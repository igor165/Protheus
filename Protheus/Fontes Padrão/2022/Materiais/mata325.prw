#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'MATA325.CH'
#INCLUDE 'FWMVCDEF.CH'               
#INCLUDE "PRCONST.CH"
#INCLUDE "msgraphi.ch"

Static lMsg := .T. //variavel para mostrar a mensagem de pre็o sugerido apenas uma vez, a valida็ใo do campo ้ chamada diretamente pelo framework          
Static l325Perg
Static cCodPlan
Static cCodRev
Static lNewInt
Static lForm2 := SuperGetMV("MV_REVPLAN",.F.,.F.) .And. FindFunction("MC010FORM2")
Static aMTC010 //variavel para que nใo seja necessario chamar o pergunte repetidas vezes em fun็ใo da performance
Static aMTA325 //variavel para que nใo seja necessario chamar o pergunte repetidas vezes em fun็ใo da performance

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMata325        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta rotina tem o objetivo de permitir a inclusใo, altera็ใo,    บฑฑ
ฑฑบ          ณexclusใo e efetiva็ใo uma publica็ใo de pre็os           	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Mata325() 
Local oBrw := FWMBrowse():New() //objeto FWMBrowse     

oBrw:SetAlias("SAX")
oBrw:SetDescription(STR0001) //"Publica็๕es de Pre็os"
	       
oBrw:AddLegend( "AX_EFETIVO=='1'", "RED"   , STR0002 )  //"Efetivada"
oBrw:AddLegend( "AX_EFETIVO=='2'", "YELLOW", STR0003 ) //"Parcialmente efetivada"
oBrw:AddLegend( "AX_EFETIVO=='3'", "GREEN" , STR0004 ) //"Em elabora็ใo"

oBrw:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oBrw:DisableDetails()
oBrw:Activate()
		
Return Nil   
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325ValPrd     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar a inclusใo do produto                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoModel - objeto model do MVC									   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325ValPrd() 
Local lRet  	 := .T.  //Flag de retorno   
Local oModel    := FWModelActive()
Local nOperacao := oModel:GetOperation() //Controle de operacao
Local cProd   	 := M->AY_PRODUTO
If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProd))       
		If !IsInCallStack("A325AddPrd")
			A325IntPlan()
		EndIf		
	Else
		Alert(STR0005) //"Produto nใo cadastrado!"
		lRet := .F.
	EndIf		
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMenuDef        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefini็ใo do menu do browse                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}         //Declaracao da aRotina
Local lGEPRE  := SuperGetMv('MV_LJGEPRE',,.F.) //Uso do parametro MV_LJGEPRE

ADD OPTION aRotina TITLE STR0006 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.MATA325' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.MATA325' OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.MATA325' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.MATA325' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.MATA325' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.MATA325' OPERATION 8 ACCESS 0  //'Imprimir'
ADD OPTION aRotina TITLE STR0065 ACTION 'M325Legend' 	  OPERATION 9 ACCESS 0  //'Legenda'

If !lGEPRE
	ADD OPTION aRotina TITLE STR0013   ACTION 'A325ESAX' OPERATION 4 ACCESS 0  //'Efetivar' 
EndIf

ADD OPTION aRotina TITLE STR0072 ACTION 'M325Painel' 	  OPERATION 10 ACCESS 0  //"Painel Forma็ใo de Pre็o"

Return aRotina                                                   
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณModelDef       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefini็ใo do objeto Model                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local oStruSAX := FWFormStruct( 1, "SAX")    //objeto contendo a estrutura da tabela SAX
Local oStruSAY := FWFormStruct( 1, "SAY",  { |cCampo| cCampo <> "AY_CODIGO" }) //objeto contendo a estrutura da tabela SAY                                                             

Local oModel   := nil //objeto model

#IFDEF TOP

	oStruSAY:SetProperty('AY_PRODUTO',MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A325ValPrd()") )      
	oStruSAY:AddTrigger( "AY_PRODUTO", "AY_DESCRI", {|| .T.},;
								 {|oModel| Padr(Posicione("SB1",1,xFilial("SB1") + oModel:GetValue("AY_PRODUTO"), "B1_DESC"),TamSx3("AY_DESCRI")[1]) } )
	
	If SuperGetMv('MV_LJGEPRE',,.F.)
		oModel := MPFormModel():New("MATA325",, {|| IIF(A325VLDGRD(oModel),A325GRVSAZ(oModel),)},{|oModel| MA325Commit(oModel)} )   
	Else                                                                       
		oModel := MPFormModel():New("MATA325",, {|| A325VLDGRD(oModel)},{|oModel| MA325Commit(oModel)})   
	EndIf    
	
	//-- Cria campos de integra็ใo 
	CposForm(oStruSAY,.T.,oModel)
	
	oModel:AddFields("SAXMASTER",,oStruSAX)
	
	
	oModel:AddGrid("SAYDETAIL","SAXMASTER",oStruSAY )                                    
	                                                             
	oModel:SetRelation( 'SAYDETAIL', { { 'AY_FILIAL', 'xFilial( "SAY" )' }, { 'AY_CODIGO', 'AX_CODIGO' } }, SAY->( IndexKey(2) ))
	                        
	oModel:GetModel( 'SAYDETAIL' ):SetUniqueLine( { 'AY_PRODUTO' } )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription(STR0014) //'Publica็ใo de Pre็os'
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'SAXMASTER' ):SetDescription( STR0015 ) //'Publica็๕es de Pre็os'
	oModel:GetModel( 'SAYDETAIL' ):SetDescription( STR0016 ) //'Itens das Publica็๕es de Pre็os'
	
	oModel:bActivate := {|oModel| A325Perg(oModel) }
	oModel:SetDeActivate( { | oModel | A325DeAct( oModel ) } )
	oModel:SetVldActivate( { | oModel | A325TPRE( oModel ) } )

#ENDIF
Return oModel 

Function A325DeAct( oModel )
l325Perg := Nil
cCodPlan := Nil
cCodRev  := Nil
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณViewDef        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefini็ใo do objeto View                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

Local aBtnAR := {}	//Variแvel usada para cria็ใo de botใo personalizado pelo PE FT325BTNAR

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruSAX := FWFormStruct( 2, 'SAX' )  //objeto contendo estrutura da tabela SAX
Local oStruSAY := FWFormStruct( 2, 'SAY',  { |cCampo| cCampo<>"AY_CODIGO" } ) //objeto contendo estrutura da tabela SAY

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'MATA325' )  //declara็ใo do objeto Model
Local oView    := Nil                       //declara็ใo do objeto View

#IFDEF TOP

	CposForm(oStruSAY,.F.,oModel)
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados serแ utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SAX', oStruSAX, 'SAXMASTER' )
	
	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_SAY', oStruSAY, 'SAYDETAIL' )
	
	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_SAY', 'AY_ITEM' )
	                                                 
	// Criar novo botao na barra de botoes
	oView:AddUserButton( STR0017  , "VERNOTA"  , { |oView| A325DetPrd(oView) } )  //'Detalhes do produto'
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'UP'  , 30 ) //SUPERIOR                                                                           
	
	
	oView:CreateHorizontalBox( 'DOWN', 70 ) //INFERIOR
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SAX', 'UP'  )
	oView:SetOwnerView( 'VIEW_SAY', 'DOWN' )
	
	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_SAX', STR0063 ) //Publica็ใo                                                                  
	oView:EnableTitleView( 'VIEW_SAY', STR0064) //Itens da Publica็ใo
	
	//-------------------------------------------------------------
	// Ponto de entrada para inserir botใo personalizado
	// no menu de a็๕es relacionadas
	//-------------------------------------------------------------
	If ( ExistBlock("FT325BTNAR") )
		aBtnAR := ExecBlock("FT325BTNAR", .F., .F.)
		If ( Len(aBtnAR) > 0 )
			oView:AddUserButton( aBtnAR[1], "", aBtnAR[2] )	//"Confirma็ใo Parcial"
		EndIf
	EndIf
#ELSE
  
	Help(" ",1,STR0001,,STR0112,3 )	//##"Publica็๕es de Pre็os"##"Rotina nใo compativel com ambiente CodeBase."
    
#ENDIF                   
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325DetPrd     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApresentar dados gerenciais do produto                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoView - Objeto View do MVC   									   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325DetPrd(oView)
Local cPrd 		 :=  oView:GetValue("SAYDETAIL","AY_PRODUTO") //Produto selecionado
Local cDesc     :=  oView:GetValue("SAYDETAIL","AY_DESCRI")  //Descri็ใo do Produto
Local cGrpFil	 :=  oView:GetValue("SAXMASTER","AX_GRUPFIL") //Grupo de Filiais            
Local aDados	 := {}//dados dos produtos
Local aCabBrw   := {STR0018,STR0019,STR0020,STR0022,; //"Filial"###"Ult. Prc Compra"###"Ult. Custo Compra"###"Markup"###"Qtd. Vendida"
                    STR0023,STR0024,STR0025,STR0026}  //Cabe็alho da TwBrowse                                      //"Valor Vendido"###"Venda/Dia"###"Saldo Estoque"###"Dias Estoque"
Local oDlg	    := Nil //Objeto Dialog
Local oFWLayer  := FWLayer():new() //Objeto FWLayer
Local oPnl1		 := Nil //painel superior
Local oPnl2		 := Nil //painel inferior
Local oTwBrw	 := Nil //Objeto TWBrowse    

If SB1->(FieldPos("B1_MARKUP")) > 0
	aAdd(aCabBrw,STR0021)
EndIf
	         
If Empty(cPrd)
	Alert(STR0027) //"Nenhum produto informado."
	Return .F.
ElseIf Empty(cGrpFil)
	Alert(STR0028) //"Grupo de Filiais nใo informado."
	Return .F.
EndIf
	
aDados := DadosPrd(cPrd,cGrpFil)
	
DEFINE MSDIALOG oDlg TITLE STR0029 FROM 000,000 TO oMainWnd:nBottom/2, oMainWnd:nRight-(0.10 * oMainWnd:nRight) Pixel of oMainWnd PIXEL //"Tipos de produto"
				       		
oFWLayer:init(oDlg,.T.)	
			 
oFWLayer:AddLine( 'UP', 10, .F. )                      // Cria uma "linha" com 10% da tela
oFWLayer:AddCollumn( 'UPALL', 100, .T., 'UP' )         // Na "linha" criada eu crio uma coluna com 100% da tamanho dela		
oPnl1 := oFWLayer:GetColPanel('UPALL','UP')				                   
				                                                                 
@005,005 SAY RTrim(cPrd)+" - "+cDesc of oPnl1 Pixel				
				
oFWLayer:AddLine( 'MIDDLE', 70, .F. )                  // Cria uma "linha" com 80% da tela
oFWLayer:AddCollumn( 'MIDDLEALL', 100, .T., 'MIDDLE' ) // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPnl2 := oFWLayer:GetColPanel( 'MIDDLEALL', 'MIDDLE' ) // Pego o objeto desse peda็o do container
                                                                                                                                  
oFWLayer:AddLine( 'DOWN', 15, .F. )                       // Cria uma "linha" com 10% da tela
oFWLayer:AddCollumn( 'DOWNALL', 100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
             
oTwBrw:= TwBrowse():New(0,0,0,0,,aCabBrw,,oPnl2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oTwBrw:Align := CONTROL_ALIGN_ALLCLIENT  
oTwBrw:SetArray(aDados)   

oTwBrw:bLine := {||{ aDados[oTwBrw:nAt,1],;                                          
					Transform(aDados[oTwBrw:nAt,2],"@E 999,999,999.99" ),;                           
					Transform(aDados[oTwBrw:nAt,3],"@E 999,999,999.99" ),;                             
					Transform(aDados[oTwBrw:nAt,4],"@E 999,999,99" ),;  
					aDados[oTwBrw:nAt,5],;
					Transform(aDados[oTwBrw:nAt,6],"@E 999,999,999.99" ),;                         
					aDados[oTwBrw:nAt,7],;
					aDados[oTwBrw:nAt,8],;
					aDados[oTwBrw:nAt,9] }}                                
                                                                             
oPnl3 := oFWLayer:GetColPanel( "DOWNALL","DOWN" )                                                  
        
@005,(oPnl3:nRight/2) - 60 Button "Sair" Size 40,10 Action(oDlg:End()) of oPnl3 Pixel                                                               
                                                                                               
ACTIVATE MSDIALOG oDlg CENTERED

Return	                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณDadosPrd       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetornar dados gerenciais do produto                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cPrd - C๓digo do produto    									   บฑฑ     
ฑฑบ			 ณ cGrpFil -Grupo de filiais  									   บฑฑ     
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DadosPrd(cPrd,cGrpFil)
Local aDados 	:= {} 						//Dados do produto
Local aFil     := GetFiliais(cGrpFil) 	//vetor com as filiais do grupo de filiais
Local nX	      := 0                   	//contador       
Local nUltPrc	:= 0    //Ultimo pre็o de compra
Local nUltCus	:= 0    //Ultimo custo de compra  
Local nMarkup	:= 0    //valor markup
Local nQtdVend	:= 0    //Quantidade vendida
Local nVlrVend	:= 0    //Valor vendido
Local nVendDia	:= 0    //Venda por dia
Local nSldEst	:= 0    //Saldo em estoque
Local nDiasEst	:= 0    //Dias de dura็ใo do estoque	                 
       
For nX := 1 to Len(aFil)
	nUltPrc	 := GetUltPrc(aFil[nX],cPrd)
	nUltCus	 := GetDadPrd(aFil[nX],cPrd,"CUSTD",0)
	nMarkup  := GetDadPrd(aFil[nX],cPrd,"MARKUP",0)  
	nQtdVend := GetDadSD2(aFil[nX],cPrd,1)
	nVlrVend := GetDadSD2(aFil[nX],cPrd,3)
	nVendDia := GetDadSD2(aFil[nX],cPrd,1) / MAX((MV_PAR03 - MV_PAR02),1)
	nSldEst  := GetSldEst(aFil[nX],cPrd)
	nDiasEst := Round(nSldEst/nVendDia,0)
	
	aAdd(aDados,{aFil[nX],nUltPrc,nUltCus,nQtdVend,nVlrVend,nVendDia,nSldEst,nDiasEst,nMarkup})
Next                     

Return aClone(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetFiliais     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna vetor com filiais do grupo de filiais                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cGrp -Grupo de filiais  									   	   บฑฑ          
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetFiliais(cGrp)
Local aFiliais  := {} //Controle de Filiais
Local aArea     := SAU->(GetArea()) //Controle de Area
Local cFil	    := xFilial("SAU") //Recebe filial corrente
 
DEFAULT cGrp := SAX->AX_GRUPFIL //Grupo de Filiais padrao
    
SAU->(dbSetOrder(1))
SAU->( dbSeek(cFil+cGrp ) )             

While SAU->(!EOF()) .And. RTrim(SAU->AU_CODGRUP) == RTrim(cGrp) .And. SAU->AU_FILIAL == cFil            
    aAdd(aFiliais,SAU->AU_CODFIL) 
	SAU->(dbSkip())
EndDo
                                  
RestArea(aArea)

Return aFiliais

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetUltPrc      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna ultimo pre็o de compra                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial que serแ utilizada                                บฑฑ
ฑฑบ			 ณ cPrd - C๓digo do produto                                        บฑฑ        
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetUltPrc(cFil,cPrd)
Local nPrc := 0	  //ultimo preco de compra	        
Local cQry := ""  //Consulta SQL
Local cSGBD := TCGetDB() //Banco de dados que esta sendo utilizado 

	cQry := " SELECT TOP(1) C7_PRECO"
	Do Case
 		Case cSGBD $ "MSSQL"   
        	cQry := "SELECT TOP 1 C7_PRECO"
   		Case cSGBD $ "ORACLE|DB2"
        	cQry := "SELECT C7_PRECO"
         Case cSGBD $ "MYSQL/POSTGRES"
         	cQry := "SELECT C7_PRECO"
         Case cSGBD $ "SYBASE" 
         	cQry := "SET ROWCOUNT 1 "
         	cQry += "SELECT R_E_C_N_O_ " 
         Case cSGBD $ "INFORMIX"
         	cQry := "SELECT FIRST 1 C7_PRECO"
         OtherWise
         	cQry := "SELECT TOP 1 C7_PRECO"
	EndCase
	cQry += " FROM "+RetSqlName("SC7")
	cQry += " WHERE C7_PRODUTO = '"+cPrd+"'"                                 
	cQry += " AND C7_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'" 
	cQry += " AND C7_FILIAL = '"+xFilial("SC7",cFil)+"' AND D_E_L_E_T_ = ' '"
	If cSGBD $ "ORACLE"
		cQry += " AND ROWNUM <= 1"
	EndIf
	
	Do Case
 		Case cSGBD $ "MSSQL"   
			cQry += " ORDER BY C7_EMISSAO DESC"        
   		Case cSGBD $ "ORACLE"
            cQry += " ORDER BY C7_EMISSAO DESC"             
        Case cSGBD $ "MYSQL/POSTGRES"
        	cQry += " ORDER BY C7_EMISSAO DESC LIMIT 1 "                            
        Case cSGBD $ "SYBASE" 
         	cQry += " ORDER BY C7_EMISSAO DESC"                             
        Case cSGBD $ "INFORMIX"
        	cQry += " ORDER BY C7_EMISSAO DESC"             
        OtherWise
	EndCase
	If cSGBD $ "DB2"
		cQry += " FETCH FIRST 1 ROWS ONLY "
	EndIf
	cQry := ChangeQuery(cQry)                  
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)    
	nPrc := TMP->C7_PRECO
	TMP->(dbCloseArea())
		                              
Return nPrc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetDadPrd      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o valor do campo especificado pelo parametro             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial que serแ utilizada                                บฑฑ
ฑฑบ			 ณ cPrd - C๓digo do produto                                        บฑฑ   
ฑฑบ			 ณ cCpo - Campo do dicionแrio de dados                             บฑฑ   
ฑฑบ			 ณ xDef - retorno padrใo caso o campo solicitado nโo exista no SX3 บฑฑ     
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetDadPrd(cFil,cPrd,cCpo,xDef)

Local aAreaSB1 := SB1->(GetArea())       //Controle de area SB1
Local aAreaSBZ := SBZ->(GetArea())       //Controle de area SBZ  
Local xRet     := ""                      //retorno da fun็ใo
     
DEFAULT xDef := ""                        //Valor default
          
SB1->(dbSetOrder(1))
SBZ->(dbSetOrder(1))
 	             
If SuperGetMv("MV_ARQPROD",,"SB1") == "SB1" .And. SB1->(FieldPos("B1_"+cCpo)) > 0
	If SB1->(dbSeek(xFilial("SB1")+cPrd)) 
   		xRet := SB1->&("B1_"+cCpo)
	Else
		xRet := CriaVar("B1_"+cCpo)
	EndIf
ElseIf SBZ->(FieldPos("BZ_"+cCpo)) > 0
	If SBZ->(dbSeek(xFilial("SBZ")+cPrd))
   		xRet := SBZ->&("BZ_"+cCpo)
	Else
		xRet := CriaVar("BZ_"+cCpo)
	EndIf
EndIf
    
RestArea(aAreaSB1) 
RestArea(aAreaSBZ)    
    
Return xRet                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetDadSD2      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o valor do campo especificado pelo parametro             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial que serแ utilizada                                บฑฑ
ฑฑบ			 ณ cPrd - C๓digo do produto                                        บฑฑ   
ฑฑบ			 ณ nOpc - Op็ao de retorno  1-Quantidade/2-Total/3-Pre็o de venda  บฑฑ        
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetDadSD2(cFil,cPrd,nOpc)
Local aDados := {} //Dados do produto
Local cQry   := "" //Consulta SQL    
                                           
DEFAULT nOpc := 1 //Opcao padrao

	cQry := " SELECT SUM(D2_QUANT) AS D2_QUANT, "
	cQry += " SUM(D2_TOTAL) AS D2_TOTAL, "
	cQry += " AVG(D2_PRCVEN) AS D2_PRCVEN " 
	cQry += " FROM "+RetSqlName("SD2")
	cQry += " WHERE D2_TIPO = 'N'"
	cQry += " AND D2_COD = '"+cPrd+"'"
	cQry += " AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'" 
	cQry += " AND D2_FILIAL = '"+xFilial("SD2",cFil)+"' AND D_E_L_E_T_ = ''"
	cQry := ChangeQuery(cQry)                  
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)    
	aAdd(aDados, TMP->D2_QUANT  )
	aAdd(aDados, TMP->D2_TOTAL  )
	aAdd(aDados, TMP->D2_PRCVEN )
	TMP->(dbCloseArea())

Return aDados[nOpc]                       
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetSldEst      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o estoque corrente                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial que serแ utilizada                                บฑฑ
ฑฑบ			 ณ cPrd - C๓digo do produto                                        บฑฑ   
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetSldEst(cFil,cPrd)
Local nEstoque  := 0 //Qtd de estoque
Local aArea		:= SB2->(getArea()) //Area Corrente

DbSelectArea("SB2")

cFil := xFilial("SB2",cFil)           
                         
SB2->(dbSeek(xFilial("SB2",cFil)+cPrd ))                                  

While SB2->(!EOF()) .And. RTrim(SB2->B2_COD) == RTrim(cPrd) .And. SB2->B2_FILIAL == cFil
	nEstoque := SaldoSB2()                  
	SB2->(dbSkip())
EndDo                            
        
RestArea(aArea)        

Return nEstoque                               
             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325GRVSAZ     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravar os dados da tabela de pre็o na tabela SAZ                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oModel - Modelo do MVC                                          บฑฑ   
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325GRVSAZ(oModel)
Local cCod	   := oModel:GetModel("SAXMASTER"):GetValue("AX_CODIGO")    //C๓digo do produto
Local aFiliais := GetFiliais() //Filiais do grupo de filiais                 
Local cLote    := "" //lote do painel de precifica็ใo
Local nX 	   := 0      //Contador 
Local cFil     := "" //Filial      
Local oPainel  := Nil
Local lPainel  := .F.

lPainel := SuperGetMV("MV_LJGEPRE",.F.,.F.)

If lPainel
	oPainel := PainelPrecificacao():New()        			     			
EndIf
       
If Empty("DA0") //DA0 compartilhado, serแ gerado pacote apenas para a primeira filial
	cFil := aFiliais[1]
	aFiliais := {cFil}
EndIf

For nX := 1 to Len(aFiliais)
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€ฟ
	//ณAQUI DEVE SER GERADO O PACOTE PARA O PAINEL DE GESTรO, O RETORNO COM O NUMERO DO LOTE SERม ARMAZENADO NESTA VARIAVELณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ€ู
	*/
	cLote := "ZZZ"
	// Atualiza Painel de Gestao criando pacote de manutencao de precos
	If lPainel
		
		BEGIN TRANSACTION
		oPainel:Lj3PacPrec(oModel:GetModel("SAXMASTER"):GetValue("AX_DATAINI"),aFiliais[nX],alltrim(cCod))	//Adiciona um pacote do tipo ATUALIZACAO DE PRECOS ao lote da data
		cLote := oPainel:cNroLote
		END TRANSACTION
		
	EndIf
    	
	If SAZ->(dbSeek(xFilial("SAZ")+cCod+aFiliais[nX]))
    	RecLock("SAZ",.F.)		
	Else
    	RecLock("SAZ",.T.)
    EndIf
    SAZ->AZ_FILIAL  := xFilial("SAZ") 
    SAZ->AZ_CODIGO  := cCod
    SAZ->AZ_CODFIL  := aFiliais[nX]
    SAZ->AZ_LOTE    := cLote
    SAZ->AZ_EFETIVO := "2"                
    SAZ->(MsUnlock())
Next

Return .T.                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325GRVSAZ     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravar os dados da tabela de pre็o na tabela SAZ                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oModel - Modelo do MVC                                          บฑฑ   
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325TPRE( oModel )
Local lRet       := .T.  //Retorno da Funcao
Local nOperation := oModel:GetOperation() //Operador corrente
        
If nOperation == 4 .Or. nOperation == 5
  		If SAX->AX_EFETIVO == '1' .Or. SAX->AX_EFETIVO == '2'	                
		HELP('MATA325',, 'MATA325',, STR0030, 1, 0)   //'Este registro jแ foi efetivado. Nใo pode ser alterado.'
		lRet := .F.
	EndIF
EndIf
	
Return lRet                                                                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325Perg       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApresentar pergunta ao usuแrio                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oModel - Modelo do MVC                                          บฑฑ   
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325Perg(oModel)
Local aPrd  := {} //Vetor de produtos                 
Local cTab  := "" //Tabela ativa
Local nOperacao := oModel:GetOperation() //Controle de operacao
Local nLine 	:= oModel:GetModel("SAYDETAIL"):GetLine() //Controle de numero da linha
Local nI,nTotLinhas
Local lUpdLo128 := AliasIndic("MG3") .AND. MG3->(FieldPos("MG3_CODIGO")) > 0  // Verifica se o update foi executado     

Default l325Perg := .F.
Default cCodPlan := ""
Default cCodRev  := ""

If Empty(cCodPlan)
	If FindFunction("GetPlanRev")
		GetPlanRev( MV_PAR01, @cCodPlan, @cCodRev )
	EndIf
	If !(nOperacao == 3) .And. SAX->(FieldPos("AX_CODPLA")) > 0 .And. !Empty(SAX->AX_CODPLA) .And. cCodPlan+cCodRev != SAX->(AX_CODPLA+AX_REVPLA)
		If !(nOperacao == 4) .Or. !ApMsgYesNo(STR0066) // "Confirma a altera็ใo da Planilha/Revisใo? Os dados de integra็ใo digitados serใo perdidos!"
			cCodPlan	:= SAX->AX_CODPLA
			cCodRev	:= SAX->AX_REVPLA
		EndIf
	EndIf
EndIf

If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4) .And. !(AtIsRotina("BUTTONOKACTION")) //Tela sendo reapresentada ap๏ฟฝs confirma๏ฟฝ๏ฟฝo do bot๏ฟฝo Ok    
   	If Pergunte("MTA325",l325Perg) .Or. l325Perg == .F.
   		If Empty(MV_PAR02)
   			MV_PAR02 := dDataBase		
   		EndIf
   		If Empty(MV_PAR03)
   			MV_PAR03 := dDataBase		
   		EndIf 	
   		If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
   			If lUpdLo128
		   		If MV_PAR04 == 1//"1" $ MV_PAR04 
		   		    aPrd := A325Categ()                                                       
		   			
		   			If !Empty(aPrd)
		   				cTab := TabAtiva()
		   				Processa( {|| A325AddPrd(oModel,aPrd,cTab) }, STR0031, STR0032,.F.) //"Aguarde..."###"Adicionando produtos..."
		   			EndIf
		   		ElseIf MV_PAR04 == 2   
					aPrd := A325Categ(.T.)	   		
		   			If !Empty(aPrd)
		   				cTab := TabAtiva()                      //NOVO PARAM
		   				Processa( {|| A325AddPrd(oModel,aPrd,cTab,.T.) }, STR0031, STR0032,.F.) //"Aguarde..."###"Adicionando produtos..."
		   			EndIf	   			
		   		EndIf 
		   	Else
		   		If "1" $ MV_PAR04    
		   		    aPrd := A325Categ()                                                       
		   			
		   			If !Empty(aPrd)
		   				cTab := TabAtiva()
		   				Processa( {|| A325AddPrd(oModel,aPrd,cTab) }, STR0031, STR0032,.F.) //"Aguarde..."###"Adicionando produtos..."
		   			EndIf		   	
		   		EndIf	
		   	EndIf	
   		EndIf
   	Else
   		MsgInfo(STR0033) //"Utilizando valores padrใo para os parametros."
   		MV_PAR01 := ""
   		MV_PAR02 := dDataBase
   		MV_PAR03 := dDataBase
   		MV_PAR04 := Iif(lUpdLo128,1,"")
   		MV_PAR05 := ""
   		MV_PAR06 := "" 
		If lUpdLo128
	   		MV_PAR07 := ""
	   		MV_PAR08 := ""
	   		MV_PAR09 := ""
	   		MV_PAR10 := ""
	   		MV_PAR11 := ""
   		EndIf
   	EndIf

	If oModel:GetOperation() == 4 .And. SAX->(FieldPos("AX_CODPLA")) > 0 
		If Empty(cCodPlan) 
			If FindFunction("GetPlanRev")
				GetPlanRev( MV_PAR01, @cCodPlan, @cCodRev )
			EndIf
			If nOperacao != MODEL_OPERATION_INSERT .And. !Empty(SAX->AX_CODPLA) .And. cCodPlan+cCodRev != SAX->(AX_CODPLA+AX_REVPLA)
				If !ApMsgYesNo(STR0066) // "Confirma a altera็ใo da Planilha/Revisใo? Os dados de integra็ใo digitados serใo perdidos!"
					cCodPlan	:= SAX->AX_CODPLA
					cCodRev	:= SAX->AX_REVPLA
				EndIf
			EndIf
		EndIf
		If cCodPlan+cCodRev != SAX->(AX_CODPLA+AX_REVPLA)
			nTotLinhas  := oModel:GetModel("SAYDETAIL"):GetQTDLine()
			For nI := 1 To nTotLinhas
				oModel:GetModel("SAYDETAIL"):SetLine(nI)
				A325IntPlan(.F.)
			Next nI
		EndIf
		oModel:GetModel("SAYDETAIL"):SetLine(nLine)
	EndIf
