#INCLUDE "FINA191.CH"
#Include "PROTHEUS.CH"

Static __cPicVal := Nil
       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Fina191  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 11.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastrar cheques recebidos                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fina191(nPosArotina,lAutomato)
Local lPanelFin := IsPanelFin()
Local cFiltro   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	  ³
//³ ----------- Elementos contidos por dimensao ------------	  ³
//³ 1. Nome a aparecer no cabecalho 									  ³
//³ 2. Nome da Rotina associada											  ³
//³ 3. Usado pela rotina													  ³
//³ 4. Tipo de Transa‡„o a ser efetuada								  ³
//³	 1 -Pesquisa e Posiciona em um Banco de Dados				  ³
//³	 2 -Simplesmente Mostra os Campos								  ³
//³	 3 -Inclui registros no Bancos de Dados						  ³
//³	 4 -Altera o registro corrente									  ³
//³	 5 -Exclui um registro cadastrado								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina		:= MenuDef()       					
Private aFlagCTB	:= {}
Private lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)

// Controla saldo na compensacao do cheque
cCadastro := STR0006 //"Cadastro de cheques recebidos"

If GetMv("MV_SLDBXCR") == "C"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega funcao Pergunte												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey (VK_F12,{|a,b| Pergunte("FIN191",.T.)})
	Pergunte("FIN191",.F.)
Endif	

// Ponto de entrada para manipilar aRotina
If ExistBlock( "FA191ROT" )
	aRotinaTmp := ExecBlock( "FA191ROT", .F., .F., { aRotina } )
	If ValType( aRotinaTmp ) == "A"
		aRotina := aClone( aRotinaTmp )
	EndIf
EndIf

cCompCab  := "F191CompGrv" // Complemento de gravacao
aACho  := {	"EF_BANCO", "EF_AGENCIA", "EF_CONTA", "EF_NUM", "EF_VALOR", "EF_VALORBX",;
				"EF_EMITENT","EF_DATA","EF_VENCTO","EF_ALINEA1","EF_DTALIN1",;
				"EF_ALINEA2","EF_DTALIN2","EF_DTREPRE","EF_CLIENTE", "EF_LOJACLI",;
				"EF_TEL", "EF_RG","EF_PREFIXO","EF_TITULO","EF_PARCELA","EF_TIPO",;
				"EF_CPFCNPJ","EF_HIST"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nPosArotina := 0
If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse		
	dbSelectArea("SEF")
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else                                          
	If !lPanelFin
		dbSelectArea("SEF")
		SEF->( dbSetOrder( 6 ) )
		SEF->( MsSeek( xFilial( "SEF" ) + "R" ) )
	EndIf
	cFiltro := "EF_FILIAL = '" + xFilial("SEF") + "' AND EF_CART = 'R'"
	mBrowse(6,1,22,75,"SEF",,,,,,Fa191Leg("SEF"),,,,,,,,cFiltro)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSetOrder(1)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F191CompGr³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para complementar a gravacao dos dados pela enchoice³±±
±±³          ³ na rotina de cadastro de cheques recebidos.             	  ³±±
±±³          ³ Neste momento o registro esta travado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA191                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION F191CompGrv
SEF->EF_CART := "R"
Return

//---------------------------------------------
/*/{Protheus.doc} NaoExistCh

Verifica se nao existe um cheque para o mesmo titulo com   
mesmo numero de banco+agencia+conta+cheque para evitar  	  
duplicidade no SEF (Utilizada na validacao do campo no SX3).
**Também pesquisa o titulo e o cliente para sugerir os dados.**

@Author	Claudio D. de Souza
@since	29/04/2002
@return lRet, Logical, .T. Nao existe Cheque, .F. Caso contrario
/*/
//---------------------------------------------
Function NaoExistCh() As Logical	
	Local aArea 	As Array
	Local lSldBxCr 	As Logical
	Local lVlTrans	As Logical
	Local aAreaSE1  As Array
	Local cTipo     As Char
	Local lRet 		As Logical
	Local cFilSA1   As Char
	
	//Inicializa variáveis
	aArea    := {}
	lSldBxCr := SuperGetMv("MV_SLDBXCR",,"B") == "C" //Movimento Bancário através da compensação de cheque
	lVlTrans := SuperGetMv("MV_VLTRANS") == 1 		//Valor da compensação considerado no saldo bancário
	aAreaSE1 := {}
	cTipo    := Iif(M->EF_TIPO $ MVRECANT, " ", "R")	
	lRet     := ExistChav("SEF", cTipo + M->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO), 6)
	cFilSA1  := ""
	
	//Se nao existe o cheque, pesquisa o titulo e o cliente para sugerir os dados
	//como codigo do cliente, loja do cliente, emitente e CNPJ para o cheque		
	If lRet .And. !Empty(M->EF_TITULO) .And. !Empty(M->EF_TIPO)
		aArea    := GetArea()
		aAreaSE1 := SE1->(GetArea())
		SE1->(DBSetOrder(1))		
		
		If (lRet := SE1->(MsSeek(xFilial("SE1")+M->EF_PREFIXO+M->EF_TITULO+M->EF_PARCELA+M->EF_TIPO))) .And. SE1->E1_SALDO == 0
			Help(" ",1,"F191TITBX")	      		
			lRet := .F.		   
		EndIf
		
		If lRet 
			DBSelectArea("SA1")
			SA1->(DBSetOrder(1))
			cFilSA1 := xFilial("SA1")
			
			If SA1->(MsSeek(cFilSA1+SE1->(E1_CLIENTE+E1_LOJA)))
				M->EF_CLIENTE := SE1->E1_CLIENTE
				M->EF_LOJACLI := SE1->E1_LOJA
				
				If (Empty(M->EF_EMITENTE) .Or. Empty(M->EF_CPFCNPJ)) .And. SA1->(MsSeek(cFilSA1+M->EF_CLIENTE+M->EF_LOJACLI))
					If Empty(M->EF_EMITENTE)
						M->EF_EMITENTE := SA1->A1_NOME
					EndIf
					
					If Empty(M->EF_CPFCNPJ)
						M->EF_CPFCNPJ := SA1->A1_CGC
					EndIf
				EndIf
			EndIf
		EndIf
		
		RestArea(aAreaSE1)
		RestArea(aArea)
		FwFreeArray(aAreaSE1)
		FwFreeArray(aArea)		
	Endif
Return lRet	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F191Prep  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 05/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prepara a chamada da AdmModelo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA191                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F191Prep(cAlias as Character, nReg as Numeric,nOpc as Numeric,lAutomato as Logical)
Local lPanelFin 	As Logical
Local lF191AltCh	As Logical
Local nTamChD		As Numeric

PRIVATE aCols		As Array
PRIVATE aHeader		As Array
PRIVATE lUsaBes		As Logical

lPanelFin := IsPanelFin()
lF191AltCh := ExistBlock( "F191ALTCH" )
nTamChD		:= TamSX3("EF_CHDEVOL")[1]

aCols		:= {}
aHeader		:= {}
lUsaBes		:= If(lPanelFin, .F., .T.)

DEFAULT	lAutomato:= .F.

If nOpc == 3 // Habilita o botao para leitura de CMC7 apenas na inclusao
	If GetMv("MV_CMC7FIN") == "S" .And. !IsPlugin()
		OpenCMC7()
		aButBar := {{'COLINC',{||	F070Cmc7(,.F.,	@M->EF_BANCO,@M->EF_AGENCIA,@M->EF_CONTA,;
																@M->EF_NUM,@M->EF_VALOR,0,@M->EF_EMITENT,;
																@M->EF_DATA,@M->EF_VENCTO,@M->EF_CPFCNPJ,;
																@M->EF_TEL,@M->EF_HIST)},STR0007,STR0035}} //"Ler cheques" //"CMC7"
	Endif
