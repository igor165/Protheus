#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "PLSRECGLO3.ch"

#DEFINE G_HONORARIO "06"
#DEFINE G_REC_GLOSA "10"


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
MenuDef
@since    04/2019
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel
Local oStrB4D := FWFormStruct(1,'B4D')
Local oStrB4E := FWFormStruct(1,'B4E')

oModel := MPFormModel():New( 'PLSRECGLO3', , {|oModel| ValidaGrid(oModel) }, {|oModel| SalvAnalise(oModel)} )

oStrB4D:AddField('Desc_Glosa', 'Código / Descrição da Glosa', 'CODDESGLO', 'C', 250, 0, , , {}, .F., {||staticCall(PLSRECGLO2, CarregaGlosa, oModel) } , .F., .F., .T., , )

oModel:addFields('MasterB4D',/*cOwner*/,oStrB4D)
oModel:AddGrid('B4EDetail', 'MasterB4D', oStrB4E, , { || VldStRecIt(oModel)})
oModel:SetRelation( 'B4EDetail', { { 'B4E_FILIAL', 'xFilial( "B4E" ) ' } , ;
										{ 'B4E_SEQB4D', 'B4D_SEQB4D' }        , ;
										{ 'B4E_CODPEG', 'B4D_CODPEG' } }      , ;
										B4E->( IndexKey( 1 ) ) )

oStrB4E:setProperty( "B4E_VLRACA" , MODEL_FIELD_VALID,  { || StatRecIte(oModel) } )
oStrB4E:setProperty( "B4E_VLRACA" , MODEL_FIELD_WHEN ,  { || oModel:getModel("B4EDetail"):getValue("B4E_STATUS") == '5' } )
oStrB4E:setProperty( "B4E_JUSOPE" , MODEL_FIELD_WHEN ,  { || oModel:getModel("B4EDetail"):getValue("B4E_STATUS") $ '3,4,5' } )
oStrB4E:setProperty( "B4E_STATUS" , MODEL_FIELD_VALID,  { || SetValRecS(oModel) } )
oStrB4D:setProperty( "B4D_ACAGUI" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "2"} )
oStrB4E:setProperty( "B4E_STATUS" , MODEL_FIELD_WHEN ,  { || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "3"} )
oStrB4D:setProperty( "B4D_ACAPRO" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "1"} )
oStrB4D:setProperty( "B4D_ACAPRO" , MODEL_FIELD_VALID, 	{ || AcatRecCab(oModel, "1")} )
oStrB4D:setProperty( "B4D_ACAGUI" , MODEL_FIELD_VALID, 	{ || AcatRecCab(oModel, "2")} )
oStrB4D:setProperty( "B4D_CDGTIS" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") $ "1,2" .and. (oModel:getModel("MasterB4D"):getValue("B4D_ACAPRO") == "N" ;
																														   .or. oModel:getModel("MasterB4D"):getValue("B4D_ACAGUI") == "N")} )
