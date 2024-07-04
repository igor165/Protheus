#include "AVERAGE.CH" 
#include "AVFRM105.CH" 
#Include "TOPCONN.CH"
#define CAPA			"1"
#define CAPA_DETALHE 	"2"

/*
Funcao      : AvCentIntegracao().
Objetivos   : Criar tela para controle de serviços.                                             
Sintaxe     : AvCentIntegracao()
Parametros  : aServ, aOpc, cDlgTit, cTreeTit, cTreeOpcTit, cRaizTit, cRaizTitOpc 
Retorno     : 
Autor       : Fabrício Romera
Data/Hora   : 19/10/09 - 16:30.
Revisao     :
Obs.        : 1) aServ:          [1] - cNome          - Descrição do Serviço.
                                 [2] - cAlias         - Alias da Tabela de Serviço.
                                 [3] - cID*           - ID para controle interno.
                                 [4] - aPastas        - Array de itens do Serviço:
                                                        [1]  - cNomeItem      - Descricao do Item
                                                        [2]  - cID*           - ID para controle interno
                                                        [3]  - cChave         - Chave de busca para filtro dos itens(filtro das works), 
                                                                               conforme indice informado (parametro [5])
                                                        [4]  -[aCampos]       - Array de campos do MsSelect
                                                        [5]  - Resource Open  - Imagem apresentada quando galho estiver aberto
                                                        [6]  - Resource Close - Imagem apresentada quando galho estiver aberto                                 
                                                        [7]  - cCampoMark     - Nome do Campo para controle de Marca e Desmarca no MsSelect.
                                                                               Se não preenchido marca e desmarca não será utilizado.
                                                        [8]  - bCampoMark     - Bloco de Código a ser executado no momento da marcação de um registro.
                                                        
                                                        Bruno Akyo Kubagawa - 13 de Abril de 2011
                                                        [9]  - bAvalCapa      - Bloco de Código a ser executado no momento do duplo clique em um 
                                                                                registro da capa (bAval da select correspondente)
                                                        [10] - bAvalDetail    - Bloco de Código a ser executado no momento do duplo clique em um 
                                                                                registro do detail (bAval da select correspondente)
                                                        
                                 [5] -[aCampos]       - Array de campos do MsSelect
                                 [6] - nOrdem         - Ordem do indice utilizado para filtro das works
                                 [7] - Resource Open  - Imagem apresentada quando galho estiver aberto
                                 [8] - Resource Close - Imagem apresentada quando galho estiver aberto
                                 [9] - cTitCapa       - Titulo (descritivo) da tabela capa
                                 [10]- cAliasDet      - Alias da tabela de detalhes
                                 [11]- cTitDet        - Titulo (descritivo) da tabela detalhes
                                 [12]- Chave da tabela de detalhes
                                 [13]- Macro para obter conteúdo da chave da tabela de detalhes
                                 [14]- Codeblock a ser executado ao clicar nos itens da capa
                                 
                                 
              2) aOpc: Array de opções dos Serviços
                                 [1] - cNomeOpc     - Descricao da Opção
                                 [2] - cID          - ID para controle interno
                                 [3] - aRestricoes  - Array com ID dos itens que possuem a
                                                      opção.                              
                                 [4] - bAcao        - Bloco de codigo com a ação a ser 
                                                      executada.                                                                            
                                 [5] - cStatus      - Caracter de controle de status de 
                                                      execução da ação, conforme campos status da base.
                                 [6] - Resource Open  - Imagem apresentada quando galho estiver aberto
                                 [7] - Resource Close - Imagem apresentada quando galho estiver aberto                                 


              3) cDlgTit       
              4) cTreeTit        
              5) cTreeTitOpc              
              6) cRaizTit                                                      
              7) cRaizTitOpc
              8) cPanelTit                                        
              9) bOkEncBar: Bloco de código com ação p/ o botão Ok da Enchoice Bar. 
                            Se NIL EnchoiceBar é omitida.
             10) bCancEncBar: Bloco de código com ação p/ o botão Cancel da Enchoice Bar
                              Se NIL EnchoiceBar é omitida.
             11) cRaizImg - Imagem para a raiz do tree de serviços.
             12) cRaiImgOpc - Imagem para a raiz do tree de ações
             13) lRefresh - Determina se as works serão atualizadas durante a execução da central, após a execução de ações ou troca de pastas.
             14) lCapaDet - Permite exibir os registro no formato capa/detalhe no browse de arquivos.
             15) bAvalItem - Ação a ser executada no duplo clique sobre o browse de detalhes de arquivos.
             16) bAvalLote - Ação a ser executada no duplo clique sobre o browse de arquivos.
             17) lAtuActions - Determina se o tree de ações será atualizado a cada troca de pastas, inibindo as ações não disponíveis.
                              
             *Importante: A quantidade de caracteres do ID de um item mais a quantidade de caracteres do ID do 
                          serviço ao qual esse item pertence deve ser menor ou igual a 7.
                          Exemplo: SV1ITE1  (Permitido)
                                   SERV1I2  (Permitido)
                                   SERV1IT1 (Ñ Permitido)   
*/ 

