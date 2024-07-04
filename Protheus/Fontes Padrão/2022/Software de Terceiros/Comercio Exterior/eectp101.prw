#INCLUDE "eectp101.ch"
#include "EEC.cH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

/*
Programa        : EECTP101.
Objetivo        : Rotina de Reajuste de Preços de acordo com os lançamentos da Tabela de Preços.
Autor           : HFD
Data/Hora       : 03.mar.2008
Obs.            :
*/

/*                                            
Funcao      : EECTP101.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Rotina de Aprovação de Preços.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 09:29.
Revisao     :
Obs.        :
*/
*-----------------*
Function EECTP101()
*-----------------*
Local lRet:=.t.
Local aSemSx3:={}

Private aCampos:={}
Private oProd, oPais, oCLiente, oMoeda
Private aCombo := {STR0001,STR0002,STR0003} //"Pais"###"Cliente"###"Ambos"
Private cProd  := CriaVar("EX5_COD_I"), cPais  := CriaVar("EX5_PAIS"), cCliente:=CriaVar("EX6_CLIENT"),;
        cMoeda := CriaVar("EX6_MOEDA")
Private aCmbStatus:= {"Ativo", "Aguardando Aprovação",STR0003} //"Ativo"###"Aguardando Aprovação"###"Ambos" - HFD              
Private cCombo := aCombo[3], cCmbStatus := aCmbStatus[3]        // HFD
Private nCont  := 0
Private cMarca := GetMark()
Private lInverte := .f.

Begin Sequence

   If !TelaGets()
      lRet:=.f.
      Break
   EndIf

   aSemSx3 := {{"WK_FLAG"   , "C", 02,0},;
               {"WK_COD_I"  , "C", AvSx3("EX5_COD_I" , AV_TAMANHO), 0},;
               {"WK_PAIS"   , "C", AvSx3("EX5_PAIS"  , AV_TAMANHO), 0},;
               {"WK_PAISDES", "C", 60, 0},;              
               {"WK_CLIENT" , "C", AvSx3("EX6_CLIENT", AV_TAMANHO), 0},;
               {"WK_CLIDES" , "C", 60, 0},;                             
               {"WK_CLLOJA" , "C", AvSx3("EX6_CLLOJA", AV_TAMANHO), 0},;
               {"WK_MOEDA"  , "C", AvSx3("EX5_MOEDA" , AV_TAMANHO), 0},;
               {"WK_PRECO"  , "N", AvSx3("EX5_PRECO" , AV_TAMANHO), AvSx3("EX5_PRECO",AV_DECIMAL)},;
               {"WK_DTINI"  , "D", AvSx3("EX5_DTINI" , AV_TAMANHO),0},;
               {"WK_DTFIM"  , "D", AvSx3("EX5_DTFIM" , AV_TAMANHO),0},;
               {"WK_DTAPRO" , "D", AvSx3("EX5_DTAPRO", AV_TAMANHO),0},;
               {"WK_HORA"   , "C", AvSx3("EX5_HORA"  , AV_TAMANHO),0},;
               {"WK_USU"    , "C", AvSx3("EX5_USU"   , AV_TAMANHO),0},;
               {"WK_STATUS" , "C", 60,0}}
               

   aHeader := {}
   cWork := E_CriaTrab(,aSemSx3,"WorkApro")
   IndRegua("WorkApro",cWork+TEOrdBagExt(),"WK_COD_I+WK_PAIS+WK_CLIENT","AllwayTrue()","AllwaysTrue()",STR0004) //"Gerando Arquivo Temporário"

   MsAguarde({|| lRet := TP101Load()},STR0005) //"Filtrando os Dados..."

   If !lRet
      Break
   EndIf

   If !TP101TelaApro()
      Break
   EndIf

   If nCont > 0
      MsgInfo(STR0006,STR0007) //"Aprovação de preços realizada com sucesso."###"Atenção"
   EndIf

End Sequence

If Select("WorkApro") > 0
   WorkApro->(E_EraseArq(cWork))
EndIf

If Select("Qry") > 0
   Qry->(DbCloseArea())
EndIf

Return lRet

/*
Funcao      : TP101TelaApro().
Parametros  : Nenhum.
Retorno     : Lógico (.T./.F.)
Objetivos   : Tela para disponibilizar aprovação de preços marcados.
Autor       : HFD
Data/Hora   : 03.mar.2009
Revisao     :
Obs.        : Variável Private "nAcres" recebe a taxa de acréscimo(capturada em TP101Acres()).
            : Adaptação(TP100TelaApro())
*/
*-----------------------------*
Static Function TP101TelaApro()
*-----------------------------*
Local nChoice := 0
Local lRet:=.t.
Local oDlg
Local aPos:={}, aButtons:={}, aCpos:={}
Local bOk     := {|| If(TP101Valid("TELASEL"),(nChoice := 1,oDlg:End()),nil)},;
      bCancel := {|| oDlg:End() }
Private nAcres := 0
Private oMsSelect

