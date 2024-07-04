//#Include "GTPA700I.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA700I()
Lançamento de titulos de bilhetes cancelados pagos com cartão
@author  Fernando Amorim da Costa
@since   22/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA700I(nOperation)
Local oMdl700B		:= FwLoadModel('GTPA700B')

If FwIsInCallStack("G700LoadMov")

	oMdl700B:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl700B:Activate()
	oMdl700B:CommitData()
	oMdl700B:Destroy()
	
Else
    FWExecView( 'Bilhetes cancelados pago com Cartão', 'VIEWDEF.GTPA700I', nOperation, , { || .T. } )  //
Endif

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da view do lançamento de taxas
@author  Renan Ribeiro Brando
@since   08/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel("GTPA700B")
Local oStruCab	    := FWFormViewStruct():New()
Local oStruGrd	    := FWFormViewStruct():New()
Local oStruG6Y      := FWFormStruct(2,"G6Y")
//Local oStruTot1     := FWCalcStruct( oModel:GetModel('700TOTAL2') )


oModel:SetDescription("BIlhetes cancelados pago com Cartão")

G700IStruct(oStruCab,oStruGrd,oStruG6Y,"V")

oView := FWFormView():New()

oView:SetModel(oModel)	

oView:AddField("VIEW_CAB" , oStruCab , "CABESC")
oView:AddGrid("V_FICHA"   , oStruGrd , "GRID1")
oView:AddGrid("V_LANCAM"  , oStruG6Y , "GRID2")
//oView:AddField("V_TOTAL1" , oStruTot1, "700TOTAL2")


oView:CreateHorizontalBox("CABECALHO" , 15) // Cabeçalho
oView:CreateHorizontalBox("FCHDEREME" , 30) // Ficha de Remessa
oView:CreateHorizontalBox("LANCAMENT" , 55) // Lançamentos Diários de Taxas
//oView:CreateHorizontalBox("TOTALIZA"  , 15) // Totalizadores
	
//oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
//oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")

//oView:EnableTitleView("V_TOTAL1","Total a Pagar")

oView:AddIncrementField( 'V_LANCAM', 'G6Y_ITEM' )
	
oView:SetOnlyView("CABESC")
oView:SetOnlyView("GRID1")
	
oView:SetNoInsertLine("V_FICHA")
oView:SetNoDeleteLine("V_FICHA")
	
	
oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
oView:SetOwnerView( "V_FICHA", "FCHDEREME")
oView:SetOwnerView( "V_LANCAM", "LANCAMENT")
//oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
//oView:SetOwnerView( "V_TOTAL2", "TOTAL2")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} G700IStruct(oStruCab,oStruGrd,oStruG6Y,cTipo) 
Define a estrutura do modelo e da view
@author  Renan Ribeiro Brando
@since   08/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function G700IStruct(oStruCab,oStruGrd,oStruG6Y,cTipo) 

Local cFieldsIn		:= ''
Local aFldStr		:= {}
Local nI			:= 0
Local aOrdem        := {}

If ( cTipo == "M" )
	// não usado		
