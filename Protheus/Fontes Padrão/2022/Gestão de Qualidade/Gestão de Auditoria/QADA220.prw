#INCLUDE "QADA220.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 
Static lCopia := .F.

//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA220
Cadastro de CheckList
@author Leonardo Bratti
@since 11/08/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA220()
	LOCAL aArea   := GetArea()
	LOCAL oBrowse
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QU2")
	oBrowse:SetDescription(STR0001)
	oBrowse:AddLegend( "QU2_EFETIV=='1'", "GREEN", STR0008 ) // Vigente
	oBrowse:AddLegend( "QU2_EFETIV=='3'", "GRAY" , STR0009 ) // Pendente
	oBrowse:AddLegend( "QU2_EFETIV=='2'", "RED"  , STR0010 ) // Obsoleto
	oBrowse:Activate()
	
	RestArea(aArea)
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 11/08/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.QADA220' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'QADA220ALT()'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.QADA220' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION 'QADA220EXC()'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0006 ACTION 'QADA220EFE()'    OPERATION 2                      ACCESS 0 // Efetiva
	ADD OPTION aRotina TITLE STR0007 ACTION 'QADA220COP()'    OPERATION 9                      ACCESS 0 // Copiar
	ADD OPTION aRotina TITLE STR0012 ACTION 'QA220Dupl()'     OPERATION 9                      ACCESS 0 // Duplica
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 11/08/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	LOCAL oStruQU2 := FWFormStruct(1,"QU2")
	LOCAL oModel   := NIL
	
	oStruQU2:SetProperty("QU2_REVIS" , MODEL_FIELD_VALID, MTBlcVld("QU2", "QU2_REVIS" , "ExistChav('QU2',M->QU2_CHKLST+M->QU2_REVIS,1,'EXISTCHK') .And. QADA220Revi() .AND. FreeForUse('QU2',M->QU2_CHKLST+M->QU2_REVIS)",.F.,.F. )) 
	oStruQU2:SetProperty("QU2_CHKLST", MODEL_FIELD_OBRIGAT, .T.)
	oStruQU2:SetProperty("QU2_REVIS" , MODEL_FIELD_OBRIGAT, .T.)
	oStruQU2:SetProperty("QU2_DESCRI", MODEL_FIELD_OBRIGAT, .T.)

	oModel := MPFormModel():New( 'QADA220', ,{|oModel|QADA220POS(oModel)} ,{|oModel|QADA220GRV(oModel)})
	oModel:SetDescription(STR0001)	
	oModel:AddFields( 'QU2MASTER', /*cOwner*/, oStruQU2 )
	oModel:GetModel( 'QU2MASTER' ):SetDescription(STR0001)
		
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 11/08/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	LOCAL oModel   := FWLoadModel('QADA220')
	LOCAL oStruQU2 := FWFormStruct(2,'QU2',{|cCampo| !ALLTRIM(cCampo) $ "QU2_FILIAL|QU2_EFETIV"})
	LOCAL oView	
			
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_QU2', oStruQU2, 'QU2MASTER' )	
	oView:CreateHorizontalBox( 'TELA', 100 )	
	oView:SetOwnerView( 'VIEW_QU2', 'TELA' )
	
Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220ALT()
Alterar Check List
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function QADA220ALT()	
	LOCAL lRet := .T.
			
	If QU2->QU2_EFETIV == "1"
		Help("",1,"020CHKVIG") // "Check List está Vigente"
		lRet := .F.
	ElseIf QU2->QU2_EFETIV == "2"
		Help("",1,"020CHKOBS") // "Check List está Obsoleto"
		lRet := .F.
	EndIf
	
	If lRet
	    FWExecView(STR0004,'QADA220',MODEL_OPERATION_UPDATE,,{ || .T. }) // Alterar
	EndIf
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220EXC()
Excluir Check List
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function QADA220EXC()	
	LOCAL lRet    := .T.
	LOCAL aFilAud := {}
	LOCAL nOldRecSM0
	LOCAL nx
			
	If QU2->QU2_EFETIV == "1"
		Help("",1,"020CHKVIG") // "Check List está Vigente"
		RETURN .F.
	ElseIf QU2->QU2_EFETIV == "2"
		Help("",1,"020CHKOBS") // "Check List está Obsoleto"
		RETURN .F.
	EndIf
	
	// Le as Filiais
	nOldrecSM0 := SM0->(Recno())
	SM0->(dbGoTop())
	While SM0->(!Eof())
		If SM0->M0_CODIGO == cEmpAnt //Empresa Atual
			Aadd(aFilAud,FWCodFil())
		EndIf       
		SM0->(dbSkip())
	EndDo
	SM0->(dbGoTo(nOldRecSM0))
	
	// Verifica se o Check List a ser excluido esta sendo utilizado em alguma Auditoria.
	QUJ->(dbSetOrder(2))   
	If !Empty(xFilial("QUJ"))
		For nx := 1 to Len(aFilAud)
			If (QUJ->(dbSeek(aFilAud[nx]+QU2->QU2_CHKLST+QU2->QU2_REVIS)))
				lRet := .F.
			EndIf                       
		Next
	Else	
		If (QUF->(dbSeek(xFilial("QUF")+QU2->QU2_CHKLST+QU2->QU2_REVIS)))
			lRet := .F.
		EndIf
	EndIf	
					  
	If !lRet
		HELP(" ",1,"010EXISAUD")		
		RETURN .F.
	EndIf
	
	If lRet
	    FWExecView(STR0005,'QADA220',MODEL_OPERATION_DELETE,,{ || .T. }) // Excluir
	EndIf
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220POS(oModel)
Pos Valid
@author Geovani.Figueira
@since 16/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
FUNCTION QADA220POS(oModel)
	LOCAL lRet := .T.
	
	IF oModel:GetOperation() == 3 .AND. oModel:GetValue('QU2MASTER','QU2_CHKLST') == '999999'
		// "Não é possível Incluir/Copiar check-lists utilizando o código do check-list padrão: 999999"
		Help(,,'QAD220NOPAD', , STR0011,1,0)
    	lRet := .F.
	ENDIF
	
