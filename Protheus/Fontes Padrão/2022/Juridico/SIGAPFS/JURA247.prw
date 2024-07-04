#INCLUDE "JURA247.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _aRecPosCtb := {} // Variavel para controlar lan�amentos estornados por altera��es

#DEFINE ICO_TEM_ANEXO "F5_VERD_OCEAN.BMP"
#DEFINE ICO_NAO_ANEXO "F5_CINZ_OCEAN.BMP"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA247
Itens de desdobramento p�s pagamento

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA247(nOperacao)
Default nOperacao := MODEL_OPERATION_UPDATE

FWExecView( STR0001, 'JURA247', nOperacao, , { || .T. }, , , ) // "Itens de desdobramento p�s pagamento

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Itens de desdobramento p�s pagamento

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSE2 := FWFormStruct( 1, "SE2" )
Local oEvent     := JA247Event():New()
Local oStructOHG := FWFormStruct( 1, "OHG" )
Local oStructOHF := FWFormStruct( 1, "OHF" )
Local cChave     := '"'+SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA+'"'
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se ser� utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = N�o)
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se ser� utilizado Controle Or�ament�rio (.T. = Sim; .F. = N�o)

oStructSE2 := J247AddCpM(oStructSE2)

// Adiciona o campo de anexo no Model
oStructOHG := J247CpoAnx(oStructOHG, "OHG", "M", {||JA247Anexo()})
oStructOHF := J247CpoAnx(oStructOHF, "OHF", "M", {||JA247Anexo()})

oModel:= MPFormModel():New( "JURA247", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SE2MASTER", NIL         /*cOwner*/, oStructSE2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid(� "OHGDETAIL",�"SE2MASTER"�/*cOwner*/,�oStructOHG,�{|oGrid, nLine, cAction, cField, xNewValue, xOldValue| J247PreOHG(oModel,�nLine, cAction, cField, xNewValue, xOldValue) }�/*Pre-Validacao*/,�{|| J247PosOHG(oModel)} /*Pos-Validacao*/,�/*bPre*/,�/*bPost*/�)
oModel:AddGrid(� "OHFDETAIL",�"SE2MASTER"�/*cOwner*/,�oStructOHF,�/*Pre-Validacao*/,�/*Pos-Validacao*/,�/*bPre*/,�/*bPost*/�)

oModel:GetModel( "SE2MASTER" ):SetDescription( STR0002 ) // "T�tulo"
oModel:GetModel( "OHGDETAIL" ):SetDescription( STR0001 ) // "Itens de desdobramento p�s pagamento"
oModel:GetModel( "OHFDETAIL" ):SetDescription( STR0028 ) // "Desdobramentos"

oModel:SetRelation("OHGDETAIL", {{"OHG_FILIAL", "E2_FILIAL" }, {"OHG_IDDOC", "FINGRVFK7('SE2', " + cChave + ")"}}, OHG->(IndexKey(1)))
oModel:SetRelation("OHFDETAIL", {{"OHF_FILIAL", "E2_FILIAL" }, {"OHF_IDDOC", "FINGRVFK7('SE2', " + cChave + ")"}}, OHF->(IndexKey(1)))

J235MAnexo(@oModel, "OHGDETAIL", "OHG", "OHG->(OHG_IDDOC+OHG_CITEM)") // Grid de Anexos

oStructSE2:SetProperty("E2_PREFIXO", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_NUM"    , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_PARCELA", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_TIPO"   , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_NATUREZ", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_VENCTO" , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2_VENCREA", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__CMOEDA", MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VALOR" , MODEL_FIELD_WHEN, {||.F.})
oStructSE2:SetProperty("E2__VLRLIQ", MODEL_FIELD_WHEN, {||.F.})
If !lUtProj .And. !lContOrc .And. OHG->(ColumnPos("OHG_CPROJE")) > 0
	oStructOHG:SetProperty("OHG_CPROJE", MODEL_FIELD_WHEN, {||.F.})
	oStructOHG:SetProperty("OHG_CITPRJ", MODEL_FIELD_WHEN, {||.F.})
EndIf

oModel:GetModel( "OHFDETAIL" ):SetOnlyQuery( .T. )
oModel:GetModel( "OHFDETAIL" ):SetNoDeleteLine( .T. )
oModel:GetModel( "OHFDETAIL" ):SetNoUpdateLine( .T. )
oModel:GetModel( "OHFDETAIL" ):SetNoInsertLine( .T. )
oModel:GetModel( "OHFDETAIL" ):SetOptional( .T. )

oModel:GetModel( "OHGDETAIL" ):SetUniqueLine( {"OHG_CITEM"} )
oModel:GetModel( "OHGDETAIL" ):SetOptional( .T. )
oModel:GetModel( "OHGDETAIL" ):SetDelAllLine( .T. )

oModel:InstallEvent("JA247Event", /*cOwner*/, oEvent)

oModel:SetActivate( {|oModel|�JIniValDes(oModel,�"OHG")} ) // Preenche os valores dos campos de total e saldo do desdobramento ao abrir a tela
oModel:SetVldActivate( { |oModel| J247VldACT( oModel ) } )



/*Bloqueio de campos desdobramento*/

oStructOHG:SetProperty("OHG_CESCR",  MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHG_CNATUR"), "OHG_CNATUR", "1") } )
oStructOHG:SetProperty("OHG_CCUSTO", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHG_CNATUR"), "OHG_CNATUR", "2") } )
oStructOHG:SetProperty("OHG_SIGLA2", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHG_CNATUR"), "OHG_CNATUR", "3") } )
oStructOHG:SetProperty("OHG_CRATEI", MODEL_FIELD_WHEN, {|oMdl| JurValidNat(oMdl:GetValue("OHG_CNATUR"), "OHG_CNATUR", "4") } )
/***********************************************************************/
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Itens de desdobramento p�s pagamento

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local cAddCpo    := "E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_NATUREZ|E2__DNATUR|E2_VENCTO|E2_VENCREA|E2__CMOEDA|E2__DMOEDA|E2__VALOR|E2__VLRLIQ|E2__TOTDES|E2__SLDDES"
Local aOrdemCpo  := STRTOKARR(cAddCpo, "|")
Local oModel     := FWLoadModel( "JURA247" )
Local oStructSE2 := FWFormStruct( 2, "SE2", {|cCampo| J247SE2Cpo(cCampo,cAddCpo)})
Local oStructOHG := FWFormStruct( 2, "OHG" )
Local oStructOHF := FWFormStruct( 2, "OHF" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N�o)
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se ser� utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = N�o)
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se ser� utilizado Controle Or�ament�rio (.T. = Sim; .F. = N�o)

oStructSE2 := J247AddCpV(oStructSE2)
oStructSE2 := J247SE2Ord(oStructSE2, aOrdemCpo)

// Adiciona o campo de anexo no View
oStructOHG := J247CpoAnx(oStructOHG, "OHG", "V")
oStructOHF := J247CpoAnx(oStructOHF, "OHF", "V")

oStructOHG:RemoveField("OHG_IDDOC")
oStructOHG:RemoveField("OHG_CPART")
oStructOHG:RemoveField("OHG_CPART2")
oStructOHG:RemoveField("OHG_DTINCL")
oStructOHF:RemoveField("OHF_IDDOC")
oStructOHF:RemoveField("OHF_CPART")
oStructOHF:RemoveField("OHF_CPART2")
oStructOHF:RemoveField("OHF_DTINCL")

If (cLojaAuto == "1") // Loja Autom�tica
	oStructOHG:RemoveField("OHG_CLOJA")
	oStructOHF:RemoveField("OHF_CLOJA")
EndIf
If !lUtProj .And. !lContOrc .And. OHG->(ColumnPos("OHG_CPROJE")) > 0
	oStructOHF:RemoveField("OHF_CPROJE")
	oStructOHF:RemoveField("OHF_DPROJE")
	oStructOHF:RemoveField("OHF_CITPRJ")
	oStructOHF:RemoveField("OHF_DITPRJ")
	oStructOHG:RemoveField("OHG_CPROJE")
	oStructOHG:RemoveField("OHG_DPROJE")
	oStructOHG:RemoveField("OHG_CITPRJ")
	oStructOHG:RemoveField("OHG_DITPRJ")
EndIf

If OHF->(FieldPos("OHF_CODLD")) > 0
	oStructOHF:RemoveField('OHF_CODLD')
	oStructOHG:RemoveField('OHG_CODLD')
EndIf

If OHG->(ColumnPos("OHG_DTCONT")) > 0 // Prote��o
	oStructOHG:RemoveField("OHG_DTCONT")
	oStructOHF:RemoveField("OHF_DTCONT")
	If OHF->(ColumnPos("OHF_DTCONI")) > 0 // Prote��o
		oStructOHF:RemoveField("OHF_DTCONI")
	EndIf
EndIf

If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integra��o Controle Or�ament�rio SIGAPFS x SIGAFIN
	oStructOHG:SetProperty("OHG_VALOR" , MVC_VIEW_CANCHANGE, .F.)
	oStructOHG:SetProperty("OHG_CESCR" , MVC_VIEW_CANCHANGE, .F.)
	oStructOHG:SetProperty("OHG_CCUSTO", MVC_VIEW_CANCHANGE, .F.)
	oStructOHG:SetProperty("OHG_SIGLA2", MVC_VIEW_CANCHANGE, .F.)
	oStructOHG:SetProperty("OHG_CRATEI", MVC_VIEW_CANCHANGE, .F.)
	If oStructOHG:HasField("OHG_CPROJE")
		oStructOHG:SetProperty("OHG_CPROJE", MVC_VIEW_CANCHANGE, .F.)
		oStructOHG:SetProperty("OHG_CITPRJ", MVC_VIEW_CANCHANGE, .F.)
	EndIf
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("JURA247_SE2", oStructSE2, "SE2MASTER")
oView:AddGrid("JURA247_OHG" , oStructOHG, "OHGDETAIL")
oView:AddGrid("JURA247_OHF" , oStructOHF, "OHFDETAIL")

oView:SetViewProperty( 'JURA247_OHG', "ENABLEDGRIDDETAIL", { 50 } )

oView:CreateHorizontalBox("FORMFIELD", 30)
oView:SetOwnerView("JURA247_SE2", "FORMFIELD")

oView:CreateHorizontalBox("FORMGRID",  70)

oView:CreateFolder('FOLDER_01',"FORMGRID")

oView:AddSheet( "FOLDER_01", "ABA_OHG", STR0027  ) //"Desdobramentos p�s pagamento"
oView:AddSheet( "FOLDER_01", "ABA_OHF", STR0028  ) //"Desdobramentos"

oView:CreateHorizontalBox("FORMFOLDER_OHG",100,,,"FOLDER_01", "ABA_OHG")
oView:CreateHorizontalBox("FORMFOLDER_OHF",100,,,"FOLDER_01", "ABA_OHF")

oView:SetOwnerView("JURA247_OHG", "FORMFOLDER_OHG")
oView:SetOwnerView("JURA247_OHF", "FORMFOLDER_OHF")

oView:SetNoInsertLine( "JURA247_OHF" )
oView:SetNoDeleteLine( "JURA247_OHF" )
oView:SetNoUpdateLine( "JURA247_OHF" )

oView:EnableControlBar( .T. )
oView:AddIncrementField( 'OHGDETAIL', 'OHG_CITEM' )

If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integra��o Controle Or�ament�rio SIGAPFS x SIGAFIN
	oView:SetNoInsertLine("OHGDETAIL")
	oView:SetNoDeleteLine("OHGDETAIL")
EndIf

oView:SetViewProperty("JURA247_OHG", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| Iif(Alltrim(cFieldName) == "OHG__ANEXO", JA247Anexo(), .T.) }}) 
oView:SetViewProperty("JURA247_OHF", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| Iif(Alltrim(cFieldName) == "OHF__ANEXO", JA247Anexo(), .T.) }}) 

