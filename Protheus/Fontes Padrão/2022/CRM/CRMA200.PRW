#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "CRMA200.CH"

Static lMVCRMUAZS	:= Nil
Static aCtrtAceUsr	:= {Nil ,.T.,.F.,.F.,.F.,.F.}
Static _nFolderAuto	:= 1

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200

Controle de Privilegios do Registro.

@sample	CRMA200(cAliasEnt)

@param		ExpC1 - Entidade que possui Controle de Privilegios do Registro.

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/08/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA200(cAliasEnt)

Local aArea			:= GetArea()
Local aAreaAO4 		:= AO4->(GetArea())
Local cSX2Unico		:= ""
Local cChave		:= ""
Local aPerHerdada	:= {}
Local lRetorno 		:= .T.
Local cCodUsr		:= "" 
Local aAutoAO4		:= {}
Local cEntCtrlPri	:= CRMXCtrlEnt() 
Local aPermPri		:= {}

Default cAliasEnt	:= Alias()

//Controle de Privilegios do Registro somente para as entidades cadastradas na funcao CRMXCtrlEnt

If ( cAliasEnt $ cEntCtrlPri )
 	CRMA200RstAce()

	 If lMVCRMUAZS = Nil
		lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
	EndIf

	cCodUsr := IIf(lMVCRMUAZS, CRMXCodUser(), RetCodUsr())	
 	
	cSX2Unico	:= CRMXGetSX2(cAliasEnt)[1]
	cChave		:= PadR(xFilial(cAliasEnt)+(cAliasEnt)->&(cSX2Unico),TAMSX3("AO4_CHVREG")[1])
	
	aPermPri := CRMXVlPriv(cAliasEnt,cChave,cCodUsr)
	
	If	Len(aPermPri) > 0 
		
		aCtrtAceUsr[PERM_CODUSR]				:= aPermPri[6]
		aCtrtAceUsr[PERM_CONTROLE_TOTAL]	:= aPermPri[1]
		aCtrtAceUsr[PERM_VISUALIZAR]		:= aPermPri[2]
		aCtrtAceUsr[PERM_EDITAR] 			:= aPermPri[3]
		aCtrtAceUsr[PERM_EXCLUIR] 			:= aPermPri[4]
		aCtrtAceUsr[PERM_COMPARTILHAR] 		:= aPermPri[5]
					
		DbSelectArea("AO4")
		DbSetOrder(aPermPri[7])
		lRetorno := DbSeek(xFilial("AO4")+aPermPri[8])

	Else 
		
		aPerHerdada := CRMXHerdaPer(cAliasEnt,cChave)
		
		If Len(aPerHerdada) > 0
			
			If AO4->(DbSeek(xFilial("AO4")+cAliasEnt+cChave))
				aCtrtAceUsr := aPerHerdada
			Else
				lRetorno := .F.
				MsgStop(STR0002)	 //"Não foi possível acessar os privilegios deste registro!")
			EndIf
			
		Else
			
			//Se o registro nao tiver nenhum proprietario, atribui o permissionamento de controle total para o Administrador.
			If cCodUsr	== "000000"
				
				aAutoAO4	:= CRMA200PAut(MODEL_OPERATION_INSERT,cAliasEnt,cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/,/*cCodEqp*/,/*cCodUnd*/)
				
				CRMA200Auto(aAutoAO4[1],aAutoAO4[2],MODEL_OPERATION_INSERT)
				
				AO4->(DbSetOrder(1)) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				
				If AO4->(DbSeek(xFilial("AO4")+cAliasEnt+cChave+aCtrtAceUsr[PERM_CODUSR]))
					aCtrtAceUsr[PERM_CODUSR]				:= AO4->AO4_CODUSR
					aCtrtAceUsr[PERM_CONTROLE_TOTAL]	:= AO4->AO4_CTRLTT
					aCtrtAceUsr[PERM_VISUALIZAR]		:= AO4->AO4_PERVIS
					aCtrtAceUsr[PERM_EDITAR] 			:= AO4->AO4_PEREDT
					aCtrtAceUsr[PERM_EXCLUIR] 			:= AO4->AO4_PEREXC
					aCtrtAceUsr[PERM_COMPARTILHAR] 		:= AO4->AO4_PERCOM
				Else
					lRetorno := .F.
					MsgStop(STR0002)	 //"Não foi possível acessar os privilegios deste registro!")
				EndIf
				
			Else
				lRetorno := .F.
				MsgStop(STR0003)	//"Você não possui acesso suficiente para gerenciar os privilégios deste registro!"
			EndIf
			
		EndIf
		
	EndIf
	 
	If lRetorno 
		FWExecView(STR0013,"CRMA200",MODEL_OPERATION_UPDATE) //"Alterar"
	EndIf

Else
	lRetorno := .F.
	MsgStop(STR0015) //"O Controle de Privilégios não está habilitado para esta entidade."
EndIf

//Reseta a variavel aCtrtAceUsr com valor padrao.
CRMA200RstAce()

RestArea(aAreaAO4) 
RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ModelDef

Modelo de dados do Controle de Privilegios do Registro.

@sample	ModelDef() 

@param		Nenhum

@return	ExpO - Objeto MPFormModel

@author	Anderson Silva
@since		04/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------  
Static Function ModelDef() 
 
Local oModel		:= Nil
Local cCpoInf		:= "AO4_ENTIDA|AO4_NOMENT|AO4_CHVREG|AO4_DESREG|AO4_PRIORI|AO4_SEQPRI|"
Local bAvCpoInf		:= { |cCampo| AllTrim(cCampo) + "|" $ cCpoInf } 
Local oStructInf	:= FWFormStruct(1,"AO4",bAvCpoInf,/*lViewUsado*/) 	 	// Informacoes do Registro - CABECALHO
Local oStructUsr	:= FWFormStruct(1,"AO4",/*bAvCpsUsr*/,/*lViewUsado*/)	// Acessos - Usuarios do CRM
Local oStructEqp	:= FWFormStruct(1,"AO4",/*bAvCpsGrp*/,/*lViewUsado*/)	// Acessos - Equipes
Local oStructUnd	:= FWFormStruct(1,"AO4",/*bAvCpsGrp*/,/*lViewUsado*/)	// Acessos - Unidades de Venda
Local bVldActive	:= {|oModel| CRMA200VMAct(oModel) }		
Local bPosVldMdl	:= {|oModel| CRMA200MdlPVal(oModel) }	
Local aAux			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Gatilhos ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//Folder de Usuarios.
aAux := FwStruTrigger("AO4_CODUSR","AO4_USRCOM","CRMA200RUCom(1,'AO4DETUSR','AO4_CODUSR')",.F.,Nil,Nil,Nil)
oStructUsr:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("AO4_CODUSR","AO4_NOMUSC","CRMA200RUCom(2,'AO4DETUSR','AO4_CODUSR')",.F.,Nil,Nil,Nil)
oStructUsr:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

//Folder de Equipe.
aAux := FwStruTrigger("AO4_CODEQP","AO4_USRCOM","CRMA200RUCom(1,'AO4DETEQP','AO4_CODEQP')",.F.,Nil,Nil,Nil)
oStructEqp:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("AO4_CODEQP","AO4_NOMUSC","CRMA200RUCom(2,'AO4DETEQP','AO4_CODEQP')",.F.,Nil,Nil,Nil)
oStructEqp:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

//Folder de Unidade de Negocio.
aAux := FwStruTrigger("AO4_CODUND","AO4_USRCOM","CRMA200RUCom(1,'AO4DETUND','AO4_CODUND')",.F.,Nil,Nil,Nil)
oStructUnd:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
aAux := FwStruTrigger("AO4_CODUND","AO4_NOMUSC","CRMA200RUCom(2,'AO4DETUND','AO4_CODUND')",.F.,Nil,Nil,Nil)
oStructUnd:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Inicializacao Padrao ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Informacoes do Registro - CABECALHO
oStructInf:SetProperty("AO4_SEQPRI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200SqAp()"))

//Acessos - Usuarios do CRM
oStructUsr:SetProperty("AO4_NOMUSR",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NUsr('AO4_CODUSR','AO4DETUSR')"))
oStructUsr:SetProperty("AO4_NOMUSC",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NUsr('AO4_USRCOM','AO4DETUSR')"))
oStructUsr:SetProperty("AO4_TPACES",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'1'"))

//Acessos - Equipes
oStructEqp:SetProperty("AO4_NOMEQP",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NEqp()"))
oStructEqp:SetProperty("AO4_NOMUSC",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NUsr('AO4_USRCOM','AO4DETEQP')"))
oStructEqp:SetProperty("AO4_TPACES",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'2'"))

//Acessos - Unidades de Venda
oStructUnd:SetProperty("AO4_NOMUND",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NUnd()"))
oStructUnd:SetProperty("AO4_NOMUSC",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"CRMA200NUsr('AO4_USRCOM','AO4DETUND')"))
oStructUnd:SetProperty("AO4_TPACES",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'3'"))
If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

If lMVCRMUAZS 
	oStructUsr:SetProperty("AO4_PROPRI",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA200MkPr()"))
EndIf

//Retira a obrigatoridade 
oStructUnd:SetProperty("AO4_CODUSR",MODEL_FIELD_OBRIGAT,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos referente a informacao do registro ³
//³ da estrutura de permissionamento. 					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Usuarios do CRM
oStructUsr:RemoveField("AO4_ENTIDA")
oStructUsr:RemoveField("AO4_NOMENT")
oStructUsr:RemoveField("AO4_CHVREG")
oStructUsr:RemoveField("AO4_DESREG")
oStructUsr:RemoveField("AO4_PRIORI")
oStructUsr:RemoveField("AO4_SEQPRI")

//Acessos - Equipes
oStructEqp:RemoveField("AO4_ENTIDA")
oStructEqp:RemoveField("AO4_NOMENT")
oStructEqp:RemoveField("AO4_CHVREG")
oStructEqp:RemoveField("AO4_DESREG")
oStructEqp:RemoveField("AO4_PRIORI")
oStructEqp:RemoveField("AO4_SEQPRI")

//Acessos - Unidades de Venda
oStructUnd:RemoveField("AO4_ENTIDA")
oStructUnd:RemoveField("AO4_NOMENT")
oStructUnd:RemoveField("AO4_CHVREG")
oStructUnd:RemoveField("AO4_DESREG")
oStructUnd:RemoveField("AO4_PRIORI")
oStructUnd:RemoveField("AO4_SEQPRI")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia o modelo de dados da Oportunidade de Venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("CRMA200",/*bPreValidacao*/,bPosVldMdl,/*bCommitMdl*/,/*bCancel*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona no modelo formulario e grids. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabeçalho - Informacoes do Registro.  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields("AO4MASTER",/*cOwner*/,oStructInf,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Privilegios do Registro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Usuarios do CRM 
oModel:AddGrid("AO4DETUSR","AO4MASTER",oStructUsr,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//Acessos - Equipes
oModel:AddGrid("AO4DETEQP","AO4MASTER",oStructEqp,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//Acessos - Unidades de Venda
oModel:AddGrid("AO4DETUND","AO4MASTER",oStructUnd,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do relacionamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Privilegios do Registro  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetRelation("AO4DETUSR",{{"AO4_FILIAL","xFilial('AO4')"},{"AO4_ENTIDA","AO4_ENTIDA"},{"AO4_CHVREG","AO4_CHVREG"},{"AO4_PRIORI","AO4_PRIORI"},{"AO4_TPACES","'1'"}},AO4->( IndexKey(1)))
oModel:SetRelation("AO4DETEQP",{{"AO4_FILIAL","xFilial('AO4')"},{"AO4_ENTIDA","AO4_ENTIDA"},{"AO4_CHVREG","AO4_CHVREG"},{"AO4_PRIORI","AO4_PRIORI"},{"AO4_TPACES","'2'"}},AO4->( IndexKey(1)))
oModel:SetRelation("AO4DETUND",{{"AO4_FILIAL","xFilial('AO4')"},{"AO4_ENTIDA","AO4_ENTIDA"},{"AO4_CHVREG","AO4_CHVREG"},{"AO4_PRIORI","AO4_PRIORI"},{"AO4_TPACES","'3'"}},AO4->( IndexKey(1)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação de linha duplicada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

If lMVCRMUAZS
	oModel:GetModel("AO4DETUSR"):SetUniqueLine({"AO4_CODUSR","AO4_USRPAP"})
Else
	oModel:GetModel("AO4DETUSR"):SetUniqueLine({"AO4_CODUSR"})
EndIf
oModel:GetModel("AO4DETEQP"):SetUniqueLine({"AO4_CODEQP"})
oModel:GetModel("AO4DETUND"):SetUniqueLine({"AO4_CODUND"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite o grid sem dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel("AO4DETUSR"):SetOptional(.T.)
oModel:GetModel("AO4DETEQP"):SetOptional(.T.)
oModel:GetModel("AO4DETUND"):SetOptional(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o Model(MPFormModel) pode ser ativado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetVldActivate(bVldActive)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura a chave primaria do Model(MPFormModel), pois o ³
//³ campo AO4_CODUSR nao pode ser utilizado no ModelFields.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetPrimaryKey({"AO4_FILIAL","AO4_ENTIDA","AO4_CHVREG","AO4_TPACES","AO4_CODUSR","AO4_CODEQP","AO4_CODUND"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Model. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetDescription(STR0001)		// "Privilégios do Registro"    

Return(oModel)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ViewDef

Interface do Controle de Privilegios do Registro.

@sample	ViewDef()

@param		Nenhum

@return	ExpO - Objeto FWFormView

@author	Anderson Silva
@since		04/08/2014
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil
Local oModel		:= FWLoadModel("CRMA200")									
Local cCpoInf		:= "AO4_ENTIDA|AO4_NOMENT|AO4_DESREG|AO4_SEQPRI|"

Local cCpoUsr		:= "AO4_CODUSR|AO4_NOMUSR|AO4_CTRLTT|AO4_PERVIS|AO4_PEREDT|AO4_PEREXC|AO4_PERCOM|AO4_USRCOM|AO4_NOMUSC|AO4_DTVLD|"
Local cCpoGrp		:= "AO4_CODEQP|AO4_NOMEQP|AO4_CTRLTT|AO4_PERVIS|AO4_PEREDT|AO4_PEREXC|AO4_PERCOM|AO4_USRCOM|AO4_NOMUSC|AO4_DTVLD|"
Local cCpoUnd		:= "AO4_CODUND|AO4_NOMUND|AO4_CTRLTT|AO4_PERVIS|AO4_PEREDT|AO4_PEREXC|AO4_PERCOM|AO4_USRCOM|AO4_NOMUSC|AO4_DTVLD|"

Local bAvCpoInf	:= { |cCampo| AllTrim(cCampo) + "|" $ cCpoInf } 
Local oStructInf	:= FWFormStruct(2,"AO4",bAvCpoInf,/*lViewUsado*/) 	// Informacoes do Registro - CABECALHO

Local bAvCpsUsr	:= { |cCampo| AllTrim(cCampo) + "|" $ cCpoUsr }
Local oStructUsr	:= FWFormStruct(2,"AO4",bAvCpsUsr,/*lViewUsado*/)	// Acessos - Usuarios do CRM

Local bAvCpsGrp	:= { |cCampo| AllTrim(cCampo) + "|" $ cCpoGrp }
Local oStructEqp	:= FWFormStruct(2,"AO4",bAvCpsGrp,/*lViewUsado*/)	// Acessos - Equipes

Local bAvCpsUnd	:= { |cCampo| AllTrim(cCampo) + "|" $ cCpoUnd }
Local oStructUnd	:= FWFormStruct(2,"AO4",bAvCpsUnd,/*lViewUsado*/)	// Acessos - Unidades de Venda

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

If lMVCRMUAZS
	cCpoUsr += "AO4_PROPRI|AO4_USRPAP|AO4_NOMPAP|"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos referente a informacao do registro ³
//³ da estrutura de permissionamento. 						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Usuarios do CRM
oStructUsr:RemoveField("AO4_ENTIDA")
oStructUsr:RemoveField("AO4_NOMENT")
oStructUsr:RemoveField("AO4_CHVREG")
oStructUsr:RemoveField("AO4_DESREG")
oStructUsr:RemoveField("AO4_CODEQP")
oStructUsr:RemoveField("AO4_NOMEQP")
oStructUsr:RemoveField("AO4_PRIORI")
oStructUsr:RemoveField("AO4_SEQPRI")

//Acessos - Equipes
oStructEqp:RemoveField("AO4_ENTIDA")
oStructEqp:RemoveField("AO4_NOMENT")
oStructEqp:RemoveField("AO4_CHVREG")
oStructEqp:RemoveField("AO4_DESREG")
oStructEqp:RemoveField("AO4_CODUSR")
oStructEqp:RemoveField("AO4_NOMUSR")
oStructEqp:RemoveField("AO4_PRIORI")
oStructEqp:RemoveField("AO4_SEQPRI")
If lMVCRMUAZS
	oStructEqp:RemoveField("AO4_USRPAP")
	oStructEqp:RemoveField("AO4_NOMPAP")
EndIF

//Acessos - Unidades de Venda
oStructUnd:RemoveField("AO4_ENTIDA")
oStructUnd:RemoveField("AO4_NOMENT")
oStructUnd:RemoveField("AO4_CHVREG")
oStructUnd:RemoveField("AO4_DESREG")
oStructUnd:RemoveField("AO4_CODUSR")
oStructUnd:RemoveField("AO4_NOMUSR")
oStructUnd:RemoveField("AO4_CODEQP")
oStructUnd:RemoveField("AO4_NOMEQP")
oStructUnd:RemoveField("AO4_PRIORI")
oStructUnd:RemoveField("AO4_SEQPRI")
If lMVCRMUAZS
	oStructUnd:RemoveField("AO4_USRPAP")
	oStructUnd:RemoveField("AO4_NOMPAP")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove os campos referente a estrutura de negocios. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Usuarios do CRM
oStructUsr:RemoveField("AO4_IDESTN")
oStructUsr:RemoveField("AO4_NVESTN")

//Acessos - Equipes
oStructEqp:RemoveField("AO4_IDESTN")
oStructEqp:RemoveField("AO4_NVESTN")

//Acessos - Unidades de Venda
oStructUnd:RemoveField("AO4_IDESTN")
oStructUnd:RemoveField("AO4_NVESTN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera posicao de campos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Equipes 
oStructEqp:SetProperty( "AO4_CODEQP"	, MVC_VIEW_ORDEM , "01")
oStructEqp:SetProperty( "AO4_NOMEQP"	, MVC_VIEW_ORDEM , "02")

//Acessos - Unidades de Venda
oStructUnd:SetProperty( "AO4_CODUND"	, MVC_VIEW_ORDEM , "01")
oStructUnd:SetProperty( "AO4_NOMUND"	, MVC_VIEW_ORDEM , "02")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a interface do Controle de Privilegios do Registro.³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView := FWFormView():New()
oView:SetModel(oModel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona na interface formulario e grids.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabeçalho - Informacoes do Registro. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddField("VIEW_INF_REG",oStructInf,"AO4MASTER")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Privilegios do Registro. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Acessos - Usuarios do CRM
oView:AddGrid("VIEW_ACESUSR",oStructUsr,"AO4DETUSR")

//Acessos - Equipes
oView:AddGrid("VIEW_ACESGRP",oStructEqp,"AO4DETEQP")

//Acessos - Unidades de Venda
oView:AddGrid("VIEW_ACESUND",oStructUnd,"AO4DETUND")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box - Cabeçalho - Informacoes do Registro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("TOP",20)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Privilegios do Registro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox("BOTTOM",80)

oView:CreateFolder( "PASTAS","BOTTOM" )

oView:AddSheet( "PASTAS", "ABA01", STR0025 )	//"Usuários do CRM"
oView:AddSheet( "PASTAS", "ABA02", STR0026 )	//"Equipes"
oView:AddSheet( "PASTAS", "ABA03", STR0027 )	//"Unidades de Negócio"

oView:CreateHorizontalBox( "PASTA_USR" , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( "PASTA_GRP" , 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( "PASTA_UND" , 100,,, 'PASTAS', 'ABA03' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta a view no janelamento criado anteriormente. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:SetOwnerView("VIEW_INF_REG","TOP")  
oView:SetOwnerView("VIEW_ACESUSR","PASTA_USR")
oView:SetOwnerView("VIEW_ACESGRP","PASTA_GRP")
oView:SetOwnerView("VIEW_ACESUND","PASTA_UND")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid - Seta algumas propriedades na View ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oView:EnableTitleView("VIEW_INF_REG",STR0004) //"Informações do Registro"

oView:SetViewProperty("VIEW_ACESUSR","ENABLENEWGRID")
oView:SetViewProperty("VIEW_ACESUSR","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_ACESUSR","GRIDSEEK",{.T.})
oView:EnableTitleView("VIEW_ACESUSR",STR0028)	//"Informe usuários que terão privilégios sobre o registro:"

oView:SetViewProperty("VIEW_ACESGRP","ENABLENEWGRID")
oView:SetViewProperty("VIEW_ACESGRP","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_ACESGRP","GRIDSEEK",{.T.})
oView:EnableTitleView("VIEW_ACESGRP",STR0029)	//"Informe Equipes que terão privilégios sobre o registro:"
 
oView:SetViewProperty("VIEW_ACESUND","ENABLENEWGRID")
oView:SetViewProperty("VIEW_ACESUND","GRIDFILTER",{.T.})
oView:SetViewProperty("VIEW_ACESUND","GRIDSEEK",{.T.})
oView:EnableTitleView("VIEW_ACESUND",STR0030)	//"Informe unidades de venda que terão privilégios sobre o registro:"
 
Return(oView)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200MdlPVal

Pos-Validadao do Model(MPFormModel) do Controle de Privilegios do Registro.  

@sample	CRMA200MdlPVal(oModel)

@param		ExpO1 - Model do Controle de Privilegios do Registro (MPFormModel).
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		05/08/2014
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRMA200MdlPVal(oModel)

Local lRetorno		:= .T.
Local oMdlInf		:= oModel:GetModel("AO4MASTER")	//Informacoes do Registro - CABECALHO 	
Local oMdlUsr		:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
Local oMdlEqp		:= oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
Local oMdlUnd		:= oModel:GetModel("AO4DETUND")	//Acessos - Unidades de Venda 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o ModelGrid Acessos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRetorno :=  CRMA200VCtrl(oMdlInf,oMdlUsr,oMdlEqp,oMdlUnd)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200VCtrl

Pos-validacao do ModelGrid de Acessos.

@sample	CRMA200VCtrl(oMdlInf,oMdlUsr,oMdlEqp,oMdlUnd)

@param		ExpO1 - ModelField Informacoes do Registro. 	
			ExpO2 - ModelGrid de Usuarios. 
			ExpO3 - ModelGrid de Equipe.
			ExpO4 - ModelGrid de Unidade de Negocio.
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		05/08/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRMA200VCtrl(oMdlInf,oMdlUsr,oMdlEqp,oMdlUnd)

Local aArea	 		:= GetArea()
Local lCtrtTotal	:= .F.
Local lRetorno 		:= .T.
Local nX			:= 0
Local cCodUsr		:= ""
Local aRetEqUd 		:= CRMXVdEqUd(cCodUsr)
Local cFilACA		:= xFilial("ACA")
Local cFilADK		:= xFilial("ADK")
Local aPDFields 	:= {}

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

cCodUsr := If(lMVCRMUAZS, CRMXCodUser(), RetCodUsr())

//Acessos - Usuarios do CRM
For nX := 1 To oMdlUsr:Length()
	
	oMdlUsr:GoLine(nX)
	
	If !oMdlUsr:IsDeleted() .AND. !Empty( oMdlUsr:GetValue("AO4_CODUSR") )
	
		If oMdlUsr:GetValue("AO4_CTRLTT") 
			lCtrtTotal := .T.
		ElseIf ( !oMdlUsr:GetValue("AO4_CTRLTT") .AND. !oMdlUsr:GetValue("AO4_PERVIS") .AND. !oMdlUsr:GetValue("AO4_PEREDT") .AND. !oMdlUsr:GetValue("AO4_PEREXC")  )
			aPDFields 	:= {"AO4_NOMUSR"}
			FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

			lRetorno := .F.
			//Para mensageria assume o usuario logado, pois o usuario superior poderá utilizar o permissionamento do seu subordinado.
			If oMdlUsr:GetValue("AO4_CODUSR") == cCodUsr
				Help("",1,"CRMA200VCtrl",Nil,STR0006,1)  // "Você removeu seu permissionamento, por favor defina pelo menos uma permissão de acesso ou remove este acesso!"          
			Else
				Help("",1,"CRMA200VCtrl",Nil,STR0007+ FATPDObfuscate(UsrRetName(oMdlUsr:GetValue("AO4_CODUSR")),"AO4_NOMUSR")+STR0008,1) //"Para o usuário "###" não foi definido um permissionamento, por favor defina pelo menos uma permissão de acesso ou deleta este acesso!"   
			EndIf
			FATPDUnload()
			Exit
		EndIf
		
		//Se usuario possui Controle Total e o mesmo retirou o controle total de todas as linhas.
		If aCtrtAceUsr[PERM_CONTROLE_TOTAL] .AND. !lCtrtTotal
			If nX == oMdlUsr:Length()
				lRetorno := .F.
				Help("",1,"CRMA200VCtrl",Nil,STR0006,1) //"Não há usuários com permissão de controle total sobre este registro, por favor conceber pelo menos um usuário com este acesso."
			EndIf
		EndIf
		
	EndIf
Next nX

//Acessos - Equipes
If	lRetorno .AND. !IsInCallStack("CRMA240")
	
	For nX := 1 To oMdlEqp:Length()
	
		oMdlEqp:GoLine(nX)
		
		If !oMdlEqp:IsDeleted() .AND. !Empty( oMdlEqp:GetValue("AO4_CODEQP") )
		 
			If oMdlEqp:GetValue("AO4_CTRLTT") 
				lCtrtTotal := .T.
			ElseIf ( !oMdlEqp:GetValue("AO4_CTRLTT") .AND. !oMdlEqp:GetValue("AO4_PERVIS") .AND. !oMdlEqp:GetValue("AO4_PEREDT") .AND. !oMdlEqp:GetValue("AO4_PEREXC")  )
				lRetorno := .F.
				//Para mensageria assume o usuario logado, pois o usuario superior poderá utilizar o permissionamento do seu subordinado.
				If oMdlEqp:GetValue("AO4_CODEQP") == aRetEqUd[1]
					Help("",1,"CRMA200VCtrl",Nil,STR0006,1)  // "Você removeu seu permissionamento, por favor defina pelo menos uma permissão de acesso ou remove este acesso!"          
				Else
					Help("",1,"CRMA200VCtrl",Nil,STR0031+Posicione("ACA",1,cFilACA+oMdlEqp:GetValue("AO4_CODEQP"),"ACA_DESCRI")+STR0008,1) //"Para equipe "###" não foi definido um permissionamento, por favor defina pelo menos uma permissão de acesso ou deleta este acesso!"   
				EndIf			
				Exit
			EndIf
			
			//Se usuario possui Controle Total e o mesmo retirou o controle total de todas as linhas.
			If aCtrtAceUsr[PERM_CONTROLE_TOTAL] .AND. !lCtrtTotal
				If nX == oMdlEqp:Length()
					lRetorno := .F.
					Help("",1,"CRMA200VCtrl",Nil,STR0032,1) //"Não há equipes com permissão de controle total sobre este registro, por favor conceber pelo menos um usuário com este acesso."
				EndIf
			EndIf
			
		EndIf
	Next nX

Endif

//Acessos - Unidades de Venda
If	lRetorno .AND. !IsInCallStack("CRMA240")
	
	For nX := 1 To oMdlUnd:Length()
	
		oMdlUnd:GoLine(nX)
		
		If !oMdlUnd:IsDeleted() .AND. !Empty( oMdlUnd:GetValue("AO4_CODUND") )
		 
			If oMdlUnd:GetValue("AO4_CTRLTT") 
				lCtrtTotal := .T.
			ElseIf ( !oMdlUnd:GetValue("AO4_CTRLTT") .AND. !oMdlUnd:GetValue("AO4_PERVIS") .AND. !oMdlUnd:GetValue("AO4_PEREDT") .AND. !oMdlUnd:GetValue("AO4_PEREXC")  )
				lRetorno := .F.
				//Para mensageria assume o usuario logado, pois o usuario superior poderá utilizar o permissionamento do seu subordinado.
				If oMdlUnd:GetValue("AO4_CODUND") == aRetEqUd[2]
					Help("",1,"CRMA200VCtrl",Nil,STR0006,1)  // "Você removeu seu permissionamento, por favor defina pelo menos uma permissão de acesso ou remove este acesso!"          
				Else
					Help("",1,"CRMA200VCtrl",Nil,STR0033+Posicione("ADK",1,cFilADK+oMdlUnd:GetValue("AO4_CODUND"),"ADK_NOME")+STR0008,1) //"Para unidade "###" não foi definido um permissionamento, por favor defina pelo menos uma permissão de acesso ou deleta este acesso!"
				EndIf			
				Exit
			EndIf
			
			//Se usuario possui Controle Total e o mesmo retirou o controle total de todas as linhas.
			If aCtrtAceUsr[PERM_CONTROLE_TOTAL] .AND. !lCtrtTotal
				If nX == oMdlUnd:Length()
					lRetorno := .F.
					Help("",1,"CRMA200VCtrl",Nil,STR0034,1) //"Não há unidades com permissão de controle total sobre este registro, por favor conceber pelo menos um usuário com este acesso."
				EndIf
			EndIf
			
		EndIf
	Next nX

Endif

RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200VMAct

Valida se o Model(MPFormModel) pode ser ativado.

@sample	CRMA200VMAct(oModel)

@param		ExpO1 - Model do Controle de Privilegios do Registro (MPFormModel).
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/04/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRMA200VMAct(oModel)

Local nOperation	:= oModel:GetOperation()
Local lRetorno 		:= .T.

If ( nOperation == MODEL_OPERATION_UPDATE )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o permissionamento do Model do  			  	³
	//³ Controle de Privilegios do Registro (MPFormModel).	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CRMA200PerMdl(oModel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria criterios de filtros para serem utilizados na 	³
	//³ carga dos models (ModelField/ModelGrid). 				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CRMA200FMdl(oModel)	
	
EndIf

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200PerMdl

Verifica o permissionamento do Model do Controle de Privilegios do Registro (MPFormModel).

@sample	CRMA200PerMdl(oModel)

@param		ExpO1 - Model do Controle de Privilegios do Registro (MPFormModel).
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/04/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRMA200PerMdl(oModel)

Local oMdlUsr := oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
Local oMdlEqp := oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
Local oMdlUnd := oModel:GetModel("AO4DETUND")	//Acessos - Unidades de Venda 

If !( aCtrtAceUsr[PERM_CONTROLE_TOTAL] .OR. aCtrtAceUsr[PERM_COMPARTILHAR] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite adicionar linhas(Compartilhar Registros) sem  ³
	//³ verificar as permissoes do usuario tem sobre o registro.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMdlUsr:SetNoInsertLine(.T.)
	oMdlEqp:SetNoInsertLine(.T.)
	oMdlUnd:SetNoInsertLine(.T.)	
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200WCpo

( Bloqueia ou Nao ) os campos que controla o permissionamento do registro conforme
os direitos de acessos que o usuario possui.

@sample	CRMA200WCpo(cCampo)

@param		ExpC1 - Campo (X3_CAMPO)
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/04/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Function CRMA200WCpo(cCampo)

Local lRetorno 	:= .F.
Local oModel	:= FwModelActive()
Local oMdlUsr	:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
Local oMdlEqp	:= oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
Local oMdlUnd	:= oModel:GetModel("AO4DETUND")	//Acessos - Unidades de Venda
Local cCodUsr	:= "" 			
Local aRetEqUd 	:= CRMXVdEqUd(cCodUsr)	
Local nFolder 	:= 1

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

cCodUsr := If(lMVCRMUAZS, CRMXCodUser(), RetCodUsr())

If IsInCallStack("CRMA200Auto")
	lRetorno := .T.
Else

	If aCtrtAceUsr[PERM_CONTROLE_TOTAL]  
		lRetorno := .T.
	Else
	
		nFolder 	:= CRMA200Folder()
		
		If	nFolder == 1
		
				//Acessos - Usuarios do CRM
				Do Case
					Case ( AllTrim(cCampo) == "AO4_PERVIS" .AND. aCtrtAceUsr[PERM_VISUALIZAR] .AND. (oMdlUsr:GetValue("AO4_CODUSR") == aCtrtAceUsr[PERM_CODUSR] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREDT" .AND. aCtrtAceUsr[PERM_EDITAR] .AND. (oMdlUsr:GetValue("AO4_CODUSR") == aCtrtAceUsr[PERM_CODUSR].OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREXC" .AND. aCtrtAceUsr[PERM_EXCLUIR] .AND. (oMdlUsr:GetValue("AO4_CODUSR") == aCtrtAceUsr[PERM_CODUSR] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PERCOM" .AND. aCtrtAceUsr[PERM_COMPARTILHAR] )
						lRetorno := .T.
				EndCase
			
		ElseIF	 nFolder == 2
		
				//Acessos - Equipes
				Do Case
					Case ( AllTrim(cCampo) == "AO4_PERVIS" .AND. aCtrtAceUsr[PERM_VISUALIZAR] .AND. (oMdlEqp:GetValue("AO4_CODEQP") == aRetEqUd[1] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREDT" .AND. aCtrtAceUsr[PERM_EDITAR] .AND. (oMdlEqp:GetValue("AO4_CODEQP") == aRetEqUd[1] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREXC" .AND. aCtrtAceUsr[PERM_EXCLUIR] .AND. (oMdlEqp:GetValue("AO4_CODEQP") == aRetEqUd[1] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PERCOM" .AND. aCtrtAceUsr[PERM_COMPARTILHAR] )
						lRetorno := .T.
				EndCase
				
		ElseIf nFolder == 3 
		
				//Acessos - Unidades de Venda
				Do Case
					Case ( AllTrim(cCampo) == "AO4_PERVIS" .AND. aCtrtAceUsr[PERM_VISUALIZAR] .AND. (oMdlUnd:GetValue("AO4_CODUND") == aRetEqUd[2] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREDT" .AND. aCtrtAceUsr[PERM_EDITAR] .AND. (oMdlUnd:GetValue("AO4_CODUND") == aRetEqUd[2] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PEREXC" .AND. aCtrtAceUsr[PERM_EXCLUIR] .AND. (oMdlUnd:GetValue("AO4_CODUND") == aRetEqUd[2] .OR. aCtrtAceUsr[PERM_COMPARTILHAR]) )
						lRetorno := .T.
					Case ( AllTrim(cCampo) == "AO4_PERCOM" .AND. aCtrtAceUsr[PERM_COMPARTILHAR] )
						lRetorno := .T.
				EndCase		
				
		Endif 				
				
	EndIf

EndIf
	
Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200VCpo

Valida se o campo pode ser alterado ou nao conforme os direitos de acessos que 
usuario possui.

@sample	CRMA200VCpo(cCampo)

@param		ExpC1 - Campo (X3_CAMPO)
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/04/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Function CRMA200VCpo(cCampo)

Local oModel		:= FwModelActive()
Local oPModVld		:= 0
Local lRetorno 		:= .T.
Local cCodUsr		:= "" 
Local aRetEqUd 		:= CRMXVdEqUd(cCodUsr)
Local nFolder		:= CRMA200Folder()
Local cCpoVld		:= ""

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

IF lMVCRMUAZS
	cCodUsr := If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
EndIf

If			nFolder == 1 
			oPModVld	:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
			cCpoVld	:= "AO4_CODUSR"
			cCntVld	:= cCodUsr
ElseIf		nFolder == 2	 
			oPModVld	:= oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
			cCpoVld	:= "AO4_CODEQP"
			cCntVld	:= aRetEqUd[1]						
ElseIf		nFolder == 3 
			oPModVld	:= oModel:GetModel("AO4DETUND")	//Acessos - Unidades de Venda
			cCpoVld	:= "AO4_CODUND"
			cCntVld	:= aRetEqUd[2]						
EndIf 	

Do Case
	// Caso os campos Visualizar, Editar, Excluir e Compartilhar estiverem marcados conceber o controle total.
	Case (	oPModVld:GetValue("AO4_PERVIS") .AND. oPModVld:GetValue("AO4_PEREDT") .AND. oPModVld:GetValue("AO4_PEREXC") .AND. oPModVld:GetValue("AO4_PERCOM") )	
		oPModVld:LoadValue("AO4_CTRLTT",.T.)
		oPModVld:LoadValue("AO4_PERVIS",.F.)
		oPModVld:LoadValue("AO4_PEREDT",.F.)
		oPModVld:LoadValue("AO4_PEREXC",.F.)
		oPModVld:LoadValue("AO4_PERCOM",.F.)
		oPModVld:LoadValue("AO4_DTVLD" ,cTod(" / / "))	
	Case ( AllTrim(cCampo) == "AO4_DTVLD" .AND. !Empty(oPModVld:GetValue("AO4_DTVLD")) .AND. oPModVld:GetValue("AO4_CTRLTT")  )
		lRetorno := .F.
		Help("", 1,"CRMA200VCpo",Nil,STR0042,1) //"Este acesso possui controle total a data de validade deverá ser desconsiderada."
	// Nao permite marcar os campos de Visualizar, Editar, Excluir e Compartilhar, caso o campo Controle Total estiver marcado.
	Case ( AllTrim(cCampo) <> "AO4_CTRLTT" .AND. oPModVld:GetValue("AO4_CTRLTT") )
		lRetorno := .F.
		//Para mensageria assume o usuario logado, pois o usuario superior poderá utilizar o permissionamento do seu subordinado.
		If oPModVld:GetValue(cCpoVld) == cCntVld	
			Help("", 1,"CRMA200VCpo",Nil,STR0009,1) // "Você já possui o controle total deste registro."
		Else
		
			If	cCpoVld == "AO4_CODUSR"
				Help("", 1,"CRMA200VCpo",Nil,STR0010,1) // "Este usuário já possui o controle total deste registro."
			ElseIf	cCpoVld == "AO4_CODEQ"	 
				Help("", 1,"CRMA200VCpo",Nil,STR0040,1) // "Esta equipe já possui o controle total deste registro."
			Else
				Help("", 1,"CRMA200VCpo",Nil,STR0041,1) // "Esta unidade já possui o controle total deste registro."			
			Endif 						
							
		EndIf    
	// Caso usuario marcar seu acesso como controle total desmarcar os campos de Visualizar, Editar, Excluir e Compartilhar
	Case ( AllTrim(cCampo) == "AO4_CTRLTT" .AND. oPModVld:GetValue("AO4_CTRLTT") )
		oPModVld:LoadValue("AO4_PERVIS",.F.)
		oPModVld:LoadValue("AO4_PEREDT",.F.)
		oPModVld:LoadValue("AO4_PEREXC",.F.)
		oPModVld:LoadValue("AO4_PERCOM",.F.)
		oPModVld:LoadValue("AO4_DTVLD" ,cTod(" / / "))
	// Caso o usuario marcar o acesso de Editar ou Excluir, desmarcar o campo Visualizar pois este acesso liberado automaticamente.
	Case ( AllTrim(cCampo) +"|" $ "AO4_PEREDT|AO4_PEREXC|" .AND. oPModVld:GetValue(cCampo) )
		oPModVld:LoadValue("AO4_PERVIS",.T.)
	// Caso o usuario desmarcar permissao de editar e excluir desmarca Visualizar.	
	Case ( AllTrim(cCampo) +"|" $ "AO4_PEREDT|AO4_PEREXC|" .AND. ( !oPModVld:GetValue("AO4_PEREDT") .AND. !oPModVld:GetValue("AO4_PEREXC") ) )
		oPModVld:LoadValue("AO4_PERVIS",.F.)
	// Caso o usuario compartilhar o registro conceber a permissao de visualizar.
	Case ( AllTrim(cCampo) == "AO4_PERCOM" .AND. oPModVld:GetValue("AO4_PERCOM") )
		oPModVld:LoadValue("AO4_PERVIS",.T.) 
	Case ( AllTrim(cCampo) == "AO4_PERVIS" .AND. ( oPModVld:GetValue("AO4_PEREDT") .OR. oPModVld:GetValue("AO4_PEREXC") .OR. oPModVld:GetValue("AO4_PERCOM") ) )
		lRetorno := .F.
		Help("", 1,"CRMA200VCpo",Nil,STR0011,1) //"A permissão de visualização não poderá ser removida."		
	
EndCase

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200FMdl

Cria criterios de filtros para serem utilizados na carga dos models (ModelField/ModelGrid)
do Controle de Privilegios do Registro. (Neste filtro somente o usuario que possui controle
total sobre o registro visualiza todos os permissionamentos)

@sample	CRMA200FMdl(oModel)

@param		ExpO1 - Model do Controle de Privilegios do Registro (MPFormModel).
	
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/04/2014 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function CRMA200FMdl(oModel)

Local aArea			:= GetArea()
Local aAreaAO4		:= AO4->(GetArea())	
Local aLoadFilter		:= {}
Local oMdlUsr			:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
Local oMdlEqp			:= oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
Local oMdlUnd			:= oModel:GetModel("AO4DETUnd")	//Acessos - Unidades de Venda

If !aCtrtAceUsr[PERM_CONTROLE_TOTAL]
	aLoadFilter := {	{"AO4_CODUSR",aCtrtAceUsr[PERM_CODUSR],MVC_LOADFILTER_EQUAL,MVC_LOADFILTER_OR},;
						{"AO4_USRCOM",aCtrtAceUsr[PERM_CODUSR],MVC_LOADFILTER_EQUAL,MVC_LOADFILTER_OR}}	
	oMdlUsr:SetLoadFilter(aLoadFilter,/*cLoadFilter*/)
EndIf

RestArea(aAreaAO4)
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200DReg

Retorna a descricao do registro, conforme o seu display informado no SX2.

@sample	CRMA200DReg(cAliasEnt)

@param		ExpC1 - Alias do registro

@return	ExpC  - Descricao do registro

@author	Anderson Silva
@since		04/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200DReg(cAliasEnt)

Local cDisplay 	:= CRMXGetSX2(cAliasEnt)[2] 
Local cDescReg	:= IIF(!Empty(cDisplay), AllTrim((cAliasEnt)->&(cDisplay)),"") 

Return(cDescReg)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200NUsr

Retorna o nome do usuario que compartilhou o registro.

@sample	CRMA200NUsr()

@param		ExpC -  Campo que possui o codigo do Usuario.

@return	ExpC  - Nome do Usuario

@author	Anderson Silva
@since		04/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200NUsr(cCampo,cMdlGrid)

Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local oMdlGrid		:= Nil
Local cNomeUsr 		:= ""

Default cCampo 		:= ""
Default cMdlGrid	:= ""

If !Empty(cCampo) .AND. !Empty(cMdlGrid) .AND. nOperation <> MODEL_OPERATION_INSERT

	oMdlGrid := oModel:GetModel(cMdlGrid)
	
	If cCampo == "AO4_CODUSR"
		If oMdlGrid:Length() == 0 .AND. !Empty(AO4->AO4_CODUSR)
			cNomeUsr := UsrRetName(AO4->AO4_CODUSR)
		EndIf
	ElseIf cCampo == "AO4_USRCOM"
		If oMdlGrid:Length() == 0 .AND. !Empty(AO4->AO4_USRCOM)
			cNomeUsr := UsrRetName(AO4->AO4_USRCOM)
		EndIf
	EndIf
		
EndIf
	
Return(cNomeUsr)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200VUsr

Valida o campo Codigo do Usuario.

@sample	CRMA200VUsr()

@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		04/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200VUsr()

Local oModel		:= FwModelActive()
Local oMdlInf		:= oModel:GetModel("AO4MASTER")	//Informacoes do Registro - CABECALHO
Local oMdlUsr		:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
 
Local lRetorno 	:= .T.

lRetorno := ( ( Vazio() .OR. UsrExist(oMdlUsr:GetValue("AO4_CODUSR")) ) .AND. ExistChav("AO4",oMdlInf:GetValue("AO4_ENTIDA")+oMdlInf:GetValue("AO4_CHVREG")+oMdlUsr:GetValue("AO4_CODUSR"),1) )

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200Auto

Rotina Automatica do Controle de Privilegios do Registro.

@sample	CRMA200Auto(aAO4Master,aAO4Detail,nOpcAuto)

@param		ExpA1 - Informacoes Principais do Registro (Entidade / Chave Unica).
			ExpA2 - Lista com as Permissoes de Acesso ao Registro.
			ExpN3 - Numero da Operacao da Rotina Automatica.

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		05/08/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA200Auto(aAO4Master,aAO4Detail,nOpcAuto)

Local lRetorno 		:= .T.
Local lSeekLine		:= .F.
Local aArea			:= GetArea()
Local aAreaAO4 		:= AO4->(GetArea())
Local aAreaAO3 		:= AO3->(GetArea())
Local aErro			:= {}
Local oMdlInf		:= Nil
Local oMdlPos		:= Nil
Local nLinAtu		:= 0
Local nNewLin		:= 0
Local nI			:= 0
Local nX			:= 0
Local nPCpoChv		:= 0
Local nPCodUsr 		:= 0
Local nPCodEqp 		:= 0
Local nPCodUnd 		:= 0
Local nPTpAces		:= 0
Local cCpoChv			:= ""

Default aAO4Master	:= {}
Default aAO4Detail	:= {}
Default nOpcAuto		:= MODEL_OPERATION_INSERT
 
// Criado o model como estatico para evitar de carregar o model quando a rotina automatica é chamada mais de uma vez. Evitando assim estouro de memoria.
Static oModel			:= Nil

If ( Len(aAO4Master) > 0  .AND. ( Len(aAO4Detail) > 0 .OR. nOpcAuto == MODEL_OPERATION_DELETE ) )

	//Controle de Privilegios do Registro somente para as entidades cadastradas na funcao CRMXCtrlEnt
	If aAO4Master[1][2] $ CRMXCtrlEnt()
	
		DbSelectArea("AO4")		// Controle de Privilégios
		AO4->(DbSetOrder(1)) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR

		If nOpcAuto <> MODEL_OPERATION_INSERT
			// Posiciona no registro para atualização ou remocao dos privilegios.
			If !AO4->(DbSeek(xFilial("AO4")+aAO4Master[1][2]+aAO4Master[2][2]))
				If ( nOpcAuto <> MODEL_OPERATION_DELETE .And. !IsBlind() .And. Type("nModulo") == "N" .And. nModulo == 73 )
					Help("",1,"CRMA200Auto",Nil,STR0002,1)  // "Não foi possível acessar os privilegios deste registro!"
				EndIf
				lRetorno := .F.
			EndIf
		EndIf

		If lRetorno
			
			If oModel == Nil
				oModel := ModelDef() 
			EndIf
			
			oModel:SetOperation(nOpcAuto)
			oModel:Activate() 
			oMdlInf := oModel:GetModel("AO4MASTER")
				
			If  nOpcAuto == MODEL_OPERATION_INSERT .OR. nOpcAuto == MODEL_OPERATION_UPDATE
			
				nPCodUsr 	:= aScan(aAO4Detail[1],{|x| x[1] == "AO4_CODUSR"})
				nPCodEqp 	:= aScan(aAO4Detail[1],{|x| x[1] == "AO4_CODEQP"})
				nPCodUnd 	:= aScan(aAO4Detail[1],{|x| x[1] == "AO4_CODUND"})
				nPTpAces	:= aScan(aAO4Detail[1],{|x| x[1] == "AO4_TPACES"})
			
				If nOpcAuto == MODEL_OPERATION_INSERT 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cabeçalho - Informacoes do Registro.  ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 To Len(aAO4Master)
						oMdlInf:SetValue(aAO4Master[nX][1],aAO4Master[nX][2])
					Next nX
					
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grid - Privilegios do Registro. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_nFolderAuto := 1
				
				For nX := 1 To Len(aAO4Detail)
				
					If lRetorno

						For nI := 1 To Len(aAO4Detail[nX])
						
							//Verifica se a linha passada na AO4Detail existe no ModelGrid.
							If nI == 1
							
								If	aAO4Detail[nX][nPTpAces][2] == "1"	
									oMdlPos	:= oModel:GetModel("AO4DETUSR")	//Acessos - Usuarios do CRM
									cCpoChv	:= "AO4_CODUSR"
									nPCpoChv	:= nPCodUsr
								Endif
								
								If	aAO4Detail[nX][nPTpAces][2] == "2"	
									oMdlPos 	:= oModel:GetModel("AO4DETEQP")	//Acessos - Equipes
									cCpoChv	:= "AO4_CODEQP"
									nPCpoChv	:= nPCodEqp
								Endif

								If	aAO4Detail[nX][nPTpAces][2] == "3"		
									oMdlPos	:= oModel:GetModel("AO4DETUND")	//Acessos - Unidades de Venda
									cCpoChv	:= "AO4_CODUND"
									nPCpoChv	:= nPCodUnd
								Endif

								If nOpcAuto == MODEL_OPERATION_UPDATE
									lSeekLine := oMdlPos:SeekLine({{cCpoChv,aAO4Detail[nX][nPCpoChv][2]}})	//Codigo do Usuario	
								EndIf
								
								If !lSeekLine .And. ValType(oMdlPos) == "O"	
								
									nLinAtu := oMdlPos:Length()	
									oMdlPos:GoLine(nLinAtu)	

									//Folder Usuario 
									If aAO4Detail[nX][11][2] == "1" .AND. !Empty(oMdlPos:GetValue("AO4_CODUSR"))		 
										nNewLin := oMdlPos:AddLine()
										If nNewLin == nLinAtu
											lRetorno := .F. 
											Exit
										EndIf
									EndIf

									//Folder Equipe	
									If aAO4Detail[nX][11][2] == "2" .AND. !Empty(oMdlPos:GetValue("AO4_CODEQP"))	 
										nNewLin := oMdlPos:AddLine()
										If nNewLin == nLinAtu
											lRetorno := .F. 
											Exit
										EndIf
									EndIf

									//Folder Unidade de Negocio
									If aAO4Detail[nX][11][2] == "3" .AND. !Empty(oMdlPos:GetValue("AO4_CODUND"))	//Codigo da Unidade de Venda	 
										nNewLin := oMdlPos:AddLine()
										If nNewLin == nLinAtu
											lRetorno := .F. 
											Exit
										EndIf
									EndIf
									
								EndIf
								lSeekLine := .F.
							EndIf
							
							If ValType(oMdlPos) == "O"
								lRetorno := oMdlPos:SetValue(aAO4Detail[nX][nI][1],aAO4Detail[nX][nI][2])
							Else
								lRetorno := .F.
							EndIf
							
							If !lRetorno 
								lRetorno := .F.
								Exit
							EndIf			
							
						Next nI
					Else
						Exit
					EndIf
				Next nX 
			
			EndIf
			
			If oModel:VldData()
				oModel:CommitData()
			Else
				lRetorno := .F.
				aErro := oModel:GetErrorMessage()
				AutoGrLog(STR0016	 + ' [' + AllToChar(aErro[1]) + ']') //"Id do formulário de origem:"
				AutoGrLog(STR0017	 + ' [' + AllToChar(aErro[2]) + ']') //"Id do campo de origem: "
				AutoGrLog(STR0018	 + ' [' + AllToChar(aErro[3]) + ']') //"Id do formulário de erro: "
				AutoGrLog(STR0019	 + ' [' + AllToChar(aErro[4]) + ']') //"Id do campo de erro: "
				AutoGrLog(STR0020	 + ' [' + AllToChar(aErro[5]) + ']') //"Id do erro: "
				AutoGrLog(STR0021	 + ' [' + AllToChar(aErro[6]) + ']') //"Mensagem do erro: "
				AutoGrLog(STR0022	 + ' [' + AllToChar(aErro[7]) + ']') //"Mensagem da solução: "
				AutoGrLog(STR0023	 + ' [' + AllToChar(aErro[8]) + ']') //"Valor atribuído: "
				AutoGrLog(STR0024	 + ' [' + AllToChar(aErro[9]) + ']') //"Valor anterior: "
				//Mostra o erro se tiver interface ou se nao há geracao de log no arquivo.
				If ( !IsBlind() .Or. Type("lAutoErrNoFile") == "L" .And. !lAutoErrNoFile )
					MostraErro()
				EndIf
			EndIf

			oModel:DeActivate() 
			
		EndIf
		 
	EndIf 

Else
	lRetorno := .F.
	If ( !IsBlind() .And. Type("nModulo") == "N" .And. nModulo == 73 ) 
		Help("",1,"CRMA200Auto",Nil,STR0012,1)	//"Não foi possível executar a rotina automática Controle de Privilégios, verifique se os parametros estão sendo passado corretamente!"
	EndIf
EndIf

//Reseta a variavel aCtrtAceUsr com valor padrao.
CRMA200RstAce()
	
RestArea(aAreaAO4)
RestArea(aAreaAO3)
RestArea(aArea)
	
Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200PAut

Prepara arrays aAO4Master e aAO4Detail com informações para serem utilizados na
Rotina Automatica do Controle de Privilegios do Registro.

@sample	CRMA200PAut(nOperation,cEntidade,cChave,cCodUsr,aPermissoes,aNvlEstrut,cCodUsrCom,dDataVld)

@param		ExpN1 - Tipo de Operacao para montar o arrays para utilizar no Controle de Privilegios.
			ExpC2 - Entidade que terá Controle de Privilegios do Registro.
			ExpC3 - Chave Unica.
			ExpC4 - Usuario que terá Acesso ao Registro.
			ExpA5 - Permissionamento [Controle Total,Visualizar,Editar,Excluir,Compartilhar].
			ExpA6 - Nivel da Estrutura de Negocio [Id da Estrutura,Nivel].
			ExpC7 - Usuario que compartilhou o Registro.
			ExpD8 - Data de Validade do Permissionamento.
			ExpC9 - Codigo da Equipe
			ExpC10 - Codigo da Unidade de Negocio
			ExpC11 - Proprietario do Registro
			ExpC12 - Sequencia + Papel do Usuario

@return	ExpC  - Descricao do registro

@author	Anderson Silva
@since		04/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200PAut( 	nOperation,cEntidade,cChave,cCodUsr,aPermissoes,aNvlEstrut,;
					 	cCodUsrCom,dDataVld,cCodEqp,cCodUnd,lPropri,cSeqPaper	)

Local aArea		:= GetArea()
Local aAreaAO3	:= AO3->(GetArea())
Local aAreaAO4	:= AO4->(GetArea())
Local aAreaAZS	:= AZS->(GetArea())

Local aAO4Master	:= {}
Local aAO4Detail 	:= {}
Local cIdEstN 		:= ""
Local cPrioriza		:= "0"
Local nNvEstN 		:= 0
Local cTpAces		:= ""
Local cFilAO4		:= xFilial("AO4")
Local lPEPAut		:= ExistBlock("CRM200PAUT")
Local aAux			:= {}

Default nOperation	:= MODEL_OPERATION_INSERT
Default cEntidade 	:= ""
Default cChave    	:= ""
Default cCodUsr  	:= ""
Default cCodEqp		:= ""
Default cCodUnd		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permissoes do registro que será atribuido para usuario. ³
//³ aPermissoes[1] => Controle Total						    ³
//³ aPermissoes[2] => Visualizar							    ³
//³ aPermissoes[3] => Alterar								    ³
//³ aPermissoes[4] => Excluir								    ³
//³ aPermissoes[5] => Compartilhar 						    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default aPermissoes	:= {.T.,.F.,.F.,.F.,.F.} 

Default aNvlEstrut	:= {}
Default cCodUsrCom 	:= ""
Default dDataVld	:= cTod("//")
Default cCodEqp		:= ""
Default cCodUnd		:= ""
Default lPropri     := .F.
Default cSeqPaper	:= "" 

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação necessário, para a integração com aplicativo Umov, que o Usuario ³
//³ é passado por arquivo .txt                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("cCR540CodU") == "C" .AND. !Empty(cCR540CodU)
	cCodUsr := cCR540CodU
ElseIf Empty(cCodUsr) .AND. Empty(cCodEqp) .AND. Empty(cCodUnd)
	cCodUsr := If(lMVCRMUAZS, CRMXCodUser(), RetCodUsr()) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nivel da Estrutura de Negocio que usuario pertence.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cCodUsr )
		
	If Empty( aNvlEstrut ) .And. Empty( cSeqPaper )
		//Retorna codigo inteligente e o nivel da estrutura de negocio de acordo com
		//papel do usuario logado no sistema.
		aUserPaper	:= CRMXGetPaper()
		If ( !Empty( aUserPaper ) .And. aUserPaper[USER_PAPER_CODUSR] == cCodUsr )
			cIdEstN 	:= aUserPaper[USER_PAPER_IDESTN]
			nNvEstN 	:= aUserPaper[USER_PAPER_NVESTN]
			cSeqPaper	:= aUserPaper[USER_PAPER_SEQUEN] + aUserPaper[USER_PAPER_CODPAPER]	
		EndIf
	Else
		DbSelectArea("AZS")
		
		//Se passar o Id. da Estrutura pega o papel
		If !Empty( aNvlEstrut )
			
			cIdEstN	:= aNvlEstrut[1] 
			nNvEstN := aNvlEstrut[2] 
			
			AZS->( DbSetOrder(3) ) //AZS_FILIAL + AZS_CODUSR + AZS_IDESTN
			
			If AZS->( DbSeek(xFilial("AZS") + cCodUsr + cIdEstN ) )
				cSeqPaper	= AZS->AZS_SEQUEN + AZS->AZS_PAPEL
			EndIf
			
		//Se passar o Papel pega o Id. da Estrutura
		ElseIf !Empty( cSeqPaper ) 
		
			AZS->( DbSetOrder(1) ) //AZS_FILIAL + AZS_CODUSR + AZS_IDESTN
			
			If AZS->( DbSeek(xFilial("AZS") + cCodUsr + cSeqPaper ) )
				cIdEstN	:= AZS->AZS_IDESTN
				nNvEstN := AZS->AZS_NVESTN 
			EndIf		
			
		EndIf
	
	EndIf

EndIf

If Len(aNvlEstrut) == 0 .AND. !Empty(cCodUsr)
	aNvlEstrut := CRMXNvlEst(cCodUsr)
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabeçalho - Informacoes do Registro. ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aAO4Master,{"AO4_ENTIDA",cEntidade	,Nil})
aAdd(aAO4Master,{"AO4_CHVREG",cChave		,Nil})
aAdd(aAO4Master,{"AO4_PRIORI",cPrioriza	,Nil})	// Sequencia de priorizacao
 
If nOperation == MODEL_OPERATION_UPDATE

	DbSelectArea("AO4")
	AO4->(DbSetOrder(1)) // AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
	If DbSeek(cFilAO4 + cEntidade + cChave)	
		While(	AO4->(!EOF()) .AND. AO4->AO4_FILIAL == cFilAO4 .AND.;
				AO4->AO4_ENTIDA == cEntidade .AND. AllTrim(AO4->AO4_CHVREG) == AllTrim(cChave)  )
				
				aAux :=	{ 	{"AO4_CODUSR",AO4->AO4_CODUSR	,Nil},;
							{"AO4_CTRLTT",AO4->AO4_CTRLTT	,Nil},;
							{"AO4_PERVIS",AO4->AO4_PERVIS	,Nil},;
							{"AO4_PEREDT",AO4->AO4_PEREDT	,Nil},;
							{"AO4_PEREXC",AO4->AO4_PEREXC	,Nil},;
							{"AO4_PERCOM",AO4->AO4_PERCOM	,Nil},;
							{"AO4_USRCOM",AO4->AO4_USRCOM	,Nil},;
							{"AO4_IDESTN",AO4->AO4_IDESTN	,Nil},;
							{"AO4_NVESTN",AO4->AO4_NVESTN	,Nil},;	
							{"AO4_DTVLD" ,AO4->AO4_DTVLD	,Nil},;
							{"AO4_TPACES",AO4->AO4_TPACES	,Nil},;
							{"AO4_CODEQP",AO4->AO4_CODEQP	,Nil},; 
							{"AO4_CODUND",AO4->AO4_CODUND	,Nil} }
				If lMVCRMUAZS
					Aadd(aAux, {"AO4_PROPRI",AO4->AO4_PROPRI,Nil} )
					Aadd(aAux, {"AO4_USRPAP",AO4->AO4_USRPAP,Nil} )
				EndIf
				aAdd(aAO4Detail, AClone(aAux))
			AO4->(DbSkip())
		EndDo
	EndIf 
EndIf	 

If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )
	
	Do Case
		// Usuario do CRM
		Case !Empty(cCodUsr)
			cIdEstN := aNvlEstrut[1]
			nNvEstN := aNvlEstrut[2]
			cTpAces := "1"
			cCodEqp := ""
			cCodUnd := ""
		// Equipes
		Case !Empty(cCodEqp)
			cTpAces := "2"
			cCodUsr := ""
			cCodUnd := ""
			cSeqPaper := ""
		// Unidades de Venda
		Case !Empty(cCodUnd)
			cTpAces := "3"
			cCodUsr := ""
			cCodEqp := ""
			cSeqPaper	:= ""
	End Case	
	
	If !Empty(cTpAces)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessos - Usuario  do CRM - Equipe - Unidade de Venda  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		aAux := {	{"AO4_CODUSR",cCodUsr									,Nil},;	// Codigo do Usuario
					{"AO4_CTRLTT",aPermissoes[1]							,Nil},;	// Controle Total
					{"AO4_PERVIS",aPermissoes[2]							,Nil},;	// Visualizar
					{"AO4_PEREDT",aPermissoes[3]							,Nil},;	// Alterar
					{"AO4_PEREXC",aPermissoes[4]							,Nil},;	// Excluir
					{"AO4_PERCOM",aPermissoes[5]							,Nil},;	// Compartilhar
					{"AO4_USRCOM",cCodUsrCom								,Nil},;	// Usuario Compartilhador do Registro
					{"AO4_IDESTN",AllTrim(cIdEstN )							,Nil},;	// Id do Usuario na Estrutura
					{"AO4_NVESTN",nNvEstN									,Nil},;	// Nivel do Usuario na Estrutura
					{"AO4_DTVLD" ,dDataVld									,Nil},;	// Data de Validade
					{"AO4_TPACES",AllTrim( cTpAces )						,Nil},;	// Tipo de acesso (1-Usuarios do CRM / 2-Equipes / 3-Unidades de Negocio)
					{"AO4_CODEQP",AllTrim( cCodEqp )						,Nil},;	// Codigo da equipe 
					{"AO4_CODUND",AllTrim( cCodUnd )						,Nil} }	// Codigo da unidade de venda
		If lMVCRMUAZS
			Aadd(aAux, {"AO4_PROPRI",lPropri,Nil}) // Proprietario
			Aadd(aAux, {"AO4_USRPAP",AllTrim( cSeqPaper ),Nil})	// Sequencia + Papel
		EndIf  
		aAdd(aAO4Detail, AClone(aAux))
		If lPEPAut
			aPEVar		:= {nOperation, cEntidade, cChave, aAO4Detail}
			aAO4DetPE	:= ExecBlock("CRM200PAUT", .F., .F., aPEVar)
			If ValType(aAO4DetPE) == "A"
				aAO4Detail	:= aClone(aAO4DetPE)
			EndIf
		EndIf	
	EndIf
							
EndIf

RestArea(aAreaAO4)
RestArea(aAreaAO3)
RestArea(aArea)
Return({aAO4Master,aAO4Detail}) 
 
//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200RstAce

Reseta a variavel aCtrtAceUsr com valor padrao.

@sample	CRMA200RstAce()

@param		Nenhum

@return	Nenhum

@author	Anderson Silva
@since		30/09/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRMA200RstAce()
If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

aCtrtAceUsr := {If(lMVCRMUAZS, CRMXCodUser(), RetCodUsr()) ,.T.,.F.,.F.,.F.,.F.}
Return Nil


//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200Folder

Retorna numero do folder posicionado

@sample	CRMA200Folder()

@param		Nenhum

@return	ExpN1 - Numero do folder posicionado  

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRMA200Folder()

Local oView 		:= FwViewActive()
Local nFolder		:= 1

If IsInCallStack("CRMA200Auto")
	nFolder := _nFolderAuto 
Else
	oView := FwViewActive()
	If	oView <> Nil
		aFolSel	:= oView:GetFolderActive("PASTAS",2)
		If Len(aFolSel) > 0
			nFolder	:= aFolSel[1]
		EndIf
	Endif
EndIf 

Return(nFolder)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200SqAp

Retorna a descricao da sequencia de priorizacao que sera aplicada no registro

@sample	CRMA200SqAp()

@param		Nenhum

@return	ExpC1 - Descricao da sequencia   

@author	Eduardo Gomes Junior 
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200SqAp()

Local oModel		:= FwModelActive()
Local oMdlInf		:= oModel:GetModel("AO4MASTER")
Local cDesSeqAp 	:= oMdlInf:GetValue("AO4_PRIORI")
Local nSeq			:= 1
Local cSeqNome		:= ""
Local cMontSeq		:= ""

If	cDesSeqAp <> "0"

	For nSeq:=1 To Len(Alltrim(cDesSeqAp))
		
		If			SubsTR(cDesSeqAp,nSeq,1) == "1"
					cMontSeq := STR0025	//"Usuários do CRM"
		ElseIf		SubsTR(cDesSeqAp,nSeq,1) == "2"
					cMontSeq := STR0026	//"Equipes"	
		Else
					cMontSeq := STR0027	//"Unidades de Negócio"	
		Endif
		
		cSeqNome += cMontSeq + " --> " 
	
	Next nSeq
	
Else 

	cSeqNome := STR0035	//"SOMA"

Endif 	

Return(cSeqNome)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM200F3Ord

Interface para selecao de priorizacao do registro (LISTBOX). Usado na consulta especifica AOESEQ (SXB) campo: AO4_SEQPRI 

@sample	CRM200F3Ord()

@param		Nenhum

@return	ExpL1 - Verdadeiro / Falso   

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRM200F3Ord()

Local oModel		:= FwModelActive()
Local oMdlInf		:= oModel:GetModel("AO4MASTER")	//Informacoes do Registro - CABECALHO

Local	cTGet		:= ""
Local 	lRet		:= .F.
Local	lMark		:= .F.

Local	aCampos	:= {}

Local oDlg		:= Nil
Local 	oColEnt	:= Nil
Local 	oLINEONE	:= Nil
Local oLINETWO	:= Nil
Local oTGet		:= Nil
Local oPanel		:= Nil

Local	oBrwMark  := .F.

Local 	nAp := 1
Local cSequApl	:= "" 

Static  cCRM200ORI  := ""  //variavel que receberá a chave de origem

AAdd( aCampos,{lMark,STR0035,"0"} )	//"Soma"
AAdd( aCampos,{lMark,STR0025,"1"} )	//"Usuários do CRM"
AAdd( aCampos,{lMark,STR0026,"2"} )	//"Equipes"
AAdd( aCampos,{lMark,STR0027,"3"} )	//"Unidades de Negócio"
     
oDlg := FWDialogModal():New()

oDlg:SetBackground(.F.) 	// .T. -> escurece o fundo da janela 
oDlg:SetTitle(STR0036)	//"Selecione a sequencia para priorizar o registro"
oDlg:SetEscClose(.T.)	//permite fechar a tela com o ESC
oDlg:SetSize(200,300) 	//cria a tela maximizada (chamar sempre antes do CreateDialog)
oDlg:EnableFormBar(.T.) 
oDlg:CreateDialog() 				//cria a janela (cria os paineis)

oPanel := oDlg:getPanelMain()

oDlg:createFormBar()				//cria barra de botoes
oDlg:addYesNoButton()

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.) 
oFWLayer:AddLine( "LINEONE",10, .F.)
oFWLayer:AddLine( "LINETWO",90, .F.)
oLINEONE := oFwLayer:GetLinePanel("LINEONE")
oLINETWO := oFwLayer:GetLinePanel("LINETWO")
	
oTGet := TGet():New( 03,05,{||cTGet},oLINEONE,0290,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet,,,, )
			
DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oLINETWO  
	ADD MARKCOLUMN oColEnt DATA {|| IIF(aCampos[oBrwMark:At()][1],"LBOK","LBNO") } DOUBLECLICK {||aCampos[oBrwMark:At()][1] := !aCampos[oBrwMark:At()][1] ,CRM200ChvOri(oBrwMark,aCampos,oTGet,@cTGet)} OF oBrwMark 
	ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][2] }") TITLE STR0037 TYPE "C" SIZE 160 OF oBrwMark		//"Priorização a ser aplicada"
	ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][3] }") TITLE STR0038 TYPE "C" SIZE 001 OF oBrwMark		//"ID"				
				
ACTIVATE FWBROWSE oBrwMark	

oDlg:Activate() 

If oDlg:getButtonSelected() > 0

	cCRM200ORI := cTGet
       	  
   For nAp:=1 To Len(aCampos)
   
  		If	aCampos[nAp][1]
  			cSequApl 	+= aCampos[nAp][3]
  		Endif
       	  
   Next nAp
   
   If	LEN(cSequApl) > 1 .AND. "0" $ cSequApl 	
   		Help("",1,"CRM200F3Ord",Nil,STR0039,1)	//"A opção SOMA não pode ser usada em conjunto com outra opção"
   		lRet := .F.
   		
	Else 

	   oMdlInf:SetValue("AO4_PRIORI",cSequApl)
	   	         	  
	   	lRet := .T.

   Endif

Else

   lRet := .F.
   	
EndIf     

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM200ORIR

Adiciona conteudo a variavel cCRM200ORI (STATIC) criada na funcao CRM200F3ORD. Usado na consulta especifica AOESEQ (SXB)

@sample	CRM200ORIR()

@param		Nenhum

@return	ExpC1 - Retorna descricao da sequencia    

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRM200ORIR() 

Return cCRM200ORI

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM200ChvOri

Compoem o texto da selecao da prioridade do registro

@sample	CRM200ChvOri()

@param		ExpO1 - Objeto de LISTBOX
			ExpA1 - Array contendo as opcoes usadas no LISTBOX
			ExpO2 - Objeto que recebe o texto da selecao
			ExpC1 - texto da selecao

@return	Nenhum    

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRM200ChvOri(oBrwMark,aCampos,oTGet,cTGet)

Local   cMais    := " --> "

Default aCampos  := {}
Default oTGet    := Nil
Default oBrwMark := Nil

cTGet := Upper(cTGet)

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos) 
	If aCampos[oBrwMark:At()][1] == .T.
		If At(aCampos[oBrwMark:At()][2],cTGet) <= 0 
		   If !Empty(cTGet)
		   		cTGet += cMais + aCampos[oBrwMark:At()][2]
		   Else
		   		cTGet += aCampos[oBrwMark:At()][2]
		   EndIf
		EndIf
	ElseIf aCampos[oBrwMark:At()][1] == .F.	
	 	If At(cMais+aCampos[oBrwMark:At()][2],cTGet) > 0
	 		cTGet := StrTran(cTGet,cMais+Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	ElseIf  At(aCampos[oBrwMark:At()][2]+cMais,cTGet) > 0
	 		cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]+cMais),"",,1)
	 	ElseIf At(aCampos[oBrwMark:At()][2],cTGet) > 0
	 	 	cTGet := StrTran(cTGet,Upper(aCampos[oBrwMark:At()][2]),"",,1)
	 	EndIf 	
	EndIf		
	If ValType(oTGet) == "O"
		oTGet:CtrlRefresh() 
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200NEqp

Iniciador padrao para o campo nome da equipe (AO4_NOMEQP)

@sample	CRMA200NEqp()

@param		Nenhum

@return	ExpC1 - Nome da equipe    

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200NEqp()

Local aArea		:= GetArea()
Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local oMdlPos		:= oModel:GetModel("AO4DETEQP") 
Local cNomeEqp 	:= ""

If nOperation <> MODEL_OPERATION_INSERT
	
	If oMdlPos:Length() == 0 .AND. !Empty(AO4->AO4_CODEQP)
		cNomeEqp := Posicione("ACA",1,xFilial("ACA")+AO4->AO4_CODEQP,"ACA_DESCRI")
	EndIf
	
EndIf        

RestArea(aArea)           

Return(cNomeEqp)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA200NUnd

Iniciador padrao para o campo nome da unidade de venda (AO4_NOMUND)

@sample	CRMA200NUnd()

@param		Nenhum

@return	ExpC1 - Nome da unidade de venda     

@author	Eduardo Gomes Junior
@since		06/07/2015
@version	12               
/*/
//------------------------------------------------------------------------------
Function CRMA200NUnd()

Local aArea		:= GetArea()
Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local oMdlPos		:= oModel:GetModel("AO4DETUND") 
Local cNomeUnd 	:= ""

If nOperation <> MODEL_OPERATION_INSERT
	
	If oMdlPos:Length() == 0 .AND. !Empty(AO4->AO4_CODUND)
		cNomeUnd := Posicione("ADK",1,xFilial("ADK")+AO4->AO4_CODUND,"ADK_NOME")
	EndIf
	
EndIf

RestArea(aArea)                   

Return(cNomeUnd)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA200RUCom

Função para retorno de valores para os gatilhos

@sample	CRMA200RUCom(nType,cMdlGrid,cCampo)

@param		Nenhum

@return	nType		- Tipo     
			cMdlGrid	- Objeto do modelo de dados do grid	
			cCampo		- Campos que posicionado	
			
@Return	cRetorno	- Valor do gatilho
			
@author	Anderson Silva
@since		10/07/2015
@version	12.1.6      
/*/
//------------------------------------------------------------------------------
Function CRMA200RUCom(nType,cMdlGrid,cCampo)

Local oModel		:= FwModelActive() 
Local cRetorno		:= ""
Local cCodUsr		:= ""

Default nType		:= 0
Default cMdlGrid	:= ""
Default cCampo		:= ""

If lMVCRMUAZS = Nil
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

cCodUsr := If(lMVCRMUAZS, CRMXCodUser(), RetCodUsr())

If nType <> 0 .And. !Empty(cMdlGrid) .And. !Empty(cCampo)
	oMdlGrid	:= oModel:GetModel(cMdlGrid)
	If !Empty(oMdlGrid:GetValue(cCampo))
		//Retorna CodUser
		If nType == 1
			If oMdlGrid:IsInserted()
				cRetorno := cCodUsr
			EndIf
		//Retorna Nome do Usuario	
		ElseIf nType == 2
			If oMdlGrid:IsInserted()
				cRetorno := UsrRetName(cCodUsr)
			EndIf
		EndIf
	EndIf
EndIf

Return( cRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA200MkPr 

Marca o proprietario da conta

@sample		CRMA200MkPr()

@return		.T. - Validação OK

@author		Aline Sebrian Damasceno
@since		18/09/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Function CRMA200MkPr()
	Local oModel	:= FWModelActive()
	Local oUser		:= oModel:GetModel("AO4DETUSR")
	Local oView		:= FWViewActive()
	Local nCurrent	:= oUser:GetLine()  
	Local nLine		:= 0

	//-------------------------------------------------------------------
	// Permite apenas um usuário proprietário.  
	//-------------------------------------------------------------------
	For nLine := 1 To oUser:Length()
		oUser:GoLine( nLine )
		oUser:LoadValue("AO4_PROPRI", If ( nLine == nCurrent, .T., .F.  ) )
	Next nLine
	
	//-------------------------------------------------------------------
	// Atualiza a camada de visualização.  
	//-------------------------------------------------------------------	
	If oView <> Nil .And. oView:GetModel() <> Nil .And. oView:GetModel():GetId()=="CRMA200" 
		oView:Refresh()
	EndIf		
Return .T.


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive