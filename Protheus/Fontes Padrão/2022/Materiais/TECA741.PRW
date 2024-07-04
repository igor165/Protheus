#INCLUDE "TECA741.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aCampos 	:= { 	"TFJ_CODIGO" , "TFJ_PROPOS" , "TFJ_PREVIS" , "TFJ_ENTIDA" ,;
		 "TFJ_CONTRT", "TFJ_CONREV" , "TFJ_ITEMRH" , "TFJ_ITEMMI" , "TFJ_DESCON" }
Static lOrcsim	:=	SuperGetMv("MV_ORCSIMP",,'2') == '1' .AND. HasOrcSimp()

Function TECA741()

Local oBrowse
Local oMBrowse
Local aColumns	:= {}
Local cQuery		:= ""
Local cAliasPro	:= "MNTPRO"
Local oDlg 		:= Nil   							// Janela Principal.
Local aSize	 	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.

DbSelectArea("SX2")
DbSelectArea("SX3")

//utiliza query
DbSelectArea("TFJ") //abre a tabela TFJ para nao dar erro na VIEW
aColumns := At741Cols(cAliasPro)
cQuery   := At741Query()

//Cria a tela para o browse
DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL STYLE WS_DLGFRAME //"Orçamento de Serviços"    
	
	// Cria um Form Browse
	oBrowse := FWFormBrowse():New()
	// Atrela o browse ao Dialog form nao abre sozinho
	oBrowse:SetOwner(oDlg)
	// Indica que vai utilizar query	
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAliasPro)
	oBrowse:SetQuery(cQuery)
	
	//Filtros
	oBrowse:SetUseFilter( .T. )
	oBrowse:SetFieldFilter(aColumns[2]) 
	
	//Colunas
	oBrowse:AddStatusColumns( {|| At741Contr((cAliasPro)->TFJ_STATUS,(cAliasPro)->AD1_STATUS,(cAliasPro)->TFJ_CONTRT)}, { || At741Legen() } )
	oBrowse:SetColumns(aColumns[1])
	
	// Botao de alterar orcamento
	oBrowse:AddButton(STR0002,; // "Alterar" 
		{|| MsgRun(STR0003,STR0004,{|| At741Alt((cAliasPro)->TFJ_CODIGO , (cAliasPro)->TFJ_STATUS , (cAliasPro)->AD1_STATUS) } ) },,,,.F.,1)// "Montando os componentes visuais..."##"Aguarde" 
		
	// Botao de visualizacao orcamento
	oBrowse:AddButton(STR0005,; // "Visualizar" 
		{|| MsgRun(STR0006,STR0007,{|| At741View((cAliasPro)->TFJ_CODIGO) } ) },,,,.F.,1)// "Montando os componentes visuais..."##"Aguarde" 
	
	oBrowse:AddButton(STR0008, { || AT741Legen()},,,, .F., 2 )	//'Legenda' 		 
	
	oBrowse:AddButton(STR0009,{|| oDlg:End() },,,,.F.,1) // "Sair" 
	
	oBrowse:DisableDetails()
	oBrowse:SetDescription(STR0010) //"Orçamento de Serviços"   
	oBrowse:Activate()
		
ACTIVATE DIALOG oDlg CENTERED

Return(Nil)
//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - Cadastro de Caracterisiticas 

@Return 	model
@author 	Serviços
@since 		15/07/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= Nil
Local oModelRH 	:= Nil
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
// Utilizando um model que ja existe em outra aplicacao
If lOrcPrc
	oModel:= FWLoadModel( 'TECA740F' )
	oModelRH := oModel:GetModel("TFF_RH")
Else
	oModel:=FWLoadModel( 'TECA740' )
	oModelRH := oModel:GetModel("TFF_RH")
Endif	

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Cadastro de Caracteristicas 

