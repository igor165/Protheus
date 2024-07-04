#include "CRMA010A.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW		2 


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados da Consulta Previsão de Vendas.

@sample		ModelDef()

@param			Nenhum

@return		ExpO - Objeto MPFormModel

@author		Aline Kokumai
@since			14/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStructFke	:= FWFormModelStruct():New()
Local oStructZYX	:= Nil
Local bCarga 		:= {|| }
Local aOpcStatus	:= {}
Local cTxtStatus	:= ""
Local cVlrStatus	:= ""
Local nX			:= 0

// Cria as estruturas fake ZYX do tipo model para receber os dados das oportunidades
oStructZYX := FWFormModelStruct():New()
oStructZYX:AddTable("ZYX",{},STR0127) //"Oportunidades"
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
oStructFke:AddField(STR0002,STR0001,"ZFK_FILIAL","C",FwSizeFilial(),0)//"Filial do Sistema"//"Filial"

//Instancia o modelo de dados
oModel := MPFormModel():New("CRMA010A",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Adiciona os campos no modelo de dados Model / ModelGrid
oModel:AddFields("MASTER", /*cOwner*/,oStructFke,/*bPreValidacao*/,/*bPosValidacao*/,bCarga)
oModel:AddGrid("ZYXDETAIL","MASTER",oStructZYX,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

aOpcStatus := StrTokArr(TxSX3Campo("AD1_STATUS")[7],";")

//Campos calculados total de receita por status
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__GERAL","SUM",/*bCond*/,/*bInitValue*/,STR0003,/*bFormula*/)//"Total Geral"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__ABERTA","SUM",{|oModel| VrfCondSta(oModel,"1")},/*bInitValue*/,STR0004,/*bFormula*/)//"Total Aberta"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__PERDIDA","SUM",{|oModel| VrfCondSta(oModel,"2")},/*bInitValue*/,STR0005,/*bFormula*/)//"Total Perdida"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__GANHA","SUM",{|oModel| VrfCondSta(oModel,"9")},/*bInitValue*/,STR0007,/*bFormula*/)//"Total Ganha"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__FECH","SUM",{|oModel| VrfPrvFech(oModel)},/*bInitValue*/,STR0008,/*bFormula*/)//"Não Fechadas"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__P7DI","SUM",{|oModel| VrfPrv7dia(oModel)},/*bInitValue*/,STR0009,/*bFormula*/)//"Prev. Fech. Próximos 7 Dias"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__U7DI","SUM",{|oModel| VrfUlt7dia(oModel)},/*bInitValue*/,STR0010,/*bFormula*/)//"Ganhas nos Últimos 7 Dias"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__FMES","SUM",{|oModel| VrfFechMes(oModel,"1")},/*bInitValue*/,STR0011,/*bFormula*/)//"Previstas p/ Fechar Neste Mês"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__GMES","SUM",{|oModel| VrfFechMes(oModel,"9")},/*bInitValue*/,STR0012,/*bFormula*/)//"Ganhas Neste Mês"
oModel:AddCalc("CALC_TOTAL_STATUS","MASTER","ZYXDETAIL","ZYX_VALOR","ZYX__PMES","SUM",{|oModel| VrfFechMes(oModel,"2")},/*bInitValue*/,STR0013,/*bFormula*/)//"Perdidas Neste Mês"
	
	
//Configura as propriedades do modelo de dados
oModel:GetModel("MASTER"):SetOnlyView(.T.)
oModel:GetModel("MASTER"):SetOnlyQuery(.T.)

oModel:GetModel("ZYXDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("ZYXDETAIL"):SetOptional(.T.)
oModel:GetModel("ZYXDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("ZYXDETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("MASTER"):SetDescription("Struct Fake")
oModel:SetDescription(STR0014)//"Consulta"
                                                  
oModel:SetPrimaryKey({})

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface da Consulta Previsão de Vendas.

@sample		ViewDef()

@param			Nenhum

@return		ExpO - Objeto FWFormView

@author		Aline Kokumai
@since			14/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:=	Nil
Local oModel		:=	FWLoadModel( 'CRMA010A' )
Local oStructZYX	:=	Nil
Local oRecPorSta	:=	Nil									//Total da Receita por Status
Local nX	:= 0

// Cria as estruturas fake ZYX DO tipo view para receber os dados das oportunidades
oStructZYX := FWFormViewStruct():New()
MntScruct(oStructZYX,"ZYX",TYPE_VIEW)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddGrid("VIEW_ZYX",oStructZYX,"ZYXDETAIL")

oRecPorSta := FWCalcStruct(oModel:GetModel("CALC_TOTAL_STATUS")) 

oView:AddField("VIEW_TOTALIZADORES",oRecPorSta,"CALC_TOTAL_STATUS")
 
oView:AddUserButton( STR0126, 'Configurar Filtros', { || FilTmVends(,,,.T.) } )  //"Configurar Filtros"

// Grid com as Oportunidades
oView:CreateHorizontalBox("OPORTUNIDADE",80)
oView:EnableTitleView("VIEW_ZYX",STR0127) //"Oportunidades"
oView:SetOwnerView("VIEW_ZYX","OPORTUNIDADE")
oView:SetViewProperty("VIEW_ZYX","ENABLENEWGRID")

// Espaço dos Totalizadores
oView:CreateHorizontalBox("TOTAL",20)
oView:EnableTitleView("VIEW_TOTALIZADORES",STR0015)//"Totalizadores"
oView:SetOwnerView("VIEW_TOTALIZADORES","TOTAL")

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
@since		16/10/2013
@version	11.90               
/*/
//------------------------------------------------------------------------------
Static Function MntScruct(oStruct,cAliasFake,nType)

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

	// Cabeçalho
	If cAliasFake == "ZYX"
		
		// Legenda da oportunidade
		oStruct:AddField("","","ZYX_LEGEND","C",1,0,Nil,Nil,Nil,Nil,{|| InicLegend((cAlias)->ZYX_CODSTA)},Nil,Nil,.T.)
		
		// Campos dados para transferencia
		aDadosCpo := TxSX3Campo("AD1_FILIAL")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0016),"ZYX_FILIAL",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Filial"
		
		aDadosCpo := TxSX3Campo("AD1_NROPOR")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0017),"ZYX_NROPOR",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Número da Oportunidade de Venda"

		aDadosCpo := TxSX3Campo("AD1_DESCRI")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0018),"ZYX_DESCRI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Descrição"
		
		oStruct:AddField(AllTrim(STR0019),AllTrim(STR0019),"ZYX_ENTIDA","C",7,Nil)		//"Entidade"
		
		oStruct:AddField(AllTrim(STR0021),AllTrim(STR0022),"ZYX_CONTA","C",6,Nil)       //"Cod. Conta"//"Código da Conta"
		
		oStruct:AddField(AllTrim(STR0024),AllTrim(STR0023),"ZYX_LOJA","C",2,Nil)   		//"Loja"//"Loja da Conta"
		
		oStruct:AddField(AllTrim(STR0027),AllTrim(STR0026),"ZYX_CTNOME","C",40,Nil,,,,,{|| IIF(AllTrim((cAlias)->ZYX_ENTIDA)==AllTrim(STR0025),;//"CLIENTE"//"Nome da Conta"//"Nome"
																			Posicione("SA1",1,xFilial("SA1")+(cAlias)->ZYX_CONTA+(cAlias)->ZYX_LOJA,"A1_NOME"),;
																			Posicione("SUS",1,xFilial("SUS")+(cAlias)->ZYX_CONTA+(cAlias)->ZYX_LOJA,"US_NOME"))},,,.T.)          	   	
		
		aDadosCpo := TxSX3Campo("AD1_STATUS")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0028),"ZYX_STATUS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,StrTokArr(aDadosCpo[7],";"))              //"Status da Oportunidade"
		
		oStruct:AddField(AllTrim(STR0029),AllTrim(STR0030),"ZYX_CODSTA","C",2,Nil)//"Cod. Status"//"Valor do Status"
		
		aDadosCpo := TxSX3Campo("AD1_DTINI")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0031),"ZYX_DTINI",aDadosCpo[6],10,aDadosCpo[4])              	//"Data de Início"
		
		oStruct:AddField(AllTrim(STR0033),AllTrim(STR0032),"ZYX_DTFIM","D",10,Nil)   //"Data de Encerramento"//"Dt. Encer."
		
		oStruct:AddField(AllTrim(STR0034),AllTrim(STR0035),"ZYX_RECEIT","N",12,2)  //"Rc. Total"//"Receita Total da Oportunidade"
		
		aDadosCpo := TxSX3Campo("AD2_PERC")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0036),"ZYX_PERC",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])  //"Porcentagem de Participação do Vendedor"
		
		oStruct:AddField(AllTrim(STR0037),AllTrim(STR0038),"ZYX_VALOR","N",12,2)         //"Partic. Receita"//"Valor de Participação do Vendedor na Receita"
				
       aDadosCpo := TxSX3Campo("AD2_VEND")
		oStruct:AddField(AllTrim(STR0039),AllTrim(STR0040),"ZYX_VEND",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])  //"Cod. Vendedor"//"Código do Vendedor"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField(AllTrim(STR0041),AllTrim(STR0042),"ZYX_NOME",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("SA3",1,xFilial("SA3")+(cAlias)->ZYX_VEND,"A3_NOME")},,,.T.)              //"Nm. Vendedor"//"Nome do Vendedor"
		
		aDadosCpo := TxSX3Campo("AD1_RCINIC")		
		oStruct:AddField(AllTrim(aDadosCpo[1]),STR0128,"ZYX_RCINIC",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Previsão Inicial"
	
		aDadosCpo := TxSX3Campo("AD1_RCFECH")		
		oStruct:AddField(AllTrim(aDadosCpo[1]),STR0129,"ZYX_RCFECH",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4]) //"Receita Estimada de Fechamento"
		
		If	AD2->(FieldPos("AD2_UNIDAD")) > 0
	       aDadosCpo := TxSX3Campo("AD2_UNIDAD")
			oStruct:AddField(AllTrim(STR0043),AllTrim(STR0044),"ZYX_UNIDAD",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Cod. Unidade"//"Código da Unidade"
			
			aDadosCpo := TxSX3Campo("ADK_NOME")
			oStruct:AddField(AllTrim(STR0045),AllTrim(STR0046),"ZYX_DSCUNID",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("ADK",1,xFilial("ADK")+(cAlias)->ZYX_UNIDAD,"ADK_NOME")},,,.T.)//"Desc. Unidade"//"Descrição da Unidade"
		EndIf 	
		
		If	AD2->(FieldPos("AD2_RESPUN")) > 0
			aDadosCpo := TxSX3Campo("AD2_RESPUN")
			oStruct:AddField(AllTrim(STR0047),AllTrim(STR0048),"ZYX_RESPUN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Cod. Resp."//"Código do Responsável pela Unidade"
			
			aDadosCpo := TxSX3Campo("A3_UNIDAD")
			oStruct:AddField(AllTrim(STR0049),AllTrim(STR0050),"ZYX_NRESUN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("SA3",1,xFilial("SA3")+(cAlias)->ZYX_RESPUN,"A3_NOME")},,,.T.)//"Nome Resp."//"Nome do Responsável pela Unidade"
		EndIf
		
		aDadosCpo := TxSX3Campo("AD1_FCS")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0051),"ZYX_FCS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])     //"FCS"
		
		aDadosCpo := TxSX3Campo("AD1_DESFCS")
		oStruct:AddField(AllTrim(STR0052),AllTrim(STR0053),"ZYX_DESFCS",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+(cAlias)->ZYX_FCS,"X5DESCRI()"))},,,.T.)        //"Desc. FCS"//"Descrição FCS"
		
		aDadosCpo := TxSX3Campo("AD1_FCI")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0054),"ZYX_FCI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              //"FCI"

		aDadosCpo := TxSX3Campo("AD1_DESFCI")
		oStruct:AddField(AllTrim(STR0055),AllTrim(STR0056),"ZYX_DESFCI",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+(cAlias)->ZYX_FCI,"X5DESCRI()"))},,,.T.)        //"Desc. FCI"//"Descrição FCI"
				
		aDadosCpo := TxSX3Campo("AD1_FEELIN")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0057),"ZYX_FEELIN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])              	//"Chance de Sucesso"
		
		aDadosCpo := TxSX3Campo("AD1_PROVEN")
		oStruct:AddField(AllTrim(STR0058),AllTrim(STR0059),"ZYX_PROVEN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Cod. Processo"//"Código do Processo de Vendas"
		
		aDadosCpo := TxSX3Campo("AC1_DESCRI")
		oStruct:AddField(AllTrim(STR0060),AllTrim(STR0061),"ZYX_DESCPR",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("AC1",1,xFilial("AC1")+(cAlias)->ZYX_PROVEN,"AC1_DESCRI")},,,.T.)              //"Desc. Processo"//"Descrição do Processo de Vendas"
				
  		aDadosCpo := TxSX3Campo("AD1_STAGE")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0062),"ZYX_STAGE",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])//"Código do Estágio da Venda"
		
		aDadosCpo := TxSX3Campo("AC2_DESCRI")
		oStruct:AddField(AllTrim(STR0063),AllTrim(STR0064),"ZYX_DESCES",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| Posicione("AC2",1,xFilial("AC2")+(cAlias)->ZYX_PROVEN+(cAlias)->ZYX_STAGE,"AC2_DESCRI")},,,.T.)//"Desc. Estágio"//"Descrição do Estágio da Venda"
		
		aDadosCpo := TxSX3Campo("AD1_PERCEN")
		oStruct:AddField(AllTrim(aDadosCpo[1]),AllTrim(STR0065),"ZYX_PERCEN",aDadosCpo[6],aDadosCpo[3],aDadosCpo[4],,,,,{|| FT300PERC( (cAlias)->ZYX_PROVEN,(cAlias)->ZYX_STAGE )},,,.T.)  //"Percentual de Conclusão do Processo de Vendas"
		
	EndIf                                   
	
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
	
	If cAliasFake == "ZYX"
	
		// Campo de marca da tabela SA3 - vendedores
		oStruct:AddField("ZYX_LEGEND","01","","",{},"C","@BMP",{||},Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	
		aDadosCpo := TxSX3Campo("AD1_NROPOR")
		oStruct:AddField("ZYX_NROPOR","01",aDadosCpo[1],aDadosCpo[2],{STR0066},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE")//"Número da Oportunidade de Venda"
		
		aDadosCpo := TxSX3Campo("AD1_DESCRI")
		oStruct:AddField("ZYX_DESCRI","02",aDadosCpo[1],aDadosCpo[2],{STR0067},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Descrição da Oportunidade"

		oStruct:AddField("ZYX_ENTIDA","03",STR0068,STR0068,{STR0068},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")		//STR0069//STR0070//"Entidade"

		oStruct:AddField("ZYX_CONTA","04",STR0071,STR0072,{STR0072},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Cod. Conta"//STR0073//"Código da Conta"
		
		oStruct:AddField("ZYX_LOJA","05",STR0076,STR0074,{STR0074},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//STR0075//"Loja da Conta"//"Loja"
		
		oStruct:AddField("ZYX_CTNOME","06",STR0079,STR0077,{STR0077},"C","@!",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE",,,,,,,,,,FATPDIsObfuscate("A1_NOME",NIL,.T.))//STR0078//"Nome da Conta"//"Nome"
		
		aDadosCpo := TxSX3Campo("AD1_STATUS")
		oStruct:AddField("ZYX_STATUS","07",aDadosCpo[1],aDadosCpo[2],{STR0080},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Código da Conta"
		
		aDadosCpo := TxSX3Campo("AD1_DTINI")
		oStruct:AddField("ZYX_DTINI","08",aDadosCpo[1],aDadosCpo[2],{STR0081},aDadosCpo[6],Nil,Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Data de Início da Oportunidade"
		
		oStruct:AddField("ZYX_DTFIM","10",STR0084,STR0083,{STR0082},"D",Nil,Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Data de Encerramento da Oportunidade"//"Data de Encerramento"//"Dt. Encer."
			
		oStruct:AddField("ZYX_RECEIT","11",STR0085,STR0087,{STR0086},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE") //"Rc. Total"//"Receita Total da Oportunidade"//"Receita Total"
		  
		aDadosCpo := TxSX3Campo("AD2_PERC")
		oStruct:AddField("ZYX_PERC","12",aDadosCpo[1],aDadosCpo[2],{STR0088},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Porcentagem de Participação do Vendedor"
		
		oStruct:AddField("ZYX_VALOR","13",STR0089,STR0090,{STR0091},"N","@E 999,999,999.99",Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")   //"Partic. Receita"//"Participação Receita"//"Valor de Participação do Vendedor na Receita"
		
		aDadosCpo := TxSX3Campo("AD2_VEND")
		oStruct:AddField("ZYX_VEND","14",STR0092,STR0093,{STR0093},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")   //"Cod. Vendedor"//STR0094//"Código do Vendedor"
		
		aDadosCpo := TxSX3Campo("A3_NOME")
		oStruct:AddField("ZYX_NOME","15",STR0095,STR0096,{STR0096},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE",,,,,,,,,,FATPDIsObfuscate("A3_NOME",NIL,.T.))	//"Nm. Vendedor"//STR0097//"Nome do Vendedor"
		
		aDadosCpo := TxSX3Campo("AD1_RCINIC")		
		oStruct:AddField("ZYX_RCINIC","16",aDadosCpo[1],aDadosCpo[2],{STR0128},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE") //"Previsão Inicial"
	
		aDadosCpo := TxSX3Campo("AD1_RCFECH")		
		oStruct:AddField("ZYX_RCFECH","17",aDadosCpo[1],aDadosCpo[2],{STR0129},aDadosCpo[6],aDadosCpo[5] ,Nil,Nil,.F.,Nil ,"GRP_OPORTUNIDADE") //"Receita Estimada de Fechamento"
		
		If	AD2->(FieldPos("AD2_UNIDAD")) > 0
			aDadosCpo := TxSX3Campo("AD2_UNIDAD")
			oStruct:AddField("ZYX_UNIDAD","18",STR0098,STR0099,{STR0099},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Cod. Unidade"//STR0100//"Código da Unidade"
			
			aDadosCpo := TxSX3Campo("ADK_NOME")
			oStruct:AddField("ZYX_DSCUNID","19",STR0101,STR0102,{STR0102},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Desc. Unidade"//STR0103//"Descrição da Unidade"
		EndIf
		
		If	AD2->(FieldPos("AD2_RESPUN")) > 0
			aDadosCpo := TxSX3Campo("AD2_RESPUN")
			oStruct:AddField("ZYX_RESPUN","20",STR0104,STR0106,{STR0105},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Cod. Resp."//"Código do Responsável pela Unidade"//"Código do Responsável"
			
			aDadosCpo := TxSX3Campo("A3_NOME")
			oStruct:AddField("ZYX_NRESUN","21",STR0107,STR0109,{STR0108},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE",,,,,,,,,,FATPDIsObfuscate("A3_NOME",NIL,.T.))//"Nome Resp."//"Nome do Responsável pela Unidade"//"Nome do Responsável"
		EndIf
		
		aDadosCpo := TxSX3Campo("AD1_FCS")
		oStruct:AddField("ZYX_FCS","22",aDadosCpo[1],aDadosCpo[2],{STR0110},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Fator Crítico de Sucesso"
		
		aDadosCpo := TxSX3Campo("AD1_DESFCS")
		oStruct:AddField("ZYX_DESFCS","23",STR0111,STR0112,{STR0113},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. FCS"//"Descrição FCS"//"Descrição do Fator Crítico de Sucesso"
		
		aDadosCpo := TxSX3Campo("AD1_FCI")
		oStruct:AddField("ZYX_FCI","24",aDadosCpo[1],aDadosCpo[2],{STR0114},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil,"GRP_OPORTUNIDADE")//"Fator Crítico de Insucesso"
		
		aDadosCpo := TxSX3Campo("AD1_DESFCI")
		oStruct:AddField("ZYX_DESFCI","25",STR0115,STR0116,{STR0117},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. FCI"//"Descrição FCI"//"Descrição do Fator Crítico de Insucesso"
		
		aDadosCpo := TxSX3Campo("AD1_FEELIN")
		oStruct:AddField("ZYX_FEELIN","26",aDadosCpo[1],aDadosCpo[2],{STR0118},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")          //"Chance de Sucesso"
		                            
		aDadosCpo := TxSX3Campo("AD1_PROVEN")
		oStruct:AddField("ZYX_PROVEN","27",aDadosCpo[1],aDadosCpo[2],{STR0119},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")          //"Código do Processo de Vendas"
		
		aDadosCpo := TxSX3Campo("AC1_DESCRI")
		oStruct:AddField("ZYX_DESCPR","28",STR0120,aDadosCpo[2],{STR0121},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. Processo"//"Descrição do Processo de Vendas"
		
		aDadosCpo := TxSX3Campo("AD1_STAGE")
		oStruct:AddField("ZYX_STAGE","29",aDadosCpo[1],aDadosCpo[2],{STR0122},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")       //"Código do Estágio da Venda"

		aDadosCpo := TxSX3Campo("AC2_DESCRI")
		oStruct:AddField("ZYX_DESCES","30",STR0123,aDadosCpo[2],{STR0124},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Desc. Estágio"//"Descrição do Estágio da Venda"
		
		aDadosCpo := TxSX3Campo("AD1_PERCEN")
		oStruct:AddField("ZYX_PERCEN","31",aDadosCpo[1],aDadosCpo[2],{STR0125},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.T.,Nil,"GRP_OPORTUNIDADE")//"Percentual de Conclusão do Processo de Vendas"
				             	    
	EndIf
	
EndIf
 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} VrfCondSta

Função para validar o status da oportunidade na geração dos campos calculados.

@sample		VrfCondSta(oModel,cCodStatus)

@param			ExpO - Objeto MPFormModel
				ExpO - Código do status da oportunidade

@return		ExpL - Verdadeiro ou Falso

@author		Aline Kokumai
@since			22/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function VrfCondSta(oModel,cCodStatus)

Local lRet := .F.

If oModel:GetValue('ZYXDETAIL','ZYX_CODSTA') == cCodStatus
	lRet := .T.
EndIf

Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} VrfPrvFech

Função para validar as oportunidades aberta que ultrapassaram o encerramento.

@sample		VrfPrvFech(oModel)

@param			ExpO -  Objeto MPFormModel

@return		ExpL -  Verdadeiro ou Falso

@author		Aline Kokumai
@since			22/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function VrfPrvFech(oModel)

Local lRet := .F.

If oModel:GetValue('ZYXDETAIL','ZYX_CODSTA') == "1" .AND. oModel:GetValue('ZYXDETAIL','ZYX_DTFIM') < MSDate()
	lRet := .T.
EndIf

Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} VrfPrv7dia

Função para validar as oportunidades abertas previstas para fechar nos próximos 7 dias.

@sample		VrfPrv7dia(oModel)

@param			ExpO -  Objeto MPFormModel

@return		ExpL -  Verdadeiro ou Falso

@author		Aline Kokumai
@since			23/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function VrfPrv7dia(oModel)

Local lRet 		:= .F.
Local oDtPrvEnc	:= TMKDateTime():New()
Local dDtPrvEnc	:= cTod("//")		

oDtPrvEnc	:= TMKDateTime():This(MsDate())
dDtPrvEnc	:= oDtPrvEnc:getDate(oDtPrvEnc:plusDays(7)) //Adiciona 7 dias após a data atual do sistema

If	oModel:GetValue('ZYXDETAIL','ZYX_CODSTA') == "1" .AND. oModel:GetValue('ZYXDETAIL','ZYX_DTFIM') >= MSDate();
	.AND. oModel:GetValue('ZYXDETAIL','ZYX_DTFIM') <= dDtPrvEnc 
	lRet := .T.
EndIf

Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} VrfUlt7dia

Função para validar as oportunidades ganhas fechadas nos últimos 7 dias.

@sample		VrfUlt7dia(oModel)

@param			ExpO -  Objeto MPFormModel

@return		ExpL - Verdadeiro ou Falso

@author		Aline Kokumai
@since			23/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function VrfUlt7dia(oModel)

Local lRet 	:= .F.
Local oDtFech	:= TMKDateTime():New()
Local dDtFech	:= cTod("//")		

oDtFech	:= TMKDateTime():This(MsDate())
dDtFech	:= oDtFech:getDate(oDtFech:minusDays(7)) //Diminui 7 dias após a data atual do sistema

If	oModel:GetValue('ZYXDETAIL','ZYX_CODSTA') == "9" .AND. oModel:GetValue('ZYXDETAIL','ZYX_DTFIM') >= dDtFech;
	.AND. oModel:GetValue('ZYXDETAIL','ZYX_DTFIM') <= MSDate()
	lRet := .T.
EndIf

Return ( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} VrfFechMes

Função para validar as oportunidades para fechar no mês da database do sistema de 
acordo com o status.

@sample		VrfFechMes(oModel,cStatus)

@param			ExpO -  Objeto MPFormModel
				ExpC -  Código do status da oportunidade

@return		ExpL - Verdadeiro ou Falso

@author		Aline Kokumai
@since			23/10/2013
@version		11.90
/*/
//------------------------------------------------------------------------------
Static Function VrfFechMes(oModel,cStatus)

Local lRet 		:= .F.
Local oDtMesCor	:= TMKDateTime():New
Local nMesCor		:= 0
Local nAnoCor		:= 0
Local oData		:= TMKDateTime():New()
Local dData		:= oModel:GetValue('ZYXDETAIL','ZYX_DTFIM')
Local nMesData	:= 0
Local nAnoData	:= 0

oData		:= 	TMKDateTime():This(dData) 
nMesData	:= 	oData:getMonth(oData)			//Mês da data de fechamento da oportunidade
nAnoData	:= 	oData:getYear(oData)				//Ano da data de fechamento da oportunidade

oDtMesCor	:= 	TMKDateTime():This(MsDate())
nMesCor	:= oDtMesCor:getMonth(oDtMesCor) 	//Mês da data corrente do sistema
nAnoCor	:= oDtMesCor:getYear(oDtMesCor)		//Ano da data corrente do sistema
												
If	oModel:GetValue('ZYXDETAIL','ZYX_CODSTA') == cStatus .AND. nMesData == nMesCor;
	.AND. nAnoData == nAnoCor
	lRet := .T.
EndIf

Return ( lRet )

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InicLegend()

Retorna a cor da legenda de acordo com o status da oportunidade.

@sample	InicLegend(cStatus)

@param		ExpC - Código do status da oportunidade

@return	ExpC - Texto da cor da legenda

@author	Aline Kokumai
@since		24/10/2013
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

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive
