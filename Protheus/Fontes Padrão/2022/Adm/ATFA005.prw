#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'atfa005.ch'

#DEFINE OPER_REVISAR		11
#define ATF_LAST_UPDATED		"10/12/12"

Static __nOper := 0

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ATFA005  � Autor 矨lvaro Camillo Neto    � Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Cadastro de Indice de depreciacao                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function ATFA005()
Local oBrowse

ChkFile("FNI")

if 'ExistChav("FNI",M->(FNI_CODIND+FNI_REVIS))'$LocX3Valid("FNI_CODIND") .and. POSICIONE("SIX",1,"FNI1","CHAVE") = "FNI_FILIAL+FNI_CODIND+FNI_REVIS"
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FNI')
	oBrowse:SetDescription(STR0008)
	oBrowse:AddLegend( "FNI_MSBLQL=='1'", "GRAY"  , STR0016 )//"Bloqueado"
	oBrowse:AddLegend( "FNI_STATUS=='1'", "GREEN" , STR0021 )//"Ativo"
	oBrowse:AddLegend( "FNI_STATUS=='2'", "RED"   , STR0022 )//"Bloqueado por Revisao"

	oBrowse:DisableDetails()
	oBrowse:Activate()
else
 
	Help( ,, 'Help',, STR0018+STR0036+ ATF_LAST_UPDATED+STR0037, 1, 0 )    // "Dicion醨io n鉶 atualizado, por favor executar o atualizador updatf01"##" de "##"ou posterior."

endif	

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0009 Action 'PesqBrw'          OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.ATFA005'  OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.ATFA005'  OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0012 Action 'VIEWDEF.ATFA005'  OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0013 Action 'VIEWDEF.ATFA005'  OPERATION 5 ACCESS 0 //Excluir
ADD OPTION aRotina Title STR0014 Action 'AF005BLQL'        OPERATION 6 ACCESS 0 //Bloquear/Desbloquear
ADD OPTION aRotina Title STR0020 Action 'AFA005REV'        OPERATION 6 ACCESS 0 //"Revis鉶"

Return aRotina
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ModelDef  � Autor 矨lvaro Camillo Neto   � Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Modelod de dados                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruFNI := FWFormStruct( 1, "FNI")
Local oCod
Local cCod
Local oDesc
Local cDesc
Local oPeriod
Local cPeriod

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('ATFA005M', /*bPreValidacao*/, { |oModel| AF005VERIF( oModel) }, /*bCommit*/, /*bCancel*/ )

oStruFNI:AddTrigger( "FNI_TIPO" , "FNI_CURVIN", {|| .T. }, {|oModel| CTOD("") } )
oStruFNI:AddTrigger( "FNI_TIPO" , "FNI_CURVFI", {|| .T. }, {|oModel| CTOD("") } )
oStruFNI:AddTrigger( "FNI_TIPO" , "FNI_DTREV", {|| .T. }, {|oModel| CTOD("") } )

oStruFNI:SetProperty('FNI_PERIOD' , MODEL_FIELD_INIT,{||'2'} )
oStruFNI:SetProperty('FNI_TIPO'   , MODEL_FIELD_WHEN,{|| INCLUI })
oStruFNI:SetProperty('FNI_PERIOD' , MODEL_FIELD_WHEN,{|| INCLUI })
oStruFNI:SetProperty('FNI_CURVIN' , MODEL_FIELD_WHEN,{|| AF005WHEN('FNI_CURVIN') })
oStruFNI:SetProperty('FNI_CURVFI' , MODEL_FIELD_WHEN,{|| AF005WHEN('FNI_CURVFI') })
oStruFNI:SetProperty('FNI_DTREV'  , MODEL_FIELD_WHEN,{|| AF005WHEN('FNI_DTREV')  })

// Adiciona ao modelo uma estrutura de formul?rio de edi??o por campo
oModel:AddFields( 'FNIMASTER', /* cOwner */, oStruFNI)

