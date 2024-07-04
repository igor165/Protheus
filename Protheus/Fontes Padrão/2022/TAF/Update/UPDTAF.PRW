#include 'protheus.ch'
#include 'updtaf.ch' 

//-----------------------------------------------------------------------
/*/{Protheus.doc} updtaf
Rotina de atualização de dicionário de dados do TAF.

@param cOrigem -> indica a origem da chamada do UPDTAF.
					0 - Programa Inicial - smartclient
					1 - TAF_Atualizador

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
main function updtaf( cOrigem )

	local aEmpresas := {}

	default cOrigem := '0'

	if ( lOpen := updOpenSM0( @aEmpresas , .T. ) ) // verifica se encontrou empresa/filial
		If Len(aEmpresas) > 0
			rpcSetType( 3 )
			//rpcSetEnv( SM0->M0_CODIGO , SM0->M0_CODFIL ,,, "TAF" ) // trecho comentado pois existem casos que o primeiro registro está deletado e não possui tabelas criadas, gerando error log.
			rpcSetEnv( aEmpresas[1][2] , aEmpresas[1][3]  ,,, "TAF" )// se encontrou empresa/filial, loga na primeira empresa encontrada.
			if ( cOrigem == '1' ) .or. ( checkEnvUpddistr( ) )
				RpcClearEnv()
				upddistr()
			else
				procUpdTAF( aEmpresas )
			endif
		EndIf
	endif

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} procUpdTAF
Função principal que executa atualização de dicionário de dados do TAF depois
que o UPDDISTR já foi concluído.

@param		aEmpresas	-	Array contendo as empresas que serão processadas

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function procUpdTAF( aEmpresas )

	local	cTxtIntro	as	character
	local	lMarcaItem	as	logical
	local	aListUpd	as	array
	local	aColSize	as	array
	local	aTitulos	as	array
	local	oNo			as	object
	local	oOk			as	object
	local	oBtn1		as	object
	local	oBtn2		as	object
	local	oBtn3		as	object
	local	oBtn4		as	object
	local	oBtn5		as	object
	local	oDlgUpd	as	object
	local	oListUpd	as	object
	private aUpdTask	as	array

	cTxtIntro	:=	''
	aColSize	:=	{ 3 , 30 , 195 , 40 , 15 }
	aTitulos	:=	{' ', 'Release', STR0113 , STR0106 , "Id." }
	oNo			:=	loadBitMap( getResources() , "LBNO" )
	oOk			:=	loadBitMap( getResources() , "LBOK" )
	lMarcaItem	:=	.T.
	aUpdTask	:= {}

	//Ignora os registros deletados no sigamat.emp
	SET DELETED ON

	cTxtIntro := "<table width='100%' border=0.5>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'><size='+3'>"
	cTxtIntro += "Esta rotina tem o objetivo de atualizar o metadados do ambiente conforme os itens selecionados abaixo." + "</font></td>"
	cTxtIntro += "<td></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'><color='#FF0000' size='+3'><br>"+ "As atualizações somente poderão ser realizadas em modo" +"<b>"+ STR0003 +"</b><br>"
	cTxtIntro += STR0004
	cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
	cTxtIntro += "</font></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "</table>

	//-- Obtem a lista de Updates disponiveis para execucao:
	aListUpd := getUpdateList()

	cMsgTitle := 'Update - TOTVS Automação Fiscal'

	DEFINE MSDIALOG oDlgUpd;
	TITLE cMsgTitle;
	FROM 00,00 TO 500,700 PIXEL

	tSay():new( 002 , 005 , {|| cTxtIntro } , oDlgUpd ,,,,,, .T. ,,, 340 , 200 ,,,, .T. ,, .T. )

	oListUpd := tWBrowse():new(	40 , 07 , 335 , 162 , , aTitulos , aColSize , oDlgUpd ,,,,,,,,,,,,, "ARRAY" , .T. )
	oListUpd:bLDblClick := {|| aListUpd[ oListUpd:nAt , 1 ] := !aListUpd[ oListUpd:nAt , 1 ] , oListUpd:Refresh() }
	oListUpd:SetArray( aListUpd )
	oListUpd:bLine := {|| { if( aListUpd[ oListUpd:nAt , 1 ] , oOk , oNo ) ,;
								aListUpd[ oListUpd:nAT , 2 ] ,;
								aListUpd[ oListUpd:nAT , 3 ] ,;
								aListUpd[ oListUpd:nAT , 4 ] ,;
								aListUpd[ oListUpd:nAT , 5 ] } }

	oBtn1 := tButton():new( 210,005, STR0006 , oDlgUpd,; //Marca/Desmarca Pendentes
					{|| aEval(aListUpd,{|aElem| aElem[1] := If(aElem[4] == STR0016 , lMarcaItem, .F.)}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; //Pendente
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn2 := tButton():new( 210,140, STR0007 , oDlgUpd,; //Marca/Desmarca Todos
					{|| aEval(aListUpd,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },;
					075,015,,/*oFonte*/,,.T.,,,,,,)


	oBtn3 := tButton():new( 210,270, STR0008 , oDlgUpd,; //Selecionar Empresas
					{|| aEmpresas := TAFSelSM0( @aEmpresas ) },;
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn4 := tButton():new( 230,005, STR0009 , oDlgUpd,; //'Processar...'
					{|| RpcClearEnv(), MsgRun(STR0011, STR0189 ,{||TAFProcUpd( aListUpd, aEmpresas , @aUpdTask )}), oDlgUpd:End() },; //Aguarde o termino do Processamento ## "TOTVS Automação Fiscal"
					075,015,,/*oFonte*/,,.T.,,,,,,)

	oBtn5 := tButton():new( 230,140, STR0010 , oDlgUpd,; //Cancelar
					{|| __quit()},;
					075,015,,/*oFonte*/,,.T.,,,,,,)

	//Altera o estilo dos botões
	oBtn1:SetCss("color:black }")
	oBtn2:SetCss("color:black }")
	oBtn3:SetCss("color:black }")
	oBtn4:SetCss("color:black }")
	oBtn5:SetCss("color:black }")

	activate MSDIALOG oDlgUpd centered

	If !Empty(aUpdTask)
		showLog( aUpdTask )
	EndIf

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} getUpdateList
Função que carrega as opções de atualização que devem ser apresentadas ao usuário.

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
Static Function getUpdateList()

	Local	aList	as	array

	aList	:=	{}

	AAdd( aList, {	.F., "P12106" 		, "Atualização - Dicionário de dados TAF - Release 12.1.006" 	 	, vldUpd("P12106") 	 	, "006" } )
	AAdd( aList, {	.F., "P12107" 		, "Atualização - Dicionário de dados TAF - Release 12.1.007" 	 	, vldUpd("P12107") 	 	, "007" } )
	AAdd( aList, {	.F., "P12114" 		, "Atualização - Dicionário de dados TAF - Release 12.1.014" 	 	, vldUpd("P12114") 	 	, "014" } )
	AAdd( aList, {	.F., "P12116" 		, "Atualização - Dicionário de dados TAF - Release 12.1.016" 	 	, vldUpd("P12116") 	 	, "016" } )
	AAdd( aList, {	.F., "P12117" 		, "Atualização - Dicionário de dados TAF - Release 12.1.017" 	 	, vldUpd("P12117") 	 	, "017" } )
	AAdd( aList, {	.F., "P12123" 		, "Atualização - Dicionário de dados TAF - Release 12.1.023" 	 	, vldUpd("P12123") 	 	, "023" } )
	AAdd( aList, {	.F., "P12125" 		, "Atualização - Dicionário de dados TAF - Release 12.1.025" 	 	, vldUpd("P12125")		, "025" } )
	AAdd( aList, {	.F., "P12127" 		, "Atualização - Dicionário de dados TAF - Release 12.1.027" 		, vldUpd("P12127") 		, "027" } )
	AAdd( aList, {	.F., "P12133" 		, "Atualização - Dicionário de dados TAF - Release 12.1.033" 		, vldUpd("P12133") 		, "033" } )

