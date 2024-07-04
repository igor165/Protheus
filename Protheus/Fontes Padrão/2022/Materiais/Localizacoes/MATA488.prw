#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "MSGRAPHI.CH"
#INCLUDE 'MATA488.CH'
Static _oMAT884TMP
Static _nMAT884TOT
//Static oModelAct := Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA488
Fuente de Reembolsos
@author 	alfredo.medrano
@since 		10/08/2021
@version 12.1.17 / Superior
/*/
//-------------------------------------------------------------------
Function MATA488(cParam1, cParam2, cParam3, cParam4, cParam5, cParam6, cParam7,cParam8)
Local aArea			:= GetArea()
Local nOperation	:= 3
Local aChaveTmp1	:= {}
Local aChaveTmp2	:= {}
Local aChaveTmp3	:= {}
Local nSavN			:= N
Private cNumDocto	:= cParam1
Private cSerieDoc   := cParam2
Private cCliente    := cParam3
Private cTienda     := cParam4
Private cTipoReem   := cParam5
Private cLiqComp    := cParam6
Private cTipoCom    := cParam7
Private cModalid	:= cParam8
Private aHead488	:= {}
Private aCols488	:= {}
PRIVATE aStruTRB	:= {}

If ValType(aLlaveOrg) == "U"
	Private aLlaveOrg:= {}	
EndIf

_nMAT884TOT := 0

If !MT884VALCA() // valida campos necesarios de la factura de venta
	Return
EndIf

If Select("TRB1") == 0
	dbSelectArea("AQ0")
	aStruTRB := AQ0->(DbStruct())
	//Pegando a Chave 1 da tabela SEL para a chave da tabela temporaria
	aChaveTmp1 := {'AQ0_FILIAL','AQ0_SERIE','AQ0_DOC','AQ0_CLIENT','AQ0_TIENDA' }
	aChaveTmp2 := Strtokarr2( AQ0->(IndexKey(1)), "+" , .F.) // AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA+AQ0_ESTABL+AQ0_PTOEMI+AQ0_NUMDOC
	aChaveTmp3 := Strtokarr2( AQ0->(IndexKey(2)), "+" , .F.) //AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA+AQ0_ITEM
	//Criando o Objeto FwTemporaryTable
	_oMAT884TMP := FwTemporaryTable():New("TRB1")
	//Setando a estrutura da tabela temporaria
	_oMAT884TMP:SetFields(aStruTRB)
	//Criando o indicie da tabela temporaria
	_oMAT884TMP:AddIndex("1",aChaveTmp1)
	_oMAT884TMP:AddIndex("2",aChaveTmp2)
	_oMAT884TMP:AddIndex("3",aChaveTmp3)
	//Criando a Tabela temporaria
	_oMAT884TMP:Create()
	 AQ0->(dbCloseArea())
Else
	dbSelectArea("TRB1")
	dbSetOrder(1)//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA 
	If MsSeek(xFilial("AQ0")+cSerieDoc+cNumDocto+cCliente+cTienda)

		dbSelectArea("AQ0")
		AQ0->(dbSetOrder(1))//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA 
		AQ0->(MsSeek(xFilial("AQ0")+cSerieDoc+cNumDocto+cCliente+cTienda))

		nOperation := 4
	Endif
EndIf
	
//Respaldos de arrays de matxfis (Factura Venta) para poder utilizar las mafis en otra área de trabajo
aHead488:= AClone(aHeader) //copia del encabezado 
aCols488:=Aclone(aCols) // copia del detalle 
MaFisSave() //Respalda todos los arrays internos(utilizados por la Factura de Venta) en una area temporal para no afectar los mafis de la Factura.
MaFisEnd() // Termina todo uso de MATXFIS borrando TODAS los arrays internos para el árede Factura de Venta.
N := 1
MaFisIni("","","C","N","R") // inicia area de trabajo con mafis para los reembolsos

oModelAct := FWLoadModel("MATA488")
oModelAct:SetOperation( nOperation ) // Inclusão
oModelAct:Activate() // Ativa o modelo com os dados posicionados
FWExecView(STR0001,"MATA488",nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,,,,,)// "Reembolsos"
oModelAct:DeActivate()

MaFisClear() // Borra todos los elementos y restablece todos los totalizadores de encabezado de arrays internos de MATXFIS para el área de reembolsos.
MafisEnd() // Termina todo uso de MATXFIS borrando TODAS los arrays internos para el área de reembolsos.

aHeader:= AClone(aHead488) //Restaura los valores originales del enecabezado de la Factura
aCols :=Aclone(aCols488) //Restaura los valores originales del detalle de la Factura
N := nSavN
MaFisRestore() //Restaura los arrays internos de MATXFIS que contienen todos los datos almacenados por la función MaFisSave() del área temporal de la Factura de Venta

Inclui := .T. //Restablece el Inclui de la factura
If MaFisFound("IT",N) //verifica si existen items en la factura
	Eval(bDoRefresh) //Atualiza o folder financeiro.
	Eval(bListRefresh)
EndIF

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	alfredo.medrano
@since 		10/08/2021
@version 	12.1.17 / Superior
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
aRotina := FWMVCMenu( 'MATA488' )
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author 	alfredo.medrano
@return		oModel objeto del Model
@since 		10/08/2021
@version	12.1.17 / Superior
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local bCmpVisual:= {|cCampo| AllTrim(cCampo) $ "AQ0_FILIAL|AQ0_SERIE|AQ0_DOC|AQ0_CLIENT|AQ0_TIENDA"}
Local bCmpNoVisu:= {|cCampo| !(AllTrim(cCampo) $ "AQ0_FILIAL|AQ0_SERIE|AQ0_DOC|AQ0_CLIENT|AQ0_TIENDA")}
Local oStruAQ0	:= FWFormStruct( 1, 'AQ0',bCmpVisual )
Local oStruAQ0G	:= FWFormStruct( 1, 'AQ0', bCmpNoVisu )
Local aTrigger	:= {}
Local oModel

// Campos vistuales que mostraran la descripción 
	oStruAQ0G:AddField(	  ;      	// Ord. Tipo Desc.
	STR0003 			, ;      // [01]  C   Titulo do campo // "Descrip."
	STR0002 		    , ;      // [02]  C   ToolTip do campo // "Descripción"
	'AQ0_DSCR01'		, ;      // [03]  C   Id do Field
	'C'					, ;      // [04]  C   Tipo do campo
	30            		, ;      // [05]  N   Tamanho do campo
	0					, ;      // [06]  N   Decimal do campo
	NIL					, ;      // [07]  B   Code-block de validação do campo
	NIL					, ;      // [08]  B   Code-block de validação When do campo
	NIL            		, ;      // [09]  A   Lista de valores permitido do campo
	.F.            	 	, ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL    				, ;      // [11]  B   Code-block de inicializacao do campo
	NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
	NIL					, ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.             )        // [14]  L   Indica se o campo é virtual
	

	// Campos vistuales que mostraran la descripción 
	oStruAQ0G:AddField(	  ;      	// Ord. Tipo Desc.
	STR0003 			, ;      // [01]  C   Titulo do campo // "Descrip."
	STR0002 		    , ;      // [02]  C   ToolTip do campo // "Descripción"
	'AQ0_DSCR02'		, ;      // [03]  C   Id do Field
	'C'					, ;      // [04]  C   Tipo do campo
	60            		, ;      // [05]  N   Tamanho do campo
	0					, ;      // [06]  N   Decimal do campo
	NIL					, ;      // [07]  B   Code-block de validação do campo
	NIL					, ;      // [08]  B   Code-block de validação When do campo
	NIL            		, ;      // [09]  A   Lista de valores permitido do campo
	.F.            	 	, ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				    , ;      // [11]  B   Code-block de inicializacao do campo
	NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
	NIL					, ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.             )        // [14]  L   Indica se o campo é virtual


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'MATA488', /*{|oMdl| MT884PREE( oMdl )}*/, /*bPosValidacao*/,{ | oMdl | MT884COMM( oMdl ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'AQ0MASTER',, oStruAQ0 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'AQ0DETAIL', 'AQ0MASTER', oStruAQ0G , /*PREE*/,{|oModelGrid, nLine ,cAction,cField| MT884POS(oModelGrid, nLine, cAction, cField) }/*POS*/)

// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond,bInit,bForm)
oModel:AddCalc( 'CPOCALCAQ01', 'AQ0MASTER', 'AQ0DETAIL', 'AQ0_TOTAL', 'AQ0__TOT01', 'SUM', /*bCondition*/, /*bInitValue*/,'Total Reembolsos',/*bFormula*/) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'AQ0DETAIL', { { 'AQ0_FILIAL', 'xFilial( "AQ0" )' }, { 'AQ0_SERIE', 'AQ0_SERIE' } , { 'AQ0_DOC', 'AQ0_DOC' },;
 { 'AQ0_CLIENT', 'AQ0_CLIENT' }, { 'AQ0_TIENDA', 'AQ0_TIENDA' }}, AQ0->( IndexKey( 1 ) ) )

 // Indica que é opcional ter dados informados na Grid
