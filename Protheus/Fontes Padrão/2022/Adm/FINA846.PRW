#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA846.CH"

Static aValores
Static lFWCodFil := .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA846   บAutor  ณBruno Sobieski      บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de manuten็ใo de recibos- Substitue a FINA087A e a   บฑฑ
ฑฑบ          ณFINA088                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION FINA846()
Local cFiltro := ""                            
Local l846BRW:= ExistBlock("846BRW")
Private oBrowse
// Instanciamento da Classe de Browse
If pergunte('FIN87A',.T.)
	oBrowse := FWMBrowse():New()
	// Defini็ใo da tabela do Browse
	oBrowse:SetAlias('FJT')
	// Defini็ใo da legenda
	oBrowse:AddLegend( "FJT_CANCEL=='1'", "RED"  , STR0002 )//"Cancelado"
	oBrowse:AddLegend( "FJT_VERATU=='0'", "BLACK" , STR0003+" "+STR0004 )//"Versใo"+"Inativa"
	oBrowse:AddLegend( "FJT_VERATU=='1'", "GREEN" , STR0003+" "+STR0005 )//"Versใo"+"Ativa"
	// Titulo da Browse
	oBrowse:SetDescription(STR0001)//'Recibos'
	// Opcionalmente pode ser desligado a exibi็ใo dos detalhes
	//oBrowse:DisableDetails()

	Setkey(VK_F12,{|| pergunte('FIN87A',.T.)})
	If l846BRW
		cFiltro:= ExecBlock("846BRW",.f.,.f.)
		If !Empty( cFiltro )
			oBrowse:SetFilterDefault( cFiltro )
		EndIf	
	EndIf
	

	// Ativa็ใo da Classe
	oBrowse:Activate()
Endif
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณBruno Sobieski      บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao dos menus                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()
Local aRotina := {}
//ADD OPTION aRotina Title 'Buscar por Cheque' Action 'F846PesqCH(oBrowse)' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FINA846' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0007 Action 'FINA840()' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0009 Action 'F846Alt(1)' OPERATION 4 ACCESS 0 //'Manut. por Recibo'
ADD OPTION aRotina Title STR0010 Action 'F846Alt(2)' OPERATION 4 ACCESS 0 //'Manut. por Cheques'
ADD OPTION aRotina Title STR0011+"/"+STR0012 Action 'VIEWDEF.FINA846' OPERATION 5 ACCESS 0 //'Anular/Excluir'
ADD OPTION aRotina Title STR0013 Action 'IIf(ExistBlock("F486PRT"),ExecBlock("F486PRT",.f.,.f.),FINR087())' OPERATION 8 ACCESS 0 //VERIFICAR COMO CHAMAR PARA QUE IMPRIMA O RECIBO POSICIONADO // 'Imprimir'
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณBruno Sobieski      บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do modelo de dados                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFJT := FWFormStruct( 1, 'FJT' )
Local oStruSEL1:= FWFormStruct( 1, 'SEL' )
Local oStruSEL2:= FWFormStruct( 1, 'SEL' )
Local oStruSEL3:= FWFormStruct( 1, 'SEL' )
Local oStruSEL4:= FWFormStruct( 1, 'SEL' )
Local oStruSFE := FWFormStruct( 1, 'SFE' )
Local oModel // Modelo de dados que serแ construํdo
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('FINA846', /*bPreValidacao*/ ,{ |oModel| F846TudoOk( oModel ) },{|oModel| FINA846GRV(oModel)} )

// Adiciona ao modelo um componente de formulแrio
oModel:AddFields( 'FJTMASTER', /*cOwner*/, oStruFJT)
// Adiciona ao modelo um componente de formulแrio
oModel:AddGrid( 'SELGRID1','FJTMASTER', oStruSEL1, , , ,  , {|oGrid,lCopia| F846FillData(oGrid,lCopia,1)})
oModel:AddGrid( 'SELGRID2','FJTMASTER', oStruSEL2, , , ,  , {|oGrid,lCopia| F846FillData(oGrid,lCopia,2)})
oModel:AddGrid( 'SELGRID3','FJTMASTER', oStruSEL3, , , ,  , {|oGrid,lCopia| F846FillData(oGrid,lCopia,3)})
oModel:AddGrid( 'SELGRID4','FJTMASTER', oStruSEL4, , , ,  , {|oGrid,lCopia| F846FillData(oGrid,lCopia,4)})
oModel:AddGrid( 'SFEGRID', 'SELGRID4' , oStruSFE, , , ,  ,  )

//Os campos nunca devem ser editแveis, e isso ้ protegido pela propria MVC,
//por้m quando ้ usada a op็ใo ALTERAR para a anula็ใo ้ necessแrio garantir que nใo sejam editados
oStruFJT:SetProperty(  '*' , MODEL_FIELD_NOUPD, .T.)            
oStruFJT:SetProperty(  'FJT_CANCEL' , MODEL_FIELD_NOUPD, .F.)            
oStruFJT:SetProperty(  'FJT_CANCEL' , MODEL_FIELD_INIT, {|| '1' })
oStruSEL1:SetProperty( '*' , MODEL_FIELD_NOUPD, .T.)
oStruSEL2:SetProperty( '*' , MODEL_FIELD_NOUPD, .T.)
oStruSEL3:SetProperty( '*' , MODEL_FIELD_NOUPD, .T.)
oStruSEL4:SetProperty( '*' , MODEL_FIELD_NOUPD, .T.)
oStruSFE:SetProperty(  '*' , MODEL_FIELD_NOUPD, .T.)

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'SELGRID1', { { 'EL_FILIAL', 'xFilial( "SEL" )' },{ 'EL_SERIE', 'FJT_SERIE' } , { 'EL_RECIBO' , 'FJT_RECIBO' },{ 'EL_VERSAO', 'FJT_VERSAO' } }, SEL->( IndexKey( 1 ) ) )
oModel:SetRelation( 'SELGRID2', { { 'EL_FILIAL', 'xFilial( "SEL" )' },{ 'EL_SERIE', 'FJT_SERIE' } , { 'EL_RECIBO' , 'FJT_RECIBO' },{ 'EL_VERSAO', 'FJT_VERSAO' } }, SEL->( IndexKey( 1 ) ) )
oModel:SetRelation( 'SELGRID3', { { 'EL_FILIAL', 'xFilial( "SEL" )' },{ 'EL_SERIE', 'FJT_SERIE' } , { 'EL_RECIBO' , 'FJT_RECIBO' },{ 'EL_VERSAO', 'FJT_VERSAO' } }, SEL->( IndexKey( 1 ) ) )
oModel:SetRelation( 'SELGRID4', { { 'EL_FILIAL', 'xFilial( "SEL" )' },{ 'EL_SERIE', 'FJT_SERIE' } , { 'EL_RECIBO' , 'FJT_RECIBO' },{ 'EL_VERSAO', 'FJT_VERSAO' } }, SEL->( IndexKey( 1 ) ) )
oModel:SetRelation( 'SFEGRID' , { { 'FE_FILIAL', 'xFilial( "SFE" )' },{ 'FE_RECIBO','EL_RECIBO' } , { 'FE_NROCERT', 'EL_NUMERO'  }}, SFE->( IndexKey( 6 ) ) )

