#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "OGA550.CH"

/*/{Protheus.doc} OGA550
@author marcelo.Ferrari
@since 10/08/2017
@version 12.1.20
@param:     Nil
@return:    Nil
@Uso:       OGA550
/*/
 Function OGA550()

	Local oMBrowse	:= Nil
	Private lSetOrd 	:= .F.

	If .Not. TableInDic('N7W')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif	
	
	IF Select("N7W") = 0
	   DbSelectArea("N7W")
	EndIF


	IF Select("N7Z") = 0
	   DbSelectArea("N7Z")
	EndIF

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N7W" )
	oMBrowse:SetMenuDef( "OGA550" )
	oMBrowse:SetDescription( "Processos para modelos de e-mail" ) 
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

 Return( Nil )

/*/{Protheus.doc} MenuDef
@author marcelo.Ferrari
@since 10/08/2017
@version 12.1.20
@param:     Nil
@return:    aRotina
@Uso:       OGA550
/*/
Static Function MenuDef()

	Local aRotina := {}
	aAdd( aRotina, { STR0001, 'VIEWDEF.OGA550', 0, 2, 0, NIL } )// Visualisar
	aAdd( aRotina, { STR0002, 'VIEWDEF.OGA550', 0, 3, 0, NIL } )// Incluir
	aAdd( aRotina, { STR0003, 'VIEWDEF.OGA550', 0, 4, 0, NIL } )// Alterar
	aAdd( aRotina, { STR0004, 'VIEWDEF.OGA550', 0, 5, 0, NIL } )// Excluir 
	aAdd( aRotina, { STR0005, 'VIEWDEF.OGA550', 0, 8, 0, NIL } )// Imprimir

Return aRotina


/*/{Protheus.doc} ModelDef
@author marcelo.Ferrari
@since 10/08/2017
@version 12.1.20
@param:     Nil
@return:    oModel
@Uso:       OGA550
/*/
Static Function ModelDef()

	Local oStruN7W 	:= FWFormStruct( 1, "N7W")
	Local oStruN7Z 	:= FWFormStruct( 1, "N7Z")

	Local oModel   := MPFormModel():New("OGA550", , , /*{|oModel| GravaDados(oModel)}*/) // Instancia o Model
	
    oStruN7Z:SetProperty('N7Z_PROCES', MODEL_FIELD_OBRIGAT, .F.)
	oModel:SetDescription( STR0006 ) //"Processos para modelos de e-mail"
	//N7W - TABELA MESTRE
	oModel:AddFields( 'N7WOGA550', /*cOwner*/, oStruN7W, /*bPre*/,/*bPost*//*{| oModel | OGA550POS( oModel ) }*/)// validações pre, pos modelo 
	oModel:SetPrimaryKey( { "N7W_FILIAL", "N7W_CODIGO" } )
	oModel:GetModel( 'N7WOGA550' ):SetDescription( STR0006)  //"Processos para modelos de e-mail"
	
    //N7Z - TABELA FILHA DE N7W
    oModel:AddGrid( 'N7ZOGA550', 'N7WOGA550', oStruN7Z ,/*bPre*/,/*bPost*//*{| oModel | OGA550POS( oModel ) } */)// validações pre, pos modelo 
	oModel:GetModel( 'N7ZOGA550' ):SetDescription( STR0007 )  //"Relacionamento entre tabelas"
	oModel:GetModel( 'N7ZOGA550' ):SetOptional( .T. )
	oModel:SetRelation('N7ZOGA550', { { 'N7Z_FILIAL', 'xFilial( "N7Z" )' }, { 'N7Z_PROCES', 'N7W_CODIGO' } }, N7Z->( IndexKey( 1 ) ) )

Return ( oModel )

/*/{Protheus.doc} ViewDef
@author marcelo.Ferrari
@since 10/08/2017
@version 12.1.20
@param:     Nil
@return:    oView
@Uso:       OGA550
/*/
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( "OGA550" )
	Local oView    	:= FWFormView():New()

	Local oStruN7W	:= FWFormStruct( 2, "N7W" )
	Local oStruN7Z	:= FWFormStruct( 2, "N7Z" )
	
	oStruN7Z:RemoveField( "N7Z_FILIAL" )
	oStruN7Z:RemoveField( "N7Z_PROCES" )
	
    oView:SetModel( oModel )
	oView:AddField("OGA550_N7W", oStruN7W  , "N7WOGA550")
	oView:AddGrid ("OGA550_N7Z", oStruN7Z  , "N7ZOGA550")
	
	oView:CreateVerticallBox("TELANOVA" , 100)
	
	oView:CreateHorizontalBox("SUPERIOR" , 30, "TELANOVA")
	oView:CreateHorizontalBox("INFERIOR" , 70, "TELANOVA")

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox("DIREITA" , 50, "INFERIOR")
	oView:CreateVerticalBox("ESQUERDA" , 50, "INFERIOR")

	oView:SetOwnerView("OGA550_N7W", "SUPERIOR")
	oView:SetOwnerView("OGA550_N7Z", "INFERIOR")
	
	oView:EnableTitleView("OGA550_N7W")
	oView:EnableTitleView("OGA550_N7Z")

    // Auto-Increment do campo N7W_CODIGO
	//oView:addIncrementField("OGA550_N7W", "N7W_CODIGO")// Incrementa o Campo Código
    oView:addIncrementField("OGA550_N7Z", "N7Z_ORDEM") // Incrementa o Campo Ordem


    oView:SetCloseOnOk( {||.T.} )

Return (oView) 

/*/{Protheus.doc} OGA550NMT
  Função de gatilhos para os campos Nome da tabela e Nome tabela pai
@author marcelo.Ferrari
@since 10/08/2017
@version 12.1.20
@param:     nTipo : 1=N7Z_TABELA / 2=N7Z_TABPAI
            nAcao : G=Gatilho / P=Inicialização Padrão
@return:    cRet
@Uso:       OGA550
/*/
Function OGA550NMT(nTipo, cAcao)
   Local aArea := GetArea()
   Local cRet := ""
   Local cCampo := ""
   Local cValor
   Default cAcao := 'G'  // P = Inicializacao padrão / G = gatilho
   
   IF nTipo = 1
      cCampo := "N7Z_TABELA"
   Else
      cCampo := ("N7Z_TABPAI")
   EndIF
         
   If cAcao == "G"
      cValor := FWFLDGET(cCampo)
   Else
      cValor := &(AllTrim("N7Z->"+AllTrim(cCampo)))
   EndIf
   
   cRet := AGRSX2NOME(cValor)

   RestArea(aArea)
Return cRet