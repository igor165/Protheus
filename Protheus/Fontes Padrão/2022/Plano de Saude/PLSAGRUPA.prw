#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'plsagrupa.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAGRUPA
agrupador de serviços
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSAGRUPA()

Local oBrowse
LOCAL nFor := 0
LOCAL aAlias := {"B6B", "B6C", "B6D"}
LOCAL cAlias := ""

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B6B')
oBrowse:SetDescription(FunDesc())

oBrowse:Activate()

//	Fecha as tabelas utilizadas na rotina
FOR nFor := 1 TO LEN(aAlias)
	IF SELECT(aAlias[nFor]) > 0
		cAlias := aAlias[nFor]
		( cAlias )->( DbCloseArea() )
	ENDIF
NEXT

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
função para criar o menu da tela
agrupador de serviços
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static function MenuDef()

Local aRotina := {}

Add Option aRotina Title STR0001  Action 'VIEWDEF.PLSAGRUPA' Operation 2 Access 0
Add Option aRotina Title STR0002    Action 'VIEWDEF.PLSAGRUPA' Operation 3 Access 0
Add Option aRotina Title STR0003    Action 'VIEWDEF.PLSAGRUPA' Operation 4 Access 0
Add Option aRotina Title STR0004    Action 'VIEWDEF.PLSAGRUPA' Operation 5 Access 0
Add Option aRotina Title STR0005   Action 'VIEWDEF.PLSAGRUPA' Operation 8 Access 0
Add Option aRotina Title STR0006     Action 'VIEWDEF.PLSAGRUPA' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
definição do modelo de Dados
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static function ModelDef()
local oModel // Modelo de dados construído
local oStrB6B:= FWFormStruct(1,'B6B')// Cria as estruturas a serem usadas no Modelo de Dados
local oStrB6C:= FWFormStruct(1,'B6C')// Cria as estruturas a serem usadas no Modelo de Dados
local oStrB6D:= FWFormStruct(1,'B6D')