oModel:GetModel("AQ0DETAIL"):SetOptional( .F. )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'AQ0DETAIL' ):SetUniqueLine( { 'AQ0_ESTABL','AQ0_PTOEMI','AQ0_NUMDOC' } ) 

oModel:SetPrimaryKey( {} ) 

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) // 'Reembolsos'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'AQ0MASTER' ):SetDescription( STR0001 ) // 'Reembolso'
oModel:GetModel( 'AQ0DETAIL' ):SetDescription( STR0004 ) //  'Detalle de Reembolso'

aTrigger := MAT488TRIG("AQ0_TIPDOC")  //Monta o gatilho dos campo AQ0_TIPDOC 
oStruAQ0G:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

aTrigger := MAT488TRIG("AQ0_TPDOC")  //Monta o gatilho dos campoAQ0_TPDOC
oStruAQ0G:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	alfredo.medrano
@since 		11/12/2017
@version	12.1.17 / Superior
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local bCmpVisual:= {|cCampo| AllTrim(cCampo) $ "AQ0_FILIAL|AQ0_SERIE|AQ0_DOC|AQ0_CLIENT|AQ0_TIENDA"}
Local bCmpNoVisu:= {|cCampo| !(AllTrim(cCampo) $ "AQ0_FILIAL|AQ0_SERIE|AQ0_DOC|AQ0_CLIENT|AQ0_TIENDA")}
// Cria a estrutura a ser usada na View
Local oStruAQ0	:= FWFormStruct( 2, 'AQ0', bCmpVisual)
Local oStruAQ0G := FWFormStruct( 2, 'AQ0',bCmpNoVisu)
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel	:= FWLoadModel( 'MATA488' )
Local oView

// Agregamos visualizador de descripcion de Docto identiad
	
	oStruAQ0G:AddField(			; 	      // Ord. Tipo Desc.
	'AQ0_DSCR01'				, ;      // [01]  C   Nome do Campo
	'07'         				, ;      // [02]  C   Ordem
	STR0003		                , ;      // [03]  C   Titulo do campo // Descrip.
	STR0002   			        , ;      // [04]  C   Descricao do campo // Descripción
	{ STR0005 }					, ;      // [05]  A   Array com Help // "Documento Identidad"
	'C' 						, ;      // [06]  C   Tipo do campo
	'@!'           				, ;      // [07]  C   Picture
	NIL            				, ;      // [08]  B   Bloco de Picture Var
	''             				, ;      // [09]  C   Consulta F3
	.f.							, ;      // [10]  L   Indica se o campo é alteravel
	NIL           				, ;      // [11]  C   Pasta do campo
	NIL            				, ;      // [12]  C   Agrupamento do campo
	NIL            				, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL            				, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL            				, ;      // [15]  C   Inicializador de Browse
	.T.             			, ;      // [16]  L   Indica se o campo é virtual
	NIL            				, ;      // [17]  C   Picture Variavel
	NIL            					)    // [18]  L   Indica pulo de linha após o campo

// Agregamos visualizador de descripcion de Tipo Comprobante
	oStruAQ0G:AddField(			; 	      // Ord. Tipo Desc.
	'AQ0_DSCR02'				, ;      // [01]  C   Nome do Campo
	'11'         				, ;      // [02]  C   Ordem
	STR0003		                , ;      // [03]  C   Titulo do campo // Descrip.
	STR0002   			        , ;      // [04]  C   Descricao do campo // Descripción
	{ STR0006 }					, ;      // [05]  A   Array com Help // "Tipo Comprobante"
	'C' 						, ;      // [06]  C   Tipo do campo
	'@!'           				, ;      // [07]  C   Picture
	NIL            				, ;      // [08]  B   Bloco de Picture Var
	''             				, ;      // [09]  C   Consulta F3
	.f.							, ;      // [10]  L   Indica se o campo é alteravel
	NIL           				, ;      // [11]  C   Pasta do campo
	NIL            				, ;      // [12]  C   Agrupamento do campo
	NIL            				, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL            				, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL            				, ;      // [15]  C   Inicializador de Browse
	.T.             			, ;      // [16]  L   Indica se o campo é virtual
	NIL            				, ;      // [17]  C   Picture Variavel
	NIL            					)    // [18]  L   Indica pulo de linha após o campo


