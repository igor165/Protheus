#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "LJCADAUX.CH"

Static oStJsonCfg   //Objeto Json criado para controlar o conteudo dos campo _CONFIG e os objetos não MVC
Static cStTipoCad   //Tipo do cadastro que esta sendo utilizado

//Variaveis utilizadas na função LjCadAuxF3, para efetuar consulta padrão
Static cStConF3
Static cStFilF3
Static aStAuxF3

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAux
Modelo MVC Integrações Varejo

@type    function
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjCadAux(cTipoCad)

	Local oBrowse := Nil

    Default cTipoCad := ""

    //Valida o dicionario de dados
    If LjCadAuxVd()
    
        If Empty(cTipoCad)
            If Pergunte("LJCADAUX", .T.)
                cTipoCad := MV_PAR01
            Else
                Return Nil
            EndIf
        EndIf

        cStTipoCad := Upper( AllTrim(cTipoCad) )

        oBrowse := FWMBrowse():New()
        oBrowse:SetDescription( Capital(cStTipoCad) )
        oBrowse:SetAlias("MIH")
        oBrowse:SetLocate()

        oBrowse:SetFilterDefault( "MIH_TIPCAD == '" + PadR( cStTipoCad, TamSX3("MIH_TIPCAD")[1] ) + "'" )  
        oBrowse:SetMenuDef("LjCadAux")
        oBrowse:Activate()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type   function
@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, {STR0002, "PesqBrw"         , 0, 1, 0, .T. } )   //"Pesquisar"
    aAdd( aRotina, {STR0003, "VIEWDEF.LjCadAux", 0, 2, 0, NIL } )	//"Visualizar"
    aAdd( aRotina, {STR0004, "VIEWDEF.LjCadAux", 0, 3, 0, NIL } )	//"Incluir"
    aAdd( aRotina, {STR0005, "VIEWDEF.LjCadAux", 0, 4, 0, NIL } )	//"Alterar"
    aAdd( aRotina, {STR0006, "VIEWDEF.LjCadAux", 0, 5, 0, NIL } )	//"Excluir"
	aAdd( aRotina, {STR0007, "VIEWDEF.LjCadAux", 0, 8, 0, NIL } )	//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados das Integrações Varejo

@type    function
@return  FWFormView, Objeto com as configurações a interface do MVC
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "LjCadAux" )
	Local oStructMIH := Nil
    Local oStructDet := NIL
	Local oView		 := Nil
  
	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructMIH := FWFormStruct( 2, "MIH" )
    oStructMIH:RemoveField("MIH_FILIAL")
    oStructMIH:RemoveField("MIH_TIPCAD")
    oStructMIH:RemoveField("MIH_CONFIG")

    //Carrega os campos definidos pelo json
    oStructDet := FWFormViewStruct():New()
    AddCampo("VIEW", @oStructDet, oStJsonCfg["Components"])

  	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( Capital(cStTipoCad) )

	oView:AddField("MIHMASTER_VIEW", oStructMIH, "MIHMASTER" )

    //Define a quantidade de colunas por linha
    oView:SetViewProperty("MIHMASTER_VIEW", "SETCOLUMNSEPARATOR", {10}) 
   	oView:SetViewProperty("MIHMASTER_VIEW", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 5}) 

    oView:AddField("MIHDETAIL_VIEW", oStructDet, "MIHDETAIL" )

    oView:SetViewProperty("MIHDETAIL_VIEW", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 4}) 

	oView:CreateHorizontalBox("PANEL_1", 20)
	oView:CreateHorizontalBox("PANEL_2", 80)

    oView:SetOwnerView("MIHMASTER_VIEW", "PANEL_1")
    oView:SetOwnerView("MIHDETAIL_VIEW", "PANEL_2")

    oView:EnableTitleView("MIHMASTER_VIEW", STR0001)    //"Dados para Localização"
    oView:EnableTitleView("MIHDETAIL_VIEW", STR0008)    //"Dados para Integração"
    
	oView:SetUseCursor(.T.)
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Mode de Integrações Varejo

