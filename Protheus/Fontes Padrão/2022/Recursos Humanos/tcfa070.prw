#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA070
Consulta de Saldo do banco de horas

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA070()
	If !PosSRAUser()
		Return 
	EndIf

	//If Pergunte("TCFA070", .T.)
		FWExecView("Extrato do Banco de Horas", "TCFA070", MODEL_OPERATION_VIEW)
	//EndIf
Return

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

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd(aRotina, {"Visualizar",	"TCFA070",	0, 2, 0, NIL})
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStructSRA := FWFormStruct(1, "SRA", NIL, .F.)	//FWFormStruct(1, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")}, .T.)
	Local oStructSPI := FWFormStruct(1, "SPI", NIL, .F.)	//FWFormStruct(1, "SPI", {|cField| !(AllTrim(cField)+"|" $ "PI_CC|PI_QUANTV|PI_SALDOV|PI_DTBAIX|")}, .T.)
	
	Local oModel:= MPFormModel():New("TCFA070")
	oModel:SetDescription("Extrato do Banco de Horas")
	
	oModel:AddFields("TCFA070_SRA", NIL, oStructSRA)
	oModel:AddGrid("TCFA070_SPI", "TCFA070_SRA", oStructSPI)
	
	oModel:SetPrimaryKey({"RA_MAT"})
	
	oModel:GetModel("TCFA070_SPI"):SetUniqueLine({"PI_MAT", "PI_DATA"})
	oModel:SetRelation(	"TCFA070_SPI",;
						{	{"PI_MAT",		"RA_MAT"}	},;
						"PI_FILIAL+PI_MAT")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da visualização de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView		 := FWFormView():New()
	Local oModel	 := FWLoadModel("TCFA070")
	Local oStructSRA := FWFormStruct(2, "SRA", {|cField| (AllTrim(cField)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|")}, .F.)
	Local oStructSPI := FWFormStruct(2, "SPI", {|cField| (AllTrim(cField)+"|" $ "PI_DATA|PI_PD|PI_DESC|PI_QUANT|PI_SALDO|PI_STATUS|")}, .F.)
	
	oStructSRA:aFolders:= {}
	
	oView:SetModel(oModel)
	oView:AddField("TCFA070_SRA", oStructSRA)   
	oView:AddGrid("TCFA070_SPI", oStructSPI)   
	
	oView:CreateHorizontalBox("HEADER", 10)
	oView:CreateHorizontalBox("ITEM", 90)      
	
	oView:SetOwnerView("TCFA070_SRA", "HEADER")
	oView:SetOwnerView("TCFA070_SPI", "ITEM")	
Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewWebDef
Gera o XML para Web

@author Rogerio Ribeiro da Cruz
@since 29/06/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return oView:GetXML2Web(nOperation, cPk, cFormMVC)