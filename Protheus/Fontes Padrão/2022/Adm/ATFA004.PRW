#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA004.CH"

//FNM_FILIAL+FNM_IDMOV
//FNM_FILIAL+FNM_ROTINA+FNM_REVIS+FNM_OPER+DTOS(FNM_DATA)+FNM_IDMOV
//FNM_FILIAL+DTOS(FNM_DATA)+FNM_ROTINA+FNM_OPER+FNM_REVIS+FNM_IDMOV
//FNM_FILIAL+FNM_CODSOL+FNM_ROTINA+FNM_OPER+FNM_REVIS+DTOS(FNM_DATA)+FNM_IDMOV
//FNM_FILIAL+FNM_CODAPR+FNM_ROTINA+FNM_OPER+FNM_REVIS+DTOS(FNM_DATA)+FNM_IDMOV

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA004     บAutor  ณRenan Guedes      บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de opera็๕es com controle de aprova็ใo             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA004()

Local oBrowse
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aAreaFNM		:= {}
Local cCadastro		:= STR0001		//"Movimentos de aprova็ใo e hist๓ricos de altera็๕es"
Local cCodUsr		:= RetCodUsr()		//C๓digo do usuแrio ativo

If lRet
	dbSelectArea("FNM")
	aAreaFNM := FNM->(GetArea())
	FNM->(dbSetOrder(1))		//FNM_FILIAL+FNM_IDMOV

	oBrowse := FWMBrowse():New() 
	oBrowse:SetAlias("FNM")
	oBrowse:SetDescription(cCadastro) 			//Descri็ใo do browse
	//Adicona legenda ao browse
	oBrowse:AddLegend( "FNM_STATUS == '1'", "BLUE"		, STR0007	)		//"Pendente"
	oBrowse:AddLegend( "FNM_STATUS == '2'", "GREEN"		, STR0008	)		//"Aprovado"
	oBrowse:AddLegend( "FNM_STATUS == '3'", "RED"		, STR0009	)		//"Reprovado"
	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "FNM_CODSOL == '" + cCodUsr + "' .Or. FNM_CODAPR == '" + cCodUsr + "'"	) 
	//Desliga a exibi็ใo dos detalhes
	//oBrowse:DisableDetails()
	oBrowse:Activate() 
	
	RestArea(aAreaFNM)
EndIf

RestArea(aArea)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMENUDEF   บAutor  ณRenan Guedes        บ Data ณ  11/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef() 

Local aRotina := {} 
 
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.ATFA004' 	OPERATION 2	ACCESS 0 		//"Visualizar"
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.ATFA004'	OPERATION 4	ACCESS 0 		//"Aprovar/Rejeitar"

Return aRotina 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA002   บAutor  ณRenan Guedes        บ Data ณ  12/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณModelo de dados do cadastro de opera็๕es com controle de    บฑฑ
ฑฑบ          ณaprova็ใo                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef() 

Local oStruFNM		:= FWFormStruct( 1, 'FNM' ) 
Local oModel		// Modelo de dados que serแ construํdo 

oModel := MPFormModel():New( 'ATFA004',/*bPreValidacao*/, { |oModel| AF004PosVld(oModel) } )
//Antiga enchoice
oModel:AddFields( 'FNMMASTER', /*cOwner*/, oStruFNM )
//Descri็ใo do modelo
oModel:SetDescription( STR0004 ) 		//"Modelo de dados dos movimentos de aprova็ใo e hist๓ricos de altera็๕es"
//Valida็ใo de ativa็ใo do modelo
oModel:SetVldActivate( { |oModel| AF004VldAct(oModel) } )

Return oModel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF004VldAct   บAutor  ณRenan Guedes    บ Data ณ  12/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo da ativa็ใo do modelo - valida antes de qualquer  บฑฑ
ฑฑบ          ณa็ใo que ative o modelo de dados                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF004VldAct(oModel)