//Desactiva la edición de los campos de la estructura oStruAQ0
oStruAQ0:SetProperty( 'AQ0_SERIE' , MVC_VIEW_CANCHANGE, .F. )
oStruAQ0:SetProperty( 'AQ0_DOC' , MVC_VIEW_CANCHANGE,  .F. )
oStruAQ0:SetProperty( 'AQ0_CLIENT' , MVC_VIEW_CANCHANGE, .F. )
oStruAQ0:SetProperty( 'AQ0_TIENDA' , MVC_VIEW_CANCHANGE,  .F. )
//Desactiva la edición de los campos de la estructura oStruAQ0G
oStruAQ0G:SetProperty( 'AQ0_ITEM' , MVC_VIEW_CANCHANGE,  .F. )
oStruAQ0G:SetProperty( 'AQ0_VALIMP' , MVC_VIEW_CANCHANGE,  .F. )
oStruAQ0G:SetProperty( 'AQ0_TOTAL' , MVC_VIEW_CANCHANGE, .F. )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_AQ0', oStruAQ0, 'AQ0MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEWDETAIL_AQ0', oStruAQ0G, 'AQ0DETAIL' )

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel( 'CPOCALCAQ01') )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_CALC', oCalc1, 'CPOCALCAQ01' )

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'MEDIO', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 20 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_AQ0', 'SUPERIOR'  )
oView:SetOwnerView( 'VIEWDETAIL_AQ0', 'MEDIO' )
oView:SetOwnerView( 'VIEW_CALC', 'INFERIOR' )
oView:EnableTitleView('VIEWDETAIL_AQ0' , STR0004 ) // 'Detalle de Reembolso' 
oView:EnableTitleView('VIEW_CALC' , STR0007 ) // "Total"
 
//Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEWDETAIL_AQ0', 'AQ0_ITEM' )

//función desde la validación del campo
// oView:SetFieldAction( 'AQ0_TIPDOC'	, { |oView| MAT488DESC(oView) } )
oView:SetFieldAction( 'AQ0_VALOR'	, { |oView| MAT488VAL(oView) } )
oView:SetFieldAction( 'AQ0_TES'	, { |oView| MAT488VAL(oView) } )
//oView:SetViewAction( 'BUTTONOK' 	, { |oView| MT884COMM( oView ) 	} )

//Seta um bloco de código que será chamado depois do Activate do View.
oView:SetAfterViewActivate({|oView| fPostView(oView)}) 

Return oView



/*/{Protheus.doc} MT884POS
Valida campos del reembolso 
@param		oModelGrid	, Objeto	, Modelo del Grid de datos
			nLine	    , Numerico	, Número Linea
			cAction 	, Carácter	, Accion Sobre la línea
			cField  	, Carácter	, Nombre Campo
@author 	Alfredo.Medrano
@since 		05/09/2021
@version	12.1.17 / Superior
/*/
static function MT884POS(oModelGrid, nLine, cAction, cField) 
Local lRet := .T.
Local cMsg := ""
Local cMsgCam:= ""

	If Empty(oModelGrid:GetValue('AQ0_TIPDOC'))
		cMsgCam += FWX3Titulo("AQ0_TIPDOC")  + Chr(13) + Chr(10) 
	EndIf 
	If Empty(oModelGrid:GetValue('AQ0_CGC'))  
		cMsgCam += FWX3Titulo("AQ0_CGC")  + Chr(13) + Chr(10)
	EndIf   
	If Empty(oModelGrid:GetValue('AQ0_PAIS'))  
		cMsgCam += FWX3Titulo("AQ0_PAIS")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_TPPROV'))
		cMsgCam += FWX3Titulo("AQ0_TPPROV")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_TPDOC'))
		cMsgCam += FWX3Titulo("AQ0_TPDOC")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_ESTABL'))
		cMsgCam += FWX3Titulo("AQ0_ESTABL")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_PTOEMI'))
		cMsgCam += FWX3Titulo("AQ0_PTOEMI")  + Chr(13) + Chr(10)
	Endif   
	If Empty(oModelGrid:GetValue('AQ0_NUMDOC'))
		cMsgCam += FWX3Titulo("AQ0_NUMDOC")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_FECHA'))
		cMsgCam += FWX3Titulo("AQ0_FECHA")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_AUTOR'))
		cMsgCam += FWX3Titulo("AQ0_AUTOR")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_TES'))
		cMsgCam += FWX3Titulo("AQ0_TES")  + Chr(13) + Chr(10)
	Endif
	If Empty(oModelGrid:GetValue('AQ0_VALOR'))
		cMsgCam += FWX3Titulo("AQ0_VALOR")  + Chr(13) + Chr(10)
	Endif
	IF cMsgCam!=""
		cMsg := STR0027  + Alltrim(STR(nLine)) + STR0028   + Chr(13) + Chr(10) // "Los campos de la línea " // " estan vacíos"
		cMsg +=  cMsgCam

		lRet:= .F.
		Help( ,, STR0030,, cMSG, 1, 0,,,,,, {STR0029} ) //"Aviso"//"Llenar los campos con la información que corresponde."
	
	Endif


Return lRet


/*/{Protheus.doc} MT884VALCA
Valida campos de la factura que se requieren en los reembolsos. 
@author 	Alfredo.Medrano
@since 		23/08/2021
@version	12.1.17 / Superior
/*/
Static Function MT884VALCA()
Local cMsgDt:= ""
Local cMsg 	:= ""
Local nMsg 	:= 0
Local lRet 	:= .T.

 
cMsg := STR0008 + Chr(13) + Chr(10) // "Para asignar un reembolso debe contar con la siguiente información :" + Chr(13) + Chr(10)  
cMsgDt := ""

If Empty(cNumDocto) 
	cMsgDt += STR0009 + Chr(13) + Chr(10) // "Número documento"
