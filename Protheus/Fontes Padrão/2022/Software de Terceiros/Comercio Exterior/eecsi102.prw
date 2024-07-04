#Include "EEC.cH"  
#Include "EECSI102.CH"   

#define BLOCK_READ 1024    // Blocos de leitura
#DEFINE FO_READ       0    // Open for reading (default)
#DEFINE FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)

/*
Funcao      : SI102AltRE(cUser, nOpcao, nAgrupa)
Parametros  : cUser: usuário do Siscomex
              nOpcao: alteração de RE. Usada na chamada da função SI100GeraTXT
              nAgrupa: tipo de agrupamento de itens do processo
Retorno     : Nill
Objetivos   : Alteração de Re:
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/05 16:48 
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisão     : WFS 28/05/09: Correção nos tratamentos de geração de arquivos de integração com o Siscomex.
                            Alteração nas chamadas de funções, para que sejam usados os mesmos tratamentos
                            de geração das works (agrupamentos).
*/
Function SI102AltRE(cUser, nOpcao, nAgrupa)
Local  oMark  
Local  cTempFile,cRC
Local  aSemSx3 , aTb_Campos:= {}, aCampos
Local  nOpc    := 0 
Local  lRet    := .F. 
Local  bOk     := {|| If(IsMark("Work", "WK_FLAG"),(nOpc := 1,oDlg:End()),HELP(" ",1,"AVG0005067") ) } //MsgInfo("Não há registros marcado para a Geração de Arquivos !","Aviso")
Local  bCancel := {|| nOpc := 0, oDlg:End()}
Local aRet:= {}
Local nAliasOld:= Select()
Private aPos, aHEADER:={} 

Begin Sequence

   aRet:= SI100GeraTXT(cUser, nOpcao, nAgrupa)
   
   If ValType(aRet) == "A"
      lRet:= aRet[1] //.T. ou .F.
      cTempFile:= aRet[2] //arquivo da Work
   Else
      lRet:= aRet
   EndIf

   If !lRet
      Break
   EndIf

End Sequence 

If Select("Work") > 0
   Work->(E_EraseArq(cTempFile))
EndIf

Select(nAliasOld)
Return lRet

/*
Funcao      : CriaTxt
Parametros  : cRE  := Número da RE
              cUser:= Identificacao do Usuario do Siscomex
              cDir := Diretorio
              cFile:= Nome do Arquivo a ser Gerado
              cRc  :=
Retorno     : NIL
Objetivos   : Cria Txt
Autor       : Michelle da Silva Veleso
Data/Hora   : 30/08/2005 17:07 
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisão     : WFS 28/05/09: Correção nos tratamentos de geração de arquivos de integração com o Siscomex.
                            Alteração nas chamadas de funções, para que sejam usados os mesmos tratamentos
                            de geração das works (agrupamentos).
Obs.        :
*/

Static Function SI102CriaTxt(cFile, cFiles, cUser)
Local aOrd := SaveOrd({"EEP","EEC","EE9","SYD","SY6"})           
Local hFile := 0,nCONT
Local cExpFabr := "", cObs := "", cPeriod := "", cNcm 
Local lP_RC 
Local lIntEDC:=EasyGParam("MV_EEC_EDC",,.F.)
Local nAnteci:=0,nTotPed:=0,nVlCalc:=0,nAvista:=0,nParcel:=0,nVlCons:=0,nFincia:=EEC->EEC_FINCIA,cFileItem,nSize:=0,;
      nLidos:=0, nVlAux:=0, nPerc:=0, nDias:=0, nSoma:=0, nNroParc :=0, nPeriodo:=0, nVlSemCob:= 0
Local cAtoCon:= Work->EE9_ATOCON
Local cKSA2 := "", nx:=0, z:=0
Local cEnquadra:="" 
Local cDir:= EasyGParam("MV_AVG0002") //Diretório para geração dos arquivos
Local nSeq
//Tratamentos da inclusão do RE replicados para alteração do RE
Local nTotCondVen:=0,nTotLocEmb:=0
Private cBuffer := "" 
Private nSemCobCamb := 0 // JPM - 10/03/06 - Definido como private para utilização no ponto de entrada.

EEP->(dbSetOrder(1))
EEC->(dbSetOrder(1))
EE9->(dbSetOrder(4))

Begin Sequence
//WFS 29/05/2009 ---
Work->(DBGoTop())
While !Work->(Eof())
   If !Empty(Work->WK_FLAG)
      nSeq:= EasyGParam("MV_AVG0001") //Próxima sequência de arquivo a ser gerado para o Siscomex
      SetMv("MV_AVG0001", nSeq + 1)
      cFile:= "ea" + Padl(nSeq, 6, "0") + ".inc"

      //Ponto de entrada que permite alterar os dados que serão escritos no arquivo .INC, manipulando a Work.
      If EasyEntryPoint("EECSI102")
         ExecBlock("EECSI102", .F., .F., {"WorkTxt"})
      EndIf

      cRC:= Work->EE9_RC
      cRE:= Work->EE9_RE
