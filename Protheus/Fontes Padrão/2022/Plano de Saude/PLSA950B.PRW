#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
//Receber e gravar valores do fonte PLSA950

Static Function ModelDef()
Local oModel 
Local oStrBR	:= FWFormModelStruct():New()
Local oStrBR4G	:= FWFormStruct(1,'BR4')

Local oModel // Modelo de dados construído
Local oStrBR4:= FWFormStruct(1,'BR4' )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSA950B' ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterBR4',/*cOwner*/,oStrBR4)  // Adiciona ao modelo um componente de formulário

oModel:GetModel('MasterBR4'):SetDescription( 'Registros RPS' ) // Adiciona a descrição do Modelo de Dados
oStrBR4:setProperty( "*" , MODEL_FIELD_VALID, {||.T. }  )
oStrBR4:setProperty( "BR4_SEPARA" , MODEL_FIELD_OBRIGAT, .F. )

oModel:SetPrimaryKey( { "BR4_FILIAL", "BR4_CODPAD","BR4_SEGMEN" } )

Return oModel // Retorna o Modelo de dados