@Return 	view
@author 	Serviços
@since 		15/07/2015
/*/
//----------------------------------------------------------

Static Function ViewDef()

Local oView   := Nil
Local oModel  := Nil  
Local oStrTFJ := FWFormStruct(2,'TFJ')
Local oStrTFL := FWFormStruct(2,'TFL')
Local oStrTFF := FWFormStruct(2,'TFF')
Local oStrTGV := FWFormStruct(2,'TGV',{|cCpo|  ! AllTrim(cCpo)$'TGV_COD' })
Local oStrTDS := FWFormStruct(2,'TDS',{|cCpo|  ! AllTrim(cCpo)$'TDS_COD' })
Local oStrTDT := FWFormStruct(2,'TDT',{|cCpo|  ! AllTrim(cCpo)$'TDT_COD' })
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lTecXRh := SuperGetMv("MV_TECXRH",,.F.)
Local cStatus := ""
Local oModelRH:= Nil
Local oModelLoc:= Nil
If lOrcPrc
	oModel:= FWLoadModel( 'TECA740F' )
Else
	oModel:= FWLoadModel( 'TECA740' )
Endif	

At740SCmt(.T.) // chama funcao de gravacao da rotina TECA740

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_PROP', oStrTFJ, 'TFJ_REFER' )

//Verificar parametro MV_TECXRH 
If lTecXRh //se MV_TECXRH for .T. mostrar campos TDT_CODHAB e TDT_ESCALA
	//remover os campos TDT_HABX5 e TDT_DHABX5
	oStrTDT:RemoveField("TDT_HABX5")
	oStrTDT:RemoveField("TDT_DHABX5")	  
Else  //se MV_TECXRH for .F.  mostrar campos TV5_HABX5 e TDT_DHABX5
	oStrTDT:RemoveField("TDT_CODHAB")
	oStrTDT:RemoveField("TDT_DSCHAB")
	oStrTDT:RemoveField("TDT_ESCALA")
	oStrTDT:RemoveField("TDT_DSCESC")	
	oStrTDT:RemoveField("TDT_ITESCA")
	oStrTDT:RemoveField("TDT_DSCITE")	  
Endif
oView:AddGrid('VIEW_LOC'  , oStrTFL, 'TFL_LOC')
oView:AddGrid('VIEW_RH'   , oStrTFF, 'TFF_RH')
oView:AddGrid('VIEW_CAR'  , oStrTDS, 'TDS_RH')
oView:AddGrid('VIEW_HAB'  , oStrTDT, 'TDT_RH')
oView:AddGrid('VIEW_CUR'  , oStrTGV, 'TGV_RH')

// Adiciona as visões na tela
oView:CreateHorizontalBox( 'TOP'   , 30 )
oView:CreateHorizontalBox( 'MIDDLE', 70 )

oView:CreateFolder( 'ABAS', 'MIDDLE')
oView:AddSheet('ABAS','ABA01',STR0011)  // 'Locais de Atendimento' 
oView:AddSheet('ABAS','ABA02',STR0012)  // 'Recursos Humanos' 

// cria as abas e sheet para incluir
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS', 'ABA01' ) // Define a área de Locais
oView:CreateHorizontalBox( 'ID_ABA02' ,  60,,, 'ABAS', 'ABA02' ) // Define a área de RH
oView:CreateHorizontalBox( 'ID_ABA02A',  40,,, 'ABAS', 'ABA02' ) // Adicionais aba RH

// cria folder e sheets para Abas de Caracteristicas, Habilidades, Cursos
oView:CreateFolder( 'RH_ABAS', 'ID_ABA02A')
oView:AddSheet('RH_ABAS','RH_ABA02A',STR0013) // 'Caracterisiticas' 
oView:AddSheet('RH_ABAS','RH_ABA02B',STR0014) //"Habilidades" 
oView:AddSheet('RH_ABAS','RH_ABA02C',STR0015) // 'Cursos' 

oView:CreateHorizontalBox( 'ID_RH_01' , 100,,, 'RH_ABAS', 'RH_ABA02A' ) // Define a área de Caracterisiticas do item Rh
oView:CreateHorizontalBox( 'ID_RH_02' , 100,,, 'RH_ABAS', 'RH_ABA02B' ) // Define a área de Habilidades do item Rh
oView:CreateHorizontalBox( 'ID_RH_03' , 100,,, 'RH_ABAS', 'RH_ABA02C' ) // Define a área de Cursos do item Rh

// Faz a amarração das VIEWs dos modelos com as divisões na interface
oView:SetOwnerView( 'VIEW_PROP' , 'TOP'     ) // Cabeçalho
oView:SetOwnerView( 'VIEW_LOC'  , 'ID_ABA01')  // Grid Locais
oView:SetOwnerView( 'VIEW_RH'   , 'ID_ABA02')  // Grid RH

//abas do RH 
oView:SetOwnerView( 'VIEW_CAR'   , 'ID_RH_01')  // Grid Caracteristicas
oView:SetOwnerView( 'VIEW_HAB'   , 'ID_RH_02')  // Grid Habilidades
oView:SetOwnerView( 'VIEW_CUR'   , 'ID_RH_03')  // Grid Cursos

//Nao permitir alteracao na liha do grid
oModelRH := oModel:GetModel("TFF_RH")
oModelRH:SetNoInsertLine(.T.)
oModelRH:SetNoDeleteLine(.T.)
oModelLoc:= oModel:GetModel('TFL_LOC')
oModelLoc:SetNoInsertLine(.T.)
oModelLoc:SetNoDeleteLine(.T.)

oStrTFJ:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
oStrTFL:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
oStrTFF:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
oStrTGV:SetProperty("TGV_CODTFF",MVC_VIEW_CANCHANGE, .F.)
oStrTDS:SetProperty("TDS_CODTFF",MVC_VIEW_CANCHANGE, .F.)
oStrTDT:SetProperty("TDT_CODTFF",MVC_VIEW_CANCHANGE, .F.)

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At741Query

Query com os dados da proposta
@author Serviços
@since 20/07/2015
@version P12
	
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At741Query()
Local cQuery := ""
Local cCampos := ""
Local nI      := 1

For nI := 1 To Len(aCampos)
	cCampos += ", " + aCampos[nI]
Next nI


cQuery += "SELECT  TFJ_STATUS, AD1_STATUS " + cCampos 
cQuery += " FROM " + RetSqlName("TFJ") + " TFJ "
cQuery += " INNER JOIN "  + RetSqlName("ADY") + " ADY ON ADY_FILIAL = '" + xFilial("ADY") + "'"
cQuery += " AND ADY_PROPOS = TFJ_PROPOS " 
cQuery += " AND ADY_PREVIS = TFJ_PREVIS "
cQuery += " INNER JOIN "  + RetSqlName("AD1") + " AD1 ON AD1_FILIAL = '" + xFilial("AD1") + "'"
cQuery += " AND AD1_NROPOR = ADY_OPORTU " 
cQuery += " WHERE TFJ_FILIAL = '" + xFilial("TFJ") + "'" 
cQuery += " AND AD1_STATUS IN ('1','9') "
cQuery += " AND TFJ_STATUS IN ('1','2') " 
cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
cQuery += " AND ADY.D_E_L_E_T_ = ' ' "
cQuery += " AND AD1.D_E_L_E_T_ = ' ' "
cQuery += " AND EXISTS( Select 1 FROM " + RetSqlName("TFL") + " TFL "
cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "   
cQuery += " ON TFL_FILIAL = '" + xFilial("TFF") + "'" 
cQuery += " AND TFL_CODIGO = TFF_CODPAI "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TFJ_CODIGO  = TFL_CODPAI " 
cQuery += " AND TFL.D_E_L_E_T_ = ' ' ) "

If !lOrcSim
	cQuery += " ORDER BY TFJ_PROPOS, TFJ_PREVIS "
Else
	cQuery += "UNION ALL "
	
	cQuery += "SELECT  TFJ_STATUS, '' as AD1_STATUS " + cCampos 
	cQuery += " FROM " + RetSqlName("TFJ") + " TFJ "
	cQuery += " WHERE TFJ_FILIAL = '" + xFilial("TFJ") + "'" 
	cQuery += " AND TFJ_STATUS IN ('1','2') " 
	cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQuery += " AND EXISTS( Select 1 FROM " + RetSqlName("TFL") + " TFL "
	cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "   
	cQuery += " ON TFL_FILIAL = '" + xFilial("TFF") + "'" 
	cQuery += " AND TFL_CODIGO = TFF_CODPAI "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE TFJ_CODIGO  = TFL_CODPAI " 
	cQuery += " AND TFJ_ORCSIM = '1' "
	cQuery += " AND TFL.D_E_L_E_T_ = ' ' ) "
cQuery += " ORDER BY TFJ_PROPOS, TFJ_PREVIS "

EndIf


Return(cQuery)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At741Cols

Colunas para o browse com os dados da proposta
@author Serviços
@since 20/07/2015
@version P12

@param		ExpC1 - Alias utilizado para o retorno das colunas	
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At741Cols(cAliasPro)

Local nI			:= 0 
Local aArea		:= GetArea()
Local aColumns	:= {}
Local aFiltros	:= {}
Local cCampo 	:= ""
Local nLinha 	:= ""

If lOrcSim 
	aCampos 	:= { 	"TFJ_CODIGO" ,  "TFJ_ENTIDA" ,;
		 	"TFJ_CONTRT", "TFJ_CONREV" , "TFJ_ITEMRH" , "TFJ_ITEMMI" , "TFJ_DESCON","TFJ_PROPOS" , "TFJ_PREVIS" }
EndIf

DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)

	If SX3->(dbSeek(aCampos[nI]))
	
		cCampo := AllTrim(SX3->X3_CAMPO)
		
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
	   	aColumns[nLinha]:SetTitle(X3Titulo())
		aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
		aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
		
		If SX3->X3_TIPO == "D"
			aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))
		Else
			aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))	
		EndIf
		
		aAdd(aFiltros,{cCampo,X3Titulo(),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})
		
	EndIf
	
Next nI

SX3->(dbCloseArea())

RestArea(aArea)

Return({aColumns, aFiltros})
//-------------------------------------------------------------------------------
/*/{Protheus.doc} At741Contr
	
