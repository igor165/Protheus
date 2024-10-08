#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "FwMvcDef.ch"
#Include "Fisa034.ch"

/*/{Protheus.doc} FISA034
Controle de Cr�ditos Fiscais - SPED Fiscal

@author Luccas Curcio
@since 22/08/2011

@return nulo, n�o tem retorno.

@obs Programa respons�vel por controlar os registros de recebimento e utiliza��o de cr�ditos fiscais.
/*/
Function FISA034()

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacCE6
	Private oDlgPrinc
	
	DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL
	
	oFWLayer	:=	FWLayer():New()
	oFWLayer:Init(oDlgPrinc, .F., .T.)
	
	oFWLayer:AddLine('UP', 70, .F.)
	oFWLayer:AddCollumn('ALLUP', 100, .T., 'UP')
	oPanelUp	:=	oFWLayer:GetColPanel('ALLUP', 'UP')
	
	oFWLayer:AddLine('DOWN', 30, .F.)
	oFWLayer:AddCollumn('ALLDOWN', 100, .T., 'DOWN')
	oPanelDown	:=	oFWLayer:GetColPanel('ALLDOWN', 'DOWN')
	
	oBrowseUp	:=	FWMBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription(STR0001)//"Controle de Cr�ditos Fiscais"
	oBrowseUp:SetAlias("CE5")
	oBrowseUp:SetMenuDef("FISA034")
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()
	oBrowseUp:Activate()
	
	oBrowseDown	:=	FWMBrowse():New()
	oBrowseDown:SetOwner(oPanelDown)
	oBrowseDown:SetDescription(STR0007)//"Saldo de Cr�ditos Fiscais"
	oBrowseDown:SetMenuDef('')
	oBrowseDown:DisableDetails()
	oBrowseDown:SetAlias("CE6")
	oBrowseDown:SetProfileID( '2' )
	oBrowseDown:Activate()
	
	oRelacCE6	:=	FWBrwRelation():New()
	oRelacCE6:AddRelation (oBrowseUp, oBrowseDown, { {"CE6_FILIAL","CE5_FILIAL"} , {"CE6_CODLAN","CE5_CODLAN"}, {"CE6_PERIOD","CE5_PERIOD"} } )
	oRelacCE6:Activate()
	
	Activate MsDialog oDlgPrinc Center

Return

/*/{Protheus.doc} MenuDef
Monta o menu com as op��es da rotina

@author Luccas Curcio
@since 22/08/2011

@return array, contem as opcoes padrao para o MeuDef de uma rotina em MVC (FWMVCMenu).
/*/
Static Function MenuDef()

Return FWMVCMenu("FISA034")

