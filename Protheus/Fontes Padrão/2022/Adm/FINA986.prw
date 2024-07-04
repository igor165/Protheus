#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA986.CH'
#INCLUDE "FWMBROWSE.CH"
#Include "FWEditPanel.CH"

Static __cXml986     := ""
Static __cAlias986   := ""
Static __nOPER       := 0
Static __lFKG_CALCUL := .F.
Static __lFKG_CODDEP := .F.
Static __lFKF_ORIINS := .F.
Static __lFKF_CEDENT := .F.
Static __lFKF_PAGPIX := .F.
Static __lFKF_RECPIX := .F.
Static __lSF2_CNO    := .F.
Static __lA2_CPRB    := .F.
Static __lBrowse     := .F.
Static __aDadosTit   := {}
Static __oSttFKG     := NIL
Static __lFinQRCode
Static __TableF71    := .F.
Static __lFina890    := .F.
Static __lTableFKF   := .F. 
Static __lFKFEspec   := .F. 
Static __lF040Espec  := .F.
Static __lTableFOF   := .F.
Static __oPJob       := NIL
Static __oPJob2      := NIL
Static __lGeraPix    := .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} FINA986
Cadastro dos complemento do titulo. Tabelas FKF e FKG

@author Karen Honda
@since 28/07/2016
@Param	cAliasC - variavel string contendo a tabela posicionada no momento (SE1 ou SE2)
@Param	lPosBrw	- variavel logica indicando o momento da chamada, se é no Browse ou na tela de cadastro do titulo
@version P11
/*/
//-------------------------------------------------------------------
Function FINA986(cAliasC, lPosBrw)

Local cIdDoc         := ""
Local cChave         := ""
Local oModel
Local nOpc           := 3
Local cAliasTab      := ""
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local cTipos		 :=	MVABATIM + "/" + MV_CRNEG + "/" + MVTXA + "/" + MV_CPNEG + "/" + MVPROVIS + "/" + MVCSABT + "/" + MVCFABT + "/" + MVPIABT

//Recriando as variáveis no escopo da função
Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

Default lPosBrw := .F.

//inicializa as variaveis estaticas.
F986IniVar(cAliasC,lPosBrw)

cAliasTab  := If(lPosBrw, cAliasC+"->" , "M->")

//Valida se o complemento esta disponivel para o tipo de titulo posicionado
If &( cAliasTab + Right(cAliasC, 2) + "_TIPO" ) $ cTipos 
    Help( ,,"FKFNAOPERM",,STR0025, 1, 0 )	// "Tipo do titulo nao permitido para o complemento de imposto.""
    Return .F.
Endif	

If cAliasC == "SE1" // se veio do contas a receber

    If __lBrowse
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
    Else
        cChave := M->E1_FILIAL + "|" +  M->E1_PREFIXO + "|" + M->E1_NUM + "|" + M->E1_PARCELA + "|" + M->E1_TIPO + "|" + M->E1_CLIENTE + "|" + M->E1_LOJA
    Endif

    If !INCLUI
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            If ALTERA
                nOpc := MODEL_OPERATION_UPDATE
            Else
                nOpc := MODEL_OPERATION_VIEW
            EndIf
        EndIf
    EndIf

ElseIf  cAliasC == "SE2" // se veio do contas a pagar

    If __lBrowse
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE+ "|" + SE2->E2_LOJA
    Else
        cChave := M->E2_FILIAL + "|" +  M->E2_PREFIXO + "|" + M->E2_NUM + "|" + M->E2_PARCELA + "|" + M->E2_TIPO + "|" + M->E2_FORNECE+ "|" + M->E2_LOJA
    Endif

    If !INCLUI
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            If ALTERA
                nOpc := MODEL_OPERATION_UPDATE
            Else
                nOpc := MODEL_OPERATION_VIEW
            EndIf
        EndIf
    EndIf
EndIf

__nOPER:= nOpc

If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)
    oModel := FwLoadModel("FINA986")
    oModel:LoadXMLData(__cXml986)
    FWExecView( STR0001,"FINA986", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel )//'Complemento titulo'
    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
Else
    FWExecView( STR0001,"FINA986", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/,  )//'Complemento titulo'STR0001
EndIf

Return

//-------------------------------------------------------------------

Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruFKF   := FWFormStruct( 1, 'FKF', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruFKG   := FWFormStruct( 1, 'FKG', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel     := NIL
    Local cAliasTab  := ""
    Local cCampo	 := ""
    Local bLinePost  := {|| F986LINE(oModel) }
    Local bWhenValor := {||}
    Local cAcao      := "M->FKG_DEDACR"
                            
    __cAlias986 := IF(ValType(__cAlias986)=="U", "SE2", __cAlias986)
    cAliasTab  := If(__lBrowse, __cAlias986+"->" , "M->")
    cCampo	   := cAliasTab + Right(__cAlias986, 2) + "_LA"
    
    oStruFKF:AddField(			  ;
    STR0026					, ;	// [01] Titulo do campo		//'Descrição do CNAE'
    STR0026					, ;	// [02] ToolTip do campo 	//'Descrição do CNAE'
    "FKF_DSCNAE"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('CG1',1,xFilial('CG1')+FKF->FKF_CNAE,'CG1_DESCRI'),'')") ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0027					, ;	// [01] Titulo do campo		//"Descrição do Tipo de Repasse"
    STR0027					, ;	// [02] ToolTip do campo 	//"Descrição do Tipo de Repasse"
    "FKF_DSCTRP"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0G'+FKF->FKF_TPREPA,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual

    oStruFKF:AddField(			  ;
    STR0028					, ;	// [01] Titulo do campo		//"Descrição do Tipo de Serviço"
    STR0028					, ;	// [02] ToolTip do campo 	//"Descrição do Tipo de Serviço"
    "FKF_DSCTSR"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD,"IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'DZ'+FKF->FKF_TPSERV,'X5_DESCRI'),'')" ) ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0029					, ;	// [01] Titulo do campo		//"Descrição do CNO"
    STR0029					, ;	// [02] ToolTip do campo 	//"Descrição do CNO"
    "FKF_DSCCNO"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SON',1,xFilial('SON')+FKF->FKF_CNO,'ON_DESC'),'')") ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0030					, ;	// [01] Titulo do campo		//"Descrição do Bem"
    STR0030					, ;	// [02] ToolTip do campo 	//"Descrição do Bem"
    "FKF_DSCBEM"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0I'+FKF->FKF_CODBEM,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(			  ;
    STR0031					, ;	// [01] Titulo do campo		//"Descrição do Serviço"
    STR0031					, ;	// [02] ToolTip do campo 	//"Descrição do Serviço"
    "FKF_DSCSRV"			, ;	// [03] Id do Field
    "C"						, ;	// [04] Tipo do campo
    200						, ;	// [05] Tamanho do campo
    0						, ;	// [06] Decimal do campo
    { || .T. }				, ;	// [07] Code-block de validação do campo
    { || .F. }				, ;	// [08] Code-block de validação When do campo
                            , ;	// [09] Lista de valores permitido do campo
    .F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SX5',1,xFilial('SX5')+'0H'+FKF->FKF_CODSER,'X5_DESCRI'),'')") ,,,;// [11] Inicializador Padrão do campo
    .T.)						// [14] Virtual


    oStruFKF:AddField(' ','FKF_ALIAS' ,'FKF_ALIAS'	,'C',3,0,/*bValid*/, /*bWhen*/,,.F.,)

    oStruFKF:SetProperty( 'FKF_IDDOC'         , MODEL_FIELD_OBRIGAT, .F.)
    oStruFKF:SetProperty( 'FKF_CPRB'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986CPRBIni()'))

    //inicializa o campo com sim
    If __cAlias986 == 'SE1' .and. __lFKF_RECPIX
        oStruFKF:SetProperty('FKF_RECPIX', MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986PixIni()'))
        oStruFKF:SetProperty("FKF_RECPIX", MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN , 'F986PixVal()'))
    EndIf
    //valid para qr code
     If __cAlias986 == 'SE2' .and. __lFKF_PAGPIX .and. !FwIsInCallStack("Fa986grava")
         oStruFKF:SetProperty( 'FKF_PAGPIX', MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"F986QRCode()"))
     EndIf

    If __lFKF_CEDENT	// Cedente
        oStruFKF:SetProperty( 'FKF_CEDNOM'	  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,"F986IniCed()"))
    EndIf
    oStruFKG:SetProperty( 'FKG_IDDOC'         , MODEL_FIELD_OBRIGAT, .F.)
    oStruFKG:SetProperty( 'FKG_IDFKE'         , MODEL_FIELD_WHEN, {||&cCampo<>'S'} )
    oStruFKG:SetProperty( 'FKG_DESATR'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986DesIn()'))
    oStruFKG:SetProperty( 'FKG_TPPROC'		  , MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'F986IniNu()'))
    oStruFKG:SetProperty( 'FKG_NUMPRO'		  , MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,'F986VldNP()'))

    oStruFKF:SetProperty( "FKF_CPRB"  , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CNAE"  , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_TPREPA", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_TPSERV", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CNO"   , MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_INDSUS", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_INDDEC", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CODBEM", MODEL_FIELD_WHEN, {||Fa986When()} )
    oStruFKF:SetProperty( "FKF_CODSER", MODEL_FIELD_WHEN, {||Fa986When()} )
    
    //Quando acionado via browse e exibir a aba de edicao da FKG, nao permitir incluir na grid quando a acao nao for 'Informativo'
    If !__lBrowse
        bWhenValor := {|| &cCampo <> 'S' }
    Else
        bWhenValor := {|| &cCampo <> 'S' .And. &cAcao <> '3' }
    Endif
    oStruFKG:SetProperty( 'FKG_VALOR', MODEL_FIELD_WHEN, bWhenValor )

    //Gatilhos
    oStruFKF:AddTrigger( "FKF_CNAE"	 , "FKF_DSCNAE", { || .T. }, { |oModel| F986Gatil(oModel, "FKF_CNAE") } )
    oStruFKF:AddTrigger( "FKF_TPREPA", "FKF_DSCTRP", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_TPREPA") } )
    oStruFKF:AddTrigger( "FKF_TPSERV", "FKF_DSCTSR", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_TPSERV") } )
    oStruFKF:AddTrigger( "FKF_CNO"	 , "FKF_DSCCNO", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CNO") } )
    oStruFKF:AddTrigger( "FKF_CODBEM", "FKF_DSCBEM", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CODBEM") } )
    oStruFKF:AddTrigger( "FKF_CODSER", "FKF_DSCSRV", { || .T.}, { |oModel| F986Gatil(oModel, "FKF_CODSER") } )	
    oStruFKG:AddTrigger( "FKG_IDFKE","FKG_IDFKE", {|| .T. }  , {|| F986FkeGt() }  )
    oStruFKG:AddTrigger( "FKG_NUMPRO","FKG_NUMPRO", {|| .T. }  , {|| F986CcfGt() }  )
    If __lFKG_CALCUL
        oStruFKG:AddTrigger( "FKG_BASECA","FKG_VALOR", {|| .T. }  , {|| F986BaseCa() }  )
    EndIf

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New("FINA986", /*PreValidacao*/ , {|oModel| Fa986Pos(oModel)} /*PosValidacao*/, {|oModel|Fa986Conf()} /*bCommit*/)

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( 'FKFMASTER', , oStruFKF )

    // Adiciona ao modelo uma estrutura de formulário de edição por grid
    oModel:AddGrid( 'FKGDETAIL', 'FKFMASTER', oStruFKG, /*bLinePre*/, bLinePost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    If __nOPER==MODEL_OPERATION_UPDATE .and. &cCampo == 'S'
        oModel:GetModel( 'FKGDETAIL' ):SetNoInsertLine( .T. )
        oModel:GetModel( 'FKGDETAIL' ):SetNoDeleteLine( .T. )
    Elseif __nOPER==MODEL_OPERATION_UPDATE .and. __lBrowse
        oModel:GetModel( 'FKGDETAIL' ):SetNoDeleteLine( .T. )
    EndIf

    oModel:SetPrimaryKey({'FKF_FILIAL','FKF_IDDOC'})

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( 'FKGDETAIL', { { 'FKG_FILIAL', 'xFilial( "FKG" )' }, { 'FKG_IDDOC', 'FKF_IDDOC' } }, FKG->( IndexKey( 1 ) ) )

    // Liga o controle de nao repeticao de linha
    oModel:GetModel( 'FKGDETAIL' ):SetUniqueLine( { 'FKG_ITEM' } )

    // Indica que é opcional ter dados informados na Grid
    oModel:GetModel( 'FKGDETAIL' ):SetOptional(.T.)

    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription(STR0010)//"Cadastro"

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'FKFMASTER' ):SetDescription( STR0002 )//'Obrigações do título'
    oModel:GetModel( 'FKGDETAIL' ):SetDescription( STR0003 ) //'Impostos X Atributos'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado sem exibir o campo IDDOC
    Local oStruFKF	:= FWFormStruct(2,'FKF', { |x| !ALLTRIM(x) $ "FKF_IDDOC , FKF_ESPEC"})
    Local oStruFKG	:= FWFormStruct( 2, 'FKG', { |x| !ALLTRIM(x) $ "FKG_IDDOC"} )

    // Cria a estrutura a ser usada na View
    Local oModel := FWLoadModel("FINA986")
    Local oView

    oStruFKF:SetProperty( 'FKF_TPREPA' , MVC_VIEW_COMBOBOX,  )

    oStruFKF:SetProperty( 'FKF_CPRB'   , MVC_VIEW_ORDEM, '01' )
    oStruFKF:SetProperty( 'FKF_INDSUS' , MVC_VIEW_ORDEM, '02' )
    oStruFKF:SetProperty( 'FKF_INDDEC' , MVC_VIEW_ORDEM, '03' )

    oStruFKF:AddField("FKF_DSCNAE" , "05", STR0026, STR0026 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//'Descrição do CNAE'
    oStruFKF:AddField("FKF_DSCTRP" , "07", STR0027, STR0027 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Tipo de Repasse"
    oStruFKF:AddField("FKF_DSCTSR" , "09", STR0027, STR0027 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Tipo de Serviço"
    oStruFKF:AddField("FKF_DSCCNO" , "11", STR0029, STR0029 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do CNO"
    oStruFKF:AddField("FKF_DSCBEM" , "13", STR0030, STR0030 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"2"/*cFolder*/)//"Descrição do Bem"
    oStruFKF:AddField("FKF_DSCSRV" , "15", STR0031, STR0031 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"2"/*cFolder*/)//"Descrição do Serviço"

    oStruFKF:SetProperty( 'FKF_CNAE'   , MVC_VIEW_ORDEM, '04' )
    oStruFKF:SetProperty( 'FKF_TPREPA' , MVC_VIEW_ORDEM, '06' )
    oStruFKF:SetProperty( 'FKF_TPSERV' , MVC_VIEW_ORDEM, '08' )
    oStruFKF:SetProperty( 'FKF_CNO'	   , MVC_VIEW_ORDEM, '10' )
    oStruFKF:SetProperty( 'FKF_CODBEM' , MVC_VIEW_ORDEM, '12' )
    oStruFKF:SetProperty( 'FKF_CODSER' , MVC_VIEW_ORDEM, '14' )

    oStruFKG:SetProperty( 'FKG_IDFKE'  , MVC_VIEW_ORDEM, '04' )
    oStruFKG:SetProperty( 'FKG_TPIMP'  , MVC_VIEW_ORDEM, '05' )
    oStruFKG:SetProperty( 'FKG_DEDACR' , MVC_VIEW_ORDEM, '06' )
    oStruFKG:SetProperty( 'FKG_APLICA' , MVC_VIEW_ORDEM, '07' )
    oStruFKG:SetProperty( 'FKG_TPATRB' , MVC_VIEW_ORDEM, '10' )
    oStruFKG:SetProperty( 'FKG_DESATR' , MVC_VIEW_ORDEM, '11' )
    oStruFKG:SetProperty( 'FKG_DESCR'  , MVC_VIEW_ORDEM, '12' )
    oStruFKG:SetProperty( 'FKG_VALOR'  , MVC_VIEW_ORDEM, '14' )
    oStruFKG:SetProperty( 'FKG_NUMPRO' , MVC_VIEW_ORDEM, '15' )
    oStruFKG:SetProperty( 'FKG_TPPROC' , MVC_VIEW_ORDEM, '16' )

    If __lFKG_CALCUL
        oStruFKG:SetProperty( 'FKG_CALCUL' , MVC_VIEW_ORDEM, '08' )
        oStruFKG:SetProperty( 'FKG_PERCEN' , MVC_VIEW_ORDEM, '09' )
        oStruFKG:SetProperty( 'FKG_BASECA' , MVC_VIEW_ORDEM, '13' )
    EndIf
   
    // Cria o objeto de View
    oView := FWFormView():New( )

    // Define qual o Modelo de dados será utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_FKF', oStruFKF, 'FKFMASTER' )

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oView:AddGrid(  'VIEW_FKG', oStruFKG, 'FKGDETAIL' )
    oStruFKG:RemoveField( 'FKG_TITINS' )
    oStruFKG:RemoveField( 'FKG_APURIN' )
    If __lFKF_ORIINS
        oStruFKF:RemoveField( 'FKF_ORIINS' )
    EndIf

    //Remover campo FKF_PAGPIX no Contas a receber
    If __cAlias986 == 'SE1' .and. __lFKF_PAGPIX
        oStruFKF:RemoveField( 'FKF_PAGPIX' )
    EndIf

    //Remover campo FKF_RECPIX no Contas a Pagar
    If __lFKF_RECPIX .And. (__cAlias986 == 'SE2' .Or. !__TableF71 .Or. !__lFina890)
        oStruFKF:RemoveField( 'FKF_RECPIX' )
    EndIf

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )

    oView:CreateFolder( 'FOLDER', 'SUPERIOR')
    oView:AddSheet('FOLDER','ABA_COMPL',STR0001)
    oView:AddSheet('FOLDER','ABA_REGRAS',STR0004)//'Complemento do Imposto X Títulos'
    oView:CreateHorizontalBox( 'SUPERIOR1', 100, , , 'FOLDER', 'ABA_COMPL')
    oView:CreateHorizontalBox( 'SUPERIOR2', 100, , , 'FOLDER', 'ABA_REGRAS')

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_FKF', 'SUPERIOR1' )
    oView:SetOwnerView( 'VIEW_FKG', 'SUPERIOR2' )

    // Define campos que terao Auto Incremento
    oView:AddIncrementField( 'VIEW_FKG', 'FKG_ITEM' )

    // Liga a identificacao do componente
    oView:EnableTitleView('VIEW_FKG',STR0005)//'Complemento do Imposto'

    //Aqui é a definição de exibir dois campos por linha
    oView:SetViewProperty( "VIEW_FKF", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    //adicionar botao Na tela ler pix
    If !isBlind()
        If __cAlias986 == 'SE2' .and. __lFKF_PAGPIX .and. (INCLUI .or. ALTERA)
            oView:AddUserButton(STR0052, 'CLIPS', {|oView| readBarcode()}, , ,)
        EndIf
    EndIf
    oView:EnableControlBar(.F.)

    //Habilita ou não a edição da Grid de Complemento de impostos (FKG)
    Fa986Fld(oView)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Fld
Não permite visualizar a folder FKG para titulos que nao seja o principal

@param oView - objeto View ativo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function Fa986Fld(oView)

    If !Fa986Folder("2") //Determina se aba deve ser exibida
        oView:SetOnlyView( 'VIEW_FKG' )   
    EndIf
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Pos
Função para setar um valor no model, para nao ocorrer error log ao mudar somente a grid sem mudar o field

@param oModel - objeto do model ativo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static function Fa986Pos(oModel)

If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and.  oModel:GetOperation() <> MODEL_OPERATION_VIEW
    oModel:Setvalue("FKFMASTER","FKF_ALIAS",__cAlias986)    
EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Conf
Botão confirmação, para atualizar os valores dos impostos sem gravar os dados na tabela
pois estes deverão ser gravados na confirmação do titulo

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function Fa986Conf()
    Local oView 	:= FwViewActive()
    Local oModel	:= FwModelActive()
    Local lDel		:= (__nOPER == MODEL_OPERATION_UPDATE)
    Local lRecalc   := .F.
    Local lYoN		:= .F.
    Local lCommit   := .F.
    Local lExecAuto := FwIsInCallStack("F986ExAut")
    Local lBlind	:= IsBlind()

    If (oView == NIL .or. oView:oModel:cId <> "FINA986") .and. !lExecAuto
        lCommit := .T.  // Commit do model por rotinas externas ( != de FINA040 e FINA050)
    Else
        lRecalc := Fa986Folder("2") //Se a aba 'Titulos x Impostos' nao for exibida, nao deve recalcular os impostos
    EndIf

    If lRecalc
        If lBlind
            lYoN := .T.
        Else
            lYoN := MsgYesNo( STR0007, STR0008 ) //"Ao confirmar, caso tenha cadastrado alguma regra de impostos, o imposto ser  recalculado. Confirma?"//"Aten‡?o"
        EndIf
        //No realiza a gravacao, s¢ guardo o model
        If lYoN
            If !lExecAuto
                __cXml986 := oModel:GetXMLData( , , , , lDel, .T. )
            Endif
            //atualiza a tela com os valores
            If __cAlias986 == "SE1"
                If M->E1_VALOR > 0
                    SA1->(dbSetOrder(1))
                    SA1->(msSeek(xFilial('SA1')+M->E1_CLIENTE+M->E1_LOJA))
                    fa040natur()
                EndIf
            ElseIf __cAlias986 == "SE2"
                If M->E2_VALOR > 0
                    SA2->(dbSetOrder(1))
                    SA2->(msSeek(xFilial('SA2')+M->E2_FORNECE+M->E2_LOJA))
                    FA050Natur()
                EndIf
            EndIf
        EndIf
    ElseIf __lBrowse .or. lCommit
        If  __nOPER == MODEL_OPERATION_INSERT
            If __cAlias986 == "SE1"
                Fa986grava("SE1","FINA040")
            ElseIf __cAlias986 == "SE2"
                Fa986grava("SE2","FINA050")
            EndIf
        Else
            If oModel:VldData()
                if __lFKF_PAGPIX .and. __cAlias986 == "SE2"
                    F986FPag()
                Endif
                FwFormCommit(oModel)
                If __lFKF_RECPIX .and. __cAlias986 == "SE1" .and. __TableF71 .and. __lFina890 
                    F986PJob()
                Endif
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])
                Help( ,,"FINA986GRV",,cLog, 1, 0 )
            Endif
            oModel:Deactivate()
            oModel:Destroy()
            oModel:= Nil
            oSubFKG := nil
        EndIf
    ElseIf !lExecAuto
        __cXml986 := oModel:GetXMLData( , , , , lDel, .T. )
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F986LimpaVar
Limpa as variaveis estaticas ao fim do processo de gravação para criar um novo model

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function F986LimpaVar()
    __cXml986 := ""
    __cAlias986 := ""
    __nOPER := 0
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986grava
Função de gravação do model chamada pelas rotinas de cadastro dos titulos a pagar/receber
@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar
@param cOrigem Informar a rotina de origem do titulo

@return retorna .T. se gravação estiver ok nas tabelas FKF e FKG
@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986grava(cAliasC,cOrigem, lGeraPix)
    Local lRet := .T.
    Local oModel := NIL
    Local oSubFKG := NIL
    Local nI := 0
    Local cLog := ""
    //para armazenar o valor do INSS calculado original
    Local nINSSTot 	:= 0
    Local nValInss	:= 0
    Local lCalcProc	:= .T.
    Local aArea		:= GetArea()
    Local lEspecie	:= .F.
    Local lMata103	:= .F.
    Local lMata461	:= .F.
    Local lExterno  := .F.
    Local cTipo     As Character
    Local cDocTEF   As Character

    //Recriando as variáveis no escopo da função
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    Default cOrigem  := "FINA050"
    Default lGeraPix := .T.
    __lGeraPix := lGeraPix 
    
    if !IsInCallStack("Fa986Conf")        
        F986IniVar(cAliasC,.F.)
    endif

    lMata103	:= alltrim(cOrigem) $ "MATA103|MATA100|"
    lMata461	:= alltrim(cOrigem) $ "MATA461|MATA460"
    lExterno    := Iif(M->E1_TIPO <> Nil .Or. M->E2_TIPO <> Nil, .F.,.T.)
    __lBrowse     := Iif(lExterno,.T.,__lBrowse)
    
    DbSelectArea("CCF")
    __cAlias986 := cAliasC

    If cAliasC == "SE2"
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
        SE2->E2_FORNECE+ "|" + SE2->E2_LOJA

    ElseIf cAliasC == "SE1"
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
        SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
    EndIf

    cIdDoc := FINGRVFK7(cAliasC, cChave)

    If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)

        oModel := FwLoadModel("FINA986")
        oModel:LoadXMLData(__cXml986)

        oModel:SetValue("FKFMASTER","FKF_IDDOC",cIdDoc)
        oSubFKG:= oModel:GetModel("FKGDETAIL")

        For nI := 1 To oSubFKG:Length()
            oSubFKG:GoLine(nI)
            lCalcProc := .T.
            If !oSubFKG:IsDeleted( nI ) .and. (oSubFKG:IsUpdated() .or.  (oSubFKG:IsInserted() .and. !Empty(oSubFKG:GetValue("FKG_IDFKE")) ))
                oSubFKG:SetValue("FKG_IDDOC",cIdDoc)
                If !Empty(oSubFKG:GetValue("FKG_NUMPRO")) .and. CCF->(DBSeek(xFilial("CCF") + oSubFKG:GetValue("FKG_NUMPRO")))
                    lCalcProc := CCF->CCF_RESACA<>"3"
                Endif
                If !lCalcProc
                    oSubFKG:LoadValue("FKG_APURIN", "2")
                Else
                    oSubFKG:LoadValue("FKG_APURIN", "1")
                EndIf
            EndIf
        Next nI
    Else//grava valores padrao da FKF caso o usuario nao entrou na tela de complemento do titulo
        FKF->(DBSetOrder(1))
        If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            nOpc := MODEL_OPERATION_UPDATE
        Else
            nOpc := MODEL_OPERATION_INSERT
        EndIf
        oModel := FwLoadModel("FINA986")
        oModel:SetOperation(nOpc)
        oModel:Activate()
        __lGeraPix := .T.
        
        oModel:SetValue("FKFMASTER","FKF_IDDOC",cIdDoc)

        If lMata103			//NF Entrada
            //aguardano MAT informar os campos da nota de entrada

        ElseIf lMata461		//NF Saida
            If __lSF2_CNO
                oModel:SetValue("FKFMASTER","FKF_CNO",SF2->F2_CNO)
            EndIf
        EndIf

    EndIf

    //gravacao do valor original dos impostos sem a alteracao do complemento (essa informacao sera enviada ao REINF)
    If __lFKF_ORIINS .and. !lMata103 .and. !lMata461
        If cAliasC == "SE2"
            SA2->(DBSetOrder(1))
            SA2->(DBSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ))

            //INSS
            If SA2->A2_TIPO == "F" //Para pessoa fisica verifico o limite de deducao no mes
                nValInss := FCalcInsPF(SE2->E2_BASEINS, ,@nINSSTot,.F.,0,.T.,SE2->E2_EMISSAO,SE2->E2_VENCREA)
            Else
                nValInss := FCalcInsPJ(SE2->E2_BASEINS, ,@nINSSTot,.F.)
            Endif
            oModel:SetValue("FKFMASTER","FKF_ORIINS",nValInss)
                
        ElseIf cAliasC == "SE1"
            SED->(DBSetOrder(1))
            If SED->(DBSeek(xFilial("SED") + SE1->E1_NATUREZ  ))
                nValInss := CalcINSS(SE1->E1_BASEINS, .F.)
            EndIf
            oModel:SetValue("FKFMASTER","FKF_ORIINS",nValInss)
        EndIf
    Endif

    If __lFKFEspec .and. __lF040Espec
        lEspecie := F040Espec()
        oModel:SetValue("FKFMASTER","FKF_ESPEC",IIF(lEspecie,"S","N"))
    EndIf

    If oModel:VldData()
        lRet	 := .T.
        if __lFKF_PAGPIX .and. __cAlias986 == "SE2" 
            F986FPag()
        Endif
        FwFormCommit(oModel)
        cTipo   := IIf(__lBrowse, SE1->E1_TIPO,     M->E1_TIPO)
        cDocTEF := IIf(__lBrowse, SE1->E1_DOCTEF,   M->E1_DOCTEF)
        If __lFKF_RECPIX .and. __cAlias986 == "SE1" .and. __TableF71 .and. __lFina890 .And. !F986PIXLj(cTipo, cDocTEF)
            F986PJob()
        Endif
    Else
        lRet := .F.
        cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[6])
        Help( ,,"FINA986GRV",,cLog, 1, 0 )
    Endif

    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
    oSubFKG := nil

    F986LimpaVar()

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986excl
Função de exclusao do model tabelas FKF e FKG chamada pelas rotinas de cadastro dos titulos a pagar/receber
Deve estar posicionado no titulo.
@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar

@return retorna .T. se exclusão estiver ok nas tabelas FKF e FKG

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986excl(cAliasC)
    Local lRet := .T.
    Local oModel
    Local cIdDoc
    Local cLog := ""

    //Recriando as variáveis no escopo da função
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    If cAliasC == "SE2"
        cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
        SE2->E2_FORNECE+ "|" + SE2->E2_LOJA

    ElseIf cAliasC == "SE1"
        cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
        SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
    EndIf

    cIdDoc := FINGRVFK7(cAliasC, cChave)
    FKF->(DBSetOrder(1))
    If FKF->(DBSeek(xFilial("FKF") + cIdDoc ))

        oModel := FwLoadModel("FINA986")
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()
        If oModel:VldData()
            lRet	 := .T.
            FwFormCommit(oModel)
        Else
            lRet := .F.
            cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[6])
            Help( ,,"FINA986DEL",,cLog, 1, 0 )
        Endif

        oModel:Deactivate()
        oModel:Destroy()
        oModel:= Nil
        F986LimpaVar()
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986regra
Retorna o valor a ser deduzido/acrescentado ao imposto/base.
Chamado pelas rotinas de calculo de impostos

@param cAliasC Informar SE1 para contas a receber e SE2 para contas a pagar
@param cImposto Informar o código do imposto. Atualmente será implementado somente para o INSS
@param cTpDed Informar "1" para buscar as regras na base, "2" para buscar as regras no valor

@return nValImp retorna o valor calculado a ser deduzido/acrescido da base ou valor do imposto

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function Fa986regra(cAliasC As Character, cImposto As Character, cTpDed As Character)

Local oModel    As Object
Local oSubFKG   As Object
Local cIdDoc    As Character
Local nValImp   As Numeric
Local nI        As Numeric
Local cChave    As Character
Local nLin      As Numeric
Local lRet      As Logical
Local lCalcProc As Logical
Local aArea     As Array
Local aAreaSE2	As Array
Local aAreaSA2	As Array
Local cQuery	As Character
Local cFilFKG	As Character
Local lFinaBx	As Logical

// Recriando as variáveis no escopo da função
// Não posso efetuar a tipagem aqui, senão inicializam com valor default False
Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

cIdDoc      := ""
nValImp     := 0
nI          := 0
cChave      := ""
nLin        := 1
lRet        := .T.
lCalcProc   := .T.
aArea       := GetArea()
aAreaSE2	:= SE2->(GetArea())
aAreaSA2	:= SA2->(GetArea())
cQuery	    := ""
cFilFKG	    := ""
lFinaBx	    := FwIsInCallStack("FINA080") .OR. FwIsInCallStack("FINA241") .OR. FwIsInCallStack("FINA090") .OR. FwIsInCallStack("FINA091") .OR. ;
               FwIsInCallStack("FINA430") .OR. FwIsInCallStack("FINA590") .OR. FwIsInCallStack("FINA300") .OR. FwIsInCallStack("FINA340") 

DEFAULT cAliasC := ""
DEFAULT cImposto := ""
DEFAULT cTpDed := ""

DbSelectArea("CCF")
// Se for inclusao e tem model, se for alteracao ou rotinas de baixa
If ( (INCLUI .and. !Empty(__cXml986)) .or. ALTERA ) .OR. lFinaBx

    If Valtype(__cXml986) == "C"  .and. !Empty(__cXml986)
        oModel := FwLoadModel("FINA986")
        oModel:LoadXMLData(__cXml986)
    Else
        If cAliasC == "SE2"
            cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
            SE2->E2_FORNECE+ "|" + SE2->E2_LOJA

        ElseIf cAliasC == "SE1"
            cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
            SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
        EndIf
        cIdDoc := FINGRVFK7(cAliasC, cChave)
        FKF->(DBSetOrder(1))
        If !lFinaBx .and. FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
            oModel := FwLoadModel("FINA986")
            oModel:SetOperation( MODEL_OPERATION_VIEW ) //visualizacao
            oModel:Activate()
        Else
            lRet:= .F.
        EndIf

        If lFinaBx
                
            lRet	:= .F.
            cQuery	:= ""
            cFilFKG	:= xFilial("FKF")

            If __oSttFKG == NIL

                cQuery := " SELECT ( ACRES.FKG_VALOR - DEDUZ.FKG_VALOR ) VALOR "
                cQuery += " FROM ( SELECT ISNULL( SUM(FKG_VALOR),0) FKG_VALOR "
                cQuery += 		 " FROM " + RetSQLName("FKG") + " FKG "
                cQuery += 		 " WHERE FKG.FKG_FILIAL = ? "
                cQuery +=				" AND FKG.FKG_IDDOC = ? "
                cQuery +=				" AND FKG.FKG_APURIN <> '2' "
                cQuery +=				" AND FKG.FKG_TPIMP = ? "
                cQuery +=				" AND FKG.FKG_APLICA = ? "
                cQuery +=				" AND FKG_DEDACR = '2' " // soma
                cQuery +=				" AND FKG.D_E_L_E_T_ = ' ' ) ACRES, "
                cQuery +=		  " ( SELECT ISNULL( SUM(FKG_VALOR),0) FKG_VALOR "
                cQuery +=			" FROM " + RetSQLName("FKG") + " FKG "
                cQuery +=			" WHERE	FKG.FKG_FILIAL = ? "
                cQuery +=					" AND FKG.FKG_IDDOC = ? "
                cQuery +=					" AND FKG.FKG_APURIN <> '2' "
                cQuery +=					" AND FKG.FKG_TPIMP = ? "
                cQuery +=					" AND FKG.FKG_APLICA = ? "
                cQuery +=					" AND FKG_DEDACR = '1' " // subtração
                cQuery +=					" AND FKG.D_E_L_E_T_ = ' ' ) DEDUZ "
                
                cQuery := ChangeQuery(cQuery)
                __oSttFKG := FWPreparedStatement():New(cQuery)
            EndIf
            
            __oSttFKG:SetString( 1, cFilFKG	)
            __oSttFKG:SetString( 2, cIdDoc	)
            __oSttFKG:SetString( 3, cImposto)
            __oSttFKG:SetString( 4, cTpDed	)
            __oSttFKG:SetString( 5, cFilFKG	)
            __oSttFKG:SetString( 6, cIdDoc	)
            __oSttFKG:SetString( 7, cImposto)
            __oSttFKG:SetString( 8, cTpDed	)

            cQuery := __oSttFKG:GetFixQuery()

            nValImp := MpSysExecScalar( cQuery,"VALOR" )
        EndIf
    EndIf
    If lRet
        oSubFKG:= oModel:GetModel("FKGDETAIL")
        nLin := oSubFKG:GetLine()
        For nI := 1 To oSubFKG:Length()
            oSubFKG:GoLine(nI)
            //se for processo, nao influenciar no calculo do imposto
            If !Empty(oSubFKG:GetValue("FKG_NUMPRO")) .and. CCF->(DbSeek(xFilial("CCF") + oSubFKG:GetValue("FKG_NUMPRO")))
                If INCLUI
                    lCalcProc := CCF->CCF_RESACA<>"3"
                Else
                    lCalcProc := oSubFKG:GetValue("FKG_APURIN")<>"2"
                EndIf
            Else
                lCalcProc := .T.
            EndIf
            If lCalcProc .AND. !oSubFKG:IsDeleted( nI ) .and. Alltrim(oSubFKG:GetValue("FKG_TPIMP")) == cImposto .and. oSubFKG:GetValue("FKG_APLICA") == cTpDed
                If oSubFKG:GetValue("FKG_DEDACR") == "2" //Acrescimo
                    nValImp += oSubFKG:GetValue("FKG_VALOR")
                ElseIf oSubFKG:GetValue("FKG_DEDACR") == "1"	//Deduz
                    nValImp -= oSubFKG:GetValue("FKG_VALOR")
                EndIf
            EndIf

        Next nI

    EndIf
EndIf

If oModel != NIL
    oModel:Deactivate()
    oModel:Destroy()
    oModel:= Nil
    oSubFKG:= Nil
Endif

RestArea(aAreaSA2)
RestArea(aAreaSE2)
RestArea(aArea)
FwFreeArray(aAreaSA2)
FwFreeArray(aAreaSE2)
FwFreeArray(aArea)

Return nValImp

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Numpr
Função utilizada no X3_WHEN do campo  FKG_NUMPRO para habilitar este campo somente
se a regra escolhida for de processo judicial

@return lRet Retorna .T. se campo pode ser liberado para edição

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function Fa986Numpr()
Local lRet := .T.
Local oModel := FWModelActive()
Local oSubFKG:= oModel:GetModel("FKGDETAIL")

If Alltrim(oSubFKG:GetValue("FKG_TPATRB")) != "004"
    lRet := .F.
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986FilFKE
Filtro da consulta padrão FKE para retornar as regras somente da carteira a pagar ou receber ou todas

@return cFiltro Retorna o filtro SQL

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F986FilFKE()
Local cFiltro := ""
If __cAlias986 == "SE2"
    cFiltro := "@FKE_CARTEI IN ('1','3')"
Else
    cFiltro := "@FKE_CARTEI IN ('2','3')"
EndIf
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlFke
X3_valid do campo FKG_IDFKE para validar se a regra de imposto escolhida é válida para a carteira

@return lRet Retorna .T. se permite selecionar esta regra para a carteira

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
//X3_valid do campo FKG_IDFKE
Function F986VlFke()
Local lRet := .F.
Local aArea := GetArea()

dbSelectArea("FKE")
FKE->(dbSetOrder(1))
If dbSeek(xFilial("FKE")+ M->FKG_IDFKE)
    If __cAlias986 == "SE2"
        lRet := FKE->FKE_CARTEI $ '1|3'
    Else
        lRet := FKE->FKE_CARTEI $ '2|3'
    EndIf
EndIf

If !lRet
    Alert(STR0009)//"Complemento do imposto não válido para esta carteira."
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VlVal
X3_VALID do campo FKG_VALOR para não permitir incluir nas regras, um valor que seja maior a base ou valor calculado

@return lRet Retorna .T. se permite selecionar esta regra para a carteira

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
//X3_VALID do campo FKG_VALOR
Function F986VlVal()
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniNu
Funcao para inicializar o valor do campo FKG_NUMPRO para o FKG_TPPROC

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986IniNu()
Local cRet := ""
Local oModel := FwModelActive()
Local oModFKG

If !INCLUI .and. oModel != NIL
    oModFKG := oModel:GetModel("FKGDETAIL")
    If oModFKG:length()== 0
        DbSelectArea("CCF")
        CCF->(DbSetorder(1))
        If CCF->(DBSeek(xFilial("CCF") + FKG->FKG_NUMPRO))
            cRet:= CCF->CCF_TIPO
        Endif
    EndIf
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniCed
Funcao para inicializar o valor do campo FKF_CEDNOM

@since  31/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986IniCed()

    Local aAreaSA2 := {}
    Local cRet := ""
    Local oModel := FwModelActive()
    Local oModFKF

    If !INCLUI .and. oModel != NIL
        oModFKF := oModel:GetModel("FKFMASTER")
        If !Empty(oModFKF:GetValue('FKF_CEDENT')) .And. !Empty(oModFKF:GetValue('FKF_LOJACE'))
            aAreaSA2 := SA2->(GetArea())
            SA2->(DbSetorder(1))
            If SA2->(DBSeek(xFilial("SA2") + M->(FKF_CEDENT+FKF_LOJACE) ) )
                cRet:= SA2->A2_NOME
            Endif
            SA2->(RestArea(aAreaSA2))
        EndIf
    Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986DesIn
Funcao para inicializar a descrição complementar do cadastro do complemento

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986DesIn()

Local cRet := ""
Local oModel := FwModelActive()
Local oModFKG

If !INCLUI .and. oModel != NIL
    oModFKG := oModel:GetModel("FKGDETAIL")
    If oModFKG:length()== 0
        cRet:=POSICIONE("SX5",1,XFILIAL("SX5")+"0D"+FKG->FKG_TPATRB,"X5_DESCRI")
    EndIf
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986FkeGt
Funcao gatilhar dados do complemento de imposto

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986FkeGt()

Local oModel := FwModelActive()
Local oSubFKG := oModel:GetModel("FKGDETAIL")
Local cRet 	:= ""

DbSelectArea("FKE")
FKE->(DbSetorder(1))

If FKE->(DBSeek(xFilial("FKE") + oSubFKG:GetValue("FKG_IDFKE")))
    oSubFKG:SetValue("FKG_TPIMP",FKE->FKE_TPIMP  )
    oSubFKG:SetValue("FKG_DEDACR",FKE->FKE_DEDACR )
    oSubFKG:SetValue("FKG_APLICA",FKE->FKE_APLICA )
    oSubFKG:SetValue("FKG_TPATRB",FKE->FKE_TPATRB )
    If __lFKG_CALCUL
        oSubFKG:SetValue("FKG_CALCUL",FKE->FKE_CALCUL )
        oSubFKG:SetValue("FKG_PERCEN",FKE->FKE_PERCEN )
        oSubFKG:LoadValue("FKG_BASECA",0)
    EndIf
    oSubFKG:SetValue("FKG_DESATR",POSICIONE("SX5",1,XFILIAL("SX5")+"0D"+FKE->FKE_TPATRB,"X5_DESCRI")  )
    oSubFKG:SetValue("FKG_VALOR",0)
    oSubFKG:LoadValue("FKG_NUMPRO",SPACE(TAMSX3("FKG_NUMPRO")[1]))
    oSubFKG:LoadValue("FKG_TPPROC",SPACE(TAMSX3("FKG_TPPROC")[1]))
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986CcfGt
Funcao gatilhar descrição do tipo de processo

@since  31/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F986CcfGt()

    Local oModel := FwModelActive()
    Local oSubFKG := oModel:GetModel("FKGDETAIL")
    Local cNumPro := oSubFKG:GetValue("FKG_NUMPRO")
    Local cTipoImp := Alltrim( oSubFKG:GetValue("FKG_TPIMP") )
    Local lRet 	:= .F.
    Local cRet 	:= ""

    DbSelectArea("CCF")
    CCF->(DbSetorder(1))

    If CCF->(DBSeek(xFilial("CCF")+cNumPro))
        
        oSubFKG:SetValue( "FKG_TPPROC",CCF->CCF_TIPO )
        
        While !lRet .And. xFilial("CCF")+cNumPro == CCF->(CCF_FILIAL+CCF_NUMERO)
            
            If cTipoImp == "INSS" .And. CCF->CCF_TRIB $ "1|2"
                lRet := .T.
            EndIf

            If lRet
                oSubFKG:SetValue("FKG_CODSUS",CCF->CCF_INDSUS)
            EndIf

            CCF->(DbSkip())
        EndDo
    Else
        oSubFKG:SetValue( "FKG_TPPROC",CriaVar("FKG_TPPROC") )
        oSubFKG:SetValue( "FKG_CODSUS",CriaVar("FKG_CODSUS") )
    Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986VldNP()
Função para validar o número do processo

@since  31/05/2019
@version P11
/*/
//-------------------------------------------------------------------
Function F986VldNP()

    Local oModel := FwModelActive()
    Local lRet 	:= .F.
    Local cNumPro := oModel:GetValue("FKGDETAIL","FKG_NUMPRO")
    Local cTipoImp := ""

    CCF->(DbSetorder(1))
    
    If !Empty(cNumPro)
        If CCF->( DBSeek(xFilial("CCF")+cNumPro) )

            cTipoImp := Alltrim( oModel:GetValue("FKGDETAIL","FKG_TPIMP") )

            While !lRet .And. CCF->(CCF_FILIAL+CCF_NUMERO) == xFilial("CCF")+cNumPro

                If cTipoImp == "INSS" .And. CCF->CCF_TRIB $ "1|2"
                    lRet := .T.
                EndIf

                CCF->(DbSkip())
            EndDo

            If !lRet
                Help( ,,"FKGTPIMP1",,STR0039, 1, 0,,,,,,{STR0040} ) //"O Código do complemento de imposto e o processo judicial não se referem ao mesmo tipo de imposto."###"Por favor, verifique os campos Código e Processo Jud. ou utilize a consulta F3 para obter os processos judiciais referentes ao tipo de imposto."
            Endif

        Else
            Help( ,,"FKGTPIMP2",,STR0041, 1, 0,,,,,,{STR0042} ) //"O código do processo judicial informado é inválido"###"Por favor, verifique se o processo judicial informado se encontra cadastrado ou utilize a consulta F3 para obter os processos judiciais referentes ao tipo de imposto."
        Endif
    Else 
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986ExAut
Funcao para carregar o model quando a inclusão do título for via execauto

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986ExAut(cAliasC, aFKF, aFKG, nOpca, aExecAut)

    Local cIdDoc 	:= ""
    Local cChave 	:= ""
    Local oModel	:= NIL
    Local oSubFKG	:= NIL
    Local nPos		:= 1
    Local nPosFKG	:= 1
    Local nTotFKG	:= Len(aFKG)
    Local nChaveFKG	:= 0
    Local lRet		:= .T.
    Local lAlt		:= nOpca==MODEL_OPERATION_UPDATE
    Local lNewLin	:= .F.
    Local nFKGDel	:= 0

    //Recriando as variáveis no escopo da função
    Private INCLUI := IIf(Type('INCLUI') == 'L', INCLUI, .F.)
    Private ALTERA := IIf(Type('ALTERA') == 'L', ALTERA, .F.)

    Default aExecAut := {}
    
    //Inicializa variáveis estáticas
    if !IsInCallStack("Fa986Conf")        
        F986IniVar(cAliasC,.F.)
    endif

    __cAlias986 := cAliasC
    __aDadosTit := AClone(aExecAut) //Armazena dados do título em array quando for ExecAuto

    If nOpca <>  MODEL_OPERATION_VIEW
        If nOpca == MODEL_OPERATION_UPDATE
            If cAliasC == "SE1" // se veio do contas a receber
                cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
                SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
            ElseIf  cAliasC == "SE2" // se veio do contas a pagar
                cChave := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" +;
                SE2->E2_FORNECE+ "|" + SE2->E2_LOJA
                cIdDoc := FINGRVFK7(cAliasC, cChave)
            EndIf

            cIdDoc := FINGRVFK7(cAliasC, cChave)
            FKF->(DBSetOrder(1))
            lRet := FKF->(DBSeek(xFilial("FKF") + cIdDoc ))
        Endif
        If lRet
            oModel := FwLoadModel("FINA986")
            oModel:SetOperation( nOpca )
            oModel:Activate()

            oSubFKG:= oModel:GetModel("FKGDETAIL")

            If nOpca <> MODEL_OPERATION_DELETE
                For nPos := 1 to Len(aFKF)
                    If !(aFKF[nPos][1] $ "FKF_IDDOC")
                        oModel:SetValue("FKFMASTER",aFKF[nPos][1],aFKF[nPos][2])
                    Endif
                Next
                If nOpca == MODEL_OPERATION_INSERT
                    For nPos := 1 to nTotFKG
                        For nPosFKG:= 1 to Len(aFKG[nPos])
                            oSubFKG:SetValue(aFKG[nPos][nPosFKG][1],aFKG[nPos][nPosFKG][2])
                        Next
                        If nPos < nTotFKG
                            oSubFKG:AddLine()
                        Endif
                    Next
                Else
                    For nPos := 1 to nTotFKG
                        nChaveFKG := aScan(aFKG[nPos],{|x| x[1]="FKG_ITEM"})
                        lNewLin := .F.
                        If nChaveFKG > 0
                            If !oSubFKG:SeekLine({{aFKG[nPos][nChaveFKG][1],aFKG[nPos][nChaveFKG][2]}})//Caso não consiga posicionar, adiciona a linha
                                oSubFKG:AddLine()
                                lNewLin := .T.
                            Else
                                nFKGDel := aScan( aFKG[nPos], { |x| x[1] = "FKGDELETE"})
                                If nFKGDel > 0 .AND. aFKG[nPos][nFKGDel][2]
                                    oSubFKG:DeleteLine()
                                EndIf
                            Endif
                            For nPosFKG:= 1 to Len(aFKG[nPos])
                                If !(aFKG[nPos][nPosFKG][1] $ "FKG_ITEM|FKG_IDDOC|FKGDELETE").or. lNewLin
                                    oSubFKG:SetValue(aFKG[nPos][nPosFKG][1],aFKG[nPos][nPosFKG][2])
                                Endif
                            Next
                        Else
                            Help( ,,"FKGSEMCHV",,STR0011, 1, 0 )//"Informe o FKG_ITEM do complemento de imposto para alteração"
                            lRet:= .F.
                            Exit
                        Endif
                    Next
                Endif//nOpca == MODEL_OPERATION_INSERT
            Endif// nOpca <> MODEL_OPERATION_DELETE
            If lRet
                __cXml986 := oModel:GetXMLData(,,,,lAlt,.T.)

                Fa986Conf()
            EndIf
            oModel:Deactivate()
            oModel:Destroy()
            oModel:= Nil
        Endif//lRet

    Endif//nOpca <>  MODEL_OPERATION_VIEW



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986CNOIni
Funcao para carregar o campo FKF_CNO quando o titulo a pagar for de uma filial de obra

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986CNOIni()
Local cCNO := ""

If INCLUI .and. __cAlias986 == "SE2" .and. __lTableFOF
    If Empty(FwFldGet("FKF_CNO"))
        DbSelectArea("F0F")
        DbSetOrder(1)
        If F0F->(DbSeek(xFilial("F0F") + cFilAnt))
            cCNO := F0F->F0F_OBRA
        EndIf
    EndIf
EndIf

DbSelectArea("FKF")
Return cCNO


//-------------------------------------------------------------------
/*/{Protheus.doc} F986CPRBIni
Funcao para carregar o campo FKF_CPRB quando o titulo a pagar e o prestador for regime CPRB

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986CPRBIni()
Local cCPRB := "2"

If INCLUI .and. __cAlias986 == "SE2" .and. __lA2_CPRB
    If Empty(FwFldGet("FKF_CPRB")) .and. !Empty(SA2->A2_CPRB)
        cCPRB := SA2->A2_CPRB
    EndIf
EndIf

DbSelectArea("FKF")
Return cCPRB

//-------------------------------------------------------------------
/*/{Protheus.doc} F986BaseCa
Calcula o valor conforme o percentual do cadastro do complemento e a base de calculo informada

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986BaseCa()

    Local nValorCalc := 0

    If __lFKG_CALCUL
        If FwFldGet("FKG_CALCUL") == "2" //2-Percentual
            If Alltrim(FwFldGet("FKG_TPIMP")) == "INSS"
                nValorCalc := FwFldGet("FKG_BASECA")
            EndIf
            nValorCalc := (nValorCalc * FwFldGet("FKG_PERCEN")) / 100
        EndIf
    EndIf

Return nValorCalc


//-------------------------------------------------------------------
/*/{Protheus.doc} F986TRIB
Retorna o filtro da CCF para exibir na consulta padrão conforme o tipo de imposto selecionado do complemento

    1=Contribuição previdenciária (INSS)
    2=Contribuição previdenciária especial (INSS)
    3=FUNRURAL
    4=SENAR
    5=CPRB
    6=ICMS
    7=PIS
    8=COFINS

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Function F986TRIB()
    Local cRet := ""
    Local cTipoImp := ""
    Local cFiltro := ""
    
    cTipoImp := Alltrim( FwFldGet("FKG_TPIMP") )
    
    If cTipoImp == "INSS"
        cFiltro := "1|2"		
    EndIf
    
    If !Empty(cFiltro)
        cRet := "CCF->CCF_TRIB $ '" + cFiltro + "'"
    EndIf
Return cRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} Fa986GerI
Retorna se o cliente/fornecedor e natureza estão configurados para reter
algum dos impostos liberados para serem utilizados no Complemento de Imposto

@since  28/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function Fa986GerI( cNatu, cForCli, cLoja )

    Local lRet   	:= .F.
    Local lSeekED   := .F.
    Local lCliFor   := .F.
    Local AliClFor  := If(__cAlias986=='SE1','SA1','SA2')

    Default cNatu	:= ""
    Default cForCli	:= ""
    Default cLoja	:= ""

    //Posiciona na Natureza
    SED->( DBSetOrder(1) )
    lSeekED := SED->( DBSeek(xFilial('SED') + cNatu  ) )

    //Posiciona no cliente ou fornecedor de acordo com a carteira (pagar/receber)
    (AliClFor)->( DBSetOrder(1) )
    lCliFor := If(__cAlias986=='SE1',SA1->(DBSeek(xFilial('SA1')+cForCli+cLoja)), SA2->(DBSeek(xFilial('SA2')+cForCli+cLoja)))

    If lSeekED .and. lCliFor
        If __cAlias986=="SE1" //Carteira a Receber
            SA1->( DBSetOrder(1) )
            If SA1->( DBSeek( xFilial("SA1") + cForCli + cLoja ) )
                lSAInss := SA1->A1_RECINSS == 'S'
            EndIf
        Else //Carteira a Pagar
            If (SED->ED_CALCINS == 'S' .and. SA2->A2_RECINSS == 'S') .or. (SED->ED_CALCIRF == 'S' ) .or. (SED->ED_CALCPIS == 'S' .and.  SA2->A2_RECPIS == '2') .or. ;
            (SED->ED_CALCCOF == 'S' .and. SA2->A2_RECCOFI == '2') .or. (SED->ED_CALCCSL == 'S' .and. SA2->A2_RECCSLL == '2')
                lRet := .T.
            Endif
        Endif
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986Folder
Regras para exibir ou não as abas na View

@author Fabio Casagrande Lima
@since 14/05/2019
/*/
//-------------------------------------------------------------------
Static Function Fa986Folder(cFolder)
    
    Local lRet      := .T.
    Local cAliasTab := If(__lBrowse, __cAlias986+"->" , "M->")
    Local cRotinas	:= "MATA103|MATA100|MATA461|MATA460"
    Local cCampo	:= cAliasTab + Right(__cAlias986, 2) + "_LA"
    Local cTipos	:=	MVABATIM + "/" + MV_CRNEG + "/" + MVRECANT + "/" + MVTXA + "/" +;
        MVTAXA + "/" + MV_CPNEG + "/" + MVINSS + "/" + ;
        MVISS + "/" + MVCSABT + "/" + MVCFABT + "/" + MVPIABT + "SES/CID/INA/PIS/CSL/COF"

    Default cFolder := "2"
    
    /* cFolder:
    Aba 1 - Complemento do titulo
    Aba 2 - Complemento do Imposto X Títulos 
    */

    If cFolder == "2" .and. (INCLUI .or. ALTERA)
        /* As regras abaixo definem as situacoes onde a aba 'Complemento do Imposto x Titulos' nao sera exibida ao acionar o botao Complemento de Titulo:
            1) Para os tipos de titulo (E2_TIPO) contidos na variavel 'cTipos';
            2) Para os titulos cuja origem esteja contido na variavel 'cRotinas';
            3) Quando o botao for acionado de fora do titulo (browse)
            4) Para titulos já contabilizados (_LA = S)  */
        If &( cAliasTab + Right(__cAlias986, 2) + "_TIPO" ) $ cTipos .OR. ;
                (Alltrim( &( cAliasTab + Right(__cAlias986, 2) + "_ORIGEM" ) ) $ cRotinas ) .OR.;
                __lBrowse .OR. ;
                &cCampo == 'S'
            lRet := .F.
        Endif
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986Gatil()
Gatilho disparado de diversos campos para preenchimento dos campos 
de descrição do mesmo

@param		cCampo	- Campo origem
            cTarget - Campo alvo
@return		cDescri - conteudo do a ser gatilhado
@author		Pequim
@since		22/08/2019
@version	P12.1.25
/*/
//-------------------------------------------------------------------
Function F986Gatil(oModel As Object, cCampo As Char, cTarget As Char ) As Char

    Local cCpoGat	As Char
    Local cDescri	As Char

    Default oModel	:= Nil
    Default cCampo	:= ""
    Default cTarget	:= ""
        
    cDescri	:= ""

    If !Empty(cCampo)

        cCpoGat := oModel:GetValue(cCampo)
    
        If cCampo == "FKF_CNAE"
            cDescri := Posicione('CG1',1,xFilial('CG1')+cCpoGat,'CG1_DESCRI')
        ElseIf cCampo == "FKF_TPREPA"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0G'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_TPSERV"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'DZ'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_CNO"
            cDescri := Posicione('SON',1,xFilial('SON')+cCpoGat,'ON_DESC')
        ElseIf cCampo == "FKF_CODBEM"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0I'+cCpoGat,'X5_DESCRI')
        ElseIf cCampo == "FKF_CODSER"
            cDescri := Posicione('SX5',1,xFilial('SX5')+'0H'+cCpoGat,'X5_DESCRI')
        EndIf
    EndIf

Return cDescri

//-------------------------------------------------------------------
/*/{Protheus.doc} F986LINE
Valida‡?o da filial

@author Fabio Casagrande Lima
@since	05/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F986LINE(oModel) as Logical

    Local lRet      := .T.
    Local lGerImp   := .F.
    Local cAcao     := ""
    Local cTpAcao   := ""
    Local cNumProc  := ""
    Local cAliasTab := ""
    Local cNatu		:= ""
    Local cForCli	:= ""
    Local cLoja		:= ""
    Local cTpImp	:= ""
    Local cCmpVld	:= ""
    Local lApliBase	:= .F.
    Local cCodDep   := ""
    
    //Não valida as linhas de FKG se a validação estiver sendo chamada pelo LoadXMLData.
    If !FwIsInCallStack("LoadXMLData")
        cAcao		:= oModel:GetValue("FKGDETAIL", "FKG_DEDACR")// 1 == Subtração se 2 == Soma
        cTpAcao		:= oModel:GetValue("FKGDETAIL", "FKG_TPATRB")
        cNumProc	:= oModel:GetValue("FKGDETAIL", "FKG_NUMPRO")
        lApliBase	:= oModel:GetValue("FKGDETAIL", "FKG_APLICA") == '1'// 1 == Base se 2 == Valor Imp
        
        cAliasTab := If(__lBrowse, __cAlias986+"->", "M->")

        If __lFKG_CODDEP
            cCodDep	    := oModel:GetValue("FKGDETAIL", "FKG_CODDEP")
        Endif
    
        If Len(__aDadosTit) > 0 //Recebe dados do título quando for ExecAuto
            cNatu	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Right(__cAlias986, 2)+"_NATUREZ"})][2]
            cForCli	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Iif(__cAlias986=="SE2","E2_FORNECE", "E1_CLIENTE")})][2]
            cLoja	:= __aDadosTit[AScan(__aDadosTit,{|x|AllTrim(x[1])==Right(__cAlias986, 2)+"_LOJA"})][2]
        Else
            cNatu	:= &( cAliasTab + Right(__cAlias986, 2) + "_NATUREZ" )
            cForCli	:= &( cAliasTab + Right(__cAlias986, 2) + Iif(__cAlias986 == "SE2","_FORNECE", "_CLIENTE" ) )
            cLoja	:= &( cAliasTab + Right(__cAlias986, 2) + "_LOJA" )
        Endif
        
        If __cAlias986 == "SE2"

            If cAcao == "1"
            
                cTpImp	:= AllTrim( oModel:GetValue("FKGDETAIL", "FKG_TPIMP" ) )
                
                If lApliBase
                    cCmpVld	:=	cAliasTab + Right(__cAlias986, 2) + "_BASE" + cTpImp
                Else
                    
                    If cTpImp == "IRF"
                        cTpImp	:=	"_IRRF"
                    ElseIf cTpImp == "COF"
                        cTpImp	:=	"_COFINS"
                    Else
                        cTpImp	:=	"_" + cTpImp
                    EndIf	
                    
                    cCmpVld	:=	cAliasTab + Right(__cAlias986, 2) + cTpImp
                EndIf
                
                If lApliBase .AND. oModel:GetValue("FKGDETAIL", "FKG_VALOR") > &( cCmpVld )
                    lRet := .F.
                    HELP(' ',1,"F986LINE3" ,,STR0043,2,0,,,,,, {STR0044})	//"O Conteúdo do campo 'Valor' é maior que o campo Base do imposto do Título. #O conteudo do campo 'Valor' precisa ser menor ou igual ao campo Base do imposto.
                ElseIf !lApliBase .AND. oModel:GetValue("FKGDETAIL", "FKG_VALOR") > &( cCmpVld )
                    lRet := .F.
                    HELP(' ',1,"F986LINE4" ,,STR0045,2,0,,,,,, {STR0046})	//"O Conteúdo do campo 'Valor' é maior que o campo Valor do imposto do Título. #O conteudo do campo 'Valor' precisa ser menor ou igual ao campo Valor do imposto do Titulo.
                EndIf
            EndIf
            
            If lRet
                lGerImp := Fa986GerI( cNatu, cForCli, cLoja )
        
                If !lGerImp .and. cAcao <> "3"
                    lRet := .F.
                    HELP(' ',1,"F986LINE1" ,,STR0020,2,0,,,,,, {STR0021})	//"Conteúdo do campo 'Ação' não permitido para títulos sem cálculo de impostos. #Selecione um complemento de imposto em que a ação esteja definida como 'Informativo'.
                ElseIf Alltrim(cTpAcao) =="004" .and. Empty(cNumProc)
                    lRet := .F.
                    HELP(' ',1,"F986LINE2" ,,STR0022,2,0,,,,,, {STR0038})   //"O preenchimento do número do processo judicial/administrativo é obrigatório para o Tipo de Ação selecionado (004). #"Preencha o campo 'Processo Jud' (FKG_NUMPRO) ou altere para outro Complemento de Imposto que possua um 'Tipo de Ação' diferente."             
                ElseIf Alltrim(cTpAcao) =="013" .and. Empty(cCodDep)
                    lRet := .F.
                    HELP(' ',1,"F986LINE3" ,,STR0047,2,0,,,,,, {STR0048})   //"O preenchimento do dependente é obrigatório para o Tipo de Ação selecionado (013 - Pensão Alimenticia)." #"Preencha o campo 'Dependente' (FKG_CODDEP) ou altere para outro Complemento de Imposto que possua um 'Tipo de Ação' diferente."
                EndIf
            EndIf
        Endif	
    EndIf
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986IniVar
Inicializa as variaveis estaticas

