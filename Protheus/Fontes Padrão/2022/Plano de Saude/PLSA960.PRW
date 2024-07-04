#INCLUDE "plsa960.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'

static lNoMsg := .f. // Controle para exibição de alerts

#define cArqNmLog "plsveprofall_erros.LOG"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA960.
Tela de Cadastro de Profissionais de Saúde
@since  01/10/2020.
//-------------------------------------------------------------------*/
function PLSA960(lAutoma)
local cFiltro   := "@(BB0_FILIAL = '" + xFilial("BB0") + "') "
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BB0')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:AddLegend("BB0->BB0_CODBLO == Space(03) .Or. BB0->BB0_DATBLO > DDATABASE", "GREEN", STR0014 ) //Autorizado
oBrowse:AddLegend("BB0->BB0_CODBLO <> Space(03) .and. BB0->BB0_DATBLO <= DDATABASE", "RED", STR0015 ) //Negado

oBrowse:SetDescription(STR0017) //"Profissionais de Saúde"
iif(!lAutoma, oBrowse:Activate(), '')
return 


/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    10/2020
//-------------------------------------------------------------------*/
static function MenuDef()
local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA960' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA960" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA960" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "FwMsgRun(, {|| staticcall(PLSA960, PLS960DEL, .f.)}, ,'Analisando dados...')"			Operation 5 Access 0  //Excluir
Add Option aRotina Title  STR0006	Action "FWExecView('Bloqueio/Desbloqueio','PLSA960BLO', 3)"			Operation 9 Access 0  //Excluir

return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    10/2020
//-------------------------------------------------------------------*/
Static function ModelDef()
local oModel    := nil     
local oStrBB0   := FWFormStruct(1,'BB0')
local oStrBQ1   := FWFormStruct(1,'BQ1')

oModel := MPFormModel():New('PLSA960', , { || PLS960VLD("S", oModel) })

oModel:addFields('MASTERBB0', , oStrBB0) 

oModel:AddGrid('BQ1Detail', 'MASTERBB0', oStrBQ1,,,{||!PlCkProfRDA(oModel:getModel("MASTERBB0"):getValue("BB0_CODIGO"), '')})

oModel:SetRelation( 'BQ1Detail', { { 'BQ1_FILIAL', 'xFilial( "BQ1" ) ' } , ;
								   { 'BQ1_CODIGO', 'BB0_CODIGO' }}        , ;
								   BQ1->( IndexKey( 1 ) ) )

oModel:GetModel('BQ1Detail'):SetUniqueLine( { 'BQ1_CODIGO', 'BQ1_CODESP' } )

oModel:GetModel('BQ1Detail'):setOptional(.t.)

oStrBB0:SetProperty( "BB0_ESTADO"  , MODEL_FIELD_VALID, { || PlsVlCpo(oModel,"BB0_ESTADO") })
oStrBB0:SetProperty( "BB0_NUMCR"   , MODEL_FIELD_VALID, { || PlsVlCpo(oModel,"BB0_NUMCR") })
oStrBB0:SetProperty( "BB0_CODSIG"  , MODEL_FIELD_VALID, { || PlsVlCpo(oModel,"BB0_CODSIG")  })
oStrBB0:SetProperty( "BB0_CODOPE"  , MODEL_FIELD_VALID, { || PlsVlCpo(oModel,"BB0_CODOPE")})
oStrBQ1:SetProperty( 'BQ1_CODIGO'  , MODEL_FIELD_INIT, { || oModel:getModel("MASTERBB0"):getValue("BB0_CODIGO")} )
oStrBQ1:SetProperty( 'BQ1_CODESP'  , MODEL_FIELD_VALID, { || PlsVlCpo(oModel,"BQ1_CODESP")} )

oModel:GetModel('MASTERBB0'):SetDescription(STR0017) // Profissionais de Saúde
oModel:SetPrimaryKey( { "BB0_FILIAL", "BB0_CODIGO", "BB0_ESTADO", "BB0_NUMCR", "BB0_CODSIG" } )

return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    10/2020
//-------------------------------------------------------------------*/
Static function ViewDef()
local oView     := nil
local oModel  	:= FWLoadModel('PLSA960')
local oStrBB0   := FWFormStruct(2, 'BB0')
local oStrBQ1   := FWFormStruct(2, 'BQ1')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBB0', oStrBB0, 'MASTERBB0')
oView:AddGrid('ViewBQ1', oStrBQ1, 'BQ1Detail')

oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

oView:SetOwnerView('ViewBB0', 'SUPERIOR')
oView:SetOwnerView('ViewBQ1', 'INFERIOR')

oView:SetViewProperty("ViewBQ1", "GRIDFILTER", {.t.})
oView:SetViewProperty("ViewBQ1", "GRIDSEEK", {.t.})
oView:SetCloseOnOK( { || .t. } )
oView:SetAfterViewActivate({|| !PlCkProfRDA(oModel:getModel("MASTERBB0"):getValue("BB0_CODIGO"), STR0024, oModel) })
oView:SetDescription(STR0017) //Profissionais de Saúde
oView:EnableTitleView('ViewBQ1',STR0018) //"Especialidades do profissional"

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PLS960VLD
Valida campo de CRM e outras validações, na hora de gravar/alterar o registro.
@since    10/2020
//-------------------------------------------------------------------*/
Function PLS960VLD(cTp, oModel)
local lRet			:= .t.
local aArea			:= GetArea()
local aRetFun		:= {}
local lHomonim		:= SuperGetMV("MV_PLSHOMO",,.F.)  // parametro para Verificação de Homonimo    
local nOperation 	:= oModel:GetOperation()
local oObjBB0		:= oModel:getModel("MASTERBB0")

if ( nOperation == MODEL_OPERATION_INSERT )

	if lRet .and. BB0->(FieldPos("BB0_MATVID")) > 0 .and. lHomonim
		PlsHomoni(oObjBB0:getValue("BB0_NOME"), oObjBB0:getValue("BB0_CGC"), oObjBB0:getValue("BB0_NUMCR"),"","","","","BB0", oObjBB0:getValue("BB0_MATVID"),.t.)
	endif
	
	if lRet
		aRetFun := PlVldBB0Cod(oObjBB0:getValue("BB0_CODIGO"))
		if aRetFun[1] //Ocorreu troca de código (Sequencial errado)
			oObjBB0:loadValue( "BB0_CODIGO", aRetFun[2] )
		endif
	endif
elseif ( nOperation == MODEL_OPERATION_DELETE )
	VldExcB17(oObjBB0:getValue("BB0_CODIGO"))
endif

RestArea(aArea)

Return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlVldBB0Cod
Verifica se o código da BB0_CODIGO está duplicado e procura outros disponível.
@since    10/2020
//-------------------------------------------------------------------*/
static function PlVldBB0Cod(cCodGerado)
local aAreaBB0		:= BB0->(getArea())
local lNovoCod		:= .f.
default cCodGerado	:= ""

BB0->(DbSetOrder(1))
if BB0->( MsSeek(xFilial("BB0") + cCodGerado ) )
	cCodGerado := GetSx8Num("BB0","BB0_CODIGO")
	BB0->( ConfirmSx8() )

	//Prevenção para não pegar código igual já cadastrado
	while ( BB0->(MsSeek(xFilial("BB0") + cCodGerado)) )
		cCodGerado := GetSx8Num("BB0","BB0_CODIGO")
		BB0->( ConfirmSx8() )
	end
	lNovoCod := .t.
endif
RestArea(aAreaBB0)
return {lNovoCod, cCodGerado}


/*//-------------------------------------------------------------------
{Protheus.doc} PLS960DEL
Verifica se o profisisonal que vai ser excluído já não foi utilizado em atendimentos. Se sim, não pode excluir.
@since    10/2020
//-------------------------------------------------------------------*/
static function PLS960DEL(lAutoma)
local lRet		:= .t.
local lRdaAtv	:= .f.
default lAutoma	:= .f.

if BB0->BB0_VINC == "2" 
	if PlCkProfRDA(BB0->BB0_CODIGO, STR0022) //Existe relacionamento deste Profissional de Saúde com uma Rede de Atendimento	
		lRet := .f.	
	endif	
else
	Help(nil, nil , STR0019, nil, STR0029, 1, 0, nil, nil, nil, nil, nil, {} )
	lRdaAtv := .t.
