#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#Include "ApWizard.ch"

#DEFINE _CRLF	Chr(13) + Chr(10)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} mata953a
Apuração de ICMS Próprio – Conferência de valores processados nas abas “ICMS-ENTRADA” e “ICMS-SAIDA”

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
@protected
*/
//------------------------------------------------------------------------------------------
Function mata953a()

	Private oBrowse

	If !ChkFile("SF3")
		Return .F.
	EndIf

//Iniciamos a construcao basica de um Browse.
	oBrowse := FWMBrowse():New()

//Definimos a tabela que ser exibida na Browse utilizando o metodo SetAlias
	oBrowse:SetAlias(SF3)

//Definimos o tiulo que ser?exibido como metodo SetDescription
	oBrowse:SetDescription("Apuração de ICMS Próprio – Conferência de Valores") // "Apuração de ICMS Próprio – Conferência de Valores"

//Ativamos a classe
	oBrowse:Activate()

Return


//------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
ModelDef da Apuração de ICMS Próprio - Notas Fiscais de Entrada e Saída

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
@protected
*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel
	Local oStruSF3  := M953aSCab1()
	Local oStruTRB1 := M953aSCab2()
	Local oStruMas  := FWFormStruct( 1, 'SF3', /*bAvalCampo*/, /*lViewUsado*/ )
	Local aRelac	:= {}
	Local aRelac1	:= {}
	Local cAliasS   := "" 
	Local cIndTmp1 := ""
	Local cAlsDeb		:= "ICMSDEB"
	Local cTempDeb		:= "ICMSDEBITO"+AllTrim(Str(ThreadID()))
	Local cAlsCrd		:= "ICMSCRD"
	Local cTempCrd		:= "ICMSCREDITO"+AllTrim(Str(ThreadID()))
	Local cAlsSTd		:= "STDEB"
	Local cTempSTd		:= "STDEBITO"+AllTrim(Str(ThreadID()))
	Local cAlsSTe		:= "STCRD"
	Local cTempSTe		:= "STCREDITO"+AllTrim(Str(ThreadID()))
	
// Posiciono o temporário no inicio do aquivo
	
	If IsInCallStack("ApurICMSSai")
		If Select( cAlsDeb ) <= 0
			DbSelectArea(cAlsDeb)
		EndIf

		( cAlsDeb )->(dbGoTop())
	ElseIf IsInCallStack("ApurICMSEnt")
		If Select( cAlsCrd ) <= 0
			DbSelectArea(cAlsCrd)
		EndIf

		( cAlsCrd )->(dbGoTop())
	ElseIf IsInCallStack("ApurSTSai")
		If Select( cAlsSTd ) <= 0
			DbSelectArea(cAlsSTd)
		EndIf

		( cAlsSTd )->(dbGoTop())
	ElseIf IsInCallStack("ApurSTEnt")
		If Select( cAlsSTe ) <= 0
			DbSelectArea(cAlsSTe)
		EndIf

		( cAlsSTe )->(dbGoTop())
	EndIf

// Carrega os blocos de codigo com os dados
	bLoad1    := {|| A953aLoad1(oModel)} // Notas Fiscais
	bLoad2    := {|| A953aLoad2(oModel)} // Itens das Notas Fiscais

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'mata953a', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

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
	oModel:SetRelation( 'SF3MASTER', aRelac , SF3->( IndexKey( 1 ) ) )
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
	Local oStruSF3  := M953aView1()
	Local oStruTRB1 := M953aView2()
	Local oView

// Cria o objeto de View
	oView := FWFormView():New()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	oModel := FWLoadModel( 'mata953a' )

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

