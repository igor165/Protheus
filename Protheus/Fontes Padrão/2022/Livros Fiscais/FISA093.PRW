#INCLUDE "FISA093.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} FISA093
Cadastro de ISS - Instituições Financeiras 

@author Cleber Maldonado
@since 14/01/2015
**/
//--------------------------------------------------------------
Function FISA093()   
Local aArea 	:= GetArea()
Local oBrowse 	:= Nil           

//Instancia o objeto Browse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CLL')
oBrowse:SetDescription( STR0001 )

//Ativa o Browse
oBrowse:Activate()

RestArea(aArea) 
Return()          

//--------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de ISS Instituições Financeiras

@author Cleber Maldonado
@since 14/01/2015
**/
//--------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruCLL 	:= FwFormStruct( 1, "CLL" )

// Instancia o modelo de dados
oModel := MpFormModel():New( 'FISA093',/*bPre*/,/*{ |oModel| }*/,{ |oMdl| Fis93Ok( oMdl ) } , /*bCancel*/ )
oModel:SetDescription( STR0002 )

// Adiciona estrutura de campos no modelo de dados
oModel:AddFields( 'CLLMASTER', /*cOwner*/, oStruCLL )
oModel:SetDescription( STR0003 )

// Seta chave primaria
oModel:SetPrimaryKey( {"CLL_FILIAL","CLL_PERIOD","CLL_CODCTA"} )

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de ISS Instituições Financeiras

@author Cleber Maldonado
@since 14/01/2015
**/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( "FISA093" )
Local oStruCLL 	:= FwFormStruct( 2, "CLL" )//Cadastro de Cultivares

// Instancia modelo de visualização
oView := FwFormView():New()

// Seta o modelo de dados
oView:SetModel( oModel )

// Adciona os campos na estrutura do modelo de dados
oView:AddField( 'VIEW_CLL', oStruCLL, 'CLLMASTER' )

// Cria o box
oView:CreateHorizontalBox( 'TOTAL', 100 )

// Seta o owner
oView:SetOwnerView( 'VIEW_CLL', 'TOTAL' )

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de ISS - Instituições Financeiras

@author Cleber Maldonado
@since 14/01/2015
**/
//----------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'VIEWDEF.FISA093' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'VIEWDEF.FISA093' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.FISA093' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'VIEWDEF.FISA093' OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis93Vld
Valida o período informado

@author Cleber Maldonado
@since 18/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fis93Vld(cPeriodo)

Local lRet := .T.

dbSelectArea("CLL")
dbSetOrder(1)

If Substr(cPeriodo,1,2)$"01|02|03|04|05|06|07|08|09|10|11|12"
	If Val(Substr(cPeriodo,3,4))>1980 .And. Val(Substr(cPeriodo,3,4))<=2049
		lRet := .T.
	Else
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis93Vlc
Valida o código da conta referencial COSIF

@author Cleber Maldonado
@since 18/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fis93Vlc(cContaRef)

Local lRet		:= .T.
Local cAliasCVN := ""

dbSelectArea("CVN")
dbSetOrder(2)

If (TcSrvType()<>"AS/400")
	cAliasCVN	:=	GetNextAlias()
	    	
	cSelect	:=  "%CVN.*%"

	cFrom := "%"
	cFrom += RetSqlName("CVN")+" CVN %"
	
   	cWhere	:=  "%"
   	cWhere	+= "CVN.CVN_FILIAL='" + xFilial("CVN") + "' AND "
	cWhere	+= "CVN.CVN_CTAREF='" + %Exp:cContaRef%+"'%"
	
	BeginSql Alias cAliasCVN
		SELECT 
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE 
			%Exp:cWhere% AND 
			CVN.%NotDel%	
	EndSql                  
	dbSelectArea(cAliasCVN)
	If (cAliasCVN)->(EOF())
    	lRet := .F.
    Endif
	(cAliasCVN)->(DbCloseArea())
Endif 
dbCloseArea(cAliasCVN)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis93Ok
Valida a inclusão.

@author Cleber Maldonado
@since 18/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fis93Ok(oModel)

Local lRet		 := .T.
Local cAliasCLL  := "" 
Local cPeriod	 := FwFldGet("CLL_PERIOD")
Local cConta	 := FwFldGet("CLL_CODCTA")
Local cCosif	 := FwFldGet("CLL_COSIF")
Local nOperation := oModel:GetOperation()

dbSelectArea("CLL")
dbSetOrder(1)

If (TcSrvType()<>"AS/400") .And. nOperation == 3
	cAliasCLL	:=	GetNextAlias()
	    	
	cSelect	:=  "%CLL.*%"

	cFrom := "%"
	cFrom += RetSqlName("CLL")+" CLL %"
	
   	cWhere	:=  "%"
   	cWhere	+= "CLL.CLL_FILIAL='" + xFilial("CLL") + "' AND "
   	cWhere  += "CLL.CLL_PERIOD='"  + %Exp:cPeriod%+"' AND "
   	cWhere  += "CLL.CLL_CODCTA='"  + %Exp:cConta%+"' AND "
	cWhere	+= "CLL.CLL_COSIF='" + %Exp:cCosif%+"'%"
	
	BeginSql Alias cAliasCLL
		SELECT 
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE 
			%Exp:cWhere% AND 
			CLL.%NotDel%
	EndSql                  
	dbSelectArea(cAliasCLL)
	If !(cAliasCLL)->(EOF())
    	lRet := .F.
    	AVISO( "JAGRAVADO", "Já existe a conta contábil e conta cosif para esse período.", {"OK"} ) 
    Endif
	(cAliasCLL)->(DbCloseArea())
	If lRet
		FWFormCommit( oModel )
	EndIf	
Else
	FWFormCommit( oModel )	
Endif      

Return lRet