RETURN lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220GRV(oModel)
Gravacao Commit
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
FUNCTION QADA220GRV(oModel)
	LOCAL lRet      := .T.
	LOCAL nx        := 0
	LOCAL oModel225 := NIL
	
	IF oModel:GetOperation() == 3
		oModel:SetValue('QU2MASTER','QU2_EFETIV',"3")
	ENDIF
	
	IF lCopia
		// Copia a Nova Revisao dos Topicos associados ao Check List
		dbSelectArea("QU3")
		dbSetOrder(1)
		dbSeek(xFilial("QU3")+cChkLst+cOldRev)
		WHILE QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
			(QU3->QU3_CHKLST+QU3->QU3_REVIS) == (cChkLst+cOldRev)		
			
			oModel225 := FWLoadModel('QADA225')
			oModel225:SetOperation(MODEL_OPERATION_INSERT)
			oModel225:Activate()
			oModel225:LoadValue('QU3MASTER','QU3_CHKLST',oModel:GetValue('QU2MASTER','QU2_CHKLST'))
			oModel225:LoadValue('QU3MASTER','QU3_REVIS' ,oModel:GetValue('QU2MASTER','QU2_REVIS'))
			oModel225:LoadValue('QU3MASTER','QU3_ULTREV',oModel:GetValue('QU2MASTER','QU2_ULTREV'))
			oModel225:LoadValue('QU3DETAIL','QU3_CHKITE',QU3->QU3_CHKITE)
			oModel225:LoadValue('QU3DETAIL','QU3_NORMA' ,QU3->QU3_NORMA)
			oModel225:LoadValue('QU3DETAIL','QU3_DESCRI',QU3->QU3_DESCRI)
			oModel225:LoadValue('QU3DETAIL','QU3_OBSERV',QU3->QU3_OBSERV)
			FwFormCommit(oModel225)
			oModel225:DeActivate()
			
		    QU3->(dbSkip())
		ENDDO	
	
		// Copia a Nova Revisao das Questoes associadas ao Check List
		dbSelectArea("QU4")
		dbSetOrder(1)
		dbSeek(xFilial("QU4")+cChkLst+cOldRev)
		WHILE QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
			(QU4->QU4_CHKLST+QU4->QU4_REVIS) == (cChkLst+cOldRev)
			                                      
			aRegist :={}
			FOR nx := 1 TO QU4->(fCount())
				 cNomCpo := FieldName(nx)
				 Aadd(aRegist,{cNomCpo,&cNomCpo})
			NEXT nx
		    nSavRec := QU4->(Recno())
		
			// Realiza a gravacao das questoes	menos as Chaves Textos MSMM
		    RecLock("QU4",.T.)
		    FOR nx := 1 TO LEN(aRegist)
	   	    	IF !(aRegist[nx,1]$'QU4_TXTCHV.QU4_REQCHV.QU4_OBSCHV')
			        QU4->(FieldPut(FieldPos(aRegist[nx,1]),aRegist[nx,2]))
			    ENDIF
		    NEXT
		    QU4->QU4_CHKLST := oModel:GetValue('QU2MASTER','QU2_CHKLST')
		    QU4->QU4_REVIS  := oModel:GetValue('QU2MASTER','QU2_REVIS')
		    QU4->QU4_ULTREV := dDatabase
		    MsUnlock()
			FKCOMMIT()
		    
	   		// Realiza a gravacao dos novos Textos MSMM
			FOR nx := 1 TO LEN(aRegist)
				DO CASE
					CASE aRegist[nx,1]=='QU4_TXTCHV'
						IF !EMPTY(aRegist[nx,2])  //Realiza a gravacao do Texto da Questao
							MsMM(QU4_TXTCHV,,,MsMM(aRegist[nx,2]),1,,,'QU4','QU4_TXTCHV')
						ENDIF	
					CASE aRegist[nx,1]=='QU4_REQCHV'
						IF !EMPTY(aRegist[nx,2]) //Realiza a gravacao do Requisito da Questao
							MsMM(QU4_REQCHV,,,MsMM(aRegist[nx,2]),1,,,'QU4','QU4_REQCHV')
						ENDIF	
					CASE aRegist[nx,1]=='QU4_OBSCHV'				
						IF !EMPTY(aRegist[nx,2]) //Realiza a gravacao da Observacao da Questao
							MsMM(QU4_OBSCHV,,,MsMM(aRegist[nx,2]),1,,,'QU4','QU4_OBSCHV')
						ENDIF	
				ENDCASE
			NEXT    
		    
			QU4->(dbGoTo(nSavRec))		    
		    QU4->(dbSkip())
	
		ENDDO
	ENDIF
	
	lRet := FwFormCommit(oModel)
	