oStrB4D:setProperty( "B4D_DSGTIS" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") $ "1,2"} )
oStrB4E:setProperty( "B4E_CDGTIS" , MODEL_FIELD_WHEN ,  { || oModel:getModel("B4EDetail"):getValue("B4E_STATUS") $ '4,5'} )

//virtuais
oStrB4E:AddField('Data_Realizacao'	, 'Data do Procedimento'	, 'B4E_DATAPROCEDIMENTO', 'D', 8, 0, , , {}, .F. ,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_DATPRO") } , .F., .F., .T., , )
oStrB4E:AddField('Quant_Apresentada', 'Quantidade Apresentada' 	, 'B4E_QTDSOLICITADA'	, 'N', 12, 4, , , {}, .F.,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_QTDAPR") }  , .F., .F., .T., , )  //Apresentada
oStrB4E:AddField('Quant_Aprovada'	, 'Quantidade Aprovada'    	, 'B4E_QTDAPROVADA'		, 'N', 12, 4, , , {}, .F.,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_QTDPRO") }  , .F., .F., .T., , )  //Liberada
oStrB4E:AddField('Valor_Contratado'	, 'Valor Contratado'       	, 'B4E_VLRCONTRATADO'	, 'N', 16, 2, , , {}, .F.,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_VLRBPR") }  , .F., .F., .T., , )
oStrB4E:AddField('Valor_Apresentado', 'Valor Apresentado'		, 'B4E_VLRAPRESENTADO'	, 'N', 16, 2, , , {}, .F.,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_VLRAPR") }  , .F., .F., .T., , )
oStrB4E:AddField('Valor_Pago'		, 'Valor Pago'				, 'B4E_VLRPAGO'			, 'N', 16, 2, , , {}, .F.,{||staticCall(PLSRECGLO2,CarregaBD6Val, oModel, "BD6_VLRPAG") }  , .F., .F., .T., , )

oModel:getModel( 'B4EDetail' ):setNoInsertLine( .T. )
oModel:getModel( 'B4EDetail' ):setNoDeleteLine( .T. )

oModel:GetModel('MasterB4D'):SetDescription(STR0002) // 'Inclusão Recurso de Glosa'

return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    04/2019.
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView		:= nil
Local oModel  	:= FWLoadModel( 'PLSRECGLO3' )
Local lPRGLOFLD	:= existblock("PRGLOFLD")
Local oStrB4D 	:= FWFormStruct(2, 'B4D', { |cCampo| FilViewB4D(cCampo, lPRGLOFLD) } )
Local oStrB4E 	:= FWFormStruct(2, 'B4E', { |cCampo| FilViewB4E(cCampo, lPRGLOFLD) } )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB4D' , oStrB4D,'MasterB4D' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid( 'ViewB4E' , oStrB4E,'B4EDetail' )

oModel:GetModel( 'B4EDetail' ):SetOptional( .T. )

oStrB4D:SetProperty( 'B4D_ACAGUI' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_ACAPRO' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_STATUS' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_JUSPRO' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_JUSGUI' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_CODPEG' , MVC_VIEW_ORDEM    , "00" )
oStrB4D:SetProperty( 'B4D_NUMAUT' , MVC_VIEW_ORDEM    , "01" )
oStrB4E:SetProperty( 'B4E_VLRACA' , MVC_VIEW_CANCHANGE, .T. )
oStrB4E:SetProperty( 'B4E_JUSOPE' , MVC_VIEW_CANCHANGE, .T. )
oStrB4E:SetProperty( 'B4E_STATUS' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_CODPEG' , MVC_VIEW_TITULO   , "Número do Protocolo (PEG)")
oStrB4D:SetProperty( 'B4D_NUMAUT' , MVC_VIEW_TITULO   , "Número da guia dentro do PEG")
oStrB4D:SetProperty( 'B4D_TOTREC' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_DATREC' , MVC_VIEW_CANCHANGE, .F. )
oStrB4E:SetProperty( 'B4E_STATUS' , MVC_VIEW_ORDEM    , "00" )
oStrB4E:SetProperty( 'B4E_VLRACA' , MVC_VIEW_ORDEM    , "01" )
oStrB4E:SetProperty( 'B4E_VLRREC' , MVC_VIEW_ORDEM    , "02" )
oStrB4E:SetProperty( 'B4E_JUSOPE' , MVC_VIEW_ORDEM    , "03" )

oStrB4E:SetProperty( 'B4E_CDGTIS' , MVC_VIEW_ORDEM    , "04" )
oStrB4E:SetProperty( 'B4E_DSGTIS' , MVC_VIEW_ORDEM    , "05" )

oStrB4D:SetProperty( 'B4D_QTDIRP' , MVC_VIEW_TITULO   , "Número da Tentativa")
oStrB4D:SetProperty( 'B4D_ACAPRO' , MVC_VIEW_TITULO   , "Protocolo Acatado?")
oStrB4D:SetProperty( 'B4D_JUSOPE' , MVC_VIEW_TITULO   , "Justificativa da Operadora - Análise")
oStrB4D:SetProperty( 'B4D_JUSPRO' , MVC_VIEW_TITULO   , "Justificativa do Protocolo - Prestador")
oStrB4D:SetProperty( 'B4D_JUSGUI' , MVC_VIEW_TITULO   , "Justificativa da Guia - Prestador")
//visual
oStrB4D:SetProperty( 'B4D_TOTACA' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_DCDPEG' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_DCDDLP' , MVC_VIEW_CANCHANGE, .F. )
oStrB4D:SetProperty( 'B4D_DNUMER' , MVC_VIEW_CANCHANGE, .F. )
//virutais
oStrB4E:AddField( 'B4E_DATAPROCEDIMENTO','30','Data do Procedimento'	,'Data do Procedimento'		,, 'Get' ,"@",,,.F.,,,,,,.T.,, )
oStrB4E:AddField( 'B4E_QTDSOLICITADA'	,'31','Quantidade Apresentada'	,'Quantidade Apresentada'	,, 'Get' ,"@E 9,999,999.9999",,,.F.,,,,,,.T.,, )
oStrB4E:AddField( 'B4E_QTDAPROVADA'		,'32','Quantidade Aprovada'		,'Quantidade Aprovada'		,, 'Get' ,"@E 9,999,999.9999",,,.F.,,,,,,.T.,, )
oStrB4E:AddField( 'B4E_VLRCONTRATADO'	,'33','Valor Contratado'		,'Valor Contratado'			,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, )
oStrB4E:AddField( 'B4E_VLRAPRESENTADO'	,'34','Valor Apresentado'		,'Valor Apresentado'		,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, )
oStrB4E:AddField( 'B4E_VLRPAGO'			,'35','Valor Pago'				,'Valor Pago'				,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, )
oStrB4D:AddField( 'CODDESGLO'			,'99','Código / Descrição da Glosa'	,'Código / Descrição da Glosa'	,, 'C' ,"@",,,.F.,,,,,,.t.,, )

oView:CreateHorizontalBox( 'SUPERIOR' , 30 )
oView:CreateHorizontalBox( 'INFERIOR' , 70 )

oView:SetOwnerView('ViewB4D','SUPERIOR')
oView:SetOwnerView('ViewB4E','INFERIOR') 

oView:SetViewProperty( 'ViewB4E', "ENABLEDGRIDDETAIL", { 40 } )

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} ValidaGrid
Valida os dados do grid
@since    04/2019
//-------------------------------------------------------------------*/
Static function ValidaGrid(oModel)
Local nI 			:= 1
Local oB4E 			:= oModel:getmodel("B4EDetail")
Local lGrava 		:= .T.
Local aStatusIte 	:= {0,0,0}
local aHelp			:= {'', '', ''}
local lExclusao		:= iif(oModel:nOperation == MODEL_OPERATION_DELETE, .t., .f.) 
local nVlrAca		:= 0

if !lExclusao
	If oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "3"
	//por item, tem que ver se todos os itens foram atualizados, caso não, dar mensagem e então colocar o status do B4D em análise
		For nI := 1 To oB4E:Length()
			oB4E:GoLine( nI )
			If !( oB4E:getvalue("B4E_STATUS") $ '3,4,5' )
				if MsgYesNo(STR0003)  //"Há itens não análisados, deseja salvar o recurso com status 'Em análise'?"
					oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "2")
					aStatusIte := {0,0,0}
					Exit
				else
					lgrava := .F.
					aHelp := {STR0001, STR0023, STR0024}  //atenção / "Informe a situação dos demais itens." / "Informe se foi Autorizado, Negado ou Autorizado parcialmente para os demais itens"
					Exit
				endif
			else
				If aStatusIte[3] == 0 .AND. aStatusIte[1] == 0 .AND. oB4E:getvalue("B4E_STATUS") == "3"
					aStatusIte[1] := 1
				elseIf aStatusIte[3] == 0 .AND. aStatusIte[2] == 0 .AND. oB4E:getvalue("B4E_STATUS") == "4"
					aStatusIte[2] := 1
				elseif aStatusIte[3] == 0 .AND. oB4E:getvalue("B4E_STATUS") == "5"
					aStatusIte[3] := 1
				endif
			endif
			nVlrAca	+= oB4E:getvalue("B4E_VLRACA")
		Next
		
		If !lgrava
			oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "2")
		else
			If aStatusIte[3] == 1 .OR. ( aStatusIte[1] == 1 .ANd. aStatusIte[2] == 1 )
				oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "5")
			elseIf ( aStatusIte[1] == 1 .ANd. aStatusIte[2] == 0 )
				oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "3")
			elseIf ( aStatusIte[1] == 0 .ANd. aStatusIte[2] == 1 )
				oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "4")
			endif
		endif
		oModel:getModel("MasterB4D"):Loadvalue("B4D_TOTACA", nVlrAca)	

	elseif oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "2"
	//ver se teve ação no ACAGUI/ACAPRO, caso não tenha, não tem o que salvar, só deixa em análise (ou nem mexe)
		If EmpTy(oModel:getModel("MasterB4D"):getValue("B4D_ACAGUI"))
			aHelp := {STR0001, STR0004, ''}  //atenção / "O recurso não foi analisado"
			lGrava := .F.
		elseIf EmpTy(oModel:getModel("MasterB4D"):getValue("B4D_JUSOPE"))
			aHelp := {STR0001, STR0005, ''}  //atenção / "Não foi informada a justificativa da análise"
			lGrava := .F.
		endif
	elseif oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "1"
		If EmpTy(oModel:getModel("MasterB4D"):getValue("B4D_ACAPRO"))
			aHelp := {STR0001, STR0004, ''}  //atenção / "O recurso não foi analisado"
			lGrava := .F.
		elseIf EmpTy(oModel:getModel("MasterB4D"):getValue("B4D_JUSOPE"))
			aHelp := {STR0001, STR0005, ''}  //atenção / "Não foi informada a justificativa da análise"
			lGrava := .F.
		endif
	endif

	if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
		Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
	endif
endif	

return lGrava


/*//-------------------------------------------------------------------
{Protheus.doc} StatRecIte
valida status da linha do grid
@since    04/2019
//-------------------------------------------------------------------*/
static function StatRecIte(oModel)
Local lRet := .T.
local aHelp	:= {'', '', ''}

If oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") > 0
	If oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") > oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC")
		aHelp := {STR0001, STR0006, STR0007}  //atenção / "O valor acatado é maior que o valor recursado" / "Inclua um valor que seja igual ou menor que o recursado pelo Prestador."
		lRet := .F.
	elseif oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") == oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC")
		If MsgYesNo(STR0008)  //"O Status foi alterado para acatado parcialmente, porém o valor acatado é igual ao valor recursado, gostaria de alterar o Status para Acatado?"
			oModel:getModel("B4EDetail"):Loadvalue("B4E_STATUS", "3")
		else
			lRet := .F.
			aHelp := {STR0001, STR0009, STR0013}  //atenção / "Verifique o valor acatado para o recurso" / "Informe o valor para o item recursado."
		endif
	endif
elseIf oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") == 0
	If MsgYesNo(STR0010) //"O Status foi alterado para acatado parcialmente, porém o valor de glosa está zerado, gostaria de alterar o Status para Negado?"
		oModel:getModel("B4EDetail"):Setvalue("B4E_STATUS", "4")
	else
		lRet := .F.
		aHelp := {STR0001, STR0009, STR0013}  // atenção / "Verifique o valor acatado para o recurso" / "Informe o valor para o item recursado."
	endif
elseIf oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") < 0
	lRet := .F.
	aHelp := {STR0001, STR0011, STR0012}  // atenção / "O valor deve ser positivo." / "Informe um valor positivo."
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} SetValRecS
Controla status dos itens do grid
@since    04/2019
//-------------------------------------------------------------------*/
static function SetValRecS(oModel)
Local lret := .T.
	oModel:getModel("B4EDetail"):Loadvalue("B4E_CDGTIS", "")
	oModel:getModel("B4EDetail"):Loadvalue("B4E_DSGTIS", "")
	If oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '3'
		oModel:getModel("B4EDetail"):Loadvalue("B4E_VLRACA", oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC"))
	elseIf oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '4'
		oModel:getModel("B4EDetail"):Loadvalue("B4E_VLRACA", 0)
	elseIf oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '5'
		oModel:getModel("B4EDetail"):Loadvalue("B4E_VLRACA", 0)
	elseIf oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '0'
		lRet := .F.
		Help(nil, nil , STR0001, nil, STR0014, 1, 0, nil, nil, nil, nil, nil, {''} )  // atenção / "não é possível alterar para este Status, pois o recurso já foi protocolado"
	endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} VldStRecIt
