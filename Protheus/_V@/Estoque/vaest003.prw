#include "Protheus.ch"

/* 
 * CRIAR PARAMETROS
 * ----------------
 * Parametro:     VA_MOVBATI
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest003. Tipo de movimento (SF5) utilizado para apontamento automatizado de batida.
 *
 * Parametro:     VA_CCPRDBA
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest003. Centro de custo utilizado para apontamento automatizado da batida. 
 * 
 * Parametro:     VA_ICPRDBA
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest003. Item contabil utilizado para apontamento automatizado da batida. 
 * 
 * Parametro:     VA_CLPRDBA
 * Tipo:          C
 * Descri��o:     Par�metro customizado usado pela rotina vaest003. Classe de valor utilizado para apontamento automatizado da batida. 
 */

static nPEmpCod := 1
static nPEmpLoc := 2
static nPEmpQtd := 3
static nPEmpCtl := 4

/*/{Protheus.doc} vaest003

 Apontamento de batida

@type function
@author JRScatolon Informatica

@param cCodPro, Caractere, N�mero da ordem de produ��o
@param nQuant, Caractere, Quantidade a ser produzida
@param cArmz, Local onde ser� depositada a ordem de produ��o
@param aEmpenho, Matriz, Matriz bidimensional no formato { {<Cod Produto>, <Armazem>, <Quantidade empenhada>} '[', {<Cod Produto>, <Local>, <Quantidade>}']' }

@return numero da ordem de produ��o

@obs Caso seja criada a vari�vel cNumOP como privada essa fun��o ir� preencher o numero da ordem de produ��o no momento de sua cria��o
@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/\
user function vaest003(cCodPro, nQuant, cArmz, aEmpenho)
	local aArea 	:= GetArea()
	local cMovBat 	:= GetMV("VA_MOVBATI")
	local cCC 		:= GetMV("VA_CCPRDBA")
	Local cIC		:= GetMV("VA_ICPRDBA")
	Local cClvl		:= GetMV("VA_CLPRDBA")


	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodPro))
	If aScan(aEmpenho,{|x| Alltrim(x[1]) == Alltrim(SB1->B1_XCODAPR)}) == 0
		aAdd( aEmpenho, { SB1->B1_XCODAPR , SB1->B1_LOCPAD , nQuant } )
	Endif

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
		cMsg := "[VAEST021] Cria OP: " + AllTrim(cCodPro),;
		.T./* lConOut */,;
					  /* lAlert */ )
		cNumOP := ""
	FWMsgRun(, {|| cNumOp := u_CriaOp(cCodPro, nQuant, cArmz) },;
		"Processando [VAEST003]",;
		cMsg )
	u_LimpaEmp(cNumOp)
	u_AjustEmp(cNumOp, aEmpenho)

	U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
		cMsg := "Apontamento OP: " + AllTrim(cNumOp),;
		.T./* lConOut */,;
					  /* lAlert */ )
		FWMsgRun(, {|| u_ApontaOP(cNumOp, cMovBat, cCC, cIC, cClvl)},;
		"Processando [VAEST003]",;
		cMsg )

	if !Empty(aArea)
		RestArea(aArea)
	endif
return cNumOp

