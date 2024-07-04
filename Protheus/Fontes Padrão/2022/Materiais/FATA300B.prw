#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA300B.CH" 

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FATA300B

Historico da Oportunidade de Venda.

@sample	FATA300()

@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		20/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function FATA300B(cFiltro)

Local aArea		:= GetArea()
Local oMBrowse		:= Nil
Local aLegend		:= {}
Local aLegendNew	:= {}
Local nX			:= 0
Local lFT30COR		:= ExistBlock("FT30COR")
Local aLPVendas 	:= {"",{|| Ft300LPVBr() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| Ft300LPVen() },,,,.F.}
Local aLEVendas 	:= {"",{|| Ft300LEVBr() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| Ft300LEVen() },,,,.F.}

Private cCadastro		:= STR0001 //"Histórico da Oportunidade de Venda"   
Private aRotina 		:= MenuDef() 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Legenda da Oportunidade de Venda  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aLegend,{"ADC->ADC_STATUS=='1'","BR_VERDE"		, STR0002}) 	//Em Aberto
aAdd(aLegend,{"ADC->ADC_STATUS=='2'","BR_PRETO"		, STR0003})	//Perdido
aAdd(aLegend,{"ADC->ADC_STATUS=='3'","BR_AMARELO"	, STR0004})	//Suspenso
aAdd(aLegend,{"ADC->ADC_STATUS=='9'","BR_VERMELHO"	, STR0005})	//Encerrado
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFT30COR
	aLegendNew := ExecBlock("FT30COR",.F.,.F.,aLegend)
	If ValType( aLegendNew ) == "A" 
		aLegend := aClone(aLegendNew)
	EndIf
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Browse da Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("ADC") 
oMBrowse:SetMenuDef("FATA300B")
oMBrowse:SetDescription(STR0001) //"Histórico da Oportunidade de Venda"
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona as legendas no browse. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aLegend)
	oMBrowse:AddLegend(aLegend[nX][1],aLegend[nX][2],aLegend[nX][3])
Next nX
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona as colunas da Evolucao da Venda no browse. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMBrowse:AddColumn(aLPVendas)
oMBrowse:AddColumn(aLEVendas)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro default no browse. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFiltro)
	oMBrowse:SetFilterDefault(cFiltro)
EndIf
	
oMBrowse:Activate()
	 
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ModelDef

Modelo de dados do cadastro de Oportunidade de Venda.

@sample	ModelDef() 

@param		Nenhum

@return	ExpO - Objeto MPFormModel

@author	Anderson Silva
@since		04/04/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() 
 
