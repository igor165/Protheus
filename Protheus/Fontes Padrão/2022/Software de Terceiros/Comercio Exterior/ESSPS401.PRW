#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 

#Define AQUISICAO "A"
#Define VENDAS    "V"

#Define OPC_VIS 2
#Define OPC_INC 3
#Define OPC_ALT 4
#Define OPC_EST 5
#Define OPC_LIQ 6
#Define OPC_ELQ 7
#Define OPC_VIN 8  // PLB 23/05/06
#Define OPC_EVN 9

/*
Função     : ESSPS401()
Parâmetros : -
Retorno    : -
Objetivos  : Gerar a(s) parcela(s) de Cambio(EEQ)
Autor      : 
Data/Hora  : 24/08/12 - 17:35
Revisao    : 
Obs.       :
*/
*------------------------*
Function ESSPS401(aParcAuto,nOpcAuto)
*------------------------*
Local oBrowse
Local i
Local cMsg := ""
Local cTpReg := ""
Local aOrd := SaveOrd({"EL9","EEQ"})
Local lRet := .F.
Local cBrwFiltro := ""
Local nOpc 
Local aProcesso := {}
Local aParcelas := {}
Private lPS401Auto := ValType(aParcAuto) == "A" .And. ValType(nOpcAuto) == "N"

Begin Sequence

   If !lPS401Auto

      If Type("cPed") == "C"
         cTpReg := cPed
      EndIf

      cBrwFiltro := "EEQ->EEQ_TPPROC=='"+cTpReg+"'"  //Filtra pelo Tipo de Processo,'A' para Aquisicao e 'V' para Venda     
      oBrowse := FWMBrowse():New() //Instanciando a Classe   
      oBrowse:SetAlias("EEQ") //Informando o Alias
      oBrowse:SetMenuDef("ESSPS401") //Nome do fonte do MenuDef
      oBrowse:SetDescription("Cambio do Serviço") //Descrição a ser apresentada no Browse
      oBrowse:SetFilterDefault(cBrwFiltro) //Filtro dos registros a serem exibidos
      oBrowse:Activate()
      EEQ->(dbClearFilter())

   Else

      If (nPosTpProc := aScan(aParcAuto[1],{ |X| X[1] == "EEQ_TPPROC"})) == 0 .Or. Empty(cTpProc := aParcAuto[1][nPosTpProc][2])
         EasyHelp("Tipo de processo não informado.")
         Break
      EndIf

      If (nPosProcesso := aScan(aParcAuto[1],{ |X| X[1] == "EEQ_PROCES"})) == 0 .Or. Empty(cProcesso := aParcAuto[1][nPosProcesso][2])
         EasyHelp("Processo de serviço não informado.")
         Break
      EndIf

      aProcesso := {}
      aAdd(aProcesso,{"EJW_TPPROC",cTpProc,Nil})
      aAdd(aProcesso,{"EJW_PROCES",cProcesso,Nil})

      aParcelas := EasyEAutItens("EJW", "EEQ", aProcesso, aParcAuto, "EJW_FILIAL+EJW_TPPROC+EJW_PROCES", 'EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE', 14)
     
      For i := 1 To Len(aParcelas)
         nOpc := nOpcAuto
         If (nPos := aScan(aParcelas[i],{|X| AllTrim(Upper(X[1])) == "AUTDELETA" })) > 0 .And. "S" $ aParcelas[i][nPos][2] 
            nOpc := 5
         EndIf
         MsExecAuto({|x,y,z,w,x| EECAF500(x,y,z,w,x)},"EEQ", , ,aParcelas[i],nOpc)
         If lMsErroAuto
            If ValType(cMsg := NomeAutoLog()) == "U"   
               cMsg := "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."        
            Else
               cMsg := MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
            EndIf
            EasyHelp(cMsg)
            Break
         EndIf
      Next
     
   EndIf
      
End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : MenuDef()
Parâmetros : -
Retorno    : aRotina
Objetivos  : Operações de pagamentos
Autor      : 
Data/Hora  : 23/08/12 - 10:35
Revisao    : 
Obs.       :
*/
Static Function MenuDef() 
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"     ACTION "AxPesqui"     OPERATION 1 ACCESS 0  
ADD OPTION aRotina TITLE "Visualizar"    ACTION "PS401Menu"    OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"       ACTION "PS401Menu"    OPERATION 3 ACCESS 0  
ADD OPTION aRotina TITLE "Alterar"       ACTION "PS401Menu"    OPERATION 4 ACCESS 0  
ADD OPTION aRotina TITLE "Excluir"       ACTION "PS401Menu"    OPERATION 5 ACCESS 0 
ADD OPTION aRotina TITLE "Liquidar"      ACTION "PS401Menu"    OPERATION 6 ACCESS 0 
ADD OPTION aRotina TITLE "Estornar Liq." ACTION "PS401Menu"    OPERATION 7 ACCESS 0
//ADD OPTION aRotina TITLE "Conhecimento"  ACTION "MsDocument"       OPERATION 4 ACCESS 0 //FSY - 17/01/2014
Return aRotina

Static Function ModelDef()
Return

Static Function ViewDef()
Return

/*
Função     : PS401Menu()
Parâmetros : cAlias - Alias da Tabela Correspondent
             nRec   - Numero do Registro selecionado
             nOpc   - Numero da Operação selecionada
Retorno    : aRotina
Objetivos  : Chamar a Rotina EECAF500 que efetua visualização e atualizar os browsers
Autor      : 
Data/Hora  : 24/08/12 - 11:35
Revisao    : 
Obs.       :
*/
Function PS401Menu(cAlias,nRec,nOpc)
Local nAtuRec := nRec

Begin Sequence

   If (nOpc == 4 .Or. nOpc == 5 .Or. nOpc == 6 .Or. nOpc == 7) .And. (ValType(nRec) == "N" .And. nRec <> 0)
      EEQ->(DbGoTo(nRec))
      //RRC  - 09/12/2013 - Além de validar se a parcela de câmbio foi gerada pelo SIGAFIN, verifica se a origem é o SIGAEIC ou SIGAEEC. Nestes casos, ela não poderá ser alterada pelo SIGAESS.
      If (AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAFIN" .And. EasyGParam("MV_EASYFIN",,"") == "S") .Or. (AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEIC"  .And. EasyGParam("MV_EASYFIN",,"") == "S") .Or. AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEEC"
         EasyHelp("Parcela gerada pelo " + AllTrim(Upper(EEQ->EEQ_SOURCE)) + ". Através do SIGAESS somente será possível visualizar.")
         nOpc := 2
      EndIf
   EndIf
   //RRC - 04/11/2013 - Expressão abaixo atualizada com a verificação da existência do campo EEQ_VLSISC
   If (nOpc == OPC_LIQ .And. (IsInCallStack("ESSPS400") .Or. (Type("lAF500Auto") == "L" .And. lAF500Auto) ) .And. EEQ->(FieldPos("EEQ_VLSISC")) > 0 .And. EEQ->EEQ_VLSISC > ELA->ELA_SLDPAG)
      EasyHelp("Não é possível liquidar esta parcela pois não há saldo suficiente na Invoice.")
      Break
   EndIf
   
   EECAF500(cAlias,nRec,nOpc)
   PS500Atua()

End Sequence

Return