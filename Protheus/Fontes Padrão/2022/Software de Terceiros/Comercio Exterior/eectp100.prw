#INCLUDE "eectp100.ch"
#include "EEC.cH"

/*
Programa        : EECATP100.
Objetivo        : Rotina de Aprovação de Preços de acordo com os lançamentos da Tabela de Preços.
Autor           : Jeferson Barros Jr.
Data/Hora       : 14/09/04 09:29.
Obs.            :
*/

/*                                            
Funcao      : EECTP100.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Rotina de Aprovação de Preços.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 09:29.
Revisao     :
Obs.        :
*/
*-----------------*
Function EECTP100()
*-----------------*
Local lRet:=.t.
Local aSemSx3:={}

Private aCampos:={}
Private oProd, oPais, oCLiente, oMoeda
Private aCombo := {STR0001,STR0002,STR0003} //"Pais"###"Cliente"###"Ambos"
Private cProd  := CriaVar("EX5_COD_I"), cPais  := CriaVar("EX5_PAIS"), cCliente:=CriaVar("EX6_CLIENT"),;
        cMoeda := CriaVar("EX6_MOEDA"), cCombo := aCombo[3]
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
               {"WK_MOEDA"  , "C", AvSx3("EX5_MOEDA" , AV_TAMANHO), 0},;
               {"WK_PRECO"  , "N", AvSx3("EX5_PRECO" , AV_TAMANHO), AvSx3("EX5_PRECO",AV_DECIMAL)},;
               {"WK_DTINI"  , "D", AvSx3("EX5_DTINI" , AV_TAMANHO),0},;
               {"WK_DTFIM"  , "D", AvSx3("EX5_DTFIM" , AV_TAMANHO),0},;
               {"WK_DTAPRO" , "D", AvSx3("EX5_DTAPRO", AV_TAMANHO),0},;
               {"WK_HORA"   , "C", AvSx3("EX5_HORA"  , AV_TAMANHO),0},;
               {"WK_USU"    , "C", AvSx3("EX5_USU"   , AV_TAMANHO),0}}

   aHeader := {}
   cWork := E_CriaTrab(,aSemSx3,"WorkApro")
   IndRegua("WorkApro",cWork+TEOrdBagExt(),"WK_COD_I+WK_PAIS+WK_CLIENT","AllwayTrue()","AllwaysTrue()",STR0004) //"Gerando Arquivo Temporário"

   MsAguarde({|| lRet := TP100Load()},STR0005) //"Filtrando os Dados..."

   If !lRet
      Break
   EndIf

   If !TP100TelaApro()
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
Funcao      : TP100TelaApro().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para disponibilizar aprovação de preços marcados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 15:21.
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function TP100TelaApro()
*-----------------------------*
Local nChoice := 0
Local lRet:=.t.
Local oDlg
Local aPos:={}, aButtons:={}, aCpos:={}
Local bOk     := {|| If(TP100Valid("TELASEL"),(nChoice := 1, oDlg:End()),nil)},;
      bCancel := {|| oDlg:End() }

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

   WorkApro->(DbGoTop())
   
   Define MsDialog oDlg Title STR0011 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Aprovação de Preços - Seleção de Preços"

      @ 31,007 Say AvSx3("EX5_COD_I",AV_TITULO) Size 65,07 Pixel Of oDlg
      @ 31,40  MSGET cProd  Size 099,07  When .f. Pixel Of oDlg

      @ 31,150 Say AvSx3("EX5_PAIS",AV_TITULO)  Size 65,07 Pixel Of oDlg
      @ 31,190 MSGET cPais  Size 80,07 When .f. Pixel Of oDlg

      @ 41,007 Say AvSx3("EX6_MOEDA",AV_TITULO) Size 40,07 Pixel of oDlg
      @ 41,40  MSGET cMoeda Size /*080*/099,07  When .f. Pixel OF oDlg          // GFP - 24/04/2012

      If (cCombo $ aCombo[2]+"/"+aCombo[3])
         @ 41,150 Say AvSx3("EX6_CLIENT",AV_TITULO) Size 35,07 Pixel of oDlg
         @ 41,190 MSGET cCliente Size 80,07 Pixel OF oDlg When .f.
      EndIf
           
      oMsSelect := MsSelect():New("WorkApro","WK_FLAG",,aCpos,@lInverte,@cMarca)
      oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If nChoice = 1
      WorkApro->(DbGoTop())
      Do While WorkApro->(!Eof())
            
         If !Empty(WorkApro->WK_FLAG)
            TP100Aprova() // Realiza a aprovação do preço.
            nCont++
         EndIf
          
         WorkApro->(DbSkip())
      EndDo        
   EndIf

