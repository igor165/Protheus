#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'TECA801.CH'

Static lGravou := .F.
Static cTEW_CODMV := ""
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA801
	Browse para Visualizar os registros substituídos
		Executa o browse do Teca800 configurando o filtro da rotina
@sample 	TECA801() 
@since		04/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function TECA801()

TECA800( 'TEW->TEW_DTRINI <> CTOD("") .And. TEW->TEW_DTRFIM == CTOD("")' )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At801Subs
	Chama a view do processo de substituição
		
@sample 	At801Subs() 
@since		04/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At801Subs( cTab, nOpc, nRecno )

Local lConfirm := .F.

If TEW->TEW_DTRINI <> CTOD("") .And. TEW->TEW_DTRFIM == CTOD("") .And. TEW->TEW_DTAMNT == CTOD('')
	lGravou := .F.
	If !(isBlind())
		lConfirm := ( FWExecView( STR0001,'VIEWDEF.TECA801', MODEL_OPERATION_UPDATE,/*oDlg*/,; // 'Substituição de Eq. Locado'
			{||.T.}/*bCloseOk*/,/*bOk*/,/*nPercRed*/,/*aButtons*/,/*bCancel*/ ) == 0 )
	EndIf
Else
	Help(,,'AT801NOITEM',, STR0002,1,0) // 'Item não pode sofrer a substituição' 
EndIf

Return lConfirm

//------------------------------------------------------------------------------
/*/{Protheus.doc} Modeldef
	Faz a criaçaõ do modelo de dados para o processo de substituição
		
@sample 	At801Subs() 
@since		04/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function Modeldef()

Local oObjMdl   := Nil
Local oStrSub   := FWFormStruct(1,'TEW')
Local oStrNew   := FWFormStruct(1,'TEW')
Local oStrPvAd  := FWFormStruct(1,'TWR')
Local xAux 		:= {}
Local aArea 	:= {}

oObjMdl := MPFormModel():New('TECA801',;
                             /*bPreValid*/,;
                             {|oModel| At801TdOk(oModel)} /*bTudoOk*/,;
                             {|oModel| At801Grv(oModel)} /*bCommit*/,;
                             /*bCancel*/)

oStrNew:SetProperty('TEW_BAATD', MODEL_FIELD_OBRIGAT, .T.)
oStrNew:SetProperty('TEW_BAATD', MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,xValueOld| At801NSVld( oMdlVld,cCampo,xValueNew,xValueOld ) })