Validação do campo B4E_STATUS
@since    04/2019
//-------------------------------------------------------------------*/
static function VldStRecIt(oModel)
Local lRet := .T.
local aHelp := {'', '', ''}  

If oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") $ '3,4,5' .AND. empTy(oModel:getModel("B4EDetail"):getvalue("B4E_JUSOPE"))
	lRet := .F.
	aHelp := {STR0001, STR0015, STR0016}  // atenção / "É obrigatório informar a justificativa da análise" /  "Informe a justificativa para prosseguir com a análise."
endif

If oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '5' .AND. oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") == 0
	If MsgYesNo(STR0010) //"O Status foi alterado para acatado parcialmente, porém o valor de glosa está zerado, gostaria de alterar o Status para Negado?"
		oModel:getModel("B4EDetail"):Setvalue("B4E_STATUS", "4")
	else
		lRet := .F.
		aHelp := {STR0001, STR0009, STR0013}  //atenção / "Verifique o valor acatado para o recurso" / "Informe o valor para o item recursado."
	endif
elseif oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") == '5' .AND. oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA") == oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC")
	If MsgYesNo(STR0008)  //"O Status foi alterado para acatado parcialmente, porém o valor acatado é igual ao valor recursado, gostaria de alterar o Status para Acatado?"
		oModel:getModel("B4EDetail"):Loadvalue("B4E_STATUS", "3")
	else
		lRet := .F.
		aHelp := {STR0001, STR0009, STR0013}  //atenção / "Verifique o valor acatado para o recurso" / "Informe o valor para o item recursado."
	endif
endif

If lRet .AND. EmpTy(oModel:getModel("B4EDetail"):getvalue("B4E_SEQUEN"))
	lRet := .F.
	aHelp := {STR0001, STR0017, ''}  // "Não é permitida a inclusão de itens no recurso de glosa manualmente"
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} IVlGloAcat
//Verifica quanto de recurso de glosa já foi acatado pra o item
@since    04/2019
//-------------------------------------------------------------------*/
Static function IVlGloAcat(cCodOpe,cCodLDP,cCodPEG,cNumero,cSequen,cOrimov)
Local nRet := 0
Local cSql := ""

cSql += " Select SUM(B4E_VLRACA) TOTALACATADO From " + RetsqlName("B4E")
cSql += " Where "
cSql += "     B4E_FILIAL = '" + xfilial("B4E") + "' "
cSql += " AND B4E_OPEMOV = '" + cCodOpe + "' "
cSql += " AND B4E_CODLDP = '" + cCodLDP + "' "
cSql += " AND B4E_CODPEG = '" + cCodPEG + "' "
cSql += " AND B4E_NUMAUT = '" + cNumero + "' "
cSql += " AND B4E_ORIMOV = '" + cOrimov + "' "
cSql += " AND B4E_SEQUEN = '" + cSequen + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"RECACAT",.f.,.t.)

nret := RECACAT->(TOTALACATADO)

RECACAT->(dbcloseArea())

return nRet


/*//-------------------------------------------------------------------
{Protheus.doc} CVlGloAcat
//Verifica quanto de recurso de glosa já foi acatado pra o PEG/Guia
@since    04/2019
//-------------------------------------------------------------------*/
Static function CVlGloAcat(cCodOpe,cCodLDP,cCodPEG,cNumero)
Local nRet := 0
Local cSql := ""

Default cNumero := ""

cSql += " Select SUM(B4D_TOTACA) TOTALACATADO From " + RetsqlName("B4D")
cSql += " Where "
cSql += "     B4D_FILIAL = '" + xfilial("B4E") + "' "
cSql += " AND B4D_OPEMOV = '" + cCodOpe + "' "
cSql += " AND B4D_CODLDP = '" + cCodLDP + "' "
cSql += " AND B4D_CODPEG = '" + cCodPEG + "' "
If !(empTy(cNumero))
	cSql += " AND B4D_NUMAUT = '" + cNumero + "' "
	cSql += " AND B4D_OBJREC = '2' "
else
	cSql += " AND B4D_OBJREC = '1' "
endif
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"RECACAT",.f.,.t.)

nret := RECACAT->(TOTALACATADO)

RECACAT->(dbcloseArea())

return nRet


/*//-------------------------------------------------------------------
{Protheus.doc} StatRecCab
Status cabeçalho
@since    04/2019
//-------------------------------------------------------------------*/
static function StatRecCab(oModel)
Local lRet := .T.
local aHelp := {'', '', ''}

If oModel:getModel("MasterB4D"):getvalue("B4D_OBJREC") $ "1,2"
	If oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") > 0
		If oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") > oModel:getModel("MasterB4D"):getvalue("B4D_VLRGLO")
			aHelp := {STR0001, STR0018, STR0019}  //atenção / "O valor apresentado para o recurso é maior que o Saldo de glosa para recurso restante" / "Verifique o valor de saldo de glosa e insira um valor até o limite de saldo apresentado."
			lRet := .F.
		endif
	elseIf oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") < 0
		lRet := .F.
		aHelp := {STR0001, STR0012, STR0013}  //atenção / "O valor deve ser positivo." / "Informe um valor positivo."
	endif
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} FilViewB4D
Campos exibidos na view B4D
@since    04/2019
//-------------------------------------------------------------------*/
static function FilViewB4D(cCampo, lPeCmp)
Local lret := .F.

If ccampo == 'B4D_CODPEG'
	lRet := .T.
endif
If ccampo == 'B4D_NUMAUT'
	lRet := .T.
endif
If ccampo == 'B4D_OBJREC'
	lRet := .T.
endif
If ccampo == 'B4D_TIPGUI'
	lRet := .T.
endif
If ccampo == 'B4D_USUARI'
	lRet := .T.
endif
If ccampo == 'B4D_NOMUSR'
	lRet := .T.
endif
If ccampo == 'B4D_JUSGUI'
	lRet := .T.
endif
If ccampo == 'B4D_JUSPRO'
	lRet := .T.
endif
If ccampo == 'B4D_TOTREC'
	lRet := .T.
endif
If ccampo == 'B4D_VLRGLO'
	lRet := .T.
endif
If ccampo == 'B4D_DATREC'
	lRet := .T.
endif
If ccampo == 'B4D_STATUS'
	lRet := .T.
endif
If ccampo == 'B4D_ACAGUI'
	lRet := .T.
endif
If ccampo == 'B4D_ACAPRO'
	lRet := .T.
endif
If ccampo == 'B4D_TOTACA'
	lRet := .T.
endif
If ccampo == 'B4D_JUSOPE'
	lRet := .T.
endif
If ccampo == 'B4D_CODRDA'
	lRet := .T.
endif
If ccampo == 'B4D_NOMRDA'
	lRet := .T.
endif

If ccampo == 'B4D_DCDPEG'
	lRet := .T.
endif
If ccampo == 'B4D_DCDDLP'
	lRet := .T.
endif
If ccampo == 'B4D_DNUMER'
	lRet := .T.
endif
If ccampo == 'B4D_QTDIRP'
	lRet := .T.
endif
If ccampo == 'B4D_CDGTIS'
	lRet := .T.
endif	
If ccampo == 'B4D_DSGTIS'
	lRet := .T.
endif	

if lPeCmp
	lRet := execBlock("PRGLOFLD",.F.,.F., {lRet, cCampo})
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} FilViewB4E
Campos exibidos na view B4E
@since    04/2019
//-------------------------------------------------------------------*/
static function FilViewB4E(cCampo, lPeCmp)
Local lret := .F.

If ccampo == 'B4E_VLRGLO'
	lRet := .T.
endif
If ccampo == 'B4E_SEQUEN'
	lRet := .T.