Endif
If nOpc == 5	//O cheque nao podera ser excluido, se o titulo vinculado a ele ja estiver baixado
	dbSelectArea("SE1")
	dbSetOrder(1)
	If MsSeek(xFilial("SE1")+SEF->EF_PREFIXO+SEF->EF_TITULO+SEF->EF_PARCELA+SEF->EF_TIPO)
		If SE1->E1_VALOR != SE1->E1_SALDO .and. F191BxCh()
			Help(" ",1,"EXCHEQUE",,STR0036+CRLF+STR0037,1,0)	//"Este cheque não pode ser excluído, pois "###"está vinculado a um título que já foi baixado."
			Return .F.
		EndIf
	EndIf
EndIf


If nOpc ==4 // O cheque não poderá ser alterado caso já esteja compensado
	If !Empty(SEF->EF_DTCOMP)
		IW_MSGBOX(STR0011 + DTOC(SEF->EF_DTCOMP), STR0010, "STOP") //"Este cheque já foi compensado em "###"Atenção"
		Return .F.
    Endif
    IF lF191AltCh
		IF !(ExecBlock( "F191ALTCH", .F., .F.))
	  		Return .F.
		EndIf
	EndIf
Endif


cTudoOk := "FA191TudoOk"
If AdmModelo(cAlias,nReg,nOpc,lAutomato) == 1
	If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5
		If Empty(SEF->EF_ORIGEM)
			Reclock("SEF",.F.)
			SEF->EF_ORIGEM := "FINA191"		
			MsUnlock()
		EndIf
		//Preenchimento da EF_FILORIG, ajuste para contabilizar pelo CTBAFIN Utilizando a LP559 considerando a Filial original
		If Empty(SEF->EF_FILORIG)
			Reclock("SEF",.F.)
			SEF->EF_FILORIG := cFilAnt 	
			MsUnlock()
		Endif	
		//preenche EF_CHDEVOL de acordo com input de devolução de cheques.
		if !Empty(SEF->EF_ALINEA1) .OR. !Empty(SEF->EF_ALINEA2) 
			if Alltrim(SEF->EF_CHDEVOL) <> "S"
				Reclock("SEF",.F.)
				SEF->EF_CHDEVOL := Padr("S",nTamChD)
				MsUnlock()
			endif
		elseif !Empty(SEF->EF_CHDEVOL)
			Reclock("SEF",.F.)
			SEF->EF_CHDEVOL := Space(nTamChD)
			MsUnlock()	
		endif	

		If ExistBlock("FA191GRV")
			ExecBlock("FA191GRV",.F.,.F.)
		Endif
	Endif	
Endif	
If GetMv("MV_CMC7FIN") == "S" .And. !IsPlugin()
   CMC7Fec(nHdlCMC7,GetMv("MV_CMC7PRT"))
