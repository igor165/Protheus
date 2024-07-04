/*
Programa        : EECCV200.PRW.
Objetivo        : Cadastro de Fretes Maritimos (Via/Origem-Destino/Agente/Fretes Maritimos).
Autor           : Jeferson Barros Jr.
Data/Hora       : 04/09/03 13:25.
Versão          : 811
Obs.            :
*/            

#INCLUDE "EECCV200.ch"
#INCLUDE "EEC.cH"

#DEFINE OP_AGE "1"
#DEFINE OP_FRE "2"

/*
Funcao      : Cv200AgMan().               
Parametros  : lVisual = .T. -> Visualização ou .F. -> Diferente de visualização.
Retorno     : .t.
Objetivos   : 
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/09/03 13:25.
Revisao     :
Obs.        :
*/
*--------------------*
Function Cv200AgMan(lVisual)
*--------------------*
Local bOk:={|| oDlg:End()}, bCancel:={|| oDlg:End()},;
      bTemReg := {|| If(IsVazio("WorkAg"),(HELP(" ",1,"AVG0000632"),.f.),.t.)}
Local nL1:=1.4, nC1:=0.8, nC2:=03, nC3:=09, nC4:=13, nC5:= 19, nC6:=23, nSize:=30
Local cOldArea := Select(), cVia, cOrigem, cDestino
Local oDlg, oVia, oDest, oOrigem, oMark
Local aAgCampos:={}, aAgPos:={}, aButtons:={}
Local lRet:=.t.
Local oPanel

Begin Sequence

   // ** Verifica se os campos da Origem e Destino.
   If Empty(M->YR_ORIGEM) .Or. Empty(M->YR_DESTINO)
      MsgInfo(STR0001+AllTrim(AvSx3("YR_ORIGEM",AV_TITULO))+STR0002+; //"O campo '"###"' e o campo '"
               AllTrim(AvSx3("YR_DESTINO",AV_TITULO))+STR0003,STR0004) //"' devem ser informados."###"Atenção"
      Break
   EndIf

   // ** Botões da EnchoiceBar.
   aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| IF(Eval(bTemReg),Cv200AgDetMan(VIS_DET,oMark),)},STR0005}) //"Visualizar"

   If !lVisual
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,{|| Cv200AgDetMan(INC_DET,oMark)},STR0006}) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/   ,{|| IF(Eval(bTemReg),Cv200AgDetMan(ALT_DET,oMark),)},STR0007}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| IF(Eval(bTemReg),Cv200AgDetMan(EXC_DET,oMark),)},STR0008}) //"Excluir"
   EndIf

   // ** Definição das colunas do browse dos agentes.
   aColsAg := {{{|| WorkAg->EX3_AGENTE},"",AvSx3("EX3_AGENTE",AV_TITULO)},;
               {{|| AllTrim(Posicione("SY5",1,xFilial()+WorkAg->EX3_AGENTE,"Y5_NOME"))} ,"",AVSX3("EX3_DSCAGE",AV_TITULO)},;
               {{|| WorkAg->EX3_OBS},"",AvSx3("EX3_OBS",AV_TITULO)}}

   // ** Variaveis para definicao de lay-out da tela de agentes.
   cVia     := M->YQ_VIA
   cOrigem  := M->YR_ORIGEM
   cDestino := M->YR_DESTINO
   aAgPos   := {40,4,140,270}

   WorkAg->(DbSetFilter({|| EX3_ORIGEM == M->YR_ORIGEM .And.;
                            EX3_DEST   == M->YR_DESTINO},;
                            "EX3_ORIGEM  =='"+M->YR_ORIGEM+"' .And. "+;
                            "EX3_DEST    =='"+M->YR_DESTINO+"'"))
   WorkAg->(dbGoTop())
   // by CRF 30/10/2010 14:55
   aColsAg := AddCpoUser(aColsAg,"EX3","5","WorkAg")


   Define MsDialog oDlg Title STR0009 From 9,0 To 28,70 Of oMainWnd //"Agentes Marítimos"
      
      oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15)
      
      @ nL1, nC1 Say STR0010 Of oPanel//"Via"
      @ nL1, nC3 Say STR0011 Of oPanel//"Origem"
      @ nL1, nC5 Say STR0012 Of oPanel//"Destino"

      @ nL1, nC2 MsGet oVia     Var cVia     When .f. Size nSize,7 Right Of oPanel
      @ nL1, nC4 MsGet oOrigem  Var cOrigem  When .f. Size nSize,7 Right Of oPanel
      @ nL1, nC6 MsGet oDestino Var cDestino When .f. Size nSize,7 Right Of oPanel

      //wfs alinhamento
      oPanel:Align:= CONTROL_ALIGN_TOP
      
      oMark := MsSelect():New("WorkAg",,,aColsAg,,,aAgPos)
      oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs
      oMark:bAval := {|| Cv200AgDetMan(VIS_DET,oMark)}
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

   WorkAg->(DbClearFilter())
   WorkAg->(dbGoTop())   