//---
      lP_RC := !Empty(cRC)
      // Cria o Arquivo ...
      hFile := EasyCreateFile(cDir+cFile)
   
      IF ! (hFile > 0)
         MsgStop(STR0011+cDir+cFile,STR0001) // "Erro na criação do arquivo: " ## "Aviso"
         Break
      Endif
   
      cFileItem := AllTrim(CriaTrab(,.F.))+".TXT"
      hItHandle := EasyCreateFile(cDir+cFileItem)
      If !(hItHandle>0)
         MsgStop(STR0011+cDir+cFileItem,STR0001) // "Erro na criação do arquivo: " ## "Aviso"
         Break   
      EndIf

      cBuffer:="" 
   
      // Linha 05                      
      cNcm := Work->EE9_POSIPI


      IF SYD->(FieldPos("YD_SISCEXP")) > 0
         SYD->(DBSETORDER(1))
         SYD->(DBSEEK(XFILIAL("SYD")+WORK->EE9_POSIPI))         

         // Completa com os dois ultimos digitos na geração da RE
         IF !Empty(SYD->YD_SISCEXP)
            cNcm := Left(Work->EE9_POSIPI,8)+SYD->YD_SISCEXP
         Endif
      Endif           

      // By OMJ - 09/12/2004 - Buscar o destaque do Embarque.
      If EE9->(FIELDPOS("EE9_DTQNCM")) > 0
         cNcm := Left(Work->EE9_POSIPI,8)+Work->EE9_DTQNCM                           
      Endif           
      
      // By OMJ - 25/02/2003 - 15:22 - Gravar no EE9 a descricao que foi para o RE.
      If lIntEDC
         DscEE9(EEC->EEC_PREEMB,Work->EE9_SEQSIS,Work->EE9_VM_DES)         
      EndIf   
      
      cBuffer := cBuffer+"T3"+IncSpace(cNcm,10,.F.) // Ncm
      cBuffer := cBuffer+IncSpace(Work->EE9_NALSH,8)       // Naldi/SH
      cBuffer := cBuffer+IncSpace(StrTran(Work->EE9_VM_DES,CRLF," "),675,.F.) // Descricao da Mercadoria
      IF SYD->(FIELDPOS("YD_CATTEX")) > 0
         SYD->(DBSETORDER(1))
         SYD->(DBSEEK(XFILIAL("SYD")+WORK->EE9_POSIPI))
         cBuffer := cBuffer+IncSpace(SYD->YD_CATTEX,4) // Categoria Textil      
      ELSE
         cBuffer := cBuffer+IncSpace("",4) // Categoria Textil
      ENDIF
      IF ( !EMPTY(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FABR+Work->EE9_FALOJA,"A2_EST")) )
         cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FABR+Work->EE9_FALOJA,"A2_EST"),2) // Estado Produtor
      ELSE 
         cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FORN+Work->EE9_FOLOJA,"A2_EST"),2) // Estado Produtor
      ENDIF
      
      cBuffer := cBuffer+IncSpace(Work->EE9_SEQSIS,6) // Nro. linha item no proc. emb.
      
      cBuffer := cBuffer+CRLF
      
      // Linha 06
      cBuffer := cBuffer+"T4"+IncSpace(Num(Work->EE9_PSLQTO,15,5),18) // Peso Lq. Unitario      
      cBuffer := cBuffer+IncSpace(Num(Work->EE9_SLDINI,15,5),18)   // Qtde Uni Comercial      
      cBuffer := cBuffer+IncSpace(ALLTRIM(Work->EE9_UNIDAD),20,.F.)        // Unidade de Comerc.
      
      /*
      Rotina de gravação da Qtde Uni. Mercadoria.
      Data e Hora : 06/02/2004 às 11:19
      Autor       : Alexsander Martins dos Santos
      Objetivo    : Gravação da Qtde Uni. Mercadoria quando a unidade de medida da NCM for diferente KG.
      */
      If Posicione("SYD", 1, xFilial("SYD")+Work->EE9_POSIPI, "YD_UNID") <> EasyGParam("MV_AVG0031",, "KG")
         cBuffer := cBuffer+IncSpace(Num(Work->WK_SLDINI, 15, 5), 18) // Qtde Uni Mercadoria
      Else
         cBuffer := cBuffer+Space(18) // Qtde Uni Mercadoria
      EndIf
      //Final da rotina.

      //cBuffer := cBuffer+IncSpace(Num(Work->EE9_PRCTOT,15,2),18)      // Preco Cond. Venda
      nTotCondVen := Work->EE9_PRCTOT
      If lSemCobCamb
         nTotCondVen += Work->EE9_VLSCOB
      EndIf
      cBuffer := cBuffer+IncSpace(Num(nTotCondVen,15,2),18)      // Preco Cond. Venda

      // Valor da condicao de venda ...
      nVlCalc:= Work->EE9_PRCTOT

      //Valor total sem cobertura cambial
      If lSemCobCamb
         nVlSemCob:= Work->EE9_VLSCOB   //TRP-03/03/2009
      Endif

      cBuffer := cBuffer+IncSpace(Num(Work->WK_PRCTOT+nVlSemCob,15,2),18)       // Preco Local de Embarque
      // by CAF 27/07/2001 Percentual comissao por item cBuffer := cBuffer+IncSpace(Num(EEC->EEC_VALCOM,5,2),5)         // Porcentual da Comissa Agente
      
      IF !Empty(Work->WK_PERCOM) .And. Empty(cRc)
         cBuffer := cBuffer+IncSpace(Num(Work->WK_PERCOM,5,2),5) // Porcentual da Comissa Agente
         IF (EEC->EEC_TIPCOM=="1")
            cFORMA:= "R"
         ELSEIF (EEC->EEC_TIPCOM=="2")
            cFORMA:= "G"
         ELSEIF (EEC->EEC_TIPCOM=="3")
            cFORMA:= "F"
         ELSE
            cFORMA:= ""
         ENDIF
      ELSE
         cBuffer := cBuffer+IncSpace("",5) // Porcentual da Comissa Agente
         cFORMA := ""
      ENDIF          
      
      cBuffer := cBuffer+IncSpace(cFORMA,1)           // Forma
      cBuffer := cBuffer+IncSpace(Work->EE9_FINALI,3) // Finalidade

      // By JPP - 02/08/2006 - 18:45 - Inclusão dos mesmos procedimentos utilizados na rotina de geração de RE, 
      //                               Para determinar se o exportador é o fabricante.
      If !(EEC->EEC_INTERM $ cSim) .And. !Empty(EEC->(EEC_EXPORT+EEC_EXLOJA))
         cExportForn := EEC->(EEC_EXPORT+EEC_EXLOJA)
      Else
         cExportForn := EEC->(EEC_FORN+EEC_FOLOJA)
      EndIf          

      // Exportador é o Fabricante ? // By JPP - 02/08/2006 - 18:45 
      //WFS 01/10/2009
      //Redundâcia para garantir que o campo EE9_FALOJA estará vazio.
      If Empty(Work->EE9_FABR)
         Work->EE9_FALOJA:= ""
      EndIf
      //IF Work->(EE9_FABR+EE9_FALOJA) == cExportForn nopado por WFS em 01/10/2009
      IF (Work->(EE9_FABR+EE9_FALOJA) == cExportForn .Or. Empty(Work->(EE9_FABR+EE9_FALOJA))) .And. Empty(Work->EE9_ATOCON)
         cExpFabr := "S"
      ELSE
         cExpFabr := "N"
      ENDIF
      
      cBuffer := cBuffer+IncSpace(cExpFabr,1) // Exportador eh fabricante 
      cBuffer := cBuffer+Work->WK_TEMOBS      // Observacao do Exportador
      cBuffer := cBuffer+CRLF
   
      // Linha 07
      // AMS - 01/07/2003 - Geração do T5 quando o Ato Concessório estiver preenchido.
      IF !Empty( Work->EE9_ATOCON ) .Or. cExpFabr == "N" //.or. !Empty( Work->EE9_ATOCON )
         cBuffer := cBuffer+"T5"
         
         For nCont:=1 To 10
             IF ! Empty(Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(nCont))))))
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(nCont))))),14,.f.) // CGC
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_NBM"+Ltrim(Str(nCont))))),10,.F.) // NCM
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_UF"+Ltrim(Str(nCont))))),2,.f.) // UF
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_ATO"+Ltrim(Str(nCont))))),13,.f.) // ATO CONCESSORIO
                cBuffer := cBuffer+IncSpace(Num(Work->(FieldGet(FieldPos("WK_QTD"+Ltrim(Str(nCont))))),15,3),16,.f.) // Qtde
                cBuffer := cBuffer+IncSpace(Num(Work->(FieldGet(FieldPos("WK_VAL"+Ltrim(Str(nCont))))),15,2),18,.f.) // Valor
             Else
                cBuffer := cBuffer+IncSpace("",14,.f.) // CGC
                cBuffer := cBuffer+IncSpace("",10,.F.) // NCM
                cBuffer := cBuffer+IncSpace("",2,.f.) // UF
                cBuffer := cBuffer+IncSpace("",13,.f.) // ATO CONCESSORIO
                cBuffer := cBuffer+IncSpace("",16,.f.) // Qtde
                cBuffer := cBuffer+IncSpace("",18,.f.) // Valor
             Endif
         Next nCont                  
         
         cBuffer := cBuffer+CRLF
      Endif
      
      // Linha 08                     
      If Work->WK_TEMOBS == "S"       
         cObs:=""
         For nX:=1 To 10            
             cObs:=cObs+Work->(FieldGet(FieldPos("WK_OBS"+AllTrim(Str(nX)))))
         Next
                  
         cBuffer := cBuffer+"T6"+cObs
         cBuffer := cBuffer+CRLF               
      Endif
   
      // Gravacao dos dados em no txt dos itens ...
      Fwrite(hItHandle,cBuffer,Len(cBuffer))
      
      cBuffer := "####eof#####"+ENTER
      fWrite(hItHandle,cBUFFER,Len(cBuffer))
      cBuffer := ""
      //fClose(hItHandle)
      
      // Posiciona o Usuario do Siscomex ...
      EEP->(dbSeek(xFilial()+cUser))
   
      // Posiciona o Processo de Exportacao a ser gerado ...
      EEC->(dbSeek(xFilial()+EEC->EEC_PREEMB))//EEC->EEC_PREEMB no lugar cProc
      // Alterado por Heder M Oliveira - 1/19/2000
      EEC->(RECLOCK("EEC",.F.))
      EEC->EEC_STASIS := SI_RS
      IF ( EMPTY(EEC->EEC_LIBSIS) )
         EEC->EEC_LIBSIS := dDATABASE    
      ENDIF
   
      EER->(RecLock("EER",.T.))
      EER->EER_FILIAL := xFilial("EER")
      EER->EER_CNPJ   := EEP->EEP_CNPJ
      EER->EER_PREEMB := EEC->EEC_PREEMB
      EER->EER_IDTXT  := cFile
      EER->EER_DTLIBS := EEC->EEC_LIBSIS
      EER->EER_DTGERS := dDataBase
      EER->EER_STASIS := SI_RS
      EER->(MsUnlock())
   
      // ** Gravacao da capa do txt ...
   
      // Verificar se gera o novo layout com as informacoes:
      // 1-CGC Representante e 2-CGC Representado   
      IF EasyGParam("MV_AVG0036",.T.) // Verifica se o parametro existe 
         IF ! Empty(EEC->EEC_EXPORT) .And. !Empty(Posicione("SA2",1,xFilial("SA2")+EEC->EEC_EXPORT+EEC->EEC_EXLOJA,"A2_CGC"))
            cKSA2 := IdCnpj (EEC->EEC_EXPORT,EEC->EEC_EXLOJA)
         Else
            cKSA2 := IdCnpj(EEC->EEC_FORN,EEC->EEC_FOLOJA)
         Endif  

         cBuffer := cBuffer+"ID"       
         cBuffer := cBuffer+cKSA2
         cBuffer := cBuffer+IncSpace(If(EasyGParam("MV_AVG0036",,"")=".", " ", EasyGParam("MV_AVG0036",,"")),14,.F.)
         cBuffer := cBuffer+CRLF
         //cBuffer := cBuffer+"RE"+EE9->EE9_RE+CRLF //msv 
         cBuffer := cBuffer+"RE"+cRE+CRLF //msv
      Endif
   
      // Linha 01
      cBuffer := cBuffer+"NP"+IncSpace(EEC->EEC_PREEMB,20)+CRLF // Proc.Exp.
   
      // Linha 02
      cBuffer := cBuffer+"SE"+IncSpace(EEP->EEP_CNPJ,11)   // Codigo
      cBuffer := cBuffer+IncSpace("",12)                   // Senha 
      cBuffer := cBuffer+IncSpace("",12)                   // Nova Senha
      cBuffer := cBuffer+IncSpace(EEP->EEP_SISTEM,62)+CRLF // Sistema
   
      // Linha 03
      cBuffer := cBuffer+"T1" 
 
      //cEnquadra:= EEC->EEC_ENQCOD+EEC->EEC_ENQCO1+EEC->EEC_ENQCO2+EEC->EEC_ENQCO3+EEC->EEC_ENQCO4+EEC->EEC_ENQCO5 
      
      cEnquadra := EEC->EEC_ENQCOD

      If !Empty(Work->EE9_ATOCON)
         If lIntEDC // ** Verifica se esta integrado ao EDC ...
            ED0->(DbSetOrder(2))
            If ED0->(DbSeek(xFilial("ED0")+Work->EE9_ATOCON))
               cEnquadra := ED0->ED0_ENQCOD
            EndIf   
         Else
            If EEC->(FIELDPOS("EEC_ENQCOX")) # 0
               cEnquadra := EEC->EEC_ENQCOX
            Else
               cEnquadra := AvKey("81101","EEC_ENQCOD")
            EndIf                     
         EndIf
      EndIf

      cEnquadra:=cEnquadra + EEC->EEC_ENQCO1+EEC->EEC_ENQCO2+EEC->EEC_ENQCO3+EEC->EEC_ENQCO4+EEC->EEC_ENQCO5 
      
      cPais:=""
      cPais:= Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_PAIS") 
      cPais:= Posicione("SYA",1,xFilial("SYA")+cPais,"YA_SISEXP")
   
      cBuffer := cBuffer+IncSpace(cEnquadra,30)
      cBuffer := cBuffer+IncSpace(SIData(EEC->EEC_LIMOPE),8) // Data Limite
      cBuffer := cBuffer+IncSpace(IF(lP_RC,LEFT(cRc,12),EEC->EEC_OPCRED),12) // Num do RC   
      // cBuffer := cBuffer+IncSpace(IF(lP_RC,LEFT(WORK->EE9_RC,12),EEC->EEC_OPCRED),12) // Num do RC
      cBuffer := cBuffer+PADL(Transf(EEC->EEC_MRGNSC,"99.99"),5)  // Margem nao sacada
      cBuffer := cBuffer+IncSpace(EEC->EEC_GEDERE,13) // GE/DE/RE/Vinculado
      cBuffer := cBuffer+IncSpace(EEC->EEC_GDRPRO,15) // Num. Processo
      cBuffer := cBuffer+IncSpace(EEC->EEC_DIRIVN,15) // DI/RI/Vinculado
      cBuffer := cBuffer+IncSpace(EEC->EEC_URFDSP,7) // Unidade RF Despacho
      cBuffer := cBuffer+IncSpace(EEC->EEC_URFENT,7) // Unidade RF Embarque
      cBuffer := cBuffer+IncSpace(EEC->EEC_IMPODE,55) // Nome do Importador
      cBuffer := cBuffer+IncSpace(AllTrim(EEC->EEC_ENDIMP)+" - "+AllTrim(EEC->EEC_END2IM),55,.F.) // End. Import.   
      cBuffer := cBuffer+IncSpace(cPais,4)//Pais do importador  
   
      cBuffer := cBuffer+CRLF

      // Linha 04   
      cPaisDet := ""
      cPaisDet := POSICIONE("SYA",1,XFILIAL("SYA")+EEC->EEC_PAISDT,"YA_SISEXP")
      
      cBuffer := cBuffer+"T2"+IncSpace(cPaisDet,4)  // Pais Destino 
      cBuffer := cBuffer+IncSpace(ALLTRIM(EEC->EEC_INSCOD),5)											  // Instr.Negociacao
      cBuffer := cBuffer+IncSpace(EEC->EEC_INCOTE,3)													  // Cod.Cond.Venda
      cBuffer := cBuffer+IncSpace(EEC->EEC_MPGEXP,3) 													  // Mod.Transacao
      cBuffer := cBuffer+IncSpace(POSICIONE("SYF",1,XFILIAL("SYF")+EEC->EEC_MOEDA,"YF_COD_GI"),3) 	      // Moeda

      // ** Utiliza sempre o valor calculado...
      nTotPed := nVlCalc

      // ** By JBJ - 14/08/03 - 11:50. (Tratamentos para Valor Total RE).
      nVlAux := nVlCalc-nFinCia
      If EEC->EEC_VLCONS <> 0 // Valor Consignado.
         nVlCons := nVlAux
      Else   
         IF EEC->EEC_COBCAM $ cSim .And. EEC->EEC_MPGEXP <> "006" // S.Cobertura Cambial    
            SY6->(DbSetOrder(1))
            If SY6->(DbSeek(xFilial("SY6")+EEC->(EEC_CONDPA+Str(EEC_DIASPA,3,0))))
               Do Case
                  Case SY6->Y6_TIPO = "1" // Tipo 'Normal'.
                     nParcel := nVlAux // Valor da parcela

                  Case SY6->Y6_TIPO = "2" // Tipo 'A vista'.
                     nAvista := nVlAux // Valor a vista.

                  Case SY6->Y6_TIPO = "3" // Tipo 'Parcelado'.
                     For z:=1 To 10
                        nPerc := SY6->&("Y6_PERC_"+StrZero(z,2))
                        nDias := SY6->&("Y6_DIAS_"+StrZero(z,2))

                        If nPerc > 0
                           If nDias = 0 // A vista.
                              nAvista += Round((nVlAux*(nPerc/100)),2) // Valor a vista.
                           ElseIf nDias > 0 // Parcelado.
                              nParcel += Round((nVlAux*(nPerc/100)),2) // Valor da parcela.
                           Else // Antecipado. 
                              nAnteci += Round((nVlAux*(nPerc/100)),2) // Valor antecipado.
                           EndIf
                        EndIf
                     Next

                     // ** Faz a verificação para possíveis resíduos.
                     nSoma := (nAvista+nParcel+nAnteci)
                     If nSoma <> nVlAux
                        If nParcel > 0
                           nParcel += Round((nVlAux-nSoma),2)
                        ElseIf nAvista > 0
                           nAvista += Round((nVlAux-nSoma),2)
                        Else
                           nAnteci += Round((nVlAux-nSoma),2)
                        EndIf
                     EndIf
               EndCase
            EndIf
         EndIf           
      Endif

      cBuffer := cBuffer+IncSpace(IF(lP_RC,"",Num(nAnteci,15,2)),18)  // Vlr.Pagto Antecipado
      cBuffer := cBuffer+IncSpace(IF(lP_RC,"",Num(nAvista ,15,2)),18) // Vlr.Pagto Vista

      // ** Calcular o nro de parcelas e a periodicidade.   
      IF !Empty(nParcel)

         nNroParc := 1

         For z:=1 To 10

            nPerc := SY6->&("Y6_PERC_"+StrZero(z,2))
            nDias := SY6->&("Y6_DIAS_"+StrZero(z,2))

            If nPerc > 0 .And. nDias > 0

                /*
               AMS - 28/05/2004 às 10:50. Substituido a rotina original para armazenar a maior periodicidade.
               If nPeriodo = 0
                  nPeriodo := nDias
               EndIf  
               */

               //nNroParc ++
               nPeriodo := nDias

            EndIf

         Next

      Endif
   
      // Nro. de Parcelas
      IF lP_RC .OR. Empty(nParcel)
         cBUFFER := cBUFFER+IncSpace("",03)   // Nro.de Parc.
      ELSE
         If EEC->EEC_DIASPA <> 901
            cBuffer := cBuffer+IncSpace(Num(EEC->EEC_NPARC,03),03)  // Nro.de Parc.
         Else
            cBuffer := cBuffer+IncSpace(Num(nNroParc,03),03)  // Nro.de Parc.
         EndIf
      ENDIF

      // Periodicidade
      IF !Empty(nParcel) .And. !lP_RC
         cPeriod := AllTrim(GetNewPar("MV_AVG0011","-1"))

         IF EEC->(FieldPos("EEC_PERIOD")) > 0
            cPeriod := AllTrim(EEC->EEC_PERIOD)
         Endif
      Endif

      IF ! Empty(cPeriod) .And. cPeriod <> "-1" 
         cBuffer := cBuffer+IncSpace(cPeriod,3) // Periodicidade
      Else
         IF lP_RC .OR. Empty(nParcel)
            cBUFFER := cBUFFER+INCSPACE("",3)   // PERIODICIDADE
         Else
            If EEC->EEC_DIASPA <> 901
               cBuffer := cBuffer+IncSpace(Num(EEC->EEC_DIASPA,3),3) // Periodicidade
            Else
               cBuffer := cBuffer+IncSpace(Num(nPeriodo,3),3) // Periodicidade
            EndIf
         ENDIF
      Endif

      IF lP_RC .OR. Empty(nParcel)
         cBuffer := cBuffer+" "    // Indicador
      ELSE
         cBuffer := cBuffer+"D"    // Indicador
      ENDIF

      // VALOR DA PARCELA DEPENDENDO DAS OPCOES
      IF lP_RC .OR. Empty(nParcel)
         cBuffer := cBuffer+IncSpace("",18) // Valor da Parcela
      ELSE
         cBuffer := cBuffer+IncSpace(Num(nParcel,15,2),18) // Valor da Parcela
      ENDIF

      cBuffer := cBuffer+IncSpace(IF(lP_RC,"",Num(nVlCons,15,2)),18)   // Vlr.em Consignacao
      //cBuffer := cBuffer+IncSpace(IF(lP_RC,"",Num(IF(EEC->EEC_COBCAM $ cNao,nTotPed,0),15,2)),18) // Valor s/ Cobertura Cambial
      cBuffer := cBuffer+IncSpace(IF(lP_RC,"",Num(IF(EEC->EEC_COBCAM $ cNao,nTotPed,If (nVlSemCob>0,nVlSemCob,nSemCobCamb)),15,2)),18) // Valor s/ Cobertura Cambial
      cBuffer := cBuffer+IncSpace(Num(nFincia,15,2),18) // Vlr. Financiamento RC
      
      cBuffer := cBuffer+CRLF
   
      // Gravacao dos dados no Disco ...
      fWrite(hFile,cBuffer,Len(cBuffer))
      cBuffer := ""
  
      nSize:=fSeek(hItHandle,0,2)
      fSeek(hItHandle,0,0)   
   
      DO WHILE nLidos <= nSize
         nLidos := nLidos+BLOCK_READ
         FREAD(hItHandle,@cBuffer,BLOCK_READ)

         FWRITE(hFile,cBuffer,Len(cBuffer))
      EndDo

      fClose(hItHandle)   
      fErase(cDir+cFileItem)
   
      fClose(hFile)
        
      EEC->(MSUNLOCK())                
