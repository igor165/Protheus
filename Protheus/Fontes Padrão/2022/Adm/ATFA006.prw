#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'atfa006.ch'

#DEFINE OPER_IMPORTAR 11
#DEFINE OPER_REVISAR  12
 
Static __nOper   := 0
Static __aIndImp := {}
Static __lRevisa := .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณATFA006   ณ Autor ณ Ramon Prado   			ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Atualizacao das taxas de อndices de Deprecia็ใo/Amort      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณSIGAFIN                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณATFA006                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                             ณฑฑ
ฑฑณ		                                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function ATFA006() 
Local oBrowse
Private nRecnoant 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FNT')
oBrowse:SetDescription(STR0019)////"Taxas de indices de cแlculo de deprecia็ใo e amortiza็ใo"
oBrowse:AddLegend( "FNT_STATUS == '1'" ,"GREEN", STR0023 )//ativo
oBrowse:AddLegend( "FNT_STATUS == '2'", "RED", STR0050 )//encerrado
oBrowse:AddLegend( "FNT_STATUS == '3'", "BROWN", STR0051 )//pendente
oBrowse:AddLegend( "FNT_STATUS == '4'", "ORANGE", STR0052 )//rejeitado
oBrowse:AddLegend( "FNT_STATUS == '7'", "BLUE", STR0024 )//bloqueado por revisao
oBrowse:AddLegend( "FNT_STATUS == '8'", "YELLOW", STR0091 )//Rejeitado-Revisใo
oBrowse:AddLegend( "FNT_STATUS == '9'", "BLACK", STR0026 )//bloqueado por usuario
oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Jandir Deodato   		ณ Data ณ 27/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ menu da tela de atualizacao de indices                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณSIGAFIN                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณATFA006                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ   									         			  ณฑฑ
ฑฑณ		       										                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0027  				Action 'PesqBrw'    			OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0028				Action 'VIEWDEF.ATFA006'		OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0029				Action 'VIEWDEF.ATFA006'		OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0032				Action 'VIEWDEF.ATFA006'		OPERATION 4 ACCESS 0 //Bloquear/Desbloquear
ADD OPTION aRotina Title STR0031				Action 'VIEWDEF.ATFA006'		OPERATION 5 ACCESS 0 //Excluir
ADD OPTION aRotina Title STR0033				Action 'ATF06REVIS'			OPERATION 7 ACCESS 0 //REVISAR
ADD OPTION aRotina Title STR0034  				Action 'ATFA006IMP'			OPERATION 3 ACCESS 0 //IMPORTAR
ADD OPTION aRotina Title STR0035				Action 'ATFA006EXP'			OPERATION 4 ACCESS 0 //EXPORTAR

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณModelDef  ณ Autor ณ Jandir Deodato   		ณ Data ณ 27/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณModelo de dados                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณSIGAFIN                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณATFA006                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ   									         			  ณฑฑ
ฑฑณ		       										                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ModelDef()

Local oModel
Local oStruFNT := FWFormStruct( 1, "FNT")

oStruFNT:SetProperty("FNT_DATA",MODEL_FIELD_INIT,"")
oStruFNT:SetProperty("*",         MODEL_FIELD_WHEN,{|oModel|oModel:GetOperation()== 3})
oStruFNT:SetProperty("FNT_MSBLQL",MODEL_FIELD_WHEN,{|oModel| (oModel:GetOperation()== 4 .and. __nOper != OPER_REVISAR) .or. __nOper == OPER_IMPORTAR } )
oStruFNT:SetProperty("FNT_REVIS", MODEL_FIELD_WHEN,{|oModel|(oModel:GetOperation()== 4 .and. __nOper == OPER_REVISAR ) .or. oModel:GetOperation()== 3})
oStruFNT:SetProperty("FNT_STATUS",MODEL_FIELD_WHEN,{||__nOper == OPER_IMPORTAR})

	oStruFNT:SetProperty("FNT_TAXA" ,MODEL_FIELD_WHEN ,{|| WhenCurva("FNT_TAXA")  })
	oStruFNT:SetProperty("FNT_CURVA",MODEL_FIELD_WHEN ,{|| WhenCurva("FNT_CURVA") })

oStruFNT:AddTrigger( "FNT_DATA" , "FNT_DTVLDF", {|| .T. }, {|oModel| AF06AtuDt(oModel) } )
oStruFNT:AddTrigger( "FNT_CODIND" , "FNT_TAXA", {|| .T. }, {|oModel| 0 } )
oStruFNT:AddTrigger( "FNT_CODIND" , "FNT_CURVA", {|| .T. }, {|oModel| 0 } )

oModel := MPFormModel():New('ATFA006',,{|oModel|ATF006valid(oModel)},{|oModel|AprovImp(oModel)}, /*bCancel*/)
oModel:SetVldActivate( { |oModel| ATFprvalid( oModel ) } )

oModel:AddFields( 'FNTMASTER', /* cOwner */, oStruFNT)
oModel:AddRules( 'FNTMASTER', 'FNT_DATA'  ,'FNTMASTER', 'FNT_CODIND', 3 )
oModel:AddRules( 'FNTMASTER', 'FNT_TAXA' ,'FNTMASTER', 'FNT_CODIND', 1 )
oModel:AddRules( 'FNTMASTER', 'FNT_CURVA','FNTMASTER', 'FNT_CODIND', 1 )

oModel:SetDescription(STR0019)
oModel:GetModel( 'FNTMASTER' ):SetDescription( STR0019 )

Return oModel
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o    ณ VIEWDEF  ณ Autor ณ Jandir Deodato        ณ Data ณ  27/09/12ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Objeto do modelo de dados                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ            
ฑฑณ Uso      ณ ATFA006                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ	     ณ      ณ                                          ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA006' )
Local oStruFNT := FWFormStruct( 2, 'FNT'/*,{|cCampo|AvaliaCampo(cCampo)}*/)
Local oView

oStruFNT:SetProperty("FNT_CODIND",MVC_VIEW_LOOKUP,"FNI")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_FNT",oStruFNT,"FNTMASTER")
oView:SetCloseOnOk({|oModel|iif(oModel:GetOperation() <> 3,.T.,.F.)}) 

Return oView
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ	ฑฑ
ฑฑณFun??็ใo  ณATF006X  ณ Autor ณ Ramon Prado            Data ณ 30/09/11 ณ	ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด	ฑฑ
ฑฑณDescri??o ณ Funcao para gravacao da taxa                               ณ	ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด	ฑฑ
ฑฑณSintaxe   ณATF006X(cAlias,nReg,nOpc,oModel)                            ณ	ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด	ฑฑ
ฑฑณRetorno   ณ.T. ou .F.                                                  ณ	ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด	ฑฑ
ฑฑณ Uso      ณ ATFA006                                                    ณ	ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด	ฑฑ
ฑฑณParametrosณ ExpC1 = Alias do arquivo --fora de uso                     ณ	ฑฑ
ฑฑณ          ณ ExpN1 = Numero do registro --fora de uso                   ณ	ฑฑ
ฑฑณ          ณ ExpN2 = Numero da opcao selecionada                        ณ	ฑฑ
ฑฑณ          ณ ExpN2 = Modelo de Dados                                    ณ	ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ	ฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ATFA006X(cAlias,nReg,nOpc,oModel)