Endif
If Empty(cSerieDoc)
	cMsgDt += STR0010 + Chr(13) + Chr(10)// "Serie"  
Endif
If Empty(cCliente)
	cMsgDt += STR0011 + Chr(13) + Chr(10) // "Cliente"
Endif
If Empty(cTienda)
	cMsgDt += STR0012 + Chr(13) + Chr(10) //"Tienda"
Endif
If Empty(cModalid)
	cMsgDt += STR0026  + Chr(13) + Chr(10) //"Modalidad"
Endif
If cTipoReem != PadR("01",TamSX3("F2_TPDOC")[1])
	cMsgDt += STR0013 + " = " + STR0016 + Chr(13) + Chr(10) // "Tipo Reembolso" = //"01-Reembolso" 
Endif
If cLiqComp != "1"
	cMsgDt += STR0014 + " = " + STR0017 + Chr(13) + Chr(10) 	//"Liquidación de compra" = //"1-Si "
Endif
If cTipoCom != PadR("41",TamSX3("F2_TIPOPE")[1])
	cMsgDt += STR0015 + " = 41" + Chr(13) + Chr(10) 	// "Tipo Comprobante"
EndIf

If cMsgDt != "" 
	Help(" ",1, STR0030,, cMsg + cMsgDt, 1, 0,,,,,, {STR0029} ) // Aviso // "Llenar los campos con la información que corresponde."
	lRet := .F.
EndIf

If lRet
	If Len(aLlaveOrg) > 0 
		If aLlaveOrg[1][1] != cNumDocto
			nMsg++
		ElseIf aLlaveOrg[1][2] != cSerieDoc
			nMsg++
		ElseIf aLlaveOrg[1][3] != cCliente
			nMsg++
		ElseIf aLlaveOrg[1][4] != cTienda
			nMsg++
		EndIf

		If nMsg > 0 
			MATA488MOD() // actualiza datos en AQ0
			lRet := .T.	
		EndIf
	Else
		If !Empty(cNumDocto) .AND. !Empty(cSerieDoc) .AND. !Empty(cCliente) .AND. !Empty(cTienda)
			AADD(aLlaveOrg,{cNumDocto,cSerieDoc,cCliente,cTienda})
		EndIF
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} MT884COMM
Commit de los reembolsos. Agrega, modifica o borra registros del grid
y los refleja en la tabla temporal.
@param		oModel	, Objeto	, Modelo de datos
@author 	Alfredo.Medrano
@since 		23/08/2021
@version	12.1.17 / Superior
/*/
Static function MT884COMM(oModel)
Local oModel 		:= FWModelActive()
Local oMdlAQ0CAL	:= oModel:GetModel('CPOCALCAQ01')
Local oModelAQ0D	:= oModel:GetModel('AQ0DETAIL')
Local nOperation	:= oModel:GetOperation()
Local nX 			:= 0
Local lbanT 		:= .F.

Begin Transaction
//PREVAL(oModelAQ0D)

If nOperation == MODEL_OPERATION_INSERT 
	For nX:= 1 to oModelAQ0D:Length()
		oModelAQ0D:GoLine(nX)
		MT488INSRT(oModelAQ0D,.T.)//agrega registro a tabla temporal
	Next nX
	lbanT := .T.
ElseIf nOperation == MODEL_OPERATION_UPDATE	
	lbanT := .T.
	dbSelectArea("TRB1")	
	dbSetOrder(3)//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA+AQ0_ITEM
	For nX := 1 To oModelAQ0D:Length()
		oModelAQ0D:GoLine(nX)
		
		If oModelAQ0D:IsDeleted(nX)
			
			If MsSeek(xFilial("AQ0")+cSerieDoc+cNumDocto+cCliente+cTienda+oModelAQ0D:GetValue('AQ0_ITEM'))
				RecLock("TRB1", .F.)
				DbDelete()
				MsUnlock()
			EndIf

		ElseIf oModelAQ0D:IsUpdated(nX)
			
			If MsSeek(xFilial("AQ0")+cSerieDoc+cNumDocto+cCliente+cTienda+oModelAQ0D:GetValue('AQ0_ITEM'))
				MT488INSRT(oModelAQ0D,.F.)//modifica registro a tabla temporal
			Else
				MT488INSRT(oModelAQ0D,.T.)//Agrega registro a tabla temporal
			Endif
		Endif
	Next nX
Endif

_nMAT884TOT := oMdlAQ0CAL:GetValue('AQ0__TOT01') // recupera el total del reembolso 

End Transaction
return .T.

/*/{Protheus.doc} MT488INSRT
Agrega o modifica registro a la tabla temporal
@param		oModelAQ0D	, Objeto	, Modelo del Grid de datos
			lAccion	    , Logico	, Indica Inserción o Edición a tabla Temporal
