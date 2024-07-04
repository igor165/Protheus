#INCLUDE "SFCA315.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH' 
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA315
Tela de Splits

@author Samantha Preima
@since 08/09/2010
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA315()
Return NIL

//-------------------------------------------------------------------
// Menu para Split - Usado em SFCA310
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0030 ACTION 'SFCA315D(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)' OPERATION 3 ACCESS 0    // 'Dividir Split'
ADD OPTION aRotina TITLE STR0031 ACTION 'SFCA315A(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO, .T.)' OPERATION 4 ACCESS 0    // 'Alocar Split'   
ADD OPTION aRotina TITLE STR0038 ACTION 'SFCA315U()'      OPERATION 4 ACCESS 0    // 'Unir Split'
ADD OPTION aRotina TITLE STR0039 ACTION 'SFCA315DES(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)' OPERATION 4 ACCESS 0  // 'Desalocar Split'
ADD OPTION aRotina TITLE STR0034 ACTION 'SFCA315AV'		  OPERATION 4 ACCESS 0    // 'Alocar Vários Splits'   
ADD OPTION aRotina TITLE STR0032 ACTION 'VIEWDEF.SFCA315' OPERATION 2 ACCESS 0    // 'Visualizar'    
ADD OPTION aRotina TITLE STR0033 ACTION 'SFCA310P( .T. )' OPERATION 3 ACCESS 0    // 'Filtro Especial'

//Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
If ExistBlock("SCA315MNU")
	ExecBlock("SCA315MNU",.F.,.F.)
EndIf

Return aRotina

//-------------------------------------------------------------------
// Model Split - Acesso via SFCA310
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYY := FWFormStruct( 1, 'CYY', /*bAvalCampo*/,/*lViewUsado*/ ) // Split
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oModel         

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA315', /*bPreValidacao*/, { |oMdl| SFCA315POS( oMdl ) },/* commit */, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYYMASTER', /*cOwner*/, oStruCYY )       

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CYVDETAIL', 'CYYMASTER', oStruCYV, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CYVDETAIL', { { 'CYV_FILIAL', 'xFilial( "CYV" )' }, { 'CYV_NRORPO', 'CYY_NRORPO' }, { 'CYV_IDAT', 'CYY_IDAT' }, { 'CYV_IDATQO', 'CYY_IDATQO' } }, CYV->( IndexKey(2)) )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CYVDETAIL' ):SetOptional(.T.) 

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )    //'Split'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYYMASTER' ):SetDescription( STR0001 )  //'Split'

Return oModel

//-------------------------------------------------------------------
// View Split - Acesso via SFCA310
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYY := FWFormStruct( 2, 'CYY' ) // Pai - Split
Local oStruCYV := FWFormStruct( 2, 'CYV' ) // Filho - Apontamentos
Local oModel   := FWLoadModel( 'SFCA315' )
Local oView

// Criação de divisores
oStruCYY:AddGroup( 'Grupo01', STR0001, '', 2 ) //'Split'
oStruCYY:AddGroup( 'Grupo02', STR0051, '', 2 ) //'Quantidades'
oStruCYY:AddGroup( 'Grupo03', STR0002, '', 2 ) //'Máquina'
oStruCYY:AddGroup( 'Grupo04', STR0003, '', 2 ) //'Previsto Preparação'
oStruCYY:AddGroup( 'Grupo05', STR0004, '', 2 ) //'Previsto Operação'
oStruCYY:AddGroup( 'Grupo06', STR0005, '', 2 ) //'Real Preparação'
oStruCYY:AddGroup( 'Grupo07', STR0006, '', 2 ) //'Real Operação'
oStruCYY:AddGroup( 'Grupo08', STR0055, '', 2 ) //'Alocação'

oStruCYY:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

