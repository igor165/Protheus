#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA297.CH'

Static __lLockRev   := .F. //lockbyname para gerar nova revisão
Static __cCodPPA    := ""
Static __cRevisao   := ""
Static __lGerRev    := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA297
Cadastro de Tabela de Classificadores de Receita e Despesa
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA297()
Local oBrowse

dbSelectArea("AK0")
dbSetOrder(1)

dbSelectArea("AK4")
dbSetOrder(1)

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'AK0' )

oBrowse:AddLegend( "AK0_STATUS == '1'"		, "YELLOW"	, "PPA em Inclusão"	) // "Baixa Ativa"
oBrowse:AddLegend( "AK0_STATUS == '2'"		, "GREEN"	, "PPA Ativo"	) // "Baixa Cancelada"
oBrowse:AddLegend( "AK0_STATUS == '3'"		, "RED"		, "PPA Obsoleto"	) // "Baixa Cancelada"


oBrowse:SetDescription( STR0001 ) //"Cadastro PPA"

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA297' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA297' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA297' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA297' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA297' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0018 Action 'P297GERREV' OPERATION 9 ACCESS 0 //"Gerar Revisão"
ADD OPTION aRotina TITLE STR0019 Action 'P297EFETIVA' OPERATION 4 ACCESS 0 //"Efetivar Revisão"


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruAK0 := FWFormStruct(1,'AK0')
Local oStruAK4 := FWFormStruct(1,'AK4')
Local oStruAK7 := FWFormStruct(1,'AK7')
Local oStruAKU := FWFormStruct(1,'AKU')
Local oStruVir := FWFormStruct(1,'AK7', {|x|  !Alltrim(x)+"|" $ "AK7_CODIGO|AK7_VERSAO|AK7_INDIC|AK7_QTDINI|AK7_QTDFIM|AK7_DSCIND|"})

Local oModel

//Criação de gatilho
oStruAK0:AddTrigger("AK0_CODIGO","AK0_VERSAO",{|| .T. },{|| P297VERSAO()})

oStruAK4:AddTrigger("AK4_UNGEST","AK4_DSCUNI",{|| .T. },{|| P297GATILHO("AK4_UNGEST")})
oStruAK4:AddTrigger("AK4_DIRET","AK4_DSCDIR",{|| .T. },{|| P297GATILHO("AK4_DIRET")})
oStruAK4:AddTrigger("AK4_PROGR","AK4_DSCPRO",{|| .T. },{|| P297GATILHO("AK4_PROGR")})
oStruAK4:AddTrigger("AK4_ANO","AK4_ANO"     ,{|| .T. },{|| P297GATILHO("AK4_ANO")})

oStruAK7:AddTrigger("AK7_INDIC","AK7_DSCIND",{|| .T. },{|| P297GATILHO("AK7_INDIC")})

oStruAKU:AddTrigger("AKU_ACAO","AKU_DSCACO",{|| .T. },{|| P297GATILHO("AKU_ACAO")})
oStruAKU:AddTrigger("AKU_PROD","AKU_DSCPRO",{|| .T. },{|| P297GATILHO("AKU_PROD")})


//Adiciona valide
oStruAK0:SetProperty('AK0_ANOFIM',MODEL_FIELD_VALID ,{|oModel|P297VLD(oModel)})

//Adicionando o When 
oStruAK0:SetProperty('AK0_CODIGO',MODEL_FIELD_WHEN,{||IIF(INCLUI,.T.,.F.)})

oStruVir:SetProperty('AK7_UNGEST',MODEL_FIELD_WHEN,{||.F.})
oStruVir:SetProperty('AK7_DIRET' ,MODEL_FIELD_WHEN,{||.F.})
oStruVir:SetProperty('AK7_PROGR' ,MODEL_FIELD_WHEN,{||.F.})
oStruVir:SetProperty('AK7_ANO'   ,MODEL_FIELD_WHEN,{||.F.})

//Inicializador padrão
oStruAK0:SetProperty('AK0_CODIGO',MODEL_FIELD_INIT,{|oModel|P297INIPAD(oModel)})
oStruAK0:SetProperty('AK0_VERSAO',MODEL_FIELD_INIT,{|oModel|IIF(__lGerRev,P297VERSAO(AK0->AK0_CODIGO),"")})