// remove os campos obrigatórios pois serão preenchidos posteriormente na gravação da rotina
// parâmetros recebidos no valid >> oMdlVld,cCampo,xValueNew,nLine,xValueOld <<
oStrPvAd:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
oStrPvAd:SetProperty( "TWR_FILPED", MODEL_FIELD_OBRIGAT, .T. )
oStrPvAd:SetProperty( "TWR_DESTIN", MODEL_FIELD_OBRIGAT, .T. )
oStrPvAd:SetProperty( "TWR_CLIENT", MODEL_FIELD_VALID, ;
					{|a,b,c,d,e| Vazio() .Or. AtChkHasKey( "SA1", 1, xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT") ) } )
oStrPvAd:SetProperty( "TWR_LOJACL", MODEL_FIELD_VALID, ;
					{|a,b,c,d,e| Vazio() .Or. AtChkHasKey( "SA1", 1, xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT")+FwFldGet("TWR_LOJACL") ) } )
oStrPvAd:SetProperty( "TWR_CLENTR", MODEL_FIELD_VALID, ;
					{|a,b,c,d,e| Vazio() .Or. AtChkHasKey( "SA1", 1, xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR") ) } )
oStrPvAd:SetProperty( "TWR_LOJENT", MODEL_FIELD_VALID, ;
					{|a,b,c,d,e| Vazio() .Or. AtChkHasKey( "SA1", 1, xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR")+FwFldGet("TWR_LOJENT") ) } )
oStrPvAd:SetProperty( "TWR_CONDPG", MODEL_FIELD_VALID, ;
					{|a,b,xValueNew,d,e| Vazio() .Or. AtChkHasKey( "SE4", 1, xFilial("SE4",FwFldGet("TWR_FILPED"))+xValueNew ) } )
oStrPvAd:SetProperty( "TWR_TES", MODEL_FIELD_VALID, ;
					{|a,b,xValueNew,d,e| Vazio() .Or. AtChkHasKey( "SF4", 1, xFilial("SF4",FwFldGet("TWR_FILPED"))+xValueNew ) } )
oStrPvAd:SetProperty( "TWR_CNPJ", MODEL_FIELD_VALID, ;
					{|oMdlVld,b,xValueNew,d,e| Vazio() .Or. ;
					At820Cnpj( oMdlVld, iif(oMdlVld:GetValue("TWR_DESTIN")=="1","FIL","ENT"), xValueNew ) } )

// ----------------------------------------------
//   Campo para receber qual status será inserido para o equipamento
//  que teve o movimento cancelado
oStrSub:AddField(STR0003,;				// cTitle  // 'Status Equipamento'
                 STR0003,;				// cToolTip  // 'Status Equipamento'
                 'TEW_STATUS',;			// cIdField
                 'C',;					// cTipo
                 2,;						// nTamanho
                 0,;						// nDecimal
                 {|oMdl, cCampo, xValueNew, nLine, xValueOld| ( xValueNew $ '03+05+06')},; // bValid
                 {||.T.},;				// bWhen
                 {'03=' + STR0004,;	// 'Manutenção'
                  '05=' + STR0005,;	// 'Extraviado'
                  '06=' + STR0006;		// 'Deteriorado'
                 },;						// aValues
                 .T.,;					// lObrigat
                 {||'03'},;				// bInit - inicia conteúdo como manutenção
                 Nil,;					// lKey
                 .F.,;					// lNoUpd
                 .T.)					// lVirtual

// campo para a quantidade distribuída do item
oStrPvAd:AddField(STR0017,;				// cTitle  // "Qt Sep"
                  STR0017,;				// cTitle  // "Qt Sep"
                  "TWR_QTSEP","N",11,0,Nil,Nil,Nil,.F.,Nil,Nil,.F.,.T. ) 

// campo para indicar se há necessidade de gerar o pedido de remessa ou não
oStrPvAd:AddField(STR0018,;				// cTitle  //"Exige NF?"
                  STR0018,;				// cTitle  //"Exige NF?"
                  'TWR_EXIGNF','C',1,0,NIL,NIL,NIL,.F.,NIL,.F.,Nil,.T.)

At801AA3Cpos( oStrNew )

//------------------------------------------
//  Gatilho para criar as linhas para receber as informações do pedido adicional
xAux := FwStruTrigger( 'TEW_BAATD', 'TEW_BAATD', 'At801PvAdc()', .F. )
		oStrNew:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
// Gatilhos dos pedidos adicionais
// -------------------------------------------------------------------------------------------------
xAux := FwStruTrigger( 'TWR_CLIENT', 'TWR_NOME',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT")+FwFldGet("TWR_LOJACL"),"A1_NOME")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_LOJACL', 'TWR_NOME',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT")+FwFldGet("TWR_LOJACL"),"A1_NOME")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_CLENTR', 'TWR_NOMENT',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR")+FwFldGet("TWR_LOJENT"),"A1_NOME")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_LOJENT', 'TWR_NOMENT',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR")+FwFldGet("TWR_LOJENT"),"A1_NOME")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

// gatilhos dos campos de CNPJ >>> essenciais na operação triangular
xAux := FwStruTrigger( 'TWR_CLIENT', 'TWR_CNPJ',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT")+FwFldGet("TWR_LOJACL"),"A1_CGC")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_LOJACL', 'TWR_CNPJ',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLIENT")+FwFldGet("TWR_LOJACL"),"A1_CGC")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_CLENTR', 'TWR_CNPJEN',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR")+FwFldGet("TWR_LOJENT"),"A1_CGC")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TWR_LOJENT', 'TWR_CNPJEN',;
				'Posicione("SA1",1,xFilial("SA1",FwFldGet("TWR_FILPED"))+FwFldGet("TWR_CLENTR")+FwFldGet("TWR_LOJENT"),"A1_CGC")', .F. )
		oStrPvAd:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
// -------------------------------------------------------------------------------------------------

oObjMdl:AddFields('SUB_TEW',/*Id Superior*/,oStrSub)
oObjMdl:AddFields('NEW_TEW','SUB_TEW',oStrNew)
oObjMdl:AddGrid('PV_TWR','NEW_TEW',oStrPvAd,{|oMdlG,nLine,cAcao,cCampo,e| At820AvPedAd( oMdlG,nLine,cAcao,cCampo,e ) })

oObjMdl:SetRelation('NEW_TEW',{{'TEW_FILIAL','xFilial("TEW")'},{'TEW_CODMV','TEW_SUBSTI'}},TEW->(IndexKey(1)))

oObjMdl:GetModel('PV_TWR'):SetOptional(.T.)
oObjMdl:GetModel('PV_TWR'):SetOnlyQuery(.T.)

oObjMdl:GetModel('PV_TWR'):SetNoInsertLine(.T.)
oObjMdl:GetModel('PV_TWR'):SetNoDeleteLine(.T.)

oObjMdl:SetDescription(STR0007)
oObjMdl:GetModel('SUB_TEW'):SetDescription(STR0008) // 'Item Substituído'
oObjMdl:GetModel('NEW_TEW'):SetDescription(STR0009) // 'Item Substituto'
oObjMdl:GetModel('PV_TWR'):SetDescription(STR0019) // 'Pedidos adicionais'

oObjMdl:SetActivate( {|oMdlGeral| At801Init( oMdlGeral ) } )

Return oObjMdl

//------------------------------------------------------------------------------
/*/{Protheus.doc} At801Init
	Inicia as informações no segundo modelo
		
@sample 	At801Init() 
@since		05/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At801Init( oMdl )

Local nX        := 0
Local aFields   := {'TEW_CODEQU','TEW_ORCSER','TEW_PRODUT','TEW_CODKIT','TEW_KITSEQ','TEW_TIPO','TEW_CODCLI','TEW_LOJCLI'}
Local cCodMv    := ''

If !lGravou
	oMdl:GetModel('SUB_TEW'):SetValue('TEW_DTAMNT', dDataBase )  // insere a data de hj na atualização do registro
	oMdl:GetModel('SUB_TEW'):SetValue('TEW_MOTIVO', '1' )  // intervenção igual a '1 - Substituição'
	
	//-------------------------------------------------------------
	//  Caso não recupere registro válido
	If Empty( oMdl:GetModel('NEW_TEW'):GetValue( 'TEW_CODMV' ) )
		
		If EMPTY(At801UpCod())
			cCodMv    := GetSxeNum('TEW','TEW_CODMV')
		Else
			cCodMv    := At801UpCod() //utilizado na automação
		EndIf
		
		For nX := 1 To Len( aFields )
			oMdl:GetModel('NEW_TEW'):SetValue( aFields[nX], oMdl:GetModel('SUB_TEW'):GetValue(aFields[nX]) )
		Next nX
		
		oMdl:GetModel('NEW_TEW'):SetValue( 'TEW_CODMV' , cCodMv )
		oMdl:GetModel('SUB_TEW'):SetValue( 'TEW_SUBSTI', cCodMv )
		
	EndIf
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Viewdef
	Interface para substituição de equipamento
@sample 	Viewdef() 
@since		04/11/2013       
@version	P11.90
@return  	oRet, objeto, objeto da view
/*/
//------------------------------------------------------------------------------
Static Function Viewdef()

Local oObjView   := Nil
Local oObjMdl    := FwLoadModel('TECA801')

Local oStrSup  := FWFormStruct(2, 'TEW',{|cCpo| SelecCpos( cCpo ) } )
Local oStrInf  := FWFormStruct(2, 'TEW',{|cCpo| Selec2Cpos( cCpo ) } )
Local oStrTWR  := FWFormStruct(2,'TWR')

oStrSup:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
oStrSup:SetProperty( 'TEW_OBSMNT', MVC_VIEW_CANCHANGE, .T. )

oStrInf:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
oStrInf:SetProperty( 'TEW_BAATD', MVC_VIEW_CANCHANGE, .T. )
oStrInf:SetProperty( 'TEW_BAATD', MVC_VIEW_LOOKUP, 'AA3LC1' )

// ----------------------------------------------
//   Campo para receber qual status será inserido para o equipamento
//  que teve o movimento cancelado
oStrSup:AddField('TEW_STATUS',;			// cIdField
                 'zz',;					// cOrdem
                 STR0003,;				// cTitulo // 'Status Equipamento'
                 STR0003,;				// cDescric // 'Status Equipamento'
                 {STR0010,STR0011},;	// aHelp
                 'C',;					// cType  // COMBO
                 '',;					// cPicture
                 Nil,;					// nPictVar
                 Nil,;					// Consulta F3
                 .T.,;					// lCanChange
                 '01',;					// cFolder
                 Nil,;					// cGroup
                 {'03='+ STR0004,;		// 'Manutenção'
                  '05='+ STR0005,;		// 'Extraviado'
                  '06='+ STR0006;		// 'Deteriorado'
                 },;						// aComboValues
                 15,;					// nMaxLenCombo
                 Nil,;					// cIniBrow
                 .T.,;					// lVirtual
                 Nil)					// cPictVar

// remove os campos que somente serão preenchidos na gravação da separação dos pedidos adicionais
oStrTWR:RemoveField("TWR_CODMOV")
oStrTWR:RemoveField("TWR_NUMPED")
oStrTWR:RemoveField("TWR_PEDIT")
oStrTWR:RemoveField("TWR_ATUFIL")
oStrTWR:RemoveField("TWR_CODTFI")
oStrTWR:RemoveField("TWR_SAIDOC")
oStrTWR:RemoveField("TWR_SAISER")
oStrTWR:RemoveField("TWR_SAIITE")
oStrTWR:RemoveField("TWR_SDOCS")
oStrTWR:RemoveField("TWR_ENTDOC")
oStrTWR:RemoveField("TWR_ENTSER")
oStrTWR:RemoveField("TWR_ENTITE")
oStrTWR:RemoveField("TWR_SDOCE")

oObjView := FWFormView():New()
oObjView:SetModel(oObjMdl)

oObjView:AddField('VIEW_SUBS' , oStrSup,'SUB_TEW' )
oObjView:AddField('VIEW_NEW' , oStrInf,'NEW_TEW' )
oObjView:AddGrid('VIEW_PVAD' , oStrTWR,'PV_TWR' )

oObjView:CreateHorizontalBox( 'VIEW', 100)
oObjView:CreateFolder( "ABAS", "VIEW" )
oObjView:AddSheet("ABAS", "ABA01", STR0020)	//"Itens Locação"
oObjView:AddSheet("ABAS", "ABA02", STR0019)	//"Pedidos adicionais"

oObjView:CreateHorizontalBox( 'VIEW_SUP', 65,,, "ABAS", "ABA01")
oObjView:CreateHorizontalBox( 'VIEW_INF', 35,,, "ABAS", "ABA01")

oObjView:CreateHorizontalBox('VIEW_GRID', 100,,,"ABAS", "ABA02")

oObjView:SetOwnerView('VIEW_SUBS','VIEW_SUP')
oObjView:SetOwnerView('VIEW_NEW','VIEW_INF')
oObjView:SetOwnerView('VIEW_PVAD','VIEW_GRID')

oObjView:EnableTitleView('VIEW_SUBS', STR0008 ) // 'Movimento Substituído'
oObjView:EnableTitleView('VIEW_NEW', STR0009 ) // 'Movimento Substituto'

Return oObjView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SelecCpos
	Interface para substituição de equipamento
@sample 	Viewdef() 
@since		04/11/2013       
@version	P11.90
@return  	oRet, objeto, objeto da view
/*/
//------------------------------------------------------------------------------
Static Function SelecCpos( cCpo )

Local lRet := ( Alltrim(cCpo) $ 'TEW_CODMV+TEW_CODEQU+TEW_PRODUT+TEW_BAATD+TEW_DTSEPA+TEW_DTRINI+TEW_EQ3' )

lRet := lRet .Or. ( Alltrim( cCpo ) $ 'TEW_OBSMNT+TEW_DTAMNT+TEW_ORCSER+TEW_NFSAI+TEW_SERSAI+TEW_ITSAI' )

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Selec2Cpos
	Interface para substituição de equipamento
@sample 	Selec2Cpos() 
@since		04/11/2013       
@version	P11.90
@return  	lRet, Lógico
/*/
//------------------------------------------------------------------------------
Static Function Selec2Cpos( cCpo )

Local lRet := ( Alltrim(cCpo) $ 'TEW_CODMV+TEW_CODEQU+TEW_PRODUT+TEW_BAATD+TEW_ORCSER' )

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At801TdOk
	Validação do modelo
@sample 	At801Vld(oModel) 
@since		02/09/2016      
@version	P12
@return  	lRet, Lógico
/*/
//------------------------------------------------------------------------------
Static Function At801TdOk(oModel)

Local oMdlSubTEW	:= oModel:GetModel("SUB_TEW")
Local oMdlNewTEW	:= oModel:GetModel('NEW_TEW')
Local lRet			:= .T.
Local aArea			:= GetArea()

If	oMdlSubTEW:GetValue("TEW_FILIAL") + oMdlSubTEW:GetValue("TEW_BAATD") == oMdlNewTEW:GetValue("TEW_FILIAL") + oMdlNewTEW:GetValue("TEW_BAATD")
	Help(,,"At801TdOk",,STR0015, 1, 0,,,,,,{STR0016})	//"Não é permitida a efetivação da substituição de uma base de atendimento por ela mesma." ## "Escolha outra base de atendimento para que seja permitida a sua substituição."
	lRet	:= .F. 
EndIf

// chama a rotina que consiste o preenchimento dos pedidos adicionais
lRet := lRet .And. At820PvVld( oModel, oModel:GetModel("PV_TWR") )

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At801Grv
	Interface para substituição de equipamento
@sample 	At801Grv() 
@since		04/11/2013       
@version	P11.90
@param  	oExp, Objeto, objeto do modelo de dados a ser gravado
@return  	lRet, Logico, status da gravação
/*/
//------------------------------------------------------------------------------
Function At801Grv( oMdlGeral )

Local lRet      := .T.
Local cCliPed   := ''
Local cLojPed   := ''
Local cItem     := StrZero( 1, TamSx3('C6_ITEM')[1] )
Local aPedCabec := {}
Local aPedItens := {}
Local xAux     := {}
Local cDescErro := ''
Local oMdlNew  := oMdlGeral:GetModel('NEW_TEW')
Local oMdlSub  := oMdlGeral:GetModel('SUB_TEW')
Local oMdlTWR  := oMdlGeral:GetModel('PV_TWR')
Local cExgNf	:= ""
Local lGerouPv	:= .F.
Local lNeedPedAdc := .F.
Local lPedAdcOk := .F.
Local cProdCod := ""
Local cPvPrincipal := ""
Local cPrdAA3 	:= ""

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

Begin Transaction
//--------------------------------------------------------------------
//  só executa a gravação dos dados 1 vez
// necessário pelo MVC não fechar a janela quando é alteração
If !lGravou  
	
	DbSelectArea('SB1')
	SB1->( DbSetOrder( 1 ) )  // B1_FILIAL+B1_COD
	
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	
	//Verifica se a base de atendimento gera pedido de remessa
	cExgNf := oMdlNew:GetValue("AA3_EXIGNF")

	lRet := At820CliLoj( @cCliPed, @cLojPed, oMdlNew:GetValue('TEW_CODEQU') )
	cProdCod := At820GetPrd( oMdlGeral, TFI->TFI_FILIAL, "NEW_TEW" )

	//-------------------------------------------------
	//  Gera o Pedido de Remessa para o equipamento substituto
	If lRet .And. cExgNf=="1" .And. ;
		SB1->( DbSeek( xFilial('SB1')+cProdCod ) )
	
		aAdd( aPedCabec, {'C5_TIPO'   , 'N', Nil } )
		aAdd( aPedCabec, {'C5_CLIENTE', cCliPed, Nil } )
		aAdd( aPedCabec, {'C5_LOJACLI', cLojPed , Nil } )
		aAdd( aPedCabec, {'C5_CONDPAG', TFJ->TFJ_CONDPG, Nil } )
		If !Empty( TFJ->TFJ_TPFRET )
			aAdd( aPedCabec, {'C5_TPFRETE', TFJ->TFJ_TPFRET ,Nil})
		Endif
		
		aAdd( xAux, {'C6_ITEM'   , cItem, Nil } )
		aAdd( xAux, {'C6_PRODUTO', cProdCod, Nil } )
		aAdd( xAux, {'C6_QTDVEN' , 1, Nil } )
		aAdd( xAux, {'C6_PRCVEN' , SB1->B1_PRV1, Nil } )
		aAdd( xAux, {'C6_PRUNIT' , SB1->B1_PRV1, Nil } )
		aAdd( xAux, {'C6_VALOR'  , SB1->B1_PRV1, Nil } )
		aAdd( xAux, {'C6_TES'    , TFI->TFI_TES, Nil } )
		aAdd( xAux, {'C6_NUMSERI', oMdlNew:GetValue("TEW_BAATD"), Nil } )
		
		aAdd( aPedItens, aClone( xAux ) )
		
		lMsErroAuto := .F.
		MsExecAuto( { |x,y,z| MATA410( x, y, z ) }, aPedCabec, aPedItens, 3 )
		
		If lMsErroAuto
			lRet := .F.
			xAux := GetAutoGrLog()
			MostraErro()
		Else
			lGerouPv := .T.
			cPvPrincipal := SC5->C5_NUM
		EndIf
	EndIf
		
	aSize( xAux, 0 )
	xAux := {}
	
	//--------------------------------------
	//  Atualiza o status do equipamento sendo substituído
	aAdd( xAux, { 'AA3_STATUS', oMdlSub:GetValue('TEW_STATUS') } )
	cPrdAA3 := At820FilPd( oMdlSub:GetValue('TEW_PRODUT'), oMdlSub:GetValue('TEW_FILIAL'), oMdlSub:GetValue('TEW_FILBAT') )
	If ( lRet := lRet .And. ;
		At800Status( @cDescErro, xAux, xFilial('AA3')+oMdlSub:GetValue('TEW_BAATD')+oMdlSub:GetValue('TEW_FILBAT'), .T., ) )
		
		aSize( xAux, 0 )
		xAux := {}
		
		oMdlTWR:GoLine(1)
		
		If lRet .And. !Empty( oMdlTWR:GetValue("TWR_FILPED") )
			lNeedPedAdc := .T.
			// chama a função para gerar os pedidos adicionais e incluir as novas linhas na tabela TWR
			lRet := At820GerAdc( oMdlTWR, TFJ->TFJ_TPFRET, TFI->TFI_CONTRT, TFI->TFI_CONREV )
		EndIf
		
		//--------------------------------------
		//  Atualiza o status do equipamento substituto
		aAdd( xAux, { 'AA3_CODCLI', cCliPed } )
		aAdd( xAux, { 'AA3_LOJA'  , cLojPed } )
		aAdd( xAux, { 'AA3_INALOC', dDataBase } )
		aAdd( xAux, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
		aAdd( xAux, { 'AA3_STATUS', '07' } ) // Status = 07 - Equipamento Separado
		aAdd( xAux, { 'AA3_FILLOC', TFI->TFI_FILIAL } ) // 
		
		cPrdAA3 := At820FilPd( oMdlNew:GetValue('TEW_PRODUT'), oMdlNew:GetValue('TEW_FILIAL'), oMdlNew:GetValue('TEW_FILBAT') )
		If ( lRet := lRet .And. ;
			At800Status( @cDescErro, xAux, xFilial('AA3')+oMdlNew:GetValue('TEW_BAATD')+oMdlNew:GetValue('TEW_FILBAT'), .T., cPrdAA3 ) )
		
			If lGerouPv
				oMdlNew:SetValue('TEW_NUMPED', cPvPrincipal)
				oMdlNew:SetValue('TEW_ITEMPV', cItem)
			EndIf
			
			oMdlNew:SetValue('TEW_DTSEPA', dDatabase)
		EndIf
	EndIf
	
	lRet := lRet .And. FwFormCommit( oMdlGeral )
	
	If lRet
		//Se gravou o movimento, gera a execução de CheckList
		At806Inc( oMdlNew:GetValue("TEW_CODMV"), oMdlNew:GetValue("TEW_CODEQU"),;
					oMdlNew:GetValue("TEW_KITSEQ"), oMdlNew:GetValue("TEW_PRODUT"),;
					oMdlNew:GetValue("TEW_CODKIT") )
		If !IsBlind()
			lGravou := .T.
			MsgInfo(STR0012)
		EndIf
	Else
		DisarmTransaction()
		Break
	EndIf

EndIf

End Transaction
Return lRet

/*/{Protheus.doc} At801F3 / At801RetF3
	Cria a interface para realizar a consulta das bases disponÃ­veis
@since 	30/12/2015       
@version P12
At801F3
@return 	lRet, Logico, indica se houve a seleção de algum item ou não
At801RetF3
@return 	cRet, Caracter, retorna o item selecionado
/*/
Function At801RetF3()

Return AA3->AA3_NUMSER

// criação da janela
Function At801F3()

Local oDlg 			:= Nil
Local aSize			:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oBrw				:= Nil							// Objeto do Browse
Local aList			:= {}							// Array com os dados a serem apresentados
Local oColumns		:= Nil
Local lConfirm 		:= .F.
Local oMdlGeral 		:= FwModelActive()
Local dDiaIniAloc 	:= CTOD("")
Local dDiaFimAloc 	:= CTOD("")

DbSelectArea("TFI")
TFI->( DbSetOrder( 1 ) ) // TFI_FILIAL + TFI_COD

DbSelectArea("AA3")
AA3->( DbSetOrder( 1 ) ) // AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER

If oMdlGeral:GetId()=="TECA801" .And. TFI->( DbSeek( xFilial("TFI") + oMdlGeral:GetValue("SUB_TEW","TEW_CODEQU") ) )
	
	dDiaIniAloc := dDataBase
	dDiaFimAloc := TFI->TFI_PERFIM
	
	MsgRun(STR0021,STR0022,;	//"Realizando pesquisa..." ## "Equipamentos disponíveis"
				{ || aList := At801ConSub( oMdlGeral:GetValue("SUB_TEW","TEW_PRODUT"),;
										dDiaIniAloc, ;
										dDiaFimAloc ) } )
	
	//Cria a tela para o browse
	DEFINE DIALOG oDlg TITLE STR0022 FROM aSize[1],aSize[2] TO aSize[3]-100,aSize[4]-100 PIXEL	//"Equipamentos disponíveis" 
		
		//-----------------------------------------------------
		// ConstrÃ³i o browse para exibiÃ§Ã£o dos dados
		DEFINE FWFORMBROWSE oBrw DATA ARRAY ARRAY aList LINE BEGIN 1 OF oDlg
			
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][2] }") TITLE TxSX3Campo("AA3_FILIAL")[1] 	SIZE TamSX3("AA3_FILIAL")[1] OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][10]}") TITLE TxSX3Campo("AA3_FILORI")[1] 	SIZE TamSX3("AA3_FILORI")[1] OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][3] }") TITLE TxSX3Campo("AA3_NUMSER")[1] 	SIZE TamSX3("AA3_NUMSER")[1] OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][4] }") TITLE TxSX3Campo("AA3_CODPRO")[1] 	SIZE TamSX3("AA3_CODPRO")[1] OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][5] }") TITLE TxSX3Campo("B1_DESC")[1]			SIZE TamSX3("B1_DESC")[1] OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][6] }") TITLE TxSX3Campo("AA3_EQ3")[1]			SIZE TamSX3("AA3_EQ3")[1] OPTIONS Separa(TxSX3Campo("AA3_EQ3")[7],";") OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][7] }") TITLE TxSX3Campo("AA3_EXIGNF")[1] 	SIZE TamSX3("AA3_EXIGNF")[1] OPTIONS Separa(TxSX3Campo("AA3_EXIGNF")[7],";") OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][8] }") TITLE TxSX3Campo("AA3_MANPRE")[1] 	SIZE TamSX3("AA3_MANPRE")[1] OPTIONS Separa(TxSX3Campo("AA3_MANPRE")[7],";") OF oBrw
			ADD COLUMN oColumns DATA &("{ || aList[oBrw:At()][9] }") TITLE TxSX3Campo("AA3_MODELO")[1] 	SIZE TamSX3("AA3_MODELO")[1] OF oBrw
			
		ACTIVATE FWFORMBROWSE oBrw
		
	ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
													{||lConfirm:=.T., AA3->(DbGoTo(aList[oBrw:At()][1])), oDlg:End()},;
													{||lConfirm:=.F., oDlg:End()} )

