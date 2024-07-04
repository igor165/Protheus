#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPC300Q.CH"

Static nOpc	:= 0

/*/{Protheus.doc} GTPC300Q
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300Q()
Local lMonitor	:= GC300GetMVC('IsActive')
Local aEnableButtons := GtpBtnView(.F.,,.T.,)


If lMonitor
	nOpc := Aviso(STR0001,	STR0002, { STR0003, STR0004,STR0005},1) //"Ocorrencia x Viagens" //'Deseja Finalizar a ocorrencia posicionada ou todas ? ' //Posicionada  //Todas // Cancelar	
	If nOpc == 1 .Or. nOpc == 2
		FWExecView( STR0006, 'VIEWDEF.GTPC300Q', MODEL_OPERATION_INSERT,,,,,aEnableButtons,,,, ) //'Finalizar a ocorrencia' 
	EndIf
Else
	FwAlertHelp(STR0006,STR0007) //"'Finalizar a ocorrencia'";"Esta rotina só funciona com monitor ativo"
Endif
	
return


/*/{Protheus.doc} ViewDef
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

Local oView			:= Nil	
																					
Local oStruRec	    := FWFormViewStruct():New()
Local oStruVia	 	:= FWFormViewStruct():New() 

Local oModel		:= FWLoadModel("GTPC300Q")
Local c300BOrigem   := ''
Local lFilter		:= .F.
						
Local bAction 		:= {|oView,lFilter,c300BOrigem|;	
						lFilter := .f.,;
						c300BOrigem := "GTPC300Q",;
						CursorWait(),;
						lFilter := G300QChkFilter(oView,c300BOrigem,.F.	),;
						Iif(lFilter,G300QCarga(oView, .F.),nil),;
						CursorArrow() }			
						

oModel:SetDescription(STR0006) //'Finalizar a ocorrencia'


G300QStruct(oStruRec,oStruVia,"V") 


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

oView:EnableTitleView("VIEW_REC", STR0008) //'Ocorrencia'
oView:EnableTitleView("VIEW_VIA", STR0009) //'Viagens'

oView:SetViewProperty("VIEW_VIA"	, "GRIDSEEK", {.T.})
oView:SetViewProperty("VIEW_VIA"	, "GRIDFILTER", {.T.}) 
If nOpc == 2
	oView:AddUserButton( STR0010, "", bAction,,VK_F5 ) //"Executar Filtro"
EndIf
oView:AddUserButton( STR0011, "", {||G300QCMkAll()}) //"Marque/Desmarque todos"
oView:AddUserButton( STR0012 , "", {||G300QGrava(oModel)}) //"Marque/Desmarque todos"


oView:ShowInsertMsg(.F.)

If nOpc == 1
	oView:SetAfterViewActivate({|oView,lFilter,c300BOrigem|;	
						lFilter := .f.,;
						c300BOrigem := "GTPC300Q",;
						CursorWait(),;
						lFilter := G300QChkFilter(oView,c300BOrigem,.T.	),;
						Iif(lFilter,G300QCarga(oView,.T.),nil),;
						CursorArrow() }	)
EndIf
Return(oView)


/*/{Protheus.doc} ModelDef
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()

Local oModel		:= Nil
Local oStruRec  	:= FWFormModelStruct():New() // Recursos
Local oStruVia  	:= FWFormModelStruct():New() // Viagens

G300QStruct(oStruRec,oStruVia,"M")

oModel := MPFormModel():New('GTPC300Q',/*bPreValid*/, /*{|oMdl| G300QTudoOk(oMdl)}/*bPosValid*/, /*bCommit*/, /*bCancel*/)


oModel:AddFields("CABREC",/*PAI*/,oStruRec,,/*bPost*/,/*bLoad*/)
oModel:AddGrid("VIAGENS", "CABREC", oStruVia,,,,,)

oModel:GetModel("CABREC"):SetOnlyQuery(.t.)
oModel:GetModel("VIAGENS"):SetOnlyQuery(.t.)
oModel:GetModel( 'VIAGENS' ):SetNoDeleteLine( .T. )
oModel:GetModel("CABREC"):SetDescription(STR0008) //"Ocorrencias"
oModel:GetModel('VIAGENS'):SetDescription(STR0013)  //"Viagens e Trechos"


oModel:SetDescription(STR0014) //'Finalização de Ocorrencias'

oModel:SetPrimaryKey({})