oModel := MPFormModel():New('PCOA297',{|oModel|P297PREVLD(oModel)},/*PosValidacao*/,{|oModel|P297COMMIT(oModel)})
oModel:SetVldActivate({|oModel|P297ACTIVAT(oModel)})

oModel:AddFields('AK0MASTER',,oStruAK0)

oModel:AddGrid('AK4DETAIL','AK0MASTER',oStruAK4, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:AddFields('VIRDETAIL','AK4DETAIL',oStruVir)
oModel:AddGrid('AK7DETAIL','AK4DETAIL',oStruAK7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('AKUDETAIL','AK4DETAIL',oStruAKU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Define o número máximo de linhas que o model poderá receber
oModel:GetModel("AK4DETAIL"):SetMaxLine(999)
//Não realiza gravação da strutura virtual
oModel:GetModel('VIRDETAIL'):SetOnlyQuery ( .T. )

oModel:SetRelation('AK4DETAIL',{{'AK4_FILIAL','XFilial("AK4")'},{'AK4_CODIGO','AK0_CODIGO'},{'AK4_VERSAO','AK0_VERSAO'}}, AK4->(IndexKey(1)) )
oModel:SetRelation('VIRDETAIL' ,{{'AK7_FILIAL','XFilial("AK7")'},{'AK7_CODIGO','AK0_CODIGO'},{'AK7_VERSAO','AK0_VERSAO'},{'AK7_UNGEST','AK4_UNGEST'},{'AK7_DIRET','AK4_DIRET'},{'AK7_PROGR','AK4_PROGR'},{'AK7_ANO','AK4_ANO'}}, AK7->(IndexKey(1)) )                                                                        
oModel:SetRelation('AK7DETAIL' ,{{'AK7_FILIAL','XFilial("AK7")'},{'AK7_CODIGO','AK0_CODIGO'},{'AK7_VERSAO','AK0_VERSAO'},{'AK7_UNGEST','AK4_UNGEST'},{'AK7_DIRET','AK4_DIRET'},{'AK7_PROGR','AK4_PROGR'},{'AK7_ANO','AK4_ANO'}}, AK7->(IndexKey(1)) )
oModel:SetRelation('AKUDETAIL' ,{{'AKU_FILIAL','XFilial("AKU")'},{'AKU_CODIGO','AK0_CODIGO'},{'AKU_VERSAO','AK0_VERSAO'},{'AKU_UNGEST','AK4_UNGEST'},{'AKU_DIRET','AK4_DIRET'},{'AKU_PROGR','AK4_PROGR'},{'AKU_ANO','AK4_ANO'}}, AKU->(IndexKey(1)) )

// Liga o controle de não repetição de linha
oModel:GetModel( 'AK4DETAIL' ):SetUniqueLine( { 'AK4_UNGEST','AK4_DIRET','AK4_PROGR','AK4_ANO' } )

oModel:SetPrimarykey({'AK0_FILIAL','AK0_CODIGO','AK0_VERSAO'})

oModel:SetDescription( STR0001 )  //'Cadastro PPA'

oModel:GetModel('AK7DETAIL'):SetDescription( STR0008 ) //'Indicadores'
oModel:GetModel('AKUDETAIL'):SetDescription( STR0009 ) //'Ação'
 
oModel:GetModel( 'AK4DETAIL' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruAK0	:= FWFormStruct(2,'AK0')
Local oStruAK4	:= FWFormStruct(2,'AK4')
Local oStruAK7	:= FWFormStruct(2,'AK7')
Local oStruAKU	:= FWFormStruct(2,'AKU')
Local oStruVir := FWFormStruct(2,'AK7', {|x|  !Alltrim(x)+"|" $ "AK7_CODIGO|AK7_VERSAO|AK7_INDIC|AK7_QTDINI|AK7_QTDFIM|AK7_DSCIND|"})
Local oModel	:= FWLoadModel('PCOA297')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_AK0',oStruAK0,'AK0MASTER')
oView:AddGrid('VIEW_AK4',oStruAK4,'AK4DETAIL')

oView:AddField('VIEW_VIR',oStruVir,'VIRDETAIL')
oView:AddGrid('VIEW_AK7',oStruAK7,'AK7DETAIL')
oView:AddGrid('VIEW_AKU',oStruAKU,'AKUDETAIL')

// Cria Folder na view
oView:CreateFolder( 'CADASTRO' )

// Cria pastas nas folders
oView:AddSheet( 'CADASTRO', 'ABA1', 'PPA' )  //'Itens - Aglutinadores Visão Gerencial'
oView:AddSheet( 'CADASTRO', 'ABA2', 'Itens' )  //'Itens - Aglutinadores Visão Gerencial'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CEMCIMA' 	,  40,,, 'CADASTRO', 'ABA1' )
oView:CreateHorizontalBox( 'CEMBAIXO'	,  60,,, 'CADASTRO', 'ABA1' )

oView:CreateHorizontalBox( 'EMCABA2' 	,  20,,, 'CADASTRO', 'ABA2' )
oView:CreateHorizontalBox( 'MEIOABA2'    ,  40,,, 'CADASTRO', 'ABA2' )
oView:CreateHorizontalBox( 'EMBABA2'	,  40,,, 'CADASTRO', 'ABA2' )

oView:SetOwnerView('VIEW_AK0','CEMCIMA'		)
oView:SetOwnerView('VIEW_AK4','CEMBAIXO'	)

oView:SetOwnerView('VIEW_VIR','EMCABA2'	)
oView:SetOwnerView('VIEW_AK7','MEIOABA2')
oView:SetOwnerView('VIEW_AKU','EMBABA2'	)


//Retira Campos da tela
oStruVir:RemoveField('AK0_INDIC')

oStruAK4:RemoveField('AK4_CODIGO')
oStruAK4:RemoveField('AK4_VERSAO')

oStruAK7:RemoveField('AK7_CODIGO')
oStruAK7:RemoveField('AK7_VERSAO')
oStruAK7:RemoveField('AK7_UNGEST')
oStruAK7:RemoveField('AK7_DIRET')
oStruAK7:RemoveField('AK7_PROGR')
oStruAK7:RemoveField('AK7_ANO')

oStruAKU:RemoveField('AKU_CODIGO')
oStruAKU:RemoveField('AKU_VERSAO')
oStruAKU:RemoveField('AKU_UNGEST')
oStruAKU:RemoveField('AKU_DIRET')
oStruAKU:RemoveField('AKU_PROGR')
oStruAKU:RemoveField('AKU_ANO')

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P297VERSAO
Gatilha a versão do PPA

@author TOTVS
@since 13/20/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297VERSAO(cCodigo)
Local cRet      := ""
Local oModel    := FWModelActive()
Local oMdlAK0   
Local cQry      := ""
Local cAliasAK0 := GetNextAlias()

Default cCodigo := ""

If Empty(cCodigo)
    oMdlAK0:= oModel:GetModel( 'AK0MASTER' )
    cCodigo   := oMdlAK0:GetValue('AK0_CODIGO')
EndIf
cQry := "SELECT MAX(AK0_VERSAO) VERSAO FROM "+RetSqlName("AK0") +" AK0" +CRLF
cQry += "WHERE AK0_FILIAL = '"+xFilial("AK0")+"'" +CRLF
cQry += "AND AK0_CODIGO= '"+cCodigo+"'" +CRLF
cQry += "AND AK0.D_E_L_E_T_ = ''"+CRLF

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasAK0,.T.,.F.)

//Incrementa saldo inicial
If (cAliasAK0)->(!EOF())
    cRet := SOMA1((cAliasAK0)->VERSAO )
EndIf

(cAliasAK0)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P297GATILHO
Realiza gatilho das descrições e campo virtuais da oStrVir para a inclusão

@author TOTVS
@since 13/20/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297GATILHO(cCampo)
Local cRet      := ""
Local oModel    := FWModelActive()
Local oMdlAK4   := oModel:GetModel( 'AK4DETAIL' )
Local oMdlVir   := oModel:GetModel( 'VIRDETAIL' )
Local oMdlAK7   := oModel:GetModel( 'AK7DETAIL' )
Local oMdlAKU   := oModel:GetModel( 'AKUDETAIL' )

Default cCampo := ""

If cCampo == "AK4_UNGEST"
    ALD->(dbSetOrder(1))
    If ALD->(dbSeek(xFilial("ALD")+oMdlAK4:GetValue('AK4_UNGEST')))
        cRet   := ALD->ALD_DESCRI
    EndIf
    //Atualiza campos virtuais do oMdlVir
    oMdlVir:LoadValue("AK7_UNGEST",oMdlAK4:GetValue('AK4_UNGEST'))
ElseIf cCampo == "AK4_DIRET"
    AMS->(dbSetOrder(1))
    If AMS->(dbSeek(xFilial("AMS")+oMdlAK4:GetValue('AK4_DIRET')))
        cRet   := AMS->AMS_DESDIR
    EndIf
    //Atualiza campos virtuais do oMdlVir
    oMdlVir:LoadValue("AK7_DIRET",oMdlAK4:GetValue('AK4_DIRET'))
ElseIf cCampo == "AK4_PROGR"
    AL0->(dbSetOrder(1))
    If AL0->(dbSeek(xFilial("AL0")+oMdlAK4:GetValue('AK4_PROGR')))
        cRet   := AL0->AL0_DESCRI
    EndIf
    //Atualiza campos virtuais do oMdlVir
    oMdlVir:LoadValue("AK7_PROGR",oMdlAK4:GetValue('AK4_PROGR'))
ElseIf cCampo == "AK4_ANO"
    cRet   := oMdlAK4:GetValue('AK4_ANO')
    //Atualiza campos virtuais do oMdlVir
    oMdlVir:LoadValue("AK7_ANO",oMdlAK4:GetValue('AK4_ANO'))
ElseIf cCampo == "AK7_INDIC"
    AMN->(dbSetOrder(1))
    If AMN->(dbSeek(xFilial("AMN")+oMdlAK7:GetValue('AK7_INDIC')))
        cRet   := AMN->AMN_DESCRI
    EndIf
ElseIf cCampo == "AKU_ACAO"
    ALE->(dbSetOrder(1))
    If ALE->(dbSeek(xFilial("ALE")+oMdlAKU:GetValue('AKU_ACAO')))
        cRet   := ALE->ALE_DESACA
    EndIf
ElseIf cCampo == "AKU_PROD" 
    ALZ->(dbSetOrder(1))
    If ALZ->(dbSeek(xFilial("ALZ")+oMdlAKU:GetValue('AKU_PROD')))
        cRet   := ALZ->ALZ_DESPRO
    EndIf
EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoAKUXB
Consulta padrao especifica para listar os campos de Função e Dubfunção

@author TOTVS
@since 09/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PcoAKUXB()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""

If cVar == 'M->AKU_FUNC'
	aTabRecDes := PcoAKUTbl("FC", "FC")
ElseIf cVar == 'M->AKU_SUBFUN'
    aTabRecDes := PcoAKUTbl("SB", "SB")
EndIf
If Empty(aTabRecDes)
	aAdd( aTabRecDes, { "NO_APLY", STR0017, 0})   //"Nao se Aplica"
EndIf

Define MsDialog oDlgCons Title STR0010 From 000, 000 To 450, 800 PIXEL //"Consulta de Tabelas"

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0011, STR0012 },,;    //"Codigo"##"Descrição"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aTabRecDes)
	oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } } 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

	@208,310 BUTTON STR0013 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
	@208,360 BUTTON STR0014 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