/*/{Protheus.doc} CriaOP

 Cria��o de Ordem de Produ��o

@type function
@author JRScatolon Informatica

@param cCodPro, Caractere, N�mero da ordem de produ��o
@param nQuant, Caractere, Quantidade a ser produzida
@param [cArmz], Local onde ser� depositada a ordem de produ��o

@return Caractere, N�mero da ordem de produ��o criado.

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
user function CriaOP(cCodPro, nQuant, cArmz,cExplode)
	local aArea := GetArea()
	local cOP := ""
	local aOP := {}
	local cCodFil := xFilial("SC2")
	Local i    := 0
	local aErroAuto := {}
	local cErroAuto := ""

	private lMsErroAuto := .f.
	private lMsHelpAuto := .t.
	private lAutoErrNoFile := .t.

	Default cExplode := 'S'

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL + B1_COD

	if SB1->(DbSeek(xFilial("SB1")+cCodPro))

		if Empty(cArmz)
			if Empty(cArmz := Iif(!Empty(SB1->B1_LOCPAD), SB1->B1_LOCPAD, StrZero(1, TamSX3("B1_LOCPAD")[1])))
				MsgStop("N�o foi preenchido o armazem padr�o, nem indicado em qual armazem deve-se apontar a produ��o de [" + AllTrim(cCodPro) + "]. Por favor, verifique o cadastro de produtos indicando o local padr�o desse produto.")
			endif
		endif

		cOP := GetSXENum("SC2", "C2_NUM")
		ConfirmSX8()

		aOP := { {"C2_FILIAL",  cCodFil,    Nil},;
				{"C2_NUM",     cOP,     	Nil},;
				{"C2_ITEM",    "01",       Nil},;
				{"C2_SEQUEN",  "001",      Nil},;
				{"C2_PRODUTO", cCodPro,    Nil},;
				{"C2_LOCAL",   cArmz,      Nil},;
				{"C2_QUANT",   nQuant,     Nil},;
				{"C2_UM",      SB1->B1_UM, Nil},;
				{"C2_DATPRI",  dDataBase,  Nil},;
				{"C2_DATPRF",  dDataBase,  Nil},;
				{"C2_EMISSAO", dDataBase,  Nil},;
				{"C2_PRIOR",   "500",      Nil},;
				{"C2_DESTINA", "P",        Nil},;
				{"C2_SEQPAI",  "000",      Nil},;
				{"C2_IDENT",   "P",        Nil},;
				{"C2_TPOP",    "F",        Nil},;
				{"C2_GRADE",   "N",        Nil},;
				{"AUTEXPLODE", cExplode,   Nil} }

		lMsErroAuto :=.F.
		MSExecAuto({|x,y| MATA650(x,y)}, aOP, 3)  //Inclusao

		if lMsErroAuto
			cLogFile := CriaTrab(,.f.) + ".log"
			aErroAuto := GetAutoGRLog()
			for i := 1 to Len(aErroAuto)
				cErroAuto += aErroAuto[i] + CRLF
			next

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
				"ERRO4: "+cErroAuto,;
				.T./* lConOut */,;
						  /* lAlert */ )

			MemoWrite(cLogFile, cErroAuto)
			RestArea(aArea)
			MsgStop("Ocorreu um erro durante a execu��o da rotina autom�tica MATA650 - Ordem de produ��o.")
		endif

	else
		MsgStop("Produto [" + cCodPro + "] n�o cadastrado." )
	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif
return cOP

