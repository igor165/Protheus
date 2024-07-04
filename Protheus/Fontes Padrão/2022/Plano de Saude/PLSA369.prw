//Cadastro de grupos de beneficiários
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA804.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA369
Abre a rotina
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA369()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B97')
oBrowse:SetDescription(FunDesc())
oBrowse:setMenudef('PLSA369')
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Menu

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title '+ Beneficiários do Grupo' Action 'PLSA361' Operation 2 Access 0
Add Option aRotina Title STR0002 /*'Visualizar'*/ Action 'VIEWDEF.PLSA369' Operation 2 Access 0
Add Option aRotina Title STR0003 /*'Incluir'   */ Action 'VIEWDEF.PLSA369' Operation 3 Access 0
Add Option aRotina Title STR0004 /*'Alterar'   */ Action 'VIEWDEF.PLSA369' Operation 4 Access 0
Add Option aRotina Title STR0005 /*'Excluir'   */ Action 'VIEWDEF.PLSA369' Operation 5 Access 0
Add Option aRotina Title STR0006 /*'Imprimir'  */ Action 'VIEWDEF.PLSA369' Operation 8 Access 0
Add Option aRotina Title STR0007 /*'Copiar'    */ Action 'VIEWDEF.PLSA369' Operation 9 Access 0
Add Option aRotina Title 'Verificar totais' Action 'PLStotB369(.T.)' Operation 2 Access 0
Add Option aRotina Title 'Carga inicial' Action 'LoadB97(1)' Operation 2 Access 0
Add Option aRotina Title 'Atualização automática' Action 'LoadB97(2)' Operation 2 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} Model

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB97:= FWFormStruct(1,'B97')

oModel := MPFormModel():New( 'PLSA369', , {|| PLSA369OK(oModel) } )		//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB97',/*cOwner*/,oStrB97)								//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB97')
oModel:SetDescription(FunDesc())												// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B97_FILIAL", "B97_CODIGO"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} View

@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB97:= FWFormStruct(2, 'B97', )

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados será utilizado
oView:AddField('FrmB97' , oStrB97,'MasterB97' ) 				// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB97', 100)						// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB97','BxB97')							// Associa a View ao Box

oStrB97:setProperty("B97_FILTRO",MVC_VIEW_TITULO,"Regra automática do grupo")

oView:AddUserButton("Definir regra automática", "", { |oModel| PLSA369FIL(@oModel) } ) //Cria o botão de Gerar Senha na View

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA369OK
Valid de confirmação da tela. 
obs: sem uso nesse primeiro momento
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA369OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB97' )
LOCAL cDescri  		:= ""
LOCAL cCodInt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLStot369
Verifica os totais do grupo posicionado ou de todos os grupos (MsgYesNo)
obs: Pendente a parte de verificação de bloqueio, o if está comentado até uma decisão final
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function PLStotB369(lTela)

local nregAtu := B97->(recno())
Local csql	:= ""
local lOk := .F.
Local lAll := .T.

Default lTela := .T.

If !lTela .OR. !MsgYesNo("Deseja atualizar todos os grupos? Caso escolha 'Não', somente o grupo posicionado será atualizado")
	lAll := .F.	
endif

If lAll
	B97->(dbGoTop())
endif

BA1->(dbSetOrder(2))