@type    function
@return  MpFormModel, Objeto com as configurações do modelo de dados do MVC
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStructMIH := NIL
    Local oStructDet := NIL
    Local oModel	 := NIL
    cStTipoCad := IIF(Valtype(cStTipoCad) !='U',cStTipoCad,"")//proteção para execAuto do Modelo.
    //Objeto Json criado para controlar o conteudo do campo _CONFIG
    IniciaJson()
    
	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructMIH := FWFormStruct(1, "MIH")

    oStructMIH:SetProperty("MIH_TIPCAD", MODEL_FIELD_INIT, {|| cStTipoCad})

    //Carrega os campos definidos pelo json
    oStructDet := FWFormModelStruct():New()
    AddCampo("MODEL", @oStructDet, oStJsonCfg["Components"],oStructMIH)

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MpFormModel():New("LjCadAux", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oModel| SalvaMod(oModel)}/*Commit*/, /*Cancel*/)
	oModel:SetDescription( Capital(cStTipoCad) )

	oModel:AddFields("MIHMASTER", /*cOwner*/, oStructMIH, /*Pre-Validacao*/, /*Pos-Validacao*/)

    oModel:AddFields("MIHDETAIL", "MIHMASTER", oStructDet, /*Pre-Validacao*/, /*Pos-Validacao*/, {|oModel, lCopia| CarregaDet(oModel, lCopia)})
    //oModel:GetModel("MIHDETAIL"):SetForceLoad(.T.)

    oModel:GetModel("MIHMASTER"):SetDescription(STR0001)    //"Dados para Localização"
    oModel:GetModel("MIHDETAIL"):SetDescription(STR0008)    //"Dados para Integração"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaMod(oModel)
Faz o commit das informações

@type    function
@param   oModel, MpFormModel, Modelo MVC que será salvo
@return  Lógico, Define se as informações forão salvas corretamente
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function SalvaMod(oModel)

    Local lRetorno  := .T.
    Local nOperacao := oModel:GetOperation()
    Local oRelac    := RmiRelacionaObj():New()
    Local aRelac    := {}

    
    If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE

        oModel:SetValue("MIHMASTER", "MIH_DATALT", FWTimeStamp(3) )

        //Insere campos pricipais no json de configuração
        AtuJson(oModel)

        oModel:SetValue("MIHMASTER", "MIH_CONFIG", oStJsonCfg:ToJson() )
    ElseIf nOperacao == MODEL_OPERATION_DELETE .And. Alltrim(oModel:GetValue("MIHMASTER", "MIH_TIPCAD")) $ "FECP|ICMS|PIS/COFINS"
        oRelac:SetTipo(Alltrim(oModel:GetValue("MIHMASTER", "MIH_TIPCAD")))
        aRelac := oRelac:Consulta(.F.,oModel:GetValue("MIHMASTER", "MIH_ID"))
        If Len(aRelac) > 0 
            lRetorno := .F.
            oModel:SetErrorMessage('MIHMASTER',,,,,STR0018)
        EndIf 
    EndIf
    If lRetorno
        lRetorno := FwFormCommit(oModel)
    EndIf
Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuJson
Atualiza json com "Dados para Integração" no objeto oStJsonCfg

@type       function
@param      oModel, FwModelActive, Modelo ativo
@author     Rafael Tenorio da Costa
@since      23/08/21
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Static Function AtuJson(oModel)

    Local nPos       := 0
    Local oStructAux := oModel:GetModel("MIHMASTER"):GetStruct()
	Local aCampos    := oStructAux:GetFields()                  	//Array com os campos da estrutura
    Local nCampo     := 0
    Local cCampo     := ""

    //Atualiza "Dados para Integração" no oStJsonCfg
    oStructAux := oModel:GetModel("MIHDETAIL"):GetStruct()
	aCampos    := oStructAux:GetFields()                  	//Array com os campos da estrutura

    For nCampo:=1 To Len(aCampos)

        cCampo := AllTrim( aCampos[nCampo][3] )

        If ( nPos := aScan( oStJsonCfg["Components"], {|x| x["IdComponent"] == cCampo} ) ) > 0
            oStJsonCfg["Components"][nPos]["ComponentContent"] := oModel:GetValue("MIHDETAIL", cCampo)  
        EndIf
    
    Next nCampo
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAuxF3
Função utilizada para consulta padrão que tenha fonte feito a mão no MVC.

