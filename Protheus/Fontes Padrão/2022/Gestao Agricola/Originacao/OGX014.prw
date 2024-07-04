#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "OGC010.CH"
#INCLUDE "FWCSS.CH"

#DEFINE  _CRLF 		CHR(13)+CHR(10)
#DEFINE BTNLBLATV		6026 // ID pertencente a label Atividades
#DEFINE BTNATIVID		6027 // ID pertencente ao botão de Criar Atividade
#DEFINE BTNESQAGD 	6030 // ID pertencente ao botão de mudar dias da agenda referente ao lado esquerdo
#DEFINE BTNDIRAGD 	6034 // ID pertencente ao botão de mudar dias da agenda referente ao lado direito

/*{Protheus.doc} OGX014A
(Rotina responsável pelo Angendamento do Take-Up, e
que será chamada via FwExecView a partir do botão Agendar Take-Up,
presente na rotina de Necessidades de Reserva (OGC010))
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
*/
Function OGX014A()	
Return

/*{Protheus.doc} ViewDef
(View que será montada ao seu chamada pela função FwExecView)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@return ${return}, ${oView}
*/
Static Function ViewDef()
	
	Local oView    	:= FWFormView():New()
	Local oModel		:= FwLoadModel("AGRA720") // Carrega o Model da rotina AGRA720
							
	oView:SetModel(oModel) // Seta o modelo
	
	oView:AddOtherObject("VIEW_AGENDA", {|oPanel, oObj| OGX014ATK(oPanel, oObj)}) // Adiciona a Widget de Calendário a view
			
	oView:CreateHorizontalBox( 'BOXAGENDA', 100 )//Remessa
			
	oView:SetOwnerView("VIEW_AGENDA", "BOXAGENDA")
	
	oView:SetCloseOnOk( {||.T.} )
	
Return (oView)

/*{Protheus.doc} OGX014ATK
(Função de criação da tela de agendamento do Take-Up)
@type function
@author roney.maia
@since 28/03/2017
@version 1.0
*/
Function OGX014ATK(oPanelWnd, oObj)

	Local oFwLayer		:= Nil
	Local nIt				:= 0
	Local aControls		:= {}
	
	_nOperation 	:= oObj:oControl:GetOperation() // Obtem o Operação atribuida a view que poderá ser INSERT ou UPDATE
	  	  	   	       	  	  				
	oFwLayer := FwLayer():New() // Cria uma Layer para divisão da dialog
	oFwLayer:Init(oPanelWnd, .F., .T.) // Inicia a criação do Layer

	oFwLayer:AddCollumn('COL01', 100, .F.)
   	  	
   	oFwLayer:AddWindow('COL01', 'C1_Win01', STR0061, 100, .F., .F.) // # "Agenda de Take-Up"
   	
   	// ### Não alterar o escopo da variavel _oCalend pois a mesma está sendo declarada na rotina OGC010							
	_oCalend := FWCalendarWidget():New( oFWLayer:GetWinPanel('COL01', 'C1_Win01')) // Instancia a widget de calendario passando o panel que sera inserida
	_oCalend:SetbNewActivity( { | dData, cHoraIni, cHoraFin | OGX014ACT( dData, cHoraIni, cHoraFin ) } ) // Bloco de codigo invocado ao clicar no botao de criar atividade ou clique duplo no horario especifico
	_oCalend:SetbRefresh( { | dData | OGX014SBR( dData ) } ) // Bloco de codigo invocado no refresh da widget
	_oCalend:SetbClickActivity( { | oItem | OGX014CLK(oItem) } )
	_oCalend:SetbRightClick( { | oItem | { {"",""} , {"",""} } } ) // Bloco de codigo invoda no clique direito do mouse       
	_oCalend:Activate() // Ativa o calendário
	
	aControls := _oCalend:oOwner:oWnd:aControls // Array de objetos e propriedades presentes no calendário
	
	For nIt := 1 To Len(aControls) // Loop	para localizar os botões de criar atividade e mudar dias de agendamento esquerdo e direito
		If ValType(aControls[nIt]) == "O" .AND. GetClassName(aControls[nIt]) == "TSAY" .AND. aControls[nIt]:hWnd == BTNLBLATV // Se for a label de Atividades
			aControls[nIt]:cTitle := STR0081 // # Agendamentos
			aControls[nIt]:cCaption := STR0081 // # Agendamentos
		EndIf
		If ValType(aControls[nIt]) == "O" .AND. GetClassName(aControls[nIt]) == "TBUTTON" // Se for um Objeto e a classe for TBUTTON
			If aControls[nIt]:hWnd == BTNATIVID // Se o ID do botão for igual ao do botão de atividade, altera a label do botão
				aControls[nIt]:cTitle := STR0082 // # Criar Agenda
				aControls[nIt]:cCaption := STR0082 // # Criar Agenda
			ElseIf aControls[nIt]:hWnd == BTNESQAGD // Se o ID do botão for igual ao botão esquerdo de mudança de dias, adiciona a chamada do refresh ao bloco de código
				aControls[nIt]:bAction := {|oBtn| oBtn:oParent:ChangeDate(1), _oCalend:oCalendar:Refresh()}
			ElseIf aControls[nIt]:hWnd == BTNDIRAGD // Se o ID do botão for igual ao botão direito de mudança de dias, adiciona a chamada do refresh ao bloco de código
				aControls[nIt]:bAction := {|oBtn| oBtn:oParent:ChangeDate(2), _oCalend:oCalendar:Refresh()}
			EndIF
		EndIf
	Next nIt
			 		 						
