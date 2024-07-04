#Include "MATA470.ch"
#Include "protheus.ch"
#Include "FWBrowse.ch"

//---------------------------------------------------------------
/*/{Protheus.doc} MATA480
Rotina para ajuste da numeração do arquivo SD9 conforme configuração

@author By Wise
@since 20/09/2013
@version MP11.8
@return Nil
/*/
//---------------------------------------------------------------

Function MATA470()

Local oLayer
Local oD9Dialog
Local aTamTela  := MsAdvSize(.F.)
Local aSizes    := {0,0,0,0}
Local nPerInfo  := 0
Local nPerProc  := 0
Local nDlgHeigh := 0 
Local nDlgWidth := 0
Local oPnlInfo
Local oPnlProc
Local oPnlTool
Local oBtnProcs
Local oBtnClose
Local oSayProc 
Local oSayInfo	
Local oMtrProc
Local nMtrProc := 0
Local cSayProc := STR0001 //"Aguardando inicio do processamento..."
Local cSayInfo := "" 
Local oScrollSay
Local oPanelSay
Local cTipoNf  := SuperGetMV("MV_TPNRNFS")

//Funcionalidade somente será utilizando quando realizar controle de numeração de documento 
If cTipoNf != "3"
	MsgAlert(STR0002,STR0003) //"Parametro MV_TPNRNFS nao configurado para esta opcao !!"###"ATENCAO"
	Return Nil  			
Endif
 
//Definição do tamanho do Dialog
aSizes[1] := 0
aSizes[2] := 0
aSizes[3] := 455
aSizes[4] := 820

nDlgHeigh := aSizes[3]-aSizes[1]
nDlgWidth := aSizes[4]-aSizes[2]

nPerProc := Round( (150/nDlgHeigh) * 100 , 2 )
nPerInfo := 100-nPerProc
	

//Criação do Dialog
DEFINE MSDIALOG oD9Dialog TITLE STR0004  FROM aSizes[1],aSizes[2] TO aSizes[3],aSizes[4] PIXEL //"Atualização do controle de numeração - SD9"

//Criação do objeto Classe
oLayer:= FwLayer():New()

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:Init(oD9Dialog,.F.)

//Cria as colunas do Layer
oLayer:addCollumn('MAIN',100,.T.,Nil)

//Adiciona Janelas a coluna
oLayer:addWindow("MAIN","winInfo",STR0005,nPerInfo,.F.,.F.,{|| /*Alert("Clique consulta"  )*/ },/*"areaGrid"*/,{|| /*Alert("Foco consulta"  )*/ }) //"Descrição do processo"

oLayer:addWindow("MAIN","winProc",STR0006,nPerProc,.F.,.F.,{|| /*Alert("Clique parametros")*/ },/*"areaTool"*/,{|| /*Alert("Foco parametros")*/ }) //"Progresso do processamento"

//Construação de Paineis - winInfo -
oPnlInfo:=TPanel():New(0,0,,oLayer:getWinPanel( "MAIN", "winInfo", Nil ),   NIL, .T., .F., NIL, /*RGB(255,147,157)*/, 000,000,  .F., .F. )
oPnlInfo:Align := CONTROL_ALIGN_ALLCLIENT