@type    function
@param   cTabela, Caractere, Nome da consulta
@param   cFiltro, Caractere, Filtro que será aplicado na consulta
@param   cTipoRet, Caractere, Define em que ponto a função foi chamada 1=Abertura da Consulta \ 2=Filtro da Consulta(SXB)
@return  Caractere, Retorna a consulta padrão ou o filtro da consulta, depende do parâmetro cTipoRet
@author  Rafael Tenorio da Costa
@since   01/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadAuxF3(cConsulta, cFiltro, cTipoRet, aAuxF3)

    Local cRetorno := ""

    Default cConsulta := ""
    Default cFiltro   := ""
    Default aAuxF3    := {}

    If cTipoRet == "1"
        cStConF3 := cConsulta
        cStFilF3 := cFiltro
        aStAuxF3 := aAuxF3

        cRetorno := cStConF3
    Else

        cRetorno := cStFilF3
        cRetorno := "@#(" + cRetorno + ")@#"
    EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadAuxVd
Valida artefatos para correta utilização da rotina.

@type    function
@return  Logico, Define se o dicionario está atualizado. 
@author  Rafael Tenorio da Costa
@since   01/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadAuxVd()

    Local lRetorno := .F.

    Do Case 
        
        Case !AmIIn(12)
            LjxjMsgErr(STR0010)             //"Esta rotina deve ser executada somente pelo módulo Controle de Lojas (12)."
        
        Case !FwAliasInDic("MIG") .Or. !FwAliasInDic("MIH")
            LjxjMsgErr(STR0011, STR0012)    //"Dicionário de dados desatualizado."  //"Aplique o pacote de Expedição Contínua - Varejo"
        
        OTherWise
            lRetorno := .T.

            //Carrega layouts iniciais
            If ExistFunc("LjLayAuxCg")
                LjLayAuxCg()
            EndIf
    
    End Case

Return lRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCampo
Adiciona campo ao View ou Model.