Return

/*{Protheus.doc} OGX014ATK
(Função referente ao evento de inicio de uma atividade ou agendamento)
@type function
@author roney.maia
@since 28/03/2017
@version 1.0
@param dData, data, (Data no qual foi iniciado a atividade)
@param cHoraIni, character, (Hora inicial no qual foi iniciado a atividade)
@param cHoraFin, character, (Hora final no qual foi iniciado a atividade)
*/
Static Function OGX014ACT(dData, cHoraIni, cHoraFin)	
	Local nRet				:= 0 // Variavel de retorno para a função FwExecView
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0059},{.T.,STR0058},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # Confirmar Agendamento # Fechar
	Local aItensBkp     	:= {}
	Private _dData 		:= dData // Data que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	Private _cHoraIni		:= cHoraIni // Hora que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	Private _aItensAgd	:= _aItens // Itens Agendados que serão enviados a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	Private _lClickAc		:= .F. // Variável de controle se foi ação de click em uma reserva ja existente ou não que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	
	dbSelectArea("DXP")
	DXP->(dbSetOrder(1))
	DXP->(dbSeek(FwXFilial("DXP") + _cCodRes))
			
	nOper    := MODEL_OPERATION_UPDATE
	aItensBkp := OGX014QRY(dData ) // Executa a query para buscar as reservas com agendamentos
	nRet = FWExecView(STR0025, 'OGX015', _nOperation, , {|| .T.}, {|oView| OGX015GRA(oView, "bOk")}, 20 / 100, aButtons) // # "Agendamento de Take-Up"
	aItens	  := OGX014QRY(dData ) // Executa a query para buscar as reservas com agendamentos
	OGX014HIST(aItens, aItensBkp, _nOperation)
	
	DXP->(dBCloseArea())
	If nRet == 0 // Se igual a 0 então o agendamento foi confirmado, ou atualizado ou cancelado.
		_nOperation := MODEL_OPERATION_UPDATE // Atribui a operação de UPDATE após alguma alteração no agendamento já existente
		_lIns := .T. // Atribui verdadeiro pois foi realizado uma inserção
	EndIf
												 		
	_oCalend:Refresh() // Atualiza o calendário
					 					
Return


/*{Protheus.doc} OGX014CLK
(Função chamada na edição de uma reserva já existente 
ao clicar duas vezes sobre a mesma)
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
@param oItem, objeto, (FWCalendarActivity contendo o Item que recebeu os cliques)
*/
Static Function OGX014CLK(oItem)
	Local nRet				:= .T. 
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0070},{.T.,STR0058},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # Confirmar Agendamento # Fechar # "Atualizar Agendamento"
	Private _dData 		:= oItem:DDTFIN // Data do item que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	Private _cHoraIni		:= oItem:CHRINI // Hora do item que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)
	Private _aItensAgd	:= _aItens
	Private _cCodRes		:= _cCodRes
	Private _lClickAc		:= .T. // Variável de controle se foi ação de click em uma reserva ja existente ou não que será enviada a rotina OGX015 (Tela de confirmação, atualização e cancelamendo do Take-Up)

  	_aItensBkp := _aItens // Atribui os itens a variavel de itens privada da tela de Necessidade de Reserva
			
	dBSelectArea("DXP")
	DXP->(dbSetOrder(1))
	DXP->(dbSeek(FwXFilial("DXP") + oItem:CID)) // Procura e posiciona no ID do item (Código da Reserva preciamento adicionado aos itens)
			
	nRet = FWExecView(STR0025, 'OGX015', MODEL_OPERATION_UPDATE, , {|| .T.}, {|oView| OGX015GRA(oView, "bOk")}, 20 / 100, aButtons) // # "Agendamento de Take-Up"

	DXP->(dBCloseArea())

	_oCalend:Refresh() // Atualiza o calendário
   //Grava Histórico do Agendamento
    OGX014HIST(_aItens, _aItensBkp, _nOperation )
    
