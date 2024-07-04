#INCLUDE 'PROTHEUS.CH'
#INCLUDE "SFCA317.ch"
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA317
Tela de cadastro de Apontamento de Parada Geral

@author Samantha Preima
@since 24/11/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA317()
Local aCoors := FWGetDialogSize( oMainWnd ) 
Local oPanelUp, oFWLayer, oPanel

Private oDlgPrinc, oBrowseUp, oBrowse 

DEFAULT lAutomacao := .F.

SFCValInt() // Verifica integração ligada

If !lAutomacao
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1],aCoors[2] To aCoors[3],aCoors[4] Pixel  //'Apontamento de Parada Geral'


	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	// Define Painel Superior
	oFWLayer:AddLine( 'UP', 55, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	// FWmBrowse Superior 
	oBrowseUp:= FWMBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( STR0001 ) //"Apontamento de Parada Geral"
	oBrowseUp:SetMenuDef( 'SFCA317' )
	oBrowseUp:SetAlias( 'CZ7' )
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:DisableDetails()
	oBrowseUp:ForceQuitButton(.T.)
	oBrowseUp:Activate()

	// Painel Inferior
	oFWLayer:AddLine( 'DOWN', 45, .F. )
	oFWLayer:AddCollumn( 'LEFT' ,  100, .T., 'DOWN' )
	oPanel := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )

	oBrowse:= FWMBrowse():New()
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( STR0010 ) //'Apontamentos de Parada'   
	oBrowse:SetMenuDef( 'SFCA311' )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'CYX' )
	oBrowse:SetProfileID( '2' )
	oBrowse:ForceQuitButton(.T.)
	oBrowse:Activate() 

	// Relacionamento entre os Paineis
	oRelacCYX:= FWBrwRelation():New()
	oRelacCYX:AddRelation( oBrowseUp  , oBrowse , { { 'CYX_FILIAL', 'CZ7_FILIAL' }, { 'CYX_IDSPTT' , 'CZ7_IDSPTT'  } } ) 
	oRelacCYX:Activate()

	Activate MsDialog oDlgPrinc Center
EndIf

Return NIL 

//-------------------------------------------------------------------
// Menu de Apontamento de Parada Geral
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.SFCA317' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.SFCA317' OPERATION 4 ACCESS 0  // 'Alterar'       
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.SFCA317' OPERATION 5 ACCESS 0  // 'Eliminar'      
ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.SFCA317' OPERATION 2 ACCESS 0  // 'Visualizar'    

Return aRotina  

//-------------------------------------------------------------------
// Model de Apontamento de Parada
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCZ7 := FWFormStruct( 1, 'CZ7', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento de Parada
Local oModel         

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA317', /*bPreValidacao*/, { | oMdlG | SFCA317POS ( oMdlG ) } , /*{ | oMdl | SFCA317CMM ( oMdl ) }*/ ,, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZ7MASTER', /*cOwner*/, oStruCZ7 )       

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )    //'Apontamento de Parada Geral'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CZ7MASTER' ):SetDescription( STR0001 )  //'Apontamento de Parada Geral'

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({"CZ7_FILIAL","CZ7_IDSPTT"})  

Return oModel

//-------------------------------------------------------------------
// View de Apontamento de Parada
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCZ7 := FWFormStruct( 2, 'CZ7' ) // Pai - Apontamento de Parada
Local oModel   := FWLoadModel( 'SFCA317' )
Local oView

DEFAULT lAutomacao := .F.

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )    

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZ7', oStruCZ7, 'CZ7MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100 ) 

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZ7', 'PAI' )

If GetMv("MV_SFCTPRE") == '2'
	oStruCZ7:RemoveField('CZ7_HRBGSP')
	oStruCZ7:RemoveField('CZ7_HREDSP')
Else
	oStruCZ7:RemoveField('CZ7_HCBGSP')	
	oStruCZ7:RemoveField('CZ7_HCEDSP')	
EndIf

If SFCIntegra(.T.) == 1 .Or. lAutomacao
	oStruCZ7:RemoveField('CYV_CDOE')
	oStruCZ7:RemoveField('CYV_CDGR')
Endif

Return oView 

//-------------------------------------------------------------------
// - Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function SFCA317POS( oModel ) 
Local lRet      := .T.             
Local oModelCZ7 := oModel:GetModel( 'CZ7MASTER' )
Local nOpc      := oModel:GetOperation()  
Local aArea     := GetArea()

