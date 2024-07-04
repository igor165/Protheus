#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA292.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA292
Modelo de Telas habilitadas para rotinas customizadas do PagPFS

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Function JURA292()
Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetDescription(STR0001) //"Rotinas Disponiveis PagPFS"
	oBrowse:SetAlias("OHZ")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura do menu
        [n,1] Nome a aparecer no cabecalho
        [n,2] Nome da Rotina associada
        [n,3] Reservado
        [n,4] Tipo de Transação a ser efetuada:
            1 - Pesquisa e Posiciona em um Banco de Dados
            2 - Simplesmente Mostra os Campos
            3 - Inclui registros no Bancos de Dados
            4 - Altera o registro corrente
            5 - Remove o registro corrente do Banco de Dados
        [n,5] Nivel de acesso
        [n,6] Habilita Menu Funcional
@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estutura da Telas habilitadas para rotinas customizadas do PagPFS

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStructOHZ := FWFormStruct(2, "OHZ")
Local oModel     := FWLoadModel("JURA292")
Local oView      := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA292_VIEW", oStructOHZ, "OHZMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA292_VIEW", "FORMFIELD")
	oView:SetDescription(STR0001) // "Rotinas Disponiveis PagPFS"
	oView:EnableControlBar(.T.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura do modelo de dados das Telas habilitadas para rotinas customizadas do PagPFS

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructOHZ := FWFormStruct(1, "OHZ")
Local oModel     := NIL
	
	JCargaOHZ()
	oModel:= MPFormModel():New("JURA292", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("OHZMASTER", Nil, oStructOHZ, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:SetDescription(STR0001) // "Rotinas Disponiveis PagPFS"
	oModel:GetModel("OHZMASTER"):SetDescription(STR0001) // "Rotinas Disponiveis PagPFS"

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} JCargaOHZ
Realiza a carga inicial da OHZ

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Function JCargaOHZ()
Local aArea    := GetArea()
Local nI       := 0
Local aRotinas := {{"TITPAG", STR0002}, ; //"Títulos a pagar"
                   {"DESDOB", STR0003}, ; //"Desdobramentos a pagar"
                   {"POSPAG", STR0004}, ; //"Desdobramento pós-pagamento"
                   {"REVDSD", STR0005}}   //"Revisão de desdobramentos"
Local aOHZArea := OHZ->( GetArea() )

	DbSelectArea("OHZ")
	OHZ->( dbSetOrder(1) )
	For nI := 1 To Len(aRotinas)
		If !(OHZ->(DbSeek(xFilial("OHZ") + aRotinas[nI][1])))
			
			RecLock("OHZ", .T.)
			OHZ->OHZ_FILIAL := xFilial("OHZ")
			OHZ->OHZ_CODIGO := aRotinas[nI][1]
			OHZ->OHZ_NOME   := aRotinas[nI][2]
			MsUnlock()
		EndIf
	Next nI
	RestArea(aOHZArea)
	RestArea(aArea)
Return Nil