cSayInfo:= " <PRE><FONT FACE='Arial, Helvetica, sans-serif'>" 
cSayInfo+= " <STRONG>" + STR0022 + CRLF  //"Esta rotina ajusta o Controle de Numeração de Documentos (Tabela SD9) e deverá ser processada sempre quando o parâmetro"
cSayInfo+= STR0023 + "</STRONG>" + CRLF //" MV_FATGCGC for alterado."
cSayInfo+= "  " + CRLF 
cSayInfo+= " <STRONG>" + STR0024 + "</STRONG>" + CRLF  //"O processo será realizado em duas etapas: "
cSayInfo+= "  " + CRLF 
cSayInfo+= "  <STRONG>" + STR0025 + "</STRONG>" + CRLF  //"Primeira Etapa"
cSayInfo+= STR0026 + CRLF  //"   Todos os registros de numeração que não foram utilizados serão excluídos do sistema."
cSayInfo+= "   " + CRLF 
cSayInfo+= "  <STRONG>" + STR0027 + "</STRONG>" + CRLF  //"Segunda Etapa"
cSayInfo+= STR0028+CRLF  //"   Caso esteja utilizando o Agrupamento por CNPJ (MV_FATGCGC == .T.) os campos D9_CNPJ e D9_FILORI serão atualizados conforme as "
cSayInfo+= STR0029 + CRLF  //"   informações do cadastro de empresas, esta situação ocorrerá quando o campo D9_CNPJ não estiver preenchido."
cSayInfo+= "   " + CRLF 
cSayInfo+= " <STRONG>" + STR0030 + "</STRONG> " + CRLF  //"Observação:"
cSayInfo+= STR0031   //" Antes de executar a rotina, é recomendado realizar um backup da tabela de Controle de Numeração de Documentos (Tabela SD9)."
cSayInfo+= "</FONT></PRE>"


oScrollSay := TScrollArea():New(oPnlInfo,000,000,000,000,.T.,.T.,.T.)
oScrollSay:Align := CONTROL_ALIGN_ALLCLIENT

oPanelSay := TPanel():New(0,0,,oScrollSay,   NIL, .T., .F., NIL, /*RGB(147,193,255)*/,000,115,  .F., .F. )
oPanelSay:Align := CONTROL_ALIGN_TOP

oScrollSay:SetFrame( oPanelSay ) 

oSayInfo := TSay():New( 005, 005, { || cSayInfo }, oPanelSay, Nil, Nil, Nil, Nil, Nil, .T., Nil , CLR_WHITE,  (nDlgWidth/2), 115, Nil, Nil, Nil, Nil, Nil, .T./*[lHTML]*/ )

//Construação de Paineis - winProc -
  
//Cria o painel que contera o meter do processo
oPnlProc := TPanel():New(0,0,,oLayer:getWinPanel( "MAIN", "winProc", Nil ),   NIL, .T., .F., NIL, /*RGB(255,147,157)*/, 000,000,  .F., .F. )
oPnlProc:Align := CONTROL_ALIGN_ALLCLIENT

//Construcao do Meter
oSayProc := TSay():New( 005, 100, { || cSayProc }, oPnlProc, Nil, Nil, Nil, Nil, Nil, .T., Nil , CLR_WHITE, ( (nDlgWidth/2) - 200), 010, Nil, Nil, Nil, Nil, Nil, .F./*[lHTML]*/ )
oMtrProc := TMeter():Create ( oPnlProc, { |u| if( Pcount() > 0, nMtrProc := u, nMtrProc ) }, 015, 100, 004, ( (nDlgWidth/2) - 200), 010, Nil, .T., Nil, Nil, .T., CLR_WHITE, Nil, Nil, Nil, Nil, Nil )
//oMtrBwLd:Hide()

//Cria um painel para os botoes de acao da janela
oPnlTool := TPanel():New(0,0,,oPnlProc,   NIL, .T., .F., NIL, /*RGB(255,147,157)*/, 000,016,  .F., .F. )
oPnlTool:Align := CONTROL_ALIGN_BOTTOM

// Construcao dos botoes de acao 
oBtnProcs := TButton():New(00,000,STR0007, oPnlTool,Nil,50,10,,,.F.,.T.,.F.,STR0008,.F.,,,.F. )  //"Executar"###"Inicia o processamento."
oBtnClose := TButton():New(00,115,STR0009, oPnlTool,Nil,50,10,,,.F.,.T.,.F.,STR0010,.F.,,,.F. ) //"Sair"###"Fecha a tela de processamento."

//Define as acoes dos botoes
oBtnProcs:bAction := {|| MA470PROC(oMtrProc,oSayProc), oD9Dialog:End()  }
oBtnClose:bAction := {|| oD9Dialog:End() }