If !IsBlind()
	oView:AddUserButton( STR0037, "CLIPS" , { | oView | JA247Anexo() } ) // "Anexos"
	oView:AddUserButton( STR0038, "BUDGET", { | oView | JA247Legen() } ) // "Legenda"
	oView:AddUserButton( STR0056, "BUDGET", { | oView | JA247Tracker(oView) } ) // "Tracker Cont�bil"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J247SE2Cpo(cCampo)
Fun��o para selecionar os campos do Model da tabela SE2

@param cCampo campo da estrutura.

@Return .T. para campos que ope

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247SE2Cpo(cCampo,cAddCpo)
Local lRet     := .F.
Local cNomeCpo := AllTrim(cCampo)

If cNomeCpo $ cAddCpo
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247AddCpM(oStruct)
Inclui campos no model atrav�s da fun��o AddField

@Param oStruct Estrutura a ser adicionadas os campos

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247AddCpM(oStruct)
	Local aNat      := TamSx3("ED_DESCRIC")
	Local aCMoe     := TamSx3("CTO_MOEDA")
	Local aDMoe     := TamSx3("CTO_SIMB")
	Local aVal      := TamSx3("E2_VALOR")
	Local cTitValor := GetSx3Cache("E2_VALOR", "X3_TITULO")
	Local cDesValor := GetSx3Cache("E2_VALOR", "X3_DESCRIC")

	                //Titulo  , Descricao , Campo       , Tipo do campo , Tamanho  , Decimal ,  bValid,  bWhen   , Lista , lObrigat,  bInicializador              , � chave, � edit�vel , � virtual
	oStruct:AddField(cTitValor, cDesValor , 'E2__VALOR' , aVal[3]       , aVal[1]  , aVal[2] ,        ,  {||.F.} ,       ,         , {|| J247InitP('E2__VALOR' )} ,        ,            , .T.       ) // 'Valor T�tulo'
	oStruct:AddField(STR0005  , STR0006   , 'E2__VLRLIQ', aVal[3]       , aVal[1]  , aVal[2] ,        ,  {||.F.} ,       ,         , {|| J247InitP('E2__VLRLIQ')} ,        ,            , .T.       ) // 'Vlr. L�quido' - 'Valor l�quido'
	oStruct:AddField(STR0007  , STR0008   , 'E2__DNATUR', aNat[3]       , aNat[1]  , aNat[2] ,        ,  {||.F.} ,       ,         , {|| J247InitP('E2__DNATUR')} ,        ,            , .T.       ) // 'Desc. Natureza' - 'Descri��o Natureza'
	oStruct:AddField(STR0009  , STR0009   , 'E2__TOTDES', aVal[3]       , aVal[1]  , aVal[2] ,        ,  {||.T.} ,       ,         , {|| J247InitP('E2__TOTDES')} ,        ,            , .T.       ) // 'Total desdobramento'
	oStruct:AddField(STR0010  , STR0010   , 'E2__SLDDES', aVal[3]       , aVal[1]  , aVal[2] ,        ,  {||.T.} ,       ,         , {|| J247InitP('E2__SLDDES')} ,        ,            , .T.       ) // 'Saldo desdobramento'
	oStruct:AddField(STR0011  , STR0012   , 'E2__CMOEDA', aCMoe[3]      , aCMoe[1] , aCMoe[2],        ,  {||.F.} ,       ,         , {|| J247InitP('E2__CMOEDA')} ,        ,            , .T.       ) // 'C�d. Moeda' - 'C�digo da Moeda'
	oStruct:AddField(STR0013  , STR0014   , 'E2__DMOEDA', aDMoe[3]      , aDMoe[1] , aDMoe[2],        ,  {||.F.} ,       ,         , {|| J247InitP('E2__DMOEDA')} ,        ,            , .T.       ) // 'S�mb. Moeda' - 'S�mbolo da Moeda'

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J247AddCpV(oStruct)
Inclui campos no view atrav�s da fun��o AddField

@Param oStruct Estrutura a ser adicionadas os campos

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247AddCpV(oStruct)
Local cPict      := Alltrim(X3Picture('E2_VALOR'))
Local cTitValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_TITULO' )
Local cDesValor  := GetSx3Cache( 'E2_VALOR'  , 'X3_DESCRIC')
Local aLgpd := {}

                 //Campo     , Ordem , Titulo    , Descricao , Help , Tipo do campo, Picture, PictVar,   F3,  When, Folder, Group, Lista Combo, Tam Max Combo, Inic. Browse, Virtual
