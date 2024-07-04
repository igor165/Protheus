#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA060
Consulta de Saldo de FGTS

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA060()
	If !PosSRAUser()
		Return 
	EndIf

	FWExecView("Extrato do FGTS", "TCFA060", MODEL_OPERATION_VIEW)
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
	
	aAdd(aRotina, {"Visualizar",	"VIEWDEF.TCFA060",	0, 2, 0, NIL})
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
	Local oStructSRA := Nil
	Local oStructSRS := Nil
	Local oModel     := Nil
	Local aAux       := {}

	oStructSRA := FWFormStruct(1, "SRA") //, {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")})
	oStructSRS := FWFormStruct(1, "SRS") //Item	
	//oStructSRS:RemoveField("RS_MAT")
	
	oModel:= MPFormModel():New("TCFA060")
	
	oModel:AddFields("TCFA060_SRA", NIL, oStructSRA , {|| .T.}/*Pre-Validacao*/,{|| .T.}/*Pos-Validacao*/,/*Carga */)
	oModel:AddGrid("TCFA060_SRS", "TCFA060_SRA", oStructSRS)
	
	oModel:SetPrimaryKey({"RA_MAT"})
	
	oModel:GetModel("TCFA060_SRS"):SetUniqueLine({"RS_MAT", "RS_ANO", "RS_MES"}) //Diz ao model que o campo deve ser validado quanto a repeticao
	oModel:SetRelation(	"TCFA060_SRS",;
						{	{"RS_MAT",		"RA_MAT"}		},;
						"RS_FILIAL+RS_MAT+RS_ANO+RS_MES")
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
	Local oView
	Local oStructSRA
	Local oStructSRS
	Local oModel := FWLoadModel("TCFA060")
	
	oView := FWFormView():New()

	oStructSRA := FWFormStruct(2, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")}) 
	oStructSRA:aFolders:= {}
	oStructSRS := FWFormStruct(2, "SRS") 	   		//Item
	oStructSRS:RemoveField("RS_MAT")

	oView:SetModel(oModel)
	oView:AddField("TCFA060_SRA", oStructSRA)   
	oView:AddGrid("TCFA060_SRS", oStructSRS)   
	
	oView:CreateHorizontalBox("HEADER", 10)
	oView:CreateHorizontalBox("ITEM", 90)      
	
	oView:SetOwnerView("TCFA060_SRA", "HEADER")
	oView:SetOwnerView("TCFA060_SRS", "ITEM")
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