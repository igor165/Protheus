#INCLUDE "QADA201.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
 
//-----------------------------------------------------------------------
/*/{Protheus.doc} QADA201
Agendamento de auditoria
@author Leonardo Bratti
@since 20/07/2017
@version 1.0
@return NIL
/*/
//-----------------------------------------------------------------------
Function QADA201()

	Local aArea   := GetArea()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QUA")
	oBrowse:SetDescription(STR0001)
	oBrowse:AddLegend('QUA->QUA_STATUS == "1"', 'ENABLE', STR0002)
 	oBrowse:AddLegend('QUA->QUA_STATUS == "2"','DISABLE', STR0003)
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0004      ACTION 'PesqBrw'         OPERATION 1                      ACCESS 0
	ADD OPTION aRotina TITLE STR0005      ACTION 'Q201Visu'        OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE STR0006      ACTION 'VIEWDEF.QADA201' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE STR0007      ACTION 'QAD201Alte'      OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE STR0008      ACTION 'Q201Excl'        OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina TITLE STR0009      ACTION 'Q201Efet '       OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruQUA := FWFormStruct(1,"QUA") 
	Local oStruQUM := FWFormStruct(1,"QUM") 
	Local oModel := Nil	
	Local nX
	
	oStruQUA:SetProperty( 'QUA_STATUS' , MODEL_FIELD_INIT,{|| '1'})
	
	// Alterações de dicionário necessárias para que a tela normal e a MVC rodem ao mesmo tempo.
	oStruQUA:SetProperty("QUA_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUA", "QUA_FILMAT", "QVldUsuQUA()",.F.,.F. ))
	oStruQUA:SetProperty("QUA_CODFOR" , MODEL_FIELD_VALID, MTBlcVld("QUA", "QUA_CODFOR", "Q201VldCpo()",.F.,.F. ))
	oStruQUA:SetProperty("QUA_LOJA"   , MODEL_FIELD_VALID, MTBlcVld("QUA", "QUA_LOJA"  , "Q201VldCpo()",.F.,.F. ))
	oStruQUA:SetProperty("QUA_MAT"    , MODEL_FIELD_VALID, MTBlcVld("QUA", "QUA_MAT"   , "QNCAUTUSR(M->QUA_FILMAT,M->QUA_MAT).And. QVldUsuQUA()",.F.,.F. ))
	oStruQUA:SetProperty("QUA_FILMAT" , MODEL_FIELD_INIT , {|| xFilial('QAA')})
	
	oStruQUM:SetProperty("QUM_NOMAUD" , MODEL_FIELD_INIT , {|| InNmQUM()})
	oStruQUM:SetProperty("QUM_SEQ"    , MODEL_FIELD_INIT , Nil)
	oStruQUM:SetProperty("QUM_FILMAT" , MODEL_FIELD_INIT , {|| xFilial('QAA')})
	
	oStruQUM:SetProperty("QUM_FILMAT" , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_FILMAT", "QVldUsuQUM()",.F.,.F. ))
	oStruQUM:SetProperty("QUM_CODAUD" , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_CODAUD", "QDATUSR().AND. QVldUsuQUM()",.F.,.F. ))
	oStruQUM:SetProperty("QUM_DTIN"   , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_DTIN"  , "QVldDH('DTIN', M->QUM_DTIN)",.F.,.F. ))
	oStruQUM:SetProperty("QUM_HRIN"   , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_HRIN"  , "QVldDH('HRIN', M->QUM_HRIN)",.F.,.F. ))
	oStruQUM:SetProperty("QUM_DTFI"   , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_DTFI"  , "QVldDH('DTFI', M->QUM_DTFI)",.F.,.F. ))
	oStruQUM:SetProperty("QUM_HRFI"   , MODEL_FIELD_VALID, MTBlcVld("QUM", "QUM_HRFI"  , "QVldDH('HRFI', M->QUM_HRFI)",.F.,.F. ))
	//-----------------------------
	
	oModel := MPFormModel():New( 'QADA201', , ,{|oModel| Q201GRV(oModel)})	
	
	oModel:AddFields( 'QUAMASTER', /*cOwner*/, oStruQUA )
	oModel:AddGrid( 'QUMDETAIL'  ,'QUAMASTER', oStruQUM , , {|| Q201LNOK()} )
	oModel:SetPrimaryKey( {} ) 
	oModel:SetRelation("QUMDETAIL",{{"QUM_FILIAL",'xFilial("QUM")'},{"QUM_NUMAUD","QUA_NUMAUD"}},QUM->(IndexKey(1)))
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'QUAMASTER' ):SetDescription(STR0010)
	oModel:GetModel( 'QUMDETAIL' ):SetDescription(STR0011)		
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'QADA201' )
	Local oStruQUA := FWFormStruct( 2, 'QUA' )
	Local oStruQUM := FWFormStruct( 2, 'QUM' )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_QUA', oStruQUA, 'QUAMASTER' )
	oView:AddGrid( 'VIEW_QUM', oStruQum, 'QUMDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 35 )
	oView:CreateHorizontalBox( 'INFERIOR', 65 )
	
	oView:SetOwnerView( 'VIEW_QUA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_QUM', 'INFERIOR' )
	
	oView:AddIncrementField( 'VIEW_QUM', 'QUM_SEQ' )
	oStruQUA:RemoveField("QUA_STATUS") 
	oStruQUM:RemoveField("QUM_NUMAUD")

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} InNmQUM()
Inicialiazador padrao para o campo vitual QUM_NOMAUD 
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function InNmQUM()
	Local oModel := FWModelActive()
	If ValType(oModel) == 'O' .And. (oModel:GetModel('QUMDETAIL'):length() > 0)
		Return Posicione("QAA",1,xFilial("QAA")+oModel:GetValue('QUMDETAIL','QUM_CODAUD'),"QAA_NOME")
	EndIf
Return " "

//----------------------------------------------------------------------
/*/{Protheus.doc} Q201VldCpo()
Verifica se o conteudo do campo QUA_CODFOR esta cadastrado na tabela SA2. 
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function Q201VldCpo()
	Local lRet      := .T.
	Local aAreaAnt  := GetArea()
	Local aAreaSA2  := SA2->(GetArea())
	Local cCampo    := ReadVar()
	Local cChave    := ""
	Local oModel    := FWModelActive()
	Local oModelQUA := oModel:GetModel("QUAMASTER")
	
	If cCampo == "M->QUA_CODFOR" .And. ValType(oModelQUA) == 'O' 
		cChave := &(ReadVar())
	    If !(Empty(oModelQUA:GetValue('QUA_LOJA')))
	        cChave += oModelQUA:GetValue('QUA_LOJA')
	    EndIf
	ElseIf cCampo == "M->QUA_LOJA" .And. ValType(oModelQUA) == 'O' 
	    If !(Empty(oModelQUA:GetValue("QUA_CODFOR")))
	        cChave += oModelQUA:GetValue("QUA_CODFOR")+&(ReadVar())
	    EndIf
	EndIf
	
	lRet := ExistCpo("SA2",cChave)
	
	RestArea(aAreaSA2)
	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} QDATUSR()
Valida se o Usuario recebera Pendencias de FNC e/ou Acoes 
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QDATUSR()
	Local lRet    := .F.
	Local cFilMat := ""
	Local oModel  := FWModelActive()
	
	If ValType(oModel) == 'O' .And. (oModel:GetModel('QUMDETAIL'):length() > 0)
		DbSelectArea("QAA")
		QAA->(dbSetOrder(1))
		cFilMat:= oModel:GetValue('QUMDETAIL','QUM_FILMAT')
		IF QAA->(dbSeek(IIF(!(Empty(cFilMat)),cFilMat,xFilial("QAA"))+oModel:GetValue('QUMDETAIL','QUM_CODAUD') )) .And. QAA->QAA_RECFNC == "S"
			lRet := .T.
		Else
			Help(" ",1,"QNCNAUTUSR") 
		EndIf 
	Endif	
Return(lRet)

//----------------------------------------------------------------------
/*/{Protheus.doc} QVldUsuQUA()
Validacao da filial/codigo do Auditor lider/alocado QUA	
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldUsuQUA()
	Local oModel := FWModelActive()
	Local oModelQUA:= oModel:GetModel('QUAMASTER')
	Local lRetorno := .T.
	Local cFilMat  := oModelQUA:GetValue('QUA_FILMAT')
	Local cCodMat  := oModelQUA:GetValue('QUA_MAT')
	Local cCampo    := ReadVar()
	
	If !Empty(cFilMat) .And. !Empty(cCodMat)                                       		
		lRetorno := QA_ChkMat(cFilMat,cCodMat)
		IF lRetorno
		   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
		   IF !lRetorno
		   		Help( , , 'Help', ,STR0012, 1, 0 ) 
		   Endif		
		Endif
	EndIf
Return(lRetorno)
//----------------------------------------------------------------------
/*/{Protheus.doc} QVldUsuQUM()
Validacao da filial/codigo do Auditor lider/alocado QUM
@author Leonardo Bratti
@since 21/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function QVldUsuQUM()
	Local oModel := FWModelActive()
	Local oModelQUM:= oModel:GetModel('QUMDETAIL')
	Local lRetorno := .T.
	Local cFilMat  := oModelQUM:GetValue('QUM_FILMAT')
	Local cCodMat  := oModelQUM:GetValue('QUM_CODAUD')
	Local cCampo    := ReadVar()
	
	If !Empty(cFilMat) .And. !Empty(cCodMat)                                       		
		lRetorno := QA_ChkMat(cFilMat,cCodMat)
		IF lRetorno
		   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
		   IF !lRetorno
		   		Help( , , 'Help', ,STR0012, 1, 0 ) 
		   Endif		
		Endif
	EndIf
Return(lRetorno)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q201LNOK()
Validação de linha da grid
@author Leonardo Bratti
@since 24/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function Q201LNOK()
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local oModelQUM := oModel:GetModel('QUMDETAIL')
	Local oModelQUA := oModel:GetModel('QUAMASTER')
	Local lAudDep	:= SuperGetMV("MV_QADDEP",.T.,.F.)
	
	If lAudDep
		QAA->(dbSetOrder(1))
		If QAA->(DBSeek(oModelQUM:GetValue('QUM_FILMAT') + oModelQUM:GetValue('QUM_CODAUD')))
			If QAA->QAA_CC == oModelQUM:GetValue('QUM_CCUSTO')
					Help( , , "Help" , , STR0013 ,1,0)
					lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
	lRet := QA201VLDPR()
	EndIf

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} QA201VLDPR()
Valida os períodos por auditor
@author Leonardo Bratti
@since 24/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function QA201VLDPR()
	Local lRet      := .T.
	Local nDataHora := 0
	Local nDataHora2:= 0
	Local oModel    := FWModelActive()
	Local oModelQUM := oModel:GetModel('QUMDETAIL')
	Local dIniAud   := Ctod("  /  /  ")
	Local dFimAud   := Ctod("  /  /  ") 
	Local dDTIn     := Ctod("  /  /  ")
	Local cHRIn     := ''
	Local dDTFim    := Ctod("  /  /  ")
	Local cHRFim    := ''	
	Local cDept     := ''
	Local nI        := ''
	Local nPosGrid  := 0
	Local aSaveLines := FWSaveRows()	
	
	nPosGrid := oModelQUM:GetLine()
	dDTIn    := oModelQUM:GetValue('QUM_DTIN') 
	cHRIn    := oModelQUM:GetValue('QUM_HRIN') 
	dDTFim   := oModelQUM:GetValue('QUM_DTFI') 
	cHRFim   := oModelQUM:GetValue('QUM_HRFI') 
	cAud     := oModelQUM:GetValue('QUM_CODAUD') 
	cSeq     := oModelQUM:GetValue('QUM_SEQ') 
	cDept	  := oModelQUM:GetValue('QUM_CCUSTO')				
	
	For nI := 1 To oModelQUM:Length()
		oModelQUM:GoLine( nI )
		If !(oModelQUM:IsDeleted())
			If oModelQUM:GetValue('QUM_CODAUD') == cAud
				If nI >= nPosGrid
					nDataHora := SubtHoras(  oModelQUM:GetValue('QUM_DTIN') , oModelQUM:GetValue('QUM_HRIN'),dDTFim ,cHRFim )
					If nDataHora < 0 
						Help("",1,"Q_PERJAUTI") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
						lRet := .F.
			 			Exit
	        		EndIf 
				ElseIf nPosGrid >= nI
						nDataHora  := SubtHoras( oModelQUM:GetValue('QUM_DTFI') , oModelQUM:GetValue('QUM_HRFI') , dDTIn , cHRIn )
						nDataHora2 := SubtHoras( dDTFim, cHRFim,  oModelQUM:GetValue('QUM_DTIN') , oModelQUM:GetValue('QUM_HRIN') )
						If nDataHora < 0 
							Help("",1,"Q_PERJAUTI") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
							lRet := .F.
				 			Exit
	        			EndIf 
	        	Endif	
			EndIf			
		EndIf
	Next nI	
	FWRestRows( aSaveLines )
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} Q201GRV()
Função de gravação da agenda de auditoria
@author Leonardo Bratti
@since 24/07/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function  Q201GRV(oModel)
	Local oFieldQUA := oModel:GetModel("QUAMASTER")
	Local oGridQUM	:= oModel:GetModel("QUMDETAIL")
	Local aAgeUsu	:= {}
	Local cMail		:= ""
	Local nI		:= 0
	Local nOperation := oModel:GetOperation()
	
	FwFormCommit(oModel)
	
	If nOperation <>  MODEL_OPERATION_DELETE	
		cMail := AllTrim(Posicione("QAA", 1, oFieldQUA:GetValue("QUA_FILMAT")+oFieldQUA:GetValue("QUA_MAT"),"QAA_EMAIL"))	
		If !Empty(cMail)
			Aadd(aAgeUsu,{"L",oFieldQUA:GetValue("QUA_FILMAT"),oFieldQUA:GetValue("QUA_MAT"),cMail})
		Endif		
		For nI:=1 to oGridQUM:Length()
			oGridQUM:GoLine( nI )
			If !oGridQUM:IsDeleted()
			   If !Empty(oGridQUM:GetValue("QUM_EMAIL"))
					Aadd(aAgeUsu,{"A",oGridQUM:GetValue("QUM_FILMAT"),oGridQUM:GetValue("QUM_CODAUD"),oGridQUM:GetValue("QUM_EMAIL")})
				EndIf
			EndIf
		Next nI		
		Q201EnvMail(aAgeUsu ,oModel)
	EndIF
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} Q201EnvMail()
Envia email para os envolvidos na auditoria
@author Leonardo Bratti
@since 25/07/2017
@version 1.0
@return .T.
/*/
//--------------------------------------------------------------------
Static Function Q201EnvMail(aAgeUsu ,oModel)
	Local lMvQadeag := If( SuperGetMv("MV_QADENAG",.F.,"1")=="1" ,.T.,.F. )
	Local cMvQadTMai:= GetMv("MV_QADTMAI",.F.,"1")
	Local cTpMail   := ""
	Local nI		  := 0
	Local aUsrMat	:= QA_USUARIO()
	Local cMatFil  := aUsrMat[2]
	Local cMatCod  := aUsrMat[3]
	Local cMatDep  := aUsrMat[4]	
	
	Default aAgeUsu	:= {}   	
	
	If cMvQadTMai == "1"
		cTpMail:= "1" // HTML
	Else
		cTpMail:= "2" // TEXTO
	EndIf
	
	IF lMvQadeag
		For nI := 1 to Len(aAgeUsu)
			If cTpMail == "1"
				cMsg:= '<HTML>'
				cMsg+= '  <TITLE>SIGAQAD</TITLE>'
				cMsg+= '<BODY>'
				
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
				cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
				cMsg+= '    <P align=center><FONT face="Courier New" color=#ffffff size=4>'
				cMsg+= '    <B>'+OemToAnsi("MENSAGEM")+'</B></FONT></P></TD></TR>' // "MENSAGEM"
				
				cMsg+= '  <TR><TD align=left width=606 height=32>'
				If !Empty(AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3])))
					cMsg+= '    <P align=Center>'+OemToAnsi(STR0014)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0015)+' '+Dtoc(QUA->QUA_ALOC)+'</P></TD></TR>'  
					cMsg+= '</TABLE><BR>'
				Else 
					cMsg+= '    <P align=Center>'+OemToAnsi(STR0015)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0015)+' '+Dtoc(QUA->QUA_ALOC)+'</P></TD></TR>'  
					cMsg+= '</TABLE><BR>'
				EndIf
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
				cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
				cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0017)+'</b></font></P></TD></TR>' 
				cMsg+= '</TABLE>'
				
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD align=left width=50% height=32><b>'+RetTitle("QUA_NUMAUD")+'</b><br>'+QUA->QUA_NUMAUD+'</TD>' // Auditoria
				cMsg+= '    <TD align=left width=50% height=32><B>' +RetTitle("QUA_ALOC")+'</B><br>'+Dtoc(QUA->QUA_ALOC)+'</TD></TR>' // Alocacao
				cMsg+= '</TABLE>'
				
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '    <TD align=left width=50% height=32><b>'+RetTitle("QUA_TIPAUD")+'</b><BR>'+QADCBox("QUA_TIPAUD", QUA->QUA_TIPAUD)+'</TD>' // Tipo
				cMsg+= '    <TD align=left width=50% height=32><b>'+RetTitle("QUA_SITUAC")+'</b><BR>'+QADCBox("QUA_SITUAC",QUA->QUA_SITUAC)+'</TD></TR>' // Situacao
				cMsg+= '</TABLE>'
				
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi(STR0018)+'</b><br>'+AllTrim(QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT))+'</TD>'//"Auditor Lider"
				cMsg+= '  </TR>'
				cMsg+= '</TABLE>'
				
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD align=left width=100% height=32><b>'+RetTitle("QUA_DESCRI")+'</b><br>'+AllTrim(QUA->QUA_DESCRI)+'</TD>' // Descricao
				cMsg+= '  </TR>'
				cMsg+= '</TABLE>'
				
				If !Empty(QUA->QUA_CODFOR)
					cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
					cMsg+= '  <TR><TD align=left width=86 height=32><b>'+RetTitle("QUA_CODFOR")+'</b><br>'+QUA->QUA_CODFOR+'</TD>' // Fornecedor
					cMsg+= '    <TD align=left width=543 height=32><b>'+OemToAnsi(STR0019)+'</b><br>'+Posicione("SA2",1,xFilial("SA2")+QUA->QUA_CODFOR,"A2_NOME")+'</TD></TR>' //"Razao Social"
					cMsg+= '</TABLE>'
				EndIf
				
				cMsg+= '<p>'+OemToAnsi(STR0019)+'<p>' //"Em breve, será enviado email de confirmação, juntamente com mais detalhes sobre a auditoria"
				cMsg+= '<p>'+OemToAnsi(STR0021) //"Atenciosamente"
				cMsg+= '<BR>'+QA_NUSR(cMatFil,cMatCod)
				cMsg+= '<BR>'+QA_NDEPT(cMatDep,.t.,cMatFil)
				cMsg+= '<BR></p>'
				
				cMsg+= '<p><FONT size=2><EM>'+OemToAnsi(STR0022)+'</EM></FONT></p>' // Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias//"Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
				cMsg+= '</BODY>'
				cMsg+= '</HTML>'
			Else
				cMsg:= OemToAnsi(STR0014)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0016)+' '+Dtoc(QUA->QUA_ALOC)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Agendamento previo de Auditoria para"//"na data"
				cMsg+= OemToAnsi(STR0017)+CHR(13)+CHR(10) //"AGENDAMENTO DE AUDITORIA"
				cMsg+= RetTitle("QUA_NUMAUD")+': '+QUA->QUA_NUMAUD+CHR(13)+CHR(10) // Auditoria
				cMsg+= RetTitle("QUA_ALOC")+': '+Dtoc(QUA->QUA_ALOC)+CHR(13)+CHR(10) // Alocacao
				cMsg+= RetTitle("QUA_TIPAUD")+': '+QADCBox("QUA_TIPAUD", QUA->QUA_TIPAUD)+CHR(13)+CHR(10) // Tipo
				cMsg+= RetTitle("QUA_SITUAC")+': '+QADCBox("QUA_SITUAC",QUA->QUA_SITUAC)+CHR(13)+CHR(10) // Situacao
				cMsg+= 'Auditor Lider'+': '+AllTrim(QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT))+CHR(13)+CHR(10) //"Auditor Lider"
				cMsg+= RetTitle("QUA_DESCRI")+': '+AllTrim(QUA->QUA_DESCRI)+CHR(13)+CHR(10) // Descricao
				If !Empty(QUA->QUA_CODFOR)
					cMsg+= RetTitle("QUA_CODFOR")+': '+QUA->QUA_CODFOR+CHR(13)+CHR(10) // Fornecedor
					cMsg+= OemToAnsi(STR0019)+': '+Posicione("SA2",1,xFilial("SA2")+QUA->QUA_CODFOR,"A2_NOME")+CHR(13)+CHR(10) //"Razao Social"
				EndIf
				cMsg+= CHR(13)+CHR(10)
				cMsg+= OemToAnsi(STR0020)+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Em breve, será enviado email de confirmação, juntamente com mais detalhes sobre a auditoria"
				cMsg+= OemToAnsi(STR0021)+CHR(13)+CHR(10) //"Atenciosamente"
				cMsg+= QA_NUSR(cMatFil,cMatCod)+CHR(13)+CHR(10)
				cMsg+= QA_NDEPT(cMatDep,.t.,cMatFil)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMsg+= OemToAnsi(STR0022) // Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias//"Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
			EndIf
	
			//Ponto de entrada para personalizar a mensagem do e-mail antes do envio		
			If ExistBlock("QAD201EN")
				cMsg := ExecBlock( "QAD201EN", .f., .f., {cMsg,aAgeUsu[nI,3]}) 
			EndIF
	
			QAudEnvMail({{aAgeUsu[nI,4],OemToAnsi(STR0023)+ dtoc(QUA->QUA_ALOC), cMsg, ""}},,,,,"2") //"Auditoria Marcada para "
		Next	
	Endif

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} Q201Efet()
Efetiva a Agenda para Auditoria.
@author Leonardo Bratti
@since 25/07/2017
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function Q201Efet()
	Local lRet	:= .T.
	Local aUsrMat	:= QA_USUARIO()
	
	//-- Verifica se a Agenda nao encontra-se efetivada.
	If QUA->QUA_STATUS == "2" 
		Help(" ",1,"QAD150EFET") //-- "Nao sera possivel a manutencao para" ### "Agenda Efetivada."
		lRet	:= .F. 
	EndIf
	
	If aUsrMat[3] <> QUA->QUA_MAT
		Help("",1,"QADNAUDIT") //-- "Usuario nao tem permissao para efetivar" ### "esta Agenda."
		lRet	:= .F.
	EndIf
	
	If lRet
		QUB->(DbSetOrder(1))
		If !QUB->(DbSeek(xFilial("QUB")+QUA->QUA_NUMAUD))
			RecLock("QUB",.T.)
			QUB->QUB_FILIAL:= QUA->QUA_FILIAL
			QUB->QUB_NUMAUD:= QUA->QUA_NUMAUD
			QUB->QUB_MOTAUD:= QUA->QUA_MOTAUD
			QUB->QUB_TIPAUD:= QUA->QUA_TIPAUD
			QUB->QUB_REFAUD:= dDataBase
			QUB->QUB_INIAUD:= QUA->QUA_ALOC
			QUB->QUB_ENCAUD:= QUA->QUA_ALOCFI
			QUB->QUB_FILMAT:= QUA->QUA_FILMAT
			QUB->QUB_AUDLID:= QUA->QUA_MAT
			QUB->QUB_CODFOR:= QUA->QUA_CODFOR
			QUB->QUB_LOJA  := QUA->QUA_LOJA
			QUB->QUB_STATUS:= "1"
			QUB->QUB_PONPOS:= CRIAVAR("QUB->QUB_PONPOS")
			MsUnlock()
			
			RecLock("QUA",.F.)	
			QUA->QUA_STATUS:= "2"
			MsUnlock()
			FKCOMMIT()
			
			QUM->(DbSetOrder(1))
			If QUM->(DbSeek(xFilial("QUM")+QUA->QUA_NUMAUD))
				While QUM->(!Eof()) .And. xFilial("QUM")+QUA->QUA_NUMAUD == QUM->QUM_FILIAL+QUM->QUM_NUMAUD
					RecLock("QUH",.T.)
					QUH->QUH_FILIAL := QUA->QUA_FILIAL
					QUH->QUH_NUMAUD := QUA->QUA_NUMAUD
					QUH->QUH_SEQ    := QUM->QUM_SEQ
					QUH->QUH_CCUSTO := QUM->QUM_CCUSTO
					QUH->QUH_DESTIN := QUM->QUM_DESTIN
					QUH->QUH_EMAIL  := QUM->QUM_EMAIL				
					QUH->QUH_FILMAT := QUM->QUM_FILMAT
					QUH->QUH_CODAUD := QUM->QUM_CODAUD			
					QUH->QUH_DTIN := QUM->QUM_DTIN
					QUH->QUH_DTFI := QUM->QUM_DTFI
					QUH->QUH_HRIN := QUM->QUM_HRIN
					QUH->QUH_HRFI := QUM->QUM_HRFI
					MsUnlock()
					FKCOMMIT()
					QUM->(dbSkip())
				EndDo
			EndIf
		Else
			Help("",1,"AUDJAEXIST") // "Auditoria ja existe."
			lRet	:= .F.
		EndIf
	EndIf
	
	If lRet
		Aviso('',STR0024,{'Ok'}) //"Auditoria efetivada com sucesso!//"Auditoria efetivada com sucesso!"	
	EndIf	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Q201Excl()
