#INCLUDE "SFCA310.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA310
Tela de cadastro de Apontamento de Produção

@author Samantha Preima
@since 08/09/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
@param		nAcao	1=Incluir Apontamento
					2=Estornar Apontamento
					3=Iniciar Apontamento
					4=Finalizar Apontamento
					5=Abandonar Apontamento
/*/
//-------------------------------------------------------------------
Function SFCA310(maqSFC310,nAcao,xRotAuto,aCZP,aCY0,aCYW,aCZ0,aCZW)
Local aCoors := FWGetDialogSize( oMainWnd )
Local lActivate
Local lRet   := .T.
Local cNRORPO
Local cIDAT
Local cIDATQO

Private oDlgPrinc, oMarkCYY
Private _MaqSFC310

SFCValInt() // Verifica integração ligada

if xRotAuto == Nil

	lActivate := SFCA310Pa(.T.,2)
	
	If !lActivate
		Return NIL	
	EndIf     
	
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3]-2, aCoors[4]-2 Pixel // 'Apontamento de Produção'
	
	// FWmBrowse Superior 
	oMarkCYY:= FWMarkBrowse():New()
	oMarkCYY:SetAlias( 'CYY' )
	oMarkCYY:SetOwner( oDlgPrinc )
	oMarkCYY:SetSemaphore(.T.)
	oMarkCYY:SetDescription( STR0002 ) // "Apontamento a Realizar" 
	oMarkCYY:SetFieldMark( 'CYY_TPVF' )
	
	Pergunte( 'SFCA310', .F. )
	
	IF MV_PAR02 == 1
		oMarkCYY:AddLegend( ".F.", "GREEN", STR0006 ) // "Disponível para Apontamento"
		oMarkCYY:AddLegend( ".F.", "RED"  , STR0007 ) // "Indisponível para Apontamento"	
		oMarkCYY:AddLegend( ".T.", "GRAY" , STR0012 ) // 'Não Calculado'
	Else
		oMarkCYY:AddLegend( "SFCA314QRP(CYY_NRORPO, CYY_IDAT, CYY_IDATQO, 0, .T., 1, , , .F.) >= 1", "GREEN", STR0006 ) // "Disponível para Apontamento"
		oMarkCYY:AddLegend( "SFCA314QRP(CYY_NRORPO, CYY_IDAT, CYY_IDATQO, 0, .T., 1, , , .F.) <= 0", "RED"  , STR0007 ) // "Indisponível para Apontamento"
		oMarkCYY:AddLegend( ".F."                                                                  , "GRAY" , STR0012 ) // 'Não Calculado'
	Endif
	
	oMarkCYY:SetAllMark( { || oMarkCYY:AllMark() } ) 
	oMarkCYY:SetMenuDef( 'SFCA310' )
	
	SFCA310Pd()
	
	oMarkCYY:Activate()
	
	SFCA310F12()
	
	Activate MsDialog oDlgPrinc Center
Else
	lHlpDark := HelpInDark(.T.)
	
	Do Case
		Case nAcao == 1 // Incluir
			
			IF Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'}) == 0 .OR.;
			   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'}) == 0 .OR.;
			   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'}) == 0
			   
				AutoGRLog(STR0029) // 'É preciso informar a ordem de produção, operação e split para incluir um apontamento de produção. Campos CYV_NRORPO, CYV_IDAT, CYV_IDATQO'
				lMsErroAuto := .T.
			   
				lRet := .F.
			Else
		
				cNRORPO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'})][2],TamSX3('CYV_NRORPO')[1])
				cIDAT   := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'})][2],TamSX3('CYV_IDAT')[1])
				cIDATQO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'})][2],TamSX3('CYV_IDATQO')[1])
				
				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			
					aRotina := MenuDef()	
					lRet := FWMVCRotAuto(FwLoadModel('SFCA316'),"CYV",3,{{"CYVMASTER",xRotAuto},{"CZPDETAIL",aCZP},{"CY0DETAIL",aCY0},{"CYWDETAIL",aCYW},{"CZ0DETAIL",aCZ0},{"CZWDETAIL",aCZW}})
				Else
					AutoGRLog(STR0032) // 'Não existe split com a chave informada'
					lMsErroAuto := .T.
				   
					lRet := .F.
				Endif
			Endif
		Case nAcao == 2 // Estornar
			lRet := SFCA313E (xRotAuto)
		Case nAcao == 3 // Iniciar
			_MaqSFC310 := xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_CDMQ'})][2]
			
			lRet := SFCA319INI(xRotAuto)			
		Case nAcao == 4 // Finalizar
			lRet := SFCA310FIM(xRotAuto,aCZP,aCY0,aCYW,aCZ0,aCZW)
		Case nAcao == 5 // Abandonar
			lRet := SFCA310ABA(xRotAuto)
	End Case
	
	HelpInDark(lHlpDark)
Endif
 
Return lRet

//-------------------------------------------------------------------
// Legenda
//-------------------------------------------------------------------
Function SFCA310LEG()
Default lAutoMacao := .F.

	// Painel da Legenda
	oFWLegend := FWLegend():New()
	oFWLegend:Add( "", "GREEN", STR0006 ) // "Disponível para Apontamento"
	oFWLegend:Add( "", "RED"  , STR0007 ) // "Indisponível para Apontamento"
	oFWLegend:Add( "", "GRAY" , STR0012 ) // 'Não Calculado'
	oFWLegend:Activate()

	IF !lAutoMacao
		oFWLegend:View()
	ENDIF

	SFCA310F12()

Return Nil

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0014 ACTION 'SFCA319INI()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Iniciar Apontamento'
	ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.SFCA314' OPERATION 3 ACCESS 0 DISABLE MENU   // 'Incluir Apontamento'
	ADD OPTION aRotina TITLE STR0015 ACTION 'SFCA310EST()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Estornar Apontamento'
	ADD OPTION aRotina TITLE STR0026 ACTION 'SFCA310FIN()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Finalizar Apontamento'
	ADD OPTION aRotina TITLE STR0027 ACTION 'SFCA310ABP()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Abandonar Apontamento'
	ADD OPTION aRotina TITLE STR0028 ACTION 'SFCA310APO()'    OPERATION 3 ACCESS 0 DISABLE MENU   // 'Apontamentos'
	ADD OPTION aRotina TITLE STR0016 ACTION 'SFCA315D(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)'      OPERATION 3 ACCESS 0 DISABLE MENU  // 'Dividir Split'
	ADD OPTION aRotina TITLE STR0017 ACTION 'SFCA315A(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO, .T.)' OPERATION 4 ACCESS 0 DISABLE MENU  // 'Alocar Split'
	ADD OPTION aRotina TITLE STR0018 ACTION 'SFCA315U()'      OPERATION 4 ACCESS 0 DISABLE MENU    // 'Unir Split' 
	ADD OPTION aRotina TITLE STR0019 ACTION 'SFCA315DES(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)'    OPERATION 4 ACCESS 0 DISABLE MENU  // 'Desalocar Split'
	ADD OPTION aRotina TITLE STR0020 ACTION 'SFCA315AV'       OPERATION 4 ACCESS 0 DISABLE MENU   // 'Alocar Vários Splits'
	ADD OPTION aRotina TITLE STR0021 ACTION 'VIEWDEF.SFCA315' OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'SFCA310LEG()'    OPERATION 6 ACCESS 0 DISABLE MENU   // 'Legenda'
	ADD OPTION aRotina TITLE STR0022 ACTION 'SFCA310P( .T. )' OPERATION 3 ACCESS 0 DISABLE MENU   // 'Filtro Especial'
	ADD OPTION aRotina TITLE STR0023 ACTION 'SFCA318ATV()'    OPERATION 3 ACCESS 0 DISABLE MENU   // 'Dispatch List'
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.SFCA311' OPERATION 3 ACCESS 0    // 'Apontamento de Parada'
	ADD OPTION aRotina TITLE STR0025 ACTION 'VIEWDEF.SFCA312' OPERATION 3 ACCESS 0    // 'Apontamento Item Controle'

Return aRotina 
 //-------------------------------------------------------------------
Function SFCA310EST()
	SFCA316(_MaqSFC310)
	SFCA310F12()
Return .T.
//-------------------------------------------------------------------
Function SFCA310FIN()
	SFCA316(_MaqSFC310)
	SFCA310F12()
Return Nil
//-------------------------------------------------------------------
Function SFCA310ABP()
	SFCA316(_MaqSFC310)
	SFCA310F12()
Return Nil
//-------------------------------------------------------------------
Function SFCA310APO()
	SFCA316(_MaqSFC310)
	SFCA310F12()
Return Nil
//-------------------------------------------------------------------
// Zoom para seleção da máquina
//-------------------------------------------------------------------
Function SFCA310P(lExibe,nTipo)
Local 	cFiltro   := ''
Local 	aArea     := GetArea()
Local 	aAreaCYB  := CYB->( GetArea() )
Local 	lReturn   := .T. 

Default nTipo := 1
Default lAutoMacao := .F.

if !Pergunte( 'SFCA310', lExibe ) .AND. nTipo == 2
	lReturn := .F.
Else
	If Empty(AllTrim(MV_PAR01))
	    lReturn := .F.
	Elseif !Empty(AllTrim(MV_PAR01))
		if lExibe
			_MaqSFC310 := MV_PAR01
		Endif
	
		dbSelectArea('CYB')
		CYB->(dbSetOrder(1))
		CYB->(dbSeek(xFilial('CYB')+_MaqSFC310))		
		
		cFiltro := "CYY->CYY_FILIAL == '" + xFilial('CYY') + "' .AND. Val(CYY->CYY_TPSTAT) < 5 .And. "
		cFiltro += "("
		cFiltro += "	CYY->CYY_CDMQ == '" + _MaqSFC310 + "' .Or. "
		cFiltro += "	( Empty(CYY->CYY_CDMQ) .And. CYY->CYY_CDCETR == '" + CYB->CYB_CDCETR + "' )"
		cFiltro += ")"
		cFiltro += " .And. "
		cFiltro += "("
		cFiltro += "	(cTPRPOR := POSICIONE('CYQ',1,xFilial('CYQ')+CYY->CYY_NRORPO,'CYQ_TPRPOR') != '1') .Or."
		cFiltro += "	(!cTPRPOR .And. CYY->CYY_LGCERP == .T.) "
		cFiltro += ")"

		oMarkCYY:SetFilterDefault( cFiltro )
	Endif
EndIf 

IF !lAutoMacao
	IF MV_PAR02 == 2
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[1][1] := "SFCA314QRP(CYY_NRORPO, CYY_IDAT, CYY_IDATQO, 0, .T., 1, , , .F.) >= 1"
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[1][3] := 'BR_VERDE'
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[2][1] := "SFCA314QRP(CYY_NRORPO, CYY_IDAT, CYY_IDATQO, 0, .T., 1, , , .F.) <= 0"
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[3][1] := ".F."
	Else
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[1][1] := '.F.'
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[2][1] := '.F.'
		oMarkCYY:OBROWSE:ALEGENDS[1][2]:ALEGEND[3][1] := '.T.'

	Endif
ENDIF

RestArea(aAreaCYB)
RestArea(aArea)

SFCA310F12()

Return lReturn

//-------------------------------------------------------------------
// Zoom para seleção da máquina - Abrir a tela do pergunte antes de definir a janela
//-------------------------------------------------------------------
Function SFCA310Pa(lExibe,nTipo)
	Local lReturn := .T.
	Default nTipo := 1 

	if !Pergunte( 'SFCA310', lExibe ) .AND. nTipo == 2
		lReturn := .F.
	Else
		If Empty(AllTrim(MV_PAR01))
			lReturn := .F.
		Elseif !Empty(AllTrim(MV_PAR01))
			if lExibe
				_MaqSFC310 := MV_PAR01
			Endif
		Endif
	Endif

Return lReturn

//-------------------------------------------------------------------
// Zoom para seleção da máquina - Filtrar a máquina selecionada depois de definir a janela
//-------------------------------------------------------------------
Function SFCA310Pd()
	Local cFiltro
	Local lReturn	:= .T.
	Local aArea		:= GetArea()
	Local aAreaCYB	:= CYB->( GetArea() )
	Default lAutoMacao := .F.

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+_MaqSFC310))

	cIDATQO := POSICIONE('CYQ',1,xFilial('CYQ')+CYY->CYY_NRORPO,'CYQ_TPRPOR')

	cFiltro := "Val(CYY->CYY_TPSTAT) < 5 .And. "
	cFiltro += "("
	cFiltro += "	CYY->CYY_CDMQ == '" + _MaqSFC310 + "' .Or. "
	cFiltro += "	( Empty(CYY->CYY_CDMQ) .And. CYY->CYY_CDCETR == '" + CYB->CYB_CDCETR + "' )"
	cFiltro += ")"
	cFiltro += " .And. "
	cFiltro += "("
	cFiltro += "	(cTPRPOR := POSICIONE('CYQ',1,xFilial('CYQ')+CYY->CYY_NRORPO,'CYQ_TPRPOR') != '1') .Or."
	cFiltro += "	(!cTPRPOR .And. CYY->CYY_LGCERP == .T.) "
	cFiltro += ")"

	IF !lAutoMacao
		oMarkCYY:SetFilterDefault( cFiltro )
	ENDIF

	RestArea(aAreaCYB)
	RestArea(aArea)

Return lReturn

//-------------------------------------------------------------------
// Calculo de horas disponíveis para apontamento de cada split
//-------------------------------------------------------------------
Function SFCA310QTD()
	Local nHoras:= 0
	Local nQtde	:= 0

	Pergunte( 'SFCA310', .F. )

	If MV_PAR02 == 2
		nQtde := SFCA314QRP(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO, 0, .T., 1, date(), time(), .T.)

		If nQtde > 0 
			nHoras := SFCA314OPER(CYY->CYY_CDCETR,CYY->CYY_NRORPO,CYY->CYY_IDAT,nQtde,2,CYY->CYY_CDFE)[1] / 3600
		Endif
	Endif
Return nHoras

//-------------------------------------------------------------------
// finalizar apontamento
//-------------------------------------------------------------------
Function SFCA310FIM(xRotAuto,aCZP,aCY0,aCYW,aCZ0,aCZW)
Local oModel := FwLoadModel('SFCA314')
Local lRet   := .T.
Local nPos   := 0

if xRotAuto != nil
	if Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'}) == 0
	
		AutoGRLog(STR0030) // 'É preciso informar a sequencia do apontamento para finalizar o apontamento. Campo CYV_NRSQRP'
		lMsErroAuto := .T.
	
		lRet :=  .F.
	Else
		nPos := Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'})

		cNRSQRP := PadR(xRotAuto[nPos][2],TamSX3('CYV_NRSQRP')[1])
		
		dbSelectArea('CYV')
		CYV->(dbSetOrder(1))
		CYV->(dbSeek(xFilial('CYV')+cNRSQRP))
		
		dbSelectArea('CYY')
		CYY->(dbSetOrder(1))
		CYY->(dbSeek(xFilial('CYY')+CYV->CYV_NRORPO+CYV->CYV_IDAT+CYV->CYV_IDATQO))
	Endif
Endif

if lRet
	// Verificar se apontamento selecionado está iniciado
	if !CYV->CYV_LGRPEO .AND. CYV->CYV_TPSTRP == '1'
	
		// Verificar se é o mesmo logado usuário que iniciou
		if CYV->CYV_CDUSRP == RetCodUsr()
		
			if xRotAuto == nil
		
				oModel:SetOperation(4)
				oModel:Activate()
				FWExecView('','SFCA314', 4,,{ || .T. },,,,,,,  )
				oModel:DeActivate()
				
			Else			
				aRotina := MenuDef()	
				FWMVCRotAuto(FwLoadModel('SFCA316'),"CYV",4,{{"CYVMASTER",xRotAuto},{"CZPDETAIL",aCZP},{"CY0DETAIL",aCY0},{"CYWDETAIL",aCYW},{"CZ0DETAIL",aCZ0},{"CZWDETAIL",aCZW}})
			Endif
		Else
			SFCMsgErro('SFCA310_USER',"SFCA310",3) // 'Somente o usuário que iniciou o apontamento pode finalizá-lo'
			lRet := .F.
		Endif
	
	Else
		SFCMsgErro('SFCA310_SOMINI',"SFCA310",3) // 'Somente apontamentos iniciados podem ser finalizados'
		lRet := .F.
	Endif
Endif

if xRotAuto == nil
	SFCA310F12()	
Endif

Return lRet

//-------------------------------------------------------------------
// visualiza apontamento
//-------------------------------------------------------------------
Function SFCA310VIS()

IF CYV->CYV_TPSTRP == '1'
	FWExecView(STR0009,'SFCA319', 1,,{ || .T. }, /*bOk*/,,, /*bCancel*/,,,  ) // 'Visualizar Apontamento'
