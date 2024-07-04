#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA683.CH"

STATIC lFN683USR := NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA683
Tela de cadastro de Grupos de Acesso

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FINA683()
	Local oBrowse
	
	oBrowse:=FWMBrowse():New()
	oBrowse:SetAlias("FLI")
	oBrowse:SetDescription(OemToANSI(STR0001)) //STR0001:"Grupos de Acesso" 
	
	oBrowse:SetMenuDef("FINA683")
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu da tela de cadastro de Grupos de Acesso

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE OemToANSI(STR0002) ACTION "VIEWDEF.FINA683" OPERATION 2 ACCESS 0 //STR0002:"Visualizar"
	ADD OPTION aRotina TITLE OemToANSI(STR0003) ACTION "VIEWDEF.FINA683" OPERATION 3 ACCESS 0 //STR0003:"Incluir"
	ADD OPTION aRotina TITLE OemToANSI(STR0004) ACTION "VIEWDEF.FINA683" OPERATION 4 ACCESS 0 //STR0004:"Alterar"
	ADD OPTION aRotina TITLE OemToANSI(STR0005) ACTION "VIEWDEF.FINA683" OPERATION 5 ACCESS 0 //STR0005:"Excluir"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da tela de cadastro de Grupos de Acesso

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruFLI := FWFormStruct(1, "FLI")
	Local oStruFLL := FWFormStruct(1, "FLL") 					    
	Local oModel
	Local aRelation := {{'FLL_FILIAL','xFilial("FLL")'},{'FLL_GRUPO','FLI_GRUPO'}}
	
	oModel := MPFormModel():New("FINA683")		
	oModel:AddFields("FLIMASTER",,oStruFLI)
	oModel:AddGrid("FLLDETAIL","FLIMASTER",oStruFLL)
	
	oModel:GetModel("FLLDETAIL"):SetUniqueLine({"FLL_PARTIC"})		
	oModel:SetRelation("FLLDETAIL", aRelation, FLL->(IndexKey(1)))
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View da tela de cadastro de Grupos de Acesso

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("FINA683")
	Local oStruFLI := FWFormStruct(2,"FLI")
	Local oStruFLL := FWFormStruct(2,"FLL")
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewField",oStruFLI,"FLIMASTER")
	oView:AddGrid("ViewGrid",oStruFLL,"FLLDETAIL")
	
	oView:CreateHorizontalBox("ViewFLI",30) 
	oView:CreateHorizontalBox("GridFLL",70)
	oView:SetOwnerView("ViewField","ViewFLI")	 
	oView:SetOwnerView("ViewGrid","GridFLL") 
	
	oView:EnableTitleView("ViewField",OemToANSI(STR0006)) //STR0006:"Informações do Grupo de Acesso"
	oView:EnableTitleView("ViewGrid",OemToANSI(STR0007)) //STR0007:"Participantes do Grupo de Acesso"
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FN683PARTI
Função que retorna os participantes que podem ser visualizados, com base 
no código de usuário informado

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FN683PARTI(cUser)
	Local aRet := {}
	Local aDeptoViagem := {} 
	Local cDeptoViagem := ""
	Local cAreaAnt := GetArea()
	Local cParticipante := "" 
	Local cGrupo := ""
	Local cQuery := ""
	Default cUser := RetCodUsr()
	
	If lFN683USR == NIL 
		lFN683USR := ExistBlock("FN683USR")
	Endif 
			
	cDeptoViagem := SuperGetMV("MV_RESGVIA",,"") 
	aDeptoViagem := StrToKarr(cDeptoViagem,";")
	//Se o usuário for do departamento de viagens, retorna "ALL"
	If aScan(aDeptoViagem,{|cBusca|cBusca==cUser}) > 0   
		aAdd(aRet, "ALL")
	Else 
		cQuery += "SELECT RD0_CODIGO, RD0_USER"
		cQuery += " FROM " + RetSqlName("RD0")  + " RD0"
		cQuery += " WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND RD0.D_E_L_E_T_ = '' AND RD0_USER = '" + cUser + "'"
		cQuery += " OR RD0_APSUBS IN (SELECT RD0_CODIGO FROM " + RetSqlName("RD0")  + " RD0 WHERE RD0_FILIAL = '" + xFilial("RD0") + "' AND RD0_USER = '" + cUser + "')"
		
		cQuery += " ORDER BY RD0_CODIGO"		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"RD0TMP",.T.,.T.)
		dbSelectArea("RD0TMP")
		
		//Se o usuário não estiver cadastrado na tabela de Participantes, retorna "NO"
		If RD0TMP->(EOF())
			aAdd(aRet, "NO")
		Else
			While RD0TMP->(!EOF())
				cParticipante := RD0TMP->RD0_CODIGO
				dbSelectArea("FLI") 
		    	dbSetOrder(2) //FLI_FILIAL + FLI_RESPON
				
				//Se o participante NÂO for um "Responsável", retorna apenas o código do mesmo
				If !dbSeek(xFilial("FLI")+cParticipante)
					aAdd(aRet, cParticipante)
				Else
			       //Se o participante FOR um "Responsável", retorna todos os participantes do Grupo desse responsável (inclusive o mesmo)									
					cGrupo := FLI->FLI_GRUPO
					dbSelectArea("FLL") 
		    		dbSetOrder(1) //FLL_FILIAL + FLL_GRUPO + FLL_PARTIC	
					
					Iif(RD0TMP->RD0_USER == cUser, aAdd(aRet, cParticipante), )
					
					If dbSeek(xFilial("FLL")+cGrupo)
						While FLL->(!EOF()) .AND. FLL->FLL_GRUPO == cGrupo
							aAdd(aRet, FLL->FLL_PARTIC)
							FLL->(dbSkip())
						EndDo
					Endif
				Endif
				RD0TMP->(dbSkip())
			EndDo
		Endif
		RD0TMP->(dbCloseArea())
	Endif
	
	RestArea(cAreaAnt)
	
	If lFN683USR
		aRet := ExecBlock("FN683USR",.F.,.F.,aRet)
	Endif
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN683VALID
Validação para não deixar cadastrar um responsável em mais de um grupo (Se o parâmetro for "FLI")
ou para não deixar cadastrar um participante em mais de um grupo (Se o parâmetro for "FLL")

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FN683VALID(cAlias)
	Local lRet := .T.
	Local cAreaAnt := GetArea()
	Local cParticipante := ""
	Local cGrupo := ""
	
	If cAlias == "FLI"
		cParticipante := M->FLI_RESPON				
		
		dbSelectArea("RD0")
		dbSetOrder(1)
		//Se o código informado não estiver cadastrado na tabela de Participantes (RD0), não valida
		if !dbSeek(xFilial("RD0")+cParticipante)
			Help(,,"FN683VALID",,OemToANSI(STR0010), 1, 0 ) //STR0010:"Participante não cadastrado." 
			lRet := .F.
		Else 
			dbSelectArea("FLI")
			dbSetOrder(2) //FLI_FILIAL + FLI_RESPON
		
			//Se o participante já for um "Responsável",não valida 
			If dbSeek(xFilial("FLI")+cParticipante)
				Help(,,"FN683VALID",,OemToANSI(STR0008)+FLI->FLI_GRUPO, 1, 0 ) //STR0008:"Responsável inválido. Essa pessoa já é responsável pelo seguinte grupo: "
				lRet := .F.
			EndIf
		Endif
	ElseIF cAlias == "FLL"
		cParticipante := M->FLL_PARTIC								
		
		//Se o código informado não estiver cadastrado na tabela de Participantes (RD0), não valida
		if !dbSeek(xFilial("RD0")+cParticipante)
			Help(,,"FN683VALID",,OemToANSI(STR0010), 1, 0 ) //STR0010:"Participante não cadastrado."
			lRet := .F.
		Else 
			dbSelectArea("FLL") 
			dbSetOrder(2) //FLL_FILIAL + FLL_PARTIC	
				
			//Se o participante já estiver em um grupo,não valida 
			If dbSeek(xFilial("FLL")+cParticipante)
				Help(,,"FN683VALID",,OemToANSI(STR0009)+FLL->FLL_GRUPO, 1, 0 ) //STR0009:"Esse participante já está incluso no seguinte grupo: " 			
				lRet := .F.
			EndIf
		Endif
	EndIf
	 
	RestArea(cAreaAnt) 
Return lRet
