#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA503.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA503
Controle de períodos do REINF

@author Karen Honda			
@since 22/03/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA503()

If TAFAlsInDic( "V1O" )
	BrowseDef()
Else
	Aviso( STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Karen Honda		
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina as array

	aRotina := {}

	ADD OPTION aRotina Title STR0003       Action 'VIEWDEF.TAFA503' OPERATION 2 ACCESS 0 //"Visualizar"

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .And. !IsInCallStack("xNewHisAlt")
		If TafColumnPos("V1O_EVENTO")
			ADD OPTION aRotina Title "Histórico"   Action 'xFunNewHis( "V1O", "TAFA503" )' OPERATION 3 ACCESS 0 //"Alterar"  		
		EndIf
	EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Karen Honda			
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV1O	as object
Local oModel		as object

oStruV1O  :=  FWFormStruct( 1, 'V1O' )
oModel    :=  MPFormModel():New( 'TAFA503' ,,,{|oModel| SaveModel(oModel)}) 

//Controle de períodos do REINF
oModel:AddFields('MODEL_V1O', /*cOwner*/, oStruV1O)
oModel:GetModel( "MODEL_V1O" ):SetPrimaryKey( { "V1O_PERAPU" },{ "V1O_NOMEVE" },{ "V1O_ATIVO" } )


Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruV1O	as object
Local oStruV1Op	as object
Local oView		as object

Local cCmpIden	as char
Local cCmpIden2	as char


oModel		:= FWLoadModel( 'TAFA503' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruV1O	:= nil
oStruV1Op	:= Nil
oView		:= FWFormView():New()

cCmpIden	:= ""
cCmpIden2 	:= ""

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
							Estrutura da View
-------------------------------------------------------------------------------------*/
cCmpIden	:= "V1O_PERAPU|V1O_VERSAO|V1O_NOMEVE|V1O_DATA|V1O_HORA|V1O_|V1O_VERLAY|V1O_SEQUEN"
cCmpIden2	:= "V1O_PROTUL|" 


oStruV1O 	:= FwFormStruct( 2, "V1O", { |x| AllTrim( x ) + "|" $ cCmpIden } )
oStruV1Op	:= FwFormStruct( 2, "V1O", { |x| AllTrim( x ) + "|" $ cCmpIden2 } )

//"Controle de Períodos do REINF"
oView:AddField( 'VIEW_V1O', oStruV1O , 'MODEL_V1O' )
oView:AddField( 'VIEW_V1Op', oStruV1Op, 'MODEL_V1O' )

oView:CreateHorizontalBox( 'PAINEL', 100 )
oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0005 ) //"Controle de Períodos do REINF" 
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0006 ) //"Protocolo de Transmissão"
oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )


oView:SetOwnerView( 'VIEW_V1O' , 'PAINEL_01')
oView:SetOwnerView( 'VIEW_V1Op', 'PAINEL_02')


lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV1O, 'V1O')	
EndIf


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	as numeric
	Local lRetorno		as logical

	nOperation	:= oModel:GetOperation()
	lRetorno	:= .T.

	FWFormCommit( oModel )  
     
Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef( cFilter )

	Local oBrw	as object

	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
	EndIf

	DBSelectArea("V1O")
	DbSetOrder(2)
	
	oBrw	:=	FWMBrowse():New()
	oBrw:SetDescription( STR0005 )	//"Controle de Períodos do REINF"
	oBrw:SetAlias( 'V1O')
	oBrw:SetMenuDef( 'TAFA503' )	
	oBrw:SetFilterDefault( "V1O_ATIVO == '1'" )

	//Set Filter TO &("V1O_ATIVO == '1'")

	oBrw:AddLegend( "Empty(V1O_NOMEVE)"			, "GREEN" 	, STR0012 ) //"Período Aberto" 
	oBrw:AddLegend( "V1O_NOMEVE == 'R-2099' "	, "RED" 	, STR0013 ) //"Período Fechado" 
	oBrw:AddLegend( "V1O_NOMEVE == 'R-2098' "	, "BLUE" 	, STR0014 ) //"Período Reaberto" 

	oBrw:Activate()

Return( oBrw )


