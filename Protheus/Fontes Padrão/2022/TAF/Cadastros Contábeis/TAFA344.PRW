#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA344.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA344
Cadastro MVC de Doacoes a Campanhas Eleitorais

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA344()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Doacoes a Campanhas Eleitorais"
oBrw:SetAlias( 'CGK')
oBrw:SetMenuDef( 'TAFA344' )
CGK->(DbSetOrder(2))
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

Local aFuncao := {{ "" , "TAF344Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA344" , , aFuncao )

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

Local oStruCGK := FWFormStruct( 1, 'CGK' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA344' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGK:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGK' , /*cOwner*/, oStruCGK) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGK'):SetPrimaryKey( { 'CGK_PERIOD','CGK_CNPJ'} )           

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

Local oModel 	:= 	FWLoadModel( 'TAFA344' )
Local oStruCGK:= 	FWFormStruct( 2, 'CGK' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCGK:RemoveField('CGK_ID')
                                       
oView:AddField('VIEW_CGK' , oStruCGK,  'MODEL_CGK' ) 
oView:EnableTitleView( 'VIEW_CGK', STR0001 ) //'Doacoes a Campanhas Eleitorais

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGK', 'PAINEL_PRINCIPAL' )   

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
		TAFAltStat( "CGK", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf344Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF344Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cBlc0CNPJ  	:= Iif( RetPessoa( SM0->M0_CGC ) == "J", SM0->M0_CGC, "" )

Default lJob := .F.

If CGK->CGK_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGK->CGK_PERIOD)
		Aadd( aLogErro, {"CGK_PERIOD", "000001", "CGK", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ do beneficiário
	If Empty(CGK->CGK_CNPJ)
		Aadd( aLogErro, {"CGK_CNPJ", "000001", "CGK", nRecno }) //000001 - Campo Inconsistente ou Vazio
	Else 
		If !CGC(CGK->CGK_CNPJ,,.F.)
			Aadd( aLogErro, {"CGK_CNPJ", "000006", "CGK", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf
		
		//REGRA_CNPJ_DIFERENTE
		If CGK->CGK_CNPJ == cBlc0CNPJ
			Aadd( aLogErro, {"CGK_CNPJ", "000163", "CGK", nRecno }) //STR0163 - "O valor do campo deve ser diferente do CNPJ do declarante."
		EndIf	
	EndIf
	
	//Valida o tipo do beneficiário
	If Empty(CGK->CGK_TIPBEN)
		Aadd( aLogErro, {"CGK_TIPBEN", "000001", "CGK", nRecno }) //000001 - Campo Inconsistente ou Vazio	
	ElseIf !CGK->CGK_TIPBEN $ ('01|02|03')
		Aadd( aLogErro, {"CGK_TIPBEN", "000002", "CGK", nRecno }) //000002 - Conteúdo do campo não condiz com as opções possiveis.
	EndIf
	
	//Valida a forma de doação
	If Empty(CGK->CGK_DOACAO)
		Aadd( aLogErro, {"CGK_DOACAO", "000001", "CGK", nRecno }) //000001 - Campo Inconsistente ou Vazio	
	ElseIf !CGK->CGK_DOACAO $ ('01|02|03|04|05|06|07')
		Aadd( aLogErro, {"CGK_DOACAO", "000002", "CGK", nRecno }) //000002 - Conteúdo do campo não condiz com as opções possiveis.
	EndIf
	
	//Valida o valor da doação  
	If Empty(CGK->CGK_VLDOA)
		Aadd( aLogErro, {"CGK_VLDOA", "000001", "CGK", nRecno }) //000001 - Campo Inconsistente ou Vazio
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
		RecLock("CGK",.F.)
		CGK->CGK_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGK",.F.)
		CGK->CGK_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGK_ID","000017", "CGK", nRecno })//Registros já validado
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)