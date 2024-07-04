#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

User Function PlsTrtPos()
Local aCab := {}
Local aIte := {}
Local aRet
Local nI
Local nPos
Local cCodPro
Local cCodInt
Local cUsuario
Local dData
Local cData
Local cDesEmp
Local cCodMed
Local cCodEsp
Local cUniSol
Local cCidPri,cCidOri
Local cCodMed2
Local cCodGuia
Local cNumImp
Local cCodAMB
Local nH
Local cCodRDA
Local cSQL
Local cTrailler := ""
Local aDadProntu
Local cLinProntu
Local nLimite := 50 // limite de linhas para o pronturario eletronico
LOCAL lMsgNovaMat := .F.
LOCAL cMatrNova
LOCAL lInterGen   := nil
LOCAL lIncAuto    := .T.
LOCAL cNomUsr
Local lCidInv
Local cSexo
Local cEstCiv
Local dDatNas
Local cTimeIni := Time()
Local cTimeOut := "00:01:10"   // 70 segundos ou 01 minuto e 10 segundos para timeout
Local nRegBA1 := 0
Local lChkExa := .F.
Local lCDPFSO := .F.
Local aExaRep := {}
Local aGuiRep := {}
Local aIteDePara := {}
Local nPosItem := 0
Local cCodPfSo := Space(06)
Local cMsg := ""
Local nIdThr := Val(StrTran(Time(),":",""))
Local cTmpIni
Local cLocal
Local lErro
Local cUsuOri
Local lGrupo := .f.
Local lItem  := .f.
Local lSub    := .f.
Local lBloqGru  := .f.
Local lBloqSub  := .f.
Local lBloqItem := .f.
Local cBloqOp := ""
Private lExaPe   := .f.

cDelimit := ""

/*
   aCab
		OPEMOV		- Operadora responsavel pelo movimento
		USUARIO		- Matricula do usuario
		DATPRO		- Data do procedimento
		HORAPRO		- Hora do procedimento
		CIDPRI		- Cid principal
		CODRDA		- Codigo da Rede de Atendimento

	aItens

		SEQMOV		- Sequencia do item
		CODPAD		- Codigo tipo tabela padrao (geralmente "01")
		CODPRO		- Codigo do Procedimento
		QTD			- Qtd do procedimento


	Matriz na seguinte estrutura

		[1] - Autorizada (.T.) ou nao (.F.)
		[2] - Numero da autorizacao (se for autorizada)
		[3] - Senha da autorizacao (se for autorizada)
		[4] - Criticas (se nao foi autorizada)

		       [4] na seguinte estrutura

			4,x,1 -> Sequencia do item (SEQMOV)
			4,x,2 -> Codigo da critica
			4,x,3 -> Descricao da critica
			4,x,4 -> Informacao da critica

*/
AaDd(aCab, {"TP_CLIENTE","POS"}  ) //VARIAVEL PARA O PTU-ONLINE
PlsPosLog("*** debug ****")
PlsPosLog("1-"+Upper(PlsPOSGet("ARQUIV",aDados)))
PlsPosLog("2-"+Str(Len(aItens),3))
PlsPosLog("3-"+PlsPOSGet("ARQUIV",aDados))
//PlsPtuLog("3-"+PlsPOSGet("TIPOTRANSA",aItens[1]))
cTmpIni := Time()
PlsPosLog("<<<<<< INICIO "+cTmpIni+" ID="+Str(nIdThr,10))

If Upper(PlsPOSGet("ARQUIV",aDados)) == "RETORNO.TX" .and. (Len(aItens) > 0 .and. PlsPOSGet("TIPOTRANSA",aItens[1]) == "UNI") // tipo UNI - indica solicitacao
   cCodInt := PlsPOSGet("CDUNIMED",aItens[1])
   If Empty(PlsPOSGet("CDUNIMED",aItens[Len(aItens)],"")) .and. Len(aItens) > 1  // pode vir um item a mais
       aSize(aItens,Len(aItens)-1)
   EndIf
   cCodInt := PlsPOSGet("CDUNIMED",aItens[1])
