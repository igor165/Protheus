#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "GTPA013.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA013()
Cadastro de Cadastro de ECFs
 
@sample	GTPA013()
 
@return	oBrowse  Retorna o Cadastro de ECFs
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA013()
	Local oBrowse
	Private aRotina	:= MenuDef()
		
	oBrowse:=FWMBrowse():New() 
	oBrowse:SetAlias('GZ2') 
	oBrowse:SetDescription(STR0001)	// Cadastro de ECFs
	oBrowse:Activate()

Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do Menu
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRot := {} 
	
	ADD OPTION aRot TITLE STR0007 ACTION 'PesqBrw' 			OPERATION 1 	ACCESS 0 //#Pesquisar
	ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.GTPA013' 	OPERATION 2 	ACCESS 0 //#Visualizar
	ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.GTPA013' 	OPERATION 3 	ACCESS 0 //#Incluir
	ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.GTPA013' 	OPERATION 4 	ACCESS 0 //#Alterar
	ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.GTPA013' 	OPERATION 5 	ACCESS 0 //#Excluir

Return aRot


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel		:= Nil
Local oStruGZ2	:= FWFormStruct(1,'GZ2')
Local bPosValid	:= {|oModel|TP013TdOK(oModel)}	
Local bCommit	:= {|oModel| GTPA013Commit(oModel)	}

oStruGZ2:SetProperty('GZ2_CODIGO',MODEL_FIELD_VALID, {|| AllwaysTrue() })

oModel := MPFormModel():New('GTPA013',/*bPreValid*/,bPosValid ,bCommit,/*bCancel*/)

oModel:AddFields('GZ2MASTER',/* cOwner */,oStruGZ2)

oModel:SetDescription(STR0001)// #Cadastro de ECFs

oModel:GetModel('GZ2MASTER'):SetDescription(STR0001)// #Cadastro de ECFs

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da Interface
 
@sample	ViewDef()
 
@return	oView - Objeto da Interface
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := ModelDef()

Local oStruGZ2 := FWFormStruct(2,'GZ2')

Local oView 

oView:= FWFormView():New()

oView:SetModel(oModel)
oView:SetDescription(STR0006)// #Dados do ECFs

oView:AddField('VIEW_GZ2',oStruGZ2,'GZ2MASTER')

oView:CreateHorizontalBox('TELA_GZ2',100)

//Relaciona a view com box a que sera utilizado pelo ID criado acima
oView:SetOwnerView('VIEW_GZ2','TELA_GZ2')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TP013TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP013TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGZ2	:= oModel:GetModel('GZ2MASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGZ2:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGZ2:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GZ2", oMdlGZ2:GetValue("GZ2_CODIGO")+oMdlGZ2:GetValue("GZ2_AGENCI") ))
		Help( ,, 'Help',"TP013TdOK", STR0008, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA013Commit
Função Responsavel pela gravação do modelo
@type function
@author jacomo.fernandes
@since 23/08/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function GTPA013Commit(oModel)
Local lRet		:= .T.
Local oMdlGZ2	:= oModel:GetModel('GZ2MASTER')
Local nOpc		:= oModel:GetOperation()

Local cFilOld	:= cFilAnt
Local cFilRes	:= Posicione('GI6',1,xFilial('GI6')+oMdlGZ2:GetValue('GZ2_AGENCI'),'GI6_FILRES')
Local cPdv		:= SubStr(oMdlGZ2:GetValue('GZ2_CODIGO'),4)
Local cStation	:= ''
Local aCab		:= {} 

Local cMsgErro	:= ""

Private lMsErroAuto	:= .F.

If Empty(cFilRes)
	cMsgErro	:= STR0009 //"A filial responsável pela Agência informada no ECF não está preenchida"
	lRet		:= .F.
Else
	cFilAnt		:= cFilRes 
Endif
IF lRet
	SLG->(DbSetOrder(1))
	If SLG->(DbSeek(cFilRes+cPdv)) 
		nOpc		:= If( nOpc <> MODEL_OPERATION_DELETE,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE)
		cStation	:= SLG->LG_SERIE
		
	ElseIf nOpc <> MODEL_OPERATION_DELETE
		nOpc := MODEL_OPERATION_INSERT
		cStation	:= GetNextId(cFilRes,@lRet,@cMsgErro)
	Else 
		lRet := .F.
	Endif
Endif

If lRet
	//Armazena informacoes da Estacao
	aAdd( aCab, {"LG_CODIGO"	, cPdv 								, Nil} )
	aAdd( aCab, {"LG_PDV"		, cPdv								, Nil} )
	aAdd( aCab, {"LG_NOME"		, oMdlGZ2:GetValue('GZ2_DESCRI') 	, Nil} )
	aAdd( aCab, {"LG_IMPFISC"	, oMdlGZ2:GetValue('GZ2_SERIE') 	, Nil} )
	aAdd( aCab, {"LG_SERPDV"	, oMdlGZ2:GetValue('GZ2_CODIGO')	, Nil} )
	aAdd( aCab, {"LG_SERIE"		, cStation							, Nil} )
	aAdd( aCab, {"LG_INTCNS"	, .F.								, Nil} )
	aAdd( aCab, {"LG_GAVSTAT"	, .F.								, Nil} )
	
	
	Begin Transaction 
		MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, Nil, Nil, aCab, nOpc)
									
		If lMsErroAuto
			lRet	:= .F.
			DisarmTransaction()
			Break																							 
		EndIf
	End Transaction
Endif

If lRet .or. (!lRet .and. nOpc == MODEL_OPERATION_DELETE)
	lRet	:= FwFormCommit(oModel)
ElseIf lMsErroAuto
	MostraErro()
	oModel:SetErrorMessage(oMdlGZ2:GetId(),'',oMdlGZ2:GetId(),'','GTPA013COMMIT', STR0011) //"Não foi possivel finalizar o processo!"
Endif	

cFilAnt		:= cFilOld

GtpDestroy(aCab)

Return lRet


/*/{Protheus.doc} GetNextId
Funlçao Responsavel para buscaro próximo numero de série
@type function
@author jacomo.fernandes
@since 23/08/2018
@version 1.0
@param cFilRes, character, (Descrição do parâmetro)
@param lRet, ${param_type}, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetNextId(cFilRes,lRet,cMsgErro)

Local cNxtId	:= ""
Local cNxtAlias	:= GetNextAlias()

Default lRet	:= .T.
Default cMsgErro:= ""

BeginSQL Alias cNxtAlias

	SELECT 
		MAX(LG_SERIE) LG_SERIE
	FROM 
		%Table:SLG% SLG
	WHERE
		LG_FILIAL = %Exp:cFilRes%
		AND SUBSTRING(LG_SERIE,1,1) = 'D'
		AND SLG.%NotDel%

EndSQL

If ( !Empty((cNxtAlias)->LG_SERIE) )

	If ( Soma1((cNxtAlias)->LG_SERIE) <= "DZZ" )
		cNxtId := Soma1((cNxtAlias)->LG_SERIE)
	Else
		cNxtId := ""
	EndIf	 

Else
	cNxtId := "D00"
EndIf

If Empty(cNxtId)
	cMsgErro	:= STR0012 //"Não foi possível incluir os dados na tabela de Estações (SLG) do módulo SIGALOJA. Não há código livre"
	lRet		:= .F.
Endif 

(cNxtAlias)->(DbCloseArea())
Return(cNxtId)