Return

/*{Protheus.doc} OGX014SBR
(Função reponsável pela atualização de informação 
da widget, a qual apresenta as atividades na mesma)
@type function
@author roney.maia
@since 28/03/2017
@version 1.0
@param dData, array, (Data posicionada)
@return ${return}, ${Array contendo as atividades que serao apresentadas}
*/
Static Function OGX014SBR(dData)
   	Local oItem   	:= Nil // Instancia um objeto da classe de atividades para o calendario
   	Local aPrior  	:= {FWCALENDAR_PRIORITY_HIGH, FWCALENDAR_PRIORITY_MEDIUM, FWCALENDAR_PRIORITY_LOW} // Prioridade das reservas, diferenciado por cores
  	Local aButtonsDt	:= _oCalend:oCalendar:oCalendBar:aButtons // Obtém o Array de Botões da Barra do Calendario
  	Local aAgendas 	:= OGX014QRY(,,aButtonsDt) // Obtém todos os agendamentos
  	Local aActs	  	:= OGX014QRY(dData) // Executa a query para buscar as reservas com agendamentos
  	Local aItens		:= {} // Array de itens da reserva que será retornado ao calendario para o mesmo adicionar em tela
  	Local nIt			:= 0
  	Local nItA			:= 0
  	Local cNomeCli	:= ""
  	Local cNomeCla	:= ""
  	Local nPoolSize 	:= Len(_aPoolDt)
  	
  	// Não alterar o escopo da variavel _aPoolDt pois a mesma está sendo declarada na rotina OGC010
  	While (nIt := aScan(_aPoolDt, {|x| ValType(x) == "U"})) > 0
  		aDel(_aPoolDt, nIt)
  		aSize(_aPoolDt, nPoolSize := nPoolSize - 1)
  	EndDo
  	  	
  	For nIt := 1 To Len(aButtonsDt) // Loop que adiciona a quantidade de agendamentos para cada data correspondente
  			If "(" $ aButtonsDt[nIt]:cTitle // Se cotém o caracter (, então atribui ao titulo da data somente a data
		  		aButtonsDt[nIt]:cTitle := SubStr(aButtonsDt[nIt]:cTitle, 1, At("(", aButtonsDt[nIt]:cTitle) - 1)
		  	EndIf
  			For nItA := 1 To Len(aAgendas) // Percorre os agendamentos retornado pela query com a data e quantidade de agendamento
		  		If 	aButtonsDt[nIt]:dDate == sTod(aAgendas[nItA][1]) // Se a data do botão for igual a data do array consultado
		  			If aAgendas[nItA][2] < 10 // Array sempre virá com 1 ou mais
		  				aButtonsDt[nIt]:cTitle += "(" + cValToChar(aAgendas[nItA][2]) + ")" // Adiciona a quantidade ao titulo. Como a comparação do sempre irá trazer um valor positivo e se for menor que 9 então adiciona a label
		  			Else
		  				aButtonsDt[nIt]:cTitle += "(*)" // Caso a quantidade for igual a 10 ou maior, adiciona o *
		  			EndIf
		  		EndIf
		  		If ValType(dData) != "U" .AND. aButtonsDt[nIt]:dDate != dData .AND. "(" $ aButtonsDt[nIt]:cTitle// Se a data for diferente da data selecionada, aplica o css destacando as datas com agendamento
		  			aButtonsDt[nIt]:SetCss(FwGetCss(aButtonsDt[nIt], CSS_CONPAD1_BUTTONS)) // Aplica o Css para destacar o dia
		  			If aScan(_aPoolDt, { |x| x:hWnd == aButtonsDt[nIt]:hWnd}) == 0 // Adiciona os botões que foram adicionados o css anteriormente para manter caso seja alterado o css
		  				aAdd(_aPoolDt, aButtonsDt[nIt])
		  			EndIf
		  		EndIf
		  	Next nItA	  	
  	Next nIt
  	
  	For nIt := 1 To Len(_aPoolDt) // Reaplica o css dos botões caso houver uma reconstrução da barra de dias 		
  		If ValType(_aPoolDt[nIt]) != "U"		
	  		If ValType(dData) != "U" .AND. .NOT.("(" $ _aPoolDt[nIt]:cTitle)
			  	_aPoolDt[nIt]:cTitle += "(0)"		  	
				If _aPoolDt[nIt]:dDate != dData
					_aPoolDt[nIt]:SetCss(FwGetCss(aButtonsDt[nIt], CSS_CONPAD1_BUTTONS))
				EndIf
			EndIf
		EndIf		 		
  	Next nIt
  	 	
  	_aItens    := aActs // Atribui os itens a variavel de itens privada da tela de Necessidade de Reserva
  	
  	For nIt := 1 To Len(aActs) // Percorre os itens de agendamento para adição ao array de itens
  		cNomeCli := Alltrim(Posicione("SA1", 1, FwXFilial("SA1") + aActs[nIt][7] + aActs[nIt][8], "A1_NOME"))
  		cNomeCla := Alltrim(Posicione("NNA", 1, FwXFilial("NNA") + aActs[nIt][5] , "NNA_NOME"))
  	 		
  		oItem   := FWCalendarActivity():New() // Instancia uma novo item
  						  
		oItem:SetID(aActs[nIt][1]) // Id para indentificação da atividade
		If aActs[nIt][1] == Iif( _lIns, _cCodRes, (_cAliasBrw)->DXP_CODIGO) // Se o item for igual a mesma reserva posicionada no browse então define a cor de prioridade alta
			oItem:SetTitle(">>> " + STR0062 + ": " + aActs[nIt][1] + " / " + STR0063 + ": " + aActs[nIt][4] + " / " + STR0071 + cNomeCli + " / " + STR0072 + cNomeCla ) // Seta um titulo para atividade # "Reserva Agendada" # Contrato
			oItem:SetPriority(aPrior[1])
		Else
			oItem:SetTitle(STR0062 + ": " + aActs[nIt][1] + " / " + STR0063 + ": " + aActs[nIt][4] + " / " + STR0071 + cNomeCli + " / " + STR0072 + cNomeCla ) // Seta um titulo para atividade # "Reserva Agendada" # Contrato
			oItem:SetPriority(aPrior[3])
		EndIf
		oItem:SetNotes(STR0034) // Seta uma anotação #"Período de Take-up agendado."
		oItem:SetDtIni(STOD(aActs[nIt][2])) // Define a data inicial da atividade
		oItem:SetDtFin(STOD(aActs[nIt][2])) // Define a data final da atividade
		oItem:SetHrIni(AllTrim(aActs[nIt][3])) // Define a hora inicial da atividade
		oItem:SetHrFin(AllTrim(aActs[nIt][3])) // Define a hora final da atividade
						
		AADD(aItens,oItem) // Adiciona a atividade ao array de atividades
		
	Next nIt
				 		 	 	 	