Local lRet			:= .T.
Local nOperation 	:= oModel:GetOperation()
Local cCodUsr		:= RetCodUsr()		//C๓digo do usuแrio ativo

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE) .And. (FNM->FNM_CODAPR != cCodUsr)
	lRet := .F.
	Help(" ",1,"AFA004NAPR")		//"Usuแrio sem permissใo para aprovar/rejeitar o movimento de aprova็ใo."##"Somente o usuแrio aprovador poderแ aprovar/rejeitar o movimento de aprova็ใo."
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE) .And. (FNM->FNM_STATUS != "1")
	lRet := .F.
	Help(" ",1,"AFA004NOK")		//"Movimento de aprova็ใo jแ aprovado/rejeitado."##"Somente movimentos de aprova็ใo pendentes podem ser aprovados/rejeitados."
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF004PosVld   บAutor  ณRenan Guedes    บ Data ณ  12/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณP๓s-valida็ใo do modelo de dados (antigo TudOk)             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF004PosVld(oModel)

Local lRet			:= .T.
Local nOperation 	:= oModel:GetOperation()
Local cStatus		:= oModel:GetValue('FNMMASTER', 'FNM_STATUS' )
Local aArea			:= GetArea()

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE) .And. !(cStatus $ "2|3|")
	lRet := .F.
	Help("",1,"AFA004STAT")		//"O movimento de aprova็ใo somente pode ser aprovado ou rejeitado."##"O movimento de aprova็ใo deve ser aprovado ou rejeitado. Para mant๊-lo pendente, cancele a opera็ใo."
EndIf

//Valida a aprova็ใo da revisใo do AVP
If lRet .And. (nOperation == MODEL_OPERATION_UPDATE) .And. (cStatus == "2") .And. (Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA440") .And. (Upper(AllTrim(FNM->FNM_OPER)) == "06")
	lRet := AF440TudOk(Nil,cStatus,.T.,FNM->FNM_RECORI)
EndIf

If lRet
	Do Case         
	
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA440" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "2")		//Aprova็ใo da revisใo de AVP
			MsgRun( STR0014 ,, {||	AF440Grava(Nil,FNM->FNM_RECORI,.T.) } ) //"Processando revisใo de AVP ..."
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA440" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "3")		//Rejei็ใo da revisใo de AVP
			AF440RepRev(FNM->FNM_RECORI)    
			
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA006" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "2")		//Aprova็ใo da revisใo de taxa de ํndice de deprecia็ใo
			AF006Aprv(1,FNM->FNM_RECORI)
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA006" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "3")		//Rejei็ใo da revisใo de taxa de ํndice de deprecia็ใo
			AF006Aprv(2,FNM->FNM_RECORI)
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA006" .And. Upper(AllTrim(FNM->FNM_OPER)) == "07" .And. (cStatus == "2")		//Aprova็ใo do bloqueio/desbloqueio de taxa de ํndice de deprecia็ใo
			AF006Aprv(3,FNM->FNM_RECORI)
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA006" .And. Upper(AllTrim(FNM->FNM_OPER)) == "08" .And. (cStatus == "2")		//Aprova็ใo da importa็ใo de taxa de ํndice de deprecia็ใo
			AF006Aprv(4,FNM->FNM_RECORI)
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA006" .And. Upper(AllTrim(FNM->FNM_OPER)) == "08" .And. (cStatus == "3")		//Rejei็ใo da importa็ใo de taxa de ํndice de deprecia็ใo
			AF006Aprv(5,FNM->FNM_RECORI)   
			
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "10" .And. (cStatus == "2")		//Aprova็ใo do Encerramento de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			lRet := AFA430ENC("FNB",FNM->FNM_RECORI,3,.T.)
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "10" .And. (cStatus == "3")		//Rejei็ใo do Encerramento de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			AF430FLAG(FNB->FNB_CODPRJ,FNB->FNB_REVIS,"1")
			
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "2")		//Aprova็ใo do Encerramento de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
	   		MsgRun( STR0011 ,, {||	lRet := AF430REVGR(FNB->FNB_CODPRJ,FNB->FNB_REVIS,.T.) } ) //"Processando revisใo do Projeto..."
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "06" .And. (cStatus == "3")		//Aprova็ใo do Revisใo de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			cRevis := AF430GetRev(FNB->FNB_CODPRJ,'8')
			AF430FLAG(FNB->FNB_CODPRJ,cRevis,"3")  
			
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "11" .And. (cStatus == "2")		//Aprova็ใo da Atualiza็ใo de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			MsgRun( STR0016 ,, {|| lRet := AFA430ATU("FNB",FNM->FNM_RECORI,3,.T.) } )//"Realizando Atualiza็ใo de Projeto"
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "11" .And. (cStatus == "3")		//Rejei็ใo da Atualiza็ใo de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			AF430FLAG(FNB->FNB_CODPRJ,FNB->FNB_REVIS,"0")
			
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "12" .And. (cStatus == "2")		//Aprova็ใo da Revisใo da Taxa de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			MsgRun( STR0017 ,, {|| lRet := AF430REVTX("FNB",FNM->FNM_RECORI,3,.T.,FNM->FNM_DATA) } )//"Processando revisใo de taxas de AVP..."
		Case Upper(AllTrim(FNM->FNM_ROTINA)) == "ATFA430" .And. Upper(AllTrim(FNM->FNM_OPER)) == "12" .And. (cStatus == "3")		//Rejei็ใo da Revisใo da Taxa  de Projeto
			dbSelectArea("FNB")
			FNB->(dbGoTo(FNM->FNM_RECORI))
			AF430CancTx(FNB->FNB_CODPRJ,FNB->FNB_REVIS)
			AF430FLAG(FNB->FNB_CODPRJ,FNB->FNB_REVIS,"1")
			
	EndCase
