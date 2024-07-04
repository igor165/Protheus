#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAC19.CH"

Static oBrowseUp 	:= Nil
Static oPanelDwn    := Nil
Static oBrowseDMS   := Nil
Static oBrowseDLU   := Nil
Static oRelacDMS    := Nil
Static oRelacDLU    := Nil

/*/{Protheus.doc} TMSAC19()
Painel Integração Planejamento Rotas (TPR)
@author  	Katia
@version 	12.1.35
@since 		17/08/2021
@return 	*/
Function TMSAC19(cFiltro)

Local aCoors     := FWGetDialogSize( oMainWnd )   
Local oPanelUp   := Nil
Local oPanelDwn  := Nil
Local oFWLayerUp := Nil
Local oFWLayerDwn:= Nil
Local aFolders    := {}
Default cFiltro   := ""

Private aRotina := MenuDef()

    // Trata a altura da janela de acordo com a resolução
	DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL
	
	// Cria conteiner para os browses
	oFWLayerUp:= FWLayer():New()
	oFWLayerUp:Init( oDlgPrinc, .F., .T.)

	// Define painel Master
	oFWLayerUp:AddLine("UP"  ,50,.F.)
	oFWLayerUp:AddLine("DOWN",50,.F.)
	
	//-- Browse superior vinculado com estrutura oPanelUp criada
	oPanelUp  := oFWLayerUp:GetLinePanel("UP")
	oBrowseUp := FWMBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription( STR0001 )  
	oBrowseUp:SetAlias('DMR')
	oBrowseUp:SetMenuDef( 'TMSAC19' )
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetProfileID('DMR')
	oBrowseUp:ForceQuitButton()
	oBrowseUp:SetFixedBrowse(.T.)
    oBrowseUp:AddLegend("DMR_STATUS == '1'" , "BR_AMARELO" 	, STR0002 ) //-- Pendente
    oBrowseUp:AddLegend("DMR_STATUS == '2'" , "BR_VERDE"    , STR0003 ) //-- Processado
	oBrowseUp:SetFilterDefault( cFiltro )  

	If nModulo <> 39 //OMS
		oBrowseUp:AddLegend("DMR_STATUS == '3'" , "BR_PRETO"   	, STR0013 ) //-- Cancelado
	EndIf
	
	// Folders - Itens Roteirização, Controle Integração 
	aFolders  := {STR0009, STR0010}    
	oPanelDwn := oFWLayerUp:GetLinePanel("DOWN")
	oFolder   := TFolder():New( 0, 0, aFolders,aFolders, oPanelDwn,,,, .T.,,oPanelDwn:NCLIENTWIDTH/2,oPanelDwn:NCLIENTHEIGHT/2)
    oFolder:bChange := {|nFolder| CriaBrow( nFolder ), AtuBrow(nFolder) } 
 
	//-- Cria novo Layer para as pastas
	oFWLayerDwn := FWLayer():New()
	oFWLayerDwn:Init(oFolder:aDialogs[1], .F., .T.)

	//--- Itens da Roteirização
	oBrowseDMS:= FWMBrowse():New()
	oBrowseDMS:SetAlias('DMS')
	oBrowseDMS:SetOwner(oFolder:aDialogs[1])
	oBrowseDMS:SetMenuDef('')
	oBrowseDMS:SetIgnoreARotina(.T.) 
	oBrowseDMS:SetProfileID('DMS')
	oBrowseDMS:DisableDetails()
	oBrowseDMS:SetFixedBrowse(.T.)
    oBrowseDMS:SetMainProc("TMSAC19")
    oBrowseDMS:AddLegend("DMS_STATUS == '1'" , "BR_AMARELO"   	, STR0002 ) //-- Pendente
	oBrowseDMS:AddLegend("DMS_STATUS == '2'" , "BR_VERMELHO"    , STR0007 ) //-- Rejeitado
    oBrowseDMS:AddLegend("DMS_STATUS == '3'" , "BR_VERDE"   	, STR0003 ) //-- Processado	
    oBrowseDMS:AddLegend("DMS_STATUS == '4'" , "BR_CANCEL"   	, STR0008 ) //-- Falha no Processamento	
	If nModulo == 43
		oBrowseDMS:AddButton(STR0011,{|| TMSAC24(DMS->DMS_FILROT, DMS->DMS_IDROT, DMS->DMS_SEQROT) },,2,,.F.) //Visualizar Mapa
	EndIf
	If nModulo == 39 .And. FindFunction("OMSTPRRota")
		oBrowseDMS:AddButton(STR0011,{|| OMSTPRRota(DMS->DMS_FILROT, DMS->DMS_IDROT, DMS->DMS_SEQROT) },,2,,.F.) //Visualizar Mapa
	EndIf
	
	If nModulo <> 39 //OMS
		oBrowseDMS:AddLegend("DMS_STATUS == '5'" , "BR_PRETO"   	, STR0013 ) //-- Cancelado
	EndIf

	oBrowseDMS:Activate()

	oRelacDMS := FWBrwRelation():New()
	oRelacDMS :AddRelation(oBrowseUp,oBrowseDMS,{{"DMS_FILIAL","xFilial('DMS')" },{"DMS_FILROT","DMR_FILROT"},{"DMS_IDROT","DMR_IDROT"}} )
	oRelacDMS :Activate()

    DMR->(DbSetOrder(1))
	oBrowseUp:Activate()

