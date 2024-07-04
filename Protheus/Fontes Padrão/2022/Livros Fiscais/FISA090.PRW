#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA090.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA090
Cadastro MVC para atender o cadastro do CEPOM (Bi tributação do ISS).

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------
Function FISA090()

	Local   oBrowse := Nil

	IF  AliasIndic("CLI") 
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CLI")
		oBrowse:SetDescription(STR0007)
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0001,1,0) // "Tabela CLI não cadastrada no sistema!"
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA090' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA090' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA090' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA090' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA090' OPERATION 9 ACCESS 0 //'Copiar'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel	:= Nil
	Local oStructCLI := FWFormStruct(1, "CLI",{|cCampo| COMP11STRU(cCampo,"CAB")}) 
	Local oStructSER := FWFormStruct(1, "CLI",{|cCampo| COMP11STRU(cCampo,"ITE")}) 
	Local bIniDSERV  := FwBuildFeature(STRUCT_FEATURE_INIPAD,  'RetDServ()')
	Local aGatilhos 	:= {}
	Local nAtual		:= 0

	//Adicionando um gatilho, do CLI_CODISSpara o CLI_DSERV
    aAdd(aGatilhos, FWStruTriggger( "CLI_CODISS",;                                //Campo Origem
                                    "CLI_DSERV",;                                 //Campo Destino
                                    "Posicione('SX5',1,xFilial('SX5')+'60'+FWFLDGET('CLI_CODISS'), 'X5DESCRI()')",;//Regra de Preenchimento
                                    .F.,;                                       //Irá Posicionar?
                                    "",;                                        //Alias de Posicionamento
                                    0,;                                         //Índice de Posicionamento
                                    '',;                                        //Chave de Posicionamento
                                    NIL,;                                       //Condição para execução do gatilho
                                    "01");                                      //Sequência do gatilho
    )

	//Percorrendo os gatilhos e adicionando na Struct
    For nAtual := 1 To Len(aGatilhos)
        oStructSER:AddTrigger(	aGatilhos[nAtual][01],; //Campo Origem
                            	aGatilhos[nAtual][02],; //Campo Destino
                            	aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
                            	aGatilhos[nAtual][04])  //Bloco de código de execução do gatilho
    Next   
	
	
	oModel	:=	MPFormModel():New('FISA090MOD', ,{|oModel| ValidForm(oModel)})
	
	oModel:AddFields('FISA090MOD' ,, oStructCLI )	   
	oModel:AddGrid('FISA090SER', 'FISA090MOD', oStructSER)
	
	oModel:SetRelation( "FISA090SER" , { { "CLI_FILIAL" , 'xFilial("CLI")' } , { "CLI_TIPO" , "CLI_TIPO" } , { "CLI_UF" , "CLI_UF" },;
		{ "CLI_CODMUN" , "CLI_CODMUN" } , { "CLI_FORNEC" , "CLI_FORNEC" } ,;
		{ "CLI_LOJAF" , "CLI_LOJAF" } }, CLI->( IndexKey( 1 ) ) )
	
	
	//CLI_FILIAL/CLI_TIPO/CLI_UF/CLI_CODMUN/CLI_MUNIC/CLI_FORNEC/CLI_NFORNE
	
	oModel:SetPrimaryKey({"CLI_FILIAL"},{"CLI_TIPO"},{"CLI_CODISS"},{"CLI_UF"},{"CLI_CODMUN"},{"CLI_FORNEC"}, {"CLI_LOJAF"})	
	
	oModel:GetModel("FISA090SER"):SetUniqueLine({"CLI_CODISS"})

	oModel:SetDescription(STR0007) //Cepom
	
	oModel:GetModel('FISA090MOD'):SetDescription(STR0009)
	
	oModel:GetModel( 'FISA090SER' ):SetDescription("SERVICO")
	
	//Mudo para não editavel quando for Saída
	oStructCLI:SetProperty( 'CLI_FORNEC' , MODEL_FIELD_WHEN  , { || ValidTipo(oModel) } )	
	oStructCLI:SetProperty( 'CLI_NFORNE' , MODEL_FIELD_WHEN  , { || ValidTipo(oModel) } )	
	oStructCLI:SetProperty( 'CLI_LOJAF' , MODEL_FIELD_WHEN  , { || ValidTipo(oModel) } )	
	//
	oStructSER:SetProperty('CLI_DSERV',    MODEL_FIELD_INIT, bIniDSERV )       //Iniciaizador  Padrão campo CLI_DSERV
	
Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     	:= FWLoadModel( "FISA090" )
	Local oStructCLI 	:= FWFormStruct(2, "CLI",{|cCampo| COMP11STRU(cCampo,"CAB")}) 
	Local oStructSER 	:= FWFormStruct(2, "CLI",{|cCampo| COMP11STRU(cCampo,"ITE")}) 
	Local oView 		:= Nil
	
	
	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "VIEW" , oStructCLI , 'FISA090MOD')	
	oView:AddGrid( 'VIEW_SER', oStructSER, 'FISA090SER' )

	oView:CreateHorizontalBox( "TELA" , 30 )
	
	oView:CreateHorizontalBox( 'INFERIOR', 70 )

	oView:SetOwnerView( "VIEW" , "TELA" )	
	
	oView:SetOwnerView( 'VIEW_SER', 'INFERIOR' )
	
	
