#INCLUDE "JURA246.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _aRecDesCtb := {} // Variavel para controlar lançamentos estornados por alterações

#DEFINE ICO_TEM_ANEXO "F5_VERD_OCEAN.BMP"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA246
Itens de desdobramento

@param  nOperacao , Operação para abrir o modelo.
@param  lForceAtu , Força abertura da rotina de desdobramento.
@param  lConfirma , Indica que a chamada foi feita na confirmação do título
@param  lTransit  , Se executa a rotina de desdobramento completa
@param  lBrowse   , Se foi chamada a execução pelo Browse
@param  lAfterSave, Se foi chamada após salvar um título (inclusão ou alteração)

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA246(nOperacao, lForceAtu, lConfirma, lTransit, lBrowse, lAfterSave)
	Local cNaturSE2    := IIf(lBrowse, SE2->E2_NATUREZ, M->E2_NATUREZ)
	Local lRet         := .T.
	Local lDesdOld     := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lTitPriPrc   := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local lExecAF050   := Type("lF050Auto") == "U" .Or. ( Type("lF050Auto") == "L" .And. !lF050Auto ) // Quando for ExecAuto não devem ser validados os desdobramentos

	Default nOperacao  := MODEL_OPERATION_UPDATE
	Default lForceAtu  := .F.
	Default lConfirma  := .F.
	Default lTransit   := JurGetDados("SED", 1, xFilial("SED") + cNaturSE2, "ED_CCJURI") == "7" // Transitória de Pagamento
	Default lBrowse    := .F.
	Default lAfterSave := .F.

	If !JurIsRest() .And. !IsBlind() .And. lExecAF050

		lRet := JVldTipoCp(SE2->E2_TIPO, .T.)

		If lRet .And. !lAfterSave .And. lTitPriPrc
			lRet := JurMsgErro(STR0059,,; // "A situação do título não permite inserir desdobramentos."
			      I18n(STR0060, {AllTrim(FwX3Titulo('E2_DESDOBR'))}), .F.) // "Após parcelamento do título ('#1' - E2_DESDOBR), só é possível desdobrar as parcelas geradas."
		EndIf

		If lRet
			If lBrowse .Or. lForceAtu .Or. M->E2_NATUREZ == SE2->E2_NATUREZ
				If lTransit
					FWExecView( STR0003, 'JURA246', nOperacao, , { || .T. }, , , ) // "Itens de desdobramento"
				Else
					lRet := J246DIALOG(lConfirma, nOperacao)
					If lRet .And. ExistBlock("J246Comp") // Pondo de entrada após confirmar a tela de complemento do título
						ExecBlock("J246Comp", .F., .F.)
					EndIf
				EndIf
			Else
				ApMsgAlert(STR0028) // "Houve alteração da Natureza. Confirme a alteração para preencher os detalhes/desdobramentos do título."
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Itens de desdobramento

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSE2 := FWFormStruct( 1, "SE2" )
Local oStructOHF := FWFormStruct( 1, "OHF" )
Local oEvent     := JA246Event():New()
Local cChave     := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
Local cIdDoc     := FINGRVFK7('SE2', cChave)
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

oStructSE2 := J246AddCpM(oStructSE2)

// Adiciona o campo de anexo no Model
oStructOHF := J247CpoAnx(oStructOHF, "OHF", "M", {||JA246Anexo()})