Activate MsDialog oDlgCons Centered

If nOpcA != 0 .And. aTabRecDes[nAt,3] > 0

	If nOpcA == 1 
		&cVar := aTabRecDes[nAt,1]
		&cVar += Space(nTam-Len(&cVar))
		A1H->( dbGoto(aTabRecDes[nAt,3]) )
		M->ALZ_UNIPRO := Alltrim( aTabRecDes[nAt,2] )
	EndIf

Else

		//recupera o que estava anteriormente
		&cVar := cCpoAnt
		lRet := .F.
		M->ALZ_UNIPRO := Space(Len(ALZ->ALZ_UNIPRO))
		Help(,, 'NO_TAB_UM',, STR0015, 1, 0)  // "A tabela de Unidade de Medida para Produtos do PPA não existe! Cadastrar tabela nos classificadores de Receitas/Despesas."

EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} PcoALZTbl
Retorna um array com codigo/descricao da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function PcoAKUTbl(cCodTab, cRadical)
Local aArea := GetArea()
Local cQuery := ""
Local aRetorno := {}
Local cAliasTmp := CriaTrab(,.F.)

cQuery += " SELECT A1H_ITECHV, A1H_CHVCNT, R_E_C_N_O_ RECTAB "
cQuery += " FROM " + RetSqlName("A1H")
cQuery += " WHERE "
cQuery +=  "      A1H_FILIAL = '"+xFilial("A1H")+"' " 
cQuery += "   AND A1H_CODTAB = '"+cCodTab+"' " 
cQuery += "   AND A1H_RADCHV =  '"+cRadical+"' " 
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY A1H_ITECHV "

