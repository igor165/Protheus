#include "MATA487.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

static _fakeView := FakeFormView():New()

Function MATA487(cAlias, cFilDoc, cNumDoc, cSerieDoc, cEsp) 
	Local aArea 			:= GetArea()
	Local oExecView			:= Nil 
	Local oModel			:= Nil

	dbSelectArea("A1X")
	dbSetOrder(1) //A1X_FILIAL+A1X_DOC+A1X_SERIE

	If A1X->(MsSeek(xFilial("A1X")+cNumDoc+cSerieDoc))	

	EndIf
	
	oModel := FWLoadModel("MATA487")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)

	oModel:Activate() 
	
	oView := FWLoadView("MATA487")
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_UPDATE) 
			  	
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0005) //"Complemento de Carta Porte"
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(MODEL_OPERATION_UPDATE)
	oExecView:OpenView(.T.)
	
	oModel:DeActivate()
	
	RestArea(aArea)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definición del modelo de datos
@author 	luis.enriquez
@return		oModel objeto del Model
@since 		27/08/2021
@version	12.1.17 / Superior
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruA1X	:= FWFormStruct( 1, 'A1X', /*bAvalCampo*/, /*lViewUsado*/ ) //Encabezado Carta Porte
	Local oStruA1Y 	:= FWFormStruct( 1, 'A1Y', /*bAvalCampo*/, /*lViewUsado*/ ) //Ubicaciones
	Local oStruA1Z 	:= FWFormStruct( 1, 'A1Z', /*bAvalCampo*/, /*lViewUsado*/ ) //Operadores
	Local oStruAE0 	:= FWFormStruct( 1, 'AE0', /*bAvalCampo*/, /*lViewUsado*/ ) //Propietarios
	Local aTrigA1X  := {}
	Local aTrigA1Z  := {}
	Local aTrigAE0  := {}
	LocAL nI        := 0
	Local bCommit   := { |oModel| .T. }

	//Crea el objeto del Modelo de Datos
	oModel := MPFormModel():New( 'MATA487' , , { |oMdl| M487POSVLD(oMdl) }, bCommit, /*bCancel*/ )
	//oModel := MPFormModel():New( 'MATA487', /*{ | oMdl | FISA833PRE(oMdl) }*//*bPreValidacao*/ , /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	aTrigA1X := M487TRA1X()  

	For nI :=1 To Len(aTrigA1X)
		oStruA1X:AddTrigger(aTrigA1X[nI][1],aTrigA1X[nI][2],aTrigA1X[nI][3],aTrigA1X[nI][4])
	Next nI

	aTrigA1Z := M487TRA1Z() 

	oStruA1Z:AddTrigger(aTrigA1Z[1],aTrigA1Z[2],aTrigA1Z[3],aTrigA1Z[4])

	aTrigAE0 := M487TRAE0()
	
	oStruAE0:AddTrigger(aTrigAE0[1],aTrigAE0[2],aTrigAE0[3],aTrigAE0[4])

	//Agrega una estructura de formulario de edición por campo a la plantilla para tabla A1X
	oModel:AddFields( 'A1XMASTER', /*cOwner*/, oStruA1X, /*bPreValidacao*/ )

	//Agreag al modelo una estructura de formulario de edición por grid para las tablas A1Y, A1Z y AE0.
	oModel:AddGrid( 'A1YDETAIL', 'A1XMASTER', oStruA1Y, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'A1ZDETAIL', 'A1XMASTER', oStruA1Z, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'AE0DETAIL', 'A1XMASTER', oStruAE0, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	//Hace relacionamiento entre los componentes del modelo
	oModel:SetRelation( 'A1YDETAIL', { { 'A1Y_FILIAL', 'xFilial( "A1X" )' }, { 'A1Y_DOC', 'A1X_DOC' }, { 'A1Y_SERIE', 'A1X_SERIE' } }, A1Y->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'A1ZDETAIL', { { 'A1Z_FILIAL', 'xFilial( "A1X" )' }, { 'A1Z_DOC', 'A1X_DOC' }, { 'A1Z_SERIE', 'A1X_SERIE' } }, A1Z->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'AE0DETAIL', { { 'AE0_FILIAL', 'xFilial( "A1X" )' }, { 'AE0_DOC', 'A1X_DOC' }, { 'AE0_SERIE', 'A1X_SERIE' } }, AE0->( IndexKey( 1 ) ) )

	//Ubicaciones
	oModel:GetModel( 'A1YDETAIL' ):SetUniqueLine( { 'A1Y_ITEM' } )
	oModel:GetModel( 'A1YDETAIL' ):SetUseOldGrid()

	//Operadores
	oModel:GetModel( 'A1ZDETAIL' ):SetUniqueLine( { 'A1Z_OPERAD' } )
	oModel:GetModel( 'A1ZDETAIL' ):SetUseOldGrid()
	oModel:GetModel( 'A1ZDETAIL' ):SetOptional(.T.)

	//Propietarios
	oModel:GetModel( 'AE0DETAIL' ):SetUniqueLine( { 'AE0_TRANSP' } )
	oModel:GetModel( 'AE0DETAIL' ):SetUseOldGrid()	
	oModel:GetModel( 'AE0DETAIL' ):SetOptional(.T.)

	oModel:SetPrimaryKey( {} ) 

	oModel:SetDescription(STR0001) //"Carta Porte"
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface del modelo de datos de configuración de responsabilidades RUT y tributos de clientes.
@param		Nenhum
@return		oView objeto del View
@author 	luis.enriquez
@since 		31/07/2019
@version	12.1.17 / Superior
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oStruA1X	:= FWFormStruct( 2, 'A1X' ) //Encabezado Carta Porte
	Local oStruA1Y	:= FWFormStruct( 2, 'A1Y' ) //Ubicaciones
	Local oStruA1Z	:= FWFormStruct( 2, 'A1Z' ) //Operadores
	Local oStruAE0	:= FWFormStruct( 2, 'AE0' ) //Propietarios
	Local oModel  	:= FWLoadModel( 'MATA487' )

	//Campos No Editables del grid A1X
	oStruA1X:SetProperty("A1X_DOC",MVC_VIEW_CANCHANGE,.F.)
	oStruA1X:SetProperty("A1X_SERIE" , MVC_VIEW_CANCHANGE, .F. )

	//Campos removididos del grid A1Y												
	oStruA1Y:RemoveField("A1Y_FILIAL")
	oStruA1Y:RemoveField("A1Y_DOC")
	oStruA1Y:RemoveField("A1Y_SERIE")
	oStruA1Y:RemoveField("A1Y_ESPECI")

	//Campos removididos del grid A1Z
	oStruA1Z:RemoveField("A1Z_FILIAL")
	oStruA1Z:RemoveField("A1Z_DOC")
	oStruA1Z:RemoveField("A1Z_SERIE")
	oStruA1Z:RemoveField("A1Z_ESPECI")

	//Campos removididos del grid AE0
	oStruAE0:RemoveField("AE0_FILIAL")
	oStruAE0:RemoveField("AE0_DOC")
	oStruAE0:RemoveField("AE0_SERIE")

	//Campos No Editables del grid A1Y, A1Z y AE0
	oStruA1Y:SetProperty("A1Y_ITEM",MVC_VIEW_CANCHANGE,.F.)
	oStruA1Z:SetProperty("A1Z_ITEM",MVC_VIEW_CANCHANGE,.F.)
	oStruAE0:SetProperty("AE0_ITEM",MVC_VIEW_CANCHANGE,.F.)

	oView := FWFormView():New()

	// Define cual es el Modelo de datos que será utilizado
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_A1X', oStruA1X, 'A1XMASTER' )
	oView:AddGrid(  'VIEW_A1Y', oStruA1Y, 'A1YDETAIL' )
	oView:AddGrid(  'VIEW_A1Z', oStruA1Z, 'A1ZDETAIL' )
	oView:AddGrid(  'VIEW_AE0', oStruAE0, 'AE0DETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 31 )
	oView:CreateHorizontalBox( 'DETA1Y', 23 )
	oView:CreateHorizontalBox( 'DETA1Z', 23 )
	oView:CreateHorizontalBox( 'DETAE0', 23 )

	// Relaciona el ID de los View con el box para exhibición
	oView:SetOwnerView( 'VIEW_A1X', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_A1Y', 'DETA1Y' )
	oView:SetOwnerView( 'VIEW_A1Z', 'DETA1Z' )
	oView:SetOwnerView( 'VIEW_AE0', 'DETAE0' )

	oView:EnableTitleView('VIEW_A1X','')
	oView:EnableTitleView('VIEW_A1Y',STR0002)  //"Ubicaciones"
	oView:EnableTitleView('VIEW_A1Z',STR0003)  //"Operadores"
	oView:EnableTitleView('VIEW_AE0',STR0004)  //"Propietarios/Arrendatarios"

	oStruA1X:SetNoFolder()

	oView:AddIncrementField( 'VIEW_A1Y', 'A1Y_ITEM' )
	oView:AddIncrementField( 'VIEW_A1Z', 'A1Z_ITEM' )
	oView:AddIncrementField( 'VIEW_AE0', 'AE0_ITEM' )

	oView:SetCloseOnOk({||.T.}) 

	oView:SetAfterViewActivate({|oView| M487VISTA(oView)}) 
Return(oView)

/*/{Protheus.doc} F827ORD
Obtiene el siguiente orden de una tabla 
@author luis.enriquez
@return		nProxOrdem
@since 31/07/2019
@version P12
/*/
Static Function M487ORD(cTabla)
	Local nProxOrdem:= 0
	Local aAreaSX3  := SX3->(GetArea())
	Local nOrden    := 0
	Local cOrden	:= ""
	
	// Verificando a ultima ordem utilizada
	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek(cTabla)
		Do While SX3->X3_ARQUIVO == cTabla  .And. !SX3->(Eof())
			cOrden := SX3->X3_ORDEM
			SX3->(dbSkip())
		Enddo
	Else
		cOrden := "00"
	EndIf
	
	SX3->(RestArea(aAreaSX3))
	
	nOrden    := RetAsc(cOrden,3,.F.)   //A0 -> 100
	nProxOrdem:= VAL(nOrden)+ 1
Return nProxOrdem

/*/{Protheus.doc} M487VISTA
Carga datos llave del documento para complemento de carta porte.
@author 	luis.enriquez
@since 		27/08/2021
@version	12.1.17 / Superior
/*/
Static Function M487VISTA(oView)
	Local oModel 	:= FWModelActivate() 
	Local oModelA1X := oModel:GetModel('A1XMASTER')
	Local nOpc      := oModel:GetOperation()
	Local cAccion	:= "oModelA1X:" + IIf(nOpc == 1, "LoadValue", "SetValue")

	&(cAccion+'("A1X_FILIAL", cFilDocCP)')	//cFilant
	&(cAccion+'("A1X_DOC", cNumDoCP)')		//M->F2_DOC
	&(cAccion+'("A1X_SERIE", cSerieCP)')	//M->F2_SERIE

	If nOpc == 4 .Or. nOpc == 1//Update o View
		M487VEHICU('V')
		M487VEHICU('R')
		M487OPERAD()
		M487PROARRE()
	EndIf

	oView:Refresh()	
Return .T.

/*/{Protheus.doc} M487TRA1X
Monta el gatillos para vehículo/remolque para Carta Porte
@author 	luis.enriquez
@since 		27/08/2021
@version	12.1.17 / Superior
/*/
Static Function M487TRA1X()
	Local aRet  := {}
	Local aRetV := {}
	Local aRetR := {}

	aRetV :=   FwStruTrigger(;
    "A1X_VEHIC" ,; // Campo Dominio
    "A1X_VEHIC" ,; // Campo de Contradominio
    "M487VEHICU('V')",; // Regra de Preenchimento
    .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
    "" ,; // Alias da tabela a ser posicionada
    0 ,; // Ordem da tabela a ser posicionada
    "" ,; // Chave de busca da tabela a ser posicionada
    NIL ,; // Condicao para execucao do gatilho
    "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro) 
	

	aAdd(aRet,aRetV) 

	aRetR :=   FwStruTrigger(;
    "A1X_REMOLQ" ,; // Campo Dominio
    "A1X_REMOLQ" ,; // Campo de Contradominio
    "M487VEHICU('R')",; // Regra de Preenchimento
    .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
    "" ,; // Alias da tabela a ser posicionada
    0 ,; // Ordem da tabela a ser posicionada
    "" ,; // Chave de busca da tabela a ser posicionada
    NIL ,; // Condicao para execucao do gatilho
    "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro) 

	aAdd(aRet,aRetR)
Return(aRet)

/*/{Protheus.doc} M487TRA1Z
Monta el gatillos de Conductores (Operadores) para Carta Porte
@author 	luis.enriquez
@since 		12/08/2021
@version	12.1.17 / Superior
/*/
Static Function M487TRA1Z()
	Local aRet  := {}

	aRet :=   FwStruTrigger(;
    "A1Z_OPERAD" ,; // Campo Dominio
    "A1Z_OPERAD" ,; // Campo de Contradominio
    "M487OPERAD()",; // Regra de Preenchimento
    .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
    "" ,; // Alias da tabela a ser posicionada
    0 ,; // Ordem da tabela a ser posicionada
    "" ,; // Chave de busca da tabela a ser posicionada
    NIL ,; // Condicao para execucao do gatilho
    "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro) 
Return(aRet)

/*/{Protheus.doc} M487TRAE0
Monta el gatillos de Transportistas para Carta Porte
@author 	luis.enriquez
@since 		12/08/2021
@version	12.1.17 / Superior
/*/
Static Function M487TRAE0()
	Local aRet  := {}

	aRet :=   FwStruTrigger(;
    "AE0_TRANSP" ,; // Campo Dominio
    "AE0_TRANSP" ,; // Campo de Contradominio
    "M487PROARRE()",; // Regra de Preenchimento
    .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
    "" ,; // Alias da tabela a ser posicionada
    0 ,; // Ordem da tabela a ser posicionada
    "" ,; // Chave de busca da tabela a ser posicionada
    NIL ,; // Condicao para execucao do gatilho
    "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro) 
Return(aRet)

Static Function MATA487GRV(oModel)
	Local lRet := .F.
	lRet := oModel:VldData()
Return lRet

/*/{Protheus.doc} M487VEHICU
Genera disparador para vehículo/remolque de complemento de Carta Porte CFDI 3.3 México
@type
@author luis.enríquez
@since 27/08/2021
@version 1.0
@param cOpc, caracter, Opción de disparador "V" retorna datos del vehículo y "R" del remolque.
@example
M487VEHICU(cOpc)
@see (links_or_references)
/*/
Function M487VEHICU(cOpc)
	Local oModel 	:= FWModelActivate() 
	Local oModelA1X := oModel:GetModel('A1XMASTER')
	Local cCampo    := IIf(cOpc == "V","A1X_VEHIC","A1X_REMOLQ")
	Local nOpc      := oModel:GetOperation()
	Local cAccion	:= 'oModelA1X:' + IIf(nOpc == 1, "LoadValue", "SetValue")

	dbSelectArea("DA3")
	DA3->(dbSetOrder(1)) //DA3_FILIAL + DA3_COD
	If DA3->(MsSeek(xFilial("DA3") + oModelA1X:GetValue(cCampo)))
		If cOpc == "V"	
			&(cAccion+'("A1X_PLACA", DA3->(DA3_PLACA))')
			&(cAccion+'("A1X_MODELO", DA3->(DA3_ANOMOD))')
			&(cAccion+'("A1X_CONFIG", DA3->(DA3_CONFIG))')
		ElseIf cOpc == "R"
			&(cAccion+'("A1X_SUBREM", DA3->(DA3_SUBREM))')
			&(cAccion+'("A1X_PLAREM", DA3->(DA3_PLACA))')
		EndIf
	EndIf
	//oView:Refresh()	
Return Nil

/*/{Protheus.doc} M487OPERAD
Genera disparador para Conductores (Operadores) de complemento de Carta Porte CFDI 3.3 México
@type
@author luis.enríquez
@since 27/08/2021
@version 1.0
@example
M487OPERAD()
@see (links_or_references)
/*/
Function M487OPERAD()
	Local oModel 	:= FWModelActivate() 
	Local oModelA1Z := oModel:GetModel('A1ZDETAIL')
	Local nTamMun   := GetSX3Cache("A1Z_MUNIC","X3_TAMANHO")
	Local nTamEdo   := GetSX3Cache("A1Z_ESTADO","X3_TAMANHO")
	Local nCP       := GetSX3Cache("A1Z_CP","X3_TAMANHO")
	Local cMunicip  := ""
	Local cEstado   := "" 
	Local cCP       := ""
	Local nOpc		:= oModel:GetOperation()
	Local cAccion	:= 'oModelA1Z:'+IIf(nOpc == 1, "LoadValue", "SetValue")
	Local nX		:= 0
	Local lCarga	:= IsInCallStack("M487VISTA") //Llamada de funcion al cargar ventana de Carta Porte
	Local nTam		:= IIf(lCarga, oModelA1Z:Length(), 1)

	dbSelectArea("DA4")
	DA4->(dbSetOrder(1)) //DA4_FILIAL + DA4_COD
	For nX := 1 To nTam
		If lCarga
			oModelA1Z:GoLine(nX)
		EndIf
		If DA4->(MsSeek(xFilial("DA4") + oModelA1Z:GetValue("A1Z_OPERAD")))
			&(cAccion+'("A1Z_NOMBRE", DA4->(DA4_NOME))')
			&(cAccion+'("A1Z_NOMBRE", DA4->(DA4_NOME))')
			&(cAccion+'("A1Z_RFC", DA4->(DA4_CGC))')
			&(cAccion+'("A1Z_LICENC", DA4->(DA4_NUMCNH))')
			&(cAccion+'("A1Z_CALLE", DA4->(DA4_END))')
			&(cAccion+'("A1Z_NUMEXT", DA4->(DA4_NUMEXT))')
			&(cAccion+'("A1Z_NUMINT", DA4->(DA4_NUMINT))')
			&(cAccion+'("A1Z_COLON", DA4->(DA4_CODBAI))')
			&(cAccion+'("A1Z_LOCAL", DA4->(DA4_LOCAL))')
			cMunicip := SubStr(DA4->(DA4_CODMUN),1,nTamMun)
			&(cAccion+'("A1Z_MUNIC", cMunicip)')
			cEstado := SubStr(DA4->(DA4_EST),1,nTamEdo)
			&(cAccion+'("A1Z_ESTADO", cEstado)')
			&(cAccion+'("A1Z_PAIS", DA4->(DA4_PAIS))')
			cCP := SubStr(DA4->(DA4_CEP),1,nCP)
			&(cAccion+'("A1Z_CP", cCP)')
		EndIf
	Next nX
	If lCarga //Mostrar modelo a partir de primer línea al cargar pantalla
		oModelA1Z:GoLine(1)
	EndIf
Return Nil

/*/{Protheus.doc} M487PROARRE
Genera disparador para Conductores (Operadores) de complemento de Carta Porte CFDI 3.3 México
@type
@author luis.enríquez
@since 27/08/2021
@version 1.0
@example
M487PROARRE()
@see (links_or_references)
/*/
Function M487PROARRE()
	Local oModel 	:= FWModelActivate() 
	Local oModelAE0 := oModel:GetModel('AE0DETAIL')
	Local nTamMun   := GetSX3Cache("AE0_MUNIC","X3_TAMANHO")
	Local nTamEdo   := GetSX3Cache("AE0_ESTADO","X3_TAMANHO")
	Local nCP       := GetSX3Cache("AE0_CP","X3_TAMANHO")
	Local cMunicip  := ""
	Local cEstado   := "" 
	Local cCP       := ""
	Local nOpc		:= oModel:GetOperation()
	Local cAccion	:= "oModelAE0:" + IIf(nOpc == 1, "LoadValue", "SetValue")
	Local nX		:= 0
	Local lCarga	:= IsInCallStack("M487VISTA") //Llamada de funcion al cargar ventana de Carta Porte
	Local nTam		:= IIf(lCarga, oModelAE0:Length(), 1)

	dbSelectArea("SA4")
	SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
	For nX := 1 To nTam
		If lCarga
			oModelAE0:GoLine(nX)
		EndIf
		If SA4->(MsSeek(xFilial("SA4") + oModelAE0:GetValue("AE0_TRANSP")))
			&(cAccion+'("AE0_NOMBRE", SA4->(A4_NOME))')
			&(cAccion+'("AE0_RFC", SA4->(A4_CGC))')
			&(cAccion+'("AE0_CALLE", SA4->(A4_END))')
			&(cAccion+'("AE0_NUMEXT", SA4->(A4_NUMEXT))')
			&(cAccion+'("AE0_NUMINT", SA4->(A4_NUMINT))')
			&(cAccion+'("AE0_COLON", SA4->(A4_CBAIRRO))')
			&(cAccion+'("AE0_LOCAL", SA4->(A4_CLOCALI))')
			cMunicip := SubStr(SA4->(A4_COD_MUN),1,nTamMun)
			&(cAccion+'("AE0_MUNIC", )')
			cEstado := SubStr(SA4->(A4_EST),1,nTamEdo)
			&(cAccion+'("AE0_ESTADO", cEstado)')
			&(cAccion+'("AE0_PAIS", SA4->(A4_CODPAIS))')
			cCP := SubStr(SA4->(A4_CEP),1,nCP)
			&(cAccion+'("AE0_CP", cCP)')
		EndIf
	Next nX
	If lCarga //Mostrar modelo a partir de primer línea al cargar pantalla
		oModelAE0:GoLine(1)
	EndIf
Return Nil

Function VldF3ICP(cCodigo,cCont1,nPos1,nPos2)
	Local lRet := .T.
	Local oModel    := Nil
	Local oModelDet := Nil
	Local cCampo	:= Alltrim(ReadVar())
	Local cValSeek  := ""
	Local cCpoCon   := ""
	Local cVlrCpo   := ""

	If (cCodigo == "S004" .And. cCampo $ "M->A1Y_CPORI|M->A1Y_CPDES") .Or. (cCodigo == "S023" .And. cCampo $ "M->A1Y_LOCORI|M->A1Y_LOCDES") ;
		.Or. (cCodigo == "S024" .And. cCampo $ "M->A1Y_MUNORI|M->A1Y_MUNDES")
		cCpoCon := IIf(cCampo $ "M->A1Y_CPORI|M->A1Y_LOCORI|M->A1Y_MUNORI","A1Y_EDOORI","A1Y_EDODES")
		oModel := FWModelActivate()
		oModelDet := oModel:GetModel('A1YDETAIL')
		cVlrCpo := oModelDet:GetValue(cCpoCon)
		cValSeek := cCont1 + cVlrCpo
	ElseIf cCodigo == "S015" .And. cCampo $ "M->A1Y_COLORI|M->A1Y_COLDES"
		cCpoCon := IIf(cCampo == "M->A1Y_COLORI","A1Y_CPORI","A1Y_CPDES")
		oModel := FWModelActivate()
		oModelDet := oModel:GetModel('A1YDETAIL')
		cVlrCpo := oModelDet:GetValue(cCpoCon)
		cValSeek := cCont1 + cVlrCpo
	EndIf

	lRet := ValidF3I(cCodigo,cValSeek,nPos1,nPos2)
Return lRet

/*/{Protheus.doc} M487COMMIT
Realiza Commit para llenado de tablas de Carta Porte A1X,A1Y,A1Z y AE0.
@type
@author luis.enríquez
@since 09/09/2021
@version 1.0
@example
M487COMMIT()
@see (links_or_references)
/*/
Function M487COMMIT()
	Local bCommit := {|| FWFormCommit(oModelAct)}
	Local lRetCom := .T.
	
	oModelAct:setCommit(bCommit)
	If (oModelAct:VldData())
		If (!oModelAct:CommitData())
			aError := oModelAct:GetErrorMessage()
		Else
			oModelAct := Nil
		EndIf
	Else
		aError := oModelAct:GetErrorMessage() 
	EndIf
Return lRetCom 

/*/{Protheus.doc} M487FAKECO
Realiza un fake Commit para llenado de tablas de Carta Porte A1X,A1Y,A1Z y AE0.
@type
@author luis.enríquez
@since 09/09/2021
@version 1.0
@example
M487FAKECO()
@see (links_or_references)
/*/
Function M487FAKECO(lCommit)
	Local oView := FWViewActive()
	Local lRetC := .T.
	Local nOpc  := oModelAct:GetOperation()

	Default lCommit := .F.

	oView:oViewOwner := _fakeView

	lRetC := oModelAct:VldData()
	If !lRetC
		aError := oModelAct:GetErrorMessage()
		If !Empty(aError[2])
			MsgAlert(aError[6])
			lRetCom := .F.
		EndIf	
	EndIf

	If lCommit
		If (nOpc == 3 .Or. nOpc == 4)  .And. lRetC //Update
			M487COMMIT()
		EndIf
	EndIf
Return lRetC

Class FakeFormView
	data lModify
	method new()	
endclass
method new() Class FakeFormView
Return

/*/{Protheus.doc} M487VLDUBI
Valida nomeclatura del campo A1Y_ORIGEN para que sea "OR"o "DE" según el tipo de ubicación (A1Y_TIPEST)
seguido de 6 dígitos númericos.
@type
@author luis.enríquez
@since 26/11/2021
@version 1.0
@example
M487VLDUBI()
@see (links_or_references)
/*/
Function M487VLDUBI()
	Local lRet      := .T.
	Local oModel 	:= FWModelActivate() 
	Local oModelA1Y := oModel:GetModel('A1YDETAIL')
	Local cOrigen   := oModelA1Y:GetValue("A1Y_ORIGEN")
	Local cTipUbi   := oModelA1Y:GetValue("A1Y_TIPEST")
	Local cPrefijo  := IIf(Alltrim(cTipUbi)=="O","OR","DE") 

	If !Empty(cOrigen)
		lRet := Substr(cOrigen,1,2) == cPrefijo .And. Val(Substr(cOrigen,3)) > 0
		If !lRet
			MsgAlert(StrTran(STR0006, '###', Alltrim(FWX3Titulo("A1Y_ORIGEN"))) + cPrefijo + STR0007) //"El campo ### (A1Y_ORIGEN), no cumple con la nomenclatura: " //" seguido de 6 dígitos numéricos."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} M487VLDDIS
Valida que el campo A1Y_DISREC sea informado si el tipo de ubicación es Destino (A1Y_TIPEST = 'D').
@type
@author luis.enríquez
@since 26/11/2021
@version 1.0
@example
M487VLDUBI()
@see (links_or_references)
/*/
Function M487VLDDIS()
	Local lRet := .T.
	Local oModel 	:= FWModelActivate() 
	Local oModelA1Y := oModel:GetModel('A1YDETAIL')
	Local cTipUbi := oModelA1Y:GetValue("A1Y_TIPEST")
	Local nDistan := oModelA1Y:GetValue("A1Y_DISREC")

	lRet := IIf(cTipUbi == "D", nDistan > 0, nDistan == 0)
	If !lRet
		If cTipUbi == "D"
			MsgAlert(StrTran(STR0008, '###', Alltrim(FWX3Titulo("A1Y_ORIGEN")))) //"El campo ### (A1Y_DISREC), deber ser mayor a cero para el Tipo de Ubicación de Destino"
		ElseIf cTipUbi == "O"
			MsgAlert(StrTran(STR0009, '###', Alltrim(FWX3Titulo("A1Y_ORIGEN")))) //"El campo ### (A1Y_DISREC), deber ser igual a cero para el Tipo de Ubicación de Origen"
		EndIf
	EndIf
Return lRet

Static Function M487POSVLD(oModel)
	Local lRet := .T.
	//Local oModel    := FWModelActive()
	Local oModelA1Z  := oModel:GetModel('A1ZDETAIL') //Operadores
	Local oModelAE0  := oModel:GetModel('AE0DETAIL') //Propietarios-Arrendatarios
	Local nOperation := oModel:GetOperation()
	Local nPosOpe    := aScan(oModelA1Z:aHeader, { |x,y| x[2] == "A1Z_OPERAD"	} )
	Local nPosProp   := aScan(oModelAE0:aHeader, { |x,y| x[2] == "AE0_TRANSP"	} )
	Local nTamOpe    := 0
	Local nTamProArr := 0
	Local nX         := 0
	Local lOperador  := .F.
	Local lPropArre  := .F.

	
	If nOperation == MODEL_OPERATION_INSERT  .Or. nOperation == MODEL_OPERATION_UPDATE
		//Grid Operadores
		nTamOpe    := Len(oModelA1Z:ACols)
		For nX:=1 To nTamOpe
			If !oModelA1Z:IsDeleted(nX) .And. !Empty(oModelA1Z:ACols[nX][nPosOpe])
				lOperador  := .T.
				Exit
			EndIf
		Next nX
		//Grid Propietarios-Arrendatarios
		nTamProArr := Len(oModelAE0:ACols)
		For nX:=1 To nTamOpe
			If !oModelAE0:IsDeleted(nX) .And. !Empty(oModelAE0:ACols[nX][nPosProp])
				lPropArre  := .T.
				Exit
			EndIf
		Next nX
		If !lOperador .And. !lPropArre
			lRet := .F.
			MsgAlert(STR0010) //"Es necesario informar al menos un Operador o Propietario/Arrendatario."
		EndIf
	EndIf
Return lRet