@type    function
@param   cOrigem, Caractere, VIEW ou MODEL.
@param   oStruct, FWFormStruct, Objeto com informações do campo 
@param   oJson, JsonObject, Json com a estrutura para criação do campo. 
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddCampo(cOrigem, oStruct, oJson,oStructMIH)

    Local nCampos     := Len(oJson)
    Local nCont       := 0
    Local cCampo      := ""
    Local xConteudo   := Nil
    Local cComponente := ""    
    Local cTitulo     := ""
    Local bValid      := {|| .T. }
    Local bInit       := {||'' }    
    Local cTipo       := ""
    
    Local cValid      := ""
    Local cF3         := ""
    Local lObrigat    := .F.
    Local xWhen       := Nil
    Local bWhen  := {|| .T.}
    Local nTamanho    := 0
    Local aLista      := {}
    Local cPicture    := ""
    Local aTrigger    := {}
    Local nTri        := 0
    Local cOrder      := ""

    Local bPre              := {|| .T.}
    Local cTargetIdField    := "" 
    Local bSetValue         := {|| .T.}

    For nCont:=1 To nCampos

        If oJson[nCont]:HasProperty("Component")

            cCampo      := oJson[nCont]["IdComponent"]
            xConteudo   := oJson[nCont]["ComponentContent"]
            cTipo       := Upper( oJson[nCont]["ContentType"] )
            cTipo       := IIF( cTipo == "NUMBER", "N", IIF(cTipo == "LOGICAL", "L", IIF(cTipo == "DATE", "D", "C") ) )

            cComponente := Upper( oJson[nCont]["Component"]["ComponentType"] )
            cTitulo     := oJson[nCont]["Component"]["ComponentLabel"]
            lObrigat    := oJson[nCont]["Component"]["Parameters"]["Required"]
            cF3         := oJson[nCont]["Component"]["Parameters"]["F3"]
            cValid      := oJson[nCont]["Component"]["Parameters"]["Valid"]
            nTamanho    := oJson[nCont]["Component"]["Parameters"]["Size"]
            aLista      := oJson[nCont]["Component"]["Parameters"]["List"]
            cPicture    := oJson[nCont]["Component"]["Parameters"]["Picture"]
            aTrigger    := oJson[nCont]["Component"]["Parameters"]["Trigger"]
            xWhen       := oJson[nCont]["Component"]["Parameters"]["CanChange"]
            bInit       := oJson[nCont]["Component"]["Parameters"]["IniPad"]
            cOrder      := oJson[nCont]["Component"]["Parameters"]["Order"]
                        
            if nTamanho == Nil
                LjxjMsgErr("LJCADAUX",I18n(STR0013, {cTitulo})) //"Parametro Size não informado no ComponentLabel: #1"                                                                                                                                                                                                                                                                                                                                                                                                                                                                
                Return .F.
            ElseIf ValType( nTamanho ) == "C"
                  nTamanho := &(nTamanho) // macro execução do tamsx3 (Exemplo)
            endif


            If cOrigem == "VIEW"

                If !Empty(cF3) .And. SubStr(cF3, 1, 2) == "{|"
                    cF3 := &(cF3)
                EndIf
 
                oStruct:AddField(   ;
                cCampo                                          , ;             // [01] Campo
                iif(Empty(cOrder),cValToChar(nCont), cOrder)    , ;             // [02] Ordem
                cTitulo                                         , ;             // [03] Titulo
                cTitulo                                         , ;             // [04] Descricao
                                                                , ;             // [05] Help
                cComponente                                     , ;             // [06] Tipo do campo: COMBO, GET ou CHECK
                cPicture                                        , ;             // [07] Picture
                                                                , ;		        // [08] PictVar
                cF3                                             , ;             // [09] F3
                                                                , ;             // [10] Logico dizendo se o campo pode ser alterado - (utilizar bloco de código bWhen no model)
                                                                , ;             // [11] Id da Folder onde o field esta
                                                                , ;             // [12] Id do Group onde o field esta
                aLista                                          )               // [13] Array com os Valores do combo

            Else
      
                If !Empty(cValid)
                    bValid := &("{|oModel,cCampo,xValor| " + cValid + " }")
                Else
                    bValid := {|| .T. }
                EndIf 

                If ValType( xWhen ) <> "U" //se a tag CanChange nao existir nao deixa dar erro.log
                    If ValType( xWhen ) == "L"
                        bWhen := &("{||" + cValToChar(xWhen) +"} ")
                    Else
                        bWhen := &("{|oModel| " + xWhen + " }")
                    EndIf
                EndIf

                oStruct:AddField(   ;
                cTitulo             , ;             // [01] Titulo do campo
                cTitulo             , ;             // [02] ToolTip do campo
                cCampo              , ;             // [03] Id do Field
                cTipo               , ;             // [04] Tipo do campo
                nTamanho            , ;             // [05] Tamanho do campo
                0                   , ;             // [06] Decimal do campo
                bValid              , ;             // [07] Code-block de validação do campo
                bWhen               , ;             // [08] Code-block de validação When do campo
                aLista              , ;             // [09] Lista de valores permitido do campo
                lObrigat            , ;             // [10] Indica se o campo tem preenchimento obrigatório
                FwBuildFeature(STRUCT_FEATURE_INIPAD,bInit))// [11] Bloco de código de inicialização do campo


                If aTrigger <> Nil 
                    For nTri := 1 to Len(aTrigger)           
            
                        cTargetIdField  := aTrigger[nTri]["TargetIdField"] 
                        bSetValue       := &("{|oModel| " + aTrigger[nTri]["SetValue"] + " }")
                        
                        
                        If "MIH" $ Alltrim(aTrigger[nTri]["FieldTrigger"])
                            oStructMIH:AddTrigger( ;
                                Alltrim(aTrigger[nTri]["FieldTrigger"])  , ;          // [01] Id do campo de origem
                                cTargetIdField , ;  // [02] Id do campo de destino
                                bPre, ;             // [03] Bloco de codigo de validação da execução do gatilho
                                bSetValue )         // [04] Bloco de codigo de execução do gatilho
                        else
                        
                            oStruct:AddTrigger( ;
                                cCampo , ;          // [01] Id do campo de origem
                                cTargetIdField , ;  // [02] Id do campo de destino
                                bPre, ;             // [03] Bloco de codigo de validação da execução do gatilho
                                bSetValue )         // [04] Bloco de codigo de execução do gatilho
                        EndIf
                    Next nTri
                EndIf
            EndIf
        EndIf

    Next nCont

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IniciaJson
Inicializa o objeto oStJsonCfg com o conteudo do campo MIH_CONFIG.

