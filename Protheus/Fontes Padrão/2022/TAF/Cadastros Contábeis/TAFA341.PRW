#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA341.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA341
Cadastro MVC de Receita de Vendas dos Estab. por Atividade Economica

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA341()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Receita de Vendas dos Estab. por Atividade Economica"
oBrw:SetAlias( 'CGH')
oBrw:SetMenuDef( 'TAFA341' )
CGH->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF341Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA341" , , aFuncao )

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

Local oStruCGH := FWFormStruct( 1, 'CGH' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA341' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGH:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGH' , /*cOwner*/, oStruCGH) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGH'):SetPrimaryKey( { 'CGH_PERIOD','CGH_CNPJ','CGH_IDCNAE' } ) 
             

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

Local oModel 		:= 	FWLoadModel( 'TAFA341' )
Local oStruCGH	:= 	FWFormStruct( 2, 'CGH' )
Local oView 		:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGH:RemoveField('CGH_ID')
                                       
oView:AddField('VIEW_CGH' , oStruCGH,  'MODEL_CGH' ) 
oView:EnableTitleView( 'VIEW_CGH', STR0001 ) //"Receita de Vendas dos Estab. por Atividade Economica" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGH', 'PAINEL_PRINCIPAL' )  

oStruCGH:RemoveField( "CGH_IDCNAE" ) 

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
		TAFAltStat( "CGH", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf341Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF341Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGH->CGH_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGH->CGH_PERIOD)
		Aadd( aLogErro, {"CGH_PERIOD", "000001", "CGH", nRecno }) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ
	If Empty(CGH->CGH_CNPJ)
		Aadd( aLogErro, {"CGH_CNPJ", "000001", "CGH", nRecno }) //000010 - Campo Inconsistente ou Vazio
	Else
		If !CGC(CGH->CGH_CNPJ,,.F.)
			Aadd( aLogErro, {"CGH_CNPJ", "000006", "CGH", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf
	EndIf
	
	//Valida a receita de vendas   
	If Empty(CGH->CGH_VLREC)
		Aadd( aLogErro, {"CGH_VLREC", "000001", "CGH", nRecno }) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNAE  
	If Empty(CGH->CGH_IDCNAE)
		Aadd( aLogErro, {"CGH_CNAE", "000001", "CGH", nRecno }) //000010 - Campo Inconsistente ou Vazio
    Else
		xVldECFTab("CZS",CGH->CGH_IDCNAE,1,,@aLogErro,{"CGH","CGH_CNAE",nRecno })
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
		RecLock("CGH",.F.)
		CGH->CGH_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGH",.F.)
		CGH->CGH_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGH_ID","000017", "CGH", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)