Return (oModel)


/*/{Protheus.doc} G300BStruct()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author 
    @since 
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G300QStruct(oStruRec,oStruVia,cTipo) 


If ( cTipo == "M" )
	If ValType( oStruRec ) == "O"
		oStruRec:AddTable("   ",{" "}," ")

    	oStruRec:AddField(	'Tipo Rec.',;									// 	[01]  C   Titulo do campo
					 		'Tipo Rec.',;									// 	[02]  C   ToolTip do campo
					 		"TPREC",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		1,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;	// 	[07]  B   Code-block de validação do campo
					 		Nil,; // 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	
		oStruRec:AddField( '   ', ; // cTitle // 'Mark'
				'Passageiro',;//'Terceiro', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKPAS', ; // cIdField
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
				'Veiculo',;//'Terceiro Subst.', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKVEI', ; // cIdField
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
				'Operacional',;//'Terceiro Subst.', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKOPE', ; // cIdField
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

		oStruRec:AddField(	'Status',;									// 	[01]  C   Titulo do campo
					'Status',;									// 	[02]  C   ToolTip do campo
					"STATUS",;							// 	[03]  C   Id do Field
					"C",;									// 	[04]  C   Tipo do campo
					1,;										// 	[05]  N   Tamanho do campo
					0,;										// 	[06]  N   Decimal do campo
					Nil,;	// 	[07]  B   Code-block de validação do campo
					Nil,; // 	[08]  B   Code-block de validação When do campo
					Nil,;									//	[09]  A   Lista de valores permitido do campo
					.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					Nil,;									//	[11]  B   Code-block de inicializacao do campo
					.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)									// 	[14]  L   Indica se o campo é virtual		


	
	Endif
	
	If ValType( oStruVia ) == "O"
			
    	oStruVia:AddTable("   ",{" "}," ")			 		
		oStruVia:AddField( '   ', ; // cTitle // 'Mark'
				'Mark', ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'CHECKVIA', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				{|oModel, cCampo, xValueNew, nLine, xValueOld| G300QVldMark(oModel, cCampo, xValueNew, nLine, xValueOld) }, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual		
		oStruVia:AddField(	'Viagem',;						// 	[01]  C   Titulo do campo
				 		    'Viagem',;				// 	[02]  C   ToolTip do campo
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
		
		oStruVia:AddField(	'Linha',;						// 	[01]  C   Titulo do campo
				 		    'Linha',;				// 	[02]  C   ToolTip do campo
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
		
		oStruVia:AddField(	'Seq',;						// 	[01]  C   Titulo do campo
				 		    'Seq',;				// 	[02]  C   ToolTip do campo
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
					 		
		oStruVia:AddField(	'Origem',;						// 	[01]  C   Titulo do campo
				 		    'Origem',;				// 	[02]  C   ToolTip do campo
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
		
		oStruVia:AddField(	'Chegada',;						// 	[01]  C   Titulo do campo
				 		    'Chegada',;				// 	[02]  C   ToolTip do campo
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
					 		
		oStruVia:AddField(	"Dt. Ref",;//"Dt. Ref",;						// 	[01]  C   Titulo do campo
				 		    "Dt. Ref",;//"Dt. Ref",;				// 	[02]  C   ToolTip do campo
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
					 		
		
		oStruVia:AddField(	'Dt. Origem',;						// 	[01]  C   Titulo do campo
				 		    'Dt. Origem',;				// 	[02]  C   ToolTip do campo
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
		
		oStruVia:AddField(	'Hr.Ini.Tr.',;//'Hr.Ini.Tr.',;						// 	[01]  C   Titulo do campo
				 		    'Hr.Ini.Tr.',;//'Hr.Ini.Tr.',;				// 	[02]  C   ToolTip do campo
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
		
		oStruVia:AddField(	'Hr. Origem',;						// 	[01]  C   Titulo do campo
				 		    'Hr. Origem',;				// 	[02]  C   ToolTip do campo
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
		
		
		oStruVia:AddField(	'Dt.Chegada',;						// 	[01]  C   Titulo do campo
				 		    'Dt.Chegada',;				// 	[02]  C   ToolTip do campo
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
					 		
		oStruVia:AddField(	'Hr. Chegada',;						// 	[01]  C   Titulo do campo
				 		    'Hr. Chegada',;				// 	[02]  C   ToolTip do campo
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
					 		
		oStruVia:AddField(	'Hr.Fim.Tr.',;//'Hr.Fim.Tr.',;						// 	[01]  C   Titulo do campo
				 		    'Hr.Fim.Tr.',;//'Hr.Fim.Tr.',;				// 	[02]  C   ToolTip do campo
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

		
		oStruVia:AddField(	"Tp Viagem",;//"Tp Viagem",;			// 	[01]  C   Titulo do campo
				 		    "Tp Viagem",;//"Tp Viagem",;			// 	[02]  C   ToolTip do campo
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

		oStruVia:AddField(	"Cod. Ocor.",;//"Cod. Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Cod. Ocor.",;//"Cod. Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"CODOCORR",;							// 	[03]  C   Id do Field
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

		
		oStruVia:AddField(	"Rec. Ocor.",;//"Rec. Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Rec. Ocor.",;//"Rec. Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"RECOCORR",;							// 	[03]  C   Id do Field
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

		oStruVia:AddField(	"Tipo. Ocor.",;//"Tipo. Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Tipo. Ocor.",;//"Tipo. Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"TIPOOCOR",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		11,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		oStruVia:AddField(	"Desc. Ocor.",;//"Desc. Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Desc. Ocor.",;//"Desc. Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"DESCRCOR",;							// 	[03]  C   Id do Field
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

		oStruVia:AddField(	"Desc. Ocor.",;//"Memo. Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Desc. Ocor.",;//"Memo. Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"OBSERVACAO",;							// 	[03]  C   Id do Field
					 		"M",;									// 	[04]  C   Tipo do campo
					 		100,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual			

		oStruVia:AddField(	"Status Ocor.",;//"Status Ocor.",;			// 	[01]  C   Titulo do campo
				 		    "Status Ocor.",;//"Status Ocor.",;			// 	[02]  C   ToolTip do campo
					 		"STATUS",;							// 	[03]  C   Id do Field
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

	
	Endif	
						
Else //VIEW
    If ValType( oStruRec ) == "O"
	    oStruRec:AddField(	"TPREC",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        'Tpo Recurso',;						// [03]  C   Titulo do campo
	                        'Tipo de Recurso',;						// [04]  C   Descricao do campo
	                        {'Recurso'},;//{'Recurso'},;					// [05]  A   Array com Help // "Selecionar"
	                        "COMBO",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        {"1=Colaborador","2=Veículo"},;		// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	    
	   
	  oStruRec:AddField( 'CHECKPAS', ; // cIdField
						'02', ; // cOrdem
						'Passageiro',;//'Terceiro', ; // cTitulo // 'Mark'
						'Passageiro',;//'Terceiro', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
						{'Passageiro'},;//{'Terceiro'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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

	  oStruRec:AddField( 'CHECKVEI', ; // cIdField
						'03', ; // cOrdem
						'Veiculo',;//'Veiculo', ; // cTitulo // 'Mark'
						'Veiculo',;//'Veiculo', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
						{'Veiculo'},;//{'Veiculo'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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

	 oStruRec:AddField( 'CHECKOPE', ; // cIdField
						'04', ; // cOrdem
						'Operacianal',;//'Operacianal', ; // cTitulo // 'Mark'
						'Operacianal',;//'Operacianal', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
						{'Operacianal'},;//{'Operacianal'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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

	    oStruRec:AddField(	"STATUS",;				// [01]  C   Nome do Campo
						"05",;						// [02]  C   Ordem
						'Status',;						// [03]  C   Titulo do campo
						'Status',;						// [04]  C   Descricao do campo
						{'Status'},;//{'Recurso'},;					// [05]  A   Array com Help // "Selecionar"
						"COMBO",;					// [06]  C   Tipo do campo
						"",;						// [07]  C   Picture
						NIL,;						// [08]  B   Bloco de Picture Var
						"",;						// [09]  C   Consulta F3
						.T.,;						// [10]  L   Indica se o campo é alteravel
						NIL,;						// [11]  C   Pasta do campo
						"",;						// [12]  C   Agrupamento do campo
						{"1=Finalizadas","2=Operacional","3=Sem Operacional","4=Todas"},;		// [13]  A   Lista de valores permitido do campo (Combo)
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
				'Mark', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				{'Marque as ocorrecias'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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
	                        'Viagem',;						// [03]  C   Titulo do campo
	                        'Viagem',;						// [04]  C   Descricao do campo
	                        {'Viagem'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Linha',;						// [03]  C   Titulo do campo
	                        'Linha',;						// [04]  C   Descricao do campo
	                        {'Linha'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Seq',;						// [03]  C   Titulo do campo
	                        'Seq',;						// [04]  C   Descricao do campo
	                        {'Seq'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Loc. Origem',;						// [03]  C   Titulo do campo
	                        'Loc. Origem',;						// [04]  C   Descricao do campo
	                        {'Loc. Origem'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        "Loc. Chegada",;						// [03]  C   Titulo do campo
	                        "Loc. Chegada",;						// [04]  C   Descricao do campo
	                        {"Loc. Chegada"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Dt. Ref.',;//'Dt. Ref.',;						// [03]  C   Titulo do campo
	                        'Dt. Ref.',;//'Dt. Ref.',;						// [04]  C   Descricao do campo
	                        {'Dt. Ref.'},;//{'Data de Referencia de alocação'},;					// [05]  A   Array com Help // "Selecionar"
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
	      
	                        
	      oStruVia:AddField("DORIGEM",;				// [01]  C   Nome do Campo
	                        "08",;						// [02]  C   Ordem
	                        "Dt. Partida",;						// [03]  C   Titulo do campo
	                        "Dt. Partida",;						// [04]  C   Descricao do campo
	                        {"Dt. Partida"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Hr.Ini.Tr.',;//'Hr.Ini.Tr.',;						// [03]  C   Titulo do campo
	                        'Hr.Ini.Tr.',;//'Hr.Ini.Tr.',;						// [04]  C   Descricao do campo
	                        {'Hr.Ini.Tr.'},;//{'Hr.Ini.Tr.'},;					// [05]  A   Array com Help // "Selecionar"
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
	      
	       
	      oStruVia:AddField("HORIGEM",;				// [01]  C   Nome do Campo
	                        "10",;						// [02]  C   Ordem
	                        "Hr. Partida",;						// [03]  C   Titulo do campo
	                        "Hr. Partida",;						// [04]  C   Descricao do campo
	                        {"Hr. Partida"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        "Dt. Chegada",;						// [03]  C   Titulo do campo
	                        "Dt. Chegada",;						// [04]  C   Descricao do campo
	                        {"Dt. Chegada"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        "Hr. Chegada",;						// [03]  C   Titulo do campo
	                        "Hr. Chegada",;						// [04]  C   Descricao do campo
	                        {"Hr. Chegada"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        'Hr.Fim.Tr.',;//'Hr.Fim.Tr.',;						// [03]  C   Titulo do campo
	                        'Hr.Fim.Tr.',;//'Hr.Fim.Tr.',;						// [04]  C   Descricao do campo
	                        {'Hr.Fim.Tr.'},;//{'Hora Final de Trabalho'},;					// [05]  A   Array com Help // "Selecionar"
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
								"Tp Viagem",;//"Tp Viagem",;						// [03]  C   Titulo do campo
								"Tp Viagem",;//"Tipo Viagem",;						// [04]  C   Descricao do campo
								{"Tp Viagem"},;//{'Tipo Viagem'},;					// [05]  A   Array com Help // "Selecionar"
								"Get",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								GTPXCBox('GYN_TIPO'),;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo

		oStruVia:AddField(	"CODOCORR",;				// [01]  C   Nome do Campo
								"15",;						// [02]  C   Ordem
								"Cod. Ocor.",;//"Cod. Ocor.",;						// [03]  C   Titulo do campo
								"Cod. Ocor.",;//"Cod. Ocor.",;						// [04]  C   Descricao do campo
								{"Cod. Ocor."},;//{"Cod. Ocor."},;					// [05]  A   Array com Help // "Selecionar"
								"Get",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								nil,;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo						

		oStruVia:AddField(	"RECOCORR",;				// [01]  C   Nome do Campo
								"16",;						// [02]  C   Ordem
								"Tipo Rec.",;//"Tipo Rec.",;						// [03]  C   Titulo do campo
								"Tipo Rec.",;//"Tipo Rec.",;						// [04]  C   Descricao do campo
								{"Tipo Rec."},;//{"Tipo Rec."},;					// [05]  A   Array com Help // "Selecionar"
								"COMBOBOX",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								{'2=Veiculo','1=Colaborador'},;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo

			
		oStruVia:AddField(	"DESCRCOR",;				// [01]  C   Nome do Campo
								"17",;						// [02]  C   Ordem
								"Desc. Ocor.",;//"Tipo Ocor.",;						// [03]  C   Titulo do campo
								"Desc. Ocor.",;//"Tipo Ocor.",;						// [04]  C   Descricao do campo
								{"Desc. Ocor."},;//{"Tipo Ocor."},;					// [05]  A   Array com Help // "Selecionar"
								"Get",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								nil,;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo					

		oStruVia:AddField(	"OBSERVACAO",;				// [01]  C   Nome do Campo
								"18",;						// [02]  C   Ordem
								"Observação",;//"Tipo Ocor.",;						// [03]  C   Titulo do campo
								"Observação",;//"Tipo Ocor.",;						// [04]  C   Descricao do campo
								{"Observação"},;//{"Tipo Ocor."},;					// [05]  A   Array com Help // "Selecionar"
								"Get",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								nil,;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo	

		oStruVia:AddField(	"STATUS",;				// [01]  C   Nome do Campo
								"19",;						// [02]  C   Ordem
								"Status",;//"Tipo Ocor.",;						// [03]  C   Titulo do campo
								"Status",;//"Tipo Ocor.",;						// [04]  C   Descricao do campo
								{"Status"},;//{"Tipo Ocor."},;					// [05]  A   Array com Help // "Selecionar"
								"COMBOBOX",;					// [06]  C   Tipo do campo
								"@!",;						// [07]  C   Picture
								NIL,;						// [08]  B   Bloco de Picture Var
								"",;						// [09]  C   Consulta F3
								.F.,;						// [10]  L   Indica se o campo é alteravel
								NIL,;						// [11]  C   Pasta do campo
								"",;						// [12]  C   Agrupamento do campo
								{'1=Finalizada','2=Com operacional','3=Sem Operacional'},;		// [13]  A   Lista de valores permitido do campo (Combo)
								NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
								NIL,;						// [15]  C   Inicializador de Browse
								.T.,;						// [16]  L   Indica se o campo é virtual
								NIL,;						// [17]  C   Picture Variavel
								.F.)						// [18]  L   Indica pulo de linha após o campo							


    Endif
EndIf

Return()


/*/{Protheus.doc} G300QCarga
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G300QCarga(oView, lPosi)