Else

	If ValType( oStruCab ) == "O"
	
		oStruCab:AddField(	"FILIAL",;					// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        "Filial",;					// [03]  C   Titulo do campo
	                        "Filial",;					// [04]  C   Descricao do campo
	                        {"Filial"},;				// [05]  A   Array com Help // "Selecionar"
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
		
		oStruCab:AddField(	"CAIXA",;					// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        "Caixa",;					// [03]  C   Titulo do campo
	                        "Caixa",;					// [04]  C   Descricao do campo
	                        {"Caixa"},;					// [05]  A   Array com Help // "Selecionar"
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
	
	    oStruCab:AddField(	"AGENCIA",;					// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        "Agência",;					// [03]  C   Titulo do campo
	                        "Código da Agêndia",;		// [04]  C   Descricao do campo
	                        {"Código da Agência"},;		// [05]  A   Array com Help // "Selecionar"
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
				
	    oStruCab:AddField(	"DESCRIAGEN",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        "Descrição",;				// [03]  C   Titulo do campo
	                        "Descrição da Agência",;	// [04]  C   Descricao do campo
	                        {"Descrição da Agência"},;	// [05]  A   Array com Help // "Selecionar"
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
	                        
	                        
	                        
		    //Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL
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
	                        "Filial",;					// [03]  C   Titulo do campo
	                        "Filial",;					// [04]  C   Descricao do campo
	                        {"Filial"},;				// [05]  A   Array com Help // "Selecionar"
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
	        
	        oStruGrd:AddField(	"CODCX",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        "Caixa",;					// [03]  C   Titulo do campo
	                        "Caixa",;					// [04]  C   Descricao do campo
	                        {"Caixa"},;					// [05]  A   Array com Help // "Selecionar"
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
	                        
	         oStruGrd:AddField(	"CODAGE",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        "Agencia",;					// [03]  C   Titulo do campo
	                        "Agencia",;					// [04]  C   Descricao do campo
	                        {"Agencia"},;				// [05]  A   Array com Help // "Selecionar"
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
	
					 		
			oStruGrd:AddField(	"FICHA",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        "Ficha de Remessa",;		// [03]  C   Titulo do campo
	                        "Ficha de Remessa",;		// [04]  C   Descricao do campo
	                        {"Código da Ficha de Remessa"},;// [05]  A   Array com Help // "Selecionar"
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
	                        
	                        
	            
	                        
	        oStruGrd:AddField(	"DTINI",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        "Data Incial",;				// [03]  C   Titulo do campo
	                        "Data Incial",;				// [04]  C   Descricao do campo
	                        {"Data Incial"},;			// [05]  A   Array com Help // "Selecionar"
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
			
			oStruGrd:AddField(	"DTFIN",;				// [01]  C   Nome do Campo
	                        "06",;						// [02]  C   Ordem
	                        "Data Final",;				// [03]  C   Titulo do campo
	                        "Data Final",;				// [04]  C   Descricao do campo
	                        {"Data Final"},;			// [05]  A   Array com Help // "Selecionar"
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
			
							 		
		
		 //Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL
		cFieldsIn := "FICHA|DTINI|DTFIN|"
	
		
		 aFldStr := aClone(oStruGrd:GetFields())
	
	    For nI := 1 to Len(aFldStr)
	
	        If ( !(aFldStr[nI,1] $ cFieldsIn) )
	            oStruGrd:RemoveField(aFldStr[nI,1])
	        EndIf
	
	    Next nI
		
	EndIf
	
		
    If ValType( oStruG6Y ) == "O"
    	
    
	    //Ajusta quais os campos que deverão aparecer na tela - Grid G6YPDETAIL
		cFieldsIn := "G6Y_AGRUPA|G6Y_BILHET|G6Y_DATA|G6Y_VALOR|G6Y_CODNSU|G6Y_CODAUT|G6Y_CODADM|G6Y_CHVTX"
	
		
		aFldStr := aClone(oStruG6Y:GetFields())
	
	    For nI := 1 to Len(aFldStr)
	
	        If ( !(aFldStr[nI,1] $ cFieldsIn) )
	            oStruG6Y:RemoveField(aFldStr[nI,1])
	        EndIf
	
	    Next nI
	    
	    AAdd(aOrdem, {"G6Y_AGRUPA","G6Y_BILHET"})
	    AAdd(aOrdem, {"G6Y_BILHET","G6Y_DATA"})
        AAdd(aOrdem, {"G6Y_DATA","G6Y_VALOR"})
        AAdd(aOrdem, {"G6Y_VALOR","G6Y_CODNSU"})
		AAdd(aOrdem, {"G6Y_CODNSU", "G6Y_CODAUT"})
		AAdd(aOrdem, {"G6Y_CODAUT", "G6Y_CODADM"})
		AAdd(aOrdem, {"G6Y_CODADM", "G6Y_CHVTX"})

		GTPOrdVwStruct(oStruG6Y, aOrdem)
	    
		// -------------------------------------+
		// DEFINE EDITA DOS CAMPOS G6Y|
		// -------------------------------------+
		oStruG6Y:SetProperty( '*'	        , MVC_VIEW_CANCHANGE,  .F. )	
        oStruG6Y:SetProperty( 'G6Y_AGRUPA'	, MVC_VIEW_CANCHANGE,  .T. )
					
				
	EndIf
        
EndIf

Return()