ACTIVATE MSDIALOG oDlgPrinc CENTER 

LimpaVar()

Return NIL

/*{Protheus.doc} ModelDef
Definição do Modelo
@author  	Katia
@version 	12.1.35
@since 		17/08/2021
@return 	*/
Static Function ModelDef()
Local oModel 	:= NIL
Local oStruFDMR:= FwFormStruct( 1, "DMR" )
Local oStruGDMS:= FwFormStruct( 1, "DMS" )

oModel := MPFormModel():New( "TMSAC19",/*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001)  //Integração Planejamento de Rotas (TPR)

oModel:AddFields( 'MdFieldDMR', Nil	, oStruFDMR, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	
oModel:GetModel("MdFieldDMR"):SetPrimaryKey( { "DMR_FILIAL", "DMR_FILROT", "DMR_IDROT" } )

oModel:AddGrid( "MdGridDMS", "MdFieldDMR", oStruGDMS )
oModel:SetRelation( "MdGridDMS", {	{"DMS_FILIAL","xFilial('DMS')"}, {"DMS_FILROT","DMR_FILROT"}, {"DMS_IDROT","DMR_IDROT"}}, DMS->( IndexKey( 1 ) ) )
oModel:GetModel("MdGridDMS"):SetOptional(.T.)

Return( oModel )

/*{Protheus.doc} ViewDef
Definição da View
@author  	Katia
@version 	12.1.35
@since 		17/08/2021
@return 	*/
Static Function ViewDef()
Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruFDMR := FwFormStruct( 2, "DMR" )
Local oStruGDMS := FwFormStruct( 2, "DMS" )

oModel   := FwLoadModel( "TMSAC19" )

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDMR', oStruFDMR , 'MdFieldDMR' )

oView:AddGrid( "VwGridDMS", oStruGDMS, "MdGridDMS" )

oView:AddIncrementField( 'VwGridDMS', 'DMS_ITEM' )

oView:CreateHorizontalBox( 'FIELD'  , 20 )
oView:CreateHorizontalBox( 'GRID'   , 80 )

oView:SetOwnerView( 'VwFieldDMR' , 'FIELD')
oView:SetOwnerView( 'VwGridDMS'  , 'GRID' )

Return( oView )

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@author  	Katia
@version 	12.1.35
@since 		17/08/21
@return 	aRotina - Array com as opçoes de Menu */   
Static Function MenuDef()
Local aRotina:= {}

ADD OPTION aRotina TITLE STR0004  ACTION "AxPesqui"       OPERATION 1 ACCESS 0    //Pesquisar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAC19" OPERATION 2 ACCESS 0    //Visualizar
If nModulo == 43   //TMS
	ADD OPTION aRotina TITLE STR0011 ACTION "TMSAC24(DMR->DMR_FILROT, DMR->DMR_IDROT, Nil)"   OPERATION 2 ACCESS 0    //"Visualizar mapa"
	ADD OPTION aRotina TITLE STR0014 ACTION "TMSAC19Can()"   OPERATION 2 ACCESS 0    //"Cancelar"
	ADD OPTION aRotina TITLE STR0016 ACTION "TMSAC19Exc()"   OPERATION 2 ACCESS 0    //"Excluir Pendentes"	
ElseIf nModulo == 39 .And. FindFunction("OMSTPRCan") .And. FindFunction("OMSTPRRota") //OMS
	ADD OPTION aRotina TITLE STR0015 ACTION "OMSTPRCan(FwxFilial('DMR') + DMR->DMR_FILROT + DMR->DMR_IDROT)"   OPERATION 2 ACCESS 0    //"Cancelar Envio
	ADD OPTION aRotina TITLE STR0011 ACTION "OMSTPRRota(DMR->DMR_FILROT, DMR->DMR_IDROT, Nil)"   OPERATION 2 ACCESS 0    //"Visualizar mapa"
EndIf

Return(aRotina)


/*{Protheus.doc} CriaBrow
Cria o Browse ao clicar no folder
@type Static Function
@author Katia
@since 22/09/2021
@version 12.1.35
@param nFolder
@return logico
*/
Static Function CriaBrow( nFolder )

Default nFolder := 1

If nFolder == 2 .And. Valtype(oBrowseDLU) == "U"

    //--- Planejamento de Rotas DLU
    aRotina := {}
	oBrowseDLU:= FWMBrowse():New()
	oBrowseDLU:SetAlias('DLU')
	oBrowseDLU:SetOwner(oFolder:aDialogs[2])
	oBrowseDLU:SetMenuDef('TMSAC23')
	oBrowseDLU:SetProfileID('DLU')
	oBrowseDLU:DisableDetails()
    oBrowseDLU:SetFixedBrowse(.T.)
    oBrowseDLU:SetMainProc("TMSAC23")
	oBrowseDLU:SetFixedBrowse(.T.)
	oBrowseDLU:Activate()

	oRelacDLU := FWBrwRelation():New()
	oRelacDLU :AddRelation(oBrowseUp,oBrowseDLU,{{"DLU_FILIAL","xFilial('DLU')" },{"DLU_CHVENT","DMR_FILROT+DMR_IDROT"}} )
	oRelacDLU :Activate()

EndIf
Return .T.


/*{Protheus.doc} AtuBrow()
Atualiza os browses inferiores
@type Static Function
@author Latia
@since 22/09/2021
@version 12.1.35
@param nFolder
@return logico
*/
Static Function AtuBrow(nFolder)

Default nFolder := 0

Do Case
    Case nFolder == 0
		oBrowseUp:Refresh(.T.)
	Case nFolder == 1			
		oBrowseDMS:Refresh(.T.)			
	Case nFolder == 2			
		oBrowseDLU:Refresh(.T.)	
EndCase

Return .T.

/*{Protheus.doc}  LimpaVar()
Limpa variáveis estáticas
@type Static Function
@author Katia
@since 22/09/2021
@version 12.1.35
*/
Static Function LimpaVar()
    oBrowseUp 	:= Nil
    oPanelDwn   := Nil
    oBrowseDMS  := Nil
    oBrowseDLU  := Nil
    oRelacDMS   := Nil
    oRelacDLU   := Nil
Return 

/*/{Protheus.doc} TMSAC19Doc()
Verifica se o Documento está em Roteirização
@author Katia
@since 30/08/2021
@version 12.1.35
Uso TMSA146
@type function
/*/
Function TMSAC19Doc(cChvEnt,cEntidade)
Local aArea     := GetArea()
Local lRet      := .T.
Local cQuery    := "'"
Local cAliasQry := GetNextAlias()

Default cChvEnt  := ""
Default cEntidade:= ""

cQuery := " SELECT COUNT(*) NREG FROM " + RetSqlName("DMS") + " DMS "
cQuery += " WHERE DMS.DMS_FILIAL = '" + xFilial('DMS') + "' "
cQuery += " AND DMS.DMS_CHVENT = '" + cChvEnt + "' "
cQuery += " AND DMS.DMS_ENTIDA = '" + cEntidade + "' "
cQuery += " AND DMS.DMS_STATUS = '1' "   //Pendente
cQuery += " AND DMS.D_E_L_E_T_= ''
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
If (cAliasQry)->(!Eof())
    If (cAliasQry)->NREG > 0
        Help('',1,'TMSAC1901') // "Este Documento está pendente para Roteirização com a TPR. Aguarde o processamento."
        lRet:= .F.
    EndIf
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} TMSAC19St()
Função para obter o status da integração TPR
@author Katia
@since 21/09/2021
@type function
@version 12.1.35
/*/
Function TMSAC19St(cIdRot)
Local aAreaDMR  := DMR->(GetArea())
Local xRet      := "BR_BRANCO"  //-- Não possui integração

Default cIdRot  := ""

If !Empty(cIdRot)
    DMR->(DbSetOrder(1))  
    If DMR->(DbSeek(xFilial("DMR")+cIdRot))
        If DMR->DMR_STATUS == "1" //-- Pendente
            xRet    := "BR_AMARELO"  
        ElseIf DMR->DMR_STATUS == "2" //-- Processado
            xRet    := "BR_VERDE"   
        EndIf 
    EndIf
EndIf

RestArea(aAreaDMR)
Return xRet

/*/{Protheus.doc} TMSAC19Leg
Mostra Legenda Dos Status da Integração TPR - DMR_STATUS
na rotina de Programação (TMSA146) e Viagem (TMSAF60)
@author Katia   
@since  21/09/2021
@type function
@version 12.1.35
/*/
Function TMSAC19Leg()
Local aLegenda := {}

Aadd(aLegenda,{"BR_BRANCO"   , STR0006 })    //-- Não possui integraçaõ 
Aadd(aLegenda,{"BR_VERDE"    , STR0003 })    //-- Processado 

If Len(aLegenda) > 0 
    BrwLegenda( STR0001 , STR0001 , aLegenda )  //Integração TOTVS Planejamento de Rotas (TPR)
EndIf
				
Return 

/*/{Protheus.doc} TMSAC19Can
Função para Cancelar a Roteirização somente
para roteirização pendentes
Obs: caso em que não houve retorno da TPR por 
problemas como URL CallBack invalida
@author Katia   
@since  30/09/2021
@type function
@version 12.1.35
/*/
Function TMSAC19Can()
Local lRet	   := .T. 
Local oModel   := Nil
Local oMdFldDMR:= Nil
Local oMdGrdDMS:= Nil
Local cIdRot   := ""
Local nY       := 0

//-- Verifica se todas os itens estão como Pendentes
If DMR->DMR_STATUS == StrZero(1,Len(DMR->DMR_STATUS))

	lRet:= TMSAC19Sta(DMR->DMR_FILROT,DMR->DMR_IDROT)	

	If lRet
		cIdRot:= DMR->DMR_FILROT  + DMR->DMR_IDROT

		oModel := FWLoadModel( 'TMSAC19' )
		oModel:SetOperation( 4 )
		oModel:Activate()

		oMdFldDMR:= oModel:GetModel("MdFieldDMR")
		oMdGrdDMS:= oModel:GetModel("MdGridDMS")

		oMdFldDMR:LoadValue('DMR_STATUS','3')
		
		For nY := 1 To oMdGrdDMS:Length()	
			oMdGrdDMS:Goline(nY)
			oMdGrdDMS:LoadValue('DMS_STATUS','5')
		Next nY
		
		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		Else
			Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0) 
		EndIf
		oModel:Destroy()
		oModel:= Nil	
		
		If lRet
			//---- Atualiza DLU para cancelado
			cIdRot:= DMR->DMR_FILROT  + DMR->DMR_IDROT
			lRet:= TMSAC19DLU(cIdRot)
		EndIf

	EndIf
Else
	Help('',1,'TMSAC1902') // O Cancelmaneto somente é permitido para Roteirização com status "Pendente".'
	lRet:= .F.
EndIf

Return lRet


/*/{Protheus.doc} TMSAC19Sta
Verifica Status dos Doctos da Roteirização
@author Katia   
@since  30/09/2021
@type function
@version 12.1.35
/*/
Static Function TMSAC19Sta()
Local lRet	   := .T. 
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()

cQuery := " SELECT COUNT(*) NREG FROM " + RetSqlName("DMS") + " DMS "
cQuery += " WHERE DMS.DMS_FILIAL = '" + xFilial('DMS') + "' "
cQuery += " AND DMS.DMS_FILROT = '" + DMR->DMR_FILROT + "' "
cQuery += " AND DMS.DMS_IDROT = '" + DMR->DMR_IDROT + "' "
cQuery += " AND DMS.DMS_STATUS <> '1' "  //1-Pendente
cQuery += " AND DMS.D_E_L_E_T_= ''
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
If (cAliasQry)->(!Eof())
	If (cAliasQry)->NREG > 0
		lRet:= .F.
	EndIf
EndIf
(cAliasQry)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} TMSAC19DLU
Grava o status de Cancelado na DLU
@author Katia   
@since  30/09/2021
@type function
@version 12.1.35
/*/
Function TMSAC19DLU(cIdRot)
Local lRet     := .T.
Local oModel   := Nil
Local aArea    := GetArea()