endif

if !lRet
	//Atenção / Existem registros atrelados. Exclusão não permitida
	Help(nil, nil , STR0019, nil, STR0023, 1, 0, nil, nil, nil, nil, nil, {} )	
elseif !lRdaAtv .and. !lAutoma
	FWExecView(STR0017, 'PLSA960', MODEL_OPERATION_DELETE,, {|| .T. } )
endif      

return {lRet, lRdaAtv}


/*//-------------------------------------------------------------------
{Protheus.doc} PlCkProfRDA
Verifica se o profisisonal é uma RDA. Se sim, suas especialdiades devem ser alteradas na RDA 
@since    10/2020
//-------------------------------------------------------------------*/
static function PlCkProfRDA(cCodigo, cMensagem, oModelVr)
local lRet			:= .f.
local lAltera		:= iif( !empty(oModelVr) .and. oModelVr:GetOperation() == MODEL_OPERATION_UPDATE, .t., .f. )
default cMensagem	:= ""
default oModelVr	:= nil

BAU->(dbsetorder(5))
if BAU->(MsSeek(xFilial("BAU") + cCodigo))
	lRet := .t.
endif
iif( !Empty(cMensagem) .and. lRet .and. lAltera, Help(nil, nil , STR0019, nil, cMensagem, 1, 0, nil, nil, nil, nil, nil, {} ), '')	//Atenção

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlVldCrDupl
Verifica se já existe profissional na base com os dados informados.
@since    10/2020
//-------------------------------------------------------------------*/
static function PlVldCrDupl(oModel, lCodSig,lNoMsgP,lCodCrm)
local aAreaBB0		:= BB0->(getArea())
local nRecnoEdt		:= iif( oModel:GetOperation() == MODEL_OPERATION_UPDATE, BB0->(recno()), 0) 
local lRet			:= .t.
local oObjBB0		:= oModel:getModel("MASTERBB0")
default lCodCrm		:= .f.
default lCodSig		:= .f.
default lNoMsgP     := .f.

lNoMsg := lNoMsgP

if lCodSig
	oObjBB0:loadValue("BB0_DESSIG", Posicione("BAH",1,xFilial("BAH") + oObjBB0:getValue("BB0_CODSIG"),"BAH_DESCRI") ) 
endif 

if ( !empty(oObjBB0:getValue("BB0_ESTADO")) .and. !empty(oObjBB0:getValue("BB0_NUMCR")) .and. !empty( oObjBB0:getValue("BB0_CODSIG")) )
	BB0->(DbSetOrder(4)) //BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
	if  BB0->( MsSeek(xFilial("BB0") + oObjBB0:getValue("BB0_ESTADO") + oObjBB0:getValue("BB0_NUMCR") + ;
									   oObjBB0:getValue("BB0_CODSIG") + oObjBB0:getValue("BB0_CODOPE")) ) .and. BB0->(recno()) != nRecnoEdt
		//Atenção / Profissional de Saúde já cadastrado.
		if !lNoMsg
			Help(nil, nil , STR0019, nil, STR0021, 1, 0, nil, nil, nil, nil, nil, {} )
		endif
		lRet := .f.
	endif
endif	
RestArea(aAreaBB0)
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlSveProfAll
Função genérica de gravação da BB0, utlizando MVC.
Os parâmetros principais são passados no corpo da função: cNome, cSigla, cEstado, cNumCons, cCodOpe, cCNPJF, cVinculo, cCodOrig
Os demais dados da tabela podem ser passados em um array, na parâmetro aDadosOpc, na seguinte estrutura: {{"BB0_SEXO", "1"}, {"BB0_EMAIL", "abc@totvs.com.br"}},
onde na primeira posição do array temos o nome do campo e na segunda, o valor a ser gravado.
lApeBusca -> Apenas verifica se existe ou não. Se informado .t., não vai realizar a gravação do profissional e retorna tudo false
@since    10/2020
//-------------------------------------------------------------------*/
function PlSveProfAll (cNome, cSigla, cEstado, cNumCons, cCodOpe, cCNPJF, cVinculo, cCodOrig, aDadosOpc, lNoMsgX)
local cBB0Filial	:= xFilial("BB0")
local lRet 			:= .t.
local lInclui		:= .f.
local nLaco			:= 0
local oModel960     := FWLoadModel("PLSA960") 
local oObjBB0		:= oModel960:GetModel('MASTERBB0')
default	cNome		:= "PROFISSIONAL OPE PADRAO"
default cSigla		:= ""
default cEstado		:= ""
default cNumCons	:= ""
default cCodOpe		:= PlsIntpad()
default cCNPJF		:= ""
default cVinculo	:= "2" //Nao faz parte da Rede de Atendimento
default cCodOrig	:= ""
default aDadosOpc	:= {}
default lNoMsgX		:= .f.