endif
If ccampo == 'B4E_CODPAD'
	lRet := .T.
endif
If ccampo == 'B4E_CODPRO'
	lRet := .T.
endif
If ccampo == 'B4E_DESPRO'
	lRet := .T.
endif
If ccampo == 'B4E_GLOTIS'
	lRet := .T.
endif
If ccampo == 'B4E_VLRREC'
	lRet := .T.
endif
If ccampo == 'B4E_SLDREC'
	lRet := .T.
endif
If ccampo == 'B4E_JUSPRE'
	lRet := .T.
endif
If ccampo == 'B4E_DESGLO'
	lRet := .T.
endif
If ccampo == 'B4E_VLRACA'
	lRet := .T.
endif
If ccampo == 'B4E_JUSOPE'
	lRet := .T.
endif
If ccampo == 'B4E_STATUS'
	lRet := .T.
endif
If ccampo == 'B4E_CDGTIS'
	lRet := .T.
endif	
If ccampo == 'B4E_DSGTIS'
	lRet := .T.
endif		

if lPeCmp
	lRet := execBlock("PRGLOFLD",.F.,.F., {lRet, cCampo})
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} AcatRecCab
Status cabeçalho
@since    04/2019
//-------------------------------------------------------------------*/
Static function AcatRecCab(oModel, cTipRec)
Local lRet := .T.

If cTipRec == "1"
	If oModel:getModel("MasterB4D"):getvalue("B4D_ACAPRO") == "S"
		oModel:getModel("MasterB4D"):Loadvalue("B4D_TOTACA", oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC"))
		oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "3")
	else
		oModel:getModel("MasterB4D"):Loadvalue("B4D_TOTACA", 0)
		oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "4")
	endif
elseIf cTipRec == "2"
	If oModel:getModel("MasterB4D"):getvalue("B4D_ACAGUI") == "S"
		oModel:getModel("MasterB4D"):Loadvalue("B4D_TOTACA", oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC"))
		oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "3")
	else
		oModel:getModel("MasterB4D"):Loadvalue("B4D_TOTACA", 0)
		oModel:getModel("MasterB4D"):Loadvalue("B4D_STATUS", "4")
	endif
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} SalvAnalise
Verificar se foi tudo analisado (Status 3, 4 ou 5 -> Acatado, não acatado ou acatado parcialmente)
Verificar o tipo de recurso (PEG, GUIA ou ITEM)
***** Se for por ITEM
	  -> gravar um PEg novo, com uma guia, com os itens recursados ACATADOS ou ACATADOS PARCIALMENTE, tudo baseado na origem
***** Se for por GUIA
	  -> gravar um PEG novo, com a guia recursada, caso ACATADO, baseado na origem
***** Se for por PEG
	  -> gravar um PEG novo, com todas as guias dele, caso o recurso seja ACATADO
Fazer um for no BD6 pra pegar todos os correspondentes nos B4E
@since    04/2019
//-------------------------------------------------------------------*/
Static function SalvAnalise(oModel)
Local lFinalizada	:= .F.
Local cTipRec		:= ""
Local nItensLaco	:= 1
Local aSeqRec		:= {} 
local cChavPegDes	:= ""
local aItensChave	:= {}
local cStatusAna	:= oModel:getModel("MasterB4D"):getvalue("B4D_STATUS")
local lExclusao		:= iif(oModel:nOperation == MODEL_OPERATION_DELETE, .t., .f.) 
local lRet			:= .f.

if !lExclusao

	oModel:VldData()

	cTipRec := oModel:getModel("MasterB4D"):getvalue("B4D_OBJREC")

	cCodOpe := oModel:getModel("MasterB4D"):getvalue("B4D_OPEMOV")
	cCodLdp := oModel:getModel("MasterB4D"):getvalue("B4D_CODLDP")
	cCodPeg := oModel:getModel("MasterB4D"):getvalue("B4D_CODPEG")
	cNumero := oModel:getModel("MasterB4D"):getvalue("B4D_NUMAUT")
	cOriMov := oModel:getModel("MasterB4D"):getvalue("B4D_ORIMOV")
	cAlias  := IIF( oModel:getModel("MasterB4D"):getvalue("B4D_TIPGUI") <> "05", "BD5", "BE4" )

	If cTipRec == "3"
		for nItensLaco := 1 To oModel:getModel("B4EDetail"):Length()
			oModel:getModel("B4EDetail"):goLine( nItensLaco )
			if ( oModel:getModel("B4EDetail"):getvalue("B4E_STATUS") $ '3,5' ) //3=Rec Glosa Autorizado;5=Aut Parcial    
				aadd(aSeqRec, {oModel:getModel("B4EDetail"):getvalue("B4E_SEQUEN"), oModel:getModel("B4EDetail"):getvalue("B4E_VLRACA")})
			endif	 
		Next
	endif

	//verifico se devo realmente gerar uma nova guia, baseado nas informações acima
	//Se glosa por PEG/Guia, deve estar acatado  - Se for item, deve ter algum item recursado acatado integral/parcial.
	if ( (cTipRec $ '1,2' .and. cStatusAna $ '3') .or. (cTipRec == "3" .and. len(aSeqRec) > 0 .and. cStatusAna $ '3,5' ) ) 
		lFinalizada := .t.
	endif

	lRecursada := .T.

	BD6->(DbsetOrder(1))
	BD6->(MsSeek(xfilial("BD6") + cCodOpe + cCodLdp + cCodPeg /*+ cNumero*/))

	if lFinalizada
		cChavPegDes := ProcCtaINC(cCodOpe, cCodLdp, cCodPeg, cNumero, cOriMov, cTipRec, lRecursada, cAlias, NIL, aSeqRec)
		
		aItensChave := StrTokArr2( cChavPegDes, ' - ', .f. )
		oModel:getModel("MasterB4D"):Loadvalue("B4D_DCDDLP", aItensChave[2])
		oModel:getModel("MasterB4D"):Loadvalue("B4D_DCDPEG", aItensChave[3])
		if cTipRec != "1"
			oModel:getModel("MasterB4D"):Loadvalue("B4D_DNUMER", aItensChave[4])
		endif
		HELP(' ',1,STR0020,, STR0021 + aItensChave[3] + iif(cTipRec != "1", STR0022 + aItensChave[4],"") ,2,0,,,,,, {''}) // "PEG / Guias de Recurso de Glosa" / "A PEG / Guia foi gravada com sucesso, na PEG: " / " e Guia de Número:"
	endif

	lRet := .t.
endif
 
//Gravar B4D 
if lRet .and. !lExclusao
	FWFormCommit( oModel ) 
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} ProcCtaINC
Função que gera as novas guias
@since    04/2019
//-------------------------------------------------------------------*/
static function ProcCtaINC(cCodOpe, cCodLdp, cCodPeg, cNumero, cOriMov, cTipRec, lRecursada, cAlias, dDtPar, aSeqRec)
local cOpeMov	:= ''
local cNumImp	:= ''
local cTipo		:= ''
local cTipFat	:= ''
local cCidObt	:= ''
local cNrdCob	:= ''
local cObtMul	:= ''
local cTipAlt	:= ''
local cNrdCnv	:= ''
local cLotGui	:= ''
local cArqImp	:= ''
local cNumSol	:= ''
local cHrAlta 	:= ''
local cEmgest	:= ''
local cAborto	:= ''
local cTragra	:= ''
local cComurp 	:= ''
local cAtespa 	:= ''
local cComnal 	:= ''
local cBaipes 	:= ''
local cPaareo 	:= ''
local cPatNor 	:= ''
local cTipSai	:= ''
local cTipCon	:= ''
local cTipoAte	:= ''
local cGrpInt	:= ''
local cTipInt	:= ''
local cIndAci	:= ''
local cUndDoe	:= ''
local cTipDoe	:= ''
local cMsg01	:= ''
local cMsg02	:= ''
local cEspSol	:= ''
local cEspEXe	:= ''
local cTipAdm	:= ''
local cCarSol	:= ''
local cAteRN	:= ''
local cSituac	:= ''
local cGuiOri	:= ''
local cHrIniFat	:= ''
local cHrFimFat	:= ''
local cGuiPri	:= ''
local cRet 		:= ''
local cPadCon	:= ''
local cRegInt	:= ''
local cTipPac	:= ''
local cTipAto	:= ''
local cParCop	:= ''
local cTipMaj	:= '' 
local cNomUsrCar:= ''
local cCodEmp	:= ''
local cOriMovRC	:= ''
//
local cPadLaco	:= cAlias+"_FILIAL+" + cAlias+"_CODOPE+" + cAlias+"_CODLDP+" + cAlias+"_CODPEG"
local cTipLaco	:= iif(cTipRec == "1", cPadLaco, cPadLaco + "+"+cAlias+"_NUMERO")
local cChaveG	:= iif(cTipRec == "1", cCodOpe + cCodLdp + cCodPeg,  cCodOpe + cCodLdp + cCodPeg + cNumero )
local aArea		:= {}
local cChaveTmp	:= ""
local cNewPegPro:= ""
//
local cFase		:= '1'
local cLocalExec:= '1'
local cRCCodLDP	:= GetNewPar("MV_PLCLDRC","0010")