//WFS 29/05/2009 ---
      cFiles += cFile + ENTER
      nLidos:= 0
   EndIf
   Work->(DBSkip())         
EndDo
//---         
End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : SelUser
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Selecao do Usuario
Autor       : Michelle da Silva Velos
Data/Hora   : 30/08/2005 17:17
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/
Static Function SelUser()
Local cUser := "", oDlg, nOpcA := 0
Local aOrd := SaveOrd("EEP",1)
Local aCpos := ArrayBrowse("EEP")
Local cFiltro := "EEP->EEP_FILIAL == '"+xFilial("EEP")+"'"
Local nAreaOld := Select()

Local oBrw

Begin Sequence
   
   EEP->(dbSeek(xFilial()))

   dbSelectArea("EEP")
   SET FILTER TO &cFiltro
 
   DEFINE MSDIALOG oDlg TITLE STR0012 FROM 9,0 TO 25,50 OF oMainWnd //"Seleção de Usuário"
      
      oBrw := MsSelect():New("EEP",,,aCpos,.f.,@cMarca,{3,2,105,178})
      oBrw:bAval := {|| nOpcA := 1 }
      
      DEFINE SBUTTON FROM 107,110 TYPE 1 OF oDlg ACTION (nOpcA:=1,oDlg:End()) ENABLE
      DEFINE SBUTTON FROM 107,143 TYPE 2 OF oDlg ACTION (oDlg:End()) ENABLE
      
   ACTIVATE MSDIALOG oDlg CENTERED
   
   IF nOpcA == 1
      cUser := EEP->EEP_CNPJ
   Endif
   