lNoMsg := lNoMsgX
	
if ( empty(cSigla) .or. empty(cEstado) .or. empty(cNumCons) )
	// Falta dados basicos para inclusao: / Número Conselho: / Estado / Sigla
	PlRetGrvErros(nil, STR0025 + STR0026 + cNumCons + " / " + STR0027 + cEstado + " / " + STR0028 + cSigla + CRLF, cArqNmLog)
	lRet := .f.
endif

if len(allTrim(cCodOpe)) < 4 
	//"Codigo da Operadora foi trocado pelo padrão. Codigo original: "
	PlRetGrvErros(nil,STR0035+cCodOpe, cArqNmLog)
	cCodOpe := PlsIntpad()
Endif

if empty(allTrim(cNome))
	//"Codigo da Operadora foi trocado pelo padrão. Codigo original: "
	PlRetGrvErros(nil,STR0036, cArqNmLog)
	cNome := "PROFISSIONAL OPE PADRAO"

endif 


if lRet
	//Tratamento dos campos - Tamanho BB0 SX3
	cNumCons	:= upper(padr(cNumCons	,TamSx3('BB0_NUMCR')[1]))
	cSigla		:= upper(padr(cSigla 	,TamSx3('BB0_CODSIG')[1]))
	cEstado		:= upper(padr(cEstado	,TamSx3('BB0_ESTADO')[1]))
	cNome		:= upper(alltrim(cNome))

	//Verifica se realmente não existe o registro, após ajustes dos valores
	BB0->( DbSetOrder(4) ) 
	If !BB0->( MsSeek( cBB0Filial + cEstado + cNumCons + cSigla + cCodOpe ) )
		//Verifica se o CPF/CNPJ é válido. Se não ou já existir, mas para outro crm, será gravado no log e o campo zerado, para não comprometer a gravação
		if ( !empty(cCNPJF) )
			BB0->( DbSetOrder(3) ) 	
			if ( !CGC(cCNPJF,,.f.) .or. BB0->(MsSeek(cBB0Filial + cCNPJF)) )
				PlRetGrvErros(nil, STR0032 + cCNPJF + " / " + cNumCons + " / " + cEstado + " / " + cSigla + " / " + cNome + CRLF, cArqNmLog) //"CPF/CNPJ inválido. Será gravado vazio. Chave: "
				cCNPJF := ""
			endif
		endif
			
		oModel960:SetOperation(3)
		oModel960:Activate()

		oObjBB0:setValue("BB0_FILIAL"	, cBB0Filial)
		oObjBB0:setValue("BB0_VINC"		, iif(empty(cVinculo), "2", cVinculo))
		oObjBB0:setValue("BB0_NOME"		, cNome)
		oObjBB0:setValue("BB0_ESTADO"	, cEstado)
		oObjBB0:setValue("BB0_CODSIG"	, cSigla)
		oObjBB0:setValue("BB0_NUMCR"	, cNumCons)
		oObjBB0:setValue("BB0_CGC"		, cCNPJF)
		oObjBB0:setValue("BB0_UF"		, cEstado)
		oObjBB0:setValue("BB0_CODOPE"	, cCodOpe)
		oObjBB0:setValue("BB0_CODORI"	, iif(valtype(cCodOrig) != "B", cCodOrig, eval(cCodOrig)))
		//Se o array estiver preenchido, estamos passando os dados opcionais para gravação
		if !empty(aDadosOpc)
			for nLaco := 1 to len(aDadosOpc)
				if len(aDadosOpc[nLaco]) == 2
					oObjBB0:setValue(aDadosOpc[nLaco,1]	, aDadosOpc[nLaco,2])
				endif
			next
		endif
		if (oModel960:VldData())
			oModel960:commitData()
			lInclui := .t.
		else
			PlRetGrvErros(oModel960, '', cArqNmLog)
			lRet := .f.
		endif
	endif