Begin Sequence

   cProd    := If(Empty(cProd),STR0008,cProd) //"Todos"
   cPais    := If(Empty(cPais),STR0008,cPais) //"Todos"
   cMoeda   := If(Empty(cMoeda),STR0009,cMoeda) //"Todas"
   cCliente := If(Empty(cCliente),STR0008,cCliente) //"Todos"
   
   /* Definição das colunas para o browse de seleção de preços 
      para aprovação. */

   aAdd(aCpos,{"WK_FLAG",""," "})
   aAdd(aCpos,{{|| WorkApro->WK_COD_I},"",AvSx3("EX5_COD_I",AV_TITULO)})
   aAdd(aCpos,{{|| AllTrim(WorkApro->WK_PAIS)+" - "+AllTrim(WorkApro->WK_PAISDES)} ,"",AvSx3("EX5_PAIS" ,AV_TITULO)+Space(30)})
  
   If cCombo $ aCombo[2]+"/"+aCombo[3]
      aAdd(aCpos,{{|| AllTrim(WorkApro->WK_CLIENT)+" - "+AllTrim(WorkApro->WK_CLIDES)},"",AvSx3("EX6_CLIENT",AV_TITULO)+Space(20)})
   EndIf
   
   aAdd(aCpos,{{|| WorkApro->WK_MOEDA },"", AvSx3("EX5_MOEDA" ,AV_TITULO)})
   aAdd(aCpos,{{|| Transf(WorkApro->WK_PRECO,AvSx3("EX5_PRECO",AV_PICTURE))} ,"",AvSx3("EX5_PRECO" ,AV_TITULO)})

   aAdd(aButtons,{"LBTIK",{|| MarkAll()},STR0010}) //"Marca/Desmarca Todos"
   
   aAdd(aCpos,{{|| WorkApro->WK_STATUS},"","Status"+Space(20)}) // ###"Status" - HFD

   WorkApro->(DbGoTop())
   
   Define MsDialog oDlg Title STR0019 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //###"Reajuste de Preços - Seleção de Preços"

      @ 15,007 Say AvSx3("EX5_COD_I",AV_TITULO) Size 65,07 Pixel Of oDlg
      @ 15,40  MSGET cProd  Size 099,07  When .f. Pixel Of oDlg

      @ 15,150 Say AvSx3("EX5_PAIS",AV_TITULO)  Size 65,07 Pixel Of oDlg
      @ 15,190 MSGET cPais  Size 80,07 When .f. Pixel Of oDlg

      @ 25,007 Say AvSx3("EX6_MOEDA",AV_TITULO) Size 40,07 Pixel of oDlg
      @ 25,40  MSGET cMoeda Size 080,07  When .f. Pixel OF oDlg

      If (cCombo $ aCombo[2]+"/"+aCombo[3])
         @ 25,150 Say AvSx3("EX6_CLIENT",AV_TITULO) Size 35,07 Pixel of oDlg
         @ 25,190 MSGET cCliente Size 80,07 Pixel OF oDlg When .f.
      EndIf
      
      // HFD - 03.mar.2009 - Inclusão do Status para Rotina de Reajuste de Preço
      @ 25,293 Say "Status" Size 40,07 Pixel of oDlg //###"Status"
      @ 25,320 MSGET cCmbStatus Size 080,07  When .f. Pixel OF oDlg

      aPos := PosDlgDown(oDlg)
      aPos[1] := 36

      oMsSelect := MsSelect():New("WorkApro","WK_FLAG",,aCpos,@lInverte,@cMarca,aPos)
      oMsSelect:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
                                     
   If nChoice = 1
      WorkApro->(DbGoTop())
      
      If TP101Acres()
         Do While WorkApro->(!Eof())
            If !Empty(WorkApro->WK_FLAG)
               TP101Aprova(nAcres)
               nCont++
            EndIf
            WorkApro->(DbSkip())
         EndDo        
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : TP101Valid(cValidacao).
Parametros  : cValidacao - Indica qual validação deverá ser realizada.
Retorno     : .t./.f.
Objetivos   : Verifica se há itens selecionados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 15:51.
Revisao     :
Obs.        : 
*/
*------------------------------------*
Static Function TP101Valid(cValidacao)
*------------------------------------*
Local lRet := .t., lFound:=.f.
Local nRec := 0

Begin Sequence

   cValidacao := Upper(AllTrim(cValidacao))

   Do Case
      Case cValidacao == "TELASEL"
          nRec := WorkApro->(RecNo())
          WorkApro->(DbGoTop())
          Do While WorkApro->(!Eof())
             If !Empty(WorkApro->WK_FLAG)
                lFound:=.t.
                Exit
             EndIf
             WorkApro->(DbSkip())
          EndDo

          WorkApro->(DbGoTo(nRec))
          
          If !lFound
             MsgStop(STR0012,; //"Não há preço marcado para aprovação. Selecione o(s) preço(s) que deseja aprovar."
                     STR0007) //"Atenção"
             lRet:=.f.
             Break
          EndIf
   EndCase

