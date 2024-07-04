#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "FwMvcDef.ch"
#Include "Fisa034.ch"

/*/{Protheus.doc} FISA034
Controle de Créditos Fiscais - SPED Fiscal

@author Luccas Curcio
@since 22/08/2011

@return nulo, não tem retorno.

@obs Programa responsável por controlar os registros de recebimento e utilização de créditos fiscais.
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
	oBrowseUp:SetDescription(STR0001)//"Controle de Créditos Fiscais"
	oBrowseUp:SetAlias("CE5")
	oBrowseUp:SetMenuDef("FISA034")
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()
	oBrowseUp:Activate()
	
	oBrowseDown	:=	FWMBrowse():New()
	oBrowseDown:SetOwner(oPanelDown)
	oBrowseDown:SetDescription(STR0007)//"Saldo de Créditos Fiscais"
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
Monta o menu com as opções da rotina

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

@return objeto, contém as funcionalidades da rotina
/*/
Static Function ModelDef()

	Local oStruCE5 	:=	FWFormStruct (1, "CE5")
	Local oModel
	Local cQryCE6	:=	"CE6"
	
	oModel	:=	MPFormModel():New('CE5MODEL', ,{ |oModel| ValidForm(oModel,@cQryCE6) }  ,{ |oModel| GravaForm(oModel,cQryCE6) } )
	
	oModel:AddFields('CE5MODEL',,oStruCE5)
	oModel:SetDescription(STR0001) //"Controle de Créditos Fiscais"
	oModel:GetModel('CE5MODEL'):SetDescription(STR0001) //"Controle de Créditos Fiscais"
	oModel:SetPrimaryKey( { "CE5_CODIGO" } )
	oModel:SetVldActivate({|oModel| fVldActiv(oModel) })
	                                                                         
	// Define que os campos podem ser editados apenas em uma operação de inclusão
	oStruCE5:SetProperty( 'CE5_CODIGO' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODLAN' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_DATA' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_TPMOV' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODUTI' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStruCE5:SetProperty( 'CE5_CODCDH' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
              
Return oModel                                        

/*/{Protheus.doc} fVldActiv
Função para validar o activate

@author Vitor Ribeiro
@since 28/12/2017

@param oModel, objeto, contem o modeldef

@return logico, se a activate continua ou não.
/*/
Static Function fVldActiv(oModel)
	
	Local lContinua := .T.
	
	Local nOperation := 0
	
	Default oModel := ModelDef()
	
	nOperation := oModel:GetOperation()
	
	// Se não for visualização e o campo CE5_TPLANC existir na base
	If nOperation <> MODEL_OPERATION_VIEW .And. CE5->(FieldPos("CE5_TPLANC")) > 0
		Help(,,"A034VLDACT",,CRLF + STR0009 + CRLF + CRLF + STR0010,1,0)	// "A manutenção das informações são realizadas através da apuração de icms na aba 'Extra Apuração'!"###"Verifique."
		lContinua := .F.
	EndIf
	
Return lContinua

/*/{Protheus.doc} ViewDef
Define a visualização de telas da rotina

@author Luccas Curcio
@since 22/08/2011

@return objeto, responsável pela exibição dos dados
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
Valida as informações contidas no formulário

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, contém as funcionalidades da rotina
@param cQryCE6, caracter, contém o conteúdo da query CE6

@return logico, se validou ou não.
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
	
	//Reseta variável que recebe a query da tabela CE6 para próximos processamentos
	cQryCE6	:=	"CE6"
	                                                           
	//Converte a data para formato período
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
	
	// Posiciono no saldo do último período calculado (o ORDER BY foi invertido, por isso utiliza-se DbGoTop())
	(cQryCE6)->(DbGoTop())
	
	// Verifica se já existe saldo em período posteior à operação que está sendo feita
	If (cQryCE6)->CE6_PERIOD > cPeriodo 
		Help(,,"A034POST",,STR0002,1,0)//"Já existe saldo para um período posterior utilizando este código de ajuste!"
		lRet	:= 	.F.
	Endif
	
	If nOperation == 3 //Inclusão 
		DbSelectArea ("CE5")
		CE5->(DbSetOrder (1))
		If CE5->(DbSeek(xFilial("CE5")+oModel:GetValue ('CE5MODEL','CE5_CODIGO')+oModel:GetValue ('CE5MODEL','CE5_CODLAN')+oModel:GetValue ('CE5MODEL','CE5_TPMOV' )))
			Help("",1,"Help","Help",STR0008,1,0) //"Controle de Créditos já cadastrado"
			lRet := .F.
		EndIf
		
		//Alteração para não permitir que seja gravado um registro do tipo = "Utilização do Credito" sem ter a tabela (CE6) cadastrada, para verificar se tem credito disponivel ou não.
		If (cQryCE6)->(Eof()) .And. aVldModel[1] == "U"
			Help(,,"A034REFC",,STR0003,1,0)//"Não existe crédito referente a este código de ajuste!" 
			lRet	:= 	.F.		 
		EndIF	
	EndIf
	
	If lRet
		While !(cQryCE6)->(Eof())
			/*
				Se não contiver erro no período atual, não é necessário varrer cQryCE6 inteiro. ³
				Os registros serão utilizados para verificação de saldo na função de gravação
			*/   
			If cPeriodo < (cQryCE6)->CE6_PERIOD
				Exit
			Endif
		
			If nOperation == 3 //Inclusão
	
			
				If aVldModel[1] == "U"
					// Verifica se existe crédito referente ao código para que possa utilizar
					If cPeriodo == (cQryCE6)->CE6_PERIOD
						If (cQryCE6)->CE6_SALDO <= 0
							Help(,,"A034REFC",,STR0003,1,0)//"Não existe crédito referente a este código de ajuste!" 
							lRet	:= 	.F.
							Exit 
						Elseif (cQryCE6)->CE6_SALDO - aVldModel[4] < 0 
							Help(,,"A034SUFC",,STR0005,1,0) //"Não existe crédito suficiente para esta operação!"
							lRet	:=	.F.
							Exit
						Endif
					Endif
				Endif
			
			Elseif nOperation == 5 //Exclusão
				If aVldModel[1] == "R" 
					// Verifica se já utilizou crédito com referência ao Código de Ajuste informado
					If (cQryCE6)->CE6_TOTUTI > 0 .And. (cQryCE6)->CE6_PERIOD >= cPeriodo
						Help(,,"A034NEXC",,STR0004,1,0)//"Já se utilizou de crédito referente a este código de ajuste! Não será excluído."
						lRet	:=	.F.
						Exit
					Endif
				Endif
			
			Elseif nOperation == 4 //Alteração
				nValorAlt	:= CE5->CE5_VALOR - aVldModel[4]
				If aVldModel[1] == "U" .And. nValorAlt < 0 .And. (cQryCE6)->CE6_SALDO + nValorAlt < 0
					lRet	:=	.F.
					Exit
				Elseif aVldModel[1] == "R" .And. nValorAlt > 0 .And. (cQryCE6)->CE6_SALDO - nValorAlt < 0
					lRet	:=	.F.
					Exit
				Endif
				If !lRet
					Help(,,"A034ANEG",,STR0006,1,0) //"Após essa alteração, o saldo do período ficará negativo! Não será alterado."
				Endif			
			Endif
			
			(cQryCE6)->(DbSkip())
		EndDo
	Endif
	
Return lRet 

/*/{Protheus.doc} GravaForm
Grava as informações contidas no formulário

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, contém as funcionalidades da rotina
@param cQryCE6, caracter, contém o conteúdo da query CE6

@return logico, se validou ou não.

@obs Funcao responsável por gravar o conteúdo do formulário. Os dados são obtidos através do objeto que contém as funcionalidades.
/*/
Static Function GravaForm(oModel,cQryCE6)

	Local lRet		:=	.T.
	Local nOperation:=	oModel:GetOperation()
	Local nSaldoAnt	:=	0
	Local aModel	:=	{}
	Local dData		:=	oModel:GetValue ('CE5MODEL','CE5_DATA'  )
	
	// Converte a data para formato período e atribui o conteúdo ao campo CE5_PERIOD
	If nOperation == 3
		oModel:SetValue('CE5MODEL','CE5_PERIOD',Substr(DTOS(dData),1,6))
	Endif
	
	aModel	:=	{oModel:GetValue ('CE5MODEL','CE5_TPMOV' ),;
				 oModel:GetValue ('CE5MODEL','CE5_CODLAN'),;
				 oModel:GetValue ('CE5MODEL','CE5_PERIOD'),;
				 oModel:GetValue ('CE5MODEL','CE5_VALOR' ),;
				 oModel:GetValue ('CE5MODEL','CE5_CODIGO'),;
				 oModel:GetValue ('CE5MODEL','CE5_TRANSF')}
	
	// Posiciono no saldo do último período calculado (o ORDER BY foi invertido, por isso utiliza-se DbGoTop())
	(cQryCE6)->(DbGoTop())
	
	// Atribui último valor de Saldo à variável nSaldoAnt
	If Alltrim((cQryCE6)->CE6_PERIOD) <> ''
		nSaldoAnt	:=	(cQryCE6)->CE6_SALDO
	Endif
	
	If nOperation == 3 //Inclusão                                   
		IncSaldo(aModel,nSaldoAnt)
	Elseif nOperation == 5 //Exclusão                         
		ExcSaldo(aModel)
	Elseif nOperation == 4 //Alteração
		AltSaldo(aModel)
	Endif
	
	// Efetua gravação/exclusão do registro CE5 e fecha o Alias da query CE6
	FWFormCommit( oModel )
	(cQryCE6)->(DbCloseArea())
                                     
Return lRet

/*/{Protheus.doc} AltSaldo
Atualiza tabela de Saldo através de uma alteração

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, contém as funcionalidades da rotina

@return nulo, não tem retorno.

@obs Função responsável por atualizar os registros contidos na tabela de Saldo de Créditos (CE6) através de uma alteração no Controle (CE5)
/*/
Static Function AltSaldo(aModel)

	Local nValorAlt	:=	0
	Local nTotTran	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nSaldo	:=	0
	
	If aModel[1] == "R" //³Recebimento de Crédito 
		
		If CE5->(DbSeek(xFilial("CE5")+aModel[5]+aModel[2]+aModel[1]))
			// nValorAlt recebe a diferença entre o valor antigo e o alterado
			nValorAlt	:=	CE5->CE5_VALOR - aModel[4]
			
			If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
				// Calcula a diferença do Saldo e Total de Crédito atual
				nTotCred	:=	CE6->CE6_TOTCRE - nValorAlt	
				nSaldo		:=	CE6->CE6_SALDO - nValorAlt
				
				// Se transferencia, calcula a diferença do valor de transferencia
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
	
	Else //³Utilização de Crédito
	
		If CE5->(DbSeek(xFilial("CE5")+aModel[5]+aModel[2]+aModel[1]))
			// nValorAlt recebe a diferença entre o valor antigo e o alterado
			nValorAlt	:=	CE5->CE5_VALOR - aModel[4]
			
			If CE6->(DbSeek(xFilial("CE6")+aModel[2]+aModel[3]))
				// Calcula a diferença do Saldo e Total Utilizado atual
				nTotUtil	:=	CE6->CE6_TOTUTI - nValorAlt
				nSaldo		:=	CE6->CE6_SALDO + nValorAlt
				
				// Se transferencia, calcula a diferença do valor de transferencia
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
Atualiza tabela de Saldo através de uma exclusão

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, contém as funcionalidades da rotina

@return nulo, não tem retorno.

@obs Função responsável por atualizar os registros contidos na tabela de Saldo de Créditos (CE6) através de uma alteração no Controle (CE5)
/*/
Static Function ExcSaldo(aModel)

	Local nSaldo	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nTotTran	:=	0
	
	If aModel[1] == "R" //³Recebimento de Crédito
	
		nTotCred	:=	aModel[4]
		nSaldo		:=	aModel[4]
		
		// Verifica se o recebimento do crédito foi através de Transferência
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
			
	Else //³Utilização de Crédito
		
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
Atualiza tabela de Saldo através de uma inclusão

@author Luccas Curcio
@since 22/08/2011

@param oModel, objeto, contém as funcionalidades da rotina
@param nSaldoAnt, numerico, Variável com o valor do último saldo válido calculado para o período

@return nulo, não tem retorno.

@obs Função responsável por atualizar os registros contidos na tabela de Saldo de Créditos (CE6) através de uma alteração no Controle (CE5)
/*/
Static Function IncSaldo(aModel,nSaldoAnt)

	Local nSaldo	:=	0
	Local nTotCred	:=	0
	Local nTotUtil	:=	0
	Local nTotTran	:=	0
	
	If aModel[1] == "R" //³Recebimento de Crédito
	
		nTotCred	:=	aModel[4]
		nSaldo		:=	aModel[4]
		
		// Verifica se o recebimento do crédito foi através de Transferência
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
		
	Else //³Utilização de Crédito
	
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
Verifica a UF do Código de Lançamento a ser gravado

@author Luccas Curcio
@since 22/08/2011

@param aLancApur, array, contém as informações do lançamento na apuração de icms.
@param dData, data, contém a data do processamento

@return nulo, não tem retorno.

@obs Função responsável verificar a UF do Código de Lançamento que foi incluído na Apuração de ICMS. Também verifica se existe registro para o mesmo código no período. Se houver, não efetua a gravação
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
Valida e converte o Código de Lançamento para gravação no Controle de Créditos Fiscais

@author Luccas Curcio
@since 22/08/2011

@param aLancApur, array, contém as informações do lançamento na apuração de icms.

@return logico, Informa se é válido ou não.

@obs Valida o código trazido da Apuração de ICMS, verifica se enquadra o Controle de Crédito e verifica se o código corresponde a recebimento ou utilização de crédito.
/*/
Static Function VldCodLan(aLancApur)

	Local aCampos	:=	{}
	
	Local lRet		:=	.T.		
	
	Local cCodLan	:=	Alltrim(aLancApur[7])
	Local cCodUtil	:=	""
	Local cCodCred	:=	""
	
	DbSelectArea("CDO")
	If DbSeek(xFilial("CDO")+aLancApur[7])
	
		// Verifica se o código é usado para recebimento de crédito
		If CDO->CDO_UTILI == "2" // Outros Créditos
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
				
				// Lançamentos automáticos (10 posições) sempre são de transferência de crédito
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
Rotina Automática de gravação do modelo pré-definido

@author Luccas Curcio
@since 22/08/2011

@param aCampos, array, contém os campos e informações que serão validados e posteriormente gravados
@param cAlias, caracter, Variável que contém o Alias da tabela para gravação do modelo de dados

@return logico, Informa se é válido ou não.

@obs Rotina automática - Valida as informações trazidas da Apuração para executar a rotina FISA034 e gravar os registros de recebimento e utilização de crédito automaticamente
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
	
	// Atribui os campos da tabela CE5 ao array aAux para validar a existência dos campos do array aCampos
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
		Valida as informações trazidas da Apuração. Se estiver tudo certo, processa 
		o Modelo original e executa a rotina de Controle de Créditos
	*/  
	If lRet
		If (lRet := oModel:VldData() )
			oModel:CommitData()
		Endif
	Endif
	
	oModel:DeActivate()

Return lRet