endif 
oModel960:deActivate()
oModel960:destroy()
freeObj( oModel960 )
freeObj( oObjBB0 )
oModel960 := nil
return {lRet, BB0->BB0_CODIGO, lInclui}


/*//-------------------------------------------------------------------
{Protheus.doc} PlSveEspQ1
Função genérica de gravação da BB0, utlizando MVC.
Os parâmetros principais são passados no corpo da função: cNome, cSigla, cEstado, cNumCons, cCodOpe, cCNPJF, cVinculo, cCodOrig
@since    10/2020
//-------------------------------------------------------------------*/
function PlSveEspQ1 (cCodOpe, cCodBB0, cCodEspec, cDescricao, cCBOS)
local cBQ1Filial	:= xFilial("BQ1")
local cBB0Filial	:= xFilial("BB0")
local lRetInc 		:= .t.
local lInclui		:= .f.
local oModel960     := FWLoadModel("PLSA960") 
local oObjBQ1		:= oModel960:GetModel('BQ1Detail')
default cCodOpe		:= PlsIntpad()
default cCodBB0		:= ""
default cCodEspec	:= ""
default cDescricao	:= ""
default aDadosOpc	:= {}

if ( empty(cCodBB0)  )
	PlRetGrvErros(nil, STR0025 + STR0030 + cCodBB0 + CRLF, cArqNmLog)
	lRetInc := .f.
endif

if lRetInc
	cCodEspec := padr(cCodEspec, TamSx3('BQ1_CODESP')[1])
	BQ1->( DbSetOrder(1) ) 
	if !BQ1->(MsSeek(cBQ1Filial + cCodBB0 + cCodEspec))
		//se cDescricao vazio e CBOS vazio, busca BAQ, se não, vai na BTQ
		if ( empty(cDescricao) .and. empty(cCBOS) )
			cDescricao := Posicione("BAQ", 1, xFilial("BAQ") + cCodOpe + cCodEspec, "BAQ_DESCRI")
		elseif ( empty(cDescricao) .and. !empty(cCBOS) )
			cDescricao := Posicione("BTQ", 1, xFilial("BTQ") + "24" + cCBOS, "BTQ->BTQ_DESTER")
		endif

		//posicionar no BBO, para abrir o form em modo de edição, para incluir as especialidades
		BB0->(DbSetOrder(1)) 
		If BB0->( MsSeek( cBB0Filial + cCodBB0 ) )
			oModel960:SetOperation(4)
			oModel960:Activate()
 
			if (!oObjBQ1:isempty())
				oObjBQ1:AddLine()
			endif

			oObjBQ1:setValue("BQ1_FILIAL"	, cBQ1Filial)
			oObjBQ1:setValue("BQ1_CODINT"	, cCodOpe)
			oObjBQ1:setValue("BQ1_CODIGO"	, cCodBB0)
			oObjBQ1:setValue("BQ1_CODESP"	, cCodEspec)

			if (oModel960:VldData())
    			oModel960:commitData()
				lInclui := .t.
			else
				PlRetGrvErros(oModel960, '', cArqNmLog)
				lRetInc := .f.
			endif	
		else
			PlRetGrvErros(nil, STR0031 + cCodBB0, cArqNmLog) //"Não existe cadastro de profissional com o BB0 informado: "
			lRetInc := .f.
		endif
	else
		lRetInc := .f.
	endif
endif 
oModel960:deActivate()
oModel960:destroy()
freeObj( oModel960 )
freeObj( oObjBQ1 )
oModel960 := nil
return {lRetInc, lInclui}


/*//-------------------------------------------------------------------
{Protheus.doc} PlRetGrvErros
Rotina para gravar logs de erros, para pesquisa do usuário/suporte
@since    10/2020
//-------------------------------------------------------------------*/
static function PlRetGrvErros(oModel, cMensagem, cNomeLog)
local lExisteDw		:= findfunction('dwcallstack')
default oModel 		:= nil
default cMensagem	:= ""

