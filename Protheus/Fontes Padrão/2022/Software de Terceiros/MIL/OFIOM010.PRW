#Include "Ofiom010.ch"
#Include "Protheus.ch"

#define STR0099 "" // Reaproveitar

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
Static cMVGARJD_T := OM010SIMU()
Static OFNJD15011 := FindFunction("OFNJD15011_RetornaMarca")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOM010 ณ Autor ณ  Emilton              ณ Data ณ 19/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Abertura de Ordens de Servico Manual                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Oficina                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM010(cNumOsv,nOpcOp,cNroOrc,lImp,lNoMBrowse)
Local cFilUser	:=	""
Local cUsaVo1 	:= 	""
Local cResVo1 	:= 	""
Local aCores    := {{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE'     } ,;   // Aberta
					{ 'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,;  // Liberada
					{ 'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,;  // Fechado
					{ 'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }   // Cancelado

Default lNoMBrowse := .f.

Private aArea     	:= GetArea() // Claudia
Private aIndVO1   	:= {} // Claudia
Private cCondicao 	:= "" // Claudia
PRIVATE aMemos  	:= {{"VO1_OBSMEM","VO1_OBSERV"}}
PRIVATE aCpoEnchoice := {}
//PRIVATE aCamposCamTec := {}
PRIVATE aRotina := MenuDef()
PRIVATE nLimCre := val(&(GetMV("MV_LIMCRE"))) , nIndVO1 := 0
Private lAuto := .f.
Private lImpOsv := .t.
Private cPerg := "OFM010"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"
Private cGetDados := "oGD010"
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
// Especifico para integra็ใo com Garantia
Private aRetWS := {}
//
Private lGarMut := (VO1->(FieldPos("VO1_GARMUT")) <> 0 )
Private nValGarMut := 0
//

VO1->(dbClearFilter())
Pergunte(cPerg,.f.)
// Antes de mostrar o browse de O.S.
If ExistBlock("MNBROM010")
	ExecBlock("MNBROM010",.f.,.f.,{})
EndIf

dbSelectArea("VO1")

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If AMIIn(11,14,41)

	If cMVGARJD_T
		MsgInfo(STR0135) // Simulacao de Garantia John Deere
	EndIf

	If lNoMBrowse
		dbSelectArea("VO1")
		If ( nOpc <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
		EndIf
	Else

		DbSelectArea("VO1")

		dbSelectArea("VAI")
		dbSetOrder(4)
		dbSeek(xFilial("VAI")+__cUserID)
		cAnd := ""
		if MV_PAR01 == 1
			cCondicao := "VO1->VO1_STATUS == 'A'"
			cAnd := ".AND."
		elseif MV_PAR01 == 2
			cCondicao := "VO1->VO1_STATUS == 'L'"
			cAnd := ".AND."
		elseif  MV_PAR01 == 3
			cCondicao := "VO1->VO1_STATUS == 'F'"
			cAnd := ".AND."
		else
			cCondicao := ".t. "
			cAnd := ".AND."
		endif

		if MV_PAR02 > 0
			cCondicao := cCondicao + cAnd + "VO1->VO1_DATABE > DDATABASE - "+str(MV_PAR02)
			cAnd := ".AND."
		endif

		DbSelectArea("VO1")
		if 	VAI->VAI_TIPTEC == "4"
			dbSetOrder(1)
			cCondicao := cCondicao + cAnd + "VO1->VO1_FUNABE == VAI->VAI_CODTEC"
		Endif

		If 	ExistBlock("OFI010FBRW") // Ponto de Entrada para Filtro no Browse
			cFilUser := ExecBlock("OFI010FBRW",.F.,.F.,cCondicao)
			if	!Empty(cFilUser) .and. ValType(cFilUser) == "C"
				cCondicao += iif( !Empty(cCondicao) , " .and. " , "" ) + cFilUser
			Endif
		Endif

		if 	!Empty(cCondicao)
			bFiltraBrw := { || FilBrowse("VO1",@aIndVO1,@cCondicao) }
			Eval(bFiltraBrw)
		endif

		mBrowse(06,01,22,75,"VO1",,,,,,aCores)

		VO1->(dbClearFilter())


	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010I_I  บAutor  ณThiago				 บ Data ณ  26/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncluir ordem de servico                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010I_I(cAlias,nReg,nOpc)
	nOpc := 3
	OM010I(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010I_A  บAutor  ณThiago			     บ Data ณ  26/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlterar ordem de servico                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010I_A(cAlias,nReg,nOpc)
	nOpc := 4
	OM010I(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010I    บAutor  ณFabio / Emilton     บ Data ณ  08/31/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncluir ordem de servico                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010I(cAlias,nReg,nOpc)

Local oDlgOSv, cNumOSv , aVetCampos := {} , cArqOsv
Local aCpoAltera := IIF( nOpc # 3 , {} , NIL )
Local oFont := TFont():New( "Courier New", 7, 15 )  // Sans Serif   Courier
Local nRecnoVO1 := 0, nCntFor := 0, nOpca:=0
Local nCrrgVar := 0
Local aObjects := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize(.t.) // Variaveis para posicionamento de Tela

Private aCpoEnchoice  :={}
Private nOpcE := 0 , nOpcG := 0 , aFicha := {} , aHeader:={} , cChaIntF := "" , cChaIntA := ""
Private oLbaFicha , lImportAge := .f.
Private cObsOS := "", nTamObs := 0, aCfgCpo := {}, cMostraAgr := "", cMostraSeq := ""
Private nLenaCols:=0

PRIVATE aRotina := { {  ,"", , 3},;
{  ,"", , 3},;
{  ,"", , 3},;
{  ,"", , 4}}

Private aBotoes  := { {"PESQUISA",{|| FG_OSONLINE() },STR0011} }

Private lVO1DATATE := .F.
Private lVO1HORTRI := ( VO1->(FieldPos("VO1_HORTRI")) <> 0 )

If lGarMut
	AADD( aBotoes , { "LJPRECO" , { || OM010GMUT() } , STR0128 } ) // "Garantia mutua"
EndIf

If cMVMIL0006 == "JD" .AND. FindFunction("OFICJD01")
	AADD( aBotoes , {"GET", { || OM010WS(2) } , STR0131 }) // "Consulta Inf. Garantia"
	AADD( aBotoes , {"GET", { || OM010WS(3) } , STR0132 }) // "Consulta Plano Revisใo/PMP"
EndIf

If cMVMIL0006 == "SCA" .AND. FindFunction("OFICSC01")
	AADD( aBotoes , {"GLOBO", { || OM010WS(2) } , STR0097 }) // "Claw"
EndIf

If ExistBlock("INCBOT010")
	aBotoes := ExecBlock("INCBOT010",.f.,.f.,{aBotoes})
EndIf

If Type("lAuto") == "U"
	lAuto := .f.
EndIf

If nOpc == 4 .And. VO1->VO1_STATUS # "A"
	if VO1->VO1_STATUS <> "F" .and. VO1->VO1_STATUS # "C"
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek("VO1_FATPAR")
			if !Empty(SX3->X3_WHEN) .and. &(SX3->X3_WHEN) == .f. // Os campo VO1_FATPAR e VO1_LOJA So ้ permitido altera็ao quando a O.S. nao estiver mais aberta para os casos que os campos estirem abilitados no WHEN
				Help("  ",1,"OSNABERTA")
				Return
			Endif
		Endif
	Endif
EndIf

// Tira o filtro
nRecnoVO1 := VO1->(Recno())

dbSelectArea("VO1")       // CLAUDIA
RetIndex("VO1")           // CLAUDIA
dbClearFilter()           // CLAUDIA
VO1->(DbGoTo(nRecnoVO1))

If nOpc == 3
	nOpcE  := 3
	nOpcG  := 3
	Inclui := .t.
	Altera := .f.
Else
	nOpc  := 4
	nOpcE := 4
	nOpcG := 4
	Inclui := .f.
	Altera := .t.
EndIf


DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VO1")
aCpoEnchoice := {}

While !Eof() .and. (X3_arquivo == "VO1")

	If X3USO(x3_usado).and.(cNivel>=x3_nivel .OR. X3OBRIGAT(X3_CAMPO)) .And. ( !( Alltrim(x3_campo) $ "VO1_NUMOSV/VO1_DATSAI/VO1_HORSAI/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_TIPSOL/VO1_SITGAR/VO1_OBSMEM/VO1_CODMAR/VO1_EXPGAR/VO1_MOTIVO/VO1_DESMOT/VO1_TEMFEC/VO1_TEMCAN/VO1_OBSLAU" ) ;
		.Or. ( nOpcE # 3 .And. Alltrim(x3_campo) $ "VO1_NUMOSV" ) )

		aadd(aCpoEnchoice,x3_campo)

	EndIf
	&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)

	If nOpcE # 3 .and. SX3->X3_PROPRI == "U"
		AADD( aCpoAltera , SX3->X3_campo )
	EndIf

	If Alltrim(x3_campo) == "VO1_OBSERV"
		nTamObs := x3_tamanho
	EndIf

	dbskip()

Enddo

lVO1DATATE := ( aScan(aCpoEnchoice, "VO1_DATATE" ) > 0 )

If nOpcE # 3

	DbSelectArea("VO1")
	For nCntFor := 1 TO FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next

	If Empty(VO1->VO1_NUMBOX)
		Aadd( aCpoAltera , "VO1_NUMBOX" )
	EndIf
	Aadd( aCpoAltera , "VO1_KILOME" )
	If VO1->(FieldPos("VO1_HORTRI")) > 0
		Aadd( aCpoAltera , "VO1_HORTRI" )
	EndIf
	Aadd( aCpoAltera , "VO1_OBSMEM" )
	Aadd( aCpoAltera , "VO1_OBSERV" )
	Aadd( aCpoAltera , "VO1_HORABE" )
	Aadd( aCpoAltera , "VO1_FUNABE" )
	// Seguradora
	Aadd( aCpoAltera , "VO1_NUMLIB" )
	Aadd( aCpoAltera , "VO1_FORPAG" )
	Aadd( aCpoAltera , "VO1_CODBCO" )
	Aadd( aCpoAltera , "VO1_APOLIC" )
	Aadd( aCpoAltera , "VO1_SINIST" )
	Aadd( aCpoAltera , "VO1_NROAPR" )
	Aadd( aCpoAltera , "VO1_FATPAR" )
	Aadd( aCpoAltera , "VO1_LOJA" )
	Aadd( aCpoAltera , "VO1_DATENT" )
	Aadd( aCpoAltera , "VO1_HORENT" )
	If VO1->(FieldPos("VO1_TPATEN")) <> 0
		Aadd( aCpoAltera , "VO1_TPATEN" )
	Endif
	If Empty(VO1->VO1_FRANQU)
		Aadd( aCpoAltera , "VO1_FRANQU" )
	EndIf
	If VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. Empty(VO1->VO1_FRANQP)
		Aadd( aCpoAltera , "VO1_FRANQP" )
	EndIf
	// Se houver uma requisicao de servico com apontamento, nao sera possivel alterar a data de atendimento da OS
	// Nใo ้ possivel alterar, pois quando informada a data de atendimento, a validacao do apontamento sera feita de acordo com seu conteudo...
	cSQL := "SELECT COUNT(*)"
	cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
	cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
	cSQL +=   " AND VO4.VO4_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VO4.VO4_DATINI <> '        '"
	cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == 0
		Aadd( aCpoAltera , "VO1_DATATE" )
		Aadd( aCpoAltera , "VO1_HORATE" )
	EndIf

	//	Campos que podem ser alterados somente quando nao existe Requisicoes de Pecas e/ou Apontamentos de Servicos //
	If FS_PECSRV()
		Aadd( aCpoAltera , "VO1_GETKEY" ) // Chave de Pesquisa do Veiculo (Chassi/Chaint/Placa/...)
	EndIf
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Garantia Mutua
	If VO1->(FieldPos("VO1_GARMUT")) <> 0
		VDF->(dbSetOrder(2))
		If !VDF->(dbSeek(xFilial("VDF") + VO1->VO1_NUMOSV))
			Aadd( aCpoAltera , "VO1_GARMUT" )
		EndIf
	EndIf
	//

EndIf

If nOpc == 4 .AND. VO1->VO1_STATUS # "C"
	If  GetNewPar("MV_MIL0023","N") <> "S"  //Nใo permite alterar Chassi OS com Requisi็ใo antes da Libera็ใo? (S ou N)
		If VO1->VO1_STATUS # "A"
			aCpoAltera := {}
			Aadd( aCpoAltera , "VO1_FATPAR" )
			Aadd( aCpoAltera , "VO1_LOJA" )
		Endif
	Else
		If VO1->VO1_STATUS $ "DF"
			aCpoAltera := {}
			Aadd( aCpoAltera , "VO1_FATPAR" )
			Aadd( aCpoAltera , "VO1_LOJA" )
		Endif
	Endif

ElseIf nOpc == 4 .AND. VO1->VO1_STATUS $ "C"
	//CI 010853 passou a permitir altera็ใo do horimetro de OS cancelada
	aCpoAltera := {}
	Aadd( aCpoAltera , "VO1_HORTRI" )
	Aadd( aCpoAltera , "VO1_KILOME" )
EndIf


If nOpc == 4
	/* mostrar os dados do veiculo, proprietario etc na alteracao */
	FG_SEEK("VV1","vo1->vo1_chassi",2,.f.)
	if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
		FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
		FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
		If lA1_IBGE
			FG_Seek("VAM","SA1->A1_IBGE",1,.f.) // CIDADE
		EndIf

		DbSelectArea("VE1")
		DbSetOrder(1)
		DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)

		M->VO1_DESMAR := VE1->VE1_DESMAR
		M->VO1_DESMOD := VV2->VV2_DESMOD
		M->VO1_GETKEY := VV1->VV1_CHASSI
		M->VO1_CODFRO := VV1->VV1_CODFRO
		M->VO1_PLAVEI := VV1->VV1_PLAVEI
		M->VO1_FABMOD := VV1->VV1_FABMOD
		M->VO1_DESCOR := VVC->VVC_DESCRI
		M->VO1_PROVEI := SA1->A1_COD
		M->VO1_LOJPRO := VV1->VV1_LJPATU
		M->VO1_NOMPRO := SA1->A1_NOME
		M->VO1_NOMFAT := SA1->A1_NOME
		M->VO1_ENDPRO := SA1->A1_END
		M->VO1_CIDPRO := FS_VLCIDEST()[1]
		M->VO1_ESTPRO := FS_VLCIDEST()[2]
		M->VO1_FONPRO := SA1->A1_TEL
		M->VO1_CODMAR := VE1->VE1_CODMAR
	EndIF

EndIF

// Salva o conteudo da observacao para tratamento.
If Altera .and. VE4->VE4_TRAOSV == "1"

	cObsOS := M->VO1_OBSERV
	If !Empty(M->VO1_OBSERV) .And. Substr( M->VO1_OBSERV , (Len(M->VO1_OBSERV)-50) , 48 ) # Repl("_",48)
		M->VO1_OBSERV += Chr(13)+Chr(10)+Repl("_",nTamObs)+Chr(13)+Chr(10)
		cObsOS := M->VO1_OBSERV
	EndIf

EndIf

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 1 , 1 }
aPosObj := MsObjSize (aInfo, aObjects, .t.)

DEFINE MSDIALOG oDlg TITLE STR0004 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

//@ aPosObj[1,1],aPosObj[1,2] FOLDER oFldOm010 SIZE aPosObj[1,4], aPosObj[1,3]-aPosObj[1,1] OF oDlg PROMPTS STR0012,STR0013 PIXEL

oFldOm010 := TFolder():New(aPosObj[1,1], aPosObj[1,2], { STR0012,STR0013 }, , oDlg, , , , .t. , , aPosObj[1,4], aPosObj[1,3]-aPosObj[1,1] )

oFldOm010:bChange := {|| FS_FICHA() }
oFldOm010:bSetOption := {|| FS_OM010LOK() }

// Primeira Aba                                   //191 - 220
//EnChoice("VO1",nReg,nOpcE,,,,aCpoEnchoice,{000,000,aPosObj[1,3]-27,aPosObj[1,4]-2},aCpoAltera,3,,,,oFldOm010:aDialogs[1],,.F.)
oEnc010VO1 := MsMGET():New("VO1",nReg, nOpcE ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, ;
	{000,000,aPosObj[1,3]-27,aPosObj[1,4]-2}, ;
	aCpoAltera, 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oFldOm010:aDialogs[1] , .f. /* lF3 */ , .f. /* lMemoria */ , .F. /* lColumn */ ,;
	/* caTela */ ,  /* lNoFolder */, .f. /* lProperty */ )
oEnc010VO1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

// Segunda Aba
@ 001,.1 LISTBOX oLbaFicha FIELDS HEADER;
		OemToAnsi(STR0015);
		SIZE 100,100 OF oFldOm010:aDialogs[2] PIXEL
//oLbaFicha:oFont := oFont
oLbaFicha:Align := CONTROL_ALIGN_ALLCLIENT

Aadd( aFicha , {""} )

oLbaFicha:SetArray(aFicha)
oLbaFicha:bLine := { || { aFicha[oLbaFicha:nAt,1] } }

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| if(FS_OM010LOK().and. obrigatorio(oEnc010VO1:aGets,oEnc010VO1:aTela).And.FS_OM010GRA(nOpc),(nOpca:=1,oDlg:End()),.f.) },{|| (nOpca:=2,oDlg:End()) },,aBotoes) )

cNumAgenda := ""

nValGarMut := 0

DbSelectArea("VO1")

// Volta Filtro
if VAI->VAI_TIPTEC == "4"
	If Type("bFiltraBrw") # "U"
		bFiltraBrw := {|| FilBrowse("VO1",@aIndVO1,@cCondicao) }
		Eval(bFiltraBrw)
		///	VO1->(DbGoTo(nRecnoVO1))
	EndIf
Endif

Return( (nOpca == 1) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_OM010GRA Autor ณ  Emilton              ณ Data ณ 19/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Gravacao da Ordens de Servico                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Oficina                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OM010GRA(nOpc)

Local nInc:=0

Local aParambox := {}
Local aRet      := {}
Local lAchou    := .f.
Local nCntFor := 0

PRIVATE aMemos  := {{"VO1_OBSMEM","VO1_OBSERV"}}

dbSelectArea("VSO")
dbSetOrder(3)
if dbSeek(xFilial("VSO")+M->VO1_GETKEY)
	While !Eof() .and. xFilial("VSO") == VSO->VSO_FILIAL .and. M->VO1_GETKEY == VSO->VSO_GETKEY
		if VSO->VSO_DATAGE > dDataBase
			if !MsgYesNo( STR0086 + dtoc(VSO->VSO_DATAGE) + STR0087 + transform(val(VSO->VSO_HORAGE),"@E 99:99")+ STR0088 ) // Veiculo encontra-se agendado no dia
				Return(.f.)
			Else
				Exit
			Endif
		Endif
		dbSelectArea("VSO")
		dbSkip()
	Enddo
Endif
// Verifica se o cliente esta bloqueado
DbSelectArea("SA1")
DbSetOrder(1)
If !Empty(M->VO1_FATPAR)
	DbSeek(xFilial("SA1")+M->VO1_FATPAR+M->VO1_LOJA)
Else
	DbSeek(xFilial("SA1")+M->VO1_PROVEI+M->VO1_LOJPRO)
EndIf
If SA1->A1_MSBLQL == "1"
	MsgStop(STR0083+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(RetTitle(IIf(!Empty(M->VO1_FATPAR),"VO1_FATPAR","VO1_PROVEI")))+": "+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,STR0029) // Cliente bloqueado! / Aten็ใo!
	DbSelectArea("VO1")
	Return(.f.)
EndIf

// Valida็ใo Tipo de Atendimento por Tipo de Tempo (Pe็a e Servi็os)
If !OM010TPATEN(M->VO1_TPATEN, M->VO1_NUMOSV, .t.)
	Return .f.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ So exibe Parambox se existe o campo VO1_FRANQP (Update de OS de Seguradora) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if (M->VO1_FRANQU > 0 .and. VO1->(FieldPos("VO1_FRANQP")) > 0 ) .or. (VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. M->VO1_FRANQP > 0)

	cTTSegPeca := cTTSegSrvc := Space(TamSX3("VOI_TIPTEM")[1])
	aParamBox := {}
	aAdd(aParamBox,{1,STR0084 ,cTTSegPeca,"@!","!Empty(MV_Par01)","VOI","",0,.t.}) // "TT Seguradora - Peca"
	aAdd(aParamBox,{1,STR0085 ,cTTSegSrvc,"@!","!Empty(MV_PAR02)","VOI","",0,.t.}) // "TT Seguradora - Serv."
	While .t.
		If ParamBox(aParamBox,STR0091,@aRet,,,,,,,,.T.)//"TT de Seguradora"
			cTTSegPeca := aRet[1]
			cTTSegSrvc := aRet[2]
			exit
		Endif
	Enddo

endif

Begin Transaction

DbSelectArea("VO1")
RecLock("VO1",If(nOpc == 3,.t.,.f.))
FG_GRAVAR("VO1")
If nOpc == 3
//	If cMVGARJD_T .AND. M->VO1_CODMAR == FMX_RETMAR("JD") .and. MsgNoYes(STR0136) // Deseja informar o n๚mero manualmente?
//		VO1->VO1_NUMOSV := FMX_INPUTBOX(STR0137, Space(TamSX3("VO1_NUMOSV")[1])) // "N๚mero da O.S"
//	Else
		VO1->VO1_NUMOSV := GetSXENum("VO1","VO1_NUMOSV")
		ConfirmSx8()
//	EndIf
EndIf

dbSelectArea("VA8")
dbSetOrder(1)
if dbSeek(xFilial("VA8")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
	dbSelectArea("VA8")
	Reclock("VA8",.f.)
	VA8->VA8_NUMOSV := VO1->VO1_NUMOSV
	MsUnlock()
Endif
If VSR->(FieldPos("VSR_PLAVEI")) # 0
	dbSelectArea("VSR")
	dbSetOrder(2)
	if dbSeek(xFilial("VSR")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
		dbSelectArea("VSR")
		Reclock("VSR",.f.)
		VSR->VSR_NUMOSV := VO1->VO1_NUMOSV
		MsUnlock()
	Endif
Endif
MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1],,&(aMemos[1][2]),1,,,"VO1","VO1_OBSMEM")

MsUnlock()
cNumOsv := VO1->VO1_NUMOSV

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta Status do Box para analise.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FG_MARCABOX(VO1->VO1_NUMBOX,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV)

// tratamento de controle de status de veiculos soh se estiver abrindo OS para um veiculo que esta no estoque
VV1->(DbsetOrder(1))
VV1->(Dbseek(xFilial("VV1")+M->VO1_CHAINT))
If FG_STATUS(,"X") .and. VV1->VV1_SITVEI $ "0 "
	FG_STATUS(M->VO1_CHAINT,"O")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera Requisicao de Franquia    P E C A S     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if VO1->(FieldPos("VO1_FRANQP")) > 0 .AND. VO1->VO1_FRANQP > 0
	if !REQFRA020(VO1->VO1_NUMOSV,cTTSegPeca)
		DisarmTransaction()
		Return .f.
	endif
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera Requisicao de Franquia    S E R V I C O ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if VO1->VO1_FRANQU > 0 .and. VO1->(FieldPos("VO1_FRANQP")) > 0 // So deve requisitar se tiver rodado o UPDATE de OS de Seguradora
	if !REQFRA030(VO1->VO1_NUMOSV,cTTSegSrvc)
		DisarmTransaction()
		Return .f.
	endif
endif

// Importa Garantia ...
If !OM010IMPGAR()
	DisarmTransaction()
	RollbackSx8()
	Return .f.
EndIf
//

// Se for GARANTIA MUTUA e informado o valor estimado, gera a solicitacao de garantia mutua
If lGarMut .and. VO1->VO1_GARMUT == "1" .and. nValGarMut <> 0
	OA550INC(VO1->VO1_NUMOSV, "", nValGarMut)
EndIf
//

If cMVMIL0006 == "SCA" .AND. FindFunction("OFINSC01")
	OFSC01(.f.,.t.,VO1->VO1_NUMOSV,Space(TamSX3("VOI_TIPTEM")[1]),Space(TamSX3("VOO_LIBVOO")[1]))//lEnd, lAuto, cTipTem, cLibVOO
EndIf

// Atualiza tabela VFB
If nOpc == 4
	if !OM010ALTVFB(VO1->VO1_PROVEI,VO1->VO1_LOJPRO,VO1->VO1_CHAINT,cNumOsv,VO1->VO1_KILOME)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Return .f.
	EndIf

Endif

End Transaction

// Zera variavel de garantia mutua
nValGarMut := 0
//

If nOpc == 3

	If Type("GrvNoOS_") # "U"
		GrvNoOS_ := cNumOSv
	EndIf

	DEFINE MSDIALOG oDlgOSv TITLE OemtoAnsi(STR0009) FROM  02,04 TO 09,41 OF oMainWnd  //Dados da Ordem de Servico

	@ 002,004 TO 35,145 LABEL STR0010 OF oDlgOSv PIXEL  //Nro. da Ordem de Servico:
	@ 010, 035 Say cNumOSv  OF oDlgOSv PIXEL Font TFont():New( "System", 015, 048 ) SIZE 105,20

	DEFINE SBUTTON oFecha   FROM 038,110 TYPE 1 ACTION oDlgOSv:End() ENABLE OF oDlgOSv

	ACTIVATE MSDIALOG oDlgOSv CENTER

	// Imprime
	If lImpOsv
		FG_PEDORD(VO1->VO1_NUMOSV,"N","S")
	EndIf

EndIf

If ExistBlock("OM010DPGR")
	ExecBlock("OM010DPGR",.f.,.f.,{nOpc})
EndIf


Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FICHA  บAutor  ณFabio               บ Data ณ  09/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica historico de passagens                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_FICHA()

if oFldOm010:nOption == 2
	FS_IMPFICHA()
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OM010LO Autor  ณFabio               บ Data ณ  09/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida linha da getdados                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_OM010LOK()

Local cFatPar := "", cLojPar := ""
Local cProVei := "", cLojVei := ""

If ExistBlock("OM010BLOQ")
   If !ExecBlock("OM010BLOQ",.f.,.f.)
      return (.f.)
   Endif
EndIf

If !FS_VKILHOR( M->VO1_KILOME , IIF( lVO1HORTRI , M->VO1_HORTRI , 0 ) )
	Return .f.
EndIf

If cMVMIL0006 == "JD" .and. Altera .and. M->VO1_KILOME != VO1->VO1_KILOME
   FS_ATUKMJD()//Funcao atualiza km no cabecalho da garantia JD (VMB)
EndIf

If Type("M->VO1_FATPAR") # "U"
	cFatPar := M->VO1_FATPAR
	cLojPar := M->VO1_LOJA
	cProVei := M->VO1_PROVEI
	cLojVei := M->VO1_LOJPRO
ElseIf Type("M->VS1_CLIFAT") # "U"
	cFatPar := M->VS1_CLIFAT
	cLojPar := M->VS1_LOJA
	cProVei := VV1->VV1_PROATU
	cLojVei := VV1->VV1_LJPATU
EndIf

// Valida limite de credito
If !Empty(cFatPar) .And. !Empty(cLojPar)
	//   FG_Seek("SA1","M->VO1_FATPAR+M->VO1_LOJA",1,.f.)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek( xFilial("SA1") + cFatPar + cLojPar ))
	If !FS_LIMCRE(cFatPar,cLojPar)
		Return(.f.)
	EndIf
Else
	//   FG_Seek("SA1","M->VO1_PROVEI+M->VO1_LOJPRO",1,.f.)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek( xFilial("SA1") + cProVei + cLojVei ))
	If !FS_LIMCRE( cProVei, cLojVei)
		Return(.f.)
	EndIf
EndIf

// Valida Observacao
If !FS_VALOBS()
	Return(.f.)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_GetKeyณ Autor ณ  Emilton              ณ Data ณ 19/07/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Apresenta Dados de Veiculos para Orcamento                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_GETKEY()
Local lReturn   := .f. , cSelect := Alias() , aCampoVO5 := {}
Local oVeiculos := DMS_Veiculo():New()

Private cPesqVV1 := M->VO1_GETKEY

If Empty(M->VO1_GETKEY)
	Return(.t.)
EndIf

lReturn := FG_POSVEI("cPesqVV1",)

if !lReturn
	return(lReturn)
endif

DBSelectArea("VV1")

// Chassi Bloqueado
If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
	Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo Bloqueado()
EndIf

M->VO1_GETKEY := VV1->VV1_CHASSI

If FindFunction("FGX_ALTVEI")
	FGX_ALTVEI("A") // 28/02/2012 - VEIXFUNA - FGX_ALTVEI
Else
	FS_ALINVEI("A")
EndIf

If Empty(VV1->VV1_PROATU) .or. Empty(VV1->VV1_LJPATU)
	Help(" ",1,"OM010OBR")
	Return .f.
EndIf

If !Empty(M->VO1_PROVEI+M->VO1_LOJPRO)
	If VV1->VV1_PROATU+VV1->VV1_LJPATU != M->VO1_PROVEI+M->VO1_LOJPRO
		If !MsgYesNo(STR0133,STR0116) // O Proprietแrio deste novo Chassi estแ diferente do Proprietแrio do Chassi informado inicialmente nesta OS? Continuar? / Aten็ใo
			Return .f.
		Endif
	Endif
Endif

If FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
EndIf

M->VO1_CHASSI := VV1->VV1_CHASSI
M->VO1_CHAINT := VV1->VV1_CHAINT
M->VO1_PLAVEI := VV1->VV1_PLAVEI
M->VO1_CODFRO := VV1->VV1_CODFRO

VXA010GVO5(VV1->VV1_CHAINT,3)
If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,nOpcE,VO5->(RecNo())})
EndIf

if !FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)

	aCampoVO5 := {}
	dbSelectArea("SX3")
	dbSeek("VO5")

	While !EOF() .And. (X3_ARQUIVO == "VO5")
		IF X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
			AADD(aCampoVO5,X3_CAMPO)
		EndIF
		dbSkip()
	EndDO

	cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

	dbSelectArea("VO5")
	If AxInclui("VO5",0,3,aCampoVO5) != 1

		dbSelectArea("VO1")
		cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

		Return(.f.)

	EndIf

	cCadastro := OemToAnsi(STR0004) //"Abertura de OS - Manual"

endif

dbSelectArea("VO1")

if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)

	//FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
	FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
	If lA1_IBGE
		FG_Seek("VAM","SA1->A1_IBGE",1,.f.) // CIDADE
	EndIf

	DbSelectArea("VE1")
	DbSetOrder(1)
	DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)

	M->VO1_DESMAR := VE1->VE1_DESMAR
	M->VO1_DESMOD := VV2->VV2_DESMOD
	M->VO1_CHASSI := VV1->VV1_CHASSI
	M->VO1_CODFRO := VV1->VV1_CODFRO
	M->VO1_PLAVEI := VV1->VV1_PLAVEI
	M->VO1_FABMOD := VV1->VV1_FABMOD
	M->VO1_DESCOR := VVC->VVC_DESCRI
	M->VO1_PROVEI := SA1->A1_COD
	M->VO1_LOJPRO := SA1->A1_LOJA
	M->VO1_NOMPRO := SA1->A1_NOME
	M->VO1_NOMFAT := SA1->A1_NOME
	M->VO1_ENDPRO := SA1->A1_END
	M->VO1_CIDPRO := FS_VLCIDEST()[1]
	M->VO1_ESTPRO := FS_VLCIDEST()[2]
	M->VO1_FONPRO := SA1->A1_TEL
	M->VO1_CODMAR := VE1->VE1_CODMAR

else
	M->VO1_DESMAR := ""
	M->VO1_DESMOD := ""
	M->VO1_CHASSI := ""
	M->VO1_CODFRO := ""
	M->VO1_PLAVEI := ""
	M->VO1_FABMOD := ""
	M->VO1_DESCOR := ""
	M->VO1_PROVEI := ""
	M->VO1_NOMPRO := ""
	M->VO1_ENDPRO := ""
	M->VO1_CIDPRO := ""
	M->VO1_ESTPRO := ""
	M->VO1_FONPRO := ""
	M->VO1_LOJPRO := ""

	return(.f.)

endif

If Empty(cSelect)
	cSelect := "VO1"
EndIf
dbSelectArea(cSelect)

M->VO1_GETKEY := VV1->VV1_CHASSI

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_LimCreณ Autor ณ  Emilton              ณ Data ณ 26/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Pesquisa Limite de Credito do Cliente                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ OFIM010.PRW                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LIMCRE(cCodCli,cCodLoj)

//if FG_LIMCRE(cCodCli,cCodLoj) < 1
If "A" $ GetMv("MV_CHKCRE")

	if !FGX_AVALCRED(cCodCli,cCodLoj,nLimCre,.t.)

		Help("  ",1,"LIMITECRED",,OemToAnsi(STR0018+" "+cCodCli+"-"+cCodLoj),4,1)

		return .f.

	endif

EndIf

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_UltKilณ Autor ณ  Emilton              ณ Data ณ 20/09/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Pesquisa Ultima Kilometragem e Ve Plano de Revisao         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ OFIM010.PRW                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ULTKIL(cChaInt)
Return FS_VKILHOR( M->VO1_KILOME , NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_UltHorณ Autor ณ  Luis Delorme         ณ Data ณ 10/09/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Pesquisa Ultima Hora de Trilha do Veํculo/Equipamento      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ OFIM010.PRW                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ULTHOR(cChaInt)
Return FS_VKILHOR(M->VO1_KILOME , M->VO1_HORTRI)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VKILHOR บAutor  ณ Rubens Takahashi   บ Data ณ 21/08/15  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao de KM/Hora                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VKILHOR(nKilome, nHorTri)

If lVO1DATATE .and. !Empty(M->VO1_DATATE) .and. M->VO1_HORATE == 0
	MsgStop(STR0134) // "Informar a hora de execu็ใo"
	Return .f.
EndIf

If !FG_VKILHOR( M->VO1_CHAINT ,;
				IIf( lVO1DATATE .and. !Empty(M->VO1_DATATE) , M->VO1_DATATE , M->VO1_DATABE ),;
				IIf( lVO1DATATE .and. !Empty(M->VO1_HORATE) , M->VO1_HORATE , M->VO1_HORABE ),;
				nKilome ,;
				nHorTri ,;
				"ABE",;
				IIf( INCLUI , NIL , M->VO1_NUMOSV ))
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_SitCliณ Autor ณ  Emilton              ณ Data ณ 30/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Pesquisa Situacao e Idade do Cliente                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ OFIM010.PRW                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION FS_SITCLI()

if SA1->A1_RISCO $ "E"
	MSGSTOP(STR0006)  //"Venda NAO autorizada ! Consulte o Depto Financeiro !"
	return .f.
endif

if dDataBase > SA1->A1_VENCLC
	MSGSTOP(STR0007)  //"Data de Validade do Limite de Credito Vencida ! Consulte o Depto Financeiro !"
	return .f.
endif

*** Bloqueia Venda para Menores de 21 Anos ***********************************

If !empty(SA1->A1_DTNASC)

	If SA1->A1_PESSOA == "F"

		Do Case
			Case year(dDataBase) - year(SA1->A1_DTNASC) == 21

				If month(dDataBase) < month(SA1->A1_DTNASC)

					MSGSTOP(STR0008)  // "Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
					return(.f.)

				Endif

				If month(dDataBase) < month(SA1->A1_DTNASC)

					If day(dDataBase) < day(SA1->A1_DTNASC)
						MSGSTOP(STR0008)  //"Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
						return(.f.)
					Endif

				Endif

			Case year(dDataBase) - year(SA1->A1_DTNASC) < 21

				MSGSTOP(STR0008)  //"Impossivel emitir NF p/ cliente com idade inferior a 21 anos !"
				return(.f.)

		Endcase

	Endif

Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ FS_OFI010ณ Autor ณ  Emilton              ณ Data ณ 20/09/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Verifica utiliza็ใo do box e retorna mensagem de box em usoณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ OFIM010.PRW                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_OFI010()

Local lRet := .t.

If FG_SEEK("VOF","M->VO1_NUMBOX",1,.f.) ==.t.
	If VOF->VOF_SITBOX # "D"
		MsgInfo(STR0030,STR0029) // A box jแ estแ a ser utilizada... / Aten็ใo!
		lRet := .f.
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CHAMRSRบAutor  ณFabio               บ Data ณ  09/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama requisicao de servico                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CHAMRSRV()

Local aRotOld := aClone(aRotina)
Local nOpcBkp := nOpc
////
//Private cTpTpoPEVM := space(4) // Tipo de Tempo Pecas
//Private cProdPEVM  := space(6) // Tipo de Tempo Servico
////
//aRotina := { { STR0002 ,"axPesqui", 0 , 1},;   // Pesquisar
//{ STR0004 ,"OM030"    , 0 , 3},;   // Requisitar
//{ STR0005 ,"OM030A"    , 0 , 3}}    // Alterar
//
//DbSelectArea("VO1")
//OM030(Alias(),Recno(),3)

SetFunName("OFIOM030")
nOpc := 2
dbSelectArea("VO1")
OFIOM030(,.t.)
SetFunName("OFIOM010")
nOpc := nOpcBkp

aRotina := aClone(aRotOld)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALINVEIบ Autor ณ Andre Luis Almeida บ Data ณ  23/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Na abertura de OS. ALTERA / INCLUI veiculos                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MIL                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ALINVEI(cTipo)
Private cCadastro := OemToAnsi(STR0050+" - "+If(cTipo=="I",STR0052,If(cTipo=="A",STR0003,""))) //Cadastro de Veiculos # Incluir # Alterar
Private aMemos:={{"VV1_OBSMEM","VV1_OBSERV"}}
Private aCampos := {}
Private aRotina := {{ STR0001     , 0 , 1},;                // Pesquisar
{ STR0051    , "Vei010V" , 0 , 2 },;   // Visualizar
{ STR0052    , "Vei010I" , 0 , 3 },;   // Incluir
{ STR0003    , "Vei010A" , 0 , 4 }}	// Alterar
Private aCampoVV1 := {}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !EOF() .And. (X3_ARQUIVO == "VV1")
	If X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !x3_campo $ "VV1_NUMTRA/VV1_TRACPA"
		AADD(aCampoVV1,x3_campo)
		wVar := "M->"+x3_campo
		If x3_campo <> "VV1_CHAINT"
			&wVar:= CriaVar(x3_campo)
		Else
			&wVar:= Space(TamSx3("VV1_CHAINT")[1])
		EndIf
	EndIf
	DbSkip()
EndDo
If cTipo == "I"
	If MsgYesNo(STR0053,STR0029) //Veiculo nao encontrado! Deseja cadastrar o veiculo? # Aten็ใo!
		AxInclui("VV1",0,3,aCampoVV1,,,"VEIVA600()")
	EndIf
ElseIf cTipo == "A"
	If MsgYesNo(STR0054,STR0029) // Deseja alterar o registo do veํculo? / Aten็ใo!
		AxAltera("VV1",VV1->(RecNo()),4,aCampoVV1,,,,"VEIVA600()")
	EndIf
EndIf
If FindFunction("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALOBS บAutor  ณFabio               บ Data ณ  04/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida observacao da OS                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALOBS()

If VE4->VE4_TRAOSV == "1"

	If Substr( cObsOS , 1, Len(cObsOS) ) # Substr( M->VO1_OBSERV , 1, Len(cObsOS) )

		MsgStop(STR0031)

		Return(.f.)

	EndIf

	If !Empty(M->VO1_OBSERV) .And. Substr( M->VO1_OBSERV , (Len(M->VO1_OBSERV)-50) , 48 ) # Repl("_",48)
		M->VO1_OBSERV += Chr(13)+Chr(10)+Repl("_",nTamObs)+Chr(13)+Chr(10)
	EndIf

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSOS บAutor  ณFabio               บ Data ณ  04/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da consulta da OS                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CONSOS()

DbSelectArea("VO1")
RetIndex()
Set Filter To

//	OFIOC060()
OC060("VO1",VO1->(RECNO()),2)

DbSelectArea("VO1")
//	dbSetOrder(2)

//	cCondicao := "VO1->VO1_FILIAL == xFilial() .AND. VO1->VO1_STATUS == 'A'" // CLAUDIA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//	bFiltraBrw := {|| FilBrowse("VO1",@aIndVO1,@cCondicao) } // claudia
//	Eval(bFiltraBrw) // claudia

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLCIDE บAutor  ณFabio               บ Data ณ  04/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnalisa uso do VAM para adicionar no verot aRet             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VLCIDEST()

Local lVAMCid  := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Local aRet := {}

if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	aadd(aRet,VAM->VAM_DESCID)
	aadd(aRet,VAM->VAM_ESTADO)
Else
	aadd(aRet,SA1->A1_MUN)
	aadd(aRet,SA1->A1_EST)
Endif

Return(aRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOM010LEG   ณ Autor ณ Fabio                ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณofiom010                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010LEG()

Local aLegenda  := {{ 'BR_VERDE'   , STR0079   } ,;  // Aberta
					{ 'BR_AZUL'    , STR0092   } ,;  // Liberada
					{ 'BR_VERMELHO', STR0093   } ,;  // Fechado
					{ 'BR_PRETO'   , STR0094 } }     // Cancelado

BrwLegenda(cCadastro,STR0055 ,aLegenda)  //Legenda

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ  Emilton              ณ Data ณ 19/08/99 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRecebe := {}
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1},;   // Pesquisar
					{ STR0002 ,"OM010I_I" , 0 , 3},;   // Abrir OS
					{ STR0003 ,"OM010I_A" , 0 , 4},;   // Alterar
					{ STR0073 ,"FS_CONSOS" , 0 , 2} ,;  // Cons.OS
					{ STR0095 ,"Pergunte(cPerg,.t.)" , 0 , 3} ,;  // Cons.OS
					{ STR0055 ,"OM010LEG" , 0 , 2,0,.f.},;    // Legenda
					{ STR0100 ,"OM010V",0,1},;
					{ STR0115 ,"OM010L",0,6}} // Laudo na O.S.
aadd(aRotina,{STR0098,"OM010BCO",0,4}) // Banco de Conhecimento
If ExistBlock("OM010CODE") // Ponto de entrada para chamada da rotina controle de deslocamento.
	aadd(aRotina,{STR0114,"U_OM010CODE",0,4}) // Controle de Deslocamento
Endif
If cMVMIL0006 == "SCA" .AND. FindFunction("GM060PSW")
	aadd(aRotina,{ STR0036,"GM060PSW",0,2}) // "Alt. Senha - Claw"
EndIf
If ExistBlock("OM010AROT")
	aRecebe := ExecBlock("OM010AROT",.f.,.f.,{aRotina} )
	If ( ValType(aRecebe) == "A" )
		aRotina := aClone(aRecebe)
	EndIf
Endif
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SELEAGEบAutor  ณFabio               บ Data ณ  10/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona agendamento                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SELEAGE(cChassi,cCodFro,cPlaVei,cChaInt)

// Rubens 08/05/2013
// Mantive a funcao pois ้ chamada de outros fontes ...

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PECSRV    Autor  ณFabio             บ Data ณ  09/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe Requisicoes de Pecas e/ou Apontamentos deบฑฑ
ฑฑบ          ณServicos.						                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PECSRV() // Verifica se existe Requisicoes de Pecas e/ou Apontamentos de Servicos //
Local lRet    := .t.
Local cAliasVO3 := "SQLVO3"
Local cAliasVO4 := "SQLVO4"
Local cAliasVMB := "SQLVMB"
Local cAliasVG8 := "SQLVG8"
Local cAliasVGA := "SQLVGA"

DbSelectArea("VO2")
DbSetOrder(1)
If DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)
	lRet := .t. // Possui requisicoes de Pecas e/ou Apontamento de Servicos
EndIf

If GetNewPar("MV_MIL0023","N") == "S" //Permite alterar Chassi OS com Requisi็ใo antes da Libera็ใo? (S ou N)

	lRet := .t.

	cQuery := "SELECT VO3.VO3_NUMOSV "
	cQuery += "FROM "
	cQuery += RetSqlName( "VO3" ) + " VO3 "
	cQuery += "WHERE VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND VO3.VO3_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND (VO3.VO3_DATFEC <> ' ' OR VO3.VO3_DATDIS <> ' ') AND "
	cQuery += "VO3.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )

	if !( cAliasVO3 )->( Eof() )

	   lRet := .f.

	Else

		cQuery := "SELECT VO4.VO4_NUMOSV "
		cQuery += "FROM "
		cQuery += RetSqlName( "VO4" ) + " VO4 "
		cQuery += "WHERE VO4.VO4_FILIAL='"+ xFilial("VO4")+ "' AND VO4.VO4_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND (VO4.VO4_DATFEC <> ' ' OR VO4.VO4_DATDIS <> ' ') AND "
		cQuery += "VO4.D_E_L_E_T_=' '"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO4, .T., .T. )

		if !( cAliasVO4 )->( Eof() )

		   lRet := .f.

		Else

			Do Case

				Case cMVMIL0006 == "JD"

					cQuery := "SELECT VMB.VMB_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VMB" ) + " VMB "
					cQuery += "WHERE VMB.VMB_FILIAL='"+ xFilial("VMB")+ "' AND VMB.VMB_NUMOSV = '"+VO1->VO1_NUMOSV+"' " // Nao deve verificar se o registro esta deletado

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVMB, .T., .T. )

					if !( cAliasVMB )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVMB)->(dbCloseArea())

				Case cMVMIL0006 == "SCA"

					cQuery := "SELECT VG8.VG8_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VG8" ) + " VG8 "
					cQuery += "WHERE VG8.VG8_FILIAL='"+ xFilial("VG8")+ "' AND VG8.VG8_NUMOSV = '"+VO1->VO1_NUMOSV+"' "
					cQuery += " AND VG8.D_E_L_E_T_=' ' "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVG8, .T., .T. )

					if !( cAliasVG8 )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVG8)->(dbCloseArea())


				Case cMVMIL0006 == "VW" .or. cMVMIL0006 == "MAN"

					cQuery := "SELECT VGA.VGA_NUMOSV "
					cQuery += "FROM "
					cQuery += RetSqlName( "VGA" ) + " VGA "
					cQuery += "WHERE VGA.VGA_FILIAL='"+ xFilial("VGA")+ "' AND VGA.VGA_NUMOSV = '"+VO1->VO1_NUMOSV+"' "
					cQuery += " AND VGA.D_E_L_E_T_=' ' "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVGA, .T., .T. )

					if !( cAliasVGA )->( Eof() )

						lRet := .f.

					Endif

					(cAliasVGA)->(dbCloseArea())

			End Case

		Endif

		(cAliasVO4)->(dbCloseArea())

	Endif

	(cAliasVO3)->(dbCloseArea())

