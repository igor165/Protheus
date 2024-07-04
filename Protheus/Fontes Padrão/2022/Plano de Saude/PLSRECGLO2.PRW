#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'PLSRECGLO2.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRECGLO2
Novo Recurso de Glosa

@author PLS TEAM
@since  01/04/2019
@version P12
/*/
function PLSRECGLO2(lAuto)
	default lAuto := .f.	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B4D')
	oBrowse:SetDescription( "Recurso de Glosa")
	oBrowse:AddLegend("B4D_STATUS == '0'", "BLACK",		STR0063 ) //"Em Edição"
	oBrowse:AddLegend("B4D_STATUS == '1'", "BLUE",		STR0064 ) //"Protocolado"
	oBrowse:AddLegend("B4D_STATUS == '2'", "YELLOW",	STR0065 ) //"Em Analise"
	oBrowse:AddLegend("B4D_STATUS == '3'", "GREEN",		STR0066 ) //"Autorizado"
	oBrowse:AddLegend("B4D_STATUS == '4'", "RED",		STR0067 ) //"Negado"
	oBrowse:AddLegend("B4D_STATUS == '5'", "ORANGE",	STR0068 ) //"Autorizado Parcial" 
	if !lAuto
		oBrowse:Activate()
	endif	
	//0=Rec Glosa Edição;1=Rec Glosa Protocolado;2=Rec Glosa Em Analise;3=Rec Glosa Autorizado;4=Rec Glosa Negado;5=Aut Parcial       
return

/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    04/2019
//-------------------------------------------------------------------*/
static function MenuDef()
Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRECGLO3' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'VIEWDEF.PLSRECGLO2' Operation 3 Access 0
Add Option aRotina Title 'Analisar'   Action 'PLRECALTY()'        Operation 4 Access 0
Add Option aRotina Title 'Excluir'    Action 'staticCall(PLSRECGLO2,PlExclusao, .t.)' Operation 9 Access 0
Add Option aRotina Title 'Alterar Protocolo'   Action 'staticCall(PLSRECGLO2,PlChkAltProt)' Operation 4 Access 0
Add Option aRotina Title 'Anexos'   Action 'MsDocument( "B4D", B4D->( recno() ), 3 )' Operation 4 Access 0

Return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    04/2019
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel 
Local oStrB4D := FWFormStruct(1,'B4D')
Local oStrB4E := FWFormStruct(1,'B4E')

oModel := MPFormModel():New( 'PLSRECGLO2', , {|oModel| ValidaGrid(oModel) } ) 

oStrB4D:AddField('Desc_Glosa', STR0069, 'CODDESGLO', 'C', 250, 0, , , {}, .F.,{||CarregaGlosa(oModel) } , .F., .F., .T., , ) //'Código / Descrição da Glosa'

oModel:addFields('MasterB4D',/*cOwner*/,oStrB4D) 
oModel:AddGrid('B4EDetail', 'MasterB4D', oStrB4E, , { || VldStRecIt(oModel)}) 
oModel:SetRelation( 'B4EDetail', { { 'B4E_FILIAL', 'xFilial( "B4E" ) ' } , ;
										{ 'B4E_SEQB4D', 'B4D_SEQB4D' }        , ;
										{ 'B4E_CODPEG', 'B4D_CODPEG' } }      , ;
										B4E->( IndexKey( 1 ) ) )