Function AvCentIntegracao(aServ, aOpc, cDlgTit, cTreeTit, cTreeOpcTit, cRaizTit, cRaizTitOpc, cPanelTit, bOkEncBar, bCancEncBar, cRaizImg, cRaizImgOpc, lRefresh, lCapaDet,bAvalItem,bAvalLote,lAtuActions)
   Local aTree, aTreeOpc[0]
   Local cAlias            
   Local i, j
   Private lOpc          
   Private nMaxItem := 0, nPosEncBar := 0
   //RMD
   Private cTipoBrw := CAPA
   Private nLinA, nLinB, nLinC, nLinD, nLinE, nLinF, nLinG, nLinH
   Private nCol1, nCol2, nCol3, nCol4  
   Private nTamGet    := 10, nAltGet := 10
   Private nBordGetSup := 2, nBordGetLat := 1
   Private aRelFilter := {}
   
   Private oFont1 := TFont():New(,,22,, .T.)
   Private oFont2 := TFont():New("ARIAL",,18,, .T.)
   Private oFont3 := TFont():New(,,15,, .T.) 
   
   Private aServPvt := aServ
   
   Private aTots := GetTotReg(aServ)
   Private lUseAlias := IsInCallStack("EECEI300") .Or. IsInCallStack("EECEI200") .Or. IsInCallStack("EICDI100") .Or. IsInCallStack("ESSCA100") .Or. IsInCallStack("ESSCV100")//RMD - 30/10/19 - Adiciona a integração com o Siscomex Importação na lista de rotinas que utilizam a base de dados no lugar de temporários
   
   //Verifica se todos os parametros foram informados, e considera como NULL os ñ informados
   For i:= 1 to Len(aServ)
      //Verifica parametros do array de serviços
      While Len(aServ[i]) < 8
         aAdd(aServ[i], Nil)
      End
      
      For J := 1 to Len(aServ[i][4])
         //Verifica parametro do array de itens         
         While Len(aServ[i][4][J]) < 8
            aAdd(aServ[i][4][J], Nil)
         End
      Next
   Next

   //Arrays de Coordenadas de Tela
   Private aTreeServPos[0], aTreeOpcPos[0], aSelPos[0], aPos[0],aPosDlg, aDetPos := {}

   //Objetos de Tela
   Private oDlg, oTree, oTreeOpc, oScrollBox, oSelect, oSRAIZ

   //Verifica se EnchoiceBar será habilitada e preenche variavel de reposicionamento de objetos de tela
   If Empty(bOkEncBar) .Or. Empty(bCancEncBar)
      nPosEncBar := 0
   Else
      nPosEncBar := 15
   EndIf

   //Objetos de referentes a serviços e itens
   For i:= 1 to Len(aServ)
      //Serviços
      Private &("oS"+aServ[i][3])  := NIL
      Private &("oS"+aServ[i][3]+"D")  := NIL
      Private &("oG2"+aServ[i][3])  := NIL
      Private &("oG1"+aServ[i][3])  := NIL
      Private &("oPn"+aServ[i][3])   := NIL //Objeto Panel      
      Private &("oY"+aServ[i][3])    := NIL //Objeto Say do Tit. Serviço                        
      Private &("cD"+aServ[i][3]) := ""     //Titulo do Serviço                  
                    
      //Itens
      For J := 1 to Len(aServ[i][4])
         Private &("oS" +aServ[i][3]+aServ[i][4][j][2]) := NIL
         Private &("oS" +aServ[i][3]+aServ[i][4][j][2]+"D") := NIL
         Private &("oG1" +aServ[i][3]+aServ[i][4][j][2]) := NIL
         Private &("oG2" +aServ[i][3]+aServ[i][4][j][2]) := NIL
         Private &("oY"   +aServ[i][3]+aServ[i][4][j][2]) := NIL   //Objeto Say do Tit. Item                               
         Private &("cWk"  +aServ[i][3]+aServ[i][4][j][2]) := (If(lUseAlias, "", "WK_") +aServ[i][3]+aServ[i][4][j][2])
         Private &("cF"   +aServ[i][3]+aServ[i][4][j][2]) := ""
         Private &("cD"   +aServ[i][3]+aServ[i][4][j][2]) := ""         
      Next     
               
      //Guarda o número maximo de itens para um serviço               
      J:= J - 1            
      nMaxItem := IIf(J > nMaxItem,J, nMaxItem)
   Next            
       
   //Cria says a mais para o serviço principal, caso haja algum serviço com mais itens do que o primeiro serviço.
   For i:= 1 to (nMaxItem - Len(aServ[1][4]))
      Private &("oY" + "Extra" + AllTrim(Str(i))) := NIL   //Objeto Say do Tit. Item extra                                                    
   Next
   
   //Variavel que Guarda o ID do MsSelect ativo                                                                                         
   Private cIdSel := "RAIZ"
   
   Private aAcoes    := aOpc
   Private cTitAcoes := cRaizTitOpc
   Private cImgAcoes := cRaizImgOpc

	//RMD - 23/08/12 - Tratamento específico para manter arquivos de trabalho - Vide EECAE109.
	__KeepUsrFiles := .F.
	If FindFunction("EECSetKeepUsrFiles")
		EECSetKeepUsrFiles()
	EndIf

   Default lCapaDet := .F.
   Default lAtuActions := .T.
   
   If !lCapaDet
      cTipoBrw := CAPA
   Else
      cTipoBrw := CAPA_DETALHE
   EndIf
                      
   //Monta aTree                                  
   lOpc     := !Empty(aAcoes)   
   aTree    := MontaTree(aServ, cRaizTit, cRaizImg)
   aTreeOpc := IIf(lOpc, MontaTreeOpc(aAcoes, cTitAcoes, cImgAcoes), {})
   
   //Cria Tela
   DEFINE MSDIALOG oDlg TITLE cDlgTit FROM DLG_LIN_INI, DLG_COL_INI;
                                        TO DLG_LIN_FIM, DLG_COL_FIM;
                                        OF oMainWnd PIXEL

   //Preenche Variaveis de Coordenadas                                     
   aPos := PosDlg(oDlg)       
   CoordTree(oDlg)

   //Titulo das Trees
   @ nLinA, nCol1 MSGET cTreeTit    SIZE nCol2-nBordGetLat, nAltGet FONT oFont2 WHEN .F. PIXEL OF oDlg //Serv.
   @ nLinE, nCol1 MSGET cTreeOpcTit SIZE nCol2-nBordGetLat, nAltGet FONT oFont2 WHEN .F. PIXEL OF oDlg //Opc.

   //Tree de Itens e Opcoes
   oTree    := AvTree(aTree,aTreeServPos,,oDlg)
   oTreeOpc := AvTree(aTreeOpc,aTreeOpcPos,,oDlg)
   If lOpc
      AbreTree(oTree, aServ, oTreeOpc, aAcoes)
   Else
      AbreTree(oTree, aServ, oTreeOpc, aAcoes)
   End If

   //Cria Works
   If !lUseAlias
      CriaWork(aServ) 
   EndIf
   
   //OAP
   CriaSelect(aServ,bAvalItem,bAvalLote)
   //CriaSelect(aServ,bAvalItem)
   
   CriaInterfaceGer(aServ,aPos[4]-aTreeOpcPos[4] - AVG_CORD(2),AVG_CORD(223), cPanelTit)

   //Trata Eventos da Tela
   oTree:bChange := {|| ExibeSel(oTree:GetCargo(), aServ, lAtuActions)}
   If lOpc
      oTreeOpc:bLDblClick := {|| ExecOpc(aAcoes, oTreeOpc:GetCargo(), oTree:GetCargo())}
   End If
   cIdSel := "oSRAIZ"

   oDlg:lMaximized := .T.

   If nPosEncBar > 0 //Verifica se EnchoiceBar estará habilitada
      ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOkEncBar, bCancEncBar)
   Else
      ACTIVATE MSDIALOG oDlg CENTERED 
   End If

   //Exclui arquivos de trabalho
   ExcluiWork(aServ)