End Sequence

dbSelectArea("EEP")
SET FILTER TO 

RestOrd(aOrd)
Select(nAreaOld)

Return cUser  


/*
Funcao      : IsMark
Parametros  : cWork: passar a Work
              cFlag: passar o campo de Flag
Retorno     : NIL
Objetivos   : Verificar se tem algo selecionado
Autor       : Michelle da Silva Velos
Data/Hora   : 30/08/2005 17:17
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/
Static Function IsMark(cWork, cFlag)   
Local lRet := .F.     

Begin Sequence

   (cWork)->(Eval({|x| dbGoTop(),;
                       dbEval({|| lRet := .T.}, {|| !Empty(&(cFlag))}, {|| lRet = .F.}),;
                       dbGoTo(x)}, Recno()))

End Sequence

Return(lRet) 

/*
Funcao      : DscEE9
Parametros  : cPreemb = Cod. do Embarque
              cSeqSis = Seq. do Siscomex
              cDescRE = Descrição da RE
Retorno     : Nil
Objetivos   : Grava no EE9 a descricao q foi para o RE.
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/2005 15:25 
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        : A descricao será gravada para os itens que tem o 
              mesmo agrupamento, mesmo nr. de EE9_SEQSIS
*/
Static Function DscEE9(cPreemb,cSeqSis,cDescRE)
Local nAliasOld := Select()
Local aOrd := SaveOrd({"EE9"})
Local cFilEE9 := xFilial("EE9")