oStruct:AddField('E2__VLRLIQ', 'ZZ'  , STR0005   , STR0006   , {}   , 'GET'        ,cPict   ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Vlr. L�quido' - 'Valor l�quido'
oStruct:AddField('E2__DNATUR', 'ZZ'  , STR0007   , STR0008   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'Desc. Natureza' - 'Descri��o Natureza'
oStruct:AddField('E2__TOTDES', 'ZZ'  , STR0009   , STR0009   , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Total desdobramento'
oStruct:AddField('E2__SLDDES', 'ZZ'  , STR0010   , STR0010   , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Saldo desdobramento'
oStruct:AddField('E2__CMOEDA', 'ZZ'  , STR0011   , STR0012   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'C�d. Moeda' - 'C�digo da Moeda'
oStruct:AddField('E2__DMOEDA', 'ZZ'  , STR0013   , STR0014   , {}   , 'GET'        ,'!@'    ,        ,     ,   .T., '1'   ,      , {}         ,              ,             , .T.    ) // 'S�mb. Moeda' - 'S�mbolo da Moeda'
oStruct:AddField('E2__VALOR' , 'ZZ'  , cTitValor , cDesValor , {}   , 'GET'        ,cPict   ,        ,     ,   .F., '1'   ,      , {}         ,              ,             , .T.    ) // 'Valor T�tulo'

aAdd(aLgpd, {"E2__VLRLIQ", "E2_VALOR"  })
aAdd(aLgpd, {"E2__DNATUR", "OHG_DNATUR"})
aAdd(aLgpd, {"E2__TOTDES", "OHG_VALOR" })
aAdd(aLgpd, {"E2__SLDDES", "OHG_VALOR" })
aAdd(aLgpd, {"E2__CMOEDA", "E2_MOEDA"  })
aAdd(aLgpd, {"E2__DMOEDA", "CTO_SIMB"  })
aAdd(aLgpd, {"E2__VALOR" , "E2_VALOR"  })

If FindFunction("JPDOfusca")
	JPDOfusca(@oStruct, aLgpd)
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J247SE2Ord(oStruct, aOrdemCpo)
Ajusta a ordem dos campos na view da SE2.

@Param oStruct     Estrutura da SE2
@Param aOrdemCpo  Array com os campos ordenados

@Param oStruct Estrutura a ser adicionadas os campos
@Param nTipo   1- para adi��o no Model; 2 - para adi��o an View

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247SE2Ord(oStruct, aOrdemCpo)
Local nI := 1

For nI := 1 To Len(aOrdemCpo)

	oStruct:SetProperty(aOrdemCpo[nI], MVC_VIEW_ORDEM, RetAsc(Str(nI), 2, .T.) )

Next nI

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J247InitP(cCampo)
Inicializador padr�o dos campos virtuais da SE2

@Param J247InitP  Array com os campos ordenados

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247InitP(cCampo)
	Local xRet   := Nil

	Do Case
		Case cCampo == 'E2__DNATUR'
			xRet := POSICIONE("SED", 1, XFILIAL("SED") + SE2->E2_NATUREZ, 'ED_DESCRIC ')

		Case cCampo == 'E2__CMOEDA'
			xRet := PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1],'0')

		Case cCampo == 'E2__DMOEDA'
			xRet := POSICIONE('CTO',1,xFilial('CTO')+ PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1],'0'), 'CTO_SIMB')

		Case cCampo == 'E2__VLRLIQ'
			xRet := JCPVlLiqui(SE2->(Recno()))

		Case cCampo == 'E2__TOTDES'
			xRet := 0

		Case cCampo == 'E2__SLDDES'
			xRet := 0

		Case cCampo == 'E2__VALOR'
			xRet := JCPVlBruto(SE2->(Recno()))
	EndCase

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247Event
Classe interna implementando o FWModelEvent, para execu��o de fun��o
durante o commit.

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA247Event FROM FWModelEvent
	Data aModelDesp // Model para inclus�o de Despesa
	Data aModelLanc // Model para inclus�o de Lan�amento
	Data aModelNZQ  // Model para aprova��o de despesa

	Method New()
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
Method New() Class JA247Event
	Self:aModelDesp := {}
	Self:aModelLanc := {}
	Self:aModelNZQ  := {}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model.

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA247Event
	Local lRet       := .T.
	Local lOrigJu049 := FwIsInCallStack("J049RepDsb") // Quando a origem da opera��o for da JURA049(Despesa)
	Local lOrigJ235A := FwIsInCallStack("J235ACancela") .Or. FwIsInCallStack("J235ADsdb") // Quando a origem � a JURA235A (aprova��o de solicita��o de despesas ou cancelamento da aprova��o)
	Local lCodAprDes := OHG->(ColumnPos("OHG_NZQCOD")) > 0
	Local lCancAprov := FWIsInCallStack("J235ACancela") // Quando a origem da opera��o for da Cancelamento aprova��o de despesas (JURA235A)
	Local lIsRest    := FindFunction("JurIsRest") .And. JurIsRest()
	Local aRetTemp   := {} // Recebe retorno das fun��es de modelo
	Local nOper      := oModel:GetOperation()

	Self:aModelDesp  := {}
	Self:aModelLanc  := {}
	Self:aModelNZQ   := {}

	lRet := J247VldSld(oModel)

	// Altera as aprova��es de despesa conforme atualiza��o do desdobramento
	If lRet .And. lCodAprDes .And. FindFunction("J235AUpdNZQ") .And. !lOrigJ235A
		aRetTemp := J235AUpdNZQ(oModel)
		If lRet := aRetTemp[1]
			Self:aModelNZQ := aRetTemp[2]
		EndIf
	EndIf

	If lRet .And. !lOrigJu049
		//Gera e valida modelo para INSERT/UPDATE/DELETE da Despesa
		aRetTemp := J247OpDesp(oModel)
		If lRet := aRetTemp[1]
			Self:aModelDesp := aRetTemp[2]
		EndIf
	EndIf

	If lRet .And. FindFunction("J235Anexo") .And. !FWIsInCallStack("J247LANC") .And. (lIsRest .Or. lCancAprov .Or. nOper == MODEL_OPERATION_DELETE)
		lRet := J235Anexo(oModel, "OHG", "OHGDETAIL", "OHG_IDDOC", "OHG_CITEM")
	EndIf

	If lRet .And. OHB->(ColumnPos("OHB_CPAGTO")) > 0 // Prote��o
		aRetTemp := J247OpLanc(oModel)
		If (lRet := aRetTemp[1])
			Self:aModelLanc := aRetTemp[2]
		EndIf
	EndIf

	If !lRet
		JurFreeArr(@Self:aModelDesp)
		JurFreeArr(@Self:aModelLanc)
		JurFreeArr(@Self:aModelNZQ)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Before
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes 
da grava��o de cada submodelo (field ou cada linha de uma grid)

@author Jonatas Martins
@since  15/10/2017
/*/
//-------------------------------------------------------------------
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA247Event

	// Executa estorno de contabiliza��o na altera��o/exclus�o de cada linha do desdobramento
	If !lNewRecord .And. cModelId == "OHGDETAIL" .And. FindFunction("J246EstCtb") .And. FindFunction("JURA265B") .And. OHG->(ColumnPos("OHG_DTCONT")) > 0
		J246EstCtb(oSubModel, "OHG", "949") // Estorno de desdobramento P�s Pagamento
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m
antes do final da transa��o

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA247Event
	Local cChave := ""
	Local cItem  := ""
	Local cIdDoc := ""
	Local nCtb   := 0

	If FWIsInCallStack("J235APreApr") .And. FindFunction("J235RepAnex") // Replica anexos da solicita��o de despesa quando vier da aprova��o
		cChave := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
		cItem  := oModel:GetValue("OHGDETAIL", "OHG_CITEM")
		cIdDoc := FINGRVFK7("SE2", cChave) + cItem
		J235RepAnex("OHG", xFilial("OHG"), cIdDoc, cChave, cItem)
	EndIf

	If !Empty(Self:aModelDesp)
		Processa( {||J247CMTAux(Self:aModelDesp, "NVY", "NVYMASTER")}, STR0003, STR0004)// "Gravando." "Atualizando Despesa..."
	EndIf

	If !Empty(Self:aModelLanc)
		Processa( {||J247CMTAux(Self:aModelLanc, "OHB", "OHBMASTER")}, STR0003, STR0030)// "Gravando." "Atualizando Lan�amentos..."
	EndIf

	If !Empty(Self:aModelNZQ)
		Processa( {||J247CMTAux(Self:aModelNZQ, "NZQ", "NZQMASTER")}, STR0003, STR0055)// "Gravando." "Atualizando Aprova��es de Despesas..."
	EndIf

	// Exclui os anexos dos desdobramentos que forem exclu�dos
	J247ExcAnx(oModel, "OHG")

	// Executa contabiliza��o desdobramentos p�s pagamento estornados por altera��es
	If FindFunction("JURA265B")
		For nCtb := 1 To Len(_aRecPosCtb)
			JURA265B("944", _aRecPosCtb[nCtb]) // Contabiliza��o de desdobramento p�s pagamento
		Next nCtb
	EndIf

	JurFreeArr(_aRecPosCtb)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrutor da classe

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class JA247Event
	JurFreeArr(@Self:aModelDesp)
	JurFreeArr(@Self:aModelLanc)
	JurFreeArr(@Self:aModelNZQ)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J247OpDesp(oModel, nOperDesp)
Valida e prepara a despesa para inclus�o, altera��o ou exclus�o.

@param oModel    => Modelo ativo
@param nOperDesp => Operacao para a Despesa (1=INSERT;2=UPDATE;3=DELETE)

@Return oModelNVY Retorna o modelo preparado da NVY para

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247OpDesp(oModel)
	Local aModelDesp := {}
	Local oModelSE2  := oModel:GetModel("SE2MASTER")
	Local oModelOHG  := oModel:GetModel("OHGDETAIL")
	Local cCobraOld  := ""
	Local lOk        := .T.
	Local nLine      := 1
	Local nQtdOHG    := oModelOHG:GetQTDLine()
	Local nOperDesp  := 0
	Local nUltimoDp  := 0
	Local cChave     := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA

	For nLine := 1 To nQtdOHG
		nOperDesp := J247AcDesp(oModel, nLine) // Verifica se � necess�rio gerar um INSERT/UPDATE/DELETE de Despesa

		If nOperDesp != 0 //N�o � necess�rio atualizar despesa.
			If nOperDesp == MODEL_OPERATION_UPDATE
				cCobraOld := JurGetDados('OHG', 1, xFilial("OHG") + oModelOHG:GetValue('OHG_IDDOC') + oModelOHG:GetValue('OHG_CITEM'), 'OHG_COBRA')
			Else
				cCobraOld := ""
			EndIf

			aAdd (aModelDesp, JA049GerDp(nOperDesp,;
								oModelOHG:GetValue("OHG_CDESP"  , nLine),;
								oModelOHG:GetValue("OHG_CCLIEN" , nLine),;
								oModelOHG:GetValue("OHG_CLOJA"  , nLine),;
								oModelOHG:GetValue("OHG_CCASO"  , nLine),;
								oModelOHG:GetValue("OHG_DTDESP" , nLine),;
								oModelOHG:GetValue("OHG_SIGLA"  , nLine),;
								oModelOHG:GetValue("OHG_CTPDSP" , nLine),;
								oModelOHG:GetValue("OHG_QTDDSP" , nLine),;
								oModelOHG:GetValue("OHG_COBRA"  , nLine),;
								oModelOHG:GetValue("OHG_HISTOR" , nLine),;
								oModelSE2:GetValue("E2__CMOEDA"),;
								oModelOHG:GetValue("OHG_VALOR"  , nLine),;
								cCobraOld,;
								,;
								cChave,;
								,;
								oModelOHG:GetValue("OHG_CITEM"  , nLine)))

			nUltimoDp := Len(aModelDesp)
			If Empty(aModelDesp[nUltimoDp])
				lOk        := .F.
				aModelDesp := {}
				Exit

			ElseIf nOperDesp == MODEL_OPERATION_INSERT
				oModelOHG:GoLine(nLine)
				oModelOHG:SetValue("OHG_CDESP", aModelDesp[nUltimoDp]:GetValue("NVYMASTER","NVY_COD"))

			ElseIf nOperDesp == MODEL_OPERATION_DELETE
				oModelOHG:GoLine(nLine)
				oModelOHG:SetValue("OHG_CDESP", "")

			EndIf
		EndIf
	Next nLine

Return {lOk, aModelDesp}

//-------------------------------------------------------------------
/*/{Protheus.doc} J247AcDesp(oModel)
Verifica se � necess�rio gerar um INSERT/UPDATE/DELETE de Despesa e retorna qual opera��o ser� executada

@param oModel     => Modelo ativo

@Return nOperDesp => A opera��o que � necess�rio para atualizar a Despesa vinculada, retorna 0 quando n�o existe atualiza��o para ser realizada.

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247AcDesp(oModel, nLine)
Local nOperDesp  := 0
Local oModelOHG  := oModel:GetModel("OHGDETAIL")
Local lNatDspNew := JurGetDados('SED', 1, xFilial('SED') + oModelOHG:GetValue("OHG_CNATUR", nLine), 'ED_CCJURI') == "5"
Local cNatOld    := JurGetDados('OHG', 1, xFilial('OHG') + oModelOHG:GetValue("OHG_IDDOC", nLine) + oModelOHG:GetValue("OHG_CITEM", nLine), 'OHG_CNATUR')
Local lNatDspOld := JurGetDados('SED', 1, xFilial('SED') + cNatOld, 'ED_CCJURI') == "5"

	If !oModelOHG:IsUpdated(nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_CPART" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_SIGLA" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_CCLIEN", nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_CLOJA" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_CCASO" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_CTPDSP", nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_QTDDSP", nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_DTDESP", nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_VALOR" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_COBRA" , nLine);
	   .Or. oModelOHG:IsFieldUpdated("OHG_HISTOR", nLine)

	If oModelOHG:IsInserted(nLine)
		Iif(lNatDspNew, nOperDesp := MODEL_OPERATION_INSERT, )

	ElseIf oModelOHG:IsDeleted(nLine)
		If lNatDspNew .And. lNatDspOld
			nOperDesp := MODEL_OPERATION_DELETE
		EndIf

	ElseIf oModelOHG:IsUpdated(nLine)
		If lNatDspNew .And. lNatDspOld //Se o lan�amento era e continua sendo com despesa
			nOperDesp := MODEL_OPERATION_UPDATE

		ElseIf lNatDspNew //Se o lan�amento N�O era de Despesa e agora � de Despesa
			nOperDesp := MODEL_OPERATION_INSERT

		ElseIf lNatDspOld //Se o lan�amento era de Despesa e agora N�O � mais de Despesa
			nOperDesp := MODEL_OPERATION_DELETE

		EndIf
	EndIf
	EndIf

Return nOperDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} J247CMTAux
Efetua o commit nas rotinas auxiliares.

