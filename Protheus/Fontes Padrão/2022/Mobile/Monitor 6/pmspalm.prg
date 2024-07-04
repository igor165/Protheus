#INCLUDE "pmspalm.ch"
#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³pmspalm   ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcoes de interface com o usuario                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ DlgMain  ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Janela principal do PMSPalm                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Main()
	Local aPMSTables  := {}     // tabelas utilizadas
	Local aPMSIndexes := {}     // indices utilizados
	
	Local i := 0
	Local j := 0
	
	Local cFile := ""
	Local cExp  := ""

	Local oDlg := Nil
	
	Local oMenu := Nil
	Local oMenuItem1 := Nil
	Local oMenuItem2 := Nil
	Local oMenuItem3 := Nil
		
	Private nSyncID := 0

	Set Date British     // necessario para a utilizacao do calendario
	Set Deleted On


	// abre o arquivo de indice
	If !OpenTable("ADV_IND", "ADVIND", .F., .T.)
	
		// se o arquivo ADV_IND nao existe
		// executa a rotina de sincronizacao
		DoSync()
		
		Return Nil
	EndIf
	
	dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)

	// adicione na rotina as
	// tabelas a serem abertas
	aPMSTables := TableLoad()
	
	For i := 1 To Len(aPMSTables)
		If !OpenTable(aPMSTables[i][PMS_TABLE], aPMSTables[i][PMS_ALIAS])
			MsgAlert(STR0001 + aPMSTables[i][PMS_TABLE]) //"Não foi possível abrir a tabela "
			
			// TODO
			// executar uma operacao de log
			// END TODO			
		Else
			MsgStatus(STR0002 + aPMSTables[i][PMS_TABLE] + "...") //"Abrindo "

			// TODO
			// executar uma operacao de log
			// END TODO
			
			GetIndexes(aPMSIndexes, aPMSTables[i][PMS_TABLE])
		
			For j := 1 To Len(aPMSIndexes)
				cFile := aPMSIndexes[j][PMS_IDX_FILENAME]
				cExp  := aPMSIndexes[j][PMS_IDX_EXP]

				If !File(cFile)
					MsgStatus(STR0003 + cFile + "...") //"Criando "

					// TODO
					// executar uma operacao de log
					// END TODO
					
					dbSelectArea(aPMSTables[i][PMS_ALIAS])
					dbCreateIndex(cFile, cExp)
				Else
					MsgStatus(STR0004 + cFile + "...") //"Reindexando "

					// TODO
					// executar uma operacao de log
					// END TODO
					
					dbSelectArea(aPMSTables[i][PMS_ALIAS])
					dbSetIndex(cFile)
				EndIf
			Next
		EndIf
	Next

	// limpa a mensagem de status
	ClearStatus()
		  
	Define Dialog oDlg Title APP_NAME
		Add Menubar oMenu Caption STR0005 Of oDlg //"Arquivo"
			Add MenuItem oMenuItem1 Caption STR0006 Action DlgConf()  Of oMenu //"Conf. Tarefa"
			Add MenuItem oMenuItem2 Caption "Apont. Recursos" Action DlgAptRec()  Of oMenu //"Apont. Recurso"
			Add MenuItem oMenuItem3 Caption STR0007 Action InitSync()    Of oMenu //"Sincronizar"
			Add MenuItem oMenuItem3 Caption STR0008 Action CloseDialog() Of oMenu //"Sair"

		@ 060, 010 Say APP_NAME Large Bold Of oDlg
		@ 074, 010 To 0, 150 Of oDlg
/*		@ 140, 010 Say "Versão ";
		               + APP_MAJOR_VERSION + ".";
		               + APP_MINOR_VERSION + ".";
		               + APP_BUILD_VERSION;
		               Of oDlg
*/
		
	Activate Dialog oDlg
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TableLoad ºAutor  ³Reynaldo Miyashita  º Data ³  02.09.2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega em array as tabelas que deverao ser abertas na     º±±
±±º          ³ chamada do program e quando executa a sincronizacao.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TableLoad()
Local aTables := {}

	// adicione em aTables as
	// tabelas a serem abertas
	aAdd(aTables , {"HAF9", "AF9"})
	aAdd(aTables , {"HAFF", "AFF"})
	aAdd(aTables , {"HAFU", "AFU"})
	aAdd(aTables , {"HAE8", "AE8"})
	aAdd(aTables , {"HSH7", "SH7"})
	aAdd(aTables , {"HAFY", "AFY"})
	aAdd(aTables , {"HSX6", "SX6"})
	
