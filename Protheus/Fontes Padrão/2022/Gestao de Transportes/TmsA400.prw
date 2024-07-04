#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA400.CH"

Static lTM400TOK    := ExistBlock('TM400TOK')
Static oDlgMot
Static lRestricao 	:= .F. // Verifica se possui a funcionalidade de Restricoes
Static lTM400FIL	:= ExistBlock('TM400FIL')	// Ponto de Entrada para filtrar o browse
/*/-----------------------------------------------------------
{Protheus.doc} TMSA400()
Liberação de Viagem

Uso: SIGATMS

@sample
//TMSA400()

@author Paulo Henrique Corrêa Cardoso.
@since 16/06/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA400()
Local oBrowse     	:= Nil						// Recebe o  Browse
Local cFilMbrow   	:= ""						// Recebe o Filtro da Browse
Local cFilMbrPE		:= ""						// Filtro do Ponto de Entrada

Private  aRotina   	:= {}						// Recebe as rotinas do menu.

//-- Troca TMSA400 Por TMSA029 Quando Nova Rotina De Liberação Estiver Em Uso.
If FindFunction("Tmsa029Use") .And. Tmsa029Use("TMSA140")

	Tmsa029()

Else

	aRotina     := MenuDef()		// Recebe as rotinas do menu.

	If Pergunte( "TMA400", .T. )
		If mv_par01 == 1 // 1-Sim
		//-- Filtro para as viagens bloqueadas
			cFilMbrow := " DUC_FILIAL == '" + xFilial("DUC") + "' .And. DUC_STATUS == '1' "
			DUC->( DbSetOrder( 2 ) )
		Else
			DUC->( DbSetOrder( 1 ) )
		EndIf
	EndIf

	// Ponto de Entrada para filtrar o browse.
	If lTM400FIL
		cFilMbrPE := ExecBlock("TM400FIL", .F., .F.)
		If Valtype(cFilMbrPE) = "C" .AND. !Empty(cFilMbrPE)
			If mv_par01 == 1 // 1-Sim
				cFilMbrow += " .AND. "
			EndIf
			cFilMbrow += " " + cFilMbrPE
		EndIf
	EndIf

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DUC")			    // Alias da tabela utilizada
	oBrowse:SetMenuDef("TMSA400")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)		// "Liberacao de Viagem"

	oBrowse:SetFilterDefault( cFilMbrow )  //Filtro

	oBrowse:AddLegend( "DUC_STATUS=='1'", "RED"	  , STR0006 ) // 'Bloqueado'
	oBrowse:AddLegend( "DUC_STATUS=='2'", "GREEN" , STR0007 ) // 'Liberado'

	oBrowse:Activate()

EndIf

Return NIL


/*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

Uso: TMSA400

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 17/06/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {} // Recebe as rotinas do menu

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0004  ACTION "TMSA400Mnt(3)"   OPERATION 2 ACCESS 0 // "Liberar"
	ADD OPTION aRotina TITLE STR0015  ACTION "TMSA400Mnt(4)"   OPERATION 2 ACCESS 0 // "Lib. Gerencial"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA400" OPERATION 2 ACCESS 0 // "Visualizar"

	// Tratamento Para Divergencias De Produtos
	If FindFunction("TMSA029USE") //.And. Tmsa029Use("TMSA140")
		ADD OPTION aRotina TITLE STR0021  ACTION "TMSA400Mot"	   OPERATION 2 ACCESS 0	//'Informacoes Bloqueio (Informaciones Del Bloqueo)
	EndIf

If ExistBlock("TM400MNU")
	ExecBlock("TM400MNU",.F.,.F.)
EndIf

Return(aRotina)


/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA400

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 17/06/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
Local oModel	:= Nil		// Objeto do Model
Local oStrFDCU	:= Nil		// Recebe a Estrutura da tabela DUC - Field
Local oStrGDUC	:= Nil		// Recebe a Estrutura da tabela DUC - Grid
Local oStrGDIY	:= Nil 		// Recebe a Estrutura da tabela DIY - GRID
Local cTMSRLC    := SuperGetMV( "MV_TMSRLC",, "0") //Restricao de Localizacao e Cliente 0= Nao Utiliza;1=Utiliza


oStrFDCU := FWFormStruct( 1, "DUC")
oStrGDUC := FWFormStruct( 1, "DUC")
lRestricao := AliasIndic("DIR") .And. FindFunction('TMSA024') .And. cTMSRLC $ '1|2|3' //Restricao de Localizacao e Cliente 0= Nao Utiliza 

// Ignora as obrigatoriedades dos campos.
oStrFDCU:SetProperty( '*' , MODEL_FIELD_OBRIGAT,.F.)
oStrGDUC:SetProperty( '*' , MODEL_FIELD_OBRIGAT,.F.)

If lRestricao
	oStrGDIY := FWFormStruct( 1, "DIY")
	oStrGDIY:SetProperty( '*' , MODEL_FIELD_OBRIGAT,.F.)
EndIf

oModel := MPFormModel():New( "TMSA400",,,, /*bCancel*/ )

