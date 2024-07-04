#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#include 'totvs.ch'
#include 'gtpa700a.ch'

Function GTPA700A(nOperation)

FWExecView(STR0003, 'VIEWDEF.GTPA700A', nOperation, , { || .T. } ) //'Lançamento de documento de entrada' 


Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700A()

Lançamento diário do Financeiro - Aba Documento de Entrada.
 
@sample	GTPA700A()
 
@return	
 
@author	SIGAGTP |Fernando Amorim(Cafu)
@since		30/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oModel		:= FWLoadModel("GTPA700B")
Local oStruCab	    := FWFormViewStruct():New()
Local oStruGrd	    := FWFormViewStruct():New()
Local oStruG6Y      := FWFormStruct(2,"G6Y")
Local oStruTot1     := FWCalcStruct( oModel:GetModel('700TOTAL1') )
Local oStruTot2     := FWCalcStruct( oModel:GetModel('700TOTAL2') )


	G700AStruct(oStruCab,oStruGrd,oStruG6Y,"V")

	oView := FWFormView():New()

	oView:SetModel(oModel)	

	oView:AddField("VIEW_CAB",oStruCab,"CABESC")
	oView:AddGrid("V_FICHA"  ,oStruGrd,"GRID1")
	oView:AddGrid("V_LANCAM" ,oStruG6Y,"GRID2")
	oView:AddField("V_TOTAL1" ,oStruTot1,'700TOTAL1')
	oView:AddField("V_TOTAL2" ,oStruTot2,'700TOTAL2')


	oView:CreateHorizontalBox("CABECALHO" , 15) // Cabeçalho
	oView:CreateHorizontalBox("FCHDEREME" , 25) // Ficha de Remessa
	oView:CreateHorizontalBox("LANCAMENT" , 45) // Lançamentos Diários
	oView:CreateHorizontalBox("TOTALIZA"  , 15) // Totalizadores
	
	oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
	oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")

	oView:EnableTitleView("V_TOTAL1", STR0007) // "Total Ficha de Remessa"
	oView:EnableTitleView("V_TOTAL2", STR0008) // "Total de Lançamento Diário"

	oView:AddUserButton(STR0009, '', {|| MATA103()} ) //'Documento de Entrada'
	oView:AddIncrementField( 'V_LANCAM', 'G6Y_ITEM' )
	
	oView:SetOnlyView("CABESC")
	oView:SetOnlyView("GRID1")
	
	oView:SetNoInsertLine("V_FICHA")
	oView:SetNoDeleteLine("V_FICHA")
	
	
	oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
	oView:SetOwnerView( "V_FICHA", "FCHDEREME")
	oView:SetOwnerView( "V_LANCAM", "LANCAMENT")
	oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
	oView:SetOwnerView( "V_TOTAL2", "TOTAL2")

	

Return(oView)



