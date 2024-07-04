#INCLUDE "EECAT135.ch"
/*
Programa        : EECAT135
Objetivo        : Permitir manutencao de moedas em varios idiomas
Autor           : Heder M Oliveira
Data/Hora       : 17/11/98 09:51
Obs.            : OC 0467/98 OS 1327/98
*/
#include "EEC.CH"

#COMMAND E_RESET_AREA => SYF->(DBSETORDER(1))


/*
Funcao      : EECAT135
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Montar browse
Autor       : Heder M Oliveira
Data/Hora   : 17/11/98 10:03
Revisao     :
Obs.        :
*/
Function EECAT135()
    Local lRet:=.T.,cOldArea:=select()
    Private cCadastro:=AVTITCAD("SYF")//Oemtoansi("Moedas")
    Private aRotina := MenuDef()
    
    Begin sequence
        mBrowse( 6, 1,22,75,"SYF")
    Endsequence
    dbselectarea(cOldArea)
Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 22/01/07 - 17:11
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001,   "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                    { STR0002,   "AT135MAN"  , 0 , VISUALIZAR},; //"Visualizar"
                    { STR0003,   "AT135MAN"  , 0 , INCLUIR},; //"Incluir"
                    { STR0004,   "AT135MAN"  , 0 , ALTERAR},; //"Alterar"
                    { STR0005,   "AT135MAN"  , 0 , EXCLUIR,3} } //"Excluir"
                    
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EAT135MNU")
	  aRotAdic := ExecBlock("EAT135MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina

/*
Funcao      : AT135MAN
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : .T.
Objetivos   : Manutencao com enchoice
Autor       : Heder M Oliveira
Data/Hora   : 17/11/98 10:26
Revisao     :
Obs.        :
*/
Function AT135MAN(cAlias,nReg,nOpc)

   Local lRet:=.T.,cOldArea:=Select(),oDlg,nInc,bVal_OK
   Local lGravaOK:=.T.,nOpcA:=3, bCancel
   Local aCpoEnc 
   //MFR 10/04/2019 OSSME-2708
   Local aEscCpo := {}

   Private aTela[0][0],aGets[0],nUsado:=0
   Private cNomArq

   Begin Sequence
    
      IF nOpc == INCLUIR 
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
         Next nInc
      Else
         For nInc := 1 TO (cALIAS)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc
      Endif
      
      // Work dos Idiomas ...
      Processa({|| EE2Manut(nOpc,MC_TMOE,MO_SP,AC_WK,{M->YF_MOEDA}) })
      
      If nOpc = VISUALIZAR
         bVal_OK:={||oDlg:End()}
      ElseIf nOpc==INCLUIR
         bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=1,oDlg:End()),nOpca:=0)}
      ElseIf nOpc==ALTERAR
         bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=2,oDlg:End()),nOpca:=0)}
      ElseIf nOpc = EXCLUIR
             IF ! INTEGREF("SYF")
                BREAK
             ENDIF
             bVal_OK:={||nOpca:=0,AT135MANE(nOpc),oDlg:End()}
      EndIf

      //MFR 10/04/2019 OSSME-2708
      If !EECFlags("INTTRA") .And. !avFlags("DU-E") // THTS - 26/05/2017 - Campo ISO deve aparecer para geracao da DU-E   
         AADD(aEscCpo,"YF_ISO")
      EndIf

      //MFR 10/04/2019 OSSME-2708
      If !EasyFindAdpt("EECAT141") // Taxa de Fiscal
         AADD(aEscCpo,"YF_CODFERP")
      EndIf
      
      //MFR 10/04/2019 OSSME-2708
      If !EasyFindAdpt("EECAT142") // Taxa de compra
         AADD(aEscCpo, "YF_CODCERP")
      EndIf
      //MFR 10/04/2019 OSSME-2708
      If !EasyFindAdpt("EECAT143")// Taxa de venda
         AADD(aEscCpo, "YF_CODVERP")
      EndIf

      If !Empty(aEscCpo)
          aCpoEnc := AvCposEnc("SYF", Nil, aEscCpo)
      EndIf

      While ( nOpca>=3 )
         nOpcA:=0           
         aTela := {}
         aGets := {}
      
         DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         
            oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , , aCpoEnc, PosDlgUp(oDlg))
            
            // MsSelect Idiomas
            EE2Manut(nOpc,MC_TMOE,MO_SP,AC_MS,{oDlg,M->YF_MOEDA})
            
            bCancel := {||nOpcA:=0,oDlg:End()}
			
			oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                
         ACTIVATE MSDIALOG oDlg ON INIT (EE2Manut(nOpc,MC_TMOE,MO_SP,AC_IN,{oDlg,bVal_OK,bCancel,M->YF_MOEDA})) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        
         Do Case
            Case nOpca==1
                Begin Transaction
                    Processa({||lGravaOk:=AT135Grava(.T.,nOpc)})
                    If !lGravaOk
                        Help(" ",1,"A110NAORE")
                    Else
                        //Processa Gatilhos
                        EvalTrigger()
                        If __lSX8
                            ConfirmSX8()
                        Endif
                    EndIf
                End Transaction
            Case nOpca==2
                SYF->(dbgoto(nReg))  //soh p/confirmar
                Processa({||lGravaOk:=AT135Grava(.F.,nOpc)})
         EndCase
      Enddo
   End Sequence

   // Fecha e Apaga o Work ...
   EE2Manut(nOpc,MC_TMOE,MO_SP,AC_ER)
   
   E_RESET_AREA
   dbselectarea(cOldArea)
   
Return lRet

/*
Funcao      : AT135MANE(nOpc)
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 17/11/98 11:09
Revisao     :
Obs.        :
*/
Static Function AT135MANE(nOpc)
    Local lRet:=.T.,cOldArea:=Select()
    Begin sequence
        if Msgnoyes(OemtoAnsi(STR0006),Oemtoansi(STR0007)) //"Confirma ExclusÆo?"###"Aten‡Æo"
           Reclock("SYF",.F.)
           
           // Eliminar descricoes em outro idioma ...
           Processa({|| EE2Manut(nOpc,MC_TMOE,MO_SP,AC_DE,{M->YF_MOEDA}) })
            
           SYF->(DBDELETE())
           SYF->(MsUnlock())
        endif
    End
    dbselectarea(cOldArea)
Return lRet

/*
Funcao      : AT135Grava(lGrava,nOpc)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Heder M Oliveira
Data/Hora   : 20/11/98 09:38
Revisao     :
Obs.        :
*/
Static Function AT135Grava(lGrava,nOpc)
    Local lRet:=.T.,cOldArea:=select(),nInc,nYnc
    Local xVar, BVar:={||.t.}   
    Begin sequence
       
        E_Grava("SYF",lGrava)
        
        // Gravar descricoes em outro idioma ...
        EE2Manut(nOpc,MC_TMOE,MO_SP,AC_GR,{M->YF_MOEDA})
        
    End sequence
    dbselectarea(cOldArea)
Return lRet

*------------------------------------------------------------------------*
* FIM DO PROGRAMA ECCAT135.PRW                                           *
*------------------------------------------------------------------------*