//   cCodUsu := SubStr(cCodInt,2)+PlsPOSGet("CDUSUARIO",aItens[1])
   If cCodInt # PlsIntPad() // caso seja outra unimed entao nao deve ter o zero a esquerda da operadora
      cCodUsu := cCodInt+PlsPOSGet("CDUSUARIO",aItens[1])
 		BA1->(DbSetOrder(5))
	   If !BA1->(DbSeek(xFilial("BA1")+cCodUsu)) .and. SubStr(cCodUsu,1,1) == "0"
         cCodUsu := SubStr(cCodUsu,2)
		   BA1->(DbSeek(xFilial("BA1")+cCodUsu))
      EndIf
   Else
      cCodUsu    := subs(cCodInt,2,3)+PlsPOSGet("CDUSUARIO",aItens[1])
      BA1->(DbSetOrder(5)) 
      If BA1->(DbSeek(xFilial()+cCodUsu))
	     PlsPosLog("CODUSU_ANT "+cCodUsu)
         cCodUsu    := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
      Else
         cCodUsu    := cCodInt+PlsPOSGet("CDUSUARIO",aItens[1])
         BA1->(DbSetOrder(2)) 
         If BA1->(DbSeek(xFilial()+cCodUsu))
	        PlsPosLog("CODUSU_ATU "+cCodUsu)
            cCodUsu    := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
         EndIf
      Endif
   EndIf
   PlsPosLog("****** dados do usuario inicio************")
   PlsPosLog("["+PlsPOSGet("CDUNIMED",aItens[1])+"]")
   PlsPosLog("["+PlsPOSGet("CDUSUARIO",aItens[1])+"]")
   PlsPosLog("****** dados do usuario fim ************")
   cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[1])),7)
   cCodMed2 := StrZero(Val(PlsPOSGet("CODMED2",aItens[1])),7)
   cCodEsp := Subs(PlsPOSGet("ESPMED",aItens[1]),3,2)
   PlsPosLog("ESPMED "+cCodEsp)
   If AllTrim(cCodEsp) == "77"
      cCodEsp := "40"
   Endif   
   BAQ->(DbSetOrder(3))
   BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+cCodEsp))
   cUniSol := StrZero(Val(PlsPOSGet("CDUNISOL",aItens[1])),4)
   cCidPri := PlsPOSGet("CID",aItens[1])
   if PadR(cCidPri,8) = '00000000'
     cCidOri := ""
   else
      cCidOri := cCidPri
   endif   
   cCidPri := LimpaCid(cCidPri)
   dData := Date()
   PlsPosLog("**************12345678901234567890********")
   PlsPosLog("***Usuario : ["+cCodUsu+"]")
   PLsPosLog("***OPEMOV  : ["+cUniSol+"]")
   PLsPosLog("***CODINT  : ["+cCodInt+"]")
   lErro := .F.
   If BA1->BA1_CODEMP <> "0257"
      aadd(aCab,{"ORIGEM","2"})
      aadd(aCab,{"CODLDP","0003"}) 
   Else                        
      aadd(aCab,{"ORIGEM","1"})
      aadd(aCab,{"CODLDP","0005"})
      cLocal := Upper(PlsPosGet("DESCLOCAL",aItens[1]))
      If SubStr(cLocal,1,5) # "USINA"
         lErro := .T.
      EndIf
   Endif   
   aadd(aCab,{"TPGRV","3"})
   aadd(aCab,{"OPEMOV",cUniSol})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",SubStr(StrTran(Time(),":",""),1,4)})
   aadd(aCab,{"CIDPRI",cCidPri })
   aadd(aCab,{"CODESP",BAQ->BAQ_CODESP })
   aadd(aCab,{"OPESOL",cUniSol})  // CODIGO DA UNIMED BOTUCATU
   aadd(aCab,{"LVALOR",.T.}) 
   BAW->(DbSetOrder(3))
   cCodPfSo := Space(06)
   plsposlog("Cod.Med.Solicitante (POS) ["+cCodMed2+"]")
   If Val(cCodMed2) # 0
      BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed2))
      plsposlog("Cod.Med.Solicitante (BAW) ["+BAW->BAW_CODIGO+"]")
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      aadd(aCab,{"CDPFSO",BAU->BAU_CODBB0})
      plsposlog("Cod.Med.Solicitante (BB0) ["+BAU->BAU_CODBB0+"]")
      cCodPfSo := BAU->BAU_CODBB0
      lCDPFSO := .t.
   EndIf   
   BAW->(DbSetOrder(3))
   BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
   BAU->(DbSetOrder(1))
   BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
   aadd(aCab,{"CODRDA",BAU->BAU_CODIGO})
   aadd(aCab,{"CDPFEX",BAU->BAU_CODBB0})
   aadd(aCab,{"CDOPEX",PlsIntPad()})
   plsposlog("Cod.Med.Executante (POS) ["+cCodMed+"]")
   plsposlog("Cod.Med.Executante (BAW) ["+BAW->BAW_CODIGO+"]")
   plsposlog("Cod.Med.Executante (BB0) ["+BAU->BAU_CODBB0+"]")
   aIte := {}
   For nI := 1 to Len(aItens)
      cCodPro := "01"+SubStr(PlsPOSGet("AMB",aItens[nI]),2)
      cCodAMB := PlsPOSGet("AMB",aItens[nI])
      aadd(aIte,{})
      aadd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
      aadd(aIte[nI],{"CODPAD",SubStr(cCodPro,1,2)  })
      aadd(aIte[nI],{"CODPRO",SubStr(cCodPro,3)  })
      aadd(aIte[nI],{"QTD",Val(PlsPOSGet("QUANTIDADE",aItens[nI]))/100 })
   Next
   PlsPosLog("*************************************************")
   PlsPosLog("COD AMB ["+cCodAMB+"]")
   PlsPosLog("*************************************************")
   If cCodAMB == "000010014"
      aadd(aCab,{"TIPO","1"})
   Else
      aadd(aCab,{"TIPO","2"})
   EndIf      
   BA0->(dBSetOrder(1)) //FILIAL+TIPO+OPERADORA
   BA0->(dbSeek(xFilial("BA0")+"0"+strzero(val(BA1->BA1_OPEORI),3)))
   cBloqOp := BA0->BA0_BLOINO 
   
   If (cBloqOp = "1").and.BA0->(!eof())
      PlsPosLog('Usuario - Operadora '+strzero(val(BA1->BA1_OPEORI),3))
      PlsPosPut("CODRES","01",aDados)
      PlsPosPut("MENSAGEM","Operadora do usuario bloqueada para atendimento em intercambio",aDados)
      aItens := Array(1)
      aItens[1] := aClone(aDados)
   ElseIf (subst(alltrim(BA1->BA1_MATANT),1,11) = '08550500009').or.(subst(alltrim(BA1->BA1_MATANT),1,10) = '8550500009')
      PlsPosLog('Usuario - Usuario 085505000009')
      PlsPosPut("CODRES","01",aDados)
      PlsPosPut("MENSAGEM","Usuario 085505000009 - Encaminhar usuario a UNIMED",aDados)
      aItens := Array(1)
      aItens[1] := aClone(aDados)
   ElseIf cCodAMB == "000010019"
      PlsPosLog("Atualizando CID")
      cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,9)
      cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))

