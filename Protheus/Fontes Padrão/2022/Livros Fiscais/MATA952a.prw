#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#Include "ApWizard.ch"

#DEFINE _CRLF	Chr(13) + Chr(10)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} mata952a
Apuração de IPI – Conferência de valores processados na Apuração de IPI

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
@protected
*/
//------------------------------------------------------------------------------------------
Function mata952a()

	Private oBrowse

	If !ChkFile("SF3")
		Return .F.
	EndIf

//Iniciamos a construcao basica de um Browse.
	oBrowse := FWMBrowse():New()

//Definimos a tabela que ser exibida na Browse utilizando o metodo SetAlias
	oBrowse:SetAlias(SF3)

//Definimos o tiulo que ser?exibido como metodo SetDescription
	oBrowse:SetDescription("Apuração de IPI – Conferência de Valores") // "Apuração de IPI – Conferência de Valores"

//Ativamos a classe
	oBrowse:Activate()

Return


//------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
ModelDef da Apuração de IPI Próprio - Notas Fiscais de Entrada e Saída

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
@protected
*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel
	Local oStruSF3  := M952aSCab1()
	Local oStruTRB1 := M952aSCab2()
	Local oStruMas  := FWFormStruct( 1, 'SF3', /*bAvalCampo*/, /*lViewUsado*/ )
	Local aRelac	:= {}
	Local aRelac1	:= {}
	Local cAlsIPIs		:= "IPIDEB"
	Local cTempIPIs		:= "IPIDEBITO"+AllTrim(Str(ThreadID()))
	Local cAlsIPIe		:= "IPICRD"
	Local cTempIPIe		:= "IPICREDITO"+AllTrim(Str(ThreadID()))
	
// Posiciono o temporário no inicio do aquivo
	
	If IsInCallStack("ApurIPISai")
		If Select(cAlsIPIs) <= 0
			DbSelectArea(cAlsIPIs)
		EndIf

		( cAlsIPIs )->(dbGoTop())
	ElseIf IsInCallStack("ApurIPIEnt")
		If Select(cAlsIPIe) <= 0
			DbSelectArea(cAlsIPIe)
		EndIf

		( cAlsIPIe )->(dbGoTop())
	EndIf
	
// Carrega os blocos de codigo com os dados
	bLoad1    := {|| A952aLoad1(oModel)} // Notas Fiscais
	bLoad2    := {|| A952aLoad2(oModel)} // Itens das Notas Fiscais

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'mata952a', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo 
	oModel:AddFields( 'MASTER', /*cOwner*/, oStruMas )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'SF3MASTER', 'MASTER'   , oStruSF3 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoad1)
	oModel:AddGrid( 'SFTDETAIL', 'SF3MASTER', oStruTRB1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoad2)

//Relacionamento do pedido com os itens
	aAdd(aRelac,{ 'FILIAL'	, 'xFilial( "SF3" )' })
	aAdd(aRelac,{ 'DOC'		, 'F3_NFISCAL'	})
	aAdd(aRelac,{ 'SERIE'	, 'F3_SERIE' })
	aAdd(aRelac,{ 'FORNECE'	, 'F3_CLIEFOR' })
	aAdd(aRelac,{ 'LOJA'	, 'F3_LOJA' })
	aAdd(aRelac,{ 'CFOP'	, 'F3_ALIQICM' })

	aAdd(aRelac1,{ 'F3_FILIAL'	, 'xFilial( "SF3" )' })
	aAdd(aRelac1,{ 'F3_NFISCAL'	, 'DOC'	})
	aAdd(aRelac1,{ 'F3_SERIE'	, 'SERIE' })

// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'SF3MASTER', aRelac, SF3->(IndexKey(1) ) )
	oModel:SetRelation( 'SFTDETAIL', aRelac1 , SF3->( IndexKey( 1 ) ) )

//Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'MASTER' ):SetDescription( "Notas Fiscais" ) // "Notas Fiscais"
	oModel:GetModel( 'SF3MASTER' ):SetDescription( "Notas Fiscais" ) // "Notas Fiscais"
	oModel:GetModel( 'SFTDETAIL' ):SetDescription( "Itens das Notas Fiscais" ) // "Itens das Notas Fiscais"

// Define uma chave primaria (obrigatorio mesmo que vazia)	
	oModel:SetPrimaryKey( {} )

Return oModel


//------------------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
ViewDef dos pedidos bloqueados 

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
@protected
*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

// Cria a estrutura a ser usada na View
	Local oStruSF3  := M952aView1()
	Local oStruTRB1 := M952aView2()
	Local oView