End Sequence

Return lRet

/*
Funcao      : TP101Acres().
Parametros  : Nenhum.
Retorno     : Lógico(.T./.F.)
Objetivos   : Tela de acréscimo dos valores selecionados
Autor       : HFD
Data/Hora   : 03.mar.2008
Revisao     :
Obs.        : Captura a variável Private "nAcres" e a modifica para tornar-se taxa (nAcres/100).
*/     
Static Function TP101Acres()
   Local oDlgAcre, oAcres
   Local lRet    := .F.
   Local bCancel := {|| oDlgAcre:End() }
   Local bOk:={|| lRet:= .T., oDlgAcre:End()}

   Define MsDialog oDlgAcre Title STR0021 From 0,0 To 220,367 Of oMainWnd Pixel //###"Reajuste de preços"
      @ 05,004 To 93,182 LABEL STR0016 Pixel //"Parâmetros Iniciais"

      @ 41,045 Say STR0020 Pixel Of oDlgAcre // ###"Taxa de Reajuste %"
      @ 51,045 MsGet oAcres Var nAcres   Picture "@E 999.999999";
                                         Size 099,08;
                                         Valid(If(Empty(nAcres), (MsgInfo("Favor informar um percentual válido", "Aviso"), .F.), .T.) );
                                         Pixel Of oDlgAcre

   Activate MsDialog oDlgAcre On Init EnchoiceBar(oDlgAcre, bOk, bCancel) Centered
                         
   If lRet 
      nAcres := (nAcres / 100)
      If !MsgYesNo(STR0013,STR0007) //"Confirma a aprovação de preço para o(s) item(ns) marcado(s) ?"###"Atenção"
         lRet := .F. 
      EndIf
   EndIf
Return lRet

/*
Funcao      : TP101Load().
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Filtrar os dados na base de dados.
Autor       : HFD
Data/Hora   : 03.mar.2008
Revisao     :
Obs.        : São tratados os ambientes em Top e CodeBase.
            : Adaptação de TP100Load().
*/
*-------------------------*
Static Function TP101Load()
*-------------------------*
Local lRet:=.t.
Local lTop:= .F.

#IFDEF TOP
   Local cCmd
   Local cSelect, cWhere, cOrder := ""
   lTop:= .T.
#EndIf