oStrB4E:setProperty( "B4E_SEQUEN" , MODEL_FIELD_INIT , 	{ || ""} )
oStrB4D:setProperty( "B4D_ACAGUI" , MODEL_FIELD_INIT , 	{ || ""} )
oStrB4D:setProperty( "B4D_ACAPRO" , MODEL_FIELD_INIT , 	{ || ""} )
oStrB4D:SetProperty( 'B4D_CODPEG' , MODEL_FIELD_VALID,  { || PegExiste(oModel:getModel("MasterB4D"):getValue("B4D_CODPEG"), oModel) } )
oStrB4D:setProperty( "B4D_CODPEG" , MODEL_FIELD_WHEN , 	{ || empTy(oModel:getModel("MasterB4D"):getValue("B4D_OBJREC")) } )
oStrB4D:SetProperty( 'B4D_NUMAUT' , MODEL_FIELD_VALID,  { || HaGlosa(oModel:getModel("MasterB4D"):getValue("B4D_NUMAUT"), oModel) } )
oStrB4D:setProperty( "B4D_NUMAUT" , MODEL_FIELD_WHEN , 	{ || empTy(oModel:getModel("MasterB4D"):getValue("B4D_OBJREC")) } )
oStrB4D:setProperty( "B4D_JUSPRO" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "1"} )
oStrB4D:setProperty( "B4D_JUSGUI" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") == "2"} )
oStrB4D:setProperty( "B4D_TOTREC" , MODEL_FIELD_WHEN , 	{ || oModel:getModel("MasterB4D"):getValue("B4D_OBJREC") $ "1,2"} )
oStrB4E:setProperty( "B4E_VLRREC" , MODEL_FIELD_VALID,  { || StatRecIte(oModel) } )
oStrB4E:setProperty( "B4E_VLRREC" , MODEL_FIELD_WHEN ,  { || !(empty(oModel:getModel("MasterB4D"):getValue("B4D_NUMAUT"))) } )
oStrB4E:setProperty( "B4E_JUSPRE" , MODEL_FIELD_WHEN ,  { || !(empty(oModel:getModel("MasterB4D"):getValue("B4D_NUMAUT"))) } )
//virtuais relativos a BD6 do item
oStrB4E:AddField('Data_Realizacao'	, STR0070	, 'B4E_DATAPROCEDIMENTO', 'D',  8, 0, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_DATPRO") }  , .F., .F., .T., , ) //'Data do Procedimento'
oStrB4E:AddField('Quant_Apresentada', STR0071 	, 'B4E_QTDSOLICITADA'	, 'N', 12, 4, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_QTDAPR") }  , .F., .F., .T., , ) //'Quantidade Apresentada'
oStrB4E:AddField('Quant_Aprovada'	, STR0072  	, 'B4E_QTDAPROVADA'		, 'N', 12, 4, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_QTDPRO") }  , .F., .F., .T., , ) //'Quantidade Aprovada'
oStrB4E:AddField('Valor_Contratado'	, STR0073  	, 'B4E_VLRCONTRATADO'	, 'N', 16, 2, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_VLRBPR") }  , .F., .F., .T., , ) //'Valor Contratado'
oStrB4E:AddField('Valor_Apresentado', STR0074	, 'B4E_VLRAPRESENTADO'	, 'N', 16, 2, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_VLRAPR") }  , .F., .F., .T., , ) //'Valor Apresentado'
oStrB4E:AddField('Valor_Pago'		, STR0075	, 'B4E_VLRPAGO'			, 'N', 16, 2, , , {}, .F.,{||CarregaBD6Val(oModel, "BD6_VLRPAG") }  , .F., .F., .T., , ) //'Valor Pago'
oStrB4E:AddField('Obser_BDX'		, STR0076	, 'OBS_BDX'			    , 'M', 16, 2, , , {}, .F.,{||CarregaBD6Val(oModel, "BDX_OBS", .t.) }  , .F., .F., .T., , ) //'Observação BDX'
oStrB4E:AddField('ComplementoDesc'	, 'ComplementoDesc'			, 'COMPLEMENTO_DESC'    , 'M', 16, 2, , , {}, .F.,								 			, .F., .F., .T., , )

oModel:getModel( 'B4EDetail' ):setNoInsertLine( .F. )
oModel:getModel('B4EDetail'):setOptional(.T.)

oModel:GetModel('MasterB4D'):SetDescription(STR0047) // 'Inclusão Recurso de Glosa'

Return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    04/2019
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView  // Interface de visualização construída
Local oModel  	:= FWLoadModel( 'PLSRECGLO2' ) // Cria as estruturas a serem usadas na View
Local lPRGLOFLD	:= existblock("PRGLOFLD")
Local oStrB4D := FWFormStruct(2, 'B4D', { |cCampo| FilViewB4D(cCampo, lPRGLOFLD) } )
Local oStrB4E := FWFormStruct(2, 'B4E', { |cCampo| FilViewB4E(cCampo, lPRGLOFLD) } )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB4D' , oStrB4D,'MasterB4D' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid( 'ViewB4E' , oStrB4E,'B4EDetail' )

oModel:GetModel( 'B4EDetail' ):SetOptional( .T. )
 
oStrB4D:SetProperty( 'B4D_CODPEG' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_NUMAUT' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_JUSPRO' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_JUSGUI' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_CODPEG' , MVC_VIEW_ORDEM    , "00" )
oStrB4D:SetProperty( 'B4D_NUMAUT' , MVC_VIEW_ORDEM    , "01" )
oStrB4E:SetProperty( 'B4E_VLRREC' , MVC_VIEW_CANCHANGE, .T. )
oStrB4E:SetProperty( 'B4E_JUSPRE' , MVC_VIEW_CANCHANGE, .T. )
oStrB4D:SetProperty( 'B4D_CODPEG' , MVC_VIEW_TITULO   , STR0077) //"Número do Protocolo (PEG)"
oStrB4D:SetProperty( 'B4D_NUMAUT' , MVC_VIEW_TITULO   , STR0078) //"Número da guia dentro do PEG"
oStrB4D:SetProperty( 'B4D_JUSPRO' , MVC_VIEW_TITULO   , STR0079) //"Justificativa do Protocolo - Prestador"
oStrB4D:SetProperty( 'B4D_JUSGUI' , MVC_VIEW_TITULO   , STR0080) //"Justificativa da Guia - Prestador"
//virtuais relativos a BD6 do item
oStrB4E:AddField( 'B4E_DATAPROCEDIMENTO','30', STR0070	, STR0070	,, 'Get' ,"@",,,.F.,,,,,,.T.,, ) //'Data do Procedimento'
oStrB4E:AddField( 'B4E_QTDSOLICITADA'	,'31', STR0071	, STR0071 	,, 'Get' ,"@E 9,999,999.9999",,,.F.,,,,,,.T.,, ) //'Quantidade Apresentada'
oStrB4E:AddField( 'B4E_QTDAPROVADA'		,'32', STR0072	, STR0072	,, 'Get' ,"@E 9,999,999.9999",,,.F.,,,,,,.T.,, ) //'Quantidade Aprovada'
oStrB4E:AddField( 'B4E_VLRCONTRATADO'	,'33', STR0073	, STR0073	,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, ) //'Valor Contratado'
oStrB4E:AddField( 'B4E_VLRAPRESENTADO'	,'34', STR0074	, STR0074	,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, ) //'Valor Apresentado'
oStrB4E:AddField( 'B4E_VLRPAGO'			,'35', STR0075	, STR0075	,, 'Get' ,"@E 9,999,999,999,999.99",,,.F.,,,,,,.T.,, ) //'Valor Pago'
oStrB4E:AddField( 'OBS_BDX'			   	,'36', STR0076	, STR0076   ,, 'Get' ,"@",,,.F.,,,,,,.T.,, ) //'Observação BDX'
oStrB4D:AddField( 'CODDESGLO'			,'99', STR0069	, STR0069	,, 'C' ,"@!",,,.F.,,,,,,.t.,, ) //'Código / Descrição da Glosa'

oStrB4D:SetProperty( 'B4D_DATREC' , MVC_VIEW_CANCHANGE, .F. )

oView:CreateHorizontalBox( 'SUPERIOR' , 30 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR' , 70 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oView:SetOwnerView('ViewB4D','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB4E','INFERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

oView:SetViewProperty( 'ViewB4E', "ENABLEDGRIDDETAIL", { 40 } )

Return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PegExiste
Verifica se o PEG informado possibilita continuar, ou se já corta
cOrigEnt := 1=Remote;2=Portal;3=WSDL;4=XML - Default "1"                                                                                                  
@since    04/2019
//-------------------------------------------------------------------*/
Static function PegExiste( cCodPeg, oModel, cRda, lPortal, cOrigEnt, lMostre )
Local lRet 			:= .F. 
Local nGloRec 		:= 0
local lTentMax		:= .f.
local nTentativa	:= 0
local aHelp			:= {'', '', ''}  //1ª Título da janela / 2ª Texto do problema encontrado / 3ª Solução do problema (opcional)
local nPortal 		:= 0
local cGlo 			:= ""
local cGloTiss  	:= ""
local cVlrGlosa		:= ""
Local cAquiOh 		:= ""

default cRda 		:= ""
default lPortal 	:= .F.
default cOrigEnt	:= iif(IsInCallStack('PLSA974'),"3","1")
Default lMostre 	:= .F.

BCI->(DbSetOrder(14))

if (empTy(cCodPeg)) 
	If cOrigEnt != "3"
		aHelp := {STR0001, STR0002, ''}  // ATENÇÃO / "Informe o número do PEG"
	EndIf
elseif BCI->(MsSeek(xfilial("BCI") + cCodPeg))
	if lPortal .and. !(BCI->BCI_CODRDA == cRda)
		If lMostre
			cAquiOh := STR0081 + cCodPeg + " Prestador : " + cRda //PEG:
		endIf
		aHelp := {STR0001, STR0005 + cAquiOh, ''} //"Verifique se o código da PEG digitado está correto."
		lRet := .F.
	elseif BCI->BCI_VLRGLO > 0
		lRet := .T.
	else
		If lMostre
			cAquiOh := STR0081 + cCodPeg //PEG:
		endIf
		If cOrigEnt != "3"
			aHelp := {STR0003, STR0004 + cAquiOh, ''} // sem glosa / "Não existe glosa no PEG informado"
		EndIf
	endif
else
	If lMostre
		cAquiOh := STR0081 + cCodPeg //PEG:
	endIf
	If cOrigEnt != "3"
		aHelp := {STR0001, STR0005 + cAquiOh, STR0006}  //"Verifique se o código da PEG digitado está correto."
	EndIf
endif

If lRet
	If !(chkPeriodo())
		lRet := .F.
		aHelp := {STR0001, STR0058, STR0059 + Alltrim(Str(BA0->BA0_PRZREC)) + STR0060} //Período para recurso de glosa expirado/O recurso pode ser feito em até/dias a partir da data de pagamento
	endIf
endIf

if lRet	
	B4D->(dbSetOrder(5))  //B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
	if B4D->(MsSeek(xfilial("B4D") + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)))
		if ( UltRecPegGui(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, '', .t.) )
			lRet := .F.
			If lMostre
				cAquiOh := STR0081 + cCodPeg //PEG:
			endIf
			aHelp := {STR0001, STR0007 + cAquiOh, ''} //"Não é possível inserir recurso pois já há um recurso não finalizado para este Protocolo"
		endif
	endif
endif

if lRet
	nGloRec := CVlGloAcat(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
	lRet := BCI->BCI_VLRGLO > nGloRec
	B4D->(dbSetOrder(5))
	if !lRet //.and. ( B4D->(MsSeek(xfilial("B4D") + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG))) .AND. B4D->B4D_OBJREC == "1" )
		If lMostre
			cAquiOh := STR0081 + cCodPeg //PEG:
		endIf
		aHelp := {STR0001, STR0008 + cAquiOh, STR0014} //'O Protocolo já foi analisado anteriormente e foi acatado integralmente' / "Protocolo Acatado e Autorizado em análise anterior"
	endif
endif

if lRet .AND. !(EmpTy(BCI->BCI_CODGLO))
	nTentativa := SomaRecB4D(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, '', @lTentMax )
	if lTentMax
		If lMostre
			cAquiOh := STR0081 + cCodPeg //PEG:
		endIf
		aHelp := {STR0009, STR0010 + cAquiOh, STR0011} //Tentativa Recurso / "Número máximo de tentativas de recurso alcançado, conforme configuração da Operadora." / "O prestador já recursou a quantidade máxima de tentivas permitidas pela Operadora."
		lRet := .f.
	else
		oModel:getmodel('MasterB4D'):loadValue("B4D_OBJREC", "1")
		If lMostre
			cAquiOh := STR0081 + cCodPeg //PEG:
		endIf
		If cOrigEnt != "3"
			aHelp := {STR0001, STR0012 + cAquiOh, ''} //"O protocolo foi glosado integralmente, o tipo de recurso de glosa a ser incluído será por Protocolo"
		EndIf
		nPortal := 1
	endif	
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	if !lPortal
		Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
	else
		cGlo := deParaSimpl('38', substr(BCI->BCI_CODGLO,2,2), 'BCT')
		cGloTiss := cGlo + " - " + descTissSp('38', cGlo)
		cVlrGlosa:= BCI->BCI_VLRGLO
	    //return {aHelp, nPortal, cGloTiss}
	endif
endif	

if lRet
	setRecGlo(oModel, "MasterB4D", nGloRec, nTentativa, lPortal, "", cOrigEnt)
	if oModel:getmodel('MasterB4D'):getValue("B4D_OBJREC") $ '1,2'
		oModel:getmodel('MasterB4D'):loadValue("B4D_TOTREC", oModel:getmodel('MasterB4D'):getValue("B4D_VLRGLO"))
	endif	
endif

if lPortal
	cGlo := deParaSimpl('38', substr(BCI->BCI_CODGLO,2,2), 'BCT')
	if !empty(cGlo)
		cGloTiss := cGlo + " - " + descTissSp('38', cGlo)
	endif
	if lRet .and. nPortal == 0
		nPortal := 2
	endif
endif

return iif(!lPortal, lRet, {aHelp, nPortal, cGloTiss, cVlrGlosa})


/*//-------------------------------------------------------------------
{Protheus.doc} HaGlosa
Função que valida se existe glosa para a guia ou itens e outras validações
@since    04/2019
//-------------------------------------------------------------------*/
static function HaGlosa( cNumero, oModel, lPortal, cOrigEnt, lMostre )
Local lRet 			:= .f.
Local nGloRec 		:= 0
local lTentMax		:= .f.
local nTentativa	:= 0
local cAlias		:= iif(BCI->BCI_TIPGUI <> "05", "BD5", "BE4") 
local aHelp			:= {'', '', ''}  //1ª Título da janela / 2ª Texto do problema encontrado / 3ª Solução do problema (opcional)
local lTitNBai		:= .f.
local cRGAcTud		:= GetNewPar("MV_PLRGACT","1") //"1" - Apenas Título Baixado / "2" - Lote de Pagamento gerado.
local lVerTit		:= iif(cRGAcTud == "1", .t., .f.)
local aLPNGer		:= {.f.,""}
local nPortal 		:= 4
local cItens    	:= ""
local cVlrGlosa 	:= ""
Local cAquiOh 		:= ""

default lPortal 	:= .f.
default cOrigEnt	:= iif(IsInCallStack('PLSA974'),"3","1")
default lMostre 	:= .F.

if empTy(oModel:getModel("MasterB4D"):getValue("B4D_CODPEG"))
	If cOrigEnt != "3"
		if lPortal
			aHelp := {STR0001, STR0004, ''} //"Não existe glosa no PEG informado."
		else
			aHelp := {STR0001, STR0002, ''} //"Informe o número do PEG."
		endif
	EndIf
else
	if BCI->BCI_TIPGUI <> "05"
		BD5->(DbSetOrder(1))
		if BD5->(MsSeek(xfilial("BD5") + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) + cNumero))
			if !empty(BD5->BD5_NUMLOT)
				aLPNGer := {.t., BD5->BD5_NUMLOT}	
			endif
			lRet := BD5->BD5_VLRGLO > 0
			if !lRet
				If lMostre
					cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG:  //" GUIA: "
				endIf
				aHelp := {STR0001, STR0013 + cAquiOh, ''} //"Não existe glosa na guia informada"
			else
				ngloRec := CVlGloAcat(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,BD5->BD5_NUMERO)
				lRet := BD5->BD5_VLRGLO > ngloRec
				cVlrGlosa := BD5->BD5_VLRGLO
				if ! lRet
					If lMostre
						cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
					endIf
					aHelp := {STR0001, STR0015 + cAquiOh, ''} //"A guia informada já foi totalmente recursada, não há mais saldo de glosa à recursar"
				endif
			endif
		Else
			If lMostre
				cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
			endIf
			If cOrigEnt != "3"
				aHelp := {STR0001, STR0016 + cAquiOh, ''} //"Guia não existe no protocolo"
			EndIf
		endif
	else
		BE4->(DbSetOrder(1))
		if BE4->(MsSeek(xfilial("BD5") + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) + cNumero))
			if !empty(BE4->BE4_NUMLOT)
				aLPNGer := {.t., BE4->BE4_NUMLOT}	
			endif
			lRet := BE4->BE4_VLRGLO > 0
			if !lRet
				If lMostre
					cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
				endIf
				aHelp := {STR0001, STR0017 + cAquiOh, ''} //"Não existe glosa na guia informada"
			else
				ngloRec := CVlGloAcat(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,BE4->BE4_NUMERO)
				lRet := BE4->BE4_VLRGLO > ngloRec
				cVlrGlosa := BE4->BE4_VLRGLO
				if ! lRet
					If lMostre
						cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
					endIf
					aHelp := {STR0001, STR0015 + cAquiOh, ''} //"A guia informada já foi totalmente recursada, não há mais saldo de glosa à recursar"
				endif
			endif
		Else
			If lMostre
				cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
			endIf
			If cOrigEnt != "3"
				aHelp := {STR0001, STR0016 + cAquiOh, ''} //"Guia não existe no protocolo"
			EndIf
		endif
	endif
endif

//Valida se houve baixa. Qualquer valor baixado será considerado baixa. Ou seja, se E2_VALOR <> E2_SALDO, teve baixa, caso contrário, são iguais.
if lRet
	if lVerTit
		lTitNBai 	:= VerfTitBaixa(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, cNumero)
	endif	
	nTentativa 	:= SomaRecB4D(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, cNumero, @lTentMax )
endif

if lRet
	B4D->(dbSetOrder(5))  //B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
	if B4D->(MsSeek(xfilial("B4D") + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) + cNumero))
		if ( UltRecPegGui(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, cNumero, .f.) )
			lRet := .F.
			If lMostre
				cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
			endIf
			aHelp := {STR0001, STR0007 + cAquiOh, ''} //"Não é possível inserir recurso pois já há um recurso não finalizado para este Protocolo."
		endif
	endif
endif

if lRet .AND. !empTy( (cAlias)->&(cAlias+"_CODGLO") ) 
	if lTentMax
		If lMostre
			cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082+ cNumero //PEG: //" GUIA: "
		endIf
		aHelp := {STR0009, STR0010 + cAquiOh, STR0011} //Tentativa Recurso / "Número máximo de tentativas de recurso alcançado, conforme configuração da Operadora." / "O prestador já recursou a quantidade máxima de tentivas permitidas pela Operadora."
		lRet := .f.
	else
		If lMostre
			cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082+ cNumero //PEG: //" GUIA: "
		endIf
		oModel:getmodel('MasterB4D'):loadValue("B4D_OBJREC", "2")
		If cOrigEnt != "3" 
			aHelp := {STR0001, STR0018 + cAquiOh, ''} //Esta Guia foi glosada integralmente, o tipo de recurso de glosa a ser incluído será o por Guia.
		EndIf
		nPortal := 3
	endif	
endif

if ( lRet .and. empty( (cAlias)->&(cAlias+"_CODGLO") ) )
	if lTentMax
		If lMostre
			cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
		endIf
		aHelp := {STR0009, STR0010 + cAquiOh, STR0011} //Tentativa Recurso / "Protocolo Acatado e Autorizado em análise anterior" / "O prestador já recursou a quantidade máxima de tentivas permitidas pela Operadora."
		lRet := .f.
	endif	
	if !lTitNBai .and. lVerTit
		If lMostre
			cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
		endIf
		aHelp := {STR0001, STR0033 + cAquiOh, STR0034}  //"O título financeiro referente a PEG da qual essa guia faz parte ainda não foi baixado." / "Só é possível incluir Recurso de Glosa para itens quando o título financeiro referente a PEG for baixado."
		lRet  := .f. 
	elseif !lVerTit .and. !aLPNGer[1]
		If lMostre
			cAquiOh := STR0081 + BCI->BCI_CODPEG + STR0082 + cNumero //PEG: //" GUIA: "
		endIf
		aHelp := {STR0001, STR0052 + cAquiOh, STR0053}  //"O lote de Pagamento não foi gerado." / "É necessário gerar lote de pagamento associado a guia, para efetuar a inclusão do Protocolo de Recurso de Glosa.
		lRet  := .f. 
	endif	
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	if !lPortal
		Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
	else 
		cGlo := deParaSimpl('38', substr((cAlias)->&(cAlias+"_CODGLO"),2,2), 'BCT')
		cGloTiss := cGlo + " - " + descTissSp('38', cGlo)
		return {aHelp, nPortal, cGloTiss, cItens, cVlrGlosa}
	endif
endif	

if lRet
	if !lPortal
		setRecGlo(oModel, "MasterB4D", ngloRec, nTentativa, lPortal, aLPNGer[2], cOrigEnt )
	else
		cItens := setRecGlo(oModel, "MasterB4D", ngloRec, nTentativa, lPortal, aLPNGer[2], cOrigEnt )
	endif
	
	if oModel:getmodel('MasterB4D'):getValue("B4D_OBJREC") $ '1,2'
		oModel:getmodel('MasterB4D'):loadValue("B4D_TOTREC", oModel:getmodel('MasterB4D'):getValue("B4D_VLRGLO"))
	endif 
endif

if lPortal
	cGlo := deParaSimpl('38', substr((cAlias)->&(cAlias+"_CODGLO"),2,2), 'BCT')
	cGloTiss := cGlo + " - " + descTissSp('38', cGlo)
	if lRet .and. nPortal == 4
		nPortal := 5
	endif
	return {aHelp, nPortal, cGloTiss, cItens, cVlrGlosa}
endif
	
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} setRecGlo
Essa função faz o preenchimento do modelo de dados para gravação
cOrigEnt := 1=Remote;2=Portal;3=WSDL;4=XML - Default "1"    
@since    04/2019
//-------------------------------------------------------------------*/
Static function setRecGlo(oModel, cModel, nGloRec, nInclRec, lPortal, cNumLote, cOrigEnt)
Local ncount 	:= 1
Local oModelIte := oModel:getmodel("B4EDetail")
Local aGlosa 	:= {}
Local cTipoRec 	:= oModel:getmodel(cModel):getValue("B4D_OBJREC")
Local nIteRec	:= 0
local nValorGlo	:= 0
local cItens    := 0
default nInclRec:= 0
default lPortal := .f.
default cNumLote:= ""
default cOrigEnt:= "1"

/*B4D*/
oModel:getmodel(cModel):loadValue("B4D_FILIAL", xFilial("B4D"))
oModel:getmodel(cModel):loadValue("B4D_SEQB4D", GETSX8NUM("B4D","B4D_SEQB4D")) //Preencher somente na gravação
oModel:getmodel(cModel):loadValue("B4D_OPEMOV", BCI->BCI_CODOPE)
oModel:getmodel(cModel):loadValue("B4D_ANOAUT", BCI->BCI_ANO)
oModel:getmodel(cModel):loadValue("B4D_MESAUT", BCI->BCI_MES)
oModel:getmodel(cModel):loadValue("B4D_CODLDP", BCI->BCI_CODLDP)
oModel:getmodel(cModel):loadValue("B4D_CODPEG", BCI->BCI_CODPEG)
oModel:getmodel(cModel):loadValue("B4D_STATUS", "1") //Esse campo terá o status do Protocolo de recurso de glosa
oModel:getmodel(cModel):loadValue("B4D_TIPGUI", BCI->BCI_TIPGUI)
oModel:getmodel(cModel):loadValue("B4D_DATSOL", dDataBase)
oModel:getmodel(cModel):loadValue("B4D_NGLOPE", BCI->BCI_ANO + BCI->BCI_MES + PLNUMAUT(BCI->BCI_CODOPE,BCI->BCI_ANO,BCI->BCI_MES)) //Prencher na gravação somente
oModel:getmodel(cModel):loadValue("B4D_CODRDA", BCI->BCI_CODRDA)
oModel:getmodel(cModel):loadValue("B4D_NOMCON", AllTrim(BCI->BCI_NOMRDA))
oModel:getmodel(cModel):loadValue("B4D_GLOPRT", BCI->BCI_CODGLO)
oModel:getmodel(cModel):loadValue("B4D_DATREC", dDataBase)
oModel:getmodel(cModel):loadValue("B4D_REGANS", BA0->BA0_SUSEP)
oModel:getmodel(cModel):loadValue("B4D_NOMOPE", Alltrim(BA0->BA0_NOMINT))
oModel:getmodel(cModel):loadValue("B4D_ORIENT", cOrigEnt)
//So gravo NUMLOT e OPELOT quando vier valor da função HASGLOSA, pois indica que a Operadora usa o parâmetro MV_PLRGACT como "2"
if !empty(cNumLote)
	oModel:getmodel(cModel):loadValue("B4D_NUMLOT", cNumLote)
	oModel:getmodel(cModel):loadValue("B4D_OPELOT", BCI->BCI_CODOPE)
endif	

if !(empTy(BCI->BCI_CODGLO))
	oModel:getmodel(cModel):loadValue("B4D_OBJREC", "1") //Esse campo define se é recurso por PEG, GUIA ou ITEM. Vai ser importante.
	cTipoRec := "1"
	oModel:getmodel(cModel):loadValue("B4D_VLRGLO", BCI->BCI_VLRGLO - nGloRec )
	oModel:getmodel(cModel):loadValue("B4D_TOTACA", nGloRec )
	aGlosa := Pls498DesG(BCI->BCI_CODGLO, BCI->BCI_CODOPE)	
	oModel:getmodel(cModel):loadValue("CODDESGLO", aGlosa[1] + ' - ' + aGlosa[2])
endif

if EmpTy(cTipoRec) .OR. cTipoRec <> "1"
	if BCI->BCI_TIPGUI <> "05"
		BD5->(dbsetOrder(1))
		BD5->(MsSeek(xFilial("BD5") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + oModel:getmodel(cModel):getValue("B4D_NUMAUT")))
			
		oModel:getmodel(cModel):loadValue("B4D_ORIMOV", BD5->BD5_ORIMOV)
		oModel:getmodel(cModel):loadValue("B4D_NUMAUT", BD5->BD5_NUMERO)
		oModel:getmodel(cModel):loadValue("B4D_USUARI", BD5->( BD5_OPEUSR + BD5_CODEMP + BD5_MATRIC + BD5_TIPREG + BD5_DIGITO ))
		oModel:getmodel(cModel):loadValue("B4D_OPEUSR", BD5->BD5_OPEUSR)
		oModel:getmodel(cModel):loadValue("B4D_CODEMP", BD5->BD5_CODEMP)
		oModel:getmodel(cModel):loadValue("B4D_CONEMP", BD5->BD5_CONEMP)
		oModel:getmodel(cModel):loadValue("B4D_SUBCON", BD5->BD5_SUBCON)
		oModel:getmodel(cModel):loadValue("B4D_VERCON", BD5->BD5_VERCON)
		oModel:getmodel(cModel):loadValue("B4D_VERSUB", BD5->BD5_VERSUB)
		oModel:getmodel(cModel):loadValue("B4D_MATRIC", BD5->BD5_MATRIC)
		oModel:getmodel(cModel):loadValue("B4D_TIPREG", BD5->BD5_TIPREG)
		oModel:getmodel(cModel):loadValue("B4D_DIGITO", BD5->BD5_DIGITO)
		oModel:getmodel(cModel):loadValue("B4D_NOMUSR", BD5->BD5_NOMUSR)
		oModel:getmodel(cModel):loadValue("B4D_SENHA" , BD5->BD5_SENHA)
	
		if !(empTy(BD5->BD5_CODGLO))
			aGlosa := Pls498DesG(BD5->BD5_CODGLO,BCI->BCI_CODOPE)		
			oModel:getmodel(cModel):loadValue("B4D_GLOPLS", aGlosa[1])
			oModel:getmodel(cModel):loadValue("B4D_DESGLO", aGlosa[2])
			oModel:getmodel(cModel):loadValue("B4D_GLOGUI", aGlosa[3])
			oModel:getmodel(cModel):loadValue("B4D_OBJREC", "2") //Esse campo define se é recurso por PEG, GUIA ou ITEM. Vai ser importante.
			oModel:getmodel(cModel):loadValue("B4D_VLRGLO", BD5->BD5_VLRGLO - nGloRec )
			oModel:getmodel(cModel):loadValue("CODDESGLO", aGlosa[1] + ' - ' + aGlosa[2])
		endif
	else
		BE4->(DbsetOrder(1))
		BE4->(MsSeek(xFilial("BE4") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + oModel:getmodel(cModel):getValue("B4D_NUMAUT")))
		
		oModel:getmodel(cModel):loadValue("B4D_ORIMOV", BE4->BE4_ORIMOV)
		oModel:getmodel(cModel):loadValue("B4D_NUMAUT", BE4->BE4_NUMERO)
		oModel:getmodel(cModel):loadValue("B4D_USUARI", BE4->( BE4_OPEUSR + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO ))
		oModel:getmodel(cModel):loadValue("B4D_OPEUSR", BE4->BE4_OPEUSR)
		oModel:getmodel(cModel):loadValue("B4D_CODEMP", BE4->BE4_CODEMP)
		oModel:getmodel(cModel):loadValue("B4D_CONEMP", BE4->BE4_CONEMP)
		oModel:getmodel(cModel):loadValue("B4D_SUBCON", BE4->BE4_SUBCON)
		oModel:getmodel(cModel):loadValue("B4D_VERCON", BE4->BE4_VERCON)
		oModel:getmodel(cModel):loadValue("B4D_VERSUB", BE4->BE4_VERSUB)
		oModel:getmodel(cModel):loadValue("B4D_MATRIC", BE4->BE4_MATRIC)
		oModel:getmodel(cModel):loadValue("B4D_TIPREG", BE4->BE4_TIPREG)
		oModel:getmodel(cModel):loadValue("B4D_DIGITO", BE4->BE4_DIGITO)
		oModel:getmodel(cModel):loadValue("B4D_NOMUSR", BE4->BE4_NOMUSR)
		oModel:getmodel(cModel):loadValue("B4D_SENHA" , BE4->BE4_SENHA)
	
		if !(empTy(BE4->BE4_CODGLO))
			aGlosa := Pls498DesG(BE4->BE4_CODGLO,BCI->BCI_CODOPE)		
			oModel:getmodel(cModel):loadValue("B4D_GLOPLS", aGlosa[1])
			oModel:getmodel(cModel):loadValue("B4D_DESGLO", aGlosa[2])
			oModel:getmodel(cModel):loadValue("B4D_GLOGUI", aGlosa[3])
			oModel:getmodel(cModel):loadValue("B4D_OBJREC", "2") //Esse campo define se é recurso por PEG, GUIA ou ITEM. Vai ser importante.
			oModel:getmodel(cModel):loadValue("B4D_VLRGLO", BE4->BE4_VLRGLO - nGloRec )
			oModel:getmodel(cModel):loadValue("CODDESGLO", aGlosa[1] + ' - ' + aGlosa[2])
		endif
	endif

	if empTy(cTipoRec) .OR. !( cTipoRec $ '1,2' )
		//B4E
		BD6->(DbSetOrder(1))
		if BD6->(MsSeek(  xfilial("BD6") + BCI->BCI_CODOPE + BCI->BCI_CODLDP + BCI->BCI_CODPEG + oModel:getmodel(cModel):getValue("B4D_NUMAUT")  ))
			oModelIte:setNoInsertLine( .f. )
			While !(BD6->(EoF())) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xfilial("BD6") + BCI->BCI_CODOPE + BCI->BCI_CODLDP + BCI->BCI_CODPEG + oModel:getmodel(cModel):getValue("B4D_NUMAUT")
				if BD6->BD6_VLRGLO > 0
					nIteRec	:= IVlGloAcat(BD6->BD6_CODOPE,BD6->BD6_CODLDP,BD6->BD6_CODPEG,BD6->BD6_NUMERO,BD6->BD6_SEQUEN,BD6->BD6_ORIMOV)

					if BD6->BD6_VLRGLO <= nIteRec
						BD6->(DbSkip())
						loop
					endif

					aGlosa := Pls498DesG("",BD6->BD6_CODOPE,BD6->BD6_CODLDP,BD6->BD6_CODPEG,BD6->BD6_NUMERO,BD6->BD6_ORIMOV,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN)
					if(ncount > 1)
						oModelIte:AddLine()
					endif
					//Seto os valores no model
					oModelIte:Goline( ncount )
					oModelIte:LoadValue("B4E_FILIAL" , xFilial("B4E") )
					oModelIte:LoadValue("B4E_OPEMOV" , Alltrim(BD6->BD6_CODOPE) )
					oModelIte:LoadValue("B4E_MESAUT" , Alltrim(BD6->BD6_MESPAG) )
					oModelIte:LoadValue("B4E_ANOAUT" , Alltrim(BD6->BD6_ANOPAG) )
					oModelIte:LoadValue("B4E_NUMAUT" , Alltrim(BD6->BD6_NUMERO) )
					oModelIte:LoadValue("B4E_SEQUEN" , Alltrim(BD6->BD6_SEQUEN) )
					oModelIte:LoadValue("B4E_SEQB4D" , Alltrim(oModel:getmodel(cModel):getValue("B4D_SEQB4D")))
					oModelIte:LoadValue("B4E_CODLDP" , Alltrim(BD6->BD6_CODLDP) )
					oModelIte:LoadValue("B4E_ORIMOV" , Alltrim(BD6->BD6_ORIMOV) )
					oModelIte:LoadValue("B4E_CODPEG" , Alltrim(BD6->BD6_CODPEG) )
					oModelIte:LoadValue("B4E_TIPGUI" , Alltrim(BCI->BCI_TIPGUI) )
					oModelIte:LoadValue("B4E_DATPRO" , (BD6->BD6_DATPRO) )
					oModelIte:LoadValue("B4E_CODPAD" , Alltrim(BD6->BD6_CODPAD) )
					oModelIte:LoadValue("B4E_CODPRO" , Alltrim(BD6->BD6_CODPRO) )
					oModelIte:LoadValue("B4E_DESPRO" , fPrenchVazio(Alltrim(BD6->BD6_DESPRO), "C") )
					oModelIte:LoadValue("B4E_STATUS" , "0" )
					oModelIte:LoadValue("B4E_CODGLO" , fPrenchVazio(Alltrim(aGlosa[1]), "C") )
					oModelIte:LoadValue("B4E_GLOTIS" , fPrenchVazio(Alltrim(aGlosa[3]), "C") )
					oModelIte:LoadValue("B4E_VLRGLO" , (BD6->BD6_VLRGLO) )
					oModelIte:LoadValue("B4E_VLRACA" , /*nIteRec*/0 )
					oModelIte:LoadValue("B4E_SLDREC" , BD6->BD6_VLRGLO - nIteRec )
					oModelIte:LoadValue("B4E_DESGLO" , fPrenchVazio(substr(Alltrim(aGlosa[2]),1,200), "C") ) //e99
					If len(aGlosa[2]) > 200
						oModelIte:LoadValue("COMPLEMENTO_DESC" , fPrenchVazio(substr(Alltrim(aGlosa[2]),201,len(aGlosa[2])), "C") ) //e99
					Endif
					oModelIte:LoadValue("B4E_GLOPLS" , fPrenchVazio(Alltrim(aGlosa[1]), "C") )
					oModelIte:LoadValue('B4E_DATAPROCEDIMENTO', BD6->BD6_DATPRO)
					oModelIte:LoadValue('B4E_QTDSOLICITADA'	 , BD6->BD6_QTDAPR)  //Apresentada
					oModelIte:LoadValue('B4E_QTDAPROVADA'	 , BD6->BD6_QTDPRO)  //Liberada
					oModelIte:LoadValue('B4E_VLRCONTRATADO'	 , BD6->BD6_VLRBPR)
					oModelIte:LoadValue('B4E_VLRAPRESENTADO'	 , BD6->BD6_VLRAPR)
					oModelIte:LoadValue('B4E_VLRPAGO'		 , BD6->BD6_VLRPAG)
					oModelIte:LoadValue("B4E_QTDIRP" , nInclRec )
					oModelIte:LoadValue("OBS_BDX" , fPrenchVazio(CarregaBDXMEMO(BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO + BD6_SEQUEN + aGlosa[1]), "BDX_OBS"), "C") )
					
					ncount++
					aGlosa := {}
					nValorGlo += BD6->BD6_VLRGLO
				endif
				BD6->(DbSkip())
			EndDo
			if nCount > 1
				oModel:getmodel(cModel):loadValue("B4D_OBJREC", "3") //Esse campo define se é recurso por PEG, GUIA ou ITEM. Vai ser importante.
				oModel:getmodel(cModel):loadValue("B4D_VLRGLO", nValorGlo)
				oModelIte:setNoInsertLine( .T. )  //não inserir linha após o load de todos os itens para glosa
			endif
			oModelIte:Goline( 1 )
		endif
	endif
endif

if nInclRec > 0
	oModel:getmodel(cModel):loadValue("B4D_QTDIRP", nInclRec )
endif

if lPortal .and. nCount > 1
	cItens := DecodeUTF8(oModelIte:GetJSONData(), "cp1252") //Para converter os caracteres acentuados de forma correta
	return cItens
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} ValidaGrid
função que valida se os dados do grid - B4E - estão preenchidos corretamente.
@since    04/2019
//-------------------------------------------------------------------*/
Static function ValidaGrid(oModel)
Local nI 		:= 1
Local oB4E 		:= oModel:getmodel("B4EDetail")
local lExclusao	:= iif(oModel:nOperation == MODEL_OPERATION_DELETE, .t., .f.) 
Local lGrava 	:= iif(lExclusao, .t., .f.)
Local aRegDel 	:= {}
local aHelp		:= {'', '', ''}
local lControl	:= .f.
local nValorRec	:= 0
local cPortal	:= oModel:getmodel("MasterB4D"):getValue("B4D_ORIENT")

if !lExclusao
	if oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") == "3"
		For nI := 1 to oB4E:Length()
			oB4E:GoLine(nI)
			nValorRec += oB4E:getValue("B4E_VLRREC")
			if oB4E:getValue("B4E_STATUS") == "0"
				if !(oB4E:IsDeleted())
					aadd(aRegDel, nI)
					oB4E:DeleteLine()
				endif
			else
				lGrava := .T.
			endif
		Next
	else
		lGrava := .t.
	endif

	if !lGrava .and. oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") == "3"
		For nI := 1 to Len(aRegdel)
			oB4E:GoLine(aRegdel[nI])
			oB4E:UnDeleteLine()
		Next
		aHelp := {STR0001, STR0019, STR0020} //"Não é possível realizar a gravação, pois não consta valores de recurso para nenhum item da guia"/ "Informe o valor do recurso para os itens da guia."
	endif

	/*Validação se o Protocolo fica no status Sem recurso ou como Protocolado.
	Caso tenha vários itens para recursar, mas o analista tenha recursardo apenas alguns e clique em salvar, o sistema irá perguntar se o analista realmente deseja gravar, sem considerar os outros itens.*/
	if lGrava .and. len(aRegDel) > 0 
		lControl := .t.
		if (cPortal != "2" .AND. cPortal != "3") .AND. MsgYesNo(STR0036 + CRLF + STR0037 + CRLF + STR0038) //"Existem itens não protocolados!" / "Caso deseje continuar depois, clique no botão SIM, pois todos os itens adicionados serão salvos e o status ficará como 'Sem rec de glosa'." / "Caso queira confirmar o protocolo apenas com os itens protocolados, clique no botão NÃO."
			oModel:getmodel("MasterB4D"):loadValue("B4D_STATUS", "0") //Esse campo terá o status do Protocolo de recurso de glosa
			For nI := 1 to Len(aRegdel)
				oB4E:GoLine(aRegdel[nI])
				oB4E:UnDeleteLine()
			Next
		else
			oModel:getmodel("MasterB4D"):loadValue("B4D_STATUS", "1")
			if cPortal != "3"
				oModel:getmodel("MasterB4D"):loadValue("B4D_PROTOC", GETSX8NUM("B4D","B4D_PROTOC","B4D_PROTOC",8))
			else
				oModel:getmodel("MasterB4D"):loadValue("B4D_PROTOC", "000") //Protocolo temporario para evitar erro de validacao
			endif
		endif 
	endif

	if lGrava .and. !lControl .and. oModel:getmodel("MasterB4D"):getvalue("B4D_STATUS") == "0"
		oModel:getmodel("MasterB4D"):loadValue("B4D_STATUS", "1")
	endif

	if oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") $ '1,2'
		if oModel:getmodel("MasterB4D"):getvalue("B4D_TOTREC") > 0
			if oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") == "1"
				lGrava := !(EmpTy(oModel:getmodel("MasterB4D"):getvalue("B4D_JUSPRO")))
			elseif oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") == "2"
				lGrava := !(EmpTy(oModel:getmodel("MasterB4D"):getvalue("B4D_JUSGUI")))
			endif
			
			if !lGrava
				aHelp := {STR0001, STR0021, STR0022}  //"Não é possível realizar a gravação, pois não foi informada a justificativa do recurso." / "Informe as justificativas necessárias."
			endif
		else
			lGrava := .F.
			aHelp := {STR0001, STR0023, ''} //"Não é possível realizar a gravação, pois não foi informado o valor do recurso."
		endif
	endif

	//Não deixar gravar sem inserir o número de guia, quando for recurso por Guia ou Item
	if empty( oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") ) .or. empty( oModel:getmodel("MasterB4D"):getvalue("B4D_CODPEG") )
		aHelp := {STR0001, STR0061, STR0062} //Informe o número da PEG ou Guia, para continuar o processo./Informe os campos solicitados para continuar.
		lGrava := .f.
	endif

	if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
		Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, nil, nil, nil, nil, nil, {aHelp[3]} )
	endif	

	if lGrava .and. !lControl
		if cPortal != "3"
			oModel:getmodel("MasterB4D"):loadValue("B4D_PROTOC", GETSX8NUM("B4D","B4D_PROTOC","B4D_PROTOC",8))
		else		
			oModel:getmodel("MasterB4D"):loadValue("B4D_PROTOC", "000") //Protocolo temporario para evitar erro de validacao
		endif
	endif

	if oModel:getmodel("MasterB4D"):getvalue("B4D_OBJREC") == '3'
		oModel:getmodel('MasterB4D'):loadValue("B4D_TOTREC", nValorRec) 
	endif	
endif
return lGrava


/*//-------------------------------------------------------------------
{Protheus.doc} StatRecIte
Valida os dados inseridos na hora de protocolar os itens da guia, como valor e saldo de glosa.
@since    04/2019
//-------------------------------------------------------------------*/
static function StatRecIte(oModel)
Local lRet 	:= .T.
local aHelp := {'', '', ''}

if oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") > 0
	if oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") > oModel:getModel("B4EDetail"):getvalue("B4E_SLDREC")
		aHelp := {STR0001, STR0024, STR0025 } //"O valor apresentado para o recurso é maior que o Saldo de glosa para recurso restante" / "Revise o valor, pois deve estar de acordo com o saldo restante."
		lRet := .F.
	else
		oModel:getModel("B4EDetail"):Loadvalue("B4E_STATUS", "1")
	endif
elseif oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") == 0
	oModel:getModel("B4EDetail"):Loadvalue("B4E_STATUS", "0")
elseif oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") < 0
	lRet := .F.
	aHelp := {STR0001, STR0026, STR0027} //"O valor deve ser positivo." / "Informe um valor positivo."
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, NIL, NIL, NIL, NIL, NIL, {aHelp[3]} )
endif	

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} VldStRecIt
Demais validações do item
@since    04/2019
//-------------------------------------------------------------------*/
static function VldStRecIt(oModel)
Local lRet := .T.
local aHelp := {'', '', ''}

if oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") > 0 .AND. empTy(oModel:getModel("B4EDetail"):getvalue("B4E_JUSPRE"))
	lRet := .F.
	aHelp := {STR0001, STR0028, STR0022} //"É obrigatório informar a justificativa do recurso." / "Informe as justificativas necessárias."
endif

if oModel:getModel("B4EDetail"):getvalue("B4E_VLRREC") == 0 .AND. !empTy(oModel:getModel("B4EDetail"):getvalue("B4E_JUSPRE"))
	lRet := .F.
	aHelp := {STR0001, STR0056, STR0057} //"Informe o valor do item recursado."/ "Informe o valor do recurso do item, pois o campo Justificativa está preenchido."
endif	

if lRet .AND. EmpTy(oModel:getModel("B4EDetail"):getvalue("B4E_SEQUEN"))
	lRet := .F.
	aHelp := {STR0001, STR0029, '' } //"Não é permitida a inclusão de itens no recurso de glosa manualmente"
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, NIL, NIL, NIL, NIL, NIL, {aHelp[3]} )
endif	

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} IVlGloAcat
Query para exibir valor acatado, caso seja uma nova tentativa de glosa de um recurso já protocolado e analisado anteriormente
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

Return nRet


/*//-------------------------------------------------------------------
{Protheus.doc} IVlGloAcat
Verifica quanto de recurso de glosa já foi acatado pra o PEG/Guia
@since    04/2019
//-------------------------------------------------------------------*/
Static function CVlGloAcat(cCodOpe,cCodLDP,cCodPEG,cNumero)
Local nRet := 0
Local cSql := ""

