#Include "GTPC300B.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"

Static c300BCodigo 
Static c300BDescri 
Static cG300BResultSet
Static n300BLinMark    	:= 0
Static lPosicionado		:= .F.

/*/{Protheus.doc} GTPC300B
Função responsavel pela substituição de recurso do monitor
@type function
@author jacomo.fernandes
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300B()
Local lMonitor	:= GC300GetMVC('IsActive')

If lMonitor
	FWExecView( STR0001, 'VIEWDEF.GTPC300B', MODEL_OPERATION_INSERT, , { || .T. } ) //'Substituição de Recursos'
Else
	FwAlertHelp(STR0002,STR0003) //"Substituição" //"Esta rotina só funciona com monitor ativo"
Endif

	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Rotina de Substituição de recurso(colaborador ou veiculo).

@sample  	ModelDef()

@return  	oModel - Objeto do Model

@author		Fernando Amorim (Cafu)
@since		
@version 	P12.1.16
/*/
//-------------------------------------------------------------------
Static Function ModelDef()



Local oModel		:= Nil
Local oStruRec  	:= FWFormModelStruct():New() // Recursos
Local oStruVia  	:= FWFormModelStruct():New() // Viagens

G300BStruct(oStruRec,oStruVia,"M")

oModel := MPFormModel():New('GTPC300B',/*bPreValid*/, {|oMdl| G300BTudoOk(oMdl)}/*bPosValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetCommit({|oMdl| G300BCommit(oMdl)})
oStruRec:AddTrigger( ;
		'CODREC'  , ;                  	// [01] Id do campo de origem
		'DESCRICAO'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || G300BGat("CABREC","CODREC")	} ) // [04] Bloco de codigo de execução do gatilho

oStruRec:AddTrigger( ;
		'SUBSREC'  , ;                  	// [01] Id do campo de origem
		'DESCRICA1'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || G300BGat("CABREC","SUBSREC")	} ) // [04] Bloco de codigo de execução do gatilho
		 
oStruRec:AddTrigger( ;
		'CHECKTER'  , ;                  	// [01] Id do campo de origem
		'CODREC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || ""	} ) // [04] Bloco de codigo de execução do gatilho	

oStruRec:AddTrigger( ;
		'CHECKTERSU'  , ;                  	// [01] Id do campo de origem
		'SUBSREC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || ""	} ) // [04] Bloco de codigo de execução do gatilho			 	 
oStruVia:AddTrigger( ;
		'DTREF'  , ;                  	// [01] Id do campo de origem
		'CHECKVIA'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || .F.	} ) // [04] Bloco de codigo de execução do gatilho

oModel:AddFields("CABREC",/*PAI*/,oStruRec,,/*bPost*/,/*bLoad*/)
oModel:AddGrid("VIAGENS", "CABREC", oStruVia,,,,,)
oModel:SetRelation( 'VIAGENS', { { 'FILIAL', 'XFILIAL("GQE")' } }   )

oModel:GetModel("CABREC"):SetOnlyQuery(.t.)
oModel:GetModel("VIAGENS"):SetOnlyQuery(.t.)
oModel:GetModel( 'VIAGENS' ):SetNoDeleteLine( .T. )
oModel:GetModel("CABREC"):SetDescription("Recurso") //"Recurso"
oModel:GetModel('VIAGENS'):SetDescription(STR0005)  //"Viagens e Trechos"


oModel:SetDescription(STR0006) //'Substituição de recursos'

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
																					
Local oStruRec	    := FWFormViewStruct():New()
Local oStruVia	 	:= FWFormViewStruct():New() 

Local oModel		:= FWLoadModel("GTPC300B")
Local bAction 		:= {|oView,lFilter,c300BOrigem|;	
						lFilter := .f.,;
						c300BOrigem := "GTPC300B",;
						CursorWait(),;
						lFilter := G300BChkFilter(oView,c300BOrigem),;
						Iif(lFilter,G300BCarga(oView, .F.),nil),;
						CursorArrow() }			
							
Local oMdlMonit		:= GC300GetMVC('M')
Local oMdlGYN		:= oMdlMonit:GetModel("GYNDETAIL")		
					
If oMdlGYN:GetValue('GYN_TIPO')=='1' //Normal 							
	oStruRec:AddField( 'CHECKTER', ; // cIdField
			'06', ; // cOrdem
			STR0056,;//'Terceiro', ; // cTitulo // 'Mark'
			STR0056,;//'Terceiro', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
			{STR0056},;//{'Terceiro'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
			'CHECK', ; // cType
			'@!', ; // cPicture
			Nil, ; // nPictVar
			Nil, ; // Consulta F3
			.T., ; // lCanChange
			'' , ; // cFolder
			Nil, ; // cGroup
			Nil, ; // aComboValues
			Nil, ; // nMaxLenCombo
			Nil, ; // cIniBrow
			.T., ; // lVirtual
			Nil ) // cPictVar  
	
	oStruRec:AddField( 'CHECKTERSU', ; // cIdField
			'06', ; // cOrdem
			STR0057,;//'Terceiro Subst.', ; // cTitulo // 'Mark'
			STR0057,;//'Terceiro Subst.', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
			{STR0057},;//{'Terceiro Subst.'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
			'CHECK', ; // cType
			'@!', ; // cPicture
			Nil, ; // nPictVar
			Nil, ; // Consulta F3
			.T., ; // lCanChange
			'' , ; // cFolder
			Nil, ; // cGroup
			Nil, ; // aComboValues
			Nil, ; // nMaxLenCombo
			Nil, ; // cIniBrow
			.T., ; // lVirtual
			Nil ) // cPictVar  		
EndIf		
G300BStruct(oStruRec,oStruVia,"V") 


oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddField("VIEW_REC",oStruRec,"CABREC")
oView:AddGRID("VIEW_VIA",oStruVia,"VIAGENS")

OView:GetModel('VIAGENS'):SetNoDeleteLine(.T.)
OView:GetModel('VIAGENS'):SetNoInsertLine(.T.)

oView:CreateHorizontalBox("SUPERIOR" , 30) // Recurso
oView:CreateHorizontalBox("INFERIOR" , 70) // Viagens

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_REC", "SUPERIOR")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_VIA", "INFERIOR")

oView:EnableTitleView("VIEW_REC", STR0007) //'Recurso'
oView:EnableTitleView("VIEW_VIA", STR0008) //'Viagens'

oView:AddUserButton( STR0009, "", bAction ,,VK_F5) //"Executar Filtro"
oView:AddUserButton( STR0010, "", {||G300BCMkAll()}) //"Marque/Desmarque todos"

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc} G300BStruct()
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
Static Function G300BStruct(oStruRec,oStruVia,cTipo) 