Executa ExecView do Q201Excl com botão de excluir
@author Leonardo Bratti
@since 11/01/2017
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function Q201Excl()

Local lRet := .T.
Local aUsrMat	:= QA_USUARIO() 

If SuperGetMv("MV_AUDSLID", .T., .F.) .And. QUA->QUA_MAT <> aUsrMat[3]
	Help("",1,"QADNAUDIT") // "Usuario nao tem permissao para visualizar" ### "ou efetuar manutencao neste agendamento de Auditoria"
	lRet:= .F.
Endif 

If QUA->QUA_STATUS == "2"
	Help(" ",1,"QAD150EFET") // "Nao sera possivel a manutencao para" ### "Agenda Efetivada."
	lRet	:= .F.
EndIf

If lRet
	FWExecView(STR0008, "QADA201", MODEL_OPERATION_DELETE)
EndIf

Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Q201Visu()
Executa ExecView do Q201Visu com botão de visualizacao
@author Leonardo Bratti
@since 25/07/2017
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function Q201Visu()
	Local lRet := .T.
	Local aUsrMat	:= QA_USUARIO() 
	
	If SuperGetMv("MV_AUDSLID", .T., .F.) .And. QUA->QUA_MAT <> aUsrMat[3]
		Help("",1,"QADNAUDIT") // "Usuario nao tem permissao para visualizar" ### "ou efetuar manutencao neste agendamento de Auditoria"
		lRet:= .F.
	Endif 
	
	If lRet
		FWExecView (STR0005, "QADA201", MODEL_OPERATION_VIEW) 
	Endif
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Q201Alte()
Executa ExecView do QADA201 com botão de alterar
@author Leonardo Bratti
@since 25/07/2017
@version 1.0
@return NIL
/*/
//--------------------------------------------------------------------
Function QAD201Alte()
	Local lRet := .T.
	Local aUsrMat	:= QA_USUARIO() 
	
	If SuperGetMv("MV_AUDSLID", .T., .F.) .And. QUA->QUA_MAT <> aUsrMat[3]
		Help("",1,"QADNAUDIT") // "Usuario nao tem permissao para visualizar" ### "ou efetuar manutencao neste agendamento de Auditoria"
		lRet:= .F.
	Endif 
	If QUA->QUA_STATUS == "2"
		Help(" ",1,"QAD150EFET") // "Nao sera possivel a manutencao para" ### "Agenda Efetivada."
		lRet	:= .F.
	EndIf
	If lRet
		FWExecView (STR0007, "QADA201", MODEL_OPERATION_UPDATE) 
	EndIf
Return lRet
	
