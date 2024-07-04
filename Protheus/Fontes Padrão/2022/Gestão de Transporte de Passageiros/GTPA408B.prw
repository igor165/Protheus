#include "GTPA408B.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

Static cGridFocus 
Static lDelButton

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Rotina de Veículos por Escala.(Montagem da escala Step 3)

@sample  	ModelDef()

@return  	oModel - Objeto do Model

@author		Fernando Amorim (Cafu)
@since		
@version 	P12.1.16
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStruCab  	:= FWFormModelStruct():New() // Cabeçalho da escala
Local oStruSEL1  	:= FWFormStruct(1,"GID")
Local oStruSEL2  	:= FWFormStruct(1,"GID")
Local oStruGZQ		:= FWFormStruct(1,"GZQ")

Local bLoad			:= {|oFieldModel, lCopy| GTPA408BLoad(oFieldModel, lCopy)}
Local bPreValid		:= { |oGrid, nLn, cAct, cFld, xVl, xOld| G408BVldSelected(oGrid, nLn, cAct, cFld, xVl, xOld) }

G408BStruct(oStruCab,oStruSEL1,oStruSEL2,"M")

oModel := MPFormModel():New('GTPA408B')

oModel:AddFields("CABESC",/*PAI*/,oStruCab,,,bLoad)
oModel:AddGrid("SELECAO1", "CABESC", oStruSEL1,,,,,{|oSubMdl| G408BCarga(oSubMdl)})
oModel:SetRelation( 'SELECAO1', { { 'GID_FILIAL', 'XFILIAL("GID")' } }   )

oModel:AddGrid("SELECAO2", "CABESC", oStruSEL2, bPreValid, , , , {|oSubMdl| G408BCarga(oSubMdl)})
oModel:SetRelation( 'SELECAO2', { { 'GID_FILIAL', 'XFILIAL("GID")' } }  )

oModel:AddGrid("GZQDETAIL", "SELECAO2", oStruGZQ, , , , , {|oSubMdl| G408BCarga(oSubMdl)})

oModel:GetModel("CABESC"):SetOnlyQuery(.t.)
oModel:GetModel("SELECAO1"):SetOnlyQuery(.t.)
oModel:GetModel("SELECAO2"):SetOnlyQuery(.t.)
oModel:GetModel("SELECAO1"):SetNoDeleteLine( .T. )
oModel:GetModel("GZQDETAIL"):SetOnlyQuery(.t.)
oModel:GetModel("GZQDETAIL"):SetOptional(.t.)
oModel:GetModel("CABESC"):SetDescription(STR0001) //"Escalas."
oModel:GetModel('SELECAO1'):SetDescription(STR0002) // "Seleção de horários" 
oModel:GetModel('SELECAO2'):SetDescription(STR0003) // "Horários selecionados"

oModel:GetModel('SELECAO1'):SetMaxLine(9990) 
oModel:GetModel('SELECAO2'):SetMaxLine(9990)

oModel:SetDescription(STR0001)// "Escalas."

oModel:SetPrimaryKey({})

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@sample  	ViewDef()

@return  	oView - Objeto do View

@author		Fernando Amorim(Cafu)

@since		04/07/2017
@version 	P12.1.16
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView			:= Nil	
																					
Local oStruCab	    := FWFormViewStruct():New()
Local oStruSEL1 	:= FWFormStruct(2, 'GID') 
Local oStruSEL2 	:= FWFormStruct(2, 'GID') 

Local oModel		:= FWLoadModel("GTPA408B")

G408BStruct(oStruCab,oStruSEL1,oStruSEL2,"V") 

oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddField("VIEW_CAB",oStruCab,"CABESC")
oView:AddGRID("V_SELECAO",oStruSEL1,"SELECAO1")
oView:AddGRID("V_SELECIONADO",oStruSEL2,"SELECAO2")
oView:GetModel('SELECAO2'):SetNoDeleteLine(.T.)
oView:GetModel('SELECAO2'):SetNoInsertLine(.T.)
oView:GetModel('SELECAO1'):SetNoInsertLine(.T.)

oView:SetViewProperty( "V_SELECIONADO", "GRIDNOORDER")

oView:AddIncrementField('SELECAO2','G52SEQUEN')

oView:CreateHorizontalBox("SUPERIOR" , 25) // cabeçalho
oView:CreateHorizontalBox("INFERIOR" , 75) // montagem da escala

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_CAB", "SUPERIOR")

oView:CreateVerticalBox( 'DIREITA' , 47,"INFERIOR")
oView:CreateVerticalBox( 'CENTRO'  , 06,"INFERIOR")
oView:CreateVerticalBox( 'ESQUERDA', 47,"INFERIOR")

oView:AddOtherObject("VIEW_BUTTON", {|oPanel| GTPA408Button(oPanel)})

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "V_SELECAO", "DIREITA")
oView:SetOwnerView( "VIEW_BUTTON", "CENTRO")
oView:SetOwnerView( "V_SELECIONADO", "ESQUERDA")

oView:EnableTitleView("VIEW_CAB", STR0001)// "Escalas."
oView:EnableTitleView("V_SELECAO", STR0002)// "Seleção de horários."
oView:EnableTitleView("V_SELECIONADO",STR0003 )// "Horários selecionados."

// saber onde está o Foco
oView:GetViewObj("V_SELECAO")[3]:SetGotFocus({||cGridFocus := "V_SELECAO" })
oView:GetViewObj("V_SELECIONADO")[3]:SetGotFocus({||cGridFocus := "V_SELECIONADO" })
oView:GetViewObj("V_SELECAO")[3]:SetDoubleClick({|oVw| GA408DblClick(oVw) })

oView:SetViewProperty("V_SELECAO"		, "GRIDSEEK", {.T.})
oView:SetViewProperty("V_SELECIONADO"	, "GRIDSEEK", {.T.})
oView:SetViewProperty("V_SELECAO"		, "GRIDFILTER", {.T.}) 
oView:SetViewProperty("V_SELECIONADO"	, "GRIDFILTER", {.T.}) 

If __cUserId == "000000" // Keys adicionados como solução de contorno para automação com TIR (metodo ClickImage não está funcionando)
	SetKey( VK_F5 ,{|| G408Next()} ) 
	SetKey( VK_F6 ,{|| G408Secionamento()} ) 
	SetKey( VK_F7 ,{|| MoveHorar(2)} ) 
	SetKey( VK_F8 ,{|| MoveHorar(3)} ) 
Endif

Return(oView)