oModel:SetVldActivate( {|oModel| F846PreVld(oModel:GetOperation()) } )

//Componente em fase de desenvolvimento em outubro de 2013. Quando pronto substituira o F486FillData()
//oModel:GetModel( 'SELGRID1' ):SetLoadFilter( { { 'EL_TIPODOC', "{'TB','RA','RG','RB','RI','RS'}", MVC_LOADFILTER_IS_NOT_CONTAINED } } )
//oModel:GetModel( 'SELGRID2' ):SetLoadFilter( { { 'EL_TIPODOC', "{'TB'}", MVC_LOADFILTER_IS_CONTAINED } } )
//oModel:GetModel( 'SELGRID3' ):SetLoadFilter( { { 'EL_TIPODOC', "{'RA'}", MVC_LOADFILTER_IS_CONTAINED } } )
//oModel:GetModel( 'SELGRID4' ):SetLoadFilter( { { 'EL_TIPODOC', "{'RG','RB','RI','RS'}", MVC_LOADFILTER_IS_CONTAINED } } )

// Adiciona a descri็ใo do Modelo de Dados
oModel:SetDescription( STR0008 ) //'Recibo'
// Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel( 'FJTMASTER' ):SetDescription( STR0014 ) //"Cabe็alho"
oModel:GetModel( 'SELGRID1' ):SetDescription( STR0015 )  //"Valores Recebidos'
oModel:GetModel( 'SELGRID2' ):SetDescription( STR0016 )  //'Cancelamentos'
oModel:GetModel( 'SELGRID3' ):SetDescription( STR0017 )  //Cr้ditos Gerados
oModel:GetModel( 'SELGRID4' ):SetDescription( STR0018 )  //Reten็๕es                
//ษ necessแrio ter a tabela SFE no modelo, pois caso conrario a exclusใo nใo podera ser confirmada pois hแ regra
//de dependencias entre as tabelas nos dicionarios
oModel:GetModel( 'SFEGRID'  ):SetDescription( STR0019+" "+STR0018 ) //'Detalhe Reten็๕es'

//oModel:GetModel( 'FJTMASTER' ):SetOnlyView ( Eval( oModel:GetOperation()}) )

// Retorna o Modelo de dados
Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณBruno Sobieski      บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do view                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'FINA846' )
// Cria a estrutura a ser usada na View
Local oStruFJT	:= FWFormStruct( 2, 'FJT' )
Local oStruSEL1:= FWFormStruct( 2, 'SEL',{|cCampo| F846Stru( cCampo,1 )} )
Local oStruSEL2:= FWFormStruct( 2, 'SEL',{|cCampo| F846Stru( cCampo,2 )} )
Local oStruSEL3:= FWFormStruct( 2, 'SEL',{|cCampo| F846Stru( cCampo,3 )} )
Local oStruSEL4:= FWFormStruct( 2, 'SEL',{|cCampo| F846Stru( cCampo,4 )} )
//Local oStruSFE	:= FWFormStruct( 2, 'SFE',{|cCampo| F846Stru( cCampo,4 )} )
Local oView
Local lReten := cPaisLoc $ 'URU|BOL|PTG|ANG|PER|ARG'

// Cria o objeto de View
oView := FWFormView():New()
// Define qual Modelo de dados serแ utilizado
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulแrio
// (antiga Enchoice)
oView:AddField( 'VIEW_FJT' , oStruFJT, 'FJTMASTER' )
oView:AddGrid ( 'VIEW_SEL1', oStruSEL1, 'SELGRID1' )
oView:AddGrid ( 'VIEW_SEL2', oStruSEL2, 'SELGRID2' )
oView:AddGrid ( 'VIEW_SEL3', oStruSEL3, 'SELGRID3' )
Iif(lReten,oView:AddGrid ( 'VIEW_SEL4', oStruSEL4, 'SELGRID4' ),)
//oView:AddGrid ( 'VIEW_SFE' , oStruSFE , 'SFEGRID' )

//Os campos nunca devem ser editแveis, e isso ้ protegido pela propria MVC,
//por้m quando ้ usada a op็ใo ALTERAR para a anula็ใo ้ necessแrio garantir que nใo sejam editados
oStruFJT:SetProperty( '*'  , MVC_VIEW_CANCHANGE,.F.)
oStruSEL1:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oStruSEL2:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oStruSEL3:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
Iif(lReten,oStruSEL4:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.),)
//oStruSFE:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)

// Criar um "box" horizontal para receber algum elemento da view
// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 40 )
oView:CreateHorizontalBox( 'INFERIOR'	, 60 )
oView:CreateFolder( 'PASTAS','INFERIOR')
oView:AddSheet( 'PASTAS', 'ABA01', STR0015 ) //"Valores Recebidos"
oView:AddSheet( 'PASTAS', 'ABA02', STR0016 ) //"Cancelamentos"
oView:AddSheet( 'PASTAS', 'ABA03', STR0017 ) //"Cr้ditos Gerados"
Iif(lReten,oView:AddSheet( 'PASTAS', 'ABA04', STR0018 ),) //"Reten็๕es"

