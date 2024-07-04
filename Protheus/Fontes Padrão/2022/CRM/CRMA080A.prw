#INCLUDE "CRMA080A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW		2 

#DEFINE ESTAGIO			1
#DEFINE TOTAL_ESTAGIO	2
#DEFINE CONV_PROXIMO		3
#DEFINE NAO_CONVERT		4
#DEFINE TOTAL_CONVERT	5 
#DEFINE FINALIZADO		6 
#DEFINE DUR_MEDIA			7
#DEFINE REC_TOTAL			8 
#DEFINE REC_MEDIA			9 
#DEFINE NRO_ESTAGIO		10

Static oPnlChrCbx	:= Nil										// Panel para disposição do combo box
Static oPnlChart	:= Nil										// Panel para disposição do gráfico

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da Consulta Funil de Vendas.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStructFke	:= FWFormModelStruct():New()
Local oStructZYX	:= Nil
Local oStructAD1	:= Nil
Local nX			:= 0

// Cria as estruturas AD1 do tipo model para receber as oportunidades
oStructAD1 := FWFormModelStruct():New()
MntStctAd1(oStructAD1,TYPE_MODEL)

// Cria as estruturas fake ZYX do tipo model para receber os indicadores de conversão
oStructZYX := FWFormModelStruct():New()
oStructZYX:AddTable("ZYX",{},"IndicadoresConversao")
MntScruct(oStructZYX,"ZYX",TYPE_MODEL)

//----------Estrutura do campo tipo Model----------------------------

// [01] C Titulo do campo
// [02] C ToolTip do campo
// [03] C identificador (ID) do Field
// [04] C Tipo do campo
// [05] N Tamanho do campo
// [06] N Decimal do campo
// [07] B Code-block de validação do campo
// [08] B Code-block de validação When do campo
// [09] A Lista de valores permitido do campo
// [10] L Indica se o campo tem preenchimento obrigatório
// [11] B Code-block de inicializacao do campo
// [12] L Indica se trata de um campo chave
// [13] L Indica se o campo pode receber valor em uma operação de update.
// [14] L Indica se o campo é virtual

// Campo filial da tabela fake
oStructFke:AddField(STR0001,STR0002,"ZFK_FILIAL","C",FwSizeFilial(),0)//"Filial do Sistema"//"Filial"

