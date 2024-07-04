#Include "PROTHEUS.CH"
#Include "FINA581.CH"

//Compilar SQA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA581  บAutor  ณ Danilo Dias        บ Data ณ 01/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera็ใo das despesas, adiantamentos e presta็ใo de       บฑฑ
ฑฑบ          ณ contas.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA581

Local cTipoLib := SuperGetMV( "MV_FINCTAL", .F., "1" )

Private aCores  := {}
Private aRotina := Menudef( cTipoLib )
Private cTitulo := STR0016	//"Libera็ใo de Movimentos do Caixinha"

dbSelectarea("SEU")
SEU->(dbSetOrder(1))


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Mostra/Altera lancamentos contabeis mv_par01 Sim/Nao         ณ
//ณ Aglutina lancamentos contabeis      mv_par02 Sim/Nao         ณ
//ณ Lancamento contabil On-Line         mv_par03 Sim/Nao         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega funcao Pergunte	                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetKey (VK_F12,{|a,b| AcessaPerg("FIA550",.T.)})

Pergunte("FIA550",.F.)

SEU->(DbSeek(xFilial()))
mBrowse( 6, 1, 22, 75, "SEU",,,,,, Fa581Leg() )


Set Key VK_F12 To

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef	บAutor  ณ Danilo Dias        บ Data ณ 01/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ MenuDef                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC1 = Tipo de libera็ใo ( 1=Simples ou 2=Fundo Fixo )    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef( cTipoLib )

Default cTipoLib := "1"

//Verifica se parโmetro de Libera็ใo por al็adas estแ ativo. ( MV_FINCTAL = 2 )
If cTipoLib = "1"

    //Menu para libera็ใo simples
	aRotina := { { STR0001, "AxPesqui" , 0, 1 },;	//"Pesquisar"
                 { STR0002, "Fa581Man" , 0, 3, , .F. },;	//"Libera็ใo Manual"
                 { STR0003, "Fa581Aut" , 0, 3, , .F. },;	//"Lib. Automแtica"
            	 { STR0004, "Fa581Canc", 0, 3, , .F. },;	//"Anular"
                 { STR0005, "Fa581Leg" , 0, 2, , .F. } }	//"Legenda"

Else

	//Menu para libera็ใo por al็ada de fundo fixo
	aRotina := { { STR0001, "AxPesqui"   , 0, 1 },;			//"Pesquisar"
                 { STR0006, "Fa581Saldo" , 0, 3 },;			//"Consulta Saldos"
                 { STR0007, "Fa581Liber" , 0, 3 },;			//"Libera Mov."
           	     { STR0004, "Fa581Anula" , 0, 3 },;			//"Anula"
                 { STR0008, "Fa581Super" , 0, 3 },;			//"Superior"
                 { STR0009, "Fa581Transf", 0, 3 },;			//"Transfere Sup."
                 { STR0010, "Fa581Aus"   , 0, 3 },;			//"Aus๊ncia Temp."
                 { STR0005, "Fa581Leg"   , 0, 2, , .F. } }	//"Legenda"

EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Leg	บAutor  ณ Danilo Dias        บ Data ณ 01/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cores da Legenda                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Leg( cAlias, nReg )

Local aLegenda := {}
Local uRetorno := .T.

//Cores para a legenda
aLegenda := { {"BR_AZUL"	, STR0011	},;	 //"Bloqueado (Esperando outros nํveis)"
              {"BR_VERMELHO", STR0012	},;	 //"Esperando aprova็ใo do usuแrio"
              {"BR_VERDE"   , STR0013	},;	 //"Movimento liberado pelo usuแrio"
              {"BR_PRETO"   , STR0014	},;  //"Movimento bloqueado pelo usuแrio"
              {"BR_CINZA"   , STR0015	} }  //"Movimento liberado por outro usuแrio"

//Verifica se nใo foi chamada do menu
If nReg == nil
	uRetorno := {}
	//Legenda de status da movimenta็ใo do caixinha
	aAdd( uRetorno, { "EU_STATUS == '01'", "BR_VERMELHO" } )	//Esperando aprova็ใo do usuแrio
	aAdd( uRetorno, { "EU_STATUS == '02'", "BR_AZUL"	   } )	//Bloqueado (esperando outros nํveis)
	aAdd( uRetorno, { "EU_STATUS == '03' .Or. Empty(EU_STATUS)", "BR_VERDE" } )	//Movimento liberado pelo usuแrio
	aAdd( uRetorno, { "EU_STATUS == '04'", "BR_PRETO"	   } )	//Movimento bloqueado pelo usuแrio
	aAdd( uRetorno, { "EU_STATUS == '05'", "BR_CINZA"	   } )	//Movimento liberado por outro usuแrio
Else
	BrwLegenda( cTitulo, STR0005, aLegenda )  //"Legenda"
EndIf

Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Man   บAutor  ณ Danilo Dias      บ Data ณ 01/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera็ใo manual do movimento sem valida็ใo de al็adas.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Man( cAlias, nReg )

Local aArea := GetArea()
local lRet := Fa581CxAbe(SEU->EU_CAIXA)

If lRet
	//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
	If SEU->EU_TIPO $ ("00|01|02|03")

		//Movimento aguardando libera็ใo, libera.
		If SEU->EU_STATUS == "01"
			RecLock( "SEU", .F. )
				SEU->EU_STATUS  := "03"
				SEU->EU_DATALIB := dDataBase
				SEU->EU_USUALIB := cUserName
			SEU->(MsUnlock())

		//Movimento bloqueado aguardando outros nํveis
		ElseIf SEU->EU_STATUS == "02"
			Help( " ", 1, "Fa581Man", , STR0019, 1, 0 )	//"Movimento estแ bloqueado aguardando outros nํveis."

		//Movimento jแ liberado
		ElseIf SEU->EU_STATUS == "03" .Or. SEU->EU_STATUS == "05"
			Help( " ", 1, "Fa581Man", , STR0020, 1, 0 )	//"Movimento jแ foi liberado."

		//Movimento bloqueado pelo usuแrio
		ElseIf SEU->EU_STATUS == "04"
			Help( " ", 1, "Fa581Man", , STR0021, 1, 0 )		//"Movimento foi bloqueado por usuแrio."
		EndIf
	Else
		Help( " ", 1, "Fa581Man", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
	EndIf
EndIf

RestArea(aArea)
FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Aut   บAutor  ณ Danilo Dias      บ Data ณ 01/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera็ใo automแtica do movimento sem valida็ใo de al็adas บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Aut()

Local oMark
Local oDlg
Local oPanel
Local oQtde
Local aArea     := GetArea()
Local cMarca    := GetMark()
Local lInverte  := .T.
Local aSize     := {}
Local aCampos   := {}
Local nQtde     := 0
Local nOpca     := 0
Local bCondicao := { || SEU->EU_STATUS == "01" .And. SEU->EU_TIPO $ ("00") }
Local cCondicao := 'SEU->EU_STATUS == "01" .And. SEU->EU_TIPO $ ("00")'

aSize := MsAdvSize()

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("SEU"))

