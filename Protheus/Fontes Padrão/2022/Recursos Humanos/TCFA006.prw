#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TCFA006.CH'


/*/{Protheus.doc} TCFA006
//Permiss�es do usu�rio para o MeuRH
@author carlos.augusto
@since 30/05/2019
@version 1.0
@type function
/*/
Function TCFA006()
	Local aArea    	:= GetArea()
	Private oBrowse	:= Nil
	
	If !AliasInDic("RJD")
		//A tabela RJD n�o existe no dicion�rio de dados!# � necess�rio realizar a atualiza��o do sistema para a expedi��o mais recente.
		MSGINFO( STR0026  + CRLF + CRLF + STR0027, STR0001 )
		Return()
	Endif

    //Avalia o compartilhamento RJD / AI3
	If (FWModeAccess( "RJD", 1) + FWModeAccess( "RJD", 2) + FWModeAccess( "RJD", 3)) <> ;
	   (FWModeAccess( "AI3", 1) + FWModeAccess( "AI3", 2) + FWModeAccess( "AI3", 3))
		//"Modo de compartilhamento inv�lido para a tabela RJD"
		//"A tabela RJD deve possuir o mesmo compartilhamento da tabela AI3 (Usu�rios Gen�ricos)."
		MSGINFO( STR0028  + CRLF + CRLF + STR0029, STR0001 )
		Return()
	EndIf


	//-------------------------
	//Instancia o objeto Browse
	//-------------------------
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('AI3')
	oBrowse:SetDescription(STR0001) //"Permiss�es do usu�rio para o MeuRH
	oBrowse:Activate()

	RestArea(aArea)
Return ()

/*/{Protheus.doc} ModelDef
//Modelo de dados do programa
@author carlos.augusto
@since 30/05/2019
@version 1.0
@return modelo de dados
@type function
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruAI3  := FwFormStruct( 1, "AI3" ) 
	Local oStruRJD  := FWFormStruct( 1, 'RJD' )

	oModel := MpFormModel():New( "TCFA006",/*bPre*/ ,/*bPost*/ ,/*bCommit*/ , /*bCancel*/ )
	oModel:SetDescription( STR0001 ) //"Permiss�es do usu�rio para o MeuRH

	oModel:AddFields( "TCFA006_AI3", , oStruAI3)
	oModel:GetModel( "TCFA006_AI3" ):SetDescription( STR0001 ) //"Permiss�es do usu�rio para o MeuRH
	oModel:SetPrimaryKey( { "AI3_FILIAL", "AI3_CODIGO" } )

	oStruAI3:SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

	oStruRJD:SetProperty( 'RJD_GRUPO' , MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, '.F.' ))
	oStruRJD:SetProperty( 'RJD_DESC' ,  MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, '.F.' ))
	oModel:AddGrid( "TCFA006_RJD", "TCFA006_AI3", oStruRJD)
	oModel:GetModel('TCFA006_RJD'):SetDescription( STR0002 ) //Servi�os
	oModel:GetModel('TCFA006_RJD'):SetOptional( .F. )

	oModel:SetRelation( 'TCFA006_RJD', {{'RJD_FILIAL', 'FWxFilial("RJD")'},{ 'RJD_CODUSU', 'AI3_CODUSU' }}, "RJD_FILIAL+RJD_CODUSU+RJD_GRUPO+RJD_SEQ" )
	
Return oModel