Return aList

//-----------------------------------------------------------------------
/*/{Protheus.doc} updOpenSM0
Função que verifica se o ambiente pode ser aberto e carrega as empresas se solicitado
através do parâmetro lLoadEmp

@param		aEmpresas	-	Array contendo as empresas que serão carregadas. Só tem efeito se lLoadEmp = .t.
@param		lLoadEmp	-	Se .t. carrega as empresas e retorna no primeiro parâmetro aEmpresas ( default .f. )

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function updOpenSM0( aEmpresas , lLoadEmp )

	local	lOpen	as	logical
	local	nLoop	as	numeric
	local	nVezes	as	numeric

	default	aEmpresas	:=	{}
	default	lLoadEmp	:=	.F.

	lOpen	:=	.F.
	nLoop	:=	0
	nVezes	:=	20

	for nLoop := 1 To nVezes

		OpenSm0()

		If !empty( select( "SM0" ) )
			lOpen := .T.
			exit
		endif

		sleep( 500 )

	next nLoop

	if !( lOpen )
		msgAlert( STR0013 ) //"Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"

	else

		if lLoadEmp
			//-- Obtem as Empresas para processamento...
			SM0->( dbGotop() )
			while !( SM0->( eof() ) )
				if aScan( aEmpresas, { |x| x[ 2 ] == M0_CODIGO } ) == 0 .And. !Deleted()//--So adiciona no array se a empresa for diferente
					aAdd( aEmpresas , {	.T. ,;
										M0_CODIGO,;
										M0_CODFIL,;
										M0_FILIAL,;
										recno() } )
				endif

				SM0->( dbSkip() )
			EndDo

			SM0->( dbGoTop() )
		endif
	endif

return( lOpen )

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFSelSM0
Exibe janela para escolha das empresas que devem ser processadas

@author Evandro dos Santos Oliveira
@since 	 01.07.2015
@version 1.0

@param	 aEmpresas	Array que sera carregada as empresas

@return aEmpresas	Array com as informacoes das empresas.
/*/
//----------------------------------------------------------------------
Static Function TAFSelSM0( aEmpresas )

	local	oDlgSM0		as	object
	local	oListBox	as	object
	local	oOk			as	object
	local	oNo			as	object
	local	aHList		as	array
	local	lMarcaItem	as	logical

	default	aEmpresas	:=	{}

	oDlgSM0		:=	nil
	oListBox	:=	nil
	oOk			:=	LoadBitMap(GetResources(),"LBOK")
	oNo			:=	LoadBitMap(GetResources(),"LBNO")
	aHList		:=	{}
	lMarcaItem	:=	.T.

	DEFINE MSDIALOG oDlgSM0 TITLE STR0115 From 9,0 To 30,52

	AAdd( aHList, ' ')
	AAdd( aHList, STR0017 )//Empresa
	AAdd( aHList, STR0018 )//Filial
	AAdd( aHList, STR0019 )//Nome
	AAdd( aHList, STR0020 ) //Id.

	oListBox := TWBrowse():new(005,005,155,145,,aHList,,oDlgSM0,,,,,,,,,,,,, "ARRAY", .T. )
	oListBox:SetArray( aEmpresas )
	oListBox:bLine := {|| {	If(aEmpresas[oListBox:nAT,1], oOk, oNo),;
							aEmpresas[oListBox:nAT,2],;
							aEmpresas[oListBox:nAT,3],;
							aEmpresas[oListBox:nAT,4],;
							aEmpresas[oListBox:nAT,5]}}

	oListBox:bLDblClick := {|| aEmpresas[oListBox:nAt,1] := !aEmpresas[oListBox:nAt,1], oListBox:Refresh()}

	DEFINE SBUTTON FROM    4,170 TYPE 1 ACTION (oDlgSM0:End())   ENABLE OF oDlgSM0
	DEFINE SBUTTON FROM 18.5,170 TYPE 11 ACTION (Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem,,oListBox:Refresh()) ONSTOP STR0021 ENABLE OF oDlgSM0 //Marca/Desmarca

	activate MSDIALOG oDlgSM0 centered

