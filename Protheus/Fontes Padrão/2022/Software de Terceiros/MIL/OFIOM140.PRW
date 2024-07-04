// ษออออออออหออออออออป
// บ Versao บ 109    บ  // Utilizar a Funcao HELP em mensagem de validacao, rotina alterada para ExecAuto
// ศออออออออสออออออออผ

#include "Ofiom140.ch"
#include "Protheus.ch"
#include "ofixdef.ch"

Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Static lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  21/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007480_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OFIOM140 ณ Autor ณ  Emilton              ณ Data ณ 07/01/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Liberacao da Ordem de Servico para Fechamento              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservacaoณ As tratativas das variaveis VOK_INCMOB/VOK_INCTEM estao    ณฑฑ
ฑฑณ          ณ desmembradas apenas para documentar e facilitar a analise eณฑฑ
ฑฑณ          ณ eventuais implementacoes, caso passe a ser necessario      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM140(lNoMBrowse,xAutoCab,nOpcAuto)

Local aCores := {{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE'    } ,;	// Aberta
				{  'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,;	// Liberada
				{  'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,;	// Fechado
				{  'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }	// Cancelado

Default lNoMBrowse := .f.

//
Private aAutoCab   := {}
Private lOM140Auto := ( xAutoCab <> NIL )
Private oPecaHlp   := DMS_Peca():New()
//

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0003) //Liberacao de Ordens de Servico
Private aIndVO1   := {}

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(14)
	Return
EndIf

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

dbSelectArea("VO1")
dbSetOrder(1)

If !lOM140Auto
	If lNoMBrowse
		dbSelectArea("VO1")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else
		If VAI->VAI_TIPTEC == "4"
			mBrowse( 6, 1,22,75,"VO1",,,,,,aCores,,,,, .f. ,,, " VO1_FUNABE = '" + VAI->VAI_CODTEC + "'" )
		Else
			mBrowse( 6, 1,22,75,"VO1",,,,,,aCores)
		Endif
	Endif
Else
	aAutoCab := xAutoCab
	nPos := aScan( aAutoCab , { |x| x[1] == "VO1_NUMOSV" } )
	VO1->(dbSetOrder(1))
	VO1->(dbSeek( xFilial("VO1") + aAutoCab[nPos,2] ))
	MBrowseAuto( nOpcAuto , , "VO1" , .f. )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM140I บAutor  ณFabio               บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM140I(cAlias, nReg, nOpc)

Local cQuery    := ""
Local cQAlias   := "SQLVO1"
Local cSB1NEnc  := "" // SB1 nao encontrados

Local lFechaDlg := .f.

// Variaveis para posicionamento de Tela
Local aObjects 	:= {}
Local aPosObj 	:= {}
Local aInfo 	:= {}
Local aSizeAut 	:= MsAdvSize()

Local lMarcar   := .f.

// Controla as pecas/servicos selecionados ...
Local aSelPeca  := {}	// Estrutura igual ao retorno da funcao FMX_CALPEC
Local aSelSrvc  := {}	// Estrutura igual ao retorno da funcao FMX_CALSER

Local nPos      := 0
Local cTipTem
Local lSaiVeiAuto

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da Enchoice ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nModelo   := 3
Local lF3       := .f.
Local lMemoria  := .t.
Local cATela    := ""
Local lProperty := .f.
Local aNewBot   := {}
//
Private lBaixou := .f.
Private nRegLib := nReg
Private oDlgLibOsv

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private aCpoEnchoice := {}

Private cTitle := STR0003 //Liberacao de Ordens de Servico

Private cLinOk , cFieldOk , nLinhas := 0

Private aSitOsv := {}

Private lLibParcial := .f.
Private lLibSep		:= .f.


If VO1->VO1_STATUS # "A"
	Help("  ",1,"OSNABERTA")
	dbSelectArea("VO1")
	dbSetOrder(1)
	Return .f.
EndIf

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFNC 29708/2009 - Rubens                              ณ
//ณVerifica se o usuario tem autorizacao para liberar OSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if VAI->(FieldPos("VAI_LIBOSV")) > 0 .and. VAI->VAI_LIBOSV <> "1"
	Help("  ",1,"M140VALLIB")
	Return .f.
endif

If VAI->(FieldPos("VAI_LIBPAR")) > 0 .and. VAI->VAI_LIBPAR == "1" 
	lLibParcial := .t. // Permissao para o usuแrio
EndIf

dbSelectArea("VV1")
dbSetOrder(1)

//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO1")
aCpoEnchoice := {}
While !Eof().and.(SX3->X3_ARQUIVO=="VO1")
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO) $ "VO1_FILIAL/VO1_GETKEY/VO1_CODMOT/VO1_NOMMOT/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_TEMFEC/VO1_TEMCAN/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR/VO1_MOTIVO/VO1_DESMOT")
		AADD(aCpoEnchoice,SX3->X3_CAMPO)
	EndIf
	If SX3->X3_CONTEXT == "V" .or. Alltrim(SX3->X3_CAMPO) $ "VO1_CHASSI"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VO1->"+SX3->X3_CAMPO)
	EndIf
	DbSkip()
Enddo
//

// Carrega os Tipos de Tempos da OS
aSitOsv := {}
aSelPeca := {}
aSelSrvc := {}
dbSelectArea("VO1")
If !OM140LVOS( @aSelPeca , @aSelSrvc , .f.)
	dbSelectArea("VO1")
	dbSetOrder(1)
	Help(" ",1,"M140SEMITE")
	return .f.
EndIf
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe os itens no cadastro de produtos ( SB1 )            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT SB1.R_E_C_N_O_ RECSB1 , VO3.VO3_GRUITE , VO3.VO3_CODITE "
cQuery += "FROM " + RetSQLName("VO2") + " VO2 "
cQuery += "JOIN " + RetSQLName("VO3") + " VO3 ON ( VO3.VO3_FILIAL=VO2.VO2_FILIAL AND VO3.VO3_NOSNUM=VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN " + RetSQLName("SB1") + " SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VO3.VO3_GRUITE AND SB1.B1_CODITE=VO3.VO3_CODITE AND SB1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VO2.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	If ( cQAlias )->( RECSB1 ) <= 0
		If nPos <= 5
			cSB1NEnc += ( cQAlias )->( VO3_GRUITE )+" "+( cQAlias )->( VO3_CODITE )+CHR(13)+CHR(10)
			nPos++
		Else
			cSB1NEnc += "..."
			Exit
		EndIf
	EndIf
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
dbSelectArea("VO1")
dbSetOrder(1)
If !Empty(cSB1NEnc)
	Help(" ",1,"M140SB1NENC",,cSB1NEnc,3,0)
	return .f.
EndIf
//
// Ponto de entrada para inclusao de botoes no acoes relacionadas da tela Principal de Libera็ใo de Ordem de Servi็o
If ExistBlock("OM140BOT") 
	aNewBot := ExecBlock("OM140BOT",.f.,.f.,{aNewBot})
EndIf
//
If !lOM140Auto
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 315, 050, .T., .T. } ) // EnchoiceBar
	AAdd( aObjects, { 315, 050, .T., .T. } ) // Listbox com Tipo de Tempo
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)
	//

	dbSelectArea("VO1")
	dbSetOrder(1)

	DEFINE MSDIALOG oDlgLibOsv FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE cTitle OF oMainWnd PIXEL

	oEnchVO1 := MSMGet():New("VO1",nReg, 2 /* Visualizar */ ,;
		/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, aPosObj[1], aCpoEnchoice, nModelo,;
		/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlgLibOsv , lF3, lMemoria, .F. /* lColumn */ ,;
		caTela, .t. /* lNoFolder */, lProperty)


	lMarcar := .t.
	// Listbox ...
	oSitOsv := TWBrowse():New(aPosObj[2,1],aPosObj[2,2],(aPosObj[2,4]-aPosObj[2,2]),(aPosObj[2,3]-aPosObj[2,1]),,,,oDlgLibOsv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oSitOsv:nAT := 1
	oSitOsv:SetArray(aSitOsv)
	oSitOsv:addColumn( TCColumn():New( ""	   , { || IIf(aSitOsv[oSitOsv:nAt,01],oOk,oNo) } 						,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Marcacao do Item
	oSitOsv:addColumn( TCColumn():New( STR0005 , { || aSitOsv[oSitOsv:nAt,02] }										,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Tipo de Tempo
	oSitOsv:addColumn( TCColumn():New( STR0006 , { || aSitOsv[oSitOsv:nAt,03] }										,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Codigo de Cliente
	oSitOsv:addColumn( TCColumn():New( STR0039 , { || aSitOsv[oSitOsv:nAt,04] }										,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Loja
	oSitOsv:addColumn( TCColumn():New( STR0007 , { || aSitOsv[oSitOsv:nAt,05] }										,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Nome do Cliente
	oSitOsv:addColumn( TCColumn():New( STR0082 , { || Transform(aSitOsv[oSitOsv:nAt,14],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Bruto Pecas
	oSitOsv:addColumn( TCColumn():New( STR0083 , { || Transform(aSitOsv[oSitOsv:nAt,15],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Desconto Pecas
	oSitOsv:addColumn( TCColumn():New( STR0008 , { || Transform(aSitOsv[oSitOsv:nAt,06],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Pecas
	oSitOsv:addColumn( TCColumn():New( STR0009 , { || aSitOsv[oSitOsv:nAt,07] }										,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // Horas Padrao
	oSitOsv:addColumn( TCColumn():New( STR0010 , { || aSitOsv[oSitOsv:nAt,08] }										,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // Hrs Trab.
	oSitOsv:addColumn( TCColumn():New( STR0084 , { || Transform(aSitOsv[oSitOsv:nAt,16],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Bruto Pecas
	oSitOsv:addColumn( TCColumn():New( STR0085 , { || Transform(aSitOsv[oSitOsv:nAt,17],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Desconto Pecas
	oSitOsv:addColumn( TCColumn():New( STR0011 , { || Transform(aSitOsv[oSitOsv:nAt,09],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Total de Servicos
	oSitOsv:addColumn( TCColumn():New( STR0012 , { || Transform(aSitOsv[oSitOsv:nAt,11],"@EZ 99999,999.99") }	,,,,"RIGHT",45,.F.,.F.,,,,.F.,) ) // Soma Total
	oSitOsv:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( OM140TIK( aSitOsv[oSitOsv:nAT,02] , oSitOsv:nAT , @aSelPeca , @aSelSrvc, .t. , lMarcar ) , lMarcar := !lMarcar , oSitOsv:Refresh() ) , Nil ) }
	oSitOsv:bLDblClick   := { || OM140TIK(  , oSitOsv:nAT , @aSelPeca , @aSelSrvc ) }
	oSitOsv:Refresh()

	ACTIVATE MSDIALOG oDlgLibOsv ON INIT (EnchoiceBar(oDlgLibOsv,{ || OM140OK(aSelPeca,aSelSrvc,@lFechaDlg) , IIF( lFechaDlg , oDlgLibOsv:End() , ) } , { || oDlgLibOsv:End() } ,, aNewBot ))
Else

	// Por enquanto so ExecAuto so funciona com tipo de tempo completo.
	lLibParcial := .f.
	
	// Procura o Tipo de Tempo para liberar ...
	nPos := aScan( aAutoCab , { |x| x[1] == "TIPTEM" } )
	cTipTem := aAutoCab[ nPos , 2 ]
	
	// Verifica se deve registrar saida de veiculo (TIPO DE TEMPO deve permitir o registro de saida na liberacao)
	lSaiVeiAuto := .f.
	If ( nPos := aScan( aAutoCab, { |x| x[1] == "SAIVEI" } ) ) <> 0
		lSaiVeiAuto := aAutoCab[ nPos , 2 ]
	EndIf
	//

	// Procura o Tipo de Tempo na matriz do Listbox
	If ( nPos := aScan( aSitOsv , { |x| x[2] == cTipTem } ) ) <= 0
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VOO_TIPTEM")) + ": " + cTipTem,4,1)	
		lMsErroAuto := .t.
		Return .f.		
	EndIf
	
	// Seleciona o tipo de tempo enviando
	OM140TIK(  , nPos , @aSelPeca , @aSelSrvc )
	// 
	
	If !OM140OK(aSelPeca,aSelSrvc,@lFechaDlg,lSaiVeiAuto)
		lMsErroAuto := .t.
		Return .f.
	EndIf
	
EndIf
dbSelectArea("VO1")
dbSetOrder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140OK   บAutor  ณRubens Takahashi    บ Data ณ  02/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ OK da Dialog Princpal                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140OK(aSelPeca, aSelSrvc, lFechaDlg,lSaiVeiAuto)

Local lRetorno := .t.

Default lSaiVeiAuto := .f. // Registra saida de veiculo (So deve ser utilizada quando for EXECAUTO) 

If lLibParcial
	OM140SELLP(aSelPeca,aSelSrvc,@lFechaDlg)
Else
	If OM140QTDNF("T",aSelPeca,aSelSrvc) .and. FS_LIBOSV(aSelPeca,aSelSrvc,lSaiVeiAuto)
		// Tenta atualizar a listbox de Tipo de Tempo da OS
		// Se nao conseguir, fecha a DIALOG principal ...
		If !lOM140Auto
			If !OM140LVOS( @aSelPeca , @aSelSrvc , .t. )
				lFechaDlg := .t.
			EndIf
		EndIf
	Else
		lRetorno := .f.
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140LVOS บAutor  ณFabio / Emilton     บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz levantamento da Ordem de Servico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140LVOS(aSelPeca, aSelSrvc, lRefresh, aTipTem )

Local aCalPec, aCalSer, nCont, nContTT
Local cTipTem
Local lTotal	// Controla se o levantamento sera total ou por Tipo de Tempo

Local lRetorno := .t.

Default aTipTem := {}

// Se for passado o aTipTem, deve atualizar somente este Tipo de Tempo ...
// Entao os itens deste tipo de tempo, devem ser excluidos da matriz ...
If Len(aTipTem) <> 0

	lTotal := .f.

	For nContTT := 1 to Len(aTipTem)

		// Zera totalizadores do tipo de tempo
		nPos := aScan(aSitOsv,{|x| x[2] == aTipTem[nContTT]})
		If nPos <> 0
			aDel( aSitOsv , nPos )
			aSize( aSitOsv, Len(aSitOsv) - 1 )
		EndIf
		//

		nCont := 1
		While nCont <= Len(aSelPeca)
			If aSelPeca[nCont,03] == aTipTem[nContTT]
				aDel( aSelPeca , nCont )
				aSize( aSelPeca , Len(aSelPeca) - 1 )
				Loop
			EndIf
			nCont++
		End

		nCont := 1
		While nCont <= Len(aSelSrvc)
			If aSelSrvc[nCont,04] == aTipTem[nContTT]
				aDel( aSelSrvc , nCont )
				aSize( aSelSrvc , Len(aSelSrvc) - 1 )
				Loop
			EndIf
			nCont++
		End

	Next nContTT
Else
	aSitOsv  := {}
	aSelPeca := {}
	aSelSrvc := {}
	lTotal := .t.
	aTipTem := { " " } // adiciona uma posicao so para conseguir entrar no FOR abaixo ...
EndIf
//

For nContTT := 1 to Len(aTipTem)

	If lTotal
		cTipTem := NIL
	Else
		cTipTem := aTipTem[nContTT]
	EndIf

	// Processa requisicao de pecas ...
	aCalPec := FMX_CALPEC(VO1->VO1_NUMOSV , cTipTem , /* cGruIte */ , /* cCodIte */ , .t. /* lMov */ , .t. /* lNegoc */ , .f. /* lReqZerada */ , .t. /* lRetAbe */ , .f. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */ , /* cLibVOO */ , /* cFiltroSQL */ , .t. /* lRetRem */ )
	For nCont := 1 to Len(aCalPec)

		// Adiciona na matriz de Peca ...
		AADD(aSelPeca , Array(Len(aCalPec[nCont])+1 ) )
		nPos := Len(aSelPeca)
		aEval( aCalPec[nCont] , { |x,nIndex| aSelPeca[nPos,nIndex] := x } )
		aSelPeca[nCont,Len(aSelPeca[nCont])] := .f. // Controla se o registro foi selecionado
		//

		nPos := aScan(aSitOsv,{|x| x[2] == aCalPec[nCont,03]})
		If nPos == 0

			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1") + aCalPec[nCont,15] + aCalPec[nCont,16] ))

			OM140ADMAT(aCalPec[nCont,03],aCalPec[nCont,15],aCalPec[nCont,16],SA1->A1_NREDUZ)

			nPos := Len(aSitOsv)
		EndIf

		aSitOsv[nPos,12] := .t.

		aSitOsv[nPos,06] += aCalPec[nCont,10] - aCalPec[nCont,07]	// 06 - Total de Pecas

		aSitOsv[nPos,14] += aCalPec[nCont,10]		// 14 - Total Bruto de Pecas
		aSitOsv[nPos,15] += aCalPec[nCont,07]		// 15 - Total Desconto de Pecas
	Next nCont
	//

	// Processa Requisicao de Servicos ...
	aCalSer := FMX_CALSER(VO1->VO1_NUMOSV , cTipTem ,  /* cGruSer */ ,  /* cCodSer */ , .t.  /* lApont */ , .t. /* lNegoc */ , .t. /* lRetAbe */ , .f. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ )
	For nCont := 1 to Len(aCalSer)

		// Adiciona na matriz de Servico ...
		AADD(aSelSrvc , Array(Len(aCalSer[nCont])+1 ) )
		nPos := Len(aSelSrvc)
		aEval( aCalSer[nCont] , { |x,nIndex| aSelSrvc[nPos,nIndex] := x } )
		aSelSrvc[nCont,Len(aSelSrvc[nCont])] := .f. // Controla se o registro foi selecionado
		//

		nPos := aScan(aSitOsv,{|x| x[2] == aCalSer[nCont,04]})
		If nPos == 0

			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1") + aCalSer[nCont,20] + aCalSer[nCont,21] ))

			OM140ADMAT(aCalSer[nCont,04] , aCalSer[nCont,20] , aCalSer[nCont,21] , SA1->A1_NREDUZ)

			nPos := Len(aSitOsv)
		EndIf

		aSitOsv[nPos,13] := .t.

		aSitOsv[nPos,07] += aCalSer[nCont,10]
		aSitOsv[nPos,08] += aCalSer[nCont,11]
		aSitOsv[nPos,09] += aCalSer[nCont,09]
		aSitOsv[nPos,16] += aCalSer[nCont,07]		// 16 - Total Bruto de Servicos
		aSitOsv[nPos,17] += aCalSer[nCont,08]		// 17 - Total Desconto de Servicos

	Next nCont
	//

Next nContTT

If Len(aSitOsv) > 0
	// Gera total Geral de Pecas e Servicos
	aEval( aSitOsv , {|x| x[11] := x[06] + x[09] } )
	//

	aSort(aSitOsv,,,{|x,y| x[2] < y[2] })
Else
	OM140ADMAT("", "", "", "")
	lRetorno := .f.
EndIf

If !lOM140Auto .and. lRefresh
	oSitOsv:nAt := 1
	oSitOsv:SetArray(aSitOsv)
	oSitOsv:DrawSelect()
	oSitOsv:Refresh()
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140ADMAT บAutor  ณ Rubens            บ Data ณ  22/11/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona registro na matriz de tipo de tempo                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140ADMAT(cTipTem,cFatPar,cLojPar,cNome)

Local nAuxPos

AADD( aSitOsv , Array(17) )
nAuxPos := Len(aSitOsv)

aSitOsv[nAuxPos,01] := .f.
aSitOsv[nAuxPos,02] := cTipTem		// 02 - Tipo de Tempo
aSitOsv[nAuxPos,03] := cFatPar		// 03 - Faturar Para
aSitOsv[nAuxPos,04] := cLojPar		// 04 - Loja
aSitOsv[nAuxPos,05] := cNome		// 05 - Nome Reduzido
aSitOsv[nAuxPos,06] := 0			// 06 - Total de Pecas
aSitOsv[nAuxPos,07] := 0			// 07 - Total de Horas Padrao
aSitOsv[nAuxPos,08] := 0			// 08 - Total de Horas Trabalhado
aSitOsv[nAuxPos,09] := 0			// 09 - Total de Servi็os
aSitOsv[nAuxPos,10] := 0			// 10 - Total de Horas Fases ???
aSitOsv[nAuxPos,11] := 0			// 11 - Total de Pecas e Servicos
aSitOsv[nAuxPos,12] := .f.			// 12 - Tem Pe็a ???
aSitOsv[nAuxPos,13] := .f.			// 13 - Tem Servico ???
aSitOsv[nAuxPos,14] := 0			// 14 - Total Bruto de Pecas
aSitOsv[nAuxPos,15] := 0			// 15 - Total Desconto de Pecas
aSitOsv[nAuxPos,16] := 0			// 16 - Total Bruto de Servicos
aSitOsv[nAuxPos,17] := 0			// 17 - Total Desconto de Servicos

Return nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LIBOSV บAutor  ณEmilton / Fabio     บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Liberacao                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_LIBOSV(aSelPeca,aSelSrvc,lSaiVeiAuto)

Local nCont			:= 0
Local nContSitOsv	:= 0
Local nContSel		:= 0
Local nContMov		:= 0
Local lLibBoxPrisma	:= .f.
Local aItensNew		:= {}

Local nQtdEst := 0 // Qtde a ser estornada do reg. de ocorrencia de reserva
Local nQtdeVSJ
Local cAliasVA8 := "SQLVA8"
Local nHorDis := 0
Local cNumLibVOO := ""	// Numero da Liberacao
Local nTotPeca := 0
Local nTotSrvc := 0
Local nTotHorP := 0
Local nTotHorT := 0
Local aTTLibVOO := {} 	// Contem os TT Liberados + o Numero da Liberacao (Sera utilizado na funcao de garantia)
Local cQuery
Local oPeca := DMS_Peca():New()
Local cAliasVE6 := "SQLVE6"
Local lAnyBlq := .F.
Local lValApl := .t.

Local aLockVO3 := {}	// Contem os registros da VO3 que deverao ser bloqueados para alteracao ...
Local aLockVO4 := {} 	// Contem os registros da VO4 que deverao ser bloqueados para alteracao ...

Local lVO3_FUNDIS := (VO3->(FieldPos("VO3_FUNDIS")) <> 0)
Local lVO4_FUNDIS := (VO4->(FieldPos("VO4_FUNDIS")) <> 0)

Local lVSJCODIGO  := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)
Local lVSJSUGCOM  := (VSJ->(FieldPos("VSJ_SUGCOM")) <> 0)
Local lVAI_VOSFER := (VAI->(FieldPos("VAI_VOSFER")) <> 0)

Local cCodTec := POSICIONE("VAI", 4, xFilial("VAI") + __cUserID, "VAI_CODTEC")

Local aItemMov := {}
Local oEst     := DMS_Estoque():New()

Default lSaiVeiAuto := .f. // Registra saida de veiculo (So deve ser utilizada quando for EXECAUTO) 

Private lSaiVei := .f.
Private lMsErroAuto := .f. , lMsHelpAuto := .f., lMsFinalAuto := .f.

Private oOkCampanha := LoadBitmap( GetResources(), "LBOK" )
Private oNoCampanha := LoadBitmap( GetResources(), "LBNO" )

// Verifica se foi selecionado peca/servico para liberacao ...
If aScan( aSitOsv , { |x| x[1] } ) <= 0
	Help("  ",1,"M140NAOSEL")
	Return( .f. )
EndIf
//

// Valida km / hora trilha
If !FG_VKILHOR( VO1->VO1_CHAINT ,;
				IIf( !Empty(VO1->VO1_DATATE) , VO1->VO1_DATATE , VO1->VO1_DATABE ),;
				IIf( !Empty(VO1->VO1_HORATE) , VO1->VO1_HORATE , VO1->VO1_HORABE ),;
				VO1->VO1_KILOME,;
				VO1->VO1_HORTRI,;
				"LIB", VO1->VO1_NUMOSV )
	Return .f.
EndIf
//

// Valida se o TT nใo estแ zerado
For nCont := 1 to Len(aSitOsv)
	If aSitOsv[nCont,1]
		// Procura alguma peca com valor zerado
		If (nPosPeca := aScan( aSelPeca , { |x| x[Len(x)] .and. x[03] == aSitOsv[nCont,02] .and. x[05] <> 0 .and. ( x[10] - x[07] ) <= 0 } )) <> 0
			Help("  ",1,"M140TTZEROP",,;
				RetTitle("VO3_TIPTEM") + ": " + aSelPeca[nPosPeca,PECA_TIPTEM] + " " + CRLF + ;
				"Pe็a: " + aSelPeca[nPosPeca,PECA_GRUITE] + " " + aSelPeca[nPosPeca,PECA_CODITE] + CRLF + ;
				RetTitle("VO3_QTDREQ") + ": " + cValToChar(aSelPeca[nPosPeca,PECA_QTDREQ]) + CRLF + ;
				RetTitle("VO3_VALBRU") + ": " + cValToChar(aSelPeca[nPosPeca,PECA_VALBRU]) + CRLF + ;
				RetTitle("VO3_VALDES") + ": " + cValToChar(aSelPeca[nPosPeca,PECA_VALDES]),4,1)
			Return .f.
		EndIf
		// Procura um servico selecionado do mesmo tipo de tempo que nao seja cortesia e esteja com o valor zerado ...
		If aScan( aSelSrvc , { |x| x[04] == aSitOsv[nCont,02] .and. x[09] <= 0 .and. x[06] <> "0" .and. x[Len(x)] } ) <> 0
			Help("  ",1,"M140TTZEROS")
			Return .f.
		EndIf
		// Validar Ferramentas requisitadas para a OS e Tp.Tempo
		If lVAI_VOSFER
			If !OM450VFER( VO1->VO1_NUMOSV , aSitOsv[nCont,02] , "1" ) // 1 - Liberacao de OS
				Return .f.
			EndIf
		EndIf
		//
	EndIf
Next nCont
//
////////////////////////////////////////////////////////////////
// Manoel - 06/08/2012
// Chamado 001269 - Servi็os de Diagn๓stico
// Verifica se existe Servi็os de Diagn๓sticos apontados na OS
// Se houver, nao permite a Libera็ใo
////////////////////////////////////////////////////////////////
//
If GetNewPar("MV_LIBDIAG","S") == "N" //Nao permite Libera็ใo com Servi็os de Diagn๓stico apontados
	For nContSitOsv := 1 to Len(aSitOsv)
		If !aSitOsv[nContSitOsv,01]
			Loop
		EndIf
		If !OM140DIAG(aSitOsv[nContSitOsv,02])
			Help(" ",1,"OM140DIAG",,STR0076,1,1)
			Return .f.
		Endif
	Next
Endif
//
If !lOM140Auto
	// Apenas se hแ Servi็os selecionados para Libera็ใo do Tipo de Tempo
	If aScan(aSelSrvc, { |x| x[Len(x)] }) > 0
		VV1->(dbSetOrder(1)) // VV1_FILIAL + VV1_CHAINT
		VV1->(MsSeek( xFilial("VV1") + VO1->VO1_CHAINT ))

		// Relacionamento Servi็o X Campanha/Pend๊ncia/Assunto T้cnico
		If FindFunction("OFA1100056_RelacionaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
			lValApl := OFA1100056_RelacionaCampanha("VO1", nRegLib, 2, .t.)
		EndIf

		If !(lValApl)
			Help("  ", 1, "M140CAMPLIB")

			Return .f.
		EndIf
	Else
		lValApl := .f.
	EndIf

	If !MsgYesNo(STR0054, STR0041) // "Confirma a libera็ใo do Tipo de Tempo
		Return .f.
	EndIf
EndIf

If !lOM140Auto
	// Verifica se deve gerar um CheckList
	If VA8->(FieldPos("VA8_ENTSAI")) <> 0 .and. GetNewPar("MV_CHECKLI","S") == "S"
	
		cQuery := "SELECT DISTINCT VA8.VA8_NUMOSV "
		cQuery += " FROM " + RetSqlName( "VA8" ) + " VA8 "
		cQuery += "WHERE VA8.VA8_FILIAL='"+ xFilial("VA8")+ "' AND VA8.VA8_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VA8.VA8_ENTSAI = '1' AND "
		cQuery += "VA8.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVA8, .T., .T. )
		lAchou := (!( cAliasVA8 )->( Eof() ) )
		( cAliasVA8 )->( dbCloseArea() )
		dbSelectArea("VA8")
	
		if !lAchou
			If MsgYesNo( STR0053 ,STR0041)  // "Deseja fazer CheckList? "
				aSeek  := {}
				aSeek1 := {}
				dbSelectArea("VA8")
				dbSetOrder(1)
				if dbSeek(xFilial("VA8")+VO1->VO1_NUMOSV)
					DbSelectArea("SX3")
					DbSetOrder(1)
					DbSeek("VA8")
					While !Eof() .and. SX3->X3_ARQUIVO == "VA8"
	
						cCampo := x3_campo
						aAdd(aSeek,{"VA8->"+Alltrim(cCampo)})
						aAdd(aSeek1,{&("VA8->"+Alltrim(cCampo))})
	
						DbSelectArea("SX3")
						SX3->(dbSkip())
	
					Enddo
	
					dbSelectArea("VA8")
					dbSetOrder(1)
					dbSeek(xFilial("VA8")+VO1->VO1_NUMOSV)
					RecLock("VA8",.t.)
					For nCont := 1 to Len(aSeek)
						cVar := &(aSeek[nCont,1])
						wVal := aSeek[nCont,1]
						if wVal == "VA8->VA8_ENTSAI"
							&wVal := "1"
						Else
							&wVal := aSeek1[nCont,1]
						Endif
					Next
					MsUnlock()
	
				Endif
				OFIOA280("OFIOM140")
			Endif
		Endif
	Endif
	//
EndIf

//If Empty(VO1->VO1_DATSAI) .and. !Empty(VO1->VO1_NUMBOX)
If !Empty(VO1->VO1_NUMBOX)

	VOI->(dbSetOrder(1))
	lSaiVei := .f.

	For nContSitOsv := 1 to Len(aSitOsv)

		If !aSitOsv[nContSitOsv,01]
			Loop
		EndIf

		VOI->(dbSeek(xFilial("VOI") + aSitOsv[nContSitOsv,02] ))

		/////////////////////////////////////////////////////////////////////////////////
		//  Registrar a SAIDA do VEICULO no momento da Liberacao da OS                 //
		//  Andre Luis Almeida                                             28/08/2009  //
		/////////////////////////////////////////////////////////////////////////////////
		If VOI->VOI_SAIVEI == "1" .and. Empty(VO1->VO1_DATSAI)// Registrar SAIDA do VEICULO na Liberacao da OS ( 0=Nao Registra / 1=Liberacao OS / 2=Fechamento OS )
			If !lOM140Auto
				If MsgYesNo(STR0030,STR0031) // Deseja registrar a saida do veiculo ?### Atencao
					lSaiVei := .t.
					Exit
				EndIf
			Else
				lSaiVei := lSaiVeiAuto
				Exit
			EndIf
		EndIf
		//

	Next nContSitOsv

EndIf

If ExistBlock("OM140CHK")
	lRetorno := ExecBlock("OM140CHK",.F.,.F.)
	If !lRetorno
		Return(lRetorno)
	Endif
EndIf

lAnyBlq := .F.
// Se nใo utiliza a liberacao parcial, carrega novamente todas as pecas/servicos dos TT Selecionados ...
If ! lLibParcial
	aSelPeca := {}
	aSelSrvc := {}
	For nContSitOsv := 1 to Len(aSitOsv)
		If !aSitOsv[nContSitOsv,01]
			Loop
		EndIf

		aCalPec := FMX_CALPEC(VO1->VO1_NUMOSV , aSitOsv[nContSitOsv,02] /* cTipTem */ , /* cGruIte */ , /* cCodIte */ , .t. /* lMov */ , .t. /* lNegoc */ , .f. /* lReqZerada */ , .t. /* lRetAbe */ , .f. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */  , /* cLibVOO */ , /* cFiltroSQL */ , .t. /* lRetRem */ )
		If Len(aCalPec) > 0
			For nContSel := 1 to Len(aCalPec)
				if oPeca:Bloqueado(, aCalPec[nContSel, 02], aCalPec[nContSel, 01])
					lAnyBlq := .T.
				end
				AADD( aSelPeca , aCalPec[nContSel] )
				aSize( aSelPeca[Len(aSelPeca)] , Len(aSelPeca[Len(aSelPeca)]) + 1 )
				aSelPeca[Len(aSelPeca),Len(aSelPeca[Len(aSelPeca)])] := .t.
			Next nContSel
		EndIf
		if lAnyBlq // algum item bloqueado? B1_MSBLQL
			return .F.
		end

		aCalSer := FMX_CALSER(VO1->VO1_NUMOSV , aSitOsv[nContSitOsv,02] /* cTipTem */ ,  /* cGruSer */ ,  /* cCodSer */ , .t.  /* lApont */ , .t. /* lNegoc */ , .t. /* lRetAbe */ , .f. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ )
		If Len(aCalSer) > 0
			For nContSel := 1 to Len(aCalSer)
				AADD( aSelSrvc , aCalSer[nContSel] )
				aSize( aSelSrvc[Len(aSelSrvc)] , Len(aSelSrvc[Len(aSelSrvc)]) + 1 )
				aSelSrvc[Len(aSelSrvc),Len(aSelSrvc[Len(aSelSrvc)])] := .t.
			Next nContSel
		EndIf
	Next nContSitOsv
EndIf
//
// Bloqueia todos os registros da VO3 e VO4 para verificar se pode continuar a liberacao...
aLockVO3 := {}
aLockVO4 := {}
For nCont := 1 to Len(aSelPeca)
	If aSelPeca[nCont, Len(aSelPeca[nCont])]
		For nContSel := 1 to Len(aSelPeca[nCont,14])
			VO3->(dbGoTo( aSelPeca[ nCont , 14 , nContSel , 05 ] ))
			AADD( aLockVO3 , VO3->VO3_GRUITE + VO3->VO3_CODITE + VO3->VO3_NOSNUM + VO3->VO3_TIPTEM + VO3->VO3_SEQINC )
		Next nContSel
	EndIf
Next nCont

For nCont := 1 to Len(aSelSrvc)
	If aSelSrvc[nCont, Len(aSelSrvc[nCont])]
		For nContSel := 1 to Len(aSelSrvc[nCont,14])
			VO4->(dbGoTo( aSelSrvc[ nCont , 14 , nContSel , 08 ] ))
			AADD( aLockVO4 , VO4->VO4_NOSNUM + VO4->VO4_SEQUEN )
		Next nContSel
	EndIf
Next nCont

// --------------------------------------------------------- //
// Gravando a liberacao dos Tipo de Tempos Selecionados ...  //
// --------------------------------------------------------- //
Begin Transaction

If !MultLock("VO3",aLockVO3,2) .and. !MultLock("VO4",aLockVO4,8)
	MsUnlockAll()
	DisarmTransaction()
	Return .f.
EndIf
//

// Valida todos os TT's Selecionados
For nContSitOsv := 1 to len(aSitOsv)
	If !aSitOsv[nContSitOsv,01]
		Loop
	EndIf

	If !FS_VALOSV( nContSitOsv , .f. , aSelPeca , aSelSrvc )
		DisarmTransaction()
		Return .f.
	EndIf

Next nContSitOsv
//

nHorDis := val(left(time(),2)+substr(time(),4,2))

lMsHelpAuto := .T.

For nContSitOsv := 1 to len(aSitOsv)

	aItensNew:={}

	If !aSitOsv[nContSitOsv,01]
		Loop
	EndIf

	nTotPeca := 0
	nTotSrvc := 0
	nTotHorP := 0
	nTotHorT := 0

	VOI->(dbSetOrder(1))
	VOI->(dbSeek(xFilial("VOI") + aSitOsv[nContSitOsv,02] ))

	cNumLibVOO := GetSXENum("VOO","VOO_LIBVOO")

	// Grava na matriz que sera utilizado na funcao de garantia ...
	AADD( aTTLibVOO , { aSitOsv[nContSitOsv,02] , cNumLibVOO } )

	// Grava Disp/Cancelamento da OS
	dbSelectArea("VOZ")
	RecLock("VOZ",.t.)
	VOZ->VOZ_FILIAL := xFilial("VOZ")
	VOZ->VOZ_NUMOSV := VO1->VO1_NUMOSV
	VOZ->VOZ_LIBVOO := cNumLibVOO
	VOZ->VOZ_TIPTEM := aSitOsv[nContSitOsv,02]
	VOZ->VOZ_DATOCO := dDataBase
	VOZ->VOZ_DISCAN := "D"
	VOZ->VOZ_CODCON := cCodTec
	VOZ->VOZ_CODMOT := ""
	MsUnlock()
	//

	dbSelectArea("VOO")
	RegToMemory("VOO",.t.,.t.,.t.)
	RecLock("VOO",.t.)
	FG_GRAVAR("VOO")
	VOO->VOO_FILIAL := xFilial("VOO")
	VOO->VOO_NUMOSV := VO1->VO1_NUMOSV
	VOO->VOO_LIBVOO := cNumLibVOO
	VOO->VOO_TIPTEM := aSitOsv[nContSitOsv,02]
	VOO->VOO_FATPAR := aSitOsv[nContSitOsv,03]
	VOO->VOO_LOJA   := aSitOsv[nContSitOsv,04]
	MsUnlock()

	// Atualiza a OS ...
	dbSelectArea("VO1")
	RecLock("VO1",.f.)
	VO1->VO1_TEMLIB := "S"
	// Registra saida do veiculo
	If Empty(VO1->VO1_DATSAI) .and. lSaiVei// s๓ grava a data se Empty
		VO1->VO1_DATSAI := dDataBase
		VO1->VO1_HORSAI := nHorDis
	EndIf
	MsUnLock()
	//

	// Atualiza Requisicao de Pecas ...
	For nContSel := 1 to Len(aSelPeca)

		// ษ do mesmo tipo de tempo ...
		If aSelPeca[nContSel,03] <> aSitOsv[nContSitOsv,02]
			Loop
		EndIf

		// Verifica se foi selecionado para liberacao ...
		If !aSelPeca[nContSel,Len(aSelPeca[nContSel])]
			Loop
		EndIf

		// Loop nos registros de movimentacoes ...
		For nContMov := 1 to Len(aSelPeca[nContSel,14])

			VO3->(dbGoTo(aSelPeca[nContSel,14,nContMov,05]))
			RecLock("VO3",.f.)
			VO3->VO3_LIBVOO := cNumLibVOO
			If lVO3_FUNDIS // Tec. Lib. TT
				VO3->VO3_FUNDIS := cCodTec
			EndIf
			VO3->VO3_DATDIS := dDataBase
			VO3->VO3_HORDIS := nHorDis
			MsUnlock()

		Next nContMov

		VO3->(dbGoTo(VO3->(Recno())))

		nTotPeca += aSelPeca[nContSel,10] - aSelPeca[nContSel,07]

	Next nContSel
	//

	// Atualiza Requisicao de Servicos ...
	For nContSel := 1 to Len(aSelSrvc)

		// ษ do mesmo tipo de tempo ...
		If aSelSrvc[nContSel,04] <> aSitOsv[nContSitOsv,02]
			Loop
		EndIf

		// Verifica se foi selecionado para liberacao ...
		If !aSelSrvc[nContSel,Len(aSelSrvc[nContSel])]
			Loop
		EndIf

		// Loop nos registros de movimentacoes ...
		For nContMov := 1 to Len(aSelSrvc[nContSel,14])

			VO4->(dbGoTo(aSelSrvc[nContSel,14,nContMov,08]))
			RecLock("VO4",.f.)
			VO4->VO4_LIBVOO := cNumLibVOO
			If lVO4_FUNDIS // Tec. Lib. TT
				VO4->VO4_FUNDIS := cCodTec
			EndIf
			VO4->VO4_DATDIS := dDataBase
			VO4->VO4_HORDIS := nHorDis
			MsUnlock()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se o todos os TT foram liberados ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			VO4->(dbGoTo(VO4->(Recno()))) // Desposiciona para funcionar o SELECT Corretamente ...
			If FS_DISOSV()
				lLibBoxPrisma := .t.
			EndIf
			//

			// Marca Box
			FG_MARCABOX(,VO4->VO4_CODCOR,VO4->VO4_PRISMA,VO1->VO1_NUMOSV,lLibBoxPrisma,lSaiVei)
			//

		Next nContMov
		//

		VO4->(dbGoTo(VO4->(Recno())))

		nTotSrvc += aSelSrvc[nContSel,09]
		nTotHorP += aSelSrvc[nContSel,10]
		nTotHorT += aSelSrvc[nContSel,11]

	Next nContSel

	// Grava totais no VOO
	RecLock("VOO",.f.)
	VOO->VOO_TOTPEC := nTotPeca
	VOO->VOO_HRSPAD := nTotHorP
	VOO->VOO_HRSAPL := nTotHorT
	VOO->VOO_TOTSRV := nTotSrvc
	MsUnLock()
	//

	If FS_DISOSV()
		lLibBoxPrisma := .t.
	EndIf

	// Marca Box
	FG_MARCABOX(VO1->VO1_NUMBOX,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV,lLibBoxPrisma,lSaiVei)
	//

	// Libera็ใo de Tipo de Tempo (Campanha)
	If lValApl
		If FindFunction("OFA1100106_PercentualCampanhaVOP") .And. VOU->(FieldPos("VOU_SERINT")) > 0
			// Verificar se o Servi็o estแ Relacionado e entใo
			// executar a Libera็ใo do Tipo de Tempo (o campo "VOU_DATEXE" deve ser preenchido)
			// VO1
			DbSelectArea("VO1")
			DbSetOrder(1) // VO1_FILIAL + VO1_NUMOSV
			If DbSeek(xFilial("VO1") + VO1->VO1_NUMOSV)
				// VOU
				DbSelectArea("VOU")
				DbSetOrder(2) // VOU_FILIAL + VOU_CHASSI
				If DbSeek(xFilial("VOU") + VO1->VO1_CHASSI)
					While !VOU->(Eof()) .And. xFilial("VOU") == VOU->VOU_FILIAL .And. VO1->VO1_CHASSI == VOU->VOU_CHASSI .And. VO1->VO1_NUMOSV == VOU->VOU_NUMOSV
						If aSitOsv[nContSitOsv,02] == VOU->VOU_TIPTEM .And. Empty(VOU->VOU_DATEXE)
							RecLock("VOU", .F.)
							VOU->VOU_DATEXE := dDataBase
							MsUnlock()

							// Gravando percentual da Campanha
							OFA1100106_PercentualCampanhaVOP(VOU->VOU_NUMINT) // VOU_NUMINT
						EndIf

						VOU->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Deleta as pecas que foram importadas do Orcamento e nao foram requisitadas ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SB1")
	DbSetOrder(7)

	DbSelectArea("SB5")
	DbSetOrder(1)

	dbSelectArea("VE6")
	dbSetOrder(5) // VE6_NUMOSV+VE6_INDREG+VE6_GRUITE+VE6_CODITE

	dbSelectArea("VS1")
	DbSetOrder(1)

	dbSelectArea("VSJ")
	dbSeek(xFilial("VSJ")+VO1->VO1_NUMOSV)
	While VO1->VO1_NUMOSV == VSJ->VSJ_NUMOSV .and. xFilial("VSJ") == VSJ->VSJ_FILIAL .and. !VSJ->(eof())

		// Foi feito reserva ...
		If VSJ->VSJ_RESPEC == "1"

			DbSelectArea("SB1")
			DbSeek( xFilial("SB1") + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE )

			DbSelectArea("SB2")
			dbSetOrder(1)

			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+GetMv("MV_RESITE")))
			nSaldo := SaldoSB2()

			nQtdEst := VSJ->VSJ_QTDITE

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPL 31 - Shark - Rubens - 21/10/2009                                ณ
			//ณSe encontrar o registro de ocorrencia de reserva, estornar somente ณ
			//ณo saldo da reserva da OS                                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery := "SELECT R_E_C_N_O_ VE6RECNO "
			cQuery += "  FROM " + RetSQLName("VE6") + " VE6 "
			cQuery += " WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'"
			cQuery += "   AND VE6.VE6_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cQuery += "   AND VE6.VE6_INDREG = '3'" // Registro de Reserva
			cQuery += "   AND VE6.VE6_GRUITE = '" + VSJ->VSJ_GRUITE + "'"  
			cQuery += "   AND VE6.VE6_CODITE = '" + VSJ->VSJ_CODITE + "'"
			cQuery += "   AND VE6.VE6_LOTECT = '" + VSJ->VSJ_LOTECT + "'"
			cQuery += "   AND VE6.VE6_NUMLOT = '" + VSJ->VSJ_NUMLOT + "'"
			If lVSJSUGCOM .and. !Empty(VSJ->VSJ_SUGCOM)
				cQuery += " AND VE6.VE6_SUGCOM = '" + VSJ->VSJ_SUGCOM + "'"
			EndIf
			cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
			If FM_SQL(cQuery) > 0
				nQtdEst := FM_SALDORESV(VSJ->VSJ_GRUITE,VSJ->VSJ_CODITE,VO1->VO1_NUMOSV,VSJ->VSJ_LOTECT,VSJ->VSJ_NUMLOT,IIf(lVSJSUGCOM,VSJ->VSJ_SUGCOM,""))
			ENDIF

			If nQtdEst > nSaldo
				nQtdEst := nSaldo
			EndIf

			IF nQtdEst > 0

				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				If Len(aItensNew) == 0
					aadd (aItensNew,{ NextNumero("SD3",2,"D3_DOC",.t.), ddatabase})
				EndIf
				//

				DbSelectArea("SB5")
				DbSeek( xFilial("SB5") + SB1->B1_COD )

				aItemMov := oEst:SetItemSD3(SB1->B1_COD               ,; //C๓digo do Produto
											GetMv( "MV_RESITE" )      ,; // Armaz้m de Origem
											FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")  ,; // Armaz้m de Destino
											GetMv( "MV_RESLOC" )      ,; // Localiza็ใo Origem
											FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,; // Localiza็ใo Destino
											nQtdEst                   ,; // Qtd a transferir
											VE6->VE6_LOTECT           ,; // Nro de lote
											VE6->VE6_NUMLOT           ,; // Nro de Sub-Lote
											VE6->VE6_NUMSER            ) // Nro de S้rie

				aAdd(aItensNew, aClone(aItemMov))
				//

			ENDIF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHฟ
			//ณPL 31 - Shark - Rubens                                      ณ
			//ณSe tiver com o parametro de reserva automatica, procura o   ณ
			//ณregistro de ocorrencia de reserva e atualiza as quantidades ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHู
			cQuery := "SELECT R_E_C_N_O_ VE6RECNO "
			cQuery += "  FROM " + RetSQLName("VE6") + " VE6 "
			cQuery += " WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'"
			cQuery += "   AND VE6.VE6_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cQuery += "   AND VE6.VE6_INDREG = '3'" // Registro de Reserva
			cQuery += "   AND VE6.VE6_GRUITE = '" + VSJ->VSJ_GRUITE + "'"  
			cQuery += "   AND VE6.VE6_CODITE = '" + VSJ->VSJ_CODITE + "'"
			cQuery += "   AND VE6.VE6_LOTECT = '" + VSJ->VSJ_LOTECT + "'"
			cQuery += "   AND VE6.VE6_NUMLOT = '" + VSJ->VSJ_NUMLOT + "'"
			If lVSJSUGCOM .and. !Empty(VSJ->VSJ_SUGCOM)
				cQuery += " AND VE6.VE6_SUGCOM = '" + VSJ->VSJ_SUGCOM + "'"
			EndIf
			cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVE6, .F., .T. )
			While !(cAliasVE6)->(Eof())
				VE6->(dbGoTo((cAliasVE6)->VE6RECNO))

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณProcessa somente registro de reserva com saldoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF (VE6->VE6_QTDITE - VE6->VE6_QTDATE - VE6->VE6_QTDEST) > 0
					dbSelectArea("VE6")
					RecLock("VE6",.f.)
					VE6->VE6_QTDEST += (VE6->VE6_QTDITE - VE6->VE6_QTDATE - VE6->VE6_QTDEST)
					MsUnLock()
				ENDIF

				(cAliasVE6)->(dbSkip())
			End
			(cAliasVE6)->(dbCloseArea())
			//
		EndIf

		DbSelectArea("VSJ")
		If lVSJCODIGO .and. !Empty(VSJ->VSJ_CODIGO)
			RecLock("VSJ",.f.,.t.)
			VSJ->VSJ_QTDITE := 0
		Else
			// Exclui registro do VSJ ...
			RecLock("VSJ",.f.,.t.)
			VSJ->(dbDelete())
		EndIf
		VSJ->(MsUnLock())
		//

		dbSkip()

	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o todos os TT foram liberados ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If FS_DISOSV()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPL 31 - Shark - Rubens                                 ณ
		//ณVerifica se ficou algum residuo de reserva sem estornarณ
		//ณSo Verifica se todas as pecas importadas de ORCAMENTO  ณ
		//ณTiverem sido requisitadas na OS                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nQtdeVSJ := FM_SQL("SELECT COUNT(*) " +;
							" FROM " + RetSQLName("VSJ") +;
							" WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "'" +;
							  " AND VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "'" +;
							  " AND VSJ_QTDITE > 0" +;
							  " AND D_E_L_E_T_ = ' '")
		IF nQtdeVSJ == 0 .and. FM_SALDORESV(,,VO1->VO1_NUMOSV) > 0

			VE6->(dbSeek(xFilial("VE6")+VO1->VO1_NUMOSV+"3"))
			While !VE6->(Eof()) .and. VE6->VE6_FILIAL == xFilial("VE6");
				.and. VE6->VE6_NUMOSV == VO1->VO1_NUMOSV;
				.and. VE6->VE6_INDREG == "3"

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณProcessa somente registro de reserva com saldoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF (VE6->VE6_QTDITE - VE6->VE6_QTDATE - VE6->VE6_QTDEST) > 0

					DbSelectArea("SB1")
					DbSeek( xFilial("SB1") + VE6->VE6_GRUITE + VE6->VE6_CODITE )
					oPeca:LoadB1()
					
					DbSelectArea("SB2")
					dbSetOrder(1)

					SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+GetMv("MV_RESITE")))
					nSaldo := SaldoSB2()

					nQtdEst := FM_SALDORESV(VSJ->VSJ_GRUITE,VSJ->VSJ_CODITE,VO1->VO1_NUMOSV,VSJ->VSJ_LOTECT,VSJ->VSJ_NUMLOT,IIf(lVSJSUGCOM,VSJ->VSJ_SUGCOM,""))

					If nQtdEst > nSaldo
						nQtdEst := nSaldo
					EndIf

					IF nQtdEst > 0

						// Adiciona cabecalho com numero do documento e data da transferencia modelo II
						If Len(aItensNew) == 0
							aadd (aItensNew,{ NextNumero("SD3",2,"D3_DOC",.t.), ddatabase})
						EndIf
						//
						DbSelectArea("SB5")
						DbSeek( xFilial("SB5") + SB1->B1_COD )

						AADD( aItensNew , Array(nTamAEstq) )
						nPosAEstq := Len(aItensNew)
						// Produto Origem
						aItensNew[nPosAEstq,01] := SB1->B1_COD
						aItensNew[nPosAEstq,02] := SB1->B1_DESC
						aItensNew[nPosAEstq,03] := SB1->B1_UM
						aItensNew[nPosAEstq,04] := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
						aItensNew[nPosAEstq,05] := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))),Space(15))
						// Produto Destino
						aItensNew[nPosAEstq,06] := SB1->B1_COD
						aItensNew[nPosAEstq,07] := SB1->B1_DESC
						aItensNew[nPosAEstq,08] := SB1->B1_UM
						aItensNew[nPosAEstq,09] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
						aItensNew[nPosAEstq,10] := IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),Space(15))
						//
						aItensNew[nPosAEstq,11] := VE6->VE6_NUMSER
						aItensNew[nPosAEstq,12] := VE6->VE6_LOTECT
						aItensNew[nPosAEstq,13] := VE6->VE6_NUMLOT
						aItensNew[nPosAEstq,14] := IIf( !Empty(VE6->VE6_LOTECT) , oPeca:LoteDtValid(VE6->VE6_LOTECT) , criavar('D3_DTVALID') )
						aItensNew[nPosAEstq,15] := criavar('D3_POTENCI')
						aItensNew[nPosAEstq,16] := nQtdEst
						aItensNew[nPosAEstq,17] := criavar("D3_QTSEGUM")
						aItensNew[nPosAEstq,18] := criavar("D3_ESTORNO")
						aItensNew[nPosAEstq,19] := criavar("D3_NUMSEQ")
						aItensNew[nPosAEstq,20] := criavar("D3_LOTECTL")
						aItensNew[nPosAEstq,21] := aItensNew[nPosAEstq,14]
					
						nUltPos := 21
						If l261IntWMS
							aItensNew[nPosAEstq,++nUltPos] := criavar("D3_SERVIC")
						EndIf
						aItensNew[nPosAEstq,++nUltPos] := criavar("D3_ITEMGRD")
						If SD3->(FieldPos("D3_IDDCF"))>0 .And. l261IntWMS
							aItensNew[nPosAEstq,++nUltPos] := criavar("D3_IDDCF")
						EndIf
						If SD3->(FieldPos("D3_OBSERVA")) <> 0
							aItensNew[nPosAEstq,++nUltPos] := criavar("D3_OBSERVA")
						EndIf
						//
					ENDIF

					// Atualiza a quantidade estornada do registro de ocorrencia ...
					dbSelectArea("VE6")
					RecLock("VE6",.f.)
					VE6->VE6_QTDEST += (VE6->VE6_QTDITE - VE6->VE6_QTDATE - VE6->VE6_QTDEST)
					MsUnLock()
					//

				ENDIF

				VE6->(dbSkip())
			End

		ENDIF

	EndIf
	
	If (ExistBlock("OM140AP"))
		aItensNew := ExecBlock("OM140AP", .f., .f., {aItensNew})
	EndIf

	If Len(aItensNew) > 0
		SB1->(DbSetOrder(1))
		MSExecAuto({|x| MATA261(x)},aItensNew)
		If lMsErroAuto
			cDecQtd := cValtoChar(tamsx3('VE6_QTDITE')[1]) + "," + cValToChar(tamsx3('VE6_QTDITE')[2])
			cDecAte := cValtoChar(tamsx3('VE6_QTDATE')[1]) + "," + cValToChar(tamsx3('VE6_QTDITE')[2])

			if cDecQtd != cDecAte
				conout(STR0104 /*"Alerta: Tamanho dos campos VE6_QTDITE e VE6_QTDATE diferentes podem causar problemas de reserva."*/)
			endif
			MostraErro()
			RollbackSX8()
			DisarmTransaction()
			Return .f.
		EndIf
	EndIf

	ConfirmSX8()

Next

// Importa Garantia ...
If !FS_IMPGAR(aTTLibVOO[1], aTTLibVOO )
	RollbackSX8()
	DisarmTransaction()
	Return .f.
EndIf
//

// Atualiza o Status da OS
dbSelectArea("VO1")
RecLock("VO1")
VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV," ")
MsUnlock()
//

If ExistBlock("VA140DPGR")
	If !ExecBlock("VA140DPGR",.f.,.f.,{VO1->VO1_NUMOSV})
		DisarmTransaction()
		Return .f.
	EndIf
EndIf

End Transaction
lMsHelpAuto := .f.

If lMsErroAuto
	MostraErro()
EndIf

return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPGAR บAutor  ณEmilton / Fabio     บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta para garantia                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPGAR( cTipTemPar , aTTLibVOO , cOperacao)

Local cFunExp := ""
Local ix1
Local lRetPE  := .t.
Local nCont   := 0
Local cMVMIL0006 := GetNewPar("MV_MIL0006","")
Local cCodMarVV1 := ""


Default aTTLibVOO := {{ cTipTemPar , "" }}
Default cOperacao := "D"

Private cTipTem

For nCont := 1 to Len(aTTLibVOO)

	cTipTem := aTTLibVOO[nCont,1]
	
	// Existe Casos de Garantia com Tipo de Tempo INTERNO
	If ExistBlock("OM140IGA")
		lRetPE := ExecBlock("OM140IGA",.F.,.F.,{cTipTem})
	EndIf
	//
	
	VOI->(DbSetOrder(1))
	VOI->(dbSeek( xFilial("VOI") + cTipTem ))
	If !VOI->VOI_SITTPO $ "2.4" .and. lRetPE
		Loop
	EndIf

	If cMVMIL0006 == "JD"
		cCodMarVV1 := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")
	Else
		cCodMarVV1 := VO1->VO1_CODMAR
	EndIf

	cFunExp := FMX_FEXPGA("1",cTipTem,cCodMarVV1)
	// Nao esta configurado para exportar garantia 
	If Empty(cFunExp)
		Loop
	EndIf
	//
	ix1 := At("(",cFunExp)
	If ix1 <> 0
		cFunExp := Left(cFunExp,ix1) + "'" + cOperacao + "','"+cTipTem+"','"+aTTLibVOO[nCont,2]+"')"
	EndIf
	// Funcao de Importacao para Garantia
	lMsHelpAuto := .f.
	If !FG_VERFORGAR(cFunExp)
		lMsHelpAuto := .t.
		Return .f.
	EndIf
	//
Next nCont

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140TIK  บAutor  ณ Rubens Takahashi   บ Data ณ  04/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca ou Desmarca a Linha do Listbox de Tipo de Tempo      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140TIK( cTipTem, nNroLin , aSelPeca , aSelSrvc , lTodos , lMarcar )

Local nCont := 0
Local lVAI_VOSFER := (VAI->(FieldPos("VAI_VOSFER")) <> 0)

Local oOficina := DMS_Oficina():New()

Default lTodos := .f.

// Desmarcar Tipo de Tempo
If lTodos .and. !lMarcar

	aEval( aSitOsv  , {|x| x[01] := .f. } )		// Desmarca todos os TT's
	aEval( aSelPeca , {|x| x[Len(x)] := .f. } )	// Desmarca todas as Pecas
	aEval( aSelSrvc , {|x| x[Len(x)] := .f. } )	// Desmarca todas as Servicos
	Return

// Desmarcar selecionado 
ElseIf aSitOsv[ nNroLin, 01 ]

	aEval( aSelPeca , {|x| IIF( x[3] == aSitOsv[nNroLin,02] , x[Len(x)] := .f. , ) } )	// Desmarca todas as Pecas
	aEval( aSelSrvc , {|x| IIF( x[4] == aSitOsv[nNroLin,02] , x[Len(x)] := .f. , ) } )	// Desmarca todas as Servicos

	aSitOsv[ nNroLin, 01 ] := .f.
	Return

EndIf

If lTodos
	nCont := 1
	nLenSitOsv := Len(aSitOsv)
Else
	nCont := nLenSitOsv := nNroLin
EndIf

While nCont <= nLenSitOsv

	If oOficina:TipoTempoBloqueado(aSitOsv[nCont,02],.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Exit
	EndIf

	// Validar Ferramentas requisitadas para a OS e Tp.Tempo
	If lVAI_VOSFER
		If !OM450VFER( VO1->VO1_NUMOSV , aSitOsv[nCont,02] , "1" ) // 1 - Liberacao de OS
			Exit
		EndIf
	EndIf
	//

	// Marca as pecas e servicos de mesmo tipo de tempo ...
	aEval( aSelPeca , {|x| IIF( x[3] == aSitOsv[nCont,02] , x[Len(x)] := .t. , ) } )
	aEval( aSelSrvc , {|x| IIF( x[4] == aSitOsv[nCont,02] , x[Len(x)] := .t. , ) } )
	//

	If FS_VALOSV( nCont ,.t. , aSelPeca , aSelSrvc)
		aSitOsv[ nCont, 01 ] := .t.
	Else
	// Desmarca as pecas e servicos de mesmo tipo de tempo ...
		aEval( aSelPeca , {|x| IIF( x[3] == aSitOsv[nCont,02] , x[Len(x)] := .f. , ) } )
		aEval( aSelSrvc , {|x| IIF( x[4] == aSitOsv[nCont,02] , x[Len(x)] := .f. , ) } )
		//
	EndIf

	++nCont
End


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140CRMATบAutor  ณ Rubens Takahashi   บ Data ณ  19/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria matriz com pecas/servicos do Listbox de Selecao para  บฑฑ
ฑฑบ          ณ Liberacao                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140CRMAT(aTipTem, aSelPeca, aSelSrvc, aLibPeca, aLibSrvc)

Local nCont := 0

// Cria matriz de pecas ..
aLibPeca := {}
For nCont := 1 to Len(aSelPeca)
	// Do tipo de tempo selecionado e valor maior que zero
	If aScan( aTipTem , aSelPeca[nCont,03] ) <> 0 .and. aSelPeca[nCont,10] <> 0
		AADD(aLibPeca , { nCont ,;
						  .f. , ;
						  aSelPeca[nCont,01] ,;
						  aSelPeca[nCont,02] ,;
						  aSelPeca[nCont,13] ,;
						  aSelPeca[nCont,05] ,;
						  aSelPeca[nCont,20] ,;
						  aSelPeca[nCont,21] ,;
						  aSelPeca[nCont,22] ,;
						  aSelPeca[nCont,23] ,;
						  aSelPeca[nCont,03] ,;
						  aSelPeca[nCont,PECA_LOTECT] ,;
						  aSelPeca[nCont,PECA_NUMLOT] } )
	EndIf
	//
Next nCont
//

// Cria matriz de servicos ...
aLibSrvc := {}
For nCont := 1 to Len(aSelSrvc)
	If aScan( aTipTem , aSelSrvc[nCont,04] ) <> 0
		AADD(aLibSrvc , { nCont ,;
						  .f. ,;
						  aSelSrvc[nCont,01] ,;
						  aSelSrvc[nCont,02] ,;
						  aSelSrvc[nCont,15] ,;
						  aSelSrvc[nCont,05] ,;
						  aSelSrvc[nCont,10] ,;
						  aSelSrvc[nCont,33] ,;
						  aSelSrvc[nCont,34] ,;
						  aSelSrvc[nCont,35] ,;
						  aSelSrvc[nCont,36] ,;
						  aSelSrvc[nCont,04] } )
	EndIf
Next nCont
//

If Len(aLibPeca) == 0 .and. Len(aLibSrvc) == 0
	// Apos atualizacao de LIB/Bin o programa estava gerando um errorlog
	AADD( aLibPeca , { 0 , .f. , "" , "" , "" , 0 , "" , "" , "" , "" , "" , "" , "" } )
	AADD( aLibSrvc , { 0 , .f. , "" , "" , "" , "" , 0 , "" , "" , "" , "" , ""} )
	Return .f.
Endif

If Len(aLibPeca) == 0
	AADD( aLibPeca , { 0 , .f. , "" , "" , "" , 0 , "" , "" , "" , "" , "" , "" , "" } )
EndIf
If Len(aLibSrvc) == 0
	AADD( aLibSrvc , { 0 , .f. , "" , "" , "" , "" , 0 , "" , "" , "" , "" , ""} )
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140SELLPบAutor  ณ Rubens Takahashi   บ Data ณ  02/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona pecas e servicos para liberacao parcial de tipo  บฑฑ
ฑฑบ          ณ tempo                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140SELLP(aSelPeca,aSelSrvc,lFechaDlg)

Local aLibPeca := {}
Local aLibSrvc := {}
Local aObjects := {}
Local aPosObj := {}
Local aInfo := {}
Local aSizeAut := MsAdvSize(.t.) // Variaveis para posicionamento de Tela
Local nCont
Local aAuxTipTem := {}

For nCont := 1 to Len(aSitOsv)
	If aSitOsv[nCont,01]
		AADD( aAuxTipTem, aSitOsv[nCont,02] )
	EndIf
Next nCont

// Cria as matrizes de Pecas e Servicos ...
OM140CRMAT(aAuxTipTem, aSelPeca, aSelSrvc, @aLibPeca, @aLibSrvc)
//

// Redimensiona Dialog Principal
aSizeAut[5] := Round(aSizeAut[5] * 0.9,0)
aSizeAut[6] := Round(aSizeAut[6] * 0.8,0)
//

DEFINE MSDIALOG oDlgPecSrv FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE STR0055 OF oMainWnd PIXEL // "Sele็ใo de Pe็as/Servi็os"

// Calcula tamanho da Dialog para trabalhar com os controles
aSizeAut[3] := Int(oDlgPecSrv:nClientWidth / 2)
If SetMDIChild()
	aSizeAut[4] := Int(oDlgPecSrv:nClientHeight / 2) - 16
Else
	aSizeAut[4] := Int(oDlgPecSrv:nClientHeight / 2) - 4
EndIf
//

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 050, .T., .T. } ) // Pecas
AAdd( aObjects, { 000, 050, .T., .T. } ) // Servicos
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects, .t.)
//

@ aPosObj[1,1]-000 , aPosObj[1,2] TO aPosObj[1,3]-005 , aPosObj[1,4] LABEL STR0056 OF oDlgPecSrv PIXEL // "Pe็as"
@ aPosObj[2,1]-005 , aPosObj[2,2] TO aPosObj[2,3]-010 , aPosObj[2,4] LABEL STR0057 OF oDlgPecSrv PIXEL // "Servi็os"

// Listbox de Pecas ...
oLboxPeca := TWBrowse():New( aPosObj[1,1] + 8 ,aPosObj[1,2] + 2 ,aPosObj[1,4] - aPosObj[1,2] - 4,aPosObj[1,3] - aPosObj[1,1] - 15 ,,,,oDlgPecSrv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLboxPeca:nAt := 1
oLboxPeca:SetArray(aLibPeca)
oLboxPeca:addColumn( TCColumn():New( ""                    	,{ || If(oLboxPeca:aArray[oLboxPeca:nAt,02],oOk,oNo) } ,,,,"LEFT" ,05,.t.,.F.,,,,.F.,) ) // Marcacao do Item
oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_TIPTEM")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,11] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Tipo de Tempo
oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_GRUITE")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,03] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Grupo
oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_CODITE")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,04] } ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Codigo
oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_DESITE")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,05] } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) //Descricao
If lCtrlLote
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_LOTECT")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,12] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Lote
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_NUMLOT")	,{ || oLboxPeca:aArray[oLboxPeca:nAt,13] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Sub-Lote
EndIf
oLboxPeca:addColumn( TCColumn():New( RetTitle("VO3_QTDREQ")	,{ || Transform(oLboxPeca:aArray[oLboxPeca:nAt,06],"@E 999,999,999") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) //Quantidade
If lInconveniente
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VSJ_GRUINC"),{ || oLboxPeca:aArray[oLboxPeca:nAt,07] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Cod do Grupo
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VSJ_CODINC"),{ || oLboxPeca:aArray[oLboxPeca:nAt,08] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Inconvenient
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VSJ_SEQINC"),{ || oLboxPeca:aArray[oLboxPeca:nAt,09] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Seq. Inconveniente - VST
	oLboxPeca:addColumn( TCColumn():New( RetTitle("VSJ_DESINC"),{ || oLboxPeca:aArray[oLboxPeca:nAt,10] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) //Descr Inconv
EndIf
oLboxPeca:bHeaderClick := { |oObj,nCol| FS_PecHC(oObj, nCol) }
oLboxPeca:bLDblClick   := { || IIf( !Empty(aLibPeca[oLboxPeca:nAt,04]) .AND. FS_PodeSelPec() , ( aLibPeca[oLboxPeca:nAt,02] := !aLibPeca[oLboxPeca:nAt,02] , OM140QTDNF("P",aLibPeca,aLibSrvc) ) , Nil ) }
oLboxPeca:Refresh()
//

// Listbox de Servicos ...
oLboxSrvc := TWBrowse():New( aPosObj[2,1] + 3 ,aPosObj[2,2] + 2 ,aPosObj[2,4] - aPosObj[2,2] - 4,aPosObj[2,3] - aPosObj[2,1] - 15 ,,,,oDlgPecSrv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLboxSrvc:nAt := 1
oLboxSrvc:SetArray(aLibSrvc)
oLboxSrvc:addColumn( TCColumn():New( ""                    	,{ || If( oLboxSrvc:aArray[oLboxSrvc:nAt,02],oOk,oNo) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Marcacao do Item
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_TIPTEM")	,{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,12] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Tipo de Tempo
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_GRUSER")	,{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,03] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Grupo
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_CODSER")	,{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,04] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Codigo
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_DESSER")	,{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,05] } ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) // Descricao
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_TIPSER")	,{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,06] } ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) // Tipo de Servico
oLboxSrvc:addColumn( TCColumn():New( RetTitle("VO4_TEMPAD")	,{ || Transform( oLboxSrvc:aArray[oLboxSrvc:nAt,07],"@R 99:99") } ,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // Tempo Padrao
If lInconveniente
	oLboxSrvc:addColumn( TCColumn():New( RetTitle("VSJ_GRUINC"),{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,08] } ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Cod do Grupo
	oLboxSrvc:addColumn( TCColumn():New( RetTitle("VSJ_CODINC"),{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,09] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Inconvenient
	oLboxSrvc:addColumn( TCColumn():New( RetTitle("VSJ_SEQINC"),{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,10] } ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Seq. Inconveniente - VST
	oLboxSrvc:addColumn( TCColumn():New( RetTitle("VSJ_DESINC"),{ ||  oLboxSrvc:aArray[oLboxSrvc:nAt,11] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) //Descr Inconv
EndIf
oLboxSrvc:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 .and. !Empty(aLibSrvc[1,12]) , ( lMarcar := !aLibSrvc[1,2] , aEval( aLibSrvc , { |x| x[02] := lMarcar } ) , OM140QTDNF("P",aLibPeca,aLibSrvc) ) ,Nil) , oLboxSrvc:Refresh() }
oLboxSrvc:bLDblClick := { || IIf( !Empty(aLibSrvc[oLboxSrvc:nAt,04]) , ( aLibSrvc[oLboxSrvc:nAt,02] := !aLibSrvc[oLboxSrvc:nAt,02] , OM140QTDNF("P",aLibPeca,aLibSrvc) ) , Nil ) }
oLboxSrvc:Refresh()
//

ACTIVATE MSDIALOG oDlgPecSrv CENTER ON INIT (EnchoiceBar(oDlgPecSrv,{ || IIf(OM140QTDNF("P",aLibPeca,aLibSrvc),OM140SELOK(@aSelPeca , @aSelSrvc, @aLibPeca, @aLibSrvc, @lFechaDlg, aAuxTipTem),.t.) } , { || oDlgPecSrv:End() } ))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa   FS_PecHC   Autor     Vinicius Gati บ Data ณ  16/02/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Header Click do getdados de pe็as                          บฑฑ
ฑฑบ            possui alguns controles internos a marcar como verificar   บฑฑ
ฑฑบ            bloqueio de pecas                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PecHC(oObj, nCol)
	Local nIdx := 1

	if nCol == 1 .and. !Empty(oLboxPeca:aArray[1,11]) 
		lMarcar := !oLboxPeca:aArray[1,2]

		for nIdx := 1 to LEN(oLboxPeca:aArray)
			if FS_PodeSelPec(nIdx)
				oLboxPeca:aArray[nIdx, 02] := lMarcar
			end
		next

		OM140QTDNF("P",oLboxPeca:aArray,oLboxSrvc:aArray)
		oLboxPeca:Refresh()
	end
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  FS_PodeSelPec Autor  Vinicius Gati      บ Data ณ  27/11/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pode selecionar mais pe็as para faturar?                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PodeSelPec(nIdx)
	Local nQMaxItNF  := GetNewPar("MV_NUMITEN",9999999) // Numero maximo de Itens por NF
	Local nLoop    := 1
	Local nChecked := 0
	Local lPecaBlq := .F.
	Local lSel
	Local cGrp
	Local cCodIte
	Default nIdx := 0

	for nLoop := 1 to Len(oLboxPeca:aArray)
		lSel := oLboxPeca:aArray[nLoop, 2] // 2 = Selcionada ou nใo .T. ou .F.
		if lSel
			nChecked += 1
		EndIf
		nCons := IIF( nIdx > 0, nIdx, oLboxPeca:nAt)
		if nCons == nLoop
			cGrp     := oLboxPeca:aArray[nLoop, 3]
			cCodIte  := oLboxPeca:aArray[nLoop, 4]
			lPecaBlq := oPecaHlp:Bloqueado(, cCodIte, cGrp)
		end
	next

Return nChecked < nQMaxItNF .AND. ! lPecaBlq // se for menor pode selecionar outro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140QTDNFบAutor  ณ Andre Luis Almeida บ Data ณ  25/02/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao: Qtde maxima de Itens para NF                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140QTDNF(cTp,aPeca,aSrvc)
Local aQtdTTp  := {} // Qtde por Tipo de Tempo
Local nQtdINF  := GetNewPar("MV_NUMITEN",9999999) // Numero maximo de Itens por NF
Local nQtdSel  := 0 // Qtde de Itens selecionados
Local nCont    := 0
Local nPosVet  := 0
Local lRet     := .t.
Local nColTTpP := IIf(cTp=="T",03,11) // Coluna do Tp.Tempo no Vetor de Pecas ( Liberacao T-otal (aSelPeca) / P-arcial (aLibPeca) )
Local nColTTpS := IIf(cTp=="T",04,12) // Coluna do Tp.Tempo no Vetor de Srvcs ( Liberacao T-otal (aSelSrvc) / P-arcial (aLibSrvc) )
Local nColTSrv := IIf(cTp=="T",05,06) // Coluna do Tp.Srvco no Vetor de Srvcs ( Liberacao T-otal (aSelSrvc) / P-arcial (aLibSrvc) )
For nCont := 1 to Len(aPeca)
	If cTp == "T" .or. aPeca[nCont,2]
		nPosVet := aScan(aQtdTTp, { |x| x[1] == aPeca[nCont,nColTTpP] } )
		If nPosVet <= 0 
			aAdd(aQtdTTp,{aPeca[nCont,nColTTpP],0,"/"}) // Qtde por Tipo de Tempo ( Pecas + Servicos )
			nPosVet := len(aQtdTTp)
		EndIf
		aQtdTTp[nPosVet,2]++
	EndIf
Next
For nCont := 1 to Len(aSrvc)
	If cTp == "T" .or. aSrvc[nCont,2]
		nPosVet := aScan(aQtdTTp, { |x| x[1] == aSrvc[nCont,nColTTpS] } )
		If nPosVet <= 0 
			aAdd(aQtdTTp,{aSrvc[nCont,nColTTpS],0,"/"}) // Qtde por Tipo de Tempo ( Pecas + Servicos )
			nPosVet := len(aQtdTTp)
		EndIf
		If !(aSrvc[nCont,nColTSrv] $ aQtdTTp[nPosVet,3]) // Tipo de Servico
			aQtdTTp[nPosVet,2]++
			aQtdTTp[nPosVet,3] += aSrvc[nCont,nColTSrv]+"/"
		EndIf
	EndIf
Next
For nCont := 1 to Len(aQtdTTp)
	If aQtdTTp[nCont,2] > nQtdINF
		nQtdSel := aQtdTTp[nCont,2]
		lRet := .f.
		Exit
	EndIf
Next
dbSelectArea("VO1")
dbSetOrder(1)
If !lRet // Qtde selecionada de Itens eh maior que qtde permitida por NF
	Help(" ",1,"M140MAXNF",,CHR(13)+CHR(10)+STR0098+": "+Alltrim(str(nQtdSel))+" "+STR0094+CHR(13)+CHR(10)+STR0097+" MV_NUMITEN: "+Alltrim(str(nQtdINF))+" "+STR0094,3,0) // Selecionados / itens / Parametro / itens
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM140SELOKบAutor  ณ Rubens Takahashi   บ Data ณ  19/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Botao OK da EnchoiceBar da Dialog de Selecao de Pecas/Srvc บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140SELOK(aSelPeca, aSelSrvc, aLibPeca, aLibSrvc, lFechaDlg, aAuxTipTem)
Local nCont   := 0
Local nCont2  := 0
Local nAuxPos := 0

// Desmarca todos os registros
aEval( aSitOsv  , {|x| x[1] := .f. } )
aEval( aSelPeca , {|x| x[len(x)] := .f. } )
aEval( aSelSrvc , {|x| x[len(x)] := .f. } )
//

// Marca as pecas na matriz auxiliar ...
For nCont := 1 to Len(aLibPeca)
	If aLibPeca[nCont,02]
		nAuxPos := aLibPeca[nCont,01]
		aSelPeca[ nAuxPos , Len(aSelPeca[nAuxPos]) ] := .t.
		aSitOsv[ aScan(aSitOsv, { |x| x[02] == aSelPeca[nAuxPos,03] } ) ,01] := .t.
	EndIf
Next nCont
//

// Marca os servicos na matriz auxiliar ...
For nCont := 1 to Len(aLibSrvc)
	If aLibSrvc[nCont,02]
		nAuxPos := aLibSrvc[nCont,01]
		aSelSrvc[ nAuxPos , Len(aSelSrvc[nAuxPos]) ] := .t.
		aSitOsv[ aScan(aSitOsv, { |x| x[02] == aSelSrvc[nAuxPos,04] } ) ,01] := .t.
	EndIf
Next nCont
//

// Verifica se existe alguma peca com valor zerado, e seleciona automaticamente
For nCont := 1 to Len(aSitOsv)
	If aSitOsv[nCont,01]
		For nCont2 := 1 to Len(aSelPeca)
			If !aSelPeca[nCont2,Len(aSelPeca[nCont2])] .and. aSelPeca[nCont2,03] == aSitOsv[nCont,02] .and. aSelPeca[nCont2,10] == 0
				aSelPeca[nCont2,Len(aSelPeca[nCont2])] := .t.
			EndIf
		Next nCont2
	EndIf
Next nCont
//

// Libera os registros selecionados...
If FS_LIBOSV( aSelPeca , aSelSrvc )

	// Tenta atualizar a listbox de Tipo de Tempo da OS
	// Se nao conseguir, fecha a DIALOG principal ...
	If !OM140LVOS( @aSelPeca , @aSelSrvc , .f. , aAuxTipTem )
		lFechaDlg := .t.
	EndIf

	// Atualiza Listbox de Pecas e Servicos do Tipo de Tempo Selecionado...
	If OM140CRMAT(aAuxTipTem, aSelPeca, aSelSrvc, @aLibPeca, @aLibSrvc)

		oLboxPeca:SetArray(aLibPeca)
		oLboxPeca:nAt := 1
		oLboxPeca:DrawSelect()
		oLboxPeca:Refresh()

		oLboxSrvc:SetArray(aLibSrvc)
		oLboxSrvc:nAt := 1
		oLboxSrvc:DrawSelect()
		oLboxSrvc:Refresh()

		// Todas as pecas/servicos do tipo de tempo selecionado ja foram liberados ...
	Else
		If !lFechaDlg
			oSitOsv:nAt := 1
			oSitOsv:SetArray(aSitOsv)
			oSitOsv:DrawSelect()
			oSitOsv:Refresh()
		EndIf
		oDlgPecSrv:End()
	EndIf
Else
	// Desmarca as pecas que foram selecionadas automaticamente
	aEval( aSelPeca , { |x| IIf( x[Len(x)] .and. x[10] == 0 , x[Len(x)] := .f. , ) } )
EndIf
//

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALOSV บAutor  ณFabio / Emilton     บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALOSV(nNroLin,lMostraTela,aSelPeca, aSelSrvc)

Local nCont, nContDet
Local nA := 0

Local lAliasVMB := AliasInDic("VMB")

Local lTemPecSrv := .f.

Default lMostraTela := .f.

VOI->(dbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + aSitOsv[nNroLin,2] ))

// Verifica se foi selecionado peca/servico para liberacao ...
If aScan( aSelPeca , { |x| x[Len(x)] } ) == 0 .and. aScan( aSelSrvc , { |x| x[Len(x)] } ) == 0
	Help("  ",1,"M140NAOSEL")
	Return( .f. )
EndIf

// Verifica se o cliente esta bloqueado
SA1->(DbSetOrder(1))
SA1->(DbSeek( xFilial("SA1") + aSitOsv[nNroLin,3] + aSitOsv[nNroLin,4] ))
If SA1->A1_MSBLQL == "1"
	Help("",1,"REGBLOQ",,"SA1" + chr(13) + chr(10) + AllTrim(RetTitle("A1_COD")) + ": " + SA1->A1_COD + "-" + SA1->A1_LOJA + " - " + SA1->A1_NOME,3,0)
	Return(.f.)
EndIf

// Verifica se o cliente possui limite de credito
If "L" $ GetMv("MV_CHKCRE") .And. !(VOI->VOI_SITTPO $ "2/3/4")
	If !FGX_AVALCRED(aSitOsv[nNroLin,3],aSitOsv[nNroLin,4],0,.t.)
		Help("  ",1,"LIMITECRED")
		Return( .f. )
	EndIf
EndIf

// Validacao de pecas ...
For nCont := 1 to Len(aSelPeca)

	If !aSelPeca[nCont, Len(aSelPeca[nCont])]
		Loop
	EndIf

	// Tipo de Tempo diferente
	If aSelPeca[nCont,03] <> aSitOsv[nNroLin,2]
		Loop
	EndIf

	If aSelPeca[nCont,09] == 0
		Help("  ",1,"M140PREPEC")
		Return .f.
	EndIf
	
	If aSelPeca[nCont,PECA_QTDREM] <> 0
		Help("  ",1,"M140REMES")
		Return .f.
	EndIf

	If aSelPeca	[nCont,PECA_QTDREQ] <> 0
		lTemPecSrv := .t.
	Endif

Next nCont
//

// Validacao de Servicos ...
For nCont := 1 to Len(aSelSrvc)

	If !aSelSrvc[nCont, Len(aSelSrvc[nCont])]
		Loop
	EndIf

	// Tipo de Tempo diferente
	If aSelSrvc[nCont,04] <> aSitOsv[nNroLin,2]
		Loop
	EndIf

	lTemPecSrv := .t.

	if GetNewPar("MV_MIL0103","S")=="S"
		aVetRat100 := {}
		aVetProd := {}
		For nContDet := 1 to Len(aSelSrvc[nCont,SRVC_APONT])
			cProd := aSelSrvc[nCont,SRVC_APONT,nContDet,SRVC_APONT_CODIGO]
			cGruSer := aSelSrvc[nCont,SRVC_GRUSER]
			cCodSer := aSelSrvc[nCont,SRVC_CODSER]
			nPerRat := aSelSrvc[nCont,SRVC_APONT,nContDet,SRVC_APONT_PERRAT]
			nPos := aScan( aVetRat100 , { |x| x[1] + x[2] == cGruSer + cCodSer } )
			nPos2 := aScan( aVetProd , { |x| x[1] + x[2] + x[3] == cGruSer + cCodSer + cProd } )
			if nPos == 0 
				aAdd(aVetRat100, {cGruSer , cCodSer, 0} )
				nPos := Len(aVetRat100)
			endif
			if nPos2 == 0
				aVetRat100[nPos,3]+=nPerRat
				aAdd(aVetProd, {cGruSer , cCodSer, cProd, nPerRat} )
			endif
			if nPos2 != 0
				if nPerRat != aVetProd[nPos2,4]
					MsgStop(STR0088+cProd +" ("+cGruSer+"/"+ cCodSer + ") ")
					return .f.
				endif
			endif
		Next
		For nContDet := 1 to Len(aVetRat100) 
			if  aVetRat100[nContDet, 3] != 100 .and.  aVetRat100[nContDet, 3] != 0
				MsgStop(STR0089+aVetRat100[nContDet, 1]+"/"+ aVetRat100[nContDet, 2])
				return .f.
			endif
		next
	Endif	
	// Tipo de Cobranca (VOK_INCMOB)
	// Mao de Obra, Mao de Obra Gratuita , Vlr Livre com base na tabela, Retorno de Srv
	Do Case
	Case aSelSrvc[nCont,06] $ "0/1/3/4"

		// Verifica todos os apontamentos de servicos para verificar
		// se existe algum apontamento aberto ...
		If VOI->VOI_CTRAPO <> "0"   

			aSort(aSelSrvc[nCont,14],,,{|x,y| dtos(x[2])+Alltrim(strzero(x[3],4)) < dtos(y[2])+Alltrim(strzero(y[3],4)) })
			For nContDet := 1 to Len(aSelSrvc[nCont,14])
			
				// Sem apontamento inicial ou final 
				If Empty(aSelSrvc[nCont,14,nContDet,02]) .or. Empty(aSelSrvc[nCont,14,nContDet,04])
				
					VV1->(dbSetOrder(1))
					VV1->(MsSeek( xFilial("VV1") + VO1->VO1_CHAINT ))
					
					// Se nใo for TT de garantia, so permite a libera็ใo de ser for um Chassi da John Deere e
					// possuir um registro de garantia autorizada
					If VOI->VOI_SITTPO <> "2" .and. lAliasVMB .and. ( VV1->VV1_CODMAR == FMX_RETMAR("JD ") .or. VV1->VV1_CODMAR == FMX_RETMAR("GRS") .or. VV1->VV1_CODMAR == FMX_RETMAR("PLA") .or. VV1->VV1_CODMAR == FMX_RETMAR("JDC") .or. VV1->VV1_CODMAR == FMX_RETMAR("HCM") )
						cQuery := "SELECT COUNT(*) FROM "+RetSqlName("VMB")+" VMB JOIN "+RetSqlName("VMC")+" VMC ON VMC.VMC_FILIAL = VMB.VMB_FILIAL AND VMB.VMB_CODGAR = VMC.VMC_CODGAR AND VMC.D_E_L_E_T_ = ' ' "
						cQuery += "WHERE VMB.VMB_FILIAL = '"+xFilial("VMB")+"' AND VMB.VMB_NUMOSV = '"+aSelSrvc[nCont,03]+"' AND VMB.VMB_STATUS NOT IN ('  ','04','05','15') AND ( VMC.VMC_TIPOPS = 'S' OR ( VMC.VMC_TIPOPS = 'O' AND VMC.VMC_CODITE = '  ')) AND "
						cQuery += " VMC.VMC_TIPTEM = '"+VOI->VOI_TIPTEM+"' AND "
						cQuery += " VMC.VMC_GRUSER = '"+aSelSrvc[nCont,01]+"' AND "
						cQuery += " VMC.VMC_CODSER = '"+aSelSrvc[nCont,02]+"' AND "
						cQuery += " VMB.D_E_L_E_T_ = ' '"
					
						If FM_SQL(cQuery) == 0
							Help(" ",1,"M140FIMSRV")
							Return(.f.)
						EndIf
					Else
						// Permite que o cliente possa fazer um controle das OS sem apontamento que podem ser fechadas
						If ExistBlock("OM140FSR")
							If !ExecBlock("OM140FSR",.F.,.F.,{VO1->VO1_NUMOSV,aSelSrvc[nCont,SRVC_TIPSER],aSelSrvc[nCont,SRVC_GRUSER],aSelSrvc[nCont,SRVC_CODSER]})
								Help(" ",1,"M140FIMSRV")
								Return(.f.)
							Endif
						Else
							Help(" ",1,"M140FIMSRV")
							Return(.f.)
						EndIf
						//
					EndIf
					
				Else
					
					if !Empty(aSelSrvc[nCont,14,nContDet,15])
						lPausa := .t.
						For nA := nContDet+1 to Len(aSelSrvc[nCont,14])

							if Empty(aSelSrvc[nCont,14,nA,15])
								If !Empty(aSelSrvc[nCont,14,nContDet,02]) .or. !Empty(aSelSrvc[nCont,14,nContDet,04])
									lPausa := .f.
									Exit	
								Endif
							Endif

						Next
						if lPausa
							Help(" ",1,"M140PAUSA")
							Return(.f.)
						Endif

					Endif 	
				EndIf
				
			Next nContDet
			
		EndIf
		//

		// Verifica se o percentual ja trabalhado ้ maior do que o mํnimo necessario para libera o TT
		If !Empty(VOI->VOI_PMINEX)
			If (aSelSrvc[nCont,11] / aSelSrvc[nCont,10] * 100 ) < VOI->VOI_PMINEX
				Help(" ",1,"M140PMINEX")
				Return .f.
			EndIf
		EndIf
		//

	// Tipo de Cobranca (VOK_INCMOB)
	// Km Socorro
	Case aSelSrvc[nCont,06] == "5"
		If aSelSrvc[nCont,19] == 0
			Help(" ",1,"M140KILROD")
			Return .f.
		EndIf

	// Tipo de Cobranca (VOK_INCMOB)
	// Srv de Terceiros
	Case aSelSrvc[nCont,06] == "2"
		// Se tiver sido informado o numero do titulo, verifica se todos os outros campos de
		// servico de terceiros foram informados ...
		If aSelSrvc[ nCont, 07 ] == 0 .or. ; 	// 07 - Valor do Servico (Valor Bruto)
			(GetNewPar("MV_SRV3PD","N") $ "P.T" .and. ;
			!Empty(aSelSrvc[nCont,27]) .and. ;	// 27 - (Srvc. Terceiros) - Numero do Titulo (Financeiro)
			(Empty(aSelSrvc[ nCont, 25 ]) .or. ;	// 25 - (Srvc. Terceiros) - Fornecedor
			Empty(aSelSrvc[ nCont, 26 ]) .or. ;	// 26 - (Srvc. Terceiros) - Loja
			Empty(aSelSrvc[ nCont, 28 ]) .or. ;	// 28 - (Srvc. Terceiros) - Tipo do Titulo (Financeiro)
			Empty(aSelSrvc[ nCont, 29 ]) .or. ;	// 29 - (Srvc. Terceiros) - Data do Pagamento
			aSelSrvc[ nCont, 32 ] == 0))			// 32 - (Srvc. Terceiros) - Valor do Custo

			Help(" ",1,"M140SRVTER")
			Return .f.
		EndIf

	EndCase
	//

Next nCont

// Verifica se existe VSJ pendente e pergunta se o usuario deseja continuar
If !lOM140Auto
	IF lMostraTela .and. FS_CONSVSJ(VO1->VO1_NUMOSV,aSitOsv[nNroLin,02])
		Help(" ",1,"M140PECOSV")
		// Exibe os itens pendentes e verifica se o usuario quer continuar ...
		If !FS_VERVSJ(VO1->VO1_NUMOSV)
			Return .f.
		EndIf
	EndIf
EndIf
//
//Verifica se ้ possivel a Sele็ใo do Tipo de Tempo
If !lTemPecSrv // -> .F. ้ quando nใo tem pe็as nem servi็os requisitados
	FMX_HELP( "NOPECSRV", STR0103 )
	Return .f.
Endif

//If ! OM1400013_PecasUmaLinhaReq(VO1->VO1_NUMOSV, aSitOsv[nNroLin,2])
//	Return .f.
//EndIf

If ! FS_IMPGAR(aSitOsv[nNroLin,2], ,"VD" )
	Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DISOSV บAutor  ณFabio / Emilton     บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se ja foi disponibilizado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DISOSV()

Local cQuery
Local nAuxCont

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe requisicoes nao disponibilizadas/fechadas/canceladasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT COUNT(*)"
cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = VO2.VO2_FILIAL "
cQuery +=         " AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM "
cQuery +=         " AND VO3.VO3_DATFEC = ' '"
cQuery +=         " AND VO3.VO3_DATDIS = ' '"
cQuery +=         " AND VO3.VO3_DATCAN = ' '"
cQuery +=         " AND VO3.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VO2_FILIAL = '" + xFilial("VO2") + "'"
cQuery +=   " AND VO2.VO2_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
nAuxCont := FM_SQL(cQuery)
if nAuxCont > 0
	Return .f.
endif

cQuery := "SELECT COUNT(*)"
cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL "
cQuery +=         " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM "
cQuery +=         " AND VO4.VO4_DATFEC = ' '"
cQuery +=         " AND VO4.VO4_DATDIS = ' '"
cQuery +=         " AND VO4.VO4_DATCAN = ' '"
cQuery +=         " AND VO4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VO2_FILIAL = '" + xFilial("VO2") + "'"
cQuery +=   " AND VO2.VO2_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
nAuxCont := FM_SQL(cQuery)
if nAuxCont > 0
	Return .f.
endif

cQuery := "SELECT COUNT(*)"
cQuery +=  " FROM " + RetSQLName("VSJ") + " VSJ "
cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "'"
cQuery +=   " AND VSJ.VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cQuery +=   " AND VSJ.VSJ_QTDITE > 0"
cQuery +=   " AND VSJ.D_E_L_E_T_ = ' '"
nAuxCont := FM_SQL(cQuery)
if nAuxCont > 0
	Return .f.
endif

return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERVSJ บAutor  ณEmilton             บ Data ณ  09/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra pecas que estiverem no VSJ                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VERVSJ(cAuxOS)

Local aPecaVSJ:= {}
Local oLbPecaVSJ
Local oDlgOrc
Local lVaiDeletar := .f.
Local cQuery := ""
Local cAliasVVD := GetNextAlias()
Local aInconv
Local aSizeAut := MsAdvSize(.t.)
Local lFieldSEQ := (VSJ->(FieldPos("VSJ_SEQINC")) <> 0)

cQuery := "SELECT VS1_TIPTEM, VSJ_GRUITE, VSJ_CODITE, B1_DESC, VSJ_QTDITE " + IIF( lFieldSEQ , " , VSJ_SEQINC" , "" ) + ", VSJ_LOTECT, VSJ_NUMLOT "
cQuery +=  ", " + IIF( VSJ->(FieldPos("VSJ_TIPTEM")) <> 0 , " VSJ.VSJ_TIPTEM " , " '        ' " ) + " AS VSJ_TIPTEM "
cQuery +=  " FROM " + RetSQLName("VSJ") + " VSJ JOIN " + RetSQLName("SB1") + " B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "'AND B1.B1_GRUPO = VSJ.VSJ_GRUITE AND B1.B1_CODITE = VSJ.VSJ_CODITE AND B1.D_E_L_E_T_ = ' '"
cQuery +=                                " LEFT JOIN " + RetSQLName("VS1") + " VS1 ON VS1.VS1_FILIAL = '"  + xFilial("VS1") + "' AND VS1.VS1_NUMORC = VSJ.VSJ_NUMORC AND VS1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "'"
cQuery +=   " AND VSJ.VSJ_NUMOSV = '" + cAuxOS + "'"
cQuery +=   " AND VSJ.VSJ_QTDITE > 0 "
cQuery +=   " AND VSJ.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD , .F., .T. )
(cAliasVVD)->(dbGoTop())
While !(cAliasVVD)->(Eof())
	aAdd( aPecaVSJ , { (cAliasVVD)->VSJ_GRUITE,;
		(cAliasVVD)->VSJ_CODITE,;
		(cAliasVVD)->B1_DESC,;
		(cAliasVVD)->VSJ_QTDITE,;
		Space(3),;
		Space(30),;
		" ",;
		" ",;
		IIf( !Empty((cAliasVVD)->VSJ_TIPTEM) , (cAliasVVD)->VSJ_TIPTEM , (cAliasVVD)->VS1_TIPTEM ) ,;
		(cAliasVVD)->VSJ_LOTECT,;
		(cAliasVVD)->VSJ_NUMLOT} )

	if lInconveniente .and. (lFieldSEQ .and. !Empty((cAliasVVD)->VSJ_SEQINC))
		aInconv := OM420CONSINC( "2" , cAuxOS , (cAliasVVD)->VSJ_SEQINC )

		aPecaVSJ[Len(aPecaVSJ),5] := aInconv[1] 			// Grupo
		aPecaVSJ[Len(aPecaVSJ),6] := aInconv[2] 			// Codigo
		aPecaVSJ[Len(aPecaVSJ),7] := aInconv[4] 			// Sequencia
		aPecaVSJ[Len(aPecaVSJ),8] := AllTrim(aInconv[3])	// Descricao
	endif

	(cAliasVVD)->(dbSkip())
End
(cAliasVVD)->(dbCloseArea())
dbSelectArea("VO1")

If Len(aPecaVSJ) > 0

	DEFINE MSDIALOG oDlgOrc TITLE STR0032 From aSizeAut[7],00 to Round(aSizeAut[6]*0.6,0),Round(aSizeAut[5]*0.9,0) of oMainWnd PIXEL //Pecas para a Ordem de Servico

	oTPanelTOP := TPanel():New(0,0,"",oDlgOrc,NIL,.T.,.F.,NIL,NIL,0,08,.T.,.F.)
	oTPanelTOP:Align := CONTROL_ALIGN_TOP

	oTPanelBOTTOM := TPanel():New(0,0,"",oDlgOrc,NIL,.T.,.F.,NIL,NIL,0,08,.T.,.F.)
	oTPanelBOTTOM:Align := CONTROL_ALIGN_BOTTOM

	oLbPecaVSJ := TWBrowse():New( 12,01,20,20,,,,oDlgOrc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbPecaVSJ:Align := CONTROL_ALIGN_ALLCLIENT
	oLbPecaVSJ:nAt := 1
	oLbPecaVSJ:SetArray(aPecaVSJ)
	oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VS1_TIPTEM"),{ || aPecaVSJ[oLbPecaVSJ:nAt,09] } ,,,,"LEFT" ,12,.F.,.F.,,,,.F.,) ) //Tp
	oLbPecaVSJ:addColumn( TCColumn():New( STR0033				,{ || aPecaVSJ[oLbPecaVSJ:nAt,01] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Grupo
	oLbPecaVSJ:addColumn( TCColumn():New( STR0034				,{ || aPecaVSJ[oLbPecaVSJ:nAt,02] } ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Codigo
	oLbPecaVSJ:addColumn( TCColumn():New( STR0035				,{ || aPecaVSJ[oLbPecaVSJ:nAt,03] } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) //Descricao
	If lCtrlLote
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_LOTECT") ,{ || aPecaVSJ[oLbPecaVSJ:nAt,10] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Lote
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_NUMLOT") ,{ || aPecaVSJ[oLbPecaVSJ:nAt,11] } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) //Sub-Lote
	EndIf
	oLbPecaVSJ:addColumn( TCColumn():New( STR0036				,{ || Transform(aPecaVSJ[oLbPecaVSJ:nAt,04],PesqPict("VSJ","VSJ_QTDITE") ) } ,,,,"RIGHT",35,.F.,.F.,,,,.F.,) ) //Quantidade
	If lInconveniente
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_GRUINC"),{ || aPecaVSJ[oLbPecaVSJ:nAt,05] } ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Cod do Grupo
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_CODINC"),{ || aPecaVSJ[oLbPecaVSJ:nAt,06] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Inconvenient
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_SEQINC"),{ || aPecaVSJ[oLbPecaVSJ:nAt,07] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) //Seq. Inconveniente - VST
		oLbPecaVSJ:addColumn( TCColumn():New( RetTitle("VSJ_DESINC"),{ || aPecaVSJ[oLbPecaVSJ:nAt,08] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) //Descr Inconv
	EndIf
	oLbPecaVSJ:Refresh()

	oDlgOrc:lEscClose := .F.
	ACTIVATE MSDIALOG oDlgOrc CENTER ON INIT EnchoiceBar(oDlgOrc, { || lVaiDeletar := .t.,oDlgOrc:End() } , { || oDlgOrc:End() } )

EndIf

Return lVaiDeletar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSVSJ บAutor  ณ Rubens Takahashi  บ Data ณ  19/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se ainda existem pecas a serem requisitadas       บฑฑ
ฑฑบ          ณ pelo Tipo de Tempo                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSVSJ(cAuxOS,cAuxTipTem)

Local lRet := .f.
Local cAuxTT := cAuxTipTem + ","
Local cAliasVOI := "ALIASQLVO2"
Local oArea := GetArea()

If VOI->(FieldPos("VOI_TTRELA")) <> 0
	cQuery := "SELECT VOI_TIPTEM, VOI_TTRELA "
	cQuery += " FROM " + RetSQLName("VOI")
	cQuery += " WHERE VOI_FILIAL = '" + xFilial("VOI") + "' "
	cQuery +=   " AND ( VOI_TIPTEM = '" + cAuxTipTem + "' OR VOI_TTRELA = '" + cAuxTipTem + "' )"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVOI , .F., .T. )
	While !(cAliasVOI)->(Eof())
		If !Empty((cAliasVOI)->VOI_TIPTEM) .and. AT((cAliasVOI)->VOI_TIPTEM+",", cAuxTT) == 0
			cAuxTT += (cAliasVOI)->VOI_TIPTEM + ","
		EndIf
		If !Empty((cAliasVOI)->VOI_TTRELA) .and. AT((cAliasVOI)->VOI_TTRELA+",", cAuxTT) == 0
			cAuxTT += (cAliasVOI)->VOI_TTRELA + ","
		EndIf

		(cAliasVOI)->(dbSkip())
	End
	(cAliasVOI)->(dbCloseArea())
EndIf

cAuxTT := Left(cAuxTT,Len(cAuxTT) - 1)

cQuery := "SELECT COUNT(*) "
cQuery +=  " FROM " + RetSQLName("VSJ") + " VSJ "
cQuery +=         " LEFT JOIN " + RetSQLName("VS1") + " VS1 ON VS1.VS1_FILIAL = '"  + xFilial("VS1") + "'"
cQuery +=                                                " AND VS1.VS1_NUMORC = VSJ.VSJ_NUMORC "
cQuery +=                                                " AND VS1.VS1_TIPTEM IN " + FormatIN(cAuxTT,",")
cQuery +=                                                " AND VS1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "'"
cQuery +=   " AND VSJ.VSJ_NUMOSV = '" + cAuxOS + "'"
cQuery +=   " AND VSJ.VSJ_QTDITE > 0 "
cQuery +=   " AND VSJ.D_E_L_E_T_ = ' '"

nContReq := FM_SQL(cQuery)

lRet := (nContReq > 0)

RestArea( oArea )

Return lRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOM140LEG   ณ Autor ณ Fabio                ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณofiom140                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM140LEG()

Local aLegenda  := {{ 'BR_VERDE'    , STR0042} ,;  	// Aberta
					{ 'BR_AZUL'    , STR0043} ,;  	// Liberada
					{ 'BR_VERMELHO', STR0044} ,;  	// Fechado
					{ 'BR_PRETO'   , STR0045} }    // Cancelado

BrwLegenda(cCadastro,STR0046 ,aLegenda)   			//legenda

Return .T.

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณMenuDef    ณ Autor ณ Fabio                ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Menu de Rotina                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}
if funname() <> "OFIOM140"
	aRotina := {{STR0001,"AxPesqui",0,1},; 		//Pesquisar
	{STR0002,"OFIOM140I",0,2},; 	//Liberar OS
	{STR0046,"OM140LEG",0,2,0,.f.}}	//Legenda
Else
	aRotina := {{STR0001,"AxPesqui",0,1},; 		//Pesquisar
	{STR0002,"OFIOM140I",0,2},; 	//Liberar OS
	{STR0046,"OM140LEG",0,2,0,.f.},;//legenda
	{STR0051,"OM140V",0,1}}  		//Pesq.Avancada
Endif
Return aRotina

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM140V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM140V()
nOpc := 1
OFIOC450()
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM140DIAG บAutor  ณManoel            บ Data ณ  06/08/12    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se ha Apontamentos de Servi็os de Diagn๓stico. Se บฑฑ
ฑฑบ          ณ houver, impede a LIbera็ใo caso MV_LIBDIAG igual a N(Nใo)  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140DIAG(cTpTem)
Local cQuery

cQuery := "SELECT VO4.R_E_C_N_O_ VO4RECNO"
cQuery += " FROM "+RetSQLName("VO4")+" VO4 JOIN "+RetSQLName("VO6")+" VO6 ON VO6.VO6_FILIAL = '"+xFilial("VO6")+"'"
cQuery += " AND VO6.VO6_CODSER = VO4.VO4_CODSER AND VO6.VO6_DIAGNO = '1'" // Servi็o de Diagn๓stico
cQuery += " AND VO6.D_E_L_E_T_ = ' '"
cQuery += " WHERE VO4.VO4_FILIAL = '"+xFilial("VO4")+"'"
cQuery += " AND VO4.VO4_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VO4.VO4_TIPTEM = '"+cTpTem+"' "
cQuery += " AND VO4_DATDIS = '        '" // Desconsidera registros Liberados
cQuery += " AND VO4_DATCAN = '        '" // Desconsidera registros Cancelados
cQuery += " AND VO4_DATFEC = '        '" // Desconsidera registros Fechados
cQuery += " AND VO4.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM140RECAL บ Autor ณ Rubens Takahashi บ Data ณ  01/09/13    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recalcula valores totais de uma liberacao                  บฑฑ
ฑฑบ          ณ Utilizado para alterar req. de garantia John Deere         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM140RECAL( cAuxOS, cAuxTipTem, cAuxLibVOO )

Local aCalPec
Local aCalSer

Local nTotPeca := 0
Local nTotSrvc := 0
Local nTotHorP := 0
Local nTotHorT := 0

Local nCont

Local aArea := GetArea()

Default cAuxLibVOO := ""

aCalPec := FMX_CALPEC( cAuxOS , cAuxTipTem /* cTipTem */ , /* cGruIte */ , /* cCodIte */ , .f. /* lMov */ , .f. /* lNegoc */ , .f. /* lReqZerada */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan */ , cAuxLibVOO /* cLibVOO */ )
For nCont := 1 to Len(aCalPec)
	If !Empty(aCalPec[nCont,PECA_DATFEC])
		Help("  ",1,"M140RECAL")
		RestArea( aArea )
		Return .f.
	EndIf
	nTotPeca += aCalPec[nCont,PECA_VALBRU] - aCalPec[nCont,PECA_VALDES]
Next nCont

aCalSer := FMX_CALSER( cAuxOS , cAuxTipTem /* cTipTem */ ,  /* cGruSer */ ,  /* cCodSer */ , .f.  /* lApont */ , .f. /* lNegoc */ , .t. /* lRetAbe */ , .t. /* lRetLib */ , .f. /* lRetFec */ , .f. /* lRetCan*/ , cAuxLibVOO /* cLibVOO */ )
For nCont := 1 to Len(aCalSer)

	If aCalSer[nCont,SRVC_DATFEC]
		Help("  ",1,"M140RECAL")
		RestArea( aArea )
		Return .f.
	EndIf
	
	nTotSrvc += aCalSer[nCont,SRVC_VALLIQ]
	nTotHorP += aCalSer[nCont,SRVC_TEMPAD]
	nTotHorT += aCalSer[nCont,SRVC_TEMTRA]
Next nCont

VOO->(dbSetOrder(1))
If !VOO->(dbSeek(xFilial("VOO") + cAuxOS + cAuxTipTem + cAuxLibVOO))
	HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VOO_TIPTEM")) + ": " + cAuxTipTem,4,1)	
	Return .f.
EndIf

// Grava totais no VOO
dbSelectArea("VOO")
RecLock("VOO",.f.)
VOO->VOO_TOTPEC := nTotPeca
VOO->VOO_HRSPAD := nTotHorP
VOO->VOO_HRSAPL := nTotHorT
VOO->VOO_TOTSRV := nTotSrvc
MsUnLock()
//
	
RestArea( aArea )

Return .t.

/*----------------------------------------------------
 Suavizar a nova verifica็ใo de integra็ใo com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return


/*/{Protheus.doc} OM1400013_PecaUmaLinha
Retorna se o tipo de tempo passado por parametro possui pecas requisitadas que geram mais de um linha de retorno na FMX_CALPEC
@author rubens.takahashi
@since 19/08/2020
@version 1.0
@param cNumOsv, characters, description
@param cTipTem, characters, description
@type function
/*/
Function OM1400013_PecaUmaLinha(cNumOsv, cTipTem)

	Local aVldPeca
	Local nCont
	Local nPosIni

	Local cGruIte, cCodIte
	
	aVldPeca := FMX_CALPEC( ;
		cNumOsv ,;
		cTipTem ,;
		/* cGruIte */ ,;
		/* cCodIte */ ,;
		.f. /* lMov */ ,;
		.f. /* lNegoc */ ,;
		.f. /* lReqZerada */ ,;
		.t. /* lRetAbe */ ,;
		.f. /* lRetLib */ ,;
		.f. /* lRetFec */ ,;
		.f. /* lRetCan */ )
	
	For nCont := 1 to Len(aVldPeca)
		cGruIte := aVldPeca[ nCont , PECA_GRUITE]
		cCodIte := aVldPeca[ nCont , PECA_CODITE]
		
		nPosIni := nCont + 1

		If (nPosIni := aScan(aVldPeca, { |x| x[PECA_GRUITE] == cGruIte .and. x[PECA_CODITE] == cCodIte }, nPosIni )) <> 0
			FMX_HELP("M140REQPECLINHA",STR0106 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + aVldPeca[nPosIni,PECA_GRUITE] + " - " + aVldPeca[nPosIni,PECA_CODITE],STR0107) // "Pe็a com mais de uma linha de requisi็ใo." / "Verifique se foram utilizados o mesmo c๓digo de TES e inconveniente em todas as requisi็๕es da pe็a."
			Return .f.
		EndIf
	Next nCont

Return .t.