Return aTables


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DlgConf   ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Janela de gerenciamento de confirmacoes                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DlgConf()
	Local oDlg    := Nil  // janela principal
	Local oMenu   := Nil  // menu principal
	Local oItem1  := Nil  // menu Visualizar
	Local oItem2  := Nil  // menu Incluir
	Local oItem3  := Nil  // menu Alterar
	Local oItem4  := Nil  // menu Excluir
	Local oItem5  := Nil  // menu Fechar
	Local oItem6  := Nil  // menu Conf. por lote
	
	//Local oSep1   := Nil  
	//Local oSep2 := Nil
	Local oBrowse := Nil  // browse
	Local oCol    := Nil  // coluna

	// arrays necessarios para
	// utilizacao com o browse
	Local aHeader := {}	
	Local aItems  := {}

	Define Dialog oDlg Title STR0009 //APP_NAME //"Confirmação de tarefa"
		Add Menubar oMenu Caption STR0006 Of oDlg //"Confirmações"

			Add MenuItem oItem6 Caption STR0010  Action MenuClick(oBrowse, aItems, MNU_CONFTODAS)  Of oMenu //"Conf. por lote"
			Add MenuItem oItem1 Caption STR0011  Action MenuClick(oBrowse, aItems, MNU_VISUALIZAR) Of oMenu //"Visualizar"
			Add MenuItem oItem2 Caption STR0012  Action MenuClick(oBrowse, aItems, MNU_INCLUIR)    Of oMenu //"Incluir"
			Add MenuItem oItem3 Caption STR0013  Action MenuClick(oBrowse, aItems, MNU_ALTERAR)    Of oMenu //"Alterar"
			Add MenuItem oItem4 Caption STR0014  Action MenuClick(oBrowse, aItems, MNU_EXCLUIR)    Of oMenu //"Excluir"
			Add MenuItem oItem5 Caption STR0015  Action CloseDialog() Of oMenu //"Fechar"

		@ 20, 05 Say STR0016 Of oDlg //"Confirmações existentes:"
		
		aAdd(aHeader, STR0017) //"Filial"
		aAdd(aHeader, STR0018) //"Projeto"
		aAdd(aHeader, STR0019) //"Revisão"
		aAdd(aHeader, STR0020) //"Data"
		aAdd(aHeader, STR0021) //"Tarefa"
		aAdd(aHeader, STR0022) //"Quantidade"
		aAdd(aHeader, STR0023) //"Ocor."
		aAdd(aHeader, STR0024) //"Cod. Mem"
		aAdd(aHeader, STR0025) //"Usuário"
		aAdd(aHeader, STR0026) //"Confir"
		aAdd(aHeader, STR0027) //"Perc"
		aAdd(aHeader, STR0028) //"AE"

		// carrega aItems com as ocorrencias existentes
		AFFFill(@aItems)

		// mostra browse com as ocorrencias existentes	
		@ 35, 05 Browse oBrowse Size 150, 100 On Click BrowseClick(oDlg, oBrowse, aItems) Of oDlg
		Set Browse oBrowse Array aItems

		Add Column oCol To oBrowse Array Element SUB_AFF_PROJET Header aHeader[02] Width 60
		Add Column oCol To oBrowse Array Element SUB_AFF_TAREFA Header aHeader[05] Width 60
		Add Column oCol To oBrowse Array Element SUB_AFF_DATA   Header aHeader[04] Width 40
		Add Column oCol To oBrowse Array Element SUB_AFF_QUANT  Header aHeader[06] Width 60 Picture "@E 999,999,999.9999" Align Right
		Add Column oCol To oBrowse Array Element SUB_AFF_PERC   Header aHeader[11] Width 40 Picture "@E 999.99"           Align Right
		Add Column oCol To oBrowse Array Element SUB_AFF_CONFIR Header aHeader[12] Width 30
	Activate Dialog oDlg
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BrowseClicºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oDlg    - janela que contem os registro do AFF             º±±
±±º          ³ oBrowse - browse                                           º±±
±±º          ³ aItems  - items contidos no browse                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BrowseClick(oDlg, oBrowse, aItems)
	Local lReturn := .F.
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MenuClick ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa a selecao dos menus                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oBrowse - browse que contem os registro do AFF             º±±
±±º          ³ aItems  - items que estao no browse                        º±±
±±º          ³ nOp     - identificador do menu                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MenuClick(oBrowse, aItems, nOp)
	Local nSelItem := 0
	Local lReturn  := .F.
	
	Do Case
		Case nOp == MNU_ALTERAR
			If !IsSel(oBrowse, aItems)
		  	MsgAlert(STR0029, APP_NAME) //"Não há nenhum registro para ser alterado!"
		 	Else
		 		DlgAFFChange(@aItems, GetOption(oBrowse, aItems))
		 		lReturn := .T.
			EndIf
	
		Case nOp == MNU_INCLUIR
			DlgAFFInclude(@aItems, {})
			lReturn := .T.
			
		Case nOp == MNU_VISUALIZAR
			If !IsSel(oBrowse, aItems)
				MsgAlert(STR0030, APP_NAME) //"Não há nenhum registro para ser visualizado!"
			Else
				DlgAFFView(@aItems, GetOption(oBrowse, aItems))
				lReturn := .T.
			EndIf
				
		Case nOp == MNU_EXCLUIR
			If !IsSel(oBrowse, aItems)
				MsgAlert(STR0031, APP_NAME) //"Não há nenhum registro para ser excluído!"
			Else
				DlgAFFExc(@aItems, GetOption(oBrowse, aItems))
				lReturn := .T.
			EndIf			

		Case nOp == MNU_CONFTODAS
			DlgAF9All(@aItems)
			lReturn := .T.
	EndCase
	
	// atualizar o browse com as confirmacoes
	If lReturn
		SetArray(oBrowse, aItems)
	EndIf
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldQtd    ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade informada na confirmacao da tarefa     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - confirmacao                                     º±±
±±º          ³ nQuant   - quantidade a ser validada                       º±±
±±º          ³ oPerQtd  - objeto que mostra a quantidade calculada        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldQtd(aAFFItem, nQuant, oPerQtd)
	Local lReturn := .F.
	Local nAF9Quant := AF9GetQuant(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET];
	                             + aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])
	Local nPerQuant := 0
	Local lMsgInvQtd := .F.

	If aAFFItem[SUB_AFF_FILIAL] == Nil .Or.;
	   aAFFItem[SUB_AFF_PROJET] == Nil .Or.;
	   aAFFItem[SUB_AFF_REVISA] == Nil .Or.;
	   aAFFItem[SUB_AFF_TAREFA] == Nil
		MsgAlert(STR0032) //"Selecione um projeto e uma tarefa para ser confirmada!"
		lReturn := .T.
	Else
		If Empty(aAFFItem[SUB_AFF_FILIAL]) .Or.;
		   Empty(aAFFItem[SUB_AFF_PROJET]) .Or.;
		   Empty(aAFFItem[SUB_AFF_REVISA]) .Or.;
		   Empty(aAFFItem[SUB_AFF_TAREFA])
			MsgAlert(STR0032) //"Selecione um projeto e uma tarefa para ser confirmada!"
			lReturn := .T.
		Else
			If nQuant > nAF9Quant .Or. nQuant < 0.00
				MsgAlert(STR0033, APP_NAME) //"Quantidade inválida!"
				lMsgInvQtd := .T.
				lReturn := .F.
			Else
				aAFFItem[SUB_AFF_QUANT] := nQuant
		
				// calcular a porcentagem
				nPerQuant := CalcPerTask(nAF9Quant, nQuant)
				
				SetText(oPerQtd, Transform(nPerQuant, "@E 999.99"))
				            
				lReturn := .T.
			EndIf
		EndIf
	EndIf
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetDate   ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra uma caixa de dialogo para a selecao de uma data     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aItem    - Apontamento no AFF                              º±±
±±º          ³ oSay     - objeto Say no qual ser mostrada a data          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetDate( aItem ,oSay )
	Local dTemp := aItem[SUB_AFF_DATA]
	
	dTemp := SelectDate(STR0034, dTemp) //"Selecione a data..."
	
	aItem[SUB_AFF_DATA] := dTemp
	SetText(oSay, DToC(dTemp))