Local oMldMonitor 	:= GC300GetMVC('M')
Local oMdlRec	 	:= oView:GetModel( 'CABREC' )
Local oMdlVia	 	:= oView:GetModel( 'VIAGENS' )
Local oMdlGQE
Local oMdlG55
Local oMdlGYN	  
Local nX		 	:= 0
Local cFiltro := ''
Local cRecurso := ''
Local cStatus  := ''

oMdlGQE	 	:= oMldMonitor:GetModel( 'GQEDETAIL' )
oMdlG55	 	:= oMldMonitor:GetModel( 'G55DETAIL' )
oMdlGYN	 	:= oMldMonitor:GetModel( 'GYNDETAIL' )

If !lPosi

	If !Empty(oMdlRec:GetValue("TPREC") )//"1=Colaborador","2=Veículo"
		cRecurso += "AND G6Q_RECURS = '"+oMdlRec:GetValue("TPREC")+"' "
	EndIf
	
	If oMdlRec:GetValue("CHECKPAS") 
		cFiltro += "AND G6Q_PASSAG = 'T' "
	EndIf 

	If oMdlRec:GetValue("CHECKVEI")
		If oMdlRec:GetValue("CHECKPAS")  
			cFiltro += "OR G6Q_VEICUL = 'T' "
		else
			cFiltro += "AND G6Q_VEICUL = 'T' "
		EndIf	
	EndIf 		

	If oMdlRec:GetValue("CHECKOPE") 
		If oMdlRec:GetValue("CHECKVEI")  
			cFiltro += "OR G6Q_OPERAC = 'T' "
		else
			cFiltro += "AND G6Q_OPERAC = 'T' "
		EndIf	
	EndIf 	


	If oMdlRec:GetValue("STATUS") <> '4' //Todas
		cStatus += "AND GYN_STSOCR = '"+oMdlRec:GetValue("STATUS")+"' "
	EndIf	 
			 
		
	For nX := 1 To oMdlGYN:Length()
		oMdlGYN:GoLine( nX )
				
		ListOcorre( oMdlGYN:GetValue("GYN_FILIAL"), oMdlGYN:GetValue("GYN_CODIGO") , oView , cFiltro, cRecurso , cStatus)
		
	Next nX	
	