End Sequence

DbSelectArea(cOldArea)

Return lRet

/*
Funcao      : Cv200AgDetMan(nOpc,oMark,lFrete).
Parametros  : Operação. (Inclusao/Alteracao/Exclusao).
              Objeto para refresh.
              lFrete - .t. (Habilita manutenção de fretes marítimos).
                       .f. (Desabilita manutenção de fretes marítimos). (Default)
Retorno     : .t./.f.
Objetivos   : Manutenção dos Agentes.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/09/03 10:29.
Revisao     :
Obs.        :
*/
*----------------------------------------------*
Static Function Cv200AgDetMan(nOpc,oMark,lFrete)
*----------------------------------------------*
Local nOldArea := Select(), nOpcA := 0, z:=0, j:=0
Local aButtons:={}, /*aAgEnchoice:={}, aAltAgEnchoice:={},*/ aOldaTela:={}, aOldaGets:={}
Local lRet:=.t., lOk:=.f.
Local bCancel:={|| oDlg:End()}, bTemReg := {|| If(IsVazio("WorkFre"),(HELP(" ",1,"AVG0000632"),.f.),.t.)}
Local oDlg,oSelect

Private aAgEnchoice:={}, aAltAgEnchoice:={}, aColsFrete:={}


Default lFrete := .f.

