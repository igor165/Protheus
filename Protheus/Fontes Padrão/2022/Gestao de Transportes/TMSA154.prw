#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TMSA154.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA154
Modelo da tabela de tracking

@author Gustavo Henrique Baptista
@since 20/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA154()
	Private oBrwTrk
	
	//Abertura da rotina se inicia por meio de um pergunte para filtro inicial
	If Pergunte('TMSA154',.T.)
		TMA154Par(1)
	EndIf
	
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TMSA154' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0014 ACTION 'TMA154Par(2)' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0017 ACTION 'T154LEG()' OPERATION 2 ACCESS 0 //Visualizar

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel  := MPFormModel():New('TMSA154')
Local oStruDLB := FWFormStruct( 1, 'DLB', /*bAvalCampo*/,/*lViewUsado*/ )

	oModel:AddFields( 'MASTER_DLB', /*cOwner*/, oStruDLB, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription(STR0001) //Tracking de Demandas
	
	oModel:SetPrimaryKey({}) 

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TMSA154' )
Local oStruDLB := FWFormStruct( 2, 'DLB' )
Local oView
Local cCampos := {}

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_DLB', oStruDLB, 'MASTER_DLB' )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMSCRTDMCBX
Retorna o tipo de registro do historico no X3_CBOX.
@sample    TMSCRTDMCBX()
@param     Nenhum
@Return    cRet    , caracter, tipo de registro no historico .
@author    Fabricia Mathes
@since     20/04/2018
@version   12.1.17
/*/
//------------------------------------------------------------------------------
Function TMSCRTDMCBX()

Local cRet := ""

//Resta apenas as letras CQ

cRet := "I="+STR0003+";" //"Inclusão"
cRet += "A="+STR0004+";" //"Ativação"
cRet += "P="+STR0005+";" //"Planejamento"
cRet += "T="+STR0006+";" //"Atendimento"
cRet += "S="+STR0007+";" //"Suspensão"
cRet += "R="+STR0008+";" //"Retomada" 
cRet += "U="+STR0009+";" //"Recusa" 
cRet += "F="+STR0010+";" //"Finalização"
cRet += "E="+STR0011+";" //"Encerramento"
cRet += "X="+STR0012+";" //"Exclusão"
cRet += "D="+STR0013+";" //"Desassociacao"
cRet += "G="+STR0018+";" //"Em Programação"
cRet += "H="+STR0019+";" //"Programação Cancelada/Excluída"
cRet += "V="+STR0020+";" //"Viagem Gerada"
cRet += "Z="+STR0021+";" //"Viagem Cancelada/Excluída"
cRet += "Y="+STR0022+";" //"Em Trânsito"
cRet += "W="+STR0023+";" //"Estorno de Trânsito"
cRet += "B="+STR0024+";" //"Estorno de Finalização"
cRet += "J="+STR0026+";" //"Cancelamento"
cRet += "K="+STR0027+";" //"Estorno de Cancelamento"
cRet += "M="+STR0028+";" //"Bloqueio"
cRet += "N="+STR0029+";" //"Desbloqueio"
cRet += "L="+STR0030+";" //"Reprocesso"
cRet += "O="+STR0031+";" //"Estorno de Reprocesso"

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMA154Par
Parametros da tela de tracking
@sample    TMA154Par()
@param     nOpc: Tipo de operacao / 1 - Via menu / 2 - F5 / 3 - Via Gestao de demanda
@param		cCtrDmd: Contrato de demanda
@param		cCodDmd: Codigo de demanda
@param		cSeqDmd: Sequencia de demanda
@param		cCodPln: Codigo do planejamento
@param		cCli: Cliente
@param		cLoja: Loja  
@param		cTipo: Tipo do documento / 1 - Contrato / 2 - Demanda / 3 - Planejamento / 4 - Todos  
@author    Ruan Ricardo Salvador
@since     11/05/2018
@version   12.1.17
/*/
//------------------------------------------------------------------------------
Function TMA154Par(nOpc, cCtrDmd, cCodDmd, cSeqDmd, cCodPln, cCli, cLoja, cTipo)

Default cCtrDmd := ''
Default cCodDmd := ''
Default cSeqDmd := ''
Default cCodPln := ''
Default cCli := ''
Default cLoja := ''
Default cTipo := ''
		
	If nOpc == 1 
			T154DLBOrd() //Efetua a ordenação
			
			SetKey(VK_F5,{ ||TMA154Par(2)} )
			oBrwTrk := FWMBrowse():New()
			oBrwTrk:SetAlias('DLB')
			oBrwTrk:SetDescription(STR0001) //Tracking de Demandas
			oBrwTrk:SetFilterDefault(TMA154Filt())
			oBrwTrk:AddStatusColumns({||T154Stat(DLB->DLB_TIPDOC)}, {||T154LEG()})
			oBrwTrk:Activate()
	ElseIf nOpc == 2
		If Pergunte('TMSA154',.T.)
			T154DLBOrd() //Efetua a ordenação
			
			oBrwTrk:SetFilterDefault(TMA154Filt()) 
			oBrwTrk:Refresh(.T.)
		EndIf
	ElseIf nOpc == 3
		//Tratativa para chamar a tela de tracking via painel de gestao de demandas com registro selecionado
		If !Pergunte('TMSA154', .F.)
			//Alterar os valores dos MV_PAR de acordo com registro selecionado em gestao de demandas
			MV_PAR01 := ''		//Data de:
			MV_PAR02 := ''		//Data ate:
			MV_PAR03 := cCtrDmd	//Contrato de:
			MV_PAR04 := cCtrDmd	//Contrato ate:
			MV_PAR05 := cCodDmd	//Demanda de:
			MV_PAR06 := cSeqDmd	//Sequencia demanda de:
			MV_PAR07 := cCodDmd	//Demanda ate:
			MV_PAR08 := cSeqDmd	//Sequencia demanda ate:
			MV_PAR09 := cCodPln	//Planejamento de:
			MV_PAR10 := cCodPln	//Planejamento ate:
			MV_PAR11 := cCli	//Cliente de:
			MV_PAR12 := cLoja	//Loja de:
			MV_PAR13 := cCli	//Cliente ate:
			MV_PAR14 := cLoja	//Loja ate:
			MV_PAR15 := cTipo	//Tipo do documento
			
			T154DLBOrd() //Efetua a ordenação
			
			SetKey(VK_F5,{ ||TMA154Par(2)} )
			oBrwTrk := FWMBrowse():New()
			oBrwTrk:SetAlias('DLB')
			oBrwTrk:SetDescription(STR0001) //Tracking de Demandas
			oBrwTrk:SetFilterDefault(TMA154Filt())
			oBrwTrk:AddStatusColumns({||T154Stat(DLB->DLB_TIPDOC)}, {||T154LEG()})
			oBrwTrk:SetMenuDef('TMSA154')			
			oBrwTrk:Activate()
			
			//Tratativa para que ao sair da tela volte o F5 e pergunte do filtro gestao de demandas.
			If IsInCallStack('TMSA153')
				SetKey(VK_F5,{ ||TMA153Par(.F.)} )
				Pergunte('TMSA153', .F.)
			ElseIf IsInCallStack('TMSA158')
				SetKey(VK_F5,{ ||TMA158Par(2)} )
			EndIf
		EndIf
	EndIf		
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMA154Filt
Filtro da tela de tracking
@sample    TMA154Filt()
@Return    Nil
@author    Ruan Ricardo Salvador
@since     11/05/2018
@version   12.1.17
/*/
//------------------------------------------------------------------------------
Function TMA154Filt()
Local cRet  	:= " "
	
	cRet := "@DLB_FILIAL = '" + xFilial('DLB') + "' "
	
	If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
		cRet += " AND DLB_DATA >= '" + DtoS(MV_PAR01) + "'"	
		cRet += " AND DLB_DATA <= '" + DtoS(MV_PAR02) + "'"
	EndIf
	
	If !Empty(MV_PAR03) .Or. !Empty(MV_PAR04) 
		cRet += " AND DLB_CRTDMD >= '" + MV_PAR03 + "'"
		cRet += " AND DLB_CRTDMD <= '" + MV_PAR04 + "'"
	EndIf
	
	If !Empty(MV_PAR05) .Or. !Empty(MV_PAR07) 
		cRet += " AND DLB_CODDMD >= '" + MV_PAR05 + "'"
		cRet += " AND DLB_CODDMD <= '" + MV_PAR07 + "'"
	EndIf
	
	If !Empty(MV_PAR06) .Or. !Empty(MV_PAR08) 	
		cRet += " AND DLB_SEQDMD >= '" + MV_PAR06 + "'"
		cRet += " AND DLB_SEQDMD <= '" + MV_PAR08 + "'"
	EndIf
	
	If !Empty(MV_PAR09) .Or. !Empty(MV_PAR10) 
		cRet += " AND DLB_CODPLN >= '" + MV_PAR09 + "'"
		cRet += " AND DLB_CODPLN <= '" + MV_PAR10 + "'"
	EndIf
	
	If !Empty(MV_PAR11) .Or. !Empty(MV_PAR13) 
		cRet += " AND DLB_CLIDEV >= '" + MV_PAR11 + "'"
		cRet += " AND DLB_CLIDEV <= '" + MV_PAR13 + "'"
	EndIf
	
	If !Empty(MV_PAR12) .Or. !Empty(MV_PAR14) 	
		cRet += " AND DLB_LOJDEV >= '" + MV_PAR12 + "'"
		cRet += " AND DLB_LOJDEV <= '" + MV_PAR14 + "'"
	EndIf
	
	If !Empty(MV_PAR15) .And. AllTrim(Str(MV_PAR15)) != '4'
		cRet += " AND DLB_TIPDOC = '" + AllTrim(Str(MV_PAR15)) + "'"
	EndIf

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T154Stat()
Função retorna as cores conforme o tipo do documento
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 11/05/2018
/*/
//-------------------------------------------------------------------------------------------------
Function T154Stat(cStatus)
	Do Case
		Case cStatus=="1"; cStatus := 'BR_AZUL'
		Case cStatus=="2"; cStatus := 'BR_VERDE'
		Case cStatus=="3"; cStatus := 'BR_VERMELHO'
	EndCase
Return cStatus

//------------------------------------------------------------------------------
/*/{Protheus.doc} T154LEG()
Duplo clique na legenda
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 11/05/2018
/*/
//-------------------------------------------------------------------------------------------------
Function T154LEG()
Local oLegend  :=  FWLegend():New()

	oLegend:Add("","BR_AZUL"    , STR0015) //Contrato
	oLegend:Add("","BR_VERDE"   , STR0016) //Demanda
	oLegend:Add("","BR_VERMELHO", STR0005) //Planejamento 

	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()
Return


/*/{Protheus.doc} T154DLBOrd
//Determina a ordenação dos registros
@author wander.horongoso
@since 28/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function T154DLBOrd()

	iIf (Empty(MV_PAR15), DLB->(DbSetOrder(4)), DLB->(DbSetOrder(MV_PAR15)))	

Return nil