If nOpc == 3
   If Empty(oModelCZ7:GetValue('CZ7_DTEDSP'))
      SFCMsgErro(STR0017,"SFCA317") //"Data final deve ser preenchida."
      lRet := .F.
   ElseIf Empty(oModelCZ7:GetValue('CZ7_HREDSP'))
      SFCMsgErro(STR0018,"SFCA317") //"Hora final deve ser preenchida."
      lRet := .F.
   ElseIf oModelCZ7:GetValue('CZ7_DTEDSP') == StoD("99991231") .And. oModelCZ7:GetValue('CZ7_HREDSP') == "23:59:59"
      SFCMsgErro(STR0019,"SFCA317") //"Data e Hora final inválidas."
      lRet := .F.
   EndIf
   If !lRet
      Return lRet
   EndIf
EndIf

Begin Transaction

	if nOpc == 3

		if Empty(oModelCZ7:GetValue('CZ7_DTEDSP'))
			oModelCZ7:SetValue('CZ7_DTEDSP',CTOD('31/12/9999'))
		Endif
	
		If GetMv("MV_SFCTPRE") == '2'
			if Empty(oModelCZ7:GetValue('CZ7_HCEDSP'))
				oModelCZ7:SetValue('CZ7_HCEDSP',23.9998)			
			Endif
			oModelCZ7:SetValue('CZ7_HRBGSP',SFCXCENTOHR(oModelCZ7:GetValue('CZ7_HCBGSP')))
			oModelCZ7:SetValue('CZ7_HREDSP',SFCXCENTOHR(oModelCZ7:GetValue('CZ7_HCEDSP'))) 
		Else
			If Empty(oModelCZ7:GetValue('CZ7_HREDSP'))    	
				oModelCZ7:LoadValue('CZ7_HREDSP', "23:59:59")
			Endif
		Endif
		
		dbSelectArea('CYN')
		CYN->(dbSetOrder(1))
		CYN->(dbGoTop())
		IF CYN->(dbSeek(xFilial('CYN')+oModelCZ7:GetValue('CZ7_CDSP'))) .AND. CYN->CYN_LGSU
			SFCMsgErro(STR0015,"SFCA317") //"Parada Geral não pode ser realizada com Motivo de Parada do tipo Preparação"
		    lRet := .F.
		Endif
		
		if Empty(IF(GetMv("MV_SFCTPRE") == '2',oModelCZ7:GetValue('CZ7_HCBGSP'),oModelCZ7:GetValue('CZ7_HRBGSP')))
			SFCMsgErro(STR0002,"SFCA317") //"Hora Inicial deve ser preenchida"
	    	lRet := .F.
		Endif
		
		if oModelCZ7:GetValue('CZ7_DTEDSP') == oModelCZ7:GetValue('CZ7_DTBGSP') .AND.;
		   oModelCZ7:GetValue('CZ7_HREDSP') < oModelCZ7:GetValue('CZ7_HRBGSP')
			SFCMsgErro(STR0003,"SFCA317") //"Hora Fim não pode ser menor que Hora Início"
		    lRet := .F.
		Endif
		
		if oModelCZ7:GetValue('CZ7_DTEDSP') < oModelCZ7:GetValue('CZ7_DTBGSP')
			SFCMsgErro(STR0005,"SFCA317") //"Data Fim não pode ser menor que Data Início"
		    lRet := .F.
		Endif
			
		if lRet == .T.
			
			cQuery := ""
			cQuery += "SELECT COUNT(*) AS QTD FROM " + RetSQLName( 'CZ7' ) + " CZ7 WHERE "
			cQuery += "		CZ7_FILIAL  = '" + xFilial('CZ7') + "' AND "
			
			if Empty(oModelCZ7:GetValue('CZ7_CDCETR'))
				cQuery += "		CZ7_CDARPO  = '" + oModelCZ7:GetValue('CZ7_CDARPO') + "' AND "
			Else
				cQuery += "		CZ7_CDCETR  = '" + oModelCZ7:GetValue('CZ7_CDCETR') + "' AND "
			Endif
			
			cQuery += "	 (((CZ7_DTBGSP <= '" + DTOS(oModelCZ7:GetValue('CZ7_DTBGSP')) + "' AND CZ7_HRBGSP < '" + oModelCZ7:GetValue('CZ7_HRBGSP') + "')  AND "
			cQuery += "	   (CZ7_DTEDSP >= '" + DTOS(oModelCZ7:GetValue('CZ7_DTBGSP')) + "' AND CZ7_HREDSP > '" + oModelCZ7:GetValue('CZ7_HRBGSP') + "')) OR "
			cQuery += "	  ((CZ7_DTBGSP <= '" + DTOS(oModelCZ7:GetValue('CZ7_DTEDSP')) + "' AND CZ7_HRBGSP < '" + oModelCZ7:GetValue('CZ7_HREDSP') + "')  AND "
			cQuery += "	   (CZ7_DTEDSP >= '" + DTOS(oModelCZ7:GetValue('CZ7_DTEDSP')) + "' AND CZ7_HREDSP > '" + oModelCZ7:GetValue('CZ7_HREDSP') + "')) OR "
			cQuery += "   ((CZ7_DTBGSP >= '" + DTOS(oModelCZ7:GetValue('CZ7_DTBGSP')) + "' AND CZ7_HRBGSP > '" + oModelCZ7:GetValue('CZ7_HRBGSP') + "')  AND "
			cQuery += "    (CZ7_DTEDSP <= '" + DTOS(oModelCZ7:GetValue('CZ7_DTEDSP')) + "' AND CZ7_HREDSP < '" + oModelCZ7:GetValue('CZ7_HREDSP') + "')) OR "
			cQuery += "    (CZ7_DTBGSP >= '" + DTOS(oModelCZ7:GetValue('CZ7_DTBGSP')) + "' AND CZ7_DTEDSP < '" + DTOS(oModelCZ7:GetValue('CZ7_DTEDSP')) + "')) AND "
			cQuery += "     D_E_L_E_T_ = ' '"
				
			cTmp := GetNextAlias()
		
			dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
			
			If (cTmp)->QTD > 0
				SFCMsgErro(STR0006, "SFCA317") //"Já existe um apontamento de parada realizado durante o período informado"
				lRet := .F.		
			EndIf
			(cTmp)->(dbCloseArea())
		Endif
	Endif
	
	lRet := SFCA317PAR(nOpc, oModel)
	
	if !lRet
		DisarmTransaction()	
	Endif
	
	If Type('oBrowseUp') == "O"
		oBrowseUp:Refresh()
	EndIf
	If Type('oBrowse') == "O"
		oBrowse:Refresh()
	EndIf
	