Begin Sequence

   aOldaTela := aTela
   aOldaGets := aGets

   aTela:={}; aGets:={}

   aAgEnchoice:={"EX3_ORIGEM", "EX3_DSCORI", "EX3_DEST",   "EX3_DSCDES",;
                 "EX3_TRATIM", "EX3_AGENTE", "EX3_DSCAGE", "EX3_OBS",;
                 "EX3_MOEDA",  "EX3_VL_MIN", "EX3_KILO1",  "EX3_VALOR1",;
                 "EX3_KILO2",  "EX3_VALOR2", "EX3_KILO3",  "EX3_VALOR3",;
                 "EX3_KILO4",  "EX3_VALOR4", "EX3_KILO5",  "EX3_VALOR5",;
                 "EX3_KILO6",  "EX3_VALOR6"}

   aAltAgEnchoice:={"EX3_TRATIM", "EX3_AGENTE", "EX3_DSCAGE", "EX3_OBS",;
   					"EX3_MOEDA",  "EX3_VL_MIN", "EX3_KILO1",  "EX3_VALOR1",;
   					"EX3_KILO2",  "EX3_VALOR2", "EX3_KILO3",  "EX3_VALOR3",;
   					"EX3_KILO4",  "EX3_VALOR4", "EX3_KILO5",  "EX3_VALOR5",;
   					"EX3_KILO6",  "EX3_VALOR6"}

   If !lFrete
      If nOpc == INC_DET
         For z := 1 TO EX3->(FCount())
            M->&(EX3->(FieldName(z))) := CriaVar(EX3->(FieldName(z)))
         Next

         M->EX3_TRATIM := M->YR_TRANS_T
      Else
         For j := 1 To WorkAg->(FCount())
            M->&(WorkAg->(FieldName(j))) := WorkAg->(FieldGet(j))
         Next
      Endif

      M->EX3_VIA    := M->YQ_VIA
      M->EX3_ORIGEM := M->YR_ORIGEM
      M->EX3_DEST   := M->YR_DESTINO
      M->EX3_DSCORI := Posicione("SY9",2,xFilial()+M->EX3_ORIGEM,"Y9_DESCR")
      M->EX3_DSCDES := Posicione("SY9",2,XFILIAL()+M->EX3_DEST,"Y9_DESCR")
   EndIf

   If nOpc == VIS_DET
      bOk := {||oDlg:End()}
   ElseIf nOpc == INC_DET
      bOk := {|| lOk:=.t., If(CV200Valid(nOpc,OP_AGE,lFrete),oDlg:End(),lOk:=.f.)}
   Else // Alteração ou Exclusão.
      bOk := {|| lOk:=.t., IF(CV200Valid(nOpc,OP_AGE,lFrete),oDlg:End(),lOk:=.f.)}
   EndIf

   If (lFrete .And. nOpc == INC_DET) .Or. (nOpc <> INC_DET)

      // ** Campos p/ alteração na enchoice do agente, já com a manutenção de fretes ativa.
      aAltAgEnchoice:={ "EX3_TRATIM", "EX3_OBS",   "EX3_VL_MIN", "EX3_KILO1",;
                        "EX3_VALOR1", "EX3_KILO2", "EX3_VALOR2", "EX3_KILO3",;
                        "EX3_VALOR3", "EX3_KILO4", "EX3_VALOR4", "EX3_KILO5",;
                        "EX3_VALOR5", "EX3_KILO6", "EX3_VALOR6" }

      // ** Botões da EnchoiceBar.
      aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| If(Eval(bTemReg),Cv200FreMan(VIS_DET,oSelect),)},STR0005}) //"Visualizar"

      If (nOpc == INC_DET .Or. nOpc == ALT_DET) .And. !lVisual
         aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,{|| Cv200FreMan(INC_DET,oSelect)},STR0006}) //"Incluir"
         aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/   ,{|| If(Eval(bTemReg),Cv200FreMan(ALT_DET,oSelect),)},STR0007}) //"Alterar"
         aAdd(aButtons,{"EXCLUIR"  ,{|| If(Eval(bTemReg),Cv200FreMan(EXC_DET,oSelect),)},STR0008}) //"Excluir"
      EndIf

      // ** Definição das colunas do browse dos agentes.
      aColsFrete := {{{|| WorkFre->EX4_TIPO} ,"",AvSx3("EX4_TIPO" ,AV_TITULO)},;
                     {{|| WorkFre->EX4_MOEDA},"",AvSx3("EX4_MOEDA",AV_TITULO)},;
                     {{||Transform(WorkFre->EX4_CON20 ,AVSX3("EX4_CON20" ,AV_PICTURE))} ,"", STR0021},; //"Valor 20´"
                     {{||Transform(WorkFre->EX4_CON40 ,AVSX3("EX4_CON40" ,AV_PICTURE))} ,"", STR0022},;  //"Valor 40´"
                     {{||Transform(WorkFre->EX4_CON40H,AVSX3("EX4_CON40H",AV_PICTURE))} ,"", STR0023}} //"Valor 40´HC"

      // ** Incluir filtro para a WorkFre.
      WorkFre->(DbSetFilter({|| EX4_ORIGEM == M->EX3_ORIGEM  .And.;
                                EX4_DEST == M->EX3_DEST .And. EX4_AGENTE == M->EX3_AGENTE},;
                                "EX4_ORIGEM  =='"+M->EX3_ORIGEM+"' .And. "+;
                                "EX4_DEST =='"+M->EX3_DEST+"' .And. EX4_AGENTE =='"+M->EX3_AGENTE+"'"))
      WorkFre->(DbGoTop())
   EndIf
   
   If EasyEntryPoint("EECCV200")
      ExecBlock("EECCV200",.F.,.F.,{"ENC_DET_AG"})
   EndIf
 
 //by CRF 30/10/2010 - 15:46
If lFrete .Or. nOpc <> INC_DET
  aColsFrete :=  AddCpoUser(aColsFrete,"EX4","5","WorkFre")
