#INCLUDE "EECAT130.ch"
/*
Programa        : EECAT130.PRW
Objetivo        : Manutencao em condicoes de pagto
Autor           : Heder M Oliveira
Data/Hora       : 25/11/98 09:29
Obs.            : OS 0467/98 OC 1407/98
                    COLOCAR VALIDACOES
*/
#include "EEC.CH"

#COMMAND E_RESET_AREA => SY6->(DBSETORDER(1))
/*
Funcao          : EECAT130()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Executar browse de manutencao
Autor           : Heder M Oliveira
Data/Hora       : 24/11/98 09:30
Revisao         :
 -LCS.23/10/2006.15:59 -> INCLUSAO DO PONTO DE ENTRADA ANTES DA ENCHOICE
Obs.            :
*/
Function EECAT130()
   Local lRet:=.T.,nOldArea:=select(),nOLDORDEM:=INDEXORD(),nOLDREC:=RECNO()
   
   //Private lIntegra:=if(valtype(EasyGParam("MV_EECFAT"))=="L",EasyGParam("MV_EECFAT"),.F.)
   Private lIntegra:= IsIntFat() .Or. If(EasyGParam("MV_ESS0014",,.F.), IsIntEnable("001") , .F.) // ** By JBJ - 29/05/02  // NCF - 06/10/2015
   
   Private lInt := lIntegra // lIntegra nao cabia no x3_when do ee9_sldini
   
   Private cCadastro:=AVTITCAD("SY6") //"Condições de Pagamento"
   Private aRotina := MenuDef()
   Private cStrSeek:=TAMSX3("EE2_COD")[1]

   Begin sequence
      mBrowse( 6, 1,22,75,"SY6")
   End sequence
   RESTAREA()