//Atribui o estilo visual dos botoes
oBtnProcs:SetCss( " QPushButton{ margin: 2px; }" )
oBtnClose:SetCss( " QPushButton{ margin: 2px; }" )

//Alinha os botoes a direita do painel (o objeto mais a direita sera o primeiro a ser alinhado)
oBtnClose:Align := CONTROL_ALIGN_RIGHT
oBtnProcs:Align := CONTROL_ALIGN_RIGHT

ACTIVATE MSDIALOG oD9Dialog Centered


Return Nil

//---------------------------------------------------------------
/*/{Protheus.doc} MA470PROC
Rotina para ajuste da numeração do arquivo SD9 conforme configuração

@author By Wise
@since 20/09/2013
@version MP11.8
@param oMeter, object, Objeto para para incrementar no processamento 
@param oSay, object, Objeto para atualizar o descritivo do processamento
@param nMargin, numeric, Margem externa que sera aplicada em pixels
@return Nil
/*/
//---------------------------------------------------------------

Function MA470PROC( oMeter, oSay )

Local cQrySD9 	:= ""
Local cAliasSD9	:= GetNextAlias()
Local lGrpCGC		:= SuperGetMV("MV_FATGCGC",,.F.)	
Local nRegs		:= 0 
Local nMeter		:= 0 
Local cQryUPD 	:= ""
Local cAliasUPD	:= GetNextAlias()
Local aAux			:= {}
Local nTotRegs	:= 0 


//Atualiza mensagem
oSay:SetText(STR0011) //"Selecionando os registros inconsistentes"

// Elimina todos os registros que não foram utililizados
cQrySD9 := " SELECT SD9.R_E_C_N_O_ SD9REC "
cQrySD9 += " FROM " + RetSqlName("SD9") + " SD9 "

If  lGrpCGC

	cQrySD9 += " WHERE  SD9.D9_DTUSO = '' "
	
Else	

	cQrySD9 += "  WHERE ( SD9.D9_DTUSO = '' OR SD9.D9_FILIAL =' ')   "

Endif
cQrySD9 += " AND SD9.D_E_L_E_T_ = ' ' "
cQrySD9  += " ORDER BY SD9REC "

cQrySD9 := ChangeQuery(cQrySD9)

// Verifica se o alias esta em uso                                             
If Select( cAliasSD9 ) > 0

	(cAliasSD9)->(DbCloseArea())
	
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySD9),cAliasSD9,.T.,.T.)

(cAliasSD9)->(DbGoTop())

// Quantidade de registros a serem deletados
( cAliasSD9 )->( dbEval( { || nRegs ++ },,{ || ( cAliasSD9 )->( !Eof() ) } ) )

(cAliasSD9)->(DbGoTop())

//Atualiza o meter
oMeter:SetTotal(nRegs)
nTotRegs += nRegs

//Atualiza mensagem	
oSay:SetText(STR0012+Alltrim(Str(nRegs))+ STR0013  ) //"Excluindo "###" registro(s) inconsistente(s)..."


While (cAliasSD9)->(!EOF())

	// Posiciona no registro a ser excluido
	SD9->(DbGoTo((cAliasSD9)->SD9REC))
	nMeter++
	
	// Realiza a exclusao do registro
	SD9->(RecLock("SD9",.F.))
	SD9->(DbDelete())	
	SD9->(MsUnLock())		
	
	// Atualiza o meter
	oMeter:Set(nMeter)
	
	(cAliasSD9)->(DbSkip())
	
Enddo

oSay:SetText(STR0014) //"Processo finalizado."