oView:CreateHorizontalBox( 'BOXABA01', 100,,, "PASTAS", "ABA01" )
oView:CreateHorizontalBox( 'BOXABA02', 100,,, "PASTAS", "ABA02" )
oView:CreateHorizontalBox( 'BOXABA03', 100,,, "PASTAS", "ABA03" )
Iif(lReten,oView:CreateHorizontalBox( 'BOXABA04', 100,,, "PASTAS", "ABA04" ),)
//oView:CreateHorizontalBox( 'BOXABA0401', 50,,, "PASTAS", "ABA04" )
//oView:CreateHorizontalBox( 'BOXABA0402', 50,,, "PASTAS", "ABA04" )

// Relaciona o identificador (ID) da View com o "box" para exibi็ใo
// Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:SetOwnerView( 'VIEW_FJT', 'SUPERIOR' )

oView:SetOwnerView( 'VIEW_SEL1', 'BOXABA01' )
oView:SetOwnerView( 'VIEW_SEL2', 'BOXABA02' )
oView:SetOwnerView( 'VIEW_SEL3', 'BOXABA03' )
Iif(lReten,oView:SetOwnerView( 'VIEW_SEL4', 'BOXABA04' ),)
//oView:SetOwnerView( 'VIEW_SFE' , 'BOXABA0402' )

//oView:EnableTitleView('VIEW_FJT')
oView:EnableTitleView('VIEW_SEL1',STR0020) //"Valores recebidos como forma de pagamento"
oView:EnableTitleView('VIEW_SEL2',STR0021) //"Documentos pagos e cr้ditos compensados"
oView:EnableTitleView('VIEW_SEL3',STR0022) //"Documentos de cr้dito que foram gerados com o saldo que nใo foi aplicado"
Iif(lReten,oView:EnableTitleView('VIEW_SEL4',STR0023),) //"Certificados de reten็๕es de impostos recebidos"
//oView:EnableTitleView('VIEW_SFE' ,'Detalles de los certificados de retenci๓n')
// Retorna o objeto de View criado
Return oView
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846Stru  บAutor  ณBruno Sobieski      บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine os campos que serao mostrados em cada pasta          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F846Stru( cCampo,nFolder )
Local lRet := .T.
Local aCposNo	:=	{}
Local aCposNoUsr
Local nX
cCampo	:=	Alltrim(cCampo)

aCposNo	:=	{'EL_FILIAL','EL_RECIBO','EL_CLIORIG','EL_LOJORIG', 'EL_NATUREZ', 'EL_TIPODOC','EL_LA', 'EL_CANCEL','EL_DTDIGIT','EL_PREREC','EL_COBRAD',;
 'EL_RECPROV','EL_CLIENTE', 'EL_LOJA', 'EL_SERIE', 'EL_EMISREC','EL_RETGAN','EL_VERSAO'}
Do Case
	Case nFolder == 1
		AAdd(aCposNo,"EL_JUROS")
		AAdd(aCposNo,"EL_MULTA")
	Case nFolder == 2
		AAdd(aCposNo,"EL_TPCRED")
		AAdd(aCposNo,"EL_BANCO")
		AAdd(aCposNo,"EL_AGENCIA")
		AAdd(aCposNo,"EL_CONTA")
		AAdd(aCposNo,"EL_BCOCHQ")
		AAdd(aCposNo,"EL_AGECHQ")
		AAdd(aCposNo,"EL_CTACHQ")
		AAdd(aCposNo,"EL_OBSBCO")
		AAdd(aCposNo,"EL_ENDOSSA")
		AAdd(aCposNo,"EL_ACREBAN")
		AAdd(aCposNo,"EL_TERCEIR")
		AAdd(aCposNo,"EL_DTDIGIT")
		AAdd(aCposNo,"EL_EMISREC")
		AAdd(aCposNo,"EL_POSTAL")
		AAdd(aCposNo,"EL_TRANSIT")
		AAdd(aCposNo,"EL_TIPODOC")
		AAdd(aCposNo,"EL_CGC")
	Case nFolder == 3
		AAdd(aCposNo,"EL_JUROS")
		AAdd(aCposNo,"EL_MULTA")
		AAdd(aCposNo,"EL_EMISREC")
		AAdd(aCposNo,"EL_TPCRED")
		AAdd(aCposNo,"EL_BANCO")
		AAdd(aCposNo,"EL_AGENCIA")
		AAdd(aCposNo,"EL_CONTA")
		AAdd(aCposNo,"EL_BCOCHQ")
		AAdd(aCposNo,"EL_AGECHQ")
		AAdd(aCposNo,"EL_CTACHQ")
		AAdd(aCposNo,"EL_OBSBCO")
		AAdd(aCposNo,"EL_ENDOSSA")
		AAdd(aCposNo,"EL_ACREBAN")
		AAdd(aCposNo,"EL_TERCEIR")
		AAdd(aCposNo,"EL_DTDIGIT")
		AAdd(aCposNo,"EL_EMISREC")
		AAdd(aCposNo,"EL_POSTAL")
		AAdd(aCposNo,"EL_TRANSIT")
		AAdd(aCposNo,"EL_TIPODOC")
		AAdd(aCposNo,"EL_CGC")
	Case nFolder == 4
		AAdd(aCposNo,"EL_JUROS")
		AAdd(aCposNo,"EL_MULTA")
		AAdd(aCposNo,"EL_EMISREC")
		AAdd(aCposNo,"EL_TPCRED")
		AAdd(aCposNo,"EL_BANCO")
		AAdd(aCposNo,"EL_AGENCIA")
		AAdd(aCposNo,"EL_CONTA")
		AAdd(aCposNo,"EL_BCOCHQ")
		AAdd(aCposNo,"EL_AGECHQ")
		AAdd(aCposNo,"EL_CTACHQ")
		AAdd(aCposNo,"EL_OBSBCO")
		AAdd(aCposNo,"EL_ENDOSSA")
		AAdd(aCposNo,"EL_ACREBAN")
		AAdd(aCposNo,"EL_TERCEIR")
		AAdd(aCposNo,"EL_DTDIGIT")
		AAdd(aCposNo,"EL_EMISREC")
		AAdd(aCposNo,"EL_POSTAL")
		AAdd(aCposNo,"EL_TRANSIT")
		AAdd(aCposNo,"EL_CGC")