@type    function
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IniciaJson()

    Local lInclui   := If(Type("INCLUI") = "L", INCLUI, .F.)
    Local cJson     := IIF(lInclui, "", MIH->MIH_CONFIG)
    Local cJsonCfg  := Posicione("MIG", 1, xFilial("MIG") + cStTipoCad, "MIG_LAYOUT")   //MIG_FILIAL + MIG_TIPCAD
    Local oJsonCfg  := Nil        
    Local oJsonInteg:= LjJsonIntegrity():New()

    FwFreeObj(oStJsonCfg)
    oStJsonCfg := Nil

    If Empty(cJson)
        cJson := cJsonCfg
    EndIf

    //Caso não tenha configurações retorna panel vazio
    If !Empty(cJson)

        //Atualiza registro com novos componentes
        If !oJsonInteg:CheckString(cJsonCfg, cJson)
            oStJsonCfg := oJsonInteg:GetJson()
        Else
            oStJsonCfg := JsonObject():New()
            oStJsonCfg:FromJson(cJson)
        EndIf
    EndIf        

    oJsonCfg   := Nil
    oJsonInteg := Nil
    FwFreeObj(oJsonCfg)
    FwFreeObj(oJsonInteg)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaDet
Carga dos dados do submodelo MIHDETAIL, carrega os componentes a partir do campo MIH_CONFIG.

@type    function
@param   oModel, FWFormFieldsModel, Que será carregado
@param   lCopia, Lógico, Define se é um operação de copia
@return  Array, Com os campos que serão carregados no sub modulo
@author  Rafael Tenorio da Costa
@since   08/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaDet(oModel, lCopia)

    Local nOperacao  := oModel:GetOperation()
	Local aCampos    := oModel:oFormModelStruct:GetFields()     //Array com os campos da estrutura
    Local nCampo     := 0
    Local cCampo     := "" 
    Local aCmpsIni   := Array( Len(aCampos) )
    Local aRetorno   := {aCmpsIni, 0}

    IniciaJson()

    If nOperacao <> MODEL_OPERATION_INSERT

        //Atualiza modelo a partir do oStJsonCfg
        For nCampo:=1 To Len(aCampos)

            cCampo := AllTrim( aCampos[nCampo][3] )

            If ( nPos := aScan( oStJsonCfg["Components"], {|x| x["IdComponent"] == cCampo} ) ) > 0
                aCmpsIni[nCampo] := oStJsonCfg["Components"][nPos]["ComponentContent"]
            EndIf
        Next nCampo

        aRetorno := { aClone(aCmpsIni), MIH->( Recno() ) }
    EndIf

    FwFreeArray(aCmpsIni)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxValid
Função para uso no Valid de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   cTipoCad, MIH_TIPCAD, campo para seleção 
@param   cCampo, Caracter, Campo da procura no MIH_CONFIG
@param   xValor, Caracter, Valor da procura no MIH_CONFIG
@return  NIL
@author  Danilo Rodrigues
@since   14/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxValid(cTipoCad, cCampo, xValor)
Return Empty(LjAuxPosic(cTipoCad, cCampo, xValor))

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxPosic
Função para uso no Trigger de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   cTipoCad, MIH_TIPCAD, campo para seleção 
@param   cCampo, Caracter, Campo da procura no MIH_CONFIG
@param   xValor, Caracter, Valor da procura no MIH_CONFIG
@param   cCmpRet,Caracter, Campo informado para o retorno do seu conteúdo na função
@return  NIL
@author  Danilo Rodrigues
@since   14/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxPosic(cTipoCad, cCampo, xValor, cCmpRet)

    Local aAreaMIH      := GetArea()
    Local oJsonCfg      := Nil
    Local cJsonCfg      := ""
    Local cRet          := ""
    Local nPos          := 0

    DEFAULT cCampo  := "MIH_ID" 
    DEFAULT cCmpRet := cCampo

    MIH->(DbSetOrder(1))    
    MIH->(dbSeek(xFilial("MIH") + cTipoCad))
    While !MIH->(EOF()) .and. Alltrim(cTipoCad) == Alltrim(MIH->MIH_TIPCAD)

        cJsonCfg := MIH->MIH_CONFIG
    
        //Carrega configurações do tipo do cadastro        
        oJsonCfg := JsonObject():New()
        oJsonCfg:FromJson(cJsonCfg)             

        If IIF( cCampo == "MIH_ID", MIH->&(cCampo) == xValor ,( nPos := aScan( oJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCampo)} ) ) > 0 .and. (oJsonCfg["Components"][nPos]["ComponentContent"] == xValor))

            If cCmpRet == "MIH_ID"
                cRet := MIH->MIH_ID
                Exit
            ElseIf (nPos := aScan( oJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCmpRet)} ) ) > 0 

                cRet := oJsonCfg["Components"][nPos]["ComponentContent"]
                Exit
            EndIf

        EndIf
        MIH->(dbSkip())    
    EndDo

    RestArea(aAreaMIH)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAuxMsg
