#INCLUDE "EECAF100.ch"
/*
Programa        : EECAF100.PRW
Objetivo        : Manutencao e follow-up de Letter of Credit
Autor           : Heder M Oliveira
Data/Hora       : 14/12/98 10:27
Revisão         : JPM - 27/06/05 - Todas as partes do programa condicionadas à variável lItensLc
Obs.            :
*/
#include "EEC.cH"


/*
Funcao      : EECAF100()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de carta de credito
Autor       : Heder M Oliveira
Data/Hora   : 14/12/98 10:30
Revisao     :
Obs.        :
*/
Function EECAF100
   Local lRet:=.T.,cOldArea:=select(),aORD:=SAVEORD({"EEC"})
   Private lNRotinaLC := .f.,cNOMARQ, cNomArq2
   PRIVATE cWHENSA1 := "",cWHENSA2 := "",cCADASTRO:=AVTITCAD("EEL") // "Cartas de Crédito"
   PRIVATE aRotina := MenuDef()
   
   Private aMemoItens := {{"EXS_CODDES","EXS_VM_DES"}}
   
   Begin sequence
      // ** JPM - 28/06/05
      lItensLc := EECFlags("ITENS_LC")
      // **
      lNRotinaLC :=    (EEL->(FieldPos("EEL_SLDVNC")) # 0) ;
                 .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0) ;
                 .And. (EEL->(FieldPos("EEL_TIPO"))   # 0)
      
      mBrowse( 6, 1,22,75,"EEL")
   End sequence

   RESTORD(aORD)
   dbselectarea(cOldArea)

   If Select("TRB") > 0 //JPM
      TRB->(E_EraseArq(cNomArq))
   EndIf
   
   If Select("WorkLc") > 0 //JPM
      WorkLc->(E_EraseArq(cNomArq2))
   EndIf
   
Return lRet                    


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 02/02/07 - 15:51
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001 ,"AXPESQUI", 0 , PESQUISAR},; //"Pesquisar"
                    { STR0002 ,"AF100MAN", 0 , VISUALIZAR},; //"Visualizar"
                    { STR0003 ,"AF100MAN", 0 , INCLUIR},; //"Incluir"
                    { STR0004 ,"AF100MAN", 0 , ALTERAR},; //"Alterar"
                    { STR0005 ,"AF100MAN", 0 , EXCLUIR},; //"Excluir"
                    { STR0006 ,"AF100FLW"  , 0 , 6},; //"Follow-Up"
                    { STR0031 ,"AF100IMAGE", 0 , 7}}  //"Imagem L/C"
                    
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAF100MNU")
	aRotAdic := ExecBlock("EAF100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina                    

/*
Funcao      : AF100Flw
Parametros  : cAlias, nReg, nOpc
Retorno     : NIL
Objetivos   : Follow-up de Carta de Credito
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/11/1999 11:24
Revisao     : 
Obs.        :
*/
Function AF100Flw(cAlias,nReg,nOpc)

Begin Sequence
   IF EasyEntryPoint("EECPFN01")
      ExecBlock("EECPFN01",.F.,.F.,{cAlias,nReg,nOpc})
   Else
      EECPFN01("EECPFN01")
   Endif
End Sequence

Return NIL

/*
    Funcao   : AF100MAN(cALIAS,nREG,nOPC)
    Autor    : Heder M Oliveira    
    Data     : 09/11/99 09:50
    Revisao  : 09/11/99 09:50
    Uso      : Manutencao cartas credito
    Recebe   :
    Retorna  :

*/
FUNCTION AF100MAN(cALIAS,nREG,nOPC)
   Local lRET:=.T.,nOLDAREA:=SELECT(),oDLG,oOBJ,aPos
   Local bOk:={||oDlg:End()},bCancel:={||oDlg:End()}
   Local aCPOTRB:={{{||TRB->EEC_PREEMB},"",AVSX3("EEC_PREEMB",AV_TITULO)},;
                   {{||TRB->EEC_DTPROC},"",AVSX3("EEC_DTPROC",AV_TITULO)},;
                   {{||TRB->EEC_DTEMBA},"",AVSX3("EEC_DTEMBA",AV_TITULO)},;
                   {{||TRB->EEC_MOEDA+TRANSF(TRB->EEC_TOTPED,AVSX3("EEC_TOTPED",AV_PICTURE))},"",STR0008}}//"Total do Embarque"
   Local nInc := 0
   Local lMemoFmg := EEL->(FieldPos("EEL_CODFMG")) > 0
   
   Private aButtons := {}
   Private aCampos  := {}, aHeader[0], nOPCA:=0, aTela[0][0], aGets[0]
   Private nSelecao := nOpc
   Private aDeletados := {}, aCposBrowse
   Private nSeq := 1
   Private cFinali := ""
   Private aCposEnchoice := {}, aNotShow := {}
   Private nToler_01 := nToler_02 := 0
   
   Begin Sequence
      
      If !EECFlags("ITENS_LC")
         aNotShow := {AvKey("EEL_TOLERA","X3_CAMPO"),;
                      AvKey("EEL_CTPROD","X3_CAMPO"),;
                      AvKey("EEL_FINALI","X3_CAMPO")}
      EndIf

      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EEL"))
      While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == "EEL"
         If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel
            If AScan(aNotShow,SX3->X3_CAMPO) == 0
               AAdd(aCposEnchoice,SX3->X3_CAMPO)
            EndIf
         EndIf
         SX3->(DbSkip())
      EndDo
      
      aSemSX3:= {{"WKRECNO","N",7,0}}
      //TRP - 29/01/07 - Campos do WalkThru
      AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
      
      // by CRF 15/10/2010 - 09:28
      aSemSX3:= AddWkCpoUser(aSEmSX3,"EEC")
      
      If Select("TRB") = 0
         //Work de Processos                    
         AADD(aCampos,"EEC_PREEMB")
         AADD(aCampos,"EEC_DTPROC")
         AADD(aCampos,"EEC_DTEMBA") // JPM - 30/12/04
         AADD(aCampos,"EEC_TOTPED")
         AADD(aCampos,"EEC_MOEDA")
         
         cNomArq := E_CriaTrab(,aSemSX3)
         IndRegua("TRB",cNomArq+TEOrdBagExt(),"EEC_PREEMB")
      Else
         TRB->(avzap())
      EndIf
      
      // JPM - 28/06/05 - Work de Itens
      If lItensLc
         If Select("WorkLc") = 0
            
            aCampos := Array(EXS->(FCount()))
            aSemSx3 := {{"RECNO","N",7,0}}
            
            //TRP - 29/01/07 - Campos do WalkThru
            AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
            AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
            
            AddNaoUsado(aSemSX3,"EXS_LC_NUM")
            AddNaoUsado(aSemSX3,"EXS_SVFINA")
            AddNaoUsado(aSemSX3,"EXS_SEFINA")
            AddNaoUsado(aSemSX3,"EXS_QVFINA")
            AddNaoUsado(aSemSX3,"EXS_QEFINA")
            
           
           // by CRF 15/10/2010 - 10:12
           aSemSX3:= AddWkCpoUser(aSEmSX3,"EXS")
           
            
            cNomArq2 := E_CriaTrab("EXS",aSemSx3,"WorkLc")
            IndRegua("WorkLc",cNomArq2+TEOrdBagExt(),"EXS_SEQUEN")

         Else
            WorkLc->(avzap())   
         EndIf
         AAdd(aButtons,{"PAPEL_ESCRITO", {|| Af100DetTela() }, STR0020, STR0021}) //"Itens da Carta de Crédito","Itens"
         // Campos do browse de itens
         aCposBrowse := {{{|| WorkLc->EXS_SEQUEN },"",AVSX3("EXS_SEQUEN",AV_TITULO)},;
                         {{|| WorkLc->EXS_COD_I  },"",AVSX3("EXS_COD_I" ,AV_TITULO)},;
                         {{|| AllTrim(MemoLine(WorkLc->EXS_VM_DES,AvSx3("EXS_VM_DES",AV_TAMANHO) ) ) },"",AVSX3("EXS_VM_DES",AV_TITULO)},;
                         {{|| AllTrim(M->EEL_MOEDA) + " " + AllTrim(Transf(WorkLc->EXS_VALOR ,AVSX3("EXS_VALOR" ,AV_PICTURE)))},"",AVSX3("EXS_VALOR" ,AV_TITULO)},;
                         {{|| AllTrim(M->EEL_MOEDA) + " " + AllTrim(Transf(WorkLc->EXS_SLDVNC,AVSX3("EXS_SLDVNC",AV_PICTURE)))},"",AVSX3("EXS_SLDVNC",AV_TITULO)},;
                         {{|| AllTrim(M->EEL_MOEDA) + " " + AllTrim(Transf(WorkLc->EXS_SLDEMB,AVSX3("EXS_SLDEMB",AV_PICTURE)))},"",AVSX3("EXS_SLDEMB",AV_TITULO)},;
                         {{|| AllTrim(Transf(WorkLc->EXS_QTDVNC,AVSX3("EXS_QTDVNC",AV_PICTURE))) + " " + AllTrim(WorkLc->EXS_UNIDAD) },"",AVSX3("EXS_QTDVNC",AV_TITULO)},;
                         {{|| AllTrim(Transf(WorkLc->EXS_QTDEMB,AVSX3("EXS_QTDEMB",AV_PICTURE))) + " " + AllTrim(WorkLc->EXS_UNIDAD) },"",AVSX3("EXS_QTDEMB",AV_TITULO)}}
      EndIf
      
      If nOpc==INCLUIR
         bOK:={||If( Obrigatorio(aGets,aTela) .And. Af100Valid("FINAL"),(nOpcA:=1,oDlg:End()),)}
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
         Next nInc
		 M->EEL_VM_TEX :=""
      Else
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
         Next nInc
         
         IF Type("M->EEL_TOLERA") # "U"   
            nToler_01 := M->EEL_TOLERA              //NCF - 10/08/2010 - Variável para ponto de entrada
         ENDIF
         
         If(EasyEntryPoint("EECAF100"),ExecBlock("EECAF100",.F.,.F.,"PERC_TOLERANCIA_01"),) 

         If lItensLc
            Af100GrWork() // JPM - 28/06/05 - Carrega dados dos itens na work
         EndIf
         
         AF100GRTRB()
           
         If nOpc = VISUALIZAR
            bOK:={||oDlg:End()}
         ElseIf nOpc==ALTERAR
            bOK:={||If( Obrigatorio(aGets,aTela) .And. Af100Valid("FINAL"),(nOpca:=2,oDlg:End()),)}
         ElseIf nOpc = EXCLUIR
            bOK:={||nOpca:=3,oDlg:End()}
         EndIf
         If lMemoFmg
            M->EEL_MEMFMG := MsMM(EEL->EEL_CODFMG,AvSx3("EEL_MEMFMG",AV_TAMANHO),,,LERMEMO)
         EndIf
         M->EEL_VM_TEX := MSMM(EEL->EEL_TEXTO,AVSX3("EEL_VM_TEX",AV_TAMANHO),,,LERMEMO)
      Endif      
      
      If lItensLc
         cFinali := M->EEL_FINALI
      EndIf
      
      If EasyEntryPoint("EECAF100")
         ExecBlock("EECAF100",.F.,.F.,{"AF100MAN_ANTES_DIALOG", nOpcA})
      EndIf
     
      //by CRF 14/10/2010 - 14:26
      aCPOTRB := AddCpoUser(aCPOTRB,"EEC","5","TRB")
      
      
      TRB->(DbGoTop())
      DEFINE MSDIALOG oDlg TITLE STR0007 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Cartas de Crédito"
      
         oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , ,aCposEnchoice ,PosDlgUp(oDlg), , 3 )
         oObj:=MsSelect():New("TRB",,,aCPOTRB,,,PosDlgDown(oDlg)) 
         oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized:=.T.
         
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,If(Len(aButtons) > 0, aButtons,))) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      TRB->(DbSetOrder(1))
      
      Begin Transaction
      
         If EasyEntryPoint("EECAF100")
            ExecBlock("EECAF100",.F.,.F.,{"AF100MAN_ANTES_GRAVA", nOpcA})
         EndIf
      
         IF ( nOPCA==2 .OR. nOPCA==1)
         
            IF Type("M->EEL_TOLERA") # "U"
               nToler_02 := M->EEL_TOLERA                                                   //NCF - 10/08/2010 - Variável para ponto de entrada
            ENDIF
            
            If(EasyEntryPoint("EECAF100"),ExecBlock("EECAF100",.F.,.F.,"PERC_TOLERANCIA_02"),)
            
            E_GRAVA("EEL",IF(nOPCA==2,.F.,.T.))
            // Gravacao dos campos memo ...
            If nOPCA==2 // Alteracao - registros excluir
               If lMemoFmg
                  MSMM(M->EEL_CODFMG,,,,EXCMEMO)
               EndIf
               MSMM(M->EEL_TEXTO,,,,EXCMEMO)
            Endif
            If lMemoFmg
               MSMM(,AVSX3("EEL_MEMFMG",AV_TAMANHO),,M->EEL_MEMFMG,INCMEMO,,,"EEL","EEL_CODFMG")
            EndIf
            MSMM(,AVSX3("EEL_VM_TEX",AV_TAMANHO),,M->EEL_VM_TEX,INCMEMO,,,"EEL","EEL_TEXTO")    
            
            If lItensLc // JPM - 28/06/05 - Grava dados dos itens na base
               Af100GrvItens()
            EndIf
            
            // ** By JPM - 28/07/2004 - ponto de entrada
            IF EasyEntryPoint("EECAF100")
               ExecBlock("EECAF100",.F.,.F.,{"GRV"})
            EndIf      
   
         ELSEIF nOPCA==3 //EXCLUSAO
            IF (ISVAZIO("TRB"))
               EEL->(RECLOCK("EEL",.F.))
               If lItensLc
                  Af100ExcItens() // JPM - 28/06/05 - Exclui todos os itens da L/C
               EndIf 
               EEL->(DBDELETE())
               EEL->(MSUNLOCK())
               If lMemoFmg
                  MSMM(M->EEL_CODFMG,,,,EXCMEMO)
               EndIf
               MSMM(M->EEL_TEXTO,,,,EXCMEMO)
            ELSE
               HELP(" ",1,"AVG0000640") //MSGINFO("Exclusão não permitida. Carta de Crédita em uso.","Aviso")
            ENDIF
         ENDIF
      
      End Transaction
      
   End Sequence
   
   DBSELECTAREA(nOLDAREA)
   
   If nOPCA == 1
      AF100MAN(cALIAS,0,INCLUIR)   
   EndIf
   
