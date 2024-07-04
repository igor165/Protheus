#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA540.CH'

Static lTipMark 	:= .T.
Static lMkDifHr 	:= .F.
Static aRecnosMk 	:= {}
Static aMntAgenda	:= {}	//---	Array que informar� se a agenda (data/hora in�cio/hora fim) do atendente possui informa��es ou n�o. 

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA540
Rotina para sele��o de agenda do atendente para manuten��o.
� necess�rio que a tabela ABB esteja posicionada no agendamento do atendente.
@sample 	TECA540( dDataDe, dDataAte )
@param		dDataDe	Data inicial para montar a lista de agendamentos.
			dDataAte	Data final para montar a lista de agendamentos.
@author	Danilo Dias			
@since		28/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA540( dDataDe, dDataAte )

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local oDialog		:= Nil
Local oLayer		:= Nil
Local oBrwList	:= Nil
Local oPanel		:= Nil
Local oDataDe		:= Nil
Local oDataAte	:= Nil
Local oDlgManut	:= Nil
Local oBtnAtual	:= Nil
Local cAliasABB	:= GetNextAlias()
Local aSize		:= FWGetDialogSize( oMainWnd )
Local aQryABB		:= {}
Local cCodAtend	:= ''
Local cChaveABB	:= ''
Local cEntidade	:= ''
Local bAcaoAtual	:= bAcaoAtual := { || aQryABB := AT540ABBQry( cCodAtend, cChaveABB, dDataDe, dDataAte, cHoraDe, cHoraAte, , , cEntidade ), AT540Atual( oBrwList, aQryABB[1] ) }

Local oHoraDe 	:= Nil
Local oHoraAte 	:= Nil
Local cHoraDe 	:= "    "
Local cHoraAte 	:= "    "
Local aFiltros 	:= {}
Local nX 			:= 0
Private aRotina 	:= FWMVCMENU('TECA540')	// Monta menu da Browse
Private cCadastro	:= STR0001 	//'Manuten��o da Agenda'

Default dDataDe	:= ABB->ABB_DTINI
Default dDataAte	:= ABB->ABB_DTFIM

lMkDifHr 	:= .F.

cCodAtend 	:= ABB->ABB_CODTEC
cChaveABB	:= ABB->ABB_CHAVE
cEntidade 	:= ABB->ABB_ENTIDA
aQryABB 	:= AT540ABBQry( cCodAtend, cChaveABB, dDataDe, dDataAte, /*cHoraDe*/, /*cHoraAte*/,/* cCodAgenda*/,/* lSelected*/, cEntidade )								