Return
  
          
/*
Função    : CriaSelect
Objetivos : Função de criação dos objetos MSSelect da tela
Parametros: aServ
Retorno   : -
Autor     : Fabrício Romera 
*/
Static Function CriaSelect(aServ,bAvalItem,bAvalLote)
   Local i, j
   Local aCampos, aCamposTemp:= {}
   Local bCampoMark, nCont
   Local cAlias, cAliasDet, cAliasWK, cId, cIdDet, cCampoMark, cBlocoCod, cTitCapa, cTitDet
   Local aBufCposDet := {}, nPosBf//RMD
   Private lInverte := .F.
   Private cMarca   := GetMark()

   //Servicos
   For i:=1 to Len(aServ)
   
      cId       := "oS"+aServ[i][3]
      cAlias    := aServ[i][2]
      If cTipoBrw == CAPA_DETALHE
         cTitCapa  := aServ[i][9]
         cAliasDet := aServ[i][10]
         cTitDet   := aServ[i][11]
         cCpoDet   := aServ[i][12]
         cCpoCapa  := aServ[i][13]
         cExecAc   := If(ValType(aServ[i][14]) == "C", aServ[i][14], ".T.")
      EndIf

      //Define aCampos
      If !EMPTY(aServ[i][5])
         aCampos := ArrayBrowse(cAlias)
      EndIf


      //Cria oSelect com o nome correspondente
      &(cId) := MsSelect():New(cAlias,,, aCampos, @lInverte, @cMarca,aSelPos,,, oDlg)
      //Esconde oSelect
      &(cId):oBrowse:Hide()

      //Itens
      For J:= 1 to Len(aServ[i][4])

         cId        := "oS" +aServ[i][3]+aServ[i][4][j][2]
         cIdSel     := cId
         cIdDet		:= "oS" +aServ[i][3]+aServ[i][4][j][2]+"D"
         cIdGet1    := "oG1" +aServ[i][3]+aServ[i][4][j][2]
         cIdGet2    := "oG2" +aServ[i][3]+aServ[i][4][j][2]
         cAliasWK   := ("WK_" +aServ[i][3]+aServ[i][4][j][2])
         If cTipoBrw == CAPA_DETALHE
            cCampoMark := aServ[i][4][j][7]
            bCampoMark := aServ[i][4][j][8]
            If (nPosBf := aScan(aBufCposDet, {|x| x[1] == cAliasDet })) == 0//RMD - 30/10/19 - Buffer para reaproveitar as informações quando houver mais de uma pasta com o mesmo Alias
               aCamposDet := ArrayBrowse(cAliasDet,,,.T.)
               aAdd(aBufCposDet, {cAliasDet, aClone(aCamposDet) })
            Else
               aCamposDet := aBufCposDet[nPosBf][2]
            EndIf
         EndIf
                 
         If !EMPTY(aServ[i][4][j][4])
            aCamposTemp:= AClone(aServ[i][4][j][4])
            aCampos:= {}
            For nCont:= 1 To Len(aCamposTemp)
               AAdd(aCampos, ColBrw(aCamposTemp[nCont], cAlias, If(lUseAlias, Nil, cAliasWK)))
            Next
         Else
            aCampos := ArrayBrowse(cAlias, If(lUseAlias, Nil, cAliasWK))
         End If
         
         If !Empty(cCampoMark)            
            cBlocoCod := "{|| "+cAliasWK+"->("+cCampoMark+")}"
            aAdd(aCampos,) 
            aIns(aCampos,1)
            aCampos[1] := {cCampoMark,,"",}
         End If

         //Cria oSelect com o nome correspondente
         If lUseAlias
	         (cAlias)->(DbSetOrder(aServ[i][6]))
	         (cAlias)->(DbGoTop())
	         cFiltro := "FRM105Filter('"+xFilial(cAlias)+aServ[i][4][j][3]+"')"
	         &(cId) := MsSelect():New(cAlias /*cAliasWK*/,cCampoMark,,aCampos,@lInverte,@cMarca,aSelPos,cFiltro, cFiltro, oDlg)
         Else
             &(cId) := MsSelect():New(cAliasWK,cCampoMark,,aCampos,@lInverte,@cMarca,aSelPos,,, oDlg)
         EndIf
         
         //OAP
         //If ValType(bAvalLote) == "B"
         //   &(cId):bAval := bAvalLote//   &("{|| EI300VLote() }")
         //EndIf 
         // BAK - 13/04/2011  
         If Len(aServ[i][4][j]) >= 9 .And. !Empty(aServ[i][4][j][9])// Verificando se o bAval esta sendo utilizada a partir do vetor aServ
            Do Case
               Case ValType(aServ[i][4][j][9]) == "C"
                  &(cId):bAval := &("{|| Eval(" + aServ[i][4][j][9] + ", " + cId + ")}")
               Case ValType(aServ[i][4][j][9]) == "B" 
                  &(cId):bAval := aServ[i][4][j][9]
            End Case
         ElseIf ValType("bAvalLote") <> "U" //Verificando se o bAval esta sendo utilizado da chamada da função AvCentIntegracao
            Do Case
               Case ValType(bAvalLote) == "C"
                  &(cId):bAval := &("{|| Eval(" + bAvalLote + ", " + cId + ")}")
//                  &(cId):bAval := &("{|| " + bAvalLote +" }")
               Case ValType(bAvalLote) == "B"
                  &(cId):bAval := bAvalLote
            End Case
         EndIf 

         If cTipoBrw == CAPA_DETALHE
            If lUseAlias
	            &(cId):oBrowse:bChange := &("{|| " + GetAlias(aServ[i][3]+aServ[i][4][j][2]) + "->(" + cExecAc + ", FilterDet()) }")
	        Else
                &(cId):oBrowse:bChange := &("{|| " + cAliasWK + "->(" + cExecAc + ", FilterDet()) }")
	        EndIf

            @nLinA, nCol3 MSGET &(cIdGet1) VAR cTitCapa SIZE nCol4-nCol3, nAltGet WHEN .F. PIXEL OF oDlg
            @nLinE, nCol3 MSGET &(cIdGet2) VAR cTitDet  SIZE nCol4-nCol3, nAltGet WHEN .F. PIXEL OF oDlg
         
            &(cIdGet1):Hide()
            &(cIdGet2):Hide()

            &(cIdDet) := MsSelect():New(cAliasDet,,,aCamposDet,@lInverte,@cMarca,aDetPos,,, oDlg)

            /*
            If ValType(bAvalItem) == "C"
               &(cIdDet):bAval := &("{|| " + cAliasDet + "->(If(Eval(" + cIdDet + ":oBrowse:bInRange), Eval(" + bAvalItem + ", " + cIdDet + "), ))}") //bAvalItem //&("{|| EI300VisDet() }")
            Else
               &(cIdDet):bAval := &("{|| FRM105VisDet('" + cAliasDet + "') }")
            EndIf*/ 
            // BAK - 13/04/2011
            If Len(aServ[i][4][j]) >= 10 .And. !Empty(aServ[i][4][j][10])// Verificando se o bAval esta sendo utilizada a partir do vetor aServ
               Do Case
                  Case ValType(aServ[i][4][j][10]) == "C"
                     &(cIdDet):bAval := &("{|| Eval(" + aServ[i][4][j][10] + ", " + cIdDet + ")}")
                  Case ValType(aServ[i][4][j][10]) == "B" 
                     &(cIdDet):bAval := aServ[i][4][j][10]
                  End Case
            ElseIf ValType("bAvalItem") <> "U" // Verificando se o bAval esta sendo utilizado da chamada da função AvCentIntegracao
               Do Case
                  Case ValType(bAvalItem) == "C"
                     &(cIdDet):bAval := &("{|| " + cAliasDet + "->(If(Eval(" + cIdDet + ":oBrowse:bInRange), Eval(" + bAvalItem + ", " + cIdDet + "), ))}")
                  Case ValType(bAvalItem) == "B"
                     &(cIdDet):bAval := bAvalItem
               End Case
            Else
               &(cIdDet):bAval := &("{|| FRM105VisDet('" + cAliasDet + "') }")
            Endif
  
            &(cIdDet):oBrowse:bWhen := &("{|| dbSelectArea('"+cAliasDet+"'),.T.}")

            If lUseAlias
	            aAdd(aRelFilter, {cAlias, &(cIdDet), cCpoDet, cCpoCapa, aServ[i][3]+aServ[i][4][j][2]})
            Else
				aAdd(aRelFilter, {cAliasWK, &(cIdDet), cCpoDet, cCpoCapa})
            EndIf

            FilterDet()
            &(cIdDet):oBrowse:Hide()

         EndIf

         //Implementa bloco de codigo a ser executado no momento da marcação/desmarcação de um registro.                            
         If !Empty(cCampoMark) .And. !Empty(bCampoMark)            
            &(cId):bMark :=  bCampoMark
         End If

         //Esconde oSelect
         &(cId):oBrowse:Hide()
      Next
   Next