@author 	Alfredo.Medrano
@since 		23/08/2021
@version	12.1.17 / Superior
/*/
Static Function MT488INSRT(oModelAQ0D,lAccion)

If ValType(lAccion)  == "L"
	
	RecLock("TRB1",lAccion)
	TRB1->AQ0_FILIAL := xfilial('AQ0')
	TRB1->AQ0_ITEM 	:=oModelAQ0D:GetValue('AQ0_ITEM')    
	TRB1->AQ0_SERIE	:=cSerieDoc
    TRB1->AQ0_DOC	:=cNumDocto
    TRB1->AQ0_CLIENT:=cCliente
	TRB1->AQ0_TIENDA:=cTienda  
	TRB1->AQ0_TIPDOC:=oModelAQ0D:GetValue('AQ0_TIPDOC')
	TRB1->AQ0_CGC 	:=oModelAQ0D:GetValue('AQ0_CGC')   
	TRB1->AQ0_PAIS 	:=oModelAQ0D:GetValue('AQ0_PAIS')
	TRB1->AQ0_TPPROV:=oModelAQ0D:GetValue('AQ0_TPPROV')
	TRB1->AQ0_TPDOC :=oModelAQ0D:GetValue('AQ0_TPDOC')
	TRB1->AQ0_ESTABL:=oModelAQ0D:GetValue('AQ0_ESTABL')
	TRB1->AQ0_PTOEMI:=oModelAQ0D:GetValue('AQ0_PTOEMI')    
	TRB1->AQ0_NUMDOC:=oModelAQ0D:GetValue('AQ0_NUMDOC')
	TRB1->AQ0_FECHA :=oModelAQ0D:GetValue('AQ0_FECHA')
	TRB1->AQ0_AUTOR	:=oModelAQ0D:GetValue('AQ0_AUTOR')
	TRB1->AQ0_TES 	:=oModelAQ0D:GetValue('AQ0_TES')
	TRB1->AQ0_VALOR :=oModelAQ0D:GetValue('AQ0_VALOR')
	TRB1->AQ0_VALIMP:=oModelAQ0D:GetValue('AQ0_VALIMP')
	TRB1->AQ0_TOTAL :=oModelAQ0D:GetValue('AQ0_TOTAL')   
	TRB1->(MsUnlock())
Endif

Return

/*/{Protheus.doc} MAT488VAL
Obtiene el impuesto y valor bruto del reembolso despues de 
seleccionar el campo AQ0_TES y AQ0_VALOR
@param		oView	, Objeto	, Vista de datos
@author 	Alfredo.Medrano
@since 		18/08/2021
@version	12.1.17 / Superior
/*/
Static function MAT488VAL(oView)
	Local aArea 	:= GetArea()
	Local oModel 	:= FWModelActive()
	Local oModelAQ0D:= oModel:GetModel('AQ0DETAIL')
	Local nVlTotal	:= 0
	Local nVlImp	:= 0
	Local cTESvl	:= ""
	Local cCamTip 	:=  alltrim(substr(ReadVar(), 4, len(ReadVar())))
	Local nValor 	:= 0

	If cCamTip == 'AQ0_TES'
		nValor := oModelAQ0D:GetValue('AQ0_VALOR')
		cTESvl := M->AQ0_TES
	ElseIf cCamTip == 'AQ0_VALOR'
		nValor := M->AQ0_VALOR
		cTESvl := oModelAQ0D:GetValue('AQ0_TES')
	Endif
	
	If !Empty(cTESvl) .and. !Empty(nValor)
		MaFisRef("IT_TES","MT100",cTESvl)
		MaFisRef("IT_VALMERC","MT100",nValor)
		nVlTotal:= MaFisRet(n,"IT_TOTAL") 
		If nVlTotal > 0
			nVlImp := nVlTotal - nValor
		EndIf
	EndIf
	
	oModelAQ0D:LoadValue('AQ0_VALIMP', nVlImp )
	oModelAQ0D:SetValue('AQ0_TOTAL', nVlTotal )

	oView:Refresh()	
		
	RestArea(aArea)
Return


/*/{Protheus.doc} fPostView
Función llamada después de la activación de la Vista.
Inicializa los valores para la Edición y Visualización del documento.
@author 	alfredo.medrano
@param		oView - objeto de la Vista
@return		Boolean
@since 		07/08/2021
@version	12.1.17 / Superior
/*/
Function fPostView(oView)
	Local aArea 		:= GetArea()
	Local oModel 	    := FWModelActivate()
    Local oModelAQ0M    := oModel:GetModel('AQ0MASTER')
	Local oModelAQ0D	:= oModel:GetModel('AQ0DETAIL')
	Local nOperation    := oModel:GetOperation()
	Local oMdlAQ0CAL	:= oModel:GetModel('CPOCALCAQ01')
	Local cValCam		:= ""
	Local cTrans		:= ""
	Local cIdent		:= ""
	Local nX            := 0
	Local nJ			:= 0
	Local nLinhaAQ0 	:= 0
	Local cLlave 		:= ""
	

    oModelAQ0M:LoadValue("AQ0_SERIE", cSerieDoc)
    oModelAQ0M:LoadValue("AQ0_DOC", cNumDocto)
    oModelAQ0M:LoadValue("AQ0_CLIENT", cCliente)
    oModelAQ0M:LoadValue("AQ0_TIENDA", cTienda)

	If nOperation == 4 	
		nLinhaAQ0 := 1
		If Select("TRB1") > 0
			cLlave := xFilial("AQ0")+cSerieDoc+cNumDocto+cCliente+cTienda
			DbSelectArea("TRB1")
			TRB1->( DbSetOrder(1) )//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA
			If TRB1->( MSSEEK(cLlave) )
				
				Do While TRB1->(!Eof()) .and. TRB1->(AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA) == cLlave
					nJ++
					If nLinhaAQ0 > 1
						If oModelAQ0D:AddLine() <> nLinhaAQ0
							//Help( ,, 'HELP',, 'Nao incluiu linha ZA1' + CRLF + oModel:getErrorMessage()[6], 1, 0)   
							TRB1->( dbSkip() )
							Loop			
						EndIf
					EndIf
					
					oModelAQ0D:LoadValue('AQ0_ITEM', TRB1->AQ0_ITEM)	
					oModelAQ0D:LoadValue('AQ0_TIPDOC', TRB1->AQ0_TIPDOC)
					oModelAQ0D:LoadValue('AQ0_CGC', TRB1->AQ0_CGC)	
					oModelAQ0D:LoadValue('AQ0_PAIS', TRB1->AQ0_PAIS)
					oModelAQ0D:LoadValue('AQ0_TPPROV', TRB1->AQ0_TPPROV)
					oModelAQ0D:LoadValue('AQ0_TPDOC', TRB1->AQ0_TPDOC)
					oModelAQ0D:LoadValue('AQ0_ESTABL', TRB1->AQ0_ESTABL)
					oModelAQ0D:LoadValue('AQ0_PTOEMI', TRB1->AQ0_PTOEMI)	
					oModelAQ0D:LoadValue('AQ0_NUMDOC', TRB1->AQ0_NUMDOC)
					oModelAQ0D:LoadValue('AQ0_FECHA', TRB1->AQ0_FECHA )
					oModelAQ0D:LoadValue('AQ0_AUTOR', TRB1->AQ0_AUTOR )
					oModelAQ0D:LoadValue('AQ0_TES', TRB1->AQ0_TES)
					oModelAQ0D:LoadValue('AQ0_VALOR', TRB1->AQ0_VALOR  )
					oModelAQ0D:LoadValue('AQ0_VALIMP', TRB1->AQ0_VALIMP )
					oModelAQ0D:SetValue('AQ0_TOTAL', TRB1->AQ0_TOTAL)		
					nLinhaAQ0++
					TRB1->( dbSkip() )
				EndDo

			EndIF
		ENdIf

		For nX:= 1 to oModelAQ0D:Length()
			oModelAQ0D:GoLine(nX)
			MaFisIniLoad(nX)	
			cValCam	:= oModelAQ0D:GetValue("AQ0_TIPDOC")
			cTrans := ObtColSAT("S002",cValCam ,1,2,3,30)
			cIdent := ObtColSAT("S002",cValCam ,1,2,31,32)
			oModelAQ0D:LoadValue('AQ0_DSCR01', cTrans + " " + cIdent)

			cValCam	:= oModelAQ0D:GetValue("AQ0_TPDOC")
			cTrans := ObtColSAT("S004",cValCam ,1,3,4,75)
			oModelAQ0D:LoadValue('AQ0_DSCR02', cTrans)	
			MaFisEndLoad(nX,3)
		Next nX

		_nMAT884TOT := oMdlAQ0CAL:GetValue('AQ0__TOT01') // recupera el total del reembolso 

	EndIf	
	
	oModelAQ0D:GoLine(1)
	oView:Refresh()		
	RestArea(aArea)
Return

/*/{Protheus.doc} MAT488TRIG
Actualiza los datos AQ0_SERIE, AQ0_DOC, AQ0_CLIENT, AQ0_TIENDA de 
la tabla temporal en casos de que estos datos hayan cambiado en la factura
@author 	Alfredo.Medrano
@since 		25/08/2021
@version	12.1.17 / Superior
/*/
Static Function MATA488MOD()
Local aArea := GetArea()
Local aRecC := {}
Local nX 	:= 0
Local cLlave:= ""

	If Len(aLlaveOrg) > 0
		cLlave := xFilial("AQ0")+aLlaveOrg[1][2]+aLlaveOrg[1][1] +aLlaveOrg[1][3]+aLlaveOrg[1][4]
		If Select("TRB1") > 0	
			DbSelectArea("TRB1")
			TRB1->( DbSetOrder(1) )//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA
			If TRB1->( DbSeek(cLlave) )
				While TRB1->(!Eof()) .and. TRB1->(AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA) == cLlave
					AADD(aRecC,{TRB1->(Recno())})
					TRB1->( dbSkip() )
				EndDo

				For nX := 1 to Len(aRecC) 
					TRB1->( DbGoTo( aRecC[nX][1] ) )
					RecLock("TRB1",.F.)
					TRB1->AQ0_SERIE	:=cSerieDoc
				    TRB1->AQ0_DOC	:=cNumDocto
				    TRB1->AQ0_CLIENT:=cCliente
					TRB1->AQ0_TIENDA:=cTienda
					TRB1->(MsUnlock())
				Next nX
					
				aLlaveOrg:={}
				AADD(aLlaveOrg,{cNumDocto,cSerieDoc,cCliente,cTienda})

			EndIf
		EndIf
	EndIf
RestArea(aArea)
Return

/*/{Protheus.doc} MAT488TRIG
Monta el gatillo para los campos AQ0_TIPDOC y AQ0_TPDOC.
@param		cCampoG	, Carácter	, Nombre Campo
@author 	Alfredo.Medrano
@since 		16/08/2021
@version	12.1.17 / Superior
/*/
Static Function MAT488TRIG(cCampoG)
	Local aRet   :=Nil
	Local cDom   :=""
	Local cCDom  :=""
	Local cRegra :=""
	Local lSeek  :=.f.
	Local cAlias :=""
	Local nOrdem :=0
	Local cChave :=""
	Local cCondic:=Nil
	Local cSequen:="01"
	
	cDom  := cCampoG
	If cDom == "AQ0_TIPDOC"
		cCDom :="AQ0_DSCR01"
		cRegra:='Alltrim(ObtColSAT("S002",AllTrim(M->AQ0_TIPDOC) ,1,2,3,30) + " " + ObtColSAT("S002",AllTrim(M->AQ0_TIPDOC) ,1,2,31,32))'
	ElseIf 	cDom == "AQ0_TPDOC"
		cCDom :="AQ0_DSCR02"
		cRegra:='Alltrim( ObtColSAT("S004",AllTrim(M->AQ0_TPDOC) ,1,3,4,75))'
	Endif
	
	aRet :=FwStruTrigger(cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic, cSequen)

Return(aRet)


/*/{Protheus.doc} MAT488VLD
Valida información necesaria antes de guardar la Factura 
@param		nValbrutC	, Numerico	, Valor total de la factura
			cTipoReem 	, Carácter	, Tipo Reembolso 
			cLiqComp  	, Carácter	, Liquidación de compra
			cTipoCom  	, Carácter	, Tipo Comprobante	
			cModalid  	, Carácter	, Modalidad
