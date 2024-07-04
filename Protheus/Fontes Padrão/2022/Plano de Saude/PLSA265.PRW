#INCLUDE "plsa265.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH" 
#Include 'FWMVCDef.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA265 ³ Autor ³ Totvs			        ³ Data ³02/12/2010³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Calendario de Pagamento                                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA265()
return Msgalert("Rotina descontinuada, favor utilizar o Novo calendário de pagamento (programa PLSA746)")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |PL265WDT	ºAutor  ³Totvs		         º Data ³ 19/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³When do campo COD DATA									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROTHEUS 11 - PLANO DE SAUDE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL265WDT()
LOCAL lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Alteracao/Exclusao - Verifico se a Data de Pagto ja esta Processada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BDT->( FieldPos("BDT_CODDAT") ) > 0 .and. BDT->( FieldPos("BDT_REEMB") ) > 0
	If !Empty(M->BDT_DATPAG) 
		BXU->(DbSetOrder(3)) //BXU_FILIAL, BXU_CODINT, BXU_DATPAG, BXU_REEMB
		If BXU->(MsSeek(xFilial("BXU")+M->(BDT_CODINT+DTOS(BDT_DATPAG)+BDT_REEMB))) .And. !Empty(BXU->BXU_DATPRO)
			lRet :=.F.
		Endif
	Endif
Endif
Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA804
Chamada da telado cadastro de competências
@author Oscar Zanin
@since 12/11/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA265C()
Local oBrowse
Local cFiltro := "@BDT_FILIAL = '" + xFilial("BDT") + "' "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BDT')
oBrowse:SetDescription("Competências das guias")
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetMainProc("PLSA265")
oBrowse:setMenudef("PLSA265")
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 26/10/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSA265' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'VIEWDEF.PLSA265' Operation 3 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSA265' Operation 4 Access 0
Add Option aRotina Title 'Excluir'    Action 'VIEWDEF.PLSA265' Operation 5 Access 0
Add Option aRotina Title 'Imprimir'   Action 'VIEWDEF.PLSA265' Operation 8 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 26/10/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBDT:= FWFormStruct(1,'BDT')

oModel := MPFormModel():New( 'PLSA265', , {|oModel| PLS265NVld(oModel) } )		//Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterBDT',/*cOwner*/,oStrBDT)								//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterBDT')
oModel:SetDescription("Cadastro de competências das guias")												// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey({""})
//oModel:SetPrimaryKey({"BDT_FILIAL","BDT_CODINT","BDT_ANO","BDT_MES","BDT_DATINI","BDT_DATFIN","BDT_DATPRE","BDT_CODDAT","BDT_DATPAG","BDT_REEMB","BDT_CODRDA"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 26/10/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrBDT:= FWFormStruct(2, 'BDT', {|cCampo| PLSA265CMP(cCampo)})

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados será utilizado
oView:AddField('FrmBDT' , oStrBDT,'MasterBDT' ) 				// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxBDT', 100)						// Cria o Box que irá conter a View
oView:SetOwnerView('FrmBDT','BxBDT')							// Associa a View ao Box

oStrBDT:setProperty("BDT_REEMB", MVC_VIEW_CANCHANGE, .T.)

Return oView

//Filtro dos campos padrão no model
function PLSA265CMP(cCampo)

Local lRet	:= .T.

If cCampo $ "BDT_DATPAG,BDT_CODDAT,BDT_CODRDA,BDT_DESRDA"
	lRet := .F.
EndIf

return lRet

/*
//Função para testes
function PLS265T(nTipo)
local LDTPAGTO := .T.

if nTipo == 1
	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","",Nil,Nil,.F.) 

	if !aRetAux[1]
		MsgAlert("Sem calendário configurado")
	else
		cMsg := "Mês: " + aRetAux[4] + " - Ano: " + aRetAux[5]
		cMsg += CRLF
		cMsg += " Data previsão de pagamento: " + DtoC(aRetAux[3])
		MsgAlert(cMsg)
	endif
else
	aRetAux := PLSXVLDCAL(Date(),"0001",.T.,"","",,,.F.,)

	if !aRetAux[1]
		MsgAlert("Sem calendário configurado")
	else
		cMsg := "Mês: " + aRetAux[4] + " - Ano: " + aRetAux[5]
		cMsg += CRLF
		cMsg += "Janela 1: " + (aRetAux[8]) + " até " + (aRetAux[9])
		cMsg += CRLF
		if aRetAux[10]
			cMsg += "Janela 2: " + (aRetAux[11]) + " até " + (aRetAux[12])
			cMsg += CRLF
		endif
		cMsg += " Data previsão de pagamento: " + DtoC(aRetAux[7])
		MsgAlert(cMsg)

	endif
endif

return
*/

//Validação da confirmação da tela
Function PLS265NVld(oModel)

Local lRet := .F.
Local cSql := ""
Local nOperation := oModel:GetOperation() 
Local lAltera := nOperation == MODEL_OPERATION_UPDATE
Local lExclui := nOperation == MODEL_OPERATION_DELETE

if !lExclui
	cSql += " Select 1 From " + Retsqlname("BDT")
	cSql += " Where "
	cSql += " BDT_FILIAL = '" + xFilial("BDT") + "' AND ( "
	cSql += " (BDT_DATINI <= '" + DtoS(oModel:getModel("MasterBDT"):getValue("BDT_DATINI")) + "' AND "
	cSql += " BDT_DATFIN >= '" + DtoS(oModel:getModel("MasterBDT"):getValue("BDT_DATINI")) + "' ) OR "
	cSql += " (BDT_DATINI <= '" + DtoS(oModel:getModel("MasterBDT"):getValue("BDT_DATFIN")) + "' AND "
	cSql += " BDT_DATFIN >= '" + DtoS(oModel:getModel("MasterBDT"):getValue("BDT_DATFIN")) + "' )  "
	cSql += " ) AND "
	if oModel:getModel("MasterBDT"):getValue("BDT_REEMB") == '1'
		cSql += " BDT_REEMB = '1' AND "
	else
		cSql += " BDT_REEMB <> '1' AND "
	endif

	if lAltera
		cSql += " R_E_C_N_O_ <> " + alltrim(str(BDT->(Recno()))) + " AND "
	endif
	cSql += " D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBDT",.F.,.T.)

	lRet := TRBBDT->(EoF())

	TRBBDT->(dbclosearea())
else
	lRet := .T.
endif

if !lRet
	Help(nil, nil , "Atenção", nil, "As datas de início e fim não podem estar contidas em outro período já cadastrado", 1, 0, nil, nil, nil, nil, nil, {""} )
endif

return lRet