// Cria o objeto de View
	oView := FWFormView():New()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	oModel := FWLoadModel( 'mata952a' )

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

// Adiciona botoes
	oView:AddUserButton( "Relatório", 'RELAT', {|oView| M952ARel() } ) // "Exportar"

//Adiciona no View um controle do tipo FormGrid(antiga newgetdados) 
	oView:AddGrid( 'VIEW_SF3' , oStruSF3 , 'SF3MASTER' )
	oView:AddGrid( 'VIEW_SFT' , oStruTRB1, 'SFTDETAIL' )

// Liga a identificação do componente 
	oView:EnableTitleView( 'VIEW_SF3' , "Relação de Notas Fiscais", 0 ) // "Notas Fiscais de Entrada"
	oView:EnableTitleView( 'VIEW_SFT' , "Itens das Notas Fiscais", 0 )  // "Itens das Notas Fiscais de Entrada"



// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'EMCIMA' , 60 )
	oView:CreateHorizontalBox( 'EMBAIXO', 40 )

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SF3' , 'EMCIMA' )
	oView:SetOwnerView( 'VIEW_SFT' , 'EMBAIXO' )
	
// Define Filtro para o Grid
	oView:SetViewProperty("VIEW_SF3", "GRIDFILTER"	, {.T.})
	oView:SetViewProperty("VIEW_SF3", "GRIDSEEK"	, {.T.})


Return oView


//-------------------------------------------------------------------
/*{Protheus.doc} M952aSCab1()
Retorna estrutura do tipo FWformModelStruct.

@author Ronaldo Tapia

@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M952aSCab1()

	Local aArea    := GetArea()
	Local oStruct := FWFormModelStruct():New()

// Tabela
	oStruct:AddTable('SF3',{'F3_FILIAL','F3_NFISCAL','F3_SERIE','F3_ENTRADA','F3_CLIEFOR','F3_LOJA','F3_CFO','VALOR'},"Grid de Notas Fiscais") // "Grid Notas Fiscais de Entrada"

// Campos
	oStruct:AddField(	"Filial"					,; 	// [01] C Titulo do campo
	"Filial"					,; 	// [02] C ToolTip do campo
	"FILIAL"	 				,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_FILIAL")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Doc"						,; 	// [01] C Titulo do campo
	"Doc"						,; 	// [02] C ToolTip do campo
	"DOC" 					,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_NFISCAL")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Serie"						,; 	// [01] C Titulo do campo
	"Serie"						,; 	// [02] C ToolTip do campo
	"SERIE" 					,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_SERIE")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Emissão"					,; 	// [01] C Titulo do campo
	"Emissão" 					,; 	// [02] C ToolTip do campo
	"EMISSAO" 					,; 	// [03] C identificador (ID) do Field
	"D" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_ENTRADA")[1] 	,; 	// [05] N Tamanho do campo
	0							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Fornecedor"				,; 	// [01] C Titulo do campo
	"Fornecedor"				,; 	// [02] C ToolTip do campo
	"FORNECE"					,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_CLIEFOR")[1] 	,; 	// [05] N Tamanho do campo
	0							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Loja"						,; 	// [01] C Titulo do campo
	"Loja"						,; 	// [02] C ToolTip do campo
	"LOJA"						,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_LOJA")[1]		,; 	// [05] N Tamanho do campo
	0							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual

	oStruct:AddField(	"CFOP"						,; 	// [01] C Titulo do campo
	"CFOP"						,; 	// [02] C ToolTip do campo
	"CFOP"		 				,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_CFO")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Base do Imposto"						,; 	// [01] C Titulo do campo
	"Base IPI"						,; 	// [02] C ToolTip do campo
	"BASE"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_BASEIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_BASEIPI")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Valor do Imposto"						,; 	// [01] C Titulo do campo
	"Valor"						,; 	// [02] C ToolTip do campo
	"VALOR"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_VALIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_VALIPI")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Outros do Imposto"						,; 	// [01] C Titulo do campo
	"Outr. IPI"						,; 	// [02] C ToolTip do campo
	"OUTROS"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_OUTRIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_OUTRIPI")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Isento do Imposto"						,; 	// [01] C Titulo do campo
	"Isen. IPI"						,; 	// [02] C ToolTip do campo
	"ISENTO"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_ISENIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_ISENIPI")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Valor Contabil"						,; 	// [01] C Titulo do campo
	"Val. Cont."						,; 	// [02] C ToolTip do campo
	"VALCONT"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_VALCONT")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_VALCONT")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"IDENTFT"						,; 	// [01] C Titulo do campo
	"IDENTFT"						,; 	// [02] C ToolTip do campo
	"IDENTFT"		 				,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_IDENTFT")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	RestArea( aArea )
	
	RestArea( aArea )

Return oStruct


//-------------------------------------------------------------------
/*{Protheus.doc} M952aView1()
Retorna estrutura do tipo FWFormViewStruct.

@author Ronaldo Tapia

@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M952aView1()
	Local oStruct   := FWFormViewStruct():New()

		/* Estutura para a criação de campos na view	
		
			[01] C Nome do Campo
			[02] C Ordem
			[03] C Titulo do campo  
			[04] C Descrição do campo  
			[05] A Array com Help
			[06] C Tipo do campo
			[07] C Picture
			[08] B Bloco de Picture Var
			[09] C Consulta F3
			[10] L Indica se o campo é editável
			[11] C Pasta do campo
			[12] C Agrupamento do campo
			[13] A Lista de valores permitido do campo (Combo)
			[14] N Tamanho Maximo da maior opção do combo
			[15] C Inicializador de Browse
			[16] L Indica se o campo é virtual
			[17] C Picture Variável
	
		*/