/*/{Protheus.doc} G408BStruct()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 13/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408BStruct(oStruCab,oStruSel,oStruSel2,cTipo) 

Local aOrdem	:= {}

If ( cTipo == "M" )
	If ValType( oStruCab ) == "O"
		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField(	STR0004,;									// 	[01]  C   Titulo do campo
					 		STR0004,;									// 	[02]  C   ToolTip do campo
					 		"FILIAL",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("GID_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruCab:AddField(	STR0005,;									// 	[01]  C   Titulo do campo
					 		STR0005,;									// 	[02]  C   ToolTip do campo
					 		"ESCALA",;							// 	[03]  C   Id do Field
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

		oStruCab:AddField(	STR0006,;						// 	[01]  C   Titulo do campo
				 		    STR0006,;				// 	[02]  C   ToolTip do campo
					 		"DESCRICAO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		35,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruCab:AddField(	STR0025,;							// 	[01]  C   Titulo do campo	//"Local Manut"	
					 		STR0026,;					// 	[02]  C   ToolTip do campo	//"Local de Manutenção"
					 		"LOCALMANUT",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("GI1_COD")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oSubMdl,cFld,xVlNew,nLn,xVlOld| GA408VldManut(oSubMdl,cFld,xVlNew,nLn,xVlOld)},;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.T.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruCab:AddField(	STR0027,;							// 	[01]  C   Titulo do campo	//"Manutenção em"
					 		STR0027,;					// 	[02]  C   ToolTip do campo		//"Manutenção em"
					 		"DSCLCMANUT",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("GI1_DESCRI")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.f.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual			 				 		
		
		oStruCab:SetProperty("ESCALA", MODEL_FIELD_INIT , {||GetCodEscala()})
		oStruCab:SetProperty("ESCALA", MODEL_FIELD_OBRIGAT , .T.)			 		
		oStruCab:SetProperty("DESCRICAO", MODEL_FIELD_OBRIGAT , .T.)
		
		
		oStruCab:AddTrigger('LOCALMANUT','DSCLCMANUT' ,{ || .T. }, { |oSubMdl| POSICIONE("GI1",1,XFILIAL("GI1")+oSubMdl:GetValue('LOCALMANUT'),"GI1_DESCRI") } )
		
	Endif
	
	If ValType( oStruSel ) == "O"
			
    	oStruSel:SetProperty("GID_COD", MODEL_FIELD_INIT , " ")
    	oStruSel:SetProperty("GID_SENTID", MODEL_FIELD_INIT , " ")
    	oStruSel:SetProperty("*", MODEL_FIELD_OBRIGAT , .F.)
    	oStruSel:SetProperty("*", MODEL_FIELD_VALID , {||.T.})
    	oStruSel:SetProperty("GID_NLINHA", MODEL_FIELD_TITULO,STR0034)		// "Origem/Destino"
    	
		oStruSel:AddField(	STR0004,;									// 	[01]  C   Titulo do campo
					 		STR0004,;									// 	[02]  C   ToolTip do campo
					 		"CODESCAL",;							// 	[03]  C   Id do Field
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
					 		
		oStruSel:AddField(	"",;									// 	[01]  C   Titulo do campo
					 		STR0028,;									// 	[02]  C   ToolTip do campo	//"Legenda"
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
					 		
					 					 		
		oStruSel:AddField(	STR0029,;							// 	[01]  C   Titulo do campo	//"Saída Garag"
					 		STR0030,;					// 	[02]  C   ToolTip do campo	//"Hora de Saída Garagem"
					 		"G52HRSDGR",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_HRSDGR")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oSubMdl,cFld,xVlNew,nLn,xVlOld| GA408VldHour(oSubMdl,cFld,xVlNew,nLn,xVlOld) },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual			 		
					 		
		oStruSel:AddField(	STR0031,;							// 	[01]  C   Titulo do campo	// "Cheg Garag"
					 		STR0032,;					// 	[02]  C   ToolTip do campo		// "Hora de Chegada Garagem"
					 		"G52HRCHGR",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_HRCHGR")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruSel:AddField(	STR0061,;							// 	[01]  C   Titulo do campo	// "Secionado?"	
					 		STR0062,;							// 	[02]  C   ToolTip do campo	// "Secionado? 1=Sim; 2=Não;3=Pai"
					 		"G52SEC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							1, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		{STR0040,STR0041,STR0063},;						//	[09]  A   Lista de valores permitido do campo		// "1=Sim"	"2=Não"	 "3=Pai"
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		{|| "2" },;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
		oStruSel:AddField(	STR0064,;							// 	[01]  C   Titulo do campo		// "Seq. Ini."
					 		STR0068,;							// 	[02]  C   ToolTip do campo		// "Sequencia inicial"
					 		"G52SEQINI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("GIE_SEQ")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		oStruSel:AddField(	STR0065,;							// 	[01]  C   Titulo do campo		// "Seq. Fim"
					 		STR0069,;							// 	[02]  C   ToolTip do campo		// "Sequencia Final"
					 		"G52SEQFIM",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("GIE_SEQ")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruSel:AddField(	STR0066,;							// 	[01]  C   Titulo do campo	// "Loc. Sec. Ini."	
					 		STR0067,;							// 	[02]  C   ToolTip do campo	// "Localidade Secionada Inicial"	
					 		"G52SECINI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							6, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruSel:AddField(	STR0070,;							// 	[01]  C   Titulo do campo	// "Loc. Sec Fim"
					 		STR0071,;							// 	[02]  C   ToolTip do campo	// "Localidade Secionada Final"
					 		"G52SECFIM",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							6, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruSel:AddField(	STR0072,;						// 	[01]  C   Titulo do campo	// "Linha Origem"
					 		STR0072,;						// 	[02]  C   ToolTip do campo	// "Linha Origem"
					 		"ORIGINLINE",;							// 	[03]  C   Id do Field
					 		"N",;									// 	[04]  C   Tipo do campo
							4, ;									// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual					 					 		
			
	Endif
	
	If ValType( oStruSel2 ) == "O"
			
    	oStruSel2:SetProperty("GID_COD", MODEL_FIELD_INIT , " ")
    	oStruSel2:SetProperty("GID_SENTID", MODEL_FIELD_INIT , " ")
    	oStruSel2:SetProperty("*", MODEL_FIELD_OBRIGAT , .F.)
    	oStruSel2:SetProperty("*", MODEL_FIELD_VALID , {||.T.})
		oStruSel2:SetProperty("GID_NLINHA", MODEL_FIELD_TITULO,STR0034)		// "Origem/Destino"
		    	
		oStruSel2:AddField(	STR0004,;									// 	[01]  C   Titulo do campo
					 		STR0004,;									// 	[02]  C   ToolTip do campo
					 		"CODESCAL",;							// 	[03]  C   Id do Field
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
		
		oStruSel2:AddField(	STR0035,;									// 	[01]  C   Titulo do campo	//"Seq"
					 		STR0035,;									// 	[02]  C   ToolTip do campo	//"Seq"
					 		"G52SEQUEN",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		4,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruSel2:AddField(	STR0037,;									// 	[01]  C   Titulo do campo	//"Dia"
					 		STR0037,;									// 	[02]  C   ToolTip do campo	//"Dia"
					 		"G52DIA",;								// 	[03]  C   Id do Field
					 		"N",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_DIA")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual					 		
	
		oStruSel2:AddField(	STR0038,;							// 	[01]  C   Titulo do campo	//"Pto Manut."
					 		STR0039,;					// 	[02]  C   ToolTip do campo		//"Ponto de Manutenção"
					 		"G52PMANUT",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_PMANUT")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		{STR0040,STR0041},;						//	[09]  A   Lista de valores permitido do campo	//"1=Sim"#"2=Não"
					 		.f.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		{|| "2" },;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
		oStruSel2:AddField(	STR0029,;							// 	[01]  C   Titulo do campo	//"Saída Garag"
					 		STR0030,;						// 	[02]  C   ToolTip do campo	//"Hora de Saída Garagem"
					 		"G52HRSDGR",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_HRSDGR")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oSubMdl,cFld,xVlNew,nLn,xVlOld| GA408VldHour(oSubMdl,cFld,xVlNew,nLn,xVlOld) },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual			 		
					 		
		oStruSel2:AddField(	STR0031,;							// 	[01]  C   Titulo do campo	//"Cheg Garag"
					 		STR0032,;							// 	[02]  C   ToolTip do campo	//"Hora de Chegada Garagem"
					 		"G52HRCHGR",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_HRCHGR")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oSubMdl,cFld,xVlNew,nLn,xVlOld| GA408VldHour(oSubMdl,cFld,xVlNew,nLn,xVlOld)},;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		oStruSel2:AddField(	STR0073,;							// 	[01]  C   Titulo do campo	// "Fim Garag"
					 		STR0074,;							// 	[02]  C   ToolTip do campo	// "Hora de Fim Garagem"
					 		"G52HRGRFI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_HRGRFI")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oSubMdl,cFld,xVlNew,nLn,xVlOld| GA408VldHour(oSubMdl,cFld,xVlNew,nLn,xVlOld)},;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual	
					 		
					 		
 		oStruSel2:AddField(	STR0075,;							// 	[01]  C   Titulo do campo	// "Dias Parado"
					 		STR0075,;							// 	[02]  C   ToolTip do campo	// "Dias Parado"
					 		"G52DIAPAR",;							// 	[03]  C   Id do Field
					 		"N",;									// 	[04]  C   Tipo do campo
							TamSX3("G52_DIAPAR")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual			 			
		
		oStruSel2:AddField(	STR0076,;							// 	[01]  C   Titulo do campo	// "Nr. Srv."
					 		STR0077,;							// 	[02]  C   ToolTip do campo	// "Número do Serviço"
					 		"G52NUMSRV",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							TamSX3("GID_NUMSRV")[1] , ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		NIL,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)		 			
	
		/*oStruSel2:AddField(	STR0033	,;									// 	[01]  C   Titulo do campo	//"Controle"
					 		STR0033,;									// 	[02]  C   ToolTip do campo	//"Controle"
					 		"CONTROLE",;							// 	[03]  C   Id do Field
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
					 		.T.)									// 	[14]  L   Indica se o campo é virtual*/
	
		oStruSel2:AddField(	STR0061,;							// 	[01]  C   Titulo do campo	// "Secionado?"
					 		STR0062,;							// 	[02]  C   ToolTip do campo	// "Secionado? 1=Sim; 2=Não; 3=Pai"
					 		"G52SEC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							1, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		{STR0040,STR0041,STR0063},;						//	[09]  A   Lista de valores permitido do campo	// "1=Sim"	"2=Não"	 "3=Pai"
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		{|| "2" },;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruSel2:AddField(	STR0066,;							// 	[01]  C   Titulo do campo	// "Loc. Sec Ini"
					 		STR0067,;							// 	[02]  C   ToolTip do campo	// "Localidade Secionada Inicial"
					 		"G52SECINI",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							6, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruSel2:AddField(	STR0070,;							// 	[01]  C   Titulo do campo	// "Loc. Sec Fim"	
					 		STR0071,;							// 	[02]  C   ToolTip do campo	// "Localidade Secionada Final"
					 		"G52SECFIM",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							6, ;				// 	[05]  N   Tamanho do campo				
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;						//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	Endif
			
Else
    
    If ( ValType( oStruCab ) == "O" )
    
	    oStruCab:AddField(	"ESCALA",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0005,;						// [03]  C   Titulo do campo
	                        STR0005,;						// [04]  C   Descricao do campo
	                        {STR0007},;					// [05]  A   Array com Help // "Selecionar"
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
	    
	    oStruCab:AddField(	"DESCRICAO",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0006,;						// [03]  C   Titulo do campo
	                        STR0006,;						// [04]  C   Descricao do campo
	                        {STR0008},;					// [05]  A   Array com Help // "Selecionar"
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

		oStruCab:AddField(	"LOCALMANUT",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0025,;						// [03]  C   Titulo do campo	//"Local Manut"
	                        STR0026,;						// [04]  C   Descricao do campo	//"Local de Manutenção"
	                        {STR0026},;					// [05]  A   Array com Help //"Local de Manutenção"	
	                        "GET",;					// [06]  C   Tipo do campo
	                        "@!",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "GI1",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo

		oStruCab:AddField(	"DSCLCMANUT",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        STR0027,;						// [03]  C   Titulo do campo	//"Manutenção em"
	                        STR0027,;						// [04]  C   Descricao do campo
	                        {STR0027},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "@!",;						// [07]  C   Picture
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
	                        
	EndIf
    
    If ValType( oStruSel ) == "O"
    	
    	oStruSel:RemoveField("GID_VIA")
    	oStruSel:RemoveField("GID_DESVIA")
    	oStruSel:RemoveField("GID_INIVIG")
    	oStruSel:RemoveField("GID_FINVIG")
    	
    	If oStruSel:hasfield("GID_SEQ")
    		oStruSel:RemoveField("GID_SEQ")
    	Endif
    	
    	oStruSel:RemoveField("GID_SERVIC")	
    	oStruSel:RemoveField("GID_LOTACA")	
    	oStruSel:RemoveField("GID_ATUALI")	
    	oStruSel:RemoveField("GID_VIGENC")
    	oStruSel:RemoveField("GID_DTATU")	
    	oStruSel:RemoveField("GID_HRATU") 
    	oStruSel:RemoveField("GID_REVISA")	
    	oStruSel:RemoveField("GID_HIST")	
    	oStruSel:RemoveField("GID_DTALT")	
    	oStruSel:RemoveField("GID_DEL")  
    	oStruSel:RemoveField("GID_SENTID")
    	  	
    	oStruSel:SetProperty("GID_SEG", MVC_VIEW_TITULO , "S")
    	oStruSel:SetProperty("GID_TER", MVC_VIEW_TITULO , "T")
    	oStruSel:SetProperty("GID_QUA", MVC_VIEW_TITULO , "Q")
    	oStruSel:SetProperty("GID_QUI", MVC_VIEW_TITULO , "Q")
    	oStruSel:SetProperty("GID_SEX", MVC_VIEW_TITULO , "S")
    	oStruSel:SetProperty("GID_SAB", MVC_VIEW_TITULO , "S")
    	oStruSel:SetProperty("GID_DOM", MVC_VIEW_TITULO , "D")    	
    	oStruSel:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)    	
    	oStruSel:SetProperty("GID_NLINHA", MVC_VIEW_TITULO,STR0034)	//"Origem/Destino"
    	
    	oStruSel:AddField(	"LEGENDA",;					// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        "",;						// [03]  C   Titulo do campo
	                        STR0028,;						// [04]  C   Descricao do campo	//"Legenda"
	                        {STR0028},;				// [05]  A   Array com Help // "Selecionar"	//"Legenda"
	                        "GET",;						// [06]  C   Tipo do campo
	                        "@BMP",;					// [07]  C   Picture
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
	    
	    oStruSel:AddField( 	'G52SEC',; 			// cIdField
							'99',;	 				// cOrdem
							STR0061,;			 		// cTitulo
							STR0061,; 	// cDescric 
							{STR0061,STR0040, STR0041, STR0063},; 	// aHelp    
							'COMBOBOX',; 				// cType
							'@!',; 					// cPicture
							Nil,; 					// nPictVar
							Nil,; 					// Consulta F3
							.t.,; 					// lCanChange
							'' ,; 					// cFolder
							Nil,; 					// cGroup
							{STR0040,STR0041,STR0063},; 	// aComboValues
							Nil,; 					// nMaxLenCombo
							Nil,; 					// cIniBrow
							.T.,; 					// lVirtual
							Nil ) 					// cPictVar                     

	                        
		AAdd(aOrdem,{"LEGENDA","GID_COD"})
    	AAdd(aOrdem,{"GID_COD","GID_LINHA"})
    	AAdd(aOrdem,{"GID_LINHA","GID_NLINHA"})
    	AAdd(aOrdem,{"GID_NLINHA","GID_HORCAB"})
    	AAdd(aOrdem,{"GID_HORCAB","GID_HORFIM"})
    	AAdd(aOrdem,{"GID_HORFIM","GID_SEG"})
    	AAdd(aOrdem,{"GID_SEG","GID_TER"})
    	AAdd(aOrdem,{"GID_TER","GID_QUA"})
    	AAdd(aOrdem,{"GID_QUA","GID_QUI"})
    	AAdd(aOrdem,{"GID_QUI","GID_SEX"})
    	AAdd(aOrdem,{"GID_SEX","GID_SAB"})
    	AAdd(aOrdem,{"GID_SAB","GID_DOM"})
    	
    	GTPOrdVwStruct(oStruSel,aOrdem)
    	
    Endif
    
    If ValType( oStruSel2 ) == "O"
    
    	oStruSel2:AddField(	"G52SEQUEN",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0035,;						// [03]  C   Titulo do campo	//"Seq"
	                        STR0035,;						// [04]  C   Descricao do campo	//"Seq"
	                        {STR0036},;					// [05]  A   Array com Help // "Sequência da escala"
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
	    
    	oStruSel2:AddField(	"G52DIA",;					// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0037,;						// [03]  C   Titulo do campo	//"Dia"
	                        STR0037,;						// [04]  C   Descricao do campo	//"Dia"
	                        {STR0037},;				// [05]  A   Array com Help // "Selecionar"	//"Dia"
	                        "GET",;						// [06]  C   Tipo do campo
	                        PesqPict("G52","G52_DIA"),;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .t.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		oStruSel2:AddField(	"G52HRSDGR",;					// [01]  C   Nome do Campo
	                        "11",;						// [02]  C   Ordem
	                        STR0029,;						// [03]  C   Titulo do campo	//"Saída Garag"
	                        STR0030,;						// [04]  C   Descricao do campo	//
	                        {STR0030},;				// [05]  A   Array com Help // "Hora de Saída Garagem"
	                        "GET",;						// [06]  C   Tipo do campo
	                        PesqPict("G52","G52_HRSDGR"),;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        Nil,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		
		oStruSel2:AddField(	"G52HRCHGR",;					// [01]  C   Nome do Campo
	                        "12",;						// [02]  C   Ordem
	                        STR0031,;						// [03]  C   Titulo do campo	/"Cheg Garag"
	                        STR0032,;						// [04]  C   Descricao do campo		//"Hora de Chegada Garagem"
	                        {STR0032},;				// [05]  A   Array com Help // "Hora de Chegada Garagem"
	                        "GET",;						// [06]  C   Tipo do campo
	                        PesqPict("G52","G52_HRCHGR"),;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        Nil,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    oStruSel2:AddField(	"G52HRGRFI",;					// [01]  C   Nome do Campo
	                        "13",;						// [02]  C   Ordem
	                        STR0073,;						// [03]  C   Titulo do campo		// "Fim Garag"
	                        STR0074,;						// [04]  C   Descricao do campo		// "Hora de Fim Garagem"
	                        {STR0032},;				// [05]  A   Array com Help // "Hora de Chegada Garagem"
	                        "GET",;						// [06]  C   Tipo do campo
	                        PesqPict("G52","G52_HRGRFI"),;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        Nil,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		 oStruSel2:AddField("G52DIAPAR",;					// [01]  C   Nome do Campo
	                        "14",;						// [02]  C   Ordem
	                        STR0075,;						// [03]  C   Titulo do campo		// "Dias Parados"
	                        STR0075,;						// [04]  C   Descricao do campo		// "Dia Para"
	                        {STR0075},;				// [05]  A   Array com Help 				// "Dias Parado"
	                        "GET",;						// [06]  C   Tipo do campo
	                        PesqPict("G52","G52_DIAPAR"),;					// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        Nil,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	   oStruSel2:AddField( 	'G52SEC',; 			// cIdField
							'99',;	 				// cOrdem
							STR0061,;			 		// cTitulo	// "Secionado?"
							STR0061,; 	// cDescric		// "Secionado?" 
							{STR0061,STR0040, STR0041, STR0063},; 	// aHelp    
							'COMBOBOX',; 				// cType
							'@!',; 					// cPicture
							Nil,; 					// nPictVar
							Nil,; 					// Consulta F3
							.t.,; 					// lCanChange
							'' ,; 					// cFolder
							Nil,; 					// cGroup
							{STR0040,STR0041,STR0063},; 	// aComboValues
							Nil,; 					// nMaxLenCombo
							Nil,; 					// cIniBrow
							.T.,; 					// lVirtual
							Nil ) 					// cPictVar                     
		
    	oStruSel2:RemoveField("GID_VIA")
    	oStruSel2:RemoveField("GID_DESVIA")
    	oStruSel2:RemoveField("GID_INIVIG")
    	oStruSel2:RemoveField("GID_FINVIG")
    	
    	If oStruSel2:hasfield("GID_SEQ")
    		oStruSel2:RemoveField("GID_SEQ")
    	Endif
    	
    	oStruSel2:RemoveField("GID_SERVIC")	
    	oStruSel2:RemoveField("GID_LOTACA")	
    	oStruSel2:RemoveField("GID_ATUALI")	
    	oStruSel2:RemoveField("GID_VIGENC")
    	oStruSel2:RemoveField("GID_DTATU")	
    	oStruSel2:RemoveField("GID_HRATU") 
    	oStruSel2:RemoveField("GID_REVISA")	
    	oStruSel2:RemoveField("GID_HIST")	
    	oStruSel2:RemoveField("GID_DTALT")	
    	oStruSel2:RemoveField("GID_DEL")    
    	oStruSel2:RemoveField("GID_SENTID")
    		
    	oStruSel2:SetProperty("GID_SEG", MVC_VIEW_TITULO , "S")
    	oStruSel2:SetProperty("GID_TER", MVC_VIEW_TITULO , "T")
    	oStruSel2:SetProperty("GID_QUA", MVC_VIEW_TITULO , "Q")
    	oStruSel2:SetProperty("GID_QUI", MVC_VIEW_TITULO , "Q")
    	oStruSel2:SetProperty("GID_SEX", MVC_VIEW_TITULO , "S")
    	oStruSel2:SetProperty("GID_SAB", MVC_VIEW_TITULO , "S")
    	oStruSel2:SetProperty("GID_DOM", MVC_VIEW_TITULO , "D") 
    	
    	oStruSel2:SetProperty("GID_COD", MVC_VIEW_TITULO , "Horário")
    	
    	oStruSel2:SetProperty("GID_COD", MVC_VIEW_VIRTUAL , .T.) 
    	oStruSel2:SetProperty("GID_LINHA", MVC_VIEW_VIRTUAL , .T.)  
    	oStruSel2:SetProperty("GID_NLINHA", MVC_VIEW_VIRTUAL , .T.)	
     	oStruSel2:SetProperty("GID_HORCAB", MVC_VIEW_VIRTUAL , .T.)
    	oStruSel2:SetProperty("GID_HORFIM", MVC_VIEW_VIRTUAL , .T.) 
    	
    	oStruSel2:SetProperty("GID_COD", MVC_VIEW_CANCHANGE , .F.) 
    	oStruSel2:SetProperty("GID_LINHA", MVC_VIEW_CANCHANGE , .F.)  
    	oStruSel2:SetProperty("GID_NLINHA", MVC_VIEW_CANCHANGE , .F.)	
    	oStruSel2:SetProperty("GID_HORCAB", MVC_VIEW_CANCHANGE , .F.)
    	oStruSel2:SetProperty("GID_HORFIM", MVC_VIEW_CANCHANGE , .F.) 
    	oStruSEL2:SetProperty('GID_NUMSRV'		, MVC_VIEW_CANCHANGE , .F. )
    	     	   	
    	oStruSel2:SetProperty("GID_NLINHA", MVC_VIEW_TITULO,STR0034)	//"Origem/Destino"
    	
    	AAdd(aOrdem,{"G52SEQUEN","GID_COD"})
    	AAdd(aOrdem,{"GID_COD","GID_LINHA"})
    	AAdd(aOrdem,{"GID_LINHA","GID_NLINHA"})
    	AAdd(aOrdem,{"GID_NLINHA","G52HRSDGR"})
    	AAdd(aOrdem,{"G52HRSDGR","GID_HORCAB"})
    	AAdd(aOrdem,{"GID_HORCAB","GID_HORFIM"})
    	AAdd(aOrdem,{"GID_HORFIM","G52HRCHGR"})
    	AAdd(aOrdem,{"G52HRCHGR","G52HRGRFI"})
    	AAdd(aOrdem,{"G52HRGRFI","GID_SEG"})
    	AAdd(aOrdem,{"GID_SEG","GID_TER"})
    	AAdd(aOrdem,{"GID_TER","GID_QUA"})
    	AAdd(aOrdem,{"GID_QUA","GID_QUI"})
    	AAdd(aOrdem,{"GID_QUI","GID_SEX"})
    	AAdd(aOrdem,{"GID_SEX","GID_SAB"})
    	AAdd(aOrdem,{"GID_SAB","GID_DOM"})
    	AAdd(aOrdem,{"GID_DOM","G52DIAPAR"})
    	
    	AAdd(aOrdem,{"GID_NLINHA","G52DIA"})
    	
    	GTPOrdVwStruct(oStruSel2,aOrdem)
    	
    Endif

EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA408BLoad
Carga dos campos virtuais da Seleção de escala
@author Fernando Amorim(Cafu)
@since 04/07/2017
@version
/*/
//-------------------------------------------------------------------
Function GTPA408BLoad(oFieldModel,lCopy)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

Local nOpera := GA408GetOperation()

If ( nOpera == 1 .Or. nOpera == 2 )

	aAdd(aCampos,xFilial("G52"))
	aAdd(aCampos,Space(TamSx3("G52_CODIGO")[1]))
	aAdd(aCampos,Space(TamSx3("G52_DESCRI")[1]))
	aAdd(aCampos,Space(TamSx3("GI1_COD")[1]))
	aAdd(aCampos,Space(TamSx3("GI1_DESCRI")[1]))
	
	Aadd(aLoad,aCampos)
	Aadd(aLoad,0)

Else

	aAdd(aCampos,xFilial("G52"))
	aAdd(aCampos,G52->G52_CODIGO)
	aAdd(aCampos,G52->G52_DESCRI)
	aAdd(aCampos,Space(TamSx3("GI1_COD")[1]))
	aAdd(aCampos,Space(TamSx3("GI1_DESCRI")[1]))
	
	Aadd(aLoad,aCampos)
	Aadd(aLoad,G52->(Recno()))

EndIf

RestArea(aArea)

Return(aLoad)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA408Button
Botoes que irão transferir horarios de um lado par ao outro
@author Fernando Amorim(Cafu)
@since 04/07/2017
@version
/*/
//-------------------------------------------------------------------
Static Function GTPA408Button( oPanel )

Local oBtn1
Local oBtn3
Local oBtn4
Local oBtnSec	
Local bNext		:= {|| G408Next() }

oBtn1 := TBitmap():New(40,15,25,25,,"NEXT",.T.,oPanel,;
            			bNext,,.F.,.F.,,,.F.,,.T.,,.F.)
oBtn1:CTOOLTIP := STR0009 //"Copia o horário selecionado"

oBtnSec := TBitmap():New(65,15,30,30,,"EDIT",.T.,oPanel,;
            			{|| G408Secionamento()},,.F.,.F.,,,.F.,,.T.,,.F.)

oBtnSec:cToolTip := STR0078	// "Secionar Horário"

oBtn3 := TBitmap():New(090,15,25,25,,"PREV",.T.,oPanel,;
            			{||MoveHorar(2)},,.F.,.F.,,,.F.,,.T.,,.F.)
oBtn3:CTOOLTIP := STR0010 //"Voltar o horário selecionado"

oBtn4 := TBitmap():New(115,15,25,25,,"PGPREV",.T.,oPanel,;
            			{||MoveHorar(3)},,.F.,.F.,,,.F.,,.T.,,.F.)
oBtn4:CTOOLTIP := STR0011 //"Voltar todos os horários"    

Return

Static Function G408Next()

Local oMdl408B 	:= GA408GetModel("GTPA408B")

Local aSeek		:= {}
Local aData		:= {}

Local cServico	:= ""
Local cLocalIni	:= ""
Local cLocalFim	:= ""

Local nLineSel1	:= 0
Local nI		:= 0
Local nP		:= 0

If ( oMdl408B:GetModel("SELECAO1"):GetValue("G52SEC") == "1" )
	
	CursorWait()
	
	cServico 	:= oMdl408B:GetModel("SELECAO1"):GetValue("GID_COD")
	cLocalIni	:= oMdl408B:GetModel("SELECAO1"):GetValue("G52SECINI")
	cLocalFim	:= oMdl408B:GetModel("SELECAO1"):GetValue("G52SECFIM")
	
	nLineSel1 := oMdl408B:GetModel("SELECAO1"):Getline()
	
	//MoveHorar(1)

	aAdd(aSeek,{"GIE_CODGID",cServico})	
	aAdd(aSeek,{"GIE_IDLOCP",cLocalIni})	
	aAdd(aSeek,{"GIE_IDLOCD",cLocalFim})
	
	aAdd(aData,{"GIE_SEQ","GIE_IDLOCP","GIE_IDLOCD"})
	
	If ( GTPSeekTable("GIE",aSeek,aData) )
		
		cSeqServ := aData[2,1] 
		
		aSeek := {}
		
		aAdd(aSeek,{"GIE_CODGID",cServico})	
		
		If ( GTPSeekTable("GIE",aSeek,aData) )
			
			nP := aScan(aData,{|x| x[1] == cSeqServ })
			
			If ( nP > 0 )
			
				For nI := nP to Len(aData)
					
					aSeek := {}
					
					aAdd(aSeek,{"GID_COD",cServico})
					aAdd(aSeek,{"G52SECINI",aData[nI,2]})
					aAdd(aSeek,{"G52SECFIM",aData[nI,3]})
					
					If ( oMdl408B:GetModel("SELECAO1"):SeekLine(aSeek) )
						
						If !( MoveHorar(1,.t.) )
							Exit
						EndIf
							
					EndIf
											
				Next nI
				
			EndIf
			
		EndIf
		
	EndIF
	
	oMdl408B:GetModel("SELECAO1"):GoLine(nLineSel1)
	
	CursorArrow()
	
Else
	MoveHorar(1)
EndIf	

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} MoveHorar
Função que irá transferir horarios de um lado par ao outro
@author Fernando Amorim(Cafu)
@since 05/07/2017
@version
//-------------------------------------------------------------------*/

Static Function MoveHorar(nBt,lNoMsg) 

Local oModel		:= GA408GetModel('GTPA408B')	
Local oMdlSel1	 	:= oModel:GetModel( 'SELECAO1' )
Local oMdlSel2	 	:= oModel:GetModel( 'SELECAO2' )
Local oView

Local nY			:= 0
Local nX			:= 0
Local nI			:= 0
Local nlinhaSel1	:= 0
Local nlinhaSel2	:= 0
Local nNewLine		:= 0
Local nOpc			:= 0

Local aStruct		:= {}
Local aValues		:= {}
Local aRetParam 	:= {}
Local aSeek			:= {}
Local cLocIni		:= ''
Local cLocFim		:= ''
Local cSeq			:= ''
Local cAviso		:= ''
Local lRet			:= .t.

Default lNoMsg		:= .f.

If oModel:GetOperation() <> MODEL_OPERATION_INSERT .and.  oModel:GetOperation() <> MODEL_OPERATION_UPDATE 
	Return(.f.)
Endif

oView := GA408GetView('GTPA408B')

If nBt == 1  // Botão 1 copia o item posicionado para lado direito
	
	If cGridFocus == 'V_SELECAO' 
		
		nlinhaSel1 		:= oMdlSel1:GetLine()
		
		/*aHora := G408IsHoraEscala(oMdlSel1:GetValue("GID_COD"),oModel:GetModel("CABESC"):GetValue("ESCALA"))
		
		If ( aHora[1] )	//existe o horário em outra escala
			lRet := .f.
			FwAlertHelp(STR0042 + aHora[2] + " - " + aHora[3] + ".",STR0043)	//"Este horário já existe em outra escala, " //"Selecione outro horário"
		EndIf*/
		
		If ( lRet )
			
			If (	oMdlSel1:GetValue( 'GID_SEG' ) .OR. oMdlSel1:GetValue( 'GID_TER' ) .OR.; 
					oMdlSel1:GetValue( 'GID_QUA' ) .OR. oMdlSel1:GetValue( 'GID_QUI' ) .OR.;
					oMdlSel1:GetValue( 'GID_SEX' ) .OR. oMdlSel1:GetValue( 'GID_SAB' ) .OR.; 
					oMdlSel1:GetValue( 'GID_DOM' ) ) 
					
				lRet := .t.
			
			Else	
				lRet := .f.
			EndIf
			
			If ( lRet )
				
				GI2->(DbSetOrder(1))
				
				GIE->(DbOrderNickName("SEQUENCIA"))
				
				If !Empty(oMdlSel1:GetValue( 'GID_COD' ))
					
					If ( oMdlSel1:GetValue("G52SEC") <> "1" )
						
						cSeq	:= GetLocIni(oMdlSel2,oMdlSel1:GetValue( 'GID_COD' ))
						
						If ( GIE->(DbSeek(xFilial("GIE") + oMdlSel1:GetValue( 'GID_COD' ))) ) 	
							cLocIni := GIE->GIE_IDLOCP
						Else
							cLocIni := ""	
						Endif
					
					Else
						cLocIni := oMdlSel1:GetValue("G52SECINI")
					EndIf
					
					oMdlSel2:GoLine(oMdlSel2:Length())
				
					If !Empty(oMdlSel2:GetValue( 'GID_COD' ))
					
						//senão for secionado, pega a localidade final do horário
						If ( oMdlSel2:GetValue("G52SEC") <> "1" )
						
							cSeq	:= GetLocFim(oMdlSel2)
					
							If ( GIE->(DbSeek(xFilial("GIE")+oMdlSel2:GetValue( 'GID_COD' ) + Padr(cSeq,TamSx3("GIE_SEQ")[1]))) )
								cLocFim := GIE->GIE_IDLOCD
							Else
								cLocFim := ""
							EndIf
					
						Else	//senão busca a localidade final do secionamento
					
							cLocFim 	:= oMdlSel2:GetValue("G52SECFIM")
						
						EndIf
					
					Else
						cLocFim := ""
					Endif
	
					If !( ALLTRIM(cLocIni) == alltrim(cLocFim) .Or. Empty(cLocFim) ) 
						
						cAviso := STR0044	//"Foi selecionado um horário que quebra a sequência lógica, cancele a operação ou confirme, mas informe um novo dia."
						
						If ( !lNoMsg )
						
							nOpc := AVISO(STR0045,cAviso , {STR0046,STR0047}, 1)	//"Fora de Sequência"#"Cancelar"#"Confirmar"		
						
							lRet := nOpc == 2
						
						Else
							lRet := .t.	
						EndIf	
								
					Endif
				
					If ( lRet )
					
						aStruct 		:= oMdlSel1:GetStruct():GetFields()
						aValues 		:= {}
						
						For nY := 1 to len( aStruct )
						
							If ( AllTrim(aStruct[nY][3]) == "G52DIA" .And. aRetParam[1] > 0 )
								aAdd( aValues, { AllTrim( aStruct[nY][3] ), aRetParam[1] } )
							Else 
								aAdd( aValues, { AllTrim( aStruct[nY][3] ), oMdlSel1:GetValue( aStruct[nY][3] ) } )
							EndIf
					
						Next nY
						
						aAdd(aValues, {"G52PMANUT","2"})
						aAdd(aValues, {"G52HRGRFI",""})
						
						lRet := LoadVSel(oModel,oMdlSel1,oMdlSel2,'SELECAO2',aValues,.T.)
						
						If ( lRet )
							TurnOffFrequence()
						EndIf	
						
						oView:Refresh( 'V_SELECAO'	)
						oView:Refresh( 'V_SELECIONADO'	)
					
					EndIf
				
				EndIf
				
			Else
				
				If ( !lNoMsg )
					FwAlertHelp(STR0012,STR0014) // "Horário","Todos os dias desse horário já foram utilizados para escala"
				EndIF
							
			Endif
		
		EndIf
		
	Else
		
		lRet := .f.
			
		If ( !lNoMsg )
			FwAlertHelp(STR0015,STR0017) //"Atenção","Este botão só funciona quando está posicionado no grid da esquerda"
		EndIf
				
	Endif	

ElseIf nBt == 2  // Botão 2 copia o item posicionado para lado esquerdo novamente(devolve os marcados na frequencia)
	
	If  cGridFocus == 'V_SELECIONADO'
		
		If ( oMdlSel2:GetLine() == oMdlSel2:Length() )	
			
			aSeek := {}
			
			If ( oMdlSel2:GetValue("G52SEC") <> "1" )
				
				aAdd(aSeek,{'GID_COD', oMdlSel2:GetValue( 'GID_COD' )})
				aAdd(aSeek,{'GID_HORCAB', oMdlSel2:GetValue( 'GID_HORCAB' )})					
		
			Else
				
				aAdd(aSeek, {'GID_COD', oMdlSel2:GetValue( 'GID_COD' )})
				aAdd(aSeek, {'G52SEC', oMdlSel2:GetValue( 'G52SEC' )})
				aAdd(aSeek, {'G52SECINI', oMdlSel2:GetValue( 'G52SECINI' )})
				aAdd(aSeek, {'G52SECFIM', oMdlSel2:GetValue( 'G52SECFIM' )})
				
			EndIf
			
			// acha o horario pai no grid da direita e transfere os marcados na frequencia
			If ( oMdlSel1:SeekLine(aSeek) )
									
				If oMdlSel2:GetValue( 'GID_SEG' )
					oMdlSel1:LoadValue("GID_SEG",oMdlSel2:GetValue( 'GID_SEG' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_TER' )
					oMdlSel1:LoadValue("GID_TER",oMdlSel2:GetValue( 'GID_TER' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_QUA' )
					oMdlSel1:LoadValue("GID_QUA",oMdlSel2:GetValue( 'GID_QUA' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_QUI' )
					oMdlSel1:LoadValue("GID_QUI",oMdlSel2:GetValue( 'GID_QUI' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_SEX' )
					oMdlSel1:LoadValue("GID_SEX",oMdlSel2:GetValue( 'GID_SEX' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_SAB' )
					oMdlSel1:LoadValue("GID_SAB",oMdlSel2:GetValue( 'GID_SAB' ) )
				Endif
				
				If oMdlSel2:GetValue( 'GID_DOM' )
					oMdlSel1:LoadValue("GID_DOM",oMdlSel2:GetValue( 'GID_DOM' ) )
				Endif
			EndIf 									

			//deleta a linha do grid lado esquerdo
			If oMdlSel2:Length() == 1
				oView:GetModel('SELECAO2'):SetNoInsertLine(.F.)
				nNewLine := oMdlSel2:AddLine()
				oMdlSel2:LineShift(1,nNewLine)
				oView:GetModel('SELECAO2'):SetNoInsertLine(.T.)
				//deleta novamente
				For nI := oMdlSel2:Length() to  1 Step -1
					oMdlSel2:Goline(nI)
					lDelButton := .T.
					oMdlSel2:DeleteLine(.T.,.T.)
				Next				
				//tira o delete da linha em branco
				oMdlSel2:UnDeleteLine()
				oMdlSel2:LoadValue("GID_NLINHA",'' )
			ElseIf oMdlSel2:GetLine() <> oMdlSel2:Length()
				nlinhaSel2 := oMdlSel2:GetLine()
				
				oMdlSel2:LineShift(oMdlSel2:GetLine(),oMdlSel2:Length())
				//deleta novamente
				lDelButton := .T.					
				oMdlSel2:DeleteLine(.T.,.T.)
				If nlinhaSel2 <> 1
					oMdlSel2:LineShift( oMdlSel2:Length(),nlinhaSel2)
				Else
					For nI := 1 to oMdlSel2:Length()
						If nI <> oMdlSel2:Length()
							oMdlSel2:LineShift( nI,nI+1)
						Endif
					Next nI
				Endif
			Else
				lDelButton := .T.	
				oMdlSel2:DeleteLine(.T.,.T.)
			Endif
			oView:Refresh( 'V_SELECAO'	)
			oView:Refresh( 'V_SELECIONADO'	)
			oMdlSel2:GoLine(oMdlSel2:GetLine())
		EndIf
		
	Else
		FwAlertHelp(STR0015,STR0016) // "Atenção","Este botão só funciona quando está posicionado no grid da direita"	
	Endif
														
ElseIf nBt == 3  // Botão 3 move todos para lado direito novamente (devolve os marcados na frequencia)
	
	If  cGridFocus == 'V_SELECIONADO'
		
		For nX:= 1 To oMdlSel2:Length()
		
			oMdlSel2:GoLine(nX)
			
			If !oMdlSel2:IsDeleted()
				
				aSeek := {}
			
				If ( oMdlSel2:GetValue("G52SEC") <> "1" )
					
					aAdd(aSeek,{'GID_COD', oMdlSel2:GetValue( 'GID_COD' )})
					aAdd(aSeek,{'GID_HORCAB', oMdlSel2:GetValue( 'GID_HORCAB' )})					
			
				Else
					
					aAdd(aSeek, {'GID_COD', oMdlSel2:GetValue( 'GID_COD' )})
					aAdd(aSeek, {'G52SEC', oMdlSel2:GetValue( 'G52SEC' )})
					aAdd(aSeek, {'G52SECINI', oMdlSel2:GetValue( 'G52SECINI' )})
					aAdd(aSeek, {'G52SECFIM', oMdlSel2:GetValue( 'G52SECFIM' )})
					
				EndIf
				
				// acha o horario no grid da direita e transfere os marcados na frequencia
				If oMdlSel1:SeekLine(aSeek)
					
					If oMdlSel2:GetValue( 'GID_SEG' )
						oMdlSel1:LoadValue("GID_SEG",oMdlSel2:GetValue( 'GID_SEG' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_TER' )
						oMdlSel1:LoadValue("GID_TER",oMdlSel2:GetValue( 'GID_TER' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_QUA' )
						oMdlSel1:LoadValue("GID_QUA",oMdlSel2:GetValue( 'GID_QUA' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_QUI' )
						oMdlSel1:LoadValue("GID_QUI",oMdlSel2:GetValue( 'GID_QUI' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_SEX' )
						oMdlSel1:LoadValue("GID_SEX",oMdlSel2:GetValue( 'GID_SEX' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_SAB' )
						oMdlSel1:LoadValue("GID_SAB",oMdlSel2:GetValue( 'GID_SAB' ) )
					Endif
					
					If oMdlSel2:GetValue( 'GID_DOM' )
						oMdlSel1:LoadValue("GID_DOM",oMdlSel2:GetValue( 'GID_DOM' ) )
					Endif
				Endif													
			Endif
		Next nI
		
		oView:GetModel('SELECAO2'):SetNoInsertLine(.F.)
		nNewLine := oMdlSel2:AddLine()
		oMdlSel2:LineShift(1,nNewLine)
		oView:GetModel('SELECAO2'):SetNoInsertLine(.T.)
		//deleta novamente
		For nI := oMdlSel2:Length() to  1 Step -1
			oMdlSel2:Goline(nI)
			lDelButton := .T.
			oMdlSel2:DeleteLine(.T.,.T.)
		Next				
		//tira o delete da linha em branco
		oMdlSel2:UnDeleteLine()
		oMdlSel2:LoadValue("GID_NLINHA",'' )
	
		oView:Refresh( 'V_SELECAO'	)
		oView:Refresh( 'V_SELECIONADO'	)
	Else
		FwAlertHelp(STR0015,STR0017)	// "Atenção","Este botão só funciona quando está posicionado no grid da esquerda"
	Endif
	
Endif

Return(lRet) 

/*/{Protheus.doc} LoadVSel
Realiza o LoadValue no modelo de dados 
@type function
@author Fernando Amorim(Cafu)
@since 05/07/2017
@version 12.1.16
/*/
Static Function LoadVSel(oModel,oMdlSel1,oMdlSel2,cIdModel,aDados,lLinha)
	
	Local lRet		:= .T.
	Local lFirstDay	:= .f.
	
	Local cHrIni	:= ""
	Local cHrFim	:= ""
	Local cLinha	:= ""
	/*Local cControle	:= ""*/
	Local cPHrCab	:= ""
	Local cPHorFim 	:= ""
	Local nX		:= 0
	Local nPHrIni	:= 0
	Local nPHrFim	:= 0
	Local nLnBef	:= 0
	Local nDia		:= 0
	Local nPLinha	:= 0
	Local nBkpLine	:= 0
	Local nPHrCab	:= 0
	Local nPHorFim 	:= 0
	
	Local oStru		:= oMdlSel2:GetStruct()
	
	Default lLinha	:= .F.

	If lLinha
		
		oView	 := GA408GetView("GTPA408B")
		oView:GetModel('SELECAO2'):SetNoInsertLine(.F.)
		
		If oMdlSel2:CanInsertLine()
		
			If  !oMdlSel2:IsEmpty() .and. !( oMdlSel2:Length() == 1 .and. Empty(oMdlSel2:GetValue( 'GID_LINHA' )))
		
				If oMdlSel2:Length() == oMdlSel2:AddLine()
					Return .F.
				EndIf
			
			Endif
		Else
			MsgInfo(STR0018 + oMdlSel2:GetId() ) // 'Modelo não permite incluir Linhas: '
			Return .F.
		EndIf
		
	EndIf
	
	oView:GetModel('SELECAO2'):SetNoInsertLine(.T.)
	
	For nX := 1 To Len( aDados )
		
		// Verifica se os campos passados existem na estrutura do modelo
		If oStru:HasField( aDados[nX][1] )
		
			If !( lRet := oModel:LoadValue(cIdModel, aDados[nX][1], aDados[nX][2] ) )
				lRet := .F.
				Exit
			EndIf
			
		EndIf
		
		If ( lRet )
			
			nPHrIni	:= aScan(aDados, {|x| alltrim(x[1]) == "G52HRSDGR"}) 
			nPHrFim	:= aScan(aDados, {|x| alltrim(x[1]) == "G52HRCHGR"})
			nPLinha := aScan(aDados, {|x| alltrim(x[1]) == "GID_LINHA"})
			nPHrCab := aScan(aDados, {|x| alltrim(x[1]) == "GID_HORCAB"})
			nPHorFim := aScan(aDados, {|x| alltrim(x[1]) == "GID_HORFIM"})
			
			If ( nPHrIni > 0 )
				cHrIni		:= aDados[nPHrIni,2]
			EndIf
			
			If ( nPHrFim > 0 )
				cHrFim		:= aDados[nPHrFim,2]
			EndIf	
			
			If ( nPLinha > 0 )
				cLinha 		:= aDados[nPLinha,2]						
			EndIf
			
			If  ( nPHrCab > 0 ) 
				cPHrCab		:= aDados[nPHrCab,2]
			EndIf
			
			If ( nPHorFim  > 0 )
				cPHorFim	:= aDados[nPHorFim,2]
			EndIf
			
			nBkpLine := oModel:GetModel("SELECAO2"):GetLine()
			
			oModel:GetModel("SELECAO2"):GoLine(1)
			
			//Pesquisa se está se repetindo o primeiro dia
			If ( oModel:GetModel("SELECAO2"):SeekLine({{"G52DIA",1},{"GID_LINHA",cLinha},{"GID_HORCAB",cPHrCab}}) )
				lFirstDay := .t.
			EndIF
			
			oModel:GetModel("SELECAO2"):GoLine(nBkpLine)
			
			If ( lFirstDay .Or. oModel:GetModel("SELECAO2"):GetLine() == 1 )
				
				nDia := 1
				
				/*If ( oModel:GetModel("SELECAO2"):GetLine() == 1 )	
					nDiaContr := 1	
				EndIf*/
				
			Else
				
				nLnBef := (oModel:GetModel("SELECAO2"):GetLine() - 1)
				
				nDia 		:= oModel:GetModel("SELECAO2"):GetValue("G52DIA",nLnBef)
				//nDiaContr	:= Val(SubStr(oModel:GetModel("SELECAO2"):GetValue("CONTROLE",nLnBef),1,At(".",oModel:GetModel("SELECAO2"):GetValue("CONTROLE",nLnBef))))
				
					
				If ( Val(cHrIni) < Val(oModel:GetModel("SELECAO2"):GetValue("G52HRCHGR",nLnBef)) .Or.;
					 ( Val(cHrIni) > Val(oModel:GetModel("SELECAO2"):GetValue("G52HRCHGR",nLnBef)) .And.;
					   Val(oModel:GetModel("SELECAO2"):GetValue("G52HRCHGR",nLnBef)) < Val(oModel:GetModel("SELECAO2"):GetValue("G52HRSDGR",nLnBef)) ) )
					   
					 nDia++
					 //nDiaContr++
				
				EndIf	   
													
			EndIf
					
			lRet := oModel:GetModel("SELECAO2"):LoadValue("G52DIA",nDia) /*.And.;
					oModel:GetModel("SELECAO2"):LoadValue("CONTROLE",StrZero(nDiaContr,3)+"."+StrZero(nDia,2))*/
			
			If ( !lRet )
				Exit
			EndIf
				 
		EndIf
		
	Next
		
Return lRet

/*/{Protheus.doc} G408BVldSelected
Valida para linha não ser deletada 
@type function
@author Fernando Amorim(Cafu)
@since 06/07/2017
@version 12.1.16
/*/
Static Function G408BVldSelected(oModelGrid, nLine, cAction, cField, xValue, xOldValue)

Local lRet 		:= .T.
Local lSection	:= .t.
Local lHasPair	:= .f.
Local cFldWeek	:= ""
Local nX		:= 0
Local nCntOff	:= 0
Local aSeek		:= {}
Local oModel	:= GA408GetModel("GTPA408B")	

If ( cAction  ==  "CANSETVALUE" )
	
	If ( cField == "G52DIA" )
		lRet :=  nLine == oModelGrid:Length()	
	EndIf
	
ElseIf cAction == "DELETE"  .AND. !lDelButton

	lRet := .F.	

	oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0020,STR0021) // "DELETE",'Não é possível deletar linhas'
	
	lDelButton := .F.

ElseIf ( cAction == "SETVALUE" )
	
	If ( cField == "GID_COD" .And. oModelGrid:GetId() == "SELECAO2" )
		
		/*aHora := G408ExistHoraEscala(xValue,oModelGrid:GetModel():GetModel("CABESC"):GetValue("ESCALA"))
		
		If ( !aHora[1] )
			lRet := .f.
			oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0048 + aHora[2] + " - " + aHora[3] + ".",STR0049) //"Este horário já existe em outra escala, "#"Selecione outro horário"
		EndIf*/
	
	ElseIf ( cField == "G52DIA" )
		
		lRet := xValue > 0 .And. xValue <= G408BMaxVlFld(oModelGrid,"G52DIA") + 1
		
		If ( !lRet )
			oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0079,STR0080) //"Foi informado um dia igual a 0 (zero) ou maior que último dia + 1."	// "Informe um dia maior que 0 (zero) e que seja no máximo um dia maior que o último."
		EndIf
		
	ElseIf ( Substr(cField,5) $ "SEG|TER|QUA|QUI|SEX|SAB|DOM" )
		
		If ( !xValue )
			
			For nX := 1 To 7
				
				cFldWeek := "GID_" + G408RetDayOfWeek(,nX)
				
				If ( cField == cFldWeek )
					nCntOff++
				Else
					If ( !oModelGrid:GetValue(cFldWeek) )
						nCntOff++
					EndIf
				EndIf 
				
			Next nI
			
			If ( nCntOff == 7 )
				
				lRet := .f.
				
				oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0081,STR0082) // "Desmarcar este dia deixará o horário sem frequência"	// "Não pode haver um horário selecionado sem nenhuma frequência marcada" 
				
			EndIf	
				
		Endif
		
		If ( lRet )
		
			//Efetua a validação da frequencia digitada
			GID->(DbSetOrder(1))
			
			//Valida com o registro no banco de dados
			If GID->(DbSeek(xFilial('GID')+oModelGrid:GetValue("GID_COD",nLine)))
			
				If !GID->&(cField)
					lRet := .F.
					oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0022,STR0023) //'FREQUÊNCIA','Esse dia não pertence a frequência deste horário.') 
				EndIf
		
			Endif
		
		EndIf
		
		IF ( lRet )
			
			lSection := oModelGrid:GetValue("G52SEC") == "1"
			
			For nX := 1 To oModelGrid:Length()
		
				If ( nLine <> nX )
					
					If ( xValue .And. !lSection )
 	
					 	If ( oModelGrid:GetValue("GID_COD",nX) == oModelGrid:GetValue("GID_COD",nLine) .and.; 
					 		oModelGrid:GetValue("GID_HORCAB",nX) == oModelGrid:GetValue("GID_HORCAB",nLine))
					 		
					 		lHasPair := .t.
					 		 
						EndIf 		
					 		 
					 ElseIf ( xValue .And. lSection ) 
					 	
					 	If ( oModelGrid:GetValue("G52SEC",nX) == "1" )
					 	
						  	If ( oModelGrid:GetValue("GID_COD",nX) == oModelGrid:GetValue("GID_COD",nLine) .And.;
						  		oModelGrid:GetValue("G52SECINI",nX) == oModelGrid:GetValue("G52SECINI",nLine) .And. ;
						  		oModelGrid:GetValue("G52SECFIM",nX) == oModelGrid:GetValue("G52SECFIM",nLine) )
						  		
						  		lHasPair := .t.
						  		
						  	EndIf	
						
						EndIf
					
					EndIf
					
					If ( lHasPair .And. oModelGrid:GetValue(cField,nX) ) 
				
						lRet := .F.
						oModel:SetErrorMessage("SELECAO2",cField,"SELECAO2",cField,STR0022,STR0024) //'FREQUÊNCIA','Esse dia da frequência deste horario já está em uso nesta escala.')
						
						Exit

					Endif
					
				EndIf
	
			Next nX
	
		EndIf
		
		//Validar aqui o verfreq, será que continuo usando a função?
		If ( lRet )
				
			If ( oModelGrid:GetValue("G52SEC") <> "1" )
				
				aAdd(aSeek,{'GID_COD', oModelGrid:GetValue( 'GID_COD' )})
				aAdd(aSeek,{'GID_HORCAB', oModelGrid:GetValue( 'GID_HORCAB' )})					
		
			Else
				
				aAdd(aSeek, {'GID_COD', oModelGrid:GetValue( 'GID_COD' )})
				aAdd(aSeek, {'G52SEC', oModelGrid:GetValue( 'G52SEC' )})
				aAdd(aSeek, {'G52SECINI', oModelGrid:GetValue( 'G52SECINI' )})
				aAdd(aSeek, {'G52SECFIM', oModelGrid:GetValue( 'G52SECFIM' )})
				
			EndIf
			
			If ( oModel:GetModel("SELECAO1"):SeekLine(aSeek) )
			
				oModel:GetModel("SELECAO1"):LoadValue(cField,!xValue )
			
				oView		:= GA408GetView("GTPA408B")
				
				oView:Refresh( 'V_SELECAO'	)
		
			Endif
			
		EndIf
		
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} G408BCarga   
    Executa o bloco de carga de dados dos grids SELECAO1 e SELECAO2
    @type  Static Function
    @author Fernando Amorim(Cafu)/Fernando Radu
    @since 27/07/2017
    @version version
    @param oSubMdl, objeto, instância da Classe FwFormGridModel
    @return aReg, array, Array de retorno da carga para o grid
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408BCarga(oSubMdl)

Local oMdl408E	:= Nil
Local oMdl408A	:= Nil
Local oMdl408B 	:= Nil
Local oStruGZQ 	:= Nil

Local aReg  := {}
Local aFlds := {}
Local aAux  := {}

Local cAliasTab := ""
Local cFilSeek	:= ""
Local cEscala	:= ""
Local cSeqEsc 	:= ""
	
Local cChave	:= ""

Local nI    := 0
Local nX	:= 0
Local nLine	:= 0

aFlds := oSubMdl:GetStruct():GetFields()

If ( oSubMdl:GetId() == "SELECAO1" )

	cAliasTab := GA408ResultSet()

	While ( (cAliasTab)->(!Eof()) )
				
		For nI := 1 to Len(aFlds)

			If ( aFlds[nI,3] == "GID_NLINHA" )
				aAdd(aAux,Rtrim((cAliasTab)->GID_DSCORI)+'/'+Rtrim((cAliasTab)->GID_DSCDES))
			ElseIf ( aFlds[nI,3] == "LEGENDA" )	
			
				If ( G408IsHoraEscala((cAliasTab)->GID_COD)[1] )
					aAdd(aAux,"BR_VERDE")
				Else
					aAdd(aAux,"BR_AMARELO")
				EndIf
				
			ElseIf ( aFlds[nI,3] == "G52HRSDGR"	)		 		
				aAdd(aAux,GA408Garagem((cAliasTab)->GID_LINHA,(cAliasTab)->GID_HORCAB,"S"))
			ElseIf ( aFlds[nI,3] == "G52HRCHGR" )
				aAdd(aAux,GA408Garagem((cAliasTab)->GID_LINHA,(cAliasTab)->GID_HORFIM,"C"))
			ElseIf ( aFlds[nI,3] == "G52SEC" )
				aAdd(aAux,"2")
			ElseIf ( (cAliasTab)->(FieldPos(aFlds[nI,3])) > 0 )
				aAdd(aAux,(cAliasTab)->&(aFlds[nI,3]))
			Else
				aAdd(aAux,GTPCastType(,aFlds[nI,4]))
			EndIf

		Next nI
		
		aAdd(aReg,{0,aClone(aAux)})
		aAux := {}
		
		(cAliasTab)->(DbSkip())
		
	EndDo

ElseIf ( oSubMdl:GetId() == "SELECAO2" )	//SELCAO2
	
	oMdl408A	:= GA408GetModel("GTPA408A")
	oMdl408E 	:= FwLoadModel("GTPA408E")
	
	oMdl408E:SetOperation(MODEL_OPERATION_VIEW)

	G52->(DbSetOrder(1))

	If ( G52->(DbSeek(xFilial("G52") + G52->G52_CODIGO )) )

		oMdl408E:Activate()

		aReg := G408BSetFromTo(oMdl408E,oSubMdl:GetModel():GetModel("SELECAO1"))
		
		oMdl408E:DeActivate()
		oMdl408E:Destroy()

	EndIf	

ElseIf ( oSubMdl:GetId() == "GZQDETAIL" )
	
	oMdl408B 	:= GA408GetModel("GTPA408B")
	oStruGZQ 	:= oMdl408B:GetModel("GZQDETAIL"):GetStruct()
	 
	cFilSeek	:= xFilial("GZQ")
	cEscala		:= oMdl408B:GetModel("CABESC"):GetValue("ESCALA")
	
	nLine		:= oMdl408B:GetModel("SELECAO2"):GetLine()
	
	For nI := 1 To oMdl408B:GetModel("SELECAO2"):Length()
		
		cSeqEsc := oMdl408B:GetModel("SELECAO2"):GetValue("G52SEQUEN",nI)
	
		cChave := PadR(cFilSeek,TamSx3("GZQ_FILIAL")[1])
		cChave += PadR(cEscala,TamSx3("GZQ_ESCALA")[1])
		cChave += PadR(cSeqEsc,TamSx3("GZQ_SEQESC")[1])
		
		GZQ->(DbSetOrder(1))
	
		If ( GZQ->(DbSeek(cChave)) )
		
			While ( GZQ->(!Eof()) .And.; 
					Alltrim(GZQ->(GZQ_FILIAL+GZQ_ESCALA+GZQ_SEQESC)) == Alltrim(cFilSeek+cEscala+cSeqEsc) )
			
				For nX := 1 to GZQ->(FCount())
				
					If ( oStruGZQ:HasField(GZQ->(FieldName(nX))) )
						aAdd(aAux,GZQ->&(FieldName(nX)))
					Else
						aAdd(aAux,GTPCastType(,ValType(GZQ->&(FieldName(nX)))))
					EndIf
				
				Next nX
		
				aAdd(aReg,{GZQ->(Recno()),aClone(aAux)})
				aAux := {}
				
				GZQ->(DbSkip())
					
			End While
		
		EndIf	
	
	Next nI
	
	oMdl408B:GetModel("SELECAO2"):GoLine(nLine)
		
EndIf	

Return(aReg)

/*/{Protheus.doc} GetLocIni
pega o trecho inicial
@type function
@author Fernando Amorim(Cafu)
@since 12/07/2017
@version 12.1.16
/*/
Static Function GetLocIni(oMdlSel2,cCodHor)
Local cAliasLini	:= GetNextAlias()
Local cSeqIni		:= ''

oMdlSel2:SeekLine({{'GID_COD',cCodHor}})

If ( oMdlSel2:GetValue("G52SEC") <> "1" )
	BeginSQL Alias cAliasLini
	
		SELECT  MIN(GIE.GIE_SEQ) GIE_SEQ
		FROM %Table:GIE% GIE
		WHERE GIE_FILIAL = %xFilial:GIE%
		AND GIE_CODGID = %Exp:cCodHor%
		AND %NotDel%
		
	EndSQL
			
	IF !(cAliasLini)->(EOF())
	
		cSeqIni := (cAliasLini)->GIE_SEQ
			
	Endif
	(cAliasLini)->(DbCloseArea())
Else

	BeginSQL Alias cAliasLini
	
		SELECT  
			MIN(GIE.GIE_SEQ) GIE_SEQ
		FROM 
			%Table:GIE% GIE
		WHERE 
			GIE_FILIAL = %xFilial:GIE%
			AND GIE_CODGID = %Exp:cCodHor%
			AND GIE_SEQ	> %Exp:oMdlSel2:GetModel():GetModel("GZQDETAIL"):GetValue("GZQ_SEQSER",oMdlSel2:GetModel():GetModel("GZQDETAIL"):Length()) %
			AND %NotDel%
		
	EndSQL
			
	IF !(cAliasLini)->(EOF())
	
		cSeqIni := (cAliasLini)->GIE_SEQ
			
	Endif
	(cAliasLini)->(DbCloseArea())

Endif
Return cSeqIni

/*/{Protheus.doc} GetLocFim
pega o trecho inicial
@type function
@author Fernando Amorim(Cafu)
@since 12/07/2017
@version 12.1.16
/*/
Static Function GetLocFim(oModel)

Local cAliasLFim	:= GetNextAlias()
Local cSeqFim		:= ''

Local nLast			:= 0

If ( oModel:GetValue("G52SEC") <> "1" )

	BeginSQL Alias cAliasLFim
	
		SELECT  
			MAX(GIE.GIE_SEQ) GIE_SEQ
		FROM 
			%Table:GIE% GIE
		WHERE 
			GIE_FILIAL = %xFilial:GIE%
			AND GIE_CODGID = %Exp:oModel:GetValue("GID_COD")%
			AND %NotDel%
		
	EndSQL
	
	IF !(cAliasLFim)->(EOF())
	
		cSeqFim := (cAliasLFim)->GIE_SEQ
			
	Endif
	
	(cAliasLFim)->(DbCloseArea())

Else

	If ( !oModel:GetModel():GetModel("GZQDETAIL"):IsEmpty() )
	
		nLast := oModel:GetModel():GetModel("GZQDETAIL"):Length()
			
		cSeqFim := oModel:GetModel():GetModel("GZQDETAIL"):GetValue("GZQ_SEQSER",nLast)
	
	EndIf

EndIf		

Return cSeqFim

/*/{Protheus.doc} G408BSetFromTo   
    Esta função é chamada pela função G408BCarga() para carregar os dados no grid SELECAO2.
	Este grid será carregado, de acordo com as informações do banco, dos registro da tabela
	G52
    @type  Function
    @author Fernando Radu Muscalu
    @since 27/07/2017
    @version version
    @param	oMdlFrom, objeto, instância da classe FwFormGridModel. Este submodelo
				é o grid proveniente do MVC GTPA508E, dados da tabela G52
			oMdlSel1, objeto, instância da classe FwFormGridModel. Submodelo de SELECAO1
    @return aLine, array, Array de retorno da carga para o grid
			
    @example
    (examples)
    @see (links_or_references)
/*/
Function G408BSetFromTo(oMdlFrom,oMdlSel1)

Local oMdlTo
Local oView		:= FwViewActive()
Local aFromTo	:= GA408GIDG52()
Local aLine		:= {}	//linha do registro a ser retornado no bLoad do Modelo
Local aLinha	:= {}	//Linha relacionada ao serviço (GTP)
Local aFldStr	:= {}
Local aAux		:= {}
Local aData		:= {}
Local aSeek		:= {}
Local nI		:= 0	
Local nX		:= 0
Local nP		:= 0
Local nOpera	:= GA408GetOperation()
Local lLocManutOn	:= .f.
Local xData
Local cLocIni	:= ""
Local cLocFim	:= ""
Local cDscIni	:= ""
Local cDscFim	:= ""

oMdlTo	:= FwLoadModel("GTPA408B")

aFldStr := aClone(oMdlTo:GetModel("SELECAO2"):GetStruct():GetFields())

If ( nOpera <> 1 )

	//Efetua a carga de SELECAO2
	For nI := 1 to oMdlFrom:GetModel("G52DETAIL"):Length()
		
		//Carrega o Secionamento
		If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEC",nI) == "1" )
			
			aData := G408BLoadSec(oMdlFrom:GetModel("G52DETAIL"),nI)
			
			nP := aScan(aData,{|x| x[2] == oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEQUEN",nI) })
			
			If ( nP > 0 )
			
				aSeek := {}
				aAdd(aSeek,{"GID_COD",oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SERVIC",nI)})
				aAdd(aSeek,{"ORIGINLINE",0})
				
				If ( oMdlSel1:SeekLine(aSeek) )
					
					GID->(DbSetOrder(1)) // GID_FILIAL+GID_COD
					
					If ( GID->(DbSeek(xFilial("GID") + oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SERVIC",nI))) )
						G408ScattServ()
					EndIf
									
				EndIf
				
				aUpd	:= {{"GIE_IDLOCP","GIE_IDLOCD"}}
				aSeek	:= {}
				
				aAdd(aSeek,{"GIE_CODGID",oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SERVIC",nI)})
				aAdd(aSeek,{"GIE_SEQ",aData[nP,4]})				
				
				If ( GTPSeekTable("GIE",aSeek,aUpd) )		
					
					cLocIni := aUpd[2,1]	
					cLocFim	:= aUpd[2,2]
					
					cDscIni	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+cLocIni,"GI1_DESCRI"))
					cDscFim	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+cLocFim,"GI1_DESCRI"))
					 
				EndIf
				
				aSeek := {}
			
				aAdd(aSeek,{"GID_COD",oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SERVIC",nI)})
				aAdd(aSeek,{"G52SECINI",cLocIni})
				aAdd(aSeek,{"G52SECFIM",cLocFim})
				
				If ( oMdlSel1:SeekLine(aSeek) ) 
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEGUND",nI) )
						oMdlSel1:LoadValue("GID_SEG",.F.)
					EndIf	
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_TERCA",nI) )
						oMdlSel1:LoadValue("GID_TER",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_QUARTA",nI) )
						oMdlSel1:LoadValue("GID_QUA",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_QUINTA",nI) )
						oMdlSel1:LoadValue("GID_QUI",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEXTA",nI) )
						oMdlSel1:LoadValue("GID_SEX",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SABADO",nI) )
						oMdlSel1:LoadValue("GID_SAB",.F.)
					EndIf
					
				EndIf
					
			EndIf
			
		
		Else
			
			TPNomeLinh(oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_LINHA",nI),aLinha,oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SENTID",nI))
			
			If ( Len(aLinha) > 0 )
			
				cDscIni := Alltrim(aLinha[1,2][1,2])
				cDscFim := Alltrim(aLinha[1,2][2,2])
				
			EndIf
			
			aSeek := {}
			
			aAdd(aSeek,{"GID_COD",oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SERVIC",nI)})
			
			If ( oMdlSel1:SeekLine(aSeek) ) 
				
				If ( !(oMdlSel1:GetValue("G52SEC") $ "1|3" ) )
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEGUND",nI) )
						oMdlSel1:LoadValue("GID_SEG",.F.)
					EndIf	
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_TERCA",nI) )
						oMdlSel1:LoadValue("GID_TER",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_QUARTA",nI) )
						oMdlSel1:LoadValue("GID_QUA",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_QUINTA",nI) )
						oMdlSel1:LoadValue("GID_QUI",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEXTA",nI) )
						oMdlSel1:LoadValue("GID_SEX",.F.)
					EndIf
					
					If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SABADO",nI) )
						oMdlSel1:LoadValue("GID_SAB",.F.)
					EndIf
					
				EndIf 
				
			EndIf
				
		EndIf		
		
		If ( !lLocManutOn )
		
			If ( ValType(oView) == "O" .And. ( oView:GetModel():GetId() == "GTPA408B" .And. oView:GetModel():IsActive()) )
			
				If ( oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_PMANUT",nI) == "1" )
					
					TPNomeLinh(oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_LINHA",nI),aLinha,oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SENTID",nI))
				
					oView:GetModel("CABESC"):LoadValue("LOCALMANUT",Alltrim(aLinha[1,2][2,1]))	
					oView:GetModel("CABESC"):RunTrigger("LOCALMANUT")
					lLocManutOn := .t.
					
				EndIf
			
			EndIf
		
		EndIf
		
		For nX := 1 to Len(aFldStr)
			
			nP := aScan(aFromTo, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(aFldStr[nX,3])) })
			
			If ( nP > 0 .And. aFromTo[nP,2] <> "NO" .And. aFldStr[nX,3] <> "GID_NLINHA" )
				aUpd := GA408RetDePara(aFromTo[nP,2], oMdlFrom:GetModel("G52DETAIL"), nI)
			ElseIf ( nP > 0 .And. aFromTo[nP,1] == "GID_NLINHA" )
				
				aUpd := {aFromTo[nP,1], Rtrim(cDscIni) + '/' + Rtrim(cDscFim) }
			
			ElseIf ( aFldStr[nX,3] == "G52HRSDGR" )
				aUpd := {"G52HRSDGR",GA408Garagem(oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_LINHA",nI),oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_HRSDRD",nI),"S")}
			ElseIf ( aFldStr[nX,3] == "G52_HRCHGR" )
				aUpd := {"G52HRSDGR",GA408Garagem(oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_LINHA",nI),oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_HRCHGR",nI),"C")}
			ElseIf ( aFldStr[nX,3] == "G52SECINI" .And. oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEC",nI) == "1" )
				aUpd := {"G52SECINI",cLocIni}
			ElseIf ( aFldStr[nX,3] == "G52SECFIM" .And. oMdlFrom:GetModel("G52DETAIL"):GetValue("G52_SEC",nI) == "1" )
				aUpd := {"G52SECFIM",cLocFim}
			ElseIf aFldStr[nX,3] == "GID_MSBLQL"
				 aUpd := {"G52SECFIM",POSICIONE("GID",1,aAux[1]+aAux[2]+aAux[3],"GID_MSBLQL")}
			EndIf
					
			If ( Len(aUpd) > 0 )
				xData := aUpd[2]
			EndIf
			
			If ( ValType(xData) == "U" .Or. ( Len(aUpd) > 0 .And. ValType(aUpd[1]) == "U" .Or. ( ValType(aUpd[1]) <> "U" .And. aUpd[1] == "NO" ) ) )
				aAdd(aAux,GTPCastType(,aFldStr[nX,4]))
			Else
				aAdd(aAux,xData)
			EndIf	 
		
		Next nX		

		aAdd(aLine,{0,aClone(aAux)})
		aAux := {}

	Next nI

Else

	For nX := 1 to Len(aFldStr)
		aAdd(aAux,GTPCastType(,aFldStr[nX,4]))
	Next nX
	
	aAdd(aLine,{0,aClone(aAux)})
	aAux := {}
	
EndIf

Return(aLine)

/*/{Protheus.doc} GA408DblClick()
	Função que mostra a dialog de legenda
		
	@type  Static Function
	@author Totvs
	@since 28/02/2018
	@version version
	
	@param	oView,	objeto, instância da classe FwFormView
	@return nil
							 	
	@example
	GA408DblClick(oView)
	
	@see (links_or_references)
/*/
Static Function GA408DblClick(oView)

Local aHora 	:= G408IsHoraEscala(oView:GetModel("SELECAO1"):GetValue("GID_COD"))
Local aLegend	:= {{ "BR_VERDE", STR0050 + IIf(!Empty(aHora[2]), ": " + Alltrim(aHora[2] + "-" + aHora[3]),"") },;	//"Horário escalado"
 					{ "BR_AMARELO", STR0051}}	//"Horário não escalado."

BrwLegenda(STR0083,STR0084,aLegend)	// "Legenda"	// "Horários" 

Return()

/*/{Protheus.doc} GA408VldHour()
	Função que valida horários de saída garagem e chegada garagem
		
	@type  Static Function
	@author Totvs
	@since 28/02/2018
	@version version
	
	@param	oSubMdl,	objeto, instância da classe FwFormGridModel
			cField, 	caractere, id do campo a ser validado
			xNewValue,	qualquer, conteúdo a ser avaliado
			nLine,		numérico, linha posicionada do Grid
			xOldValue,	qualquer, conteúdo anterios do campo (cField)
	@return lRet,	lógico, .t. - validação ok
							 	
	@example
	xRet := GA408VldHour(oSubMdl,cField,xNewValue,nLine,xOldValue)
	
	@see (links_or_references)
/*/
Static Function GA408VldHour(oSubMdl,cField,xNewValue,nLine,xOldValue)

Local lRet	:= .t.

Local cMsgProb	:= ""
Local cMsgSolu	:= ""
Local cTitle	:= ""

If ( !Empty(xNewValue) ) 

	lRet := GTTimeValid(xNewValue,.t.,.t.)
	
	If ( lRet )
	
		If ( cField == "G52HRSDGR" .And. Val(xNewValue) > Val(oSubMdl:GetValue("GID_HORCAB")) )
			
			lRet := .f.
			
			cMsgProb	:= STR0052	//"A hora informada não pode ser maior que a Hora Início "
			cMsgSolu	:= STR0053	//"Informe um horário igual ou inferior"
			cTitle		:= STR0054	//"Hora Incorreta!"
			
		ElseIf ( cField == "G52HRCHGR" .And. Val(xNewValue) < Val(oSubMdl:GetValue("GID_HORFIM")) )
		
			lRet := .f.
		
			cMsgProb	:= STR0055	//"A hora informada não pode ser menor que a Hora Fim "
			cMsgSolu	:= STR0056	//"Informe um horário igual ou superior"
			cTitle		:= STR0054	//"Hora Incorreta!"
		
		EndIf
		
		If ( !lRet )
			FWAlertHelp(cMsgProb,cMsgSolu,cTitle)
		EndIf	
		
	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GA408VldManut()
	Função que valida o local de manutenção dos veículos
		
	@type  Static Function
	@author Totvs
	@since 22/02/2018
	@version version
	
	@param	oSubMdl,	objeto, instância da classe FwFormGridModel
			cField, 	caractere, id do campo a ser validado
			xNewValue,	qualquer, conteúdo a ser avaliado
			nLine,		numérico, linha posicionada do Grid
			xOldValue,	qualquer, conteúdo anterios do campo (cField)
	@return lRet,	lógico, .t. - validação ok
							 	
	@example
	xRet := GA408VldManut(oSubMdl,cField,xNewValue,nLine,xOldValue)
	
	@see (links_or_references)
/*/
Static Function GA408VldManut(oSubMdl,cField,xNewValue,nLine,xOldValue)

Local lRet	:= .F.
Local aLinha	:= {}
Local cMsgProb	:= ""
Local cMsgSolu	:= ""
Local cTitle	:= ""
Local nI		:= 0
Local oSel2		:= oSubMdl:GetModel():GetModel("SELECAO2")

If ( cField == "LOCALMANUT" )

	GI1->(DbSetOrder(1))

	If ( GI1->(DbSeek(xFilial("GI1") + xNewValue)) )

		For nI := 1 to oSel2:Length()
			
			If ( oSel2:GetValue("G52SEC",nI) <> "1" )	//para não secionado
			
				TPNomeLinh(oSel2:GetValue("GID_LINHA",nI),aLinha,oSel2:GetValue("GID_SENTID",nI))
				
				If ( Len(aLinha) > 0 .And. Alltrim(xNewValue) == Alltrim(aLinha[1,2][2,1]) )
					lRet := .t.			
				EndIf	
			
			Else
				lRet := Alltrim(xNewValue) == Alltrim(oSel2:GetValue("G52SECFIM",nI))
			EndIf
			
			If ( lRet )
				Exit
			EndIf	
			
		Next nI
	
		If ( !lRet )
		
			cMsgProb := STR0057	//"Não há localidade de destino, nos horários que foram selecionados, "
			cMsgProb += STR0058	//"que condizem com localidade informada."
			
			cMsgSolu := STR0059	//"Informe uma localidade que exista nos pontos de chegadas (Destino) dos horários selecionados."
			
			cTitle := STR0060	//"Localidade Incorreta!"
		
		Endif
	
	Else
		
		cMsgProb := STR0085		// "Esta localidade não está cadastrada." 
		
		cMsgSolu := STR0086		// "Informe uma localidade que esteja cadastrada."
		
		cTitle := STR0087		// "Registro não encontrado."
		
	EndIf
	
Else
	lRet := .t.
EndIf

If ( !lRet )
	FWAlertHelp(cMsgProb,cMsgSolu,cTitle)
EndIf

Return(lRet)

/*/{Protheus.doc} G408BMaxVlFld()
	Função que retorna o valor máximo do campo de um grid
		
	@type  Static Function
	@author Totvs
	@since 22/02/2018
	@version version
	
	@param	oGrid,	objeto, instância da classe FwFormGridModel
			cField, caractere, id do campo a ser pesquisado o seu valor máximo
	
	@return xRet,	qualquer, o maior valor do grid
							 	
	@example
	xRet := G408BMaxVlFld(oGrid,cField)
	
	@see (links_or_references)
/*/
Static Function G408BMaxVlFld(oGrid,cField)

Local xRet

Local aDados := GridToArray(oGrid,{"G52DIA"})

aSort(aDados,,,{|x,y| x[1] > y[1]})

xRet := aDados[1,1]

Return(xRet)

/*/{Protheus.doc} G408FGetFocus()
	Função que retorna qual o Grid (id da View) está posicionado
		
	@type  Function
	@author Totvs
	@since 22/02/2018
	@version version
	
	@param	não há
	
	@return cGridFocus,	caractere, Id da View referente ao Grid que está posicionado
			"V_SELECAO" ou "V_SELECIONADO"		
				 	
	@example
	cGridFocus := G408FGetFocus()
	
	@see (links_or_references)
/*/
Function G408FGetFocus()

Return(cGridFocus)

/*/{Protheus.doc} G408BLoadSec()
	Busca o secionamento de acordo com a sequência da escala de veículo 
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	oGridG52,	objeto, instância da classe FwFormGridModel contendo o objeto do submodelo "G52DETAIL"
			nLine,		numérico, linha posicionada no grid "G52DETAIL"
	
	@return aData,	array, 
				array[1], caractere, código da escala
				array[2], caractere, sequência da escala
				array[3], caractere, código do serviço (horário) do item secionado da sequência da escala	
				array[4], caractere, código do serviço (horário) do item secionado da sequência da escala
				
	@example
	aData := G408BLoadSec(oGridG52,nLine)
	
	@see (links_or_references)
/*/
Static Function G408BLoadSec(oGridG52,nLine)

Local aData	:= {{"GZQ_ESCALA","GZQ_SEQESC","GZQ_SERVIC","GZQ_SEQSER"}}
Local aSeek	:= {{"GZQ_FILIAL",xFilial("GZQ")},;
				{"GZQ_ESCALA",oGridG52:GetValue("G52_CODIGO",nLine)},;
				{"GZQ_SEQESC",oGridG52:GetValue("G52_SEQUEN",nLine)}}

If ( GTPSeekTable("GZQ",aSeek,aData) .And. Len(aData) > 1 )
	
	aDel(aData,1)
	aSize(aData,Len(aData)-1)
	
EndIf

aSort(aData,,,{|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})

Return(aData)

/*/{Protheus.doc} SearchFreqDefault()
	Busca a frequência padrão dos dias do serviço (horário) 
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	cHorário,	caractere, código do serviço (horário)
			
	@return aResultSet,	array,
				array[1]	
					array[1][1], caractere, campo do DOMINGO ("GID_DOM")
					array[1][2], caractere, campo do SEGUNDA ("GID_SEG")
					array[1][3], caractere, campo do TERÇA ("GID_TER")
					array[1][4], caractere, campo do QUARTA ("GID_QUA")
					array[1][5], caractere, campo do QUINTA ("GID_QUI")
					array[1][6], caractere, campo do SEXTA ("GID_SEX")
					array[1][7], caractere, campo do SÁBADO ("GID_SAB")
				array[2]	
					array[2][1], lógico, (.t.) representa a frequência de domingo marcada
					array[2][2], lógico, (.t.) representa a frequência de segunda marcada
					array[2][3], lógico, (.t.) representa a frequência de terça marcada
					array[2][4], lógico, (.t.) representa a frequência de quarta marcada
					array[2][5], lógico, (.t.) representa a frequência de quinta marcada
					array[2][6], lógico, (.t.) representa a frequência de sexta marcada
					array[2][7], lógico, (.t.) representa a frequência de sábado marcada
	
	@example
	aResultSet := SearchFreqDefault(cHorario)
	
	@see (links_or_references)
/*/
Static Function SearchFreqDefault(cHorario,lJaUsados)

Local oMdlSel2		:= GA408GetModel("GTPA408B"):GetModel("SELECAO2") 

Local nLine			:= 0

Local aSeek			:= {}
Local aResultSet 	:= {{"GID_DOM",;
						"GID_SEG",;
						"GID_TER",;
						"GID_QUA",;
						"GID_QUI",;
						"GID_SEX",;
						"GID_SAB"}}

Default lJaUsados := .t.

aAdd(aSeek,{"GID_FILIAL",XFILIAL("GID")})
aAdd(aSeek,{"GID_COD",cHorario})

//Busca as Frequência padrão do horário 
GTPSeekTable("GID",aSeek,aResultSet)

If ( Len(aResultSet) > 1 .and. lJaUsados )

	nLine := oMdlSel2:GetLine()

	aSeek := {}
	
	aAdd(aSeek,{"G52SEC","2"})
	aAdd(aSeek,{"GID_COD",cHorario})
	
	//Verifica se o horário pai, foi selecionado.
	//Desta forma, a frequência que será utilizada pelo secionamento
	//será somente dos dias que não foram marcados  
	If ( oMdlSel2:SeekLine(aSeek) )
		
		If ( aResultSet[2,1] )		
			aResultSet[2,1] := !oMdlSel2:GetValue("GID_DOM")
		EndIf
		
		If ( aResultSet[2,2] )	
			aResultSet[2,2] := !oMdlSel2:GetValue("GID_SEG",nLine)
		EndIf
		
		If ( aResultSet[2,3] )	
			aResultSet[2,3] := !oMdlSel2:GetValue("GID_TER",nLine)
		EndIf
		
		If ( aResultSet[2,4] )
			aResultSet[2,4] := !oMdlSel2:GetValue("GID_QUA",nLine)
		EndIf
		
		If ( aResultSet[2,5] ) 
			aResultSet[2,5] := !oMdlSel2:GetValue("GID_QUI",nLine)
		EndIf
		
		If ( aResultSet[2,6] )	 
			aResultSet[2,6] := !oMdlSel2:GetValue("GID_SEX",nLine)
		EndIf
		
		If ( aResultSet[2,7] )	
			aResultSet[2,7] := !oMdlSel2:GetValue("GID_SAB",nLine)
		EndIf
			
	EndIf
	
	oMdlSel2:GoLine(nLine)
	
EndIf

Return(aResultSet)	

Function G408ServFreqStand(cHorario,lJaUsados)

Default lJaUsados := .f.

Return(SearchFreqDefault(cHorario,lJaUsados))

/*/{Protheus.doc} TurnOffFrequence()
	Desmarca os dias da frequência do horário no Grid "SELECAO1"
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	oMdlSel1,	objeto, instância da classe FwFormGridModel contendo o submodelo do grid "SELECAO1"
			nLine,		numérico, linha posicionada no grid "SELECAO1"
			aFrequence,	array, 
					array[1], lógico, (.t.) representa a frequência de domingo marcada
					array[2], lógico, (.t.) representa a frequência de segunda marcada
					array[3], lógico, (.t.) representa a frequência de terça marcada
					array[4], lógico, (.t.) representa a frequência de quarta marcada
					array[5], lógico, (.t.) representa a frequência de quinta marcada
					array[6], lógico, (.t.) representa a frequência de sexta marcada
					array[7], lógico, (.t.) representa a frequência de sábado marcada
			
	@return lRet,	lógico, .t. - Desmarcou os dias com sucesso
	
	@example
	lRet := TurnOffFrequence(oMdlSel1,nLine,aFrequence)
	
	@see (links_or_references)
/*/
Static Function TurnOffFrequence(oMdlSel1,nLine,aFrequence,lCallSec)

Local lRet 			:= .t.
		
Default oMdlSel1	:= GA408GetModel("GTPA408B"):GetModel("SELECAO1") 
Default nLine		:= oMdlSel1:GetLine()  
Default aFrequence	:= {	oMdlSel1:GetValue("GID_DOM",nLine),;	//SER
							oMdlSel1:GetValue("GID_SEG",nLine),;
							oMdlSel1:GetValue("GID_TER",nLine),;
							oMdlSel1:GetValue("GID_QUA",nLine),;
							oMdlSel1:GetValue("GID_QUI",nLine),;
							oMdlSel1:GetValue("GID_SEX",nLine),;
							oMdlSel1:GetValue("GID_SAB",nLine)}
Default lCallSec	:= .f.

If ( oMdlSel1:GetValue("GID_DOM",nLine) .And. aFrequence[1] )
	lRet := oMdlSel1:LoadValue("GID_DOM",.F.  )
Endif
		
If ( lRet .And. oMdlSel1:GetValue("GID_SEG",nLine) .And. aFrequence[2] )
	lRet := oMdlSel1:LoadValue("GID_SEG",.F. )
Endif

If ( lRet .And. oMdlSel1:GetValue("GID_TER",nLine) .And. aFrequence[3] )
	lRet := oMdlSel1:LoadValue("GID_TER",.F.  )
Endif

If ( lRet .And. oMdlSel1:GetValue("GID_QUA",nLine) .And. aFrequence[4] )
	lRet := oMdlSel1:LoadValue("GID_QUA",.F.  )
Endif

If ( lRet .And. oMdlSel1:GetValue("GID_QUI",nLine) .And. aFrequence[5] )
	lRet := oMdlSel1:LoadValue("GID_QUI",.F.  )
Endif

If ( lRet .And. oMdlSel1:GetValue("GID_SEX",nLine) .And. aFrequence[6] )
	lRet := oMdlSel1:LoadValue("GID_SEX",.F.  )
Endif

If ( lRet .And. oMdlSel1:GetValue("GID_SAB",nLine) .And. aFrequence[7] )
	lRet := oMdlSel1:LoadValue("GID_SAB",.F.  )
Endif
		
Return(lRet)