/*/{Protheus.doc} ModelDef
Define o Modelo da Rotina (oModel)

@author Luccas Curcio
@since 22/08/2011

@return objeto, cont�m as funcionalidades da rotina
/*/
Static Function ModelDef()

	Local oStruCE5 	:=	FWFormStruct (1, "CE5")
	Local oModel
	Local cQryCE6	:=	"CE6"
	
	oModel	:=	MPFormModel():New('CE5MODEL', ,{ |oModel| ValidForm(oModel,@cQryCE6) }  ,{ |oModel| GravaForm(oModel,cQryCE6) } )
	
	oModel:AddFields('CE5MODEL',,oStruCE5)
	oModel:SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:GetModel('CE5MODEL'):SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:SetPrimaryKey( { "CE5_CODIGO" } )
	oModel:SetVldActivate({|oModel| fVldActiv(oModel) })
	                                                                         
	// Define que os campos podem ser editados apenas em uma opera��o de inclus�o
	oStruCE5:SetProperty( 'CE5_CODIGO' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODLAN' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_DATA' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_TPMOV' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODUTI' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODCDH' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
              
Return oModel                                        

/*/{Protheus.doc} fVldActiv
Fun��o para validar o activate

@author Vitor Ribeiro
@since 28/12/2017

@param oModel, objeto, contem o modeldef

@return logico, se a activate continua ou n�o.
/*/
Static Function fVldActiv(oModel)
	
	Local lContinua := .T.
	
	Local nOperation := 0
	
	Default oModel := ModelDef()
	
	nOperation := oModel:GetOperation()
	
	// Se n�o for visualiza��o e o campo CE5_TPLANC existir na base
	If nOperation <> MODEL_OPERATION_VIEW .And. CE5->(FieldPos("CE5_TPLANC")) > 0
		Help(,,"A034VLDACT",,CRLF + STR0009 + CRLF + CRLF + STR0010,1,0)	// "A manuten��o das informa��es s�o realizadas atrav�s da apura��o de icms na aba 'Extra Apura��o'!"###"Verifique."
		lContinua := .F.
	EndIf
	
Return lContinua

/*/{Protheus.doc} ViewDef
Define a visualiza��o de telas da rotina

@author Luccas Curcio
@since 22/08/2011

@return objeto, respons�vel pela exibi��o dos dados
/*/
Static Function ViewDef()

	Local oModel	:=	FWLoadModel ("FISA034")
	Local oStruCE5	:=	FWFormStruct (2, "CE5")
	Local oView
	
	oView	:=	FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField("View_CE5",oStruCE5,"CE5MODEL")
	oView:CreateHorizontalBox("TELA",100)
	oView:SetOwnerView("View_CE5","TELA")

Return oView

/*/{Protheus.doc} ValidForm
Valida as informa��es contidas no formul�rio

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, cont�m as funcionalidades da rotina
@param cQryCE6, caracter, cont�m o conte�do da query CE6

@return logico, se validou ou n�o.
/*/
Static Function ValidForm(oModel,cQryCE6)

	Local lRet		:=	.T.
	
	Local nOperation:=	oModel:GetOperation()
	
	Local cIndex	:=	""
	Local cQuery	:=	""
	Local cPeriodo	:=	""
	Local nValorAlt	:=	0
	Local aVldModel	:=	{oModel:GetValue ('CE5MODEL','CE5_TPMOV' ),;
						 oModel:GetValue ('CE5MODEL','CE5_CODLAN'),;
						 oModel:GetValue ('CE5MODEL','CE5_DATA'  ),;
				 		 oModel:GetValue ('CE5MODEL','CE5_VALOR' )}
	
	//Reseta vari�vel que recebe a query da tabela CE6 para pr�ximos processamentos
	cQryCE6	:=	"CE6"
	                                                           
	//Converte a data para formato per�odo
	cPeriodo	:=	Substr(DTOS(aVldModel[3]),1,6)
	
	DbSelectArea(cQryCE6)
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cQryCE6 := GetNextAlias()
			
			BeginSql alias cQryCE6
				SELECT 	* 
				FROM 	%table:CE6% CE6
				WHERE   CE6.CE6_FILIAL	= %xfilial:CE5%		AND
						CE6.CE6_CODLAN	= %Exp:aVldModel[2]%AND
						CE6.%notDel%
				ORDER BY CE6_PERIOD DESC
			EndSql
		Else
	#ENDIF
		cIndex  :=  CriaTrab (NIL,.F.)
		cQuery  :=  "CE6_FILIAL='"+xFilial("CE5")+"' AND CE6_CODLAN=='"+aVldModel[2]+"' AND CE6.D_E_L_E_T_  = ' '"
	    IndRegua (cQryCE6, cIndex, CE6->(IndexKey ()),, cQuery)
	    nIndex  :=  RetIndex(cQryCE6)
	    
	    #IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF
		
		DbSelectArea (cQryCE6)
		DbSetOrder (nIndex+1)
	#IFDEF TOP
		Endif
	#ENDIF
	
	// Posiciono no saldo do �ltimo per�odo calculado (o ORDER BY foi invertido, por isso utiliza-se DbGoTop())
	(cQryCE6)->(DbGoTop())
	
	// Verifica se j� existe saldo em per�odo posteior � opera��o que est� sendo feita
	If (cQryCE6)->CE6_PERIOD > cPeriodo 
		Help(,,"A034POST",,STR0002,1,0)//"J� existe saldo para um per�odo posterior utilizando este c�digo de ajuste!"
		lRet	:= 	.F.
	Endif
	
	If nOperation == 3 //Inclus�o 
		DbSelectArea ("CE5")
		CE5->(DbSetOrder (1))
		If CE5->(DbSeek(xFilial("CE5")+oModel:GetValue ('CE5MODEL','CE5_CODIGO')+oModel:GetValue ('CE5MODEL','CE5_CODLAN')+oModel:GetValue ('CE5MODEL','CE5_TPMOV' )))
			Help("",1,"Help","Help",STR0008,1,0) //"Controle de Cr�ditos j� cadastrado"
			lRet := .F.
		EndIf
		
		//Altera��o para n�o permitir que seja gravado um registro do tipo = "Utiliza��o do Credito" sem ter a tabela (CE6) cadastrada, para verificar se tem credito disponivel ou n�o.
		If (cQryCE6)->(Eof()) .And. aVldModel[1] == "U"
			Help(,,"A034REFC",,STR0003,1,0)//"N�o existe cr�dito referente a este c�digo de ajuste!" 
			lRet	:= 	.F.		 
		EndIF	
	EndIf
	
	If lRet
		While !(cQryCE6)->(Eof())
			/*
				Se n�o contiver erro no per�odo atual, n�o � necess�rio varrer cQryCE6 inteiro. �
				Os registros ser�o utilizados para verifica��o de saldo na fun��o de grava��o
			*/   
			If cPeriodo < (cQryCE6)->CE6_PERIOD
				Exit
			Endif
		
			If nOperation == 3 //Inclus�o
	
			
				If aVldModel[1] == "U"
					// Verifica se existe cr�dito referente ao c�digo para que possa utilizar
					If cPeriodo == (cQryCE6)->CE6_PERIOD
						If (cQryCE6)->CE6_SALDO <= 0
							Help(,,"A034REFC",,STR0003,1,0)//"N�o existe cr�dito referente a este c�digo de ajuste!" 
							lRet	:= 	.F.
							Exit 
						Elseif (cQryCE6)->CE6_SALDO - aVldModel[4] < 0 
							Help(,,"A034SUFC",,STR0005,1,0) //"N�o existe cr�dito suficiente para esta opera��o!"
							lRet	:=	.F.
							Exit
						Endif
					Endif
				Endif
			
			Elseif nOperation == 5 //Exclus�o
				If aVldModel[1] == "R" 
					// Verifica se j� utilizou cr�dito com refer�ncia ao C�digo de Ajuste informado
					If (cQryCE6)->CE6_TOTUTI > 0 .And. (cQryCE6)->CE6_PERIOD >= cPeriodo
						Help(,,"A034NEXC",,STR0004,1,0)//"J� se utilizou de cr�dito referente a este c�digo de ajuste! N�o ser� exclu�do."
						lRet	:=	.F.
						Exit
					Endif
				Endif
			
			Elseif nOperation == 4 //Altera��o
				nValorAlt	:= CE5->CE5_VALOR - aVldModel[4]
				If aVldModel[1] == "U" .And. nValorAlt < 0 .And. (cQryCE6)->CE6_SALDO + nValorAlt < 0
					lRet	:=	.F.
					Exit
				Elseif aVldModel[1] == "R" .And. nValorAlt > 0 .And. (cQryCE6)->CE6_SALDO - nValorAlt < 0
					lRet	:=	.F.
					Exit
				Endif
				If !lRet
					Help(,,"A034ANEG",,STR0006,1,0) //"Ap�s essa altera��o, o saldo do per�odo ficar� negativo! N�o ser� alterado."
				Endif			
			Endif
			
			(cQryCE6)->(DbSkip())
		EndDo
	Endif
	
Return lRet 

/*/{Protheus.doc} GravaForm
Grava as informa��es contidas no formul�rio

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, cont�m as funcionalidades da rotina
@param cQryCE6, caracter, cont�m o conte�do da query CE6

@return logico, se validou ou n�o.

@obs Funcao respons�vel por gravar o conte�do do formul�rio. Os dados s�o obtidos atrav�s do objeto que cont�m as funcionalidades.
/*/
Static Function GravaForm(oModel,cQryCE6)

	Local lRet		:=	.T.
	Local nOperation:=	oModel:GetOperation()
	Local nSaldoAnt	:=	0
	Local aModel	:=	{}
	Local dData		:=	oModel:GetValue ('CE5MODEL','CE5_DATA'  )
	
	// Converte a data para formato per�odo e atribui o conte�do ao campo CE5_PERIOD
	If nOperation == 3
		oModel:SetValue('CE5MODEL','CE5_PERIOD',Substr(DTOS(dData),1,6))
	Endif
	
	aModel	:=	{oModel:GetValue ('CE5MODEL','CE5_TPMOV' ),;
				 oModel:GetValue ('CE5MODEL','CE5_CODLAN'),;
				 oModel:GetValue ('CE5MODEL','CE5_PERIOD'),;
				 oModel:GetValue ('CE5MODEL','CE5_VALOR' ),;
				 oModel:GetValue ('CE5MODEL','CE5_CODIGO'),;
				 oModel:GetValue ('CE5MODEL','CE5_TRANSF')}
	
	// Posiciono no saldo do �ltimo per�odo calculado (o ORDER BY foi invertido, por isso utiliza-se DbGoTop())
	(cQryCE6)->(DbGoTop())
	
	// Atribui �ltimo valor de Saldo � vari�vel nSaldoAnt
	If Alltrim((cQryCE6)->CE6_PERIOD) <> ''
		nSaldoAnt	:=	(cQryCE6)->CE6_SALDO
	Endif
	
	If nOperation == 3 //Inclus�o                                   
		IncSaldo(aModel,nSaldoAnt)
	Elseif nOperation == 5 //Exclus�o                         
		ExcSaldo(aModel)
	Elseif nOperation == 4 //Altera��o
		AltSaldo(aModel)
	Endif
	
	// Efetua grava��o/exclus�o do registro CE5 e fecha o Alias da query CE6
	FWFormCommit( oModel )
	(cQryCE6)->(DbCloseArea())
                                     
Return lRet

/*/{Protheus.doc} AltSaldo
Atualiza tabela de Saldo atrav�s de uma altera��o

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, cont�m as funcionalidades da rotina

@return nulo, n�o tem retorno.

@obs Fun��o respons�vel por atualizar os registros contidos na tabela de Saldo de Cr�ditos (CE6) atrav�s de uma altera��o no Controle (CE5)
/*/
Static Function AltSaldo(aModel)

	Local nValorAlt	:=	0
	Local nTotTran	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nSaldo	:=	0
	
	If aModel[1] == "R" //�Recebimento de Cr�dito 
		
		If CE5->(DbSeek(xFilial("CE5")+aModel[5]+aModel[2]+aModel[1]))
			// nValorAlt recebe a diferen�a entre o valor antigo e o alterado
			nValorAlt	:=	CE5->CE5_VALOR - aModel[4]
			
			If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
				// Calcula a diferen�a do Saldo e Total de Cr�dito atual
				nTotCred	:=	CE6->CE6_TOTCRE - nValorAlt	
				nSaldo		:=	CE6->CE6_SALDO - nValorAlt
				
				// Se transferencia, calcula a diferen�a do valor de transferencia
				If CE5->CE5_TRANSF == "1"
					nTotTran	:=	CE6->CE6_TOTTRA - nValorAlt
		   		Endif
				
				Begin Transaction
					RecLock("CE6",.F.)
					CE6->CE6_TOTCRE	:=	nTotCred
					CE6->CE6_SALDO	:=	nSaldo
					CE6->CE6_TOTTRA	:=	nTotTran
					CE6->(FKCommit())
					MsUnLock()
				End Transaction
			Endif
		Endif
	
	Else //�Utiliza��o de Cr�dito
	
		If CE5->(DbSeek(xFilial("CE5")+aModel[5]+aModel[2]+aModel[1]))
			// nValorAlt recebe a diferen�a entre o valor antigo e o alterado
			nValorAlt	:=	CE5->CE5_VALOR - aModel[4]
			
			If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
				// Calcula a diferen�a do Saldo e Total Utilizado atual
				nTotUtil	:=	CE6->CE6_TOTUTI - nValorAlt
				nSaldo		:=	CE6->CE6_SALDO + nValorAlt
				
				// Se transferencia, calcula a diferen�a do valor de transferencia
				If CE5->CE5_TRANSF == "1"
					nTotTran	:=	CE6->CE6_TOTTRA + nValorAlt
		   		Endif
		   		
		   		Begin Transaction
					RecLock("CE6",.F.)
					CE6->CE6_TOTUTI	:=	nTotUtil
					CE6->CE6_SALDO	:=	nSaldo
					CE6->CE6_TOTTRA	:=	nTotTran
					CE6->(FKCommit())
					MsUnLock()
				End Transaction
			Endif				
		Endif	
	Endif

Return

/*/{Protheus.doc} ExcSaldo
Atualiza tabela de Saldo atrav�s de uma exclus�o

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, cont�m as funcionalidades da rotina

@return nulo, n�o tem retorno.

@obs Fun��o respons�vel por atualizar os registros contidos na tabela de Saldo de Cr�ditos (CE6) atrav�s de uma altera��o no Controle (CE5)
/*/
Static Function ExcSaldo(aModel)

	Local nSaldo	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nTotTran	:=	0
	
	If aModel[1] == "R" //�Recebimento de Cr�dito
	
		nTotCred	:=	aModel[4]
		nSaldo		:=	aModel[4]
		
		// Verifica se o recebimento do cr�dito foi atrav�s de Transfer�ncia
		If CE5->CE5_TRANSF == "1"
			nTotTran	:=	aModel[4]
		Endif
		
		DbSelectArea("CE6")
		If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
			Begin Transaction
				RecLock("CE6",.F.)
				CE6->CE6_TOTCRE	-=	nTotCred
				CE6->CE6_SALDO	-=	nSaldo
				CE6->CE6_TOTTRA	-=	nTotTran
				CE6->(FKCommit())
				MsUnLock()
			End Transaction					
		Endif
			
	Else //�Utiliza��o de Cr�dito
		
	    nTotUtil	:=	aModel[4]
		nSaldo		:=	aModel[4]	
				
		DbSelectArea("CE6")
		If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
			Begin Transaction
				RecLock("CE6",.F.)
				CE6->CE6_TOTUTI	-=	nTotUtil
				CE6->CE6_SALDO	+=	nSaldo
				CE6->(FKCommit())
				MsUnLock()
			End Transaction
		Endif
	Endif
	
	("CE6")->(DbCloseArea())
	
Return

/*/{Protheus.doc} IncSaldo
Atualiza tabela de Saldo atrav�s de uma inclus�o

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, cont�m as funcionalidades da rotina
@param nSaldoAnt, numerico, Vari�vel com o valor do �ltimo saldo v�lido calculado para o per�odo

@return nulo, n�o tem retorno.

@obs Fun��o respons�vel por atualizar os registros contidos na tabela de Saldo de Cr�ditos (CE6) atrav�s de uma altera��o no Controle (CE5)
/*/
Static Function IncSaldo(aModel,nSaldoAnt)

	Local nSaldo	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nTotTran	:=	0
	
	If aModel[1] == "R" //�Recebimento de Cr�dito
	
		nTotCred	:=	aModel[4]
		nSaldo		:=	aModel[4]
		
		// Verifica se o recebimento do cr�dito foi atrav�s de Transfer�ncia
		If aModel[6] == "1"
			nTotTran	:=	aModel[4]
			nTotCred	:=	0
		Endif
			
		DbSelectArea("CE6")
		If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
			Begin Transaction
				RecLock("CE6",.F.)
				CE6->CE6_TOTCRE	+=	nTotCred
				CE6->CE6_SALDO	+=	nSaldo
				CE6->CE6_TOTTRA	+=	nTotTran
				CE6->(FKCommit())
				MsUnlock()
			End Transaction
		Else
			Begin Transaction
				RecLock("CE6",.T.)
				CE6->CE6_FILIAL	:=	xFilial("CE5")
				CE6->CE6_PERIOD	:=	aModel[3]
				CE6->CE6_CODLAN	:=	aModel[2]
				CE6->CE6_TOTCRE	:=	nTotCred
				CE6->CE6_TOTUTI	:=	nTotUtil
				CE6->CE6_SALDO	:=	nSaldoAnt + nSaldo
				CE6->CE6_TOTTRA	:=	nTotTran
				CE6->(FKCommit())
				MsUnlock()
			End Transaction
		Endif
		
	Else //�Utiliza��o de Cr�dito
	
		nTotUtil	:=	aModel[4]
		nSaldo		:=	aModel[4]	
					
		DbSelectArea("CE6")
		If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
			Begin Transaction
				RecLock("CE6",.F.)
				CE6->CE6_TOTUTI	+=	nTotUtil
				CE6->CE6_SALDO	-=	nSaldo
				CE6->(FKCommit())
				MsUnlock()
			End Transaction
		Else
			Begin Transaction
				RecLock("CE6",.T.)
				CE6->CE6_FILIAL	:=	xFilial("CE5")
				CE6->CE6_PERIOD	:=	aModel[3]
				CE6->CE6_CODLAN	:=	aModel[2]
				CE6->CE6_TOTCRE	:=	nTotCred
				CE6->CE6_TOTUTI	:=	nTotUtil
				CE6->CE6_SALDO	:=	nSaldoAnt - nSaldo
				CE6->(FKCommit())
				MsUnlock()
			End Transaction
		Endif
	Endif

Return

/*/{Protheus.doc} UFCodLan
Verifica a UF do C�digo de Lan�amento a ser gravado

@author Luccas Curcio
@since 22/08/2011

@param aLancApur, array, cont�m as informa��es do lan�amento na apura��o de icms.
@param dData, data, cont�m a data do processamento

@return nulo, n�o tem retorno.

@obs Fun��o respons�vel verificar a UF do C�digo de Lan�amento que foi inclu�do na Apura��o de ICMS. Tamb�m verifica se existe registro para o mesmo c�digo no per�odo. Se houver, n�o efetua a grava��o
/*/
Function UFCodLan(aLancApur,dData)

	Local lOk		:=	.F.
	
	Local cPeriodo	:=	Substr(DTOS(dData),1,6)
	
	DbSelectArea("CE5")
	DbSetOrder(3)
	
	If !dbSeek(xFilial("CE5")+aLancApur[7]+cPeriodo)
		If Substr(aLancApur[7],1,2) == "GO"
			lOk := VldCodLan(aLancApur)
		Endif
	Endif
	 
Return

/*/{Protheus.doc} VldCodLan
Valida e converte o C�digo de Lan�amento para grava��o no Controle de Cr�ditos Fiscais

@author Luccas Curcio
@since 22/08/2011

@param aLancApur, array, cont�m as informa��es do lan�amento na apura��o de icms.

@return logico, Informa se � v�lido ou n�o.

@obs Valida o c�digo trazido da Apura��o de ICMS, verifica se enquadra o Controle de Cr�dito e verifica se o c�digo corresponde a recebimento ou utiliza��o de cr�dito.
/*/
Static Function VldCodLan(aLancApur)

	Local aCampos	:=	{}
	
	Local lRet		:=	.T.		
	
	Local cCodLan	:=	Alltrim(aLancApur[7])
	Local cCodUtil	:=	""
	Local cCodCred	:=	""
	
	DbSelectArea("CDO")
	If DbSeek(xFilial("CDO")+aLancApur[7])
	
		// Verifica se o c�digo � usado para recebimento de cr�dito
		If CDO->CDO_UTILI == "2" // Outros Cr�ditos
			aAdd(aCampos,{"CE5_FILIAL"	,xFilial("CDH")		})
			aAdd(aCampos,{"CE5_CODIGO"	,GetSXENum("CE5")	})
			aAdd(aCampos,{"CE5_CODLAN"	,cCodLan			})
			aAdd(aCampos,{"CE5_VALOR"	,aLancApur[4]		})
			aAdd(aCampos,{"CE5_DATA"	,dDataBase			})
			aAdd(aCampos,{"CE5_TPMOV"	,"R"				})
			
			If !AutoCred("CE5",aCampos)
				lRet	:=	.F.
			Endif
		Else
			If !Empty(CDO->CDO_CODUTI) .And. !Empty(CDO->CDO_CODCRE)
		
				cCodUtil	:=	CDO->CDO_CODUTI
				cCodCred	:=	CDO->CDO_CODCRE
			
				aAdd(aCampos,{"CE5_FILIAL"	,xFilial("CDH")		})
				aAdd(aCampos,{"CE5_CODIGO"	,GetSXENum("CE5")	})
				aAdd(aCampos,{"CE5_CODLAN"	,cCodCred			})
				aAdd(aCampos,{"CE5_VALOR"	,aLancApur[4]		})
				aAdd(aCampos,{"CE5_DATA"	,dDataBase			})
				aAdd(aCampos,{"CE5_TPMOV"	,"U"				})
				aAdd(aCampos,{"CE5_CODCDH"	,cCodLan			})
				aAdd(aCampos,{"CE5_CODUTI"	,cCodUtil			})
				
				// Lan�amentos autom�ticos (10 posi��es) sempre s�o de transfer�ncia de cr�dito
				If Len(cCodLan) == 10
					aAdd(aCampos,{"CE5_TRANSF"	,"1"})
				Endif
			
				If !AutoCred("CE5",aCampos)
					lRet	:=	.F.
				Endif
			Endif
		Endif
	Endif	

Return lRet

/*/{Protheus.doc} AutoCred
Rotina Autom�tica de grava��o do modelo pr�-definido

@author Luccas Curcio
@since 22/08/2011

@param aCampos, array, cont�m os campos e informa��es que ser�o validados e posteriormente gravados
@param cAlias, caracter, Vari�vel que cont�m o Alias da tabela para grava��o do modelo de dados

@return logico, Informa se � v�lido ou n�o.

@obs Rotina autom�tica - Valida as informa��es trazidas da Apura��o para executar a rotina FISA034 e gravar os registros de recebimento e utiliza��o de cr�dito automaticamente
/*/
Static Function AutoCred(cAlias,aCampos)

	Local oModel, oAux, oStruCE5
	
	Local nI		:= 0
	Local nPos		:= 0
	
	Local lRet		:= .T.
	
	Local aAux		:= {}
	
	// Abre a tabela CE5
	DbSelectArea( cAlias )
	
	// Carrega e ativa o modelo original do programa FISA034
	oModel	:=	FWLoadModel("FISA034")
	oModel:SetOperation(3)
	oModel:Activate()
	
	oAux		:=	oModel:GetModel("CE5MODEL")
	oStruCE5	:=	oAux:GetStruct()
	
	// Atribui os campos da tabela CE5 ao array aAux para validar a exist�ncia dos campos do array aCampos
	aAux	:=	oStruCE5:GetFields()
	
	// Verifica se os campos do array aCampos existem na tabela
	For nI := 1 To Len(aCampos)
		If (nPos := aScan(aAux,{|x| Alltrim(x[3]) == Alltrim(aCampos[nI,1]) } ) ) > 0
			If !(lAux := oModel:SetValue("CE5MODEL", aCampos[nI,1], aCampos[nI,2] ) )
				lRet := .F.
				Exit
			Endif
		Endif
	Next
	
	/*
		Valida as informa��es trazidas da Apura��o. Se estiver tudo certo, processa 
		o Modelo original e executa a rotina de Controle de Cr�ditos
	*/  
	If lRet
		If (lRet := oModel:VldData() )
			oModel:CommitData()
		Endif
	Endif
	
	oModel:DeActivate()

Return lRet