EndIF
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F191Comp	  ³ Autor ³ Claudio D. de Souza ³ Data ³ 06.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a compensacao de um cheque recebido					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F191Comp(cAlias, nRec,  nOpc, lAutomato)
	Local cBanco        := ""
	Local cAgencia      := ""
	Local cConta        := ""
	Local dDtComp		:= dDataBase
	Local oDlg          := Nil
	LOCAL oBold         := Nil
	Local cBancoCh      := ""
	Local cAgenciaCh    := ""
	Local cContaCh      := ""
	Local cNumCh        := ""
	Local nOpcA         := 0
	Local aArea			:= GetArea()
	Local aAreaSef		:= SEF->(GetArea())
	Local aAreaSE5		:= SE5->(GetArea())
	Local cPadrao		:= "559"
	Local lPadrao		:= VerPadrao(cPadrao)
	Local nTotal		:= 0
	Local nHdlPrv		:= 0
	Local cArquivo   
	Local lF191VldCmp 	:= ExistBlock("F191VLDCMP")
	Local lRet			:= .T.
	Local lF191AltBco	:= ExistBLock("F191ALTBCO")
	Local aAltBco		:=	{}
	Local nReg          := 0
	Local lF191REGCMP   := ExistBlock("F191REGCMP")
	Local cChaveSEF     := ""
	Local lBxDtFin      := SuperGetMv("MV_BXDTFIN",,"1") == "2"
	Local lLoja         := .F.
	Local lSldBxCr      := SuperGetMv("MV_SLDBXCR",,"B") == "C"
	Local cChaveBco     := ""
	Local lFINA460      := FunName() <> "FINA460"
	Local cSinal        := ""
	Local cMovSEF       := "" 
	Local lCobDesc      := .F.
	Local cSequenc      := ""
	Local cHistMov      := ""
	Local cTblTmp       := ""
	Local lSpbinUse		:=SpbinUse()
	
	PRIVATE cLoteFin := Space(4)
	PRIVATE cLote
	DEFAULT lAutomato := .F.
	
	LoteCont("FIN")
	
	Do Case
	Case SEF->EF_CART != "R"
		IW_MSGBOX(STR0009, STR0010, "STOP") //"Este cheque não pertence ao contas a receber, nao pode ser compensado"###"Atenção"
	Case !Empty(SEF->EF_DTCOMP)
		IW_MSGBOX(STR0011 + DTOC(SEF->EF_DTCOMP), STR0010, "STOP") //"Este cheque já foi compensado em "###"Atenção"
	Case !Empty(SEF->EF_DTALIN2)
		IW_MSGBOX(STR0012 + DTOC(SEF->EF_DTALIN2), STR0010, "STOP") //"Este cheque já foi devolvido pela segunda vez em "###"Atenção"
	Case !F191VldCh(1)
		IW_MSGBOX(STR0041, STR0010, "STOP")//"Já existe(m) cheque(s) compensado(s) vinculado(s) a esse título!"###"Atenção"
	Case !F191VldCh(2)
		IW_MSGBOX(STR0026+Chr(13)+Chr(10)+STR0027,STR0010, "STOP") //"O titulo referente a este cheque não foi baixado ainda."###"Não é permitida a compensação sem que o titulo tenha sido baixado"	
	OtherWise
		SE1->(DbSetOrder(1))
		SE1->(MsSeek(xFilial("SE1")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)))
		
		If Empty(SE1->E1_BAIXA) .And. !SE1->E1_TIPO $ MVRECANT
			IW_MSGBOX(STR0026+Chr(13)+Chr(10)+STR0027,STR0010, "STOP") //"O titulo referente a este cheque não foi baixado ainda."###"Não é permitida a compensação sem que o titulo tenha sido baixado"
		Else
			//Busca o banco onde o cheque foi depositado
			SE5->(DbSetOrder(7))
			cMovSEF := xFilial("SE5")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_CLIENTE)
			SE5->(MsSeek(cMovSEF))
			
			While SE5->(!Eof()) .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR) == cMovSEF
				//Encontrou o registro referente ao CHEQUE.		
				If SE5->E5_LOJA == SEF->EF_LOJACLI .And. !SE5->E5_TIPODOC $ "CH|ES" .And. Empty(SE5->E5_SITUACA) .And.;
					Alltrim(SE5->E5_SEQ) == Alltrim(SEF->EF_SEQUENC)
					Exit
				EndIf
				
				SE5->(DbSkip())
			EndDo
			
			If SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR) != cMovSEF
				SE5->(dbSkip(-1))
			Endif
				
			cBanco   := SE5->E5_BANCO
			cAgencia := SE5->E5_AGENCIA
			cConta	 := SE5->E5_CONTA
			
			If lF191AltBco
				aAltBco  :=  ExecBlock("F191ALTBCO",.f.,.f.,{cBanco,cAgencia,cConta})
				cBanco   := aAltBco[1][1]
				cAgencia := aAltBco[1][2]
				cConta   := aAltBco[1][3]
			EndIf
				
			If !lAutomato
				DEFINE MSDIALOG oDlg FROM 0,0 TO 190,334 TITLE STR0013 Of oMainWnd PIXEL //"Confirmação da compens. de cheque recebido"
				DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
				@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 35,155 NOBORDER WHEN .F. PIXEL
				@ 11 ,35  TO 13 ,400 LABEL '' OF oDlg PIXEL
				@ 3  ,37  SAY STR0014 Of oDlg PIXEL FONT oBold //"Compensação de cheque"
				@ 19,050 SAY STR0015   	OF oDlg PIXEL  //"Banco"
				@ 19,120 MSGET cBanco    OF oDlg PIXEL F3 "SA6" Picture "@S3" Valid CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.) WHEN EMPTY(cBanco) HASBUTTON
				@ 33,050 SAY STR0016	OF oDlg PIXEL     //"Agencia"
				@ 33,120 MSGET cAgencia	OF oDlg PIXEL  WHEN EMPTY(cAgencia)
				@ 47,050 SAY STR0017		OF oDlg PIXEL  //"Conta"
				@ 47,120 MSGET cConta	OF oDlg SIZE 35,9 PIXEL WHEN EMPTY(cConta)
				@ 61,050 SAY STR0018 OF oDlg PIXEL //"Data de Compensação"
				@ 61,120 MSGET dDtComp	OF oDlg SIZE 45,9 PIXEL  HASBUTTON
				
				DEFINE SBUTTON FROM 80,102 TYPE 1 ENABLE OF oDlg ACTION (nOpcA := 1, oDlg:End())
				DEFINE SBUTTON FROM 80,130 TYPE 2 ENABLE OF oDlg ACTION (nOpcA := 0, oDlg:End())
				ACTIVATE MSDIALOG oDlg CENTERED
			Else
				nOpcA := 1
			EndIF
			
			If lBxDtFin .and. !DtMovFin(dDtComp,,"1")
				nOpcA:= 0
			Endif
			
			Begin Transaction
				If nOpcA == 1 .and. lF191VldCmp
					lRet := ExecBlock("F191VLDCMP",.F.,.F.)
				EndIf
				
				If nOpcA == 1 .and. lRet
					If lPadrao .And. MV_PAR01 == 1 // Existe o LP e contabiliza on-line
						nHdlPrv := HeadProva(cLote, "FINA191", Substr(cUsuario,7,6), @cArquivo)
					Endif
					
					If AllTrim(SEF->EF_BANCO) + AllTrim(SEF->EF_AGENCIA) + Alltrim(SEF->EF_CONTA) + alltrim (SEF->EF_NUM) == "..."	.AND. ALLTRIM(SE1->E1_ORIGEM) == "LOJA701" // Se For de origem loja compensa apenas o cheque selecionado
						lLoja := .T.
					Else
						SEF->(DbSetOrder(1))
						// Compensa todos os cheques de mesmo numero,pois um mesmo cheque
						// pode ter sido utilizado no pagto de varios titulos.
						SEF->(MsSeek(xFilial("SEF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)))
					EndIf
					
					cBancoCh   := SEF->EF_BANCO
					cAgenciaCh := SEF->EF_AGENCIA
					cContaCh   := SEF->EF_CONTA
					cNumCh     := SEF->EF_NUM
					VALOR      := 0
					nReg       := SEF->(Recno())
					cChaveSEF  := FWUUIDV4()
					cChaveBco  := xFilial("SEF")+cBancoCh+cAgenciaCh+cContaCh+cNumCh 
					
					While SEF->(!Eof()) .And. SEF->(EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM) == cChaveBco
						lCobDesc := .F.
						
						If SEF->EF_CART != 'R'
							SEF->(DbSkip())
							Loop
						Endif

						If SE1->(MsSeek(xFilial("SE1")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)))
							If !Empty(SE1->E1_SITUACA) .And. FN022SITCB(SE1->E1_SITUACA)[3]
								If !Empty(cTblTmp := F191MovTra(SE1->E1_FILORIG, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO))
									lCobDesc := (cTblTmp)->R_E_C_N_O_ > 0 .And. !Empty((cTblTmp)->E5_SEQ)
									(cTblTmp)->(DbCloseArea())
								EndIf								
							EndIf
						EndIf
						
						//Gera movimento de CH	se o cheque já não tiver sido feito pelo RA	  		
						If lFINA460 .And. !lCobDesc .And. !("RA" $ SE1->E1_TIPO .And. !lSldBxCr)
							cHistMov := STR0019 + SEF->(EF_BANCO+"/"+EF_AGENCIA+"/"+EF_NUM) //"Ch comp - bco/ag/ch "
							//Neste processo e somente nesse processo eu tenho que verificar as sequencias FK1 e FK5
							cSequenc := FinSeqFK1()
							cSeqFK5	 := FinSeqFK5()	

							cSequenc := If(cSequenc > cSeqFK5, cSequenc, cSeqFK5)

							Fa070GrvSe5(cBanco, cAgencia, cConta, dDtComp, SEF->EF_VALORBX, .F., .F., "CH", cHistMov, cLoteFin,;
										"NOR", 0, cSequenc, lSpbinUse, "3", dDtcomp, "", "", 0, 0, 0, 0, 0, 0, {}, "R", 0, Nil, Nil, '', cChaveSEF)
							
							//Atualiza saldo bancario
							AtuSalBco(cBanco,cAgencia,cConta,dDtComp,SEF->EF_VALORBX,"+")
						Endif
						
						SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						cSinal := Iif(SE1->E1_TIPO $ MVRECANT+"|"+MV_CRNEG, "+", "-")
						AtuSalDup(cSinal, SEF->EF_VALORBX, 1, SE1->E1_TIPO, Nil, SE1->E1_EMISSAO)
						
						RecLock("SEF",.F.)
						SEF->EF_DTCOMP := dDtComp
						SEF->EF_IDSEF  := cChaveSEF
						SEF->EF_LIBER  :='S'
						
						If lPadrao .And. MV_PAR01 == 1 //Existe o LP e contabiliza on-line
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd(aFlagCTB, {"EF_LA", "S", "SEF", SEF->(Recno()), 0, 0, 0})
							Else
								SEF->EF_LA := "S"
							EndIf
							
							nTotal += DetProva(nHdlPrv, cPadrao, "FINA191", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/,;
												/*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
						Endif	
							
						SEF->(DbSkip())
							
						If lLoja //Se For de origem loja compensa apenas o cheque selecionado
							lLoja := .F.
							Exit
						EndIf
					EndDo
					
					SEF->(DbGoto(0))
					SE5->(DbGoto(0))
					
					If lF191REGCMP
						ExecBlock("F191REGCMP",.F.,.F., nReg)
					EndIf
					
					VALOR := nTotal
					
					If nTotal > 0 .And. MV_PAR01 == 1 // Existe o LP e contabiliza on-line
						//Contabiliza o total de compensacoes
						nTotal += DetProva(nHdlPrv, cPadrao, "FINA191", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
											/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)
						
						RodaProva(nHdlPrv, nTotal)
						
						//Envia para Lançamento Contabilização
						cA100Incl(cArquivo, nHdlPrv, 3, cLote, mv_par02==1, mv_par03==1, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/)
						aFlagCTB := {}
					Endif
					
					SEF->(RestArea(aAreaSef))
					FwFreeArray(aAreaSef)
				Endif
			End Transaction
			
			SE5->(RestArea(aAreaSe5))
			FwFreeArray(aAreaSe5)
		Endif	
	EndCase
	
	RestArea(aArea)
	FwFreeArray(aArea)
Return Nil

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F191EsComp

Permite o estorno da compensacao de um cheque recebido

@Author	Claudio D. de Souza
@since	24.12.03
/*/
//-----------------------------------------------------------------------------------------------------

Function F191EsComp (cAlias,nReg,nOpc,lAutomato)
	Local cBanco      := ""
	Local cAgencia    := ""
	Local cConta      := ""
	Local dDtComp     := dDataBase
	Local oDlg        := Nil
	LOCAL oBold       := Nil
	Local cBancoCh    := ""
	Local cAgenciaCh  := ""
	Local cContaCh    := ""
	Local cNumCh      := ""
	Local nOpcA       := 1
	Local aAreaSEF	  := {}
	Local aAreaSE5	  := {}
	Local cPadrao 	  := "583"
	Local lPadrao 	  := VerPadrao(cPadrao)
	Local nTotal 	  := 0
	Local nHdlPrv	  := 0
	Local cArquivo    := Nil
	Local nTamSeq     := TamSX3("FK5_SEQ")[1]
	Local cSequencia  := Replicate("0",nTamSeq)
	Local lF191AltEst := ExistBlock("F191ALTEST")
	Local lCtbLizou   := .F. //Verifica se cheque foi contabilizado na compensacao
	Local lF191EstC   := ExistBlock("F191EstC")
	Local lRet        := .T.
	Local lF191ESCHQ  := ExistBlock("F191ESCHQ") 
	Local nEstCompChq := 0
	Local lBxDtFin    := SuperGetMv("MV_BXDTFIN",,"1") == "2"
	Local lLoja       := .F. 	//Variavel de controle que indica se o cheque foi originado do SIGALOJA
	Local lSldBxCr    := SuperGetMv("MV_SLDBXCR",,"B") == "C"
	Local lVlTrans    := SuperGetMv("MV_VLTRANS", .F., 1) == 2
	Local cChavSE5    := ""
	Local cTblTmp     := ""
	Local lTitulo     := .F.
	Local cChaveBco   := ""
	Local cSinal      := ""
	Local cFilSE1     := ""
	Local cFilSE5     := ""
	Local cRegCheque  := ""
	Local nRegTransf  := 0
	Local lMovCheque  := .F.
	Local lSpbinUse	  :=SpbinUse()
	
	PRIVATE cLoteFin  := Space(4)
	PRIVATE cLote
	
	DEFAULT lAutomato := .F.
	
	If lF191EstC
		//Ponto de entrada para validar se permite usuario acessar a opção de estorno de compensacao
		lRet := ExecBlock("F191EstC",.f.,.f.)
		
		If !lRet
			Return 
		EndIf
	EndIf
	
	LoteCont("FIN")
	
	If Empty(SEF->EF_DTCOMP)
		IW_MSGBOX(STR0028+Chr(13)+Chr(10)+STR0033,STR0010, STR0029) //"Cheque não compensado. Somente é permitido o estorno   "###"STOP" //"de compensação de cheques já compensados                         "
	Else
		aAreaSEF := SEF->(GetArea())
		aAreaSE5 := SE5->(GetArea())		
		
		SE1->(DbSetOrder(1))
		SE5->(DbSetOrder(2))
		cChavSE5 := xFilial("SE5")+"CH"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)
		lTitulo  := SE1->(DbSeek(xFilial("SE1", SEF->EF_FILORIG)+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)))
		
		If !SE5->(Dbseek(cChavSE5))   
			If !Empty(cTblTmp := F191MovTra(SEF->EF_FILORIG, SEF->EF_PREFIXO, SEF->EF_TITULO, SEF->EF_PARCELA, SEF->EF_TIPO))			
				nRegTransf := (cTblTmp)->R_E_C_N_O_ 
				(cTblTmp)->(DbCloseArea())
				SE5->(DbGoto(nRegTransf))
			EndIf
		EndIf
		
		cBanco   := SE5->E5_BANCO
		cAgencia := SE5->E5_AGENCIA
		cConta   := SE5->E5_CONTA
		
		//Busca o banco onde o cheque foi depositado	
		SE5->(DbSetOrder(7))
		cChavSE5 := xFilial("SE5")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_CLIENTE)
		
		If nRegTransf == 0 .And. SE5->(MsSeek(cChavSE5))
			While SE5->(!Eof()) .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR) == cChavSE5						
				//Encontrou o registro referente ao cheque.		
				If SE5->E5_TIPODOC == "BA" .and. Empty(SE5->E5_SITUACA) .And. Alltrim(SE5->E5_SEQ) == Alltrim(SEF->EF_SEQUENC)  
					lMovCheque := .T.
					Exit
				EndIf
				
				SE5->(DbSkip())
			EndDo
			
			If lVlTrans .And. lTitulo .And. FN022SITCB(SE1->E1_SITUACA)[3] .And. !lMovCheque
				Help(" ",1,"ROTCHEQUE", Nil, STR0043, 1, 0)
				Return
			EndIf
		EndIf		
		
		If lF191AltEst
			aAltBco  := ExecBlock("F191ALTEST",.f.,.f.,{cBanco,cAgencia,cConta})
			cBanco   := aAltBco[1][1]
			cAgencia := aAltBco[1][2]
			cConta   := aAltBco[1][3]
		EndIf
		
		If !lAutomato
			DEFINE MSDIALOG oDlg FROM 0,0 TO 190,334 TITLE STR0030 Of oMainWnd PIXEL //"Confirmação da estorno de compensação"
			DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
			@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 35,155 NOBORDER WHEN .F. PIXEL
			@ 11 ,35  TO 13 ,400 LABEL '' OF oDlg PIXEL
			@ 3  ,37  SAY STR0031 Of oDlg PIXEL FONT oBold //"Estorno de Compensação"
			@ 19,050 SAY STR0015   	OF oDlg PIXEL  //"Banco"
			@ 19,120 MSGET cBanco 	WHEN .F. OF oDlg PIXEL 
			@ 33,050 SAY STR0016	OF oDlg PIXEL //"Agencia"
			@ 33,120 MSGET cAgencia	WHEN .F. OF oDlg PIXEL
			@ 47,050 SAY STR0017		OF oDlg PIXEL //"Conta"
			@ 47,120 MSGET cConta	WHEN .F. OF oDlg SIZE 35,9 PIXEL
			@ 61,050 SAY STR0018 OF oDlg PIXEL //"Data de Compensação"
			@ 61,120 MSGET dDtComp	WHEN .F. OF oDlg SIZE 45,9 PIXEL HASBUTTON

			DEFINE SBUTTON FROM 80,102 TYPE 1 ENABLE OF oDlg ACTION (nOpcA := 1, oDlg:End())
			DEFINE SBUTTON FROM 80,130 TYPE 2 ENABLE OF oDlg ACTION (nOpcA := 0, oDlg:End())

			ACTIVATE MSDIALOG oDlg CENTERED
		Endif
		
		If lBxDtFin .And. !DtMovFin(dDtComp, Nil, "1")
			nOpcA := 0
		Endif
		
		Begin Transaction
			If nOpcA == 1
						
				If AllTrim(SEF->EF_BANCO) + AllTrim(SEF->EF_AGENCIA) + Alltrim(SEF->EF_CONTA) + alltrim (SEF->EF_NUM) == "..."	.AND. ALLTRIM(SE1->E1_ORIGEM) == "LOJA701" // Se For de origem loja compensa apenas o cheque selecionado
					lLoja := .T.
				Else 
					SEF->(DbSetOrder(6))	//EF_FILIAL, EF_CART, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_NUM, EF_PREFIXO, EF_TITULO, EF_PARCELA, EF_TIPO
					// Se o cheque nao for gerado pelo SIGALOJA
					// Estorna Compensa todos os cheques de mesmo numero,pois um mesmo cheque
					// pode ter sido utilizado no pagto de varios titulos.
					// Se tiver sido gerado pelo SIGALOJA estorna somento o que estiver posicionado
					SEF->(MsSeek(xFilial("SEF")+"R"+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)))
				EndIf
				
				cBancoCh   := SEF->EF_BANCO
				cAgenciaCh := SEF->EF_AGENCIA
				cContaCh   := SEF->EF_CONTA
				cNumCh     := SEF->EF_NUM
				lCtblizou  := IIF(SEF->EF_LA != "S", .F., .T.)
				
				If lPadrao .And. lCtblizou
					nHdlPrv := HeadProva(cLote, "FINA191", Substr(cUsuario,7,6), @cArquivo)
				Endif	
				
				VALOR     := 0
				cChaveBco := xFilial("SEF")+cBancoCh+cAgenciaCh+cContaCh+cNumCh
				SE5->(dbSetOrder(2))
				cFilSE1 := xFilial("SE1")
				cFilSE5 := xFilial("SE5")
				
				While SEF->(!Eof()) .And. SEF->(EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM) == cChaveBco
					
					cChavSE5 := Iif(!lSldBxCr .And. AllTrim(SEF->EF_TIPO) == "RA", "RA", "CH") + SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)
					
					SE1->(MsSeek(cFilSE1+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)))
					nEstCompChq := SEF->(Recno())
					
					If nRegTransf == 0
						SE5->(MsSeek(cFilSE5+cChavSE5))
						nRecSE5    := nRegTransf
						cRegCheque := cFilSE5+"CH"+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)
						
						//-- Localiza ultima sequencia para gerar estorno da cmpensacao do cheque
						If ( nRecSE5:=F191GetE5() ) > 0 //-- Localiza registro do cheque com base no Rastreio de Movimentos (FKA)
							SE5->(dbGoTo(nRecSE5))
							cSequencia := SE5->E5_SEQ
						Else							
							While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == cRegCheque
								If SEF->EF_NUM == SE5->E5_NUMCHEQ 
									cSequencia := SE5->E5_SEQ
									nRecSE5    := SE5->(Recno())
								Endif
								
								SE5->(dbSkip())
							EndDo
						EndIF
						
						cHistMov:= STR0032 + SEF->(EF_BANCO+"/"+EF_AGENCIA+"/"+EF_NUM) //"Est comp - bco/ag/ch "
						SE5->(DbGoTo(nRecSe5))
						
						//Gera movimento de estorno
						Fa070GrvSe5(cBanco,  cAgencia, cConta, dDtComp, SEF->EF_VALORBX, .F., .F., "ES", cHistMov, cLoteFin, "NOR",;
													0, cSequencia, lSpbinUse, "3", dDataBase, "", "", 0, 0, 0, 0, 0, 0, {}, "P")
						//Estorna Saldo bancario							
						AtuSalBco(cBanco,cAgencia,cConta,dDtComp,SEF->EF_VALORBX,"-")
					EndIf
					
					SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					cSinal := Iif(SE1->E1_TIPO $ MVRECANT+"|"+MV_CRNEG, "-", "+")
					AtuSalDup(cSinal, SEF->EF_VALORBX, 1, SE1->E1_TIPO, Nil, SE1->E1_EMISSAO)
					
					//Passa o recno do registro posicionado na SEF após estorno da compensação de cheque.
					If lF191ESCHQ
						ExecBlock("F191ESCHQ",.F.,.F., nEstCompChq)
					EndIf
					
					RecLock("SEF",.F.)
					SEF->EF_DTCOMP := Ctod("")
					SEF->EF_IDSEF  := ""
					SEF->EF_LIBER  := ""
					
					If lPadrao .And. lCtblizou// Existe o LP e contabilizou na compensacao
						//Limpa flag de contabilizacao para permitir contabilizar novamente em uma nova compensacao
						If lUsaFlag  //Armazena em aFlagCTB para atualizar no modulo Contabilo
							aAdd(aFlagCTB, {"EF_LA", " ", "SEF", SEF->(Recno()), 0, 0, 0} )
						Else
							SEF->EF_LA := " "
						EndIf
						
						nTotal += DetProva(nHdlPrv, cPadrao, "FINA191", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
											/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)
					Endif
					
					If lLoja //Se For de origem loja compensa apenas o cheque posicionado
						lLoja := .F.
						Exit
					EndIf
					
					SEF->(DbSkip())
				EndDo
				
				SEF->(DbGoto(0))
				VALOR := nTotal
				
				If nTotal > 0 .And. lPadrao .And. lCtblizou// Existe o LP e contabilizou na compensacao
					//Contabiliza o total de compensacoes
					nTotal += DetProva(nHdlPrv, cPadrao, "FINA191", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
										/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)
					
					RodaProva(nHdlPrv, nTotal)
					
					//Envia para Lançamento Contábil
					cA100Incl(cArquivo, nHdlPrv, 3, cLote, mv_par02==1, mv_par03==1, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )
					aFlagCTB := {}
				Endif
			Endif
		End Transaction
		
		RestArea(aAreaSEF)
		RestArea(aAreaSE5)
		FwFreeArray(aAreaSEF)
		FwFreeArray(aAreaSE5)
	Endif
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa191Leg    ³ Autor ³ Claudio D. de Souza ³ Data ³ 14.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa191Leg( cAlias, nReg )