End Transaction

RestArea(aArea)

FwModelActive( oModel, .T. )

Return lRet

//-------------------------------------------------------------------
// - Gera paradas de máquina
// Input: 
// Retorno: 
//-------------------------------------------------------------------
Static Function SFCA317PAR(nOpc, oModel)
Local lRet    := .T.
Local aMotivo := {}
Local aErro   := {}
Local cQuery  := ''
Local cTmp    := ''
Local cTmp2   := ''
Local aAreaCYX := CYX->(getArea())
Local oModelCZ7 := oModel:GetModel( 'CZ7MASTER' )
Local cCDSP   := ""
Local dDTBGSP := Nil
Local dDTEDSP := Nil
Local cIDSPTT := ""
Local nHCBGSP := 0
Local nHCEDSP := 0
Local cHRBGSP := ""
Local cHREDSP := ""
Local cCDCETR := ""
Local cCDARPO := ""
Local cSFCTPRE := GetMv("MV_SFCTPRE")

DEFAULT lAutomacao := .F.

cCDSP   := oModelCZ7:GetValue('CZ7_CDSP')
dDTBGSP := oModelCZ7:GetValue('CZ7_DTBGSP')
dDTEDSP := oModelCZ7:GetValue('CZ7_DTEDSP')
cIDSPTT := oModelCZ7:GetValue('CZ7_IDSPTT')
nHCBGSP := oModelCZ7:GetValue('CZ7_HCBGSP')
nHCEDSP := oModelCZ7:GetValue('CZ7_HCEDSP')
cHRBGSP := oModelCZ7:GetValue('CZ7_HRBGSP')
cHREDSP := oModelCZ7:GetValue('CZ7_HREDSP')
cCDCETR := oModelCZ7:GetValue('CZ7_CDCETR')
cCDARPO := oModelCZ7:GetValue('CZ7_CDARPO')