@author Fabio Casagrande Lima
@since 24/04/2019
/*/
//-------------------------------------------------------------------
Static Function F986IniVar(cAliasC,lPosBrw)

    Default lPosBrw := .F.

    __nOPER       := 0
    __cAlias986   := cAliasC
    __lBrowse     := lPosBrw
    __TableF71    := AliasIndic('F71')
    __lFina890    := FindFunction('FINA890')
    __lF040Espec  := ExistFunc("F040Espec")
    __lFKFEspec   := FKF->(ColumnPos("FKF_ESPEC")) > 0 
    __lFKF_ORIINS := FKF->(ColumnPos("FKF_ORIINS")) > 0
    __lFKF_CEDENT := FKF->(ColumnPos("FKF_CEDENT")) > 0
    __lFKF_PAGPIX := FKF->(ColumnPos("FKF_PAGPIX")) > 0
    __lFKF_RECPIX := FKF->(ColumnPos("FKF_RECPIX")) > 0
    __lFKG_CALCUL := FKG->(ColumnPos("FKG_CALCUL")) > 0
    __lFKG_CODDEP := FKG->(ColumnPos("FKG_CODDEP")) > 0
    __lSF2_CNO    := SF2->(ColumnPos("F2_CNO")) > 0 .and. FKF->(ColumnPos("FKF_CNO")) > 0
    __lA2_CPRB    := SA2->(ColumnPos("A2_CPRB")) > 0
    __lTableFOF   := AliasInDic("F0F")

Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} F986ExcFKG
Função para limpar os complementos de impostos do título, ao alterar a natureza do mesmo

@author pedro.alencar
@since 27/08/2019
@version 12.1.27
@type Function

@param cAliasTit, char, Alias do título (SE1 ou SE2)
@return lRet, boolean, Indica se as linhas de complemento de imposto foram excluídas
/*/
//---------------------------------------------------------------------------------------------
Function F986ExcFKG( cAliasTit As Char ) As Logical
    Local lRet As Logical
    Local lcXml986 As Logical
    Local lTemFKG As Logical
    Local oModel As Object
    Local oModelFKG As Object
    Local cChaveTit As Char
    Local cIdDoc As Char
    Local nI As Numeric
    Local aArea As Array
    Default cAliasTit := ""
    
    lRet := .T.
    lTemFKG := .F.
    oModel := Nil
    oModelFKG := Nil
    cChaveTit := ""
    cIdDoc := ""
    nI := 0
    aArea := GetArea()
    lcXml986 := !Empty(__cXml986)
    
    If !lcXml986
        If cAliasTit == "SE2"
            cChaveTit := Iif(Empty(M->E2_FILIAL),xFilial('SE2'),M->E2_FILIAL) + "|" + M->E2_PREFIXO + "|" + M->E2_NUM + "|" +;
                                                                M->E2_PARCELA + "|" + M->E2_TIPO    + "|" + M->E2_FORNECE + "|" + M->E2_LOJA
        ElseIf cAliasTit == "SE1"
            cChaveTit := M->E1_FILIAL + "|" +  M->E1_PREFIXO + "|" + M->E1_NUM + "|" + M->E1_PARCELA + "|" + M->E1_TIPO + "|" + M->E1_CLIENTE + "|" + M->E1_LOJA
        EndIf

        cIdDoc := FINGRVFK7(cAliasTit, cChaveTit)
    
        FKF->( dbSetOrder(1) ) //FKF_FILIAL+FKF_IDDOC
        lRet := FKF->( msSeek( FWxFilial("FKF") + cIdDoc ) )
    EndIf
    
    If lRet
        oModel := FwLoadModel("FINA986")
        oModelFKG := oModel:GetModel("FKGDETAIL")
        
        If lcXml986
            oModel:LoadXMLData(__cXml986, .T.)
        Else
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
        EndIf
        
        If oModelFKG:Length() > 0
            For nI := 1 To oModelFKG:Length()
                If ! oModelFKG:IsDeleted(nI) .And. ! oModelFKG:IsEmpty(nI)
                    lTemFKG := .T.
                    oModelFKG:GoLine(nI)
                    
                    If ! oModelFKG:DeleteLine()
                        lRet := .F.
                        Exit
                    EndIf
                EndIf
            Next nI
            
            If lTemFKG
                If lRet
                    __cXml986 := oModel:GetXMLData(,,,, .T., .T.)
                    
                    Help( ,, "F986ExcFKG",, STR0033, 1, 0,,,,,, {} ) //"Devido a alteração de natureza, os complementos de impostos (FKG) serão excluídos para esse título. Caso necessário, inclua-os novamente clicando em 'Outras Ações > Complemento do título'."
                Else
                    Help( ,, "F986NoExcFKG",, STR0034, 1, 0,,,,,, {} ) //"A natureza foi alterada, porém não foi possível excluir os complementos de impostos (FKG). Acesse 'Outras Ações > Complemento do título' e revise os complementos informados."
                EndIf
            EndIf
        EndIf
        
        oModel:Deactivate()
        oModel:Destroy()
        FWFreeObj(oModelFKG)
        FWFreeObj(oModel)
    EndIf
    
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} readBarcode
Executa o aplicativo caso ele nao exista avisa o usuario

@author pedro castro
@since 19/10/2020
@version 12.1.27
@type Function
 
/*/
Static Function readBarcode()
    Local cDir As Character

    cDir := iif(GetOS()=="UNIX", Subs(getClientDir(),3), getClientDir()) 

    If GetOS() =="WINDOWS"
        If WaitRun(cDir + "barcode_scan.exe", 1 ) != 0
            MsgInfo(STR0050)// Verifique se o executavel barcode_scan existe na pasta do smartclient
            Return
        Endif
        MsgInfo(STR0051)//De um Ctrl+V no campo QR CODE
    Else
        If WaitRun(cDir + "barcode_scan", 1 ) != 0
            MsgInfo(STR0050)// Verifique se o executavel barcode_scan existe na pasta do smartclient
            Return
        Endif   
        MsgInfo(STR0051)//De um Ctrl+V no campo QR CODE
    Endif

Return

/*/{Protheus.doc} GetOS
Avalia e retorna o sistema operacional

@author pedro castro
@since 19/10/2020
@version 12.1.27
@type Function
 
/*/
Static Function GetOS() As Character
    Local cStringOS As Character
    Local cRet      As Character

    cStringOS := Upper(GetRmtInfo()[2])
    cRet      := ""

    If GetRemoteType() == 0 .or. GetRemoteType() == 1
        cRet := "WINDOWS"
    ElseIf GetRemoteType() == 2 
        cRet := "UNIX" // Linux ou MacOS		
    ElseIf GetRemoteType() == 5 
        cRet := "HTML" // Smartclient HTML		
    ElseIf ("ANDROID" $ stringOS)
        cRet := "ANDROID" 
    ElseIf ("IPHONEOS" $ stringOS)
        cRet := "IPHONEOS"
    EndIf
return cRet

/*/{Protheus.doc} F986PixIni
Caso o cliente utilize pix altera o campo FKF_RECPIX para sim
@author pedro castro
@since  20/10/2020
@version P12
/*/
Function F986PixIni() As Character    
    Local lDesdobra As Logical
    Local cRet 		As Char
    Local cChavAI0 	As Char   
    Local cParcela  As Char
    Local cTipo     As Char
    Local aAreaAI0 	As Array	
    
    //Inicializa variáveis
    lDesdobra := .F.
    cTipo     := IIf(__lBrowse, SE1->E1_TIPO, M->E1_TIPO)    	
    cDocTEF   := IIf(__lBrowse, SE1->E1_DOCTEF, M->E1_DOCTEF)
    cRet      := "2"
    cChavAI0  := ""
    cParcela  := ""
    aAreaAI0  := {}
    
    If !(F986PIXLj(cTipo, cDocTEF)) .And. GeraPix(cTipo) .And. AI0->(FieldPos("AI0_RECPIX")) > 0
        aAreaAI0 := AI0->(GetArea())
        AI0->(DbSetOrder(1))
        
        If __lBrowse
            cChavAI0 :=  SE1->E1_CLIENTE + SE1->E1_LOJA
        Else
            cChavAI0 := M->E1_CLIENTE + M->E1_LOJA
        Endif
        
        lDesdobra:= IIF(__lBrowse, SE1->E1_DESDOBR == "1", M->E1_DESDOBR == "1")
        cParcela := IIF((__lBrowse .Or. lDesdobra), SE1->E1_PARCELA, M->E1_PARCELA)
        
        If __lGeraPix .And. !(lDesdobra .And. Empty(Alltrim(cParcela)))
            If AI0->(DbSeek(xFilial("AI0")+cChavAI0)) .And. Alltrim(AI0->AI0_RECPIX) $ "1|2"
                cRet := '1'
            EndIf
        Endif
        
        RestArea(aAreaAI0)
        FwFreeArray(aAreaAI0)
    EndIf
    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986RecPix
Verifica se o título pode ser PIX

@author pedro castro
@since  20/10/2020
@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function F986PixVal() As Logical
    Local cDocTEF   As Char
    Local cTipo     As Char
    Local lRet   As Logical
    
    cTipo  := IIf(__lBrowse, SE1->E1_TIPO,M->E1_TIPO)
    cDocTEF := IIf(__lBrowse, SE1->E1_DOCTEF,   M->E1_DOCTEF)
    lRet    := !(F986PIxLj(cTipo, cDocTEF))
    
    If lRet .And. GeraPix(cTipo)
        lRet := !(ALTERA .And. SE1->E1_SALDO <= 0)
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F986RecPix
criar ou altera um registo na tabela F71 de acordo com o campo FKF_RECPIX

@author pedro castro
@since  21/10/2020
@version P12
/*/
//-------------------------------------------------------------------