Default cNumero := ""

cSql += " Select SUM(B4D_TOTACA) TOTALACATADO From " + RetsqlName("B4D")
cSql += " Where "
cSql += "     B4D_FILIAL = '" + xfilial("B4D") + "' "
cSql += " AND B4D_OPEMOV = '" + cCodOpe + "' "
cSql += " AND B4D_CODLDP = '" + cCodLDP + "' "
cSql += " AND B4D_CODPEG = '" + cCodPEG + "' "
if !(empTy(cNumero))
	cSql += " AND B4D_NUMAUT = '" + cNumero + "' "
//	cSql += " AND B4D_OBJREC = '2' "
else
	cSql += " AND B4D_OBJREC = '1' "
endif
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"RECACAT",.f.,.t.)

nret := RECACAT->(TOTALACATADO)

RECACAT->(dbcloseArea())

Return nRet


/*//-------------------------------------------------------------------
{Protheus.doc} StatRecCab
Status do cabeçalho conforme glosa
@since    04/2019
//-------------------------------------------------------------------*/
static function StatRecCab(oModel)
Local lRet 	:= .T.
local aHelp	:= {'', '', ''}

if oModel:getModel("MasterB4D"):getvalue("B4D_OBJREC") $ "1,2"
	if oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") > 0
		if oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") > oModel:getModel("MasterB4D"):getvalue("B4D_VLRGLO")
			aHelp := {STR0001, STR0024, STR0025}  //"O valor apresentado para o recurso é maior que o Saldo de glosa para recurso restante" / "Revise o valor, pois deve estar de acordo com o saldo restante."
			lRet := .F.
		endif
	elseif oModel:getModel("MasterB4D"):getvalue("B4D_TOTREC") < 0
		lRet := .F.
		aHelp := {STR0001, STR0026, STR0027 } //"O valor deve ser positivo." / "Informe um valor positivo."
	endif