/*/{Protheus.doc} ApontaOP

Efetua o apontamento da ordem de produ��o

@type function
@author JRScatolon Informatica 

@param cOP, Caracter, N�mero da ordem de produ��o
@param cTpMov, Caracter, Tipo de movimenta��o usado na produ��o
@param cCC, Caracter, C�digo do centro de custo a ser valorizado pela OP
@param cIC, Caracter, C�digo do item contabil a ser valorizado pela OP
@param cClvl, Caracter, C�digo da classe de valor a ser valorizada pela OP

@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
user function ApontaOP(cOP, cTpMov, cCC, cIC, cClvl, cLoteCTL, cCurral )
	local aArea 			:= GetArea()
	local aApon 			:= {}
	local i, nLen
	local lRet 				:= .T.

	local aErroAuto 		:= {}
	local cErroAuto 		:= ""

	private lMsErroAuto 	:= .f.
	private lMsHelpAuto 	:= .t.
	private lAutoErrNoFile 	:= .t.

	Default cLoteCTL     	:= ""
	Default cCurral		 	:= ""

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	DbSelectArea("SD3")
	DbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_SEQUEN + C2_ITEMGRD

	if DbSeek(xFilial("SC2")+cOP)

    /* aApon := { {"D3_TM",      cTpMov,          nil},;
    		   {"D3_OP",      SC2->C2_NUM+SC2->C2_ITEM+C2_SEQUEN, nil },;
               {"D3_LOTECTL", cLoteCTL, nil		},;
			   {"D3_DTVALID", iIF(Empty(cLoteCTL),sToD(""),SB8->B8_DTVALID), nil } }
     */
	/*
               {"D3_COD",     SC2->C2_PRODUTO, nil},;
               {"D3_UM",      SC2->C2_UM,      nil},;
               {"D3_LOCAL",   SC2->C2_LOCAL,   nil},;
               {"D3_QUANT",   SC2->C2_QUANT,   nil},;
               
               {"D3_EMISSAO", dDataBase,       nil},;
               {"D3_CC",      cCC,             nil},;
               {"D3_ITEMCTA", cIC, nil			},;
               {"D3_CLVL",    cClvl, nil		},;
    */

		aAdd( aApon, {"D3_TM"		, cTpMov									, nil } )
		aAdd( aApon, {"D3_OP"		, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN  	, nil } )

		If Empty(cLoteCTL)
			aAdd( aApon, {"D3_COD"		, SC2->C2_PRODUTO						, nil } )
			aAdd( aApon, {"D3_UM"		, SC2->C2_UM	 						, nil } )
			aAdd( aApon, {"D3_LOCAL"	, SC2->C2_LOCAL							, nil } )
			aAdd( aApon, {"D3_QUANT"	, SC2->C2_QUANT							, nil } )
			aAdd( aApon, {"D3_EMISSAO"	, dDataBase								, nil } )
			aAdd( aApon, {"D3_CC"		, cCC									, nil } )
			aAdd( aApon, {"D3_ITEMCTA"	, cIC									, nil } )
			aAdd( aApon, {"D3_CLVL"		, cClvl									, nil } )
		Else

			_cB8_PRODUTO := POSICIONE( 'SB8', 7, XFILIAL('SB8') + cLoteCTL + cCurral, 'B8_PRODUTO')

			aAdd( aApon, {"D3_COD"		, _cB8_PRODUTO						    , nil } )
			aAdd( aApon, {"D3_LOTECTL"  , cLoteCTL							    , nil } )
			aAdd( aApon, {"D3_X_CURRA"  , cCurral							    , nil } )
			aAdd( aApon, {"D3_DTVALID"  , iIf(Empty(cLoteCTL),sToD(""),SB8->B8_DTVALID), nil } )
			if !Empty(SB8->B8_X_CURRA)
				aAdd( aApon, {"D3_X_CURRA", SB8->B8_X_CURRA, nil} )
			endif
		EndIf

		FG_X3ORD("C", , aApon )
		// ConOut(u_atOs(aApon))

		MSExecAuto( { |x,y| MATA250(x,y) }, aApon, 3 ) //3-Inclusao
		if lMsErroAuto
			lRet := .f.
			cLogFile := CriaTrab(,.f.) + ".log"
			aErroAuto := GetAutoGRLog()
			for i := 1 to Len(aErroAuto)
				cErroAuto += aErroAuto[i] + CRLF
			next

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
				"ERRO5: "+cErroAuto,;
				.T./* lConOut */,;
						  /* lAlert */ )

			MemoWrite(cLogFile, cErroAuto)
			RestArea(aArea)
			MsgStop("Ocorreu um erro durante a execu��o da rotina autom�tica MATA250 - Apontamento de produ��o.")
		endIf

		// U_ExecProd(aApon)

	else
		lRet := .f.
		MsgStop("Ordem de produ��o [" + cOP + "] n�o encontrada. N�o � poss�vel efetuar os apontamentos de produ��o. Por favor verifique!!!")
	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif

return lRet

/*/{Protheus.doc} EncerOP

Encerra uma ordem de produ��o e estorna seus apontamentos, de acordo com os parametros

@type function
@author JRScatolon Informatica 

@param cOP, Caracter, N�mero da ordem de produ��o

@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
user function EncerrOP(cOP)
	local aArea := GetArea()
	local nSaldo := 0
	Local i := 0
	local aErroAuto := {}
	local cErroAuto := ""

	private lMsErroAuto := .f.
	private lMsHelpAuto := .t.
	private lAutoErrNoFile := .t.

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SD3")
	DbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

	if !SC2->(DbSeek(xFilial("SC2")+cOP))
		MsgStop("Ordem de produ��o [" + cOP + "] n�o encontrada. N�o � poss�vel encerrar a OP.")
	endif

	if !Empty(SC2->C2_DATPRF)
		MsgStop("Ordem de produ��o [" + cOP + "] j� se encontra ecerrada. N�o � poss�vel encerrar a OP.")
	endif

	if SD3->(DbSeek(xFilial("SD3")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+SC2->C2_PRODUTO+SC2->C2_LOCAL))

		aApon := { {"D3_FILIAL",  SD3->D3_FILIAL,  nil},;
			{"D3_TM",      SD3->D3_TM,      nil},;
			{"D3_COD",     SD3->D3_COD,     nil},;
			{"D3_UM",      SD3->D3_UM,      nil},;
			{"D3_LOCAL",   SD3->D3_LOCAL,   nil},;
			{"D3_QUANT",   SD3->D3_QUANT,   nil},;
			{"D3_OP",      SD3->D3_OP,      nil},;
			{"D3_EMISSAO", SD3->D3_EMISSAO, nil},;
			{"D3_CC",      SD3->D3_CC,      nil},;
			{"D3_LOTECTL", SD3->D3_LOTECTL, nil} }

		MSExecAuto( { |x,y| MATA250(x,y) }, aApon, 7 ) //"Encerrar"

		if lMsErroAuto
			lRet := .f.
			cLogFile := CriaTrab(,.f.) + ".log"
			aErroAuto := GetAutoGRLog()
			for i := 1 to Len(aErroAuto)
				cErroAuto += aErroAuto[i] + CRLF
			next

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
				"ERRO6: "+cErroAuto,;
				.T./* lConOut */,;
						  /* lAlert */ )

			MemoWrite(cLogFile, cErroAuto)
			RestArea(aArea)
			MsgStop("Ocorreu um erro durante a execu��o da rotina autom�tica MATA250 - Estorno do Apontamento de produ��o.")
		endif

	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif
return nil

user function EstornOP(cOP)
	local aArea := GetArea()
	local nSaldo := 0
	Local i := 0
	local aErroAuto := {}
	local cErroAuto := ""

	private lMsErroAuto := .f.
	private lMsHelpAuto := .t.
	private lAutoErrNoFile := .t.

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SD3")
	DbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

	if !SC2->(DbSeek(xFilial("SC2")+cOP))
		MsgStop("Ordem de produ��o [" + cOP + "] n�o encontrada. N�o � poss�vel encerrar a OP.")
	endif

	if SC2->C2_QUJE <> 0

		if SB2->(DbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL)) .and.;
				(nSaldo := SaldoSB2()) < SC2->C2_QUJE
			MsgStop("N�o existe saldo suficiente em estoque de [" + AllTrim(SC2->C2_PRODUTO) + "] no armazem [" + SC2->C2_LOCAL + "] para atender ao estorno da ordem de produ��o [" + cOP + "]. N�o � possivel realizar o estorno da OP.")
		endif

		if SD3->(DbSeek(xFilial("SD3")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+SC2->C2_PRODUTO+SC2->C2_LOCAL))
			aApon := { {"D3_FILIAL",  SD3->D3_FILIAL,  nil},;
				{"D3_TM",      SD3->D3_TM,      nil},;
				{"D3_COD",     SD3->D3_COD,     nil},;
				{"D3_UM",      SD3->D3_UM,      nil},;
				{"D3_LOCAL",   SD3->D3_LOCAL,   nil},;
				{"D3_QUANT",   SD3->D3_QUANT,   nil},;
				{"D3_OP",      SD3->D3_OP,      nil},;
				{"D3_EMISSAO", SD3->D3_EMISSAO, nil},;
				{"D3_CC",      SD3->D3_CC,      nil},;
				{"D3_LOTECTL", SD3->D3_LOTECTL, nil} }

			MSExecAuto( { |x,y| MATA250(x,y) }, aApon, 5 ) //"Estornar"
			if lMsErroAuto
				lRet := .f.
				cLogFile := CriaTrab(,.f.) + ".log"
				aErroAuto := GetAutoGRLog()
				for i := 1 to Len(aErroAuto)
					cErroAuto += aErroAuto[i] + CRLF
				next

				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
					"ERRO7: "+cErroAuto,;
					.T./* lConOut */,;
						  /* lAlert */ )

				MemoWrite(cLogFile, cErroAuto)
				RestArea(aArea)
				MsgStop("Ocorreu um erro durante a execu��o da rotina autom�tica MATA250 - Estorno do Apontamento de produ��o.")
			endif
		endif

	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif
return nil