cQuery := ChangeQuery( cQuery )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
While (cAliasTmp)->( ! Eof() )
	aAdd( aRetorno, { (cAliasTmp)->A1H_ITECHV, (cAliasTmp)->A1H_CHVCNT, (cAliasTmp)->RECTAB } )
	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->( DBCloseArea() )

RestArea(aArea)

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} P297VLD
Funçaõ chamada do Valide do campo AK0_ANOFIM para validar quantidade
de anos do ppa

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297VLD(oMdlAK0)
Local lRet      := .T.
Local nAnoIni   := VAL(oMdlAK0:GetValue("AK0_ANOINI"))
Local nAnoFim   := VAL(oMdlAK0:GetValue("AK0_ANOFIM"))

If  (nAnoFim - nAnoIni) != 3
    HELP(' ',1,"ANOPPA" ,,STR0016,1,0)//"O PPA deve ser realizado para 4 anos"
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P297ACTIVAT
Funçaõ para realizar validação antes de abrir a tela

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297ACTIVAT(oModel)
Local nOper     := oModel:getOperation()
Local lRet      := .T.

If (nOper == 4 .Or. nOper == 5) .And. AK0->AK0_STATUS <>"1"
    HELP(' ',1,"NAOALTERA" ,,STR0020,1,0)//"Só pode alterar ou excluir PPA com Status Em Elaboração"
    lRet := .F.
