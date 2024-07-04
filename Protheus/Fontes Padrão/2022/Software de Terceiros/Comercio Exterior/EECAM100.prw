#Include "EECAM100.CH"
#Include "EEC.cH"
#Include "AP5MAIL.CH"

/*
Programa   : EECAM100.PRW.
Objetivo   : Manutencao de Amostras.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 05/10/05 - 14:00
Obs        : 
*/


/*
Funcao      : EECAM100()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Executar MBrowse
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/10/05 - 14:00
Obs.        :
*/                            

*------------------*
Function EECAM100()
*------------------*
Local aOrd := SaveOrd({"EXU"})
Local cAlias := "EXU"

Private cNomArq1, cNomArq2, cNomArq3, cNomArq4 

Private aRotina := MenuDef()
Private aCampos  := {}
Private cFilBr := "", cFilEx := ""
PRIVATE cCadastro := FWX2Nome(cAlias)
EECFlags("INTERMED")

If EasyEntryPoint("EECAM100")
   ExecBlock("EECAM100",.F.,.F.,{"BROWSE"})
EndIf

EXU->(DbSetOrder(2))
mBrowse(6, 1,22,75,cAlias)
RestOrd(aOrd, .F.)
If Select("WKEXV") > 0
   WKEXV->(E_EraseArq(cNomArq1))  
EndIf

If Select("WKITENS") > 0
   WKITENS->(E_EraseArq(cNomArq2))  
EndIf

If Select("WKQUAL") > 0
   WKQUAL->(E_EraseArq(cNomArq3))  
EndIf

If Select("WKAMOSTRA") > 0
   WKAMOSTRA->(E_EraseArq(cNomArq4))  
EndIf

