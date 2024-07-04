#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA887.CH' 

PUBLISH MODEL REST NAME recibosTotvs  

/*/{Protheus.doc} FINA887
Fonte de cobros diversos (Padrão)
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Function FINA887()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	
	
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FJT')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FINA887' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.FINA887' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.FINA887' OPERATION 4 ACCESS 0 // 'Alterar'
	
Return aRotina


/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function ModelDef()
Local cCampSE1		:= "E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_SALDO,E1_DESCONT,E1_MULTA,E1_JUROS,E1_MOEDA,E1_CANCEL,E1_NATUREZ,E1_MOTIVO"
Local oStruFJT		:= FWFormStruct(1, 'FJT', , .F.)
Local oStruSEL		:= FWFormStruct(1, 'SEL', , .F.)
Local oStruSE1 		:= FWFormStruct(1, 'SE1', { | cCampo | AllTrim( cCampo ) $ cCampSE1  }, .F.)
Local oStruMOE		:= FWFormModelStruct():New()
Local oStruGEN		:= FWFormModelStruct():New()
Local oStruADM		:= FWFormModelStruct():New()
Local oStruFAC		:= FWFormModelStruct():New()

Local oModel		:= Nil 
Local oEvtTit		:= F887FIN():New()
Local oEvtCtb		:= F887CTB():New()
Local nPosTpDoc		:= 0
	
	oStruFJT:AddField("GERANCC","GERANCC","GERANCC",'C',1) 
	oStruFJT:AddField("DOCUMEN","DOCUMEN","DOCUMEN",'C',3) //Para generar saldo - Para México y Perú no es considerado el contenido informado.
	oStruFJT:AddField("ASIENTO","ASIENTO","ASIENTO",'N',1) //Muestra Asientos.
	oStruFJT:AddField("AGRUPA" ,"AGRUPA" ,"AGRUPA" ,'N',1) //Agrupa Asientos.
	oStruFJT:AddField("ONLINE" ,"ONLINE" ,"ONLINE" ,'N',1) //Agrupa Asientos.
	//Uso para Perú, sólo en sus eventos.
	oStruFJT:AddField("EMITCOM","EMITCOM","EMITCOM",'N',1)  //Emite comprobante
	oStruFJT:AddField("RUTCOM" ,"RUTCOM" ,"RUTCOM" ,'C',12) //Nombre rutina comprobante
	
	
	oStruSE1:AddField("BAIXAR       ","BAIXAR                   ","BAIXAR"	    ,'N',16,2,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	oStruSE1:AddField("RECNO        ","RECNO                    ","RECNO"	    ,'N',32 ,0,{||.T.},{||.T.},{},.F.,,.F.,.F.,.T.,)
	
	//Tabla de saldos y monedas
	oStruMOE:AddTable('' , { '' } , "SALDOMOEDA", {|| ''})
	oStruMOE:AddField('Moneda' 	, 'Moneda'	, 'MOEDA' 	, 'C' , 1)
	oStruMOE:AddField('Tasa' 	, 'Tasa' 	, 'TASA' 	, 'N' , 10, 2)
	oStruMOE:AddField('Recibido', 'Recibido', 'RECIBIDO', 'N' , 16, 2)
	oStruMOE:AddField('Saldo'	, 'Saldo'	, 'SALDO' 	, 'N' , 16, 2)

	//Tabla de datos generales
	oStruGEN:AddTable('' , { '' } , "GENERALES", {|| ''})
	oStruGEN:AddField('HourSave' 	, 'HourSave'	, 'HOURSAVERECEIPT' 	, 'C' , 8)

	//Tabla de administradoras financieras
	oStruADM:AddTable('', { '' }, "CAJAFINANCIERA",{|| ''})
	oStruADM:AddField('Codigo'		,'Codigo'		,'CODE'			,'C' ,6)
	oStruADM:AddField('Descripcion'	,'Descripcion'	,'DESCRIPTION'	,'C',30)

	//Tabla de factoraje
	oStruFAC:AddTable('', { '' }, "FACTORAJE",{|| ''})
	oStruFAC:AddField('Valor'		,'Valor'		,'VALUE'		,'N' ,16,2)
	oStruFAC:AddField('Valor'		,'Valor'		,'FACTOR'		,'C' ,1)
	
	oModel := MPFormModel():New( 'FINA887'/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	
	oModel:addFields('FJT_MASTER',,oStruFJT)
	
	oModel:addGrid('SEL_DETAIL','FJT_MASTER',oStruSEL,,)
	
	oModel:AddGrid('SE1_DETAIL','FJT_MASTER',oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	oModel:addGrid('MOE_DETAIL','FJT_MASTER',oStruMOE,,)

	oModel:addGrid('GEN_DETAIL','FJT_MASTER',oStruGEN,,)

	oModel:addGrid('ADM_DETAIL','FJT_MASTER',oStruADM,,)

	oModel:addGrid('FAC_DETAIL','FJT_MASTER',oStruFAC,,)
	
	oModel:SetRelation('SEL_DETAIL', { { 'EL_FILIAL', 'FWxFilial("SEL")' }, { 'EL_SERIE', 'FJT_SERIE' }, { 'EL_RECIBO', 'FJT_RECIBO' } }, SEL->(IndexKey(1)) )
	
	oModel:SetRelation( 'SE1_DETAIL', { { 'E1_FILIAL', 'xFilial( "SE1" )' }, { 'E1_CLIENTE', 'FJT_CLIENT' }, { 'E1_LOJA', 'FJT_LOJA' },  { 'E1_RECIBO', 'FJT_RECIBO'} }, SE1->( IndexKey( 1 ) ) )


	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "TB" })
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_ACREBAN'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_ENDOSSA'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TERCEIR'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_PREREC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_TRANSIT'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_SELDOC'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })
	oStruSEL:SetProperty( 'EL_RECIBO'	, 	MODEL_FIELD_INIT,	{|oModelGrid| "" })

	//Retirada de validaciones con variables privadas	
	oStruSEL:SetProperty( 'EL_TIPODOC'	, 	MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Pertence("|TB|") .Or. ' + GetSx3Cache("EL_TIPODOC","X3_VALID") ))
	oStruSEL:SetProperty( 'EL_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJA(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_LOJORIG'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887LOJORI(oModelGrid) } ) //ExistCPO
	oStruSEL:SetProperty( 'EL_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| FA887VALTP(oModelGrid,.F.) } ) //FA840VALTP
	oStruSEL:SetProperty( 'EL_BCOCHQ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| F887BCO("EL_BCOCHQ", .F.) } )
	
	oStruSE1:SetProperty( 'E1_TIPO'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa840Bco
	oStruSE1:SetProperty( 'E1_CLIENTE'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE,,,,.F.) .and. fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_LOJA'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //existcpo("SA1",M->E1_CLIENTE+M->E1_LOJA) .And. Fa040Num() .And. FA040Natur()
	oStruSE1:SetProperty( 'E1_MOEDA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) //Fa040moed().and.fa040Irf().And.FA040VALOR()                                                                                                                                                                                          
	oStruSE1:SetProperty( 'E1_NATUREZ'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_NUM'		, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PARCELA'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 
	oStruSE1:SetProperty( 'E1_PREFIXO'	, 	MODEL_FIELD_VALID,	{|oModelGrid| .T. } ) // 

	
	
	oStruSEL:SetProperty( 'EL_PREFIXO'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| .T. } ) //A840WHEN
	oStruSEL:SetProperty( 'EL_TPCRED'	, 	MODEL_FIELD_WHEN ,	{|oModelGrid| F887aWhen("TPCRED") } ) //a087awhen("TPCRED")

	nPosTpDoc := aScan(oStruSEL:aFields, {|x| x[3] == "EL_TIPODOC"})
	If nPosTpDoc > 0
		AADD(oStruSEL:aFields[nPosTpDoc][MODEL_FIELD_VALUES], "TB=TB" )
	EndIf
	
	//limpiado de disparadores
	oStruSEL:aTriggers := {}

	oStruSEL:SetProperty( '*' 			, 	MODEL_FIELD_OBRIGAT, .F.)
	oStruSE1:SetProperty( '*' 			, 	MODEL_FIELD_OBRIGAT, .F.)
	
	oStruFJT:SetProperty(  'FJT_VERSAO' , MODEL_FIELD_INIT, {|| '00' })
	oStruFJT:SetProperty(  'FJT_VERATU' , MODEL_FIELD_INIT, {|| '1' })
	oStruFJT:SetProperty(  'ASIENTO' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'AGRUPA' 	, MODEL_FIELD_INIT, {|| 2 })
	oStruFJT:SetProperty(  'ONLINE' 	, MODEL_FIELD_INIT, {|| 2 })

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel( 'SEL_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'SE1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'MOE_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'GEN_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'ADM_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'FAC_DETAIL' ):SetOptional(.T.)

	//Define que el submodelo permitirá la edición de datos.

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SE1_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('MOE_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('GEN_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('ADM_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('FAC_DETAIL'):SetOnlyQuery(.T.)
	

	oModel:SetPrimaryKey({'FJT_RECIBO','FJT_SERIE'})
	
	//Evento de actualizaciones financieras
	oModel:InstallEvent("F887FIN"	,/*cOwner*/,oEvtTit)
	 //Evento de lanzamientos contables
	oModel:InstallEvent("F887CTB"	,/*cOwner*/,oEvtCtb)	
	
Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización padrón
@return		oView objeto del View
@author 	raul.medina
@since 		05/04/2021
@version	12.1.27 / Superior
/*/
Static Function ViewDef()
Local oStruFJT	:= FWFormStruct( 2, 'FJT')
Local oStruSEL	:= FWFormStruct( 2, 'SEL')
Local oModel	:= FWLoadModel('FINA887')
Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('oStruFJT' , oStruFJT, 'FJT_MASTER' )
	oView:AddGrid('oStruSEL'  , oStruSEL, 'SEL_DETAIL')
	
	oView:CreateHorizontalBox( 'CIMA' , 50)
	oView:CreateHorizontalBox( 'BAIXO' , 50)
	
	oView:SetOwnerView('oStruFJT', 'CIMA')
	oView:SetOwnerView('oStruSEL', 'BAIXO')
	
Return oView

/*/{Protheus.doc} F887LOJA
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJA(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIENTE")
Local cLoja		:= oModelSEL:GetValue("EL_LOJA")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet 

/*/{Protheus.doc} F887LOJORI
Función para validación de Loja
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Static Function F887LOJORI(oModel)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cCliente	:= oModelSEL:GetValue("EL_CLIORIG")
Local cLoja		:= oModelSEL:GetValue("EL_LOJORIG")

	lRet := ExistCpo("SA1",cCliente+cLoja,1)
	
Return lRet


/*/{Protheus.doc} FA887VALTP
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/
Function FA887VALTP(oModel, lValid)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local aArea		:= {}
Local cConteudo	:= ""
Local aCheque	:= {}
	
IF lValid
	If AliasInDic("FJS")
		cConteudo	:= oModelSEL:GetValue("EL_TIPO")
		aArea := FJS->(GetArea())
		DbSelectArea("FJS")
		FJS->(DbSetOrder(1)) //FJS_FILIAL+FJS_TIPO
		If FJS->(DbSeek(xFilial("FJS")+PadR(cConteudo,GetSx3Cache("FJS_TIPO","X3_TAMANHO"))))  
			If !((ALLTRIM(FJS->FJS_BLOQ) == "2") .and. (ALLTRIM(FJS->FJS_CARTE) $ "1|3")) 
				lRet := .F.
				Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"
			EndIf
		Else
			lRet := .F.
			Help( " ", 1, "FANOTOPODOC",,STR0043,1,0)//"Não é possível utilizar este tipo de documento"	
		EndIf
		If lRet
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_ENDOSSA"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_ENDOSSA","2")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TERCEIR"}) > 0
				If FJS->FJS_CARTE $ "13" .AND. !SEL->(ColumnPos("EL_DOCPOS")) >0 
					oModelSEL:SetValue("EL_TERCEIR","1")
				EndIf
			EndIf
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == "EL_TRANSIT"}) > 0
				oModelSEL:SetValue("EL_TRANSIT",FJS->FJS_TRANS)
			EndIf
		EndIf
		FJS->(RestArea(aArea))
	EndIf