Return( aEmpresas )

//-----------------------------------------------------------------------
/*/{Protheus.doc} checkEnvUpddistr
Função que analisa o ambiente e apresenta tela ao usuário caso seja necessário atualizar
o ambiente do TAF com a execução do UPDDISTR.

@return		lExecDistr	-	se .t. o UPDDISTR precisa ser executado para atualização do TAF.

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function checkEnvUpddistr()

	local	lExecDistr	as	logical
	local	lExecSegr1	as	logical
	local	lExecSegr2	as	logical
	local	cTitle		as	character
	local	cText		as	character
	local	nTamWindow	as	numeric
	local	nLin		as	numeric
	local	nCol		as	numeric
	local	oDlgMsg		as	object
	local	oFont		as	object
	local	bReadMore	:=	{|| ShellExecute( "open" , "http://tdn.totvs.com/pages/viewpage.action?pageId=198935223" , "" , "" , 1 ) }

	lExecSegr1	:=	.F.
	lExecSegr2	:=	.F.
	lExecDistr	:=	.F.
	oFont		:= TFont():new('Arial',,-12,.T.)
	nLin		:=	420
	nCol		:=	720
	nTamWindow	:=	3

	cTitle		:=	"UPDDISTR"

	cText		:=	"Este update é responsável pela atualização de metadados do <b>TOTVS Automação Fiscal.</b><br><br>"
	cText		+=	"O sistema identificou a necessidade de execução do compatibilizador <b>UPDDISTR</b> devido componentes "
	cText		+=	"do dicionário de dados não localizados no ambiente.<br><br>"
	cText		+=	"Ao clicar em 'Continuar' você será direcionado a esta rotina de atualização e <b>será necessário realizar nova execução do UPDTAF "
	cText		+=	"após o término do processamento do UPDDISTR</b> para finalizar o processo de atualização do TAF.<br><br>"
	cText		+=	"Clique em 'Saiba Mais' e entenda o procedimento de atualização completo do TOTVS Automação Fiscal.<br><br>"
	cText		+=	"Observações sobre a análise do ambiente:<br>"

	cText		+=	" -> Necessário aplicar a Parte 1 da Atualização de dicionário de dados do TAF? "
	if !tafAlsInDic("CHA")
		lExecSegr1 := .T.
		cText		+=	"<b>Sim</b><br>"
	else
		lExecSegr1 := .F.
		cText		+=	"<b>Não</b><br>"
	endif

	cText += " -> Necessário aplicar a Parte 2 da Atualização de dicionário de dados do TAF? "
	If	( !TafAlsInDic( "LEF" ) .or. !TafAlsInDic( "LEY" ) ) .or.;//Release 12.1.14
		( AllTrim( Posicione( "SX3", 2, "C0R_CODDA", "X3_VISUAL" ) ) <> "V" .or. AllTrim( Posicione( "SX3", 2, "C0R_DCODRE", "X3_RELACAO" ) ) <> "TAF027Init()" ) .or.; //Release 12.1.16
		( X3Uso( Posicione( "SX3", 2, "C8R_REPDSR", "X3_USADO" ))  == .T. .and. !TAFColumnPos( "C9G_VLNRET" ) /*Reinf 1.3*/ ) //Release 12.1.17

		lExecSegr2 := .T.
		cText += "<b>Sim</b><br>"
	Else
		lExecSegr2 := .F.
		cText += "<b>Não</b><br>"
	EndIf

	if lExecSegr1 .or. lExecSegr2

		oDlgMsg := MsDialog():new( 0, 0, nLin, nCol, "",,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )

		oLayer := FWLayer():new()
		oLayer:Init( oDlgMsg, .F. )
		oLayer:AddLine( "LINE01", 100 )
		oLayer:AddCollumn( "BOX01", 100,, "LINE01" )
		oLayer:AddWindow( "BOX01", "PANEL01", 'IMPORTANTE...', 100, .F.,,, "LINE01" )

		oSay	:=	TSay():new(10,10,{|| cText },oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),,oFont,,,,.T.,,,340,nLin,,,,,,.T.)
		oSay:lWordWrap = .T.

		tButton():new( 140, 40,  "Saiba Mais"	,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), bReadMore 								, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )
		tButton():new( 140, 140, "Continuar"	,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), {|| oDlgMsg:end() , lExecDistr := .T. }	, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )
		tButton():new( 140, 240, "Cancelar"		,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), {|| __quit() }							, 70,30,,oFont,.F.,.T.,.F.,,.F.,,,.F. )

		activate MSDIALOG oDlgMsg centered

	endif