Endif

DbSelectArea("VO1")
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPFIC บAutor  ณFabio               บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime ficha                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_IMPFICHA()

OFIOC330(M->VO1_CHAINT)

oFldOm010:nOption := 1

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funo    | OM010V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrio | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM010V()
nOpc := 1
OFIOC450()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010L	   Autor  ณFabio             บ Data ณ  09/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLaudo na OS.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010L()
Local cObserv := space(300)
Local cAliasVO3 := "SQLVO3"
Local cAliasVO4 := "SQLVO4"
Local lAchou    := .f.
Local nOpca := 0

cQuery := "SELECT VO3.VO3_NUMOSV "
cQuery += "FROM "
cQuery += RetSqlName( "VO3" ) + " VO3 "
cQuery += " INNER JOIN "+RetSqlName("VOI")+" VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "VO3.VO3_FILIAL='"+ xFilial("VO3")+ "' AND VO3.VO3_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VOI.VOI_SITTPO = '2' AND "
cQuery += "VO3.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )

if !( cAliasVO3 )->( Eof() )
   lAchou := .t.
Endif
(cAliasVO3)->(dbCloseArea())

If !lAchou
	cQuery := "SELECT VO4.VO4_NUMOSV "
	cQuery += "FROM "
	cQuery += RetSqlName( "VO4" ) + " VO4 "
	cQuery += " INNER JOIN "+RetSqlName("VOI")+" VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery += "VO4.VO4_FILIAL='"+ xFilial("VO4")+ "' AND VO4.VO4_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VOI.VOI_SITTPO = '2' AND "
	cQuery += "VO4.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO4, .T., .T. )

	if !( cAliasVO4 )->( Eof() )
	   lAchou := .t.
	Endif
	(cAliasVO4)->(dbCloseArea())
