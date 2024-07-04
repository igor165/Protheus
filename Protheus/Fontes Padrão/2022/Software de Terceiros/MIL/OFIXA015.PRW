// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "PROTHEUS.CH"
#include "OFIXA015.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIXA015 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao de Venda  do Orcamento de Pecas e Servicos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXA015()

	Private oBrwXA015

	Private cCadastro := STR0001 // Liberação de Venda
	//Private aRotina   := MenuDef()

	If ! OXA015_VerAcesso()
		Return .f.
	Endif

	// Instanciamento da Classe de Browse
	oBrwXA015 := BrowseDef()
	oBrwXA015:Activate()

return .t.

/*/{Protheus.doc} BrowseDef
	Monta Browse
	@type  Function
	@author Rubens Takahashi
	@since 24/03/2021
/*/

Static Function BrowseDef()
	Local oBrowse := FWMBrowse():New()
	Local cAuxFilter := OXA015_MontaFiltro()

	oBrowse:SetAlias('VS6')
	oBrowse:SetDescription( STR0001 ) // "Liberação de Venda"
	oBrowse:SetFilterDefault(cAuxFilter)
	oBrowse:DisableDetails()
	
Return oBrowse

/*/{Protheus.doc} OXA015_MontaFiltro
	Monta filtro para Browse
	@type  Function
	@author Rubens Takahashi
	@since 24/03/2021
/*/
Static  Function OXA015_MontaFiltro()

	Local cFilterTP := "@"

	If GetNewPar("MV_GLIBVEN","N") == "N"
		cFilterTP += "VS6_DATAUT='        '  AND VS6_DATREJ='        ' AND VS6_TIPAUT IN ('1','2') "
	Else

		cFilterTP += "VS6_DATAUT='        ' AND VS6_DATREJ='        ' "

		VAI->(dbSetOrder(4))
		VAI->(dbSeek(xFilial("VAI")+__cUserID))

		// Liberacao de Venda 
		If  VAI->VAI_APRVLV == "1" 	// Liberacao de Peca
			cFilterTP += " AND ( VS6_TIPAUT='1' OR (VS6_TIPAUT='2' AND VS6_NUMIDE IN ( SELECT DISTINCT VS7.VS7_NUMIDE FROM " + RetSQLName("VS7") + " VS7 WHERE VS7.VS7_FILIAL=VS6_FILIAL AND VS7.VS7_NUMIDE=VS6_NUMIDE AND VS7.VS7_TIPAUT='1' AND VS7.D_E_L_E_T_=' '))) "
		ElseIf VAI->VAI_APRVLV == "2"	// Liberacao de Servico
			cFilterTP += " AND ( VS6_TIPAUT='2' AND VS6_NUMIDE IN ( SELECT DISTINCT VS7.VS7_NUMIDE FROM " + RetSQLName("VS7") + " VS7 WHERE VS7.VS7_FILIAL=VS6_FILIAL AND VS7.VS7_NUMIDE=VS6_NUMIDE AND VS7.VS7_TIPAUT='2' AND VS7.D_E_L_E_T_=' ')) "
		EndIf
		
		// Liberacao de Margem
		If VAI->VAI_APRVLM == "1" 		// 1=Descontos
			cFilterTP += " AND  VS6_TIPOCO='000008' "
		ElseIf VAI->VAI_APRVLM == "2"	// 2=Margem
			cFilterTP += " AND  VS6_TIPOCO='000009' "
		EndIf
		
	EndIf

	cFilterTP += " AND " +;
		" ( VS6_NUMORC = ' ' " +;
			" OR " +;
			" EXISTS(" +;
				" SELECT VS1_NUMORC " +;
				  " FROM " + RetSQLName("VS1") + " VS1 " +;
				 " WHERE VS1.VS1_FILIAL = VS6_FILIAL " +;
				 	" AND VS1.VS1_NUMORC = VS6_NUMORC " +;
					" AND VS1.VS1_STATUS = '2' " +;
					" AND ( VS1.VS1_DATVAL >= '" + dtos(dDatabase) + "' " +;
							" OR " +;
							" VS1.VS1_STARES IN ('1','2') " +;
							") " +;
					" AND VS1.D_E_L_E_T_=' ')" +;
		" ) "
Return cFilterTP