RETURN lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220EFE()
Efetiva
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA220EFE()
	LOCAL aAreaQU2   := QU2->(GetArea())  
	LOCAL cChkLst    := QU2->QU2_CHKLST
	LOCAL cNewChkLst := QU2->(QU2_CHKLST+QU2_REVIS)
	LOCAL lQa20Vlef  := .T.	
	LOCAL oModel     := NIL
	
	IF QU2->QU2_EFETIV == "1"
		Help("",1,"020CHKVIG") // "Check List esta Vigente"
		RETURN .F.
	ELSEIF QU2->QU2_EFETIV == "2"
		Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
		RETURN .F.
	ENDIF
	
	// Verifica se existem topicos associados ao Check List
	QU3->(dbSetOrder(1))
	QU3->(dbSeek(xFilial("QU3")+cNewChkLst))
	IF QU3->(Eof())
	   	Help("",1,"020NEXITOP")
	 	RETURN .F.
	ELSE
		WHILE QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And. (QU3->QU3_CHKLST+QU3->QU3_REVIS) == cNewChkLst			
			// Verifica se existem Questoes	associadas ao Check List
			QU4->(dbSetOrder(1))
			QU4->(dbSeek(xFilial("QU4")+QU3->QU3_CHKLST+QU3->QU3_REVIS+	QU3->QU3_CHKITE))
			IF QU4->(Eof())
	 		   	Help("",1,"QADNOQST") //"Existe Topico sem Questao associada, verifique"
			 	RETURN .F.        
			 	Exit
			ENDIF           
			QU3->(dbSkip())
		ENDDO	 	
	ENDIF
	
	// Ponto de Entrada para validar a efetivação do Check List
	IF Existblock("Qa20Vlef")
		lQa20Vlef := Execblock("Qa20Vlef",.F.,.F.,{QU2->QU2_FILIAL,QU2->QU2_CHKLST,QU2->QU2_REVIS})
		IF ValType(lQa20Vlef) == 'L' .And. !lQa20Vlef // Se retornar falso sai da função
			RETURN .F.
		ENDIF
	ENDIF               
	
	// Caso exista Topicos e questoes efetiva o CheckList
	oModel := FWLoadModel('QADA220')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oModel:LoadValue('QU2MASTER','QU2_CHKLST',cChkLst)
	oModel:LoadValue('QU2MASTER','QU2_REVIS' ,QU2->QU2_REVIS)
	oModel:LoadValue('QU2MASTER','QU2_DESCRI',QU2->QU2_DESCRI)
	oModel:LoadValue('QU2MASTER','QU2_OBSERV',QU2->QU2_OBSERV)
	oModel:LoadValue('QU2MASTER','QU2_ULTREV',QU2->QU2_ULTREV)	
	oModel:LoadValue('QU2MASTER','QU2_EFETIV','1')
	FwFormCommit(oModel)
	oModel:DeActivate()
	
	QU2->(dbSetorder(1))
	QU2->(dbSeek(xFilial("QU2")+QU2->QU2_CHKLST))
	WHILE QU2->(!Eof()) .And. (QU2->QU2_FILIAL == xFilial("QU2")) .And. (QU2->QU2_CHKLST == cChkLst) 
		IF QU2->(QU2_CHKLST+QU2_REVIS) # cNewChkLst 
			IF QU2->QU2_EFETIV # "2" 
				oModel := FWLoadModel('QADA220')
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				oModel:LoadValue('QU2MASTER','QU2_CHKLST',QU2->QU2_CHKLST)
				oModel:LoadValue('QU2MASTER','QU2_REVIS' ,QU2->QU2_REVIS)
				oModel:LoadValue('QU2MASTER','QU2_DESCRI',QU2->QU2_DESCRI)
				oModel:LoadValue('QU2MASTER','QU2_OBSERV',QU2->QU2_OBSERV)
				oModel:LoadValue('QU2MASTER','QU2_ULTREV',QU2->QU2_ULTREV)	
				oModel:LoadValue('QU2MASTER','QU2_EFETIV','2')
				FwFormCommit(oModel)				
				oModel:DeActivate()
		    ENDIF
		ENDIF
		QU2->(dbSkip())
	ENDDO
	
	RestArea(aAreaQU2)
	
