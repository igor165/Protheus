#INCLUDE 'MATC710.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATC710  ºAutor  ³ Andre Anjos		 º Data ³  03/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Interface de consulta das necessidades por filial.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle de Producao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATC710()
Private Inclui := .F.
dbSelectArea("SHF")

FWExecView(,"MATC710")

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ModelDef ºAutor  ³ Andre Anjos		 º Data ³  03/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao da estrutura do modelo de dados.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC710                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSB1 := FWFormStruct(1,'SB1')
Local oStruFIL := FWFormModelStruct():New()
Local oStruMRP := FWFormStruct(1,'SHF')
Local oModel

CamposFIL(.T.,@oStruFIL) //-- Carrega campos da get de filiais

oModel := MPFormModel():New('COMP023M')

oModel:AddFields('SB1MASTER',/*cOwner*/,oStruSB1) //-- Cadastro do Produto
oModel:AddGrid('FILDETAIL','SB1MASTER', oStruFIL,,,,,{|| LoadFIL()}) //-- Filiais
oModel:AddGrid('MRPDETAIL','FILDETAIL', oStruMRP,,,,,) //-- Necessidades da Filial

// Faz relaciomaneto entre os compomentes FIL e MRP
oModel:SetRelation('FILDETAIL',{{'FILIAL','B1_FILIAL'},{'PRODUTO','B1_COD'}},SB1->(IndexKey(1)))
oModel:SetRelation('MRPDETAIL',{{'HF_FILNEC','FILIAL'},{'HF_PRODUTO','PRODUTO'}},SHF->(IndexKey(1)))

// Adiciona descricoes para as partes do modelo
oModel:SetDescription(STR0001) //"Necessidades por Filial"
oModel:GetModel('SB1MASTER'):SetDescription(STR0002) //"Cadastro do Produto"  
oModel:GetModel('FILDETAIL'):SetDescription(STR0003) //"Filiais"
oModel:GetModel('MRPDETAIL'):SetDescription(STR0004) //"Necessidades da Filial"

oModel:SetPrimaryKey({})

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewDef  ºAutor  ³ Andre Anjos		 º Data ³  03/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao da estrutura da view.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC710                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
Local oStruSB1 := FWFormStruct(2,'SB1')
Local oStruFIL := FWFormViewStruct():New()
Local oStruMRP := FWFormStruct(2,'SHF')
Local oModel   := FWLoadModel('MATC710')
Local oView	 := FWFormView():New()

CamposFIL(.F.,@oStruFIL) //-- Carrega campos da get de filiais

// Remove campos que nao devem aparecer na estrutura
oStruFIL:RemoveField('PRODUTO')
oStruMRP:RemoveField('HF_FILNEC')
oStruMRP:RemoveField('HF_PRODUTO')

oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros

//-- Divide a tela nas partes a utilizar
oView:CreateHorizontalBox('BASE',100)
oView:CreateVerticalBox('ESQUERDA',30,'BASE')
oView:CreateVerticalBox('DIREITA',70,'BASE')
oView:CreateHorizontalBox('CIMA' ,40,'DIREITA')
oView:CreateHorizontalBox('MEIO' ,30,'DIREITA')
oView:CreateHorizontalBox('BAIXO',30,'DIREITA')

MsgRun(STR0022,STR0010,{|| CursorWait(),oView:AddOtherObject('TREE',{|oPanel| Produtos(oPanel,@oModel,@oView)}),CursorArrow()})  //-- Cria o tree de navegacao entre os produtos

//Adiciona na view um controle do tipo FormFields (antiga enchoice)
oView:AddField('VIEW_SB1',oStruSB1,'SB1MASTER')

//Adiciona na view um controle do tipo FormGrid (antiga newgetdados)
oView:AddGrid('VIEW_FIL',oStruFIL,'FILDETAIL')
oView:AddGrid('VIEW_MRP',oStruMRP,'MRPDETAIL')

//-- Relaciona as views com os boxs em que serao exibidas
oView:SetOwnerView('VIEW_SB1','CIMA' )
oView:SetOwnerView('VIEW_FIL','MEIO' )
oView:SetOwnerView('VIEW_MRP','BAIXO')
oView:SetOwnerView('TREE','ESQUERDA')