oModel:SetActivate({ |oModel| ActiveMdl( oModel ) })

oModel:AddFields( 'MdFieldDUC',, oStrFDCU,,,/*Carga*/ )

oModel:SetPrimaryKey({"DUC_FILIAL","DUC_FILORI","DUC_VIAGEM"})

oModel:AddGrid( 'MdGridDUC', 'MdFieldDUC', oStrGDUC,,, /*bPreVal*/, /*bPosVal*/,/*BLoad*/  )

oModel:SetRelation('MdGridDUC',{ {"DUC_FILIAL","FWxFilial('DUC')"},{"DUC_FILORI","DUC_FILORI"},{"DUC_VIAGEM","DUC_VIAGEM"} }, DUC->(IndexKey(1)) )

If lRestricao
	oModel:AddGrid( 'MdGridDIY', 'MdGridDUC', oStrGDIY,,, /*bPreVal*/, /*bPosVal*/,/*BLoad*/  )
	oModel:SetRelation('MdGridDIY',{ {"DIY_FILIAL","FWxFilial('DIY')"},{"DIY_FILORI","DUC_FILORI"},{"DIY_VIAGEM","DUC_VIAGEM"} }, DIY->(IndexKey(1)) )
	oModel:GetModel( 'MdGridDIY' ):SetOptional( .T. )
EndIf

oModel:GetModel( 'MdFieldDUC' ):SetDescription( STR0001 ) 	//"Liberacao de Viagem"

oModel:GetModel('MdGridDUC'):SetNoDeleteLine( .T. )
Return oModel

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA400

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 17/06/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()
Local oModel	 := Nil		// Objeto do Model
Local oStrFDUC	 := Nil		// Recebe a Estrutura da tabela DUC Field
Local oStrGDUC	 := Nil		// Recebe a Estrutura da tabela DUC Grid
Local oStrGDIY	 := Nil 	// Recebe a Estrutura da tabela DIY - GRID

Local oView					// Recebe o objeto da View
Local lTMA400But := .F.     // Permite ao usuario, incluir botoes na enchoicebar.
Local cTMSRLC    := SuperGetMV( "MV_TMSRLC",, "0") //Restricao de Localizacao e Cliente 0= Nao Utiliza;1=Utiliza

lRestricao := AliasIndic("DIR") .And. FindFunction('TMSA024') .And. cTMSRLC $ '1|2|3' //Restricao de Localizacao e Cliente 0= Nao Utiliza 
lTMA400But := ExistBlock( 'TMA400BUT' )

oModel   := FwLoadModel("TMSA400")

oStrFDUC := FWFormStruct( 2, "DUC",{|cCampo| AllTrim(cCampo)+"|" $ "DUC_FILORI|DUC_VIAGEM|"})
oStrGDUC := FWFormStruct( 2, "DUC" )