Begin Sequence

   //#IfDef Top
   If lTop   
      Do Case
         Case cCombo == aCombo[1] // Pais.
              cSelect := "Select * From "+RetSqlName("EX5")+" EX5 "
              cWhere  := " EX5.D_E_L_E_T_ <> '*' And "+;
                         "EX5_FILIAL = '"+xFilial("EX5")+"' And EX5_PRECO > 0 AND EX5_DTFIM = '        ' "
              
              If cCmbStatus == aCmbStatus[1] // Ativos
                 cWhere += " AND EX5_DTAPRO <> '        '"
              ElseIf cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
                 cWhere += " AND EX5_DTAPRO = '        ' "
              EndIf 
              If !Empty(cProd)
                 cWhere += " And EX5_COD_I = '"+cProd+"' "
              EndIf
              If !Empty(cPais)
                 cWhere += " And EX5_PAIS = '"+cPais+"' "
              EndIf
              If !Empty(cMoeda)
                 cWhere += " And EX5_MOEDA = '"+cMoeda+"' "
              EndIf
              cOrder += "Order By EX5_COD_I"
              cCmd := cSelect+" WHERE "+cWhere+cOrder

         Case cCombo == aCombo[2] // Cliente.
              cSelect := "Select * From "+RetSqlName("EX6")+" EX6 "
              cWhere  := "EX6.D_E_L_E_T_ <> '*' And "+;
                         "EX6_FILIAL = '"+xFilial("EX6")+"' And EX6_PRECO > 0 AND EX6_DTFIM = '        '"

              If cCmbStatus == aCmbStatus[1] // Ativos
                 cWhere += " AND EX6_DTAPRO <> '        '"
              ElseIf cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
                 cWhere += " AND EX6_DTAPRO = '        ' "
              EndIf 
              If !Empty(cProd)
                 cWhere += " And EX6_COD_I = '"+cProd+"' "
              EndIf
              If !Empty(cPais)
                 cWhere += " And EX6_PAIS = '"+cPais+"' "
              EndIf
              If !Empty(cCliente)
                 cWhere += " And EX6_CLIENT = '"+cCliente+"' "
              EndIf
              If !Empty(cMoeda)
                 cWhere += " And EX6_MOEDA = '"+cMoeda+"' "
              EndIf
              cOrder += "Order By EX6_COD_I"
              cCmd := cSelect+" WHERE "+cWhere+cOrder

         Case cCombo == aCombo[3] // Ambos.
              cSelect := "Select EX5_COD_I, EX5_DTAPRO, EX5_MOEDA, EX5_PAIS, EX5_PRECO, '' AS WK_CLIENT From "+RetSqlName("EX5")+" EX5 "
              cWhere  := "EX5.D_E_L_E_T_ <> '*' And "+;
                         "EX5_FILIAL = '"+xFilial("EX5")+"' And EX5_PRECO > 0 AND EX5_DTFIM = '        '"
              
              If cCmbStatus == aCmbStatus[1] // Ativos
                 cWhere += " AND EX5_DTAPRO <> '        '"
              ElseIf cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
                 cWhere += " AND EX5_DTAPRO = '        ' "
              EndIf 
              If !Empty(cProd)
                 cWhere += " And EX5_COD_I = '"+cProd+"' "
              EndIf
              If !Empty(cPais)
                 cWhere += " And EX5_PAIS = '"+cPais+"' "
              EndIf
              If !Empty(cMoeda)
                 cWhere += " And EX5_MOEDA = '"+cMoeda+"' "
              EndIf

              cCmd:= cSelect+" WHERE "+cWhere

              cSelect := " Union "
              cSelect += "Select EX6_COD_I, EX6_DTAPRO, EX6_MOEDA, EX6_PAIS, EX6_PRECO, EX6_CLIENT AS WK_CLIENT From "+RetSqlName("EX6")+" EX6 "
              cWhere  := "EX6.D_E_L_E_T_ <> '*' And "+;
                         "EX6_FILIAL = '"+xFilial("EX6")+"' And EX6_PRECO > 0 AND EX6_DTFIM = '        '"
              
              If cCmbStatus == aCmbStatus[1] // Ativos
                 cWhere += " AND EX6_DTAPRO <> '        '"
              ElseIf cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
                 cWhere += " AND EX6_DTAPRO = '        ' "
              EndIf 
              If !Empty(cProd)
                 cWhere += " And EX6_COD_I = '"+cProd+"' "
              EndIf
              If !Empty(cPais)
                 cWhere += " And EX6_PAIS = '"+cPais+"' "
              EndIf
              If !Empty(cCliente)
                 cWhere += " And EX6_CLIENT = '"+cCliente+"' "
              EndIf
              If !Empty(cMoeda)
                 cWhere += " And EX6_MOEDA = '"+cMoeda+"' "
              EndIf

              cOrder += "Order By EX6_COD_I"
              cCmd += cSelect+" WHERE "+cWhere
      EndCase

      cCmd := ChangeQuery(cCmd)
      DbUseArea(.t.,"TOPCONN", TcGenQry(,,cCmd), "Qry",.f.,.T.)

      If (cCombo $ aCombo[1]+"/"+aCombo[3])
          TcSetField("Qry", "EX5_DTINI" , "D", 8, 0 )
          TcSetField("Qry", "EX5_DTFIM" , "D", 8, 0 )
          TcSetField("Qry", "EX5_DTAPRO", "D", 8, 0 )
          TcSetField("Qry", "EX5_PRECO" , "N", AvSx3("EX5_PRECO",AV_TAMANHO),AvSx3("EX5_PRECO",AV_DECIMAL))
      EndIf

      If (cCombo $ aCombo[2]+"/"+aCombo[3])
         TcSetField("Qry", "EX6_DTINI" , "D", 8, 0 )
         TcSetField("Qry", "EX6_DTFIM" , "D", 8, 0 )
         TcSetField("Qry", "EX6_DTAPRO", "D", 8, 0 )
         TcSetField("Qry", "EX6_PRECO" , "N", AvSx3("EX6_PRECO",AV_TAMANHO),AvSx3("EX6_PRECO",AV_DECIMAL))
      EndIf

      If Qry->(Bof()) .And. Qry->(Eof())
         MsgStop(STR0014,STR0007) //"Não há dados que satisfaçam as condições de filtro."###"Atenção"
         lRet:=.f.
         Break
      EndIf

      Do While Qry->(!Eof())
         WorkApro->(DbAppend())

         Do Case
            Case cCombo == aCombo[1] // Pais.
                 WorkApro->WK_COD_I   := Qry->EX5_COD_I
                 WorkApro->WK_PAIS    := Qry->EX5_PAIS
                 WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))//FSY - 04/07/2013 - Preenche o campo descrição do pais.
                 WorkApro->WK_MOEDA   := Qry->EX5_MOEDA
                 WorkApro->WK_PRECO   := Qry->EX5_PRECO
                 WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))
                 WorkApro->WK_STATUS  := Iif(!Empty(Qry->EX5_DTAPRO),;
                                         "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD

            Case cCombo == aCombo[2] // Cliente.
                 WorkApro->WK_COD_I  := Qry->EX6_COD_I
                 WorkApro->WK_PAIS   := Qry->EX6_PAIS
                 WorkApro->WK_PAISDES:= AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))//FSY - 04/07/2013 - Preenche o campo descrição do pais.
                 WorkApro->WK_CLIENT := Qry->EX6_CLIENT
                 WorkApro->WK_CLLOJA := Posicione("SA1",1, XFILIAL("SA1")+WorkApro->WK_CLIENT, "A1_LOJA" )//FSY - 03/07/2013 - Preenche o campo Cliente Loja na WORK que é gravada na EX6 depois que confirmar o reajuste.
                 WorkApro->WK_CLIDES := AllTrim(Posicione("SA1",1,xFilial("SA1")+Qry->EX6_CLIENT,"A1_NREDUZ"))
                 WorkApro->WK_MOEDA  := Qry->EX6_MOEDA
                 WorkApro->WK_PRECO  := Qry->EX6_PRECO
                 WorkApro->WK_STATUS := Iif(!Empty(Qry->EX6_DTAPRO),;
                                        "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD
  
            Case cCombo == aCombo[3] // Ambos.  
                 If !Empty(Qry->WK_CLIENT)
                    WorkApro->WK_COD_I  := Qry->EX5_COD_I
                    WorkApro->WK_PAIS   := Qry->EX5_PAIS 
                    WorkApro->WK_PAISDES:= AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))//FSY - 04/07/2013 - Preenche o campo descrição do pais.
                    WorkApro->WK_CLIENT := Qry->WK_CLIENT
                    WorkApro->WK_CLLOJA := Posicione("SA1",1, XFILIAL("SA1")+WorkApro->WK_CLIENT, "A1_LOJA" )//FSY - 03/07/2013 - Preenche o campo Cliente Loja na WORK que é gravada na EX6 depois que confirmar o reajuste.
                    WorkApro->WK_CLIDES := AllTrim(Posicione("SA1",1,xFilial("SA1")+Qry->WK_CLIENT,"A1_NREDUZ"))                    
                    WorkApro->WK_MOEDA  := Qry->EX5_MOEDA
                    WorkApro->WK_PRECO  := Qry->EX5_PRECO
                    WorkApro->WK_STATUS := Iif(!Empty(Qry->EX5_DTAPRO),;
                                        "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD
                 Else
                    WorkApro->WK_COD_I  := Qry->EX5_COD_I
                    WorkApro->WK_PAIS   := Qry->EX5_PAIS 
                    WorkApro->WK_PAISDES:= AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))                    
                    WorkApro->WK_MOEDA  := Qry->EX5_MOEDA
                    WorkApro->WK_PRECO  := Qry->EX5_PRECO
                    WorkApro->WK_STATUS := Iif(!Empty(Qry->EX5_DTAPRO),;
                                        "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD
                 EndIf
         EndCase
         Qry->(DbSkip())
      EndDo
     
   //#Else
   Else   
      If (cCombo $ aCombo[1]+"/"+aCombo[3])
         
         Do Case
            Case cCmbStatus == aCmbStatus[1] // Ativos
               EX5->(DbSetFilter({|| !Empty(EX5->EX5_DTAPRO) .AND. Empty(EX5->EX5_DTFIM)},;
                                    "!Empty(EX5->EX5_DTAPRO) .AND. Empty(EX5->EX5_DTFIM)"))
            Case cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
               EX5->(DbSetFilter( {||Empty(EX5->EX5_DTAPRO)}, "Empty(EX5->EX5_DTAPRO)"))
            Case  cCmbStatus == aCmbStatus[2] //Ambos                                   
               EX5->(DbSetFilter( {||Empty(EX5->EX5_DTFIM)}, "Empty(EX5->EX5_DTFIM)")) 
         EndCase
            
                  
         EX5->(DbSetOrder(1))
         EX5->(DbSeek(xFilial("EX5")))
         
         Do While EX5->(!Eof()) 
            
            If EX5->EX5_PRECO = 0  /*.Or. !Empty(EX5->EX5_DTAPRO) */
               EX5->(DbSkip())
               Loop
            EndIf

            If !Empty(cProd)
               If EX5->EX5_COD_I <> AvKey(cProd,"EX5_COD_I")
                  EX5->(DbSkip())
                  Loop
               EndIf
            EndIf

            If !Empty(cPais)
               If EX5->EX5_PAIS <> AvKey(cPais,"EX5_PAIS")
                  EX5->(DbSkip())
                  Loop
               EndIf
            EndIf

            If !Empty(cMoeda)
               If EX5->EX5_MOEDA <> AvKey(cMoeda,"EX5_PAIS")
                  EX5->(DbSkip())
                  Loop
               EndIf
            EndIf

            WorkApro->(DbAppend())
            WorkApro->WK_COD_I   := EX5->EX5_COD_I
            WorkApro->WK_PAIS    := EX5->EX5_PAIS
            WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+EX5->EX5_PAIS,"YA_DESCR"))
            WorkApro->WK_MOEDA   := EX5->EX5_MOEDA
            WorkApro->WK_PRECO   := EX5->EX5_PRECO
            WorkApro->WK_STATUS := Iif(!Empty(EX5->EX5_DTAPRO) .AND. Empty(EX5->EX5_DTFIM),;
                                        "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD
            EX5->(DbSkip())
         EndDo
         EX5->(DbClearFilter())
      EndIf

      If (cCombo $ aCombo[2]+"/"+aCombo[3])
         
         Do Case
            Case cCmbStatus == aCmbStatus[1] // Ativos
               EX6->(DbSetFilter({|| !Empty(EX6->EX6_DTAPRO) .AND. Empty(EX6->EX6_DTFIM)},;
                                    "!Empty(EX6->EX6_DTAPRO) .AND. Empty(EX6->EX6_DTFIM)"))
            
            Case cCmbStatus == aCmbStatus[2] // Aguardando Aprovação
               EX6->(DbSetFilter({|| Empty(EX6->EX6_DTAPRO)}, "Empty(EX6->EX6_DTAPRO)"))
            
            Case cCmbStatus == aCmbStatus[3] // Ambos
               EX6->(DbSetFilter({|| Empty(EX6->EX6_DTFIM)}, "Empty(EX6->EX6_DTFIM)"))
         EndCase 

         EX6->(DbSetOrder(1))
         EX6->(DbSeek(xFilial("EX6"))) 

         Do While EX6->(!Eof())       
            
            If EX6->EX6_PRECO = 0 /*.Or. !Empty(EX6->EX6_DTAPRO) */
               EX6->(DbSkip())
               Loop
            EndIf

            If !Empty(cProd)
               If EX6->EX6_COD_I <> AvKey(cProd,"EX6_COD_I")
                  EX6->(DbSkip())
                  Loop
               EndIf
            EndIf

            If !Empty(cPais)
               If EX6->EX6_PAIS <> AvKey(cPais,"EX6_PAIS")
                  EX6->(DbSkip())
                  Loop
               EndIf
            EndIf

            If !Empty(cCliente)
               If EX6->EX6_CLIENT <> AvKey(cCliente,"EX6_CLIENT")
                  EX6->(DbSkip())
                  Loop
               EndIf
            EndIf

            If !Empty(cMoeda)
               If EX6->EX6_MOEDA <> AvKey(cMoeda,"EX6_PAIS")
                  EX6->(DbSkip())
                  Loop
               EndIf
            EndIf

            WorkApro->(DbAppend())
            WorkApro->WK_COD_I   := EX6->EX6_COD_I
            WorkApro->WK_PAIS    := EX6->EX6_PAIS
            WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+EX6->EX6_PAIS,"YA_DESCR"))
            WorkApro->WK_CLIENT  := EX6->EX6_CLIENT
            WorkApro->WK_CLIDES  := AllTrim(Posicione("SA1",1,xFilial("SA1")+EX6->EX6_CLIENT+EX6->EX6_CLLOJA,"A1_NREDUZ"))
            WorkApro->WK_CLLOJA  := AllTrim(EX6->EX6_CLLOJA)
            WorkApro->WK_MOEDA   := EX6->EX6_MOEDA
            WorkApro->WK_PRECO   := EX6->EX6_PRECO
            WorkApro->WK_STATUS  := Iif(!Empty(EX6->EX6_DTAPRO) .AND. Empty(EX6->EX6_DTFIM),;
                                        "Ativo", "Aguardando Aprovação") // ###"Ativo, ###"Aguardando Aprovação" - HFD
            EX6->(DbSkip())
         EndDo
         EX6->(DbClearFilter())
      EndIf
   
      If WorkApro->(Bof()) .And. WorkApro->(Eof())
         MsgStop(STR0014,STR0007) //"Não há dados que satisfaçam as condições de filtro."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   Endif
   //#EndIf