Return aItens

/*{Protheus.doc} OGX014QRY
(Query que irá buscar os agendamentos realizados do Take-Up por data ou codigo da reserva)
@type function
@author roney.maia
@since 26/05/2017
@alterado Marcelo Ferrari
@since alt 19/06/2017
@version 1.0
@param dData, array, (Descrição do parâmetro)
@return ${return}, ${Array contendo os itens do agendamento}
*/
Function OGX014QRY(dData, cReserva, aButtonsDt)

	Local aActs		:= {}
	Local cQuery		:= ""
	Local cTemp		:= GetNextAlias()
	Local lDataNnill	:= Iif(ValType(dData) == "D", .T., .F.) // Validação de data para caso não for enviado uma data, obter todos os agendamentos
	Default cReserva 	:=  Nil
	
	If IsInCallStack("OGC020") // Verificação e atribuição realizada pelo fato da rotina OGC020 passar uma data Nula, para carregar as datas para histórico.
		lDataNnill := .T.
	EndIf
	
	//Query para montar o filtro para consulta.
	If lDataNnill // Validação de data para caso não for enviado uma data, obter todos os agendamentos
   		cQuery := " SELECT DXP_CODIGO, DXP_DATAGD, DXP_HORAGD, DXP_CODCTP, DXP_CLAEXT, DXP_CLAINT, DXP_CLIENT, DXP_LJCLI"
   	Else
   		cQuery := " SELECT DXP_DATAGD, COUNT(DXP_DATAGD) AS QUANTDATAS"
   	EndIf
   	cQuery += " FROM "+ RetSqlName('DXP')+" DXP"
   	cQuery += " WHERE DXP.DXP_FILIAL = '"+FwXFilial("DXP")+"'"
   	cQuery += " AND DXP.D_E_L_E_T_ != '*'"
   	If !Empty(cReserva)
   	    cQuery += " AND DXP.DXP_CODIGO = '" + cReserva + "'"
   	Else
   	   cQuery += " AND DXP.DXP_STATUS = '1'"
   	   If lDataNnill
   	   		cQuery += " AND DXP.DXP_DATAGD = '" + DTOS(dData) + "'"
   	   	Else
   	   		If ValType(aButtonsDt) == "A" // Se o array de botões foi passado, adiciona a query o range de datas que serão consultadas
   	   			cQuery += " AND DXP.DXP_DATAGD >= '" + DTOS(aButtonsDt[1]:dDate) + "' AND DXP.DXP_DATAGD <= '" + DTOS(aButtonsDt[Len(aButtonsDt)]:dDate) + "'"
   	   		EndIf
   	   	EndIf
   	EndIf
   	
   	cQuery += " AND DXP.DXP_HORAGD != ''"
   	
   	If !lDataNnill
   		cQuery += "GROUP BY DXP.DXP_DATAGD"
   	EndIf
 
 	cQuery := ChangeQuery( cQuery )
 		
	If Select(cTemp) != 0
		(cTemp)->(dbCloseArea())	
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)   
	//*Alimenta o array para tratar o filtro.
	If lDataNnill // Se a data é não é nula, a query montada recebera os ponteiros correspondentes
		While .Not. (cTemp)->(Eof())
			aAdd( aActs, {(cTemp)->DXP_CODIGO, (cTemp)->DXP_DATAGD, (cTemp)->DXP_HORAGD, (cTemp)->DXP_CODCTP, ;
			              (cTemp)->DXP_CLAEXT, (cTemp)->DXP_CLAINT, (cTemp)->DXP_CLIENT, (cTemp)->DXP_LJCLI  } )	
			(cTemp)->( dbSkip() )
		EndDo
	Else
		While .Not. (cTemp)->(Eof())
			aAdd( aActs, {(cTemp)->DXP_DATAGD,  (cTemp)->QUANTDATAS  } )	
			(cTemp)->( dbSkip() )
		EndDo
	EndIf
    (cTemp)->(dbCloseArea())
    