Return lRet                    


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 12/01/07 - 17:10
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
                    { STR0002, "AT130MAN" , 0 , 2},; //"Visualizar"
                    { STR0003, "AT130MAN" , 0 , 3},; //"Incluir"
                    { STR0004, "AT130MAN" , 0 , 4},; //"Alterar"
                    { STR0005, "AT130MAN" , 0 , 5,3} } //"Excluir"
                    
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EAT130MNU")
	  aRotAdic := ExecBlock("EAT130MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina
/*
Funcao        : AT130MAN
Parametros    : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno        : .T.
Objetivos    : Executar enchice
Autor        : Heder M Oliveira
Data/Hora    : 25/11/98 10:58
Revisao        : 
Obs.        :
*/
Function AT130MAN(cAlias,nReg,nOpc)
    Local lRet:=.T.,nOldArea:=select(),nOLDORDEM:=INDEXORD(),nOLDREC:=RECNO()
	Local oDlg,nInc,bVal_OK,bCancel
    Local lGravaOK:=.T.
    Local bValPerc := {||}
    
    Private aTela[0][0],aGets[0],nUsado:=0
    Private aMemos:={{"Y6_DESC_P","Y6_VM_DESP"}}
    Private cNomArq,nOpcA:=3
    Private oDlgFocus := Nil //ASK 08/05/07 - Variável utilizada na chamada da função AvSetFocus
    Private lValPerc := .T.  
    
    Private aY6Enchoice:={"Y6_COD","Y6_TIPO","Y6_DIAS_PA","Y6_VM_DESP","Y6_MDPGEXP",;
                          "Y6_PERC_01","Y6_DIAS_01","Y6_PERC_02","Y6_DIAS_02",; 
                          "Y6_PERC_03","Y6_DIAS_03","Y6_PERC_04","Y6_DIAS_04",;
                          "Y6_PERC_05","Y6_DIAS_05","Y6_PERC_06","Y6_DIAS_06",;
                          "Y6_PERC_07","Y6_DIAS_07","Y6_PERC_08","Y6_DIAS_08",;
                          "Y6_PERC_09","Y6_DIAS_09","Y6_PERC_10","Y6_DIAS_10",;
                          "Y6_COM_LC","Y6_MDPDESC","Y6_CODERP"} // FSM - 28/12/2011 - Inclusao do campo 'Y6_CODERP'
    
    If Type("lInt") == "U"
       Private lInt := IsIntFat() .Or. If(EasyGParam("MV_ESS0014",,.F.), IsIntEnable("001") , .F.) // NCF - 06/10/2015
    EndIf
    
    If Type("cCadastro") == "U"                //NCF - 15/06/2015 - Variável não inicializda quando acessada rotina via F3 para MVC
       Private cCadastro:=AVTITCAD("SY6")
    EndIf
    
    IF lInt 
       aAdd(aY6Enchoice,"Y6_SIGSE4")
    Endif
    IF SY6->(FIELDPOS("Y6_PROMES")) # 0
       aAdd(aY6Enchoice,"Y6_PROMES")
    Endif
                          
    Begin sequence
       
       IF nOpc == INCLUIR
          // CRIAR VARIAVEIS DE MEMORIA ...
          For nInc := 1 TO (cAlias)->(FCount())
             M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
          Next nInc
       Else
          For nInc := 1 TO (cALIAS)->(FCount())
              M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
          Next nInc
       ENDIF
       
       // Work dos Idiomas ...
       Processa({|| EE2Manut(nOpc,MC_TCPG,MO_MM,AC_WK,{M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO))}) })
       
       If nOpc = VISUALIZAR
          bVal_OK:={||oDlg:End()}
       ElseIf nOpc==INCLUIR
          bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AT130PEVALID(nOpc),(nOpcA:=1,oDlg:End()),nOpca:=0)}
       ElseIf nOpc==ALTERAR
          bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. AT130PEVALID(nOpc),(nOpcA:=2,oDlg:End()),nOpca:=0)}
          If ! SY6->(Reclock("SY6",.F.))  // By JPP - 18/04/2005 - 11:35 - Bloquear o registro durante a alteração.
             Break
          EndIf
       ElseIf nOpc = EXCLUIR
              IF ! INTEGREF("SY6")
                 BREAK
              ENDIF
              bVal_OK:={||nOpca:=0,IF(AT130PEVALID(nOpc),(AT130MANE(nOpc),oDlg:End()),)}
              If ! SY6->(Reclock("SY6",.F.))  // By JPP - 18/04/2005 - 11:35 - Bloquear o registro durante a Exclusão.
                 Break
              EndIf
       EndIf
       // LCS.23/10/2006.08:20 - inclusao do ponto de entrada
       IF EasyEntryPoint("EECAT130")
          ExecBlock("EECAT130",.F.,.F.,{"ANTES_DO_MSGET",nOPC})
       Endif
       While ( nOpca>=3 )
          nOpcA := 0
          aTela := {}
          aGets := {}
          
          aY6Enchoice:=(AddCpoUser(aY6Enchoice,"SY6","1"))  // GFP - 21/03/2014
          
          DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

            oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , ,aY6Enchoice ,PosDlgUp(oDlg))
            
            
            // MsSelect dos Idiomas ...
            EE2Manut(nOpc,MC_TCPG,MO_MM,AC_MS,{oDlg,M->Y6_COD})
            
            bCancel := {||nOpcA:=0,oDlg:End()}
            oDlgFocus := oDlg //ASK 08/05/07 - Variável utilizada na chamada da função AvSetFocus                                   
            bValPerc := If(lGravaOK,{||IF(lValPerc,,(AvSetFocus("Y6_PERC_01",oDlgFocus),lValPerc:=.T.)) },{|| .T.})  // GFP - 25/04/2014
            oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
          ACTIVATE MSDIALOG oDlg ON INIT (EE2Manut(nOpc,MC_TCPG,MO_MM,AC_IN,{oDlg,bVal_Ok,bCancel,M->Y6_COD}),eval(bValPerc)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        
          Do Case
             Case nOpca==0
                  SY6->(MSUnlock()) // By JPP - 18/04/2005 - 11:40
                  If __lSX8
                     RollBackSXE()
                  EndIf
             Case nOpca==1 
                 Begin Transaction
                     Processa({||lGravaOk:=AT130Grava(.T.,nOpc)})
                     If !lGravaOk
                        //Help(" ",1,"A110NAORE")
                        nOpca:=3 //forcar loop
                        If __lSX8
                           RollBackSXE()
                        EndIf
                     Else
                        //Processa Gatilhos
                        EvalTrigger()
                        If __lSX8
                           ConfirmSX8()
                        Endif
                     EndIf
                 End Transaction
             Case nOpca==2 
                Begin Transaction
                   SY6->(dbgoto(nReg))  //soh p/confirmar
                   Processa({||lGravaOk:=AT130Grava(.F.,nOpc)})
                      
                   If !lGravaOk
                      //Help(" ",1,"A110NAORE")
                      nOpca:=3 // forcar loop
                      If __lSX8
                         RollBackSXE()
                      EndIf
                   Else
                      //Processa Gatilhos
                      EvalTrigger()
                      If __lSX8
                         ConfirmSX8()
                      Endif
                   EndIf
                End Transaction
          EndCase
       Enddo
    End Sequence
    // Fecha Work dos Idiomas ...
    EE2Manut(nOpc,MC_TCPG,MO_MM,AC_ER)
    E_RESET_AREA 
    RESTAREA()
Return lRet

/*
Funcao        : AT130MANE(nOpc)
Parametros    : Nenhum
Retorno        : .T.
Objetivos    : Excluir Registros
Autor        : Heder M Oliveira
Data/Hora    : 25/11/98 11:22
Revisao        :
Obs.        :
*/
Static Function AT130MANE(nOpc)

Local lRet:=.T.,cOldArea:=select(),cFilJF:=Xfilial("EE2")
Private lRetPE:=.T.

Begin Sequence
    if Msgnoyes(OemtoAnsi(STR0006),Oemtoansi(STR0007)) //"Confirma ExclusÆo?"###"Aten‡Æo"

        If EasyEntryPoint("EECAT130")
            Execblock("EECAT130",.F.,.F.,{"ANTES_EXCFINAL",nOpc})
        EndIf

        If lRetPE

            Reclock("SY6",.F.)
            
            // Eliminar descricoes em outro idioma ...
            Processa({|| EE2Manut(nOpc,MC_TCPG,MO_MM,AC_DE,{M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO))}) })
            
            SY6->(DBDELETE())
            SY6->(MsUnlock())
            MSMM(SY6->Y6_DESC_P,,,,EXCMEMO)
            
            If EasyEntryPoint("EECAT130")
                Execblock("EECAT130",.F.,.F.,{"APOS_EXCFINAL",nOpc})
            EndIf

        EndIf

    endif