local nQtNasV	:= 0
local nQtNasM	:= 0
local nQtNasP	:= 0
local nQtObtP	:= 0
local nQtObAR	:= 0
local nTmpDoe	:= 0

local lHonor 	:= (BD6->BD6_TIPGUI == G_HONORARIO)
local lAtuPeg	:= .t.
local lImpTxt	:= .f.
local lImpXml	:= .f.
local lnInfEquip:= .f.
local lXmlOrigS	:= .f.
local lChkByFase:= .t.

local dDtAlta 	:= stod('')
local dDtIniFat	:= stod('')
local dDtFimFat	:= stod('')

local aItens	:= {}
local aTipPart	:= {}
local aCriticas	:= {}
local aEspCbXML	:= {}

local cTipGui	:= G_REC_GLOSA 
local cHora		:= "" //strTran(time(),':','')

Local CCNES	:= ""

local cCodRda	:= ""
local cCodLoc	:= ""
local cCodEsp	:= ""
local cCidPri	:= ""
local cNumLib	:= ""
local cMatric	:= ''
local cTipoGrv	:= ""
local cCDPFSO	:= ""
local cCDPFEX	:= ""
local dDatPro	:= ""
local cGuiInt	:= ""

default cCodOpe		:= ""
default cCodLdp		:= ""
default cCodPeg		:= ""
default cNumero		:= ""
default cOriMov		:= ""
default lRecursada 	:= .F.
default cTipRec		:= ""
default dDtPar		:= date()
default aSeqRec		:= {}

//alimenta variavel usada na PLSPOSGLO
setCTRVAr("PLSA498GUI") //serve pra deixar todas as críticas desativadas no plsposglo

//BD5
if cAlias == 'BD5'

	BD5->(dbSetOrder(1))//BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
	if BD5->( MsSeek(xFilial("BD5") + cChaveG) )
		while ( !BD5->(EOF()) .and. BD5->&(cTipLaco) == xFilial("BD5") + cChaveG )
			cOpeMov 	:= iIf(empty(BD5->BD5_OPEMOV),BD5->BD5_CODOPE,BD5->BD5_OPEMOV)
			cCodEmp		:= BD5->BD5_CODEMP
			cAnoAut 	:= BD5->BD5_ANOAUT
			cMesAut 	:= BD5->BD5_MESAUT
			cNumAut 	:= BD5->BD5_NUMAUT
			cNumImp		:= BD5->BD5_NUMIMP
			cTipFat		:= BD5->BD5_TIPFAT
			cLotGui		:= BD5->BD5_LOTGUI
			cNumSol 	:= BD5->(BD5_CODOPE+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)
			cTipSai		:= BD5->BD5_TIPSAI
			cTipCon		:= BD5->BD5_TIPCON
			cNomUsrCar	:= BD5->BD5_NOMUSR
			cTipoAte	:= BD5->BD5_TIPATE
			cIndAci		:= BD5->BD5_INDACI
			cUndDoe		:= BD5->BD5_UTPDOE
			nTmpDoe		:= BD5->BD5_TPODOE
			cTipDoe		:= BD5->BD5_TIPDOE
			cMsg01		:= BD5->BD5_OBSGUI
			cEspSol		:= BD5->BD5_ESPSOL
			cEspEXe		:= BD5->BD5_ESPEXE
			cTipAdm		:= BD5->BD5_TIPADM	
			cAteRN		:= BD5->BD5_ATERNA
			cSituac		:= BD5->BD5_SITUAC
			cGuiOri		:= BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
			cCnes 		:= BD5->BD5_CNES
			cGuiPri		:= BD5->BD5_GUIPRI
			cTipPac		:= BD5->BD5_TIPPAC
			cTipAto		:= BD5->BD5_TIPATO
			cParCop		:= BD5->BD5_PARCOP
			cTipMaj		:= BD5->BD5_TIPMAJ
			cGuiInt		:= BD5->BD5_GUIINT
			//Demais dados
			cCodRda		:= BD5->BD5_CODRDA
			cCodLoc		:= BD5->BD5_CODLOC
			cCodEsp		:= BD5->BD5_CODESP
			cCidPri		:= BD5->BD5_CID
			cNumLib		:= iif(empty(BD5->BD5_NRAOPE),BD5->BD5_SENHA,BD5->BD5_NRAOPE)
			cMatric		:= BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
			cTipoGrv	:= BD5->BD5_TPGRV
			cCDPFSO		:= BD5->BD5_CDPFSO
			cCDPFEX		:= BD5->BD5_CDPFRE
			dDatPro		:= BD5->BD5_DATPRO
			cHora 		:= BD5->BD5_HORPRO

			cChaveTmp := iif( empty(aSeqRec), cChaveG, cCodOpe + cCodLdp + cCodPeg + cNumero + cOriMov)
			fDadosBD6( cChaveTmp, iif (cTipRec == "1", BD5->BD5_NUMERO, ""), aSeqRec, @aItens )

			aArea := BD5->(getArea())

			if lRecursada
				
				cAlias := "BD5"
				cRet := PLSICM(	cOpeMov, cMatric, cTipoGrv, cLocalExec, cCDPFSO, cCDPFEX, dDatPro, cHora, cNumImp, cCodRda, cRCCodLDP,;
								cTipo, cCodLoc, cCodEsp, cTipGui, cCidPri, nQtNasV,nQtNasM, nQtNasP, nQtObtP, nQtObAR, cTipFat, cCidObt,cNrdCob,;
								cObtMul, cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,cAlias,lHonor,cOriMovRC,cNumSol,nil,lAtuPeg,;
								cPadCon, dDtAlta,cHrAlta,cEmgest,cAborto, cTraGra, cComurp,cAtespa,cComnal,cBaipes,cPaareo,cPatnor,cTipSai,;
								cTipCon, cNomUsrCar,dDtPar,cTipoAte,cGrpInt,cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,;
								cEspExe, cTipAdm,cRegint,cCarSol,nil,cAteRN,lImpTxt,cFase,cSituac,cGuiOri,cCnes,aCriticas,dDtIniFat,cHrIniFat,;
								dDtFimFat, cHrFimFat, lnInfEquip, lXmlOrigS, aEspCbXML, cGuiPri, lImpXml, lChkByFase, cTipPac, cTipAto, cParCop,;
								cTipMaj, iif( cTipRec == "1", {cTipRec, cNewPegPro}, {'',''}),,cGuiInt)

				//Vamos posicionar na guia novamente e realizar a MF
				cNewPegPro := BCI->BCI_CODPEG
				fPosiMudFas(cRet)

			endif

			//Como na inclusão da guia e nas demais funções tem manipulção da BD5, restauramos a area original encontrada e limpamos todas as variáveis.
			Restarea(aArea)
			fLimpVarArr(@aItens, @cOpeMov, @cCodEmp, @cAnoAut, @cMesAut, @cNumAut, @cNumImp, @cTipFat, @cLotGui, @cNumSol, @cTipSai, @cTipCon, @cNomUsrCar, @cTipoAte, @cIndAci, @cUndDoe,;
			            @nTmpDoe, @cTipDoe, @cMsg01, @cEspSol, @cEspEXe, @cTipAdm, @cAteRN,	@cSituac, @cGuiOri, @cCnes, @cGuiPri, @cTipPac, @cTipAto, @cParCop, @cTipMaj,;
						@cCodRda, @cCodLoc, @cCodEsp, @cCidPri, @cNumLib, @cMatric, @cTipoGrv, @cCDPFSO, @cCDPFEX, @dDatPro,;
						@nQtNasV, @nQtNasM, @nQtNasP, @nQtObtP, @nQtObAR, @cCidObt, @cNrdCob, @cObtMul, @cTipAlt, @cNrdCnv, @cPadCon, @dDtAlta, @cHrAlta, @cEmgest, @cAborto, @cTragra,;
						@cComurp, @cAtespa, @cComnal, @cBaipes, @cPaareo, @cPatNor, @cGrpInt, @cTipInt, @cMsg02, @cRegInt, @cAteRN, @dDtIniFat, @cHrIniFat, @dDtFimFat, @cHrFimFat)

			BD5->(DbSkip())
		enddo
		
	endif