// Campos
	oStruct:AddField("FILIAL","01","Filial","Filial",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Filial"
	oStruct:AddField("DOC","02","Doc","Doc",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Doc"
	oStruct:AddField("SERIE","03","Serie","Serie",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Serie"
	oStruct:AddField("EMISSAO","04","Emissao","Emissao",{},"D","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Emissao"
	oStruct:AddField("FORNECE","05","Cliente/Fornecedor","Cliente/Fornecedor",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Cliente/Fornecedor"
	oStruct:AddField("LOJA","06","Loja","Loja",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Loja"
	oStruct:AddField("CFOP","07","CFOP","CFOP",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "CFOP"
	oStruct:AddField("BASE","08","Base do Imposto","Base do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("VALOR","09","Valor do Imposto","Valor do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("OUTROS","10","Outros IPI","Outros IPI",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("ISENTO","11","Isento IPI","Isento IPI",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("VALCONT","12","Valor Contabil","Valor Contabil",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("IDENTFT","13","Ident. SFT","Ident. SFT",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Identificador SFT"
	
Return oStruct


//------------------------------------------------------------------------------------------
/* {Protheus.doc} A952aLoad1
Carrega o bloco de carga dos dados do submodelo 1

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//------------------------------------------------------------------------------------------
Static Function A952aLoad1(oModel)

	Local aLoad1 		:= {}
	Local aSaveLines	:= FWSaveRows()
	
	Local cAlsIPIs		:= "IPIDEB"
	Local cAlsIPIe		:= "IPICRD"
	
// Percorro todo o temporario para adicionar os itens no codeblock aLoad1
	If IsInCallStack("ApurIPISai") // Debito - Apuração IPI
		If Select(cAlsIPIs) > 0
			While !((cAlsIPIs)->(eof()))
				aAdd(aLoad1,{0,{(cAlsIPIs)->FILIAL, (cAlsIPIs)->DOC, (cAlsIPIs)->SERIE, (cAlsIPIs)->EMISSAO, (cAlsIPIs)->FORNECE,;
					(cAlsIPIs)->LOJA,(cAlsIPIs)->CFOP,(cAlsIPIs)->BASEIPI,(cAlsIPIs)->VALOR,(cAlsIPIs)->OUTROS,(cAlsIPIs)->ISENTO,(cAlsIPIs)->VALCONT,(cAlsIPIs)->IDENTFT}})
				(cAlsIPIs)->(dbSkip())
			Enddo
		EndIf
	ElseIf IsInCallStack("ApurIPIEnt") // Credito - Apuração IPI
		If Select(cAlsIPIe) > 0
			While !((cAlsIPIe)->(eof()))
				aAdd(aLoad1,{0,{(cAlsIPIe)->FILIAL, (cAlsIPIe)->DOC, (cAlsIPIe)->SERIE, (cAlsIPIe)->EMISSAO, (cAlsIPIe)->FORNECE,;
					(cAlsIPIe)->LOJA,(cAlsIPIe)->CFOP,(cAlsIPIe)->BASEIPI,(cAlsIPIe)->VALOR,(cAlsIPIe)->OUTROS,(cAlsIPIe)->ISENTO,(cAlsIPIe)->VALCONT,(cAlsIPIe)->IDENTFT}})
				(cAlsIPIe)->(dbSkip())
			Enddo
		EndIf
	EndIf

	FWRestRows( aSaveLines )

Return aLoad1

//-------------------------------------------------------------------
/*{Protheus.doc} M952aSCab2()
Retorna estrutura do tipo FWformModelStruct.

@author Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M952aSCab2()

	Local aArea    := GetArea()
	Local oStruct := FWFormModelStruct():New()

// Tabela
	oStruct:AddTable('SFT',{'FT_FILIAL','FT_NFISCAL','FT_SERIE','FT_ITEM','FT_PRODUTO','FT_CFOP','FT_QUANT','FT_PRCUNIT','FT_TOTAL','FT_BASEIPI','FT_VALIPI','FT_ALIQIPI','FT_POSIPI'},"Itens das Notas Fiscais") // "Itens das Notas Fiscais"

// Campos
	oStruct:AddField(	"Filial"					,; 	// [01] C Titulo do campo // "Filial"
	"Filial"					,; 	// [02] C ToolTip do campo // "Filial"
	"FT_FILIAL"		 			,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_FILIAL")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validcao do campo
	Nil							,; 	// [08] B Code-block de validcao When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatorio
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opercao de update.
	.F. )  	            		// [14] L Indica se o campo ?virtual
					
	oStruct:AddField(	"Doc"						,; 	// [01] C Titulo do campo // "Doc"
	"Doc"						,; 	// [02] C ToolTip do campo // "Doc"
	"FT_NFISCAL"		 		,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_NFISCAL")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validcao do campo
	Nil							,; 	// [08] B Code-block de validcao When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatorio
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opercao de update.
	.F. )  	            		// [14] L Indica se o campo ?virtual
					
	oStruct:AddField(	"Serie"						,; 	// [01] C Titulo do campo // "Serie"
	"Serie"						,; 	// [02] C ToolTip do campo // "Serie"
	"FT_SERIE"		 			,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_SERIE")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validcao do campo
	Nil							,; 	// [08] B Code-block de validcao When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatorio
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opercao de update.
	.F. )  	            		// [14] L Indica se o campo ?virtual

	oStruct:AddField(	"Item"						,; 	// [01] C Titulo do campo // "Item"
	"Item"						,; 	// [02] C ToolTip do campo // "Item"
	"FT_ITEM"		 			,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("D1_ITEM")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validcao do campo
	Nil							,; 	// [08] B Code-block de validcao When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatorio
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opercao de update.
	.F. )  	            		// [14] L Indica se o campo ?virtual

	oStruct:AddField(	"Produto"					,; 	// [01] C Titulo do campo // "Produto"
	"Produto"					,; 	// [02] C ToolTip do campo // "Produto"
	"FT_PRODUTO"	 			,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_PRODUTO")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"CFOP"						,; 	// [01] C Titulo do campo // "CFOP"
	"CFOP" 						,; 	// [02] C ToolTip do campo // "CFOP"
	"FT_CFOP" 					,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_CFOP")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Quantidade"				,; 	// [01] C Titulo do campo // "Quantidade"
	"Quantidade" 				,; 	// [02] C ToolTip do campo // "Quantidade"
	"FT_QUANT" 					,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_QUANT")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_QUANT")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual

	oStruct:AddField(	"Valor Unitário"			,; 	// [01] C Titulo do campo // "Valor Unitário"
	"Valor Unitário" 			,; 	// [02] C ToolTip do campo // "Valor Unitário"
	"FT_PRCUNIT" 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_PRCUNIT")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_PRCUNIT")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Valor Total"				,; 	// [01] C Titulo do campo // "Valor Total"
	"Valor Total" 				,; 	// [02] C ToolTip do campo // "Valor Total"
	"FT_TOTAL" 					,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_TOTAL")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_TOTAL")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual

	oStruct:AddField(	"Base de Cálculo"					,; 	// [01] C Titulo do campo // "Base ICM"
	"Base IPI"	   				,; 	// [02] C ToolTip do campo // "Base ICM"
	"FT_BASEIPI"				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_BASEIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_BASEIPI")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Valor do Imposto"					,; 	// [01] C Titulo do campo // "Valor ICM"
	"Valor IPI" 				,; 	// [02] C ToolTip do campo // "Valor ICM"
	"FT_VALIPI" 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_VALIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_VALIPI")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Aliquota do Imposto"					,; 	// [01] C Titulo do campo // "Aliquota do Imposto"
	"Valor IPI" 				,; 	// [02] C ToolTip do campo // "Valor ICM"
	"FT_ALIQIPI" 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_ALIQIPI")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_ALIQIPI")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"N.C.M"					,; 	// [01] C Titulo do campo // "Produto"
	"N.C.M"					,; 	// [02] C ToolTip do campo // "Produto"
	"FT_POSIPI"	 			,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_POSIPI")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	RestArea( aArea )

Return oStruct


//-------------------------------------------------------------------
/*{Protheus.doc} M952aView2()
Retorna estrutura do tipo FWFormViewStruct.

@author Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M952aView2()

	Local oStruct   := FWFormViewStruct():New()

		/* Estutura para a criação de campos na view	
		
			[01] C Nome do Campo
			[02] C Ordem
			[03] C Titulo do campo  
			[04] C Descrição do campo  
			[05] A Array com Help
			[06] C Tipo do campo
			[07] C Picture
			[08] B Bloco de Picture Var
			[09] C Consulta F3
			[10] L Indica se o campo é editável
			[11] C Pasta do campo
			[12] C Agrupamento do campo
			[13] A Lista de valores permitido do campo (Combo)
			[14] N Tamanho Maximo da maior opção do combo
			[15] C Inicializador de Browse
			[16] L Indica se o campo é virtual
			[17] C Picture Variável
	
		*/

// Campos
	oStruct:AddField("FT_FILIAL","01","Filial","Filial",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Filial"
	oStruct:AddField("FT_NFISCAL","02","Doc","Doc",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Doc"
	oStruct:AddField("FT_SERIE","03","Serie","Serie",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Serie"
	oStruct:AddField("FT_ITEM","04","Item","Item",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Item"
	oStruct:AddField("FT_PRODUTO","05","Produto","Produto",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Código"
	oStruct:AddField("FT_CFOP","06","CFOP","CFOP",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "CFOP"
	oStruct:AddField("FT_QUANT","07","Quantidade","Quantidade",{},"N","'@E 9999",/*bPictVar*/,/*cLookUp*/,.T.) // "Quantidade"
	oStruct:AddField("FT_PRCUNIT","08","Valor Unitário","Valor Unitário",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor Unitário"
	oStruct:AddField("FT_TOTAL","09","Valor Total","Valor Total",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor Total"
	oStruct:AddField("FT_BASEIPI","10","Base de Cálculo","Base de Cálculo",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Base de Cálculo"
	oStruct:AddField("FT_VALIPI","11","Valor do Imposto","Valor do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("FT_ALIQIPI","12","Aliquota do Imposto","Aliquota do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Aliquota do Imposto"
	oStruct:AddField("FT_POSIPI","13","N.C.M","N.C.M",{},"N","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "NCM"
Return oStruct

//------------------------------------------------------------------------------------------
/* {Protheus.doc} A952aLoad2
Carrega o bloco de carga dos dados do submodelo 2

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//------------------------------------------------------------------------------------------
Static Function A952aLoad2(oModel)

	Local aLoad2 		:= {}
	local cQry1  		:= ""
	Local aSaveLines	:= FWSaveRows()
	Local oModelApur	:= oModel:GetModel("SF3MASTER")
	Local cFilApur 		:= oModelApur:GetValue("FILIAL")
	Local cDoc	 		:= oModelApur:GetValue("DOC")
	Local cSerie 		:= oModelApur:GetValue("SERIE")
	Local cCFOP 		:= oModelApur:GetValue("CFOP")
	Local cIdent		:= oModelApur:GetValue("IDENTFT")
	
	// Adiciono os itens no codeblock aLoad2

	
	If (Select("TRB1") <> 0)
		dbSelectArea("TRB1")
		dbCloseArea()
	Endif

	aQry:= QrySFTIPI(cFilApur,cDoc,cSerie,cCFOP,cIdent)
	cSlct:= "%" + aQry[1] + "%"
	cWhere:= "%" + aQry[3] + "%"
	cOrder:= "%" + aQry[4] + "%"

	BeginSQL Alias "TRB1"
		SELECT 
		%Exp:cSlct%
		
		FROM 
		%table:SFT% SFT
		
		WHERE
		%Exp:cWhere%
		
		ORDER BY SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE	
		
		
	EndSQL
	
	Dbselectarea("TRB1")
	
	While TRB1->(!Eof())
		If IsInCallStack("ApurIPISai") .Or. IsInCallStack("ApurIPIEnt")
			aAdd(aLoad2,{0,{TRB1->FT_FILIAL,TRB1->FT_NFISCAL,TRB1->FT_SERIE,TRB1->FT_ITEM,TRB1->FT_PRODUTO,TRB1->FT_CFOP,;
				TRB1->FT_QUANT,TRB1->FT_PRCUNIT,TRB1->FT_TOTAL,TRB1->FT_BASEIPI,TRB1->FT_VALIPI,TRB1->FT_ALIQIPI,TRB1->FT_POSIPI}})
		EndIf
		TRB1->(dbSkip())
	Enddo
	
	FWRestRows( aSaveLines )

Return aLoad2


//----------------------------------------------------------------------------

/*M953ARel - Função que irá imprimir o relatório das notas fiscais*/

//----------------------------------------------------------------------------

Function M952ARel()

If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
EndIf	

Return
//------------------------------------------------------------


Static Function ReportDef()

	Local oReport     	:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Private oBreak		:= Nil
	Private oBreak2		:= Nil

	oReport             := Nil
	oReport	:= TReport():New('MATA952A',"Listagem de NFs",'',{|oReport| ListIPI()},"STR0001",,,,,.F.) //'Relatório de previsão da apuração dos eventos.'
	//Resumo dos registros do relatório
	oSection1 	:= TRSection():New(oReport,"Valores do Cabeçalho - SF3")//
	oSection1:SetHeaderSection(.T.)
	oSection1:SetTitle("Listagem de Notas Fiscais - SF3")

	
	TRCell():New(oSection1,'FILIAL'		, '', "FILIAL"	, /*Picture*/,  6,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'DOC'		, '', "DOC"	, /*Picture*/, 12,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'SERIE'		, '', "SERIE"	, /*Picture*/,  5,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'EMISSAO'	, '', "EMISSAO", /*Picture*/ 	 , 10, /*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'FORNECE'	, '', "PARTICIPANTE"	, /*Picture*/, 20,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'LOJA'		, '', "LOJA"	, /*Picture*/,  6,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'CFOP'		, '', "CFOP", /*Picture*/	 , 10,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'BASE'		, '', "BASE", /*Picture*/	 , 10,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'VALOR'		, '', "VALOR"	, "@E 999999999999999.99", TAMSX3("F3_VALIPI")[1] ,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'OUTROS'		, '', "OUTROS"	, "@E 999999999999999.99",  TAMSX3("F3_OUTRIPI")[1],	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'ISENTO'		, '', "ISENTO", "@E 999999999999999.99"		 , TAMSX3("F3_ISENIPI")[1],	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'VALCONT'	, '', "VALCONT", "@E 999999999999999.99"	 	 ,  TAMSX3("F3_VALCONT")[1], /*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'IDENTFT'	, '', "IDENTFT", /*Picture*/	, TAMSX3("F3_IDENTFT")[1], /*lPixel*/,,"LEFT",,"LEFT") 
	
	oBreak := TRBreak():New(oSection1,oSection1:Cell("FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
	TRFunction():New(oSection1:Cell("VALOR"),"Valor tributado","SUM",oBreak,'Valor Tributado',,,.F.,.F.) 
	oSection1:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra

	
	
	oSection2 := TRSection():New(oReport,"Valores por item - SFT")
	oSection2:SetHeaderSection(.T.)
	oSection2:SetTitle("listagem dos Itens - SFT")

	TRCell():New(oSection2,"FT_FILIAL"	,  "","FILIAL")
	TRCell():New(oSection2,"FT_NFISCAL"	,  "","DOC")
	TRCell():New(oSection2,"FT_SERIE"	,  "","SERIE")
	TRCell():New(oSection2,"FT_ITEM"	,  "","ITEM NF")
	TRCell():New(oSection2,"FT_PRODUTO"	,  "","PRODUTO")
	TRCell():New(oSection2,"FT_CFOP"	,  "","CFOP")
	TRCell():New(oSection2,"FT_CLASFIS"	,  "","SIT. TRIB")
	TRCell():New(oSection2,"FT_QUANT"	,  "","QUANT")
	TRCell():New(oSection2,"FT_PRCUNIT"	,  "", "VAL. UNIT")
	TRCell():New(oSection2,"FT_TOTAL"	,  "", "TOTAL")
	TRCell():New(oSection2,"FT_BASEIPI"	,  "", "BASE IPI")
	TRCell():New(oSection2,"FT_VALIPI"	,  "", "VAL. IPI")
	TRCell():New(oSection2,"FT_ALIQIPI"	,  "", "ALIQ. IPI")
	TRCell():New(oSection2,"FT_OUTRIPI"	,  "", "OUTROS IPI")
	TRCell():New(oSection2,"FT_ISENIPI"	,  "", "ISENTO IPI")
	TRCell():New(oSection2,"FT_POSIPI"	,  "", "N.C.M")
	
	
	
	oBreak := TRBreak():New(oSection2,oSection2:Cell("FT_FILIAL"),"Totalizadores ",.T.,'Totalizadores',.T.)
	TRFunction():New(oSection2:Cell("FT_TOTAL"),NIL,"SUM",oBreak,'Valor das Operações',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_TOTAL"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_BASEIPI"),NIL,"SUM",oBreak,'Base de IPI',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_BASEICM"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_VALIPI"),NIL,"SUM",oBreak,'Valor IPI',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_VALICM"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_OUTRIPI"),NIL,"SUM",oBreak,'Outros IPI',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_OUTRICM"):getvalue()) }*/) 
	TRFunction():New(oSection2:Cell("FT_ISENIPI"),NIL,"SUM",oBreak,'Isento IPI',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_ISENICM"):getvalue()) }*/)
	//TRFunction():New(oSection2:Cell("FT_ICMSRET"),NIL,"SUM",oBreak,'ICMS Retido',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_ISENICM"):getvalue()) }*/)
	
	
Return(oReport)

//--------------------------------------------------

//--------------------------------------------------

Function ListIPI()	
	
	Local cAlsIPIe		:= "IPICRD"
	Local cTempIPIe		:= "IPICREDITO"+AllTrim(Str(ThreadID()))
	Local cAlsIPIs		:= "IPIDEB"
	Local cTempIPIs		:= "IPIDEBITO"+AllTrim(Str(ThreadID()))
	Local oCab 			:= oReport:Section(1)
	Local oItem 		:= oReport:Section(2)
	Local aQry			:= {}
	Local cSlct			:= ""
	Local cWhere		:= ""
	Local cOrder		:= ""
	Local cAliIt		:= ""
	private oBreak := Nil
	private oBreak2 := Nil
	
	If IsInCallStack("ApurIPISai")
		If Select(cAlsIPIs) <= 0
			DbSelectArea(cAlsIPIs)
		EndIf

		( cAlsIPIs )->(dbGoTop())
		oCab:init()

		While !(cAlsIPIs)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsIPIs)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsIPIs)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsIPIs)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsIPIs)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsIPIs)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsIPIs)->LOJA)
			oCab:Cell("CFOP"):SetValue((cAlsIPIs)->CFOP)
			oCab:Cell("BASE"):SetValue((cAlsIPIs)->BASEIPI)
			oCab:Cell("VALOR"):SetValue((cAlsIPIs)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsIPIs)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsIPIs)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsIPIs)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsIPIs)->IDENTFT)
			oCab:Printline()
			( cAlsIPIs )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsIPIs )->(dbGoTop())
		While !(cAlsIPIs)->(Eof())	
			
			aQry:= QrySFTIPI((cAlsIPIs)->FILIAL,(cAlsIPIs)->DOC,(cAlsIPIs)->SERIE,(cAlsIPIs)->CFOP,(cAlsIPIs)->IDENTFT)
			
			cSlct:= "%" + aQry[1] + "%"
			cWhere:= "%" + aQry[3] + "%"
			cOrder:= "%" + aQry[4] + "%"
		
			oItem:BeginQuery()
			cAliIT:=GetNextAlias()
			BeginSQL Alias cAliIT
				SELECT 
					%Exp:cSlct%
		
				FROM 
					%table:SFT% SFT
		
				WHERE
					%Exp:cWhere%
		
					ORDER BY SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE	
		
		
			EndSQL
			oItem:EndQuery()
			
			
			oItem:init()
			DbSelectArea(cAliIT)
			While !(cAliIT)->(Eof())
				oItem:Cell("FT_FILIAL"):SetValue((cAliIT)->FT_FILIAL)
				oItem:Cell("FT_NFISCAL"):SetValue((cAliIT)->FT_NFISCAL)
				oItem:Cell("FT_SERIE"):SetValue((cAliIT)->FT_SERIE)
				oItem:Cell("FT_ITEM"):SetValue((cAliIT)->FT_ITEM)
				oItem:Cell("FT_PRODUTO"):SetValue((cAliIT)->FT_PRODUTO)
				oItem:Cell("FT_CFOP"):SetValue((cAliIT)->FT_CFOP)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEIPI"):SetValue((cAliIT)->FT_BASEIPI)
				oItem:Cell("FT_VALIPI"):SetValue((cAliIT)->FT_VALIPI)
				oItem:Cell("FT_ALIQIPI"):SetValue((cAliIT)->FT_ALIQIPI)
				oItem:Cell("FT_POSIPI"):SetValue((cAliIT)->FT_POSIPI)

				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsIPIs )->(dbSkip())
			
		EndDo
		oItem:Finish()
		
		
	ElseIf IsInCallStack("ApurIPIEnt")
		If Select(cAlsIPIe) <= 0
			DbSelectArea(cAlsIPIe)
		EndIf

		( cAlsIPIe )->(dbGoTop())
		oCab:init()

		While !(cAlsIPIe)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsIPIe)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsIPIe)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsIPIe)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsIPIe)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsIPIe)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsIPIe)->LOJA)
			oCab:Cell("CFOP"):SetValue((cAlsIPIe)->CFOP)
			oCab:Cell("BASE"):SetValue((cAlsIPIe)->BASEIPI)
			oCab:Cell("VALOR"):SetValue((cAlsIPIe)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsIPIe)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsIPIe)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsIPIe)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsIPIe)->IDENTFT)
			oCab:Printline()
			( cAlsIPIe )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsIPIe )->(dbGoTop())
		While !(cAlsIPIe)->(Eof())	
			
			aQry:= QrySFTIPI((cAlsIPIe)->FILIAL,(cAlsIPIe)->DOC,(cAlsIPIe)->SERIE,(cAlsIPIe)->CFOP,(cAlsIPIe)->IDENTFT)
			
			cSlct:= "%" + aQry[1] + "%"
			cWhere:= "%" + aQry[3] + "%"
			cOrder:= "%" + aQry[4] + "%"
		
			oItem:BeginQuery()
			cAliIT:=GetNextAlias()
			BeginSQL Alias cAliIT
				SELECT 
					%Exp:cSlct%
		
				FROM 
					%table:SFT% SFT
		
				WHERE
					%Exp:cWhere%
		
					ORDER BY SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE	
		
		
			EndSQL
			oItem:EndQuery()
	
			oItem:init()
			DbSelectArea(cAliIT)
			While !(cAliIT)->(Eof())
				oItem:Cell("FT_FILIAL"):SetValue((cAliIT)->FT_FILIAL)
				oItem:Cell("FT_NFISCAL"):SetValue((cAliIT)->FT_NFISCAL)
				oItem:Cell("FT_SERIE"):SetValue((cAliIT)->FT_SERIE)
				oItem:Cell("FT_ITEM"):SetValue((cAliIT)->FT_ITEM)
				oItem:Cell("FT_PRODUTO"):SetValue((cAliIT)->FT_PRODUTO)
				oItem:Cell("FT_CFOP"):SetValue((cAliIT)->FT_CFOP)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEIPI"):SetValue((cAliIT)->FT_BASEIPI)
				oItem:Cell("FT_VALIPI"):SetValue((cAliIT)->FT_VALIPI)
				oItem:Cell("FT_ALIQIPI"):SetValue((cAliIT)->FT_ALIQIPI)
				oItem:Cell("FT_POSIPI"):SetValue((cAliIT)->FT_POSIPI)
				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsIPIe )->(dbSkip())
			
		EndDo
		oItem:Finish()
	EndIf