EndCase
If ExistBlock('F486CPOS')
	aCposNoUsr	:=	ExecBlock('F486CPOS',.f.,.f.,{aCposNo,nFolder})
	If ValType(aCposNoUsr ) == "A"
		For nX:= 1 to Len(aCposNoUsr)
			aadd(aCposNo,aCposNoUsr[nX])
		Next
	Endif
Endif

lRet := aSCAN(aCposNo,{|x| cCampo==x}) == 0
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846FillData บAutor  ณBruno Sobieski   บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados em cada pasta de acordo com a natureza de  บฑฑ
ฑฑบ          ณcada um.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F846FillData(oGrid,lCopia,nPasta)
Local aRet := {}
Local aRet2	:=	{}
Local nX        

aRet2  := FormLoadGrid(oGrid,lCopia)
For nX:= 1 TO Len(aRet2)
	SEL->(MsGoto(aRet2[nX,1]))
	Do Case
		Case nPasta == 1 .And. !(Alltrim(SEL->EL_TIPODOC) $'TB/RA/RG/RB/RI/RS')
			aadd(aRet,aClone(aRet2[nX]))
		Case nPasta == 2 .And. (Alltrim(SEL->EL_TIPODOC) =='TB')
			aadd(aRet,aClone(aRet2[nX]) )
		Case nPasta == 3 .And. (Alltrim(SEL->EL_TIPODOC) =='RA')
			aadd(aRet,aClone(aRet2[nX])  )
		Case nPasta == 4 .And. (Alltrim(SEL->EL_TIPODOC) $'RG/RB/RI/RS')
			aadd(aRet,aClone(aRet2[nX]))
	EndCase
Next
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846TudoOk    บAutor  ณBruno Sobieski  บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de tudoOk. Valida o formulario na confirmacao.       บฑฑ
ฑฑบ          ณUsar somente a funcao HELP para mostrar mensagens, pois ้   บฑฑ
ฑฑบ          ณa ๚nica preparada para funcionar no modelo MVC !!!!         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F846TudoOk( oModel )
Local lRet := .T.
Local nOperation 	:= oModel:GetOperation()
Local lIsRotAuto	:=	.F.
If nOperation == MODEL_OPERATION_DELETE
	If FJT->FJT_VERATU <> '1' 
		lRet	:=	.F.	
		Help(" ",1,"HELP",STR0024,STR0025,1,0) //"Atenci๓n","Esta opera็ใo s๓ pode ser executada com a ultima versใo do recibo"
	Endif	
	//Quando a rotina ้ automatica nao pode mostrar a tela. 
	If lRet.And. !lIsRotAuto
		If FJT->FJT_CANCEL == '1'
			If (Aviso(STR0024+": "+STR0026,STR0027+chr(13)+chr(10)+STR0028,{STR0029,STR0030}) <> 1) // "Aten็ใo: "+"Exclussใo","Todas as vers๕es deste recibo serใo excluidas definitivamente dos registros do sistema."+chr(13)+chr(10)+'Confirma เ exclusใo?',{'Sim','Nใo'})
            lRet	:=	.F.
				Help("" ,1, 'Help',STR0031,STR0032, 1, 0 ) //"FA088 - Exclusใo abortada","Opera็ใo cancelada pelo usuario"			
			Endif
		Else
			Aviso(STR0024+": "+STR0033,STR0034+chr(13)+chr(10)+STR0035,{'Ok'}) //'Aten็ใo: "+"Cancelamento","Todas as vers๕es deste recibo serใo canceladas","Para excluir definitivamente chamar novamente esta rotina despois de confirmar o cancelamento"
		Endif
	Endif
	If lRet.And. !Fa088VldCa(FJT->FJT_RECIBO,.F.,FJT->FJT_SERIE) //validacao para o peru
		Help(" ",1,"HELP",STR0036,STR0037,1,0) //"FA088 - RETENวรO APURADA","Ja existe uma apura็ใo de IGV posterior เ data deste recibo. Se ainda nใo foi apresentada, exclua e tente novamente."
		lRet	:=	.F.	
	Endif	
	If lRet
		If !(DtMovFin(FJT->FJT_DTDIGI,.F.))					//menor que MV_DATAFIM
			Help ( " ", 1, "DTMOVFIN")
			lRet	:=	.F.
		Else 
			DbSelectArea('SEL')
			DbSetorder(8)
			DbSeek(xFilial()+FJT->FJT_SERIE+FJT->FJT_RECIBO) ///TROCAR REVISA POR VERSAO
			WHILE lRet .And. !Eof() .And. xFilial()+FJT->FJT_SERIE+FJT->FJT_RECIBO+FJT->FJT_VERSAO == EL_FILIAL+EL_SERIE+EL_RECIBO+EL_VERSAO
				If !(SubsTR(EL_TIPODOC,1,2)$"TB|RI|RG|RB|RS")
					SE1->(DbSetOrder(2))
					If SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO) )
						//Verifica se teve alguma baixa
						If SE1->E1_SALDO <> SE1->E1_VALOR
							lRet	:=	.F.
							If Subs(EL_TIPODOC,1,2)<>'RA'
								Help( ,, 'Help',, I18N(STR0038,{SEL->EL_PREFIXO+"/"+SEL->EL_NUMERO}), 1, 0 ) //"O documento #1[EL_PREFIXO/EL_NUMERO]# recebido por esta opera็ใo sofreu cancelamento(s)"
							Else
								Help( ,, 'Help',, I18N(STR0039,{SEL->EL_PREFIXO+"/"+SEL->EL_NUMERO}), 1, 0 ) //"O documento de cr้dito #1[EL_PREFIXO/EL_NUMERO]# gerado por esta opera็ใo sofreu cancelamento(s)"							
							Endif
							//Verifica se ainda esta em carteira (nao ้ necessแrio verificar para os titulos de credito gerados)
						ElseIf Subs(EL_TIPODOC,1,2)<>'RA' .And.!SE1->E1_SITUACA$"0 "
							//Este cPaisLoc ้ por causa do tratamento de carteira de cheques, inicialmente implementado s๓ para Argentina,
							//neste tratamento os cheques podem ter diferentes status, caso nao seja argentina simplesmente avisa que nao esta em carteira
							If cPaisLoc <> 'ARG' .Or. RTRIM(EL_TIPODOC) <> "CH"
								lRet	:=	.F.
								Help( ,, 'Help',, I18N(STR0040,{SEL->EL_PREFIXO+"/"+SEL->EL_NUMERO}), 1, 0 ) //"O documento #1[EL_PREFIXO/EL_NUMERO]# gerado por esta opera็ใo sofreo altera็๕es (cobrado,transferido, etc.)"
								//Para os cheques da Argentina verifica o status
							Else
								nRet:=FA088CkSEF(EL_BCOCHQ,EL_AGECHQ,EL_CTACHQ,EL_PREFIXO,EL_NUMERO) //verifica se existe historico ou foi usado na OP
								If nRet == 0 //U
									lRet:=.F.
									Help(" ",1,"HELP",STR0041,STR0042,1,0) //"FA088 - RECIBO LIQUIDADO","Este recibo nใo pode ser cancelado ou excluido."
								Else //N
									lRet:=.F.
									Help(" ",1,"HELP",STR0043,STR0044,1,0) //"FA088 - CHEQUE EM CARTEIRA","Este recibo possui cheque em carteira no Controle de Cheques."
								Endif
							Endif 
						Endif
					Endif
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerificar se o documento foi ajustado por diferencia ณ
				//ณde cambio com data posterio a OP                     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If cPaisLoc $ "ARG|URU"
					SIX->(DbSetOrder(1))
					If SIX->(DbSeek('SFR'))
						DbSelectArea('SFR')
						DbSetOrder(1)
						DbSeek(xFilial()+"1"+SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO+Dtos(SEL->EL_DTDIGIT),.T.)
						If FR_FILIAL==xFilial() .And.	FR_CHAVOR==SEL->EL_CLIENTE+SEL->EL_LOJA+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO.And.;
							SFR->FR_CARTEI=="1".And.SEL->EL_DTDIGIT <= SFR->FR_DATADI
							Help(" ",1,"HELP",STR0045,I18N(STR0046,{SEL->EL_PREFIXO+"/"+SEL->EL_NUMERO}),1,0) //"FA088 - DIF DE CAMBIO","O cancelamento do documento #1[prefixo/documento]# jแ foi corregido por diferen็a de cambio."
							lRet:=.F.
						Endif
						DbSelectArea('SEL')
					Endif
				Endif
				DbSElectArea('SEL')
				dBSkip()
			EndDo
		Endif
	Endif