Return Nil                         


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 02/02/07 - 15:11
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //Pesquisar
                    { STR0002, "AM100MAN" , 0 , 2},;   //Visualizar
                    { STR0003, "AM100MAN" , 0 , 3},;   //Incluir
                    { STR0004, "AM100MAN" , 0 , 4},;   //Alterar
                    { STR0005, "AM100MAN" , 0 , 5,3},; //Excluir
                    { STR0006, "AM100MAIL" ,0 , 4},;   //Env. E-mail
                    { STR0104, "AM100DESC" ,0 , 5,3}}  //Descartar

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAM100MNU")
	aRotAdic := ExecBlock("EAM100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
                  

/*
Funcao      : AM100MAN()
Parametros  : cAlias, nReg, nOpc
Retorno     : Nenhum.
Objetivos   : Efetuar manutenção em uma amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/10/05 - 14:15
Obs.        :
*/                            

*----------------------------------*
Function AM100MAN(cAlias,nReg,nOpc)
*----------------------------------*                 
Local bOk := {|| If( Am100Valid("BOK") ,(lOk := .T., oDlg:End()), lOk := .F.) },;
      bCancel := {|| oDlg:End()}

Local nInc

Local aOrd := SaveOrd({"EXU","EXV"})

Local lOk := .F.

Private nOpcao := nOpc

Private lAltera := .T.,;
        lRej := .F.

Private oMsSelectCp,;
        oGet_x

Private aPosCap, aPosDet, aCposBrowseCp, aDeletados := {}, aButtons := {},;
        aCampos := Array(EXV->(FCount())),;
        aCamposValid := {"EXU_NROAMO","EXU_PEDIDO","EXU_CODQUA","EXU_CODPEN","EXU_CODTIP","EXU_CODBEB","EXU_TIPOAM"},;
        aGets[0],aTela[0]
        
Private cMarca := GetMark(), cTipoAm := CriaVar("EXU_TIPOAM"), cGet_x := ""

Private aMostra,aAltera

Begin Sequence

   If nOpc == INCLUIR
      For nInc := 1 To EXU->(FCount())
         M->&(EXU->(FIELDNAME(nInc))) := CRIAVAR(EXU->(FIELDNAME(nInc)))
      Next
      M->EXU_STATUS := STAM_NE
      M->EXU_STADES := STR0017//"Não Enviada."
   Else
      If nOpc == ALTERAR
         If EXU->EXU_STATUS == STAM_RJ
            MsgInfo(STR0008, STR0055)//"Amostra rejeitada, disponível apenas para visualização."
            nOpc := VISUALIZAR
         ElseIf EXU->EXU_STATUS == STAM_DC
            MsgInfo(STR0060, STR0055)//"Amostra descartada, disponível apenas para visualização."
            nOpc := VISUALIZAR
         EndIf
      EndIf      

      For nInc := 1 To EXU->(FCount())
         M->&(EXU->(FIELDNAME(nInc))) := EXU->(FIELDGET(nInc))
      Next
      M->EXU_DSCQUA := MSMM(EXU->EXU_QUADES,AVSX3("EXU_DSCQUA",AV_TAMANHO),,,LERMEMO)
      M->EXU_DSCOBS := MSMM(EXU->EXU_OBS,AVSX3("EXU_DSCOBS",AV_TAMANHO),,,LERMEMO)
      cTipoAm := M->EXU_TIPOAM
      
   EndIf
 
   If nOpc == INCLUIR .Or. nOpc == ALTERAR
      aAdd(aButtons,{"BMPINCLUIR" /*"NOVACELULA"*/, {|| AM100DETMAN(INC_DET)},STR0009}) //"Vincular Itens"
      aAdd(aButtons,{"S4WB005N" /*"S4WB001N"*/, {|| AM100CPQUAL() },STR0010}) //"Copiar informações de Qualidade/Tipo/Peneira/Bebida."
   EndIf                                
   aSemSX3:= {{"WK_RECNO","N",10,0}}  
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   If Select("WKEXV") == 0
      cNomArq1 := EXV->(E_CriaTrab("EXV",aSemSX3,"WKEXV"))
   EndIf
   
   If nOpc <> INCLUIR
      WKEXV->(avzap())
      EXV->(DbSetOrder(1))
      If EXV->(DbSeek(xFilial("EXV")+M->EXU_NROAMO))
         lAltera := .F.
         While EXV->(!Eof()) .And. xFilial("EXV") == EXV->EXV_FILIAL .And. EXV->EXV_NROAMO == M->EXU_NROAMO
            WKEXV->(DbAppend())
            AvReplace("EXV","WKEXV")
            WKEXV->WK_RECNO := EXV->(RecNo())
            WKEXV->TRB_ALI_WT:= "EXV"
            WKEXV->TRB_REC_WT:= EXV->(Recno())
            EXV->(DbSkip())
         EndDo
         WKEXV->(DbGoTop())
      EndIf
   EndIf
   
   aCposBrowseCp:={{{|| WKEXV->EXV_NROAMO },"",AvSx3("EXV_NROAMO" ,AV_TITULO)},;
                  {{|| WKEXV->EXV_PEDIDO  },"",AvSx3("EXV_PEDIDO" ,AV_TITULO)},;
                  {{|| WKEXV->EXV_PREEMB  },"",AvSx3("EXV_PREEMB" ,AV_TITULO)},;
                  {{|| WKEXV->EXV_QTD     },"",AvSx3("EXV_QTD"    ,AV_TITULO)} }
   
   If EasyEntryPoint("EECAM100")   // By JPP - 18/11/2009
      ExecBlock("EECAM100",.F.,.F.,{ "ANTES_TELA_PRINCIPAL" })
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0011 FROM DLG_LIN_INI,DLG_COL_INI ; //"Cadastro de Amostras"
   					                    TO DLG_LIN_FIM,DLG_COL_FIM   ;
   										OF oMainWnd PIXEL 
      oDlg:lMaximized := .T.                                 
      aPosCap:= PosDlgUp(oDlg)
      aPosCap[3] += 30
      aPosDet := PosDlgDown(oDlg)
      aPosDet[1] += 30 
      
      //EnChoice( cAlias, nReg, nOpc,,,, ,aPosCap, )
      EnChoice( cAlias, nReg, nOpc,,,,aMostra,aPosCap     ,aAltera)
      
      
      oMsSelectCp := MsSelect():New("WKEXV",,,aCposBrowseCp,,,aPosDet) 
      
      @200,200 MsGet oGet_x Var cGet_x Of oDlg
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If !lOk .Or. nOpc == VISUALIZAR        
      Break
   EndIf
   //Efetua a gravação dos dados
   Am100Grava(nOpc)
   
End Sequence

If Select("WKEXV") > 0
   WKEXV->(avzap())
EndIf
If Select("WKITENS") > 0
   WKITENS->(avzap())
EndIf
If Select("WKQUAL") > 0
   WKQUAL->(avzap())
EndIf

Return Nil

/*
Funcao      : AM100DETMAN()
Parametros  : nOpc
Retorno     : Nenhum
Objetivos   : Selecionar itens que serão vinculados a amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/10/05 - 14:15
Obs.        :
*/                            

*-------------------------*
Function AM100DETMAN(nOpc)
*-------------------------*
Local oDlg                             
Local aButtons := {{"LBTIK",{|| MarcaTodos()},STR0035}} //"Marca/Desmarca Todos"
Local nInc
Private lOk := .F.
Private lInverte := .F.
Private aGets[0],aTela[0]

Begin Sequence
   If cTipoAm == "P"
      MsgInfo(STR0062, STR0051)//"Opção disponível apenas para amostras por embarque"###"Atenção"
      lRet := .F.
      Break
   EndIf
   If !Am100Valid("OBRIGATORIOS")
      Break
   EndIf
   If !AM100WKEMB()
      MsgInfo(STR0014, STR0055)//"Não foram encontrados embarques que correspondam às características da amostra."###"Alerta"
      Break
   EndIf
   
   aCposBrowse:={{"WK_MARCA",""," "}}
   aAdd(aCposBrowse, {{|| WKITENS->EXV_PREEMB },"",AvSx3("EXV_PREEMB" ,AV_TITULO)})
   aAdd(aCposBrowse, {{|| WKITENS->EXV_QTD    },"","Quantidade Vinc."            })
   aAdd(aCposBrowse, {{|| WKITENS->WK_SLDINI },"","Saldo a Vinc."               })
                  
   DEFINE MSDIALOG oDlg TITLE STR0015 FROM DLG_LIN_INI,DLG_COL_INI ; //"Seleção de embarques"
   					                    TO DLG_LIN_FIM,DLG_COL_FIM   ;
   									    OF oMainWnd PIXEL 
   

   oMsSelect := MsSelect():New("WKITENS","WK_MARCA",,aCposBrowse,@lInverte,@cMarca,PosDlg(oDlg))
   oMsSelect:bAval := {|| MarcaEXV(If(Empty(WKITENS->WK_MARCA),GetQtde(WKITENS->WK_SLDINI),)) }
  
   bOk := {|| oDlg:End(), lOk := .T.}                            
   bCancel := {|| oDlg:End()}
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
   
   If !lOk
      Break
   EndIf
   
   WKITENS->(DbSetFilter({|| WKITENS->WK_MARCA <> Space(2)}, "WKITENS->WK_MARCA <> Space(2)" ))
   WKITENS->(DbGoTop())
   WKEXV->(avzap())
   While WKITENS->(!Eof())
      WKEXV->(RecLock("WKEXV",.T.))
      WKEXV->EXV_NROAMO := M->EXU_NROAMO
      WKEXV->EXV_PEDIDO := M->EXU_PEDIDO
      WKEXV->EXV_PREEMB := WKITENS->EXV_PREEMB
      WKEXV->EXV_QTD    := WKITENS->EXV_QTD
      WKEXV->WK_RECNO   := WKITENS->WK_RECNO
      WKITENS->(DbSkip())
   EndDo
   WKITENS->(DbClearFilter())
   WKEXV->(DbGoTop())
   
   If IsVazio("WKEXV")
      lAltera := .T.
   Else
      lAltera := .F.
   EndIf
   
End Sequence

Return Nil

/*
Funcao      : AM100WKEMB()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Alimentar Work com embarques disponíveis para amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05 - 11:00
Obs.        :
*/                            

*--------------------*
Function AM100WKEMB()
*--------------------*
Local lRet := .T.
Local aEEC := {}
Local nInc, nSaldo, x

Begin Sequence
   aSemSx3 := {{"WK_RECNO" ,"N",10,0},;
               {"WK_MARCA" ,"C", 2,0},;
               {"WK_SLDINI","N",15,3}}
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   If Select("WKITENS") == 0
      cNomArq2 := EXV->(E_CriaTrab("EXV",aSemSx3,"WKITENS"))
   EndIf
 
   WKITENS->(avzap())
   EE9->(DbSetOrder(1))
   EE9->(DbSeek(xFilial("EE9")+M->EXU_PEDIDO))
   While EE9->(!Eof()) .And. xFilial("EE9") == EE9->EE9_FILIAL .And. EE9->EE9_PEDIDO == M->EXU_PEDIDO
      If EE9->(EE9_CODQUA+EE9_CODPEN+EE9_CODTIP+EE9_CODBEB) == M->(EXU_CODQUA+EXU_CODPEN+EXU_CODTIP+EXU_CODBEB)
         x := ASCAN(aEEC, {|x| x[1] = EE9->EE9_PREEMB} )
         If x == 0
            AADD(aEEC, {EE9->EE9_PREEMB, EE9->EE9_SLDINI})
         Else
            aEEC[x][2] += EE9->EE9_SLDINI
         EndIf
      EndIf
      EE9->(DbSkip())
   EndDo

   EEC->(DbSetOrder(1))
   For nInc := 1 To Len(aEEC)

      If (nSaldo := Am100Saldo(M->EXU_PEDIDO, aEEC[nInc][1], M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, EXU_CODBEB, M->EXU_NROAMO, "E")) <= 0
         Loop
      EndIf
      
      If EEC->(DbSeek(xFilial("EEC")+aEEC[nInc][1]))
         If EEC->EEC_STATUS <> ST_PC .And. EEC->EEC_ENVAMO $ SIM
            WKITENS->(DbAppend())
            WKITENS->EXV_PREEMB := EEC->EEC_PREEMB
            WKITENS->WK_SLDINI := nSaldo
            WKITENS->TRB_ALI_WT:= "EEC"
            WKITENS->TRB_REC_WT:= EEC->(Recno())
         EndIf
      EndIf

   Next

   If IsVazio("WKITENS")
      lRet := .F.
      Break
   EndIf

   WKITENS->(DbGoTop())
   WKEXV->(DbGoTop())
   IndRegua("WKITENS",cNomArq2+TEOrdBagExt(),"EXV_PREEMB")
   M->EXU_QTD := 0
   While WKEXV->(!Eof())
      If WKITENS->(DbSeek(WKEXV->EXV_PREEMB))
         WKITENS->WK_MARCA  := cMarca
         WKITENS->WK_SLDINI -= WKEXV->EXV_QTD
         M->EXU_QTD         += WKEXV->EXV_QTD
         WKITENS->EXV_QTD   := WKEXV->EXV_QTD
         WKITENS->WK_RECNO  := WKEXV->WK_RECNO
      EndIf
      WKEXV->(DbSkip())
   EndDo   
   
   WKITENS->(DbGoTop())
   WKEXV->(DbGoTop())
   
End Sequence
   
Return lRet
     
/*
Funcao      : AM100WKPED()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Verificar se existem itens com a qualidade informada para amostra por pedido e gerar work.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 20/01/06 - 14:15
Obs.        :
*/                            

*--------------------*
Function AM100WKPED()
*--------------------*
Local lRet := .T.

Begin Sequence

   /*
   EE9->(DbSetOrder(1))
   If EE9->(DbSeek(xFilial("EE9")+M->EXU_PEDIDO))
      MsgInfo(StrTran(STR0057, "###", AllTrim(M->EXU_PEDIDO)), STR0055)//"O pedido ### possui item(ns) embarcado(s), tornando possível somente o envio de amostra do tipo 'Amostra por Embarque'."###"Alerta"
      lRet := .F.
      Break
   EndIf
   */
   
   If (nSaldo := Am100Saldo(M->EXU_PEDIDO, , M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, "P")) <= 0
      MsgInfo(STR0090,STR0055)//"O pedido informado não pode ser utilizado porque não possui saldo disponível para lançamento de amostra."###"Alerta"
      lRet := .F.
      Break
   ElseIf nSaldo < M->EXU_QTD
      MsgInfo(STR0091, STR0055)//"A quantidade informada é maior que o saldo do pedido disponível para amostra."###"Alerta"
      lRet := .F.
      Break
   EndIf
   
   WKEXV->(DbGoTop())
   If(nOpcao==INCLUIR, (WKEXV->(avzap()), WKEXV->(DbAppend())),)
   WKEXV->EXV_NROAMO := M->EXU_NROAMO
   WKEXV->EXV_PEDIDO := M->EXU_PEDIDO
   WKEXV->EXV_QTD    := M->EXU_QTD

End Sequence

Return lRet

/*
Funcao      : MarcaEXV
Parametros  : nQtde -> Quantidade a ser vinculada
Retorno     : Nenhum
Objetivos   : Vincula um item a amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function MarcaEXV(nQtde)
*------------------------------*
Local nInd

If WKITENS->WK_MARCA <> Space(2)
   WKITENS->WK_MARCA  := Space(2)
   WKITENS->WK_SLDINI += WKITENS->EXV_QTD
   M->EXU_QTD         -= WKITENS->EXV_QTD
   WKITENS->EXV_QTD   := 0
   
   If !Empty(WKITENS->WK_RECNO)
      AADD(aDeletados, WKITENS->WK_RECNO)
   EndIf
Else
   If !Empty(WKITENS->(WK_RECNO)) .And. (nInd := aScan(aDeletados, WKITENS->WK_RECNO)) > 0
      aDel(aDeletados, nInd)
      aSize(aDeletados, Len(aDeletados)-1)
   EndIf
   If nQtde > 0
      WKITENS->WK_MARCA  := cMarca
      WKITENS->EXV_QTD   := nQtde
      WKITENS->WK_SLDINI -= nQtde
      M->EXU_QTD         += nQtde
   EndIf
EndIf

Return Nil

/*
Funcao      : MarcaTodos
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vincular todos os embarques disponíveis para amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function MarcaTodos()
*---------------------------*

Begin Sequence
   WKITENS->(DbGoTop())
   If !Empty(WKITENS->WK_MARCA)
      While WKITENS->(!EOF())
         If WKITENS->WK_MARCA <> Space(2)
            MarcaEXV()
         EndIf   
         WKITENS->(DbSkip())
      EndDo
   Else
      While WKITENS->(!EOF())
         If WKITENS->WK_MARCA == Space(2)
            MarcaEXV(WKITENS->WK_SLDINI)
         EndIf
         WKITENS->(DbSkip())
      EndDo
   EndIf
End Sequence   
WKITENS->(DbGoTop())   
oMsSelect:oBrowse:Refresh()

Return Nil

/*
Funcao      : GetQtde
Parametros  : nQtde  -> Saldo a vincular do item em questão.
Retorno     : lOk
Objetivos   : Possibilitar que o usuário informe a quantidade a ser vinculada do item.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 04/04/06
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function GetQtde(nQtde)
*-----------------------------*
Local oDlg
Local lOk       := .F.
Local bOk       := {|| If ((Eval(bValidSup) .And. Eval(bValidSup)),(lOk := .T., oDlg:End()), )} 
Local bCancel   := {|| oDlg:End() } 
Local bValidSup := {|| (If ((nQtde > nSaldo),(MsgInfo(STR0092,STR0055),.F.),.T.))}//"Quantidade superior a Permitida" ### "Atenção"
Local bValidInf := {|| (If ((nQtde <= 0),(MsgInfo(STR0093,STR0055),.F.),.T.))}//"Quantidade inferior a Permitida" ### "Atenção"
Local nSaldo    := nQtde
Local oPanel
Begin Sequence

    Define MsDialog oDlg Title "Controle de Saldo" From 1,1 To 150,380 Of oMainWnd Pixel//"Controle de Saldo"
    
    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  

    @ 1,4  To 38,187 Label "Indique a quantidade a ser vinculada" Pixel of oPanel//"Indique a quantidade a ser vinculada"
    @ 10,10  Say "Saldo:" Pixel Of oPanel//"Saldo:"
    @ 9,60 MsGet nSaldo Size 70,07 Picture "@E 999,999,999,999.99" When .F. Pixel Of oPanel
    @ 22,10  Say "Total a vincular:" Pixel Of oPanel//"Total a vincular:"
    @ 21,60 MsGet nQtde  Size 70,07 Picture "@E 999,999,999,999.99" Valid Positivo(nQtde) Pixel Of oPanel

    Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

    If !lOk
       nQtde := 0
       Break
    EndIf

End Sequence

Return nQtde

/*
Funcao      : Am100Grava
Parametros  : nOpc  -> Indica a opção desejada
              cTipo -> Tipo da Amostra ("E"-> Amostra por Embarque, "P"->Amostra por Pedido) 
Retorno     : Nenhum
Objetivos   : Efetua a inclusão/alteração/exclusão da Amostra
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 12/01/06 - 11:00
Obs.        :
*/

*-------------------------------*
Function Am100Grava(nOpc, cTipo)
*-------------------------------*
Local nInc

Begin Sequence
   Begin Transaction

      If EasyEntryPoint("EECAM100")   // By JPP - 18/11/2009
         ExecBlock("EECAM100",.F.,.F.,{ "GRAVACAO_INICIO",nOpc})
      EndIf
   
      If nOpc == INCLUIR
         
         EXU->(RecLock("EXU",.T.))
         WKEXV->(DbGoTop())
         While WKEXV->(!Eof())
            EXV->(RecLock("EXV",.T.))
            AvReplace("WKEXV","EXV")
            EXV->(MsUnlock())
            WKEXV->(DbSkip())
         EndDo
         AvReplace("M","EXU")
         MSMM(,TAMSX3("EXU_DSCQUA")[1],,M->EXU_DSCQUA,INCMEMO,,,"EXU","EXU_QUADES")
         MSMM(,TAMSX3("EXU_DSCOBS")[1],,M->EXU_DSCOBS,INCMEMO,,,"EXU","EXU_OBS")         
         EXU->(MsUnlock())
         
      ElseIf nOpc == ALTERAR
         EXU->(RecLock("EXU",.F.))
         For nInc := 1 To Len(aDeletados)
            EXV->(DbGoTo(aDeletados[nInc]))
            EXV->(RecLock("EXV",.F.))
            EXV->(DbDelete())
            EXV->(MsUnlock())
         Next
         
         WKEXV->(DbGoTop())
         While WKEXV->(!Eof())
            If Empty(WKEXV->WK_RECNO)
               EXV->(RecLock("EXV",.T.))
            Else
               EXV->(DbGoTo(WKEXV->WK_RECNO))
               EXV->(RecLock("EXV",.F.))
            EndIf
            AvReplace("WKEXV","EXV")
            EXV->(MsUnlock())
            WKEXV->(DbSkip())
         EndDo
         AvReplace("M","EXU")
         MSMM(EXU->EXU_QUADES,,,,EXCMEMO)
         MSMM(EXU->EXU_OBS,,,,EXCMEMO)
         MSMM(,TAMSX3("EXU_DSCQUA")[1],,M->EXU_DSCQUA,INCMEMO,,,"EXU","EXU_QUADES")
         MSMM(,TAMSX3("EXU_DSCOBS")[1],,M->EXU_DSCOBS,INCMEMO,,,"EXU","EXU_OBS")
         EXU->(MsUnlock())

      ElseIf nOpc == EXCLUIR
         EXU->(RecLock("EXU",.F.))
         EXV->(DbSetOrder(1))
         EXV->(DbSeek(xFilial("EXV")+EXU->EXU_NROAMO))
         While EXV->EXV_FILIAL == xFilial("EXV") .And. EXV->EXV_NROAMO == EXU->EXU_NROAMO
            EXV->(RecLock("EXV",.F.))
            EXV->(DbDelete())
            EXV->(MsUnlock())
            EXV->(DbSkip())
         EndDo
         MSMM(EXU->EXU_QUADES,AVSX3("EXU_DSCQUA",AV_TAMANHO),,,EXCMEMO)
         MSMM(EXU->EXU_OBS,AVSX3("EXU_DSCOBS",AV_TAMANHO),,,EXCMEMO)
         EXU->(DbDelete())
         EXU->(MsUnlock())

      EndIf
             
      If EasyEntryPoint("EECAM100")   // By JPP - 18/11/2009
         ExecBlock("EECAM100",.F.,.F.,{ "GRAVACAO_FIM",nOpc})
      EndIf
      
   End Transaction
End Sequence

Return Nil

/*
Funcao      : Am100ListAmo
Parametros  : cPedido  -> Numero do Pedido
              cQual    -> Código da Qualidade
              cPen     -> Código da Peneira
              cTipo    -> Código do Tipo
              cBebida  -> Código da Bebida
              cNotList -> Código da Amostra que não deve ser considerada
              cStatus  -> Código do Status das amostras desejadas
              cTipo    -> Tipo de amostra a ser considerada. "E" = Amostras por embarque, "P" = Amostras por pedido
Retorno     : aAmostra -> {{"Numero da Amostra", "Data de Envio"}}
Objetivos   : Retornar array com todas as amostras lançadas para determinado pedido. Se informados código da Qualidade 
              e/ou código da Peneira e/ou código do Tipo e/ou código da Bebida e/ou código do Status, retorna somente amostras com as mesmas informações
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 23/01/06 - 17:00
Obs.        :
*/                    
*-----------------------------------------------------------------------------------------------------*
Function Am100ListAmo(cPedido, cPreemb, cQual, cPen, cTipo, cBebida, cNotList, cStatus, cTipoAm, cFil)
*-----------------------------------------------------------------------------------------------------*
Local aOrd := SaveOrd({"EXV","EXU"})
Local aAmostra := {}
Local nTotVinc := 0
Default cPreemb := ""
Default cFil := xFilial("EXU")
Begin Sequence
   
   cFil := Avkey(cFil,"EXU_FILIAL")

   EXU->(DbSetOrder(1))
   EXV->(DbSetOrder(2))
   If EXV->(DbSeek(cFil+cPedido+cPreemb))
      While EXV->(!Eof() .And. EXV_FILIAL+EXV_PEDIDO == cFil+cPedido .And. If(!Empty(cPreemb), EXV_PREEMB == cPreemb, .T.))
         If EXV->EXV_NROAMO == cNotList
            EXV->(DbSkip())
            Loop
         EndIf
         EXU->(DbSeek(cFil+EXV->EXV_NROAMO))
         If (ValType(cTipoAm) == "C" .And. EXU->EXU_TIPOAM <> cTipoAm)   .Or.;
            (ValType(cStatus) == "C" .And. !(EXU->EXU_STATUS $ cStatus)) .Or.;
            (ValType(cQual)   == "C" .And. cQual <> EXU->EXU_CODQUA)     .Or.;
            (ValType(cPen)    == "C" .And. cPen <> EXU->EXU_CODPEN)      .Or.;
            (ValType(cTipo)   == "C" .And. cTipo <> EXU->EXU_CODTIP)     .Or.;
            (ValType(cBebida) == "C" .And. cBebida <> EXU->EXU_CODBEB)
               EXV->(DbSkip())
               Loop
         EndIf
         If (x := aScan(aAmostra, {|x| x[1] == EXV->EXV_NROAMO})) == 0
            aAdd(aAmostra, {EXU->EXU_NROAMO, EXU->EXU_DTENV, EXU->EXU_STATUS, EXV->EXV_QTD})
         Else
            aAmostra[x][4] += EXV->EXV_QTD
         EndIf
         EXV->(DbSkip())
      EndDo
   EndIf
   
End Sequence

RestOrd(aOrd, .T.)
                     
Return aAmostra

/*
Funcao      : Am100Saldo
Parametros  : cPedido, cPreemb, cQual, cPen, cTipo, cBebida, 
              cNotList -> Numero da amostra a não ser considerada na apuração, 
              cTipo -> Tipo de amostra a ser considerada. "E" = Amostras por embarque, "P" = Amostras por pedido
Retorno     : nSaldo -> Saldo da qualidade/Saldo total a vincular do pedido/embarque
Objetivos   : Retornar o saldo a vincular de uma determinada qualidade. Quando não for informada uma qualidade, 
              o sistema busca todas as qualidades lançadas para o pedido/embarque informado e retorna o saldo a vincular para todas as qualidades
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/04/06
Obs.        :
*/                            

*-----------------------------------------------------------------------------------------*
Function Am100Saldo(cPedido, cPreemb, cQual, cPen, cTipo, cBebida, cNotList, cTipoAm,cFil)
*-----------------------------------------------------------------------------------------*
Local aOrd := SaveOrd({"EE8", "EE9"}),;
      aQualidade := {}
Local nTotalVinc := 0,;
      nTotalItem := 0,;
      nInc, nInc2, nInd

Local cAlias

Private lValidaSaldo := .T.

Default cFil := xFilial("EXU")

Begin Sequence
      cFil := Avkey(cFil,"EXU_FILIAL")

      If ValType(cPedido) == "C"
         If ValType(cPreemb) == "C"
            EE9->(DbSetOrder(2))
            If !EE9->(DbSeek(xFilial()+cPreemb+cPedido))
               Break
            EndIf
            cWhile := "EE9->(!Eof() .And. EE9_FILIAL+EE9_PEDIDO+EE9_PREEMB == '" + xFilial("EE9") + cPedido + cPreemb + "')"
            cAlias := "EE9"
         Else
            EE8->(DbSetOrder(1))
            If !EE8->(DbSeek(xFilial()+cPedido))
               Break
            EndIf
            cWhile := "EE8->(!Eof() .And. EE8_FILIAL+EE8_PEDIDO == '" + xFilial("EE8") + cPedido + "')"
            cAlias := "EE8"
         EndIf
      ElseIf ValType(cPreemb) == "C"
         EE9->(DbSetOrder(2))
         If !EE9->(DbSeek(xFilial()+cPreemb))
            Break
         EndIf
         cWhile := "EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == '" + xFilial("EE9") + cPreemb + "')"
         cAlias := "EE9"
      Else
         Break
      EndIf     
      While &(cWhile)
         If (ValType(cQual) == "C" .And. (cAlias)->&(cAlias + "_CODQUA") <> cQual)
            (cAlias)->(DbSkip())
            Loop
         EndIf
         If (ValType(cPen)  == "C" .And. (cAlias)->&(cAlias + "_CODPEN") <> cPen)
            (cAlias)->(DbSkip())
            Loop
         EndIf
         If (ValType(cTipo) == "C" .And. (cAlias)->&(cAlias + "_CODTIP") <> cTipo)
            (cAlias)->(DbSkip())
            Loop
         EndIf
         If (ValType(cBebida) == "C" .And. (cAlias)->&(cAlias + "_CODBEB") <> cBebida)
            (cAlias)->(DbSkip())
            Loop
         EndIf
         //Adiciona no array as diferentes qualidades encontradas no pedido/embarque
         If (nInd := (cAlias)->(aScan(aQualidade, {|x| x[1] == &(cAlias + "_CODQUA");
                                      .And. x[2] == &(cAlias + "_CODPEN");
                                      .And. x[3] == &(cAlias + "_CODTIP");
                                      .And. x[4] == &(cAlias + "_CODBEB")})) ) == 0

            (cAlias)->(aAdd(aQualidade, {&(cAlias + "_CODQUA"),;
                                         &(cAlias + "_CODPEN"),;
                                         &(cAlias + "_CODTIP"),;
                                         &(cAlias + "_CODBEB"),;
                                         {{&(cAlias + "_PEDIDO"), &(cAlias + "_SLDINI"), &(cAlias + "_SLDINI")}}}))

         Else
            //Adiciona os pedidos com a qualidade informada e a quantidade vinculada
            If (nInd2 := aScan(aQualidade[nInd][5], {|x| x[1] == (cAlias)->&(cAlias + "_PEDIDO")})) == 0
              (cAlias)->(aAdd(aQualidade[nInd][5], {&(cAlias + "_PEDIDO"), &(cAlias + "_SLDINI"), &(cAlias + "_SLDINI")}))
            Else
               aQualidade[nInd][5][nInd2][2] += (cAlias)->&(cAlias + "_SLDINI")
               aQualidade[nInd][5][nInd2][3] += (cAlias)->&(cAlias + "_SLDINI")
            EndIf
         EndIf
         (cAlias)->(DbSkip())
      EndDo
      For nInc := 1 To Len(aQualidade)
         For nInc2 := 1 To Len(aQualidade[nInc][5])
         
            If EasyEntryPoint("EECAM100") //DRL 20/01/2009 - Alterado para Utilizacao no ponto de entrada, para controle de novos Status
               ExecBlock("EECAM100",.F.,.F.,{"APROVACAO_SALDO"})
            EndIf
   
            If lValidaSaldo
         
               //Calcula o total vinculado para as qualidades informadas
               aEXU := Am100ListAmo(aQualidade[nInc][5][nInc2][1],;
                                    If(ValType(cPreemb) == "C",cPreemb,Nil),;
                                    aQualidade[nInc][1],;
                                    aQualidade[nInc][2],;
                                    aQualidade[nInc][3],;
                                    aQualidade[nInc][4],;
                                    If(ValType(cNotList) == "C",cNotList,Nil),;
                                    STAM_AP,;
                                    If(ValType(cTipoAm) == "C",cTipoAm,Nil),;
                                    cFil)

               aEval(aEXU, {|x| aQualidade[nInc][5][nInc2][3] -= x[4], nTotalVinc += x[4] })

            EndIf
            
            //Calcula a quantidade total de itens com a qualidade informada
            nTotalItem += aQualidade[nInc][5][nInc2][2]
         Next
      Next
      If Type("aSldEmb") == "A" .And. Len(aSldEmb) == 0
         aSldEmb := aClone(aQualidade)
      EndIf
      
End Sequence
RestOrd(aOrd, .T.)

Return (nTotalItem - nTotalVinc)

/*
Funcao      : Am100AprvAmo
Parametros  : Nenhum.
Retorno     : lRet -> Indica se a amostra está pronta para ser aprovada, descartando as amostras excedentes.
Objetivos   : Prepara uma amostra para aprovação, verificando se existe saldo para todos os itens e 
              se existem amostras similares que precisam ser descartadas.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 04/04/06 - 17:00
Obs.        :
*/
*----------------------*
Function Am100AprvAmo()
*----------------------*
Local aOrd := SaveOrd({"EXU", "EXV", "WKEXV"}),;
      aDescarte := {},;
      aSaldo := {},;
      aMsg := {}
      
Local nSaldo := 0, nInc

Local lRet := .T.,;
      lSaldo := .T.

Private lValidaSaldo := .T.
Private lDescarta    := .T.

Begin Sequence

   If cTipoAm == "P"
      If (nSaldo := Am100Saldo(M->EXU_PEDIDO, , M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, "P")) - M->EXU_QTD == 0
         aDescarte := Am100ListAmo(M->EXU_PEDIDO, , M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, STAM_EN+STAM_NE/*+STAM_RJ*/, "P")
      ElseIf nSaldo - M->EXU_QTD < 0
         aHeader := {{"EXV_PEDIDO",,,,,}, {"EXV_QTD",,"Saldo",,,}, {"EXV_QTD",,"Quantidade Vinculada",,,}}
         M->(aAdd(aSaldo, {EXU_PEDIDO, nSaldo, EXU_QTD}))
      EndIf

   ElseIf cTipoAm == "E"
      WKEXV->(DbGoTop())
      While WKEXV->(!Eof())
         If (nSaldo := Am100Saldo(M->EXU_PEDIDO, WKEXV->EXV_PREEMB, M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, "E")) - WKEXV->EXV_QTD == 0 .And. lSaldo
            aEmb := Am100ListAmo(M->EXU_PEDIDO, WKEXV->EXV_PREEMB, M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, STAM_EN+STAM_NE/*+STAM_RJ*/, "E")
            For nInc := 1 To Len(aEmb)
               If aScan(aDescarte, {|x| x[1] == aEmb[nInc][1]}) == 0
                  aAdd(aDescarte, aEmb[nInc])
               EndIf
            Next
         ElseIf nSaldo - M->EXU_QTD < 0
            lSaldo := .F.
            aHeader := {{"EXV_PREEMB",,,,,}, {"EXV_QTD",,STR0096,,,}, {"EXV_QTD",,STR0097,,,}}//"Saldo"###"Quantidade Vinculada"
            WKEXV->(aAdd(aSaldo, {EXV_PREEMB, nSaldo, EXV_QTD}))
         EndIf
         WKEXV->(DbSkip())
      EndDo
   EndIf
   
   If EasyEntryPoint("EECAM100") //DRL 20/01/2009 - Alterado para Utilizacao no ponto de entrada, para controle de novos Status
      ExecBlock("EECAM100",.F.,.F.,{"APROVACAO_SALDO"})
   EndIf
   
   If Len(aSaldo) > 0 .And. lValidaSaldo
      aAdd(aMsg, {STR0095, .T.})//"Não é possível efetivar a amostra, pois a quantidade vinculada é superior ao saldo."
      aAdd(aMsg, {ENTER, .F.})
      aAdd(aMsg, {EECMontaMsg(aHeader, aSaldo,,.F.) + ENTER, .F.})
      EECView(aMsg, STR0011)//"Manutenção de Amostras"        
      lRet := .F.
      Break
         
   ElseIf Len(aDescarte) > 0 .And. lDescarta
      aAdd(aMsg, {STR0081, .T.})//"Existem amostras iguais cadastradas no sistema. Para prosseguir, as seguintes amostras serão descartadas:"
      aAdd(aMsg, {ENTER, .F.})
      aAdd(aMsg, {EECMontaMsg({"EXU_NROAMO", "EXU_DTENV"}, aDescarte,,.F.) + ENTER, .F.})
      aAdd(aMsg, {STR0082, .T.})//"Confirma aprovação da amostra?"
      If !EECView(aMsg, STR0011)//"Manutenção de Amostras"
         lRet := .F.
         Break
      EndIf

      EXU->(DbSetOrder(1))
      For nInc := 1 To Len(aDescarte)
         If EXU->(DbSeek(xFilial("EXU")+aDescarte[nInc][1]))
            EXU->(RecLock("EXU", .F.))
            EXU->EXU_STATUS := STAM_DC
         EndIf
      Next
   EndIf

End Sequence
RestOrd(aOrd, .T.)

Return lRet

/*
Funcao      : AM100CPQUAL
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Copia informações de qualidade/peneira/tipo/bebida
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*---------------------*
Function AM100CPQUAL()
*---------------------*
Local oDlg, lOk := .F., aSemSx3 := {}

Begin Sequence
   
   If Empty(M->EXU_PEDIDO)
      MsgInfo(STR0028, STR0051)//"Favor informar número do pedido." ### "Atenção"
      Break
   EndIf
   
   If !lAltera
      MsgInfo(STR0063, STR0051)//"Não é possível alterar as informações de qualidade/peneira/tipo/bebida pois a amostra possui itens vinculados"###"Atenção"
      Break
   EndIf
   aCampos := {"EE8_PEDIDO","EE8_SEQUEN","EE8_CODQUA","EE8_CODPEN",;
               "EE8_DSCPEN","EE8_CODTIP","EE8_DSCTIP", "EE8_CODBEB", "EE8_DSCBEB"}
   
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("EE8_QUADES"))
      If X3Uso(SX3->X3_USADO) 
         aAdd(aCampos,"EE8_QUADES")
      Else
         AddNaoUsado(aSemSx3,"EE8_QUADES")
      EndIf
   EndIf
   
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   If Select("WKQUAL") == 0
      cNomArq3 := E_CriaTrab(,aSemSx3,"WKQUAL")
   EndIf
 
   WKQUAL->(avzap())
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+M->EXU_PEDIDO))
   While EE8->(!Eof()) .And. xFilial("EE8") == EE8->EE8_FILIAL .And. EE8->EE8_PEDIDO == M->EXU_PEDIDO
      WKQUAL->(RecLock("WKQUAL",.T.))
      AvReplace("EE8","WKQUAL")
      WKQUAL->(MsUnlock())
      EE8->(DbSkip())
   EndDo
   WKQUAL->(DbGoTop())
   
   aCposBrowse:={ {{|| WKQUAL->EE8_PEDIDO },"",AvSx3("EE8_PEDIDO" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_SEQUEN },"",AvSx3("EE8_SEQUEN" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_CODQUA },"",AvSx3("EE8_CODQUA" ,AV_TITULO)},;
                  {{|| MSMM(WKQUAL->EE8_QUADES,AVSX3("EXU_DSCQUA",AV_TAMANHO),,,LERMEMO)},"",AvSx3("EE8_DSCQUA" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_CODPEN },"",AvSx3("EE8_CODPEN" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_DSCPEN },"",AvSx3("EE8_DSCPEN" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_CODTIP },"",AvSx3("EE8_CODTIP" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_DSCTIP },"",AvSx3("EE8_DSCTIP" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_CODBEB },"",AvSx3("EE8_CODBEB" ,AV_TITULO)},;
                  {{|| WKQUAL->EE8_DSCBEB },"",AvSx3("EE8_DSCBEB" ,AV_TITULO)} }
   
   DEFINE MSDIALOG oDlg TITLE STR0029 FROM DLG_LIN_INI,DLG_COL_INI ; //"Cópia de informações"
   					                  TO DLG_LIN_FIM,DLG_COL_FIM   ;
           							  OF oMainWnd PIXEL 

   oMsSelect := MsSelect():New("WKQUAL",,,aCposBrowse,,,PosDlg(oDlg))    
   oMsSelect:bAval := {|| (oDlg:End(), lOk := .T.) }   
   
   bOk := {|| (oDlg:End(), lOk := .T.)}
   bCancel := {|| oDlg:End()}
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   
   If !lOk
      Break
   EndIf
   
   M->EXU_CODQUA := WKQUAL->EE8_CODQUA
   M->EXU_DSCQUA := MSMM(WKQUAL->EE8_QUADES,AVSX3("EXU_DSCQUA",AV_TAMANHO),,,LERMEMO)
   M->EXU_CODTIP := WKQUAL->EE8_CODTIP
   M->EXU_DSCTIP := WKQUAL->EE8_DSCTIP
   M->EXU_CODPEN := WKQUAL->EE8_CODPEN
   M->EXU_DSCPEN := WKQUAL->EE8_DSCPEN
   M->EXU_CODBEB := WKQUAL->EE8_CODBEB
   M->EXU_DSCBEB := WKQUAL->EE8_DSCBEB
   oGet_x:SetFocus()
    
 End Sequence

Return Nil

/*
Funcao      : Am100SendMail
Parametros  : cFrom, cTo, cCC, cSubject, cMsg
Retorno     : lRet
Objetivos   : Enviar e-mail
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 14/02/06
Revisao     :
Obs.        :
*/
*------------------------------------------------------------*
Function Am100SendMail(cFrom, cTo, cCC, cSubject, cMsg, cBCC)
*------------------------------------------------------------*

Local cServer     := AllTrim(GetNewPar("MV_RELSERV"," ")) // "mailhost.average.com.br" //Space(50)
Local cAccount    := AllTrim(GetNewPar("MV_RELACNT"," ")) //Space(50)
Local cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," "))  //Space(50)
Local nTimeOut    := EasyGParam("MV_RELTIME",,120)//Tempo de Espera antes de abortar a Conexão
Local lAutentica  := EasyGParam("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local cUserAut    := Alltrim(EasyGParam("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
Local cPassAut    := Alltrim(EasyGParam("MV_RELAPSW",,cPassword))//Senha para Autenticação no Servidor de Email
Local lRelTLS     := GetMV("MV_RELTLS")
Local lRelSLS     := GetMV("MV_RELSSL")
Local cRelPor     := GetMV("MV_PORSMTP")
Local cError      := ""
Local lRet        := .T. 

   If Empty(cServer) 
      cServer    := EasyGParam("MV_WFSMTP")
   endif
   if Empty(cAccount)
      cAccount   := EasyGParam("MV_WFACC")
   endif
   If Empty(cPassword)
      cPassword  := EasyGParam("MV_WFPASSW")
   endif

   if at(":",cServer) > 0
      if Empty(cRelPor)
         cRelPor := val( Substr( cServer , at(":",cServer)+1 , len(cServer) ) )
      endif
      cServer := Substr( cServer , 1 , at(":",cServer)-1 )
   endif

   Begin Sequence

      If !Empty(cServer) .and. !Empty(cAccount)
         oMail := TMailManager():New()
         if lRelSLS
            oMail:SetUseSSL( .T. )
         endif
         if lRelTLS
            oMail:SetUseTLS( .T. )
         endif
         oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
         oMail:SetSmtpTimeOut( nTimeOut )

         nErro := oMail:SmtpConnect()
         if nErro <> 0
            cError := oMail:GetErrorString( nErro )
            MsgInfo(STR0033+cError+STR0031+cSubject+STR0032, STR0055) //"Erro na conexão com o servidor de Email - " # " O e-mail '" # "' não pôde ser enviado."
            lRet := .F.
            break
            // easyhelp("Falha na Conexao com Servidor de E-Mail: "+cError,"Erro")
         Else
            if lAutentica
               nErro := oMail:SmtpAuth( cUserAut,cPassAut )
               If nErro <> 0
                  cError := oMail:GetErrorString( nErro )
                  MsgInfo(STR0080,STR0055)//"Falha na Autenticacao do Usuario"###"Alerta"
                  // easyhelp("Falha na Autenticacao do Usuario: "+cError,"Erro")
                  oMail:SMTPDisconnect()
                  If nErro <> 0
                     cError := oMail:GetErrorString( nErro )
                     lRet := .F.
                     break
                     // easyhelp("Erro na Desconexão: "+cError,"Erro")
                  endif
               endif
            endif

            if nErro == 0
               oMessage := TMailMessage():New()
               oMessage:Clear()
               oMessage:cFrom                  := cFrom
               oMessage:cTo                    := cTo
               oMessage:cCc                    := cCC
               oMessage:cbcc                   := cBCC
               oMessage:cSubject               := cSubject
               oMessage:cBody                  := cMsg

               nErro := oMessage:Send( oMail )
               if nErro <> 0
                  cError := oMail:GetErrorString( nErro )
                  MsgInfo(STR0030+cError+STR0031+cSubject+STR0032, STR0051) //"Erro no envio de Email - " # " O e-mail '" # "' não pôde ser enviado."
                  lRet := .F.
                  break
                  // easyhelp("Falha no Envio de E-Mail: "+cError,"Erro")
               else
                  MsgInfo(STR0046, STR0056)//"E-mail de notificação enviado com sucesso."
               EndIf

               oMail:SMTPDisconnect()
               If nErro <> 0
                  cError := oMail:GetErrorString( nErro )
                  MsgInfo("Erro na Desconexão: "+cError,"Erro")
                  // easyhelp("Erro na Desconexão: "+cError,"Erro")
               endif
            endif
         endif
      Else
         MsgInfo(STR0048, STR0051) //"Não foi possível enviar o e-mail porque o as informações de servidor e conta de envio não estão configuradas corretamente."
         lRet := .F.
      EndIf
      
   End Sequence
   
Return lRet

/*
Funcao      : AM100VALID
Parametros  : cCampo -> Campo a ser validado
Retorno     : lRet
Objetivos   : Validações Gerais.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*----------------------------------*
Function AM100VALID(cCampo, lGrava) 
*----------------------------------*
Local cAliasSts := "EXU"
Local nInc, nRecnoWKAMOSTRA
Private lRet := .T. //DRL 21/01/2009 - Alterado para Private para utilização no Ponto de Entrada
Private cStatus //DRL 20/01/2009 - Alterado para Utilizacao no ponto de entrada, para controle de novos Status
Private cCampoAux := cCampo //DRL 21/01/2009 - Controle da Validação do Campo para utilizacao no ponto de entrada

Begin Sequence

   Do Case
      Case cCampo == "EXU_STADES"
         If Type("M->EXU_STATUS") = "C"
            cAliasSts := "M"
         EndIf 
         Do Case
            Case &(cAliasSts + "->EXU_STATUS") == STAM_NE
               cStatus := STR0017//"Não Enviada."
 
            Case &(cAliasSts + "->EXU_STATUS") == STAM_EN
               cStatus := STR0018//"Enviada."

            Case &(cAliasSts + "->EXU_STATUS") == STAM_AP
               cStatus := STR0019//"Aprovada."

            Case &(cAliasSts + "->EXU_STATUS") == STAM_RJ
               cStatus := STR0020//"Rejeitada."
            Case &(cAliasSts + "->EXU_STATUS") == STAM_DC
               cStatus := STR0066 //"Descartada"
         EndCase
         If EasyEntryPoint("EECAM100") //DRL 20/01/2009 - Alterado para Utilizacao no ponto de entrada, para controle de novos Status
            ExecBlock("EECAM100",.F.,.F.,{"GRV_STATDES"})
         EndIf
         If cAliasSts == "M"
            Return M->EXU_STADES := cStatus
         Else
            Return cStatus
         EndIf

      Case cCampo == "EXU_PEDIDO" // RMD - 24/01/06 - Carrega as informações de qualidade/peneira/tipo/bebida do primeiro item do pedido informado
         If !Empty(M->EXU_PEDIDO)
            If !ExistCpo("EE7")
               lRet := .F.
               Break
            EndIf
            If ValType(cTipoAm) <> "C" .Or. !(cTipoAm $ "P/E")
               MsgInfo(STR0101, STR0051)//"Favor informar o tipo da amostra"###"Atenção"
               lRet := .F.
               Break
            EndIf
            EE7->(DbSetOrder(1))            
            If AvGetM0Fil() == cFilEx .And. EE7->(DbSeek(cFilBr+M->EXU_PEDIDO)) .And. EE7->EE7_INTERM $ SIM
               MsgInfo(STR0099, STR0051)//"Para processos do tipo Off-Shore, as amostras devem ser lançadas pela filial Brasil." ### "Atenção"
               lRet := .F.
               Break
            EndIf
            EE7->(DbSeek(xFilial("EE7")+M->EXU_PEDIDO))
            If (!(EE7->EE7_ENVAMO $ SIM) .And. cTipoAm == "P")
               MsgInfo(STR0065, STR0051)//"O pedido informado não solicita envio de amostra"###"Atenção"
               lRet := .F.
               Break
            EndIf
            EE8->(DbSetOrder(1))
            If EE8->(DbSeek(xFilial("EE8")+M->EXU_PEDIDO))
               M->EXU_CODQUA := EE8->EE8_CODQUA
               M->EXU_DSCQUA := MSMM(EE8->EE8_QUADES,AVSX3("EXU_DSCQUA",AV_TAMANHO),,,LERMEMO)
               M->EXU_CODTIP := EE8->EE8_CODTIP
               M->EXU_DSCTIP := EE8->EE8_DSCTIP
               M->EXU_CODPEN := EE8->EE8_CODPEN
               M->EXU_DSCPEN := EE8->EE8_DSCPEN
               M->EXU_CODBEB := EE8->EE8_CODBEB
               M->EXU_DSCBEB := EE8->EE8_DSCBEB
               oGet_x:SetFocus()
            EndIf
         EndIf
      
      Case cCampo == "EXU_DTENV"
         //If M->EXU_TIPOAM == "E" .And. !Empty(M->EXU_DTENV) .And. IsVazio("WKEXV")
            //MsgInfo(STR0021, STR0051)//"Não é possivel enviar a amostra porque a mesma não possui embarques vinculados."###"Atenção"
            //lRet := .F.
            //Break
         //EndIf
         If Empty(M->EXU_DTENV) .And. !Empty(M->EXU_DTAPRO)
            MsgInfo(STR0022, STR0051)//"Amostra com data de aprovação preenchida."###"Atenção"
            lRet := .F.
            Break
         EndIf
         If Empty(M->EXU_DTENV) .And. !Empty(M->EXU_DTREJE)
            MsgInfo(STR0025, STR0051)//"Amostra rejeitada."###"Atenção"
            lRet := .F.                         
            Break
         EndIf
         AM100VALID("EXU_STATUS")
                 
      Case cCampo == "EXU_DTREJE"
         If !Empty(M->EXU_DTREJE)
            If !Empty(M->EXU_DTAPRO)
               MsgInfo(STR0024, STR0055)//"Amostra aprovada."
               lRet := .F.
               Break      
            EndIf
            If Empty(M->EXU_DTENV)
               MsgInfo(STR0023, STR0055)//"Amostra não enviada."
               lRet := .F.
               Break      
            EndIf            
            If M->EXU_DTENV > M->EXU_DTREJE//JVR - 06/07/09
               MsgInfo(STR0107,STR0055)//"Data de rejeição menor que Data de envio."###"Atenção"
               lRet := .F.
               Break
            EndIf            
            lRej := .T.
         Else
            M->EXU_CLAREJ := Space(2)
            M->EXU_DSCREJ := Space(60)
            lRej := .F.
         EndIf
         AM100VALID("EXU_STATUS")
               
      Case cCampo == "EXU_DTAPRO"
         If !Empty(M->EXU_DTAPRO)
            If !Empty(M->EXU_DTREJE)
               MsgInfo(STR0025, STR0025)//"Amostra rejeitada."
               lRet := .F.
               Break      
            EndIf
            If Empty(M->EXU_DTENV)
               MsgInfo(STR0023, STR0055)//"Amostra não enviada."
               lRet := .F.
               Break      
            EndIf         
         EndIf
         If M->EXU_DTENV > M->EXU_DTAPRO//JVR - 06/07/09
               MsgInfo(STR0108,STR0055)//"Data de aprovação menor que Data de envio."###"Atenção"
               lRet := .F.
               Break
            EndIf            
         AM100VALID("EXU_STATUS")

      
      Case cCampo == "EXU_STATUS"
         If !Empty(M->EXU_DTAPRO)
            M->EXU_STATUS := STAM_AP
            AM100VALID("EXU_STADES")
            Break               
         EndIf
         If !Empty(M->EXU_DTREJE)
            M->EXU_STATUS := STAM_RJ
            AM100VALID("EXU_STADES")
            Break               
         EndIf
         If !Empty(M->EXU_DTENV)
            M->EXU_STATUS := STAM_EN
            AM100VALID("EXU_STADES")
            Break               
         EndIf
         M->EXU_STATUS := STAM_NE
         AM100VALID("EXU_STADES")
      
      Case cCampo == "EXU_QTD"
         If M->EXU_TIPOAM == "E" .Or. Empty(M->EXU_PEDIDO)
            Break
         EndIf
         EE7->(DbSetOrder(1))
            If EE7->(DbSeek(xFilial()+M->EXU_PEDIDO))
               If !(EE7->EE7_ENVAMO $ SIM)
               MsgInfo(STR0065, STR0051)//"O pedido informado não solicita envio de amostra"###"Atenção"
               lRet := .F.
               Break
            EndIf
            lRet := .F.
            If EE8->(DbSeek(xFilial()+M->EXU_PEDIDO))
               While EE8->(EE8_FILIAL+EE8_PEDIDO == xFilial()+M->EXU_PEDIDO)
                  If EE8->(EE8_CODQUA+EE8_CODPEN+EE8_CODTIP+EE8_CODBEB) == M->(EXU_CODQUA+EXU_CODPEN+EXU_CODTIP+EXU_CODBEB)
                     lRet := .T.
                     Exit
                  EndIf
                  EE8->(DbSkip())
               EndDo
            EndIf
         EndIf
         If lRet
            If M->EXU_QTD > Am100Saldo(M->EXU_PEDIDO, , M->EXU_CODQUA, M->EXU_CODPEN, M->EXU_CODTIP, M->EXU_CODBEB, M->EXU_NROAMO, "P")
               MsgInfo(STR0091, STR0055)//"A quantidade informada é superior ao saldo do pedido disponível para lançamento de amostra."###"Alerta"
               lRet := .F.
               Break
            ElseIf !IsVazio("WKEXV")
               WKEXV->(DbGoTop())
               WKEXV->EXV_QTD := M->EXU_QTD
               oMsSelectCp:oBrowse:Refresh()
            EndIf
         Else
            MsgInfo(STR0058, STR0051)//"O pedido informado não possui itens que correspondam as caracteristicas da amostra. Não será possível vincular."###"Atenção"
            Break
         EndIf
         
      Case cCampo == "EXU_CLAREJ"
         If lRej .And. Empty(M->EXU_CLAREJ)
            MsgInfo(STR0027, STR0051)//"Favor informar identificação da rejeição."
            lRet := .F.
            Break
         EndIf

      Case cCampo == "AGECOM"  // JPP - 21/12/2005 - 16:43
           If ! Empty(cGetAgeCom)
              SY5->(DbSetOrder(1))
              If SY5->(DbSeek(xFilial("SY5")+cGetAgeCom)) 
                 If Left(SY5->Y5_TIPOAGE,1)=="3"  
                    lRet := .T.
                    cGetAgeDesc := SY5->Y5_NOME
                 Else 
                    lRet := .F.
                    MsgInfo(STR0050,STR0051)  // "O agente selecionado não é do tipo recebedor de Comissão!" ### "Atenção"   
                    cGetAgeDesc := "" 
                    oGetAgeDesc:refresh()
                 EndIf
              Else
                 cGetAgeDesc := ""
                 lRet := .F.
                 MsgInfo(STR0052,STR0051) //"Agente Recebedor de Comissão não cadastrado!"###"Atenção"
              EndIf 
           EndIf  

        Case cCampo == "BOK"
           If nOpcao == VISUALIZAR
              Break
           EndIf

           If nOpcao == EXCLUIR .And. !MsgYesNo(STR0089, STR0051)//"Confirma exclusão da amostra?"###"Atenção"
              lRet := .F.
              Break
           EndIf

           If !Obrigatorio(aGets,aTela)
              lRet := .F.
              Break
           EndIf
           
           If (M->EXU_TIPOAM $ "P/E") .And. Empty(M->EXU_PEDIDO)
              MsgInfo("O número do processo não foi informado.", "Atenção")
              lRet := .F.
              Break
           EndIf
           
           If M->EXU_TIPOAM == "P" .And. M->EXU_QTD == 0
              MsgInfo(STR0100,STR0051)//"Favor informar a quantidade vinculada."###"Atenção"
              lRet := .F.
              Break
           EndIf
           
           If M->EXU_TIPOAM == "P" .And. nOpcao == INCLUIR .And. !AM100WKPED()
              lRet := .F.
              Break
           EndIf
           
           If lRej .And. (!AM100VALID("EXU_CLAREJ") .Or. !MsgYesNo(STR0007, STR0051))//"Confirma rejeição da amostra? Esta operação não poderá ser desfeita."###"Atenção"
              lRet := .F.
              Break
           EndIf
           
           If EasyEntryPoint("EECAM100")
              lRet := ExecBlock("EECAM100",.F.,.F.,{"BOK"})
              If ValType(lRet) <> "L"
                 lRet := .t.
              EndIf
              If !lRet
                 Break
              EndIf
           EndIf

           If !Empty(M->EXU_DTENV) .And. IsVazio("WKEXV")
              //MsgInfo(STR0021, STR0051)//"Não é possivel enviar a amostra porque a mesma não possui embarques vinculados."###"Atenção"
              //lRet := .F.
              //Break
               If !(lRet := MsgYesNo("A amostra não possui embarques vinculados. Deseja confirmar o envio?", STR0051))
                  Break
               EndIf
           EndIf

           If !Empty(M->EXU_DTAPRO) .And. Empty(EXU->EXU_DTAPRO)
              If !Am100AprvAmo()
                 lRet := .F.
                 Break
              EndIf
           EndIf
      
      Case cCampo == "EXU_TIPOAM"
         If ValType(cTipoAm) == "C"
            If cTipoAm <> M->EXU_TIPOAM .And. (Select("WKEXV") > 0 .And. !IsVazio("WKEXV"))
               If MsgYesNo(STR0059,STR0051)//"Confirma mudança no tipo da amostra? Será necessário vincular os itens novamente."###"Atenção"
                  M->EXU_QTD := 0
                  If(Select("WKITENS") > 0, WKITENS->(avzap()),)
                  WKEXV->(avzap())
                  lAltera := .T.
                  oMsSelectCp:oBrowse:Refresh()
               Else
                  lRet := .F.
                  Break
               EndIf
            EndIf
         EndIf
         cTipoAm := M->EXU_TIPOAM
         
      Case cCampo == "OBRIGATORIOS"
         For nInc := 1 To Len(aCamposValid)
            If Empty(M->&(aCamposValid[nInc]))
               MsgInfo(STR0012 + AvSx3(aCamposValid[nInc] ,AV_TITULO) + STR0013, STR0055)//"Não é possível vincular porque o campo " ### " não foi informado."
               lRet := .F.
               Break
            EndIf
         Next
      
      Case cCampo == "E-MAIL"
         If Empty(cTo)
            MsgInfo(STR0068, STR0051)//"Informar destinatário"###"Atenção"
            lRet := .F.
            Break
         EndIf
         If Empty(cSubject) .And. !MsgYesNo(STR0069,STR0051)//"A mensagem não possui assunto. Deseja enviá-la assim mesmo?"###"Atenção"
            lRet := .F.
            Break
         EndIf
         nRecnoWKAMOSTRA := WKAMOSTRA->(Recno())
         WKAMOSTRA->(DbGoTop())
         lMark := .F.
         While WKAMOSTRA->(!Eof())
            If !Empty(WKAMOSTRA->WK_MARCA)
               lMark := .t.
               Exit
            EndIf
            WKAMOSTRA->(DbSkip())
         EndDo
         If !lMark
            MsgInfo(STR0070, STR0051)//"Selecione ao menos um embarque para envio do e-mail."###"Atenção"
            lRet := .F.
            WKAMOSTRA->(DbGoTo(nRecnoWKAMOSTRA))
            Break
         EndIf
         If Empty(cConteudo) .And. !MsgYesNo(STR0071,STR0051)//"A mensagem não possui conteúdo. Deseja enviá-la mesmo assim?"###"Atenção"
            lRet := .F.
            Break
         EndIf
      
      Case cCampo == "TELA_EMAIL"
         If !lAmostra .and. !lContrato .and. !lEmbarque .and. !lCliente .And. !lAgeCom
            lRet := .F.
            Break
         Else
            If (lAmostra .And. Vazio(cGetAmostra)) .Or. (lContrato .And. Vazio(cGetContrato)) .Or. ;
               (lEmbarque .And. Vazio(cGetEmbarque)) .Or. (lCliente .And. Vazio(cGetCliente)) .Or.;
               (lAgeCom .And. Vazio(cGetAgeCom))
               lRet := .F.
               Break
            EndIf
         EndIf
         If !Empty(dGetDt1) .And. !Empty(dGetDt2) .And. (dGetDt1 > dGetDt2)
            MsgInfo(STR0037, STR0051)//"Data inicial superior a data final."
         EndIf
         If nRadio == 2 .Or. nRadio == 3
            If !Empty(dDataMail1) .And. !Empty(dDataMail2) .And. (dDataMail1 > dDataMail2)
               MsgInfo(STR0037, STR0051)//"Data inicial superior a data final."
            EndIf
         EndIf

   EndCase

End Sequence

If EasyEntryPoint("EECAM100") //DRL 20/01/2009 - Alterado para Utilizacao no ponto de entrada, para controle de novos Status
   ExecBlock("EECAM100",.F.,.F.,{"VAL_STATUS"})
EndIf

Return lRet

/*
Funcao      : AM100MAIL
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Envia e-mail de notificação de envio de amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*-------------------*
Function AM100MAIL()
*-------------------*
Local lOk := .F., cQry := "", nChav
Local nInc
Local bDataMail := {|| If(nRadio <> 1,(oDataMail1:Enable(),oDataMail2:Enable()),(dDataMail1:= Ctod( "  /  /  " ),dDataMail2:= Ctod( "  /  /  " ),;
                                                                                 oDataMail1:Disable(),oDataMail2:Disable())),oDataMail1:Refresh(),oDataMail2:Refresh()}

Local bOk := {|| If (Am100Valid("TELA_EMAIL"),(lOk := .T., oDlg:End()),MsgInfo(STR0036, STR0051))} //"Informações de filtro incompletas. Não é possível continuar."
Local bCancel := {|| oDlg:End()}
Local aAmostra := {}, aPedido := {}
Local aPos, lMailOk := .F.

Private oRadio,nRadio := 1

Private cFrom := EasyGParam("MV_WFMAIL"),;
        cTo := Space(150),;
        cCC := Space(150),;
        cBCC := Space(150),;
        cSubject := IncSpace("PS Sample",150,.F.),;
        cBody:="",;
        cBodyTb:="",;
        cConteudo := "Please inform about approval as soon as possible." + ENTER;
                    + ENTER;
                    + "Best Regards" + ENTER + ENTER;
                    + "Traffic Dept"

Private cGetAmostra  := Space(20),;
        cGetContrato := Space(20),;
        cGetEmbarque := Space(20),;
        cGetCliente  := Space(6),;
        dGetDt1      := Ctod( "  /  /  " ),;
        dGetDt2      := Ctod( "  /  /  " ),;
        dDataMail1   := Ctod( "  /  /  " ),;
        dDataMail2   := Ctod( "  /  /  " ),;
        cLojaCliente := Space(2),;
        cGetAgeCom   := Space(6),; // JPP - 21/12/2005 - 16:43
        cGetAgeDesc  := Space(30)  // JPP - 21/12/2005 - 16:43
        

Private lAmostra, lContrato, lEmbarque, lCliente, lDatas, lAgeCom     // JPP - 21/12/2005 - 16:43

Private aObj := {{"lAmostra" ,"oCBAmostra" ,"oGetAmostra" },;
                 {"lContrato","oCBContrato","oGetContrato"},;
                 {"lEmbarque","oCBEmbarque","oGetEmbarque"},;
                 {"lCliente" ,"oCBCliente" ,"oGetCliente" },;
                 {"lAgeCom","oCBAgeCom","oGetAgeCom"}}
                                                      
Private oDataMail1,oDataMail2
Private aGets[0],aTela[0]
Private cMarca := GetMark() 
Private lInverte := .F.

EXU->(DbSetOrder(1))

Begin Sequence
      
   Define MsDialog oDlg Title STR0038 From 0, 0 To 420,350 Of oMainWnd Pixel //"Envio de e-mail de notificação"
   
   nInc  := 15
   nLin  := 20
   nCol  := 6
   nCol1 := 18
   nCol2 := 60
   nCol3 := 123
   
   @ nLin,08 Say STR0039 Pixel //"Informações de Filtro"
   
   nLin += nInc
   @ nLin,nCol CheckBox oCBAmostra Var lAmostra Prompt STR0040 Size 090,08 On Click ObjChange(1) Of oDlg Pixel //"Nro. Amostra"
   @ nLin,nCol2 MsGet oGetAmostra Var cGetAmostra Picture "@!" Valid (If (!Vazio(), ExistCpo("EXU", cGetAmostra), )) F3 "EXU" Size 60, 08 Of oDlg Pixel   
   
   nLin += nInc   
   @ nLin,nCol CheckBox oCBContrato Var lContrato Prompt STR0041  Size 090,08 On Click ObjChange(2) Of oDlg Pixel //"Nro. Contrato"
   @ nLin,nCol2 MsGet oGetContrato Var cGetContrato Picture "@!" Valid (If (!Vazio(), ExistCpo("EE7", cGetContrato), )) F3 "EE7" Size 60, 08 Of oDlg Pixel   
   
   nLin += nInc   
   @ nLin,nCol CheckBox oCBEmbarque Var lEmbarque Prompt STR0042 Size 090,08 On Click ObjChange(3) Of oDlg Pixel //"Nro. Embarque"
   @ nLin,nCol2 MsGet oGetEmbarque Var cGetEmbarque Picture "@!" Valid (If (!Vazio(), ExistCpo("EEC", cGetEmbarque), )) F3 "EEC" Size 60, 08 Of oDlg Pixel   
   
   nLin += nInc                            
   @ nLin,nCol CheckBox oCBCliente Var lCliente Prompt STR0043 Size 090,08 On Click ObjChange(4) Of oDlg Pixel //"Cliente"
   @ nLin,nCol2   MsGet oGetCliente Var cGetCliente Picture "@!" Valid (If (!Vazio(), ExistCpo("SA1", cGetCliente), )) F3 "SA1" Size 60, 08 Of oDlg Pixel   
   
   nLin += nInc   
   @ nLin,nCol To nLin+30, 120 Label STR0044 Of oDlg Pixel //"Período de Datas de Envio"
   nLin += 11
   @ nLin,nCol1 MsGet oGetData1 Var dGetDt1 /*Valid Eval(bData)*/ Size 35, 08 Of oDlg Pixel   
   @ nLin,nCol2+15 MsGet oGetData2 Var dGetDt2 /*Valid Eval(bData)*/ Size 35, 08 Of oDlg Pixel      
   
   nLin += nInc // JPP - 21/12/2005 - 16:43
   nLin += 11
   @ nLin,nCol CheckBox oCBAgeCom Var lAgeCom Prompt STR0053 Size 090,08 On Click ObjChange(5) Of oDlg Pixel //"Agen. Comissão"
   @ nLin,nCol2 MsGet oGetAgeCom Var cGetAgeCom Picture "@!" Valid (AM100VALID("AGECOM")) F3 "Y5B" Size 60, 08 Of oDlg Pixel   
   nLin += nInc 
   @ nLin,nCol Say STR0054 Size 60, 08 Of oDlg Pixel  // "Nome Agente"
   @ nLin,nCol2 MsGet oGetAgeDesc Var cGetAgeDesc Size 110, 08 Of oDlg Pixel 
   oGetAgeDesc:Disable()   
   
   nLin += nInc //ER - 17/03/06 - 14:11
   @ nLin,nCol To nLin+45,170  Label STR0084 Of oDlg Pixel //"Amostras com Email"
   nLin += 11
   @ nLin,nCol1 Radio oRadio Var nRadio Items STR0085, STR0086, STR0087 On Change Eval(bDataMail) Size 50,10 Pixel Of oDlg //"Não Enviado"#"Enviado"#"Ambas"
   
   nLin += 03
   @ nLin,nCol2+12 To nLin+28,160 Label STR0044 Of oDlg Pixel //"Período de Datas de Envio"
   nLin += 10
   
   @ nLin,nCol2+15 MsGet oDataMail1 Var dDataMail1 Size 35, 08 Of oDlg Pixel        
   @ nLin,nCol3    MsGet oDataMail2 Var dDataMail2 Size 35, 08 Of oDlg Pixel
   
   If nRadio == 1
      oDataMail1:Disable()
      oDataMail2:Disable()
   EndIf
   
   nLin += 01
   @ nLin,nCol2+51 Say STR0088 Pixel //Até
   
   ObjChange()

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered   
   
   If !lOk
      Break
   EndIf
   
   aCampos := {"EXU_NROAMO","EXU_PEDIDO","EXU_QTD","EXU_DTENV","EXU_NROCA","EXV_PREEMB","EXV_QTD","EE7_IMPORT","EE7_IMPODE"}
   aSemSx3 := {{"WK_MARCA","C", 2,0},;
               {"WK_CHAV1","N", 9,0},;
               {"WK_CHAV2","N", 9,0}}
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   If Select("WKAMOSTRA") == 0
      cNomArq4 := E_CriaTrab(,aSemSx3,"WKAMOSTRA")
   Else
      WKAMOSTRA->(avzap())
   EndIf
  
   If lAmostra
      AADD(aAmostra, cGetAmostra)
   EndIf
   
   If lContrato
      #IFDEF TOP
         cQry := "SELECT EXU_NROAMO, EXU_PEDIDO FROM " + RetSqlName("EXU") + " "
         cQry += "WHERE EXU_FILIAL = '" + xFilial("EXU") + "' AND D_E_L_E_T_ <> '*' " 
         cQry += "And EXU_PEDIDO = '" + cGetContrato + "' "
      #ELSE
         EXU->(DbSetOrder(1))
         EXU->(DbSeek(xFilial("EXU")))
         While EXU->(!Eof() .And. xFilial("EXU") == EXU_FILIAL)
            If EXU->EXU_STATUS == STAM_EN .And. EXU->EXU_PEDIDO == cGetContrato
               AADD(aAmostra, EXU->EXU_NROAMO)
            EndIf
            EXU->(DbSkip())
         EndDo
      #ENDIF
   EndIf
 
   If lEmbarque                                              
      #IFDEF TOP
         cQry := "SELECT EXU_NROAMO, EXU_PEDIDO, EXV_NROAMO, EXV_PREEMB FROM " + RetSqlName("EXU") + " EXU, " + RetSqlName("EXV") + " EXV "
         cQry += "WHERE EXU.EXU_FILIAL = '" + xFilial("EXU") + "' And EXV.EXV_FILIAL = '" + xFilial("EXV") + "' "
         cQry += "And EXU.D_E_L_E_T_ <> '*' And EXV.D_E_L_E_T_ <> '*' "
         cQry += "And EXU.EXU_NROAMO = EXV.EXV_NROAMO And EXV.EXV_PREEMB = '" + cGetEmbarque + "' "
      #ELSE
         EXV->(DbSetOrder(1))
         EXV->(DbSeek(xFilial("EXV")))
         While EXV->(!Eof() .And. xFilial("EXV") == EXV_FILIAL)
            If EXV->EXV_PREEMB == cGetEmbarque
               EXU->(DbSetOrder(1))
               EXU->(DbSeek(xFilial("EXU")+EXV->EXV_NROAMO))
               If EXU->EXU_STATUS == STAM_EN .And. ASCAN(aAmostra, EXV->EXV_NROAMO) == 0
                  AADD(aAmostra, EXV->EXV_NROAMO)
               EndIf            
            EndIf
            EXV->(DbSkip())
         EndDo
      #ENDIF
   EndIf

   If lCliente
      #IFDEF TOP
         cQry := "SELECT EXU_NROAMO, EXU_PEDIDO, EE7_PEDIDO, EE7_IMPORT FROM " + RetSqlName("EXU") + " EXU, " + RetSqlName("EE7") + " EE7 "
         cQry += "WHERE EXU.EXU_FILIAL = '" + xFilial("EXU") + "' And EE7.EE7_FILIAL = '" + xFilial("EE7") + "' "
         cQry += "AND EE7.D_E_L_E_T_ <> '*' AND EXU.D_E_L_E_T_ <> '*' "
         cQry += "AND EXU.EXU_PEDIDO = EE7.EE7_PEDIDO "
         cQry += "AND ((EE7.EE7_INTERM <> '1' AND EE7.EE7_IMPORT = '" + cGetCliente + "') Or (EE7.EE7_INTERM = '1' AND EE7.EE7_CLIENT = '" + cGetCliente + "' ))"
         If !Empty(dGetDt1)
            cQry += "AND EXU_DTENV >= '" + DTOS(dGetDt1) + "' "
         EndIf
         If !Empty(dGetDt2)
            cQry += "AND EXU_DTENV <= '" + DTOS(dGetDt2) + "' "
         EndIf
            
      #ELSE
         EXU->(DbSetOrder(1))
         EXU->(DbSeek(xFilial("EXU")))
         While EXU->(!Eof() .And. xFilial("EXU") == EXU_FILIAL)
            If EXU->EXU_STATUS == STAM_EN
               EE7->(DbSetOrder(1))
               EE7->(DbSeek(xFilial("EE7")+EXU->EXU_PEDIDO))
               If (!Empty(dGetDt1) .And. EXU->EXU_DTENV >= dGetDt1) .Or. Empty(dGetDt1)
                  If (!Empty(dGetDt2) .And. EXU->EXU_DTENV <= dGetDt2) .Or. Empty(dGetDt2)
                     If EE7->EE7_INTERM $ cSim
                        If EE7->EE7_CLIENT == cGetCliente
                           AADD(aAmostra, EXU->EXU_NROAMO)                        
                        EndIf
                     Else
                        If EE7->EE7_IMPORT == cGetCliente
                           AADD(aAmostra, EXU->EXU_NROAMO)
                        EndIf
                     EndIf
                  EndIf
               EndIf
               EXU->(DbSkip())
            EndIf
         EndDo
      #ENDIF
   EndIf
   
   If lAgeCom // JPP - 21/12/2005 - 16:43
      #IFDEF TOP  
         cQry := "SELECT EXU.EXU_NROAMO, EXU.EXU_PEDIDO, EE7.EE7_PEDIDO FROM " + RetSqlName("EXU") +" EXU, " + RetSqlName("EE7") + " EE7 "
         cQry += "WHERE EXU.EXU_PEDIDO = EE7.EE7_PEDIDO "
         cQry += "AND EXU.D_E_L_E_T_ <> '*' AND EE7.D_E_L_E_T_ <> '*' AND EE7.EE7_FILIAL = '" + xFilial("EE7") + "' "
         cQry += "AND EXU.EXU_FILIAL = '" + xFilial("EXU") + "' "
         cQry += "AND EE7.EE7_PEDIDO IN ( "
         cQry += "SELECT EEB_PEDIDO FROM " + RetSqlName("EEB") + " "
         cQry += "WHERE EEB_CODAGE = '" + cGetAgeCom + "' AND EEB_TIPOAG LIKE '3%' " // DFS - Alteração da função LEFT para LIKE
         cQry += "AND D_E_L_E_T_ <> '*' AND "
         cQry += "EEB_FILIAL = '" + xFilial("EEB") + "' AND "
         cQry += "EEB_OCORRE = 'P' AND "
         cQry += "EEB_PEDIDO = EE7.EE7_PEDIDO ) "
         If !Empty(cQry)
            cQry := ChangeQuery(cQry)
            dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WKQRYEEC", .F., .T.)
            If !IsVazio("WKQRYEEC")
               EXU->(DbSetOrder(1))
               While WKQRYEEC->(!Eof())
                  If EXU->(DbSeek(xFilial("EXU")+WKQRYEEC->EXU_NROAMO))// .And. EXU->EXU_STATUS == STAM_EN
                     If Ascan(aAmostra, EXU->EXU_NROAMO) == 0
                        AADD(aAmostra, EXU->EXU_NROAMO)
                     EndIf
                  EndIf
                  WKQRYEEC->(DbSkip())
               EndDo
            EndIf
            WKQRYEEC->(DbCloseArea())
         EndIf
         
         cQry := "SELECT EXV.EXV_NROAMO, EXV.EXV_PREEMB, EE9.EE9_PREEMB FROM " + RetSqlName("EXV") +" EXV, " + RetSqlName("EE9") + " EE9 "
         cQry += "WHERE EXV.EXV_PREEMB = EE9.EE9_PREEMB "
         cQry += "AND EXV.D_E_L_E_T_ <> '*' AND EE9.D_E_L_E_T_ <> '*' AND EE9.EE9_FILIAL = '" + xFilial("EE9") + "' "
         cQry += "AND EXV.EXV_FILIAL = '" + xFilial("EXV") + "' "
         cQry += "AND EE9.EE9_PREEMB IN ( "
         cQry += "SELECT EEB_PEDIDO FROM " + RetSqlName("EEB") + " "
         cQry += "WHERE EEB_CODAGE = '" + cGetAgeCom + "' AND EEB_TIPOAG LIKE '3%' " // DFS - Alteração da função LEFT para LIKE
         cQry += "AND D_E_L_E_T_ <> '*' AND "
         cQry += "EEB_FILIAL = " + xFilial("EEB") + " AND "
         cQry += "EEB_OCORRE = 'Q' AND "
         cQry += "EEB_PEDIDO = EE9.EE9_PREEMB ) "
         If !Empty(cQry)
            cQry := ChangeQuery(cQry)
            dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WKQRYEEC", .F., .T.)
            If !IsVazio("WKQRYEEC")
               EXU->(DbSetOrder(1))
               While WKQRYEEC->(!Eof())
                  If EXU->(DbSeek(xFilial("EXU")+WKQRYEEC->EXU_NROAMO))// .And. EXU->EXU_STATUS == STAM_EN
                     If Ascan(aAmostra, EXU->EXU_NROAMO) == 0
                        AADD(aAmostra, EXU->EXU_NROAMO)
                     EndIf
                  EndIf
                  WKQRYEEC->(DbSkip())
               EndDo
            EndIf
            WKQRYEEC->(DbCloseArea())
         EndIf
      #ELSE  
         EXU->(DbSetOrder(1))
         EXV->(DbSetOrder(1))
         EXU->(DbGoTop())
         EXU->(DbSeek(xFilial("EXU")))
         While EXU->(!Eof() .And. EXU_FILIAL == xFilial("EXU"))
            If EXU->EXU_STATUS == STAM_NE .Or. EXU->EXU_STATUS == STAM_RJ .Or. EXU->EXU_STATUS == STAM_DC
               EXU->(DbSkip())
               Loop
            EndIf
            If EEB->(DbSeek(xFilial("EEB")+EE7->EE7_PEDIDO+OC_PE+Avkey(cGetAgeCom,"EEB_CODAGE")+"3-AGENTE (RECEBEDOR COMIS"))
               If Ascan(aAmostra, EXU->EXU_NROAMO) == 0
                  AADD(aAmostra, EXU->EXU_NROAMO)
               EndIf
               EXU->(DbSkip())
               Loop
            EndIf
            If EXV->(DbSeek(xFilial("EXV")+EXU->EXU_NROAMO))
               While EXV->(!Eof() .And. EXV_FILIAL+EXV_NROAMO == xFilial("EXV")+EXU_NROAMO)
                  If EEB->(DbSeek(xFilial("EEB")+EXV->EXV_PREEMB+OC_EM+Avkey(cGetAgeCom,"EEB_CODAGE")+"3-AGENTE (RECEBEDOR COMIS"))
                     If Ascan(aAmostra, EXU->EXU_NROAMO) == 0
                        AADD(aAmostra, EXU->EXU_NROAMO)
                     EndIf
                     Exit
                  EndIf                  
                  EXV->(DbSkip())
               EndDo
            EndIf
            EXU->(DbSkip())
         EndDo

      #ENDIF   
   EndIf
   
   #IFDEF TOP
      If !Empty(cQry) .And. !lAgeCom
         cQry := ChangeQuery(cQry)
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WKQRY", .F., .T.)
         If !IsVazio("WKQRY")
            While WKQRY->(!Eof())
               AADD(aAmostra, WKQRY->EXU_NROAMO)
               WKQRY->(DbSkip())
            EndDo
         EndIf
        WKQRY->(DbCloseArea())
      EndIf
   #ENDIF
      
   If Len(aAmostra) > 0
      For nInc := 1 To Len(aAmostra)
         nChav2 := 1
         EXU->(DbSetOrder(1))
         EXU->(DbSeek(xFilial("EXU")+aAmostra[nInc]))
         
         /*
            ER - 17/03/2006 às 15:30
            Tratamento para os filtros de Amostras Enviadas ou não por Email
         */
         If nRadio == 1 // Amostras que nunca foram Enviadas por Email
            If !Empty(EXU->EXU_DTMAIL)
               Loop     
            EndIf
         ElseIf nRadio == 2 //Amostras que já foram Enviadas por Email
            If Empty(EXU->EXU_DTMAIL)
               Loop     
            Else
               If !Empty(dDataMail1) .or. !Empty(dDataMail2)
                  If EXU->EXU_DTMAIL < dDataMail1 .Or. EXU->EXU_DTMAIL > dDataMail2
                     Loop
                  EndIf
               EndIf
            EndIf
         Else //Ambas
            If !Empty(EXU->EXU_DTMAIL)
               If !Empty(dDataMail1) .or. !Empty(dDataMail2)
                  If EXU->EXU_DTMAIL < dDataMail1 .Or. EXU->EXU_DTMAIL > dDataMail2
                     Loop
                  EndIf
               EndIf
            EndIf
         EndIf
         
         EE7->(DbSetOrder(1))
         EE7->(DbSeek(xFilial("EE7")+EXU->EXU_PEDIDO))
         cGetCliente  := EE7->EE7_IMPORT
         cLojaCliente := EE7->EE7_IMLOJA
         cNomCliente  := EE7->EE7_IMPODE
         EXV->(DbSetOrder(1))
         If EXV->(DbSeek(xFilial("EXV")+aAmostra[nInc]))
            While EXV->(!Eof() .And. EXV_NROAMO == aAmostra[nInc])
               WKAMOSTRA->(DbAppend())
               WKAMOSTRA->EXU_NROAMO := EXU->EXU_NROAMO
               WKAMOSTRA->EXU_PEDIDO := EXU->EXU_PEDIDO
               WKAMOSTRA->EXU_DTENV  := EXU->EXU_DTENV
               WKAMOSTRA->EXU_NROCA  := EXU->EXU_NROCA
               WKAMOSTRA->EXV_QTD    := EXV->EXV_QTD
               WKAMOSTRA->EXV_PREEMB := EXV->EXV_PREEMB
               WKAMOSTRA->EE7_IMPORT := cGetCliente
               WKAMOSTRA->EE7_IMPODE := cGetCliente
               WKAMOSTRA->EXU_QTD    := EXU->EXU_QTD
               WKAMOSTRA->WK_CHAV1   := nInc
               WKAMOSTRA->WK_CHAV2   := nChav2
               nChav2 += 1
               WKAMOSTRA->TRB_ALI_WT := "EXU"
               WKAMOSTRA->TRB_REC_WT := EXU->(Recno())
               EXV->(DbSkip())
            EndDo
         Else
            WKAMOSTRA->(DbAppend())
            WKAMOSTRA->EXU_NROAMO := EXU->EXU_NROAMO
            WKAMOSTRA->EXU_PEDIDO := EXU->EXU_PEDIDO
            WKAMOSTRA->EXU_DTENV  := EXU->EXU_DTENV
            WKAMOSTRA->EXU_NROCA  := EXU->EXU_NROCA
            WKAMOSTRA->EE7_IMPORT := cGetCliente
            WKAMOSTRA->EE7_IMPODE := cGetCliente
            WKAMOSTRA->EXU_QTD    := EXU->EXU_QTD
            WKAMOSTRA->WK_CHAV1   := nInc
            WKAMOSTRA->WK_CHAV2   := nChav2
            nChav2 += 1
            WKAMOSTRA->TRB_ALI_WT := "EXU"
            WKAMOSTRA->TRB_REC_WT := EXU->(Recno())
         EndIf
      Next
      WKAMOSTRA->(DbGoTop())
   Else
      MsgInfo(STR0049, STR0051)//"Não foram encontradas amostras satisfaçam as condições de filtro."
      Break
   EndIf
   
   If IsVazio("WKAMOSTRA")
      If nRadio == 1 .or. nRadio == 2
         MsgInfo(STR0049, STR0051)//"Não foram encontradas amostras satisfaçam as condições de filtro."
      EndIf
      Break
   EndIf
   
   EEB->(DbSetOrder(1))
   If EEB->(DbSeek(xFilial("EEB")+EXU->EXU_PEDIDO+OC_PE))
      While EEB->(!Eof() .And. EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE == xFilial("EEB")+EXU->EXU_PEDIDO+OC_PE)
         If Left(EEB->EEB_TIPOAG, 1) == CD_AGC
            SY5->(DbSetOrder(1))
            SY5->(DbSeek(xFilial("SY5")+EEB->EEB_CODAGE))
            If !Empty(SY5->Y5_EMAIL)
               cTo := IncSpace(SY5->Y5_EMAIL,150,.F.)
               Exit
            EndIf
         EndIf
         EEB->(DbSkip())
      EndDo
   EndIf
   If Empty(cTo)
      SA1->(DbSetOrder(1))
      EE7->(DbSeek(xFilial("EE7")+EXU->EXU_PEDIDO))
      If EE7->EE7_INTERM $ cSim
         SA1->(DbSeek(xFilial("SA1")+EE7->EE7_CLIENT+EE7->EE7_CLLOJA))
      Else
         SA1->(DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))
      EndIf
      If !Empty(SA1->A1_EMAIL)
         cTo := IncSpace(SA1->A1_EMAIL,150,.F.)
      Else
         MsgInfo(STR0045, STR0051)//"Endereço de e-mail do cliente não informado."
      EndIf
   EndIf   
   
   WKAMOSTRA->(DbSetFilter({|| WKAMOSTRA->WK_CHAV2 == 1}, "WKAMOSTRA->WK_CHAV2 == 1" ))
   
   
   aCposBrowse:={ {"WK_MARCA",""," "},;
                  {{|| WKAMOSTRA->EXU_NROAMO },"",AvSx3("EXU_NROAMO" ,AV_TITULO)},;
                  {{|| WKAMOSTRA->EXU_PEDIDO },"",AvSx3("EXU_PEDIDO" ,AV_TITULO)},;
                  {{|| WKAMOSTRA->EXV_PREEMB },"",AvSx3("EXV_PREEMB" ,AV_TITULO)},;
                  {{|| DTOC(WKAMOSTRA->EXU_DTENV) },"",AvSx3("EXU_DTENV" ,AV_TITULO)},;
                  {{|| WKAMOSTRA->EXU_QTD },"",AvSx3("EXU_QTD" ,AV_TITULO)}}

   If EasyEntryPoint("EECAM100")
      ExecBlock("EECAM100",.F.,.F.,{"MAIL_TELA"})
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0072 From 1,1 To 530,620 Of oMainWnd PIXEL//"Notificação de Amostra"
   									    
    nLin  := 08
    nCol1 := 10
    nCol2 := 35
    nInc  := 12
    @ nLin+1,nCol1 Say STR0073 Size 40, 08 Of oDlg Pixel//"De:"
    @ nLin,nCol2 MsGet cFrom Size 260, 08 When .F. OF oDlg PIXEL
    nLin +=nInc
    @ nLin+1,nCol1 Say STR0074 Size 40, 08 Of oDlg Pixel//"Para:"
    @ nLin,nCol2 MsGet cTo Size 260, 08 OF oDlg PIXEL
    nLin += nInc    
    @ nLin+1,nCol1 Say STR0075 Size 40, 08 Of oDlg Pixel//"Cópia:"
    @ nLin,nCol2 MsGet cCC SIZE 260, 08 OF oDlg PIXEL
   	nLin += nInc
    @ nLin+1,nCol1 Say STR0076 Size 40, 08 Of oDlg Pixel//"Assunto:"
    @ nLin,nCol2 MsGet cSubject SIZE 260, 08 OF oDlg PIXEL
   
    @ nLin+=15,10 To nLin+95,300 Label STR0078 of oDlg Pixel//"Selecione os embarques"
    oMsSelect := MsSelect():New("WKAMOSTRA","WK_MARCA",,aCposBrowse,@lInverte,@cMarca,{nLin+10,15,nLin+90,295})
    oMsSelect:bAval := {|| If (WKAMOSTRA->WK_MARCA == Space(2), WKAMOSTRA->WK_MARCA:= cMarca, WKAMOSTRA->WK_MARCA := Space(2)) }
    
    @ nLin+=100,10 To nLin+84,300 Label STR0079 of oDlg Pixel//"Corpo da Mensagem"
    @ nLin+=8,15 Get cConteudo SIZE 280, 70 MEMO Of oDlg PIXEL HSCROLL

    DEFINE SBUTTON oBut1 FROM nLin+77, 240 TYPE 1  ACTION Eval(bOk,)    ENABLE of oDlg
    DEFINE SBUTTON oBut2 FROM nLin+77, 275 TYPE 2  ACTION Eval(bCancel) ENABLE of oDlg   
       
    lOk := .F.
    bOk := {|| If(Am100Valid("E-MAIL"),(oDlg:End(), lOk := .T.),) }
    bCancel := {|| oDlg:End()}

   ACTIVATE MSDIALOG oDlg Centered
   
   If !lOk
      Break
   EndIf
   
   WKAMOSTRA->(DbClearFilter())

   WKAMOSTRA->(DbGoTop())
   nChav := 0
   lMarca := .F.
   While WKAMOSTRA->(!Eof())
      If WKAMOSTRA->WK_CHAV1 == nChav
         If lMarca
            WKAMOSTRA->WK_MARCA := cMarca
         EndIf
      Else
         nChav := WKAMOSTRA->WK_CHAV1
         If WKAMOSTRA->WK_MARCA == cMarca
            lMarca := .T.
         Else
            lMarca := .F.
         EndIf
      EndIf
      WKAMOSTRA->(DbSkip())
   EndDo
   
   If !lOk
      Break
   EndIf
   

   WKAMOSTRA->(DbSetFilter({|| WKAMOSTRA->WK_MARCA <> Space(2)}, "WKAMOSTRA->WK_MARCA <> Space(2)" ))
 
   cBody := "<HTML>"
   cBody += "<BODY>"
   cBody += "<BR>"
  
   cBodyTb += "<TABLE WIDTH=100% BORDER=1 CELLPADDING=4 CELLSPACING=3>"
   cBodyTb += "<COL WIDTH=51*>"
   cBodyTb += "<COL WIDTH=51*>"
   cBodyTb += "<COL WIDTH=51*>"
   cBodyTb += "<COL WIDTH=51*>"

   cBodyTb += "<TR VALIGN=TOP>"
   cBodyTb += "<TD WIDTH=20%>"
   cBodyTb += "<P ALIGN=CENTER>CTR</P>"
   cBodyTb += "</TD>"
   cBodyTb += "<TD WIDTH=20%>"
   cBodyTb += "<P ALIGN=CENTER>GVS</P>"
   cBodyTb += "</TD>"
   cBodyTb += "<TD WIDTH=20%>"
   cBodyTb += "<P ALIGN=CENTER>PS SAMPLE</P>"
   cBodyTb += "</TD>"
   cBodyTb += "<TD WIDTH=20%>"
   cBodyTb += "<P ALIGN=CENTER>DATE</P>"
   cBodyTb += "</TD>"
   cBodyTb += "<TD WIDTH=20%>"
   cBodyTb += "<P ALIGN=CENTER>AWB</P>"
   cBodyTb += "</TD>"   
   cBodyTb += "</TR>"
   
   WKAMOSTRA->(DbGoTop())
   While WKAMOSTRA->(!Eof())
      cBodyTb += "<TR VALIGN=TOP>"
      cBodyTb += "<TD WIDTH=20%>"
      cBodyTb += "<P ALIGN=CENTER>" + WKAMOSTRA->EXU_PEDIDO + "</P>"
      cBodyTb += "</TD>"
      cBodyTb += "<TD WIDTH=20%>"
      cBodyTb += "<P ALIGN=CENTER>" + WKAMOSTRA->EXV_PREEMB + "</P>"
      cBodyTb += "</TD>"
      cBodyTb += "<TD WIDTH=20%>"
      cBodyTb += "<P ALIGN=CENTER>" + WKAMOSTRA->EXU_NROAMO + "</P>"
      cBodyTb += "</TD>"
      cBodyTb += "<TD WIDTH=20%>"
      cBodyTb += "<P ALIGN=CENTER>" + DTOC(WKAMOSTRA->EXU_DTENV) + "</P>"
      cBodyTb += "</TD>"
      cBodyTb += "<TD WIDTH=20%>"
      cBodyTb += "<P ALIGN=CENTER>" + WKAMOSTRA->EXU_NROCA + "</P>"
      cBodyTb += "</TD>"
      cBodyTb += "</TR>"
      WKAMOSTRA->(DbSkip())
   EndDo
   cBodyTb += "</TABLE>"

   If EasyEntryPoint("EECAM100")
      ExecBlock("EECAM100",.F.,.F.,{"MAIL_MSG_TAB"})
   EndIf

   cBody += cBodyTb
   cBody += "<BR><BR>"
   cBody += "<P>" + cConteudo + "</P>"
   cBody += "</BODY>"
   cBody += "</HTML>"
   
   While !(lMailOk := Am100SendMail(cFrom, cTo, cCC, cSubject, cBody, cBCC))
      If !MsgYesNo(STR0067,STR0051)//"Tentar novamente?"###"Atenção"
         Exit
      EndIf
   EndDo
   
   /*
      ER - 17/03/06 às 17:00
      Grava a Data do Envio de Email.  
   */
   If lMailOk
      WKAMOSTRA->(DbGoTop())
      While WKAMOSTRA->(!EOF())
         EXU->(DbSetOrder(1))
         EXU->(DbSeek(xFilial("EXU")+WKAMOSTRA->(EXU_NROAMO)+WKAMOSTRA->(EXU_PEDIDO)))
         EXU->(RecLock("EXU",.F.))
         EXU->EXU_DTMAIL := Date()
         EXU->(MsUnlock())
         WKAMOSTRA->(DbSkip())
      EndDo
   EndIf
   
   WKAMOSTRA->(DbClearFilter())
    