While !(B97->(EoF()))

	cSql += " Select R_E_C_N_O_ REC From " + retsqlName("B9U")
	cSql += " Where "
	cSql += " B9U_FILIAL = '" + xFilial("B9U") + "' AND "
	cSql += " B9U_CODGRU = '" + B97->B97_CODIGO + "' AND "
	cSql += " B9U_VIGINI >= '" + DtoS(Date()) + "' AND "
	cSql += " B9U_VIGFIM <> '        ' AND "
	If !lAll 
		cSql += " R_E_C_N_O_ = " + alltrim(str(nregAtu)) + " AND "
	endif
	cSql += " D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"ITEGRU",.f.,.t.)

	While !(ITEGRU->(EoF()))
		B9U->(dbgoTo(ITEGRU->REC))
		lOk := .F.

		If BA1->(msSeek(xFilial("BA1")+B9U->B9U_MATRIC)) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == alltrim(B9U->B9U_MATRIC) //[Verifica se existe com seek] .and. [Verifica se é exatamente o mesmo número]
			lOk := .T.
		Endif

		If lRet .AND. !lTela
		// Implementação futura (?)
		//	lOk := !PlChHiBlo("BCA", Date(), substr(B9U->B9U_MATRIC,1,14), substr(B9U->B9U_MATRIC,15,2), /*dDatIniBlo*/, /*dDatFinBlo*/, /*cMotBlo*/, /*lConsTole*/, /*aVgDatBlo*/, /*lConDatBCA*/.T., /*cHora*/, /*cHorPar*/) 
			lOk := .T.
		endif

		If !lOk
			B9U->(recLock("B9U",.F.))
				B9U->B9U_VIGFIM := Date()
			B9U->(MsUnLock())
		endIf

		ITEGRU->(dbskip())
	endDo
    B97->(reclock("B97",.F.))
        B97->B97_TOTBEN := PLScount361()
    B97->(MsUnlock())

	ITEGRU->(dbclosearea())

	If !lAll
		exit
	endif

    B97->(dbskip())
enddO

If lall
	B97->(dbgoto(nregAtu))
endif

if lTela
	MsgInfo("Atualização finalizada")
endif

return


function PLSA369FIL(oModel)
Local cWhere := ""
Local nOperation := oModel:GetOperation()

if nOperation == 3 .OR. nOperation == 4
	cWhere := BuildExpr("BA3",,,.t.)

	if !empty(cWhere)
		if MsgYesNo("Confirma a nova regra? A regra atual será substituída pela nova")
			oModel:getModel("MasterB97"):setValue("B97_FILTRO",cWhere)
			oModel:lModify := .T.
		endif
	endif
else
	Msgalert("Opção disponível para Inclusão ou Alteração do registro somente")
endif

return

static function BaseB97()
Local cSql := ""

cSql += " Select Distinct BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1.R_E_C_N_O_ RECBA1 From " + RetSqlName("BA1") + " BA1 "
cSql += " inner Join " + retSqlName("BA3") + " BA3 "
cSql += " On "
cSql += " BA3_FILIAL = '" + xFilial("BA3") + "' AND "
cSql += " BA3_CODINT = BA1_CODINT AND "
cSql += " BA3_CODEMP = BA1_CODEMP AND "
cSql += " BA3_MATRIC = BA1_MATRIC AND "
cSql += " BA3.D_E_L_E_T_ = ' ' "
cSql += " Where "
cSql += " BA1_FILIAL = '" + xFilial("BA1") + "' AND "
cSql += " BA1.D_E_L_E_T_ = ' ' "

if !empty(B97->B97_FILTRO)
	cSql += " AND ( "
	cSql += alltrim(B97->B97_FILTRO)
	cSql += " ) "
endif

return cSql

function LoadB97(nTipo)

Local cSql := BaseB97()
Local cQueryAlt := ""
Local cQueryExc := ""
Local lCompAtu := B97->(fieldPos("B97_INICIO")) > 0

Default nTipo := 1

if empty(B97->B97_FILTRO)
	MsgAlert("Não foi configurada regra automática")