Default cIdRot := ""

If !Empty(cIdRot)	
	DLU->(DbSetOrder(2))
	If DLU->(DbSeek( xFilial('DLU')  + xFilial('DMR') + 'DMR' + Padr(cIdRot,Len(DLU->DLU_CHVENT))  ))																									
		oModel := FWLoadModel( "TMSAC23" )
		oModel:SetOperation( 4 ) // Alteracao
		oModel:Activate() 

		oModel:GetModel( "MdFieldDLU" ):SetValue( "DLU_STATUS", "3" )	

		lRet := oModel:VldData()
		If lRet 
			oModel:CommitData()
		EndIf
		oModel:Destroy()
		oModel:= Nil	
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet


/*/{Protheus.doc} TMSAC19Exc
Exclusão das Roteirizações Pendentes conforme
parametrização DLV_TMPEXP
@author Totvs 
@since  20/10/2021
@version P12.1.35
@type function
/*/
Function TMSAC19Exc()
Local cTmpExp := ""

cTmpExp:= TMSAC21Tmp()
If !Empty(cTmpExp)
	If MsgYesNo(STR0017)   //Deseja excluir todas Roteirizações Pendentes expiradas ? 
    	FwMsgRun( , { || lRet:= T21PrcCan(cTmpExp) }  , ,  STR0017 ) //'Excluindo Roteirizações Pendentes...'
	EndIf
Else
	Help('',1,'TMSAC1903') //O tempo de expiração para exclusão das Roteirizações Pendentes, não está informado na Configuração de Planejamento de Rotas.
EndIf

Return