EndIf
//OAP -05/11/2010-Inclusão de campos adicionados pelo usuário 
   aAgEnchoice := AddCpoUser(aAgEnchoice,"EX3","1")
   aAltAgEnchoice := AddCpoUser(aAltAgEnchoice,"EX3","1")

   Define MsDialog oDlg Title STR0013+M->YQ_VIA From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Agente - Via "
       //aPos:=PosDlg(oDlg) 
      //OAP -05/11/2010- Correção do Posicionamento dos campos 
      If lFrete .Or. nOpc <> INC_DET
         aPos:=PosDlgUp(oDlg) 
      Else
         aPos:=PosDlg(oDlg)  
      EndIf

      EnChoice("EX3",,IF(nOpc=INC_DET,3,4),,,,aAgEnchoice,aPos,IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aAltAgEnchoice),3)

      If lFrete .Or. nOpc <> INC_DET
         oSelect := MsSelect():New("WorkFre",,,aColsFrete,,,PosDlgDown(oDlg))
         oSelect:bAval := {|| IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),Cv200FreMan(VIS_DET,oMark),Cv200FreMan(ALT_DET,oMark))}
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

   If (lFrete .Or. nOpc <> INC_DET)
      WorkFre->(DbClearFilter())
      If lOk
         If nOpc == INC_DET
            WorkAg->(DbAppend())
         Endif

         If !Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
            For j:= 1 TO WorkAg->(FCount())
               If AllTrim(WorkAg->(FieldName(j))) $ "RECNO,DELETE"
                  Loop
               Endif
               WorkAg->(FieldPut(j,M->&(FieldName(j))))
            Next
            WorkAg->EX3_VIA := M->YQ_VIA
         EndIf

         If lFrete .Or. nOpc <> INC_DET
            oMark:oBrowse:Refresh()
         EndIf
      EndIf
   Else
      If lOk
         Cv200AgDetMan(nOpc,oMark,.t.)
      EndIf
   EndIf

End Sequence

aTela := aOldaTela
aGets := aOldaGets

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : Cv200FreMan(nOpc,oSelect).
Parametros  : Operação. (Inclusao/Alteracao/Exclusao).
              oSelect - Objeto para refresh.
Retorno     : .t./.f.
Objetivos   : Manutenção dos Fretes Marítimos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/09/03 15:34.
Revisao     :
Obs.        :
*/
*---------------------------------------*
Static Function Cv200FreMan(nOpc,oSelect)
*---------------------------------------*
Local nOldArea := Select(), nOpcA := 0, z:=0, j:=0
Local aButtons:={}, aFrEnchoice:={}, aPos:={}, aOldaTela:={}, aOldaGets:={}
Local bCancel:={|| oDlg:End()}
Local lRet:=.t.
Local oDlg