return 
//---------------------------------------------------------------------------------------------------------

/* Função que irá executar a query da SFT para carregar na tela da rotina e nos relatórios

*/
//---------------------------------------------------------------------------------------------------------- 

Function QrySFTIPI(cFilApur,cDoc,cSerie,cCFOP,cIdent)

	Local cSlct := ""
	Local cFrom := ""
	Local cWhere:= ""
	Local cOrder:= ""

	default cFilApur 	:= ""
	Default cDoc 		:= ""
	Default cSerie		:= ""
	Default cCFOP 		:= ""
	Default cIdent		:= ""

	cSlct += " SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_CFOP,"
	cSlct += " SFT.FT_QUANT,SFT.FT_PRCUNIT,SFT.FT_TOTAL,SFT.FT_BASEIPI,SFT.FT_VALIPI,SFT.FT_ALIQIPI, SFT.FT_POSIPI "
	
	cFrom := " "+RetSQLName("SFT") + " SFT "
	
	cWhere := " SFT.D_E_L_E_T_ = ' ' "
	cWhere += " AND SFT.FT_FILIAL = '"+cFilApur+"' "
	cWhere += " AND SFT.FT_NFISCAL = '"+cDoc+"' "
	cWhere += " AND SFT.FT_SERIE = '"+cSerie+"' "
	cWhere += " AND SFT.FT_IDENTF3 = '"+cIdent+"'
	If IsInCallStack("ApurIPISai") 
		cWhere += " AND SFT.FT_TIPOMOV = 'S'"
	ElseIf IsInCallStack("ApurIPIEnt")
		cWhere += " AND SFT.FT_TIPOMOV = 'E'"
	Endif
	cOrder += " SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE"
	
	
	

Return {cSlct,cFrom,cWhere,cOrder}	