RETURN lRET

/*
Função      : Af100GrWork
Objetivos   : Carregar dados na Work de Itens da Carta de Crédito
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 28/06/2005 - 10:38
*/

Function Af100GrWork()
Local i

Begin Sequence
   
   EXS->(DbSetOrder(1))
   EXS->(DbSeek(xFilial()+M->EEL_LC_NUM))
   While EXS->(!Eof()) .And. alltrim(EXS->(EXS_FILIAL+EXS_LC_NUM)) == alltrim(xFilial("EXS")+M->EEL_LC_NUM)
      WorkLc->(DbAppend())
      AvReplace("EXS","WorkLc")
      WorkLc->RECNO := EXS->(RecNo())
      WorkLc->TRB_ALI_WT:= "EXS"
      WorkLc->TRB_REC_WT:= EXS->(Recno())
      For i := 1 To Len(aMemoItens)
         WorkLc->&(aMemoItens[i][2]) := MSMM(EXS->&(aMemoItens[i][1]),AvSx3(aMemoItens[i][2],AV_TAMANHO),,,LERMEMO)
      Next
      nSeq := Val(AllTrim(EXS->EXS_SEQUEN))
      EXS->(DbSkip())
   EndDo
   WorkLc->(DbGoTop()) 
   nSeq++