Else
			
	ListOcorre( oMdlGYN:GetValue("GYN_FILIAL"), oMdlGYN:GetValue("GYN_CODIGO") , oView )
	

EndIf 
oMdlVia:Goline(1)
oView:Refresh("VIAGENS")

Return()

/*/{Protheus.doc} G300QChkFilter
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G300QChkFilter(oView,c300BOrigem, lPosi)

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


If c300BOrigem =='GTPC300Q' .and. !fwisincallstack("FWALERTHELP")
	If !Empty(oMldRec:GetValue("TPREC")) .AND. ( oMldRec:GetValue("CHECKPAS") .OR. oMldRec:GetValue("CHECKVEI") .OR. oMldRec:GetValue("CHECKOPE") ) .Or. lPosi
		lRet		:= .T.
		oMldVia:GOLINE(1)
		
	Else
		lRet		:= .F.
		FwAlertHelp(STR0015,STR0016) 		 //"Filtro"
	EndIf	
	
Elseif !fwisincallstack("FWALERTHELP")
	If oMldRec:GetValue("TPREC") == '1'
		lRet		:= .T.
		oMldVia:GOLINE(1)
	Else
		lRet		:= .F.
		FwAlertHelp(STR0015,STR0016) 	 //"Filtro"
	EndIf

Endif

If ( lRet .AND. ( oMldRec:GetValue("CHECKPAS") .OR. oMldRec:GetValue("CHECKVEI") .OR. oMldRec:GetValue("CHECKOPE") ) .AND. (nOpera == 3 .Or. nOpera == 4) .AND. !fwisincallstack("FWALERTYESNO")  .AND. !fwisincallstack("FWALERTSUCCESS") .AND. !fwisincallstack("FWALERTERROR") .AND. ;
     !fwisincallstack("FWALERTHELP") .AND. !fwisincallstack("FWALERTEXITPAGE") )
	If !lPosi
		lRet := MsgYesNo(STR0017) //"Deseja realmente refazer o filtro ?"
	EndIf
	If ( lRet )

		oMldRec:SetValue("CHECKPAS", .T. )
		oMldRec:SetValue("CHECKVEI", .T. )
		oMldRec:SetValue("CHECKOPE", .T. )		
		oView:GetModel("VIAGENS"):ClearData()
		oView:Refresh("VIEW_VIA")
		
	EndIf
ElseIf lRet .AND. Empty(oMldVia:GetValue("VIAGEM")) .And. oView:IsActive() .AND. !fwisincallstack("FWALERTYESNO")
	lRet := .T.
Else
	lRet := .F.
EndIf

Return(lRet)


/*/{Protheus.doc} ListOcorre
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static FuncTion ListOcorre( cFilialGYN, cCodViagem, oView, cFiltro, cRecurso, cStatus )

