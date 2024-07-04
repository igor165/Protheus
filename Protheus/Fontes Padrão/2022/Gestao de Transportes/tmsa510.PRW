#INCLUDE 'Protheus.ch'
#INCLUDE "TMSA510.CH"

Static oBrowseDUO := Nil	//-- Perfil do Cliente
Static oBrowseAAM := Nil	//-- Contratos do Cliente
Static oBrowseDV2 := Nil	//-- Observações do Cliente
Static oBrowseDDO := Nil	//-- Distâncias entre Clientes
Static oBrowseDVZ := Nil	//-- Distâncias por Cliente
Static oBrowseDVN := Nil	//-- Prazos de Regiões do Cliente
Static oBrowseDV3 := Nil	//-- Inscrições Estaduais do Cliente
Static oBrowseDV5 := Nil	//-- Bloqueios do Cliente
Static oBrowseDW3 := Nil	//-- Filiais de Negociação do Cliente
Static oBrowseDV1 := Nil	//-- Regras por Cliente
Static oBrowseDWO := Nil	//-- Clientes Preservados
Static oBrowseDUE := Nil	//-- Solicitantes
Static oBrowseDTC := Nil	//-- Notas Fiscais
Static oBrowseDT6 := Nil	//-- Documentos
Static oBrowseDT5 := Nil	//-- Coletas
Static oBrowseDT4 := Nil	//-- Cotações
Static oBrowseSE1 := Nil	//-- Faturas
Static oBrowseDUU := Nil	//-- Pendências
Static oBrowseDUB := Nil	//-- Indenizações

Static oRelacDUO := Nil
Static oRelacAAM := Nil
Static oRelacDV2 := Nil
Static oRelacDDO := Nil
Static oRelacDVZ := Nil
Static oRelacDVN := Nil
Static oRelacDV3 := Nil
Static oRelacDV5 := Nil
Static oRelacDW3 := Nil
Static oRelacDV1 := Nil
Static oRelacDWO := Nil
Static oRelacDUE := Nil
Static oRelacDTC := Nil
Static oRelacDT6 := Nil
Static oRelacDT5 := Nil
Static oRelacDT4 := Nil
Static oRelacSE1 := Nil
Static oRelacDUU := Nil
Static oRelacDUB := Nil

Static aObjBrow  := {"","oBrowseDUO","oBrowseAAM","oBrowseDV2","oBrowseDDO","oBrowseDVZ","oBrowseDVN","oBrowseDV3","oBrowseDV5","oBrowseDW3","oBrowseDV1","oBrowseDWO","oBrowseDUE","oBrowseDTC","oBrowseDT6","oBrowseDT5","oBrowseDT4","oBrowseSE1","oBrowseDUU","oBrowseDUB"}
Static aObjRelac := {"","oRelacDUO","oRelacAAM","oRelacDV2","oRelacDDO","oRelacDVZ","oRelacDVN","oRelacDV3","oRelacDV5","oRelacDW3","oRelacDV1","oRelacDWO","oRelacDUE","oRelacDTC","oRelacDT6","oRelacDT5","oRelacDT4","oRelacSE1","oRelacDUU","oRelacDUB"}

Static oFolders	:= Nil

Static aBrowUsu   := {}
Static lTMA510BRW := ExistBlock("TMA510BRW")

Static oPainel1   := Nil
Static oPainel2   := Nil
Static oPainel3   := Nil
Static oPainel4   := Nil
Static oPainel5   := Nil
Static nFreteMes  := 0
Static nTotPeso   := 0
Static nTotVols   := 0
Static nTotPend   := 0
Static nPercServ  := 0

/*{Protheus.doc} TMSA510
    CockPit de Clientes
    @type Function
    @author Valdemar Roberto Mognon
    @since 16/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF60()
    (examples)
    @see (links_or_references)
*/
Function TMSA510()
Local aCoors    := FWGetDialogSize( oMainWnd )   
Local oPanelUp,oFWLayerUp,oFWLayerDw,oInferior := Nil
Local aFolders  := {}
Local nCntFor1  := 0
Local nCntFor2  := 0

Private cCadastro := STR0001	//-- "CockPit de Clientes"
Private oDlgPrinc
Private oBrowseUp

//-- Ponto de Entrada para Inclusão de Browses de Usuários
If lTMA510BRW
	aBrowUsu := ExecBlock("TMA510BRW",.F.,.F.,{})
	If ValType(aBrowUsu) != "A"
		aBrowUsu := {}
	Else
		For nCntFor1 := 1 To Len(aBrowUsu)
			&(aBrowUsu[nCntFor1,5] + " := Nil")
			&(aBrowUsu[nCntFor1,6] + " := Nil")
		Next nCntFor1
	EndIf
EndIf