/*/{Protheus.doc} ViewDef
//Define a view para o programa
@author carlos.augusto
@since 30/05/2019
@version 1.0
@return View do programa
@type function
/*/
Static Function ViewDef()
	Local oStruAI3  := FwFormStruct( 2, "AI3",{|cCampo|(Alltrim(cCampo) $ "AI3_FILIAL|AI3_CODUSU|AI3_LOGIN|AI3_NOME")})
	Local oStruRJD  := FwFormStruct( 2, "RJD",{|cCampo|!(Alltrim(cCampo) $ "RJD_CODUSU|RJD_SEQ|RJD_WS|RJD_VERSAO")})  
	Local oModel	:= FwLoadModel( "TCFA006" )
	Local oView		:= FwFormView():New() 

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_AI3', oStruAI3, 'TCFA006_AI3' )

	oView:AddGrid( "TCFA006_RJD", oStruRJD, "TCFA006_RJD" )

	oView:CreateHorizontalBox( "SUPERIOR", 15 )
	oView:CreateHorizontalBox( "INFERIOR", 85 )

	oView:SetOwnerView( "TCFA006_AI3", "SUPERIOR" )
	oView:SetOwnerView( "TCFA006_RJD", "INFERIOR" )

	oView:EnableTitleView( "TCFA006_AI3" )
	oView:EnableTitleView( "TCFA006_RJD" )

Return (oView)


/*/{Protheus.doc} MenuDef
//Define as opcoes para a tela principal
@author carlos.augusto
@since 31/05/2019
@version 1.0
@return Opcoes de menu
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0003 Action 'TCFA006VIE()' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004 Action 'TCFA006UPD()' OPERATION 4 ACCESS 0 //"Alterar"

Return aRotina


/*/{Protheus.doc} TCFA006UPD
//Funcao do metodo alterar
@author carlos.augusto
@since 31/05/2019
@version 1.0
@type function
/*/
Function TCFA006UPD()

	TCFA006SRV()
	FWExecView('', 'VIEWDEF.TCFA006', MODEL_OPERATION_UPDATE, , {|| .T. })

Return 


/*/{Protheus.doc} TCFA006VIE
//Funcao do metodo visualizar
@author carlos.augusto
@since 04/06/2019
@version 1.0

