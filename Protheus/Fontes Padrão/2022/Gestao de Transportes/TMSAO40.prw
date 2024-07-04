#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE 'TMSAO40.CH'

//-------------------------------------------------------------------
/*TMSAO40

Rotina de saldo de horas do motorista
                                                                                        
@author  Caio Murakami
@since   22/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Function TMSAO40( aRotAuto, nOpcAuto )
Local oBrowse  
Local cFiltro	:= ""

Default aRotAuto := NIL

If aRotAuto == Nil
	
	If Pergunte("TMSAO40",.T.)   
   	cFiltro 	:= " DEX_CODMOT >= '"+ mv_par01 + "' .And. DEX_CODMOT <= '" + mv_par02 + "' .And. "
   	cFiltro	+= " DEX_DATA   >= '"+dToS(mv_par03) + "' .And. DEX_DATA <= '" + DtoS(mv_par04) + "' "
	EndIf

	oBrowse := FWmBrowse():New()	
	oBrowse:SetAlias( 'DEX' )   	 
	oBrowse:DisableDetails()
	oBrowse:SetDescription( STR0006 )
	oBrowse:SetFilterDefault(cFiltro) 
	oBrowse:Activate()	
Else
	aRotina := MenuDef()
	FwMvcRotAuto(ModelDef(),"DEX",nOpcAuto,{{"MdFieldDEX",aRotAuto}} , .F. , .F.)  //-- Chamada da rotina automatica através do MVC
EndIf

Return

//-------------------------------------------------------------------
/*MenuDef
@author  Caio Murakami
@since   22/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRot := {}   

	aAdd( aRot, { STR0003   	, 'VIEWDEF.TMSAO40', 0, 2, 0, .F. } )	//-- Visualizar	
	aAdd( aRot, { STR0004  		, 'VIEWDEF.TMSAO40', 0, 8, 0, .F. } )	//-- Imprimir
	
Return aRot


//-------------------------------------------------------------------
/*ModelDef
Model dos Parametros da Jornada de Trabalho

@author  Caio Murakami
@since   21/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function ModelDef()  
Local oStructDEX
Local oModel	

oStructDEX := FwFormStruct(1,"DEX",,)
                                                                        
oModel:= MpFormModel():New("TMSAO40",,,,/*Cancel*/)  

oModel:AddFields("MdFieldDEX",,oStructDEX,/*bPreValid*/,/*bPosValid*/,/*Carga*/)
oModel:SetDescription(STR0006) 								
oModel:GetModel("MdFieldDEX"):SetDescription(STR0006) 

Return oModel

//-------------------------------------------------------------------
/* ViewDef
Definicao da View 

@author  Caio Murakami
@since   21/01/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStructDEX := FwFormStruct(2,'DEX')
Local oModel     := FwLoadModel('TMSAO40')            
Local oView    

oView := FwFormView():New()

oView:SetModel(oModel)
oView:AddField('VwFieldDEX', oStructDEX , 'MdFieldDEX') 
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VwFieldDEX','TELA')

Return oView 

//-------------------------------------------------------------------
/* AO40CBOX
Retorno de string para combobox

@author  Caio Murakami
@since   14/02/2013
@version 1.0
*/
//-------------------------------------------------------------------

Function AO40CBOX()
Local cTexto 	:= ""	

cTexto	:= STR0009 + ";" //-- "1=Tempo da Jornada de Trabalho"  
cTexto	+= STR0010 + ";" //-- "2=Tempo de Direção"   
cTexto	+= STR0011 + ";" //-- "3=Tempo Excedido da Jornada"  
cTexto	+= STR0012 + ";" //-- "4=Tempo de Espera"         
cTexto	+= STR0013 + ";" //-- "5=Tempo de Descanso"
cTexto	+= STR0014 + ";" //-- "6=Tempo de Refeição"
cTexto	+= STR0015  		//-- "7=Tempo de Parada" 

Return cTexto
