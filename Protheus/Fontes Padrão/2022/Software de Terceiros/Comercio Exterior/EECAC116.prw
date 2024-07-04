#Include 'Totvs.ch'         
#Include 'EECAC116.ch'

/*/
Função     : EECAC116()
Parâmetros : 
Objetivos  : Chamar a Rotina EECAF500 para geracao de adiantamento a fornecedores.
Autor      : Tiago Henrique Tudisco dos Santos - THTS 
Data       : 17/03/2017
Revisao    : 
Obs.       :/
*/
Function EECAC116()

Local cOldArea	:= Select()
Local aFil			:= {}
Local cFil			:= ""
Local nI			:= 0
Private cCadastro	:= STR0001 + Alltrim(SA2->A2_NOME) //Adiantamento a Fornecedor - 
Private aRotina 	:= MenuDef()

aFil := AvgSelectFil(,"EEQ");

For nI:= 1 To len(aFil)
	cFil += aFil[nI]
	If nI < Len(aFil)
		cFil += ","
	EndIF
Next

Begin Sequence

EEQ->(dbSetOrder(1))
EEQ->(dbSetFilter( {|| EEQ->EEQ_FILIAL  $ cFil .AND. EEQ->EEQ_EVENT=='609' .AND. EEQ->EEQ_FORN == SA2->A2_COD .AND. EEQ->EEQ_FOLOJA== SA2->A2_LOJA}, "EEQ->EEQ_FILIAL $ '"+cFil+"' .AND. EEQ->EEQ_EVENT=='609' .AND. EEQ->EEQ_FORN=='"+SA2->A2_COD+"' .AND. EEQ->EEQ_FOLOJA=='"+SA2->A2_LOJA+"'"))

mBrowse( 6, 1,22,75,"EEQ",,,,,,,,,,,,,,)

End Sequence

Return


/*
Função     : MenuDef()
Parâmetros : -
Retorno    : aRotina
Objetivos  : Operações de pagamentos
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 20/03/2017
Revisao    : 
Obs.       :
*/
Static Function MenuDef()
Local aRotina:= {}

aAdd(aRotina,{STR0002 		,"AxPesqui"   ,0,1})//"Pesquisar"
aAdd(aRotina,{STR0003	 	,"AC116MNT"   ,0,2})//"Visualizar"
aAdd(aRotina,{STR0004 		,"AC116MNT"   ,0,3})//"Incluir"
aAdd(aRotina,{STR0005 		,"AC116MNT"   ,0,4})//"Alterar" 
aAdd(aRotina,{STR0006 		,"AC116MNT"   ,0,5})//"Excluir"
aAdd(aRotina,{STR0007 		,"AC116MNT"   ,0,6})//"Liquidar"
aAdd(aRotina,{STR0008		,"AC116MNT"   ,0,7})//"Estornar Liq."

Return AClone(aRotina)


/*
Função     : AC116MNT()
Parâmetros : cAlias - Alias da Tabela Correspondent
             nRec   - Numero do Registro selecionado
             nOpc   - Numero da Operação selecionada
Retorno    : aRotina
Objetivos  : Chamar a Rotina EECAF500 que efetua visualização e atualizar os browsers
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 20/03/2017
Revisao    : 
Obs.       :
*/
Function AC116MNT(cAlias,nRec,nOpc)
Local lRet			:= .T.
Local nAtuRec 		:= nRec
Private aTMPAlt		:= {}
Private aEAIAF520 	:= {} //Array utilizado nos adapters EECAF214 e EECAF520 para integracao com o Logix

Begin Sequence
	//Se nao existir o evento 609 para EXPORT, ele deve ser criado
	EC6->(dbSetOrder(1))//EC6_FILIAL, EC6_TPMODU, EC6_ID_CAM, EC6_IDENTC
	If EC6->(!dbSeek(xFilial("EC6") + avKey("EXPORT","EC6_TPMODU") + avKey("609","EC6_ID_CAM")))
		EC6->(RecLock("EC6",.T.))
		EC6->EC6_FILIAL		:= xFilial("EC6")
		EC6->EC6_TPMODU		:= "EXPORT"
		EC6->EC6_ID_CAM		:= "609"
		EC6->EC6_DESC			:= "ADTO FORNECEDOR"
		EC6->EC6_RECDES		:= "2"
		EC6->(MsUnlock())
	EndIf

	If nOpc == 7 .And. !Empty(EEQ->EEQ_SEQBX)
		lRet := .F.
		EasyHelp(STR0009)//"Não é possível realizar o estorno da liquidação, pois o adiantamento encontra-se compensado."
	EndIf
	
	If lRet
   		EECAF500(cAlias,nRec,nOpc)
	EndIf
	
End Sequence

Return
