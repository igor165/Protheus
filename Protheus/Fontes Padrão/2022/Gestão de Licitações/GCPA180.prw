#include "GCPA180.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include "TbiConn.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA180
Consulta SICAF x Inclusao de Fornecedor
@author Rogerio Melonio
@since 12/06/15
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA180
Local oBrowse
Static aCampos	:= {}
Static aGrid	:= {}

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('SA2')

// Titulo da Browse
oBrowse:SetDescription(STR0001)//'Cadastro de Fornecedores/Habilitação'

// Opcionalmente pode ser desligado a exibição dos detalhes
oBrowse:DisableDetails()

// Ativação da Classe
oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Cria o menu de opcoes da rotina
@author Rogerio Melonio
@since 15/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0035		Action 'GCP180VIS' 		OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina Title STR0002 		Action 'VIEWDEF.GCPA180'	OPERATION 3 ACCESS 0	//'Incluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Rogerio Melonio
@since 12/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil

//--> chama funcao a180Model para incluir mahualmente todos os campos do modelo
oModel := a180Model(oModel)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface
@author Rogerio Melonio
@since 12/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel	:= ModelDef()
Local oView		:= Nil

//--> chama função a180View para criar a view manualmente
oView := a180View(oModel,oView)

// limpa os arrays dos campos para nao gerar duplicidade dos mesmos no model e na view
aCampos	:= {}
aGrid	:= {}

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} a180Model
Adiciona os campos manualmente na estrutura do modelo de dados
@author Rogerio Melonio
@since 16/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a180Model(oModel)
Local cMascaraPJ 	:=  '@R 99.999.999/9999-99'
Local cMascaraPF 	:=  '@R 999.999.999-99'
Local aPessoa		:= { '0=Todos','1=Pessoa Jurídica','2=Pessoa Física' }
Local aAtivo 		:= { '0=Todos','1=Ativo','2=Inativo' }
Local aPorte		:= { '0=Todos','1=Microempresa','3=Pequeno Porte','5=Demais' }
Local aNatureza		:= {}
Local aTipo			:= { '1=Fornecedor','2=Participante' }
Local cCampo		:= ""
Local nTamA2Nome	:= TamSX3("A2_NOME")[1]
Local nTamA2Mun		:= TamSX3("A2_MUN")[1]
Local nCampo		:=0

// Cria a estrutura a ser usada no Modelo de Dados
Local oStru1 	:= FWFormModelStruct():New()
Local oStru2 	:= FWFormModelStruct():New()
Local bInitTipo	:= { || "  " }
Local bInitAtivo:= { || .T. }
Local bInitUF	:= { || Criavar("A2_EST") }
Local bValid012 := { || .T. }
Local bInit012	:= { || "0" }
Local bInitC10  := { || Space(10) }
Local bInitC40  := { || Criavar("A2_NOME") }
Local bInitCPF	:= { || Criavar("A2_CGC") }
Local bInitCNPJ	:= { || Criavar("A2_CGC") }
Local bWhenTrue := { || .T. }
Local bVldUF 	:= {|a,b,c,d| a180SicUF(a,b,c,d)}

aNatureza := { '0=Todos','1=Empresa Individual','2=Ltda','3=S/A','4=Cooperativa','5=Nome Coletivo','6=Comantida Simples','7=Capital Indústria',;
				'8=Comandita por Ações','9=Economia Mista','10=Fundação Privada','11=Sociedade Civil Sem FIns Lucrativos','12=Sociedade Civil',;
				'13=Empresa Pública','14=Sociedade Estrangeira','15=Autarquias e Fundações Públicas' }