Local oMldMonitor := GC300GetMVC('M')
Local oMdlVia     := oView:GetModel( 'VIAGENS' )
Local oMdlGQE     := oMldMonitor:GetModel( 'GQEDETAIL' )
Local oMdlG55     := oMldMonitor:GetModel( 'G55DETAIL' )
Local oMdlGYN     := oMldMonitor:GetModel( 'GYNDETAIL' )
Local cTipoRec    := ''
Local cAliasTmp   := GetNextAlias()
Local nRecNoG56   := nil
Local aAreaG56    := G56->(GetArea())

Default cFiltro  := ''
Default cRecurso := ''
Default cStatus  := ''

	cFiltro := "%" + cFiltro + "%"
	cRecurso:= "%" + cRecurso + "%"
	cStatus := "%" + cStatus + "%"

	BeginSQL Alias cAliasTmp
	
		SELECT 
			GYN.GYN_STSOCR,
			G6Q.G6Q_PASSAG,
			G6Q.G6Q_VEICUL,
			G6Q.G6Q_RECURS,
			G6Q.G6Q_DESCRI,
			G56.G56_CODIGO,
			G56.G56_STSOCR,
			G56.R_E_C_N_O_ RECNOG56
		FROM 
			%table:GYN% GYN
			INNER JOIN %table:G56% G56 
				ON G56.G56_VIAGEM   = GYN.GYN_CODIGO 
				AND G56.G56_FILIAL  = %exp:cFilialGYN% 
				AND G56.G56_VIAGEM  = %exp:cCodViagem% 
				AND G56.%notDel%
				%exp:cStatus% 
			INNER JOIN %table:G6Q% G6Q 
				ON G6Q.G6Q_FILIAL  = %xFilial:G6Q%
				AND G6Q.G6Q_CODIGO = G56.G56_TPOCOR 
				AND G6Q.%notDel% 
				%exp:cRecurso%
		WHERE GYN.GYN_FILIAL = %exp:cFilialGYN%
			AND GYN.%notDel% 
			%exp:cFiltro%
	
	EndSQL

	If (cAliasTmp)->(!Eof())
		While (cAliasTmp)->(!Eof())
			
			If  !oMdlVia:IsEmpty() .AND. !Empty(oMdlVia:GetValue("VIAGEM")) 
				lRet := oMdlVia:Length() < oMdlVia:AddLine(.t.,.t.)
			endif
			
			If (cAliasTmp)->G6Q_PASSAG
				cTipoRec := STR0018//'Passageiro'
			ElseIf	(cAliasTmp)->G6Q_VEICUL
				cTipoRec := STR0019//'Veiculo'
			Else
				cTipoRec := STR0020//'Operacional'
			EndIf	

			nRecNoG56 := (cAliasTmp)->RECNOG56	
			G56->( DbGoto(nRecNoG56) )			

			lRet := oMdlVia:LoadValue('VIAGEM'		,oMdlGYN:GetValue("GYN_CODIGO")) 	.And. ;
					oMdlVia:LoadValue('LINHA'		,TPNomeLinh(oMdlGYN:GetValue("GYN_LINCOD"))) 	.And. ;
					oMdlVia:LoadValue('SEQ'			,oMdlG55:GetValue("G55_SEQ") ) 	.And. ;
					oMdlVia:LoadValue('ORIGEM'		,posicione("GI1",1,xFilial("GI1")+oMdlG55:GetValue("G55_LOCORI"),"GI1_DESCRI")) 	.And. ;
					oMdlVia:LoadValue('CHEGADA'		,posicione("GI1",1,xFilial("GI1")+oMdlG55:GetValue("G55_LOCDES"),"GI1_DESCRI")) .And. ;							
					oMdlVia:LoadValue('DORIGEM'		,oMdlG55:GetValue("G55_DTPART")) .And. ;
					oMdlVia:LoadValue('DCHEGADA'	,oMdlG55:GetValue("G55_DTCHEG")) .And. ;
					oMdlVia:LoadValue('HORIGEM'		,oMdlG55:GetValue("G55_HRINI")) .And. ;							
					oMdlVia:LoadValue('HCHEGADA'	,oMdlG55:GetValue("G55_HRFIM")) .And. ;
					oMdlVia:LoadValue('DTREF'		,oMdlGQE:GetValue("GQE_DTREF")) .And. ;
					oMdlVia:LoadValue('HRINITRAB'	,oMdlGQE:GetValue("GQE_HRINTR")) .And. ;
					oMdlVia:LoadValue('HRFIMTRAB'	,oMdlGQE:GetValue("GQE_HRFNTR")) .And. ;
					oMdlVia:LoadValue('TPVIAGEM'	,oMdlGYN:GetValue("GYN_TIPO")) .And. ;
					oMdlVia:LoadValue('CODOCORR'	,(cAliasTmp)->G56_CODIGO ) .And. ;
					oMdlVia:LoadValue('RECOCORR'	,(cAliasTmp)->G6Q_RECURS ) .And. ; 
					oMdlVia:LoadValue('TIPOOCOR'	,cTipoRec ) .And. ;
					oMdlVia:LoadValue('DESCRCOR'	,(cAliasTmp)->G6Q_DESCRI ) .And. ;
					oMdlVia:LoadValue('OBSERVACAO'	,G56->G56_MEMO ) .And. ;
					oMdlVia:LoadValue('STATUS'	    ,(cAliasTmp)->G56_STSOCR ) 
					
			If lRet
				If Empty(oMdlVia:GetValue('DTREF'))
					lRet := oMdlVia:LoadValue('DTREF',oMdlG55:GetValue("G55_DTPART"))
				Endif
				If lRet.and. Empty(oMdlVia:GetValue('HRINITRAB'))
					lRet := oMdlVia:LoadValue('HRINITRAB',oMdlG55:GetValue("G55_HRINI"))
				Endif
				If lRet.and. Empty(oMdlVia:GetValue('HRFIMTRAB'))
					lRet := oMdlVia:LoadValue('HRFIMTRAB',oMdlG55:GetValue("G55_HRFIM"))
				Endif
			Endif	

		(cAliasTmp)->(DbSkip())
		End	
	Endif	

	RestArea(aAreaG56)				