End Sequence

Return Nil         

/*
Funcao      : ObjChange
Parametros  : nObj -> Objeto a ser validado
Retorno     : Nenhum.
Objetivos   : Habilita/Desabilita edição das Gets da tela de filtros de e-mail.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/10/05
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function ObjChange(nObj)
*------------------------------*
Local i
Default nObj := 0

   For i := 1 To Len(aObj)
      If i == nObj
         &(aObj[i][1]) := .T.
         &(aObj[i][2] + ":Refresh()")
         &(aObj[i][3] + ":Enable()" )
         &(aObj[i][3] + ":Refresh()")
         &(aObj[i][3] + ":SetFocus()")
      Else
         &(aObj[i][1]) := .F.
         &(aObj[i][2] + ":Refresh()")
         &(aObj[i][3] + ":Disable()")
         &(aObj[i][3] + ":Refresh()")
      EndIf
   Next
   If lCliente
      oGetData1:Enable()
      oGetData2:Enable()
   Else
      oGetData1:Disable()
      oGetData2:Disable()
      dGetDt1  := Ctod( "  /  /  " )
      dGetDt2  := Ctod( "  /  /  " )
   EndIf

   oGetData1:Refresh()
   oGetData2:Refresh()
   
Return Nil

/*
Funcao      : Am100VldEmb
Parametros  : cTipo -> Indica o tipo de validação a ser feita.
Retorno     : lRet
Objetivos   : Validações no embarque referentes a amostra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/04/06
Revisao     :
Obs.        :
*/                           
*-------------------------------------------------*
Function Am100VldEmb(cTipo, cPreemb,lExibeMsg,cFil)
*-------------------------------------------------*
Local lRet := .T.
Local aOrd := SaveOrd({"EEC", "EE9"}),;
      aEXU := {},;
      aAmostras := {},;
      aMsg := {},;
      aQualidade := {},;
      aEmb := {}
      