Return

Static Function FilterDet()
Local cAlias
Local cAliasWK := AllTrim(StrTran(cIdSel, "oS", "WK_"))
Local oSelectDet, cCpoDet, cCpoCapa
Local nPos
Local lFound := .F.

   If lUseAlias
      lFound := (nPos := aScan(aRelFilter, {|x| x[5] == SubStr(cIdSel, 3) })) > 0
   Else
      lFound := (nPos := aScan(aRelFilter, {|x| x[1] == cAliasWK })) > 0
   EndIf
   
   If lFound
      cAlias     := aRelFilter[nPos][1]
      oSelectDet := aRelFilter[nPos][2]
      cCpoDet    := aRelFilter[nPos][3]
      cCpoCapa   := aRelFilter[nPos][4]
      If lUseAlias
         oSelectDet:oBrowse:SetFilter(cCpoDet, (cAlias)->&(cCpoCapa), (cAlias)->&(cCpoCapa))
      Else
         oSelectDet:oBrowse:SetFilter(cCpoDet, (cAliasWK)->&(cCpoCapa), (cAliasWK)->&(cCpoCapa))
      EndIF
      oSelectDet:oBrowse:Refresh()
   EndIf

Return Nil


/*
Função    : ExecOpc
Objetivos : Função de criação dos objetos MSSelect da tela
Parametros: aOpc, cOpc, cIdSel
Retorno   : -
Autor     : Fabrício Romera
Data      : 21/10 - 17:14
Obs       : aOpc   : Vetor de Opções
            cOpc   :
            cIdSel : Id do item selecionado
*/
Static Function ExecOpc(aOpc, cOpc, cIdSel)
   Local nPos:=0, nOpc:=0
   Local aRestr[0]    
   Local bAcao         
   Local cAliasWK := If(lUseAlias, GetAlias(cIdSel), "WK_"+AllTrim(cIdSel))
                                  
   Begin Sequence          
      //Busca informações da opcao selecionada
      While nOpc = 0 .And. nPos < Len(aOpc)       
         nPos := nPos + 1
         nOpc := aScan(aOpc[nPos], AllTrim(cOpc)) 
      End     

      If nOpc = 0
         BREAK        
      End If
   
      //Verifica se opcao é valida para o item selecionado
      If (aScan(aOpc[nPos][3], {|x| x == AllTrim(cIdSel)} ) = 0) .Or. Empty(cAliasWK)
         MsgInfo(STR0001, STR0002) // "Opção indisponível para o serviço selecionado.", "Aviso"
         BREAK
      End If
      
      //Seleciona area de trabalho ativa para que seja acessivel ao usuario
      If Select(cAliasWK) > 0 
         DbSelectArea(cAliasWK)
      End If
                        
      //Executa opcao
      Eval(aOpc[nPos][4], cAliasWK, cIdSel)
      
      aTots := Nil
      
      AvAtuCentrInt(If(lUseAlias, cIdSel, Nil), aServPvt)
            
   End Sequence
   If !empty(cAliasWK) .and. Select(cAliasWK) > 0 
      (cAliasWK)->(DBGOBOTTOM())
   EndIf   
Return

Static Function GetAlias(cIdSel)
Local cAlias := ""
Local i, j

    cIdSel := StrTran(cIdSel, "oS", "")

    For i := 1 To Len(aServPvt)
            For j := 1 To Len(aServPvt[i][4])
                If AllTrim(cIdSel) == aServPvt[i][3]+aServPvt[i][4][j][2]
                        cAlias := aServPvt[i][2]
                        Exit
                EndIf
            Next
    Next

Return cAlias

Static Function GetIndex(cIdSel)
Local nIndex := 1
Local i, j

	cIdSel := StrTran(cIdSel, "oS", "")

	For i := 1 To Len(aServPvt)
		For j := 1 To Len(aServPvt[i][4])
			If AllTrim(cIdSel) == aServPvt[i][3]+aServPvt[i][4][j][2]
				nIndex := aServPvt[i][6]
				Exit
			EndIf
		Next
	Next

Return nIndex

/*
Função    : MontaTree
Objetivos : Função que retorna Tree de serviços
Parametros: aServ, cRaizTit
Retorno   : aTree
Autor     : Fabrício Romera
Data      : 
Obs       : aServ    : Array de Serviços
            cRaizTit : Descrição da raiz da Tree 
*/
Static Function MontaTree(aServ, cRaizTit, cImgRaiz)
   Local aTree := {}                                                               
   Local nCod := 1                                                        
   Local i,j                                                             
                 
   //Raiz   
   aAdd(aTree, {;
                "",;                          //Cod.
                cRaizTit,;                    //Descr.                   
                "RAIZ",;                      //Cargo           
                cImgRaiz,;                    //Resource Open
                cImgRaiz,;                    //Resource Close                                                         
                StrZero(0,4),;                 //Link                                       
               })         
              
   //Varre vetor de servicos e cria estrutura de itens e subitens do aTree   
   For i:=1 to Len(aServ)
      //Galhos
      aAdd(aTree, {;
                   StrZero(0,4),;              //Cod.
                   aServ[i][1],;              //Descr.
                   aServ[i][3],;              //Cargo
                   aServ[i][7],;             //Resource Open
                   aServ[i][8],;             //Resource Close
                   StrZero((++nCod),4),;       //Link                                       
                  })   
      //Folhas       
      For J:= 1 to Len(aServ[i][4])     
         aAdd(aTree, {; 
                      StrZero(nCod,4),;        //Cod.
                      aServ[i][4][j][1],;     //Descr.                   
                      aServ[i][3]+;
                      aServ[i][4][j][2],;     //Cargo           
                      aServ[i][4][j][5],;     //Resource Open
                      aServ[i][4][j][6],;     //Resource Close                                                         
                      "",;  			      //Link                                                        
                     })   
      Next          
                                                              
      nCod++
      
   Next
            