oStru1:AddTable("   ",{" "}," ")
//--> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - bValid, [11] bInit
aAdd( aCampos,{'tipo_pessoa'	,'C',01,'@!'			,'Tipo'			,'Tipo'			,aPessoa  		,NIL ,bWhenTrue	,bValid012 ,bInit012  } )	//	Texto		Tipo da pessoa, física 'PF' ou jurídica 'PJ'.
aAdd( aCampos,{'uf'				,'C',02,'@!'			,'UF'				,'UF'				,NIL	  		,NIL ,bWhenTrue	,bVldUF    ,bInitUF   } )	//	Texto		Sigla da Unidade Federativa.
aAdd( aCampos,{'cnpj'			,'C',14,cMascaraPJ	,'CNPJ'			,'CNPJ'			,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitCNPJ } )	//	Texto		CNPJ do fornecedor.
aAdd( aCampos,{'cpf'				,'C',11,cMascaraPF	,'CPF'				,'CPF'				,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitCPF  } )	//	Texto		CPF do fornecedor.
aAdd( aCampos,{'nome'			,'C',40,'@!'			,'Razão Social'	,'Razão Social'	,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC40  } )	//	Texto		Parte do nome do fornecedor.
aAdd( aCampos,{'ativo'			,'C',01,'@!' 			,'Ativo?'			,'Ativo?'			,aAtivo	  	,NIL ,bWhenTrue	,bValid012 ,bInit012  } )	// 	Booleano	Se o fornecedor está ativo.
aAdd( aCampos,{'cnae'			,'C',10,'@9'			,'ID CNAE'			,'ID CNAE'			,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único do código CNAE do fornecedor.
aAdd( aCampos,{'linha'			,'C',10,'@9'			,'ID Linha'		,'ID Linha'		,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único de linha de fornecimento do fornecedor.
aAdd( aCampos,{'municipio'		,'C',10,'@9'			,'ID Mun. SICAF'	,'ID Mun. SICAF'	,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único de município no SICAF.
aAdd( aCampos,{'ramo'			,'C',10,'@9'			,'Ramo'			,'Ramo'			,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único do ramo de negócio do fornecedor.
aAdd( aCampos,{'unidade'			,'C',10,'@9'			,'Unid. Cad.'		,'Unid. Cad.'		,NIL	  		,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único da Unidade Cadastradoar à qual o	fornecedor está cadastrado no SICAF.
aAdd( aCampos,{'natureza'		,'C',01,'@!'			,'Nat. Jur.'		,'Nat. Jur.'		,aNatureza 	,NIL ,bWhenTrue	,NIL       ,NIL		 } )	//	Inteiro	Identificador único da natureza jurídica do fornecedor.
aAdd( aCampos,{'porte'			,'C',01,'@!' 			,'Porte'			,'Porte'			,aPorte	  	,NIL ,bWhenTrue	,NIL       ,bInitC10  } )	//	Inteiro	Identificador único do tipo da empresa do fornecedor.

For nCampo := 1 To Len(aCampos)
	cCampo := "STRU1_" + aCampos[nCampo][01]
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru1:AddField(aCampos[nCampo][05]	,;	// 	[01]  C   Titulo do campo
				 	aCampos[nCampo][06]		,;	// 	[02]  C   ToolTip do campo
				 	cCampo						,;	// 	[03]  C   Id do Field
				 	aCampos[nCampo][02]		,;	// 	[04]  C   Tipo do campo
				 	aCampos[nCampo][03]		,;	// 	[05]  N   Tamanho do campo
				 	0							,;	// 	[06]  N   Decimal do campo
				 	aCampos[nCampo][10]		,;	// 	[07]  B   Code-block de validação do campo
				 	aCampos[nCampo][09]		,;	// 	[08]  B   Code-block de validação When do campo
				 	aCampos[nCampo][07]		,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	aCampos[nCampo][11]		,;	//	[11]  B   Code-block de inicializacao do campo
				 	.F.							,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.T.							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.							)	// 	[14]  L   Indica se o campo é virtual
Next

//--> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - Alteravel?
aAdd( aGrid,{'STRU2_ITEM'		,'C',06			,'@!'			,'Item'				,'Item'				,NIL				,NIL,NIL  		,.F.	} )
aAdd( aGrid,{'STRU2_OK'			,'L',01			,NIL			,'  '					,'  '					,NIL				,NIL,bWhenTrue,.T.	} )
aAdd( aGrid,{'STRU2_TIPO'		,'C',01			,'@!'			,'Tipo de Cadastro'	,'Tipo de Cadastro'	,aTipo				,NIL,bWhenTrue,.T.	} )
aAdd( aGrid,{'STRU2_CNPJ'		,'C',14			,cMascaraPJ	,'CNPJ'				,'CNPJ'				,NIL				,NIL,NIL  		,.F.	} )
aAdd( aGrid,{'STRU2_CPF'			,'C',11			,cMascaraPF	,'CPF'					,'CPF'					,NIL				,NIL,NIL  		,.F.	} )
aAdd( aGrid,{'STRU2_NOME'		,'C',nTamA2Nome	,'@!'			,'Razão Social'		,'Razão Social'		,NIL				,NIL,NIL  		,.F.	} )
aAdd( aGrid,{'STRU2_UF'			,'C',02			,'@!'			,'UF'					,'UF'					,NIL				,NIL,NIL  		,.F. 	} )
aAdd( aGrid,{'STRU2_MUNICIPIO'	,'C',nTamA2Mun	,'@!' 			,'Municipio'			,'Municipio'			,NIL				,NIL,NIL  		,.F. 	} )
aAdd( aGrid,{'STRU2_RAMO'		,'C',30			,'@!'			,'Ramo'				,'Ramo'				,NIL				,NIL,NIL  		,.F. 	} )
aAdd( aGrid,{'STRU2_NATUREZA'	,'C',30			,'@!'			,'Natureza'			,'Natureza'			,NIL				,NIL,NIL  		,.F. 	} )
aAdd( aGrid,{'STRU2_PORTE'		,'C',30			,'@!'			,'Porte'				,'Porte'				,NIL				,NIL,NIL  		,.F. 	} )
aAdd( aGrid,{'STRU2_ATIVO'		,'C',01			,'@!'			,'Ativo?'				,'Ativo?'				,aAtivo			,NIL,NIL  		,.F.	} )
aAdd( aGrid,{'STRU2_IDSICAF'	,'C',10			,'@!'			,'Id Sicaf'			,'Id Sicaf'			,NIL				,NIL,NIL  		,.F.	} )

oStru2:AddTable("   ",{" "}," ")
For nCampo := 1 To Len(aGrid)
	//-- Adiciona campos detail do resultado da busca de fornecedor 
	oStru2:AddField( aGrid[nCampo][05]		,;	// 	[01]  C   Titulo do campo
					 aGrid[nCampo][06]		,;	// 	[02]  C   ToolTip do campo
					 aGrid[nCampo][01]		,;	// 	[03]  C   Id do Field
					 aGrid[nCampo][02]		,;	// 	[04]  C   Tipo do campo
					 aGrid[nCampo][03]		,;	// 	[05]  N   Tamanho do campo
					 0							,;	// 	[06]  N   Decimal do campo
					 NIL						,;	// 	[07]  B   Code-block de validação do campo
					 aGrid[nCampo][09]		,;	// 	[08]  B   Code-block de validação When do campo
					 aGrid[nCampo][07]		,;	//	[09]  A   Lista de valores permitido do campo
					 .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL						,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.						)	// 	[14]  L   Indica se o campo é virtual
Next

oModel := MPFormModel():New('GCPA180', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'STRU1MASTER',/*cOwner*/, oStru1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'STRU2DETAIL', 'STRU1MASTER', oStru2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//oStru1:SetProperty("STRU1_UF",MODEL_FIELD_VALID,{ |a,b,c,d,e| a180SicUF(a,b,c,d) ,lRet := CN300VlQtd(d,e) .And. A300CalcVl(a) .And. cn300vlMod() .And. CN300VlQMd() ,FWCloseCpo(a,b,c,lRet,.T.),lRet})
//Local bVldUF 	:= {|a,b,c,d| a180SicUF(a,b,c,d)}


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0003 )//"Consulta de Fornecedores no SICAF"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'STRU1MASTER' ):SetDescription( STR0004 )//"Parâmetros de Consulta de Fornecedores"
oModel:GetModel( 'STRU2DETAIL' ):SetDescription( STR0036 )//'Resultado da Consulta'

// bloqueia inclusão / exclusão de linhas pelo usuário no grid
oModel:GetModel( 'STRU2DETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'STRU2DETAIL' ):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey( {} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} a180View
Adiciona os campos manualmente na estrutura da view
@author Rogerio Melonio
@since 16/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a180View(oModel,oView)
// Cria a estrutura a ser usada na View
Local oStru1	:= FWFormViewStruct():New()
Local oStru2	:= FWFormViewStruct():New()
Local nCampo  := 0

For nCampo := 1 To Len(aCampos)
	//--> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - bValid, [11] bInit
	cCampo := "STRU1_" + aCampos[nCampo][01]
	cOrdem := StrZero(nCampo,2)
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru1:AddField(cCampo					,;	// [01]  C   Nome do Campo
					cOrdem						,;	// [02]  C   Ordem
					aCampos[nCampo][05] 		,;	// [03]  C   Titulo do campo
					aCampos[nCampo][06] 		,;	// [04]  C   Descricao do campo
					{}							,;	// [05]  A   Array com Help
					aCampos[nCampo][02]		,;	// [06]  C   Tipo do campo
					aCampos[nCampo][04]		,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					aCampos[nCampo][08]		,;	// [09]  C   Consulta F3
					.T.							,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					aCampos[nCampo][07]		,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					.F.							)	// [18]  L   Indica pulo de linha após o campo
Next

For nCampo := 1 To Len(aGrid)
	//-- Adiciona campos detail do resultado da busca de fornecedor 
	cOrdem := StrZero(nCampo,2)
	//--> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - Alteravel?
	oStru2:AddField(aGrid[nCampo][01]		,;	// [01]  C   Nome do Campo
					cOrdem						,;	// [02]  C   Ordem
					aGrid[nCampo][05]			,;	// [03]  C   Titulo do campo
					aGrid[nCampo][06]			,;	// [04]  C   Descricao do campo
					{}							,;	// [05]  A   Array com Help
					aGrid[nCampo][02]			,;	// [06]  C   Tipo do campo
					aGrid[nCampo][04]			,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					aGrid[nCampo][08]			,;	// [09]  C   Consulta F3
					aGrid[nCampo][10]			,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					aGrid[nCampo][07]			,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					.F.							)	// [18]  L   Indica pulo de linha após o campo
Next

//-- Monta o modelo da interface do formulario
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_STRU1',oStru1,'STRU1MASTER')
oView:AddGrid('VIEW_STRU2',oStru2,'STRU2DETAIL')
oView:AddIncrementField( 'VIEW_STRU2', 'STRU2_ITEM' )

//-- Cria as 2 divisoes da interface
oView:CreateHorizontalBox('SUPERIOR',50)
oView:CreateHorizontalBox('INFERIOR',50)

//Bloco SetOwnerView
oView:SetOwnerView('VIEW_STRU1','SUPERIOR')
oView:SetOwnerView('VIEW_STRU2','INFERIOR')

//--> Adiciona botoes de chamada de rotinas de processamento ao menu de açoes relacionadas
oView:AddUserButton("Busca SICAF", 'CLIPS', {|oView|  GcpUrlMake(oModel,'STRU1MASTER')})//'Busca SICAF'
oView:AddUserButton(STR0005,'CLIPS', {|oView| A180INCLUI( oModel ) } )//'Inclui Fornecedor/Participante'

Return oView
				 
//-------------------------------------------------------------------
/*/{Protheus.doc} GcpUrlMake
Gera URL de acordo com campos de filtros preenchidos 
@author José Eulálio
@since 17/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GcpUrlMake(oModel,cStru,cUrl)
Local cPar			:= ""
Local cCampo		:= ""
Local cValor		:= ""
Local nX			:= 0
Local nC			:= 0
Local oModStru		:= oModel:GetModel(cStru)
Local aHeadStru		:= oModStru:GetStruct():GetFields()
Local aAux			:= {}
Local lRet			:= .T.

DEFAULT cUrl 		:= "http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml?"

For nX := 1 to Len(aHeadStru)
	cValor	:= FwUrlEncode(AllTrim(oModStru:GetValue(aHeadStru[nX][3])))
	cCampo	:= upper(aHeadStru[nX][3])
	// Quando usado cValor <> "0", para CNPJ que começa com 0 o resultado dá .F. e não considera o valor informado
	If !Empty(cValor) .And. !( cValor == "0")
		If cCampo == "STRU1_LINHA"
			cPar := "id_linha_fornecimento"
			nC++
		ElseIf cCampo == "STRU1_UF"
			cPar := "uf"
			nC++
		ElseIf cCampo == "STRU1_NOME"
			cPar := "nome"
			nC++
		ElseIf cCampo == "STRU1_CNPJ"
			cPar := "cnpj"
			nC++
		ElseIf cCampo == "STRU1_TIPO_PESSOA"
			cPar := "tipo_pessoa"
			If cValor == "1"
				cValor := "PJ"
			ElseIf  cValor == "2"
				cValor := "PF"
			EndIf
			nC++
		ElseIf cCampo == "STRU1_CPF"
			cPar := "cpf"					
			nC++
		ElseIf cCampo == "STRU1_ATIVO"
			cPar := "ativo"					
			If cValor == "1"
				cValor := "true"
			ElseIf  cValor == "2"
				cValor := "false"
			EndIf
			nC++		
		ElseIf cCampo == "STRU1_CNAE"
			cPar := "id_cnae"				
			nC++
		ElseIf cCampo == "STRU1_MUNICIPIO"
			cPar := "id_municipio"			
			nC++
		ElseIf cCampo == "STRU1_RAMO"
			cPar := "id_ramo_negocio"		
			nC++
		ElseIf cCampo == "STRU1_UNIDADE"
			cPar := "id_unidade_cadastradora"
			nC++
		ElseIf cCampo == "STRU1_NATUREZA"
			cPar := "id_natureza_juridica"	
			nC++
		ElseIf cCampo == "STRU1_PORTE"
			cPar := "id_porte_empresa"		
			nC++
		Else
			cPar := StrTran(aHeadStru[nX][3],"STRU1_",,1)
			nC++
		EndIf
		If nC > 1
			cUrl += "&"
		EndIf
		cUrl += cPar + "=" + cValor		
	EndIf
Next nX

If nC == 0
	Help("",1,STR0007,,STR0006,4,1)//"Não existem campos preenchidos para realizar esta busca."//"Vazios"
	lRet := .F.
EndIf

If lRet .And. nC > 0
	MsgRun( STR0009,STR0008 , { || GcpConSicaf(cUrl,oModel) } )//"Aguarde..."//"Carregando Dados SICAF"
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GcpConSicaf
Faz httpget() da URL com os filtros passados
@author José Eulálio
@since 17/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GcpConSicaf(cUrl,oModel)
Local cGetPar		:= ""
Local cHeaderRet	:= ""
Local cResponse		:= ""
Local cAviso    	:= ""
Local aId			:= {}
Local aCNPJ			:= {}
Local aCPF			:= {}
Local aNome			:= {}
Local aAtivo		:= {}
Local aUF			:= {}
Local aMunicipio	:= {}
Local aNatureza		:= {}
Local aRamoNegocio	:= {}
Local aPorteEmpresa	:= {}
Local aID			:= {}

Local cErro     	:= ""
Local cMsg			:= ""
Local nTimeOut		:= 120 //Segundos
Local nErro1		:= 0
Local nX			:= 0
Local nC			:= 0
Local nI			:= 0
Local nLinha		:= 0
Local nLink			:= 0
Local aHeaderStr	:= {}
Local lRet 			:= .F. 
Local lSicaf 		:= .F. 
Local lBasica    	:= .F.
Local lDetalhada 	:= .F.
Local lAtivo		:= .F.
Local oSicaf 		:= Nil
Local oView  		:= FWViewActive()
Local oResponse1	:= Nil
Local oEmbedded		:= Nil
Local oEstado		:= Nil
Local oAtivo		:= Nil
Local oNome			:= Nil 
Local oCNPJ			:= Nil
Local oCPF			:= Nil
Local oId			:= Nil
Local oModStru2		:= Nil
Local lFim 			:= .F. 
Local nCount 		:= 0
Local nOffSet 		:= 0
Local cUrlOri 		:= cUrl

Local cNatureza     := ""
Local cRamoNegocio  := ""
Local cPorteEmpresa := ""

Local nTamA2Nome	:= TamSX3("A2_NOME")[1]
Local nTamA2Mun		:= TamSX3("A2_MUN")[1]
	
aAdd(aHeaderStr,"Content-Type: application/x-www-form-urlencoded" )

While !lFim
	//--> realiza consulta basica
	cResponse := HTTPGet( cUrl, , nTimeOut, aHeaderStr, @cHeaderRet )
	nErro1 := HTTPGetStatus(cErro)
	
	// se ocorreu erro no get do site do SICAF exibe erro
	If nErro1 <> 0 .And. nErro1 <> 200
		cMsg := STR0011 + CRLF + CRLF + cErro + STR0010//"Continua consulta?"//"Problemas consultando dados básicos do fornecedor"
		lFim := MSGYESNO('',cMsg)
		lRet := .F. 
	Else
		cAviso := ""
		cErro  := ""
		oResponse1 := XmlParser(cResponse,"_",@cAviso,@cErro)

		If nOffSet = 0
			oCount := XmlChildEx(oResponse1:_RESOURCE, "_COUNT") 
			nCount := Val(oCount:TEXT)
			
			If nCount > 990
				cMsg := STR0013 + AllTrim(Str(nCount)) + STR0012 + CRLF + CRLF + STR0014//" fornecedores, "//"Foram encontrados "//"serão exibidos apenas os 990 primeiros no grid."
				cMsg += STR0015 //"Informe filtro mais específico para restringir o resultado."
				Help("",1,STR0023,,cMsg,4,1)
			Endif
			
		Endif

		//--> oEmbedded existe somente para a URL http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml 
		oEmbedded := XmlGetchild( oResponse1:_RESOURCE , XmlChildCount( oResponse1:_RESOURCE ))
	
		//--> se estrutura do oEmbedded está correta, extrai campos 
		If Valtype(oEmbedded) == "O"
			oResource :=  XmlChildEx( oEmbedded, "_RESOURCE" ) 

			// se tem apenas um fornecedor seta lFim para sair	
			lFim := ( nCount = 1 ) 

			//--> se estrutura do oResource está correta, extrai campos 
			If Valtype(oResource) == "O"

				nC++
				
				oCNPJ := XmlChildEx( oResource, "_CNPJ" )
				If ValType(oCNPJ) == "O" 
					Aadd(aCNPJ, AllTrim(Upper(oCNPJ:TEXT))) // "CNPJ"
				Else
					Aadd(aCNPJ, "" ) 
				Endif
				
				oCPF := XmlChildEx( oResource, "_CPF" )
				If ValType(oCPF) == "O" 
					Aadd(aCPF, AllTrim(Upper(oCPF:TEXT))) // "CPF"
				Else
					Aadd(aCPF, "" ) // "CPF"
				Endif
				
				oIdSICAF := XmlChildEx( oResource, "_ID" )
				If ValType(oIdSICAF) == "O"
					Aadd(aID, AllTrim(Upper(oIdSICAF:TEXT))) // ID
				Else
					Aadd(aID, "" ) // ID
				Endif
								
				oNome := XmlChildEx( oResource, "_NOME" )
				Aadd(aNome, Upper(oNome:TEXT))
		
				oAtivo := XmlChildEx( oResource, "_ATIVO" )
				Aadd(aAtivo, IIf(Alltrim(Upper(oAtivo:TEXT)) == "TRUE",.T.,.F.)) // "true"
				
				oEstado := XmlChildEx( oResource, "_UF" )
				Aadd(aUF, AllTrim(Upper(oEstado:TEXT))) // "SP"

				oLinks :=  XmlChildEx( oResource, "__LINKS" )
				oLink  := XmlGetChild( oLinks , XmlChildCount( oLinks ) )
				cMunicipio	  := CriaVar("A2_MUN")
				cNatureza     := Space(20)
				cRamoNegocio  := Space(20)
				cPorteEmpresa := Space(20)
				If ValType(oLink) ==  "A"
					For nLink := 1 To Len(oLink)
						If "MUNICIPIO" $ Upper(oLink[nLink]:_TITLE:TEXT)
							cMun := Upper(oLink[nLink]:_TITLE:TEXT)
							nPos := At( ":" , cMun )
							cMunicipio := Padr(Substr(cMun,nPos+1),nTamA2Mun)
						ElseIf "NATUREZA" $ Upper(oLink[nLink]:_TITLE:TEXT)
							cNat := Upper(oLink[nLink]:_TITLE:TEXT)
							nPos := At( ":" , cNat )
							cNatureza := Padr(Substr(cNat,nPos+1),30)
						ElseIf "RAMO" $ Upper(oLink[nLink]:_TITLE:TEXT)
							cRamo := Upper(oLink[nLink]:_TITLE:TEXT)
							nPos := At( ":" , cRamo )
							cRamoNegocio := Padr(Substr(cRamo,nPos+1),30)
						ElseIf "PORTE" $ Upper(oLink[nLink]:_TITLE:TEXT)
							cPorte := Upper(oLink[nLink]:_TITLE:TEXT)
							nPos := At( ":" , cPorte )
							cPorteEmpresa := Padr(Substr(cPorte,nPos+1),30)
						Endif
					Next
				Endif
	
				aAdd( aMunicipio, cMunicipio)
				aAdd( aNatureza, cNatureza)
				aAdd( aRamoNegocio, cRamoNegocio)
				aAdd( aPorteEmpresa, cPorteEmpresa)
	
				lRet := .T.
				
			ElseIf Valtype(oResource) == "A"
			
				For nX := 1 to Len(oResource)
				
					oCNPJ := XmlChildEx( oResource[nX], "_CNPJ" )
					If ValType(oCNPJ) == "O" 
						Aadd(aCNPJ, AllTrim(Upper(oCNPJ:TEXT))) // "CNPJ"
					Else
						Aadd(aCNPJ, "" ) 
					Endif
	
					oCPF := XmlChildEx( oResource[nX], "_CPF" )
					If ValType(oCPF) == "O" 
						Aadd(aCPF, AllTrim(Upper(oCPF:TEXT))) // "CPF"
					Else
						Aadd(aCPF, "" ) // "CPF"
					Endif

					oIdSICAF := XmlChildEx( oResource[nX], "_ID" )
					If ValType(oIdSICAF) == "O"
						Aadd(aID, AllTrim(Upper(oIdSICAF:TEXT))) // ID
					Else
						Aadd(aID, "" ) // ID
					Endif
								
					oNome := XmlChildEx( oResource[nX], "_NOME" )
					Aadd(aNome, Upper(oNome:TEXT))
			
					oAtivo := XmlChildEx( oResource[nX], "_ATIVO" )
					Aadd(aAtivo, IIf(Alltrim(Upper(oAtivo:TEXT)) == "TRUE",.T.,.F.)) // "true"
					
					oEstado := XmlChildEx( oResource[nX], "_UF" )
					Aadd(aUF, AllTrim(Upper(oEstado:TEXT))) // "SP"

					oLinks :=  XmlChildEx( oResource[nX], "__LINKS" )
					oLink  := XmlGetChild( oLinks , XmlChildCount( oLinks ) )
					cMunicipio	  := CriaVar("A2_MUN")
					cNatureza     := Space(20)
					cRamoNegocio  := Space(20)
					cPorteEmpresa := Space(20)
					If ValType(oLink) ==  "A"
						For nLink := 1 To Len(oLink)
							If "MUNICIPIO" $ Upper(oLink[nLink]:_TITLE:TEXT)
								cMun := Upper(oLink[nLink]:_TITLE:TEXT)
								nPos := At( ":" , cMun )
								cMunicipio := Padr(Substr(cMun,nPos+1),nTamA2Mun)
							ElseIf "NATUREZA" $ Upper(oLink[nLink]:_TITLE:TEXT)
								cNat := Upper(oLink[nLink]:_TITLE:TEXT)
								nPos := At( ":" , cNat )
								cNatureza := Padr(Substr(cNat,nPos+1),30)
							ElseIf "RAMO" $ Upper(oLink[nLink]:_TITLE:TEXT)
								cRamo := Upper(oLink[nLink]:_TITLE:TEXT)
								nPos := At( ":" , cRamo )
								cRamoNegocio := Padr(Substr(cRamo,nPos+1),30)
							ElseIf "PORTE" $ Upper(oLink[nLink]:_TITLE:TEXT)
								cPorte := Upper(oLink[nLink]:_TITLE:TEXT)
								nPos := At( ":" , cPorte )
								cPorteEmpresa := Padr(Substr(cPorte,nPos+1),30)
							Endif
						Next
					Endif
		
					aAdd( aMunicipio, cMunicipio)
					aAdd( aNatureza, cNatureza)
					aAdd( aRamoNegocio, cRamoNegocio)
					aAdd( aPorteEmpresa, cPorteEmpresa)
	
					nC++
					
				Next nX
				
				lRet := .T.
			Else
				cMsg := STR0016//"Erro no revebimento das informações pelo SICAF."
				Alert(cMsg)
			Endif
		Endif

		//-->> se retorno do httpget() tem mais que 990 fornecedores, continua requisitando a URL passando parâmetro offset de 500.
		//-->> se for necessário aumentar a quantidade de linhas do grid será necessário mudar o parâmetro de quantidade de linhas. 
		If ( nC < nCount ) .And. ( nC <= 990 )
			nOffSet += 500
			cUrl := cUrlOri + "&offset=" + AllTrim(Str(nOffSet))
		Else
			lFim := .T.
		Endif
	Endif
EndDo 

If lRet
	// desativa bloqueio de inclusão / exclusão de linha no grid para poder popular com os dados obtidos
	oModel:GetModel( 'STRU2DETAIL' ):SetNoInsertLine(.F.)
	oModel:GetModel( 'STRU2DETAIL' ):SetNoDeleteLine(.F.)

	oModStru2 := oModel:GetModel('STRU2DETAIL')
	//Limpa a grid para os novos resultados 
	nX := oModStru2:GetQtdLine()
	// se ja tem linhas no grid, limpa antes de incluir com o novo resultado obtido
	If !( Empty(oModStru2:GetValue('STRU2_CNPJ')) ) .Or. !( Empty(oModStru2:GetValue('STRU2_CPF')) )  
		For nI := nX To 1 STEP -1
			oModStru2:GoLine(nI)
			oModStru2:DeleteLine(.T.,.T.)
		Next nX
	EndIf
	
	For nX := 1 to nC
		nLinha++
		If nLinha > oModStru2:GetQtdLine()
			oModStru2:AddLine()
		Else
			oModStru2:UndeleteLine()
		EndIf
		
		// carrega os campos do grid com os dados obtidos no httpget()				
		oModStru2:LoadValue('STRU2_OK'		 , .F. )
		oModStru2:LoadValue('STRU2_TIPO'	 , " " )
		oModStru2:LoadValue('STRU2_CNPJ'	 ,aCnpj[nX])
		oModStru2:LoadValue('STRU2_CPF'		 ,aCPF[nX])
		oModStru2:LoadValue('STRU2_IDSICAF'  ,aID[nX])
		oModStru2:LoadValue('STRU2_NOME'	 ,SubStr(aNome[nX],1,nTamA2Nome) ) 
		oModStru2:LoadValue('STRU2_UF'		 ,aUF[nX])
		oModStru2:LoadValue('STRU2_MUNICIPIO',aMunicipio[nX])
		oModStru2:LoadValue('STRU2_RAMO'	 ,aRamoNegocio[nX])
		oModStru2:LoadValue('STRU2_NATUREZA' ,aNatureza[nX])
		oModStru2:LoadValue('STRU2_PORTE'	 ,aPorteEmpresa[nX])
		oModStru2:LoadValue('STRU2_ATIVO'	 ,IIF(aAtivo[nX],"1","2"))

	Next nX

	// ativa bloqueio de inclusão / exclusão de linha pelo usuário no grid 
	oModel:GetModel( 'STRU2DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'STRU2DETAIL' ):SetNoDeleteLine(.T.)

	oModStru2:GoLine(1)
	oView:Refresh()
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc}A180INCLUI
Funcao que inclui os fornecedores/participantes selecionados no grid 
@author Rogerio Melonio
@since 16/06/2015
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A180INCLUI( oModel )
Local lRet 		:= .F.
Local oModStru2 := oModel:GetModel('STRU2DETAIL')
Local nI		:= 0
Local aFornece  := {}
Local aPartic	:= {} 
Local cArea		:= ""
Local cCNPJ 	:= ""
Local cCPF  	:= ""
Local cCPF  	:= ""
Local cID   	:= ""
Local cUF		:= ""
Local lSA2CPF 	:= .F.
Local lCO6CPF 	:= .F.
Local cNome   	:= ""
Local cMsg 		:= ""

Local aSaveLines:= FWSaveRows()

For nI := 1 to oModStru2:GetQtdLine()
	oModStru2:GoLine(nI)
	// verifica se pelo menos uma linha esta marcada, se foi selecionado fornecedor/participante e se CNPJ/CPF está preenchido
	If !oModStru2:IsDeleted() .And. oModStru2:GetValue('STRU2_OK') .And. !Empty(oModStru2:GetValue('STRU2_TIPO')) .And. ;
		( !Empty(oModStru2:GetValue('STRU2_CNPJ')) .Or. !Empty(oModStru2:GetValue('STRU2_CPF')) ) 
		lRet := .T.
		Exit
	Endif
Next nI

If !lRet
	Help("",1,STR0023,,STR0017,4,1)//"Não existem linhas do grid selecionadas para realizar inclusão."
Else
	lRet := (MSGYESNO('',STR0018))//"Confirma inclusão dos fornecedores/participantes selecionados?"
Endif

aAreaSA2 := SA2->(GetArea())

If lRet
	dbSelectArea("SA2")
	dbSetOrder(3)
	dbSelectArea("CO6")
	dbSetOrder(2)
	lRet := .F. 
	For nI := 1 to oModStru2:GetQtdLine()
		oModStru2:GoLine(nI)
		// verifica se a linha esta marcada, se foi selecionado fornecedor/participante e se CNPJ/CPF está preenchido
		If !oModStru2:IsDeleted() .And. oModStru2:GetValue('STRU2_OK') .And. !Empty(oModStru2:GetValue('STRU2_TIPO')) .And. ;
			( !Empty(oModStru2:GetValue('STRU2_CNPJ')) .Or. !Empty(oModStru2:GetValue('STRU2_CPF')) )
			cArea := Iif( oModStru2:GetValue('STRU2_TIPO') == "1", "SA2", "CO6" )
			cCNPJ := AllTrim(oModStru2:GetValue('STRU2_CNPJ'))
			cCPF  := AllTrim(oModStru2:GetValue('STRU2_CPF'))
			cCPF  := StrTran(cCPF,"*",'') 
			cID   := AllTrim(oModStru2:GetValue('STRU2_IDSICAF'))
			cUF	  := oModStru2:GetValue('STRU2_UF')
			
			// se tipo de pessoa é Pessoa Juridica, busca CNPJ no SA2
			If !Empty(cCNPJ) 
				lAchou := (cArea)->( dbSeek(xFilial(cArea) + cCNPJ ) )
				// se não existe CNPJ, adiciona ao array de fornecedor/participante
				If !lAchou .And. oModStru2:GetValue('STRU2_TIPO') == "1"
					aAdd( aFornece, { cCNPJ , cID, cUF } )
					lRet := .T. 
				ElseIf !lAchou .And. oModStru2:GetValue('STRU2_TIPO') == "2"
					If !( SA2->( dbSeek(xFilial("SA2") + cCNPJ ) ) ) 			
						aAdd( aPartic, { cCNPJ , cID, cUF } )
						lRet := .T.
					Endif  
				Endif
			// se tipo de pessoa é Pessoa Fisica, busca CPF no SA2 e no CO6 	
			ElseIf !Empty(cCPF)

				lSA2CPF := a180CPF( "SA2", cCPF)
				lCO6CPF := a180CPF( "CO6", cCPF)
				cNome := AllTrim( oModStru2:GetValue('STRU2_NOME') )
				
				// se não existe CPF, adiciona ao array de fornecedor/participante
				If !lSA2CPF .And. oModStru2:GetValue('STRU2_TIPO') == "1"
					aAdd( aFornece, { cCPF , cID, cUF } )
					lRet := .T. 
				ElseIf !lCO6CPF .And. oModStru2:GetValue('STRU2_TIPO') == "2"
					If !lSA2CPF			
						aAdd( aPartic, { cCPF , cID, cUF } )
						lRet := .T.
					Endif
				// Se o CPF semelhante já existe, emite aviso e ignora linha do grid 
				ElseIf lSA2CPF 
					cMsg := STR0020 + cCPF + " ( " + cNome + STR0019//" ), não será feita importação do mesmo."//"Já existe fornecedor com CPF semelhante ao "
					Help("",1,STR0023,, cMsg ,4,1)
				ElseIf lCO6CPF
					cMsg := STR0022 + cCPF + " ( " + cNome + STR0021//" ), não será feita importação do mesmo."//"Já existe participante com CPF semelhante ao "
					Help("",1,STR0023,, cMsg ,4,1)//"Atenção!"
				Endif
			
			Endif
		Endif
	Next nI

	// se nenhuma linha do grid foi processada, emite aviso
	If !lRet
		Help("",1,STR0023,,STR0024,4,1)//"Os fornecedores/participantes selecionados não serão processados."
	Endif

	// chama rotina de inclusão de fornecedores
	If !Empty(aFornece)
		Alert(STR0027 + Alltrim(Str(Len(aFornece))) + STR0025)//" Fornecedores"
		a180Fornece(aFornece,"SA2")
	Endif
	
	// chama rotina de inclusão de participantes
	If !Empty(aPartic)
		Alert(STR0027 + AllTrim(Str(Len(aPartic))) + STR0026)//" Participantes"//"Serão incluídos "
		a180Fornece(aPartic,"CO6")
	Endif
Endif	

SA2->(RestArea(aAreaSA2))

FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a180Fornece
Rotina de Inclusao de Fornecedor
@author Rogerio Melonio
@since 18/06/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function a180Fornece(aCNPJs,cTipo)
Local cUrl1		:= "http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml"
Local cUrl2		:= ""
Local cGetPar	:= ""
Local nTimeOut	:= 120 //Segundos
Local aHeaderStr:= {}
Local cHeaderRet:= ""
Local cResponse	:= ""
Local cAviso    := ""
Local cErro     := ""
Local lRet 		:= .T. 
Local lSicaf 	:= .F. 
Local oSicaf 	:= Nil
Local lBasica    := .F.
Local lDetalhada := .F.
Local nW		 := 0
Local aDados	 := {}
Local cCPFCNPJ	 := ""
Local cIdPF		 := ""
Local cCodigo	 := ""
Local cLoja   	 := ""
Local cA2Tipo	 := ""
Local cRazao 	 := ""
Local cNome 	 := ""
Local cFantasia  := ""
Local cLogradouro:= ""
Local cBairro	 := ""
Local cMunicipio := ""
Local cUF  		 := ""
Local cCep       := ""
Local nPos		:= 0
Local nX		:= 0
Local cMun		:= ""

Local nTamA2Nome	:= TamSX3("A2_NOME")[1]
Local nTamA2Reduz	:= TamSX3("A2_NREDUZ")[1]
Local nTamA2Ender	:= TamSX3("A2_END")[1]
Local nTamA2Bairro	:= TamSX3("A2_BAIRRO")[1]
Local nTamA2Mun		:= TamSX3("A2_MUN")[1]
Local nTamO6Nome	:= TamSX3("CO6_NOME")[1]
Local nTamO6Ender	:= TamSX3("CO6_END")[1]
Local nTamO6Bairro	:= TamSX3("CO6_BAIRRO")[1]
Local nTamO6Mun		:= TamSX3("CO6_MUN")[1]
Local nTamO6cNPJ	:= TamSX3("CO6_CNPJ")[1]
			
//-->> variável cCadastro é obrigatória na A020WebbIc
Private cCadastro := STR0028 //"Fornecedores"

//--> processa o array aCNPJs para fazer as consultas completas do fornecedor e popular os campos do cadastro
For nW := 1 To Len(aCNPJs)
	lRet 		:= .T.
	
	cCPFCNPJ	:= AllTrim(aCNPJs[nW][01])
	cIdPF		:= AllTrim(aCNPJs[nW][02]) 

	// se é CNPJ monta URL de busca completa de pessoa juridica
	If Len(cCPFCNPJ) = 14
		cGetPar	:= "cnpj=" + cCPFCNPJ
		cUrl2 	:= "http://compras.dados.gov.br/fornecedores/doc/fornecedor_pj/" + cCPFCNPJ + ".xml"
	// se é CPF monta URL de busca básica de pessoa física e ignora busca completa 
	Else
		cGetPar	:= ""
		cUrl2 	:= "http://compras.dados.gov.br/fornecedores/doc/fornecedor_pf/" + cIdPF + ".xml"
	Endif           

	lBasica    	:= .F.
	lDetalhada 	:= .F.

	If cTipo == "SA2"
		cCodigo		:= CriaVar("A2_COD")   			
		cLoja   		:= CriaVar("A2_LOJA")	
		cA2Tipo		:= CriaVar("A2_TIPO")
		cRazao 		:= CriaVar("A2_NOME")
		cNome 			:= CriaVar("A2_NOME")
		cFantasia 		:= CriaVar("A2_NREDUZ")	
		cLogradouro	:= CriaVar("A2_END")
		cBairro		:= CriaVar("A2_BAIRRO")
		cMunicipio		:= CriaVar("A2_MUN")	
		cUF  			:= CriaVar("A2_EST")
		cCep      		:= CriaVar("A2_CEP")	
	Else
		cCodigo		:= CriaVar("CO6_CODIGO")   			
		cLoja   		:= CriaVar("CO6_LOJFOR")	
		cA2Tipo		:= CriaVar("CO6_TIPO")
		cRazao 		:= CriaVar("CO6_NOME")
		cNome 			:= CriaVar("CO6_NOME")
		cLogradouro	:= CriaVar("CO6_END")
		cBairro		:= CriaVar("CO6_BAIRRO")
		cMunicipio		:= CriaVar("CO6_MUN")	
		cUF  			:= CriaVar("CO6_CEP")
	Endif

	If lRet .And. !Empty(cGetPar)
	
		//--> realiza consulta basica
		cResponse := HTTPGet( cUrl1, cGetPar, nTimeOut, aHeaderStr, @cHeaderRet )
		nErro1 := HTTPGetStatus(cErro)
		
		// se ocorreu erro no get do site do SICAF exibe erro
		If nErro1 <> 200
			cMsg := STR0029 + CRLF + CRLF + cErro //"Problemas consultando dados básicos do fornecedor"
			Help("",1,STR0023,, cMsg ,4,1)
			lRet := .F. 
		Else
			// converte string de retorno no objeto oResponse1
			oResponse1 := XmlParser(cResponse,"_",@cAviso,@cErro)
			
			//--> oEmbedded existe somente para a URL http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml 
			oEmbedded := XmlGetchild( oResponse1:_RESOURCE , XmlChildCount( oResponse1:_RESOURCE ))
	
			//--> se estrutura do oEmbedded está correta, extrai campos 
			If Valtype(oEmbedded) == "O"
				oResource :=  XmlChildEx ( oEmbedded, "_RESOURCE" ) 
	
				//--> se estrutura do oResource está correta, extrai campos 
				If Valtype(oResource) == "O"
					oNome := XmlChildEx ( oResource, "_NOME" )
					cRazao := Upper(oNome:TEXT)
			
					oAtivo := XmlChildEx ( oResource, "_ATIVO" )
					cAtivo := Alltrim(Upper(oAtivo:TEXT)) // "true"
					lAtivo := cAtivo == "TRUE"
					
					oEstado := XmlChildEx ( oResource, "_UF" )
					cUF := AllTrim(Upper(oEstado:TEXT)) // "SP"

					lBasica := .T.
				Else
					cMsg := STR0030//"Retorno do httpget() inconsistente não permite obter dados dos fornecedores."
					Help("",1,STR0023,, cMsg ,4,1)
				Endif
			Endif 
		Endif
	Endif
	
	//--> realiza consulta detalhada
	cErro     := ""
	cResponse := HTTPGet( cUrl2 , "" , nTimeOut, aHeaderStr, @cHeaderRet )
	nErro2 := HTTPGetStatus(cErro)
	
	If nErro2 <> 200
		cMsg := STR0031 + CRLF + CRLF + cErro//"Problemas consultando dados detalhados do fornecedor"
		Help("",1,STR0023,, cMsg ,4,1)
		lRet := .F.
	Else

		// converte string de retorno no objeto oResponse2
		oResponse2 := XmlParser(cResponse,"_",@cAviso,@cErro)
	
		//--> se estrutura do oResponse2 está correta, extrai campos 
		If Valtype(oResponse2) == "O"
			oResource :=  XmlChildEx ( oResponse2, "_RESOURCE" ) 
		
			oRazao := XmlChildEx ( oResource, "_RAZAO_SOCIAL" )
			If ValType(oRazao) == "O"
				cRazao := AllTrim(Upper(oRazao:TEXT)) 
			Endif

			oNome := XmlChildEx ( oResource, "_NOME" )
			If ValType(oNome) == "O"
				cNome := AllTrim(Upper(oNome:TEXT)) 
			Endif
		
			oFantasia := XmlChildEx ( oResource, "_NOME_FANTASIA" )
			If ValType(oFantasia) == "O"
				cFantasia := Upper(oFantasia:TEXT)
			Endif
			
			oLogradouro := XmlChildEx ( oResource, "_LOGRADOURO" )
			If ValType(oLogradouro) == "O"
				cLogradouro := Upper(oLogradouro:TEXT)
			Endif
		
			oBairro := XmlChildEx ( oResource, "_BAIRRO" )
			If ValType(oBairro) == "O"
				cBairro := Upper(oBairro:TEXT)
			Endif
		
			oCEP := XmlChildEx ( oResource, "_CEP" )
			If ValType(oCEP) == "O"
				cCEP := StrTran(oCEP:TEXT,"-","")
			Endif
			
			oAtivo := XmlChildEx ( oResource, "_ATIVO" )
			cAtivo := Alltrim(Upper(oAtivo:TEXT)) // "true"
			lAtivo := cAtivo == "TRUE"

			If Empty(cMunicipio)
				oLinks :=  XmlChildEx ( oResource, "__LINKS" )
				oLink := XmlGetChild( oLinks , XmlChildCount( oLinks ) )
				If ValType(oLink) ==  "A"
					For nX := 1 To Len(oLink)
						If "MUNICIPIO" $ Upper(oLink[nX]:_TITLE:TEXT)
							cMun := Upper(oLink[nX]:_TITLE:TEXT)
							nPos := At( ":" , cMun )
							cMunicipio := AllTrim(Substr(cMun,nPos+1))
							cMunicipio := Padr(cMunicipio,nTamA2Mun)
							Exit
						Endif
					Next
				Endif
			Endif 

			lDetalhada := .T.
		Else
			Alert(STR0032)//"Fornecedor não encontrado na consulta detalhada"
		Endif
	Endif 

	// Quando é pessoa fisica, é retornado o nome e não a razão social
	cRazao := Iif(Empty(cNome),cRazao, cNome )

	// caso o nome fantasia venha vazio, assume a razao social
	cFantasia := Iif( Empty(cFantasia), Left(cRazao,nTamA2Reduz), cFantasia )
	
	cUF := Iif( Empty(cUF), aCNPJs[nW][03], cUF ) 
	
	lSicaf := ( lBasica .Or. lDetalhada ) 

	If lRet .AND. lSicaf
		If cTipo == "SA2"
			//--Inclui como fornecedor
			// Em caso de inclusão de fornecedor pessoa fisica a função A020CGC verifica se o campo A2_CGC tem 11 caracteres.
			// Para a gravação ocorrer sem problema completamos a variável cCPFCNPJ com zeros. 
			cCPFCNPJ := Iif( Len(cCPFCNPJ)<11, "000" + cCPFCNPJ + "00", cCPFCNPJ ) 
			cA2Tipo := Iif( Len(cCPFCNPJ)<14,"F",Iif(Len(cCPFCNPJ)=14,"J","X") )
			
			aDados := {	{"A2_COD",		cCodigo}	, {"A2_LOJA",cLoja}		,;
						{"A2_TIPO",		cA2Tipo}	, {"A2_CGC",cCPFCNPJ}	,;
						{"A2_NOME",		Padr(cRazao,nTamA2Nome)}			,;
						{"A2_NREDUZ",	Padr(cFantasia,nTamA2Reduz)}		,;
						{"A2_END",		Padr(cLogradouro,nTamA2Ender)}		,;
						{"A2_BAIRRO",	Padr(cBairro,nTamA2Bairro)}			,;
						{"A2_MUN",		cMunicipio}	, {"A2_EST",cUF}, {"A2_CEP",cCep} }
			lRet := GCPCadForn(aDados)

			If !lRet
				Help("",1,STR0023,,STR0033 + AllTrim(cRazao),4,1)//"Problema com inclusão do fornecedor "
				RollBackSX8()
			Else
				ConfirmSX8()
			Endif

		ElseIf cTipo == "CO6"
			//--Inclui como participante
			cCodigo := GetSXENum('CO6','CO6_CODIGO')
			cLoja 	 := '01'
			aDados := { } 
			Aadd(aDados, cCodigo )
			Aadd(aDados, cLoja   )	
			Aadd(aDados, 'F'     )
			Aadd(aDados, Padr( cRazao	  , nTamO6Nome   ) )
			Aadd(aDados, Padr( cLogradouro, nTamO6Ender  ) )
			Aadd(aDados, Padr( cBairro	  , nTamO6Bairro ) )
			Aadd(aDados, Padr( cMunicipio , nTamO6Mun    ) )
			Aadd(aDados, cUF  )
			Aadd(aDados, cCep )

			// em caso de inclusão de participante pessoa fisica o POSVALID verifica se o campo CO6_CNPJ é válido,
			// para a gravação ocorrer sem problema é passado o campo vazio para gravação posterior
			If Len(cCPFCNPJ)<11
				Aadd(aDados, Space(nTamO6cNPJ) )
			Else
				Aadd(aDados, Padr(cCPFCNPJ,nTamO6cNPJ) )
			Endif
			
			// chama execview para inclusão de participante
			lRet := a180IncCO6(aDados)
			If lRet
				ConfirmSX8()
				// em caso de inclusão de participante pessoa fisica o POSVALID do model 'GCPA003' verifica se o campo CO6_CNPJ é válido,
				// para a gravação ocorrer sem problema é passado o campo vazio, e depois é feita gravação posterior ao commit.
				If Len(cCPFCNPJ)<11
					RecLock("CO6",.F.)
					CO6->CO6_CNPJ := "000" + cCPFCNPJ + "00"
					MsUnlock()
				Endif	
			Else
				RollBackSX8()
				Help("",1,STR0023,,STR0034 + AllTrim(cRazao),4,1)//"Problema com inclusão do participante "
			EndIf		

		Endif

	Endif

Next nW

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a180IncCO6(aDados)
Função que inclui um participante
@author Rogerio Melonio
@since 18/06/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a180IncCO6(aDados)
Local lRet 			:= .F.
// carrega o model do cadastro de participantes
Local oModel  		:= FWLoadModel('GCPA003')
Local oCO6Master  	:= oModel:GetModel('CO6MASTER')

oModel:SetOperation(3)                                 
oModel:Activate()

// preenche os campos com cados da consulta 
oCO6Master:SetValue('CO6_CODIGO',aDados[01])
oCO6Master:SetValue('CO6_LOJFOR',aDados[02])
oCO6Master:SetValue('CO6_NOME'	,aDados[04])
oCO6Master:SetValue('CO6_END'	,aDados[05])
oCO6Master:SetValue('CO6_BAIRRO',aDados[06])
oCO6Master:SetValue('CO6_MUN'	,aDados[07])
oCO6Master:SetValue('CO6_UF'	,aDados[08])
oCO6Master:SetValue('CO6_CEP'	,aDados[09])
oCO6Master:SetValue('CO6_CNPJ'	,aDados[10])

If oModel:VldData()
	lRet := .T.  
	oModel:CommitData()	
EndIf	
oModel:DeActivate()		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a180CPF
Função que verifica se CPF existe nas tabelas SA2 e CO6
@author Rogerio Melonio
@since 22/06/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a180CPF(cArea,cCPF)
Local lRet 			:= .F.
local cAliasSql	:= GetNextAlias()
Local cOrdem := '' 
Local cWhere := ''

If cArea == "SA2"
	cOrdem		:= "% SA2.A2_CGC %" 
	cWhere := "% AND SA2.A2_CGC LIKE '%" + cCPF + "%' %"

	BeginSQL Alias cAliasSql
			SELECT 
				SA2.R_E_C_N_O_  AS RecSA2
			FROM 
				%table:SA2% SA2
			WHERE 
				SA2.A2_FILIAL = %xfilial:SA2%
				%exp:cWhere%
				AND SA2.%NotDel%
			ORDER BY %exp:cOrdem%					
	EndSql
Else
	cOrdem		:= "% CO6.CO6_CNPJ %" 
	cWhere := "% AND CO6.CO6_CNPJ LIKE '%" + cCPF + "%' %"

	BeginSQL Alias cAliasSql
		SELECT 
			CO6.R_E_C_N_O_  AS RecCO6
		FROM 
			%table:CO6% CO6
		WHERE 
			CO6.CO6_FILIAL = %xfilial:CO6%
			%exp:cWhere%
			AND CO6.%NotDel%
	EndSql
Endif

While !(cAliasSql)->(eof())
	If cArea == "SA2" .And. (cAliasSql)->RecSA2 <> 0
		lRet := .T.
		Exit
	ElseIf cArea == "CO6" .And. (cAliasSql)->RecCO6 <> 0
		lRet := .T.
		Exit
	EndIf
	(cAliasSql)->(DBSkip())	
End

(cAliasSql)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a180SicUF
Função que valida o campo UFadmin
@author Rogerio Melonio
@since 26/06/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function a180SicUF(oM,cField,cValue,cOldValue)
Local lRet := .F.
Local cUF    := cValue

If Empty(cUF)
	lRet := .T.
Else
	lRet := ExistCpo("SX5","12"+cUF)
Endif

Return lRet