Função para uso no Trigger de campo para encontrar um valor a partir do campo MIH_CONFIG.

@type    function
@param   lvld, lógico, retorno lógico da condição de validação
@param   cCampo, Caracter, Campo a ser validado
@param   cIdMsg, Caracter, Código da mensagem do parâmetro Messages do JSON
@return  NIL
@author  Evandro Pattaro     
@since   14/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjAuxMsg(lvld,cCampo,cIdMsg)

    Local nPos       := 0
    Local nPosmsg    := 0
    Local aMsg       := {}
    Local oModel     := FwModelActive()
    Local cError     := ""

    If !lvld .AND. ( nPos := aScan( oStJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCampo)} ) ) > 0 

        aMsg := oStJsonCfg["Components"][nPos]["Component"]["Parameters"]["Messages"]

        If (nPosmsg := aScan(aMsg ,{|x| UPPER(ALLTRIM(x["Id"])) == UPPER(ALLTRIM(cIdMsg))})) > 0 

            cError := aMsg[nPosmsg]["Message"]
        Else 
            cError := "Mensagem de validação não encontrada no Layout (propriedade 'Messages')"
        Endif

        oModel:SetErrorMessage('MIHDETAIL',cCampo,,,,cError)
    EndIf

Return lvld

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetComp
Função para retornar o IDProprietário do cadastro de compartilhamentos a partir do código da filial do protheus.

@type    function
@param   cCodLoj, Caracter, Código da filial protheus(SM0)
@param   cProcesso, Caracter, Processo envolvido na busca (MIH_TIPCAD)
@return  NIL
@author  Evandro Pattaro     
@since   18/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjRetComp(cCodLoj,cProcesso)

    Local cRet      := ""
    Local IDLoj     := ""
    Local cMsgErr   := ""  
    
    If Empty(cCodLoj)
        If Empty(cRet := LjAuxPosic("COMPARTILHAMENTOS", "nivel", '0',"IdProprietario"))
           cMsgErr := STR0015//"Agrupamento geral(nível 0) não encontrado no cadastro de compartilhamentos."   
        EndIf    
    
    Else
        If !Empty(IDLoj := LjAuxPosic(cProcesso, "IDFilialProtheus", cCodLoj,"MIH_ID"))
            If Empty(cRet := LjAuxPosic("COMPARTILHAMENTOS", "CodigoLoja", IDLoj,"IdProprietario"))
                cMsgErr := STR0016//"IDRetaguarda não encontrado para esta filial. Verifique o cadastro de compartilhamentos."
            EndIf
        Else 
            cMsgErr := STR0017//"Filial não encontrada no cadastro de lojas."        
        EndIf
    Endif

    If !Empty(cMsgErr)
        LjGrvLog("LjRetComp", cMsgErr, {cCodLoj,cProcesso}, /*lCallStack*/)
    EndIf    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCAuxRet
Retorna o conteúdo da TAG do campo MIH_CONFIG, já posicionado na MIH.

@type    function
@param   cComponent, Carectere, Identificador do componente
@return  Caractere, Conteúdo do componente
@author  Rafael Tenorio da Costa
@since   08/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCAuxRet(cComponent)

    Local oJsonCfg  := JsonObject():New()
    Local nPos      := 0
    Local xConteudo := ""

    oJsonCfg:FromJson(MIH->MIH_CONFIG)

    If ( nPos := aScan( oJsonCfg["Components"], {|x| x["IdComponent"] == cComponent} ) ) > 0
       xConteudo := oJsonCfg["Components"][nPos]["ComponentContent"]
    EndIf

    FwFreeObj(oJsonCfg)

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCAuxPesq
Pesquisa um registro na MIH a partir do MIH_CONFIG, com as caracteristicas
passadas no array aCampos.