End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao        : AT130Grava(lGrava)
Parametros    : lGrava:= .T. - append blank
                         .F. - replace
Retorno       : .T.
Objetivos     : Gravar Header e mensagens
Autor         : Heder M Oliveira
Data/Hora     : 20/11/98 09:38
Revisao       :
Obs.          :
*/
Static Function AT130Grava(lGrava,nOpc)
    Local lRet:=.T., cOldArea:=select(), nDiasOld := IF(nOpc == 4,SY6->Y6_DIAS_PA,0), nRecAtu, nRecNext, aOrdEE2
    
    Begin Sequence
        If !EA060Valid("*")
            lRet:=.F.
            BREAK
        EndIf
        
        E_Grava("SY6",lGrava)
        
        If ! lGrava
           //excluir antes
           MSMM(M->Y6_DESC_P,,,,EXCMEMO)
        EndIf
        
        MSMM(,AVSX3("Y6_VM_DESP")[AV_TAMANHO],,M->Y6_VM_DESP,INCMEMO,,,"SY6","Y6_DESC_P")
        
        // Gravar descricoes em outro idioma ...
        IF nOpc == 4 // Alteração
           IF M->Y6_DIAS_PA <> nDiasOld // Verifica se o usuário mudou o dias de pagamento, que é chave primária no EE2                     
              // Salva a ordem anterior do EE2
              aOrdEE2 := SaveOrd("EE2")
              
              // Posiciona o EE2 no primeiro item
              EE2->(dbSetOrder(2)) // FILIAL+CODCAD+TIPMEN+COD+IDIOMA              
              EE2->(dbSeek(xFilial()+MC_TCPG+TM_GER+AvKey(M->Y6_COD+STR(nDiasOld,AVSX3("Y6_DIAS_PA",AV_TAMANHO)),"EE2_COD")))
              
              While EE2->(!Eof() .And. EE2_FILIAL == xFilial("EE2")) .And. EE2->EE2_CODCAD == MC_TCPG .And.;
                    EE2->EE2_TIPMEN == TM_GER .And. EE2->EE2_COD == AvKey(M->Y6_COD+STR(nDiasOld,AVSX3("Y6_DIAS_PA",AV_TAMANHO)),"EE2_COD")
                 // Salva o recno do registro atual    
                 nRecAtu  := EE2->(RecNo())
                 // Busca o proximo registro e salva o recno
                 EE2->(dbSkip())
                 nRecNext := EE2->(RecNo())
                 // Atualiza o novo Codigo+Dias
                 EE2->(dbGoTo(nRecAtu))         
                 EE2->(RecLock("EE2",.F.))
                 EE2->EE2_COD := M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO))
                 // Vai para o proximo registro
                 EE2->(dbGoTo(nRecNext))
              Enddo                       
              
              // Restaura a ordem anterior               
              RestOrd(aOrdEE2)
              
              // Salva a ordem do Temp_EE2
              aOrdEE2 := SaveOrd("Temp_EE2")
              
              // Grava o novo codigo, muda para ordem 0 por RECNO, porque vai regravar o codigo
              Temp_EE2->(dbSetOrder(0))
              Temp_EE2->(dbEval({|| Temp_EE2->EE2_COD := M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO)) }))
              
              // Restaura a ordem anterior               
              RestOrd(aOrdEE2)
           Endif
        Endif
        
        EE2Manut(nOpc,MC_TCPG,MO_MM,AC_GR,{M->Y6_COD+STR(M->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO))})

    End Sequence
    
    dbselectarea(cOldArea)
    
Return lRet

/*
Funcao       : AT130PEVALID(nOpc)
Parametros   : Nenhum
Retorno      : Nil
Objetivos    : Executar ponto de entrada no CodBlock bVal_OK
Autor        : Lucas Raminelli LRS
Data/Hora    : 21/08/2018
*/
Function AT130PEVALID(nOpc)
Private lRetPE := .T.

IF(EasyEntryPoint("EECAT130"),Execblock("EECAT130",.F.,.F.,{"VALID_GRAVACAO",nOpc}),)

Return lRetPE
