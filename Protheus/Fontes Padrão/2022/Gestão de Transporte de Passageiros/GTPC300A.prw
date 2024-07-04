#Include "GTPC300A.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
Static nOpc	:= 0

/*/{Protheus.doc} GTPC300A
Função responsavel pela inclusão de recurso no monitor
@type function
@author jacomo.fernandes
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300A()
Local lMonitor	:= GC300GetMVC('IsActive')


If lMonitor
	nOpc := Aviso( STR0001,	STR0023, { "Posicionada", "Todas","Cancelar"},1) //"Finalizar Viagens" //'Deseja Finalizar a viagem posicionada ou todas ? ' //Posicionada  //Todas // Cancelar	
	If nOpc == 1 .Or. nOpc == 2
		FWExecView( STR0001, 'VIEWDEF.GTPC300A', MODEL_OPERATION_INSERT, , { || .T. } ) //'Inclusão de Recurso'
	EndIf
Else
	FwAlertHelp(STR0001,STR0002) //"Inclusão de Recurso";"Esta rotina só funciona com monitor ativo"
Endif
	
return

//-------------------------------------------------------------------

Static Function ViewDef()

Local oView			:= Nil	
																					
Local oStruRec	    := FWFormViewStruct():New()
Local oStruVia	 	:= FWFormViewStruct():New() 

Local oModel		:= FWLoadModel("GTPC300B")
Local oMdlMonit		:= GC300GetMVC('M')
Local oMdlGYN		:= oMdlMonit:GetModel("GYNDETAIL")
						
Local bAction 		:= {|oView,lFilter,c300BOrigem|;	
						lFilter := .f.,;
						c300BOrigem := "GTPC300A",;
						CursorWait(),;
						lFilter := G300BChkFilter(oView,c300BOrigem	),;
						Iif(lFilter,G300BCarga(oView, .F.),nil),;
						CursorArrow() }			
						

oModel:SetDescription(STR0001) //'Inclusão de recursos'
G300AStruct(oStruRec,oStruVia,"V") 

If oMdlGYN:GetValue('GYN_TIPO')=='1' //Normal 
	oStruRec:AddField( 'CHECKTER', ; // cIdField
					'06', ; // cOrdem
					STR0024,;//'Terceiro', ; // cTitulo // 'Mark'
					STR0024,;//'Terceiro', ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
					{STR0024},;//{'Terceiro'}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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

oView:EnableTitleView("VIEW_REC", 'Recurso') //'Recurso'
oView:EnableTitleView("VIEW_VIA", STR0004) //'Viagens'

oView:SetViewProperty("VIEW_VIA"	, "GRIDSEEK", {.T.})
oView:SetViewProperty("VIEW_VIA"	, "GRIDFILTER", {.T.}) 

oView:AddUserButton( STR0005, "", bAction,,VK_F5 ) //"Executar Filtro"
oView:AddUserButton( STR0006, "", {||G300BCMkAll()}) //"Marque/Desmarque todos"

oView:ShowInsertMsg(.F.)

If nOpc == 1
	oView:SetAfterViewActivate({|oView,lFilter,c300BOrigem|;	
						lFilter := .f.,;
						c300BOrigem := "GTPC300A",;
						CursorWait(),;
						lFilter := G300BChkFilter(oView,c300BOrigem,.T.	),;
						Iif(lFilter,G300BCarga(oView,.T.),nil),;
						CursorArrow() }	)
EndIf
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
Static Function G300AStruct(oStruRec,oStruVia,cTipo) 


If ( cTipo == "M" )
	// não usado		
Else
    If ValType( oStruRec ) == "O"
	    oStruRec:AddField(	"TPREC",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0022,;						// [03]  C   Titulo do campo
	                        STR0022,;						// [04]  C   Descricao do campo
	                        {STR0025},;//{'Recurso'},;					// [05]  A   Array com Help // "Selecionar"
	                        "COMBO",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        {STR0007,STR0008},;		// [13]  A   Lista de valores permitido do campo (Combo)
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
	                        STR0009,;						// [03]  C   Titulo do campo
	                        STR0009,;						// [04]  C   Descricao do campo
	                        {STR0009},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0010,;						// [03]  C   Titulo do campo
	                        STR0010,;						// [04]  C   Descricao do campo
	                        {STR0010},;					// [05]  A   Array com Help // "Selecionar"
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
	    
	    oStruRec:AddField(	"CODVIAG",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        STR0026,;//"Cod. Viagem",;						// [03]  C   Titulo do campo
	                        STR0027,;//"Codigo Viagem",;						// [04]  C   Descricao do campo
	                        {},;					// [05]  A   Array com Help // "Selecionar"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .T.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;					// [13]  A   Lista de valores permitido do campo (Combo)
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
				STR0011, ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				{STR0012}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
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
	                        STR0013,;						// [03]  C   Titulo do campo
	                        STR0013,;						// [04]  C   Descricao do campo
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0014,;						// [03]  C   Titulo do campo
	                        STR0014,;						// [04]  C   Descricao do campo
	                        {STR0014},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0015,;						// [03]  C   Titulo do campo
	                        STR0015,;						// [04]  C   Descricao do campo
	                        {STR0015},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0016,;						// [03]  C   Titulo do campo
	                        STR0016,;						// [04]  C   Descricao do campo
	                        {STR0016},;					// [05]  A   Array com Help // "Selecionar"
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
	      
	      oStruVia:AddField("DTREF",;				// [01]  C   Nome do Campo
	                        "07",;						// [02]  C   Ordem
	                        STR0028,;//'Dt. Ref.',;						// [03]  C   Titulo do campo
	                        STR0028,;//'Dt. Ref.',;						// [04]  C   Descricao do campo
	                        {STR0029},;//{'Data de Referencia de alocação'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0018,;						// [03]  C   Titulo do campo
	                        STR0018,;						// [04]  C   Descricao do campo
	                        {STR0018},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0030,;//'Hr.Ini.Tr.',;						// [03]  C   Titulo do campo
	                        STR0030,;//'Hr.Ini.Tr.',;						// [04]  C   Descricao do campo
	                        {STR0030},;//{'Hr.Ini.Tr.'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0019,;						// [03]  C   Titulo do campo
	                        STR0019,;						// [04]  C   Descricao do campo
	                        {STR0019},;					// [05]  A   Array com Help // "Selecionar"
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
	                        
	                        
	      oStruVia:AddField(	"DCHEGADA",;				// [01]  C   Nome do Campo
	                        "11",;						// [02]  C   Ordem
	                        STR0020,;						// [03]  C   Titulo do campo
	                        STR0020,;						// [04]  C   Descricao do campo
	                        {STR0020},;					// [05]  A   Array com Help // "Selecionar"
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
	       
	      oStruVia:AddField(	"HCHEGADA",;				// [01]  C   Nome do Campo
	                        "12",;						// [02]  C   Ordem
	                        STR0021,;						// [03]  C   Titulo do campo
	                        STR0021,;						// [04]  C   Descricao do campo
	                        {STR0021},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0031,;//'Hr.Fim.Tr.',;						// [03]  C   Titulo do campo
	                        STR0031,;//'Hr.Fim.Tr.',;						// [04]  C   Descricao do campo
	                        {STR0032},;//{'Hora Final de Trabalho'},;					// [05]  A   Array com Help // "Selecionar"
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
	                        STR0033,;//"Tp Viagem",;						// [03]  C   Titulo do campo
	                        STR0034,;//"Tipo Viagem",;						// [04]  C   Descricao do campo
	                        {STR0034},;//{'Tipo Viagem'},;					// [05]  A   Array com Help // "Selecionar"
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
    Endif
EndIf

Return()
