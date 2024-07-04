#INCLUDE "QADA225.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA225
Cadastro de Tópicos
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA225()
	LOCAL aArea   := GetArea()
	LOCAL oBrowse
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QU3")
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
	
	RestArea(aArea)
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.QADA225' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.QADA225' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'QADA225ALT'      OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'QADA225EXC'      OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
		LOCAL oStruQU3  := FWFormStruct(1,'QU3',{|cCampo| ALLTRIM(cCampo) $ "QU3_CHKLST|QU3_REVIS|QU3_ULTREV"})
	LOCAL oStruQU3T := FWFormStruct(1,'QU3',{|cCampo| !ALLTRIM(cCampo) $ "QU3_CHKLST|QU3_REVIS|QU3_ULTREV"})
	LOCAL oModel    := NIL
	
	oModel := MPFormModel():New( 'QADA225', ,{|oModel|QADA225POS(oModel)},)
	
	oStruQU3:AddField(STR0006, STR0006, 'CDESCRI' , 'C', TAMSX3("QU2_DESCRI")[1] , 0, NIL , NIL , NIL ,NIL ,, NIL , NIL , .T. ) // Descrição
	
	oStruQU3:SetProperty("QU3_CHKLST" , MODEL_FIELD_VALID, MTBlcVld("QU3", "QU3_CHKLST" , "ExistCpo('QU2',M->QU3_CHKLST,1)",.F.,.F. ))
	oStruQU3:SetProperty("QU3_REVIS"  , MODEL_FIELD_VALID, MTBlcVld("QU3", "QU3_REVIS"  , "ExistCpo('QU2',M->QU3_CHKLST+M->QU3_REVIS,1)",.F.,.F. ))
	oStruQU3:SetProperty("QU3_CHKLST" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU3:SetProperty("QU3_REVIS"  , MODEL_FIELD_OBRIGAT, .T.)
	
	oStruQU3:AddTrigger( "QU3_REVIS" , "CDESCRI", {|| .T. }, {|| QADA225Atu() } )
	
	oStruQU3T:SetProperty("QU3_CHKITE" , MODEL_FIELD_NOUPD,.T.)
	oStruQU3T:SetProperty("QU3_CHKITE" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU3T:SetProperty("QU3_DESCRI" , MODEL_FIELD_OBRIGAT, .T.)
	
	oModel:AddFields( 'QU3MASTER', /*cOwner*/, oStruQU3 , , , )
	oModel:AddGrid( 'QU3DETAIL'  ,'QU3MASTER', oStruQU3T, ,)
	
	oModel:SetRelation('QU3DETAIL',{{'QU3_FILIAL','xFilial("QU3")'},{'QU3_CHKLST','QU3_CHKLST'},{'QU3_REVIS','QU3_REVIS'}},QU3->(IndexKey(1)))
	
	oModel:GetModel("QU3DETAIL"):SetOptional(.F.)
	oModel:SetPrimaryKey( {{"QU3_FILIAL","QU3_CHKLST","QU3_REVIS"}} ) 
	oModel:GetModel('QU3DETAIL'):SetUniqueLine({'QU3_CHKITE'})
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'QU3MASTER' ):SetDescription(STR0001)			
		
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	LOCAL oModel    := FWLoadModel('QADA225')
	LOCAL oStruQU3  := FWFormStruct(2,'QU3',{|cCampo| ALLTRIM(cCampo) $ "QU3_CHKLST|QU3_REVIS|QU3_ULTREV"})
	LOCAL oStruQU3T := FWFormStruct(2,'QU3',{|cCampo| !ALLTRIM(cCampo) $ "QU3_FILIAL|QU3_CHKLST|QU3_REVIS|QU3_ULTREV"})
	LOCAL oView	
	
	oStruQU3T:RemoveField("QU3_CHKLST")
	oStruQU3T:RemoveField("QU3_REVIS")
	
	oStruQU3:SetProperty('QU3_CHKLST', MVC_VIEW_LOOKUP, 'QBC')
	
	oStruQU3:AddField('CDESCRI', '2', STR0006, STR0006, {}, 'C', '' , NIL , '' , .F. , '' , NIL , NIL , NIL , NIL , .T. ) // Descrição
				
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_CHECK', oStruQU3 , 'QU3MASTER' )
	oView:AddGrid( 'VIEW_QU3'   , oStruQU3T, 'QU3DETAIL' )
	
	oView:CreateHorizontalBox( 'CHECK', 10 )
	oView:CreateHorizontalBox( 'TOPICO', 90 )
		
	oView:SetOwnerView( 'VIEW_CHECK', 'CHECK' )
	oView:SetOwnerView( 'VIEW_QU3'  , 'TOPICO')
	
Return oView


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA225ALT()
Alterar Tópico
@author Geovani.Figueira
@since 21/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA225ALT()

	IF QadChkEfet(QU3->QU3_CHKLST+QU3->QU3_REVIS,.F.)
		FWExecView(STR0004,'QADA225',MODEL_OPERATION_UPDATE,,{ || .T. }) // Alterar
	ENDIF
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA225EXC()
Excluir Tópico
@author Geovani.Figueira
@since 21/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA225EXC()

	IF QadChkEfet(QU3->QU3_CHKLST+QU3->QU3_REVIS,.F.)
		FWExecView(STR0005,'QADA225',MODEL_OPERATION_DELETE,,{ || .T. }) // Excluir
	ENDIF
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA225POS(oModel)
Pós validação
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA225POS(oModel)    
	LOCAL lRet := .T.
	
	IF oModel:GetOperation() == 3
		lRet := qPsqChkLst(oModel:GetModel('QU3MASTER'):GetValue('QU3_CHKLST'),oModel:GetModel('QU3MASTER'):GetValue('QU3_REVIS'),.F.,.F.)
	ENDIF

RETURN lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA225Atu()
Atualiza Descrição
@author Geovani.Figueira
@since 18/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA225Atu()    
	LOCAL cDescricao := ""
	LOCAL oModel     := FWModelActive()
	
	// Busca a descrição do CheckList atraves do registro corrente QU3
	IF oModel:GetOperation() == 3	
		cDescricao := Posicione("QU2", 1, xFilial("QU3")+oModel:GetValue('QU3MASTER','QU3_CHKLST')+oModel:GetValue('QU3MASTER','QU3_REVIS'),"QU2_DESCRI")
	ELSE
		cDescricao := Posicione("QU2", 1, xFilial("QU3")+QU3->QU3_CHKLST+QU3->QU3_REVIS,"QU2_DESCRI")
	ENDIF

RETURN cDescricao
