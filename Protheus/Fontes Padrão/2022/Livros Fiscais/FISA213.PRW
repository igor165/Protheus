#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA213.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA213()  

Rotina com objetivo de registrar os percentuais de estorno dos créditos
de PIS e COFINS, referente ao b/enefício da agro indúistria, que permite 
determinadas vendas não sem tributadas, porém em contra partida deverá
estornar os créditos de PIS e COFINS de determinados insumos.

Estes percentuais serão armazenados nesta tabela para que apuração 
da EFD Contribuições possa ler e gerar os estornos automaticamente,
através dos registros M110 e M510, ajustes de redução de crédito
de PIS e COFINS.

@author Erick G Dias
@since 05/02/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA213()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F3V")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3V")
    oBrowse:SetDescription(STR0001)//"Cadastro dos Percentuais de Estorno dos Créditos de PIS e COFINS"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicionário desatualizado, favor verificar atualização da EFD Contribuições"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA213" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F3V",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(1, "F3V",{|cCampo| COMPSTRU("ITE",cCampo)})

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA213',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })
 
//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA213",,oCabecalho)

oCabecalho:SetProperty('F3V_PERAPU' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Adiciona o grid
oModel:AddGrid("FISA213ITEM","FISA213",oItem)

oModel:SetRelation('FISA213ITEM', {{ 'F3V_FILIAL', 'xFilial("F3V")' }, { 'F3V_PERAPU', 'F3V_PERAPU' }, { 'F3V_ORIG', 'F3V_ORIG' }}, F3V->( IndexKey(1)))

oModel:SetPrimaryKey( {"F3V_FILIAL","F3V_PERAPU", "F3V_ORIG" } )

oModel:GetModel( 'FISA213ITEM' ):SetUniqueLine( { 'F3V_DESCHP' } )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001)  //"Cadastro dos Percentuais de Estorno dos Créditos de PIS e COFINS"

oModel:AddCalc( 'FISA213ITEMTOTAL', 'FISA213', 'FISA213ITEM', 'F3V_PERDET', 'Total', 'SUM', { | oFW | .T. },,'Total %' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA213" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2,"F3V",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(2,"F3V",{|cCampo| COMPSTRU("ITE",cCampo)})
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

// Retirando campo de ID e origem da view.
oCabecalho:RemoveField('F3V_ID')
oCabecalho:RemoveField('F3V_ORIG')

oItem:RemoveField('F3V_ID')
oItem:RemoveField('F3V_ORIG')

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA213' )

//Adiciona o grid com os código BCC
oView:AddGrid("VIEW_ITEM",oItem,"FISA213ITEM")

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel( 'FISA213ITEMTOTAL') )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_TOTAL', oCalc1, 'FISA213ITEMTOTAL' )

//Separa a tela em duas partes
oView:CreateHorizontalBox("SUPERIOR",20)	
oView:CreateHorizontalBox("INFERIOR",60)
oView:CreateHorizontalBox("RODAPE",20)

//Definição do cabeçalho e do item na tela
oView:SetOwnerView("VIEW_CABECALHO","SUPERIOR")
oView:SetOwnerView("VIEW_ITEM","INFERIOR")
oView:SetOwnerView("VIEW_TOTAL","RODAPE")

//Títulos do cabeçalho e do item
oView:EnableTitleView('VIEW_CABECALHO', STR0003) //'Estorno do Crédito do Período' 
oView:EnableTitleView('VIEW_ITEM'     , STR0004) //'Detalhamento do Estorno de Crédito'
oView:EnableTitleView('VIEW_TOTAL'    , STR0005) //'Total do Percentual de Detalhamento'

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPSTRU
Função que faz verificação dos campos que deverão ser exibidos
no cabeçalho ou então no item do Grid.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function COMPSTRU(cTipo,cCampo)

Local lRet := .F.

If cTipo == "CAB" .AND. AllTrim(cCampo) $ "F3V_PERAPU/F3V_PEREST/F3V_ORIG" //Verifica os campos de cabeçalho
    lRet := .T.
ElseIf cTipo == "ITE" .AND. AllTrim(cCampo) $ "F3V_DESCHP/F3V_PERDET/F3V_ORIG/F3V_CODAJU/F3V_CODCTA" //Verifica os campos dos itens
    lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA213PER
Função zuxilar para validação do período dos percentuais

@author Erick G Dias    
@since 06/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA213PER()

Local lRet  := .F.

lRet := Len(Alltrim(FwFldGet("F3V_PERAPU")))==6 .And. ;
        VAL(Substr(FwFldGet("F3V_PERAPU"),5,2))>=1 .And. ;
        VAL(Substr(FwFldGet("F3V_PERAPU"),5,2))<=12 .AND. ;
        !ExistCpo("F3V", FwFldGet("F3V_PERAPU"))

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que fará a validação de gravação do modelo
Aqui verificarei se o percentual do detalhamento totaliza 100%, para evitar
cálculo incorreto na apuração da EFD COntribuições.

@author Erick G Dias    
@since 07/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local oGrid     := oModel:GetModel( 'FISA213ITEM' )
Local nI        := 0
Local nTotal    := 0
Local lRet      := .T.

//Percorrerá as linhas do grid, de forma que o somatório dos percentuais do detalhamento seja igual a 100%
For nI := 1 To oGrid:Length()
    oGrid:GoLine(nI)
    IF !oGrid:IsDeleted() //Não considero as linhas deletadas
        nTotal += oGrid:GetValue('F3V_PERDET')
    EndiF
Next nI

//Verifico se o somatório dos percentuais é diferente de 100%, se for então será exibida mensagem de alerta para usuário
If nTotal <> 100
    lRet := .F.
    Help( ,, 'Help',, STR0006, 1, 0 )//"O somatório dos percentuais de detalhamento precisa ser igual a 100%, por favor verifique os percentuais do detalhamento informados."
EndIF

Return lRet