@param aModel  , Array com os Modelos da rotina - Ex: NVY(Despesa)
@param cTable  , Tabela principal dos modelos (aModel)
@param cIdModel, Id do modelo principal (cTable)

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247CMTAux(aModel, cTable, cIdModel)
Local nRecLine := 0
Local nQtd     := Len(aModel)
Local nItem    := 1
Local oModel   := Nil

	ProcRegua(nQtd)

	For nItem := 1 To nQtd
		If (aModel[nItem] != Nil)
			oModel   := aModel[nItem]:GetModel(cIdModel)
			nRecLine := oModel:GetDataID()
			(cTable)->(DbGoTo(nRecLine))
			aModel[nItem]:CommitData()
		EndIf
		IncProc()
	Next nItem

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247WHEN
When dos campos da OHG - desdobramento p�s pagamento financeiro

1 - Escrit�rio
2 - Escrit�rio e Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transit�ria de Pagamentos

@author bruno.ritter
@since 10/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA247WHEN()
Local lRet     := .T.
Local cCampo   := Alltrim(StrTran(ReadVar(),'M->',''))
Local cModelo  := "OHGDETAIL"
Local cNatur   := "OHG_CNATUR"
Local cEscrit  := "OHG_CESCR"
Local cCusto   := "OHG_CCUSTO"
Local cSigla   := "OHG_SIGLA2"
Local cRateio  := "OHG_CRATEI"
Local cClient  := "OHG_CCLIEN"
Local cLoja    := "OHG_CLOJA"
Local cCaso    := "OHG_CCASO"

	//----------------//
	// Grupo Natureza //
	//----------------//
	If cCampo $ 'OHG_CESCR'
		lRet := JurWhNatCC("1", cModelo, cNatur , cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHG_CCUSTO'
		lRet := JurWhNatCC("2", cModelo, cNatur , cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHG_SIGLA2|OHG_CPART2'
		lRet := JurWhNatCC("3", cModelo, cNatur , cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHG_CRATEI'
		lRet := JurWhNatCC("4", cModelo, cNatur , cEscrit, cCusto, cSigla, cRateio)

	//---------------//
	// Grupo Despesa //
	//---------------//
	ElseIf cCampo $ 'OHG_CCLIEN|OHG_CLOJA|OHG_QTDDSP|OHG_COBRA|OHG_DTDESP|OHG_CTPDSP'
		lRet := JurWhNatCC("5", cModelo, cNatur, , , , , cClient, cLoja, cCaso)

	ElseIf cCampo $ 'OHG_CCASO'
		lRet := JurWhNatCC("6", cModelo, cNatur, , , , , cClient, cLoja, cCaso)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247IniCBD()
Fun��o do gatilho das naturezas para preencher o valor padr�o "cobrar despesa?".

@Return cOpcao => Op��o do campo cobrar despesa

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247IniCBD()
Local cOpcao := ''

If JurGetDados('SED', 1, xFilial('SED') + FwFldGet('OHG_CNATUR'), 'ED_CCJURI') == '5'
	cOpcao := '1'
EndIf

Return cOpcao

//-------------------------------------------------------------------
/*/{Protheus.doc} J247VldEscr(cEscrit)
Valida��o do campo de Escrit�rio

@Param cEscrit  C�digo do escrit�rio

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247VldEscr(cEscrit)
Local lRet   := .T.

lRet := ExistCpo('NS7', cEscrit, 1) .And. JAVLDCAMPO('OHGDETAIL', 'OHG_CESCR' ,'NS7' ,'NS7_ATIVO', '1')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247DESC
Retorna a descri��o do caso. Chamado pelo inicializador padr�o dos campos

@Param  - cCampo    Nome do campo para busca dos dados de Cliente e Loja

@Return - cRet      Descri��o/Assunto do Caso

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA247DESC(cCampo)
Local cRet     := ""
Default cCampo := ""

If !Empty(cCampo)
	If cCampo == 'OHG_DCASO'
		cRet := POSICIONE('NVE', 1, xFilial('NVE') + OHG->OHG_CCLIEN + OHG->OHG_CLOJA + OHG->OHG_CCASO, 'NVE_TITULO')
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condi��o de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente N�O pertence ao caso informado

@author bruno.ritter
@since 10/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247ClxCa()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cClien    := ""
Local cLoja     := ""
Local cCaso     := ""

cClien := oModel:GetValue("OHGDETAIL", "OHG_CCLIEN")
cLoja  := oModel:GetValue("OHGDETAIL", "OHG_CLOJA")
cCaso  := oModel:GetValue("OHGDETAIL", "OHG_CCASO")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247VldHis(cHist)
Valida��o do historico padr�o

@Param cHist  C�digo do hit�rico padr�o

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247VldHis(cHist)
Local lRet   := .T.

lRet := ExistCpo('OHA', cHist, 1) .And. JAVLDCAMPO('OHGDETAIL', 'OHG_CHISTP' ,'OHA' ,'OHA_CTAPAG', '1')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247PosOHG
P�s valida��o do grid OHG

Centro de Custo Jur�dico (cCCNatur || cCCNatDest)
1 - Escrit�rio
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transit�ria de Pagamentos

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247PosOHG(oModel)
Local lRet      := .T.
Local lIsRest   := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
	
	lRet := JurVldNCC(oModel, "OHGDETAIL", "OHG_CNATUR", "OHG_CESCR", "OHG_CCUSTO", "OHG_CPART2", "OHG_SIGLA2", "OHG_CRATEI", "OHG_CCLIEN", "OHG_CLOJA", ;
					"OHG_CCASO", "OHG_CTPDSP", "OHG_QTDDSP", "OHG_COBRA", "OHG_DTDESP", "OHG_CPART", "OHG_SIGLA", "OHG_CPROJE", "OHG_CITPRJ")

	If lRet .And. oModel:GetModel("OHGDETAIL"):IsInserted() .And. lIsRest .And. OHG->(FieldPos( "OHG_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		lRet := JurMsgCdLD(oModel:GetValue("OHGDETAIL", "OHG_CODLD"))
	EndIf

	If lRet .And. Empty(oModel:GetValue("OHGDETAIL", "OHG_CHISTP")) .And. SuperGetMv("MV_JHISPAD", .F., .F.)
		lRet := .F.
		JurMsgErro(STR0051,, STR0052) // "� obrigat�rio o preenchimento do Hist�rico Padr�o, conforme o par�metro MV_JHISPAD." # "Informe um c�digo v�lido para o Hist�rico Padr�o."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247VldSld()
Valida se o valor total dos desdobramentos � maior que o saldo

@Param oModel  Modelo de dados

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247VldSld(oModel)
Local lRet      := .T.
Local oModelSE2 := oModel:GetModel("SE2MASTER")
Local cValor    := ""
Local cFilSE2   := ""
Local cPrefixo  := ""
Local cNum      := ""
Local cParcela  := ""
Local cTipo     := ""
Local cFornece  := ""
Local cLoja     := ""
Local nValorDsd := 0

Local oModelOHG  := oModel:GetModel("OHGDETAIL")
Local nLine      := 1
Local nQtdOHG    := oModelOHG:GetQTDLine()


If oModelSE2:GetValue("E2__SLDDES") < 0
	cFilSE2   := oModelSE2:GetValue("E2_FILIAL")
	cPrefixo  := oModelSE2:GetValue("E2_PREFIXO")
	cNum      := oModelSE2:GetValue("E2_NUM")
	cParcela  := oModelSE2:GetValue("E2_PARCELA")
	cTipo     := oModelSE2:GetValue("E2_TIPO")
	cFornece  := oModelSE2:GetValue("E2_FORNECE")
	cLoja     := oModelSE2:GetValue("E2_LOJA")
	nValorDsd := JValDesPos(cFilSE2, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja)

	cValor := AllTrim(Transform(nValorDsd, (GetSx3Cache('E2_VALOR', 'X3_PICTURE') ) ) )

	lRet := .F.
	JurMsgErro(STR0017,,I18N(STR0018,{cValor})) // 'O valor total dos desdobramento n�o pode ser maior do que foi definido na natureza transit�ria p�s pagamento.' - 'O valor m�ximo para o desdobramento � #1.'

EndIf

//Validacao cliente/loja igual os parametros:MV_JURTS5 e MV_JURTS6 ou MV_JURTS9 e MV_JURTS10
If lRet .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)

	For nLine := 1 To nQtdOHG
		If !oModelOHG:IsDeleted(nLine)
			lRet := JurCliLVld(oModel, oModelOHG:GetValue('OHG_CCLIEN', nLine), oModelOHG:GetValue('OHG_CLOJA', nLine))
			If !lRet
	   			Exit
	   		EndIf
		EndIf
	Next nLine	
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247VldACT(oModel)
Fun��o de valida��o da ativa��o do modelo.

@author bruno.ritter
@since 10/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247VldACT(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local nOper     := oModel:GetOperation()
Local nSaldo    := 0
Local cFilSE2   := ""
Local cPrefixo  := ""
Local cNum      := ""
Local cParcela  := ""
Local cTipo     := ""
Local cFornece  := ""
Local cLoja     := ""
Local cChave    := ""
Local cIdDoc    := ""
Local lBxParc   := .F.
Local lDesdPos  := .F.

 	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_DELETE
		If ! IsInCallStack("J246DelOHF") .And. Empty(JURUSUARIO(__CUSERID))
			lRet := .F.
			oModel:SetErrorMessage(,, oModel:GetId(),, "J247VldACT", STR0019, STR0020,, ) // "N�o ser� poss�vel manipular os desdobramentos do Contas Pagar, pois o usu�rio n�o est� vinculado a um participante." "Associe seu usu�rio a um participante para ter acesso a opera��o.
		EndIf

		If lRet
			cFilSE2   := SE2->E2_FILIAL
			cPrefixo  := SE2->E2_PREFIXO
			cNum      := SE2->E2_NUM
			cParcela  := SE2->E2_PARCELA
			cTipo     := SE2->E2_TIPO
			cFornece  := SE2->E2_FORNECE
			cLoja     := SE2->E2_LOJA
			nSaldo    := JValDesPos(cFilSE2, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja)
			If nSaldo <= 0
				lRet := .F.
				oModel:SetErrorMessage(,, oModel:GetId(),, "J247VldACT", STR0023, STR0024,, ) //#"N�o existe saldo para ser desdobrado." ##"Verifique o(s) desdobramento(s) lan�ado(s) no t�tulo"
			EndIf
		EndIf

		If lRet
			//Valida se existe baixa.
			cChave := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
			cIdDoc := FINGRVFK7("SE2", cChave)
			lBxParc   := SE2->E2_SALDO != SE2->E2_VALOR
			OHG->(DbSetOrder(1)) //OHG_FILIAL + OHG_IDDOC + OHG_CITEM
			lDesdPos  := (OHG->(DbSeek( SE2->E2_FILIAL + cIdDoc)))

			If !lBxParc .And. !lDesdPos
				lRet := .F.
				oModel:SetErrorMessage(,, oModel:GetId(),, "J247VldACT", STR0025, STR0026,, ) //#"N�o existe baixa para o t�tulo com desdobramento transit�rio p�s pagamento." ##"Realize uma baixa para habilitar o desdobramento p�s pagamento"
			EndIf
		EndIf

	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247OpLanc()
Prepara o(s) lan�amento(s) para inclus�o, altera��o ou exclus�o.

@param oModel    => Modelo ativo

@Return oModelLanc Retorna o modelo preparado da OHB para commit

@author Jorge Martins
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247OpLanc(oModel)
	Local aModelLanc  := {}
	Local oModelOHG   := oModel:GetModel("OHGDETAIL")
	Local nQtdOHG     := oModelOHG:GetQtdLine()
	Local nLine       := 0
	Local nOperLanc   := 0
	Local nUltimoLanc := 0
	Local lRet        := .T.
	Local lIsRest     := FindFunction("JurIsRest") .And. JurIsRest()
	Local lCancAprov  := FWIsInCallStack("J235ACancela") // Quando a origem da opera��o for da Cancelamento aprova��o de despesas (JURA235A)

	For nLine := 1 To nQtdOHG
		nOperLanc := J247OpcOHB(oModelOHG, nLine) // Opera��o que deve realizada no lan�amento

		If nOperLanc != 0 // N�o � necess�rio atualizar despesa.

			aAdd(aModelLanc, J247Lanc(oModel, nOperLanc, nLine) ) // Preenchimento dos campos de lan�amentos (OHB)
			nUltimoLanc := Len(aModelLanc)

			If (aModelLanc[nUltimoLanc] != Nil)
				If Empty(aModelLanc[nUltimoLanc])
					lRet       := .F.
					JurFreeArr(@aModelLanc)
					Exit
				EndIf

				// Replica anexos do desdobramento p�s no momento da inclus�o do lan�amento
				If lRet .And. nOperLanc != MODEL_OPERATION_DELETE .And. !FWIsInCallStack("J235APreApr") .And. FindFunction("J235RepAnex")
					lRet := J235RepAnex("OHB", xFilial("OHB"), aModelLanc[nUltimoLanc]:GetValue("OHBMASTER", "OHB_CODIGO"), aModelLanc[nUltimoLanc]:GetValue("OHBMASTER", "OHB_CPAGTO"), aModelLanc[nUltimoLanc]:GetValue("OHBMASTER", "OHB_ITDPGT"))
				EndIf

				If lRet .And. FindFunction("J235Anexo") .And. (lIsRest .Or. lCancAprov .Or. nOperLanc == MODEL_OPERATION_DELETE)
					lRet := J235Anexo(aModelLanc[nUltimoLanc], "OHB", "OHBMASTER", "OHB_CODIGO")
				EndIf
			EndIf
		EndIf

	Next nLine

Return {lRet, aModelLanc}

//-------------------------------------------------------------------
/*/{Protheus.doc} J247OpcOHB()
Verifica se � necess�rio gerar um INSERT/UPDATE/DELETE de Lan�amento 
e retorna qual opera��o ser� executada

@param oModelOHG     => Modelo ativo
@param nLine         => Linha posicionada

@Return nOpcLanc => A opera��o que � necess�ria para atualizar o lan�amento vinculado, 
                    retorna 0 quando n�o existe atualiza��o a ser realizada.

@author Jorge Martins
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247OpcOHB(oModelOHG, nLine)
Local nOpcLanc := 0

	If oModelOHG:IsInserted(nLine) // Foi inserida...
		If !oModelOHG:IsDeleted(nLine) // ... e n�o foi deletada
			nOpcLanc := MODEL_OPERATION_INSERT
		EndIf
	ElseIf oModelOHG:IsDeleted(nLine)
		nOpcLanc := MODEL_OPERATION_DELETE
	ElseIf oModelOHG:IsUpdated(nLine)
		nOpcLanc := MODEL_OPERATION_UPDATE
	EndIf

Return nOpcLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J247Lanc()
Valida e prepara o lan�amento para inclus�o, altera��o ou exclus�o.

@param oModel    => Modelo ativo
@param nOpc      => Operacao
@param nLine     => Linha posicionada

@Return oModelLanc Retorna o modelo preparado da OHB

@author Jorge Martins
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247Lanc(oModel, nOpc, nLine)
Local aAreaOHB   := OHB->(GetArea())
Local oModelSE2  := oModel:GetModel("SE2MASTER")
Local oModelOHG  := oModel:GetModel("OHGDETAIL")
Local oModelLanc := Nil
Local oModelOHB  := Nil
Local aErro      := {}
Local cNatOri    := "" // C�digo da natureza cujo C.C. Jur�dico � Transit�rio p�s pagamento
Local cNatDes    := ""
Local cCodLanc   := ""
Local nValLine   := 0
Local lNegativo  := .F.
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))
Local cChaveSE2  := oModelSE2:GetValue("E2_FILIAL" ) + '|' + ;
                    oModelSE2:GetValue("E2_PREFIXO") + '|' + ;
                    oModelSE2:GetValue("E2_NUM"    ) + '|' + ;
                    oModelSE2:GetValue("E2_PARCELA") + '|' + ;
                    oModelSE2:GetValue("E2_TIPO"   ) + '|' + ;
                    oModelSE2:GetValue("E2_FORNECE") + '|' + ;
                    oModelSE2:GetValue("E2_LOJA"   ) 

	cCodLanc := J247CodOHB(oModelOHG, nLine, cChaveSE2)

	OHB->(DbSetOrder(1)) // OHB_FILIAL + OHB_CODIGO
	If nOpc == MODEL_OPERATION_INSERT .Or. (!Empty(cCodLanc) .And. OHB->(DbSeek(xFilial("OHB") + cCodLanc)))
		oModelLanc := FWLoadModel("JURA241")
		oModelLanc:SetOperation(nOpc)
		oModelLanc:Activate()

		cNatOri  := JurBusNat("6")
		cNatDes  := oModelOHG:GetValue("OHG_CNATUR", nLine)
		nValLine := oModelOHG:GetValue("OHG_VALOR" , nLine)

		lNegativo := nValLine < 0
		nValLine  := IIF(lNegativo, nValLine * -1, nValLine)

		If nOpc != MODEL_OPERATION_DELETE
			oModelOHB := oModelLanc:GetModel("OHBMASTER")
			JurSetVal(oModelOHB, "OHB_ORIGEM" , "1"                                     )
			JurSetVal(oModelOHB, "OHB_NATORI" , IIF(lNegativo, cNatDes, cNatOri)        )
			JurSetVal(oModelOHB, "OHB_NATDES" , ""                                      ) // Limpa a natureza para limpar os campos de CCJuri para n�o dar problema no when
			JurSetVal(oModelOHB, "OHB_NATDES" , IIF(lNegativo, cNatOri, cNatDes)        )
			JurSetVal(oModelOHB, "OHB_CESCRD" , oModelOHG:GetValue("OHG_CESCR" , nLine) )
			JurSetVal(oModelOHB, "OHB_CCUSTD" , oModelOHG:GetValue("OHG_CCUSTO", nLine) )
			JurSetVal(oModelOHB, "OHB_SIGLAD" , oModelOHG:GetValue("OHG_SIGLA2", nLine) )
			JurSetVal(oModelOHB, "OHB_CTRATD" , oModelOHG:GetValue("OHG_CRATEI", nLine) )
			JurSetVal(oModelOHB, "OHB_CCLID"  , oModelOHG:GetValue("OHG_CCLIEN", nLine) )
			JurSetVal(oModelOHB, "OHB_CLOJD"  , oModelOHG:GetValue("OHG_CLOJA" , nLine) )
			JurSetVal(oModelOHB, "OHB_CCASOD" , oModelOHG:GetValue("OHG_CCASO" , nLine) )
			JurSetVal(oModelOHB, "OHB_CTPDPD" , oModelOHG:GetValue("OHG_CTPDSP", nLine) )
			JurSetVal(oModelOHB, "OHB_QTDDSD" , oModelOHG:GetValue("OHG_QTDDSP", nLine) )
			JurSetVal(oModelOHB, "OHB_COBRAD" , oModelOHG:GetValue("OHG_COBRA" , nLine) )
			JurSetVal(oModelOHB, "OHB_DTDESP" , oModelOHG:GetValue("OHG_DTDESP", nLine) )
			JurSetVal(oModelOHB, "OHB_SIGLA"  , oModelOHG:GetValue("OHG_SIGLA" , nLine) )
			JurSetVal(oModelOHB, "OHB_DTLANC" , Date()                                  )
			JurSetVal(oModelOHB, "OHB_CMOELC" , oModelSE2:GetValue("E2__CMOEDA")        )
			JurSetVal(oModelOHB, "OHB_VALOR"  , nValLine                                )
			JurSetVal(oModelOHB, "OHB_CHISTP" , oModelOHG:GetValue("OHG_CHISTP", nLine) )
			JurSetVal(oModelOHB, "OHB_HISTOR" , oModelOHG:GetValue("OHG_HISTOR", nLine) )
			JurSetVal(oModelOHB, "OHB_FILORI" , cFilAnt                                 )

			JurSetVal(oModelOHB, Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE") , oModelOHG:GetValue("OHG_CPROJE", nLine) )
			JurSetVal(oModelOHB, Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ") , oModelOHG:GetValue("OHG_CITPRJ", nLine) )

			// Dados de v�nculo do desdobramento com lan�amento
			JurSetVal(oModelOHB, "OHB_ITDPGT" , oModelOHG:GetValue("OHG_CITEM" , nLine) )
			JurSetVal(oModelOHB, "OHB_CPAGTO" , cChaveSE2                               )

		EndIf

		If oModelLanc:HasErrorMessage()
			aErro := oModelLanc:GetErrorMessage()

			JurMsgErro(STR0029,,Alltrim(aErro[7])) // "Erro ao atualizar lan�amento: "
				oModelLanc:Destroy()
				oModelLanc := Nil

		ElseIf !oModelLanc:VldData()
			aErro := oModelLanc:GetErrorMessage()

			JurMsgErro(STR0029,,Alltrim(aErro[7])) // "Erro ao atualizar lan�amento: "
				oModelLanc:Destroy()
				oModelLanc := Nil
		EndIf
	EndIf

	RestArea(aAreaOHB)

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J247CodOHB()
Retorna c�digo do lan�amento OHB vinculado ao desdobramento p�s 
pagamento indicado

@param oModelOHG   => Modelo da tabela de desdobramento p�s pagamento
@param nLine       => Linha posicionada no oModelOHG
@param cChaveSE2   => Chave do contas a pagar do desdobramento

@return cRet       => C�digo do Lan�amento (OHB)

@author Jorge Martins
@since 22/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247CodOHB(oModelOHG, nLine, cChaveSE2)
Local cRet      := ""
Local aSQL      := {}
Local cOHGItem  := oModelOHG:GetValue("OHG_CITEM", nLine)

	If !Empty(cOHGItem)
		cQuery := " SELECT OHB_CODIGO OHBCOD"
		cQuery +=   " FROM " + RetSqlName("OHB") + " OHB "
		cQuery +=  " WHERE OHB_FILIAL = '" + xFilial("OHB") + "' "
		cQuery +=    " AND OHB_CPAGTO = '" + cChaveSE2 + "' "
		cQuery +=    " AND OHB_ITDPGT = '" + cOHGItem + "' "
		cQuery +=    " AND D_E_L_E_T_ = ' ' "

		aSQL := JurSQL(cQuery, {"OHBCOD"})

		If !Empty(aSQL)
			cRet := aSQL[1][1]
		EndIf

		aSize(aSQL, 0)

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247PreOHG()
Fun��o de pr� valida��o do modelo OHG

@author Jorge Martins
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J247PreOHG(oModel,�nLine, cAction, cField, xNewValue, xOldValue)
Local lRet        := .T.
Local lOrigJ235A  := FwIsInCallStack("J235ACancela")
Local lIsRest     := (IIF(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local oModelOHG   := oModel:GetModel("OHGDETAIL")
Local cCodAprDes  := IIF(OHG->(ColumnPos("OHG_NZQCOD")) > 0, oModelOHG:GetValue("OHG_NZQCOD", nLine), "")
Local cAnexo      := oModelOHG:GetValue("OHG__ANEXO", nLine)
Local aRetDesp    := {}
Local cDespesa    := ""

// Verifica se o desdobramento � originado de uma aprova��o de despesa
If lRet .And. !IsBlind() .And. !Empty(cCodAprDes) .And. cAction $ "DELETE" .And. !lOrigJ235A
	lRet := ApMsgYesNo(STR0048) // "Esse desdobramento tem como origem a aprova��o de uma solicita��o de despesa. Deseja realmente excluir o desdobramento e reprovar a solicita��o de despesa?"
	If !lRet
		JurMsgErro(STR0049, ,STR0050, .F.) // "Opera��o cancelada." # "Desdobramento n�o removido."
	EndIf
EndIf

If lRet .And. !lIsRest ;                              // Execu��o via REST integra��o com LegalDesk
        .And. "CANSETVALUE" != cAction ;              // Altera��o de Valor
        .And. cField == "OHG_CNATUR" ;                // Campo de natureza
        .And. xNewValue != xOldValue                  // Valor novo diferente do valor antigo

	cCCNatNew := JurGetDados("SED", 1, xFilial("SED") + xNewValue, "ED_CCJURI")
	cCCNatOld := JurGetDados("SED", 1, xFilial("SED") + xOldValue, "ED_CCJURI")

	If AllTrim(SE2->E2_ORIGEM) == "JURCTORC" // Integra��o Controle Or�ament�rio SIGAPFS x SIGAFIN
		If cCCNatNew != cCCNatOld // Centros de custos jur�dico diferentes
			lRet := .F.
			JurMsgErro(STR0033,,; // "N�o � poss�vel alterar a natureza desse desdobramento."
			      i18n(STR0034, {AllTrim(xOldValue)}) ) // "Indique uma natureza que possua o mesmo centro de custo jur�dico da natureza '#1'."
		EndIf
	EndIf

	If lRet .And. AllTrim(cAnexo) == ICO_TEM_ANEXO // Possui anexos
		If cCCNatNew $ '6|7'// Houve mudan�a de centro de custo e o novo centro de custo � transit�rio ou transit�rio p�s pagamento
			lRet := .F.
			JurMsgErro(STR0033,,; // "N�o � poss�vel alterar a natureza desse desdobramento."
			      i18n(STR0039, {AllTrim(xNewValue)}) ) // "O desdobramento possui anexo(s). Para indicar a natureza '#1' � necess�rio excluir o(s) anexo(s)."
		EndIf
	EndIf

EndIf

If lRet .And. cAction == "SETVALUE" .And. !Empty(oModelOHG:GetValue("OHG_CDESP")) ;
   .And. cField $ "OHG_CPART|OHG_SIGLA|OHG_CCLIEN|OHG_CLOJA|OHG_CCASO|OHG_CTPDSP|OHG_QTDDSP|OHG_DTDESP|OHG_COBRA"

	cDespesa := oModelOHG:GetValue("OHG_CDESP")
	aRetDesp := JurGetDados("NVY", 1, xfilial("NVY") + cDespesa, {"NVY_SITUAC", "NVY_CPREFT"})

	If FindFunction("J246VldPre")
		lRet := J246VldPre(oModelOHG,"OHG")
	EndIf
EndIf

If lRet
	lRet := JAtuValDes("OHG",�oModel,�nLine,�cAction)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247CpoAnx()
Adiciona o campo de anexo no model e view

@param oStruct  => Estrutura na qual ser� adicionado o campo de anexo
@param cTabela  => Tabela da Estrutura
@param cTipo    => Indica se a Estrutura � do Model ("M") ou da View ("V")
@param bValid   => Bloco utilizado no campo de valid (fun��o que chama a tela de anexos)

@return oStruct => Estrutura da tabela com o novo campo

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247CpoAnx(oStruct, cTabela, cTipo, bValid)
Local cCampo := cTabela+'__ANEXO'

Default bValid  := Nil

If cTipo == "M" 
	                 // Titulo, Descricao, Campo  , Tipo do campo , Tamanho  , Decimal , bValid , bWhen , Lista , lObrigat,  bInicializador         , � chave, � edit�vel , � virtual
	oStruct:AddField( STR0037 , STR0037  , cCampo , 'BT'          , 1        , 0       , bValid ,       , Nil   , Nil     , {||J247IcoAnx(cTabela)} ,        ,            , .T.       ) // Anexos
Else
	                 //Campo  , Ordem , Titulo  , Descricao , Help , Tipo do campo, Picture, PictVar,   F3,  When, Folder, Group, Lista Combo, Tam Max Combo, Inic. Browse, Virtual
	oStruct:AddField( cCampo  , '00'  , STR0037 , STR0037   , {}   , 'BT'         ,'@BMP'  ,        ,     ,   .F.,       ,      , {}         ,              ,             , .T.    ) // Anexos
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} J247IcoAnx()
Indica qual icone deve ser exibido na legenda

@param cTabela  => Tabela na qual ser� aplicado o filtro que verifica
                   a exist�ncia de anexos

@return cIcone  => Icone que ser� utilizado

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247IcoAnx(cTabela)
Local cIcone    := ""
Local cChave    := ""
Local lWorkSite := AllTrim( SuperGetMv('MV_JDOCUME',,'1')) == "1"
Local lTemAnx   := .F.

If lWorkSite
	cChave  := IIf(cTabela == "OHF", "OHF->OHF_IDDOC + OHF->OHF_CITEM", "OHG->OHG_IDDOC + OHG->OHG_CITEM")
	lTemAnx := !Empty(AllTrim(JurGetDados('NUM', 3, xFilial('NUM') + cTabela + &(cChave), 'NUM_COD'))) // Indica se existem anexos
Else
	cChave  := IIf(cTabela == "OHF", "SE2->E2_FILIAL + OHF->OHF_IDDOC + OHF->OHF_CITEM", "SE2->E2_FILIAL + OHG->OHG_IDDOC + OHG->OHG_CITEM")
	lTemAnx := !Empty(AllTrim(JurGetDados('NUM', IIF(JurHasClas(), 5, 3), xFilial('NUM') + cTabela + &(cChave), 'NUM_COD'))) // Indica se existem anexos
EndIf

cIcone := IIf(lTemAnx, ICO_TEM_ANEXO, ICO_NAO_ANEXO) // Indica que existem anexos // Indica que n�o existem anexos

Return cIcone

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247Anexo()
Anexo de documentos

@return lRet   => .T./.F. - Indica se foi poss�vel anexar documentos.

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA247Anexo()
Local aAreas     := { OHF->(GetArea()), OHG->(GetArea()), GetArea() }
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
Local oModelDet  := Nil
Local nLine      := 0
Local lRet       := .T.
Local lUpdate    := .T.
Local cTabela    := ""
Local cDetail    := ""

	If oView:GetFolderActive("FOLDER_01", 2)[1] == 1 // Aba de Desdobramentos P�s Pagamento
		cTabela  := "OHG"
		cDetail  := "OHGDETAIL"
	Else
		cTabela  := "OHF"
		cDetail  := "OHFDETAIL"
	EndIf

	oModelDet := oModel:GetModel(cDetail)
	nLine     := oModelDet:GetLine()

	If lRet := J247VAnexo(oModelDet, nLine, cTabela+"_CNATUR") // Verifica que pode anexar nesse desdobramento
		
		(cTabela)->(dbGoto(oModelDet:GetDataId())) // Posiciona a tabela para a rotina de anexos

		JURANEXDOC(cTabela, cDetail, "", cTabela + "_IDDOC", "", "", "", "", "", "3", cTabela+"_CITEM", .F., .F., .T.) // Abre tela de anexo de documento
		lUpdate := oModelDet:CanUpdateLine() // Verifica se o grid � edit�vel

		IIf(lUpdate, Nil, oModelDet:SetNoUpdateLine(.F.)) // Caso o grid n�o seja edit�vel, habilita a edi��o somente para atualizar a legenda do anexo
		
		oModelDet:LoadValue(cTabela+"__ANEXO", J247IcoAnx(cTabela) ) // Atualiza a legenda
		
		IIf(lUpdate, Nil, oModelDet:SetNoUpdateLine(.T.)) // Caso tenha alterado a propriedade, volta para o status original
	
		oView:Refresh(cDetail)

	EndIf

AEval( aAreas , {|aArea| RestArea( aArea ) } )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J247VAnexo()
Valida��o para indicar se � poss�vel anexar documentos no desdobramento

@param oGrid   => Modelo (Grid) ativo
@param nLine   => Linha posicionada
@param cCpoNat => Nome do campo de natureza a ser usado na valida��o

@return lRet   => .T./.F. - Indica se � poss�vel anexar documentos.

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J247VAnexo(oGrid, nLine, cCpoNat)
Local lRet    := .T.
Local cCCJuri := ""

	If oGrid:IsInserted(nLine) // Foi inserida...
		lRet := .F.
		JurMsgErro(STR0040,,STR0041) // "N�o � poss�vel anexar documentos para linhas novas." - "Confirme a inclus�o do registro e acesse novamente a op��o de anexos."
	ElseIf oGrid:IsDeleted(nLine)
		lRet := .F.
		JurMsgErro(STR0042,,STR0043) // "N�o � poss�vel anexar documentos para linhas deletadas." - "Verifique a situa��o do registro para acessar a op��o de anexos."
	EndIf

	If lRet

		cCCJuri := JurGetDados("SED", 1, xFilial("SED") + oGrid:GetValue(cCpoNat, nLine), "ED_CCJURI")

		If cCCJuri $ '6|7' // Centros de custos transit�rios (pagamento ou p�s pagamento)
			lRet := .F.
			JurMsgErro(STR0044,,; // "N�o � poss�vel anexar documentos neste desdobramento."
			           STR0045 ) // "Verifique a natureza do desdobramento. N�o � permitida a inclus�o de anexo(s) para desdobramentos com naturezas transit�rias de pagamento ou transit�rias p�s pagamento."
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247Legen()
Legenda do grid

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA247Legen()
Local oLegenda := FWLegend():New() // Cria a legenda que identifica a estrutura

// Adiciona descri��o para cada legenda
oLegenda:Add( { || }, ICO_TEM_ANEXO , STR0046 ) // "H� anexo(s)"
oLegenda:Add( { || }, ICO_NAO_ANEXO , STR0047 ) // "N�o h� anexo(s)"

// Ativa a Legenda
oLegenda:Activate()

// Exibe a Tela de Legendas
oLegenda:View()

// Desativa a Legenda
oLegenda:DeActivate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J247ExcAnx()
Exclui os anexos das linhas que forem deletadas

@param oModel  - Modelo de dados de Desdobramento / Desdobramento p�s pagamento
@param cTabela - Tabela para identicar o desdobramento que ser� exclu�do 
                 OHF - Desdobramento / OHG - Desdobramento p�s pagamento

@author Jorge Martins
@since  21/11/2018
/*/
//-------------------------------------------------------------------
Function J247ExcAnx(oModel, cTabela)
Local oModelDet  := oModel:GetModel(cTabela + "DETAIL")
Local nQtdLine   := oModelDet:GetQtdLine()
Local nLine      := 0
Local cChave     := ""
Local lJurClass  := FindFunction("JurHasClas") .And. JurHasClas()
Local lWorkSite  := AllTrim(SuperGetMv("MV_JDOCUME", , "1")) == "1" // WorkSite/iManage

	If FindFunction("JExcAnxSinc")
		For nLine := 1 To nQtdLine
			If oModelDet:IsDeleted(nLine)

				cChave := IIF(lWorkSite .Or. lJurClass, "", oModelDet:GetValue(cTabela + "_FILIAL", nLine)) + ;
				          oModelDet:GetValue(cTabela + "_IDDOC", nLine) + ;
				          oModelDet:GetValue(cTabela + "_CITEM", nLine)

				JExcAnxSinc(cTabela, cChave) // Exclui os anexos vinculados ao desdobramento/desdobramento p�s pagamento e registra na fila de sincroniza��o

			EndIf
		Next
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J247SetEst
Fun��o para alimentar arry est�tico com registros estornados na
contabiliza��o

@author Jonatas Martins
@since  21/11/2018
@Obs    Fun��o chamada no fonte JURA246
/*/
//-------------------------------------------------------------------
Function J247SetEst(nRecnoReg)
	Default nRecnoReg := 0

	If nRecnoReg > 0
		aAdd(_aRecPosCtb, nRecnoReg)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA247Tracker()
Executa a fun��o de Tracker Cont�bil CTBC662().

@author Reginaldo Borges
@since  01/04/2022
/*/
//-------------------------------------------------------------------
Static Function JA247Tracker(oModel)
Local aAreas    := {OHG->(GetArea()), GetArea()}
Local oModelOHG := oModel:GetModel("OHGDETAIL")

	CTBC662("OHG", oModelOHG:GetDataId())
	AEval(aAreas, {|aArea| RestArea(aArea)})

Return .T.