EndIf
FwModelActive(oMdlGeral)
Return lConfirm

/*/{Protheus.doc} At801ConSub
	Consulta os equipamentos disponÃ­veis no perÃ­odo para a substituiÃ§Ã£o
@since 	30/12/2015
@version P12
@param 	cProdSub, Caracter, indica o cÃ³digo do produto a ter os equipamentos consultados
@param 	dDtIniSub, Data, data inicial da alocaÃ§Ã£o substituta
@param 	dDtFimSub, Data, data final da alocaÃ§Ã£o substituta
@return 	aRet, Lista, informaÃ§Ãµes dos equipamentos disponÃ­veis
/*/
Function At801ConSub( cProdSub, dDtIniSub, dDtFimSub )
Local aDados := {}
Local cCpos := " AA3.R_E_C_N_O_ RECAA3, AA3_FILIAL, AA3_FILORI, AA3_NUMSER, AA3_CODPRO, B1_DESC, AA3_EQ3, AA3_EXIGNF, AA3_MANPRE, AA3_MODELO "
Local cTabTemp := At180xDisp( cProdSub, dDtIniSub, dDtFimSub, dDataBase, cCpos, .F. )

(cTabTemp)->( DbEval( {|| aAdd( aDados, { (cTabTemp)->RECAA3,;
									(cTabTemp)->AA3_FILIAL,;
									(cTabTemp)->AA3_NUMSER,;
									(cTabTemp)->AA3_CODPRO,;
									(cTabTemp)->B1_DESC,;
									(cTabTemp)->AA3_EQ3,;
									(cTabTemp)->AA3_EXIGNF,;
									(cTabTemp)->AA3_MANPRE ,;
									(cTabTemp)->AA3_MODELO ,;
									(cTabTemp)->AA3_FILORI } ) } ) )