Begin Sequence

   aOldaTela := aTela
   aOldaGets := aGets

   aTela:={}; aGets:={}

   If nOpc == INC_DET
      If Empty(M->EX3_AGENTE)
         MsgInfo(STR0001+AllTrim(AvSx3("EX3_AGENTE",AV_TITULO))+STR0014,STR0004) //"O campo '"###"' deve ser informado."###"Atenção"
         Break
      EndIf

      For z := 1 TO EX4->(FCount())
         M->&(EX4->(FieldName(z))) := CriaVar(EX4->(FieldName(z)))
      Next
      bOk := {|| nOpca:=1, If(CV200Valid(nOpc,OP_FRE),oDlg:End(),nOpca:=0)}
   Else
      For j := 1 To WorkFre->(FCount())
         M->&(WorkFre->(FieldName(j))) := WorkFre->(FieldGet(j))
      Next

      If nOpc == VIS_DET
         bOk := {||oDlg:End()}
      Else // Alteração e Exclusão.
         bOk := {|| nOpca:=1, If(CV200Valid(nOpc,OP_FRE),oDlg:End(),nOpca:=0)}
      EndIf
   Endif

   Define MsDialog oDlg Title STR0015 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Taxas de Frete"
      aPos:=PosDlg(oDlg)
      EnChoice("EX4",,IF(nOpc=INC_DET,3,4),,,,,aPos,IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

   If nOpcA == 1 // Ok
      If nOpc == INC_DET
         WorkFre->(DbAppend())
      Endif

      If !Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
         For j:= 1 TO WorkFre->(FCount())
            If AllTrim(WorkFre->(FieldName(j))) $ "RECNO,DELETE"
               Loop
            Endif
            WorkFre->(FieldPut(j,M->&(FieldName(j))))
         Next

         WorkFre->EX4_VIA    := M->YQ_VIA
         WorkFre->EX4_ORIGEM := M->YR_ORIGEM
         WorkFre->EX4_DEST   := M->YR_DESTINO
         WorkFre->EX4_AGENTE := M->EX3_AGENTE
      EndIf

      oSelect:oBrowse:Refresh()
   Endif

End Sequence

DbSelectArea(nOldArea)

aTela := aOldaTela
aGets := aOldaGets

Return lRet

/*
Funcao      : CV200Valid(nOpc)
Parametros  : nOpc = Operação (Visualizacao/Inclusao/Alteracao/Exclusao)
              cManut - (Frete ou Agente).
              lFrete - .t. (Valida a work de fretes marítimos).
                       .f. (Valida apenas as informações do agente).(Default)
Retorno     : .t./.f.
Objetivos   : Consistencias do EX3 e EX4.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/20/2002 15:50
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Static Function CV200Valid(nOpc,cManut,lFrete)
*--------------------------------------------*
Local lRet := .t.

Default lFrete :=.f.

Begin Sequence

   If nOpc == INC_DET .Or. nOpc == ALT_DET
      If ! Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      Endif

   Elseif nOpc == EXC_DET
      IF !MsgNoYes(STR0016, STR0004) //"Confirma a Exclusão ?"###"Atenção"
         lRet := .f.
         Break
      Endif
   Endif

   Do Case
      Case cManut == OP_AGE
         If lFrete
            If nOpc == INC_DET .Or. nOpc == ALT_DET
               If IsVazio("WorkFre")
                  HELP(" ",1,"AVG0005019") //MsgStop("Não existem Tarifas de Fretes cadastradas !","Atenção")
                  lRet:=.F.
                  Break
               EndIf
            EndIf
         EndIf

         If nOpc == EXC_DET
            // ** Deleta as tarifas maritimas cadastradas para o agente a ser excluido.
            WorkFre->(DbSetOrder(1))
            WorkFre->(DbSeek(WorkAg->EX3_ORIGEM+WorkAg->EX3_DEST+WorkAg->EX3_AGENTE))
            Do While WorkFre->(!Eof()) .And. WorkFre->EX4_ORIGEM == WorkAg->EX3_ORIGEM .And.;
                                             WorkFre->EX4_DEST   == WorkAg->EX3_DEST .And.;
                                             WorkFre->EX4_AGENTE == WorkAg->EX3_AGENTE
               If WorkFre->RECNO <> 0
                  aAdd(aFreDeletados,WorkFre->RECNO)
               EndIf
               WorkFre->(DbDelete())

               WorkFre->(DbSkip())
            EndDo 

            // ** Apaga o agente.
            If WorkAg->RECNO <> 0
               aAdd(aAgDeletados,WorkAg->RECNO)
            EndIf
            WorkAg->(DbDelete())
            WorkAg->(DbGoTop())
         EndIf

      Case cManut == OP_FRE
         If nOpc == EXC_DET  // Exclusao. //CCM - 28/05/09 - Não é obrigatorio a digitação dos cointainers.
            //If Empty(M->EX4_CON20) .And. Empty(M->EX4_CON40) .And. Empty(M->EX4_CON40H)
            //   MsgInfo(STR0017+ENTER+; //"Não existem Tarifas de Fretes preenchidas! Verifique os campos "
            //           "'"+AvSx3("EX4_CON20",AV_TITULO)+"', '"+AvSx3("EX4_CON40",AV_TITULO)+"' e '"+AvSx3("EX4_CON40H",AV_TITULO)+"'.",STR0024) //"Aviso"
            //   lRet:=.f.
            //   Break
            //EndIf
         //Else 
            If WorkFre->RECNO <> 0
               aAdd(aFreDeletados,WorkFre->RECNO)
            EndIf
            WorkFre->(DbDelete())
            WorkFre->(DbGoTop())
         EndIf
   EndCase

End Sequence

Return lRet

/*
Funcao          : CV200TpCon().
Parametros      : Nenhum.
Objetivos       : Retornar descricao de tipo de container.
Autor           : Jeferson Barros Jr.
Data/Hora       : 05/09/03 15:58.
Revisao         :
Obs             :
*/
*-------------------*
Function CV200TpCon()
*-------------------*
Local lRet:=.t., cOldArea:=select(), cX5_DESC

Begin sequence

   If !Empty(cX5_DESC:=Tabela('CK',Left(M->EX4_TIPO,1)))
      M->EX4_TIPO:= Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
   Else
      M->EEA_TIPDOC:=SPACE(25)
      lRet:=.F.
   EndIf

End Sequence
    
lRefresh:=.T.
    
DbSelectarea(cOldArea)

Return lRet

/*
Funcao          : CV200VldAg(cCpo).
Parametros      : cCpo - Campo a ser validado.
Objetivos       : Verificar se o agente já existe para a via e origem e destino.
Autor           : Jeferson Barros Jr.
Data/Hora       : 09/09/03 08:52.
Revisao         :
Obs             :
*/
*-----------------------*
Function CV200VldAg(cCpo)
*-----------------------*
Local lRet:=.t., lFound:=.f.
Local cOldArea:=select(), cCodAg
Local aOrd

Begin sequence

   cCpo:= AllTrim(Upper(cCpo))
   
   Do Case
      Case cCpo == "EX3_AGENTE"

         aOrd:=SaveOrd({"EX3","WorkAg","SY5"})
         
         cCodAg:= M->EX3_AGENTE
         WorkAg->(DbSetOrder(1))
         lFound := WorkAg->(DbSeek(M->EX3_ORIGEM+M->EX3_DEST+cCodAg))

         If !lFound
            EX3->(DbSetOrder(1))
            lFound := EX3->(DbSeek(xFilial("EX3")+M->EX3_VIA+M->EX3_ORIGEM+M->EX3_DEST+cCodAg))   
         EndIf

         If lFound
            MsgInfo(STR0018,STR0019) //"Este agente já está existe para esta via, origem e destino!"###"Aviso"
            lRet:=.f.
         Else
            SY5->(DbSetOrder(1))
            If SY5->(DbSeek(xFilial("SY5")+M->EX3_AGENTE))
               If Left(SY5->Y5_TIPOAGE,1) <> "1"
                  MsgInfo(STR0020,STR0004) //"Agente inválido! Escolha um agente do tipo 'Embarcador'"###"Atenção"
                 lRet:=.f.
               EndIf
           EndIf
         EndIf

      Otherwise
         aOrd:=SaveOrd({"SY5"})
         SY5->(DbSetOrder(1))
         If SY5->(DbSeek(xFilial("SY5")+M->&(cCpo)))
            If Left(SY5->Y5_TIPOAGE,1) <> "1"
               MsgInfo(STR0020,STR0004) //"Agente inválido! Escolha um agente do tipo 'Embarcador'"###"Atenção"
               lRet:=.f.
            EndIf
         EndIf
   EndCase

End Sequence

RestOrd(aOrd)
DbSelectArea(cOldArea)   

Return lRet


/*
Funcao    : CV200REL()
Autor     : Ricardo Dumbrovsky
Manutenção: 
Data      : 05.11.2002
Descricao : Relatorio da tabela de fretes
Uso       : SIGAEEC
*/
*-----------------*
Function CV200REL()  
*-----------------*
Local cAlias := Alias(), nOrdEX3 := EX3->( IndexOrd()), nOrdEX4 := EX4->( IndexOrd() )
Local nRecEX3:= EX3->( Recno() ), nRecEX4:= EX4->( Recno() ), lOk:= .F.

// Define variaveis das funções SetPrint() e SetDefault()
PRIVATE cString := "WRK"
PRIVATE NomeRel := "CV200REL"
PRIVATE titulo  := ""
PRIVATE cDesc1  := STR0025 //"Este relatório os imprime as taxas de frete"
PRIVATE cDesc2  := STR0026 //" conforme parametros informados pelo usuáruo"
PRIVATE cDesc3  := ""
PRIVATE aOrd    := Nil
PRIVATE tamanho := "M"
PRIVATE nLin    := 999
PRIVATE aReturn := { "Zebrado", 1,"Importação", 2, 2, 1, "", 1 }
PRIVATE m_pag   := 1
PRIVATE cCabec1 := ""
PRIVATE cCabec2 := ""
PRIVATE cArqTrb := ""   
PRIVATE cARQTRB1 := ""

// Define variaveis desta rotina
Private cQUEBRA
Private cKey
Private Var1 := CriaVar("EX3_ORIGEM")
Private aCampos:= aHeader := {}

Begin Sequence

   Do While .T.
      Titulo := STR0027 //"Relatório da Tabela de Frete Maritimos"
   
      If !SelParam()
         Break
      EndIf
      Processa({||lOk:=CV200RELGRVTRB()},STR0028) //"Gerando relatório..."
      If !lok
         EXIT
      Endif

      CV200RELIMP()
      WRK->(E_EraseArq(cArqTrb))
      dbSelectArea(cAlias)
   EndDo

End Sequence

EX4->( dbSetOrder(nOrdEX4) )
EX3->( dbSetOrder(nOrdEX3) )
EX4->( dbGoto(nRecEX4) )
EX3->( dbGoto(nRecEX3) )

Return Nil

*------------------------------*
Static Function CV200RELGRVTRB() 
*------------------------------*
LOCAL aStruct := {}, lPVez 
Local aOrd:=SaveOrd({"EX3","EX4"})

Begin Sequence

   aAdd(aStruct, {"WK_ORIGEM" , "C", 03, 0})
   aAdd(aStruct, {"WK_DEST"   , "C", 03, 0})
   aAdd(aStruct, {"WK_AGENTE" , "C", 03, 0})
   aAdd(aStruct, {"WK_DSCORI" , "C", 20, 0})
   aAdd(aStruct, {"WK_DSCDES" , "C", 20, 0})
   aAdd(aStruct, {"WK_DSCAGE" , "C", 20, 0})
   aAdd(aStruct, {"WK_TRATIM" , "N", 03, 0})
   aAdd(aStruct, {"WK_OBS"    , "C", 40, 0})
   aAdd(aStruct, {"WK_TIPO"   , "C", 20, 0})
   aAdd(aStruct, {"WK_MOEDA"  , "C", 03, 0})
   aAdd(aStruct, {"WK_CON20"  , "N", 15, 2})
   aAdd(aStruct, {"WK_CON40"  , "N", 15, 2})
   aAdd(aStruct, {"WK_CON40H" , "N", 15, 2})
   aAdd(aStruct, {"WK_CHAVE"  , "C", 26, 2})

   cArqTrb := E_CriaTrab(,aStruct,"WRK")
   IndRegua("WRK",cArqTrb+TEOrdBagExt(),"WK_ORIGEM+WK_DEST+WK_AGENTE")
   
   cARQTRB1 := CRIATRAB(,.F.)
   IndRegua("WRK",cArqTrb1+TEOrdBagExt(),"WK_CHAVE")

   Set Index To (cARQTRB+TEOrdBagExt()),(cARQTRB1+TEOrdBagExt())

   ProcRegua(EX3->(LastRec()))

   EX3->(DbSetOrder(2))
   EX4->(DbSetOrder(1))

   If EX3->(DbSeek(xFilial("EX3")+Var1))
      Do While EX3->(!Eof()) .And. EX3->EX3_FILIAL == xFilial("EX3") .And.;
                                   EX3->EX3_ORIGEM == Var1
         lPVez := .t.
         EX4->(DbSeek(xFilial("EX4")+EX3->EX3_VIA+EX3->EX3_ORIGEM+EX3->EX3_DEST+EX3->EX3_AGENTE))
         Do While EX4->(!Eof()) .And. EX4->EX4_FILIAL == xFilial("EX4") .And.;
                                      EX4->EX4_VIA    == EX3->EX3_VIA .And.;
                                      EX4->EX4_ORIGEM == EX3->EX3_ORIGEM .And.;
                                      EX4->EX4_DEST   == EX3->EX3_DEST .And.;
                                      EX4->EX4_AGENTE == EX3->EX3_AGENTE
            IncProc(STR0029) //"Pesquisando..."
            Wrk->(DbAppend())
            Wrk->WK_ORIGEM := EX4->EX4_ORIGEM
            Wrk->WK_DEST   := EX4->EX4_DEST
            Wrk->WK_AGENTE := EX4->EX4_AGENTE
            If lPVez
               Wrk->WK_DSCORI := EX3->EX3_DSCORI
               Wrk->WK_DSCDES := EX3->EX3_DSCDES
               Wrk->WK_DSCAGE := Posicione("SY5",1,xFilial("SY5")+EX3->EX3_AGENTE,"Y5_NOME")
               Wrk->WK_TRATIM := EX3->EX3_TRATIM
               Wrk->WK_OBS    := EX3->EX3_OBS
               lPVez := .F.
            Endif
            Wrk->WK_CHAVE  := EX4->EX4_ORIGEM+EX3->EX3_DSCDES+EX4->EX4_AGENTE
            Wrk->WK_TIPO   := Alltrim(EX4->EX4_TIPO)
            Wrk->WK_MOEDA  := EX4->EX4_MOEDA
            Wrk->WK_CON20  := EX4->EX4_CON20
            Wrk->WK_CON40  := EX4->EX4_CON40
            Wrk->WK_CON40H := EX4->EX4_CON40H

            EX4->(DbSkip())
         EndDo
         EX3->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd)

