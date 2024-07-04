#include "Ofiom150.ch"
#include "Protheus.ch"

STATIC lOM350STATUS := FindFunction("OM350STATUS")
Static cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006",""))

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007676_2"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM150  บAutor  ณFabio               บ Data ณ  07/14/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancelamento da OS                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM150(lNoMBrowse,xAutoCab,nOpcAuto)

Local aCores := {;
	{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE'    } ,;   	// Aberta
	{ 'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,;  	// Liberada
	{ 'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,;  	// Fechado
	{ 'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }    	// Cancelado
//
Private aAutoCab   := {}
Private lOM150Auto := ( xAutoCab <> NIL )
//
Default lNoMBrowse := .f.

Private aRotina    := MenuDef()
Private cCadastro  := STR0003 //Dados do Veiculo para oficina //Cancelamento da Ordem de Servico
Private cParam01   := ""

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(14)
	Return
EndIf

AjustaHelp()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("VO1")
dbSetOrder(1)
If !lOM150Auto
	If lNoMBrowse
		dbSelectArea("VO1")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else
		mBrowse( 6, 1,22,75,"VO1",,,,,,aCores)
	EndIf
Else
	aAutoCab := xAutoCab
	nPos := aScan( aAutoCab , { |x| x[1] == "VO1_NUMOSV" } )
	VO1->(dbSetOrder(1))
	VO1->(dbSeek( xFilial("VO1") + aAutoCab[nPos,2] ))
	MBrowseAuto( nOpcAuto , , "VO1" , .f. )
EndIf

dbSelectArea("VO1")
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM150     บAutor  ณFabio               บ Data ณ  07/14/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela gravacao                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM150(cAlias,nReg,nOpc)

Local nPosVO1		:= VO1->( Recno() )

// Variaveis para posicionamento de Tela
Local aObjects 	:= {}
Local aPosObj 	:= {}
Local aInfo 	:= {}
Local aSizeAut 	:= MsAdvSize()
//

// Variaveis da Enchoice
Local nModelo   := 3
Local cTudoOk   := ".t."
Local lF3       := .f.
Local lMemoria  := .t.
Local lColumn   := .f.
Local cATela    := ""
Local lProperty := .f.
//

Local aPeca 		:= {}
Local aSrv			:= {}
Local aCpoEnchoice	:= {}

Local nPos
Local cTipTem
Local cLibVOO

Private aTempos  := {}
Private lEndOk   := .f.
Private n        := 1
Private nOpca    := 0
Private oOk      := LoadBitmap( GetResources(), "LBTIK" )
Private oCancel  := LoadBitmap( GetResources(), "LBNO" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL"  )
Private oBranco  := LoadBitmap( GetResources(), "FOLDER9" )
Private cObserv  := STR0033 // "Devolver as pe็as ao armaz้m do tipo de tempo, nใo as subtrai  เ conta corrente do produtivo , apague os campos do fecho."
Private aMotCancel := {}
Private cMotivoEsc := ""
Private cParam01   := ""

Private lVO3_FUNDIS := ( VO3->(FieldPos("VO3_FUNDIS")) <> 0 )
Private lVO4_FUNDIS := ( VO4->(FieldPos("VO4_FUNDIS")) <> 0 )

nOpcE := 2
nOpc  := 2

If VO1->VO1_STATUS =="C"
	Help(" ",1,"DOCINVALID")
	Return .F.
Endif

// Posiciona no Arquivo de Veiculos
VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1")+VO1->VO1_CHAINT))

// Levanta os Tipos de Tempos da OS ...
OM150LVOS( @aPeca, @aSrv , .f. )
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO1", .f. )

aCpoEnchoice  :={}

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO1")
While !Eof().and.(x3_arquivo=="VO1")
	If X3USO(x3_usado) .and. cNivel >= x3_nivel .and. !(Alltrim(X3_CAMPO) $ "VO1_MOTIVO/VO1_DESMOT/VO1_GETKEY/VO1_CODMOT/VO1_NOMMOT/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VOI_TEMLIB/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR/VO1_TEMLIB/VO1_TEMFEC/VO1_TEMCAN")
		aAdd(aCpoEnchoice,x3_campo)
	Endif
	dbSkip()
EndDo
dbSelectArea("VO1")

If !lOM150Auto

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 00, 050, .T., .T. } ) // Folder
	AAdd( aObjects, { 00, 013, .T., .F. } ) // Legenda ...
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)
	//

	DEFINE MSDIALOG oDlg150 FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE STR0003 OF oMainWnd PIXEL // Cancelamento da Ordem de Servico

	oFolder150 := TFolder():New(aPosObj[1,1],aPosObj[1,2],{ STR0004,STR0005,STR0006 },, oDlg150, , , , .t. , , aPosObj[1,4] - aPosObj[1,2], aPosObj[1,3] - aPosObj[1,1] ) // "Dados da OS" "Servicos" "Pecas"

	// Folder - "Dados da OS"
	oPanFolTOP := TPanel():New(0,0,"",oFolder150:aDialogs[1],NIL,.T.,.F.,NIL,NIL,0,50,.T.,.F.)
	oPanFolTOP:Align :=  CONTROL_ALIGN_ALLCLIENT

	oEnchVO1 := MSMGet():New("VO1",nReg, 2 /* Visualizar */ ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, {00,00,00,00} , aCpoEnchoice, nModelo,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oPanFolTOP , lF3, lMemoria, .F. /* lColumn */ ,;
	caTela, .t. /* lNoFolder */, lProperty)
	oEnchVO1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oPanFolBOT := TPanel():New(0,0,"",oFolder150:aDialogs[1],NIL,.T.,.F.,NIL,NIL,0,100,.T.,.F.)
	oPanFolBOT:Align := CONTROL_ALIGN_BOTTOM

	// Listbox de Tipo de Tempo
	oLbTempos := TWBrowse():New(00,00,00,00,,,,oPanFolBOT,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbTempos:nAT := 1
	oLbTempos:SetArray(aTempos)
	oLbTempos:Align := CONTROL_ALIGN_ALLCLIENT
	oLbTempos:AddColumn( TCColumn():New( ""		 , { || Iif( aTempos[oLbTempos:nAt,13] == "D" , oAzul , Iif(aTempos[oLbTempos:nAt,13] == "F" , oVermelho , Iif( aTempos[oLbTempos:nAt,13] == "C" , oPreto , oVerde ) ) ) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	oLbTempos:AddColumn( TCColumn():New( ""		 , { || Iif( aTempos[oLbTempos:nAt,01] , oOk , oCancel ) }																,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	oLbTempos:AddColumn( TCColumn():New( STR0007 , { || aTempos[oLbTempos:nAt,02] }																						,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // "TT"
	oLbTempos:AddColumn( TCColumn():New( STR0069 , { || aTempos[oLbTempos:nAt,15] }																						,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Num. Lib. TT"
	oLbTempos:AddColumn( TCColumn():New( STR0008 , { || aTempos[oLbTempos:nAt,03] }																						,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Numero Nf"
	oLbTempos:AddColumn( TCColumn():New( STR0009 , { || FGX_UFSNF(aTempos[oLbTempos:nAt,04]) }                                                                          ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // "Serie"
	oLbTempos:AddColumn( TCColumn():New( STR0048 , { || aTempos[oLbTempos:nAt,14] }																						,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // "Nro Orc Loja"
	oLbTempos:AddColumn( TCColumn():New( STR0010 , { || aTempos[oLbTempos:nAt,05] }																						,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Faturar Para"
	oLbTempos:AddColumn( TCColumn():New( STR0011 , { || aTempos[oLbTempos:nAt,06] }																						,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // "Loja"
	oLbTempos:AddColumn( TCColumn():New( STR0012 , { || aTempos[oLbTempos:nAt,07] }																						,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // "Nome"
	oLbTempos:AddColumn( TCColumn():New( STR0013 , { || Transform(aTempos[oLbTempos:nAt,08] , "@E 999,999,999.99" ) }													,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) // "Total Pecas"
	oLbTempos:AddColumn( TCColumn():New( STR0014 , { || Transform(aTempos[oLbTempos:nAt,09] , "@R 99:99" ) }															,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // "Tp Padr"
	oLbTempos:AddColumn( TCColumn():New( STR0015 , { || Transform(aTempos[oLbTempos:nAt,10] , "@R 99:99" ) }															,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) // "Tp Trab"
	oLbTempos:AddColumn( TCColumn():New( STR0016 , { || Transform(aTempos[oLbTempos:nAt,11] , "@E 999,999,999.99" ) }													,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) // "Total Srv"
	oLbTempos:bLDblClick := { || FS_MARCA() }
	oLbTempos:Refresh()

	// Folder - "Servicos"
	oLbSrv := TWBrowse():New(00,00,00,00,,,,oFolder150:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbSrv:nAT := 1
	oLbSrv:SetArray(aSrv)
	oLbSrv:Align := CONTROL_ALIGN_ALLCLIENT
	oLbSrv:AddColumn( TCColumn():New( ""      , { || Iif( aSrv[oLbSrv:nAt,8] == "D" , oAzul , Iif(aSrv[oLbSrv:nAt,8] == "F" , oVermelho , oVerde) ) } ,,,,"LEFT" ,010,.T.,.F.,,,,.F.,) )
	oLbSrv:AddColumn( TCColumn():New( STR0007 , { || aSrv[oLbSrv:nAt,2] }                                                                             ,,,,"LEFT" ,020,.F.,.F.,,,,.F.,) ) // "TT"
	oLbSrv:AddColumn( TCColumn():New( STR0069 , { || aSrv[oLbSrv:nAt,10] }                                                                            ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) ) // "Num. Lib. TT"
	If lVO4_FUNDIS
		oLbSrv:AddColumn( TCColumn():New( RetTitle("VO4_FUNDIS") , { || IIf(!Empty(aSrv[oLbSrv:nAt,13]),aSrv[oLbSrv:nAt,13]+"-"+aSrv[oLbSrv:nAt,14],"") } ,,,,"LEFT" ,75,.F.,.F.,,,,.F.,) ) // "Tec. Lib. TT"
	EndIf
	oLbSrv:AddColumn( TCColumn():New( STR0008 , { || aSrv[oLbSrv:nAt,3] }                                                                             ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) ) // "Numero Nf"
	oLbSrv:AddColumn( TCColumn():New( STR0009 , { || FGX_UFSNF(aSrv[oLbSrv:nAt,11]) }                                                                 ,,,,"LEFT" ,020,.F.,.F.,,,,.F.,) ) // "Serie"
	oLbSrv:AddColumn( TCColumn():New( STR0019 , { || aSrv[oLbSrv:nAt,4] }                                                                             ,,,,"LEFT" ,030,.F.,.F.,,,,.F.,) ) // "Tp Srv"
	oLbSrv:AddColumn( TCColumn():New( STR0023 , { || aSrv[oLbSrv:nAt,9] }                                                                             ,,,,"LEFT" ,030,.F.,.F.,,,,.F.,) ) // "Grupo"
	oLbSrv:AddColumn( TCColumn():New( STR0020 , { || aSrv[oLbSrv:nAt,5] }                                                                             ,,,,"LEFT" ,070,.F.,.F.,,,,.F.,) ) // "Codigo"
	oLbSrv:AddColumn( TCColumn():New( STR0021 , { || aSrv[oLbSrv:nAt,6] }                                                                             ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) ) // "Descricao"
	oLbSrv:AddColumn( TCColumn():New( STR0022 , { || Transform(aSrv[oLbSrv:nAt,7],"@E 999,999,999.99") }                                              ,,,,"RIGHT",040,.F.,.F.,,,,.F.,) ) // "Valor"
	oLbSrv:Refresh()


	// Folder - "Pecas"
	oLbPeca := TWBrowse():New(00,00,00,00,,,,oFolder150:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbPeca:nAT := 1
	oLbPeca:SetArray(aPeca)
	oLbPeca:Align := CONTROL_ALIGN_ALLCLIENT
	oLbPeca:AddColumn( TCColumn():New( ""      , { || IIf( aPeca[oLbPeca:nAt,9] == "D" , oAzul , If(aPeca[oLbPeca:nAt,9] == "F" , oVermelho , oVerde) ) } ,,,,"LEFT" ,010,.T.,.F.,,,,.F.,) )
	oLbPeca:AddColumn( TCColumn():New( STR0007 , { || aPeca[oLbPeca:nAt,2] }                                                                              ,,,,"LEFT" ,020,.F.,.F.,,,,.F.,) ) // "TT"
	oLbPeca:AddColumn( TCColumn():New( STR0069 , { || aPeca[oLbPeca:nAt,12] }                                                                             ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) ) // "Num. Lib. TT"
	If lVO3_FUNDIS
		oLbPeca:AddColumn( TCColumn():New( RetTitle("VO3_FUNDIS") , { || IIf(!Empty(aPeca[oLbPeca:nAt,15]),aPeca[oLbPeca:nAt,15]+"-"+aPeca[oLbPeca:nAt,16],"") } ,,,,"LEFT" ,75,.F.,.F.,,,,.F.,) ) // "Tec. Lib. TT"
	EndIf
	oLbPeca:AddColumn( TCColumn():New( STR0008 , { || aPeca[oLbPeca:nAt,3] }                                                                              ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) ) // "Numero Nf"
	oLbPeca:AddColumn( TCColumn():New( STR0009 , { || FGX_UFSNF(aPeca[oLbPeca:nAt,13]) }                                                                  ,,,,"LEFT" ,020,.F.,.F.,,,,.F.,) ) // "Serie"
	oLbPeca:AddColumn( TCColumn():New( STR0023 , { || aPeca[oLbPeca:nAt,4] }                                                                              ,,,,"LEFT" ,030,.F.,.F.,,,,.F.,) ) // "Grupo"
	oLbPeca:AddColumn( TCColumn():New( STR0020 , { || aPeca[oLbPeca:nAt,5] }                                                                              ,,,,"LEFT" ,070,.F.,.F.,,,,.F.,) ) // "Codigo"
	oLbPeca:AddColumn( TCColumn():New( STR0021 , { || aPeca[oLbPeca:nAt,6] }                                                                              ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) ) // "Descricao"
	oLbPeca:AddColumn( TCColumn():New( STR0024 , { || Transform(aPeca[oLbPeca:nAt,7],"@E 999,999,999") }                                                  ,,,,"RIGHT",040,.F.,.F.,,,,.F.,) ) // "Quantidade"
	oLbPeca:AddColumn( TCColumn():New( STR0022 , { || Transform(aPeca[oLbPeca:nAt,8],"@E 999,999,999.99") }                                               ,,,,"RIGHT",040,.F.,.F.,,,,.F.,) ) // "Valor"
	oLbPeca:Refresh()

	oPan150BOT := TPanel():New(aPosObj[2,1],aPosObj[2,2],"",oDlg150,NIL,.T.,.F.,NIL,NIL,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.F.)

	@ 03,040 BITMAP oxVerde RESOURCE "BR_VERDE" OF oPan150BOT NOBORDER SIZE 10,10 when .f. PIXEL
	@ 03,050 SAY STR0025 OF oPan150BOT SIZE 32,08 PIXEL  //Aberta

	@ 03,135 BITMAP oxAzul  RESOURCE "BR_AZUL" OF oPan150BOT NOBORDER SIZE 10,10 when .f. PIXEL
	@ 03,145 SAY STR0026 OF oPan150BOT SIZE 42,08 PIXEL COLOR CLR_BLACK //Liberada

	@ 03,225 BITMAP oxVermelho RESOURCE "BR_VERMELHO" OF oPan150BOT NOBORDER SIZE 10,10 when .f. PIXEL
	@ 03,235 SAY STR0027 OF oPan150BOT SIZE 32,08 PIXEL COLOR CLR_BLACK //Fechada

	@ 03,315 BITMAP oxVermelho RESOURCE "BR_PRETO" OF oPan150BOT NOBORDER SIZE 10,10 when .f. PIXEL
	@ 03,325 SAY STR0060 OF oPan150BOT SIZE 32,08 PIXEL COLOR CLR_BLACK //Cancelada

	ACTIVATE MSDIALOG oDlg150 ON INIT EnchoiceBar( oDlg150,;
		{ || IIf( FS_GRACANCEL(.t.,"",aPeca,aSrv) , IIf( !OM150LVOS( @aPeca, @aSrv ) , lEndOk := .t. , .f. ) , .f. ) , IIf( lEndOk , oDlg150:End() , .f. ) } ,;
		{ || ( OM150FECHAR(), oDlg150:End() ) })

Else

	cTipTem := ""
	cLibVOO := ""

	nPos := aScan( aAutoCab , { |x| x[1] == "MOTIVO" } )
	cParam01 := aAutoCab[ nPos , 2 ]

	VS0->(DbSetOrder(1))
	If !VS0->(DbSeek( xFilial("VS0") + "000002" + cParam01 ))
		HELP(" ",1,"REGNOIS",,"Motivo" + ": " + cParam01,4,1)
		lMsErroAuto := .t.
		Return .f.
	EndIf

	// Procura o Tipo de Tempo para cancelar ...
	If (nPos := aScan( aAutoCab , { |x| x[1] == "TIPTEM" } )) > 0
		cTipTem := aAutoCab[ nPos , 2 ]
	EndIf

	// Se enviar o Tipo de Tempo ...
	// Se vier em branco esta cancelando a OS
	If !Empty(cTipTem)

		If (nPos := aScan( aAutoCab , { |x| x[1] == "LIBVOO" } )) > 0
			cLibVOO := aAutoCab[ nPos, 2 ]
		Else
			cLibVOO := Space(TamSX3("VOO_LIBVOO")[1])
		EndIf
		nPos := aScan( aTempos , { |x| x[2] == cTipTem .and. x[15] == cLibVOO } )

		If nPos > 0
			If !FS_MARCA( nPos )
				lMsErroAuto := .t.
				Return .f.
			EndIf
		Else
			FMX_HELP("OM150ERR01",STR0074 + CRLF + CRLF + RetTitle("VOI_TIPTEM") + ": " + cTipTem + CRLF + RetTitle("VOO_LIBVOO") + ": " + cLibVOO ) // "Tipo de tempo nใo encontrado na lista de tipos de tempos liberados da Ordem de Servi็o."
			lMsErroAuto := .t.
			Return .f.
		EndIf
	EndIf

	If !FS_GRACANCEL(.t.,"",aPeca,aSrv)
		lMsErroAuto := .t.
		Return .f.
	EndIf

EndIf

dbSelectArea("VO1")
DbGoTo( nPosVO1 )


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MARCA บAutor  ณ Rubens Takahashi   บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marcar um Tipo de Tempo para Cancelamento                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MARCA(nLinTempos)

Local cPrefNF
Local lVAI_VOSFER := (VAI->(FieldPos("VAI_VOSFER")) <> 0)
Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0
Local cPedido

Default nLinTempos := oLbTempos:nAT

// Listbox esta vazio
If Empty(aTempos[nLinTempos,2])
	Return .f.
EndIf
//

// Se ja tiver marcado, somente desmarca selecao ...
If aTempos[nLinTempos,1]
	aTempos[nLinTempos,1] := .f.
	If !lOM150Auto
		oLbTempos:Refresh()
	EndIf
	Return .t.
EndIf
//

// Nao deixa marcar tipo de tempo ja cancelado ...
If aTempos[nLinTempos,13] == "C"
	Return .f.
EndIf
//

If ( ExistBlock("OFM150MK") )
	lRet := ExecBlock("OFM150MK",.f.,.f.)
	if !lRet
		Return .f.
	Endif
EndIf
If !Empty(aTempos[ nLinTempos , 14 ])
	Help(" ",1,"M150LOJA")
	aTempos[nLinTempos,1]  := .f.
	Return .f.
EndIf

// Validar Ferramentas requisitadas para a OS e Tp.Tempo
If lVAI_VOSFER
	If !OM450VFER( M->VO1_NUMOSV , aTempos[nLinTempos,2] , "3" ) // 3 - Cancelamento de OS
		aTempos[nLinTempos,1]  := .f.
		Return .f.
	EndIf
EndIf

SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
If SF2->(dbSeek(xFilial("SF2") + aTempos[ nLinTempos , 03 ] + aTempos[ nLinTempos , 04 ] + aTempos[ nLinTempos , 05 ] + aTempos[ nLinTempos , 06 ] ))

	cPrefNF := IIf( Empty(SF2->F2_PREFIXO) , &(GETMV("MV_1DUPREF")) , SF2->F2_PREFIXO )
	cPrefNF := PadR( AllTrim(cPrefNF) , TamSX3("E1_PREFIXO")[1] , " ")
	cPedido := OM150PEDIDO( aTempos[ nLinTempos , 03 ], aTempos[ nLinTempos , 04 ], aTempos[ nLinTempos , 05 ], aTempos[ nLinTempos , 06 ] , lNFeCancel)

	SE1->(dbSetOrder(1))
	SE1->(dbSeek( xFilial('SE1') + cPrefNF + SF2->F2_DOC ))

	While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == SF2->F2_DOC .and. SE1->E1_PEDIDO == cPedido
		If !Empty( SE1->E1_BAIXA ) .Or. SE1->E1_SALDO # SE1->E1_VALOR
			Help("  ",1,"TITBAIXADO")
			Return .f.
		EndIf
		SE1->(dbSkip())
	EndDo
EndIf

aEval( aTempos , {|x| x[1] := .f. } )
aTempos[nLinTempos,01] := .t.

If !lOM150Auto
	oLbTempos:Refresh()
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GRACANCEL บAutor  ณFabio           บ Data ณ  07/15/00   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava cancelamento do Fechamento do tipo de tempo          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRACANCEL(lValid,cOrcLoja,aPeca,aSrv)

Local ni         := 0
Local nRegistros := 0
Local lRet       := .t.
Local cAliasVO3  := GetNextAlias()
Local cAliasVO4  := GetNextAlias()
Local cAliasVVD  := GetNextAlias()
Local cAliasVSF  := GetNextAlias()
Local cAliasVS6  := GetNextAlias()
Local cAliasVOO  := GetNextAlias()
Local cQAlVS1    := GetNextAlias()
Local cQAlConf   := "SQLCONF"
Local lConfOfi   := GetNewPar("MV_MIL0145","0") == "1" // Trabalha com Conferencia de Itens na Oficina
Local cQuery     := ""
Local nHora		 := Val(Left(Time(),2)+SubStr(Time(),4,2))
Local aOsRelac	 := {} // Contem as OS's Relacionadas (Fechamento Agrupado)

Local nNUMIDE 	 := TamSX3("VS9_NUMIDE")[1]
Local aAltOSV	 := {} // Controla as OS's que foram alteradas ...
Local nCont
Local lCancOS	 := .f. // Controla se vai cancelar a OS

// Variaveis necessarias para gerar CEV no Final do processo
Local nCEVQTD := 0
Local cCEVNFI := ""
Local cCEVOSV := ""
Local cCEVCLI := ""
Local cCEVLOJ := ""
Local cCEVTTP := ""
Local lMotCan := .f.
Local aCEV    := {}
Local cGCCOCEV   := ""
Local lVCM510CEV := FindFunction("VCM510CEV")
Local nRecVO1
Local cSQL
Local cNumPedido
Local aRecTit := {}

Local lVO3VECREL := (VO3->(FieldPos("VO3_VECREL")) <> 0)
Local lVO4VSCIDE := (VO4->(FieldPos("VO4_VSCIDE")) <> 0)

Local lVSJCODIGO := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)

Local lVAI_VOSFER := (VAI->(FieldPos("VAI_VOSFER")) <> 0)

Local lVVD_FILOSV := VVD->(FieldPos("VVD_FILOSV")) <> 0

Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0
Local lIntegLoja

Local aItensNew := {}

Local lNaoCancelou := .t.

Default lValid := .t.
Default cOrcLoja := ""

lIntegLoja := !Empty(cOrcLoja)

// Valida se pode continuar o cancelamento ...
If !FS_VALCAN()
	If lValid
		Help("  ",1,"SEMPERM")
		Return(.f.)
	EndIf
EndIf
//

// Verifica se foi selecionado algum tipo de tempo ...
ni := Ascan( aTempos , {|x| x[1] == .t. } )
If ni == 0

	// Verifica se todos os TT's estao cancelados
	If aScan( aTempos , { |x| x[13] <> "C" } ) <> 0
		Return .f.
	EndIf
	//

	lCancOS := .t.

EndIf
//

// Validar Ferramentas requisitadas para a OS e Tp.Tempo
If !lCancOS .and. lVAI_VOSFER
	If !OM450VFER( M->VO1_NUMOSV , aTempos[ni,2] , "3" ) // 3 - Cancelamento de OS
		Return .f.
	EndIf
EndIf

// Verifica se existe outro fechamento com o mesmo numero de nota fiscal
If !lCancOS .and. !OM150OSREL( aTempos[ni,3] , aTempos[ni,4] , M->VO1_NUMOSV , aTempos[ni,02] , aTempos[ni,15] , @aOsRelac )
	If lValid
		Return(.f.)
	EndIf
EndIf
//
If !lOM150Auto
	If lValid .and. !MsgYesNo( STR0046 , STR0050) // "Confirma cancelamento", "Aten็ใo"
		Return .f.
	EndIf
EndIf

// ponto de entrada ao clicar no botใo confirmar na rotina de cancelamento de O.S.
If ExistBlock("OM150VCO")
	If !ExecBlock("OM150VCO",.f.,.f.,{})
		Return .f.
	EndIf
EndIf

// Pergunta o Motivo do Cancelamento (Nao pergunta se for cancecar a OS) ...
If !lCancOS
	If !lOM150Auto .and. aTempos[nI,13] == "D"
		aMotCancel := OFA210MOT("000002","2","","",.f.) // Filtro da consulta do motivo
		if Len(aMotCancel) == 0
			Return .f.
		Endif
		DbSelectArea("VS0")
		DbSetOrder(1)
		DbSeek( xFilial("VS0") + "000002" + aMotCancel[1] )
		cParam01 := aMotCancel[1]  // Foi criada esta variavel, porque em algum programa de integracao, esta variavel esta tendo seu conteudo alterado
	EndIf
EndIf
//

If !lCancOS

	dbSelectArea("VOI")
	dbSetOrder(1)
	dbSeek(xFilial("VOI") + aTempos[ni,2] )

	dbSelectArea("VOO")
	dbSetOrder(1)
	dbSeek( xFilial("VOO") + VO1->VO1_NUMOSV + aTempos[ni,2] + aTempos[ni,15] )

EndIf

If lValid .and. !OM150VLD( ni , lCancOS, aPeca , aSrv , aOSRelac )
	MsUnlockAll()
	Return .f.
EndIf
//

lMSHelpAuto := .t.
lMsErroAuto := .f.

If !lCancOS .and. aTempos[ ni , 13 ] == "F" .and. !lIntegLoja

	aRecTit := FS_LEVTIT( aTempos[ni,3], aTempos[ni,4], aTempos[ni,5], aTempos[ni,6] , lNFeCancel)

	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aTempos[ni,2] ))

	// Procura o numero do pedido de Venda Gerado
	If !Empty(aTempos[ni,3])
		//
		If OM1500025_MarcaJD()
			If !OM1500015_EfetuaCancGar(lValid,aOsRelac,ni)
				MostraErro()
				MsUnlockAll()
				Return .f.
			EndIf
			lNaoCancelou := .f.
		EndIf
		
		cNumPedido := OM150PEDIDO( aTempos[ni,3] , aTempos[ni,4] , aTempos[ni,5], aTempos[ni,6] , lNFeCancel)
		//
		// Deleta Nota Fiscal
		If lNFeCancel .and. !FS_DELNFI( aTempos[ni,3] , aTempos[ni,4] , aTempos[ni,5] , aTempos[ni,6] , lNFeCancel)
			If lValid
				If lMsErroAuto
					MostraErro()
				EndIf
				MsUnlockAll()
				Return .f.
			EndIf
		Endif
	Endif
	//
EndIf

// Inicio do Cancelamento ...
Begin Transaction

nRegistros := 1
// Seta barra de progresso
ProcRegua(nRegistros)

If !lCancOS

	If lNaoCancelou
		If !OM1500015_EfetuaCancGar(lValid,aOsRelac,ni)
			lRet := .f.
			DisarmTransaction()
			MsUnlockAll()
			Break
		EndIf
	EndIf

	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aTempos[ni,2] ))

EndIf

dbSelectArea("VOO")

aAltOSV := {}

// Se for cancelar a OS (Atualizar VO1_STATUS)
If lCancOS
	AADD( aAltOSV , { M->VO1_NUMOSV ,  ,  } )
Else

	// Cancelamento de Tipo de Tempo Finalizado ...
	// Deleta o numero da nota fiscal e financeiro
	If aTempos[ ni , 13 ] == "F"

		// Tipo de Tempo NAO ้ tipo de tempo INTERNO
		If !Empty(aTempos[ni,3])

			// Cancela titulo
			If Empty( VOO->VOO_CONTCD )
				If !FS_CANTIT( aRecTit , lNFeCancel)
					If lValid
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
				EndIf
			// Cancela CDCI
			Else
				If !FS_CANCDCI( VOO->VOO_CONTCD )//  Verificar
					If lValid
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
				EndIf
				//
			EndIf
			//

			// Quando nใo integrado com Loja/Venda Direta
			If !lIntegLoja
				// Deleta Nota Fiscal - Somente quando gera Nota Fiscal
				If !lNFeCancel .and. Empty(cOrcLoja) .and. !FS_DELNFI( aTempos[ni,3] , aTempos[ni,4] , aTempos[ni,5] , aTempos[ni,6] , lNFeCancel)
					If lValid
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
				Endif
				// Pedido de Venda
				If !FS_DELPED(cNumPedido)
					If lValid
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
				EndIf
			EndIf
			//

		EndIf
		//

		// (Temporario) - Cancela pelo numero da NF, pois o OFIOM160 gera os registros da VS9 pelo numero da NF
		If !Empty(VOO->VOO_NUMNFI)

			// Deleta Arquivo de Entradas
			dbSelectArea("VS9")
			dbSetOrder(1)
			VS9->(dbSeek( xFilial("VS9") + "OF" + VOO->VOO_NUMNFI + VOO->VOO_SERNFI))
			While !VS9->(Eof()) .and. VS9->VS9_FILIAL == xFilial("VS9") .and. Alltrim(VS9->VS9_NUMIDE) == Alltrim("OF"+VOO->VOO_NUMNFI+VOO->VOO_SERNFI)
				If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
					VS9->(dbSkip())
					Loop
				EndIf

				RecLock("VS9",.F.,.T.)
				VS9->(dbdelete())
				VS9->(MsUnlock())
				VS9->(DbSkip())

			Enddo

			// Deleta Dados Parcelamento da Entrada
			dbSelectArea("VSE")
			dbSetOrder(1)
			dbSeek( xFilial("VSE") + "OF" + VOO->VOO_NUMNFI + VOO->VOO_SERNFI )
			While !VSE->(Eof()) .and. VSE->VSE_FILIAL == xFilial("VSE") .and. Alltrim(VSE->VSE_NUMIDE) == Alltrim("OF" + VOO->VOO_NUMNFI + VOO->VOO_SERNFI )
				If VSE->VSE_TIPTEM <> VOO->VOO_TIPTEM
					VSE->(dbSkip())
					Loop
				EndIf

				RecLock("VSE",.F.,.T.)
				VSE->(dbdelete())
				VSE->(MsUnlock())
				VSE->(DbSkip())
			Enddo
			//

		EndIf
		//

	EndIf
	//

	// ------------------------------------------------------------------ //
	// Pesquisa na tabela VOO, por causa do fechamento agrupado           //
	// Exclui Negociacao, Avaliacao de Peca/Servicos, Despesa com Veiculo //
	// ------------------------------------------------------------------ //
	// Pesquisa VFE, para fechamento integrado com o LOJA
	If (Empty(VOO->VOO_NUMNFI) .and. !Empty(VOO->VOO_PESQLJ)) .or. !Empty(cOrcLoja)
		cQuery := "SELECT VOO.R_E_C_N_O_ RECNO, VFE.R_E_C_N_O_ VFERECNO "
		cQuery +=  " FROM " + RetSQLName("VFE") + " VFE "
		cQuery +=		" JOIN " + RetSQLName("VOO") + " VOO"
		cQuery += 			 " ON VOO.VOO_FILIAL = '" + xFilial("VOO") + "'"
		cQuery += 			" AND VOO.VOO_NUMOSV = VFE.VFE_NUMOSV "
		cQuery += 			" AND VOO.VOO_TIPTEM = VFE.VFE_TIPTEM "
		cQuery += 		    " AND VOO.VOO_LIBVOO = VFE.VFE_LIBVOO "
		cQuery += 			" AND VOO.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VFE.VFE_FILIAL = '" + xFilial("VFE") + "'"
		cQuery += 	" AND VFE.VFE_NUMORC = '" + IIf( !Empty(cOrcLoja) , cOrcLoja , VOO->VOO_PESQLJ ) + "'"
		cQuery += 	" AND VFE.D_E_L_E_T_ = ' '"
	Else
		cQuery := "SELECT VOO.R_E_C_N_O_ RECNO"
		cQuery +=  " FROM " + RetSQLName("VOO") + " VOO"
		cQuery += " WHERE VOO_FILIAL = '" + xFilial("VOO") + "'"
		// Pesquisa pela NF, para cancelar fechamento agrupado
		If !Empty(VOO->VOO_NUMNFI)
			cQuery += " AND VOO.VOO_NUMNFI = '" + aTempos[ni,3] + "'"
			cQuery += " AND VOO.VOO_SERNFI LIKE '" + aTempos[ni,4] + "%'"
			// Pesquisa pela OS e TT
		Else
			cQuery += " AND VOO.VOO_NUMOSV = '" + M->VO1_NUMOSV + "'"
			cQuery += " AND VOO.VOO_TIPTEM = '" + aTempos[ni,2] + "'"
			cQuery += " AND VOO.VOO_LIBVOO = '" + aTempos[ni,15] + "'"
		EndIf
		cQuery += " AND VOO.D_E_L_E_T_ = ' '"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVOO, .F., .T. )
	Do While !(cAliasVOO)->(Eof())

		dbSelectArea("VOO")
		VOO->(dbGoTo((cAliasVOO)->RECNO))

		dbSelectArea("VOI")
		dbSetOrder(1)
		dbSeek( xFilial("VOI") + VOO->VOO_TIPTEM )

		// Variaveis necessarias para gerar CEV no Final do processo
		nCEVQTD++
		cCEVNFI := VOO->VOO_NUMNFI+"-"+ FGX_MILSNF('VOO', 2, 'VOO_SERNFI')
		cCEVOSV := VOO->VOO_NUMOSV
		cCEVCLI := VOO->VOO_FATPAR
		cCEVLOJ := VOO->VOO_LOJA
		cCEVTTP := VOI->VOI_SITTPO
		//

		// Deleta despesa do veiculo referente a OS
		if VOI->VOI_SITTPO == "3" .and. VOI->VOI_DESVEI == "1"
			cQuery := "SELECT VVD.R_E_C_N_O_ RECNO"
			cQuery +=  " FROM " + RetSQLName("VVD") + " VVD "
			cQuery += " WHERE VVD.VVD_FILIAL = '" + xFilial("VVD") + "'"
			If lVVD_FILOSV
				cQuery += " AND ( VVD.VVD_FILOSV = '" + xFilial("VOO") + "' OR VVD.VVD_FILOSV = '  ') "
			Endif
			cQuery +=   " AND VVD.VVD_CHAINT = '" + M->VO1_CHAINT + "'"
			cQuery +=   " AND VVD.VVD_NUMOSV = '" + VOO->VOO_NUMOSV + "'"
			If VVD->(FieldPos("VVD_LIBVOO")) <> 0
				cQuery += " AND ( ( VVD.VVD_TIPTEM = '  ' OR VVD.VVD_TIPTEM = '" + aTempos[ni,2]  + "' )"
				cQuery +=       " AND "
				cQuery +=     " ( VVD.VVD_LIBVOO = '  ' OR VVD.VVD_LIBVOO = '" + aTempos[ni,15] + "' ) ) "
			EndIf
			cQuery +=   " AND VVD.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD, .F., .T. )
			(cAliasVVD)->(dbGoTop())
			dbSelectArea("VVD")
			Do While !(cAliasVVD)->(Eof())
				VVD->(dbGoTo( (cAliasVVD)->RECNO ))
				RecLock("VVD",.F.,.T.)
				dbdelete()
				MsUnlock()
				(cAliasVVD)->(dbSkip())
			EndDo
			(cAliasVVD)->(DbCloseArea())
			dbSelectArea("VVD")
			If VOO->(FieldPos("VOO_D3DVEI")) > 0 .and. !Empty(VOO->VOO_D3DVEI)
				dbselectarea("SD3")
				dbsetorder(4)
				if dbseek(xFilial("SD3")+VOO->VOO_D3DVEI+'E0'+Padr(GetMV("MV_GRUVEI"),TamSX3("B1_GRUPO")[1])+"_"+M->VO1_CHAINT)
					aItensNew := {}
					aadd(aItensNew,{"D3_FILIAL",SD3->D3_FILIAL,NIL})
					aadd(aItensNew,{"D3_NUMSEQ",SD3->D3_NUMSEQ,NIL})
					aadd(aItensNew,{"D3_COD",SD3->D3_COD,NIL})
					aadd(aItensNew,{"D3_UM",SD3->D3_UM,NIL})
					aadd(aItensNew,{"D3_QUANT",SD3->D3_QUANT,NIL})
					aadd(aItensNew,{"D3_CUSTO1",SD3->D3_CUSTO1,NIL})
					aadd(aItensNew,{"D3_LOCAL",SD3->D3_LOCAL,NIL})
					aadd(aItensNew,{"D3_EMISSAO",SD3->D3_EMISSAO,NIL})
					aadd(aItensNew,{"D3_DOC",SD3->D3_DOC,NIL})
					aAdd(aItensNew,{"INDEX",4,Nil})
					lMsHelpAuto := .t.
					lMsErroAuto := .f.
					MSExecAuto({|x,y| mata240(x,y)},aItensNew,5)
					If lMsErroAuto
						lRet := .f.
						DisarmTransaction()
						MostraErro()
						Break
					Else
						dbSelectArea("VOO")
						RecLock("VOO",.f.)
							VOO->VOO_D3DVEI := ""
						MsUnLock()
					EndIf
				EndIf
			EndIf
		endif
		dbSelectArea("VVD")
		//

		// Deleta Avaliacao de Pecas
		dbSelectArea("VEC")
		dbSetOrder(5)
		dbSeek( xFilial("VEC") + VOO->VOO_NUMOSV + VOO->VOO_TIPTEM )
		Do While !VEC->(Eof()) .And. VEC->VEC_FILIAL == xFilial("VEC") .and. VEC->VEC_NUMOSV == VOO->VOO_NUMOSV .and. VEC->VEC_TIPTEM == VOO->VOO_TIPTEM

			If VEC->VEC_LIBVOO <> VOO->VOO_LIBVOO
				VEC->(dbSkip())
				Loop
			EndIf

			// Deleta arquivo de comissao
			dbSelectArea("VSG")
			dbSetOrder(1)
			dbSeek(xFilial("VSG") + VEC->VEC_NUMIDE + "P" )
			Do While !Eof() .And. VSG->VSG_FILIAL == xFilial("VSG") .And. VSG->VSG_NOSNUM == VEC->VEC_NUMIDE .And. VSG->VSG_TIPCOM == "P"
				dbSelectArea("VSG")
				RecLock("VSG",.F.,.T.)
				dbdelete()
				MsUnlock()
				dbSkip()
			EndDo
			//

			//
			dbSelectArea("VEC")
			RecLock("VEC",.F.,.T.)
			dbdelete()
			MsUnlock()
			//
			dbSkip()

		EndDo
		//

		// Deleta Avaliacao de Servicos
		dbSelectArea("VSC")
		dbSetOrder(1)
		dbSeek( xFilial("VSC") + VOO->VOO_NUMOSV + VOO->VOO_TIPTEM )
		Do While !VSC->(Eof()) .And. VSC->VSC_FILIAL == xFilial("VSC") ;
			.And. VSC->VSC_TIPTEM == VOO->VOO_TIPTEM ;
			.And. VSC->VSC_NUMOSV == VOO->VOO_NUMOSV

			If VSC->VSC_LIBVOO <> VOO->VOO_LIBVOO
				VSC->(dbSkip())
				Loop
			EndIf

			// Deleta arquivo de comissao
			dbSelectArea("VSG")
			dbSetOrder(1)
			dbSeek(xFilial("VSG") + VSC->VSC_NUMIDE + "S" + VSC->VSC_CODPRO )
			Do While !Eof() .And. VSG->VSG_FILIAL == xFilial("VSG") ;
				.And. VSG->VSG_NOSNUM == VSC->VSC_NUMIDE ;
				.And. VSG->VSG_TIPCOM == "S" ;
				.And. VSG->VSG_CODVEN == VSC->VSC_CODPRO

				// Deleta
				dbSelectArea("VSG")
				RecLock("VSG",.F.,.T.)
				dbdelete()
				MsUnlock()
				//
				dbSkip()
			EndDo

			// Deleta Avaliacao Servico
			dbSelectArea("VSC")
			RecLock("VSC",.F.,.T.)
			dbdelete()
			MsUnlock()
			//
			dbSkip()

		EndDo
		//

		// Posi็ใo Controle de Manuten็ใo (Fechamento por Quilometragem)
		DbSelectArea("VF3")
		DbSetOrder(1)
		DbSeek( xFilial("VF3") + VOO->VOO_NUMOSV )
		While !VF3->(Eof()) .and. VF3->VF3_FILIAL == xFilial("VF3") .and. VF3->VF3_NUMOSV == VOO->VOO_NUMOSV

			If VF3->VF3_NUMNFI <> VOO->VOO_NUMNFI .or. VF3->VF3_SERNFI <> VOO->VOO_SERNFI
				VF3->(dbSkip())
				Loop
			EndIf

			RecLock("VF3",.F.,.T.)
			dbdelete()
			MsUnlock()
			dbSkip()
		EndDo
		//

		// Volta Kilometragem
		dbSelectArea("VF4")
		dbSetOrder(4)
		While dbSeek( xFilial("VF4") + VOO->VOO_NUMOSV )
			RecLock("VF4",.f.)
			VF4->VF4_NUMOSV := Space(Len(VF4->VF4_NUMOSV))
			MsUnLock()
		EndDo
		//

		If FindFunction("OFIOA510GRV")
			// "Controle de Valor de Garantia por periodo" - chamada da Funcao para
			// (2-subtrair) do VPH/VPI. Andre Luis Almeida - 27/03/2009
			OFIOA510GRV(2,VOO->VOO_NUMOSV,VOO->VOO_TIPTEM)
		EndIf

		// Deleta Arquivo de Entradas
		If aTempos[nI,13] <> "F"
			dbSelectArea("VS9")
			dbSetOrder(1)
			dbSeek( xFilial("VS9") + PadR(AllTrim(VOO->VOO_NUMOSV),nNUMIDE," ") + "O" )
			While !VS9->(Eof()) .and. VS9->VS9_FILIAL == xFilial("VS9") .and. VS9->VS9_NUMIDE == PadR(AllTrim(VOO->VOO_NUMOSV),nNUMIDE," ") .and. VS9->VS9_TIPOPE == "O"
				If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
					VS9->(dbSkip())
					Loop
				EndIf

				If VS9->VS9_LIBVOO <> VOO->VOO_LIBVOO
					VS9->(dbSkip())
					Loop
				EndIf

				RecLock("VS9",.F.,.T.)
				VS9->(dbdelete())
				VS9->(MsUnlock())
				VS9->(DbSkip())
			Enddo

			// Deleta Dados Parcelamento da Entrada
			dbSelectArea("VSE")
			dbSetOrder(1)
			dbSeek( xFilial("VSE") + PadR(AllTrim(VOO->VOO_NUMOSV),nNUMIDE," ") + "O" )
			While !VSE->(Eof()) .and. VSE->VSE_FILIAL == xFilial("VSE") .and. Alltrim(VSE->VSE_NUMIDE) == Alltrim("OF" + VOO->VOO_NUMNFI + VOO->VOO_SERNFI )
				If VSE->VSE_TIPTEM <> VOO->VOO_TIPTEM
					VSE->(dbSkip())
					Loop
				EndIf

				If VSE->VSE_LIBVOO <> VOO->VOO_LIBVOO
					VS9->(dbSkip())
					Loop
				EndIf

				RecLock("VSE",.F.,.T.)
				VSE->(dbdelete())
				VSE->(MsUnlock())
				VSE->(DbSkip())
			Enddo
			//

			// Deleta Negociacao ...
			dbSelectArea("VZ1")
			dbSetOrder(1)
			dbSeek( xFilial("VZ1") + VOO->VOO_NUMOSV + VOO->VOO_TIPTEM )
			While !VZ1->(Eof()) .and. VZ1->VZ1_FILIAL == xFilial("VZ1") .and. VZ1->VZ1_NUMOSV == VOO->VOO_NUMOSV .and. VZ1->VZ1_TIPTEM == VOO->VOO_TIPTEM

				If VZ1->VZ1_LIBVOO <> VOO->VOO_LIBVOO
					VZ1->(dbSkip())
					Loop
				EndIf

				RecLock("VZ1",.F.,.T.)
				VZ1->(dbdelete())
				VZ1->(MsUnlock())
				VZ1->(DbSkip())
			Enddo
			//
		EndIf

		// Deleta VFE - Rela็ใo Sigaloja Fec OS
		If !Empty(VOO->VOO_PESQLJ) .and. (cAliasVOO)->(VFERECNO) <> 0
			dbSelectArea("VFE")
			dbGoTo((cAliasVOO)->(VFERECNO))
			RecLock("VFE",.F.,.T.)
			dbdelete()
			MsUnlock()
		EndIf
		//

		If aTempos[nI,13] == "D"
			// Exclui VSF( Nao utilizada no fechamento novo OFIXX100)
			cQuery := "SELECT VSF.R_E_C_N_O_ VSFRECNO "
			cQuery +=  " FROM " + RetSQLName("VSF") + " VSF "
			cQuery += " WHERE VSF_FILIAL = '" + xFilial("VSF") + "'"
			cQuery +=   " AND VSF_NUMOSV = '" + VOO->VOO_NUMOSV + "'"
			cQuery +=   " AND VSF_TIPTEM = '" + VOO->VOO_TIPTEM + "'"
			cQuery +=   " AND VSF.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVSF, .F., .T. )
			While !(cAliasVSF)->(Eof())
				dbSelectArea("VSF")
				VSF->(dbGoTo((cAliasVSF)->VSFRECNO))
				Reclock("VSF",.f.,.t.)
				VSF->(dbDelete())
				VSF->(MsUnLock())
				(cAliasVSF)->(dbSkip())
			EndDo
			(cAliasVSF)->(dbCloseArea())
			dbSelectArea("VSF")
			//
		EndIf

		If aTempos[nI,13] == "D"
			// Exclui Liberacao de Desconto
			VS7->(dbSetOrder(1))
			cQuery := "SELECT R_E_C_N_O_ VS6RECNO"
			cQuery +=  " FROM " + RetSQLname("VS6") + " VS6"
			cQuery += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
			cQuery +=   " AND VS6_DOC IN ('Ind-" + VOO->VOO_NUMOSV + "','Agr-" + VOO->VOO_NUMOSV + "')"
			cQuery +=   " AND VS6_TIPTEM = '" + VOO->VOO_TIPTEM + "'"
			cQuery +=   " AND VS6_LIBVOO = '" + VOO->VOO_LIBVOO + "'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVS6 , .F., .T. )
			While !(cAliasVS6)->(Eof())

				VS6->(dbGoTo( (cAliasVS6)->VS6RECNO ))

				dbSelectArea("VS7")
				VS7->(dbSeek( xFilial("VS7") + VS6->VS6_NUMIDE ))
				While !VS7->(Eof()) .and. VS7->VS7_FILIAL == xFilial("VS7") .and. VS7->VS7_NUMIDE == VS6->VS6_NUMIDE
					RecLock("VS7",.F.,.T.)
					VS7->(dbDelete())
					VS7->(MsUnlock())
					VS7->(dbSkip())
				EndDo

				dbSelectArea("VS6")
				RecLock("VS6",.f.,.t.)
				VS6->(dbdelete())
				VS6->(MsUnlock())

				(cAliasVS6)->(dbSkip())
			EndDo
			(cAliasVS6)->(dbCloseArea())
			dbSelectArea("VS6")
			//
		EndIf

		If aTempos[nI,13] == "D"
			// Volta Disponibilidade
			dbSelectArea("VOZ")
			RecLock("VOZ",.t.)
			VOZ->VOZ_FILIAL := xFilial("VOZ")
			VOZ->VOZ_NUMOSV := VOO->VOO_NUMOSV
			VOZ->VOZ_TIPTEM := VOO->VOO_TIPTEM
			VOZ->VOZ_DATOCO := dDataBase
			VOZ->VOZ_DISCAN := "C"
			VOZ->VOZ_CODCON := POSICIONE("VAI",4,xFilial("VAI")+__cUserID,"VAI_CODTEC")
			If !lOM150Auto
				VOZ->VOZ_CODMOT := cParam01
			EndIf
			VOZ->VOZ_LIBVOO := VOO->VOO_LIBVOO
			MsUnlock()
			//
		EndIf

		If aTempos[nI,13] == "F"
			// Limpar Or็amentos de Oficina
			OM150VS1LIMPAORC(VOO->VOO_NUMNFI, VOO->VOO_SERNFI)
		EndIf

		// Cancelamento de Libera็ใo de Tipo de Tempo
		// deve limpar o campo "VOU_DATEXE" caso tipo "D" (disponibiliza็ใo)
		// Obs: FieldPos("VOU_SERINT") pois o campo ้ novo, antes o c๓digo nใo realizava esse cancelamento!
		If aTempos[nI,13] == "D" .And. VOU->(FieldPos("VOU_SERINT")) > 0
			// Verificar se o Servi็o estแ Relacionado e entใo
			// cancelar a Libera็ใo do Tipo de Tempo (o campo "VOU_DATEXE" deve ter seu conte๚do apagado)
			// VO1
			DbSelectArea("VO1")
			DbSetOrder(1) // VO1_FILIAL + VO1_NUMOSV
			If DbSeek(xFilial("VO1") + VOO->VOO_NUMOSV)
				// VOU
				DbSelectArea("VOU")
				DbSetOrder(2) // VOU_FILIAL + VOU_CHASSI
				If DbSeek(xFilial("VOU") + VO1->VO1_CHASSI)
					While !VOU->(Eof()) .And. xFilial("VOU") == VOU->VOU_FILIAL .And. VO1->VO1_CHASSI == VOU->VOU_CHASSI .And. VOO->VOO_NUMOSV == VOU->VOU_NUMOSV
						If VOO->VOO_TIPTEM == VOU->VOU_TIPTEM .And. !Empty(VOU->VOU_DATEXE)
							RecLock("VOU", .F.)
							VOU->VOU_DATEXE := CtoD("")
							MsUnlock()

							// Gravando percentual da Campanha
							OFA1100106_PercentualCampanhaVOP(VOU->VOU_NUMINT) // VOU_NUMINT
						EndIf

						VOU->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf

		If aTempos[nI,13] == "D"
			// Exclui registro de liberacao ...
			dbSelectArea("VOO")
			Reclock("VOO",.f.,.t.)
			VOO->(dbDelete())
			MsUnLock()
			//
		ElseIf aTempos[nI,13] == "F"
			dbSelectArea("VOO")
			Reclock("VOO",.f.,.t.)
			VOO->VOO_NUMNFI := Space(Len(VOO->VOO_NUMNFI))
			VOO->VOO_SERNFI := Space(Len(VOO->VOO_SERNFI))
			if FieldPos('VOO_SDOC') > 0
				VOO->VOO_SDOC := Space(TamSx3('VOO_SDOC')[1])
			EndIf
			VOO->VOO_PESQLJ := Space(Len(VOO->VOO_PESQLJ))
			//			VOO->VOO_TOTPEC := 0
			//			VOO->VOO_TOTSRV := 0
			//Otแvio 14/01/2013 - Antes estavam sendo zerados os totais de pe็as e servi็os pois o tipo de tempo voltava para aberto.
			//Com a altera็ใo do Rubens o tipo de tempo volta para liberado, por isso os valores nao podem ser apagados.
			MsUnLock()
		EndIf

		// Adiciona na matriz para posteriormente acertar as Requisicoes de OS
		AADD( aAltOSV , { VOO->VOO_NUMOSV, VOO->VOO_TIPTEM, VOO->VOO_LIBVOO } )
		//
		(cAliasVOO)->(dbSkip())

	EndDo

	If !lCancOS .and. Len(aAltOSV) == 0
		AADD( aAltOSV , { M->VO1_NUMOSV , aTempos[ni,2] , aTempos[ni,15] } )
	EndIf

	// --------------------------------------------//
	// Atualiza as Requisicoes de Pecas e Servicos //
	// --------------------------------------------//
	For nCont := 1 to Len(aAltOSV)

		VO1->(dbSetOrder(1))
		VO1->(MsSeek( xFilial("VO1") + aAltOSV[nCont,01] ))

		VV1->(dbSetOrder(1))
		VV1->(MsSeek( xFilial("VV1") + VO1->VO1_CHAINT ))

		// Acertando Requisicoes de Pecas ...
		cQuery := "SELECT VO3.R_E_C_N_O_ VO3RECNO"
		cQuery += " FROM " + RetSQLName("VO2") + " VO2"
		cQuery += 		 " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
		cQuery += 										   " AND VO3.VO3_NOSNUM = VO2_NOSNUM "
		cQuery += 										   " AND VO3.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
		cQuery +=   " AND VO2.VO2_NUMOSV = '" + aAltOSV[nCont,01] + "'"
		cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
		cQuery +=   " AND VO3.VO3_TIPTEM = '" + aAltOSV[nCont,02] + "'"
		cQuery +=   " AND VO3.VO3_LIBVOO = '" + aAltOSV[nCont,03] + "'"
		cQuery += " ORDER BY VO2.VO2_NOSNUM, VO3.VO3_GRUITE, VO3.VO3_CODITE"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cAliasVO3, .F., .T. )
		While !(cAliasVO3)->(Eof())

			dbSelectArea("VO3")
			dbGoTo((cAliasVO3)->VO3RECNO)
			RecLock("VO3",.f.)

			If !Empty(VO3->VO3_DATFEC) .or. lIntegLoja

				VO3->VO3_DATFEC := Ctod(" ")
				VO3->VO3_HORFEC := 0
				VO3->VO3_FUNFEC := ""
				VO3->VO3_NUMNFI := ""
				VO3->VO3_SERNFI := ""
				if FieldPos('VO3_SDOC') > 0
					VO3->VO3_SDOC := ""
				EndIf

				// Atualiza Ocorrencia do veiculo
				OM140VFB( "P" , VV1->VV1_PROATU , VV1->VV1_LJPATU , VV1->VV1_CHAINT , VO3->VO3_TIPTEM , VO3->VO3_NUMOSV , VO3->VO3_GRUITE , VO3->VO3_CODITE )
				//

			ElseIf !Empty(VO3->VO3_DATDIS)

				VO3->VO3_DATDIS := Ctod(" ")
				VO3->VO3_HORDIS := 0
				VO3->VO3_LIBVOO := ""
				If lVO3_FUNDIS // Tec. Lib. TT
					VO3->VO3_FUNDIS := ""
				EndIf

			Else

				VO3->VO3_DATCAN := dDataBase
				VO3->VO3_HORCAN := nHora

			EndIf

			If lVO3VECREL .and. Empty(VO3->VO3_DATFEC)
				VO3->VO3_VECREL := ""
				VO3->VO3_PEDNUM := ""
				VO3->VO3_PEDITE := ""
				VO3->VO3_ITENFI := ""
			EndIf

			MsUnLock()

			(cAliasVO3)->(dbSkip())

		EndDo
		(cAliasVO3)->(dbCloseArea())
		dbSelectArea("VO3")
		dbGoTop() // Desposiciona para funcionar SELECT
		//

		// Acertando Requisicoes de Servico ...
		cQuery := "SELECT VO4.R_E_C_N_O_ VO4RECNO"
		cQuery += " FROM " + RetSQLName("VO2") + " VO2"
		cQuery += 		 " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
		cQuery += 										   " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM "
		cQuery += 										   " AND VO4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
		cQuery +=   " AND VO2.VO2_NUMOSV = '" + aAltOSV[nCont,01] + "'"
		cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
		cQuery +=   " AND VO4.VO4_TIPTEM = '" + aAltOSV[nCont,02] + "'"
		cQuery +=   " AND VO4.VO4_LIBVOO = '" + aAltOSV[nCont,03] + "'"
		cQuery += " ORDER BY VO2.VO2_NOSNUM, VO4.VO4_GRUSER, VO4.VO4_CODSER"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cAliasVO4, .F., .T. )
		While !(cAliasVO4)->(Eof())

			dbSelectArea("VO4")
			dbGoTo((cAliasVO4)->VO4RECNO)

			RecLock("VO4",.f.)

			If !Empty(VO4->VO4_DATFEC) .or. lIntegLoja

				VO4->VO4_DATFEC := Ctod(" ")
				VO4->VO4_HORFEC := 0
				VO4->VO4_FUNFEC := ""
				VO4->VO4_NUMNFI := ""
				VO4->VO4_SERNFI := ""
				if FieldPos('VO4_SDOC') > 0
					VO4->VO4_SDOC := ""
				EndIf

				// Atualiza Ocorrencia do veiculo
				OM140VFB( "S" , VV1->VV1_PROATU , VV1->VV1_LJPATU , VV1->VV1_CHAINT , VO4->VO4_TIPTEM , VO4->VO4_NUMOSV , VO4->VO4_GRUSER , VO4->VO4_CODSER)
				//


			ElseIf !Empty(VO4->VO4_DATDIS)

				VO4->VO4_DATDIS := Ctod(" ")
				VO4->VO4_HORDIS := 0
				VO4->VO4_LIBVOO := ""
				If lVO4_FUNDIS // Tec. Lib. TT
					VO4->VO4_FUNDIS := ""
				EndIf

			Else

				VO4->VO4_DATCAN := dDataBase
				VO4->VO4_HORCAN := nHora

			EndIf

			If lVO4VSCIDE .and. Empty(VO4->VO4_DATFEC)
				VO4->VO4_VSCIDE := ""
				VO4->VO4_PEDNUM := ""
				VO4->VO4_PEDITE := ""
				VO4->VO4_ITENFI := ""
			EndIf


			MsUnLock()

			(cAliasVO4)->(dbSkip())

		EndDo
		(cAliasVO4)->(dbCloseArea())
		dbSelectArea("VO4")
		dbGoTop() // Desposiciona para funcionar SELECT
		//

	Next nCont

EndIf

//------------------//
// Atualiza as OS's //
//------------------//
For nCont := 1 to Len(aAltOSV)

	VO1->(dbSetOrder(1))
	VO1->(dbSeek( xFilial("VO1") + aAltOSV[nCont,01] ))

	// tratamento de controle de status de veiculo em estoque
	VV1->(dbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1")+VO1->VO1_CHAINT))
	If FG_STATUS(,"X") .and. VV1->VV1_SITVEI $ "0 "
		FG_STATUS(VO1->VO1_CHAINT,"F")
	EndIf
	//

	// Atualiza OS
	dbSelectArea("VO1")
	Reclock("VO1",.F.)
	VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV," ")
	If Empty(VO1->VO1_STATUS) .and. lCancOS
		VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV,"C")
	EndIf
	VO1->VO1_TEMLIB := IIf( FMX_TEMLIB( VO1->VO1_NUMOSV ) , "S" , "N" )
	VO1->VO1_TEMFEC := Iif( FS_TEMFEC ( VO1->VO1_NUMOSV ) , "S" , "N" )
	If VO1->VO1_STATUS <> "C"
		VO1->VO1_DATSAI := ctod("")
		VO1->VO1_HORSAI := 0
	Else
		If Empty(VO1->VO1_DATSAI)
			VO1->VO1_DATSAI := dDataBase
			VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
		EndIf
	EndIf
	MsUnLock()
	//

	// Marca box da Oficina
	FG_MARCABOX( VO1->VO1_NUMBOX ,,,, (VO1->VO1_STATUS $ "C/D") )
	//

	If VO1->VO1_STATUS == "C"

		// Verifica se ficou alguma reserva que nao foi estornada anteriormente
		If !OM150ESTRE( VO1->VO1_NUMOSV )
			DisarmTransaction()
			MsUnlockAll()
			MostraErro()
			Return .f.
		EndIf
		//

		// Apaga todos os VSJ's que nao foram requisitados ...
		dbSelectArea("VSJ")
		dbSetOrder(1)
		dbSeek(xFilial("VSJ")+VO1->VO1_NUMOSV)
		While !VSJ->(eof()) .and. xFilial("VSJ") == VSJ->VSJ_FILIAL .and. VSJ->VSJ_NUMOSV == VO1->VO1_NUMOSV
			//
			If lConfOfi .and. lVSJCODIGO .and. !Empty(VSJ->VSJ_CODIGO) // Trabalha com Conferencia de Itens na Oficina
				//
				cQuery := "SELECT R_E_C_N_O_ AS RECVM4 , VM4_FILIAL , VM4_CODVM3 "
				cQuery += "  FROM " + RetSQLName("VM4")
				cQuery += " WHERE VM4_FILIAL = '" + xFilial("VM4") + "' " 
				cQuery += "   AND VM4_CODVSJ = '" + VSJ->VSJ_CODIGO + "' "
				cQuery += "   AND D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlConf, .F., .T. )
				While !( cQAlConf )->( Eof() )
					//
					dbSelectArea("VM4")
					DbGoto(( cQAlConf )->( RECVM4 ))
					RecLock("VM4",.f.,.t.)
					VM4->(dbDelete())
					VM4->(MsUnLock())
					//
					DbSelectArea("VM3")
					DbSetOrder(1)
					If DbSeek( ( cQAlConf )->( VM4_FILIAL ) + ( cQAlConf )->( VM4_CODVM3 ) ) .and. VM3->VM3_STATUS $ "1/2/3" // Apagar somente se a Conferencia estiver Em Aberto
						RecLock("VM3",.f.,.t.)
						VM3->(dbDelete())
						VM3->(MsUnLock())
					EndIf
					//
					( cQAlConf )->( DbSkip() )
				EndDo
				( cQAlConf )->( dbCloseArea() )
				//
			EndIf
			//
			dbSelectArea("VSJ")
			RecLock("VSJ",.f.,.t.)
			If lVSJCODIGO .and. !Empty(VSJ->VSJ_CODIGO)
				VSJ->VSJ_QTDITE := 0
			Else
				VSJ->(dbDelete())
			EndIf
			VSJ->(MsUnLock())
			//
			dbSkip()
		EndDo
		//

		If VO1->(FieldPos("VO1_GARMUT")) <> 0
			If !OA550CANPED( "" , VO1->VO1_NUMOSV )
				DisarmTransaction()
				MsUnlockAll()
				Return .f.
			EndIf
		EndIf

	EndIf

Next nCont

If ExistBlock("VA150DPGR")
	If !ExecBlock("VA150DPGR",.f.,.f.,{})
		lMsErroAuto := .t.
	EndIf
EndIf

//Projeto WHI SC
If GetNewPar("MV_MIL0006","") == "SCA" .AND. FindFunction("OFINSC01")
	If lCancOS
		OFSC01(.f.,.t.,VO1->VO1_NUMOSV,"","")//lEnd, lAuto, cTipTem, cLibVOO
	ElseIf Len( aAltOSV ) > 0
		For nCont := 1 To Len(aAltOSV)
			OFSC01(.f.,.t.,aAltOSV[nCont,01],aAltOSV[nCont,02],aAltOSV[nCont,03])//lEnd, lAuto, cTipTem, cLibVOO
		Next
	Endif
EndIf

If !lOM150Auto
	///////////////////////////////////
	// Gravar Motivo de Cancelamento //
	///////////////////////////////////
	If Len(aMotCancel) > 0
		OFA210VDT("000002",aMotCancel[1],"2",VO1->VO1_FILIAL,VO1->VO1_NUMOSV,aMotCancel[4])
	EndIf
EndIf

End Transaction
lMsHelpAuto := .f.

If !lRet
	MostraErro()
Else

	If lOM350STATUS
		if VS1->(FieldPos("VS1_NUMAGE")) # 0
			cQuery := "SELECT VS1.VS1_NUMAGE FROM "+RetSqlName("VS1")+" VS1 WHERE "
			cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VS1.VS1_NUMAGE<>' ' AND VS1.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVS1, .F., .T. )
			While !( cQAlVS1 )->( Eof() )
				If VO1->VO1_STATUS <> "C"
					OM350STATUS(( cQAlVS1 )->( VS1_NUMAGE ),"1","2") // Volta Agendamento para OS Aberta
				Else
					OM350STATUS(( cQAlVS1 )->( VS1_NUMAGE ),"1","4") // Cancela Agendamento Oficina
				EndIf
				( cQAlVS1 )->( DbSkip() )
			EndDo
			( cQAlVS1 )->( dbCloseArea() )
			DbSelectArea("VO1")
		Endif
	EndIf
	If !lOM150Auto
		if Len(aMotCancel) > 0
			lMotCan := aMotCancel[3]
		Else
			lMotCan := .f.
		Endif
	Else
		lMotCan := .t.
	EndIf
	If lMotCan .and. !Empty( cCEVNFI )
		If lVCM510CEV
			aCEV := VCM510CEV("7","",cCEVTTP,IIf(nCEVQTD>1,"",cCEVOSV)) // 7 = Cancelamento Servicos
		Else // Temporario
			cGCCOCEV := Alltrim(GetNewPar("MV_GCCOCEV",""))
			If !Empty(cGCCOCEV)
				aCEV := {{substr(cGCCOCEV,1,1),val(substr(cGCCOCEV,2,3)),substr(cGCCOCEV,5,6),val(substr(cGCCOCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If !Empty(VS0->VS0_USURES)
				aCEV[ni,3] := VS0->VS0_USURES // Vendedor Responsavel
			EndIf
			// CEV - Agenda Contato quando Cancela Oficina - Satisfacao do Cliente - Andre Luis Almeida - 04/03/2008 //
			FS_AGENDA( aCEV[ni,1] ,;
			( dDataBase+aCEV[ni,2] ) ,;
			aCEV[ni,3] ,;
			cCEVCLI ,;
			cCEVLOJ ,;
			"" ,;
			IIf(nCEVQTD>1,"",cCEVOSV) ,;
			"" ,;
			STR0051+IIf(nCEVQTD>1,STR0052,cCEVOSV)+" "+IIf(cCEVTTP#"1",IIf(cCEVTTP=="2",STR0053,STR0054),"")+STR0055+cCEVNFI ,;
			"" ,;
			"" )   //OS 3 Agrupada # Garantia # Revisao #  CANCELADA - NF:
		Next
	EndIf

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM150OSREL บAutor  ณ Rubens Takahashi บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra OS relacionadas na Nota Fiscal                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM150OSREL( cNumNFI , cSerieNFI , cNumOsv , cTipTem , cLibVOO , aOsRelac)

Local cSQL
Local cAuxAlias 	:= GetNextAlias()
Local lRetOsRelac 	:= .t.

Local aSizeAut := MsAdvSize(.t.)
Local aObjects
Local aInfo
Local lVAI_TIPCAN := VAI->(FieldPos("VAI_TIPCAN")) <> 0
Local aPosObj

// Variaveis da Enchoice
Local nModelo   := 3
Local lF3       := .f.
Local lMemoria  := .t.
Local cATela    := ""
Local lProperty := .f.
//

aOsRelac := {}

If Empty( cNumNFI )
	Return .t.
EndIf

cSQL := "SELECT VOO_NUMOSV , VOO_TIPTEM , VOO_FATPAR , VOO_LOJA , VOO_TOTPEC , VOO_TOTSRV , VOO_LIBVOO "
cSQL +=     " , VV1_CHASSI , VV1_CODMAR , VV1_MODVEI"
cSQL +=     " , A1_NREDUZ"
cSQL += " FROM " + RetSQLName("VOO") + " VOO JOIN " + RetSQLName("VO1") + " VO1 ON VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = VOO_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
cSQL +=                                    " JOIN " + RetSQLName("VV1") + " VV1 ON VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_ = ' '"
cSQL +=                                    " JOIN " + RetSQLName("SA1") + " SA1 ON  A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = VOO_FATPAR AND A1_LOJA = VOO_LOJA AND SA1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VOO_FILIAL = '" + xFilial("VOO") + "'"
cSQL +=   " AND VOO_NUMNFI = '" + cNumNFI + "'"
cSQL +=   " AND VOO_SERNFI LIKE '" + cSerieNFI + "%'"
cSQL +=   " AND ( VOO_NUMOSV <> '" + cNumOsv + "'"
cSQL +=   "    OR VOO_LIBVOO <> '" + cLibVOO + "'"
cSQL +=   " )"
cSQL +=   " AND VOO.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
nVPec := 0
nVSrv := 0
While !(cAuxAlias)->(Eof())

	aAdd( aOsRelac , { (cAuxAlias)->VOO_NUMOSV ,;
	                   (cAuxAlias)->VV1_CHASSI ,;
	                   (cAuxAlias)->VV1_CODMAR ,;
	                   (cAuxAlias)->VV1_MODVEI ,;
	                   (cAuxAlias)->VOO_FATPAR ,;
	                   (cAuxAlias)->VOO_LOJA ,;
	                   (cAuxAlias)->A1_NREDUZ ,;
	                   (cAuxAlias)->VOO_TIPTEM ,;
	                   (cAuxAlias)->VOO_LIBVOO } )

	nVPec += (cAuxAlias)->VOO_TOTPEC
	nVSrv += (cAuxAlias)->VOO_TOTSRV

	(cAuxAlias)->(dbSkip())


EndDo
(cAuxAlias)->(dbCloseArea())

nPosTT := Ascan( aTempos , {|x| x[1] == .t. } )
nVPec += aTempos[nPosTT,8]
nVSrv += aTempos[nPosTT,11]

if lVAI_TIPCAN
	if !OM150VCAN(VAI->VAI_TIPCAN,nVPec,nVSrv,"A")
		Return(.f.)
	Endif
Endif

dbSelectArea("VOO")

If Len(aOsRelac) # 0

	// Redimensiona Dialog Principal
	aSizeAut[5] := Round(aSizeAut[5] * 0.9,0)
	aSizeAut[6] := Round(aSizeAut[6] * 0.8,0)
	//

	DEFINE MSDIALOG oDlgOsRelac FROM aSizeAut[7],000 TO aSizeAut[6] , aSizeAut[5] TITLE STR0038 + cNumNFI + " - " + FGX_UFSNF(cSerieNFI) OF oMainWnd PIXEL //Ordem de servico relacionadas na mesma Nota Fiscal -

	// Calcula tamanho da Dialog para trabalhar com os controles
	aSizeAut[3] := Int(oDlgOsRelac:nClientWidth / 2)
	If SetMDIChild()
		aSizeAut[4] := Int(oDlgOsRelac:nClientHeight / 2) - 16
	Else
		aSizeAut[4] := Int(oDlgOsRelac:nClientHeight / 2) - 4
	EndIf
	//

	aObjects := {}
	AAdd( aObjects, { 00, 050, .T., .F. } ) // Enchoice VO1
	AAdd( aObjects, { 00, 013, .T., .T. } ) // Listbox ...
	aInfo := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)

	oEnchVO1Rel := MSMGet():New("VO1",1, 2 /* Visualizar */ ,;
										/* aCRA */, /* cLetra*/, /* cTexto */, {"VO1_NUMOSV","VO1_CHASSI","VO1_DESMAR","VO1_DESMOD","VO1_PROVEI","VO1_LOJPRO","VO1_NOMPRO"},;
										aPosObj[1] , ;
										{"VO1_NUMOSV","VO1_CHASSI","VO1_DESMAR","VO1_DESMOD","VO1_PROVEI","VO1_LOJPRO","VO1_NOMPRO"}, nModelo,;
										/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlgOsRelac , lF3, lMemoria, .F. /* lColumn */ ,;
										caTela, .t. /* lNoFolder */, lProperty)


	@ aPosObj[2,1] , aPosObj[2,2] TO aPosObj[2,3] , aPosObj[2,4] LABEL STR0045 OF oDlgOsRelac PIXEL  //Ordem de Servico Relacionadas

	oLbOsRelacionadas := TWBrowse():New( aPosObj[2,1]+8 , aPosObj[2,2]+2 , (aPosObj[2,4]-aPosObj[2,2]-4) , (aPosObj[2,3]-aPosObj[2,1]-10) ,,,,oDlgOsRelac,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbOsRelacionadas:nAT := 1
	oLbOsRelacionadas:SetArray(aOsRelac)
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0040, { || aOsRelac[oLbOsRelacionadas:nAt,1] },,,,"LEFT",30,.F.,.F.,,,,.F.,) ) // OS
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0007, { || aOsRelac[oLbOsRelacionadas:nAt,8] },,,,"LEFT",20,.F.,.F.,,,,.F.,) ) // TT
	oLbOsRelacionadas:AddColumn( TCColumn():New( RetTitle("VOO_LIBVOO"), { || aOsRelac[oLbOsRelacionadas:nAt,9] },,,,"LEFT",40,.F.,.F.,,,,.F.,) ) // Liberacao TT
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0041, { || aOsRelac[oLbOsRelacionadas:nAt,2] },,,,"LEFT",70,.F.,.F.,,,,.F.,) ) // Chassi
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0042, { || aOsRelac[oLbOsRelacionadas:nAt,3] },,,,"LEFT",20,.F.,.F.,,,,.F.,) ) // Marca
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0043, { || aOsRelac[oLbOsRelacionadas:nAt,4] },,,,"LEFT",40,.F.,.F.,,,,.F.,) ) // Modelo
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0044, { || aOsRelac[oLbOsRelacionadas:nAt,5] },,,,"LEFT",22,.F.,.F.,,,,.F.,) ) // Cliente
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0011, { || aOsRelac[oLbOsRelacionadas:nAt,6] },,,,"LEFT",15,.F.,.F.,,,,.F.,) ) // Loja
	oLbOsRelacionadas:AddColumn( TCColumn():New( STR0012, { || aOsRelac[oLbOsRelacionadas:nAt,7] },,,,"LEFT",60,.F.,.F.,,,,.F.,) ) // Nome
	oLbOsRelacionadas:Refresh()

	lRetOsRelac := .f.
	ACTIVATE MSDIALOG oDlgOsRelac CENTER ON INIT EnchoiceBar(oDlgOsRelac,{ || lRetOsRelac := .t. , oDlgOsRelac:End() } , {|| oDlgOsRelac:End() })
EndIf

Return( lRetOsRelac )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DELNFI บAutor  ณFabio               บ Data ณ  07/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta Nota Fiscal                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DELNFI(cNumNfi,cSerie,cFatPar,cLoja,lNFeCancel)

Local aRegSD2 := {}
Local aRegSE1 := {}
Local aRegSE2 := {}
Local lAgendado := .f.
Local cAuxData := Dtoc(dDataBase)

Private aMata520Cab := {} , aMata410Cab := {} , aMata410Itens := {}

conout("OFIOM150 - FS_DELFNI - INICIO PROCESSAMENTO: " + cAuxData + " - " + Time())

If lNFeCancel .and. FGX_STATF2("D",cSerie,cNumNfi,cFatPar,cLoja,"S") // verifica se NF foi Deletada
	Return .t.
EndIf

If lNFeCancel
	lRetStatus := FGX_STATF2("J",cSerie,cNumNfi,cFatPar,cLoja,"S",@lAgendado) // verifica se NF esta na fila para transmissao
	If !lRetStatus .and. lAgendado
		Return .f.
	EndIf
EndIf

dbSelectArea("SF2")
dbSetOrder(1)
If DbSeek(xFilial("SF2") + cNumNfi + cSerie )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o estorno do documento de saํda pode ser feito     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	conout("OFIOM150 - FS_DELFNI - CHAMADA DA MACANDELF2:  "+ cAuxData +" - "+Time())
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		conout("OFIOM150 - FS_DELFNI - RETORNO POSITIVO DA MACANDELF2:  "+ cAuxData +" - "+Time())
		/*Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2, Array com os registro do SE1, Array com os registro do SE2 ) */
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Estorna o documento de saida                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PERGUNTE("MTA521",.f.)
		If lNFeCancel
			conout("OFIOM150 - FS_DELFNI - CHAMADA DA MADELNFS:  "+ cAuxData +" - "+Time())
			If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
				//lMsErroAuto:= .T.
				Return(.f.)
			Else
				conout("OFIOM150 - FS_DELFNI - RETORNO POSITIVO DA MADELNFS:  "+ cAuxData +" - "+Time())
			Endif
		Else
			SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
		EndIf

		conout("OFIOM150 - FS_DELFNI - CHAMADA FGX_STATF2:  "+ cAuxData +" - "+Time())
		If lNFeCancel .and. !FGX_STATF2("V",cSerie,cNumNfi,cFatPar,cLoja,"S") /// Verifica STATUS da NF no SEFAZ
			//lMsErroAuto:= .T.
			Return .f.
		EndIf
	Else
		conout("OFIOM150 - FS_DELFNI - RETORNO NEGATIVO DA MACANDELF2:  "+ cAuxData +" - "+Time())
		//Nao pode ser excluida.
		lMsErroauto:= .T.
		Return(.f.)
	EndIf

EndIf

conout("OFIOM150 - FS_DELFNI - FIM DO PROCESSAMENTO:  "+ cAuxData +" - "+Time())

Return(.t.)

/*/{Protheus.doc} FS_DELPED
Deleta pedido de venda (SC5)
@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}
@param cNumPedido, characters, descricao
@type function
/*/
Static Function FS_DELPED(cNumPedido)

// Estorna liberacao de Pedido (SC5)
SC9->(DbSetOrder(1))
SC9->(DbSeek(xFilial("SC9")+cNumPedido))
While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPedido == SC9->C9_PEDIDO
	SC9->(a460Estorna())
	SC9->(dbSkip())
EndDo
//

// Exclui Pedido
aMata410Cab   := {{"C5_NUM"    , cNumPedido     ,Nil}} //numero do pedido
aMata410Itens := {{"C5_NUM"    , cNumPedido     ,Nil}} //numero do pedido
lMSHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x,y,z| MATA410(x,y,z)},aMata410Cab,{aMata410Itens},5)
If lMsErroAuto
	Return(.f.)
Endif

Return(.t.)
//

/*/{Protheus.doc} FS_LEVTIT
Levanta os titulos de contas a receber
@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}
@param cNumNfi, characters, descricao
@param cSerNfi, characters, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param lNFeCancel, logical, descricao
@type function
/*/
Static Function FS_LEVTIT( cNumNfi, cSerNfi, cCliente, cLoja, lNFeCancel)

	Local aRecTit := {}
	Local nTit := 0
	Local cAuxPrefOfi := GetNewPar("MV_PREFOFI","OFI")
	Local cPrefNF := ""
	Local cSQL

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(dbSeek( xFilial("SF2") + cNumNfi + cSerNfi ))
	If SF2->(Found())
		If SF2->F2_PREFORI <> cAuxPrefOfi
			Return {}
		EndIf
		cPrefNF := IIf(Empty(SF2->F2_PREFIXO),&(GetMv("MV_1DUPREF")),SF2->F2_PREFIXO)
	EndIf

	// Se a nota estiver deletada e esta configurado o cancelamento automatico
	// Procura a nota excluida ...
	If !SF2->(Found())
		If !lNFeCancel
			Return {}
		EndIf

		cSQL := ;
			"SELECT F2_PREFIXO " +;
			" FROM " + RetSQLName("SF2") + " SF2 " +;
			" WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' " +;
			  " AND SF2.F2_SERIE = '" + cSerNfi + "' " +;
			  " AND SF2.F2_DOC = '" + cNumNfi + "' " +;
			  " AND SF2.F2_CLIENTE = '" + cCliente + "' "+;
			  " AND SF2.F2_LOJA = '" + cLoja + "' " +;
			" ORDER BY R_E_C_N_O_ DESC"
		cPrefNF := FM_SQL(cSQL)

	EndIF

	If !Empty(cPrefNF)
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek( xFilial("SE1") + cPrefNF + cNumNfi )
		while !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == cNumNfi
			if SE1->E1_PREFORI == cAuxPrefOfi
				AADD( aRecTit , SE1->(Recno()) )
			endif
			dbSkip()
		Enddo
	EndIf

Return aClone(aRecTit)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CANTIT บAutor  ณFabio               บ Data ณ  10/25/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela Titulo                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CANTIT(aRecTit, lNFeCancel)

Local aTitulos := {}
Local nTit := 0

dbSelectArea("SE1")

// Levanta informacoes dos titulos para cancelamento
For nTit := 1 to len(aRecTit)
	SE1->(dbGoTo( aRecTit[nTit] ))

	// Quando o envio do cancelamento ao SEFAZ ้ automatico, o titulo ja pode ter sido excluido pela rotina de Cancelamento da Totvs
	If lNFeCancel .and. SE1->(Deleted())
		Loop
	EndIf

	aAdd(aTitulos,{ {"E1_PREFIXO",E1_PREFIXO,nil} , {"E1_NUM",E1_NUM          ,nil} , {"E1_PARCELA",E1_PARCELA,nil } ,;
		{"E1_TIPO"   ,E1_TIPO   ,nil} , {"E1_NATUREZA",E1_NATUREZA,nil} , {"E1_CLIENTE",E1_CLIENTE,nil } ,;
		{"E1_LOJA"   ,E1_LOJA   ,nil} , {"E1_EMISSAO",E1_EMISSAO  ,nil} , {"E1_VENCTO" ,E1_VENCTO ,nil } ,;
		{"E1_VENCREA",E1_VENCREA,nil} , {"E1_VALOR",E1_VALOR      ,nil}  })

	If AllTrim(SE1->E1_ORIGEM) == "MATA460"
		RecLock("SE1",.f.)
		SE1->E1_ORIGEM := "FINA040"
		MsUnLock()
	EndIf
Next nTit
//

// cancela os titulos
For nTit := 1 to len(aTitulos)
	Pergunte("FIN040",.F.)
	MSExecAuto({|x,y| FINA040(x,y)},aTitulos[nTit],5)
	If lMsErroAuto
		Exit
	Endif
Next
//

Return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CANCDCIบAutor  ณFabio               บ Data ณ  10/25/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela CDCI                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CANCDCI( cNumCDCI )

// Exclui titulo do CDCI
ExTitCDCI( cNumCDCI )

If lMsErroAuto

	Return(.f.)

EndIf

// Exclui Contrato de CDCI
ExContCDCI( cNumCDCI )

If lMsErroAuto

	Return(.f.)

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CANGAR บAutor  ณFabio               บ Data ณ  11/13/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CANGAR(cTipTem,cLibVOO, cStatTT)

Local cFunExp := ""
Local cFuncao
Local lRet := .t.
Local lRetPE := .t.
Local ix1  := 0

If ExistBlock("OM150IGA")
	lRetPE := ExecBlock("OM150IGA",.F.,.F.,{cTipTem})
EndIf

VOI->(dbSetOrder(1))
VOI->(MsSeek(xFilial("VOI") + cTipTem))

cNumNota := VOO->VOO_NUMNFI
cSerNfi  := VOO->VOO_SERNFI

If !VOI->VOI_SITTPO $ "2.4" .and. lRetPE
	// Para os casos em que nใo se trata de tipo de tempo de garantia
	// A marca pode exigir a transmissใo de um registro de solicita็ใo de garantia dependo da forma que foi aberta a OS.
	// EX: A John Deere nใo estแ reembolsando algumas revis๕es da linha 5000 mas ้ necessแrio a transmissใo do registro 
	//     de solicita็ใo de garantia para ficar registrado no sistema da fแbrica que a Revisใo foi feita pelo cliente.
	//     Nesses casos, o sistema foi alterado para se comportar como uma Garantia mas com tipo de tempo interno ou cliente.
	If AllTrim(GetNewPar("MV_MIL0006","")) <> "JD"
		Return lRet
	EndIF
EndIf

// Posiciona no Arquivo de Veiculos
FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
If cMVMIL0006 == "JD"
	cCodMarVV1 := FMX_RETMAR("JD ") + "/" + FMX_RETMAR("GRS") + "/" + FMX_RETMAR("PLA") + "/" + FMX_RETMAR("JDC") + "/" + FMX_RETMAR("HCM")
Else
	cCodMarVV1 := VV1->VV1_CODMAR
EndIf

cFuncao := FMX_FEXPGA("",cTipTem,cCodMarVV1)
If !Empty(cFuncao)
	For ix1 := 1 to len(cFuncao)
		If SubStr(cFuncao,ix1,1) == "("
			cFunExp += "('C','"+cTipTem+"','" + cLibVOO +"','" + cStatTT + "')"
			Exit
		EndIf
		cFunExp += SubStr(cFuncao,ix1,1)
	Next
	lRet := &cFunExp                           // Funcao de Cancelamento da Importacao da Garantia
EndIf

Return lRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOM150LEG   ณ Autor ณ Ricardo Farinelli    ณ Data ณ 11/12/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณofiom150                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM150LEG()

Local aLegenda  := {;
	{ 'BR_VERDE'   , STR0057 } ,;	// Aberta
	{ 'BR_AZUL'    , STR0058 } ,;	// Liberada
	{ 'BR_VERMELHO', STR0059 } ,;	// Fechado
	{ 'BR_PRETO'   , STR0060 } }	// Cancelado

BrwLegenda(cCadastro,STR0061 ,aLegenda)   //Legenda

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALCAN บAutor  ณFabio               บ Data ณ  06/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Cancelamento                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALCAN()

Local nLinRef := 0 , nPosIni := 0 , nTamIni := 0
Local lVAI_VALCAN := VAI->(FieldPos("VAI_VALCAN")) <> 0
Local lVAI_TIPCAN := VAI->(FieldPos("VAI_TIPCAN")) <> 0

If ( nLinRef := Ascan( aTempos , {|x| x[1] == .t. } ) ) # 0

	lFlag   := aTempos[nLinRef,01]
	cTipTem := aTempos[nLinRef,02]
	cNumOsv := aTempos[nLinRef,03]
	cSerNfi := aTempos[nLinRef,04]
	cFatPar := aTempos[nLinRef,05]
	cLoja   := aTempos[nLinRef,06]
	cNReduz := aTempos[nLinRef,07]
	nTotPec := aTempos[nLinRef,08]
	nHorPad := aTempos[nLinRef,09]
	nHorApl := aTempos[nLinRef,10]
	nTotSer := aTempos[nLinRef,11]
	nKm     := aTempos[nLinRef,12]
	cStatus := aTempos[nLinRef,13]

	If lVAI_VALCAN
		VAI->(DbSetOrder(4))
		VAI->(DbSeek(xFilial("VAI") + __cUserID))
		If !(aTempos[nLinRef,13] $ VAI->VAI_VALCAN)
			Return(.f.)
		Endif
		if lVAI_TIPCAN
			if !OM150VCAN(VAI->VAI_TIPCAN,nTotPec,nTotSer,"I")
				Return(.f.)
			EndIf
		Endif
	ElseIf ( nPosIni := At( aTempos[nLinRef,13]+"=" , GetMv("MV_VALCAN") )  ) # 0

		nPosIni += 2
		nTamIni := At( ";" , Substr( GetMv("MV_VALCAN") , nPosIni ) ) - 1

		If nTamIni <= 0
			nTamIni := Len( Alltrim( Substr( GetMv("MV_VALCAN") , nPosIni ) ) ) + 1
		EndIf

		If !&( Substr( GetMv("MV_VALCAN") , nPosIni , nTamIni ) )

			Return(.f.)

		EndIf

	EndIf

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgramaณ MenuDef	บAutor  ณAndre Luis Almeida  บ Data ณ  27/08/08   บฑฑ
ฑฑฬออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Menu														  บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Oficina                                                      บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0001 , "AxPesqui"	, 0 , 1 } ,;   		// Pesquisar
{ STR0002 , "OM150"		, 0 , 2	} ,;   		// Excluir
{ STR0061 , "OM150LEG"	, 0 , 2, 0, .f.},; 	// Legenda
{ STR0067 , "OM150V"	, 0 , 1	}}			// Pesq. Avancada

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณOM150CANC บ Autor ณ Andre Luis Almeida บ Data ณ  11/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Cancela OS, atraves do Nro do Orcamento no Loja            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ Loja -> Oficina                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM150CANC(cOrcLoja)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local cQuery  := ""
Local cAlCANC := "SQL_CANCEL"
Local nRecVOO := 0
Local nRecVO1 := 0

Local aArea := GetArea()

Private cMotivoEsc := ""
Private aTempos  := {}

Default cOrcLoja := ""
If !Empty(cOrcLoja)
	cQuery := "SELECT VOO.R_E_C_N_O_ AS VOOREC , VO1.R_E_C_N_O_ AS VO1REC "
	cQuery +=  " FROM "+RetSQLName("VOO")+" VOO JOIN "+RetSQLName("VO1")+" VO1 "
	cQuery +=         " ON VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VOO.VOO_NUMOSV AND VO1.D_E_L_E_T_=' '"
	cQuery += " WHERE VOO.VOO_FILIAL='"+xFilial("VOO")+"' "
	cQuery +=   " AND VOO.VOO_PESQLJ='"+cOrcLoja+"'"
	cQuery +=   " AND VOO.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlCANC , .F., .T. )
	If !( cAlCANC )->( Eof() )
		nRecVOO := ( cAlCANC )->( VOOREC )
		nRecVO1 := ( cAlCANC )->( VO1REC )
	EndIf
	( cAlCANC )->( DbCloseArea() )
	If nRecVOO > 0 .and. nRecVO1 > 0

		DbSelectArea("VOO")
		DbSetOrder(1)
		DbGoTo( nRecVOO )

		DbSelectArea("VO1")
		DbSetOrder(1)
		DbGoTo( nRecVO1 )
		For nCntFor := 1 TO FCount()
			&( "M->"+EVAL(bCampo,nCntFor) ) := FieldGet(nCntFor)
		Next

		// Se o Registro do VOO possuir numero de nota fiscal, ้ problema de chamada da DEVLOJA
		// Quando integrado com o venda direta e gerada nota fiscal, no cancelamento da nota fiscal, o LOJA701 nใo esta executando o DEVLOJA
		// Serแ necessแrio executar a funcao FMX para cancelar as informa็๕es de fechamento ...
		If !Empty(VOO->VOO_NUMNFI)
			FMX_LJCAN( cOrcLoja )
		EndIf

		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek( xFilial("VOI") + VOO->VOO_TIPTEM )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + VOO->VOO_FATPAR + VOO->VOO_LOJA )

		aAdd(aTempos, { .t. , ;	// 01 - Indicador de Selecao
		                VOO->VOO_TIPTEM , ; // 02 - Tipo de Tempo
		                VOO->VOO_NUMNFI , ; // 03 - Numero da Nota Fiscal
		                VOO->VOO_SERNFI , ; // 04 - Serie da Nota Fiscal
		                VOO->VOO_FATPAR , ; // 05 - Cliente - Faturar Para
		                VOO->VOO_LOJA , ; // 06 - Loja - Faturar Para
		                SA1->A1_NREDUZ , ; // 07 - Nome do Cliente - Faturar Para
		                VOO->VOO_TOTPEC , ; // 08 - Total de Pecas
		                VOO->VOO_HRSPAD , ; // 09 - Total de Horas Padrao
		                VOO->VOO_HRSAPL , ; // 10 - Total de Horas Aplicadas
		                VOO->VOO_TOTSRV , ; // 11 - Total de Servicos
		                VOI->VOI_TPOKLM , ; // 12 - Tp de Tempo de Kilometro ?
		                "F" , ; // 13 - Status do Tipo de Tempo
		                VOO->VOO_PESQLJ , ; // 14 - Numero do Orcamento (SIGALOJA)
		                VOO->VOO_LIBVOO } ) // 15 - Numero da Liberacao do TT

		If !FS_GRACANCEL(.f.,cOrcLoja) // Cancelar a OS / Tipo de Tempo ( .f. = NAO VALIDAR )
			Return(.f.)
		EndIf

		DbSelectArea("VOO")
		DbGoTo( nRecVOO )
		RecLock("VOO",.f.)
		VOO->VOO_PESQLJ := ""
		MsUnLock()
	EndIf

EndIf
RestArea( aArea )
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM150LVOS บAutor  ณ Rubens Takahashi   บ Data ณ  18/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz levantamento da Ordem de Servico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM150LVOS( aPeca, aSrv , lAtuLBox , cTipTem , cLibVOO )

Local cAuxCod  := ""
Local cAuxNome := ""
Local aCalPec
Local aCalSer
Local nCont
Local lExistVOO

Default lAtuLBox := .t.
Default cTipTem  := ""
Default cLibVOO  := ""

If VO1->VO1_STATUS =="C"
	//	Help(" ",1,"DOCINVALID")
	Return .F.
Endif

// Se for passado o cTipTem, deve atualizar somente este Tipo de Tempo ...
// Entao os itens deste tipo de tempo, devem ser excluidos da matriz ...
If !Empty(cTipTem)

	// Zera totalizadores do tipo de tempo
	nPos := aScan(aTempos,{ |x| x[02] == cTipTem .and. x[15] == cLibVOO })
	If nPos <> 0
		aDel( aTempos , nPos )
		aSize( aTempos, Len(aTempos) - 1 )
	EndIf
	//

	nCont := 1
	While nCont <= Len(aPeca)
		If aPeca[nCont,01] == cTipTem .and. aPeca[nCont,12] == cLibVOO
			aDel( aPeca , nCont )
			aSize( aPeca , Len(aPeca) - 1 )
			Loop
		EndIf
		nCont++
	EndDo

	nCont := 1
	While nCont <= Len(aSrv)
		If aSrv[nCont,01] == cTipTem .and. aSrv[nCont,10] == cLibVOO
			aDel( aSrv , nCont )
			aSize( aSrv , Len(aSrv) - 1 )
			Loop
		EndIf
		nCont++
	EndDo
Else
	aTempos  := {}
	aPeca := {}
	aSrv := {}
EndIf
//

VOO->(dbSetOrder(1))
VOI->(dbSetOrder(1))
SA1->(dbSetOrder(1))

// Processa requisicao de pecas ...
aCalPec := FMX_CALPEC(VO1->VO1_NUMOSV , ;
                      IIf( !Empty(cTipTem) , cTipTem , NIL ) ,;
                      /* cGruIte */ ,;
                      /* cCodIte */ ,;
                      .t. /* lMov */ ,;
                      .f. /* lNegoc */ ,;
                      .f. /* lReqZerada */ ,;
                      .t. /* lRetAbe */ ,;
                      .t. /* lRetLib */ ,;
                      .t. /* lRetFec */ ,;
                      .t. /* lRetCan */ ,;
                      IIf( !Empty(cLibVOO) .or. Len(cLibVOO) <> 0, cLibVOO , NIL ) )
For nCont := 1 to Len(aCalPec)
	If lVO3_FUNDIS
		If cAuxCod <> aCalPec[ nCont , 47 ]
			cAuxCod  := aCalPec[ nCont , 47 ]
			cAuxNome := Left(POSICIONE("VAI", 1, xFilial("VAI") + aCalPec[ nCont , 47 ], "VAI_NOMTEC"), 15)
		EndIf
	EndIf

	lExistVOO := VOO->(MsSeek(xFilial("VOO") + VO1->VO1_NUMOSV + aCalPec[ nCont, 03 ] + aCalPec[ nCont , 25 ] ))

	VOI->(MsSeek(xFilial("VOI") + aCalPec[ nCont , 03 ] ))

	// Adiciona na matriz de Peca ...
	aAdd(aPeca, { aCalPec[ nCont , 03 ],; 													// 01 - VEC->VEC_TIPTEM
	              aCalPec[ nCont , 03 ],; 													// 02 - VEC->VEC_TIPTEM
	              IIf( lExistVOO , VOO->VOO_NUMNFI , Space(TamSX3("VOO_NUMNFI")[1]) ) ,; 	// 03 - Nota Fiscal
	              aCalPec[ nCont , 01 ],; 													// 04 - VEC->VEC_GRUITE
	              aCalPec[ nCont , 02 ],; 													// 05 - VEC->VEC_CODITE
	              aCalPec[ nCont , 13 ],; 													// 06 - SB1->B1_DESC
	              aCalPec[ nCont , 05 ],; 													// 07 - VEC->VEC_QTDITE
	              aCalPec[ nCont , 10 ] - aCalPec[ nCont , 07 ],; 					// 08 - VEC->VEC_VALVDA
	              "",; 																			// 09 - Status
	              aCalPec[ nCont , 15 ],; 													// 10 - VOO->VOO_FATPAR
	              aCalPec[ nCont , 16 ],; 													// 11 - VOO->VOO_LOJA
	              aCalPec[ nCont , 25 ],; 													// 12 - Numero da Liberacao do TT
	              IIf( lExistVOO , VOO->VOO_SERNFI , Space(TamSX3("VOO_SERNFI")[1]) ),;		// 13 - Serie da Nota Fiscal
	              aCalPec[ nCont , 14 ],;													// 14 - Movimentacoes da Peca (VO3)
				  cAuxCod,;																	// 15 - Codigo Tecnico da Liberacao do TT
	              cAuxNome } )																// 16 - Nome Tecnico da Libera็ใo do TT
	//

	nPos := aScan(aTempos,{|x| x[2] == aCalPec[nCont,03] .and. x[15] == aCalPec[nCont,25]})
	If nPos == 0

		SA1->(MsSeek( xFilial("SA1") + aCalPec[nCont,15] + aCalPec[nCont,16] ))

		aAdd(aTempos, { .f. ,;																		// 01 - Indicador de Selecao
		                aCalPec[ nCont , 03 ] ,;												// 02 - Tipo de Tempo
		                IIf( lExistVOO , VOO->VOO_NUMNFI , Space(TamSX3("VOO_NUMNFI")[1]) ),;	// 03 - Numero da Nota Fiscal
		                IIf( lExistVOO , VOO->VOO_SERNFI , Space(TamSX3("VOO_SERNFI")[1]) ),;	// 04 - Serie da Nota Fiscal
		                aCalPec[ nCont , 15 ],;												// 05 - Cliente - Faturar Para
		                aCalPec[ nCont , 16 ],;												// 06 - Loja - Faturar Para
		                SA1->A1_NREDUZ ,;														// 07 - Nome do Cliente - Faturar Para
		                0 ,;																			// 08 - Total de Pecas
		                0 ,;																			// 09 - Total de Horas Padrao
		                0 ,;																			// 10 - Total de Horas Aplicadas
		                0 ,;																			// 11 - Total de Servicos
		                VOI->VOI_TPOKLM ,;														// 12 - Tp de Tempo de Kilometro ?
		                "" ,;																		// 13 - Status do Tipo de Tempo
		                IIf( lExistVOO , VOO->VOO_PESQLJ , Space(TamSX3("VOO_PESQLJ")[1]) ),;	// 14 - Numero do Orcamento (SIGALOJA)
		                aCalPec[nCont,25]})														// 15 - Numero da Liberacao do TT
		nPos := Len(aTempos)

		Do Case
			Case !Empty(aCalPec[nCont,19])	// Data do Fechamento
				aTempos[ nPos , 13 ] := "F"	// Status = Fechada
			Case !Empty(aCalPec[nCont,17])	// Data de Liberacao
				aTempos[ nPos , 13 ] := "D"	// Status = Liberada
			Case !Empty(aCalPec[nCont,18])	// Data de Cancelamento
				aTempos[ nPos , 13 ] := "C"	// Status = Cancelada
			Otherwise
				aTempos[ nPos , 13 ] := "A"	// Status = Aberta
		EndCase

	EndIf

	// Calcula Total de Pecas ...
	aTempos[nPos,08] += aCalPec[ nCont , 10 ] - aCalPec[ nCont , 07 ]

	// Acerta o Status ...
	aPeca[ Len(aPeca) , 09 ] := aTempos[nPos,13]


Next nCont

If Len( aPeca ) == 0
	aAdd( aPeca, { "" , "" , "" , "" , "" , "" , 0 , 0 , "" , "" , "" , "" , "" , {} , "" , "" } )
EndIf
//

// Processa Requisicao de Servicos ...
aCalSer := FMX_CALSER(VO1->VO1_NUMOSV ,;
                      IIf( !Empty(cTipTem) , cTipTem , NIL ) ,;
                      /* cGruSer */ ,;
                      /* cCodSer */ ,;
                      .t.  /* lApont */ ,;
                      .t. /* lNegoc */ ,;
                      .t. /* lRetAbe */ ,;
                      .t. /* lRetLib */ ,;
                      .t. /* lRetFec */ ,;
                      .t. /* lRetCan*/ ,;
                      IIf( !Empty(cLibVOO) .or. Len(cLibVOO) <> 0, cLibVOO , NIL ) )
For nCont := 1 to Len(aCalSer)
	If lVO4_FUNDIS
		If cAuxCod <> aCalSer[ nCont , 54 ]
			cAuxCod  := aCalSer[ nCont , 54 ]
			cAuxNome := Left(POSICIONE("VAI", 1, xFilial("VAI") + aCalSer[ nCont , 54 ], "VAI_NOMTEC"), 15)
		EndIf
	EndIf

	lExistVOO := VOO->(MsSeek(xFilial("VOO") + VO1->VO1_NUMOSV + aCalSer[ nCont, 04 ] + aCalSer[ nCont , 38 ] ))

	VOI->(MsSeek(xFilial("VOI") + aCalSer[ nCont , 04 ] ))

	// Adiciona na matriz de Servicos ...
	aAdd(aSrv, { aCalSer[ nCont , 04 ] ,; 													// 01 - VSC->VSC_TIPTEM
	             aCalSer[ nCont , 04 ] ,; 													// 02 - ""
	             IIf( lExistVOO , VOO->VOO_NUMNFI , Space(TamSX3("VOO_NUMNFI")[1]) ) ,; 	// 03 - Nota Fiscal
	             aCalSer[ nCont , 05 ] ,; 													// 04 - VSC->VSC_TIPSER
	             aCalSer[ nCont , 02 ] ,; 													// 05 - VSC->VSC_CODSER
	             aCalSer[ nCont , 15 ] ,; 													// 06 - VO6->VO6_DESSER
	             aCalSer[ nCont , 09 ] ,; 													// 07 - VSC->VSC_VALSER
	             ""                    ,; 													// 08 -
	             aCalSer[ nCont , 01 ] ,; 													// 09 - Grupo de Servico
	             aCalSer[ nCont , 38 ] ,; 													// 10 - Numero da Liberacao do TT
	             IIf( lExistVOO , VOO->VOO_SERNFI , Space(TamSX3("VOO_SERNFI")[1]) ),;	 	// 11 - Serie da Nota Fiscal
	             aCalSer[ nCont , 14 ] ,;													// 12 - Movimentacoes do Servico (VO4)
	             cAuxCod ,;																	// 13 - Codigo Tecnico da Liberacao do TT
				 cAuxNome } )																// 14 - Nome Tecnico da Libera็ใo do TT
	//

	nPos := aScan(aTempos,{|x| x[2] == aCalSer[nCont,04] .and. x[15] == aCalSer[nCont,38] })
	If nPos == 0

		SA1->(MsSeek( xFilial("SA1") + aCalSer[nCont,20] + aCalSer[nCont,21] ))

		aAdd(aTempos, { .f. ,;																		// 01 - Indicador de Selecao
		                aCalSer [ nCont , 04 ] ,;												// 02 - Tipo de Tempo
		                IIf( lExistVOO , VOO->VOO_NUMNFI , Space(TamSX3("VOO_NUMNFI")[1]) ),;	// 03 - Numero da Nota Fiscal
		                IIf( lExistVOO , VOO->VOO_SERNFI , Space(TamSX3("VOO_SERNFI")[1]) ),;	// 04 - Serie da Nota Fiscal
		                aCalSer[ nCont , 20 ],;												// 05 - Cliente - Faturar Para
		                aCalSer[ nCont , 21 ],;												// 06 - Loja - Faturar Para
		                SA1->A1_NREDUZ ,;														// 07 - Nome do Cliente - Faturar Para
		                0 ,;																			// 08 - Total de Pecas
		                0 ,;																			// 09 - Total de Horas Padrao
		                0 ,;																			// 10 - Total de Horas Aplicadas
		                0 ,;																			// 11 - Total de Servicos
		                VOI->VOI_TPOKLM ,;														// 12 - Tp de Tempo de Kilometro ?
		                "" ,;																		// 13 - Status do Tipo de Tempo
		                IIf( lExistVOO , VOO->VOO_PESQLJ , Space(TamSX3("VOO_PESQLJ")[1]) ),;	// 14 - Numero do Orcamento (SIGALOJA)
		                aCalSer[nCont,38]})														// 15 - Numero da Liberacao do TT
		nPos := Len(aTempos)

		Do Case
			Case !Empty(aCalSer[nCont,24])	// Data do Fechamento
				aTempos[ nPos , 13 ] := "F"	// Status = Fechada
			Case !Empty(aCalSer[nCont,22])	// Data de Liberacao
				aTempos[ nPos , 13 ] := "D"	// Status = Liberado
			Case !Empty(aCalSer[nCont,23])	// Data de Cancelamento
				aTempos[ nPos , 13 ] := "C"	// Status = Cancelada
			Otherwise
				aTempos[ nPos , 13 ] := "A"	// Status = Aberta
		EndCase

	EndIf

	// Calcula Totais de Servicos ...
	aTempos[ nPos , 09 ] += aCalSer[ nCont , 10 ]
	aTempos[ nPos , 10 ] += aCalSer[ nCont , 11 ]
	aTempos[ nPos , 11 ] += aCalSer[ nCont , 09 ]
	//

	// Acerta o Status ...
	aSrv[ Len(aSrv) , 09 ] := aTempos[nPos,13]

Next nCont

If Len( aSrv ) == 0
	aAdd( aSrv, { "" ,  "" , "" , "" , "" , "" , 0 ,  "" , "" , "" , "" , {} , "" , "" } )
EndIf

If Len(aTempos) == 0
	aAdd(aTempos, { .f. , "" , "" , "" , "" , "" , "" , 0 , 0 , 0 , 0 , "" , "C" , "" , "" })
Else
	ASort(aTempos,,,{|x,y| x[2] + x[15] < y[2] + y[15] })
EndIf

If !lOM150Auto .and. lAtuLBox
	oLbTempos:nAT := 1
	oLbTempos:SetArray(aTempos)
	//oLbTempos:DrawSelect()
	oLbTempos:Refresh()
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FS_TEMFEC    บAutor  ณTakahashi       บ Data ณ  08/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se a OS possui TT fechado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da OS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_TEMFEC( cNumOsv )

Local lRetorno := .f.
Local cSQL
Local cAlias := "TOSLIB"
Local oArea := GetArea()

cSQL := "SELECT VO3.VO3_TIPTEM"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'P'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
cSQL +=   " AND VO3.VO3_DATDIS <> '" + Space(8) + "'"
cSQL +=   " AND VO3.VO3_DATFEC <> '" + Space(8) + "'"
cSQL +=   " AND VO3.VO3_DATCAN = '" + Space(8) + "'"
cSQL += " UNION "
cSQL += "SELECT VO4.VO4_TIPTEM"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'S'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
cSQL +=   " AND VO4.VO4_DATDIS <> '" + Space(8) + "'"
cSQL +=   " AND VO4.VO4_DATFEC <> '" + Space(8) + "'"
cSQL +=   " AND VO4.VO4_DATCAN = '" + Space(8) + "'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAlias , .F., .T. )

If !(cAlias)->(Eof())
	lRetorno := .t.
EndIf
(cAlias)->(dbCloseArea())

RestArea( oArea )

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OM150VLD     บAutor  ณTakahashi       บ Data ณ  15/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se pode continuar o cancelamento                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da OS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM150VLD( ni , lCancOS, aPeca , aSrv , aOSRelac )

Local nCont
Local nCont2
Local nContSel

Local aLockVOO	 := {}
Local aLockVO1	 := {}
Local aLockVO3	 := {}
Local aLockVO4	 := {}

Local aPecaOSRel := {}
Local aSrvOSRel  := {}
Local aAuxTempos := {} // Utilizado para validacao ...

Local lTemReqPeca := .f.
Local lTemReqSrvc := .f.

Local cMsg

Local aBkpTempo := aClone(aTempos)

If lCancOS
	aAuxTempos := aClone(aTempos)
Else
	aAuxTempos := aClone(aTempos[ni])
EndIf

VOO->(dbSetOrder(1))
aLockVO1 := {}
aLockVOO := {}
If !lCancOS .and. aTempos[ni,13] $ "D/F" .and. VOO->(dbSeek( xFilial("VOO") + VO1->VO1_NUMOSV + aTempos[ni,2] + aTempos[ni,15] ))
	AADD( aLockVOO , VO1->VO1_NUMOSV + aTempos[ni,2] + aTempos[ni,15] )
Else
	AADD( aLockVO1 , VO1->VO1_NUMOSV )
EndIf

// Adiciona na matriz de RECNO's os RECNO's das OS's relacionadas
For nCont := 1 to Len(aOSRelac)
	AADD( aLockVOO , aOSRelac[nCont,1] + aOSRelac[nCont,8] + aOSRelac[nCont,9] )
Next nCont
//

// Bloqueia os registro da VOO...
If ( Len(aLockVOO) <> 0 .and. !MultLock("VOO",aLockVOO,1) ) .and. ;
	( Len(aLockVO1) <> 0 .and. !MultLock("VO1",aLockVO1,1) )
	Return .f.
EndIf
//

// Recarrega o tipo de tempo selecionado, pois pode ter alterado de status por outro usuario/programa
// Verificacao para cancelamento da OS
If lCancOS
	If !OM150LVOS( @aPeca , @aSrv )
		Return .f.
	EndIf

	If Len(aTempos) <> Len(aAuxTempos)
		Alert(STR0070) // "Tipo de tempo foi alterado, favor selecionแ-lo novamente."
		Return .f.
	EndIf

	For nCont := 1 to Len(aTempos)
		If aTempos[nCont,03] <> aAuxTempos[nCont,03] .or. aTempos[nCont,13] <> aAuxTempos[nCont,13] .or. aTempos[nCont,14] <> aAuxTempos[nCont,14] .or. aTempos[nCont,15] <> aAuxTempos[nCont,15]
			Alert(STR0070) // "Tipo de tempo foi alterado, favor selecionแ-lo novamente."
			Return .f.
		EndIf
	Next nCont

	// Verificacao para cancelamento de um tipo de tempo selecionado
Else
	If !OM150LVOS( @aPeca , @aSrv , .t. , aTempos[ni,2] , aTempos[ni,15])
		Return .f.
	EndIf

	ni := aScan( aTempos , { |x| x[02] == aAuxTempos[02] .and. x[15] == aAuxTempos[15]} )
	If ni == 0
		Alert(STR0071) // "Tipo de tempo nใo encontrado na matriz aTempos."
		Return .f.
	EndIf

	// Verifica se a situacao do tipo de tempo selecionado ้ a mesma ...
	If aTempos[ni,03] <> aAuxTempos[03] .or. aTempos[ni,13] <> aAuxTempos[13] .or. aTempos[ni,14] <> aAuxTempos[14] .or. aTempos[ni,15] <> aAuxTempos[15]
		Alert(STR0070) // "Tipo de tempo foi alterado, favor selecionแ-lo novamente."
		Return .f.
	EndIf
	//

	aTempos[ni,01] := .t.
EndIf
//

// Gera uma matriz com os RECNO's da VO3 e VO4 que serao manipulados,
// os registros serใo bloqueados
aLockVO3 := {}
aLockVO4 := {}
For nCont := 1 to Len(aPeca)
	If lCancOS .or. (aPeca[nCont,01] == aTempos[ni,02] .and. aPeca[nCont,12] == aTempos[ni,15])
		For nContSel := 1 to Len(aPeca[nCont,14])
			VO3->(dbGoTo( aPeca[ nCont , 14 , nContSel , 05 ] ))
			AADD( aLockVO3 , VO3->VO3_GRUITE + VO3->VO3_CODITE + VO3->VO3_NOSNUM + VO3->VO3_TIPTEM + VO3->VO3_SEQINC )
		Next nContSel
	EndIf
Next nCont
For nCont := 1 to Len(aSrv)
	If lCancOS .or. (aSrv[nCont,01] == aTempos[ni,02] .and. aSrv[nCont,10] == aTempos[ni,15])
		For nContSel := 1 to Len(aSrv[nCont,12])
			VO4->(dbGoTo( aSrv[ nCont , 12 , nContSel , 08 ] ))
			AADD( aLockVO4 , VO4->VO4_NOSNUM + VO4->VO4_SEQUEN )
		Next nContSel
	EndIf
Next nCont
//

// Adiciona na matriz de RECNO's os RECNO's das OS's relacionadas
For nCont := 1 to Len(aOSRelac)
	aPecaOSRel := FMX_CALPEC(aOSRelac[nCont,1] , ;
									aOSRelac[nCont,8] ,;
									/* cGruIte */ ,;
									/* cCodIte */ ,;
									.t. /* lMov */ ,;
									.f. /* lNegoc */ ,;
									.f. /* lReqZerada */ ,;
									.t. /* lRetAbe */ ,;
									.t. /* lRetLib */ ,;
									.t. /* lRetFec */ ,;
									.t. /* lRetCan */ ,;
									IIf( !Empty(aOSRelac[nCont,9]) .or. Len(aOSRelac[nCont,9]) <> 0 , aOSRelac[nCont,9] , NIL ) )
	For nCont2 := 1 to Len(aPecaOSRel)
		For nContSel := 1 to Len(aPecaOSRel[nCont2,14])
			VO3->(dbGoTo( aPecaOSRel[ nCont2 , 14 , nContSel , 05 ] ))
			AADD( aLockVO3 , VO3->VO3_GRUITE + VO3->VO3_CODITE + VO3->VO3_NOSNUM + VO3->VO3_TIPTEM + VO3->VO3_SEQINC )
		Next nContSel
	Next nCont2

	aSrvOSRel := FMX_CALSER(aOSRelac[nCont,1] , ;
									aOSRelac[nCont,8] ,;
									/* cGruSer */ ,;
									/* cCodSer */ ,;
									.t.  /* lApont */ ,;
									.t. /* lNegoc */ ,;
									.t. /* lRetAbe */ ,;
									.t. /* lRetLib */ ,;
									.t. /* lRetFec */ ,;
									.t. /* lRetCan*/ ,;
									IIf( !Empty(aOSRelac[nCont,9]) .or. Len(aOSRelac[nCont,9]) <> 0, aOSRelac[nCont,9] , NIL ) )

	For nCont2 := 1 to Len(aSrvOSRel)
		For nContSel := 1 to Len(aSrvOSRel[nCont2,14])
			VO4->(dbGoTo( aSrvOSRel[ nCont2 , 14 , nContSel , 08 ] ))
			AADD( aLockVO4 , VO4->VO4_NOSNUM + VO4->VO4_SEQUEN )
		Next nContSel
	Next nCont2

Next nCont
//

// Bloqueia os registro da VO3/VO4 e VOO...
If ( Len(aLockVO3) <> 0 .and. !MultLock("VO3",aLockVO3,2) ) .and. ;
	( Len(aLockVO4) <> 0 .and. !MultLock("VO4",aLockVO4,8) )
	Return .f.
EndIf
//

// Se o Tipo de Tempo estiver Aberto, verifica se as requisicoes foram devolvidas ...
If lCancOS .or. aTempos[ni,13] == "A"
	lTemReqPeca	:= .f.
	lTemReqSrvc	:= .f.

	For nCont := 1 to Len(aPeca)
		If lCancOS .or. (aPeca[nCont,01] == aTempos[ni,02] .and. aPeca[nCont,12] == aTempos[ni,15])
			// Existe peca requisitada para a OS
			If aPeca[nCont,07] <> 0
				lTemReqPeca := .t.
				Exit
			EndIf
			//
		EndIf
	Next nCont

	For nCont := 1 to Len(aSrv)
		If lCancOS
			If !Empty(aSrv[nCont,01])
				lTemReqSrvc	:= .t.
				Exit
			EndIf
		Else
			If (aSrv[nCont,01] == aTempos[ni,02] .and. aSrv[nCont,10] == aTempos[ni,15])
				lTemReqSrvc	:= .t.
				Exit
			EndIf
		EndIf
	Next nCont

	If lTemReqPeca .or. lTemReqSrvc

		cMsg := IIf( lCancOS , STR0063 , STR0064 ) + CHR(13) + CHR(10) + ; // "Impossํvel cancelar OS.", "Impossํvel cancelar Tipo de Tempo."
		IIf( lTemReqPeca , STR0065 + CHR(13) + CHR(10) , "" ) + ; // "Existem pe็as requisitadas."
		IIf( lTemReqSrvc , STR0066 + CHR(13) + CHR(10) , "" ) // "Existem servi็os requisitados."

		Help(" ",1,"M150REQ",,cMsg,1,1)

		//   	MsgAlert( IIf( lCancOS , STR0063 , STR0064 ) + CHR(13) + CHR(10) + ;
		//				  IIf( lTemReqPeca , STR0065 + CHR(13) + CHR(10) , "" ) + ;
		//				  IIf( lTemReqSrvc , STR0066 + CHR(13) + CHR(10) , "" ) , STR0050 )// "Impossํvel cancelar OS." / "Impossํvel cancelar Tipo de Tempo."
		Return .f.

	EndIf

EndIf

Return .t.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ OM150ESTRE   บAutor  ณTakahashi       บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se ficou algum saldo de reserva, se tiver estorna   บฑฑ
ฑฑบ          ณ o saldo                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da OS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM150ESTRE(cNumOsv)

Local aItensNew := {}
Local nQtdEst
Local nSaldoSB2
Local aProdEst := {} // Contem os itens para estorno
Local nPosProdEst

Local oPeca := DMS_Peca():New()

Local aItemMov    := {}
Local oEst        := DMS_Estoque():New()

dbSelectArea("SB1")
dbSetOrder(7)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SB5")
dbSetOrder(1)

cLocal := GetMv("MV_RESITE")

dbSelectArea("VE6")
dbSetOrder(5)
VE6->(dbSeek( xFilial("VE6") + cNumOsv + "3"))
While !VE6->(Eof()) .and. VE6->VE6_FILIAL == xFilial("VE6") .and. VE6->VE6_NUMOSV == cNumOsv .and. VE6->VE6_INDREG == "3"

	// Estorna somente a quantidade nใo requisitada
	IF VE6->VE6_QTDITE <= ( VE6->VE6_QTDATE + VE6->VE6_QTDEST )
		VE6->(dbSkip())
		Loop
	EndIf
	//

	nPosProdEst := aScan( aProdEst , { |x| x[1] == VE6->VE6_GRUITE .and. x[2] == VE6->VE6_CODITE .and. x[4] == VE6->VE6_LOTECT .and. X[5] == VE6->VE6_NUMLOT .and. x[6] == VE6->VE6_NUMSER } )
	If nPosProdEst == 0
		AADD( aProdEst , { VE6->VE6_GRUITE , VE6->VE6_CODITE , 0 , VE6->VE6_LOTECT , VE6->VE6_NUMLOT , VE6->VE6_NUMSER } )
		nPosProdEst := Len(aProdEst)
	EndIf
	aProdEst[nPosProdEst,3] += (VE6->VE6_QTDITE - VE6->VE6_QTDATE)

	// Atualiza a quantidade estornada
	RecLock("VE6",.f.)
	VE6->VE6_QTDEST += (VE6->VE6_QTDITE - VE6->VE6_QTDATE)
	MsUnLock()

	VE6->(dbSkip())
EndDo

For nPosProdEst := 1 to Len(aProdEst)

	DbSelectArea("SB1")
	DbSeek( xFilial("SB1") + aProdEst[nPosProdEst,1] + aProdEst[nPosProdEst,2] )

	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	If Len(aItensNew) == 0
		aadd (aItensNew,{ NextNumero("SD3",2,"D3_DOC",.t.), ddatabase})
	EndIf

	DbSelectArea("SB5")
	DbSeek( xFilial("SB5") + SB1->B1_COD )

	aItemMov := oEst:SetItemSD3(SB1->B1_COD              ,; //C๓digo do Produto
								cLocal                   ,; // Armaz้m de Origem
								FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")  ,; // Armaz้m de Destino
								GetMv( "MV_RESLOC" )     ,; // Localiza็ใo Origem
								FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,; // Localiza็ใo Destino
								aProdEst[nPosProdEst,3]  ,; // Qtd a transferir
								aProdEst[nPosProdEst,4]  ,; // Nro de lote
								aProdEst[nPosProdEst,5]  ,; // Nro de Sub-Lote
								aProdEst[nPosProdEst,6]   ) // Nro de S้rie

	aAdd(aItensNew, aClone(aItemMov))

Next nPosProdEst

If (ExistBlock("OM150AP"))
	aItensNew := ExecBlock("OM150AP", .f., .f., {aItensNew})
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a Transferencia de Almoxarifadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aItensNew) > 0
	SB1->(DbSetOrder(1))
	lMsErroAuto := .F.
	MSExecAuto({|x| MATA261(x)},aItensNew)
	If lMsErroAuto
		Return .f.
	EndIf
EndIf

Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ OM140VFB   บAutor  ณ Takahashi          บ Data ณ  09/11/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Ocorrencia do Veiculo                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipReg - Tipo do Registro                                 บฑฑ
ฑฑบ          ณ           "P" - Peca                                       บฑฑ
ฑฑบ          ณ           "S" - Servico                                    บฑฑ
ฑฑบ          ณ cCodCli - Codigo do Proprietario do Veiculo                บฑฑ
ฑฑบ          ณ cCodLoj - Loca do Proprietario do Veiculo                  บฑฑ
ฑฑบ          ณ cChaInt - Chassi Interno no Veiculo                        บฑฑ
ฑฑบ          ณ cTipTem - Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cNumOsv - Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cAuxGrupo  - Codigo do Grupo                               บฑฑ
ฑฑบ          ณ cAuxCodigo - Codigo da Peca/Servico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM140VFB(cTipReg,cCodCli,cCodLoj,cChaInt,cTipTem,cNumOsv,cAuxGrupo,cAuxCodigo)

Local cSQL := ""
Local cAliasVFB := "TVFB"
Local lRet := .t.

cSQL := "SELECT R_E_C_N_O_ NRECNO"
cSQL +=  " FROM " + RetSQLName("VFB") + " VFB"
cSQL += " WHERE VFB_FILIAL = '" + xFilial("VFB") + "'"
cSQL +=   " AND VFB_CODCLI = '" + cCodCli + "'"
cSQL +=   " AND VFB_LOJA = '" + cCodLoj + "'"
cSQL +=   " AND VFB_CHAINT = '" + cChaInt + "'"
cSQL +=   " AND VFB_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VFB_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VFB_SERPEC = '" + cTipReg + "'"
If cTipReg == "P"
	cSQL += " AND VFB_GRUITE = '" + cAuxGrupo + "'"
	cSQL += " AND VFB_CODITE = '" + cAuxCodigo + "'"
ElseIf cTipReg = "S"
	cSQL += " AND VFB_CODSER = '" + cAuxCodigo + "'"
EndIf
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVFB , .F., .T. )
(cAliasVFB)->(dbGoTop())
dbSelectArea("VFB")
While !(cAliasVFB)->(Eof())
	VFB->(dbGoTo( (cAliasVFB)->NRECNO ))
	If !RecLock("VFB",.f.)
		lRet := .f.
		Exit
	EndIf

	VFB->VFB_DATFEC := CtoD("")

	(cAliasVFB)->(dbSkip())
EndDo
(cAliasVFB)->(dbCloseArea())

dbSelectArea("VO1")

Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM150V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM150V()
nOpc := 1
OFIOC450()
Return(.t.)





/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณAjustaHelp ณ Autor ณ Rubens Takahashi     ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Ajuta help da Rotina                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaHelp()

Local aHelpEng, aHelpSpa, aHelpPor

aHelpPor := { STR0072 } // "Encontrado Or็amento no Loja."
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("PM150LOJA",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := { STR0049 } // "Or็amento do Loja deverแ ser Eliminado..."
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("SM150LOJA",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := { STR0073 } // "Estorne as requisi็๕es."
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("SM150REQ",aHelpPor,aHelpEng,aHelpSpa,.T.)

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOM150VCAN  ณ Autor ณ Thiago               ณ Data ณ 25/04/17 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao VAI_TIPCAN.                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM150VCAN(cTipCan,nTotPec,nTotSer,cStatus)

if cStatus == "I" // (Individual)
	if cTipCan == "2" .and. nTotPec==0
		Return(.f.)
	Endif
	if (cTipCan == "3" .and. nTotSer==0) .or. (cTipCan == "3" .and. nTotPec<>0 .and. nTotSer<>0)
		Return(.f.)
	EndIf
Else // cStatus == "A" (Agrupado) - O.S. fechadas com tipo de tempo de pe็a e servico na mesma nota so permite cancelar se o campo VAI_TIPCAN estiver IGUAL a 'Ambos'
	if cTipCan $ "23" .and. nTotPec > 0 .and. nTotSer > 0
		Help("  ",1,"SEMPERM")
		Return(.f.)
	Endif
Endif

Return(.t.)



/*/{Protheus.doc} OM150PEDIDO
Retorna o numero do pedido que deverแ ser cancelado
@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}
@param cNumNFI, characters, descricao
@param cSerieNFI, characters, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param lNFeCancel, logical, descricao
@type function
/*/
Static Function OM150PEDIDO( cNumNFI , cSerieNFI , cCliente, cLoja , lNFeCancel)

	Local cRetorno := ""

	cSQL := "SELECT D2_PEDIDO "
	cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 "
	cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cSQL +=   " AND SD2.D2_DOC = '" + cNumNFI + "'"
	cSQL +=   " AND SD2.D2_SERIE = '" + cSerieNFI + "'"
	cSQL +=   " AND SD2.D2_CLIENTE = '" + cCliente + "'"
	cSQL +=   " AND SD2.D2_LOJA = '" + cLoja + "'"
	cSQL +=   " AND SD2.D_E_L_E_T_ = ' '"
	cRetorno := FM_SQL(cSQL)

	// Se nใo encontrar o pedido e o cliente utilizar o JOB de Cancelamento (MV_CANCNFE)
	// procura o ultimo pedido com nota fiscal deletada
	If Empty(cRetorno) .and. lNFeCancel
		cSQL := "SELECT MAX(D2_PEDIDO) "
		cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 "
		cSQL +=  " JOIN " + RetSQLName("SC5") + " SC5 "
		cSQL +=    " ON SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
		cSQL +=   " AND SC5.C5_NUM = SD2.D2_PEDIDO "
		cSQL +=   " AND SC5.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cSQL +=   " AND SD2.D2_DOC = '" + cNumNFI + "'"
		cSQL +=   " AND SD2.D2_SERIE = '" + cSerieNFI + "'"
		cSQL +=   " AND SD2.D2_CLIENTE = '" + cCliente + "'"
		cSQL +=   " AND SD2.D2_LOJA = '" + cLoja + "'"
		cRetorno := FM_SQL(cSQL)
	EndIf
	//
Return cRetorno

/*/{Protheus.doc} OM150FECHAR

@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM150FECHAR()
	MsUnlockAll()
Return

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

/*/{Protheus.doc} OM150VS1LIMPAORC
Limpa N๚mero da NF e S้rie caso Or็amento
@author Fernando V. Cavani
@since 07/02/2018
@version 1.0
@param cNumNFI, characters, descricao
@param cSerieNFI, characters, descricao
@type function
/*/
Static Function OM150VS1LIMPAORC(cNumNFI, cSerieNFI)
	Local cSQL := ""

	cSQL := " UPDATE " + RetSQLName("VS1") + " SET "
	cSQL +=   " VS1_NUMNFI = ' ', "
	cSQL +=   " VS1_SERNFI = ' '"
	cSQL += " WHERE VS1_FILIAL = '" + xFilial("VS1") + "'"
	cSQL +=   " AND VS1_NUMNFI = '" + cNumNFI + "'"
	cSQL +=   " AND VS1_SERNFI = '" + cSerieNFI + "'"
	cSQL +=   " AND VS1_TIPORC = '2'"
	TCSqlExec(cSQL)

	DbSelectArea("VOO")
Return

/*/{Protheus.doc} OM1500015_EfetuaCancGar
Valida e efetua o cancelamento da garantia
@author Renato Vinicius
@since 30/11/2018
@version 1.0
@param lValida, booleano, descricao
@param aOSRelacio, array, descricao
@param nPosTemp, numerico, descricao
@type function
/*/
Static Function OM1500015_EfetuaCancGar(lValida,aOSRelacio,nPosTemp)

Local lRetCGar := .t.
Local nCont    := 0

Default lValida    := .t.
Default aOSRelacio := {}
Default nPosTemp   := 0

If !FS_CANGAR( aTempos[nPosTemp,2] , aTempos[nPosTemp,15] , aTempos[nPosTemp,13])
	If lValida
		lRetCGar := .f.
	EndIf
EndIf

// Executa funcao de Garantia para cada OS Relacioada
If Len(aOSRelacio) > 0
	nRecVO1 := VO1->(RecNo())
	VO1->(dbSetOrder(1))
	For nCont := 1 to Len(aOSRelacio)
		VO1->(dbSeek( xFilial("VO1") + aOSRelacio[nCont,1] ))
		If !FS_CANGAR( aOSRelacio[nCont,8] , aOSRelacio[nCont,9] , "F" )
			If lValida
				lRetCGar := .f.
			EndIf
		EndIf
	Next nCont
	VO1->(dbGoTo(nRecVO1))
EndIf

If !lRetCGar
	Help("  ",1,"CANOSGA",,STR0068,4,1) // "OS jแ enviada para a Montadora. Liberar a manuten็ใo da GARANTIA antes do cancelamento."
EndIf

Return lRetCGar

/*/{Protheus.doc} OM1500025_MarcaJD
Indica็ใo de chassi marca john deere
@author Renato Vinicius
@since 30/11/2018
@version 1.0
@param
@type function
/*/
Static Function OM1500025_MarcaJD()

Local lRetMarJD := .t.

	VV1->(dbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1") + VO1->VO1_CHAINT))

	cSQL := "SELECT VE1_MARFAB "
	cSQL +=  " FROM " + RetSQLName("VE1")
	cSQL += " WHERE VE1_FILIAL = '" + xFilial("VE1")+"'"
	cSQL +=   " AND VE1_CODMAR = '" + VV1->VV1_CODMAR + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"

	If !(FM_SQL(cSQL) $ "JD /GRS/PLA/JDC/HCM")
		lRetMarJD := .f.
	Endif

Return lRetMarJD