endif

if !empty(aHelp[1]) .and. !empty(aHelp[2]) 
	Help(nil, nil , aHelp[1], nil, aHelp[2], 1, 0, NIL, NIL, NIL, NIL, NIL, {aHelp[3]} )
endif	

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} FilViewB4D
Campos que devem ser exibidos na view B4D
@since    04/2019
//-------------------------------------------------------------------*/
static function FilViewB4D(cCampo, lPE)
Local lRet := .F.

if ccampo == 'B4D_CODPEG'
	lRet := .T.
endif
if ccampo == 'B4D_NUMAUT'
	lRet := .T.
endif
if ccampo == 'B4D_OBJREC'
	lRet := .T.
endif
if ccampo == 'B4D_TIPGUI'
	lRet := .T.
endif
if ccampo == 'B4D_USUARI'
	lRet := .T.
endif
if ccampo == 'B4D_NOMUSR'
	lRet := .T.
endif
if ccampo == 'B4D_JUSGUI'
	lRet := .T.
endif
if ccampo == 'B4D_JUSPRO'
	lRet := .T.
endif
if ccampo == 'B4D_TOTREC'
	lRet := .T.
endif
if ccampo == 'B4D_VLRGLO'
	lRet := .T.
endif
if ccampo == 'B4D_DATREC'
	lRet := .T.
endif

if lPE
	lRet := execBlock("PRGLOFLD",.F.,.F., {lRet, ccampo})
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} FilViewB4E
Campos que devem ser exibidos na view B4E
@since    04/2019
//-------------------------------------------------------------------*/
static function FilViewB4E(cCampo, lPE)
Local lRet := .F.

if ccampo == 'B4E_VLRGLO'
	lRet := .T.
endif
if ccampo == 'B4E_SEQUEN'
	lRet := .T.
endif
if ccampo == 'B4E_CODPAD'
	lRet := .T.
endif
if ccampo == 'B4E_CODPRO'
	lRet := .T.
endif
if ccampo == 'B4E_DESPRO'
	lRet := .T.
endif
if ccampo == 'B4E_GLOTIS'
	lRet := .T.
endif
if ccampo == 'B4E_VLRREC'
	lRet := .T.
endif
if ccampo == 'B4E_SLDREC'
	lRet := .T.
endif
if ccampo == 'B4E_JUSPRE'
	lRet := .T.
endif
if ccampo == 'B4E_DESGLO'
	lRet := .T.
endif

if lPE
	lRet := execBlock("PRGLOFLD",.F.,.F., {lRet, ccampo})
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PLRECALTY
Função de análise do Protocolo
@since    04/2019
//-------------------------------------------------------------------*/
Function PLRECALTY()
Local lRet		:= .T.
local lVisual	:= .f.