dbSelectArea("EE9")

EE9->(dbSetOrder(9)) 

EE9->(dbSeek(cFilEE9 + cPreemb + cSeqSis ))
Do While !EE9->(Eof()) .And.;
         EE9->EE9_FILIAL = cFilEE9 .And.;
         EE9->EE9_PREEMB = cPreemb .And.;
         EE9->EE9_SEQSIS = cSeqSis               
   
   EE9->(RecLock("EE9",.F.))

   If !Empty(EE9->EE9_DESCRE)
      MSMM(EE9->EE9_DESCRE,,,,EXCMEMO)
   Endif
                              
   MSMM(,AVSX3("EE9_VM_DRE",AV_TAMANHO),,cDescRE,INCMEMO,,,"EE9","EE9_DESCRE")
   
   EE9->(MsUnlock())

   EE9->(dbSkip())
   
EndDo         

RestOrd(aOrd)

dbSelectArea(nAliasOld)

Return Nil  

/*
Funcao      : Num
Parametros  : nValor := Valor Numerico
              nInt   := Numero de Inteiros
              nDec   := Numero de Decimais
Retorno     : cNum
Objetivos   : Converter um valor numerico em string
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/2005 09:24
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/ 
Static Function Num (nValor,nInt,nDec)
Local cNum := ""

Default nInt := 10, nDec := 0

Begin Sequence
   cNum := Str(nValor,nInt,nDec)
End Sequence

Return cNum 

/*
Funcao      : Data
Parametros  : dData := Data a ser convertida
Retorno     : cData 
Objetivos   : Converter uma data em string
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/2005 11:34
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/
Static Function SIData(dData)
Local cDat := Space(8)

Begin Sequence
   IF !Empty(dData)
      cDat := Padl(Day(dData),2,"0")+Padl(Month(dData),2,"0")+Str(Year(dData),4)
   Endif
End Sequence

Return cDat


/*
Funcao      : SI102CanRE
Parametros  : 
Retorno     : Nil
Objetivos   : Cancelamento de RE
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/2005 11:34
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/                   
Function SI102CanRE()   
Local aCampos:= {},aSEMX3:={},aHEADER:={}
Local cTempFile:="", cUser:="",cFiles:=""
Local oMark 
Local lRet    := .f.
Local X,nSeq  :=0
Local nOpc    := 0
Local bOk     := {|| If(IsMark("Work", "WK_FLAG"),(nOpc := 1,oDlg:End()),HELP(" ",1,"AVG0005067") ) }  
Local bCancel := {|| nOpc := 0, oDlg:End()}
Local cDir    := EasyGParam("MV_AVG0002") // Diretorio para geracao dos arquivos
Private lInverte := .f., cMarca := GetMark()     

aCampos := Array(EE9->(fCount())) 
aSEMSX3 := CRIAESTRU(aCAMPOS,@aHEADER,"EE9")
X := ASCAN(aSEMSX3,{|X| X[1] = "EE9_UNIDAD"})
IF X <> 0
   aSEMSX3[X,3] := 20  
ENDIF


x := aScan(aSemSX3,{|x| x[1] = "EE9_SLDINI"})
IF x > 0
   aSemSX3[X,3] := 18
   aSemSX3[x,4] := 5
Endif

AADD(aSEMSX3,{"WK_FLAG"   ,"C",02,2})
AADD(aSEMSX3,{"WK_PRCTOT" ,"N",15,2}) ; AADD(aSEMSX3,{"WK_SLDINI"   ,"N",18,5})
AADD(aSEMSX3,{"WK_CGC1"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC2"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM1"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM2"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF1"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF2"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO1"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO2"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD1"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD2"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL1"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL2"     ,"N",15,2})
AADD(aSEMSX3,{"WK_CGC3"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC4"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM3"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM4"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF3"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF4"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO3"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO4"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD3"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD4"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL3"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL4"     ,"N",15,2})
AADD(aSEMSX3,{"WK_CGC5"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC6"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM5"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM6"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF5"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF6"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO5"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO6"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD5"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD6"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL5"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL6"     ,"N",15,2})
AADD(aSEMSX3,{"WK_CGC7"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC8"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM7"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM8"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF7"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF8"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO7"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO8"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD7"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD8"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL7"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL8"     ,"N",15,2})
AADD(aSEMSX3,{"WK_CGC9"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC10"    ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM9"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM10" ,"C",10,0})
AADD(aSEMSX3,{"WK_UF9"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF10"     ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO9"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO10"    ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD9"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD10"    ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL9"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL10"    ,"N",15,2})
AADD(aSEMSX3,{"WK_PERCOM" ,"N",6,2})  // by CAF 27/07/2001 Percentual comissao por item
AADD(aSEMSX3,{"WK_RE"     ,"C",12,0})  
AADD(aSEMSX3,{"WK_TEMOBS" ,"C",01,0}) ; AADD(aSEMSX3,{"WK_OBS1"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS2"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS3"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS4"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS5"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS6"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS7"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS8"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS9"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS10"  ,"C",75,0}) ; AADD(aSEMSX3,{"WK_ENQCOD" ,"C",AvSX3("EEC_ENQCOD",AV_TAMANHO),0})

cTempFile := E_CriaTrab(,aSemSx3,"Work") 

//MFR 18/12/2018 OSSME-1974
IndRegua("Work",cTempFile+TeOrdBagExt(),"WK_RE") //cria o indice (IndRegua)

Begin Sequence                                
                 
   
   lRet := WorkCancel()        

   If !lRet  // retorno se não escolhei nem um processo
      Break
   EndIf                                                                                
   
   
   aTb_Campos := {{"WK_FLAG"   ,," "},;  
                 {"EE9_PEDIDO",,AvSx3("EE9_PEDIDO",AV_TITULO) },;
                 {"EE9_RE"    ,,AvSx3("EE9_RE"    ,AV_TITULO) },;
                 {"EE9_DTRE"  ,,AvSx3("EE9_DTRE"  ,AV_TITULO) }} 

   Work->(dbGoTop())
  
   DEFINE MSDIALOG oDlg TITLE STR0014 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL // "Cancelamento de RE"

      aPos    := PosDlg(oDlg)
      aPos[1] := 15 

      oMark := MsSelect():New("Work","WK_FLAG",,aTb_Campos,@lInverte,@cMarca,aPos) 

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel)   
   
   Do Case
      Case nOpc = 0
         Break      
      Case nOpc = 1
      
         //Seleciona o Usuario
         cUser := SelUser()

         If Empty(cUser)
            Break
         EndIf 
         
         cFile := ""        
            
         Work->(dbGoTop())
         While !Work->(Eof())
            If !Empty(Work->WK_FLAG)
     		   nSeq  := EasyGParam("MV_AVG0001") // Proxima seq.de arq. a ser gerado para o Siscomex
               SetMv("MV_AVG0001",nSeq+1)
               cFile := "CE"+Padl(nSeq,6,"0")+".inc"               
               CriaTxtCanc(Work->EE9_RE,cUser,cDir,cFile)//michelle
               cFiles += cFile+CRLF

            EndIf
            Work->(dbSkip())         
         EndDo
 
         If ( Empty(cFILES) )
            Break
         Endif
     
         cFILES += "####eof#####"+CRLF

         If File(cDir+"EECTOT.AVG")
            fErase(cDir+"EECTOT.AVG")
         Endif

         hFile := EasyCreateFile(cDir+"EECTOT.AVG") 
         fWrite(hFile,cFiles,Len(cFiles))
         fClose(hFile)

         MsgInfo(STR0003,STR0001) //"Arquivos gerados com sucesso !" ## "Aviso"

   End Case
   
End Sequence 

If Select("Work") > 0
   Work->(E_EraseArq(cTempFile))
EndIf

Return Nil 

/*
Funcao      : WorkCancel
Parametros  : 
Retorno     : Nil
Objetivos   : Cancelamento de RE
Autor       : Michelle da Silva Veloso
Data/Hora   : 30/08/2005 11:34
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
Revisao     :
Obs.        :
*/
Static Function WorkCancel()   
Local oDlg  
Local bOk     := {|| nOp := 1, oDlg:End() } 
Local bCancel := {|| nOp := 0, oDlg:End() } 
Local cPreemb := Space(Len(EEC->EEC_PREEMB)) 
Local cRE := ""
Local x
Local nOp:=0 
Local lRet:= .f.
Local aEE9:={}