Function F986PJob()
    local aDadoTit   As Array
    Local cQuery     As Character
    Local cSeq       As Character
    Local cTempAlias As Character
    Local cIdTran    As Character
    Local lDesdobra  As Logical
    Local cParcela   As Character

    cQuery      := ''
    cQuery1     := ''
    cSeq        := ''
    aDadoTit    := {}
    lDesdobra   := .f.
    cParcela    := ''
    cIdTran     := ''

    cTempAlias  := GetNextAlias()

    If M->FKF_RECPIX == '2' //Nao
        if __oPJob = NIL
            cQuery := " SELECT F71_FILIAL, F71_PREFIX, F71_NUM, F71_PARCEL, F71_TIPO, F71_CODCLI, F71_LOJCLI, F71_SOLCAN, "
            cQuery += " F71_VALOR, F71_EMISSA, F71_VENCTO, F71_CHVPIX, F71_STATUS, "
            cQuery += " F71_SOLCAN, F71_SEQ, F71_IDDOC, F71_IDTRAN "
            cQuery += " FROM "+ RetSQLName("F71")+" "
            cQuery += " WHERE F71_FILIAL = ? "
            cQuery += " AND F71_IDDOC = ? "
            cQuery += " AND F71_STATUS IN ('1','2','3','4')"
            cQuery += " AND F71_SOLCAN = '2'"
            cQuery += " AND D_E_L_E_T_ = ' '"

            __oPJob := FWPreparedStatement():New(cQuery)          
        endif
        __oPJob:SetString(1,xFilial('F71'))
        __oPJob:SetString(2,FKF->FKF_IDDOC)
        
        cQuery := __oPJob:GetFixQuery()
        MPSysOpenQuery(cQuery,cTempAlias)

        (cTempAlias)->(dbGoTop())

        Do While (cTempAlias)->(!EOF())
            aDadoTit := {}
            aAdd(aDadoTit, /*"F71_PREFIX"*/  (cTempAlias)->F71_PREFIX)
            aAdd(aDadoTit, /*"F71_NUM"	 */	 (cTempAlias)->F71_NUM)
            aAdd(aDadoTit, /*"F71_TIPO"  */  (cTempAlias)->F71_TIPO)
            aAdd(aDadoTit, /*"F71_PARCEL"*/  (cTempAlias)->F71_PARCEL)
            aAdd(aDadoTit, /*"F71_CODCLI"*/  (cTempAlias)->F71_CODCLI)
            aAdd(aDadoTit, /*"F71_LOJCLI"*/  (cTempAlias)->F71_LOJCLI)
            aAdd(aDadoTit, /*"F71_IDDOC" */  FKF->FKF_IDDOC)
            aAdd(aDadoTit, /*"F71_SEQ"*/     (cTempAlias)->F71_SEQ)
            aAdd(aDadoTit, /*"F71_VALOR"*/   (cTempAlias)->F71_VALOR)
            aAdd(aDadoTit, /*"F71_EMISSA"*/  STOD((cTempAlias)->F71_EMISSA))
            aAdd(aDadoTit, /*"F71_VENCTO"*/  STOD((cTempAlias)->F71_VENCTO))
            aAdd(aDadoTit, /*"F71_SOLCAN"*/  "1")
            aAdd(aDadoTit, /*"F71_STATUS"*/  IIF(Empty((cTempAlias)->F71_CHVPIX),"7",(cTempAlias)->F71_STATUS))
            aAdd(aDadoTit, /*"F71_IDTRAN"*/  (cTempAlias)->F71_IDTRAN)
            
            F986PixE(aDadoTit,"2")
            (cTempAlias)->(DbSkip()) 
        Enddo
        (cTempAlias)->(DbCloseArea())
    ElseIf M->FKF_RECPIX == "1" //Sim
        if __oPJob2 = NIL 
            cQuery := "SELECT COUNT(*) AS NTOTREG "
            cQuery += "FROM "+ RetSQLName("F71") + " "
            cQuery += "WHERE F71_FILIAL = ? "
            cQuery += "AND F71_IDDOC = ? "
            cQuery += "AND F71_SOLCAN = '2' AND F71_STATUS NOT IN ('5', '7', '8') "
            cQuery += "AND D_E_L_E_T_ = ' '"            
            __oPJob2 := FWPreparedStatement():New(cQuery)         
        endif        
        __oPJob2:SetString(1,xFilial('F71'))
        __oPJob2:SetString(2,FKF->FKF_IDDOC)
        
        cQuery := __oPJob2:GetFixQuery()  
        MPSysOpenQuery(cQuery,cTempAlias)
        (cTempAlias)->(dbGoTop())

        lDesdobra:= IIF(__lBrowse,SE1->E1_DESDOBR == "1",M->E1_DESDOBR == "1")
        cParcela := IIF(__lBrowse .or. lDesdobra,SE1->E1_PARCELA,M->E1_PARCELA)
        
        If !(lDesdobra .And. Empty(Alltrim(cParcela))) .And. (cTempAlias)->(NTOTREG) == 0
            cSeq := F986RetSeq()
            aDadoTit := {}
            aAdd(aDadoTit, /*"F71_PREFIX"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_PREFIXO,M->E1_PREFIXO))
            aAdd(aDadoTit, /*"F71_NUM"	 */	 IIF(__lBrowse .or. lDesdobra,SE1->E1_NUM,M->E1_NUM))
            aAdd(aDadoTit, /*"F71_TIPO"  */  IIF(__lBrowse .or. lDesdobra,SE1->E1_TIPO,M->E1_TIPO))
            aAdd(aDadoTit, /*"F71_PARCEL"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_PARCELA,M->E1_PARCELA))
            aAdd(aDadoTit, /*"F71_CODCLI"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_CLIENTE,M->E1_CLIENTE))
            aAdd(aDadoTit, /*"F71_LOJCLI"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_LOJA,M->E1_LOJA))
            aAdd(aDadoTit, /*"F71_IDDOC" */  FKF->FKF_IDDOC)
            aAdd(aDadoTit, /*"F71_SEQ"*/  	 Soma1(cSeq))
            aAdd(aDadoTit, /*"F71_VALOR"*/   IIF(__lBrowse .or. lDesdobra,SE1->E1_VALOR,M->E1_VALOR))
            aAdd(aDadoTit, /*"F71_EMISSA"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_EMISSAO,M->E1_EMISSAO))
            aAdd(aDadoTit, /*"F71_VENCTO"*/  IIF(__lBrowse .or. lDesdobra,SE1->E1_VENCREA,M->E1_VENCREA))
            aAdd(aDadoTit, /*"F71_SOLCAN"*/  "2")
            aAdd(aDadoTit, /*"F71_STATUS"*/  "1")
            aAdd(aDadoTit, /*"F71_IDTRAN"*/  F986IDTran())
            F986PixE(aDadoTit, "1")
        EndIf
        
        (cTempAlias)->(DbCloseArea())
    EndIf
