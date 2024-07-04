#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'totvs.ch'
#include 'gtpa700b.ch'

Static cNumFch 	:= ""
Static aFichas 	:= {}
Static nITFCH	:= 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700B()

Tela de Lançamento diário do Financeiro - Tesouraria 
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA700B(nOperation)
Local oMdl700B	:= FwLoadModel('GTPA700B')

aFichas := {}
cNumFch := ""
nITFCH  := 0

If FwIsInCallStack("G700LoadMov")

	oMdl700B:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl700B:Activate()
	oMdl700B:CommitData()
	oMdl700B:Destroy()
	
Else
	FWExecView(STR0032, 'VIEWDEF.GTPA700B', nOperation, , { || .T. } ) // "Depósitos"
Endif

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700B()

ModelDef 
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStruCab  	:= FWFormModelStruct():New()
Local oStruGrd  	:= FWFormModelStruct():New()
Local oStruG6Y	    := FWFormStruct(1,"G6Y")
Local bLoadCab	    := {|oFieldModel, lCopy| GTP7BCabLoad(oFieldModel, lCopy)}
Local bLoadGrid1	:= {|oSubMdl| G700BCarga(oSubMdl)}
Local bPosValid    := {|oSubMdl| TPPosCmt700B(oSubMdl)}
Local aRelation 	:= {}  
Local bPreLin		:= {|oGrid2,nLine,cAction,cField| GA700BPreLn(oGrid2,nLine,cAction, cField)}	
Local bPosLin		:= {|oGrid2| GA700BPosLn(oGrid2)}	
Local lLoadGrid1	:= .F.

	lLoadGrid1 :=	(FwIsInCallStack("GTPA700B") .Or. FwIsInCallStack("GTPA700C") .Or. FwIsInCallStack("GTPA700D") .Or. FwIsInCallStack("GTPA700I") .Or. ;
	 				FwIsInCallStack("GTPA700JA") .Or. FwIsInCallStack("GTPA700JB") .Or. FwIsInCallStack("GTPA700E") .Or. FwIsInCallStack("GTPA700N"))

	G700BStruct(oStruCab,oStruGrd,oStruG6Y,"M") 
		
	oModel := MPFormModel():New('GTPA700B',/*bPreValid*/, bPosValid, {|oMdl| G700BCommit(oMdl)}, /*bCancel*/)
	oModel:AddFields("CABESC",/*PAI*/,oStruCab,,,bLoadCab)
	
	oModel:AddGrid("GRID1", "CABESC", oStruGrd,,,,, (bLoadGrid1))


	aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"}}
	oModel:SetRelation( 'GRID1', aRelation )
	oModel:AddGrid("GRID2", "GRID1",oStruG6Y, bPreLin, bPoslin,,,IIF(lLoadGrid1,bLoadGrid1,))

	If FwIsInCallStack("GTPA700A")
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'1'"}	}
						
		oModel:GetModel("GRID2"):SetUniqueLine({"G6Y_ITEM","G6Y_NOTA","G6Y_SERIE","G6Y_FORNEC","G6Y_LOJA"})				
		
	ElseIf FwIsInCallStack("GTPA700B") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'2'"}	}
		oModel:GetModel("GRID1"):SetNoInsertLine(.T.)						
	
	ElseIf FwIsInCallStack("GTPA700C") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'3'"}	}
	ElseIf FwIsInCallStack("GTPA700D")
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'4'"}	}
		oModel:GetModel("GRID2"):SetNoInsertLine(.T.)
	ElseIf FwIsInCallStack("GTPA700E") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'6'"}	}
	ElseIf FwIsInCallStack("GTPA700I") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'7'"}	}
	ElseIf FwIsInCallStack("GTPA700JA") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'8'"}	}
		oModel:GetModel("GRID2"):SetUniqueLine({"G6Y_CODGZC"})
	ElseIf FwIsInCallStack("GTPA700JB") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'9'"}	}
		oModel:GetModel("GRID2"):SetUniqueLine({"G6Y_CODGZC"})
	ElseIf FwIsInCallStack("GTPA700N") 
		aRelation	:= {{"G6Y_FILIAL","xFilial('G6T')"},;
						{"G6Y_CODIGO","CODCX"}	,;
						{"G6Y_CODAGE","CODAGE"}	,;
						{"G6Y_NUMFCH","FICHA"}	,;
						{"G6Y_TPLANC","'A'"}	}
		oModel:GetModel("GRID2"):SetUniqueLine({"G6Y_CODGZC"})
	Endif
	
	oModel:SetRelation( 'GRID2', aRelation )	
	
	oModel:GetModel('GRID2'):SetMaxLine(999999)
	
	oModel:AddCalc('700TOTAL1' , 'GRID1', 'GRID1',  'FICHA' , 'G6Y_TOTFIC'	, 'FORMULA',,, STR0008,{|oModel| T700ACalc(oModel)}, 14, 2) // "Total Ficha de Remessa"
	
	If FwIsInCallStack("GTPA700A")
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM',/*bLoad*/,, STR0009) // "Total de Lançamento Diário"
	ElseIf FwIsInCallStack("GTPA700B") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM',{|oModel| SumCancelDep(oModel)},, STR0009) // "Total de Lançamento Diário"
	ElseIf FwIsInCallStack("GTPA700C") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM',/*bLoad*/,, STR0023) // "Total de Taxas Avulsas"
	ElseIf FwIsInCallStack("GTPA700D")
		oModel:AddCalc('700TOTAL3','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM',/*bLoad*/,,"Total a Pagar" ) // "Total a Pagar"
		oModel:AddCalc('700TOTAL4','GRID1','GRID2','G6Y_VALOR','G6Y_VALOR','SUM', {|| oModel:GetModel("GRID2"):GetValue("G6Y_AGRUPA")},,"Total" ) // "Total"
	ElseIf FwIsInCallStack("GTPA700E") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM',/*bLoad*/,, STR0027) // "Total de Vendas POS"
	ElseIf FwIsInCallStack("GTPA700I") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_TOTLAN','SUM', {|| oModel:GetModel("GRID2"):GetValue("G6Y_AGRUPA")},,"Total" ) // "Total"	
	ElseIf FwIsInCallStack("GTPA700JA") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_VALOR','SUM', {|oModel| SumCancelDep(oModel)},,"Total Receita" ) // "Total"	
	ElseIf FwIsInCallStack("GTPA700JB") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_VALOR','SUM', {|oModel| SumCancelDep(oModel)},,"Total Despesa" ) // "Total"	
	ElseIf FwIsInCallStack("GTPA700N") 
		oModel:AddCalc('700TOTAL2','GRID1','GRID2','G6Y_VALOR','G6Y_VALOR','SUM', {|oModel| SumCancelDep(oModel)},,"Total Despesa" ) // "Total"	
	Endif
	
	oModel:GetModel("CABESC"):SetOnlyQuery(.t.)
	oModel:GetModel("GRID1"):SetOnlyQuery(.t.)
	oModel:GetModel("GRID1"):SetNoInsertLine(.T.)
	
	oModel:GetModel ("GRID2"):SetOptional(.T.)
	
	oModel:GetModel("CABESC"):SetDescription(STR0007) // "Lançamento Diário"
	
	oModel:GetModel('GRID1'):SetDescription(STR0004) // "Ficha de Remessa"
	
	//oModel:GetModel('GRID2'):SetDescription("Lançamentos Diários") // "Lançaentos Diários"
	
	oModel:SetDescription(STR0007) // "Lançamentos Diário"
	
	oModel:SetPrimaryKey({})
	
	oModel:GetModel('GRID2'):SetMaxLine(999999)
	
	If  /*.Or.FwIsInCallStack('GTPA700C') /*.Or. FwIsInCallStack('GTPA700E') .Or. */ FwIsInCallStack("GTPA700JA") .OR. FwIsInCallStack("GTPA700JB")
	
		oModel:SetActivate( { |oModel| Processa ( {|| GA700BLoad( oModel ) }, STR0028,"")}) // "Aguarde, carregando dados..."
		
	Endif
	oModel:lModify := .T.
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700B()

ViewDef
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oStruCab	    := FWFormViewStruct():New()
Local oStruGrd	    := FWFormViewStruct():New()
Local oModel		:= FWLoadModel("GTPA700B")
Local oStruG6Y      := FWFormStruct(2,"G6Y")
Local oStruTot1     := FWCalcStruct( oModel:GetModel('700TOTAL1') )
Local oStruTot2     := FWCalcStruct( oModel:GetModel('700TOTAL2') )


	G700BStruct(oStruCab,oStruGrd,oStruG6Y,"V")

	oView := FWFormView():New()

	oView:SetModel(oModel)	
	
	oView:SetDescription(STR0007) // "Lançamento Diário"

	oView:AddField("VIEW_CAB",oStruCab,"CABESC")
	oView:AddGrid("V_FICHA"  ,oStruGrd,"GRID1")
	oView:AddGrid("V_LANCAM" ,oStruG6Y,"GRID2")
	oView:AddField("V_TOTAL1" ,oStruTot1,'700TOTAL1')
	oView:AddField("V_TOTAL2" ,oStruTot2,'700TOTAL2')

	oView:AddIncrementField( 'V_LANCAM', 'G6Y_ITEM' )
	
	oView:CreateHorizontalBox("CABECALHO" , 15) // Cabeçalho
	oView:CreateHorizontalBox("FCHDEREME" , 25) // Ficha de Remessa
	oView:CreateHorizontalBox("LANCAMENT" , 45) // Lançamentos Diários
	oView:CreateHorizontalBox("TOTALIZA"  , 15) // Totalizadores

	oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
	oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")
	
	oView:EnableTitleView("V_TOTAL1", STR0008) // "Total Ficha de Remessa"
	oView:EnableTitleView("V_TOTAL2", STR0009) // "Total de Lançamento Diário"
	
	oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
	oView:SetOwnerView( "V_FICHA", "FCHDEREME")
	oView:SetOwnerView( "V_LANCAM", "LANCAMENT")
	oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
	oView:SetOwnerView( "V_TOTAL2", "TOTAL2")
	
	oView:AddUserButton("Legendas","GTPA700B",{|oVw| TP700BDblClick(oVw)},"Depósitos", , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}) // "Vincular Cheque"