//--------------------------------------------------------------
// Monta tela com lista de agendamentos do per�odo
//--------------------------------------------------------------
oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , , , , , oMainWnd, .T. )

	oLayer := FWLayer():New()
	oLayer:Init( oDialog, .F.)
	
	oLayer:AddLine( 'Linha', 100)
	oLayer:AddColumn( 'Coluna', 100, .T., 'Linha' )
	oLayer:AddWindow( 'Coluna', 'oDlgManut', cCadastro, 100, .F., .F., {||}, 'Linha' )
	oDlgManut := oLayer:GetWinPanel( 'Coluna', 'oDlgManut', 'Linha' )
	
	//----------------------------------------------------------
	// Objetos para permitir selecionar um per�odo de filtro
	//----------------------------------------------------------
	oPanelTop 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.10 )
	oPanelTop:Align := CONTROL_ALIGN_TOP
	
	oSay     	:= TSay():New( 12, 10, { || STR0002 }, oPanelTop,,,,,,.T.,,, 50, 10 )		//'Agendamentos De:'
	oDataDe  	:= TGet():New( 10, 60, { |u| If( PCount() > 0, dDataDe := u, dDataDe ) }, oPanelTop, 050, 010,,,,,,,,.T.,,,,,,,,,,"dDataDe" )

	oSay     	:= TSay():New( 12, 120, { || STR0003 }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Agendamentos At�:'	
	oDataAte	:= TGet():New( 10, 170, { |u| If( PCount() > 0, dDataAte := u, dDataAte ) }, oPanelTop, 050, 010,,,,,,,,.T.,,,,,,,,,,"dDataAte" )
	
	oSay     	:= TSay():New( 12, 230, { || "Hora Inicial:" }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Hora Inicial:'
	oHoraDe 	:= TGet():New( 10, 260, { |u| If( PCount() > 0, cHoraDe := Transform( u, "@R 99:99" ), cHoraDe ) }, oPanelTop, 015, 010,"@R 99:99",,,,,,,.T.,,,,,,,,,,"cHoraDe" )

	oSay     	:= TSay():New( 12, 300, { || "Hora Final:" }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Hora Final:'
	oHoraAte 	:= TGet():New( 10, 330, { |u| If( PCount() > 0, cHoraAte := Transform( u, "@R 99:99" ), cHoraAte ) }, oPanelTop, 015, 010,"@R 99:99",,,,,,,.T.,,,,,,,,,,"cHoraAte" )
	
	oBtnAtual	:= TButton():New( 10, 400, STR0004, oPanelTop, bAcaoAtual, 040,,,,,.T.,,,,,,, )	//'Atualizar' 
	
	//----------------------------------------------------------
	// Browse com agendas no per�odo solicitado (ABB)
	//----------------------------------------------------------
	oPanelBot 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.90 )	
	oPanelBot:Align := CONTROL_ALIGN_BOTTOM
	
	oBrwList := FWFormBrowse():New()
	oBrwList:SetOwner( oPanelBot )
	oBrwList:AddMarkColumns( { || IIf( (cAliasABB)->ABB_OK == 1, "LBOK", "LBNO" ) }, { || IIf( (cAliasABB)->ABB_OK == 0,(cAliasABB)->ABB_OK := 1, (cAliasABB)->ABB_OK := 0 ) } )
	oBrwList:SetDataQuery(.T.)
	oBrwList:SetQuery( aQryABB[1] )
	oBrwList:SetAlias( cAliasABB )
	oBrwList:AddStatusColumns( { || AT540Status( cAliasABB ) }, { || AT540Legen() } )
	oBrwList:SetColumns( aQryABB[2] )
	oBrwList:SetUseFilter( .T. )
	oBrwList:DisableConfig()
	oBrwList:DisableReport()
	oBrwList:DisableDetails()
	oBrwList:AddButton( STR0005, { || AT540Manut( oBrwList, cAliasABB, aQryABB[1] ) },,,, .F., 2 )		//'Manuten��o'
	oBrwList:AddButton( STR0006, { || AT540Detal( oBrwList, aQryABB[1], (cAliasABB)->ABB_CODIGO ) },,,, .F., 2 )	//'Detalhes'
	oBrwList:AddButton( STR0007, { || oDialog:End() },,,, .F., 2 )	//'Sair'
	oBrwList:aColumns[1]:bHeaderClick := {|| AT540MkAll( oBrwList ) }
	oBrwList:SetDoubleClick( {|| AT540MkOne( oBrwList ) } )
	oBrwList:Activate()	
	
oDialog:Activate( ,,,.T.,,, )

RestArea( aAreaABB )
RestArea( aArea )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540Manut
Fun��o para acionar a tela de manuten��o da agenda.

@sample 	AT540Manut( oBrowse, cAlias, cQuery )

@param		oBrowse 	Objeto FWFormBrowse com os dados da ABB que acionou a tela.
			cAlias		Alias da tabela tempor�ria com a lista de agendas.
			dDataDe	Data inicial de agendamentos.
			dDataAte	Data final de agendamentos.

@author	Danilo Dias			
@since		10/01/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540Manut( oBrowse, cAlias, cQuery )

Local aCarga		:= {}

If ( AT540VldChk( cAlias, @aCarga ) )	//Valida se h� itens marcados na lista
	
	//Valida o retorno da fun��o. 0-Usu�rio confirmou | 1-Cancelado pelo usu�rio
	If ( AT550ExecView( cAlias, MODEL_OPERATION_INSERT, aCarga ) == 0 )
		AT540Atual( oBrowse, cQuery )	//Atualiza browse
	EndIf
		
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540Detal
Fun��o para acionar a tela de Manuten��es da Agenda (TECA550), permitindo 
alterar ou excluir manuten��es realizadas.

@sample 	AT540Detal( oBrowse, cQuery, cAgenda )

@param		oBrowse 	Objeto FWFormBrowse com os dados da ABB que acionou a tela.
			cQuery		Query para gerar os dados da Browse.
			cAgenda	C�digo da agenda que deseja alterar as manuten��es.

@author	Danilo Dias			
@since		14/01/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540Detal( oBrowse, cQuery, cAgenda )

DbSelectArea('ABR')
ABR->(DbSetOrder(1))

If ( ABR->( DbSeek( xFilial('ABR') + cAgenda ) ) ) 
	TECA550( cAgenda, oBrowse:Alias() )
	AT540Atual( oBrowse, cQuery )
Else
	Help( " ", 1, "AT540Detal", , STR0008, 1, 0 )		//'Agendamento selecionado n�o possui manuten��o.'
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540Status
Fun��o para montar os status dos agendamentos.

@sample 	AT540Status( cAlias )
@param		cAlias		Alias com os dados do Browse.
@return	cStatus	Cor representando o status do agendamento.

@author	Danilo Dias			
@since		28/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540Status( cAlias )

Local cStatus := 'BR_VERDE'	//Agendamento n�o sofreu manuten��o, est� ativo e n�o foi atendido

If ( (cAlias)->ABB_ATIVO == '1' )
	
	If ( (cAlias)->ABB_MANUT == '1' )
		cStatus := 'BR_AMARELO'	//Agendamento alterado e ativo
	EndIf
	If ( (cAlias)->ABB_ATENDE == '1' .And. (cAlias)->ABB_CHEGOU = 'S' )
		cStatus := 'BR_AZUL'		//Atendimento encerrado
	EndIf
	
Else
	cStatus := 'BR_VERMELHO'	//Agendamento inativo
EndIf

Return cStatus


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540Legen
Fun��o para montar a legenda da Browse.

@sample 	AT540Legen()
	
@author	Danilo Dias		
@since		28/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540Legen()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add( '', 'BR_VERDE'	, STR0009 )	//'Agendamento Ativo'
oLegenda:Add( '', 'BR_AMARELO'	, STR0010 )	//'Agendamento Alterado'
oLegenda:Add( '', 'BR_VERMELHO'	, STR0011 )	//'Agendamento Inativo'
oLegenda:Add( '', 'BR_AZUL'		, STR0013 )	//'Agendamento Encerrado'

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540VldChk
Valida se h� itens marcados na lista.
Posiciona o alias no primeiro item marcado.

@sample 	AT540VldChk( oBrowse )

@param		oBrowse	Browse a ser verificada.
			
@return	aRet 	Indica se h� itens marcados.

@author	Danilo Dias
@since		19/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540VldChk( cAlias, aCarga )

Local aArea	 		:= GetArea()
Local aAreaTmp 	:= (cAlias)->(GetArea())
Local lRet			:= .F.
Local aHrSelec 	:= {}
Local nPosHr 		:= 0
Local nPriSelec	 	:= 0
Local aCalendAtd 	:= {}		//Array com dados do calend�rio para gera��o da agenda
Local aCalendInf 	:= {}		//Array com informa��es do calend�rio para gera��o da agenda
Local cTurno 		:= Space( TamSX3("ABQ_TURNO")[1] )		//Turno para grava��o da agenda
Local cTrnSeq 		:= "01"
Local dDtRef 		:= CTOD("")
Local nLimAgeSel	:= At540LimAg()
Local nAgeSel		:= 0

aRecnosMk := {}

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

While ( (cAlias)->(!Eof()) )

	//  Verifica se o atendente possui turno quebrado 
	// para questionar usu�rio sobre r�plica
	DbSelectArea('ABQ')
	ABQ->( DbSetOrder( 1 ) )
	dDtRef := CTOD("")
	If  ABQ->( DbSeek( xFilial('ABQ')+(cAlias)->ABB_IDCFAL))
	
		cTurno := ABQ->ABQ_TURNO
		cTrnSeq := Posicione( "TFF", 1, xFilial("TFF")+ABQ->ABQ_CODTFF, "TFF_SEQTRN")
		If Empty(cTrnSeq)
			cTrnSeq := "01"
		EndIf
		
		
		// ---------------------------------
		// Carrega as informa��es do turno
		TxCalenAtd( StoD((cAlias)->ABB_DTINI)-1, StoD((cAlias)->ABB_DTFIM), (cAlias)->ABB_CODTEC,;
							@aCalendAtd, @aCalendInf, cTurno, cTrnSeq,.F.,.F. )
	
		//---------------------------------------------------------------
		//  Verifica se o tipo est� nos tipos que permitem a manuten��
		// de m�ltiplas agendas
		If Len(aCalendAtd) > 1
			
			For nPosHr := 1 To Len(aCalendAtd)
				If ( 	aCalendAtd[nPosHr,1]== StoD( (cAlias)->ABB_DTINI ) ; // data in�cio
						.And. aCalendAtd[nPosHr,3]== (cAlias)->ABB_HRINI ;
						.And. aCalendAtd[nPosHr,7]== StoD( (cAlias)->ABB_DTFIM ) ;
						.And. aCalendAtd[nPosHr,4]== (cAlias)->ABB_HRFIM ;
					)
					
					dDtRef := aCalendAtd[nPosHr,8]
					Exit
				EndIf
			Next nPosHr
			
			If Empty(dDtRef)
				dDtRef := StoD( (cAlias)->ABB_DTINI )
			EndIf
			
			// ----------------------------------------------------------------------
			//  Identifica o item do array que se refere aquele per�odo do 
			// turno
			aAdd( aRecnosMk, {	(cAlias)->( Recno() ),; // Posicao do registro na tabela 
								(cAlias)->ABB_OK==1 ,; // se j� est� marcado
								.F. ,; // ainda n�o identificado para r�plica
								dDtRef,;
								(cAlias)->ABB_ATIVO=='1' } ) // data de refer�ncia da agenda 
			
		EndIf
	
	EndIf

	If ( (cAlias)->ABB_OK == 1 )
		
		If !lRet
			nPriSelec := (cAlias)->( Recno() )
		EndIf
		
		lRet := .T.
		
		If nLimAgeSel > nAgeSel
			AAdd( aCarga, { (cAlias)->ABB_CODTEC 										 	,;
							SubStr( (cAlias)->ABB_IDCFAL, 1, TAMSX3( 'AAH_CONTRT' )[1] )	,;
				            (cAlias)->ABB_CODIGO  					   						,;
				            (cAlias)->ABB_DTINI												,;
				            (cAlias)->ABB_HRINI	   											,;
				            (cAlias)->ABB_DTFIM	   											,;
				            (cAlias)->ABB_HRFIM		} )
			nAgeSel++
			If ( aScan( aHrSelec, {|x| x[1]==(cAlias)->ABB_HRINI .And. x[2]==(cAlias)->ABB_HRFIM } ) == 0 )
				aAdd( aHrSelec, { (cAlias)->ABB_HRINI, (cAlias)->ABB_HRFIM } )
			EndIf
		Else
			lRet := .f.
			Exit
		EndIf

	EndIf
	
	(cAlias)->(DbSkip())
	
EndDo

If ( !lRet )
	Help( " ", 1, "AT540VldChk", ,IIF(  nLimAgeSel > nAgeSel , STR0012, STR0017+ cValtochar(nLimAgeSel)+ STR0018), 1, 0 )	//'Selecione ao menos um registro para realizar a manuten��o.'##"� poss�vel selecionar at�  "## " agendas."
	aCarga := {}
Else
	//--------------------------------------------------------------
	//  Identifica que houve a sele��o de mais que um hor�rio
	// entre os registros selecionados
	lMkDifHr := ( Len( aHrSelec ) > 1 )
EndIf

RestArea( aAreaTmp )
RestArea( aArea )

//-----------------------------------------------------------
//  Garante que a tabela fique posicionada com um registro
// que sofrer� a manuten��o da agenda
If nPriSelec > 0
	(cAlias)->( DbGoTo( nPriSelec ) )
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} DadosCampo
Fun��o auxiliar que retorna dados de um campo no SX3.

@sample 	DadosCampo( cCampo )

@param		cCampo	Nome do campo que deseja obter informa��es.
			
@return	aDados Dados do campo.
					[1] T�tulo do campo.
					[2] Descri��o do campo.
					[3] Tamanho do campo.
					[4] Decimais do campo.
					[5] Picture do campo.

@author	Danilo Dias
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function DadosCampo( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
SX3->( DbGoTop() )

If ( SX3->( MsSeek( cCampo ) ) )

	AAdd( aDados, X3Titulo() )			//Retorna t�tulo do campo no X3
	AAdd( aDados, X3Descric() )			//Retorna descri��o do campo no X3
	AAdd( aDados, TamSX3(cCampo)[1] )	//Retorna tamanho do campo
	AAdd( aDados, TamSX3(cCampo)[2] )	//Retorna quantidade de casas decimais do campo
	AAdd( aDados, X3Picture(cCampo) )	//Retorna a picture do campo

EndIf

RestArea( aArea )

Return aDados


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540Atual
Atualiza o objeto Browse com a Query recebida.

@sample 	AT540Atual( oBrowse, cQuery )

@param		oBrowse	Objeto do tipo FWBrowse
			cQuery		Consulta SQL para atualizar a Browse

@author	Danilo Dias			
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540Atual( oBrowse, cQuery )

Local lRet	:= .T.
Local cAliasQry := ""

oBrowse:Data():DeActivate()
oBrowse:SetQuery( cQuery )
oBrowse:Data():Activate()
oBrowse:UpdateBrowse(.T.)
oBrowse:GoBottom()
oBrowse:GoTo(1, .T.)
oBrowse:Refresh(.T.)

cAliasQry := oBrowse:calias
Do While (cAliasQry)->(!Eof()) 
	At540SetAge("1", cAliasQry)
	(cAliasQry)->(dBSkip())
EndDo
oBrowse:GoBottom()
oBrowse:GoTo(1, .T.)
oBrowse:Refresh(.T.)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540ABBQry
Fun��o para montar a consulta � agenda do atendente.

@sample 	AT540ABBAry( cCodTec, cChave, dDataDe, dDataAte )

@param		cCodTec	C�digo do atendente
			cChave		Chave de consulta da OS para buscar a agenda
			dDataDe	Data inicial para retornar agendamentos
			dDataAte	Data final para retornar agendamentos
			cCodAgenda	Codigo da agenda a ser encontrada
			lSelected	Indica se os registros por padr�o estar�o selecionados
			cEntidade Entidade a ser considerada para filtro
			
@return	aRet 	Consulta e campos retornados.
					[1] cQuery - Consulta no padrao SQL
					[2] aCampos - Estrutura dos campos da consulta

@author	Danilo Dias
@since		17/12/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540ABBQry( cCodTec, cChave, dDataDe, dDataAte, cHoraDe, cHoraAte, cCodAgenda, lSelected, cEntidade )

Local aArea		:= GetArea()
Local cQuery		:= ''
Local aCampos		:= {}
Local aColumns	:= {}
Local nI			:= 0
Local nJ			:= 0
Local aRet			:= {}
Local aTemp	 	:= {}
Local aNoFields 	:= {}

Default cHoraDe 	:= "  :  "
Default cHoraAte 	:= "  :  "
Default cCodAgenda	:= ""
Default lSelected := .F.
Default cEntidade := 'AB7'

//--------------------------------------------------------------
// Campos utilizados
//--------------------------------------------------------------
AAdd( aCampos, 'ABB_CODIGO' )
AAdd( aCampos, 'ABB_CODTEC' )
AAdd( aCampos, 'AA1_NOMTEC' )
AAdd( aCampos, 'ABB_NUMOS' )
AAdd( aCampos, 'ABB_CHAVE' )
AAdd( aCampos, 'ABB_DTINI' )
AAdd( aCampos, 'ABB_HRINI' )
AAdd( aCampos, 'ABB_DTFIM' )
AAdd( aCampos, 'ABB_HRFIM' )
AAdd( aCampos, 'ABB_MANUT' )
AAdd( aCampos, 'ABB_ATIVO' )
AAdd( aCampos, 'ABB_IDCFAL' )
AAdd( aCampos, 'ABB_ATENDE' )
AAdd( aCampos, 'ABB_CHEGOU' )
AAdd( aCampos, 'ABB_LOCAL' )

//--------------------------------------------------------------
// Campos n�o visualizados na Browse
//--------------------------------------------------------------
AAdd( aNoFields, 'ABB_CODIGO' )
AAdd( aNoFields, 'ABB_CHAVE' )
AAdd( aNoFields, 'ABB_MANUT' )
AAdd( aNoFields, 'ABB_ATIVO' )
AAdd( aNoFields, 'ABB_IDCFAL' )
AAdd( aNoFields, 'ABB_OK' )
AAdd( aNoFields, 'ABB_ATENDE' )
AAdd( aNoFields, 'ABB_CHEGOU' )

//--------------------------------------------------------------
// Monta consulta de dados da grid
//--------------------------------------------------------------
cQuery := "SELECT "

//Carrega campos que a consulta deve retornar
For nI := 1 To Len(aCampos)
	If ( nI > 1 )
		cQuery += ', '
	EndIf
	cQuery += aCampos[nI]
Next nI

If lSelected
	cQuery += ", 1 AS ABB_OK "
Else
	cQuery += ", 0 AS ABB_OK "
EndIf
cQuery += " FROM " + RetSQLName("ABB") + " ABB "
cQuery += " JOIN " + RetSQLName("AA1") + " AA1 ON AA1.AA1_FILIAL = '"+xFilial("AA1")+"' "
cQuery +=                                   " AND AA1.D_E_L_E_T_ = ' ' "
cQuery +=                                   " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
cQuery += " WHERE ABB.ABB_FILIAL = '"+xFilial("ABB")+"' "
cQuery +=   " AND ABB.D_E_L_E_T_ = ' ' "
cQuery +=   " AND ABB.ABB_ENTIDA = '"+cEntidade+"' "
cQuery +=   " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
cQuery +=   " AND ABB.ABB_CHAVE = '" + cChave + "' "
cQuery +=   " AND ( ABB.ABB_DTINI >= '" + DToS(dDataDe) + "' AND ABB.ABB_DTINI <= '" + DToS(dDataAte) + "' ) "

//--------------------------------------------------------------------
//  Adiciona filtro pelo hor�rio
If ! Empty( StrTran( cHoraDe, ":", "" ) ) .And. ! Empty( StrTran( cHoraAte, ":", "" ) )
	cQuery += " AND ( ABB.ABB_HRINI = '"+ cHoraDe +"' AND ABB.ABB_HRFIM = '"+ cHoraAte +"' ) "
ElseIf ! Empty( StrTran( cHoraDe, ":", "" ) )
	cQuery += " AND ABB.ABB_HRINI = '"+ cHoraDe +"' "
ElseIf ! Empty( StrTran( cHoraAte, ":", "" ) )
	cQuery += " AND ABB.ABB_HRFIM = '"+ cHoraAte +"' "
EndIf

If ! Empty(cCodAgenda)
	cQuery += " AND ABB.ABB_CODIGO = '"+cCodAgenda+"' "     	
EndIf

//--------------------------------------------------------------
// Cria estrutura dos campos da grid
//--------------------------------------------------------------
AAdd( aCampos, 'ABB_OK' )

nJ := 1

For nI := 1 To Len(aCampos)

	If ( AScan( aNoFields, aCampos[nI] ) == 0 )
		
		aTemp := DadosCampo(aCampos[nI])
		
		AAdd( aColumns, FWBrwColumn():New() )
		If ( aCampos[nI] $( 'ABB_DTINI|ABB_DTFIM' ) )
			aColumns[nJ]:SetData( &("{||SToD(" + aCampos[nI] + ")}") )
		Else
			aColumns[nJ]:SetData( &("{||" + aCampos[nI] + "}") )
		EndIf	
		
		aColumns[nJ]:SetTitle( aTemp[1] )
		aColumns[nJ]:SetSize( aTemp[3] )
		aColumns[nJ]:SetDecimal( aTemp[4] )
		aColumns[nJ]:SetPicture( aTemp[5] )
		
		nJ++
		
	EndIf
	
Next nI

AAdd( aRet, cQuery )
AAdd( aRet, aColumns )

RestArea( aArea )

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540MkAll
Marca os registros da tabela tempor�ria quando ocorrer o clique no header do
campo de flag

@sample 	AT540MkAll( oMarkABB )

@param		oObjMark 	Objeto da classe FwFormBrowse para identifica��o do Alias e 
	Atualiza��o da interface
			
@return	Nil

@author	Josimar Assun��o
@since		23/04/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540MkAll( oObjMark )

Local cMarkABB := ''
Local nTipMark := If( lTipMark, 1, 0 )

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkABB := oObjMark:cAlias
	
	(cMarkABB)->( DbGoTop() )
	
	While (cMarkABB)->( !EOF() ) 

		(cMarkABB)->ABB_OK := nTipMark
		(cMarkABB)->( DbSkip() )
	End
	
	(cMarkABB)->( DbGoTop() )
	
	lTipMark := !lTipMark
	oObjMark:Refresh(,.T.)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT540MkOne
Marca o registro posicionado quando realizar enter ou duplo clique na linha

@sample 	AT540MkOne( oMarkABB )

@param		oObjMark 	Objeto da classe FwFormBrowse para identifica��o do Alias e 
	Atualiza��o da interface
			
@return	Nil

@author	Josimar Assun��o
@since		23/04/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT540MkOne( oObjMark )

Local cMarkABB := ''

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkABB := oObjMark:cAlias
	
	If (cMarkABB)->ABB_OK == 1
		(cMarkABB)->ABB_OK := 0
	Else
		(cMarkABB)->ABB_OK := 1
	EndIf

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At540DifHr
  Retorna a vari�vel lMkDifHr que indica se houve a sele��o de registros com 
hor�rios diferentes, para realizar o bloqueio de movimentos de hor�rios
entre per�odos de turno. (Pois iniciam em hor�rios distintos)

@sample 	At540DifHr()
@return	lMkDifHr	Indica se houve a sele��o de per�odos de turno (data e hora in�cio e fim 
	diferentes para mais de um registro)

@author	Josimar Assun��o
@since		30/04/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function At540DifHr()
Return lMkDifHr


//------------------------------------------------------------------------------
/*/{Protheus.doc} At540GetMk
  Retorna o array com os registros marcados para realizar a identifica��o de necessidade 
de replica��o dos dados

@sample 	At540GetMk()
@return 	aRecnosMk

@author 	Josimar Assun��o
@since 	30/04/2013
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At540GetMk()
Return aClone( aRecnosMk )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At540SetAge
Realiza a inicializa��o e atualiza��o do array com o status da manuten��o da agenda do atendente.
@sample 	At540SetAge(cTpRet, cAlias)
@param		cTpRet: "0"=Inicializa o array // "1"=Incrementa/atualiza o array
			cAlias: Alias a ser trabalhado para a montagem das informa��es do array
@return 	NIL
@author 	Alexandre da Costa
@since	 	24/09/2015
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At540SetAge(cTpRet, cAlias)
Local nPos     := 0

Default cTpRet := "0"
Default cAlias := ""

If	cTpRet	==	"0"			//Inicializa o array de manuten��o da agenda do atendente
	If	ValType(aMntAgenda)<>"A" .or. Len(aMntAgenda)>0
		aMntAgenda	:=	{}
	EndIf
ElseIf	cTpRet	==	"1" .and. !Empty(cAlias)		//Armazena/atualiza uma nova intera��o no array da manuten��o da agenda do atendente
	If	Len(aMntAgenda) > 0 .and. (aScan(aMntAgenda,{|x|	x[01] == (cAlias)->ABB_CODTEC})) == 0
		// Se houverem manuten��es da agenda, confere se o atendente � o mesmo. Caso contr�rio, for�a a
		// inicializa��o do array
		At540SetAge("0", cAlias)
	EndIf
	If	(nPos := aScan(aMntAgenda,{|x|	x[01] == (cAlias)->ABB_CODTEC		.and.;
											x[02] == StoD((cAlias)->ABB_DTINI)	.and.;
											x[03] == (cAlias)->ABB_HRINI		.and.;
											x[04] == StoD((cAlias)->ABB_DTFIM)	.and.;
											x[05] == (cAlias)->ABB_HRFIM		.and.;
											x[06] == (cAlias)->ABB_CODIGO		.and.;
											x[07] == (cAlias)->ABB_IDCFAL	}) ) == 0
		aAdd(aMntAgenda,	{	(cAlias)->ABB_CODTEC,;
								StoD((cAlias)->ABB_DTINI),;
								(cAlias)->ABB_HRINI,;
								StoD((cAlias)->ABB_DTFIM),;
								(cAlias)->ABB_HRFIM,;
								(cAlias)->ABB_CODIGO,;
								(cAlias)->ABB_IDCFAL,;
								(cAlias)->ABB_MANUT	})
		nPos := Len(aMntAgenda)
	EndIf
	aMntAgenda[nPos,08]	:=	(cAlias)->ABB_MANUT
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At540GetAge
Retorna o conte�do do array com o status da manuten��o da agenda do atendente.
@sample 	At540GetAge(cTpRet, cAlias)
@param		NIL
@return 	aRet
@author 	Alexandre da Costa
@since	 	24/09/2015
@version 	P12
/*/
//------------------------------------------------------------------------------
Function At540GetAge()
Local	aRet	:=	aClone( aMntAgenda )
At540SetAge("0")	//Limpa o array da manuten��o da agenda do atendente
Return	aRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At540LimAg
Retorna o limite de agendas que podem ser selecionadas.
@sample 	At540LimAg()
@param		NIL
@return 	aRet
@author 	fabiana.silva
@since	 	28/05/2019
@version 	P12.1.25
/*/
//------------------------------------------------------------------------------
Static Function At540LimAg()
Local nMaxQrySz := 31960
Local cQrySize 	:= ""
Local nLimite 	:= 0

If GetRPORelease() <= "12.1.017"
	nMaxQrySz := 15960
Elseif GetSrvVersion() <  "13.2.3.35"
 	nMaxQrySz := 15960
EndIf

If (cQrySize := GetSrvProfString( 'MaxQuerySize', 'NOFOUND' ) ) <> 'NOFOUND' .AND. Val(cQrySize) > 0
 	nMaxQrySz := Val(cQrySize)
ElseIf (cQrySize := GetPvProfString('GENERAL', 'MaxQuerySize', 'NOFOUND', 'APPSERVER.INI')  ) <> 'NOFOUND' .AND. Val(cQrySize) > 0
	nMaxQrySz := Val(cQrySize)
EndIf


//Calcula quantidade de per�odos a ser selecionados - Query da rotina ListarApoio TECXFUNA.PRW

//query sem os per�odos aprox 
//Query fixa(embebed sql) + (len(cJoinHabil)*2+Len(cWhereDisp)+Len(cWhereIndisp)+ Len(cWhereReg)*2 + Len(cJoinCarac)*2 + Len(cJoinCursos)*2+Len(cJoinSPF)*2 )- Aplica um acrescimo de 10%
 //3401                   + 1172                    +262             +252               +56                 +274                  +154       +622 = 6193 + 10% = 6812
 
 //len(cWhereABB)*2
 //660
 
//Limite da Abb
//nMaxQrySz >= 6812 + (660)*n
	
//(nMaxQrySz - 6812)/660 = n
 
nLimite := Int((nMaxQrySz - 6812)/660)

Return nLimite