@since 24/07/2015
@version P12
		
@param Status do contrato, contrato e revisão

@description
Retorna a cor da legenda

/*/
Function At741Contr(cTFJStat,cAD1Stat,cContrt)
Local lVersion23	:= HasOrcSimp()
Local cColor:= ""

If lVersion23
	cColor:= A741ctr23(cTFJStat,cAD1Stat,cContrt)
Else
	cColor:= A741ctr17(cTFJStat,cAD1Stat,cContrt)
EndIf

Return cColor


/*/{Protheus.doc} AT741Legen
	
@author 
@since 24/07/2015
@version 12
@description
Apreseentação das Legendas disponiveis
/*/
Static Function AT741Legen()
	Local oLegenda  :=  FWLegend():New()
	
	
	If !lOrcsim
		oLegenda:Add( '', 'BR_VERDE'	, STR0016)	    //'Oportunidade Aberta Sem Contrato' 
		oLegenda:Add( '', 'BR_AMARELO'	, STR0017 )		//'Contrato Em Revisão' 
		oLegenda:Add( '', 'BR_VERMELHO'	, STR0018 )		//'Oportunidade Fechada com Contrato' 
		oLegenda:Add( '', 'BR_PRETO'	, STR0023 )		//'Oportunidade Fechada sem Contrato		
	Else
		oLegenda:Add( '', 'BR_VERDE'	, STR0024)	    //'Sem contrato gerado' 
		oLegenda:Add( '', 'BR_AMARELO'	, STR0017 )		//'Contrato Em Revisão' 
		oLegenda:Add( '', 'BR_VERMELHO'	, STR0025 )		//'Contrato Gerado' 
		oLegenda:Add( '', 'BR_PRETO'	, STR0023 )		//'Oportunidade Fechada sem Contrato' 
	EndIf
	
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil
/*/{Protheus.doc} At741Alt