Local aLegenda := { 	{"BR_VERDE", STR0022 },; //"Cheque não devolvido"
							{"BR_AMARELO", STR0023 },; //"Cheque com uma devolucao"
							{"BR_PRETO", STR0024 },; //"Cheque com duas devoluções"
							{"BR_VERMELHO", STR0025 } } //"Cheque compensado"
Local uRetorno := .T.
Local uRetBkp
Local aLegBkp 
If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { '!Empty(EF_DTCOMP)'	, aLegenda[4][1] } )
	Aadd(uRetorno, { ' Empty(EF_ALINEA1) .and.  Empty(EF_ALINEA2)'	, aLegenda[1][1] } )
	Aadd(uRetorno, { '!Empty(EF_ALINEA1) .and.  Empty(EF_ALINEA2)'	, aLegenda[2][1] } )
	Aadd(uRetorno, { '!Empty(EF_ALINEA1) .and. !Empty(EF_ALINEA2)'	, aLegenda[3][1] } )
	
	If ExistBlock("F191uRetor")
		uRetBkp := uRetorno
		uRetorno := ExecBlock("F191uRetor",.F.,.F.,uRetorno)
		If ValType(uRetorno) <> "A"
			uRetorno := uRetBkp
		Endif
	Endif
Else
	If ExistBlock("F191aLegen")
		aLegBkp := aLegenda
		aLegenda := ExecBlock("F191aLegen", .F., .F., aLegenda)
		If ValType(aLegenda) <> "A"
			aLegenda := aLegBkp
		Endif
	Endif
	BrwLegenda(cCadastro, STR0020,aLegenda) //"Legenda"