else
	//Primeira carga
	if nTipo == 1
		B9U->(dbsetOrder(1))
		if B9U->(MsSeek(xfilial("B9U") + B97->B97_CODIGO))
			MsgAlert('Já foram incluídos beneficiários, não é possível realizar a carga inicial')
		else
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"CRG369",.f.,.t.)

			While !CRG369->(EoF())
		
				insertB97(CRG369->BA1_CODINT + CRG369->BA1_CODEMP + CRG369->BA1_MATRIC + CRG369->BA1_TIPREG + CRG369->BA1_DIGITO, IIF(lCompAtu, B97->B97_INICIO == '1', .F.))

				CRG369->(dbskip())
			endDo

			CRG369->(dbclosearea())

			PLStotB369(.F.)

			MsgInfo("Processo finalizado")
		endif
	else //Atualização

		cQueryExc += " Select Distinct B9U.R_E_C_N_O_ RECB9U, COALESCE(X.RECBA1, 0) RECA1 From " + RetSqlName("B9U") + " B9U "
		cQueryExc += " Left Join ( " 
		cQueryExc += cSql
		cQueryExc += " ) X On "
		cQueryExc += " B9U_MATRIC = BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO "
		cQueryExc += " Where "
		cQueryExc += " B9U_FILIAL = '" + xFilial("B9U") + "' AND "
		cQueryExc += " B9U_CODGRU = '" + B97->B97_CODIGO + "' AND "
		cQueryExc += " (B9U_VIGFIM = '        ' OR B9U_VIGFIM > '" + DtoS(LastDay(dDatabase)) + "') AND "
		cQueryExc += " B9U.D_E_L_E_T_ = ' ' "

		cQueryExc := changequery(cQueryExc)

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cQueryExc),"EXC369",.f.,.t.)

		While !(EXC369->(EoF()))
			if EXC369->RECA1 == 0
				B9U->(dbgoto(EXC369->RECB9U))
				UpdateB97()
			endif
			EXC369->(dbskip())
		endDo

		EXC369->(dbclosearea())

		cQueryAlt += " Select Distinct COALESCE(B9U.R_E_C_N_O_, 0) RECB9U, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO From ( "
		cQueryAlt += csql
		cQueryAlt += " ) X "
		cQueryAlt += " Left Join " + RetSqlName("B9U") + " B9U "
		cQueryAlt += " On "
		cQueryAlt += " B9U_FILIAL = '" + xFilial("B9U") + "' AND "
		cQueryAlt += " B9U_CODGRU = '" + B97->B97_CODIGO + "' AND "
		cQueryAlt += " B9U_MATRIC = BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO AND "
		cQueryAlt += " (B9U_VIGFIM = '        ' OR B9U_VIGFIM > '" + DtoS(LastDay(dDatabase)) + "') AND "
		cQueryAlt += " B9U.D_E_L_E_T_ = ' ' "
		
		cQueryAlt := changequery(cQueryAlt)

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cQueryAlt),"ATU369",.f.,.t.)

		While !(ATU369->(EoF()))

			if ATU369->RECB9U == 0
				insertB97(ATU369->BA1_CODINT + ATU369->BA1_CODEMP + ATU369->BA1_MATRIC + ATU369->BA1_TIPREG + ATU369->BA1_DIGITO, IIF(lCompAtu, B97->B97_INICIO == '1', .F.))
			else
				if PlChHiBlo("BCA", dDatabase, ATU369->BA1_CODINT + ATU369->BA1_CODEMP + ATU369->BA1_MATRIC, ATU369->BA1_TIPREG, /*dDatIniBlo*/, /*dDatFinBlo*/, /*cMotBlo*/, /*lConsTole*/, /*aVgDatBlo*/, /*lConDatBCA*/.T., /*cHora*/, /*cHorPar*/)
					B9U->(dbgoTo(ATU369->RECB9U))
					UpdateB97()
				endif
			endif
			ATU369->(dbskip())
		endDo

		ATU369->(dbclosearea())

		PLStotB369(.F.)

		MsgInfo("Processo finalizado")
	endif
endif

return

static function UpdateB97()

local oModel := FWLoadModel('PLSA361')

oModel:SetOperation( 4 )
oModel:Activate()

oModel:getModel("MasterB9U"):setValue("B9U_VIGFIM", LastDay(dDatabase))

If (oModel:VldData() )
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	oModel:CommitData()
EndIf
oModel:DeActivate()
oModel:Destroy()
oModel := nil

return

static function insertB97(cMatric, lCompAtu)

local oModel := FWLoadModel('PLSA361')
Default lCompAtu := .F.

oModel:SetOperation( 3 )
oModel:Activate()

oModel:getModel("MasterB9U"):setValue("B9U_MATRIC", cMatric)
oModel:getModel("MasterB9U"):setValue("B9U_VIGINI", IIF(lCompAtu, firstDay(dDatabase), LastDay(dDatabase)+1))

If (oModel:VldData() )
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	oModel:CommitData()
EndIf
oModel:DeActivate()
oModel:Destroy()
oModel := nil

return
