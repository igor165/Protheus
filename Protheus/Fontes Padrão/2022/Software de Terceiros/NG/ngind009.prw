#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND009.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

#DEFINE _nVERSAO 1 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND009
Hist�rico de Indicadores.

@author Wagner Sobral de Lacerda
@since 17/09/2012

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND009()
	
	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	
	Local lExecute := .T. // Vari�vel para identificar se pode ou n�o executar esta rotina
	Local oBrowse // Vari�vel do Browse
	
	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	lExecute := NGIND007OP()
	
	If lExecute
		// Declara as Vari�veis PRIVATE
		NGIND009VR()
		
		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZB")
		dbSetOrder(1)
		dbGoTop()
		
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()
			
			// Defini��o da tabela do Browse
			oBrowse:SetAlias("TZE")
			
			// Descri��o do Browse
			oBrowse:SetDescription(cCadastro)
			
			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND009")
			
		// Ativa��o da Classe
		oBrowse:Activate()
		//----------------
		// Fim do Browse
		//----------------
	EndIf
	
	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	
Return lExecute

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 18/09/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
	
	// Vari�vel do Menu
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND009" OPERATION 2 ACCESS 0 //"Visualizar"
	
Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} fCposExcep
Monta o Array com a excecao de campos para o Modelo/View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCposExcep()
	
	// Exce��o de campos na View da tabela TZG
	aVCpoTZF := {}
	aAdd(aVCpoTZF, "TZF_CODIGO")
	
	// Exce��o de campos na View da tabela TZF
	aVCpoTZG := {}
	aAdd(aVCpoTZG, "TZG_CODIGO")
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DO < MODELO > * MVC                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 18/09/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
	
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZE := FWFormStruct(1, "TZE", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZF := FWFormStruct(1, "TZF", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZG := FWFormStruct(1, "TZG", /*bAvalCampo*/, /*lViewUsado*/)
	
	// Modelo de dados que ser� constru�do
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND009", /*bPreValid*/, /*bPosValid*/, /*bFormCommit*/, /*bFormCancel*/)
		
		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------
		
		// Adiciona ao modelo um componente de Formul�rio Principal
		oModel:AddFields("TZEMASTER"/*cID*/, /*cIDOwner*/, oStruTZE/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)
		
		// Adiciona ao modelo um componente de Grid, com o "TZBMASTER" como Owner
		oModel:AddGrid("TZFDATA"/*cID*/, "TZEMASTER"/*cIDOwner*/, oStruTZF/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
			// Define a Rela��o do modelo das F�rmulas com o Principal (Indicador Gr�fico)
			oModel:SetRelation("TZFDATA"/*cIDGrid*/,;
								{ {"TZF_FILIAL", 'xFilial("TZE")'}, {"TZF_CODIGO", "TZE_CODIGO"} }/*aConteudo*/,;
								TZF->( IndexKey(3) )/*cIndexOrd*/)
		
		// Adiciona ao modelo um componente de Grid, com o "TZBMASTER" como Owner
		oModel:AddGrid("TZGPARAMS"/*cID*/, "TZEMASTER"/*cIDOwner*/, oStruTZG/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
			// Define a Rela��o do modelo das F�rmulas com o Principal (Indicador Gr�fico)
			oModel:SetRelation("TZGPARAMS"/*cIDGrid*/,;
								{ {"TZG_FILIAL", 'xFilial("TZE")'}, {"TZG_CODIGO", "TZE_CODIGO"} }/*aConteudo*/,;
								TZG->( IndexKey(3) )/*cIndexOrd*/)
		
		// Adiciona a descri��o do Modelo de Dados (Geral)
		oModel:SetDescription(STR0002/*cDescricao*/) //"Hist�rico de Indicadores"
			
			//--------------------------------------------------
			// Defini��es do Modelo
			//--------------------------------------------------
			
			// Adiciona a descri��o do Modelo de Dados TZB
			oModel:GetModel("TZEMASTER"):SetDescription(STR0003/*cDescricao*/) //"Hist�rido de Resultados"
			
			// Adiciona a descri��o do Modelo de Dados TZC
			oModel:GetModel("TZFDATA"):SetDescription(STR0004/*cDescricao*/) //"Hist�rico de Dados"
			
			// Adiciona a descri��o do Modelo de Dados TZC
			oModel:GetModel("TZGPARAMS"):SetDescription(STR0005/*cDescricao*/) //"Hist�rico de Par�metros"
	
Return oModel

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DA < VIEW > * MVC                                                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 18/09/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Dimensionamento de Tela
	Local aScreen  := aClone( GetScreenRes() )
	Local nAltura  := aScreen[2]
	
	Local aPorcen := {}
	Local nPixels := If(nAltura >= 1024, 400, 350) // Pixels para o cabe�alho
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND009")
	
	// Cria a estrutura a ser usada na View
	Local oStruTZE := FWFormStruct(2, "TZE", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZF := FWFormStruct(2, "TZF", {|cCampo| fStructCpo(cCampo, "TZF") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZG := FWFormStruct(2, "TZG", {|cCampo| fStructCpo(cCampo, "TZG") }/*bAvalCampo*/, /*lViewUsado*/)
	
	// Interface de visualiza��o constru�da
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
		
		// Define qual o Modelo de dados ser� utilizado na View
		oView:SetModel(oModel)
		
		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------
		
		// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
		oView:AddField("VIEW_TZEMASTER"/*cFormModelID*/, oStruTZE/*oViewStruct*/, "TZEMASTER"/*cLinkID*/, /*bValid*/)
		
		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZFDATA"/*cFormModelID*/, oStruTZF/*oViewStruct*/, "TZFDATA"/*cLinkID*/, /*bValid*/)
		
		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZGPARAMS"/*cFormModelID*/, oStruTZG/*oViewStruct*/, "TZGPARAMS"/*cLinkID*/, /*bValid*/)
		
		//--------------------------------------------------
		// Layout
		//--------------------------------------------------
		
		// Cria os componentes "box" horizontais para receberem elementos da View
		aPorcen := Array(2)
		aPorcen[1] := ( (nPixels * 100) / nAltura ) // Quero 'nPixels' para a Altura
		aPorcen[2] := ( 100 - aPorcen[1] )
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, aPorcen[1]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, aPorcen[2]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			
			//Cria os componentes "box" verticais dentro do box horizontal
			oView:CreateVerticalBox("BOX_INFERIOR_ESQ"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			oView:CreateVerticalBox("BOX_INFERIOR_DIR"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				
				// Cria os componentes "box" horizontais, dentro dos verticais
				oView:CreateHorizontalBox("BOX_DATA"  /*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_ESQ"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				oView:CreateHorizontalBox("BOX_PARAMS"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_DIR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		
		// Relaciona o identificador (ID) da View com o "box" para exibi��o
		oView:SetOwnerView("VIEW_TZEMASTER"/*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZFDATA"  /*cFormModelID*/, "BOX_DATA"    /*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZGPARAMS"/*cFormModelID*/, "BOX_PARAMS"  /*cIDUserView*/)
		
		// Adiciona um T�tulo para a View
		oView:EnableTitleView("VIEW_TZEMASTER"/*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZFDATA"  /*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZGPARAMS"/*cFormModelID*/, /*cTitle*/, /*nColor*/)
		
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCampo
	Campo atual sendo verificado na estrutura * Obrigat�rio
@param cEstrutura
	Tabela da estrutura sendo carregada * Obrigat�rio

@return .T. caso o campo seja valido; .F. se nao for valido
/*/
//---------------------------------------------------------------------
Static Function fStructCpo(cCampo, cEstrutura)
	
	// Vari�vel de c�pia do array de Exce��es
	Local aExcecao := {}
	
	// Recebe os campos de exce��o
	If cEstrutura == "TZF"
		aExcecao := aClone( aVCpoTZF )
	ElseIf cEstrutura == "TZG"
		aExcecao := aClone( aVCpoTZG )
	EndIf
	
	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008VR
Declara as vari�veis Private utilizadas no Hist�rico de Indicadores.
* Lembrando que essas vari�veis ficam declaradas somente para a fun��o
que � Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 18/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND009VR()
	
	//------------------------------
	// Declara as vari�veis
	//------------------------------
	
	// Vari�vel do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0002)) //"Hist�rico de Indicadores"
	
	// Exce��o de Campos
	_SetOwnerPrvt("aVCpoTZF", {}) // Vari�vel de exce��o de campos na View da TZF
	_SetOwnerPrvt("aVCpoTZG", {}) // Vari�vel de exce��o de campos na View da TZG
	
	//------------------------------
	// Define conte�dos Default
	//------------------------------
	// Monta o array com a exce��o de campos
	fCposExcep()
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES UTILIZADAS NO DICION�RIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND009IP
Fun��o para INICIALIZADOR PADR�O.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCampo
	ID do Campo do dicion�rio SX3 * Obrigat�rio

@return cIniPad
/*/
//---------------------------------------------------------------------
Function NGIND007IP(cCampo)
	
	// Vari�vel do Retorno 'INICIALIZADOR PADR�O'
	Local cIniPad := ""
	
	// Defaults
	Default cCampo := ""
	
	//----------
	// Executa
	//----------
	If cCampo == "TZE_NOMFOR"
		cIniPad := If(INCLUI, "", Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME"))
	EndIf
	
Return cIniPad

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND009IB
Fun��o para INICIALIZADOR do BROWSE.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCampo
	ID do Campo do dicion�rio SX3 * Obrigat�rio

@return cIniBrw
/*/
//---------------------------------------------------------------------
Function NGIND007IB(cCampo)
	
	// Vari�vel do Retorno 'INICIALIZADOR do BROWSE'
	Local cIniBrw := ""
	
	// Defaults
	Default cCampo := ""
	
	//----------
	// Executa
	//----------
	If cCampo == "TZE_NOMFOR"
		cIniBrw := Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME")
	EndIf
	
Return cIniBrw