EndIf

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA002   บAutor  ณRenan Guedes        บ Data ณ  12/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef() 

Local oModel 	:= FWLoadModel( 'ATFA004' ) 		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
Local oStruFNM 	:= FWFormStruct( 2, 'FNM' ) 		// Cria a estrutura a ser usada na View 
Local oView  									// Interface de visualiza็ใo construํda 
Local bBlock	:= {|| .T.}

//tratamento para Dados Protegidos quando o usuario nใo tiver acesso a dados pessoais nใo ativar F3.
If FindFunction("CTPROTDADO") .AND. !CTPROTDADO()
	oStruFNM:SetProperty( 'FNM_CODAPR', MVC_VIEW_LOOKUP, "" )
	oStruFNM:SetProperty( 'FNM_CODSOL', MVC_VIEW_LOOKUP, "" )
Endif

// Cria o objeto de View 
oView := FWFormView():New() 
// Define qual o Modelo de dados serแ utilizado na View 
oView:SetModel( oModel ) 
// Adiciona no nosso View um controle do tipo formulแrio  
oView:AddField( 'VIEWFNM', oStruFNM, 'FNMMASTER' )
// Criar um "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'TELA' , 100 ) 
// Relaciona o identificador (ID) da View com o "box" para exibi็ใo 
oView:SetOwnerView( 'VIEWFNM', 'TELA' ) 
//Botใo origem do registro de aprova็ใo
oView:AddUserButton( STR0010, 'SDUSEEK', {|oView| AFA004Origem()} )		//"Origem"
//For็a o fechamento da janela na confirma็ใo
oView:SetCloseOnOk( bBlock )

Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF004GrvMov  บAutor  ณRenan Guedes     บ Data ณ  12/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF004GrvMov(cRotina,cOper,dData,cCodSol,cMoeda,nValor,cOrigem,cAlias,nRec,lATF006AUT)

Local lRet			:= .T.
Local mMemSol		:= ""
Local cIdProc		:= ""
Local aAreaFNL		:= {}
Local aAreaFNM		:= {}
Local nTamRot, nTamOper 
Local cRev			:= ""

Default cRotina		:= ""
Default cOper		:= ""
Default dData		:= dDataBase
Default cCodSol		:= RetCodUsr()
Default cMoeda		:= "01"
Default nValor		:= 0
Default cOrigem		:= FunName()
Default cAlias		:= ""
Default nRec		:= 0
Default lATF006AUT	:= .F.   //UTILIZADO PARA ROTINA AUTOMATICA IMPORTAวรO CSV ATFA006IMP DA ROTINA ATFA006

If Empty(cRotina) .Or. Empty(cOper) .Or. Empty(cAlias) .Or. (nRec <= 0)
	lRet := .F.