ElseIf __lGerRev .And. AK0->AK0_STATUS <> "2"
    HELP(' ',1,"NAOREVISA" ,,STR0021,1,0)//"Não é permitido realizar uma nova revisão se o PPA não estiver Ativo."
    lRet := .F.
EndIf

If lRet .And. __lGerRev
    If Lockbyname(xFilial("AK0")+AK0->AK0_CODIGO)
        __lLockRev:= .T. 
        __cCodPPA := AK0->AK0_CODIGO
        __cRevisao:= AK0->AK0_VERSAO 
    Else
        lRet := .F.
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P297PREVLD
Funçaõ para colocar status como 1 quando for gerar nova revisão

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297PREVLD(oModel)

Local lRet := .T.
Local oMdlAK0	:= oModel:GetModel("AK0MASTER")

If __lGerRev 
	oMdlAK0:LoadValue("AK0_STATUS","1")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P297INIPAD
Inicializador padrão do AK0_CODIGO 

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P297INIPAD(oModel)
Local cRet      :=  ""
// Local oMdlAK0   := oModel:GetModel( 'AK0MASTER' )
Local nOper     := oModel:getOperation()
// Local cVersao   := ""

If __lGerRev
    cRet := AK0->AK0_CODIGO
ElseIf nOper != 3
    cRet := AK0->AK0_CODIGO
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} P297EFETIVA
Funçaõ para não realizar a efetivação do PPA (AK0_STATUS=2)

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function P297EFETIVA()
Local aArea := GetArea()
Local aAreaAK0 := AK0->(GetArea())

//Realiza alteração de Status
Reclock("AK0",.F.)
AK0->AK0_STATUS := "2"
AK0->AK0_OBSERV := AK0->AK0_OBSERV + CRLF + DToC(ddatabase) +" "+ TIME() +STR0022+ Retcodusr() //" - Efetivação "
AK0->(Msunlock())