Return aTree   


/*
Função    : MontaTreeOpc
Objetivos : Função que retorna Tree de opções
Parametros: aOpc, cRaizTit
Retorno   : aTree
Autor     : Fabrício Romera
Data      : 
Obs       : aOpc     : Array de Opções
            cRaizTit : Descrição da raiz da Tree 
*/
Static Function MontaTreeOpc(aOpc, cRaizTit, cImgRaizOpc)
   Local aTree := {}
   Local nCod := 1
   Local i

   If ValType(oTreeOpc) == "O"
      If oTreeOpc:TreeSeek("RAIZ")
         oTreeOpc:DelItem("RAIZ")
      EndIf
   EndIf

   //Raiz   
   aAdd(aTree, {;
                "",;                          //Cod.
                cRaizTit,;                    //Descr.                   
                "RAIZ",;                      //Cargo           
                cImgRaizOpc,;                 //Resource Open
                cImgRaizOpc,;                 //Resource Close                                                         
                StrZero(0,4),;                 //Link                                       
               })

   //Varre vetor de servicos e cria estrutura de itens e subitens do aTree
   For i:=1 to Len(aOpc)
      If aScan(aOpc[i][3], StrTran(cIdSel, "oS", "")) > 0
         //Galhos
         aAdd(aTree, {;
                      StrZero(0,4),;              //Cod.
                      aOpc[i][1],;               //Descr.
                      aOpc[i][2],;               //Cargo
                      aOpc[i][6],;               //Resource Open
                      aOpc[i][7],;               //Resource Close                                                         
                      StrZero((++nCod),4),;       //Link                                       
                     })   
                                                              
         nCod++
      EndIf
      
   Next
            
Return aTree

                           
/*                                                                                   
Função    : CoordTree
Objetivos : Função que preenche variaveis de coordenadas
Parametros: -
Retorno   : -
Autor     : Fabrício Romera
Data      : 20/10 - 15:57 
*/
Static Function CoordTree(oDlg)                                                                    
Local nLinFin

If SetMdiChild()
   nLinFin:= aPos[3]-AVG_CORD(4)
Else
   nLinFin:= aPos[3]-AVG_CORD(2)
EndIf

   nAltura  := int((oDlg:nBottom-oDlg:nTop)/2) - 13 - (2*(nBordGetSup+nAltGet))
   nLargura := int((oDlg:nRight-oDlg:nLeft)/2)
   
   nCol1 := 2
   nCol2 := 95
   nCol3 := nCol2
   nCol4 := nLargura

   nLinA := 0
   nLinC := nLinA + nBordGetSup+nAltGet
   nLinD := nLinC + (nAltura*0.52)
   nLinE := nLinD
   nLinF := nLinE + nBordGetSup+nAltGet
   nLinG := nLinF
   nLinH := nLinG + (nAltura*0.48)
      
   aTreeServPos := {nLinC, AVG_CORD(02), nLinD, nCol2}
   aTreeOpcPos  := {nLinG, AVG_CORD(02), nLinH, nCol2}  

   If cTipoBrw == CAPA
      aSelPos      := {nLinA, nCol3, nLinH, nCol4}
   ElseIf cTipoBrw == CAPA_DETALHE
      aSelPos	:= {nLinC, nCol3, nLinD, nCol4}
      aDetPos	:= {nLinG, nCol3, nLinH, nCol4}
   EndIf

Return 


/*
Função    : AbreTree()
Objetivos : Abrir todos os galhos do objeto Tree de Serviços e de Opções
Parametros: oTreeServ, aServ, oTreeOpc, aOpc
Retorno   : -
Autor     : Fabrício Romera
Data      : 20/10 - 15:57 
*/                              
Static Function AbreTree(oTreeServ, aServ, oTreeOpc, aOpc)
   Local i, j                 
                      
   If ValType(oTreeServ) == "O" .And. ValType(aServ) == "A"
      //Varre vetor de Serviço e abre os galhos e folhas da Tree
      For i := 1 to Len(aServ)
         oTreeServ:TreeSeek(aServ[i][3])          //Seek pelo Id do Serviço
         For j:= 1 to Len(aServ[i][4])
            oTreeServ:TreeSeek(aServ[i][4][j][2]) //Seek pelo Id dos Itens
         Next   
      Next
      //Posiciona na raiz   
      oTreeServ:TreeSeek("RAIZ")
   EndIf
   
   If ValType(oTreeOpc) == "O" .And. ValType(aOpc) == "A"
      
      If lOpc
         //Varre vetor de Opções e abre os galhosTree   
         For i:= 1 to Len(aOpc)
            oTreeOpc:TreeSeek(aOpc[i][2])         //Seek pelo Id da Opção   
         Next                       
                          
         //Posiciona na raiz
         oTreeOpc:TreeSeek("RAIZ")
      End If
   EndIf
   
Return                                                               

                               
/*
Função    : ExibeSel
Objetivos : Função que controla Hidden/Show dos objetos da Tela e exibe o selecionado
Parametros: cId
Retorno   : -
Autor     : Fabrício Romera
Data      : 21/10 - 15:21 
Obs       : cId    : Id do item que foi selecionado e que será exibido
            cIdSel : Id do item que estava selecionado e será escondido(Private da Fnc principal)
            lAtuActions: Determina se o tree de ações será atualizado a cada troca de pastas, inibindo as ações não disponíveis.
*/
Static Function ExibeSel(cId, aServ, lAtuActions) 
   Local nCont  := 0, nServ := 0 , i, j
   Local cAlias
   Local nIndex

   Begin Sequence
   		
      If lUseAlias
         cAlias := GetAlias(cID)
         nIndex := GetIndex(cID)
      Else
         cAlias := Alias()
      EndIf

      If AllTrim(cId) == "RAIZ"
         nServ := 1
      End IF           
      
      //Esconde PanelMain/MsSelect Ativo
      oSRAIZ:Hide()
      If !Empty(cIdSel) .And. !(cIdSel == "oSRAIZ")
         &(cIdSel):oBrowse:Hide()
         If Type(cIdSel+"D") == "O"
            &(cIdSel+"D"):oBrowse:Hide()
         EndIf
         cIdAnt := StrTran(cIdSel, "oS", "")
         If Type("oG1"+cIdAnt) == "O"
            &("oG1"+cIdAnt):Hide()
         EndIf
         If Type("oG2"+cIdAnt) == "O"
            &("oG2"+cIdAnt):Hide()
         EndIf
      End If   
      
      //Busca posição do serviço selecionada
      While nServ = 0 .And. nCont < Len(aServ)       
         nCont := nCont + 1
         nServ := aScan(aServ[nCont], AllTrim(cId)) 
      End                                                         
      
      If nServ == 0 .And. !(AllTrim(cId) == "RAIZ")
         //Itens: Exibe MsSelect                  
         If Type("oG1"+cId) == "O"
            &("oG1"+cId):Show()
         EndIf
         If Type("oG2"+cId) == "O"
            &("oG2"+cId):Show()
         EndIf
         cId := "oS" + AllTrim(cId)
         //Guarda Id do Select Exibido
         cIdSel := cId
         If lUseAlias
            (cAlias)->(DbSetOrder(nIndex))
         EndIf
         &(cId):oBrowse:Show()
         If lUseAlias .And. !Eval(&(cId):oBrowse:bGoTop)
         	//Se não existir registros no filtro atual, coloca em Eof para não afetar o filtro dos detalhes
         	(cAlias)->(DbGoBottom())
         	(cAlias)->(DbSkip())
         EndIf
         Eval(&(cId):oBrowse:bChange)
         &(cId):oBrowse:Refresh()
         If Type(cID + "D") == "O"
            &(cId+"D"):oBrowse:Show()
            &(cId+"D"):oBrowse:Refresh()
         EndIf
      Else  
         //Raiz/Serviços: Exibe Interface de Gerenciamento
         
         For i:= 1 to Len(aServ) 
            For j:= 1 to Len(aServ[i][4])         
               If !lUseAlias
                  ("WK_" +aServ[i][3]+aServ[i][4][j][2])->(DbGoTop())
               EndIf
            Next
         Next      
                  
         SelServPanel(aServ, nCont)
         oSRAIZ:Show()                                       
         cId := "oSRAIZ"
         //Guarda Id do Select Exibido
         cIdSel := cId  
      End If
      
      //RMD - 15/09/12 - Determina se o tree de ações será atualizado a cada troca de pastas, inibindo as ações não disponíveis.
      If lAtuActions
         //Atualiza o tree de ações, exibindo somente as ações reservadas ao serviço selecionado.
         oTreeOpc := AvTree(MontaTreeOpc(aAcoes, cTitAcoes, cImgAcoes),,,, oTreeOpc)
         AbreTree(,, oTreeOpc, aAcoes)
      EndIf

   End Sequence
                                                                                