//-- Desenha os Browses
DEFINE MSDIALOG oDlgPrinc TITLE cCadastro FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

	//-- Cria novo Layer
	oFWLayerUp := FWLayer():New()
	oFWLayerUp:Init(oDlgPrinc,.F.,.T.)

	//-- Cria as linhas do Layer
	oFWLayerUp:AddLine("UP",50,.F.)	//-- Adiciona linha superior (browse dos clientes)
	oFWLayerUp:AddLine("DOWN",50,.F.)	//-- Adiciona linha inferior (browses inferiores)

	//-- Browse superior dos clientes
	oFWLayerUp:AddCollumn("ALL",100,.T.,"UP")	//-- Adiciona coluna dos clientes
	oPanelUp := oFWLayerUP:GetColPanel("ALL","UP")  
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription(STR0003)	//-- Clientes
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetAlias("SA1")
	oBrowseUp:SetMenuDef("CRMA980")
	oBrowseUp:SetProfileID("1") 
	oBrowseUp:ForceQuitButton()
	oBrowseUp:SetMainProc("CRMA980")
	oBrowseUp:bChange := {|| ChgLine()}

	//-- Cria os Folders da linha inferior
	//-- Indicadores # Perfil do Cliente # Contratos do Cliente # Observações do Cliente # Distâncias entre Clientes # Distâncias do Cliente # Prazos de Regiões do Cliente
	//-- Inscrições Estaduais do Cliente # Bloqueios do Cliente # Filiais de Negociação do Cliente # Regras por Cliente # Clientes Preservados # Solicitantes
	//-- Notas Fiscais # Documentos # Coletas # Cotações # Faturas # Pendências # Indenizações
	aFolders  := {STR0063,STR0002,STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0058,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022}

	//-- Inclui Folders de Usuários
	If !Empty(aBrowUsu)
		For nCntFor1 := 1 To Len(aBrowUsu)
			Aadd(aFolders,aBrowUsu[nCntFor1,1])
		Next nCntFor1
	EndIf

	oInferior := oFWLayerUp:GetLinePanel("DOWN")
	oFolders  := TFolder():New(0,0,aFolders,aFolders,oInferior,,,,.T.,,oInferior:nClientWidth / 2,oInferior:nClientHeight / 2)
	oFolders:bChange := {|nFolder | lCria := Nil, CriaBrow(nFolder, @lCria),Atualiza(nFolder, lCria)}

	//-- Cria novo Layer para as pastas
	oFWLayerDw := FWLayer():New()
	oFWLayerDw:Init(oFolders:aDialogs[1],.F.,.T.)

	//-- Cria linha do Layer inferior
	oFWLayerDw:AddLine("DETALHE",100,.F.)

	//-- Cria coluna dos indicadores do cliente
	oFWLayerDw:AddCollumn("COLINDICA",100,.T.,"DETALHE")

	//-- Cria coluna dos perfis do cliente
	oFWLayerDw:AddCollumn("COLPERFIL",100,.T.,"DETALHE")

	//-- Cria coluna dos contratos do cliente
	oFWLayerDw:AddCollumn("COLCONTR",100,.T.,"DETALHE")

	//-- Cria coluna das observações do cliente
	oFWLayerDw:AddCollumn("COLOBSERV",100,.T.,"DETALHE")

	//-- Cria coluna das distâncias entre clientes
	oFWLayerDw:AddCollumn("COLDISENTR",100,.T.,"DETALHE")

	//-- Cria coluna das distâncias do cliente
	oFWLayerDw:AddCollumn("COLDISCLI",100,.T.,"DETALHE")

	//-- Cria coluna dos prazos de regiões do cliente
	oFWLayerDw:AddCollumn("COLPRAZO",100,.T.,"DETALHE")

	//-- Cria coluna das inscrições estaduais do cliente
	oFWLayerDw:AddCollumn("COLINSCR",100,.T.,"DETALHE")

	//-- Cria coluna dos bloqueios do cliente
	oFWLayerDw:AddCollumn("COLBLOQ",100,.T.,"DETALHE")

	//-- Cria coluna das filiais de negociação do cliente
	oFWLayerDw:AddCollumn("COLFILNEG",100,.T.,"DETALHE")

	//-- Cria coluna das regras de tributação por cliente
	oFWLayerDw:AddCollumn("COLREGRA",100,.T.,"DETALHE")

	//-- Cria coluna dos clientes preservados
	oFWLayerDw:AddCollumn("COLPRESERV",100,.T.,"DETALHE")

	//-- Cria coluna dos solicitantes
	oFWLayerDw:AddCollumn("COLSOLIC",100,.T.,"DETALHE")

	//-- Cria coluna das notas fiscais
	oFWLayerDw:AddCollumn("COLNOTAS",100,.T.,"DETALHE")
	
	//-- Cria coluna dos documentos
	oFWLayerDw:AddCollumn("COLDOCTOS",100,.T.,"DETALHE")

	//-- Cria coluna das coletas
	oFWLayerDw:AddCollumn("COLCOLET",100,.T.,"DETALHE")
	
	//-- Cria coluna das cotações
	oFWLayerDw:AddCollumn("COLCOTAC",100,.T.,"DETALHE")
	
	//-- Cria coluna das faturas
	oFWLayerDw:AddCollumn("COLFATURA",100,.T.,"DETALHE")
	
	//-- Cria coluna das pendências
	oFWLayerDw:AddCollumn("COLPENDEN",100,.T.,"DETALHE")
	
	//-- Cria coluna das indenizações
	oFWLayerDw:AddCollumn("COLINDENIZ",100,.T.,"DETALHE")

	//-- Browse inferior do Solicitante
	oBrowseDUE:= FWMBrowse():New()
	oBrowseDUE:SetOwner(oFolders:aDialogs[13])
	oBrowseDUE:SetDescription(STR0058)	//-- Solicitantes
	oBrowseDUE:SetMenuDef("TMSA440")
	oBrowseDUE:DisableDetails()
	oBrowseDUE:SetAlias("DUE") 	
	oBrowseDUE:SetProfileID("14")
	oBrowseDUE:SetMainProc("TMSA440")
	oBrowseDUE:Activate()

	//-- Realiza relacionamento dos solicitantes com o cliente
	oRelacDUE:= FWBrwRelation():New()
	oRelacDUE:AddRelation(oBrowseUp,oBrowseDUE,{{"DUE_FILIAL","xFilial('DUE')"},{"DUE_CODCLI","A1_COD"},{"DUE_LOJCLI","A1_LOJA"}})
	oRelacDUE:Activate()

	//-- Cria Colunas de Usuários
	If !Empty(aBrowUsu)
		For nCntFor1 := 1 To Len(aBrowUsu)
			&("oFWLayerDw:AddCollumn('" + aBrowUsu[nCntFor1,2] + "',100,.T.,'DETALHE')")
		Next nCntFor1
	EndIf

	//-- Cria Browses de Usuários
	If !Empty(aBrowUsu)
		For nCntFor1 := 1 To Len(aBrowUsu)
			If Valtype(aBrowUsu[nCntFor1,3]) == "A"
				//-- Monta Browses de Usuários
				&(aBrowUsu[nCntFor1,5] + ":= FWMBrowse():New()")
				For nCntFor2 := 1 To Len(aBrowUsu[nCntFor1,3])
					&(aBrowUsu[nCntFor1,5] + ":" + aBrowUsu[nCntFor1,3,nCntFor2])
				Next nCntFor2
				&(aBrowUsu[nCntFor1,5] + ":Activate()")
			EndIf

			If Valtype(aBrowUsu[nCntFor1,4]) == "A"
				//-- Monta Relacionamentos de Usuários
				&(aBrowUsu[nCntFor1,6] + ":= FWBrwRelation():New()")
				For nCntFor2 := 1 To Len(aBrowUsu[nCntFor1,4])
					&(aBrowUsu[nCntFor1,6] + ":" + aBrowUsu[nCntFor1,4,nCntFor2])
				Next nCntFor2
				&(aBrowUsu[nCntFor1,6] + ":Activate()")
				&(aBrowUsu[nCntFor1,5] + ":Refresh()")
			EndIf
		Next nCntFor1
	EndIf

	SA1->(DbSetOrder(1))
	oBrowseUp:Activate()
	oBrowseUP:GoTop(.T.)
    
	//-- Executa query dos indicadores
	If FindFunction("TMSPnlT510")
		TMSPnlT510(@nFreteMes,@nTotPeso,@nTotVols,@nTotPend,@nPercServ)
	EndIf

	//--  Aba dos indicadores
	oPainel1 := TMSPainel():New(oFolders:aDialogs[1],STR0064,AllTrim(TransForm(nFreteMes,X3Picture("DT6_VALMER"))) ,{228,  3,  3},,  5,5)	//-- "Faturamento Mensal"
	oPainel2 := TMSPainel():New(oFolders:aDialogs[1],STR0065,AllTrim(TransForm(nTotPeso  ,X3Picture("DT6_PESO")))  ,{255,140,  0},,120,5)	//-- "Total de Peso"
	oPainel3 := TMSPainel():New(oFolders:aDialogs[1],STR0066,AllTrim(TransForm(nTotVols  ,X3Picture("DT6_QTDVOL"))),{255,237,  0},,235,5)	//-- "Total de Volumes"
	oPainel4 := TMSPainel():New(oFolders:aDialogs[1],STR0067,AllTrim(TransForm(nTotPend  ,"@E 99999"))             ,{  0,128, 38},,350,5)	//-- "Total de Pendências"
	oPainel5 := TMSPainel():New(oFolders:aDialogs[1],STR0068,AllTrim(TransForm(nPercServ ,"@E 999.99"))            ,{  0, 77,255},,465,5)	//-- "% Nível de Serviço"