End Sequence

Return lRet

/*
Funcao      : TP100Valid(cValidacao).
Parametros  : cValidacao - Indica qual validação deverá ser realizada.
Retorno     : .t./.f.
Objetivos   : Efetuar validações diversas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 15:51.
Revisao     :
Obs.        : 
*/
*------------------------------------*
Static Function TP100Valid(cValidacao)
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

          If !MsgYesNo(STR0013,STR0007) //"Confirma a aprovação de preço para o(s) item(ns) marcado(s) ?"###"Atenção"
             lRet:=.f.
             Break
          EndIf
   EndCase

End Sequence

Return lRet

/*
Funcao      : TP100Load().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Filtrar os dados na base de dados.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 11:51.
Revisao     :
Obs.        : São tratados tanto os ambientes em Top e CodeBase.
*/
*-------------------------*
Static Function TP100Load()
*-------------------------*
Local lRet:=.t.

#IfDef Top
   Local cCmd
   Local cSelect, cWhere, cOrder
#EndIf

Begin Sequence

   #IfDef Top
      Do Case
         Case cCombo == aCombo[1] // Pais.
              cSelect := "Select * From "+RetSqlName("EX5")+" EX5 "
              cWhere  := "EX5.D_E_L_E_T_ <> '*' And "+;
                         "EX5_FILIAL = '"+xFilial("EX5")+"' And EX5_DTAPRO = '        ' And EX5_PRECO > 0 "

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
              cCmd := cSelect+cWhere+cOrder

         Case cCombo == aCombo[2] // Cliente.
              cSelect := "Select * From "+RetSqlName("EX6")+" EX6 "
              cWhere  := "EX6.D_E_L_E_T_ <> '*' And "+;
                         "EX6_FILIAL = '"+xFilial("EX6")+"' And EX6_DTAPRO = '        ' And EX6_PRECO > 0 "

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
              cCmd := cSelect+cWhere+cOrder

         Case cCombo == aCombo[3] // Ambos.
              cSelect := "Select EX5_COD_I, EX5_PAIS, "" AS 'WK_CLIENT', EX5_PRECO From "+RetSqlName("EX5")+" EX5 "
              cWhere  := "EX5.D_E_L_E_T_ <> '*' And "+;
                         "EX5_FILIAL = '"+xFilial("EX5")+"' And EX5_DTAPRO = '        ' And EX5_PRECO > 0 "

              If !Empty(cProd)
                 cWhere += " And EX5_COD_I = '"+cProd+"' "
              EndIf
              If !Empty(cPais)
                 cWhere += " And EX5_PAIS = '"+cPais+"' "
              EndIf
              If !Empty(cMoeda)
                 cWhere += " And EX5_MOEDA = '"+cMoeda+"' "
              EndIf

              cCmd:= cSelect+cWhere

              cSelect := "Union "
              cSelect += "Select EX6_COD_I, EX6_PAIS, EX6_CLIENT AS 'WK_CLIENT', EX6_PRECO From "+RetSqlName("EX6")+" EX6 "
              cWhere  := "EX6.D_E_L_E_T_ <> '*' And "+;
                         "EX6_FILIAL = '"+xFilial("EX6")+"' And EX6_DTAPRO = '        ' And EX6_PRECO > 0 "
              
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
              cCmd += cSelect+cWhere
      EndCase

      cCmd := ChangeQuery(cCmd)
      DbUseArea(.t.,"TOPCONN", TcGenQry(,,cCmd), "Qry",.f.,.t.)

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
                 WorkApro->WK_MOEDA   := Qry->EX5_MOEDA
                 WorkApro->WK_PRECO   := Qry->EX5_PRECO
                 WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))

            Case cCombo == aCombo[2] // Cliente.
                 WorkApro->WK_COD_I  := Qry->EX6_COD_I
                 WorkApro->WK_PAIS   := Qry->EX6_PAIS
                 WorkApro->WK_CLIENT := Qry->EX6_CLIENT
                 WorkApro->WK_CLIDES := AllTrim(Posicione("SA1",1,xFilial("SA1")+Qry->EX6_CLIENT,"A1_NREDUZ"))
                 WorkApro->WK_MOEDA  := Qry->EX6_MOEDA
                 WorkApro->WK_PRECO  := Qry->EX6_PRECO
  
            Case cCombo == aCombo[3] // Ambos.  
                 If !Empty(Qry->WK_CLIENT)
                    WorkApro->WK_COD_I  := Qry->EX6_COD_I
                    WorkApro->WK_PAIS   := Qry->EX6_PAIS
                    WorkApro->WK_CLIENT := Qry->WK_CLIENT
                    WorkApro->WK_CLIDES := AllTrim(Posicione("SA1",1,xFilial("SA1")+Qry->WK_CLIENT,"A1_NREDUZ"))                    
                    WorkApro->WK_MOEDA  := Qry->EX6_MOEDA
                    WorkApro->WK_PRECO  := Qry->EX6_PRECO
                 Else
                    WorkApro->WK_COD_I  := Qry->EX5_COD_I
                    WorkApro->WK_PAIS   := Qry->EX5_PAIS 
                    WorkApro->WK_PAISDES := AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry->EX5_PAIS,"YA_DESCR"))                    
                    WorkApro->WK_MOEDA  := Qry->EX5_MOEDA
                    WorkApro->WK_PRECO  := Qry->EX5_PRECO
                 EndIf
         EndCase
         Qry->(DbSkip())
      EndDo
     
   #Else
      If (cCombo $ aCombo[1]+"/"+aCombo[3])
         EX5->(DbSetOrder(1))
         EX5->(DbSeek(xFilial("EX5")))

         Do While EX5->(!Eof()) 

            If !Empty(EX5->EX5_DTAPRO) .Or. EX5->EX5_PRECO = 0
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
            EX5->(DbSkip())
         EndDo
      EndIf

      If (cCombo $ aCombo[2]+"/"+aCombo[3])
         EX6->(DbSetOrder(1))
         EX6->(DbSeek(xFilial("EX6")))

         Do While EX6->(!Eof())

            If !Empty(EX6->EX6_DTAPRO) .Or. EX6->EX6_PRECO = 0
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
            WorkApro->WK_MOEDA   := EX6->EX6_MOEDA
            WorkApro->WK_PRECO   := EX6->EX6_PRECO
            EX6->(DbSkip())
         EndDo
      EndIf
   
      If WorkApro->(Bof()) .And. WorkApro->(Eof())
         MsgStop(STR0014,STR0007) //"Não há dados que satisfaçam as condições de filtro."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   #EndIf