Return

/*/{Protheus.doc} F986PixE
execauto F71

@author pedro castro
@since  23/10/2020
@version P12
/*/

Function F986PixE(aDadosTit As Array, cOps As Character)

    Local oModel 		As Object
    Local oF71Model 	As Object
    Local aAreaF71		As Logical

    Default aDadosTit := {}
    Default cOps := '1'

    oModel 			:= Nil
    oF71Model 		:= Nil
    aAreaF71 	:= F71->(GetArea())

    If cOps == '2'
        F71->(DbSetOrder(1))
        If F71->(DbSeek(xFilial("F71") + aDadosTit[7] + aDadosTit[8]))
            oModel := FwLoadModel ("FINA890")
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
        Endif
    elseIf cOps == '1'
        oModel := FwLoadModel("FINA890") 
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()
    EndIf

    oF71Model := oModel:GetModel("FORMF71")
    oF71Model:SetValue("F71_FILIAL"    , FwXFilial("F71") ) 
    oF71Model:SetValue("F71_PREFIX"    , aDadosTit[1] ) 
    oF71Model:SetValue("F71_NUM"       , aDadosTit[2] ) 
    oF71Model:SetValue("F71_TIPO"      , aDadosTit[3] ) 
    oF71Model:SetValue("F71_PARCEL"    , aDadosTit[4] ) 
    oF71Model:SetValue("F71_CODCLI"    , aDadosTit[5] ) 
    oF71Model:SetValue("F71_LOJCLI"    , aDadosTit[6] ) 
    oF71Model:SetValue("F71_IDDOC"     , aDadosTit[7] ) 
    oF71Model:SetValue("F71_SEQ"       , aDadosTit[8] ) 
    oF71Model:SetValue("F71_VALOR"     , aDadosTit[9] ) 
    oF71Model:SetValue("F71_EMISSA"    , aDadosTit[10] ) 
    oF71Model:SetValue("F71_VENCTO"    , aDadosTit[11] )
    oF71Model:SetValue("F71_SOLCAN"    , aDadosTit[12] )
    oF71Model:SetValue("F71_STATUS"    , aDadosTit[13] )
    oF71Model:SetValue("F71_IDTRAN"    , aDadosTit[14] )

    If oModel:VldData()
        oModel:CommitData()
    Else
        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    RestArea(aAreaF71)

    oModel := Nil
 