(cTabTemp)->(DbCloseArea())

Return aDados

/*/{Protheus.doc} At801PvAdc
	Chama a função para incluir as linhas dos pedidos adicionais para a remessa do equipamento
@since 		11/08/2016
@version 	P12
/*/
Function At801PvAdc()
Local oModel := FwModelActive()
Local oMdlTWR := oModel:GetModel("PV_TWR")
Local oMdlSub := oModel:GetModel("SUB_TEW")
Local oMdlNew := oModel:GetModel("NEW_TEW")
Local nI := 0
Local aCpos := {}

// limpa eventuais linhas para dados de pedidos adicionais
oMdlTWR:GoLine(1)
If (nI := oMdlTWR:Length()) > 1 .Or. !Empty( oMdlTWR:GetValue("TWR_FILPED") )
	
	oMdlTWR:SetNoDeleteLine(.F.)
	oMdlTWR:GoLine( nI )
	
	While (nI := oMdlTWR:GetLine()) > 1
		oMdlTWR:DeleteLine(.T.,.T.)
	End
	
	aCpos := oMdlTWR:GetStruct():GetFields()
	For nI := 1 To Len( aCpos )
		oMdlTWR:LoadValue(aCpos[nI,MODEL_FIELD_IDFIELD], If(aCpos[nI,MODEL_FIELD_TIPO]=="C","",0) )
	Next nI
	
	oMdlTWR:SetNoDeleteLine(.T.)