Return aActs

/*{Protheus.doc} OGX014HIST
(Grava o histórico de alterações da agenda/reserva na tabela NK9)
@type function
@author Marcelo Ferrari
@since 19/06/2017
@version 1.0
@param aItens, array, (Descrição do parâmetro)
       aItensBkp, array, (Descrição do parâmetro)
       nOper, Integer, (Descrição do parâmetro)
@return ${return}, ${.T.}
*/
Function OGX014HIST(aItens, aItensBkp, nOper )
	Local nI            := 0
	Local nJ            := 0
	lOCAL lExiste       := .F.
	Local cMsg          := ""
	Local aHist         := {}

  	//Gera o histórico do Agendamento
	//TO-DO: Quando um item for gravado em outra data, deve Gravar no histórico também.
    For nI := 1 to Len(aItensBkp)
       aItem := {}
       lExiste := .F.
       lGrava := .F.
       For nJ := 1 to Len(aItens)
          If (aItensBkp[nI, 1] == aItens[nJ, 1] )
             aItem := aClone(aItens[nJ])
             lExiste := .T.
             Exit
          EndIf
       Next nJ

       lGrava :=  Empty(aItem)
       
       If (!Empty(aItem))
          lGrava :=  ( lExiste .AND.      ;
                       ((aItensBkp[nI, 2] != aItem[2]) .OR. ;
                        (aItensBkp[nI, 3] != aItem[3]) .OR. ;
                        (aItensBkp[nI, 4] != aItem[4]) .OR. ;
                        (aItensBkp[nI, 5] != aItem[5]) .OR. ;
                        (aItensBkp[nI, 6] != aItem[6]) ) )
       EndIF
       
       If lGrava
          aAdd(aHist, "DXP" )  //Tabela

          aAdd(aHist, (FwxFilial('DXP') + aItensBkp[nI, 1] ) )  // Chave do histórico
          aAdd(aHist, AllTrim(Str(nOper))  )  //Tipo = Alteracao

          cMsg := STR0073 + _CRLF
          cMsg += STR0074 + aItensBkp[nI, 1] + _CRLF
          cMsg += STR0075 + aItensBkp[nI, 2] + _CRLF
          cMsg += STR0076 + aItensBkp[nI, 3] + _CRLF
          cMsg += STR0077 + aItensBkp[nI, 4] + _CRLF
          cMsg += STR0078 + aItensBkp[nI, 5] + _CRLF
          cMsg += STR0079 + aItensBkp[nI, 6] + _CRLF
          aAdd(aHist, cMsg)
 
          AGRGRAVAHIS(STR0080, , , , aHist) //Histórico da Política de Programação de Entrega
       EndIF
    Next nI
  
Return .T.