If nOpc == 3
	if !Empty(cCDCETR)
		cQuery := ""
		cQuery += "SELECT * FROM " + RetSQLName( 'CYI' ) + " CYI WHERE "
		cQuery += "		CYI_FILIAL = '" + xFilial('CYI') + "' AND "
		cQuery += "		CYI_CDCETR = '" + cCDCETR + "' AND "
		cQuery += "     D_E_L_E_T_ = ' ' ORDER BY CYI_CDCETR"			
	Else
		cQuery := ""
		cQuery += "SELECT * FROM " + RetSQLName( 'CYI' ) + " CYI WHERE "
		cQuery += "		CYI_FILIAL = '" + xFilial('CYI') + "' AND "
		cQuery += "		CYI_CDARPO = '" + cCDARPO + "' AND "
		cQuery += "     D_E_L_E_T_ = ' ' ORDER BY CYI_CDCETR"
	Endif
	
	cTmp := GetNextAlias()
	
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
	
	While (cTmp)->(!EOF()) .Or. lAutomacao
	
		cQuery := ""
		cQuery += "SELECT * FROM " + RetSQLName( 'CYB' ) + " CYB WHERE "
		cQuery += "		CYB_FILIAL = '" + xFilial('CYB') + "' AND "
		cQuery += "		CYB_CDCETR = '" + (cTmp)->CYI_CDCETR + "' AND "
		cQuery += "     D_E_L_E_T_ = ' ' ORDER BY CYB_CDMQ"
		
		cTmp2 := GetNextAlias()
	
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp2, .T., .F. )
		
		While (cTmp2)->(!EOF()) .Or. lAutomacao
			oModelCYX := FWLoadModel( 'SFCA311' )
			oModelCYX:SetOperation( 3 )
			oModelCYX:Activate()
			
			oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_CDMQ'  , (cTmp2)->CYB_CDMQ)
			oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_CDSP'  , cCDSP)
			oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_DTBGSP', dDTBGSP)
			oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_DTEDSP', dDTEDSP)
			oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_IDSPTT', cIDSPTT) 
			
			IF cSFCTPRE == '2'
				oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_HCBGSP', nHCBGSP,.T.)
				oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_HCEDSP', nHCEDSP,.T.)
			Else
				oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_HRBGSP', cHRBGSP,.T.)
				oModelCYX:GetModel('CYXMASTER'):SetValue('CYX_HREDSP', cHREDSP,.T.)
			Endif
					
			IF oModelCYX:VldData()
				oModelCYX:CommitData()
			Else
				aErro := oModelCYX:GetErrorMessage()
				AADD(aMotivo,(cTmp2)->CYB_CDMQ + aErro[6])
			Endif
			oModelCYX:DeActivate()

			If lAutomacao
				Exit
			EndIf
			
			(cTmp2)->(dbSkip())
		End	
		
		(cTmp2)->(dbCloseArea())

		If lAutomacao
			Exit
		EndIf

		(cTmp)->(dbSkip())
	End
			
	(cTmp)->(dbCloseArea())
ElseIf nOpc == 4
	// Alterando paradas
	/*integração com datasul não tem previsão de sair
	if SFCIntegra() == 2	
		dbSelectArea('CYX')
		CYX->(dbSetOrder(3))
		CYX->(dbGoTop())
		CYX->(dbSeek(xFilial('CYX')+CZ7->CZ7_IDSPTT))
		While CYX->(!EOF()) .AND. CYX->CYX_IDSPTT == CZ7->CZ7_IDSPTT
			oModelCYX := FWLoadModel( 'SFCA311' )			
			oModelCYX:SetOperation( 4 )
			oModelCYX:Activate()
		
			oModelCYX:LoadValue('CYXMASTER', 'CYX_CDSP', CZ7->CZ7_CDSP)
		
			IF oModelCYX:VldData()
				oModelCYX:CommitData()
			Else
				aErro := oModelCYX:GetErrorMessage()
				AADD(aMotivo,CYX->CYX_CDMQ + aErro[6])
			Endif
		
			oModelCYX:DeActivate()
		
			CYX->(dbSkip())
		End
	
		RestArea(aAreaCYX)
	Else*/
		SFCMsgErro (STR0016 , 'SFCA317', 2 ) // 'Paradas de Máquina não serão alteradas pois já foram integradas com o PCP'
	//Endif