Return( dTemp )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DlgAFFInclºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ mostra a janela de inclusao de confirmacao                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aItems  - items contidos no browse (sera atualizado com a  º±±
±±º          ³           confirmacao inserida                             º±±
±±º          ³ aAFFItemPre                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DlgAFFInclude(aItems, aAFFItemPre)
	Local oDlg   := Nil

	Local oBtnCalen := Nil	
	Local oBtnOk     := Nil
	Local oBtnCancel := Nil
		
	Local oGetPer   := Nil
	Local oGetQtd  := Nil
	
	Local nTemp := 0
	Local nQtd  := 0

	Local aTasks    := {}	
	Local oCboTasks := Nil
	Local oCboProjs := Nil
	
	Local oChoose   := Nil
	
	Local nSelTask  := 1
	Local nSelProj  := 1
	
	Local aProjs := {}
	
	Local cDate := DToC(Date())
	
	Local oSayProj := Nil
	Local oSayTask := Nil
	Local oSayDate := Nil
	Local oSayTaskDes := Nil

	Local oChk     := Nil
	Local lCheck   := .F.
		
	Local aAFFItem := {}
	Local lBatch   := .F.
	
	Private lMsgInvQtd := .F.
	Private lMsgInvPer := .F.

	If (aAFFItemPre == Nil) .Or. (Len(aAFFItemPre) == 0)
		lBatch := .F.
	Else
		lBatch := .T.
	EndIf
	
	If !lBatch
		AFFInitItem(@aAFFItem)
	Else
		aAFFItem := aClone(aAFFItemPre)
	EndIf
	
	// seta o checkbox de confirmacao de entrega
	AFFSetAE(@aAFFItem, lCheck)

	Define Dialog oDlg Title STR0035  //APP_NAME //"Inclusão de Confirmação"
		//@  18, 05 Say "Inclusão de Confirmação" Bold Of oDlg

		// -------------------------------------------------------------------
		
		@  20, 05 Say STR0036       Of oDlg //"Projeto:"
		@  20, 50 Say oSayProj Prompt Space(30) Of oDlg
		SetText(oSayProj, aAFFItem[SUB_AFF_PROJET])
		
		@  34, 05 Say STR0037        Of oDlg //"Tarefa:"
		@  34, 50 Say oSayTask Prompt Space(30) Of oDlg
		SetText(oSayTask, aAFFItem[SUB_AFF_TAREFA])

		@  48, 05 Say STR0038     Of oDlg //"Descrição:"
		@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
		SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
		                                         aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])))

		If lBatch
			@  64, 05 Button oChoose Caption STR0039   Action ShowDetails(aAFFItem) Size 60, 10 of oDlg  //"Detalhes..."
		Else
			@  64, 05 Button oChoose Caption STR0040 Action ChooseTask(@aAFFItem, oSayProj, oSayTask, oSayTaskDes) Size 50, 10 of oDlg //"Selecionar"
		EndIf

		// -------------------------------------------------------------------

		@  80, 05 To 00,155 Of oDlg

		// -------------------------------------------------------------------

		@  84, 05 Say STR0041      Of oDlg //"Data ref:"
		@  84, 50 Say oSayDate Prompt DToC(aAFFItem[SUB_AFF_DATA]) Of oDlg
		@  84, 105 Button oBtnCalen Caption "..." Action GetDate(@aAFFItem ,oSayDate) Size 15, 10 Of oDlg

		@  98, 05 Say STR0042     Of oDlg //"% Exec.:"
		@  98, 50 Get oGetPer Var nTemp Picture "@E 999.99" Valid VldPer(@aAFFItem, Round(nTemp, 4), oGetQtd) Of oDlg

		@ 112, 05 Say STR0043       Of oDlg   //"Qtd. Exec.:"
		@ 112, 50 Get oGetQtd Var nQtd Picture "@E 999999.9999" Valid VldQtd(@aAFFItem, nQtd, oGetPer) Of oDlg

		@ 126, 03 CheckBox oChk Var lCheck Caption STR0044 Action AFFSetAE(@aAFFItem, lCheck) Of oDlg //"Gerar Autoriz. Entrega"
		SetText(oChk, lCheck)

		// -------------------------------------------------------------------
		
		//@ 140, 05 To 140, 155 Of oDlg    
		@ 140, 05 To 0, 155 Of oDlg

		// -------------------------------------------------------------------
		
		@ 145, 05 Button oBtnOk     Caption STR0045 Action VldAFFSave(@aAFFItem, nQtd, aItems) Size 35, 10 Of oDlg //"OK"
		@ 145, 55 Button oBtnCancel Caption STR0046 Action CloseDialog() Size 45, 10 Of oDlg //"Cancel"
	Activate Dialog oDlg
Return Nil