Local aSaveArea		:= GetArea()
Local nOpcX			:= nOpc
Local lAprov		:= .F.
Local cCodSol		:= RetCodUsr()
Local cOrigem		:= FunName()
Local aAreaFNM		:= {}
Local aAreaFNT		:= {}
Local nRec			:= 0
Local cReV
Local oView 		:= FWViewActive()
Default cAlias:="FNT"
Default nReg:=(cAlias)->(Recno())
Do Case
	Case nOpcx == 3  //Inclusao  //importa็ใo CSV tamb้m ้ considerada uma inclusใo
		If __nOper == OPER_IMPORTAR //garantindo a validacao somente para a importacao CSV
			lAprov := ATFxCtrlAprov("ATFA006","08")			
			//Se o controle de aprova็ใo estiver habilitado 
			If lAprov 
				oModel:SetValue('FNTMASTER','FNT_STATUS',"3")            //Status "Pendente" jแ que a importa็ใo terแ de ser aprovada ou rejeitada
			EndIf
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณchama a funcao para verificar se o registro armazenado no aAutoCab  ณ
			//ณestao contidos na tabela "FNT" e, caso sim, faz a revisใo
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If __lRevisa
				RevisaTaxa(oModel, lAprov)
			Else
				cRev:=AF06UltRev(oModel:GetValue('FNTMASTER','FNT_CODIND'),oModel:GetValue('FNTMASTER','FNT_DATA'))
				If Val(cRev)==0
					cRev:=Soma1(cREv)
				Endif
				oModel:SetValue('FNTMASTER','FNT_REVIS',cRev)
			Endif
		Else
			ATF006Grava(oModel)
		EndIf
	Case nOpcx == 4 .and. __nOper != OPER_REVISAR //Bloqueio //controle de aprova็ใo opera็ใo "07"
		If oModel:GetValue('FNTMASTER','FNT_MSBLQL') != FNT->FNT_MSBLQL .And. MsgYesNo(STR0048)	//'Voc๊ deseja Confirmar a operacao?'	
			lAprov := ATFxCtrlAprov("ATFA006","07")
			dbSelectArea("FNT")
			aAreaFNT := FNT->(GetArea())
			FNT->(dbGoTo(nReg))
			//Se o controle de aprova็ใo estiver habilitado, a taxa ้ mantida desbloqueada e ้ gerado um movimento de aprova็ใo
			If lAprov
				oModel:SetValue("FNTMASTER","FNT_MSBLQL",IIF(oModel:GetValue("FNTMASTER","FNT_MSBLQL") == "1","2","1"))
				AF004GrvMov("ATFA006","07",dDataBase,cCodSol,,FNT->FNT_TAXA,cOrigem,"FNT",FNT->(Recno()))
			Else
				//Se o controle de aprova็ใo estiver desabilitado, altera o status da taxa para ativo ou bloqueado por usuแrio
				FwFormCommit(oModel)
				RecLock("FNT",.F.)
				FNT->FNT_STATUS	:= IIF(FNT->FNT_MSBLQL == "1","9","1")	//Ativo/Bloqueado por usuแrio
				FNT->(MsUnlock())	
			EndIf
			RestArea(aAreaFNT)
		Else
		   oModel:SetValue("FNTMASTER","FNT_MSBLQL",FNT->FNT_MSBLQL)				   
		EndIf
		oView:Refresh()
	Case nOpcx == 5 //Exclusao  //controle de aprova็ใo opera็ใo "05"
		nRec := FNT->(Recno())
		BEGIN TRANSACTION
			//Verifica se o controle de aprova็ใo estแ habilitado para a rotina/opera็ใo
			lAprov := ATFxCtrlAprov("ATFA006","05")
			//Se o controle de aprova็ใo estiver habilitado, os registros de movimento de aprova็ใo referentes a taxa serใo deletados
			If lAprov .And. (nRec > 0)
				dbSelectArea("FNM")
				aAreaFNM := FNM->(GetArea())			
				FNM->(dbSetOrder(6))		//FNM_FILIAL+FNM_TABORI+FNM_IDMOV
				If FNM->(MsSeek(xFilial("FNM")+"FNT"))												
					//Procura todos os registros de movimento de aprova็ใo referentes a taxa
					While FNM->(!EoF()) .And. (FNM->(FNM_FILIAL+FNM_TABORI) == xFilial("FNM")+"FNT")
						If FNM->FNM_RECORI == nRec
							//Apaga o movimento de aprova็ใo referente a taxa
							Reclock("FNM",.F.)
							dbDelete()
							FNM->(MsUnlock())
						EndIf
						FNM->(dbSkip())
					EndDo														
				EndIf
				RestArea(aAreaFNM)
			EndIf
		END TRANSACTION
	Case nOpcx == 4 .and. __nOper == OPER_REVISAR //Revisao    //controle de aprova็ใo opera็ใo "06"
		ATF006Grava(oModel)
EndCase

