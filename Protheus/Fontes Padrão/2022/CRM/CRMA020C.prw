#INCLUDE "CRMA020C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

#DEFINE TYPE_FORM_SOL_CONTAS  1

#DEFINE TYPE_FORM_DCS_CONTAS  2
 
#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW	2 

STATIC nTypeForm  := 0  
STATIC nOpcForm   := 0
Static lMVCRMUAZS := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA020C

Funcionalidade para o vendedor liberar as contas de outros vendedores para que o
mesmo trabalhe com esta conta por um período fixo ou determinado.

@sample 	CRMA020C(cEntidad,cCodCta,cLojCta,nOperation,nType)

@param		ExpC1 Codigo da Entidade
			ExpC2 Codigo da Conta
			ExpC3 Loja da Conta
			ExpC4 Codigo do Vendedor - Logado (Fez uma solicitação ou que fez uma liberação da conta )
			ExpN5 Numero que informa a operação (3 = Solicitação / 4 = Liberação)
			ExpN6 Numero que indica qual Form esta chamando essa funcao

@return		Nenhum

@author  	Anderson Silva
@since		24/09/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function CRMA020C(cEntidad,cCodCta,cLojCta,cCodVend,nType,nOperation,uRotAuto)

Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
Local aSize	 		:= FWGetDialogSize( oMainWnd )
Local oModel		:= Nil
Local oView	   		:= Nil
Local oMdlAIM		:= Nil
Local oFWMVCWin		:= Nil
Local aCampos 		:= {}
Local lRetorno		:= .T.
Local cTitle		:= "" 

Default cEntidad	:= ""
Default cCodCta	  	:= ""
Default cLojCta		:= ""
Default cCodVend	:= ""
Default nType		:= TYPE_FORM_SOL_CONTAS
Default nOperation  := 3

// Define o tipo de formulario para view
nTypeForm := nType
nOpcForm  := nOperation

If uRotAuto == Nil
	
	If nTypeForm == TYPE_FORM_SOL_CONTAS
		cTitle := STR0001//"Solicitação"
	ElseIf nTypeForm == TYPE_FORM_DCS_CONTAS
		cTitle := STR0002//"Decisão"
	EndIf
	
	oModel := FWLoadModel("CRMA020C")
	oModel:SetOperation(nOperation)
	oModel:Activate()  
	oMdlAIM := oModel:GetModel("AIMMASTER")
	
	If nOperation == MODEL_OPERATION_INSERT
		 
		(cEntidad)->( DbSetOrder(1) )//ACH_FILIAL+ACH_CODIGO # US_FILIAL+US_COD # A1_FILIAL+A1_COD
		
		If (cEntidad)->( DbSeek(xFilial(cEntidad)+cCodCta+cLojCta) )
			
			aCampos := CRMA20CCpo(cEntidad)
			
			If !Empty( aCampos )
				oMdlAIM:SetValue("AIM_ENTIDA",cEntidad)
				oMdlAIM:SetValue("AIM_NOMENT",AllTrim(Posicione("SX2",1,cEntidad,"X2NOME()")))
				oMdlAIM:SetValue("AIM_CODCTA",cCodCta)
				oMdlAIM:SetValue("AIM_LOJCTA",cLojCta)
				oMdlAIM:SetValue("AIM_NOMCTA",(cEntidad)->&(aCampos[4]))
				oMdlAIM:SetValue("AIM_TIPPES",IIF((cEntidad)->&(aCampos[5])$ "F|CF","F","J"))
				oMdlAIM:SetValue("AIM_CGC",Transform(Alltrim((cEntidad)->&(aCampos[6])),CRMA20CPFJ()))
				oMdlAIM:SetValue("AIM_VENPRO",(cEntidad)->&(aCampos[7]))
				oMdlAIM:SetValue("AIM_VENSOL",cCodVend)
				oMdlAIM:SetValue("AIM_NROPAB",CRMA20CNOp(cEntidad,cCodCta,cLojCta))
				                                        
				SA3->( DbSetOrder(1) )//A3_FILIAL+A3_COD 
				
				//Informacoes do dono da conta
				If SA3->( DbSeek(xFilial("SA3")+(cEntidad)->&(aCampos[7])) )
					oMdlAIM:LoadValue("AIM_VEND",SA3->A3_COD)
					oMdlAIM:LoadValue("AIM_NVEND",SA3->A3_NOME)
					oMdlAIM:LoadValue("AIM_MAILVD",SA3->A3_EMAIL)
					oMdlAIM:LoadValue("AIM_DDDVEN",SA3->A3_DDDTEL)
					oMdlAIM:LoadValue("AIM_TELVEN",SA3->A3_TEL)
					oMdlAIM:LoadValue("AIM_UNDVEN",SA3->A3_UNIDAD)
					oMdlAIM:LoadValue("AIM_NUDVEN",AllTrim(Posicione("ADK",1,xFilial("ADK")+SA3->A3_UNIDAD,"ADK_NOME")))
				EndIf    
				
			EndIf                          
			
			If nTypeForm == TYPE_FORM_DCS_CONTAS
				oMdlAIM:SetValue("AIM_LIBERA","1")
				oMdlAIM:SetValue("AIM_VENDCS",cCodVend)
				oMdlAIM:SetValue("AIM_DTSOL" ,MsDate())
				oMdlAIM:SetValue("AIM_HRSOL" ,SubStr(Time(),1,5) )
				// Caso nao tiver oportunidade em aberto inicializar o campo (AIM_ACOPOR) sem acao. 
				If oMdlAIM:GetValue("AIM_NROPAB") == 0 
			   		oMdlAIM:SetValue("AIM_ACOPOR","3")			
				EndIf
			EndIf
			                      
		EndIf
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
	
		oMdlAIM:SetValue("AIM_VENDCS",cCodVend)
		// Caso nao tiver oportunidade em aberto inicializar o campo (AIM_ACOPOR) sem acao. 
		If oMdlAIM:GetValue("AIM_NROPAB") == 0 
	   		oMdlAIM:SetValue("AIM_ACOPOR","3")			
		EndIf

	EndIf
	
	SA3->( DbSetOrder(1) )//A3_FILIAL+A3_COD 
	
	oView := FWLoadView("CRMA020C")
	oView:SetModel(oModel)
	oView:SetOperation(nOperation)
	 
	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(cTitle)
	oFWMVCWin:oView:BCloseOnOk := {|| .T. }
	oFWMVCWin:Activate()
	
	//Abortou a solicitacao de transf.
	If oFWMVCWin:oView:GetbuttonWasPressed() == 1
		lRetorno := .F.
	EndIf
	