Endif

Return uRetorno

Static Function MenuDef()
Local aRotina := {}    

AAdd( aRotina, {STR0001, "AxPesqui", 0, 1,,.F.}) //"Pesquisar"
AAdd( aRotina, {STR0002, "F191Prep", 0, 2}) //"Visualizar"
AAdd( aRotina, {STR0003, "F191Prep", 0, 3}) //"Incluir"
AAdd( aRotina, {STR0004, "F191Prep", 0, 4}) //"Alterar"
AAdd( aRotina, {STR0005, "F191Prep", 0, 5})  //"Excluir"
If GetMv("MV_SLDBXCR") == "C"
	Aadd(aRotina, {STR0008,"F191Comp", 0, 5} ) //"Compensar"
	Aadd(aRotina, {STR0034,"F191EsComp", 0, 5} ) //"Est. Comp."
Endif	
Aadd(aRotina,{STR0048,"CTBC662", 0, 7, ,.F.}) //"Tracker Contábil"
Aadd(aRotina,{STR0020,"Fa191Leg", 0, 6, ,.F.}) //"Legenda"

Return(aRotina)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA191TudoOk

Faz a validação do valor referente a baixa.

@Author	Marcio Menon
@since	15/08/2007
/*/
//-----------------------------------------------------------------------------------------------------

Function FA191TudoOk() as Logical
Local lRet 		As Logical
Local lSldBxCr  As Logical
Local nVlrNom   As Numeric

lRet 		:= .T.
lSldBxCr 	:= SuperGetMv("MV_SLDBXCR",,"B") == "C"
nVlrNom     := M->EF_VALOR

If M->EF_TIPO == MVRECANT .and. lSldBxCr
	HELP(,,"RACHEQ",,STR0050,1,0,,,,,,{STR0051})					//"zero e menor ou igual ao valor nominal."
	lRet := .F.
EndIf

If (M->EF_VALORBX == 0 .Or. M->EF_VALORBX > M->EF_VALOR)
	HELP(' ',1,"F191VLRBX",,	STR0038+Chr(13)+Chr(10)+;			//"Favor informar um valor referente a"
										STR0039+Chr(13)+Chr(10)+;	//"baixa. Este valor tem que ser maior que"
										STR0040,1,0)				//"zero e menor ou igual ao valor nominal."
	lRet := .F.
EndIf

If lRet .And. F191ExisCh(M->EF_BANCO, M->EF_AGENCIA, M->EF_CONTA, M->EF_NUM, @nVlrNom, .T.)
	If nVlrNom != M->EF_VALOR
		If !IsBlind()
			lRet := MsgYesNo( STR0054 + alltrim(transform(nVlrNom, "@E 999,999,999.99")) + STR0055 + alltrim(transform(M->EF_VALOR,"@E 999,999,999.99")) + STR0056, STR0010 ) //"Existem lançamentos em que o valor nominal deste cheque está diferente. Valor nominal: "  ### ". Deseja atualizar o valor de todos os lançamentos para: " ### "? " ### "Atenção"
		EndIf
		
		If lRet 
			F191AtuChq(M->EF_BANCO, M->EF_AGENCIA, M->EF_CONTA, M->EF_NUM, M->EF_VALOR)
		EndIf
	EndIf
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA191T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA191T(aParam)
	cRotinaExec := "FINA191"	
	ReCreateBrow("SEF",FinWindow)      		
	FinA191(aParam[1])
	ReCreateBrow("SEF",FinWindow)      	
	dbSelectArea("SEF")
	
	INCLUI := .F.
	ALTERA := .F.
	
Return .T.	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F191BxCh º Autor ³ Adrianne Furtado   º Data ³  10/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se há baixa para esse cheque onde está posicionadoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cheques Recebidos	                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F191BxCh()
Local lRet := .F.
Local aAreaSE5 := SE5->(GetArea())
Local lBxComp := GetMv("MV_SLDBXCR") == "C"

dbSelectArea("SE5")
SE5->(dbSetOrder(7))      
SE5->(MsSeek(xFilial("SE5")+SEF->EF_PREFIXO+SEF->EF_TITULO+SEF->EF_PARCELA+SEF->EF_TIPO))
While SE5->(!Eof()) .And.;
		SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) ==;
		xFilial("SE5")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)
	If IIf(lBxComp, SE5->E5_TIPODOC == "BA",.T.) .and. SE5->E5_SITUACA <> "C" .and. Alltrim(SE5->E5_SEQ) == Alltrim(SEF->EF_SEQUENC)
		If SEF->EF_USADOBX == "S"    //pode verificar amarração E5_SEQ x EF_SEQUENC
			lRet := .T.
		Endif	
	EndIf
	
	SE5->(DbSkip())
EndDo
                                 
RestArea(aAreaSE5)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F191VldCh ºAutor  ³ Pedro Pereira Lima º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o cheque que está sendo compensado não tem       º±±
±±º          ³ amarração com um título que já tem cheque amarrado e que   º±±
±±º          ³ sofreu compensação anteriormente.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA19 - F191Comp                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F191VldCh(nVld)
Local aArea    := GetArea()
Local aAreaSEF := SEF->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local lRet     := .T.         
Local nTotCh   := 0                                                                                                                                           
Local nVlrBx   := 0                                                                                                                                           
Local lTemChCmp:= .F. 
Local cChequePos :=""

//Verifico se o titulo amarrado a este cheque foi baixado completamente
dbSelectArea("SE1")
SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If SE1->(dbSeek(xFilial("SE1")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO)))
	If nVld == 1
		//Titulo baixado completamente 
		If SE1->E1_SALDO == 0  
			cChequePos := SEF->EF_NUM
			//Verifico se esse título possui amarracao com um ou mais cheques
			dbSelectArea("SEF")
			SEF->(dbSetOrder(3))//EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
			If SEF->(dbSeek(xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				//Se encontrou o cheque(s), verifico se o(s) mesmo(s) foi(foram) compensado(s)
				While !SEF->(Eof()) .And. SEF->(EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) == xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
				    
					If cChequePos == SEF->EF_NUM
						If !lTemChCmp
							lTemChCmp := !Empty(SEF->EF_DTCOMP)
						EndIf
						nVlrBx := Iif((!Empty(SEF->EF_VALORBX) .And. SEF->EF_VALOR <> SEF->EF_VALORBX) , SEF->EF_VALORBX, SEF->EF_VALOR)
						If nVlrBx + nTotCh > SE1->E1_VALOR .And. lTemChCmp
							lRet := .F.
							Exit
						EndIf
						Exit
					Endif

					SEF->(dbSkip())
				EndDo
			EndIf
		EndIf    
	Else
		//Se título em aberto, o valor do cheque a ser compensado não pode ser maior que o saldo do título
		If SE1->E1_SALDO > 0 .And. ! SE1->E1_TIPO $ MVRECANT
			dbSelectArea("SEF")
			SEF->(dbSetOrder(3))//EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
			If SEF->(dbSeek(xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				//Se encontrou o cheque(s), verifico se o(s) mesmo(s) foi(foram) compensado(s)
				While !SEF->(Eof()) .And. SEF->(EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) == xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
					If !lTemChCmp
						lTemChCmp := !Empty(SEF->EF_DTCOMP)
					EndIf
					//o retorno deverá ser absoluto, pois quando há baixa parcial com taxa de permanencia o E1_SALDO fica maior que E1_VALOR
					nVlrBx := Iif((!Empty(SEF->EF_VALORBX) .And. SEF->EF_VALOR <> SEF->EF_VALORBX) , SEF->EF_VALORBX, SEF->EF_VALOR)
					If (nVlrBx + nTotCh) > ABS(SE1->E1_VALOR - SE1->E1_SALDO) .And. lTemChCmp
						lRet := .F.
						Exit
					EndIf
					nTotCh += IIf(Empty(SEF->EF_DTCOMP),0,nVlrBx)

					If Empty(SEF->EF_DTCOMP)
						Exit
					EndIf 

					SEF->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSE5)
RestArea(aAreaSEF)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} TrValor
Transforma o campo E1_VALOR de acordo com sua picture.

@author Igor Fricks
@version P12.1.17
@since	03/07/2018
/*/
Function F191TrVal()
	Local cValor    := ""	

	If __cPicVal = Nil
		__cPicVal := PesqPict("SE1", "E1_VALOR")
	End

	cValor := Transform(SE1->E1_VALOR,__cPicVal)