Local nInc, nInc2, nInc3, nInd, nInd2, nTotAmo := 0

Private aSldEmb := {}

Private lValAm:= .T.  //TRP - 31/10/2011 - Variável utilizada em rdmake para desviar validação - Chamado 734146

Default lExibeMsg := .T.
Default cFil := xFilial("EXU")

If EasyEntryPoint("EECAM100")
   ExecBlock("EECAM100",.F.,.F.,{"ANTES_VALID"})
EndIf

Begin Sequence

   cFil := Avkey(cFil,"EXU_FILIAL")
   Do Case
      Case cTipo == "EMBARQUE"
         If EECFlags("AMOSTRA_BASE") .And. !Empty(EEC->EEC_AMBASE) //Se possuir amostra base, considera a sua aprovação para validação do embarque.
            EXU->(DbSetOrder(1))
            If EXU->(DbSeek(xFilial()+EEC->EEC_AMBASE)) .And. !Empty(EXU->EXU_DTAPRO)//Amostra base aprovada.
               //Valida a digitação da data de embarque.
               lRet := .T.
               Break
            EndIf
         EndIf
         If Am100Saldo( ,cPreemb, , , , , , "E",cFil) > 0
            EE9->(DbSetOrder(1))
            For nInc := 1 To Len(aSldEmb)
               For nInc2 := 1 To Len(aSldEmb[nInc][5])
                  If aSldEmb[nInc][5][nInc2][3] > 0
                     aEmb := {}
                     If EE9->(DbSeek(xFilial()+aSldEmb[nInc][5][nInc2][1]))
                        EEC->(DbSetOrder(1))
                        While EE9->(!Eof() .And. EE9_PEDIDO == aSldEmb[nInc][5][nInc2][1])
                           If EE9->EE9_PREEMB <> cPreemb;
                              .And. EE9->(EE9_CODQUA == aSldEmb[nInc][1];
                              .And. EE9_CODPEN == aSldEmb[nInc][2];
                              .And. EE9_CODTIP == aSldEmb[nInc][3];
                              .And. EE9_CODBEB == aSldEmb[nInc][4])
                              If !EEC->(DbSeek(xFilial()+EE9->EE9_PREEMB)) .Or. !(EEC->EEC_ENVAMO $ SIM) .Or. Empty(EEC->EEC_DTEMBA)
                                 EE9->(DbSkip())
                                 Loop
                              EndIf
                              If (nInd := aScan(aEmb, {|x| x[1] == EE9->EE9_PREEMB .And. x[2] == EE9->EE9_PEDIDO})) == 0
                                 ("EE9")->(aAdd(aEmb, {EE9_PEDIDO, EE9_PREEMB, EE9_SLDINI, EE9_CODQUA, EE9_CODPEN, EE9_CODTIP, EE9_CODBEB}))
                              Else
                                 aEmb[nInd][3] += EE9->EE9_SLDINI
                              EndIf
                           EndIf
                           EE9->(DbSkip())
                        EndDo
                     EndIf
                     nTotAmo := 0
                     For nInc3 := 1 To Len(aEmb)
                        If (nSaldo := Am100Saldo(aEmb[nInc3][1], aEmb[nInc3][2], aEmb[nInc3][4], aEmb[nInc3][5], aEmb[nInc3][6], aEmb[nInc3][7], ,"E",cFil)) > 0
                           aSldEmb[nInc][5][nInc2][3] += nSaldo
                        EndIf
                     Next
                     aExu := Am100ListAmo(aSldEmb[nInc][5][nInc2][1], , aSldEmb[nInc][1], aSldEmb[nInc][2], aSldEmb[nInc][3], aSldEmb[nInc][4], ,STAM_AP, "P",cFil)
                     aEval(aEXU, {|x| nTotAmo += x[4] })
                     If lValAm  //TRP - 31/10/2011 - Variável utilizada em rdmake para desviar validação - Chamado 734146
                        If (nTotAmo - aSldEmb[nInc][5][nInc2][3]) < 0
                           If lExibeMsg
                              MsgInfo(STR0094,STR0055)//"Não é possível embarcar, ainda não foram aprovadas amostras suficientes para totalizar a quantidade do embarque."
                           EndIf
                           lRet := .F.
                           Break
                        EndIf
                     Endif
                  EndIf
               Next
            Next
         EndIf
   
      Case cTipo == "EXCLUSAO"
         EE9->(DbSetOrder(2))
         If EE9->(DbSeek(xFilial()+cPreemb))
            While EE9->(!Eof() .And. EE9_FILIAL == xFilial() .And. EE9_PREEMB == cPreemb)
               aEXU := Am100ListAmo(EE9->EE9_PEDIDO, EE9->EE9_PREEMB)
               For nInc := 1 To Len(aEXU)
                  If aScan(aAmostras, {|x| x[1] == aEXU[nInc][1]}) == 0
                     aAdd(aAmostras, aEXU[nInc])
                  EndIf
               Next
               EE9->(DbSkip())
            EndDo
         EndIf
         If Len(aAmostras) > 0
            aAdd(aMsg, {STR0098,.T.})//"Não é possível cancelar/excluir o embarque pois ele está vinculado com a(s) seguinte(s) amostra(s):"
            aAdd(aMsg, {EECMontaMsg({"EXU_NROAMO"}, aAmostras,,.F.) + ENTER,.F.})
            EECView(aMsg, STR0011)//"Manutenção de Amostras"
            lRet := .F.
            Break
         EndIf
         
   EndCase