//BE4
else 
	
	BE4->(dbSetOrder(1))//BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
	if BE4->(MsSeek(xFilial("BE4") + cChaveG))
		while ( !BE4->(EOF()) .and. BE4->&(cTipLaco) == xFilial("BE4") + cChaveG )
			cOpeMov 	:= BE4->BE4_CODOPE
			cCodEmp		:= BE4->BE4_CODEMP
			cAnoAut 	:= BE4->BE4_ANOINT
			cMesAut 	:= BE4->BE4_MESINT
			cNumAut 	:= BE4->BE4_NUMINT
			cNumImp		:= BE4->BE4_NUMIMP
			nQtNasV		:= BE4->BE4_NASVIV
			nQtNasM		:= BE4->BE4_NASMOR
			nQtNasP		:= BE4->BE4_NASVPR
			nQtObtP		:= BE4->BE4_OBTPRE
			nQtObAR		:= BE4->BE4_OBTTAR
			cTipFat		:= BE4->BE4_TIPFAT
			cCidObt		:= BE4->BE4_CIDOBT
			cNrdCob		:= BE4->BE4_NRDCOB
			cObtMul		:= BE4->BE4_OBTMUL
			cTipAlt		:= BE4->BE4_TIPALT
			cNrdCnv		:= BE4->BE4_NRDCNV
			cLotGui		:= BE4->BE4_LOTGUI
			cNumSol 	:= BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			cPadCon		:= BE4->BE4_PADCON 
			dDtAlta 	:= BE4->BE4_DTALTA 
			cHrAlta 	:= BE4->BE4_HRALTA 
			cEmgest		:= BE4->BE4_EMGEST 
			cAborto		:= BE4->BE4_ABORTO 
			cTragra 	:= BE4->BE4_TRAGRA 
			cComurp 	:= BE4->BE4_COMURP
			cAtespa 	:= BE4->BE4_ATESPA
			cComnal 	:= BE4->BE4_COMNAL
			cBaipes 	:= BE4->BE4_BAIPES 
			cPaareo 	:= BE4->BE4_PARCES 
			cPatNor 	:= BE4->BE4_PATNOR 
			//cTipSai	:= BE4->BE4_TIPSAI
			cTipCon		:= BE4->BE4_TIPCON
			cNomUsrCar	:= BE4->BE4_NOMUSR
			cGrpInt		:= BE4->BE4_GRPINT
			cTipInt		:= BE4->BE4_TIPINT
			cIndAci		:= BE4->BE4_INDACI
			cUndDoe		:= BE4->BE4_UTPDOE
			nTmpDoe		:= BE4->BE4_TPODOE
			cTipDoe		:= BE4->BE4_TIPDOE
			cMsg01		:= BE4->BE4_MSG01
			cMsg02		:= BE4->BE4_MSG02
			cEspSol		:= BE4->BE4_ESPSOL
			cEspEXe		:= BE4->BE4_ESPEXE
			cTipAdm		:= BE4->BE4_TIPADM	
			cRegInt		:= BE4->BE4_REGINT
			cAteRN		:= BE4->BE4_ATERNA
			cSituac		:= BE4->BE4_SITUAC
			cGuiOri		:= BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
			cCnes 		:= BE4->BE4_CNES
			dDtIniFat	:= BE4->BE4_DTINIF
			cHrIniFat	:= BE4->BE4_HRINIF
			dDtFimFat	:= BE4->BE4_DTFIMF
			cHrFimFat	:= BE4->BE4_HRFIMF
			//Demais dados
			cCodRda		:= BE4->BE4_CODRDA
			cCodLoc		:= BE4->BE4_CODLOC
			cCodEsp		:= BE4->BE4_CODESP
			cCidPri		:= BE4->BE4_CID
			cNumLib		:= iif(empty(BE4->BE4_NRAOPE),BE4->BE4_SENHA,BE4->BE4_NRAOPE)
			cMatric		:= BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
			cTipoGrv	:= BE4->BE4_TPGRV
			cCDPFSO		:= BE4->BE4_CDPFSO
			cCDPFEX		:= BE4->BE4_CDPFRE
			dDatPro		:= BE4->BE4_DATPRO
			cHora 		:= BE4->BE4_HORPRO
			cGuiInt		:= BE4->BE4_GUIINT

			cChaveTmp := iif( empty(aSeqRec), cChaveG, cCodOpe + cCodLdp + cCodPeg + cNumero + cOriMov)
			fDadosBD6( cChaveTmp, iif (cTipRec == "1", BE4->BE4_NUMERO, ""), aSeqRec, @aItens )

			aArea := BE4->(getArea())

			if lRecursada
				
				cAlias := "BD5"
				cRet := PLSICM(	cOpeMov, cMatric, cTipoGrv, cLocalExec, cCDPFSO, cCDPFEX, dDatPro, cHora, cNumImp, cCodRda, cRCCodLDP,;
								cTipo, cCodLoc, cCodEsp, cTipGui, cCidPri, nQtNasV,nQtNasM, nQtNasP, nQtObtP, nQtObAR, cTipFat, cCidObt,cNrdCob,;
								cObtMul, cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,cAlias,lHonor,cOriMovRC,cNumSol,nil,lAtuPeg,;
								cPadCon, dDtAlta,cHrAlta,cEmgest,cAborto, cTraGra, cComurp,cAtespa,cComnal,cBaipes,cPaareo,cPatnor,cTipSai,;
								cTipCon, cNomUsrCar,dDtPar,cTipoAte,cGrpInt,cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,;
								cEspExe, cTipAdm,cRegint,cCarSol,nil,cAteRN,lImpTxt,cFase,cSituac,cGuiOri,cCnes,aCriticas,dDtIniFat,cHrIniFat,;
								dDtFimFat, cHrFimFat, lnInfEquip, lXmlOrigS, aEspCbXML, cGuiPri, lImpXml, lChkByFase, cTipPac, cTipAto, cParCop,;
								cTipMaj, iif( cTipRec == "1", {cTipRec, cNewPegPro}, {'',''}),,cGuiInt )
				
				//Vamos posicionar na guia novamente e realizar a MF
				cNewPegPro := BCI->BCI_CODPEG
				fPosiMudFas(cRet)

			endif

			//Como na inclusão da guia e nas demais funções tem manipulção da BD5, restauramos a area original encontrada e limpamos todas as variáveis.
			Restarea(aArea)
			fLimpVarArr(@aItens, @cOpeMov, @cCodEmp, @cAnoAut, @cMesAut, @cNumAut, @cNumImp, @cTipFat, @cLotGui, @cNumSol, @cTipSai, @cTipCon, @cNomUsrCar, @cTipoAte, @cIndAci, @cUndDoe,;
			            @nTmpDoe, @cTipDoe, @cMsg01, @cEspSol, @cEspEXe, @cTipAdm, @cAteRN,	@cSituac, @cGuiOri, @cCnes, @cGuiPri, @cTipPac, @cTipAto, @cParCop, @cTipMaj,;
						@cCodRda, @cCodLoc, @cCodEsp, @cCidPri, @cNumLib, @cMatric, @cTipoGrv, @cCDPFSO, @cCDPFEX, @dDatPro,;
						@nQtNasV, @nQtNasM, @nQtNasP, @nQtObtP, @nQtObAR, @cCidObt, @cNrdCob, @cObtMul, @cTipAlt, @cNrdCnv, @cPadCon, @dDtAlta, @cHrAlta, @cEmgest, @cAborto, @cTragra,;
						@cComurp, @cAtespa, @cComnal, @cBaipes, @cPaareo, @cPatNor, @cGrpInt, @cTipInt, @cMsg02, @cRegInt, @cAteRN, @dDtIniFat, @cHrIniFat, @dDtFimFat, @cHrFimFat)

			BE4->(DbSkip())
		enddo	
	
	endif