if !B4D->B4D_STATUS == "0"
	if B4D->B4D_STATUS $ '3,4,5'
		lVisual := .t.
		Help(nil, nil , STR0030, nil, STR0031, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} )  //"Modo de Visualização" / "A análise deste recurso já foi concluída, a tela será aberta em modo de visualização."
	endif	
	FWExecView(STR0032,'PLSRECGLO3', iif(lVisual, MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE),, {|| .T. } )  //Análise
else
	Help(nil, nil , STR0001, nil, STR0045, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046} ) //"O protocolo ainda não está finalizado, não sendo possível sua análise." / "Termine a inserção do Protocolo de Glosa, para que fique no status 'Recurso de Glosa Protocolado', para análise."
endif

Return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} CarregaBD6Val
Para cada linha do BD6, carrega os valores dos campos que são exibidos no grid da B4E
@since    04/2019
//-------------------------------------------------------------------*/
static function CarregaBD6Val(oModel, cCampo, lBdx)
local nOpcao 	:= oModel:GetOperation()
local cCodOpe 	:= oModel:getmodel('MasterB4D'):getValue("B4D_OPEMOV")
local cCodLDP	:= oModel:getmodel('MasterB4D'):getValue("B4D_CODLDP")
local cCodPEG	:= oModel:getmodel('MasterB4D'):getValue("B4D_CODPEG")
local cNumero	:= oModel:getmodel('MasterB4D'):getValue("B4D_NUMAUT") 
local cOrimov	:= oModel:getmodel('MasterB4D'):getValue("B4D_ORIMOV")
local cRet   	:= ""
local lValida	:= iif(nOpcao == 1 .or. nOpcao == 4, .t., .f.)
default lBdx	:= .f.
                                                    
if lValida  //Visualização ou Update - no caso da análise de glosa
	if !lBdx 
		cRet := Posicione("BD6", 1, xFilial("BD6")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOrimov+ B4E->(B4E_SEQUEN + B4E_CODPAD + B4E_CODPRO), cCampo)
	else
		cRet := Posicione("BDX", 1, xFilial("BDX")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOrimov+ B4E->(B4E_CODPAD + B4E_CODPRO + B4E_SEQUEN + B4E_CODGLO), cCampo)
	endif
endif

return cRet


/*//-------------------------------------------------------------------
{Protheus.doc} CarregaBDXMEMO
Exibe no grid B4E as observações existentes para o item glosado, conforme tabela BDX
@since    04/2019
//-------------------------------------------------------------------*/
static function CarregaBDXMEMO(cChave, cCampo)
local cMemo  	:= "" 
default cChave 	:= ""
default cCampo	:= "BDX_OBS"

if !empty(cChave)
	cMemo := Posicione("BDX", 1, xFilial("BDX")+cChave, cCampo)	
endif

return alltrim(cMemo)


/*//-------------------------------------------------------------------
{Protheus.doc} SomaRecB4D
Query para Contar as tentativas de recurso já efetuados pelo prestador
@since    04/2019
//-------------------------------------------------------------------*/
static function SomaRecB4D(cCodOpe, cCodLdp, cCodPeg, cNumero, lMaxTent)
local cSql 		:= ""
local nRec 		:= 0
local nMaxRec	:= 0
default lMaxTent:= .f.

cSql := " SELECT COUNT(B4D_FILIAL) TOTRECURSO, MAX(B4D_QTDIRP) INCTENT "
cSql += " FROM " + RetsqlName("B4D") + " B4D "
cSql += " WHERE B4D_FILIAL = '" + xFilial("B4D") + "' "
cSql += " AND B4D_OPEMOV = '" + cCodOpe + "' AND B4D_CODLDP = '" + cCodLdp + "' "
cSql += " AND B4D_CODPEG = '" + cCodPeg + "' "
if !empty(cNumero)
	cSql += " AND B4D_NUMAUT = '" + cNumero + "' "
endif
cSql += " AND B4D.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"QtdRecursos",.f.,.t.)

nRec 	:= QtdRecursos->TOTRECURSO + 1 
nMaxRec	:= QtdRecursos->INCTENT + 1

QtdRecursos->(dbcloseArea())

BA0->(DbSetOrder(1))
if ( BA0->(msSeek(xFilial("BA0")+cCodOpe)) )
	lMaxTent := iif( BA0->BA0_MAXRG < nRec, .t., .f.)
endif 
return nMaxRec


/*//-------------------------------------------------------------------
{Protheus.doc} PlExclusao
Função para deletar o Protocolo e Análise - quando possível. Começa pelo último
@since    04/2019
//-------------------------------------------------------------------*/
static function PlExclusao(lPerg)
local lExclui	:= .t.
local cPasso	:= iif(B4D->B4D_STATUS $ '3,4,5', STR0043, STR0042) // "a Análise" / "o Protocolo"
local lUltimo	:= .f.	
default lPerg 	:= .t.

if lPerg
	if MsgYesNo(STR0039 + cPasso + STR0040 + CRLF + STR0041) //  "Deseja realmente excluir " / "de Glosa do sistema?" / "O processo não pode ser desfeito!"
		lExclui := .t.
	else
		lExclui := .f.
	endif
endif
//Verifica se o protocolo é o último posicionado.
lUltimo	:= UltRecPegGui(B4D->B4D_OPEMOV, B4D->B4D_CODLDP, B4D->B4D_CODPEG, alltrim(B4D->B4D_NUMAUT), iif(B4D->B4D_OBJREC == "1", .t., .f.), .t., B4D->(recno()) )

if lUltimo	
	if lExclui .and. B4D->B4D_STATUS $ '3,4,5'
		PlAG3DelAnalise(B4D->B4D_OPEMOV, B4D->B4D_OBJREC, B4D->B4D_STATUS)
	elseif lExclui .and. B4D->B4D_ORIENT == "1" .and. !B4D->B4D_STATUS $ '3,4,5'  //apenas protocolos gerados pelo remote podem ser excluídos
		FWExecView(STR0044,'PLSRECGLO2', MODEL_OPERATION_DELETE,, {|| .t.} ) //"Protocolo de Glosa"
	elseif lExclui .and. B4D->B4D_ORIENT <> "1"
		Help(nil, nil , STR0001, nil, STR0050, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0051} ) //Somente protocolos incluídos via remote podem ser excluídos / Protocolos oriundos do Portal, XML ou WSDL não são excluídos, pois foi ação executada pelo prestador
	endif	
else
	Help(nil, nil , STR0001, nil, STR0054, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0055} )  // Deve-se excluir o último Protocolo/Análise realizada / A exclusão de Protocolo/Análise deve começar pelo último registro inserido
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} VerfTitBaixa
Quando glosa por itens e parâmetro MV_PLRGACT igual "1", devemos verifica se a PEG onde a guia está localizada foi faturada e paga. Se não foi faturada e paga, não pode recursar.
Se foi faturada, deve ter sido pago algum valor ao prestador.
@since    04/2019
//-------------------------------------------------------------------*/
static function VerfTitBaixa(cCodOpe, cCodLdp, cCodPeg, cNumero)
local lRet 		:= .f.
local cSql 		:= ""
local cAliBD7	:= RetSqlName("BD7")
local cAliSE2	:= RetSqlName("SE2")
local cFilBD7	:= xFilial("BD7")

cSql := " SELECT COUNT(BD7_FILIAL) BAIXA FROM " + cAliBD7+ " BD7 "
cSql += " INNER JOIN " + cAliSE2 + " SE2 "
cSql += "    ON " + keybreak("BD7_CHKSE2")	
cSql += "    AND SE2.D_E_L_E_T_ = ' ' "
cSql += " AND E2_VALOR <> E2_SALDO "

cSql += " WHERE     BD7_FILIAL = '" + cFilBD7 + "' "
cSql += " 		AND BD7_CODOPE = '" + cCodOpe + "' "
cSql += " 		AND BD7_CODLDP = '" + cCodLdp + "' "
cSql += " 		AND BD7_CODPEG = '" + cCodPeg + "' "
cSql += " 		AND BD7_NUMERO = '" + cNumero + "' "
cSql += " 		AND BD7.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"BAIXADO",.F.,.T.)
	
if BAIXADO->(BAIXA) > 0	
	lRet := .t.
endif

BAIXADO->(dbcloseArea())
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlChkAltProt
Verifica se o protocolo pode ser ainda editado pelo usuário. Somente protocolos no status Rec Glosa Edição podem ser editados.
@since    04/2019
//-------------------------------------------------------------------*/
static function PlChkAltProt()

if B4D->B4D_STATUS == '0' .and. B4D->B4D_ORIENT == "1" 
	FWExecView(STR0032,'PLSRECGLO2', MODEL_OPERATION_UPDATE,, {|| .T. }/*,,,aButtons*/ )  //Análise
else
	Help(nil, nil , STR0001, nil, STR0035, 1, 0, NIL, NIL, NIL, NIL, NIL, {''} )  //"Somente é possível alterar protocolos no status Rec Glosa Edição e gerados pelo remote."
endif

return


/* {Protheus.doc} callPegExi
Utilizada pelo portal para chamada da função PegExiste
cOrigEnt := 1=Remote;2=Portal;3=WSDL;4=XML - Default "1"    
@since    04/2019 */
function callPegExi(cCodPeg, cCodRDA, lPortal, cOrigEnt, lMostre)
local areturn 	:= {}
local oRecGlo 	:= FWLoadModel( 'PLSRECGLO2' )
default cOrigEnt := "2"
Default lMostre := .F.

oRecGlo:setOperation(3)
oRecGlo:Activate()

areturn := PegExiste(cCodPeg, oRecGlo, cCodRDA, lPortal, cOrigEnt, lMostre)

return areturn

/* {Protheus.doc} callIncRec
Utilizada pelo portal inclusão dos recursos
cOrigEnt := 1=Remote;2=Portal;3=WSDL;4=XML
@since    04/2019 */
function callIncRec(cCodPeg, cCodRDA, cGuiaNum, cJustif, cOperador, cItens, cOrigEnt, aPreComit, cGuiaOper, aItensRest)
local areturn 	:= {}
local oRecGlo 	:= FWLoadModel( 'PLSRECGLO2' )
Local oModelIte := ""
local nRet 	  	:= 0
local aRes   	:= ""
local cMsg    	:= ""
local cPro 	  	:= ""
local aItens    := {}
local aItemInfo := {}
local nX		:= 0
local nLinhaI	:= 0
local aLidas 	:= {}
local aLidasB4E := {}
local lOK		:= .F.
local cCodPad 	:= ""
local cCodPro 	:= ""
local cOriMov 	:= ""
local lIsWsXml  := .F.

default cOrigEnt	:= "2"
default cGuiaOper	:= ""
default aItensRest 	:= {}

if cOrigEnt == "3" .or. cOrigEnt == "4"
	lIsWsXml := .T.
endif

BCI->(DbSetOrder(14))  
if BCI->(MsSeek(xfilial("BCI") + cCodPeg))
	
	//Verifico se o tipo de recurso enviado é do mesmo tipo da glosa
	areturn := verTipoGlo(cOperador,cCodPeg,@cGuiaNum,BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG), cGuiaOper)
	If !(Empty(areturn[1]))
		return areturn
	Endif
	
	if BCI->BCI_CODRDA == cCodRDA
		oRecGlo:setOperation(3)
		oRecGlo:Activate()
		oRecGlo:getModel('MasterB4D'):setValue('B4D_CODPEG', cCodPeg)
		if cOperador == "1"
			oRecGlo:getModel('MasterB4D'):setValue('B4D_JUSPRO', fwcutoff(cJustif))
		elseif cOperador == "3"
			oRecGlo:getModel('MasterB4D'):setValue('B4D_NUMAUT', cGuiaNum)
			oRecGlo:getModel('MasterB4D'):setValue('B4D_JUSGUI', fwcutoff(cJustif))
		elseif cOperador == "5"
			if lIsWsXml
			
				oRecGlo:getModel('MasterB4D'):setValue('B4D_NUMAUT', cGuiaNum)
				oRecGlo:getModel('MasterB4D'):loadValue("B4D_OBJREC", "3")			
				oModelIte := oRecGlo:getmodel("B4EDetail")
				aItens := Separa(cItens,"|")
				for nX := 1 to len(aItens)
					aItemInfo := Separa(aItens[nX],"-_Sep_-")
					lOk := .F.
					if len(aItemInfo) > 3
						cCodPad := aItemInfo[3]
						cCodPro := aItemInfo[4]
						if BCI->BCI_TIPGUI <> "05"
							BD5->(dbsetOrder(1))
							BD5->(MsSeek(xFilial("BD5") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cGuiaNum))
							cOriMov := BD5->BD5_ORIMOV
						else
							BE4->(DbsetOrder(1))
							BE4->(MsSeek(xFilial("BE4") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cGuiaNum))
							cOriMov := BE4->BE4_ORIMOV
						endif
						BD6->(DbSetOrder(6))
						if BD6->(MsSeek(  xfilial("BD6") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cGuiaNum + cOriMov + cCodPad + cCodPro))
							
							While !(BD6->(EoF())) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+AllTrim(BD6_CODPRO)) == xfilial("BD6") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cGuiaNum + cOriMov + cCodPad + cCodPro .AND. lOK == .F.
								if ascan(aLidas, BD6->BD6_SEQUEN ) == 0
									aadd(aLidas, BD6->BD6_SEQUEN )
									lOk := .T.
								else	
									BD6->(DbSkip())	
								Endif
							enddo
						else
							lOk := .F.
							cMsg := STR0090 + cCodPad + " - " + cCodPro + STR0091 + chr( 13 ) + chr( 10 ) + STR0092 + BCI->BCI_CODPEG + STR0082 + cGuiaNum //O Evento/Não consta na guia objeto do recurso./Protocolo:/GUIA:"
							exit
						endif
						if lOK .and. oModelIte:SeekLine({{"B4E_CODPAD",cCodPad}, {"B4E_CODPRO",cCodPro}})
							lOk := .F.
							if ascan(aLidasB4E, oModelIte:getline()) == 0
								aadd(aLidasB4E, oModelIte:getline())
								lOk := .T.
							else
								for nX := (oModelIte:getline() +1) to oModelIte:Length()
									oModelIte:Goline(nX) 
									if oModelIte:getvalue("B4E_CODPAD") == cCodPad .and. AllTrim(oModelIte:getvalue("B4E_CODPRO")) == cCodPro .and. ascan(aLidasB4E, oModelIte:getline()) == 0
										lOk := .T.
										aadd(aLidasB4E,oModelIte:getline())
										exit
									endif
								next
							endif
							nLinhaI := oModelIte:getline() 
							if lOk           
								nRec := val(strTran(strTran(aItemInfo[1],".",""),",",""))/100
								if !validaSaldo(oRecGlo,nRec,nLinhaI)
									orecglo:getModel("B4EDetail"):GoLine(nLinhaI)
									cEsteItem := orecglo:getmodel("B4EDetail"):getvalue("B4E_CODPAD") + " - " + AllTrim(orecglo:getmodel("B4EDetail"):getvalue("B4E_CODPRO")) + " - " + Alltrim(orecglo:getmodel("B4EDetail"):getvalue("B4E_DESPRO"))
									cMsg := STR0089 + cEsteItem + " na Guia: " + cGuiaNum //O valor recursado está maior que o saldo de glosa no item/
									lOk := .F.
									exit
								endif
								oModelIte:setValue("B4E_VLRREC",nRec)
								oModelIte:setValue("B4E_JUSPRE",aItemInfo[2])
							endif
						endif
					endif
					If !lOk
						cMsg := STR0087 + cGuiaNum + STR0088 //Não foi possível realizar o recurso, pois  ha um erro na Guia/que impede o processamento.
						exit
					Endif
				next
			
			else
				oRecGlo:getModel('MasterB4D'):setValue('B4D_NUMAUT', cGuiaNum)				
				oRecGlo:getModel('MasterB4D'):loadValue("B4D_OBJREC", "3")			
				oModelIte := oRecGlo:getmodel("B4EDetail")
				if len(aItensRest) > 0
					aItens := aItensRest
				else
					aItens := STRTOKARR(cItens,"|")    
				endif 
				for nX := 1 to len(aItens)
					if len(aItensRest) > 0
						aItemInfo := aItensRest[nX]
					else
						aItemInfo := STRTOKARR(aItens[nX],"-")
					endif
					if len(aItemInfo) > 2 .and. oModelIte:SeekLine({{"B4E_SEQUEN",aItemInfo[1]}})
						nRec := val(strTran(strTran(aItemInfo[2],".",""),",",""))/100	//nRec := val(strTran(strTran(aItemInfo[1],".",""),",",""))/100						
						oModelIte:setValue("B4E_VLRREC",nRec)
						oModelIte:setValue("B4E_JUSPRE",fwcutoff(aItemInfo[3])) //oModelIte:setValue("B4E_JUSPRE",aItemInfo[2])
					endif
				next
			endif
		endif		
		oRecGlo:getmodel("MasterB4D"):setValue("B4D_ORIENT", cOrigEnt)

		if !lIsWsXml
			if oRecGlo:VldData()	
				aRes := oRecGlo:CommitData()
				cMsg  := STR0049 //"Recurso gravado com sucesso" 
				nRet  := 1
				cPro  := oRecGlo:getModel('MasterB4D'):getValue('B4D_PROTOC')
			Else		
				aRes := oRecGlo:GetErrorMessage()
				cMsg  := aRes[6]
				nRet := 0
			endif
		else
			aadd(aPrecomit,oRecGlo)
		endif	
	else
		cMsg := STR0086 + cCodPeg //A identificação do prestador origem não coincide com o número de protocolo:
		nRet := 0
	endif
else
	cMsg := STR0048 + STR0081 + cCodPeg //"Protocolo não encontrado." //PEG:
	nRet := 0
endif

areturn := {cMsg, nRet, cPro}

return areturn


/* {Protheus.doc} callGuiExi
Utilizada pelo portal para chamada da função PegExiste
cOrigEnt := 1=Remote;2=Portal;3=WSDL;4=XML     
@since    04/2019 */
function callGuiExi(cCodPeg, cGuiaNum, lPortal, cOrigEnt, lMostre)
local areturn 	:= {}
local oRecGlo 	:= FWLoadModel( 'PLSRECGLO2' )
local oModelIte := oRecGlo:getmodel("B4EDetail")

default cOrigEnt := "2"
default lMostre := .F.

oRecGlo:setOperation(3)
oRecGlo:Activate()
oRecGlo:getModel('MasterB4D'):setValue('B4D_CODPEG', cCodPeg)
oRecGlo:getModel('MasterB4D'):setValue('B4D_NUMAUT', cGuiaNum)
//Limpar o Model antes da chamada final. Setvalue dispara ações que atuam no model de itens.
oModelIte:clearData()
areturn := HaGlosa(cGuiaNum,oRecGlo,lPortal,cOrigEnt,lMostre)

return areturn

/*//-------------------------------------------------------------------
{Protheus.doc} fPrenchVazio
Preenche vazios
@since    04/2019
//-------------------------------------------------------------------*/
static function fPrenchVazio(cValor, cTipDado)
local cRet := ""

if empty(cValor)
	cRet := "-"
else
	cRet := cValor	
endif

return cRet 

/*//-------------------------------------------------------------------
{Protheus.doc} validaSaldo
Valida se ha saldo para o recurso de glosa, assim evitando o erro de comitar parte dos dados do webservice com falha em eventos nessa situacao.
@since    07/2019
//-------------------------------------------------------------------*/
function validaSaldo(oModel,nRec,nLinhaI)

local lRet 	:= .T.
Local oB4E 	:= oModel:getmodel("B4EDetail")

oB4E:Goline(nLinhaI)
if nRec > oB4E:getvalue("B4E_SLDREC")
	lRet := .F.
endif

return lRet

/*//-------------------------------------------------------------------
{Protheus.doc} UltRecPegGui
Query para verificar o status da última tentativa
@since    04/2019
//-------------------------------------------------------------------*/
static function UltRecPegGui(cCodOpe, cCodLdp, cCodPeg, cNumero, lPeg, lExclui, nRecno)
local cSql 		:= ""
local lRecAbr 	:= .f.
default lPeg	:= .f.
default lExclui	:= .f.
default nRecno	:= 0

cSql := " SELECT B4D_STATUS, B4D.R_E_C_N_O_ REC "
cSql += " FROM " + RetsqlName("B4D") + " B4D "
cSql += " WHERE B4D_FILIAL = '" + xFilial("B4D") + "' "
cSql += " AND B4D_OPEMOV = '" + cCodOpe + "' AND B4D_CODLDP = '" + cCodLdp + "' "
cSql += " AND B4D_CODPEG = '" + cCodPeg + "' "
if !empty(cNumero)
	cSql += " AND B4D_NUMAUT = '" + cNumero + "' "
endif
if lPeg
	cSql += " AND B4D_OBJREC = '1' "
endif
cSql += " AND B4D.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY B4D_QTDIRP DESC"

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"PEGGUIAB",.f.,.t.)

if ( !PEGGUIAB->(eof()) )
	if !lExclui
		lRecAbr := iif ( (PEGGUIAB->B4D_STATUS $ '5,4,3'), .f., .t. )
	else
		lRecAbr := iif ( (PEGGUIAB->REC == nRecno), .t., .f. )
	endif				
endif

PEGGUIAB->(dbcloseArea())

return lRecAbr


/*//-------------------------------------------------------------------
{Protheus.doc} PLRGLICriticas
Exibe justificativa da Operadora no Portal. 
@since    04/2019
//-------------------------------------------------------------------*/
function PLRGLICriticas (cChave, cAlias)
local cSql 		:= ""
local cTexto	:= ""
local aSep		:= {}