End Sequence

Return lRet

/*
Funcao      : TelaGets.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para criação dos filtros.
Autor       : HFD
Data/Hora   : 03.mar.2009
Revisao     :
Obs.        : Foi Incluido ComboBox de "status".
            : Adaptação (TelaGets Rotina TP100).
*/
*------------------------*
Static Function TelaGets()
*------------------------*
Local lRet:=.f.
Local oDlg
Local bOk :={|| lRet:=.t., oDlg:End()},;
      bCancel:= {|| oDlg:End()}

Begin Sequence

   Define MsDialog oDlg Title STR0018 From 0,0 To 260,367 Of oMainWnd Pixel //"Reajuste de Preços - Filtros"
   
      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 110, 165) //MCF - 11/09/2015 - Ajustes versão P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @ 1,004 To 93,182 LABEL STR0016 Pixel OF oPanel //"Parâmetros Iniciais"

      @ 17,015 Say "Status" Pixel OF oPanel //###"Status "
      @ 17,050 Combobox cCmbStatus ITEMS aCmbStatus;
                                   Size 80,8 ;
                                   Pixel OF oPanel
                               
      @ 29,015 Say STR0017 Pixel OF oPanel //"Preço "
      @ 29,050 Combobox cCombo ITEMS aCombo;
                               Size 80,8 ;
                               On Change TP101TrataObj();
                               Pixel OF oPanel

      @ 41,015 Say AvSx3("EX5_COD_I",AV_TITULO) Pixel OF oPanel
      @ 41,050 MsGet oProd Var cProd Picture AvSx3("EX5_COD_I",AV_PICTURE);
                                     Size 099,08;
                                     Valid((Empty(cProd) .Or. ExistCpo("SB1")));
                                     F3("EB1") Pixel OF oPanel

      @ 53,015 Say AvSx3("EX5_PAIS",AV_TITULO) Pixel OF oPanel
      @ 53,050 MsGet oPais Var cPais Picture AvSx3("EX5_PAIS",AV_PICTURE);
                                     Size 045,08;
                                     Valid (Empty(cPais) .Or. ExistCpo("SYA"));
                                     F3 "SYA" Pixel OF oPanel

      @ 65,015 Say AvSx3("EX6_CLIENT",AV_TITULO) Pixel OF oPanel
      @ 65,050 MsGet oCliente Var cCliente Picture AvSx3("EX6_CLIENT",AV_PICTURE);
                                           Size 045,08;
                                           Valid (Empty(cCliente) .Or. ExistCpo("SA1"));
                                           F3 "CLI" Pixel OF oPanel

      @ 77,015 Say AvSx3("EX6_MOEDA",AV_TITULO) Pixel OF oPanel // WFS 25/09/2012 - Alinhamento
      @ 77,050 MsGet oMoeda Var cMoeda Picture AvSx3("EX6_MOEDA",AV_PICTURE);
                                       Size 045,08;
                                       Valid (Empty(cMoeda) .Or. ExistCpo("SYF"));
                                       F3 "SYF" Pixel OF oPanel

   Activate MsDialog oDlg On Init EnChoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet

/*
Funcao      : TP101TrataObj.
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Habilitar/Desabilitar objetos na tela de parâmetros.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 11:28.
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function TP101TrataObj(cObj)
*-----------------------------*
Local lRet:=.t.

Begin Sequence

  Do Case
     Case cCombo == aCombo[1] // País.
          oPais:Enable()

          cCliente := CriaVar("EX6_CLIENT")
          oCliente:Disable()

     Case cCombo == aCombo[2] // Cliente
          oCliente:Enable()

          cPais := CriaVar("EX5_PAIS")
          oPais:Disable()

     Case cCombo == aCombo[3] // Ambos.
          oPais:Enable()
          oCliente:Enable()
  EndCase
   
End Sequence

Return lRet


/*
Funcao      : MarkAll
Parametros  : cAlias,oMsSelect
Retorno     : NIL
Objetivos   : Marca/Desmarca Todos
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/2004 15:29
Obs.        : 
*/
*------------------------*
Static Function MarkAll()
*------------------------*
Local cFlag, nRec:=0

Begin Sequence
   nRec := WorkApro->(RecNo())
   cFlag  := IF(!Empty(WorkApro->WK_FLAG),Space(2),cMarca)
   
   WorkApro->(dbGotop())
   WorkApro->(DbEval({||WorkApro->WK_FLAG := cFlag},{|| .t. }))
   WorkApro->(DbGoTo(nRec))
   
   oMsSelect:oBrowse:Refresh()

