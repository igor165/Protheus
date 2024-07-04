//Cadastro de beneficiários do grupo
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA804.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA361
Cadastro dos beneficiários do grupo
@author Oscar Zanin
@since 03/2021
@version P12.
/*/
//-------------------------------------------------------------------
Function PLSA361()
Local oBrowse
Local cFiltro := "@(B9U_FILIAL = '" + xFilial("B9U") + "' AND B9U_CODGRU = '" + B97->B97_CODIGO + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9U')
oBrowse:SetDescription('Beneficiários do grupo')
oBrowse:setMainProc("PLSA361")
oBrowse:setMenudef("PLSA361")
oBrowse:setFilterDefault(cFiltro)
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} menudef

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA361' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'   */ Action 'VIEWDEF.PLSA361' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'   */ Action 'VIEWDEF.PLSA361' Operation 4 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'  */ Action 'VIEWDEF.PLSA361' Operation 8 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} modeldef

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9U:= FWFormStruct(1,'B9U')

oModel := MPFormModel():New( 'PLSA361', , {|oModel| PLSA361OK(oModel) }, {|oModel| PLSA361CMT(oModel)} )		//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB9U',/*cOwner*/,oStrB9U)								//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB9U')
///oModel:SetDescription(FunDesc())												// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B9U_FILIAL", "B9U_CODGRU", "B9U_SEQUEN"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9U:= FWFormStruct(2, 'B9U', {|cCampo| PLSCmp361(cCampo) })

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados será utilizado
oView:AddField('FrmB9U' , oStrB9U,'MasterB9U' ) 				// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9U', 100)						// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB9U','BxB9U')							// Associa a View ao Box
//oStrB9U:SetProperty( 'B9U_VIFFIM', MVC_VIEW_CANCHANGE, )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA361OK
Validação ao confirmar tela
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA361OK(oModel)
LOCAL lRet     		:= .T.
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9U' )
LOCAL nOpc				:= oModel:GetOperation()
Local cMatric := ""
Local aArea := B9U->(getArea())
Local cMsg := ""

If nOpc == 3
    cMatric := oModelDetail:getValue("B9U_MATRIC")
    B9U->(dbsetOrder(2))
    If B9U->(MsSeek( xFilial("B9U") + B97->B97_CODIGO + cMatric))
        While !(B9U->(eoF())) .AND. xFilial("B9U") + B97->B97_CODIGO + cMatric == B9U->(B9U_FILIAL+B9U_CODGRU+B9U_MATRIC)
            If empty(B9U->B9U_VIGFIM)
                lRet := .F.
                cMsg := "O beneficiário já está cadastrado no grupo sem fechamento da vigência anterior"
                exit
            endif
            If oModelDetail:getValue("B9U_VIGINI") < B9U->B9U_VIGFIM .AND. B9U->B9U_VIGINI <> B9U->B9U_VIGFIM
                lRet := .F.
                cMsg := "A vigência inicial é inferior à data de fechamento de vigência de outro cadastro deste beneficiário no grupo"
                exit
            endif
            B9U->(dbskip())
        endDo
    endif
    restarea(aarea)
    oModelDetail:SetValue('B9U_SEQUEN', PLSseq361())
endIf

if !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCMP361
Retira campos da view
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSCmp361(cCampo)

Local lRet := .T.

If cCampo == "B9U_CODGRU"
    lRet := .F.
endif

If cCampo == "B9U_SEQUEN"
    lRet := .F.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSseq361
Gera o sequencial
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSseq361()

Local cRet := ""
Local cSql := ""

cSql += " Select MAX(B9U_SEQUEN) ULTSEQ From " + RetSqlName("B9U")
cSql += " Where "
cSql += " B9U_FILIAL = '" + xFilial("B9U") + "' AND "
cSql += " B9U_CODGRU = '" + B97->B97_CODIGO + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"SEEKSEQ",.f.,.t.)

