#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA312.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA312
Cadastro MVC de Periodo de Apuração

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA312()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Periodo de Apuração"
oBrw:SetAlias('CAH')
oBrw:SetMenuDef( 'TAFA312' )
CAH->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA312" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCAH  :=  FWFormStruct( 1, 'CAH' )
Local oModel    :=  MPFormModel():New( 'TAFA312' )

oModel:AddFields('MODEL_CAH', /*cOwner*/, oStruCAH)
oModel:GetModel('MODEL_CAH'):SetPrimaryKey({'CAH_FILIAL','CAH_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA312' )
Local   oStruCAH    :=  FWFormStruct( 2, 'CAH' )
Local   oView       :=  FWFormView():New()
 
oStruCAH:RemoveField('CAH_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAH', oStruCAH, 'MODEL_CAH' )

oView:EnableTitleView( 'VIEW_CAH', STR0001 )    //"Cadastro de Periodo de Apuração"
oView:CreateHorizontalBox( 'FIELDSCAH', 100 )
oView:SetOwnerView( 'VIEW_CAH', 'FIELDSCAH' )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "CAH_FILIAL" )
	aAdd( aHeader, "CAH_ID" )
	aAdd( aHeader, "CAH_CODIGO" )
	aAdd( aHeader, "CAH_DESCRI" )
	aAdd( aHeader, "CAH_DTINI" )
	aAdd( aHeader, "CAH_DTFIN" )

	aAdd( aBody, { "", "4aae06a9-6893-fe70-8da2-8b96f2d982cd", "A00", "ANUAL", "20130101", "" } )
	aAdd( aBody, { "", "03ba5f6e-952d-cc58-1ebd-223c696151d8", "A01", "REC. BRUTA DE JANEIRO /BALANCO SUSPENSAO REDUCAO ATE JANEIRO", "20130101", "" } )
	aAdd( aBody, { "", "79e6b003-8119-e57b-7c1d-4d2682bc8fe3", "A02", "REC. BRUTA DE FEVEREIRO /BALANCO SUSPENSAO REDUCAO ATE FEVEREIRO", "20130101", "" } )
	aAdd( aBody, { "", "bdf113e5-d934-d2af-cfc7-582189d55ac3", "A03", "REC. BRUTA DE MARCO /BALANCO SUSPENSAO REDUCAO ATE MARCO", "20130101", "" } )
	aAdd( aBody, { "", "b2abfe87-0e6b-fe37-928d-df3b3457391a", "A04", "REC. BRUTA DE ABRIL /BALANCO SUSPENSAO REDUCAO ATE ABRIL", "20130101", "" } )
	aAdd( aBody, { "", "015f3a79-de41-a067-e37e-f2f17a04e5bd", "A05", "REC. BRUTA DE MAIO /BALANCO SUSPENSAO REDUCAO ATE MAIO", "20130101", "" } )
	aAdd( aBody, { "", "75a46c8f-b97d-b863-984d-24655150f372", "A06", "REC. BRUTA DE JUNHO /BALANCO SUSPENSAO REDUCAO ATE JUNHO", "20130101", "" } )
	aAdd( aBody, { "", "1ce4dfba-3b47-b081-2e27-130aacf75b56", "A07", "REC. BRUTA DE JULHO /BALANCO SUSPENSAO REDUCAO ATE JULHO", "20130101", "" } )
	aAdd( aBody, { "", "2e5030c8-f35f-2c2d-c9ff-16b93f33de77", "A08", "REC. BRUTA DE AGOSTO /BALANCO SUSPENSAO REDUCAO ATE AGOSTO", "20130101", "" } )
	aAdd( aBody, { "", "513fe77b-2dcd-520f-2a86-b977e6e37509", "A09", "REC. BRUTA DE SETEMBRO /BALANCO SUSPENSAO REDUCAO ATE SETEMBRO", "20130101", "" } )
	aAdd( aBody, { "", "9972811b-554c-603e-7f36-7b798effb2b1", "A10", "REC. BRUTA DE OUTUBRO/BALANCO SUSPENSAO REDUCAO ATE OUTUBRO", "20130101", "" } )
	aAdd( aBody, { "", "2055f779-8d61-6e71-1b02-df8542226254", "A11", "REC. BRUTA DE NOVEMBRO /BALANCO SUSPENSAO REDUCAO ATE NOVEMBRO", "20130101", "" } )
	aAdd( aBody, { "", "a712cb44-03d3-0648-4a50-a07f0870feb3", "A12", "REC. BRUTA DE DEZEMBRO/BALANCO SUSPENSAO REDUCAO ATE DEZEMBRO", "20130101", "" } )
	aAdd( aBody, { "", "d0473a54-5476-1ab8-da1a-ccbc92cced12", "T01", "1º TRIMESTRE", "20130101", "" } )
	aAdd( aBody, { "", "593d5941-e463-e348-9f9b-adaf8f3d2ab9", "T02", "2º TRIMESTRE", "20130101", "" } )
	aAdd( aBody, { "", "acaec8a5-1992-b146-24e7-4b74087c5627", "T03", "3º TRIMESTRE", "20130101", "" } )
	aAdd( aBody, { "", "f9b12922-6ac8-1769-b4f0-3b610a37918a", "T04", "4º TRIMESTRE", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )