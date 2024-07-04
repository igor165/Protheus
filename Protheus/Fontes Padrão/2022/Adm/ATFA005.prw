#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'atfa005.ch'

#DEFINE OPER_REVISAR		11
#define ATF_LAST_UPDATED		"10/12/12"

Static __nOper := 0

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFA005  ³ Autor ³Alvaro Camillo Neto    ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Indice de depreciacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
 
	Help( ,, 'Help',, STR0018+STR0036+ ATF_LAST_UPDATED+STR0037, 1, 0 )    // "Dicionário não atualizado, por favor executar o atualizador updatf01"##" de "##"ou posterior."

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
ADD OPTION aRotina Title STR0020 Action 'AFA005REV'        OPERATION 6 ACCESS 0 //"Revisão"

Return aRotina
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef  ³ Autor ³Alvaro Camillo Neto   ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modelod de dados                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF005WHEN ³ Autor ³Alvaro Camillo Neto   ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação do campo When dos campos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef  ³ Autor ³Alvaro Camillo Neto   ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modelod de Tela                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF005VlMd  ³ Autor ³Alvaro Camillo Neto   ³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação do Modelo de dados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
			Help( ,, 'AF005STAT',, STR0023, 1, 0 )//"O Status desse índice não permite manutenção"
			lRet := .F.
		EndIf
		
		If lRet .And. nOper == MODEL_OPERATION_DELETE .And. cRev > "0001"
			Help( ,, 'AF005STAT3',, STR0024, 1, 0 ) //"O indice possui revisão anterior e não poderá ser excluido"
			lRet := .F.
		EndIf 
		
		If lRet .And. nOper == MODEL_OPERATION_DELETE .And. cBloq = "1"
			Help( ,, 'AF005STAT',, STR0023, 1, 0 )//"O Status desse índice não permite manutenção"
			lRet := .F.
		EndIf		
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF005VERIF³ Autor ³ Ramon Prado				³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera matriz Acols para preenchimento das cotacoes            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF005VERIF(oModel)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA005                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1=oModel					                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

If nOpc == MODEL_OPERATION_DELETE    //se operacao igual a exclusão

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

	If !lResp    //verifica se há registro em que o indice está amarrado a ficha do ativo
		Help( ,, "AF05VERIF1",, STR0001+cDescInd+' '+STR0002+cCODIND+''+STR0003, 1, 0 ) //mensagem: 'Índice de Código:tal não pode ser excluído, pois está sendo utilizado'
	Endif

	If lResp 
		dbSelectArea( 'FNT' )
		aAreaFNT:=FNT->(GetArea())
		FNT->(dbSetOrder(1))//FNT_FILIAL+FNT_CODIND+FNT_REVIS+DTOS(FNT_DATA)
		If FNT->(MsSeek(xFilial("FNT")+cCODIND))    //verifica se há registro em que o indice está amarrado a alguma taxa
			lResp := .F.
			Help( ,, "AF05VERIF2",, STR0001+cDescInd+' '+STR0002+cCODIND+''+STR0003, 1, 0 ) //mensagem: 'Índice de Código:tal não pode ser excluído, pois está sendo utilizado'
		Endif
		RestArea(aAreaFNT)
	Endif
	
	RestArea(aAreaSN3)
	