Else
	MV_PAR01 := ""
   	MV_PAR02 := dDataBase
   	MV_PAR03 := dDataBase
   	MV_PAR04 := Iif(lUpdLo128,1,"")
   	MV_PAR05 := ""
   	MV_PAR06 := "" 
	If lUpdLo128
	   	MV_PAR07 := ""
	   	MV_PAR08 := ""
	 	MV_PAR09 := ""
		MV_PAR10 := ""
		MV_PAR11 := ""
	EndIf
EndIf

Return                                                            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325AddPrd     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdicionar produtos ao Model                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oModel - Modelo do MVC                                          บฑฑ 
ฑฑบ			 ณ aPrd   - vetor com c๓digo de produtos                           บฑฑ 
ฑฑบ			 ณ cTab   - Tabela de pre็o ativa                                  บฑฑ   
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325AddPrd(oModel,aPrd,cTab,lFornece)
Local nX				:= 0      //contador
Local oMdlSAY		:= oModel:GetModel("SAYDETAIL")
Local aCols			:= oMdlSAY:aCols  
Local nOperation	:= oModel:GetOperation() 
Local nPosCat		:= SAY->(FieldPos("AY_CATEGO"))
Local nPosForne		:= SAY->(FieldPos("AY_FORNECE"))
Local nPosLjFor		:= SAY->(FieldPos("AY_LJFORNE"))
Local lSeekLine		:= .F.
Local lUpdLo128 := AliasIndic("MG3") .AND. MG3->(FieldPos("MG3_CODIGO")) > 0  // Verifica se o update foi executado
Local lIntPlan	:= .T.
Local lUsaForne	:= Ascan(oMdlSAY:aHeader,{ |x| x[2]=="AY_FORNECE" } ) > 0        

Default lFornece:= .F.

//Ponto de entrada para manipula็ใo da quantidade de linhas - Somente Argentina
If cPaisLoc == "ARG" .And. ( ExistBlock("FT325NMax") )
	ExecBlock("FT325NMax",.F.,.F.,{oMdlSAY})	
Else
	oMdlSAY:SetMaxLine(9999)	//N๚mero mแximo de linhas
EndIf


ProcRegua(Len(aPrd))

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0	
	lIntPlan := .F.
EndIf

For nX := 1 to Len(aPrd)
	IncProc()                  
            
	If nOperation == 4 .And. aScan(aCols,{|x| RTrim(x[2]) == RTrim(aPrd[nX][1])}) > 0 
		Loop
	EndIf
		
	If !Empty(aPrd[nX][1])
		lSeekLine := oMdlSAY:SeekLine({{"AY_PRODUTO",aPrd[nX][1]}})
		If !lSeekLine .AND. oMdlSAY:AddLine() > 0 			
			oModel:LoadValue("SAYDETAIL","AY_ITEM",StrZero(nX,TamSx3("AY_ITEM")[1]))
			oModel:LoadValue("SAYDETAIL","AY_PRODUTO",aPrd[nX][1])
			oModel:LoadValue("SAYDETAIL","AY_DESCRI",aPrd[nX][2])  
			oModel:LoadValue("SAYDETAIL","AY_PRCATU ",GetPrcAtu(cTab,aPrd[nX][1]))
			If nPosCat > 0 .AND. !lFornece
				oModel:LoadValue("SAYDETAIL","AY_CATEGO",aPrd[nX][3])
				oModel:LoadValue("SAYDETAIL","AY_DESCAT",Posicione("ACU",1,xFilial("ACU") + aPrd[nX][3], "ACU_DESC"))
			EndIf 
			
			If lFornece .AND. nPosForne > 0 .AND. nPosLjFor > 0 .AND. lUsaForne
				oModel:LoadValue("SAYDETAIL","AY_FORNECE",SubStr(aPrd[nX][3],1,Len(aPrd[nX][3])-2 ))
				oModel:LoadValue("SAYDETAIL","AY_LJFORNE",SubStr(aPrd[nX][3],Len(aPrd[nX][3])-1,2 ))
				oModel:LoadValue("SAYDETAIL","AY_DRCFORN",Posicione("SA2",1,xFilial("SA2") + aPrd[nX][3], "A2_NREDUZ") )
			EndIf
			
			If lUpdLo128		
				//Projeto Precifica็ใo: Preencher a Categoria ou Fornecedor com o primeiro que encontrar
				If lFornece 
					ACV->(DbSetOrder(5))
					ACV->(DbSeek(xFilial("ACV")+aPrd[nX][1],.T.))
					oModel:LoadValue("SAYDETAIL","AY_CATEGO",ACV->ACV_CATEGO)			
				Else
					If lUsaForne
						SA5->(DbSetOrder(2))
						SA5->(DbSeek(xFilial("SA5")+aPrd[nX][1],.T.))
						oModel:LoadValue("SAYDETAIL","AY_FORNECE",SA5->A5_FORNECE )
						oModel:LoadValue("SAYDETAIL","AY_LJFORNE",SA5->A5_LOJA )
						oModel:LoadValue("SAYDETAIL","AY_DRCFORN",SubStr(SA5->A5_NOMEFOR,1,TamSx3("AY_DRCFORN")[1]) )
					EndIf
				EndIf
		    EndIf
			
			If lIntPlan
				A325IntPlan(.F.)
			EndIf	  
		EndIf
		

	EndIf  
	
Next

Return 
                                                                                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325ESAX       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdicionar produtos ao Model                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cAlias - Alias da tabela                                        บฑฑ 
ฑฑบ			 ณ nRecno - Recno do registro                                      บฑฑ 
ฑฑบ			 ณ cTab   - Op็ใo da MBrowse                                       บฑฑ   
ฑฑบ			 ณ cLote  - Numero do lote do painel de gestใo                     บฑฑ  
ฑฑบ			 ณ cFil   - Op็ใo da MBrowse                                       บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                         
Function A325ESAX(cAlias,nRecno,nOpc,cLote,cFil) 
Local aGrpFil 		:= {}								//-- Vetor com as filiais do grupo de filiais
Local lRet 			:= .T. 								//-- Retorno indicando se a fun็ใo foi realizada com sucesso      
Local aDA0 			:= {} 								//-- Registros do DA0                      
Local aDA1 			:= {} 								//-- Registros do DA1
Local aAreaSAX 		:= {}								//-- Controle de area SAX
Local aAreaSAZ 		:= {}								//-- Controle de area SAZ  
Local cCod 			:= ""								//-- C๓digo da publica็ใo
Local cMvLjTpPub	:= SuperGetMv("MV_LJTPPUB",,"1")
	
//-- Verifica o tamanho dos campos AY_PRCSUG e DA1_PRCVEN
If !VldTamCpos()                                    
	Help(" ",1,"A325TDIF")
	lRet := .F.
EndIf

If lRet
	If SuperGetMv('MV_LJGEPRE',,.F.)
		aAreaSAX := SAX->(GetArea())
		aAreaSAZ := SAZ->(GetArea())  
	     
		SAX->(dbSetOrder(1))
		SAZ->(dbSetOrder(2))      
	    	
		If SAZ->(dbSeek(xFilial("SAZ",cFil) + cFil + cLote) ) 
	    	cCod := SAZ->AZ_CODIGO
	    	If SAZ->AZ_EFETIVO <> "1"		
				aDA0 := SAXtoDA0(cFil,SAZ->AZ_CODIGO)
				aDA1 := SAYtoDA1(cFil,SAZ->AZ_CODIGO)       
				
				A325EFET(cFil,aDA0,aDA1)       
				   
				RecLock("SAZ",.F.)
				SAZ->AZ_EFETIVO := "1"
				SAZ->(MsUnlock())
				
				A325AtuSts(cFil,cCod)
			Else
	    		lRet := .F.
	    		Alert(STR0034) //"Lote jแ efetivado para esta filial"
			EndIf			
		Else
	    	lRet := .F.
	    	Alert(STR0035) //"Lote nใo encontrado para esta filial"
		EndIf
		RestArea(aAreaSAX)
	    RestArea(aAreaSAZ)
	Else
		aGrpFil := GetFiliais(SAX->AX_GRUPFIL)    
		If SAX->AX_EFETIVO == "3" .OR. Empty(SAX->AX_EFETIVO)
			If ApMsgYesNo(STR0036) //"Deseja efetivar a tabela de pre็o?"
				
				//Tratamento caso o campo Grupo de Filiais esteja vazio
				If ( Len(aGrpFil) == 0 )
					AAdd( aGrpFil, Iif( cMvLjTpPub == '1',xFilial("DA0") ,xFilial("SB0") ) )
				EndIf
				
				// Projeto Precificacao
				// Efetua a gravacao dos dados de publicacao de acordo com o parametro MV_LJTPPUB. 
				// Podera gravar a lista de preco no DA0/DA1 ou no SB0
				LjParTpPub(aGrpFil, nRecno) // funcao no LOJXFUND
					
			EndIf	   
		Else
			Alert(STR0037) //"Registro jแ efetivado."
		EndIf	
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325EFET       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetivar tabela de pre็o                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil   - Filial que serแ efetivada a tabela de pre็o            บฑฑ 
ฑฑบ			 ณ aDA0   - Vetor com dados da tabela DA0                          บฑฑ 
ฑฑบ			 ณ aDA1   - Vetor com dados da tabela DA1                          บฑฑ   
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                     
Function A325EFET(cFil,aDA0,aDA1,cTabAtiva) 
Local cNewTab   := ""                 //c๓digo da nova tabela de pre็o
Local cFilBak   := ""                 //Backup da filial logada no sistema
Local lTpOper   := DA1->(FieldPos("DA1_TPOPER")) > 0
                         
Local nX		    := 0          //contador
Local nY        := 0          //contador
Local lNovaTab  := .T.	      // Flag para indicar se o sistema irแ criar uma nova tabela de pre็o                 
Local nItens	 := 0				//Armazena a quantidade de itens que jแ estใo na tabela de pre็o               

Default cTabAtiva := TabAtiva(cFil,.F.,aDA0) //tabela de pre็o ativa

DA0->(dbSetOrder(1)) 
DA1->(dbSetOrder(1))
	             
BEGIN TRANSACTION
	If !Empty(cTabAtiva)
		lNovaTab := .F.
		If DA0->(dbSeek(xFilial("DA0",cFil)+cTabAtiva))
			If SuperGetMV("MV_TPEFETP",,"1") == "2" .Or. DA0->DA0_DATDE <> SAX->AX_DATAINI
				lNovaTab := .T.
				RecLock("DA0",.F.)
				If DA0->DA0_DATDE < aDA0[2,2] - 1
					DA0->DA0_DATATE := aDA0[2,2] - 1
				Else
					DA0->DA0_DATATE := DA0->DA0_DATDE
				EndIf
				DA0->(MsUnlock())
			EndIf
		EndIf
		If SuperGetMV("MV_TPEFETP",,"1") == "1" .And. DA1->(dbSeek(xFilial("DA1",cFil)+cTabAtiva))
			While DA1->(!EOF()) .And. RTrim(DA1->DA1_CODTAB) == RTrim(cTabAtiva) .And. DA1->DA1_FILIAL == xFilial("DA1",cFil)
				If aScan(aDA1, {|x| RTrim(x[1,2]) == RTrim(DA1->DA1_CODPRO)}) == 0
					If lTpOper
						aAdd(aDA1, {{"DA1_CODPRO"	, DA1->DA1_CODPRO },;
										{"DA1_PRCVEN"	, DA1->DA1_PRCVEN },;
										{"DA1_ATIVO" 	, "1"},;
										{"DA1_TPOPER" 	, "4"},;
										{"DA1_QTDLOTE"	, DA1->DA1_QTDLOTE},;
										{"DA1_MOEDA" 	, 1  } })
					Else
						aAdd(aDA1, {{"DA1_CODPRO"	,DA1->DA1_CODPRO },;
										{"DA1_PRCVEN"	,DA1->DA1_PRCVEN },;
										{"DA1_ATIVO" 	,"1"},;
										{"DA1_QTDLOTE"	,DA1->DA1_QTDLOTE},;
										{"DA1_MOEDA" 	,1  } })
					EndIf
					nItens++
				EndIf
				DA1->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If lNovaTab
		cFilBak := cFilAnt
		cFilAnt := cFil
		cNewTab := GETSXENUM("DA0","DA0_CODTAB")
		cFilAnt := cFilBak
		
		RecLock("DA0",.T.)
		DA0->DA0_CODTAB := cNewTab
		DA0->DA0_FILIAL := xFilial("DA0",cFil)
		DA0->DA0_HORATE := "23:59"
		For nX := 1 to Len(aDA0)
			DA0->(FieldPut(FieldPos(aDA0[nX,1]),aDA0[nX,2]))
		Next
		DA0->(MsUnlock())
		ConfirmSX8()
	Else
		cNewTab := cTabAtiva
	EndIf
	
	DA1->(dbSetOrder(1))
	nPosPrd := aScan(aDA1,{|x| RTrim(x[1,1]) == "DA1_CODPRO" })
	
	For nX := 1 to Len(aDA1)
		DA1->(dbSeek(xFilial("DA1",cFil)+PadR(cNewTab,3)+aDA1[nX,nPosPrd,2] ))
		RecLock("DA1",DA1->(!Found()))
		DA1->DA1_CODTAB := cNewTab
		DA1->DA1_FILIAL := xFilial("DA1",cFil)
		If DA1->(!Found())
			nItens++
			DA1->DA1_ITEM := StrZero(nItens,4)
		EndIf
		For nY := 1 to Len(aDA1[nX])
			DA1->(FieldPut(FieldPos(aDA1[nX,nY,1]),aDA1[nX,nY,2]))
		Next nY
		DA1->(MsUnlock())
	Next nX
	