If lRestricao
	oStrGDIY := FWFormStruct( 2, "DIY" )
EndIf

oStrGDUC:RemoveField("DUC_FILORI")
oStrGDUC:RemoveField("DUC_VIAGEM")

If IsInCallStack("TMSA400Mnt") // Liberacao
	oStrGDUC:RemoveField("DUC_DATLIB")
	oStrGDUC:RemoveField("DUC_HORLIB")
	oStrGDUC:RemoveField("DUC_USER")
EndIf

If lRestricao
	oStrGDIY:RemoveField("DIY_FILORI")
	oStrGDIY:RemoveField("DIY_VIAGEM")
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)

//Bloqueia todos os campos da tela
oStrFDUC:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oStrGDUC:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oStrGDUC:SetProperty( 'DUC_OBSLIB' , MVC_VIEW_CANCHANGE,.T.)

If lRestricao
	oStrGDIY:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
EndIf

// Adiciona os botoes do ponto de entrada
If lTMA400But
	If ValType( aUsButtons := ExecBlock( 'TMA400BUT', .F., .F. ) ) == 'A'
		AEval( aUsButtons, { |x| oView:AddUserButton(x[3],x[1],x[2]  ) } )
	EndIf
EndIf

// adiciona o botao de visualização da viagem
oView:AddUserButton(STR0010 , 'CARGA', {|| Tmsa400Viag() } )// "Viagem <F4>"

oView:AddField('VwFieldDUC', oStrFDUC , 'MdFieldDUC')
oView:AddGrid( 'VwGridDUC',  oStrGDUC , 'MdGridDUC')

If lRestricao
	oView:AddGrid( 'VwGridDIY',  oStrGDIY , 'MdGridDIY')
EndIf


oView:CreateHorizontalBox('CABECALHO', 20)
oView:CreateHorizontalBox('GRID', Iif(lRestricao , 40, 60) )

If lRestricao
	oView:CreateHorizontalBox('GRIDInf', 40)
	oView:EnableTitleView ('VwGridDIY' , STR0018 ) 	//-- 'Itens do Bloqueio por Restrição'
	oView:SetOwnerView('VwGridDIY','GRIDInf')
EndIf

oView:EnableTitleView ('VwGridDUC'	, STR0017 ) 	//-- 'Bloqueio da Viagem'

oView:SetOwnerView('VwFieldDUC','CABECALHO')
oView:SetOwnerView('VwGridDUC','GRID')

oView:SetCloseOnOk({|| .T. })

//Habilita o novo Grid

//Grid DUC
oView:SetViewProperty("VwGridDUC", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDUC", "GRIDFILTER", {.T.})
oView:SetViewProperty("VwGridDUC", "GRIDSEEK", {.T.})

If lRestricao
	//Grid DIY
	oView:SetViewProperty("VwGridDIY", "ENABLENEWGRID")
	oView:SetViewProperty("VwGridDIY", "GRIDFILTER", {.T.})
	oView:SetViewProperty("VwGridDIY", "GRIDSEEK", {.T.})
EndIf

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} TMSA400Mnt()
Liberacao de Viagens

Uso: TMSA400

@sample
//TMSA400Mnt(nOpcao)

@author Paulo Henrique Corrêa Cardoso.
@since 18/06/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA400Mnt(nOpcao)
Local cTMSRLC    := SuperGetMV( "MV_TMSRLC",, "0") //Restricao de Localizacao e Cliente 0= Nao Utiliza;1=Utiliza

Private aSetKey  := {} // Recebe as teclas de atalho

Default nOpcao := 2	 // Recebe a Opcao

If nOpcao == 3 .And. FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA140")

	Help(' ', 1, 'TMSA40003',,STR0024,5,11) // "Utilize a Rotina TMSA029 Para Desbloquear a Viagem."