EndIf

// chama a função para incluir as linhas para os pedidos adicionais
At820PvAdc( "NEW_TEW", "PV_TWR", { oMdlSub:GetValue("TEW_FILIAL"), oMdlSub:GetValue("TEW_CODEQU") },;
			 .T. /*lFlag*/, oMdlNew:GetValue("TEW_CODMV") )

Return

/*/{Protheus.doc} At801NSVld
	Valida se o número de série pode ser utilizado em substituição ao equipamento alocado
@since 		11/08/2016
@version 	P12
@param 		oMdlVld, Objeto, modelo parcial da rotina que contém o campo sendo validado
@param 		cCampo, Caracter, campo sendo validado (TEW_BAATD)
@param 		xValueNew, Caracter, conteúdo novo a ser inserido no campo
@param 		xValueOld, Caracter, conteúdo anterior do campo
@return 	Lógico, determina se pode ou não realizar a atribuição de conteúdo no campo
/*/
Function At801NSVld( oMdlVld,cCampo,xValueNew,xValueOld )

Local lNumSerOk := .F.
Local dDiaIniAloc := CTOD('')
Local dDiaFimAloc := CTOD('')
Local aInfo := {}
Local nPosInfo := 0
Local nColNumSer := 3
Local nColCodPro := 4
Local nColExigNf := 7
Local nColFilOri := 10
Local oModel := oMdlVld:GetModel()