// Adiciona botoes
	oView:AddUserButton( "Relatório", 'RELAT', {|oView| M953ARel() } ) // "Exportar"

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
/*{Protheus.doc} M953aSCab1()
Retorna estrutura do tipo FWformModelStruct.

@author Ronaldo Tapia

@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M953aSCab1()

	Local aArea    := GetArea()
	Local oStruct := FWFormModelStruct():New()

// Tabela
	oStruct:AddTable('SF3',{'F3_FILIAL','F3_NFISCAL','F3_SERIE','F3_ENTRADA','F3_CLIEFOR','F3_LOJA','F3_ESTADO','F3_CFO','F3_ALIQICM','VALOR'},"Grid de Notas Fiscais") // "Grid Notas Fiscais de Entrada"

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
	
	oStruct:AddField(	"UF"						,; 	// [01] C Titulo do campo
	"UF"						,; 	// [02] C ToolTip do campo
	"UF"						,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_ESTADO")[1]		,; 	// [05] N Tamanho do campo
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
	
	oStruct:AddField(	"FORMULA"						,; 	// [01] C Titulo do campo
	"FORMULA"						,; 	// [02] C ToolTip do campo
	"FORMULA"		 				,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_FORMULA")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"CODRSEF"						,; 	// [01] C Titulo do campo
	"CODRSEF"						,; 	// [02] C ToolTip do campo
	"CODRSEF"		 				,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_CODRSEF")[1]		,; 	// [05] N Tamanho do campo
	0 							,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Aliquota"					,; 	// [01] C Titulo do campo
	"Aliquota"					,; 	// [02] C ToolTip do campo
	"ALIQUOTA"		 			,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_ALIQICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_ALIQICM")[2]		,; 	// [06] N Decimal do campo
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
	TamSX3("F3_VALICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_VALICM")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"ICMS Outros"						,; 	// [01] C Titulo do campo
	"Outros"						,; 	// [02] C ToolTip do campo
	"OUTROS"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_OUTRICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_OUTRICM")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"ICMS Isento"						,; 	// [01] C Titulo do campo
	"Isento"						,; 	// [02] C ToolTip do campo
	"ISENTO"		 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("F3_ISENICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("F3_ISENICM")[2] 		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Val. Cont."						,; 	// [01] C Titulo do campo
	"ValCont"						,; 	// [02] C ToolTip do campo
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

Return oStruct


//-------------------------------------------------------------------
/*{Protheus.doc} M953aView1()
Retorna estrutura do tipo FWFormViewStruct.

@author Ronaldo Tapia

@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M953aView1()
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
	oStruct:AddField("UF","07","UF","UF",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "UF"
	oStruct:AddField("CFOP","08","CFOP","CFOP",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "CFOP"
	oStruct:AddField("FORMULA","09","Formula","Formula",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "FORMULA"
	oStruct:AddField("CODRSEF","10","Cod. Ret. SEFAZ","Cod Ret. SEFAZ",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "CODRSEF"
	oStruct:AddField("ALIQUOTA","11","Aliquota","Aliquota",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Aliquota"
	oStruct:AddField("VALOR","12","Valor do Imposto","Valor do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("OUTROS","13","ICMS Outros","ICMS Outros",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("ISENTO","14","ICMS Isen.","ICMS Isen.",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("VALCONT","15","Val. Cont.","Val. Cont.",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("IDENTFT","16","Ident. SFT","Ident. SFT",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "Identificador SFT"
Return oStruct


//------------------------------------------------------------------------------------------
/* {Protheus.doc} A953aLoad1
Carrega o bloco de carga dos dados do submodelo 1

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//------------------------------------------------------------------------------------------
Static Function A953aLoad1(oModel)

	Local aLoad1 		:= {}
	Local aSaveLines	:= FWSaveRows()

	Local cAlsDeb := "ICMSDEB"
	Local cAlsCrd := "ICMSCRD"
	Local cAlsSTd := "STDEB"
	Local cAlsSTe := "STCRD"
	
// Percorro todo o temporario para adicionar os itens no codeblock aLoad1
	If IsInCallStack("ApurICMSSai") // Debito - Apuração ICMS
		If Select(cAlsDeb) > 0
			While !((cAlsDeb)->(eof()))
				aAdd(aLoad1,{0,{(cAlsDeb)->FILIAL, (cAlsDeb)->DOC, (cAlsDeb)->SERIE, (cAlsDeb)->EMISSAO, (cAlsDeb)->FORNECE,;
					(cAlsDeb)->LOJA,(cAlsDeb)->ESTADO,(cAlsDeb)->CFOP,(cAlsDeb)->FORMULA,(cAlsDeb)->CODRSEF,(cAlsDeb)->ALIQUOTA,(cAlsDeb)->VALOR,(cAlsDeb)->OUTROS,;
					(cAlsDeb)->ISENTO,(cAlsDeb)->VALCONT, (cAlsDeb)->IDENTFT}})
				(cAlsDeb)->(dbSkip())
			Enddo
		EndIf
	ElseIf IsInCallStack("ApurICMSEnt") // Credito - Apuração ICMS
		If Select(cAlsCrd) > 0
			While !((cAlsCrd)->(eof()))
				aAdd(aLoad1,{0,{(cAlsCrd)->FILIAL, (cAlsCrd)->DOC, (cAlsCrd)->SERIE, (cAlsCrd)->EMISSAO, (cAlsCrd)->FORNECE,;
					(cAlsCrd)->LOJA,(cAlsCrd)->ESTADO,(cAlsCrd)->CFOP,(cAlsCrd)->FORMULA,(cAlsCrd)->CODRSEF,(cAlsCrd)->ALIQUOTA,(cAlsCrd)->VALOR,(cAlsCrd)->OUTROS,;
					(cAlsCrd)->ISENTO,(cAlsCrd)->VALCONT, (cAlsCrd)->IDENTFT}})
				(cAlsCrd)->(dbSkip())
			Enddo
		EndIf
	ElseIf IsInCallStack("ApurSTSai") // Debito - Apuração ICMS-ST
		If Select(cAlsSTd) > 0
			While !((cAlsSTd)->(eof()))
				aAdd(aLoad1,{0,{(cAlsSTd)->FILIAL, (cAlsSTd)->DOC, (cAlsSTd)->SERIE, (cAlsSTd)->EMISSAO, (cAlsSTd)->FORNECE,;
					(cAlsSTd)->LOJA,(cAlsSTd)->ESTADO,(cAlsSTd)->CFOP,(cAlsSTd)->FORMULA,(cAlsSTd)->CODRSEF,(cAlsSTd)->ALIQUOTA,(cAlsSTd)->VALOR,(cAlsSTd)->OUTROS,;
					(cAlsSTd)->ISENTO,(cAlsSTd)->VALCONT, (cAlsSTd)->IDENTFT}})
				(cAlsSTd)->(dbSkip())
			Enddo
		EndIf
	ElseIf IsInCallStack("ApurSTEnt") // Credito - Apuração ICMS-ST
		If Select(cAlsSTe) > 0
			While !((cAlsSTe)->(eof()))
				aAdd(aLoad1,{0,{(cAlsSTe)->FILIAL, (cAlsSTe)->DOC, (cAlsSTe)->SERIE, (cAlsSTe)->EMISSAO, (cAlsSTe)->FORNECE,;
					(cAlsSTe)->LOJA,(cAlsSTe)->ESTADO,(cAlsSTe)->CFOP,(cAlsSTe)->FORMULA,(cAlsSTe)->CODRSEF,(cAlsSTe)->ALIQUOTA,(cAlsSTe)->VALOR,(cAlsSTe)->OUTROS,;
					(cAlsSTe)->ISENTO,(cAlsSTe)->VALCONT, (cAlsSTe)->IDENTFT}})
				(cAlsSTe)->(dbSkip())
			Enddo
		EndIf
	EndIf

	FWRestRows( aSaveLines )

Return aLoad1

//-------------------------------------------------------------------
/*{Protheus.doc} M953aSCab2()
Retorna estrutura do tipo FWformModelStruct.

@author Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M953aSCab2()

	Local aArea    := GetArea()
	Local oStruct := FWFormModelStruct():New()

// Tabela
	oStruct:AddTable('SFT',{'FT_FILIAL','FT_NFISCAL','FT_SERIE','FT_ITEM','FT_PRODUTO','FT_CFOP','FT_QUANT','FT_PRCUNIT','FT_TOTAL','FT_BASEICM','FT_VALICM','FT_ALIQICM'},"Itens das Notas Fiscais") // "Itens das Notas Fiscais"

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
	
	oStruct:AddField(	"CLASFIS"						,; 	// [01] C Titulo do campo // "CFOP"
	"CLASFIS" 						,; 	// [02] C ToolTip do campo // "CFOP"
	"FT_CLASFIS" 					,; 	// [03] C identificador (ID) do Field
	"C" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_CLASFIS")[1]		,; 	// [05] N Tamanho do campo
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
	"Base ICM"	   				,; 	// [02] C ToolTip do campo // "Base ICM"
	"FT_BASEICM"				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_BASEICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_BASEICM")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
					
	oStruct:AddField(	"Valor do Imposto"					,; 	// [01] C Titulo do campo // "Valor ICM"
	"Valor ICM" 				,; 	// [02] C ToolTip do campo // "Valor ICM"
	"FT_VALICM" 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_VALICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_VALICM")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Aliquota do Imposto"					,; 	// [01] C Titulo do campo // "Aliquota do Imposto"
	"Valor ICM" 				,; 	// [02] C ToolTip do campo // "Valor ICM"
	"FT_ALIQICM" 				,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_ALIQICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_ALIQICM")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Outros"						,; 	// [01] C Titulo do campo // "CFOP"
	"OUTROS" 						,; 	// [02] C ToolTip do campo // "CFOP"
	"FT_OUTRICM" 					,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_OUTRICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_OUTRICM")[2]		,; 	// [06] N Decimal do campo
	Nil 						,; 	// [07] B Code-block de validação do campo
	Nil							,; 	// [08] B Code-block de validação When do campo
	Nil 						,; 	// [09] A Lista de valores permitido do campo
	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
	Nil							,; 	// [11] B Code-block de inicializacao do campo
	Nil 						,;	// [12] L Indica se trata de um campo chave
	.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
	.F. )  	            		// [14] L Indica se o campo é virtual
	
	oStruct:AddField(	"Isento"						,; 	// [01] C Titulo do campo // "CFOP"
	"ISENTO" 						,; 	// [02] C ToolTip do campo // "CFOP"
	"FT_ISENICM" 					,; 	// [03] C identificador (ID) do Field
	"N" 						,; 	// [04] C Tipo do campo
	TamSX3("FT_ISENICM")[1]		,; 	// [05] N Tamanho do campo
	TamSX3("FT_ISENICM")[2]		,; 	// [06] N Decimal do campo
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
/*{Protheus.doc} M953aView2()
Retorna estrutura do tipo FWFormViewStruct.

@author Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//-------------------------------------------------------------------
Static function M953aView2()

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
	oStruct:AddField("FT_CLASFIS","07","Sit. Trib","Sit. Trib",{},"C","@!",/*bPictVar*/,/*cLookUp*/,.T.) // "CLASFIS"
	oStruct:AddField("FT_QUANT","08","Quantidade","Quantidade",{},"N","'@E 9999",/*bPictVar*/,/*cLookUp*/,.T.) // "Quantidade"
	oStruct:AddField("FT_PRCUNIT","09","Valor Unitário","Valor Unitário",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor Unitário"
	oStruct:AddField("FT_TOTAL","10","Valor Total","Valor Total",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor Total"
	oStruct:AddField("FT_BASEICM","11","Base de Cálculo","Base de Cálculo",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Base de Cálculo"
	oStruct:AddField("FT_VALICM","12","Valor do Imposto","Valor do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Valor do Imposto"
	oStruct:AddField("FT_ALIQICM","13","Aliquota do Imposto","Aliquota do Imposto",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Aliquota do Imposto"
	oStruct:AddField("FT_OUTRICM","14","Outros ICMS","Outros ICMS",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Outros ICMS"
	oStruct:AddField("FT_ISENICM","15","Isento ICMS","Isento ICMS",{},"N","@E 9,999,999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) // "Outros ICMS"
	
Return oStruct

//------------------------------------------------------------------------------------------
/* {Protheus.doc} A953aLoad2
Carrega o bloco de carga dos dados do submodelo 2

@author    Ronaldo Tapia
@version   12.1.17
@since     23/08/2017
*/
//------------------------------------------------------------------------------------------
Static Function A953aLoad2(oModel)

	Local aLoad2 		:= {}
	local cQry1  		:= ""
	Local aSaveLines	:= FWSaveRows()
	Local oModelApur	:= oModel:GetModel("SF3MASTER")
	Local cFilApur 		:= oModelApur:GetValue("FILIAL")
	Local cDoc	 		:= oModelApur:GetValue("DOC")
	Local cSerie 		:= oModelApur:GetValue("SERIE")
	Local cCFOP 		:= oModelApur:GetValue("CFOP")
	Local nAliq 		:= cValtoChar(oModelApur:GetValue("ALIQUOTA"))
	Local cIdent		:= oModelApur:GetValue("IDENTFT")
	Local aQry			:= {}
	Local cSlct			:= ""
	Local cWhere		:= ""
	Local cOrder		:= ""

	
	If (Select("TRB1") <> 0)
		dbSelectArea("TRB1")
		dbCloseArea()
	Endif
	
	aQry:= QrySFT(cFilApur,cDoc,cSerie,cCFOP,nAliq,cIdent)
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
		If IsInCallStack("ApurICMSSai") .Or. IsInCallStack("ApurICMSEnt")
			aAdd(aLoad2,{0,{TRB1->FT_FILIAL,TRB1->FT_NFISCAL,TRB1->FT_SERIE,TRB1->FT_ITEM,TRB1->FT_PRODUTO,TRB1->FT_CFOP,TRB1->FT_CLASFIS,;
				TRB1->FT_QUANT,TRB1->FT_PRCUNIT,TRB1->FT_TOTAL,TRB1->FT_BASEICM,TRB1->FT_VALICM,TRB1->FT_ALIQICM, TRB1->FT_OUTRICM, TRB1->FT_ISENICM}})
		ElseIf IsInCallStack("ApurSTSai") .Or. IsInCallStack("ApurSTEnt")
			aAdd(aLoad2,{0,{TRB1->FT_FILIAL,TRB1->FT_NFISCAL,TRB1->FT_SERIE,TRB1->FT_ITEM,TRB1->FT_PRODUTO,TRB1->FT_CFOP, TRB1->FT_CLASFIS,;
				TRB1->FT_QUANT,TRB1->FT_PRCUNIT,TRB1->FT_TOTAL,TRB1->FT_BASERET,TRB1->FT_ICMSRET,TRB1->FT_ALIQICM, TRB1->FT_OUTRICM, TRB1->FT_ISENICM}})
		EndIf
		TRB1->(dbSkip())
	Enddo
	
	FWRestRows( aSaveLines )

Return aLoad2

//---------------------------------------------------------------------------------------------------------

/* Função que irá executar a query da SFT para carregar na tela da rotina e nos relatórios

*/
//---------------------------------------------------------------------------------------------------------- 

Function QrySFT(cFilApur,cDoc,cSerie,cCFOP,nAliq,cIdent)

	Local cSlct := ""
	Local cFrom := ""
	Local cWhere:= ""
	Local cOrder:= ""

	default cFilApur 	:= ""
	Default cDoc 		:= ""
	Default cSerie		:= ""
	Default cCFOP 		:= ""
	Default nAliq		:= 0
	Default cIdent		:= ""

	cSlct += " SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_CFOP,"
	cSlct += " SFT.FT_CLASFIS,SFT.FT_QUANT,SFT.FT_PRCUNIT,SFT.FT_TOTAL,SFT.FT_BASEICM,SFT.FT_VALICM,SFT.FT_ALIQICM, SFT.FT_BASERET, SFT.FT_ICMSRET, SFT.FT_OUTRICM, SFT.FT_ISENICM "
	
	cFrom := " "+RetSQLName("SFT") + " SFT "
	
	cWhere := " SFT.D_E_L_E_T_ = ' ' "
	cWhere += " AND SFT.FT_FILIAL = '"+cFilApur+"' "
	cWhere += " AND SFT.FT_NFISCAL = '"+cDoc+"' "
	cWhere += " AND SFT.FT_SERIE = '"+cSerie+"' "
	cWhere += " AND SFT.FT_ALIQICM = '"+nAliq+"' "
	cWhere += " AND SFT.FT_IDENTF3 = '"+cIdent+"'
	
	cOrder += " SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE"
	
	
	

Return {cSlct,cFrom,cWhere,cOrder}

//----------------------------------------------------------------------------

/*M953ARel - Função que irá imprimir o relatório das notas fiscais*/

//----------------------------------------------------------------------------

Function M953ARel()

If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
EndIf	


//------------------------------------------------------------


Static Function ReportDef()

	Local oReport     	:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Private oBreak		:= Nil
	Private oBreak2		:= Nil

	oReport             := Nil
	oReport	:= TReport():New('MATA953A',"Listagem de NFs",'',{|oReport| ListNotas()},"STR0001",,,,,.F.) //'Relatório de previsão da apuração dos eventos.'
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
	TRCell():New(oSection1,'ESTADO'		, '', "UF"	, /*Picture*/,  5,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'CFOP'		, '', "CFOP", /*Picture*/	 , 10,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'FORMULA'	, '', "FORMULA", /*Picture*/	 , TAMSX3("F3_FORMUL")[1], /*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'CODRSEF'	, '', "CODRSEF", /*Picture*/ 	 ,  10, /*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'ALIQUOTA'	, '', "ALIQUOTA"	, "@E 99.99" ,  20,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'VALOR'		, '', "VALOR"	, "@E 999999999999999.99", TAMSX3("F3_VALICM")[1] ,	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'OUTROS'		, '', "OUTROS"	, "@E 999999999999999.99",  TAMSX3("F3_OUTRICM")[1],	/*lPixel*/,,"LEFT",,"LEFT") 
	TRCell():New(oSection1,'ISENTO'		, '', "ISENTO", "@E 999999999999999.99"		 , TAMSX3("F3_ISENICM")[1],	/*lPixel*/,,"LEFT",,"LEFT") 
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
	TRCell():New(oSection2,"FT_BASEICM"	,  "", "BASE ICMS")
	TRCell():New(oSection2,"FT_VALICM"	,  "", "VAL. ICMS")
	TRCell():New(oSection2,"FT_ALIQICM"	,  "", "ALIQ. ICMS")
	TRCell():New(oSection2,"FT_BASERET"	,  "", "BASE ICMS ST")
	TRCell():New(oSection2,"FT_ICMSRET"	,  "", "VAL. ICMS ST")
	TRCell():New(oSection2,"FT_OUTRICM"	,  "", "OUTROS ICMS")
	TRCell():New(oSection2,"FT_ISENICM"	,  "", "ISEN. ICMS")
	
	
	oBreak := TRBreak():New(oSection2,oSection2:Cell("FT_FILIAL"),"Totalizadores ",.T.,'Totalizadores',.T.)
	TRFunction():New(oSection2:Cell("FT_TOTAL"),NIL,"SUM",oBreak,'Valor das Operações',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_TOTAL"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_BASEICM"),NIL,"SUM",oBreak,'Base de ICMS',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_BASEICM"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_VALICM"),NIL,"SUM",oBreak,'Valor ICMS',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_VALICM"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_OUTRICM"),NIL,"SUM",oBreak,'Outros ICMS',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_OUTRICM"):getvalue()) }*/) 
	TRFunction():New(oSection2:Cell("FT_ISENICM"),NIL,"SUM",oBreak,'Isento ICMS',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_ISENICM"):getvalue()) }*/)
	TRFunction():New(oSection2:Cell("FT_ICMSRET"),NIL,"SUM",oBreak,'ICMS Retido',,,.F.,.F.,,,/*{|| Empty(oSection2:Cell("FT_ISENICM"):getvalue()) }*/)
	
	
Return(oReport)

//--------------------------------------------------

//--------------------------------------------------

Function ListNotas()	
	
	Local cAlsDeb		:= "ICMSDEB"
	Local cTempDeb		:= "ICMSDEBITO"+AllTrim(Str(ThreadID()))
	Local cAlsCrd		:= "ICMSCRD"
	Local cTempCrd		:= "ICMSCREDITO"+AllTrim(Str(ThreadID()))
	Local cAlsSTd		:= "STDEB"
	Local cTempSTd		:= "STDEBITO"+AllTrim(Str(ThreadID()))
	Local cAlsSTe		:= "STCRD"
	Local cTempSTe		:= "STCREDITO"+AllTrim(Str(ThreadID()))
	Local oCab 			:= oReport:Section(1)
	Local oItem 		:= oReport:Section(2)
	Local aQry			:= {}
	Local cSlct			:= ""
	Local cWhere		:= ""
	Local cOrder		:= ""
	Local cAliIt		:= ""
	private oBreak := Nil
	private oBreak2 := Nil
	
	If IsInCallStack("ApurICMSSai")
		If Select( cAlsDeb ) <= 0
			DbSelectArea(cAlsDeb)
		EndIf

		( cAlsDeb )->(dbGoTop())
		oCab:init()

		While !(cAlsDeb)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsDeb)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsDeb)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsDeb)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsDeb)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsDeb)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsDeb)->LOJA)
			oCab:Cell("ESTADO"):SetValue((cAlsDeb)->ESTADO)
			oCab:Cell("CFOP"):SetValue((cAlsDeb)->CFOP)
			oCab:Cell("FORMULA"):SetValue((cAlsDeb)->FORMULA)
			oCab:Cell("CODRSEF"):SetValue((cAlsDeb)->CODRSEF)
			oCab:Cell("ALIQUOTA"):SetValue((cAlsDeb)->ALIQUOTA)
			oCab:Cell("VALOR"):SetValue((cAlsDeb)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsDeb)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsDeb)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsDeb)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsDeb)->IDENTFT)
			oCab:Printline()
			( cAlsDeb )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsDeb )->(dbGoTop())
		While !(cAlsDeb)->(Eof())	
			
			aQry:= QrySFT((cAlsDeb)->FILIAL,(cAlsDeb)->DOC,(cAlsDeb)->SERIE,(cAlsDeb)->CFOP,cValtoChar((cAlsDeb)->ALIQUOTA),(cAlsDeb)->IDENTFT)
			
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
				oItem:Cell("FT_CLASFIS"):SetValue((cAliIT)->FT_CLASFIS)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEICM"):SetValue((cAliIT)->FT_BASEICM)
				oItem:Cell("FT_VALICM"):SetValue((cAliIT)->FT_VALICM)
				oItem:Cell("FT_ALIQICM"):SetValue((cAliIT)->FT_ALIQICM)
				oItem:Cell("FT_BASERET"):SetValue((cAliIT)->FT_BASERET)
				oItem:Cell("FT_ICMSRET"):SetValue((cAliIT)->FT_ICMSRET)
				oItem:Cell("FT_OUTRICM"):SetValue((cAliIT)->FT_OUTRICM)
				oItem:Cell("FT_ISENICM"):SetValue((cAliIT)->FT_ISENICM)

				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsDeb )->(dbSkip())
			
		EndDo
		oItem:Finish()
		
		
	ElseIf IsInCallStack("ApurICMSEnt")
		If Select( cAlsCrd) <= 0
			DbSelectArea(cAlsCrd)
		EndIf

		( cAlsCrd )->(dbGoTop())
		oCab:init()
		While !(cAlsCrd)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsCrd)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsCrd)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsCrd)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsCrd)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsCrd)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsCrd)->LOJA)
			oCab:Cell("ESTADO"):SetValue((cAlsCrd)->ESTADO)
			oCab:Cell("CFOP"):SetValue((cAlsCrd)->CFOP)
			oCab:Cell("FORMULA"):SetValue((cAlsCrd)->FORMULA)
			oCab:Cell("CODRSEF"):SetValue((cAlsCrd)->CODRSEF)
			oCab:Cell("ALIQUOTA"):SetValue((cAlsCrd)->ALIQUOTA)
			oCab:Cell("VALOR"):SetValue((cAlsCrd)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsCrd)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsCrd)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsCrd)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsCrd)->IDENTFT)
			oCab:Printline()
			( cAlsCrd )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsCrd )->(dbGoTop())
		While !(cAlsCrd)->(Eof())	
			
			aQry:= QrySFT((cAlsCrd)->FILIAL,(cAlsCrd)->DOC,(cAlsCrd)->SERIE,(cAlsCrd)->CFOP,cValtoChar((cAlsCrd)->ALIQUOTA),(cAlsCrd)->IDENTFT)
			
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
				oItem:Cell("FT_CLASFIS"):SetValue((cAliIT)->FT_CLASFIS)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEICM"):SetValue((cAliIT)->FT_BASEICM)
				oItem:Cell("FT_VALICM"):SetValue((cAliIT)->FT_VALICM)
				oItem:Cell("FT_ALIQICM"):SetValue((cAliIT)->FT_ALIQICM)
				oItem:Cell("FT_BASERET"):SetValue((cAliIT)->FT_BASERET)
				oItem:Cell("FT_ICMSRET"):SetValue((cAliIT)->FT_ICMSRET)
				oItem:Cell("FT_OUTRICM"):SetValue((cAliIT)->FT_OUTRICM)
				oItem:Cell("FT_ISENICM"):SetValue((cAliIT)->FT_ISENICM)
				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsCrd )->(dbSkip())
			
		EndDo
		oItem:Finish()
		
	ElseIf IsInCallStack("ApurSTSai")
		If Select( cAlsSTd ) <= 0
			DbSelectArea(cAlsSTd)
		EndIf

		( cAlsSTd )->(dbGoTop())
		oCab:init()
		While !(cAlsSTd)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsSTd)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsSTd)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsSTd)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsSTd)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsSTd)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsSTd)->LOJA)
			oCab:Cell("ESTADO"):SetValue((cAlsSTd)->ESTADO)
			oCab:Cell("CFOP"):SetValue((cAlsSTd)->CFOP)
			oCab:Cell("FORMULA"):SetValue((cAlsSTd)->FORMULA)
			oCab:Cell("CODRSEF"):SetValue((cAlsSTd)->CODRSEF)
			oCab:Cell("ALIQUOTA"):SetValue((cAlsSTd)->ALIQUOTA)
			oCab:Cell("VALOR"):SetValue((cAlsSTd)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsSTd)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsSTd)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsSTd)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsSTd)->IDENTFT)
			oCab:Printline()
			( cAlsSTd )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsSTd )->(dbGoTop())
		While !(cAlsSTd)->(Eof())	
			
			aQry:= QrySFT((cAlsSTd)->FILIAL,(cAlsSTd)->DOC,(cAlsSTd)->SERIE,(cAlsSTd)->CFOP,cValtoChar((cAlsSTd)->ALIQUOTA),(cAlsSTd)->IDENTFT)
			
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
				oItem:Cell("FT_CLASFIS"):SetValue((cAliIT)->FT_CLASFIS)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEICM"):SetValue((cAliIT)->FT_BASEICM)
				oItem:Cell("FT_VALICM"):SetValue((cAliIT)->FT_VALICM)
				oItem:Cell("FT_ALIQICM"):SetValue((cAliIT)->FT_ALIQICM)
				oItem:Cell("FT_BASERET"):SetValue((cAliIT)->FT_BASERET)
				oItem:Cell("FT_ICMSRET"):SetValue((cAliIT)->FT_ICMSRET)
				oItem:Cell("FT_OUTRICM"):SetValue((cAliIT)->FT_OUTRICM)
				oItem:Cell("FT_ISENICM"):SetValue((cAliIT)->FT_ISENICM)

				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsSTd )->(dbSkip())
			
		EndDo
		oItem:finish()
		
	ElseIf IsInCallStack("ApurSTEnt")
		If Select(cAlsSTe) <= 0
			DbSelectArea(cAlsSTe)
		EndIf

		( cAlsSTe )->(dbGoTop())
		oCab:init()
		While !(cAlsSTe)->(Eof())
			oCab:Cell("FILIAL"):SetValue((cAlsSTe)->FILIAL)
			oCab:Cell("DOC"):SetValue((cAlsSTe)->DOC)
			oCab:Cell("SERIE"):SetValue((cAlsSTe)->SERIE)
			oCab:Cell("EMISSAO"):SetValue((cAlsSTe)->EMISSAO)
			oCab:Cell("FORNECE"):SetValue((cAlsSTe)->FORNECE)
			oCab:Cell("LOJA"):SetValue((cAlsSTe)->LOJA)
			oCab:Cell("ESTADO"):SetValue((cAlsSTe)->ESTADO)
			oCab:Cell("CFOP"):SetValue((cAlsSTe)->CFOP)
			oCab:Cell("FORMULA"):SetValue((cAlsSTe)->FORMULA)
			oCab:Cell("CODRSEF"):SetValue((cAlsSTe)->CODRSEF)
			oCab:Cell("ALIQUOTA"):SetValue((cAlsSTe)->ALIQUOTA)
			oCab:Cell("VALOR"):SetValue((cAlsSTe)->VALOR)
			oCab:Cell("OUTROS"):SetValue((cAlsSTe)->OUTROS)
			oCab:Cell("ISENTO"):SetValue((cAlsSTe)->ISENTO)
			oCab:Cell("VALCONT"):SetValue((cAlsSTe)->VALCONT)
			oCab:Cell("IDENTFT"):SetValue((cAlsSTe)->IDENTFT)
			oCab:Printline()
			( cAlsSTe )->(dbSkip())
			
		
		EndDo
		oCab:Finish()
		( cAlsSTe )->(dbGoTop())
		While !(cAlsSTe)->(Eof())	
			
			aQry:= QrySFT((cAlsSTe)->FILIAL,(cAlsSTe)->DOC,(cAlsSTe)->SERIE,(cAlsSTe)->CFOP,cValtoChar((cAlsSTe)->ALIQUOTA),(cAlsSTe)->IDENTFT)
			
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
				oItem:Cell("FT_CLASFIS"):SetValue((cAliIT)->FT_CLASFIS)
				oItem:Cell("FT_QUANT"):SetValue((cAliIT)->FT_QUANT)
				oItem:Cell("FT_PRCUNIT"):SetValue((cAliIT)->FT_PRCUNIT)
				oItem:Cell("FT_TOTAL"):SetValue((cAliIT)->FT_TOTAL)
				oItem:Cell("FT_BASEICM"):SetValue((cAliIT)->FT_BASEICM)
				oItem:Cell("FT_VALICM"):SetValue((cAliIT)->FT_VALICM)
				oItem:Cell("FT_ALIQICM"):SetValue((cAliIT)->FT_ALIQICM)
				oItem:Cell("FT_BASERET"):SetValue((cAliIT)->FT_BASERET)
				oItem:Cell("FT_ICMSRET"):SetValue((cAliIT)->FT_ICMSRET)
				oItem:Cell("FT_OUTRICM"):SetValue((cAliIT)->FT_OUTRICM)
				oItem:Cell("FT_ISENICM"):SetValue((cAliIT)->FT_ISENICM)
				oItem:Printline()
				
				( cAliIT )->(dbSkip())
				
			EndDo
			
			( cAlsSTe )->(dbSkip())
			
		EndDo
		oItem:finish()
	EndIf
return 
	
	