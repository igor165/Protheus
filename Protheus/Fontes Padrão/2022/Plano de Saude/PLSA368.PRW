#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSA368.CH'

Static lAutoSt := .F.

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA368
Cadastro do Contrato Preestabelecido, firmado entre Operadora e RDA
@since 10/2019
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA368(lAutomat)
Local oBrowse	:= nil
local cFiltro	:= ""
default lAutomat := .f.
_SetOwnerPrvt("lAutoma", .f. ) //Private para automação e demais funções
lAutoSt := .F.

If !FWAliasInDic("B94") 	
	If !lAutomat
		aviso( "Atenção","Para a execução da rotina, é necessária a criação da tabela B94." ,{ "Ok" }, 2 )
		return
	Else
		return .F.
	EndIf
EndIf

cFiltro := "@(B8O_FILIAL = '" + xFilial("B8O") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B8O')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //Rede de Atendimento X Contrato Preestabelecido
oBrowse:SetMenuDef('PLSA368')	
if !lAutomat
    oBrowse:Activate()
endif

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 10/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA368' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA368" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA368" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  "Gerar crédito"	Action 'PLSgera368()' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSA368"	Operation 5 Access 0  //Excluir
Add Option aRotina Title  "Histórico de créditos"	Action 'PLSsbgq368()' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  "Eventos Relacionados"	Action 'PLSsB8P368()' 	Operation 2 Access 0  //Visualizar
//opções para acompanhamento do contrato, foi acordado que vão ser implementação futura
//Add Option aRotina Title  "Acompanhamento RDA"	Action 'PLSZStart(1)' 	Operation 2 Access 0  //Visualizar
//Add Option aRotina Title  "Dados Benef."	Action 'PLSZStart(2)' 	Operation 2 Access 0  //Visualizar

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil 
Local oStrB8O	:= FWFormStruct(1,'B8O')
Local oStrB94   := FWFormStruct(1,'B94')
local aGatl     := {}

oModel := MPFormModel():New( 'PLSA368', ,  { || PLSCADOK(oModel) }  ) 

aGatl := FwStruTrigger('B8O_CODRDA', 'B8O_NOMRDA', 'BAU->BAU_NOME', .T., 'BAU', 1,'xFilial("BAU") + M->B8O_CODRDA','!empty(M->B8O_CODRDA)')
oStrB8O:AddTrigger( aGatl[1], aGatl[2], aGatl[3], aGatl[4] )

oModel:AddFields('B8OMASTER', /*cOwner*/, oStrB8O )
oModel:AddGrid('B94Detail', 'B8OMASTER', oStrB94,{ |oModelGrid, nLine, cAction, cField| PLSvdel368(oModelGrid, nLine, cAction, cField) })

oStrB8O:setProperty( "B8O_CODRDA" , MODEL_FIELD_OBRIGAT, .t. )    
oStrB8O:setProperty( "B8O_CODINT" , MODEL_FIELD_WHEN , { || oModel:GetOperation() == MODEL_OPERATION_INSERT } )
oStrB8O:setProperty( "B8O_CODRDA" , MODEL_FIELD_WHEN , { || oModel:GetOperation() == MODEL_OPERATION_INSERT } ) 
oStrB8O:setProperty( "B8O_IDCOPR" , MODEL_FIELD_WHEN , { || oModel:GetOperation() == MODEL_OPERATION_INSERT .and. !empty(oModel:getModel("B8OMASTER"):getValue("B8O_CODRDA")) } )       

oModel:SetRelation( 'B94Detail', { ;
    { 'B94_FILIAL'	, 'xFilial( "B94" )' },;
    { 'B94_CODRDA'	, 'B8O_CODRDA'		 },;
    { 'B94_IDCOPR'	, 'B8O_IDCOPR'       }},;
    B94->( IndexKey(1) ) )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA368' )
