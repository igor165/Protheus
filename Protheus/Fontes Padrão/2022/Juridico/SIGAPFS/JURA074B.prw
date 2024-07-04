#INCLUDE "JURA074B.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA074B
Geração automática de protocolos

@author Andreia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA074B( )
Private oBrw074B

oBrw074B := FWMarkBrowse():New()
oBrw074B:SetDescription( STR0001 ) //"Geração Automática de Protocolos"
oBrw074B:SetAlias( 'NXA' )
oBrw074B:SetMenuDef( 'JURA074B' )
oBrw074B:SetFilterDefault("NXA_SITUAC = '1'")
oBrw074B:SetFieldMark( 'NXA_OK' )
JurSetLeg( oBrw074B, 'NXA' )
JurSetBSize( oBrw074B )
oBrw074B:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Andreia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, 'JA074BGER( oBrw074B )', 0, 3, 0, NIL } ) //Gerar 
aAdd( aRotina, { STR0008, 'JA074BALL( .T. )' , 0, 4, 0, NIL } ) //"Marcar Todas"
aAdd( aRotina, { STR0009, 'JA074BALL( .F. )' , 0, 4, 0, NIL } ) //"Desmarcar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Fatura

@author Andréia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( 'JURA074B' )
Local oStruct := FWFormStruct( 2, 'NXA' )

JurSetAgrp( 'NXA',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA074B_VIEW', oStruct, 'NXAMASTER' )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA074B_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0005 ) //"Faturas"
IIf(IsBlind(), , oMarkUp:SetFieldMark( 'NXA_OK' )) // Controle devido a automação 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Fatura

@author Andréia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, 'NXA' )

oModel:= MPFormModel():New( 'JURA074B', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NXAMASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0003 ) //"Modelo de Dados de Fatura"
oModel:GetModel( 'NXAMASTER' ):SetDescription( STR0004 ) //"Dados de Fatura"
oModel:GetModel( 'NXAMASTER' ):SetOnlyView()
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074BGER
Gera protocolo automático

@author Andréia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074BGER( oBrw202B )
	Local cMarca    := oBrw074B:Mark()
	Local cCmd      := ''
	Local cQryRes   := GetNextAlias()
	Local aArea     := GetArea()
	Local cCodProt  := ''
	Local cTipoProt := ''

	cCmd := " SELECT NXA.NXA_COD, NXA.NXA_RAZSOC, NXA.NXA_CCONT, "
	cCmd +=        " NXA.NXA_LOGRAD, NXA.NXA_BAIRRO, NXA.NXA_CEP, "
	cCmd +=        " NXA.NXA_CIDADE, NXA.NXA_ESTADO, "
	cCmd +=        " NXA.NXA_PAIS, NXA.NXA_CESCR"
	cCmd +=   " FROM "+ RetSqlName( 'NXA' ) + " NXA "
	cCmd +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cCmd +=    " AND NXA.NXA_OK = '" + cMarca + "' "
	cCmd +=    " AND NXA.D_E_L_E_T_ = ' '"

	cCmd := ChangeQuery(cCmd, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd), cQryRes, .T., .T.)
	(cQryRes)->(dbgoTop())

	If !(cQryRes)->(EOF())

		cTipoProt := JASelOpcao('NXH_CTIPO')

		If !Empty(cTipoProt) .And. ExistCpo("NSO", cTipoProt, 1)

			BEGIN TRANSACTION

				cCodProt := GETSXENUM("NXH", "NXH_COD")

				RecLock("NXH", .T.)
				NXH->NXH_COD    := cCodProt
				NXH->NXH_CTIPO  := cTipoProt
				NXH->NXH_RZSOC  := (cQryRes)->NXA_RAZSOC
				NXH->NXH_CONTAT := Posicione("SU5", 1, xFilial("SU5") + (cQryRes)->NXA_CCONT, "U5_CONTAT")
				NXH->NXH_LOGRAD := (cQryRes)->NXA_LOGRAD
				NXH->NXH_BAIRRO := (cQryRes)->NXA_BAIRRO
				NXH->NXH_CEP    := (cQryRes)->NXA_CEP
				NXH->NXH_CID    := (cQryRes)->NXA_CIDADE
				NXH->NXH_UF     := (cQryRes)->NXA_ESTADO
				NXH->NXH_PAIS   := (cQryRes)->NXA_PAIS
				msUnlock()
	
			END TRANSACTION

			While !(cQryRes)->(EOF())
	
				BEGIN TRANSACTION
	
					RecLock("NXI", .T.)
					NXI->NXI_CPROT := cCodProt
					NXI->NXI_CESCR := (cQryRes)->NXA_CESCR
					NXI->NXI_CFAT  := (cQryRes)->NXA_COD
					msUnlock()
					(cQryRes)->(dbSkip())
	
				END TRANSACTION
			EndDo
			
			While GetSX8Len()>0
				ConfirmSX8()
			EndDo
	
			JA074BALL( .F. )
			APMsgInfo(STR0007) // "Protocolo Gerado"
			
		EndIf
		
	Else
		JurMsgErro(STR0006) // "Nenhuma fatura selecionada"
	EndIf
	
	oBrw202B:GoTop()
	oBrw202B:Refresh( .T. )

	(cQryRes)->(DbCloseArea())
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074BALL
Marca ou desmarca todos os registros da tela

@author Andréia S. N. de Lima
@since 22/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074BALL(lMarcar)
Local aArea   := GetArea()
Local cFiltro := oBrw074B:oBrowse:oFWFilter:GetExprADVPL()
Local bFiltro := { || }
Local cMarca  := oBrw074B:Mark()

	If ! Empty( cFiltro )
		cFiltOld := NXA->( dbFilter() )
		bFiltOld := IIf(! Empty(cFiltOld), &('{|| ' + AllTrim(cFiltOld) + '}'), '')

		bFiltro  := &('{||' + cFiltro + '}')

		NXA->(dbSetFilter(bFiltro, cFiltro))
	EndIf

	NX0->(dbGoTop())

	While ! NXA->(EOF()) 
		RecLock('NXA', .F.)
		NXA->NXA_OK := IIf(lMarcar, cMarca, '  ')
		MsUnLock()
		NXA->(dbSkip())
	EndDo

	If ! Empty(cFiltro)

		NXA->(dbClearFilter())

		If !Empty(cFiltOld)
			NXA->(dbSetFilter(bFiltOld, cFiltOld))
		EndIf
	EndIf

	RestArea(aArea)

Return Nil