// Realiza o Ajsute do CNPJ
If lGrpCGC 
	
	//Inicializa as variaveis 
	nMeter := 0
	nRegs	:= 0
	
	//Atualiza mensagem
	oSay:SetText(STR0015) //"Selecionando os registros para atualizacao"
	
	// Elimina todos os registros que não foram utililizados
	cQryUPD := " SELECT SD9.D9_FILIAL, SD9.R_E_C_N_O_ SD9REC "
	cQryUPD += " FROM " + RetSqlName("SD9") + " SD9 "
	cQryUPD += " WHERE SD9.D9_DTUSO <> '' "	
	cQryUPD += " AND SD9.D9_CNPJ  = ' ' "
	cQryUPD += " AND SD9.D_E_L_E_T_ = ' ' "
	cQryUPD += " ORDER BY SD9REC "
	
	cQryUPD := ChangeQuery(cQryUPD)
	
	// Verifica se o alias esta em uso                                             
	If Select( cAliasUPD ) > 0
	
		(cAliasUPD)->(DbCloseArea())
		
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryUPD),cAliasUPD,.T.,.T.)
	
	
	(cAliasUPD)->(DbGoTop())

	// Quantidade de registros a serem atualizados
	( cAliasUPD )->( dbEval( { || nRegs ++ },,{ || ( cAliasUPD )->( !Eof() ) } ) )

	(cAliasUPD)->(DbGoTop())
				
		
	//Atualiza o meter
	oMeter:SetTotal(nRegs)
	nTotRegs += nRegs
		
	//Atualiza mensagem	
	oSay:SetText(STR0016+Alltrim(Str(nRegs))+ STR0017  ) //"Atualizando "###" registro(s) sem CNPJ informado..."
	
	
	While (cAliasUPD)->(!EOF())

		// Posiciona no registro a ser excluido
		SD9->(DbGoTo((cAliasUPD)->SD9REC))
		nMeter++
		
		aAux := MA470RCGC(SM0->M0_CODIGO,(cAliasUPD)->D9_FILIAL )
		
		// Realiza a exclusao do registro
		SD9->(RecLock("SD9",.F.))
		SD9->D9_CNPJ 		:= aAux[1]
		SD9->D9_FILORI	:= aAux[2]
		SD9->(MsUnLock())		
		
		// Atualiza o meter
		oMeter:Set(nMeter)
		
		(cAliasUPD)->(DbSkip())
	
	Enddo

	oSay:SetText(STR0014) //"Processo finalizado."


Endif 
If nTotRegs > 0 
	Aviso(STR0018, STR0019, {STR0020}) //"Controle de Numeração"###"Processo finalizado. Todas as inconsistências encontradas foram ajustadas."###"OK"
Else
	Aviso(STR0018, STR0021, {STR0020}) //"Controle de Numeração"###"Processo finalizado. Não foram encontradas inconsistências."###"OK"
Endif 		

// Fecha a Area que realiza a exclusao                                              
If Select( cAliasSD9 ) > 0
	(cAliasSD9)->(DbCloseArea())	
EndIf
// Fecha a Area que foi utilizada para atualizacao                                               
If Select( cAliasUPD ) > 0
	(cAliasUPD)->(DbCloseArea())	
EndIf

Return Nil 

//---------------------------------------------------------------
/*/{Protheus.doc} MA470RCGC
Rotina que retorna o CNPJ conforme código de filial informado

@author By Wise
@since 20/09/2013
@version MP11.8
@param cSM0Emp, character, Informa a empresa na qual deseja realizar a pesquisa 
@param cSM0Fil, character, Informa a filial na qual deseja realizar a pesquisa
@return array, Vetor contendo os CNPJ's e Estrutura de Filial
/*/
//---------------------------------------------------------------

Function MA470RCGC (cSM0Emp,cSM0Fil )

Local aArea   := GetArea()
Local aAreaM0 := SM0->( GetArea() )
Local aRet    := {}
Local cEmpCod	:= ""
Local cFilCod	:= ""

SM0->( DbSetOrder(1) )

//Pesquisa a empresa informada

If SM0->( DbSeek( cSM0Emp + cSM0Fil ) )
	
	cEmpCod := SM0->M0_CGC
	cFilCod := SM0->M0_CODFIL
	
Endif

aAdd( aRet, cEmpCod )
aAdd( aRet, cFilCod ) 

SM0->( RestArea( aAreaM0 ) )
RestArea( aArea )

Return aRet