Define MsDialog oDlg Title STR0016 ; // "Escolha o Processo para Cancelamento"
          From 1,1 To 150,390 Of oMainWnd Pixel 
                  
      @  22,07 SAY STR0006 Pixel // "Escolha o processo"
      @  20,60 MsGet cPreemb F3 "EEC" Valid ExistCpo("EEC",cPreemb) SIZE 80,8 PIXEL
     
Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   If nOp = 0 
      Break
   EndIf
   
   ProcRegua(EE9->(LastRec()))   
   
   Work->(avzap())   
                          
   aEE9 := {}
   
   EEC->(dbSetOrder(1))
   EE9->(dbSetOrder(3))
  
   EE9->(dbSeek(xFilial("EE9")+cPreemb))

   While !EE9->(Eof()) .And.;
          EE9->EE9_FILIAL == xFilial("EE9") .And.;
          EE9->EE9_PREEMB == cPreemb

      IncProc( STR0007 + Trans(EE9->EE9_SEQEMB,AVSX3("EE9_SEQEMB",AV_PICTURE)) ) // "Processando..."

      If !Empty(EE9->EE9_RE) .And. !Work->(DbSeek(EE9->EE9_RE ))
        work->(DbAppend())
        Work->EE9_RE     := EE9->EE9_RE 
        Work->EE9_PEDIDO := EE9->EE9_PEDIDO
        Work->EE9_DTRE   := EE9->EE9_DTRE        
        lRet := .T. 
      EndIf      
      EE9->(dbSkip())
   EndDo  
     