Return

  
/*
Função    : SelServPanel()
Objetivos : Altera o oMainPanel deixando apenas o painel selecionado visivel.
Parametros: aServ, nServSel
Retorno   : -
Autor     : Fabrício Romera
Data      : 28/10 - 10:38
Obs       : aServ : Array de Serviços  
            nServSel : Indice do array de serviços correspondente ao serviço selecionado 
*/      
Static Function SelServPanel(aServ, nServSel)   
   
   //Verifica se a Raiz foi selecionada
   If nServSel = 0
      //Mostra todos os paineis           
      ShowHidePanel(.T., aServ)        
      
      //Altera primeiro painel de serviços
      AlteraPanelServ(aServ, 1)            
   Else
      //Esconde todos os paineis, exceto o primeiro
      ShowHidePanel(.F., aServ)        
      
      //Altera primeiro painel de serviços conforme o selecionado
      AlteraPanelServ(aServ, nServSel)         
   End If            
   
Return                                       

  
/*
Função    : ShowHidePanel
Objetivos : Função mostra todos os panels do oMainPanel ou esconde todos exceto o primeiro. 
Parametros: lShow, aServ
Retorno   : -
Autor     : Fabrício Romera
Data      : 28/10 - 10:55
Obs       : lShow = .T., mostra todos; lShow = .F., esconde todos exceto o primeiro panel.
*/                                    
Static Function ShowHidePanel(lShow, aServ)
   Local i, cNomPanel
                
   //Controla exibição dos paineis de serviços, sendo que o primeiro sempre estara visivel.
   For i:= 1 to Len(aServ)
      cNomPanel := "oPn"+aServ[i][3] 
      If lShow .Or. i=1
         &(cNomPanel):Show()      
      Else         
         &(cNomPanel):Hide()
      End If                     
   Next         

Return


/*
Função    : AlteraPanelServ
Objetivos : Altera o primeiro painel de serviços para que fique com o conteudo do serviço selecionado.
Parametros: aServ, nServSel
Retorno   : -
Autor     : Fabrício Romera
Data      : 28/10 - 11:05
Obs       : 
*/
Static Function AlteraPanelServ(aServ, nServSel)
   Local i := 0, nCont := 1, cObjSay := "", nAux := 0, cDescItem

   //Altera titulo do serviço
   cObjSay := "oY" +aServ[1][3]
   &(cObjSay):cCaption := aServ[nServSel][1]

   If ValType(aTots) <> "A"
      aTots := GetTotReg(aServ)
   EndIf
   //Altera itens do serviço
   For i:= 1 to Len(aServ[nServSel][4])
      If i <= Len(aServ[1][4]) //Controle para exibição de itens a mais
         cObjSay := "oY" + aServ[1][3]+aServ[1][4][i][2]
      Else
         cObjSay := "oY" + "Extra" + AllTrim(Str(nCont))
         nCont   := nCont + 1
      End If

       //Descrição do item
       cDescItem := aServ[nServSel][4][i][1] + ": " + Alltrim(Str(TotReg(aTots, aServ[nServSel][3], aServ[nServSel][4][i][3])))
       //Preenche Say
       &(cObjSay):cCaption := cDescItem
   Next                                                               
                            
   nCont:= 1
   //i    := i - 1  
                                  
   //Limpa titulo de itens a mais
   For i:= i to nMaxItem
      //Verifica nome do objeto say
      If i <= Len(aServ[1][4]) //Itens de Serviço
         cObjSay := "oY" + aServ[1][3] + aServ[1][4][i][2]
      Else   
         cObjSay := "oY" + "Extra" + AllTrim(Str(nCont))   
         nCont   := nCont + 1
      End If                                            
                                   
      //Limpa Say
      &(cObjSay):cCaption := ""             
   Next

Return


/*
Função    : CriaWork
Objetivos : Função que cria as Works dos itens dos serviços
Parametros: aServ
Retorno   : -
Autor     : Fabrício Romera
Data      : 22/10 - 10:58
Obs       : aServ : Array de Serviços  
*/
Static Function CriaWork(aServ)                                                                  
   Local cAlias   := "", cAliasWk := "", cCamposBusca    
   Local i, j
   Local aCamposWK := {} //Guarda campos, que ñ existem para a work no X3, mas que devem ser criados p/ a Work.
   Private aHeader := {}, aCampos := {}
                
   //Cria Works dos itens
   For i := 1 to Len(aServ)                                      

      cAlias := aServ[i][2]
      aCampos := Array(&(cAlias)->(FCount()))
      cCamposBusca := GetCamposIndice(cAlias, aServ[i][6])

      For j := 1 to Len(aServ[i][4])                                                                                                                                                           
          
      	cAliasWk := ("WK_"+aServ[i][3]+aServ[i][4][j][2])                     
			aCamposWK := (cAlias)->(dbStruct())
		 	//Verifica se será utilizado campo Marca/Desmarca  **
         If !Empty(aServ[i][4][j][7])
            aAdd(aCamposWK, {aServ[i][4][j][7], "C", 2, 0} ) //Adiciona campos de marca e desmarca
         End If

         //Cria Work
         If !lUseAlias .And. Select(cAliasWk) == 0
            &("cF"+aServ[i][3]+aServ[i][4][j][2]) := E_CriaTrab(,aCamposWK,cAliasWk)
         End If
         
         IF(EasyEntryPoint("AVFRM105"),Execblock("AVFRM105",.F.,.F.,{"CRIA_INDEX",cAliasWk}),)

         //Preenche Work
         If !lUseAlias
            PreencheWork(cAlias, cAliasWk, aServ[i][4][j][3], aServ[i][6], cCamposBusca)
         EndIf
      Next  
   Next                     