@author 
@since 24/07/2015
@version 12
		
@param cCodTFJ, character

@description
Apresenta visualização do orçamento de serviço.

/*/
Function At741Alt(cCodTFJ,cTFJStat,cAD1Stat)	

Local lRet := .F.
Local lVersion23	:= HasOrcSimp()

If lVersion23
	lRet := At741Alt23(cCodTFJ,cTFJStat,cAD1Stat)
Else
	lRet :=	At741Alt17(cCodTFJ,cTFJStat,cAD1Stat)
EndIf

Return lRet 


//------------------------------------------------------------------------
/*/{Protheus.doc} At741View

@author 
@since 24/07/2015
@version 12
		
@param cCodTFJ, character

@description
Apresenta visualização do orçamento de serviço.

/*/
Function At741View(cCodTFJ)	
	Local aArea 	:= {}
	Local oModel 	:= Nil
	Local lRet 	:= .F.
		
	aArea 	:= TFJ->(GetArea())
	TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))
			
		FWExecView(STR0021,"VIEWDEF.TECA741", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Orçamento de Serviços" 
		
	Else
		Help( ' ', 1, 'TECA741', , STR0022 , 1, 0 )	//"Orçamento de Serviços não encontrado" 
	EndIf
	
	TFJ->(RestArea(aArea))
Return 



/*/{Protheus.doc} At741Alt17
@author diego.bezerra
@since 20/12/2018
@version 12
@param cCodTFJ, character
@description
Apresenta visualização do orçamento de serviço. - Versão p12117
/*/
Static Function At741Alt17(cCodTFJ,cTFJStat,cAD1Stat)

Local aArea 	:= {}
Local oModel 	:= Nil
Local lRet 	:= .F.
		
aArea 	:= TFJ->(GetArea())
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO

If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ)) .AND. ( cAD1Stat <> '9' .OR.  cTFJStat == '2' )
	lRet := .T.
	FWExecView(STR0019,"VIEWDEF.TECA741", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Orçamento de Serviços" 
Else
	lRet := .F.
	Help( ' ', 1, 'TECA741', , STR0020, 1, 0 )	//"Oportunidade Fechada Com Contrato não ode ser alterada" 
EndIf

TFJ->(RestArea(aArea))

Return lRet

/*/{Protheus.doc} At741Alt23