EndIf
dbSelectArea("VO1")
if lAchou
	if Aviso(STR0116,STR0117,{STR0118,STR0119}) == 1 // Aten็ใo / O que deseja fazer com o laudo / Digitar / Imprimir

		cObserv := MSMM(VO1->VO1_LAUMEM,TamSX3("VO1_OBSLAU")[1])
		cAuxObserv := cObserv

		DEFINE MSDIALOG oLaudo TITLE STR0120 From 7,08 to 26,88      of oMainWnd  // Laudo na O.S.
		@ 008,010 GET oMsg2 VAR cObserv OF oLaudo MEMO SIZE 300,110 PIXEL
		DEFINE SBUTTON FROM 125,250 TYPE 1 ACTION ( IIf( OM010VLDM(cObserv,cAuxObserv) , ( nOpca := 1, oLaudo:End() ) , ) ) ENABLE OF oLaudo
		DEFINE SBUTTON FROM 125,280 TYPE 2 ACTION ( nOpca := 2, oLaudo:End() ) ENABLE OF oLaudo
		ACTIVATE MSDIALOG oLaudo CENTER
		if nOpca == 1
 			cObserv += Chr(13)+Chr(10)+Chr(13)+Chr(10)+"*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+DtoC(dDataBase)+"-"+Transform(time(),"@R 99:99")+"h"+" ***"
			cObserv += Chr(13)+Chr(10)+Repl("_",74)+Chr(13)+Chr(10)
			MSMM(VO1->VO1_LAUMEM,TamSx3("VO1_OBSLAU")[1],,cObserv,1,,,"VO1","VO1_LAUMEM")
		Endif
	Else
	   FS_IMPRESSAO()
	Endif