Endif
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina846Vlr    บAutor  ณBruno Sobieski   บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao usada como inicializo padrao dos campos de valores   บฑฑ
ฑฑบ          ณtotais do recibo                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina846Vlr(nOpcao)
Local nComp	:=	0
Local nTB	:=	0
Local nTR	:=	0
Local nTRa	:=	0
Local nRet	:=	0
Local nDecs := MsDecimais(1)
If aValores <> Nil .And. aValores[1] == FJT->(FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO)
	nRet	:=	aValores[2][nOpcao]
Else
	DbSelectArea('SEL')
	DbSetorder(8)
	DbSeek(xFilial()+FJT->FJT_SERIE+FJT->FJT_RECIBO) ///TROCAR REVISA POR VERSAO
	Do While xFilial()==EL_FILIAL .And. EL_RECIBO==FJT->FJT_RECIBO .And. EL_SERIE == FJT->FJT_SERIE.And. EL_VERSAO == FJT->FJT_VERSAO
		If Subs(EL_TIPODOC,1,2)=="TB"
			If EL_TIPO $ MVRECANT+"/"+MV_CRNEG
				nComp	+= EL_VLMOED1
			Else
				nTB	+= EL_VLMOED1
			Endif
		ElseIf   Subs(EL_TIPODOC,1,2)$"RI|RG|RB|RS"
			nTR	+= EL_VLMOED1
		ElseIf Subs(EL_TIPODOC,1,2)=="RA"
			nTRa	+=	EL_VLMOED1
		Endif
		DbSkip()
	Enddo
	aValores	:=	{FJT->(FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO),{Round(nTB-nTR-nComp+nTRa,nDecs),Round(nTB,nDecs),Round(nTRa,nDecs),Round(nTR,nDecs)}}
	nRet	:=	aValores[2][nOpcao]
Endif
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina846grv    บAutor  ณBruno Sobieski   บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao qua faz a gravacao do formulario                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA846GRV(oModel)
Local cAlias		:= ""
Local cKeyImp		:= ""
Local cArquivo	:= ""
Local nHdlPrv		:= 0
Local nTotalLanc	:= 0
Local cLoteCom	:= ""
Local nLinha		:= 2
Local cPadrao		:= ""
Local lLanctOk	:= .F.
Local lLancPad70:= .F.
Local aFlagCTB	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local nOrdSE5		:= 0 //Usada para posicionar no indice E5_FILIAL+E5_PROCTRA
Local aTitRec		:= {}
Local aChaveCH	:= {}
Local aChaveRet := {}
Local nChaveCH	:= 0
Local cFilSEF		:= ""
Local cFilFRF		:= ""
Local cChaveCH	:= ""
Local nRegSM0 	:= SM0->(RecNo())
Local nRegAnt		:= SM0->(RecNo())
Local nOperation := oModel:GetOperation()
Local lDigita  	
Local lAglutina	
Local aDiario :={}                                           
Local cSerie	:=	""
Local cRecibo	:=	""
Pergunte('FIN87A',.F.)
Private lGeraLanc	:= If( MV_PAR01==1,.T.,.F.)  // Lanctos. On-Line
lDigita  	:= If( mv_par01==1,.T.,.F.)  // Mostra Lanctos.
lAglutina	:= If( mv_par02==1,.T.,.F.)  // Aglutina Lanctos.

nRegSM0 := SM0->(Recno())
SA1->(DbSetOrder(1))