If !(SEEKSEQ->(EoF()))
    cRet := Soma1(SEEKSEQ->ULTSEQ)
else
    cRet := "00001"
endIf
SEEKSEQ->(dbclosearea())

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvmat361
Valida matrícula
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvmat361()

Local lRet := .F.
Local oModel   := FWModelActive() 
Local cMatModel := oModel:getModel("MasterB9U"):getValue("B9U_MATRIC")
Local cMsg := "Matrícula inválida"

BA1->(dbSetOrder(2))
If BA1->(msSeek(xFilial("BA1")+cMatModel)) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == alltrim(cMatModel) //[Verifica se existe com seek] .and. [Verifica se é exatamente o mesmo número]
    lRet := .T.
Endif

If lRet
    lRet := !PlChHiBlo("BCA", Date(), substr(cMatModel,1,14), substr(cMatModel,15,2), /*dDatIniBlo*/, /*dDatFinBlo*/, /*cMotBlo*/, /*lConsTole*/, /*aVgDatBlo*/, /*lConDatBCA*/.T., /*cHora*/, /*cHorPar*/) 
    if !lRet
        cMsg := "Beneficiário bloqueado"
    endif
endif

if !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvdt361
Valida datas
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvdt361(nTipo)

Local lRet := .F.
Local oModel   := FWModelActive() 
Local dVigIni := oModel:getModel("MasterB9U"):getValue("B9U_VIGINI")
Local dVigFim := oModel:getModel("MasterB9U"):getValue("B9U_VIGFIM")
Local cMsg := "Data informada inválida"
Default nTipo := 1

If nTipo == 1
    lRet := .T.
    oModel:getModel("MasterB9U"):SetValue("B9U_DATINC", Date())
elseif ntipo == 2
    if empty(oModel:getModel("MasterB9U"):getValue("B9U_VIGFIM"))
        lRet := .T.
    else
        lRet := !(empty(oModel:getModel("MasterB9U"):getValue("B9U_VIGINI"))) .AND. dVigFim >= dVigIni
        oModel:getModel("MasterB9U"):SetValue("B9U_DATBLQ", Date())
    endif
endif

if !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLScount361
conta até 361.. não.. pera.. faz a contagem dos beneficiários não bloqueados
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLScount361()

Local nRet      := 0
Local cSql      := ""
Local lCompAtu  := B97->(fieldPos("B97_INICIO")) > 0 .AND. B97->B97_INICIO == '1'
local cAliB9U   := RetSqlName("B9U")

cSql += " Select count(1) CNTTOT From " + cAliB9U
cSql += " Where "
cSql += " B9U_FILIAL = '" + xFilial("B9U") + "' AND "
cSql += " B9U_CODGRU = '" + B97->B97_CODIGO + "' AND "
if !lCompAtu
    cSql += " ( B9U_VIGINI <= '" + DtoS(LastDay(LastDay(dDatabase)+1)) + "' ) AND "
    cSql += " ( B9U_VIGFIM = '        ' OR B9U_VIGFIM > '" + DtoS(LastDay(LastDay(dDatabase)+1)) + "' ) AND "
else
    cSql += " ( B9U_VIGINI <= '" + DtoS(LastDay(dDatabase)) + "' ) AND "
    cSql += " ( B9U_VIGFIM = '        ' OR B9U_VIGFIM >= '" + DtoS(FirstDay(dDatabase)-1) + "' ) AND "
endif
cSql += " D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"CNTGRP",.f.,.t.)

If !(CNTGRP->(EoF()))
    nRet := CNTGRP->CNTTOT
endIf
CNTGRP->(dbclosearea())

return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA361CMT
função do commit para atualizar o total de beneficiários
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSA361CMT(oModel)

Local lRet := .F.

If oModel:VldData()
    FWFormCommit( oModel )
    B97->(reclock("B97",.F.))
        B97->B97_TOTBEN := PLScount361()
    B97->(MsUnlock())
    lRet := .T.
endif

return lRet