ENDIF

Return lRet

/*/{Protheus.doc} F887BCO
Función para validación de uso de tipo de documento
@param		oModel - Objeto del modelo
			lNoValid - Indica si debe realizar la validación (Uso para Argentina)
@return		lRet -  Resultado de la validación
@author 	raul.medina
@version	12.1.27 / Superior
@since 		07/04/2027
/*/

Function F887BCO(cCampo, lNoValid)
Local oModel 		:= FWModelActive()
Local oModelSEL 	:= oModel:GetModel( 'SEL_DETAIL' )
//--- Retorno
Local lRet := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 29/08/2012 : O campo Banco cheque eh comum para 2 rotinas, ³
	//³                                                            ³
	//³ Fina087a -> NAO deve efetuar a validacao chamado a tabela  ³
	//³             de Entidades bancarias                         ³
	//³ Fina840 -> sim, deve chamar a tabela Entidades bancarias   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
Local xConten := oModelSEL:GetValue(cCampo)
	
Default lNoValid := .F.
	
	If lNoValid
		//--- Se existir conteudo informado manualmente no campo EL_BCOCHQ
		If !Empty( xConten )
			aArea:=GetArea()       
       		If Empty( oModelSEL:GetValue("EL_AGECHQ") ) .OR. Empty( oModelSEL:GetValue("EL_POSTAL") ) .OR. oModelSEL:GetValue("EL_AGECHQ") <> FJN->FJN_AGENCI .OR. oModelSEL:GetValue("EL_POSTAL")  <> FJN->FJN_POSTAL
        		lRet := .F.
				oModel:SetErrorMessage('', '' , '' , '' , '', '', OemToAnsi( STR0047 )) // "Por favor, use a consulta padrão, de forma a preencher os campos de <Agencia> e <Codigo Postal>."  
			EndIf
		RestArea(aArea)
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} F887AWHEN
Validaciones correspondientes a campos

@type 		Method


@author 	raul.medina
@version	12.1.27 / Superior
@since		23/05/2021 
/*/
Function F887aWhen(cCampo)
Local oModel 	:= FWModelActive()
Local oModelSEL := oModel:GetModel( 'SEL_DETAIL' )
Local lRet		:= .T.
Local cTipoDoc	:= oModelSEL:GetValue("EL_TIPODOC")
Local cTipoCr	:= oModelSEL:GetValue("EL_TPCRED")
Local cCredInm	:= GetSESTipos({|| ES_RCOPGER == "1"},"1")

	cCredInm	:= IIf(Empty(cCredInm),"TF /EF /CC /CD ",cCredInm)
	
If cCampo == "TPCRED"
	If cTipoDoc $ cCredInm
		//Inmediato
		oModelSEL:LoadValue("EL_TPCRED","1")
	Else
		If cTipoDoc == "CHF"
			//Acreditación
			oModelSEL:LoadValue("EL_TPCRED","3")
		ELSEIF cTipoDoc == "DC"
			oModelSEL:LoadValue("EL_TPCRED","")
		ELSE
			//Fiscal
			oModelSEL:LoadValue("EL_TPCRED","4")
		EndIf
	EndIf
EndIf

Return lRet