End Sequence

Return Nil

/*
Função      : Af100GrvItens
Objetivos   : Gravar dados de itens da Carta de Crédito na base de dados
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 28/06/2005 - 10:58
*/

Function Af100GrvItens()
Local i
Begin Sequence
   For i := 1 to Len(aDeletados)
      EXS->(DbGoTo(aDeletados[i]),;
            RecLock("EXS",.f.),;
            DbDelete(),;
            MsUnlock())
   Next
   WorkLc->(DbGoTop())
   While WorkLc->(!EoF())
      If WorkLc->RECNO <> 0
         EXS->(DbGoto(WorkLc->RECNO))
         EXS->(RecLock("EXS",.f.))
         AvReplace("WorkLc","EXS")
         For i := 1 To Len(aMemoItens)
            MSMM(EXS->&(aMemoItens[i][1]),,,,EXCMEMO)
         Next
      Else
         EXS->(RecLock("EXS",.t.))
         AvReplace("WorkLc","EXS")
      EndIf

      For i := 1 To Len(aMemoItens)
         MSMM(,AvSx3(aMemoItens[i][2],AV_TAMANHO),,WorkLc->&(aMemoItens[i,2]),INCMEMO,,,"EXS",aMemoItens[i,1])
      Next
      
      EXS->(MsUnLock())
      
      WorkLc->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
Função      : Af100ExcItens
Objetivos   : Excluir todos os itens da Carta de Crédito que será excluída.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 28/06/2005 - 11:21
*/

Function Af100ExcItens()

Begin Sequence
   
   EXS->(DbSetOrder(1))
   EXS->(DbSeek(xFilial()+M->EEL_LC_NUM))
   While EXS->(!EoF()) .And. EXS->(EXS_FILIAL+EXS_LC_NUM) == (xFilial("EXS")+M->EEL_LC_NUM)
      EXS->(RecLock("EXS",.f.),DbDelete(),MsUnlock(),DbSkip())
   EndDo
   
End Sequence
   
Return Nil

/*
Função      : Af100DetTela
Objetivos   : Apresentar MsSelect para manutenção dos itens da Carta de Crédito
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 27/06/2005 - 16:40
*/

Function Af100DetTela()

Local oDlg, oMsSelect, aDelBackup, cOldArea := Select()
Local cFileBackup := CriaTrab(,.F.), lOk
Local bOk := {|| lOk := .t., oDlg:End()}, bCancel := {|| lOk := .f., oDlg:End()}
Local aButtons := {}
Begin Sequence
   
   If Empty(M->EEL_LC_NUM)
      MsgInfo(STR0022,STR0010) //"Informe o número da carta de crédito.","Aviso"
      Break
   EndIf
   
   If M->EEL_CTPROD $ cNao .And. IsVazio("WorkLc")
      MsgInfo(STR0051 + "'" + AllTrim(AvSx3("EEL_CTPROD",AV_TITULO)) + "'" + " .",STR0010) //"Esta carta de crédito esta configurada para não controlar produtos. Verifique o campo "##" .","Aviso"
      Break
   EndIf
   
   If (nSelecao = INCLUIR .Or. nSelecao = ALTERAR) .And. M->EEL_FINALI $ cNao //Se for inclusão ou alteração e não for uma L/C finalizada
      AAdd(aButtons, {"BMPINCLUIR" /*"EDIT"*/, {|| Af100DetMan(INCLUIR),oMsSelect:oBrowse:Refresh() }, STR0003 } ) //"Incluir"
      AAdd(aButtons, {"EDIT" /*"ALT_CAD"*/   , {|| Af100DetMan(ALTERAR),oMsSelect:oBrowse:Refresh() }, STR0004 } ) //"Alterar"
      AAdd(aButtons, {"EXCLUIR", {|| Af100DetMan(EXCLUIR),oMsSelect:oBrowse:Refresh() }, STR0005 } ) //"Excluir"     
   EndIf
   
   AAdd(aButtons, {"BMPVISUAL" /*"ANALITICO"*/,{|| Af100DetMan(VISUALIZAR)}, STR0002 } ) //"Visualizar"
   
   DbSelectArea("WorkLc")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy To (cFileBackup)
   TETempBackup(cFileBackup) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   aDelBackup := aClone(aDeletados)
   
   // by CRF 15/10/2010 - 09:51
   aCposBrowse := AddCpoUser(aCposBrowser,"EXS","5","WorkLc")
   
   WorkLc->(DbGoTop())
   
   Define MsDialog oDlg Title STR0023 + AllTrim(M->EEL_LC_NUM) From DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Itens da L/C Nr. "
      
      oMsSelect:=MsSelect():New("WorkLc",,,aCposBrowse,,,PosDlg(oDlg)) 
      oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelect:oBrowse:Refresh()
      oMsSelect:bAval := {|| Af100DetMan(VISUALIZAR) }
               
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
   
   If lOk
      WorkLc->(DbGoTop())
      
      While WorkLc->(!EoF())
         
         WorkLc->(DbSkip())
      EndDo
   Else
      WorkLc->(avzap())

      dbSelectArea("WorkLc")
      TERestBackup(cFileBackup) 
      aDeletados := aClone(aDelBackup)
      Break
   EndIf
   
   
End Sequence   

FErase(cFileBackup+GetDBExtension())
DbSelectArea(cOldArea)

Return Nil

/*
Função      : Af100DetMan
Parâmetros  : nOpc = INCLUIR, ALTERAR, EXCLUIR ou VISUALIZAR
Objetivos   : Apresentar Enchoice para manutenção de item da Carta de Crédito
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 28/06/2005 - 9:27
*/

Function Af100DetMan(nOpc)
Local oDlg, oMsMGet,cOldArea := Select()
Local bOk     := {|| If(Af100DetValid(),(lOk := .t., oDlg:End()),) },;
      bCancel := {|| lOk := .f., oDlg:End()}, lOk := .f.
Local nReg := WorkLc->(RecNo()), i
Private aGets[0], aTela[0][0]
Private nOpcItem := nOpc, lUtilizado := .f.

Begin Sequence 

   If nOpc <> INCLUIR .And. IsVazio("WorkLc")
      Help("",1,"ARQVAZIO")
      Break
   EndIf
   
   If nOpc = INCLUIR
      For i := 1 to EXS->(FCount())
         M->&(EXS->(FieldName(i))) := CriaVar(EXS->(FieldName(i)))
      Next
      If IsVazio("WorkLc")
         nSeq := 1
      EndIf
      M->EXS_LC_NUM := M->EEL_LC_NUM
      M->EXS_SEQUEN := StrZero(nSeq,AvSx3("EXS_SEQUEN",AV_TAMANHO))
      nReg := 0
   Else
      For i := 1 to WorkLc->(FCount())
         M->&(WorkLc->(FieldName(i))) := WorkLc->(FieldGet(i))
      Next
   EndIf

   If nOpc <> INCLUIR
      EE9->(DbSetOrder(11))
      If EE9->(DbSeek(xFilial("EXS")+M->EEL_LC_NUM+M->EXS_SEQUEN))
         lUtilizado := .t.
      EndIf
   EndIf
   
   Define MsDialog oDlg Title SubStr(aRotina[nOpc][1],2) + " - " + STR0024 + " " + AllTrim(M->EXS_SEQUEN) From DLG_LIN_INI,DLG_COL_INI To (DLG_LIN_FIM*0.80),(DLG_COL_FIM*0.80) Of oMainWnd Pixel //"Sequência"
      
      oMsMGet := MsMGet():New("EXS",, nOpc,,,,,PosDlg(oDlg),,3,,,,,,.t.)
      oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
      
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered
   
   If !lOk
      Break
   EndIf
   
   If nOpc = INCLUIR
      WorkLc->(DbAppend())
      AvReplace("M","WorkLc")
      nSeq++
   ElseIf nOpc = ALTERAR
      AvReplace("M","WorkLc")                  
   ElseIf nOpc = EXCLUIR
      If WorkLc->RECNO <> 0
         AAdd(aDeletados,WorkLc->RECNO)
      EndIf
      WorkLc->(DbDelete())
   EndIf
   
   If nOpc == INCLUIR //quando é inclusão, repete.
      Af100DetMan(INCLUIR)
   EndIf
   
End Sequence

DbSelectArea(cOldArea)

Return Nil

/*
Função      : Af100DetValid
Parâmetros  : Nenhum
Retorno     : .T. / .F.
Objetivos   : Validar dados da enchoice
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 28/06/2005 - 9:54
*/

Function Af100DetValid()
Local lRet := .t.