Return .T.

*---------------------------*
Static Function CV200RELIMP() 
*---------------------------*
LOCAL aDados :={"WRK",;
                Titulo,;
                cDesc1,;
                cDesc2,;
                "G",;
                220,;
                "",;
                "",;
                Titulo,;
                aReturn,; 
                "CV200REL",{{|| U_CV200QUEBRA() },{|| U_CV200TOTAL()}},.T.}

Private cChave
Private aRCampos:={ ;
                  {"WK_ORIGEM"                                      , STR0030, "E"}  ,;  //"ORIGEM"  //ACB - 23/03/2010
                  {"WK_DEST"                                        , STR0031, "E"}  ,;  //"DESTINO" //ACB - 23/03/2010
                  {"WK_DSCAGE"                                      , STR0032, "E"}  ,;  //"AGENTE"
                  {"If(WK_TRATIM >0,Transform(WK_TRATIM,'99'),'  ')", STR0033, "C"}  ,;  //"TRANSIT TIME"
                  {"WK_OBS"                                         , STR0034, "E"}  ,;  //"OBSERVACAO"
                  {"WK_TIPO"                                        , "TIPO" , "E"}  ,; 
                  {"WK_MOEDA"                                       , STR0035, "E"}  ,; //"MOEDA"
                  {"Transform(WK_CON20,'@E 999,999.99')"            , STR0036, "E"}  ,;  //"VALOR 20'"
                  {"Transform(WK_CON40,'@E 999,999.99')"            , STR0037, "E"}  ,;  //"VALOR 40'"
                  {"Transform(WK_CON40H,'@E 999,999.99')"           , STR0038, "E"} } //"VALOR 40'HC"
                  