RestArea(aSaveArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o    ณATF006Validณ Autor ณ Ramon Prado		    	ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Validacao das taxas de indices                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ.T./.F.                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA006                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 = Modelo de dados   	                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF006Valid(oModel)

Local aSaveArea	:= GetArea()
Local lExistDta := .F.                    //DETERMINARA SE ESSA EXISTE TAXA VALIDA PARA DATA ESPECIFICADA
Local lRevPend := .F.
Local lRet:=.T.
Local dData:=oModel:GetValue("FNTMASTER","FNT_DATA")
Local cCod:=oModel:GetValue("FNTMASTER","FNT_CODIND")
Local nOpc:=oModel:GetOperation()
Local cPeriod:=''
Local cDesc :=''
Local nReg:=0

FNI->(MsSeek(xFilial("FNI")+cCOD))
cPeriod := FNI->FNI_PERIOD
cDesc   := FNI->FNI_DSCIND

If nOpc == 3 .Or. nOpc == 4 
	lRet := lRet .And. A006VLDDT(dData,cPeriod) // Verifica se a data ้ valida
	lRet := lRet .And. A006OBRIG(oModel)        // Verifica se a data ้ valida
EndIf

Do Case
	Case nOpc == 3 //incluir

		If lRet
			DbSelectArea("FNT")
			DbSetOrder(2)   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS
			DbGotop()
			If FNT->(MsSeek(xFilial("FNT")+Dtos(dData)+cCOD)) 
				If  !__lRevisa .and. __nOper == OPER_IMPORTAR//nao permite incluir uma importa็ใo que ja exista
					lExistDta := .T.
				EndIf
				If !lExistDta
					While (FNT->(!Eof()) .AND. FNT->FNT_DATA == dData .AND. FNT->FNT_CODIND == cCOD)
						If FNT->FNT_STATUS $ '1|'
							nReg:=FNT->(RECNO())
						Endif
						If __lRevisa
							If __nOper == OPER_IMPORTAR 
								IF !FNT->FNT_STATUS $ '1|2|4|8|' 
									lExistDta	:= .T.			//ACHOU DTA VALIDA PARA PERIODO     
									Exit
								Endif
							Else
								lExistDta	:= .T.			//ACHOU DTA VALIDA PARA PERIODO     
								Exit
							Endif
						Else
							If FNT->FNT_STATUS $ '1|3|7|9|'
								lExistDta	:= .T.			//ACHOU DTA VALIDA PARA PERIODO     
								Exit
							Endif
						Endif
						FNT->(dbSkip())
					Enddo				
				Endif
			Endif
			If !lExistDta                    
				If A006VldBlo(nReg) 
					lRevPend := .F.
					AF06UltRev(cCOD,dData,@lRevPend)	 
					If lRevPend //Existe revisใo pendente, portanto nใo pode criar mais uma revisใo     
						lRet := .F.
						Help( ,, 'ATF006VA02',, STR0053, 1, 0 )//'Nใo ้ possํvel criar nova revisใo para esta taxa, pois jแ existe uma revisใo pendente de aprova็ใo '
					EndIf
				Else
					lRet := .F.
					Help( ,, 'AF006VREV3',,STR0063 , 1, 0 ) //"Existe aprova็ใo pendente para este item."
				EndIf
			Else
				lRet:=.F.
				Help( ,, 'ATF006VA01',, STR0001, 1, 0 ) //"Ja existe taxa para o periodo"
			EndIf
   		EndIf
	Case nOpc ==4	 .and. __nOper == OPER_REVISAR	//FUNCIONALIDADE Revisar
		DbSelectArea("FNT")
		DbSetOrder(2)   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS
		If FNT->(MsSeek(xFilial("FNT")+Dtos(dData)+cCOD))
			While (FNT->(!Eof()) .AND. FNT->FNT_DATA == dData .AND. FNT->FNT_CODIND == cCOD)
				If FNT->FNT_STATUS == '1'       //VERIFICA SE STATUS DA TAXA == "ATIVA"
					lExistDta	:= .T.			//ACHOU DTA VALIDA PARA PERIODO
					nRecnoAnt := recno()
					exit
				Endif
				FNT->(dbSkip())
			Enddo
		Endif
		If !lExistDta
			lRet := .F.
			Help( ,, 'ATF006VA03',, STR0008, 1, 0 )//'Nao hแ taxa para o perํodo'
		Endif
EndCase

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o    ณATF006Gravaณ Autor ณ Ramon Prado          ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Grava, exclui ou revisa as cotacoes digitadas na GetDados  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T.                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA006                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpO1 = Modelo de dados                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ATF006Grava(oModel)

Local aSaveArea	:= GetArea()
Local lAprov		:= .F.
Local cCodSol		:= RetCodUsr()
Local cOrigem		:= FunName()
Local nRecFNT		:= 0
Local dData:=oModel:GetValue("FNTMASTER","FNT_DATA")
Local nOpc :=oModel:GetOperation()
Local cTaxa
Local cTipo
Local	dDat
Local	cCodind
Local	cRevis
Local	cStatus
Local	cMsBlQl
Local	dDtVal
Local cUltRevis := ''
Local cCurva
Local lCurva :=.F. 
Local lContinua :=.F.
Local aAreaFNI:=FNI->(GetArea())
Local aAreaFNT:=FNT->(GetArea())
FNI->(dbSetOrder(1))
FNT->(DbSetOrder(2))   //indice: FNT_FILIAL + FNT_DATA  + FNT_CODIND + FNT_REVIS
Do Case
	Case nOpc == 3			//INCLUIR
		If FNT->(MsSeek(xFilial("FNT") + Dtos(dData) + oModel:GetValue("FNTMASTER","FNT_CODIND") + oModel:GetValue("FNTMASTER","FNT_REVIS")))
			If FNT->FNT_STATUS != "1" //STATUS BLOQUEADO POR REVISAO
				cUltRevis := AF06UltRev(FNT->FNT_CODIND,FNT->FNT_DATA)
				oModel:SetValue("FNTMASTER","FNT_REVIS",Soma1(cUltRevis))
			Endif
		Endif
	Case nOpc == 4 .and. __nOper == OPER_REVISAR	//REVISAR IGUAL A UMA INCLUSAO(NOVA TAXA) COM INCREMENTO NO CAMPO FNT->FNT_REVIS E UMA ALTERACAO NO STATUS DA TAXA("ANTIGA TAXA") PARA STATUS "BLOQUEDO POR REVIS".
		//Verifica se o controle de aprova็ใo estแ habilitado para a rotina/opera็ใo
		lAprov := ATFxCtrlAprov("ATFA006","06")
		cTaxa:=oModel:GetValue('FNTMASTER','FNT_TAXA')
		If lCurva:=AF06IsCalc(FNT->FNT_CODIND)
			cCurva:= oModel:GetValue('FNTMASTER','FNT_CURVA')
		Endif
		IF lCurva
			If cCurva <> FNT->FNT_CURVA
				lContinua:=.T.
			Endif
		Else
			If cTaxa <> FNT->FNT_TAXA
				lContinua:=.T.
			Endif
		Endif
		IF lContinua
			FNT->(dbGoTo(nRecnoAnt))
			If lCurva
				oModel:SetValue('FNTMASTER','FNT_CURVA',FNT->FNT_CURVA)
			Endif
			oModel:SetValue('FNTMASTER','FNT_TAXA',FNT->FNT_TAXA)
			dDat:= FNT->FNT_DATA
			cCodind:= FNT->FNT_CODIND
			cRevis:=Soma1(AF06UltRev(FNT->FNT_CODIND,FNT->FNT_DATA))
			cStatus:=IIF(lAprov, "7",FNT->FNT_STATUS)
			cMsBlQl:= FNT->FNT_MSBLQL
			dDtVal:=FNT->FNT_DTVLDF
			cTipo:=FNT->FNT_TIPO
			FwFormCommit(oModel)
			dbSelectArea("FNT")
			RecLock("FNT",.T.)
			FNT->FNT_FILIAL	:= xFilial("FNT")
			FNT->FNT_DATA	:= dDat
			FNT->FNT_CODIND	:= cCodInd
			FNT->FNT_REVIS	:= cRevis
			FNT->FNT_TAXA	:= cTaxa
			FNT->FNT_TIPO   := cTipo
			If lCurva
				FNT->FNT_CURVA:=cCurva
			Endif
			FNT->FNT_STATUS	:= cStatus
			FNT->FNT_MSBLQL := cMSBlQl
			FNT->FNT_DTVLDF := dDtVal
			FNT->(MsUnlock())
			//Se o controle de aprova็ใo estiver habilitado, gera o movimento de aprova็ใo
			If lAprov
				AF004GrvMov("ATFA006","06",dData,cCodSol,,FNT->FNT_TAXA,cOrigem,"FNT",FNT->(Recno()))
			EndIf
			//Se o controle de aprova็ใo estiver desabilitado, altera o status da taxa anterior para encerrado
			If !lAprov
				FNT->(dbGoto(nRecnoAnt))
				RecLock("FNT",.F.)     		//Alteracao do Status da Taxa
				FNT->FNT_STATUS	:= "2"  	//Encerrado
				FNT->(MsUnlock())
			EndIf
		Endif
EndCase

nRecFNT := FNT->(Recno())
RestArea(aAreaFNI)
RestArea(aAreaFNT)
RestArea(aSaveArea)

FNT->(DbGoTo(nRecFNT))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณSemelhante ao FINA018Imp ณ Autor ณ Ramon Pradoณ Data ณ19/10/11  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณImporta indices de Ativo Fixo de arquivo CSV                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณATFA006Imp()                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nenhum                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATF	                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA006Imp()

Local aRet      := {}									// Conteudo de retorno da ParamBox
Local aPerg     := {}									// Array de parametros a serem passados para a ParamBox
Local cDescPar  := STR0036							   // Descricao do parametro (###"Arquivo para importa็ใo")
Local cDescPar2 := STR0018							   //"Gerar rev. para taxa existente?"
Local cIniPar   := PadR("",150) 						// Conteudo inicial do parametro
Local cPictPar  := ""									// Mascara de edicao do parametro
Local cValidPar := ""									// Validacao posterior do parametro
Local cWhenPar  := ""									// Validacao anterior do parametro
Local nTamPar   := 90									// Tamanho da MsGet do parametro
Local lObrigat  := .t.								    // Determina se o parametro e obrigatorio
Local cTipArq   := STR0037							   // Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
Local cDirIni   := ""								 	// Diretorio inicial do cGetFile
Local cParGetF  := ""								 	// Parametros da cGetFile
Local cTitulo   := STR0034+" - " + STR0059	// Titulo da tela de parametros(### "Importar  - CSV")
Local aOpc		  := {}
Local aArea	  := GetArea()
Local nCoFNTAnt := FNT->(RECCOUNT())
Local nCoFNTPos := 0
Local nX        := 0
Private cCadastro:=STR0019

aOpc	:= {STR0020,STR0021}	//{"Sim,Desejo","Nใo"}

__nOper   := OPER_IMPORTAR
__aIndImp := {}  

cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray a ser passado para ParamBox quando tipo(6) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})
aAdd( aPerg,{2,cDescPar2,STR0021,aOpc,60,cValidPar,.T.})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso confirme a tela de parametros proce,ssa a rotina de exportacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If ParamBox(aPerg,cTitulo,@aRet)
	aRetP1 := AjRetParam(aRet,aPerg)	
	MsgRun( STR0068 ,, { || ImportTx( aRetP1[1] ,aRetP1[2] == 1 ) } )//"Aguarde Processamento"
EndIf

nCoFNTPos := FNT->(RECCOUNT())

If nCoFNTPos == 0 .OR. nCoFNTPos == nCoFNTAnt
	Aviso(STR0054,STR0055,{STR0056}) // "Importa็ใo" // "Nenhuma taxa de deprecia็ใo/amortiza็ใo foi importada."// "Confirmar"
Else
	For nX := 1 to Len(__aIndImp)
		A06ProcInd(__aIndImp[nX] )
	Next nX 
EndIf

__nOper   := 0
__aIndImp := {} 

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณATFA006Exp ณ Autor ณ Ramon Neves				   ณ Data ณ30/09/11  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณExporta indices financeiros para arquivo CSV                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณATFA006Exp()                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAATF                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA006Exp()