endif

return cRet


/*//-------------------------------------------------------------------
{Protheus.doc} fDadosBD6
Alimenta array de itens com os dados da BD6
@since    04/2019
//-------------------------------------------------------------------*/
static function fDadosBD6 (cChavePesq, cNumero, aSeqItens, aResult)
local nItem 	:= 0
local cPesqCha	:= cChavePesq + iif(empty(cNumero), "", cNumero )
Local aTpPRec := {}

BD6->(DbSetOrder(1))
BD7->(dbSetOrder(1))
if !empty(aSeqItens)
	for nItem := 1 To Len(aSeqItens)
		If BD6->(MsSeek( xfilial("BD6") + cPesqCha + aSeqItens[nItem][1] ))
			if BD6->BD6_TIPGUI == "06" .AND. BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While !(BD7->(EoF())) .AND. xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					AaDd( aTpPRec,;
					{ BD7->BD7_CODTPA,;
					BD6->BD6_CODRDA,;
					"",;
					"",;
					"",;
					"",;
					"",;
					.T.,;
					BD6->BD6_CODRDA,;
					BD6->BD6_CODESP,;
					{BD7->BD7_CODUNM} } )
					BD7->(dbskip())
				EndDo
			endif
			aadd(aResult,{	{"SEQMOV" , BD6->BD6_SEQUEN },;
				{"CODPAD" , BD6->BD6_CODPAD },;
				{"CODPRO" , BD6->BD6_CODPRO },;
				{"CDPDRC" , BD6->BD6_CDPDRC },;
				{"PROREL" , BD6->BD6_PROREL },;
				{"TPEVCT" , BD6->BD6_TPEVCT },;
				{"PERVIA" , BD6->BD6_PERVIA },;
				{"VLRAPR" , aSeqItens[nItem][2] },;
				{"PRTXPG" , 0				},;
				{"NIVAUT" , BD6->BD6_NIVAUT },;
				{"NIVCRI" , BD6->BD6_NIVCRI },;
				{"CHVNIV" , BD6->BD6_CHVNIV },;
				{"PAGATO" , BD6->BD6_PAGATO },;
				{"QTD"	  , BD6->BD6_QTDPRO },;
				{"QTDAUT" , BD6->BD6_QTDPRO },;
				{"HORINI" , BD6->BD6_HORPRO },; 
				{"DATPRO" , BD6->BD6_DATPRO },;
				{"TECUT"  , BD6->BD6_TECUTI },;
				{"ATPPAR" , aclone(aTpPRec) };
				} )

				aTpPRec := {}
		endif
	Next
else
	If BD6->(MsSeek(xfilial("BD6") + cPesqCha))
		while !BD6->(eof()) .and. xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xFilial('BD6') + cPesqCha
			if BD6->BD6_TIPGUI == "06" .AND. BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While !(BD7->(EoF())) .AND. xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					AaDd( aTpPRec,;
					{ BD7->BD7_CODTPA,;
					BD6->BD6_CODRDA,;
					"",;
					"",;
					"",;
					"",;
					"",;
					.T.,;
					BD6->BD6_CODRDA,;
					BD6->BD6_CODESP,;
					{BD7->BD7_CODUNM} } )
					BD7->(dbskip())
				EndDo
			endif
			aadd(aResult,{	{"SEQMOV" , BD6->BD6_SEQUEN },;
				{"CODPAD" , BD6->BD6_CODPAD },;
				{"CODPRO" , BD6->BD6_CODPRO },;
				{"CDPDRC" , BD6->BD6_CDPDRC },;
				{"PROREL" , BD6->BD6_PROREL },;
				{"TPEVCT" , BD6->BD6_TPEVCT },;
				{"PERVIA" , BD6->BD6_PERVIA },;
				{"VLRAPR" , BD6->BD6_VLRAPR },;
				{"PRTXPG" , BD6->BD6_PRTXPG	},;
				{"NIVAUT" , BD6->BD6_NIVAUT },;
				{"NIVCRI" , BD6->BD6_NIVCRI },;
				{"CHVNIV" , BD6->BD6_CHVNIV },;
				{"PAGATO" , BD6->BD6_PAGATO },;
				{"QTD"	  , BD6->BD6_QTDPRO },;
				{"QTDAUT" , BD6->BD6_QTDPRO },; 
				{"HORINI" , BD6->BD6_HORPRO },; 
				{"DATPRO" , BD6->BD6_DATPRO },;
				{"TECUT"  , BD6->BD6_TECUTI },;
				{"ATPPAR" , aclone(aTpPRec) },;
				{"VALORIRG", BD6->BD6_VALORI}}	)

				aTpPRec := {}
			BD6->(DbSkip())	
		enddo
	endif
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} fPosiMudFas
Psociona na guia recém gerada e realiza a MF
@since    04/2019
//-------------------------------------------------------------------*/
static function fPosiMudFas(cGuiaPeg)
local cCodigo := alltrim(STRTRAN(STRTRAN(cGuiaPeg,"-","")," ",""))
local nRecBD5 := 0

BD5->(DbSetOrder(1)) 
if ( BD5->(MsSeek(xfilial("BD5") + cCodigo)) ) 
	nRecBD5 := BD5->(recno())
	PLSA500FAS("BD5", nRecBD5, 5, nil, .f., .f., .t.)
	PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} fLimpVarArr
Liompa as variáveis usadas para gerar as guias e os arrays
@since    04/2019
//-------------------------------------------------------------------*/
static function fLimpVarArr(aItens, cOpeMov, cCodEmp, cAnoAut, cMesAut, cNumAut, cNumImp, cTipFat, cLotGui, cNumSol, cTipSai, cTipCon, cNomUsrCar, cTipoAte, cIndAci, cUndDoe,;
			            nTmpDoe, cTipDoe, cMsg01, cEspSol, cEspEXe, cTipAdm, cAteRN,	cSituac, cGuiOri, cCnes, cGuiPri, cTipPac, cTipAto, cParCop, cTipMaj,;
						cCodRda, cCodLoc, cCodEsp, cCidPri, cNumLib, cMatric, cTipoGrv, cCDPFSO, cCDPFEX, dDatPro,;
						nQtNasV, nQtNasM, nQtNasP, nQtObtP, nQtObAR, cCidObt, cNrdCob, cObtMul, cTipAlt, cNrdCnv, cPadCon, dDtAlta, cHrAlta, cEmgest, cAborto, cTragra,;
						cComurp, cAtespa, cComnal, cBaipes, cPaareo, cPatNor, cGrpInt, cTipInt, cMsg02, cRegInt, cAteRN, dDtIniFat, cHrIniFat, dDtFimFat, cHrFimFat)

if ( len(aItens) > 0 )
	while Len(aItens) > 0
		aDel(aItens,len(aItens))
		aSize(aItens, len(aItens)-1)	
	enddo
	aItens := {}
endif