@author 	Alfredo.Medrano
@since 		24/08/2021
@version	12.1.17 / Superior
/*/
Function MAT488VLD(nValbrutC,cTipoReem,cLiqComp,cTipoCom,cModalid)
Local lRet 	:= .T.
Local cMsg 	:= ""
Local cMsgDt:= ""
Local cMsgNr:= ""

Default nValbrutC := 0

If cTipoReem != PadR("01",TamSX3("F2_TPDOC")[1])
	cMsgDt += " - " + STR0013 + Chr(13) + Chr(10)// Tipo Reembolso 
Endif
If cLiqComp != "1"
	cMsgDt += " - " + STR0014 + Chr(13) + Chr(10) // Liquidación de compra  	
Endif
If cTipoCom != PadR("41",TamSX3("F2_TIPOPE")[1])
	cMsgDt += " - " + STR0015  + Chr(13) + Chr(10) //Tipo Comprobante	
EndIf
If Empty(cModalid)
	cMsgDt += " - " + STR0026  + Chr(13) + Chr(10) //Tipo Comprobante	
Endif

cMsgNr := STR0018  + Chr(13) + Chr(10) //"Documento de tipo Reembolso. "
cMsgNr += STR0019  + Chr(13) + Chr(10) //"No hay reembolsos asignados a la factura." 
cMsgNr += STR0020  //"¿Desea continua? "


If Select("TRB1") > 0 .and. len(aLlaveOrg) > 0
	cLlave := xFilial("AQ0")+aLlaveOrg[1][2]+aLlaveOrg[1][1] +aLlaveOrg[1][3]+aLlaveOrg[1][4]
	DbSelectArea("TRB1")
	TRB1->( DbSetOrder(1) )//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA
	If TRB1->( MsSeek(cLlave))

		If cMsgDt != "" 
		
			cMsg := STR0021 + Chr(13) + Chr(10) //"El documento tiene reembolsos relacionados pero ha cambiado su información."
			cMsg += Chr(13) + Chr(10)
			cMsgDt += Chr(13) + Chr(10) +STR0022 + " " + STR0020 // "Si continua, los reembolsos relacionados se perderán." // "¿Desea continua? "
			
			If MsgYESNO(cMsg + cMsgDt,STR0023 ) //Atención 
				MAT488END() //elimina tabla temporal y limpia variables privadas y estaticas
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
		
			If nValbrutC > 0
				If nValbrutC <> _nMAT884TOT
					Aviso(STR0023 ,STR0024 ,{STR0025}) //"Atención" //"El total del reembolso debe ser igual al total de la factura."// Ok
					lRet := .F.
				Endif
			Endif

		EndIf
	
	Else
		If MsgYESNO(cMsgNr)
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Endif
Endif

Return lRet


/*/{Protheus.doc} MAT488AQ0
Guarda los reembolsos en tabla AQ0
@param		cFsDoc 	    , Carácter	, Núm Docto Factura
			cFsSerie  	, Carácter	, Serie
			cFsClient  	, Carácter	, Cliente
			cFsLoja  	, Carácter	, Tienda
			cTipoReem 	, Carácter	, Tipo Reembolso 
			cLiqComp  	, Carácter	, Liquidación de compra
			cTipoCom  	, Carácter	, Tipo Comprobante	