//      cCodGuia := RetGuia(aCab)
      If Empty(cCodGuia)
         PlsPosPut("CODRES","01",aDados)
         PlsPosPut("MENSAGEM","Guia nao localizada para atualizar CID.",aDados)
      Else
         
         cSQL := "SELECT BAA_CODPAD, BAA_CODPRO FROM "+RetSQLName("BAA")+" WHERE "
         cSQL += "BAA_FILIAL = '"+xFilial("BAA")+"' AND "
         cSQL += "BAA_CODDOE = '"+cCidOri+"' AND "
         cSQL += "BAA_CODPAD = '01' AND "
         cSQL += "BAA_CODPRO = '00010014' AND "
         cSQL += "D_E_L_E_T_ = ''"
   
         PLSQuery(cSQL,"PLSVLDPRI")
         lCidInv := ! PLSVLDPRI->(Eof())   // se existir conteudo no SELECT entao o CID e' invalido para este procedimento
         PLSVLDPRI->(DbCloseArea())
         BA9->(DbSetOrder(1))
         If lCidINv
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Cid incompativel com um dos procedimentos da guia.",aDados)
         ElseIf !BA9->(DbSeek(xFilial()+PadR(cCidOri,8)))
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Cid invalido.",aDados)
         Else
            PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"1",.T.,"1",.T.,cCidOri,.T.)
            PlsPosLog("*** GUIA ["+cCodGuia+"] atualizada com o CID ["+cCidOri+"] ***")
            PlsPosPut("CODRES","90",aDados)      
            PlsPosPut("MENSAGEM","/ok GUIA atualizada com o CID ["+cCidOri+"]",aDados)
         EndIf
      EndIf   
      aItens := Array(1)
      aItens[1] := aClone(aDados)
   ElseIf cCodAMB == "000010017"
      PlsPosLog("Confirmacao de exame")
      cMsg := ""
      For nI := 1 to Len(aItens)
         If !Empty(cMsg)
            cMsg += Chr(13)+Chr(10)
         EndIf   
         cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[nI]),1,9)
         cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
         cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[nI])),7)
         PlsPosLog("NumImp ["+cNumImp+"]")
         PlsPosLog("CodGuia ["+cCodGuia+"]")
         PlsPosLog("CodMed ["+cCodMed+"]")
         BEA->(dBSetOrder(1))
         BEA->(dBSeek(xFilial("BEA")+Subs(cCodGuia,1,4)+Subs(cCodGuia,5,4)+Subs(cCodGuia,9,2)+Subs(cCodGuia,11)))
         BD6->(dBSetOrder(1))
         BD6->(dBSeek(xFilial("BD6")+BEA->BEA_OPEMOV+BEA->BEA_CODLDP+BEA->BEA_CODPEG+BEA->BEA_NUMGUI))
         BAW->(DbSetOrder(3))
         BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
         BAU->(DbSetOrder(1))
         BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
         cCodRDA := BAU->BAU_CODIGO
         If Empty(cCodGuia) // .AND. (COLOCAR AQUI O SE O ARQUIVO DE GUIA ESTIVER GUIA->EOF())
            cMsg += "/err Guia nao localizada."
         Else
             // Verificar aqui se o cCodRDA e' diferente do que esta na guia
            If BAU->BAU_CODIGO # BEA->BEA_CODRDA
               cMsg += "/err Nao pode ser confirmada - Dados incompativeis - Prestador"
            ElseIf BEA->BEA_TIPO # "2"
               cMsg += "/err Nao pode ser confirmada - Dados incompativeis - Guia nao e' de exames"
            ElseIf BEA->BEA_ORIGEM == "1"
               cMsg += "/err Guia ja confirmada"
            Else
               if BEA->BEA_CODEMP = "0050" 
                 
               
                  BR8->(DbSetOrder(1))
                  BR8->(dBSeek(xFilial("BR8")+BD6->BD6_CODPAD+BD6->BD6_CODPRO))
                  
                  if BR8->(Found())
                     lBloqItem := .f. 
                     PlsPosLog("Item "+BR8->BR8_CODPSA+" "+BR8->BR8_NIVEL)
                     if empty(BR8->BR8_X_BLOP).or.BR8->BR8_X_BLOP$'0'//buscar subgrupo
                        BR8->(dBSeek(xFilial("BR8")+BD6->BD6_CODPAD+subst(BD6->BD6_CODPRO,1,4)))
                        
                        if BR8->(Found())  
                           PlsPosLog("Sub "+BR8->BR8_CODPSA+" "+BR8->BR8_NIVEL)                                           
                           lSub := .f.
                           do while (subst(BD6->BD6_CODPRO,1,4)=subst(BR8->BR8_CODPSA,1,4)).and.BR8->(!eof()).and.!lSub
                              if BR8->BR8_NIVEL = '2'    
                                 lSub := .t.
                              endif   
                              BR8->(dbSkip())  
                           enddo
                           if lSub //encontrou subgrupo
                              if empty(BR8->BR8_X_BLOP).or.BR8->BR8_X_BLOP$'0'//buscar grupo
                                 BR8->(dBSeek(xFilial("BR8")+BD6->BD6_CODPAD+subst(BD6->BD6_CODPRO,1,2)))
                                 
                                 if BR8->(Found())
                                   lGrupo := .f.
                                   PlsPosLog("Grupo "+BR8->BR8_CODPSA+" "+BR8->BR8_NIVEL)
                                   do while (subst(BD6->BD6_CODPRO,1,2)=subst(BR8->BR8_CODPSA,1,2)).and.BR8->(!eof()).and.!lGrupo
                                      if BR8->BR8_NIVEL = '1'    
                                           lGrupo := .t.
                                      endif   
                                      BR8->(dbSkip())  
                                   enddo
                                   if lGrupo
                                      if BR8->BR8_X_BLOP$'1'  
                                         lBloqGru := .t.
                                      endif
                                   endif
                                 endif   
                              else
                                 lBloqSub := .t.   
                              endif
                           endif
                        endif
                     else
                        lBloqItem := .t.
                     endif         
                  endif       
                  
                  PlsPosLog("Bloq Item "+iif(lBloqItem,".t.",".f."))
                  PlsPosLog("Bloq Sub "+iif(lBloqSub,".t.",".f."))
                  PlsPosLog("Bloq Grupo "+iif(lBloqGru,".t.",".f."))
                  PlsPosLog("Bloqueios: "+"BR8 "+BR8->BR8_X_BLOP)
                  PlsPosLog("Bloqueios: "+"BAU "+BAU->BAU_X_BLOP)
                     
                  if  (BR8->BR8_X_BLOP$'1') .AND. (BAU->BAU_X_BLOP$'1')
                       cMsg += "/err Usuario intercambio - guia sera confirmada pela UNIMED"
                  else
                    PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"1",.T.,"1",.T.,"",.f.)
                    cMsg += "/ok GUIA desbloqueada."
                    PlsPosLog("*** GUIA ["+cCodGuia+"] desbloqueada ***")
                  endif    
                  
               else
                  PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"1",.T.,"1",.T.,"",.f.)
                  cMsg += "/ok GUIA desbloqueada."
                  PlsPosLog("*** GUIA ["+cCodGuia+"] desbloqueada ***")
               endif 
            EndIf   
         EndIf   
      Next   
      PlsPosLog("************************ MSG **************************************************")
      PlsPosLog(cMsg)
      PlsPosLog("************************ FIM MSG **********************************************")
      PlsPosPut("CODRES","90",aDados)      
      PlsPosPut("MENSAGEM",cMsg,aDados)
      aItens := Array(1)
      aItens[1] := aClone(aDados)