END TRANSACTION

//----------------------------------------------------------
// Ponto de Entrada p๓s efetiva็ใo da tabela de pre็o
// Criado a pedido da Eletrozema para grava็ใo de Log
//----------------------------------------------------------
If ( ExistBlock("FT325EFET") )
    ExecBlock( "FT325EFET", .F., .F. )
EndIf

Return                                     
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSAXtoDA0       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdicionar a um vetor dados da tabela SAX                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil   - Filial que serแ efetivada a tabela de pre็o            บฑฑ 
ฑฑบ			 ณ cCod   - C๓digo da tabela SAX                                   บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                             
Static Function SAXtoDA0(cFil,cCod)
Local aAux := {}     //Controle de retorno auxiliar

SAX->(dbSetOrder(1))	
SAX->(dbSeek(xFilial("SAX",cFil)+cCod))     

aAdd(aAux,{"DA0_DESCRI",SAX->AX_DESCRI})       
aAdd(aAux,{"DA0_DATDE" ,SAX->AX_DATAINI})
aAdd(aAux,{"DA0_HORADE",SAX->AX_HORAINI})
aAdd(aAux,{"DA0_HORAATE","23:59"})
aAdd(aAux,{"DA0_ATIVO" ,SAX->AX_ATIVO}) 
aAdd(aAux,{"DA0_TPHORA","1"})

If DA0->(FieldPos("DA0_FILPUB")) > 0  .And. DA0->(FieldPos("DA0_CODPUB")) > 0
	aAdd(aAux,{"DA0_FILPUB",SAX->AX_FILIAL})       
	aAdd(aAux,{"DA0_CODPUB",SAX->AX_CODIGO})       
EndIf

Return aClone(aAux)
                                                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325AtuSts     บAutor  ณMicrosiga           บ Data ณ  13/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizar Status das tabelas SAX e SAZ                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil   - Filial que serแ atualizado o status                    บฑฑ 
ฑฑบ			 ณ cCod   - C๓digo da publica็ใo de pre็o                          บฑฑ  
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function A325AtuSts(cFil,cCod) 
Local lAllEfet := .T. //Flag para verificar se todos os registros de uma publica็ใo na SAZ foram efetivados

SAZ->(dbSetOrder(1))
SAZ->(dbSeek(xFilial("SAZ")+cCod))
                                 
While SAZ->(!EOF()) .And. RTrim(SAZ->AZ_CODIGO) == RTrim(cCod) .And. SAZ->AZ_FILIAL == xFilial("SAZ",cFil)
	If SAZ->AZ_EFETIVO <> "1"
		lAllEfet := .F.
	EndIf
	SAZ->(dbSkip()) 	
EndDo

SAX->(dbSetOrder(1))
SAX->(dbSeek(xFilial("SAX",cFil)+cCod))

RecLock("SAX",.F.)
If lAllEfet
	SAX->AX_EFETIVO := "1"
Else
	SAX->AX_EFETIVO := "2"
EndIf

SAX->(MsUnlock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSAYtoDA1       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdicionar a um vetor dados da tabela SAY                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil   - Filial que serแ efetivada a tabela de pre็o            บฑฑ 
ฑฑบ			 ณ cCod   - C๓digo da tabela SAY                                   บฑฑ  
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                             
Static Function SAYtoDA1(cFil,cCod)
Local aAux := {} //Controle de retorno auxiliar
Local lTpOper := DA1->(FieldPos("DA1_TPOPER")) > 0

SAY->(dbSetOrder(1))	
SAY->(dbSeek(xFilial("SAY",cFil)+cCod))     

While SAY->(!EOF()) .AND. RTrim(SAY->AY_CODIGO) == RTrim(cCod) .And. SAY->AY_FILIAL == xFilial("SAY",cFil)
	If lTpOper
		aAdd(aAux, { {"DA1_CODPRO",SAY->AY_PRODUTO},;
	                 {"DA1_PRCVEN",SAY->AY_PRCSUG },;
	                 {"DA1_QTDLOT",999999.99},;
	                 {"DA1_ATIVO" ,"1"},;
	                 {"DA1_TPOPER" ,"4"},;
	                 {"DA1_MOEDA" ,1  } })
	Else
		aAdd(aAux, { {"DA1_CODPRO",SAY->AY_PRODUTO},;
	                 {"DA1_PRCVEN",SAY->AY_PRCSUG },;
	                 {"DA1_QTDLOT",999999.99},;
	                 {"DA1_ATIVO" ,"1"},;
	                 {"DA1_MOEDA" ,1  } })
	EndIf
	SAY->(dbSkip())
EndDo   
	                                                                     
Return aClone(aAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325PrcSug     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetornar o pre็o sugerido                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cPrd - C๓digo do produto                                        บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                             
Static Function A325PrcSug(cPrd)    
Local aVet   := {} //Controle de vetor
Local nPreco := 0 //Atualizacao de Preco
       
Private cArqMemo := MV_PAR01
Private lDirecao   := .T.  
Private nQualCusto := 1
Private cProg      := "R430"
       
DEFAULT lMsg := .T.

Pergunte("MTC010",.F.)  //Este pergunte serve para a funcao MC010Forma, sem os MV_PARXX ocorre error log.
SB1->(dbSeek(xFilial("SB1")+RTrim(cPrd) ))
If SuperGetMV("MV_REVPLAN",.F.,.F.) .And. FindFunction("MC010FORM2")
	aVet :=	MC010Form2("SB1",SB1->(RecNo()),98)
Else			
	aVet := MC010Forma("SB1",SB1->(RecNo()),98)
EndIf
                                    
If ValType(aVet) <> "A"
	aVet := {}
EndIf
    
nPos := aScan(aVet,{|x| RTrim(x[3]) == "#PUBLICACAO" })
     
If nPos > 0   
	nPreco := aVet[nPos,5]
ElseIf lMsg                                                            
	Alert(STR0038) //"Nใo foi calculado pre็o Sugerido."
	lMsg := .F.
	nPreco := 0.00		
EndIf                                                                                 

Pergunte("MTA325",.F.)
	
Return nPreco                                                            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTabAtiva       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetornar a tabela de pre็o ativa                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial da consulta                                       บฑฑ 
ฑฑบ          ณ lAlerta - Exibe alerta de tabela nใo encontrada                 บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                             
Static Function TabAtiva(cFil,lAlerta,aSAX)
Local lUpdLo128 := AliasIndic("MG3") .AND. MG3->(FieldPos("MG3_CODIGO")) > 0  // Verifica se o update foi executado     
Local cTab := Iif(lUpdLo128,MV_PAR11,MV_PAR05)//-- Tabela de pre็o        
Local nPos := 0 //Posicao do campo DA0_DATDE
DEFAULT lAlerta := .T.
DEFAULT cFil := xFilial("DA0",cFil)
DEFAULT aSAX := {}               

cFil := xFilial("DA0",cFil)

If !Empty(aSAX)
	nPos := aScan(aSAX,{|x| RTrim(x[1]) == "DA0_DATDE" })
	If nPos > 0
		DA0->(dbGoTop())
		While DA0->(!EOF()) .And. Empty(cTab)
			If DA0->DA0_DATDE == aSAX[nPos,2] .And. DA0->DA0_FILIAL == cFil
				cTab := DA0->DA0_CODTAB
			EndIf
			DA0->(dbSkip())
		EndDo
	EndIf
EndIf

If Empty(cTab)
	DA0->(dbGoTop())
	While DA0->(!EOF()) .And. Empty(cTab)
		If dDataBase >= DA0->DA0_DATDE .And. (Empty(DA0->DA0_DATATE) .Or. dDataBase <= DA0->DA0_DATATE ) .And. DA0->DA0_FILIAL == cFil
			If DA0->DA0_ATIVO == "1"
				cTab := DA0->DA0_CODTAB
			EndIf
		EndIf
		DA0->(dbSkip())
	EndDo
	
	If Empty(cTab) .And. lAlerta
		Alert(STR0039) //"Sem tabela ativa no momento."
	EndIf
EndIf

Return cTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetPrcAtu      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetornar o pre็o atual do produto                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil - Filial da consulta                                       บฑฑ 
ฑฑบ          ณ cCod - C๓digo do produto                                        บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                             
Static Function GetPrcAtu(cTab,cCod)
Local nPrcAtu  //pre็o atual

If !Empty(cTab)
	DA1->(dbSetOrder(2))
	If DA1->(dbSeek(xFilial("DA1")+PADR(cCod,TAMSX3("B1_COD")[1])+cTab))
    	nPrcAtu := DA1->DA1_PRCVEN  
	Else
		nPrcAtu := 0.00
	EndIf      
Else
	nPrcAtu := 0.00
EndIf	

Return nPrcAtu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325Categ      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApresentar arvore para sele็ใo de produtos atrav้s das categoriasบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325Categ(lFornece)

Local oDlgCat 		:= Nil   //objeto dialog
Local oLayer  		:= FWLayer():new() // objeto FwLayer
   
Local nRight  		:= oMainWnd:nRight - 200 //posi็ใo fina da dialog
Local nBottom 		:= oMainWnd:nBottom - 200//posi็ใo fina da dialog     
              
Local oWinL			:= Nil //container window esquerdo da dialog
Local oWinR			:= Nil //container window direito da dialog
Local oPnLUP		:= Nil //painel superior
Local oPnLDown		:= Nil //painel inferior
Local oPnRUP		:= Nil //painel superior direito
Local oPnRMiddle	:= Nil //painel intermediario direito
Local oPnRDown		:= Nil   //painel inferior direito
Local oGetL			:= Nil  //objeto get esquerdo
Local oGetR			:= Nil  //objeto get direito                              
Local oSayL			:= Nil  //objeto say esquerdo
Local oSayR			:= Nil  //objeto say direito
Local oSayPrd		:= Nil  //objeto say inferior esquerdo
Local oSayTot		:= Nil  //objeto say total inferior esquerdo       
Local oButL			:= Nil    //botใo lado esquerdo
Local oButR			:= Nil    //botใo lado direto
Local cPesqL 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado esquerdo
Local cPesqR 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado direito           
Local oPnlBottom	:= Nil //painel inferior    
Local oSayAtalho	:= Nil //Say utilizado para informar os atalhos da tela 
Local oBtnOk		:= Nil     //botใo Ok
Local oBtnCancel	:= Nil //botใo cancelar
Local oTree  		:= Nil //objeto tree  
Local aTree  		:= {}  //vetor com itens para a tree
Local oBrw   		:= Nil //objeto TWBrowse
Local aBrw   		:= {} //cabe็alho TWBrowse 
Local aDados 		:= {{"","",""}} //dados da TWBrowse 
Local lOk    		:= .F. //variavel de controle botใo OK            
Local aPrd   		:= {}  //Vetor com produtos selecionados
Local nX			:= 0  //contador
Local nTam			:= 0 //tamanho que a linha do Layer ira ocupar da tela	


Default lFornece:= .F.	
      
aBrw:= {STR0042,STR0043,Iif(lFornece,STR0073,STR0046)} //"C๓digo"###"Descri็ใo"###Fornecedor###"Categoria"

aTree:= Iif(lFornece,{},RetCatPrd()) 

DEFINE MSDIALOG oDlgCat TITLE Iif(lFornece,STR0074,STR0044) FROM 000,000 TO nBottom, nRight  Pixel of oMainWnd PIXEL //"Categoria de produtos"//"Fornecedores"
	             
If oApp:lMDI
	nTam := 85
Else
	nTam := 92
EndIf
oLayer:init(oDlgCat,.T.)
oLayer:addLine ('UP',nTam, .T. )          
oLayer:addCollumn('Left' ,50,.F.,'UP')     
oLayer:addWindow('Left', 'WLeft',Iif(lFornece,STR0074,STR0045) , 100, .F., .F., , 'UP' )        //"Fornecedores"###"Categorias"
	     
oWinL := oLayer:getWinPanel ( 'Left', 'WLeft', 'UP' ) 
oPnLUP := TPanel():New( 0,0, , oWinL, , , , , RGB(230,230,230), 0, 30, .F., .F. ) 
oPnLUP:Align := CONTROL_ALIGN_TOP                        
	
oSayL := TSay():New( 5 , 5,{|| Iif(lFornece,STR0075,STR0057) },oPnLUP,,,,,,.T.)  //"Produto/Fornecedor"###Produto/Categoria
oGetL := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqL:=u,cPesqL)} , oPnLUP, (oPnLUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )                                            
oButL := TButton():New( 15, (oPnLUP:nClientWidth/2) - 70, STR0047, oPnLUP, {|| TreeSeek(oTree,RTrim(cPesqL))}, 60, 10, , , , .T. )  //"Pesquisar"
	      
oPnLDown := TPanel():New( 0,0, , oWinL, , , , , , 0, 0, .F., .F. ) 
oPnLDown:Align := CONTROL_ALIGN_ALLCLIENT                      
                                         
oTree := Xtree():New(0, 0, 0, 0, oPnLDown)
oTree:Align := CONTROL_ALIGN_ALLCLIENT
                 
oLayer:addCollumn('Right',50,.F.,'UP')  
oLayer:addWindow('Right', 'WRight', STR0048, 100, .F., .F., , 'UP' ) //"Produtos selecionados"

oWinR := oLayer:getWinPanel ( 'Right', 'WRight', 'UP' )

oPnRUP := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 30, .T., .T. ) 
oPnRUP:Align := CONTROL_ALIGN_TOP                        
      
oSayR := TSay():New( 5 , 5,{|| STR0058},oPnRUP,,,,,,.T.) //Produto:"
oGetR := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqR:=u,cPesqR)} , oPnRUP, (oPnRUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )                                            
oButR := TButton():New( 15, (oPnRUP:nClientWidth/2) - 70, STR0047, oPnRUP, {|| FindPrd(oBrw,cPesqR)}, 60, 10, , , , .T. )  //"Pesquisar"
                                          
oPnRMiddle := TPanel():New( 0,0, , oWinR, , , , , , 0, 0, .F., .F. ) 
oPnRMiddle:Align := CONTROL_ALIGN_ALLCLIENT                      
                                                                
oBrw := TwBrowse():New(0,0,0,0,,aBrw,,oPnRMiddle,,,,,,,,,,,,,,.T.)
oBrw:lHScroll := .F.
oBrw:Align := CONTROL_ALIGN_ALLCLIENT
oBrw:setArray(aDados)		       

oBrw:bLine := {||{ aDados[oBrw:nAt,1],;
	                aDados[oBrw:nAt,2],;
	                aDados[oBrw:nAt,3] } }
	                 	        
oPnRDown := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 15, .T., .T. ) 
oPnRDown:Align := CONTROL_ALIGN_BOTTOM                               
	
oSayPrd := TSay():New(05,05,{|| STR0050},oPnRDown,,,,,,.T.) //"Produtos selecionados:"
oSayTot := TSay():New(05,80,{|| "0"},oPnRDown,"@E 99999",,,,,.T.)//,,,50,20)                  
 
If !lFornece
	addNode(oTree,aTree,oBrw,oSayTot)
Else	
	addForn(oTree,oBrw,oSayTot)
EndIf	
oTree:Refresh()                 
                                             
oLayer:addLine ("DOWN",10, .T. )
oPnlBottom := oLayer:getLinePanel("DOWN") 

oSayR      := TSay():New( 5 , 5,{|| "F4 | F5"},oPnlBottom,,,,,,.T.)
oBtnOk     := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 120, STR0051      , oPnlBottom, {|| lOk := .T., oDlgCat:End()}, 50, 12, , , , .T. )  //"OK"
oBtnCancel := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 60 , STR0052, oPnlBottom, {|| oDlgCat:End()}, 50, 12, , , , .T. )  //"Cancelar"
                                      
//Teclas de atalho
SetKEY(VK_F4,{|| MarkAll(oTree,oBrw,oSayTot,1)})
SetKEY(VK_F5,{|| MarkAll(oTree,oBrw,oSayTot,2)})

ACTIVATE MSDIALOG oDlgCat Centered
	
If lOk    
	aPrd := aClone(aDados)
EndIf                   

SetKEY(VK_F4,Nil)
SetKEY(VK_F5,Nil)       
Return aClone(aPrd)                                                                                                                   
                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณaddNode        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da fun็ใo recursiva addItem                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ aAux   - Vetor com dados do novo n๓   	 					   บฑฑ 
ฑฑบ          ณ oBrw   - Objeto TWBrowse   									   บฑฑ 
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ                
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Static Function addNode(oTree,aAux,oBrw,oSayTot)
Local nX := 1 //contador

If ValType(aAux[3]) == "A" .And. Len(aAux[3]) > 0
	For nX := 1 to Len(aAux[3])                                   
		addItem(oTree,aAux[3,nX],oBrw,oSayTot)                                                                 
	Next     
EndIf 
Return                                                                                                   
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณaddItem        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo recursiva para adicionar o n๓ e seus filhos               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ aAux   - Vetor com dados do novo n๓   	 					   บฑฑ 
ฑฑบ          ณ oBrw   - Objeto TWBrowse   									   บฑฑ 
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ                
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Static Function addItem(oTree,aAux,oBrw,oSayTot)
Local nX := 0  //contador                                                                          
Local nY := 0//contador

If ValType(aAux[3]) == "A" .And. Len(aAux[3]) > 0     
	//Adiciona Categoria "Pai"
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )
	For nX := 1 to Len(aAux[3])		
		//Adiciona produtos filhos, que possuem n๓s abaixo dele
		addItem(oTree,aAux[3,nX],oBrw,oSayTot)
	Next nX      
 	addPrdTree(oTree,aAux[1],oBrw,oSayTot) 
 	oTree:EndTree() 
ElseIf ValType(aAux[3]) == "A"
	//adiciona produtos filhos
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} ) 
	addPrdTree(oTree,aAux[1],oBrw,oSayTot)
	oTree:EndTree()
EndIf
	                 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณdblClick       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo de a็ใo de dois cliques marca/desmarca um item            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ oBrw   - Objeto TWBrowse   									   บฑฑ 
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ                
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Static Function dblClick(oTree,oBrw,oSayTot)
Local cCargo := oTree:GetCargo()   //ID do n๓ selecionado
Local nPos	 := aScan(oTree:aCargo,{|x| RTrim(x[1]) == RTrim(cCargo)}) //posicใo do n๓ no vetor
Local cResource := '' //imagem a ser adicionada no n๓                    
Local bCode := Nil     //Utilizado para informar se o n๓ estแ com flag ou nใo
Local cPai := ''      //ID do produto pai
               
If nPos > 0	                            
	If Eval(oTree:aCargo[nPos,3]) //o Flag do checkBox serแ desmarcado                 
	    cResource := "LBNO"                                     
		bCode	  := {|| .F.}
		oTree:aCargo[nPos,3] := {|| .F.}              
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.)
	
		//Adiciona produtos selecionados	
	Else //o Flag do checkBox serแ marcado
		cResource := "LBTIK"                                    
		bCode	  := {|| .T.}
		oTree:aCargo[nPos,3] := {|| .T.}
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.)
		//Remove produtos selecionados
	EndIf
	oTree:ChangeBmp(cResource,cResource,cCargo)       
	cPai := oTree:aNodes[nPos,2]
	MarkAllSon(oTree,cPai,cResource,bCode,oBrw,oSayTot)
EndIf  
    
oBrw:Refresh()