/*/{Protheus.doc} ExclOP
    Exclui a ordem de produ��o (SC2) passada pelo parametro cOP.
@param cOP, Caractere, Numero da ordem de produ��o
@return nil
@obs A fun��o lan�ar� uma excess�o em caso de erro.
@author JRScatolon Informatica 
/*/
user function ExclOP(cOP)
	local aArea := GetArea()
	local aOP := {}
	local cCodFil := xFilial("SC2")
	Local i    := 0
	local aErroAuto := {}
	local cErroAuto := ""

	private lMsErroAuto := .f.
	private lMsHelpAuto := .t.
	private lAutoErrNoFile := .t.

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
	EndIf

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL + B1_COD

	if !SC2->(DbSeek(xFilial("SC2")+cOP+"01001"))
		MsgStop("Ordem de produ��o [" + cOP+"01001" + "] n�o encotrada. N�o � poss�vel excuir a Ordem de Produ��o.")
	endif

	aOP := { {"C2_FILIAL",  SC2->C2_FILIAL,  nil},;
		{"C2_NUM",     SC2->C2_NUM,     nil},;
		{"C2_ITEM",    SC2->C2_ITEM,    nil},;
		{"C2_SEQUEN",  SC2->C2_SEQUEN,  nil},;
		{"C2_PRODUTO", SC2->C2_PRODUTO, nil},;
		{"C2_LOCAL",   SC2->C2_LOCAL,   nil},;
		{"C2_QUANT",   SC2->C2_QUANT,   nil},;
		{"C2_UM",      SC2->C2_UM,      nil},;
		{"C2_DATPRI",  SC2->C2_DATPRI,  nil},;
		{"C2_DATPRF",  SC2->C2_DATPRF,  nil},;
		{"C2_EMISSAO", SC2->C2_EMISSAO, nil},;
		{"C2_PRIOR",   SC2->C2_PRIOR,   nil},;
		{"C2_DESTINA", SC2->C2_DESTINA, nil},;
		{"C2_SEQPAI",  SC2->C2_SEQPAI,  nil},;
		{"C2_IDENT",   SC2->C2_IDENT,   nil},;
		{"C2_TPOP",    SC2->C2_TPOP,    nil},;
		{"C2_GRADE",   SC2->C2_GRADE,   nil} }

	lMsErroAuto :=.F.
	MSExecAuto({|x,y| MATA650(x,y)}, aOP, 5)  //Exclus�o

	if lMsErroAuto
		cLogFile := CriaTrab(,.f.) + ".log"
		aErroAuto := GetAutoGRLog()
		for i := 1 to Len(aErroAuto)
			cErroAuto += aErroAuto[i] + CRLF
		next

		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
			"ERRO8: "+cErroAuto,;
			.T./* lConOut */,;
						  /* lAlert */ )

		MemoWrite(cLogFile, cErroAuto)
		RestArea(aArea)
		MsgStop("Ocorreu um erro durante a execu��o da rotina autom�tica MATA650 - Ordem de produ��o.")
	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif

return nil

/*/{Protheus.doc} AjustEmp 
    Cria registro de empenho na tabela SD4 e atualiza os dados das tabelas de suporte.
@type function
@author JRScatolon Informatica 

@param cOP, Caractere, Numero da ordem de produ��o
@param aEmpenho, Matriz, Matriz bidimensional no formato { {<Cod Produto>, <Armazem>, <Quantidade empenhada>} '[', {<Cod Produto>, <Local>, <Quantidade>}']' }
@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
@obs O produto ser� empenhado mesmo n�o havendo saldo em estoque. A rotina de produ��o, atrav�s do parametro MV_ESTNEG ser� responsavel pelo tratamento das movimenta��es de estoque. 
/*/
user function AjustEmp(cOP, aEmpenho)
	local aArea := GetArea( )
	local aEmp := {}
	local i, nLen
	local lRet := .t.

	local aErroAuto := {}
	local cErroAuto := ""

	private lMsErroAuto := .f.
	private lMsHelpAuto := .t.
	private lAutoErrNoFile := .t.

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

	if SC2->(DbSeek(xFilial("SC2")+cOP+"01001"))

		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL + B1_COD

		DbSelectArea("SD4")
		DbSetOrder(1) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL

		nLen := Len(aEmpenho)
		for i := 1 to nLen

			if !SB1->(DbSeek(xFilial("SB1")+aEmpenho[i][nPEmpCod]))
				MsgStop("Produto [" + aEmpenho[i][nPEmpCod] + "] n�o encontrado. N�o � possivel efetuar o empenho.")
			endif
			aEmp := {}

			aAdd( aEmp, {"D4_FILIAL" , xFilial("SD4")		  , nil} )
			aAdd( aEmp, {"D4_COD"    , aEmpenho[i][nPEmpCod], nil} )
			aAdd( aEmp, {"D4_LOCAL"  , aEmpenho[i][nPEmpLoc], nil} )
			aAdd( aEmp, {"D4_OP"     , cOP+"01001"		  , nil} )
			aAdd( aEmp, {"D4_DATA"   , dDataBase		      , nil} )
			aAdd( aEmp, {"D4_QTDEORI", aEmpenho[i][nPEmpQtd], nil} )
			aAdd( aEmp, {"D4_QUANT"  , aEmpenho[i][nPEmpQtd], nil} )

			if Len(aEmpenho[i]) > 3
				aAdd( aEmp, {"D4_LOTECTL", aEmpenho[i][nPEmpCtl], nil} )
				aAdd( aEmp, {"D4_DTVALID", Iif(Empty(aEmpenho[i][nPEmpCtl]),stoD(""),SB8->B8_DTVALID), nil} )
			EndIf

			AjuEMp(aEmp)

		next
	endif
	if !Empty(aArea)
		RestArea( aArea )
	endif