If nOperation == MODEL_OPERATION_DELETE
	//+--------------------------------------------------------------------------------+
	//ฆChequeo que no se puedan cancelar recibos cuyos cheques no estan en Cartera     ฆ
	//+--------------------------------------------------------------------------------+
	If FJT->FJT_CANCEL <> '1'
		// Posiciona Cliente - Sergio Camurca
		SA1->(DbSeek(xFilial("SA1")+FJT->FJT_CLIENT+FJT->FJT_LOJA))
		While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt
			cFilAnt  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			nRegAnt	 := SM0->(RecNo())
			aChaveCH := {}
			DbSelectArea("SEL")
			DbSetOrder(8)
			DbSeek(FwxFilial("SEL")+FJT->FJT_SERIE+FJT->FJT_RECIBO)
			Do While FwxFilial("SEL")==EL_FILIAL.AND.FJT_RECIBO==EL_RECIBO .AND. FJT->FJT_SERIE==EL_SERIE
				If FJT->FJT_VERSAO == SEL->EL_VERSAO
					If !(Subs(EL_TIPODOC,1,2) $ "RG|RI|RB|RS")
						
						SM0->(dbGoTo(nRegSM0))
						cFilAnt := SM0->M0_CODFIL
						F088AtuaSE1(FJT->FJT_SERIE,FJT->FJT_RECIBO)
						SM0->(dbGoTo(nRegAnt))
						cFilAnt := SM0->M0_CODFIL
						
					Endif
					
					If cPaisLoc == "COS"
						aAdd(aTitRec,SEL->(FwxFilial("SE1")+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO))
					EndIf
					IF !Empty(SEL->EL_COBRAD) .and. !(Alltrim(SEL->EL_TIPODOC) $"TB|RA")
						fa088Comis(FJT->FJT_SERIE,FJT->FJT_RECIBO)
					EndIf
					If cPaisLoc $ "ARG|COS" .AND. ALLTRIM(SEL->EL_TIPODOC) == "CH"
						Aadd(aChaveRet,{SEL->EL_BCOCHQ,SEL->EL_AGECHQ,SEL->EL_CTACHQ,SEL->EL_PREFIXO,SEL->EL_NUMERO})
					Endif
				Endif
				RecLock("SEL",.F.)
				Replace EL_CANCEL With .T.
				MsUnLock()
				SEL->(DbSkip())
			EndDo
			F088DelSE5(FJT->FJT_SERIE,FJT->FJT_RECIBO)
			F088DelRet(aTitRec,FJT->FJT_SERIE,FJT->FJT_RECIBO)  // Borra todos los documentos relativos a Retenciones.
			F088DelNCC(FJT->FJT_SERIE,FJT->FJT_RECIBO,FJT->FJT_VERSAO)  // excluir as NCCs geradas a partir do recibo excluido
			SM0->(DbSkip())
		End
		//+--------------------------------------------------------------+
		//ฆ Genera asiento contable.                                     ฆ
		//+--------------------------------------------------------------+
		SM0->(dbGoTo(nRegSM0))
		cFilAnt := SM0->M0_CODFIL

		If lGeraLanc // .and. !__TTSInUse
			
			//+--------------------------------------------------------------+
			//ฆ Posiciona numero do Lote para Lancamentos do Financeiro      ฆ
			//+--------------------------------------------------------------+
			dbSelectArea("SX5")
			dbSeek(xFilial()+"09FIN")
			cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
			//nHdlPrv:=HeadProva(cLoteCom,"FINA088",Subs(cUsuario,7,6),@cArquivo)
			nHdlPrv := HeadProva( cLoteCom,;
			"FINA088",;
			Substr( cUsuario, 7, 6 ),;
			@cArquivo )
			
			If nHdlPrv <= 0
				Help(" ",1,"A100NOPROV")
			EndIf
		EndIf
		If nHdlPrv > 0 .and. lGeraLanc //.and. !__TTSInUse
			SEL->(DbSetOrder(8))
			SEL->(DbSeek(xFilial("SEL")+FJT->FJT_SERIE+FJT->FJT_RECIBO,.F.))
			Do while !SEL->(EOF()).And.SEL->EL_RECIBO==FJT_RECIBO .And. SEL->EL_SERIE == FJT->FJT_SERIE
				If UsaSeqCor()
					aDiario := {{"SEL",SEL->(recno()),SEL->EL_DIACTB,"EL_NODIA","EL_DIACTB"}}
				endif
				
				Do Case 
					Case SEL->EL_TIPODOC == "TB" .And. SEL->EL_TIPO $ MV_CRNEG+"/"+MVRECANT .And. VerPadrao("5BV")   //Titulo de Credito
						lLancPad70 := .T. 
						cPadrao := "5BV" 
					Case SEL->EL_TIPODOC == "TB" .And. !(SEL->EL_TIPO $ MV_CRNEG+"/"+MVRECANT) .And. VerPadrao("5BX") // Titulo de Debito
						lLancPad70 := .T.
						cPadrao := "5BX"			
					Case SEL->EL_TIPODOC == "RA" .And. VerPadrao("5BW")
						lLancPad70 := .T. 
						cPadrao := "5BW"
					Case SEL->EL_TIPODOC == "CH" .And. VerPadrao("5BY")
						lLancPad70 := .T.  
						cPadrao := "5BY"
					Case SEL->EL_TIPODOC == "DC" .And. VerPadrao("5BZ")
						lLancPad70 := .T.
						cPadrao := "5BZ"
					Case SEL->EL_TIPODOC == "EF" .And. VerPadrao("5C2")
						lLancPad70 := .T. 
						cPadrao := "5C2"
					Case SEL->EL_TIPODOC == "TF" .And. VerPadrao("5C1")
						lLancPad70 := .T.
						cPadrao := "5C1"
					Case SEL->EL_TIPODOC $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5C3")
						lLancPad70 := .T.
						cPadrao := "5C3"
					Otherwise
						lLancPad70 := VerPadrao("576")
						cPadrao := "576"   
				EndCase				
				 
				If lLancPad70
					SA6->(DbsetOrder(1))
					SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
					SE1->(DbsetOrder(2))
					SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))
					If SEL->EL_LA=="S"
						Do Case
							Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
								cAlias := "SF1"
							Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
								cAlias := "SF1"
							Otherwise
								cAlias := "SF2"
						EndCase
						cKeyImp := 	xFilial(cAlias)	+;
						SE1->E1_NUM		+;
						SE1->E1_PREFIXO	+;
						SE1->E1_CLIENTE	+;
						SE1->E1_LOJA
						If ( cAlias == "SF1" )
							cKeyImp += SE1->E1_TIPO
						Endif
						Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"EL_LA", "C", "SEL", SEL->( Recno() ), 0, 0, 0} )
						Else
							RecLock("SEL",.F.)
							Replace EL_LA With "C"
							MsUnLock()
						Endif
						
						nTotalLanc := nTotalLanc + DetProva( 	nHdlPrv,;
						cPadrao,;
						"FINA088",;
						cLoteCom,;
						nLinha,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						@aFlagCTB,;
						/*aTabRecOri*/,;
						/*aDadosProva*/ )
					Endif
					
				Endif
				
				SEL->(DbSkip())
			ENDDO
			If lLancPad70
				IF cPaisLoc == "PER"
					nOrderSE5:=SE5->(IndexOrd())
					SE5->(dBSetOrder(8))
					IF SE5->(DbSeek(xFilial("SE5")+FJT->FJT_RECIBO+FJT->FJT_SERIE))
						Do While (xFilial("SE5")==SE5->E5_FILIAL .And. FJT->FJT_RECIBO==SE5->E5_ORDREC .And. FJT->FJT_SERIE == SE5->E5_SERREC)
							If !(SE5->E5_TIPODOC $ "BA/JR/MT/OG/DC") .And. SE5->E5_TIPO!="CH"
								nRecOldE5:=SE5->(Recno())
								nProcITF:=SE5->E5_PROCTRA
								nOrdSE5 := SE5ProcInd()
								SE5->(DbSetOrder(nOrdSE5))
								IF SE5->(DBSeek(xFilial("SE5")+nProcITF))
									While !SE5->(Eof()) .And. SE5->E5_PROCTRA == nProcITF
										If lFindITF .And. FinProcITF( SE5->( Recno() ),2 )
											FinProcITF( SE5->( Recno() ),5,, .F.,{ nHdlPrv, "573", "", "FINA089", cLotecom } , @aFlagCTB )
										EndIf
										SE5->(DBSkip())
									Enddo
								Endif
								SE5->(dBSetOrder(8))
								SE5->(DbGoTo(nRecOldE5))
							ENDIF
							SE5->(DBSkip())
						ENDDO
					ENDIF
					SE5->(DbSetOrder(nOrderSE5))
				ENDIF
				//+-----------------------------------------------------+
				//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
				//+-----------------------------------------------------+
				RodaProva(  nHdlPrv,;
				nTotalLanc)
				//+-----------------------------------------------------+
				//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
				//+-----------------------------------------------------+
				lLanctOk := cA100Incl( cArquivo,;
				nHdlPrv,;
				3,;
				cLoteCom,;
				lDigita,;
				lAglutina,;
				/*cOnLine*/,;
				/*dData*/,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				aDiario )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
				
				If !lLanctOk
					SEL->(DbSeek(xFilial("SEL")+FJT->FJT_SERIE+FJT->FJT_RECIBO))
					Do while FJT->FJT_RECIBO==SEL->EL_RECIBO .AND. FJT->FJT_SERIE==SEL->EL_SERIE .AND. SEL->(!EOF())
						RecLock("SEL",.F.)
						Replace SEL->EL_LA With "S"
						MsUnLock()
						SEL->(DbSkip())
					Enddo
				EndIf
			Endif
		Endif
		cSerie	:=	FJT->FJT_SERIE
		cRecibo	:=	FJT->FJT_RECIBO
		FJT->(DbSetOrder(1))
		FJT->(DbSeek(xFilial()+cSerie+cRecibo))
		While !FJT->(Eof()) .And. xFilial("FJT")+cSerie+cRecibo == FJT->(FJT_FILIAL+FJT_SERIE+FJT_RECIBO)
			RecLock('FJT',.F.)
			FJT_CANCEL	:=	'1'
			MsUnLock()                                                                               
			FJT->(dBsKIP())
		EndDo	
		/*
		Atualiza os arquivos de controle de cheques recebidos*/
		If !Empty(aChaveRet)
			cFilSEF := xFilial("SEF")
			cFilFRF := xFilial("FRF")
			For nChaveCH := 1 To Len(aChaveRet)
				/*
				apaga os registros do historico */
				If FRF->(dbSeek(cFilFRF + aChaveRet[nChaveCH,1] + aChaveRet[nChaveCH,2] + aChaveRet[nChaveCH,3] + aChaveRet[nChaveCH,4] + aChaveRet[nChaveCH,5]))
					While !FRF->(Eof()) .And. FRF->FRF_FILIAL == cFilFRF .And. FRF->FRF_BANCO == aChaveRet[nChaveCH,1]  .And. FRF->FRF_AGENCIA == aChaveRet[nChaveCH,2] ;
						.And. FRF->FRF_CONTA == aChaveRet[nChaveCH,3]  .And. FRF->FRF_PREFIX == aChaveRet[nChaveCH,4] .And. FRF->FRF_NUM == aChaveRet[nChaveCH,5]
						RecLock("FRF",.F.)
						FRF->(DbDelete())
						FRF->(MsUnLock())
						FRF->(dbSkip())
					EndDo
				Endif
				/*
				apaga o registro do cheque */
				cChaveCH := cFilSEF + aChaveRet[nChaveCH,1] + aChaveRet[nChaveCH,2] + aChaveRet[nChaveCH,3] + aChaveRet[nChaveCH,5]
				If SEF->(DbSeek(cChaveCH))
					RecLock("SEF",.F.)
					SEF->(DbDelete())
					SEF->(MsUnLock())
				Endif
			Next
		Endif
		/**/
		If cPaisLoc == "PER"
			If !(lLancPad) .OR. nHdlPrv <= 0
				nOrderSE5:=SE5->(IndexOrd())
				SE5->(dBSetOrder(8))
				IF SE5->(DbSeek(xFilial("SE5")+FJT->FJT_RECIBO+FJT->FJT_SERIE))
					Do While (xFilial("SE5")==SE5->E5_FILIAL .And. FJT->FJT_RECIBO==SE5->E5_ORDREC .And. FJT->FJT_SERIE == SE5->E5_SERREC)
						If !(SE5->E5_TIPODOC $ "BA/JR/MT/OG/DC") .And. SE5->E5_TIPO!="CH"
							nRecOldE5:=SE5->(Recno())
							nProcITF:=SE5->E5_PROCTRA
							nOrdSE5 := SE5ProcInd()
							SE5->(DbSetOrder(nOrdSE5))
							IF SE5->(DBSeek(xFilial("SE5")+nProcITF))
								While !SE5->(Eof()) .and. SE5->E5_PROCTRA == nProcITF
									If lFindITF .And. FinProcITF( SE5->( Recno() ),2 )
										FinProcITF( SE5->( Recno() ),5,, .F.)
									EndIf
									SE5->(DBSkip())
								Enddo
							Endif
							SE5->(dBSetOrder(8))
							SE5->(DbGoTo(nRecOldE5))
						EndIf
						SE5->(DBSkip())
					ENDDO
				ENDIF
				SE5->(DbSetOrder(nOrderSE5))
			ENDIF
		Endif
	Else
		f088NumPend(FJT->FJT_SERIE,FJT->FJT_RECIBO)
		dbSelectArea("SEL")
		DbSeek(xFilial("SEL")+FJT->FJT_SERIE+FJT->FJT_RECIBO)
		Do While xFilial("SEL")==SEL->EL_FILIAL .AND. FJT->FJT_RECIBO==SEL->EL_RECIBO .AND. FJT->FJT_SERIE==SEL->EL_SERIE
			RecLock("SEL",.F.)
			dbDelete()
			MsUnLock()
			SEL->(dbSkip())
		EndDo
		cSerie	:=	FJT->FJT_SERIE
		cRecibo	:=	FJT->FJT_RECIBO
		FJT->(DbSetOrder(1))
		FJT->(DbSeek(xFilial()+cSerie+cRecibo))
		While !FJT->(Eof()) .And. xFilial('FJT')+cSerie+cRecibo == FJT->(FJT_FILIAL+FJT_SERIE+FJT_RECIBO)
			RecLock('FJT',.F.)
			DbDelete()
			MsUnLock()
			FJT->(dBsKIP())
		EndDo	
	Endif
