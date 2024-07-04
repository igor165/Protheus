#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA871C.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA871C
Monitor de servicos financeiros.

@author Varejo
@since 20/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA871C()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFI' )
oBrowse:SetDescription(STR0002) //"Monitor de Serviços"

oBrowse:SetFilterDefault("!Empty(MFI_SITGAR) .AND. MFI_ORIGEM = 'SF' ")                            

oBrowse:AddLegend( "MFI_SITGAR=='02' .AND. !EMPTY(MFI_PEDIDO)", "GREEN" , STR0003) //"00=Fechamento Realizado"
oBrowse:AddLegend( "MFI_SITGAR=='01'", "YELLOW", STR0004) //"01=Env. Seguradora"
oBrowse:AddLegend( "MFI_SITGAR=='02'", "BLUE"  , STR0005) //"02=Ok Seguradora"
oBrowse:AddLegend( "MFI_SITGAR=='03'", "RED"   , STR0006) //"03=Erro Seguradora"
oBrowse:AddLegend( "MFI_SITGAR=='04'", "GRAY"  , STR0007) //"04=Pendente Seguradora"
oBrowse:AddLegend( "MFI_SITGAR=='05'", "ORANGE", STR0008) //"05=Env.Cancelamento"
oBrowse:AddLegend( "MFI_SITGAR=='06'", "WHITE" , STR0009) //"06=Ok Cancelamento"
oBrowse:AddLegend( "MFI_SITGAR=='07'", "BLACK" , STR0010) //"07=Erro Cancelamento"
oBrowse:AddLegend( "MFI_SITGAR=='08'", "BROWN" , STR0011) //"08=Pendente Cancelamento"

oBrowse:Activate()

Return NIL   

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0012 ACTION "LOJA870C('SF')"	OPERATION 2   ACCESS 0 //"Gera Arquivo Texto"
ADD OPTION aRotina TITLE STR0013 ACTION "LOJA870H('SF')"	OPERATION 3   ACCESS 0 //"Retorno Arquivo Texto"
ADD OPTION aRotina TITLE STR0014 ACTION "LOJA870I(MFI->MFI_NUMLOT,'SF')"     OPERATION 4   ACCESS 0 //"Ajuste"
ADD OPTION aRotina TITLE STR0015 ACTION "LOJA870E()"	 	OPERATION 4   ACCESS 0 //"Fech. Serviço Financeiro"
ADD OPTION aRotina TITLE STR0017 ACTION "LOJA870J(,,,1)"	 	OPERATION 4   ACCESS 0 //"Relatório Fechamento SF"
ADD OPTION aRotina TITLE STR0016 ACTION 'Lj871Leg' 	  		OPERATION 9 ACCESS 0  //"Legenda"

Return aRotina

//-------------------------------------------------------------------
/* Lj871Leg
Aciona legenda.
@author  Varejo
@since   10/06/2014
@version 1.0
*/
//------------------------------------------------------------------- 
Function Lj871Leg()

Local aLegenda := {{"BR_VERDE"		, STR0003},; //"00=Fechamento Realizado"
				  	{"BR_AMARELO"	, STR0004},; //"01=Env. Seguradora"
					{"BR_AZUL"		, STR0005},; //"02=Ok Seguradora"
					{"BR_VERMELHO"	, STR0006},; //"03=Erro Seguradora"
					{"BR_CINZA"		, STR0007},; //"04=Pendente Seguradora"
					{"BR_LARANJA"	, STR0008},; //"05=Env. Cancelamento"
					{"BR_BRANCO"	, STR0009},; //"06=Ok Cancelamento"
					{"BR_PRETO"		, STR0010},; //"07=Erro Cancelamento"
					{"BR_MARRON"	, STR0011}}  //"08=Pendente Cancelamento"					

BrwLegenda(STR0002, STR0016, aLegenda) //#"Monitor de Serviços" ##"Legenda"
     
Return Nil