Begin Sequence
   
   If nOpcItem = INCLUIR .Or. nOpcItem = ALTERAR
      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      EndIf

      If M->EXS_VALOR <= 0
         MsgInfo(STR0053,STR0010) // "O Valor Total do Item deve ser maior que zero.","Aviso"
         lRet := .f.
         Break
      EndIf
      
      If M->EXS_CTRQTD $ cSim // Se controla saldo por quantidade
         If M->EXS_QTD = 0
            MsgInfo(STR0054 + "'" + AllTrim(AvSx3("EXS_CTRQTD",AV_TITULO)) + "'" + STR0055 ,STR0010)
                 //"Sendo controlado o Saldo por Quantidade (Campo " ## "), deve-se preencher a Quantidade.","Aviso"
            lRet := .f.
            Break
         EndIf
      EndIf
      
      If M->(!Empty(EXS_QTD) .And. Empty(EXS_UNIDAD))
         MsgInfo(STR0056,STR0010)//"Para preencher o campo de quantidade, a unidade de medida deverá ser informada.","Aviso"
         lRet := .f.
         Break
      EndIf
      
   ElseIf nOpcItem = EXCLUIR
      If lUtilizado//M->(EXS_VALOR <> EXS_SLDVNC) .Or. M->(EXS_QTD <> EXS_QTDVNC)
         MsgInfo(STR0025,STR0026)//"O item atual já está vinculado a iten(s) de embarque.","Exclusão não permitida"
         lRet := .f.
         Break
      EndIf
      If !MsgYesNo(STR0027,STR0028) //"Confirma Exclusão?","Exclusão"
         lRet := .f.
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
    Funcao   : AF100W(cCPO)
    Autor    : Heder M Oliveira    
    Data     : 08/11/99 16:58
    Revisao  : 08/11/99 16:58
    Uso      : Validar When
    Recebe   :
    Retorna  :

*/
Function AF100W(cCpo)
   Local lRet := .t.
   Begin Sequence
      Do Case
         Case cCpo == "EEL_IMPORT"
            cWhenSA1 := "EEL_IMPORT"

         Case cCpo == "EEL_EXPORT"
            cWhenSA2 := "EEL_EXPORT"

         Case cCpo == "EEL_BENEF"
            cWhenSA2 := "EEL_BENEF"

         Case cCpo == "EXS_TOLEQT"
            If lUtilizado
               lRet := .f.
               Break
            ElseIf M->EXS_CTRQTD $ cNao
               M->EXS_TOLEQT := 0
               lRet := .f.
               Break               
            EndIf
      End
   End Sequence
   
Return lRet

/*
    Funcao   : AF100GRTRB()
    Autor    : Heder M Oliveira    
    Data     : 09/11/99 10:37
    Revisao  : 09/11/99 10:37
    Uso      : Gerar TRB
    Recebe   : -
    Retorna  : .T. / .F.

*/
Static Function AF100GRTRB()

Local lRet:=.F.,nOldArea:=Select(), lEntra := .t.
Local aEmbarques := {}

Begin Sequence           

   EEC->(DbSetOrder(3)) //No. L/C
   EEQ->(DbSetOrder(1))

   If EEC->(DbSeek(xFilial("EEC")+M->EEL_LC_NUM))
      lRet:=.T.

      While !EEC->(EoF()) .AND. (XFILIAL("EEC")+M->EEL_LC_NUM==EEC->EEC_FILIAL+EEC->EEC_LC_NUM)
         If lNRotinaLC // JPM - Se for do tipo standby, se o embarque estiver todo liquidado,não entra na work
            lEntra := .t. //pois o saldo é restaurado quando são liquidadas as parcelas.
            If M->EEL_TIPO == "2" 
               //If EEQ->(DbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))
               If EEQ->(DbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))
                  lEntra := .f.
                  //While EEQ->(!EoF()) .And. xFilial("EEQ") == EEQ->EEQ_FILIAL .And. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
                  While EEQ->(!EoF()) .And. xFilial("EEQ") == EEQ->EEQ_FILIAL .And. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
                     If Empty(EEQ->EEQ_PGT)
                        lEntra := .t.
                        Exit
                     Endif
                     EEQ->(DbSkip())
                  Enddo
               EndIf
            Endif    
         Endif
         If lEntra 
            AAdd(aEmbarques,EEC->EEC_PREEMB)
            TRB->(DBAPPEND())
            TRB->EEC_PREEMB := EEC->EEC_PREEMB
            TRB->EEC_DTPROC := EEC->EEC_DTPROC
            TRB->EEC_DTEMBA := EEC->EEC_DTEMBA
            TRB->EEC_MOEDA  := EEC->EEC_MOEDA
            TRB->EEC_TOTPED := EEC->EEC_TOTPED
            TRB->TRB_ALI_WT := "EEC"
            TRB->TRB_REC_WT := EEC->(Recno())
         
            aOrd := SaveOrd("SX3",1)      
            SX3->(dbSeek("EEC"))       
            While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EEC" 
               If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
                  Eval(FieldWBlock(SX3->X3_CAMPO, Select("TRB")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("EEC"))))
               EndIF   
               SX3->(dbSkip())
            Enddo
            RestOrd(aOrd)
         
         EndIf
         EEC->(DbSkip(1))    
      EndDo
   EndIf
   
   If lItensLc
      EEC->(DbSetOrder(1))
      EE9->(DbSetOrder(11))
      WorkLc->(DbGoTop())
      While WorkLc->(!EoF())
         EE9->(DbSeek(xFilial("EXS")+WorkLc->(EXS_LC_NUM+EXS_SEQUEN)))
         While EE9->(!EoF()) .And. (xFilial("EXS")+WorkLc->(EXS_LC_NUM+EXS_SEQUEN)) == EE9->(EE9_FILIAL+EE9_LC_NUM+EE9_SEQ_LC)
            If AScan(aEmbarques,EE9->EE9_PREEMB) = 0
               AAdd(aEmbarques,EE9->EE9_PREEMB)
               EEC->(DbSeek(xFilial("EEL")+EE9->EE9_PREEMB))
               TRB->(DBAPPEND())
               TRB->EEC_PREEMB := EEC->EEC_PREEMB
               TRB->EEC_DTPROC := EEC->EEC_DTPROC
               TRB->EEC_DTEMBA := EEC->EEC_DTEMBA
               TRB->EEC_MOEDA  := EEC->EEC_MOEDA
               TRB->EEC_TOTPED := EEC->EEC_TOTPED
               TRB->TRB_ALI_WT := "EEC"
               TRB->TRB_REC_WT := EEC->(Recno())
            EndIf
            EE9->(DbSkip())
         EndDo
         WorkLc->(DbSkip())
      EndDo
   EndIf

   If TRB->(Empty(EEC_PREEMB) .And. !Eof() .And. !Bof() )
      TRB->(DbDelete())
   EndIf
   
   TRB->(DbGoTop())
   
