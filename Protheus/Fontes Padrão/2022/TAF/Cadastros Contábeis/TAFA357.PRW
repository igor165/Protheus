#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA357.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA357
Cadastro MVC de Outras Inf. Lucro Pres.Total Atual

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA357()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Outras Informações (Lucro Presumido ou Lucro Arbitrado)"    
oBrw:SetAlias( 'CGV')
oBrw:SetMenuDef( 'TAFA357' )  
CGV->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF357Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA357" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGV 	:= 	FWFormStruct( 1, 'CGV' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA357' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGV:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGV' , /*cOwner*/, oStruCGV) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CGV'):SetPrimaryKey( {'CGV_PERIOD'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA357' )
Local oStruCGVa	:=	nil
Local oStruCGVb	:=	nil
Local oView 	:= 	FWFormView():New()
Local cCmpFil	:= ""


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

cGrpAba01 := "CGV_FILIAL|CGV_ID|CGV_PERIOD|CGV_CAPANT|CGV_CAPITA|CGV_ESTANT|CGV_ESTOQU|CGV_CAIANT|CGV_CAIXA|CGV_APLANT|CGV_APLFIN|CGV_CTRANT|CGV_CTAREC|CGV_CTPANT|CGV_CTAPAG|CGV_COMMER|CGV_COMATI|CGV_RECEIT|CGV_TOTATI|CGV_FOLHA|CGV_ALQRED|GV_INDEST|"
cGrpAba02 := "CGV_REGAPU|"

cCmpFil   := cGrpAba01
oStruCGVa := FWFormStruct( 2, 'CGV',{ |x| AllTrim( x ) + "|" $ cCmpFil } )

cCmpFil := cGrpAba02
oStruCGVb := FWFormStruct( 2, 'CGV',{ |x| AllTrim( x ) + "|" $ cCmpFil } )

oStruCGVa:AddGroup( "GRP_ABA01", "", "", 1 )
oStruCGVa:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA01") 
oStruCGVa:RemoveField('CGV_ID')

oStruCGVb:AddGroup( "GRP_ABA02", "", "", 1 )
oStruCGVb:SetProperty('*', MVC_VIEW_GROUP_NUMBER,"GRP_ABA02")

oView:AddField("VIEW_CGVa",oStruCGVa,"MODEL_CGV")
oView:AddField("VIEW_CGVb",oStruCGVb,"MODEL_CGV")

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGV - Outras Inf. Lucro Pres.Total Atual	

//Aba Principal
oView:AddSheet("FOLDER_PRINCIPAL","ABA01","Principal")
oView:CreateHorizontalBox("ABA001",100,,,"FOLDER_PRINCIPAL","ABA01")
oView:SetOwnerView("VIEW_CGVa","ABA001")

//Aba Obsoletos
oView:AddSheet("FOLDER_PRINCIPAL","ABA02","Obsoletos")
oView:CreateHorizontalBox("ABA002",100,,,"FOLDER_PRINCIPAL","ABA02")
oView:SetOwnerView("VIEW_CGVb","ABA002")

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
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
		TAFAltStat( "CGV", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf357Vld

@author Denis R. de Oliveira
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF357Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGV->CGV_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CGV->CGV_PERIOD)
		Aadd( aLogErro, {"CGV_PERIOD", "000001", "CGV", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o Regime Apuracao Receitas
	If !Empty( CGV->CGV_REGAPU )
		If !( CGV->CGV_REGAPU $ ( "1|2" ) )
			aAdd( aLogErro, { "CGV_REGAPU", "000002", "CGV", nRecno } ) //STR0002 - Conteúdo do campo não condiz com as opções possíveis.
		EndIf
	EndIf

	//Valida o Método de Avaliação de Estoques
	If !Empty(CGV->CGV_INDEST)

		If !(CGV->CGV_INDEST $ ("1|2|3"))
			AADD(aLogErro,{"CGV_INDEST","000002","CGV", nRecno}) //STR0002 - Conteúdo do campo não condiz com as opções possíveis.
		EndIf 
		
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
		RecLock("CGV",.F.)
		CGV->CGV_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGV",.F.)
		CGV->CGV_STATUS := "0"
		MsUnlock()
	EndIf	  	    
		
Else
	
	AADD(aLogErro,{"CGV_ID","000017","CGV", nRecno})//STR0017 - Registro já validado.
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)