oModel := MPFormModel():New( 'PLSAGRUPA' , , {|| PLSVLDAGR(oModel, "B6B") } , , {|| PLSAGRUSXE() } ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB6B',/*cOwner*/,oStrB6B)  // adiciona ao modelo um componente de formulário

oModel:AddGrid('B6CDetail', 'MasterB6B', oStrB6C) // adiciona ao modelo uma componente de grid
oModel:AddGrid('B6DDetail', 'MasterB6B', oStrB6D) // adiciona ao modelo uma componente de grid

oModel:SetRelation( 'B6CDetail', { ;
	{ 'B6C_FILIAL'	, 'xFilial("B6C")' },;
	{ 'B6C_CODINT'	, 'B6B_CODINT' 		},;
	{ 'B6C_CODIGO'	, 'B6B_CODIGO'		} },;
	B6C->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:SetRelation( 'B6DDetail', { ;
	{ 'B6D_FILIAL'	, 'xFilial("B6D")' },;
	{ 'B6D_CODINT'	, 'B6B_CODINT' 		},;
	{ 'B6D_CODIGO'	, 'B6B_CODIGO'		} },;
	B6D->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:GetModel( 'B6CDetail' ):SetUniqueLine( { 'B6C_CODPAD', 'B6C_CODPRO'} ) // nao deixa cadastrar dois registros iguais
oModel:GetModel( 'B6DDetail' ):SetUniqueLine( { 'B6D_CODRDA' } ) // nao deixa cadastrar dois registros iguais

oModel:GetModel('MasterB6B'):SetDescription(STR0007) // adiciona a descrição do Modelo de Dados

//Define Chave primária do Model
oModel:SetPrimaryKey( {"B6B_FILIAL", "B6B_CODINT", "B6B_CODIGO", "B6B_CODTAB", "B6B_CODPRO"} )

Return oModel // Retorna o Modelo de dados

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
definição do interface
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
local oView  // Interface de visualização construída
local oModel := FWLoadModel( 'PLSAGRUPA' ) // Cria as estruturas a serem usadas na View
local oStrB6B:= FWFormStruct(2, 'B6B', { |cCampo| PLSOCULAGR('B6B', cCampo) } )
local oStrB6C:= FWFormStruct(2, 'B6C', { |cCampo| PLSOCULAGR('B6C', cCampo) })
local oStrB6D:= FWFormStruct(2, 'B6D', { |cCampo| PLSOCULAGR('B6D', cCampo) })

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB6B' , oStrB6B,'MasterB6B' ) // adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid( 'ViewB6C' , oStrB6C,'B6CDetail' ) // adiciona no nosso view um controle do tipo grid
oView:AddGrid( 'ViewB6D' , oStrB6D,'B6DDetail' ) // adiciona no nosso view um controle do tipo grid

oView:CreateHorizontalBox( 'CABECALHO' , 30,,,, ) // cria um "box" horizontal para receber os campos do cabeçalho
oView:CreateHorizontalBox( 'ABAS', 70,,,,  ) // cria um "box" horizontal para receber as abas
oView:CreateHorizontalBox( 'PROCEDIMENTO', 100,,, 'ABA', 'T1'  ) // Cria um "box" horizontal para receber o grid de procedimentos
oView:CreateHorizontalBox( 'PRESTADOR', 100,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber o grid de procedimentos

oView:EnableTitleView( 'ViewB6B', STR0008) // atribui título para a View

oView:SetViewProperty("ViewB6C","GRIDFILTER",{.T.})
oView:SetViewProperty("ViewB6C","GRIDSEEK",{.T.})

oView:SetViewProperty("ViewB6D","GRIDFILTER",{.T.})
oView:SetViewProperty("ViewB6D","GRIDSEEK",{.T.})

oView:SetOwnerView('ViewB6B','CABECALHO') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB6C','PROCEDIMENTO') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB6D','PRESTADOR') // Relaciona o identificador (ID) da View com o "box" para exibição

oView:CreateFolder( 'ABA', 'ABAS' ) // cria estrutura de abas

oView:AddSheet( 'ABA', 'T1', STR0009) // cria primeira aba (tabela B6C)
oView:AddSheet( 'ABA', 'T2', STR0010) // cria segunda aba (tabela B6D)

Return oView // Retorna o objeto de View criado

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSOCULAGR
tratamento para separar os campos que devem ser ocultados na view
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSOCULAGR (cAlias, cCampo)

local   lRet	:= .t.
default cAlias := ""
default cCampo := ""

if cAlias == "B6B"
    If cCampo == "B6B_CODINT"
        lRet := .F.
    EndIf
elseif cAlias == "B6C"
    If cCampo == "B6C_CODINT"
        lRet := .F.
    EndIf

    If cCampo == "B6C_CODIGO"
        lRet := .F.
    EndIf
elseif cAlias == "B6D"
    If cCampo == "B6D_CODINT"
        lRet := .F.
    EndIf

    If cCampo == "B6D_CODIGO"
        lRet := .F.
    EndIf
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAGRUSXE
função dá rollback no sxe reservado
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSAGRUSXE()

//somente para a operação de inclusão
if INCLUI
	ROLLBACKSXE()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDB6C
valida o codpad e procedimento no grid (tabela B6C)
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSVLDB6C(cCampo)

local oModel 	:= FWModelActive()
local oGrid 	:= oModel:GetModel('B6CDetail')
local cCodPad 	:= oGrid:GetValue('B6C_CODPAD',oGrid:nLine)
local cCodPro 	:= oGrid:GetValue('B6C_CODPRO',oGrid:nLine)
local cProDes   := ""
local lRet      := .f.
local lPro      := .f.   
local lExi      := .f.

default cCampo  := ""

if cCampo == "CODPAD"
    lRet := ExistCpo("BR4",cCodPad) // valida se o codigo da tabela existe
    if !empty(cCodPro)
        oGrid:LoadValue('B6C_CODPRO',"")
        oGrid:LoadValue('B6C_DESPRO',"")
    endif
elseif cCampo == "CODPRO"
    lPro  := ExistCpo("BR8",cCodPad+cCodPro,1) // valida se o procedimento existe
    lExi  := PLSVLDAGR(oModel, 'B6C', {{cCodPad, cCodPro}}) // valida se o procedimento foi vinculado a outro cabeçalho

    if lPro .and. lExi
        lRet := .t.
        cProDes := Posicione("BR8",1,XFILIAL("BR8")+cCodPad+cCodPro,"BR8_DESCRI")
        oGrid:LoadValue('B6C_DESPRO', cProDes)
    endif
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPROB6C
consulta padrão do campo procedimento (tabela B6C)
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSPROB6C()

local oModel 	:= FWModelActive()
local oGrid 	:= oModel:GetModel('B6CDetail')
local cCodPad 	:= oGrid:GetValue('B6C_CODPAD',oGrid:nLine)
local lRet      := .f.

lRet := PLSPESPROC(cCodPad,.T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDB6D
valida a rda no grid (tabela B6D)
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSVLDB6D()

local oModel 	:= FWModelActive()
local oGrid 	:= oModel:GetModel('B6DDetail')
local cCodRda 	:= oGrid:GetValue('B6D_CODRDA',oGrid:nLine)
local cNomRda   := ""
local lRet      := .f.
local lRda      := .f.
local lExi      := .f.

lRda := ExistCpo("BAU",cCodRda,1) // valida se o codigo existe
lExi := PLSVLDAGR(oModel, 'B6D', {cCodRda}) // valida se o codigo ja esta vinculado a outro cabeçalho

if lRda .and. lExi
    lRet := .t.
    cNomRda := Posicione("BAU",1,XFILIAL("BAU")+cCodRda,"BAU_NOME")
    oGrid:SetValue('B6D_NOMRDA', cNomRda)
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAGRPRE
inicializador padrão dos campos de descrição (virtuais)
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSAGRPRE(cAlias)

local oModel 	:= FWModelActive()
local nOpc	    := oModel:GetOperation()
local oGrid 	:= nil
local cCod1 	:= ""
local cCod2     := ""
local cRet      := ""
default cAlias  := ""

If (nOpc != 3)
    if cAlias == "B6B"
        oGrid 	:= oModel:GetModel('MasterB6B')
        cCod1   := oGrid:GetValue('B6B_CODPAD')
        cCod2   := oGrid:GetValue('B6B_CODPRO')

        BR8->(DBSetOrder(1))
        if BR8->(MsSeek(xFilial("BR8")+cCod1+cCod2))
            cRet := BR8->BR8_DESCRI
        endif
    elseif cAlias == "B6C"
        cCod1   := B6C->B6C_CODPAD
        cCod2   := B6C->B6C_CODPRO

        BR8->(DBSetOrder(1))
        if BR8->(MsSeek(xFilial("BR8")+cCod1+cCod2))
            cRet := BR8->BR8_DESCRI
        endif
    elseif cAlias == "B6D"
        cCod1   := B6D->B6D_CODRDA

        BAU->(DBSetOrder(1))
        if BAU->(MsSeek(xFilial("BAU")+cCod1))
            cRet := BAU->BAU_NOME
        endif
    endif
endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDAGR
valida se já existe B6D_CORDA ou B6C_CODPAD+B6C_CODPRO vinculado em cabeçalhos
semelhantes (B6B_CODPAD+B6B_CODPRO)
utilizado ao:
alterar B6C_CODPRO
alterar B6D_CODRDA
botão confirmar
@author pablo alipio
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSVLDAGR(oModel, cAlias, aValor)

local lRet    := .t.
local cHead   := ""
local cMsg    := ""
local cSql    := ""
local cCodInt := oModel:GetModel("MasterB6B"):getValue("B6B_CODINT")
local cCodigo := oModel:GetModel("MasterB6B"):getValue("B6B_CODIGO")
local cCodPad := oModel:GetModel("MasterB6B"):getValue("B6B_CODPAD")
local cCodPro := oModel:GetModel("MasterB6B"):getValue("B6B_CODPRO")
local nOpc	  := oModel:GetOperation()
Local oB6C    := oModel:GetModel('B6CDetail')
local oB6D    := oModel:GetModel('B6DDetail')
local aCodPro := {}
local aCodRda := {}
local aValorB6C := {}
local aValorB6D := {}
local nI      := 1
local nY      := 1

default oModel := FWModelActive()
default cAlias := ""
default aValor := {}

If (nOpc == 3 .or. nOpc == 4) //inclusão ou alteração
    B6B->(dbSetOrder(2)) // B6B_FILIAL+B6B_CODINT+B6B_CODPAD+B6B_CODPRO
    if cAlias == "B6B" // botão confirmar
        // preenche os arrays com todos os procedimentos e rdas
        for nI := 1 to oB6C:length()
            oB6C:GoLine(nI)
            aadd(aValorB6C, {oB6C:getValue("B6C_CODPAD"), oB6C:getValue("B6C_CODPRO")})
        next
        for nI := 1 to oB6D:length()
            oB6D:GoLine(nI)
            aadd(aValorB6D, oB6D:getValue("B6D_CODRDA"))
        next
    endif

    if (cAlias == 'B6D' .or. cAlias == "B6B") .and. ( len(aValor) > 0 .or. len(aValorB6D))
        // verifica se já existe B6D_CORDA vinculado em cabeçalhos semelhantes (B6B_CODPAD+B6B_CODPRO)
        cSql := " SELECT B6D_CODRDA FROM  " + RetSqlName("B6B") + " B6B "
        cSql += " INNER JOIN " + RetSqlName("B6D") + " B6D ON "
        cSql += " B6B_CODINT = B6D_CODINT AND "
        cSql += " B6B_CODIGO = B6D_CODIGO AND "
        if (cAlias == "B6B") // é necessário incluir todos os códigos na query utilizando for
            cSql += " ( "
            for nY := 1 to len(aValorB6D)
                cSql += " B6D_CODRDA = '" + aValorB6D[nY] + "' OR"
            next
            cSql := left(cSql, len(cSql)-2) // utilizado para tirar o ultimo "OR"
            cSql += " ) "
        else // valid no campo do grid, vem apenas um procedimento para validar
            cSql += " B6D_CODRDA = '" + aValor[nY] + "' "
        endif
        
        cSql += " AND B6D.D_E_L_E_T_ = ' ' " 
        cSql += " WHERE B6B_FILIAL = '" + xFilial("B6B") + "' AND " 
        cSql += " B6B_CODINT = '" + cCodInt + "' AND " 
        cSql += " B6B_CODIGO != '" + cCodigo + "'AND "
        cSql += " B6B_CODPAD = '" + cCodPad + "' AND "
        cSql += " B6B_CODPRO = '" + cCodPro + "' AND "
        cSql += " B6B.D_E_L_E_T_ = ' ' "
        cSql += " GROUP BY B6D_CODIGO, B6D_CODRDA "

        cSql := ChangeQuery(cSql)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB6D",.F.,.T.)

        while TrbB6D->(!Eof())
            lRet := .f.
            aadd(aCodRda, TrbB6D->B6D_CODRDA)
            TrbB6D->(DbSkip())
        enddo
        TrbB6D->(DbCloseArea())

    endif

    if !lRet
        cMsg := STR0011 + chr(13)
        if (len(aCodRda) > 0)
            cMsg += STR0010 + ": " + chr(13)
            for nI := 1 to len(aCodRda)
                cMsg += aCodRda[nI] + chr(13)
            next
        endif

        if (len(aCodPro) > 0)
            cMsg += STR0009 + ": " + chr(13)
            for nI := 1 to len(aCodPro)
                cMsg += aCodPro[nI] + chr(13)
            next
        endif 

        Help( ,, 'HELP', , cMsg, 1, 0)        
    endif

EndIf

Return (lRet)