//limpar variavéis quando for glosa por PEG, garantindo valores certos. Abaixo, economiza na contagem de linhas do fonte;
cOpeMov 	:= ""; cCodEmp		:= ""; cAnoAut		:= ""; cMesAut		:= ""; cNumAut		:= ""; cNumImp		:= ""; cTipFat		:= ""
cLotGui		:= ""; cNumSol		:= ""; cTipSai		:= ""; cTipCon		:= ""; cNomUsrCar	:= ""; cTipoAte		:= ""; cIndAci		:= ""
cUndDoe		:= ""; nTmpDoe 		:= 0 ; cTipDoe 		:= ""; cMsg01 		:= ""; cEspSol		:= ""; cEspEXe		:= ""; cTipAdm		:= ""
cAteRN		:= ""; cSituac		:= ""; cGuiOri		:= ""; cCnes		:= ""; cGuiPri		:= ""; cTipPac		:= ""; cTipAto		:= ""
cParCop		:= ""; cTipMaj 		:= ""; cCodRda		:= ""; cCodLoc		:= ""; cCodEsp		:= ""; cCidPri		:= ""; cNumLib		:= ""
cMatric		:= ""; cTipoGrv		:= ""; cCDPFSO		:= ""; cCDPFEX		:= ""; dDatPro		:= stod('')
//BE4
nQtNasV 	:= 0 ; nQtNasM 		:= 0 ; nQtNasP		:= 0 ; nQtObtP		:= 0 ; nQtObAR		:= 0 ; cCidObt		:= ""; cNrdCob		:= ""
cObtMul		:= ""; cTipAlt		:= ""; cNrdCnv		:= ""; cPadCon		:= ""; dDtAlta		:= ""; cHrAlta		:= ""; cEmgest		:= ""
cAborto		:= ""; cTragra		:= ""; cComurp		:= ""; cAtespa		:= ""; cComnal		:= ""; cBaipes		:= ""; cPaareo		:= ""
cPatNor		:= ""; cGrpInt		:= ""; cTipInt		:= "";cMsg02		:= ""; cRegInt		:= ""; cAteRN		:= ""; cHrFimFat	:= ""
dDtIniFat	:= stod(''); cHrIniFat	:= stod(''); dDtFimFat	:= stod('')

return


/*//-------------------------------------------------------------------
{Protheus.doc} PlsDelGuias
Função que realiza a exclusão da PEG e guias quando for chamado a rotina de exclusão da Análise, verificando se pode ou não cancelar.
@since    04/2019
//-------------------------------------------------------------------*/
static function PlsDelGuias(cCodOpe, cCodLdp, cCodPeg, cNumero, cTipRec)
local lRet 		:= .t.
local cSql 		:= ""
local aAreas	:= {"BD5", "BD6", "BD7"}
local nI		:= 0

cSql := " SELECT BCI_STTISS FROM " + RetsqlName("BCI")
cSql += " WHERE BCI_FILIAL = '" + xFilial("BCI") + "' "
cSql += " AND BCI_CODOPE = '" + cCodOpe + "' "
cSql += " AND BCI_CODLDP = '" + cCodLdp + "' "
cSql += " AND BCI_CODPEG = '" + cCodPeg + "' "
cSql += " AND BCI_STTISS IN ('1','2') " //"1=Recebido;2=Em análise;
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"QRYMOD",.f.,.t.)

if !QRYMOD->(eof())

	cSql := ""
	//Contar se existem outras guias na PEG, quando for Guia ou Itens. Se for única, iremos excluir a PEG
	cSql := " SELECT COUNT(BD5_FILIAL) TOT FROM " + RetsqlName("BD5")
	cSql += "    WHERE BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSql += "      AND BD5_CODOPE = '" + cCodOpe + "' "
	cSql += "      AND BD5_CODLDP = '" + cCodLdp + "' "
	cSql += "      AND BD5_CODPEG = '" + cCodPeg + "' "
	cSql += "      AND D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"TOTPEG",.f.,.t.)
	nI := TOTPEG->(TOT)
	if nI == 1
		aAreas := {"BD5", "BD6", "BD7", "BCI"}
	endif
	TOTPEG->(dbcloseArea())

	nI 	 := 0
	cSql := ""

	for nI := 1 to len(aAreas)
		cSql := " UPDATE " + RetSQLName(aAreas[nI]) + " SET D_E_L_E_T_ = '*' "
		cSql += iif( PLCHKRCD(aAreas[nI]), " , R_E_C_D_E_L_ = R_E_C_N_O_", "")
		cSql += "    WHERE " + aAreas[nI] + "_FILIAL = '" + xFilial(aAreas[nI]) + "' "
		cSql += "      AND " + aAreas[nI] + "_CODOPE = '" + cCodOpe + "' "
		cSql += "      AND " + aAreas[nI] + "_CODLDP = '" + cCodLdp + "' "
		cSql += "      AND " + aAreas[nI] + "_CODPEG = '" + cCodPeg + "' "
		if aAreas[nI] != "BCI"
			cSql += "      AND " + aAreas[nI] + "_NUMERO = '" + cNumero + "' "
		endif	
		cSql += "      AND D_E_L_E_T_ = ' ' "
		TCSQLExec(cSql)
	next	
else
	lRet := .f.
endif	
QRYMOD->(dbcloseArea())

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlAG3DelAnalise
Se existir Análise, verifica se a guia gerda de Recursod e Glosa pode ser excluída.
Se pode ser excluída, vamos deletar a guia/peg e depois, limpar os campos da análise, mas não excluir o protcolo todo. Essse vai voltar a ficar
no status Recurso Protocolado.
@since    10/2021
//-------------------------------------------------------------------*/
function PlAG3DelAnalise(cCodOpe, cTipRec, cStatusAna)
local aCmpLimpD	:= {"B4D_DCDDLP", "B4D_DCDPEG", "B4D_DNUMER", "B4D_ACAGUI", "B4D_ACAPRO", "B4D_JUSOPE", "B4D_CDGTIS"}
local aHelp		:= {STR0001,'',''}
local aAreaBkp 	:= BCI->(getArea())
local cStatPad	:= "1"
local cCodLdp 	:= ""
local cCodPeg 	:= ""
local cNumero 	:= ""
local lRetExc	:= .t.
local nFor 		:= 0
local oModel	:= FWLoadModel("PLSRECGLO3")
local oObjB4D 	:= oModel:getModel("MasterB4D")
local oObjB4E	:= oModel:getModel("B4EDetail")

oModel:setOperation( 4 ) //Alterar
oModel:activate()

cCodLdp 	:= oObjB4D:getvalue("B4D_DCDDLP")
cCodPeg 	:= oObjB4D:getvalue("B4D_DCDPEG")
cNumero 	:= oObjB4D:getvalue("B4D_DNUMER")

//Deletar a PEG/GUIA caso já tenha sido gerado, cancelando ambas
if ( cStatusAna $ '3,5' .and. !empty(cCodPeg) )
	lRetExc := iif( cTipRec == "1", PLSDELMOV(cCodOpe + cCodLdp + cCodPeg,"1,3"), PlsDelGuias(cCodOpe, cCodLdp, cCodPeg, cNumero, cTipRec) )
endif
Restarea(aAreaBkp)

if lRetExc
	//B4D_STATUS => 1=Rec Glosa Protocolado / B4E_STATUS => 1=Rec Glosa Protocolado
	oObjB4D:Loadvalue("B4D_STATUS", cStatPad)
	oObjB4D:Loadvalue("B4D_TOTACA", 0)

	for nFor := 1 to len(aCmpLimpD)
		oObjB4D:Loadvalue(aCmpLimpD[nFor], "")
	next

	if cTipRec == "3"
		for nFor := 1 to oObjB4E:Length()
			oObjB4E:goLine(nFor)
			oObjB4E:Loadvalue("B4E_STATUS", cStatPad)
			oObjB4E:Loadvalue("B4E_VLRACA", 0)
			oObjB4E:Loadvalue("B4E_JUSOPE", "")
			oObjB4E:Loadvalue("B4E_CDGTIS", "")	
		next
	endif
	
	FWFormCommit( oModel ) 
	aHelp[2] := STR0027 //"Exclusão da Análise do Protocolo de Recurso de Glosa efetuada com sucesso"
else
	aHelp[2] := STR0025 //"A PEG de Destino está no status Faturada ou superior." 
	aHelp[3] := STR0026 //"Não é possivel excluir a PEG de Destino nesses status"
endif

if !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
endif

return