Return lRet

/*
Função      : CriaTxtCanc
Objetivo    : Cria o txt para efetuar o cancelamento de RE.
Parametros  : EE9_RE  : Número da Re a ser cancelada
              cUser   : usuario que está cancelando
              cDir    : diretório para armazenar o arquivo criado
              cFile   : sequencia do número do arquivo  
Retorno     : Nil 
Autor       : Michelle da Silva Veloso
Data e Hora : 25/08/2005 às 17:46.
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
*/
Static Function CriaTxtCanc(EE9_RE,cUser,cDir,cFile)
Local hFileCan,cFileItem,cBuffer

Begin Sequence
   // Cria o Arquivo ...
   hFileCan := EasyCreateFile(cDir+cFile)
   EEC->(dbSetOrder(1))
   EEC->(dbSeek(xFilial()+EEC->EEC_PREEMB))
   
   IF ! (hFileCan > 0)
      MsgStop(STR0011+cDir+cFile,STR0001) //"Erro na criação do arquivo: "###"Aviso"
      Break
   Endif
   
   cFileItem := AllTrim(CriaTrab(,.F.))+".TXT"
  
   If !(hFileCan>0)
      MsgStop(STR0011+cDir+cFileItem,STR0001) //"Erro na criação do arquivo: "###"Aviso"
      Break   
   EndIf

   cBuffer:=""
   
   cBuffer := cBuffer+"RE"+IncSpace(EE9_RE, 12)+CRLF
   cBuffer += "NP"+IncSpace(EEC->EEC_PREEMB,20)+cUser+CRLF // Proc.Exp.
   cBuffer += "####eof#####"+ENTER
   
   // Gravacao dos dados em no txt dos itens ...
   Fwrite(hFileCan,cBuffer,Len(cBuffer)) 
   
   fClose(hFileCan)

End Sequence

Return Nil

/*
Função      : SI102RetCanRe()
Objetivo    : Retorno do cancelamento de RE.
Retorno     : Nil
Autor       : Michelle da Silva Veloso
Data e Hora : 25/08/2005 às 17:46.
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
*/ 
Function SI102RetCanRe()
Local aFile:={}
Local cDir := EasyGParam("MV_AVG0002"), hFile:="" , cBuffer:="",cProc:="",cRE:="", cMsg:="",cLine:="",nSize,cAux:="" 
Local cPathDT := "C:\EEC-Sisc\OriSisc\hissisc\" , cNomeArq:=""
Local x , nLidos
Local nRead
Local lEECView := .F.
Local nBytes  := BLOCK_READ

Begin Sequence  

     aFile := DIRECTORY(cDir+"ce*.ok")

     If Len(aFile) <> 0
        aFile := ASort(aFile,,,{|X,Y| X[1] < Y[1]})
     Else
        MsgStop(STR0017,STR0002) // "Arquivo de retorno não encontrado" ## "Atenção"
     EndIf 
     
     For x := 1 TO Len(aFile)

	    hFile:= EasyOpenFile(cDir+aFile[x,1],FO_READ+FO_EXCLUSIVE)	   
        nSize:= fSeek(hFile, 0,0)  //posicionando na primeira linha
        cNomeArq:= SubStr(aFile[x,1],3,6)
        
        If fError() <> 0
           MsgStop(STR0018 + Ltrim(Str(fError())), STR0002)  // "Erro ao abrir o arquivo(DOS)" ## "Atenção" 
           Break
        EndIf  
        
        cLine := Space(nBytes)
        fRead(hFile,@cLine,nBytes)
        
        cProc:= SubStr(cLine, 01, 20) 
        cRE  := SubStr(cLine, 27, 14)
        
        cMsg += STR0019 + Replicate(ENTER, 2) //"Retorno do cancelamento da RE"

        cMsg += STR0020 + cProc                 + ENTER +;            //"Processo : "
                STR0021 + cRE                   + ENTER +;            //"Nº. DSE  : "
                STR0022 + SubStr(cLine, 43,  8) + ENTER +;            //"Data     : "
                STR0023 + SubStr(cLine, 51,  5) + Replicate(ENTER, 3) //"Hora     : "
                
        cMsg += STR0024 + ENTER +; // "Para confirmar o cancelamento da RE, escolha o botão Ok, caso contrário" 
                STR0025 // "Cancele."              
        
        lEECView := EECView(cMsg, STR0014) // "Cancelamento de RE"  
        
        If lEECView
                
           FClose(hFile)
           
           EE9->(dbSetOrder(3))        
           EE9->(dbSeek(xFilial("EE9")+cProc)) 
           
           cRE:= StrTran(Substr(cLine,27,14),"/","") 
           cRE:= StrTran(Substr(cRE,01,13),"-","")
           
           If  EE9->EE9_RE <> cRE
              MsgInfo(STR0026,STR0002)  // "Número de RE não confere." ## "Atenção"
           Else
                      
              RecLock("EE9",.F.) //Travar a tabela EE9
            
              EE9->EE9_RE:= "" //apagar o número da RE.
              EE9->EE9_DTRE := Ctod("  /  /  ")  // By JPP - 17/12/2008 - 17:38
              MsUnlock() //Destravar a Tabela
           
              //Move o arquivo inc para a pasta HISSISC e deleta o inc e ok da pasta Orisisc.
              Copy File(cDir+"ce"+cNomeArq+".inc") to (cPathDT+"ce"+cNomeArq+".inc") 
              fErase(cDir+"ce"+cNomeArq+".inc")//Deleta o arquivo inc da pasta Orisisc 
              fErase(cDir+"ce"+cNomeArq+".ok") //Deleta o arquivo ok da pasta Orisisc                                 
           
      
              MsgInfo(STR0027,STR0002) // "Cancelamento de RE concluído com sucesso." ## "Atenção" 
           
           EndIf 
	    Endif
	 Next 
     
 End Sequence
    
