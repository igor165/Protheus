#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA350.CH'

Static aBenefi	:= {}
Static aDadosProd	:= {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TECA350 ºAutor  ³Vendas CRM          º Data ³  13/05/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de Beneficios             					        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TECA350(aProd, lOnlyLoad)

Local aArea := GetArea()
Local nOpc	 := 3
Local nPercReducao := 20
Private n //necessario para a FWINITCPO(PROTHEUSFUNCTIONMVC.PRX)
Default lOnlyLoad := .F. // quando for chamado pelo assistente de implantação é apenas para carregar as variaveis de load (sem dar o execview)

aDadosProd	:= aClone(aProd)

If !lOnlyLoad 
	FWExecView(STR0001,'VIEWDEF.TECA350', 4,/*oDlgBen*/,{||.T.}, /*{|oModel| A600Benefi(oModel)}*/ ,nPercReducao) //"Cadastro"
EndIf

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Vendas e CRM          ³ Data ³ 09/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Definicao do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.TECA350'	OPERATION 1	ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.TECA350'	OPERATION 2	ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.TECA350'	OPERATION 3	ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.TECA350'	OPERATION 4	ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.TECA350'	OPERATION 5	ACCESS 0 //"Excluir"


Return (aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ModelDef  ³ Autor ³Vendas CRM             ³ Data ³09/03/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Definicao do modelo do cadastro Kit de atendimento    (MVC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TECA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local aAux			:= {} //array para auxiliar a criação de gatilhos
Local oModel		:= MPFormModel():New( 'TECA350', , , {|oModel| AT350GRV(oModel) } ) 
Local oStruFake 	:= FWFormModelStruct():New() //estrutura fake - criada apenas porque eh obrigatorio a criacao de um componente de formulario ao modelo
Local oStruProd	:= nil
Local oStruBenef	:= FWFormStruct(1,'ABP') //Cria a estrutura de beneficios
Local aBenef		:= {}
Local nCont		:=0
Local nLinha		:=0
	
	
	oStruBenef:SetProperty( 'ABP_COD' , MODEL_FIELD_INIT , {||At350IniPadrao(oModel, 'ABP_COD')})
	oStruBenef:SetProperty( 'ABP_REVISA' , MODEL_FIELD_INIT , {||At350IniPadrao(oModel, 'ABP_REVISA')})
	oStruBenef:SetProperty( 'ABP_CODPRO' , MODEL_FIELD_INIT , {||At350IniPadrao(oModel, 'ABP_CODPRO')})
	oStruBenef:SetProperty( 'ABP_ENTIDA' , MODEL_FIELD_INIT , {||At350IniPadrao(oModel, 'ABP_ENTIDA')})
	oStruBenef:SetProperty( 'ABP_ITEMPR' , MODEL_FIELD_INIT , {||At350IniPadrao(oModel, 'ABP_ITEMPR')})
	
aAux := FwStruTrigger("ABP_BENEFI","ABP_DESCRI","At350Desc()",.F.,Nil,Nil,Nil)
oStruBenef:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux1 := FwStruTrigger("ABP_VERBA","ABP_DSVERB","At350DescV()",.F.,Nil,Nil,Nil)
oStruBenef:AddTrigger(aAux1[1],aAux1[2],aAux1[3],aAux1[4])


//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------
oStruFake:AddField("Teste", "" ,"ZPA_TESTE", "C", 50 )//Serve apenas para evitar erro: The FWFormViewStruct doesn't have fields associated.
oModel:AddFields( 'MODEL_FAKE',,oStruFake ,,, {|| } )
oModel:GetModel( 'MODEL_FAKE' ):SetDescription("Fake")

//------------------------------------------------
//		Cria a estrutura de produtos manualmente
//------------------------------------------------
oStruProd := FWFormModelStruct():New()
oStruProd:AddTable( "ZPP" , { "ZPP_CODPRO" } , STR0010 )//produto
oStruProd:AddField(STR0007, "" , "ZPP_CODIGO", "C", 6 )//codigo
oStruProd:AddField(STR0008, "" , "ZPP_ENTIDA", "C", 1 ) // endidade
oStruProd:AddField(STR0009, "" ,"ZPP_REVISA", "C", 2 )//revisao
oStruProd:AddField(STR0010, "" , "ZPP_CODPRO", "C", 20 )//produto
oStruProd:AddField(STR0011, "" ,"ZPP_DESC", "C", 50 )//descrição
oStruProd:AddField("Item Prop.","","ZPP_ITEM","",2) //Item da Proposta
oModel:AddGrid( 'MODEL_PROD', 'MODEL_FAKE', oStruProd,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{|| At350ProdLoad(aDadosProd)}/*bLoad*/) 
oModel:GetModel( 'MODEL_PROD' ):SetDescription("Produtos")


//------------------------------------------------
//		beneficios
//------------------------------------------------
// Adiciona ao modelo uma estrutura de formulario de edicao por grid
oModel:AddGrid( 'MODEL_BEN','MODEL_PROD',oStruBenef,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/,/*bLoad*/) // Adiciona uma Grid ao modelo
// Faz relaciomanto entre os compomentes do model
oModel:SetRelation('MODEL_BEN', {{'ABP_FILIAL','xFilial("ABP")'},{'ABP_ITEMPR','ZPP_ITEM'},{'ABP_COD','ZPP_CODIGO'},{'ABP_ENTIDA','ZPP_ENTIDA'},{'ABP_REVISA','ZPP_REVISA'},{'ABP_CODPRO','ZPP_CODPRO'}},ABP->(IndexKey(1)))

oModel:GetModel("MODEL_PROD"):SetNoInsertLine(.T.)
oModel:GetModel("MODEL_PROD"):SetNoUpdateLine(.T.)
oModel:GetModel("MODEL_PROD"):SetNoDeleteLine(.T.)
oModel:GetModel("MODEL_PROD"):SetOnlyQuery(.T.)
oModel:GetModel("MODEL_BEN"):SetOptional( .T. )


oModel:SetDescription(STR0012) //obrigartorio ter alguma descricao//"Análise de Rentabilidade"
oModel:SetPrimaryKey( {'ABP_FILIAL','ABP_COD','ABP_ENTIDA','ABP_REVISA','ABP_CODPRO','ABP_ITEM','ABP_BENEFI' } ) //obrigatorio setar a chave primaria (mesmo que vazia)
	
aSize(aBenefi,0)

Return oModel

/*                               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   º Autor ³ Vendas CRM      º Data ³ 12/03/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define a interface para Manutencao do Kit de          º±±
±±º          ³atendimento(MVC).                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA350                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel   	:= FWLoadModel('TECA350')
Local oStruFake  	:= FWFormViewStruct():New()		//estrutura fake - criada apenas porque eh obrigatorio a criacao de um componente de formulario ao modelo
Local oStruProd	:= Nil
Local oStruBenef	:= FWFormStruct(2,'ABP'  ,{|cCampo| !(AllTrim(cCampo)+"|" $ "ABP_FILIAL|ABP_COD|ABP_REVISA|ABP_CODPRO|ABP_ENTIDA|")}  )

oView:SetModel(oModel)

//----------------------------------------------------------
//		Cria a estrutura da View
//----------------------------------------------------------
oStruProd :=FWFormViewStruct():New()  
oStruProd:AddField('ZPP_CODIGO', '1', STR0017, STR0013, , 'C' )//'Codigo'
oStruProd:AddField('ZPP_ENTIDA', '1', STR0008, STR0014, , 'C' )//'Entidade'
oStruProd:AddField('ZPP_REVISA', '2', STR0009, STR0009, , 'C' )//Revisao
oStruProd:AddField('ZPP_CODPRO', '3', STR0010, STR0015, , 'C' )//'Produto'
oStruProd:AddField('ZPP_DESC', '4', STR0011, STR0016, , 'C' )//Descrição
oStruProd:AddField('ZPP_ITEM','5',"Item da Proposta", "Item da Proposta",,'C')//Item da Proposta
oStruFake:AddField('ZPA_TESTE', '1', 'TESTE', "TESTE do Produto", , 'C' ) //Serve apenas para evitar erro: The FWFormViewStruct doesn't have fields associated.

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model teca350
oView:SetDescription(STR0012) //"Beneficios do Contrato"


//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "SUPERIOR", 50 )  // Box dos produtos
oView:CreateHorizontalBox( "INFERIOR", 50 )  // Box dos beneficios
oView:CreateHorizontalBox( "BOX_FAKE", 0 )  // criado apenas pq o componente de formulario eh vazio, mas precisa estar em algum box (nao pode ser em um box ja utilizado, senao a tela fica vazia)

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField( 'VIEW_FAKE', oStruFake, 'MODEL_FAKE' ) //cria componente associado ao componente de formulario (FAKE) do model
oView:AddGrid( 'VIEW_PROD', oStruProd, 'MODEL_PROD' ) //grid - principal
oView:AddGrid('VIEW_BEN',oStruBenef,'MODEL_BEN' )
oView:AddIncrementField('VIEW_BEN','ABP_ITEM')

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( 'VIEW_FAKE', 'BOX_FAKE' ) 
oView:SetOwnerView( 'VIEW_PROD', 'SUPERIOR' ) // Relaciona o identificador (ID) da View com o "box" para exibição  
oView:SetOwnerView( 'VIEW_BEN','INFERIOR' )


Return (oView)




//-------------------------------------------------------------------
/*/{Protheus.doc} At350ProdLoad()

Faz o carregamento de dados no grid de produtos

@param aDadosProd, array, dados do grid (cCodPro | cDescricao )
@return aRet, array, dados no formato para load do grid
    
@author Vendas CRM
@since 04/02/2013
/*/
//-------------------------------------------------------------------- 
Function At350ProdLoad(aDadosProd)
Local aRet 			:= {}
Local nI := 0

For nI := 1 to Len(aDadosProd)
	Aadd(aRet, { nI,  aDadosProd[nI] } )
Next nI


Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} At350IniPadrao()

Inicializador padrao dos campos de beneficio

@param oView, objeto, view
@return cIdGrid, caractere, Id do grid
    
@author Vendas CRM
@since 04/02/2013
/*/
//-------------------------------------------------------------------- 

Function At350IniPadrao(oModel, cCampo, aBenef, nCont)
Local cRet	:= ''
Default aBenef:= {}
Default nCont:= 1

//Carrega automaticamente o codigo da proposta/contrato no cadastro de beneficio
If cCampo == 'ABP_COD'
	cRet := oModel:GetValue('MODEL_PROD', 'ZPP_CODIGO')
EndIf
//Carrega automaticamente a revisao da proposta no cadastro de beneficio
If cCampo == 'ABP_REVISA'
	cRet := oModel:GetValue('MODEL_PROD', 'ZPP_REVISA')
EndIf
//Carrega automaticamente o código do produto selecionado da proposta no cadastro de beneficio
If cCampo == 'ABP_CODPRO'
	cRet := oModel:GetValue('MODEL_PROD', 'ZPP_CODPRO')
EndIf
//Carrega automaticamente o tipo de entidade
If cCampo == 'ABP_ENTIDA'
	cRet := oModel:GetValue('MODEL_PROD', 'ZPP_ENTIDA')
EndIf
//Carrega automaticamente o item da proposta
If cCampo == 'ABP_ITEMPR'
	cRet := oModel:GetValue('MODEL_PROD', 'ZPP_ITEM')
EndIf

Return cRet



/*                               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At350Desc   º Autor ³ Vendas CRM      º Data ³ 19/10/12º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho da Descrição do Beneficio				         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA350                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function At350Desc()
Local cNome 	:= ""

If !Empty(M->ABP_BENEFI)
	cNome := Alltrim( Posicione("SX5",1,xFilial("SX5")+"AZ"+M->ABP_BENEFI,"X5_DESCRI") )
EndIf

Return( cNome )

/*                               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³At091DescV   º Autor ³ Vendas CRM    º Data ³ 19/10/12º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho da Descrição da Verba					         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TECA350                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function At350DescV()
Local cNome 	:= ""

If !Empty(M->ABP_VERBA)
	cNome := Alltrim( Posicione("SRV",1,xFilial("SRV")+M->ABP_VERBA,"RV_DESC") )
EndIf

Return( cNome )

//-------------------------------------------------------------------
/*/{Protheus.doc} At350Grv()

Carrega Valores dos Benefícios no array aBenefi

@param oModel, objeto, model
@return .T., Lógico
    
@author Gestão de Serviços
@since 27/09/2013
/*/
//-------------------------------------------------------------------- 

Static Function At350Grv( oModel )

Local lRetorno	:= .T.
Local aSaveLines	:= FWSaveRows()
Local oModelAC2	:= oModel:GetModel("MODEL_PROD")
Local nCntFor		:= 0
Local nCnt2		:= 0
Local aLinha		:= {}
Local nIni			:= 1

aBenefi := {}
//Atribui no array os diversos valores da relação item da proposta com seus Benefícios
For nCntFor := 1 To oModelAC2:Length()					
	oModelAC2:GoLine(nCntFor)
	aLinha := aClone(oModel:GetModel("MODEL_BEN"):GetOldData())
	If Len(aBenefi)==0
		AAdd(aBenefi,aLinha[1])  //o primeiro valor do aBenefi é o header do MODEL_BEN, estes valores são utilizados no FATA600 para gravação dos benefícios
	EndIf 
	AAdd(aBenefi,aLinha[2])
Next nCntFor

FWModelActive( oModel )
FWFormCommit( oModel )

FwRestRows(aSaveLines)	
	
Return .T. 