Else
	lRetorno := FWMVCRotAuto(ModelDef(),"AIM",nOperation,{{"AIMMASTER",uRotAuto}},/*lSeek*/,.T.)
EndIf

RestArea(aArea)
RestArea(aAreaSA3)

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Criacao da camada da estrutura de dados

@sample 	ModelDef()

@param		Nenhum

@return		oModel - Objeto da estrutura de dados

@author  	Thiago Tavares
@since		24/09/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStructAIM	:= FWFormStruct(1,"AIM", /*bValCampo*/ ,/*lViewUsado*/)
Local bCommit		:= {|oModel| CRMA20CGrv(oModel)}
Local bPosValid	:= {|oModel| CRM020CPVld(oModel)} 
 
oStructAIM:SetProperty("AIM_CGC",MODEL_FIELD_TAMANHO,18) 

If nTypeForm == TYPE_FORM_SOL_CONTAS
	oStructAIM:SetProperty("AIM_ACOPOR",MODEL_FIELD_OBRIGAT,.F.)
	oStructAIM:SetProperty("AIM_OBSDCS",MODEL_FIELD_OBRIGAT,.F.)
ElseIf nTypeForm == TYPE_FORM_DCS_CONTAS
	oStructAIM:SetProperty("AIM_LIBERA",MODEL_FIELD_OBRIGAT,.T.) 
	/*Caso a solicitação for passada como decisão atraves do PE CRM20BSL fonte CRMA020B
	 os campos abaixo poderão ser modificados.
	*/
	If !IsInCallStack("CRM020B20C") 
		oStructAIM:SetProperty("AIM_CODMOT",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
		oStructAIM:SetProperty("AIM_OBSMOT",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
	EndIf
EndIf

oModel := MPFormModel():New("CRMA020C",/*bPreValidacao*/,bPosValid,bCommit,/*bCancel*/)
oModel:AddFields("AIMMASTER",/*cOwner*/,oStructAIM,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription(STR0003)//"Liberação para Transferencia de Contas"

Return(oModel) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Criacao da camada da interface de dados

@sample 	ViewDef()

@param		Nenhum

@return		oView - Objeto da interface de dados

@author 	Thiago Tavares 
@since		24/09/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView			:= Nil
Local oModel		:= FWLoadModel("CRMA020C")
Local oStructAIM 	:= FWFormStruct(2,"AIM", /*bValCampo*/ ,/*lViewUsado*/)

//Remove a picture do campo
oStructAIM:SetProperty("AIM_CGC",MVC_VIEW_PICT,"")
oStructAIM:RemoveField("AIM_CODIGO")
oStructAIM:RemoveField("AIM_ENTIDA")
oStructAIM:RemoveField("AIM_VENSOL")
oStructAIM:RemoveField("AIM_NVDSOL")
oStructAIM:RemoveField("AIM_VENDCS")
oStructAIM:RemoveField("AIM_NVDDCS")

//------------------------------------------------------------------------------
// Definindo os campos do grupo ------------- CONTA ----------------------------
//------------------------------------------------------------------------------
oStructAIM:AddGroup("CONTA",STR0004	,"",2)//"Informações da Conta"
oStructAIM:SetProperty("AIM_NOMENT"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_CODCTA"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_NOMCTA"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_LOJCTA"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_TIPPES"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_CGC"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_VENPRO"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_NVDPRO"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_UNDPRO"	, MVC_VIEW_GROUP_NUMBER,"CONTA")
oStructAIM:SetProperty("AIM_NUDPRO"	, MVC_VIEW_GROUP_NUMBER,"CONTA")

If nTypeForm == TYPE_FORM_SOL_CONTAS
	
	oStructAIM:RemoveField("AIM_STATUS")
	oStructAIM:RemoveField("AIM_OBSDCS")
	oStructAIM:RemoveField("AIM_DTDCS")
	oStructAIM:RemoveField("AIM_HRDCS")
	oStructAIM:RemoveField("AIM_ACOPOR")
	oStructAIM:RemoveField("AIM_NROPAB")
	oStructAIM:RemoveField("AIM_VENPRO")
	oStructAIM:RemoveField("AIM_NVDPRO")
	oStructAIM:RemoveField("AIM_UNDPRO")
	oStructAIM:RemoveField("AIM_NUDPRO")
	oStructAIM:RemoveField("AIM_LIBERA")
	oStructAIM:RemoveField("AIM_ENVMAI")
	oStructAIM:RemoveField("AIM_STATUS")
	oStructAIM:RemoveField("AIM_FCIOPO")
	oStructAIM:RemoveField("AIM_DSCFCI")

	//------------------------------------------------------------------------------
	// Definindo os campos do grupo ------------ PROPRIETARIO DA CONTA -------------
	//------------------------------------------------------------------------------
	oStructAIM:AddGroup("PROPRIETARIO",STR0005,"",2)//"Informações do Proprietário da Conta"
	oStructAIM:SetProperty("AIM_VEND"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_NVEND"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_MAILVD"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_DDDVEN"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_TELVEN"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_UNDVEN"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	oStructAIM:SetProperty("AIM_NUDVEN"	,MVC_VIEW_GROUP_NUMBER,"PROPRIETARIO")
	
	//------------------------------------------------------------------------------
	// Definindo os campos do grupo ------------- MOTIVO ---------------------------
	//------------------------------------------------------------------------------
	oStructAIM:AddGroup("MOTIVO",STR0006,"",3)//"Motivo da Solicitação"
	oStructAIM:SetProperty("AIM_CODMOT"	,MVC_VIEW_GROUP_NUMBER,"MOTIVO" )
	oStructAIM:SetProperty("AIM_DSCMOT"	,MVC_VIEW_GROUP_NUMBER,"MOTIVO" )
	oStructAIM:SetProperty("AIM_OBSMOT"	,MVC_VIEW_GROUP_NUMBER,"MOTIVO" )
	oStructAIM:SetProperty("AIM_DTSOL"	,MVC_VIEW_GROUP_NUMBER,"MOTIVO" )
	oStructAIM:SetProperty("AIM_HRSOL" 	,MVC_VIEW_GROUP_NUMBER,"MOTIVO" )
	
ElseIf nTypeForm == TYPE_FORM_DCS_CONTAS			// DECISAO
	
	If nOpcForm == MODEL_OPERATION_UPDATE 
	 	oStructAIM:RemoveField("AIM_STATUS")
	Else
		oStructAIM:RemoveField("AIM_LIBERA")
		oStructAIM:RemoveField("AIM_ENVMAI")
    EndIf
	
	//------------------------------------------------------------------------------
	// Definindo os campos do grupo ------------- SOLICITANTE ----------------------
	//------------------------------------------------------------------------------
	oStructAIM:AddGroup("SOLICITANTE",STR0007,"",2)//"Informações do Solicitante"
	oStructAIM:SetProperty("AIM_VEND"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_NVEND"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_MAILVD"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_DDDVEN"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_TELVEN"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_UNDVEN"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE")
	oStructAIM:SetProperty("AIM_NUDVEN"	,MVC_VIEW_GROUP_NUMBER,"SOLICITANTE") 
	
	//------------------------------------------------------------------------------
	// Definindo os campos do grupo ------------- MOTIVO ---------------------------
	//------------------------------------------------------------------------------
	oStructAIM:AddGroup("MOTIVO",STR0008,"",3)//"Motivo da Solicitação"
	oStructAIM:SetProperty("AIM_CODMOT",MVC_VIEW_GROUP_NUMBER,"MOTIVO")
	oStructAIM:SetProperty("AIM_DSCMOT",MVC_VIEW_GROUP_NUMBER,"MOTIVO")
	oStructAIM:SetProperty("AIM_OBSMOT",MVC_VIEW_GROUP_NUMBER,"MOTIVO")
	oStructAIM:SetProperty("AIM_DTSOL" ,MVC_VIEW_GROUP_NUMBER,"MOTIVO")
	oStructAIM:SetProperty("AIM_HRSOL" ,MVC_VIEW_GROUP_NUMBER,"MOTIVO")
	
	//------------------------------------------------------------------------------
	// Definindo os campos do grupo ------------- DECISAO --------------------------
	//------------------------------------------------------------------------------
	oStructAIM:AddGroup("DECISAO",STR0009,"",4)//"Decisão"
	oStructAIM:SetProperty("AIM_OBSDCS"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
	oStructAIM:SetProperty("AIM_ACOPOR" ,MVC_VIEW_GROUP_NUMBER,"DECISAO")
	oStructAIM:SetProperty("AIM_NROPAB"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")  
	oStructAIM:SetProperty("AIM_FCIOPO"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
	oStructAIM:SetProperty("AIM_DSCFCI"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
	oStructAIM:SetProperty("AIM_DTDCS" 	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
	oStructAIM:SetProperty("AIM_HRDCS" 	,MVC_VIEW_GROUP_NUMBER,"DECISAO")

	
	If nOpcForm == MODEL_OPERATION_UPDATE 
	 	oStructAIM:SetProperty("AIM_LIBERA"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
		oStructAIM:SetProperty("AIM_ENVMAI"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
    Else
    	oStructAIM:SetProperty("AIM_STATUS"	,MVC_VIEW_GROUP_NUMBER,"DECISAO")
    EndIf
	
EndIf

oView := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel(oModel)

oView:AddField("VIEW_AIM",oStructAIM,"AIMMASTER")
oView:CreateHorizontalBox("HBOX_AIM",100)
oView:SetOwnerView("VIEW_AIM","HBOX_AIM")
oView:ShowUpdateMsg(.F.)

Return (oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CGrv

Funcao que grava a solicitacao a conta

@sample 	CRMA20CGrv(oModel)

@param		ExpO - objeto do modelo de dados

@return		ExpO - Objeto da interface de dados

@author 	Anderson Silva
@since		24/09/2013 
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20CGrv( oModel )

Local aArea 	 		:= GetArea()
Local aAreaAZS 	 	:= AZS->( GetArea() )
Local oMdlAIM   		:= oModel:GetModel("AIMMASTER")
Local lRetorno		:= .T.
Local cEntidad 		:= ""
Local cCodCta	 		:= ""
Local cLojCta	 		:= "" 
Local nNrOptAbr  		:= 0
Local nOperation 		:= oModel:GetOperation()
Local nI				:= 0
Local cAcaoOpor  		:= "" 
Local cCodVenAnt 		:= ""
Local cCodVenAtu 		:= ""
Local cCodFCI			:= ""
Local cCodTer			:= ""
Local cTpMem			:= ""
Local cCodMem			:= ""
Local aErrorFluig		:= {}
Local aErroAuto		:= {}
Local cIdFluig		:= ""
Local cLogErro		:= ""
Local cUserFluig		:= ""
Local lWFFluig		:= SuperGetMv("MV_CRMWFFG",,.F.)

Private lMsErroAuto		:= .F. 
Private lAutoErrNoFile	:= .T.
Private lMsHelpAuto   	:= .T.	

If lMVCRMUAZS == Nil  
	lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
EndIf

If ! lMVCRMUAZS	// Só permite integração com fluig se utilizar AZS
	lWFFluig := .F.
EndIf

BEGIN TRANSACTION 

If nOperation <> MODEL_OPERATION_DELETE	

	If nTypeForm == TYPE_FORM_DCS_CONTAS
	
		oMdlAIM:LoadValue("AIM_DTDCS",MsDate())
		oMdlAIM:LoadValue("AIM_HRDCS",SubStr(Time(),1,5))
		
		If oMdlAIM:GetValue("AIM_LIBERA") == "1"  
		 	
			cEntidad  	:= oMdlAIM:GetValue("AIM_ENTIDA")	
			cCodCta		:= oMdlAIM:GetValue("AIM_CODCTA")
			cLojCta		:= oMdlAIM:GetValue("AIM_LOJCTA")
			nNrOptAbr 	:= oMdlAIM:GetValue("AIM_NROPAB")
			cAcaoOpor 	:= oMdlAIM:GetValue("AIM_ACOPOR")
			cCodVenAnt	:= oMdlAIM:GetValue("AIM_VENPRO")
		   	cCodVenAtu	:= oMdlAIM:GetValue("AIM_VENSOL") 
		   	cCodFCI  	:= oMdlAIM:GetValue("AIM_FCIOPO") 
			
			If ( AIM->(ColumnPos("AIM_CODTER")) .And. AIM->(ColumnPos("AIM_TPMEM")) .And. AIM->(ColumnPos("AIM_CODMEM")) )
				cCodTer	:= oMdlAIM:GetValue("AIM_CODTER")
				cTpMem  := oMdlAIM:GetValue("AIM_TPMEM") 
				cCodMem	:= oMdlAIM:GetValue("AIM_CODMEM")
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere ou encerra como perdida as oportunidades de venda em aberto das contas Suspects / Clientes. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lMsErroAuto .AND. cEntidad $ "SUS|SA1" .AND. cAcaoOpor $ "1|2" .AND. nNrOptAbr > 0
				CRMA20AOport(cEntidad,cCodCta,cLojCta,cAcaoOpor,cCodVenAnt,cCodVenAtu,cCodFCI)
			EndIf  
			
			//Suspects
			If cEntidad == "ACH"
				aExecAuto := {{"ACH_CODIGO"	,cCodCta		,Nil}	,;
							   	{"ACH_LOJA"	,cLojCta		,Nil}	,;
							   	{"ACH_VEND"	,cCodVenAtu	,Nil} }
							   	
				If ! Empty(cCodTer) .And. ! Empty(cCodMem)
					Aadd(aExecAuto, {"ACH_CODTER"	,cCodTer	,Nil})
					Aadd(aExecAuto, {"ACH_TPMEM"	,cTpMem	,Nil})
					Aadd(aExecAuto, {"ACH_CODMEM"	,cCodMem	,Nil})
				EndIf
			
				MSExecAuto( {|x,y| TMKA341(x,y) },aExecAuto,4)
	
			//Prospects
			ElseIf cEntidad == "SUS"
				aExecAuto := {{"US_COD"		,cCodCta		,Nil},;
							   	{"US_LOJA"		,cLojCta		,Nil},;
							   	{"US_VEND"		,cCodVenAtu	,Nil}}
				
				If ! Empty(cCodTer) .And. ! Empty(cCodMem)
					Aadd(aExecAuto, {"US_CODTER"	,cCodTer	,Nil})
					Aadd(aExecAuto, {"US_TPMEMB"	,cTpMem	,Nil})
					Aadd(aExecAuto, {"US_CODMEMB"	,cCodMem	,Nil})
				EndIf
				
				MSExecAuto( {|x,y| TMKA260(x,y) },aExecAuto,4)
		
			//Clientes
			Else
				aExecAuto := { {"A1_COD"		,cCodCta		,Nil},;
							   	 {"A1_LOJA"	,cLojCta		,Nil},;
							   	 {"A1_VEND"	,cCodVenAtu	,Nil} 	}
				
				If ! Empty(cCodTer) .And. ! Empty(cCodMem)
					Aadd(aExecAuto, {"A1_CODTER"	,cCodTer	,Nil})
					Aadd(aExecAuto, {"A1_TPMEMB"	,cTpMem	,Nil})
					Aadd(aExecAuto, {"A1_CODMEMB"	,cCodMem	,Nil})
				EndIf
		
				MSExecAuto( {|x,y| MATA030(x,y) },aExecAuto,4)

			EndIf
				
			If !lMsErroAuto	
			
				aExecAuto := {{"AIN_ENTIDA",cEntidad							,Nil}	,;
								{"AIN_CODCTA",cCodCta							,Nil}	,;
								{"AIN_LOJCTA",cLojCta							,Nil}	,;
								{"AIN_CODMOT",oMdlAIM:GetValue("AIM_CODMOT")	,Nil}	,;
								{"AIN_OBSMOT",oMdlAIM:GetValue("AIM_OBSMOT")	,Nil}	,;
								{"AIN_OBSLIB",oMdlAIM:GetValue("AIM_OBSDCS")	,Nil}	,;
								{"AIN_VENDCS",oMdlAIM:GetValue("AIM_VENDCS")	,Nil}	,;
								{"AIN_VENANT",cCodVenAnt							,Nil}	,;
								{"AIN_UNDANT",Posicione("SA3",1,xFilial("SA3")+cCodVenAnt,"A3_UNIDAD"),Nil}	,;
								{"AIN_VENATU",cCodVenAtu	  						,Nil}	,;
								{"AIN_UNDATU",Posicione("SA3",1,xFilial("SA3")+cCodVenAtu,"A3_UNIDAD"),Nil} 	,;
								{"AIN_CODSOL",oMdlAIM:GetValue("AIM_CODIGO")	,Nil}	}
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o Log de Transferência de contas. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MSExecAuto( {|x,y| CRMA030(x,y) },aExecAuto,3)
		
			EndIf
				
			If lMsErroAuto
				
				aErroAuto := GetAutoGRLog()
				For nI := 1 To Len(aErroAuto)
					cLogErro += aErroAuto[nI]
				Next nI

				oModel:SetErrorMessage("",,oModel:GetId(),"","CRMA20CGRV",AllTrim( cLogErro )) 
		
				DisarmTransaction()
				lRetorno := .F.
			Else
				oMdlAIM:SetValue("AIM_STATUS","2")
			EndIf
				
		Else
			oMdlAIM:SetValue("AIM_STATUS","3")
		EndIf
		
	EndIf

EndIf

If lRetorno
	
	If ( nTypeForm == TYPE_FORM_DCS_CONTAS .Or. nOperation == MODEL_OPERATION_DELETE	)
		If lMVCRMUAZS == Nil  
			lMVCRMUAZS := SuperGetMv("MV_CRMUAZS",, .F.)
		EndIf
		
		If ( lWFFluig .And. lMVCRMUAZS .And. !IsBlind() )
		
			cIdFluig := oMdlAIM:GetValue("AIM_FLUIG")
			
			If !Empty( cIdFluig )
				
				AZS->( DBSetOrder( 4 ) ) //AZS_FILIAL + AZS_VEND
	 
				If AZS->( DBSeek( xFilial("AZS") + oMdlAIM:GetValue("AIM_VENSOL") ) )
					
					cUserFluig	:= FWWFColleagueId( AZS->AZS_CODUSR ) 
					FwMsgRun(,{|| lRetorno := FWECMCancelProcess(Val( cIdFluig ),cUserFluig, STR0031 ) },,STR0032) //"Cancelado por contingência!"//"Cancelando o processo de aprovação no Fluig..."
					
					If !lRetorno .And. FWWFIsError()
						aErrorFluig := FWWFGetError()
						Help("",1,"HELP","Fluig",aErrorFluig[2],1)
					EndIf
					
				EndIf
			
			EndIf
			
		EndIf
		
	EndIf

	If lRetorno 
		lRetorno := FwFormCommit(oModel)
		//------------------------------------------------------------------------------
		// Dispara o e-mail para os vendedores sobre a Transferencia de contas ---------
		//------------------------------------------------------------------------------
		If oMdlAIM:GetValue("AIM_ENVMAI") == "1" 	
			CRMA20CEMail(oMdlAIM)
		EndIf
	EndIf
	
EndIf

END TRANSACTION

RestArea( aAreaAZS ) 
RestArea( aArea )

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20AEMail

Dispara e-mail para o vendedores envolvidos na transferencia das contas

@sample		CRMA20CEMail(oMdlAIM)

@param		ExpO1 - Dados da transferencia

@return		Nenhum

@author		Thiago Tavares
@since		24/09/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function CRMA20CEMail(oMdlAIM)

Local cFrom	:= ""
Local cTo	:= ""
Local cBody	:= ""
                
If oMdlAIM:GetValue("AIM_LIBERA") == "1"

	cBody :=	'<html>'+;
				'<head>'+;
					'<style type="text/css">'+;
						'td { font-family:verdana; font-size:12px}'+;
						'p  { font-family:verdana; font-size:12px}'+;
					'</style>'+;
				'</head>'+;
				'<body>'+;
					'<p>'+STR0010 + AllTrim(oMdlAIM:GetValue("AIM_NVDSOL")) + ', </p>'+;//"Caro(a) "
					'<p>'+STR0011+'<br>'+;//"Foi realizada a liberação de uma transferência de conta para sua area de trabalho:"
						STR0012 + dToc(oMdlAIM:GetValue("AIM_DTSOL")) + " - " + oMdlAIM:GetValue("AIM_HRSOL") + '<br>'+;//"Data/Hora da solicitação: "
						STR0013 + dToc(oMdlAIM:GetValue("AIM_DTDCS")) + " - " + oMdlAIM:GetValue("AIM_HRDCS") + '<br>'+;//"Data/Hora da liberação: "
					STR0014 + oMdlAIM:GetValue("AIM_CODCTA") + " - " + STR0015 + oMdlAIM:GetValue("AIM_LOJCTA") + " - " + oMdlAIM:GetValue("AIM_NOMCTA") +'<br>'+;//"Conta: "//"Loja: "
					STR0016 + oMdlAIM:GetValue("AIM_CODMOT") + " - " + AllTrim(Posicione("SX5",1,xFilial("SX5")+"AE"+oMdlAIM:GetValue("AIM_CODMOT"),"X5DESCRI()"))  +'<br>'+;//"Motivo: "
					STR0017 + oMdlAIM:GetValue("AIM_VENPRO") + " - " + oMdlAIM:GetValue("AIM_NVDPRO") + '<br>'+;//"Vendedor Anterior: "
					STR0018 + oMdlAIM:GetValue("AIM_UNDPRO") + " - " + oMdlAIM:GetValue("AIM_NUDPRO") + '<br>'+;//"Unid. Neg. Anterior : "
					STR0019+ AllTrim(oMdlAIM:GetValue("AIM_OBSDCS"))+'</p>'+;//"Observaçoes: "
					'<table cellpadding="2" width="100%">'+;
						'<tr>'+;
							'<td colspan="12" align="center" bgcolor="#08364D">'+;
								'<span style="color:white;font-size:10px;"><b>'+STR0020+'<b></span>'+;//"TOTVS S.A. - TODOS OS DIREITOS RESERVADOS"
							'</td>'+;
						'</tr>'+;
						'<tr><td colspan="12">'+STR0021+'</td></tr>'+;//"Mensagem automática, favor não responder."
					'</table>'+;
				'</body>'+;
				'</html>'                   
				
ElseIf oMdlAIM:GetValue("AIM_LIBERA") == "2" 	
		
		cBody :=	'<html>'+;
				'<head>'+;
					'<style type="text/css">'+;
						'td { font-family:verdana; font-size:12px}'+;
						'p  { font-family:verdana; font-size:12px}'+;
					'</style>'+;
				'</head>'+;
				'<body>'+;
					'<p>'+STR0010 + AllTrim(oMdlAIM:GetValue("AIM_NVDSOL")) + ', </p>'+;//"Caro(a) "
					'<p>'+STR0025+'<br>'+;//"A conta abaixo não foi liberada para sua área de trabalho:"
						STR0012 + dToc(oMdlAIM:GetValue("AIM_DTSOL")) + " - " + oMdlAIM:GetValue("AIM_HRSOL") + '<br>'+;//"Data / Hora da solicitação: "
						STR0013 + dToc(oMdlAIM:GetValue("AIM_DTDCS")) + " - " + oMdlAIM:GetValue("AIM_HRDCS") + '<br>'+;//"Data / Hora da liberação: "
					STR0014 + oMdlAIM:GetValue("AIM_CODCTA") + " - " + STR0015 + oMdlAIM:GetValue("AIM_LOJCTA") + " - " + oMdlAIM:GetValue("AIM_NOMCTA") +'<br>'+;//"Conta: "//"Loja: "
					STR0016 + oMdlAIM:GetValue("AIM_CODMOT") + " - " + AllTrim(Posicione("SX5",1,xFilial("SX5")+"AE"+oMdlAIM:GetValue("AIM_CODMOT"),"X5DESCRI()"))  +'<br>'+;//"Motivo: "
					STR0017 + oMdlAIM:GetValue("AIM_VENPRO") + " - " + oMdlAIM:GetValue("AIM_NVDPRO") + '<br>'+;//"Vendedor Anterior: "
					STR0018 + oMdlAIM:GetValue("AIM_UNDPRO") + " - " + oMdlAIM:GetValue("AIM_NUDPRO") + '<br>'+;//"Unid. Neg. Anterior : "
					STR0019+ AllTrim(oMdlAIM:GetValue("AIM_OBSDCS"))+'</p>'+;//"Observaçoes: "
					'<table cellpadding="2" width="100%">'+;
						'<tr>'+;
							'<td colspan="12" align="center" bgcolor="#08364D">'+;
								'<span style="color:white;font-size:10px;"><b>'+STR0020+'<b></span>'+;//"TOTVS S.A. - TODOS OS DIREITOS RESERVADOS"
							'</td>'+;
						'</tr>'+;
						'<tr><td colspan="12">'+STR0021+'</td></tr>'+;//"Mensagem automática, favor não responder."
					'</table>'+;
				'</body>'+;
				'</html>'
					
EndIf
	        
	        	
cFrom	:= Lower(AllTrim(Posicione("SA3",1,xFilial("SA3")+oMdlAIM:GetValue("AIM_VENDCS"),"A3_EMAIL")))
cTo		:= Lower(oMdlAIM:GetValue("AIM_MAILVD"))+";"+Lower(AllTrim(Posicione("SA3",1,xFilial("SA3")+oMdlAIM:GetValue("AIM_VENPRO"),"A3_EMAIL")))

CRMXEnvMail(cFrom,cTo,"","",STR0022,cBody)	//"Transferência de Contas"

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CNCT

Retorna o nome da conta

@sample	CRMA20CNCT(cAlias,cCodCta,cLojCta)

@param		ExpC1 - Alias da entidade
			ExpC2 - Codigo da conta
			ExpC3 - Loja da conta

@return   	ExpC - Nome da conta

@author 	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20CNCT(cEntidad,cCodCta,cLojCta)

Local cRetorno := ""
Local aCampos   := {}

If !Empty(cEntidad)
	aCampos  := CRMA20CCpo(cEntidad)
	cRetorno := Alltrim(Posicione(cEntidad,1,xFilial(cEntidad)+cCodCta+cLojCta,aCampos[4]))
EndIf

Return( cRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CTPes

Retorna o nome da conta

@sample	CRMA20CTPes(cEntidad,cCodCta,cLojCta)

@param		ExpC1 - Alias da entidade
			ExpC2 - Codigo da conta
			ExpC3 - Loja da conta

@return   	ExpC - Tipo de Pessoa Juridica/Fisica

@author 	Anderson Silva
@since		25/09/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMA20CTPes(cEntidad,cCodCta,cLojCta)

Local cRetorno	:= ""
Local aCampos   := {}

If !Empty(cEntidad)
	aCampos  := CRMA20CCpo(cEntidad)
	cRetorno := Alltrim(Posicione(cEntidad,1,xFilial(cEntidad)+cCodCta+cLojCta,aCampos[5]))
	If cRetorno $ "F|CF"
		cRetorno := "F"
	Else
		cRetorno := "J"
	EndIf
EndIf

Return( cRetorno )


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CCGC

Retorna cpf/cnpj da conta

@sample	CRMA20CCGC(cEntidad,cCodCta,cLojCta)

@param		ExpC1 - Alias da entidade
			ExpC2 - Codigo da conta
			ExpC3 - Loja da conta

@return   	ExpC - CGC

@author 	Anderson Silva
@since		25/09/2013
@version	11.90

/*/
//------------------------------------------------------------------------------
Function CRMA20CCGC(cEntidad,cCodCta,cLojCta)

Local cRetorno	:= ""
Local aCampos   := {}

If !Empty(cEntidad)
	aCampos  := CRMA20CCpo(cEntidad)
	cRetorno :=  Transform(AllTrim(Posicione(cEntidad,1,xFilial(cEntidad)+cCodCta+cLojCta,aCampos[6])),CRMA20CPFJ())
EndIf

Return( cRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CVDL

Retorna o codigo do vendedor

@sample	CRMA20CVDL(cEntidad,cCodCta,cLojCta)

@param		ExpC1 - Alias da entidade
			ExpC2 - Codigo da conta
			ExpC3 - Loja da conta

@return     ExpC - Retorna o codigo do vendedor

@author 	Anderson Silva
@since		25/09/2013
@version	11.90

/*/
//------------------------------------------------------------------------------

Function CRMA20CVDL(cEntidad,cCodCta,cLojCta)

Local cRetorno	:= ""
Local aCampos   := {}

If !Empty(cEntidad)
	aCampos  := CRMA20CCpo(cEntidad)
	cRetorno := Alltrim(Posicione(cEntidad,1,xFilial(cEntidad)+cCodCta+cLojCta,aCampos[7]))
EndIf

Return( cRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CCpo

Retorna os campos de uma determinada entidade para ser utilizada no preenchimento
dos campos virtuais.

@sample	CRMA20CCpo(cEntidad)

@param		ExpC - Alias da entidade

@return   	ExpA - Campos da entidade passada como parametro.

@author 	Anderson Silva
@since		25/09/2013
@version	11.90

/*/
//------------------------------------------------------------------------------

Static Function CRMA20CCpo(cEntidad)
Local aRet 	:= {}
Local aCampos	:= {}
Local nPos 	:= 0

Default cEntidad := ""

If !Empty( cEntidad )
	aAdd(aCampos,{"ACH","ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_PESSOA","ACH_CGC","ACH_VEND"})
	aAdd(aCampos,{"SUS","US_COD","US_LOJA","US_NOME","US_TPESSOA","US_CGC","US_VEND"})
	aAdd(aCampos,{"SA1","A1_COD","A1_LOJA","A1_NOME","A1_PESSOA","A1_CGC","A1_VEND"})
	nPos := aScan(aCampos,{|x| x[1] == AllTrim(cEntidad) })
	If nPos > 0 
		aRet := aCampos[nPos]
	EndIf
EndIf
 
Return( aRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CRVd

Retorna os dados do vendedor de acordo com a visao do formulario MVC, 
solicitacao da conta ou decisao.

@sample	CRMA20CRVd(cCampo)

@param		ExpC1 - Campo do vendedor passado no SX3

@return   	ExpC - Valor do campo

@author 	Anderson Silva
@since		25/09/2013
@version	11.90

/*/
//------------------------------------------------------------------------------
Function CRMA20CRVd(cCampo)

Local cCodVend	:= ""
Local cRetorno 	:= "" 

Default cCampo 	 	:= ""              

If nTypeForm == TYPE_FORM_SOL_CONTAS  
	cCodVend := FwFldGet("AIM_VENPRO")
ElseIf nTypeForm == TYPE_FORM_DCS_CONTAS
  	cCodVend := FwFldGet("AIM_VENSOL")
EndIf
	
SA3->( DbSetOrder(1) )//A3_FILIAL+A3_COD 

If Alias() == "SA3" .AND. SA3->A3_COD == cCodVend
	cRetorno := SA3->&(cCampo)
Else
	If SA3->( DbSeek(xFilial("SA3")+cCodVend) )
		cRetorno := SA3->&(cCampo)
	EndIf
EndIf

Return( cRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CNOp

Retorna o numero de oportunidades em aberto por entidade

@sample	CRMA20CNOp(cEntidad,cCodCta,cLojCta)

@param		ExpC1 - Entidade
            ExpC2 - Codigo da conta
            ExpC3 - Codigo da loja 
            
@return		ExpN - numero de oportunidade abertas 

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20CNOp(cEntidad,cCodCta,cLojCta)
           
Local aArea		 := GetArea()
Local nNrOportAb := 0

If !Empty(cEntidad) .AND. cEntidad $ "SUS|SA1"
	(cEntidad)->( DbSetOrder(1) )//US_FILIAL+US_COD # A1_FILIAL+A1_COD
	If (cEntidad)->( DbSeek(xFilial(cEntidad)+cCodCta+cLojCta) )
		nNrOportAb := CRMA20COpt(cEntidad)
	EndIf
EndIf

RestArea(aArea)

Return( nNrOportAb )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CAOP

Valida o campo AIM_ACOPOR para determinar uma acao que sera efetuada para as
contas com oportunidades em aberto.

@sample		CRMA20AAOP()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20CAOP()

Local lRetorno := .T.

If Pertence("123")
	If FwFldGet("AIM_ACOPOR") $ "1|2" .AND. FwFldGet("AIM_NROPAB") == 0
		Help("",1,"HELP","CRMA20CAOP",STR0023,1)//"Esta ação só poderá ser alterada para contas (Prospects / Clientes) com oportunidades de venda em aberto."
		lRetorno := .F.
	ElseIf FwFldGet("AIM_ACOPOR") == "3" .AND. FwFldGet("AIM_NROPAB") > 0
		Help("",1,"HELP","CRMA20CAOP",STR0024,1)//"Esta ação não poderá ser utilizada para contas (Prospects / Clientes) com oportunidades de venda em aberto."
		lRetorno := .F.
	EndIf
Else
	lRetorno := .F.
EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CPFJ

Retorna a picture do CPF ou CNPJ da conta.

@sample		CRMA20CPFJ()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20CPFJ()
Local cPict := ""

If FwFldGet("AIM_TIPPES") $ "F|CF"
	cPict := "@R 999.999.999-99"
Else
	cPict := "@R 99.999.999/9999-99"
EndIf

Return( cPict ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA20CVdP

Retorna o codigo do vendedor proprietario da conta.

@sample		CRMA20CVdP()

@param		Nenhum

@return		ExpL - Verdadeiro / Falso

@author		Anderson Silva
@since		22/09/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA20CVdP()

Local aCampos   := CRMA20CCpo(FwFldGet("AIM_ENTIDA"))
Local cVendProp := ""		

//Proprietario da conta
cVendProp := Posicione(	FwFldGet("AIM_ENTIDA"),1,xFilial(FwFldGet("AIM_ENTIDA"))+;
						FwFldGet("AIM_CODCTA")+FwFldGet("AIM_LOJCTA"),aCampos[7] )
Return( cVendProp )            

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020PVld

Função de pós validação do modelo 

@sample		CRM020PVld()

@param		oModel, objeto, objeto com estrutura do modelo de dados

@return		lValid, logico, Verdadeiro/Falso

@author		Jonatas Martins
@since		04/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRM020CPVld(oModel)

Local lRet			:= .T.
Local lAvaliaTer	:= SuperGetMv("MV_CRMTERT",,.F.)

//---------------------------------------------------------------------------------------
// Faz avaliação do territorio mas não bloqueia o processo de transferencia de contas
//---------------------------------------------------------------------------------------
If lAvaliaTer .And.( AIM->(ColumnPos("AIM_CODTER")) .And. AIM->(ColumnPos("AIM_TPMEM")) .And. AIM->(ColumnPos("AIM_CODMEM")) )
	lRet := CRM020CTerAval()
EndIf 


Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020CTerAval

Faz avaliação do territorio mas não bloqueia o processo de transferencia de contas,
caso o função CRMA690EvalTerritory não encontre nenhum territorio apropriado para
atender esta conta.

@sample	CRM020CTerAval()

@param		Nenhum

@return	lRet, logico, Verdadeiro

@author	Jonatas Martins
@since		04/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRM020CTerAval()

Local aArea		:= GetArea()
Local aAreaRot	:= {}
Local xTerritors	:= Nil
Local cProcess	:= ""
Local cRotName	:= "CRMA020B"
Local cAlsRot		:= ""
Local cChave		:= ""
Local lRet			:= .T.
Local oModel		:= Nil

If nTypeForm == TYPE_FORM_SOL_CONTAS 

	oModel := FwModelActive()
	//----------------------------------------------------
	// Verifica se o modelo de dados ativo foi carregado 
	//----------------------------------------------------
	If ValType(oModel) == "O"
		//--------------------------------------
		// Obtem a entidade da rotina corrente
		//--------------------------------------
		cAlsRot := oModel:GetValue("AIMMASTER","AIM_ENTIDA")
	
		If !Empty(cAlsRot)	
			//------------------------------------------
			// Com base no alias posiciona no registro 
			//------------------------------------------
			cChave 		:= 	oModel:GetValue("AIMMASTER","AIM_CODCTA") + oModel:GetValue("AIMMASTER","AIM_LOJCTA")
			aAreaRot	:= (cAlsRot)->(GetArea())
			
			(cAlsRot)->( DbSetOrder(1) )
			lRet := (cAlsRot)->( DbSeek( xFilial(cAlsRot) + cChave  ) )
				
			//----------------------------------------------------
			// Executa a avaliação de território e obtem retorno
			//----------------------------------------------------
			If lRet	
				
				cProcess	:= Alltrim( CRMXGetSX2(cAlsRot)[3] )	
				cRotName	:= IIF( IsInCallStack("CRMA020B") , "CRMA020B" , "CRMA020" ) // Solicitação ou Tranferência 
				xTerritors := CRMA690EvalTerritory(cProcess,cAlsRot,.T.,.F., cRotName)	
				
				If ValType(xTerritors) == "A"
					lRet := xTerritors[1]	
				Else
					lRet := .F.
				EndIf
				
				//------------------------------
				// Executa validação do membro
				//------------------------------
				If lRet .And. !Empty(xTerritors[2])
					lRet := CRM020CMbrAval(oModel, xTerritors[2], cRotName)
				Else
					//---------------------------------------------------------------
					// Se não encontrar nenhum territorio deixa transferir a conta.
					//---------------------------------------------------------------
					lRet := .T.    
				EndIf  
				
			EndIf
			RestArea(aAreaRot)
		EndIf		
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020CMbrAval

Função que valida se o usuário faz parte do território da conta

@sample		CRM020CMbrAval(oModel, cCodTer)

@param		oModel	, objeto	, Estrutura do modelo de dados
@param		cCodTer	, caractere	, Código do território da conta
@param		cRotName, caractere	, CRMA020 -> Tranferência / CRMA020B -> Solicitação

@return		lMbrOk, logico, Verdadeiro/Falso

@author		Jonatas Martins
@since		04/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRM020CMbrAval(oModel, cCodTer, cRotName)

Local aAreaAZS	:= AZS->(GetArea())
Local cAlsTmp		:= GetNextAlias()
Local cCodUser		:= ""
Local cUnidade	:= ""
Local cEquipe		:= ""
Local lMbrOk		:= .T.
Local aUserPaper	:= {}

Default oModel	:= Nil
Default cCodTer := "" 
Default cRotName:= ""

//----------------------------------------------------------
// Obtem código do usuário conforme a rotina
//----------------------------------------------------------
// TRANSFERÊNCIA 
If cRotName == "CRMA020"

	AZS->( DbSetOrder( 4 ) ) //AZS_FILIAL + AZS_VEND
	 
	If AZS->( DbSeek( xFilial("AZS") + oModel:GetValue("AIMMASTER","AIM_VENSOL") ) )
		cCodUser := AZS->AZS_CODUSR
		cUnidade := AZS->AZS_CODUND
		cEquipe  := AZS->AZS_CODEQP
	EndIf
	
// SOLICITAÇÃO
Else
	aUserPaper	:= CRMXGetPaper()
	If !Empty( aUserPaper )
		cCodUser := aUserPaper[USER_PAPER_CODUSR] 
		cUnidade := aUserPaper[USER_PAPER_CODUND] 
		cEquipe  := aUserPaper[USER_PAPER_CODEQP] 
	EndIf
EndIf

If !Empty( cCodUser ) 
	
	BeginSql Alias cAlsTmp
	      
	      SELECT A09.A09_TPMBRO, A09.A09_CODTER, A09.A09_CODMBR
	      
	      FROM %Table:A09% A09
	      
	      WHERE ( ( A09_TPMBRO = "1" AND A09_CODMBR = %Exp:cUnidade% ) OR
	      ( A09_TPMBRO = "2" AND A09_CODMBR = %Exp:cCodUser% ) OR
	      ( A09_TPMBRO = "3" AND A09_CODMBR = %Exp:cEquipe% ) ) AND
	      A09_CODTER = %Exp:cCodTer%  AND A09_FILIAL = %xFilial:A09% AND 
	      A09_MSBLQL <> "1"	AND A09.%NotDel%
	       
	EndSql
	
	//----------------------------------------------------------
	// Efetua a gravação dos dados do território na solicitação
	//----------------------------------------------------------
	If (cAlsTmp)->( !Eof() ) .And. !Empty( (cAlsTmp)->A09_CODMBR )
		lMbrOk := CRM020CSetTer( oModel, cCodTer, (cAlsTmp)->A09_TPMBRO, (cAlsTmp)->A09_CODMBR )
	EndIf
	
	(cAlsTmp)->( DbCloseArea() )	
	
EndIf

RestArea(aAreaAZS)

Return(lMbrOk)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM020CSetTer

Função que insere os dados do território no modelo para gravação futura

@sample	CRM020SetTer(oModel,cCodTer,cTpMem,cCodMem)

@param		oModel, objeto	, Estrutura do modelo de dados
@param		cCodTer, caractere, Código do território da conta
@param		cTpMem, caractere, Tipo do membro do território
@param		cCodMem, caractere, Código do membro território 

@return		lSetOk, logico, Verdadeiro/Falso

@author		Jonatas Martins
@since		04/09/2015
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRM020CSetTer(oModel,cCodTer,cTpMem,cCodMem)

Local oMdlAIM		:= Nil
Local lSetOk		:= .T.
Local aCposAIM		:= {"AIM_CODTER","AIM_TPMEM","AIM_CODMEM"}
Local nX			:= 0

Default oModel	:= Nil
Default cCodTer	:= ""
Default cTpMem	:= ""
Default cCodMem	:= ""

If ValType(oModel) == "O"

	oMdlAIM := oModel:GetModel("AIMMASTER") 
	
	For nX := 1 To Len(aCposAIM)
		Do Case
			Case aCposAIM[nX] ==  "AIM_CODTER"
				lSetOk := oMdlAIM:SetValue(aCposAIM[nX],cCodTer)			
			Case aCposAIM[nX] ==  "AIM_TPMEM"
				lSetOk := oMdlAIM:SetValue(aCposAIM[nX],cTpMem)
			Case aCposAIM[nX] ==  "AIM_CODMEM"	
				lSetOk := oMdlAIM:SetValue(aCposAIM[nX],cCodMem)
		EndCase
		//-----------------------------------------------------------
		// Finaliza o loop caso não consiga setar o valor no modelo
		//-----------------------------------------------------------
		If !lSetOk
			Exit
		EndIf	
	Next nX
EndIf

Return (lSetOk)