cSql := " SELECT " + cAlias + "_JUSOPE JUSOPE, " + cAlias + "_CDGTIS CODGLOSA "
cSql += " FROM " + RetSqlName(cAlias)
if (cAlias == "B4D")
	cSql += " WHERE B4D_FILIAL = '" + xFilial(cAlias) + "' AND B4D_PROTOC = '" + cChave + "' "
else
	aSep := Separa(cChave, '~')
	cSql += " WHERE B4E_FILIAL = '" + xFilial(cAlias) + "' AND B4E_SEQB4D = '" + aSep[1] + "' AND B4E_SEQUEN = '" + aSep[2] + "' "	
endif 

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"QJUSOPE",.f.,.t.)

cTexto := fwcutoff(alltrim(QJUSOPE->JUSOPE))

if !empty(QJUSOPE->CODGLOSA)
	cTexto += "<br><strong> MOTIVO TISS: </strong>" + QJUSOPE->CODGLOSA + " - " + Posicione("BTQ",1,xFilial("BTQ")+"38"+QJUSOPE->CODGLOSA,"BTQ_DESTER")
endif

cTexto := encode64(cTexto)

QJUSOPE->(dbcloseArea())
return cTexto


/*//-------------------------------------------------------------------
{Protheus.doc} CarregaGlosa
Carrega código e descrição da glosa para o campo virtual CODDESGLO, quando for recurso por Protocolo ou Guia
@since    01/2020
//-------------------------------------------------------------------*/
static function CarregaGlosa(oModel)
local cCodOpe	:= oModel:getmodel('MasterB4D'):getValue("B4D_OPEMOV")
local cTipRec	:= oModel:getmodel('MasterB4D'):getValue("B4D_OBJREC")
local cCodGlo 	:= ''
local aGlosa	:= {}
local cRet		:= ''

if cTipRec $ '1,2'
	cCodGlo := oModel:getmodel('MasterB4D'):getValue("B4D_" + iif(cTipRec == "1", "GLOPRT", "GLOPLS"))
	aGlosa := Pls498DesG(cCodGlo, cCodOpe)	
	if !empty(aGlosa)
		cRet := aGlosa[1] + ' - ' + aGlosa[2]
	endif
endif		

return cRet

//O BCI chega posicionado.
static function chkPeriodo()
Local lRet := .F.
Local nDias := 0
Local cSql := ""
Local dDatVenc := StoD("")
Local aChvSE2 := ""

BA0->(DbSetOrder(1))
BA0->(MsSeek(xfilial("BA0") + BCI->BCI_CODOPE ))
nDias := BA0->BA0_PRZREC

If nDias == 0
	lRet := .T.
else
	cSql += " Select BD7_CHKSE2 From " + RetSqlName("BD7") + " BD7 "
	cSql += " Where "
	cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
	cSql += " BD7_CODOPE = '" + BCI->BCI_CODOPE + "' AND "
	cSql += " BD7_CODLDP = '" + BCI->BCI_CODLDP + "' AND "
	csql += " BD7_CODPEG = '" + BCI->BCI_CODPEG + "' AND "
	cSql += " BD7_CHKSE2 <> ' ' AND "
	cSql += " BD7.D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VIND7",.f.,.t.)

	If !(VIND7->(EoF()))
		aChvSE2 := Separa(VIND7->(BD7_CHKSE2), "|")
		//M SP 01 |MED|000000051| |DP |000074|01             <- BD7_CHKSE2
		SE2->(DbSetOrder(1))
		If SE2->(MsSeek(aChvSE2[1]+aChvSE2[2]+aChvSE2[3]+aChvSE2[4]+aChvSE2[5]+aChvSE2[6]+aChvSE2[7]))
			dDatVenc := SE2->E2_VENCTO
			lRet := dDatVenc + nDias > dDataBase
		endIf
	else
		lRet := .T. //Se não tem título, essa validação não pode ser aplicada.
	endIf

	VIND7->(dbclosearea())
endIf

return lRet

/*//-------------------------------------------------------------------
{Protheus.doc} verTipoGlo
Verifica se o tipo de Glosa (Peg Integral, guia ou evento) e o tipo do recurso são o mesmo 
@since    06/2020
//-------------------------------------------------------------------*/
static function verTipoGlo(cTipoRec,cCodPeg,cGuia,cChave,cGuiaOper)

Local cTipoGlo 	:= "0" //Tipo de glosa
local aRetorno	:= {,,}
local aDeParaTip:= {{"1","PEG INTEGRAL"},{"3","GUIA INTEIRA"},{"5","DE EVENTO"}}
local cMsgTipo1	:= "" //Tipo de Recurso enviado
local cMsgTipo2	:= "" //Tipo de glosa aplicada
local nI		:= 1
Default cTipoRec:= "" // 1-Peg Integral / 3-Guia / 5-Evento
Default cCodPeg := ""
Default cGuia	:= ""
Default cChave	:= "" // BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)

//Descobro qual é o tipo de Glosa aplicada
If !(empty(BCI->BCI_CODGLO))
	cTipoGlo := "1"
Else
	if BCI->BCI_TIPGUI <> "05"
		BD5->(dbsetOrder(1)) //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
		//pesquisa pelo número da Guia Operadora -> tag <numeroGuiaOperadora> = PEG + Num. Guia
		If ! Empty(Alltrim(cGuiaOper)) 
			If BD5->(MsSeek(xFilial("BD5") + cChave + iif(len(cGuiaOper) > 8, substr(cGuiaOper,9,8), cGuiaOper)))
				cTipoGlo := Iif(!(empty(BD5->BD5_CODGLO)),"3",cTipoGlo)
				cGuia := BD5->BD5_NUMERO
			EndIf
		//se não encontrar, pesquisa pelo número da Guia Prestador -> tag <numeroGuiaOrigem>
		Elseif BD5->(MsSeek(xFilial("BD5") + cChave + iif(len(cGuia) > 8, substr(cGuia,9,8), cGuia) ))
			cTipoGlo := Iif(!(empty(BD5->BD5_CODGLO)),"3",cTipoGlo)
			cGuia := BD5->BD5_NUMERO
		EndIf
		//se não encontrar, pesquisa o número informado na Guia Prestador no _NUMIMP
		If cTipoGlo == "0"
			BD5->(dbsetOrder(6)) //BD5_FILIAL+BD5_NUMIMP
			if BD5->(MsSeek(xFilial("BD5") + cGuia))
				while !(BD5->(EoF())) .AND. AllTrim(BD5->BD5_NUMIMP) == AllTrim(cGuia)
					iF (BD5->BD5_CODPEG == cCodPeg) .AND. (BD5->BD5_CODRDA == BCI->BCI_CODRDA)
						cTipoGlo := Iif(!(empty(BD5->BD5_CODGLO)),"3",cTipoGlo)
						cGuia := BD5->BD5_NUMERO
						Exit
					EndIf
					BD5->(DbSkip())
				EndDo
			EndIf
		EndIf

	Else
		BE4->(dbsetOrder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
		//pesquisa pelo número da Guia Operadora -> tag <numeroGuiaOperadora> = PEG + Num. Guia
		If ! Empty(Alltrim(cGuiaOper)) 
			If BE4->(MsSeek(xFilial("BE4") + cChave + iif(len(cGuiaOper) > 8, substr(cGuiaOper,9,8), cGuiaOper) ))
				cTipoGlo := Iif(!(empty(BE4->BE4_CODGLO)),"3",cTipoGlo)
				cGuia := BE4->BE4_NUMERO
			EndIf
		//se não encontrar, pesquisa pelo número da Guia Prestador -> tag <numeroGuiaOrigem>
		ElseIf BE4->(MsSeek(xFilial("BE4") + cChave + iif(len(cGuia) > 8, substr(cGuia,9,8), cGuia)))
			cTipoGlo := Iif(!(empty(BE4->BE4_CODGLO)),"3",cTipoGlo)
			cGuia := BE4->BE4_NUMERO
		EndIf
		//se não encontrar, pesquisa o número informado na Guia Prestador no _NUMIMP
		If cTipoGlo == "0"
			BE4->(dbsetOrder(6)) //BE4_FILIAL+BE4_NUMIMP
			if BE4->(MsSeek(xFilial("BE4") + cGuia))
				while !(BE4->(EoF())) .AND. AllTrim(BE4->BE4_NUMIMP) == AllTrim(cGuia)
					iF (BE4->BE4_CODPEG == cCodPeg) .AND. (BE4->BE4_CODRDA == BCI->BCI_CODRDA)
						cTipoGlo := Iif(!(empty(BE4->BE4_CODGLO)),"3",cTipoGlo)
						cGuia := BE4->BE4_NUMERO
						Exit
					EndIf
					BE4->(DbSkip())
				EndDo
			EndIf
		EndIf
	Endif
Endif

if empTy(cTipoGlo) .OR. !( cTipoGlo $ '1,3' )
	BD6->(DbSetOrder(1))
	if BD6->(MsSeek(  xfilial("BD6") + cChave + cGuia))
		While !(BD6->(EoF())) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == xfilial("BD6") + cChave + cGuia .AND. cTipoGlo <> "5"
			if BD6->BD6_VLRGLO > 0
				cTipoGlo := "5"
			Endif
			BD6->(DbSkip())
		EndDo
	Endif
Endif 

//Retorno para os casos de não encontrar Glosa
if !( cTipoGlo $ '1,3,5' )
	aRetorno[1] := "Não há glosa para a PEG: " + cCodPeg
	aRetorno[1] += Iif(cTipoRec != "1", STR0082 + cGuia," (do Tipo glosa PEG INTEGRAL)") //" GUIA: "
	aRetorno[2] := 0
	aRetorno[3] := ""
	Return aRetorno
endif

//Crio mensagem de erro en caso de divergencia
If cTipoGlo <> cTipoRec
	For nI := 1 to len(aDeParaTip)
		If cTipoRec == aDeParaTip[nI][1]
			cMsgTipo1 := aDeParaTip[nI][2]
		Endif
		If cTipoGlo == aDeParaTip[nI][1]
			cMsgTipo2 := aDeParaTip[nI][2]
		Endif
	Next
	If cTipoRec == "1" // Caso o recurso seja de PEG Integral, não há o num.guia para pesquisar no seek
		aRetorno[1] := STR0083 + cMsgTipo1 + STR0084 //Foi enviado um recurso do tipo/e não houve esse tipo de glosa.
	Else
		aRetorno[1] := STR0083 + cMsgTipo1 + STR0085 + cMsgTipo2 //"Foi enviado um recurso do tipo/,enquanto a glosa foi do tipo
		aRetorno[1] += Iif(cTipoGlo != "1"," na Guia " + cGuia,"")
	Endif
	aRetorno[2] := 0
	aRetorno[3] := ""	
Endif

Return aRetorno