oModel:SetVldActivate( {|oModel| AF005VlMd(oModel) } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription(STR0008)
oModel:GetModel( 'FNIMASTER' ):SetDescription( STR0015 )

Return oModel

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � AF005WHEN � Autor 矨lvaro Camillo Neto   � Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Valida玢o do campo When dos campos                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function AF005WHEN(cCampo)
Local lRet        := .F.
Local oModel      := FWModelActive()
Local oModelFNI   := oModel:GetModel('FNIMASTER')
Local nOperation  := oModel:GetOperation()
Local cTipo       := oModelFNI:GetValue("FNI_TIPO")

If cCampo == 'FNI_CURVIN'
	If cTipo == '2' .And. nOperation == MODEL_OPERATION_INSERT 
		lRet := .T.
	ElseIf cTipo == '2' .And. nOperation == MODEL_OPERATION_UPDATE .And. Empty(FNI->FNI_CURVIN)
		lRet := .T.
	EndIf

ElseIf cCampo == 'FNI_CURVFI'
	If cTipo == '2' .And. (nOperation == MODEL_OPERATION_INSERT .Or. __nOper == OPER_REVISAR )
		lRet := .T.
	ElseIf cTipo == '2' .And. nOperation == MODEL_OPERATION_UPDATE .And. Empty(FNI->FNI_CURVFI)
		lRet := .T.
	EndIf
ElseIf cCampo == 'FNI_DTREV'
	If cTipo == '2' .And. ( __nOper == OPER_REVISAR )
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ModelDef  � Autor 矨lvaro Camillo Neto   � Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Modelod de Tela                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA005' )
Local oStruFNI := FWFormStruct( 2, 'FNI')

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FNI",oStruFNI,"FNIMASTER")

If __nOper == OPER_REVISAR
	oStruFNI:SetProperty( '*'         , MVC_VIEW_CANCHANGE , .F. )
	oStruFNI:SetProperty('FNI_CURVFI' , MVC_VIEW_CANCHANGE , .T. )
	oStruFNI:SetProperty('FNI_DTREV'  , MVC_VIEW_CANCHANGE , .T. )
EndIf

Return oView

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � AF005VlMd  � Autor 矨lvaro Camillo Neto   � Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Valida玢o do Modelo de dados                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAATF                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function AF005VlMd(oModel)
Local lRet    := .T.
Local cStatus := FNI->FNI_STATUS
Local cBloq   := FNI->FNI_MSBLQL 
Local cRev    := FNI->FNI_REVIS 
Local nOper   := oModel:GetOperation()


If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE  
	If FNI->(!EOF())
		If Alltrim(cStatus) != "1" .Or. nOper == MODEL_OPERATION_UPDATE .And. Alltrim(cBloq) == "1"
			Help( ,, 'AF005STAT',, STR0023, 1, 0 )//"O Status desse 韓dice n鉶 permite manuten玢o"
			lRet := .F.
		EndIf
		
		If lRet .And. nOper == MODEL_OPERATION_DELETE .And. cRev > "0001"
			Help( ,, 'AF005STAT3',, STR0024, 1, 0 ) //"O indice possui revis鉶 anterior e n鉶 poder� ser excluido"
			lRet := .F.
		EndIf 
		
		If lRet .And. nOper == MODEL_OPERATION_DELETE .And. cBloq = "1"
			Help( ,, 'AF005STAT',, STR0023, 1, 0 )//"O Status desse 韓dice n鉶 permite manuten玢o"
			lRet := .F.
		EndIf		
	EndIf
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨F005VERIF� Autor � Ramon Prado				� Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Gera matriz Acols para preenchimento das cotacoes            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨F005VERIF(oModel)                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   �.T./.F.                                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFA005                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpO1=oModel					                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AF005VERIF(oModel)

Local aAreaAt   := GetArea()
Local oModelFNI := oModel:GetModel('FNIMASTER')
Local lResp     := .T.
Local nOpc      := oModel:GetOperation()  //pega a operacao a ser realizada
Local cCODIND   := oModelFNI:GetValue('FNI_CODIND')
Local cRev      := oModelFNI:GetValue('FNI_REVIS')
Local cDescInd  := AllTrim(oModelFNI:GetValue('FNI_DSCIND'))
Local cTipo     := oModelFNI:GetValue('FNI_TIPO')
Local dCurvaIni := oModelFNI:GetValue('FNI_CURVIN')
Local dCurvaFim := oModelFNI:GetValue('FNI_CURVFI')
Local dDataRev  := oModelFNI:GetValue('FNI_DTREV')
Local aAreaFNT
Local cAliasQry
Local aAreaSN3

If nOpc == MODEL_OPERATION_DELETE    //se operacao igual a exclus鉶

	dbSelectArea( 'SN3' )
	aAreaSN3:=SN3->(GetArea())
	SN3->(dbSetOrder ( 1 ))  //CBASE+ITEM+TIPO+BAIXA+SEQ

	cAliasQry:=GetNextAlias()
	BeginSql Alias cAliasQry
	SELECT N3_CODIND
	FROM %table:SN3% 
	WHERE 	N3_FILIAL = %xfilial:SN3% AND
			N3_CODIND = %Exp:cCODIND% AND 
			%notDel%
	EndSql
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		lResp:= .F.
	EndIf
	(cAliasQry)->(DbCloseArea())

	If !lResp    //verifica se h� registro em que o indice est� amarrado a ficha do ativo
		Help( ,, "AF05VERIF1",, STR0001+cDescInd+' '+STR0002+cCODIND+''+STR0003, 1, 0 ) //mensagem: '蚽dice de C骴igo:tal n鉶 pode ser exclu韉o, pois est� sendo utilizado'
	Endif

	If lResp 
		dbSelectArea( 'FNT' )
		aAreaFNT:=FNT->(GetArea())
		FNT->(dbSetOrder(1))//FNT_FILIAL+FNT_CODIND+FNT_REVIS+DTOS(FNT_DATA)
		If FNT->(MsSeek(xFilial("FNT")+cCODIND))    //verifica se h� registro em que o indice est� amarrado a alguma taxa
			lResp := .F.
			Help( ,, "AF05VERIF2",, STR0001+cDescInd+' '+STR0002+cCODIND+''+STR0003, 1, 0 ) //mensagem: '蚽dice de C骴igo:tal n鉶 pode ser exclu韉o, pois est� sendo utilizado'
		Endif
		RestArea(aAreaFNT)
	Endif
	
	RestArea(aAreaSN3)
	
Else
	If cTipo == '2'
		
		If lResp .and. oModelFNI:GetValue('FNI_PERIOD') != '2'
			Help( ,, "AF05VERIF3",, STR0019 , 1, 0 ) // 'Para 韓dices Tipo = 2 - Calculado, s� � permitido per韔do mensal'
			lResp:=.F.
		EndIf
		
		If lResp .And. ( Empty(dCurvaIni) .Or. Empty(dCurvaFim) )
			Help( ,, "AF05VERIF4",, STR0026 , 1, 0 ) // "Para 韓dices Tipo = 2 - Calculado, os campos de curva inicial e final s鉶 obrigat髍ios"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaIni != FirstDay(dCurvaIni)
			Help( ,, "AF05VERIF5",, STR0027 , 1, 0 ) // "A data inicial da curva de demanda deve ser no primeiro dia do m阺"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaFim != LastDay(dCurvaFim)
			Help( ,, "AF05VERIF6",, STR0028 , 1, 0 ) // "A data final da curva de demanda deve ser no ultimo dia do m阺"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaIni > dCurvaFim
			Help( ,, "AF05VERIF7",, STR0029 , 1, 0 ) // "A data final da curva de demanda deve ser superior a data inicial"
			lResp:=.F.
		EndIf
		
		If lResp .And. __nOper == OPER_REVISAR
			If lResp .And. ( Empty(dDataRev) )
				Help( ,, "AF05VERIF8",, STR0030 , 1, 0 ) // "Na opera玢o de revis鉶, a data de revis鉶 � obrigat髍ia"
				lResp:=.F.
			EndIf
			
			If lResp .And. ( dDataRev != FirstDay(dDataRev) )
				Help( ,, "AF05VERIF9",, STR0031 , 1, 0 ) // "A data de revis鉶 deve ser no primeiro dia do m阺"
				lResp:=.F.
			EndIf
			
			If lResp .And.  (dDataRev < dCurvaIni .Or. dDataRev > dCurvaFim)
				Help( ,, "AF05VERIF10",, STR0032 , 1, 0 ) // "A data de revis鉶 deve ser no per韔do da curva de demanda "
				lResp:=.F.
			EndIf
			
			If lResp
				FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS
				cRevAnt := Tira1(cRev) 
				If FNI->(MsSeek(xFilial("FNI") + cCODIND + cRevAnt) ) 
					If lResp .And. dCurvaFim < FNI->FNI_CURVFI  
						Help( ,, "AF05VERIF11",, STR0033 + DTOC(FNI->FNI_CURVFI) , 1, 0 ) //"A data final da curva de demanda n鉶 pode ser menor que a data final da revis鉶 anterior: "
						lResp:= .F.
					EndIf
					
					If lResp .And. dDataRev < FNI->FNI_DTREV  
						Help( ,, "AF05VERIF12",, STR0034 + DTOC(FNI->FNI_DTREV) , 1, 0 ) // "A data de revis鉶 da curva de demanda n鉶 pode ser menor que a data de revis鉶 anterior: "
						lResp:= .F.
					EndIf	
				EndIf
			EndIf		
		EndIf		
	EndIf
Endif

RestArea(aAreaAt)

Return lResp

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矨F005BLQL� Autor � Ramon Prado				� Data � 30/09/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri玢o � Faz Bloqueio/Desbloqueio de 蚽dices				           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矨F005BLQL()                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � ATFA005                                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AF005BLQL()
Local aSaveArea	:= GetArea()
Local aSaveFNI		:= FNI->(GetArea())

If FNI->FNI_STATUS == '1'
	If FNI->FNI_MSBLQL == "1"	//se campo bloqueio? == "1"  (sim)
		if MsgYesNo ( STR0004+Alltrim(FNI->FNI_DSCIND)+' '+STR0002+FNI->FNI_CODIND+'?',STR0005)
			RecLock( 'FNI', .F. )
			FNI->FNI_MSBLQL := "2"	//campo receberao "2"(nao)
			FNI->(MsUnlock())
		endif
	Else //senao, entao, sera == "2"(nao)//campo receberao "1"(sim)
		if MsgYesNo ( STR0006+Alltrim(FNI->FNI_DSCIND)+' '+STR0002+FNI->FNI_CODIND+'?',STR0007)
			RecLock( 'FNI', .F. )
			FNI->FNI_MSBLQL := "1"
			FNI->(MsUnlock())
		endif
	EndIf
Else
	Help( ,, 'AF005STAT1',, STR0023, 1, 0 )//"O Status desse 韓dice n鉶 permite manuten玢o"
EndIf

RestArea(aSaveFNI)
RestArea(aSaveArea)

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨FA430CPY篈utor  矨lvaro Camillo Neto � Data �  12/12/11   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Realiza a c髉ia do projeto                                 罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AFA005REV(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCod          := FNI->FNI_CODIND
Local cRev          := FNI->FNI_REVIS
Local lRet          := .T.

If FNI->(MsSeek(xFilial("FNI") + cCod + cRev)) .And. FNI->FNI_TIPO == '2' .And. FNI->FNI_STATUS == '1' .And. FNI->FNI_MSBLQL == '2' 

	cTitulo      := STR0020 			// "Revis鉶"
	cPrograma    := 'ATFA005'
	nOperation   := MODEL_OPERATION_INSERT
	
	__nOper      := OPER_REVISAR
	
	oModel := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclus鉶
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	
	oModel:SetValue("FNIMASTER","FNI_REVIS",Soma1(cRev))
	oModel:SetValue("FNIMASTER","FNI_CODIND" , cCod )
	
	nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	__nOper      := 0
	
	If nRet == 0 // Confirmada a revis鉶, bloqueia a revis鉶 anterior
		If FNI->(MsSeek(xFilial("FNI") + cCod + cRev))
			RecLock("FNI",.F.)
			FNI->FNI_STATUS := "2"
			MsUnLock()
		EndIf
	EndIf
Else
	If FNI->FNI_TIPO == '2' 
		Help( ,, "AF05REVIS01",,STR0023 , 1, 0 ) //"O Status desse 韓dice n鉶 permite manuten玢o"
	Else
		Help( ,, "AF05REVIS02",,STR0035 , 1, 0 ) //"A opera玢o de revis鉶 disponivel para os indices ativos e do tipo 2 - Calculado."
	EndIf	
EndIf

RestArea(aArea)

Return