Return cValor

//------------------------------
/*/{Protheus.doc}F191MovTra
Busca o movimento bancário de transferência,
da carteira descontada e descontada caucionada

@Param cFilOri, char, Filial de inclusão do título
@Param cPrefTit, char, Prefixo do título
@Param cNroTit, char, Número do título
@Param cParcTit, char, Parcela do título
@Param cTipoTit, char, Tipo do título
@Return TblTmp, char, nome da tabela temporária

@author Sivaldo Oliveira
@since  09/11/2020
@version 12
/*/
//------------------------------
Static Function F191MovTra(cFilOri As Char, cPrefTit As Char, cNroTit As Char, cParcTit As Char, cTipoTit As Char) As Char
	Local cTblTmp As Char
	Local cQry    As Char
	
	//Inicializa variáveis.
	cTblTmp := "" 	
	cQry    := ""
	
	//Valores default
	Default cFilOri  := cFilAnt
	Default cPrefTit := ""
	Default cNroTit  := ""
	Default cParcTit := ""
	Default cTipoTit  := ""
	
	If !Empty(cNroTit) .And. !Empty(cTipoTit)
		cPrefTit := Padr(cPrefTit, TamSx3("E1_PREFIXO")[1], "")
		cNroTit  := Padr(cNroTit,  TamSx3("E1_NUM")[1], "")
		cParcTit := Padr(cParcTit, TamSx3("E1_PARCELA")[1], "")
		cTipoTit := Padr(cTipoTit, TamSx3("E1_TIPO")[1], "")
		
		cQry := "SELECT E5_SEQ, E5_BANCO, E5_AGENCIA, E5_CONTA, R_E_C_N_O_ FROM " + RetSqlName("SE5") + " "
		cQry += "WHERE E5_FILIAL = '" + xFilial("SE5",cFilOri) + "' "	
		cQry += "AND E5_TIPODOC = 'TR' AND E5_PREFIXO = '"  + cPrefTit + "' "
		cQry += "AND E5_NUMERO = '" + cNroTit + "' AND E5_PARCELA = '" + cParcTit + "' "  
		cQry += "AND E5_TIPO = '"   + cTipoTit  + "' AND E5_RECPAG = 'R' "
		cQry += "AND E5_TABORI = 'FK5' AND D_E_L_E_T_ = ' '"
		cQry := ChangeQuery(cQry)
		cTblTmp := MpSysOpenQuery(cQry)
		
		If (cTblTmp)->(Eof())
			(cTblTmp)->(DbCloseArea())
			cTblTmp := ""
		EndIf
	EndIf