/*
      PlsPosLog("Confirmacao de exame")
      cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,9)
      cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
      cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[1])),7)
      BAW->(DbSetOrder(3))
      BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      cCodRDA := BAU->BAU_CODIGO
      If Empty(cCodGuia) // .AND. (COLOCAR AQUI O SE O ARQUIVO DE GUIA ESTIVER GUIA->EOF())
         PlsPosPut("CODRES","01",aDados)
         PlsPosPut("MENSAGEM","Guia nao localizada.",aDados)
      Else
          // Verificar aqui se o cCodRDA e' diferente do que esta na guia
         If BAU->BAU_CODIGO # BEA->BEA_CODRDA
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Nao pode ser confirmada - Dados incompativeis - Prestador",aDados)
         ElseIf BEA->BEA_TIPO # "2"
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Nao pode ser confirmada - Dados incompativeis - Guia nao e' de exames",aDados)
         EndIf
         If BEA->BEA_ORIGEM == "1"
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Guia ja confirmada",aDados)
         EndIf
         PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"1",.T.,"1",.T.,"",.f.)
         PlsPosLog("*** GUIA ["+cCodGuia+"] desbloqueada ***")
         PlsPosPut("CODRES","90",aDados)      
         PlsPosPut("MENSAGEM","/ok GUIA desbloqueada.",aDados)
      EndIf   
      aItens := Array(1)
      aItens[1] := aClone(aDados)
*/
   ElseIf cCodAMB == "000010016"
      PlsPosLog("Reemitindo consulta")
      cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,9)
      cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
      cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[1])),7)
      cUniSol := StrZero(Val(PlsPOSGet("CDUNISOL",aItens[1])),4)
      PlsPosLog("passo 1")
