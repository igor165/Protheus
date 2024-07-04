#include "GTPA022.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'

//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPA022  
  
Tipos de Linhas
  
@sample 	 GTPA022()  
  
@return	 Nil  
@author	 Wanderley Monteiro da Silva  
@since	 31/08/2015  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
FUNCTION GTPA022()

Local oBrowse

oBrowse:=FWMBrowse():New()
oBrowse:SetAlias('GQC')
oBrowse:SetDescription(STR0001)//"Tipos de Linha"
oBrowse:Activate()

Return(NIL)


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@sample		MenuDef()

@return		aRotina   Array contendo as opções do Menu                                                                                                                           

@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015 
@version	P12

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA022' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA022' OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA022' OPERATION 4 ACCESS 0//'Alterar'
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA022' OPERATION 5 ACCESS 0//'Excluir'

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@sample		ModelDef()

@return		oModel 		Objeto do Model

@author		Wanderley Monteiro da Silva 
@since		 03/07/2015  
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGQC	:= FWFormStruct(1,'GQC')
Local oStruGZW	:= FWFormStruct(1,'GZW', { |X| Alltrim(x)+"|" $ "GZW_EST|GZW_PROTAR|"},.F. ) 
Local bPosValid	:= {|oModel|TP022TdOK(oModel)}
Local oModel	:= MPFormModel():New('GTPA022',/*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)
Local aRelation	:= {}

oModel:AddFields('GQCMASTER',/*cOwner*/,oStruGQC)
oModel:AddGrid("EXCECAOF", "GQCMASTER", oStruGZW ) 

aRelation	:= {{"GZW_FILIAL","xFilial('GZW')"},;
						{"GZW_CODGQC","GQC_CODIGO"}	}

oModel:SetRelation( 'EXCECAOF', aRelation  )
oModel:SetPrimaryKey({"GQC_FILIAL","GQC_CODIGO"})

oModel:GetModel ("EXCECAOF"):SetOptional(.T.)
oModel:GetModel("EXCECAOF"):SetUniqueLine({"GZW_EST"})
oModel:SetDescription(STR0002) //"Tipos de Linhas"
oModel:GetModel("GQCMASTER"):SetDescription(STR0002)
oModel:GetModel('EXCECAOF'):SetDescription("Exceção Fiscal GTP por tipo de linha")
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015 
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel('GTPA022')
Local oStruGQC	:= FWFormStruct(2,'GQC')
Local oStruGZW	:= FWFormStruct(2,'GZW', { |X| Alltrim(x)+"|" $ "GZW_EST|GZW_PROTAR|"},.F. )
Local oView

oView:=FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW',oStruGQC,'GQCMASTER')
oView:AddGrid("VIEW_EXCECAO"  ,oStruGZW,"EXCECAOF")

oView:CreateHorizontalBox('TLINHA',50)
oView:CreateHorizontalBox('EXCECAO',50)
oView:SetOwnerView('VIEW','TLINHA')
oView:SetOwnerView( "VIEW_EXCECAO", "EXCECAO")

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}
aRet:= GTPI022( cXml, nTypeTrans, cTypeMessage )
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP013TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP022TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGQC	:= oModel:GetModel('GQCMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGQC:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGQC:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GQC", oMdlGQC:GetValue("GQC_CODIGO")))
		Help( ,, 'Help',"TP022TdOK", STR0009, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)