@type    function
@param   aCampos, Array, Array com os campos procurados {cTag, xConteudo}
@return  Caractere, MIH_ID do registros localizado
@author  Rafael Tenorio da Costa
@since   08/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCAuxPesq(cTipoCad, aCampos)

    Local aAreaMIH  := GetArea()
    Local cRetorno  := ""
    Local lEncontrou:= .T.
    Local oJsonCfg  := JsonObject():New()
    Local nPos      := 0
    Local cCampo    := ""
    Local xValor    := Nil
    Local nCont     := 0

    MIH->( DbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
    MIH->( DbSeek(xFilial("MIH") + cTipoCad) )
    While !MIH->( Eof() ) .And. Alltrim(MIH->MIH_TIPCAD) == Alltrim(cTipoCad) 

        lEncontrou := .T.

        //Carrega configurações do tipo do cadastro
        oJsonCfg:FromJson(MIH->MIH_CONFIG)

        //Procura todos os campos dentro do JSON
        For nCont:=1 To Len(aCampos)

            cCampo := aCampos[nCont][1]
            xValor := aCampos[nCont][2]

            nPos := aScan( oJsonCfg["Components"], {|x| x["IdComponent"] == cCampo} )

            If nPos == 0 .Or. oJsonCfg["Components"][nPos]["ComponentContent"] <> xValor
                lEncontrou := .F.
                Exit
            EndIf
        Next nCont

        If lEncontrou
            cRetorno := MIH->MIH_ID 
            Exit
        EndIf

        MIH->( DbSkip() )
    EndDo

    RestArea(aAreaMIH)

    FwFreeObj(oJsonCfg)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCadxF3Mu
Função chamada da consulta padrão LJF3MU, para apresentação de tela com seleção de multiplos registros.

@type    function
@return  Lógico, Definindo se foi confirmada ou não a tela da consulta
@author  Rafael Tenorio da Costa
@since   15/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function LjCadxF3Mu()

    Local aArea     := GetArea()
	Local cTitulo 	:= aStAuxF3[3]
	Local aOpcoes	:= {}
    Local cOpcoes	:= ""
    Local cReadVar  := Alltrim( ReadVar() )
	Local aMarcados := {}
    Local cMarcados := ""
    Local cSql      := ""
    Local aSql      := {}
    Local cCmpChave := aStAuxF3[1]
    Local cCmpDesc  := aStAuxF3[2]
    Local cTabela   := GetSx3Cache(cCmpChave, "X3_ARQUIVO")
    Local nTamChave := TamSx3(cCmpChave)[1]
    Local nCont     := 1
    Local lConfirma := .F.

    cSql := " SELECT " + cCmpChave + ", " + cCmpDesc
    cSql += " FROM " + RetSqlName(cTabela)
    cSql += " WHERE " + PrefixoCPO(cTabela) + "_FILIAL = '" + xFilial(cTabela) + "'"
    cSql += " AND D_E_L_E_T_ = ' '"

    If !Empty(cStFilF3)
        cSql += " AND " + cStFilF3
    EndIf

    aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    For nCont:=1 To Len(aSql)
        cOpcoes +=    aSql[nCont][1]
        Aadd(aOpcoes, aSql[nCont][2])
    Next nCont

	If f_Opcoes(@aMarcados	,;	//Variavel de Retorno
				cTitulo		,;	//Titulo da Coluna com as opcoes # Tipos
				aOpcoes	    ,;	//Opcoes de Escolha (Array de Opcoes)
				cOpcoes     ,;	//String de Opcoes para Retorno
				NIL			,;	//Nao Utilizado
				NIL			,;	//Nao Utilizado
				.F.			,;	//Se a Selecao sera de apenas 1 Elemento por vez
				nTamChave   ,;	//Tamanho da Chave
				Len(aOpcoes),;	//Número maximo de elementos na variavel de retorno
				NIL     	,;	//Inclui Botoes para Selecao de Multiplos Itens
				.F.			,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
				NIL			,;	//Qual o Campo para a Montagem do aOpcoes
				.T.			,;	//Nao Permite a Ordenacao
				.T.			,;	//Nao Permite a Pesquisa
				.T.     	,;	//Forca o Retorno Como Array
				NIL			 ;	//Consulta F3
		)

        For nCont:=1 To Len(aMarcados)
            cMarcados += aMarcados[nCont] + ";"
        Next nCont

        lConfirma := .T.
        &cReadVar := cMarcados   //Devolve Resultado para ReadVar(), que é utilizado na consulta padrão
    EndIf

    FwFreeArray(aSql)
    FwFreeArray(aOpcoes)
	
    RestArea(aArea)

Return lConfirma