Else
   MsgStop(STR0121) // Op็ใo somente disponํvel para ordem de servi็o com tipo de tempo de garantia
   Return(.f.)
Endif
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010VLDM  | Autor |  Rubens	 	          | Data | 01/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Validacao do memo do laudo de os                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM010VLDM(cObserv,cAuxObserv)

If !Empty(cAuxObserv) .and. SubStr(cObserv,1,Len(cAuxObserv)) <> cAuxObserv
	MsgStop(STR0125)	// "Nใo ้ possํvel alterar o laudo anterior"
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPRESSAO  Autor  ณThiago           บ Data ณ  05/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do Laudo na OS.									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPRESSAO()
Local cDesc1		:= STR0120 // Laudo na O.S.
Local cDesc2 		:= ""
Local cDesc3 		:= ""
Local cAlias		:= "VO1"
Local aRegistros	:= {}
Local aRegs         := {}

Private nLin := 1
Private aPag := 1
Private nIte := 1
Private aReturn := { STR0122, 1,STR0123, 2, 2, 2, "",1 }  //Zebrado ## Administracao
Private cTamanho:= "P"           	// P/M/G
Private Limite  := 80           	// 80/132/220
Private aOrdem  := {}           	// Ordem do Relatorio
Private cTitulo := STR0124      	// Impressใo do laudo na O.S.
Private cNomProg:= "LAUDOOS"
Private cNomeRel:= "LAUDOOS"
Private nLastKey:= 0
cPergBlk := cPerg
cPerg := ""
cNomeRel := SetPrint(cAlias,cNomeRel,nil,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| FS_IMPREL(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
cPerg := cPergBlk

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPREL		Autor  ณThiago           บ Data ณ  05/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do Laudo na OS.									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPREL()

cabec1 := ""
cabec2 := ""
nLin := 1
nCaracter:=15
M_PAG := 1
nLin := cabec(ctitulo,cabec1,cabec2,cNomProg,cTamanho,nCaracter) + 1
dbSelectArea("SYP")
dbSetOrder(1)
dbSeek(xFilial("SYP")+VO1->VO1_LAUMEM)
While !Eof() .and. xFilial("SYP") == SYP->YP_FILIAL .and. VO1->VO1_LAUMEM == SYP->YP_CHAVE

	nPos := AT("\13\10",SYP->YP_TEXTO)
	if nPos > 0
		nPos -= 1
	Else
		nPos := Len(SYP->YP_TEXTO)
	Endif

	cObs := alltrim(Substr(SYP->YP_TEXTO,1,nPos))
	If !Empty(cObs)
		@ nLin , 03 psay "- " + cObs
		nlin++
	EndIf
	SYP->(DbSkip())
Enddo
Return(.t.)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010GMUT  | Autor |  Rubens	 	          | Data | 28/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Parambox de valor estimado de garantia mutua                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM010GMUT()

Local aParamBox := {}
Local aRet      := {}

If M->VO1_GARMUT <> "1"
	MsgInfo(STR0126,STR0029) // "Informar que a OS ้ de garantia mutua" / Aten็ใo!
	Return
EndIf


If Altera
	// Verifica se a OS ja possui registro de solicita็ใo de garantia
	VDF->(dbSetOrder(2))
	If VDF->(dbSeek(xFilial("VDF") + M->VO1_NUMOSV))
		MsgInfo(STR0127,STR0029) // "OS jแ possui solicita็ใo de garantia mutua" / Aten็ใo!
		nValGarMut := 0
		Return
	EndIf
EndIf

aAdd(aParamBox,{1,RetTitle("VDF_VLREST"),nValGarMut,PesqPict("VDF","VDF_VLREST"),"Positivo()","","",0,.f.}) // Valor Estimado
If ParamBox(aParamBox,STR0128,@aRet,,,,,,,,.F.,.F.) // "Garantia Mutua"
	nValGarMut := aRet[1]
EndIf

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM010WS    | Autor |  Rubens	 	          | Data | 08/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Web Service de Montadora                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM010WS(nAuxOpc,cMarca)

Local nAuxRecno
Local cAuxAlias := Alias()

If Empty(M->VO1_CHASSI)
	MsgInfo(STR0129) // "Favor informar um Chassi"
	Return
EndIf

Do Case
Case cMVMIL0006 == "JD"
	If M->VO1_CODMAR <> FMX_RETMAR("JD") .and. M->VO1_CODMAR <> FMX_RETMAR("GRS") .and. M->VO1_CODMAR <> FMX_RETMAR("PLA") .and. M->VO1_CODMAR <> FMX_RETMAR("JDC") .and. M->VO1_CODMAR <> FMX_RETMAR("HCM")
		MsgInfo(STR0130,STR0029) // "N๚mero de s้rie nใo ้ da John Deere" / Aten็ใo!
		Return
	EndIf

	nAuxRecno := VV1->(Recno())
	aRetWS := {}

	VV1->(DbSetOrder(2))
	VV1->(dbSeek( xFilial("VV1") + M->VO1_CHASSI ))
	dbSelectArea("VO1")
	OFICJD01(.t.,nAuxOpc,@aRetWS)

Case cMVMIL0006 == "SCA"

	If M->VO1_CODMAR <> FMX_RETMAR("SCA")
		MsgInfo(STR0096,STR0029) // "Chassi nใo ้ da marca Scania." / Aten็ใo!
		Return
	EndIf

	nAuxRecno := VV1->(Recno())
	VV1->(DbSetOrder(2))
	VV1->(dbSeek( xFilial("VV1") + M->VO1_CHASSI ))
	dbSelectArea("VO1")
	OFICSC01(.t.,nAuxOpc,,.f.)
End
If Empty(cAuxAlias)
	cAuxAlias := "VO1"
Endif
dbSelectArea(cAuxAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM010IMPGAR บAutor  ณ Rubens Takahashiบ Data ณ  08/07/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta para garantia                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM010IMPGAR()

Local cFunExp := ""
Local ix1
Local cSQL
Local nAuxRecno := OM010VE4RECNO(VO1->VO1_CODMAR)

If nAuxRecno == 0
	Return .t.
EndIf
VE4->(dbGoTo(nAuxRecno))

If FG_SEEK("VEG","VE4->VE4_FOREXP",1,.f.)
	//
	cFunExp := Alltrim(VEG->VEG_FORMUL)
	//

	ix1 := At("(",cFunExp)
	If ix1 <> 0
		cFunExp := Left(cFunExp,ix1) + "'A','','','',aRetWS)"
	EndIf
	// Funcao de Importacao para Garantia
	lMsHelpAuto := .f.
	If !FG_VERFORGAR(cFunExp)
		lMsHelpAuto := .t.
		Return .f.
	EndIf
	//
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010FEC  บAutor  ณThiago              บ Data ณ  18/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada do fechamemto.             	                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010FEC()
Private nOpc := 2
Private cGetVersao := GetVersao(.f.) // "P10" ou "11"

If cGetVersao == "P10"
	OFIOM160(.f.)
Else
	OFIXA100(.T.)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATUKMJD   บAutor  ณCarla               บ Data ณ  09/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada na Alteracao da O.S.       	                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ATUKMJD()

Local cSql      := ""
Local nRecnoVMB := 0

If TCCanOpen( RetSqlName( "VMB" ) )//Cabecalho Garantia JD.

   cSql := " SELECT VMB.R_E_C_N_O_ "
   cSql += " FROM " + RetSqlName("VMB") + " VMB "
   cSql += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "' AND "
   cSql += "       VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "' AND "
   cSql += "       VMB_STATUS IN ( '  ', '01' ) AND " // Nao enviada
   cSql += "       D_E_L_E_T_ = ' ' "

   nRecnoVMB := FM_SQL( cSql )

   If ( nRecnoVMB ) > 0

	  VMB->( DbGoto( nRecnoVMB ) )
	  Reclock("VMB")
	  VMB->VMB_QTDUTI := M->VO1_KILOME
	  MsUnlock()

   Endif

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM010BCO  บAutor  ณ Andre Luis Almeida บ Data ณ  02/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Banco de Conhecimento da OS       	                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM010BCO()
If !Empty(VO1->VO1_NUMOSV)
	cAlias := "VO1"
	nOpc := aScan( aRotina , { |x| x[2] == "OM010BCO" } )
	nReg := VO1->(RecNo())
	FGX_MSDOC(cAlias,nReg,nOpc)
EndIf
Return()


/*/{Protheus.doc} OM010SIMU
Habilita modo de simula็ใo de Garantia
@author Rubens
@since 16/11/2017
@version 1.0
@return lRetorno , logical , Habilita modo de simulacao

@type function
/*/
Static Function OM010SIMU()
	If cEmpAnt <> "99" .or. ! FindFunction("OFNJD15SIMU")
		Return .f.
	EndIf
Return OFNJD15SIMU()

/*/{Protheus.doc} OM010TPATEN
Valida็ใo da associa็ใo de Tipo de Atendimento ao Tipo de Tempo
@author Fernando V. Cavani
@since 26/01/2018
@version undefined
@type function
/*/
Function OM010TPATEN(cTipAte,cNumOSv,lMsg)
Local aTipTem 	 := {}
Local oSqlHelper := Dms_SqlHelper():New()
Local oArrHlp 	 := DMS_ArrayHelper():New()
Local lConsidera := .f.

Default cTipAte := ""
Default cNumOSv := ""
Default lMsg 	:= .t.

If VOI->(FieldPos("VOI_CONVCP")) > 0 .And. !Empty(cNumOSv)
	// Pe็as e Servi็os
	cQuery := "SELECT VO3.VO3_TIPTEM "
	cQuery += "FROM " + RetSQLName("VO3") + " VO3 "
	cQuery += " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.VOI_CONVCP = '1' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "' "
	cQuery +=   "AND VO3.VO3_DATCAN = ' ' "
	cQuery +=   "AND VO3.VO3_NUMOSV = '" + cNumOSv + "' "
	cQuery +=   "AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " UNION "
	cQuery += "SELECT VO4.VO4_TIPTEM "
	cQuery += "FROM " + RetSQLName("VO4") + " VO4 "
	cQuery += " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.VOI_CONVCP = '1' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' "
	cQuery +=   "AND VO4.VO4_DATCAN = ' ' "
	cQuery +=   "AND VO4.VO4_NUMOSV = '" + cNumOSv + "' "
	cQuery +=   "AND VO4.D_E_L_E_T_ = ' ' "

	aTipTem := oSqlHelper:GetSelectArray(cQuery)

	If !Empty(aTipTem)
		lConsidera := .t.
	EndIf
EndIf

If !lConsidera
	Return(.t.)
EndIf

cQuery := "SELECT COUNT(VCP.R_E_C_N_O_) "
cQuery += "FROM " + RetSqlName("VCP") + " VCP "
cQuery += "WHERE VCP.VCP_FILIAL = '" + xFilial("VCP") + "' "
cQuery +=   "AND VCP.VCP_TPATEN = '" + cTipAte + "' "
cQuery +=   "AND VCP.VCP_TIPTEM IN ('" + oArrHlp:Join(aTipTem, "','") + "') "
cQuery +=   "AND VCP.D_E_L_E_T_ = ' ' "

nRecVCP := FM_SQL(cQuery)

If nRecVCP == 0
	If lMsg
		Help(1,"  ","TPTEMATE")
	EndIf

	Return(.f.)
EndIf
Return(.t.)


/*/{Protheus.doc} OM010VE4RECNO
Retorna o RECNO do Registro da Tabela VE4 que deverแ ser utilizado na importacao da Garantia 
@author Rubens
@since 16/08/2018
@version 1.0
@return nAuxRecno, RECNO da VE4
@param cPesqCodMar, characters, descricao
@type function
/*/
Static Function OM010VE4RECNO(cPesqCodMar)

	Local cSQL
	Local nAuxRecno

	If cMVMIL0006 == "JD"
		cSQL := ;
			"SELECT VE4.R_E_C_N_O_" +;
			" FROM (" +;
					"SELECT VE1_1.VE1_CODMAR, '0' ORDEM " +;
					 " FROM " + RetSQLName("VE1") + " VE1_1 " +;
					" WHERE VE1_1.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
					  " AND VE1_1.VE1_CODMAR = '" + cPesqCodMar + "' " +;
					  " AND VE1_1.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
					  " AND VE1_1.D_E_L_E_T_ =  ' '  " +;
					" UNION " +;
					"SELECT VE1_2.VE1_CODMAR, '1' ORDEM " +;
					 " FROM " + RetSQLName("VE1") + " VE1_2 " +;
					" WHERE VE1_2.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
					  " AND VE1_2.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM') " +;
					  " AND VE1_2.D_E_L_E_T_ =  ' '  " +;
					") " +;
			" TMPFILTRO JOIN " + RetSQLName("VE4") + " VE4 ON VE4.VE4_FILIAL = '" + xFilial("VE4") + "' " +;
																	  " AND VE4.VE4_PREFAB = TMPFILTRO.VE1_CODMAR " +;
																	  " AND VE4.VE4_QDOIMP = '3'" +;
																	  " AND VE4.VE4_FOREXP <> ' '" +;
																	  " AND VE4.D_E_L_E_T_ = ' '" +;
			" ORDER BY TMPFILTRO.ORDEM , VE4.R_E_C_N_O_"
	Else
		cSQL := ;
			"SELECT R_E_C_N_O_ " + ;
			 " FROM " + RetSQLName("VE4") + " VE4 " +;
			" WHERE VE4.VE4_FILIAL = '" + xFilial("VE4") + "'" +;
			  " AND VE4.VE4_PREFAB = '" + cPesqCodMar + "'" +;
			  " AND VE4.VE4_QDOIMP = '3'" +;
			  " AND VE4.D_E_L_E_T_ = ' '"
	EndIf

	nAuxRecno := FM_SQL(cSQL)

Return nAuxRecno



Function OM010VLDENC()
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ''
Local lRet    := .t.

If ReadVar() == "M->VO1_HORABE"

	cQuery := "SELECT VO1_HORABE, VO1_CHASSI, VO1_DATABE, R_E_C_N_O_ FROM " + RetSQLName("VO1")
	cQuery += " WHERE "
	cQuery += " VO1_FILIAL = '" + xFilial("VO1") + "' AND"
	cQuery += " VO1_CHASSI = '"+M->VO1_CHASSI+"'  AND"
	cQuery += " VO1_DATABE = '"+Dtos(M->VO1_DATABE)+"' AND"
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VO1_DATABE, VO1_HORABE, R_E_C_N_O_ DESC"
	cQuery := oSqlHlp:TOPFunc(cQuery, 1)
	nRetHor := FM_SQL(cQuery)
	If M->VO1_HORABE == nRetHor
		Help("  ",1,"HORAINVALIDA",,CRLF+STR0138,4,1) // "Jแ existe Ordem de Servi็o para esse Chassi com mesma Data e Hora de Abertura! Impossivel continuar!"
		lRet := .f.
	Endif

Endif

return lRet

/*/{Protheus.doc} OM010ALTVFB
Atualiza dados da VFB na altera็ใo da Ordem de Servi็o
@author Jose Silveira
@since 09/11/2021
@version 1.0
@param cCodCli, cCodLoj, cChaInt, cNumOsv, nKilome
@type function
/*/
Static Function OM010ALTVFB(cCodCli,cCodLoj,cChaInt,cNumOsv,nKilome)

Local cAliasVFB := "SQLVFB"

If !Empty(cNumOSv)
	cQuery := "SELECT VFB.R_E_C_N_O_ AS RECVFB "
	cQuery += "FROM "
	cQuery += RetSqlName( "VFB" ) + " VFB "
	cQuery += "WHERE "
	cQuery += "VFB.VFB_FILIAL='"+ xFilial("VFB")+ "' AND VFB.VFB_NUMOSV = '"+cNumOsv+"' AND "
	cQuery += "VFB.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )

	Do While !( cAliasVFB )->( Eof() )

		dbSelectArea("VFB")
		VFB->(dbGoTo(( cAliasVFB )->RECVFB))
		If !RecLock("VFB",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VFB->VFB_CHAINT := cChaInt
		VFB->VFB_CODCLI := cCodCli
		VFB->VFB_LOJA   := cCodLoj
		VFB->VFB_KILOME := nKilome

		MsUnlock()

		( cAliasVFB )->(DbSkip())

	EndDo
	( cAliasVFB )->(dbCloseArea())
Endif

Return .t.