DbSelectArea("TFI")
TFI->( DbSetOrder( 1 ) ) // TFI_FILIAL + TFI_COD

If TFI->( DbSeek( xFilial("TFI") + oModel:GetValue("SUB_TEW","TEW_CODEQU") ) )

	dDiaIniAloc := dDataBase
	dDiaFimAloc := TFI->TFI_PERFIM
	
	aInfo := At801ConSub( oMdlVld:GetValue("TEW_PRODUT"),dDiaIniAloc,dDiaFimAloc )
	
	If ( nPosInfo := aScan( aInfo, {|x| x[nColNumSer] == xValueNew } ) ) > 0
		lNumSerOk := .T.
		
		oMdlVld:LoadValue("AA3_EXIGNF", aInfo[nPosInfo,nColExigNf] )
		oMdlVld:LoadValue("TEW_FILBAT", aInfo[nPosInfo,nColFilOri] )
		oMdlVld:LoadValue("AA3_FILORI", aInfo[nPosInfo,nColFilOri] )
		oMdlVld:LoadValue("AA3_CODPRO", aInfo[nPosInfo,nColCodPro] )
		oMdlVld:LoadValue("AA3_NUMSER", xValueNew )
		oMdlVld:LoadValue("AA3_FLAG", .T. )
		
	Else
		oModel:GetModel():SetErrorMessage( oModel:GetId(),"TEW_BAATD",oModel:GetId(), "TEW_BAATD",'TEW_BAATD',;
							STR0023,;	//"Equipamento indisponível no estoque."
							I18N(STR0024,{ DTOC(dDiaIniAloc), DTOC(dDiaFimAloc)}) )	//"Selecione um equipamento disponível no período entre #1 a #2."
	EndIf