//      BAU->(DbSetOrder(1))
//      BAU->(DbSeek(xFilial("BAU")+BEA->BEA_CODRDA))
      BAW->(DbSetOrder(3))
      BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
      PlsPosLog("passo 2")
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      PlsPosLog("passo 3")
      BA1->(DbSetOrder(2)) 
      BA1->(DbSeek(xFilial()+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG) ))
      PlsPosLog("passo 4")
      BAQ->(DbSetOrder(1))
      BAQ->(DbSeek(xFilial("BAQ")+BEA->BEA_OPEUSR+BEA->BEA_CODESP))
      cCodRDA := BAU->BAU_CODIGO
      PlsPosLog("passo 5")
      If Empty(cCodGuia) .or. Val(cNumImp) == 0 // .AND. (COLOCAR AQUI O SE O ARQUIVO DE GUIA ESTIVER GUIA->EOF())
         PlsPosPut("CODRES","90",aDados)
         PlsPosPut("MENSAGEM","/err Guia nao localizada.",aDados)
         PlsPosLog("Guia nao localizada.")
         For nI := 1 to Len(aItens)
            PlsPosPut("CODRES","90",aItens[nI])
            PlsPosPut("MENSAGEM","/err Guia nao localizada.",aItens[nI])
         Next
      Else
         If BAU->BAU_CODIGO # BEA->BEA_CODRDA
            PlsPosPut("CODRES","90",aDados)
            PlsPosPut("MENSAGEM","/err Guia nao pode ser re-emitida - Dados incompativeis - Prestador",aDados)
            PlsPosLog("Nao pode ser re-emitida - Dados incompativeis - Prestador")
            For nI := 1 to Len(aItens)
               PlsPosPut("CODRES","90",aItens[nI])
               PlsPosPut("MENSAGEM","/err Guia nao pode ser re-emitida - Dados incompativeis - Prestador",aItens[nI])
            Next
         Else
            PlsPosPut("RESPOSTA","01",aDados)
            PlsPosPut("CODRES","00",aDados)
            For nI := 1 to Len(aItens)
               cCodPro := "01"+SubStr(PlsPOSGet("AMB",aItens[nI]),2)
               PlsPosPut("CODRES","00",aItens[nI])
               PlsPosPut("NRGUIA",Strzero(vAL(cNumImp),9),aItens[nI])
               PlsPosPut("CDUSUARIO",Transform(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),__cPictUsr),aItens[nI])
               PlsPosPut("NOME",BA1->BA1_NOMUSR,aItens[nI])
               PlsPosPut("PLANO",Posicione("BA3",1,xFilial("BA3")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB,"BA3_CODPLA")  ,aItens[nI])
               If !Empty(BA3->BA3_CONEMP)
                 cDesEmp := Posicione("BG9",1,xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP+"2","BG9_DESCRI")
               Else
                 cDesEmp := Posicione("BG9",1,xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP+"1","BG9_DESCRI")
               Endif
               PlsPosPut("EMPRESA",AllTrim(cDesEmp),aItens[nI])
               PlsPosPut("DATA",DtoC(BEA->BEA_DATPRO)+" "+Time()  ,aItens[nI])
               PlsPosPut("ESPECIALID",BEA->BEA_DESESP,aItens[nI])
               PlsPosPut("PRESTADOR",AllTrim(BAU->BAU_NOME),aItens[nI])
               PlsPosPut("COMENTARIO",  ,aItens[nI])
               PlsPosPut("DESCAMB",Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"),aItens[nI])
            Next   
         EndIf
      EndIf
   ElseIf .f.   // aguardar autorizacao do FARALDO para colocar cCodAMB == "000010021"  // atualizacao de medico executante
      PlsPosLog("Atualizacao de executante")
      cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,9)
      cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
      cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[1])),7)
      BAW->(DbSetOrder(3))
      BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))

      If Empty(cCodGuia) // .AND. (COLOCAR AQUI O SE O ARQUIVO DE GUIA ESTIVER GUIA->EOF())
         PlsPosPut("CODRES","01",aDados)
         PlsPosPut("MENSAGEM","Guia nao localizada.",aDados)
      Else
         PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"",.F.,"",.F.,"",.F.,BAU->BAU_CODBB0,.T.)
         PlsPosLog("*** GUIA ["+cCodGuia+"] atualizada com executante ["+BAU->BAU_CODBB0+"] ***")
         PlsPosPut("CODRES","90",aDados)      
         PlsPosPut("MENSAGEM","/ok Executante atualizado na Guia.",aDados)
      EndIf   
      aItens := Array(1)
      aItens[1] := aClone(aDados)
   ElseIf cCodAMB == "000010018"  // cadastro de usuarios de intercambio
      cNomUsr   := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,30)
      dDatNas   := CtoD(SubStr(PlsPOSGet("DESCVALAD",aItens[1]),31,10))
      cCodInt   := PlsPOSGet("CDUNIMED",aItens[1])
      cMatrNova := AllTrim(cCodInt+PlsPOSGet("CDUSUARIO",aItens[1]))
      If SubStr(PlsPOSGet("CID",aItens[1]),2,1)=="M"
         cSexo := "1"
      ElseIf SubStr(PlsPOSGet("CID",aItens[1]),2,1)=="F"
         cSexo := "2"
      Else
         cSexo := "0"
      EndIf
      If SubStr(PlsPOSGet("CID",aItens[1]),1,1) == "M"  // casado
         cEstCivil := "C"
      ElseIf SubStr(PlsPOSGet("CID",aItens[1]),1,1) == "A"  // Separado
         cEstCivil := "Q"
      ElseIf SubStr(PlsPOSGet("CID",aItens[1]),1,1) == "W"  // Viuvo
         cEstCivil := "V"
      Else   
         cEstCivil := SubStr(PlsPOSGet("CID",aItens[1]),1,1)
      EndIf   
      lMsgNovaMat := .F.
      lInterGen   := nil
      lIncAuto    := .T.


      PlsPosLog("Cadastrando Usuarios de Intercambio")
      PlsPosLog("************************************************")
      PlsPosLog("Nome      "+cNomUsr)
      PlsPosLog("Dt.Nasc   "+Dtoc(dDatNas))
      PlsPosLog("CodInt    "+cCodInt)
      PlsPosLog("Matricula "+cMatrNova)
      PlsPosLog("Sexo      "+cSexo)
      PlsPosLog("EstCivil  "+cEstCivil)
      PlsPosLog("************************************************")

      If PLSA235(lMsgNovaMat,cMatrNova,lInterGen,lIncAuto,cNomUsr)[1]  // INCLUIDO
         BA1->(RecLock("BA1",.F.))
         BA1->BA1_ESTCIV := cEstCiv
         BA1->BA1_SEXO   := cSexo
         BA1->BA1_DATNAS := dDatNas
         BA1->(DbUnlock())
         BA1->(DbCommit())
         PlsPosPut("CODRES","90",aDados)
         PlsPosPut("MENSAGEM","/ok usuario cadastrado",aDados)
      Else
         PlsPosPut("CODRES","90",aDados)
         PlsPosPut("MENSAGEM","/err usuario nao cadastrado",aDados)
      EndIf   
   ElseIf cCodAMB == "000000000" .or. cCodAMB == "000010020"  // cancelamento
      cNumImp := SubStr(PlsPOSGet("DESCVALAD",aItens[1]),1,9)
      PlsPosLog("cancelando impresso ["+cNumImp+"]")
      cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
      cCodMed := StrZero(Val(PlsPOSGet("CODMED",aItens[1])),7)
      cUniSol := StrZero(Val(PlsPOSGet("CDUNISOL",aItens[1])),4)
      BAW->(DbSetOrder(3))
      BAW->(DbSeek(xFilial("BAW")+cUniSol+cCodMed))
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      PlsPosLog("cancelando guia ["+cCodGuia+"]")
      If Empty(cCodGuia) .or. Val(cNumImp) == 0
         PlsPosPut("CODRES","01",aDados)
         PlsPosPut("MENSAGEM","Guia nao localizada.",aDados)
      ElseIf BAU->BAU_CODIGO # BEA->BEA_CODRDA
         PlsPosPut("CODRES","01",aDados)
         PlsPosPut("MENSAGEM","Guia nao pode ser cancelada - Dados incompativeis - Prestador",aDados)
      Else
         If BEA->BEA_ORIGEM#"2"
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Guia nao pode ser cancelada - ja processada",aDados)
         ElseIf .f.   //  NAO CHECAR USUARIO NO CANCELAMENTO - AllTrim(BEA->BEA_MATANT) # AllTrim(cCodUsu) .and. AllTrim(cCodUsu) # BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Guia nao pode ser cancelada - Dados incompativeis - Usuario [1] ["+cCodUsu+"] ["+AllTrim(BEA->BEA_MATANT)+"] ["+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)+"]",aDados)
         ElseIf BAU->BAU_CODIGO # BEA->BEA_CODRDA
            PlsPosPut("CODRES","01",aDados)
            PlsPosPut("MENSAGEM","Guia nao pode ser cancelada - Dados incompativeis - Prestador",aDados)
         Else
            PLSXEXCA(cCodGuia)
            PlsPosLog("*** GUIA CANCELADA ["+cCodGuia+"]***")
            PlsPosLog("*** IMPRESSO ["+cNumImp+"]***")
            PlsPosPut("CODRES","90",aDados)
            PlsPosPut("MENSAGEM","/ok GUIA cancelada. Impresso ["+cNumImp+"] codigo Microsiga ["+cCodGuia+"]",aDados)
         EndIf
      EndIf   
      aItens := Array(1)
      aItens[1] := aClone(aDados)
   Else
  	  lChkExa := .T.
   	  nRegBA1 := BA1->(Recno())
   	  If cCodInt # PlsIntPad() .OR. (!lCDPFSO .and. cCodAMB # "000010014") // quanto e' intercambio nao se checa exames repetidos ou entao quanto nao tem profissional solicitante e nao e' consulta
         lChkExa := .F.
   	  Else
         If PLSUSRINTE(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),dData)  // VERIFICA SE USUARIO ESTA INTERNADO, ESTANDO INTERNADO PODERA SER FEITO VARIOS EXAMES IGUAIS NO MESMO DIA
      	    lChkExa := .F.
      	 EndIf
      EndIf 	 
      aIte    := {}
      aExaRep := {}
      aGuiRep := {}
      lExaPe  := .F.
      If Len(aItens) == 1 .and. PlsPOSGet("AMB",aItens[1]) == "28130480"
         lExaPe := .T.
         aadd(aItens,aItens[1])
         aadd(aItens,aItens[1])
         aadd(aItens,aItens[1])
         PlsPosPut("AMB","28040465",aItens[1])
         PlsPosPut("AMB","28050703",aItens[2])
         PlsPosPut("AMB","28050711",aItens[3])
         PlsPosPut("AMB","28130197",aItens[4])
      EndIf
      For nI := 1 to Len(aItens)
         cCodPro := "01"+SubStr(PlsPOSGet("AMB",aItens[nI]),2)
         PlsPosLog("cod pro ["+cCodPro+"]")
         If cCodPro == "0181010010"  // temporario, retirar depois
            cCodPro := "0180031005"
            PlsPosLog("alterado COD AMB ["+cCodPro+"]")
         EndIf   
         If lChkExa
            cSQL     := "SELECT R_E_C_N_O_,BE2_NUMIMP FROM "+RetSQLName("BE2")+" WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND D_E_L_E_T_ = '' AND "+;
                                                                                   "BE2_OPEUSR='"+BA1->BA1_CODINT+"' AND "+;
                                                                                   "BE2_CODEMP='"+BA1->BA1_CODEMP+"' AND "+;
                                                                                   "BE2_MATRIC='"+BA1->BA1_MATRIC+"' AND "+;
                                                                                   "BE2_TIPREG='"+BA1->BA1_TIPREG+"' AND "+;
                                                                                   "BE2_DIGITO='"+BA1->BA1_DIGITO+"' AND "+;
                                                                                   "BE2_CODPAD='"+SubStr(cCodPro,1,2)+"' AND "+;
                                                                                   "BE2_CODPRO='"+SubStr(cCodPro,3)+"' AND "+;
                                                                                   "BE2_CDPFSO='"+cCodPfSo+"' AND "
            If cCodAMB == "000010014"
               cSQL+="BE2_CODRDA='"+BAU->BAU_CODIGO+"' AND "
            EndIf         
            cSQL+="BE2_DATPRO='"+DtoS(dData)+"' "
            PlsPosLog("*****************************************************")
            PlsPosLog("Query "+StrZero(nI,2))
            PlsPosLog(cSql)                                                                                   
            PLSQUERY(cSQL,"PLSTEMP")                
            If !PLSTEMP->(Eof())
               aadd(aExaRep,nI)   // array para controle de itens de exames repetidos
               aadd(aGuiRep,PLSTEMP->BE2_NUMIMP)
               PLSTEMP->(DbCloseArea())
               Loop
            EndIf   
            PLSTEMP->(DbCloseArea())
         EndIf
         aadd(aIte,{})
         aadd(aIte[Len(aIte)],{"SEQMOV",StrZero(nI,3) })
         aadd(aIte[Len(aIte)],{"CODPAD",SubStr(cCodPro,1,2)  })
         aadd(aIte[Len(aIte)],{"CODPRO",SubStr(cCodPro,3)  })
         aadd(aIte[Len(aIte)],{"QTD",Val(PlsPOSGet("QUANTIDADE",aItens[nI]))/100 })
         aadd(aIteDePara,{nI,Len(aIte)})  // array necessario para sincronizar aIte com aItens
      Next
      PlsPosLog("autorizando...")
      If Len(aIte) > 0 .and. !lErro
         nH       := PLSAbreSem("PLSTRTPOS.SMF")
         cSQL     := "SELECT MAX(BD6_NUMIMP) MAIOR FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND BD6_NUMIMP>='0000000100000000' AND BD6_NUMIMP<='0000000999999999' "
         PLSQUERY(cSQL,"PLSTEMP")                
         If Val(PLSTEMP->MAIOR) > 0
            cNumImp := StrZero(Val(PLSTEMP->MAIOR)+1,16)
         Else
            cNumImp := StrZero(100000000,16)
         EndIf
         PLSTEMP->(DbCloseArea())
         aadd(aCab,{"NUMIMP",cNumImp})   
         aRet := PLSXAUTP(aCab,aIte)  
         PLSFechaSem(nH)
         If cCodAMB # "000010014"
            BEA->(RecLock("BEA"))
            BEA->BEA_TIPO := "2"
            BEA->(MsUnlock())
         EndIf
         MsgErro(aRet)
         PlsPosLog("NOME "+BAU->BAU_NOME)
         If lExaPe
            aDel(aItens,4)
            aDel(aItens,3)
            aDel(aItens,2)
            aSize(aItens,1)
            PlsPOSPut("AMB","28130480",aItens[1])  // volta o codigo original
            // as mensagens de erro que foram para os outros codigos e' gerado para o codigo original
            For nI := 1 to Len(aRet[4])
               aRet[4,nI,1] := "01"
            Next
         EndIf
         If aRet[1]   // autor izou