Local oModel 	 	:= Nil																							// Modelo de Dados da Oportunidade de Venda.
Local oStructADC	:= FWFormStruct(1,"ADC",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela ADC - Oportunidade de Venda.
Local oStructAD2	:= FWFormStruct(1,"AD2",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela AD2 - Time de Vendas.
Local oStructAD3	:= FWFormStruct(1,"AD3",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela AD3 - Concorrentes. 
Local oStructAD4	:= FWFormStruct(1,"AD4",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela AD4 - Parceiros.
Local oStructAD9	:= FWFormStruct(1,"AD9",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela AD9 - Contatos.
Local oStructADJ	:= FWFormStruct(1,"ADJ",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela ADJ - Produtos da Oportunidade de Venda.
Local oStructAIJ	:= FWFormStruct(1,"AIJ",/*bAvalCampo*/,/*lViewUsado*/)									// Estrutura da Tabela AIJ - Evolução da Venda (Pipeline).
Local bLoadAIJ		:= {|oMdlAIJ| F300LdAIJ(oMdlAIJ) }															// Faz o load da tabela AIJ - Evolucao da Venda (Pipeline).
Local aMemoADC 	:= {{"ADC_CODMEM","ADC_MEMO"}}																// Array para ser utilizado na funcao FWMemoVirtual.								
Local aMemoAD4 	:= {{"AD4_CODMEM","AD4_MEMO"}}																// Array para ser utilizado na funcao FWMemoVirtual.								

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campo de legenda na estrutura da Evolucao da Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oStructAIJ:AddField(	AllTrim("")								,;  	// [01] C Titulo do campo
						AllTrim(STR0006)							,;   	// [02] C ToolTip do campo
		     			"AIJ_LEGEND" 								,;    	// [03] C identificador (ID) do Field
		         		"C" 										,;    	// [04] C Tipo do campo
		            	15 											,;    	// [05] N Tamanho do campo
		              	0 											,;    	// [06] N Decimal do campo
		                Nil 										,;    	// [07] B Code-block de validação do campo
		                Nil											,;     	// [08] B Code-block de validação When do campo
		                Nil 										,;    	// [09] A Lista de valores permitido do campo
		                Nil 										,;  	// [10] L Indica se o campo tem preenchimento obrigatório
		                {|| "BR_VERDE" } 							,;   	// [11] B Code-block de inicializacao do campo
		                Nil 										,;  	// [12] L Indica se trata de um campo chave
		                Nil 										,;     	// [13] L Indica se o campo pode receber valor em uma operação de update.
		                .T. )              									// [14] L Indica se o campo é virtual
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para campos do tipo Memo com o conteudo na SYP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FWMemoVirtual(oStructADC,aMemoADC)
FWMemoVirtual(oStructAD4,aMemoAD4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados da Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("FATA300B",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona no modelo formulario e grids. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabeçalho - Histórico da Oportunidade de Venda. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields("ADCMASTER",/*cOwner*/,oStructADC,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Time de Vendas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oModel:AddGrid("AD2DETAIL","ADCMASTER",oStructAD2,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Concorrentes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddGrid("AD3DETAIL","ADCMASTER",oStructAD3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Parceiros. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddGrid("AD4DETAIL","ADCMASTER",oStructAD4,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Contatos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddGrid("AD9DETAIL","ADCMASTER",oStructAD9,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddGrid("ADJDETAIL","ADCMASTER",oStructADJ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Evolucao da Venda (Pipeline). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddGrid("AIJDETAIL","ADCMASTER",oStructAIJ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,bLoadAIJ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do relacionamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Time de Vendas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AD2DETAIL",{{"AD2_FILIAL","xFilial('AD2')"},{"AD2_NROPOR","ADC_NROPOR"},{"AD2_REVISA","ADC_REVISA"}},AD2->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Concorrentes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AD3DETAIL",{{"AD3_FILIAL","xFilial('AD3')"},{"AD3_NROPOR","ADC_NROPOR"},{"AD3_REVISA","ADC_REVISA"}},AD3->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Parceiros. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AD4DETAIL",{{"AD4_FILIAL","xFilial('AD4')"},{"AD4_NROPOR","ADC_NROPOR"},{"AD4_REVISA","ADC_REVISA"}},AD4->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Contatos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AD9DETAIL",{{"AD9_FILIAL","xFilial('AD9')"},{"AD9_NROPOR","ADC_NROPOR"},{"AD9_REVISA","ADC_REVISA"}},AD9->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("ADJDETAIL",{{"ADJ_FILIAL","xFilial('ADJ')"},{"ADJ_NROPOR","ADC_NROPOR"},{"ADJ_REVISA","ADC_REVISA"}},ADJ->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Evolucao da Venda (Pipeline). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AIJDETAIL",{{"AIJ_FILIAL","xFilial('AIJ')"},{"AIJ_NROPOR","ADC_NROPOR"},{"AIJ_REVISA","ADC_REVISA"},{"AIJ_PROVEN","ADC_PROVEN"}},AIJ->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permissoes para Grid. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("AD2DETAIL"):SetOptional(.T.)		// Time de Vendas
oModel:GetModel("AD3DETAIL"):SetOptional(.T.)		// Concorrentes
oModel:GetModel("AD4DETAIL"):SetOptional(.T.)		// Parceiros
oModel:GetModel("AD9DETAIL"):SetOptional(.T.)		// Contatos
oModel:GetModel("ADJDETAIL"):SetOptional(.T.)		// Produtos
oModel:GetModel("AIJDETAIL"):SetOptional(.T.)		// Evolucao da Venda
	
oModel:GetModel("AD2DETAIL"):SetOnlyView(.T.)		// Time de Vendas
oModel:GetModel("AD3DETAIL"):SetOnlyView(.T.)		// Concorrentes
oModel:GetModel("AD4DETAIL"):SetOnlyView(.T.)		// Parceiros
oModel:GetModel("AD9DETAIL"):SetOnlyView(.T.)		// Contatos
oModel:GetModel("ADJDETAIL"):SetOnlyView(.T.)		// Produtos
oModel:GetModel("AIJDETAIL"):SetOnlyView(.T.)		// Evolucao da Venda

oModel:GetModel("AD2DETAIL"):SetOnlyQuery(.T.)	// Time de Vendas
oModel:GetModel("AD3DETAIL"):SetOnlyQuery(.T.)	// Concorrentes
oModel:GetModel("AD4DETAIL"):SetOnlyQuery(.T.)	// Parceiros
oModel:GetModel("AD9DETAIL"):SetOnlyQuery(.T.)	// Contatos
oModel:GetModel("ADJDETAIL"):SetOnlyQuery(.T.)	// Produtos
oModel:GetModel("AIJDETAIL"):SetOnlyQuery(.T.)	// Evolucao da Venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Model. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetDescription(STR0001) // "Histórico da Oportunidade de Venda"

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da Oportunidade de Venda.

@sample	ViewDef()

@param		Nenhum

@return	ExpO - Objeto FWFormView

@author	Anderson Silva
@since		08/04/2014
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 		:= Nil															// Interface da Oportunidade de Venda.
Local oModel		:= FWLoadModel("FATA300B")									// Modelo de Dados da Oportunidade de Venda.
Local oStructADC	:= FWFormStruct(2,"ADC",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela ADC - Oportunidade de Venda.
Local oStructAD2	:= FWFormStruct(2,"AD2",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela AD2 - Time de Vendas.
Local oStructAD3	:= FWFormStruct(2,"AD3",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela AD3 - Concorrentes.
Local oStructAD4	:= FWFormStruct(2,"AD4",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela AD4 - Parceiros.
Local oStructAD9	:= FWFormStruct(2,"AD9",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela AD9 - Contatos.
Local oStructADJ	:= FWFormStruct(2,"ADJ",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela ADJ - Produtos da Oportunidade de Venda.
Local oStructAIJ	:= FWFormStruct(2,"AIJ",/*bAvalCampo*/,/*lViewUsado*/)	// Estrutura da Tabela AIJ - Evolução da Venda (Pipeline).
Local lMultVist 	:= SuperGetMv("MV_MULVIST",,.F.)   							// Multipla Vistorias Tecnica
Local lPyme		:= IIF(Type("__lPyme") <> "U",__lPyme,.F.)					// Serie 3 do Protheus


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona campo de legenda na estrutura da Evolucao da Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oStructAIJ:AddField(	"AIJ_LEGEND" 								,;	// [01] C Nome do Campo
						"01" 										,; 	// [02] C Ordem
						AllTrim("")								,; 	// [03] C Titulo do campo
	     				AllTrim(STR0006)							,; 	// [04] C Descrição do campo #TRADUZIR#
	         			{STR0006} 	   								,; 	// [05] A Array com Help
	            		"C" 										,; 	// [06] C Tipo do campo
	            		"@BMP" 										,; 	// [07] C Picture
	              		Nil 										,; 	// [08] B Bloco de Picture Var
	                	"" 											,; 	// [09] C Consulta F3
	                 	.F. 										,;	// [10] L Indica se o campo é evitável
	                  	Nil 										,; 	// [11] C Pasta do campo
	                   	Nil 										,;	// [12] C Agrupamento do campo
	                    Nil 										,; 	// [13] A Lista de valores permitido do campo (Combo)
	                    Nil 										,;	// [14] N Tamanho Maximo da maior opção do combo
	                    Nil 										,;	// [15] C Inicializador de Browse
	                    .T. 										,;	// [16] L Indica se o campo é virtual
	                    Nil )                 							// [17] C Picture Variável    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura da Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructADC:RemoveField("ADC_CODMEM")
oStructADC:RemoveField("ADC_IDESTN")
oStructADC:RemoveField("ADC_NVESTN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vistoria Tecnica do Gestão de Serviços. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nModulo <> 28 .OR. lPyme .OR. lMultVist )
	oStructADC:RemoveField("ADC_VISTEC")
	oStructADC:RemoveField("ADC_CODVIS")
	oStructADC:RemoveField("ADC_SITVIS")
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura do Time de Vendas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAD2:RemoveField("AD2_NROPOR")
oStructAD2:RemoveField("AD2_REVISA")
oStructAD2:RemoveField("AD2_HISTOR")
oStructAD2:RemoveField("AD2_IDESTN")
oStructAD2:RemoveField("AD2_NVESTN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura de Concorrentes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAD3:RemoveField("AD3_NROPOR")
oStructAD3:RemoveField("AD3_REVISA")
oStructAD3:RemoveField("AD3_HISTOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura de Parceiros. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAD4:RemoveField("AD4_NROPOR")
oStructAD4:RemoveField("AD4_REVISA")
oStructAD4:RemoveField("AD4_HISTOR")
oStructAD4:RemoveField("AD4_CODMEM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura de Contatos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAD9:RemoveField("AD9_NROPOR")
oStructAD9:RemoveField("AD9_REVISA")
oStructAD9:RemoveField("AD9_HISTOR")
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos da estrutura de Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructADJ:RemoveField("ADJ_NROPOR")
oStructADJ:RemoveField("ADJ_REVISA")
oStructADJ:RemoveField("ADJ_HISTOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a interface da Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView := FWFormView():New()
oView:SetModel(oModel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona na interface formulario e grids. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabeçalho - Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddField("VIEW_ADC",oStructADC,"ADCMASTER")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Time de Vendas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_AD2",oStructAD2,"AD2DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Concorrentes. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_AD3",oStructAD3,"AD3DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Parceiros. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_AD4",oStructAD4,"AD4DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Contatos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_AD9",oStructAD9,"AD9DETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_ADJ",oStructADJ,"ADJDETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Evolucao da Venda (Pipeline). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddGrid("VIEW_AIJ",oStructAIJ,"AIJDETAIL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box - Cabeçalho da Oportunidade de Venda. ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("TOP",50)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box - Central da Oportunidade de Venda (Time de Vendas, Concorrentes, Parceiros, Contatos, Produtos, Evolucao da Venda (Pipeline) ). ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("CENTER",50)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder - Criação das Pastas. ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateFolder("FOLDER","CENTER")
oView:AddSheet("FOLDER","TAB_AD2","Time de Vendas")		// "Time de Vendas"
oView:AddSheet("FOLDER","TAB_AD3","Concorrentes")		// "Concorrentes"
oView:AddSheet("FOLDER","TAB_AD4","Parceiros")			// "Parceiros"
oView:AddSheet("FOLDER","TAB_AD9","Contatos")				// "Contatos"
oView:AddSheet("FOLDER","TAB_ADJ","Produtos")				// "Produtos"
oView:AddSheet("FOLDER","TAB_AIJ","Evolução da Venda")	// "Evolução da Venda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box dentro do Folder - Rodape da Oportunidade de Venda ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("HBX_AD2",100,,,"FOLDER","TAB_AD2") // "Time de Vendas"
oView:CreateHorizontalBox("HBX_AD3",100,,,"FOLDER","TAB_AD3") // "Concorrentes"
oView:CreateHorizontalBox("HBX_AD4",100,,,"FOLDER","TAB_AD4") // "Parceiros"
oView:CreateHorizontalBox("HBX_AD9",100,,,"FOLDER","TAB_AD9") // "Contatos"
oView:CreateHorizontalBox("HBX_ADJ",100,,,"FOLDER","TAB_ADJ") // "Produtos"
oView:CreateHorizontalBox("HBX_AIJ",100,,,"FOLDER","TAB_AIJ") // "Evolução da Venda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta a view no janelamento criado anteriormente. ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:SetOwnerView("VIEW_ADC","TOP")
oView:SetOwnerView("VIEW_AD2","HBX_AD2")	// "Time de Vendas"
oView:SetOwnerView("VIEW_AD3","HBX_AD3") 	// "Concorrentes"
oView:SetOwnerView("VIEW_AD4","HBX_AD4")	// "Parceiros"
oView:SetOwnerView("VIEW_AD9","HBX_AD9")	// "Contatos"
oView:SetOwnerView("VIEW_ADJ","HBX_ADJ")	// "Produtos"
oView:SetOwnerView("VIEW_AIJ","HBX_AIJ")	// "Evolução da Venda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o formulario ao confirmar uma operação CRUD. ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:BCloseOnOk := {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta formulario continuo para Oportunidade de Venda. ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:SetContinuousForm() 

Return( oView )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} MenuDef

MenuDef do Historico da Oportunidade de Venda.

@sample	MenuDef()

@param		Nenhum

@return	ExpA - Rotinas CRUD / Acoes Relacionadas

@author	Anderson Silva
@since		20/03/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function MenuDef() 

Local aRotina := {} 		// Variavel a rotina.                      

ADD OPTION aRotina TITLE STR0007	ACTION "PesqBrw"				OPERATION 1 ACCESS 0  // "Pesquisar"
ADD OPTION aRotina TITLE STR0008	ACTION "VIEWDEF.FATA300B"	OPERATION 2 ACCESS 0  // "Visualizar"
ADD OPTION aRotina TITLE STR0009 	ACTION "Ft300Leg"          	OPERATION 2 ACCESS 0 	// "Legenda"

Return(aRotina)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} F300LdAIJ

Faz a carga da Evolucao da Venda e calcula a data e hora limite para encerramento
do estagio atual do processo de venda utilizado na Oportunidade de Venda.

@sample 	F300LdAIJ(oMdlAIJ)

@param		ExpO1 - ModelGrid da Evolucao da Venda. 

@return	ExpA - Carga da Evolucao da Venda.

@author	Anderson Silva
@since		27/03/2014 
@version	P12
/*/ 
//------------------------------------------------------------------------------
Static Function F300LdAIJ(oMdlAIJ)

Local aArea		:= GetArea()																					// Area da tabela atual.
Local aAreaAC2		:= AC2->(GetArea())																			// Area da tabela AC2.
Local aAreaAIJ		:= AIJ->(GetArea())
Local oModel		:= oMdlAIJ:GetModel()																		    // Model da Oportunidade de Venda (MPFormModel).
Local oStructAIJ	:= oMdlAIJ:GetStruct()																		// Estrutura da Evolucao da Venda.
Local aCamposAIJ	:= aClone(oStructAIJ:GetFields())															// Campos da AIJ.
Local aLoadAIJ		:= {}																							// Carga da AIJ.
Local nLinha		:= 0																							// Linha do array aLoadAIJ.
Local dDtNotif		:= cTod("//") 																					// Data que comecara a notificacao.
Local cHrNotif		:= ""																							// Hora que comecara a notificacao.
Local nHrsInt 		:= 0		   																					// Horas configurada para notificar.
Local nDtHrLimit	:= 0								   															// Data / Hora limite para avancar o estagio.
Local nDtHrNotif	:= 0								   															// Data / Hora notificacao para avancar o estagio.
Local nDtHrBase	:= 0																							// Database do sistema (Data/Hora).
Local dDataLim 	:= cTod("//")																					// Data limite para avancar ou encerrar o estagio.
Local cHoraLim 	:= ""																							// Hora limite para avancar ou encerrar o estagio.
Local nX			:= 0																							// Incremento utilizado no laco for.
Local oMdlADC		:= oModel:GetModel("ADCMASTER")																// ModelField da Oportunidade de Venda.
Local cNrOport		:= oMdlADC:GetValue("ADC_NROPOR")
Local cRevOport	:= oMdlADC:GetValue("ADC_REVISA") 
Local nPosLegend	:= aScan(aCamposAIJ,{ |x| AllTrim(x[MODEL_FIELD_IDFIELD]) == "AIJ_LEGEND"})	 		// Posicao do campo no SX3.
Local nPosDtLim 	:= aScan(aCamposAIJ,{ |x| AllTrim(x[MODEL_FIELD_IDFIELD]) == "AIJ_DTLIMI"}) 			// Posicao do campo no SX3.
Local nPosHrLim 	:= aScan(aCamposAIJ,{ |x| AllTrim(x[MODEL_FIELD_IDFIELD]) == "AIJ_HRLIMI"}) 			// Posicao do campo no SX3.

Private INCLUI		:= .F.

DbSelectArea("AIJ")
//AIJ_FILIAL+AIJ_NROPOR+AIJ_REVISA+AIJ_PROVEN+AIJ_STAGE
AIJ->(DbSetOrder(1))

DbSelectArea("AC2")
//AC2_FILIAL+AC2_PROVEN+AC2_STAGE 
AC2->(DbSetOrder(1))

If AIJ->(DbSeek(xFilial("AIJ")+cNrOport+cRevOport))
	
	While (	 AIJ->(!Eof()) .AND. AIJ->AIJ_FILIAL == xFilial("AIJ") .AND.;
			 AIJ->AIJ_NROPOR == cNrOport .AND. AIJ->AIJ_REVISA == cRevOport )
		
		If AC2->(DbSeek(xFilial("AC2")+AIJ->AIJ_PROVEN+AIJ->AIJ_STAGE))
	
			aAdd(aLoadAIJ,{AIJ->(RecNo()),Array(Len(aCamposAIJ))})
			
			nLinha := Len(aLoadAIJ)
			
			//Faz a carga das informações gravada na tabela AIJ e inicializa os campos virtuais
			For nX := 1 To Len(aCamposAIJ)
				If !aCamposAIJ[nX][MODEL_FIELD_VIRTUAL]
					aLoadAIJ[nLinha][2][nX]	:= &("AIJ->"+aCamposAIJ[nX][MODEL_FIELD_IDFIELD])
				Else
					Do Case
						Case aCamposAIJ[nX][MODEL_FIELD_IDFIELD] == "AIJ_LEGEND"
							aLoadAIJ[nLinha][2][nX]	:= "BR_VERDE"
						Case aCamposAIJ[nX][MODEL_FIELD_IDFIELD] == "AIJ_DSTAGE"
							aLoadAIJ[nLinha][2][nX]	:= AC2->AC2_DESCRI
						Case aCamposAIJ[nX][MODEL_FIELD_IDFIELD] == "AIJ_DUREST"
							aLoadAIJ[nLinha][2][nX]	:= TKCalcPer(AIJ->AIJ_DTINIC,AIJ->AIJ_HRINIC,AIJ->AIJ_DTENCE,AIJ->AIJ_HRENCE)
						OtherWise
							aLoadAIJ[nLinha][2][nX]	:= CriaVar(aCamposAIJ[nX][MODEL_FIELD_IDFIELD],.T.)
					EndCase
				EndIf
			Next nX
			
			// Seta a legenda e calcula a Evolucao da Venda
			If !Empty(AIJ->AIJ_STATUS)
				
				If AIJ->AIJ_STATUS == "1"
					aLoadAIJ[nLinha][2][nPosLegend] := "BR_BRANCO"
				ElseIf AIJ->AIJ_STATUS == "2"
					aLoadAIJ[nLinha][2][nPosLegend] := "BR_PRETO"
				EndIf
				
			Else
				
				//Calcula o limite de encerramento do estagio do processo de vendas.
				dDataLim := AIJ->AIJ_DTLIMI
				cHoraLim := AIJ->AIJ_HRLIMI
				
				Ft300LtEst(AIJ->AIJ_DTINIC,AIJ->AIJ_HRINIC,@dDataLim,@cHoraLim)
				
				aLoadAIJ[nLinha][2][nPosDtLim] := dDataLim
				aLoadAIJ[nLinha][2][nPosHrLim] := cHoraLim
				
				If ( AC2->AC2_DNOTIF <> 0 .OR. ( !Empty(AC2->AC2_HNOTIF) .AND. AC2->AC2_HNOTIF <> "00:00" ) )
					
					dDtNotif := aLoadAIJ[nLinha][2][nPosDtLim] - AC2->AC2_DNOTIF
					cHrNotif := aLoadAIJ[nLinha][2][nPosHrLim]
					nHrsInt  := HoraToInt(AC2->AC2_HNOTIF)
					
					SubtDiaHor(@dDtNotif,@cHrNotif,nHrsInt)
					
					nDtHrNotif	:= Val(DtoS(dDtNotif)+StrTran(cHrNotif,":",""))
					
				EndIf
				
				nDtHrLimit	:= Val(DtoS(aLoadAIJ[nLinha][2][nPosDtLim])+StrTran(aLoadAIJ[nLinha][2][nPosHrLim],":",""))
				nDtHrBase	:= Val(DtoS(dDataBase)+StrTran(SubStr(Time(),1,5),":",""))
				
				// Legenda do estagio atual.
				If nDtHrLimit <> 0
					If ( nDtHrNotif <> 0 .AND. nDtHrBase >=  nDtHrNotif  .AND. nDtHrNotif <= nDtHrLimit  .AND. nDtHrLimit > nDtHrBase  )
						aLoadAIJ[nLinha][2][nPosLegend] := "BR_AMARELO"
					ElseIf nDtHrBase > nDtHrLimit
						aLoadAIJ[nLinha][2][nPosLegend] := "BR_VERMELHO"
					EndIf
				EndIf
				
			EndIf
			
		EndIf
		
		AIJ->(DbSkip())
	End
	
EndIf

RestArea(aAreaAIJ)
RestArea(aAreaAC2)
RestArea(aArea)

Return(aLoadAIJ)