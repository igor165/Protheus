#Include "FWMVCDEF.CH"
#INCLUDE "TMSA600.ch"
#include "Protheus.ch"

Static oBrowseDUI,oBrowseDUF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ TMSA600  ³ Autor ³ Henry Fila            ³ Data ³ 13/11/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Cadastro de Regra de tributacao por clientes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao da Revisao                      ³ Responsavel      ³   Data   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Conversao do fonte para o padrao MVC      ³ Mauro Paladini   ³02.10.2013³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA600()
Local aCoors   := FWGetDialogSize(oMainWnd)
Local aFolders := {}
Local aRotAnt  := {}
Local oFWLayerUp,oFWLayerDw,oInferior,oFolders
Local oPanelUp
Local oRelacDUI,oRelacDUF

Private cCadastro := STR0001	 //-- Regra de tributacao por cliente
Private aRotina   := MenuDef()
Private oDlgPrinc
Private oBrowseUp

DEFINE MSDIALOG oDlgPrinc TITLE cCadastro FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

	//-- Cria novo Layer	
	oFWLayerUp := FWLayer():New()
	oFWLayerUp:Init(oDlgPrinc,.F.,.T.)

	//-- Cria as linhas do Layer
	oFWLayerUp:AddLine("UP",50,.F.)	//-- Adiciona linha superior
	oFWLayerUp:AddLine("DOWN",50,.F.)	//-- Adiciona linha inferior

	//-- Browse superior dos lotes
	oFWLayerUp:AddCollumn("ALL",100,.T.,"UP")	//-- Adiciona coluna do Lote
	oPanelUp := oFWLayerUP:GetColPanel("ALL","UP")  
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription(cCadastro)
	oBrowseUp:SetAlias("DV1")
	oBrowseUp:SetMenuDef("TMSA600")
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetProfileID("1") 
	oBrowseUp:ForceQuitButton()
	oBrowseUp:SetMainProc("TMSA600")

	aRotAnt := Aclone(aRotina)
	
	//-- Cria os Folders da linha inferior
	aFolders  := {STR0007,STR0008}	//-- Configuração de Documentos # Regras de Tributação
	oInferior := oFWLayerUp:GetLinePanel("DOWN")
	oFolders  := TFolder():New(0,0,aFolders,aFolders,oInferior,,,,.T.,,oInferior:nClientWidth / 2,oInferior:nClientHeight / 2)
	oFolders:bChange := {|nFolder| Atualiza(nFolder)}

	//-- Cria novo Layer para as pastas
	oFWLayerDw := FWLayer():New()
	oFWLayerDw:Init(oFolders:aDialogs[1],.F.,.T.)

	//-- Cria linha do Layer inferior
	oFWLayerDw:AddLine("DETALHE",100,.F.)

	//-- Cria coluna das configurações de documentos
	oFWLayerDw:AddCollumn("COLCONFIGS",100,.T.,"DETALHE")

	//-- Browse inferior das configurações de documentos
	aRotina := {}
	oBrowseDUI:= FWMBrowse():New()
	oBrowseDUI:SetOwner(oFolders:aDialogs[1])
	oBrowseDUI:SetDescription(STR0007)	//-- Configuração de Documentos
	oBrowseDUI:SetMenuDef("TMSA150")
	oBrowseDUI:DisableDetails()
	oBrowseDUI:SetAlias("DUI") 	
	oBrowseDUI:SetProfileID("2")
	oBrowseDUI:SetMainProc("TMSA150")
	oBrowseDUI:Activate()

	//-- Realiza relacionamento da nota com o lote
	oRelacDUI:= FWBrwRelation():New()
	oRelacDUI:AddRelation(oBrowseUp,oBrowseDUI,{{"DUI_FILIAL","xFilial('DUI')"},{"DUI_DOCTMS","DV1_DOCTMS"}})
	oRelacDUI:Activate()

	//-- Cria coluna das regras de tributação
	oFWLayerDw:AddCollumn("COLREGTRIB",100,.T.,"DETALHE")

	//-- Browse inferior das regras de tributação
	aRotina := {}
	oBrowseDUF:= FWMBrowse():New()
	oBrowseDUF:SetOwner(oFolders:aDialogs[2])
	oBrowseDUF:SetDescription(STR0008)	//-- Regras de Tributação
	oBrowseDUF:SetMenuDef("TMSA410")
	oBrowseDUF:DisableDetails()
	oBrowseDUF:SetAlias("DUF") 	
	oBrowseDUF:SetProfileID("3")
	oBrowseDUF:SetMainProc("TMSA410")
	oBrowseDUF:Activate()

	//-- Realiza relacionamento da nota com o lote
	oRelacDUF:= FWBrwRelation():New()
	oRelacDUF:AddRelation(oBrowseUp,oBrowseDUF,{{"DUF_FILIAL","xFilial('DUF')"},{"DUF_REGTRI","DV1_REGTRI"}})
	oRelacDUF:Activate()

	oBrowseUp:Activate()

	aRotina := Aclone(aRotAnt)
		