Return cTblTmp


//------------------------------
/*/{Protheus.doc}F191VldNom
Valida a existência de um cheque e faz o controle do valor nominal.
Função executada no gatilho dos campos:
EF_BANCO
EF_AGENCIA
EF_CONTA
EF_NUM

@author Edson Melo
@since  14/04/2021
@version 12
/*/
//------------------------------
Function F191VldNom() As Numeric	
	Local cBco 	   As Character
	Local cAge 	   As Character
	Local cCc 	   As Character
	Local cChq 	   As Character
	Local nVlrNom  As Numeric
	
	//Inicializa variáveis.
	nVlrNom := 0
	
	If Type("aHeader") == "A" .And. Type("aCols") == "A" .And. Len(aHeader) > 0 .And. Len(aCols) > 0
		F191SetVlr(@cBco, @cAge, @cCc, @cChq, @nVlrNom)
	Else
		cBco 	:= M->EF_BANCO
		cAge 	:= M->EF_AGENCIA
		cCc	 	:= M->EF_CONTA
		cChq 	:= M->EF_NUM
		nVlrNom := M->EF_VALOR
	EndIf
	
	F191ExisCh(cBco, cAge, cCc, cChq, @nVlrNom, .F.)	
Return nVlrNom

//------------------------------
/*/{Protheus.doc}F191WhnNom
Valida o when do campo de valor nominal do cheque

@author Edson Melo
@since  14/04/2021
@version 12
/*/
//------------------------------
Function F191WhnNom() As Logical	
	Local lWhen    As Logical
	Local cBco 	   As Character
	Local cAge 	   As Character
	Local cCc 	   As Character
	Local cChq 	   As Character
	Local nVlrNom  As Numeric
	Local lExterno As Numeric
	
	lWhen := .T.
	
	If (lExterno := (Type("aHeader") == "A" .And. Type("aCols") == "A" .And. Len(aHeader) > 0 .And. Len(aCols) > 0))
		F191SetVlr(@cBco, @cAge, @cCc, @cChq, @nVlrNom)
	Else
		cBco 	:= M->EF_BANCO
		cAge 	:= M->EF_AGENCIA
		cCc	 	:= M->EF_CONTA
		cChq 	:= M->EF_NUM
		nVlrNom := M->EF_VALOR
	EndIf
	
	If (lExterno .Or. INCLUI)
		lWhen := !F191ExisCh(cBco, cAge, cCc, cChq, @nVlrNom, .F.)
	EndIf
Return lWhen