return lRet

/*/{Protheus.doc} LimpaEmp
    Atualiza os dados das tabelas de suporte e remove registro de empenho na tabela SD4.

@type function
@author JRScatolon Informatica 

@param cOP, Numero da Ordem de produ��o (sem item e sequencia)
@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
user function LimpaEmp(cOP)
	local aArea := GetArea( )
	local lRet := .t.

	DbSelectArea("SD4")
	DbSetOrder(2) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL

	while SD4->(DbSeek(xFilial("SD4")+PadR(cOP+"01001", TamSX3("D4_OP")[1])))
		LimpaEmp()
	end

	if !Empty(aArea)
		RestArea( aArea )
	endif
return lRet

/*/{Protheus.doc} AjuEmp 
    Fun��o Estatica. Cria registro de empenho na tabela SD4 e atualiza os dados das tabelas de suporte.
@type function
@author JRScatolon Informatica 

@param aEmp, Matriz bidimensional no formato { {<Campo SD4>, <Valor referente>, nil} '[', {<Campo SD4>, <Valor referente>, nil}']' }
@return nil

@obs A fun��o lan�ar� uma excess�o em caso de erro.
/*/
static function AjuEmp(aEmp)
	local aArea := GetArea()
	local i, nLen
	local aTravas    :={}
	local lLocaliza := .f.
	local nQtdeEmp := 0
	local nQtde2UM := 0

	private cLoteAnt := Criavar("D4_NUMLOTE")
	private cLotCtlAnt := Criavar("D4_LOTECTL")
	private nQtdAnt := 0
	private nQtdAnt2UM := 0
	private cLocal := Criavar("D4_LOCAL")
	private nQtdOriAnt := 0


	DbSelectArea("SD4")
	DbSetOrder(1) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL

	RegToMemory("SD4", .t.)

	nLen := Len(aEmp)
	for i := 1 to nLen
		&("M->"+aEmp[i][1]) := aEmp[i][2]
	next

	RecLock("SD4", .t.)
	u_GrvCPO("SD4")
	MsUnlock()

	aSerie := { {SD4->D4_QUANT, CriaVar("DC_LOCALIZ"), CriaVar("DC_NUMSERI"), SD4->D4_QTSEGUM, .F.} }

	if (lLocaliza := Localiza(SD4->D4_COD))
		A380DigLoc(@aSerie)

		nQtdeEmp := 0
		nQtde2UM := 0

		nLen := Len(aSerie)
		for i := 1 to nLen
			if !(aSerie[i][Len(aSerie[i])])
				nQtdeEmp += aSerie[nFor,1]
				nQtde2UM += aSerie[nFor,4]
			endif
		next nFor

		if QtdComp(nQtdeEmp) < QtdComp(SD4->D4_QUANT)
			AAdd(aSerie,{SD4->D4_QUANT-nQtdeEmp, CriaVar("DC_LOCALIZ"), CriaVar("DC_NUMSERI"), SD4->D4_QTSEGUM-nQtde2UM, .f.})
		endif
	endif

	nLen := Len(aSerie)
	for i := 1 to nLen
		// GravaEmp(cProduto,cLocal,nQtd,nQtd2UM,cLoteCtl,cNumLote,cLocaliza,cNumSerie,cOP,cTrt,cPedido,cItem,cOrigem,cOPOrig,dEntrega,aTravas,lEstorno,lProj,lEmpSB2,lGravaSD4,lConsVenc,lEmpSB8SBF,lCriaSDC,lEncerrOp,cIdDCF,aSalvCols,nSG1,lOpEncer,cTpOp,cCAT83, dDtEmissao)
		GravaEmp(SD4->D4_COD,; // cProduto
		SD4->D4_LOCAL,; // cLocal
		SD4->D4_QUANT,; // nQtd
		ConvUM(SD4->D4_COD,SD4->D4_QUANT,0,2),; // nQtd2UM
		SD4->D4_LOTECTL,; // cLoteCtl
		SD4->D4_NUMLOTE,; // cNumLote
		aSerie[i][3],; // cLocaliza
		aSerie[i][4],; // cNumSerie
		SD4->D4_OP,; // cOP
		SD4->D4_TRT,; // cTrt
		nil,;   // cPedido
		nil,;   // cItem
		"SC2",; // cOrigem
		nil,;   // cOPOrig
		SD4->D4_DATA,; // dEntrega
		@aTravas,; // aTravas
		.f.,; // lEstorno
		nil,; // lProj
		.t.,; // lEmpSB2
		.f.,; // lGravaSD4
		GetMV('MV_LOTVENC')=='S',; // lConsVenc
		!Empty(SD4->D4_LOTECTL+SD4->D4_NUMLOTE) .or. lLocaliza,; // lEmpSB8SBF
		!Empty(SD4->D4_LOTECTL+SD4->D4_NUMLOTE) .or. lLocaliza) // lCriaSDC
		MaDesTrava(aTravas)
	next

	if !Empty(aArea)
		RestArea(aArea)
	endif
return nil

/*/{Protheus.doc} LimpaEmp

    Desfaz os empenhos e exclui os registros posicionados da tabela SD4