Return              

/*
Função    : Preenche Work
Objetivos : Função que popula as Works dos itens dos serviços conforme parametros de indice e chave.
Parametros: cAliasBase, cAliasWk, cChave, nOrdem
Retorno   : -
Autor     : Fabrício Romera
Data      : 22/10 - 11:20
Obs       : cAliasBase : Alias do Serviço
            cAliasWk   : Alias da Work
            cChave     : Chave para busca e filtro na tabela de serviço 
            nOrdem     : Ordem do indice de busca.
            cCamposBusca : Cam
*/
Static Function PreencheWork(cAliasBase, cAliasWk, cChave, nOrdem, cCampoBusca)
   
	EasyWKLoad(cAliasBase, cAliasWk, cChave, cCampoBusca)

   IF(EasyEntryPoint("AVFRM105"),Execblock("AVFRM105",.F.,.F.,{"DELETA_REGISTRO",cAliasWk}),)

Return                                                                              

/*
Função    : GetCamposIndice()
Objetivos : Função que retorna os campos do indice passado por parametro, sem o campo _FILIAL
Parametros: cAlias, nOrdem
Retorno   : -
Autor     : Fabrício Romera
Data      : 22/10 - 11:20
Obs       : 
*/
Static Function GetCamposIndice(cAlias, nOrdem)
   Local cCamposIndice := ""

   SIX->(DbSetOrder(1))
   SIX->(DbSeek(cAlias+AllTrim(Str(nOrdem))))
   
   If SIX->INDICE == cAlias .And. SIX->ORDEM == AllTrim(Str(nOrdem))
      cCamposIndice := AllTrim(SIX->CHAVE)             //Traz campos do indice
      cCamposIndice := STUFF(cCamposIndice, 1, 11, "") //Elimina primeiro campo _FILIAL  
   End If            
   
Return cCamposIndice            

/*
Função    : AvAtuCentrInt
Objetivos : Atualizar conteudo de um ou de todos os arquivos de trabalho da tela.
Parametros: [cCargo], aServ
Retorno   : -
Autor     : Fabrício Romera
Data      : 28/10 - 16:15
Obs       : cCargo: ID do serviço + ID do item a ser atualizado, exemplo: "SV2IT1" (Item 1 do Serviço 2);
                    Caso não seja informado todos os itens serão atualizados
*/
Function AvAtuCentrInt(cCargo, aServ)
   Local cAlias, cAliasWk, cSelect
   Local nRecno := 0
   Local lTodos := .T.
   Local i,j

   //Verifica parametro
   If !Empty(cCargo)
      lTodos  := .F.
   End If

   For i := 1 to Len(aServ)
      cAlias := aServ[i][2]
      cCamposBusca := GetCamposIndice(cAlias, aServ[i][6])

      For j := 1 to Len(aServ[i][4])

         cAliasWk := ("WK_" +aServ[i][3]+aServ[i][4][j][2]) //Alias Work
         cSelect  := ("oS"+aServ[i][3]+aServ[i][4][j][2]) //Objeto MsSelect Correspondente
         If !lUseAlias
            nRecno   := &(cAliasWk)->(Recno())
         Else
            (cAlias)->(DbSetOrder(GetIndex(aServ[i][3]+aServ[i][4][j][2])))
         EndIf

         If lTodos
               If !lUseAlias
                  &(cAliasWk)->(avzap())
                  PreencheWork(cAlias, cAliasWk, aServ[i][4][j][3], aServ[i][6], cCamposBusca)
               EndIf
               &(cSelect):oBrowse:Refresh()
         Else
            If cCargo = aServ[i][3]+aServ[i][4][j][2]
               If !lUseAlias
                  &(cAliasWk)->(avzap())
                  PreencheWork(cAlias, cAliasWk, aServ[i][4][j][3], aServ[i][6], cCamposBusca)
               EndIf
               &(cSelect):oBrowse:Refresh()
            End If
         End If                            
         
         If !lUseAlias
            &(cAliasWk)->(DbGoTo(nRecno))
         
            If &(cAliasWk)->(EOF()) .And. nRecno > 1
               &(cAliasWk)->(DbGoTop())         
            End If
         EndIf
            
      Next
   Next
   If cIdSel <> "oSRAIZ"
      If lUseAlias .And. (cAlias)->(Left(&(IndexKey()), Len(Frm105Filter(AllTrim(cCargo))))) <> Frm105Filter(AllTrim(cCargo)) .And. !Eval(&(cIdSel):oBrowse:bGoTop)
         (cAlias)->(DbGoBottom())
         (cAlias)->(DbSkip())
      EndIf
      Eval(&(cIdSel):oBrowse:bChange)
   EndIf 
Return

/*
Função    : TotReg()
Objetivos : Função que calcula o numero total de registros de um arquivo de trabalho
Parametros: cAlias
Retorno   : -
Autor     : Fabrício Romera
Data      : 28/10 - 15:00
Obs       : cAlias
*/
Static Function TotReg(aTots, cServ, cID)
Local nCont := 0, nPos

	If (nPos := aScan(aTots, {|x| x[1] == cServ .And. x[2] == cID })) > 0
		nCont := aTots[nPos][3]
	EndIf

Return nCont


/*
Função    : ExcluiWork()
Objetivos : Função que exclui arquivos de trabalho utilizados.
Parametros: aServ
Retorno   : -
Autor     : Fabrício Romera
Data      : 26/10
Obs       : aServ: Array de Serviços.
*/
Static Function ExcluiWork(aServ)
   Local i, j

   //Exclui arquivos de trabalho                                                                                
   For i := 1 to Len(aServ)
      For j:= 1 to Len(aServ[i][4])                 
         If Select("WK_"+aServ[i][3]+aServ[i][4][j][2]) > 0
            &("cWK"+aServ[i][3]+aServ[i][4][j][2])->(DbCloseArea())
            E_EraseArq(&("cF"+aServ[i][3]+aServ[i][4][j][2]))
         EndIf            
      Next
   Next             
   
Return   