Endif


DbSelectArea("SEL")
DbSetOrder(1)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846Alt       บAutor  ณBruno Sobieski   บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para manutencao do recibo. Usa a FINA841.            บฑฑ
ฑฑบDesc.     ณdeve ser planejado para converter a FINA841 para MVC puro  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F846Alt(nOpcao)
Local lRet	:=	.T.
Pergunte("FIN87A",.F.)
Private lGeraLanc	:= If( MV_PAR01==1,.T.,.F.)  // Lanctos. On-Line
Private lDigita	:= If( mv_par02==1,.T.,.F.)
Private lAglutina	:= If( mv_par03==1,.T.,.F.)
If F846PreVld(4)
	If nOpcao == 1
		Fina841(FJT->FJT_RECIBO,FJT->FJT_SERIE)
	Else
		Fina841(Nil)
	Endif	
Else
	lRet	:=	.F.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846PreVld    บAutor  ณBruno Sobieski   บ Data ณ  10/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar que seja excluido o alterado unicamente บฑฑ
ฑฑบDesc.     ณa ultima revisao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F846PreVld(nOperation)
Local lRet := .T. 
Local aArea   	:= GetArea()
Local aChaveCH := {}
Local cChaveCH := ""

If (nOperation == MODEL_OPERATION_DELETE .Or.nOperation == MODEL_OPERATION_UPDATE) .And. FJT->FJT_VERATU <> '1'
	lRet := .F.
	Help(" ",1,"HELP",STR0024,STR0025,1,0) //"Aten็ใo","Esta opera็ใo s๓ pode ser executada com a ultima versใo do recibo"