End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : AF100Valid
Parametros  : cCampo
Retorno     : .T./.F.
Objetivos   : Validar/Gatilhar campos da manutenção de carta de crédito
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 23/12/2004 - 15:34
Revisao     : 
Obs.        :
*/
Function AF100Valid(cCampo)
Local lRet := .t., nRec, nDif := 0, nDif2 := 0, lSeek := .f. 
Local aCampos, cAlias, cPrefixo, cCond
Local nValor, lValor := .f., nOp, i
Local cInteiro, cDecimais, nValorMax,cValorMax // By JPP - 28/06/2008 - 15:15

Begin Sequence

   Do Case 
      Case cCampo == "EEL_LCVL"
         If M->EEL_LCVL < 0
            MsgStop(STR0009,STR0010)//"O valor da L/C não pode ser negativo.","Aviso"
            lRet := .f.
            Break
         Endif
         nRec := EEL->(RecNo())         
         EEL->(DbSetOrder(1))
         if !Empty(M->EEL_LC_NUM) 
            lSeek := EEL->(DbSeek(xFilial("EEL")+M->EEL_LC_NUM))
            If lSeek
               nDif := EEL->EEL_LCVL - M->EEL_LCVL
               If (EEL->EEL_SLDVNC - nDif) < 0 .or. (EEL->EEL_SLDEMB - nDif) < 0
                  MsgStop(STR0011,STR0010)
                  //"O valor digitado é insuficiente para cobrir os valores dos embarques já vinculados a esta Carta de Crédito.","Aviso"
                  lRet := .f.
                  EEL->(DbGoTo(nRec))
                  Break 
               Endif
            Endif
         Endif        
         If lSeek
            M->EEL_SLDVNC := EEL->EEL_SLDVNC - nDif
            M->EEL_SLDEMB := EEL->EEL_SLDEMB - nDif
         Else
            M->EEL_SLDVNC := M->EEL_LCVL
            M->EEL_SLDEMB := M->EEL_LCVL
         EndIf   
         EEL->(DbGoTo(nRec))
      
      Case cCampo $ "EEL_IMPORT/EEL_EXPORT/EEL_BENEF/EEL_NOTIFY/EEL_CONSIG/"
         
         If cCampo = "EEL_IMPORT"
            aCampos := {"EEL_IMPORT","EEL_IMLOJA","EEL_IMPODE","EEL_IMPEND","EEL_IMPEN2",STR0012}//"Cliente/Importador"
            cAlias  := "SA1"
            cCond   := "SA1->A1_TIPCLI $ '1/4'"
         ElseIf cCampo = "EEL_EXPORT"
            aCampos := {"EEL_EXPORT","EEL_EXLOJA","EEL_EXPODE","EEL_EXPEND","EEL_EXPEN2",STR0013}//"Exportador"
            cAlias  := "SA2"
            cCond   := "Left(SA2->A2_ID_FBFN,1) $ '3/4' "
         ElseIf cCampo = "EEL_BENEF"
            aCampos := {"EEL_BENEF","EEL_BELOJA","EEL_BENEDE","EEL_BENEND","EEL_BENEN2",STR0014}//"Beneficiário"
            cAlias  := "SA2"
            cCond   := "Left(SA2->A2_ID_FBFN,1) $ '3/5' "
         ElseIf cCampo = "EEL_NOTIFY"
            aCampos := {"EEL_NOTIFY","EEL_NOTLOJ","EEL_NOTDES","EEL_NOTEND","EEL_NOTEN2",STR0015}//"Notify"
            cAlias  := "SA1"
            cCond   := "SA1->A1_TIPCLI $ '3/4'"
         ElseIf cCampo = "EEL_CONSIG"
            aCampos := {"EEL_CONSIG","EEL_CONLOJ","EEL_CONDES","EEL_CONEND","EEL_CONEN2",STR0016}//"Consignatário"
            cAlias  := "SA1"
            cCond   := "SA1->A1_TIPCLI $ '2/4'"            
         EndIf
         If Empty(M->&(cCampo))
            aEval(aCampos,{|x| M->&(x) := CriaVar(x)},2,4)
            
            Break
         EndIf
         
         cPrefixo := SubStr(cAlias,2,2)
         (cAlias)->(DbSetOrder(1))
         lRet := (cAlias)->(DbSeek(xFilial()+M->&(aCampos[1]+"+"+aCampos[2]) ))
         If !lRet
            If SubStr(ReadVar(),4) = aCampos[2] //Se estiver validando o campo de loja, o seek com a loja(acima)deve retornar true se existir.
               Help("",1,"REGNOIS")
               Break
            EndIf
            lRet := (cAlias)->(DbSeek(xFilial()+M->&(aCampos[1])))
         EndIf
         If !lRet
            Help("",1,"REGNOIS")
            Break
         EndIf

         If !(&cCond)
            MsgStop(STR0017 + aCampos[6] + ".",STR0010) //"O código digitado não se refere a um " ## "." , "Aviso"
            lRet := .f.
            Break
         EndIf
         
         M->&(aCampos[2]) := (cAlias)->&(cPrefixo+"_LOJA")
         M->&(aCampos[3]) := (cAlias)->&(cPrefixo+"_NOME")
         M->&(aCampos[4]) := EECMEND(cAlias,1,M->&(aCampos[1]+"+"+aCampos[2]),.T.,AvSx3(aCampos[4],3),1)
         M->&(aCampos[5]) := EECMEND(cAlias,1,M->&(aCampos[1]+"+"+aCampos[2]),.T.,AvSx3(aCampos[5],3),2)
     
      Case cCampo $ "EXS_PRECO/EXS_QTD/EXS_VALOR"

         If cCampo $ "EXS_PRECO/EXS_QTD"
            If M->EXS_PRECO < 0 .Or. M->EXS_QTD < 0
               MsgStop(STR0018,STR0010)// "O preço e a quantidade devem ser positivos.","Aviso"
               lRet := .f.
               Break
            EndIf
            
           // nValor := M->(Round(EXS_PRECO * EXS_QTD,AvSx3("EXS_VALOR",AV_DECIMAL))) ASK 07/08/07
            nValor := Round(M->EXS_PRECO * M->EXS_QTD, AvSx3("EXS_VALOR", AV_DECIMAL))
            //If nValor > &(Repl("9",AvSx3("EXS_VALOR",AV_TAMANHO)-AvSx3("EXS_VALOR",AV_DECIMAL)-1)+"."+Repl("9",AvSx3("EXS_VALOR",AV_DECIMAL)) ) // By JPP - 28/06/2008 - 15:15 
            cInteiro := Replicate("9",AvSx3("EXS_VALOR",AV_TAMANHO)-AvSx3("EXS_VALOR",AV_DECIMAL)-1)+"." // By JPP - 28/06/2008 - 15:15 - O IF acima foi substituido por motivos de error.log.
            cDecimal := Replicate("9",AvSx3("EXS_VALOR",AV_DECIMAL)) // By JPP - 28/06/2008 - 15:15
            cValorMax := cInteiro + cDecimal // By JPP - 28/06/2008 - 15:15
            nValorMax := Val(cValorMax) // By JPP - 28/06/2008 - 15:15
            If nValor > nValorMax  .Or. nValor > M->EEL_SLDEMB // By JPP - 28/06/2008 - 15:15
               MsgInfo(STR0029,STR0010)//"Os valores digitados são muito grandes para serem armazenados.","Aviso"
               lRet := .f.
               Break
            EndIf
         Else
            nValor := M->EXS_VALOR
            lValor := .t.
         EndIf
         
         If nOpcItem == ALTERAR

            If nValor > 0 .Or. cCampo = "EXS_VALOR"
               // ** Alteração no valor
               nDif := WorkLc->EXS_VALOR - nValor
               If (WorkLc->EXS_SLDVNC - nDif) < 0 .or. (WorkLc->EXS_SLDEMB - nDif) < 0
                  MsgStop(STR0019,STR0010)//"O valor digitado é insuficiente para cobrir os valores dos itens de embarques já vinculados a esta Carta de Credito.","Aviso"
                  lRet := .f.
                  Break 
               Endif
            EndIf
         
            If !lValor
               // ** Alteração na quantidade
               nDif2 := WorkLc->EXS_QTD - M->EXS_QTD
               If (WorkLc->EXS_QTDVNC - nDif2) < 0 .or. (WorkLc->EXS_QTDEMB - nDif2) < 0
                  MsgStop(STR0052,STR0010)//"A quantidade informada é insuficiente para cobrir as quantidades dos itens de embarque já vinculados a esta Carta de Crédito.","Aviso"
                  lRet := .f.
                  Break
               Endif
               M->EXS_QTDVNC := WorkLc->EXS_QTDVNC - nDif2
               M->EXS_QTDEMB := WorkLc->EXS_QTDEMB - nDif2
            EndIf
            
            If nValor > 0 .Or. cCampo = "EXS_VALOR"
               M->EXS_SLDVNC := WorkLc->EXS_SLDVNC - nDif
               M->EXS_SLDEMB := WorkLc->EXS_SLDEMB - nDif
            EndIf
            
         Else
            If nValor > 0 .Or. cCampo = "EXS_VALOR"
               M->EXS_SLDVNC := nValor
               M->EXS_SLDEMB := nValor
            EndIf
            
            If !lValor
               M->EXS_QTDVNC := M->EXS_QTD
               M->EXS_QTDEMB := M->EXS_QTD
            EndIf
            
         EndIf
         
         If !lValor .And. nValor > 0
            M->EXS_VALOR := nValor
            
         EndIf
         
      Case cCampo = "FINAL"
         
         If !lItensLc
            Break
         EndIf
         
         nValor := 0
         WorkLc->(DbGoTop())
         
         While WorkLc->(!EoF())
            nValor += WorkLc->EXS_VALOR
            If nSelecao = INCLUIR
               WorkLc->EXS_LC_NUM := M->EEL_LC_NUM
            EndIf
            WorkLc->(DbSkip())
         EndDo
         
         If M->EEL_CTPROD $ cSim .And. nValor <> M->EEL_LCVL
            MsgInfo(STR0030,STR0010) //"A soma dos valores dos itens deve ser igual ao valor informado na capa.","Aviso"
            lRet := .f.
            Break
         EndIf
      
      Case cCampo $ "EEL_TOLERA/EXS_TOLEVL/EXS_TOLEQT/"
         
         If M->&(cCampo) > 99.99
            MsgStop(STR0049,STR0010) //"A porcentagem de tolerância não pode exceder 99.99%.","Aviso"
            lRet := .f.
            Break
         EndIf

         If cCampo = "EXS_TOLEVL"
            If M->EXS_TOLEVL > M->EEL_TOLERA
               MsgStop(STR0057,STR0010) //"A tolerância do item não pode ser maior que a tolerância da L/C.","Aviso"
               lRet := .f.
               Break
            EndIf
         EndIf

      Case cCampo = "EEL_CTPROD"
      
         If !IsVazio("WorkLc") .And. M->EEL_CTPROD $ cNao
            MsgInfo(STR0050,STR0010) //"Existem itens cadastrados para esta carta de crédito. Remova todos os itens antes de mudar esta opção.","Aviso"
            lRet := .f.
            Break
         EndIf

      Case cCampo = "EEL_FINALI"  
         
         If cFinali <> M->EEL_FINALI // Se o campo foi mudado pelo usuário
            If cFinali $ cSim .And. M->EEL_FINALI $ cNao // Se estava como sim e foi para não
               aCampos := {"EEL_SLDVNC", "EEL_SLDEMB", "EXS_SLDVNC", "EXS_SLDEMB", "EXS_QTDVNC", "EXS_QTDEMB",;
                           "EEL_SVFINA", "EEL_SEFINA", "EXS_SVFINA", "EXS_SEFINA", "EXS_QVFINA", "EXS_QEFINA" }
            ElseIf cFinali $ cNao .And. M->EEL_FINALI $ cSim
               aCampos := {"EEL_SVFINA", "EEL_SEFINA", "EXS_SVFINA", "EXS_SEFINA", "EXS_QVFINA", "EXS_QEFINA",;
                           "EEL_SLDVNC", "EEL_SLDEMB", "EXS_SLDVNC", "EXS_SLDEMB", "EXS_QTDVNC", "EXS_QTDEMB" }
               
            Else
               Break
            EndIf
            
            For i := 1 to 2
               M->&(aCampos[i])   := M->&(aCampos[i+6])
               M->&(aCampos[i+6]) := 0
            Next
            
            WorkLc->(DbGoTop())
            While WorkLc->(!EoF())
               For i := 3 to 6
                  WorkLc->&(aCampos[i])   := WorkLc->&(aCampos[i+6])
                  WorkLc->&(aCampos[i+6]) := 0
               Next
               WorkLc->(DbSkip())
            EndDo
            
            cFinali := M->EEL_FINALI
         EndIf
      
      //RMD - Só deixa mudar se não estiver vinculada.
      Case cCampo == "EEL_RENOVA"
         
         If Type("nSelecao") == "L" .And. nSelecao == ALTERAR
            aOrd := SaveOrd("EE9")
            EE9->(DbSetOrder(11))
            If EE9->(DbSeek(xFilial("EXS")+M->EEL_LC_NUM+M->EXS_SEQUEN))
               MsgInfo(STR0025 + ENTER + STR0058, STR0010)//"O item atual já está vinculado a um ou mais itens de embarque."
                                                          //"Para alterar, será necessário fazer a desvinculação do item no processo de embarque correspondente."###"Aviso"
               lRet := .F.
            EndIf
            RestOrd(aOrd, .T.)
            If !lRet
               Break
            EndIf
         EndIf
      
   EndCase
     