Else

	Aadd(aSetKey, { VK_F4 , {|| Tmsa400Viag() } } )

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	// Executa a View para Liberacao
	FWExecView(STR0001,'TMSA400',MODEL_OPERATION_UPDATE,, { || .T. },{ || TMSA400Grv(nOpcao)  },,,{ || .T. })  // "Liberacao de Viagem"

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

EndIf

Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} TMSA400Grv()
Realiza a gravação da Liberação

Uso: TMSA400

@sample
//Function TMSA400Grv( nTmsOpcx, cFilOri, cViagem, lAuto, cObsLib  )

@author Paulo Henrique Corrêa Cardoso.
@since 18/06/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA400Grv( nTmsOpcx, cFilOri, cViagem, lAuto, cObsLib  )
Local lTM400Grv   := ExistBlock("TM400GRV") 					// Verifica o ponto de entrada de gravacao
Local lObsLib     := DUC->(FieldPos('DUC_CODOBS')) > 0			// Verifica se o campo de observacao existe
Local nCount      := 0											// Recebe o Contado
Local cQuery      := ''											// Recebe a Query
Local cAliasQry   := ''											// Recebe o alias da Query
Local lContinua   := .F.										// Verifica se continua o processamento
Local aRet        := {}											// Recebe o Retorno da autenticação do TMS
Local cCodUser    := ''											// Recebe o Codigo do usuario
Local lLiberado   := .F.										// Recebe se o usuario esta liberado
Local oModelItem  := NIL										// Recebe o Model de Itens
Local aSaveLine   := {}											// Recebe a posição das Linhas do Grid
Local oModel 	  := NIL										// Recebe o Model Ativo
Local cCampoObs	  := "DUC->DUC_CODOBS"							// Recebe o Campo de Observacao

Local   oCBox	  := NIL
Local   lCBox     := .F.
Local   oGetMot	  := NIL
Local   cGetMot   := ""
Local   oGrp	  := NIL
Local   oSay	  := NIL
Local   oSBut	  := NIL
Local   nAcao     := 0
Local lTmsa029   := FindFunction("TMSA029USE")
Local cUsuario   := RetCodUsr()
Local cNameUsr   := UsrFullName(cUsuario)

Default lAuto	:= .F.					//  Verifica se eh rotina automatica
Default cFilOri	:= M->DUC_FILORI		// 	Recebe a Filial de origem posicionada
Default cViagem	:= M->DUC_VIAGEM		//  Recebe a Viagem posicionada
Default cObsLib	:= STR0016				// 	Recebe a Observacao automatica

If	(nTmsOpcx == 3 .Or. nTmsOpcx == 4) .AND. TMSA400TOk( nTmsOpcx ) // Liberar
	//-- Atualiza as Observacoes referente a realizacao da Liberacao
	If lObsLib .And. !lAuto

		oModel 	   :=  FWModelActive()
		oModelItem := oModel:GetModel( 'MdGridDUC' )
		aSaveLine  := FWSaveRows()

		For nCount := 1 To oModelItem:Length()

			oModelItem:GoLine( nCount )

			DUC->(DbSetOrder(1)) //--DUC_FILIAL+DUC_FILORI+DUC_VIAGEM+DUC_CODBLQ+DUC_CODPRO+DUC_CODVEI+DUC_CODMOT
			If DUC->(dbSeek(	FWxFilial('DUC') + cFilOri + cViagem + oModelItem:GetValue("DUC_CODBLQ") +;
								oModelItem:GetValue("DUC_CODPRO")+  oModelItem:GetValue("DUC_CODVEI") + oModelItem:GetValue("DUC_CODMOT")))
				MSMM(&cCampoObs,,,oModelItem:GetValue("DUC_OBSLIB"),1,,,"DUC","DUC_CODOBS")
			EndIf
		Next nCount
		FWRestRows( aSaveLine )
   EndIf

	Begin Transaction

	dbSelectArea("DUC")
	DUC->( dbSetOrder(1))   // DUC_FILIAL+DUC_FILORI+DUC_VIAGEM+DUC_CODBLQ+DUC_CODPRO
	DUC->( MsSeek(FWxFilial( 'DUC' ) + cFilOri + cViagem) )

	Do While !DUC->(Eof()) .And. DUC->(DUC_FILIAL+DUC_FILORI+DUC_VIAGEM == FWxFilial('DUC')+cFilOri+cViagem)

		If nTmsOpcx == 3 .And. DUC->DUC_STATUS == StrZero(1,Len(DUC->DUC_STATUS))
			If DUC->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
				DUC->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ)) .Or.;
				DUC->DUC_CODBLQ == PadR('D4', Len(DUC->DUC_CODBLQ))

				cAliasQry := GetNextAlias()
				cQuery := "SELECT Count(DUC.DUC_STATUS) NUMLIB "
				cQuery += "FROM " + RetSQLName('DUC') + " DUC "
				cQuery += "WHERE DUC.DUC_FILIAL = '" + FWxFilial('DUC') + "' AND "
				cQuery += "(DUC.DUC_CODBLQ = 'D1' OR DUC.DUC_CODBLQ = 'D2' OR DUC.DUC_CODBLQ = 'D4') AND "
				cQuery += "DUC.DUC_CODFOR = '" + DUC->DUC_CODFOR + "' AND "
				cQuery += "DUC.DUC_LOJFOR = '" + DUC->DUC_LOJFOR + "' AND "
				cQuery += "DUC.DUC_STATUS = '2' AND "

				dbSelectArea("DD1")
				DD1->(dbSetOrder(1))
				If DD1->(MsSeek(FWxFilial('DD1') + DUC->(DUC_CODFOR+DUC_LOJFOR)))
					If DD1->DD1_CTRLIB == '1' //-- Controla as Liberacoes Diariamente
						cQuery += "DUC.DUC_DATLIB = '" + DtoS(dDataBase) + "' AND "

					ElseIf DD1->DD1_CTRLIB == '2' //-- Controla as Liberacoes Mensalmente
						cQuery += "DUC.DUC_DATLIB BETWEEN '" + Left(DtoS(dDataBase),6) + "01' AND '" + Left(DtoS(dDataBase),6) + "31' AND "

					EndIf
					cQuery += "DUC.D_E_L_E_T_ = ''
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

					If (cAliasQry)->(EoF())
						lContinua := .T.
					Else
						If (cAliasQry)->NUMLIB > DD1->DD1_NUMLIB .And. !lLiberado
							aRet := TmsSenha()
							If aRet[1]
								lContinua := TmsAcesso(aRet[2],'TMSA400',@cCodUser,4,.T.)
								lLiberado := .T.
							Else
								lContinua := .F.
							EndIf
						Else
							lContinua := .T.
						EndIf
					EndIf
					(cAliasQry)->(dbCloseArea())
				Else
					lContinua := .F.
				EndIf

			ElseIf DUC->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ))
				cAliasQry := GetNextAlias()
				cQuery := "SELECT Count(DUC.DUC_STATUS) NUMLIB "
				cQuery += "FROM " + RetSQLName('DUC') + " DUC "
				cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "
				cQuery += "DUC.DUC_CODBLQ = 'D3' AND "
				cQuery += "DUC.DUC_CODMOT = '" + DUC->DUC_CODMOT + "' AND "
				cQuery += "DUC.DUC_STATUS = '2' AND "

				DD2->(DbSetOrder(1))
				If DD2->(MsSeek(xFilial('DD1') + DUC->(DUC_CODFOR+DUC_LOJFOR)))
					If DD2->DD2_CTRLIB == '1' //-- Controla as Liberacoes Diariamente
						cQuery += "DUC.DUC_DATLIB = '" + DtoS(dDataBase) + "' AND "

					ElseIf DD2->DD2_CTRLIB == '2' //-- Controla as Liberacoes Mensalmente
						cQuery += "DUC.DUC_DATLIB BETWEEN '" + Left(DtoS(dDataBase),6) + "01' AND '" + Left(DtoS(dDataBase),6) + "31' AND "

					EndIf
					cQuery += "DUC.D_E_L_E_T_ = ''
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

					If (cAliasQry)->(EoF())
						lContinua := .T.
					Else
						If (cAliasQry)->NUMLIB > DD1->DD1_NUMLIB .And. !lLiberado
							aRet := TmsSenha()
							If aRet[1]
								lContinua := TmsAcesso(aRet[2],'TMSA400',@cCodUser,4,.T.)
								lLiberado := .T.
							Else
								lContinua := .F.
							EndIf
						EndIf
					EndIf
					(cAliasQry)->(dbCloseArea())
				Else
					lContinua := .F.
				EndIf
            Else
            	lContinua := .T.
            EndIf
        Else
        	lContinua := .T.
        EndIf

		If lContinua
			RecLock('DUC', .F.)
			DUC->DUC_STATUS := "2"  // Liberado
			DUC->DUC_DATLIB := dDataBase
			DUC->DUC_HORLIB := StrTran(Left(Time(),5), ":", "")
			DUC->DUC_USER   := cUsuario
			MsUnLock()

			If lAuto
				MSMM(&cCampoObs,,,cObsLib,1,,,"DUC","DUC_CODOBS")
			EndIf

			If lTM400Grv
				ExecBlock("TM400Grv",.F.,.F., {DUC->DUC_FILORI , DUC->DUC_VIAGEM, DUC->DUC_CODBLQ } )
			EndIf

			// Grava Tabela DDU (Logs De Bloqueios).
			If lTmsa029 .And. Tmsa029Use("TMSA140")

				If DUC->DUC_CODBLQ == "CR" // Classe Risco (Diverg. Produtos)

					If !lAuto

						// Captura Motivo Da Tela Anterior
						cGetMot := Posicione("DUC",1,xFilial("DUC") + DUC->DUC_FILORI + DUC->DUC_VIAGEM,"DUC_OBSLIB")

						// Se Motivo Nao Informado, Obriga Digitacao
						While Empty(cGetMot)

					  		cGetMot   := Space(TamSX3("DDU_MTVLIB")[1])

					  		// Dialog Para Digitacao Do Motivo Da Liberacao
					  		DEFINE MSDIALOG oDlgMot TITLE STR0022 FROM 000, 000  TO 150, 700 PIXEL // "Motivo Liberação"

					    	@ 009, 005 GROUP oGrp TO 046, 346		PROMPT STR0022								OF oDlgMot  PIXEL // "Motivo Liberação"
					   	 	@ 021, 010 MSGET oGetMot VAR cGetMot 						SIZE 330, 014 			OF oDlgMot  PIXEL When !(lCBox)

					    	DEFINE SBUTTON oSBut FROM 053, 308 TYPE 01 ACTION ( nAcao := 1 , oDlgMot:End() )	OF oDlgMot ENABLE

					  		ACTIVATE MSDIALOG oDlgMot CENTERED

					  		If nAcao == 1 .And. Empty(cGetMot)
								Help(' ', 1, 'TMSA40002',,STR0023,5,11) // "Obrigatório Informar o Motivo Do Desbloqueio!"
							EndIf
						EndDo
				  	Else
				  		cGetMot := cObsLib
				  	EndIf

					DbSelectArea("DDU")
					DbSetOrder(1) //-- DDU_FILIAL+DDU_CHAVE+DDU_INDEX+DDU_SEQ
					If MsSeek(xFilial("DDU") + DUC->DUC_FILORI + DUC->DUC_VIAGEM ,.F.)

						RecLock("DDU",.f.)
						Replace DDU->DDU_STATUS  With "2" // Liberado
						Replace DDU->DDU_USRLIB  With cUsuario
						Replace DDU->DDU_NOMLIB  With cNameUsr
						Replace DDU->DDU_DATLIB  With MsDate()
						Replace DDU->DDU_HORLIB  With Substr(Time(),1,5)
						Replace DDU->DDU_MTVLIB  With cGetMot
						DDU->(MsUnlock())

					EndIf
				EndIf
			EndIf
		EndIf

		DUC->(dbSkip())
	EndDo

	End Transaction