Return(Nil) 

/*
Função      : IdCnpj(cCodigo, cLoja)
Objetivo    : Retornar o CNPJ do Exportador.
Retorno     : Nil
Autor       : Michelle da Silva Veloso
Data e Hora : 25/08/2005 às 17:46.
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
*/
Static Function IdCnpj(cCodigo, cLoja)
*-------------------------------------*

Local cRet := ""
Begin Sequence 

   If !Empty(EEC->EEC_EXPORT)
      cRet := BuscaExport(cCodigo, cLoja, "A2_CGC")
   EndIf
End Sequence

Return(cRet) 

/*
Função      : BuscaExport(cCodigo, cLoja, cCampo)
Objetivo    : Buscar na tabela de Fornecedore/Exportadores e Retornar o CNPJ do Exportador.
Retorno     : Nil
Autor       : Michelle da Silva Veloso
Data e Hora : 25/08/2005 às 17:46.
Alteração   : Julio de Paula Paz - 17/12/2008 - 17:00 - Transformação da customização em rotina padrão.
*/
Static Function BuscaExport(cCodigo, cLoja, cCampo)
Local xRet
Local aSaveOrd := SaveOrd("SA2", 1)

Begin Sequence

   SA2->(dbSeek(xFilial()+cCodigo+cLoja),;
         xRet := &(cCampo))

End Sequence

RestOrd(aSaveOrd, .T.)

Return(xRet)


/*
Funcao      : SI102SelItem(cRE, cRC, cArqInc, cUser, nAgrupa)
Parametros  : cArqInc, cArqAvg, cUser: usados pela função de geração do arquivo txt
Retorno     : 
Objetivos   : Seleção dos itens do processo que serão alterados no Siscomex
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 29/05/2009
Alteração   : WFS em 24/06/2009 - inclusão de tratamentos para Wizard
*/
Function SI102SelItem(cArqInc, cArqAvg, cUser)
Local cTitulo:= " - " +  STR0020 + EEC->EEC_PREEMB
Local aCampos:= {}, aPos
Local oDlg, oMark
Local bOk:= {|| If(IsMark("Work", "WK_FLAG"), (SI102CriaTxt(@cArqInc, @cArqAvg, cUser),;
                lRet:= .T., oDlg:End()), Help("", 1, "AVG0005067"))} //MsgInfo("Não há registros marcados para a geração de arquivos!", "Aviso")
Local bCancel:= {|| lRet:= .F., oDlg:End()}
Local bVoltar:= {|| oDlg:End(), Work->(DBCloseArea()), WizardREUser()}
Local lRet:= .F.

If !lWizardRe
   Private lInverte:= .F.,;
           cMarca:= GetMark()
EndIf

   //Campos que serão exibidos na tela, para escolha dos itens
   AAdd(aCampos, {"WK_FLAG", , " "})
   AAdd(aCampos, {"EE9_PREEMB", , AvSx3("EE9_PREEMB", AV_TITULO), AvSX3("EE9_PREEMB", AV_PICTURE)})
   AAdd(aCampos, {"EE9_RE"    , , AvSx3("EE9_RE"    , AV_TITULO), AvSX3("EE9_RE"    , AV_PICTURE)})
   AAdd(aCampos, {"EE9_DTRE"  , , AvSx3("EE9_DTRE"  , AV_TITULO), AvSX3("EE9_DTRE"  , AV_PICTURE)})
   AAdd(aCampos, {"EE9_POSIPI", , AvSx3("EE9_POSIPI", AV_TITULO), AvSX3("EE9_POSIPI", AV_PICTURE)})
   AAdd(aCampos, {"EE9_VM_DES", , AvSx3("EE9_VM_DES", AV_TITULO), AvSX3("EE9_VM_DES", AV_PICTURE)})
   AAdd(aCampos, {"EE9_SLDINI", , STR0028                       , AvSX3("EE9_SLDINI", AV_PICTURE)})
   AAdd(aCampos, {"EE9_SLDINI", , STR0029                       , AvSX3("EE9_SLDINI", AV_PICTURE)})
   AAdd(aCampos, {"EE9_PRCTOT", , STR0030                       , EECPreco("EE9_PRCTOT", AV_PICTURE)})
   AAdd(aCampos, {"EE9_PRCTOT", , STR0031                       , EECPreco("EE9_PRCTOT", AV_PICTURE)})                

   Work->(DBGoTop())

   If lWizardRe
      Define MSDialog oDlg Title STR0013 + cTitulo From 0, 0 To 562, 455 Of oMainWnd Pixel //"Alteração de RE" + "Processo: "

      @ 010, 08 Say STR0032 Pixel Font oBold //"Escolha de R.E."
      @ 030, 08 Say STR0033 Pixel //"Selecione o R.E. para alteração:"

      @ 045, 08 To 210, 221 Label STR0034 Pixel //"Agrupamentos"

      aPos:= {52, 11, 206, 217}

      oMark:= MsSelect():New("Work", "WK_FLAG", , aCampos, @lInverte, @cMarca, aPos)

      @ 219, 08 Say STR0035 Pixel //Para abortar, clique no botão 'Cancelar'.
      @ 229, 08 Say STR0036 Pixel //Para retornar à seleção de usuário, clique no botão 'Voltar'.
      @ 239, 08 Say STR0037 Pixel //Para prosseguir, clique no botão 'Avançar'.

      Define SButton oBtAvancar  From 260, 191 Type 19 Action Eval(bOk) Enable Of oDlg
      Define SButton oBtVoltar   From 260, 160 Type 20 Action Eval(bVoltar) Enable Of oDlg
      Define SButton oBtCancelar From 260, 129 Type 02 Action Eval(bCancel) Enable Of oDlg
         
      Activate MSDialog oDlg Centered   
   Else
      Define MsDialog oDlg Title STR0013 + cTitulo;
         From DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Alteração de RE" + "Processo: "

         aPos:= PosDlg(oDlg)
         aPos[1]:= 15

         oMark:= MsSelect():New("Work", "WK_FLAG", , aCampos, @lInverte, @cMarca, aPos) 

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel)
   EndIf

Return lRet