End Sequence

Return lRet

/*
Funcao      : AF100Image
Parametros  : cAlias, nReg, nOpc
Retorno     : Nil
Objetivos   : Guardar / Carregar imagem da L/C.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 29/06/2005 15:25
*/

Function AF100Image(cAlias, nReg, nOpc)
Local oDlg, oFont
Private cFolder := "\Imagens - LC", cImagem := cFolder+"\"+AllTrim(EEL->EEL_LC_NUM)+".pdf"

Begin Sequence

   If !lIsDir(cFolder)
      MakeDir(cFolder)
   EndIf
   
   Define MsDialog oDlg Title STR0035 From 1,1 To 150,180 OF oMainWnd Pixel //"O que deseja fazer?"
      
      AvBorda()
      oFont := TFont():New("Arial",08,15)
      @ 10,010 Button "&"+STR0032 Size 70,13 Pixel Font oFont Action Af100Anexa() Of oDlg //"Anexar Imagem"
      @ 30,010 Button "&"+STR0033 Size 70,13 Pixel Font oFont Action Af100Carrega() Of oDlg When File(cImagem)//"Abrir imagem"
      @ 50,010 Button "&"+STR0034 Size 70,13 Pixel Font oFont Action Af100Exclui() Of oDlg When File(cImagem)//"Excluir imagem"
      
   Activate MsDialog oDlg Centered      