@author 	Alfredo.Medrano
@since 		25/08/2021
@version	12.1.17 / Superior
/*/

Function MAT488AQ0(cFsDoc, cFsSerie, cFsClient, cFsLoja,cTipoReem,cLiqComp,cTipoCom) 
Local cLlave 		:= ""
Local lTrns 		:= .T. 
If ValType(aLlaveOrg) == "U"
	 aLlaveOrg:= {}	
EndIf

//verifica que factura contenga reembolso
If SF2->F2_TPDOC != PadR("01",TamSX3("F2_TPDOC")[1]) .and. SF2->F2_TPVENT != "1" .and. SF2->F2_TIPOPE != PadR("41",TamSX3("F2_TIPOPE")[1])
	Return .F.
Endif

If Len(aLlaveOrg) > 0
	cLlave := xFilial("AQ0")+aLlaveOrg[1][2]+aLlaveOrg[1][1] +aLlaveOrg[1][3]+aLlaveOrg[1][4]

	If Select("TRB1") > 0 .and. SF2->F2_DOC != "" .and. SF2->F2_SERIE != "" .and.  SF2->F2_CLIENTE != "" .and.  SF2->F2_LOJA != "" 
		DbSelectArea("AQ0")
		DbSelectArea("TRB1")
		TRB1->( DbSetOrder(1) )//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA
		If TRB1->( MSSEEK(cLlave) )
		
			Do While TRB1->(!Eof())	.and. TRB1->(AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA) == cLlave
				RecLock("AQ0",.T.)
				AQ0->AQ0_FILIAL := xfilial('AQ0')
				AQ0->AQ0_ITEM 	:= TRB1->AQ0_ITEM     
				AQ0->AQ0_SERIE	:= SF2->F2_SERIE
				AQ0->AQ0_DOC	:= SF2->F2_DOC 
				AQ0->AQ0_CLIENT := SF2->F2_CLIENTE
				AQ0->AQ0_TIENDA := SF2->F2_LOJA
				AQ0->AQ0_TIPDOC := TRB1->AQ0_TIPDOC
				AQ0->AQ0_CGC 	:= TRB1->AQ0_CGC 
				AQ0->AQ0_PAIS 	:= TRB1->AQ0_PAIS
				AQ0->AQ0_TPPROV	:= TRB1->AQ0_TPPROV
				AQ0->AQ0_TPDOC 	:=TRB1->AQ0_TPDOC
				AQ0->AQ0_ESTABL	:=TRB1->AQ0_ESTABL
				AQ0->AQ0_PTOEMI	:=TRB1->AQ0_PTOEMI
				AQ0->AQ0_NUMDOC	:=TRB1->AQ0_NUMDOC
				AQ0->AQ0_FECHA 	:=TRB1->AQ0_FECHA
				AQ0->AQ0_AUTOR	:=TRB1->AQ0_AUTOR
				AQ0->AQ0_TES 	:=TRB1->AQ0_TES 
				AQ0->AQ0_VALOR 	:=TRB1->AQ0_VALOR
				AQ0->AQ0_VALIMP	:=TRB1->AQ0_VALIMP
				AQ0->AQ0_TOTAL 	:=TRB1->AQ0_TOTAL
				AQ0->(MsUnlock())

				TRB1->( dbSkip() )
			EndDo
		EndIf

	 lTrns := MT884CNTS() // baja de cuenta por cobrar y alta de cuenta por pagar

	EndIf
Endif

MAT488END()//inicializa variables y elimina tabla temporal

Return lTrns


/*/{Protheus.doc} MAT488END
Elimina tabla temporal despues de guardar o cancelar la factura
@author 	Alfredo.Medrano
@since 		24/08/2021
@version	12.1.17 / Superior
/*/
Function MAT488END()
	//Limpia variable llave de Factura
	aLlaveOrg := {}
	//Limpia variable totalizador
	_nMAT884TOT := 0
	// Elimina tabla temporal
	If(_oMAT884TMP <> NIL)
		_oMAT884TMP:Delete()
		_oMAT884TMP := NIL
	EndIf
Return

/*/{Protheus.doc} MAT488DEL
Elimina los reembolsos en tabla AQ0 y la cuenta por pagar(SE2) cuando se elimina la factura
@author 	Alfredo.Medrano
@since 		08/09/2021
@version	12.1.17 / Superior
/*/
Function MAT488DEL() 
Local lTrns 	:= .T.
Local cLlave	:= ""
Local aBaixa	:= {}
Local cCodProvS	:= ""
Local cLojaS	:= ""


BEGIN TRANSACTION
//verifica que la factura contenga reembolso

If SF2->F2_TPDOC == PadR("01",TamSX3("F2_TPDOC")[1]) .and. SF2->F2_TPVENT == "1" .and. SF2->F2_TIPOPE == PadR("41",TamSX3("F2_TIPOPE")[1])
	
	cLlave := xFilial("AQ0")+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
	DbSelectArea("AQ0")
	AQ0->( DbSetOrder(1) )//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA+AQ0_ESTABL+AQ0_PTOEMI+AQ0_NUMDOC
	If AQ0->( MSSEEK(cLlave))

		Do While AQ0->(!Eof()) .and. AQ0->(AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA) == cLlave
			RecLock("AQ0",.F.)
			DbDelete()
			AQ0->(MsUnlock())
			AQ0->( dbSkip() )
		EndDo

	EndIf

	ObtProvCli(@cCodProvS, @cLojaS, SF2->F2_CLIENTE,SF2->F2_LOJA )
	cLLave := xFilial("SE2")+cCodProvS+cLojaS+SF2->F2_PREFIXO+SF2->F2_DUPL
	SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO                                                                                                                                                                                            
	If SE2->(MSSeek(cLLave))
		AADD(aBaixa,{"E2_PREFIXO" 	,SE2->E2_PREFIXO		, Nil})	// 01
		AADD(aBaixa,{"E2_NUM"     	,SE2->E2_NUM			, Nil})	// 02
		AADD(aBaixa,{"E2_PARCELA" 	,SE2->E2_PARCELA		, Nil})	// 03
		AADD(aBaixa,{"E2_TIPO"    	,SE2->E2_TIPO			, Nil})	// 04
		AADD(aBaixa,{"E2_FORNECE"	,SE2->E2_FORNECE		, Nil})	// 05
		AADD(aBaixa,{"E2_LOJA"    	,SE2->E2_LOJA			, Nil})	// 06
		AADD(aBaixa,{"E2_MOEDA"    	,SE2->E2_MOEDA			, Nil})	// 07
		AADD(aBaixa,{"E2_TXMOEDA"	,SE2->E2_TXMOEDA		, Nil})	// 08
		lMsErroAuto := .F.
		MSExecAuto({|x, y, z| FINA050(x, y , z )}, aBaixa, 5 , 5 )
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			lTrns := .F.
		EndIf

	EndIf
Endif

END TRANSACTION

Return lTrns

/*/{Protheus.doc} MT884CNTS
Cancela la cuenta por cobrar(SE1) y crea la cuenta por pagar(SE2)
@author 	Alfredo.Medrano
@since 		08/09/2021
@version	12.1.17 / Superior
/*/
Function MT884CNTS()
Local cLlave := ""
Local aBaixa := {}
Local aAlta := {}
Local cHist := ""
Local cCodProvS := ""
Local cLojaS := ""
Local lTrns := .T.

BEGIN TRANSACTION

	cLlave:= xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC + PadR(Extrae(aDupl[1],3),TamSX3("E1_PARCELA")[1]) + PadR(SF2->F2_ESPECIE,TamSX3("E1_TIPO")[1])
	SE1->( dbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(MSSeek(cLlave) ) //Busca las cuentas por cobrar
		// Cancela las cuentas por cobrar 
		aBaixa := {}
		AADD(aBaixa,{"E1_FILIAL"	, xFilial("SE1")	,NIL})
		AADD(aBaixa,{"E1_CLIENTE"	, SE1->E1_CLIENTE	,NIL})
		AADD(aBaixa,{"E1_LOJA"	    , SE1->E1_LOJA		,NIL})
		AADD(aBaixa,{"E1_PREFIXO"	, SE1->E1_PREFIXO	,NIL})
		AADD(aBaixa,{"E1_NUM"		, SE1->E1_NUM	  	,NIL})
		AADD(aBaixa,{"E1_PARCELA"	, SE1->E1_PARCELA	,NIL})
		AADD(aBaixa,{"E1_TIPO"	    , SE1->E1_TIPO		,NIL})
		lMsErroAuto := .F.
		MSExecAuto({|x, y| FINA040(x, y)}, aBaixa, 5) 	//5 = Exclusión
		
		If !lMsErroAuto
			ObtProvCli(@cCodProvS, @cLojaS, SF2->F2_CLIENTE,SF2->F2_LOJA )
			// si la cancelación fue correcta genera una cuenta por pagar
			cHist:=SF2->F2_CLIENTE+SF2->F2_LOJA
			AADD(aAlta,{'E2_FILIAL ', xFilial("SE2")    	      	, NIL})
			AADD(aAlta,{'E2_PREFIXO', SF2->F2_SERIE	      			, NIL})
			AADD(aAlta,{'E2_NUM    ', SF2->F2_DOC		      		, NIL})
			//AADD(aAlta,{'E2_HIST	', SF2->F2_XGLOSA           	, NIL})
			AADD(aAlta,{'E2_PARCELA', AllTrim(Extrae(aDupl[1],3))   , NIL})
			AADD(aAlta,{'E2_TIPO   ', SF2->F2_ESPECIE				, NIL})
			AADD(aAlta,{'E2_NATUREZ', SF2->F2_NATUREZ		      	, NIL})
			AADD(aAlta,{'E2_FORNECE', cCodProvS		 				, NIL})
			AADD(aAlta,{'E2_LOJA   ', cLojaS						, NIL})
			AADD(aAlta,{'E2_EMISSAO', SF2->F2_EMISSAO           	, NIL})
			AADD(aAlta,{'E2_VENCTO ', Ctod(Extrae(aDupl[1],4))  	, NIL})
			AADD(aAlta,{'E2_VENCREA', Ctod(Extrae(aDupl[1],4))  	, NIL})
			AADD(aAlta,{'E2_VENCORI', Ctod(Extrae(aDupl[1],4))  	, NIL})
			AADD(aAlta,{'E2_VALOR  ', SF2->F2_VALBRUT          		, NIL})
			AADD(aAlta,{'E2_SALDO ', SF2->F2_VALBRUT          		, NIL})
			AADD(aAlta,{'E2_VLCRUZ ', SF2->F2_VALBRUT          		, NIL})
			AADD(aAlta,{'E2_MOEDA  ', SF2->F2_MOEDA	          		, NIL})
			AADD(aAlta,{'E2_TXMOEDA', SF2->F2_TXMOEDA	      		, NIL})
			AADD(aAlta,{'E2_LA'	   , "S"					   	 	, NIL})

			MsExecAuto( { |x,y| FINA050(x,y)} , aAlta, 3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				lTrns := .F.
			Endif
		Else
			DisarmTransaction()
			MostraErro()
			lTrns := .F.
		EndIF

	EndIf

END TRANSACTION

Return lTrns