//            BA1->(DbGoto(nRegBA1))
            PlsPosPut("RESPOSTA","01",aDados)
            PlsPosPut("CODRES","00",aDados)
            For nI := 1 to Len(aItens)
               cCodPro := "01"+SubStr(PlsPOSGet("AMB",aItens[nI]),2)
               If cCodPro == "0181010010"  // temporario, retirar depois
                  cCodPro := "0180031005"
                  PlsPosLog("alterado COD AMB ["+cCodPro+"]")
               EndIf   
               PlsPosLog("*** AUTORIZADO ***")
               PlsPosLog("GUIA NUMERO ["+aRet[2]+"]")
               PlsPosLog("IMPRESSO NUMERO ["+Guia2Imp(aRet[2])+"]")
               PlsPosPut("CODRES","00",aItens[nI])
               PlsPosPut("NRGUIA",Strzero(vAL(cNumImp),9),aItens[nI])
               If cCodInt # PlsIntPad()
                  cCodUsu := cCodInt+PlsPOSGet("CDUSUARIO",aItens[1])
               EndIf
               If Len(AllTrim(cCodUsu)) == 17
                  PlsPosPut("CDUSUARIO",Transform(cCodUsu,__cPictUsr)+"-"+SubStr(cCodUsu,Len(cCodUsu),1) ,aItens[nI])
               Else
                  PlsPosPut("CDUSUARIO",Transform(cCodUsu,"@R !!!.!!!!.!!!!!!-!!")+"-"+SubStr(cCodUsu,Len(cCodUsu),1) ,aItens[nI])
               EndIf   
               PlsPosPut("NOME",BA1->BA1_NOMUSR,aItens[nI])
               PlsPosPut("PLANO",Posicione("BA3",1,xFilial("BA3")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB,"BA3_CODPLA")  ,aItens[nI])
               If !Empty(BA3->BA3_CONEMP)
                  cDesEmp := Posicione("BG9",1,xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP+"2","BG9_DESCRI")
               Else
                  cDesEmp := Posicione("BG9",1,xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP+"1","BG9_DESCRI")
               Endif
               PlsPosPut("EMPRESA",AllTrim(cDesEmp),aItens[nI])
               PlsPosPut("DATA",DtoC(Date())+" "+Time()  ,aItens[nI])
               PlsPosPut("ESPECIALID",BAQ->BAQ_DESCRI,aItens[nI])
               PlsPosPut("PRESTADOR",AllTrim(BAU->BAU_NOME),aItens[nI])
               If Len(aRet) >= 9 .And. ! Empty(aRet[9])
                  PlsPosPut("COMENTARIO",aRet[9],aItens[nI])
               Else   
                  PlsPosPut("COMENTARIO",  ,aItens[nI])
               Endif
               PlsPosPut("DESCAMB",Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"),aItens[nI])
            Next   
            // necessario este bloco porque mesmo a guia tendo sida autorizada ALGUNS itens podem ter sido recusados.
            If Len(aRet) >= 4
               For nI := 1 to Len(aRet[4])
                  PlsPosLog("**** "+StrZero(Val(aRet[4,nI,1]),2))
                  PlsPosLog("Codigo da Critica "+aRet[4,nI,2])
                  PlsPosLog("Descricao         "+aRet[4,nI,3])
                  nPosItem := PosItem(aIteDePara,Val(aRet[4,nI,1]),1)  // de acordo com o aIte busca a linha correspondente no aItens
                  PlsPosPut("CODRES","01",aItens[nPosItem])
                  If Empty(PlsPosGet("MENSAGEM",aItens[nPosItem]))
                     PlsPosPut("MENSAGEM",AllTrim(aRet[4,1,3]),aItens[nPosItem])
                     PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[nPosItem]))
                  EndIf   
               Next
            EndIf
            // grava mensagem caso algum exame ja tenha sido liberado no dia
            For nI := 1 to Len(aItens)
               PlsPosLog("**** "+StrZero(nI,2))
               If Empty(PlsPosGet("MENSAGEM",aItens[nI]))
                  If (nPos := aScan(aExaRep,nI)) > 0  // se estiver no array que controla exames repetidos
                     PlsPosPut("CODRES","01",aItens[nI])
                     PlsPosPut("MENSAGEM","Servico ja liberado neste dia. ["+aGuiRep[nPos]+"]",aItens[nI])
                  EndIf
                  PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[nI]))
               EndIf   
            Next
            // aqui deve ser colocado as informacoes para Pronturario Eletronico
            // adiciona dados do prontuario eletronico (colocado dentro da funcao DadosPron()
         Else  // nao autorizou
            PlsPosLog("*** NAO AUTORIZADO ***")      
            PlsPosPut("CODRES","01",aDados)
            PlsPosLog("************ LOG DE ERRO 02 ***********")
            For nI := 1 to Len(aRet[4])
               PlsPosLog("**** "+StrZero(Val(aRet[4,nI,1]),2))
               PlsPosLog("Codigo da Critica "+aRet[4,nI,2])
               PlsPosLog("Descricao         "+aRet[4,nI,3])
               nPosItem := PosItem(aIteDePara,Val(aRet[4,nI,1]),1)  // de acordo com o aIte busca a linha correspondente no aItens
               PlsPosPut("CODRES","01",aItens[nPosItem])
               If Empty(PlsPosGet("MENSAGEM",aItens[nPosItem]))
                  PlsPosPut("MENSAGEM",AllTrim(aRet[4,nI,3]),aItens[nPosItem])
                  PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[nPosItem]))
               EndIf   
            Next
            PlsPosLog("************ LOG DE ERRO 01 ***********")
            For nI := 1 to Len(aItens)
               PlsPosLog("**** "+StrZero(nI,2))
               PlsPosLog("Codigo da Critica "+aRet[4,1,2])
               PlsPosLog("Descricao         "+aRet[4,1,3])
               PlsPosPut("CODRES","01",aItens[nI])
               If Empty(PlsPosGet("MENSAGEM",aItens[nI]))
                  If (nPos:=aScan(aExaRep,nI)) > 0  // se estiver no array que controla exames repetidos
                     PlsPosPut("MENSAGEM","Servico ja liberado neste dia. ["+aGuiRep[nPos]+"]",aItens[nI])
                  Else
                     PlsPosPut("MENSAGEM",AllTrim(aRet[4,1,3]),aItens[nI])
                  EndIf   
                  PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[nI]))
               EndIf   
            Next
         EndIf
      Else   // caso todos os itens da solicitacao ja tenham sido liberados neste dia
         If lErro
            PlsPosLog("*** NAO AUTORIZADO, GUIAS EMITIDAS SOMENTE NA USINA ***")      
            PlsPosLog("Local solicitado : "+cLocal)
            PlsPosPut("CODRES","01",aDados)
            For nI := 1 to Len(aItens)
               PlsPosPut("CODRES","01",aItens[nI])
               PlsPosPut("MENSAGEM","Nao autorizado. Guias emitidas somente na usina.",aItens[nI])
            Next
         Else
            If lExaPe
               aDel(aItens,4)
               aDel(aItens,3)
               aDel(aItens,2)
               aSize(aItens,1)
               PlsPOSPut("AMB","28130480",aItens[1])  // volta o codigo original
            EndIf
            PlsPosLog("*** NAO AUTORIZADO, EXAME JA LIBERADO NA DATA ***")      
            PlsPosPut("CODRES","01",aDados)
            For nI := 1 to Len(aItens)
               PlsPosPut("CODRES","01",aItens[nI])
               PlsPosPut("MENSAGEM","Servico ja liberado neste dia. ["+aGuiRep[nI]+"]",aItens[nI])
            Next
         EndIf   
      EndIf
   EndIf