EndIf
	
Return lNumSerOk

/*/{Protheus.doc} At801AA3Cpos
	Carrega os campos que precisam ser utilizados no processo de inserção das linhas 
para os pedidos adicionais de remessa quando necessário o envio de equipamento de outra filial
@since 		11/08/2016
@version 	P12
@param 		oStruct, Objeto, estrutura a qual os campos precisam ser adicionados (estrutura da nova movimentação)
/*/
Static Function At801AA3Cpos( oStruct )
Local aArea := GetArea()
Local aAreaSX3 := SX3->( GetArea() )
Local aCpos := { 'AA3_EXIGNF', 'AA3_FILORI', 'AA3_CODPRO', 'AA3_NUMSER' }
Local nCpos := 0

SX3->( DbSetOrder( 2 ) )  // X3_CAMPO
// parâmetros valid == oMdl, cCampo, xValueNew, xValueOld ==
For nCpos := 1 To Len(aCpos)
	SX3->( DbSeek( aCpos[nCpos] ) )
	oStruct:AddField( X3Titulo(),X3Descric(),aCpos[nCpos],SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,{||.T.}/*bValid*/,{||.T.},/*aValues*/,.F.,/*bInit*/,.T./*lVirtual*/ )
Next nCpos

oStruct:AddField(STR0025,;                  // cTitle	//"Marca"
                 STR0025,;                  // cDescric	//"Marca"
                 'AA3_FLAG','L',1,0,/*bValid*/,{|| .T.},Nil,Nil,Nil,Nil,.F.,.T. )                                                                                              // lVirtual

RestArea( aAreaSX3 )
RestArea( aArea )
Return

/*/{Protheus.doc} At801UpCod
Altera a chave criada que preencherá o campo TEW_CODMV da nova movimentação.
Função utilizada na automação.
@since 		03/10/2018
@version 	P12
@param 		cSetValue, string, valor que será gravado no campo TEW_CODMV
@author	Mateus Boiani
/*/
Function At801UpCod(cSetValue)
If VALTYPE(cSetValue) == "C"
	cTEW_CODMV := cSetValue
EndIf
Return cTEW_CODMV