End Sequence

Return Nil

/*
Funcao      : TP101Aprova.
Parametros  : nAcres -> taxa de acréscimo.
Retorno     : (.T.)
Objetivos   : Com a aprovação da taxa de acréscimo, altera o preço.
Autor       : HFD
Data/Hora   : 03.mar.2008
Obs.        : Caso status seja "Ativo" cria-se um novo registro com status de "Aguardando aprovação",
            : senão apenas altera campo EX#_PRECO.
Obs.2       : EX#_DTINI faz parte da chave primária, haja visto que não pode haver mais de um item por país
            : com status de "Aguardando Aprovação" .
*/
Static Function TP101Aprova(nAcres)

Local lRet:=.t.
Local aOrd:=SaveOrd({"EX5","EX6"})
Local aChaves

//GFP - 19/05/2011
If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("APROV PRECO")
EndIf

Begin Transaction
   If Empty(WorkApro->WK_CLIENT)// ** Aprovação de preço por Produto+Pais(EX5).
      
      // Retira itens com Status "Inativo".
      EX5->(DbSetFilter({|| Empty(EX5->EX5_DTFIM)}, "Empty(EX5->EX5_DTFIM)"))
      EX5->(DbSetOrder(1))                        
      
      If EX5->(DbSeek(xFilial("EX5")+WorkApro->WK_COD_I+WorkApro->WK_PAIS))
         
         Do While EX5->(!Eof())                         .AND.;
                  EX5->EX5_FILIAL == xFilial("EX5")     .AND.;
                  EX5->EX5_COD_I  == WorkApro->WK_COD_I .AND.;
                  EX5->EX5_PAIS   == WorkApro->WK_PAIS

            If Empty(EX5->EX5_DTAPRO)      // Status "Aguardando Aprovação".
               EX5->(RecLock("EX5",.F.))
               EX5->EX5_PRECO := EX5->EX5_PRECO * (1 + nAcres)
               EX5->(MsUnlock())
               EXIT
            Else
               EX5->(DbSkip())                                       // Verifica se o próximo registro é
               If Empty(EX5->EX5_DTAPRO) .AND. EX5->(!Eof() ) .AND.; // Status "Aguardando Aprovação".
                        EX5->EX5_FILIAL == xFilial("EX5")     .AND.;
                        EX5->EX5_COD_I  == WorkApro->WK_COD_I .AND.;
                        EX5->EX5_PAIS   == WorkApro->WK_PAIS      

                  EX5->(RecLock("EX5",.F.))
                  EX5->EX5_PRECO   := WorkApro->WK_PRECO * (1 + nAcres) 
                  EX5->(MsUnlock())
                  EXIT
               Else                                                  // Status "Ativo"
                  EX5->(RecLock("EX5",.T.))
                  EX5->EX5_FILIAL := xFilial("EX5")
                  EX5->EX5_COD_I  := Alltrim(WorkApro->WK_COD_I)
                  EX5->EX5_PAIS   := Alltrim(WorkApro->WK_PAIS )
                  EX5->EX5_MOEDA  := Alltrim(WorkApro->WK_MOEDA)
                  EX5->EX5_PRECO  := WorkApro->WK_PRECO * (1 + nAcres)
                  EX5->EX5_DTAPRO := AvCToD("")
                  EX5->EX5_DTFIM  := AvCToD("")
                  EX5->EX5_DTINI  := AvCToD("")
                  EXIT
               EndIf
            EndIf                                    			
            EX5->(DbSkip())
         EndDo 
      EndIf
      EX5->(DbClearFilter())
   Else                           // ** Aprovação de preço por Protudo+Pais+Cliente (EX6).
      
      // Retira itens com Status "Inativo"
      EX6->(DbSetFilter({|| Empty(EX6->EX6_DTFIM)}, "Empty(EX6->EX6_DTFIM)"))
      EX6->(DbSetOrder(1))
      
      If EX6->(DbSeek(xFilial("EX6")+WorkApro->WK_COD_I+WorkApro->WK_PAIS+WorkApro->WK_CLIENT))

         Do While EX6->(!Eof())                         .AND.;
                  EX6->EX6_FILIAL == xFilial("EX6")     .AND.;
                  EX6->EX6_COD_I  == WorkApro->WK_COD_I .AND.;
                  EX6->EX6_PAIS   == WorkApro->WK_PAIS  .AND.;
                  EX6->EX6_CLIENT == WorkApro->WK_CLIENT

            If Empty(EX6->EX6_DTAPRO)     // Status "Aguardando Aprovação".
               EX6->(RecLock("EX6",.F.))
               EX6->EX6_PRECO := EX6->EX6_PRECO * (1 + nAcres)
               EX6->(MsUnlock())                                          
               EXIT
            Else
               EX6->(DbSkip())                                   // Verifica se o próximo registro é 
               If  Empty(EX6->EX6_DTAPRO)                .AND.;  // Status "Aguardando Aprovação".
                   EX6->(!Eof())                         .AND.;
                   EX6->EX6_FILIAL == xFilial("EX6")     .AND.;
                   EX6->EX6_COD_I  == WorkApro->WK_COD_I .AND.;
                   EX6->EX6_PAIS   == WorkApro->WK_PAIS  .AND.;
                   EX6->EX6_CLIENT == WorkApro->WK_CLIENT
                  
                  EX6->(RecLock("EX6",.F.))
                  EX6->EX6_PRECO   := WorkApro->WK_PRECO * (1 + nAcres)
                  EX6->(MsUnlock())                                          
                  EXIT
               Else                                              // Status "Ativo"
                  EX6->(RecLock("EX6",.T.))         
                  EX6->EX6_FILIAL := xFilial("EX6")
                  EX6->EX6_COD_I  := AllTrim(WorkApro->WK_COD_I)
                  EX6->EX6_PAIS   := AllTrim(WorkApro->WK_PAIS )
                  EX6->EX6_CLLOJA := AllTrim(WorkApro->WK_CLLOJA)
                  EX6->EX6_CLIENT := AllTrim(WorkApro->WK_CLIENT)
                  EX6->EX6_MOEDA  := AllTrim(WorkApro->WK_MOEDA )
                  EX6->EX6_PRECO  := WorkApro->WK_PRECO * (1 + nAcres)
                  EX6->EX6_DTAPRO := AvCToD("")
                  EX6->EX6_DTFIM  := AvCToD("")
                  EX6->EX6_DTINI  := AvCToD("")
                  EXIT
               EndIf
            EndIf
            EX6->(DbSkip())
         EndDo
      EndIf  
      EX6->(DbClearFilter())
   EndIf
End Transaction

//FDR - 21/03/2011 - Tratamento de WorkFlow no Reajuste de Preço
If AvFlags("WORKFLOW")
   EasyGroupWF("APROV PRECO",aChaves)
EndIf

RestOrd(aOrd)

Return lRet