//Instancia o modelo de dados
oModel := MPFormModel():New("CRMA080A",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Adiciona os campos no modelo de dados Model / ModelGrid
oModel:AddFields("MASTER", /*cOwner*/,oStructFke,/*bPreValidacao*/,/*bPosValidacao*/,{|| })
oModel:AddGrid("ZYXDETAIL","MASTER",oStructZYX,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("AD1DETAIL","MASTER",oStructAD1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

//Configura as propriedades do modelo de dados
oModel:GetModel("MASTER"):SetOnlyView(.T.)
oModel:GetModel("MASTER"):SetOnlyQuery(.T.)

oModel:GetModel("ZYXDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("ZYXDETAIL"):SetOptional(.T.)
oModel:GetModel("ZYXDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("ZYXDETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("AD1DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("AD1DETAIL"):SetOptional(.T.)
oModel:GetModel("AD1DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("AD1DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("MASTER"):SetDescription("Struct Fake")
oModel:SetDescription(STR0003)//"Consulta"
oModel:GetModel("AD1DETAIL"):SetDescription("AD1")
oModel:GetModel("ZYXDETAIL"):SetDescription("ZYX")
                                                  
oModel:SetPrimaryKey({})

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da Consulta Funil de Vendas.

@sample		ViewDef()

@param			Nenhum

@return		ExpO - Objeto FWFormView

@author		Aline Kokumai
@since			29/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local aArea		:= GetArea()
Local aAreaACA	:= ACA->(GetArea())	
Local aAreaSU5		:= SU5->(GetArea())	
Local oView		:=	Nil
Local oModel		:=	FWLoadModel( 'CRMA080A' )
Local oStructZYX	:=	Nil
Local oStructAD1	:=	Nil
Local cCodVend		:= CRMXRetVend()

// Cria as estruturas AD1 do tipo view para receber as oportunidades
oStructAD1 := FWFormViewStruct():New()
MntStctAd1(oStructAD1,TYPE_VIEW)

// Cria as estruturas fake ZYX do tipo view para receber os indicadores de conversão
oStructZYX := FWFormViewStruct():New()
MntScruct(oStructZYX,"ZYX",TYPE_VIEW)
oStructZYX:RemoveField("ZYX_DURMEDN")

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddGrid("VIEW_ZYX",oStructZYX,"ZYXDETAIL")
oView:AddGrid("VIEW_AD1",oStructAD1,"AD1DETAIL")
oView:AddOtherObject("VIEW_GRAFICO", {|oPanel| AddGrafic(oPanel,.F.)},Nil,{|oPanel| AddGrafic(oPanel,.T.)})
 
oView:AddUserButton( STR0004, STR0168, { || CfgTmVends(,,,.T.) } )//"Configurar Filtros"
 
DbSelectArea("SA3")
SA3->(DbSetOrder(1)) //A3_FILIAL+A3_COD

// carregando o aRotina do fonte de Oportunidade, para não estourar erro em rotina de dentro do Formulario de oportunidades 
oView:AddUserButton( STR0005, STR0005, { || CRMA080Opo(4) } )//"Alterar Oportunidade"
oView:AddUserButton( STR0006, STR0006, { || CRMA080Opo(1) } )  //"Visualizar Oportunidade"

oView:CreateHorizontalBox("SUPERIOR",50) 
oView:CreateHorizontalBox("INFERIOR",50)

oView:CreateVerticalBox("VIEW_ZYX_SUP",50,"SUPERIOR")
oView:CreateVerticalBox("VIEW_GRAFICO_SUP",50,"SUPERIOR")  

// Indicadores de Conversão - Onde está o ponto fraco do meu processo de vendas
oView:EnableTitleView("VIEW_ZYX",STR0007)//"Indicadores de Conversão"
oView:SetOwnerView("VIEW_ZYX","VIEW_ZYX_SUP")

// Gráfico Funil de Vendas
oView:EnableTitleView("VIEW_GRAFICO",STR0008)//"Grafico"
oView:SetOwnerView("VIEW_GRAFICO","VIEW_GRAFICO_SUP")

// Oportunidades de Venda
oView:EnableTitleView("VIEW_AD1",STR0009)//"Oportunidades de Venda"
oView:SetOwnerView("VIEW_AD1","INFERIOR") 
oView:ShowInsertMessage(.F.)
oView:ShowUpdateMessage(.F.)

RestArea(aAreaACA)
RestArea(aAreaSU5)
RestArea(aArea)

Return ( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntScruct

Monta a estrutura de dados do tipo Model / View.

@sample	MntScruct(oStruct,cAliasFake,nType)

@param		ExpO1 - Objeto FWFormModelStruct / FWFormViewStruct
			ExpC2 - Objeto Alias Fake
			ExpN3 - Tipo Model / View 
			
@return	ExpO - Objeto FWFormView

@author	Aline Kokumai
@since		29/10/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------

Static Function MntScruct(oStruct,cAliasFake,nType)

If nType == TYPE_MODEL
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual

	oStruct:AddField(STR0010,STR0010,"ZYX_ESTAGIO","C",20,0)//STR0011//"Estágio"
	
	oStruct:AddField(STR0012,STR0012,"ZYX_TOTAL","N",12,0)              	//STR0013//"Total"
	
	oStruct:AddField(STR0014,STR0014,"ZYX_CONVPRO","N",12,2)              	//STR0015//"% Conv. Próximo"
	
	oStruct:AddField(STR0016,STR0016,"ZYX_NAOCONV","N",12,0)//STR0017//"Não Convertidos"
		
	oStruct:AddField(STR0018,STR0018,"ZYX_CONVTOT","N",12,2)		//STR0019//"% Conv. Total"
		
	oStruct:AddField(STR0020,STR0020,"ZYX_FINAL","N",12,2)       //STR0021//"% Finalizados"
		
	oStruct:AddField(STR0022,STR0022,"ZYX_DURMEDC","C",50,0)//STR0023//"Duração Média"
		
	oStruct:AddField(STR0024,STR0024,"ZYX_DURMEDN","N",12,2)     		//STR0025//"Duração Média"
		
	oStruct:AddField(STR0026,STR0026,"ZYX_RCTOTAL","N",12,2)          	   	//STR0027//"Receita Total"
		
	oStruct:AddField(STR0028,STR0028,"ZYX_RCMEDIA","N",12,2)//STR0029//"Receita Média"
	
	oStruct:AddField(STR0166,STR0166,"ZYX_NROESTAG","C",6,0) //"Código Estágio"
 
ElseIf nType == TYPE_VIEW
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	oStruct:AddField("ZYX_ESTAGIO","01",STR0030,STR0030,{STR0032},"C","@!",Nil,Nil,.F.,Nil)//STR0031//"Estágio"//"Nome do estágio do processo de venda."
	
	oStruct:AddField("ZYX_TOTAL","02",STR0034,STR0034,{STR0033},"N","@E 999,999,999",Nil,Nil,.F.,Nil)//"Número de vezes que o estágio do processo de vendas esteve presente nas oportunidades."//STR0035//"Total"
	
	oStruct:AddField("ZYX_CONVPRO","03",STR0036,STR0036,{STR0038},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0037//"% Conv. Próximo"//"Representa a taxa de conversão do estágio da venda anterior para o estágio da venda posterior."

	oStruct:AddField("ZYX_NAOCONV","04",STR0039,STR0039,{STR0041},"N","@E 999,999,999",Nil,Nil,.F.,Nil)//STR0040//"Não Convertidos"//"Representa número de vezes que o estágio não foi convertido para o próximo estágio do processo de vendas."

	oStruct:AddField("ZYX_CONVTOT","05",STR0042,STR0042,{STR0044},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0043//"% Conv. Total"//"Representa a taxa de conversão de cada estágio comparado com o total de oportunidades cadastradas."
	
	oStruct:AddField("ZYX_FINAL","06",STR0045,STR0045,{STR0047},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0046//"% Finalizados"//"Representa a taxa de conversão de oportunidades que chegaram ao último estágio da venda comparado com o total de cada estágio."
		
	oStruct:AddField("ZYX_DURMEDC","07",STR0048,STR0048,{STR0050},"C","@!",Nil,Nil,.F.,Nil)//STR0049//"Duração Média"//"Representa o tempo médio de duração do estágio nas oportunidades de venda."
		
	oStruct:AddField("ZYX_DURMEDN","08",STR0051,STR0051,{STR0053},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0052//"Duração Média"//"Representa o tempo médio de duração do estágio nas oportunidades de venda."
		
	oStruct:AddField("ZYX_RCTOTAL","09",STR0054,STR0054,{STR0056},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0055//"Receita Total"//"Representa a somatória da receita estimada das oportunidades para cada estágio do processo de vendas."
		
	oStruct:AddField("ZYX_RCMEDIA","10",STR0057,STR0057,{STR0059},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil)//STR0058//"Receita Média"//"Representa a média da receita estimada das oportunidades para cada estágio do processo de vendas."
	
	oStruct:AddField("ZYX_NROESTAG","11",STR0166,STR0166,{STR0167},"C","@!",Nil,Nil,.F.,Nil) //"Código Estágio"//"Código do estágio do processo de venda."
	
EndIf
 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntStctAd1

Monta a estrutura de dados do tipo Model / View.

@sample	MntStctAd1(oStruct,nType)

@param		ExpO1 - Objeto FWFormModelStruct / FWFormViewStruct
			ExpN2 - Tipo Model / View 
			
@return	ExpO - Objeto FWFormView

@author	Aline Kokumai
@since		06/11/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function MntStctAd1(oStruct,nType)

Local aDadosCpo	:= {}

If nType == TYPE_MODEL
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
		
	// Legenda da oportunidade
	oStruct:AddField("","","AD1_LEGEND","C",1,0,Nil,Nil,Nil,Nil,{|| InicLegend((cAlias)->AD1_CODSTA)},Nil,Nil,.T.)
		
	// Campos dados para transferencia
	aDadosCpo := TxSX3Campo("AD1_FILIAL")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0060,"AD1_FILIAL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Filial"
		
	aDadosCpo := TxSX3Campo("AD1_NROPOR")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0061,"AD1_NROPOR",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              //"Número da Oportunidade de Venda"

	aDadosCpo := TxSX3Campo("AD1_DESCRI")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0062,"AD1_DESCRI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])             //"Descrição"
		
	oStruct:AddField(STR0063,STR0063,"AD1_ENTIDA","C",7,Nil)		//STR0064//"Entidade"
		
	oStruct:AddField(STR0065,STR0066,"AD1_CONTA","C",6,Nil)		//"Cod. Conta"//"Código da Conta"
		
	oStruct:AddField(STR0068,STR0067,"AD1_LOJA","C",2,Nil)		//"Loja da Conta"//"Loja"
		
	oStruct:AddField(STR0071,STR0070,"AD1_CTNOME","C",40,Nil,,,,,{|| IIF(AllTrim((cAlias)->AD1_ENTIDA)==AllTrim(STR0069),;//"CLIENTE"//"Nome da Conta"//"Nome"
																			Posicione("SA1",1,xFilial("SA1")+(cAlias)->AD1_CONTA+(cAlias)->AD1_LOJA,"A1_NOME"),;
																			Posicione("SUS",1,xFilial("SUS")+(cAlias)->AD1_CONTA+(cAlias)->AD1_LOJA,"US_NOME"))},,,.T.)          	   	
		
	aDadosCpo := TxSX3Campo("AD1_FEELIN")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0072,"AD1_FEELIN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,StrTokArr(aDadosCpo[7],";"))              	//"Chance de Sucesso"
		
	aDadosCpo := TxSX3Campo("AD1_PROVEN")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0073,"AD1_PROVEN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Código do Processo de Vendas"
		
	aDadosCpo := TxSX3Campo("AC1_DESCRI")
	oStruct:AddField(STR0074,STR0075,"AD1_DESCPR",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("AC1",1,xFilial("AC1")+(cAlias)->AD1_PROVEN,"AC1_DESCRI")},,,.T.)//"Desc. Processo"//"Descrição do Processo de Vendas"
				
  	aDadosCpo := TxSX3Campo("AD1_STAGE")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0076,"AD1_STAGE",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Código do Estágio da Venda"
		
	aDadosCpo := TxSX3Campo("AC2_DESCRI")
	oStruct:AddField(STR0077,STR0078,"AD1_DESCES",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("AC2",1,xFilial("AC2")+(cAlias)->AD1_PROVEN+(cAlias)->AD1_STAGE,"AC2_DESCRI")},,,.T.)//"Desc. Estágio"//"Descrição do Estágio da Venda"
		
	aDadosCpo := TxSX3Campo("AD1_VERBA")	
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0079,"AD1_VERBA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Receita Estimada da Oportunidade"
	
	aDadosCpo := TxSX3Campo("AD1_RCINIC")		
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0080,"AD1_RCINIC",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Previsão Inicial"
	
	aDadosCpo := TxSX3Campo("AD1_RCFECH")		
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0081,"AD1_RCFECH",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Receita Estimada de Fechamento"
	
	aDadosCpo := TxSX3Campo("AD1_RCREAL")		
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0082,"AD1_RCREAL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Receita Real da Oportunidade"
			
	aDadosCpo := TxSX3Campo("AD1_DTINI")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0083,"AD1_DTINI",aDadosCpo[6],10,aDadosCpo[4])//"Data de Início"
		
	oStruct:AddField(STR0084,STR0085,"AD1_DTFIM","D",10,Nil)//"Data de Encerramento"//"Dt. Encer."
		
	aDadosCpo := TxSX3Campo("AD1_VEND")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0086,"AD1_VEND",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Código do Vendedor"
		
	aDadosCpo := TxSX3Campo("A3_NOME")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0087,"AD1_NOMVEN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("SA3",1,xFilial("SA3")+(cAlias)->AD1_VEND,"A3_NOME")},,,.T.)//"Nome do Vendedor"
		
	aDadosCpo := TxSX3Campo("AD1_FCS")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0088,"AD1_FCS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])    //"FCS"
		
	aDadosCpo := TxSX3Campo("AD1_DESFCS")
	oStruct:AddField(STR0089,STR0090,"AD1_DESFCS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+(cAlias)->AD1_FCS,"X5DESCRI()"))},,,.T.)       //"Desc. FCS"//"Descrição FCS"
		
	aDadosCpo := TxSX3Campo("AD1_FCI")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0091,"AD1_FCI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])             //"FCI"

	aDadosCpo := TxSX3Campo("AD1_DESFCI")
	oStruct:AddField(STR0092,STR0093,"AD1_DESFCI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+(cAlias)->AD1_FCI,"X5DESCRI()"))},,,.T.)        //"Desc. FCI"//"Descrição FCI"
	
	aDadosCpo := TxSX3Campo("AD1_STATUS")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0094,"AD1_STATUS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,StrTokArr(aDadosCpo[7],";"))//"Status da Oportunidade"
	
	oStruct:AddField(STR0095,STR0096,"AD1_CODSTA","C",2,Nil)  //"Cod. Status"//"Valor do Status"
				
	aDadosCpo := TxSX3Campo("AD1_REVISA")
	oStruct:AddField(AllTrim(aDadosCpo[1]),STR0097,"AD1_REVISA",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])	       //"Revisão da Oportunidade de Venda"
		                
ElseIf nType == TYPE_VIEW
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	// Campo de marca da tabela SA3 - vendedores
	oStruct:AddField("AD1_LEGEND","01","","",{},"C","@BMP",{||},Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)

	aDadosCpo := TxSX3Campo("AD1_NROPOR")
	oStruct:AddField("AD1_NROPOR","02",aDadosCpo[1],aDadosCpo[2],{STR0098},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Número da Oportunidade de Venda"
	
	aDadosCpo := TxSX3Campo("AD1_DESCRI")
	oStruct:AddField("AD1_DESCRI","03",aDadosCpo[1],aDadosCpo[2],{STR0099},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Descrição da Oportunidade"

	oStruct:AddField("AD1_ENTIDA","04",STR0100,STR0100,{STR0100},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//STR0101//STR0102//"Entidade"

	oStruct:AddField("AD1_CONTA","05",STR0103,STR0104,{STR0104},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Cod. Conta"//STR0105//"Código da Conta"
		
	oStruct:AddField("AD1_LOJA","06",STR0108,STR0106,{STR0106},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//STR0107//"Loja da Conta"//"Loja"
		
	oStruct:AddField("AD1_CTNOME","07",STR0111,STR0109,{STR0109},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//STR0110//"Nome da Conta"//"Nome"
		
	aDadosCpo := TxSX3Campo("AD1_FEELIN")
	oStruct:AddField("AD1_FEELIN","08",aDadosCpo[1],aDadosCpo[2],{STR0112},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Chance de Sucesso"
		                            
	aDadosCpo := TxSX3Campo("AD1_PROVEN")
	oStruct:AddField("AD1_PROVEN","09",aDadosCpo[1],aDadosCpo[2],{STR0113},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE") //"Código do Processo de Vendas"
		
	aDadosCpo := TxSX3Campo("AC1_DESCRI")
	oStruct:AddField("AD1_DESCPR","10",STR0114,aDadosCpo[2],{STR0115},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. Processo"//"Descrição do Processo de Vendas"
		
	aDadosCpo := TxSX3Campo("AD1_STAGE")
	oStruct:AddField("AD1_STAGE","11",aDadosCpo[1],aDadosCpo[2],{STR0116},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Código do Estágio da Venda"
	
	aDadosCpo := TxSX3Campo("AC2_DESCRI")
	oStruct:AddField("AD1_DESCES","12",STR0117,aDadosCpo[2],{STR0118},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. Estágio"//"Descrição do Estágio da Venda"
		
	aDadosCpo := TxSX3Campo("AD1_VERBA")		
	oStruct:AddField("AD1_VERBA","13",aDadosCpo[1],aDadosCpo[2],{STR0119},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Receita Estimada"

	aDadosCpo := TxSX3Campo("AD1_RCINIC")		
	oStruct:AddField("AD1_RCINIC","14",aDadosCpo[1],aDadosCpo[2],{STR0120},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Previsão Inicial"
	
	aDadosCpo := TxSX3Campo("AD1_RCFECH")		
	oStruct:AddField("AD1_RCFECH","15",aDadosCpo[1],aDadosCpo[2],{STR0121},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Receita Estimada de Fechamento"
	
	aDadosCpo := TxSX3Campo("AD1_RCREAL")		
	oStruct:AddField("AD1_RCREAL","16",aDadosCpo[1],aDadosCpo[2],{STR0122},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Receita Real de Fechamento"
				       
	aDadosCpo := TxSX3Campo("AD1_DTINI")
	oStruct:AddField("AD1_DTINI","17",aDadosCpo[1],aDadosCpo[2],{STR0123},aDadosCpo[6],Nil,Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Data de Início da Oportunidade"
		
	oStruct:AddField("AD1_DTFIM","18",STR0126,STR0125,{STR0124},"D",Nil,Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Data de Encerramento da Oportunidade"//"Data de Encerramento"//"Dt. Encer."
			  
	aDadosCpo := TxSX3Campo("AD1_VEND")
	oStruct:AddField("AD1_VEND","19",STR0127,STR0128,{STR0128},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Cod. Vendedor"//STR0129//"Código do Vendedor"
		
	aDadosCpo := TxSX3Campo("A3_NOME")
	oStruct:AddField("AD1_NOMVEN","20",STR0130,STR0131,{STR0131},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Nm. Vendedor"//STR0132//"Nome do Vendedor"
		
	aDadosCpo := TxSX3Campo("AD1_FCS")
	oStruct:AddField("AD1_FCS","21",aDadosCpo[1],aDadosCpo[2],{STR0133},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Fator Crítico de Sucesso"
		
	aDadosCpo := TxSX3Campo("AD1_DESFCS")
	oStruct:AddField("AD1_DESFCS","22",STR0134,STR0135,{STR0136},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. FCS"//"Descrição FCS"//"Descrição do Fator Crítico de Sucesso"
		
	aDadosCpo := TxSX3Campo("AD1_FCI")
	oStruct:AddField("AD1_FCI","23",aDadosCpo[1],aDadosCpo[2],{STR0137},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Fator Crítico de Insucesso"
		
	aDadosCpo := TxSX3Campo("AD1_DESFCI")
	oStruct:AddField("AD1_DESFCI","24",STR0138,STR0139,{STR0140},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. FCI"//"Descrição FCI"//"Descrição do Fator Crítico de Insucesso"
			
	aDadosCpo := TxSX3Campo("AD1_STATUS")
	oStruct:AddField("AD1_STATUS","25",aDadosCpo[1],aDadosCpo[2],{STR0141},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Status da Oportunidade"
	
	aDadosCpo := TxSX3Campo("AD1_REVISA")
	oStruct:AddField("AD1_REVISA","26",aDadosCpo[1],aDadosCpo[2],{STR0142},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Revisão da Oportunidade de Venda"
				      	    
EndIf
 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddGrafic

Função para adicionar o gráfico na tela.

@sample	AddGrafic(oPanel)

@param		ExpO1 - Objeto Panel 
		
@return	ExpL - Verdadeiro 

@author	Aline Kokumai
@since		31/10/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function AddGrafic(oPanel,lPnlActive)

Local oModel		:= FwModelActive()
Local oMdlZYX 	:= oModel:GetModel("ZYXDETAIL")
Local nX 			:= 0
Local nLinha		:= 0
Local aOpcoes 	:= {ESTAGIO,TOTAL_ESTAGIO,CONV_PROXIMO,NAO_CONVERT,TOTAL_CONVERT,FINALIZADO,DUR_MEDIA,REC_TOTAL,REC_MEDIA,NRO_ESTAGIO}
Local aSeries		:= {}
Local aArea		:= GetArea()
Local aCbxResA 	:= {STR0144,STR0145,STR0143}			// Combo do tipo de gráfico: STR0144,STR0145,STR0143//"Barras"//"Funil"//"Pizza"
Local aCbxResB 	:= {STR0149,STR0146,STR0148,STR0147,;	//"% Conv. Próximo"//"% Conv. Total"//"Não Convertidos"//"Total"
						STR0150,STR0151,STR0153,STR0152}   		//"% Finalizados"//"Duração Média"//"Receita Média"//"Receita Total"
Local cCbxResA 	:= ""									
Local cCbxResB 	:= ""
Local nTpChart	:= 1 	//Tipo do Grafico				
Local oFwChart	:= Nil
Local oFwChartFactory := FwChartFactory():New()
Local lFunil	:= .T.
Local lRetorno	:= .T.

If ValType(oMdlZYX) == "O" 

	If lPnlActive == .T.
		oPnlChrCbx:FreeChildren()
		oPnlChart:FreeChildren()
	Else
		
		oPnlChrCbx := TPanel():New(000,000,"",oPanel,,,,,,(oPanel:nWidth/2),(oPanel:nHeight/2)*0.15)
		oPnlChrCbx:Align := CONTROL_ALIGN_TOP
		//Em notebooks os campos ficam cordados
		//oPnlChart := TPanel():New(000,000,"",oPanel,,,,,,(oPanel:nWidth/2),(oPanel:nHeight/2)*0.85)
		oPnlChart := TPanel():New(000,000,"",oPanel,,,,,,(oPanel:nWidth/2),(oPanel:nHeight/2)*0.75)
		oPnlChart:Align := CONTROL_ALIGN_BOTTOM
	EndIf
	
	For nX := 1 To oMdlZYX:Length()
		Aadd(aSeries,Array(Len(aOpcoes)))
		oMdlZYX:GoLine(nX)
		aSeries[nX][ESTAGIO]			:= oMdlZYX:GetValue("ZYX_ESTAGIO")
		aSeries[nX][TOTAL_ESTAGIO]	:= oMdlZYX:GetValue("ZYX_TOTAL") 
		aSeries[nX][CONV_PROXIMO]	:= oMdlZYX:GetValue("ZYX_CONVPRO")
		aSeries[nX][NAO_CONVERT]		:= oMdlZYX:GetValue("ZYX_NAOCONV")
		aSeries[nX][TOTAL_CONVERT]	:= oMdlZYX:GetValue("ZYX_CONVTOT")
		aSeries[nX][FINALIZADO]		:= oMdlZYX:GetValue("ZYX_FINAL")
		aSeries[nX][DUR_MEDIA]		:= Round(oMdlZYX:GetValue("ZYX_DURMEDN"),2)
		aSeries[nX][REC_TOTAL]		:= oMdlZYX:GetValue("ZYX_RCTOTAL")
		aSeries[nX][REC_MEDIA]		:= oMdlZYX:GetValue("ZYX_RCMEDIA")
		aSeries[nX][NRO_ESTAGIO]		:= oMdlZYX:GetValue("ZYX_NROESTAG")
	Next nX
	
	If FindFunction("__FWCFunnel")	
		lFunil := .F.
	EndIf
	
	//Criação do Combo Box do tipo de gráfico (pizza ou barras)
	@ 05, 05 Say STR0154 Size 050, 008 Pixel Of oPnlChrCbx//"Tipo de Gráfico:"
	@ 03, 50 ComboBox cCbxResA Items aCbxResA Size 055, 010 Pixel Of oPnlChrCbx ;
	On Change (	nTpChart := aScan( aCbxResA, cCbxResA ) ,;		
					IIF (	lFunil .AND. nTpChart== 1,;						
					Help("",1, STR0164, , STR0165, 1, ),; //"Atenção" //"Gráfico de Funil de Vendas indisponível. Atualize a LIB com data superior a 14/11/2013."
					GeraGrafic(oFwChartFactory, @oFwChart,oPnlChart,aSeries,aCbxResA,cCbxResA,aCbxResB,cCbxResB,nTpChart)	) )
		
	//Criação do Combo Box
	//Tipo de valor
	@ 05, 115 Say STR0155 Size 060, 008 Pixel Of oPnlChrCbx //"Critério:"
	@ 03, 141 ComboBox cCbxResB Items aCbxResB Size 085, 010 Pixel Of oPnlChrCbx ;
	On Change (	IIF (	lFunil .AND. nTpChart== 1,;						
					Help("",1, STR0164, , STR0165, 1, ),;  //"Atenção"  //"Gráfico de Funil de Vendas indisponível. Atualize a LIB com data superior a 14/11/2013."
					GeraGrafic(oFwChartFactory, @oFwChart,oPnlChart,aSeries,aCbxResA,cCbxResA,aCbxResB,cCbxResB,nTpChart)	) )
	
	If !lFunil .AND. nTpChart== 1 //Funil

		GeraGrafic(oFwChartFactory,oFwChart,oPnlChart,aSeries,aCbxResA,cCbxResA,aCbxResB,cCbxResB,nTpChart)
	Else
		Help("",1, STR0164, , STR0165, 1, )  //"Atenção"  //"Gráfico de Funil de Vendas indisponível. Atualize a LIB com data superior a 14/11/2013."
	EndIf

EndIf

Return ( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraGrafic

Função para construir o gráfico da consulta.

@sample	GeraGrafic (oFwChartFactory,oFwChart,oPnlChart,aSeries,aCbxResA,cCbxResA,aCbxResB,cCbxResB)

@param		ExpO1 -		Instancia do grafico
			ExpO2 -		Objeto grafico
			ExpO3 -		Panel para disposição do gráfico
			ExpA4 -		Array com o valor das series do gráfico
			ExpA5 -		Combo do tipo de gráfico
			ExpC6 -		Opção do tipo de gráfico selecionado
			ExpA7 -		Combo das opções do gráfico
			ExpC8 -		Opção do gráfico selecionado
		
@return	ExpL - Verdadeiro 

@author	Aline Kokumai
@since		04/11/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function GeraGrafic (oFwChartFactory,oFwChart,oPnlChart,aSeries,aCbxResA,cCbxResA,aCbxResB,cCbxResB,nTpChart)

Local nX		 := 0
Local nSerie	 := 0
Local aArea	     := GetArea()
Local aSerieEst  := {}
Local nCritSel   := AScan(aCbxResB,{|x| x == cCbxResB }) //Recebe a posição da opção do gráfico selecionado
Local cDescri	 := ""
Local cPicture   := ""
Local cCategoria := ""
Local lRetorno   := .T.
Local oView	     := FwViewActive()
Local oViwZYX    := oView:GetViewStruct("VIEW_ZYX")

Do Case
	Case nCritSel == 1
		nSerie := TOTAL_ESTAGIO
		cDescri:= STR0156//"Total X Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_TOTAL",MVC_VIEW_PICT)
	Case nCritSel == 2
		nSerie := CONV_PROXIMO 
		cDescri:= STR0157//"% Convertidos Para Próximo Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_CONVPRO",MVC_VIEW_PICT)
	Case nCritSel == 3             
		nSerie := NAO_CONVERT  
		cDescri:= STR0158//"Não Convertidos Para Próximo Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_NAOCONV",MVC_VIEW_PICT)
	Case nCritSel == 4             
		nSerie := TOTAL_CONVERT
		cDescri:= STR0159//"% Convertidos Por Total Oportunidades"
		cPicture	:= oViwZYX:GetProperty("ZYX_CONVTOT",MVC_VIEW_PICT)
	Case	nCritSel == 5   
		nSerie := FINALIZADO
		cDescri:= STR0160 //"% Finalizados X Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_FINAL",MVC_VIEW_PICT)
	Case nCritSel == 6
		nSerie := DUR_MEDIA 
		cDescri:= STR0161 //"Tempo Médio de Duração X Estágio"
		cPicture	:= "@E 999,999,999.99" // Utilizada Picture, pois o campo foi removido da View
	Case nCritSel == 7             
		nSerie := REC_TOTAL 
		cDescri:= STR0162  //"Receita X Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_RCTOTAL",MVC_VIEW_PICT)
	Case nCritSel == 8             
		nSerie := REC_MEDIA
		cDescri:= STR0163 //"Média da Receita X Estágio"
		cPicture	:= oViwZYX:GetProperty("ZYX_RCMEDIA",MVC_VIEW_PICT)
	OtherWise
		nSerie := 0
EndCase

If oFwChart <> NIL
	FreeObj(oFwChart)
Endif 

If nTpChart == 2			//Pizza
	oFwChart := oFWChartFactory:getInstance( PIECHART )
ElseIf nTpChart == 3		//Barras
	oFwChart := oFWChartFactory:getInstance( BARCHART )
Else
	oFwChart := oFWChartFactory:getInstance( FUNNELCHART )
EndIf

oFwChart:setTitle(cDescri, CONTROL_ALIGN_CENTER )
oFWChart:setPicture( cPicture )
 
If (nTpChart == 2 .OR. nTpChart == 3)
	oFwChart:init( oPnlChart )
EndIf

If (nSerie > 0 )
	For nX := 1 to Len(aSeries)
		cCategoria := aSeries[nX][NRO_ESTAGIO] + "-" + aSeries[nX][ESTAGIO]
		oFwChart:addSerie(cCategoria ,aSeries[nX][nSerie])
		aadd(aSerieEst,{nX,aSeries[nX][10]})
	Next nX
EndIf
oFwChart:setLegend( CONTROL_ALIGN_BOTTOM )
oFwChart:SetSerieAction({ |nSerie| CursorWait(),CRM080BrwOp( nSerie, aSerieEst, oFwChart ),CursorArrow()  }) 

If (nTpChart == 2 .OR. nTpChart == 3)
	oFwChart:build()
Else
	oFwChart:oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
	oFwChart:oChart:lSerieLabel := .T.	
	oFwChart:oChart:lLabelDesc := .T.  //Exibe descricao no label
	oFwChart:oChart:lLabelValue := .T. //Exibe valor e percentual no label	
	oFwChart:Activate( oPnlChart )
EndIf

RestArea(aArea)

Return ( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA080Opo

FUNÇÃO PARA POSICIONAR A TABELA AD1- OPORTUNIDADES

@sample	CRMA080Opo(nOpcx)

@param	Nenhum	
			
@return	.T.

@author	Victor Bitencourt
@since		12/09/2014
@version	12.0               
/*/
//------------------------------------------------------------------------------
Function CRMA080Opo(nOpc)

Local oModel		:= FwModelActive()
Local oMdlAD1 		:= oModel:GetModel("AD1DETAIL")
Local nLinha		:= oMdlAD1:GetLine()
Local cNroPor		:= ""
Local cRevisa		:= "" 

Private aRotina 	:= FwLoadMenuDef("FATA300")
Private ALTERA		:= .F.

Default nOpc 		:= 1

oMdlAD1:GoLine(nLinha)
cNroPor	:= oMdlAD1:GetValue("AD1_NROPOR")
cRevisa	:= oMdlAD1:GetValue("AD1_REVISA") 

DbSelectArea("AD1")
DbSetOrder(1) //AD1_FILIAL+AD1_NROPOR+AD1_REVISA

If AD1->(DbSeek(xFilial("AD1")+ Alltrim(cNroPor + cRevisa )))

	If nOpc == 4
		ALTERA := .T.
	EndIf
	FWExecView( STR0006, "VIEW.FATA300" ,nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/ )
	If nOpc == 4
		AtlzModel()
	EndIf

EndIf

Return .T.

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InicLegend()

Retorna a cor da legenda de acordo com o status da oportunidade.

@sample	InicLegend(cStatus)

@param		ExpC - Código do status da oportunidade

@return	ExpC - Texto da cor da legenda

@author	Aline Kokumai
@since		01/11/2013
@version	11.90
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function InicLegend(cStatus)

Local cRetorno := ""

Do Case 
	Case (cStatus == "1")
		cRetorno := "BR_VERDE"		//Aberto
	Case (cStatus == "2")
		cRetorno := "BR_PRETO"		//Perdido
	Case (cStatus == "3")
		cRetorno := "BR_AMARELO"		//Suspenso
	Case (cStatus == "9")
		cRetorno := "BR_VERMELHO"	//Ganho
 	OtherWise
 		cRetorno := "BR_AZUL"		//Outros
EndCase 

Return ( cRetorno )   

//----------------------------------------------------------------------
/*/{Protheus.doc} AtlzModel()

função para atualizar o model, desativando e ativando novamente, para
passar no bloco de bload

@sample	AtlzModel()

@param	Nenhum

@return	Nenhum

@author	    Victor Bitencourt
@since		01/11/2013
@version	11.90
/*/
//------------------------------------------------------------------------
Static Function AtlzModel()

Local oModel := FWModelActive()

If !Empty(oModel) .AND. oModel:cId == "CRMA080A"
	oModel:DeActivate()
	oModel:Activate()
EndIf

Return