Return                                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMarkAllSon     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os filhos de um n๓                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ cPai   - ID do n๓ Pai								           บฑฑ 
ฑฑบ          ณ cResource - nome da imagem que o n๓ irแ apresentar              บฑฑ
ฑฑบ          ณ bCode     - Indicarแ se o n๓ estแ marcado ou nใo                บฑฑ
ฑฑบ          ณ oBrw      - objeto TWBrowse                                     บฑฑ
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ                
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarkAllSon(oTree,cPai,cResource,bCode,oBrw,oSayTot)
Local aFilhos := {} //Vetor com n๓s filhos
Local nPos 	  := 0  //posicใo do n๓ na arvore  
Local nX 	  := 0    //contador               
Local cCargo  := '' //ID do n๓
	
aEval(oTree:aNodes, {|x| If(RTrim(x[1]) == RTrim(cPai),aAdd(aFilhos,x[2]) , ) } )

For nX := 1 to Len(aFilhos)
	nPos   := aScan(oTree:aNodes, {|x| RTrim(x[2]) == RTrim(aFilhos[nX]) } )
	cCargo := oTree:aCargo[nPos,1]                   
	oTree:aCargo[nPos,3] := bCode         
	oTree:ChangeBmp(cResource,cResource,cCargo)       
	If Eval(bCode)
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.) 
	Else
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.)	
	EndIf	
	MarkAllSon(oTree,aFilhos[nX],cResource,bCode,oBrw,oSayTot)
Next

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณaddPrdTree     บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona um produto a arvore                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ ID     - ID do n๓ Pai								           บฑฑ 
ฑฑบ          ณ oBrw      - objeto TWBrowse                                     บฑฑ
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ                
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function addPrdTree(oTree,cID,oBrw,oSayTot) 
Local cFil := xFilial("ACV") //Filial      
                        
ACV->(dbSetOrder(1))
ACV->(dbSeek(xFilial("ACV")+cID))
                                     
While ACV->(!EOF()) .And. RTrim(ACV->ACV_CATEGO) == RTrim(cID) .And. ACV->ACV_FILIAL == cFil
	If !Empty(ACV->ACV_CODPRO)
		SB1->(dbSetOrder(1))                            
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_CODPRO))		
		oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", "CAT"+ACV->ACV_CATEGO+"_PRD"+RTrim(SB1->B1_COD),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} ) 	           	
	ElseIf !Empty(ACV->ACV_GRUPO)
		SB1->(dbSetOrder(4))                            
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_GRUPO))		
		While SB1->(!EOF()) .And. ACV->ACV_GRUPO == SB1->B1_GRUPO
			oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", "CAT"+ACV->ACV_CATEGO+"_PRD"+RTrim(SB1->B1_COD),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)})		
			SB1->(dbSkip())
		EndDo
	EndIf
	ACV->(dbSkip())
EndDo   
	
Return           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAtuPrdBrw      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona um produto a arvore                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ oBrw   - objeto TWBrowse                                        บฑฑ
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ 
ฑฑบ          ณ nPos   - Posi็ใo do n๓                                          บฑฑ     
ฑฑบ          ณ lAdd   - indica se estแ adicionando ou retirando um item        บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuPrdBrw(oTree,oBrw,oSayTot,nPos,lAdd)
Local aBrw		:= oBrw:aArray //Vetor do objeto TWBrowse com produtos selecionados
Local cPrd		:= "" //Produto selecionado
Local cCateg	:= "" // Categoria do produto selecionado
Local cFornece  := "" // Fornecedor do produto selecionado         
Local aArea		:= SB1->( GetArea()) // Guardar e restaurar a area
//Verifica se ้ produto, e se ele existe
If Len(oTree:aCargo[nPos,1]) > Len(ACV->ACV_CATEGO) .And. Left(oTree:aCargo[nPos,1],3) == "CAT"
	cCateg	:= Substr( oTree:aCargo[nPos,1], 4, Len(ACV->ACV_CATEGO) )
	cPrd		:= Substr( oTree:aCargo[nPos,1], 3 + Len(ACV->ACV_CATEGO) + 4 + 1 )
	// Projeto Precificacao
	// Posicionar no indice correto
	SB1->( DbSetOrder(1))  // B1_FILIAL+B1_COD	
	If SB1->(DbSeek(xFilial("SB1")+cPrd)) 
		If lAdd
	    	If Len(aBrw) == 1 .And. Empty(aBrw[1,1])	
	   		aBrw[1,1] := SB1->B1_COD
	   		aBrw[1,2] := SB1->B1_DESC
	   		aBrw[1,3] := cCateg
	    	ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)}) == 0
   			aAdd(aBrw,{SB1->B1_COD,SB1->B1_DESC,cCateg})	
	    	EndIf
		Else
	    	nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)})
	    	If nPos > 0                      
		    	aDel(aBrw,nPos)
	    		aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
		If Len(aBrw) == 0
			aAdd(aBrw,{"","",""})
		EndIf                                   
	 	aSort(aBrw,,,{|x,y| x[1] < y[1]})
	EndIf                       

ElseIf Len(oTree:aCargo[nPos,1]) > Len(SA5->A5_FORNECE+SA5->A5_LOJA) .And. Left(oTree:aCargo[nPos,1],3) == "FOR"
	cFornece	:= Substr( oTree:aCargo[nPos,1], 4, Len(SA5->A5_FORNECE+SA5->A5_LOJA) )
	cPrd		:= Substr( oTree:aCargo[nPos,1], 3 + Len(SA5->A5_FORNECE+SA5->A5_LOJA) + 4 + 1 )
	If SB1->(DbSeek(xFilial("SB1")+cPrd)) 
		If lAdd
	    	If Len(aBrw) == 1 .And. Empty(aBrw[1,1])	
	   		aBrw[1,1] := SB1->B1_COD
	   		aBrw[1,2] := SB1->B1_DESC
	   		aBrw[1,3] := cFornece
	    	ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)}) == 0
   				aAdd(aBrw,{SB1->B1_COD,SB1->B1_DESC,cFornece})	
	    	EndIf
		Else
	    	nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(cPrd)})
	    	If nPos > 0                      
		    	aDel(aBrw,nPos)
	    		aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
		If Len(aBrw) == 0
			aAdd(aBrw,{"","",""})
		EndIf                                   
	 	aSort(aBrw,,,{|x,y| x[1] < y[1]})
	EndIf    	
EndIf                       

// Projeto Precificacao
// Restaurar a area
RestArea(aArea)

oBrw:nAt := 1
oBrw:Refresh()

Return                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTreeSeek       บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcura um n๓ na arvore                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ cPesq  - ID do n๓                                               บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TreeSeek(oTree,cPesq)
	
Local nPos	:= 0 //posi็ใo do produto no vetor          

If !Empty(cPesq)			
	//Procura pelo produto
	nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) ==  Upper(subStr(x[4],1,at("-",x[4] ) - 1)) } )
	 
	//Procura pela categoria
	If nPos == 0
		nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) $  Upper(RTrim(x[4])) } )	
	EndIf
	
	If nPos > 0
		oTree:TreeSeek(oTree:aCargo[nPos,1])
	Else
		Alert(STR0060)  //"Digite o c๓digo do produto ou categoria para pesquisar."
	EndIf	
Else
	Alert(STR0059)
EndIf

Return              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFindPrd        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcura um produto no TwBrowse								   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oBrw   - objeto TWBrowse                                        บฑฑ
ฑฑบ          ณ cPesq  - c๓digo do produto a ser localizado                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FindPrd(oBrw,cPesq)
Local nPos := 0 //posi็ใo do produto no TwBrose

nPos := aScan(oBrw:aArray,{|x| RTrim(x[1]) == RTrim(cPesq)})               

If nPos == 0
	nPos := aScan(oBrw:aArray,{|x|  RTrim(cPesq) $ RTrim(x[2]) })               
EndIf

If nPos > 0
	oBrw:nAt := nPos
	oBrw:Refresh()
Else
	Alert(STR0054) //"Produto nใo encontrado"
EndIf
	
Return            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMarkAll        บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca/Desmarca todos os n๓s da arvore                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oTree  - objeto xTree  		    							   บฑฑ 
ฑฑบ          ณ oBrw   - objeto TWBrowse                                        บฑฑ
ฑฑบ          ณ oSayTot- Objeto TSay 	     								   บฑฑ 
ฑฑบ          ณ nPos   - Posi็ใo do n๓                                          บฑฑ     
ฑฑบ          ณ nOpc   - 1 - Marca/Desmarca todos os itens/ 2 -Inverte marca็ใo บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarkAll(oTree,oBrw,oSayTot,nOpc)
Local nX := 0     //contador            
Local lMarca := .F. //verifica se o n๓ estแ marcado ou nใo                      
Local bCode := Nil  //irแ informar a nova situa็ใo do n๓
            
If nOpc == 1
	lMarca := IIf(Len(oTree:aCargo)>0,!(eval(oTree:aCargo[1,3])),.F.)
	
	If lMarca
		bCode := {|| .T.}
		cResource := "LBTIK"
	Else
		bCode := {|| .F.}
		cResource := "LBNO"
	EndIf
	
	For nX := 1 to Len(oTree:aCargo)
		oTree:aCargo[nX,3] := bCode
		oTree:ChangeBmp(cResource,cResource,oTree:aCargo[nX,1])    
		AtuPrdBrw(oTree,oBrw,oSayTot,nX,lMarca)
	Next nX
Else
	For nX := 1 to Len(oTree:aCargo)
		lMarca := !(eval(oTree:aCargo[nX,3]))
	
		If lMarca
			bCode := {|| .T.}
			cResource := "LBTIK"
		Else
			bCode := {|| .F.}
			cResource := "LBNO"
		EndIf
	
		oTree:aCargo[nX,3] := bCode
		oTree:ChangeBmp(cResource,cResource,oTree:aCargo[nX,1])    
		AtuPrdBrw(oTree,oBrw,oSayTot,nX,lMarca)
	Next nX	
EndIf

oTree:Refresh()
Return                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRetCatPrd      บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna todos os produtos abaixo do n๓ pai                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPai  - C๓digo do produto pai   							   บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetCatPrd(cCodPai)                 
Local aTree     := {} //vetor com itens para a arvore                                             
Local aOrd      := ACU->(GetArea()) //armazena ordem atual da tabela   
Local lUpdLo128 := AliasIndic("MG3") .AND. MG3->(FieldPos("MG3_CODIGO")) > 0  // Verifica se o update foi executado     
Local cCatAte   := Iif(lUpdLo128,MV_PAR06,'')  // Codigo categoria ate para filtragem

DEFAULT cCodPai := ""                     

If Empty(cCodPai)
    If lUpdLo128
	    ACU->(dbSetOrder(1))
		If ACU->(dbSeek(xFilial("ACU")+MV_PAR05))
			If !Empty(ACU->ACU_CODPAI)
				If ACU->(dbSeek(xFilial("ACU")+ACU->ACU_CODPAI))
					cCodPai := ACU->ACU_COD
					aTree := {ACU->ACU_COD,ACU->ACU_DESC,{}}
				EndIf
			Else                           
				cCodPai := ACU->ACU_COD
				aTree := {ACU->ACU_COD,ACU->ACU_DESC,{}}
			EndIf
		Else
			aTree := {"","",{}}
	    EndIf
	Else 
		aTree := {"","",{}}
	EndIf	    	
Else      
    ACU->(dbSetOrder(1))
    ACU->(dbSeek(xFilial("ACU")+cCodPai))
    aTree := {ACU->ACU_COD,ACU->ACU_DESC,{}}	                  
EndIf                       
    
ACU->(dbSetOrder(2))
If lUpdLo128
	addNodeTree(aTree[3],cCodPai,cCatAte)               
Else
	addNodeTree(aTree[3],cCodPai)               	
EndIf	
                     
RestArea(aOrd) 

Return aClone(aTree)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณaddNodeTree    บAutor  ณMicrosiga           บ Data ณ  05/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo recursiva que adiciona todos os itens no vetor            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aTree    - Vetor que serแ adicionado os produtos         	   บฑฑ 
ฑฑบ			 ณ cCodPai  - C๓digo do produto pai   							   บฑฑ 
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function addNodeTree(aTree,cCodPai,cCatAte)
Local aOrd := ACU->(GetArea()) //armazena ordem atual da tabela
Local lUpdLo128 := AliasIndic("MG3") .AND. MG3->(FieldPos("MG3_CODIGO")) > 0  // Verifica se o update foi executado     
Default cCatAte:= Replicate("Z", TamSx3("ACU_COD")[1])

If (ACU->(dbSeek(xFilial("ACU")+cCodPai)))
	If lUpdLo128
		While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai) .AND. RTrim(ACU->ACU_COD) <= RTrim(cCatAte)
	    	aAdd(aTree,{ACU->ACU_COD,ACU->ACU_DESC,{}})
	     	addNodeTree(aTree[Len(aTree)][3],ACU->ACU_COD,cCatAte)                 
	     	ACU->(dbSkip())
		EndDo	
	Else
		While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai) 
	    	aAdd(aTree,{ACU->ACU_COD,ACU->ACU_DESC,{}})
	     	addNodeTree(aTree[Len(aTree)][3],ACU->ACU_COD)                 
	     	ACU->(dbSkip())
		EndDo	
	EndIf	
EndIf      
   
RestArea(aOrd)

Return                      
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325VLDGRD     บAutor  ณMicrosiga           บ Data ณ  25/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar pre็o dos produtos no Model                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325VLDGRD(oModel)
Local lRet  := .T.
Local nX 	:= 0 //Contador          
Local aCols := oModel:GetModel("SAYDETAIL"):aCols
           
For nX := 1 to Len(aCols)       
	If  !(Empty(aCols[nX,2])) .And. FwFldGet("AY_PRCSUG",nX) <= 0 .And. !(aCols[nx,Len(aCols[nx])])
		HELP('MATA325',, 'MATA325',, STR0061+RTrim(FwFldGet("AY_PRODUTO",nX))+STR0062, 1, 0)   //'Este registro j๏ฟฝ foi efetivado. N๏ฟฝo pode ser alterado.'		
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTAMCPOS        บAutor  ณMicrosiga           บ Data ณ  06/11/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o tamanho dos campos para efetiva็ใo da tabela          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldTamCpos()
Local lCposDiv := .T. //flag para informar se os campos estใo diferentes
Local aTamDA1  := TamSX3("DA1_PRCVEN")
Local aTamSAY  := TamSX3("AY_PRCSUG")  

If aTamDA1[1] <> aTamSAY[1] .Or. aTamDA1[2] <> aTamSAY[2]     
	lCposDiv := .F.	                                                              
EndIf 
	
Return lCposDiv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณM325Legend     บAutor  ณMicrosiga           บ Data ณ  16/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a janela de legenda								           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M325Legend()

Local aLegenda := {	{"BR_VERMELHO"	,	STR0002},; 	//"Efetivada"
                   	{"BR_AMARELO"	,	STR0003},; 	//"Parcialmente efetivada"
					{"BR_VERDE"		,	STR0004}} 	//"Em elabora็ใo"

BrwLegenda(STR0001,STR0065,aLegenda)//"Publica็๕es de Pre็os" - "Legenda"
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CposForm บAutor  ณ Daniel Leme        บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Avalia a Planilha de Forma็ใo de Pre็os e cria colunas no  บฑฑ
ฑฑบ          ณ grid para visualizar ou editar, conforme op็ใo da planilha บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CposForm(oStruModel,lModelDef,oModel)
Local cAliasTRB 	:= GetNextAlias()
Local cQuery 		:= ""
Local nPosPSug		:= 0
Local cOrdem 		:= ""
Local cNomeCpo		:= ""
Local nOperacao	:= oModel:GetOperation() //Controle de operacao

Default l325Perg	:= .T.
Default cCodPlan	:= ""
Default cCodRev	:= ""

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return
EndIf

Pergunte("MTA325",l325Perg)
l325Perg := .F.

If AliasInDic("SC0") .And. AliasInDic("SAV") .And. AliasInDic("SCI") .AND. SCO->(FieldPos("CO_INTPUB")) > 0
	cQuery := " SELECT CO_LINHA, CO_DESC, CO_FORMULA, CO_INTPUB"
	cQuery += " FROM " + RetSqlName("SCO") + " SCO "
	cQuery += " WHERE "
	cQuery += "    CO_FILIAL      = '" + xFilial("SCO") + "'"
	cQuery += "    AND CO_CODIGO  = '" + cCodPlan       + "'"
	cQuery += "    AND CO_REVISAO = '" + cCodRev        + "'"
	cQuery += "    AND CO_INTPUB IN('1','2')"
	cQuery += "    AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY CO_LINHA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)
	
	Do While (cAliasTRB)->(!Eof())
	
		//-- ModelDef
		If lModelDef 
	
			//-- Item de Precifica็ใo
			If "ITPRC" $ (cAliasTRB)->CO_FORMULA
				cNomeCpo := "ITPRC_"+Substr((cAliasTRB)->CO_FORMULA, 8, Len(SAV->AV_CODPRC))
				SAV->( DbSetOrder (1) ) //-- AV_FILIAL+AV_CODPRC
				If SAV->( MsSeek( xFilial("SAV") + Substr((cAliasTRB)->CO_FORMULA, 8, Len(SAV->AV_CODPRC)) ))
					oStruModel:AddField( ;
						Left((cAliasTRB)->CO_DESC,12), ;															// [01] Titulo do campo
						(cAliasTRB)->CO_DESC, ;																		// [02] ToolTip do campo
						cNomeCpo, ;																						// [03] Id do Field
						Iif( SAV->AV_TIPO == "1","N","C"), ;													// [04] Tipo do campo
						Iif( SAV->AV_TIPO == "1",TamSX3("CI_CNTNUM")[1],Iif(SAV->AV_TIPO == "2",1,25)), ;							// [05] Tamanho do campo
						Iif( SAV->AV_TIPO == "1",TamSX3("CI_CNTNUM")[2],0), ;								// [06] Decimal do campo
						FWBuildFeature(STRUCT_FEATURE_VALID," A325IntPlan()"), ;							// [07] Code-block de valida็ใo do campo
						Nil, ;																							// [08] Code-block de valida็ใo When do campo
						Nil, ;																							// [09] Lista de valores permitido do campo
						.F., ;																							// [10] Indica se o campo tem preenchimento obrigat๓rio
						FWBuildFeature(STRUCT_FEATURE_INIPAD," A325Cnt('"+cNomeCpo+"','"+cCodPlan+"','"+cCodRev+"','"+Iif(SAV->AV_TIPO=="1","N","C")+"')"), ;			// [11] Code-block de inicializacao do campo
						NIL, ;																							// [12] Indica se trata-se de um campo chave
						(cAliasTRB)->CO_INTPUB!="2", ;															// [13] Indica se o campo pode receber valor em uma opera็ใo de update.
						.T.)																								// [14] Indica se o campo ้ virtual
				EndIf
	
			//-- Linha de F๓rmula da Forma็ใo de Pre็os 
			Else
				cNomeCpo := "LINEP_"+(cAliasTRB)->CO_LINHA
				oStruModel:AddField( ;
					Left((cAliasTRB)->CO_DESC,12), ;															// [01] Titulo do campo
					(cAliasTRB)->CO_DESC, ;																		// [02] ToolTip do campo
					cNomeCpo, ;																						// [03] Id do Field
					"N", ;																							// [04] Tipo do campo
					TamSX3("CI_CNTNUM")[1], ;																	// [05] Tamanho do campo
					TamSX3("CI_CNTNUM")[2], ;																	// [06] Decimal do campo
					FWBuildFeature(STRUCT_FEATURE_VALID," A325IntPlan()"), ;							// [07] Code-block de valida็ใo do campo
					Nil, ;																							// [08] Code-block de valida็ใo When do campo
					Nil, ;																							// [09] Lista de valores permitido do campo
					.F., ;																							// [10] Indica se o campo tem preenchimento obrigat๓rio
					FWBuildFeature(STRUCT_FEATURE_INIPAD," A325Cnt('"+cNomeCpo+"','"+cCodPlan+"','"+cCodRev+"','"+Iif(SAV->AV_TIPO=="1","N","C")+"')"), ;			// [11] Code-block de inicializacao do campo
					NIL, ;																							// [12] Indica se trata-se de um campo chave
					(cAliasTRB)->CO_INTPUB!="2", ;															// [13] Indica se o campo NAO poderแ receber valor em uma opera็ใo de update.
					.T.)																								// [14] Indica se o campo ้ virtual
			EndIf		
	
		//-- ViewDef
		Else
			//-- Ajusta a ordem do Campo na View
			nPosPSug	:= aScan( oStruModel:aFields, {|x| 	AllTrim( x[MVC_VIEW_IDFIELD] ) == "AY_PRCSUG"} )
			cOrdem 	:= oStruModel:aFields[nPosPSug][MVC_VIEW_ORDEM]
			oStruModel:aFields[nPosPSug][MVC_VIEW_ORDEM] := Soma1(cOrdem)
	
			If "ITPRC" $ (cAliasTRB)->CO_FORMULA
				cNomeCpo := "ITPRC_"+Substr((cAliasTRB)->CO_FORMULA, 8, Len(SAV->AV_CODPRC))
				SAV->( DbSetOrder (1) ) //-- AV_FILIAL+AV_CODPRC
				If SAV->( MsSeek( xFilial("SAV") + Substr((cAliasTRB)->CO_FORMULA, 8, Len(SAV->AV_CODPRC)) ))
					oStruModel:AddField( ;
						cNomeCpo , ;																					// [01] Campo
						cOrdem, ; 																						// [02] Ordem
						Left((cAliasTRB)->CO_DESC,12) , ;														// [03] Titulo
						(cAliasTRB)->CO_DESC, ;																		// [04] Descricao
						NIL, ;																							// [05] Help
						Iif( SAV->AV_TIPO == "1","GET","COMBO"), ;											// [06] Tipo do campo   COMBO, Get ou CHECK
						Iif( SAV->AV_TIPO == "1",PesqPict("SCI","CI_CNTNUM"),Iif(SAV->AV_TIPO == "3","@!","@!")), ;															// [07] Picture
						, ;																								// [08] PictVar
						, ;																								// [09] F3
						(cAliasTRB)->CO_INTPUB=="2", ;															// [10] Editavel
						, ;																								// [11] Folder
						, ;																								// [12] Group
						Iif(SAV->AV_TIPO == "2",{"1=Sim","2=Nใo"},Nil), ;									// [13] Lista Combo
						, ;																								// [14] Tam Max Combo
						, ;																								// [15] Inic. Browse
						.T.)																								// [16] Virtual
				EndIf
			Else
				cNomeCpo := "LINEP_"+(cAliasTRB)->CO_LINHA
				oStruModel:AddField( ;
					cNomeCpo , ;																					// [01] Campo
					cOrdem, ; 																						// [02] Ordem
					Left((cAliasTRB)->CO_DESC,12) , ;														// [03] Titulo
					(cAliasTRB)->CO_DESC, ;																		// [04] Descricao
					NIL, ;																							// [05] Help
					"GET", ;																							// [06] Tipo do campo   COMBO, Get ou CHECK
					PesqPict("SCI","CI_CNTNUM"), ;															// [07] Picture
					, ;																								// [08] PictVar
					, ;																								// [09] F3
					(cAliasTRB)->CO_INTPUB=="2", ;															// [10] Editavel
					, ;																								// [11] Folder
					, ;																								// [12] Group
					, ;																								// [13] Lista Combo
					, ;																								// [14] Tam Max Combo
					, ;																								// [15] Inic. Browse
					.T.)																								// [16] Virtual
			EndIf
		EndIf
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA325IntPlanบAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua integra็ใo entre planilha de forma็ใo e publica็ใo  บฑฑ
ฑฑบ          ณ preenchendo os valores nos campos                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325IntPlan(lIni) 
Local lRet			:= .T.  //Flag de retorno  
Local oModel 		:= FwModelActive()
Local nOperacao	:= oModel:GetOperation() //Controle de operacao
Local nLine			:= oModel:GetModel("SAYDETAIL"):GetLine() //Controle de numero da linha
Local aHeadPar		:= oModel:GetModel("SAYDETAIL"):aHeader
Local aColsPar		:= oModel:GetModel("SAYDETAIL"):aCols
Local nPreco 		:= 0
Local lSvCols		:= (Type("aCols") == "A" .And. Type("aHeader") == "A")
Local aSvCols, aSvHead, bError 
Local nx			:= 0 