@author diego.bezerra
@since 20/12/2018
@version 12
@param cCodTFJ, character
@description
Apresenta visualização do orçamento de serviço. - Versão p12123
/*/
Static Function At741Alt23(cCodTFJ,cTFJStat,cAD1Stat)

Local aArea 	:= {}
Local oModel 	:= Nil
Local lRet 	:= .F.
Local lTfj	:= .F.

aArea 	:= TFJ->(GetArea())
TFJ->(DbSetOrder(1))//TFJ_FILIAL+TFJ_CODIGO
lTfj := TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ)) 
	
If lTfj .AND. ((Empty(cAD1Stat) .AND. (cTFJStat == '2' .OR. Empty(TFJ_CONTRT)) ) .OR. ((!Empty(cAD1Stat) .AND. cAD1Stat <> '9') .OR.  cTFJStat == '2') ) .AND. !(!lOrcsim .AND. TFJ->TFJ_ORCSIM == '1')
	lRet := .T.
	FWExecView(STR0019,"VIEWDEF.TECA741", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Orçamento de Serviços" 
Else
	If (!lOrcsim .AND. TFJ->TFJ_ORCSIM == '1') 
		lRet := .F.
		Help( ' ', 1, 'TECA741', ,STR0026, 1, 0 )	//"Não é possível editar esse orçamento com o parâmetro MV_ORCSIM == '2'."
	ElseIf(!Empty(TFJ_CONTRT) .AND. Empty(cAD1Stat))		
		lRet := .F.
		Help( ' ', 1, 'TECA741', , STR0027, 1, 0 )	//"Oportunidade Fechada Com Contrato não ode ser alterada"
	Else 	
		lRet := .F.
		Help( ' ', 1, 'TECA741', , STR0020, 1, 0 )	//"Oportunidade Fechada Com Contrato não ode ser alterada" 
	EndIf 
EndIf

TFJ->(RestArea(aArea))

Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} At741Contr
	
@since 24/07/2015
@version P12
		
@param Status do contrato, contrato e revisão

@description
Retorna a cor da legenda - Versão 12.1.23

/*/

Function A741ctr23(cTFJStat,cAD1Stat,cContrt)
Local cColor:="BR_AMARELO"
Local aArea:=GetArea()

DbSelectArea("TFJ")
DbSetOrder(1)

If cTFJStat == '1' .AND. (cAD1Stat <> '9' .OR. Empty(cAD1Stat)) .AND. Empty(cContrt)
	cColor	:=	"BR_VERDE"
ElseIf cTFJStat == '2' //.AND. cAD1Stat <> '9'
		cColor	:=	"BR_AMARELO"
ElseIf (cAD1Stat  ==  '9' .AND. !Empty(cContrt)) .OR. (!Empty(cContrt) .AND. Empty(cAD1Stat))
		cColor	:=	"BR_VERMELHO"
ElseIf cAD1Stat  ==  '9' .AND. Empty(cContrt)
		cColor	:=	"BR_PRETO"
EndIf

RestArea(aArea)
Return cColor



//-------------------------------------------------------------------------------
/*/{Protheus.doc} At741Contr
	
@since 24/07/2015
@version P12
		
@param Status do contrato, contrato e revisão

@description
Retorna a cor da legenda versão 12.1.17

/*/

Function A741ctr17(cTFJStat,cAD1Stat,cContrt)
Local cColor:="BR_AMARELO"
Local aArea:=GetArea()

DbSelectArea("TFJ")
DbSetOrder(1)

If cTFJStat == '1' .AND. cAD1Stat <> '9'
	cColor	:=	"BR_VERDE"
ElseIf cTFJStat == '2' //.AND. cAD1Stat <> '9'
		cColor	:=	"BR_AMARELO"
ElseIf cAD1Stat  ==  '9' .AND. !Empty(cContrt)
		cColor	:=	"BR_VERMELHO"
ElseIf cAD1Stat  ==  '9' .AND. Empty(cContrt)
		cColor	:=	"BR_PRETO"
EndIf

RestArea(aArea)
Return cColor
