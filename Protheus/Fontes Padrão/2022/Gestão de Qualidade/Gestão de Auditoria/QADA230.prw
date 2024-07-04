#INCLUDE "QADA230.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA230
Cadastro de Questionário
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA230()
	LOCAL aArea   := GetArea()
	LOCAL oBrowse
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QU4")
	oBrowse:SetDescription(STR0001) // Questionário
	oBrowse:Activate()
	
	RestArea(aArea)
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.QADA230' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.QADA230' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'QADA230ALT()'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'QADA230EXC()'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	LOCAL oStruQU4 := FWFormStruct(1,"QU4")
	LOCAL oModel   := NIL
	
	oStruQU4:SetProperty("QU4_CHKLST" , MODEL_FIELD_VALID, MTBlcVld("QU4", "QU4_CHKLST" , "Qada230Next() .And. Qada230Vld()",.F.,.F. ))
	oStruQU4:SetProperty("QU4_REVIS"  , MODEL_FIELD_VALID, MTBlcVld("QU4", "QU4_REVIS"  , "Qada230Next() .And. Qada230Vld()",.F.,.F. ))
	oStruQU4:SetProperty("QU4_CHKITE" , MODEL_FIELD_VALID, MTBlcVld("QU4", "QU4_CHKITE" , "Qada230Next() .And. Qada230Vld()",.F.,.F. ))
	oStruQU4:SetProperty("QU4_QSTITE" , MODEL_FIELD_VALID, MTBlcVld("QU4", "QU4_QSTITE" , "EXISTCHAV('QU4',M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE+M->QU4_QSTITE)",.F.,.F. ))
	oStruQU4:SetProperty("QU4_CHKLST" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU4:SetProperty("QU4_REVIS"  , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU4:SetProperty("QU4_CHKITE" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU4:SetProperty("QU4_QSTITE" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU4:SetProperty("QU4_USAALT" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU4:SetProperty("QU4_TXTQS1" , MODEL_FIELD_OBRIGAT, .T.)
	
	oModel := MPFormModel():New( 'QADA230', ,{|oModel|QADA230POS(oModel)},{|oModel|QADA230GRV(oModel)})
	oModel:SetDescription(STR0001) // Questionário
	oModel:AddFields( 'QU4MASTER', /*cOwner*/, oStruQU4 )
	oModel:GetModel( 'QU4MASTER' ):SetDescription(STR0001)
	
	FWMemoVirtual(oStruQU4, {{'QU4_TXTCHV','QU4_TXTQS1'},{'QU4_OBSCHV','QU4_OBSER1'},{'QU4_REQCHV','QU4_REQQS1'}})
		
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	LOCAL oModel   := FWLoadModel('QADA230')
	LOCAL oStruQU4 := FWFormStruct(2,'QU4',{|cCampo|!ALLTRIM(cCampo)$"QU4_FILIAL|QU4_TXTCHV|QU4_OBSCHV|QU4_REQCHV"})
	LOCAL oView	
	
	oStruQU4:AddGroup('G01', '' , '', 1)
	oStruQU4:AddGroup('G02', '' , '', 1)
	oStruQU4:AddGroup('G03', '' , '', 1)
	
	oStruQU4:SetProperty( 'QU4_CHKLST', MVC_VIEW_GROUP_NUMBER, 'G01' )
	oStruQU4:SetProperty( 'QU4_REVIS' , MVC_VIEW_GROUP_NUMBER, 'G01' )
	oStruQU4:SetProperty( 'QU4_CHKITE', MVC_VIEW_GROUP_NUMBER, 'G01' )
	oStruQU4:SetProperty( 'QU4_QSTITE', MVC_VIEW_GROUP_NUMBER, 'G01' )
	
	oStruQU4:SetProperty( 'QU4_TXTQS1', MVC_VIEW_GROUP_NUMBER, 'G02' )
	
	oStruQU4:SetProperty( 'QU4_FAIXIN', MVC_VIEW_GROUP_NUMBER, 'G03' )
	oStruQU4:SetProperty( 'QU4_FAIXFI', MVC_VIEW_GROUP_NUMBER, 'G03' )
	oStruQU4:SetProperty( 'QU4_USAALT', MVC_VIEW_GROUP_NUMBER, 'G03' )
	oStruQU4:SetProperty( 'QU4_ULTREV', MVC_VIEW_GROUP_NUMBER, 'G03' )
	oStruQU4:SetProperty( 'QU4_PESO'  , MVC_VIEW_GROUP_NUMBER, 'G03' )
	
	oStruQU4:SetProperty( 'QU4_OBSER1', MVC_VIEW_GROUP_NUMBER, 'G03' )
	oStruQU4:SetProperty( 'QU4_REQQS1', MVC_VIEW_GROUP_NUMBER, 'G03' )
			
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_QU4', oStruQU4, 'QU4MASTER' )	
	oView:CreateHorizontalBox( 'TELA', 100 )	
	oView:SetOwnerView( 'VIEW_QU4', 'TELA' )
	
Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230ALT()
Alterar Questionário
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230ALT()

	IF QADChkEfet(QU4->QU4_CHKLST+QU4->QU4_REVIS,.F.)
		FWExecView(STR0004,'QADA230',MODEL_OPERATION_UPDATE,,{ || .T. }) // Alterar
	ENDIF
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230EXC()
Excluir Questionário
@author Geovani.Figueira
@since 17/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230EXC()

	IF QADChkEfet(QU4->QU4_CHKLST+QU4->QU4_REVIS,.F.)
		FWExecView(STR0005,'QADA230',MODEL_OPERATION_DELETE,,{ || .T. }) // Excluir
	ENDIF
	
RETURN


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230POS(oModel)
Pós validação
@author Geovani.Figueira
@since 17/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230POS(oModel)
	LOCAL lRet := .T.
	
	IF (oModel:GetValue('QU4MASTER','QU4_FAIXFI') - oModel:GetValue('QU4MASTER','QU4_FAIXIN') <= 0)
	   HELP(" ",1,"QU4NOTA")
	   lRet := .F.
	ENDIF	
	
RETURN lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230GRV(oModel)
Gravação Commit
@author Geovani.Figueira
@since 17/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230GRV(oModel)
	LOCAL lRet := .T.	

	IF oModel:GetOperation() # 5
		IF oModel:GetValue('QU4MASTER','QU4_PESO') == 0
			oModel:SetValue('QU4MASTER','QU4_PESO',1)
		ENDIF
		IF Existblock ("QD030TOK")
			Execblock("QD030TOK",.F.,.F.,{xFilial("QU4"),oModel:GetValue('QU4MASTER','QU4_CHKLST'),oModel:GetValue('QU4MASTER','QU4_REVIS'),oModel:GetValue('QU4MASTER','QU4_CHKITE'),oModel:GetValue('QU4MASTER','QU4_QSTITE')})
		ENDIF
	ENDIF
	
	lRet := FwFormCommit(oModel)
	
RETURN lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230VLD()
Efetua as validacoes no Questionario
@author Geovani.Figueira
@since 17/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230VLD()
	LOCAL lRet      := .T.
	LOCAL lHelp     := .F.
	LOCAL oModel    := FWModelActive() // FWLoadModel('QADA230')
	LOCAL oModelQU4 := oModel:GetModel('QU4MASTER')
	
	IF !Empty(oModelQU4:GetValue('QU4_CHKLST')) 
	
		QU3->(dbSetOrder(1))
		IF QU3->(!dbSeek(xFilial("QU3")+oModelQU4:GetValue('QU4_CHKLST')))
			lRet  := .F.
			lHelp := .T.
	    ENDIF  
	    
		IF !Empty(oModelQU4:GetValue('QU4_REVIS')) .And. lRet
			IF QU3->(!dbSeek(xFilial("QU3")+oModelQU4:GetValue('QU4_CHKLST')+oModelQU4:GetValue('QU4_REVIS')))
				lRet  := .F.
				lHelp := .T.
			Else
				IF !QADChkEfet(oModelQU4:GetValue('QU4_CHKLST')+oModelQU4:GetValue('QU4_REVIS'),.F.)
					lRet := .F.
				ENDIF	
		    ENDIF
		    
			IF !Empty(oModelQU4:GetValue('QU4_CHKITE')) .And. lRet
				IF QU3->(!dbSeek(xFilial("QU3")+oModelQU4:GetValue('QU4_CHKLST')+oModelQU4:GetValue('QU4_REVIS')+oModelQU4:GetValue('QU4_CHKITE')))
					lRet  := .F.
					lHelp := .T.
	            ENDIF
			ENDIF
		ENDIF		
	ENDIF
	
	IF lHelp
		Help(" ",1,"QU4CHKNEXI")	
	ENDIF

RETURN lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA230Next()
Retorna o proximo numero da questao	
@author Geovani.Figueira
@since 17/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA230Next()
	LOCAL aSavQU4   := QU4->(GetArea())	 
	LOCAL nChkLst   := 0
	
	IF !Empty(M->QU4_CHKLST) .AND. !Empty(M->QU4_REVIS) .AND. !Empty(M->QU4_CHKITE) 
		QU4->(dbSetOrder(1))
		IF !QU4->(dbSeek(xFilial("QU4")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE))
			nChkLst ++
			M->QU4_QSTITE := StrZero(nChkLst,Len(QU4->QU4_QSTITE))
		ELSE
			While !QU4->(Eof()) .And. (QU4->QU4_FILIAL+QU4->QU4_CHKLST+QU4->QU4_REVIS+QU4->QU4_CHKITE)==;
				(xFilial("QU4")+M->QU4_CHKLST+M->QU4_REVIS+M->QU4_CHKITE)
				nChkLst ++
				IF Val(QU4->QU4_QSTITE) <> nChkLst
					nChkLst--
					Exit
				Endif
				QU4->(dbSkip())
			EndDo
			M->QU4_QSTITE := StrZero((nChkLst+1),Len(QU4->QU4_QSTITE))
		ENDIF
	ENDIF
	
	RestArea(aSavQU4)

RETURN .T.