Else
	If !lATF006AUT  //apenas rotinas nใo automแticas chamam a tela para o preenchimento da justificativa
	//Chama a janela para o preenchimento da justificativa
	AF004Jus(@mMemSol)
	Else
		mMemSol := STR0013  //"Importa็ใo CSV"		
	EndIf	
	
	nTamRot		:= TamSX3("FNH_ROTINA")[1]
	nTamOper	:= TamSX3("FNH_OPER")[1]
	
	//Padroniza os strings da rotina e opera็ใo
	cRotina		:= PADR(AllTrim(cRotina), nTamRot)
	cOper		:= PADR(AllTrim(cOper), nTamOper)
	
	//Posiciona no aprovador habilitado
	cRev := AFXAprRev(cRotina)
	dbSelectArea("FNL")
	aAreaFNL := FNL->(GetArea())
	FNL->(dbSetOrder(1))		//FNL_FILIAL+FNL_ROTINA+FNL_REVIS+FNL_OPER+FNL_CODAPR
	If FNL->(MsSeek(xFilial("FNL")+cRotina+cRev+cOper))
	
		//Gera um novo c๓digo de processo
		cIdProc	:= GetSxeNum('FNM','FNM_IDMOV','FNM_IDMOV'+cEmpAnt,1)
	
		//Grava o movimento de aprova็ใo
		dbSelectArea("FNM")
		aAreaFNM := FNM->(GetArea())
		Reclock("FNM",.T.)
		FNM->FNM_FILIAL	:= xFilial("FNM")
		FNM->FNM_IDMOV	:= cIdProc
		FNM->FNM_ROTINA	:= cRotina
		FNM->FNM_REVIS	:= FNL->FNL_REVIS		//Revisใo da al็ada
		FNM->FNM_OPER	:= cOper
		FNM->FNM_DATA	:= dData
		FNM->FNM_CODSOL	:= cCodSol
		FNM->FNM_CODAPR	:= FNL->FNL_CODAPR
		FNM->FNM_MOEDA	:= cMoeda
		FNM->FNM_VALOR	:= nValor
		FNM->FNM_STATUS	:= "1"		//Pendente
		FNM->FNM_MEMSOL	:= mMemSol
		FNM->FNM_MEMAPR	:= ""
		FNM->FNM_ORIGEM	:= cOrigem
		FNM->FNM_TABORI	:= cAlias
		FNM->FNM_RECORI	:= nRec
		FNM->(MsUnlock())
		
		ConfirmSX8()
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF004Jus   บAutor  ณRenan Guedes       บ Data ณ  12/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJanela de preenchimento da justificativa do movimento       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF004Jus(mMemSol)

Local oDlgJus		:= Nil
Local oBotOk		:= Nil

DEFINE MSDIALOG oDlgJus FROM 1,1 TO 10,48.5 OF oMainWnd STYLE DS_MODALFRAME TITLE STR0005		//"Justificativa"
@ 00,000 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgJus SIZE 35,oDlgJus:nBottom / 2.4 NOBORDER WHEN .F. PIXEL
//Campo memo
@ 0.5,5.7 GET oMemo VAR mMemSol OF oDlgJus MEMO SIZE 135,40 FONT oDlgJus:oFont COLOR CLR_BLACK,CLR_HGRAY
oMemo:bRClicked := {||AllwaysTrue()}
//Botใo Confirmar
DEFINE SBUTTON FROM 52,155	TYPE 1 ACTION ( IIF(AF004TOk(mMemSol),oDlgJus:End(),.F.) ) ENABLE OF oDlgJus  
oDlgJus:Activate( ,,, .T.,,, {|| oDlgJus:lEscClose := .F. } )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF004TOk  บAutor  ณAlvaro Camillo Neto บ Data ณ  31/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que valida a tela de justificativa de solicitacao   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF004TOk(mMemSol)
Local lRet := .T.

If Empty(mMemSol)
	Help("",1,"AFA004JUS",, STR0015, 1, 0 ) //"Por favor, preencha o campo de justificativa."
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA004Origem   บAutor  ณRenan Guedes   บ Data ณ  12/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a janela de consulta do cadastro de origem do 		  บฑฑ
ฑฑบ          ณmovimento de aprova็ใo                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA004Origem()

Local aArea			:= GetArea()
Local aAreaSN0		:= {}
Local lRet			:= .T.
Local cAlias		:= ""
Local nRec			:= 0

Private cCadastro	:= ""

dbSelectArea("SN0")
aAreaSN0 := SN0->(GetArea())
SN0->(dbSetOrder(1))		//N0_FILIAL+N0_TABELA+N0_CHAVE
If SN0->(MsSeek(xFilial("SN0")+"20"+AllTrim(FNM->FNM_ORIGEM)))
	cCadastro := AllTrim(SN0->N0_DESC01)
	cAlias := FNM->FNM_TABORI
	nRec := FNM->FNM_RECORI
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTo(nRec))
	AxVisual( cAlias, nRec, 2)
EndIf

RestArea(aAreaSN0)
RestArea(aArea)

Return lRet
