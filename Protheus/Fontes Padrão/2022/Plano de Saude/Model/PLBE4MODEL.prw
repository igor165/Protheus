#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados das guias
@author Renan Martins
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados.
Local oStruBE4 := FWFormStruct( 1, 'BE4' )
Local oStruBD6 := FWFormStruct( 1, 'BD6' )
//Local oStruBD7 := FWFormStruct( 1, 'BD7' )
Local oModel := MPFormModel():New( 'MGuiPls', , {|| .t. }  )

oModel:AddFields( 'BE4Cab' ,/*cOwner*/, oStruBE4 )
oModel:AddGrid  ( 'BD6Proc', 'BE4Cab' , oStruBD6 )
//oModel:AddGrid  ( 'BD7Part', 'BD6Proc', oStruBD7 )

//GRAVAÇÃO DA MODEL: oModel:CommitData()
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BD6Proc', {{ 'BD6_FILIAL'	, 'xFilial( "BD6" )'},;
                                { 'BD6_CODOPE'	, 'BE4_CODOPE' },;
                                { 'BD6_CODLDP'   , 'BE4_CODLDP' },;
                                { 'BD6_CODPEG'   , 'BE4_CODPEG' },;
                                { 'BD6_NUMERO'   , 'BE4_NUMERO' }},;
       				           BD6->( IndexKey( 1 ) ) )
       				           
/*oModel:SetRelation( 'BD7Part', {{ 'BD7_FILIAL'	, 'xFilial( "BD7" )'},;
                                { 'BD7_CODOPE'	, 'BD6_CODOPE' },;
                                { 'BD7_CODLDP'   , 'BD6_CODLDP' },;
                                { 'BD7_CODPEG'   , 'BD6_CODPEG' },;
                                { 'BD7_NUMERO'   , 'BD6_NUMERO' },;
                                { 'BD7_ORIMOV'   , 'BD6_ORIMOV' },;
                                { 'BD7_SEQUEN'   , 'BD6_SEQUEN' }},;
       				           BD7->( IndexKey( 1 ) ) )*/

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Guias' )

oStruBE4:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )
oStruBD6:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )
//oStruBD7:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )

oStruBE4:SetProperty( '*'   , MODEL_FIELD_OBRIGAT, .F.)
oStruBD6:SetProperty( '*'   , MODEL_FIELD_OBRIGAT, .F.)

oModel:SetPrimaryKey({ 'BE4_FILIAL',;
						  'BE4_CODOPE',;
						  'BE4_CODLDP',;
						  'BE4_CODPEG',;
						  'BE4_NUMERO',; 
						  'BE4_SITUAC',;
						  'BE4_FASE'}) 

// Retorna o Modelo de dados
Return oModel