//-- Default Arguments
Default lIni := .T.
//-- Default Statics
// Projeto Precificacao
// Erro na perquisa do campo AY_CATEGO
Default lNewInt := AliasInDic("SAV") .And. AliasInDic("SCI") .And. FindFunction("MA317IniPr") .And. FindFunction("C010ClrVLine") .And. SAY->( FieldPos("AY_CATEGO")) > 0
                  
If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0	
	Return lRet
EndIf

If aMTA325 == NIL
	Pergunte( "MTA325", .F. ) 
	aMTA325 := {}
	For nx :=1 to 60
		aAdd(aMTA325,&("mv_par"+strzero(nx,2,0)))
	Next nX
			
	// Jแ tenho o grupo de perguntas e devo "carregar"
Else
	For nx:=1 to 60
		&("mv_par"+strzero(nx,2,0)):=aMTA325[nx]
	Next nX
EndIf

Private cArqMemo   := MV_PAR01 
Private lDirecao   := .T.  
Private nQualCusto := 1
Private cProg      := "R430"

If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE

	ACU->(DbSetOrder(1)) //-- ACU_FILIAL+ACU_COD
	If lNewInt
		ACU->(MsSeek(xFilial("ACU")+FwFldGet("AY_CATEGO",nLine)))
 	EndIf  

	SB1->(DbSetOrder(1)) //-- B1_FILIAL+B1_COD
	If SB1->(DbSeek(xFilial("SB1")+FwFldGet("AY_PRODUTO",nLine))) 

		// se nao NIL quer dizer que nใo carregou o grupo de perguntas MTC010
		If aMTC010 == NIL
			Pergunte( "MTC010", .F. )  //-- Este pergunte serve para a funcao MC010Forma, sem os MV_PARXX ocorre error log.
			aMTC010 := {}
			For nx :=1 to 60
				aAdd(aMTC010,&("mv_par"+strzero(nx,2,0)))
			Next nX
			
		// Jแ tenho o grupo de perguntas e devo "carregar"
		Else
			For nx:=1 to 60
				&("mv_par"+strzero(nx,2,0)):=aMTC010[nx]
			Next nX
		EndIf
	
		If lSvCols
			aSvCols	:= aClone( aCols )
			aSvHead	:= aClone( aHeader )
		EndIf
        
		bError := ErrorBlock( {|| lRet := .F., A325Err(  ) } )
		Begin Sequence
		   
			If lNewInt
				//-- Inicializa Dados da Publica็ใo na Planilha e Cadastro de Itens de Precifica็ใo x Categoria x Produto
				If lIni
					//-- Inicializa pela digita็ใo da Tela
					C010ClrVLine()
					aEval( aHeadPar, {|x,y| Iif( 	Left(x[2],6) $ "ITPRC_",;
				     										MA317IniPr( Substr( x[2], 7 ), Iif( x[2] $ ReadVar(), &(ReadVar()), aColsPar[nLine,y] ) ),;
				     										Iif(	Left(x[2],6) $ "LINEP_",;
				     												C010SetVLin( Val(Substr( x[2], 7 ))+1, Iif( x[2] $ ReadVar(), &(ReadVar()), aColsPar[nLine,y] )),;
				     												Nil) ) })
				Else
					//-- Inicializa pelo cadastro de Itens de Precifica็ใo por CategoriaxProduto
					aEval( aHeadPar, {|x,y| Iif( 	Left(x[2],6) $ "ITPRC_",;
				     										MA317IniPr( Substr(x[2],7),;
				     														Iif( 	x[2] $ ReadVar(),;
				     																&(ReadVar()),;
				     																MATA317Cnt(SB1->B1_COD, Substr(x[2],7)) )),;
		     												Nil)  })
				EndIf	
			EndIf			
			//-- Faz Chamada ao Cแlculo da Planilha de Forma็ใo de Pre็os
			If lForm2
				aVet := MC010Form2( "SB1", SB1->( RecNo() ), 98,,, .F.,,.T.,SCO->CO_CODIGO,SCO->CO_REVISAO )
			Else
				aVet := MC010Forma( "SB1", SB1->( RecNo() ), 98,,, .F. )
			EndIf
	
			//-- Atualiza colunas afetadas pelo calculo na publica็ใo
			If ValType( aVet ) == "A"
				If (nPos := aScan( aVet, {|x| RTrim( x[3] ) == "#PUBLICACAO" }) ) > 0   
					nPreco := aVet[nPos,6]
				EndIf
	         
				If lNewInt
					aEval( aHeadPar, {|x,y| Iif(	Left(x[2],6) $ "LINEP_" .And. !(x[2] $ ReadVar()),;
															aColsPar[nLine,y] := aVet[ Val(Substr( x[2], 7 ))+1,6],;
		     												Iif( (!lIni .And. Left(x[2],6) $ "ITPRC_" .And. !(x[2] $ ReadVar()) );
		     														.Or. (!(x[2] $ ReadVar()) .And. ValType(MATA317Cnt(SB1->B1_COD, Substr(x[2],7) )) == "C" ) ,;
		     														aColsPar[nLine,y] := MATA317Cnt(SB1->B1_COD, Substr(x[2],7) ) ,;
		     														Nil);
		     												)  })
				EndIf
			EndIf
        Recover  	 
            lRet:=.F.
		End Sequence
		ErrorBlock(bError)
		//-- Limpa Dados estแticos da Planilha de Forma็ใo e do Cadastro de Itens de Precifica็ใo x Categoria x Produto
		If lNewInt
			C010ClrVLine()
			MA317FimPr()
		EndIf
				
		If lSvCols
			aCols		:= aClone( aSvCols )
			aHeader	:= aClone( aSvHead )
		EndIf

		// Jแ tenho o grupo de perguntas e devo "carregar"
		For nx:=1 to 60
			&("mv_par"+strzero(nx,2,0)):=aMTA325[nx]
		Next nX
		
	EndIf

   If lRet .And. nPreco > 0
		oModel:SetValue("SAYDETAIL","AY_PRCSUG",nPreco)
	EndIf

EndIf
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMA325CommitบAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Commit do MVC - Faz chamada para a grava็ใo da tabela SDY  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MA325Commit(oModel)
Local lRet := .T.

bError := ErrorBlock( {|| lRet := .F., A325Err(  ) } )
Begin Transaction 
	FwFormCommit(oModel,,{|oModel,cID,cAlias,lNewRecord| MA325GrComp(oModel,cID,cAlias,lNewRecord)})
	
End Transaction  
ErrorBlock(bError)

If  !lRet
  	Alert(STR0067)// "Erro ao gravar componentes"
EndIf 

cCodPlan := Nil
cCodRev  := Nil

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMA325GrCompบAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava componentes integrados เ planilha de forma็ใo de     บฑฑ
ฑฑบ          ณ pre็os - tabela SDY                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MA325GrComp(oModelPar,cID,cAlias,lNewRecord)
Local aArea			:= GetArea()
Local aAreaSDY		:= {}
Local aAreaSAV		:= {}
Local oModel 		:= FwModelActive()
Local nOperacao	:= oModel:GetOperation() //Controle de operacao
Local nLine			:= oModel:GetModel("SAYDETAIL"):GetLine() //Controle de numero da linha
Local aHeadPar		:= oModel:GetModel("SAYDETAIL"):aHeader
Local aColsPar		:= oModel:GetModel("SAYDETAIL"):aCols
Local cSequen		:= ""
Local nJ

Default cCodPlan 	:= ""
Default cCodRev 	:= ""

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return .T.
EndIf

If cAlias == "SAX" .Or. nOperacao == MODEL_OPERATION_UPDATE
	If SAX->(FieldPos("AX_CODPLA")) > 0 .And. SAX->(FieldPos("AX_REVPLA")) > 0 .And. cCodPlan+cCodRev != SAX->(AX_CODPLA+AX_REVPLA)
		RecLock("SAX",.F.)
			SAX->AX_CODPLA := cCodPlan
			SAX->AX_REVPLA := cCodRev
		SAX->(MsUnLock())

	EndIf
EndIf

// Tratamento para que na copia de uma publica็ใo "efetivada", seja gerada com legenda verde "".
If nOperacao == 3 .And. SAX->AX_EFETIVO <> "3"
	RecLock("SAX",.F.)
	SAX->AX_EFETIVO := "3"
	SAX->(MsUnLock())
EndIf
If cAlias == "SAY" .And. AliasInDic("SDY") .And. AliasInDic("SAV")
	aAreaSDY		:= SDY->(GetArea())
	aAreaSAV		:= SAV->(GetArea())
	cSequen		:= StrZero( 1, Len(SDY->DY_SEQUEN) )

	SDY->( DbSetOrder( 2 )) //-- DY_FILIAL+DY_CODIGO+DY_ITEM+DY_SEQUEN
	
	If !oModel:GetModel("SAYDETAIL"):IsDeleted() .And. (nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE) 
	
		For nJ := 1  To Len( aHeadPar )
	      
			SAV->( DbSetOrder( 1 )) //-- AV_FILIAL+AV_CODPRC
	      If Left(aHeadPar[nJ][2],6) $ "ITPRC_/LINEP_" .And.;
	      	aHeadPar[nJ][8] == "N" .Or.;
	      	(  Left(aHeadPar[nJ][2],6) $ "ITPRC_" .And.;
	      	   SAV->( MsSeek( xFilial("SAV") + Substr( aHeadPar[nJ][2], 7 ) )) .And.;
	      	   SAV->AV_TIPO == "2"  ) 
	
				If !SDY->(MsSeek( xFilial("SDY") + SAY->(AY_CODIGO + AY_ITEM ) + cSequen ) )
					RecLock("SDY",.T.)
					SDY->DY_FILIAL		:= xFilial("SDY")
					SDY->DY_CODIGO		:= SAY->AY_CODIGO
					SDY->DY_ITEM		:= SAY->AY_ITEM
					SDY->DY_SEQUEN		:= cSequen
				Else
					RecLock("SDY",.F.)
				EndIf
		
				SDY->DY_PRODUTO	:= SAY->AY_PRODUTO
		
				If "ITPRC_" $ aHeadPar[nJ][2]
	
					SDY->DY_LINHA	:= " "
					SDY->DY_CODPRC	:= Substr( aHeadPar[nJ][2], 7 )
					SDY->DY_VALOR	:= Iif( ValType(FwFldGet(aHeadPar[nJ][2],nLine)) == "N", FwFldGet(aHeadPar[nJ][2],nLine), Val(FwFldGet(aHeadPar[nJ][2],nLine)) )
					//SDY->DY_VALOR	:= Iif( ValType(aColsPar[nLine][nJ]) == "N", aColsPar[nLine][nJ], 0 )
					
				ElseIf "LINEP_" $ aHeadPar[nJ][2]
	
					SDY->DY_LINHA	:= Substr( aHeadPar[nJ][2], 7 )
					SDY->DY_CODPRC	:= " "
					SDY->DY_VALOR	:= FwFldGet(aHeadPar[nJ][2],nLine)
					//SDY->DY_VALOR	:= aColsPar[nLine][nJ]
		
				EndIf
				SDY->( MsUnLock() )
	
				cSequen := Soma1(cSequen)
	
			EndIf
		Next nJ
	EndIf
	
	If !oModel:GetModel("SAYDETAIL"):IsDeleted() .And. nOperacao == MODEL_OPERATION_DELETE
		Do While SDY->( MsSeek( xFilial("SDY") + SAY->(AY_CODIGO + AY_ITEM) ) )
			RecLock("SDY", .F., .T.)
			SDY->( DbDelete() )
			SDY->( MsUnLock() )
		EndDo
		cSequen := Soma1(cSequen)
	EndIf

	RestArea( aAreaSAV )
	RestArea( aAreaSDY )
EndIf

RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A325Cnt   บAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obt้m o conte๚do dos campos salvos na publica็ใo           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325Cnt(cVar,cCodPlan,cCodRev,cTpRet)
Local aArea			:= GetArea()
Local aAreaSAV		:= SAV->(GetArea())
Local aAreaSDY		:= SDY->(GetArea())
Local oModel 		:= FwModelActive()
Local nOperacao	:= oModel:GetOperation() //Controle de operacao
Local cSeek			:= ""
Local uRet			:= Iif(cTpRet == "C", " ", 0 )

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return 0
EndIf

If nOperacao != MODEL_OPERATION_INSERT .And.;
	(nOperacao != MODEL_OPERATION_UPDATE .Or. cCodPlan+cCodRev == SAX->(AX_CODPLA+AX_REVPLA))

	SAV->( DbSetOrder(1) ) //-- AV_FILIAL+AV_CODPRC
	SDY->( DbSetOrder(3) ) //-- DY_FILIAL+DY_CODIGO+DY_ITEM+DY_LINHA+DY_CODPRC 

	If "ITPRC_" $ cVar
		cSeek := xFilial("SDY") + SAX->AX_CODIGO + SAY->AY_ITEM + Space(Len(SDY->DY_LINHA)) + Substr(cVar,7)
	Else
		cSeek := xFilial("SDY") + SAX->AX_CODIGO + SAY->AY_ITEM + Substr(cVar,7)
	EndIf

	If "ITPRC_" $ cVar .And. SAV->( MsSeek( xFilial("SAV") + Substr( cVar, 7 ) ))
		If SAV->AV_TIPO == "3"
			uRet := MATA317Cnt( SAY->AY_CODIGO, Substr(cVar,7), SAY->AY_CATEGO, SAV->AV_FORMUL )
		ElseIf SDY->(MsSeek( cSeek ))
			uRet := Iif( SAV->AV_TIPO == "1", SDY->DY_VALOR, AllTrim(Str(SDY->DY_VALOR)) )
		EndIf
	ElseIf SDY->(MsSeek( cSeek ))
		uRet := SDY->DY_VALOR
	EndIf
EndIf

RestArea( aAreaSAV )
RestArea( aAreaSDY )
RestArea( aArea )

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A325Err   บAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento de erros nos blocos em sequencia nos fontes     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325Err()

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return
EndIf

If InTransact()
	DisarmTransaction()
EndIf

Break

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A325TabDt บAutor  ณ Daniel Leme       บ Data ณ  04/27/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna tabelas de precos ativas num determinado periodo   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325TabDt(aGrpFil,dDatIni,cHorIni,dDatFim,cHorFim)
Local aAreas		:= {GetArea()}
Local aTabs			:= {}
Local cAliasTrb	:= GetNextAlias()
Local cQuery		:= ""
Local nI				:= 0
Local lLjCnVda := SuperGetMv("MV_LJCNVDA",,.F.) // caso o parametro MV_LJCNVDA esteja ativo, deve utilizar SB0 e SB1 no lugar da DA0 e DA1 para lista de precos

Default aGrpFil	:= {cFilAnt}
Default dDatIni	:= dDataBase
Default cHorIni	:= Space(5)
Default dDatFim	:= dDatIni
Default cHorFim	:= "23:59"     

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return aTabs
EndIf

// Projeto Precificacao
// caso o parametro MV_LJCNVDA esteja ativo, deve utilizar DA0 e DA1 no lugar da SB0 e SB1 para lista de precos
If lLjCnVda
	For nI := 1 To Len(aGrpFil)
		//-- Montagem da Query para sele็ใo das Tabelas de Pre็o 
		cQuery := " SELECT DA0_FILIAL, DA0_CODTAB, R_E_C_N_O_ NRECNO "
		
		cQuery += " FROM " + RetSqlName("DA0") + " DA0 "
		
		cQuery += " WHERE"
		cQuery += "     DA0.DA0_FILIAL     = '" + xFilial("DA0",aGrpFil[nI]) + "'"
		cQuery += "     AND DA0.D_E_L_E_T_ = ' '"
		cQuery += "     AND DA0.DA0_ATIVO  = '1'" 
		
		cQuery += "     AND (DA0_DATDE           < '" + DtoS(dDatIni) + "'"
		cQuery += "          OR (DA0_DATDE       = '" + DtoS(dDatIni) + "'"
		cQuery += "              AND DA0_HORADE <= '" + cHorIni       + "'))"
		
		cQuery += "     AND (DA0_DATATE          = ' '"
		cQuery += "          OR DA0_DATATE       > '" + DtoS(dDatFim) + "'"
		cQuery += "          OR (DA0_DATATE      = '" + DtoS(dDatFim) + "'"
		cQuery += "              AND DA0_HORATE >= '" + cHorFim       + "'))"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTrb,.F.,.T.)
		
		//-- Percorre a Query e adiciona o resultado no array de Retorno
		(cAliasTrb)->( DbEval( {|| aAdd( aTabs, {DA0_FILIAL,DA0_CODTAB,NRECNO} ) })  )
		(cAliasTrb)->( DbCloseArea() )
	Next nI

Endif

//-- Restaura as areas selecionadas
aEval( aAreas, { |xArea| RestArea(xArea) } )

Return aTabs


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA325TabEfetบAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para sele็ใo de tabelas de Pre็o por Filial para a    บฑฑ
ฑฑบ          ณ efetiva็ใo                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A325TabEfet( aGrpFil, aTabs )
Local aAreas	:= {	SM0->(GetArea()),;
							GetArea() }
Local nI       := 0
Local oFont    := TFont():New( "Courier New", 6, 15 )
Local nTLinhas := 0   
Local nPos		:= 0
Local lRet		:= .T.