//-------------------------------------------------------------------
/*/{Protheus.doc} Taf503Grv
Realiza a gravação do status da reabertura e fechamento para controle do periodo.

@author Karen Honda
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf503Grv(cEvento, cPerApur,dData, cHora,cRecibo,cBloco)

Local nRecAtivo 	as numeric
Local oModel		as object
Local cEveAtivo 	as character
Local cVerLay		as character
Local cOrdem		as character
Local cID			as character
Local cIdOld		as character
Local cBloco    	as character
Local cTpEvento		as character
Local cErro			as character
Local cEventFech    as character
Local cEventAber    as character
Local aErro			as array
Local lGrava		as logical
Local lBlc40		as logical  
Local lIndV1O   	as logical

Default cEvento  	:= ""
Default cPerApur 	:= ""
Default dData 	 	:= Date()
Default cHora 	 	:= Time()
Default cRecibo  	:= ""
Default cBloco   	:= "20"

cEventFech  := ""
cEventAber  := ""
lBlc40 	 	:= .F. 
lIndV1O  	:= .F. 

cVerLay := SuperGetMv('MV_TAFVLRE',.F.,"1_03_01")
nRecAtivo := 0
cEveAtivo := ""
cOrdem 	  := "000000"
cID		  := ""
cIdOld	  := ""	
lGrava	  := .T.	
cPerApur  := StrTran(StrTran(cPerApur,"/",""),"-","")
cTpEvento := "I"
lBlc40    := TAFAlsInDic("V5C") .AND. TafColumnPos("LEM_PRID40") .and. FindFunction("TAFQRY40XX")



if cBloco == "20"
	//cBloco 		:= "20"
	cEventFech  := "R-2099"
    cEventAber  := "R-2098"
else
	//cBloco 		:= "40"
	cEventFech  := "R-4099"
    cEventAber  := "R-4098"
endif

DBSelectArea("V1O")
V1O->(DBSetOrder(2)) // V1O_FILIAL, V1O_PERAPU, V1O_ATIVO,V1O_BLOCO R_E_C_N_O_, D_E_L_E_T_

	if lBlc40
		lIndV1O := V1O->( DbSeek( xFilial( "V1O" ) +cPerApur+"1" + cBloco)) 
	else 
		lIndV1O := V1O->( DbSeek( xFilial( "V1O" ) +cPerApur+"1") )
	endif
	if lIndV1O

		nRecAtivo := V1O->(Recno())
		cEveAtivo := V1O->V1O_NOMEVE
		cOrdem	  := V1O->V1O_SEQUEN
		cTpEvento := "A"	
	
	If (cEveAtivo == cEventFech .and. cEvento == cEventAber) .or. ; // Se o Evento ativo for um fechamento, o registro recebido deve ser uma reabertura
		((cEveAtivo == cEventAber .or. Empty(cEveAtivo)) .and. cEvento == cEventFech)  .or.;// Se o Evento ativo for uma reabertura, o registro recebido deve ser uma fechamento
		Empty(cEveAtivo) .And. Empty(V1O->V1O_PROTUL)
		
		cIdOld 	:= V1O->V1O_ID
		// Desativa o registro atual
		FAltRegAnt( "V1O", "2" )
		
	Else
		If cEvento == cEventFech
			lGrava := .F.
			cErro := STR0008 //"Fechamento não pode ser realizada se o período não estiver em aberto."
		EndIf
		
		If !lGrava
			MsgAlert(cErro) 
			//Gerar inconsistencia, pois pode haver duas reaberturas sem fechamento ou dois fechamento sem reabertura
			TafXLog( cID, cEvento, "ERRO"		, STR0009 + CRLF + cErro ) //"Mensagem do erro: "
		EndIf	
	Endif 

EndIf

If lGrava
	//Funcao para criacao do Model de integracao de acordo com a operacao a ser realizada
	FCModelInt( "V1O", "TAFA503", @oModel, MODEL_OPERATION_INSERT )
	If Empty( cIdOld )
		cIdOld := TAFGERAID("TAF")
	EndIf	
	cOrdem := Soma1(cOrdem) 
	oModel:LoadValue( "MODEL_V1O", "V1O_ID", cIdOld )
	oModel:LoadValue( "MODEL_V1O", "V1O_VERSAO", xFunGetVer() )
	oModel:LoadValue( "MODEL_V1O", "V1O_NOMEVE", cEvento )
	oModel:LoadValue( "MODEL_V1O", "V1O_PERAPU", cPerApur )
	oModel:LoadValue( "MODEL_V1O", "V1O_STATUS", IIf(Empty(cRecibo), "", "4") ) // sempre será gravado o status transmitido
	oModel:LoadValue( "MODEL_V1O", "V1O_PROTUL", cRecibo )
	oModel:LoadValue( "MODEL_V1O", "V1O_ATIVO", "1" )
	oModel:LoadValue( "MODEL_V1O", "V1O_DATA", dData )
	oModel:LoadValue( "MODEL_V1O", "V1O_HORA", cHora )		
	oModel:LoadValue( "MODEL_V1O", "V1O_VERLAY", cVerLay )
	oModel:LoadValue( "MODEL_V1O", "V1O_SEQUEN", cOrdem )
	if lBlc40
		oModel:LoadValue( "MODEL_V1O", "V1O_BLOCO", cBloco )
	EndIF
	
	If TafColumnPos("V1O_EVENTO")
		oModel:LoadValue( "MODEL_V1O", "V1O_EVENTO", cTpEvento )		
	EndIf
	If oModel:VldData()
		FwFormCommit( oModel )
	Else
		aErro   :={}
		cErro := TafRetEMsg( oModel )
		
		TafXLog( cID, cEvento, "ERRO"		, STR0009 + CRLF + cErro )		//"Mensagem do erro: "
	EndIf
	
	If cEvento == cEventFech
		// Gera uma abertura para o proximo periodo
		cPerProx := TafProxPer(.T.,cPerApur)
		cPerProx := StrTran(StrTran(cPerProx,"/",""),"-","")
		cOrdem := Soma1(cOrdem) 
		
		/*
			Valido a existência do próximo período de apuração,
			para não duplicar o controle de períodos apurados ( V1O_PERAPU )
		*/	

		if lBlc40
			lIndV1O := !V1O->( DbSeek( xFilial( "V1O" ) +  cPerProx + "1" + cBloco ) )  // V1O_FILIAL + V1O_PERAPU + V1O_ATIVO + V1O_BLOCO
		else 
			lIndV1O := !V1O->( DbSeek( xFilial( "V1O" ) +  cPerProx + "1" ) ) // V1O_FILIAL + V1O_PERAPU + V1O_ATIVO + V1O_BLOCO
		endif
		if lIndV1O
		//If !V1O->( DbSeek( xFilial( "V1O" ) +  cPerProx + "1" ) ) // V1O_FILIAL + V1O_PERAPU + V1O_ATIVO
			FCModelInt( "V1O", "TAFA503", @oModel, MODEL_OPERATION_INSERT )
			cID := TAFGERAID("TAF")
			oModel:LoadValue( "MODEL_V1O", "V1O_ID", cID )
			oModel:LoadValue( "MODEL_V1O", "V1O_VERSAO", xFunGetVer() )
			oModel:LoadValue( "MODEL_V1O", "V1O_NOMEVE", "" )
			oModel:LoadValue( "MODEL_V1O", "V1O_PERAPU", cPerProx )
			oModel:LoadValue( "MODEL_V1O", "V1O_STATUS",  "" ) // sera gravado status em branco para registro incluido após o 2099
			oModel:LoadValue( "MODEL_V1O", "V1O_PROTUL", "" )
			oModel:LoadValue( "MODEL_V1O", "V1O_ATIVO", "1" )
			oModel:LoadValue( "MODEL_V1O", "V1O_DATA", dDatabase )
			oModel:LoadValue( "MODEL_V1O", "V1O_HORA", Time() )		
			oModel:LoadValue( "MODEL_V1O", "V1O_VERLAY", cVerLay )
			oModel:LoadValue( "MODEL_V1O", "V1O_SEQUEN", cOrdem )

			if lBlc40
				oModel:LoadValue( "MODEL_V1O", "V1O_BLOCO", cBloco )
			EndIF
			
			If oModel:VldData( )
				FwFormCommit( oModel )
			Endif	
		EndIf	
	EndIf			
EndIf
Return