Return Nil

/*/{Protheus.doc} F986FPag
Altera o campo E2_FORMPAG para 47 caso o campo FKF_PAGPIX foi preenchido com um QR code

@author pedro castro
@since  26/10/2020
@version P12
/*/

Static Function F986FPag()

    Local cCampo    as Character
    Local cSX3Campo as Character
    Local cValor    as Character

    Local lRet      as Logical

    Local oModel    as Object
    Local oModFKF   as Object

    cCampo    := "X3_RELACAO"
    cSX3Campo := "FKF_PAGPIX"

    lRet      := .F.

    cValor := InitPad(GetSX3Cache(cSX3Campo, cCampo))

    oModel := FwModelActive()
    oModFKF := oModel:GetModel("FKFMASTER")

    cFKFPAGPIX := oModFKF:GetValue('FKF_PAGPIX')

    IF !Empty(cFKFPAGPIX) .and. Alltrim(cFKFPAGPIX) <> Alltrim(cValor)
        If SE2->(RLock())
            SE2->E2_FORMPAG := '47'
        EndIf 
    Endif

Return
/*
{Protheus.doc} F986RetSeq
Retorna maior sequencia das dos registro da F71

@author pedro castro
@return cSeq, Character
@since  29/10/2020
@version P12
*/
Static function F986RetSeq() As Character
    Local cQuery As Character
    Local cSeq   As Character
    Local cTotal As Character
    //aqui kco
    cSeq := '00'
    cTotal := ''

    cQuery := " SELECT MAX(F71_SEQ) As TOTAL"
    cQuery += " FROM "+ RetSQLName("F71")+" "
    cQuery += " WHERE F71_FILIAL = '" + xFilial('F71') + "'"
    cQuery += " AND F71_IDDOC 	 = '" + FKF->FKF_IDDOC + "'"
    cQuery += " AND D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)
    cTotal := MpSysExecScalar(cQuery, "TOTAL")

    If !Empty(cTotal)
        cSeq   := IIf(cTotal <> cSeq, cTotal, cSeq)
    EndIf