//-- Dialog
Local oDlgAux

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- Enchoice
Local aVisual := {}
Local aAltera := {}

//-- GetDados
Local nNumLinhas  := 999
Local nLinhaPE	  := 0  //Retorno do P.E FT325NMax	

//-- GetDados
Local aPosObj := {}  
Local aHeadAux := {}
Local aColsAux := {}

Private oGetTab,oEnch
 
//Ponto de entrada para manipula็ใo da quantidade de linhas - Somente Argentina
If cPaisLoc == "ARG" .And. ( ExistBlock("FT325NMax") )
	nLinhaPE := ExecBlock("FT325NMax",.F.,.F.,{Nil})
	If ValType(nLinhaPE) == "N" .And. nLinhaPE > 0
		nNumLinhas := nLinhaPE
	EndIf	
EndIf 
                      
If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return lRet
EndIf

RegToMemory("SAX",.F.)
aAdd(aVisual,"NOUSER")
aAdd(aVisual,"AX_CODIGO")
aAdd(aVisual,"AX_DESCRI")
aAdd(aVisual,"AX_DATAINI")
aAdd(aVisual,"AX_HORAINI")

//-- Monta aHeader Manual
/*** Estrutura do aHeader ***
//-- 01-TITULO
//-- 02-CAMPO
//-- 03-PICTURE
//-- 04-TAMANHO
//-- 05-DECIMAL
//-- 06-VALID
//-- 07-USADO
//-- 08-TIPO
//-- 09-F3
//-- 10-CONTEXT
//-- 11-CBOX
//-- 12-RELACAO
//-- 13-WHEN
//-- 14-VISUAL
//-- 15-VLDUSER
//-- 16-PICTVAR
//-- 17-OBRIGAT
*/
aHeadAux := {}
Aadd(aHeadAux,{RetTitle("AY_ITEM")		,"ITEM"		,PesqPict("SAY","AY_ITEM")		, TamSX3("AY_ITEM")[1]		, TamSX3("AY_ITEM")[2]		, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("AY_FILIAL")	,"FILIAL"	,PesqPict("SAY","AY_FILIAL")	, TamSX3("AY_FILIAL")[1]	, TamSX3("AY_FILIAL")[2]	, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("AY_DESCRI")	,"DESFIL"	,"@!"									, Len(SM0->M0_FILIAL)		, 0								, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("DA0_CODTAB")	,"CODTAB"	,PesqPict("DA0","DA0_CODTAB")	, TamSX3("DA0_CODTAB")[1]	, TamSX3("DA0_CODTAB")[2]	,"(Vazio() .Or. ExistCpo('DA0')) .And. A325VldTab()" , ,"C", "DA0", "V", , , , "A", , , }) 
Aadd(aHeadAux,{RetTitle("DA0_DESCRI")	,"DESTAB"	,PesqPict("DA0","DA0_DESCRI")	, TamSX3("DA0_DESCRI")[1]	, TamSX3("DA0_DESCRI")[2]	, , ,"C", ,"V", , , , "V", , , }) 

//-- Ordena Array de tabelas por Filial + Tabela
aSort( aTabs,,,{|x,y| x[1] + x[2] < y[1] + y[2] }) 

//-- Carrega aCols         
aColsAux := {}
For nI := 1 To Len(aGrpFil)

	aAdd(aColsAux,Array(Len(aHeadAux)+1))
	aColsAux[ nI, Len( aHeadAux)+1 ] := .F.

	GDFieldPut("ITEM"		, StrZero(nI,TamSX3("AY_ITEM")[1])								, nI, aHeadAux, aColsAux )
	GDFieldPut("FILIAL"	, aGrpFil[nI]															, nI, aHeadAux, aColsAux )
	GDFieldPut("DESFIL"	, Posicione("SM0",1,cEmpAnt+aGrpFil[nI],"M0_FILIAL")		, nI, aHeadAux, aColsAux )

	//-- Se Encontrar apenas uma tabela ativa para a Filial, sugere-a
	If ( nPos := aScan(aTabs, { |x| x[1] == xFilial("DA0",aGrpFil[nI]) }) ) > 0 .And.;
		( nPos == Len(aTabs) .Or. xFilial("DA0", aTabs[nPos][1]) != xFilial( "DA0", aTabs[nPos+1][1]) ) 
		
		GDFieldPut("CODTAB"	, aTabs[nPos][2]																					, nI, aHeadAux, aColsAux )
		GDFieldPut("DESTAB"	, Posicione("DA0",1,xFilial("DA0",aGrpFil[nI]) + aTabs[nPos][2], "DA0_DESCRI"), nI, aHeadAux, aColsAux )
		
	Else
	
		GDFieldPut("CODTAB"	, Space(TamSX3("DA0_CODTAB")[1])															, nI, aHeadAux, aColsAux )
		GDFieldPut("DESTAB"	, Space(TamSX3("DA0_DESCRI")[1])															, nI, aHeadAux, aColsAux )
	
	EndIf
Next nI

//-- Restaura as Areas, em virtude de desposicionamento do SM0
aEval( aAreas, { |aAreaX| RestArea(aAreaX) })

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 080, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

//-- Exibe a Tela
DEFINE MSDIALOG oDlgAux TITLE OemToAnsi(STR0068) FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL // "Sele็ใo de Tabelas de Pre็o a serem Encerradas pela Efetiva็ใo"

	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( "SAX", SAX->(Recno()), 2,,,,aVisual, aPosObj[1],aAltera, 3,,,,,,.T. )
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oEnch:aEntryCtrls)
		If oEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI

	//-- MSNewGetDados():New(                    nTop,           nLeft,         nBottom,          nRight,   nStyle ,  uLinhaOk,  uTudoOk, cIniCpos, aAlter, nFreeze,       nMax, cFieldOk, uSuperDel ,  uDelOk, oWnd   , aParHeader, aParCols)
	oGetTab := MSNewGetDados():New( aPosObj[ 2, 1 ], aPosObj[ 2, 2 ], aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], GD_UPDATE,        "",         ,         ,       ,        , nNumLinhas,         ,           ,      "", oDlgAux,   aHeadAux, aColsAux)
	
ACTIVATE MSDIALOG oDlgAux ON INIT EnchoiceBar( oDlgAux, {|| lRet := .T., oDlgAux:End() }, {|| lRet := .F., oDlgAux:End() } ) 

//-- Se confirmar, remonta o array com Tabelas de Pre็o.
aTabs := {}
If lRet

	For nI := 1 To Len( oGetTab:aCols )
		aAdd( aTabs, GdFieldGet( "CODTAB", nI, , oGetTab:aHeader, oGetTab:aCols ) )
	Next nI
EndIf

//-- Restaura as Areas
aEval( aAreas, { |aAreaX| RestArea(aAreaX) })

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A325VldTabบAutor  ณ Daniel Leme       บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Valida็ใo de tabela de Pre็o                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A325VldTab()
Local aAreas 	:= {	DA0->(GetArea()),;
							GetArea()}
Local lRet 		:= .T.
Local aGrpFil	:= {GdFieldGet("FILIAL", oGetTab:oBrowse:nAt,,oGetTab:aHeader, oGetTab:aCols )}
Local aTabs 	:= A325TabDt(aGrpFil, SAX->AX_DATAINI, SAX->AX_HORAINI ) 

If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return lRet
EndIf

If !Empty(M->CODTAB)
	If aScan(aTabs,{ |x| x[2] == M->CODTAB }) > 0 
		GDFieldPut("DESTAB"	, Posicione("DA0",1,xFilial("DA0",aGrpFil[1]) + M->CODTAB, "DA0_DESCRI"), oGetTab:oBrowse:nAt, oGetTab:aHeader, oGetTab:aCols )
	Else
		Alert(STR0069) // "Tabela nใo estแ ativa para o Perํodo da Publica็ใo!"
		lRet := .F.
	EndIf
Else
	GDFieldPut("DESTAB"	, Space(oGetTab:aHeader[GdFieldPos("DESTAB",oGetTab:aHeader)][4]), oGetTab:oBrowse:nAt, oGetTab:aHeader, oGetTab:aCols )
EndIF
oGetTab:Refresh()

//-- Restaura as Areas
aEval( aAreas, { |aAreaX| RestArea(aAreaX) })

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA325TabSB0 บAutor  ณ                   บ Data ณ  05/06/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para sele็ใo de tabelas de Pre็o por Filial para a    บฑฑ
ฑฑบ          ณ efetiva็ใo                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA325                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function A325TabSB0()
Local aAreas	:= {	SM0->(GetArea()), SB0->(GetArea()), SB1->(GetArea()), GetArea() }
Local nI       := 0
Local oFont    := TFont():New( "Courier New", 6, 15 )
Local nTLinhas := 0   
Local nPos		:= 0
Local lRet		:= .T.

//-- Dialog
Local oDlgAux

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- Enchoice
Local aVisual := {}
Local aAltera := {}

//-- GetDados
Local nNumLinhas  := 999
Local nLinhaPE	  := 0  //Retorno do P.E FT325NMax	

//-- GetDados
Local aPosObj := {}  
Local aHeadAux := {}
Local aColsAux := {}

Local cFilSAY	:= xFilial("SAY") //Recebe filial corrente
Local cFilSB1	:= xFilial("SB1")

Private oGetTab,oEnch

//Ponto de entrada para manipula็ใo da quantidade de linhas - Somente Argentina
If cPaisLoc == "ARG" .And. ( ExistBlock("FT325NMax") )
	nLinhaPE := ExecBlock("FT325NMax",.F.,.F.,{Nil})
	If ValType(nLinhaPE) == "N" .And. nLinhaPE > 0
		nNumLinhas := nLinhaPE
	EndIf	
EndIf
                      
If SAX->(FieldPos("AX_CODPLA")) = 0 .OR. SAY->(FieldPos("AY_CATEGO")) = 0
	Return lRet
EndIf

RegToMemory("SAX",.F.)
aAdd(aVisual,"NOUSER")
aAdd(aVisual,"AX_CODIGO")
aAdd(aVisual,"AX_DESCRI")
aAdd(aVisual,"AX_DATAINI")
aAdd(aVisual,"AX_HORAINI")

//-- Monta aHeader Manual
/*** Estrutura do aHeader ***
//-- 01-TITULO
//-- 02-CAMPO
//-- 03-PICTURE
//-- 04-TAMANHO
//-- 05-DECIMAL
//-- 06-VALID
//-- 07-USADO
//-- 08-TIPO
//-- 09-F3
//-- 10-CONTEXT
//-- 11-CBOX
//-- 12-RELACAO
//-- 13-WHEN
//-- 14-VISUAL
//-- 15-VLDUSER
//-- 16-PICTVAR
//-- 17-OBRIGAT
*/
aHeadAux := {}
Aadd(aHeadAux,{RetTitle("AY_ITEM")		,"AY_ITEM"		,PesqPict("SAY","AY_ITEM")		, TamSX3("AY_ITEM")[1]		, TamSX3("AY_ITEM")[2]		, , ,"C", ,"R", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("AY_PRODUTO")	,"AY_PRODUTO"	,PesqPict("SB1","B1_COD")		, TamSX3("B1_COD")[1]		, TamSX3("B1_COD")[2]		, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("B1_DESC")		,"B1_DESC"		,PesqPict("SB1","B1_DESC")		, TamSX3("B1_DESC")[1]		, TamSX3("B1_DESC")[2]		, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("AY_PRCATU")	,"AY_PRCATU"	,PesqPict("SAY","AY_PRCATU")	, TamSX3("AY_PRCATU")[1]	, TamSX3("AY_PRCATU")[2]	, , ,"C", ,"V", , , , "V", , , }) 
Aadd(aHeadAux,{RetTitle("AY_PRCSUG")	,"AY_PRCSUG"	,PesqPict("SAY","AY_PRCSUG")	, TamSX3("AY_PRCSUG")[1]	, TamSX3("AY_PRCSUG")[2]	, , ,"C", ,"V", , , , "V", , , }) 

//-- Carrega aCols
lTpOper := DA1->(FieldPos("DA1_TPOPER")) > 0

SAY->(dbSetOrder(1))	 	// AY_FILIAL+AY_CODIGO+AY_ITEM
SAY->(dbSeek(cFilSAY+SAX->AX_CODIGO))     

Do While SAY->(!EOF()) .AND. SAY->AY_FILIAL == cFilSAY .AND. SAY->AY_CODIGO == SAX->AX_CODIGO 
	cDesc := Posicione("SB1",1,cFilSB1+SAY->AY_PRODUTO,"B1_DESC")

	aAdd(aColsAux,Array(Len(aHeadAux)+1))
	aColsAux[ Len(aColsAux), Len( aHeadAux)+1 ] := .F.

	GDFieldPut("AY_ITEM"		, SAY->AY_ITEM		, Len(aColsAux), aHeadAux, aColsAux )
	GDFieldPut("AY_PRODUTO"	, SAY->AY_PRODUTO	, Len(aColsAux), aHeadAux, aColsAux )
	GDFieldPut("B1_DESC"		, cDesc				, Len(aColsAux), aHeadAux, aColsAux )
	GDFieldPut("AY_PRCATU" 	, SAY->AY_PRCATU	, Len(aColsAux), aHeadAux, aColsAux )
	GDFieldPut("AY_PRCSUG" 	, SAY->AY_PRCSUG	, Len(aColsAux), aHeadAux, aColsAux )

	SAY->(dbSkip())
EndDo   
	                                                                     
//-- Restaura as Areas, em virtude de desposicionamento do SM0
aEval( aAreas, { |aAreaX| RestArea(aAreaX) })

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 080, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

//-- Exibe a Tela
DEFINE MSDIALOG oDlgAux TITLE OemToAnsi(STR0068) FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL // "Sele็ใo de Tabelas de Pre็o a serem Encerradas pela Efetiva็ใo"

	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( "SAX", SAX->(Recno()), 2,,,,aVisual, aPosObj[1],aAltera, 3,,,,,,.T. )
	
	//-- MSNewGetDados():New(             nTop,           nLeft,         nBottom,          nRight,         nStyle ,  uLinhaOk,  uTudoOk, cIniCpos, aAlter, nFreeze,       nMax, cFieldOk, uSuperDel ,    uDelOk, oWnd   , aParHeader, aParCols)
	oGetTab := MSNewGetDados():New( aPosObj[ 2, 1 ], aPosObj[ 2, 2 ], aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], 0 ,        "",         ,         ,       ,        , nNumLinhas,         ,           ,      "", oDlgAux,   aHeadAux, aColsAux)

ACTIVATE MSDIALOG oDlgAux ON INIT EnchoiceBar( oDlgAux, {|| lRet := .T., oDlgAux:End() }, {|| lRet := .F., oDlgAux:End() } ) 

//-- Restaura as Areas
aEval( aAreas, { |aAreaX| RestArea(aAreaX) })

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณA325EFETSB0    บAutor  ณMicrosiga           บ Data ณ  05/06/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetivar tabela de pre็o                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFat                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil   - Filial que serแ efetivada a tabela de pre็o            บฑฑ 
ฑฑบ			 ณ aDA0   - Vetor com dados da tabela DA0                          บฑฑ 
ฑฑบ			 ณ aDA1   - Vetor com dados da tabela DA1                          บฑฑ   
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                     
Function A325EFETSB0() 
Local nX		    := 0          //contador
Local aGrpFil:={} // array de filiais
DA0->(dbSetOrder(1))  // DA0_FILIAL+DA0_CODTAB
DA1->(dbSetOrder(1))  // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
SB0->(dbSetOrder(1))  // B0_FILIAL+B0_COD
	             
BEGIN TRANSACTION
	
	// posiciona na SAX para gravar as informacoes de publicacao na SB0
	cCodSAX := SAX->AX_CODIGO    
	aGrpFil := GetFiliais(SAX->AX_GRUPFIL)    
	//Tratamento caso o campo Grupo de Filiais esteja vazio
	If ( Len(aGrpFil) == 0 )
		AAdd( aGrpFil, xFilial("SB0") )
	EndIf
	SAY->( Dbseek(xFilial("SAY")+cCodSAX))
	Do While SAY->( ! Eof()) .and. SAY->AY_FILIAL == xFilial("SAY") .and. SAY->AY_CODIGO == cCodSAX
	
		For nX:= 1 To Len(aGrpFil)
			If SB0->( DbSeek( aGrpFil[nX]+SAY->AY_PRODUTO))
				RecLock("SB0",.F.)
			Else
				RecLock("SB0",.T.)
				SB0->B0_FILIAL := aGrpFil[nX]
				SB0->B0_COD    := SAY->AY_PRODUTO
			Endif
			SB0->B0_PRV1  := SAY->AY_PRCSUG
			SB0->B0_DATA1 := dDataBase
			SB0->( MsUnLock())
		Next nX	
		SAY->( Dbskip())
	Enddo
	
END TRANSACTION

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |LjParTpPubณ Autor ณ TOTVS                 ณ Data ณ10/06/13  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ For็a a execu็ใo das triggers do campo                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjParTpPub(aGrpFil, nRecno)
Local cParam := SuperGetMv("MV_LJTPPUB",,"1")
Local aTabsAtiv
Local nX

if cParam == '2' .and. FindFunction("A325TabSB0")  // gravacao da publicacao de precos no SB0

	//-- Tela com os produtos para a tabela a ser gerada.
	If A325TabSB0()
	   SAX->(dbGoTo(nRecno))
		Processa( {|| A325EFETSB0()}, STR0031, "Efetivando tabela de pre็os...",.F.) //"Aguarde..."###"Efetivando tabela de pre็os..."

		RecLock("SAX",.F.) 
		SAX->AX_EFETIVO := "1"
		SAX->(MsUnlock())     
	EndIf

Elseif cParam <= '1' // gravacao da publicacao de precos padrao DA0/DA1 	
	If Empty(xFilial("DA0")) //Tabela compartilhada
		aDA0 := SAXtoDA0(aGrpFil[1],SAX->AX_CODIGO)
		aDA1 := SAYtoDA1(aGrpFil[1],SAX->AX_CODIGO)
						
		//-- Tela com tabelas de pre็os ativas para cada tabela a ser gerada.
		aTabsAtiv := A325TabDt( Nil, SAX->AX_DATAINI, SAX->AX_HORAINI ) 
		If A325TabEfet( @aGrpFil, @aTabsAtiv )
			A325EFET(aGrpFil[1],aDA0,aDA1,aTabsAtiv[1])
		   SAX->(dbGoTo(nRecno))
			RecLock("SAX",.F.) 
			SAX->AX_EFETIVO := "1"
			SAX->(MsUnlock())     
		EndIf
	Else
		//-- Tela com tabelas de pre็os ativas para cada tabela a ser gerada.
		aTabsAtiv := A325TabDt(aGrpFil, SAX->AX_DATAINI, SAX->AX_HORAINI )
		If A325TabEfet( @aGrpFil, @aTabsAtiv )
			For nX := 1 To Len(aGrpFil)
				aDA0 := SAXtoDA0(aGrpFil[nX],SAX->AX_CODIGO)
				aDA1 := SAYtoDA1(aGrpFil[nX],SAX->AX_CODIGO)
							
				A325EFET(aGrpFil[nX],aDA0,aDA1,aTabsAtiv[nX])
			Next
		   SAX->(dbGoTo(nRecno))
			RecLock("SAX",.F.) 
			SAX->AX_EFETIVO := "1"
			SAX->(MsUnlock())     
		EndIf
	EndIf
Endif

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณaddForn        บAutor  ณMicrosiga           บ Data ณ  22/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna todos os produtos abaixo do n๓ pai por fornecedor        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLOJA                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function addForn(oTree,oBrw,oSayTot)
Local aArea:= GetArea()// salva area atual
Local cFornece:= ''    // codigo do fornecedor+loja

SA5->(DbSetOrder(1))  
SA5->(DbGoTop())
While SA5->(!EOF() ) .AND. SA5->A5_FORNECE+SA5->A5_LOJA >= MV_PAR07+MV_PAR08 .AND. SA5->A5_FORNECE+SA5->A5_LOJA <= MV_PAR09+MV_PAR10
    If cFornece <> SA5->A5_FORNECE+SA5->A5_LOJA
		oTree:addTree( SA5->A5_NOMEFOR , "LBNO", "LBNO", SA5->A5_FORNECE+SA5->A5_LOJA,, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )	    		
		cFornece := SA5->A5_FORNECE+SA5->A5_LOJA
		oTree:addTreeItem( RTrim(SA5->A5_PRODUTO)+"-"+SA5->A5_NOMPROD, "LBNO", "FOR"+cFornece+"_PRD"+RTrim(SA5->A5_PRODUTO),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} )
	Else
		oTree:addTreeItem( RTrim(SA5->A5_PRODUTO)+"-"+SA5->A5_NOMPROD, "LBNO", "FOR"+cFornece+"_PRD"+RTrim(SA5->A5_PRODUTO),, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot)} ) 	           		
	EndIf
	
	
	SA5->(DbSkip())	
	If cFornece <> SA5->A5_FORNECE+SA5->A5_LOJA
		oTree:EndTree()
	EndIf	