ElseIf (Len(aItens) > 0 .and. PlsPOSGet("TIPOTRANSA",aDados) == "UN2") // tipo UN2 - confirmacao
ElseIf (Len(aItens) > 0 .and. PlsPOSGet("TIPOTRANSA",aDados) == "AUT") // MODULO CADASTRO INTERCAMBIO
   PlsPosLog("************************************************")
   PlsPosLog("DESCLOCAL "+PlsPosGet("DESCLOCAL",aItens[1]))
   PlsPosLog("TIPOTRAN2 "+PlsPosGet("TIPOTRAN2",aItens[1]))
   PlsPosLog("CARTAO    "+PlsPosGet("CARTAO",aItens[1]))
   PlsPosLog("CODPREST  "+PlsPosGet("CODPREST",aItens[1]))
   PlsPosLog("ESPPREST  "+PlsPosGet("ESPPREST",aItens[1]))
   PlsPosLog("NOME      "+PlsPosGet("NOME",aItens[1]))
   PlsPosLog("ESTCIV    "+PlsPosGet("ESTCIV",aItens[1]))
   PlsPosLog("SEXO      "+PlsPosGet("SEXO",aItens[1]))
   PlsPosLog("DTNASC    "+PlsPosGet("DTNASC",aItens[1]))
   PlsPosLog("PLANO     "+PlsPosGet("PLANO",aItens[1]))
   PlsPosLog("************************************************")
   lMsgNovaMat := .F.
   cMatrNova   := StrTran(PlsPosGet("CARTAO",aItens[1]),".","")
   cMatrNova   := StrTran(cMatrNova,"-","")
   lInterGen   := nil
   lIncAuto    := .T.
   cNomUsr     := PlsPosGet("NOME",aItens[1]) 
   If PlsPosGet("SEXO",aItens[1])=="M"
      cSexo := "1"
   ElseIf PlsPosGet("SEXO",aItens[1])=="F"
      cSexo := "2"
   Else
      cSexo := "0"
   EndIf
   If PlsPosGet("ESTCIV",aItens[1]) == "M"  // casado
      cEstCivil := "C"
   ElseIf PlsPosGet("ESTCIV",aItens[1]) == "A"  // Separado
      cEstCivil := "Q"
   ElseIf PlsPosGet("ESTCIV",aItens[1]) == "W"  // Viuvo
      cEstCivil := "V"
   Else   
      cEstCivil := PlsPosGet("ESTCIV",aItens[1])
   EndIf   
   dDatNas := CtoD(PlsPosGet("DTNASC",aItens[1]))
   PLSA235(lMsgNovaMat,cMatrNova,lInterGen,lIncAuto,cNomUsr)
   BA1->(RecLock("BA1",.F.))
   BA1->BA1_ESTCIV := cEstCiv
   BA1->BA1_SEXO   := cSexo
   BA1->BA1_DATNAS := dDatNas
   BA1->(DbUnlock())
   BA1->(DbCommit())
   PlsPosPut("CODRES","90",aDados)
   PlsPosPut("MENSAGEM","/ok usuario cadastrado",aDados)