Return(oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G708BStruct(oStruCab,oStruGrd,cTipo)

Define as estruturas da Tela em MVC - Model e View
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function G700BStruct(oStruCab,oStruGrd,oStruG6Y,cTipo)
	
Local cFieldsIn := ""
Local aFldStr   := {}
Local aOrdem    := {}
Local nI        := 0
Local aTrigAux	:= {}

	If cTipo == "M"
	
		If ValType( oStruCab ) == "O"
	
		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField("FILIAL",;									// 	[01]  C   Titulo do campo // "Filial"
					 		"FILIAL",;									// 	[02]  C   ToolTip do campo // "Filial"
					 		"FILIAL",;							// 	[03]  C   Id do Field // "Filial"
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("G6T_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruCab:AddField(STR0010,;									// 	[01]  C   Titulo do campo  // "Caixa"
					 		STR0010,;								// 	[02]  C   ToolTip do campo // "Caixa"
					 		"CAIXA",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual

		oStruCab:AddField(STR0011,;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0012,;					// 	[02]  C   ToolTip do campo // "Código da Agência"
					 		"AGENCIA",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruCab:AddField(STR0013,;							// 	[01]  C   Titulo do campo // "Descrição"
					 		STR0013,;				// 	[02]  C   ToolTip do campo // "Descrição da Agência"
					 		"DESCRIAGEN",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							 TamSx3("GI6_DESCRI")[1] , ;			// 	[05]  N   Tamanho do campo						
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		 				 		
		EndIf
		
		If ValType( oStruGrd ) == "O"
			oStruGrd:AddTable("   ",{" "}," ")
			oStruGrd:AddField("FILIAL",;									// 	[01]  C   Titulo do campo // "Filial"
						 		"FILIAL",;									// 	[02]  C   ToolTip do campo // "Filial"
						 		"FILIAL",;							// 	[03]  C   Id do Field
						 		"C",;									// 	[04]  C   Tipo do campo
						 		TAMSX3("G6T_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
						 		
			oStruGrd:AddField(STR0015,;									// 	[01]  C   Titulo do campo // "Caixa"
					 		STR0015,;									// 	[02]  C   ToolTip do campo // "Caixa"
					 		"CODCX",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			oStruGrd:AddField(STR0011,;									// 	[01]  C   Titulo do campo // "Agência"
					 		STR0012,;									// 	[02]  C   ToolTip do campo  // "Código da Agência"
					 		"CODAGE",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
				
		    oStruGrd:AddField(STR0004,;					// 	[01]  C   Titulo do campo // "Ficha de Remessa"
						 		STR0004,;					// 	[02]  C   ToolTip do campo // "Ficha de Remessa"
						 		"FICHA",;								// 	[03]  C   Id do Field
						 		"C",;									// 	[04]  C   Tipo do campo
						 		10,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
			oStruGrd:AddField(STR0016,;								// 	[01]  C   Titulo do campo // "Data Inicial"
					 		    STR0016,;					// 	[02]  C   ToolTip do campo  // "Data Inicial"
						 		"DTINI",;								// 	[03]  C   Id do Field
						 		"D",;									// 	[04]  C   Tipo do campo
						 		8,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
			oStruGrd:AddField(STR0017,;								// 	[01]  C   Titulo do campo // "Data Final"
					 		    STR0017,;					// 	[02]  C   ToolTip do campo   // "Data Final"
						 		"DTFIN",;								// 	[03]  C   Id do Field
						 		"D",;									// 	[04]  C   Tipo do campo
						 		8,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual

			/*If G6X->(FieldPos('G6X_TITPRO')) > 0 .And. G6X->(FieldPos('G6X_DEPOSI')) > 0	

				oStruGrd:AddField(STR0034,;									// 	[01]  C   Titulo do campo // "Titulo Prov."
									STR0034,;								// 	[02]  C   ToolTip do campo // "Titulo Prov."
									"TITPRO",;								// 	[03]  C   Id do Field
									"C",;									// 	[04]  C   Tipo do campo
									1,;										// 	[05]  N   Tamanho do campo
									0,;										// 	[06]  N   Decimal do campo
									Nil,;									// 	[07]  B   Code-block de validação do campo
									Nil,;									// 	[08]  B   Code-block de validação When do campo
									Nil,;									//	[09]  A   Lista de valores permitido do campo
									.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
									Nil,;									//	[11]  B   Code-block de inicializacao do campo
									.F.,;									//	[12]  L   Indica se trata-se de um campo chave
									.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)									// 	[14]  L   Indica se o campo é virtual

				oStruGrd:AddField(STR0035,;									// 	[01]  C   Titulo do campo // "Tipo Pagto."
									STR0035,;								// 	[02]  C   ToolTip do campo // "Tipo Pagto."
									"DEPOSI",;								// 	[03]  C   Id do Field
									"C",;									// 	[04]  C   Tipo do campo
									1,;										// 	[05]  N   Tamanho do campo
									0,;										// 	[06]  N   Decimal do campo
									Nil,;									// 	[07]  B   Code-block de validação do campo
									Nil,;									// 	[08]  B   Code-block de validação When do campo
									Nil,;									//	[09]  A   Lista de valores permitido do campo
									.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
									Nil,;									//	[11]  B   Code-block de inicializacao do campo
									.F.,;									//	[12]  L   Indica se trata-se de um campo chave
									.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)									// 	[14]  L   Indica se o campo é virtual

			Endif	*/							 
						 		
		EndIf
		
		If  ValType(oStruG6Y ) == "O"
				
				oStruG6Y:AddField(	"",;									// 	[01]  C   Titulo do campo
				 	STR0018,;									// 	[02]  C   ToolTip do campo // "Legenda"
					"LEGENDA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		15,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
				
				
				If FwIsInCallStack("GTPA700A") // lançamento de notas de entrada
				
					oStruG6Y:AddField(	"   ",;									// 	[01]  C   Titulo do campo
				 	STR0019,;									// 	[02]  C   ToolTip do campo // "Nota"
					"NOTA" ,;							// 	[03]  C   Id do Field
					 		"BT",;									// 	[04]  C   Tipo do campo
					 		15,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		{||"LUPA"},;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
					
					// -------------------------------------+
					// DEFINE OBRIGATORIEDADE DOS CAMPOS G6Y|
					// -------------------------------------+
					oStruG6Y:SetProperty( '*'	,MODEL_FIELD_OBRIGAT, .F.)
					oStruG6Y:SetProperty( 'G6Y_ITEM'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_NOTA'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_SERIE'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_FORNEC'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_LOJA'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_DATA'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })					
					oStruG6Y:SetProperty( 'G6Y_VALOR'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_CHVTIT'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_NATURE'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_CC'		, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_CONTA'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'NOTA'		, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty( 'G6Y_TIPOL'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA700AX3WhenG6Y(oGrid, cCpo) })
					oStruG6Y:SetProperty("G6Y_TIPOL" 	,  MODEL_FIELD_INIT,{||'2' } )
					
					oStruG6Y:AddTrigger('G6Y_NOTA','G6Y_NOTA',{||.T.}, {|oMdl,cField,xVal| SeekSF1(oMdl,cField,xVal)})
					oStruG6Y:AddTrigger('G6Y_SERIE','G6Y_SERIE',{||.T.}, {|oMdl,cField,xVal| SeekSF1(oMdl,cField,xVal)})
					oStruG6Y:AddTrigger('G6Y_LOJA','G6Y_LOJA',{||.T.}, {|oMdl,cField,xVal| SeekSF1(oMdl,cField,xVal)})

					// -------------------------------------+
					// DEFINE VALID DOS CAMPOS G6Y|
					// -------------------------------------+
					oStruG6Y:SetProperty( '*'	, MODEL_FIELD_VALID, {|| .T. })
					//oStruG6Y:SetProperty( 'G6Y_NOTA'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| VLDNF(oGrid,cCpo,xValAtu) })	
				ElseIf FwIsInCallStack("GTPA700B") .Or. FwIsInCallStack("GTPA700N")
					
					//Define obrigação de campo
					oStruG6Y:SetProperty( 'G6Y_STSDEP'	,MODEL_FIELD_OBRIGAT, .T.)
					
					//Define validação dos campos
					oStruG6Y:SetProperty( 'G6Y_NUMFCH'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| TPVldNfc700b(oGrid,cCpo,xValAtu)})
					oStruG6Y:SetProperty( 'G6Y_BANCO'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| TPVldBc700b(oGrid,cCpo,xValAtu)})
					oStruG6Y:SetProperty( 'G6Y_DATA'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| TPVldDt700b(oGrid,cCpo,xValAtu)})
					oStruG6Y:SetProperty( 'G6Y_VALOR'	,MODEL_FIELD_VALID, {|| Positivo()})
					oStruG6Y:SetProperty( 'G6Y_STSDEP'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| TPVldPert700b(oGrid,cCpo,xValAtu)})
					oStruG6Y:SetProperty( 'G6Y_FORPGT'	,MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu| TPVldPert700b(oGrid,cCpo,xValAtu)})
							
				ElseIf FwIsInCallStack("GTPA700C")
					oStruG6Y:SetProperty("G6Y_DATA" ,  MODEL_FIELD_INIT,{|| dDataBase } )						
					oStruG6Y:SetProperty("G6Y_CODG57", MODEL_FIELD_INIT,{|| STR0024 } ) // "ACERTO"
					oStruG6Y:SetProperty("G6Y_NLOCOR", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('GI1', 1, xFilial('GI1') + G6Y->G6Y_LOCORI, 'GI1_DESCRI')"))

				ElseIf FwIsInCallStack("GTPA700E")
					oStruG6Y:SetProperty("G6Y_DATA" ,  MODEL_FIELD_INIT,{|| dDataBase } )						
					oStruG6Y:SetProperty("G6Y_CODGQM", MODEL_FIELD_INIT,{|| STR0024 } ) // "ACERTO"
					oStruG6Y:SetProperty("G6Y_DESADM", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SAE',1,XFILIAL('SAE')+GQL->GQL_CODADM,'AE_DESC')"))
					aTrigAux := FwStruTrigger("G6Y_CODADM", "G6Y_DESADM", "Posicione('SAE',1,xFilial('SAE') + FwFldGet('G6Y_CODADM'), 'AE_DESC')")
					oStruG6Y:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
				ElseIf FwIsInCallStack("GTPA700JA") .OR. FwIsInCallStack("GTPA700JB")  
					oStruG6Y:SetProperty( 'G6Y_CODGZC'	,MODEL_FIELD_OBRIGAT, .T.)
					oStruG6Y:AddField(	"Descrição",;									// 	[01]  C   Titulo do campo
					 				"Descrição",;									// 	[02]  C   ToolTip do campo // "Nota"
									"G6Y_DSCGZC" ,;							// 	[03]  C   Id do Field
							 		"C",;									// 	[04]  C   Tipo do campo
							 		TamSx3('GZC_DESCRI')[1],;										// 	[05]  N   Tamanho do campo
							 		0,;										// 	[06]  N   Decimal do campo
							 		Nil,;									// 	[07]  B   Code-block de validação do campo
							 		Nil,;									// 	[08]  B   Code-block de validação When do campo
							 		Nil,;									//	[09]  A   Lista de valores permitido do campo
							 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
							 		NIL,;							//	[11]  B   Code-block de inicializacao do campo
							 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
							 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							 		.T.)									// 	[14]  L   Indica se o campo é virtual
					oStruG6Y:AddTrigger('G6Y_VALOR','G6Y_ACERTO',{||.T.},{||.T.})
					oStruG6Y:AddTrigger('G6Y_CODGZC','G6Y_DSCGZC',{||.T.},{||Posicione('GZC',1,XFILIAL('GZC')+M->G6Y_CODGZC,'GZC_DESCRI')})
					oStruG6Y:SetProperty("G6Y_ACERTO" ,  MODEL_FIELD_INIT,{|| .T. } )
							
				Endif
		Endif
		
	Else
		If ValType( oStruCab ) == "O"
	
			oStruCab:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
		                        "01",;						// [02]  C   Ordem
		                        STR0010,;						// [03]  C   Titulo do campo // "Filial"
		                        STR0010,;						// [04]  C   Descricao do campo // "Filial"
		                        {STR0010},;					// [05]  A   Array com Help // "Selecionar"  //"Filial"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
			
			oStruCab:AddField(	"CAIXA",;				// [01]  C   Nome do Campo
		                        "02",;						// [02]  C   Ordem
		                        STR0015,;						// [03]  C   Titulo do campo // "Caixa"
		                        STR0015,;						// [04]  C   Descricao do campo // "Caixa"
		                        {STR0015},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		    oStruCab:AddField(	"AGENCIA",;				// [01]  C   Nome do Campo
		                        "03",;						// [02]  C   Ordem
		                        STR0011,;						// [03]  C   Titulo do campo // "Agência"
		                        STR0012,;						// [04]  C   Descricao do campo // "Código da Agência"
		                        {STR0012},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
					
		    oStruCab:AddField(	"DESCRIAGEN",;				// [01]  C   Nome do Campo
		                        "04",;						// [02]  C   Ordem
		                        STR0013,;						// [03]  C   Titulo do campo // "Descrição"
		                        STR0014,;						// [04]  C   Descricao do campo // "Descrição da Agência"
		                        {STR0014},;					// [05]  A   Array com Help // "Selecionar" // "Descrição da Agência"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
						 		
		    cFieldsIn := "CAIXA|AGENCIA|DESCRIAGEN"
			
				
			aFldStr := aClone(oStruCab:GetFields())
			
			For nI := 1 to Len(aFldStr)
			
				If ( !(aFldStr[nI,1] $ cFieldsIn) )
					oStruCab:RemoveField(aFldStr[nI,1])
			    EndIf
			
			Next nI
			                    
		EndIf
		
		If ValType( oStruGrd ) == "O"
			
			oStruGrd:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0010,;						// [03]  C   Titulo do campo // "Filial"
	                        STR0010,;						// [04]  C   Descricao do campo // "Filial"
	                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	        
	        oStruGrd:AddField(	"CODCX",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0015,;						// [03]  C   Titulo do campo // "Caixa"
	                        STR0015,;						// [04]  C   Descricao do campo // "Caixa"
	                        {STR0015},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	         oStruGrd:AddField(	"CODAGE",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0011,;						// [03]  C   Titulo do campo // "Agencia"
	                        STR0012,;						// [04]  C   Descricao do campo // "Código da Agência"
	                        {STR0012},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo         
	
					 		
			oStruGrd:AddField(	"FICHA",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        STR0004,;						// [03]  C   Titulo do campo // "Ficha de Remessa"
	                        STR0004,;						// [04]  C   Descricao do campo // "Ficha de Remessa"
	                        {STR0004},;					// [05]  A   Array com Help // "Selecionar" // "Ficha de Remessa"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	                        
	        oStruGrd:AddField(	"DTINI",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        STR0016,;						// [03]  C   Titulo do campo // "Data Incial"
	                        STR0016,;						// [04]  C   Descricao do campo // "Data Incial"
	                        {STR0016},;					// [05]  A   Array com Help // "Selecionar" // "Data Incial"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo	
			
			oStruGrd:AddField(	"DTFIN",;				// [01]  C   Nome do Campo
	                        "06",;						// [02]  C   Ordem
	                        STR0017,;						// [03]  C   Titulo do campo // "Data Final"
	                        STR0017,;						// [04]  C   Descricao do campo // "Data Final"
	                        {STR0017},;					// [05]  A   Array com Help // "Selecionar" // "Data Final"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo	
			

			/*If G6X->(FieldPos('G6X_TITPRO')) > 0 .And. G6X->(FieldPos('G6X_DEPOSI')) > 0	

				oStruGrd:AddField("TITPRO",;				// [01]  C   Nome do Campo
								"07",;						// [02]  C   Ordem
								STR0034,;					// [03]  C   Titulo do campo // "Titulo Prov"
								STR0034,;					// [04]  C   Descricao do campo // "Titulo Prov"
								{STR0034},;					// [05]  A   Array com Help // "Selecionar" // "Titulo Prov"
								"GET",;						// [06]  C   Tipo do campo
								"",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo

				oStruGrd:AddField("DEPOSI",;				// [01]  C   Nome do Campo
								"08",;						// [02]  C   Ordem
								STR0035,;					// [03]  C   Titulo do campo // "Tipo Pagto."
								STR0035,;					// [04]  C   Descricao do campo // "Tipo Pagto."
								{STR0035},;					// [05]  A   Array com Help // "Selecionar" // "Tipo Pagto."
								"GET",;						// [06]  C   Tipo do campo
								"",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo

			Endif	*/							 

			cFieldsIn := "FICHA|DTINI|DTFIN|"
	
			aFldStr := aClone(oStruGrd:GetFields())

			For nI := 1 to Len(aFldStr)
		
				If ( !(aFldStr[nI,1] $ cFieldsIn) )
					oStruGrd:RemoveField(aFldStr[nI,1])
				EndIf
		
			Next nI
			    
		EndIf
		
		If ValType( oStruG6Y ) == "O"
				
			oStruG6Y:AddField(	"LEGENDA",;				// [01]  C   Nome do Campo
	                "01",;						// [02]  C   Ordem
	                STR0018,;						// [03]  C   Titulo do campo // "Legenda"
	                STR0018,;						// [04]  C   Descricao do campo // "Legenda"
	                {STR0018},;					// [05]  A   Array com Help // "Selecionar" // "Legenda"
	                "GET",;					// [06]  C   Tipo do campo
	                "@BMP",;						// [07]  C   Picture
	                NIL,;						// [08]  B   Bloco de Picture Var
	                "",;						// [09]  C   Consulta F3
	                .T.,;						// [10]  L   Indica se o campo é alteravel
	                NIL,;						// [11]  C   Pasta do campo
	                "",;						// [12]  C   Agrupamento do campo
	                NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                NIL,;						// [15]  C   Inicializador de Browse
	                .T.,;						// [16]  L   Indica se o campo é virtual
	                NIL,;						// [17]  C   Picture Variavel
	                .F.)						// [18]  L   Indica pulo de linha após o campo	

				//Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL
			cFieldsIn := "G6Y_ITEM|G6Y_IDDEPO|G6Y_BANCO|G6Y_AGEBCO|"
			cFieldsIn += "G6Y_CTABCO|G6Y_DATA|G6Y_VALOR|LEGENDA|"
			cFieldsIn += "G6Y_STSDEP|G6Y_FORPGT|G6Y_CARGA|G6Y_NUMFCH,G6Y_CHVTIT"
			
				
			aFldStr := aClone(oStruG6Y:GetFields())
			
			For nI := 1 to Len(aFldStr)
			
		        If ( !(aFldStr[nI,1] $ cFieldsIn) )
		            oStruG6Y:RemoveField(aFldStr[nI,1])
		        EndIf
			
			Next nI
			    
		    AAdd(aOrdem,{"LEGENDA","G6Y_ITEM"})
		    AAdd(aOrdem,{"G6Y_ITEM","G6Y_NUMFCH"})
		    AAdd(aOrdem,{"G6Y_NUMFCH","G6Y_FORPGT"})
		    AAdd(aOrdem,{"G6Y_FORPGT","G6Y_BANCO"})
		    AAdd(aOrdem,{"G6Y_BANCO","G6Y_AGEBCO"})
		    AAdd(aOrdem,{"G6Y_AGEBCO","G6Y_CTABCO"})
		    AAdd(aOrdem,{"G6Y_CTABCO","G6Y_IDDEPO"})
		    AAdd(aOrdem,{"G6Y_IDDEPO","G6Y_DATA"})
		    AAdd(aOrdem,{"G6Y_DATA","G6Y_VALOR"})
		    AAdd(aOrdem,{"G6Y_VALOR","G6Y_STSDEP"})
		    AAdd(aOrdem,{"G6Y_STSDEP","G6Y_CARGA"})
		    AAdd(aOrdem,{"G6Y_CARGA","G6Y_CHVTIT"})
					    
		    GTPOrdVwStruct(oStruG6Y,aOrdem)
		    
		    //Retira os campos da View
		    oStruG6Y:RemoveField("G6Y_CARGA")
		    
		    //Adiciona Consulta Padrão aos campos
		    oStruG6Y:SetProperty("G6Y_BANCO" , MVC_VIEW_LOOKUP   , "SA6")
		    oStruG6Y:SetProperty("G6Y_NUMFCH", MVC_VIEW_LOOKUP   , "G6X")
		    
		    //Define quais campos não serão editáveis na view
		    oStruG6Y:SetProperty('LEGENDA'    , MVC_VIEW_CANCHANGE, .F. )
		    oStruG6Y:SetProperty('G6Y_ITEM'   , MVC_VIEW_CANCHANGE, .F. )
		    oStruG6Y:SetProperty('G6Y_BANCO' , MVC_VIEW_CANCHANGE, .T. )
		    oStruG6Y:SetProperty('G6Y_AGEBCO' , MVC_VIEW_CANCHANGE, .T. )
		    oStruG6Y:SetProperty('G6Y_CTABCO' , MVC_VIEW_CANCHANGE, .T. )
		    oStruG6Y:SetProperty('G6Y_CHVTIT' , MVC_VIEW_CANCHANGE, .F. )
		    		    
        EndIf
			
		
	EndIf
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP7BCabLoad()

Função responsável pelo Load do Cabeçalho da Tesouraria.
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------


Static Function GTP7BCabLoad(oFieldModel, lCopy)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

aAdd(aCampos,xFilial("G6T"))
aAdd(aCampos,G6T->G6T_CODIGO)
aAdd(aCampos,G6T->G6T_AGENCI)
aAdd(aCampos,G700BTrig())
		
Aadd(aLoad,aCampos)
Aadd(aLoad,G6T->(Recno()))
	
RestArea(aArea)

aFichas := {}
cNumFch := ""
nITFCH  := 0

Return aLoad

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G700BCarga(oSubMdl)

Função responsável pelo Load do Grid 1 - Ficha de Remessa
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function G700BCarga(oSubMdl)

Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cAliasQry3 := GetNextAlias()
Local cAliasQry4 := GetNextAlias()
Local cAliasPOS	 := GetNextAlias()
Local cAliasTEF	 := GetNextAlias()
Local cWhere	 := "%"
Local nConta     := 0
Local nx         := 0
Local oStruct    := oSubMdl:GetStruct() 
Local aCampos    := oStruct:GetFields()  
Local aLoad      := {}
Local cTpLanc    := GetTpLanc()
Local cFldsG6X	 := ''
Local cQuery	 := ''
Local cQryDep	 := ''

cCodigo := 	G6T->G6T_CODIGO
cAGencia := G6T->G6T_AGENCI

If oSubMdl:GetId() == 'GRID1'

	If G6X->(FieldPos('G6X_TITPRO')) > 0
		cFldsG6X := ' ,G6X_TITPRO '	
	Endif

	If G6X->(FieldPos('G6X_DEPOSI')) > 0
		cFldsG6X += ' ,G6X_DEPOSI '	
	Endif

	cFldsG6X := '%' + cFldsG6X + '%'

	BeginSQL Alias cAliasQry
		
		SELECT  G6X_FILIAL,G6X_NUMFCH,G6X_DTINI,G6X_DTFIN
		%Exp:cFldsG6X%
		FROM %Table:G6X% G6X
		WHERE G6X_FILIAL = %xFilial:G6X%
		AND G6X_STATUS IN ('3','4')
		AND G6X_CODCX  = %Exp:G6T->G6T_CODIGO%
		AND G6X_FLAGCX = 'T'		
		AND G6X_AGENCI = %Exp:G6T->G6T_AGENCI%
		AND %NotDel%
		ORDER BY G6X_CODCX,G6X_NUMFCH
			
	EndSQL
	
	If (cAliasQry)->(!Eof())

		While (cAliasQry)->(!Eof())
	
			nConta++
		
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
			
			For nX := 1 To Len(aCampos)
		
				If AllTrim(aCampos[nx,3]) == "FILIAL"
					aLoad[nConta,2,nx] := xFilial("G6X")
			
				ElseIf AllTrim(aCampos[nx,3]) == "CODCX"
					aLoad[nConta,2,nx] := G6T->G6T_CODIGO
				
				ElseIf AllTrim(aCampos[nx,3]) == "CODAGE"
					aLoad[nConta,2,nx] := G6T->G6T_AGENCI
			
				ElseIf AllTrim(aCampos[nx,3]) == "FICHA"
					aLoad[nConta,2,nx] := (cAliasQry)->G6X_NUMFCH
				
				ElseIf AllTrim(aCampos[nx,3]) == "DTINI"
					aLoad[nConta,2,nx] := STOD((cAliasQry)->G6X_DTINI)  
				
				ElseIf AllTrim(aCampos[nx,3]) == "DTFIN"
					aLoad[nConta,2,nx] := STOD((cAliasQry)->G6X_DTFIN)
				
		/*		ElseIf AllTrim(aCampos[nx,3]) == "TITPRO"
					aLoad[nConta,2,nx] := (cAliasQry)->G6X_TITPRO

				ElseIf AllTrim(aCampos[nx,3]) == "DEPOSI"
					aLoad[nConta,2,nx] :=(cAliasQry)->G6X_DEPOSI*/

				EndIf
				
			Next nX
			
			If FwIsInCallStack("GTPA700C") .Or. FwIsInCallStack("GTPA700D") .Or. FwIsInCallStack("GTPA700I") .Or. fwisincallstack("GTPA700B") ;
				.OR. (FwIsInCallStack("GTPA700JA") .Or. FwIsInCallStack("GTPA700JB") .Or. fwisincallstack("GTPA700E") .Or. fwisincallstack("GTPA700N"))
				
				If ASCAN(aFichas,(cAliasQry)->G6X_NUMFCH) == 0
					AAdd(aFichas,(cAliasQry)->G6X_NUMFCH )
				ENdif
				
			Endif
						
			If !(At((cAliasQry)->G6X_NUMFCH, cNumFch) > 0)
				cNumFch += (cAliasQry)->G6X_NUMFCH
				cNumFch += "/"
			Endif

			(cAliasQry)->(dbSkip())
		
		End While
		
		nITFCH := 0
	Else
		aAdd(aLoad,{0,{xFilial("G6X"), G6T->G6T_CODIGO, G6T->G6T_AGENCI, Space(TamSx3('G6X_NUMFCH')[1]),Space(TamSx3('G6X_DTINI')[1]), Space(TamSx3('G6X_DTFIN')[1])}})
	Endif
		
ElseIf  oSubMdl:GetId() =='GRID2' .And. FwIsInCallStack("GTPA700B")
		
	nITFCH++
				
	cCodigo := 	G6T->G6T_CODIGO
	cAGencia := G6T->G6T_AGENCI
	
	cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' "
	cWhere += "%"
	
	BeginSQL Alias cAliasQry2

		SELECT * 
		FROM %Table:G6Y% G6Y
		WHERE G6Y_FILIAL = %xFilial:G6Y%
		%Exp:cWhere%
		AND G6Y_CODIGO = %Exp:cCodigo%
		AND G6Y_CODAGE = %Exp:cAgencia%
		AND G6Y_TPLANC = %Exp:cTpLanc%
		AND %NotDel%
	
	EndSQL
	
	If (cAliasQry2)->(!Eof())
	
		While (cAliasQry2)->(!Eof())
			
			nConta++
			
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
						
			For nx := 1 To Len(aCampos) 
			
				If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
					aLoad[nConta,2,nx] := xFilial("G6Y")
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
					aLoad[nConta,2,nx] := G6T->G6T_CODIGO

				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
					aLoad[nConta,2,nx] := G6T->G6T_AGENCI
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_NUMFCH
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
					aLoad[nConta,2,nx] := cTpLanc
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_ITEM
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_IDDEPO"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_IDDEPO
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_BANCO"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_BANCO
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_AGEBCO"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_AGEBCO
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CTABCO"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CTABCO
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_VALOR
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
					aLoad[nConta,2,nx] := StoD((cAliasQry2)->G6Y_DATA)
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_FORPGT"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_FORPGT
						
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_STSDEP"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_STSDEP
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CHVTIT"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CHVTIT	
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
					aLoad[nConta,2,nx] := If((cAliasQry2)->G6Y_CARGA == "T", .T.,.F.)
					
				ElseIf AllTrim(aCampos[nx,3]) == "LEGENDA"
					aLoad[nConta,2,nx] := Iif((cAliasQry2)->G6Y_STSDEP == "1","BR_VERDE","BR_VERMELHO")					
		
				EndIf
			
			Next nX
			
			(cAliasQry2)->(dbSkip())
				
		End While
			
	ElseIf (cAliasQry2)->(Eof())
		
		cWhere := ""
		cWhere += "%"
		//cWhere += " AND GZE_NUMFCH IN " + FormatIn(cNumFch,"/")  
		cWhere += " AND GZE_NUMFCH = '" + aFichas[nITFCH] + "' " 
		cWhere += "%"

		If G6X->(FieldPos('G6X_TITPRO')) > 0
			cFldsG6X := ' ,G6X_TITPRO '	
		Endif

		If G6X->(FieldPos('G6X_DEPOSI')) > 0
			cFldsG6X += ' ,G6X_DEPOSI '	
		Endif

		cFldsG6X := '%' + cFldsG6X + '%'

		BeginSQL Alias cAliasQry3

			SELECT GZE.GZE_AGENCI,
				GZE.GZE_NUMFCH,
				GZE.GZE_IDDEPO,
				GZE.GZE_CODBCO,
				GZE.GZE_AGEBCO,
				GZE.GZE_CTABCO,
				GZE.GZE_VLRDEP,
				GZE.GZE_DTDEPO,
				GZE.GZE_FORPGT,
				G6X.G6X_NUMTIT
				%Exp:cFldsG6X%
			FROM %Table:GZE% GZE
			INNER JOIN %Table:G6X% G6X ON G6X.G6X_FILIAL = %xFilial:G6X%
			AND G6X.G6X_AGENCI = GZE.GZE_AGENCI
			AND G6X.G6X_NUMFCH = GZE.GZE_NUMFCH
			AND G6X.%NotDel%
			WHERE GZE_FILIAL =  %xFilial:GZE%
			%Exp:cWhere%	
			AND GZE_AGENCI = %Exp:G6T->G6T_AGENCI%
			AND GZE.%NotDel%		
		
		EndSQL
			
		If (cAliasQry3)->(!Eof())

			While (cAliasQry3)->(!Eof())
		
				nConta++
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
					
				For nx := 1 To Len(aCampos)
		
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("GZE")
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
						aLoad[nConta,2,nx] := StrZero(aLoad[nConta][1],3)
	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_AGENCI
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_NUMFCH
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
				 		aLoad[nConta,2,nx] := cTpLanc
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_IDDEPO"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_IDDEPO
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_BANCO"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_CODBCO
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_AGEBCO"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_AGEBCO
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CTABCO"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_CTABCO
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_VLRDEP
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
						aLoad[nConta,2,nx] := StoD((cAliasQry3)->GZE_DTDEPO)
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CHVTIT"
						aLoad[nConta,2,nx] := (cAliasQry3)->G6X_NUMTIT
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_FORPGT"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZE_FORPGT
							
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_STSDEP"

						If (G6X->(FieldPos('G6X_TITPRO')) > 0 .And. G6X->(FieldPos('G6X_DEPOSI')) > 0) .And.;
						  ((cAliasQry3)->G6X_TITPRO == '2' .Or. (cAliasQry3)->G6X_DEPOSI == '3')
							aLoad[nConta,2,nx] := '1'
						Else
							aLoad[nConta,2,nx] := ''
						Endif	
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
						aLoad[nConta,2,nx] := .T.
						
					ElseIf AllTrim(aCampos[nx,3]) == "LEGENDA"
						aLoad[nConta,2,nx] := "BR_VERDE"
						
					EndIf
					
				Next nX
				
				(cAliasQry3)->(dbSkip())
			
			End While
			
		EndIf
			
	EndIf
	
ElseIf oSubMdl:GetId() =='GRID2' .And. FwIsInCallStack("GTPA700C")
	
	nITFCH++
	//For nI := 1 to Len(aFichas)
	cWhere := ''
	cWhere := "%"
			
	//cWhere += " AND G6Y_NUMFCH IN " + FormatIn(SubStr(cNumFch, 1, Len(cNumFch)-1 ),"/")  
	cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' " 
	cWhere += "%"
	
	If Select(cAliasQry4) > 0
		(cAliasQry4)->(dbCloseArea())
	Endif
	
	BeginSQL Alias cAliasQry4
	
		SELECT *	
		FROM 
			%Table:G6Y% G6Y
		WHERE 
			G6Y_FILIAL = %xFilial:G6Y%
			%Exp:cWhere%
			AND G6Y_CODIGO = %Exp:cCodigo%
			AND G6Y_CODAGE = %Exp:cAgencia%
			AND G6Y_TPLANC = %Exp:cTpLanc%
			AND %NotDel%
		
	EndSQL
		
	If (cAliasQry4)->(!Eof())
		
		nConta := 0
		
		While (cAliasQry4)->(!Eof())
		
			nConta++
		
						
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
		
			For nx:=1 To Len(aCampos)
		
				If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
					aLoad[nConta,2,nx] := xFilial("G6Y")
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
					aLoad[nConta,2,nx] := G6T->G6T_CODIGO
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
					aLoad[nConta,2,nx] := G6T->G6T_AGENCI
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
					aLoad[nConta,2,nx] := aFichas[nITFCH] 
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
					aLoad[nConta,2,nx] := cTpLanc						
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_ITEM
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODG57"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_CODG57							
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMMOV"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_NUMMOV							
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
					aLoad[nConta,2,nx] := STOD((cAliasQry4)->G6Y_DATA)						
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_LOCORI"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_LOCORI						
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_VALOR
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NLOCOR"
					aLoad[nConta,2,nx] := Posicione("GI1",1,XFILIAL("GI1")+(cAliasQry4)->G6Y_LOCORI,"GI1_DESCRI")
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
					aLoad[nConta,2,nx] :=(cAliasQry4)->G6Y_CARGA
				EndIf
			
			Next nX
			
			(cAliasQry4)->(dbSkip())	
		
		End While	
			
	Else
		
		If Select(cAliasQry2) > 0
			(cAliasQry2)->(dbCloseArea())
		Endif
		
		BeginSQL Alias cAliasQry2
		
			SELECT  G57_CODIGO,
					G57_NUMMOV,
					G57_VALOR,
					G57_VALACE,
					G57_EMISSA,
					G57_LOCORI
			FROM %Table:G57% G57	
			WHERE G57_FILIAL	= %xFilial:G57%
				AND G57_AGENCI 	= %Exp:G6T->G6T_AGENCI%
				AND G57_NUMFCH = %Exp:aFichas[nITFCH]%	//AND %Exp:cWhere%
				AND G57_CONFER	= '2'
				AND G57.%NotDel%	
				
		EndSQL
		
		If (cAliasQry2)->(!Eof())
			
			While (cAliasQry2)->(!Eof())
		
				nConta++
			
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
				
				For nX:=1 To Len(aCampos)
					
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("GIC")
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := G6T->G6T_AGENCI
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := aFichas[nITFCH] 	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
						aLoad[nConta,2,nx] := cTpLanc						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
						aLoad[nConta,2,nx] := StrZero(nConta,TamSx3("G6Y_ITEM")[1])							
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_LOCORI"
						aLoad[nConta,2,nx] := (cAliasQry2)->G57_LOCORI	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NLOCOR"
						aLoad[nConta,2,nx] := Posicione('GI1', 1, xFilial('GI1') + (cAliasQry2)->G57_LOCORI, 'GI1_DESCRI')					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODG57"
						aLoad[nConta,2,nx] := (cAliasQry2)->G57_CODIGO	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
						aLoad[nConta,2,nx] := STOD((cAliasQry2)->G57_EMISSA)							
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMMOV"
						aLoad[nConta,2,nx] := (cAliasQry2)->G57_NUMMOV								
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := If((cAliasQry2)->G57_VALACE <> 0,(cAliasQry2)->G57_VALACE,(cAliasQry2)->G57_VALOR)									
					EndIf
					
				Next nX
		
				(cAliasQry2)->(dbSkip())
				
			End While
								
		EndIf
		
	EndIf
		
//EndIf
	//next nI
	
ElseIf oSubMdl:GetId() =='GRID2' .And. FwIsInCallStack("GTPA700D")
	
	nITFCH++
	cWhere := ''
	cWhere := "%"
	cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' " 
	cWhere += "%"
	
	If Select(cAliasQry4) > 0
		(cAliasQry4)->(dbCloseArea())
	Endif
	
	BeginSQL Alias cAliasQry4
	
		SELECT G6Y_FILIAL,
				G6Y_CODIGO,
				G6Y_CODAGE,
				G6Y_NUMFCH,
				G6Y_LOCORI,		
				G6Y_QTDTAX,
				G6Y_TARIFA,
				G6Y_VALOR,
				G6Y_AGRUPA
		FROM %Table:G6Y% G6Y
			WHERE G6Y_FILIAL = %xFilial:G6Y%
			%Exp:cWhere%
			AND G6Y_CODIGO = %Exp:cCodigo%
			AND G6Y_CODAGE = %Exp:cAgencia%
			AND G6Y_TPLANC = %Exp:cTpLanc%
			AND %NotDel%
		
	EndSQL
		
	If (cAliasQry4)->(!Eof())
		
		nConta := 0
		
		While (cAliasQry4)->(!Eof())
			
			nConta++
			
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
			
			For nX := 1 To Len(aCampos)
			
				If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
					aLoad[nConta,2,nx] := xFilial("G6Y")
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
					aLoad[nConta,2,nx] := G6T->G6T_CODIGO
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
					aLoad[nConta,2,nx] := G6T->G6T_AGENCI
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
					aLoad[nConta,2,nx] := aFichas[nITFCH] 
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_LOCORI"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_LOCORI
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NLOCOR"
					aLoad[nConta,2,nx] := Posicione('GI1', 1, xFilial('GI1') + (cAliasQry4)->G6Y_LOCORI, 'GI1_DESCRI')		
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_QTDTAX"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_QTDTAX
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TARIFA"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_TARIFA
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
					aLoad[nConta,2,nx] := (cAliasQry4)->G6Y_VALOR
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_AGRUPA"
					aLoad[nConta,2,nx] := IIf((cAliasQry4)->G6Y_AGRUPA == 'T', .T.,.F.)
				EndIf
			
			Next nX
			
			(cAliasQry4)->(dbSkip())	
		
		End	While
			
	Else
	
		cWhere := ''
		cWhere := "%"
		cWhere += " AND GIC_NUMFCH = '" + aFichas[nITFCH] + "' " 
		cWhere += "%"
		
		If Select(cAliasQry2) > 0
			(cAliasQry2)->(dbCloseArea())
		Endif
		
		BeginSQL Alias cAliasQry2
		
			SELECT DISTINCT(GIC_LOCORI)as LocOri,
				COUNT(GIC_CODIGO) AS QTD, 
				GIC_TAX, 
				SUM(GIC_TAX) AS VALOR 
			FROM 
				%Table:GIC% GIC
			WHERE 
				GIC_FILIAL = %xFilial:GZE%
				AND %NotDel%
				%Exp:cWhere%
				AND GIC_AGENCI = %Exp:G6T->G6T_AGENCI%
				GROUP BY GIC_TAX,GIC_LOCORI

		EndSQL
		
		If (cAliasQry2)->(!Eof())
		
			While (cAliasQry2)->(!Eof())
		
				nConta++
			
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
				
				For nX := 1 To Len(aCampos)
		
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("GIC")
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := G6T->G6T_AGENCI
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := aFichas[nITFCH] 								
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_LOCORI"
						aLoad[nConta,2,nx] := (cAliasQry2)->LOCORI	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NLOCOR"
						aLoad[nConta,2,nx] := Posicione('GI1', 1, xFilial('GI1') + (cAliasQry2)->LOCORI, 'GI1_DESCRI')						
	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_QTDTAX"
						aLoad[nConta,2,nx] := (cAliasQry2)->QTD
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TARIFA"
						aLoad[nConta,2,nx] := (cAliasQry2)->GIC_TAX
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := (cAliasQry2)->VALOR
					EndIf
				
				Next nX
		
				(cAliasQry2)->(dbSkip())
			
			End While
		
		EndIf
								
	EndIf
	
ElseIf oSubMdl:GetId() =='GRID2' .And. FwIsInCallStack("GTPA700I")
		
	cCodigo := 	G6T->G6T_CODIGO
	cAGencia := G6T->G6T_AGENCI
	
	nITFCH++

	cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' "   
	cWhere += "%"
		
	BeginSQL Alias cAliasQry2
		
		SELECT * 
		FROM %Table:G6Y% G6Y
		WHERE G6Y_FILIAL = %xFilial:G6Y%
		%Exp:cWhere%
		AND G6Y_CODIGO = %Exp:cCodigo%
		AND G6Y_CODAGE = %Exp:cAgencia%
		AND G6Y_TPLANC = %Exp:cTpLanc%
		AND %NotDel%
		  
		
	EndSQL
		
	If (cAliasQry2)->(!Eof())
	
		While (cAliasQry2)->(!Eof())
		
			nConta++
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
				
			//cFieldsIn := "G6Y_AGRUPA|G6Y_BILHET|G6Y_DATA|G6Y_VALOR|G6Y_CODNSU|G6Y_CODAUT|"
			For nx:=1 To Len(aCampos) 
				
				If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
					aLoad[nConta,2,nx] := xFilial("G6Y")
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
					aLoad[nConta,2,nx] := G6T->G6T_CODIGO

				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
					aLoad[nConta,2,nx] := G6T->G6T_AGENCI
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_NUMFCH
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
					aLoad[nConta,2,nx] := cTpLanc
				
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_ITEM
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_BILHET"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_BILHET
					
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODNSU"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODNSU
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAUT"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODAUT
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODADM"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODADM
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_VALOR
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
					aLoad[nConta,2,nx] := StoD((cAliasQry2)->G6Y_DATA)
			
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_AGRUPA"
					aLoad[nConta,2,nx] := IIf((cAliasQry2)->G6Y_AGRUPA == 'T', .T.,.F.)
				ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CHVTX"
					aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CHVTX				
		
				EndIf
		
			Next nX
			
			(cAliasQry2)->(dbSkip())
			
		End While
		
	ElseIf (cAliasQry2)->(Eof())
	
		cWhere := ""
		cWhere += "%"
		cWhere += " AND GIC_NUMFCH = '" + aFichas[nITFCH] + "' "
		cWhere += "%"
		
		BeginSQL Alias cAliasQry3
		
			SELECT  *
			FROM %Table:GIC% GIC
			JOIN %Table:GZP% GZP 
			ON GZP.%NotDel%
			AND GZP_FILIAL = %xFilial:GZP%
			AND GZP_CODBIL = GIC_BILREF
			AND GZP_TPAGTO = 'CD'
			WHERE GIC_FILIAL = %xFilial:GIC%
			%Exp:cWhere%
			AND GIC_AGENCI = %Exp:G6T->G6T_AGENCI%
			AND GIC_STATUS = 'C'
			AND GIC.%NotDel%
			
		EndSQL
				
		If (cAliasQry3)->(!Eof())
	
			While (cAliasQry3)->(!Eof())
						
				nConta++
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
					
				For nx:=1 To Len(aCampos)
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("G6Y")
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := G6T->G6T_AGENCI
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := (cAliasQry3)->GIC_NUMFCH
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
						aLoad[nConta,2,nx] := cTpLanc
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
						aLoad[nConta,2,nx] := StrZero(nConta,TamSx3("G6Y_ITEM")[1])
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_BILHET"
						aLoad[nConta,2,nx] := (cAliasQry3)->GIC_BILHET
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODNSU"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZP_NSU
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAUT"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZP_AUT
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODADM"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZP_FPAGTO
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZP_VALOR
				
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
						aLoad[nConta,2,nx] := StoD((cAliasQry3)->GIC_DTVEND)
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CHVTX"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZP_TITTEF					
				
					EndIf
	
				Next nX
			
				(cAliasQry3)->(dbSkip())
			
			End While
			
		EndIf
		
	EndIF
	
ElseIf oSubMdl:GetId() =='GRID2' .And. (FwIsInCallStack("GTPA700JA") .Or. FwIsInCallStack("GTPA700JB") .Or. FwIsInCallStack("GTPA700N")) 
	
	cCodigo := 	G6T->G6T_CODIGO
	cAGencia := G6T->G6T_AGENCI
	
	nITFCH++
	
	cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' "   
	cWhere += "%"
	
	BeginSQL Alias cAliasQry2
	
		SELECT 
			G6Y.*,
			GZC.GZC_DESCRI AS G6Y_DSCGZC
		FROM %Table:G6Y% G6Y
			INNER JOIN %Table:GZC% GZC ON
				 GZC.GZC_FILIAL = %xFilial:GZC%
				 AND GZC.GZC_CODIGO = G6Y.G6Y_CODGZC
				 AND GZC.%NotDel% 
		WHERE G6Y_FILIAL = %xFilial:G6Y%
			%Exp:cWhere%
			AND G6Y_CODIGO = %Exp:cCodigo%
			AND G6Y_CODAGE = %Exp:cAgencia%
			AND G6Y_TPLANC = %Exp:cTpLanc%
			AND G6Y.%NotDel%
	EndSQL
		
	If (cAliasQry2)->(!Eof())
	
		While (cAliasQry2)->(!Eof())
		
			nConta++
			aAdd(aLoad,{nConta,Array(Len(aCampos))})
					
				For nx:=1 To Len(aCampos) 
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("G6Y")
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := G6T->G6T_AGENCI
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_NUMFCH
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
						aLoad[nConta,2,nx] := cTpLanc
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_ITEM
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
						aLoad[nConta,2,nx] := IIf((cAliasQry2)->G6Y_CARGA == 'T', .T.,.F.)
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ACERTO"
						aLoad[nConta,2,nx] := IIf((cAliasQry2)->G6Y_ACERTO == 'T', .T.,.F.)
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODGZC"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODGZC
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DSCGZC"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_DSCGZC
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_VALOR

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := StoD((cAliasQry2)->G6Y_DATA)
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_IDDEPO" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_IDDEPO

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_BANCO" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_BANCO

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_AGEBCO" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_AGEBCO

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CTABCO" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CTABCO

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_FORPGT" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_FORPGT

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CHVTIT" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CHVTIT

					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_STSDEP"
						aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_STSDEP
					EndIf
				Next
				
				(cAliasQry2)->(dbSkip())
			End
		
	ElseIf (cAliasQry2)->(Eof())
	
		cWhere := "%"
		cWhere += " AND GZG_NUMFCH = '" + aFichas[nITFCH] + "' "

		If GZG->(FieldPos('GZG_CONFER')) > 0
			cWhere += " AND GZG_CONFER = '2' "
		Endif

		cWhere += "%"

	 	If GZG->(FieldPos('GZG_VLACER')) > 0
			cQuery := ",GZG_VLACER "
		Endif

		cQuery := '%' + cQuery + '%'

		If cTpLanc == 'A'
			cQryDep := "% GZG.GZG_COD = '029' %"
		Else
			cQryDep := "% GZG.GZG_COD <> '029' %"
		Endif

		BeginSQL Alias cAliasQry3
		
			Select 
				GZG_NUMFCH, 
				GZG_COD,
				GZC_DESCRI,
				GZG_VALOR,
				GZC_LCXREJ 
				%Exp:cQuery%
			From %Table:GZG% GZG
				INNER JOIN %Table:GZC% GZC ON
					GZC.GZC_FILIAL = %xFilial:GZC%
					AND GZC.GZC_CODIGO = GZG.GZG_COD
					AND GZC.GZC_LANCX = 'T'
					AND GZC.D_E_L_E_T_ = ' '
			WHERE 
				GZG.GZG_FILIAL = %xFilial:GZG%
				%EXP:cWhere%
				AND GZG.GZG_AGENCI = %Exp:cAgencia%
				AND GZG.GZG_TIPO = %Exp:If(cTpLanc=="8",'1','2' )%
				AND GZG.D_E_L_E_T_ = ' '
				AND %Exp:cQryDep%
			
		EndSQL
			
		If (cAliasQry3)->(!Eof())
			While (cAliasQry3)->(!Eof())
		
				nConta++
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
					
				For nx:=1 To Len(aCampos)
					If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
						aLoad[nConta,2,nx] := xFilial("G6Y")
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
						aLoad[nConta,2,nx] := G6T->G6T_CODIGO
	
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
						aLoad[nConta,2,nx] := G6T->G6T_AGENCI
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZG_NUMFCH
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
						aLoad[nConta,2,nx] := cTpLanc
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
						aLoad[nConta,2,nx] := StrZero(nConta,TamSx3('G6Y_ITEM')[1])
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
						aLoad[nConta,2,nx] := .T.
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ACERTO"
						aLoad[nConta,2,nx] := .F.
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODGZC"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZG_COD
						
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DSCGZC"
						aLoad[nConta,2,nx] := (cAliasQry3)->GZC_DESCRI
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
						aLoad[nConta,2,nx] := IIF((cAliasQry3)->GZG_VLACER > 0, (cAliasQry3)->GZG_VLACER, (cAliasQry3)->GZG_VALOR) 
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_STSDEP"

						If GZG->(FieldPos('GZG_CONFER')) > 0
							aLoad[nConta,2,nx] := If((cAliasQry3)->GZC_LCXREJ == 'T','2','1') 
						Else
							aLoad[nConta,2,nx] := If((cAliasQry3)->GZC_LCXREJ == 'T','2',' ') 
						Endif

						If cTpLanc == 'A'
							aLoad[nConta,2,nx] := ''
						Endif
					
					ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA" .And. cTpLanc == 'A'
						aLoad[nConta,2,nx] := StoD((cAliasQry3)->GZG_NUMFCH)
					EndIf	
					
				Next
				(cAliasQry3)->(dbSkip())
			End
		EndIf
		
	EndIF


ElseIf (oSubMdl:GetId() $ 'GRID2|G6YDETAIL') .And. FwIsInCallStack("GTPA700E") 
		cCodigo := 	G6T->G6T_CODIGO
		cAGencia := G6T->G6T_AGENCI
		nITFCH++
		  cWhere += " AND G6Y_NUMFCH = '" + aFichas[nITFCH] + "' "     
		cWhere += "%"
		
		BeginSQL Alias cAliasQry2
		
		SELECT * 
		FROM %Table:G6Y% G6Y
		WHERE G6Y_FILIAL = %xFilial:G6Y%
		%Exp:cWhere%
		AND G6Y_CODIGO = %Exp:cCodigo%
		AND G6Y_CODAGE = %Exp:cAgencia%
		AND G6Y_TPLANC = %Exp:cTpLanc%
		AND %NotDel%
		
		EndSQL
		
		If (cAliasQry2)->(!Eof())
			While (cAliasQry2)->(!Eof())
			
				nConta++
				
				aAdd(aLoad,{nConta,Array(Len(aCampos))})
						//cFieldsIn := "G6Y_AGRUPA|G6Y_BILHET|G6Y_DATA|G6Y_VALOR|G6Y_CODNSU|G6Y_CODAUT|"
					For nx:=1 To Len(aCampos) 
						If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
							aLoad[nConta,2,nx] := xFilial("G6Y")
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
							aLoad[nConta,2,nx] := G6T->G6T_CODIGO

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
							aLoad[nConta,2,nx] := G6T->G6T_AGENCI
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
							aLoad[nConta,2,nx] := StrZero(nConta,TamSx3("G6Y_ITEM")[1])

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
							aLoad[nConta,2,nx] := cTpLanc
		
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CARGA
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODGQM"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODGQM
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TIPPOS"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_TIPPOS
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODADM"
							aLoad[nConta,2,nx] := SUBSTR((cAliasQry2)->G6Y_CODADM,1,6)	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DESADM"
							aLoad[nConta,2,nx] := Posicione('SAE',1,xFilial('SAE') + (cAliasQry2)->G6Y_CODADM, 'AE_DESC')//Posicione('GI1', 1, xFilial('GI1') + (cAliasQry2)->LOCORI, 'GI1_DESCRI')(cAliasQry2)->G6Y_DESADM
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODNSU"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODNSU
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAUT"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_CODAUT
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ESTAB"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_ESTAB
								
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_VALOR
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
							aLoad[nConta,2,nx] := StoD((cAliasQry2)->G6Y_DATA)
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ACERTO"
							aLoad[nConta,2,nx] := IIf((cAliasQry2)->G6Y_ACERTO == 'T', .T.,.F.)
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_NUMFCH		
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPVEND"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_TPVEND				

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_IDECNT"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_IDECNT				

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_QNTPAR"
							aLoad[nConta,2,nx] := (cAliasQry2)->G6Y_QNTPAR				
				
						EndIf
					Next
					(cAliasQry2)->(dbSkip())
				End
			
		ElseIf (cAliasQry2)->(Eof())
		
			cWhere := "%"

		 	If GQM->(FieldPos('GQM_CONFER')) > 0
				cWhere += " AND GQM_CONFER = '2' "
			Endif

			cWhere += "%"

		 	If GQM->(FieldPos('GQM_VLACER')) > 0
				cQuery := " ,GQM_VLACER "
			Endif

			cQuery := '%' + cQuery + '%'			
			
		 	BeginSQL alias cAliasPOS    
	
			SELECT	GQL.GQL_CODADM,
	  				GQL.GQL_TPVEND,
				  	GQL.GQL_NUMFCH,
				  	GQL.GQL_IDECNT,
				  	GQM.GQM_CODIGO,
				  	GQM.GQM_CODNSU,
	  				GQM.GQM_CODAUT,
	  				GQM.GQM_ESTAB,
	  				GQM.GQM_DTVEND,
	  				GQM.GQM_VALOR,
	  				GQM.GQM_QNTPAR,
	  				SAE.AE_DESC
					%Exp:cQuery%  
			FROM %Table:GQL% GQL
			INNER JOIN %Table:GQM% GQM ON GQM.GQM_FILIAL = %xFilial:GQM%
				AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
			LEFT JOIN %Table:SAE% SAE ON SAE.AE_COD = GQL.GQL_CODADM
				WHERE GQL.GQL_FILIAL = %xFilial:GQL%
				AND GQL.GQL_CODAGE = %Exp:cAgencia%
				AND GQL.GQL_NUMFCH = %Exp:aFichas[nITFCH]%
				AND GQL.%NotDel%
				%Exp:cWhere%
			
			EndSQL		
			
			If (cAliasPOS)->(!Eof())
				While (cAliasPOS)->(!Eof())
			
					nConta++
					aAdd(aLoad,{nConta,Array(Len(aCampos))})
						
					For nx:=1 To Len(aCampos)
						If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
							aLoad[nConta,2,nx] := xFilial("G6Y")
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
							aLoad[nConta,2,nx] := G6T->G6T_CODIGO
		
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
							aLoad[nConta,2,nx] := G6T->G6T_AGENCI
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
							aLoad[nConta,2,nx] := StrZero(nConta,TamSx3("G6Y_ITEM")[1])
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQL_NUMFCH
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
							aLoad[nConta,2,nx] := cTpLanc
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODNSU"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQM_CODNSU
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAUT"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQM_CODAUT
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ESTAB"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQM_ESTAB	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODADM"
							aLoad[nConta,2,nx] := SUBSTR((cAliasPOS)->GQL_CODADM,1,6)
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DESADM"
							aLoad[nConta,2,nx] := (cAliasPOS)->AE_DESC

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
							aLoad[nConta,2,nx] := IIF((cAliasPOS)->GQM_VLACER > 0, (cAliasPOS)->GQM_VLACER, (cAliasPOS)->GQM_VALOR) 
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
							aLoad[nConta,2,nx] := StoD((cAliasPOS)->GQM_DTVEND)
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPVEND"
							aLoad[nConta,2,nx] := 'P'	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ACERTO"
							aLoad[nConta,2,nx] := .F.					
											
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
							aLoad[nConta,2,nx] := .F.	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_IDECNT"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQL_IDECNT	

						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_QNTPAR"
							aLoad[nConta,2,nx] := (cAliasPOS)->GQM_QNTPAR	
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TIPPOS"
						//TODO
							aLoad[nConta,2,nx] := (cAliasPOS)->GQL_TPVEND
						
						EndIf
		
					Next
					
					(cAliasPOS)->(dbSkip())
				End
			EndIf
			
			BeginSQL alias cAliasTEF    
	
			SELECT GZP_CODIGO,
				   GZP_FPAGTO,
				   GZP_DCART,
				   GZP_TPAGTO,
				   GZP_NSU,
				   GZP_AUT,
				   GZP_ESTAB,
				   GZP_VALOR,
				   GZP_QNTPAR,
				   GIC_DTVEND,
				   GIC_NUMFCH,
				   SAE.AE_DESC
			FROM %Table:GZP% GZP

			INNER JOIN %Table:GIC% GIC ON GIC.GIC_FILIAL = %xFilial:GIC%
				AND GIC.GIC_CODIGO = GZP_CODIGO
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND GIC.GIC_NUMFCH = %Exp:aFichas[nITFCH]%
				AND GIC.%NotDel%
			LEFT JOIN %Table:SAE% SAE ON SAE.AE_COD = GZP.GZP_FPAGTO
		
			Where GZP.GZP_FILIAL = %xFilial:GZP%
			AND GZP.%NotDel%
			ORDER BY GZP_CODIGO	

			EndSQL	
			
			If (cAliasTEF)->(!Eof())
				While (cAliasTEF)->(!Eof())
			
					nConta++
					aAdd(aLoad,{nConta,Array(Len(aCampos))})
						
					For nx:=1 To Len(aCampos)
						If AllTrim(aCampos[nx,3]) == "G6Y_FILIAL"
							aLoad[nConta,2,nx] := xFilial("G6Y")
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODIGO"
							aLoad[nConta,2,nx] := G6T->G6T_CODIGO
		
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAGE"
							aLoad[nConta,2,nx] := G6T->G6T_AGENCI
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ITEM"
							aLoad[nConta,2,nx] := StrZero(nConta,TamSx3("G6Y_ITEM")[1])
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_NUMFCH"
							aLoad[nConta,2,nx] := (cAliasTEF)->GIC_NUMFCH
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPLANC"
							aLoad[nConta,2,nx] := cTpLanc
						
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODNSU"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_NSU
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODAUT"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_AUT
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ESTAB"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_ESTAB
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CODADM"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_FPAGTO
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DESADM"
							aLoad[nConta,2,nx] := (cAliasTEF)->AE_DESC
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_VALOR"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_VALOR
					
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_DATA"
							aLoad[nConta,2,nx] := StoD((cAliasTEF)->GIC_DTVEND)
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TPVEND"
							aLoad[nConta,2,nx] := 'T'	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_ACERTO"
							aLoad[nConta,2,nx] := .F.					
											
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_CARGA"
							aLoad[nConta,2,nx] := .F.	
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_QNTPAR"
							aLoad[nConta,2,nx] := (cAliasTEF)->GZP_QNTPAR
							
						ElseIf AllTrim(aCampos[nx,3]) == "G6Y_TIPPOS"
						//TODO
							aLoad[nConta,2,nx] := IIF((cAliasTEF)->GZP_TPAGTO = "CR","2","1")
											
						EndIf
		
					Next
					
					(cAliasTEF)->(dbSkip())
				End
			EndIf
			
	EndIF

Endif

If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
Endif

If Select(cAliasQry2) > 0
	(cAliasQry2)->(dbCloseArea())
Endif

If Select(cAliasQry3) > 0
	(cAliasQry3)->(dbCloseArea())
Endif

If Select(cAliasQry4) > 0
	(cAliasQry4)->(dbCloseArea())
Endif

If Select(cAliasPOS) > 0
	(cAliasPOS)->(dbCloseArea())
Endif

If Select(cAliasTEF) > 0
	(cAliasTEF)->(dbCloseArea())
Endif

Return(aLoad)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G700BTrig()

Gatilho Nome Agência
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function G700BTrig()
Local cAgencia   := G6T->G6T_AGENCI
Local cReturn    := ""
Local cAliasTemp := GetNextAlias()


		BeginSQL Alias cAliasTemp
			
			SELECT  GI6_DESCRI
			FROM %Table:GI6% GI6
			WHERE GI6_FILIAL = %xFilial:GI6%
			AND GI6_CODIGO = %Exp:cAgencia%
			AND %NotDel%
				
		EndSQL	 
		
		If  (cAliasTemp)->(!Eof())
			cReturn := AllTrim((cAliasTemp)->GI6_DESCRI)
		EndIf
		
		(cAliasTemp)->(dbCloseArea())
		

		
Return cReturn

/*/{Protheus.doc} G700BCommit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 03/11/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G700BCommit(oModel,cTpLanc)

Local lRet 		:= .T.
Local oMdlFCH 	:= oModel:GetModel("GRID1")
Local oMdlG6Y	:= oModel:GetModel("GRID2")
Local oModelGRV	:= FWLOADModel('GTPA700X')
Local oMdlMstr	:= oModelGRV:GetModel("MASTER")
Local oMdlGRV	:= oModelGRV:GetModel("G6YDETAIL")
Local cAliasG6X := GetNextAlias()
Local nX		:= 0
Local nY		:= 0
Local nCount	:= 0
Local lGrv		:= .F.
Local aFilterG6Y:= {}
Local cTpLanc	:= GetTpLanc()
 		
If oModel:VldData()
 	Begin Transaction
	 G6Y->(DBSETORDER( 1 ))
 		If G6Y->( DbSeek(PADR(xFilial("G6Y"),TAMSX3("G6Y_FILIAL")[1])+ PADR(G6T->G6T_CODIGO,TAMSX3("G6Y_CODIGO")[1])  + PADR(cTpLanc,TAMSX3("G6Y_TPLANC")[1]) ) )
 		
			 BeginSQL Alias cAliasG6X
			
				SELECT  G6X_NUMFCH
				FROM %Table:G6X% G6X
				WHERE G6X_FILIAL = %xFilial:G6X%
				AND G6X_STATUS IN ('3','4')
				AND G6X_CODCX  = %Exp:G6T->G6T_CODIGO%
				AND G6X_FLAGCX = 'T'
				AND G6X_FECHCX = 'F'
				AND %NotDel%
					
			EndSQL
 			
 			While (cAliasG6X)->(!Eof())

		 		If oModelGRV:IsActive() 
		 			oModelGRV:DeActivate()
		 		EndIf

				oModelGRV:SetOperation(MODEL_OPERATION_DELETE)
				aAdd(aFilterG6Y,{ 'G6Y_CODIGO', "'"+PADR(G6T->G6T_CODIGO,TAMSX3("G6Y_CODIGO")[1])+"'" })
				aAdd(aFilterG6Y,{ 'G6Y_TPLANC', "'"+PADR(cTpLanc,TAMSX3("G6Y_TPLANC")[1])+"'" })
				//aAdd(aFilterG6Y,{ 'G6Y_NUMFCH', "'"+PADR((cAliasG6X)->G6X_NUMFCH,TAMSX3("G6Y_NUMFCH")[1])+"'" })
				oMdlGRV	:= oModelGRV:GetModel("G6YDETAIL")
				oMdlGRV:SetLoadFilter(aFilterG6Y )
				oModelGRV:Activate()
				G6Y->(DbSetOrder(1))
			    
				if oModelGRV:IsActive() 
			 		If oModelGRV:VldData()
			 			lRet :=  oModelGRV:CommitData()
			 		Else
			 			JurShowErro( oModelGRV:GetErrorMessage() )
			 			DisarmTransaction()
			 			lRet := .F.
			 		EndIf
			 	EndIf

			 	(cAliasG6X)->(DbSkip())
			End 

		 	If Select(cAliasG6X) > 0
				(cAliasG6X)->(dbCloseArea())
			Endif

		EndIf   
		    
		If lRet
			oModelGRV:DeActivate()
			oModelGRV:SetOperation(MODEL_OPERATION_INSERT)
			oModelGRV:Activate()
			oMdlGRV	:= oModelGRV:GetModel("G6YDETAIL")
			oMdlMstr := oModelGRV:GetModel("MASTER")
			lRet := oMdlMstr:SetValue( "CODIGO"	, oMdlFCH:GetValue("CODCX") ) 
			For nY := 1 To oMdlFCH:Length()
				lRet	:= .T.
				nCount := 0
				oMdlFCH:GoLine( nY )
				oMdlG6Y:SeekLine({ {'G6Y_CODIGO', oMdlFCH:GetValue("CODCX")},{"G6Y_CODAGE",oMdlFCH:GetValue("CODAGE")},;
								{'G6Y_NUMFCH', oMdlFCH:GetValue("FICHA")},{'G6Y_TPLANC', cTpLanc}})
				For nX := 1 To oMdlG6Y:Length()
					lRet	:= .T.
					oMdlG6Y:GoLine( nX )
					
					If !oMdlG6Y:IsDeleted() .and. !oMdlG6Y:IsEmpty()
						If !oMdlGRV:IsEmpty()
							lRet := oMdlGRV:Length() < oMdlGRV:AddLine()
						endif
						nCount++
						lGrv	:= .T.
						lRet := oMdlGRV:SetValue( "G6Y_FILIAL"	, xFilial('G6Y')) .And.;
								oMdlGRV:SetValue( "G6Y_CODIGO"	, oMdlFCH:GetValue("CODCX") ) .And.;
								OMdlGRV:SetValue( "G6Y_CODAGE"	, oMdlFCH:GetValue("CODAGE"))  .And.;	
								oMdlGRV:SetValue( "G6Y_ITEM"	, STRZERO(nCount, TamSx3("G6Y_ITEM")[1] ) ) .And.;	
								oMdlGRV:SetValue( "G6Y_TPLANC"	, cTpLanc )  								 
						If lRet		
							If cTpLanc == '1'
								lRet := oMdlGRV:SetValue( "G6Y_NOTA"	, oMdlG6Y:GetValue("G6Y_NOTA") ) .And.;	
								oMdlGRV:SetValue( "G6Y_SERIE"	, oMdlG6Y:GetValue("G6Y_SERIE") ) .And.;	
								oMdlGRV:SetValue( "G6Y_FORNEC"	, oMdlG6Y:GetValue("G6Y_FORNEC") ) .And.;	
								oMdlGRV:SetValue( "G6Y_LOJA"	, oMdlG6Y:GetValue("G6Y_LOJA") ) .And.;
								oMdlGRV:SetValue( "G6Y_DATA"	, oMdlG6Y:GetValue("G6Y_DATA") ) .And.;
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) .And.;
								oMdlGRV:SetValue( "G6Y_TIPOL"	, oMdlG6Y:GetValue("G6Y_TIPOL") ) .And.;
								oMdlGRV:SetValue( "G6Y_TPLACX"	, oMdlG6Y:GetValue("G6Y_TPLACX") ) .And.;
								oMdlGRV:SetValue( "G6Y_NATURE"	, oMdlG6Y:GetValue("G6Y_NATURE") ) .And.;
								oMdlGRV:SetValue( "G6Y_CC"		, oMdlG6Y:GetValue("G6Y_CC") ) .And.;
								oMdlGRV:SetValue( "G6Y_CONTA"	, oMdlG6Y:GetValue("G6Y_CONTA") ) .And.;
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") )
								 
							Endif
							
							If cTpLanc == '2' //.And. nY == 1   
								lRet := oMdlGRV:SetValue( "G6Y_IDDEPO"	, oMdlG6Y:GetValue("G6Y_IDDEPO") ) .And.;	
								oMdlGRV:SetValue( "G6Y_BANCO"	, oMdlG6Y:GetValue("G6Y_BANCO") ) .And.;	
								oMdlGRV:SetValue( "G6Y_AGEBCO"	, oMdlG6Y:GetValue("G6Y_AGEBCO") ) .And.;	
								oMdlGRV:SetValue( "G6Y_CTABCO"	, oMdlG6Y:GetValue("G6Y_CTABCO") ) .And.;
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") ) .And.;
								oMdlGRV:SetValue( "G6Y_DATA"	, oMdlG6Y:GetValue("G6Y_DATA") ) .And.;
								oMdlGRV:SetValue( "G6Y_FORPGT"	, oMdlG6Y:GetValue("G6Y_FORPGT") ) .And.;
								oMdlGRV:SetValue( "G6Y_STSDEP"	, oMdlG6Y:GetValue("G6Y_STSDEP") ) .And.;
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlG6Y:GetValue("G6Y_NUMFCH") ) .And.;
								oMdlGRV:SetValue( "G6Y_CHVTIT"	, oMdlG6Y:GetValue("G6Y_CHVTIT") ) .And.;
								oMdlGRV:SetValue( "G6Y_CARGA"	,  gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L') ) 


							EndIf
							
							If cTpLanc == '3' // Taxa Avulsa
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") ) 
								oMdlGRV:SetValue( "G6Y_ITEM"	, oMdlG6Y:GetValue("G6Y_ITEM") ) 
								oMdlGRV:SetValue( "G6Y_CODG57"	, oMdlG6Y:GetValue("G6Y_CODG57") ) 
								oMdlGRV:SetValue( "G6Y_NUMMOV"	, oMdlG6Y:GetValue("G6Y_NUMMOV") ) 
								oMdlGRV:SetValue( "G6Y_DATA"	, oMdlG6Y:GetValue("G6Y_DATA") ) 
								oMdlGRV:SetValue( "G6Y_CARGA"	, gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L') ) 
								oMdlGRV:SetValue( "G6Y_MOTLAN"	, oMdlG6Y:GetValue("G6Y_MOTLAN") ) 
								oMdlGRV:SetValue( "G6Y_LOCORI"	, oMdlG6Y:GetValue("G6Y_LOCORI") ) 
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) 
								oMdlGRV:SetValue( "G6Y_ACERTO"	, !gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L') ) 
							Endif
																
							If cTpLanc == '4' // Taxa Avulsa
								oMdlGRV:SetValue( "G6Y_AGRUPA"	, oMdlG6Y:GetValue("G6Y_AGRUPA") ) 
								oMdlGRV:SetValue( "G6Y_LOCORI"	, oMdlG6Y:GetValue("G6Y_LOCORI") )
								oMdlGRV:SetValue( "G6Y_QTDTAX"	, oMdlG6Y:GetValue("G6Y_QTDTAX") ) 
								oMdlGRV:SetValue( "G6Y_TARIFA"	, oMdlG6Y:GetValue("G6Y_CODG57") ) 
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") ) 
								oMdlGRV:SetValue( "G6Y_CHVTX"	, GETchvtX(oMdlFCH:GetValue("CODCX"),oMdlFCH:GetValue("CODAGE"),oMdlFCH:GetValue("FICHA"),oMdlG6Y:GetValue("G6Y_LOCORI")) )
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) 
							Endif

							If cTpLanc == '6' // Vendas POS
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") ) 
								oMdlGRV:SetValue( "G6Y_ITEM"	, oMdlG6Y:GetValue("G6Y_ITEM") ) 
								oMdlGRV:SetValue( "G6Y_CODADM"	, SubStr(oMdlG6Y:GetValue("G6Y_CODADM"),1,6) ) 
								oMdlGRV:SetValue( "G6Y_CODNSU"	, oMdlG6Y:GetValue("G6Y_CODNSU") ) 
								oMdlGRV:SetValue( "G6Y_CODAUT"	, oMdlG6Y:GetValue("G6Y_CODAUT") ) 
								oMdlGRV:SetValue( "G6Y_ESTAB"	, oMdlG6Y:GetValue("G6Y_ESTAB") )
								oMdlGRV:SetValue( "G6Y_TIPPOS"	, oMdlG6Y:GetValue("G6Y_TIPPOS") ) 
								oMdlGRV:SetValue( "G6Y_CODGQM"	, oMdlG6Y:GetValue("G6Y_CODGQM") ) 
								oMdlGRV:SetValue( "G6Y_DATA"	, oMdlG6Y:GetValue("G6Y_DATA") ) 
								oMdlGRV:SetValue( "G6Y_CARGA"	, gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L')) 
								oMdlGRV:SetValue( "G6Y_MOTLAN"	, oMdlG6Y:GetValue("G6Y_MOTLAN") ) 
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) 
								oMdlGRV:SetValue( "G6Y_ACERTO"	, !gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L') ) 
								oMdlGRV:SetValue( "G6Y_TPVEND"	, oMdlG6Y:GetValue("G6Y_TPVEND") )
								oMdlGRV:SetValue( "G6Y_QNTPAR"	, cValToChar(oMdlG6Y:GetValue("G6Y_QNTPAR")) )  
							Endif
							
							If cTpLanc == '7' // Bilhetes cancelados pagos com Cartão
								oMdlGRV:SetValue( "G6Y_AGRUPA"	, oMdlG6Y:GetValue("G6Y_AGRUPA") ) 
								oMdlGRV:SetValue( "G6Y_BILHET"	, oMdlG6Y:GetValue("G6Y_BILHET") )
								oMdlGRV:SetValue( "G6Y_CODAUT"	, oMdlG6Y:GetValue("G6Y_CODAUT") ) 
								oMdlGRV:SetValue( "G6Y_CODNSU"	, oMdlG6Y:GetValue("G6Y_CODNSU") ) 
								oMdlGRV:SetValue( "G6Y_CODADM"	, oMdlG6Y:GetValue("G6Y_CODADM") )
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") ) 
								oMdlGRV:SetValue( "G6Y_CHVTX"	, oMdlG6Y:GetValue("G6Y_CHVTX"))
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) 
								oMdlGRV:SetValue( "G6Y_DATA"	, oMdlG6Y:GetValue("G6Y_DATA") )
							Endif
														
							If cTpLanc == '8' .Or. cTpLanc == '9' .Or. cTpLanc == 'A' // RECEITA OU DESPESA
								oMdlGRV:SetValue( "G6Y_NUMFCH"	, oMdlFCH:GetValue("FICHA") ) 
								oMdlGRV:SetValue( "G6Y_CODGZC"	, oMdlG6Y:GetValue("G6Y_CODGZC") ) 
								oMdlGRV:SetValue( "G6Y_VALOR"	, oMdlG6Y:GetValue("G6Y_VALOR") )
								oMdlGRV:SetValue( "G6Y_CARGA"	, gtpcasttype(oMdlG6Y:GetValue("G6Y_CARGA"),'L') ) 
								oMdlGRV:SetValue( "G6Y_ACERTO"	, oMdlG6Y:GetValue("G6Y_ACERTO") ) 
								oMdlGRV:SetValue( "G6Y_STSDEP"	, oMdlG6Y:GetValue("G6Y_STSDEP") )

								If oMdlG6Y:GetValue("G6Y_CODGZC") == '029'
									oMdlGRV:LoadValue("G6Y_TPLANC", 'A')
									oMdlGRV:SetValue("G6Y_DATA", oMdlG6Y:GetValue("G6Y_DATA"))
									oMdlGRV:SetValue("G6Y_IDDEPO", oMdlG6Y:GetValue("G6Y_IDDEPO"))
									oMdlGRV:SetValue("G6Y_BANCO", oMdlG6Y:GetValue("G6Y_BANCO"))
									oMdlGRV:SetValue("G6Y_AGEBCO", oMdlG6Y:GetValue("G6Y_AGEBCO"))
									oMdlGRV:SetValue("G6Y_CTABCO", oMdlG6Y:GetValue("G6Y_CTABCO"))
									oMdlGRV:SetValue("G6Y_FORPGT", oMdlG6Y:GetValue("G6Y_FORPGT"))
								Endif
								
							Endif
						Endif			
					Endif
					If ( !lRet )
						Exit
					EndIf
				
				next nX
			Next nY
			
						
		Endif
		
		If lRet
			If lGrv
				lRet := oModelGRV:VldData() .And. oModelGRV:CommitData()
			Endif
			If !lRet
				JurShowErro( oModelGRV:GetErrorMessage() )
				DisarmTransaction()
				lRet := .F.			
			Endif
		
		Else
			JurShowErro( oModelGRV:GetErrorMessage() )
			DisarmTransaction()
			lRet := .F.
		EnDIf
		
		
		
	End Transaction
	
Endif	
	
If Valtype(oModelGRV) = "O"
	oModelGRV:DeActivate()
	oModelGRV:Destroy()
	oModelGRV:= nil
EndIf	

Return(lRet)

/*/{Protheus.doc} GetTpLanc   
    Retorna o Tipo de Lançamento.
    
    1=NF de Entrada;
    2=Depositos;
    3=Taxa de Embarque Avulsas;
    4=Taxa de Embarque;
    5=Documentos Controlados;
    6=Lancamento Diario          
    
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 03/11/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function GetTpLanc()
Local cTpLanc	:= ' '

If FwIsInCallStack("GTPA700A")
	cTpLanc := '1'
ElseIf FwIsInCallStack("GTPA700B")
	cTpLanc := '2'
ElseIf FwIsInCallStack("GTPA700C")
	cTpLanc := '3'
ElseIf FwIsInCallStack("GTPA700D")
	cTpLanc := '4'
ElseIf FwIsInCallStack("GTPA700E")
	cTpLanc := '6'
ElseIf FwIsInCallStack("GTPA700I")
	cTpLanc := '7'
ElseIf FwIsInCallStack("GTPA700JA")
	cTpLanc := '8'
ElseIf FwIsInCallStack("GTPA700JB")
	cTpLanc := '9'
ElseIf FwIsInCallStack("GTPA700N")
	cTpLanc := 'A'
Endif

Return cTpLanc

/*/{Protheus.doc} GA700BPreLn(oGrid, nLine, cAction, cField)   
    Executa o bloco de pré-validaçao da grid
    @type  Static Function
    @author Flavio Martins
    @since 09/11/2017
    @version version
    @param oGrid, nLine, cAction, cField
    @return  lógico, .T.  
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA700BPreLn(oGrid, nLine, cAction, cField)
Local oModel  := oGrid:GetModel()
Local oGrid2  := oModel:GetModel("GRID2")
Local lRet		:= .T.

	If FwIsInCallStack("GTPA700C") 

		If (cAction == "DELETE") .And. gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L')
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0020, "")  // "Lançamento não pode ser excluído"                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			lRet :=  .F.
	
		Endif
		
		If (cAction == "CANSETVALUE") .And. cField $  "G6Y_VALOR|G6Y_MOTLAN" .And. !Empty(oGrid2:GetValue('G6Y_CARGA', nLine))
			lRet :=  .F.
	
		Endif
		
	ElseIf	FwIsInCallStack("GTPA700B")
		
		If (cAction == "DELETE") .And. gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L')

			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0020, "")  // "Lançamento não pode ser excluído"                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			lRet :=  .F.
		
		Endif
		
		If (cAction == "CANSETVALUE") 
			lRet := (!gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L'))  .Or. (cField $ "G6Y_STSDEP|G6Y_IDDEPO|G6Y_BANCO|G6Y_AGEBCO|G6Y_CTABCO")
		EndIf
		
	ElseIf FwIsInCallStack("GTPA700E")
	
		If (cAction == "DELETE") .And. gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L')
										
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0020, "")  // "Lançamento não pode ser excluído"                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			lRet :=  .F.
	
		Endif
		
		If (cAction == "CANSETVALUE") .And. cField $  "G6Y_VALOR" .And. !Empty(oGrid2:GetValue('G6Y_CARGA', nLine))
			lRet :=  .F.
	
		Endif
	ElseIf FwIsInCallStack("GTPA700A")
		If (cAction == "CANSETVALUE") .And. cField $  "G6Y_VALOR|G6Y_DATA" .And. oGrid2:GetValue('G6Y_TIPOL', nLine)== '1'
			lRet :=  .F.
	
		Endif
	ElseIf FwIsInCallStack("GTPA700JA") .Or. FwIsInCallStack("GTPA700JB") .or. FwIsInCallStack("GTPA700N") 
		If (cAction == "DELETE") .And. gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L')
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0020, "")  // "Lançamento não pode ser excluído"                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			lRet :=  .F.
		Endif
		If (cAction == "CANSETVALUE") .And. cField  == "G6Y_CODGZC" .And. gtpcasttype(oGrid2:GetValue('G6Y_CARGA', nLine),'L')
			lRet :=  .F.
		Endif
		
	Endif 
	
Return lRet

/*/{Protheus.doc} GA700BPosLn(oGrid)  
    Executa o bloco de pós-validaçao da grid
    @type  Static Function
    @author Flavio Martins
    @since 09/11/2017
    @version version
    @param oGrid
    @return  lógico, .T.  
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA700BPosLn(oGrid)
Local oModel  := oGrid:GetModel()
Local oGrid2  := oModel:GetModel("GRID2")
Local lRet		:= .T.

	If FwIsInCallStack("GTPA700A") .And. oGrid2:GetValue('G6Y_TIPOL') == '1' 

		SF1->(dbSetOrder(1))
				
		If !(SF1->(dbSeek(xFilial('SF1')+oGrid2:GetValue('G6Y_NOTA')+;
					oGrid2:GetValue('G6Y_SERIE')+;
					oGrid2:GetValue('G6Y_FORNEC')+;
					oGrid2:GetValue('G6Y_LOJA'))))
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700A', STR0039, "") // "Documentado de entrada inválido"
			lRet :=  .F.
		Endif

	Endif 

	If FwIsInCallStack("GTPA700C") .Or. FwIsInCallStack("GTPA700E") 

		If oGrid2:GetValue('G6Y_VALOR') == 0

			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0021, "") // "Valor do lançamento deve ser diferente de zero"
			lRet :=  .F.
	
		Endif
		
		If !gtpcasttype(oGrid2:GetValue('G6Y_CARGA'),'L') .And. Empty(oGrid2:GetValue('G6Y_MOTLAN'))
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0022, "")  // "Motivo do acerto precisa ser informado"                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			lRet :=  .F.
	
		Endif
		 
	Endif 
	
Return lRet

/*/{Protheus.doc} GA700BLoad(oModel)  
    Executa a carga de dados da tabela G6Y
    @type  Static Function
    @author Flavio Martins
    @since 09/11/2017
    @version version
    @param oModel
    @return  Nil  
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA700BLoad(oModel)
Local cAliasG57	:= GetNextAlias()
Local cAliasPOS	:= GetNextAlias()
Local cAliasTEF	:= GetNextAlias()
Local cAliasG6X	:= GetNextAlias()
Local oMdlCab   := oModel:GetModel('CABESC')
Local oGrid1	:= oModel:GetModel('GRID1')
Local oGrid2	:= oModel:GetModel('GRID2')
Local cAgencia	:= oMdlCab:GetValue('AGENCIA')
Local cFicha 	:= oGrid1:GetValue('FICHA')
Local lConfere	:= .T.
Local lCarga	:= .T.
Local cTpLanc	:= ""
Local nX		:= 0
Local nY		:= 0
Local aFichasCx	:= {}

	BeginSql Alias cAliasG6X
		
		SELECT  G6X_FILIAL,G6X_NUMFCH,G6X_DTINI,G6X_DTFIN
		FROM %Table:G6X% G6X
		WHERE G6X_FILIAL = %xFilial:G6X%
		AND G6X_STATUS IN ('3','4')
		AND G6X_CODCX  = %Exp:G6T->G6T_CODIGO%
		AND G6X_FLAGCX = 'T'
		AND %NotDel%		
			
	EndSql
	
	While (cAliasG6X)->(!Eof())
	
		Aadd(aFichasCx, (cAliasG6X)->G6X_NUMFCH)
	
		(cAliasG6X)->(dbSkip())
	
	EndDo

	(cAliasG6X)->(dbCloseArea())

	If FwIsInCallStack("GTPA700C")
	
		cTpLanc := "3"
 	
	 	For nX := 1 To Len(aFichasCx)
	 	
	 		cFicha := aFichasCx[nX] // oGrid1:GetValue('FICHA', nX)
	 	
		 	BeginSQL alias cAliasG57    
	
				SELECT G57_CODIGO,
						G57_NUMMOV,
						G57_AGENCI,
						G57_VALOR,
						G57_VALACE,
						G57_NUMFCH,
						G57_EMISSA,
						G57_LOCORI
				FROM %Table:G57% G57	
				WHERE G57_FILIAL	= %xFilial:G57%
				AND G57_AGENCI 	= %Exp:cAgencia%
				AND G57_NUMFCH	= %Exp:cFicha%
				AND G57_CONFER	= %Exp:lConfere%
				AND G57.%NotDel%		

			EndSQL		
	
			ProcRegua((cAliasG57)->(ScopeCount()))
	
			(cAliasG57)->(dbGoTop())
	
			While !(cAliasG57)->(Eof())	
		
				IncProc(STR0029) // "Carregando..."
			
				If !oGrid2:SeekLine({ {"G6Y_CODG57",(cAliasG57)->G57_CODIGO}, {"G6Y_NUMMOV",(cAliasG57)->G57_NUMMOV}})
		
					If !Empty(oGrid2:GetValue('G6Y_CARGA'))
						oGrid2:AddLine()
					Endif
		
					oGrid2:LoadValue('G6Y_CARGA', lCarga)
					oGrid2:LoadValue('G6Y_CODG57', (cAliasG57)->G57_CODIGO)
					oGrid2:LoadValue('G6Y_NUMMOV', (cAliasG57)->G57_NUMMOV)
					oGrid2:LoadValue('G6Y_NUMFCH', (cAliasG57)->G57_NUMFCH)
					oGrid2:LoadValue('G6Y_TPLANC', cTpLanc)
					oGrid2:LoadValue('G6Y_DATA', StoD((cAliasG57)->G57_EMISSA,'G57_EMISSA'))
					oGrid2:LoadValue('G6Y_LOCORI', (cAliasG57)->G57_LOCORI)
					oGrid2:LoadValue('G6Y_NLOCOR', Posicione("GI1",1,XFILIAL("GI1")+(cAliasG57)->G57_LOCORI,"GI1_DESCRI"))
					oGrid2:LoadValue('G6Y_ACERTO', .F.)
				
					If (cAliasG57)->G57_VALACE <> 0		
						oGrid2:SetValue('G6Y_VALOR', (cAliasG57)->G57_VALACE)
					Else
						oGrid2:SetValue('G6Y_VALOR', (cAliasG57)->G57_VALOR)
					Endif
			
				Endif 
	
				(cAliasG57)->(dbSkip())	
			
			EndDo
	
			(cAliasG57)->(dbCloseArea())
			
			If oGrid2:GetValue('G6Y_VALOR') == 0 .And. oModel:GetOperation() <> MODEL_OPERATION_VIEW
				oGrid2:DeleteLine()
			Endif
			
			oGrid1:GoLine(1)
			oGrid2:GoLine(1)
			
		Next	
	
	ElseIf FwIsInCallStack("GTPA700E")
	
		cTpLanc := "6"

	 	For nX := 1 To Len(aFichasCx) // oGrid1:Length()
	 	
	 		cFicha := aFichasCx[nX] //oGrid1:GetValue('FICHA', nX)
	 	
			BeginSQL alias cAliasPOS    
	
				SELECT	GQL.GQL_CODADM,
						GQL.GQL_TPVEND,
						GQL.GQL_IDECNT,
						GQM.GQM_QNTPAR,
						GQL.GQL_NUMFCH,
						GQM.GQM_CODIGO,
						GQM.GQM_CODNSU,
						GQM.GQM_CODAUT,
						GQM.GQM_DTVEND,
						GQM.GQM_VALOR
				FROM %Table:GQL% GQL
				INNER JOIN %Table:GQM% GQM ON GQM.GQM_FILIAL = %xFilial:GQM%
					AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
				WHERE GQL.GQL_FILIAL = %xFilial:GQL%
					AND GQL.GQL_CODAGE = %Exp:cAgencia%
					AND GQL.GQL_NUMFCH = %Exp:cFicha%
					AND GQL.%NotDel%
			
			EndSQL		
			//VENDA TEF
			BeginSQL alias cAliasTEF    
	
			SELECT GZP_CODIGO,
				   GZP_FPAGTO,
				   GZP_DCART,
				   GZP_TPAGTO,
				   GZP_NSU,
				   GZP_AUT,
				   GZP_VALOR,
				   GZP_QNTPAR,
				   GIC_DTVEND,
				   GIC_NUMFCH
			FROM %Table:GZP% GZP
			INNER JOIN %Table:GIC% GIC ON GIC.GIC_FILIAL = %xFilial:GIC%
				AND GIC.GIC_CODIGO = GZP_CODIGO
				AND GIC.GIC_AGENCI = %Exp:cAgencia%
				AND GIC.GIC_NUMFCH = %Exp:cFicha%
				AND GIC.%NotDel%
			
			Where GZP.GZP_FILIAL = %xFilial:GZP%
			AND GZP.%NotDel%
			ORDER BY GZP_CODIGO	

			EndSQL	
	
			ProcRegua((cAliasPOS)->(ScopeCount()) + (cAliasTEF)->(ScopeCount()))
	
			(cAliasPOS)->(dbGoTop())
			
			While !(cAliasPOS)->(Eof())	
		
				IncProc(STR0029) // "Carregando..."
			
			//	If !oGrid2:SeekLine({ {"G6Y_CODGQM",(cAliasPOS)->GQM_CODIGO}})
		
					If !Empty(oGrid2:GetValue('G6Y_CARGA'))
						oGrid2:AddLine()
					Endif 
		
					oGrid2:LoadValue('G6Y_TPLANC', cTpLanc)
					oGrid2:LoadValue('G6Y_CARGA', lCarga)
					oGrid2:LoadValue('G6Y_CODGQM', (cAliasPOS)->GQM_CODIGO)
					oGrid2:LoadValue('G6Y_TIPPOS', (cAliasPOS)->GQL_TPVEND)
					oGrid2:LoadValue('G6Y_CODADM', (cAliasPOS)->GQL_CODADM)
					oGrid2:LoadValue('G6Y_DESADM', Posicione("SAE",1,XFILIAL("SAE")+(cAliasPOS)->GQL_CODADM,"AE_DESC"))
					oGrid2:LoadValue('G6Y_CODNSU', (cAliasPOS)->GQM_CODNSU)
					oGrid2:LoadValue('G6Y_CODAUT', (cAliasPOS)->GQM_CODAUT)
					oGrid2:LoadValue('G6Y_DATA', StoD((cAliasPOS)->GQM_DTVEND,'GQM_DTVEND'))
					oGrid2:LoadValue('G6Y_ACERTO', .F.)
					oGrid2:LoadValue('G6Y_NUMFCH', (cAliasPOS)->GQL_NUMFCH)
					oGrid2:SetValue('G6Y_VALOR', (cAliasPOS)->GQM_VALOR)
					oGrid2:SetValue('G6Y_TPVEND', "P")
			
			//	Endif 
	
				(cAliasPOS)->(dbSkip())
				
				If !(cAliasPOS)->(Eof())
				EndIf	
			
			EndDo
	
			(cAliasTEF)->(dbGoTop())
			
			While !(cAliasTEF)->(Eof())	
		
				IncProc(STR0029) // "Carregando..."
			
			//	If !oGrid2:SeekLine({ {"G6Y_CODGQM",(cAliasTEF)->GZP_CODIGO}})
		
					If !Empty(oGrid2:GetValue('G6Y_CARGA'))
						oGrid2:AddLine()
					Endif
		
					oGrid2:LoadValue('G6Y_TPLANC', cTpLanc)
					oGrid2:LoadValue('G6Y_CARGA', lCarga)
					oGrid2:LoadValue('G6Y_CODGQM', (cAliasTEF)->GZP_CODIGO)
					oGrid2:LoadValue('G6Y_TIPPOS', IIF((cAliasTEF)->GZP_TPAGTO = "CR","2","1"))
					oGrid2:LoadValue('G6Y_CODADM', AllTrim((cAliasTEF)->GZP_FPAGTO))
					oGrid2:LoadValue('G6Y_DESADM', Posicione("SAE",1,XFILIAL("SAE")+(cAliasTEF)->GZP_FPAGTO,"AE_DESC"))
					oGrid2:LoadValue('G6Y_CODNSU', AllTrim((cAliasTEF)->GZP_NSU))
					oGrid2:LoadValue('G6Y_CODAUT', AllTrim((cAliasTEF)->GZP_AUT))
					oGrid2:LoadValue('G6Y_DATA', StoD((cAliasTEF)->GIC_DTVEND,'GQM_DTVEND'))
					oGrid2:LoadValue('G6Y_ACERTO', .F.)
					oGrid2:LoadValue('G6Y_NUMFCH', (cAliasTEF)->GIC_NUMFCH)
					oGrid2:SetValue('G6Y_VALOR', (cAliasTEF)->GZP_VALOR)
					oGrid2:SetValue('G6Y_TPVEND', "T")
					
		//		Endif 
	
				(cAliasTEF)->(dbSkip())	
				
			EndDo
			
			(cAliasPOS)->(dbCloseArea())
			(cAliasTEF)->(dbCloseArea())
			
			If oGrid2:GetValue('G6Y_VALOR') == 0 .And. oModel:GetOperation() <> MODEL_OPERATION_VIEW
				oGrid2:DeleteLine()
			Endif
			
			oGrid1:GoLine(1)
			oGrid2:GoLine(1)
			
		Next	
	ElseIf FwIsInCallStack("GTPA700JA") .Or. FwIsInCallStack("GTPA700JB") .Or. FwIsInCallStack("GTPA700N")
		For nX := 1 To oGrid1:Length()
			oGrid1:GoLine(nX)
			For nY	:= 1 To oGrid2:Length()
				oGrid2:GoLine(nY)
				If Empty(oGrid2:GetValue('G6Y_CODGZC')) .And. oModel:GetOperation() <> MODEL_OPERATION_VIEW
					oGrid2:DeleteLine()
				Endif
			Next
			
			oGrid2:GoLine(1)
		Next
		
		oGrid1:GoLine(1)
		
	Endif

Return


Static Function TP700BDblClick(oView)

Local aLegend	:= {{ "BR_VERDE", STR0030 },; // "Depósito Aceito"
 					{ "BR_AMARELO", STR0031 }} // "Depósito Rejeitado."

BrwLegenda("Legenda",STR0032,aLegend) // "Depósitos"

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumCancelDep()

Soma apenas os depósitos com status: Aceito
para o totalizador.
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function SumCancelDep(oModel)
Local lRet      := .F. 
Local oModelG6Y := oModel:GetModel('GRID2')

	lRet := oModelG6Y:GetValue('G6Y_STSDEP') == '1'
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPVldDt700b()

Valida se a data informada no depósito está dentro da Ficha de Remessa.
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TPVldDt700b(oGrid,cCpo,xValAtu)
Local oMdl     := oGrid:GetModel()
Local lRet     := .F.
Local cNumFch  := oMdl:GetModel("GRID2"):GetValue("G6Y_NUMFCH")
Local nAgencia := omdl:GetModel("GRID1"):GetValue("CODAGE")
Local dDataIni := StoD("  /  /  ") 
Local dDataFin := StoD("  /  /  ")
	
	If !Empty(cNumFch)
		DbSelectArea("G6X")
		G6X->(DbSetOrder(3))

		If DbSeek(xFilial("G6X")+nAgencia+cNumFch)
			dDataIni := G6X->G6X_DTINI
			dDataFin := G6X->G6X_DTFIN
			
			lRet := .T.
		EndIf
	Else
		FwAlertHelp("Ficha de Remessa.","Informe o número da Ficha de Remessa")
	EndIf

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPVldPert700b()

Valida se o campo em análise tem seus conteúdos dentro do range definido no ComboBox
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function TPVldPert700b(oGrid,cCpo,xValAtu)
Local lRet := .F.

	If cCpo == "G6Y_STSDEP"
		lRet := xValAtu $ "1|2"

		If lRet .And. oGrid:GetValue('G6Y_CODGZC') == '029' .And. xValAtu == '1'
			lRet := VldDepTerc(oGrid)
		Endif

	ElseIf cCpo == "G6Y_FORPGT"
		lRet := xValAtu $ "1|2|3"
	EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPVldBc700b()

Valida se o conteúdo informado no campo Banco existe na tabela de Bancos.
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function TPVldBc700b(oGrid,cCpo,xValAtu)
Local lRet := .T.
	
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	
	lRet := SA6->(DbSeek(xFilial("SA6")+xValAtu))

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPVldBc700b()

Valida se o número da Ficha informado está dentro do range do caixa.
 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TPVldNfc700b(oGrid,cCpo,xValAtu)

Local lRet := .F.

	lRet := xValAtu $ cNumFch
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPVldBc700b()
Verifica se o campo Status de Pagamento foi preenchido.

 
@sample	GTPA700B()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function TPPosCmt700B(oSubMdl, cAction)
Local oModel   := oSubMdl:GetModel()
Local lRet     := .F.
Local oGridG6Y := oSubMdl:GetModel("GRID2")
Local nDataMdl := 0
	
	If FwIsInCallStack("GTPA700B")
		For nDataMdl := 1 to Len(oGridG6Y:aDataModel)
			lRet := !Empty(oGridG6Y:GetValue("G6Y_STSDEP", nDataMdl))
			If !lRet
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA700B', STR0033, "")  // "Informe todos os Status de Depósito para confirmar o lançamento."
				Exit
			EndIf
		Next nX
	Else
		lRet := .T.
	EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SeekSF1()
Valida o documento de entrada selecionado.
@sample	GTPA700B()
@return	
@author	SIGAGTP 
@since 13/12/2021
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function SeekSF1(oMdl, cField, xVal)
Local nLine			:= oMdl:GetLine()
Local cAliasQry 	:= GetNextAlias()
Local oMdlFCH 		:= oMdl:GetModel():GetModel("GRID1")
Local oMdlG6Y 		:= oMdl:GetModel():GetModel("GRID2")
Local lRet			:= .T.
Local nOperation	:= oMdl:GetOperation()

If cField == "G6Y_LOJA" .Or.;
	(cField $ "G6Y_NOTA|G6Y_SERIE" .And. !Empty(oMdl:GetValue('G6Y_NOTA')) .And. !Empty(oMdl:GetValue('G6Y_SERIE')) .And.;
	 !Empty(oMdl:GetValue('G6Y_FORNEC')) .And. !Empty(oMdl:GetValue('G6Y_LOJA')))

	If nOperation == 4

		SF1->(dbSetOrder(1))

		If SF1->(dbSeek(xFilial('SF1')+oMdl:GetValue('G6Y_NOTA')+oMdl:GetValue('G6Y_SERIE')+oMdl:GetValue('G6Y_FORNEC')+xVal))
			
			BeginSQL Alias cAliasQry
			
				SELECT  G6Y_NOTA
				FROM %Table:G6Y% G6Y
				WHERE G6Y_FILIAL = %xFilial:G6Y%
				AND G6Y_TPLANC = '1'
				AND G6Y_NOTA = %Exp:SF1->F1_DOC%
				AND G6Y_SERIE = %Exp:SF1->F1_SERIE%
				AND G6Y_FORNEC = %Exp:SF1->F1_FORNECE%
				AND G6Y_LOJA = %Exp:SF1->F1_LOJA%
				AND %NotDel%
					
			EndSql

			If  (cAliasQry)->(Eof())

				If !FINDNF(oMdlG6Y,oMdlFCH,oMdlFCH:GetValue("FICHA"), nLine) // procura no grid atual se ja foi utilizado a nota fiscal
					oMdl:SetValue('G6Y_DATA', SF1->F1_EMISSAO)
					oMdl:SetValue('G6Y_VALOR', SF1->F1_VALBRUT)
				Else
					lRet := .F.
					FwAlertHelp(STR0036, STR0037) //"Documento de entrada", "Esse documento já foi utilizado para esse caixa"
				Endif
			Else
				lRet := .F.
				FwAlertHelp(STR0036, STR0038) //"Documento de Entrada", "Esse documento já foi utilizado para lançamento de outra ficha de remessa"
			Endif

			(cAliasQry)->(dbCloseArea())

		Else
			lRet := .F.
			FwAlertHelp(STR0036, STR0039) //"Documento de entrada", "Documento de Entrada inválido"
		Endif	

	Endif

	If !(lRet)
		oMdl:ClearField("G6Y_NOTA")
		oMdl:ClearField("G6Y_SERIE")
		oMdl:ClearField("G6Y_FORNEC")
		oMdl:ClearField("G6Y_LOJA")
	Endif

Endif

oMdl:GoLine(nLine)	

Return xVal

Static Function FINDNF(oMdlG6Y,oMdlFCH,cFicha, nLine)

Local lRet			:= .F.
Local nY			:= 0
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()

For nY := 1 to oMdlFCH:Length()
	oMdlFCH:GoLine( nY)
	If oMdlFCH:GetValue("FICHA") <> cFicha 
		If oMdlG6Y:SeekLine({ {'G6Y_NOTA', SF1->F1_DOC},{"G6Y_SERIE",SF1->F1_SERIE},;
								{'G6Y_FORNEC', SF1->F1_FORNECE},{'G6Y_LOJA', SF1->F1_LOJA}})
			lRet	:= .T.
				
		Endif
	Else
		If oMdlG6Y:SeekLine({ {'G6Y_NOTA', SF1->F1_DOC},{"G6Y_SERIE",SF1->F1_SERIE},;
								{'G6Y_FORNEC', SF1->F1_FORNECE},{'G6Y_LOJA', SF1->F1_LOJA}}) .And.;
				nLine != oMdlG6Y:GetLine()
			lRet	:= .T.
			
		Endif	
		
	Endif
					
Next nY

RestArea(aArea)
FwRestRows( aSaveLines )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldDepTerc(oMdl)
Valida se todas as informações do depósito de terceiro foram preenchidas
@sample	
@return	lRet lógico
@author	flavio.martins
@since		14/02/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function VldDepTerc(oMdl)
Local lRet := .T.

If Empty(oMdl:GetValue('G6Y_FORPGT'))	.Or.;
	Empty(oMdl:GetValue('G6Y_BANCO')) 	.Or.;
	Empty(oMdl:GetValue('G6Y_AGEBCO')) 	.Or.;
	Empty(oMdl:GetValue('G6Y_CTABCO')) 	.Or.;
	Empty(oMdl:GetValue('G6Y_DATA')) 

	lRet := .F.
	oMdl:GetModel():SetErrorMessage(oMdl:GetModel():GetId(),,oMdl:GetModel():GetId(),,'GTPA700B', STR0040, "")  // "Preencha todos dos dados do depósito"
Endif

Return lRet