EndDo

RestArea(aArea)

Return               
                  
//-------------------------------------------------------------------
/*/{Protheus.doc} M325Painel()
  
Faz a chamada da funcao onde eh montado o painel de gestao 
    
@author Varejo
@since 30/10/2013
/*/
//-------------------------------------------------------------------- 
Function M325Painel()  

If SAX->AX_EFETIVO=='3'
	M325PlGtFP()
Else  
	
	MsgInfo(STR0101,STR0102)//"A Publica็ใo de pre็o selecionada jแ foi Parcialmente Efetivada ou Efetivada"###"Aten็ใo"	
EndIf	
  
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} M325PlGtFP()
  
Exibe o Painel de Forma็ใo de Pre็o. 
    
@author Varejo
@since 30/10/2013
/*/
//-------------------------------------------------------------------- 
Function M325PlGtFP(aColsPGt,aHeaderPGt)  

Local oDlg       := nil  // Objeto da tela principal
Local oGetD      := Nil  // Objeto do GetDados
Local oPanelAll  := nil  // Objeto Panel que contem a Categoria/ Precos e Percentua&Majoracao 
Local oPanelAll1 := nil  // Objeto Panel que contem Precos 
Local oPanelAll2 := nil  // Objeto Panel que contem Categoria 
Local oPanelAll3 := nil  // Objeto Panel que contem Percentua&Majoracao  
Local oPanelRight:= nil  // Objeto Panel que contem os graficos 
Local aLayers:={nil,nil,nil,nil,nil} // Objetos layer para criacao da tela com layer

Local oProd := nil // objeto que ira receber o layer dos itens da publica็ใo
Local oAcao := nil // objeto que ira receber o layer de acao
Local oCat  := nil // objeto que ira receber o layer de categoria
Local oMarge:= nil // objeto que ira receber o layer de Margem
Local oGraf := nil // objeto que ira receber o layer do grafico
Local oSimu := nil // objeto que ira receber o layer de simulacao

Local oFolder    := nil  // Objeto Folder que contem os graficos dos precos
Local oListBox1  := nil  // Objeto ListBox que contem os precos
Local oListBox2  := nil  // Objeto ListBox que contem as categorias
Local oListBox3  := nil  // Objeto ListBox que contem a Margem Minima e Regular dos produtos
Local oFwChart1  := nil  // Objeto Grafico para exibir os precos dos concorrentes
Local oFWChart2  := nil  // Objeto Grafico para exibir o historico de preco
Local cTitle :=  STR0076+Alltrim(AX_CODIGO) +" - "+Alltrim(AX_DESCRI)//"Painel de Forma็ใo de Pre็o - Publica็ใo: "
Local aSize  := MsAdvSize( .T. )

Local nOpcA     := 0// sem op็ใo para incluir/alterar/excluir  
Local nFreeze	:= 0// sem freeze
Local nMax		:= 999999999 // maximo de itens
Local cLinOk	:= 'AllwaysTrue'   // sempre .T.
Local cTudoOk	:= "AllwaysTrue"   // sempre .T.
Local cIniCpos	:= ""              // sem inicializador
Local cFieldOk	:= "AllwaysTrue"  // sempre .T.
Local cSuperDel	:= ""             // sem valida็ใo
Local cDelOk	:= "AllwaysTrue"  // sempre .T.
Local aAlter    := {}             //Array para campos que podem ser alterados
Local aCatPrd   := {{"",""}}             // Array categoria do produto em foco
Local aMgmPrd   := {{0.00,0.00}}             // Array Margem do produto em foco
Local aPrcPrd   := {{'1',"",0.00,0.00,''}}             // Array precos do produto em foco
Local oBtnOk    := nil             // Botao executar
Local oButMarc  := NIL             // Botao marcar todos
Local oButInv   := NIL             // Bota็ Inverter Selecao 
Local oCombBox1 := nil             // Combobox Percenteual/Preco
Local oCombBox2 := nil             // Combobox Majora็ใo/Desconto

Local aCombBox1 := {STR0103,STR0104}  // Itens ocombobox1 //"1=Percentual"###"2=Pre็o"
Local aCombBox2 := {STR0105,STR0106}// Itens ocombobox2 //"1=Majora็ใo"###"2=Desconto"
Local cCombBox1 := '1' // selecao ocombobox1
Local cCombBox2 := '1' // selecao ocombobox1
Local oExecut   := nil // Objeto valor digitado
Local nExecut   := 0   // Valor digitado

Local oMed		:= LoadBitmap(GetResources(), "BR_AMARELO") // botao para legenda
Local oMim		:= LoadBitmap(GetResources(), "BR_VERMELHO")//botao para legenda
Local oAlt		:= LoadBitmap(GetResources(), "BR_VERDE")   //botao para legenda
 
Local aColsPnBkp:={} // Armazena o BackUp do aCols
Default aHeaderPGt:= {} 
Default aColsPGt  := {} 

If Empty(aHeaderPGt) 
	aHeaderPGt:= LjMontaHeader()	
EndIf  

If Empty(aColsPGt) 
	aColsPGt  := LjMontaCols(aHeaderPGt)
	aColsPnBkp:= aClone(aColsPGt)
EndIf  

DEFINE MSDIALOG oDlg TITLE cTitle From aSize[7],00 to aSize[6],aSize[5] Of oDlg PIXEL
	oDlg:lMaximized :=  .T.
		
    //Efetua a divisao da tela com o obejeto panel
   oPanelAll:= tPanel():New(0,0,"",oDlg,,,,, ,00,030,.T.)
   oPanelAll:align:= CONTROL_ALIGN_ALLCLIENT
  
  oPanelAll1:= tPanel():New(0,0,"",oPanelAll,,,,,/*CLR_GREEN*/,00,00,.F.)
  oPanelAll1:align:= CONTROL_ALIGN_ALLCLIENT   
   
  oPanelAll2:= tPanel():New(0,0,"",oPanelAll,,,,,/*CLR_GREEN*/,00,080,.F.)
  oPanelAll2:align:= CONTROL_ALIGN_TOP    
                                              
  oPanelAll3:= tPanel():New(0,0,,oPanelAll,,,,,/*CLR_GREEN*/,100,000,.F.)
  oPanelAll3:align:= CONTROL_ALIGN_RIGHT      
       
  oPanelRight:= tPanel():New(0,0,"",oDlg,,,,,/*CLR_GREEN*/,300,100,.F.)
  oPanelRight:align:= CONTROL_ALIGN_RIGHT
       
   oPanelTop:= tPanel():New(0,0,"",oDlg,,,,/*CLR_GREEN*/,/*CLR_GREEN*/,00,100,.F.)
   oPanelTop:align:= CONTROL_ALIGN_TOP  
  
  //Inclui cada panel dentro de um layer para melhor visualizacao.
  aLayers[1]:=FWLayer():new()
  aLayers[2]:=FWLayer():new()
  aLayers[3]:=FWLayer():new()
  aLayers[4]:=FWLayer():new()
  aLayers[5]:=FWLayer():new()    
    
  aLayers[1]:Init(oPanelTop,.T.)	
  aLayers[2]:Init(oPanelAll2,.T.)	
  aLayers[3]:Init(oPanelAll3,.T.)		
  aLayers[4]:Init(oPanelAll1,.T.)		
  aLayers[5]:Init(oPanelRight,.T.)	    
    
  aLayers[1]:addLine('Lin01',88,.f.)    
  aLayers[2]:addLine('Lin01',100,.f.)
  aLayers[3]:addLine('Lin01',100,.f.)
  aLayers[4]:addLine('Lin01',100,.f.)
  aLayers[5]:addLine('Lin01',100,.f.)
  If Alltrim(GetTheme()) == "STANDARD"									
	  aLayers[1]:addCollumn("Col01",100,.t.,'Lin01')	    
	  aLayers[2]:addCollumn("Col01",30,.t.,'Lin01')	
	  aLayers[2]:addCollumn("Col02",24,.t.,'Lin01')	
	  
	  aLayers[3]:addCollumn("Col01",100,.t.,'Lin01')	
	  aLayers[4]:addCollumn("Col01",45,.t.,'Lin01')	
	  aLayers[5]:addCollumn("Col01",100,.t.,'Lin01')	
	  	  
	  aLayers[1]:addWindow ("Col01","Win01",STR0077,100,.f.,.f., ,'Lin01') //'Itens da Publica็ใo de pre็o'
	  aLayers[2]:addWindow ("Col01","Win01",STR0078,100,.f.,.f., ,'Lin01') //'Categoria do produto selecionado'
	  aLayers[2]:addWindow ("Col02","Win02","Margem",100,.f.,.f., ,'Lin01')// 'Margem'
	  aLayers[3]:addWindow ("Col01","Win01",STR0079,100,.f.,.f., ,'Lin01') //"A็ใo"
	  aLayers[4]:addWindow ("Col01","Win01",STR0080,100,.f.,.f., ,'Lin01') //'Simula็ใo'
	  aLayers[5]:addWindow ("Col01","Win01",STR0081,100,.f.,.f., ,'Lin01') //'Analise Grแfica'
  Else                                                
  
	  aLayers[1]:addCollumn("Col01",100,.t.,'Lin01')	    
	  aLayers[2]:addCollumn("Col01",30,.t.,'Lin01')	
   	  aLayers[2]:addCollumn("Col02",25.5,.t.,'Lin01')	
	   
	  aLayers[3]:addCollumn("Col01",100,.t.,'Lin01')	
	  aLayers[4]:addCollumn("Col01",48,.t.,'Lin01')	
	  aLayers[5]:addCollumn("Col01",100,.t.,'Lin01')	  			  	
	  
	  aLayers[1]:addWindow ("Col01","Win01",STR0077,100,.f.,.f., ,'Lin01') //'Itens da Publica็ใo de pre็o'
	  aLayers[2]:addWindow ("Col01","Win01",STR0078,100,.f.,.f., ,'Lin01') //'Categoria do produto selecionado'
	  aLayers[2]:addWindow ("Col02","Win02","Margem",100,.f.,.f., ,'Lin01')// 'Margem'
	  aLayers[3]:addWindow ("Col01","Win01",STR0079,56.5,.f.,.f., ,'Lin01') //"A็ใo"
	  aLayers[4]:addWindow ("Col01","Win01",STR0080,56.5,.f.,.f., ,'Lin01') //'Simula็ใo'
	  aLayers[5]:addWindow ("Col01","Win01",STR0081,100,.f.,.f., ,'Lin01') //'Analise Grแfica'  	  
  EndIf 
          	 
  oProd := aLayers[1]:GetWinPanel("Col01" ,"Win01",'Lin01') 
  oCat  := aLayers[2]:GetWinPanel("Col01" ,"Win01",'Lin01') 
  oMarge:= aLayers[2]:GetWinPanel("Col02" ,"Win02",'Lin01')   
  
  oAcao := aLayers[3]:GetWinPanel("Col01" ,"Win01",'Lin01') 
  oSimu := aLayers[4]:GetWinPanel("Col01" ,"Win01",'Lin01') 
  oGraf := aLayers[5]:GetWinPanel("Col01" ,"Win01",'Lin01')                     
  
  oCombBox1 := TComboBox():New(010,001,{|u|if(PCount()>0,cCombBox1:=u,cCombBox1)},aCombBox1,40,007,oAcao,,{||  LoadCalc(@oExecut,@nExecut,@oAcao,cCombBox1)},,,,.T.,,,,,,,,,'cCombBox1')		
  oCombBox1:Select(1) //por padrใo inicia como sim    


  @ 010,44 MSGET oExecut VAR nExecut Size 45,10 Picture PesqPict("SB1","B1_REDINSS") OF oAcao PIXEL  	
  oExecut:bGotFocus:= {|| LoadCalc(@oExecut,@nExecut,@oAcao,cCombBox1) }  

  oCombBox2 := TComboBox():New(025,001,{|u|if(PCount()>0,cCombBox2:=u,cCombBox2)},aCombBox2,40,007,oAcao,,{||  },,,,.T.,,,,,,,,,'cCombBox2')		
  oCombBox2:Select(1) //por padrใo inicia como Percentual  
  
  oBtnOk:= TButton():New( 55, 30, STR0084 , oAcao,;//"Executa"
  						 {|| LoadAcao(aHeaderPGt,oGetD:aCols,oGetD:NAT,@aCatPrd,;
								  @aPrcPrd,@oListBox2,@oListBox1,@oFolder,;
							      @oFWChart1,@oFWChart2,@oGetD,cCombBox1,;
							      cCombBox2,aColsPnBkp,@oListBox3,@aMgmPrd,nExecut) } , 30, 12, , , , .T. )  //"Executa"
  
  oBtnOk := TButton():New(075,05 ,"Confirmar" ,oAcao,{|| LoadGrvPb(aHeaderPGt,oGetD:aCols),oDlg:End()},030,012,,,,.T.,,,,,,)//"Confirmar"
  oBtnEnd:= TButton():New(075,52 ,"Fechar"    ,oAcao,{|| oDlg:End()},030,012,,,,.T.,,,,,,)							        //"Fechar"
    
  @ 10,0 LISTBOX oListBox1 FIELDS TITLE "          ","             ",STR0085,STR0086 SIZE 10,20 OF oSimu PIXEL     //"Pre็o       "###"Margem % " 
	oListBox1:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox1:blDblClick := {|| LjFunDLeg()}
	oListBox1:SetArray( aPrcPrd )	
	
    oListBox1:bLine := {|| {Iif( aPrcPrd[oListBox1:nAt,1]== '1' ,oMim,Iif(aPrcPrd[oListBox1:nAt,1]== '2',oMed,oAlt)),;	  
						aPrcPrd[oListBox1:nAt,2],;
						aPrcPrd[oListBox1:nAt,3],;
						aPrcPrd[oListBox1:nAt,4] }	}
	                                                	
@ 10,0 LISTBOX oListBox2 FIELDS TITLE STR0087,STR0088 SIZE 10,20 OF oCat PIXEL //"Codigo  "###"Categoria"     
	oListBox2:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox2:SetArray( aCatPrd )	
	oListBox2:bLine := {|| aCatPrd[oListBox2:nAt] }	
                                                      
@ 10,0 LISTBOX oListBox3 FIELDS TITLE STR0107,STR0108     SIZE 10,20 OF oMarge PIXEL //"Minima      "###"Regular"     
	oListBox3:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox3:SetArray( aMgmPrd )	
	oListBox3:bLine := {|| aMgmPrd[oListBox3:nAt] }   
   
    oFolder:= TFolder():New(0,0,{STR0089,STR0090},,oGraf,,,,.T.,.F.,300,200)//"Pre็os dos Concorrentes"###"Hist๓rico de Pre็os"
    oFolder:Align := CONTROL_ALIGN_ALLCLIENT                   	
	//Grid da tela - superior
   	oGetD:= MsNewGetDados():New(000,000,100,000,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
						  	nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oProd,@aHeaderPGt,@aColsPGt)
	oGetD:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	
	oGetD:oBrowse:bLDblClick := {|| oGetD:EditCell(), oGetD:aCOLS[oGetD:nAt,1]:=Iif(oGetD:aCOLS[oGetD:nAt,1]=='LBOK','LBNO','LBOK'),aColsPnBkp[oGetD:nAt][1]:=oGetD:aCOLS[oGetD:nAt,1]}
	oGetD:bChange := {|| M325Load(aHeaderPGt,oGetD:aCOLS,n,@aCatPrd,;
								   @aPrcPrd,@oListBox2,@oListBox1,@oFolder,;
								   @oFWChart1,@oFwChart2,@oGetD,@oListBox3,@aMgmPrd) }

@ 88,05 Button oButMarc Prompt STR0109 Size 32, 12 Pixel Action  ( MarcaMas(aHeaderPGt,@oGetD,@aColsPnBkp,1) ) Of oPanelTop//'Mar. Todos'
@ 88,40 Button oButInv Prompt  STR0110 Size 32, 12 Pixel Action ( MarcaMas(aHeaderPGt,@oGetD,@aColsPnBkp,2) ) Of oPanelTop//'Inv. Sele็ใo'
	
ACTIVATE MSDIALOG oDlg Centered                                                      


Return
   