Return oView


//-------------------------------------------------------------------

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cTipo		:=	oModel:GetValue ('FISA090MOD','CLI_TIPO')
	Local cUF			:=	oModel:GetValue ('FISA090MOD','CLI_UF')
	Local cMunic		:=	oModel:GetValue ('FISA090MOD','CLI_CODMUN')
	Local cFornec		:=	oModel:GetValue ('FISA090MOD','CLI_FORNEC')  
	Local cLoja		:=	oModel:GetValue ('FISA090MOD','CLI_LOJAF')  
	Local cCodIss		:= oModel:GetValue ('FISA090SER','CLI_CODISS')     
	Local nOperation 	:=	oModel:GetOperation()
	
	If nOperation == 3 .Or. nOperation == 4 
		CLI->(DbSetOrder (1))
		If CLI->(DbSeek(xFilial("CLI")+cTipo+cCodIss+cUF+cMunic+cFornec+cLoja))						
			Help("",1,"Help","Help",STR0008,1,0) //Já existe registro com esses dados
			lRet := .F.
		EndIF
		
		If cTipo == "1" .And. Empty(cFornec)
			Help(,,"Fisa080",,STR0010,1,0)
			lRet := .F.
		EndIf	
	EndIF

Return lRet
//-------------------------------------------------------------------

/*/{Protheus.doc} ValidTipo
Validação das informações digitadas no form.

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidTipo(oModel)

Local lRet			:=	.T.
Local cTipo		:=	oModel:GetValue ('FISA090MOD','CLI_TIPO')

IF cTipo == "2"
	lRet:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Graziele Mendonça Paro
@since 05.11.2014
@version P11

/*/
//-------------------------------------------------------------------
Static Function COMP11STRU(cCampo,cTipo)

	Local 	lRet 		:= .T.
	Local	cCabec		:=	""
	Local	cItem		:=	""

	cCabec	:= "CLI_FILIAL/CLI_TIPO/CLI_UF/CLI_CODMUN/CLI_MUNIC/CLI_FORNEC/CLI_NFORNE/CLI_LOJAF/"
	cItem	:= "CLI_CODISS/CLI_DSERV/"

	If cTipo = "CAB"
		If !AllTrim( cCampo ) + "/" $ cCabec
			lRet := .F.
		EndIf
	Else
		If !AllTrim( cCampo ) + "/" $ cItem
			lRet := .F.
		EndIf
	EndIf

Return(lRet)

//-------------------------------------------------------------------

/*/{Protheus.doc} RetDServ
Retorna Descrição de Serviço

@author r.cavalcante
@since 15.06.22
@version P12

/*/
//-------------------------------------------------------------------
Function RetDServ()
	Local cRet 		:= ""
    Local oModel	:= FWModelActive()
    Local lF090		:= ValType(oModel) == "O" .And. oModel:GetId() == "FISA090MOD"  .And. IsInCallStack("FISA090")
    Local oModGrid  := IIF(lF090,oModel:GetModel("FISA090SER"),Nil)
    Local nLinha    := IIF(lF090,oModGrid:nLine,0)

	If lF090 .AND. nLinha == 0 .AND. !INCLUI
		cRet	:= Posicione("SX5",1,xFilial("SX5")+"60"+CLI->CLI_CODISS, "X5DESCRI()")
	EndIf

	
Return cRet