EndIf

PlsPosPut("TRAILLER",cTrailler,aDados)
PlsPosLog("<<<<<< FIM "+Time()+" Tempo Total "+ElapTime(cTmpIni,Time())+" ID="+Str(nIdThr,10))

If ElapTime(cTimeIni,Time()) > cTimeOut // verifica se do momento que entrou ate o atual passou mais que o tempo estipulado para timeout
   PlsPosLog("*********************")
   PlsPosLog("TIMEOUT => "+cTimeIni+" / "+Time())
   PlsPosLog("ID => "+Str(nIdThr,10))
   PlsPosLog("*********************")
   lTimeOut := .T.   // variavel que define que houve TIMEOUT
   MS_QUIT()
EndIf

Return

User Function PlsEndPos()
Local cDriveProc := ParamIxb[1]
Local cPathOut := ParamIxb[2]
Local cPathIn  := ParamIxb[3]
Local aFilesP
Local nTotFiles
Local nI

aFilesP := Directory(cDriveProc+cPathOut+'*.*')
 
For nI := 1 to len(aFilesP)
   fErase(cPathIn+aFilesP[nI][1])
   If fREname(cDriveProc+cPathOut+aFilesP[nI][1] , cPathIn+aFilesP[nI][1] )#-1
      PlsPosLog("renomeado para "+cPathIn+aFilesP[nI][1])
   EndIf   
Next

Return

User Function PlsArqPos()
Local cPathIn := ParamIxb[1]
Local aFiles
aFiles := Directory(cPathIn+'*.TXT')
Return aFiles


/*
funcao para deletar

PLSXEXCA(cNumeroAut)
*/


Static Function Guia2Imp(cGuia)
LOCAL cRet := ""
BEA->(DbSetOrder(1))
If BEA->(DbSeek(xFilial("BEA")+cGuia))
   cRet := BEA->BEA_NUMIMP
Endif   

Return cRet

Static Function Imp2Guia(cImp)
LOCAL cRet := ""
BEA->(DbSetOrder(9))
If BEA->(DbSeek(xFilial("BEA")+StrZero(Val(cImp),16)))
   cRet := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
Endif
   
Return cRet

Static Function RetGuia(aDados)
LOCAL cMatric   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "USUARIO"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL dDatPro   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "DATPRO"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cHora     := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "HORAPRO"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cOpeMov   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "OPEMOV"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cCidPri   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "CIDPRI"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cCodRda   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "CODRDA"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cOpeSol   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "OPESOL"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cCDPFSO   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "CDPFSO"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cCodEsp   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "CODESP"}), IF(nPos>0,aDados[nPos,2],"") })
LOCAL cSQL
LOCAL aRetFun
LOCAL lOK
LOCAL aDadUsr                            
LOCAL cUsuario
LOCAL cNumGui   := ""

aRetFun := PLSA090USR(cMatric,dDatPro,cHora,"BE1",.F.,.T.)

lOK  := aRetFun[1]
aTrb := aRetFun[2]
If lOK
   aDadUsr  := PLSGETUSR()
   cUsuario := aDadUsr[2]
Endif  

If lOK
   BEA->(DbSetOrder(8))
   If BEA->(DbSeek(xFilial("BEA")+cUsuario+cCodRda+dtos(dDatPro)+"01"+Space(Len(BEA->BEA_CID))))
      cNumGui := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
   Endif     
Endif   
   
Return(cNumGui)

// funcao que altera mensagens de erro conforme campo BCT_DESPOS
Static Function MsgErro(aRet)
Local nI
BCT->(DbSetOrder(1))
For nI := 1 to Len(aRet[4])
   If BCT->(DbSeek(xFilial()+PlsIntPad()+aRet[4,nI,2])) .and. !Empty(BCT->BCT_DESPOS)
      aRet[4,nI,3] := BCT->BCT_DESPOS
   EndIf
Next
Return

Static Function LimpaCid(cCidPri)
Local cCid := ""
Local nI
Local cCar

For nI := 1 to Len(cCidPri)
   cCar := SubStr(cCidPri,nI,1)
   If cCar $ "0123456789" .or. (Upper(cCar) >= "A" .and. Upper(cCar) <= "Z")
      cCid+=cCar
   EndIf
Next


Return cCid

// nTipo == 1 busca o item do aIte relacionado no aItens
// nTipo == 2 busca o item do aItens relacionado no aIte
Static Function PosItem(aIteDePara,nPos,nTipo)
Local nPosRet := 0
If nTipo == 1
   nPosRet := aScan(aIteDePara,{|x| x[2] == nPos})
Else
   nPosRet := aScan(aIteDePara,{|x| x[1] == nPos})
EndIf
If lExaPe
   nPosRet := 1
EndIf
Return nPosRet


Static Function DadosPron()
// inicio
//                                            / aqui estao os campos pedidos para retorno /
/*         aDadProntu := PLSGETMOV(cCodUsu,180,{"BD6_DATPRO","BD6_CODPRO","BD6_DESPRO"},nLimite)
         If Len(aDadProntu) > 0
            cTrailler := '/ext'
            For nI := 1 to Len(aDadProntu)
               // aqui no CLINPRONTU vc monta a string que sera enviada ao client do POS
               cLinProntu := DtoC(aDadProntu[nI,1])+' - '+Transform(aDadProntu[nI,2],"@R 99.99.999-9")+' '+aDadProntu[nI,3]
               cTrailler+='"'+cLinProntu+'"'
               If nI # Len(aDadProntu)
                  cTrailler+=','
               EndIf
            Next
         EndIf   
*/
// fim

Return


User Function PLSPOSJOB()
Local cStartPath := ParamIxb[1]
Local cMask := cStartPath+"\POS_PROC\ONLINE\*.POS"
Local aFiles := Directory(cMask)
Local nI
Local cFile
Local nH

For nI := 1 to Len(aFiles)
   cFile := cStartPath+"\POS_PROC\ONLINE\"+StrTran(aFiles[nI,1],".POS",".FIM")
   nH := FCreate(cFile)
   FClose(nH)
Next

Return
