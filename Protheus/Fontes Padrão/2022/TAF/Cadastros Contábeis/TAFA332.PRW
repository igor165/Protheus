#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA332.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA332
Registros GenИricos - Bloco X

@author Roger Cangianeli
@since 20/05/2014
@version 1.0  
  
/*/
//-------------------------------------------------------------------
Function TAFA332()
Local oBrw := FWmBrowse():New()
Local cReg := ""

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CFT')
oBrw:SetMenuDef( 'TAFA332' )

If "X291" $ Upper( FunDesc() )
	cReg := "X291"
ElseIf "X292" $ Upper( FunDesc() )
	cReg := "X292"
ElseIf "X360" $ Upper( FunDesc() )
	cReg := "X360"
ElseIf "X361" $ Upper( FunDesc() )
	cReg := "X361"
ElseIf "X362" $ Upper( FunDesc() )
	cReg := "X362"
ElseIf "X363" $ Upper( FunDesc() )
	cReg := "X363"
ElseIf "X364" $ Upper( FunDesc() )
	cReg := "X364"
ElseIf "X365" $ Upper( FunDesc() )
	cReg := "X365"
ElseIf "X366" $ Upper( FunDesc() )
	cReg := "X366"
ElseIf "X390" $ Upper( FunDesc() )
	cReg := "X390"
ElseIf "X400" $ Upper( FunDesc() )
	cReg := "X400"
ElseIf "X460" $ Upper( FunDesc() )
	cReg := "X460"
ElseIf "X470" $ Upper( FunDesc() )
	cReg := "X470"
ElseIf "X480" $ Upper( FunDesc() )
	cReg := "X480"
ElseIf "X490" $ Upper( FunDesc() )
	cReg := "X490"
ElseIf "X500" $ Upper( FunDesc() )
	cReg := "X500"
ElseIf "X510" $ Upper( FunDesc() )
	cReg := "X510"
EndIf

oBrw:SetFilterDefault( "CFT_IDRECF == '" + Posicione( "CFU", 2, xFilial( "CFU" ) + cReg, "CFU_ID" ) + "'" ) //Filtro do Registro

oBrw:SetCacheView(.F.)

oBrw:Activate()  


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf332Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA332" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFT 	:= 	FWFormStruct( 1, 'CFT' )
Local 	oModel 	:= MPFormModel():New( 'TAFA332' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CFT', /*cOwner*/, oStruCFT)
oModel:GetModel( 'MODEL_CFT' ):SetPrimaryKey( { "CFT_IDRECF", "CFT_PERIOD", "CFT_IDCODL" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA332' )
Local 	oStruCFT 	:= 	FWFormStruct( 2, 'CFT' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFT', oStruCFT, 'MODEL_CFT' )

oView:EnableTitleView( 'VIEW_CFT', STR0001 ) // Registros GenИricos - Bloco X
oView:CreateHorizontalBox( 'FIELDSCFT', 100 )
oView:SetOwnerView( 'VIEW_CFT', 'FIELDSCFT' )

oStruCFT:RemoveField('CFT_ID')
oStruCFT:RemoveField('CFT_IDRECF')
oStruCFT:RemoveField('CFT_IDCODL')


Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁFuncao responsavel por setar o Status do registro para BrancoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		TAFAltStat( "CFT", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf332Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacУes caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf332Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro:= {}
Local cTpLin	:= ""

If (CFT->CFT_STATUS $ (' 1'))
	
	//Valida o Registro ECF 
	If Empty(CFT->CFT_IDRECF)
		Aadd( aLogErro, { "CFT_REGECF", "000001", "CFT", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFT->CFT_IDRECF
		xVldECFTab( "CFU",cChave,1,,@aLogErro, { "CFT","CFT_REGECF", nRecno } )
	EndIf

	
	//Valida o PerМodo
	If Empty(CFT->CFT_PERIOD)
		Aadd( aLogErro, { "CFT_PERIOD", "000003", "CFT", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	
	//Valida o CСdigo de LanГamento ECF     
	If Empty(CFT->CFT_IDCODL)
		Aadd( aLogErro, { "CFT_CODLAN", "000001", "CFT", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFT->CFT_IDCODL
		xVldECFTab("CH6",cChave,1,,@aLogErro,{ "CFT","CFT_CODLAN", nRecno })	
	EndIf
	
	//REGRA_OBRIGATORIO_TIPO_DIFERENTE_R 
	//Busca o tipo na tabela de cСdigos de lanГamento
	CH6->(DbSetOrder(1))
	If CH6->(DbSeek(xFilial("CH6")+CFT->CFT_IDCODL) )
		cTpLin:= CH6->CH6_TPLIN
	EndIF
	
	If cTpLin <> "1" .And. cTpLin <> ""
		If Empty(CFT->CFT_VALOR)
			Aadd( aLogErro, { "CFT_VALOR", "000223", "CFT", nRecno } ) //STR0223 - "O campo 'Valor' deve ser preenchido obrigatoriamente quando o CСdigo de LanГamento possuir o tipo da linha diferente de 'R'."	
		EndIf
	EndIf
	
	
	//зддддддддддддддддддддддддддддд©
	//ЁATUALIZO O STATUS DO REGISTROЁ
	//Ё1 = Registro Invalido        Ё
	//Ё0 = Registro Valido          Ё
	//юддддддддддддддддддддддддддддды
	If Len(aLogErro)>0
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁUtilizo RecLock, pois o SETVALUE somente funciona em campos USADOSЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		TAFAltStat("CFT", '1')
	Else
		TAFAltStat("CFT", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CFT_ID","000017", "CFT", nRecno }) //STR0017 - "Registro jА validado"
	
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNЦo apresento o alert quando utilizo o JOB para validarЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)