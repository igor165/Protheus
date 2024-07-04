#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA080.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA080
Consulta da Tabela de Horarios

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA080()
	If !PosSRAUser()
		Return 
	EndIf

	If Pergunte("TCFA080", .T.)
		FWExecView(STR0001, "TCFA080", MODEL_OPERATION_VIEW)	//"Tabela de Horarios"
	EndIf
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
	
	aAdd(aRotina, {STR0025,	"TCFA080",	0, 2, 0, NIL})		//"Visualizar"
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
	Local oModel:= MPFormModel():New("TCFA080")
	Local oStructSRA := FWFormStruct(1, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")})
	Local oStructChild := FWFormModelStruct():New()            
	oStructChild:addField(STR0002, STR0002, "DATA", "D", 10)		//"Data"
	oStructChild:addField(STR0003, STR0003, "DIA",  "C", 8)			//"Dia"
	oStructChild:addField(STR0004, STR0005, "ENT1", "C", 5)			//"1ª Ent."	//"1ª Entrada"
	oStructChild:addField(STR0006, STR0007, "SAI1", "C", 5)			//"1ª Sai."	//"1ª Saida"
	oStructChild:addField(STR0008, STR0009, "ENT2", "C", 5)			//"2ª Ent."	//"2ª Entrada"
	oStructChild:addField(STR0010, STR0011, "SAI2", "C", 5)			//"2ª Sai."	//"2ª Saida"
	oStructChild:addField(STR0012, STR0013, "ENT3", "C", 5)			//"3ª Ent."	//"3ª Entrada"
	oStructChild:addField(STR0014, STR0015, "SAI3", "C", 5)			//"3ª Sai."	//"3ª Saida"
	oStructChild:addField(STR0016, STR0017, "ENT4", "C", 5)			//"4ª Ent."	//"4ª Entrada"
	oStructChild:addField(STR0018, STR0019, "SAI4", "C", 5)			//"4ª Sai."	//"4ª Saida"
	oStructChild:addField(STR0020, STR0020, "TIPO", "C", 30)		//"Tipo do Dia"
	
	
	oModel:AddFields("TCFA080_SRA", NIL, oStructSRA)

	oModel:AddGrid("TCFA080_TMP", "TCFA080_SRA", oStructChild, NIL, NIL, NIL, NIL, {|| Carga() } )
	oModel:GetModel("TCFA080_TMP"):SetDescription(STR0001)	//"Tabela de Horarios"
	
	oModel:SetPrimaryKey({"RA_MAT"})
Return(oModel)                                                                            


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
	Local oModel	 := FWLoadModel("TCFA080")
	Local oStructSRA := FWFormStruct(2, "SRA", {|cField|  (AllTrim(cField)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|")})
	Local oStructChild := FWFormViewStruct():New()
	oStructChild:addField("DATA", "01", STR0002, STR0002, NIL, "D", "@D")		//"Data"
	oStructChild:addField("DIA",  "02", STR0003, STR0003, NIL, "C", "")		//"Dia"
	oStructChild:addField("ENT1", "03", STR0004, STR0005, NIL, "C", "")		  //"1ª Ent."   "1ª Entrada"
	oStructChild:addField("SAI1", "04", STR0006, STR0007, NIL, "C", "")		  //"1ª Sai."   "1ª Saida"
	oStructChild:addField("ENT2", "05", STR0008, STR0009, NIL, "C", "")		  //"2ª Ent."   "2ª Entrada"
	oStructChild:addField("SAI2", "06", STR0010, STR0011, NIL, "C", "")		  //"2ª Sai."   "2ª Saida"
	oStructChild:addField("ENT3", "07", STR0012, STR0013, NIL, "C", "")		  //"3ª Ent."   "3ª Entrada"
	oStructChild:addField("SAI3", "08", STR0014, STR0015, NIL, "C", "")		  //"3ª Sai."   "3ª Saida"
	oStructChild:addField("ENT4", "09", STR0016, STR0017, NIL, "C", "")		  //"4ª Ent."   "4ª Entrada"
	oStructChild:addField("SAI4", "10", STR0018, STR0019, NIL, "C", "")		  //"4ª Sai."   "4ª Saida"
	oStructChild:addField("TIPO", "11", STR0020, STR0020, NIL, "C", "")		  //"Tipo do Dia"
	oStructSRA:aFolders:= {}
	
	oView:SetModel(oModel)
	oView:AddField("TCFA080_SRA", oStructSRA)   
	oView:AddGrid("TCFA080_TMP", oStructChild)
	
	oView:CreateHorizontalBox("HEADER", 10)
	oView:CreateHorizontalBox("ITEM", 90)      
	
	oView:SetOwnerView("TCFA080_SRA", "HEADER")
	oView:SetOwnerView("TCFA080_TMP", "ITEM")	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} Carga

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Carga()
	Local aTabCalend:= {}, aTabPadrao:= {}, aRet:= {}
	Local oTipoDia:= GetDayTypes()
	Local cOrdem:= ""
	Local nCount
	Local nHorasTrab
	
	Pergunte("TCFA080", .F.)	
	
	If !CriaCalend(	MV_PAR01		,;
					MV_PAR02		,;
					SRA->RA_TNOTRAB	,;
					SRA->RA_SEQTURN	,;
					@aTabPadrao	    	,;
					@aTabCalend		,;
					SRA->RA_FILIAL	,;
					SRA->RA_MAT		,;
					SRA->RA_CC		 ;
					)
		Return {}
	EndIf
		
	For nCount:= 1 To Len(aTabCalend)
		If cOrdem != aTabCalend[nCount, 2]
			cOrdem := aTabCalend[nCount, 2]
			nHorasTrab:= 0
			nPosHora:= 3
			
			Aadd(aRet, {0, {	aTabCalend[nCount, 1],;
								DiaSemana(aTabCalend[nCount, 1]),;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	NIL,;
							 	oTipoDia:GetItem(aTabCalend[nCount, 6])  } } )	
		EndIf

		nHorasTrab += aTabCalend[nCount, 7]
		
		If (nHorasTrab > 0)
			aRet[Len(aRet), 2, nPosHora] := StrTran(AllTrim(Str(aTabCalend[nCount, 3], 5, 2)), ".", ":")
		EndIf
		nPosHora++
	Next
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDayTypes()
Consulta da Tabela de Horarios

@author Rogerio Ribeiro da Cruz
@since 20/10/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function GetDayTypes()
	Local oTipoDia:= HashTable():New()
	oTipoDia:Add("S", STR0021)		//"Trabalhado"
	oTipoDia:Add("N", STR0022)		//"Nao Trabalhado"
	oTipoDia:Add("D", STR0023)		//"D.S.R."
	oTipoDia:Add("C", STR0024)		//"Compensado"
Return oTipoDia

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