Local oStrB8O	:= FWFormStruct(2,'B8O')
Local oStrB94	:= FWFormStruct(2,'B94', {|cCampo| PLS368vCMP(cCampo) })

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_B8O', oStrB8O, 'B8OMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 40)
oView:CreateHorizontalBox( 'INFERIOR', 60)
oView:AddGrid( 'ViewB94', oStrB94, 'B94Detail' )
oView:AddIncrementField( 'ViewB94' , 'B9Q_SEQUEN')

oView:EnableTitleView('ViewB94',"Grupos vinculados")
oView:SetOwnerView('VIEW_B8O', 'SUPERIOR' )
oView:SetOwnerView('ViewB94', 'INFERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclusão do Registro.
@since 10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADOK(oModel)
Local lRet		:= .T.
local cSql      := ""
local lOperIns  := iif(oModel:nOperation == MODEL_OPERATION_INSERT, .t., .f.) 
Local noperatin := oModel:getoperation()
Local nI := 1

if lOperIns
    cSql := " SELECT B8O_FILIAL FROM " + RetSqlName("B8O") 
    cSql += " WHERE B8O_FILIAL = '"    + xFilial("B8O") + "' "
    cSql += " AND B8O_CODINT = '"      + oModel:getModel("B8OMASTER"):getValue("B8O_CODINT") + "' "
    cSql += " AND B8O_CODRDA = '"      + oModel:getModel("B8OMASTER"):getValue("B8O_CODRDA") + "' "
    cSql += " AND B8O_IDCOPR = '"      + oModel:getModel("B8OMASTER"):getValue("B8O_IDCOPR") + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"VerRepet",.f.,.t.)

    if ( !VerRepet->(eof()) )
        lRet := .f.
        Help(nil, nil , STR0007, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {""} ) //Atenção / Já existe esse número de contrato para a mesma RDA e Operadora. Verifique as informações.
    endif 
    VerRepet->(dbclosearea())
endif    

If lRet .AND. (noperatin == 3 .OR. noperatin == 4)
    If oModel:getModel("B8OMASTER"):getValue("B8O_TIPCAL") == '1'
        For nI := 1 To oModel:getModel("B94Detail"):length()
            oModel:getModel("B94Detail"):goline(nI)
            lRet := !(empty(oModel:getModel("B94Detail"):getValue("B94_CODLAN")))
            if !lRet
                Help(nil, nil , STR0007, nil, "Para cotratos com valor calculado, é necessário preencher o campo B94_CODLAN com um código de lançamento do crédito, para todos os grupos vinculados", 1, 0, nil, nil, nil, nil, nil, {""} )
                exit
            endif
        next
    else
        lRet := !(empty(oModel:getModel("B8OMASTER"):getValue("B8O_CODLAN")))
        if !lRet
            Help(nil, nil , STR0007, nil, "Para cotratos com valor diferente de calculado, é necessário preencher o campo B8O_CODLAN com um código de lançamento do crédito", 1, 0, nil, nil, nil, nil, nil, {""} )
        endif
    endif
endif

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsVldB8P
Carrega a descricao do procedimento informado 
@since 10/2019
@version P12 
/*/
//------------------------------------------------------------------------------------------
Function PLB8OPRO()
Local lRet      := .T.
local oModel    := nil
local oModelLin := nil  
local nLine     := 0

oModel     := FWModelActive()
oModelLin  := oModel:GetModel("B8PDetail")
nLine  	   := oModelLin:GetLine()

If ReadVar() == "M->B8P_CODPRO"
	If !ExistCPO("BR8", FwFldGet('B8P_CODPAD', nLine) + M->B8P_CODPRO, 1)
        lRet := .F.
    else
        oModel:getModel("B8PDetail"):loadvalue("B8P_DESPRO", Posicione("BR8",1,xFilial("BR8") + FwFldGet('B8P_CODPAD',nLine) + FwFldGet('B8P_CODPRO',nLine),"BR8_DESCRI"))
	Endif
ElseIf ReadVar() == "M->B8P_CODPAD"
	If !ExistCPO("BR4", M->B8P_CODPAD, 1)
		lRet := .F.
    endif 
    FwFldPut("B8P_CODPRO", "", nLine,,.t.,.t.)    
Endif

Return lRet
  

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLB8OPesq
Consulta especifica de tipos de tabela  
@since 10/2019
@version P12 
/*/
//------------------------------------------------------------------------------------------
Function PLB8OPesq()
Local lRet    := .F.
local oModel    := nil
local oModelLin := nil  