Return cSeq

/*
{Protheus.doc} F986QRCode
Função para proteger a existencia da FinQRCode

@author pedro castro
@return lRet
@since  29/10/2020
@version P12
*/
Function F986QRCode() As Logical

    Local lRet As Logical
    lRet := .T. 

    If __lFinQRCode == Nil
        __lFinQRCode := FindFunction('FinQRCode')
    EndIf 

    If __lFinQRCode
        FinQRCode(M->FKF_PAGPIX,.T.,.F.)
    EndIf 

    If !Empty(Alltrim(M->FKF_PAGPIX)) .AND. SubStr(M->FKF_PAGPIX,1,6) != '000201'
        Help(" ", 1, "QRCODEPIX", Nil, STR0053, 2, 0,,,,,,{STR0054}) //"Não identificamos no conteúdo do campo, um formato de código de QR Code válido." // "Verifique o QR Code utilizado!"
        lRet:= .F.
    Endif

Return lRet

/*
{Protheus.doc} F986IDTran
Função para gerar o IDTran para a tabela F71

@author Edson Melo
@return cIdTran
@since  18/11/2020
@version P12
*/
Function F986IDTran() As Character
    Local cIdTran  As Character
    Local nIndice  As Numeric
    Local aArea    As Array
    Local aAreaF71 As Array    
    
    //Inicializa variáveis        
    cIdTran  := ""    
    nIndice  := 3
    aArea    := GetArea()
    aAreaF71 := {}
    
    DbSelectArea("F71")
    aAreaF71 := F71->(GetArea())            
    cIdTran  := GetSXENum("F71", "F71_IDTRAN", "F71_IDTRAN" + CEMPANT, nIndice)
    
    F71->(DbSetOrder(nIndice))
    While F71->(MsSeek(cIdTran))
        cIdTran  := GetSXENum("F71", "F71_IDTRAN", "F71_IDTRAN" + CEMPANT, nIndice) 
    EndDo
    
    ConfirmSX8()
    RestArea(aAreaF71)
    RestArea(aArea)
    FwFreeArray(aAreaF71)
    FwFreeArray(aArea)