Return


/*/{Protheus.doc} G300QVldMark
Função responsavel pela validação (Criação para padronização e futuro uso)
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G300QVldMark( oMdlBase, cCampo, xValueNew, nLine, xValueOld)

Local lRet       	:= .T. 

Return lRet


/*/{Protheus.doc} G300QCMkAll
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G300QCMkAll(lAut)

Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oGridVia	:= Nil
Local nI		:= 1

Default lAut    := .F.

If !lAut
	
	oGridVia := oModel:GetModel('VIAGENS')
	
	For nI := 1 To oGridVia:Length()
		oGridVia:GoLine( nI )
		
		If oGridVia:GetValue("CHECKVIA")
			oGridVia:SetValue("CHECKVIA", .F.)	
		Else 	
			oGridVia:SetValue("CHECKVIA", .T.)				
		EndIf
			
		oModel:GetErrorMessage(.T.)	
	Next nI

Endif

Return lRet

/*/{Protheus.doc} G300QGrava
Função responsavel pela finalização de ocorrencias
@type function
@author GTP
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function G300QGrava(oMdlMaster, lAut)

Local lRet  := .T.
Local oMdl300 := FwLoadModel("GTPA300")
Local oMldMonitor 	:= GC300GetMVC('M')
Local oViewMonitor	:= GC300GetMVC('V')
Local oMdlVia	 	:= OMdlMaster:GetModel( 'VIAGENS' )
Local oMdlGYN	 	:= oMldMonitor:GetModel( 'GYNDETAIL' )
Local oMdl300P		:= Nil
Local nX		 	:= 0

Default lAut 		:= .F.

if !lAut
	If MsgYesNo(STR0021) //'Deseja relamente finalizar as ocorrências marcadas?'

		For nX := 1 To oMdlVia:Length()

				oMdlVia:GoLine( nX )

				If oMdlVia:GetValue('CHECKVIA')	
						oMdlGYN:GoLine(1)									
						If oMdlGYN:SeekLine({ {'GYN_CODIGO', oMdlVia:GetValue( 'VIAGEM' )}})

							DbSelectArea("G56")
							DbSetOrder(3)
							If G56->( DBSeek(xFilial("G56") + oMdlVia:GetValue( 'VIAGEM' ) ) )	

								oMdl300P	 := FWLoadModel("GTPC300P") 	
								oMdl300P:SetOperation(MODEL_OPERATION_UPDATE)
								oMdl300P:Activate()	
								If oMdl300P:IsActive()	
								
									oMdl300P:GetModel("G56DETAIL"):SetValue("G56_STSOCR",'1')

									If oMdl300P:VldData()   	
										oMdl300P:CommitData()
										oMdl300P:DeActivate() 
									Else
										JurShowErro( oMdl300P:GetModel():GetErrormessage() )	
										lRet := .F.
									EndIf 
										
								EndIf		
										
								If lRet	
									If GYN->(DbSeek(xFilial("GYN") + oMdlVia:GetValue( 'VIAGEM' )))
										oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
										IF oMdl300:Activate()
											oMdl300:GetModel("GYNMASTER"):LoadValue("GYN_STSOCR",'1')

											If oMdl300:VldData()
												oMdl300:CommitData()
											Else
												lRet := .F.
											EndIf
											oMdl300:DeActivate()

											oMdlGYN:loadValue( "GYN_STSOCR"	, '1' )
							

											GC300SetLegenda(oMdlGYN)
																				
											oMdlVia:loadValue( "STATUS"	, '1' )
											
										Endif
									Endif	
								Endif

							Endif
						
						Else
							lRet := .F.
						Endif

				EndIf
				
		Next nX

		Aviso( STR0023, STR0022, {"Ok"}) //'Aviso' - 'Ocorrência(s) finalizada(s).'

	EndIf

	If lRet
		oViewMonitor:Refresh("G55DETAIL")
		oViewMonitor:Refresh("GQEDETAIL")
	EndIf
endif

Return(lRet)