oStruCYY:SetProperty( 'CYY_QTAT'   , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYY:SetProperty( 'CYY_QTATRP' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYY:SetProperty( 'CYY_QTATAP' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYY:SetProperty( 'CYY_QTATRT' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYY:SetProperty( 'CYY_QTATRF' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )

oStruCYY:SetProperty( 'CYY_CDMQ'   , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYY:SetProperty( 'CYY_DSMQ'   , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYY:SetProperty( 'CYY_QTPAMQ' , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYY:SetProperty( 'CYY_QTTEMQ' , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )

oStruCYY:SetProperty( 'CYY_QTPASU' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYY:SetProperty( 'CYY_DTIMCS' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
oStruCYY:SetProperty( 'CYY_HRIMCS' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYY:SetProperty( 'CYY_DTIMTS' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
oStruCYY:SetProperty( 'CYY_HRIMTS' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' )

oStruCYY:SetProperty( 'CYY_QTPAAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_DTIMC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_HRIMC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_DTFMC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_HRFMC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_DTIMT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_HRIMT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_DTFMT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYY:SetProperty( 'CYY_HRFMT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
   
oStruCYY:SetProperty( 'CYY_QTTESU' , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYY:SetProperty( 'CYY_DTBGSU' , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYY:SetProperty( 'CYY_HRBGSU' , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYY:SetProperty( 'CYY_DTEDSU' , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )
oStruCYY:SetProperty( 'CYY_HREDSU' , MVC_VIEW_GROUP_NUMBER, 'Grupo06' )

oStruCYY:SetProperty( 'CYY_QTTEAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_DTBGAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_HRBGAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_DTEDAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_HREDAT' , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_DTDI'   , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )
oStruCYY:SetProperty( 'CYY_HRDI'   , MVC_VIEW_GROUP_NUMBER, 'Grupo07' )

oStruCYY:SetProperty( 'CYY_DTFMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_DTFMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_DTIMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_DTIMCS', MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_DTIMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_DTIMTS', MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRFMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRFMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRIMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRIMCS', MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRIMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo08' )
oStruCYY:SetProperty( 'CYY_HRIMTS', MVC_VIEW_GROUP_NUMBER, 'Grupo08' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )    

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYY', oStruCYY, 'CYYMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CYV', oStruCYV, 'CYVDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI'  , 60 ) 
oView:CreateHorizontalBox( 'FILHO', 40 ) 

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'FILHO' ) 

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0052 ) // 'Apontamentos'
                                                               
oView:CreateHorizontalBox( "INFERIOR", 100,,,"PASTAS","ABA01" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYY', 'PAI' )
oView:SetOwnerView( 'VIEW_CYV', 'FILHO' )

//Remove o campo repetido em tela
oStruCYV:RemoveField("CYV_NRORPO") 
oStruCYV:RemoveField("CYV_IDAT") 
oStruCYV:RemoveField("CYV_IDATQO") 

IF SFCIntegra() == 1
	oStruCYY:RemoveField('CYY_QTGRAC')
	oStruCYY:RemoveField('CYY_QTPAPP')
	oStruCYY:RemoveField('CYY_IDQOET')
	oStruCYY:RemoveField('CYY_QTTEPP')
	
	oStruCYY:RemoveField('CYY_HRPLSU')
	oStruCYY:RemoveField('CYY_DTPLSU')
	oStruCYY:RemoveField('CYY_DTDIPL')
	oStruCYY:RemoveField('CYY_QTTEDI')
	oStruCYY:RemoveField('CYY_DTBGPL')
	oStruCYY:RemoveField('CYY_HRBGPL')
	oStruCYY:RemoveField('CYY_DTEDPL')
	oStruCYY:RemoveField('CYY_HREDPL')
	oStruCYY:RemoveField('CYY_LGQORP')
	oStruCYY:RemoveField('CYY_LGRPOR')
	oStruCYY:RemoveField('CYY_QTFE')
Endif

oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_LGRPEO', MVC_VIEW_ORDEM , '01'  )
oView:GetViewStruct('VIEW_CYY'):SetProperty('CYY_NRORPO', MVC_VIEW_ORDEM , '02'  )
oView:GetViewStruct('VIEW_CYY'):SetProperty('CYY_IDAT'  , MVC_VIEW_ORDEM , '03'  )
oView:GetViewStruct('VIEW_CYY'):SetProperty('CYY_IDATQO', MVC_VIEW_ORDEM , '04'  )
oView:GetViewStruct('VIEW_CYY'):SetProperty('CYY_HCDIRP', MVC_VIEW_ORDEM , '05'  )

Return oView

//-------------------------------------------------------------------
// Validações de Alocação - BOIN535.I1
//-------------------------------------------------------------------
Static Function SFCA315VAL(cNRORPO,cIDAT,cIDATQO,cCDCETR,cCDMQ,cCDFE)
Local aArea    := GetArea()
Local aAreaCYY := CYY->(GetArea())
Local aAreaCY9 := CY9->(GetArea())
Local aAreaCYI := CYI->(GetArea())
Local aAreaCYB := CYB->(GetArea())
Local aAreaCYH := CYH->(GetArea())
Local aAreaCYC := CYC->(GetArea())
Local aAreaCYQ := CYQ->(GetArea())
Local aAreaCYA := CYA->(GetArea())
Local lRet     := .T.
     
dbSelectArea('CYY')
CYY->(dbSetOrder(1))
CYY->(dbGoTop())
CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

dbSelectArea('CY9')
CY9->(dbSetOrder(1))
CY9->(dbGoTop())
if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

	if CYY->CYY_TPSTAT >= '4'
		SFCMsgErro(STR0009,'SFCA315',2)	 //'Split da Operação não pode ser alterado devido ao seu estado'
		lRet := .F.
	Endif
	
	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	CYI->(dbGoTop())
	if !(CYI->(dbSeek(xFilial('CYI')+cCDCETR)))
		SFCMsgErro(STR0010 + cCDCETR + STR0011,'SFCA315',2) //'Centro de Trabalho '###' inexiste'
		lRet := .F.
	Endif
	
	IF !Empty(cCDMQ)
		dbSelectArea('CYB')
		CYB->(dbSetOrder(1))
		CYB->(dbGoTop())
		if CYB->(dbSeek(xFilial('CYB')+cCDMQ)) .AND. CYB->CYB_CDCETR != cCDCETR
			SFCMsgErro(STR0012 + cCDMQ + STR0013 + cCDCETR,'SFCA315',2) //'Máquina '###' não está relacionada ao Centro de Trabalho '
			lRet := .F.
		Endif
		
		RestArea( aAreaCYB )
	Endif
	
	if !Empty(cCDFE)	
		dbSelectArea('CYH')
		CYH->(dbSetOrder(1))
		CYH->(dbGoTop())
		if !(CYH->(dbSeek(xFilial('CYH')+'2'+cCDFE)))
			SFCMsgErro(STR0014 + cCDFE + STR0015,'SFCA315',2) //'Ferramenta '###' inexistente.'
			lRet := .F.        
		Else
			if !Empty(cCDMQ)
				dbSelectArea('CYC')
				CYC->(dbSetOrder(1))
				CYC->(dbGoTop())
				if !(CYC->(dbSeek(xFilial('CYC')+cCDMQ+'2'+cCDFE)))
					SFCMsgErro(STR0014 + cCDFE + STR0016 + cCDMQ,'SFCA315',2) //'Ferramenta '###' não está relacionada ao Máquina '
					lRet := .F.
				Endif
				
				RestArea( aAreaCYC )
			Endif
		Endif
				
		RestArea( aAreaCYH )		
	Endif
	
	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	CYQ->(dbGoTop())
	CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))
	
	if !Empty(CYI->CYI_CDARPO)
		dbSelectArea('CYA')
		CYA->(dbSetOrder(1))
		CYA->(dbGoTop())
		if CYA->(dbSeek(xFilial('CYA')+CYI->CYI_CDARPO)) .AND. CYA->CYA_CDES != CYQ->CYQ_CDES
			SFCMsgErro(STR0017,'SFCA315',2) //'Estabelecimento da área de produção difere do estabelecimento da ordem de produção.'
			lRet := .F.
		Endif
		
		RestArea( aAreaCYA )
	Endif
	
	RestArea( aAreaCYI )
	RestArea( aAreaCYQ )	
	
Endif

RestArea( aArea    )
RestArea( aAreaCYY )
RestArea( aAreaCY9 )

Return lRet

//-------------------------------------------------------------------
// Botão Alocar Vários Splits
//-------------------------------------------------------------------
Function SFCA315AV()
Local lRet		:= .T.
Local cMarca    
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYI  := CYI->(GetArea())
Local aOrdens   := {} 
Local aDadosInt := {}
Local lIntgMES  
Local nI        := 0
Local nTotal    := 0
Local nSucess   := 0
Local nError    := 0
Local oModelCYY
Local lBkpAlt   := .F.
Local lBkpInc   := .F.

Private aIntegPPI := {}
Default lAutomacao := .F.

If !lAutomacao
	cMarca := oMarkCYY:Mark()
	lIntgMES  := PCPIntgPPI()
Else
	lIntgMES := .T.
EndIf

Begin Transaction

	// Verificar quantos splits foram selecionados
	dbSelectArea('CYY')
	CYY->(dbGoTop())
	If !lAutomacao
		While !CYY->(EOF())
			If oMarkCYY:IsMark(cMarca)
			
				// Verifica se existe apontamento de produção em aberto para split
				lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)
				
				IF !lRet
					Exit
				Endif
				
				oModelCYY := FWLoadModel('SFCA315')
				oModelCYY:SetOperation(4) 
				oModelCYY:Activate()
				
				if CYY->CYY_CDMQ != _MaqSFC310
				
					DbSelectArea('CYB')
					CYB->(DbSetOrder(1))
					CYB->(DbSeek(xFilial('CYB')+_MaqSFC310))
					
					DbSelectArea('CYI')
					CYI->(DbSetOrder(1))
					CYI->(DbSeek(xFilial('CYI')+CYB->CYB_CDCETR))
				
					IF SFCA315VAL(CYY->CYY_NRORPO,CYY->CYY_IDAT,CYY->CYY_IDATQO,CYB->CYB_CDCETR,_MaqSFC310,'')
						oModelCYY:SetValue( 'CYYMASTER', 'CYY_CDMQ', _MaqSFC310)
						oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTCG', CYI->CYI_QTCG)
					Else
						lRet := .F.
					Endif
				Endif		
				
				if oModelCYY:VldData()
					oModelCYY:CommitData()
					If aScan(aOrdens, {|x| x == CYY->CYY_NRORPO}) < 1
						aAdd(aOrdens, CYY->CYY_NRORPO)
					EndIf
				Endif
				oModelCYY:DeActivate()
				
			Endif
		
			CYY->(dbSkip())
		End
	EndIf 
	
	if !lRet
		DisarmTransaction()
	Else
		If lIntgMES
			//Realiza a integração TOTVS MES
			dbSelectArea("SC2")
			SC2->(dbSetOrder(1))
			lBkpAlt := ALTERA
			lBkpInc := INCLUI
			INCLUI  := .F.
			ALTERA  := .T.
			For nI := 1 To Len(aOrdens)
				SC2->(dbSeek(xFilial("SC2")+aOrdens[nI]))
				If PCPFiltPPI("SC2", SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"SC2")
					nTotal++
					If mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., .T., .F., .F.)
						nSucess++
						aAdd(aDadosInt, {SG2->G2_PRODUTO, STR0072, STR0073}) //"OK" "Processado com sucesso"
					Else
						nError++
					EndIf
				EndIf
			Next nI
			INCLUI  := lBkpInc
			ALTERA  := lBkpAlt
			If Len(aIntegPPI) > 0
				For nI := 1 To Len(aIntegPPI)
					aAdd(aDadosInt, {aIntegPPI[nI,1], STR0071, aIntegPPI[nI,2]}) //"Erro"
				Next nI
				erroPPI(aDadosInt, nTotal, nSucess, nError)
			EndIf
		EndIf
	Endif
End Transaction

if lRet
	If !lAutomacao
		SFCA310P(.F.)
	EndIf
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aArea)

SFCA310F12()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA315A
Alocar máquina

@param  cNRORPO    Ordem de Produção
@param  cIDAT      Identificador Operação
@param  cIDATQO    Identificador Split
@param  lTela      Se exibe tela ou não
@param  cMaquina   Caso não exiba tela, deve passar a máquina

@return lRet       Se realizou processo com sucesso

@author Samantha Preima
@since 01/01/2012
@version 11
/*/
//-------------------------------------------------------------------
Function SFCA315A (cNRORPO, cIDAT, cIDATQO, lTela, cMaquina)
Local oDlg, oCombo
Local aListMaq  := {}
Local nCount    := 0
Local cQuery	:= ''
Local cTmp      := ''  
Local nNovo     := 0
Local nOriginal := 0
Local nPrevista := 0
Local aArea     := GetArea()
Local aAreaCYB  := CYB->( GetArea() )
Local aAreaCY9  := CY9->( GetArea() )
Local lRet      := .T.
Local cCDAT     := ''
Default cMaquina := ''
Default lTela    := .F.

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
        
	dbSelectArea('CYB')
	CYB->(dbSetOrder(2))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+CYY->CYY_CDCETR))
	
	While CYB->(!EOF()) .AND. CYB->CYB_CDCETR == CYY->CYY_CDCETR
	
		aadd(aListMaq, CYB->CYB_CDMQ)
		CYB->(dbSkip())
		nCount++
	End
	
	nPrevista := CYY->CYY_QTAT
	nOriginal := if(CYY->CYY_QTATAP>0,CYY->CYY_QTATAP,CYY->CYY_QTAT)
	nNovo     := nPrevista - nOriginal
	cCDAT     := Posicione('CY9',1,xFilial('CY9')+cNRORPO+cIDAT,'CY9_CDAT')
	
	IF nCount > 0
	
		IF lTela
		
			Define Font oFont Name 'Courier New' Size 0, -12
		
			Define MsDialog oDlg From 0,0 to 350,390 PIXEL TITLE STR0018 //'Alocar Operação'
			    
				tSay():New(06,10,{||STR0019},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Máquina:'
				tComboBox():New(15,10,{|u|if(PCount()>0,cMaquina:=u,cMaquina)},aListMaq,100,20,oDlg,,{||},,,,.T.,,,,,,,,,'cMaquina')
		           
				tSay():New(31,10,{||STR0048},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'ID Operação SFC'
				@ 40, 10 MSGET cIDAT SIZE 40,7 PIXEL OF oDlg WHEN .F.
				
				tSay():New(31,100,{||STR0020},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Operação'
				@ 40, 100 MSGET cCDAT SIZE 40,7 PIXEL OF oDlg WHEN .F.
				
				tSay():New(56,10,{||STR0021},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Split'
				@ 65, 10 MSGET cIDATQO SIZE 40,7 PIXEL OF oDlg WHEN .F. 
				 
				tSay():New(81,10,{||STR0022},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Prevista'
				@ 90, 10 MSGET nPrevista SIZE 93,7 PIXEL OF oDlg WHEN .F. PICTURE "@E 999,999,999.9999"
				
				tSay():New(106,10,{||STR0023},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Orig'
				@ 115, 10 MSGET nOriginal SIZE 93,7 PIXEL OF oDlg WHEN .T. VALID if(nOriginal>nPrevista, nPrevista:=CYY->CYY_QTAT,nNovo:=nPrevista-nOriginal) PICTURE "@E 999,999,999.9999"
				
				tSay():New(131,10,{||STR0024},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Novo'
				@ 140, 10 MSGET nNovo SIZE 93,7 PIXEL OF oDlg WHEN .F. PICTURE "@E 999,999,999.9999"
			
				TButton():New(160,100,STR0025      ,oDlg,{|| if(SFCA315OK(cNRORPO, cIDAT, cIDATQO, cMaquina, nOriginal, nNovo, 1, .T.),oDlg:End(),lRet := .F.)},40,10,,,,.T.) //'Ok'
				TButton():New(160,145,STR0026,oDlg,{|| lRet := .F., oDlg:End() },40,10,,,,.T.) //'Cancelar'
				
			Activate MsDialog oDlg Centered
		Else
			SFCA315OK(cNRORPO, cIDAT, cIDATQO, cMaquina, nOriginal, nNovo, 1, .F.)
		Endif	    
	Else
		SFCMsgErro(STR0027 + CYY->CYY_CDCETR,'SFCA315',2) //'Não existe Máquina para o Centro de Trabalho '
		lRet := .F.
	Endif
Endif

RestArea( aArea )
RestArea( aAreaCYB )
RestArea( aAreaCY9 )

IF lRet .AND. lTela 
	SFCA310P(.F.)
Endif

SFCA310F12()

Return lRet

//-------------------------------------------------------------------
// Botão Dividir
//-------------------------------------------------------------------
Function SFCA315D(cNRORPO, cIDAT, cIDATQO, lTela, nOrigInt)
Local oDlg
Local cCDAT       := ''
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaCYY    := CYY->(GetArea())
Private nNovo     := 0
Private nOriginal := 0
Private nPrevista := 0
Default cNRORPO   := CYY->CYY_NRORPO
Default cIDAT     := CYY->CYY_IDAT
Default cIDATQO   := CYY->CYY_IDATQO
Default lTela     := .T.

cCDAT := Posicione('CY9',1,xFilial('CY9')+cNRORPO+cIDAT,'CY9_CDAT')

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	IF lTela
	
		nPrevista := CYY->CYY_QTAT
		nOriginal := if(CYY->CYY_QTATAP>0,CYY->CYY_QTATAP,CYY->CYY_QTAT)
		nNovo     := nPrevista - nOriginal
		
		Define Font oFont Name 'Courier New' Size 0, -12
		
		Define MsDialog oDlg From 0,0 to 300,390 PIXEL TITLE STR0028 //'Dividir Operação'
		           
			tSay():New(06,10,{||STR0048},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) // ID Operação SFC
			@ 15, 10 MSGET cIDAT SIZE 40,7 PIXEL OF oDlg WHEN .F.
			
			tSay():New(06,100,{||STR0020},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Operação'
			@ 15, 100 MSGET cCDAT SIZE 40,7 PIXEL OF oDlg WHEN .F.
			
			tSay():New(31,10,{||STR0021},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Split'
			@ 40, 10 MSGET cIDATQO SIZE 40,7 PIXEL OF oDlg WHEN .F.
			
			tSay():New(56,10,{||STR0022},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Prevista'
			@ 65, 10 MSGET nPrevista SIZE 93,7 PIXEL OF oDlg WHEN .F. PICTURE "@E 999,999,999.9999"
			
			tSay():New(81,10,{||STR0023},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Orig'
			@ 90, 10 MSGET nOriginal SIZE 93,7 PIXEL OF oDlg WHEN .T. VALID SFCA315VQT() PICTURE "@E 999,999,999.9999"
			
			tSay():New(106,10,{||STR0024},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) //'Quantidade Novo'
			@ 115, 10 MSGET nNovo SIZE 93,7 PIXEL OF oDlg WHEN .F. PICTURE "@E 999,999,999.9999"
		
			TButton():New(135,100,STR0025,oDlg,{|| if(SFCA315OK(cNRORPO, cIDAT, cIDATQO, '',nOriginal,nNovo,2,.T.),oDlg:End(), lRet := .F.)},40,10,,,,.T.) //'Ok'
			TButton():New(135,145,STR0026,oDlg,{|| lRet := .F., oDlg:End() },40,10,,,,.T.) //'Cancelar'
			
		Activate MsDialog oDlg Centered
		
		IF lRet .AND. IsInCallStack('SFCA310')
			SFCA310P(.F.)
		Endif
	Else
		nPrevista := CYY->CYY_QTAT
		nOriginal := nOrigInt
		nNovo     := nPrevista - nOriginal
	
		lRet := SFCA315OK(cNRORPO, cIDAT, cIDATQO, '', nOriginal, nNovo, 2, .F.)
	Endif
Endif

RestArea(aArea)
RestArea(aAreaCYY)

SFCA310F12()

Return lRet

//-------------------------------------------------------------------
// Botão Unir
//-------------------------------------------------------------------
Function SFCA315U ()
Local lRet     := .T.
Local cMarca   
Local nQtd     := 0
Local aRetorno := {}
Local aErro    := {}
Local oModelCYY
Local cNRORPO  // Ordem Split 1
Local cNRORPO2 // Ordem Split 2
Local cIDAT    // Operação Split 1
Local cIDAT2   // Operação Split 2
Local cIDATQO  // Split 1
Local cIDATQO2 // Split 2
Local cTPSTAT  // Estado Split 1
Local cTPSTAT2 // Estado Split 2
Local nQTAT    // Qtd Prevista Split 1
Local nQTAT2   // Qtd Prevista Split 2
Local nNovaQTD
Local lIntgMES := PCPIntgPPI()
Local aAreaC2  := {}
Local lBkpInc  := .F.
Local lBkpAlt  := .F.
Default lAutomacao := .F.

If !lAutomacao
	cMarca   := oMarkCYY:Mark()
EndIf

dbSelectArea('CYY')
CYY->(dbGoTop())
If !lAutomacao
	While !CYY->(EOF())
		If oMarkCYY:IsMark(cMarca)
			nQtd++
			
			if nQtd > 2
				Exit
			Endif
			
			// Verifica se existe apontamento de produção em aberto para split
			lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)
			
			IF !lRet
				Exit
			Endif
			
			IF nQtd == 1
				cNRORPO := CYY->CYY_NRORPO
				cIDAT   := CYY->CYY_IDAT
				cIDATQO := CYY->CYY_IDATQO
				cTPSTAT := CYY->CYY_TPSTAT
				nQTAT   := CYY->CYY_QTAT
			ElseIf nQtd == 2
				cNRORPO2 := CYY->CYY_NRORPO
				cIDAT2   := CYY->CYY_IDAT
				cIDATQO2 := CYY->CYY_IDATQO
				cTPSTAT2 := CYY->CYY_TPSTAT
				nQTAT2   := CYY->CYY_QTAT
			Endif
		Endif
		
		CYY->(dbSkip())
	End
EndIf

if lRet

	if nQtd != 2
		SFCMsgErro(STR0040,'SFCA315',2) // 'Devem ser selecionados 2 registros da mesma Ordem de Produção e mesma Operação.'
		lRet := .F.
	Endif
	
	IF lRet .AND.;
	   (cNRORPO != cNRORPO2 .OR.;
	    cIDAT   != cIDAT2)
		SFCMsgErro(STR0041,'SFCA315',2) // 'Somente podem ser unidos splits da mesma ordem e da mesma operação'
		lRet := .F.	
	Endif
	
	if lRet .AND.;
	   (cTPSTAT  == '5' .OR.;
	    cTPSTAT2 == '5')
		SFCMsgErro(STR0042,'SFCA315',2) // 'Splits não podem estar finalizados'
		lRet := .F.	
	Endif
	
	if lRet .AND.;
	    cTPSTAT  == '4' .AND.;
	    cTPSTAT2 == '4'
		SFCMsgErro(STR0043,'SFCA315',2) // 'Somente um dos Splits pode estar iniciado'
		lRet := .F.	
	Endif
	
	if lRet
		Begin Transaction
	
			dbSelectArea('CYY')
			CYY->(dbSetOrder(1))
			
			IF cTPSTAT2 == '4' 
				CYY->(dbSeek(xFilial('CYY')+cNRORPO2+cIDAT2+cIDATQO2))
			Else
				CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			Endif
			
			dbSelectArea('CYI')
			CYI->(dbSetOrder(1))
			CYI->(dbSeek(xFilial('CYI')+CYY->CYY_CDCETR))
			
			nNovaQTD := CYY->CYY_QTAT + IF(cTPSTAT2=='4',nQTAT,nQTAT2)
			
			oModelCYY := FWLoadModel('SFCA315')
			oModelCYY:SetOperation(4) 
			oModelCYY:Activate()
			
			aRetorno := SFCA314OPER ( CYY->CYY_CDCETR, CYY->CYY_NRORPO, CYY->CYY_IDAT, nNovaQTD, 2, CYY->CYY_CDFE )
			
			oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTAT'  , nNovaQTD)
			oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTPAMQ', if(CYI->CYI_TPPC == '4',0,aRetorno[1]))
			oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTPAOE', if(CYI->CYI_TPPC != '4',0,aRetorno[1]))
			oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTVMAT', aRetorno[2])
			oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTPAAT', aRetorno[1])
			
			if oModelCYY:VldData()
				oModelCYY:CommitData()
			Else
				aErro := oModelCYY:GetErrorMessage()
				SFCMsgErro(aErro[6], "SFCA315")
				lRet := .F.
			Endif
			oModelCYY:DeActivate()
			
			if !lRet
				DisarmTransaction()
			Endif
			
			IF cTPSTAT2 == '4' 
				CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			Else
				CYY->(dbSeek(xFilial('CYY')+cNRORPO2+cIDAT2+cIDATQO2))			
			Endif
			
			oModelCYY := FWLoadModel('SFCA315')
			oModelCYY:SetOperation(5) 
			oModelCYY:Activate()
			
			if oModelCYY:VldData()
				oModelCYY:CommitData()
			Else
				aErro := oModelCYY:GetErrorMessage()
				SFCMsgErro(aErro[6], "SFCA315")
				lRet := .F.
			Endif
			oModelCYY:DeActivate()
			
			If lRet .And. lIntgMES
				aAreaC2 := SC2->(GetArea())
				dbSelectArea("SC2")
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+cNRORPO))
				lBkpInc := INCLUI
				lBkpAlt := ALTERA
				INCLUI := .F.
				ALTERA := .T.
				lRet := mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., .F., .F., .T.)
				INCLUI := lBkpInc
				ALTERA := lBkpAlt
				SC2->(RestArea(aAreaC2))
				If !lRet
					DisarmTransaction()
				EndIf
			EndIf
			
			if !lRet
				DisarmTransaction()
			Else
				SFCA310P(.F.)
			Endif
		End Transaction	
	Endif
Endif

SFCA310F12()

Return lRet

//-------------------------------------------------------------------
// Botão Desalocar
//-------------------------------------------------------------------
Function SFCA315DES (cNRORPO, cIDAT, cIDATQO)
Local oModelCYY
Local lRet     := .T.
Local lIntgMES := PCPIntgPPI()
Local aAreaC2  := {}
Local lBkpInc  := .F.
Local lBkpAlt  := .F.
Default lAutomacao := .F.

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))	

	// Verifica se existe apontamento de prodção em aberto para split
	lRet := SFCApAbeSp(cNRORPO,cIDAT,cIDATQO)
	
	if lRet

		if CYY->CYY_TPSTAT != '3'
			SFCMsgErro(STR0044,'SFCA315',2) // 'Somente Splits não iniciados (Estado Liberado) podem ser desalocados.'
			lRet := .F.
		Else
			
			BeginTran()
			oModelCYY := FWLoadModel('SFCA315')
			oModelCYY:SetOperation(4) 
			oModelCYY:Activate()
			
			oModelCYY:ClearField( 'CYYMASTER', 'CYY_CDMQ')
			oModelCYY:ClearField( 'CYYMASTER', 'CYY_QTCG')
			
			if oModelCYY:VldData()
				oModelCYY:CommitData()
				If lIntgMES
					aAreaC2 := SC2->(GetArea())
					dbSelectArea("SC2")
					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2")+cNRORPO))
					lBkpInc := INCLUI
					lBkpAlt := ALTERA
					INCLUI := .F.
					ALTERA := .T.
					lRet := mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., .F., .F., .T.)
					INCLUI := lBkpInc
					ALTERA := lBkpAlt
					SC2->(RestArea(aAreaC2))
					If !lRet
						DisarmTransaction()
					EndIf
				EndIf
			Endif
			oModelCYY:DeActivate()	
			EndTran()
		Endif
	Endif
Endif

if lRet
	If !lAutomacao
		SFCA310P(.F.)
	EndIf
Endif

SFCA310F12()

Return lRet

//-------------------------------------------------------------------
// SFCA315VQT - Validações de quantidade
//-------------------------------------------------------------------
Function SFCA315VQT()

IF nOriginal > nPrevista .OR. nOriginal < 0
	nOriginal := CYY->CYY_QTAT
	nNovo     := 0
Else
	nNovo := nPrevista - nOriginal
Endif

Return .T.

//-------------------------------------------------------------------
// Botão ok de 'Alocar' e 'Dividir' 
// Alteração Split - boin535.i1 
// 1 - alocar, 2 - dividir
//-------------------------------------------------------------------
Function SFCA315OK (cNRORPO, cIDAT, cIDATQO, cMaquina, nOriginal, nNovo, nTipo, lTela)
Local aArea    := GetArea()
Local aAreaCYY := CYY->( GetArea() )
Local aAreaCYB := CYB->( GetArea() )
Local aAreaCYI := CYI->( GetArea() )
Local aAreaC2  := {}
Local aRetorno := {}
Local lRet     := .T.
Local aErro    := {}
Local lDividir := .F.
Local cCDCETR  := ''
Local aSplit   := {}
Local oTabela
Local aTab     := SFCA315TAB()
Local lIntgMES := PCPIntgPPI()
Local lBkpInc  := .F.
Local lBkpAlt  := .F.

oTabela := SFCCriFWTa(aTab)
cAlias  := oTabela:GetAlias()

Begin Transaction

	DbSelectArea('CYY')
	CYY->(DbSetOrder(01))
	CYY->(DbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
	
	cCDCETR := CYY->CYY_CDCETR
	
	// Verifica se existe apontamento de produção em aberto para split
	lRet := SFCApAbeSp(cNRORPO, cIDAT, cIDATQO)
	
	if lRet
	
		DbSelectArea('CYB')
		CYB->(DbSetOrder(01))
		CYB->(DbSeek(xFilial('CYB')+cMaquina))
		
		DbSelectArea('CYI')
		CYI->(DbSetOrder(01))
		CYI->(DbSeek(xFilial('CYI')+CYB->CYB_CDCETR))
		
		if nTipo == 1 // Alocar
			IF SFCA315VAL(cNRORPO,cIDAT,cIDATQO,CYB->CYB_CDCETR,cMaquina,'')
			
				if nNovo > 0 // Entao tb vai dividir 
					lDividir := .T.				
				Else // Apenas alocar
					oModelCYY := FWLoadModel( 'SFCA315' )
					oModelCYY:SetOperation( 4 )
					oModelCYY:Activate()
					
					oModelCYY:SetValue( 'CYYMASTER', 'CYY_CDMQ', cMaquina)
					oModelCYY:SetValue( 'CYYMASTER', 'CYY_QTCG', CYI->CYI_QTCG)
					
					oModelCYY:VldData()
					oModelCYY:CommitData()
					oModelCYY:DeActivate()
				Endif
			Else
				lRet := .F.
			Endif
		Else // Dividir
			lDividir := .T.
		Endif
		
		if lDividir			
			if nNovo == 0
				lRet := .F.
			Else
				if lRet
					if CYY->CYY_TPSTAT == '5'
						SFCMsgErro(STR0008,'SFCA315',2) //'Split não pode estar finalizado'
						lRet := .F.
					Endif
				
					// Verificar se a quantidade original não é menor que a quantidade aprovada apontada para o Split
					IF CYY->CYY_QTATAP == CYY->CYY_QTAT
						SFCMsgErro(STR0036,'SFCA315',2) // Split já foi totalmente apontado e não pode ser dividido
						lRet := .F.
					Else
						if CYY->CYY_QTATAP > nOriginal
							SFCMsgErro(STR0037 + ALLTRIM(STR(CYY->CYY_QTATAP)),'SFCA315',2) // Split já foi apontado. A quantidade original deve ser maior ou igual a 
							lRet := .F.
						Endif
					Endif
				Endif
			Endif
			
			if lRet
				IF nTipo == 2 .AND. !lTela
					// Altera Split Original
					RecLock("CYY",.F.)
					
					aRetorno := SFCA314OPER ( cCDCETR, cNRORPO, cIDAT, nOriginal, 2, CYY->CYY_CDFE )
					
					CYY->CYY_QTPAMQ := if(CYI->CYI_TPPC == '4',0,aRetorno[1])
					CYY->CYY_QTPAOE := if(CYI->CYI_TPPC != '4',0,aRetorno[1])
					CYY->CYY_QTVMAT := aRetorno[2]
					CYY->CYY_QTPAAT := aRetorno[1]
					CYY->CYY_QTAT   := nOriginal				
				
					MsUnlock()
					
					SFCA315GER(.T., cNRORPO, cIDAT, nNovo,,aTab[1],cAlias)
					
					RecLock('CYY',.T.)
					
					CYY->CYY_FILIAL := xFilial('CYY')
					CYY->CYY_NRORPO := (cAlias)->CYY_NRORPO
					CYY->CYY_IDAT   := (cAlias)->CYY_IDAT
					CYY->CYY_IDATQO := (cAlias)->CYY_IDATQO
					CYY->CYY_CDAC   := (cAlias)->CYY_CDAC
					CYY->CYY_TPSTAT := (cAlias)->CYY_TPSTAT
					CYY->CYY_QTCG   := (cAlias)->CYY_QTCG
					CYY->CYY_CDMQ   := (cAlias)->CYY_CDMQ
					CYY->CYY_QTFE   := (cAlias)->CYY_QTFE
					CYY->CYY_QTGRAC := (cAlias)->CYY_QTGRAC
					CYY->CYY_QTAT   := (cAlias)->CYY_QTAT
					CYY->CYY_QTPASU := (cAlias)->CYY_QTPASU
					CYY->CYY_LGQORP := (cAlias)->CYY_LGQORP
					CYY->CYY_LGQOED := (cAlias)->CYY_LGQOED
					CYY->CYY_LGQO   := (cAlias)->CYY_LGQO
					CYY->CYY_LGRPOR := (cAlias)->CYY_LGRPOR
					CYY->CYY_DTDIPL := (cAlias)->CYY_DTDIPL
					CYY->CYY_QTTEDI := (cAlias)->CYY_QTTEDI
					CYY->CYY_CDCETR := (cAlias)->CYY_CDCETR
					CYY->CYY_DTBGPL := (cAlias)->CYY_DTBGPL
					CYY->CYY_HRBGPL := (cAlias)->CYY_HRBGPL
					CYY->CYY_DTEDPL := (cAlias)->CYY_DTEDPL
					CYY->CYY_HREDPL := (cAlias)->CYY_HREDPL					
					CYY->CYY_QTPAMQ := (cAlias)->CYY_QTPAMQ
					CYY->CYY_QTPAOE := (cAlias)->CYY_QTPAOE
					CYY->CYY_QTVMAT := (cAlias)->CYY_QTVMAT
					CYY->CYY_QTPAAT := (cAlias)->CYY_QTPAAT
					
					MsUnlock()
				Else
					IF !lTela .OR. (lTela .AND. MsgYesNo(STR0053 + ALLTRIM(STR(nOriginal)) + STR0054 + ALLTRIM(STR(nNovo)))) // 'Confirma divisão do Split? Quantidade Split Original: ' ##
					
						// Altera Split Original
						RecLock("CYY",.F.)
						
						if nTipo == 1
							CYY->CYY_CDMQ := cMaquina
						Endif
					
						aRetorno := SFCA314OPER ( cCDCETR, cNRORPO, cIDAT, nOriginal, 2, CYY->CYY_CDFE )
						
						CYY->CYY_QTPAMQ := if(CYI->CYI_TPPC == '4',0,aRetorno[1])
						CYY->CYY_QTPAOE := if(CYI->CYI_TPPC != '4',0,aRetorno[1])
						CYY->CYY_QTVMAT := aRetorno[2]
						CYY->CYY_QTPAAT := aRetorno[1]
						CYY->CYY_QTAT   := nOriginal
					
						MsUnlock()
						
						SFCA315GER(.T., cNRORPO, cIDAT, nNovo,,aTab[1],cAlias)
						
						// Cria novo Split
						oModelCYY := FWLoadModel( 'SFCA315' )
						oModelCYY:SetOperation( 3 )
						oModelCYY:Activate()
						
						oModelCYY:SetValue('CYYMASTER', 'CYY_NRORPO', (cAlias)->CYY_NRORPO)
						oModelCYY:SetValue('CYYMASTER', 'CYY_IDAT',   (cAlias)->CYY_IDAT  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_IDATQO', (cAlias)->CYY_IDATQO)
						oModelCYY:SetValue('CYYMASTER', 'CYY_CDAC'  , (cAlias)->CYY_CDAC  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_TPSTAT', (cAlias)->CYY_TPSTAT)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTFE',   (cAlias)->CYY_QTFE  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTGRAC', (cAlias)->CYY_QTGRAC)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTAT',   (cAlias)->CYY_QTAT  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTPASU', (cAlias)->CYY_QTPASU)
						oModelCYY:SetValue('CYYMASTER', 'CYY_LGQORP', (cAlias)->CYY_LGQORP)
						oModelCYY:SetValue('CYYMASTER', 'CYY_LGQOED', (cAlias)->CYY_LGQOED)
						oModelCYY:SetValue('CYYMASTER', 'CYY_LGQO',   (cAlias)->CYY_LGQO  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_LGRPOR', (cAlias)->CYY_LGRPOR)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTCG',   (cAlias)->CYY_QTCG  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_DTDIPL', (cAlias)->CYY_DTDIPL)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTTEDI', (cAlias)->CYY_QTTEDI)
						oModelCYY:SetValue('CYYMASTER', 'CYY_CDCETR', (cAlias)->CYY_CDCETR)
						oModelCYY:SetValue('CYYMASTER', 'CYY_CDMQ'  , (cAlias)->CYY_CDMQ  )
						oModelCYY:SetValue('CYYMASTER', 'CYY_DTBGPL', (cAlias)->CYY_DTBGPL)
						oModelCYY:SetValue('CYYMASTER', 'CYY_HRBGPL', (cAlias)->CYY_HRBGPL)
						oModelCYY:SetValue('CYYMASTER', 'CYY_DTEDPL', (cAlias)->CYY_DTEDPL)
						oModelCYY:SetValue('CYYMASTER', 'CYY_HREDPL', (cAlias)->CYY_HREDPL)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTPAMQ', (cAlias)->CYY_QTPAMQ) 
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTPAOE', (cAlias)->CYY_QTPAOE)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTVMAT', (cAlias)->CYY_QTVMAT)
						oModelCYY:SetValue('CYYMASTER', 'CYY_QTPAAT', (cAlias)->CYY_QTPAAT)
						oModelCYY:SetValue('CYYMASTER', 'CYY_LGCERP', (cAlias)->CYY_LGCERP)
						oModelCYY:ClearField('CYYMASTER', 'CYY_CDFE')
						oModelCYY:ClearField('CYYMASTER', 'CYY_QTATAP')
						oModelCYY:ClearField('CYYMASTER', 'CYY_QTATRF')
						oModelCYY:ClearField('CYYMASTER', 'CYY_QTATRT')
						oModelCYY:ClearField('CYYMASTER', 'CYY_QTATRP')
						oModelCYY:ClearField('CYYMASTER', 'CYY_HRPLSU')
						oModelCYY:ClearField('CYYMASTER', 'CYY_IDQOET')
									
						if oModelCYY:VldData()
							oModelCYY:CommitData()
						Else
							aErro := oModelCYY:GetErrorMessage()
							lRet  := .F.
						Endif
						oModelCYY:DeActivate()
					Else
						lRet := .F.
					Endif
				Endif
			Endif
		Endif
	Endif
	
	if !lRet
		DisarmTransaction()
	Else
		//Integração TOTVS MES
		If lIntgMES
			aAreaC2 := SC2->(GetArea())
			dbSelectArea("SC2")
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+cNRORPO))
			lBkpInc := INCLUI
			lBkpAlt := ALTERA
			INCLUI := .F.
			ALTERA := .T.
			lRet := mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., !lTela, .F., .T.)
			INCLUI := lBkpInc
			ALTERA := lBkpAlt
			SC2->(RestArea(aAreaC2))
			If !lRet
				DisarmTransaction()
			EndIf
		EndIf
	Endif
	
End Transaction

oTabela:Delete()

RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aArea)

Return lRet 

//-------------------------------------------------------------------
// Função para preparação estrutura tabela
//-------------------------------------------------------------------
Function SFCA315TAB()
Local aTab := {}
Local cChave
Local aChave := {}
Local StructCYY := FWFormStruct(3,'CYY')
Local nI := 0
Local nPos := 0

For nI := 1 to Len(StructCYY[3])

	nPos := Ascan(StructCYY[1],{|x|Alltrim(x[3]) == StructCYY[3][nI][1]})

	if StructCYY[3][nI][16] == .F.
		aAdd( aTab, { StructCYY[3][nI][1], StructCYY[1][nPos][4], StructCYY[1][nPos][5], StructCYY[1][nPos][6], StructCYY[1][nPos][1], .T., StructCYY[3][nI][7] } )
	Endif

Next nI

dbSelectArea( 'CYY' )
cChave := Substr( IndexKey(1), 12 )
aChave := STRTOKARR(cChave,"+")

Return {aTab, aChave}

//-------------------------------------------------------------------
// Função para geração de dados de split
// lUsaSplit - Quando sim, cria um registro de split com base em 
//             outro split já existente. (Divisão de Split)
// cNRORPO   - Número da ordem de produção
// cIDAT     - Identificador da operação
// nQuant    - Quantidade a ser criada o split
// oModelCY9 - Quando lUsaSplit igual a não, se o model for válido,
//             utiliza as informações do model da CY9. Utiliza-se 
//             quando ainda não existe CY9 gravado. (Criação ordem)
//-------------------------------------------------------------------
Function SFCA315GER(lUsaSplit, cNRORPO, cIDAT, nQuant, oModelCY9, aTab, cAlias, oModelCYY)
Local aRetorno := {}
Local nI       := 0
Local cArquivo

// Cria novo split com base em um split (divisão)
if lUsaSplit
	RecLock(cAlias, .T.)

	For nI := 1 to Len(aTab)
		(cAlias)->&(aTab[nI][1]) := CYY->&(aTab[nI][1])
	Next
	(cAlias)->CYY_IDATQO := ALLTRIM(SFCA315NR(xFilial('CYY'),cNRORPO,cIDAT))
	
	aRetorno := SFCA314OPER( CYY->CYY_CDCETR, cNRORPO, cIDAT, nQuant, 2, CYY->CYY_CDFE )
	
	(cAlias)->CYY_QTAT   := nQuant					
	(cAlias)->CYY_QTPAMQ := if(CYI->CYI_TPPC == '4',0,aRetorno[1])
	(cAlias)->CYY_QTPAOE := if(CYI->CYI_TPPC != '4',0,aRetorno[1])
	(cAlias)->CYY_QTVMAT := aRetorno[2]
	(cAlias)->CYY_QTPAAT := aRetorno[1]
	(cAlias)->CYY_TPSTAT := '3'
	
	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	CYI->(dbSeek(xFilial('CYI')+CYY->CYY_CDCETR))
	
	(cAlias)->CYY_QTCG := CYI->CYI_QTCG
	(cAlias)->CYY_CDMQ := SFCA100MAQ(CYI->CYI_CDCETR)

	If CYI->CYI_LGCERP
		(cAlias)->CYY_LGCERP := .T.
	Else
		(cAlias)->CYY_LGCERP := .F.
	EndIf
	
	MsUnLock()
Else
	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))
        
		// Quando criado registro com base na operação. (Recriação de Split)
   		IF Empty(oModelCY9)
		
			dbSelectArea('CY9')
			CY9->(dbSetOrder(1))
			if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))
			
				dbSelectArea('CYI')
				CYI->(dbSetOrder(1))
				CYI->(dbSeek(xFilial('CYI')+CY9->CY9_CDCETR))
				
				RecLock(cAlias, .T.)
			
				(cAlias)->CYY_NRORPO := cNRORPO
				(cAlias)->CYY_IDAT   := cIDAT
				(cAlias)->CYY_IDATQO := ALLTRIM(SFCA315NR(xFilial('CYY'),cNRORPO,cIDAT))
				(cAlias)->CYY_CDCETR := CY9->CY9_CDCETR
				(cAlias)->CYY_CDAC   := CY9->CY9_CDAC
				(cAlias)->CYY_TPSTAT := '3'
				(cAlias)->CYY_QTAT   := CY9->CY9_QTAT
				(cAlias)->CYY_DTBGPL := CYQ->CYQ_DTBGOR
				(cAlias)->CYY_HRBGPL := '00:00:00'
				(cAlias)->CYY_DTEDPL := CYQ->CYQ_DTEDOR
				(cAlias)->CYY_HREDPL := '23:59:59'
				(cAlias)->CYY_QTPASU := CY9->CY9_QTTESU * 3600
				(cAlias)->CYY_QTPAAT := CY9->CY9_QTTEMQ * 3600
				(cAlias)->CYY_QTPAMQ := CY9->CY9_QTTEMQ * 3600
				(cAlias)->CYY_QTPAOE := CY9->CY9_QTTERC * 3600
				(cAlias)->CYY_DTBGPL := CYQ->CYQ_DTBGOR
				(cAlias)->CYY_HRBGPL := '00:00:00'
				(cAlias)->CYY_DTEDPL := CYQ->CYQ_DTEDOR
				(cAlias)->CYY_HREDPL := '23:59:59'
				(cAlias)->CYY_CDMQ   := SFCA100MAQ(CYI->CYI_CDCETR)
				(cAlias)->CYY_QTCG   := CYI->CYI_QTCG

				If CYI->CYI_LGCERP
					(cAlias)->CYY_LGCERP := .T.
				Else
					(cAlias)->CYY_LGCERP := .F.
				EndIf
				
				MsUnLock()
			Endif
		Else // Quando não exite registro de operação ainda. (Criação Ordem)
			dbSelectArea('CYI')
			CYI->(dbSetOrder(1))
			CYI->(dbSeek(xFilial('CYI')+oModelCY9:GetValue('CY9_CDCETR')))
			
			oModelCYY:SetValue('CYYMASTER','CYY_NRORPO',cNRORPO)
			oModelCYY:SetValue('CYYMASTER','CYY_IDAT'  ,cIDAT)
			oModelCYY:SetValue('CYYMASTER','CYY_IDATQO',ALLTRIM(SFCA315NR(xFilial('CYY'),cNRORPO,cIDAT)))
			oModelCYY:SetValue('CYYMASTER','CYY_CDCETR',CYI->CYI_CDCETR)
			oModelCYY:SetValue('CYYMASTER','CYY_CDAC'  ,oModelCY9:GetValue('CY9_CDAC'))
			oModelCYY:SetValue('CYYMASTER','CYY_TPSTAT','3')
			oModelCYY:SetValue('CYYMASTER','CYY_QTAT'  ,oModelCY9:GetValue('CY9_QTAT'))
			oModelCYY:SetValue('CYYMASTER','CYY_DTBGPL',CYQ->CYQ_DTBGOR)
			oModelCYY:SetValue('CYYMASTER','CYY_HRBGPL','00:00:00')
			oModelCYY:SetValue('CYYMASTER','CYY_DTEDPL',CYQ->CYQ_DTEDOR)
			oModelCYY:SetValue('CYYMASTER','CYY_HREDPL','23:59:59')
			oModelCYY:SetValue('CYYMASTER','CYY_QTPASU',oModelCY9:GetValue('CY9_QTTESU') * 3600)
			oModelCYY:SetValue('CYYMASTER','CYY_QTPAAT',oModelCY9:GetValue('CY9_QTTEMQ') * 3600)
			oModelCYY:SetValue('CYYMASTER','CYY_QTPAMQ',oModelCY9:GetValue('CY9_QTTEMQ') * 3600)
			oModelCYY:SetValue('CYYMASTER','CYY_QTPAOE',oModelCY9:GetValue('CY9_QTTERC') * 3600)
			oModelCYY:SetValue('CYYMASTER','CYY_CDMQ'  ,SFCA100MAQ(CYI->CYI_CDCETR))
			oModelCYY:SetValue('CYYMASTER','CYY_QTCG'  ,CYI->CYI_QTCG)
			If CYI->CYI_LGCERP
				oModelCYY:SetValue('CYYMASTER','CYY_LGCERP',.T.)				
			Else
				oModelCYY:SetValue('CYYMASTER','CYY_LGCERP',.F.)
			EndIf
		Endif
	Endif
Endif	

Return

//-------------------------------------------------------------------
// Zoom para seleção da máquina
//-------------------------------------------------------------------
Function SFCA315P( lExibe)
	Pergunte( 'SFCA310', lExibe )
Return NIL

//-------------------------------------------------------------------
// Busca de sequencia para novo split
//-------------------------------------------------------------------
Function SFCA315NR (cFILIAL,cNRORPO,cIDAT)
	Local aArea    := GetArea()
	Local aAreaCYY := CYY->(GetArea())
	Local nIDATQO  := 0

	dbSelectArea("CYY")
	CYY->(dbSetOrder(1))
	If CYY->(dbSeek(cFILIAL+cNRORPO+cIDAT))
		While !CYY->(Eof()) .And. CYY->(CYY_FILIAL+CYY_NRORPO+CYY_IDAT) == cFILIAL+cNRORPO+cIDAT
			If Val(CYY->CYY_IDATQO) > nIDATQO
				nIDATQO := Val(CYY->CYY_IDATQO)
			EndIF
			CYY->(dbSkip())
		End
	EndIf 
	
	RestArea( aArea )
	RestArea( aAreaCYY )
	
Return StrZero(nIDATQO+1,TamSX3("CYY_IDATQO")[1])
//-------------------------------------------------------------------
// Pos validação
//-------------------------------------------------------------------
Static Function SFCA315POS (oModel) 
Local nOpc      := oModel:GetOperation()
Local lRet      := .T. 
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())

if nOpc == 3
	IF !Empty(oModel:GetValue('CYYMASTER','CYY_IDQOET')) 
		DbSelectArea('CYY')
		CYY->(DbSetOrder(3))
		if CYY->(DbSeek(xFilial('CYY')+oModel:GetValue('CYYMASTER','CYY_NRORPO')+oModel:GetValue('CYYMASTER','CYY_IDAT')+oModel:GetValue('CYYMASTER','CYY_IDQOET')))
			SFCMsgErro(STR0029,'SFCA315') //'Já existe registro de split com a chave externa informada'
			lRet := .F.
		Endif
	Endif
Endif

RestArea( aArea )
RestArea( aAreaCYY )

Return lRet

//-------------------------------------------------------------------
// Visualizar
//-------------------------------------------------------------------
Function SFCA315VIS()
Local oModel := FwLoadModel( 'SFCA315' )

oModel:Activate()

FWExecView( '', 'SFCA315', 2,, { || .T. },,,,,,, oModel )

Return Nil

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
/*Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
            
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA315: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA315 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA315' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYY')
			CYY->(dbSetOrder(1))   
			lFound := CYY->(dbSeek(xFilial('CYY')+ PadR(oBusinessContent:_ProductionOrderNumber:TEXT, Len(CYY->CYY_NRORPO)) + PadR(oBusinessContent:_ActivityID:TEXT, Len(CYY->CYY_IDAT)) + oBusinessContent:_SplitOperationCode:TEXT))
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_NRORPO', oBusinessContent:_ProductionOrderNumber:TEXT	) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_IDAT', oBusinessContent:_ActivityID:TEXT				) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_IDQOET', oBusinessContent:_SplitOperationCode:TEXT	) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYYMASTER', 'CYY_CDAC', 	SFCXXtoS(oBusinessContent:_ItemCode:TEXT		) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTATAP', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_ApprovedQuantity:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTATRF', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_ScrapQuantity:TEXT	, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTFE', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_ToolQuantity:TEXT	, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTAT', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_TeamItemQuantity:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTPASU', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_SetupTime:TEXT		, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTATRT', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_ReworkQuantity:TEXT	, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTATRP', 	SFCXStoX(oBusinessContent:_ListOfQuantities:_Quantity:_ReportQuantity:TEXT	, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf

				lAssign := oModel:SetValue('CYYMASTER', 'CYY_CDMQ', 	SFCXXtoS(oBusinessContent:_MachineCode:TEXT					  )	) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_TPSTAT', 	SFCXXtoS(oBusinessContent:_OperationStatus:TEXT				  )	)        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_CDFE', 	SFCXXtoS(oBusinessContent:_ToolCode:TEXT					  )	)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTVMAT', 	SFCXStoX(oBusinessContent:_UsedCapacity:TEXT			 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_LGQORP', 	SFCXStoX(oBusinessContent:_ReportedSplit:TEXT			 , 'L') )        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_LGQOED', 	SFCXStoX(oBusinessContent:_DischargedSplit:TEXT			 , 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_LGQO', 	SFCXStoX(oBusinessContent:_CriticalSplit:TEXT			 , 'L') )        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_LGRPOR', 	SFCXStoX(oBusinessContent:_IsProductionControlReport:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYYMASTER', 'CYY_QTCG', 	SFCXStoX(oBusinessContent:_LotTimeValue:TEXT			 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
							          			                 
				// DateTime - Verificar
				If XmlChildEx(oBusinessContent:_ListOfOperationDates, "_STARTOPERATIONDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTBGAT', 	SFCXStoX(oBusinessContent:_ListOfOperationDates:_OperationDate:_StartOperationDateTime:TEXT , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRBGAT', 	SFCXStoX(oBusinessContent:_ListOfOperationDates:_OperationDate:_StartOperationDateTime:TEXT , 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTEDAT', 	SFCXStoX(oBusinessContent:_ListOfOperationDates:_OperationDate:_EndOperationDateTime:TEXT   , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HREDAT', 	SFCXStoX(oBusinessContent:_ListOfOperationDates:_OperationDate:_EndOperationDateTime:TEXT	, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf 
				
				If XmlChildEx(oBusinessContent, '_LISTOFSETUPDATES') != NIL  .And. XmlChildEx(oBusinessContent:_ListOfSetupDates, '_SETUPDATE') != NIL
					If XmlChildEx(oBusinessContent:_ListOfSetupDates:_SetupDate, '_STARTSETUPDATETIME') != NIL
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTBGSU', 	SFCXStoX(oBusinessContent:_ListOfSetupDates:_SetupDate:_StartSetupDateTime:TEXT			    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRBGSU', 	SFCXStoX(oBusinessContent:_ListOfSetupDates:_SetupDate:_StartSetupDateTime:TEXT				, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oBusinessContent:_ListOfSetupDates:_SetupDate, '_ENDSETUPDATETIME') != NIL
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTEDSU', 	SFCXStoX(oBusinessContent:_ListOfSetupDates:_SetupDate:_EndSetupDateTime:TEXT			    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_HREDSU', 	SFCXStoX(oBusinessContent:_ListOfSetupDates:_SetupDate:_EndSetupDateTime:TEXT			, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
				EndIf
								
				If XmlChildEx(oBusinessContent,  "_AVAILABLEDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTDI', 	SFCXStoX(oBusinessContent:_AvailableDateTime:TEXT										    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRDI', 	SFCXStoX(oBusinessContent:_AvailableDateTime:TEXT		   									, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_STARTEARLIERDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTIMC', 	SFCXStoX(oBusinessContent:_StartEarlierDateTime:TEXT									    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRIMC', 	SFCXStoX(oBusinessContent:_StartEarlierDateTime:TEXT										, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_ENDEARLIERDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTFMC', 	SFCXStoX(oBusinessContent:_EndEarlierDateTime:TEXT										    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRFMC', 	SFCXStoX(oBusinessContent:_EndEarlierDateTime:TEXT											, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_STARTLATERDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTIMT', 	SFCXStoX(oBusinessContent:_StartLaterDateTime:TEXT										    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRIMT', 	SFCXStoX(oBusinessContent:_StartLaterDateTime:TEXT											, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_ENDLATERDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTFMT', 	SFCXStoX(oBusinessContent:_EndLaterDateTime:TEXT										    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRFMT', 	SFCXStoX(oBusinessContent:_EndLaterDateTime:TEXT											, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_STARTEARLIERSETUPDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTIMCS', 	SFCXStoX(oBusinessContent:_StartEarlierSetupDateTime:TEXT								    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRIMCS', 	SFCXStoX(oBusinessContent:_StartEarlierSetupDateTime:TEXT									, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_STARTLATERSETUPDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTIMTS', 	SFCXStoX(oBusinessContent:_StartLaterSetupDateTime:TEXT									    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRIMTS', 	SFCXStoX(oBusinessContent:_StartLaterSetupDateTime:TEXT										, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_LISTOFPLANDATES") != NIL
					If XmlChildEx(oBusinessContent:_ListOfPlanDates:_PlanDate, "_STARTPLANDATETIME") != NIL
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTBGPL', 	SFCXStoX(oBusinessContent:_ListOfPlanDates:_PlanDate:_StartPlanDateTime:TEXT			    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRBGPL', 	SFCXStoX(oBusinessContent:_ListOfPlanDates:_PlanDate:_StartPlanDateTime:TEXT				, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oBusinessContent:_ListOfPlanDates:_PlanDate, "_ENDPLANDATETIME") != NIL
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTEDPL', 	SFCXStoX(oBusinessContent:_ListOfPlanDates:_PlanDate:_EndPlanDateTime:TEXT				    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModel:SetValue('CYYMASTER', 'CYY_HREDPL', 	SFCXStoX(oBusinessContent:_ListOfPlanDates:_PlanDate:_EndPlanDateTime:TEXT					, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent,  "_STARTPLANSETUPDATETIME") != NIL
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_DTPLSU', 	SFCXStoX(oBusinessContent:_StartPlanSetupDateTime:TEXT				 					    , 'DTD') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYYMASTER', 'CYY_HRPLSU', 	SFCXStoX(oBusinessContent:_StartPlanSetupDateTime:TEXT										, 'DTT') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

             EndIf
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA315 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA315 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA315 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "OperationSplit",oModel:GetOperation(), { { "Code", oModel:GetValue("CYYMASTER", 'CYY_CDAC') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          

		cXMLRet += '<ProductionOrderNumber>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_NRORPO')) 		+ '</ProductionOrderNumber>'
		cXMLRet += '<ActivityID>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_IDAT')) 		+ '</ActivityID>'
		cXMLRet += '<SplitOperationCode>' 			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_IDQOET')) 		+ '</SplitOperationCode>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<ItemCode>' 				+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_CDAC')) 		+ '</ItemCode>'
			cXMLRet += '<ItemDescription>' 	   		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DSAC')) 		+ '</ItemDescription>'
			
			cXMLRet += '<ListOfOperationDates>'
				cXMLRet += '<OperationDate>'
					cXMLRet += '<StartOperationDateTime>'	+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTBGAT')) 		+ '</StartOperationDateTime>'
					cXMLRet += '<StartOperationDateTime>'	+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRBGAT')) 		+ '</StartOperationDateTime>'
					cXMLRet += '<EndOperationDateTime>'		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTEDAT')) 		+ '</EndOperationDateTime>'
					cXMLRet += '<EndOperationDateTime>'		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HREDAT')) 		+ '</EndOperationDateTime>'
				cXMLRet += '</OperationDate>'
			cXMLRet += '</ListOfOperationDates>'
			
			cXMLRet += '<ListOfQuantities>'
				cXMLRet += '<Quantity>'
					cXMLRet += '<ApprovedQuantity>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTATAP')) 		+ '</ApprovedQuantity>'
					cXMLRet += '<ScrapQuantity>'   			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTATRF')) 		+ '</ScrapQuantity>'
					cXMLRet += '<ToolQuantity>' 			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTFE')) 		+ '</ToolQuantity>'
					cXMLRet += '<TeamItemQuantity>'    		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTAT')) 		+ '</TeamItemQuantity>'
					cXMLRet += '<SetupTime>' 	 			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTPASU')) 		+ '</SetupTime>'
					cXMLRet += '<ReworkQuantity>' 			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTATRT')) 		+ '</ReworkQuantity>'
					cXMLRet += '<ReportQuantity>' 	  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTATRP')) 		+ '</ReportQuantity>' 
				cXMLRet += '</Quantity>'
			cXMLRet += '</ListOfQuantities>'
			
			cXMLRet += '<MachineCode>' 						+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_CDMQ')) 		+ '</MachineCode>'
			cXMLRet += '<OperationStatus>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_TPSTAT'))   	+ '</OperationStatus>'
			cXMLRet += '<ToolCode>' 						+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_CDFE')) 		+ '</ToolCode>'
			cXMLRet += '<UsedCapacity>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTVMAT')) 		+ '</UsedCapacity>'
			cXMLRet += '<ReportedSplit>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_LGQORP')) 		+ '</ReportedSplit>'
			cXMLRet += '<DischargedSplit>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_LGQOED')) 		+ '</DischargedSplit>'
			cXMLRet += '<CriticalSplit>' 					+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_LGQO')) 		+ '</CriticalSplit>'
			cXMLRet += '<IsProductionControlReport>'	 	+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_LGRPOR')) 		+ '</IsProductionControlReport>'
		
			cXMLRet += '<ListOfSetupDates>'
				cXMLRet += '<SetupDate>'
					cXMLRet += '<StartSetupDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTBGSU')) 		+ '</StartSetupDateTime>'
					cXMLRet += '<StartSetupDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRBGSU')) 		+ '</StartSetupDateTime>'
					cXMLRet += '<EndSetupDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTEDSU')) 		+ '</EndSetupDateTime>'
					cXMLRet += '<EndSetupDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HREDSU')) 		+ '</EndSetupDateTime>'
				cXMLRet += '</SetupDate>'
			cXMLRet += '</ListOfSetupDates>'              	
			              
			cXMLRet += '<AvailableDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTDI')) 	+ '</AvailableDateTime>'
			cXMLRet += '<AvailableDateTime>' 			 	+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRDI')) 	+ '</AvailableDateTime>'
			cXMLRet += '<LotTimeValue>' 		  			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_QTCG')) 	+ '</LotTimeValue>'
			cXMLRet += '<StartEarlierDateTime>' 	  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTIMC')) 	+ '</StartEarlierDateTime>'
			cXMLRet += '<StartEarlierDateTime>' 	 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRIMC')) 	+ '</StartEarlierDateTime>'
			cXMLRet += '<EndEarlierDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTFMC')) 	+ '</EndEarlierDateTime>'
			cXMLRet += '<EndEarlierDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRFMC')) 	+ '</EndEarlierDateTime>'
			cXMLRet += '<StartLaterDateTime>' 		 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTIMT')) 	+ '</StartLaterDateTime>'
			cXMLRet += '<StartLaterDateTime>' 				+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRIMT')) 	+ '</StartLaterDateTime>'
			cXMLRet += '<EndLaterDateTime>' 		  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTFMT')) 	+ '</EndLaterDateTime>'
			cXMLRet += '<EndLaterDateTime>' 		  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRFMT')) 	+ '</EndLaterDateTime>'
			cXMLRet += '<StartEarlierSetupDateTime>'  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTIMCS')) 	+ '</StartEarlierSetupDateTime>'
			cXMLRet += '<StartEarlierSetupDateTime>'  		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRIMCS')) 	+ '</StartEarlierSetupDateTime>'
			cXMLRet += '<StartLaterSetupDateTime>' 	   		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTIMTS')) 	+ '</StartLaterSetupDateTime>'
			cXMLRet += '<StartLaterSetupDateTime>' 	   		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRIMTS')) 	+ '</StartLaterSetupDateTime>'
			cXMLRet += '<StartPlanSetupDateTime>' 			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTPLSU')) 	+ '</StartPlanSetupDateTime>'
			cXMLRet += '<StartPlanSetupDateTime>'  			+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRPLSU')) 	+ '</StartPlanSetupDateTime>'

			cXMLRet += '<ListOfPlanDates>'                                  
				cXMLRet += '<PlanDate>'
					cXMLRet += '<StartPlanDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTBGPL')) 		+ '</StartPlanDateTime>'
					cXMLRet += '<StartPlanDateTime>' 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HRBGPL')) 		+ '</StartPlanDateTime>'
					cXMLRet += '<EndPlanDateTime>' 	 		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_DTEDPL')) 		+ '</EndPlanDateTime>'
					cXMLRet += '<EndPlanDateTime>' 	   		+ SFCXXtoS(oModel:GetValue("CYYMASTER", 'CYY_HREDPL')) 		+ '</EndPlanDateTime>'			
				cXMLRet += '</PlanDate>'
			cXMLRet += '</ListOfPlanDates>'
			
        EndIf
		                
      cXMLRet += '</BusinessContent>'
      
EndIf

ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)

Return { lRet, cXMLRet }
*/

Function INTDF_A315( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} erroPPI

Exibe uma tela com as mensagens de erro que aconteceram durante a integração

@param aDadosInt - Array com as informações dos erros. 
@param nTotal	    - Quantidade total de registros processados.
@param nSucess   - Quantidade de registros processados com sucesso.
@param nError    - Quantidade de registros processados com erro.

@author  Lucas Konrad França
@version P118
@since   11/04/2016
@return  Nil
/*/
//-------------------------------------------------------------------------------------------------
Static Function erroPPI(aDadosInt, nTotal, nSucess, nError)
	Local oDlgErr, oPanel, oBrwErr, oGetTot, oGetErr, oGetSuc
	Local aCampos := {}
	Local aSizes  := {}

	DEFINE MSDIALOG oDlgErr TITLE STR0070 FROM 0,0 TO 350,800 PIXEL //"Erros integração TOTVS MES"
			
	oPanel := tPanel():Create(oDlgErr,01,01,,,,,,,401,156)
	//Cria o array dos campos para o browse
	aCampos := {STR0067,STR0068,STR0069} //"Ordem de produção" / "Status" / "Mensagem"
	aSizes  := {80, 30, 400}
	
	// Cria Browse
	oBrwErr := TCBrowse():New( 0 , 0, 400, 155,,;
	                           aCampos,aSizes,;
	                           oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	// Seta vetor para a browse
	oBrwErr:SetArray(aDadosInt)
	oBrwErr:bLine := {||{ aDadosInt[oBrwErr:nAT,1],;
	                      aDadosInt[oBrwErr:nAt,2],;
	                      aDadosInt[oBrwErr:nAt,3]}}
	oPanel:Refresh()
	oPanel:Show()
	
	@ 162,02 Say STR0066 Of oDlgErr Pixel //"Total de registros:"
	@ 160,48 MSGET oGetTot VAR nTotal SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.
	
	@ 162,90 Say STR0065 Of oDlgErr Pixel //"Processados com erro:"
	@ 160,150 MSGET oGetErr VAR nError SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.
	
	@ 162,190 Say STR0064 Of oDlgErr Pixel //"Processados com sucesso:"
	@ 160,260 MSGET oGetSuc VAR nSucess SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.
	
	DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oDlgErr
	ACTIVATE DIALOG oDlgErr CENTERED

Return Nil