ACTIVATE MSDIALOG oDlgPrinc CENTER 

Zera()

Return

/*{Protheus.doc} Atualiza
Atualiza os browses inferiores
@type Function
@author Valdemar Roberto Mognon
@since 16/07/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Atualiza(nFolder,lCria)

Default nFolder := 1

Do Case
	Case nFolder == 1
		oBrowseUP:Refresh(.F.)
	Case nFolder == 2
		oBrowseDUO:Refresh(lCria)
	Case nFolder == 3
		oBrowseAAM:Refresh(lCria)
	Case nFolder == 4
		oBrowseDV2:Refresh(lCria)
	Case nFolder == 5
		oBrowseDDO:Refresh(lCria)
	Case nFolder == 6
		oBrowseDVZ:Refresh(lCria)
	Case nFolder == 7
		oBrowseDVN:Refresh(lCria)
	Case nFolder == 8
		oBrowseDV3:Refresh(lCria)
	Case nFolder == 9
		oBrowseDV5:Refresh(lCria)
	Case nFolder == 10
		oBrowseDW3:Refresh(lCria)
	Case nFolder == 11
		oBrowseDV1:Refresh(lCria)
	Case nFolder == 12
		oBrowseDWO:Refresh(lCria)
	Case nFolder == 13
		oBrowseDUE:Refresh(lCria)
	Case nFolder == 14
		oBrowseDTC:Refresh(lCria)
	Case nFolder == 15
		oBrowseDT6:Refresh(lCria)
	Case nFolder == 16
		oBrowseDT5:Refresh(lCria)
	Case nFolder == 17
		oBrowseDT4:Refresh(lCria)
	Case nFolder == 18
		oBrowseSE1:Refresh(lCria)
	Case nFolder == 19
		oBrowseDUU:Refresh(lCria)
	Case nFolder == 20
		oBrowseDUB:Refresh(lCria)
	Case nFolder > 20
		If !Empty(aBrowUsu)
			//-- Refresh em Browses de Usuários
			&(aBrowUsu[nFolder - 20,5] + ":Refresh()")
		EndIf
EndCase

Return .T.

/*{Protheus.doc} CriaBrow
Cria os browses inferiores
@type Function
@author Valdemar Roberto Mognon
@since 16/07/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function CriaBrow(nFolder, lCria)

Default nFolder := 1

Do Case
	Case nFolder == 1
		//-- Executa query dos indicadores
		If FindFunction("TMSPnlT510")
			TMSPnlT510(@nFreteMes,@nTotPeso,@nTotVols,@nTotPend,@nPercServ)
			oPainel1:AtuValor(AllTrim(TransForm(nFreteMes,X3Picture("DT6_VALMER"))))
			oPainel2:AtuValor(AllTrim(TransForm(nTotPeso,X3Picture("DT6_PESO"))))
			oPainel3:AtuValor(AllTrim(TransForm(nTotVols,X3Picture("DT6_QTDVOL"))))
			oPainel4:AtuValor(AllTrim(TransForm(nTotPend,"@E 99999")))
			oPainel5:AtuValor(AllTrim(TransForm(nPercServ,"@E 999.99")))
		EndIf

	Case nFolder == 2
		If Valtype(oBrowseDUO) == "U"
			//-- Browse inferior do perfil dos clientes
			oBrowseDUO:= FWMBrowse():New()
			oBrowseDUO:SetOwner(oFolders:aDialogs[2])
			oBrowseDUO:SetDescription(STR0002)	//-- Perfil dos Clientes
			oBrowseDUO:SetMenuDef("TMSA480")
			oBrowseDUO:DisableDetails()
			oBrowseDUO:SetAlias("DUO") 	
			oBrowseDUO:SetProfileID("3")
			oBrowseDUO:SetMainProc("TMSA480")
			oBrowseDUO:Activate()
		
			//-- Realiza relacionamento do perfil com o cliente
			oRelacDUO:= FWBrwRelation():New()
			oRelacDUO:AddRelation(oBrowseUp,oBrowseDUO,{{"DUO_FILIAL","xFilial('DUO')"},{"DUO_CODCLI","A1_COD"},{"DUO_LOJCLI","A1_LOJA"}})
			oRelacDUO:Activate()	
			lCria:= .T.
		EndIf

	Case nFolder == 3
		If Valtype(oBrowseAAM) == "U"
			//-- Browse inferior dos contratos do cliente
			oBrowseAAM:= FWMBrowse():New()
			oBrowseAAM:SetOwner(oFolders:aDialogs[3])
			oBrowseAAM:SetDescription(STR0004)	//-- Contratos dos Clientes
			oBrowseAAM:SetMenuDef("TECA250")
			oBrowseAAM:DisableDetails()
			oBrowseAAM:SetAlias("AAM") 	
			oBrowseAAM:SetProfileID("4")
			oBrowseAAM:SetMainProc("TECA250")
			oBrowseAAM:Activate()

			//-- Realiza relacionamento dos contratos com o cliente
			oRelacAAM:= FWBrwRelation():New()
			oRelacAAM:AddRelation(oBrowseUp,oBrowseAAM,{{"AAM_FILIAL","xFilial('AAM')"},{"AAM_CODCLI","A1_COD"},{"AAM_LOJA","A1_LOJA"}})
			oRelacAAM:Activate()
			lCria:= .T.
		EndIf

	Case nFolder == 4
		If Valtype(oBrowseDV2) == "U"
			//-- Browse inferior das observações do cliente
			oBrowseDV2:= FWMBrowse():New()
			oBrowseDV2:SetOwner(oFolders:aDialogs[4])
			oBrowseDV2:SetDescription(STR0005)	//-- Observação do Cliente
			oBrowseDV2:SetMenuDef("TMSA610")
			oBrowseDV2:DisableDetails()
			oBrowseDV2:SetAlias("DV2") 	
			oBrowseDV2:SetProfileID("5")
			oBrowseDV2:SetMainProc("TMSA610")
			oBrowseDV2:Activate()

			//-- Realiza relacionamento das observações com o cliente
			oRelacDV2:= FWBrwRelation():New()
			oRelacDV2:AddRelation(oBrowseUp,oBrowseDV2,{{"DV2_FILIAL","xFilial('DV2')"},{"DV2_CODCLI","A1_COD"},{"DV2_LOJCLI","A1_LOJA"}})
			oRelacDV2:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 5
		If Valtype(oBrowseDDO) == "U"
			//-- Browse inferior das distâncias entre clientes
			oBrowseDDO:= FWMBrowse():New()
			oBrowseDDO:SetOwner(oFolders:aDialogs[5])
			oBrowseDDO:SetDescription(STR0006)	//-- Distâncias entre Clientes
			oBrowseDDO:SetMenuDef("TMSAF14")
			oBrowseDDO:DisableDetails()
			oBrowseDDO:SetAlias("DDO") 	
			oBrowseDDO:SetProfileID("6")
			oBrowseDDO:SetMainProc("TMSAF14")
			oBrowseDDO:Activate()

			//-- Realiza relacionamento das distâncias entre clientes
			oRelacDDO:= FWBrwRelation():New()
			oRelacDDO:AddRelation(oBrowseUp,oBrowseDDO,{{"DDO_FILIAL","xFilial('DDO')"},{"DDO_CODCLI","A1_COD"},{"DDO_LOJCLI","A1_LOJA"}})
			oRelacDDO:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 6
		If Valtype(oBrowseDVZ) == "U"
			//-- Browse inferior das distâncias dos clientes
			oBrowseDVZ:= FWMBrowse():New()
			oBrowseDVZ:SetOwner(oFolders:aDialogs[6])
			oBrowseDVZ:SetDescription(STR0007)	//-- Distâncias do Cliente
			oBrowseDVZ:SetMenuDef("TMSA711")
			oBrowseDVZ:DisableDetails()
			oBrowseDVZ:SetAlias("DVZ") 	
			oBrowseDVZ:SetProfileID("7")
			oBrowseDVZ:SetMainProc("TMSA711")
			oBrowseDVZ:Activate()

			//-- Realiza relacionamento das distâncias do cliente
			oRelacDVZ:= FWBrwRelation():New()
			oRelacDVZ:AddRelation(oBrowseUp,oBrowseDVZ,{{"DVZ_FILIAL","xFilial('DVZ')"},{"DVZ_CODCLI","A1_COD"},{"DVZ_LOJCLI","A1_LOJA"}})
			oRelacDVZ:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 7
		If Valtype(oBrowseDVN) == "U"
			//-- Browse inferior dos prazos de regiões dos clientes
			oBrowseDVN:= FWMBrowse():New()
			oBrowseDVN:SetOwner(oFolders:aDialogs[7])
			oBrowseDVN:SetDescription(STR0008)	//-- Prazos de Regiões do Cliente
			oBrowseDVN:SetMenuDef("TMSA395")
			oBrowseDVN:DisableDetails()
			oBrowseDVN:SetAlias("DVN") 	
			oBrowseDVN:SetProfileID("8")
			oBrowseDVN:SetMainProc("TMSA395")
			oBrowseDVN:Activate()

			//-- Realiza relacionamento dos prazos com o cliente
			oRelacDVN:= FWBrwRelation():New()
			oRelacDVN:AddRelation(oBrowseUp,oBrowseDVN,{{"DVN_FILIAL","xFilial('DVN')"},{"DVN_CODCLI","A1_COD"},{"DVN_LOJCLI","A1_LOJA"}})
			oRelacDVN:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 8
		If Valtype(oBrowseDV3) == "U"
			//-- Browse inferior das inscrições estaduais dos clientes
			oBrowseDV3:= FWMBrowse():New()
			oBrowseDV3:SetOwner(oFolders:aDialogs[8])
			oBrowseDV3:SetDescription(STR0009)	//-- Inscrições Estaduais do Cliente
			oBrowseDV3:SetMenuDef("TMSA620")
			oBrowseDV3:DisableDetails()
			oBrowseDV3:SetAlias("DV3") 	
			oBrowseDV3:SetProfileID("9")
			oBrowseDV3:SetMainProc("TMSA620")
			oBrowseDV3:Activate()

			//-- Realiza relacionamento das inscrições com o cliente
			oRelacDV3:= FWBrwRelation():New()
			oRelacDV3:AddRelation(oBrowseUp,oBrowseDV3,{{"DV3_FILIAL","xFilial('DV3')"},{"DV3_CODCLI","A1_COD"},{"DV3_LOJCLI","A1_LOJA"}})
			oRelacDV3:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 9
		If Valtype(oBrowseDV5) == "U"
			//-- Browse inferior dos bloqueios do cliente
			oBrowseDV5:= FWMBrowse():New()
			oBrowseDV5:SetOwner(oFolders:aDialogs[9])
			oBrowseDV5:SetDescription(STR0010)	//-- Bloqueios do Cliente
			oBrowseDV5:SetMenuDef("TMSA630")
			oBrowseDV5:DisableDetails()
			oBrowseDV5:SetAlias("DV5") 	
			oBrowseDV5:SetProfileID("10")
			oBrowseDV5:SetMainProc("TMSA630")
			oBrowseDV5:Activate()

			//-- Realiza relacionamento dos bloqueios com o cliente
			oRelacDV5:= FWBrwRelation():New()
			oRelacDV5:AddRelation(oBrowseUp,oBrowseDV5,{{"DV5_FILIAL","xFilial('DV5')"},{"DV5_CODCLI","A1_COD"},{"DV5_LOJCLI","A1_LOJA"}})
			oRelacDV5:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 10
		If Valtype(oBrowseDW3) == "U"
			//-- Browse inferior das filiais de negociação dos clientes
			oBrowseDW3:= FWMBrowse():New()
			oBrowseDW3:SetOwner(oFolders:aDialogs[10])
			oBrowseDW3:SetDescription(STR0011)	//-- Filiais de Negocição do Cliente
			oBrowseDW3:SetMenuDef("TMSA950")
			oBrowseDW3:DisableDetails()
			oBrowseDW3:SetAlias("DW3") 	
			oBrowseDW3:SetProfileID("11")
			oBrowseDW3:SetMainProc("TMSA950")
			oBrowseDW3:Activate()

			//-- Realiza relacionamento das filiais de negociação com o cliente
			oRelacDW3:= FWBrwRelation():New()
			oRelacDW3:AddRelation(oBrowseUp,oBrowseDW3,{{"DW3_FILIAL","xFilial('DW3')"},{"DW3_CODCLI","A1_COD"},{"DW3_LOJCLI","A1_LOJA"}})
			oRelacDW3:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 11
		If Valtype(oBrowseDV1) == "U"
			//-- Browse inferior das regras por cliente
			oBrowseDV1:= FWMBrowse():New()
			oBrowseDV1:SetOwner(oFolders:aDialogs[11])
			oBrowseDV1:SetDescription(STR0012)	//-- Regras po Cliente
			oBrowseDV1:SetMenuDef("TMSA600")
			oBrowseDV1:DisableDetails()
			oBrowseDV1:SetAlias("DV1") 	
			oBrowseDV1:SetProfileID("12")
			oBrowseDV1:SetMainProc("TMSA600")
			oBrowseDV1:Activate()

			//-- Realiza relacionamento das filiais de negociação com o cliente
			oRelacDV1:= FWBrwRelation():New()
			oRelacDV1:AddRelation(oBrowseUp,oBrowseDV1,{{"DV1_FILIAL","xFilial('DV1')"},{"DV1_CODCLI","A1_COD"},{"DV1_LOJCLI","A1_LOJA"}})
			oRelacDV1:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 12
		If Valtype(oBrowseDWO) == "U"
			//-- Browse inferior dos clientes preservados
			oBrowseDWO:= FWMBrowse():New()
			oBrowseDWO:SetOwner(oFolders:aDialogs[12])
			oBrowseDWO:SetDescription(STR0013)	//-- Clientes Preservados
			oBrowseDWO:SetMenuDef("TMSA980")
			oBrowseDWO:DisableDetails()
			oBrowseDWO:SetAlias("DWO") 	
			oBrowseDWO:SetProfileID("13")
			oBrowseDWO:SetMainProc("TMSA980")
			oBrowseDWO:AddLegend("DWO_STATUS=='1'","GREEN",STR0014)	//-- Ativo
			oBrowseDWO:AddLegend("DWO_STATUS=='2'","RED"  ,STR0015)	//-- Inativo
			oBrowseDWO:Activate()

			//-- Realiza relacionamento dos clientes preservados com o cliente
			oRelacDWO:= FWBrwRelation():New()
			oRelacDWO:AddRelation(oBrowseUp,oBrowseDWO,{{"DWO_FILIAL","xFilial('DWO')"},{"DWO_CODCLI","A1_COD"},{"DWO_LOJCLI","A1_LOJA"}})
			oRelacDWO:Activate()
			lCria:= .T.
		EndIf

	Case nFolder == 14
		If Valtype(oBrowseDTC) == "U"
			//-- Browse inferior das notas fiscais
			oBrowseDTC:= FWMBrowse():New()
			oBrowseDTC:SetOwner(oFolders:aDialogs[14])
			oBrowseDTC:SetDescription(STR0016)	//-- Notas Fiscais
			oBrowseDTC:SetMenuDef("")
			MontaBtn(oBrowseDTC,"DTC")
			oBrowseDTC:DisableDetails()
			oBrowseDTC:SetAlias("DTC") 	
			oBrowseDTC:SetProfileID("15")
			oBrowseDTC:SetMainProc("TMSA050")
			oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='1'","YELLOW",STR0024)	//-- Em Aberto
			oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='2'","GREEN" ,STR0025)	//-- Digitado
			oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='3'","BLUE"  ,STR0026)	//-- Calculado
			oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='4'","RED"   ,STR0027)	//-- Bloqueado
			oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='5'","ORANGE",STR0028)	//-- Erro de Gravação
			oBrowseDTC:Activate()

			//-- Realiza relacionamento das notas fiscais com o cliente
			oRelacDTC:= FWBrwRelation():New()
			oRelacDTC:AddRelation(oBrowseUp,oBrowseDTC,{{"DTC_FILIAL","xFilial('DTC')"},{"DTC_CLIDEV","A1_COD"},{"DTC_LOJDEV","A1_LOJA"}})
			oRelacDTC:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 15
		If Valtype(oBrowseDT6) == "U"
			//-- Browse inferior dos documentos
			oBrowseDT6:= FWMBrowse():New()
			oBrowseDT6:SetOwner(oFolders:aDialogs[15])
			oBrowseDT6:SetDescription(STR0017)	//-- Documentos
			oBrowseDT6:SetMenuDef("")
			MontaBtn(oBrowseDT6,"DT6")
			oBrowseDT6:DisableDetails()
			oBrowseDT6:SetAlias("DT6") 	
			oBrowseDT6:SetProfileID("16")
			oBrowseDT6:SetMainProc("TMSA500")
			oBrowseDT6:AddLegend( "DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1')","BR_VERDE",STR0024)		//-- Em Aberto
			oBrowseDT6:AddLegend( "DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2')","BR_VERMELHO",STR0029)	//-- Carregado / Indicado para Coleta
			oBrowseDT6:AddLegend( "DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3')","BR_AMARELO",STR0030)	//-- Em Trânsito / Coleta em Processo
			oBrowseDT6:AddLegend("(DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5')","BR_LARANJA",STR0031)	//-- Chegada Parcial / Documento Informado
			oBrowseDT6:AddLegend("(DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4')","BR_AZUL",STR0032)		//-- Chegada Final / Coleta Encerrada
			oBrowseDT6:AddLegend( "DT6_STATUS == '6'","BR_CINZA",STR0033)	//-- Indicado para Entrega
			oBrowseDT6:AddLegend( "DT6_STATUS == '7'","BR_MARROM",STR0034)	//-- Entregue
			oBrowseDT6:AddLegend( "DT6_STATUS == '8'","BR_PINK",STR0035)	//-- Entrega Parcial
			oBrowseDT6:AddLegend( "TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')","BR_PRETO",STR0036)	//-- Ordem de Coleta Cancelada
			oBrowseDT6:AddLegend( "DT6_STATUS == '9'","BR_CANCEL",STR0037)	//-- Anulado
			oBrowseDT6:AddLegend( "DT6_STATUS == 'A'","BR_BRANCO",STR0038)	//-- Retorno Total
			oBrowseDT6:AddLegend( "DT6_STATUS == 'B'","PMSEDT4",STR0039)		//-- Cancelamento SEFAZ Aguardando
			oBrowseDT6:AddLegend( "DT6_STATUS == 'C'","PMSEDT3",STR0040)		//-- Cancelamento SEFAZ Autorizado
			oBrowseDT6:AddLegend( "DT6_STATUS == 'D'","PMSEDT1",STR0041)		//-- Cancelamento SEFAZ Não Autorizado
			oBrowseDT6:AddStatusColumns({||TF68StaCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegCTE()})
			oBrowseDT6:AddStatusColumns({||TF68AvbCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegAVB()})
			oBrowseDT6:Activate()

			//-- Realiza relacionamento dos documentos com o cliente
			oRelacDT6:= FWBrwRelation():New()
			oRelacDT6:AddRelation(oBrowseUp,oBrowseDT6,{{"DT6_FILIAL","xFilial('DT6')"},{"DT6_CLIDEV","A1_COD"},{"DT6_LOJDEV","A1_LOJA"}})
			oRelacDT6:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 16
		If Valtype(oBrowseDT5) == "U"
			//-- Browse inferior das coletas
			oBrowseDT5:= FWMBrowse():New()
			oBrowseDT5:SetOwner(oFolders:aDialogs[16])
			oBrowseDT5:SetDescription(STR0018)	//-- Coletas
			oBrowseDT5:SetMenuDef("")
			MontaBtn(oBrowseDT5,"DT5")
			oBrowseDT5:DisableDetails()
			oBrowseDT5:SetAlias("DT5") 	
			oBrowseDT5:SetProfileID("17")
			oBrowseDT5:SetMainProc("TMSA460")
			oBrowseDT5:AddLegend("DT5_STATUS=='1'","GREEN" ,STR0024)	//-- Em Aberto
			oBrowseDT5:AddLegend("DT5_STATUS=='2'","RED"   ,STR0059)	//-- Indicada para Coleta
			oBrowseDT5:AddLegend("DT5_STATUS=='3'","YELLOW",STR0060)	//-- Em Trânsito
			oBrowseDT5:AddLegend("DT5_STATUS=='4'","BLUE"  ,STR0045)	//-- Encerrada
			oBrowseDT5:AddLegend("DT5_STATUS=='5'","ORANGE",STR0061)	//-- Documento Informado
			oBrowseDT5:AddLegend("DT5_STATUS=='6'","GRAY"  ,STR0043)	//-- Bloqueada
			oBrowseDT5:AddLegend("DT5_STATUS=='7'","BROWN" ,STR0062)	//-- Em Conferência
			oBrowseDT5:AddLegend("DT5_STATUS=='9'","BLACK" ,STR0047)	//-- Cancelada
			oBrowseDT5:Activate()

			//-- Realiza relacionamento das coletas com o cliente
			oRelacDT5:= FWBrwRelation():New()
			oRelacDT5:AddRelation(oBrowseDUE,oBrowseDT5,{{"DT5_FILIAL","xFilial('DT5')"},{"DT5_CODSOL","DUE_CODSOL"}})
			oRelacDT5:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 17
		If Valtype(oBrowseDT4) == "U"
			//-- Browse inferior das cotações
			oBrowseDT4:= FWMBrowse():New()
			oBrowseDT4:SetOwner(oFolders:aDialogs[17])
			oBrowseDT4:SetDescription(STR0019)	//-- Cotações
			oBrowseDT4:SetMenuDef("")
			MontaBtn(oBrowseDT4,"DT4")
			oBrowseDT4:DisableDetails()
			oBrowseDT4:SetAlias("DT4")
			oBrowseDT4:SetProfileID("18")
			oBrowseDT4:SetMainProc("TMSA040")
			oBrowseDT4:AddLegend("DT4_STATUS=='1'","BR_AMARELO" ,STR0042)	//-- Pendente
			oBrowseDT4:AddLegend("DT4_STATUS=='2'","BR_VERMELHO",STR0043)	//-- Bloqueada
			oBrowseDT4:AddLegend("DT4_STATUS=='3'","BR_VERDE"   ,STR0044)	//-- Aprovada
			oBrowseDT4:AddLegend("DT4_STATUS=='4'","BR_AZUL"    ,STR0045)	//-- Encerrada
			oBrowseDT4:AddLegend("DT4_STATUS=='5'","BR_BRANCO"  ,STR0046)	//-- Bloqueada Div. Produtos/RRE
			oBrowseDT4:AddLegend("DT4_STATUS=='9'","BR_PRETO"   ,STR0047)	//-- Cancelada
			oBrowseDT4:Activate()

			//-- Realiza relacionamento das cotações com o cliente
			oRelacDT4:= FWBrwRelation():New()
			oRelacDT4:AddRelation(oBrowseUp,oBrowseDT4,{{"DT4_FILIAL","xFilial('DT4')"},{"DT4_CLIDEV","A1_COD"},{"DT4_LOJDEV","A1_LOJA"}})
			oRelacDT4:Activate()		
			lCria:= .T.
		EndIf
		
	Case nFolder == 18
		If Valtype(oBrowseSE1) == "U"
			//-- Browse inferior das faturas
			oBrowseSE1:= FWMBrowse():New()
			oBrowseSE1:SetOwner(oFolders:aDialogs[18])
			oBrowseSE1:SetDescription(STR0020)	//-- Faturas
			oBrowseSE1:SetMenuDef("")
			MontaBtn(oBrowseSE1,"SE1")
			oBrowseSE1:DisableDetails()
			oBrowseSE1:SetAlias("SE1")
			oBrowseSE1:SetProfileID("19")
			oBrowseSE1:SetMainProc("TMSA850")
			oBrowseSE1:AddLegend("E1_SITFAT == '3'","BR_PRETO",STR0048)				//-- Fatura Cancelada
			oBrowseSE1:AddLegend("ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .And. E1_SITUACA $ 'F6'","BR_AMARELO",STR0049)	//-- Fatura Protestada
			oBrowseSE1:AddLegend("ROUND(E1_SALDO,2) == 0","BR_VERMELHO",STR0050)	//-- Fatura Baixada
			oBrowseSE1:AddLegend("E1_SITFAT == '2'","BR_AZUL",STR0051)				//-- Fatura Impressa
			oBrowseSE1:AddLegend(".T.","BR_VERDE",STR0052)							//-- Fatura em Aberto
			oBrowseSE1:Activate()

			//-- Realiza relacionamento das faturas com o cliente
			oRelacSE1:= FWBrwRelation():New()
			oRelacSE1:AddRelation(oBrowseUp,oBrowseSE1,{{"E1_FILIAL","xFilial('SE1')"},{"E1_CLIENTE","A1_COD"},{"E1_LOJA","A1_LOJA"}})
			oRelacSE1:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 19
		If Valtype(oBrowseDUU) == "U"
			//-- Browse inferior das pendências
			oBrowseDUU:= FWMBrowse():New()
			oBrowseDUU:SetOwner(oFolders:aDialogs[19])
			oBrowseDUU:SetDescription(STR0021)	//-- Pendências
			oBrowseDUU:SetMenuDef("")
			MontaBtn(oBrowseDUU,"DUU")
			oBrowseDUU:DisableDetails()
			oBrowseDUU:SetAlias("DUU")
			oBrowseDUU:SetProfileID("20")
			oBrowseDUU:SetMainProc("TMSA540")
			oBrowseDUU:AddLegend("DUU_STATUS=='1'","GREEN" ,STR0024)	//-- Em Aberto
			oBrowseDUU:AddLegend("DUU_STATUS=='2'","YELLOW",STR0053)	//-- Indenização Solicitada
			oBrowseDUU:AddLegend("DUU_STATUS=='2'","RED"   ,STR0054)	//-- Indenizada
			oBrowseDUU:AddLegend("DUU_STATUS=='2'","BLUE"  ,STR0045)	//-- Encerrada
			oBrowseDUU:Activate()

			//-- Realiza relacionamento das pendências com o cliente
			oRelacDUU:= FWBrwRelation():New()
			oRelacDUU:AddRelation(oBrowseUp,oBrowseDUU,{{"DUU_FILIAL","xFilial('DUU')"},{"DUU_CODCLI","A1_COD"},{"DUU_LOJCLI","A1_LOJA"}})
			oRelacDUU:Activate()
			lCria:= .T.
		EndIf
		
	Case nFolder == 20
		If Valtype(oBrowseDUB) == "U"
			//-- Browse inferior das indenizações
			oBrowseDUB:= FWMBrowse():New()
			oBrowseDUB:SetOwner(oFolders:aDialogs[20])
			oBrowseDUB:SetDescription(STR0022)	//-- Indenizações
			oBrowseDUB:SetMenuDef("")
			MontaBtn(oBrowseDUB,"DUB")
			oBrowseDUB:DisableDetails()
			oBrowseDUB:SetAlias("DUB")
			oBrowseDUB:SetProfileID("21")
			oBrowseDUB:SetMainProc("TMSA370")
			oBrowseDUB:AddLegend("DUB_STATUS=='1'","GREEN" ,STR0024)	//-- Em Aberto
			oBrowseDUB:AddLegend("DUB_STATUS=='2'","YELLOW",STR0055)	//-- Autorizacao de Pagto
			oBrowseDUB:AddLegend("DUB_STATUS=='2'","BLUE"  ,STR0056)	//-- Encerrada - Indenizado
			oBrowseDUB:AddLegend("DUB_STATUS=='2'","BROWN" ,STR0057)	//-- Encerrada - Nao Indenizado
			oBrowseDUB:Activate()

			//-- Realiza relacionamento das indenizações com o cliente
			oRelacDUB:= FWBrwRelation():New()
			oRelacDUB:AddRelation(oBrowseUp,oBrowseDUB,{{"DUB_FILIAL","xFilial('DUB')"},{"DUB_CODCLI","A1_COD"},{"DUB_LOJCLI","A1_LOJA"}})
			oRelacDUB:Activate()
			lCria:= .T.
		EndIf
EndCase

Return .T.

/*{Protheus.doc} Zera
Zera variáveis estáticas
@type Static Function
@author Valdemar Roberto Mognon
@since 16/07/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Zera()

FwFreeObj(oBrowseDUO)
FwFreeObj(oBrowseAAM)
FwFreeObj(oBrowseDV2)
FwFreeObj(oBrowseDDO)
FwFreeObj(oBrowseDVZ)
FwFreeObj(oBrowseDVN)
FwFreeObj(oBrowseDV3)
FwFreeObj(oBrowseDV5)
FwFreeObj(oBrowseDW3)
FwFreeObj(oBrowseDV1)
FwFreeObj(oBrowseDWO)
FwFreeObj(oBrowseDUE)
FwFreeObj(oBrowseDTC)
FwFreeObj(oBrowseDT6)
FwFreeObj(oBrowseDT5)
FwFreeObj(oBrowseDT4)
FwFreeObj(oBrowseSE1)
FwFreeObj(oBrowseDUU)
FwFreeObj(oBrowseDUB)

FwFreeObj(oRelacDUO)
FwFreeObj(oRelacAAM)
FwFreeObj(oRelacDV2)
FwFreeObj(oRelacDDO)
FwFreeObj(oRelacDVZ)
FwFreeObj(oRelacDVN)
FwFreeObj(oRelacDV3)
FwFreeObj(oRelacDV5)
FwFreeObj(oRelacDW3)
FwFreeObj(oRelacDV1)
FwFreeObj(oRelacDWO)
FwFreeObj(oRelacDUE)
FwFreeObj(oRelacDTC)
FwFreeObj(oRelacDT6)
FwFreeObj(oRelacDT5)
FwFreeObj(oRelacDT4)
FwFreeObj(oRelacSE1)
FwFreeObj(oRelacDUU)
FwFreeObj(oRelacDUB)

FwFreeObj(oFolders)

FwFreeArray(aBrowUsu)

FwFreeObj(oPainel1)
FwFreeObj(oPainel2)
FwFreeObj(oPainel3)
FwFreeObj(oPainel4)
FwFreeObj(oPainel5)

nFreteMes  := 0
nTotPeso   := 0
nTotVols   := 0
nTotPend   := 0
nPercServ  := 0

Return

/*{Protheus.doc} TMSA510Cli
Posiciona no cliente e retorna um campo
@type Function
@author Valdemar Roberto Mognon
@since 19/07/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TMSA510Cli(cCodCli,cLojCli,cCampo)
Local cRet   := ""
Local aAreas := {SA1->(GetArea()),GetArea()}

cRet := Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli,cCampo)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

/*{Protheus.doc} MontBtn
Monta os botões de acesso às funções dos grids de movimento
@type Static Function
@author Valdemar Roberto Mognon
@since 03/08/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function MontaBtn(oBrowse,cAlias)

If cAlias == "DTC"
	If TmsAcesso(,"TMSA050",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA050"),INCLUI := .F., If( DTC->(EOF()), TMS510Help(), TMSA050Mnt("DTC",DTC->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "DT6"
	If TmsAcesso(,"TMSA500",,2,.F.)
		oBrowse:AddButton(STR0023, { || SetFunName("TMSA500"),INCLUI := .F.,aRotina := StaticCall(TMSA500,MenuDef), If( DT6->(EOF()), TMS510Help(), TMSA500Mnt("DT6",DT6->(Recno()),2) ), aRotina := Nil,oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "DT5"
	If TmsAcesso(,"TMSA460",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA460"),INCLUI := .F., If( DT5->(EOF()), TMS510Help(), TMSA460Mnt("DT5",DT5->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "DT4"
	If TmsAcesso(,"TMSA040",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA040"),INCLUI := .F., If( DT4->(EOF()), TMS510Help(), TMSA040Mnt("DT4",DT4->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "SE1"
	If TmsAcesso(,"TMSA850",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA850"),INCLUI := .F., If( SE1->(EOF()), TMS510Help(), TMSA850Vis("SE1",SE1->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "DUU"
	If TmsAcesso(,"TMSA540",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA540"),INCLUI := .F., If( DUU->(EOF()), TMS510Help(), TMSA540Mnt("DUU",DUU->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
ElseIf cAlias == "DUB"
	If TmsAcesso(,"TMSA370",,2,.F.)
		oBrowse:AddButton(STR0023,{|| SetFunName("TMSA370"),INCLUI := .F.,ALTERA := .F.,  If( DUB->(EOF()), TMS510Help(), TMSA370Mnt("DUB",DUB->(Recno()),2) ),oBrowse:Refresh()},,2,,.F.)	//-- Visualizar
	EndIf
EndIf

Return

/*{Protheus.doc} ChgLine
Trata mudança de linha do browse principal
@type Static Function
@author Valdemar Roberto Mognon
@since 17/08/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function ChgLine()

If Valtype(oPainel1) != "U"
	If oFolders:nOption == 1
		CriaBrow(1)
	EndIf
EndIf

Return


/*{Protheus.doc} TMS510Help
Aciona help para area de trabalho vazia
@type Static Function
@author Rodrigo Pirolo
@since 18/10/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/

Static Function TMS510Help()

	Help( '', 1, "TMSA510 - ARQVAZIO", , STR0069, 1 ) // STR0069 "A area de trabalho está vazia."

Return