Local aRet      := {}				// Conteudo de retorno da ParamBox
Local lRet      := .t.				// Conteudo de retorno da funcao
Local aPerg     := {}				// Array de parametros a serem passados para a ParamBox
Local cDescPar  := STR0058			// Descricao do parametro (###"Nome do arquivo exporta็ใo")
Local cIniPar   := PadR("",150) 	// Conteudo inicial do parametro
Local cPictPar  := ""				// Mascara de edicao do parametro
Local cValidPar := ""				// Validacao posterio do parametro
Local cWhenPar  := ""				// Validacao anterior do parametro
Local nTamPar   := 90				// Tamanho da MsGet do parametro
Local lObrigat  := .t.				// Determina se o parametro e obrigatorio
Local cTipArq   := STR0037		 	// Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
Local cDirIni   := ""			 	// Diretorio inicial do cGetFile
Local cParGetF  := ""			 	// Parametros da cGetFile
Local cTitulo   := STR0035+" - " + STR0059 	// Titulo da tela de parametros(###"Exportar  - CSV")
Private cCadastro:= STR0019

SaveInter()

cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray a ser passado para ParamBox quando tipo(6) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso confirme a tela de parametros processa a rotina de exportacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ParamBox(aPerg,cTitulo,@aRet)
	
	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"FNT",1} } )} )
	oProcess:Activate()
	
EndIf