End Sequence
RestOrd(aOrd, .T.)

Return lRet

/*
Funcao      : Am100IniStatus
Parametros  : cAlias -> "EEC" ou "EE7"
Retorno     : cRet   -> "Sim" ou "Não"
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/04/06
Revisao     :
Obs.        :
*/
Function Am100IniStatus(cAlias)
Local cRet := ""

If cAlias == "EE7"
   If .T./*EECFlags("CAFE")*/
      If(EE7->EE7_ENVAMO == "1", cRet := STR0102, cRet := STR0103)//"Sim"###"Nao"
   Else
      If(EE7->EE7_AMOSTR == "1", cRet := STR0102, cRet := STR0103)//"Sim"###"Nao"
   EndIf
ElseIf cAlias == "EEC"
   If .T./*EECFlags("CAFE")*/
      If(EEC->EEC_ENVAMO == "1", cRet := STR0102, cRet := STR0103)//"Sim"###"Nao"
   Else
      If(EEC->EEC_AMOSTR == "1", cRet := STR0102, cRet := STR0103)//"Sim"###"Nao"
   EndIf
EndIf

Return cRet

/*
Funcao      : AM100DESC()
Parametros  : cAlias, nReg, nOpc
Retorno     : Nenhum.
Objetivos   : Efetuar descarte de uma amostra
Autor       : Caio César Henrique
Data/Hora   : 20/08/08 - 16:50
Obs.        :
*/                            