Return cIdTran

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa986When
Função para tratar os campos das abas do complemento de impostos

@author Douglas de Oliveira
@since 11/06/2021
@version P12
/*/
//-------------------------------------------------------------------
Static function Fa986When() as Logical
    
    Local lRet      as Logical     
    Local cTipos    as Character	 
    Local cTpTab    as Character   
    Local cAliasTab as Character

    lRet      := .T.
    cTipos	  := MVTAXA + "/" + MVINSS + "/" + MVISS + "/" + MVIRF + "/" + "SES/CID/INA/PIS/CSL/COF"
    cTpTab    := ""
    cAliasTab := ""
         
    __cAlias986 := IF(ValType(__cAlias986)=="U", "SE2", __cAlias986)
    cAliasTab  := If(__lBrowse, __cAlias986+"->" , "M->")
    cTpTab     := cAliasTab + Right(__cAlias986, 2) + "_TIPO"

    If &cTpTab $ cTipos
         lRet := .F.
    EndIf  

Return lRet

/*/{Protheus.doc} GeraPix
    Valida se um determinado tipo de título
    pode gerar registro no monitor pix

    @author Sivaldo Oliveira
    @since 13/04/2022
    @return lRet, Logical, retorna verdadeiro (.T.) ou falso (.F.),
    (.T.) = Pode gerar registro no monitor pix
    (.F.) = Não pode gerar no monitor pix
/*/    
Static Function GeraPix(cTipoTit As Char) As Logical
    Local lRet   As Logical
    Local cLista As Char
    
    Default cTipoTit := ""
    
    If (lRet   := !Empty(cTipoTit))
        cLista := MVABATIM+"|"+MV_CRNEG+"|"+MVTXA+"|"+MV_CPNEG+"|"+MVPROVIS+"|"+MVINSS
        cLista += "|"+MVISS+"|"+MVIRF+"|"+MVRECANT+"|TX |SES|CID|INA|PIS|CSL|COF"
        
        lRet := !cTipoTit $ cLista 
    EndIf
Return lRet

/*/{Protheus.doc} F986PIXLj
Verifica se o título PIX originado no Loja.

@author Rafael Riego
@since  19/04/2022
@param  cTipo, character, tipo do título
@param  cDocTEF, character, preenchido caso seja originado no PDV Loja
@return logical, verdadeiro caso seja PIX originado no PDV loja
/*/   
Static Function F986PIXLj(cTipo As Character, cDocTEF As Character) As Logical

    Local lLoja As Logical

    Default cTipo   := ""
    Default cDocTEF := ""

    lLoja := cTipo $ "PX |PD " .And. !(Empty(cDocTEF))

Return lLoja