oModel     := FWModelActive()
oModelLin  := oModel:GetModel("MasterB8P")

iif( !lAutoma,  lRet := PLSPESPROC(oModelLin:getValue("B8P_CODPAD"),.f.),  lRet := .t. )
  
Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerSitGrid
Atualizar as informações do grid, de acordo com a mudanças ocorridas no form pai.
@since 10/2019
@version P12 
/*/
//---------------------------------------------------------------------------------------
static function VerSitGrid(lVazCon, oModel)
local oB8P      := oModel:getmodel("B8PDetail")
local oView     := FWViewActive()
local nI        := 0
if !lVazCon
	For nI := 1 to oB8P:Length()
        oB8P:GoLine(nI)
        oB8P:loadValue("B8P_CODINT", oModel:getModel("B8OMASTER"):getValue("B8O_CODINT"))
        oB8P:loadValue("B8P_CODRDA", oModel:getModel("B8OMASTER"):getValue("B8O_CODRDA"))
        oB8P:loadValue("B8P_IDCOPR", oModel:getModel("B8OMASTER"):getValue("B8O_IDCOPR"))       
    Next
    if !lAutoma
        oView:Refresh()
    endif    
endif    

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} 
filtro de cmapos B94
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLS368vCMP(cCampo)

Local lRet := .T.

If cCampo == "B94_CODRDA"
    lRet := .F.
endif

If cCampo == "B94_IDCOPR"
    lRet := .F.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvgrp368
valida a inclusão de um grupo
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvgrp368()
Local lRet := .F.
Local oModel     := FWModelActive()
Local cMsg := "Verifique as informações cadastradas"


B97->(dbsetOrder(1))

If B97->(MsSeek(xFilial("B97")+oModel:GetModel("B94Detail"):getValue("B94_CODGRU"))) //.AND. B97->B97_TOTBEN > 0
    If PLScdup368(.T.)
        lRet := .T.
    else
        cMsg := "Grupo já cadastrado e com vigêcia em aberto"
    endif
endif

If lRet
    oModel:GetModel("B94Detail"):setValue("B94_DESGRU", B97->B97_DESCRI)
    oModel:GetModel("B94Detail"):setValue("B94_QTDGRU", B97->B97_TOTBEN)
    If oModel:GetModel("B8OMASTER"):getValue("B8O_TIPCAL") == "1"
        PLSvcal368()
    endif
endif

If !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvcal368
faz o cálculo do valor de contrato
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvcal368()

Local lRet := .T.
Local oModel     := FWModelActive()
Local oModelLin  := oModel:GetModel("B94Detail")
Local nI := 0
Local nValcont := 0
Local dVigIni := ddatabase//oModel:getModel("MasterB9U"):getValue("B9U_VIGINI")
Local dVigFim := ddatabase//oModel:getModel("MasterB9U"):getValue("B9U_VIGFIM")
Local dDataNext := LastDay(ddatabase) + 1
Local nLinha := oModelLin:GetLine()

If oModel:GetModel("B8OMASTER"):getValue("B8O_TIPCAL") == "1"
    For nI := 1 to oModelLin:length()
        oModelLin:goline(nI)
        dVigIni := oModel:getModel("B94Detail"):getValue("B94_VIGINI")
        dVigFim := oModel:getModel("B94Detail"):getValue("B94_VIGFIM")
        If dVigIni <= dDataNext .AND. (empty(dVigFim) .OR. dVigFim > dDataNext)
            nValCont += oModelLin:getValue("B94_VALBEN") * oModelLin:getValue("B94_QTDGRU")
        endif
    next
    oModel:GetModel("B8OMASTER"):LoadValue("B8O_VLRCON", nValCont) //Usa o loadValue aqui pra 
endif

oModelLin:goline(nLinha)

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 
valida as datas de vigência
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvdat368(nTipo)
Local lRet := .T.
Local oModel   := FWModelActive() 
Local dVigIni := oModel:getModel("B94Detail"):getValue("B94_VIGINI")
Local dVigFim := oModel:getModel("B94Detail"):getValue("B94_VIGFIM")
Local dVigConIni := oModel:getModel("B8OMASTER"):getValue("B8O_VIGINI")
Local dVigConFim := oModel:getModel("B8OMASTER"):getValue("B8O_VIGFIM")

Local cMsg := "Data inválida"

Default nTipo := 1

If nTipo == 1

    If dVigIni < dVigConIni
        lRet := .F.
        cMsg := "Data infrmada menor que a vigência inicial do contrato"
    elseif !(empty(oModel:getModel("B94Detail"):getValue("B94_VIGFIM"))) .AND. dVigIni > dVigConFim
        lRet := .F.
        cMsg := "Data infrmada maior que a vigência final do contrato"
    endif
    
    If lRet
        lRet := PLSbgqx368(2,.T.,,.T.,.T.)
        if !lRet
            cMsg := "Já foi gerado crédito para a vigência"
        endif
    endif

    if lRet
        lRet := PLScdup368()
        if !lRet
            cMsg := "Data já coberta por outra vigência cadastrada"
        endif
    endif

    If lRet
        PLSvcal368()    
    endif

elseif ntipo == 2
    lRet := !(empty(oModel:getModel("B94Detail"):getValue("B94_VIGINI"))) .AND. dVigFim >= dVigIni
    If !lRet
        cMsg := "Data informada menor que a vigência inicial"
    endif

    If !(empty(oModel:getModel("B8OMASTER"):getValue("B8O_VIGFIM"))) .AND. !(empty(oModel:getModel("B94Detail"):getValue("B94_VIGFIM"))) .AND. dVigFim > dVigConFim
        lRet := .F.
        cMsg := "Data informada maior que a vigência final do contrato"
    endif

    If lRet .AND. !(empty(oModel:getModel("B94Detail"):getValue("B94_VIGFIM")))
        lRet := PLSbgqx368(2,.F.,dVigFim,.T.,.T.)
        If lRet
            PLSvcal368()
        else
            cMsg := "Já foi gerado crédito para a vigência da data informada"
        endif
    elseif (empty(oModel:getModel("B94Detail"):getValue("B94_VIGFIM")))
        lRet := .T.
        PLSvcal368()
    endif
endif

If !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSiseq368
gera o sequencial
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSiseq368()

Local cRet := ""
Local oModel     := FWModelActive()
Local oModelLin  := oModel:GetModel("B94Detail")

cRet := StrZero(oModelLin:length()+1,3)

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSbgqx368
valida se já não existe um BGQ gerado com o critério de busca
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSbgqx368(ntipo,lDataBase,dDataalt,lModel,lMsg,lCompAtu)

Local lRet := .F.
Local csql := ""
Local cAno := ""
Local cMes := ""
Local oModel := nil
Local cCodrda := ""
Local cContrato := ""
Local cidgrp := ""
Local cMsg := "Já foi gerado crédito para a vigência, não é permitido alteração. Para modificar o valor é necessário criar nova vigência."

Default ntipo := 1
Default lDatabase := .T.
Default dDataalt := StoD("")
Default lModel := .F.
Default lMsg := .T.
Default lCompAtu := .F. //Define se deve ser usada a competência atual

cCodrda := B8O->B8O_CODRDA
cContrato := B8O->B8O_IDCOPR

if lCompAtu
    cano := substr(DtoS(dDatabase),1,4)
    cMes := substr(DtoS(dDatabase),5,2)
elseIf lDatabase
    cano := substr(DtoS(Lastday(dDatabase)+1),1,4)
    cMes := substr(DtoS(Lastday(dDatabase)+1),5,2)
else
    cano := substr(DtoS(Lastday(dDataalt)+1),1,4)
    cMes := substr(DtoS(Lastday(dDataalt)+1),5,2)
endif

If lModel
    oModelx     := FWModelActive()
    oModel := oModelx:GetModel("B94Detail")
    cIdgrp := oModel:getValue("B94_SEQUEN") + oModel:getValue("B94_CODGRU")
else
    cIdgrp := B94->(B94_SEQUEN+B94_CODGRU)
endif

cSql += "Select 1 from " + RetSqlName("BGQ")
cSql += " where "
cSql += " BGQ_FILIAL = '" + xfilial("BGQ") + "' AND "
cSql += " BGQ_CODIGO = '" + cCodrda + "' AND "
cSql += " BGQ_IDCOPR = '" + cContrato + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

If nTipo == 1 //Valida se já foi gerado o BGQ antes da geração de um novo
    cSql += " AND "
    cSql += " BGQ_ANO = '" + cAno + "' AND "
    cSql += " BGQ_MES = '" + cMes + "' "
    dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"BGQ368",.f.,.t.)
        lRet := BGQ368->(EoF())
    BGQ368->(dbclosearea())

elseif ntipo == 2
    cSql += " AND "
    cSql += " BGQ_ANO >= '" + cAno + "' AND "
    cSql += " BGQ_MES >= '" + cMes + "' AND "
    cSql += " ( BGQ_IDGRP = '" + cIdgrp + "' OR "
    cSql += " BGQ_IDGRP = '      ' ) "
    dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"BGQ368",.f.,.t.)
        lRet := BGQ368->(EoF())
    BGQ368->(dbclosearea())

endif

If !lRet .AND. lMsg
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSgera368
Gera o BGQ usando outras funç~ões para validação
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSgera368()

Local oModel    := nil //FWLoadModel( 'PLSA755' )
Local cano := substr(DtoS(Lastday(dDatabase)+1),1,4)
Local cMes := substr(DtoS(Lastday(dDatabase)+1),5,2)
Local lOk   := .T.
local avig := {"","","",""}
Local lCmpPos := B8O->(FieldPos("B8O_POSPAG")) > 0
Local lCompAtu := .F.

if lCmpPos
    lCompAtu := B8O->B8O_POSPAG == '1'
    if lCompAtu
        cano := substr(DtoS(dDatabase),1,4)
        cMes := substr(DtoS(dDatabase),5,2)
    endif
endif

If PLSbgqx368(1,.T.,nil,nil,.F.,lCompAtu)
    BGQ->(dbsetOrder(1))

    If B8O->B8O_TIPCAL == '1'
        B94->(dbsetOrder(1))
        If B94->(MsSeek(xFilial('B94')+B8O->(B8O_CODRDA+B8O_IDCOPR)))
            While !(B94->(eoF())) .AND. B94->(B94_CODRDA+B94_IDCOPR) == B8O->(B8O_CODRDA+B8O_IDCOPR)
                aVig[1] := substr(DtoS(B94->B94_VIGINI),1,4)
                aVig[2] := substr(DtoS(B94->B94_VIGINI),5,2)
                aVig[3] := substr(DtoS(B94->B94_VIGFIM),1,4)
                aVig[4] := substr(DtoS(B94->B94_VIGFIM),5,2)
                If ( (aVig[1] < cAno .OR. ( aVig[1] == cAno .AND. aVig[2] <= cMes ) ) .ANd.;
                 ( empty(B94->B94_VIGFIM) .OR. aVig[3] > cAno .OR. ( aVig[3] == cAno .AND. avig[4] > cMes ) ) ) 
                    oModel := FWLoadModel( 'PLSA755' )
                    oModel:SetOperation( 3 )
                    oModel:Activate()
                    oModel:getModel("BGQMASTER"):setValue("BGQ_CODIGO", B8O->B8O_CODRDA)
                    oModel:getModel("BGQMASTER"):setValue("BGQ_ANO   ", cAno)
                    oModel:getModel("BGQMASTER"):setValue("BGQ_MES   ", cMes)
                    oModel:getModel("BGQMASTER"):setValue("BGQ_CODLAN", B94->B94_CODLAN)
                    oModel:getModel("BGQMASTER"):setValue("BGQ_IDCOPR", B8O->B8O_IDCOPR )
                    oModel:getModel("BGQMASTER"):setValue("BGQ_VALOR ", B94->B94_VALBEN * Posicione("B97",1,xFilial("B97")+B94->B94_CODGRU,"B97_TOTBEN") )
                    oModel:getModel("BGQMASTER"):setValue("BGQ_IDGRP ", B94->(B94_SEQUEN+B94_CODGRU) )

                    if oModel:vldData()
                        oModel:CommitData()
                    else
                        lOk := .F.
                    endif
                endif
                B94->(dbskip())
            endDo
        else
            lOk := .F.
        endif
    else
        oModel := FWLoadModel( 'PLSA755' )
        oModel:SetOperation( 3 )
        oModel:Activate()
        oModel:getModel("BGQMASTER"):setValue("BGQ_CODIGO", B8O->B8O_CODRDA)
        oModel:getModel("BGQMASTER"):setValue("BGQ_ANO   ", cAno)
        oModel:getModel("BGQMASTER"):setValue("BGQ_MES   ", cMes)
        oModel:getModel("BGQMASTER"):setValue("BGQ_CODLAN", B8O->B8O_CODLAN)
        oModel:getModel("BGQMASTER"):setValue("BGQ_VALOR ", B8O->B8O_VLRCON )
        oModel:getModel("BGQMASTER"):setValue("BGQ_IDCOPR", B8O->B8O_IDCOPR )

        if oModel:vldData()
            oModel:CommitData()
        else
            lOk := .F.
        endif
    endif

    if lOk
        MsgInfo("Crédito gerado!")
    else
        MsgAlert('Houve um erro na geração')
    endif
else
    MsgAlert("Já foi gerado o crédito para a " + iif(lCompAtu, '', 'próxima ') + "competência")
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSwdat368
when do campo de data de vigência até, para impedir desbloqueios
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSwdat368()

local lRet := .T.
Local oModelx     := FWModelActive()
Local oModel  := oModelx:GetModel("B94Detail")

B94->(dbsetOrder(1))
If B94->(MsSeek(xFilial("B94") + oModel:getValue("B94_CODRDA") + oModel:getValue("B94_IDCOPR") + oModel:getValue("B94_SEQUEN") ))
    lRet := empty(B94->B94_VIGFIM)
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLScdup368
Valida se o grupo informado já não está cadastrado com uma vigência em aberto
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLScdup368(lGrp)

local lRet := .T.
Local oModelx     := FWModelActive()
Local oModel  := oModelx:GetModel("B94Detail")
Local nLine := oModel:getLine()
Local nI := ""
Local aInfoIni := {oModel:getvalue("B94_CODGRU"),oModel:getvalue("B94_VIGINI"),oModel:getvalue("B94_VIGFIM")}
Local cMsg := ""

Default lGrp := .F.

for nI := 1 to oModel:length()

    if nI == nLine
        loop
    endif
    oModel:goline(nI)    

    if lGrp
        if aInfoIni[1] == oModel:getvalue("B94_CODGRU") .AND. empty(oModel:getvalue("B94_VIGFIM"))
            lRet := .F.
            cMsg := "Grupo já cadastrado e com vigência em aberto"
            exit
        endif
    else
        if aInfoIni[1] <> oModel:getvalue("B94_CODGRU")
            loop
        endif
        if aInfoIni[2] < oModel:getvalue("B94_VIGFIM")
            lRet := .F.
            cMsg := "Vigência inicial inferior à vigência final de outro cadastro deste grupo no contrato"
            exit
        endif
        if aInfoIni[2] < oModel:getvalue("B94_VIGINI")
            lRet := .F.
            cMsg := "Vigência inicial inferior à vigência inicial de outro cadastro deste grupo no contrato"
            exit
        endif
    endif
next

oModel:goline(nLine)

If !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvlan368
Valida o código de lançamento
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSvlan368(nTipo,lMsg)
Local lRet := .F.
Local cCodLan := ""
Local cMsg := "Código inválido"
Local oModelx     := FWModelActive()

Default ntipo := 1
Default lMsg := .T.

If ntipo == 1
    cCodLan := oModelx:GetModel("B8OMASTER"):getValue("B8O_CODLAN")
else
    cCodLan := oModelx:GetModel("B94Detail"):getValue("B94_CODLAN")
endif

BBB->(dbsetOrder(1))
lRet := BBB->(MsSeek(xFilial("BBB") + cCodLan))

If !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSwgrp368
when do campo de código do grupo
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSwgrp368()
Local oModel     := FWModelActive()
Local lRet := .F.

If oModel:GetOperation() == 3
    lRet := .T.
elseif oModel:GetOperation() == 4
    B94->(dbsetOrder(1))
    If B94->(MsSeek(xfilial("B94") + oModel:getModel("B8OMASTER"):getValue("B8O_CODRDA") + oModel:getModel("B8OMASTER"):getValue("B8O_IDCOPR") + oModel:getModel("B94Detail"):getValue("B94_SEQUEN") ))
        lRet := PLSbgqx368(2,.F.,B94->B94_VIGINI,.F.,.F.)
    else
        lRet := .T.
    endif
else
    lRet := .T.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSwval368()
When do campo de valor do contrato
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLSwval368()
Local oModel     := FWModelActive()
Local lRet := .F.

lRet := oModel:getModel("B8OMASTER"):getValue("B8O_TIPCAL") <> '1'

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSsbgq368()
Chama a tela de débitos/créditos filtrada pelos créditos dos contratos
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSsbgq368()
Local oBrowse	:= nil
Local csql := "@BGQ_IDCOPR = '" + B8O->B8O_IDCOPR + "'"

PLSstat755(.T.)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BGQ')
oBrowse:SetFilterDefault(cSql)
oBrowse:SetDescription("Histórico dos créditos")
oBrowse:SetMenuDef('PLSA755')
oBrowse:setMainProc("PLSA755")
oBrowse:Activate()

Return

//Função para atribuir valor à variável static
function PLSastat368(lVar)
    lAutoSt := lVar
return

function PLSvdel368(oModelGrid, nLine, cAction, cField)

Local lRet := .T.
Local oModel := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()
Local lNew     := .T.

oModelGrid:goline(nLine)
lNew := oModelGrid:isInserted()

If cAction == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE .AND. !lNew
    B94->(dbsetOrder(1))
    If B94->(MsSeek(xfilial("B94") + B8O->B8O_CODRDA + B8O->B8O_IDCOPR + oModelGrid:getValue("B94_SEQUEN") ))
        lRet := PLSbgqx368(2,.F.,B94->B94_VIGINI,.F.,.F.)
        cMsg := "Não é possível deletar o registro, pois o mesmo já foi utilizado na geração de um crédito"
    endif
endif

If !lRet
    Help(nil, nil , "Atenção", nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {""} ) 
endif

return lRet


function PLSqry368()

Local csql := ""

cSql += " Select BD6_VLRBPR, BD6_VLRDES, BD6_CODPAD, BD6_CODPRO, BD6_QTDPRO, BD6_CODRDA, BD6_DATPRO, BD6_PERDES, "
cSql += " BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO From " + RetSqlName("BD6") + " BD6 "

cSql += " Inner Join " + RetSqlName("B8O") + " B8O "
cSql += " On "
cSql += " B8O.B8O_FILIAL = '" + xFilial("B8O") + "' AND "
cSql += " B8O.B8O_CODINT = '" + B8O->B8O_CODINT + "' AND "
cSql += " B8O.B8O_CODRDA = '" + B8O->B8O_CODRDA + "' AND "
cSql += " B8O.D_E_L_E_T_ = ' ' "

cSql += " Inner Join " + RetSqlName("B8O") + " B8O "
cSql += " On "
cSql += " B8O.B8O_FILIAL = '" + xFilial("B8O") + "' AND "
cSql += " B8O.B8O_CODINT = '" + B8O->B8O_CODINT + "' AND "
cSql += " B8O.B8O_CODRDA = '" + B8O->B8O_CODRDA + "' AND "
cSql += " B8O.D_E_L_E_T_ = ' ' "

cSql += " Where "
cSql += " BD6.BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSql += " BD6.BD6_CODOPE = '" + B8O->B8O_CODINT + "' AND "
cSql += " BD6.BD6_CODRDA = '" + B8O->B8O_CODRDA + "' AND "
cSql += " BD6.BD6_TABDES = 'B8O' AND "
cSql += " BD6.D_E_L_E_T_ = ' ' "

return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSsbgq368()
Chama a tela de Eventos relacionados
@author Oscar Zanin
@since 09/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSsB8P368()
Local oBrowse	:= nil
Local csql := "@"
Local lAtualizado := findfunction("PLSA368B")

if lAtualizado
    cSql += "B8P_CODINT = '" + B8O->B8O_CODINT + "' AND "
    cSql += "B8P_CODRDA = '" + B8O->B8O_CODRDA + "' AND "
    cSql += "B8P_IDCOPR = '" + B8O->B8O_IDCOPR + "' "

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('B8P')
    oBrowse:SetFilterDefault(cSql)
    oBrowse:SetDescription("Eventos Relacionados")
    oBrowse:SetMenuDef('PLSA368B')
    oBrowse:setMainProc("PLSA368B")
    oBrowse:Activate()
else
    Msgalert("Necessária atualização para uso desta opção")
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS368BenC()
Exibe beneficiários cobertos na competência do crédito. Somente para contratos que geram créditos por grupo.
@author Oscar Zanin
@since 02/2022
@version P12
/*/
//-------------------------------------------------------------------
Function PLS368BenC()
Local cFiltro := "@"
Local oBrowse := nil
Local cDescri := "Beneficiários cobertos na competência"
Local cGrupo := IIF(!empty(BGQ->BGQ_IDGRP), SubStr(BGQ->BGQ_IDGRP,4,3), "")
Local cAno := BGQ->BGQ_ANO
Local cMes := BGQ->BGQ_MES
Local cCompetencia := cMes + "/" + cAno
Local cMesAnt := IIF(cMes == "01", "12", StrZero(Val(cMes) - 1, 2))
Local cAnoAnt := IIF(cMesAnt == "12", StrZero(Val(cAno) - 1, 4), cAno )

If !(empty(cGrupo))
    cDescri += "| Grupo: " + cGrupo + " - Competência: " + cCompetencia

    cFiltro += "B9U_CODGRU = '" + cGrupo + "' AND "
    cFiltro += "B9U_VIGINI <= '" + cAno + cMes + '01' + "' AND "
    cFiltro += "B9U_DATINC <= '" + cAnoAnt + cMesAnt + '31' + "' AND "
    cFiltro += " ( "
    cFiltro += " B9U_VIGFIM = '        ' OR "
    cFiltro += " B9U_VIGFIM >= '" + cAno + cMes + '01' + "' OR "
    cFiltro += " ( B9U_VIGFIM <= '" + cAno + cMes + '01' + "' AND B9U_DATBLQ >= '" + cAno + cMes + '01' + "' ) "
    cFiltro += " ) "

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('B9U')
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetDescription(cDescri)
    oBrowse:SetMenuDef('')
    oBrowse:Activate()
else
    MsgInfo("Funcionalidade disponível apenas para créditos gerados para grupos específicos")
endif

return