*------------------------------------*
Function AM100DESC(cAlias, nReg, nOpc)
*------------------------------------*
Local cTexto := ""
Local lDescarta := .T.

Begin Sequence        

   Do Case
      Case EXU->EXU_STATUS == STAM_RJ
         MsgInfo(STR0105+Replicate(ENTER,2)+"Amostra: "+Alltrim(EXU->EXU_NROAMO), STR0055)//"Amostra rejeitada, não é necessário descartá-la" 
         Break
      Case EXU->EXU_STATUS == STAM_DC
         MsgInfo(STR0106+Replicate(ENTER,2)+"Amostra: "+Alltrim(EXU->EXU_NROAMO), STR0055)//"A Amostra selecionada está descartada"
         Break
      Case EXU->EXU_STATUS == STAM_NE
         cTexto := "A Amostra ainda Não Foi Enviada"+ENTER
      Case EXU->EXU_STATUS == STAM_AP
         cTexto := "A Amostra está Aprovada"+ENTER   
      Case EXU->EXU_STATUS == STAM_EN
         cTexto := "A Amostra foi Enviada"+ENTER         
   EndCase
                                                 
   lDescarta := MsgNoYes("Tem certeza que deseja descartar a amostra selecionada?"+ENTER+cTexto+;
                         "Esta operação não poderá ser desfeita.",;
                         "Descartar Amostra "+Alltrim(EXU->EXU_NROAMO))       
   
   If lDescarta 
 
      EXU->(RecLock("EXU", .F.))
      EXU->EXU_STATUS := STAM_DC             
      EXU->(MsUnlock())
     
   End If
     
End Sequence

Return Nil       