/*/{Protheus.doc} OXA015_VerAcesso
	Verifica se o usuário LOGADO possui permissão para liberar a venda
	@type  Function
	@author Rubens Takahashi
	@since 24/03/2021
/*/
Static Function OXA015_VerAcesso()

	VAI->(dbSetOrder(4))
	VAI->(dbSeek(xFilial("VAI")+__cUserID))

	// Liberacao de Venda 
	If VAI->VAI_APRVLV == "0" .or. Empty(VAI->VAI_APRVLV) // usuario nao autorizado
		MsgStop(STR0006+Alltrim(RetTitle("VAI_APRVLV"))+"(VAI_APRVLV)",STR0007)
		Return(.f.)
	EndIf
	
	// Liberacao de Margem
	If VAI->VAI_APRVLM == "0" .or. Empty(VAI->VAI_APRVLM) // usuario nao autorizado
		MsgStop(STR0006+Alltrim(RetTitle("VAI_APRVLM"))+"(VAI_APRVLM)",STR0007)
		Return(.f.)
	EndIf

Return .t. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA015   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Orcamento de Pecas e Servicos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA015(cAlias,nReg,nOpc)

Local lRet := .f.
Local nRecVS6

If ! OXA015_VerAcesso()
	Return .f.
EndIf

If nOpc <> 2 .and. ! Empty(VS6->VS6_DATAUT) .or. ! Empty( VS6->VS6_DATREJ )
	FMX_HELP("OXA15JALIB",STR0011) // "Solicitação de liberação de venda já foi liberada ou rejeitada."
	Return .f.
Endif

nRecVS6 := VS6->(Recno())

lRet := OFIXX003(cAlias,nReg,nOpc)

VS6->(DbGoTo(nRecVS6))

// Liberacao Oficina
If nOpc <> 2 .and. ! Empty(VS6->VS6_DATAUT) .and. VS6->VS6_TIPAUT == "2" .and. ! Empty(VS6->VS6_NUMORC)

	// No caso do orcamento de oficina, como nao tem separacao, quando o status cair para separacao, joga para finalizar..
	VS1->(DBSetOrder(1))
	If VS1->(DBSeek(xFilial("VS1")+VS6->VS6_NUMORC)) .and. VS1->VS1_STATUS == "4"
	
		DBSelectArea("VS1")
		RecLock("VS1",.f.)
		cVS1StAnt := VS1->VS1_STATUS
		VS1->VS1_STATUS := "F"
		MsUnlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Liberação de Venda
		EndIf

		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC," - Orcamento: " + VS6->VS6_NUMORC + " - Nro Identif.: " + VS6->VS6_NUMIDE ,VS1->VS1_FILIAL,cVS1StAnt)

		DBSelectArea("VS6")

	Endif

Endif

DBSelectArea("VS6")
oBrwXA015:Refresh()

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Pecas e Servicos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {;
	{ STR0002, "axPesqui",    0, 1},;    // "Pesquisar"
	{ STR0003, "OXA015"  , 0, 2},;    // "Visualizar"
	{ STR0004, "OXA015"  , 0, 4},;    // "Liberar"
	{ STR0008, "OXA015REJ"  , 0, 4} ;
	}    // "Rejeitar"
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIXA015  ºAutor  ³Renato Vinicius     º Data ³  10/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rejeicao de Pedido de Liberacao de Venda                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OXA015REJ(cAlias,nReg,nOpc)

If ! OXA015_VerAcesso()
	Return .f.
EndIf

If ! Empty(VS6->VS6_DATAUT) .or. ! Empty( VS6->VS6_DATREJ )
	FMX_HELP("OXA15JALIB",STR0011) // "Solicitação de liberação de venda já foi liberada ou rejeitada."
	Return .f.
Endif

If !MsgNoYes(STR0009,STR0007) // "Deseja realmente rejeitar este Pedido de Liberação?"
	Return .f.
EndIf

VS6->(DbGoto(nReg))
aMotCancel := OFA210MOT("000016","2","","",.f.) // Filtro da consulta do motivo
If Len(aMotCancel) > 0 
	DbSelectArea("VS6")
	RecLock("VS6",.f.)
		VS6->VS6_USUREJ := cUserName
		VS6->VS6_DATREJ := dDatabase
		VS6->VS6_HORREJ := val(substr(Time(),1,2)+substr(Time(),4,2))
		VS6->VS6_MOTREJ := aMotCancel[1]
	MsUnlock()
	///////////////////////////////////
	// Gravar Motivo de Cancelamento //
	///////////////////////////////////
	OFA210VDT("000016",aMotCancel[1],If(Empty(VS6->VS6_NUMORC),"2","4"),VS6->VS6_FILIAL,VS6->VS6_NUMORC,aMotCancel[4])
Else
	MsgInfo(STR0010,STR0007) // "Operação de Rejeição de Pedido abortada"
EndIf

Return .t.