RestInter()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณA006VldBlo ณ Autor ณ Ramon Neves				   ณ Data ณ30/09/11  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบDesc.     ณUSADA PARA VERIFICAR SE HOUVE ALTERACAO NO COMBO DO CAMPO  -
ฑฑ  FNT_MSBLQL DE "SIM" PARA "NรO" OU VICE-VERSA'''''''''''''''''         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณA006VldBlo()                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAATF                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A006VldBlo(nreg)
Local aSaveArea	:= GetArea()
Local lRet			:= .T.
Local cAliasQry 	:= ''
Default nReg		:= FNT->(RECNO())

//Pesquisa se jแ existe uma aprova็ใo de bloqueio/desbloqueio pendente						
cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry
SELECT FNM_RECORI
FROM %table:FNM% FNM
WHERE 	FNM.FNM_FILIAL = %xfilial:FNM% AND
		FNM.FNM_TABORI = 'FNT' AND 
		FNM.FNM_RECORI = %Exp:nReg% AND
		FNM.FNM_OPER   = '07' AND
		FNM.FNM_STATUS = '1' AND	
		FNM.%notDel%
EndSql

If (cAliasQry)->(!Eof())
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF06UltRevบAutor  ณRamon Neves         บ Data ณ  12/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a ultima revisao do indice para a data             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF06UltRev(cCodInd,dDtInd,lRevPend)
Local cUltRev := ""
Local aArea   := GetArea()
Local aAreaFNT
dbSelectArea("FNT")

aAReaFNT:=FNT->(GetAREA())
FNT->(dbSetOrder(2))//FNT_FILIAL+DTOS(FNT_DATA)+FNT_CODIND+FNT_REVIS

If FNT->(MsSeek( xFilial("FNT") + DtoS(dDtInd) + cCodInd  ))
	While FNT->(!EOF()) .And. FNT->(FNT_FILIAL+DTOS(FNT_DATA)+FNT_CODIND) == xFilial("FNT") + DtoS(dDtInd) + cCodInd
		lRevPend := FNT_STATUS $ '3|7'
		cUltRev := FNT->FNT_REVIS
		FNT->(dbSKip())
	EndDo
Else
	cUltRev :=  REPLICATE("0", TAMSX3("FNT_REVIS")[1]  )
EndIf

RestARea(aAReaFNT)
RestArea(aArea)

Return cUltRev

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF006Aprv   บAutor  ณRenan Guedes      บ Data ณ  12/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera o status das taxas envolvidas no movimento de        บฑฑ
ฑฑบ          ณaprova็ใo                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณlStatus	= Movimento aprovado (.T.) ou rejeitado (.F.)     บฑฑ
ฑฑบ          ณnRec		= Recno do registro do movimento de aprova็ใo     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF006Aprv(nStatus,nRec)

Local aArea			:= GetArea()
Local aAreaFNT		:= {}
Local cCodInd		:= ""
Local dData			:= ""
Default nStatus		:= 0
Default nRec		:= 0
If (nStatus > 0) .And. (nRec > 0)
	dbSelectArea("FNT")
	aAreaFNT := FNT->(GetArea())
	Do Case
		Case nStatus == 1		//Se for aprova็ใo da revisใo da taxa
			FNT->(dbGoTo(nRec))
			cCodInd	:= FNT->FNT_CODIND
			dData	:= FNT->FNT_DATA
			FNT->(dbSetOrder(3))		//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS
			If FNT->(MsSeek(xFilial("FNT")+cCodInd+DTOS(dData)))
				//Procura a taxa ativa para a data
				While FNT->(!EoF()) .And. (FNT->FNT_FILIAL == xFilial("FNT")) .And. (FNT->FNT_CODIND == cCodInd) .And. (FNT->FNT_DATA == dData)
					//Verifica se a taxa estแ ativa e desbloqueada
					If (FNT->FNT_STATUS == "1") .And. (FNT->FNT_MSBLQL == "2")				
						//Altera a taxa antiga para encerrada
						RecLock("FNT",.F.)
						FNT->FNT_STATUS := "2"		//Encerrado
						FNT->(MsUnlock())
						//Posiciona novamente na taxa do movimento de aprova็ใo para tornแ-la ativa
						FNT->(dbGoTo(nRec))
						RecLock("FNT",.F.)
						FNT->FNT_STATUS := "1"		//Ativo
						FNT->(MsUnlock())
						Exit
					EndIf
					FNT->(dbSkip())
				EndDo
				/* refaz os valores das taxas */
				A06ProcInd(cCodInd)
			EndIf		
   		Case nStatus == 2		//Se for rejei็ใo da revisใo da taxa 
			//Se o movimento de aprova็ใo foi rejeitado, altera o status da taxa para bloqueado por aprova็ใo
			FNT->(dbGoTo(nRec))
			RecLock("FNT",.F.)
		 	FNT->FNT_STATUS	:= "8"		//Bloqueado por aprova็ใo
			FNT->(MsUnlock())
   		Case nStatus == 3		//Se for aprova็ใo do bloqueio/desbloqueio da taxa
   			FNT->(dbGoTo(nRec))
			RecLock("FNT",.F.)
			FNT->FNT_MSBLQL	:= IIF(FNT->FNT_MSBLQL == "1","2","1")
			FNT->FNT_STATUS	:= IIF(FNT->FNT_MSBLQL == "1","9","1")
			FNT->(MsUnlock())
			A06ProcInd(FNT->FNT_CODIND)//reprocessando a curva
		Case nStatus == 4		//Se for aprova็ใo da importa็ใo da taxa//considerando possivel importa็ใo com revisใo
			FNT->(dbGoTo(nRec))
			cCodInd	:= FNT->FNT_CODIND
			dData	:= FNT->FNT_DATA
			FNT->(dbSetOrder(3))		//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS
			If FNT->(MsSeek(xFilial("FNT")+cCodInd+DTOS(dData)))   //considera importa็ใo com revisใo da taxa
				//Procura a taxa ativa para a data
				While FNT->(!EoF()) .And. (FNT->FNT_FILIAL == xFilial("FNT")) .And. (FNT->FNT_CODIND == cCodInd) .And. (FNT->FNT_DATA == dData)
					//Verifica se a taxa estแ ativa, efetiva e desbloqueada
					If (FNT->FNT_STATUS == "1") .And. (FNT->FNT_MSBLQL == "2")						
						//Altera a taxa antiga para encerrada
						RecLock("FNT",.F.)
						FNT->FNT_STATUS := "2"		//Encerrado
						FNT->(MsUnlock())
						Exit
					EndIf
					FNT->(dbSkip())
				EndDo
			EndIf
			//Posiciona novamente na taxa do movimento de aprova็ใo para tornแ-la ativa
			FNT->(dbGoTo(nRec))			
			RecLock("FNT",.F.)
			FNT->FNT_STATUS := "1"  //Status "Ativo"  //a taxa foi aprovada
			FNT->(MsUnlock())
			/* refaz os valores das taxas */
			A06ProcInd(cCodInd)	
		Case nStatus == 5		//Se for rejei็ใo da importa็ใo da taxa
			FNT->(dbGoTo(nRec))
			RecLock("FNT",.F.)
			FNT->FNT_STATUS := "4" //Rejei็ใo-Imp.
			FNT->(MsUnlock())				
    EndCase
	RestArea(aAreaFNT)

EndIf

RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRamon Neves Lacerda Prado บDataณ07/10/11บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ	Utilizado para importar registros que sใo iguais          บฑฑ
ฑฑบ			   ณ	ao(s) jแ presente(s) na tabela "FNT"  -- 			      บฑฑ
ฑฑบ          ณ  sใo importado(s) como uma nova revisใo                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RevisaTaxa(oModel, lAprov)
Local aArea 	:= GetArea()
Local cFil
Local cCodInd
Local cRevis
Local dData
Default lAprov := .F.
cFil		:= xFilial("FNT")
cCodInd	:= oModel:GetValue('FNTMASTER','FNT_CODIND')	// pega o c๓digo do indice
dData		:= oModel:GetValue('FNTMASTER','FNT_DATA')	// pega a data
cRevis 		:= AF06UltRev(cCodInd,dData)	
			
dbSelectArea("FNT")
FNT->(dbSetOrder(2)) //FNT_FILIAL+DTOS(FNT_DATA)+FNT_CODIND+FNT_REVIS
FNT->(dbGotop())
If !Empty(cRevis)	
	If FNT->(MsSeek(cFil+DTOS(dData)+cCodInd+cRevis))
		oModel:SetValue('FNTMASTER','FNT_REVIS',Soma1(cRevis)) //incrementa 1 no campo revisใo//vai gerar nova taxa			
		If !lAprov
			FNT->(MsSeek(cFil+DTOS(dData)+cCodInd+cRevis))
			RecLock("FNT",.F.)
			FNT->FNT_STATUS := '2' // cancela a taxa antiga		
			FNT->(MSUNLOCK())
		Endif
	EndIf			
EndIf			

RestArea(aArea)

Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA006VLDDT  ณ Autor ณ Rodrigo Gimenes		ณ Data ณ 02/05/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica se a data ้ vแlida para o perํodo selecionado     |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ.T./.F.                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA006                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 = data				                          ณฑฑ
ฑฑณ          ณ ExpD1 = tipo de taxa       		           	                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Function A006VLDDT(dData,cTipoTx) 
Local lRetorno	:= .F.
Local cDia		:= ""      
Local nMes		:= 0

cDia := Substr(Dtos(dData),7,2)
nMes := Month(dData)
	Do Case
	   	Case cTipoTx == "1" //Diแria 
	   		lRetorno := .T.
		Case cTipoTx == "2" // Mensal
			If cDia == "01"
				lRetorno = .T.
			Else  
				Help( ,, 'A006VLDD01',, STR0002, 1, 0 ) //'A taxa deve ser cadastrada para o primeiro dia do m๊s'                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lRetorno = .F.
			EndIf            
		Case cTipoTx == "3" // Trimestral  
			lRetorno := CVALTOCHAR(nMes)  $ "01|04|07|10"
	 		lRetorno := lRetorno .And. cDia == "01"
			If lRetorno == .F.
				Help( ,, 'A006VLDD02',, STR0003, 1, 0 )                                                                                                                                                                                                                                                                                                                                                                                            
			EndIf
		Case cTipoTx == "4" // Semestral        
			lRetorno := CVALTOCHAR(nMes)  $ "01|07"
			lRetorno := lRetorno .And. cDia == "01"
			If lRetorno == .F.  
		   		Help( ,, 'A006VLDD03',, STR0004, 1, 0 ) 
				lRetorno := .F.
			EndIf
		Case cTipoTx == "5" // Anual
			If nMes == 1 .And. cDia == "01"
				lRetorno := .T.
			Else
				Help( ,, 'A006VLDD04',, STR0007, 1, 0 )                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lRetorno := .F.
			EndIf
	EndCase
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjRetParamบAutor  ณAlvaro Camillo Neto บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta as repostas do aParambox                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF06REVISบAutor  ณ                    บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama a view de revisใo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATF06REVIS()
Local lRet :=.T.

__nOper := OPER_REVISAR

If FNT->FNT_STATUS <> '1'
	Help( ,, 'ATF06REV01',, STR0011, 1, 0 )  //'Status da taxa tem de ser ativa
	lRet := .F.
Else
	FWExecView (STR0033, 'ATFA006', 4,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
Endif

__nOper := 0

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAprovImpบAutor  ณ บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณgrava o modelo e verifica se deve enviar aprovacao para                             บฑฑ
ฑฑบ          ณ importacao CSV                                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AprovImp(oModel)
Local lAprov :=.F.
Local cCodSol		:= RetCodUsr()
Local cOrigem		:= FunName()

ATFA006X(,,oModel:GetOperation(),oModel)
FwFormCommit(oModel)
lAprov := ATFxCtrlAprov("ATFA006","08")			

If lAprov
	AF004GrvMov("ATFA006","08",dDataBase,cCodSol,,FNT->FNT_TAXA,cOrigem,"FNT",FNT->(Recno()),__nOper == OPER_IMPORTAR)
Else
	If __nOper != OPER_IMPORTAR
		A06ProcInd(FNT->FNT_CODIND)
	Else
		If aScan( __aIndImp , {|x| Alltrim(x) == Alltrim(FNT->FNT_CODIND) } ) <= 0
			aAdd(__aIndImp, Alltrim(FNT->FNT_CODIND) )
		EndIf
	EndIf
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWhenCurvaบAutor  ณ บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o campo curva sera habilitado ou nao         บฑฑ
ฑฑบ          ณ                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function WhenCurva(cCampo)
Local aArea    := GetArea()
Local cCodInd  := ""
Local lRet     := .T.
Local oModel   := FWModelActive()
Local oModelFNI:= oModel:GetModel('FNTMASTER')
Local nOper    := oModel:GetOperation()

cCodInd := oModelFNI:GetValue('FNT_CODIND')

If __nOper != OPER_IMPORTAR
	If nOper == MODEL_OPERATION_INSERT .Or. ( __nOper == OPER_REVISAR .And. nOper == MODEL_OPERATION_UPDATE )  
		If AF06IsCalc(cCodInd)
			If cCampo == "FNT_TAXA"
				lRet :=.F.
			Else
				lRet:=.T.
			Endif
		Else
			If cCampo == "FNT_TAXA"
				lRet:=.T.
			Else
				lRet:=.F.
			Endif
		Endif
	ElseIf nOper == MODEL_OPERATION_UPDATE .and. __nOper != OPER_REVISAR//bloqueio
		lRet:=.F.
	EndIf
EndIf

RestArea(aArea)

Return  lREt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF06IsCalcบAutor  ณJandir Deodato      บ Data ณ  11/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se o ํndice utiliza o tipo 2 (Calculado)           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF06IsCalc (cCodInd)
Local aArea:=GetArea()
Local aAreaFNI
Local lRet:=.F.

DbSelectArea('FNI')
aAreaFNI:=FNI->(GetArea())
FNI->(dbSetOrder(1))

If FNI->(DbSeek(xFilial('FNI')+cCodInd)) .and. FNI->FNI_TIPO == '2'
	lRet:= .T.
Endif

RestArea(aAreaFNI)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF06AtuDtบAutor  ณJandir Deodato      บ Data ณ  11/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho da data de validade da taxa                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF06AtuDt(oModel)
Local cYear
Local cPeriod
Local dDataVal:=CriaVar('FNT_DTVLDF',.T.)
Local nTrim
Local cMesCalc
Local aArea:=GetArea()
Local aAreaFNI
Local dData:=oModel:GetValue("FNT_DATA")
Local cCod:=oModel:GetValue("FNT_CODIND")
dbSelectArea('FNI')
aAreaFNI:=FNI->(GetArea())
FNI->(DbSetOrder(1))
If !Empty(dData)
	IF FNI->(dbseek(xFilial("FNI")+cCOD))
		cYear	:= AllTrim(Str(Year(dData)))					
		cPeriod := FNI->FNI_PERIOD
		If cPeriod == "1"//diario
			dDataVal := dData
		ElseIf cPeriod == "2"//mensal
			dDataVal := LastDay(dData)
		ElseIf cPeriod == "3" //trimestral
			If Month(dData) <= 3
				nTrim := 1
			ElseIF Month(dData)<= 9
				If (Month(dData) % 3)==0
					nTrim := NoRound((Month(dData) / 3),0) 
				Else
					nTrim := NoRound((Month(dData) / 3),0) + 1
				Endif
			Else
				nTrim :=4
			Endif
			cMesCalc := STRZERO((nTrim * 3),2)
			dDataVal	:= LastDay(CTOD("01/"+ cMesCalc+  '/'+cYear)) 
		ElseIf cPeriod == "4"//semestral
			If Month(dData) <= 6
				nTrim := 1
			Else
				nTrim := 2
			EndIf
			cMesCalc := STRZERO((nTrim * 6),2)
			dDataVal	:= LastDay(CTOD("01/"+ cMesCalc+  '/'+cYear)) 
		Else//anual tipo 5
			dDataVal	:= CTOD("31/12/"+cYear)	 
		EndIf
	Endif
Endif

RestArea(aAreaFNI)
RestARea(aArea)

Return dDataVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFprvalidบAutor  ณJandir Deodato      บ Data ณ09/11/12     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPre validacao das rotinas                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFprvalid(oModel)
Local lRet:=.T.
Local nOpc:=oModel:GetOperation()
Local cSqlFNT:=''
Local cAlsFNT 
Local aArea:=GetArea()
Local lRevis:=.F.
Do Case
	Case nOpc == 4 .and. __nOper != OPER_REVISAR // bloqueio
		If !(FNT->FNT_STATUS $ "1|9")
			//Help( ,, 'ATFA006X03',, STR0041, 1, 0 )//'Taxa nใo pode ser Alterada - manuten็ใo de hist๓rico'
			Help( ,, 'ATFA006X03',, STR0070, 1, 0 )  //"Op็ใo disponํvel apenas para taxas ativas ou bloqueadas."      
			lRet:=.F.
		Endif
		If lRet
			AF06UltRev(FNT->FNT_CODIND,FNT->FNT_DATA,@lRevis)
			If !(A006VldBlo()) .or.  lRevis
				Help( ,, 'AF006VREV2',,STR0063 , 1, 0 ) //"Existe aprova็ใo pendente para este item."
				lRet:=.F.
			Endif
		Endif
	Case nOpc ==4	 .and. __nOper == OPER_REVISAR//revisar
		AF06UltRev(FNT->FNT_CODIND,FNT->FNT_DATA,@lRevis)
		If !(A006VldBlo())
			lRet := .F.
			Help( ,, 'AF006VREV3',,STR0063 , 1, 0 ) //"Existe aprova็ใo pendente para este item."
		ElseIf lRevis
			lRet:=.F.
			Help( ,, 'ATF006VA02',, STR0053, 1, 0 )//'Nใo ้ possํvel criar nova revisใo para esta taxa, pois jแ existe uma revisใo pendente de aprova็ใo '
		Endif
	Case nOpc == 5 //Exclusao  //controle de aprova็ใo opera็ใo "05"
			If (FNT->FNT_STATUS $ "2|3|4|7|8|9|")           //Status respectivamente: "Ativo", "Pendente", "Rejeitado", "Bloqueado por Revisใo", "Bloqueado por Aprova็ใo", "Bloqueado por Usuแrio"
				lRet:=.F.
				Help( ,, 'ATFA006X04',, STR0040, 1, 0 )//'Taxa nใo pode ser Excluํda - manuten็ใo de hist๓rico'					
			Endif
			If lRet
				cSqlFNT	:= "	SELECT	"
				cSqlFNT	+= "		COUNT(SN3.N3_CODIND) N3_COUNT "
				cSqlFNT	+= "	FROM " + RetSqlTab("SN3") + " "
				cSqlFNT	+= "	WHERE	"
				cSqlFNT	+= "		SN3.D_E_L_E_T_ != '*' "
				cSqlFNT	+= "		AND SN3.N3_CODIND	= '" + FNT->FNT_CODIND + "'"
				//Executa a query
				cAlsFNT := GetNextAlias()
				cSqlFNT := ChangeQuery(cSqlFNT )
				dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSqlFNT) , cAlsFNT , .T. , .F.)
				(cAlsFNT)->(dbGoTop())
				If !((cAlsFNT)->N3_COUNT == 0)							//verifica se data do ultimo calculo de depreciacao menor que data da taxa e
					lRet:=.F.
					Help( ,, 'ATFA006X05',, STR0012, 1, 0 )//'A taxa nใo pode ser excluํda, pois o ํndice de deprecia็ใo / amortiza็ใo estแ vinculado a ficha de ativo.'
				Endif
				(cAlsFNT)->(dbCloseArea())
				If lRet
					AF06UltRev(FNT->FNT_CODIND,FNT->FNT_DATA,@lRevis)
					IF lRevis .or. !(A006VldBlo())
						lRet := .F.
						Help( ,, 'AF006VREV3',,STR0063 , 1, 0 ) //"Existe aprova็ใo pendente para este item."
					Endif
				Endif
			Endif
EndCase

RestArea(aARea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA06ProcIndบAutor  ณAlvaro Camillo Neto บ Data ณ  11/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que reprocessa os indices de deprecia็ใo da curva   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A06ProcInd(cIndice)
Local aArea := GetArea()

MsgRun( STR0068 ,, { || ProcInDep(cIndice) } )//"Aguarde Processamento"

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA06ProcIndบAutor  ณAlvaro Camillo Neto บ Data ณ  11/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que reprocessa os indices de deprecia็ใo da curva   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA006                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcInDep(cIndice)

Local aArea    := GetArea()
Local nTaxa    := 0
Local cQuery   := ""
Local cTab     := GetNextAlias()
Local cRevAtual:= ""
Local nTaxaTot := 0
Local nDecimais := TamSX3("FNT_TAXA")[2]

FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS
FNT->(dbSetOrder(3)) //FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

cRevAtual := AFXIndRev(cIndice)

If FNI->(MsSeek(xFilial("FNI") + cIndice + cRevAtual )) .And. FNI->FNI_TIPO == '2'
	// Atualiza apenas as curvas vแlidas
	cQuery   += " SELECT R_E_C_N_O_ RECFNT"
	cQuery   += " FROM " + RetSQLTab("FNT")
	cQuery   += " WHERE "
	cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
	cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
	cQuery   += " FNT_MSBLQL = '2' AND "
	cQuery   += " FNT_STATUS = '1'  AND  "
	cQuery   += " D_E_L_E_T_ = ' ' "
	cQuery   := ChangeQuery(cQuery)
	If Select(cTab) > 0
		(cTab)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)
	
	While (cTab)->(!EOF())
		FNT->(dbGoTo((cTab)->RECFNT) )
		
		//Retorna a revisใo do codigo de indice para a data da taxa
		cRev := AFXIndRev(cIndice,FNT->FNT_DATA )
		
		FNI->(MsSeek(xFilial("FNI") + cIndice + cRev ))
		
		If cRev <= "0001"
			nTaxa := AFCurvOrig(cIndice,FNT->FNT_DATA,FNI->FNI_CURVIN,FNI->FNI_CURVFI)
		Else
			nTaxa := AFCurvRev(cIndice,FNT->FNT_DATA,FNI->FNI_CURVIN,FNI->FNI_CURVFI)
		EndIf
		
		RecLock("FNT", .F.)
		FNT->FNT_TAXA := Round(NoRound(nTaxa,nDecimais+1),nDecimais)
		MsUnlock()
		
		
		nRecno := (cTab)->RECFNT
		
		(cTab)->(dbSkip())
		
		If (cTab)->(!EOF())
			nTaxaTot += FNT->FNT_TAXA
		Else
			nTaxa := 1 - nTaxaTot
			FNT->(dbGoTo(nRecno) )
			RecLock("FNT", .F.)
			FNT->FNT_TAXA := nTaxa
			MsUnlock()
		EndIf
		
	EndDo
	
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ AFCurvOrig		บAutor  ณAlvaro Camillo Neto   ณ  10/10/12บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Indice de deprecia็ใo calculado na primeira revisใo da curvaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFCurvOrig(cIndice,dDataCalc, dInicio, dFinal)

Local aArea    := GetArea()
Local aAreaFNI := FNI->(GetArea())
Local cQuery   := ""
Local cTab     := "TRBAF06ORI"
Local nCurvaTot:= 0
Local aAreaFNT := FNT->(GetArea())
Local nTaxa    := 0

dDataCalc := FirstDay(dDataCalc)
dInicio   := FirstDay(dInicio)
dFinal    := LastDay(dFinal)

FNT->(dbSetOrder(3))//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

// Somat๓rio total da curva de trafego
cQuery   :=  " SELECT "
cQuery   += " SUM(FNT_CURVA) TOTCURVA"
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA >= '"+DTOS(dInicio)+"'  AND "
cQuery   += " FNT_DATA <= '"+DTOS(dFinal)+"'   AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)

If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->TOTCURVA > 0
	nCurvaTot:= (cTab)->TOTCURVA
Endif

// Curva de trafego do perํodo atual
cQuery   := " SELECT "
cQuery   += " FNT_CURVA "
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA = '"+DTOS(dDataCalc)+"'  AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)

If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->(!EOF())
	nTaxa := (cTab)->FNT_CURVA/nCurvaTot
EndIf

RestArea(aAreaFNT)
RestArea(aAreaFNI)
RestArea(aArea)
(cTab)->(dbCloseArea())

Return nTaxa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ AFCurvRev  		บAutor  ณAlvaro Camillo Neto   ณ  10/10/12บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Indice de deprecia็ใo calculado na segunda revisใo em diante
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFCurvRev(cIndice,dDataCalc, dInicio, dFinal)

Local aArea    := GetArea()
Local aAreaFNI := FNI->(GetArea())
Local cQuery   := ""
Local cTab     := "TRBAF06OREV"
Local nTotCurva:= 0
Local nIndTotal:= 0
Local aAreaFNT := FNT->(GetArea())
Local nTaxa    := 0

dDataCalc := FirstDay(dDataCalc)
dInicio   := FirstDay(dInicio)
dFinal    := LastDay(dFinal)

FNT->(dbSetOrder(3))//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

// Passo 1: Soma de indices do inicio da curva at้ o perํodo anterior da data atual
cQuery   :=  " SELECT "
cQuery   += " SUM(FNT_TAXA) TOTTAXA"
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA >= '"+DTOS(dInicio)+"'  AND "
cQuery   += " FNT_DATA <= '"+DTOS(dDataCalc-1)+"'   AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)

If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->TOTTAXA > 0
	nIndTotal := 1 - (cTab)->TOTTAXA
Endif

// Passo 2: Soma de curva da data atual at้ o final da curva
cQuery   :=  " SELECT "
cQuery   += " SUM(FNT_CURVA) TOTCURVA"
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA >= '"+DTOS(dDataCalc)+"'  AND "
cQuery   += " FNT_DATA <= '"+DTOS(dFinal)+"'   AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)

If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->TOTCURVA > 0
	nTotCurva := (cTab)->TOTCURVA
Endif

// Curva de trafego do perํodo atual
cQuery   :=  " SELECT "
cQuery   += " FNT_CURVA "
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA = '"+DTOS(dDataCalc)+"'  AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)

If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->(!EOF()) .And. nTotCurva > 0
	nTaxa := ((cTab)->FNT_CURVA * nIndTotal) / nTotCurva
EndIf

RestArea(aAreaFNT)
RestArea(aAreaFNI)
RestArea(aArea)
(cTab)->(dbCloseArea())

Return nTaxa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF006VlDt   บAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo de valida็ใo de data de indice de depreciacao        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF006VlDt()

Local lRet      := .T.
Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oModelFNT := oModel:GetModel("FNTMASTER") 
Local cFilFNT   := oModelFNT:GetValue("FNT_FILIAL") 
Local cCodInd   := oModelFNT:GetValue("FNT_CODIND") 
Local cRevis    := oModelFNT:GetValue("FNT_REVIS") 
Local dData     := oModelFNT:GetValue("FNT_DATA") 
Local cRevFNI   := AFXIndRev(cCodInd)

FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS

lRet := ExistChav("FNT",cFilFNT + cCodInd + cRevis + DTOS(dData) )

If lRet
	If FNI->(MsSeek(xFilial("FNI") + cCodInd + cRevFNI))
		If FNI->FNI_TIPO == '2' .And. (dData < FNI->FNI_CURVIN .Or. dData > FNI->FNI_CURVFI)
	   		Help( ,, "AF06VERIF11",, STR0066 + DTOC(FNI->FNI_CURVIN) + STR0067 + DTOC(FNI->FNI_CURVFI)  , 1, 0 ) // "A data do indice deve ser no perํodo da curva de demanda. Data Inicial :"##" Data Final: "
			lRet := .F.
		EndIf
	EndIf	
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA006OBRIG   บAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo de valida็ใo de obrigatoriedade dos campos taxa e    บฑฑ
ฑฑบ          ณcurva de demanda                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A006OBRIG(oModel)
Local lRet    := .T.
Local aArea   := GetArea()
Local cInd    := oModel:GetValue("FNTMASTER","FNT_CODIND")
Local nTaxa   := oModel:GetValue("FNTMASTER","FNT_TAXA")
Local nCurva  := oModel:GetValue("FNTMASTER","FNT_CURVA")
Local cTipo   := ""

FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS

If FNI->(MsSeek(xFilial("FNI") + cInd ))
	cTipo := FNI->FNI_TIPO
	//Como o campo FNI_TIPO nao eh obrigatorio, pode ficar em branco.
	//Neste caso, ele sera considerado como taxa do tipo Informado.
	If cTipo $ '1/ ' // Informada
		If Empty(nTaxa)
			lRet := .F.
			Help( ,, "AF06VERITAXA",, STR0071  , 1, 0 ) //"Para indices do tipo Informado o campo taxa ้ obrigat๓rio"
		EndIf
	Else
		If Empty(nCurva)
			lRet := .F.
			Help( ,, "AF06VERICURVA",, STR0072  , 1, 0 ) //"Para indices do tipo calculado o campo curva ้ obrigat๓rio"
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImportTx  บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a exporta็ใo do projeto de imobilizado             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImportTx(cArq,lRevisa)
Local lRet        := .T.
Local nHandle     := 0
Local aTabela	    := {}
Local aLinha	    := {}
Local aEstruct	:= {}
Local aDadosAux	:= {}
Local cTabela	:= ""
Local nX		:= 0
Local nY		:= 0
Local aFNT		:= {}
Local cArqDest  := ""
Local cExt		:= ""
Local lRetRot := .T.

Default lRevisa := .F.

SplitPath(cArq,,,@cArqDest,@cExt)


If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	lRet:= .F.
EndIf

If lRet
	nTot:=FT_FLASTREC()
	FT_FGOTOP()
	
	//Realiza a Leitura da 1 linha para capturar as tabelas
	aLinha := AF006RDLN()
	FT_FSKIP()
	
	If Alltrim(aLinha[1]) != "0"
		Aviso(STR0073,STR0074,{STR0075})//"Estrutura incorreta."##"Cabecalho nao encontrado"##"Abandona"
		lRet := .F.
	EndIf
	
	If lRet
		For nX := 2 to Len(aLinha)
			AADD( aTabela, {aLinha[nX], {} } )
		Next nX
	EndIf
	
	// Carrega a estrutura da tabela
	If lRet
		For nX := 1 to Len(aTabela)
			aLinha := AF006RDLN()
			aEstruct := {}
			
			For nY := 2 to Len(aLinha)
				aAdd(aEstruct,aLinha[nY])
			Next nX
			
			aTabela[nX][2] := aClone(aEstruct)
			
			FT_FSKIP()
		Next nX
	EndIf
	
	//Realiza a Leitura dos dados
	Do While lRet .And. !FT_FEOF()
		
		aLinha := AF006RDLN()
		
		If Len(aLinha) <= 0
			FT_FSKIP()
			Loop
		EndIf
		
		nId := Val(aLinha[1])
		
		If nId <= 0 .Or. nId > Len(aTabela)
			lRet:= .F.
			Aviso(STR0073,STR0076,{STR0075})//"Estrutura incorreta."##"1บ Elemento da Linha nใo contem Id da Tabela, por favor conferir layout"##"Abandona"
			Exit
		EndIf
		
		aDel(aLinha,1)
		aSize(aLinha,Len(aLinha)-1)
		
		cTabela	:= Alltrim(aTabela[nId][1])
		aEstruct := aTabela[nId][2]
		
		If ( Len(aLinha) ) != Len( aEstruct )
			lRet:= .F.
			Aviso(STR0073,STR0077,{STR0075})//"Estrutura incorreta."##"Quantidade de colunas de dados nใo confere com a quantidade de campos configurados nas primeiras linhas"##"Abandona"
			Exit
		EndIf
		
		aDadosAux := {}
		
		For nX := 1 to Len(aLinha)
			aAdd(aDadosAux,{ aEstruct[nX] , aLinha[nX] } )
		Next nX
		
		// Prepara as informa็๕es
		// Convertendo para os tipos corretos e verificando se o campo existe no dicionario
		aFNT := AF006Dado(cTabela,aDadosAux)
		If lRetRot
			lRetRot := AFA006AUT(aFNT,3,lRevisa)
		Else
			AFA006AUT(aFNT,3,lRevisa)
		EndIf
		
		FT_FSKIP()
	EndDo
	
	FT_FUSE()
	
EndIf

If !lRetRot
	MostraErro()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF006RDLN บAutor  ณAlvaro Camillo Neto บ Data ณ  25/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Leitura da Linha e retorna um array com os dados บฑฑ
ฑฑบ          ณ jแ separados                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF006RDLN()
Local aLinha := {}
Local cLinha := ""
Local nPos   := 0

//Tratamento para linhas com tamanho superior a 1020 Bytes
If ( Len(FT_FREADLN()) < 1023 )
	cLinha	:= FT_FREADLN()
Else
	cLinha	:= ""
	While .T.
		/*Verifica se encontrou o final da linha.*/
		If ( Len(FT_FREADLN()) < 1023 )
			cLinha += FT_FREADLN()
			Exit
		Else
			cLinha += FT_FREADLN()
			FT_FSKIP()
		EndIf
	EndDo
EndIf

Do While At(";",cLinha)>0
	aAdd(aLinha,Substr(cLinha,1,At(";",cLinha)-1))
	nPos++
	cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
EndDo
If Len(AllTrim(cLinha)) > 0
	aAdd(aLinha,StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
Else
	aAdd(aLinha,"")
EndIf	

Return aLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF006Dado บAutor  ณAlvaro Camillo Neto บ Data ณ  25/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara as informa็๕es,Convertendo para os tipos corretos  บฑฑ
ฑฑบ          ณ  e verificando se o campo existe no dicionario             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF006Dado(cTabela,aDados)
Local aRet 		:= {}
Local aStruct  := (cTabela)->(dbStruct())
Local nX			:= 0
Local nPos		:= 0

For nX := 1 to Len(aDados)
	If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aDados[nX][1] ) } ) ) > 0
		Do Case
			Case aStruct[nPos][2] == "C"
				AADD(aRet,{aStruct[nPos][1] , aDados[nX][2] })
				
			Case aStruct[nPos][2] == "L"
				AADD(aRet,{aStruct[nPos][1] , aDados[nX][2]=="T" })
				
			Case aStruct[nPos][2] == "D"
				AADD(aRet,{aStruct[nPos][1] , STOD( aDados[nX][2] ) })
				
			Case aStruct[nPos][2] == "N"
				AADD(aRet,{aStruct[nPos][1] , Val( aDados[nX][2] ) })
		EndCase
	EndIf
Next nX

Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430AUT บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de cria็ใo automatica de projetos.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ
ฑฑบ          ณ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFA006AUT(aFNT,nOperation,lRevisa)
Local lRet 			:= .T.
Local nCampo		    := 0
Local oModel         := Nil
Local oModelFNT		:= Nil
Local aCpoFNT  		:= {}
Local nPos			    := 0
Local cDetalhe		:= ""
Local aArea			:= GetArea()
Local dData			:=StoD('')
Local cCodInd :=''
Local cStatus := ""
Local cBloq   := ""

Default nOperation   := MODEL_OPERATION_INSERT

FNT->(dbSetOrder(3)) // FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

//Busca a chave do projeto
If (nPos := aScan( aFNT, { |x| AllTrim( x[1] ) ==  AllTrim( "FNT_CODIND" ) } ) ) > 0
	cCodInd := aFNT[nPos][2]
EndIf

If (nPos := aScan( aFNT, { |x| AllTrim( x[1] ) ==  AllTrim( "FNT_DATA" ) } ) ) > 0
	dData := aFNT[nPos][2]
EndIf

If (nPos := aScan( aFNT, { |x| AllTrim( x[1] ) ==  AllTrim( "FNT_STATUS" ) } ) ) > 0
	cStatus := aFNT[nPos][2]
EndIf

cStatus := IIF(Empty(cStatus), "1",cStatus)

If (nPos := aScan( aFNT, { |x| AllTrim( x[1] ) ==  AllTrim( "FNT_MSBLQL" ) } ) ) > 0
	cBloq := aFNT[nPos][2]
EndIf

//Apenas importa itens ativos e nใo bloqueados
If cStatus != "1" .Or. cBloq == '1'
	AutoGrLog( STR0078 + ' [' + cCodInd + ']' )//"C๓digo do Indice :"
	AutoGrLog( STR0079 + ' [' + DTOC(dData) + ']' )//"Data do Indice   :"
	AutoGrLog( STR0080)//"Estแ com o status invแlido "
	lRet := .F.
EndIf 

If FNT->(MsSeek(xFilial("FNT") + cCodInd + DTOS(dData) )) .And. lRevisa
	__lRevisa := .T. 
EndIf 

If lRet
	oModel := FWLoadModel( 'ATFA006' )
	oModel:SetOperation( nOperation )
	lRet := oModel:Activate()
EndIf

If lRet
	oModelFNT	:= oModel:GetModel( "FNTMASTER" )
	aCpoFNT	:= oModelFNT:GetStruct():GetFields()
EndIf


//Carrega Cabe็alho do Projeto
If lRet
	For nCampo := 1 To Len( aFNT )
		If !( aFNT[nCampo][1] $ 'FNT_REVIS/FNT_STATUS/FNT_MSBLQL' )
			If ( nPos := aScan( aCpoFNT, { |x| AllTrim( x[3] ) ==  AllTrim( aFNT[nCampo][1] ) } ) ) > 0
				If !Empty(aFNT[nCampo][2])
					If !( lAux := oModelFNT:SetValue( aFNT[nCampo][1] , aFNT[nCampo][2] ) )
						lRet    := .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next nCampo
EndIf

If lRet .And. oModel:VldData()
	oModel:CommitData()
Else
	lRet := .F.
EndIf


If !lRet .And. oModel != Nil
	// Se os dados nใo foram validados obtemos a descri็ใo do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	// A estrutura do vetor com erro ้:
	//  [1] Id do formulแrio de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulแrio de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solu็ใo
	//  [8] Valor atribuido
	//  [9] Valor anterior
	AutoGrLog(CRLF)
	AutoGrLog("------------------------")
	AutoGrLog(CRLF)
	AutoGrLog( STR0078 + ' [' + cCodInd + ']' )//"C๓digo do Indice :"
	AutoGrLog( STR0079 + ' [' + DTOC(dData) + ']' )//"Data do Indice   :"
	AutoGrLog( STR0081 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulแrio de origem:"
	AutoGrLog( STR0082 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulแrio de origem:"
	AutoGrLog( STR0083 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
	AutoGrLog( STR0084 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulแrio de erro:  "
	AutoGrLog( STR0085 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
	AutoGrLog( STR0086 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
	AutoGrLog( STR0087 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
	AutoGrLog( STR0088 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
	AutoGrLog( STR0089 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
	AutoGrLog( STR0090 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
EndIf

If oModel != Nil
	// Desativamos o Model
	oModel:DeActivate()
EndIf

__lRevisa:= .F.

RestArea(aArea)

Return lRet