ACTIVATE MSDIALOG oDlgPrinc CENTER 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modelo de dados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel Objeto do Modelo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDV1	:= Nil
Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil

oStruDV1  := FWFormStruct(1,"DV1")

oModel:= MpFormMOdel():New("TMSA600",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDV1",Nil,oStruDV1,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	 // "Regra de tributacao por cliente"
oModel:GetModel("MdFieldDV1"):SetDescription(STR0001) // "Regra de tributacao por cliente"
oModel:SetPrimaryKey({ "DV1_CODCLI","DV1_LOJCLI","DV1_DOCTMS","DV1_CODPRO","DV1_TIPNFC","DV1_TIPCLI","DV1_SEQINS" })

Return ( oModel )                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe browse de acordo com a estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ViewDef()

Local oModel := FwLoadModel("TMSA600")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDV1', FWFormStruct(2,"DV1") , 'MdFieldDV1') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDV1","TELA")

Return(oView)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º PosVldMdl  º Autor º        Nava        º Data º 02/11/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Funcao de validacao da Model                                		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º oModel                                  			       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Antiga funcao Tmsa600TudOk()                              º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador    º  Data    º BOPS º Motivo da Alteracao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Paladini º 09/08/13 º      º Conversao para padrao MVC            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosVldMdl(oMdl)

Local lRet    := .T.
Local aArea   := GetArea()
Local lRet    := .T.

Local cTipNfc := Iif(DV1->(FieldPos("DV1_TIPNFC")) > 0,M->DV1_TIPNFC,"")
Local cTipCli := Iif(DV1->(FieldPos("DV1_TIPCLI")) > 0,M->DV1_TIPCLI,"")
Local cSeqIns := Iif(DV1->(FieldPos("DV1_SEQINS")) > 0,M->DV1_SEQINS,"")

If oMdl <> Nil .And. ( oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE )
`
	//-- Verifica a existencia da alteracao do indice 1 no arquivo DV1 (Regra de Tribut. p/ Cliente)
	If !TMSBIndDV1()
		Return(.F.)
	EndIf
	
	If !Empty(M->DV1_CODCLI) .And. !Empty(M->DV1_LOJCLI) .And. !Empty(M->DV1_DOCTMS) .And. !Empty(M->DV1_REGTRI)
		If Inclui 
			DV1->(dbSetOrder(1))
			If DV1->(MsSeek(xFilial("DV1")+M->DV1_CODCLI+M->DV1_LOJCLI+M->DV1_DOCTMS+M->DV1_CODPRO+cTipNfc+cTipCli+cSeqIns))
				lRet := .F.
				Help(" ",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
			Endif	
		EndIf		
	Endif	
            
	RestArea(aArea)

Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MenuDef com as rotinas do Browse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina array com as rotina do MenuDef                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA600" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA600" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA600" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA600" OPERATION 5 ACCESS 0  //"Excluir"

Return ( aRotina )





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA600Whe³ Autor ³ Eduardo de Souza      ³ Data ³ 07.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o campo pode ser alterado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA600Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA600Whe(cCampo)

Local lRet     := .T.
Local cCliGen  := Alltrim(GetMV('MV_CLIGEN'))
Default cCampo := ReadVar()

If Type("M->DV1_CODCLI") <> "U"
	If cCampo == "M->DV1_TIPCLI"
		lRet := ( cCliGen == M->DV1_CODCLI + M->DV1_LOJCLI )
	ElseIf cCampo == "M->DV1_SEQINS"
		lRet := !( cCliGen == M->DV1_CODCLI + M->DV1_LOJCLI )
	EndIf
Else
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA600Vld³ Autor ³ Eduardo de Souza      ³ Data ³ 07.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da rotina                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA600Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA600Vld()

Local lRet := Vazio() .Or. ExistCpo("DV3",M->DV1_CODCLI+M->DV1_LOJCLI+M->DV1_SEQINS,1)

Return lRet


/*{Protheus.doc} Atualiza
Atualiza os browses inferiores
@type Function
@author Valdemar Roberto Mognon
@since 05/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Atualiza(nFolder)

Default nFolder := 1

Do Case
	Case nFolder == 1
		oBrowseDUI:Refresh()
	Case nFolder == 2
		oBrowseDUF:Refresh()
EndCase

Return .T.