End Sequence

Return lRet

/*
Funcao      : TelaGets.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tela para digitação dos filtros.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 10:18.
Revisao     :
Obs.        :
*/
*------------------------*
Static Function TelaGets()
*------------------------*
Local lRet:=.f.
Local oDlg
Local bOk :={|| lRet:=.t., oDlg:End()},;
      bCancel:= {|| oDlg:End()}

Begin Sequence

   Define MsDialog oDlg Title STR0015 From 0,0 To /*195*/280,367 Of oMainWnd Pixel //"Aprovação de Preços - Filtros"   // GFP - 24/04/2012 - Ajuste para versão M11.5
      
      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 11/09/2015 - Ajustes versão P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @ 15,004 To 095,182 LABEL STR0016 Pixel OF oPanel//"Parâmetros Iniciais"

      @ 27,015 Say STR0017 Pixel OF oPanel //"Preço "
      @ 27,050 Combobox cCombo ITEMS aCombo;
                               Size 80,8 ;
                               On Change TP100TrataObj();
                               Pixel OF oPanel

      @ 39,015 Say AvSx3("EX5_COD_I",AV_TITULO) Pixel OF oPanel
      @ 39,050 MsGet oProd Var cProd Picture AvSx3("EX5_COD_I",AV_PICTURE);
                                     Size 099,08;
                                     Valid((Empty(cProd) .Or. ExistCpo("SB1")));
                                     F3("EB1") Pixel OF oPanel

      @ 51,015 Say AvSx3("EX5_PAIS",AV_TITULO) Pixel OF oPanel
      @ 51,050 MsGet oPais Var cPais Picture AvSx3("EX5_PAIS",AV_PICTURE);
                                     Size 045,08;
                                     Valid (Empty(cPais) .Or. ExistCpo("SYA"));
                                     F3 "SYA" Pixel OF oPanel

      @ 63,015 Say AvSx3("EX6_CLIENT",AV_TITULO) Pixel OF oPanel
      @ 63,050 MsGet oCliente Var cCliente Picture AvSx3("EX6_CLIENT",AV_PICTURE);
                                           Size 045,08;
                                           Valid (Empty(cCliente) .Or. ExistCpo("SA1"));
                                           F3 "CLI" Pixel OF oPanel

      @ 75,015 Say AvSx3("EX6_MOEDA",AV_TITULO) Pixel OF oPanel
      @ 75,050 MsGet oMoeda Var cMoeda Picture AvSx3("EX6_MOEDA",AV_PICTURE);
                                       Size 045,08;
                                       Valid (Empty(cMoeda) .Or. ExistCpo("SYF"));
                                       F3 "SYF" Pixel OF oPanel

   Activate MsDialog oDlg On Init EnChoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet

/*
Funcao      : TP100TrataObj.
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Habilitar/Desabilitar objetos na tela de parâmetros.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/04 11:28.
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function TP100TrataObj()
*-----------------------------*
Local lRet:=.t.

Begin Sequence

  Do Case
     Case cCombo == aCombo[1] // Pais.
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
Funcao      : TP100Aprova.
Parametros  : cAlias,oMsSelect.
Retorno     : NIL.
Objetivos   : Marca/Desmarca Todos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/09/2004 15:29.
Obs.        :
*/
*---------------------------*
Static Function TP100Aprova()
*---------------------------*
Local lRet:=.t.
Local aOrd:=SaveOrd({"EX5","EX6"})

Begin Transaction

   If Empty(WorkApro->WK_CLIENT)
      // ** Aprovação de preço por Protudo+Pais.
      EX5->(DbSetOrder(1))
      If EX5->(DbSeek(xFilial("EX5")+WorkApro->WK_COD_I+WorkApro->WK_PAIS))
         Do While EX5->(!Eof()) .And. EX5->EX5_FILIAL == xFilial("EX5") .And.;
                                      EX5->EX5_COD_I  == WorkApro->WK_COD_I .And.;
                                      EX5->EX5_PAIS   == WorkApro->WK_PAIS

            If (Empty(EX5->EX5_DTFIM) .And. !Empty(EX5->EX5_DTAPRO))
               If EX5->EX5_DTAPRO <> dDataBase

                  // ** Finaliza o período de validade para o preço.
                  If EX5->(RecLock("EX5",.f.))
                     EX5->EX5_DTFIM := dDataBase
                     EX5->(MsUnlock())
                  EndIf
                  Exit
               Else
                  // ** Exclui o preço se a data de aprovação for igual a database.
                  If EX5->(RecLock("EX5",.f.))
                     EX5->(DbDelete())
                  EndIf
               EndIf
            EndIf

            EX5->(DbSkip())
         EndDo
      EndIf

      If EX5->(DbSeek(xFilial("EX5")+WorkApro->WK_COD_I+WorkApro->WK_PAIS))
         Do While EX5->(!Eof()) .And. EX5->EX5_FILIAL == xFilial("EX5") .And.;
                                      EX5->EX5_COD_I  == WorkApro->WK_COD_I .And.;
                                      EX5->EX5_PAIS   == WorkApro->WK_PAIS
            If Empty(EX5->EX5_DTAPRO) 
               If EX5->(RecLock("EX5",.f.))
                  EX5->EX5_DTINI  := dDataBase + 1
                  EX5->EX5_DTFIM  := AvCToD("")
                  EX5->EX5_DTAPRO := dDataBase
                  EX5->EX5_USU    := cUserName
                  EX5->EX5_HORA   := Time()
                  EX5->(MsUnlock())                                 
               EndIf
               Exit
            EndIf
            EX5->(DbSkip())
         EndDo
      EndIf
   Else
      // ** Aprovação de preço por Protudo+Pais+Cliente.
      EX6->(DbSetOrder(1))
      If EX6->(DbSeek(xFilial("EX6")+WorkApro->WK_COD_I+WorkApro->WK_PAIS+WorkApro->WK_CLIENT))
         Do While EX6->(!Eof()) .And. EX6->EX6_FILIAL == xFilial("EX6") .And.;
                                      EX6->EX6_COD_I  == WorkApro->WK_COD_I .And.;
                                      EX6->EX6_PAIS   == WorkApro->WK_PAIS  .And.;
                                      EX6->EX6_CLIENT == WorkApro->WK_CLIENT

            If (Empty(EX6->EX6_DTFIM) .And. !Empty(EX6->EX6_DTAPRO))
               If EX6->EX6_DTAPRO <> dDataBase

                  // ** Finaliza o período de validade para o preço.
                  If EX6->(RecLock("EX6",.f.))
                     EX6->EX6_DTFIM := dDataBase
                     EX6->(MsUnlock())                                          
                  EndIf
                  Exit
               Else
                  // ** Exclui o preço se a data de aprovação for igual a database.
                  If EX6->(RecLock("EX6",.f.))
                     EX6->(DbDelete())
                  EndIf
               EndIf
            EndIf

            EX6->(DbSkip())
         EndDo
      EndIf  

      If EX6->(DbSeek(xFilial("EX6")+WorkApro->WK_COD_I+WorkApro->WK_PAIS+WorkApro->WK_CLIENT))
         Do While EX6->(!Eof()) .And. EX6->EX6_FILIAL == xFilial("EX6") .And.;
                                      EX6->EX6_COD_I  == WorkApro->WK_COD_I .And.;
                                      EX6->EX6_PAIS   == WorkApro->WK_PAIS  .And.;
                                      EX6->EX6_CLIENT == WorkApro->WK_CLIENT
            If Empty(EX6->EX6_DTAPRO) 
               If EX6->(RecLock("EX6",.f.))
                  EX6->EX6_DTINI  := dDataBase + 1
                  EX6->EX6_DTFIM  := AvCToD("")
                  EX6->EX6_DTAPRO := dDataBase
                  EX6->EX6_USU    := Substr(cUsuario,7,15)
                  EX6->EX6_HORA   := Time()
                  EX6->(MsUnlock())
               EndIf
               Exit
            EndIf
            EX6->(DbSkip())
         EndDo
      EndIf
   EndIf

End Transaction

RestOrd(aOrd)

Return lRet
*-----------------------------------------------------------------------------------------------------------------*
*                                           FIM DO PROGRAMA EECTP100                                              *
*-----------------------------------------------------------------------------------------------------------------*