return ( lExecDistr )

//-----------------------------------------------------------------------
/*/{Protheus.doc} vldUpd
Função que verifica se determinado Update já foi aplicado.

@param		cUpdate	-	Identificação da atualização que deve ser verificada

@return		cInfo	-	Retornar "Executado" ou "Pendente"

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function vldUpd( cUpdate )

	local	cInfo	as	character
	local	lAchou := .F. 
	Local	aRelacao as array

	default	cUpdate	:=	""

	cInfo	:=	"Pendente"

	do case

		case "P12106" $ cUpdate

			if ( AllTrim( Posicione( "SX3", 2, "CEP_DCTA", "X3_RELACAO" ) ) ) == 'Iif(!INCLUI .and. !Empty(CEP->CEP_IDCTA),Posicione("CFR",1,xFilial("CFR")+CEP->CEP_IDCTA,"CFR_DCODCT"),"")'
				cInfo := "Executado"
			endif

		case "P12107" $ cUpdate

			if ( AllTrim( Posicione( "SX3", 2, "CM4_DTRABA", "X3_RELACAO" ) ) ) == "XFUNRelac(48,'CM4_TRABAL')"
				cInfo := "Executado"
			endif

		case "P12114" $ cUpdate

			if ( AllTrim( Posicione( "SX3", 2, "C3H_VTXAD", "X3_TITULO" ) ) ) == "Vlr Ad Valor"
				cInfo := "Executado"
			endif

		case "P12116" $ cUpdate

			if ( AllTrim( Posicione( "SX2", 1, "CAK", "X2_MODO" ) ) ) == "C"
				cInfo := "Executado"
			endif

		Case "P12117" $ cUpdate
		
			lAchou := FwSX9Util():SearchX9Paths( 'C9V', 'C91', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C9V' .and. x[3] == 'C91' .and. alltrim(x[2]) != 'C9V_ID' .and. alltrim(x[4]) == 'C91_TRABAL' } ) > 0
			
			if !lAchou
				If AllTrim( Posicione( "SX3", 2, "C91_NOME", "X3_VISUAL" ) ) == "A"
					lAchou := .F.
				Else
					lAchou := .T.
				EndIf
			endif

			if !lAchou

				lAchou := FwSX9Util():SearchX9Paths( 'T9C', 'C20', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T9C' .and. x[3] == 'C20' .and. alltrim(x[4]) == 'C20_CODOBR'  } ) > 0

				if !lAchou
					
					lAchou := FwSX9Util():SearchX9Paths( 'C20', 'CRO', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C20' .and. x[3] == 'CRO' .and. alltrim(x[4]) == 'CRO_CHVNF'  } ) > 0

					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'C20', 'T96', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C20' .and. x[3] == 'T96' .and. alltrim(x[4]) == 'T96_CHVNF'  } ) > 0
					endif
				
					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "C1E_DTINI", "X3_VALID" ) ) == 'XFUNVldDt(, "C1E_DTFIN")'
							lAchou := .F.
						Else
							lAchou := .T.
						EndIf
					endif

					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'LEM', 'CRO', @aRelacao ) .or. FwSX9Util():SearchX9Paths( 'LEM', 'T96', @aRelacao )
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CMD_CNPJSU", "X3_TITULO" ) ) == 'Nr Inscrição'
							lAchou := .F.
						Else
							lAchou := .T.
						EndIf
					endif
					
					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "T3P_BENEFI", "X3_USADO" ) ) == AllTrim( Posicione( "SX3", 2, "T3P_CPF   ", "X3_USADO" ) )
							lAchou := .F.
						Else 
							lAchou := .T.
						EndIf
					EndIf

					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "T3P_BENEFI", "X3_RESERV" ) ) == AllTrim( Posicione( "SX3", 2, "T3P_CPF   ", "X3_RESERV" ) )
							lAchou := .F.
						Else 
							lAchou := .T.
						EndIf
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "C91_CNPJEA", "X3_TITULO" ) ) == 'Nr Inscrição'
							lAchou := .F.
						Else
							lAchou := .T.
						EndIf
					endif
					
					If !lAchou
						lAchou  := FwSX9Util():SearchX9Paths( 'C92', 'C20', @aRelacao ) .and. aScan( aRelacao, { |x| x[3] == 'C20' .and. alltrim(x[4]) == 'C20_CODOBR'  } ) > 0
					EndIf
					
					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'T34', 'T35', @aRelacao ) .and. aScan( aRelacao, { |x| x[3] == 'T35' .and. alltrim(x[4]) == 'T35_CODAJU'  } ) > 0
					EndIf
					
					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'T37', 'T36', @aRelacao ) .and. aScan( aRelacao, { |x| x[3] == 'T36' .and. alltrim(x[4]) == 'T36_CODDIS'  } ) > 0
					EndIf
					
					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'C0G', 'T6L', @aRelacao ) .and. aScan( aRelacao, { |x| x[3] == 'T6L' .and. alltrim(x[4]) == 'T6L_ANPITE'  } ) > 0
					EndIf
					
					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'T5A', 'T6L', @aRelacao ) .and. aScan( aRelacao, { |x| x[3] == 'T6L' .and. alltrim(x[4]) == 'T6L_OPEANP'  } ) > 0
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "C29_VLRLIQ", "X3_VISUAL" ) ) == 'A'
							lAchou := .t.
						EndIf				
					endif

					if !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'T9C', 'C20', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T9C' .and. x[3] == 'C20' .and. alltrim(x[2]) == 'T9C_NRINSC'  } ) > 0
					EndIf	

					// Seek por T92
					If !lAchou
						lAchou := FwSX9Util():SearchX9Paths( 'T92', 'T92', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T92' .and. x[3] == 'T92' .and. alltrim(x[2]) = 'T92_PENALI'  } ) > 0
					EndIf

					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "T1U_NOME", "X3_VISUAL" ) ) <> 'A'
							lAchou := .T.
						EndIf
					EndIf
					
					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "T92_DTRABA", "X3_BROWSE" ) ) <> 'S'
							lAchou := .T.
						EndIf
					EndIf
					
					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "T3V_PERAPU", "X3_VALID" ) ) <> 'xFunVldUni("T3V",4, FWFLDGET("T3V_INDAPU")+M->T3V_PERAPU+"1")'
							lAchou := .T.
						EndIf
					EndIf
					
					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "C9W_OBS   ", "X3_ORDEM" ) ) <> '17'
							lAchou := .T.
						EndIf
					EndIf
					
					If !lAchou
						If AllTrim( Posicione( "SX3", 2, "C9W_DESPRO", "X3_ORDEM" ) ) <> '07'
							lAchou := .T.
						EndIf
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CM0_DNATLE", "X3_FOLDER" ) ) == '3'
							lAchou := .F.
						Else
							lAchou := .T.
						EndIf
					endif

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CM0_NATLES", "X3_FOLDER" ) ) == '3'
							lAchou := .F.
							
						Else
							lAchou := .T.
						EndIf
					endif

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CM0_DESLES", "X3_TITULO" ) ) == 'Comp.Lesão' .Or. AllTrim( Posicione( "SX3", 2, "CM0_DESLES", "X3_ORDEM" ) ) == '52'
							lAchou := .F.
						Else
							lAchou := .T.
						EndIf
					endif
					
					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "C91_NOMEV", "X3_INIBRW" ) ) == "TafGetNome(C91->C91_FILIAL,C91->C91_TRABAL,C91->C91_NOME,'C91',C91->C91_CPF)"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						if ( AllTrim( Posicione( "SX3", 2, "C91_DTRABA", "X3_RELACAO" ) ) ) == 'TAFNMTRAB(XFILIAL("C9V"),M->C91_TRABAL,"S1200")'
							lAchou := .F.
						Else	
							lAchou := .T.								
						EndIf			
					EndIf			
					// DESERTAF1-18282
					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "C91_NISV", "X3_INIBRW" ) ) == "TafGetNIS(C91->C91_FILIAL, C91->C91_TRABAL, 'C91')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CM6_NISV", "X3_INIBRW" ) ) == "TafGetNIS(CM6->CM6_FILIAL, CM6->CM6_FUNC, 'CM6')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CM8_NISV", "X3_INIBRW" ) ) == "TafGetNIS(CM8->CM8_FILIAL, CM8->CM8_TRABAL, 'CM8')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CMD_CPFV", "X3_INIBRW" ) ) == "TafGetCPF(CMD->CMD_FILIAL, CMD->CMD_FUNC, , 'CMD')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "CMD_MATV", "X3_INIBRW" ) ) == "TafGetMatr(CMD->CMD_FILIAL, CMD->CMD_FUNC, CMD->CMD_ID, CMD->CMD_VERSAO, ,'CMD')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "T3P_MATV", "X3_INIBRW" ) ) == "TafGetMatr(T3P->T3P_FILIAL, T3P->T3P_BENEFI, T3P->T3P_ID, , T3P->T3P_CPF, 'T3P')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf
					
					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "T3P_NISV", "X3_INIBRW" ) ) == "TafGetNIS(T3P->T3P_FILIAL, T3P->T3P_BENEFI, 'T3P', T3P->T3P_CPF)"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "T92_NISV", "X3_INIBRW" ) ) == "TafGetNIS(T92->T92_FILIAL, T92->T92_TRABAL, 'T92')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf
					
					if !lAchou
						If AllTrim( Posicione( "SX3", 2, "T92_DTRABA", "X3_INIBRW" ) ) == "TafGetNome(T92->T92_FILIAL,  T92->T92_TRABAL, , 'T92')"
							lAchou := .F.						
						Else
							lAchou := .T.
						EndIf					
					EndIf

					If !lAchou
						lAchou := ( Alltrim( Posicione( "SX3", 2, "C5M_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C5M","C5M_ID",,3)' )
					EndIf

					If !lAchou
						lAchou := ( Alltrim( Posicione( "SX3", 2, "C0R_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C0R","C0R_ID",,6)' )
					EndIf

					if !lAchou
						cInfo := "Executado"
					endif

				endif
			endif

		Case "P12123" $ cUpdate
			If !lAchou
				lAchou := !(AllTrim( Posicione( "SX3", 2, "C91_NOME", "X3_VISUAL" ) ) == "A")
			Endif
			
			if !lAchou
				lAchou := !(( AllTrim( Posicione( "SX3", 2, "C91_DTRABA", "X3_RELACAO" ) ) ) == 'TAFNMTRAB(XFILIAL("C9V"),M->C91_TRABAL,"S1200")')	
			EndIf

			if !lAchou
				cSep	:= "' - '"
				lAchou := !(AllTrim( Posicione( "SX3", 2, "C9P_DESTAB", "X3_RELACAO" ) ) == 'IF(!INCLUI.AND.!EMPTY(C9P->C9P_ESTABE),Posicione( "C92", 1, xFilial("C92")+C9P->C9P_ESTABE, "C92_TPINSC+'+cSep+'+C92_NRINSC"),"")')
			EndIf

			If !lAchou
				lAchou := !(AllTrim( Posicione( "SX3", 2, "T3R_NRARQ ", "X3_OBRIGAT" ) ) == '')
			EndIf
			
			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_RELACAO" ) ) != 'TafRelCtC("T0O_IDCC",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_F3" ) ) != 'C1OA' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_VALID" ) ) != 'TafVldCtC("C1O",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C5M_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C5M","C5M_ID",,3)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_DCONTC", "X3_RELACAO" ) ) != 'TafRelCtC("T0O_IDCC",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C0R_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C0R","C0R_ID",,6)' )
			EndIf

			if !lAchou
				cInfo := "Executado"
			endif


		Case "P12125" $ cUpdate
			If !lAchou
				//Protecao dessa atualizacao para o tsi, ja que o pacote ainda nao foi disponibilizado e com isso a execucao do UpdTaf fica pendente mesmo apos ser processada.
				if FindFunction("Ws034Dipa")
					lAchou := ( Alltrim( Posicione( "SX3", 2, "C30_DCDIPA", "X3_RELACAO" ) ) != 'iif(FWIsInCallStack("Ws034Dipa"),Ws034Dipa(),"Sem Descrição Disponível")' )
				else
					lAchou := ( Alltrim( Posicione( "SX3", 2, "C30_DCDIPA", "X3_RELACAO" ) ) != 'Iif(!INCLUI .and. !Empty(C30->C30_CODIPA),Posicione("LF0",1,xFilial("LF0")+C30_CODIPA,"trim(LF0_CODIGO)+' + "' - '" + '+LF0_DESCRI"),"")' )
				endif
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T36_DESDIS", "X3_RELACAO" ) ) != 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODI),POSICIONE("T37",1,XFILIAL("T37")+T36->T36_IDCODI,"T37_DESCRI"),"")' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T36_DESLOC", "X3_RELACAO" ) ) != 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODL),POSICIONE("C07",3,XFILIAL("C07")+T36->T36_IDCODL,"C07_DESCRI"),"")' )
			EndIf
			
			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_RELACAO" ) ) != 'TafRelCtC("T0O_IDCC",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_F3" ) ) != 'C1OA' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_CODCC", "X3_VALID" ) ) != 'TafVldCtC("C1O",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T0O_DCONTC", "X3_RELACAO" ) ) != 'TafRelCtC("T0O_IDCC",1)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C0R_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C0R","C0R_ID",,6)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C5M_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C5M","C5M_ID",,3)' )
			EndIf

			if !lAchou
				cInfo := "Executado"
			endif

		Case "P12127" $ cUpdate

			If !lAchou
				//Protecao dessa atualizacao para o tsi, ja que o pacote ainda nao foi disponibilizado e com isso a execucao do UpdTaf fica pendente mesmo apos ser processada.
				if FindFunction("Ws034Dipa")
					lAchou := ( Alltrim( Posicione( "SX3", 2, "C30_DCDIPA", "X3_RELACAO" ) ) != 'iif(FWIsInCallStack("Ws034Dipa"),Ws034Dipa(),"Sem Descrição Disponível")' )
				else
					lAchou := ( Alltrim( Posicione( "SX3", 2, "C30_DCDIPA", "X3_RELACAO" ) ) != 'Iif(!INCLUI .and. !Empty(C30->C30_CODIPA),Posicione("LF0",1,xFilial("LF0")+C30_CODIPA,"trim(LF0_CODIGO)+' + "' - '" + '+LF0_DESCRI"),"")' )
				endif
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C0R_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C0R","C0R_ID",,6)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C5M_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C5M","C5M_ID",,3)' )
			EndIf
	
			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C2T', 'C2U', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C2T' .and. x[3] == 'C2U' .and. alltrim(x[2]) == 'C2T_ID+C2T_CODAJU'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C2T', 'C2V', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C2T' .and. x[3] == 'C2V' .and. alltrim(x[2]) == 'C2T_ID+C2T_CODAJU'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C3K', 'C3L', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C3K' .and. x[3] == 'C3L' .and. alltrim(x[2]) == 'C3K_ID+C3K_CODAJU'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C3K', 'C3M', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C3K' .and. x[3] == 'C3M' .and. alltrim(x[2]) == 'C3K_ID+C3K_CODAJU'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C4A', 'CA9', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C4A' .and. x[3] == 'CA9' .and. alltrim(x[2]) == 'C4A_ID+C4A_INDAJU+C4A_CAJAPC'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'CAD', 'CAE', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'CAD' .and. x[3] == 'CAE' .and. alltrim(x[2]) == 'CAD_ID+CAD_CTA'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'CAF', 'CAG', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'CAF' .and. x[3] == 'CAG' .and. alltrim(x[2]) == 'CAF_ID+CAF_CTA'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'LEG', 'LEH', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'LEG' .and. x[3] == 'LEH' .and. alltrim(x[2]) == 'LEG_FILIAL+LEG_ID'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'LEG', 'LEQ', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'LEG' .and. x[3] == 'LEQ' .and. alltrim(x[2]) == 'LEG_FILIAL+LEG_ID'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'LEM', 'T5M', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'LEM' .and. x[3] == 'T5M' .and. alltrim(x[2]) == 'LEM_IDPART+LEM_NUMERO'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'T68', 'T69', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T68' .and. x[3] == 'T69' .and. alltrim(x[2]) == 'T68_ID'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'T9G', 'T9H', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T9G' .and. x[3] == 'T9H' .and. alltrim(x[2]) == 'T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'T9G', 'T9I', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T9G' .and. x[3] == 'T9I' .and. alltrim(x[2]) == 'T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'  } ) > 0
			EndIf

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'T37', 'T36', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'T37' .and. x[3] == 'T36' .and. alltrim(x[2]) == 'T37_ID' } ) > 0
			EndIf  

			If !lAchou
				lAchou := FwSX9Util():SearchX9Paths( 'C6G', 'C7D', @aRelacao ) .and. aScan( aRelacao, { |x| x[1] == 'C6G' .and. x[3] == 'C7D' .and. alltrim(x[2]) == 'C6G_FILIAL+C6G_ID+DTOS(C6G_DTMOV)' } ) > 0
			EndIf  

			If !lAchou //devera apagar X3_F3 = T9CA , devera ficar vazio apos execucao
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T95_TPNUOB", "X3_F3" ) ) == 'T9CA' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SXA", 1, "T62", "XA_ALIAS" ) ) == 'T62' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "CM0_DCODSI", "X3_RELACAO" ) ) != 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")' )													
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C0A_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C0A","C0A_ID",,3)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C2S_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C2S","C2S_ID",,2)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "C3J_ID", "X3_RELACAO" ) ) != 'GetSx8Num("C3J","C3J_ID",,2)' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOMEV", "X3_RELACAO" ) ) != 'IIf(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")' )													
			EndIf
			
			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOMEV", "X3_INIBRW" ) ) != 'TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P")' )													
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX7", 1, PadR("T36_CODLOC",10) + "001", "X7_SEQUENC" ) ) ) != "" 													
			EndIf
			
			If !lAchou
				lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_RELACAO")) != 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'												
			EndIf

			If !lAchou
				lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_INIBRW")) != 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'												
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITULO")) != "Pag. Per Apu"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITSPA")) != "Pago Per Cal"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITENG")) != "Cal Per. Pay"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCRIC")) != "Info. Pagto. Per. Apur."
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCSPA")) != "Info. Pago Per Calculo"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCENG")) != "Info. Calc. Period Pay"
			EndIf

			If !lAchou
				cInfo := "Executado"
			EndIf

		Case "P12133" $ cUpdate

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SXA", 1, "T62", "XA_ALIAS" ) ) == 'T62' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "CM0_DCODSI", "X3_RELACAO" ) ) != 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")' )
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOMEV", "X3_RELACAO" ) ) != 'IIf(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")' )													
			EndIf
			
			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOMEV", "X3_INIBRW" ) ) != 'TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P")' )													
			EndIf

			If !lAchou
				lAchou := ( Alltrim( Posicione( "SX7", 1, PadR("T36_CODLOC",10) + "001", "X7_SEQUENC" ) ) ) != "" 													
			EndIf

			If !lAchou
				lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_RELACAO")) != 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'												
			EndIf

			If !lAchou
				lAchou := Alltrim(Posicione("SX3", 2, "V72_DFUNC", "X3_INIBRW")) != 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'												
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITULO")) != "Pag. Per Apu"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITSPA")) != "Pago Per Cal"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_TITENG")) != "Cal Per. Pay"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCRIC")) != "Info. Pagto. Per. Apur."
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCSPA")) != "Info. Pago Per Calculo"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "CUO_PAGDIV", "X3_DESCENG")) != "Info. Calc. Period Pay"
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "T2G_CPFTRA", "X3_TITULO")) != "CPF Trab."
			EndIf

			If !lAchou
				lAchou := AllTrim(Posicione("SX3", 2, "T2G_CPFBEN", "X3_TITULO")) != "CPF Ben."
			EndIf
			
			If !lAchou
				cInfo := "Executado"
			EndIf

	EndCase
	
	If cUpdate $ "P12133|P12127|P12125|P12123|P12117"
	
		If !lAchou 
			lAchou := ( Alltrim( Posicione( "SX7", 1, PadR("CM9_FUNC",10) + "002","X7_SEQUENC"))) != ""
		EndIf

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SX3", 2, "T3P_NOME", "X3_RELACAO" ) ) != 'TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210")' )													
		EndIf

		If !lAchou
			lAchou := ( Alltrim( Posicione( "SX3", 2, "CM0_DTRABA", "X3_RELACAO" ) ) != 'IIF(!INCLUI .AND. !EMPTY(CM0->CM0_TRABAL),TAFNMTRAB(XFILIAL("C9V"),M->CM0_TRABAL,"S2210"),"")' )													
		EndIf
				
		If lAchou
			cInfo:="Pendente"
		EndIf

	EndIf 

Return( cInfo )

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFProcUpd
Função que processa as atualizações, chamando as funções já alteradas do
RUP_TAF.

@param		aListUpd	-	Lista de atualizações que devem ser executadas
@param		aEmpresas	-	Empresas que devem ser processadas
@param		aUpdTask	-	Array que contém um resumo das atualizações, para ser visualizado
							pelo usuário na função showLog()
@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function TAFProcUpd( aListUpd, aEmpresas , aUpdTask )

	local	nUpd		as	numeric
	local	nFSx		as	numeric
	local	nEmpresa	as	numeric

	local	aFuncSx			as	array

	default aListUpd	:=	{}
	default aEmpresas	:=	{}
	default aUpdTask	:=	{}

	nUpd		:=	0
	nEmpresa	:=	0
	nFSx		:=	0
	aFuncSx		:=	{ 'FAtuTafSX1' , 'FAtuTafSIX' , 'FAtuTafSX2', 'FAtuTafSX3' , 'FAtuTafSX7' , 'FAtuTafSXA', 'FAtuTafSXB' , 'FAtuTafSX9' , 'FAtuTafHlp' }

	setTopMemoMega()

	for nEmpresa := 1 To Len( aEmpresas )

		if ( aEmpresas[ nEmpresa , 1 ] ) .and. ( lOpen := updOpenSM0( , .F.) )

			SM0->( dbGoTo( aEmpresas[ nEmpresa , 5 ] ) )
			rpcSetType( 3 )
			rpcSetEnv( SM0->M0_CODIGO , SM0->M0_CODFIL ,,, "TAF" )

			for nUpd := 1 to len( aListUpd )
				if aListUpd[ nUpd , 1 ]
					for nFSx := 1 to len ( aFuncSx )
						&( 'staticCall( RUPTAF , ' + aFuncSx[ nFSx ] + ' , ' + aListUpd[ nUpd , 5 ] + ' , @aUpdTask ) ' )
					next nFSx
				endif
			next nUpd

		endif

		rpcClearEnv()

	next nEmpresa

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} showLog
Função que mostra um resumo das atualizações ao usuário

@param		aUpdTask	-	Array que contém um resumo das atualizações

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function showLog( aUpdTask )

	local	oDlgMsg		as	object
	local	nLin		as	numeric
	local	nCol		as	numeric
	local	nx			as	numeric
	local	aColSize	as	array

	default aUpdTask	:=	{}

	nLin			:=	420
	nCol			:=	720
	nx := 1
	aColSize	:=	{ 30 , 20 , 50 , 50 , 190 }
	cTxtIntro := "<table width='100%' border=0.5>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'>< size='+1'>"
	cTxtIntro += "Resumo de atualizações realizadas pelo Compatibilizador." + "</font></td>"
	cTxtIntro += "<tr>"
	cTxtIntro += "<td colspan='2'>< size='+1'><br>"+ "Verifique abaixo a lista de atualizações realizadas nas empresas selecionadas.<br>"
	cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
	cTxtIntro += "</font></td>"
	cTxtIntro += "</tr>
	cTxtIntro += "</table>

	DEFINE MSDIALOG oDlgMsg TITLE "Update - TOTVS Automação Fiscal" FROM 00,00 TO 500,700 PIXEL

	TSay():new(005,005,{|| cTxtIntro },oDlgMsg,,,,,,.T.,,,340,200,,,,.T.,,.T.)

	oListUpd := TWBrowse():new(	40,07,335,162,,{ 'Empresa','Arq..','Chave','Campo(Dic.)','Conteúdo após atualização'},aColSize,oDlgMsg,,,,,,,,,,,,,"ARRAY",.T.,,,,.T.)

	oListUpd:SetArray( aUpdTask )
	oListUpd:bLine := {|| { aUpdTask[oListUpd:nAT,1],aUpdTask[oListUpd:nAT,2],aUpdTask[oListUpd:nAT,3],aUpdTask[oListUpd:nAT,4],aUpdTask[oListUpd:nAT,5] } }

	oBtn1 := tButton():new( 210,005, "Finalizar" , oDlgMsg,{|| __quit() },075,015,,,,.T.,,,,,,)

	oBtn1:SetCss("color:black }")

	activate MSDIALOG oDlgMsg centered

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} setTopMemoMega
Função que atualiza a chave topmemomega no appserver.ini

@author		Luccas Curcio
@since		29/11/2016
@version	1.0

/*/
//----------------------------------------------------------------------
static function setTopMemoMega()

	if ( getSrvProfString( 'TOPMEMOMEGA' , '0' ) ) == '0'
		writeSrvProfString( 'TOPMEMOMEGA' , '1' )
	endif

return
