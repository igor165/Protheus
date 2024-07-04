#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.CH'
#include 'GTPA420.CH'


/*/{Protheus.doc} GTPA420
Cadastro de Tipos de Documentos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/
Function GTPA420()

Local oBrowse	:= Nil
Private aRotina	:= MenuDef()
	
	Processa({|| GTPA420GZC()}) 
	oBrowse:=FWMBrowse():New()
	oBrowse:SetAlias("GZC")
	oBrowse:SetDescription(STR0008) //Tipos de Documentos
	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef
Defini��o de Menu do Cadastro de Tipos de Documentos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/

Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA420' OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA420' OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA420' OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA420' OPERATION 5 ACCESS 0 // #Excluir

Return aRotina

/*/{Protheus.doc} ModelDef
Defini��o do Modelo de Dados do Cadastro de Tipos de Documentos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/

Static Function ModelDef()

Local oStruGZC	:= FWFormStruct( 1,"GZC")	//Tabela de Tipos de Documentos
Local oModel
	
	oModel := MPFormModel():New('GTPA420', {|a,b,c,d,e,f| Gtp420PreVld(a,b,c,d,e,f)}/*bPreValidacao*/, {|| GtpVld420(oModel)}, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('GZCMASTER',/*cPai*/,oStruGZC)
	oModel:SetPrimaryKey({"GZC_FILIAL","GZC_CODIGO"})
	
	oStruGZC:SetProperty('GZC_CODIGO', MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|GA420VldCod(oMdl,cField,cNewValue,cOldValue) } )

	If !FwIsInCallStack('GTPI420') 
		oStruGZC:SetProperty( "*"  			, MODEL_FIELD_WHEN  , {|| FwFldGet('GZC_PROPRI') <> 'S' } ) //Quando Criado por sistema, o usu�rio n�o poder� altera-lo
	Endif
	
	oStruGZC:SetProperty('GZC_LANCX'	, MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	oStruGZC:SetProperty('GZC_LCXREJ'	, MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	oStruGZC:SetProperty('GZC_TIPDOC'	, MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	oStruGZC:SetProperty('GZC_GERTIT'	, MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	oStruGZC:SetProperty('GZC_PREFIX'	, MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	if GZC->(FieldPos("GZC_INCFCH")) > 0
		oStruGZC:SetProperty('GZC_INCFCH', MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE() } )
	EndIf
	oModel:SetDescription(STR0008) //Tipos de Documentos
	


Return oModel

/*/{Protheus.doc} ViewDef
Defini��o da Interface do Cadastro de Tipos de Documentos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/
Static Function ViewDef()

Local oModel	:= FWLoadModel('GTPA420')
Local oStruGZC	:= FWFormStruct(2,'GZC')
Local oView		:= Nil

	oStruGZC:RemoveField('GZC_PROPRI')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription("Tipos de Documentos") 

	oView:AddField('VIEW_GZC',oStruGZC,'GZCMASTER')
	oView:CreateHorizontalBox('VIEWTOTAL',100)
	
	oView:SetOwnerView('VIEW_GZC','VIEWTOTAL')
	
Return oView

Function Gtp420PreVld(oModel,b,c,d,e,f)
Local lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE .and. GZC->GZC_PROPRI = 'S'
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","Gtp420PreVld",STR0011)//"N�o � possivel deletar um tipo de documento criado pelo sistema"
	Endif
	
Return lRet

/*/{Protheus.doc} VldModel
MenuDef do Cadastro de Tipos de Documentos

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/
Function GtpVld420(oModel)

Local lRet       := .T.
Local cCodigo
Local nOperation :=  oModel:GetOperation()


	DbSelectArea("GZC")
	GZC->(DbSetOrder(1))
	
	If nOperation == MODEL_OPERATION_INSERT 
		cCodigo := oModel:GetValue('GZCMASTER','GZC_CODIGO')
		If GZC->(DbSeek(xFilial("GZC")+cCodigo))
			Help( ,, 'Help',"GTPA420",STR0007, 1, 0 ) //"Tipo de Documento j� cadastrado."
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE .and. oModel:GetValue('GZCMASTER','GZC_PROPRI') = 'S'
		lRet := .F.
		Help( ,, 'Help',"GtpVld420",STR0011, 1, 0 )//"N�o � possivel deletar um tipo de documento criado pelo sistema"
		
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	
		If oModel:GetValue('GZCMASTER','GZC_GERTIT') == '1' .And. Empty(oModel:GetValue('GZCMASTER','GZC_NATUR'))
		
			oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","Gtp420PreVld", STR0033)// "Natureza financeira obrigat�ria para tipos que geram t�tulos."
			lRet := .F.
			
		Endif
	
	Endif
		
Return lRet

/*/{Protheus.doc} TP420VldCod
Valida��o de Campo para verificar se existe o c�digo cadastrado na tabela.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/

Function TP420VldCod(cCodigo)

Local lRet := .T.

	DbSelectArea("GZC")
	GZC->(DbSetOrder(1))
	
	If GZC->(DbSeek(xFilial("GZC")+cCodigo))
			Help( ,, 'Help',"GTPA420",STR0007, 1, 0 ) //"Tipo de Documento j� cadastrado."
			lRet := .F.
	EndIf
	
	
Return lRet


Function GTPA420GZC()

Local lRet      := .T.
Local aArea     := GetArea()
Local oModel	:= FwLoadModel('GTPA420')
Local oMdlGZC	:= oModel:GetModel('GZCMASTER')
Local aDados	:= {}
Local nX		:= 0

//         ,GZC_CODIGO                          ,GZS_DESCRI  ,GZS_TIPO
aAdd(aDados,{StrZero(01,TamSx3('GZC_CODIGO')[1]),  STR0012,  '1' })//001 - "DOCUMENTO CHEQUE RECEITA"
aAdd(aDados,{StrZero(02,TamSx3('GZC_CODIGO')[1]),  STR0013,  '2' })//002 - "DOCUMENTO CHEQUE DESPESA"
aAdd(aDados,{StrZero(03,TamSx3('GZC_CODIGO')[1]),  STR0014,  '2' })//003 - "BILHETE CANCELADO"                  
aAdd(aDados,{StrZero(04,TamSx3('GZC_CODIGO')[1]),  STR0015,  '2' })//004 - "BILHETE DEVOLVIDO"                  
aAdd(aDados,{StrZero(05,TamSx3('GZC_CODIGO')[1]),  STR0016,  '2' })//005 - "REQUISI��ES"                        
aAdd(aDados,{StrZero(06,TamSx3('GZC_CODIGO')[1]),  STR0017,  '1' })//006 - "TAXA DE EMBARQUE"                   
aAdd(aDados,{StrZero(07,TamSx3('GZC_CODIGO')[1]),  STR0018,  '1' })//007 - "TAXA DE EXCEDENTE"                  
aAdd(aDados,{StrZero(08,TamSx3('GZC_CODIGO')[1]),  STR0019,  '2' })//008 - "TROCA VENDAS DE PASSAGENS INTERNET" 
aAdd(aDados,{StrZero(09,TamSx3('GZC_CODIGO')[1]),  STR0020,  '2' })//009 - "TROCA VENDAS DE IMPRESS�O POSTERIOR"
aAdd(aDados,{StrZero(10,TamSx3('GZC_CODIGO')[1]),  STR0021,  '2' })//010 - "OUTRAS ENTREGAS"                    
aAdd(aDados,{StrZero(11,TamSx3('GZC_CODIGO')[1]),  STR0022,  '2' })//011 - "TROCAS DE PASSAGENS"                
aAdd(aDados,{StrZero(12,TamSx3('GZC_CODIGO')[1]),  STR0023,  '2' })//012 - "VENDAS POS CR�DITO"                 
aAdd(aDados,{StrZero(13,TamSx3('GZC_CODIGO')[1]),  STR0024,  '2' })//013 - "VENDAS POS D�BITO"                  
aAdd(aDados,{StrZero(14,TamSx3('GZC_CODIGO')[1]),  STR0025,  '2' })//014 - "VENDAS TEF CR�DITO"                 
aAdd(aDados,{StrZero(15,TamSx3('GZC_CODIGO')[1]),  STR0026,  '2' })//015 - "VENDAS TEF D�BITO"                  
aAdd(aDados,{StrZero(16,TamSx3('GZC_CODIGO')[1]),  STR0027,  '1' })//016 - "ADIANT.IMPRESS�O POSTERIOR"         
aAdd(aDados,{StrZero(17,TamSx3('GZC_CODIGO')[1]),  STR0028,  '2' })//017 - "BILHETES INUTILIZADOS"                                                                                                                   
aAdd(aDados,{StrZero(18,TamSx3('GZC_CODIGO')[1]),  STR0029,  '1' })//018 - "Cancelamento de Cart�o de Debito"   
aAdd(aDados,{StrZero(19,TamSx3('GZC_CODIGO')[1]),  STR0030,  '1' })//019 - "Cancelamento de Cart�o de Credito"
aAdd(aDados,{StrZero(20,TamSx3('GZC_CODIGO')[1]),  STR0034,  '1' })//020 - "Devolu��o de Cart�o de Credito"
aAdd(aDados,{StrZero(21,TamSx3('GZC_CODIGO')[1]),  STR0035,  '1' })//021 - "Devolu��o de Cart�o de D�bito" 
aAdd(aDados,{StrZero(22,TamSx3('GZC_CODIGO')[1]),  STR0036,  '2' })//022 - "VENDAS TEF CR�DITO - TAXA"
aAdd(aDados,{StrZero(23,TamSx3('GZC_CODIGO')[1]),  STR0037,  '2' })//023 - "VENDAS TEF D�BITO  - TAXA"
aAdd(aDados,{StrZero(24,TamSx3('GZC_CODIGO')[1]),  STR0038,  '1' })//024 - "RECEITA DE ENCOMENDAS"
aAdd(aDados,{StrZero(25,TamSx3('GZC_CODIGO')[1]),  STR0039,  '2' })//025 - "DESPESAS COM ENCOMENDAS A FATURAR"
aAdd(aDados,{StrZero(26,TamSx3('GZC_CODIGO')[1]),  STR0042,  '3' })//026 - "DIFEREN�A FECHAMENTO NA FICHA "
aAdd(aDados,{StrZero(27,TamSx3('GZC_CODIGO')[1]),  STR0043,  '2' })//027 - "VENDAS POR PIX"
aAdd(aDados,{StrZero(28,TamSx3('GZC_CODIGO')[1]),  STR0044,  '2' })//028 - "COMISS�O NO PER�ODO DA FICHA"
aAdd(aDados,{StrZero(29,TamSx3('GZC_CODIGO')[1]),  STR0045,  '2' })//029 - "VENDAS POR DEP�SITO/ADIANTAMENTO"
      	  	  	  
GZC->(DbSetOrder(1))//GZC_FILIAL+GZC_CODIGO
For nX := 1 to Len(aDados)
	If !GZC->(DbSeek(xFilial('GZC')+aDados[nX][1]))
	
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oMdlGZC:SetValue('GZC_CODIGO'	,aDados[nX][1])
			oMdlGZC:SetValue('GZC_DESCRI'	,aDados[nX][2])
			oMdlGZC:SetValue('GZC_TIPO'		,aDados[nX][3])
			oMdlGZC:SetValue('GZC_MSBLQL'	,"2")
			oMdlGZC:SetValue('GZC_LANCX'	,Iif(oMdlGZC:GetValue('GZC_CODIGO') == '029', .T., .F.)) //Lancamento de Caixa
			oMdlGZC:SetValue('GZC_INCMAN'	,"2") //Permite a inclus�o manual dos registros na ficha? 1=Sim;2=N�o
			oMdlGZC:SetValue('GZC_PROPRI'	,"S") //Define que esses cadastros foram feito pelo sistema
			If oModel:VldData() 
				oModel:CommitData()
			EndIf
		EndIf
		
		oModel:Deactivate()
	
	EndIf
Next
oModel:Destroy()
RestArea(aArea)
GtpDestroy(aDados)

Return lRet

/*/{Protheus.doc} A420TPVldFld
Valida��o para vincular tipo de Receita e Despesa 
com o Tipo de Documentos (do Controle de Documentos)
Neste caso, o tipo de Receita e Despesa sempre ser�
"1- Receita"

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 15/07/2017
@version 

@type function
/*/
Static Function A420TPVldFld(oModelGZC)
Local lRet   := .T.
Local cTpDoc := oModelGZC:GetVAlue('GZC_TIPDOC')	
	
	If !Empty(cTpDoc)
		DbSelectArea("GZC")
		GZC->(DbSetOrder(2))
		If !GZC->(DbSeek(xFilial('GZC')+cTpDoc))
			oModelGZC:LoadValue('GZC_TIPO','1')
		Else 
			FWAlertHelp(STR0009, STR0010)
			lRet := .F.
		EndIf
	Else
		oModelGZC:SetValue('GZC_TIPO','')
	EndIf
	
Return lRet

/*/{Protheus.doc} GA420XBFIL
(long_description)
@type function
@author jacomo.fernandes
@since 04/03/2018
@version 1.0
@param cTipo, character, Informa qual o Tipo de filtro (1=Receita/2=Despesa)
@return ${return}, ${return_description}
@example
 @#GA420XBFIL('1')
@see (links_or_references)
/*/
Function GA420XBFIL(cTipo)
	Local cRet		:= "@#"
	Default cTipo	:= '1'
	
	
	If FwIsInCallStack('GTPA700JA')
		cRet += " ( GZC->GZC_TIPO = '1' .OR. GZC->GZC_TIPO = '3' ) "
		cRet += " .and.  GZC->GZC_LANCX = .T. "
	ElseIf FwIsInCallStack('GTPA700JB')  
		cRet += " ( GZC->GZC_TIPO = '2' .OR. GZC->GZC_TIPO = '3' ) "
		cRet += " .and.  GZC->GZC_LANCX = .T. "
	Else
		cRet += " ( GZC->GZC_TIPO = '"+cTipo+"' .OR. GZC->GZC_TIPO = '3' ) "
	Endif
	cRet += "@#"

Return cRet

/*/{Protheus.doc} GA420VldCod(oMdl, cField, cNewValue, cOldValue)
    Valida se c�digo digitado � valido
    @type  Static Function
    @author Flavio Martins
    @since 06/04/2018
    @version 1
    @param 
    @return lRet
    @example
    @see (links_or_references)
/*/
Static Function GA420VldCod(oMdl, cField, cNewValue, cOldValue)
Local lRet     := .T.

	If !FwIsInCallStack("GTPA420GZC")

		If cNewValue >= StrZero(1,3) .And. cNewValue <= StrZero(100,3)
	
			oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GA420VldCod",STR0031,STR0032)//#"C�digo digitado n�o pode ser utilizado."//#"Selecionado um c�digo fora do intervalo entre 001 e 100."
			lRet := .F.
	
		Endif
		
	Endif
	 
Return lRet

/*/{Protheus.doc} IntegDef
Fun��o respons�vel por acionar a integra��o via mensagem �nica do cadastro de Localidades.

Nome da mensagem: Locality
Fonte da Mensagem: GTPI420

@sample	IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )
 
@param		cXml			Texto da mensagem no formato XML.
@param		nTypeTrans		C�digo do tipo de transa��o que est� sendo executada.
@param		cTypeMessage	C�digo com o tipo de Mensagem. (DELETE ou UPSERT)
@param		cVersionRec	Vers�o da mensagem.

@return	aRet  			Array contendo as informa��es dos par�metros para o Adapter.
 
@author	Danilo Dias
@since		16/02/2016
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )

	Local aRet := {}

	aRet :=  GTPI420( cXML, nTypeTrans, cTypeMessage, cVersionRec )

Return aRet