if !empty(oModel)
	//"* Erro de Validação MVC: " / "Campo e Valor: "
	cMensagem := STR0033 + oModel:getErrorMessage()[6] + " - " + STR0034 + oModel:getErrorMessage()[4] + " - "
	cMensagem += iif( !empty(oModel:getErrorMessage()[8]), oModel:getErrorMessage()[8], '')  + CRLF + dtoc(msdate()) + " - " + time()
endif 

if !empty(cMensagem) .and. !empty(cNomeLog)
	cMensagem += iif( lExisteDw, dwcallstack(0,,.f.), PPilhaProc(0, '') ) + CRLF + padr("*",60,"*") + CRLF
	PlsLogFil(cMensagem, cNomeLog)
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} VldExcB17
Exclui os dados relativos aos bloqueios/desbloqueios realizados do profissional que está sendo excluído.
@since    10/2020
//-------------------------------------------------------------------*/
static function VldExcB17(cCodProf)
local cSql		:= ""
local oMdl960B	:= FWLoadModel("PLSA960BLO") 

cSql := " SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B17")
cSql += "   WHERE B17_FILIAL = '" + xFilial("B17") + "' "
cSql += "   AND B17_CODPFS = '" + cCodProf + "' "
cSql += "   AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql), "QRYBLOCK",.f.,.t.)

while !QRYBLOCK->(eof()) 
	B17->( dbgoto(QRYBLOCK->REC) )
	oMdl960B:SetOperation(5)
	oMdl960B:Activate()
	if (oMdl960B:VldData())
		oMdl960B:commitData()
	endif
	oMdl960B:deActivate()
	QRYBLOCK->(dbskip())
enddo
QRYBLOCK->(dbcloseArea())
oMdl960B:deActivate()
oMdl960B:destroy()
freeObj( oMdl960B )
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlsVlCpo
Valida campos
@since   02/2021
//-------------------------------------------------------------------*/
Static Function PlsVlCpo(oModel,cCampo)
local lRet      := .t.
Local oObjBB0   := oModel:getModel("MASTERBB0")
Local oObjBQ1   := oModel:GetModel('BQ1Detail')
local oViewTel  := FWViewActive()
local lExsView  := iif( valtype(oViewTel) == "U" .or. !oViewTel:isActive(), .f., .t. ) //Caso venha do PTU será .F. assim da para tratar para que não apareça mensagens em tela

if cCampo == "BB0_ESTADO"
	SX5->(DbSetOrder(1))
	If  !(SX5->(DbSeek(xFilial("SX5")+"12" + oObjBB0:getValue("BB0_ESTADO"))))  
		lret := .F.
	endif

elseif 	cCampo == "BB0_CODSIG"

	BAH->(DbSetOrder(1))
	If  !(BAH->(DbSeek(xFilial("BAH")+ oObjBB0:getValue("BB0_CODSIG")))) 
		lret := .F.
	endif	
elseif 	cCampo == "BB0_CODOPE"	

	BA0->(DbSetOrder(1))
	If  !BA0->(DbSeek(xFilial("BA0")+oObjBB0:getValue("BB0_CODOPE")))
		lret := .F.
	endif	

Elseif 	cCampo == "BQ1_CODESP"		

	BAQ->(DbSetOrder(1))
	If !BAQ->(DbSeek(xFilial("BQ1")+ oObjBQ1:getValue("BQ1_CODINT") +oObjBQ1:getValue("BQ1_CODESP")))
	lret := .F.
	endif	

Elseif 	cCampo == "BB0_NUMCR"		
	if lExsView
		lRet:= PlVldCrDupl(oModel, .f.,.f.)
	else 
		lRet:= PlVldCrDupl(oModel, .f.,.t.)
	endif	
endif


if lret 
	if lExsView  
		PlVldCrDupl(oModel, .t.,.f.)//Caso venha do PTU passa .T. no ultimo parametro para nao exibir mensagem em tela.
	else 
		PlVldCrDupl(oModel, .t.,.t.)
	endif
endif

return lRet