Else
	// Eliminando paradas
	dbSelectArea('CYX')
	CYX->(dbSetOrder(3))
	CYX->(dbGoTop())
	CYX->(dbSeek(xFilial('CYX')+CZ7->CZ7_IDSPTT))
	While CYX->(!EOF()) .AND. CYX->CYX_IDSPTT == CZ7->CZ7_IDSPTT
		oModelCYX := FWLoadModel( 'SFCA311' )
		oModelCYX:SetOperation( 5 )
		oModelCYX:Activate()
		
		IF oModelCYX:VldData()
			oModelCYX:CommitData()
		Else
			aErro := oModelCYX:GetErrorMessage()
			AADD(aMotivo,CYX->CYX_CDMQ + aErro[6])
		Endif
		
		oModelCYX:DeActivate()

		If lAutomacao
			Exit
		EndIf
		
		CYX->(dbSkip())
	End
	
	RestArea(aAreaCYX) 
Endif 

IF !Empty(aMotivo)
	GeraTXT(aMotivo)
Endif

Return lRet
 
//-------------------------------------------------------------------
// - Gera arquivo txt com os erros gerados
// Input: 
// Retorno: 
//-------------------------------------------------------------------
Static Function GeraTXT( aDados )
Local cArq   := ''
Local nHdl   := -1
Local cLinha := ''
Local cEOF   := Chr(13) + Chr(10)   
Local aArea  := GetArea()
Local nI	 := 0

//cArq := GetSrvProfString( 'StartPath', '' )
cArq := 'C:\TEMP'

If Empty( cArq )
 	Return NIL
EndIf

cArq := AllTrim( cArq ) + "\ErrosParadaGeral.TXT"

nHdl := FCreate(cArq)
If fError() != 0
   //Se não conseguiu criar o arquivo, cria dentro da pasta do servidor.
   If !ExistDir("\SIGASFC")
      MakeDir("\SIGASFC")
   EndIf
   cArq := "\SIGASFC\ErrosParadaGeral" + DtoS(DATE()) + StrTran(Time(),":","") + ".TXT"
   nHdl := FCreate(cArq)
   //Se não conseguiu criar o arquivo no servidor, não continua a execução desta função.
   If fError() != 0
      ApMsgInfo(STR0020) //"Ocorreram erros na criação do log de parada geral."
      Return NIL
   EndIf
EndIf
cLinha := '-------------------------------------------------------------------------' + DTOC(DATE()) + '-' + TIME() + cEOF + ;
		  STR0007 + cEOF + ; //'Erros gerados durante o apontamento da Parada Geral'
		  '--------------------------------------------------------------------------------------------' + cEOF + ;
		  STR0008 + cEOF + ; //'Máquina              Erro'
 		  '-------------------- -----------------------------------------------------------------------' + cEOF
  		  
FWrite(nHdl, cLinha, Len(cLinha))

For nI := 1 to Len( aDados )

	cLinha := aDados[nI] + cEOF
			
	FWrite(nHdl, cLinha, Len(cLinha))
Next

FClose(nHdl)

ApMsgInfo(STR0009 + cArq) //"Foram gerados erros durante a criação dos Apontamentos de Parada. Para visualizá-los verifique o arquivo: "
          
RestArea( aArea )

Return NIL                     
                     
/*----------------------------------------------
Valida se parada está disponível para alteração
----------------------------------------------*/
Function SFCA317VAL()
	Local lRet := .T.
               
If SFCIntegra() == 1 .And. !Empty(CZ7->CZ7_DTEDSP) .And. CZ7->CZ7_DTEDSP != CTOD('31/12/9999') .And. !INCLUI
	lRet := .F.
EndIf  

Return lRet

/*----------------------------------------------
Filtro de Operadores e Equipes
----------------------------------------------*/
Function SFCA317FIL(nType)
Local lRet    := .F.
Local cCDARPO := FwFldGet('CZ7_CDARPO')
Local cCDCETR := FwFldGet('CZ7_CDCETR')

DEFAULT lAutomacao := .F.

IF (nType == 1 .AND. CYH->CYH_TPRC == '1') .OR.;
   (nType == 2 .AND. CYH->CYH_TPRC == '3') .OR. lAutomacao
	if Empty(CYH->CYH_CDARPO) .AND. !lAutomacao
		lRet := .T.
	Else	
		IF Empty(cCDCETR)
			if CYH->CYH_CDARPO == cCDARPO
				lRet := .T.
			Endif			
		Else
			dbSelectArea('CYI')
			CYI->(dbSetOrder(1))
			CYI->(dbGoTop())
			IF CYI->(dbSeek(xFilial('CYI')+cCDCETR)) .AND. CYI->CYI_CDCETR == cCDCETR .AND. CYI->CYI_CDARPO == cCDARPO
				lRet := .T.
			Endif
		Endif
	Endif