@type function
/*/
Function TCFA006VIE()

	TCFA006SRV()
	FWExecView('', 'VIEWDEF.TCFA006', MODEL_OPERATION_VIEW, , {|| .T. })

Return 


/*/{Protheus.doc} AtualRJD
//Realiza o controle de atualizacao da tabela RJD
@author carlos.augusto
@since 31/05/2019
@version 1.0
@param aServicos, array, descricao
@param cVersao, characters, descricao
@type function
/*/
Static Function AtualRJD( aServicos, cVersao )
	Local aArea		:= GetArea()
	Local nChoice
	Local nChoices
	Local nPosWSOK := .F.

	//Posicao de cada elemento no array pre-definido em TCFA006SRV()
	nPosWS		:= 1
	nPosHab		:= 2
	nPosGrp		:= 3
	nPoDesc		:= 4
	nPosSeq		:= 5
	nPosStatus	:= 6

	//No primeiro momento serao alterados os registros encontrados e deletados os que nao forem encontrados no array de servicos
	nChoices := Len( aServicos )
	RJD->( DbGoTop() )
	RJD->(dbSetOrder(1))
	If RJD->(dbSeek(FWxFilial("RJD") + AI3->AI3_CODUSU))
		While RJD->( !Eof() ) .And. RJD->RJD_FILIAL == AI3->AI3_FILIAL .And. RJD->RJD_CODUSU == AI3->AI3_CODUSU
			For nChoice := 1 To nChoices
				If aServicos[ nChoice, nPosWS ] == AllTrim(RJD->RJD_WS)
					nPosWSOK := .T.
					Exit
				EndIf
			Next			
			If nPosWSOK
				nPosWSOK := .F.
				If RJD->( RecLock( "RJD" , .F. ) )
					RJD->( RJD_GRUPO )	:= aServicos[ nChoice, nPosGrp ]
					RJD->( RJD_DESC )	:= aServicos[ nChoice, nPoDesc ]
					RJD->( RJD_SEQ )	:= aServicos[ nChoice, nPosSeq ]
					RJD->( RJD_VERSAO ) := cVersao
					RJD->( MsUnlock() )
				EndIf
				//Marca o controle interno no array de servicos
				aServicos[ nChoice, nPosStatus ] := .T.			
			Else
				//Se nao encontrou o registro da tabela no array de servicos deve ser excluido
				RecLock("RJD", .F. )
				RJD->( DbDelete())
				RJD->(MsUnLock())
			EndIf
			RJD->(DbSkip())
		EndDo
	EndIf


	For nChoice := 1 To nChoices
		//Procura pelos servicos nao encontrados/marcos para que possam ser adicionados
		If !aServicos[ nChoice, nPosStatus ]
			If RJD->( RecLock( "RJD" , .T. ) )
				RJD->( RJD_GRUPO )	:= aServicos[ nChoice, nPosGrp ]
				RJD->( RJD_DESC )	:= aServicos[ nChoice, nPoDesc ]
				RJD->( RJD_SEQ )	:= aServicos[ nChoice, nPosSeq ]
				RJD->( RJD_HABIL )	:= aServicos[ nChoice, nPosHab ]
				RJD->( RJD_FILIAL ) := FwxFilial("RJD")
				RJD->( RJD_CODUSU )	:= AI3->AI3_CODUSU
				RJD->( RJD_WS )		:= aServicos[ nChoice, nPosWS ]
				RJD->( RJD_VERSAO ) := cVersao
				RJD->( MsUnlock() )
			EndIf
			aServicos[ nChoice, nPosStatus ] := .T.	
		EndIf
	Next	

	RestArea( aArea )

Return


/*/{Protheus.doc} TCFA006SRV
//Definir quais servicos estarao disponiveis para o administrador selecionar
//Informar uma nova versao para a variavel cVersao se desejar que o sistema atualize os servicos
@author carlos.augusto
@since 31/05/2019
@version 1.0
@type function
/*/
Function TCFA006SRV( lGetServ)
	Local cVersao		:= ""
	Local cNewVersion	:= ""
	Local cCliVersao	:= ""
	Local aArea			:= GetArea()
	Local aServicos 	:= {}
	Local lRelease25	:= GetRpoRelease() >= "12.1.025"
	Local lRelease27	:= GetRpoRelease() >= "12.1.027"
	Local lOrgCfg1      := SuperGetMv("MV_ORGCFG", NIL ,"0") == "1"

	Default lGetServ	:= .F.
	/* Webservice, habilitado, Rotina(grupo), Descricao, Sequencia, controle interno do programa para validar 
	se e necessario adicionar na tabela RJD */
	
	If lRelease25
		Aadd(aServicos,{"vacation"						,"2",STR0006 /*"F�rias"*/			,STR0041 /*"Cadastro e solicita��es de f�rias"*/							,"001",.F. })
		Aadd(aServicos,{"vacationRegister"				,"1",STR0006 /*"F�rias"*/			,STR0040 /*"Inclus�o de solicita��o de f�rias"*/							,"002",.F. })
		Aadd(aServicos,{"absenceManager"				,"1",STR0008 /*"Gest�o"*/			,STR0009 /*"Gest�o de f�rias"*/												,"001",.F. })
		Aadd(aServicos,{"clockingGeoView"				,"2",STR0008 /*"Gest�o"*/			,STR0010 /*"Gest�o de marca��es por geolocaliza��o"*/						,"002",.F. })
		Aadd(aServicos,{"substituteRequest"				,"2",STR0008 /*"Gest�o"*/			,STR0012 /*"Cadastro de solicita��es de substituto"*/						,"003",.F. })
		Aadd(aServicos,{"profile"						,"1",STR0031 /*"Home"  */			,STR0059 /*"Acesso ao Perfil"*/ 											,"001",.F. })
		Aadd(aServicos,{"searchEmployee"				,"2",STR0031 /*"Home"  */			,STR0032 /*"Localizar funcion�rios"				   */						,"002",.F. })
		Aadd(aServicos,{"dashboardBirthdays"    		,"2",STR0031 /*"Home"  */			,STR0054 /*"Visualizar os aniversariantes do m�s na Home"*/					,"003",.F. })
		Aadd(aServicos,{"dashboardEmployeeBirthday"		,"1",STR0031 /*"Home"  */			,STR0055 /*"Visualizar o anivers�rio de empresa na Home"*/   				,"004",.F. })
		Aadd(aServicos,{"dashboardPayment"	    		,"1",STR0031 /*"Home"  */			,STR0053 /*"Visualizar o demonstrativo de pagamento na Home"*/				,"005",.F. })
		Aadd(aServicos,{"dashboardVacationCountdown"	,"1",STR0031 /*"Home"  */			,STR0056 /*"Visualizar os dias faltantes at� o inicio das f�rias na Home"*/ ,"006",.F. })
		Aadd(aServicos,{"payment"						,"1",STR0013 /*"Pagamentos"*/		,STR0014 /*"Envelope de Pagamento"*/										,"001",.F. })
		Aadd(aServicos,{"annualReceipt"					,"1",STR0013 /*"Pagamentos"*/		,STR0015 /*"Informe de rendimentos"*/										,"002",.F. })
		Aadd(aServicos,{"salaryHistory"					,"2",STR0013 /*"Pagamentos"*/	    ,STR0030 /*"Hist�rico Salarial"*/											,"003",.F. })
		Aadd(aServicos,{"payrollLoan"					,"2",STR0013 /*"Pagamentos"*/	    ,STR0050 /*"Empr�stimo Consignado"*/										,"004",.F. })
		Aadd(aServicos,{"timesheet"						,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0018 /*"Espelho do ponto e saldo do banco de horas"*/					,"001",.F. })
		Aadd(aServicos,{"clockingRegister"				,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0019 /*"Inclus�o batida informada"*/									,"002",.F. })
		Aadd(aServicos,{"clockingUpdate"				,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0020 /*"Editar batidas informadas"*/									,"003",.F. })
		Aadd(aServicos,{"clockingGeoRegister"			,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0021 /*"Inclus�o batida geolocaliza��o"*/								,"004",.F. })
		Aadd(aServicos,{"clockingGeoDisconsider"		,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0022 /*"Desconsiderar batidas por geolocaliza��o"*/						,"005",.F. })
		Aadd(aServicos,{"medicalCertificate"			,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0024 /*"Cadastro de atestado m�dico"*/									,"006",.F. })
		Aadd(aServicos,{"allowance"						,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0025 /*"Cadastro de Abono"*/											,"007",.F. })
		Aadd(aServicos,{"externalClockIn"				,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0051 /*"Ponto via Clock-In"*/											,"008",.F. })

		If lRelease27
			Aadd(aServicos,{"vacationNotice"						,"2",STR0006 /*"F�rias"*/			,STR0034 /*"Aviso de f�rias"*/														,"003",.F. })
			Aadd(aServicos,{"vacationReceipt"						,"2",STR0006 /*"F�rias"*/			,STR0035 /*"Recibo de f�rias"*/														,"004",.F. })
			Aadd(aServicos,{"downloadVacationReceipt"				,"2",STR0006 /*"F�rias"*/			,STR0048 /*"Download do recibo de f�rias"*/											,"005",.F. })
			Aadd(aServicos,{"teamManagement"						,"2",STR0008 /*"Gest�o"*/			,STR0033 /*"Gest�o do Time"*/														,"004",.F. })
			Aadd(aServicos,{"managementOfDelaysAndAbsences"			,"2",STR0008 /*"Gest�o"*/			,STR0049 /*"Gest�o de Atrasos e Faltas"*/											,"005",.F. })
			Aadd(aServicos,{"requisitions"		    				,"2",STR0008 /*"Gest�o"*/			,STR0036 /*"Requisi��es"*/                              							,"006",.F. })
			Aadd(aServicos,{"demission"			    				,"2",STR0008 /*"Gest�o"*/			,STR0037 /*"Requisi��o de Desligamento"*/               							,"007",.F. })
			Aadd(aServicos,{"demissionRequest"	    				,"2",STR0008 /*"Gest�o"*/			,STR0038 /*"Inclus�o de Requisi��o de Desligamento"*/   							,"008",.F. })
			Aadd(aServicos,{"employeeDataChange"					,"2",STR0008 /*"Gest�o"*/			,STR0067 /*"Requisi��o de Altera��o Salarial (salario, cargo ou fun��o)"*/			,"009",.F. }) 
			Aadd(aServicos,{"employeeDataChangeRequest"				,"2",STR0008 /*"Gest�o"*/			,STR0068 /*"Inclus�o de Requisi��o de Altera��o Salarial"*/							,"010",.F. })
			If(lOrgCfg1)
				Aadd(aServicos,{"staffIncrease"					    ,"2",STR0008 /*"Gest�o"*/	   		,STR0072 /*"Requisi��o de aumento de quadro"*/ 	                                    ,"011",.F. })
				Aadd(aServicos,{"staffIncreaseRequest"    			,"2",STR0008 /*"Gest�o"*/			,STR0076 /*"Inclus�o de Requisi��o de Aumento de Quadro"*/   						,"012",.F. })
			EndIf 
			Aadd(aServicos,{"transfer"								,"2",STR0008 /*"Gest�o"*/			,STR0073 /*"Requisi��o de Transfer�ncia"*/											,"013",.F. })
			Aadd(aServicos,{"transferRequest"						,"2",STR0008 /*"Gest�o"*/			,STR0079 /*"Inclus�o de Requisi��o de Transfer�ncia."*/								,"014",.F. })
			Aadd(aServicos,{"teamManagementVacation"				,"2",STR0008 /*"Gest�o"*/			,STR0042 /*"Acesso a F�rias na Gest�o Time"*/										,"015",.F. })
			Aadd(aServicos,{"teamManagementSalaryHist"				,"2",STR0008 /*"Gest�o"*/			,STR0043 /*"Acesso ao Hist�rico salarial na Gest�o Time"*/							,"016",.F. })
			Aadd(aServicos,{"teamManagementMedical"					,"2",STR0008 /*"Gest�o"*/			,STR0044 /*"Acesso ao Atestado M�dico na Gest�o Time"*/								,"017",.F. })
			Aadd(aServicos,{"teamManagementAllowance"				,"2",STR0008 /*"Gest�o"*/			,STR0045 /*"Acesso ao Abono na Gest�o Time"*/										,"018",.F. })
			Aadd(aServicos,{"teamManagementProfile"					,"2",STR0008 /*"Gest�o"*/			,STR0046 /*"Acesso ao Perfil na Gest�o Time"*/										,"019",.F. })
			Aadd(aServicos,{"teamManagementTimesheet"				,"2",STR0008 /*"Gest�o"*/			,STR0047 /*"Acesso ao Ponto Eletr�nico na Gest�o Time"*/							,"020",.F. })
			Aadd(aServicos,{"dashboardBalanceTeamSum"				,"1",STR0008 /*"Gest�o"*/			,STR0069 /*"Acesso ao Banco de Horas do Time na Home"*/								,"021",.F. })
			Aadd(aServicos,{"teamManagementViewSalary"				,"2",STR0008 /*"Gest�o"*/			,STR0052 /*"Visualizar o sal�rio da equipe na Gest�o Time"*/						,"022",.F. })			
			Aadd(aServicos,{"teamManagementDivergentClockingView"	,"2",STR0008 /*"Gest�o"*/			,STR0057 /*"Visualizar diverg�ncias de ponto da equipe na Gest�o Time"*/			,"023",.F. })
			Aadd(aServicos,{"teamManagementSendAttachmentAllowance"	,"2",STR0008 /*"Gest�o"*/			,STR0060 /*"Enviar anexo na solicita��o de abono na Gest�o Time"*/					,"024",.F. })
			Aadd(aServicos,{"teamManagementViewAttachmentAllowance"	,"2",STR0008 /*"Gest�o"*/			,STR0063 /*"Visualizar anexo na solicita��o de abono na Gest�o Time"*/				,"025",.F. })	
			Aadd(aServicos,{"teamManagementDownloadShareClocking"	,"1",STR0008 /*"Gest�o"*/			,STR0065 /*"Download e compartilhamento do espelho de ponto para gestores."*/		,"026",.F. })
			Aadd(aServicos,{"notificationClocking"					,"1",STR0008 /*"Gest�o"*/			,STR0074 /*"Acesso as notifica��es de marca��o de ponto e abono."*/					,"027",.F. })
			Aadd(aServicos,{"notificationVacation"					,"1",STR0008 /*"Gest�o"*/			,STR0075 /*"Acesso as notifica��es de f�rias."*/									,"028",.F. })
			Aadd(aServicos,{"divergentClockingView"					,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0058 /*"Visualizar diverg�ncias de ponto"*/										,"009",.F. })
			Aadd(aServicos,{"sendAttachmentAllowance"				,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0061 /*"Enviar anexo na solicita��o de Abono"*/									,"010",.F. })
			Aadd(aServicos,{"viewAttachmentAllowance"				,"2",STR0017 /*"Ponto Eletr�nico"*/	,STR0062 /*"Visualizar anexo na solicita��o de Abono"*/								,"011",.F. })
			Aadd(aServicos,{"balanceSummary"					    ,"1",STR0017 /*"Ponto Eletr�nico"*/	,STR0070 /*"Visualizar saldo do banco de horas"*/                                   ,"012",.F. })
			Aadd(aServicos,{"alterPassword"		    				,"2",STR0031 /*"Home"  */			,STR0039 /*"Alterar senha"*/   													  	,"007",.F. })
			Aadd(aServicos,{"workLeave "							,"2",STR0031 /*"Home"  */			,STR0066 /*"Visualizar Afastamentos"*/ 												,"008",.F. })
			Aadd(aServicos,{"downloadShareClocking"					,"1",STR0017 /*"Ponto Eletr�nico"*/	,STR0064 /*"Download e compartilhamento do espelho de ponto para funcion�rios."*/ 	,"012",.F. })
			Aadd(aServicos,{"dependents"							,"2",STR0013 /*"Pagamentos"*/		,STR0077 /*"Visualizar os dependentes."*/ 											,"005",.F. })
			Aadd(aServicos,{"beneficiaries"							,"2",STR0013 /*"Pagamentos"*/		,STR0078 /*"Visualizar os benefici�rios."*/											,"006",.F. })
		EndIf
	Else
		Aadd(aServicos,{"absenceManager"		,"1",STR0008 /*"Gest�o"*/			,STR0009 /*"Gest�o de f�rias"*/								,"001",.F. })
		Aadd(aServicos,{"payment"				,"1",STR0013 /*"Pagamentos"*/		,STR0014 /*"Envelope de Pagamento"*/						,"001",.F. })
		Aadd(aServicos,{"annualReceipt"			,"1",STR0013 /*"Pagamentos"*/		,STR0015 /*"Informe de rendimentos"*/						,"002",.F. })
	EndIf
	
	If lGetServ
		Return aServicos
	EndIf

	cNewVersion := If( lRelease27, "40", "41")
	cVersao		:= PADR(cNewVersion ,TamSX3('RJD_VERSAO')[1],' ')
	
	RJD->( DbGoTop() )
	If RJD->(dbSeek(FWxFilial("RJD") + AI3->AI3_CODUSU))
		cCliVersao := RJD->( RJD_VERSAO )
	Else
		cCliVersao := ""
	EndIf

	RestArea( aArea )

	If cVersao <> cCliVersao
		Processa({|| AtualRJD( aServicos, cVersao )}, STR0005) //"Atualizando tabela de servi�os."
	EndIf

Return