/*/{Protheus.doc} G700AStruct()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 30/10/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G700AStruct(oStruCab,oStruGrd,oStruG6Y,cTipo) 

Local cFieldsIn		:= ''
Local aFldStr		:= {}
Local nI			:= 0
Local aOrdem		:= {}
If ( cTipo == "M" )
	// não usado		
Else

	If ValType( oStruCab ) == "O"
	
		oStruCab:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0010,;						// [03]  C   Titulo do campo // "Filial"
	                        STR0010,;						// [04]  C   Descricao do campo  // "Filial"
	                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
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
	                        STR0011,;						// [03]  C   Titulo do campo // "Caixa"
	                        STR0011,;						// [04]  C   Descricao do campo // "Caixa"
	                        {STR0011},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
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
	                        STR0012,;						// [03]  C   Titulo do campo // "Agência"
	                        STR0013,;						// [04]  C   Descricao do campo // "Código da Agência"
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
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
	                        STR0014,;						// [03]  C   Titulo do campo // "Descricao"
	                        STR0015,;						// [04]  C   Descricao do campo // "Descrição da Agência"
	                        {STR0015},;					// [05]  A   Array com Help // "Selecionar" // "Descrição da Agência"
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
	                        STR0010,;						// [03]  C   Titulo do campo // "Filial"
	                        STR0010,;						// [04]  C   Descricao do campo // "Filial"
	                        {STR0010},;					// [05]  A   Array com Help // "Selecionar"  // "Filial"
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
	        
	        oStruGrd:AddField(	"CODCX",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0011,;						// [03]  C   Titulo do campo // "Caixa"
	                        STR0011,;						// [04]  C   Descricao do campo // "Caixa"
	                        {STR0011},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
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
	                        
	         oStruGrd:AddField(	"CODAGE",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0012,;						// [03]  C   Titulo do campo // "Agência"
	                        STR0013,;						// [04]  C   Descricao do campo // "Código da Agência"
	                        {STR0013},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
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
	                        STR0016,;						// [03]  C   Titulo do campo // "Data Inicial"
	                        STR0016,;						// [04]  C   Descricao do campo // "Data Inicial"
	                        {STR0016},;					// [05]  A   Array com Help // "Selecionar" // "Data Inicial"
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
    	oStruG6Y:AddField(	"NOTA",;				// [01]  C   Nome do Campo // "Nota"
	                        "01",;						// [02]  C   Ordem
	                        "   ",;						// [03]  C   Titulo do campo
	                        STR0018,;						// [04]  C   Descricao do campo // "Nota"
	                        {STR0018},;					// [05]  A   Array com Help // "Selecionar" // "Nota"
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
		cFieldsIn := "NOTA|G6Y_TIPOL|G6Y_ITEM|G6Y_NOTA|G6Y_SERIE|G6Y_FORNEC|"
		cFieldsIn += "G6Y_LOJA|G6Y_NOME|G6Y_DATA|G6Y_TPLACX|G6Y_VALOR|G6Y_NATURE|G6Y_CC|G6Y_CONTA"
	
		
		 aFldStr := aClone(oStruG6Y:GetFields())
	
	    For nI := 1 to Len(aFldStr)
	
	        If ( !(aFldStr[nI,1] $ cFieldsIn) )
	            oStruG6Y:RemoveField(aFldStr[nI,1])
	        EndIf
	
	    Next nI
	      AAdd(aOrdem,{"NOTA","G6Y_TIPOL"})
	      AAdd(aOrdem,{"G6Y_TIPOL","G6Y_ITEM"})
		  AAdd(aOrdem,{"G6Y_ITEM","G6Y_NOTA"})
		  AAdd(aOrdem,{"G6Y_NOTA","G6Y_SERIE"})
		  AAdd(aOrdem,{"G6Y_SERIE","G6Y_FORNEC"})
		  AAdd(aOrdem,{"G6Y_FORNEC","G6Y_LOJA"})
		  AAdd(aOrdem,{"G6Y_LOJA","G6Y_NOME"})
		  AAdd(aOrdem,{"G6Y_NOME","G6Y_DATA"})
		  AAdd(aOrdem,{"G6Y_DATA","G6Y_TPLACX"})		  
		  AAdd(aOrdem,{"G6Y_TPLACX","G6Y_VALOR"})
		  
					    
		  GTPOrdVwStruct(oStruG6Y,aOrdem)
		// -------------------------------------+
		// DEFINE EDITA DOS CAMPOS G6Y|
		// -------------------------------------+
		oStruG6Y:SetProperty( '*'	, MVC_VIEW_CANCHANGE,  .F. )
		oStruG6Y:SetProperty( 'G6Y_TIPOL'	, MVC_VIEW_CANCHANGE,  .T. )
		oStruG6Y:SetProperty( 'G6Y_DATA'	, MVC_VIEW_CANCHANGE,  .T. )	
		oStruG6Y:SetProperty( 'G6Y_TPLACX'	, MVC_VIEW_CANCHANGE,  .T. )			
		//Acrescentado por Fernando Radu em 15/03/2018 - início
		oStruG6Y:SetProperty( 'G6Y_NOTA'	, MVC_VIEW_CANCHANGE,  .T. )
		oStruG6Y:SetProperty( 'G6Y_SERIE'	, MVC_VIEW_CANCHANGE,  .T. )
		//fim inclusão		
		oStruG6Y:SetProperty( 'G6Y_VALOR'	, MVC_VIEW_CANCHANGE,  .T. )
		oStruG6Y:SetProperty( 'G6Y_NATURE'	, MVC_VIEW_CANCHANGE,  .T. )
		oStruG6Y:SetProperty( 'G6Y_CC'	, MVC_VIEW_CANCHANGE,  .T. )
		oStruG6Y:SetProperty( 'G6Y_CONTA'	, MVC_VIEW_CANCHANGE,  .T. )
	EndIf
        
EndIf

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDNF()

Função responsável pela validação da nota fiscal
 
@sample	VLDNF()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function VLDNF(oGrid,cCpo,xValAtu)

Local lRet		:= .T.
Local cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry
		
	SELECT  F1_DOC
	FROM %Table:SF1% SF1
	WHERE F1_FILIAL = %xFilial:SF1%
	AND F1_DOC = %Exp:xValAtu%
	AND %NotDel%
		
EndSQL

If (cAliasQry)->(!Eof())
	
	lRet		:= .T.
	
Else
	lRet		:= .F.
	FwAlertHelp(STR0019, STR0020) // "Nota de Entrada", "Informe um numero válido"	
Endif
If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
Endif	
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} T700ACalc()

Função responsável pela calculo da ficha de remessa
 
@sample	T700ACalc()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/
Function T700ACalc(oModel)

Local nVlFicha	:= 0
Local oMdlFicha	:= oModel:GetModel("GRID1")
Local cAliasQry := GetNextAlias()


BeginSQL Alias cAliasQry
		
	SELECT  G6X_VLRLIQ,G59_RECBIL,G59_RECTAX
	FROM %Table:G6X% G6X 
	INNER JOIN %Table:G59% G59 ON
	G6X.G6X_FILIAL = G59.G59_FILIAL AND
	G6X.G6X_AGENCI = G59.G59_AGENCI AND
	G6X.G6X_NUMFCH = G59.G59_NUMFCH AND
	G59.%NotDel%
	WHERE G6X.G6X_FILIAL = %xFilial:G6X%
	AND G6X.G6X_STATUS In ('3','4')
	AND G6X.G6X_FLAGCX = 'T'
	AND G6X.G6X_NUMFCH = %Exp:oMdlFicha:GetValue("FICHA")%
	AND G6X.G6X_AGENCI = %Exp:oMdlFicha:GetValue("CODAGE")%
	AND G6X.%NotDel%
		
EndSQL
	
If (cAliasQry)->(!Eof())
	nVlFicha	:= (cAliasQry)->G59_RECBIL + (cAliasQry)->G59_RECTAX
Endif

If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
Endif

Return nVlFicha


Static Function FINDNF(oMdlG6Y,oMdlFCH,cFicha)

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
	Endif
					
Next nY

RestArea(aArea)
FWRestRows( aSaveLines )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA700AX3WhenG6Y()

Rotina responsavel por habilitar a edição dos campos com base no tipo de trecho (Campo TIPO)

@sample	GA700AX3WhenG6Y()

@Param		oGrid - Objeto Grid  
@Param		cCampo - Nome do campo a ser avaliado.

@author	Fernando Amorim(Cafu)
@since		21/12/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------


Function GA700AX3WhenG6Y(oGrid, cCampo)

Local cTipo			:= oGrid:GetValue("G6Y_TIPOL")
Local cFields 		:= ""
Local lRet 			:= .F.
	
	If cTipo == "1" 
		cFields := "NOTA|G6Y_TIPOL|G6Y_ITEM|G6Y_TPLACX|G6Y_NOTA|G6Y_SERIE|G6Y_FORNEC|G6Y_LOJA|G6Y_DATA|G6Y_VALOR|G6Y_TPLACX|G6Y_NATURE|G6Y_CC|G6Y_CONTA"
	Else
		cFields := "G6Y_TIPOL|G6Y_ITEM|G6Y_DATA|G6Y_VALOR|G6Y_TPLACX|G6Y_NATURE|G6Y_CC|G6Y_CONTA"	
	EndIf
		
	lRet := AllTrim(cCampo) $ cFields
	
	
Return (lRet)