//Liga a identificacao das estruturas
oView:EnableTitleView('TREE',STR0005) //"Estruturas / Produtos"
oView:EnableTitleView('VIEW_SB1',STR0002) //"Cadastro do Produto"
oView:EnableTitleView('VIEW_FIL',STR0003) //"Filiais"
oView:EnableTitleView('VIEW_MRP',STR0004) //"Necessidades da Filial"

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ Produtos º Autor ³ Andre Anjos 		 º Data ³  29/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que monta o tree de navegacao entre os produtos da  º±±
±±º          ³ consulta.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oPanel: painel onde o tree devera ser montado.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ViewDef                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Produtos(oPanel,oModel,oView)
Local aEstrutura := {}
Local oTree 	 := NIL
Local oMenu 	 := NIL

SG1->(dbSetOrder(1))

MENU oMenu POPUP
MENUITEM STR0025 Action MC710Seek(@oTree,@oModel,@oView) //"Localizar produto"
MENUITEM Replicate("-",40) Action NIL
MENUITEM STR0006 Action MC710NxNiv(@oTree,.F.) //"Expandir este nível"
MENUITEM STR0007 Action MC710NxNiv(@oTree,.T.) //"Expandir deste nível em diante" 
MENUITEM Replicate("-",40) Action NIL
MENUITEM STR0008 Action If(Pergunte("MTC050",.T.),MsgRun(STR0009,STR0010,{|| MC050Con()}),NIL) //"Consulta ao produto" 
MENUITEM STR0011 Action MaViewSB2(SB1->B1_COD,oModel:GetValue("FILDETAIL","FILIAL")) //"Detalhes do saldo na filial"
ENDMENU
oTree := DBTree():New(0,0,0,0,oPanel,{|x| AtuModel(@x,@oModel,@oView),oTree:SetFocus()},{|a,b,c| oMenu:Activate(b,c)},.T.) //-- Tree com as estruturas
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:SetScroll(1,.T.)
oTree:SetScroll(2,.T.)
oTree:bInit := {|| AtuModel(@oTree,@oModel,@oView)}
oTree:bLDblClick := {|| MC710NxNiv(@oTree,.F.)}

BeginSQL Alias "SG1PAI"
	SELECT DISTINCT SG1.G1_COD, SB1.B1_DESC, SB1.B1_REVATU, SB1.B1_OPC
	FROM %Table:SG1% SG1
	JOIN %Table:SB1% SB1 ON SB1.%NotDel% AND
		SB1.B1_FILIAL = %xFilial:SB1% AND
		SB1.B1_COD = SG1.G1_COD
	WHERE SG1.%NotDel% AND
		SG1.G1_FILIAL = %xFilial:SG1% AND
		SG1.G1_NIV = '01'
	ORDER BY SG1.G1_COD
EndSQL

While !SG1PAI->(EOF())
	oTree:AddTreeItem(PadR(AllTrim(SG1PAI->G1_COD) +" - " +SG1PAI->B1_DESC,100),"PCPIMG16",,Space(TamSX3("B1_COD")[1]*2)+SG1PAI->G1_COD+CriaVar("G1_TRT",.F.))
	oTree:EndTree() //-- Encerra tree para voltar ao nivel base
		
	SG1PAI->(dbSkip())
End
SG1PAI->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CamposFIL ºAutor  ³ Andre Anjos        º Data ³  29/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta estrutura de campos para modelo e view das filiais.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lModel: identifica se e criacao do model ou view.		  º±±
±±º			 ³ oStru: objeto da estrutura de dados.						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ModelDef e ViewDef                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CamposFIL(lModel,oStru)

