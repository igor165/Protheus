#INCLUDE 'GTPA410A.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWBROWSE.CH'

Static aProcesso		:= {}
Static aAux				:= {}
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPA410

Cálculo de Comissão de Agência

@sample 	GTPA410()

@author		SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12  
@comments  
/*///------------------------------------------------------------------------------
Function GTPA410A(aExpFil)
Local lRet	:= .T.
aProcesso	:= aclone(aExpFil)

	FWExecView(  STR0001, "VIEWDEF.GTPA410A", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Nota Fiscal"
						{|| .T. } ,/*bOk*/, 50, /*aEnablBuettons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
						
aExpFil	:= aclone(aProcesso)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@sample		ModelDef()

@return		oModel 		Objeto do Model

@author	 	SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12
/*///-------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel
	Local oStrCab	:= FWFormModelStruct():New() // Cabeçalho
	Local oStruTit	:= FWFormModelStruct():New() // Nova estrutura para seleção da nota
	Local aRelacao	:= {}
	Local bLoadGrd		:= {|oModel| GC410Acti(oModel, aProcesso)}
	Local bCommit	:= {|oModel| GC410GRV(oModel)}
	oStrCab:AddTable("CAB",{},"Master")
	oStruTit:AddTable("GRD",{},"GRID")
	
	GCB410CabStruct(oStrCab, .T.)	
	GA410Struct(oStruTit)	
	
	oModel := MPFormModel():New('GTPA410A',/*bPreValid*/, /*bPost*/, bCommit)
	
	//GaLoadStruct(oStrCab)
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("CABFAKE", , oStrCab, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("GRIDFAKE", "CABFAKE", oStruTit, /*bLinePre*/, /*bLinePost*/, /*bPosVal*/, /*bLoad*/,)
	
	oModel:SetDescription(STR0001)						//"Nota Fiscal"
	oModel:GetModel("CABFAKE"):SetDescription(STR0001)//"Nota Fiscal"
	oModel:GetModel("GRIDFAKE"):SetDescription(STR0001)//"Nota Fiscal"
	oModel:SetPrimaryKey({})
	
	oModel:SetActivate( bLoadGrd )
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 	SI4503 - Marcio Martins Pereira  
@since	 	10/02/2016 
@version	P12
/*///-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel	:= FWLoadModel('GTPA410A')
	Local oStrCab	:= FWFormViewStruct():New()
	Local oStruTit	:= FWFormViewStruct():New() // View da seleção de titulo, campo fake
	Local oView		:= Nil
	
	GCB410CabStruct(oStrCab, .F.)
	GA410Struct(oStruTit, .T.)
	
	oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	
	oView:AddGrid('VW_GRIDFAKE', oStruTit, 'GRIDFAKE')
	
	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('CORPO', 100)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VW_GRIDFAKE', 'CORPO')
	
	//Habitila os títulos dos modelos para serem apresentados na tela
	oView:EnableTitleView('VW_GRIDFAKE',STR0002)//"Seleção de Nota Fiscal"
			
Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA410Struct()
Estrutura fake
@sample	InitDados()
@author	Yuki Shiroma
@since		24/11/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Static Function GA410Struct(oStruct, lView)

Local aArea   := GetArea()
Local aTrigAux	:= {}
Local aCampo	:= {}
Local aOpera	:= {}
Local aParen	:= {}

DEFAULT lView := .F.

//-------------------------------+
// lView = .T. - Estrutura Model |
//-------------------------------+
If !lView
	oStruct:AddField( ;       // Ord. Tipo Desc.
       STR0003    ,; // [01] C Titulo do campo##Cod. Proce
       STR0003    ,; // [02] C ToolTip do campo Cod. Proce
       "GRD_CODPROC"   ,; // [03] C identificador (ID) do Field
       "C"     ,; // [04] C Tipo do campo
       6      ,; // [05] N Tamanho do campo
       0      ,; // [06] N Decimal do campo
       {|| .T.}   ,; // [07] B Code-block de validação do campo
       NIL     ,; // [08] B Code-block de validação When do campo
       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
       Nil , ; // [11] B Code-block de inicializacao do campo
       NIL     ,; // [12] L Indica se trata de um campo chave
       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
       .T. )        // [14] L Indica se o campo é virtual
       
	oStruct:AddField( ;       // Ord. Tipo Desc.
       STR0004    ,; // [01] C Titulo do campo##"Fornec"
       STR0004    ,; // [02] C ToolTip do campo
       "GRD_FORNEC"   ,; // [03] C identificador (ID) do Field
       "C"     ,; // [04] C Tipo do campo
       6      ,; // [05] N Tamanho do campo
       0      ,; // [06] N Decimal do campo
       {|| .T.}   ,; // [07] B Code-block de validação do campo
       NIL     ,; // [08] B Code-block de validação When do campo
       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
       Nil , ; // [11] B Code-block de inicializacao do campo
       NIL     ,; // [12] L Indica se trata de um campo chave
       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
       .T. )        // [14] L Indica se o campo é virtual
       
	oStruct:AddField( ;       // Ord. Tipo Desc.
       STR0005    ,; // [01] C Titulo do campo##"Loja"
       STR0005    ,; // [02] C ToolTip do campo
       "GRD_LOJA"   ,; // [03] C identificador (ID) do Field
       "C"     ,; // [04] C Tipo do campo
       TAMSX3('A1_LOJA')[1]	     ,; // [05] N Tamanho do campo
       0      ,; // [06] N Decimal do campo
       {|| .T.}   ,; // [07] B Code-block de validação do campo
       NIL     ,; // [08] B Code-block de validação When do campo
       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
       Nil , ; // [11] B Code-block de inicializacao do campo
       NIL     ,; // [12] L Indica se trata de um campo chave
       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
       .T. )        // [14] L Indica se o campo é virtual      
       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0006    ,; // [01] C Titulo do campo##"Nome Loj"
	       STR0006    ,; // [02] C ToolTip do campo
	       "GRD_NOMELOJ"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       40      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0007    ,; // [01] C Titulo do campo##"Agência"
	       STR0007    ,; // [02] C ToolTip do campo
	       "GRD_CODAG"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       6      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0008    ,; // [01] C Titulo do campo##"Des. Ag"
	       STR0008    ,; // [02] C ToolTip do campo
	       "GRD_DESAG"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       40      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0009    ,; // [01] C Titulo do campo##"VL. Com."
	       STR0009    ,; // [02] C ToolTip do campo
	       "GRD_VLCOM"   ,; // [03] C identificador (ID) do Field
	       "N"     ,; // [04] C Tipo do campo
	       9      ,; // [05] N Tamanho do campo
	       2      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0010    ,; // [01] C Titulo do campo##"Nt. Fis"
	       STR0010    ,; // [02] C ToolTip do campo
	       "GRD_NTFIS"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       9      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0011    ,; // [01] C Titulo do campo##"Serie"
	       STR0011    ,; // [02] C ToolTip do campo
	       "GRD_SERIE"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       3      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
	       
	oStruct:AddField( ;       // Ord. Tipo Desc.
	       STR0012    ,; // [01] C Titulo do campo##"Filial"
	       STR0012    ,; // [02] C ToolTip do campo
	       "GRD_FILIAL"   ,; // [03] C identificador (ID) do Field
	       "C"     ,; // [04] C Tipo do campo
	       2      ,; // [05] N Tamanho do campo
	       0      ,; // [06] N Decimal do campo
	       {|| .T.}   ,; // [07] B Code-block de validação do campo
	       NIL     ,; // [08] B Code-block de validação When do campo
	       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
	       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
	       Nil , ; // [11] B Code-block de inicializacao do campo
	       NIL     ,; // [12] L Indica se trata de um campo chave
	       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
	       .T. )        // [14] L Indica se o campo é virtual
Else
//------------------------------+
// lView = .F. - Estrutura View |
//------------------------------+	
	oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_CODPROC"   ,; // [01] C Nome do Campo
       "01"    ,; // [02] C Ordem
       STR0003    ,; // [03] C Titulo do campo -->"Cod. Proce"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve
       
	oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_FORNEC"   ,; // [01] C Nome do Campo
       "02"    ,; // [02] C Ordem
       STR0004    ,; // [03] C Titulo do campo -->"Fornec" 
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve

	oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_LOJA"   ,; // [01] C Nome do Campo
       "03"    ,; // [02] C Ordem
       STR0005   ,; // [03] C Titulo do campo -->"Loja"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve

oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_NOMELOJ"   ,; // [01] C Nome do Campo
       "04"    ,; // [02] C Ordem
       STR0006    ,; // [03] C Titulo do campo -->"Nome Loj"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve

oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_CODAG"   ,; // [01] C Nome do Campo
       "05"    ,; // [02] C Ordem
       STR0007    ,; // [03] C Titulo do campo -->"Agência"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve
       
oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_DESAG"   ,; // [01] C Nome do Campo
       "06"    ,; // [02] C Ordem
       STR0008    ,; // [03] C Titulo do campo -->"Des. Ag."
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve
       
oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_VLCOM"   ,; // [01] C Nome do Campo
       "07"    ,; // [02] C Ordem
       STR0009    ,; // [03] C Titulo do campo -->"VL. Com"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@E 9,999,999.99"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve

oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_NTFIS"   ,; // [01] C Nome do Campo
       "08"    ,; // [02] C Ordem
       STR0010    ,; // [03] C Titulo do campo -->"Nt. Fis"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       "SF1GTP"      ,; // [09] C Consulta F3
       .T.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve

oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_SERIE"   ,; // [01] C Nome do Campo
       "09"    ,; // [02] C Ordem
       STR0011    ,; // [03] C Titulo do campo -->"Série"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve
       
   oStruct:AddField( ; // Ord. Tipo Desc.
       "GRD_FILIAL"   ,; // [01] C Nome do Campo
       "10"    ,; // [02] C Ordem
       STR0012    ,; // [03] C Titulo do campo -->"Filial"
       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
       {}      ,; // [05] A Array com Help
       "GET"      ,; // [06] C Tipo do campo
       "@!"     ,; // [07] C Picture
       NIL     ,; // [08] B Bloco de Picture Var
       ""      ,; // [09] C Consulta F3
       .F.     ,; // [10] L Indica se o campo é editável
       NIL     ,; // [11] C Pasta do campo
       NIL     ,; // [12] C Agrupamento do campo
       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
       NIL     ,; // [15] C Inicializador de Browse
       .T.     ,; // [16] L Indica se o campo é virtual
       NIL )     // [17] C Picture Variáve
			 								
			 								
	
EndIf

RestArea(aArea)


Return

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB410CabStruct

Função responsável pela definição da estrutura utilizada no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do parâmetro lModel 	
	lModel:		Lógico. .t. - Será criado/atualizado a estrutura do Model; .f. - será criado/atualizado a
	estrutura da View
	
@sample: GCB300CabStruct(oStrCab, lModel)

@author Yuki Shiroma

@since 24/11/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GCB410CabStruct(oStrCab, lModel)

Default lModel := .t.

If ( lModel )

	oStrCab:AddField( ;       // Ord. Tipo Desc.
				       STR0013   ,; // [01] C Titulo do campo##"Codigo"
				       STR0013    ,; // [02] C ToolTip do campo
				       "CAB_CODIGO"   ,; // [03] C identificador (ID) do Field
				       "C"     ,; // [04] C Tipo do campo
				       6      ,; // [05] N Tamanho do campo
				       0      ,; // [06] N Decimal do campo
				       {|| .T.}   ,; // [07] B Code-block de validação do campo
				       NIL     ,; // [08] B Code-block de validação When do campo
				       Nil , ; // [09] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
				       .F.     ,; // [10] L Indica se o campo tem preenchimento obrigatório
				       Nil , ; // [11] B Code-block de inicializacao do campo
				       NIL     ,; // [12] L Indica se trata de um campo chave
				       NIL     ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
				       .T. )        // [14] L Indica se o campo é virtual
Else
	oStrCab:AddField( ; // Ord. Tipo Desc.
				       "CAB_CODIGO"   ,; // [01] C Nome do Campo
				       "01"    ,; // [02] C Ordem
				       STR0013    ,; // [03] C Titulo do campo -->"Venda/Reemb?"
				       ""    ,; // [04] C Descrição do campo -->"Venda/Reemb?"
				       {}      ,; // [05] A Array com Help
				       "GET"      ,; // [06] C Tipo do campo
				       "@!"     ,; // [07] C Picture
				       NIL     ,; // [08] B Bloco de Picture Var
				       ""      ,; // [09] C Consulta F3
				       .T.     ,; // [10] L Indica se o campo é editável
				       NIL     ,; // [11] C Pasta do campo
				       NIL     ,; // [12] C Agrupamento do campo
				       {} , ; // [13] A Lista de valores permitido do campo --> "1=Venda"##"2=Reembolso"##"3=Ambos"
				       Nil     ,; // [14] N Tamanho Máximo da maior opção do combo
				       NIL     ,; // [15] C Inicializador de Browse
				       .T.     ,; // [16] L Indica se o campo é virtual
				       NIL )     // [17] C Picture Variáve

EndIf

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC410Acti

Função responsável para realizar o load dos dados da nota fiscal 

@Params: 
	oModel:	Objeto do modelo
	aProcesso:		Array contendo valores para carga da nota fiscal 
	estrutura da View
	
@author Yuki Shiroma

@since 24/11/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GC410Acti(oModel, aProcesso)
Local lRet		:= .T.
Local nI		:= 1
Local oMdlGrd	:= oModel:GetModel("GRIDFAKE")
Local oMdlCab	:= oModel:GetModel("CABFAKE")

oMdlCab:SetValue("CAB_CODIGO", "1")
For nI	:= 1 to Len(aProcesso)
	
	If !nI == 1 
		oMdlGrd:AddLine()
	EndIf
	
	oMdlGrd:Setvalue("GRD_CODPROC", aProcesso[nI][1])
	oMdlGrd:Setvalue("GRD_FORNEC", aProcesso[nI][2])
	oMdlGrd:Setvalue("GRD_LOJA", aProcesso[nI][3])
	oMdlGrd:Setvalue("GRD_NOMELOJ", Posicione("SA2",1,xFilial("SA2")+aProcesso[nI][2]+aProcesso[nI][3],"A2_NREDUZ"))
	oMdlGrd:Setvalue("GRD_CODAG", aProcesso[nI][5])
	oMdlGrd:Setvalue("GRD_DESAG", POSICIONE("GI6",1,XFILIAL("GI6") + aProcesso[nI][5],"GI6_DESCRI"))
	oMdlGrd:Setvalue("GRD_VLCOM", aProcesso[nI][4])
	
Next

oMdlGrd:SetNoInsertLine(.T.)
oMdlGrd:SetNoDeleteLine(.T.)


Return lRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC410GRV

Função responsável para vincular Nota Fiscal X Processamento 

@Params: 
	oModel:	Objeto do modelo
	
@author Yuki Shiroma

@since 24/11/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GC410GRV(oModel)
Local lRet		:= .T.
Local nI		:= 1
Local oMdlGrid	:= oModel:GetModel("GRIDFAKE")
Local nId		:= 0 

//Realiza a carga do relacionamento processamento X Nota Fiscal X Titulo
For nI	:= 1 To  oMdlGrid:Length()
	oMdlGrid:GoLine(nI)
	nId	:= aScan(aProcesso, {|x,y| x[1] == oMdlGrid:GetValue("GRD_CODPROC") .And. x[2] == oMdlGrid:GetValue("GRD_FORNEC") .And. x[3] == oMdlGrid:GetValue("GRD_LOJA")}) 
	If 	nId > 0
		aProcesso[nId][6]	:= oMdlGrid:GetValue("GRD_NTFIS")
		aProcesso[nId][7]	:= oMdlGrid:GetValue("GRD_SERIE")
		aProcesso[nId][14]	:= oMdlGrid:GetValue("GRD_FILIAL")
	EndIf 
Next


Return lRet