EndIf
Return .T.


/*/-----------------------------------------------------------
{Protheus.doc} ActiveMdl()
Ativa o modelo

Uso: TMSA400LB

@sample
//ActiveMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 18/06/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ActiveMdl( oModel )
Local nOperation := oModel:GetOperation()  //Recece a operação realizada

If nOperation == MODEL_OPERATION_UPDATE
	oModel:SetValue( 'MdFieldDUC', 'DUC_VIAGEM', FwFldGet("DUC_VIAGEM") )
EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSA400TOk()
Valida os dados

Uso: TMSA400

@sample
//TMSA400TOk( nTMSOpcx )

@author Paulo Henrique Corrêa Cardoso.
@since 18/06/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA400TOk( nTMSOpcx )
Local lRet := .T. 	// Recebe o Retorno

// Verifica se a viagem ja foi liberada
If (nTmsOpcx == 3 .Or. nTmsOpcx == 4) .And. M->DUC_STATUS == "2"
	Help(' ', 1, 'TMSA40001',,STR0009 + M->DUC_VIAGEM,5,11)	//-- Viagem ja liberada! Viagem No : ###
	lRet := .F.
EndIf

// Verifica as validacoes do ponto de entrada
If nTMSOpcx <> 2
	If lRet .And. lTM400TOK
		lRet := ExecBlock('TM400TOK',.F.,.F.,{nTMSOpcx, M->DUC_FILORI, M->DUC_VIAGEM})
		If	ValType(lRet) <> 'L'
			lRet := .F.
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa400Viag³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa400Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa400Viag()

If Type('aSetKey') == "U"
	Private aSetKey    := {} // Recebe as teclas de atalho
EndIf	
//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

// Exibe a viagem
TmsVisViag(M->DUC_FILORI,M->DUC_VIAGEM)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa400Rel ³ Autor ³ Vitor Raspa          ³ Data ³31.Ago.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Incializa os campos do DUC (X3_RELACAO)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA400Rel()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA400Rel()
Local aArea    := GetArea()
Local aAreaDTQ := DTQ->(GetArea())
Local nDiasAtr := 0

DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
DTQ->(MsSeek(xFilial('DTQ') + DUC->(DUC_FILORI + DUC_VIAGEM)))

If 	DUC->DUC_CODBLQ == PadR('D1', Len(DUC->DUC_CODBLQ)) .Or.;
	DUC->DUC_CODBLQ == PadR('D2', Len(DUC->DUC_CODBLQ))
	//-- Bloqueio referente ao Fornecedor vinculado ao proprietario do veiculo
	DD3->(DbSetOrder(2))
	DD3->(MsSeek(xFilial('DD3') + DUC->(DUC_CODFOR+DUC_LOJFOR+DUC_CODDOC)))

	nDiasAtr := DTQ->DTQ_DATGER - DD3->DD3_PRXAPR

ElseIf DUC->DUC_CODBLQ == PadR('D3', Len(DUC->DUC_CODBLQ))
	//-- Bloqueio referente ao Motorista
	DD4->(DbSetOrder(2))
	DD4->(MsSeek(xFilial('DD4') + DUC->(DUC_CODMOT+DUC_CODDOC)))

	nDiasAtr := DTQ->DTQ_DATGER - DD4->DD4_PRXAPR

EndIf

RestArea(aArea)
RestArea(aAreaDTQ)
Return(nDiasAtr)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA400Mot
Divergencias De Produtos - Dialog Para Exibicao Dos Motivos De Bloqueio Da Viagem.
@author Eduardo Alberti
@since 23/10/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TMSA400Mot()

Local aArea			:= GetArea()
Local aArSB1			:= SB1->(GetArea())
Local aVetDlg			:= {}
Local aVetIni			:= {}
Local cTitulo			:= OemToAnsi(STR0021) //"Inform. Bloqueio"
Local aCab				:= {}
Local oDlgTmp 		:= Nil
Local oListTmp  		:= Nil
Local aCoordenadas	:= MsAdvSize(.T.)
Local nI				:= 0
Local lOpcClick 		:= .F.
Local aButtons		:= {}
Local cDetalhe      := ""

// Verifica Se Tabela Existe No Dicionario
If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA140")

	// Posiciona Nos Bloqueios Da Viagem
	DbSelectArea("DDU")
	DbSetOrder(2) //-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE
	If MsSeek(xFilial("DDU") + "DUC" + PadR(xFilial("DUC") + DUC->DUC_FILORI + DUC->DUC_VIAGEM,TamSX3("DDU_CHAVE")[1]) + DUC->DUC_CODBLQ ,.F.)

		// Converte Cada Pipe Encontrado No Campo Tipo 'Memo' Em Uma Linha Do Vetor
		aVetIni := StrToKarr(DDU->DDU_DETALH,"|")

		// Converte <Enter) Em Nova Linha
		If Len(aVetIni) == 1
			aVetIni := StrToKarr(DDU->DDU_DETALH,Chr(13)+Chr(10))
		EndIf

		// Converte Cada Sustenido ("#") Em Uma Linha Do Vetor
		For nI := 1 To Len(aVetIni)

			aAdd(aVetDlg,StrToKarr(aVetIni[nI],"#"))

			// Ajusta Tamanho Vetor Qdo Necessario
			If Len(aVetDlg[Len(aVetDlg)]) < 5
				aAdd(aVetDlg[Len(aVetDlg)],"")
			EndIf

		Next nI

		If DDU->DDU_TIPBLQ == 'RR'
			cDetalhe:= STR0025
		ElseIf DDU->DDU_TIPBLQ == 'CR'
			cDetalhe:= STR0031
		EndIf

		If Len(aVetDlg[1]) < 5
			aCab := {STR0032}   //Motivo
		Else
			aCab := {STR0026,STR0027,STR0028,STR0029,STR0030,cDetalhe}  //"Seq.Agrup.","Num. CTR","Produto","Descrição","NF. Cliente","Incompatíveis"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botoes da barra superior              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDlgTmp 			:= TDialog():New(000,000,aCoordenadas[6],aCoordenadas[5],OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.)
		oListTmp 			:= TWBrowse():New(014,003,oDlgTmp:nClientWidth/2-5,oDlgTmp:nClientHeight/2-45,,aCab,,oDlgTmp,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		//oListTmp:lHScroll	:= .F.

		oListTmp:SetArray(aVetDlg)

		If Len(aVetDlg[1]) < 5
			oListTmp:bLine := {||{;
			aVetDlg[oListTmp:nAt][01]}}
		Else
			oListTmp:bLine := {||{;
			aVetDlg[oListTmp:nAt][01],;
			aVetDlg[oListTmp:nAt][02],;
			aVetDlg[oListTmp:nAt][03],;
			Alltrim(Posicione("SB1",1,xFilial("SB1") + aVetDlg[oListTmp:nAt][03],"B1_DESC")),;
			aVetDlg[oListTmp:nAt][04],;
			aVetDlg[oListTmp:nAt][05]}}
		EndIf

		Activate MsDialog oDlgTmp On Init EnchoiceBar(oDlgTmp,{|| lOpcClick := .T., oDlgTmp:End()},{|| oDlgTmp:End() },,aButtons)

	EndIf
EndIf

RestArea(aArSB1)
RestArea(aArea)

Return()   