If lModel //-- Instancia de modelo
	oStru:AddTable("FILTMP",{"FILIAL"},"Filiais") //--  Tabela
	oStru:AddIndex(1,"1","FILIAL","Filial","","",.T.) //-- Indice
	
	//-- Campo Produto
	oStru:AddField(	STR0012      		,;	// [01]  C   Titulo do campo  - Produto
					STR0013				,;	// [02]  C   ToolTip do campo - Código do Produto
					"PRODUTO"			,;	// [03]  C   Id do Field
					"C"					,;	// [04]  C   Tipo do campo
					TamSX3("B1_COD")[1]	,;	// [05]  N   Tamanho do campo
					0					,;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual

	//-- Campo Filial
	oStru:AddField(	STR0014         	,;	// [01]  C   Titulo do campo  - Filial
					STR0015 			,;	// [02]  C   ToolTip do campo - Codigo da Filial
					"FILIAL"				,;	// [03]  C   Id do Field
					"C"					,;	// [04]  C   Tipo do campo
					FwSizeFilial()			,;	// [05]  N   Tamanho do campo
					0					,;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual

	//-- Campo nome
	oStru:AddField(	STR0016         	,;	// [01]  C   Titulo do campo  - Nome
					STR0017				,;	// [02]  C   ToolTip do campo - Nome da Filial
					"NOME"				,;	// [03]  C   Id do Field
					"C"					,;	// [04]  C   Tipo do campo
					15					,;	// [05]  N   Tamanho do campo
					0					,;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual
					
	//-- Campo Saldo Atual
	oStru:AddField(	STR0018         	,;	// [01]  C   Titulo do campo - Sld. Atual
					STR0019				,;	// [02]  C   ToolTip do campo   - Saldo atual na filial
					"QATU"				,;	// [03]  C   Id do Field
					"N"					,;	// [04]  C   Tipo do campo
					TamSX3("B2_QATU")[1],;	// [05]  N   Tamanho do campo
					TamSX3("B2_QATU")[2],;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual

	//-- Campo Saldo Atual
	oStru:AddField(	STR0020         	,;	// [01]  C   Titulo do campo  - Sld. Disp.
					STR0021				,;	// [02]  C   ToolTip do campo - Saldo disponível
					"QDISP"				,;	// [03]  C   Id do Field
					"N"					,;	// [04]  C   Tipo do campo
					TamSX3("B2_QATU")[1],;	// [05]  N   Tamanho do campo
					TamSX3("B2_QATU")[2],;	// [06]  N   Decimal do campo
					NIL					,;	// [07]  B   Code-block de validação do campo
					NIL					,;	// [08]  B   Code-block de validação When do campo
					NIL					,;  // [09]  A   Lista de valores permitido do campo
					.F.					,;  // [10]  L   Indica se o campo tem preenchimento obrigatório
					NIL					,;	// [11]  B   Code-block de inicializacao do campo
					NIL					,;	// [12]  L   Indica se trata-se de um campo chave
					NIL					,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.					)   // [14]  L   Indica se o campo é virtual
Else	//-- Instancia de view
	//-- Campo Produto
	oStru:AddField(	"PRODUTO"			,;	// [01]  C   Nome do Campo
					"01"					,;	// [02]  C   Ordem
					STR0012 			,;	// [03]  C   Titulo do campo
					STR0013				,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"C"					,;  // [06]  C   Tipo do campo
					""					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					'SB1'					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo
					
	//-- Campo Filial
	oStru:AddField(	"FILIAL"				,;	// [01]  C   Nome do Campo
					"02"					,;	// [02]  C   Ordem
					STR0014 			,;	// [03]  C   Titulo do campo
					STR0015				,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"C"					,;  // [06]  C   Tipo do campo
					""					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					'SM0_01'				,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

	//-- Campo Nome
	oStru:AddField(	"NOME"				,;	// [01]  C   Nome do Campo
					"03"					,;	// [02]  C   Ordem
					STR0016 			,;	// [03]  C   Titulo do campo
					STR0017				,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"C"					,;  // [06]  C   Tipo do campo
					""					,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

	//-- Campo Saldo Atual
	oStru:AddField(	"QATU"		 		,;	// [01]  C   Nome do Campo
					"04"					,;	// [02]  C   Ordem
					STR0018 			,;	// [03]  C   Titulo do campo
					STR0019				,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"N"					,;  // [06]  C   Tipo do campo
					PesqPict("SB2","B2_QATU"),;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo

	//-- Campo Saldo Disponivel
	oStru:AddField(	"QDISP"		 		,;	// [01]  C   Nome do Campo
					"05"					,;	// [02]  C   Ordem
					STR0020 			,;	// [03]  C   Titulo do campo
					STR0021 		   ,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"N"					,;  // [06]  C   Tipo do campo
					PesqPict("SB2","B2_QATU"),;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo é alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.T.					,;	// [16]  L   Indica se o campo é virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha após o campo
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuModel ºAutor  ³ Andre Anjos		 º Data ³  02/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Caso altere o produto posicionado no tree, atualiza o modelº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oTree: objeto tree com os produtos.						  º±±
±±º			 ³ oModel: objeto com o modelo de dados.					  º±±
±±º			 ³ oView: objeto com a view do modelo de dados.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Produtos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuModel(oTree,oModel,oView)
Local cProduto := Substr(oTree:GetCargo(),(TamSX3("G1_COMP")[1] * 2) + 1,TamSX3("G1_COMP")[1])

If cProduto # oModel:GetValue("SB1MASTER","B1_COD")
	SB1->(dbSeek(xFilial("SB1")+cProduto))
	oModel:DeActivate()
	oModel:Activate()
	oView:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LoadFIL	ºAutor  ³ Andre Anjos		 º Data ³  02/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao responsavel pela carga dos dados na get das filiais.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ModelDef                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadFIL()
Local aArea    := SM0->(GetArea())
Local aRet	   := {}
Local cFilBkp  := cFilAnt
Local nQAtuTot := 0
Local nDispTot := 0

SM0->(dbSeek(cEmpAnt))
While !SM0->(EOF()) .And. SM0->M0_CODIGO == cEmpAnt
	cFilAnt  := SM0->M0_CODFIL
	nQAtuTot := 0
	nDispTot := 0
	
	SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))
	While !SB2->(EOF()) .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2")+SB1->B1_COD
		nQAtuTot += SB2->B2_QATU
		nDispTot += SaldoSB2()		
		SB2->(dbSkip())
	End
	
	aAdd(aRet,{0,{SB1->B1_COD,cFilAnt,SM0->M0_FILIAL,nQAtuTot,nDispTot}})
	
	SM0->(dbSkip())
End

cFilAnt := cFilBkp
SM0->(RestArea(aArea))
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MC710NxNivºAutor  ³ Andre Anjos        º Data ³  03/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao responsavel pela explosao do nivel da estrutura que º±±
±±º          ³ esta posicionado no tree.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Produtos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MC710NxNiv(oTree,lRecurs)
Local cCargo  := oTree:GetCargo()
Local nRecno  := 0
Local cPai    := Substr(cCargo,(TamSX3("B1_COD")[1] * 2) +1,TamSX3("B1_COD")[1])
Local cPaiPai := Substr(cCargo,TamSX3("B1_COD")[1] + 1,TamSX3("B1_COD")[1])

SB1->(dbSeek(xFilial("SB1")+cPai))

SG1->(dbSetOrder(1))
SG1->(dbSeek(xFilial("SG1")+cPai))
While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cPai
	SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
	nRecno := SG1->(Recno())
	cImagem := If(SG1->(dbSeek(xFilial("SG1")+SG1->G1_COMP)),"PCPIMG16","COMIMG16")
	SG1->(dbGoTo(nRecno))
	If !oTree:TreeSeek(SG1->(cPaiPai+G1_COD+G1_COMP+G1_TRT))
		oTree:AddItem(PadR(AllTrim(SB1->B1_COD) +" - " +SB1->B1_DESC,100),SG1->(cPaiPai+G1_COD+G1_COMP+G1_TRT),cImagem,cImagem,,,2)
	EndIf
	If lRecurs
		oTree:TreeSeek(SG1->(cPaiPai+G1_COD+G1_COMP+G1_TRT))
		nRecno := SG1->(Recno())
		MC710NxNiv(@oTree,.T.)
		SG1->(dbGoTo(nRecno))
		oTree:TreeSeek(cCargo)
	EndIf
	
	SG1->(dbSkip())
End
oTree:TreeSeek(cCargo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MC710Seek ºAutor  ³ Andre Anjos		 º Data ³  27/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Localiza produto na arvore                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC710                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MC710Seek(oTree,oModel,oView)
Local aAreaSG1	:= SG1->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aProdDesc := {}
Local aAddTree  := {}
Local lPesq	  	:= .F.
Local lDescExat	:= .T.
Local lPriPesq	:= .T.
Local oDlg    	:= NIL
Local oGetPrd 	:= NIL
Local c710Prod	:= CriaVar("B1_COD",.F.)
Local c710Desc  := CriaVar("B1_DESC",.F.)
Local cPaiPai	:= ""
Local cPai		:= ""
Local cTrt		:= ""
Local cProdPesq := ""
Local cImagem	:= ""
Local cAlias	:= "SB1"
Local cCargoBkp	:= oTree:GetCargo()
Local nX		:= 0

oDlg := MSDialog():New(0,0,150,390,STR0025,,,,,,,,oMainWnd,.T.) //-- Localizar produto
TSay():Create(oDlg,{|| RetTitle("B1_COD")},05,05,,,,,,.T.,,,30,10)
oGetPrd := TGet():Create(oDlg,{|u| If(Pcount()>0,c710Prod:=u,c710Prod)},03,35,160,10,,{|x| Empty(x:cText) .Or. ExistCpo("SB1",x:cText)},,,,,,.T.,,,,,,,,,,"c710Prod")
oGetPrd:cF3 := "SB1"
TSay():Create(oDlg,{|| RetTitle("B1_DESC")},25,05,,,,,,.T.,,,30,10)
TGet():Create(oDlg,{|u| If(Pcount()>0,c710Desc:=u,c710Desc)},23,35,160,10,,,,,,,,.T.,,,,,,,,,,"c710Desc")
TCheckBox():Create(oDlg,{|u| If(Pcount()>0,lDescExat:=u,lDescExat)},40,35,STR0026,100,50,,,,,,,,.T.,STR0027) //-- Pesquisa exata / Indica se a busca pela descrição será exata ou parcial (contido).

TButton():Create(oDlg,55,120,STR0028,{|| lPesq := .T.,oDlg:End()},70,10,,,,.T.) //-- Localizar
oDlg:Activate(,,,.T.)

If lPesq
	//-- Pesquisa pela descricao
	If Empty(c710Prod) .And. !Empty(c710Desc)
		If lDescExat
			SB1->(dbSetOrder(3))
			SB1->(dbSeek(xFilial("SB1")+c710Desc))
		Else
			cAlias := "SB1TMP"
			cQuery := "SELECT B1_FILIAL, B1_COD	FROM " +RetSQLName("SB1") +" WHERE "
			cQuery += "D_E_L_E_T_ <> '*' AND B1_FILIAL = '" +xFilial("SB1") +"' AND "
			cQuery += "B1_DESC LIKE '%" +AllTrim(c710Desc) +"%'"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)			
		EndIf

		While !(cAlias)->(EOF()) .And. If(lDescExat,(cAlias)->(B1_FILIAL+B1_DESC) == xFilial("SB1")+c710Desc,.T.)
			aAdd(aProdDesc,(cAlias)->B1_COD)
			(cAlias)->(dbSkip())
		End
		
		If !lDescExat
			(cAlias)->(dbCloseArea())
		EndIf		
	ElseIf !Empty(c710Prod)
		aAdd(aProdDesc,c710Prod)
	EndIf
	
	lPesq := .F.

	SG1->(dbSetOrder(2))
	
	//-- Pesquisa pelo codigo
	For nX := 1 To Len(aProdDesc)
		lPriPesq  := .T.
		cPaiPai   := Replicate("Z",TamSX3("B1_COD")[1])
		cPai 	  := Replicate("Z",TamSX3("B1_COD")[1])
		cProdPesq := aProdDesc[nX]
		
		While !lPesq .And. !Empty(cPaiPai+cPai)
			If SG1->(dbSeek(xFilial("SG1")+cProdPesq)) //-- Componente em uma estrutura
				cPai := SG1->G1_COD
				cTrt := SG1->G1_TRT
				If SG1->(dbSeek(xFilial("SG1")+cPai))	//-- Se for PI
					cPaiPai := SG1->G1_COD
				Else
					cPaiPai := CriaVar("B1_COD",.F.)
				EndIf
			Else	//-- Somente PA
				cPai 	:= CriaVar("B1_COD",.F.)
				cTrt 	:= CriaVar("G1_TRT",.F.)
				cPaiPai := CriaVar("B1_COD",.F.)
			EndIf

			//-- Pesquisa no tree
			lPesq := oTree:TreeSeek(cPaiPai+cPai+cProdPesq+cTrt)

			If lPesq .And. !Empty(c710Desc) .And. Empty(aAddTree) //-- Se preencheu descricao, valida descricao
				If lDescExat
					lPesq := AllTrim(Substr(oTree:GetPrompt(),At("-",oTree:GetPrompt())+2)) == AllTrim(c710Desc)
				Else
					lPesq := AllTrim(c710Desc) $ AllTrim(Substr(oTree:GetPrompt(),At("-",oTree:GetPrompt())+2))
				EndIf
			ElseIf !lPesq .And. !Empty(cPaiPai+cPai)
				aAdd(aAddTree,cPaiPai+cPai+cProdPesq+cTrt)
				cProdPesq := cPai
			EndIf
		End			
	
		If lPesq
			Exit		
		EndIf
	Next nX
	
	//-- Adiciona caminho da pesquisa
	If lPesq .And. !Empty(aAddTree)
		SB1->(dbSetOrder(1))
		For nX := Len(aAddTree) To 1 Step -1
			SB1->(dbSeek(xFilial("SB1")+Substr(aAddTree[nX],(TamSX3("B1_COD")[1]*2)+1,TamSX3("B1_COD")[1])))
			cImagem := If(nX > 1,"PCPIMG16","COMIMG16")
			oTree:AddItem(PadR(AllTrim(SB1->B1_COD) +" - " +SB1->B1_DESC,100),aAddTree[nX],cImagem,cImagem,,,2)
			oTree:TreeSeek(aAddTree[nX])
		Next nX
	EndIf

	SG1->(RestArea(aAreaSG1))
	SB1->(RestArea(aAreaSB1))
	
	If !lPesq
		oTree:TreeSeek(cCargoBkp)
		Aviso(STR0023,STR0029,{"OK"}) //-- Produto não localizado.
	Else
		AtuModel(@oTree,@oModel,@oView)
		oTree:SetFocus()
	EndIf
EndIf

Return