//------------------------------
/*/{Protheus.doc}F191ExisCh
Query para verificar se existe cheque já cadastrado

@param cBanco, Caracter, Código do banco.
@param cAgencia, Caracter, Número da agência.
@param cConta, Caracter, Número da conta corrente.
@param cCheque, Caracter, Número do chque.
@param nVlrNom, Numerico, Valor nominal do cheque. Caso passado por referência, retornará o valor nominal já cadastrado.

@return lExistCh – Retorna .T. caso o cheque exista

@author Edson Melo
@since  14/04/2021
@version 12
/*/
//------------------------------
Function F191ExisCh(cBanco As Char, cAgencia As Char, cConta As Char, cCheque As Char, nVlrNom As Numeric, lTudoOk As Logical) As Logical	
	Local lLegF191 As Logical
	Local lExistCh As Logical
	Local nVlrCh   As Numeric
	Local cQry     As Character
	Local cTblTmp  As Character
	Local nQtdCheq As Numeric
	
	Default cBanco   := " "
	Default cAgencia := " "
	Default cConta   := " "
	Default cCheque  := " "
	Default nVlrNom  := 0
	Default lTudoOk  := .F.
	
	lLegF191  := SuperGetMV("MV_LEGF191", .F., .F.)
	lExistCh  := .F.
	nVlrCh    := 0
	cQry      := ""
	cTblTmp   := ""	
	nQtdCheq  := 0
	
	If lLegF191 .And. !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta) .And. !Empty(cCheque)
		cQry := "SELECT EF_BANCO, EF_AGENCIA, EF_CONTA, EF_NUM, EF_VALOR "
		cQry += "FROM " + RetSqlName("SEF") + " WHERE "
		cQry += "EF_FILIAL = '" + FWxFilial("SEF") + "' "	
		cQry += "AND EF_BANCO = '" + cBanco + "' "
		cQry += "AND EF_AGENCIA = '" + cAgencia + "' "
		cQry += "AND EF_CONTA = '" + cConta + "' "
		cQry += "AND EF_NUM = '" + cCheque + "' "
		cQry += "AND EF_CART = 'R' "
		cQry += "AND D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery(cQry)
		cTblTmp := MpSysOpenQuery(cQry)
		
		If (cTblTmp)->(!Eof()) 
			lExistCh := .T.
			
			While (cTblTmp)->(!Eof())			
				nQtdCheq += 1
				
				If nVlrCh == 0
					nVlrCh := (cTblTmp)->EF_VALOR
				ElseIf (cTblTmp)->EF_VALOR != nVlrCh
					exit
				EndIf
				
				(cTblTmp)->(DbSkip())
			EndDo
			
			nVlrNom  := nVlrCh
			lExistCh := Iif(lTudoOk, (nQtdCheq > 1), lExistCh) 
		EndIf
		
		(cTblTmp)->(DbCloseArea())
	EndIf
Return lExistCh

//------------------------------
/*/{Protheus.doc}F191AtuChq
Atualiza valor nominal do cheque em todo o SEF

@param cBanco, Caracter, Código do banco.
@param cAgencia, Caracter, Número da agência.
@param cConta, Caracter, Número da conta corrente.
@param cCheque, Caracter, Número do chque.
@param nVlrNom, Numerico, Valor nominal do cheque a ser considerado para todos os registros

@author Edson Melo
@since  14/04/2021
@version 12
/*/
//------------------------------
Function F191AtuChq(cBanco As Char, cAgencia As Char, cConta As Char, cCheque As Char, nVlrNom As Numeric)
	Local aAreaSEF  As Array
	Local cChaveSEF As Char
	
	//Inicializa variáveis.	
	aAreaSEF  := SEF->(GetArea())
	cChaveSEF := FWxFilial("SEF")+cBanco+cAgencia+cConta+cCheque
	
	SEF->(DbSetOrder(1))
	If SEF->(DbSeek(cChaveSEF))
		While SEF->(!EOF()) .And. SEF->(EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM) == cChaveSEF
			If SEF->EF_CART == "R"			
				Reclock("SEF")
				SEF->EF_VALOR := nVlrNom
				SEF->(MSuNLOCK())
				SEF->(DbSkip())
			EndIf
		EndDo
	EndIf

	RestArea(aAreaSEF)
	FwFreeArray(aAreaSEF)
Return

//------------------------------
/*/{Protheus.doc}F191SetVlr
Atualiza os valores dos campos
banco, agência, conta e valor do cheque
quando for chamado por outras rotinas

@Param cBco, char, Código do banco
@Param cAge, char, número da agência
@Param cCc, char, Número da conta
@Param cChq, char, Número do cheque
@Param nVlrNom, Numeric, Valor nominal do cheque

@author Sivaldo Oliveira
@since  28/04/2021
@version 12
/*/
//------------------------------
Static Function F191SetVlr(cBco As Char, cAge As Char, cCc As Char, cChq As Char, nVlrNom As Numeric)
	Local nPos As Numeric		
	
	//Inicializa variáveis
	nPos := 0
	
	Default cBco := Padr(" ", TamSx3("EF_BANCO")[1],   " ")
	Default cAge := Padr(" ", TamSx3("EF_AGENCIA")[1], " ")
	Default cCc  := Padr(" ", TamSx3("EF_CONTA")[1],   " ")
	Default cChq := Padr(" ", TamSx3("EF_NUM")[1],     " ")
	
	If (nPos := GdFieldPos("EF_BANCO", aHeader)) > 0
		cBco := aCols[n,nPos]
	EndIf
	
	If (nPos := GdFieldPos("EF_AGENCIA", aHeader)) > 0
		cAge := aCols[n,nPos]
	EndIf
	
	If (nPos := GdFieldPos("EF_CONTA", aHeader)) > 0
		cCc := aCols[n,nPos]
	EndIf		
	
	If (nPos := GdFieldPos("EF_NUM", aHeader)) > 0
		cChq := aCols[n,nPos]
	EndIf		
	
	If (nPos := GdFieldPos("EF_VALOR", aHeader)) > 0
		nVlrNom := aCols[n,nPos]
	EndIf
Return Nil


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} F191GetE5
	Retorna registro do SE5 referente o cheque que esta sendo estornado
	Função em subistituição ao método anterior, que localizava o registro atraves do 
	indice 2 do SE5 (que nao funcionava quando havia cheques de contas diferentes mas de mesma numeração)
	
	@Type Static Function
	@author Fabio Zanchim
	@since 24/03/2022
	@version 1.0
	@return nRecno
/*/
//-------------------------------------------------------------------------------------------
Static Function F191GetE5() As Numeric

	Local nRecno 	As Numeric
	Local _cProc 	As Character 
	Local _aArea 	As Array
	Local _cAlias	As Character
	Local _cQuery	As Character
	
	_cQuery	:=""
	_cAlias :=""
	nRecno	:=0
	_aArea	:=SE5->(GetArea())

	//-- Pega o codigo de processo relacionado ao cheque
	dbSelectArea('FKA')
	dbSetOrder(3)
	If dbSeek(xFilial()+'SEF'+SEF->EF_IDSEF)		
		_cProc :=FKA_IDPROC
	
		_cAlias :=GetNextAlias()
		//-- Localiza o movimento bancario da baixa
		_cQuery := " SELECT "+RetSQLName("SE5")+".R_E_C_N_O_ REC"
		_cQuery += " FROM "+RetSQLName("FKA")+" INNER JOIN  "+RetSQLName("SE5")
		_cQuery += " 	ON FKA_FILIAL=E5_FILIAL AND FKA_IDORIG=E5_IDORIG " 
		_cQuery += " 	AND E5_RECPAG='R'"
		_cQuery += "    AND "+RetSQLName("SE5")+".D_E_L_E_T_=' '"
		_cQuery += " WHERE "
		_cQuery += " FKA_FILIAL='"+xFilial('FKA')+"' AND"
		_cQuery += " FKA_TABORI='FK5' "
		_cQuery += " AND FKA_IDPROC='"+_cProc+"'"
		_cQuery += " AND "+RetSQLName("FKA")+".D_E_L_E_T_=' '"
		_cQuery += " Order by E5_SEQ DESC"
		_cQuery := ChangeQuery( _cQuery )

		dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), _cAlias, .F., .T. )
		DbSelectArea(_cAlias)
		If !Eof()
			nRecno := (_cAlias)->REC			
		EndIf
		(_cAlias)->(dbCloseArea())
	EndIf 

	RestArea(_aArea)
Return(nRecno)