@type function
@author JRScatolon Informatica 

@return nil

@obs A fun��o lan�ar� uma user exception em caso de erro.
/*/
static function LimpaEmp()
	local aArea := GetArea()
	local lLocaliza := Localiza(SD4->D4_COD)
	local aTravas := {}

	if Select("SD4") == 0
		MsgStop("A tabela SD4 n�o est� aberta. N�o existe registro posicionado para cancelar seu empenho.")
	elseif SD4->(Eof())
		MsgStop("A tabela SD4 est� posicionada no fim de arquivo. N�o existe registro posicionado para cancelar seu empenho.")
	endif

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + `C2_SEQUEN + C2_ITEMGRD

	if !SC2->(DbSeek(xFilial("SC2")+SD4->D4_OP))
		MsgStop("N�o � possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois a ordem de produ��o a que o empenho se refere n�o foi encontrada.")
	endif

	if !Empty(SC2->C2_DATRF)
		MsgStop("N�o � possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois a ordem de produ��o foi finalizada.")
	endif

	if (SD4->D4_QUANT < SD4->D4_QTDEORI)
		MsgStop("N�o � possivel remover o empenho [" + AllTrim((SD4->(&(IndexKey())))) + "] pois ele foi parcialmente baixado.")
	endif

	if lLocaliza
		DbSelectArea("SDC")
		DbSetOrder(2) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI

		SDC->(DbSeek(xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE))
		while xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE == DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE
			if SDC->DC_QUANT < SDC->DC_QTDORIG
				MsgStop("N�o � possivel remover o empenho [" + AllTrim(&(SD4->(IndexKey()))) + "] pois ele foi parcialmente baixado.")
			endif
			SDC->(DbSkip())
		end
	endif

//GravaEmp(SD4->D4_COD,; //cProduto
//         SD4->D4_LOCAL,; // cLocal
//         SD4->D4_QUANT,; // nQtd
//         SD4->D4_QTSEGUM,; // nQtd2UM
//         SD4->D4_LOTECTL,; // cLoteCtl
//         SD4->D4_NUMLOTE,; // cNumLote
//         nil,; // cLocaliza
//         nil,; // cNumSerie
//         SD4->D4_OP,; // cOP
//         SD4->D4_TRT,; // cTrt
//         nil,; // cPedido
//         nil,; // cItem
//         "SC2",; // cOrigem
//         nil,; // cOPOrig
//         SD4->D4_DATA,; // dEntrega
//         @aTravas,; // aTravas
//         .t.,; // lEstorno
//         nil,; // lProj
//         .t.,; // lEmpSB2
//         .t.,; // lGravaSD4
//         GetMV('MV_LOTVENC')=='S') // lConsVenc
//    MaDesTrava(aTravas)

	RecLock("SD4", .f.)
	DbDelete()
	MsUnlock()

	RestArea(aArea)
return nil