Else
	If cTipo == '2'
		
		If lResp .and. oModelFNI:GetValue('FNI_PERIOD') != '2'
			Help( ,, "AF05VERIF3",, STR0019 , 1, 0 ) // 'Para índices Tipo = 2 - Calculado, só é permitido período mensal'
			lResp:=.F.
		EndIf
		
		If lResp .And. ( Empty(dCurvaIni) .Or. Empty(dCurvaFim) )
			Help( ,, "AF05VERIF4",, STR0026 , 1, 0 ) // "Para índices Tipo = 2 - Calculado, os campos de curva inicial e final são obrigatórios"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaIni != FirstDay(dCurvaIni)
			Help( ,, "AF05VERIF5",, STR0027 , 1, 0 ) // "A data inicial da curva de demanda deve ser no primeiro dia do mês"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaFim != LastDay(dCurvaFim)
			Help( ,, "AF05VERIF6",, STR0028 , 1, 0 ) // "A data final da curva de demanda deve ser no ultimo dia do mês"
			lResp:=.F.
		EndIf
		
		If lResp .And.  dCurvaIni > dCurvaFim
			Help( ,, "AF05VERIF7",, STR0029 , 1, 0 ) // "A data final da curva de demanda deve ser superior a data inicial"
			lResp:=.F.
		EndIf
		
		If lResp .And. __nOper == OPER_REVISAR
			If lResp .And. ( Empty(dDataRev) )
				Help( ,, "AF05VERIF8",, STR0030 , 1, 0 ) // "Na operação de revisão, a data de revisão é obrigatória"
				lResp:=.F.
			EndIf
			
			If lResp .And. ( dDataRev != FirstDay(dDataRev) )
				Help( ,, "AF05VERIF9",, STR0031 , 1, 0 ) // "A data de revisão deve ser no primeiro dia do mês"
				lResp:=.F.
			EndIf
			
			If lResp .And.  (dDataRev < dCurvaIni .Or. dDataRev > dCurvaFim)
				Help( ,, "AF05VERIF10",, STR0032 , 1, 0 ) // "A data de revisão deve ser no período da curva de demanda "
				lResp:=.F.
			EndIf
			
			If lResp
				FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS
				cRevAnt := Tira1(cRev) 
				If FNI->(MsSeek(xFilial("FNI") + cCODIND + cRevAnt) ) 
					If lResp .And. dCurvaFim < FNI->FNI_CURVFI  
						Help( ,, "AF05VERIF11",, STR0033 + DTOC(FNI->FNI_CURVFI) , 1, 0 ) //"A data final da curva de demanda não pode ser menor que a data final da revisão anterior: "
						lResp:= .F.
					EndIf
					
					If lResp .And. dDataRev < FNI->FNI_DTREV  
						Help( ,, "AF05VERIF12",, STR0034 + DTOC(FNI->FNI_DTREV) , 1, 0 ) // "A data de revisão da curva de demanda não pode ser menor que a data de revisão anterior: "
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF005BLQL³ Autor ³ Ramon Prado				³ Data ³ 30/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Faz Bloqueio/Desbloqueio de Índices				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AF005BLQL()                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA005                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	Help( ,, 'AF005STAT1',, STR0023, 1, 0 )//"O Status desse índice não permite manutenção"
EndIf

RestArea(aSaveFNI)
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA430CPYºAutor  ³Alvaro Camillo Neto º Data ³  12/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a cópia do projeto                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

	cTitulo      := STR0020 			// "Revisão"
	cPrograma    := 'ATFA005'
	nOperation   := MODEL_OPERATION_INSERT
	
	__nOper      := OPER_REVISAR
	
	oModel := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	
	oModel:SetValue("FNIMASTER","FNI_REVIS",Soma1(cRev))
	oModel:SetValue("FNIMASTER","FNI_CODIND" , cCod )
	
	nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	__nOper      := 0
	
	If nRet == 0 // Confirmada a revisão, bloqueia a revisão anterior
		If FNI->(MsSeek(xFilial("FNI") + cCod + cRev))
			RecLock("FNI",.F.)
			FNI->FNI_STATUS := "2"
			MsUnLock()
		EndIf
	EndIf
Else
	If FNI->FNI_TIPO == '2' 
		Help( ,, "AF05REVIS01",,STR0023 , 1, 0 ) //"O Status desse índice não permite manutenção"
	Else
		Help( ,, "AF05REVIS02",,STR0035 , 1, 0 ) //"A operação de revisão disponivel para os indices ativos e do tipo 2 - Calculado."
	EndIf	
EndIf

RestArea(aArea)

Return