/*
Função    : CriaInterfaceGer()
Objetivos : Função que cria objetos de tela da inteface de gerenciamento de integração.
Parametros: 
Retorno   : -
Autor     : Fabrício Romera
Data      : 27/10 - 13:30
Obs       : 
*/            
Static Function CriaInterfaceGer(aServ, nHeightScroll, nWidthScroll, cPanelTit)
   
   //Variaveis de controle de criação de paineis                                                                            
   Local nNumPanel    := 0,; //Numero de paineis criados dentro do MainPainel
         nColPanel    := 0,; 
         nRowPanel    := 0,; 
         nHeightPanel := 0,; 
         nWidthPanel  := 0,; 
         cNomPanel    := "";                       
         
   Local nColSayItem  := 0,;
         nRowSayItem  := 0
   Local i, j, nCont := 1   
   Local cSayTitServ := cPanelTit, cDescServ, cDescItem  
   Local a := {1,2}                        
   
   //oPanel Principal    
   oSRAIZ:= tPanel():New(nLinA, nCol3, "", oDlg,,,,,, nCol4-nCol3, nLinH-nLinA)
        
   //Titulo Principal
   TSay():New(AVG_CORD(6),AVG_CORD(8), &("{|| '" + cSayTitServ + "' }"), oSRAIZ,,oFont1,,,, .T.,,, AVG_CORD(89.5), AVG_CORD(08))      
                    
   //Inicia variaveis de controle de posição
   nColPanel    := AVG_CORD(8)
   nRowPanel    := AVG_CORD(25)
   nHeightPanel := AVG_CORD(60)                                                                
   nWidthPanel  := AVG_CORD(100)                                                              

   For i := 1 to Len(aServ) 
   
      //Pega informações do array de serviços p/ localizar var. dinamicas
      cNomPanel := "oPn"+aServ[i][3]
      cDescServ := "cD" +aServ[i][3] 
      cObjSay   := "oY" +aServ[i][3] 
      
      //Define variaveis dinamicas      
      &(cDescServ) := aServ[i][1] //Titulo do Serviço
                  
      //oPanel de Serviço  
      &(cNomPanel) := tPanel():New(nRowPanel, nColPanel, "", oSRAIZ,,,,,,nWidthPanel, nHeightPanel) 

      //Titulo do Serviço                                             
      &(cObjSay):=TSay():New(AVG_CORD(2),AVG_CORD(2), &("{|| '" + &(cDescServ) + "' }"), &(cNomPanel),,oFont2,,,, .T.,,, AVG_CORD(89.5), AVG_CORD(08))
      
      //Itens
      nColSayItem := AVG_CORD(6)
      nRowSayItem := AVG_CORD(15)
      If ValType(aTots) <> "A"
         aTots := GetTotReg(aServ)
      EndIf
      For J := 1 to Len(aServ[i][4])
         //Título do Item
         cObjSay      := "oY"+aServ[i][3]+aServ[i][4][j][2]
         cDescItem    := "cD"+aServ[i][3]+aServ[i][4][j][2]
         &(cDescItem) := aServ[i][4][j][1] + ": " + Alltrim(Str(TotReg(aTots, aServ[i][3], aServ[i][4][j][3])))
         
         &(cObjSay)   :=TSay():New(nRowSayItem,nColSayItem, &("{|| '" + &(cDescItem) + "' }");
                                    , &(cNomPanel),,oFont3,,,, .T.,,, AVG_CORD(89.5), AVG_CORD(08))
         
         //Incrementa variaveis de posição
         nColSayItem := AVG_CORD(6)
         nRowSayItem := nRowSayItem + AVG_CORD(10)         
      Next      
                                                               
      J := J - 1                           
      //Cria Itens a mais no Serviço Pricipal(Primeiro Serviço)      
      For J := J to nMaxItem
         cObjSay      := "oY"+"Extra"+AllTrim(Str(nCont))
         &(cObjSay)    :=TSay():New(nRowSayItem,nColSayItem, &("{|| '' }");
                                    , &(cNomPanel),,oFont3,,,, .T.,,, AVG_CORD(89.5), AVG_CORD(08))      
         nCont := nCont + 1                           
         
         //Incrementa variaveis de posição
         nColSayItem := AVG_CORD(6)
         nRowSayItem := nRowSayItem + AVG_CORD(10)         
      Next
      
      //Incrementa variaveis de controle de posição                                                  
      If Mod(I, 2) = 0 
         nColPanel    := AVG_CORD(8) 
         nRowPanel    := nRowPanel + nHeightPanel + AVG_CORD(10) 
      Else
         nColPanel    := nWidthPanel + AVG_CORD(15)                
      End If         
            
   Next            
                                           
Return                               

Function FRM105VisDet(cAlias)
Local oDlg

   RegToMemory(cAlias, .T.)
   DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0; // "Detalhes do item"
                                      TO DLG_LIN_FIM*0.7, DLG_COL_FIM*0.7;
                                      OF oMainWnd PIXEL

      EnChoice(cAlias, (cAlias)->(Recno()), VISUALIZAR,,,,, {1,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

   ACTIVATE MSDIALOG oDLG Centered

Return Nil

Function Frm105Filter(cFilter)
Return cFilter

Static Function GetTotReg(aServ)
Local i
Local aTots := {}
Local cKey
Local cFil

	For i := 1 To Len(aServ)
		(aServ[i][2])->(DbSetOrder(aServ[i][6]))
		cFil := If(Left(aServ[i][2], 1) == "S", SubStr(aServ[i][2], 2, 2), aServ[i][2])+"_FILIAL"
	   	cIndex := StrTran((aServ[i][2])->(IndexKey()), cFil + "+", "")
	   	If Len(aServ[i][4]) > 0
			nLenKey := Len(aServ[i][4][1][3])
			nLenIndex := 0
			cKey := ""
			While nLenIndex < nLenKey
				If At("+", cIndex) > 0
					cCampo := SubStr(cIndex, 1, At("+", cIndex) - 1)
					If !Empty(cKey)
						cKey += ","
					EndIf
					cKey += cCampo
					nLenIndex += AvSx3(cCampo, AV_TAMANHO)
					cIndex := SubStr(cIndex, Len(cCampo)+2)
				Else
					Exit
				EndIf
			EndDo
		Else
			If At("+", cIndex) > 0
				//Considera sempre um campo apenas na chave (limitação da central)
				cKey := SubStr(cIndex, 1, At("+", cIndex) - 1)
			EndIf
		EndIf
		//DFS - 03/06/13 - Inclusão de tratamento para verificar se existe chave ou não antes da montagem da query.
		If !Empty(cKey)
		   cQuery := "Select " + cKey + ", Count(*) TOTAL From " + RetSqlName(aServ[i][2]) + " Where " + cFil + " = '" + xFilial(aServ[i][2]) + "' And D_E_L_E_T_ <> '*' Group By " + cKey
		Else
	       cQuery := "Select " + cKey + " Count(*) TOTAL From " + RetSqlName(aServ[i][2]) + " Where " + cFil + " = '" + xFilial(aServ[i][2]) + "' And D_E_L_E_T_ <> '*' 
		EndIf
		TcQuery ChangeQuery(cQuery) ALIAS "QRY" NEW
		While QRY->(!Eof())
			aAdd(aTots, {aServ[i][3], QRY->&(StrTran(cKey, ",", "+")), QRY->TOTAL})
			QRY->(DbSkip())
		EndDo
		QRY->(DbCloseArea())
	Next

Return aTots