//Exibe na markBrowse os campos que estใo com Browse igual a Sim no dicionแrio ou
//sใo os campos definidos como padrใo para prote็ใo.
While SX3->X3_ARQUIVO == "SEU"
	If ( SX3->X3_BROWSE == "S" .Or. SX3->X3_CAMPO $ ("EU_CAIXA|EU_TIPO|EU_HISTOR|EU_VALOR|EU_EMISSAO") ) .And. !SX3->X3_CONTEXT == "V"
		aAdd( aCampos, {SX3->X3_CAMPO, , X3_TITULO, X3_PICTURE} )
	EndIf
	SX3->(dbSkip())
EndDo

//Filtra Movimentos pendentes apenas
SEU->(dbSetFilter( bCondicao, cCondicao ) )
SEU->(dbGoTop())

//Cria MsDialog com marca็ใo
oDlg := MSDialog():New( aSize[7], 0, aSize[6], aSize[5], STR0023, , , , , , , , oMainWnd, .T., , , , )	//"Aprova็ใo de Movimentos"
oDlg:lMaximized := .T.

	oPanel := TPanel():New( 0, 0, '', oDlg, , .T., .T., , , 40, 40, .T., .T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oSay  := TSay():New( 10, 10, { || STR0024 }, oPanel,,,,,,.T.,,, 120, 10 )	//"Quantidade de movimentos selecionados:"
	oQtde := TSay():New( 10, 135, { || nQtde }, oPanel,,,,,,.T.,,, 60, 10 )

	oMark := MsSelect():New( "SEU", "EU_OK",, /*aCampos*/, .F., @cMarca, { 35, oDlg:nLeft, oDlg:nBottom, oDlg:nRight } )
	oMark:oBrowse:bAllMark := { || Fa581Marca( cMarca, oQtde, @nQtde, lInverte, .T., oMark, "SEU", "EU_OK" ) }
	oMark:bMark := { || Fa581Display( cMarca, lInverte, oQtde, @nQtde ) }
	oMark:bAval	:= { || Fa581Marca( cMarca, oQtde, @nQtde, lInverte, .F., oMark, "SEU", "EU_OK" ) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oDlg:Activate( ,,,.T.,,,{ || EnchoiceBar( oDlg, { || ( nOpca := 1, oDlg:End() ) }, {|| nOpca := 0, ODlg:End() } ) } )

//Se usuแrio clicou em Ok
If nOpca == 1

	SEU->(dbGoTop())

	While SEU->(!Eof())
		If SEU->EU_OK == cMarca .And. SEU->EU_STATUS == "01"
			If Fa581CxAbe(SEU->EU_CAIXA)
				RecLock( "SEU", .F. )
					SEU->EU_STATUS  := "03"
					SEU->EU_DATALIB := dDataBase
					SEU->EU_USUALIB := cUserName
				MsUnlock()
			EndIf
		EndIf
		SEU->(dbSkip())
	EndDo

EndIf

SEU->(dbClearFilter())
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Marca บAutor ณDanilo Dias        บ Data ณ  04/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza marca็ใo na tela de sele็ใo.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cMarca = Marca utlizada na MsSelect.                       ณฑฑ
ฑฑณ          ณ oQtde  = Objeto Get que recebe a quantidade selecionada.   ณฑฑ
ฑฑณ          ณ nQtde  = Aramazena a quantidade selecionada.(Refer๊ncia)   ณฑฑ
ฑฑณ          ณ lInverte = Indica se deve usar inversใo da sele็ใo.        ณฑฑ
ฑฑณ          ณ lTodos = Habilita sele็ใo de todos os itens da MsSelect.   ณฑฑ
ฑฑณ          ณ oMark = Objeto MsSelect.                                   ณฑฑ
ฑฑณ          ณ cAlias = Alias da tabela que estแ sendo usada na MsSelect. ณฑฑ
ฑฑณ          ณ cCpoMarca = Campo utilizado para a marca็ใo.               ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa581Marca( cMarca, oQtde, nQtde, lInverte, lTodos, oMark,;
                            cAlias, cCpoMarca )

Local aArea := GetArea()

Default lInverte := .T.
Default lTodos   := .F.

If lTodos
	(cAlias)->(dbGoTop())
Endif

While !lTodos .Or. (cAlias)->(!Eof())
	RecLock(cAlias, .F.)

	If lInverte
		If &(cCpoMarca) == cMarca
			&(cCpoMarca) := ""
			nQtde--
			nQtde := IIf ( nQtde <= 0, 0, nQtde )
	 	Else
	 		&(cCpoMarca) := cMarca
			nQtde++
		EndIf
	Else
		If &(cCpoMarca) != cMarca
			&(cCpoMarca) := cMarca
			nQtde++
		EndIf
	EndIf

	MsUnLock()
	oQtde:Refresh()

	If !lTodos
		Exit
	Endif

	(cAlias)->(dbSkip())
EndDo

oMark:oBrowse:Refresh()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo	 ณ Fa581Display ณ Autor ณ Danilo Dias      ณ Data ณ 18/04/2011  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณ Atualiza tela de sele็ใo da libera็ใo automแtica.            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FINA581														ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cMarca = Marca utlizada na MsSelect.                         ณฑฑ
ฑฑณ          ณ lInverte = Indica se deve usar inversใo da sele็ใo.          ณฑฑ
ฑฑณ          ณ oQtde  = Objeto Get que recebe a quantidade selecionada.     ณฑฑ
ฑฑณ          ณ nQtde  = Aramazena a quantidade selecionada.(Refer๊ncia)     ณฑฑ
ฑฑณ          ณ cCampo = Campo utilizado para a marca็ใo.                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa581Display( cMarca, lInverte, oQtde, nQtde, cCampo )

If IsMark( cCampo, cMarca, lInverte )
	 nQtde++
Else
	 nQtde--
	 nQtde:= IIf( nQtde < 0, 0, nQtde )
End

oQtde:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Canc  บAutor  ณ Danilo Dias      บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelamento da libera็ใo.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Canc()
	Local aArea := GetArea()
	local lRet  := Fa581CxAbe(SEU->EU_CAIXA)

	IF lRet
		//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
		If SEU->EU_TIPO $ ("00|01|02|03") 

			//Movimento liberado, bloqueia.
			If SEU->EU_STATUS == "03" 
				RecLock( "SEU", .F. )
				SEU->EU_STATUS  := "01"
				SEU->EU_DATALIB := CTOD("  /  /  ")
				SEU->EU_USUALIB := ""
				SEU->(MsUnlock())
			EndIf	
		Else
			Help( " ", 1, "Fa581Canc", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
		EndIf
	EndIf
	
	RestArea(aArea)
	FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Saldo บAutor  ณ Danilo Dias      บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Saldos do usuแrio aprovador.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA580, FINA581                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Saldo()
Local aArea    := GetArea()
Local oDlg
Local oCalend
Local oSaldo
Local oMoeda
Local oDataSld
Local nSaldo   := 0
Local cMoeda   := "1"
Local dDataRef := dDataBase
Local cCodigo  := ""
Local cNome    := ""
Local nValMin  := 0
Local nValMax  := 0
Local nLimite  := 0
Local nMoeda   := 0	

If FunName() == "FINA580"
	nMoeda := SE2->E2_MOEDA
Else
	nMoeda := SEU->EU_MOEDA
EndIf 

If nMoeda > 0
	cMoeda := StrZero(nMoeda,TamSx3("FRP_MOEDA")[1])
EndIf

dbSelectArea("FRP")
FRP->(dbSetOrder(2))
If FRP->(dbSeek( xFilial() + __cUserId  + cMoeda ))

	cCodigo := FRP->FRP_COD
	cNome   := UsrFullName(__cUserId)
	nValMax := FRP->FRP_LIMMAX
	nValMin := FRP->FRP_LIMMIN
	nLimite := FRP->FRP_LIMITE
	cMoeda  := FRP->FRP_MOEDA
	nSaldo  := Fa581ValSld( cCodigo, cMoeda, dDataRef )

	oDlg := MsDialog():New( 0, 0, 320, 575, STR0025, , , , , , , , oMainWnd, .T., , , ,  )	//"Consulta de Saldos"

		oCalend         := MsCalend():New( 82, 10, oDlg )
		oCalend:bChange := { || Fa581ChgDt( @oMoeda, @oSaldo, @nSaldo, @oDataSld, @dDataRef, cCodigo, cMoeda, oCalend:dDiaAtu ) }
		oCalend:dDiaAtu := dDataBase

		oSay     := TSay():New( 010, 010, { || STR0026 }, oDlg,,,,,,.T.,,, 60, 10 )	//"C๓digo"
		oCodigo  := TGet():New( 020, 010, { |u| If( PCount() > 0, cCodigo := u, cCodigo ) }, oDlg, 060, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cCodigo" )
		oSay     := TSay():New( 010, 080, { || STR0027 }, oDlg,,,,,,.T.,,, 50, 10 )	//"Nome"
		oNome    := TGet():New( 020, 080, { |u| If( PCount() > 0, cNome := u, cNome ) }, oDlg, 200, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNome" )
		oSay     := TSay():New( 040, 010, { || STR0028 }, oDlg,,,,,,.T.,,, 82, 10 )	//"Valor Mํnimo"
		oValMin  := TGet():New( 050, 010, { |u| If( PCount() > 0, nValMin := u, nValMin) }, oDlg, 082, 010, SX3->(X3Picture("FRP_LIMMIN")),,,,,,,.T.,,,{|| .F.},,,,,,,"nValMin" )
		oSay     := TSay():New( 040, 104, { || STR0029 }, oDlg,,,,,,.T.,,, 82, 10 )	//"Valor Mแximo"
		oValMax  := TGet():New( 050, 104, { |u| If( PCount() > 0, nValMax := u, nValMax ) }, oDlg, 082, 010, SX3->(X3Picture("FRP_LIMMAX")),,,,,,,.T.,,,{|| .F.},,,,,,,"nValMax" )
		oSay     := TSay():New( 040, 198, { || STR0030 }, oDlg,,,,,,.T.,,, 82, 10 )	//"Limite"
		oLimite  := TGet():New( 050, 198, { |u| If( PCount() > 0, nLimite := u, nLimite ) }, oDlg, 082, 010, SX3->(X3Picture("FRP_LIMITE")),,,,,,,.T.,,,{|| .F.},,,,,,,"nLimite" )

		oSay     := TSay():New( 090, 155, { || STR0031 }, oDlg,,,,,,.T.,,, 51, 10 )	//"Saldo na data"
		oSaldo   := TGet():New( 089, 205, { |u| If( PCount() > 0, nSaldo := u, nSaldo ) }, oDlg, 072, 010, SX3->(X3Picture("FRT_SALDO")),,,,,,,.T.,,,{|| .F.},,,,,,,"nSaldo" )
		oSay     := TSay():New( 108, 155, { || STR0032 }, oDlg,,,,,,.T.,,, 51, 10 )	//"Moeda"
		oMoeda   := TGet():New( 107, 205, { |u| If( PCount() > 0, cMoeda := u, cMoeda ) }, oDlg, 072, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cMoeda" )
		oSay     := TSay():New( 126, 155, { || STR0033 }, oDlg,,,,,,.T.,,, 51, 10 )	//"Data de Ref."
		oDataSld := TGet():New( 125, 205, { |u| If( PCount() > 0, dDataRef := u, dDataRef ) }, oDlg, 072, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"dDataRef" )

		//Botใo para fechar a janela
		oButton:=tButton():New(144,242,STR0064,oDlg,{||oDlg:End()},035,,,,,.T.) //"Fechar"

	oDlg:Activate( ,,,.T.,,, )

Else
	Help( " ", 1, "Fa581Saldo", , STR0034, 1, 0 )	//"Usuแrio nใo ้ Gestor Financeiro."
EndIf

RestArea(aArea)
FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581ValSld บAutor  ณ Danilo Dias     บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออสอออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o saldo do usuแrio aprovador.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA580, FINA581                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cCodAprov = C๓digo do gestor financeiro.                   ณฑฑ
ฑฑณ          ณ cMoeda = Moeda utlizada na aprova็ใo.                      ณฑฑ
ฑฑณ          ณ dDtRef = Data de refer๊ncia da aprova็ใo.                  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581ValSld( cCodAprov, cMoeda, dDtRef )

Local aMovAprov := {}
Local nSldAprov := 0

aMovAprov := fxAlcSld( cMoeda, dDtRef, cCodAprov, .F. ) 	//Monta array com os movimentos do Gestor
nSldAprov := fxAlcSldFim( aMovAprov )	//Busca saldo final do usuแrio aprovador

Return nSldAprov

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581ChgDt บAutor  ณ Danilo Dias      บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออสออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o saldo de acordo com a data selecionada no       บฑฑ
ฑฑบ          ณ calendแrio.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581ChgDt( oMoeda, oSaldo, nSaldo, oDataSld, dDataRef,;
                     cCodigo, cMoeda, dDtRef )

nSaldo   := Fa581ValSld( cCodigo, cMoeda, dDtRef )
dDataRef := dDtRef

oSaldo:Refresh()
oDataSld:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Liber  บAutor  ณ Danilo Dias     บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออสอออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera็ใo de movimentos pelo aprovador usando regras de    บฑฑ
ฑฑบ          ณ al็ada por fundo fixo.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Liber(cAlias, nReg)
Local aArea     := GetArea()
Local cUsrAprov := __cUserId
Local cCodAprov := SEU->EU_CODAPRO
Local cMoeda    := strzero(SEU->EU_MOEDA,TamSx3("FRP_MOEDA")[1])//cValToChar(SEU->EU_MOEDA)//alterado por Fernando Radu Muscalu em 01/09/2011
Local dDtRef    := dDataBase
Local nTotal    := SEU->EU_VALOR
Local nNumInt   := SEU->EU_NUM
Local cEmissao  := SEU->EU_EMISSAO
Local nSldAprov := 0
Local lRet      := .T.
Local nOpc      := 0
Local nRecSEU	:= 0 

SET->(dbSetOrder(1))
SET->(dbSeek(xFilial("SET")+SEU->EU_CAIXA))

If !Empty(SEU->EU_STATUS)
	If Alltrim(SEU->EU_STATUS) $ '03|05'
		If Empty(cCodAprov)
			Help( " ", 1, "Fa581Liber", , STR0035, 1, 0 )	//"Movimento a liberar nใo possui aprovador."
			Return()
		Endif
	Endif
	If dDataBase < SEU->EU_EMISSAO
		Help( " ", 1, "Fa581Liber",, STR0073,1,0 ) //"Data da libera็ใo nใo pode ser menor que a data da movimenta็ใo do caixinha."
		Return()
	Endif
	If SET->ET_SITUAC == "1"
		Help( " ", 1, "Fa581Liber",, STR0074,1,0 ) //"Caixa fechado. A libera็ใo nใo poderแ ser realizada."
		Return()
	Endif
Endif

//Busca dados do Gestor Aprovador do Movimento
dbSelectArea("FRP")
FRP->(dbSetOrder(2))

If FRP->(dbSeek( xFilial("FRP") + cUsrAprov + cMoeda ))

	//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
	If SEU->EU_TIPO $ ("00|01|02|03")

		//Movimento aguardando libera็ใo
		If SEU->EU_STATUS == "01"

			//Verifica se usuแrio ้ o aprovador
			If FRP->FRP_COD == cCodAprov
				//Verifica saldo do aprovador
				lRet := Fa550ValSld( cUsrAprov, cCodAprov, cMoeda, dDtRef, nTotal, @nSldAprov )
			Else
				Help( " ", 1, "Fa581Liber", , STR0036, 1, 0 )	//"Usuแrio nใo ้ o aprovador para esse movimento."
				lRet := .F.
			EndIf

			If lRet
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Monta tela de confirma็ใo da libera็ใo das movimenta็๕es ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nOpc := Fa581CfMov( STR0016, .T., "SEU", nNumInt, cEmissao, dDtRef, nTotal, "EU_VALOR" )

				If nOpc == 1 //Movimento aprovado
					Begin Transaction

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Atualiza o saldo do aprovador ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					lRet := FXALCGrava( cUsrAprov, cCodAprov, cMoeda, "2", dDtRef, nTotal )

					//Realiza os lanc CTB/PCO e abate o saldo do caixinha
					nRecSEU	:= SEU->(Recno())
					FA560Lanc()
					SEU->(dbGoto(nRecSEU))
					If lRet
						//Se tem saldo libera Movimento
						RecLock( "SEU", .F. )
						SEU->EU_STATUS  := "03"
						SEU->EU_DATALIB := dDataBase
						SEU->EU_USUALIB := cUserName
						MsUnlock()
					EndIf

					//Inserir aqui a chamada do d้bito do caixinha (atualiza็ใo da SET)

					End Transaction
				ElseIf nOpc == 2	//Movimento bloqueado
					RecLock( "SEU", .F. )
					SEU->EU_STATUS  := "04"
					MsUnlock()
				EndIf
			EndIf

			//Movimento bloqueado aguardando outros nํveis
		ElseIf SEU->EU_STATUS == "02"
			Help( " ", 1, "Fa581Liber", , STR0019, 1, 0 )	//"Movimento estแ bloqueado aguardando outros nํveis."

			//Movimento jแ liberado
		ElseIf SEU->EU_STATUS == "03" .Or. SEU->EU_STATUS == "05"
			Help( " ", 1, "Fa581Liber", , STR0020, 1, 0 )	//"Movimento jแ foi liberado."

			//Movimento bloqueado pelo usuแrio
		ElseIf SEU->EU_STATUS == "04"
			Help( " ", 1, "Fa581Liber", , STR0021, 1, 0 )	//"Movimento foi bloqueado por usuแrio."
		EndIf
	Else
		Help( " ", 1, "Fa581Liber", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
	EndIf
Else
	Help( " ", 1, "Fa581Liber", , STR0038, 1, 0 )	//"Usuแrio nใo ้ um Gestor Financeiro ou nใo tem permissใo para a moeda deste movimento."
EndIf

RestArea( aArea )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Anula   บAutor  ณ Danilo Dias    บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estornar a libera็ใo do movimento corrente.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Anula( cAlias, nReg )
Local aArea     := GetArea()
Local cUsrAprov := __cUserId
Local cCodAprov := SEU->EU_CODAPRO
Local dDtRef    := dDataBase
Local dEmissao  := SEU->EU_EMISSAO
Local nTotal    := SEU->EU_VALOR
Local nNumInt   := SEU->EU_NUM
Local cMoeda    := strzero(SEU->EU_MOEDA,TamSx3("FRP_MOEDA")[1])//cValToChar(SEU->EU_MOEDA)//alterado por Fernando Radu Muscalu em 01/09/2011
Local nOpc      := 0
Local lRet      := Fa581CxAbe(SEU->EU_CAIXA)

IF lRet
	//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
	If SEU->EU_TIPO $ ("00|01|02|03")

		//Movimento liberado, bloqueia.
		If SEU->EU_STATUS == "03" .Or. SEU->EU_STATUS == "05"
			
			If SEU->EU_TIPO == "01" .and. SEU->EU_VALOR != SEU->EU_SLDADIA
				//Se for adiantamento jแ com prestacao de contas, nใo permite anular
				Help( " ", 1, "Fa581CancA", , STR0075, 1, 0 ) //"Cancelamento nใo permitido. Adiantamento jแ possui presta็ใo de contas." 
			Else

				//Busca dados do Gestor Aprovador do Movimento
				dbSelectArea("FRP")
				FRP->(dbSetOrder(2))

				If FRP->(dbSeek( xFilial() + cUsrAprov + cMoeda ))

					//Verifica se usuแrio ้ o aprovador
					If FRP->FRP_COD == cCodAprov
						nOpc := Fa581CfMov( STR0039, .F., "SEU", nNumInt, dEmissao, dDtRef, nTotal, "EU_VALOR" )	//"Cancelamento da Libera็ใo de Movimento do Caixinha"

						If nOpc == 1	//Confirma estorno
							Begin Transaction

							//Atualiza o saldo do aprovador
							lRet := FXALCGrava( cUsrAprov, cCodAprov, cMoeda, "3", dDtRef, nTotal )

							If lRet
								//Atualiza status do Movimento
								RecLock( "SEU", .F. )
									SEU->EU_STATUS  := "01"
									SEU->EU_DATALIB := CTOD("  /  /  ")
									SEU->EU_USUALIB := ""
								MsUnlock()
							EndIf
							End Transaction
						EndIf
					Else
						Help( " ", 1, "Fa581Anula", , STR0036, 1, 0 )	//"Usuแrio nใo ้ o aprovador para esse movimento."
					EndIf
				Else
					Help( " ", 1, "Fa581Anula", , STR0038, 1, 0 )	//"Usuแrio nใo ้ um Gestor Financeiro ou nใo tem permissใo para a moeda deste Movimento."
				EndIf
			EndIf
		Else
			Help( " ", 1, "Fa581Anula", , STR0040, 1, 0 )	//"Movimento nใo foi liberado."
		EndIf
	Else
		Help( " ", 1, "Fa581Anula", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
	EndIf
EndIf

RestArea(aArea)
FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Super บAutor  ณ Danilo Dias      บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera movimentos pelo aprovador superior.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Super( cAlias, nReg )
Local aArea     := GetArea()
Local cUsrAprov := __cUserId
Local cCodAprov := SEU->EU_CODAPRO
Local cCodSup   := Fa006User( cUsrAprov, .F., 2, SEU->EU_MOEDA)	//Retorna o c๓digo de gestor do usuแrio logado
Local cMoeda    := Strzero(SEU->EU_MOEDA,TamSX3("FRP_MOEDA")[1])//cValToChar(SEU->EU_MOEDA) //alterado por Fernando Radu Muscalu em 01/09/2011
Local dDtRef    := dDataBase
Local dEmissao  := SEU->EU_EMISSAO
Local nTotal    := SEU->EU_VALOR
Local nNumInt   := SEU->EU_NUM
Local nSldAprov := 0
Local lRet      := Fa581CxAbe(SEU->EU_CAIXA)

If lRet
	//Verifica se usuแrio ้ superior do aprovador do Movimento
	dbSelectArea("FRS")
	FRS->(dbSetOrder(3))

	If FRS->(dbSeek( xFilial() + "2" + cCodAprov + cCodSup ))

		cCodAprov := cCodSup

		//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
		If SEU->EU_TIPO $ ("00|01|02|03")

			//Movimento aguardando libera็ใo
			If SEU->EU_STATUS == "01"

				dbSelectArea("FRP")
				FRP->(dbSetOrder(1))
				FRP->(dbGoTop())

				If FRP->(dbSeek (xFilial() + FRS->FRS_CODSUP + cMoeda))
					nOpc := Fa581CfMov( STR0041, , "SEU", nNumInt, dEmissao, dDtRef, nTotal, "EU_VALOR" )	//"Libera็ใo de Movimento pelo Gestor Superior"
				Else
					Help( " ", 1, "Fa581Transf", , STR0042, 1, 0 )	//"Superior nใo ้ um Gestor Financeiro."
					nOpc := 0
				EndIf

				If nOpc == 1
					//Verifica saldo do gestor
					lRet := Fa550ValSld( cUsrAprov, cCodAprov, cMoeda, dDtRef, nTotal, @nSldAprov )

					If lRet
						Begin Transaction

						lRet := FXALCGrava( cUsrAprov, cCodAprov, cMoeda, "2", dDtRef, nTotal )

						//Realiza os lanc CTB/PCO e abate o saldo do caixinha
						SET->(dbSetOrder(1))
						SET->(dbSeek(xFilial("SET")+SEU->EU_CAIXA))
						FA560Lanc()

						If lRet
							//Se tem saldo libera Movimento
							RecLock( "SEU", .F. )
							SEU->EU_STATUS  := "05"
							SEU->EU_CODAPRO := cCodSup
							SEU->EU_DATALIB := dDataBase
							SEU->EU_USUALIB := cUserName
							MsUnlock()
						EndIf

						End Transaction
					EndIf
				ElseIf nOpc == 2
					RecLock( "SEU", .F. )
					SEU->EU_STATUS  := "04"
					SEU->EU_CODAPRO := cCodSup
					MsUnlock()
				EndIf

			//Movimento bloqueado aguardando outros nํveis
			ElseIf SEU->EU_STATUS == "02"
				Help( " ", 1, "Fa581Man", , STR0019, 1, 0 )	//"Movimento estแ bloqueado aguardando outros nํveis."

			//Movimento jแ liberado
			ElseIf SEU->EU_STATUS == "03" .Or. SEU->EU_STATUS == "05"
				Help( " ", 1, "Fa581Man", , STR0020, 1, 0 )	//"Movimento jแ foi liberado."

			//Movimento bloqueado pelo usuแrio
			ElseIf SEU->EU_STATUS == "04"
				Help( " ", 1, "Fa581Man", , STR0021, 1, 0 )	//"Movimento foi bloqueado por usuแrio."
			EndIf
		Else
			Help( " ", 1, "Fa581Man", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
		EndIf
	Else
		Help( " ", 1, "Fa581Man", , STR0043, 1, 0 )	//"Apenas um superior do aprovador pode liberar um Movimento atrav้s dessa op็ใo."
	EndIf
EndIf

RestArea(aArea)
FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Transf บAutor  ณ Danilo Dias     บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transfere a responsabilidade da libera็ใo para o superior. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Transf(cAlias, nReg)
Local aArea     := GetArea()
Local cUsrAprov := __cUserId
Local cCodAprov := SEU->EU_CODAPRO
Local cMOeda    := Strzero(SEU->EU_MOEDA,TamSX3("FRP_MOEDA")[1])//cValToChar(SEU->EU_MOEDA)//alterado por Fernando Radu Muscalu em 01/09/2011
Local dDtRef    := dDataBase
Local dEmissao  := SEU->EU_EMISSAO
Local nTotal    := SEU->EU_VALOR
Local nNumInt   := SEU->EU_NUM

//Verifica se usuแrio ้ gestor financeiro
dbSelectArea("FRP")
FRP->(dbSetOrder(2))

If FRP->(dbSeek( xFilial() + cUsrAprov + cMoeda ))

	//Verifica se ้ uma despesa, adiantamento ou presta็ใo de contas.
	If SEU->EU_TIPO $ ("00|01|02|03")

		//Movimento aguardando libera็ใo
		If SEU->EU_STATUS == "01"

            //Verifica se usuแrio ้ o aprovador
			If FRP->FRP_COD == cCodAprov

			    dbSelectArea("FRS")
			    FRS->(dbSetOrder(1))

			    //Verifica se hแ superior vinculado na tabela FRS - Amarra็ใo Gestor X Superior
			    If FRS->(dbSeek( xFilial() + "2" + cCodAprov + "01" ))

			    	FRP->(dbSetOrder(1))
			    	FRP->(dbGoTop())
			    	If FRP->(dbSeek (xFilial() + FRS->FRS_CODSUP + cMoeda))
			    		nOpc := Fa581CfMov( STR0044, , "SEU", nNumInt, dEmissao, dDtRef, nTotal, "EU_VALOR" )	//"Libera็ใo de Movimento do Caixinha"
			    	Else
			    		Help( " ", 1, "Fa581Transf", , STR0042, 1, 0 )	//"Superior nใo ้ um Gestor Financeiro."
			    		nOpc := 0
			    	EndIf

			    	If nOpc == 1
						RecLock( "SEU", .F. )
						SEU->EU_CODAPRO := FRS->FRS_CODSUP
						SEU->EU_DATALIB := CTOD("  /  /  ")
						SEU->EU_USUALIB := ""
						MsUnlock()
				 	ElseIf nOpc == 2
				 		RecLock( "SEU", .F. )
				 		SEU->EU_STATUS  := "04"
						SEU->EU_CODAPRO := FRS->FRS_CODSUP
						SEU->EU_DATALIB := CTOD("  /  /  ")
						SEU->EU_USUALIB := ""
						MsUnlock()
				 	EndIf
				Else
			   		Help( " ", 1, "Fa581Transf", , STR0045, 1, 0 )	//"Usuแrio nใo possui superior vinculado."
				EndIf

	   		Else
		    	Help( " ", 1, "Fa581Transf", , STR0036, 1, 0 )	//"Usuแrio nใo ้ o aprovador deste Movimento."
		    EndIf

		//Movimento bloqueado
		ElseIf SEU->EU_STATUS == "02" .Or. SEU->EU_STATUS == "04"
			Help( " ", 1, "Fa581Transf", , STR0046, 1, 0 )	//"Esta opera็ใo nใo poderแ ser realizada, o registro selecionado encontra-se bloqueado."

		//Movimento jแ liberado
		ElseIf SEU->EU_STATUS == "03" .Or. SEU->EU_STATUS == "05"
			Help( " ", 1, "Fa581Transf", , STR0020, 1, 0 )	//"Movimento jแ foi liberado."

		EndIf
	Else
		Help( " ", 1, "Fa581Transf", , STR0022, 1, 0 )	//"Movimento nใo ้ uma despesa, adiantamento ou presta็ใo de contas."
	EndIf
Else
	Help( " ", 1, "Fa581Transf", , STR0038, 1, 0 )	//"Usuแrio nใo ้ um Gestor Financeiro ou nใo tem permissใo para a moeda deste Movimento."
EndIf

RestArea(aArea)
FWFreeArray(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Aus   บAutor  ณ Danilo Dias      บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transfere a responsabilidade da libera็ใo por aus๊ncia     บฑฑ
ฑฑบ          ณ temporแria.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Aus()

Local aArea     := GetArea()
Local aAreaSEU  := SEU->(GetArea())
Local cMarca    := GetMark()
Local cCodSup   := Fa006User( __cUserID, .F., 2 )	//Retorna o c๓digo de gestor do usuแrio logado

nOpc := Fa581Mark( "SEU", "EU_OK", @cMarca, cCodSup )

If nOpc == 1
	SEU->(dbGoTop())

	While SEU->(!Eof())
		If SEU->EU_OK == cMarca
			RecLock( "SEU", .F. )
			SEU->EU_CODAPRO := cCodSup
			SEU->EU_DATALIB := CTOD("  /  /  ")
			SEU->EU_USUALIB := ""
			MsUnlock()
		EndIf
		SEU->(dbSkip())
	EndDo
EndIf

SEU->(dbClearFilter())

RestArea(aAreaSEU)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Mark    บAutor  ณ Danilo Dias    บ Data ณ 10/05/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela com MarkBrowse para transferir documentos do    บฑฑ
ฑฑบ          ณ aprovador para o superior.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA580, FINA581                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cAlias = Alias utilizado na MsSelect.                      ณฑฑ
ฑฑณ          ณ cCampo = Campo usado para a marca็ใo da MsSelect.          ณฑฑ
ฑฑณ          ณ cMarca = Marca para identificar os registros selecionados. ณฑฑ
ฑฑณ          ณ          Deve ser passado por refer๊ncia.                  ณฑฑ
ฑฑณ          ณ cCodSup = C๓digo do superior que serแ o aprovador.         ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581Mark( cAlias, cCampo, cMarca, cCodSup )

Local oDlg
Local oAprovAus
Local oQtde
Local oMark
Local aArea     := GetArea()
Local aAprov    := {}
Local cAprovAus := ""
Local cCodApr   := ""
Local cSuperior := cCodSup + " - " + Fa006User( cCodSup )	//Retorna o nome do gestor
Local nQtde     := 0
Local lInverte  := .T.
Local cCpoMarca := cAlias + "->" + cCampo
Local nOpc      := 0

//Monta array com gestores amarrados ao superior
Fa581Aprov( @aAprov, "2", cCodSup )

If Len(aAprov) > 0
	//Inicializa variแvel do combo com primeiro aprovador do array
	cAprovAus := aAprov[1]

	oDlg := MsDialog():New( 0, 0, 400, 780, STR0047, , , , , , , , oMainWnd, .T., , , ,  )	//"Transfer๊ncia por Aus๊ncia Temporแria de Aprovadores"

		oSay     := TSay():New( 014, 006, { || STR0048 }, oDlg,,,,,,.T.,,, 080, 009 )	//"Aprovador Ausente "
		oAprovAus := TComboBox():New( 012, 070, { |u| If( PCount() > 0, cAprovAus := u, cAprovAus ) }, aAprov, 250, 090, oDlg,, { || Fa580ClrMk( cAlias, CcpoMarca ), Fa581Filtra ( cAlias, Substr(cAprovAus, 1, 6), @oMark, @oDlg ), nQtde := 0 },,,,.T.,,,,{|| .T.},,,,, "cAprovAus" )

		oSay      := TSay():New( 032, 006, { || STR0049 }, oDlg,,,,,,.T.,,, 080, 009 )	//"Aprovador Superior "
		oSuperior := TGet():New( 030, 070, { |u| If( PCount() > 0, cSuperior := u, cSuperior ) }, oDlg, 250, 009,,,,,,,,.T.,,,{|| .F.},,,,,,,"cSuperior" )

		oSay      := TSay():New( 050, 006, { || STR0024 }, oDlg,,,,,,.T.,,, 120, 009 )	//"Quantidade de Movimentos selecionados:"
		oQtde     := TSay():New( 050, 135, { || nQtde }, oDlg,,,,,,.T.,,, 060, 009 )

		oMark := MsSelect():New( cAlias, cCampo,,, .F., @cMarca, { 070, 010, 175, 380 } )
		oMark:oBrowse:bAllMark := { || Fa581Marca( cMarca, oQtde, @nQtde, lInverte, .T., oMark, cAlias, cCpoMarca ) }
		oMark:bMark := { || Fa581Display( cMarca, lInverte, oQtde, @nQtde, cCampo ) }
		oMark:bAval	:= { || Fa581Marca( cMarca, oQtde, @nQtde, lInverte, .F., oMark, cAlias, cCpoMarca ) }

		oBtnTransf := tButton():New( 182, 299, STR0050, oDlg, { || nOpc := 1, oDlg:End() }, 040,,,,,.T.,,,,,,, )	//"Transferir"
		oBtnCancel := tButton():New( 182, 340, STR0051, oDlg, { || nOpc := 0, oDlg:End() }, 040,,,,,.T.,,,,,,, )	//"Cancelar"

	//Ativa MsDialog acionando filtro de Movimentos pendentes do gestor selecionado no Combo Box
	oDlg:Activate( ,,,.T.,,, { || Fa581Filtra ( cAlias, Substr(cAprovAus, 1, 6), @oMark, @oDlg ) } )
Else
	Help( " ", 1, "Fa581Mark", , STR0063, 1, 0 )	//"Nใo hแ gestores amarrados ao usuแrio atual. Verifique o cadastro de amarra็ใo de Aprovadores X Superiores."
EndIf

Return nOpc


Static Function Fa580ClrMk( cAlias, cCpoMarca )

Local aArea := GetArea()

(cAlias)->(dbGoTop())

While (cAlias)->(!Eof())
	RecLock( cAlias, .F. )
		&(cCpoMarca) := ""
	MsUnlock()
	(cAlias)->(dbSkip())
EndDo

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Filtra  บAutor  ณ Danilo Dias    บ Data ณ 29/04/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra os movimentos pendentes do gestor no caixinha.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cAlias = Alias utilizado na MsSelect.                      ณฑฑ
ฑฑณ          ณ cCodApr = C๓digo do gestor aprovador da transa็ใo.         ณฑฑ
ฑฑณ          ณ oMark = Objeto MsSelect.                                   ณฑฑ
ฑฑณ          ณ oDlg = Objeto MsDialog.                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa581Filtra ( cAlias, cCodApr, oMark, oDlg )

Local cCondicao := ""
Local bCondicao := { || &(cCondicao) }

//Filtra Movimentos pendentes apenas
If cAlias == "SEU"
	cCondicao := 'SEU->EU_CODAPRO == "' + cCodApr + '"' + ' .And. SEU->EU_STATUS = "01"' + ' .And. SEU->EU_TIPO $ ("00|01|02|03")'
	bCondicao := { || &(cCondicao) }
EndIf

If cAlias == "SE2"
	cCondicao := 'SE2->E2_CODAPRO == "' + cCodApr + '"' + ' .And. SE2->E2_STATLIB = "01"'
	bCondicao := { || &(cCondicao) }
EndIf

(cAlias)->(dbClearFilter())
(cAlias)->(dbSetFilter( bCondicao, cCondicao ) )
(cAlias)->(dbGoTop())

//Atualiza o MsDialog
If ValType(oMark) == "O"
	oDlg:Refresh()
	oMark:oBrowse:Refresh(.T.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581Aprov บAutor  ณ Danilo Dias      บ Data ณ 28/04/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega um array com os aprovadores que o usuแrio estแ     rฑฑ
ฑฑบ          ณ amarrado como superior na tabela FRS.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ aAprov = Array que receberแ os gestores amarrados ao Sup.  ณฑฑ
ฑฑณ          ณ cTipo = Tipo do usuแrio amarrado.(1=Analista ou 2=Gestor)  ณฑฑ
ฑฑณ          ณ cCodSup = C๓digo do gestor superior.                       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa581Aprov( aAprov, cTipo, cCodSup )

Local aAreaFRS := FRS->(GetArea())
Local bSeek    := { |cBusca| cBusca == FRS->FRS_CODAPR }

dbSelectArea("FRS")
FRS->(dbSetOrder(3))
FRS->(dbSeek( xFilial() + cTipo ))

//Monta array com gestores cujo usuแrio estแ amarrado como superior.
While FRS->(!Eof()) .And. FRS->FRS_TIPO == cTipo
	If FRS->FRS_CODSUP == cCodSup .And. aScan( aAprov, bSeek ) == 0
		aAdd( aAprov, FRS->FRS_CODAPR + " - " + Fa006User( FRS->FRS_CODAPR ) )
	EndIf
	FRS->(dbSkip())
EndDo

RestArea(aAreaFRS)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581CfMov บAutor  ณ Danilo Dias      บ Data ณ 28/04/2011  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de confirma็ใo da libera็ใo das movimenta็๕es   rฑฑ
ฑฑบ          ณ do caixinha e transfer๊ncias de aprovadores.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581, FINA580                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cTitulo = Tํtulo para o MsDialog.                          ณฑฑ
ฑฑณ          ณ lBtnBlq = Ativa o botใo de bloqueio.                       ณฑฑ
ฑฑณ          ณ cAlias = Alias usado no MsDialog.                          ณฑฑ
ฑฑณ          ณ cNumInt = N๚mero do tํtulo ou movimento do caixinha.       ณฑฑ
ฑฑณ          ณ cEmissao = Data de emissใo do tํtulo ou movimento.         ณฑฑ
ฑฑณ          ณ dDtRef = Data de refer๊ncia da transa็ใo.                  ณฑฑ
ฑฑณ          ณ nTotal = Valor do tํtulo ou movimento.                     ณฑฑ
ฑฑณ          ณ cCpoVlr = Nome do campo que cont้m o valor para usar pict. ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581CfMov( cTitulo, lBtnBlq, cAlias, cNumInt, cEmissao,;
                     dDtRef, nTotal, cCpoVlr )

Local oDlg
Local oBtnAprov, oBtnCanc
Local cUsrAprov	:= FRP->FRP_USER
Local cCodAprov	:= FRP->FRP_COD
Local cNomAprov	:= Fa006User(cCodAprov)
Local cMoeda	:= FRP->FRP_MOEDA//CValToChar(FRP->FRP_MOEDA)//alterado por Fernando Radu Muscalu em 01/09/2011
Local nLimMin	:= FRP->FRP_LIMMIN
Local nLimMax	:= FRP->FRP_LIMMAX
Local aMovAprov	:= fXAlcSld( cMoeda, dDtRef, cCodAprov, .F. ) 	//Monta array com os movimentos do Gestor
Local nSldAprov	:= fxAlcSldFim( aMovAprov )	//Retorna o saldo atual do Gestor
Local aTipoLim	:= {}
Local cTipoLim	:= FRP->FRP_TIPO
Local nOpc		:= 0

Default lBtnBlq	:= .T.

//Carrega tipos de limite do campo combo pelo X3_CBOX
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
If SX3->(dbSeek("FRP_TIPO"))
	aTipoLim := StrToKarr( X3CBox(), ";" )
EndIf

//Cria Dialog de libera็ใo do movimento
oDlg := MSDialog():New( 0, 0, 300, 600, cTitulo, , , , , , , , oMainWnd, .T., , , , )

oGroup1 := TGroup():New( 002, 005, 042, 295, STR0052, oDlg,,,.T., )	//"Movimento"

	oSay     := TSay():New( 012, 010, { || STR0053 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"N๚mero Int."
    oNumInt  := TGet():New( 010, 070, { |u| If( PCount() > 0, cNumInt := u, cNumInt ) }, oGroup1, 060, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNumInt" )
    oSay     := TSay():New( 012, 170, { || STR0054 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"Emissใo"
    oEmissao := TGet():New( 010, 230, { |u| If( PCount() > 0, cEmissao := u, cEmissao ) }, oGroup1, 060, 010, "@D",,,,,,,.T.,,,{|| .F.},,,,,,,"cEmissao" )
    oSay     := TSay():New( 026, 170, { || STR0033 }, oGroup1,,,,,,.T.,,, 60, 10 )	//"Data de Ref."
    oDtRef   := TGet():New( 024, 230, { |u| If( PCount() > 0, dDtRef := u, dDtRef ) }, oGroup1, 060, 010,,,,,,,,.T.,,,{|| .F.},,,,,,, "dDtRef" )
	oSay     := TSay():New( 026, 010, { || STR0055 }, oGroup1,,,,,,.T.,,, 80, 10 )	//"Valor"
    oTotal   := TGet():New( 024, 070, { |u| If( PCount() > 0, nTotal := u, nTotal ) }, oGroup1, 060, 010, (cAlias)->(X3Picture(cCpoVlr)),,,,,,,.T.,,,{|| .F.},,,,,,,"nTotal" )

oGroup2 := TGroup():New( 050, 005, 105, 295, STR0056, oDlg,,,.T., )	//"Aprovador"

    oSay     := TSay():New( 060, 010, { || STR0056 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Aprovador"
    oAprov   := TGet():New( 058, 070, { |u| If( PCount() > 0, cNomAprov := u, cNomAprov ) }, oGroup2, 220, 010,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNomAprov" )
    oSay     := TSay():New( 076, 010, { || STR0057 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Limite Mํn."
    oLimMin  := TGet():New( 074, 070, { |u| If( PCount() > 0, nLimMin := u, nLimMin ) }, oGroup2, 060, 010, FRP->(X3Picture("FRP_LIMMIN")),,,,,,,.T.,,,{|| .F.},,,,,,,"nLimMin" )
    oSay     := TSay():New( 076, 170, { || STR0058 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Limite Mแx."
    oLimMax  := TGet():New( 074, 230, { |u| If( PCount() > 0, nLimMax := u, nLimMax ) }, oGroup2, 060, 010, FRP->(X3Picture("FRP_LIMMAX")),,,,,,,.T.,,,{|| .F.},,,,,,,"nLimMax" )
    oSay     := TSay():New( 090, 010, { || STR0059 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Saldo"
    oLimite  := TGet():New( 088, 070, { |u| If( PCount() > 0, nSldAprov := u, nSldAprov ) }, oGroup2, 060, 010, FRP->(X3Picture("FRP_LIMITE")),,,,,,,.T.,,,{|| .F.},,,,,,,"nSldAprov" )
    oSay     := TSay():New( 090, 170, { || STR0060 }, oGroup2,,,,,,.T.,,, 60, 10 )	//"Tipo Lim."
    oTipoLim := TComboBox():New( 088, 230, { |u| If( PCount() > 0, cTipoLim := u, cTipoLim ) }, aTipoLim, 060, 010, oGroup2,,,,,,.T.,,,,{|| .F.},,,,, "cTipoLim" )

    oBtnAprov := tButton():New( 130, 070, STR0061 , oDlg, { || oDlg:End(), nOpc := 1 }, 050,,,,,.T.,,,,,,, )	//"Aprovar"
    oBtnAprov := tButton():New( 130, 130, STR0062 , oDlg, { || oDlg:End(), nOpc := 2 }, 050,,,,,lBtnBlq,,,,,,, )	//"Bloquear"
    oBtnCanc  := tButton():New( 130, 190, STR0051 , oDlg, { || oDlg:End(), nOpc := 0 }, 050,,,,,.T.,,,,,,, )	//"Cancelar"

oDlg:Activate( ,,,.T.,,,,, )

Return nOpc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Fa581CxAbe บAutor  ณ Yuri Porto     บ Data ณ 28/04/2011   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออสออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o caixa estแ aberto						      rฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA581                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cCaixa = COdigo do caixa na tabela SEU				   .  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa581CxAbe( cCaixa As Char) As logic
	Local aArea As Array
	Local lRet As logic
	lRet := .T.
	aArea := GetArea()

	SET->(dbSetOrder(1))
	iF SET->(dbSeek(xFilial("SET")+cCaixa))
		If SET->ET_SITUAC == "1"
			Help( " ", 1, ProcName(1),, STR0076,1,0 ) //"Caixa fechado. O movimento nใo pode ser realizado."
			lRet := .F.
		Endif
	EndIf
	
	RestArea(aArea)
Return lret
