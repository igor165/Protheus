#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MATA470A.CH"

//---------------------------------------------------------------
/*/{Protheus.doc} MATA470A
Rotina para reiniciar a numeracao da serie selecionada quando o 
usuario utiliza o modelo de numerador controlado pela tadela SD9.

Clientes dos setores de telecomunicacao e energia eletrica necessitam
reiniciar o numerador de notas fiscais de saida a cada mes conforme
legislação do Ajuste SINIEF 07/05 referente a Nota Fiscal Eletrônica 
e o convênio ICMS 115/03. a Rotina somente podera ser executada caso
o usuario ja tenha implantado o novo formato de gravacao dos documentos
fiscais atraves do programa UpdSerieNF disponivel apos o release 12.1.8

@author Bruno Cremaschi
@since 30/09/2015
@version MP12.1.9
@return Nil
/*/
//---------------------------------------------------------------

Function MATA470A()

Local oLayer
Local oD9Dialog
Local aTamTela  := MsAdvSize(.F.)
Local aSizes    := {0,0,0,0}
Local nPerInfo  := 0
Local nPerProc  := 0
Local nDlgHeigh := 0 
Local nDlgWidth := 0
Local nI		:= 0
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
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso

Private aSerie	:= {}
Private oOk     := LoadBitmap( nil, "LBOK" )
Private oNo     := LoadBitmap( nil, "LBNO" )

//Funcionalidade somente será utilizando quando realizar controle de numeração de documento 
If cTipoNf != "3"
	MsgAlert(STR0002,STR0003) //"Parametro MV_TPNRNFS nao configurado para esta opcao !!"###"ATENCAO"
	Return Nil  			
Endif

If !lUsaNewKey
	MsgAlert(STR0032,STR0003) //"Esta rotina só pode ser executada caso a rotina UpdSerieNF tenha sido executada no ambiente, para detalhes consulte a documentação técnica nos links do UpdSerieNF."###"ATENCAO"
	Return Nil  			
EndIf
 
//Definição do tamanho do Dialog
aSizes[1] := 0
aSizes[2] := 0
aSizes[3] := 605//455
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
cSayInfo+= " <STRONG>" + STR0022 + CRLF  //"Esta rotina ajusta o Controle de Numeração de Documentos (Tabela SD9) e deverá ser processada sempre quando "
cSayInfo+= STR0023 + "</STRONG>" + CRLF //"o usuário desejar reiniciar a numeração dos documentos."
cSayInfo+= "  " + CRLF 
cSayInfo+= " <STRONG>" + STR0024 + "</STRONG>" + CRLF  //"O processo irá excluir todos os registros da tabela SD9, inclusive os já utilizados anteriormente."
cSayInfo+= "   " + CRLF 
cSayInfo+= " <STRONG>" + STR0030 + "</STRONG> " + CRLF  //"Observação:"
cSayInfo+= STR0031   //" Antes de executar a rotina, é recomendado realizar um backup da tabela de Controle de Numeração de Documentos (Tabela SD9)."
cSayInfo+= "</FONT></PRE>"


oScrollSay := TScrollArea():New(oPnlInfo,000,000,000,000,.T.,.T.,.T.)
oScrollSay:Align := CONTROL_ALIGN_ALLCLIENT

oPanelSay := TPanel():New(0,0,,oScrollSay,   NIL, .T., .F., NIL, /*RGB(147,193,255)*/,000,/*115*/58,  .F., .F. ) 
oPanelSay:Align := CONTROL_ALIGN_TOP

oScrollSay:SetFrame( oPanelSay ) 

oSayInfo := TSay():New( 005, 005, { || cSayInfo }, oPanelSay, Nil, Nil, Nil, Nil, Nil, .T., Nil , CLR_WHITE,  (nDlgWidth/2), 115, Nil, Nil, Nil, Nil, Nil, .T./*[lHTML]*/ )

aSerie := GetSerie()