RETURN .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220COP()
Copiar
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA220COP()
	LOCAL   aArea     := GetArea()
	LOCAL   lContinua := .T.
	LOCAL   oModel    := NIL
	LOCAL   oModelQU2 := NIL
	LOCAL   cNewRev   := QU2->QU2_REVIS
	PRIVATE cOldRev   := QU2->QU2_REVIS
	PRIVATE cChkLst   := QU2->QU2_CHKLST
	
	// Verifica se o Check List esta efetivado
	IF QU2->QU2_EFETIV # "1"
		Help("",1,"020CHKNEFE") 
		RETURN .F.
   	ENDIF
	
	IF cChkLst == '999999'
		Help(,,'QAD220NOPAD', , STR0011,1,0) // 'Não é possível Incluir/Copiar check-lists utilizando o código do check-list padrão: 999999',1,0,,,,,,{"Utilize outro código."}) // Não é possível Incluir/Copiar check-lists utilizando o código do check-list padrão: 999999
	    RETURN .F.
    ENDIF
	
	// Ponto de entrada para verificar se efetua ou não a cópia do checklist
	IF Existblock ("QD020CPY")
		lContinua := Execblock("QD020CPY",.F.,.F.)
	ENDIF
	
	IF lContinua
		oModel := FWLoadModel('QADA220')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModelQU2 := oModel:GetModel('QU2MASTER')
	
		oModelQU2:SetValue('QU2_CHKLST',cChkLst)
		oModelQU2:SetValue('QU2_DESCRI',QU2->QU2_DESCRI)
		oModelQU2:SetValue('QU2_OBSERV',QU2->QU2_OBSERV)
		oModelQU2:SetValue('QU2_ULTREV',DATE())
	    
		// Procura a ultima revisao do Check List
		While QU2->(!Eof()) .And. QU2->QU2_FILIAL == xFilial("QU2") .And. QU2->QU2_CHKLST == cChkLst
			QU2->(dbSkip())
		EndDo
		QU2->(dbSkip(-1))
		cNewRev := StrZero(Val(QU2->QU2_REVIS)+1,2)
		
		oModelQU2:SetValue('QU2_REVIS' ,cNewRev)
		
		lCopia := .T.
		FWExecView (STR0007, 'QADA220', 9, , { || .T. },,,,,,,oModel ) // Copiar
		lCopia := .F.
		oModel:DeActivate()
	ENDIF
	
	RestArea(aArea)	