RestArea(aAreaAK0)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P297COMMIT
Realiza gravação do modelo

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function P297COMMIT(oModel)
Local lRet := .T.
Local nOper := oModel:getOperation()
Local aArea := GetArea()
Local aAreaAK0 := AK0->(GetArea())
Local oMdlAK0  := oModel:GetModel("AK0MASTER")
Local cObserv   := ""
Local cAcao := ""

//atualiza campo de observação
If nOper != 5 
    cObserv := oMdlAK0:GetValue("AK0_OBSERV")
    If __lGerRev
        cAcao := STR0023 //"- Nova Revisão"
        cObserv := ""
    ElseIf nOper == 3
        cAcao := STR0024 //"- Inclusão"
    ElseIf nOper == 4 
        cAcao := STR0025 //"Alteração"
    EndIf
    cObserv += cObserv +CRLF+  DToC(ddatabase) +" "+ TIME() +" - "+cAcao+" " + Retcodusr()
    oMdlAK0:LoadValue("AK0_OBSERV", cObserv)
EndIf

lRet:= FWFormCommit( oModel )

//Atualiza versão anterior para obsoleto AK0_STATUS = 3
If lRet .And. __lGerRev
    If AK0->(dbSeek(xFilial("AK0")+__cCodPPA+__cRevisao))
        Reclock("AK0",.F.)
        AK0->AK0_STATUS := "3"
        AK0->(Msunlock())
    EndIf
EndIf

If __lLockRev
    Unlockbyname(xFilial("AK0")+AK0->AK0_CODIGO) 
EndIf

//Limpa variaveis staticas
__cCodPPA   := .F.
__lGerRev   := .F.
__cRevisao  := ""

RestArea(aAreaAK0)
RestArea(aArea)
Return lRet


Function P297GERREV()

__lGerRev := .T.

FWExecView(STR0018,'PCOA297', 9, , { || .T. }, , ,) //'Gerar Revisão'

__lGerRev := .F.
Return
/*
Function P297AUTO()
//Grid AK4
//Inclui Unidade Gestora - ALD
If AliasInDic("ALD") .And. !(ALD->(dbSeek(xFilial("ALD")+010100)))
    Reclock("ALD",.T.)
    ALD->ALD_FILIAL := xFilial("ALD")
    ALD->ALD_CODIGO := "010100"
    ALD->ALD_DESCRI := "CAMARA MUNICIPAL              "
    ALD->ALD_TPUNID := "1"
    ALD->ALD_GESSUP := ""
    ALD->(Msunlock())
EndIf

//Inclui DIretriz - AM0
If AliasInDic("AM0") .And. !(AM0->(dbSeek(xFilial("AM0")+06)))
    Reclock("AM0",.T.)
    AM0->AM0_FILIAL := xFilial("AM0")
    AM0->AM0_CODFRC := "06"
    AM0->AM0_DESCFR := "OUTRAS FONTES DE RECURSOS"
    AM0->AM0_ESPEFR := "Recursos não enquadrados em especificações próprias;"                                                                                                                     
    AM0->AM0_TIPREC := "2"
    AM0->(Msunlock())
EndIf

//Inclui Programa - AL0
If AliasInDic("AL0") .And. !(AM0->(dbSeek(xFilial("AL0")+001)))
    Reclock("AL0",.T.)
    AL0->AL0_FILIAL := xFilial("AL0")
    AL0->AL0_CODIGO := "001"
    AL0->AL0_DESCRI := "PROCESSO LEGISLATIVO"
    AL0->AL0_OBJET  := "Programa Processo Legislativo."
    AL0->AL0_TIPO   := "2"
    AL0->AL0_STATUS := "1"
    AL0->(Msunlock())
EndIf

//Grid AK7
//Inclui Indicadores - AMN
If AliasInDic("AMN") .And. !(AM0->(dbSeek(xFilial("AMN")+00101)))
    Reclock("AMN",.T.)  
    AMN->AMN_FILIAL := XFilial("AMN")
    AMN->AMN_CODIGO := "00101"
    AMN->AMN_DESCRI := "Quantidade de normas juridicas criadas"
    AMN->AMN_UM     := "Un" 
    AMN->AMN_UNDESC := "Unidade"
    //AMN->AMN_UNITAB :=
    //AMN->AMN_UNIRAD := 
    AMN->(Msunlock())
EndIf
//Grid AKU
//Inclui Ação - ALE
Return

*/