cChave := ""
bQUEBRA := {||WRK->(WK_CHAVE)}
If WRK->(Bof()) .And. WRK->(Eof())
   MsgInfo(STR0039,STR0040)     //"Não há registros para a seleção!"###"Atenção"
else
   WRK->(DBSETORDER(2))
   WRK->(DBGOTOP())
   cQUEBRA:= EVAL(bQUEBRA)
   E_Report(aDados,aRCampos)
EndIf

Return .T.                

*--------------------------*
User FUNCTION CV200QUEBRA() 
*--------------------------*
IF Alltrim(EVAL(bQUEBRA)) # Alltrim(cQuebra)
   cQuebra:=EVAL(bQUEBRA)
   Linha+= 1
   @ Linha, 00 PSAY REPLICATE("-",220)
   Linha+= 1
Endif
Return .T.


*--------------------------*
User FUNCTION CV200TOTAL() 
*--------------------------*
Linha+=1 
@ Linha, 00 PSAY REPLICATE("=",220)

Return .t.

/*
Funcao      : SelParam()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Tela definição dos parâmetros para impressão do relatório de Fretes Marítimos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/09/2003 14:34.
Revisao     :
Obs.        :
*/
*------------------------*
Static Function SelParam()
*------------------------*
Local lRet:= .F. , oDlg
Local bOk := {|| lRet:=.T. , If(Empty(Var1),MsgInfo(STR0041),oDlg:End())} //"Informe o Porto de Origem"
Local bCancel := {|| oDlg:End()}
//19.mai.2009 - 719365 - Alteração do botão Cancelar - HFD

Begin Sequence
   //AOM - 14/07/2011 - Alterado o tamanho das telas
   DEFINE MSDIALOG oDlg TITLE STR0042 FROM 10,12 TO 20.5,60 OF oMainWnd //"Relatório Fretes Marítimos"  //  By JPP - 19/04/05 - 16:45 - Redimensionamento da tela

      @ 0.1, 0.5 TO 4.5,22.5 LABEL STR0043 OF oDlg //"Informações Iniciais"  //  By JPP - 19/04/05 - 16:45 - Redimensionamento da tela

      @ 1.2, 2.0 SAY STR0044 OF oDlg SIZE 35,9 //"Porto Origem"
      @ 1.8, 2.0 MSGET Var1 SIZE 45,07 PICTURE AVSX3("EX3_ORIGEM",AV_PICTURE) F3 "EY9" Valid ExistCpo("SY9",Var1,2) Of oDlg 

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

End Sequence

Return lRet

************************************************************************************
* FIM DO PROGRAMA EECCV200                                                         *
************************************************************************************