Else
	FWExecView(STR0009,'SFCA314', 1,,{ || .T. }, /*bOk*/,,, /*bCancel*/,,,  ) // 'Visualizar Apontamento'
Endif

SFCA310F12()

Return nil

//-------------------------------------------------------------------
// Abandonar Apontamento
//-------------------------------------------------------------------
Function SFCA310ABA(xRotAuto)
Local oModel := FwLoadModel('SFCA319')
Local lRet   := .T.

if xRotAuto != nil
	if Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'}) == 0
	
		AutoGRLog(STR0031) // 'É preciso informar a sequencia do apontamento para abandonar o apontamento. Campo CYV_NRSQRP'
		lMsErroAuto := .T.
	
		lRet := .F.		
	Endif

	cNRSQRP := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRSQRP'})][2],TamSX3('CYV_NRSQRP')[1])
	
	dbSelectArea('CYV')
	CYV->(dbSetOrder(1))
	CYV->(dbSeek(xFilial('CYV')+cNRSQRP))
Endif

if lRet
	// Verificar se apontamento selecionado está iniciado
	if !CYV->CYV_LGRPEO .AND. CYV->CYV_TPSTRP == '1'
	
		// Verificar se é o mesmo logado usuário que iniciou
		if CYV->CYV_CDUSRP == RetCodUsr()
		
			if MsgYesNo(STR0010) // Deseja abandonar apontamento de produção?
				oModel:SetOperation(4)
				oModel:Activate()
				
				oModel:SetValue('CYVMASTER','CYV_CDUSOE', CYV->CYV_CDUSRP)
				oModel:SetValue('CYVMASTER','CYV_DTEO'  , DATE())
				oModel:SetValue('CYVMASTER','CYV_LGRPEO', .T.)
				
				If oModel:VldData()
					oModel:CommitData()
				Endif
				
				oModel:DeActivate()
			Endif
		Else
			SFCMsgErro('SFCA310_ABUSER',"SFCA310",3) // 'Somente o usuário que iniciou o apontamento pode abandoná-lo'
			lRet := .F.
		Endif
	
	Else
		SFCMsgErro('SFCA310_ABAINI',"SFCA310",3) // 'Somente apontamentos iniciados podem ser abandonados'
		lRet := .F.
	Endif
Endif

if xRotAuto == nil
	SFCA310F12()
Endif

Return lRet

//-------------------------------------------------------------------
// Inclusão de F12
//-------------------------------------------------------------------
Function SFCA310F12()

// Pergunte para medição
SetKey(VK_F12,{|| Pergunte('SFCA310A',.T.)})  

Return .T.