End Sequence

Return Nil

/*
Funcao      : AF100Anexa
Objetivos   : Anexar imagem da L/C
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 29/06/2005 16:39
*/
Function AF100Anexa()
Local cFile, lFile

Begin Sequence

   If (lFile := File(cImagem))
      If !MsgYesNo(STR0036 + AllTrim(EEL->EEL_LC_NUM) + ". "+STR0037) //"Já existe arquivo anexado à L/C " ## "Deseja substituí-lo?"
         Break
      EndIf
   EndIf
   
   If Empty(cFile := ChooseFile())
      Break
   EndIf
   
   If !File(cFile)
      MsgInfo(STR0038,STR0010) //"O arquivo informado não existe.","Aviso"
      Break
   EndIf
   
   If lFile
      If FErase(cImagem) = -1
         MsgInfo(STR0039,STR0010) //"O arquivo já existente não pode ser apagado.","Aviso"
         Break
      EndIf
   EndIf   
   
   If AvCpyFile(cFile,cImagem,.f.) //não tem Else porque a própria AvCpyFile dá as mensagens necessárias se houver insucesso.
      MsgInfo(STR0040 + AllTrim(EEL->EEL_LC_NUM) + STR0041,STR0042) //"Arquivo anexado à L/C "##" com sucesso!","Sucesso"
   EndIf
   
End Sequence

Return Nil

/*
Funcao      : AF100Carrega
Objetivos   : Carregar imagem da L/C
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 29/06/2005 16:39
*/

Function AF100Carrega()
Local cOper  := "open" // "print", "explore"
Local cParam := ""
Local cDir   := ""
Local cDrive := ""
Local nRet

If !File(cImagem)
   MsgInfo(STR0043,STR0010) //"Esta L/C não possui imagem anexada.","Aviso"
   Return Nil
EndIf

cTempPath := GetTempPath()

cFile := SubStr(cImagem,RAt("\",cImagem))
cFile := cTempPath + "\" + cFile

If (File(cFile) .And. FErase(cFile) = -1) .Or. !CpyS2T( cImagem, cTempPath, .T. )
   MsgInfo(STR0044,STR0010) //"Não foi possível efetuar a cópia do arquivo para o terminal.","Aviso"
   Return Nil
EndIf

SplitPath(cFile, @cDrive, @cDir )
cDir := Alltrim(cDrive) + Alltrim(cDir)

nRet := ShellExecute(cOper,cFile,cParam,cDir, 1)

If nRet <= 32
   MsgInfo(STR0045 + cImagem + ".",STR0010) //"Não foi possível abrir a imagem " ## ".","Aviso"
EndIf

Return Nil

/*
Funcao      : Af100Exclui
Objetivos   : Exclui imagem da L/C
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 30/06/2005 8:47
*/

Function Af100Exclui()

Begin Sequence

   If File(cImagem)
      If FErase(cImagem) = -1
         MsgInfo(STR0046 + AllTrim(Str(FError())) + ".",STR0010) //"A imagem não pode ser excluída. Erro: " ## ".","Aviso"
         Break
      EndIf
      MsgInfo(STR0047,STR0042) //"Imagem excluída com sucesso!","Sucesso"
   Else
      MsgInfo(STR0043,STR0010) //"Esta L/C não possui imagem anexada.","Aviso"
   EndIf
   
End Sequence

Return Nil

/*
Funcao     : ChooseFile()
Parametros : Nenhum
Retorno    : cFile - Arquivo selecionado
Objetivos  : Abrir tela para escolha do arquivo a ser anexado à L/C
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/06/05 - 16:45
*/

*--------------------------*
Static Function ChooseFile()
*--------------------------*
Local cTitle := STR0048//"Arquivo a ser anexado"
Local cMask  := "Adobe Acrobat Document (*.pdf)|*.pdf"
Local cFile  := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

Return cFile