//-------------------------------------------------------------------
/*{Protheus.doc} LJ870BVl
Monta aHeaderPGt para tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LjMontaHeader()

Local aHeaderPGt:= {}  // estrutura do aheader
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta aHeader para GetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeaderPGt:= {}
aAdd( aHeaderPGt, { '', 'AY_MARK', '@BMP', 10, 0,,, 'C',, 'V' ,  ,  , 'mark'   , 'V', 'S' } )

dbSelectArea("SX3")
dbSetOrder(1)
If dbSeek("SAY")
	While !Eof() .AND. SX3->X3_ARQUIVO == "SAY"
		If !Alltrim(SX3->X3_CAMPO) $ "AY_FILIAL|AY_CODIGO|"
			AAdd(aHeaderPGt,	{AllTrim(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX	  , ; 		
							SX3->X3_RELACAO   , ;       
							SX3->X3_INIBRW  , ;			
							SX3->X3_BROWSE  , ;			
							SX3->X3_VISUAL  } )			
			EndIf	
		SX3->(dbSkip())
	EndDo	
EndIf 

aAdd( aHeaderPGt, {'Recno','RECNOSAY','', 09, 0,,, 'N',,'V',,,'','V','S'} )                        

Return aHeaderPGt

//-------------------------------------------------------------------
/*{Protheus.doc} LjMontaCols
Monta aCols para tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LjMontaCols(aHeaderPGt)

Local aArea    := GetArea()   //salva area atual
Local aColsPGt := {}      // acols para newgetdados
Local nCntFor  := 1         // contador

 
SAY->(DbSetOrder(2))		 
If SAY->(DbSeek(xFilial("SAY")+ SAX->AX_CODIGO ))
	While SAY->(!EOF()) .AND. SAY->AY_CODIGO == SAX->AX_CODIGO
		Aadd(aColsPGt,Array(Len(aHeaderPGt)+1))
		aColsPGt[Len(aColsPGt)][Len(aHeaderPGt)+1] := .F.
		aColsPGt[Len(aColsPGt)][1] := 'LBNO' //'ENABLE'
		For nCntFor := 2 To Len(aHeaderPGt)
			If ( aHeaderPGt[nCntFor][10] != "V" )			
				aColsPGt[Len(aColsPGt)][nCntFor] := &("SAY"+"->"+aHeaderPGt[nCntFor][2]) 
			Else     
				If ( aHeaderPGt[nCntFor][2] == "RECNOSAY" )			
					aColsPGt[Len(aColsPGt)][nCntFor] := SAY->(Recno())
				Else	
					aColsPGt[Len(aColsPGt)][nCntFor] := CriaVar(aHeaderPGt[nCntFor,2]) 
				EndIf	
			EndIf
		Next		
		
		SAY->(DbSkip())			
	EndDo 
EndIf
           
RestArea(aArea)

Return aColsPGt


//-------------------------------------------------------------------
/*{Protheus.doc} M325Load
Carrega as informacoes referente a tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function M325Load(aHeaderPGt,aColsPGt,n,aCatPrd,;
						aPrcPrd,oListBox2,oListBox1,oFolder,;
						oFWChart1,oFwChart2,oGetD,oListBox3,aMgmPrd)

Local nPosProd:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRODUTO"	}) // Posicao do produto no aHeader
Local nPosCat := aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_CATEGO"	}) // Posicao da categoria no aHeader
Local nPosPrAt:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRCATU"	}) // Posicao do preco atual no aHeader
Local nPosPrSg:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRCSUG"	}) // Posicao do preco sugerido no aHeader
Local aAux    := {}    // Array auxiliar para montagem da categoria/grafico          
Local aAux2   := {}    // Array auxiliar para montagem da categoria/grafico          
Local cAux    := ''    // string auxiliar para montagem do grafico          
Local aCusto  := {}    // Array do custo nas moedas  1,2,3,4 e 5
Local nCusto  := 0     // valor do custo na moeda configurada
Local nCont   := 1     // contador
Local cMoeda  := Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))//moeda do sistema
Local cMascPor:= PesqPict("DTV","DTV_RENTAB")// mascara para porcentagem
Local nX:=1 // contador
Local nY:=1 // contador
Local oMed		:= LoadBitmap(GetResources(), "BR_AMARELO") // botao para legenda
Local oMim		:= LoadBitmap(GetResources(), "BR_VERMELHO")//botao para legenda
Local oAlt		:= LoadBitmap(GetResources(), "BR_VERDE")   //botao para legenda

aPrcPrd:= {}
 
aCusto  := PegaCMAtu(aColsPGt[n][nPosProd],Posicione("SB1",1,xFilial("SB1") + aColsPGt[n][nPosProd] , "B1_LOCPAD") )		        
nCusto  := aCusto[Val(cMoeda)]
//Efetua a busca de categoria para apresentacao na tela
ACU->(dbSetOrder(1))
If ACU->(dbSeek(xFilial("ACU")+aColsPGt[n][nPosCat]))         
	Aadd(aAux,{ACU->ACU_COD,ACU->ACU_DESC})		

	LoadCat(@aAux,ACU->ACU_CODPAI)
	//aCatPrd:= aAux
	aCatPrd:={}
	nCont:= Len(aAux)
	While nCont > 0  
	 	Aadd(aCatPrd,aAux[nCont])
		nCont--		
	EndDo
Else
	aCatPrd:={{"",""}}
EndIf

//Efetua a busca dos precos para apresentacao na tela   
Aadd(aPrcPrd,{'',STR0091,aColsPGt[n][nPosPrAt] , Transform(((aColsPGt[n][nPosPrAt]-nCusto)/aColsPGt[n][nPosPrAt])*100,cMascPor),''  })//"Pre็o Atual"
Aadd(aPrcPrd,{'',STR0092,aColsPGt[n][nPosPrSg] , Transform(((aColsPGt[n][nPosPrSg]-nCusto)/aColsPGt[n][nPosPrSg])*100,cMascPor),''  })//"Pre็o Sugerido"
Aadd(aPrcPrd,{'',STR0093, nCusto               , Transform((                (nCusto-nCusto)/nCusto                )*100,cMascPor),''  })//"Margem Zero"
Aadd(aPrcPrd,{'',"----------------","----------------","----------------",'' })
Aadd(aPrcPrd,{'',STR0094,"----------------","----------------",'' })//"Concorrentes"

// Adiciona os precos dos concorrentes no array
aAux:= LoadCct(@aPrcPrd,aColsPGt[n][nPosProd],nCusto,@aMgmPrd) 
 
 
If Valtype(oFWChart1)=="O" 
	FreeObj(@oFWChart1)
Endif
 
If Valtype(oFWChart2)=="O" 
	FreeObj(@oFWChart2)
Endif

//Carrega grafico: Preco do Concorrente
oFWChart1 := FWChartFactory():New()
oFWChart1 := oFWChart1:getInstance(  LINECHART )
oFWChart1:init( oFolder:aDialogs[1] )
oFWChart1:SetLegend(CONTROL_ALIGN_BOTTOM)
oFWChart1:SetMask( "R$ *@*")
oFWChart1:SetPicture( PesqPict("SD2","D2_TOTAL") ) 
    
If  Len(aAux) > 0  
	For nX:= 1 To Len(aAux)
		aAux2:= {}  
		cAux:= aAux[nX][1]
		For nY:=1 To Len(aAux[nX][2])
			aAdd(aAux2,aAux[nX][2][nY])
			//Apenas as 5 ultimas informacoes de precos sera exibina na tela
			If Len(aAux2) > 5
				aDel(aAux2,1)
				aSize(aAux2,Len(aAux2)-1)
			EndIf
		Next nY
		oFWChart1:addSerie(cAux,aAux2 )
	Next nX 
Else
	oFWChart1:addSerie( "", { {"" ,0}}	)
EndIf     

oFWChart1:Build()
      
//Carrega grafico: Historico de preco
oFWChart2 := FWChartFactory():New()
oFWChart2 := oFWChart2:getInstance(  LINECHART )
oFWChart2:init( oFolder:aDialogs[2] )
oFWChart2:SetLegend(CONTROL_ALIGN_BOTTOM)
oFWChart2:SetMask( "R$ *@*")
oFWChart2:SetPicture(PesqPict("SD2","D2_TOTAL")) 
 
aAux:= LoadPrcProd(aColsPGt[n][nPosProd])   
If  Len(aAux) > 0  
	oFWChart2:addSerie(STR0095+aColsPGt[n][nPosProd],aAux )//"Produto :"
Else
	oFWChart2:addSerie(STR0095+aColsPGt[n][nPosProd], { {"" ,0}}	 )//"Produto :"
EndIf 
oFWChart2:Build()

//Atualiza o Array de categorias      
oListBox2:SetArray( aCatPrd ) 
oListBox2:bLine := {|| aCatPrd[oListBox2:nAt] }	
oListBox2:Refresh()  

//Atualiza o Array de categorias      
oListBox3:SetArray( aMgmPrd ) 
oListBox3:bLine := {|| aMgmPrd[oListBox3:nAt] }	
oListBox3:Refresh()  

//Atualiza o Array de pre็os  
oListBox1:SetArray( aPrcPrd ) 
oListBox1:bLine := {|| {Iif( aPrcPrd[oListBox1:nAt,1]== '1' ,oMim,Iif(aPrcPrd[oListBox1:nAt,1]== '2',oMed,oAlt)),;	  
						aPrcPrd[oListBox1:nAt,2],;
						aPrcPrd[oListBox1:nAt,3],;
						aPrcPrd[oListBox1:nAt,4] }	}
						
oListBox1:Refresh()
oGetD:aCols:= aColsPGt
oGetD:Refresh()

Return


//-------------------------------------------------------------------
/*{Protheus.doc} LoadCat
Carrega estrutura da categoria

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadCat(aAux,cCodPai)

ACU->(dbSetOrder(1))
If !EMPTY(cCodPai) .AND. (ACU->(dbSeek(xFilial("ACU")+cCodPai)))
	cCodPai:=ACU->ACU_CODPAI 

	While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai)
    	aAdd(aAux,{ACU->ACU_COD,ACU->ACU_DESC})
     	LoadCat(@aAux,ACU->ACU_CODPAI)                 
     	ACU->(dbSkip())    	
    EndDo	
EndIf 
    

Return


//-------------------------------------------------------------------
/*{Protheus.doc} LoadCct
Carrega os precos dos concorrentes

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadCct(aPrcPrd,cProd,nCusto,aMgmPrd) 
Local nScan := 0   //busca 
Local nCcts := Len(aPrcPrd)  // contador para atualizar o preco atual do concorrente
Local aCcts := {} //Array de concorrentes
Local cCodCt:= '' //codigo do concorrente 
Local cNReduz:='' // armazena o nome reduzido do concorrente
Local cMascPor:= PesqPict("DTV","DTV_RENTAB")//mascara para campo
Local nMax   := 0 // contador de cocorrentes; exibe nos maximo 5 concorrentes

AC3->(DbGoTop())
AC3->(DbSetOrder(1))
While AC3->(!EOF()) .AND. nMax <= 5
    
  	If AC3->AC3_PAINEL == '2' 
		AC3->(DbSkip())		
		Loop
	EndIf

	nMax++
	MG3->(DbGoTop())            	
	MG3->(DbSetOrder(3))
	
	If MG3->(DbSeek(xFilial("MG3")+AC3->AC3_CODCON+cProd))
	    While MG3->(!EOF()) .AND. MG3->MG3_CODPRD == cProd .AND. AC3->AC3_CODCON == MG3->MG3_CODCCT
	    
	    	cCodCt:= MG3->MG3_CODCCT
	    	cNReduz:= AC3->AC3_NREDUZ
	    	nSan:= aScan(aPrcPrd,{|x| x[5] == cCodCt})
	    	If nSan == 0
				aAdd(aPrcPrd,{'' ,cNReduz ,MG3->MG3_PRECO, Transform(((MG3->MG3_PRECO-nCusto)/MG3->MG3_PRECO)*100,cMascPor),cCodCt } )	
				
		    	aAdd(aCcts,{ cNReduz,;
		    			    {	{DtoC(MG3->MG3_EMISSA),MG3->MG3_PRECO} } } )
				nCcts++	    			    
	    	Else 
		    	aPrcPrd[nCcts][3] := MG3->MG3_PRECO
		    	aPrcPrd[nCcts][4] := Transform(((MG3->MG3_PRECO-nCusto)/MG3->MG3_PRECO)*100,cMascPor)		    	
		    	aAdd(aCcts[Len(aCcts)][2] ,	{DtoC(MG3->MG3_EMISSA),MG3->MG3_PRECO}  )    		
	    	EndIf
	    	
	    	
	    	MG3->(DbSkip())                                   
		EndDo
	
	EndIf 
	AC3->(DbSkip())
EndDo

LoadLeg(@aPrcPrd,cProd,nCusto,@aMgmPrd)

Return aCcts
      
//-------------------------------------------------------------------
/*{Protheus.doc} LoadLeg
Carrega a legenda para os precos referente a margem minima

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadLeg(aPrcPrd,cProd,nCusto,aMgmPrd)   

Local oMed		:= LoadBitmap(GetResources(), "BR_AMARELO") // botao para legenda
Local oMim		:= LoadBitmap(GetResources(), "BR_VERMELHO")//botao para legenda
Local oAlt		:= LoadBitmap(GetResources(), "BR_VERDE")   //botao para legenda
Local nR:= 1           // contador
Local aRentab:= {}     // array de rentabilidade
Local nMargemVenda:= 0 // armazena margem de venda
Local nPrecoAux := 0   // armazena o preco de venda
Local cMascVlr:= PesqPict("MG3","MG3_PRECO") // mascara do campo

//Percorre array de concorrentes para analise da margem
For nR:= 1 To Len(aPrcPrd)	    

	nPrecoAux := MaValPres(aPrcPrd[nR][3],dDataBase,,,dDataBase)
	cMargem   :=  TransForm(  ( ( nPrecoAux-nCusto)/aPrcPrd[nR][3]) * 100 ,PesqPict("SD2","D2_TOTAL"))
	aAdd(aRentab,{cProd,aPrcPrd[nR][3],nCusto,nPrecoAux,( nPrecoAux-nCusto) , cMargem ,,})
	LoadRentb(@aRentab)
	nMargemVenda := StrTran(aRentab[1][6],".","") //retira a mascara e converte para numerico
	nMargemVenda := Val(StrTran(nMargemVenda,",","."))		
	If nMargemVenda < aRentab[1][7] 		
		aPrcPrd[nR][1]:= '1'//oMim 
	ElseIf nMargemVenda >= aRentab[1][7] .AND. nMargemVenda <= aRentab[1][8] 		 		
		aPrcPrd[nR][1]:= '2'//oMed 
	Else                  
		aPrcPrd[nR][1]:= '3'//oAlt 
	EndIf
	
	aMgmPrd:= {{ TransForm(aRentab[1][7],PesqPict("SD2","D2_TOTAL")) ,TransForm(aRentab[1][8],PesqPict("SD2","D2_TOTAL")) }}
	
	aRentab:={}
	aPrcPrd[nR][3]:=Transform(aPrcPrd[nR][3],cMascVlr)
	//Pula esta posicoes poes nao existe calculo
	If nR == 3
		nR:= nR+2
	EndIf
Next nR     

Return   

//-------------------------------------------------------------------
/*{Protheus.doc} LoadRentb
Verifica a margem de pre็o para cada concorrente do produto selecionado

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadRentb(aRentab)
   
Local aArea := GetArea()            // salva area    
Local cSeek:= ''                    // efetua seek pata consulta da margem
Local cEspaco:=''                   // espaco para o seek da margem
Local cWhile:= ''                   // efetua while pata consulta da margem
Local cGrupoCli:= ''                // seek  pesquisa regra por grupo de clientes
Local lContinua:= .F.               // variavel de controle
Local nMargMin      := 0 // margem minima cadastrada
Local nMargMed      := 0 // Margem media cadastrada
Local cCliPad       := StrZero(1,TamSx3("A1_COD")[1] )+StrZero(1,TamSx3("A1_LOJA")[1] ) // Cliente padrใo do sistema
//--------------------------------------------
//pesquisa regra por o cliente
//--------------------------------------------
//Cliente padrใo para pesquisa da margem
cSeek := "xFilial('AIH') + '"+cCliPad+"'"
cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. + '"+StrZero(1,TamSx3("A1_COD")[1] )+;
			"' == AIH->AIH_CODCLI .AND. + '"+StrZero(1,TamSx3("A1_LOJA")[1] )+"' == AIH->AIH_LOJA"
lContinua := PesqCliGru(2, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)

If !lContinua
	//--------------------------------------------
	//pesquisa regra por grupo de clientes
	//--------------------------------------------
	cGrupoCli := Posicione("SA1",1 , xFilial("SA1") +cCliPad, "A1_GRPVEN")
	If !Empty(cGrupoCli)
		cSeek := "xFilial('AIH') + '" + cGrupoCli + "'"
		cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. + '" + cGrupoCli + "' == AIH->AIH_GRPVEN "
		lContinua := PesqCliGru(3, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)
	EndIf
EndIf

If !lContinua
	//--------------------------------------------------------------------------------------
	//pesquisa regra que sirva para qualquer cliente (codcli branco e grupo cli branco)
	//--------------------------------------------------------------------------------------
	cEspaco := Space(TamSx3("AIH_GRPVEN")[1]) + Space(TamSx3("AIH_CODCLI")[1]) + Space(TamSx3("AIH_LOJA")[1])
	cSeek := "xFilial('AIH') + '" + cEspaco + "'"
	cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. AIH->AIH_GRPVEN+AIH->AIH_CODCLI+AIH->AIH_LOJA == '" + cEspaco + "' "
	lContinua := PesqCliGru(3, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)
EndIf
aRentab[1][7]:= nMargMin
aRentab[1][8]:= nMargMed

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} LjFunDLeg
Mostra legenda na tela

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LjFunDLeg()

Local  aLegenda := {}   //array da legenda

aAdd( aLegenda, { "BR_VERDE"	, STR0096  } )//"Acima da Margem Regular"
aAdd( aLegenda, { "BR_AMARELO" 	, STR0097  } )//"Entre Margem Minima e Regular"
aAdd( aLegenda, { "BR_VERMELHO"	, STR0098  } )//"Abaixo da Margem Minima"    

BrwLegenda(STR0099,STR0100,aLegenda)//"Consulta Margem Minima"###"Legenda"

Return .T.

 
//-------------------------------------------------------------------
/*{Protheus.doc} LoadAcao
Executa os calculos ao apertar o botao "EXECUTAR"

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadAcao(aHeaderPGt,aColsPGt,n,aCatPrd,;
						aPrcPrd,oListBox2,oListBox1,oFolder,;
						oFWChart1,oFwChart2,oGetD,cCombBox1,;
						cCombBox2,aColsPnBkp,oListBox3,aMgmPrd,;
						nExecut)

Local nPosProd:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRODUTO"	}) // Posicao do produto no aHeader
Local nPosPrAt:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRCATU"	}) // Posicao do preco atual no aHeader					
Local nPosPrSg:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRCSUG"	}) // Posicao do preco atual no aHeader					
Local nPosMark:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_MARK"	}) // Posicao do produto selecionado no aHeader					
Local nH:= 1 // contador

aColsPGt:= aClone(aColsPnBkp)

For nH:= 1 To Len(aColsPGt) 
	If aColsPGt[nH][nPosMark] == "LBOK" 
		If cCombBox1 == '1'
			If cCombBox2 == '1'
				aColsPGt[nH][nPosPrSg]+= (nExecut*aColsPnBkp[n][nPosPrSg])/100 
			Else
				aColsPGt[nH][nPosPrSg]-= (nExecut*aColsPnBkp[n][nPosPrSg])/100 
			EndIf		
		Else 
			If cCombBox2 == '1'
				aColsPGt[nH][nPosPrSg]+= nExecut		
			Else
				aColsPGt[nH][nPosPrSg]-= nExecut
			EndIf				
		EndIf
	EndIf
Next nH



M325Load(aHeaderPGt,aColsPGt,n,@aCatPrd,;
		 @aPrcPrd,@oListBox2,@oListBox1,@oFolder,;
		 @oFWChart1,@oFwChart2,@oGetD,@oListBox3,@aMgmPrd)

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} LoadPrcProd
Carrega os precos do produto 

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadPrcProd(cProd)

Local cQuery  := ''             // Montagem da query
Local cAliasTrb:= GetNextAlias()// Alias temporario
Local aRet:= {} // array de retorno
Local cSGBD := TCGetDB() //Banco de dados que esta sendo utilizado
                                                  
If cSGBD $ "ORACLE"
	cQuery += " SELECT AY_PRCATU,AX_DATAINI FROM "+RetSqlName("SAY")+" SAY"+CRLF
ElseIf cSGBD $ "DB2"
	cQuery += " SELECT AY_PRCATU,AX_DATAINI FROM "+RetSqlName("SAY")+" SAY"+CRLF
Else
	cQuery += " SELECT TOP 5 AY_PRCATU,AX_DATAINI FROM "+RetSqlName("SAY")+" SAY"+CRLF
EndIf	
cQuery += " INNER JOIN "+RetSqlName("SAX")+" SAX" + CRLF
cQuery += " ON AX_FILIAL = AY_FILIAL"+CRLF
cQuery += " AND AX_CODIGO=AY_CODIGO"+CRLF
cQuery += " AND SAX.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " WHERE "+CRLF
cQuery += " AY_FILIAL = '"+xFilial("SAY")+"' "+CRLF
cQuery += " AND AY_PRODUTO = '"+cProd+"' "+CRLF
cQuery += " AND SAY.D_E_L_E_T_ = ' '

If cSGBD $ "ORACLE"
	cQuery += " AND ROWNUM <= 5"
EndIf
	
cQuery += " ORDER BY AX_DATAINI"+CRLF

If cSGBD $ "DB2"
	cQuery += " FETCH FIRST 5 ROWS ONLY "
EndIf

cQuery:= ChangeQuery(cQuery) 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
     
//Percorre tabela temporaria para adicionar no array que apresentara o grafico
While (cAliasTrb)->(!EOF())
	aAdd(aRet,{ DTOC(STOD((cAliasTrb)->AX_DATAINI)) , (cAliasTrb)->AY_PRCATU})   
	(cAliasTrb)->(DbSkip())
EndDo

(cAliasTrb)->(dbCloseArea())

Return aRet
            

//-------------------------------------------------------------------
/*{Protheus.doc} MarcaMas
Marca todos os registros do aCols ou Inverte Selecao

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MarcaMas(aHeaderPGt,oGetD,aColsPnBkp,nTipo)
Local aColsPGt:= oGetD:aCols // recebe array
Local nH:= 1 // contador
Local nPosMark:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_MARK"	}) // Posicao do produto no aHeader
For nH:= 1  To Len(aColsPGt)
	If nTipo == 1 
		aColsPGt[nH][nPosMark]	:= "LBOK"
		aColsPnBkp[nH][nPosMark]:= "LBOK"
	Else
		aColsPGt[nH][nPosMark]	:= Iif( aColsPGt[nH][nPosMark] == "LBOK","LBNO","LBOK")
		aColsPnBkp[nH][nPosMark]:= aColsPGt[nH][nPosMark]
	EndIf
Next nH
oGetD:aCols:= aColsPGt
oGetD:Refresh()

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} LoadCalc
Monta get de acordo com a sele็ใo do combobox

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadCalc(oExecut,nExecut,oAcao,cCombBox1)
         
nExecut:= 0  // zera variavel

If cCombBox1 == '1'                                                          
	@ 010,44 MSGET oExecut VAR nExecut Size 45,10 Picture PesqPict("SB1","B1_REDINSS") OF oAcao PIXEL  	
Else
	@ 010,44 MSGET oExecut VAR nExecut Size 45,10 Picture PesqPict("SD2","D2_TOTAL") OF oAcao PIXEL    
EndIf
     

oAcao:Refresh() 
oExecut:Refresh() 
Return .T.

       
//-------------------------------------------------------------------
/*{Protheus.doc} LoadGrvPb
Efetua a gravacao dos precos sugeridos modificados

@author Varejo
@since 27/08/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function LoadGrvPb(aHeaderPGt,aColsPGt)

Local nPosMark:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_MARK"	}) // Posicao do produto no aHeader
Local nPosPrSg:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "AY_PRCSUG"	}) // Posicao do preco atual no aHeader
Local nPosRec:= aScan(aHeaderPGt,{ |x| Upper(AllTrim(x[2])) == "RECNOSAY"	}) // Posicao do Recno no aHeader
Local nI:= 1//contador

If MsgYesNo(STR0111) //"Confirma a altera็ใo da Publica็ใo de pre็o para o(s) item(s) selecionados(s) ? "
	BEGIN TRANSACTION
	//Grava SAY para os produtos selecionados no aCols
	For nI:= 1 To Len(aColsPGt)	
		If aColsPGt[nI][nPosMark] == "LBOK"  
		    SAY->(DbGoTo(aColsPGt[nI][nPosRec]))
		    RecLock("SAY",.F.)
			SAY->AY_PRCSUG:= aColsPGt[nI][nPosPrSg]
			SAY->(MsUnlock())
	    EndIf
	Next nI			
	END TRANSACTION
EndIf
Return .T.