Endif  
if lRet    
	DbSelectArea("SEL")
	DbSetOrder(8)
	If DbSeek(FwxFilial("SEL")+FJT->FJT_SERIE+FJT->FJT_RECIBO)
		Aadd(aChaveCH,{SEL->EL_BCOCHQ,SEL->EL_AGECHQ,SEL->EL_CTACHQ,SEL->EL_PREFIXO,SEL->EL_NUMERO})
    Endif
	cChaveCH := xFilial("SEF") + aChaveCH[1,1] + aChaveCH[1,2] + aChaveCH[1,3] + aChaveCH[1,5]
	If SEF->(DbSeek(cChaveCH))
		If nOperation == 5 .And. SEF->EF_STATUS # '01'   // Ativo
			Help(" ",1,"HELP",STR0041,STR0042,1,0)//"FA088 - RECIBO LIQUIDADO"//"Este recibo nใo pode ser cancelado ou excluido."
			lRet:=.F.	   
		Endif	
	Endif	
Endif	
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF846PesqCH    บAutor  ณBruno Sobieski   บ Data ณ  10/27/12  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para pesquisar um recibo de acordo com o cheque      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F846PesqCH(oBrowse) 
Local cQryRecibo	:=	""
Local lRet	:=	.F.
Local cAlsRecibo := GetNextAlias()

If Pergunte('FINA841',.T.)
	cQryRecibo := "SELECT "
	cQryRecibo += " SEL.EL_RECIBO, SEL.EL_SERIE "
	cQryRecibo += " FROM " + RetSqlName("SEL") + " SEL "
	cQryRecibo += " WHERE "
	cQryRecibo += " SEL.EL_NUMERO = '" + MV_PAR01 + "' AND "
	cQryRecibo += " SEL.EL_BCOCHQ = '" + MV_PAR02 + "' AND "
	cQryRecibo += " SEL.EL_AGECHQ = '" + MV_PAR03 + "' AND "
	cQryRecibo += " SEL.EL_CTACHQ = '" + MV_PAR04 + "' AND "
	cQryRecibo += " SEL.EL_TIPODOC = 'CH' AND "
	
	cQryRecibo += RetSqlCond("SEL") 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRecibo),cAlsRecibo,.T.,.T.)
	If (cAlsRecibo)->(!Eof())
		FJT->(DbSetOrder(1))
		FJT->(DbSeek(xFilial()+(cAlsRecibo)->EL_SERIE+(cAlsRecibo)->EL_RECIBO))	
		oBrowse:GoTo (FJT->(Recno()),.T.)
		lRet	:=	.T.
	Else
		MsgAlert(STR0047) //"Cheque nใo encontrado"
	EndIf
	(cAlsRecibo)->(DbCloseArea())
Endif
Return lRet