Endif

Return lRet
       
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local aArea     := GetArea() 
Local aAreaCZ7  := CZ7->(GetArea())

DEFAULT lAutomacao := .F.
              
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA317: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))


	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA317 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL .Or. lAutomacao
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
			
            If lValid == .F. .And. !lAutomacao
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA317' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CZ7')
			CZ7->(dbSetOrder(1))

			If !lAutomacao
				lFound := CZ7->(dbSeek(xFilial('CZ7') + PadR(oBusinessContent:_StopReasonCode:TEXT, Len(CZ7->CZ7_CDSP)) + DToS(SFCXStoX(oBusinessContent:_StartDate:TEXT, 'D')) ) )
			

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
						lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_CDSP'  , oBusinessContent:_StopReasonCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_DTBGSP', SFCXStoX( oBusinessContent:_StartDate:TEXT, 'D') )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
				
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_CDCETR', oBusinessContent:_WorkCenterCode:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_DSCETR', oBusinessContent:_WorkCenterDescription:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_DSSP'  , oBusinessContent:_StopReasonDescription:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_HRBGSP', oBusinessContent:_StartTime:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_DTEDSP', SFCXStoX( oBusinessContent:_EndDate:TEXT, 'D') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_HREDSP', oBusinessContent:_EndTime:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_CDARPO', oBusinessContent:_ProductionAreaCode:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_DSARPO', oBusinessContent:_ProductionAreaDescription:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_HCBGSP', SFCXStoX(oBusinessContent:_StartStop:TEXT, 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CZ7MASTER', 'CZ7_HCEDSP', SFCXStoX(oBusinessContent:_EndStop:TEXT, 'N') )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
			Else
				// Set a operação e Ativa o Model
				oModel:SetOperation(nOpc)
				oModel:Activate()
			EndIf

            // Validação no Model    
			if oModel:VldData()  .And. !lAutomacao
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
			//conout( '+ IntegDef SFCA317 Recebendo Mensagem Response' )
			cXMLRet := 'Resposta recebida com sucesso.'
		// Mensagem é de Whois
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			//conout( '+ IntegDef SFCA317 Recebendo Mensagem WHOIS' )
			Return {.T., '1.000'}
		EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA317 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  If lAutomacao
	  	oModel:ACTIVATE()
	  EndIf

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ReportStopGeneral",oModel:GetOperation(), { { "StopReasonCode", SFCXXtoS(oModel:GetValue("CZ7MASTER", "CZ7_CDSP")) }, ;
       																	     { "StartDate",  SFCXXtoS(oModel:GetValue("CZ7MASTER", "CZ7_DTBGSP")) } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
	  cXMLRet += '<BusinessContent>'          
       
		cXMLRet += '<StopReasonCode>' 				+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_CDSP')) 	+ '</StopReasonCode>'
		cXMLRet += '<StartDate>' 					+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_DTBGSP')) 	+ '</StartDate>'
		

		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5                                                                                                  
		
            cXMLRet += '<WorkCenterCode>' 				+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_CDCETR')) 	+ '</WorkCenterCode>' 
			cXMLRet += '<WorkCenterDescription>' 		+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_DSCETR')) 	+ '</WorkCenterDescription>'
			cXMLRet += '<StopReasonDescription>' 		+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_DSSP')) 	+ '</StopReasonDescription>'
			cXMLRet += '<StartTime>' 					+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_HRBGSP')) 	+ '</StartTime>'
			cXMLRet += '<EndDate>' 						+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_DTEDSP')) 	+ '</EndDate>'
			cXMLRet += '<EndTime>' 						+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_HREDSP')) 	+ '</EndTime>'
			cXMLRet += '<ProductionAreaCode>' 			+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_CDARPO')) 	+ '</ProductionAreaCode>'
			cXMLRet += '<ProductionAreaDescription>' 	+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_DSARPO')) 	+ '</ProductionAreaDescription>'
			cXMLRet += '<StartStop>' 					+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_HCBGSP')) 	+ '</StartStop>'
			cXMLRet += '<EndStop>' 						+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_HCEDSP')) 	+ '</EndStop>'
			cXMLRet += '<StopTotalID>' 					+ SFCXXtoS(oModel:GetValue("CZ7MASTER", 'CZ7_IDSPTT')) 	+ '</StopTotalID>'
			
		EndIf               
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aArea)
RestArea(aAreaCZ7)

//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }


Function INTDF_A317( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