//Cria grid para seleção das séries.
oBrowse := TCBrowse():New( 060 ,001,400,135/*50*/,,,,oPnlInfo,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
oBrowse:SetArray(aSerie) 
oBrowse:AddColumn(TCColumn():New(' ',{|| if(aSerie[oBrowse:nAt,1],oOk,oNo) },,,,'LEFT',10,.T.,.T.,,,,.F.,))
oBrowse:AddColumn(TCColumn():New('Serie',{||aSerie[oBrowse:nAt,2] },,,,'LEFT',,.F.,.F.,,,,.F.,))

oBrowse:nScrollType	 := 0
oBrowse:bHeaderClick := {|o,x| marcaCkb(aSerie) , oBrowse:refresh()}
oBrowse:bLDblClick   := {|z,x| aSerie[oBrowse:nAt,1] := alteraCkb(aSerie[oBrowse:nAt,1] ) }

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
oBtnClose := TButton():New(00,115,STR0009, oPnlTool,Nil,50,10,,,.F.,.T.,.F.,STR0010,.F.,,,.F. )  //"Sair"###"Fecha a tela de processamento."


//Define as acoes dos botoes
oBtnProcs:bAction := {|| Ma470Proc(oMtrProc,oSayProc, aSerie), oD9Dialog:End()  }
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
/*/{Protheus.doc} Ma470Proc
Rotina para ajuste da numeração do arquivo SD9 conforme configuração

@author Bruno Cremaschi
@since 30/09/2015
@version MP12.1.7
@param oMeter, object, Objeto para para incrementar no processamento 
@param oSay, object, Objeto para atualizar o descritivo do processamento
@param nMargin, numeric, Margem externa que sera aplicada em pixels
@return Nil
/*/

//---------------------------------------------------------------

Static Function Ma470Proc( oMeter, oSay, aSerie )

Local cQrySD9 	:= ""
Local cAliasSD9	:= GetNextAlias()
Local lGrpCGC	:= SuperGetMV("MV_FATGCGC",,.F.)	
Local nRegs		:= 0 
Local nMeter	:= 0 
Local nI		:= 0
Local cQryUPD 	:= ""
Local cAliasUPD	:= GetNextAlias()
Local aAux		:= {}
Local nTotRegs	:= 0 
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cNumNota  := ""
Local lReinicSX5:= .F.
Local nTamNota	:= TamSX3("F2_DOC")[1]

//Atualiza mensagem
oSay:SetText(STR0011) //"Selecionando os registros"

For nI:=1 To Len(aSerie)

	If aSerie[nI,1] == .T.
		// Elimina todos os registros
		cQrySD9 := " SELECT SD9.R_E_C_N_O_ SD9REC "
		cQrySD9 += " FROM " + RetSqlName("SD9") + " SD9 "
		cQrySD9 += " WHERE "
		cQrySD9 += " D9_SDOC = '" + aSerie[nI,2] + "' "
		cQrySD9 += " AND SD9.D_E_L_E_T_ = ' ' "
		cQrySD9 += " ORDER BY SD9REC "
		
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
		oSay:SetText(STR0012+Alltrim(Str(nRegs))+ STR0013  ) //"Excluindo "###" registro(s) ..."
		
		
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
			
			lReinicSX5 := .T.

		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicia a Numeracao da Serie no SX5 para atender o Conv ICMS 115/03    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaNewKey .And. lReinicSX5 

			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))
			If dbSeek( xFilial("SX5") + "01" + aSerie[nI,02] , .F. ) .And. SimpleLock("SX5") 

				// Gera nota com 6 ou 9 digitos, de acordo com o numero informado pelo usuario na tabela "01"
				If cPaisloc == "BRA" .And. Len(AllTrim(SX5->X5_DESCRI)) < nTamNota
					nTamNota := 6
				EndIf				

				cNumNota := StrZero( 1 , nTamNota , 0 )   

				RecLock("SX5",.F.)

				SX5->X5_DESCRI  := cNumNota
				SX5->X5_DESCSPA := cNumNota
				SX5->X5_DESCENG := cNumNota
	
				SX5->(MsRUnLock())

			EndIf

			lReinicSX5 := .F.

		EndIf

	EndIf
Next nI

oSay:SetText(STR0014) //"Processo finalizado."

If nTotRegs > 0 
	Aviso(STR0018, STR0019, {STR0020}) //"Controle de Numeração"###"Processo finalizado. Todas os registros encontrados foram excluídos."###"OK"
Else
	Aviso(STR0018, STR0021, {STR0020}) //"Controle de Numeração"###"Processo finalizado. Não foram encontrados registros."###"OK"
Endif 		

// Fecha a Area que realiza a exclusao                                              
If Select( cAliasSD9 ) > 0
	(cAliasSD9)->(DbCloseArea())	
EndIf

Return Nil

/**
* Autor : Bruno Cremaschi
* Data  : 01/10/2015
* Rotina: GetSerie
* Descri: Seleciona todas as séries disponíveis na tabela SX5.
*/

Static Function GetSerie()

Local cQuery	:= "" 
Local cAliasSX5	:= GetNextAlias()
Local aRet 		:= {}

cQuery := "SELECT X5_CHAVE "
cQuery += "FROM " + RetSqlName("SX5") + " SX5 "
cQuery += "WHERE " 
cQuery += "X5_TABELA = '01' AND "
cQuery += "D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
		
// Verifica se o alias esta em uso                                             
If Select( cAliasSX5 ) > 0
	(cAliasSX5)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSX5,.T.,.T.)

While !(cAliasSX5)->(EOF())

	aAdd(aRet, {.F., (cAliasSX5)->X5_CHAVE })

	(cAliasSX5)->(dbSkip())
EndDo

(cAliasSX5)->(DbGoTop())

Return(aRet)

/**
* Autor : Bruno Cremaschi
* Data  : 01/10/2015
* Rotina: marcaCkb
* Descri: Trata marcação ou não de todos os itens do Browse.
*/

Static Function marcaCkb(aSerie)

Local nI := 0

For nI := 1 to len(aSerie)
	If aSerie[nI,1] == .T.
		aSerie[nI,1] := .F.
	Else
		aSerie[nI,1] := .T.
	EndIf
next i 

Return 

/**
* Autor : Bruno Cremaschi
* Data  : 01/10/2015
* Rotina: alteraCkb
* Descri: Trata marcação ou não de item a item da Browse.
*/

Static Function alteraCkb(varCkb)
	If varCkb == .T.
		varCkb := .F.
	Else
		varCkb := .T.
	Endif
Return varCkb