RETURN .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} QADA220Revi()
Verifica se o codigo da Revisao e Numerico
@author Geovani.Figueira
@since 15/08/2017
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
FUNCTION QADA220Revi()
	LOCAL lRet := .T.
	
	IF IsAlpha(M->QU2_REVIS) 
	    Help("",1,"QAD010CHKC")
	    lRet := .F.	    
	ENDIF                       
	
	IF Len(Alltrim(M->QU2_REVIS)) # Len(M->QU2_REVIS)
	    Help("",1,"QAD010TAMI")
	    lRet := .F.	    
	ENDIF

RETURN lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} QA220Dupl()
Realiza a duplicacao de um Check List
@author Luiz Henrique Bourscheid
@since 06/07/2018
@version 1.0
@return 
/*/
//--------------------------------------------------------------------
Function QA220Dupl()
Local cNewChkLst
Local cNewRevChk
Local cOldChkLst
Local cOldRevChk     
Local aRegist 
Local cNomCpo 
Local nSavRec
Local cMessage
Local nX		:= 1   
Local cPerg     := "QAD020    "
Local lContinua := .T.

If QU2->QU2_EFETIV == "2"
	Help("",1,"020CHKOBS") // "Check List esta Obsoleto"
	Return(NIL)
Endif

If !QA20CkPd("QU2") // Verifica se está duplicando o check-list padrão
	Return Nil
EndIf

IF Pergunte(cPerg,.T.)
	cNewChkLst:=MV_PAR01
	cNewRevChk:=MV_PAR02
    nSavRec   := QU2->(Recno())
	QU2->(DBSetOrder(1))
   	IF QU2->(DbSeek(xFilial("QU2")+cNewChkLst+cNewRevChk))
   	   Help("",1, "EXISTCHK" )
   	   QU2->(dbGoTo(nSavRec))		    
       Return(NIL)             
	Endif                        
	QU2->(dbGoTo(nSavRec))		                               
Else
    Return(NIL)
Endif

If Existblock ("QD020DUP")
	lContinua := Execblock("QD020DUP",.F.,.F.,{cNewChkLst,cNewRevChk})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica retorno do Ponto de Entrada 	           		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Copia a Revisao do Check List							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QU2")            
	cOldChkLst := QU2->QU2_CHKLST
	cOldRevChk := QU2->QU2_REVIS

	aRegist := {}
	For nX := 1 to QU2->(fCount())
		cNomCpo := FieldName(nX)
		Aadd(aRegist,{cNomCpo,&cNomCpo})
	Next nX

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a gravacao do Novo Check com a nova Revisao			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("QU2",.T.)
	For nX := 1 To Len(aRegist)
		QU2->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
	Next
	QU2->QU2_CHKLST	:= cNewChkLst
	QU2->QU2_REVIS  := cNewRevChk
	QU2->QU2_ULTREV := dDatabase
	QU2->QU2_EFETIV := "3"
	MsUnlock()
	FKCOMMIT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Copia a Nova Revisao dos Topicos associados ao Check List     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QU3")
	dbSetOrder(1)
	dbSeek(xFilial("QU3")+cOldChkLst+cOldRevChk)
	While QU3->(!Eof()) .And. QU3->QU3_FILIAL == xFilial("QU3") .And.;
		(QU3->QU3_CHKLST+QU3->QU3_REVIS) == (cOldChkLst+cOldRevChk)
	
		aRegist := {}
		For nX := 1 to QU3->(fCount())
			cNomCpo := FieldName(nX)
			Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
		nSavRec := QU3->(Recno())
	
		//Realiza a gravacao dos Topicos
		RecLock("QU3",.T.)
		For nX := 1 To Len(aRegist)
			QU3->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
		Next
		QU3->QU3_CHKLST	:= cNewChkLst
		QU3->QU3_REVIS  := cNewRevChk
		QU3->QU3_ULTREV := dDatabase
		MsUnlock()
		FKCOMMIT()
	
		QU3->(dbGoTo(nSavRec))
		QU3->(dbSkip())
	
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Copia a Nova Revisao das Questoes associadas ao Check List    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QU4")
	dbSetOrder(1)
	dbSeek(xFilial("QU4")+cOldChkLst+cOldRevChk)
	While QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") .And.;
		(QU4->QU4_CHKLST+QU4->QU4_REVIS) == (cOldChkLst+cOldRevChk)
	
		aRegist :={}
		For nX := 1 to QU4->(fCount())
			cNomCpo := FieldName(nX)
			Aadd(aRegist,{cNomCpo,&cNomCpo})
		Next nX
		nSavRec := QU4->(Recno())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a gravacao das questoes	menos as Chaves Textos MSMM  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("QU4",.T.)
		For nX := 1 To Len(aRegist)
			IF !(aRegist[nX,1]$'QU4_TXTCHV.QU4_REQCHV.QU4_OBSCHV')
				QU4->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
			Endif
		Next
		QU4->QU4_CHKLST	:= cNewChkLst
		QU4->QU4_REVIS  := cNewRevChk
		QU4->QU4_ULTREV := dDatabase
		MsUnlock()
		FKCOMMIT()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a gravacao dos novos Textos MSMM	 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aRegist)
			DO CASE
				CASE aRegist[nX,1]=='QU4_TXTCHV'
					//Realiza a gravacao do Texto da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_TXTCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_TXTCHV')
					Endif
				CASE aRegist[nX,1]=='QU4_REQCHV'
					//Realiza a gravacao do Requisito da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_REQCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_REQCHV')
					Endif
				CASE aRegist[nX,1]=='QU4_OBSCHV'
					//Realiza a gravacao da Observacao da Questao
					IF !EMPTY(aRegist[nX,2])
						MsMM(QU4_OBSCHV,,,MsMM(aRegist[nX,2]),1,,,'QU4','QU4_OBSCHV')
					Endif
			EndCASE
		Next
	
		QU4->(dbGoTo(nSavRec))
		QU4->(dbSkip())
	
	EndDo
	End Transaction

	cMessage := STR0013+AllTrim(cNewChkLst)+STR0014+cNewRevChk //"Foi gerado o Check List "###" com a Revisao "
	MsgAlert(cMessage)

Endif

Return(NIL)