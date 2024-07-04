#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA345.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA345
Cadastro MVC de Ativos no Exterior

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//------------------------------------------------------------------- 
Function TAFA345()

Local	oBrw	:= FWmBrowse():New()
dbSelectArea("CGL")
CGL->(DbSetOrder(2))
oBrw:SetDescription( STR0001 )	//Ativos no Exterior
oBrw:SetAlias( 'CGL')
oBrw:SetMenuDef( 'TAFA345' )

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Paulo VilasBoas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF345Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA345" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Vilas Boas
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGL := FWFormStruct( 1, 'CGL' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA345' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGL:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGL' , /*cOwner*/, oStruCGL) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGL'):SetPrimaryKey( { 'CGL_PERIOD','CGL_TIPATV','CGL_DISCRI'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA345' )
Local oStruCGL:= 	FWFormStruct( 2, 'CGL' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGL:RemoveField('CGL_ID')
                                       
oView:AddField('VIEW_CGL' , oStruCGL,  'MODEL_CGL' ) 
oView:EnableTitleView( 'VIEW_CGL', STR0001 ) //'Ativos no Exterior'

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGL', 'PAINEL_PRINCIPAL' ) 

oStruCGL:RemoveField( "CGL_IDTATV" )  

oStruCGL:SetProperty( "CGL_PERIOD"	, MVC_VIEW_ORDEM, "03" )
oStruCGL:SetProperty( "CGL_TIPATV"	, MVC_VIEW_ORDEM, "04" )
oStruCGL:SetProperty( "CGL_DTPATV"	, MVC_VIEW_ORDEM, "05" )
oStruCGL:SetProperty( "CGL_PAIS" 	, MVC_VIEW_ORDEM, "06" )
oStruCGL:SetProperty( "CGL_DPAIS" 	, MVC_VIEW_ORDEM, "07" )
oStruCGL:SetProperty( "CGL_DISCRI" , MVC_VIEW_ORDEM, "08" )
oStruCGL:SetProperty( "CGL_VLANT"	, MVC_VIEW_ORDEM, "09" )
oStruCGL:SetProperty( "CGL_VLATU"	, MVC_VIEW_ORDEM, "10" )

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CGL", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf345Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF345Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}
Local cChave:= ''
Default lJob := .F.

If CGL->CGL_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGL->CGL_PERIOD)
		Aadd( aLogErro, {"CGL_PERIOD", "000001", "CGL", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Tipo de Ativo    
	If Empty(CGL->CGL_IDTATV)
		Aadd( aLogErro, {"CGL_TIPATV", "000001", "CGL", nRecno }) //000010 - Campo Inconsistente ou Vazio
    Else
		xVldECFTab("CW6",CGL->CGL_IDTATV,1,,@aLogErro,{"CGL","CGL_TIPATV",nRecno })
    EndIf	
		
	//Valida o País
	If Empty(CGL->CGL_PAIS)
		Aadd( aLogErro, {"CGL_PAIS", "000001", "CGL", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CGL->CGL_PAIS
		xVldECFTab("C08",cChave,3,,@aLogErro,{"CGL","CGL_PAIS",nRecno })
    EndIf
	
	//Valida a Discriminação  
	If Empty(CGL->CGL_DISCRI)
		Aadd( aLogErro, {"CGL_DISCRI", "000001", "CGL", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Valor Atual   
	If Empty(CGL->CGL_VLATU)
		Aadd( aLogErro, {"CGL_VLATU", "000001", "CGL", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CGL",.F.)
		CGL->CGL_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGL",.F.)
		CGL->CGL_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
Else
	
	AADD(aLogErro,{"CGL_ID","000017", "CGL", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)