If ( cTipo == "M" )
	If ValType( oStruRec ) == "O"
		oStruRec:AddTable("   ",{" "}," ")
		oStruRec:AddField(	STR0011,;									// 	[01]  C   Titulo do campo
					 		STR0011,;									// 	[02]  C   ToolTip do campo
					 		"FILIAL",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("GQE_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruRec:AddField(	STR0007,;									// 	[01]  C   Titulo do campo
					 		STR0007,;									// 	[02]  C   ToolTip do campo
					 		"TPREC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		1,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oMdlRec,cCpo,xValue|G300BVld(oMdlRec,cCpo,xValue) },;	// 	[07]  B   Code-block de validação do campo
					 		{|oGrid,cCpo|G300BWhen(oGrid, cCpo) },; // 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual

		oStruRec:AddField(	'Cód Recurso',;						// 	[01]  C   Titulo do campo
				 		    'Cód Recurso',;				// 	[02]  C   ToolTip do campo
					 		"CODREC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		16,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oMdlRec,cCpo,xValue|G300BVld(oMdlRec,cCpo,xValue) },;		// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		
		oStruRec:AddField(	STR0013,;						// 	[01]  C   Titulo do campo
				 		    STR0013,;				// 	[02]  C   ToolTip do campo
					 		"DESCRICAO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		40,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		
		oStruRec:AddField(	STR0014,;						// 	[01]  C   Titulo do campo
				 		    STR0014,;				// 	[02]  C   ToolTip do campo
					 		"TIPO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		2,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oMdlRec,cCpo,xValue|G300BVld(oMdlRec,cCpo,xValue) },;		// 	[07]  B   Code-block de validação do campo
					 		{|oGrid,cCpo|G300BWhen(oGrid, cCpo) },;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruRec:AddField(	STR0058,;//"Cod. Viaj",;							// 	[01]  C   Titulo do campo
				 		    STR0059,;//"Codigo Viagem",;						// 	[02]  C   ToolTip do campo
					 		"CODVIAG",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TamSx3('GYN_CODIGO')[1],;				// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
	                        
		oStruRec:AddField(	STR0015,;						// 	[01]  C   Titulo do campo
				 		    STR0015,;				// 	[02]  C   ToolTip do campo
					 		"SUBSREC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		16,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oMdlRec,cCpo,xValue|G300BVld(oMdlRec,cCpo,xValue) },;		// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruRec:AddField(	STR0013,;						// 	[01]  C   Titulo do campo
				 		    STR0013,;				// 	[02]  C   ToolTip do campo
					 		"DESCRICA1",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		40,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruRec:AddField(	STR0060,;//"Justf",;						// 	[01]  C   Titulo do campo
				 		    STR0061,;//"Justifcativa",;				// 	[02]  C   ToolTip do campo
					 		"CABJUSTF",;							// 	[03]  C   Id do Field
					 		"M",;									// 	[04]  C   Tipo do campo
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
	
		oStruRec:AddField( '   ', ; // cTitle // 'Mark'
				STR0056,;//'Terceiro', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKTER', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual
				
		oStruRec:AddField( '   ', ; // cTitle // 'Mark'
				STR0057,;//'Terceiro Subst.', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKTERSU', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual				

		oStruRec:SetProperty("TPREC", MODEL_FIELD_INIT , {||'1'})
	Endif
	
	If ValType( oStruVia ) == "O"
			
    	oStruVia:AddTable("   ",{" "}," ")			 		
		oStruVia:AddField( '   ', ; // cTitle // 'Mark'
				STR0016, ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKVIA', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				{|oModel, cCampo, xValueNew, nLine, xValueOld| G300BVldMark(oModel, cCampo, xValueNew, nLine, xValueOld) }, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual		
		oStruVia:AddField(	STR0017,;						// 	[01]  C   Titulo do campo
				 		    STR0017,;				// 	[02]  C   ToolTip do campo
					 		"VIAGEM",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TamSx3('GYN_CODIGO')[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruVia:AddField(	STR0018,;						// 	[01]  C   Titulo do campo
				 		    STR0018,;				// 	[02]  C   ToolTip do campo
					 		"LINHA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TamSx3("GI1_DESCRI")[1]*2+1,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruVia:AddField(	STR0019,;						// 	[01]  C   Titulo do campo
				 		    STR0019,;				// 	[02]  C   ToolTip do campo
					 		"SEQ",;							// 	[03]  C   Id do Field
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
					 		
		oStruVia:AddField(	STR0020,;						// 	[01]  C   Titulo do campo
				 		    STR0020,;				// 	[02]  C   ToolTip do campo
					 		"ORIGEM",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		40,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruVia:AddField(	STR0021,;						// 	[01]  C   Titulo do campo
				 		    STR0021,;				// 	[02]  C   ToolTip do campo
					 		"CHEGADA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		40,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruVia:AddField(	STR0062,;//"Dt. Ref",;						// 	[01]  C   Titulo do campo
				 		    STR0062,;//"Dt. Ref",;				// 	[02]  C   ToolTip do campo
					 		"DTREF",;							// 	[03]  C   Id do Field
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
					 		
		
		oStruVia:AddField(	STR0022,;						// 	[01]  C   Titulo do campo
				 		    STR0022,;				// 	[02]  C   ToolTip do campo
					 		"DORIGEM",;							// 	[03]  C   Id do Field
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
		
		oStruVia:AddField(	STR0063,;//'Hr.Ini.Tr.',;						// 	[01]  C   Titulo do campo
				 		    STR0063,;//'Hr.Ini.Tr.',;				// 	[02]  C   ToolTip do campo
					 		"HRINITRAB",;							// 	[03]  C   Id do Field
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
		
		oStruVia:AddField(	STR0023,;						// 	[01]  C   Titulo do campo
				 		    STR0023,;				// 	[02]  C   ToolTip do campo
					 		"HORIGEM",;							// 	[03]  C   Id do Field
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
		
		
		oStruVia:AddField(	STR0024,;						// 	[01]  C   Titulo do campo
				 		    STR0024,;				// 	[02]  C   ToolTip do campo
					 		"DCHEGADA",;							// 	[03]  C   Id do Field
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
					 		
		oStruVia:AddField(	STR0025,;						// 	[01]  C   Titulo do campo
				 		    STR0025,;				// 	[02]  C   ToolTip do campo
					 		"HCHEGADA",;							// 	[03]  C   Id do Field
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
					 		
		oStruVia:AddField(	STR0064,;//'Hr.Fim.Tr.',;						// 	[01]  C   Titulo do campo
				 		    STR0064,;//'Hr.Fim.Tr.',;				// 	[02]  C   ToolTip do campo
					 		"HRFIMTRAB",;							// 	[03]  C   Id do Field
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
					 		
		oStruVia:AddField(	STR0060,;//"Justif",;						// 	[01]  C   Titulo do campo
				 		    STR0061,;//"Justicativa",;				// 	[02]  C   ToolTip do campo
					 		"JUSTIF",;							// 	[03]  C   Id do Field
					 		"M",;									// 	[04]  C   Tipo do campo
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
		
		oStruVia:AddField(	STR0065,;//"Tp Viagem",;						// 	[01]  C   Titulo do campo
				 		    STR0065,;//"Tp Viagem",;				// 	[02]  C   ToolTip do campo
					 		"TPVIAGEM",;							// 	[03]  C   Id do Field
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
		oStruVia:SetProperty("DORIGEM"	, MODEL_FIELD_WHEN	, {|oGrid| oGrid:GetValue('TPVIAGEM') == '2' } )
		oStruVia:SetProperty("HORIGEM"	, MODEL_FIELD_WHEN	, {|oGrid| oGrid:GetValue('TPVIAGEM') == '2' } )
		oStruVia:SetProperty("DCHEGADA"	, MODEL_FIELD_WHEN	, {|oGrid| oGrid:GetValue('TPVIAGEM') == '2' } )
		oStruVia:SetProperty("HCHEGADA"	, MODEL_FIELD_WHEN	, {|oGrid| oGrid:GetValue('TPVIAGEM') == '2' } )
		
			
	Endif
		
Else
    If ValType( oStruRec ) == "O"
	    oStruRec:AddField(	"TPREC",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0026,;						// [03]  C   Titulo do campo
	                        STR0026,;						// [04]  C   Descricao do campo
	                        {STR0007},;					// [05]  A   Array com Help // "Selecionar"
	                        "COMBO",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        {STR0027,STR0028},;		// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruRec:AddField(	"CODREC",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        'Cód Recurso',;						// [03]  C   Titulo do campo
	                        'Cód Recurso',;						// [04]  C   Descricao do campo
	                        {'Cód Recurso'},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "REC001",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;					// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruRec:AddField(	"DESCRICAO",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0013,;						// [03]  C   Titulo do campo
	                        STR0013,;						// [04]  C   Descricao do campo
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar"
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
	   
	   oStruRec:AddField(	"TIPO",;					// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        STR0014,;						// [03]  C   Titulo do campo
	                        STR0014,;						// [04]  C   Descricao do campo
	                        {STR0014},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "GYK",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;		// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                         
	   oStruRec:AddField(	"SUBSREC",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        STR0015,;						// [03]  C   Titulo do campo
	                        STR0015,;						// [04]  C   Descricao do campo
	                        {STR0015},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "REC001",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;					// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	      oStruRec:AddField(	"DESCRICA1",;				// [01]  C   Nome do Campo
	                        "06",;						// [02]  C   Ordem
	                        STR0013,;						// [03]  C   Titulo do campo
	                        STR0013,;						// [04]  C   Descricao do campo
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar"
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
	                        
		oStruRec:AddField(	"CABJUSTF",;				// [01]  C   Nome do Campo
	                        "07",;						// [02]  C   Ordem
	                        STR0060,;//"Justf",;						// [03]  C   Titulo do campo
	                        STR0061,;//"Justificativa",;						// [04]  C   Descricao do campo
	                        {STR0061},;//{"Justificativa"},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "@!",;						// [07]  C   Picture
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
	    
	            
	EndIf
    If ValType( oStruVia ) == "O"
    
    	oStruVia:AddField( 'CHECKVIA', ; // cIdField
				'01', ; // cOrdem
				'   ', ; // cTitulo // 'Mark'
				STR0016, ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				{STR0029}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
				'CHECK', ; // cType
				'@!', ; // cPicture
				Nil, ; // nPictVar
				Nil, ; // Consulta F3
				.T., ; // lCanChange
				'' , ; // cFolder
				Nil, ; // cGroup
				Nil, ; // aComboValues
				Nil, ; // nMaxLenCombo
				Nil, ; // cIniBrow
				.T., ; // lVirtual
				Nil ) // cPictVar
		
		oStruVia:AddField(	"VIAGEM",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0017,;						// [03]  C   Titulo do campo
	                        STR0017,;						// [04]  C   Descricao do campo
	                        {STR0017},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
    	oStruVia:AddField(	"LINHA",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0018,;						// [03]  C   Titulo do campo
	                        STR0018,;						// [04]  C   Descricao do campo
	                        {STR0018},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	     oStruVia:AddField(	"SEQ",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        STR0019,;						// [03]  C   Titulo do campo
	                        STR0019,;						// [04]  C   Descricao do campo
	                        {STR0019},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruVia:AddField(	"ORIGEM",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        STR0030,;						// [03]  C   Titulo do campo
	                        STR0030,;						// [04]  C   Descricao do campo
	                        {STR0030},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
    	 oStruVia:AddField(	"CHEGADA",;				// [01]  C   Nome do Campo
	                        "06",;						// [02]  C   Ordem
	                        STR0031,;						// [03]  C   Titulo do campo
	                        STR0031,;						// [04]  C   Descricao do campo
	                        {STR0031},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	      
	      oStruVia:AddField("DTREF",;				// [01]  C   Nome do Campo
	                        "07",;						// [02]  C   Ordem
	                        STR0062,;//'Dt. Ref',;						// [03]  C   Titulo do campo
	                        STR0062,;//'Dt. Ref',;						// [04]  C   Descricao do campo
	                        {STR0066},;//{'Data Referencia de alocação'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	       
	                        
	      oStruVia:AddField(	"DORIGEM",;				// [01]  C   Nome do Campo
	                        "08",;						// [02]  C   Ordem
	                        STR0022,;						// [03]  C   Titulo do campo
	                        STR0022,;						// [04]  C   Descricao do campo
	                        {STR0022},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	      
	      oStruVia:AddField("HRINITRAB",;				// [01]  C   Nome do Campo
	                        "09",;						// [02]  C   Ordem
	                        STR0063,;//'Hr.Ini.Tr.',;						// [03]  C   Titulo do campo
	                        STR0063,;//'Hr.Ini.Tr.',;						// [04]  C   Descricao do campo
	                        {STR0067},;//{'Hora Inicio de Trabalho'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@R 99:99",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	      
	      oStruVia:AddField(	"HORIGEM",;				// [01]  C   Nome do Campo
	                        "10",;						// [02]  C   Ordem
	                        STR0023,;						// [03]  C   Titulo do campo
	                        STR0023,;						// [04]  C   Descricao do campo
	                        {STR0023},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@R 99:99",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	                        
	      oStruVia:AddField("DCHEGADA",;				// [01]  C   Nome do Campo
	                        "11",;						// [02]  C   Ordem
	                        STR0024,;						// [03]  C   Titulo do campo
	                        STR0024,;						// [04]  C   Descricao do campo
	                        {STR0024},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	       
	      oStruVia:AddField("HCHEGADA",;				// [01]  C   Nome do Campo
	                        "12",;						// [02]  C   Ordem
	                        STR0025,;						// [03]  C   Titulo do campo
	                        STR0025,;						// [04]  C   Descricao do campo
	                        {STR0068},;//{'Hr. Chegada'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@R 99:99",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruVia:AddField("HRFIMTRAB",;				// [01]  C   Nome do Campo
	                        "13",;						// [02]  C   Ordem
	                        STR0064,;//'Hr.Fim.Tr.',;						// [03]  C   Titulo do campo
	                        STR0064,;//'Hr.Fim.Tr.',;						// [04]  C   Descricao do campo
	                        {},;//{'Hora Final de Trabalho'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@R 99:99",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	      
	            
		oStruVia:AddField(	"TPVIAGEM",;				// [01]  C   Nome do Campo
	                        "14",;						// [02]  C   Ordem
	                        STR0065,;//"Tp Viagem",;						// [03]  C   Titulo do campo
	                        STR0070,;//"Tipo Viagem",;						// [04]  C   Descricao do campo
	                        {STR0070},;//{'Tipo Viagem'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@!",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        GTPXCBox('GYN_TIPO'),;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	    oStruVia:AddField(	"JUSTIF",;				// [01]  C   Nome do Campo
	                        "15",;						// [02]  C   Ordem
	                        STR0060,;//"Justif",;						// [03]  C   Titulo do campo
	                        STR0061,;//"Justificativa",;						// [04]  C   Descricao do campo
	                        {STR0061},;//{'Justificativa'},;					// [05]  A   Array com Help // "Selecionar"
	                        "Get",;					// [06]  C   Tipo do campo
	                        "@!",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
    Endif
    
EndIf

Return()

//-----------------------------------------------------------------------------
/*{Protheus.doc} G300BFil
Função responsável para chamada do filtro 

@Return
 cRet: retorna busca do filtro 

@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//-----------------------------------------------------------------------------

User Function G300BFil()

Local aRetorno 		:= {}
Local cQuery   		:= ""          
Local lRet     		:= .F.
Local oLookUp  		:= Nil
Local oMldMaster	:=  FwModelActive()
Local lTerceiro		:= .F. 

If ( FWIsInCallStack("GTPC300A") .Or. FWIsInCallStack("GTPC300B") )
	cIdSubMdl 	:= "CABREC"
	cField		:= "TPREC"
	
	lTerceiro	:= Gtpc300Ter(oMldMaster:GetModel(cIdSubMdl))		
	
ElseIf FWIsInCallStack("GTPC300E") .or. FWIsInCallStack("GTPC300I") .OR. FWIsInCallStack("GTPC300K") 
	cIdSubMdl 	:= "GQEMASTER"
	cField		:= "GQE_TRECUR"
	
	lTerceiro	:= Gtpc300Ter(oMldMaster:GetModel(cIdSubMdl))
Else
	cIdSubMdl 	:= "GQEDETAIL"
	cField		:= "GQE_TRECUR"
EndIf

If oMldMaster:IsActive() .And. oMldMaster:GetModel(cIdSubMdl):GETVALUE(cField) == '1'
	If lTerceiro
		cQuery := " SELECT DISTINCT G6Z_CODIGO, G6Z_NOME, G6Z_FORNEC, G6Z_LOJAFO, G6Z_DDD, G6Z_TELEFO, G6Z_CPF" 
		cQuery += " FROM " + RetSqlName("G6Z")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND G6Z_FILIAL = '"+xFilial('G6Z')+"' AND G6Z_TRECUR='1' "
		oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"G6Z_CODIGO", "G6Z_NOME","G6Z_CPF"})
		                                                       
		oLookUp:AddIndice("Código"		, "G6Z_CODIGO")
		oLookUp:AddIndice("Nome"		, "G6Z_NOME")
		oLookUp:AddIndice("CPF"			, "G6Z_CPF")
	Else
		cQuery := " SELECT DISTINCT GYG_CODIGO, REPLACE( REPLACE ( GYG_NOME , ')' , '' ) , '(' , '' ) as GYG_NOME, GYG_FUNCIO" 
		cQuery += " FROM " + RetSqlName("GYG")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND GYG_FILIAL = '"+xFilial('GYG')+"' "
		oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GYG_CODIGO", "GYG_NOME","GYG_FUNCIO"})
		                                                       
		oLookUp:AddIndice("Código"		, "GYG_CODIGO")
		oLookUp:AddIndice("Nome"		, "GYG_NOME")
		oLookUp:AddIndice("Matricula"	, "GYG_FUNCIO")
	EndIf
Elseif oMldMaster:IsActive() .And. oMldMaster:GetModel(cIdSubMdl):GETVALUE(cField) == '2'
	If lTerceiro
		cQuery := " SELECT DISTINCT G6Z_CODIGO, G6Z_NOME, G6Z_FORNEC, G6Z_LOJAFO, G6Z_PREFCA, G6Z_PLACA, G6Z_MARCA, G6Z_MODELO" 
		cQuery += " FROM " + RetSqlName("G6Z")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND G6Z_FILIAL = '"+xFilial('G6Z')+"' AND G6Z_TRECUR='2' "
		oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"G6Z_CODIGO", "G6Z_NOME","G6Z_PLACA"})
		                                                       
		oLookUp:AddIndice("Código"		, "G6Z_CODIGO")
		oLookUp:AddIndice("Nome"		, "G6Z_NOME")
		oLookUp:AddIndice("Placa"		, "G6Z_PLACA")
		oLookUp:AddIndice("Marca"		, "G6Z_MARCA")
		oLookUp:AddIndice("Modelo"		, "G6Z_MODELO")
	Else
		cQuery := " SELECT DISTINCT T9_CODBEM, REPLACE( REPLACE ( T9_NOME , ')' , '' ) , '(' , '' ) AS T9_NOME" 
		cQuery += " FROM " + RetSqlName("ST9")
		cQuery += " WHERE T9_FILIAL = '"+xFilial('ST9')+"' and D_E_L_E_T_ = ' ' AND T9_CATBEM IN ('2','4') "
		oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"T9_CODBEM", "T9_NOME"})
		                                                       
		oLookUp:AddIndice("Código", "T9_CODBEM")
	EndIf

Endif

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	c300BCodigo := aRetorno[1]
	c300BDescri := aRetorno[2]
EndIf   

FreeObj(oLookUp)

Return lRet

//-----------------------------------------------------------------------------
/*{Protheus.doc} G300BRFil
Função responsável para chamada do filtro 

@Return
 cRet: chamada do filtro de acordo com o retorno

@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//-----------------------------------------------------------------------------

User Function G300BRFil(nRet)
Local cRet :=''
If nRet == 1
	cRet:=	c300BCodigo
Else
	cRet:=	c300BDescri
Endif

Return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} G300BChkFilter()
	Verifica se o filtro
	@type  Static Function
	@author Fernando Amorim(Cafu)
	@since 22/08/2017
	@version version
	@param oView, objeto, instância da Classe FwFormView
	@return lRet, lógico, .t. - Permite prosseguir com o filtro
	@example
	(examples)
	@see (links_or_references)
/*/
//-----------------------------------------------------------------------------

Function G300BChkFilter(oView,c300BOrigem, lPosi)

Local lRet		:= .F.
Local nOpera 	:= 0
Local oMldRec	 
Local oMldVia	

If ValType(oView) == 'U'  
	Return(.F.)
Endif
nOpera 	:= oView:GetModel():GetOperation()
oMldRec	:= oView:GetModel("CABREC")
oMldVia	:= oView:GetModel("VIAGENS")


If c300BOrigem =='GTPC300A' .and. !fwisincallstack("FWALERTHELP")
	If !Empty(oMldRec:GetValue("CODREC")) .AND. If(oMldRec:GetValue("TPREC") == '1',!Empty(oMldRec:GetValue("TIPO")),.T.) .Or. lPosi
		lRet		:= .T.
		oMldVia:GOLINE(1)
		
	Else
		lRet		:= .F.
		FwAlertHelp(STR0032,STR0033) 		 //"Filtro"
	EndIf	
	
Elseif !fwisincallstack("FWALERTHELP")
	If ( If(oMldRec:GetValue("TPREC") == '1',!Empty(oMldRec:GetValue("TIPO")),.T.) )
		lRet		:= .T.
		oMldVia:GOLINE(1)
	Else
		lRet		:= .F.
		FwAlertHelp(STR0032,STR0033) 	 //"Filtro"
	EndIf

Endif

If ( lRet .AND. !Empty(oMldVia:GetValue("VIAGEM")) .AND. (nOpera == 3 .Or. nOpera == 4) .AND. !fwisincallstack("FWALERTYESNO")  .AND. !fwisincallstack("FWALERTSUCCESS") .AND. !fwisincallstack("FWALERTERROR") .AND. ;
     !fwisincallstack("FWALERTHELP") .AND. !fwisincallstack("FWALERTEXITPAGE") )
	
	lRet := MsgYesNo(STR0034) //"Deseja realmente refazer o filtro de viagens?"

	If ( lRet )

		oView:GetModel("VIAGENS"):ClearData()
		oView:Refresh("VIEW_VIA")
		
	EndIf
ElseIf lRet .AND. Empty(oMldVia:GetValue("VIAGEM")) .And. oView:IsActive() .AND. !fwisincallstack("FWALERTYESNO")
	lRet := .T.
Else
	lRet := .F.
EndIf

Return(lRet)
//-----------------------------------------------------------------------------
 /*/{Protheus.doc} G300BFill()
	Preenche os horários do grid VIAGENS
	@type Static Function
	@author Fernando Amorim(Cafu)
	@since 22/08/2017
	@version version
	@param oView, objeto, instância da classe FwFormView
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*/
//-----------------------------------------------------------------------------
Function G300BFill(oView)

Local oMdlVia	:= oView:GetModel("VIAGENS")
Local cAlias	:= cG300BResultSet
Local lRet		:= .T.

If ( (cAlias)->(!Eof()) )

	While ( (cAlias)->(!Eof()) )
		
		If ( !Empty(oMdlVia:GetValue("VIAGEM")) )
			lRet := oMdlVia:Length() < oMdlVia:AddLine(.t.,.t.)
		EndIf

		If ( lRet )
				
			lRet := oMdlVia:LoadValue('VIAGEM',(cAlias)->GYN_CODIGO) 	.And. ;
					oMdlVia:LoadValue('LINHA',TPNomeLinh((cAlias)->GYN_LINCOD)) 	.And. ;
					oMdlVia:LoadValue('SEQ',(cAlias)->G55_SEQ) 	.And. ;
					oMdlVia:LoadValue('ORIGEM',posicione("GI1",1,xFilial("GI1")+(cAlias)->G55_LOCORI,"GI1_DESCRI")) 	.And. ;
					oMdlVia:LoadValue('CHEGADA',posicione("GI1",1,xFilial("GI1")+(cAlias)->G55_LOCDES,"GI1_DESCRI")) .And. ;
					oMdlVia:LoadValue('DORIGEM',STOD((cAlias)->G55_DTPART)) .And. ;
					oMdlVia:LoadValue('HORIGEM',(cAlias)->G55_HRINI) .And. ;
					oMdlVia:LoadValue('DCHEGADA',STOD((cAlias)->G55_DTLOCA)) .And. ;
					oMdlVia:LoadValue('HCHEGADA',(cAlias)->G55_HRFIM) 
					
				
		Else
			Exit
		EndIf	

		If ( !lRet )
			Exit
		EndIf

		(cAlias)->(DbSkip())

	EndDo

	If ( lRet )
		oMdlVia:GoLine(1)
		oView:Refresh("VIEW_VIA")
	EndIf

EndIf

Return() 

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldMark
	valida a marcação do registro e elimina uma marcação anterior
@sample 	VldMark()
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Function G300BVldMark( oMdlBase, cCampo, xValueNew, nLine, xValueOld)

Local lRet       	:= .T. 
Local oMdlCab		:= oMdlBase:GetModel():GetModel("CABREC")
Local oMdlMonit		:= GC300GetMVC('M')
Local oMdlGYN		:= oMdlMonit:GetModel("GYNDETAIL")
Local oMdlG55		:= oMdlMonit:GetModel("G55DETAIL")
Local oMdlGQE		:= oMdlMonit:GetModel("GQEDETAIL")

Local cSeq			:= oMdlBase:GetValue("SEQ",nLine)
Local cViagem		:= oMdlBase:GetValue("VIAGEM")
Local cCodRecur		:= oMdlCab:GetValue("CODREC")
Local cTipo			:= oMdlCab:GetValue("TPREC")      
Local cTpColab		:= oMdlCab:GetValue("TIPO")  
Local dDtIni		:= oMdlBase:GetValue("DORIGEM")     
Local dDtFim        := oMdlBase:GetValue("DCHEGADA")    
Local cHrIni        := oMdlBase:GetValue("HORIGEM")     
Local cHrFim        := oMdlBase:GetValue("HCHEGADA")   
Local nRecGQK       := oMdlCab:GetDataId()
Local lTerceiro		:= .F. 
Local dDtRef        := oMdlBase:GetValue("DTREF")

Local cMsgErro		:= ""
Local cMsgSol		:= ""
Local cLimTip		:= Posicione("GYK",1,XFilial("GYK") + cTpColab, "GYK_LIMTIP")

If FwIsInCallStack("GTPC300A")
	lTerceiro	:=oMdlCab:GetValue("CHECKTER")
ElseIf FwIsInCallStack("GTPC300B")
	lTerceiro	:=oMdlCab:GetValue("CHECKTERSU")
EndIf
//Validação para verificar se na seção seleciona ja possui o colaborador escolhido
If lRet .and. FwIsInCallStack("GTPC300A")
	oMdlGYN:SeekLine({{"GYN_CODIGO",cViagem} })//Posiciona na seção 
	oMdlG55:SeekLine({{"G55_VIACOD",cViagem},{"G55_SEQ",cSeq} })//Posiciona na seção 
	
	//Verifica se a viagem se encontra finalizada
	If oMdlGYN:GetValue('GYN_FINAL') == "1"
		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',"Viagem se encontra finalizada","Selecione outro registro ou reabra a viagem antes de manipular o recurso" )
		lRet	:= .F.
	Endif
	
	//Verifica se existe o mesmo recuso na seção selecionada
	If lRet .and. lTerceiro .AND. oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo},{"GQE_RECURS",cCodRecur},{"GQE_TERC",'1'}  })//Realiza busca do colaborador-Terceiro
		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0055,STR0048 )//"Seção selecionada já possui o colaborador selecionado"#"Selecione outra seção"#"Não há recursos alocados para esta viagem";"Incluir um recurso para viagem"				
		lRet	:= .F.
	ElseIf lRet .and. oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo},{"GQE_RECURS",cCodRecur} })//Realiza busca do colaborador
		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0055,STR0048 )//"Seção selecionada já possui o colaborador selecionado"#"Selecione outra seção"#"Não há recursos alocados para esta viagem";"Incluir um recurso para viagem"				
		lRet	:= .F.
	EndIf
	
	If lRet .And. cLimTip == '1'  .And. oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo},{"GQE_TCOLAB",cTpColab} })  //

		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0053,STR0054 )//"Permitido apenas um colaborador deste tipo por viagem"#"Selecione outro tipo"#"Não há recursos alocados para esta viagem";"Incluir um recurso para viagem"				
		
		lRet	:= .F.

	Endif
	
	If lRet .And. cLimTip == '2'  .And. oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo},{"GQE_TCOLAB",cTpColab} })  //

		If !(FwAlertYesNo(STR0052 )) // Já existe um colaborador deste tipo na seção selecionada. Deseja continuar ?
		
			oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0051,"" ) // "Seleção cancelada"				
		
			lRet	:= .F.
			
		Endif

	Endif

	//Verifica se possui ja um veículo ou motorista na seção
	If lRet .AND. cTipo == "1" .AND. cTpColab == "01" .And. Empty(oMdlGYN:GetValue("GYN_SRVEXT"))
		If oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo},{"GQE_TCOLAB",cTpColab} }) 
		
			oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0050,STR0048 )//"Seção selecionada já possui um motorista"#"Não há recursos alocados para esta viagem";"Incluir um recurso para viagem"				
			
			lRet	:= .F.
		EndIf
	ElseIf lRet .AND. cTipo == "2"
		If oMdlGQE:SeekLine({{"GQE_VIACOD",cViagem},{"GQE_SEQ",cSeq},{"GQE_TRECUR",cTipo}})//Realiza busca do veiculo
			
			oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',STR0049,STR0048 )//"Seção selecionada já possui um veículo"#"Não há recursos alocados para esta viagem";"Incluir um recurso para viagem"				
			
			lRet	:= .F.
		EndIf
	EndIf
ElseIf FwIsInCallStack("GTPC300B")
	oMdlGYN:SeekLine({{"GYN_CODIGO",cViagem} })//Posiciona na seção 
	
	If oMdlGYN:GetValue('GYN_FINAL') == "1"
		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',"Viagem se encontra finalizada","Selecione outro registro ou reabra a viagem antes de manipular o recurso" )
		lRet	:= .F.
	Endif

EndIf

//Verifica se recurso já está alocado em uma viagem
If lRet .And. xValueNew

	If !FwIsInCallStack("GTPC300A")
		cCodRecur	:= oMdlCab:GetValue("SUBSREC")
	EndIf
	
	//Verifica se na base encontra algum trecho que o colaborador esteja trabalhando
	//Caso não, verifica no monitor se existe algum caso que ainda não foi salvo 
	If !Gc300VldAloc(cCodRecur,cTipo,dDtRef,dDtIni,cHrIni ,dDtFim,cHrFim,@cMsgErro, !lTerceiro,nRecGQK,,oMdlGYN:GetValue("GYN_LINCOD"),@cMsgSol)
		lRet 	:= .F.
		cMsgSol := Iif(Empty(cMsgSol),STR0048,cMsgSol)
		oMdlBase:GetModel():SetErrorMessage(oMdlBase:GetId(),"CHECKVIA",oMdlBase:GetId(),"CHECKVIA",'Check',cMsgErro,cMsgSol )//"Selecione outra seção"
	EndIf
EndIf

oMdlBase:GoLine( nLine ) 

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} G300BCMkAll
	Marca ou desmarca todos os registros da grid
@sample 	TP003RMkAll(oView)
@since		07/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function G300BCMkAll(oView)

Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oGridVia	:= oModel:GetModel('VIAGENS')
Local nI		:= 1
Local oMdlMonit		:= GC300GetMVC('M')
Local oMdlG55		:= oMdlMonit:GetModel("G55DETAIL")
Local oMdlGQE		:= oMdlMonit:GetModel("GQEDETAIL")
Local oMdlCab		:= oModel:GetModel("CABREC")

For nI := 1 To oGridVia:Length()
	oGridVia:GoLine( nI )
	
	If FwIsInCallStack("GTPC300A")
	
		oMdlG55:SeekLine({{"G55_VIACOD",oGridVia:GetValue("VIAGEM")},{"G55_SEQ",oGridVia:GetValue("SEQ")} })//Posiciona na seção 
		
		If oGridVia:GetValue("CHECKVIA")
		
			oGridVia:SetValue("CHECKVIA", .F.)
		
		ElseIf oMdlGQE:SeekLine({{"GQE_VIACOD",oGridVia:GetValue("VIAGEM")},;
							{"GQE_SEQ",oGridVia:GetValue("SEQ")},;
							{"GQE_TRECUR",oMdlCab:GetValue("TPREC")},;
							{"GQE_RECURS",oMdlCab:GetValue("CODREC")} })//Realiza busca do colaborador 	
			oGridVia:SetValue("CHECKVIA", .F.)
		Else
			oGridVia:SetValue("CHECKVIA", .T.)					
		EndIf
		oGridVia:GoLine( 1 ) 
	Else
	
		If oGridVia:GetValue("CHECKVIA")
			oGridVia:SetValue("CHECKVIA", .F.)
		
		Else 	
			oGridVia:SetValue("CHECKVIA", .T.)				
		EndIf
	
	EndIf
	
	oModel:GetErrorMessage(.T.)	
Next nI

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302X3WhenGYP()

Rotina responsavel por habilitar a edição dos campos com base no tipo de trecho (Campo GYP_TIPO)

@sample	GA302X3WhenGYP()

@Param		oGrid - Objeto Grid  
@Param		cCampo - Nome do campo a ser avaliado.

@author	Fernando Amorim(Cafu)
@since		09/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function G300BWhen(oGrid, cCampo)

Local cTipo			:= oGrid:GetValue("TPREC")
Local cFields 		:= ""
Local lRet 			:= .F.


If cCampo == "DORIGEM" .OR. cCampo == "HORIGEM"  .OR. cCampo == "DCHEGADA" .OR. cCampo == "HCHEGADA"
	lRet := oGrid:GetValue("TPVIAGEM") == '2' 
Else
	If cTipo == "1" 
		cFields := "TPREC|CODREC|TIPO|SUBSREC"
	Else
		cFields := "TPREC|CODREC|SUBSREC"
	
	EndIf
		
	lRet := AllTrim(cCampo) $ cFields
Endif	
	
Return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} G300BGat()

Rotina responsavel pelo retorno da descrição de acordo com tipo do recurso
@sample	GA302X3WhenGYP()

@Param		cId - Id do modelo  
@Param		cCpoRec  - Nome do campo a ser avaliado.

@author	Fernando Amorim(Cafu)
@since		09/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------
 Function G300BGat(cId,cCpoRec)

Local oMldMaster	:=  FwModelActive()
Local cRet			:= ''

If oMldMaster:IsActive() .And. oMldMaster:GetModel(cId):GETVALUE("TPREC") == '1'	
	cRet := Posicione("GYG",1,xFilial("GYG")+oMldMaster:GetModel(cId):GETVALUE(cCpoRec), "GYG_NOME")
Elseif oMldMaster:IsActive() .And. oMldMaster:GetModel(cId):GETVALUE("TPREC") == '2'
	cRet := Posicione("ST9",1,xFilial("ST9")+oMldMaster:GetModel(cId):GETVALUE(cCpoRec), "T9_NOME")	
Endif

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G300BVLD()
Função de validação de campo
@return lRet: Lógico.	.t. Validação e atualização efetuadas com sucesso		
@author	Fernando Amorim (Cafu)
@since		23/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G300BVLD(oMdlRec, cCampo,xValue)

Local lRet			:= .T.

Local oMdlVia		:= oMdlRec:GetModel():GetModel("VIAGENS")
Local oView			:= FwViewActive()
Local lTerceiro		:= oMdlRec:GetValue('CHECKTER')
Local lTerceiroS	:= oMdlRec:GetValue('CHECKTERSU')

	If 	cCampo = 'TPREC' .And. !lPosicionado	
		oMdlRec:LOADValue("CODREC",'')
		oMdlRec:LOADValue("DESCRICAO",'')
		oMdlRec:LOADValue("SUBSREC",'')
		oMdlRec:LOADValue("DESCRICA1",'')
		oMdlRec:LOADValue("TIPO",'')
		
	Elseif cCampo = 'TIPO'
		lRet := ExistCpo("GYK",xValue)
	Elseif cCampo = 'CODREC'
		
		If oMdlRec:GetValue("CODREC") == oMdlRec:GetValue("SUBSREC")
			lRet := .F.
		EndIf
		
		If ( lRet )
			lRet := GC300ChkRec(xValue,oMdlRec:GetValue("TPREC"), , lTerceiro)
		EndIf
		
	Elseif cCampo = 'SUBSREC'
		
		If oMdlRec:GetValue("CODREC") == oMdlRec:GetValue("SUBSREC")
			lRet := .F.			
		EndIf
		
		If ( lRet )
			lRet := GC300ChkRec(xValue,oMdlRec:GetValue("TPREC"), , lTerceiroS)
		EndIf
	Endif
	
	If lRet
		oMdlVia:ClearData(.t.)
		oView:Refresh()
	Endif
	
	lPosicionado	:= .F.
	
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} G300BCommit
	Grava 
@author Fernando Amorim(Cafu)
@since		23/08/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function G300BCommit(oMdlMaster)

Local lRet  := .T.

Local oMldMonitor 	:= GC300GetMVC('M')
Local oViewMonitor	:= GC300GetMVC('V')
Local oMdlRec	 	:= OMdlMaster:GetModel( 'CABREC' )
Local oMdlVia	 	:= OMdlMaster:GetModel( 'VIAGENS' )
Local oMdlGQE
Local oMdlG55	  
Local nX		 	:= 0
Local cRecurs		:= ''	
Local aRetLog		:= {}
Local lTerceiro		:= Gtpc300Ter(oMdlRec)

oMdlGQE	 	:= oMldMonitor:GetModel( 'GQEDETAIL' )
oMdlG55	 	:= oMldMonitor:GetModel( 'G55DETAIL' )
oMdlGYN	 	:= oMldMonitor:GetModel( 'GYNDETAIL' )


For nX := 1 To oMdlVia:Length()

		oMdlVia:GoLine( nX )

		If oMdlVia:GetValue('CHECKVIA')				
						
			If fwisincallstack("GTPC300B")
			
				If oMdlRec:GetValue('CHECKTERSU')
					cRecurs := Posicione("G6Z",1,xFilial("G6Z")+oMdlRec:GETVALUE("SUBSREC"), "G6Z_NOME")
				Else
					If oMdlRec:GETVALUE("TPREC") == '1'	
						cRecurs := Posicione("GYG",1,xFilial("GYG")+oMdlRec:GETVALUE("SUBSREC"), "GYG_NOME")
					Elseif oMdlRec:GETVALUE("TPREC") == '2'
						cRecurs := Posicione("ST9",1,xFilial("ST9")+oMdlRec:GETVALUE("SUBSREC"), "T9_NOME")	
					Endif
				Endif
			
				
				If oMdlGYN:SeekLine({ {'GYN_CODIGO', oMdlVia:GetValue( 'VIAGEM' )}})
					If oMdlG55:SeekLine({ {'G55_CODVIA', oMdlVia:GetValue( 'VIAGEM' )},{"G55_SEQ",substr(oMdlVia:GetValue("SEQ"),1,TAMSX3("G55_SEQ")[1])}})
				
						If oMdlGQE:SeekLine({ {'GQE_VIACOD', oMdlVia:GetValue( 'VIAGEM' )},{"GQE_SEQ",oMdlVia:GetValue("SEQ")};
							,{"GQE_RECURS",oMdlRec:GetValue("CODREC")},{"GQE_TRECUR",oMdlRec:GetValue("TPREC")};
							,{"GQE_TCOLAB",If(oMdlRec:GetValue("TPREC")=='1',oMdlRec:GetValue("TIPO"),space(TamSx3("GQE_TCOLAB")[1]))}})	
						
							lRet := oMdlGQE:LoadValue( "GQE_RECURS"	, oMdlRec:GetValue("SUBSREC")) .AND.;	
									oMdlGQE:LoadValue( "GQE_DRECUR"	, cRecurs) .AND.;
									oMdlGQE:loadValue( "GQE_STATUS"	, '2' )	.AND. ;
									oMdlGQE:LoadValue( "GQE_DTREF"	, oMdlVia:GetValue("DTREF") ) .And.;
									oMdlGQE:LoadValue( "GQE_HRINTR"	, oMdlVia:GetValue("HRINITRAB") ) .And.;
									oMdlGQE:LoadValue( "GQE_HRFNTR"	, oMdlVia:GetValue("HRFIMTRAB") ) .And.;
									oMdlGQE:LoadValue( "GQE_TERC"	, IIf(oMdlRec:GetValue("CHECKTERSU"),'1','2') ) .And.;
									oMdlGQE:loadValue( "GQE_JUSTIF"	, oMdlRec:GetValue('CABJUSTF') ) .And.;
									oMdlGQE:LoadValue( "GQE_USRALO"	, cUserName ) .And.;
									oMdlGQE:LoadValue( "GQE_DTALOC"	, FwTimeStamp(2) ) 
									
									GC300SetLegenda(oMdlGQE)
							If lRet
								oMdlG55:loadValue( "G55_CONF"	, '2' )
								oMdlG55:loadValue( "G55_DTPART"	, oMdlVia:GetValue("DORIGEM") )
								oMdlG55:loadValue( "G55_HRINI"	, oMdlVia:GetValue("HORIGEM") )
								oMdlG55:loadValue( "G55_DTCHEG"	, oMdlVia:GetValue("DCHEGADA") )
								oMdlG55:loadValue( "G55_HRFIM"	, oMdlVia:GetValue("HCHEGADA") )
								
								GC300SetLegenda(oMdlG55)
								oMdlGYN:loadValue( "GYN_CONF"	, '2' )
								GC300SetLegenda(oMdlGYN)
							Endif			
						Endif
					Else
						lRet := .F.
					Endif
				Else
					lRet := .F.
				Endif
			Else
			
				If lTerceiro
					cRecurs := Posicione("G6Z",1,xFilial("G6Z")+oMdlRec:GETVALUE("CODREC"), "G6Z_NOME")
				Else
					If oMdlRec:GETVALUE("TPREC") == '1'	
						cRecurs := Posicione("GYG",1,xFilial("GYG")+oMdlRec:GETVALUE("CODREC"), "GYG_NOME")
					Elseif oMdlRec:GETVALUE("TPREC") == '2'
						cRecurs := Posicione("ST9",1,xFilial("ST9")+oMdlRec:GETVALUE("CODREC"), "T9_NOME")	
					Endif
				Endif
			
				If oMdlGYN:SeekLine({ {'GYN_CODIGO', oMdlVia:GetValue( 'VIAGEM' )}})
					If oMdlG55:SeekLine({ {'G55_CODVIA', oMdlVia:GetValue( 'VIAGEM' )},{"G55_SEQ",substr(oMdlVia:GetValue("SEQ"),1,TAMSX3("G55_SEQ")[1])}})
						//Radu comenta, em 11/08/2022:
						//	'Este bloco já é validado durante a marcação de cada item, 
						//	no grid, através da função Gc300VldAloc(..)'
						// If !lTerceiro .AND. oMdlRec:GETVALUE("TPREC") == '1' .and. !GTP409ColConf(oMdlRec:GetValue("CODREC"),oMdlVia:GetValue("DTREF"),oMdlGYN:GetValue("GYN_LINCOD"),/*aConf*/,aRetLog)
						// 	oMdlMaster:SetErrorMessage("",,oMdlMaster:GetId(),"","G300BCommit",aRetLog[2])
						// 	lRet:= .F.
						// Endif		
						
						If lRet .and. !oMdlGQE:IsEmpty() .AND. !Empty(oMdlGQE:GetValue("GQE_VIACOD")) 
							lRet := oMdlGQE:Length() < oMdlGQE:AddLine(.t.,.t.)
						endif
					Else
						lRet := .F.
					Endif
				Else
					lRet := .F.
				Endif
				
				If ( lRet )
					If oMdlGQE:Length() > 1
						cItem	:= StrZero(Val(oMdlGQE:GetValue('GQE_ITEM',oMdlGQE:Length()-1))+1,TamSx3('GY6_SEQ')[1])
					Else
						cItem	:= StrZero(1,TamSx3('GY6_SEQ')[1])
					Endif
					
					lRet := oMdlGQE:LoadValue( "GQE_VIACOD"	, oMdlVia:GetValue('VIAGEM') ) 	.And.;
							oMdlGQE:LoadValue( "GQE_SEQ"	, oMdlVia:GetValue('SEQ') ) 	.And.;
							oMdlGQE:LoadValue( "GQE_ITEM"	, cItem ) 	.And.;
							oMdlGQE:LoadValue( "GQE_TRECUR"	, oMdlRec:GetValue("TPREC") ) 	.And.;
							oMdlGQE:LoadValue( "GQE_TCOLAB"	, oMdlRec:GetValue("TIPO") ) 	.And.;
							oMdlGQE:LoadValue( "GQE_DCOLAB", If(oMdlRec:GetValue("TPREC")=="1",Posicione("GYK",1,XFilial("GYK") + oMdlRec:GetValue("TIPO"),"GYK_DESCRI"),"") ) .AND. ;
							oMdlGQE:LoadValue( "GQE_RECURS"	, oMdlRec:GetValue("CODREC") ) .And.;	
							oMdlGQE:LoadValue( "GQE_DRECUR"	, cRecurs ).And.;
							oMdlGQE:LoadValue( "GQE_DTREF"	, oMdlVia:GetValue("DTREF") ) .And.;	
							oMdlGQE:LoadValue( "GQE_HRINTR"	, oMdlVia:GetValue("HRINITRAB") ) .And.;
							oMdlGQE:LoadValue( "GQE_HRFNTR"	, oMdlVia:GetValue("HRFIMTRAB") ) .And.;
							oMdlGQE:LoadValue( "GQE_CANCEL"	, '1' ) .And. ;
							oMdlGQE:LoadValue( "GQE_STATUS"	, '2' ) .AND.	;
							oMdlGQE:LoadValue( "GQE_TERC"	, IIf(lTerceiro,'1','2') ) .AND.	; 
							oMdlGQE:LoadValue( "GQE_JUSTIF"	, oMdlVia:GetValue('JUSTIF') ) .And. ;
							oMdlGQE:LoadValue( "GQE_USRALO"	, cUserName ) .And. ;
							oMdlGQE:LoadValue( "GQE_DTALOC"	, FwTimeStamp(2) ) 
							
							GC300SetLegenda(oMdlGQE)
					If lRet
						oMdlG55:loadValue( "G55_CONF"	, '2' )
						oMdlG55:loadValue( "G55_DTPART"	, oMdlVia:GetValue("DORIGEM") )
						oMdlG55:loadValue( "G55_HRINI"	, oMdlVia:GetValue("HORIGEM") )
						oMdlG55:loadValue( "G55_DTCHEG"	, oMdlVia:GetValue("DCHEGADA") )
						oMdlG55:loadValue( "G55_HRFIM"	, oMdlVia:GetValue("HCHEGADA") )
											
						GC300SetLegenda(oMdlG55)
						oMdlGYN:loadValue( "GYN_CONF"	, '2' )
						GC300SetLegenda(oMdlGYN)
					Endif						
							
				EndIf	
			Endif
		EndIf
		
Next nX

If lRet
	oViewMonitor:Refresh("G55DETAIL")
	oViewMonitor:Refresh("GQEDETAIL")
EndIf
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} G300BTudoOk
	Valida o modelo 
@author Fernando Amorim(Cafu)
@since		24/08/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function G300BTudoOk(OMdlMaster)

Local lRet  	:= .T.
Local lMarcado	:= .F.

Local oMdlRec	 	:= OMdlMaster:GetModel( 'CABREC' )
Local oMdlVia	 	:= OMdlMaster:GetModel( 'VIAGENS' )
Local nX		 	:= 0


If fwisincallstack("GTPC300B")
	If ( If(oMdlRec:GetValue("TPREC") == '1',Empty(oMdlRec:GetValue("TIPO")),.F.) ) 
		lRet		:= .F.
		OMdlMaster:SetErrorMessage("CABREC",'CODREC',"CABREC",'CODREC',STR0004,STR0035)		 //"Recurso"#"Há campos em branco no cabeçalho."
	ElseIf Empty(oMdlRec:GetValue("CABJUSTF")) 
		lRet		:= .F.
		oMdlMaster:SetErrorMessage("CABREC",'CABJUSTF',"CABREC",'CABJUSTF',STR0046,STR0047)		 //"Há campos em branco no cabeçalho."#"Necessario justificar a substituição"#"Justifique a substituição no cabeçalho"
	EndIf

Else
	If Empty(oMdlRec:GetValue("CODREC")) .Or. If(oMdlRec:GetValue("TPREC") == '1',Empty(oMdlRec:GetValue("TIPO")),.F.)
		lRet		:= .F.
		oMdlMaster:SetErrorMessage("CABREC",'CODREC',"CABREC",'CODREC',STR0007,STR0035)	 //'Recurso'
	EndIf

Endif

If lRet
	For nX := 1 To oMdlVia:Length()
	
		oMdlVia:GoLine( nX )

		If oMdlVia:GetValue('CHECKVIA')
			If Empty(oMdlVia:GetValue('DTREF'))
				lRet := .F.
				oMdlMaster:SetErrorMessage("VIAGENS",'DTREF',"VIAGENS",'DTREF','DTREF',;
					I18N( STR0038,{oMdlVia:GetValue('VIAGEM'),oMdlVia:GetValue('SEQ')}),;//'Data Referencia não informada na viagem #1 sequencia #2'
					STR0039)  //"Marcado"#'Informe uma data de referencia da alocação'
				Exit
			ElseIf Empty(oMdlVia:GetValue('DORIGEM')) .or. Empty(oMdlVia:GetValue('HORIGEM'))
				lRet := .F.
				oMdlMaster:SetErrorMessage("VIAGENS",'',"VIAGENS",'','HORATRAB',;
					I18N( STR0040,{oMdlVia:GetValue('VIAGEM'),oMdlVia:GetValue('SEQ')}),;//'Data ou hora inicial do Trecho não informada na viagem #1 sequencia #2'
					STR0041)  //"Marcado"//'Informe a hora inicial ou final na viagem selecionada'
				Exit
			
			ElseIf Empty(oMdlVia:GetValue('DCHEGADA')) .or. Empty(oMdlVia:GetValue('HCHEGADA'))
				lRet := .F.
				oMdlMaster:SetErrorMessage("VIAGENS",'',"VIAGENS",'','HORATRAB',;
					I18N( STR0042,{oMdlVia:GetValue('VIAGEM'),oMdlVia:GetValue('SEQ')}),;//'Data ou hora final do Trecho não informada na viagem #1 sequencia #2'
					STR0043)  //"Marcado"#'Informe a hora inicial ou final na viagem selecionada'
				Exit
			
			ElseIf Empty(oMdlVia:GetValue('HRINITRAB')) .or. Empty(oMdlVia:GetValue('HRFIMTRAB')) 
				lRet := .F.
				oMdlMaster:SetErrorMessage("VIAGENS",'',"VIAGENS",'','HORATRAB',;
					I18N( STR0044,{oMdlVia:GetValue('VIAGEM'),oMdlVia:GetValue('SEQ')}),;//'Hora inicial ou final de trabalho não informada na viagem #1 sequencia #2'
					STR0045)  //"Marcado"#'Informe a hora inicial ou final na viagem selecionada'
				Exit
			Endif
			lMarcado := .T.
		Endif
	Next nX
	
	If !lMarcado 
		lRet := .F.
		oMdlMaster:SetErrorMessage("VIAGENS",'CHECKVIA',"VIAGENS",'CHECKVIA',STR0036,STR0037)  //"Marcado"
	Endif
EndIf

return (lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} G300BCommit
	Grava 
@author Fernando Amorim(Cafu)
@since		23/08/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
/*
**NOTAS DO DESENVOLVEDOR**
Cheguei a remover alguns trechos de código que não vi de onde poderia vir para entrar, 
sem contar que dá para melhorar a lógica (fica a dica), para não demorar na entrega da manutenção
estarei liberando dessa forma.
*/
Function G300BCarga(oView, lPosi)

Local oMldMonitor 	:= GC300GetMVC('M')
Local oMdlRec	 	:= oView:GetModel( 'CABREC' )
Local oMdlVia	 	:= oView:GetModel( 'VIAGENS' )
Local oMdlGQE
Local oMdlG55
Local oMdlGYN	
Local lRet  := .T.

Local cTmpAlias		:= GetNextAlias()
Local cGid          := "%%"
Local cRecurso      := "%%"
Local cWhere        := "%%"
Local lIsG300B      := fwisincallstack("GTPC300B")


oMdlGQE	 	:= oMldMonitor:GetModel( 'GQEDETAIL' )
oMdlG55	 	:= oMldMonitor:GetModel( 'G55DETAIL' )
oMdlGYN	 	:= oMldMonitor:GetModel( 'GYNDETAIL' )

cWhere := "%"

If !(EMPTY(oMdlRec:GetValue("CODVIAG")))
	cWhere += " AND GYN.GYN_CODIGO = '" + oMdlRec:GetValue("CODVIAG") + "' "
Else
	If lPosi
		cWhere += " AND GYN.GYN_CODIGO = '" + oMdlGYN:GetValue("GYN_CODIGO") + "' "
		oMdlRec:LoadValue("CODVIAG",oMdlGYN:GetValue("GYN_CODIGO"))
	EndIf
EndIf

If !(EMPTY(oMdlRec:GetValue("CODREC"))) .AND. !(EMPTY(oMdlRec:GetValue("TPREC")))
	cRecurso := "% AND GQE.GQE_RECURS IN(' ', '" + oMdlRec:GetValue("CODREC") + "') "
	cRecurso += " AND GQE.GQE_TRECUR IN(' ', '" + oMdlRec:GetValue("TPREC") + "')%"
EndIf

If !(EMPTY(MV_PAR04))
	cWhere += " AND GYN.GYN_LOCORI = '" + MV_PAR04 + "' "
EndIf

If !(EMPTY(MV_PAR05))
	cWhere += " AND GYN.GYN_LOCDES = '" + MV_PAR05 + "' "
EndIf

If MV_PAR07 == 1
	cWhere += " AND GYN_CANCEL  = '1' "
Endif

If MV_PAR06 == 1
	cGid := "%"
	cGid += "	LEFT JOIN "+RetSQLName("GID")+" GID "
	cGid += "		ON GID.GID_FILIAL = GYN.GYN_FILIAL "
	cGid += "		AND GID.GID_COD = GYN.GYN_CODGID "
	cGid += "		AND GID.GID_HIST = '2' "
	cGid += "		AND GID.GID_STATUS IN ('','1') "
	cGid += "		AND GID.GID_STATUS Is Not Null "
	cGid += "		AND GID.D_E_L_E_T_ = ' ' "
	cGid += "%"
EndIf

If !(EMPTY(MV_PAR03))
	cWhere += " AND EXISTS (   "
	cWhere += " 	SELECT G55_CODVIA   "
	cWhere += " 	FROM "+RetSQLName("G55")+" G55   "
	cWhere += " 		INNER JOIN "+RetSQLName("GY1")+" GY1 ON  "
	cWhere += " 			GY1_FILIAL = '"+xFilial("GY1")+"'  "
	cWhere += " 			AND GY1.D_E_L_E_T_ = ' '  "
	cWhere += " 			AND GY1_SETOR = '" + MV_PAR03 + "'  "
	cWhere += " 			AND (   "
	cWhere += " 					G55_LOCORI = GY1_LOCAL "
	cWhere += " 					OR                    "
	cWhere += " 					G55_LOCDES = GY1_LOCAL "
	cWhere += " 				)  "                     
	cWhere += " 	WHERE   "
	cWhere += " 		G55_FILIAL = GYN.GYN_FILIAL  "
	cWhere += " 		AND G55_CODVIA = GYN.GYN_CODIGO   "
	cWhere += " 		AND G55.D_E_L_E_T_ = ' ' "
	cWhere += " )  "  
EndIf

cWhere += "%"

BeginSql Alias cTmpAlias
	SELECT
		GYN.GYN_CODIGO,
		GYN.GYN_LINCOD,
		GYN.GYN_TIPO,
		G55.G55_SEQ,
		G55.G55_LOCORI,
		GI1ORI.GI1_DESCRI AS ORIGEM,
		G55.G55_LOCDES,
		GI1DES.GI1_DESCRI AS CHEGADA,
		G55.G55_DTPART,
		G55.G55_CODVIA,
		G55.G55_DTCHEG,
		G55.G55_HRINI,
		G55.G55_HRFIM,
		G55.G55_CANCEL,
		GQE.GQE_RECURS,
		GQE.GQE_TRECUR,
		GQE.GQE_DTREF,
		GQE.GQE_HRINTR,
		GQE.GQE_HRFNTR,
		GQE.GQE_TCOLAB,
		GQE.GQE_VIACOD,
		GQE.GQE_JUSTIF OBGQE
	FROM %Table:GYN% GYN
	INNER JOIN %Table:G55% G55
		ON G55.G55_FILIAL  = GYN.GYN_FILIAL
		AND G55.G55_CODVIA = GYN.GYN_CODIGO
		AND G55.G55_CODGID = GYN.GYN_CODGID
		AND G55.%NotDel%
	LEFT JOIN %Table:GQE% GQE
		ON GQE.GQE_FILIAL  = GYN.GYN_FILIAL
		AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
		AND GQE.GQE_SEQ    = G55.G55_SEQ
		AND GQE.%NotDel%
		%EXP:cRecurso%
	INNER JOIN %Table:GI1% GI1ORI 
		ON GI1ORI.GI1_FILIAL  = %xFilial:GI1%
		AND GI1ORI.GI1_COD    = G55.G55_LOCORI
		AND GI1ORI.%NotDel%
	INNER JOIN %Table:GI1% GI1DES 
		ON GI1DES.GI1_FILIAL  = %xFilial:GI1%
		AND GI1DES.GI1_COD    = G55.G55_LOCDES
		AND GI1DES.%NotDel%
		%exp:cGid%
	WHERE
		GYN.GYN_FILIAL     = %xFilial:GYN%
		AND ( 
			(GYN.GYN_DTINI >= %exp:DtoS(MV_PAR01)%  
			and GYN.GYN_DTFIM <= %exp:DtoS(MV_PAR02)% ) 
			or
			(GYN.GYN_DTINI >= %exp:DtoS(MV_PAR01)% and (%exp:DtoS(MV_PAR02)% BETWEEN GYN.GYN_DTINI AND GYN.GYN_DTFIM))
		) 
		AND GYN.%NotDel%
		%Exp:cWhere%
	ORDER BY G55.G55_FILIAL, G55.G55_CODVIA, G55.G55_SEQ
EndSql

While (cTmpAlias)->(!Eof())
	If !lPosi

		If Empty(oMdlRec:GetValue("CODVIAG"))
			If (cTmpAlias)->G55_CANCEL == '1'
				If lIsG300B
					If 	alltrim((cTmpAlias)->GQE_RECURS) == alltrim(oMdlRec:GetValue("CODREC")) .AND. (cTmpAlias)->GQE_TRECUR == oMdlRec:GetValue("TPREC") .AND. ;
						If(oMdlRec:GetValue("TPREC") == '1',(cTmpAlias)->GQE_TCOLAB == oMdlRec:GetValue("TIPO"),.T.)
						lRet = .T.
					Else
						lRet = .F.
					EndIf	
					If lRet .AND. !oMdlVia:IsEmpty() .AND. !Empty(oMdlVia:GetValue("VIAGEM")) 
						lRet := oMdlVia:Length() < oMdlVia:AddLine(.t.,.t.)
					endif
					
					If ( lRet )
						
						lRet := oMdlVia:LoadValue('VIAGEM'		,(cTmpAlias)->GYN_CODIGO) 	.And. ;
								oMdlVia:LoadValue('LINHA'		,TPNomeLinh((cTmpAlias)->GYN_LINCOD)) 	.And. ;
								oMdlVia:LoadValue('SEQ'			,(cTmpAlias)->G55_SEQ ) 	.And. ;
								oMdlVia:LoadValue('ORIGEM'		,(cTmpAlias)->ORIGEM) 	.And. ;
								oMdlVia:LoadValue('CHEGADA'		,(cTmpAlias)->CHEGADA) .And. ;							
								oMdlVia:LoadValue('DORIGEM'		,STOD((cTmpAlias)->G55_DTPART)) .And. ;
								oMdlVia:LoadValue('DCHEGADA'	,STOD((cTmpAlias)->G55_DTCHEG)) .And. ;
								oMdlVia:LoadValue('HORIGEM'		,(cTmpAlias)->G55_HRINI) .And. ;							
								oMdlVia:LoadValue('HCHEGADA'	,(cTmpAlias)->G55_HRFIM) .And. ;
								oMdlVia:LoadValue('DTREF'		,IIF(Empty(oMdlVia:GetValue('DTREF')),STOD((cTmpAlias)->G55_DTPART),STOD((cTmpAlias)->GQE_DTREF))) .And. ;
								oMdlVia:LoadValue('HRINITRAB'	,IIF(Empty(oMdlVia:GetValue('HRINITRAB')),(cTmpAlias)->G55_HRINI,(cTmpAlias)->GQE_HRINTR)) .And. ;
								oMdlVia:LoadValue('HRFIMTRAB'	,IIF(Empty(oMdlVia:GetValue('HRFIMTRAB')),(cTmpAlias)->G55_HRFIM,(cTmpAlias)->GQE_HRFNTR)) .And. ;
								oMdlVia:LoadValue('TPVIAGEM'	,(cTmpAlias)->GYN_TIPO) .And. ;
								oMdlVia:LoadValue('JUSTIF'		,(cTmpAlias)->OBGQE)
					EndIf				
				Else
					If (Empty((cTmpAlias)->GQE_VIACOD)) .Or. !oMdlGQE:SeekLine({ {'GQE_VIACOD',(cTmpAlias)->GYN_CODIGO},{"GQE_SEQ",(cTmpAlias)->G55_SEQ};
															,{"GQE_TRECUR",oMdlRec:GetValue("TPREC")},{"GQE_TCOLAB",If(oMdlRec:GetValue("TPREC")=='1',oMdlRec:GetValue("TIPO"),space(TamSx3("GQE_TCOLAB")[1]))}})	
											
					
						If ( lRet )
					
							If  !oMdlVia:IsEmpty() .AND. !Empty(oMdlVia:GetValue("VIAGEM")) 
								lRet := oMdlVia:Length() < oMdlVia:AddLine(.t.,.t.)
							endif
							
							lRet := oMdlVia:LoadValue('VIAGEM'		,(cTmpAlias)->GYN_CODIGO) 	.And. ;
									oMdlVia:LoadValue('LINHA'		,TPNomeLinh((cTmpAlias)->GYN_LINCOD)) 	.And. ;
									oMdlVia:LoadValue('SEQ'			,(cTmpAlias)->G55_SEQ ) 	.And. ;
									oMdlVia:LoadValue('ORIGEM'		,(cTmpAlias)->ORIGEM) 	.And. ;
									oMdlVia:LoadValue('CHEGADA'		,(cTmpAlias)->CHEGADA) .And. ;							
									oMdlVia:LoadValue('DORIGEM'		,STOD((cTmpAlias)->G55_DTPART)) .And. ;
									oMdlVia:LoadValue('DCHEGADA'	,STOD((cTmpAlias)->G55_DTCHEG)) .And. ;
									oMdlVia:LoadValue('HORIGEM'		,(cTmpAlias)->G55_HRINI) .And. ;							
									oMdlVia:LoadValue('HCHEGADA'	,(cTmpAlias)->G55_HRFIM) .And. ;
									oMdlVia:LoadValue('DTREF'		,STOD((cTmpAlias)->G55_DTPART)) .And. ;
									oMdlVia:LoadValue('HRINITRAB'	,(cTmpAlias)->G55_HRINI) .And. ;
									oMdlVia:LoadValue('HRFIMTRAB'	,(cTmpAlias)->G55_HRFIM) .And. ;
									oMdlVia:LoadValue('TPVIAGEM'	,(cTmpAlias)->GYN_TIPO) .And. ;
									oMdlVia:LoadValue('JUSTIF'		,(cTmpAlias)->OBGQE)
						EndIf				
					Endif
				Endif
			Endif
		Else
			If (cTmpAlias)->G55_CANCEL == '1'
				If !lIsG300B
					If (Empty((cTmpAlias)->GQE_VIACOD)) .Or. !oMdlGQE:SeekLine({ {'GQE_VIACOD',(cTmpAlias)->GYN_CODIGO},{"GQE_SEQ",(cTmpAlias)->G55_SEQ};
												,{"GQE_TRECUR",oMdlRec:GetValue("TPREC")},{"GQE_TCOLAB",""}})	
							
							
						If ( lRet ) .And. AllTrim(oMdlRec:GetValue("CODVIAG")) == (cTmpAlias)->G55_CODVIA
							
							If  !oMdlVia:IsEmpty() .AND. !Empty(oMdlVia:GetValue("VIAGEM")) 
								lRet := oMdlVia:Length() < oMdlVia:AddLine(.t.,.t.)
							endif
							
							lRet := oMdlVia:LoadValue('VIAGEM'		,(cTmpAlias)->GYN_CODIGO			) .And. ;
									oMdlVia:LoadValue('LINHA'		,TPNomeLinh((cTmpAlias)->GYN_LINCOD)) .And. ;
									oMdlVia:LoadValue('SEQ'			,(cTmpAlias)->G55_SEQ 				) .And. ;
									oMdlVia:LoadValue('ORIGEM'		,(cTmpAlias)->ORIGEM				) .And. ;
									oMdlVia:LoadValue('CHEGADA'		,(cTmpAlias)->CHEGADA				) .And. ;							
									oMdlVia:LoadValue('DORIGEM'		,STOD((cTmpAlias)->G55_DTPART)		) .And. ;
									oMdlVia:LoadValue('DCHEGADA'	,STOD((cTmpAlias)->G55_DTCHEG)		) .And. ;
									oMdlVia:LoadValue('HORIGEM'		,(cTmpAlias)->G55_HRINI				) .And. ;							
									oMdlVia:LoadValue('HCHEGADA'	,(cTmpAlias)->G55_HRFIM				) .And. ;
									oMdlVia:LoadValue('DTREF'		,IIF(Empty(oMdlVia:GetValue('DTREF')),STOD((cTmpAlias)->G55_DTPART),STOD((cTmpAlias)->GQE_DTREF))) .And. ;
									oMdlVia:LoadValue('HRINITRAB'	,(cTmpAlias)->G55_HRINI				) .And. ;
									oMdlVia:LoadValue('HRFIMTRAB'	,(cTmpAlias)->G55_HRFIM				) .And. ;
									oMdlVia:LoadValue('TPVIAGEM'	,(cTmpAlias)->GYN_TIPO				) .And. ;
									oMdlVia:LoadValue('JUSTIF'		,(cTmpAlias)->OBGQE					)
									
						EndIf				
					Endif
				Endif
			Endif
		EndIf
		
	Else
		oMdlRec:LoadValue("CODVIAG",(cTmpAlias)->GYN_CODIGO)
		If  !oMdlVia:IsEmpty() .AND. !Empty(oMdlVia:GetValue("VIAGEM")) 
			oMdlVia:AddLine(.T.,.T.)
		Endif
		oMdlVia:LoadValue('VIAGEM'   , (cTmpAlias)->GYN_CODIGO)
		oMdlVia:LoadValue('LINHA'    , TPNomeLinh((cTmpAlias)->GYN_LINCOD))
		oMdlVia:LoadValue('SEQ'      , (cTmpAlias)->G55_SEQ )
		oMdlVia:LoadValue('ORIGEM'   , (cTmpAlias)->ORIGEM)
		oMdlVia:LoadValue('CHEGADA'  , (cTmpAlias)->CHEGADA)
		oMdlVia:LoadValue('DORIGEM'  , STOD((cTmpAlias)->G55_DTPART))
		oMdlVia:LoadValue('DCHEGADA' , STOD((cTmpAlias)->G55_DTCHEG))
		oMdlVia:LoadValue('HORIGEM'  , (cTmpAlias)->G55_HRINI)
		oMdlVia:LoadValue('HCHEGADA' , (cTmpAlias)->G55_HRFIM)
		oMdlVia:LoadValue('TPVIAGEM' , (cTmpAlias)->GYN_TIPO) 
		oMdlVia:LoadValue('JUSTIF'   , (cTmpAlias)->OBGQE)
		oMdlVia:LoadValue('DTREF'	 , IIF(lIsG300B,STOD((cTmpAlias)->GQE_DTREF),STOD((cTmpAlias)->G55_DTPART)))
		oMdlVia:LoadValue('HRINITRAB', IIF(lIsG300B,(cTmpAlias)->GQE_HRINTR,(cTmpAlias)->G55_HRINI))
		oMdlVia:LoadValue('HRFIMTRAB', IIF(lIsG300B,(cTmpAlias)->GQE_HRFNTR,(cTmpAlias)->G55_HRFIM))
	
		lPosicionado	:= .T.
		
	EndIf	
	(cTmpAlias)->(DbSkip())
EndDo

(cTmpAlias)->(DbCloseArea())

 
oMdlVia:Goline(1)
oView:Refresh("VIAGENS")

Return()


/*/{Protheus.doc} Gtpc300Ter
//TODO Descrição auto-gerada.
@author osmar.junior
@since 21/02/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function Gtpc300Ter(oModel)
Local lRet:= .F.

	If FWIsInCallStack("GTPC300A")
		lRet := oModel:GetValue('CHECKTER')
	ElseIf FWIsInCallStack("GTPC300I") .OR. FWIsInCallStack("GTPC300K") .OR. FWIsInCallStack("GTPC300E")
		lRet := oModel:GetValue('GQE_TERC') == '1'
	ElseIf	FWIsInCallStack("GTPC300B")
		IF ('CODREC' $ ReadVar() .AND. oModel:GetValue('CHECKTER'))
			lRet := .T.
		ElseIf ('SUBSREC' $ ReadVar() .AND. oModel:GetValue('CHECKTERSU'))
			lRet := .T.	
		EndIf
		
	EndIf

Return lRet

