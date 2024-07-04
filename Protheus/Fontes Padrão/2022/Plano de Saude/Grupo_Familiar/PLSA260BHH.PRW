#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BHH
Browse de Situações Adversas
@author DEV TOTVS
@since  10/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BHH(lAutomato)

// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BHH' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Situações Adversas
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados de Situações Adversas
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruBHH 		:= FWFormStruct(1,'BHH')

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local nNx
Local aAux          := {}

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BHH')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx])
Next

// Cria gatilho para gravar a descrição da situação adversa
aAux :=   FwStruTrigger(;
      "BHH_CODSAD" ,; 				// Campo Dominio
      "BHH_DESSAD" ,; 				// Campo de Contradominio
      "BGX->BGX_DESCRI",; 			// Regra de Preenchimento
      .T. ,; 						// Se posicionara ou nao antes da execucao do gatilhos
      "BGX" ,; 						// Alias da tabela a ser posicionada
      1,; 							// Ordem da tabela a ser posicionada
      "ChavGatMVC('BHH_CODSAD')" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; 						// Condicao para execucao do gatilho
      "01" ) 						// Sequencia do gatilho (usado para identificacao no caso de erro) 

// Substitui o gatilho da seq 001, devio utilizar a memoria dos campos
oStruBHH:ATRIGGERS[1] := {	aAux[1] , ;       // [01] Id do campo de origem
							aAux[2] , ;       // [02] Id do campo de destino
							aAux[3] , ;       // [03] Bloco de codigo de validação da execução do gatilho
							aAux[4]	}		  // [04] Bloco de codigo de execução do gatilho 

// Adiciona as estruturas no modelo
oModel:addFields('BA1MASTER' ,NIL,oStruBA1) 
oModel:AddGrid('BHHDETAIL','BA1MASTER',oStruBHH)

// Permissão de grid sem dados
oModel:GetModel('BHHDETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BHHDETAIL', {  { 'BHH_FILIAL'  , 'xFilial( "BHH" )'},;
								    { 'BHH_CODINT'	, 'BA1_CODINT' } ,;
                                    { 'BHH_CODEMP'	, 'BA1_CODEMP' } ,;
                                    { 'BHH_MATRIC'	, 'BA1_MATRIC' } ,;
                                    { 'BHH_TIPREG'	, 'BA1_TIPREG' }},;										
								BHH->( IndexKey( ) ) ) 				
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Define linha unica para o codigo
oModel:GetModel('BHHDETAIL'):SetUniqueLine({'BHH_CODSAD'}) 

// Descrição de cada modelo usado
oModel:GetModel('BA1MASTER'):SetDescription('Beneficiário' )
oModel:GetModel('BHHDETAIL'):SetDescription('Situações Adversas' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('BA1MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('BA1MASTER'):SetOnlyView(.T.)

oStruBHH:setProperty( 'BHH_TIPREG', MODEL_FIELD_INIT,  { || BA1->BA1_TIPREG })
oStruBHH:setProperty( 'BHH_CODSAD', MODEL_FIELD_VALID, { || ExistCpo('BGX',oModel:GetValue('BA1MASTER','BA1_CODINT')+oModel:GetValue('BHHDETAIL','BHH_CODSAD'),1)} )
oStruBHH:setProperty( 'BHH_DESSAD', MODEL_FIELD_INIT,  { || If(Inclui,"",Posicione("BGX",1,xFilial("BGX")+BA1->BA1_CODINT+BHH->BHH_CODSAD,"BGX_DESCRI")) } )

oStruBHH:setProperty( 'BHH_VIGDE' , MODEL_FIELD_VALID, { || VLDVIGBHH(oModel,"1")} ) // 1 = De
oStruBHH:setProperty( 'BHH_VIGATE', MODEL_FIELD_VALID, { || VLDVIGBHH(oModel,"2")} ) // 2 = Ate

oModel:SetPrimaryKey( { 'BHH_FILIAL', 'BHH_CODINT', 'BHH_CODEMP', 'BHH_MATRIC' , 'BHH_CODSAD' } )

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View de Situações Adversas
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

// Declaração de Variáveis
Local oStruBA1      := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR' } )
Local oStruBHH      := FWFormStruct(2,'BHH')	
Local oModel        := FWLoadModel( 'PLSA260BHH') // Carrega o modelo
Local oView
Local aCamposBA1    := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCamposBA1[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

// Removo os campos para não ser exibido no AddGrid
oStruBHH:RemoveField('BHH_TIPREG')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'BA1MASTER' )
oView:AddGrid(  'VIEW_BHH' , oStruBHH, 'BHHDETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 12) 
oView:CreateHorizontalBox( 'INFERIOR', 88) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_BHH', 'INFERIOR')	
	
oView:EnableTitleView('VIEW_BA1','Beneficiário')
oView:EnableTitleView('VIEW_BHH','Situações Adversas')

Return oView      

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDVIGBHH
Valida a vigencia da Data De e Data Ate das situações adversas
@author  DEV TOTVS
@since   12/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function VLDVIGBHH(oModel,cVig)

Local lRet      := .T.
Local dDataDe   := oModel:GetValue('BHHDETAIL','BHH_VIGDE')
Local dDataAte  := oModel:GetValue('BHHDETAIL','BHH_VIGATE')

If cVig == "1" // De
    lRet := If(!Empty(dDataAte), dDataDe <= dDataAte,.T.)
ElseIf cVig == "2" // Até
    lRet := If(!Empty(dDataDe) .And. !Empty(dDataAte), dDataAte >= dDataDe,.T.)            
EndIf
                                                                                                                              
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDVIGBHH
Criado função para retornar chave para o gatilho MVC
@author  DEV TOTVS
@since   12/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function ChavGatMVC(cCampo)

Local oModel    := FWModelActive()
Local cReturn   := ''

If cCampo == "BHH_CODSAD"
    cReturn:=  (xFilial("BHH")+oModel:GetValue('BA1MASTER','BA1_CODINT')+oModel:GetValue('BHHDETAIL','BHH_CODSAD')) 
EndIf 

Return (cReturn) 