oModel:= MPFormModel():New( "JURA246", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SE2MASTER", NIL         /*cOwner*/, oStructSE2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid("OHFDETAIL", "SE2MASTER"/*cOwner*/, oStructOHF, {|oGrid, nLine, cAction, cField, xNewValue, xOldValue| J246PreOHF(oModel, nLine, cAction, cField, xNewValue, xOldValue)} /*Pre-Validacao*/, {|| J246PosOHF(oModel)} /*Pos-Validacao*/, /*bPre*/, /*bPost*/ )

oModel:SetRelation("OHFDETAIL", {{"OHF_FILIAL", "E2_FILIAL" }, {"OHF_IDDOC", '"'+cIdDoc+'"'}}, OHF->(IndexKey(1)))

oModel:GetModel( "SE2MASTER" ):SetDescription( STR0004 ) // "Título"
oModel:GetModel( "OHFDETAIL" ):SetDescription( STR0003 ) // "Itens de desdobramento"

J235MAnexo(@oModel, "OHFDETAIL", "OHF", "OHF->(OHF_IDDOC+OHF_CITEM)") // Grid de Anexos

oStructSE2:SetProperty("E2_PREFIXO", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_NUM"    , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_PARCELA", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_TIPO"   , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__NATURE", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VENCTO", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VENCRE", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__CMOEDA", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VALOR" , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VLRLIQ", MODEL_FIELD_WHEN, {||.F.})

/*Bloqueio de campos desdobramento*/

oStructOHF:SetProperty("OHF_CESCR",  MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHF_CNATUR"), "OHF_CNATUR", "1") } )
oStructOHF:SetProperty("OHF_CCUSTO", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHF_CNATUR"), "OHF_CNATUR", "2") } )
oStructOHF:SetProperty("OHF_SIGLA2", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHF_CNATUR"), "OHF_CNATUR", "3") } )
oStructOHF:SetProperty("OHF_CRATEI", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHF_CNATUR"), "OHF_CNATUR", "4") } )
/***********************************************************************/

If !lUtProj .And. !lContOrc .And. OHF->(ColumnPos("OHF_CPROJE")) > 0
	oStructOHF:SetProperty("OHF_CPROJE", MODEL_FIELD_WHEN, {||.F.})
	oStructOHF:SetProperty("OHF_CITPRJ", MODEL_FIELD_WHEN, {||.F.})
EndIf

oModel:GetModel("OHFDETAIL"):SetUniqueLine( {"OHF_CITEM"} )

oModel:SetOptional( "OHFDETAIL", .T. )
oModel:GetModel( "OHFDETAIL" ):SetDelAllLine( .T. )

oModel:InstallEvent("JA246Event", /*cOwner*/, oEvent)

oModel:SetActivate( {|oModel| JIniValDes(oModel, "OHF"), J246ActWhn(@oStructOHF)} ) // Preenche os valores dos campos de total e saldo do desdobramento ao abrir a tela, e ajusta when
oModel:SetVldActivate( { |oModel| J246VldACT( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J246ActWhn
Ajuste o WHEN do modelo JURA246 que não são alterados após a ativação do modelo

@param  oStructOHF, estrutura do modelo para ser alterado o when
@return Nil

@author  Bruno Ritter
@since   07/11/2019
/*/
//-------------------------------------------------------------------
Function J246ActWhn(oStructOHF)
	Local lDesdOld   := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lDesdFin   := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local lExisteBx  := SE2->E2_SALDO != SE2->E2_VALOR
	Local lFldNoUpd  := lExisteBx .And. !lDesdFin

	oStructOHF:SetProperty("OHF_CNATUR", MODEL_FIELD_NOUPD, lFldNoUpd )
	oStructOHF:SetProperty("OHF_SALDO" , MODEL_FIELD_NOUPD, lFldNoUpd )
	oStructOHF:SetProperty("OHF_VALOR" , MODEL_FIELD_NOUPD, lFldNoUpd )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Itens de desdobramento

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local cAddCpo    := "E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2__NATURE|E2__DNATUR|E2__VENCTO|E2__VENCRE|E2__CMOEDA|E2__DMOEDA|E2__VALOR|E2__VLRLIQ|E2__TOTDES|E2__SLDDES"
Local aOrdemCpo  := STRTOKARR(cAddCpo, "|")
Local oModel     := FWLoadModel( "JURA246" )
Local oStructSE2 := FWFormStruct( 2, "SE2", {|cCampo| J246SE2Cpo(cCampo, cAddCpo)})
Local oStructOHF := FWFormStruct( 2, "OHF" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

oStructSE2 := J246AddCpV(oStructSE2)
oStructSE2 := J246SE2Ord(oStructSE2, aOrdemCpo)

// Adiciona o campo de anexo no View
oStructOHF := J247CpoAnx(oStructOHF, "OHF", "V")

oStructOHF:RemoveField("OHF_IDDOC")
oStructOHF:RemoveField("OHF_CPART")
oStructOHF:RemoveField("OHF_CPART2")
oStructOHF:RemoveField("OHF_DTINCL")

If (cLojaAuto == "1") // Loja Automática
	oStructOHF:RemoveField("OHF_CLOJA")
EndIf

If !lUtProj .And. !lContOrc .And. OHF->(ColumnPos("OHF_CPROJE")) > 0
	oStructOHF:RemoveField("OHF_CPROJE")
	oStructOHF:RemoveField("OHF_DPROJE")
	oStructOHF:RemoveField("OHF_CITPRJ")
	oStructOHF:RemoveField("OHF_DITPRJ")
EndIf

// Remove campo da data de contabilização off-line
If OHF->(ColumnPos("OHF_DTCONT")) > 0
	oStructOHF:RemoveField("OHF_DTCONT")
EndIf

// Remove campo da data de contabilização off-line para inclusão de desdobramento
If OHF->(ColumnPos("OHF_DTCONI")) > 0
	oStructOHF:RemoveField("OHF_DTCONI")
EndIf

If OHF->(FieldPos("OHF_CODLD")) > 0
	oStructOHF:RemoveField('OHF_CODLD')
EndIf

If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integração Controle Orçamentário SIGAPFS x SIGAFIN
	oStructOHF:SetProperty("OHF_VALOR" , MVC_VIEW_CANCHANGE, .F.)
	oStructOHF:SetProperty("OHF_CESCR" , MVC_VIEW_CANCHANGE, .F.)
	oStructOHF:SetProperty("OHF_CCUSTO", MVC_VIEW_CANCHANGE, .F.)
	oStructOHF:SetProperty("OHF_SIGLA2", MVC_VIEW_CANCHANGE, .F.)
	oStructOHF:SetProperty("OHF_CRATEI", MVC_VIEW_CANCHANGE, .F.)
	If oStructOHF:HasField("OHF_CPROJE")
		oStructOHF:SetProperty("OHF_CPROJE", MVC_VIEW_CANCHANGE, .F.)
		oStructOHF:SetProperty("OHF_CITPRJ", MVC_VIEW_CANCHANGE, .F.)
	EndIf
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("JURA246_SE2", oStructSE2, "SE2MASTER")
oView:AddGrid("JURA246_OHF" , oStructOHF, "OHFDETAIL")

oView:SetViewProperty( 'JURA246_OHF', "ENABLEDGRIDDETAIL", { 50 } )

oView:CreateHorizontalBox("FORMFIELD", 30)
oView:CreateHorizontalBox("FORMGRID",  70)

oView:SetOwnerView("JURA246_SE2", "FORMFIELD")
oView:SetOwnerView("JURA246_OHF", "FORMGRID")

oView:EnableTitleView("JURA246_OHF")

oView:EnableControlBar( .T. )
oView:AddIncrementField( 'OHFDETAIL', 'OHF_CITEM' )

If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integração Controle Orçamentário SIGAPFS x SIGAFIN
	oView:SetNoInsertLine("OHFDETAIL")
	oView:SetNoDeleteLine("OHFDETAIL")
EndIf

oView:SetViewProperty("JURA246_OHF", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| Iif(Alltrim(cFieldName) == "OHF__ANEXO", JA246Anexo(), .T.) }})

If !IsBlind()
	oView:AddUserButton( STR0046, "CLIPS" , { | oView | JA246Anexo() } ) // "Anexos"
	oView:AddUserButton( STR0047, "BUDGET", { | oView | JA247Legen() } ) // "Legenda"
	oView:AddUserButton( STR0064, "BUDGET", { | oView | JA246Tracker(oView) } ) // "Tracker Contábil"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J246SE2Cpo(cCampo)
Função para selecionar os campos do Model da tabela SE2

@param cCampo campo da estrutura.

@return .T. para campos que ope

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246SE2Cpo(cCampo, cAddCpo)
Local lRet     := .F.
Local cNomeCpo := AllTrim(cCampo)

If cNomeCpo $ cAddCpo
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246AddCpM(oStruct)
Inclui campos no model através da função AddField

@param oStruct Estrutura a ser adicionadas os campos

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246AddCpM(oStruct)
	Local aNat       := TamSx3('ED_DESCRIC')
	Local aCMoe      := TamSx3('CTO_MOEDA')
	Local aDMoe      := TamSx3('CTO_SIMB')
	Local aVal       := TamSx3('E2_VALOR')
	Local aCodNat    := TamSx3('E2_NATUREZ')
	Local aVencto    := TamSx3('E2_VENCTO')

	Local cTitNat    := GetSx3Cache( 'E2_NATUREZ', 'X3_TITULO' )
	Local cDesNat    := GetSx3Cache( 'E2_NATUREZ', 'X3_DESCRIC')
	Local cTitVencto := GetSx3Cache( 'E2_VENCTO' , 'X3_TITULO' )
	Local cDesVencto := GetSx3Cache( 'E2_VENCTO' , 'X3_DESCRIC')
	Local cTitVencRe := GetSx3Cache( 'E2_VENCREA', 'X3_TITULO' )
	Local cDesVencRe := GetSx3Cache( 'E2_VENCREA', 'X3_DESCRIC')
	Local cTitValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_TITULO' )
	Local cDesValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_DESCRIC')

	                //Titulo   , Descricao , Campo       , Tipo do campo , Tamanho    , Decimal    ,  bValid,  bWhen   , Lista , lObrigat,  bInicializador                          , é chave, é editável , é virtual
	oStruct:AddField(STR0005   , STR0006   , 'E2__VLRLIQ', aVal[3]       , aVal[1]    , aVal[2]    ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__VLRLIQ')} ,        ,            , .T.       ) // 'Vlr. Líquido' - 'Valor líquido'
	oStruct:AddField(STR0007   , STR0008   , 'E2__DNATUR', aNat[3]       , aNat[1]    , aNat[2]    ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__DNATUR')} ,        ,            , .T.       ) // 'Desc. Natureza' - 'Descrição Natureza'
	oStruct:AddField(STR0009   , STR0009   , 'E2__TOTDES', aVal[3]       , aVal[1]    , aVal[2]    ,        ,  {||.T.} ,       ,         , {|| J246InitP('E2__TOTDES')} ,        ,            , .T.       ) // 'Total Desdobramento'
	oStruct:AddField(STR0010   , STR0010   , 'E2__SLDDES', aVal[3]       , aVal[1]    , aVal[2]    ,        ,  {||.T.} ,       ,         , {|| J246InitP('E2__SLDDES')} ,        ,            , .T.       ) // 'Saldo Desdobramento'
	oStruct:AddField(STR0011   , STR0012   , 'E2__CMOEDA', aCMoe[3]      , aCMoe[1]   , aCMoe[2]   ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__CMOEDA')} ,        ,            , .T.       ) // 'Cód. Moeda' - 'Código da Moeda'
	oStruct:AddField(STR0013   , STR0014   , 'E2__DMOEDA', aDMoe[3]      , aDMoe[1]   , aDMoe[2]   ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__DMOEDA')} ,        ,            , .T.       ) // 'Símb. Moeda' - 'Símbolo da Moeda'
	oStruct:AddField(cTitNat   , cDesNat   , 'E2__NATURE', aCodNat[3]    , aCodNat[1] , aCodNat[2] ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__NATURE')} ,        ,            , .T.       ) // 'Natureza'
	oStruct:AddField(cTitVencto, cDesVencto, 'E2__VENCTO', aVencto[3]    , aVencto[1] , aVencto[2] ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__VENCTO')} ,        ,            , .T.       ) // 'Vencimento'
	oStruct:AddField(cTitVencRe, cDesVencRe, 'E2__VENCRE', aVencto[3]    , aVencto[1] , aVencto[2] ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__VENCRE')} ,        ,            , .T.       ) // 'Vencimento Real'
	oStruct:AddField(cTitValor , cDesValor , 'E2__VALOR' , aVal[3]       , aVal[1]    , aVal[2]    ,        ,  {||.F.} ,       ,         , {|| J246InitP('E2__VALOR' )} ,        ,            , .T.       ) // 'Valor Título'

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J246AddCpV(oStruct, nTipo)
Inclui campos no view através da função AddField

@Param oStruct Estrutura a ser adicionadas os campos

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246AddCpV(oStruct)
Local cPict := Alltrim(X3Picture('E2_VALOR'))
Local aLgpd := {}

Local cTitNat    := GetSx3Cache( 'E2_NATUREZ', 'X3_TITULO' )
Local cDesNat    := GetSx3Cache( 'E2_NATUREZ', 'X3_DESCRIC')
Local cTitVencto := GetSx3Cache( 'E2_VENCTO' , 'X3_TITULO' )
Local cDesVencto := GetSx3Cache( 'E2_VENCTO' , 'X3_DESCRIC')
Local cTitVencRe := GetSx3Cache( 'E2_VENCREA', 'X3_TITULO' )
Local cDesVencRe := GetSx3Cache( 'E2_VENCREA', 'X3_DESCRIC')
Local cTitValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_TITULO' )
Local cDesValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_DESCRIC')

                 //Campo     , Ordem, Titulo    , Descricao , Help , Tipo do campo, Picture, PictVar,   F3,  When, Folder, Group, Lista Combo, Tam Max Combo, Inic. Browse, Virtual
oStruct:AddField('E2__VLRLIQ', 'ZZ' , STR0005   , STR0006   , {}   , 'GET'        ,cPict   ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Vlr. Líquido' - 'Valor líquido'
oStruct:AddField('E2__DNATUR', 'ZZ' , STR0007   , STR0008   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Desc. Natureza' - 'Descrição Natureza'
oStruct:AddField('E2__TOTDES', 'ZZ' , STR0009   , STR0009   , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Total Desdobramento'
oStruct:AddField('E2__SLDDES', 'ZZ' , STR0010   , STR0010   , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Saldo Desdobramento'
oStruct:AddField('E2__CMOEDA', 'ZZ' , STR0011   , STR0012   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Cód. Moeda' - 'Código da Moeda'
oStruct:AddField('E2__DMOEDA', 'ZZ' , STR0013   , STR0014   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Símb. Moeda' - 'Símbolo da Moeda'
oStruct:AddField('E2__NATURE', 'ZZ' , cTitNat   , cDesNat   , {}   , 'GET'        ,'!@'    ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Natureza'
oStruct:AddField('E2__VENCTO', 'ZZ' , cTitVencto, cDesVencto, {}   , 'GET'        ,'!@'    ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Vencimento'
oStruct:AddField('E2__VENCRE', 'ZZ' , cTitVencRe, cDesVencRe, {}   , 'GET'        ,'!@'    ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Vencimento Real'
oStruct:AddField('E2__VALOR' , 'ZZ' , cTitValor , cDesValor , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Valor Título'

aAdd(aLgpd, {"E2__VLRLIQ", "E2_VALOR"  })
aAdd(aLgpd, {"E2__DNATUR", "OHF_DNATUR"})
aAdd(aLgpd, {"E2__TOTDES", "OHF_VALOR" })
aAdd(aLgpd, {"E2__SLDDES", "OHF_VALOR" })
aAdd(aLgpd, {"E2__CMOEDA", "E2_MOEDA"  })
aAdd(aLgpd, {"E2__DMOEDA", "CTO_SIMB"  })
aAdd(aLgpd, {"E2__NATURE", "E2_NATUREZ"})
aAdd(aLgpd, {"E2__VENCTO", "E2_VENCTO" })
aAdd(aLgpd, {"E2__VENCRE", "E2_VENCREA"})
aAdd(aLgpd, {"E2__VALOR" , "E2_VALOR"  })

If FindFunction("JPDOfusca")
	JPDOfusca(@oStruct, aLgpd)
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J246SE2Ord(oStruct, aOrdemCpo)
Ajusta a ordem dos campos na view da SE2.

@Param oStruct     Estrutura da SE2
@Param aOrdemCpo  Array com os campos ordenados

@author Luciano Pereira dos Santos
@since 03/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246SE2Ord(oStruct, aOrdemCpo)
Local nI := 1

For nI := 1 to Len(aOrdemCpo)

	oStruct:SetProperty(aOrdemCpo[nI], MVC_VIEW_ORDEM, RetAsc(Str(nI), 2, .T.) )

Next nI

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J246InitP
Inicializador padrão dos campos virtuais da SE2

@param cCampo  Nome do campo que terá o inicializador atribuído

@author Luciano Pereira dos Santos
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246InitP(cCampo)
	Local xRet   := Nil

	Do Case
		Case cCampo == 'E2__DNATUR'
			xRet := POSICIONE("SED", 1, XFILIAL("SED") + SE2->E2_NATUREZ, 'ED_DESCRIC ')

		Case cCampo == 'E2__CMOEDA'
			xRet := PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1], '0')

		Case cCampo == 'E2__DMOEDA'
			xRet := POSICIONE('CTO', 1, xFilial('CTO') + PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1], '0'), 'CTO_SIMB')

		Case cCampo == 'E2__TOTDES'
			xRet := 0

		Case cCampo == 'E2__SLDDES'
			xRet := 0

		Case cCampo == 'E2__NATURE'
			xRet := SE2->E2_NATUREZ

		Case cCampo == 'E2__VALOR'
			xRet := JCPVlBruto(SE2->(Recno()))

		Case cCampo == 'E2__VENCRE'
			xRet := SE2->E2_VENCTO

		Case cCampo == 'E2__VENCTO'
			xRet := SE2->E2_VENCTO

		Case cCampo == 'E2__VLRLIQ'
			xRet := JCPVlLiqui(SE2->(Recno()))
	EndCase

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246OpDesp(oModel, nOperDesp)
Valida e prepara a despesa para inclusão, alteração ou exclusão.

@param oModel    => Modelo ativo
@param nOperDesp => Operacao para a Despesa (1=INSERT;2=UPDATE;3=DELETE)

@return oModelNVY Retorna o modelo preparado da NVY para

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246OpDesp(oModel)
	Local aModelDesp := {}
	Local oModelSE2  := oModel:GetModel("SE2MASTER")
	Local oModelOHF  := oModel:GetModel("OHFDETAIL")
	Local cCobraOld  := ""
	Local lOk        := .T.
	Local nLine      := 1
	Local nQtdOHF    := oModelOHF:GetQTDLine()
	Local nOperDesp  := 0
	Local nUltimoDp  := 0
	Local cChave     := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA

	For nLine := 1 To nQtdOHF
		nOperDesp := J246AcDesp(oModel, nLine) // Verifica se é necessário gerar um INSERT/UPDATE/DELETE de Despesa

		If nOperDesp != 0 //Não é necessário atualizar despesa.
			If nOperDesp == MODEL_OPERATION_UPDATE
				cCobraOld := JurGetDados('OHF', 1, xFilial("OHF") + oModelOHF:GetValue('OHF_IDDOC', nLine) + oModelOHF:GetValue('OHF_CITEM', nLine), 'OHF_COBRA')
			Else
				cCobraOld := ""
			EndIf

			aAdd (aModelDesp, JA049GerDp(nOperDesp,;
								oModelOHF:GetValue("OHF_CDESP"  , nLine),;
								oModelOHF:GetValue("OHF_CCLIEN" , nLine),;
								oModelOHF:GetValue("OHF_CLOJA"  , nLine),;
								oModelOHF:GetValue("OHF_CCASO"  , nLine),;
								oModelOHF:GetValue("OHF_DTDESP" , nLine),;
								oModelOHF:GetValue("OHF_SIGLA"  , nLine),;
								oModelOHF:GetValue("OHF_CTPDSP" , nLine),;
								oModelOHF:GetValue("OHF_QTDDSP" , nLine),;
								oModelOHF:GetValue("OHF_COBRA"  , nLine),;
								oModelOHF:GetValue("OHF_HISTOR" , nLine),;
								oModelSE2:GetValue("E2__CMOEDA"),;
								oModelOHF:GetValue("OHF_VALOR"  , nLine),;
								cCobraOld,;
								,;
								cChave,;
								oModelOHF:GetValue("OHF_CITEM", nLine) ;
								))

			nUltimoDp := Len(aModelDesp)
			If Empty(aModelDesp[nUltimoDp])
				lOk        := .F.
				aModelDesp := {}
				Exit
			ElseIf nOperDesp == MODEL_OPERATION_INSERT
				oModelOHF:GoLine(nLine)
				oModelOHF:SetValue("OHF_CDESP", aModelDesp[nUltimoDp]:GetValue("NVYMASTER", "NVY_COD"))
			ElseIf nOperDesp == MODEL_OPERATION_DELETE
				oModelOHF:GoLine(nLine)
				oModelOHF:SetValue("OHF_CDESP", "")
			EndIf
		EndIf
	Next nLine

Return {lOk, aModelDesp}

//-------------------------------------------------------------------
/*/{Protheus.doc} J246AcDesp(oModel)
Verifica se é necessário gerar um INSERT/UPDATE/DELETE de Despesa e retorna qual operação será executada

@param oModel     => Modelo ativo

@return nOperDesp => A operação que é necessário para atualizar a Despesa vinculada, retorna 0 quando não existe atualização para ser realizada.

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246AcDesp(oModel, nLine)
Local nOperDesp  := 0
Local oModelOHF  := oModel:GetModel("OHFDETAIL")
Local lNatDspNew := JurGetDados('SED', 1, xFilial('SED') + oModelOHF:GetValue("OHF_CNATUR", nLine), 'ED_CCJURI') == "5"
Local cNatOld    := JurGetDados('OHF', 1, xFilial('OHF') + oModelOHF:GetValue("OHF_IDDOC", nLine) + oModelOHF:GetValue("OHF_CITEM", nLine), 'OHF_CNATUR')
Local lNatDspOld := JurGetDados('SED', 1, xFilial('SED') + cNatOld, 'ED_CCJURI') == "5"

	If !oModelOHF:IsUpdated(nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_CPART" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_SIGLA" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_CCLIEN", nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_CLOJA" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_CCASO" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_CTPDSP", nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_QTDDSP", nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_DTDESP", nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_VALOR" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_COBRA" , nLine);
	   .Or. oModelOHF:IsFieldUpdated("OHF_HISTOR", nLine)

		If oModelOHF:IsInserted(nLine)
			Iif(lNatDspNew, nOperDesp := MODEL_OPERATION_INSERT, )

		ElseIf oModelOHF:IsDeleted(nLine)
			If lNatDspNew .And. lNatDspOld
				nOperDesp := MODEL_OPERATION_DELETE
			EndIf

		ElseIf oModelOHF:IsUpdated(nLine)
			If lNatDspNew .And. lNatDspOld //Se o lançamento era e continua sendo com despesa
				nOperDesp := MODEL_OPERATION_UPDATE

			ElseIf lNatDspNew //Se o lançamento NÃO era de Despesa e agora é de Despesa
				nOperDesp := MODEL_OPERATION_INSERT

			ElseIf lNatDspOld //Se o lançamento era de Despesa e agora NÃO é mais de Despesa
				nOperDesp := MODEL_OPERATION_DELETE

			EndIf
		EndIf
	EndIf

Return nOperDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} J246CMMdls
Efetua o commit nos modelos.

@param aModels, Array com os Modelos para comitar
@param cTable , Tabela principal dos modelos (aModels)
@param cIdModel, Id do modelo principal (cTable)

@author bruno.ritter
@since 04/10/2017
/*/
//-------------------------------------------------------------------
Static Function J246CMMdls(aModels, cTable, cIdModel)
	Local nRecLine  := 0
	Local nQtdMdls  := Len(aModels)
	Local nMdl      := 1
	Local oModel    := Nil

	ProcRegua(nQtdMdls)

	For nMdl := 1 To nQtdMdls
		oModel   := aModels[nMdl]:GetModel(cIdModel)
		nRecLine := oModel:GetDataID()
		(cTable)->(DbGoTo(nRecLine))
		aModels[nMdl]:CommitData()
		aModels[nMdl]:DeActivate()
		aModels[nMdl]:Destroy()
		IncProc()
	Next nMdl

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246WHEN
When dos campos da OHF - Desdobramento financeiro

1 - Escritório
2 - Escritório e Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA246WHEN()
Local lRet     := .T.
Local cCampo   := Alltrim(StrTran(ReadVar(), 'M->', ''))
Local cModelo  := "OHFDETAIL"
Local cNatur   := "OHF_CNATUR"
Local cEscrit  := "OHF_CESCR"
Local cCusto   := "OHF_CCUSTO"
Local cSigla   := "OHF_SIGLA2"
Local cRateio  := "OHF_CRATEI"
Local cClient  := "OHF_CCLIEN"
Local cLoja    := "OHF_CLOJA"
Local cCaso    := "OHF_CCASO"

// Grupo Natureza
If cCampo $ 'OHF_CESCR'
	lRet := JurWhNatCC("1", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

ElseIf cCampo $ 'OHF_CCUSTO'
	lRet := JurWhNatCC("2", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

ElseIf cCampo $ 'OHF_SIGLA2|OHF_CPART2'
	lRet := JurWhNatCC("3", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

ElseIf cCampo $ 'OHF_CRATEI'
	lRet := JurWhNatCC("4", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

// Grupo Despesa
ElseIf cCampo $ 'OHF_CCLIEN|OHF_CLOJA|OHF_QTDDSP|OHF_COBRA|OHF_DTDESP|OHF_CTPDSP'
	lRet := JurWhNatCC("5", cModelo, cNatur, , , , , cClient, cLoja, cCaso)

ElseIf cCampo $ 'OHF_CCASO'
	lRet := JurWhNatCC("6", cModelo, cNatur, , , , , cClient, cLoja, cCaso)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246IniCBD()
Função do gatilho das naturezas para preencher o valor padrão "cobrar despesa?".

@return cOpcao => Opção do campo cobrar despesa

@author bruno.ritter/ricardo.neves
@since 12/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246IniCBD(cCampo)
	Local cOpcao := ''

	Default cCampo := 'OHF_CNATUR'

	If JurGetDados('SED', 1, xFilial('SED') + FwFldGet(cCampo), 'ED_CCJURI') == '5'
		cOpcao := '1'
	EndIf

Return cOpcao

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldEscr(cEscrit)
Validação do campo de Escritório

@param cEscrit  Código do escritório

@author Luciano Pereira dos Santos
@since  05/10/2017
@obs    Função chamada no X3_VALID dos campos OHF_CESCR e OHV_CESCR
/*/
//-------------------------------------------------------------------
Function J246VldEscr(cEscrit, cCampo)
	Local lRet   := .T.

	Default cCampo := "OHF_CESCR"

	If cCampo == "OHF_CESCR"
		lRet := ExistCpo('NS7', cEscrit, 1) .And. JAVLDCAMPO('OHFDETAIL', 'OHF_CESCR', 'NS7', 'NS7_ATIVO', '1')
	ElseIf cCampo == "OHV_CESCR"
		lRet := ExistCpo('NS7', cEscrit, 1) .And. JAVLDCAMPO('OHVDETAIL', 'OHV_CESCR', 'NS7', 'NS7_ATIVO', '1')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246DESC
Retorna a descrição do caso. Chamado pelo inicializador padrão dos campos

@param  - cCampo    Nome do campo para busca dos dados de Cliente e Loja

@return - cRet      Descrição/Assunto do Caso

@author bruno.ritter
@since  05/10/2017
@obs    Função chamada no X3_RELACAO dos campos OHF_DCASO e OHV_DCASO
/*/
//-------------------------------------------------------------------
Function JA246DESC(cCampo)
	Local cRet     := ""
	
	Default cCampo := ""

	If !Empty(cCampo)
		If cCampo == 'OHF_DCASO'
			cRet := Posicione('NVE', 1, xFilial('NVE') + OHF->OHF_CCLIEN + OHF->OHF_CLOJA + OHF->OHF_CCASO, 'NVE_TITULO')
		ElseIf cCampo == 'OHV_DCASO'
			cRet := Posicione('NVE', 1, xFilial('NVE') + OHV->OHV_CCLIEN + OHV->OHV_CLOJA + OHV->OHV_CCASO, 'NVE_TITULO')
		EndIf
	EndIf

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J246ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246ClxCa()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cTab      := IIF(oModel:GetID() == "JURA246", "OHF", "OHV")
Local cIdGrid   := cTab + "DETAIL"
Local cClien    := ""
Local cLoja     := ""
Local cCaso     := ""

cClien := oModel:GetValue(cIdGrid, cTab + "_CCLIEN")
cLoja  := oModel:GetValue(cIdGrid, cTab + "_CLOJA")
cCaso  := oModel:GetValue(cIdGrid, cTab + "_CCASO")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldHis
Validação do historico padrão

@param cHist  Código do hitórico padrão

@author Luciano Pereira dos Santos
@since  05/10/2017
@obs    Função chamada X3_VALID dos campos OHF_CHISTP e OHV_CHISTP
/*/
//-------------------------------------------------------------------
Function J246VldHis(cHist, cCampo)
	Local lRet := .T.

	Default cHist  := ""
	Default cCampo := "OHF_CHISTP"

	If cCampo == "OHF_CHISTP"
		lRet := ExistCpo('OHA', cHist, 1) .And. JAVLDCAMPO('OHFDETAIL', 'OHF_CHISTP', 'OHA', 'OHA_CTAPAG', '1')
	ElseIf cCampo == "OHV_CHISTP"
		lRet := ExistCpo('OHA', cHist, 1) .And. JAVLDCAMPO('OHVDETAIL', 'OHV_CHISTP', 'OHA', 'OHA_CTAPAG', '1')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246PosOHF
Pós validação do grid OHF

Centro de Custo Jurídico (cCCNatur || cCCNatDest)
1 - Escritório
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 06/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246PosOHF(oModel)
Local lRet      := .T.
Local lIsRest   := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

	lRet := JurVldNCC(oModel, "OHFDETAIL", "OHF_CNATUR", "OHF_CESCR", "OHF_CCUSTO", "OHF_CPART2", "OHF_SIGLA2", "OHF_CRATEI", "OHF_CCLIEN", "OHF_CLOJA", ;
                       "OHF_CCASO", "OHF_CTPDSP", "OHF_QTDDSP", "OHF_COBRA ", "OHF_DTDESP", "OHF_CPART", "OHF_SIGLA", "OHF_CPROJE", "OHF_CITPRJ" )

	If lRet .And. oModel:GetModel("OHFDETAIL"):IsInserted() .And. lIsRest .And. OHF->(FieldPos( "OHF_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD") .And. JVldTipoCp(SE2->E2_TIPO,.F.)
		lRet := JurMsgCdLD(oModel:GetValue("OHFDETAIL", "OHF_CODLD"))
	EndIf
	
	If lRet .And. Empty(oModel:GetValue("OHFDETAIL", "OHF_CHISTP")) .And. SuperGetMv("MV_JHISPAD", .F., .F.)
		lRet := JurMsgErro(STR0054,, STR0055) // "É obrigatório o preenchimento do Histórico Padrão, conforme o parâmetro MV_JHISPAD." # "Informe um código válido para o Histórico Padrão."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldCli()
Validacao cliente/loja igual os parametros: MV_JURTS5 e MV_JURTS6 ou
MV_JURTS9 e MV_JURTS10

@Param oModel  Modelo de dados

@author Jorge Luis Branco Martins Junior
@since 06/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246VldCli(oModel)
Local lRet       := .T.
Local oModelOHF  := oModel:GetModel("OHFDETAIL")
Local nLine      := 1
Local nQtdOHF    := oModelOHF:GetQtdLine()

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	For nLine := 1 To nQtdOHF
		If !oModelOHF:IsDeleted(nLine)
			lRet := JurCliLVld(oModel, oModelOHF:GetValue('OHF_CCLIEN', nLine), oModelOHF:GetValue('OHF_CLOJA', nLine))
			If !lRet
				Exit
			EndIf
		EndIf
	Next nLine
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldACT(oModel)
Função de validação da ativação do modelo.

@author bruno.ritter
@since 07/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246VldACT(oModel)
Local lRet     := .T.
Local nOper    := oModel:GetOperation()
Local aArea    := GetArea()

 	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_DELETE
		If ! FWIsInCallStack("J246DelOHF") .And. Empty(JURUSUARIO(__CUSERID))
			lRet := .F.
			ApMsgAlert(STR0019 + CRLF + STR0020) // "Não será possível manipular os desdobramentos do Contas Pagar, pois o usuário não está vinculado a um participante." "Associe seu usuário a um participante para ter acesso a operação.
		EndIf
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246PreOHF()
Função de pré validação do modelo OHF

@author bruno.ritter
@since 11/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246PreOHF(oModel, nLine, cAction, cField, xNewValue, xOldValue)
Local lRet        := .T.
Local lIsRest     := (IIF(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local lOrigJ235A  := FwIsInCallStack("J235ACancela")
Local lOrigJ281   := FwIsInCallStack("MATA103")
Local oModelOHF   := oModel:GetModel("OHFDETAIL")
Local cIdDoc      := ""
Local cNatur      := ""
Local cCCNaturez  := ""
Local cCCNatNew   := ""
Local cCCNatOld   := ""
Local cBxTPosPag  := ""
Local cDtContabil := IIF(OHF->(ColumnPos("OHF_DTCONT")) > 0, DtoS(oModelOHF:GetValue("OHF_DTCONT", nLine)), "")
Local cCodAprDes  := IIF(OHF->(ColumnPos("OHF_NZQCOD")) > 0, oModelOHF:GetValue("OHF_NZQCOD", nLine), "")
Local cAnexo      := oModelOHF:GetValue("OHF__ANEXO", nLine)

// Não permite alteração de registros contabilizados
If !Empty(cDtContabil) .And. cAction $ "CANSETVALUE|DELETE"
	lRet := .F.
	If cAction == "DELETE"
		JurMsgErro(STR0044, , STR0045, .F.) // "Não é possível alterar/excluir o registro!" # "Desdobramento já contabilizado."
	EndIf
EndIf

// Verifica se o desdobramento é originado de uma aprovação de despesa
If lRet .And. !IsBlind() .And. !Empty(cCodAprDes) .And. cAction $ "DELETE" .And. !lOrigJ235A .And. !lOrigJ281
	lRet := ApMsgYesNo(STR0050) // "Esse desdobramento tem como origem a aprovação de uma solicitação de despesa. Deseja realmente excluir o desdobramento e reprovar a solicitação de despesa?"
	If !lRet
		JurMsgErro(STR0051, , STR0052, .F.) // "Operação cancelada." # "Desdobramento não removido."
	EndIf
EndIf

//Se o campo OHF_CNATUR foi alterado é porque inicialmente ele não era do tipo "6"
If lRet .And. "CANSETVALUE" != cAction .And. !oModelOHF:IsFieldUpdated("OHF_CNATUR", nLine)
	cNatur     := oModelOHF:GetValue("OHF_CNATUR")
	cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNatur, "ED_CCJURI")

	If cCCNaturez == "6" //Transitória pós pagamento
		cIdDoc  := oModelOHF:GetValue("OHF_IDDOC")
		OHG->(DbSetOrder(1))
		If OHG->(DbSeek(xFilial("OHG")+cIdDoc))
			cBxTPosPag := JurInfBox("ED_CCJURI", "6" )
			lRet       := JurMsgErro(i18n(STR0023, {cBxTPosPag});//"Quando já existe um desdobramento pós pagamento lançado no título, não é possível alterar um desdobranto cujo a natureza é do tipo '6 - #1'."
			,, STR0024) //"Verifique as o desdobramento pós pagamento lançado para esse título."
		EndIf
	EndIf
EndIf

If lRet .And. !lIsRest ;                                   // Execução via REST integração com LegalDesk
        .And. "CANSETVALUE" != cAction ;                   // Alteração de Valor
        .And. cField == "OHF_CNATUR" ;                     // Campo de natureza
        .And. xNewValue != xOldValue                       // Valor novo diferente do valor antigo

	cCCNatNew := JurGetDados("SED", 1, xFilial("SED") + xNewValue, "ED_CCJURI")
	cCCNatOld := JurGetDados("SED", 1, xFilial("SED") + xOldValue, "ED_CCJURI")

	If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integração Controle Orçamentário SIGAPFS x SIGAFIN
		If ! Empty(cCCNatOld) .And. cCCNatNew != cCCNatOld // Centros de custos jurídico diferentes
			lRet := JurMsgErro(STR0033,,; // "Não é possível alterar a natureza desse desdobramento."
			      i18n(STR0034, {AllTrim(xOldValue)}) ) // "Indique uma natureza que possua o mesmo centro de custo jurídico da natureza '#1'."
		EndIf
	EndIf

	If lRet .And. AllTrim(cAnexo) == ICO_TEM_ANEXO // Possui anexos
		If cCCNatNew $ '6|7'// Houve mudança de centro de custo e o novo centro de custo é transitório ou transitório pós pagamento
			lRet := JurMsgErro(STR0033,,; // "Não é possível alterar a natureza desse desdobramento."
			      i18n(STR0048, {AllTrim(xNewValue)}) ) // "O desdobramento possui anexo(s). Para indicar a natureza '#1' é necessário excluir o(s) anexo(s)."
		EndIf
	EndIf
EndIf

If lRet .And. cAction == "SETVALUE" .And. !Empty(oModelOHF:GetValue("OHF_CDESP")) ;
   .And. cField $ "OHF_CPART|OHF_SIGLA|OHF_CCLIEN|OHF_CLOJA|OHF_CCASO|OHF_CTPDSP|OHF_QTDDSP|OHF_DTDESP|OHF_COBRA"

	lRet := J246VldPre(oModelOHF,"OHF")
EndIf

If lRet
	lRet := JAtuValDes("OHF", oModel, nLine, cAction)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldPre
Valida se o usuário tem permissão para alterar lançamentos em pré-fatura
e se a mesma pode ser editada.

@Param oMdlDes, Modelo de dados de desdobramentos/desd. pós pag.
@Param  cTab  , Tabela do desdobramento "OHF" ou desdobramento pós pag. "OHG"

@author Abner Fogaça de Oliveira
@since 04/05/2020
/*/
//-------------------------------------------------------------------
Function J246VldPre(oMdlDes, cTab)
	Local lRet     := .T.
	Local cPartLog := JurUsuario(__CUSERID)

	If JurGetDados("NUR", 1, xFilial("NUR") + cPartLog, "NUR_LCPRE") == "2" // Participante sem permissão para alterar lançamentos em pré-fatura
		lRet := JurMsgErro(STR0062,, STR0063) // "O participante não tem permissão para alterar despesas com Pré-faturas." # "Verifique o cadastro do participante."
	Else
		cDespesa := oMdlDes:GetValue(cTab + "_CDESP")
		aRetDesp := JurGetDados("NVY", 1, xfilial("NVY") + cDespesa, {"NVY_SITUAC", "NVY_CPREFT"})

		// Se a chamada está vindo do Cadastro de Despesas e a Pre-Fatura está em Minuta emitida, permite a alteração
		// pois está replicando a alteração da Descrição para o Desdobramento
		If (IsInCallStack("JURA049") .And. (JurGetDados("NX0", 1, xFilial("NX0") + aRetDesp[2], "NX0_SITUAC") $ "6")) // Minuta emitida
			lRet := .T.
		ElseIf !Empty(aRetDesp) .And. (aRetDesp[1] == "2" .Or.;
			(!Empty(aRetDesp[2]) .And. !(JurGetDados("NX0", 1, xFilial("NX0") + aRetDesp[2], "NX0_SITUAC") $ "2|3|C|F"))) // Pré-Fatura difernete de: Análise, Alterada, Revisão e Aguardando Sincronização
			lRet := JurMsgErro(STR0056,,; // "A situação da despesa vinculada ao desdobramento não permite alterações."
				i18n(STR0057, {AllTrim(cDespesa)}) ) // "Verifique o cadastro da despesa '#1'."
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA246Event
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA246Event FROM FWModelEvent
	Data aModelDesp // Model para inclusão de Despesa
	Data aModelLanc // Model para alteração de Lançamentos
	Data aModelNZQ  // Model para aprovação de despesa

	Method New()
	Method GridLinePreVld()
	Method GridLinePosVld()
	Method ModelPosVld()
	Method Before()
	Method InTTS()
	Method Destroy()
End Class

//-------------------------------------------------------------------
/*/ { Protheus.doc } New()
New FWModelEvent
/*/
//-------------------------------------------------------------------
Method New() Class JA246Event

	Self:aModelDesp := {}
	Self:aModelLanc := {}
	Self:aModelNZQ  := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid

@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId       , nome do campo
@param xValue    , Novo valor do campo
@param xCurrentVl, Valor atual do campo

@author bruno.ritter
@since 20/12/2018
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrentVl) Class JA246Event
	Local lRet       := .T.
	Local lDesdOld   := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lDesdFin   := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local lExisteBx  := SE2->E2_SALDO != SE2->E2_VALOR

	If cModelId == "OHFDETAIL" .And. (lExisteBx .And. !lDesdFin)
		If cAction $ "DELETE" .And. !oSubModel:IsInserted()
			lRet := JurMsgErro(STR0021,, STR0022, .F.) // "Não é permitido incluir ou excluir desdobramentos quando a situação do título é diferente de aberto." "Altere a situação do título."
		EndIf

		If cAction == 'CANSETVALUE' .And. oSubModel:IsInserted()
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Metodo de pos-validação do linha do Grid.

@param  oSubModel, Submodelo do grid de desdobramentos (OHF)
@param  cModelID , ID do Submodelo de desdobramentos (OHFDETAIL)
@param  nLine    , Linha posicionada do grid

@return lLineOk  , Se verdadeiro os dados dá linha estão válidos

@author Jonatas Martins
@since  12/07/2021
/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oSubModel, cModelID, nLine) Class JA246Event
Local cNatPosPag := JurBusNat("6") // Natureza Transitória Pós Pagamento
Local cBxTPosPag := ""
Local lPosLineOK := .T.

	If cModelID == "OHFDETAIL" .And. !Empty(cNatPosPag)
		If oSubModel:GetValue("OHF_VALOR") < 0 .And. oSubModel:GetValue("OHF_CNATUR") == cNatPosPag // Não permitir valor negativo para natureza de Pós Pagameto
			cBxTPosPag := JurInfBox("ED_CCJURI", "6", "3")
			lPosLineOK := JurMsgErro(I18N("Natureza do tipo #1 não pode receber valor negativo!", {cBxTPosPag}),, "Insira um valor positivo ou altere a natureza.")
		EndIf
	EndIf

Return (lPosLineOK)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Model.

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA246Event
	Local lRet       := .T.
	Local lIsRest    := FindFunction("JurIsRest") .And. JurIsRest()
	Local lOrigJu049 := FwIsInCallStack("J049RepDsb") // Quando a origem da operação for da JURA049(Despesa)
	Local lOrigJ235A := FwIsInCallStack("J235ACancela") .Or. FwIsInCallStack("J235ADsdb") // Quando a origem é a JURA235A (aprovação de solicitação de despesas ou cancelamento da aprovação)
	Local lCodAprDes := OHF->(ColumnPos("OHF_NZQCOD")) > 0
	Local lCancAprov := FWIsInCallStack("J235ACancela") // Quando a origem da operação for da Cancelamento aprovação de despesas (JURA235A)
	Local aRetTemp   := {} // Recebe retorno das funções de modelo
	Local nOper      := oModel:GetOperation()
	Local lDesdOld   := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lDesdFin   := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local lExisteBx  := SE2->E2_SALDO != SE2->E2_VALOR
	
	Self:aModelDesp  := {}
	Self:aModelLanc  := {}
	Self:aModelNZQ   := {}

	// Valida cliente e loja nos desdobramentos
	lRet := J246VldCli(oModel)

	// Altera as aprovações de despesa conforme atualização do desdobramento
	If lRet .And. lCodAprDes .And. FindFunction("J235AUpdNZQ") .And. !lOrigJ235A
		aRetTemp := J235AUpdNZQ(oModel)
		If lRet := aRetTemp[1]
			Self:aModelNZQ := aRetTemp[2]
		EndIf
	EndIf

	If lRet .And. !lOrigJu049
		//Gera e valida modelo para INSERT/UPDATE/DELETE da Despesa
		aRetTemp := J246OpDesp(oModel)
		If lRet := aRetTemp[1]
			Self:aModelDesp := aRetTemp[2]
		EndIf
	EndIf

	// Validação Calendário contábil x Lançamentos
	If lRet
		lRet := JA246VldCal(oModel)
	EndIf

	// Valida dados do desdobramento
	If lRet .And. ! oModel:GetModel("OHFDETAIL"):IsDeleted()
		lRet := J246VldDes(oModel)
	EndIf

	If lRet .And. (lExisteBx .And. !lDesdFin)
		Self:aModelLanc := J246VlLanc(oModel)
	EndIf

	If !lRet
		JurFreeArr(@Self:aModelDesp)
		JurFreeArr(@Self:aModelLanc)
		JurFreeArr(@Self:aModelNZQ)
	EndIf

	If lRet .And. FindFunction("J235Anexo") .And. !FWIsInCallStack("J247LANC") .And. (lIsRest .Or. lCancAprov .Or. nOper == MODEL_OPERATION_DELETE)
		lRet := J235Anexo(oModel, "OHF", "OHFDETAIL", "OHF_IDDOC", "OHF_CITEM")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Before
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)

@author Bruno Ritter
@since 07/11/2019
/*/
//-------------------------------------------------------------------
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA246Event
Local lDelOHF := .F. //Rotina de exclusão da OHF

	// Processamento para títulos que foram desdobrados (parcelado) pelo financeiro
	If cModelId == "SE2MASTER"
		J246DesFin(oSubModel:GetModel(), @Self:aModelDesp, @Self:aModelLanc, @Self:aModelNZQ)
	EndIf

	// Executa estorno de contabilização na alteração/exclusão de cada linha do desdobramento
	If cModelId == "OHFDETAIL" 
		lDelOHF := FWIsInCallStack("J246DelOHF")
		If !lNewRecord .And. !lDelOHF .And. FindFunction("JURA265B") .And. FindFunction("J265LpFlag") ;
		   .And. OHF->(ColumnPos("OHF_DTCONT")) > 0 .And. OHF->(ColumnPos("OHF_DTCONI")) > 0
			J246EstCtb(oSubModel, "OHF", "948")
		EndIf
		If OHF->(ColumnPos("OHF_CODCF8")) > 0 .And. Existblock("J241EFD") 
			J246EFD(lNewRecord, lDelOHF, oSubModel)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação
@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA246Event
	Local cChave   := ""
	Local cItem    := ""
	Local cIdDoc   := ""
	Local nCtb   := 0

	If !Empty(Self:aModelDesp)
		Processa({|| J246CMMdls(Self:aModelDesp, "NVY", "NVYMASTER")}, STR0001, STR0002) // "Gravando." "Atualizando Despesa..."
	EndIf

	If !Empty(Self:aModelLanc)
		Processa({|| J246CMMdls(Self:aModelLanc, "OHB", "OHBMASTER")}, STR0001, STR0049) // "Gravando." "Atualizando Lançamentos..."
	EndIf

	If !Empty(Self:aModelNZQ)
		Processa({|| J246CMMdls(Self:aModelNZQ, "NZQ", "NZQMASTER")}, STR0001, STR0053) // "Gravando." "Atualizando Aprovações de Despesas..."
	EndIf

	If FWIsInCallStack("J235APreApr") .And. FindFunction("J235RepAnex") // Replica anexos da solicitação de despesa quando vier da aprovação
		cChave := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
		cItem  := oModel:GetValue("OHFDETAIL", "OHF_CITEM")
		cIdDoc := FINGRVFK7('SE2', cChave) + cItem
		J235RepAnex("OHF", xFilial("OHF"), cIdDoc, cChave, cItem)
	EndIf

	// Exclui os anexos dos desdobramentos que forem excluídos
	J247ExcAnx(oModel, "OHF")
	
	// Executa contabilização desdobramentos estornados por alterações
	If FindFunction("JURA265B")
		For nCtb := 1 To Len(_aRecDesCtb)
			JURA265B("947", _aRecDesCtb[nCtb]) // Contabilização de inclusão de desdobramento
		Next nCtb
	EndIf

	JurFreeArr(_aRecDesCtb)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrutor da classe

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class JA246Event

	JurFreeArr(@Self:aModelDesp)
	JurFreeArr(@Self:aModelLanc)
	JurFreeArr(@Self:aModelNZQ)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J246DIALOG()
Monta a tela para o Desdobramento após a inclusão do título a pagar.

@param  lConfirma  Indica que a chamada foi feita na confirmação do título
@param  nOperacao  Operação realizada (1-Visualização / 4-Alteração)

@author Nivia Ferreira | Bruno Ritter
@since 09/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246DIALOG(lConfirma, nOperacao)
Local aArea       := GetArea()
Local lRet        := .T.
Local aSize       := {}
Local aButtons    := {}
Local oLayer      := FWLayer():new()
Local oModel      := Nil
Local oModelOHF   := Nil
Local oMainColl   := Nil
Local oScroll     := Nil
Local oPanel      := Nil
Local nSaveRec    := SE2->(Recno())
Local nAltura     := 0
Local nSizeTela   := 0
Local nTamDialog  := 0
Local nCoordPos   := 95
Local nLargura    := 270
Local nPosLoja    := 0
Local nLarLoja    := 0
Local nValorSE2   := JCPVlBruto(nSaveRec)
Local cNaturSE2   := SE2->E2_NATUREZ
Local cCCJuri     := JurGetDados("SED", 1, xFilial("SED") + cNaturSE2, "ED_CCJURI")
Local lCCJuriDef  := !Empty(cCCJuri) // Indica se a natureza tem Centro de Custo Jurídico definido
Local lVisualiza  := .F.
Local lContOrcam  := AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integração Controle Orçamentário SIGAPFS x SIGAFIN
Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc    := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local cChvPagP    := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
Local cIdDocPag   := FINGRVFK7("SE2", cChvPagP)
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lshowFld    := .T.
Local aCampos     := {}
Local aNoAcess    := {}
Local aOfuscar    := {}
Local bOk		  := NIl
Local bClose	  := NIL
Local nProp 	  := 2.24 //Proporção coordenadas x pixel

Private oDlg      := Nil
Private oCliOr    := Nil
Private oDesCli   := Nil
Private oLojaOr   := Nil
Private oLojaOrF3 := Nil
Private oCodNat   := Nil
Private oDesNat   := Nil
Private oVlTit    := Nil
Private oSiglSol  := Nil
Private oNomSigl  := Nil
Private oCodEsc   := Nil
Private oDesEsc   := Nil
Private oCodCc    := Nil
Private oDesCc    := Nil
Private oSigPart  := Nil
Private oDesPart  := Nil
Private oCodRate  := Nil
Private oDesRate  := Nil
Private oCasoOr   := Nil
Private oDesCas   := Nil
Private oCodDesp  := Nil
Private oDesDesp  := Nil
Private oQtdDes   := Nil
Private oDtDesp   := Nil
Private oCbDesp   := Nil
Private oCodHp    := Nil
Private oHistor   := Nil
Private oCodProj  := Nil
Private oDesProj  := Nil
Private oCItProj  := Nil
Private oDItProj  := Nil

Private cCliOr    := ""
Private cLojaOr   := ""

Default lConfirma := .F.
Default nOperacao := MODEL_OPERATION_UPDATE

lVisualiza := nOperacao == 1

If AliasInDic("OHF")
	oModel    := FWLoadModel("JURA246")
	cCliOr    := CriaVar('OHF_CCLIEN', .F.) // Filtro do F3 caso
	cLojaOr   := CriaVar('OHF_CLOJA',  .F.) // Filtro do F3 caso

	oModel:SetOperation(nOperacao)
	If oModel:CanActivate()
		oModel:Activate()
		oModelOHF := oModel:GetModel("OHFDETAIL")

		If oModelOHF:CanSetValue("OHF_CITEM") .And. Empty(oModelOHF:GetValue("OHF_CITEM"))
			oModelOHF:SetValue("OHF_CITEM", StrZero(1, TAMSX3("OHF_CITEM")[1]))
		EndIf

		If lUtProj .Or. lContOrc // Aumenta a quantidade de pixels para ajustar a tela e acionar o scroll
			nAltura := 60
		EndIf

		Do Case
			Case Empty(cCCJuri) .Or. cCCJuri $ "5" // Não definido ou Despesa de Cliente
				nAltura += 340
			Case cCCJuri $ "1|3|4" // Escritório / Profissional / Tabela de Rateio
				nAltura += 250
			Case cCCJuri $ "2"     // Escritório e Centro de Custo
				nAltura += 280
		EndCase

		If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)
			aCampos := {"OHF_DNATUR","OHF_DPART" ,"OHF_DESCR" ,"OHF_DCUSTO","OHF_DPART2","OHF_DRATEI","OHF_DCLIEN","OHF_DCASO" ,"OHF_DPROJE","OHF_DITPRJ","OHF_HISTOR"}

			aNoAcess := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCampos)
			AEval(aNoAcess, {|x| AAdd( aOfuscar, x:CFIELD)})

		EndIf

		// Retorna o tamanho da tela
		aSize   := MsAdvSize(.T.) //Utiliza enchoice na tela
		nSizeTela := aSize[6]*0.95 // Diminui 5% da altura.
		If GetScreenRes()[01] >= 1920 .and. (  (Empty(cCCJuri) .Or. cCCJuri $ "5")  .Or. (lUtProj .Or. lContOrc) )
			If ! (cCCJuri $ "1|3|4") // Escritório / Profissional / Tabela de Rateio
				nProp := 2.18
			Else
				nProp := 2.2
			EndIf
		Else
			If lUtProj .Or. lContOrc
				nProp := 2.20
			ElseIf cCCJuri $ "2"
				nProp := 2.22
			EndIf
		EndIf
			

		If nAltura > 0 .And. nSizeTela < (nAltura * nProp)
			nTamDialog := nSizeTela
		Else
			nTamDialog := nAltura * nProp
		EndIf

 		Define MsDialog oDlg title STR0025 STYLE DS_MODALFRAME FROM 0,0 To nTamDialog, 570 OF oMainWnd PIXEL  //PIXEL//"Detalhamento Contas a Pagar"
			oDlg:lEscClose := .F.
			Aadd( aButtons, {"CLIPS", {|| JA246Anexo(.F.) }, STR0046, STR0046, {|| .T.}} )   //Anexos


			bOk := {|| IIf(J246Commit(@oModel), oDlg:End(), lRet := .F.)}
			bClose := { || IIf(lConfirma, J246DelOHF(), Nil), IIf(lVisualiza .Or. JA246Desd(cIdDocPag), oDlg:End(), Alert(STR0043)) } //"Cancelar" // "O preenchimento dos detalhes do título é obrigatório. Por favor, verifique!"

			oScroll := TScrollArea():New(oDlg,01,01,365,545)
			oScroll:Align := CONTROL_ALIGN_ALLCLIENT

			@ 000,000 MSPANEL oPanel OF oScroll SIZE  nLargura, nAltura


			oLayer := FwLayer():New()
			oLayer:Init(oPanel, .F.)
			oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
			oMainColl := oLayer:GetColPanel( 'MainColl' )

			// Define objeto painel como filho do scroll
			oScroll:SetFrame( oPanel )
			//-----------------
			// "Cód Natureza" //
			oCodNat := TJurPnlCampo():New(005,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CNATUR")), ("OHF_CNATUR"),{|| },{|| },,,,'SEDOHF',,,,,)
			oCodNat:SetWhen({|| J246DlgVal(@oModel, "OHF_CNATUR", cNaturSE2, cCCJuri, .T.) .And. .F. })
			oCodNat:SetValue(cNaturSE2)

			// "Desc Naturez" //
			oDesNat := TJurPnlCampo():New(005,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DNATUR")) ,("ED_DESCRIC"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DNATUR") > 0)
			oDesNat:SetValue(oModelOHF:GetValue("OHF_DNATUR"))
			oDesNat:SetWhen({||.F.})

			//-----------------
			// "Vl. Título." //
			oVlTit := TJurPnlCampo():New(035,015,90,022,oMainColl, STR0027 ,("OHF_SALDO"),{|| },{|| },,,,,,,,,) // "Vl. Título"
			oVlTit:SetWhen({|| J246DlgVal(@oModel, "OHF_VALOR", nValorSE2, cCCJuri) .And. .F. })
			oVlTit:SetValue(nValorSE2)

			
			// "Sigla Solic." //
			oSiglSol := TJurPnlCampo():New(065,015,060,022,oMainColl, AllTrim(RetTitle("OHF_SIGLA")) ,("RD0_SIGLA"),{|| },{|| },,,,'RD0ATV',,,,,)
			oSiglSol:SetValid({|| J246DlgVal(@oModel, "OHF_SIGLA", oSiglSol:GetValue(), cCCJuri)})
			oSiglSol:SetValue(oModelOHF:GetValue("OHF_SIGLA"))
			oSiglSol:SetWhen({||oModelOHF:CanSetValue("OHF_SIGLA")})
			oSiglSol:Enable(!lVisualiza)
	
			// "Nome Solic" //
			oNomSigl := TJurPnlCampo():New(065,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DPART ")) ,("OHF_DPART "),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DPART") > 0)
			oNomSigl:SetValue(oModelOHF:GetValue("OHF_DPART"))
			oNomSigl:SetWhen({||.F.})
		
			//----------------- Inicio oculta campos
			lshowFld :=  !Empty(cCCJuri) .OR. (SuperGetMv("MV_JDETDES",.T.,"1") == "1")
			If cCCJuri $ "1|2" .Or. !lCCJuriDef // Escritório / Escritório - Centro de Custo / Não Definido

				// "Escritório  " //
				oCodEsc := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CESCR")) ,("OHF_CESCR"),{|| },{|| },,,,'NS7ATV',,,,,)
				oCodEsc:SetValid({|| J246DlgVal(@oModel, "OHF_CESCR", oCodEsc:GetValue(), cCCJuri)})
				oCodEsc:SetValue(oModelOHF:GetValue("OHF_CESCR"))
				oCodEsc:SetWhen({||oModelOHF:CanSetValue("OHF_CESCR")})
				oCodEsc:Enable(!lVisualiza .And. !lContOrcam)

				// "Desc. Escrit" //
				oDesEsc := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DESCR")) ,("OHF_DESCR"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DESCR") > 0)
				oDesEsc:SetValue(oModelOHF:GetValue("OHF_DESCR"))
				oDesEsc:SetWhen({||.F.})
				IF !lshowFld
					oCodEsc:HIDE()
					oDesEsc:HIDE()
				ELSE
					nCoordPos+=30
				ENDIF
				//-----------------

				If cCCJuri == "2" .Or. !lCCJuriDef // Escritório - Centro de Custo / Não Definido

					// "Centro Custo" //
					oCodCc := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CCUSTO")) ,("OHF_CCUSTO"),{|| },{|| },,,,'CTTNS7',,,,,)
					oCodCc:SetValid({||J246DlgVal(@oModel, "OHF_CCUSTO", oCodCc:GetValue(), cCCJuri)})
					oCodCc:SetValue(oModelOHF:GetValue("OHF_CCUSTO"))
					oCodCc:SetWhen({||oModelOHF:CanSetValue("OHF_CCUSTO")})
					oCodCc:Enable(!lVisualiza .And. !lContOrcam)

					//"Desc C Custo" //
					oDesCc := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DCUSTO")) ,("OHF_DCUSTO"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DCUSTO") > 0)
					oDesCc:SetValue(oModelOHF:GetValue("OHF_DCUSTO"))
					oDesCc:SetWhen({||.F.})
					IF !lshowFld
						oCodCc:HIDE()
						oDesCc:HIDE()
					ELSE
						nCoordPos+=30
					ENDIF

				EndIf

			EndIf

			//-----------------

			IF cCCJuri == "3" .Or. !lCCJuriDef // Profissional / Não Definido

				// "Sigla Partic" //
				oSigPart := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_SIGLA2")) ,("RD0_SIGLA"),{|| },{|| },,,,'RD0ATV',,,,,)
				oSigPart:SetValid({||J246DlgVal(@oModel, "OHF_SIGLA2", oSigPart:GetValue(), cCCJuri)})
				oSigPart:SetValue(oModelOHF:GetValue("OHF_SIGLA2"))
				oSigPart:SetWhen({||oModelOHF:CanSetValue("OHF_SIGLA2")})
				oSigPart:Enable(!lVisualiza .And. !lContOrcam)

				// "Nome Part." //
				oDesPart := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DPART2")) ,("OHF_DPART2"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DPART2") > 0)
				oDesPart:SetValue(oModelOHF:GetValue("OHF_DPART2"))
				oDesPart:SetWhen({||.F.})

				IF !lshowFld
					oSigPart:HIDE()
					oDesPart:HIDE()
				ELSE
					nCoordPos+=30
				ENDIF
			ENDIF

			//-----------------

			If cCCJuri == "4" .Or. !lCCJuriDef // Tabela de Rateio / Não Definido

				// "Tab. Rateio " //
				oCodRate := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CRATEI")) ,("OH6_CODIGO"),{|| },{|| },,,,'OH6',,,,,)
				oCodRate:SetValid({||J246DlgVal(@oModel, "OHF_CRATEI", oCodRate:GetValue(), cCCJuri)})
				oCodRate:SetValue(oModelOHF:GetValue("OHF_CRATEI"))
				oCodRate:SetWhen({||oModelOHF:CanSetValue("OHF_CRATEI")})
				oCodRate:Enable(!lVisualiza .And. !lContOrcam)
			

				// "Desc. Rateio" //
				oDesRate := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DRATEI")) ,("OHF_DRATEI"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DRATEI") > 0)
				oDesRate:SetValue(oModelOHF:GetValue("OHF_DRATEI"))
				oDesRate:SetWhen({||.F.})
				IF !lshowFld
					oCodRate:HIDE()
					oDesRate:HIDE()
				ELSE
					nCoordPos+=30
				ENDIF		
			ENDIF

			//-----------------

			If cCCJuri == "5" // Despesa de Cliente

				// "Cód Cliente" //
				oCliOr := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CCLIEN")) ,("OHF_CCLIEN"),{|| },{|| },,,,'SA1NUH',,,,,)
				oCliOr:SetValid({||J246DlgVal(@oModel, "OHF_CCLIEN", oCliOr:GetValue(), cCCJuri)})
				oCliOr:SetValue(oModelOHF:GetValue("OHF_CCLIEN"))
				oCliOr:SetWhen({||oModelOHF:CanSetValue("OHF_CCLIEN")})
				oCliOr:Enable(!lVisualiza)
				If(cLojaAuto == "1")
					oCliOr:SetChange( {|| cCliOr := oCliOr:GetValue(), oLojaOr:SetValue(JurGetLjAt()), cLojaOr := JurGetLjAt() } )
				Else
					oCliOr:SetChange( {|| cCliOr := oCliOr:GetValue(), cLojaOr := oLojaOr:GetValue() } )
				EndIf

				// "Loja do F3, usado pois a função de valid apaga a loja quando o preenchimento veio do F3" //
				oLojaOrF3 := TJurPnlCampo():New(nCoordPos,085,030,022,oMainColl, "" ,("OHF_CLOJA "),{|| },{|| },,,,,,,,,)
				oLojaOrF3:SetValid({||J246DlgVal(@oModel, "OHF_CLOJA", oLojaOrF3:GetValue(), cCCJuri)})
				oLojaOrF3:SetWhen({||oModelOHF:CanSetValue("OHF_CLOJA")})
				oLojaOrF3:SetChange({|| cCliOr := oCliOr:GetValue(),;
										cLojaOr:= oLojaOr:GetValue()})
				oLojaOrF3:Visible(.F.)

				// "Loja" //
				oLojaOr := TJurPnlCampo():New(nCoordPos,085,030,022,oMainColl, "" ,("OHF_CLOJA "),{|| },{|| },,,,,,,,,)
				oLojaOr:SetValid({||J246DlgVal(@oModel, "OHF_CLOJA", oLojaOr:GetValue(), cCCJuri)})
				oLojaOr:SetValue(oModelOHF:GetValue("OHF_CLOJA"))
				oLojaOr:SetWhen({||oModelOHF:CanSetValue("OHF_CLOJA")})
				oLojaOr:Enable(!lVisualiza)
				oLojaOr:SetChange({|| cCliOr := oCliOr:GetValue(),;
									cLojaOr:= oLojaOr:GetValue()})
				oLojaOr:Visible(cLojaAuto == "2")

				// "NOME CLIENTE" //
				If cLojaAuto == "2"
					nPosLoja := 115
					nLarLoja := 140
				Else
					nPosLoja := 085
					nLarLoja := 170
				EndIf

				oDesCli := TJurPnlCampo():New(nCoordPos,nPosLoja,nLarLoja,022,oMainColl, AllTrim(RetTitle("OHF_DCLIEN")) ,("OHF_DCLIEN"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DCLIEN") > 0)
				oDesCli:SetValue(oModelOHF:GetValue("OHF_DCLIEN"))
				oDesCli:SetWhen({||.F.})

				nCoordPos += 30

				//-----------------
				// "Código Caso" //
				oCasoOr := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CCASO")) ,("OHF_CCASO"),{|| },{|| },,,,'NVELOJ',,,,,)
				oCasoOr:SetValid({||J246DlgVal(@oModel, "OHF_CCASO", oCasoOr:GetValue(), cCCJuri)})
				oCasoOr:SetValue(oModelOHF:GetValue("OHF_CCASO"))
				oCasoOr:SetWhen({||oModelOHF:CanSetValue("OHF_CCASO")})
				oCasoOr:Enable(!lVisualiza)

				// "Desc. Caso" //
				oDesCas := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DCASO")) ,("OHF_DCASO"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DCASO") > 0)
				oDesCas:SetValue(oModelOHF:GetValue("OHF_DCASO"))
				oDesCas:SetWhen({||.F.})

				nCoordPos += 30

				//-----------------
				// "Tipo Despesa" //
				oCodDesp := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHF_CTPDSP")) ,("NRH_COD"),{|| },{|| },,,,'NRH',,,,,)
				oCodDesp:SetValid({|| J246DlgVal(@oModel, "OHF_CTPDSP", oCodDesp:GetValue(), cCCJuri)})
				oCodDesp:SetValue(oModelOHF:GetValue("OHF_CTPDSP"))
				oCodDesp:SetWhen({|| oModelOHF:CanSetValue("OHF_CTPDSP") })
				oCodDesp:Enable(!lVisualiza)

				// "Desc Tp Desp" //
				oDesDesp := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHF_DTPDSP")) ,("NRH_DESC"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DTPDSP") > 0)
				oDesDesp:SetValue(oModelOHF:GetValue("OHF_DTPDSP"))
				oDesDesp:SetWhen({||.F.})

				nCoordPos += 30

				//-----------------
				// "Qtd despesa " //
				oQtdDes := TJurPnlCampo():New(nCoordPos,015,040,022,oMainColl, AllTrim(RetTitle("OHF_QTDDSP")) ,("OHF_QTDDSP"),{|| },{|| },,,,,,,,,)
				oQtdDes:SetValid({|| J246DlgVal(@oModel, "OHF_QTDDSP", oQtdDes:GetValue(), cCCJuri)})
				oQtdDes:SetValue(oModelOHF:GetValue("OHF_QTDDSP"))
				oQtdDes:SetWhen({|| oModelOHF:CanSetValue("OHF_QTDDSP") })
				oQtdDes:Enable(!lVisualiza)

				// "Data Despesa" //
				oDtDesp := TJurPnlCampo():New(nCoordPos,085,060,022,oMainColl, AllTrim(RetTitle("OHF_DTDESP")) ,("OHF_DTDESP"),{|| },{|| },,,,,,,,,)
				oDtDesp:SetValid({|| J246DlgVal(@oModel, "OHF_DTDESP", oDtDesp:GetValue(), cCCJuri)})
				oDtDesp:SetValue(oModelOHF:GetValue("OHF_DTDESP"))
				oDtDesp:SetWhen({|| oModelOHF:CanSetValue("OHF_DTDESP") })
				oDtDesp:Enable(!lVisualiza)

				//-----------------
				// "Cobrar Desp?" //
				oCbDesp := TJurPnlCampo():New(nCoordPos,155,060,025,oMainColl, AllTrim(RetTitle("OHF_COBRA")) ,("OHF_COBRA"),{|| },{|| },,,,,,,,,)
				oCbDesp:SetValid({|| J246DlgVal(@oModel, "OHF_COBRA", oCbDesp:GetValue(), cCCJuri)})
				oCbDesp:SetValue(oModelOHF:GetValue("OHF_COBRA"))
				oCbDesp:SetWhen({|| !lVisualiza .And. oModelOHF:CanSetValue("OHF_COBRA") .And. GetSX3Cache("OHF_COBRA", "X3_VISUAL") <> "V"})

				nCoordPos += 30

			EndIf

			If (lUtProj .Or. lContOrc) .And. OHF->(ColumnPos("OHF_CPROJE")) > 0
				// "Código Projeto" //
				oCodProj := TJurPnlCampo():New(nCoordPos,015,060,022, oMainColl, AllTrim(RetTitle("OHF_CPROJE")) ,("OHF_CPROJE"),{|| },{|| },,,,'OHL',,,,,)
				oCodProj:SetValid({||J246DlgVal(@oModel, "OHF_CPROJE", oCodProj:GetValue(), cCCJuri)})
				oCodProj:SetValue(oModelOHF:GetValue("OHF_CPROJE"))
				oCodProj:SetWhen({||oModelOHF:CanSetValue("OHF_CPROJE")})
				oCodProj:Enable(!lVisualiza .And. !lContOrcam)

				// "Desc. Projeto" //
				oDesProj := TJurPnlCampo():New(nCoordPos,085,170,022, oMainColl, AllTrim(RetTitle("OHF_DPROJE")) ,("OHF_DPROJE"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DPROJE") > 0)
				oDesProj:SetValue(oModelOHF:GetValue("OHF_DPROJE"))
				oDesProj:SetWhen({||.F.})

				nCoordPos += 30

				// "Código Item Projeto" //
				oCItProj := TJurPnlCampo():New(nCoordPos,015,060,022, oMainColl, AllTrim(RetTitle("OHF_CITPRJ")) ,("OHF_CITPRJ"),{|| },{|| },,,,'OHM',,,,,)
				oCItProj:SetValid({||J246DlgVal(@oModel, "OHF_CITPRJ", oCItProj:GetValue(), cCCJuri)})
				oCItProj:SetValue(oModelOHF:GetValue("OHF_CITPRJ"))
				oCItProj:SetWhen({||!Empty(oCodProj:GetValue()) .And. oModelOHF:CanSetValue("OHF_CITPRJ")})
				oCItProj:Enable(!lVisualiza .And. !lContOrcam)

				// "Desc. Item Projeto" //
				oDItProj := TJurPnlCampo():New(nCoordPos,085,170,022, oMainColl, AllTrim(RetTitle("OHF_DITPRJ")) ,("OHF_DITPRJ"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_DITPRJ") > 0)
				oDItProj:SetValue(oModelOHF:GetValue("OHF_DITPRJ"))
				oDItProj:SetWhen({||.F.})

				nCoordPos += 30

			EndIf

			// "Cód Hist Pad" //
			oCodHp := TJurPnlCampo():New(nCoordPos,015,080,022,oMainColl, AllTrim(RetTitle("OHF_CHISTP")) ,("OHF_CHISTP"),{|| },{|| },,,,,,,,,)
			oCodHp:SetValid({|| J246DlgVal(@oModel, "OHF_CHISTP", oCodHp:GetValue(), cCCJuri)})
			oCodHp:SetValue(oModelOHF:GetValue("OHF_CHISTP"))
			oCodHp:SetWhen({|| oModelOHF:CanSetValue("OHF_CHISTP")})
			oCodHp:Enable(!lVisualiza)

			nCoordPos += 30

			//-----------------
			// "Histórico   " //
			oHistor := TJurPnlCampo():New(nCoordPos,015,200,090,oMainColl, AllTrim(RetTitle("OHF_HISTOR")), ("OHF_HISTOR"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHF_HISTOR") > 0)
			oHistor:SetValid({|| J246DlgVal(@oModel, "OHF_HISTOR", oHistor:GetValue(), cCCJuri)})
			oHistor:SetValue(oModelOHF:GetValue("OHF_HISTOR"))
			oHistor:SetWhen({|| oModelOHF:CanSetValue("OHF_HISTOR") })
			oHistor:Enable(!lVisualiza)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bClose,, aButtons,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

		oModel:DeActivate()
		SE2->(dbGoto(nSaveRec))
	EndIf

EndIf

JurFreeArr(@aButtons)

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246Commit()
Botão de ok da dialog, valida e inclui do Desdobramento.

@param oModel  Modelo de dados de Detalhes / Desdobramentos

@author Nivia Ferreira | Bruno Ritter
@since 15/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246Commit(oModel)
Local lRet     := .T.
Local aErro    := {}
Local aArea    := GetArea()

	If oModel:GetOperation() != MODEL_OPERATION_VIEW
		If !(oModel:VldData() .And. oModel:CommitData())
			aErro := oModel:GetErrorMessage(.T.)
			Help("", 1, "HELP",, aErro[6], 1,,,,,,, {aErro[7]})
			lRet := .F.
		EndIf
	EndIf

	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246DlgVal()
Valid dos campos da Dialog.
Valida os campos e preenche os campos referentes aos gatilhos da OHF

@param oModel    Modelo de dados de Detalhes / Desdobramentos
@param cCampo    Campo que será atualizado
@param cValue    Valor que será indicado no cCampo
@param cCCJuri   Centro de Custo Jurídico da natureza indicada no título
@param lLoadObj  Atualiza o arquivo alterado
@author Nivia Ferreira | Bruno Ritter
@since 15/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246DlgVal(oModel, cCampo, cValue, cCCJuri,lLoadObj)
Local aErro      := {}
Local lRet       := .T.
Local oModelOHF  := oModel:GetModel("OHFDETAIL")
Local lCCJuriDef := !Empty(cCCJuri) // Indica se a natureza tem Centro de Custo Jurídico definido
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nPos 		 := 0
Local nI 		 := 0
Local nCampos	 := 0
Local uValue 	 := NIL
Local lAtualiza	 := .F.
Local aCampos  	 := { {"OHF_CNATUR", oCodNat,  { ||.t. }}, ;
					  {"OHF_DNATUR", oDesNat,  { ||.t. }}, ;
					  {"OHF_SIGLA", oSiglSol,  { ||.t. }}, ;
					  {"OHF_DPART",oNomSigl,  { ||.t. }} ,;
					  {"OHF_CESCR", oCodEsc, { || cCCJuri $ "1|2" .Or. !lCCJuriDef }}, ;
					  {"OHF_DESCR", oDesEsc, { ||cCCJuri $ "1|2" .Or. !lCCJuriDef}}, ;
					  {"OHF_CCUSTO", oCodCc,  { ||cCCJuri == "2" .Or. !lCCJuriDef }}, ;
					  {"OHF_DCUSTO",oDesCc,   { ||cCCJuri == "2" .Or. !lCCJuriDef }},;
					  {"OHF_SIGLA2", oSigPart,   { ||cCCJuri == "3" .Or. !lCCJuriDef }} ,;
					  {"OHF_DPART2", oDesPart,  { ||cCCJuri ==  "3" .Or. !lCCJuriDef }}, ;
					  {"OHF_CRATEI", oCodRate,  { ||cCCJuri == "4" .Or. !lCCJuriDef }}, ;
					  {"OHF_DRATEI",oDesRate,  { ||cCCJuri == "4" .Or. !lCCJuriDef  }} ,;
					  {"OHF_CCLIEN", oCliOr,  { ||cCCJuri == "5" }}, ;
					  {"OHF_CLOJA", oLojaOr,  { ||cCCJuri == "5" }}, ;
					  {"OHF_DCLIEN", oDesCli,  { ||cCCJuri == "5" }}, ;
					  {"OHF_CCASO",oCasoOr, { ||cCCJuri == "5" }} ,;
					  {"OHF_DCASO", oDesCas,  { ||cCCJuri == "5"  }}, ;
					  {"OHF_CTPDSP", oCodDesp,  { ||cCCJuri == "5" }}, ;
					  {"OHF_DTPDSP", oDesDesp,  { ||cCCJuri == "5" }}, ;
					  {"OHF_QTDDSP", oQtdDes,  { ||cCCJuri == "5" }}, ;
					  {"OHF_DTDESP",oDtDesp, { ||cCCJuri == "5"  }} ,;
					  {"OHF_COBRA",oCbDesp,  { ||cCCJuri == "5" }} ,;
					  {"OHF_CPROJE", oCodProj,  { ||lUtProj .Or. lContOrc }}, ;
					  {"OHF_DPROJE", oDesProj, { ||lUtProj .Or. lContOrc }}, ;
					  {"OHF_CITPRJ", oCItProj,  { ||lUtProj .Or. lContOrc }}, ;
					  {"OHF_DITPRJ",oDItProj,  { ||lUtProj .Or. lContOrc }} ,;
					  {"OHF_CHISTP", oCodHp,  { ||.t. }}, ;
					  {"OHF_HISTOR", oHistor,  { ||.t. }} } 

	Default lLoadObj  := .F. //Atualiza o objeto

	If oModel:GetOperation() != MODEL_OPERATION_VIEW
		If oModelOHF:CanSetValue(cCampo)
			If oModelOHF:GetValue(cCampo) <> cValue 
				//Alimenta o modelo somente se ele foi atualizado
				lRet := oModelOHF:SetValue(cCampo, cValue)
				lAtualiza := lRet 
			Else
				lAtualiza := lLoadObj
			EndIf
		EndIf

		If  lAtualiza .AND. lRet .And. cCCJuri == "5" .And. !Empty(oLojaOrF3:GetValue()) .And. cLojaAuto == '2'
			lRet := oModelOHF:SetValue("OHF_CLOJA", oLojaOrF3:GetValue())
			oLojaOrF3:SetValue(CriaVar('OHF_CLOJA', .F.))
		EndIf
	EndIf

	

	If lRet 
		If lAtualiza
			nCampos := Len(aCampos)
			nPos := aScan(aCampos, {|c| c[1] == cCampo})
			If !lLoadObj
				nPos++
			EndIf
			If nPos > 0
				For nI := nPos to nCampos
					//Verifica o objeto pode ser atualizado  se o conteudo do modelo x objeto foi atualizado
					If Eval(aCampos[nI, 03]) .AND. (uValue := oModelOHF:GetValue(aCampos[nI, 01]))  <> aCampos[nI, 02]:GetValue()
						aCampos[nI, 02]:SetValue(uValue)
					EndIf
				Next nI
			EndIf
		EndIf	
	Else
		aErro := oModel:GetErrorMessage(.T.)
		Help("", 1, "HELP",, aErro[6], 1,,,,,,, {aErro[7]})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246AtuOHF()
Realiza a atualização dos detalhes / desdobramentos quando houver
alteração de natureza ou outros dados no título.
Uso no cadastro de título a pagar (FINA050 - SIGAFIN)

@param lInclui   Indica se a operação é inclusão
@param nRecno    Recno do título SE2

@author Jorge Martins / Cristina Cintra
@since 13/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246AtuOHF(lInclui, nRecno)
Local aArea       := GetArea()
Local lRet        := .T.
Local lConfirma   := .T. // Indica que a chamada foi feita na confirmação do título
Local lAtuTransit := .F. // Indica se a natureza atual é Transitória de Pagamento
Local lOldTransit := .F. // Indica se a natureza antiga é Transitória de Pagamento
Local nOpc        := MODEL_OPERATION_UPDATE
Local cOldNatSE2  := IIf(Type('cOldNatPFS') <> 'U', cOldNatPFS, "")
Local cNatTrans   := AllTrim(JurBusNat("7")) // Natureza Transitória de Pagamento
Local cTpNatOld   := JurGetDados("SED", 1, xFilial("SED") + cOldNatSE2, "ED_CCJURI")
Local cTpNatAtu   := ""
Local lTpNatDif   := .F. // Indica se o Centro de Custo Jurídico das naturezas são diferentes
Local lDesdOld    := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
Local lTitPriPrc  := .F. // Título digitado pelo usuário para ser parcelado (desdobramento do financeiro)
Local lAlteNat    := .F. // Se ocorreu alteração de natureza abre a tela de detalhe / desdobramento para preenchimento
Local lPodParTit  := .T.
Local cTmpSE2     := ""
Local nValOrig    := 0

Default nRecno := SE2->(Recno())

SE2->(dbGoto(nRecno))

cTpNatAtu   := JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI")
lTpNatDif   := cTpNatOld <> cTpNatAtu
lTitPriPrc  := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Título digitado pelo usuário para ser parcelado (desdobramento do financeiro)
lAlteNat    := cOldNatSE2 <> SE2->E2_NATUREZ // Se ocorreu alteração de natureza abre a tela de detalhe / desdobramento para preenchimento
lOldTransit := AllTrim(cOldNatSE2)      == cNatTrans
lAtuTransit := AllTrim(SE2->E2_NATUREZ) == cNatTrans
nValOrig    := SE2->E2_VALOR

If !lInclui
	// Se não houve alteração de natureza
	If cOldNatSE2 == SE2->E2_NATUREZ .And. !lAtuTransit
		lRet := J246AltOHF() // Altera os campos (ex. Valor) no detalhe / desdobramento

	// Se o Centro de Custo Jurídico das naturezas forem diferentes, excluí os registros de detalhes / desdobramento
	ElseIf lTpNatDif
		lRet := J246DelOHF()
	EndIf
EndIf

// Se for inclusão de uma parcela de desdobramento financeiro, então NÃO abre a nossa tela de desdobramento,
//     pois será aberta apenas a uma vez a tela para o título principal (SE2->E2_STATUS != "D") e 
//     ao salvar o model será replicado o desdobramento para as parcelas igualmente.
// Foi utilizado o FwisInCallStack, pois não foi possível utilizar o campo E2_DESDOBR para indentificar a parcela
//     o financeiro inclui a parcela com E2_DESDOBR = 'N', mas depois ele altera a SE2 para E2_DESDOBR = 'S'
lPodParTit := !FwIsInCallStack("GeraParcSe2")

If lInclui .And. lTitPriPrc .And. lPodParTit

	// Se é o título digitado pelo usuário para ser parcelado (desdobramento), então só irá abrir a nossa tela
	// de desdobramento se for no momento de inclusão do mesmo e só vamos abrir a tela quando o
	// parâmetro MV_NRASDSD utilizar a forma nova de parcelar, onde preenche os dados na FI8 para
	// rastrear os títulos gerados pelo parcelamento
	lPodParTit := lPodParTit .And. !lDesdOld

	If lPodParTit
		cTmpSE2 := J246ParcFi() // Retrona área com o Recno e Valor de cada parcela da SE2 posicionada.

		If lAtuTransit .And. (cTmpSE2)->(!Eof())
			// Se foi um parcelamento e a natureza for transitória de pagamento, não vamos replicar os desdobramento, pois os valores gerados nos desdobramentos (JURA246) vão ficar quebrados e não vão bater com o título
			// Se o desdobramento (financeiro) foi para replicar o título, vamos perguntar se o usuário quer replicar os desdobramento informados (se não for via serviço (FwModel/PO-UI)), senão, vamos abrir o desdobramento (JURA246) da primeira parcela
			If (cTmpSE2)->FI8_VALOR != nValOrig .Or. (!IsBlind() .And. !ApMsgYesNo(STR0061)) // "Os desdobramentos informados a seguir serão destinados à primeira parcela gerada. Deseja replicar para as demais parcelas?"
				SE2->(DbGoTo((cTmpSE2)->RECNO))
			EndIf
		EndIf
		(cTmpSE2)->(dbCloseArea())
	EndIf
EndIf

If lRet .And. lAlteNat .And. lPodParTit
	JURA246(nOpc, .T., lConfirma, lAtuTransit, .F., .T.)
EndIf

SE2->(dbGoto(nRecno))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246DelOHF()
Realiza a exclusão dos detalhes / desdobramentos quando houver
alteração de natureza no título, ou quando for PA - "Pagamento Adiantado".

@author Jorge Martins / Cristina Cintra
@since 13/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246DelOHF(nSE2Recno)
Local oModel      := FWLoadModel("JURA246")
Local oModelOHF   := Nil
Local nQtdOHF     := 0
Local nLine       := 0
Local lRet        := .T.
Local aErro       := {}
Default nSE2Recno := 0

	If nSE2Recno != 0
		SE2->(DbGoTo(nSE2Recno))
	EndIf
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oModelOHF := oModel:GetModel("OHFDETAIL")
	nQtdOHF := oModelOHF:GetQtdLine()

	For nLine := 1 To nQtdOHF
		oModelOHF:GoLine(nLine)
		If !(lRet := lRet .And. oModelOHF:DeleteLine())
			Exit
		EndIf
	Next

	If !lRet
		aErro := oModel:GetErrorMessage(.T.)
		JurMsgErro(aErro[6], , aErro[7])		
	EndIf

	// Executa estorno da contabilização na exclusão de TODAS as linhas do desdobramento
	If lRet .And. nQtdOHF > 0 .And. FindFunction("JURA265B") .And. OHF->(ColumnPos("OHF_DTCONI")) > 0 .And. VerPadrao("948")
		JURA265B("948")
	EndIf
	lRet := lRet .And. J246Commit(oModel)
	oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246AltOHF()
Realiza as alterações nos detalhes / desdobramentos quando houver
alterações no título e não for necessário abrir a tela de
detalhes / desdobramentos.

@author Jorge Martins
@since 13/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246AltOHF()
Local oModel    := FWLoadModel("JURA246")
Local oModelOHF := Nil
Local nQtdOHF   := 0
Local lRet      := .T.

	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:Activate()
	oModelOHF := oModel:GetModel("OHFDETAIL")

	nQtdOHF := oModelOHF:GetQtdLine()

	// Atualiza o campo de valor somente se for "1" detalhe/desdobramento e não existir baixa
	If AllTrim(cOldNatPFS) == AllTrim(SE2->E2_NATUREZ) .And. nQtdOHF == 1;
		.And. SE2->E2_SALDO == SE2->E2_VALOR
		oModelOHF:GoLine( 1 )

		If !Empty(oModelOHF:GetValue("OHF_CNATUR"))
			oModelOHF:SetValue("OHF_VALOR", JCPVlBruto(SE2->(Recno())))
			lRet := J246Commit(oModel)
		EndIf
	EndIf

	oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246VldCal
Validação Calendário Contábil x Lançamentos

@param oModel Modelo de dados de lançamentos

@author Anderson Carvalho
@since 05/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA246VldCal(oModel)
Local lRet      := .T.
Local lCalBlock := .F.
Local cFilAtu   := cFilAnt
Local nI        := 1
Local nLine     := 1
Local aStruct   := {}
Local oModelOHF := oModel:GetModel("OHFDETAIL")
Local cCpoLiber := ""
Local cCampo    := ""
Local cTitulo   := ""
Local oStruct   := FWFormStruct( 2, "OHF" )
Local nOHFQtdLn := 0

cCpoLiber := "OHF_CPART2|OHF_DPART2|"+;
				"OHF_CRATEI|OHF_DRATEI|"+;
					"OHF_CCLIEN|OHF_CLOJA|OHF_DCLIEN|OHF_CCASO|OHF_CRATEI|OHF_DRATEI|OHF_DCASO|OHF_CTPDSP|OHF_DTPDSP|OHF_QTDDSP|OHF_CCUSTO|OHF_DCUSTO|"+;
						"OHF_CESCR|OHF_DESCR|OHF_SIGLA2|OHF_CPART2|OHF_DPART2|OHF_COBRA|OHF_DTDESP"

cFilAnt := oModel:GetValue("SE2MASTER", "E2_FILIAL")

lCalBlock := !(CtbValiDt(, oModel:GetValue("OHFDETAIL", "OHF_DTINCL"), .F.,,, {"PFS001"},))

If lCalBlock
	aStruct := oStruct:GetFields()
	nQtdStruct := Len(aStruct)
	nOHFQtdLn := oModelOHF:GetQtdLine()
	For nLine := 1 To nOHFQtdLn
		If oModelOHF:IsInserted(nLine) .OR. oModelOHF:IsDeleted(nLine)
			lRet := .F.
			Exit
		Else
			For nI := 1 To nQtdStruct
				cCampo  := aStruct[nI][1]
				If (cCampo == "OHF_SIGLA") .And. oModelOHF:IsFieldUpdated(cCampo, nLine)
					lRet := .F.
					cTitulo := I18n(STR0031, {aStruct[nI][MODEL_FIELD_IDFIELD]}) //# "O Calendário Contábil esta bloqueado e o campo '#1' não pode ser alterado."
					Exit
				Else
					If !(cCampo $ cCpoLiber) .And. oModelOHF:IsFieldUpdated(cCampo, nLine)
						lRet := .F.
						cTitulo := I18n(STR0031, {aStruct[nI][MODEL_FIELD_IDFIELD]}) //# "O Calendário Contábil esta bloqueado e o campo '#1' não pode ser alterado."
						Exit
					EndIf
				EndIf
			Next nI
		EndIf
	Next nLine
EndIf

If !lRet
	JurMsgErro(Iif(Empty(cTitulo), STR0029, cTitulo),, I18n(STR0030, {cFilAnt})) //"Calendário Contábil bloqueado." -- "Verifique o bloqueio do processo 'PFS001' no Calendário Contábil da filial '#1', para o período da data do lançamento."
EndIf

cFilAnt := cFilAtu

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246IncOHF
Inclui um desdobramento para o título de PA - Pagamento adiantado ou
para títulos de TX - Impostos

@param nRecnoSE2    Recno do título SE2
@param cTipo        Tipo de desdobramento "PA" - Pagamento antecipado; "TX" - Impostos

@author Bruno Ritter
@since 26/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246IncOHF(nRecnoSE2, cTipo)
	Local lRet       := .T.
	Local oModel     := Nil
	Local oModelOHF  := Nil
	Local cNatDesdob := ""
	Local cHistoric  := ""
	Local cItem      := StrZero(1, TamSx3("OHF_CITEM")[1])
	Local cNatSE2    := ""
	Local cCodOHP    := ""
	Local nValorSE2  := JCPVlBruto(nRecnoSE2)
	Local nRecOld    := SE2->(Recno())

	Default cTipo := "PA"

	SE2->(DbGoTo(nRecnoSE2))

	If cTipo == "PA"
		cNatDesdob := JurBusNat("7",,,, .T.)
		cHistoric  := STR0032 + " - " + AllTrim(SE2->E2_FORNECE) + "/" + AllTrim(SE2->E2_LOJA) + " - " // "Pagamento Antecipado"
		cHistoric  += Capital(AllTrim(JurGetDados("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA , "A2_NOME")))
		cHistoric  += Iif(!Empty(SE2->E2_HIST), " - " + Capital(AllTrim(SE2->E2_HIST)), "")
	ElseIf cTipo == "TX"
		cNatSE2 := Alltrim(SE2->E2_NATUREZ)
		Do Case
			Case cNatSE2 == StrTran(SuperGetMV("MV_IRF",, ''), '"', '') // IRRF Colocado STRTRAN porque o parametro possui aspas
				cCodOHP := "009"
			Case cNatSE2 == StrTran(SuperGetMV("MV_ISS",, ''), '"', '') // ISS
				cCodOHP := "010"
			Case cNatSE2 == StrTran(SuperGetMV("MV_INSS",, ''), '"', '') // INSS
				cCodOHP := "011"
			Case cNatSE2 == StrTran(SuperGetMV("MV_PISNAT",, ''), '"', '') // PIS
				cCodOHP := "012"
			Case cNatSE2 == StrTran(SuperGetMV("MV_COFINS",, ''), '"', '') // COFINS
				cCodOHP := "013"
			Case cNatSE2 == StrTran(SuperGetMV("MV_CSLL",, ''), '"', '') // CSLL
				cCodOHP := "014"
		EndCase
		If cCodOHP == ""
			cNatDesdob := SE2->E2_NATUREZ
		Else
			cNatDesdob := JurClasNat(cCodOHP)
		EndIf

		cHistoric := STR0042 // "Impostos"
	EndIf

	If Empty(cNatDesdob)
		lRet := .F.
	Else
		// O Modelo deve ser instanciado após o posicionamento da SE2
		oModel    := FWLoadModel("JURA246")
		oModelOHF := oModel:GetModel("OHFDETAIL")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		Iif(lRet, lRet := oModelOHF:LoadValue("OHF_CITEM", cItem     ), Nil)
		Iif(lRet, lRet := oModelOHF:SetValue("OHF_CNATUR", cNatDesdob), Nil)
		Iif(lRet, lRet := oModelOHF:SetValue("OHF_VALOR" , nValorSE2 ), Nil)
		Iif(lRet, lRet := oModelOHF:SetValue("OHF_HISTOR", cHistoric ), Nil)

		lRet := J246Commit(oModel)
		oModel:DeActivate()
	EndIf

	SE2->(DbGoTo(nRecOld))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246RetPrj()
Retorna o valor do código do projeto da dialog criada pela função J246DIALOG

@author Bruno Ritter
@since 26/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246RetPrj()
Local cRet := ""

If Type("oCodProj") == "O"
	cRet := oCodProj:GetValue()
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldDes()
Valida dados do desdobramento quando a natureza do título for diferente
de Transitória de Pagamento

@param oModel, objeto, Modelo da OHF

@obs Essa validação é necessária devido a inclusão de CP com desdobramento 
( serviço: JurRestCP)

@author bruno.ritter/queizy.nascimento
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J246VldDes(oModel)
	Local lRet       := .T.
	Local cNatTit    := AllTrim(oModel:GetValue("SE2MASTER", "E2_NATUREZ")) // Natureza do título
	Local nValTit    := JCPVlBruto(SE2->(Recno()))
	Local cValtit    := ""
	Local cNatTrans  := AllTrim(JurBusNat("7")) // Natureza Transitória de Pagamento
	Local oModelOHF  := Nil

	If cNatTit != cNatTrans
		oModelOHF := oModel:GetModel("OHFDETAIL")
		lRet := oModelOHF:Length(.T.) <= 1

		If !lRet
			JurMsgErro(STR0035, , STR0036)// "Natureza permite adicionar apenas um desdobramento.", "Informe apenas um desdobramento."
		EndIf

		If lRet .And. AllTrim(SE2->E2_TIPO) == "PA"
			lRet := JurMsgErro(STR0037, , STR0041)// "Natureza do desdobramento inválida!", "A natureza do desdobramento deve ser do tipo 6 - Transitória de Pagamento"
		EndIf

		If lRet .And. nValTit != oModelOHF:GetValue("OHF_VALOR")
			cValtit := AllTrim(Transform(nValTit, PesqPict("SE2", "E2_VALOR")))
			lRet    := JurMsgErro(STR0039, , I18N(STR0040, {cValTit}))// "Valor do desdobramento inválido!", "O valor do desdobramento deve ser igual ao valor do título #1."
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246Desd()
Verifica se existe desdobramento para o título.

@param cIdDoc    Chave para busca do desdobramento

@author Cristina Cintra
@since 01/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA246Desd(cIdDoc)
Local aAreaOHF   := OHF->(GetArea())
Local cFilOHF    := xFilial("OHF")
Local lRet       := .T.

OHF->(DbSetOrder(1)) //OHF_FILIAL + OHF_IDDOC + OHF_CITEM
If ! OHF->(DbSeek(cFilOHF + cIdDoc))
	lRet := .F.
EndIf

RestArea(aAreaOHF)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246Anexo()
Anexo de documentos

@param  lView  => .T./.F. - Indica se a chamada foi feita em uma view.
                            Será falso quando for a tela de detalhes
                            do contas a pagar.

@return lRet   => .T./.F. - Indica se foi possível anexar documentos.

@obs Manter como Function devido ao uso em rotina customizada.

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA246Anexo(lView)
Local aAreas     := { OHF->(GetArea()), GetArea() }
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
Local oModelOHF  := oModel:GetModel("OHFDETAIL")
Local nLineOHF   := oModelOHF:GetLine()
Local lRet       := .T.

Default lView    := .T.

	oModelOHF := oModel:GetModel("OHFDETAIL")
	nLineOHF  := oModelOHF:GetLine()

	If lRet := J247VAnexo(oModelOHF, nLineOHF, "OHF_CNATUR") // Verifica que pode anexar nesse desdobramento

		OHF->(dbGoto(oModelOHF:GetDataId())) // Posiciona a tabela para a rotina de anexos

		JURANEXDOC("OHF", "OHFDETAIL", "", "OHF_IDDOC", "", "", "", "", "", "3", "OHF_CITEM", .F., .F., .T.) // Abre tela de anexo de documento

		If lView
			oModelOHF:LoadValue("OHF__ANEXO", J247IcoAnx("OHF") ) // Atualiza a legenda
			oView:Refresh("OHFDETAIL")
		EndIf

	EndIf

AEval( aAreas, {|aArea| RestArea( aArea ) } )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VlLanc
Gera os modelos e valida os lançamentos gerados pelos desdobramentos
alterados

@param oModel   , Model da JURA246

@return aMdlLanc, Modelos dos lançamento que devem ser comitados

@author Bruno Ritter
@since 20/12/18
/*/
//-------------------------------------------------------------------
Static Function J246VlLanc(oModel)
	Local oModelOHF   := oModel:GetModel("OHFDETAIL")
	Local lDesdOld    := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lDesdFin    := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local lExisteBx   := SE2->E2_SALDO != SE2->E2_VALOR //Existe baixa
	Local cChave      := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
	Local aLinesChg   := 0
	Local nI          := 0
	Local nY          := 0
	Local nLine       := 0
	Local aMdlLanc    := {}
	Local aRecLanc    := {}
	Local cItem       := ""
	Local nUltimoLanc := 0
	Local lValido     := .T.

	If (lExisteBx .And. !lDesdFin) .And. oModelOHF:IsModified()
		aLinesChg := oModelOHF:GetLinesChanged(MODEL_GRID_LINECHANGED_UPDATED)

		For nI := 1 To Len(aLinesChg)
			nLine := aLinesChg[nI]
			cItem := oModelOHF:GetValue("OHF_CITEM", nLine)
			aRecLanc := J246QrLanc(cChave, cItem)

			For nY := 1 To Len(aRecLanc)
				Aadd( aMdlLanc, J246GrLanc(oModelOHF, nLine, aRecLanc[nY][1]) )

				nUltimoLanc := Len(aMdlLanc)
				If Empty(aMdlLanc[nUltimoLanc])
					lValido := .F.
					JurFreeArr(@aMdlLanc)
					Exit
				EndIf
			Next nY

		Next nI
	EndIf

Return aMdlLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J246QrLanc
Retorna os lançamentos de um desdobramento

@param cChave   , Chava da SE1 com separado por '|' acada campo da SE1
@param cItem    , OHF_CITEM do desdobramento para achar o seus lançamentos

@return aRecLanc, Array com os recnos dos lançamentos

@author Bruno Ritter
@since 20/12/18
/*/
//-------------------------------------------------------------------
Static Function J246QrLanc(cChave, cItem)
	Local cQuery   := ""
	Local aRecLanc := {}

	cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("OHB") + " OHB "
	cQuery += " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "' "
	cQuery +=   " AND OHB.OHB_CPAGTO = '" + cChave + "' "
	cQuery +=   " AND OHB.OHB_ITDES = '"  + cItem + "' "
	cQuery +=   " AND OHB.D_E_L_E_T_ = ' ' "

	aRecLanc := JurSQL(cQuery, "R_E_C_N_O_")

Return aRecLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J246GrLanc
Replica os dados do desdobramento para um lançamento

@param oModelOHF  , O model da OHFDETAIL
@param nLine      , Linha para replicar valores
@param nRecLanc   , Recno do lançamento que vai receber os valores

@return oModelLanc, Model da JURA246 - Lançamento com os valores replicados e validado

@obs retorna Nil se o não foi possível replicar os valores

@author Bruno Ritter
@since 20/12/18
/*/
//-------------------------------------------------------------------
Static Function J246GrLanc(oModelOHF, nLine, nRecLanc)
Local oModelLanc := Nil
Local oModelOHB  := Nil
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))

	OHB->(DbGoTo(nRecLanc))
	oModelLanc := FWLoadModel("JURA241")
	oModelLanc:SetOperation(MODEL_OPERATION_UPDATE)
	oModelLanc:Activate()

	oModelOHB := oModelLanc:GetModel("OHBMASTER")

	JurSetVal(oModelOHB, "OHB_NATDES", "") // Limpa a natureza para limpar os campos de CCJuri para não dar problema no when
	JurSetVal(oModelOHB, "OHB_NATDES", oModelOHF:GetValue("OHF_CNATUR", nLine))
	JurSetVal(oModelOHB, "OHB_CESCRD", oModelOHF:GetValue("OHF_CESCR" , nLine))
	JurSetVal(oModelOHB, "OHB_CCUSTD", oModelOHF:GetValue("OHF_CCUSTO", nLine))
	JurSetVal(oModelOHB, "OHB_SIGLAD", oModelOHF:GetValue("OHF_SIGLA2", nLine))
	JurSetVal(oModelOHB, "OHB_CTRATD", oModelOHF:GetValue("OHF_CRATEI", nLine))
	JurSetVal(oModelOHB, "OHB_CCLID" , oModelOHF:GetValue("OHF_CCLIEN", nLine))
	JurSetVal(oModelOHB, "OHB_CLOJD" , oModelOHF:GetValue("OHF_CLOJA" , nLine))
	JurSetVal(oModelOHB, "OHB_CCASOD", oModelOHF:GetValue("OHF_CCASO" , nLine))
	JurSetVal(oModelOHB, "OHB_CTPDPD", oModelOHF:GetValue("OHF_CTPDSP", nLine))
	JurSetVal(oModelOHB, "OHB_QTDDSD", oModelOHF:GetValue("OHF_QTDDSP", nLine))
	JurSetVal(oModelOHB, "OHB_COBRAD", oModelOHF:GetValue("OHF_COBRA" , nLine))
	JurSetVal(oModelOHB, "OHB_DTDESP", oModelOHF:GetValue("OHF_DTDESP", nLine))
	JurSetVal(oModelOHB, "OHB_SIGLA" , oModelOHF:GetValue("OHF_SIGLA" , nLine))
	JurSetVal(oModelOHB, "OHB_VALOR" , oModelOHF:GetValue("OHF_VALOR" , nLine))
	JurSetVal(oModelOHB, "OHB_CHISTP", oModelOHF:GetValue("OHF_CHISTP", nLine))
	JurSetVal(oModelOHB, "OHB_HISTOR", oModelOHF:GetValue("OHF_HISTOR", nLine))

	JurSetVal(oModelOHB, Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE"), oModelOHF:GetValue("OHF_CPROJE", nLine))
	JurSetVal(oModelOHB, Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ"), oModelOHF:GetValue("OHF_CITPRJ", nLine))

	If oModelLanc:HasErrorMessage()
		aErro := oModelLanc:GetErrorMessage()

		JurMsgErro(STR0029,, Alltrim(aErro[7])) // "Erro ao atualizar lançamento: "
		oModelLanc:Destroy()
		oModelLanc := Nil

	ElseIf !oModelLanc:VldData()
		aErro := oModelLanc:GetErrorMessage()

		JurMsgErro(STR0029,, Alltrim(aErro[7])) // "Erro ao atualizar lançamento: "
		oModelLanc:Destroy()
		oModelLanc := Nil
	EndIf

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J246VldPro()
Rotina de dicionário para validar o projeto, considerando
se a situação esta dirente de '2'.

@param cProjeto codigo do projeto a ser validado

@author Luciano Pereira dos Santos
@since   14/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J246VldPro(cProjeto)
	Local lRet    := .T.
	Local lValBlq := .T.

	lRet := JurVldProj(cProjeto, "2", lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J246DesFin
Processamento para títulos que foram desdobrados (parcelado) pelo financeiro

@param oModel    , modelo principal da JURA246
@param aModelDesp, Array de modelos vinculados ao desdobramento
@param aModelLanc, Array de modelos vinculados ao desdobramento
@param aModelNZQ , Array de modelos vinculados ao desdobramento

@return Nil

@author  Bruno Ritter
@since   07/11/2019
/*/
//-------------------------------------------------------------------
Static Function J246DesFin(oModel, aModelDesp, aModelLanc, aModelNZQ)
	Local oModelOHF  := oModel:GetModel("OHFDETAIL")
	Local nTotalOHF  := oModelOHF:Length()
	Local cNaoCopiar := "OHF_FILIAL|OHF_IDDOC|OHF_CDESP|OHF_NZQCOD|OHF_CODLD"
	Local lDesdOld   := SuperGetMV("MV_NRASDSD", .F.) // Permite que o desdobramento de títulos seja realizado no processo antigo, sem rastreamento e excluindo o título originador.
	Local lDesdFin   := Iif(lDesdOld, SE2->E2_DESDOBR == "S" .And. SE2->(Deleted()), SE2->E2_STATUS == "D") // Se o título está sendo desdobrado pelo financeiro
	Local aAreaSE2   := {}
	Local cTmpSE2    := ""
	Local nRecAtual  := SE2->(Recno())
	Local oModelParc := Nil
	Local oMdlPrcOHF := Nil
	Local aFieldsOHF := {}
	Local nCpo       := 0
	Local cCampo     := ""
	Local xValor     := Nil
	Local nLine      := 0
	Local pPerc      := Nil // Percentual em ponto flutuante entre a parcela e o título original
	Local pVlDesd    := Nil
	Local pVlParc    := Nil
	Local pVlTitOrig := Nil // Valor em ponto flutuante do título digitado pelo usuário
	Local pVlTitParc := Nil // Valor em ponto flutuante da parcela
	Local nDecValor  := 0   // Casas decimais do campo OHF_VALOR
	Local nDecimal   := 18  // Uso de casas decimais no ponto flutuante
	Local aDesdPerc  := {}  // Percentual que o desdobramento vale no título
	Local nDesdOri   := 0

	If lDesdFin .And. oModelOHF:Length(.T.) > 0
		JurFreeArr(@aModelDesp)
		JurFreeArr(@aModelLanc)
		JurFreeArr(@aModelNZQ)

		aAreaSE2   := SE2->(GetArea())
		nDecValor  := TamSX3("OHF_VALOR")[2]
		pVlTitOrig := DEC_CREATE(cValToChar(SE2->E2_VALOR), 64, nDecimal)

		For nDesdOri := 1 To nTotalOHF
			pVlDesd := DEC_CREATE(cValToChar(oModelOHF:GetValue("OHF_VALOR", nDesdOri)), 64, nDecimal)
			pPerc   := DEC_DIV(pVlDesd, pVlTitOrig)
			aAdd(aDesdPerc, pPerc)
		Next nDesdOri

		aFieldsOHF := oModelOHF:GetStruct():GetFields()

		cTmpSE2 := J246ParcFi() // Retrona área com o Recno e Valor de cada parcela da SE2 posicionada.

		While (cTmpSE2)->(!Eof())
			SE2->(DbGoTo((cTmpSE2)->RECNO))
			oModelParc := FwLoadModel("JURA246") // Recriao modelo, pois ele é montado conforme a SE2 posicionada, então não podemos aproveitar o modelo criado anteriormente
			oModelParc:SetOperation(MODEL_OPERATION_UPDATE)

			If oModelParc:CanActivate() .And. oModelParc:Activate()
				oMdlPrcOHF := oModelParc:GetModel("OHFDETAIL")
				pVlTitParc := DEC_CREATE(cValToChar(SE2->E2_VALOR), 64, nDecimal)

				For nLine := 1 To nTotalOHF
					If !oModelOHF:IsDeleted(nLine)
						pPerc := aDesdPerc[nLine]

						For nCpo := 1 To Len(aFieldsOHF)
							If !aFieldsOHF[nCpo][14] // Campo NÃO é virtual
								cCampo := AllTrim(aFieldsOHF[nCpo][3])

								If oMdlPrcOHF:HasField(cCampo) .And. !(cCampo $ cNaoCopiar)
									If cCampo == "OHF_VALOR"
										pVlParc := DEC_MUL(pVlTitParc, pPerc)
										xValor  := Val(cValToChar(DEC_RESCALE(pVlParc, nDecValor, 0)))
									Else
										xValor := oModelOHF:GetValue(cCampo, nLine)
									EndIf

									oMdlPrcOHF:LoadValue(cCampo, xValor) // Já foi feita as validações, poir isso o loadvalue
								EndIf
							EndIf
						Next nCpo
					EndIf

					oMdlPrcOHF:AddLine()
				Next nLine

				oMdlPrcOHF:DeleteLine()
				// Valida sem pegar o retorno, pois já foi validado anteriormente,
				// mas é necessário passar pelas funções de valid para carregar os atributos do objeto FWModelEvent antes de comitar o modelo
				oModelParc:VldData()
				oModelParc:CommitData()
				oModelParc:DeActivate()
				oModelParc:Destroy() // Destroy pois o modelo é montado conforme a SE2 posicionada, então não podemos aproveitar o modelo criado
			EndIf

			(cTmpSE2)->(DbSkip())
		EndDo

		(cTmpSE2)->(dbCloseArea())

		SE2->(DbGoTo(nRecAtual))
		oModelOHF:DelAllLine()

		RestArea(aAreaSE2)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J246ParcFi
Gera uma area temporária com os dados das parcelas geradas pelo
desdobramento do financeiro

@return cTmpSE2, Área com o Recno e Valor de cada parcela da SE2 posicionada.

@author  Bruno Ritter / Jorge Martins
@since   14/11/2019
/*/
//-------------------------------------------------------------------
Static Function J246ParcFi()
	Local cTmpSE2  := GetNextAlias()

	BeginSql Alias cTmpSE2
		SELECT
			SE2.R_E_C_N_O_ RECNO,
			FI8.FI8_VALOR
		FROM %Table:SE2% SE2
		INNER JOIN %Table:FI8% FI8
				ON FI8.FI8_FILIAL = %xFilial:FI8%
			AND FI8.FI8_PRFORI = %Exp:SE2->E2_PREFIXO%
			AND FI8.FI8_NUMORI = %Exp:SE2->E2_NUM%
			AND FI8.FI8_PARORI = %Exp:SE2->E2_PARCELA%
			AND FI8.FI8_TIPORI = %Exp:SE2->E2_TIPO%
			AND FI8.FI8_FORORI = %Exp:SE2->E2_FORNECE%
			AND FI8.FI8_LOJORI = %Exp:SE2->E2_LOJA%
			AND FI8.%NotDel%
		WHERE SE2.E2_FILIAL    = FI8.FI8_FILDES
			AND SE2.E2_PREFIXO = FI8.FI8_PRFDES
			AND SE2.E2_NUM     = FI8.FI8_NUMDES
			AND SE2.E2_PARCELA = FI8.FI8_PARDES
			AND SE2.E2_TIPO    = FI8.FI8_TIPDES
			AND SE2.E2_FORNECE = FI8.FI8_FORDES
			AND SE2.E2_LOJA    = FI8.FI8_LOJDES
			AND SE2.%NotDel%
		ORDER BY SE2.E2_PARCELA
	EndSql

Return cTmpSE2

//-------------------------------------------------------------------
/*/{Protheus.doc} J246EstCtb
Função que chama o estorno da contabilização do desdobramento/desd. pós pag.
quando já contabilizado e houve alteração ou exclusão.

@Param oMdlDes , Objeto, Modelo de dados de desdobramentos/desd. pós pag.
@Param  cTab   , caractere, Tabela do desdobramento "OHF" ou desdobramento pós pag. "OHG"
@Param  cCodLP , caractere, Código do lançamento padrão de estorno "948" ou "949"

@author Jonatas Martins
@since  14/10/2019
@Obs    Nesse ponto está posicionado na linha da OHF que sofreu modificação
/*/
//-------------------------------------------------------------------
Function J246EstCtb(oMdlDes, cTab, cCodLP)
Local nRecLine  := 0
Local lDeleted  := .F.
Local lModified := .F.
Local lReversal := .F.
Local cCpoFlag  := ""
Local cFilBkp   := ""

Default oMdlDes := Nil
Default cTab    := ""
Default cCodLP  := ""

	If ValType(oMdlDes) == "O" .And. !Empty(cTab) .And. !Empty(cCodLP)
		cCpoFlag := J265LpFlag(cCodLP) // Busca campo de flag da contabilização
		
		If !Empty(oMdlDes:GetValue(cCpoFlag)) // Verifica se o registro está contabilizado "947"
			cFilBkp   := cFilAnt 
			cFilAnt   := SE2->E2_FILIAL // Altera a filial logada para filial do título para contabilizar o desdobramento na filial correta
			lDeleted  := oMdlDes:IsDeleted()
			lModified := lDeleted .Or. J246IsUpdLin(oMdlDes, cTab)
			If lModified
				nRecLine  := oMdlDes:GetDataID()
				lReversal := JURA265B(cCodLP, nRecLine) // Estorno da contabilização de desdobramento/desd. pós pagamento
				If lReversal .And. !lDeleted
					If cCodLP == "948"
						AAdd(_aRecDesCtb, nRecLine) // Array estático utilizado no método INTTS para nova contabilização
					Else // Desdobramento Pós pagamento
						J247SetEst(nRecLine) // Alimenta array _aRecPosCtb estático do fonte JURA247
					EndIf
				EndIf
			EndIf
			cFilAnt := cFilBkp
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J246IsUpdLin
Avalia a alteração de dados do desdobramentos

@param  oMdlDes  , Modelo de dados de desdobramentos/desd. pós pagamento
@param  cTab     , Tabela do desdobramento "OHF" ou desdobramento pós pag. "OHG"
@param  aFields  , Array com os campos a serem verificados

@return lModified, Indica se o desdobramento foi modificado

@author Luciano Pereira dos Santos
@since  14/10/2019
@Obs    Não utilizado o método IsFieldUpdated pois há situações
        que o campo não foi alterado e o método retorna .T.
/*/
//-------------------------------------------------------------------
Static Function J246IsUpdLin(oMdlDes, cTab, aFields)
Local cChave    := SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" +SE2->E2_LOJA
Local cIdDoc    := FINGRVFK7("SE2", cChave)
Local aValues   := {}
Local cValue    := ""
Local nFld      := 0
Local lModified := .F.

Default aFields   := {cTab + "_CNATUR", cTab + "_VALOR", cTab + "_CCLIEN", cTab + "_CLOJA", cTab + "_CTPDSP"}

	AEval(aFields, {|cField| xValue := oMdlDes:GetValue(cField), AAdd(aValues, {xValue, ValType(xValue)})})

	cQuery :=  " SELECT " + cTab + "_IDDOC"
	cQuery +=    " FROM " + RetSqlName(cTab)
	cQuery +=   " WHERE " + cTab + "_FILIAL = '" + xFilial(cTab) + "'"
	cQuery +=     " AND " + cTab + "_IDDOC = '" + cIdDoc + "' "
	For nFld := 1 To Len(aFields)
		cValue := J246ConvVal(aValues[nFld][1], aValues[nFld][2])
		cQuery += " AND " + aFields[nFld] + " = " + cValue
	Next nFld
	cQuery +=     " AND D_E_L_E_T_ = ' '"

	aRetSql := JurSQL(cQuery, "*")

	// Avalia se o registro permanece inalterado no banco de dados
	lModified := Empty(aRetSql)

Return (lModified)

//-------------------------------------------------------------------
/*/{Protheus.doc} J246ConvVal
Função para converter dados como texto para uso em query

@Param  xValue, indefinido, Valor a ser convertido
@Param  cType , caractere , Tipo de dado a ser convertido

@Return cValue, caractere, Valor convertido como texto

@author Jonatas Martins
@since  14/10/2019
@Obs    Não utilizado o método IsFieldUpdated pois há situações
        que o campo não foi alterado e o método retorna .T.
/*/
//-------------------------------------------------------------------
Function J246ConvVal(xValue, cType)
	Local cValue := ""

	Do Case
		Case cType == "N"
			cValue := AllTrim(Str(xValue))
		
		Case cType == "D"
			cValue := "'" + DtoS(xValue) + "'"
		
		OtherWise // Caractere
			cValue := "'" + xValue + "'"
	End Case

Return (cValue)

//-------------------------------------------------------------------
/*/{Protheus.doc} J246EFD
Função para gravação dos dados de desdobramentos na EFD

@param  lNewRecord, Indica se é um novo registro no Grid
@param  lDelOHF   , Indica se é exclusão do registro (Rotina J246DelOHF)
@param  oMdlOHF   , Linha do Modelo de Dados OHF

@author fabiana.silva
@since  06/01/2022
/*/
//-------------------------------------------------------------------
Static Function J246EFD(lNewRecord, lDelOHF, oMdlOHF)
Local lDelete   := .F.
Local lGravaCF8 := .F.
Local cCodCF8   := ""
Local cNatureza := "" // Natureza de Origem
Local aFields   := {"OHF_CITEM", "OHF_CNATUR", "OHF_VALOR", "OHF_CCLIEN", "OHF_CLOJA", "OHF_DTINCL", "OHF_CODCF8"}
Local aArea     := GetArea()
Local aAreaCF8  := {}
Local aDadosNat := {}
Local lModified := .F.

	If !lNewRecord
		lDelete   := lDelOHF .Or. oMdlOHF:IsDeleted()
		lModified := lDelete .Or. J246IsUpdLin(oMdlOHF, "OHF", aFields)
		If !lModified
			OHF->(DbGoto(oMdlOHF:GetDataID()))
			lModified := !(oMdlOHF:GetValue("OHF_HISTOR") == OHF->OHF_HISTOR)
		EndIf

		If lModified .And. !Empty(cCodCF8 := oMdlOHF:GetValue("OHF_CODCF8"))
			//Deleta o registro da CF8
			aAreaCF8 := CF8->(GetArea())
			CF8->(DbSetOrder(1)) // CF8_FILIAL + CF8_CODIGO

			If CF8->(DbSeek(xFilial("CF8") + cCodCF8))
				RecLock("CF8", .F.)
				CF8->(DbDelete())
				CF8->(MsUnlock())
			EndIf	
			RestArea(aAreaCF8)
		EndIf
	EndIf

	cNatureza := oMdlOHF:GetValue("OHF_CNATUR") // Natureza de Origem
	If !lDelete .And. !Empty(cNatureza) // Inclusão ou Alteração
		aDadosNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, {"ED_APURCOF", "ED_APURPIS"})

		If (Len(aDadosNat) >= 2 .And. (!Empty(aDadosNat[1]) .Or. !Empty(aDadosNat[2]))) // Não possui apuração de PIS ou COFINS
			lGravaCF8 := Execblock("J241EFD", .F., .F., {cNatureza})
		EndIf
		
		If ValType(lGravaCF8) == "L" .And. lGravaCF8
			J246GrvCF8(cNatureza, oMdlOHF)
		EndIf
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J246GrvCF8
Função para gravação dos dados de desdobramentos na EFD

@param  cNatureza, Código da Natureza
@param  oMdlOHF  , Linha do Modelo de Dados OHF

@author fabiana.silva
@since  06/01/2022
/*/
//-------------------------------------------------------------------
Static Function J246GrvCF8(cNatureza, oMdlOHF)
Local aAreaSED   := SED->(GetArea())
Local cCodigo    := ""
Local cIndOri    := ""
Local cHistor    := ""
Local dDataLanc  := Nil
Local nValorNac  := 0
Local nValBase   := 0
Local nValBasCof := 0
Local nValCof    := 0
Local nValBasPIS := 0
Local nValPIS    := 0
Local nValor     := 0

	If SED->(DbSeek(xFilial("SED") + cNatureza))
		cCodigo    := GetSXENum("CF8", "CF8_CODIGO")
		cIndOri    := Criavar("CF8_INDORI", .T.)
		cIndOri    := IIF(Empty(cIndOri), "0", cIndOri)
		nValor     := Abs(oMdlOHF:GetValue("OHF_VALOR"))
		dDataLanc  := oMdlOHF:GetValue("OHF_DTINCL")
		//Realiza a conversão do valor do Lançamento em moeda nacional
		nValorNac  := J246ConvNC(nValor, dDataLanc)
		nValBase   := nValorNac
		cHistor    := SubStr(AllTrim(StrTran(oMdlOHF:GetValue("OHF_HISTOR"), CRLF, " ")), 1, TamSx3("CF8_DESCPR")[1])

		// Calcula redução da base do PIS e COFINS
		If !Empty(SED->ED_REDPIS) .And. Empty(SED->ED_PERCPIS)
			nValBase *= SED->ED_REDPIS / 100
		ElseIf !Empty(SED->ED_REDCOF) .And. Empty(SED->ED_PERCCOF)
			nValBase *= SED->ED_REDCOF / 100
		EndIf
		// Base COFINS
		If !(SED->ED_CSTCOF $ "07_08_09_49")
			nValBasCof := nValBase
			// Valor COFINS
			If !Empty(SED->ED_APURCOF)
				nValCof := nValBasCof * SED->ED_PCAPCOF / 100
			EndIf
		EndIf
		// Base e valor PIS
		If !(SED->ED_CSTPIS $ "07_08_09_49")
			nValBasPIS := nValBase
			nValPIS    := nValBasPIS * SED->ED_PCAPPIS / 100
		EndIf

		RecLock("CF8", .T.)
		CF8->CF8_FILIAL := xFilial("CF8")
		CF8->CF8_CODIGO := cCodigo
		CF8->CF8_TPREG  := IIf(SED->ED_TPREG == "1", "2", IIf(SED->ED_TPREG == "2", "1", "")) // SED - 1=Nao Cumulativo;2=Cumulativo / CF8 - 1=Cumulativo;2=Não Cumulativo
		CF8->CF8_INDOPE := "0"
		CF8->CF8_DTOPER := dDataLanc
		CF8->CF8_VLOPER := nValorNac
		CF8->CF8_CSTCOF := SED->ED_CSTCOF
		CF8->CF8_ALQCOF := SED->ED_PCAPCOF
		CF8->CF8_BASCOF := nValBasCof
		CF8->CF8_VALCOF := nValCof
		CF8->CF8_CSTPIS := SED->ED_CSTPIS
		CF8->CF8_ALQPIS := SED->ED_PCAPPIS
		CF8->CF8_BASPIS := nValBasPIS
		CF8->CF8_VALPIS := nValPIS
		CF8->CF8_INDORI := cIndOri
		CF8->CF8_CODCTA := SED->ED_CONTA
		CF8->CF8_CLIFOR := SE2->E2_FORNECE
		CF8->CF8_LOJA   := SE2->E2_LOJA
		CF8->CF8_DESCPR := cHistor
		CF8->CF8_CODBCC := SED->ED_CLASFIS
		CF8->CF8_DOC    := SE2->E2_NUM
		CF8->(MsUnLock())

		If __lSX8
			ConFirmSX8()
			oMdlOHF:SetValue("OHF_CODCF8", cCodigo)
		EndIf
	EndIf
	RestArea(aAreaSED)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J246ConvNC
Realiza a conversão do Lançamento em Moeda Nacional na Data do Lançamento
e retorna os dados do título (Fornecedor, Loja, Documento)

@param  nValorL    , Valor do Lançamento na Moeda do Título
@param  dDataLanc  , Data do Lançamento

@return nVlMoedaNac, Valor em Moeda Nacional convertido na Data do lançamento

@author fabiana.silva
@since  06/01/2022
/*/
//-------------------------------------------------------------------
Static Function J246ConvNC(nValorL, dDataLanc)
Local nTaxa       := 0
Local nVlMoedaNac := nValorL
Local cMoedaL     := PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1], '0')
Local cMoedaNac   := SuperGetMv('MV_JMOENAC',, '01' ) // Moeda Nacional

	If cMoedaL <> cMoedaNac
		nTaxa       := J201FCotDia(cMoedaL, cMoedaNac, dDataLanc, xFilial("CTP"))[1]
		nVlMoedaNac := IIF(nTaxa > 0, Round(nTaxa * nValorL, TamSX3('CF8_VLOPER')[2]), nValorL)
	EndIf

Return nVlMoedaNac

//-------------------------------------------------------------------
/*/{Protheus.doc} JA246Tracker()
Executa a função de Tracker Contábil CTBC662().

@author Reginaldo Borges
@since  01/04/2022
/*/
//-------------------------------------------------------------------
Static Function JA246Tracker(oModel)
Local aAreas    := {OHF->(GetArea()), GetArea()}
Local oModelOHF := oModel:GetModel("OHFDETAIL")

	CTBC662("OHF", oModelOHF:GetDataId())
	AEval(aAreas, {|aArea| RestArea(aArea)})

Return .T.

