// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Exportacao Trato | Carreg.  (JSON)
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"
#INCLUDE "SHASH.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF


/*---------------------------------------------------------------------------------,
 | Analista : 								                                       |
 | Data		:                                                                      |
 | Cliente  : Livio                                                                |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
 User Function VAPCPA13()

	Local aArea := GetArea()
//Local oBrowsey
	Local aIndBrw := {}

	Private aRotina := MenuDef()
	Private cDscCab := Posicione("SX2", 1, "Z0X", "X2_NOME")
//Private cDscDtA := Posicione("SX2", 1, "Z0Y", "X2_NOME")
//Private cDscDtB := Posicione("SX2", 1, "Z0W", "X2_NOME")
	Private aParRet := {}
	Private aFilRet := {100, 300, 500, "1"}
	Private aDadsel := {'', '',''}
	Private oGrdFRt, oGrdFTr
	Private aHdrGFR := {}
	Private aHdrGFT := {}
	Private aClsGFR := {}
	Private aClsGFT := {}
	Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}
//Private cRota    := ""
//Private cTrat    := ""
	Private oSSlBP
	Private oSSlBR
	Private oSSlBD
	Private oSSlTP
	Private oSSlTR
	Private oSSlTD

	Private oSORBP
	Private oSORBR
	Private oSORBD
	Private oSORTP
	Private oSORTR
	Private oSORTD

	Private aObjLCrP := {}
	Private aObjLCrC := {}
	Private aObjLCrR := {}

	Private nOpcRot  := 1
	Private cLogFile := ""
	Private cMsgPrc  := ""
	Private cRotSel  := ""

	Private _cA13LayOut := "NOVO"

	AAdd(aHdrGFR, {"Sel."     , "Selecionado", "@BMP", 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFR, {"Conferido", "Conferido  ", "@BMP", 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFR, {"Ordem    ", "Ordem      ", ""    , 10, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFR, {"Rota     ", "Rota       ", ""    , 06, 0, "", "", "C", "", "R", "", "", "", "V"})

	AAdd(aHdrGFT, {"Sel."     , "Selecionado", "@BMP", 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFT, {"Conferido", "Conferido  ", "@BMP", 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFT, {"Trato    ", "Trato      ", ""    , 01, 0, "", "", "C", "", "R", "", "", "", "V"})
//AAdd(aHdrGFT, {"Receita  ", "Receita    ", ""    , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrGFT, {"Descricao", "Descricao  ", ""    , 30, 0, "", "", "C", "", "R", "", "", "", "V"})

	AAdd(aIndBrw, {"Filial + Data + Versao + Equipamento" , {{"","C",02,0, "Z0X_FILIAL", ""}, {"","D",8,0, "Z0X_DATA", ""}, {"","C",04,0, "Z0X_VERSAO", "@!"}, {"","C",06,0, "Z0X_EQUIP", "@!"}}, 1, .T. } )
	AAdd(aIndBrw, {"Filial + Codigo", {{"","C",06,0, "Z0X_CODIGO" , "@!"}}, 2, .T. } )

	oBrowse := FwmBrowse():New()
	oBrowse:SetAlias("Z0X")
	oBrowse:SetDescription(cDscCab)
	oBrowse:SetSeek(.T., aIndBrw)
	oBrowse:DisableDetails()

	SetKey(VK_F12, {|| fNewLayOut()})

	oBrowse:Activate()

	RestArea(aArea)

Return

/* MB : 30.09.2021 */
Static Function fNewLayOut()
	If (_cA13LayOut == "NOVO")
		
		_cA13LayOut := "OLD"
		MsgInfo( "LayOut Configurado para o modelo Inicial" )
	Else
		
		_cA13LayOut := "NOVO"
		MsgInfo( "LayOut Configurado para o modelo NOVO (folder)" )
	EndIf

Return


Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE OemToAnsi("Visualizar"        ) ACTION "U_BTNVIS"    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE OemToAnsi("Exportar"          ) ACTION "U_BTNEXP"    OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Exportar"
	ADD OPTION aRotina TITLE OemToAnsi("Recriar Arq."      ) ACTION "U_BTNRXP"    OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Estornar"
	ADD OPTION aRotina TITLE OemToAnsi("Importar"          ) ACTION "U_BTNIMP"    OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE OemToAnsi("Conferir"	       ) ACTION "U_BTNCFR" 	  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE OemToAnsi("Processar"	       ) ACTION "U_BTNPRC" 	  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Processar"
	ADD OPTION aRotina TITLE OemToAnsi("Excluir"	       ) ACTION "U_BTNEXC" 	  OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE OemToAnsi("Estorno"	       ) ACTION "U_BTNEST" 	  OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Estornar"
	ADD OPTION aRotina TITLE OemToAnsi("Importar TODOS"    ) ACTION "U_BTIMPALL"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE OemToAnsi("Parametro Agua"    ) ACTION "U_BTParH20"  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE OemToAnsi("Importar Detalhado") ACTION "U_BIMPDT"    OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE OemToAnsi("Carreg. Detalhado" ) ACTION "U_fRotZ0Z"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Importar"
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPA13"    OPERATION 9 ACCESS 0 // "Copiar"

Return aRotina


/* ----------------------------------------------------------------------------- */
User Function btnCfr()

Local aEnButt := {{.F., NIL},;        // 01 - Copiar
                  {.F., NIL},;        // 02 - Recortar
                  {.F., NIL},;        // 03 - Colar
                  {.F., NIL},;        // 04 - Calculadora
                  {.F., NIL},;        // 05 - Spool
                  {.F., NIL},;        // 06 - Imprimir
                  {.T., "Salvar"},;   // 07 - Confirmar
                  {.T., "Sair"},;     // 08 - Cancelar
                  {.F., NIL},;        // 09 - WalkTrhough
                  {.F., NIL},;        // 10 - Ambiente
                  {.F., NIL},;        // 11 - Mashup
                  {.T., NIL},;        // 12 - Help
                  {.F., NIL},;        // 13 - Formulario HTML
                  {.F., NIL}}         // 14 - ECM

nOpcRot := MODEL_OPERATION_UPDATE
	
If (Z0X->Z0X_STATUS = "A" .OR. Z0X->Z0X_STATUS = "B" .OR. Z0X->Z0X_STATUS = "C" .OR. Z0X->Z0X_STATUS = "I")

	FWExecView(cDscCab, 'VAPCPA13', nOpcRot, , { || .T. },,, aEnButt)
	
Else

	MsgInfo("Nao existe importacao ou o arquivo '" + Z0X->Z0X_CODIGO + "' ja foi totalmente processado.")

EndIf

Return (Nil)


/* ----------------------------------------------------------------------------- */
User Function BTNVIS()

//O array aEnableButtons tem por padrao 14 posicoes:
Local aEnButt := {{.F., NIL},;			  // 01 - Copiar
                  {.F., NIL},;             // 02 - Recortar
                  {.F., NIL},;             // 03 - Colar
                  {.F., NIL},;             // 04 - Calculadora
                  {.F., NIL},;             // 05 - Spool
                  {.F., NIL},;             // 06 - Imprimir
                  {.F., NIL},;             // 07 - Confirmar
                  {.T., "Fechar"},;        // 08 - Cancelar
                  {.F., NIL},;             // 09 - WalkTrhough
                  {.F., NIL},;             // 10 - Ambiente
                  {.F., NIL},;             // 11 - Mashup
                  {.T., NIL},;             // 12 - Help
                  {.F., NIL},;             // 13 - Formulario HTML
                  {.F., NIL}}             // 14 - ECM

	nOpcRot  := MODEL_OPERATION_VIEW

	FWExecView(cDscCab, 'VAPCPA13', nOpcRot, , { || .T. },,, aEnButt)

Return (Nil)


/* ------------------------------------------------------------------------ */
User Function BTNEXC()

Local aEnButt := {{.F., NIL},;                // 01 - Copiar
                  {.F., NIL},;                // 02 - Recortar
                  {.F., NIL},;                // 03 - Colar
                  {.F., NIL},;                // 04 - Calculadora
                  {.F., NIL},;                // 05 - Spool
                  {.F., NIL},;                // 06 - Imprimir
                  {.T., "Confirmar"},;        // 07 - Confirmar
                  {.T., "Cancelar"},;         // 08 - Cancelar
                  {.F., NIL},;                // 09 - WalkTrhough
                  {.F., NIL},;                // 10 - Ambiente
                  {.F., NIL},;                // 11 - Mashup
                  {.T., NIL},;                // 12 - Help
                  {.F., NIL},;                // 13 - Formulario HTML
                  {.F., NIL}}                // 14 - ECM
Local cQryUpd := ""

nOpcRot  := MODEL_OPERATION_DELETE

///G=Gerado;A=Import.Parcial;I=Import.Total;C=Conferido;P=Processado;B=Proces.Parcial
If (Z0X->Z0X_STATUS == "C" .OR. Z0X->Z0X_STATUS == "G" .OR. Empty(Z0X->Z0X_STATUS))
	FWExecView(cDscCab, 'VAPCPA13', nOpcRot, , { || .T. },,, aEnButt)
Else
	MsgInfo("Arquivo nao pode ser excluido, estorne o processamento e tente novamente.")
	Return (Nil)
EndIf

If (Z0X->(Deleted()))
	
	If (Z0X->Z0X_OPERAC = "2")
		cQryUpd := " UPDATE " + RetSqlName("Z0J") + _ENTER_
		cQryUpd += " SET Z0J_EXPGER = '2' " + _ENTER_
		cQryUpd += " WHERE Z0J_FILIAL = '" + xFilial("Z0J") + "'" + _ENTER_
		cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
		cQryUpd += "   AND Z0J_DATA   = '" + DTOS(Z0X->Z0X_DATA) + "'" + _ENTER_
		cQryUpd += "   AND Z0J_VERSAO = '" + Z0X->Z0X_VERSAO + "'" + _ENTER_
		cQryUpd += "   AND Z0J_EQUIPA = '" + Z0X->Z0X_EQUIP + "'" + _ENTER_
	
		If (TCSqlExec(cQryUpd) < 0)
			MsgInfo(TCSqlError())
		EndIf
	Else
		If (!(Z0X->(DBSeek(xFilial("Z0X") + DTOS(Z0X->Z0X_DATA) + Z0X->Z0X_VERSAO))))
			DBSelectArea("Z0R")
			Z0R->(DBSetOrder(1))
			
			If (Z0R->(DBSeek(xFilial("Z0R") + DTOS(Z0X->Z0X_DATA) + Z0X->Z0X_VERSAO)))
				RecLock("Z0R", .F.)
					Z0R->Z0R_LOCK := '1'
				Z0R->(MSUnlock())
			EndIf
		EndIf
		/* 		
			cQryExp := " UPDATE " + RetSqlName("Z05") + _ENTER_
			cQryExp += " SET Z05_LOCK = '1' " + _ENTER_
			cQryExp += " WHERE Z05_FILIAL = '" + xFilial("Z05") + "'" + _ENTER_
			cQryExp += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
			cQryExp += "   AND Z05_DATA = '" + DTOS(Z0X->Z0X_DATA) + "'" + _ENTER_
			cQryExp += "   AND Z05_VERSAO = '" + Z0X->Z0X_VERSAO + "'" + _ENTER_
			cQryExp += "   AND Z05_CURRAL IN (SELECT Z0W.Z0W_CURRAL " + _ENTER_
			cQryExp += "                      FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
			cQryExp += "                      WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
			cQryExp += "                        AND Z0W.D_E_L_E_T_ = '*' " + _ENTER_
			cQryExp += "                        AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "') " + _ENTER_
			
			If (TCSqlExec(cQryExp) < 0)
				MsgInfo(TCSqlError())
			EndIf
			MEMOWRITE("C:\TOTVS_RELATORIOS\UPDLOCKZ05.SQL", cQryExp)
		*/
EndIf

EndIf

Return (Nil)


User Function btnExp()
/* Local aEnButt := {{.F., NIL},;           // 01 - Copiar
                  {.F., NIL},;           // 02 - Recortar
                  {.F., NIL},;           // 03 - Colar
                  {.F., NIL},;           // 04 - Calculadora
                  {.F., NIL},;           // 05 - Spool
                  {.F., NIL},;           // 06 - Imprimir
                  {.F., NIL},;           // 07 - Confirmar
                  {.T., "Fechar"},;      // 08 - Cancelar
                  {.F., NIL},;           // 09 - WalkTrhough
                  {.F., NIL},;           // 10 - Ambiente
                  {.F., NIL},;           // 11 - Mashup
                  {.T., NIL},;           // 12 - Help
                  {.F., NIL},;           // 13 - Formulario HTML
                  {.F., NIL}}           // 14 - ECM */
Local cPrgExp := "VAPCPA13X"

U_PosSX1({{"VAPCPA13E", "01", DTOS(dDataBase)}, {"VAPCPA13E", "02", Space(4)}, {"VAPCPA13E", "03", Space(6)}})
// U_PosSX1({{"VAPCPA13X", "01", DTOS(dDataBase)},;
// 		  {"VAPCPA13X", "03", Space(6)},;
// 		  {"VAPCPA13X", "04", Space(60)}})
U_PosSX1({{"VAPCPA13X", "01", iIf(cUserName $ "Administrador,atoshio", "20220416", DTOS(dDataBase))},;
		  {"VAPCPA13X", "02", Space(6)},;
		  {"VAPCPA13X", "03", Space(6)},;
		  {"VAPCPA13X", "04", 2       } })

aParRet := {}

If (Pergunte(cPrgExp, .T.))

	/*01*/ AAdd(aParRet, MV_PAR01) // DATA
	// /*02*/ AAdd(aParRet, "0001"  )
	/*02*/ AAdd(aParRet, MV_PAR02) // /*03*/ AAdd(aParRet, MV_PAR03) // EQUIPAMENTO
	// /*04*/ AAdd(aParRet, MV_PAR02) // OPERACAO: 1- trato; 2-Fabrica; 3-Phibro
	// /*05*/ AAdd(aParRet, MV_PAR05) // TIPO ARQUIVO: 1-CSV; 2=JSon
	/*03*/ AAdd(aParRet, MV_PAR03) // ROTA // /*06*/ AAdd(aParRet, MV_PAR04) // ROTA
	/*04*/ AAdd(aParRet, MV_PAR04) // ROTA // /*06*/ AAdd(aParRet, MV_PAR04) // ROTA
	
	FWMsgRun(, {|| U_ExpBatTrt()}, "Processando", "Gerando arquivo...")
	//	FWExecView(cDscCab, 'VAPCPA13', MODEL_OPERATION_INSERT, , { || .T. },,, aEnButt)
EndIf

Return (Nil)


User Function btnRxp()

Local cLocArq := ""
Local aCntRxp := {}
Local cCntJsn := ""
Local cCntCsv := ""
// Local cEquip  := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+Z0X->Z0X_EQUIP, "ZV0_IDENT"))
Local cArqExJ := "programacao.json"
// Local cArqExC := "programacao-" +AllTrim(Str(DAY(Z0X->Z0X_DATA)))  +"-" +;
// 								 AllTrim(Str(Month(Z0X->Z0X_DATA)))+"-" +;
// 								 AllTrim(Str(Year(Z0X->Z0X_DATA))) +"-" +;
// 								 cEquip+;
// 								 "-V"+Z0X->Z0X_VERSAO + ".csv"
Local cArqExC := ""
//ocal cArqExJ := "programacao.json"
//Local cArqExC := "programacao.csv"

// MB : 16.02.2020
cEquip  := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+Z0X->Z0X_EQUIP, "ZV0_IDENT"))

aCntRxp := StrToKArr(Z0X->Z0X_CNTEXP, '|')

cCntJsn := aCntRxp[1]
cCntCsv := aCntRxp[2]

cLocArq := "\TOTVS_EXPIMP\" + IIf(Z0X->Z0X_OPERAC = "1", "TRATO\", "FABRICA\")
MakeDir(cLocArq)
MakeDir("C:" + cLocArq)
			
cLocArq += DTOS(Z0X->Z0X_DATA) + "-" + Z0X->Z0X_VERSAO + "\"
MakeDir(cLocArq)
MakeDir("C:" + cLocArq)
			
cLocArq += AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+Z0X->Z0X_EQUIP, "ZV0_IDENT")) + "\" //AllTrim(aParRet[3]) + "\"
MakeDir(cLocArq)
MakeDir("C:" + cLocArq)
			
cMsgExp := "Arquivos 'programacao.csv' e 'programacao.json' gerados na pasta 'C:" + cLocArq + "'. "		

MEMOWRITE(cLocArq + cArqExJ, cCntJsn)
MEMOWRITE("C:" + cLocArq + cArqExJ, cCntJsn)

MEMOWRITE(cLocArq + cArqExC, cCntCsv)
MEMOWRITE("C:" + cLocArq + cArqExC, cCntCsv)

MsgInfo(cMsgExp, "Arquivo JSON | CSV " + IIf (Z0X->Z0X_OPERAC = "1", " Carreg. | Trato", "Fabrica"))

Return (Nil)

/* 
	MB : 01.10.2021 
		Importa automatico todos os arquivos;
*/
User Function BTIMPALL()

	Local cOrigPath := GetMV( "MB_PCPA13O",, "C:\temp\_RESULTADO\")
	Local cDestPath := GetMV( "MB_PCPA13D",, "C:\temp\_IMPORTADO\")
	Local aFiles    := {}
	Local nI        := 0

// Carregar arquivos do diretorio
	aFiles := Directory(cOrigPath + "*.*")
	If Len(aFiles) == 0
		MsgInfo( "Nao foi localizado arquivos no diretorio: " + cOrigPath )

	Else
		for nI:=1 to Len(aFiles)

			Pergunte( "VAPCPA13I", .F.)
			MV_PAR01 := cOrigPath + aFiles[nI, 1]
			AAdd(aParRet, MV_PAR01)

			If !U_ImpCSV( MV_PAR01 )
				// Transferir para pasta dos processados

				// If (CpyT2S( cFile, cDestPath )) // operacao de copia entre servidor x local
				If  __CopyFile( MV_PAR01, cDestPath + aFiles[nI, 1] ,,,.F.)
					fErase( MV_PAR01 )
				Else
					MsgInfo( "Erro ao mover arquivo: " + MV_PAR01 + " para o diretrio: " + cDestPath )
					Exit
				EndIf

			EndIf
		next nI

		MsgInfo( "Importacao concluida com Sucesso para " + cValToChar(nI-1) + " arquivos." )

	EndIf

Return nil


User Function btnImp()

/* Local aEnButt := {{.F., NIL},;           // 01 - Copiar
                     {.F., NIL},;           // 02 - Recortar
                     {.F., NIL},;           // 03 - Colar
                     {.F., NIL},;           // 04 - Calculadora
                     {.F., NIL},;           // 05 - Spool
                     {.F., NIL},;           // 06 - Imprimir
                     {.F., NIL},;           // 07 - Confirmar
                     {.T., "Fechar"},;      // 08 - Cancelar
                     {.F., NIL},;           // 09 - WalkTrhough
                     {.F., NIL},;           // 10 - Ambiente
                     {.F., NIL},;           // 11 - Mashup
                     {.T., NIL},;           // 12 - Help
                     {.F., NIL},;           // 13 - Formulario HTML
                     {.F., NIL}}           // 14 - ECM */
Local cPrgImp := "VAPCPA13I"

//U_PosSX1({{cPrgImp, "01", DTOS(dDataBase)}, {cPrgImp, "02", Space(4)}, {cPrgImp, "03", Space(6)}, {cPrgImp, "04", Space(20)}})

aParRet := {}

If (Pergunte(cPrgImp, .T.))
	AAdd(aParRet, MV_PAR01)
	
	FWMsgRun(, {|| U_ImpBatTrt(MV_PAR01)}, "Processando", "Importando arquivo...")
	
	//FWExecView(cDscCab, 'VAPCPA13', MODEL_OPERATION_UPDATE, , { || .T. },,, aEnButt)
EndIf

Return (Nil)

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.07.2023                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Bot�o importar detalhado;                                            |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function BIMPDT() 
Local cPrgImp := "VAPCPA13I"

aParRet := {}

If (Pergunte(cPrgImp, .T.))
	AAdd(aParRet, MV_PAR01)
	
	FWMsgRun(, {|| U_ImpDetalhado(MV_PAR01)}, "Processando", "Importando arquivo...")
	
	//FWExecView(cDscCab, 'VAPCPA13', MODEL_OPERATION_UPDATE, , { || .T. },,, aEnButt)
EndIf

Return (Nil)


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 12.11.2019                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Processamento em Lote ou Individual;                                 |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function btnPrc()
Local cTimeIni := Time()
/* Local aEnButt  := {{.F., NIL},;         // 01 - Copiar
                   {.F., NIL},;          // 02 - Recortar
                   {.F., NIL},;          // 03 - Colar
                   {.F., NIL},;          // 04 - Calculadora
                   {.F., NIL},;          // 05 - Spool
                   {.F., NIL},;          // 06 - Imprimir
                   {.F., NIL},;          // 07 - Confirmar
                   {.T., "Fechar"},;     // 08 - Cancelar
                   {.F., NIL},;          // 09 - WalkTrhough
                   {.F., NIL},;          // 10 - Ambiente
                   {.F., NIL},;          // 11 - Mashup
                   {.T., NIL},;          // 12 - Help
                   {.F., NIL},;          // 13 - Formulario HTML
                   {.F., NIL}}          // 14 - ECM */

nAviso := Aviso("Processamento","Deseja fazer o apontamento de producao de  ?",{"Todos","Atual","Cancela"})

If LockByName("BTNPRC", .T., .T.) .and. nAviso == 1

	U_fPrcLote()

ElseIf LockByName("BTNPRC", .T., .T.) .and. nAviso == 2

	aParRet := {}

	AAdd(aParRet, Z0X->Z0X_DATA)
	AAdd(aParRet, Z0X->Z0X_CODIGO)
	
	ConOut( "Processando os dados [" + Z0X->Z0X_CODIGO + "]" )
	FWMsgRun(, {|| U_PrcBatTrt()}, "Processando", "Processando os dados [" + Z0X->Z0X_CODIGO + "]")
	
Else 
	MsgInfo("Operacao Cancelada")
		
EndIf 

UnlockByName("BTNPRC")

If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin, administrador' .And. !nAviso == 3 
	cMsg := 'Inicio: ' + cTimeINI + _ENTER_
	cMsg += iIf(Empty( cMsg ),"", CRLF) + 'Final : ' + Time()   + _ENTER_
	cMsg += iIf(Empty( cMsg ),"", CRLF) + 'Tempo de processamento: ' + ElapTime( cTimeINI, Time() )
	Alert( cMsg )
	ConOut( cMsg )
EndIf

Return (Nil)


/*--------------------------------------------------------------------------------,
 | Principal: 					                         		                  |
 | Func:  ModelDef   	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:                                                                          |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ModelDef()

Local oModel     := Nil
Local oStrCabZ0X := FWFormStruct(1, "Z0X")
Local oStrGrdZ0Y := FWFormStruct(1, "Z0Y")
Local oStrGrdZ0W := FWFormStruct(1, "Z0W")
// Local cCSSGrd := ""

Local aAux := FwStruTrigger(;
				  "Z0Y_PESDIG" ,; // Campo Dominio
				  "Z0Y_DATINI" ,; // Campo de Contradominio
				  "dDataBase",; // Regra de Preenchimento
				  .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				  "" ,; // Alias da tabela a ser posicionada
				  0 ,; // Ordem da tabela a ser posicionada
				  "" ,; // Chave de busca da tabela a ser posicionada
				  NIL ,; // Condicao para execucao do gatilho
				  "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0Y:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0Y_PESDIG" ,; // Campo Dominio
				"Z0Y_HORINI" ,; // Campo de Contradominio
				"Time()",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0Y:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0Y_PESDIG" ,; // Campo Dominio
				"Z0Y_DATFIN" ,; // Campo de Contradominio
				"dDataBase",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0Y:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0Y_PESDIG" ,; // Campo Dominio
				"Z0Y_HORFIN" ,; // Campo de Contradominio
				"Time()",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"04" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0Y:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0Y_PESDIG" ,; // Campo Dominio
				"Z0Y_DIFPES" ,; // Campo de Contradominio
				"FwFldGet('Z0Y_QTDPRE')-FwFldGet('Z0Y_PESDIG')",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"05" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])
/* ------------------------------------------------------------------------------------------------------------ */


aAux := FwStruTrigger(;
				"Z0W_PESDIG" ,; // Campo Dominio
				"Z0W_DATINI" ,; // Campo de Contradominio
				"dDataBase",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0W_PESDIG" ,; // Campo Dominio
				"Z0W_HORINI" ,; // Campo de Contradominio
				"Time()",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0W_PESDIG" ,; // Campo Dominio
				"Z0W_DATFIN" ,; // Campo de Contradominio
				"dDataBase",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0W_PESDIG" ,; // Campo Dominio
				"Z0W_HORFIN" ,; // Campo de Contradominio
				"Time()",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"04" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])

aAux := FwStruTrigger(;
				"Z0W_PESDIG" ,; // Campo Dominio
				"Z0W_DIFPES" ,; // Campo de Contradominio
				"FwFldGet('Z0W_QTDPRE')-FwFldGet('Z0W_PESDIG')",; // Regra de Preenchimento
				.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
				"" ,; // Alias da tabela a ser posicionada
				0 ,; // Ordem da tabela a ser posicionada
				"" ,; // Chave de busca da tabela a ser posicionada
				NIL ,; // Condicao para execucao do gatilho
				"05" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStrGrdZ0W:AddTrigger(aAux[1], aAux[2], aAux[3], aAux[4])
/* ------------------------------------------------------------------------------------------------------------ */


oStrGrdZ0Y:SetProperty('Z0Y_PESDIG', MODEL_FIELD_VALID,;
							FWBuildFeature( STRUCT_FEATURE_VALID, "U_VldPesDig()"))

oStrGrdZ0Y:SetProperty('Z0Y_MOTCOR', MODEL_FIELD_VALID,;
							FWBuildFeature( STRUCT_FEATURE_VALID, "U_VldPesDig()"))

oStrGrdZ0W:SetProperty('Z0W_PESDIG', MODEL_FIELD_VALID,;
							FWBuildFeature( STRUCT_FEATURE_VALID, "U_VldPesDig()"))

oStrGrdZ0W:SetProperty('Z0W_MOTCOR', MODEL_FIELD_VALID,;
							FWBuildFeature( STRUCT_FEATURE_VALID, "U_VldPesDig()"))
/* ------------------------------------------------------------------------------------------------------------ */


// oModel := MpFormModel():New("PCPVAA13",,/* { |oModel| U_PCPA13POS( oModel ) } */,, ) //{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}
oModel := MPFormModel():New('PCPVAA13',/*bPreValidacao*/,, /* {|oMdl| SVDTM(oMdl)} */ ,/*bCancel*/)

// [01] C Titulo do campo // [02] C ToolTip do campo // [03] C identificador (ID) do Field // [04] C Tipo do campo // [05] N Tamanho do campo // [06] N Decimal do campo // [07] B Code-block de validacao do campo // [08] B Code-block de validacao When do campo // [09] A Lista de valores permitido do campo // [10] L Indica se o campo tem preenchimento obrigatório // [11] B Code-block de inicializacao do campo // [12] L Indica se trata de um campo chave // [13] L Indica se o campo pode receber valor em uma operacao de update. // [14] L Indica se o campo e virtual
oStrGrdZ0Y:AddField(AllTrim(""), AllTrim(""), "Z0Y_LEGEND", "C", 50, 0, NIL, NIL, NIL, NIL, ;                 
                { || IIf(Z0Y->Z0Y_DIFPES >= aFilRet[3], "BR_VERMELHO", IIf(Z0Y->Z0Y_DIFPES < aFilRet[3] .AND. Z0Y->Z0Y_DIFPES >= aFilRet[2], "BR_LARANJA", "BR_VERDE"))} , ;           
                NIL, NIL, .T.)
                
oModel:AddFields("MdFldZ0X",,oStrCabZ0X,/*bPreValid*/, /*bPosValid*/,)
oModel:AddGrid("MdGrdZ0Y", "MdFldZ0X", oStrGrdZ0Y,,/* { |oModelGrid| U_PCPA13LPOS(oModelGrid) } */ )

If (Z0X->Z0X_OPERAC == "1")

	oStrGrdZ0W:AddField(AllTrim(""), AllTrim(""), "Z0W_LEGEND", "C", 50, 0, NIL, NIL, NIL, NIL, ;
					{ || IIf(Z0W->Z0W_DIFPES >= aFilRet[3], "BR_VERMELHO", IIf(Z0W->Z0W_DIFPES < aFilRet[3] .AND. Z0W->Z0W_DIFPES >= aFilRet[2], "BR_LARANJA", "BR_VERDE"))} , ; //{ || IIf(Z0W->Z0W_DIFPES > 200, "BR_VERMELHO", "BR_VERDE")} , ;
					NIL, NIL, .T.)

	oModel:AddGrid("MdGrdZ0W", "MdFldZ0X", oStrGrdZ0W)

EndIf

//oModel:AddCalc("VAPCPA13SPB", "MdFld" + cAlsCab, "MdGrd" + cAlsDtA, "Z0Y_QTDPRE", "Z0Y_TOTPBC", "SUM",,, "Total Previsto Carreg.")
//oModel:AddCalc("VAPCPA13SPT", "MdFld" + cAlsCab, "MdGrd" + cAlsDtB, "Z0W_QTDPRE", "Z0W_TOTPTC", "SUM",,, "Total Previsto Trato")
//oModel:AddCalc("VAPCPA13SRB", "MdFld" + cAlsCab, "MdGrd" + cAlsDtA, "Z0Y_QTDREA", "Z0Y_TOTRBC", "SUM",,, "Total Realizado Carreg.")
//oModel:AddCalc("VAPCPA13SRT", "MdFld" + cAlsCab, "MdGrd" + cAlsDtB, "Z0W_QTDREA", "Z0W_TOTRTC", "SUM",,, "Total Realizado Trato")

oModel:SetRelation("MdGrdZ0Y", {{"Z0Y_CODEI", "Z0X_CODIGO"}})

If (Z0X->Z0X_OPERAC == "1")
	oModel:SetRelation("MdGrdZ0W", {{"Z0W_CODEI", "Z0X_CODIGO"}}, Z0W->( IndexKey( 1 ) ) )
EndIf

oModel:SetPrimaryKey({"Z0X_FILIAL", "Z0X_CODIGO"})

DBSelectArea("Z0Y")
Z0Y->(DBSetOrder(1))
Z0Y->(DBSeek(xFilial("Z0Y")+Z0X->Z0X_CODIGO))

aDadSel[1] := Z0Y->Z0Y_ORDEM
aDadSel[2] := Z0Y->Z0Y_TRATO
aDadSel[3] := Z0Y->Z0Y_ROTA

If (nOpcRot != MODEL_OPERATION_DELETE)
	oModel:GetModel("MdGrdZ0Y"):SetLoadFilter({;
			{"Z0Y_ORDEM", "'" + Z0Y->Z0Y_ORDEM + "'"},;
			{"Z0Y_TRATO", "'" + Z0Y->Z0Y_TRATO + "'"}})
	
	If (Z0X->Z0X_OPERAC == "1")
		oModel:GetModel("MdGrdZ0W"):SetLoadFilter({{"Z0W_TRATO", "'" + Z0Y->Z0Y_TRATO + "'"}})
		oModel:GetModel("MdGrdZ0W"):SetDescription("Trato")
	EndIf
EndIf

oModel:GetModel("MdFldZ0X"):SetDescription(cDscCab)
oModel:GetModel("MdGrdZ0Y"):SetDescription("Carregamento")

Return oModel


/*--------------------------------------------------------------------------------,
 | Principal: 					                         		                  |
 | Func:  ViewDef   	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:                                                                          |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ViewDef()

Local oModel := ModelDef()
Local oView 
Local oStrCabZ0X := FwFormStruct(2, "Z0X") // Cabecalho da tela de importacao
Local oStrGrdZ0Y := FwFormStruct(2, "Z0Y") // 
Local oStrGrdZ0W := FwFormStruct(2, "Z0W")
//Local oStrTot := FWCalcStruct(oModel:GetModel('VAPCPA13SPB'))

oView := FwFormView():New()
oView:SetModel(oModel)

// Ord. Tipo Desc. // [01] C   Nome do Campo // [02] C   Ordem // [03] C   Titulo do campo // [04] C   Descricao do campo // [05] A   Array com Help // [06] C   Tipo do campo // [07] C   Picture // [08] B   Bloco de Picture Var // [09] C   Consulta F3 // [10] L   Indica se o campo e alteravel // [11] C   Pasta do campo // [12] C   Agrupamento do campo // [13] A   Lista de valores permitido do campo (Combo) // [14] N   Tamanho maximo da maior opcao do combo // [15] C   Inicializador de Browse // [16] L   Indica se o campo e virtual // [17] C   Picture Variavel // [18] L   Indica pulo de linha após o campo

oStrGrdZ0Y:AddField("Z0Y_LEGEND", "00", AllTrim(''), AllTrim(''), {"Legenda"}, 'C', '@BMP', NIL, '', .T., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

If (Z0X->Z0X_OPERAC == "1")
	oStrGrdZ0W:AddField("Z0W_LEGEND", "00", AllTrim(''), AllTrim(''), {"Legenda"}, 'C', '@BMP', NIL, '', .T., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
EndIf

//View X Model
oView:AddField("VwFldZ0X", oStrCabZ0X, "MdFldZ0X")
oView:AddGrid("VwGrdZ0Y" , oStrGrdZ0Y, "MdGrdZ0Y")

If (Z0X->Z0X_OPERAC == "1")
	oView:AddGrid("VwGrdZ0W", oStrGrdZ0W, "MdGrdZ0W")
	oView:SetViewProperty("VwGrdZ0W", "CHANGELINE", {{ |oView, cViewID| /* Alert('SetViewProperty'), */ LegCur(Nil, .F.) }} )
	
	oView:AddOtherObject("VwPnlLCr", {|oPanel| /* alert('AddOtherObject'), */ LegCur(oPanel, .T.)}, {|| .T.}, {|| .T.})
EndIf

//oView:AddField('CALC', oStrTot,'VAPCPA13SPB') 

If (nOpcRot != MODEL_OPERATION_DELETE)
	oView:AddOtherObject("VwGrdRot", {|oPanel| FilRot(oPanel)}, {|| .T.}, {|| .T.})
	oView:AddOtherObject("VwGrdTrt", {|oPanel| FilTrt(oPanel)}, {|| .T.}, {|| .T.})
	oView:AddOtherObject("VwPnlTSl", {|oPanel| TotSl(oPanel, .T.)}, {|| .T.}, {|| .T.})
	oView:AddOtherObject("VwPnlTAr", {|oPanel| TotEI(oPanel, .T.)}, {|| .T.}, {|| .T.})
EndIf

oStrCabZ0X:RemoveField("Z0X_ARQEXP")
oStrCabZ0X:RemoveField("Z0X_CNTEXP")
oStrCabZ0X:RemoveField("Z0X_USUEXP")
oStrCabZ0X:RemoveField("Z0X_ARQIMP")
oStrCabZ0X:RemoveField("Z0X_CNTIMP")
oStrCabZ0X:RemoveField("Z0X_USUIMP")

oStrGrdZ0Y:RemoveField("Z0Y_FILIAL")
oStrGrdZ0Y:RemoveField("Z0Y_CODIGO")
oStrGrdZ0Y:RemoveField("Z0Y_CODEI")
oStrGrdZ0Y:RemoveField("Z0Y_ORDEM")
oStrGrdZ0Y:RemoveField("Z0Y_RECEIT")
oStrGrdZ0Y:RemoveField("Z0Y_TRATO")
oStrGrdZ0Y:RemoveField("Z0Y_AJUSTE")
oStrGrdZ0Y:RemoveField("Z0Y_ROTA")
oStrGrdZ0Y:RemoveField("Z0Y_TOLERA")
oStrGrdZ0Y:RemoveField("Z0Y_TIMER")
oStrGrdZ0Y:RemoveField("Z0Y_CONFER")
oStrGrdZ0Y:RemoveField("Z0Y_DATCFR")
oStrGrdZ0Y:RemoveField("Z0Y_HORCFR")
oStrGrdZ0Y:RemoveField("Z0Y_DSCDIE")
oStrGrdZ0Y:RemoveField("Z0Y_ORDEM")
oStrGrdZ0Y:RemoveField("Z0Y_DATA")
oStrGrdZ0Y:RemoveField("Z0Y_VERSAO")

If (Z0X->Z0X_OPERAC == "1")
	oStrGrdZ0W:RemoveField("Z0W_FILIAL")
	oStrGrdZ0W:RemoveField("Z0W_CODIGO")
	oStrGrdZ0W:RemoveField("Z0W_CODEI")
	oStrGrdZ0W:RemoveField("Z0W_ROTA")
	oStrGrdZ0W:RemoveField("Z0W_TRATO")
	oStrGrdZ0W:RemoveField("Z0W_CONFER")
	oStrGrdZ0W:RemoveField("Z0W_DATCFR")
	oStrGrdZ0W:RemoveField("Z0W_DATCFR")
	oStrGrdZ0W:RemoveField("Z0W_HORCFR")
	oStrGrdZ0W:RemoveField("Z0W_ORDEM")
	oStrGrdZ0W:RemoveField("Z0W_DATA")
	oStrGrdZ0W:RemoveField("Z0W_VERSAO")
	
	oStrGrdZ0W:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
	
	oView:SetNoDeleteLine("VwGrdZ0W")
EndIf

oStrGrdZ0Y:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)

oView:SetNoDeleteLine("VwGrdZ0Y")

If (ALTERA)
	oStrGrdZ0Y:SetProperty("Z0Y_PESDIG", MVC_VIEW_CANCHANGE , .T.)
	oStrGrdZ0Y:SetProperty("Z0Y_MOTCOR", MVC_VIEW_CANCHANGE , .T.)
	If (Z0X->Z0X_OPERAC = "1")
		oStrGrdZ0W:SetProperty("Z0W_PESDIG", MVC_VIEW_CANCHANGE , .T.)
		oStrGrdZ0W:SetProperty("Z0W_MOTCOR", MVC_VIEW_CANCHANGE , .T.)
	EndIf
EndIf

//separacao da tela
oView:CreateHorizontalBox( "CABECALHO", 16 )
oView:CreateHorizontalBox( "BOXTELDV1", 02 )
oView:CreateHorizontalBox( "FILTRO"   , 22 )

oView:CreateVerticalBox("BOXFILROT", 16, "FILTRO")
oView:CreateVerticalBox("BOXFILDV1", 02, "FILTRO")
oView:CreateVerticalBox("BOXFILDV2", 04, "FILTRO")
oView:CreateVerticalBox("BOXFILTRT", 20, "FILTRO")
oView:CreateVerticalBox("BOXTOTSEL", 18, "FILTRO")
oView:CreateVerticalBox("BOXFILDV3", 04, "FILTRO")
oView:CreateVerticalBox("BOXTOTARQ", 18, "FILTRO")
oView:CreateVerticalBox("BOXFILDV4", 18, "FILTRO")

If (_cA13LayOut == "NOVO")

	oView:CreateHorizontalBox("FOLDER", 60 )

	oView:CreateFolder( 'PASTAS', 'FOLDER' )

	oView:AddSheet( 'PASTAS', 'ABA01', 'Carregamento' )
	oView:CreateHorizontalBox("BOXCARREG", 100,,, 'PASTAS', 'ABA01')

	oView:AddSheet( 'PASTAS', 'ABA02', 'Trato       ' )
	oView:CreateHorizontalBox("BOXTRATO" , 84,,, 'PASTAS', 'ABA02')
	
	oView:CreateHorizontalBox("BOXTELDV3",  3,,, 'PASTAS', 'ABA02' )
	oView:CreateHorizontalBox("BOXLEGCUR", 13,,, 'PASTAS', 'ABA02' )

Else // If (_cA13LayOut == "OLD")

	oView:CreateHorizontalBox("BOXTELDV2", 02)
	oView:CreateHorizontalBox("BOXCARREG", 24)
	oView:CreateHorizontalBox("BOXTELDV3", 02)
	oView:CreateHorizontalBox("BOXLEGCUR", 08)
	oView:CreateHorizontalBox("BOXTRATO" , 24)
	
EndIf

//oView:CreateVerticalBox("BOXCARREG", 48, "DETALHE")
//oView:CreateVerticalBox("BOXDETDV1", 04, "DETALHE")
//oView:CreateVerticalBox("BOXTRATO", 48, "DETALHE")

//visoes da tela
oView:SetOwnerView("VwFldZ0X", "CABECALHO")
If (nOpcRot != MODEL_OPERATION_DELETE)
	oView:SetOwnerView("VwGrdRot", "BOXFILROT")
	oView:SetOwnerView("VwGrdTrt", "BOXFILTRT")
	oView:SetOwnerView("VwPnlTSl", "BOXTOTSEL")
	oView:SetOwnerView("VwPnlTAr", "BOXTOTARQ")
	
	oView:EnableTitleView("VwGrdRot", "Filtro de Rotas (Ordem)")
	oView:EnableTitleView("VwGrdTrt", "Filtro de Trato")
	oView:EnableTitleView("VwPnlTSl", "Totais Trato")
	oView:EnableTitleView("VwPnlTAr", "Totais Ordem")
EndIf

oView:SetOwnerView("VwGrdZ0Y", "BOXCARREG")
oView:EnableTitleView("VwGrdZ0Y") //, "Carregamento - " + @aDadSel[3])

If (Z0X->Z0X_OPERAC == "1")
	oView:SetOwnerView("VwGrdZ0W", "BOXTRATO")
	oView:EnableTitleView("VwGrdZ0W") //, "Trato - " + @aDadSel[2])
	
	oView:SetOwnerView("VwPnlLCr", "BOXLEGCUR")
EndIf

If (Z0X->Z0X_OPERAC == "1")
	oView:SetNoInsertLine("VwGrdZ0W")
	oView:SetNoDeleteLine("VwGrdZ0W")
EndIf

oView:SetNoInsertLine("VwGrdZ0Y")
oView:SetNoDeleteLine("VwGrdZ0Y")

//SetKey(VK_F2, {|| ShwDtL()})
//SetKey(VK_F3, {|| ShwDtI()})
SetKey(VK_F4, {|| U_ShwFilTl()})

Return oView



/* ****************************************************************************************************** */
Static Function FilRot(oPanel)

aClsGFR := {}
aClsGFR := ExpImpRot()

oGrdFRt := Nil

oGrdFRt := MsNewGetDados():New( 001, 001, 100, 400,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue",;
		oPanel, aHdrGFR, aClsGFR, {|| ChgRot(n)})
oGrdFRt:oBrowse:bLDblClick := {|| MarkTrt(oGrdFRt:nAt, 1), oGrdFRt:Refresh()}

Return (Nil)



/* ****************************************************************************************************** */
Static Function FilTrt(oPanel)

//sClGFFT := {}
aClsGFT := ExpImpTrt()

oGrdFTr := Nil

oGrdFTr := MsNewGetDados():New( 001, 001, 100, 400,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue",;
		oPanel, aHdrGFT, aClsGFT, {|| ChgTrt(n)})
oGrdFTr:oBrowse:bLDblClick := {|| MarkTrt(oGrdFTr:nAt, 2), oGrdFTr:Refresh()}

Return (Nil)



/* ****************************************************************************************************** */
Static Function TotSl(oPanel, lIni)

Local oTFntTt  := TFont():New('Courier New',,18,.T.,.T.)  
Local cQryTot  := ""
// Local oViwAt   := FWViewActive()
Local cTSlTPre := ""
Local cTSlTRea := ""
Local cTSlTDig := ""
Local cTSlBPre := ""
Local cTSlBRea := ""
Local cTSlBDig := ""
Local lVldTSl  := .T.

If (oGrdFTr:nAt = 0)
	oGrdFTr:nAt := 1
EndIf

cQryTot += " SELECT TOTPRE, TOTREA, TOTDIG" + _ENTER_ 
cQryTot += " FROM (" + _ENTER_ 
cQryTot += " 		SELECT ISNULL(SUM(Z0Y.Z0Y_QTDPRE), 0) AS TOTPRE, " + _ENTER_ 
cQryTot += " 		       ISNULL(SUM(Z0Y.Z0Y_QTDREA), 0) AS TOTREA, " + _ENTER_ 
cQryTot += " 		       ISNULL(SUM(Z0Y.Z0Y_PESDIG), 0) AS TOTDIG  " + _ENTER_
// cQryTot := " SELECT SUM(Z0Y.Z0Y_QTDPRE) AS TOTPRE, SUM(Z0Y.Z0Y_QTDREA) AS TOTREA, SUM(Z0Y.Z0Y_PESDIG) AS TOTDIG " + _ENTER_
cQryTot += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
cQryTot += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
cQryTot += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
cQryTot += "   AND Z0Y.Z0Y_ORDEM = '" + IIf(lIni, Z0Y->Z0Y_ORDEM,oGrdFRt:aCols[oGrdFRt:nAt][3]) + "'" + _ENTER_
cQryTot += "   AND Z0Y.Z0Y_RECEIT = '" + IIf(lIni, Z0Y->Z0Y_RECEIT, Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) ) + "'" + _ENTER_
cQryTot += "   AND Z0Y.Z0Y_TRATO = '" + IIf(lIni, " 1", oGrdFTr:aCols[oGrdFTr:nAt][3]) + "'" + _ENTER_
cQryTot += "   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
cQryTot += " ) DADOS " + _ENTER_
cQryTot += " WHERE " + _ENTER_
cQryTot += " 	TOTPRE > 0 OR " + _ENTER_
cQryTot += " 	TOTREA > 0 OR " + _ENTER_
cQryTot += " 	TOTDIG > 0 "    + _ENTER_

TCQUERY cQryTot NEW ALIAS "QRYTOT"

If (!QRYTOT->(EOF()))
	MEMOWRITE("C:\TOTVS_RELATORIOS\TOTSELCARREG.sql", cQryTot)
	cTSlBPre := TRANSFORM(QRYTOT->TOTPRE, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
	cTSlBRea := TRANSFORM(QRYTOT->TOTREA, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
	cTSlBDig := TRANSFORM(QRYTOT->TOTDIG, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
EndIf
QRYTOT->(DBCloseArea())

If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")

	cQryTot += " SELECT TOTPRE, TOTREA, TOTDIG" + _ENTER_ 
	cQryTot += " FROM (" + _ENTER_ 
	cQryTot += " 		SELECT ISNULL(SUM(Z0W.Z0W_QTDPRE), 0) AS TOTPRE, " + _ENTER_ 
	cQryTot += " 		       ISNULL(SUM(Z0W.Z0W_QTDREA), 0) AS TOTREA, " + _ENTER_ 
	cQryTot += " 		       ISNULL(SUM(Z0W.Z0W_PESDIG), 0) AS TOTDIG  " + _ENTER_
	// cQryTot := "   SELECT SUM(Z0W.Z0W_QTDPRE) AS TOTPRE, SUM(Z0W.Z0W_QTDREA) AS TOTREA, SUM(Z0W.Z0W_PESDIG) AS TOTDIG " + _ENTER_
	cQryTot += "   FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
	cQryTot += "   WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_ 
	cQryTot += "   AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryTot += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryTot += "   AND Z0W.Z0W_ORDEM = '" + IIf(lIni, Z0Y->Z0Y_ORDEM,oGrdFRt:aCols[oGrdFRt:nAt][3]) + "'" + _ENTER_
	cQryTot += "   AND Z0W.Z0W_RECEIT = '" + IIf(lIni, Z0Y->Z0Y_RECEIT, Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) ) + "'" + _ENTER_
	cQryTot += "   AND Z0W.Z0W_TRATO = '" + IIf(lIni, " 1",oGrdFTr:aCols[oGrdFTr:nAt][3]) + "'" + _ENTER_
	cQryTot += " ) DADOS " + _ENTER_
	cQryTot += " WHERE " + _ENTER_
	cQryTot += " 	TOTPRE > 0 OR " + _ENTER_
	cQryTot += " 	TOTREA > 0 OR " + _ENTER_
	cQryTot += " 	TOTDIG > 0 "    + _ENTER_
	
	TCQUERY cQryTot NEW ALIAS "QRYTOT"
	
	If (!QRYTOT->(EOF()))
		MEMOWRITE("C:\TOTVS_RELATORIOS\TOTSELDESC.sql", cQryTot)
		cTSlTPre := TRANSFORM(QRYTOT->TOTPRE, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
		cTSlTRea := TRANSFORM(QRYTOT->TOTREA, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
		cTSlTDig := TRANSFORM(QRYTOT->TOTDIG, "@E 999,999,999" + iIf(Z0X->Z0X_OPERAC=='3',".99",""))
	EndIf
	QRYTOT->(DBCloseArea())
EndIf

If (lIni)

	TSay():New(015, 005, {|| "Carregamento: "}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040)
	oSSlBP := TSay():New(025, 005, {|| " Prev.: " + AllTrim(cTSlBPre)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	oSSlBR := TSay():New(040, 005, {|| " Real.: " + AllTrim(cTSlBRea)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	oSSlBD := TSay():New(055, 005, {|| " Dig. : " + AllTrim(cTSlBDig)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	
	If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")
		TSay():New(015, 085, {|| "Trato: "}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040)
		oSSlTP := TSay():New(025, 080, {|| " Prev.: " + AllTrim(cTSlTPre)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
		oSSlTR := TSay():New(040, 080, {|| " Real.: " + AllTrim(cTSlTRea)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
		oSSlTD := TSay():New(055, 080, {|| " Dig. : " + AllTrim(cTSlTDig)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	EndIf
Else

	oSSlBP:SetText(" Prev.: " + AllTrim(cTSlBPre))
	oSSlBR:SetText(" Real.: " + AllTrim(cTSlBRea))
	oSSlBD:SetText(" Dig. : " + AllTrim(cTSlBDig))
	
	If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")
		oSSlTP:SetText(" Prev.: " + AllTrim(cTSlTPre))
		oSSlTR:SetText(" Real.: " + AllTrim(cTSlTRea))
		oSSlTD:SetText(" Dig. : " + AllTrim(cTSlTDig))
	EndIf
EndIf

//If ((ValType(oGrdFRt) != "U") .AND. (ValType(oGrdFTr) != "U"))
	oGrdFRt:Refresh(.T.)
	oGrdFTr:Refresh(.T.)
//EndIf

Return (lVldTSl)


Static Function TotEI(oPanel, lIni)

Local oTFntTt := TFont():New('Courier New',,18,.T.,.T.)  
Local cQryTot := ""
Local lVldTEI := .T.
Local cTEITPre := ""
Local cTEITRea := ""
Local cTEITDig := ""
Local cTEIBPre := ""
Local cTEIBRea := ""
Local cTEIBDig := ""

cQryTot := " SELECT SUM(Z0Y.Z0Y_QTDPRE) AS TOTPRE, SUM(Z0Y.Z0Y_QTDREA) AS TOTREA, SUM(Z0Y.Z0Y_PESDIG) AS TOTDIG "
cQryTot += " FROM " + RetSqlName("Z0Y") + " Z0Y "
cQryTot += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'"
cQryTot += "   AND Z0Y.D_E_L_E_T_ = ' ' "
cQryTot += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'"
cQryTot += "   AND Z0Y.Z0Y_ORDEM = '" + IIf(lIni, Z0Y->Z0Y_ORDEM, oGrdFRt:aCols[oGrdFRt:nAt][3]) + "'" 
cQryTot += "   AND Z0Y.Z0Y_RECEIT = '" + IIf(lIni, Z0Y->Z0Y_RECEIT, Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) ) + "'" + _ENTER_

TCQUERY cQryTot NEW ALIAS "QRYTOT"

If (!QRYTOT->(EOF()))
	MEMOWRITE("C:\TOTVS_RELATORIOS\TOTORDCARREG.sql", cQryTot)
	cTEIBPre := TRANSFORM(QRYTOT->TOTPRE, "@E 999,999,999")
	cTEIBRea := TRANSFORM(QRYTOT->TOTREA, "@E 999,999,999")
	cTEIBDig := TRANSFORM(QRYTOT->TOTDIG, "@E 999,999,999")
EndIf
QRYTOT->(DBCloseArea())

If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")

	cQryTot := "   SELECT SUM(Z0W.Z0W_QTDPRE) AS TOTPRE, SUM(Z0W.Z0W_QTDREA) AS TOTREA, SUM(Z0W.Z0W_PESDIG) AS TOTDIG "
	cQryTot += "   FROM " + RetSqlName("Z0W") + " Z0W "
	cQryTot += "   WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "'"
	cQryTot += "   AND Z0W.D_E_L_E_T_ = ' ' "
	cQryTot += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'"
	cQryTot += "   AND Z0W.Z0W_ORDEM = '" + IIf(lIni, Z0Y->Z0Y_ORDEM, oGrdFRt:aCols[oGrdFRt:nAt][3]) + "'"
	cQryTot += "   AND Z0W.Z0W_RECEIT = '" + IIf(lIni, Z0Y->Z0Y_RECEIT, Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) ) + "'" + _ENTER_
	
	TCQUERY cQryTot NEW ALIAS "QRYTOT"
	
	If (!QRYTOT->(EOF()))
		MEMOWRITE("C:\TOTVS_RELATORIOS\TOTORDDESC.sql", cQryTot)
		cTEITPre := TRANSFORM(QRYTOT->TOTPRE, "@E 999,999,999")
		cTEITRea := TRANSFORM(QRYTOT->TOTREA, "@E 999,999,999")
		cTEITDig := TRANSFORM(QRYTOT->TOTDIG, "@E 999,999,999")
	EndIf
	QRYTOT->(DBCloseArea())
EndIf

If (lIni)

	TSay():New(015, 005, {|| "Carregamento: "}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040)
	oSORBP := TSay():New(025, 005, {|| "Prev.: " + AllTrim(cTEIBPre)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	oSORBR := TSay():New(040, 005, {|| "Real.: " + AllTrim(cTEIBRea)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	oSORBD := TSay():New(055, 005, {|| "Dig. : " + AllTrim(cTEIBDig)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)

	If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")
	
		TSay():New(015, 085, {|| "Trato: "}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040)
		oSORTP := TSay():New(025, 080, {|| " Prev.: " + AllTrim(cTEITPre)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
		oSORTR := TSay():New(040, 080, {|| " Real.: " + AllTrim(cTEITRea)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
		oSORTD := TSay():New(055, 080, {|| " Dig. : " + AllTrim(cTEITDig)}, oPanel,,oTFntTt,,,,.T., CLR_BLACK, CLR_WHITE, 080, 040)
	
	EndIf

Else

	oSORBP:SetText(" Prev.: " + AllTrim(cTEIBPre))
	oSORBR:SetText(" Real.: " + AllTrim(cTEIBRea))
	oSORBD:SetText(" Dig. : " + AllTrim(cTEIBDig))
	
	If (Z0X->Z0X_OPERAC == "1") // (Z0X->Z0X_OPERAC != "2")
		oSORTP:SetText(" Prev.: " + AllTrim(cTEITPre))
		oSORTR:SetText(" Real.: " + AllTrim(cTEITRea))
		oSORTD:SetText(" Dig. : " + AllTrim(cTEITDig))
	EndIf

EndIf

Return (lVldTEI)



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 20.01.2020                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Funcao para forcar o preenchimento do campo Motivo de Correcao;	   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |                                                                                 |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Param:                                                                          |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function VldPesDig()
Local lRet := .T.
Local oViwAt  := nil
Local oMdlAt := nil
// If StrTran(ReadVar(), "M->", "") == "Z0W_PESDIG"
If FwFldGet(SubStr(StrTran(ReadVar(), "M->", ""), 1, 3) + '_PESDIG') > 0 .and.;
		Empty( FwFldGet(SubStr(StrTran(ReadVar(), "M->", ""), 1, 3) + '_MOTCOR') )
		
 	lRet := .F.
	MsgInfo("E Obrigatrio informar um motivo quando informar o Peso Manualmente")
EndIf

if lRet
	oMdlAt  := FWModelActive()
	oViwAt  := FWViewActive()
	if oViwAt:GetModel("MdGrdZ0Y"):IsUpdated() .or. ((Z0X->Z0X_OPERAC = "1") .and. oViwAt:GetModel("MdGrdZ0W"):IsUpdated())
	    // FWFormCommit( oMdlAt )
		oViwAt:Refresh("MdGrdZ0Y")
	
		If (Z0X->Z0X_OPERAC == "1")
			oViwAt:Refresh("MdGrdZ0W")
		EndIf
	endif
endif

Return lRet


/* ######################################################################################################### */
Static Function LegCur(oPanel, lIni)

Local aArea   := GetArea()
Local lVldLCr := .T.
Local oTFntGr := TFont():New('Courier New', , 16, .T., .T.)
Local oMdlAt  := FWModelActive()
// Local oViwAt  := FWViewActive()
Local cLote   := oMdlAt:GetModel("MdGrdZ0W"):GetValue("Z0W_LOTE", oMdlAt:GetModel("MdGrdZ0W"):GetLine())
Local nColLCr := 020
Local nTotTrt := GETMV("VA_NTRATO")
Local nCntTrt := 0
Local aTotLCr := {}
Local nSomTTP := 0
// Local nSomTTC := 0
Local nSomTTR := 0

// return .T.

// DBSelectArea("Z0W")
Z0W->(DBSetOrder(5)) //Lote+Data+Versao
Z0W->(DBGoTop())

aTotLCr := {}
If (Z0W->(DBSeek(xFilial("Z0W") + cLote + DTOS(Z0X->Z0X_DATA) + Z0X->Z0X_VERSAO + Z0X->Z0X_CODIGO)))
	While (cLote = Z0W->Z0W_LOTE .AND. Z0W->Z0W_DATA = Z0X->Z0X_DATA .AND. Z0W->Z0W_VERSAO = Z0X->Z0X_VERSAO .AND. Z0W->Z0W_CODEI = Z0X->Z0X_CODIGO)
		AAdd( aTotLCr, { Z0W->Z0W_TRATO,;
		 				 Z0W->Z0W_QTDPRE,;
		 				 Z0W->Z0W_QTDREA,;
		 				 Z0W->Z0W_KGRECA })
		Z0W->(DBSkip())
	EndDo
EndIf

If (lIni)
	
	aObjLCrP := {}
	aObjLCrC := {}
	aObjLCrR := {}
	
	TSay():New(000, nColLCr, {|| " Tratos Previstos    - "}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 045)
	//TSay():New(010, nColLCr, {|| " Tratos Recalculados - "}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 045)
	TSay():New(015/* 020 */, nColLCr, {|| " Tratos Realizados   - "}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 045)
	
	nColLCr += 105
	
	If Len(aTotLCr) > nTotTrt
		nTotTrt := Len(aTotLCr)
	EndIf
	
	For nCntTrt := 1 To nTotTrt
	
		AAdd(aObjLCrP, TSay():New(000, nColLCr, {|| IIf(nCntTrt > Len(aTotLCr), "", AllTrim(aTotLCr[nCntTrt][1]) + ": " + TRANSFORM(aTotLCr[nCntTrt][2], "@E 999,999"))}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 060, 040))
		//AAdd(aObjLCrC, TSay():New(010, nColLCr, {|| IIf(nCntTrt > Len(aTotLCr), "", AllTrim(aTotLCr[nCntTrt][1]) + ": " + TRANSFORM(aTotLCr[nCntTrt][4], "@E 999,999"))}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 060, 040))
		AAdd(aObjLCrR, TSay():New(020, nColLCr, {|| IIf(nCntTrt > Len(aTotLCr), "", AllTrim(aTotLCr[nCntTrt][1]) + ": " + TRANSFORM(aTotLCr[nCntTrt][3], "@E 999,999"))}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 060, 040))
		
		nSomTTP += IIf(nCntTrt > Len(aTotLCr), 0, aTotLCr[nCntTrt][2])
		//nSomTTC += IIf(nCntTrt > Len(aTotLCr), 0, aTotLCr[nCntTrt][4])
		nSomTTR += IIf(nCntTrt > Len(aTotLCr), 0, aTotLCr[nCntTrt][3])
	
		nColLCr += 70
	Next nCntTrt
	
	AAdd(aObjLCrP, TSay():New(000, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))
	//AAdd(aObjLCrC, TSay():New(010, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))
	AAdd(aObjLCrR, TSay():New(020, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))

Else

	For nCntTrt := 1 To Len(aTotLCr) // nTotTrt // Len(aTotLCr)
	
		aObjLCrP[nCntTrt]:SetText(aTotLCr[nCntTrt][1] + ": " + TRANSFORM(aTotLCr[nCntTrt][2], "@E 999,999"))
		//aObjLCrC[nCntTrt]:SetText(aTotLCr[nCntTrt][1] + ": " + TRANSFORM(aTotLCr[nCntTrt][4], "@E 999,999"))
		aObjLCrR[nCntTrt]:SetText(aTotLCr[nCntTrt][1] + ": " + TRANSFORM(aTotLCr[nCntTrt][3], "@E 999,999"))
	
		nSomTTP += aTotLCr[nCntTrt][2]
		//nSomTTC += aTotLCr[nCntTrt][4]
		nSomTTR += aTotLCr[nCntTrt][3]
	
	Next nCntTrt

	aObjLCrP[ nCntTrt ]:SetText("Total: " + TRANSFORM(nSomTTP, "@E 999,999"))
	//aObjLCrC[ nCntTrt ]:SetText("Total: " + TRANSFORM(nSomTTC, "@E 999,999"))
	aObjLCrR[ nCntTrt ]:SetText("Total: " + TRANSFORM(nSomTTR, "@E 999,999"))

	For nCntTrt := Len(aTotLCr)+2 To Len(aObjLCrP)
		aObjLCrP[nCntTrt]:SetText("")
		//aObjLCrC[nCntTrt]:SetText("")
		aObjLCrR[nCntTrt]:SetText("")
	Next nCntTrt

/* 
	// corrigir vetor
	If !(Len(aTotLCr)+1 == Len(aObjLCrP))
		For nI := Len(aObjLCrP) to Len(aTotLCr)+1
			If Len(aObjLCrP) < Len(aTotLCr)+1
				AAdd(aObjLCrP, TSay():New(000, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))
				AAdd(aObjLCrC, TSay():New(010, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))
				AAdd(aObjLCrR, TSay():New(020, nColLCr, {|| ""}, oPanel,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 090, 040))
			EndIf
		Next nI	
	EndIf
 */
EndIf

RestArea(aArea)

Return (lVldLCr)


Static Function MarkTrt(nLin, nOpc)

	Local lVldMrk := .T.
	Local cQryUpd := ""
	Local cQryCfr := ""
	Local nCntMrk := 1
	Local cVldCfr := aTik[1]

// valida se pode aceitar o CONFERIR
	if !(lVldMrk := fMJValid(dToS(Z0X->Z0X_DATA)))
		Return (lVldMrk)
	EndIf

	cQryUpd := " UPDATE " + RetSqlName("Z0Y") + _ENTER_
	cQryUpd += " SET Z0Y_CONFER = '" + IIf(aClsGFR[oGrdFRt:nAt, 2] = aTik[1], 'F', 'T') + "'" + _ENTER_
	cQryUpd += "   , Z0Y_DATCFR = '" + DTOS(Date()) + "'" + _ENTER_
	cQryUpd += "   , Z0Y_HORCFR = '" + SUBSTR(TIME(), 1, 5) + "'" + _ENTER_
	cQryUpd += " WHERE Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
	cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
	cQryUpd += "   AND Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryUpd += "   AND Z0Y_ORDEM = '" + aDadSel[1]  + "'" + _ENTER_
	cQryUpd += IIf(nOpc = 1, "", "   AND lTrim(Z0Y_TRATO) = '" + AllTrim(aDadSel[2]) + "'") + _ENTER_

	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPCFRREC.sql", cQryUpd)

	If (TCSqlExec(cQryUpd) < 0)
		MsgInfo(TCSqlError())
	EndIf

	cQryUpd := " UPDATE " + RetSqlName("Z0W") + _ENTER_
	cQryUpd += " SET Z0W_CONFER = '" + IIf(aClsGFR[oGrdFRt:nAt, 2] = aTik[1], 'F', 'T') + "'" + _ENTER_
	cQryUpd += "   , Z0W_DATCFR = '" + DTOS(Date()) + "'" + _ENTER_
	cQryUpd += "   , Z0W_HORCFR = '" + SUBSTR(TIME(), 1, 5) + "'" + _ENTER_
	cQryUpd += " WHERE Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
	cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
	cQryUpd += "   AND Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryUpd += "   AND Z0W_ORDEM = '" + aDadSel[1]  + "'" + _ENTER_
	cQryUpd += IIf(nOpc = 1, "", "   AND Z0W_TRATO = '" + aDadSel[2] + "'") + _ENTER_

	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPCFRTRT.sql", cQryUpd)

	If (TCSqlExec(cQryUpd) < 0)
		MsgInfo(TCSqlError())
	EndIf

	If (nOpc == 1)

		If (oGrdFRt:aCols[oGrdFRt:nAt, 2] = aTik[1])
			oGrdFRt:aCols[oGrdFRt:nAt, 2] := aTik[2]
		Else
			oGrdFRt:aCols[oGrdFRt:nAt, 2] := aTik[1]
		EndIf

		For nCntMrk := 1 To Len(oGrdFTr:aCols)
			oGrdFTr:aCols[nCntMrk, 2] := oGrdFRt:aCols[oGrdFRt:nAt, 2]
		Next nCntMrk

	ElseIf (nOpc == 2)

		If (oGrdFTr:aCols[oGrdFTr:nAt, 2] = aTik[1])
			oGrdFTr:aCols[oGrdFTr:nAt, 2] := aTik[2]
		Else
			oGrdFTr:aCols[oGrdFTr:nAt, 2] := aTik[1]
		EndIf

	EndIf

	For nCntMrk := 1 To Len(oGrdFTr:aCols)
		If (oGrdFTr:aCols[nCntMrk, 2] = aTik[2])
			cVldCfr := aTik[2]
		EndIf
	Next nCntMrk

	oGrdFRt:aCols[oGrdFRt:nAt][2] := cVldCfr

	cQryCfr := " SELECT * " + _ENTER_
	cQryCfr += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
	cQryCfr += " WHERE Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
	cQryCfr += "   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryCfr += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryCfr += "   AND Z0Y.Z0Y_CONFER = 'F' " + _ENTER_

	TCQUERY cQryCfr NEW ALIAS "QRYCFR"

	If (QRYCFR->(EOF()))
		RecLock("Z0X", .F.)
		Z0X->Z0X_STATUS := "C"
		Z0X->(MSUnlock())
	EndIf
	QRYCFR->(DBCloseArea())

	cQryCfr := " SELECT * " + _ENTER_
	cQryCfr += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
	cQryCfr += " WHERE Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
	cQryCfr += "   AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryCfr += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryCfr += "   AND Z0W.Z0W_CONFER = 'F' " + _ENTER_

	TCQUERY cQryCfr NEW ALIAS "QRYCFR"

	If (QRYCFR->(EOF()))
		RecLock("Z0X", .F.)
		Z0X->Z0X_STATUS := "C"
		Z0X->(MSUnlock())
	EndIf
	QRYCFR->(DBCloseArea())

	oGrdFRt:Refresh(.T.)
	oGrdFTr:Refresh(.T.)

Return (lVldMrk)

/* 
	MB : 02.04.2022
		-> Atualizacao dos parametros :  PERGUNTE := "VAPCPA13X"
*/
User Function ExpBatTrt( )

Local aArea         := GetArea()
Local cVersao       := "0001"
// Local cEquip           := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+aParRet[3], "ZV0_IDENT"))
Local cEquip        := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+aParRet[2], "ZV0_IDENT"))
Local cArqExJ       := "programacao.json"
Local cArqExC       := "programacao-" +AllTrim(Str(DAY(aParRet[1])))+;
						"-" +AllTrim(Str(Month(aParRet[1])))+;
						"-" +AllTrim(Str(Year(aParRet[1])))+;
						Iif(Empty(cEquip),"","-" + cEquip) +;
						"-V" + cVersao +".csv"
Local cLocArq       := ""
Local cJsnExp       := ""
Local cCsvExp       := ""
Local cCsvEBt       := ""
Local cCsvETr       := ""
Local cQryExp       := ""
Local cQryRec       := ""
Local cQryTTr       := ""
Local aResult       := {}
Local aEqpJsn       := {}
Local aOrdArq       := {}, a2OrdArq       := {}, lDesenv := .T., c2RArqChv := "", c2PArqChv := ""
Local aOrdCur       := {}, a2OrdCur       := {}
Local aCsvAux       := {}, nIniCsv := 1, nI:= 0, nQtdPrev:= 0
// , nTotPrev:= 0
Local nTmOrd        := 0
Local nCntEqp       := 0
Local nCntOrd       := 0
Local nCntTrt       := 0
Local nCntCmp       := 0, n2CntCmp := 0
Local nCntBat       := 0, nCol := 0
Local nCntCur       := 0
Local nTTrMS        := 0
Local nTTrMN        := 0
Local nPrcMT        := 0
Local nDivisa       := 0
Local nQtdPre       := 0
Local cSeqOrd       := ""
Local lCnt          := .T.
Local cCodRec       := ""
Local lMsmOrd       := .F.
Local cCodigo       := ""
Local lRet          := .T.
Local cTipo_carreg  := ""
Local aTipo_carreg  := {}
Local cMsgExp       := ""
Local nAllOuSoVazio := 0
Local lAux          := .T.
// Local aPhibro          := {}
Local _cRoteiro     := ""
Local aAguaZ0Y      := {}
Local nIagua        := 0
Local nPos          := 0
Local cAux          := ""
Local nIm           := 0, nIj := 0
Local __nCntTrt     := 0

Local xAux          := {}, _nQtdPreTT := 0, _nAgr := 0
Local _aZ0SQTCARR   := {}, _nZ0SQTCARR   := 0
//	, /*__nPAUX := */0

/* 
	MB : 19.08.2021
		-> Verificar se existe EXPORTACAO gerada;
			Se houver, nao sera permitido continuar a geracao GERAL (para todos);
			apenas por caminhao;
*/
// If (Empty(aParRet[3]) .and. Empty(aParRet[6])) .and.;
If (Empty(aParRet[2]) .and. Empty(aParRet[3])) .and.;
	TemExpGerada()

	MsgInfo("Esta operacao ser� cancelada pois j� foi encontrado trato exportado para este dia [" + DtoC(aParRet[1]) + "]."+CRLF+;
		"Favor exportar os caminh�es individulamente.")

	RestArea(aArea)
	Return (Nil)
EndIf

// MB : 15.03.2021
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// NAO PREENCHIDO

// if (Len(aParRet) == 5)
// 	/*06*/ AAdd(aParRet, MV_PAR04)
// EndIf
/* 23/11/2020 - Arthur Toshio
Atualmente a rotina verifica na Z0X equipamento por equipamento
*/
cQryExp := " SELECT MAX(Z0X.Z0X_VERSAO) AS VERSAO, Z0X.Z0X_STATUS  Z0X_STATUS " + _ENTER_
cQryExp += " FROM " + RetSqlName("Z0X") + " Z0X "  + _ENTER_
cQryExp += " WHERE Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_
cQryExp += "   AND Z0X.Z0X_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
/* MB : 20.02
	E preciso validar novamente se o equipamento esta preenchido,
	pois acima agora tem 2 validacoes: EQUIPAMENTOS e ROTA
*/
// EQUIPAMENTO
// if(!Empty(aParRet[3]))
if(!Empty(aParRet[2]))
	// cQryExp += "   AND Z0X.Z0X_EQUIP = '" + aParRet[3] + "'" + _ENTER_
	cQryExp += "   AND Z0X.Z0X_EQUIP = '" + aParRet[2] + "'" + _ENTER_
EndIf
// ROTA
// if (!Empty(aParRet[6]))
if (!Empty(aParRet[3]))
	cQryExp += "   AND Z0X_CODIGO IN (SELECT DISTINCT Z0Y_CODEI " + _ENTER_
	cQryExp += "                       FROM  " + RetSqlName("Z0Y") + "" + _ENTER_
	cQryExp += "				      WHERE Z0Y_FILIAL = '" + FWxFilial("Z0Y") + "'" + _ENTER_
	cQryExp += "   						AND Z0Y_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
	// cQryExp += "				        AND Z0Y_ROTA IN (" + AllTrim(aParRet[6]) + ")" + _ENTER_
	cQryExp += "				        AND Z0Y_ROTA IN (" + AllTrim(aParRet[3]) + ")" + _ENTER_
	cQryExp += "						AND D_E_L_E_T_ = ' ') " + _ENTER_
EndIf
cQryExp += "   AND Z0X.D_E_L_E_T_ = ' '  " + _ENTER_
cQryExp += " GROUP BY Z0X_STATUS "

MEMOWRITE( "C:\TOTVS_RELATORIOS\VAPCPA13_Geral.sql", cQryExp)
TCQUERY cQryExp NEW ALIAS "QRYVER"

If !(QRYVER->(EOF()))
	If(QRYVER->Z0X_STATUS $ "P,I")
		MsgInfo("J� Existe um Arquivo Importado ou Processado para o equipamento " +cEquip+" no dia " +AllTrim(Str(DAY(aParRet[1])))+ "-" +AllTrim(Str(Month(aParRet[1])))+"-" +AllTrim(Str(Year(aParRet[1])))+". Por favor verifique os par�metros")
		lRet := .F.
	Else
		cVersao  := Soma1(QRYVER->VERSAO)
		cArqExC := "programacao-" +AllTrim(Str(DAY(aParRet[1])))+ "-" +;
			AllTrim(Str(Month(aParRet[1])))+"-" +;
			AllTrim(Str(Year(aParRet[1])))+"-" +;
			cEquip+;
			"-V" + cVersao +".csv"
	EndIf
EndIf
QRYVER->(DBCloseArea())

If!lRet
	RestArea(aArea)
	Return (Nil)
EndIf
If(Empty( cVersao ))
	cVersao  := StrZero(1, TamSX3('Z0R_VERSAO')[1]) // "0001"
EndIf

// MB : 15.03.2021
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// PREENCHIDO
// If Empty(aParRet[3])
If Empty(aParRet[2])
	nAllOuSoVazio := AVISO("Atencao",;
		'Campo EQUIPAMENTO nao localizado.'+CRLF+'Deseja gerar para TODOS ou somente os VAZIOS ???',;
		{ "Vazios", "Todos", "Cancelar" }, 2)
	If (nAllOuSoVazio == 3) // Cancelar
		return nil
	EndIf

	/*
		MB : 22.02.2021
			Validar se existe versao maior que 0001; se tiver entao a operacao nao pode continuar;
	*/
	if nAllOuSoVazio==2 .AND. (!Empty(cAux:=fTemVersaoMaior()))
		MsgInfo("Esta operacao ser� cancelada pois foi encontrata exportacao adicional: " + cAux)
		return nil
	EndIf
Else
	// AAdd(aEqpJsn, aParRet[3])
	AAdd(aEqpJsn, aParRet[2])
EndIf

// * TODOS * VAZIOS * CANCELAR
// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica

cQryEqp := " SELECT"
cQryEqp += "   DISTINCT"
cQryEqp += "              Z0S.Z0S_EQUIP AS EQUIP " + _ENTER_
cQryEqp += "            , Z0S.Z0S_ROTA   " + _ENTER_
cQryEqp += "            , Z0S.Z0S_QTCARR " + _ENTER_
cQryEqp += " FROM " + RetSqlName("Z0S") + " Z0S " + _ENTER_
cQryEqp += " WHERE Z0S.Z0S_FILIAL = '" + xFilial("Z0S")   + "'" + _ENTER_
cQryEqp += "   AND Z0S.Z0S_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_
cQryEqp += "   AND Z0S.Z0S_VERSAO = '" +  cVersao  + "'" + _ENTER_
cQryEqp += _ENTER_

If ( nAllOuSoVazio == 1 )
	cQryEqp += " AND Z0S.Z0S_EQUIP = '      '" + _ENTER_
Else
	// If(!Empty(aParRet[3])) // EQUIPAMENTO
	If(!Empty(aParRet[2])) // EQUIPAMENTO
		// cQryEqp += " AND Z0S.Z0S_EQUIP = '" + aParRet[3] + "'" + _ENTER_
		cQryEqp += " AND Z0S.Z0S_EQUIP = '" + aParRet[2] + "'" + _ENTER_
	Else
		cQryEqp += " AND Z0S.Z0S_ROTA IN (" + _ENTER_
		cQryEqp += "               SELECT  Z0T.Z0T_ROTA AS EQUIP " + _ENTER_
		cQryEqp += "               FROM	 " +RetSqlName('Z0T')+ " Z0T " + _ENTER_
		cQryEqp += "               WHERE   Z0T.Z0T_FILIAL = '"+FwxFilial("Z0T")+"' " + _ENTER_
		cQryEqp += "                   AND Z0T.Z0T_DATA   = Z0S.Z0S_DATA " + _ENTER_
		cQryEqp += "                   AND Z0T.Z0T_VERSAO = Z0S.Z0S_VERSAO " + _ENTER_
		cQryEqp += "                   AND Z0T.D_E_L_E_T_ = ' '" + _ENTER_
		cQryEqp += "  )" + _ENTER_
		cQryEqp += _ENTER_
		cQryEqp += "--    AND Z0S.Z0S_EQUIP NOT IN ( " + _ENTER_
		cQryEqp += "--                               SELECT Z0X.Z0X_EQUIP AS EQUIP " + _ENTER_
		cQryEqp += "-- 		                      FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_
		cQryEqp += "--                               WHERE Z0X.Z0X_FILIAL = '" + xFilial("Z0S") + "'" + _ENTER_
		cQryEqp += "-- 		                        AND Z0X.Z0X_DATA   = Z0S.Z0S_DATA " + _ENTER_
		cQryEqp += "--                                 AND Z0X.Z0X_VERSAO = Z0S.Z0S_VERSAO " + _ENTER_
		cQryEqp += "--    			                    AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_
		cQryEqp += "--    			        ) " + _ENTER_
	EndIf
EndIf
cQryEqp += "   AND Z0S.D_E_L_E_T_ = ' ' " + _ENTER_

// ElseIf (aParRet[4] == 2)
//
// 	cQryEqp := " SELECT DISTINCT Z0J.Z0J_EQUIPA AS EQUIP " + _ENTER_
// 	cQryEqp += " FROM " + RetSqlName("Z0J") + " Z0J " + _ENTER_
// 	cQryEqp += " WHERE Z0J.Z0J_FILIAL = '" + xFilial("Z0J") + "'" + _ENTER_
// 	cQryEqp += "   AND Z0J.Z0J_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_
// 	// cQryEqp += "   AND Z0J.Z0J_VERSAO = '" +  cVersao  + "'" + _ENTER_
// 	If(!Empty(aParRet[3])) // EQUIPAMENTO
// 		cQryEqp += " AND ISNULL(Z0J.Z0J_EQUIPA, '      ') = '" + aParRet[3] + "'" + _ENTER_
// 	EndIf
// 	cQryEqp += "   AND Z0J.D_E_L_E_T_ = ' ' " + _ENTER_
// 	// cQryEqp += "   AND Z0J.Z0J_EQUIPA <> '' " + _ENTER_
//
// EndIf

MEMOWRITE( "C:\TOTVS_RELATORIOS\VAPCPA13_Equipamentos.sql", cQryEqp)
TCQUERY cQryEqp NEW ALIAS "QRYEQP"

While (!(QRYEQP->(EOF())))
	If (aScan(aEqpJsn, {|x| x == QRYEQP->EQUIP}) < 1)
		AAdd(aEqpJsn, QRYEQP->EQUIP)
	EndIf
	//Alert("Equipamento " + QRYEQP->EQUIP + "rota "+ QRYEQP->Z0S_ROTA)
	If aScan( _aZ0SQTCARR, { |x| x[1] + x[2] == QRYEQP->EQUIP + QRYEQP->Z0S_ROTA} ) < 1
		AAdd( _aZ0SQTCARR, {;
								QRYEQP->EQUIP     ,;
								QRYEQP->Z0S_ROTA  ,;
								QRYEQP->Z0S_QTCARR ;
			})
	EndIf
	QRYEQP->(DBSkip())
EndDo
QRYEQP->(DBCloseArea())

// MsgAlert(U_AtoS(_aZ0SQTCARR), "Ponto 01")

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// MB : 15.03.2021
For nCntEqp := 1 To Len(aEqpJsn)

	// If (aParRet[4] == 1) // 1 == Trato; 2 = Fabrica

	// Posiciona a Z0R para identificar a �ltima versao do trato
	DbSelectArea("Z0R")
	DbSetOrder(1) // Z0R_FILIAL + Z0R_DATA + Z0R_VERSAO

	DbUseArea(.t., "TOPCONN", TCGenQry(,,;
						_cSql := " select max(Z0R_VERSAO) Z0R_VERSAO" + _ENTER_ +;
						" from " + RetSqlName("Z0R") + " Z0R" + _ENTER_ +;
						" where Z0R.Z0R_FILIAL = '" + FWxFilial("Z0R") + "'" + _ENTER_ +;
						" and Z0R.Z0R_DATA   = '" + DToS(aParRet[1]) + "'" + _ENTER_ +;
						" and Z0R.D_E_L_E_T_ = ' '" ;
						), "TMPZ0R", .f., .f.)
	Z0R->(DbSeek(FWxFilial("Z0R")+DToS(aParRet[1])+TMPZ0R->Z0R_VERSAO))
	TMPZ0R->(DbCloseArea())

	cQryExp := " SELECT Z06.Z06_DATA AS DATA, Z06.Z06_VERSAO AS VERSAO, Z06.Z06_CURRAL AS CURRAL, Z06.Z06_TRATO AS TRATO, Z06.Z06_LOTE AS LOTE " + _ENTER_
	cQryExp += "      , Z0T.Z0T_ROTA AS ROTA, Z0S.Z0S_TOTTRT AS TOTTRT, ISNULL(Z0S.Z0S_EQUIP,'      ') AS EQUIP, ISNULL(Z0S.Z0S_OPERAD,' ') AS OPERAD, Z06.Z06_DIETA AS DIETA, Z0S_QTCARR " + _ENTER_
	cQryExp += "      , ((SELECT Z05.Z05_CABECA FROM " + RetSqlName("Z05") + " Z05 WHERE Z05.Z05_DATA = Z06.Z06_DATA AND Z05.Z05_VERSAO = Z06.Z06_VERSAO AND Z05.Z05_CURRAL = Z06.Z06_CURRAL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ = ' ') * Z06.Z06_KGMSTR) AS KGMS  " + _ENTER_
	cQryExp += "      ,  (SELECT Z05.Z05_CABECA FROM " + RetSqlName("Z05") + " Z05 WHERE Z05.Z05_DATA = Z06.Z06_DATA AND Z05.Z05_VERSAO = Z06.Z06_VERSAO AND Z05.Z05_CURRAL = Z06.Z06_CURRAL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ = ' ') AS QTDCAB "
	cQryExp += " FROM " + RetSqlName("Z06") + " Z06 " + _ENTER_
	cQryExp += " RIGHT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z06.Z06_DATA AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO AND Z0T.Z0T_CURRAL = Z06.Z06_CURRAL AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryExp += " LEFT  JOIN " + RetSqlName("Z0S") + " Z0S ON Z0S.Z0S_DATA = Z0T.Z0T_DATA AND Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO AND Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA   AND Z0S.Z0S_FILIAL = '" + xFilial("Z0T") + "' AND Z0S.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryExp += " WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "'" + _ENTER_
	cQryExp += "   AND Z06.Z06_DATA   = '" + DTOS(Z0R->Z0R_DATA) + "'" + _ENTER_
	cQryExp += "   AND Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + _ENTER_ //" +  cVersao  + "'" + _ENTER_

	/* validacao EQUIPAMENTOS e ROTA; se nao preenchido no parametro entao pegar o equipamento
		do parametro aEqpJsn */
	lAux := .T.
	// if (!Empty(aParRet[6]))
	if (!Empty(aParRet[3]))
		// cQryExp += "   AND Z0S.Z0S_ROTA IN (" + AllTrim(aParRet[6]) + ")" + _ENTER_
		cQryExp += "   AND Z0S.Z0S_ROTA IN (" + AllTrim(aParRet[3]) + ")" + _ENTER_
		lAux := .F.
	EndIf
	// if(!Empty(aParRet[3]))
	if(!Empty(aParRet[2]))
		// cQryExp += "   AND ISNULL(Z0S.Z0S_EQUIP, '      ') = '" + aParRet[3] + "'" + _ENTER_
		cQryExp += "   AND ISNULL(Z0S.Z0S_EQUIP, '      ') = '" + aParRet[2] + "'" + _ENTER_
		lAux := .F.
	EndIf
	// If lAux .and. ( !(Empty(aParRet[3]) .and. Empty(aParRet[6])) .Or. nAllOuSoVazio==2 )
	If lAux .and. ( !(Empty(aParRet[3]) .and. Empty(aParRet[3])) .Or. nAllOuSoVazio==2 )
		cQryExp += "   AND ISNULL(Z0S.Z0S_EQUIP, '      ')  = '" + aEqpJsn[nCntEqp] + "'" + _ENTER_
	EndIf
	//cQryExp += "   AND Z06.Z06_CURRAL IN (SELECT Z05.Z05_CURRAL FROM " + RetSqlName("Z05") + " Z05 WHERE Z05.Z05_DATA = Z06.Z06_DATA AND Z05.Z05_VERSAO = Z06.Z06_VERSAO AND Z05.Z05_LOCK < '2' AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ = ' ') "
	cQryExp += "   AND Z06.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryExp += " ORDER BY Z06.Z06_DATA, Z06.Z06_VERSAO, Z0T.Z0T_ROTA, Z06.Z06_TRATO, Z06.Z06_CURRAL "


	/* MB : 24.11.2021
		- Processamento SQL para levantar as receitas com itens para PHIBRO=P e IMBIF=I;
			Se localizado receitas com itens nesta origem, entao sera descontado uma quantidade definida em parametro
			da agua;
		*/
	_cSqlAgua := " WITH " + CRLF +;
				 " DADOS AS (" + CRLF +;
				 " 	 SELECT * " + CRLF +;
				 " 	 FROM ( " + CRLF +;
				 "  			 SELECT DISTINCT " + CRLF +;
				 " 				    ZG1.ZG1_COD AS RECEITA, ZG1.ZG1_COMP AS ITEM" + CRLF +;
				 "  		          ,	ZG1.ZG1_QUANT AS QUANT, Z0V.Z0V_INDMS AS INDMS" + CRLF +;
				 "  		          ,	ZG1.ZG1_TIMER AS TIMER,	ZG1.ZG1_TRT AS SEQ " + CRLF +;
				 " 				  , ZG1_ORIGEM ORIGEM" + CRLF +;
				 "  				  FROM " +RetSqlName('ZG1')+ " ZG1 " + CRLF +;
				 "  			RIGHT JOIN " +RetSqlName('Z0V')+ " Z0V ON Z0V.Z0V_FILIAL = '"+FwxFilial("Z0V")+"'" + CRLF +;
				 "  													 AND Z0V.Z0V_COMP = ZG1.ZG1_COMP" + CRLF +;
				 "  													 AND Z0V.D_E_L_E_T_ = ' ' " + CRLF +;
				 "  			WHERE ZG1.ZG1_FILIAL = '"+FwxFilial("ZG1")+"'" + CRLF +;
				 "  			  AND ZG1.ZG1_COD IN (" + CRLF +;
				 "   					    SELECT distinct Z06.Z06_DIETA AS DIETA" + CRLF +;
				 " 						FROM " +RetSqlName('Z06')+ " Z06 " + CRLF +;
				 " 						 RIGHT JOIN " +RetSqlName('Z0T')+ " Z0T ON Z0T.Z0T_DATA = Z06.Z06_DATA AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO AND Z0T.Z0T_CURRAL = Z06.Z06_CURRAL AND Z0T.Z0T_FILIAL = '"+FwxFilial("Z0T")+"' AND Z0T.D_E_L_E_T_ = ' ' " + CRLF +;
				 " 						 WHERE Z06.Z06_FILIAL = '"+FWxFilial("Z06")+"'" + CRLF +;
				 " 						   AND Z06.Z06_DATA   = '" + DTOS(Z0R->Z0R_DATA) + "'" + CRLF +;
				 " 						   AND Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
				 " 						   AND Z06.D_E_L_E_T_ = ' ' 		  " + CRLF +;
				 " 			  )" + CRLF +;
				 "  			  AND ZG1.ZG1_SEQ = (" + CRLF +;
				 "  			  			      			SELECT MAX(ZG1A.ZG1_SEQ)" + CRLF +;
				 "  			  			      			FROM " +RetSqlName('ZG1')+ " ZG1A" + CRLF +;
				 "  			  			      			WHERE ZG1A.ZG1_FILIAL = '"+FWxFilial("ZG1")+"'" + CRLF +;
				 "  		  				      				AND ZG1A.ZG1_COD = ZG1.ZG1_COD" + CRLF +;
				 "  		  				      				AND ZG1A.D_E_L_E_T_ = ' '" + CRLF +;
				 " 									) " + CRLF +;
				 "  			  AND Z0V.Z0V_DATA    = '" + DTOS(Z0R->Z0R_DATA) + "'" + CRLF +;
				 "  			  AND Z0V.Z0V_VERSAO  = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
				 "  			  AND ZG1.ZG1_FILIAL = '"+FwxFilial("ZG1")+"' AND ZG1.D_E_L_E_T_ = ' ' " + CRLF +;
				 " 	 ) DADOS " + CRLF +;
				 " )" + CRLF +;
				 " " + CRLF +;
				 " , FILTRO_ORIGEM AS (" + CRLF +;
				 " 		SELECT	RECEITA" + CRLF +;
				 " 			  , ORIGEM" + CRLF +;
				 " 		FROM	DADOS " + CRLF +;
				 " 		WHERE	ORIGEM IN ( " + GetMV( "MB_PCPA13R",, "'P', 'I'") + " )" + CRLF +;
				 " )" + CRLF +;
				 " " + CRLF +;
				 " , FILTRO_AGUA AS (" + CRLF +;
				 " 		SELECT	RECEITA, ITEM, ORIGEM" + CRLF +;
				 " 		FROM	DADOS" + CRLF +;
				 " 		WHERE	ITEM = '" + GetMV( "MB_PCPA13A",, "990012") + "'" + CRLF +; // Codigo da Agua
				 " )" + CRLF +;
				 " " + CRLF +;
				 " , DADOS2 AS (" + CRLF +;
				 " 		SELECT		DISTINCT" + CRLF +;
				 " 					O.RECEITA" + CRLF +;
				 " 					, ISNULL(ITEM, '') AGUA" + CRLF +;
				 " 					, O.ORIGEM" + CRLF +;
				 " 		FROM		FILTRO_ORIGEM O" + CRLF +;
				 " 		LEFT JOIN	FILTRO_AGUA   A ON O.RECEITA = A.RECEITA" + CRLF +;
				 " )" + CRLF +;
				 " " + CRLF +;
				 " , CONTAGEM AS (" + CRLF +;
				 " 		SELECT RECEITA, COUNT(RECEITA) QTD" + CRLF +;
				 " 		FROM DADOS2" + CRLF +;
				 " 		GROUP BY RECEITA " + CRLF +;
				 " )" + CRLF +;
				 " " + CRLF +;
				 " SELECT DISTINCT D.*, C.QTD" + CRLF +;
				 " FROM DADOS2 D " + CRLF +;
				 " CROSS JOIN CONTAGEM C" + CRLF +;
				 " ORDER BY 1, 2"
	MEMOWRITE( "C:\TOTVS_RELATORIOS\Validacao_Agua_" + iIf(empty(aEqpJsn[nCntEqp]),"","_" +aEqpJsn[nCntEqp]) + ".sql", _cSqlAgua)
	TCQUERY _cSqlAgua NEW ALIAS "TMPEXPAGUA"

	_aReceitaOrigem := {}
	While !(TMPEXPAGUA->(Eof()))
		aAdd( _aReceitaOrigem, {;
			AllTrim( TMPEXPAGUA->RECEITA ),;
			AllTrim( TMPEXPAGUA->AGUA    ),;
			AllTrim( TMPEXPAGUA->ORIGEM  ),;
			TMPEXPAGUA->QTD;
			})
		TMPEXPAGUA->(DbSkip())
	EndDo
	TMPEXPAGUA->(DbCloseArea())

	// ElseIf (aParRet[4] == 2)
	// 	cQryExp := " SELECT Z0J.Z0J_DATA AS DATA, Z0J.Z0J_VERSAO AS VERSAO, Z0J.Z0J_QUANT AS TOTBAT, Z0J.Z0J_EQUIPA AS EQUIP " + _ENTER_
	// 	cQryExp += "      , Z0J.Z0J_PRODUT AS DIETA, Z0J.Z0J_BATIDA AS QTDBAT "  + _ENTER_
	// 	cQryExp += " FROM " + RetSqlName("Z0J") + " Z0J " + _ENTER_
	// 	cQryExp += " WHERE Z0J.Z0J_FILIAL = '" + xFilial("Z0J") + "'" + _ENTER_
	// 	cQryExp += "   AND Z0J.Z0J_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_
	// 	// Nao existe tratameto de versao na F�brica.
	// 	// cQryExp += "   AND Z0J.Z0J_VERSAO = '" + aParRet[2] + "'" + _ENTER_
	// 	cQryExp += "   AND Z0J.Z0J_EQUIPA = '" + aEqpJsn[nCntEqp] + "'" + _ENTER_
	// 	cQryExp += "   AND Z0J.Z0J_EXPGER <> '1' " + _ENTER_
	// 	cQryExp += "   AND Z0J.D_E_L_E_T_ = ' ' " + _ENTER_
	// 	cQryExp += " ORDER BY Z0J.Z0J_EQUIPA, Z0J.Z0J_PRODUT "
	// EndIf

	_cPath := "C:\TOTVS_RELATORIOS\EXPMAIN" +;
		Iif(nAllOuSoVazio==2, "", iIf(empty(aEqpJsn[nCntEqp]), "", "_" +aEqpJsn[nCntEqp])) + ".sql"
	// iIf(empty(aEqpJsn[nCntEqp]), "", "_" +aEqpJsn[nCntEqp]) + ".sql"
	MEMOWRITE( _cPath, cQryExp)
	if Select("QRYEXP") > 0
		QRYEXP->(DbCloseArea())
	EndIf
	TCQUERY cQryExp NEW ALIAS "QRYEXP"

	_cEquipamento := aEqpJsn[nCntEqp]	// aParRet[3] := aEqpJsn[nCntEqp]

	Begin Transaction

		If (!(QRYEXP->(EOF())))

			aResult := Array(#)
			aResult[#'equipamento'] := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT"))
			nDivisa := iIf( Empty(ZV0->ZV0_DIVISA), GetMV("VA_ZV0DIVI",,10), ZV0->ZV0_DIVISA)

			DBSelectArea("Z0X")
			Z0X->(DBSetOrder(1))

			RecLock("Z0X", .T.)
			Z0X->Z0X_FILIAL := xFilial("Z0X")
			Z0X->Z0X_CODIGO := cCodigo := GetNextCod("Z0X_CODIGO")
			Z0X->Z0X_DATA   := aParRet[1]
			Z0X->Z0X_VERSAO :=  cVersao
			Z0X->Z0X_EQUIP  := _cEquipamento /*aParRet[3]*/
			Z0X->Z0X_OPERAD := QRYEXP->OPERAD // IIf(aParRet[4] == 1, QRYEXP->OPERAD, "")
			Z0X->Z0X_OPERAC := "1" // AllTrim(STR(aParRet[4]))
			Z0X->(MSUnlock())

			aOrdCur := {}
			a2OrdCur := {}
			aOrdArq := {}
			a2OrdArq := {}
			//__cDieta := "" // QRYEXP->DIETA
			While (!(QRYEXP->(EOF())))

				_cEquipamento /*aParRet[3]*/ := QRYEXP->EQUIP
				// If (aParRet[4] == 1) // 1 == Trato; 2 = Fabrica

				nTmOrd := 0
				// If ((nOrdRot := aScan(aOrdCur, {|x| x[1] == QRYEXP->ROTA})) > 0) //.AND. __cDieta == QRYEXP->DIETA
				If ((nOrdRot := aScan(a2OrdCur, {|x| x[1]+x[2] == QRYEXP->ROTA+QRYEXP->DIETA })) > 0) //.AND. __cDieta == QRYEXP->DIETA
					If ((nCntTrt := aScan(aOrdCur[nOrdRot], {|x| x[1] == QRYEXP->TRATO}, 2)) > 0)
						If (aScan(aOrdCur[nOrdRot][nCntTrt], {|x| x[1] == QRYEXP->CURRAL}, 2) < 1)
							AAdd(aOrdCur[nOrdRot][nCntTrt], {QRYEXP->CURRAL, QRYEXP->KGMS, QRYEXP->LOTE, QRYEXP->DIETA, QRYEXP->OPERAD, QRYEXP->QTDCAB})
						EndIf
					Else
						AAdd(aOrdCur[nOrdRot], {QRYEXP->TRATO, {QRYEXP->CURRAL, QRYEXP->KGMS, QRYEXP->LOTE, QRYEXP->DIETA, QRYEXP->OPERAD, QRYEXP->QTDCAB}})
					EndIf
				Else
					AAdd(aOrdCur, {QRYEXP->ROTA, {QRYEXP->TRATO, {QRYEXP->CURRAL, QRYEXP->KGMS, QRYEXP->LOTE, QRYEXP->DIETA, QRYEXP->OPERAD, QRYEXP->QTDCAB}}})
					AAdd(a2OrdCur, {QRYEXP->ROTA, QRYEXP->DIETA})
					//__cDieta := QRYEXP->DIETA
				EndIf

				// If ((nOrdRot := aScan(aOrdArq, {|x| x[1]  == QRYEXP->ROTA})) > 0)
				If ((nOrdRot := aScan(a2OrdArq, {|x| x[1]+x[2] == QRYEXP->ROTA+QRYEXP->DIETA })) > 0)
					If (aScan(aOrdArq[nOrdRot], {|x| x[1] == QRYEXP->TRATO}, 2) < 1)
						AAdd(aOrdArq[nOrdRot], {QRYEXP->TRATO, QRYEXP->DIETA, QRYEXP->KGMS})
					Else
						QRYEXP->(DBSkip())
						Loop
					EndIf
				Else
					AAdd(aOrdArq, {QRYEXP->ROTA, {QRYEXP->TRATO, QRYEXP->DIETA, QRYEXP->KGMS}})
					AAdd(a2OrdArq, {QRYEXP->ROTA, QRYEXP->DIETA, 1})
					nTmOrd += 1
				EndIf

				// ElseIf (aParRet[4] == 2)
				// 	3
				// 	nTmOrd := 0
				// 	For nCntBat := 1 To QRYEXP->QTDBAT
				//
				// 		If ((nOrdRot := aScan(aOrdArq, {|x| x[1] + x[2][2] == QRYEXP->EQUIP + QRYEXP->DIETA})) > 0)
				// 			AAdd(aOrdArq[nOrdRot], {nCntBat, QRYEXP->DIETA, (QRYEXP->TOTBAT / QRYEXP->QTDBAT)})
				// 		Else
				// 			AAdd(aOrdArq, {QRYEXP->EQUIP, {nCntBat, QRYEXP->DIETA, (QRYEXP->TOTBAT / QRYEXP->QTDBAT)}})
				// 			nTmOrd += 1
				// 		EndIf
				//
				// 		AAdd(aOrdCur, {nCntBat, {"0"}})
				// 	Next nCntBat
				//
				// EndIf

				QRYEXP->(DBSkip())
			EndDo

			CountRotaDieta( @a2OrdArq ) /* , @a2OrdCur */

			aResult[#'nordens'] := AllTrim(STR(Len(aOrdArq)))
			aResult[#'ordens' ] := Array(Len(aOrdArq))

			// cCsvEBt := "CAMINHAO;DATA;ORDEM;VERSAO;CARREGAMENTO;DIETA;SEQUENCIA;INGREDIENTE;QTDE REQUISITADA" + _ENTER_
			cCsvEBt := "operacao;caminhao;data;ordem_producao;versao;num _carreg;codigo_dieta;nome_dieta;"
			cCsvEBt += "ordem_ingrediente;cod_ingrediente;nome_ingrediente;qtde_prev;perc_ingrediente;"
			cCsvEBt += "tipo_carreg;roteiro;materia_seca" + _ENTER_

			// cCsvETr := "CAMINHAO;DATA;ORDEM;VERSAO;NUM_TRATO;CURRAL;LOTE;NUMERO_ANIM;DIETA;OFERTA" + _ENTER_

			if nAllOuSoVazio<>2
				cCsvETr := ""
			EndIf
			cCsvETr += Iif(nCntEqp==1, "operacao;caminhao;data;ordem_producao;versao;num_trato;curral;lote;n_animais;"+;
				"cod_dieta;nome_dieta;qtde_prev;0;0;0;0" + _ENTER_, "" )
			For nCntOrd := 1 To Len(aOrdArq)

				// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
				nNrTrt := Len(aOrdArq[nCntOrd]) - 1
				// ElseIf (aParRet[4] = 2)
				// 	nNrTrt := Len(aOrdArq[nCntOrd]) - 1 //Len(aOrdArq)
				// EndIf

				cSeqOrd := ""
				lMsmOrd := .F.
				cQryExp := " SELECT DISTINCT(Z0Y.Z0Y_ORDEM) AS ORDEM " + _ENTER_ +;
					"      , rTrim(Z0Y_ROTA) Z0Y_ROTA, rTrim(Z0Y_RECEIT) Z0Y_RECEIT " + _ENTER_ +;
					" FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_ +;
					" JOIN " + RetSqlName("Z0Y") + " Z0Y ON Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_ +;
					"								   AND Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_ +;
					"								   AND Z0X.Z0X_CODIGO = Z0Y.Z0Y_CODEI" + _ENTER_ +;
					"								   AND Z0X.Z0X_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_ +;
					"                                   AND Z0X.Z0X_EQUIP  = '" + _cEquipamento /*aParRet[3]*/ + "'" + _ENTER_ +;
					"								   AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_ +;
					"								   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_ +;
					" WHERE " + _ENTER_
				// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
				cQryExp += "	Z0Y.Z0Y_ROTA   = '" + AllTrim(aOrdCur[nCntOrd][1]) + "'" + _ENTER_
				// Else
				// 	cQryExp += "	Z0Y.Z0Y_RECEIT = '" + AllTrim(aOrdArq[nCntOrd][2][2]) + "'" + _ENTER_
				// EndIf

				_cPath := "C:\TOTVS_RELATORIOS\EXPVRFVER_" + AllTrim(aOrdCur[nCntOrd][1]) + ".sql"
				MEMOWRITE( _cPath, cQryExp)
				TCQUERY cQryExp NEW ALIAS "QRYORD"

				// lDesenv := AllTrim(QRYORD->Z0Y_ROTA) <> c2RArqChv
				lDesenv := !(AllTrim(QRYORD->Z0Y_ROTA) == c2RArqChv .AND. AllTrim(a2OrdArq[nCntOrd, 02]) <> c2PArqChv)
				If !(QRYORD->(EOF())) .And. lDesenv //  !(aParRet[4] == 2)
					cSeqOrd := QRYORD->ORDEM
					// Verifica se a ordem / roteiro j� teve arquivo exportado no dia
					lMsmOrd := .T.
				EndIf
				QRYORD->(DBCloseArea())

				If (Empty(cSeqOrd))
					cSeqOrd := GetNextCod("ORDEM")
					lMsmOrd := .F.
				EndIf

				If (lMsmOrd)

					cQryExp := " UPDATE " + RetSqlName("Z0Y") + _ENTER_
					cQryExp += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  " + _ENTER_
					cQryExp += " WHERE Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
					cQryExp += "   AND Z0Y_VERSAO < '" +  cVersao  + "'" + _ENTER_
					cQryExp += "   AND Z0Y_ORDEM = '" + cSeqOrd + "'" + _ENTER_
					// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
					cQryExp += "   AND Z0Y_ROTA = '" + AllTrim(aOrdCur[nCntOrd][1]) + "'" + _ENTER_
					// Else
					// 	cQryExp += "   AND Z0Y_RECEIT = '" + AllTrim(aOrdArq[nCntOrd][2]) + "'" + _ENTER_
					// EndIf
					cQryExp += "   AND D_E_L_E_T_ = ' ' " + _ENTER_

					If (TCSqlExec(cQryExp) < 0)
						MsgInfo(TCSqlError())
					EndIf

					cQryExp := " UPDATE " + RetSqlName("Z0W") + _ENTER_
					cQryExp += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  " + _ENTER_
					cQryExp += " WHERE Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
					cQryExp += "   AND Z0W_VERSAO < '" +  cVersao  + "'" + _ENTER_
					cQryExp += "   AND Z0W_ORDEM = '" + cSeqOrd + "'" + _ENTER_
					// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
					cQryExp += "   AND Z0W_ROTA = '" + AllTrim(aOrdCur[nCntOrd][1]) + "'" + _ENTER_
					// Else
					// 	cQryExp += "   AND Z0W_RECEIT = '" + AllTrim(aOrdArq[nCntOrd][2]) + "'" + _ENTER_
					// EndIf
					cQryExp += "   AND D_E_L_E_T_ = ' ' " + _ENTER_

					If (TCSqlExec(cQryExp) < 0)
						MsgInfo(TCSqlError())
					EndIf

					cQryExp := " SELECT * " + _ENTER_
					cQryExp += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
					cQryExp += " JOIN " + RetSqlName("Z0X") + " Z0X ON Z0X.Z0X_CODIGO = Z0Y.Z0Y_CODEI AND Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "' AND Z0X.D_E_L_E_T_ <> '*' " + _ENTER_
					cQryExp += "                               AND Z0X.Z0X_EQUIP = '" + _cEquipamento /*aParRet[3]*/ + "' AND Z0X.Z0X_DATA = '" + DTOS(aParRet[1]) + "' AND Z0X.Z0X_VERSAO = Z0Y.Z0Y_VERSAO" + _ENTER_
					cQryExp += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
					cQryExp += "   AND Z0Y.Z0Y_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
					cQryExp += "   AND Z0Y.Z0Y_VERSAO < '" +  cVersao  + "'" + _ENTER_
					cQryExp += "   AND Z0Y.D_E_L_E_T_ <> '*' " + _ENTER_

					TCQUERY cQryExp NEW ALIAS "QRYVRF"

					If (QRYVRF->(EOF()))

						cQryExp := " UPDATE " + RetSqlName("Z0X") + _ENTER_
						cQryExp += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  " + _ENTER_
						cQryExp += " WHERE Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_
						cQryExp += "   AND Z0X_VERSAO < '" +  cVersao  + "'" + _ENTER_
						cQryExp += "   AND Z0X_EQUIP = '" + _cEquipamento /*aParRet[3]*/ + "'" + _ENTER_
						cQryExp += "   AND Z0X_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
						cQryExp += "   AND D_E_L_E_T_ <> '*' " + _ENTER_

						If (TCSqlExec(cQryExp) < 0)
							MsgInfo(TCSqlError())
						EndIf
					Else
						cQryExp := " UPDATE " + RetSqlName("Z0X") + _ENTER_
						cQryExp += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  " + _ENTER_
						cQryExp += " WHERE	Z0X_FILIAL  = '" + xFilial("Z0X") + "' " + _ENTER_
						cQryExp += " 	AND Z0X_DATA    = '" + DTOS(aParRet[1]) + "' " + _ENTER_
						cQryExp += " 	AND Z0X_VERSAO  < '" +  cVersao  + "' " + _ENTER_
						cQryExp += " 	AND Z0X_EQUIP   = '" + _cEquipamento /*aParRet[3]*/ + "' " + _ENTER_
						cQryExp += " 	AND NOT EXISTS ( " + _ENTER_
						cQryExp += " 		SELECT	1 FROM " + RetSqlName("Z0Y") + _ENTER_
						cQryExp += " 		WHERE	Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND " + _ENTER_
						cQryExp += " 				Z0X_CODIGO = Z0Y_CODEI AND " + _ENTER_
						cQryExp += " 				D_E_L_E_T_ <> '*'  " + _ENTER_
						cQryExp += " 	) " + _ENTER_
						cQryExp += " 	AND NOT EXISTS ( " + _ENTER_
						cQryExp += " 		SELECT	1 FROM " + RetSqlName("Z0W") + _ENTER_
						cQryExp += " 		WHERE	Z0W_FILIAL = '" + xFilial("Z0W") + "' AND " + _ENTER_
						cQryExp += " 				Z0X_CODIGO = Z0W_CODEI AND " + _ENTER_
						cQryExp += " 				D_E_L_E_T_ <> '*'  " + _ENTER_
						cQryExp += " 	) " + _ENTER_
						cQryExp += " 	AND D_E_L_E_T_  = ' '"
						If (TCSqlExec(cQryExp) < 0)
							MsgInfo(TCSqlError())
						EndIf
					EndIf
					QRYVRF->(DBCloseArea())
				EndIf

				RecLock("Z0X", .F.)
					Z0X->Z0X_TRATO := AllTrim(STR(nNrTrt))
				Z0X->(MSUnlock())

				aResult[# 'ordens' ][nCntOrd]                         := Array(#)
				aResult[# 'ordens' ][nCntOrd][# 'ordemproducao' ]     := cSeqOrd // IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
				aResult[# 'ordens' ][nCntOrd][# 'ajuste' ]            := 0
				aResult[# 'ordens' ][nCntOrd][# 'currenttrato' ]      := 0
				aResult[# 'ordens' ][nCntOrd][# 'mixtimer' ]          := Array(nNrTrt)
				aResult[# 'ordens' ][nCntOrd][# 'ntratos' ]           := nNrTrt
				aResult[# 'ordens' ][nCntOrd][# 'receitas' ]          := Array(nNrTrt)
				aResult[# 'ordens' ][nCntOrd][# 'ingredientes' ]      := Array(nNrTrt)
				aResult[# 'ordens' ][nCntOrd][# 'pesosrequisitados' ] := Array(nNrTrt)
				aResult[# 'ordens' ][nCntOrd][# 'tolerancias' ]       := Array(nNrTrt)
				// aResult[# 'ordens' ][nCntOrd][# 'ncurrais' ]          := IIf(aParRet[4] == 1, Len(aOrdCur[nCntOrd][2]) - 1, Len(aOrdCur[nCntOrd]) - 1) //IIf(aParRet[4] = 1, Len(aOrdCur[nCntOrd]) - 1, 1)
				aResult[# 'ordens' ][nCntOrd][# 'ncurrais' ]          := Len(aOrdCur[nCntOrd][2]) - 1
				// aResult[# 'ordens' ][nCntOrd][# 'currais' ]           := IIf(aParRet[4] == 1, Array(Len(aOrdCur[nCntOrd][2]) - 1), Array(Len(aOrdCur[nCntOrd]) - 1)) //IIf(aParRet[4] = 1, Array(Len(aOrdCur[nCntOrd]) - 1), {})
				aResult[# 'ordens' ][nCntOrd][# 'currais' ]           := Array(Len(aOrdCur[nCntOrd][2]) - 1)
				aResult[# 'ordens' ][nCntOrd][# 'tratos' ]            := Array(nNrTrt) //IIf(aParRet[4] = 1, Array(nNrTrt), {}) //IIf(aParRet[4] = 1, Array(nNrTrt), Array(Len(aOrdCur[nCntOrd])))

				xAux := {}
				_nQtdPreTT := 0

				Z0S->(DbSetOrder(1))
				If Z0S->(DbSeek(xFilial("Z0S")+DtoS(aParRet[1])+StrZero(1,TamSX3("Z0S_VERSAO")[1])/* cVersao */+AllTrim(aOrdCur[nCntOrd][1]) /* QRYEXP->ROTA */))
					_nZ0SQTCARR := Z0S->Z0S_QTCARR
				EndIf
				For nCntTrt := 1 To nNrTrt

					nTTrMS := 0
					// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
					cQryTTr :=    " SELECT Z06.Z06_CURRAL" + CRLF +;
						"      , Z06.Z06_TRATO" + CRLF +;
						"      , Z06.Z06_KGMSTR" + CRLF +;
						"      , Z05.Z05_CABECA" + CRLF +;
						"      , (Z06.Z06_KGMSTR * Z05.Z05_CABECA) AS TOTAL " + CRLF +;
						"      , Z0T_ROTA " + CRLF
					cQryTTr +=    " FROM " + RetSqlName("Z06") + " Z06 " + CRLF
					cQryTTr +=    " JOIN " + RetSqlName("Z05") + " Z05" + CRLF +;
						"  ON Z05.Z05_DATA = Z06.Z06_DATA" + CRLF +;
						" AND Z05.Z05_VERSAO = Z06.Z06_VERSAO" + CRLF +;
						" AND Z05.Z05_CURRAL = Z06.Z06_CURRAL" + CRLF +;
						" AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "'" + CRLF +;
						" AND Z05.D_E_L_E_T_ = ' ' " + CRLF
					cQryTTr += " RIGHT JOIN " + RetSqlName("Z0T") + " Z0T" + CRLF +;
						" ON Z0T.Z0T_DATA = Z06.Z06_DATA" + CRLF +;
						" AND Z0T.Z0T_VERSAO = Z06.Z06_VERSAO" + CRLF +;
						" AND Z0T.Z0T_CURRAL = Z06.Z06_CURRAL" + CRLF +;
						" AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "'" + CRLF +;
						" AND Z0T.Z0T_ROTA = '" + aOrdCur[nCntOrd][1] + "'" + CRLF +;
						" AND Z0T.D_E_L_E_T_ = ' '"  + CRLF
					cQryTTr +=      " WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "'" + CRLF +;
						" AND Z06.Z06_TRATO = " + STR(nCntTrt) + "" + CRLF +;
						" AND Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
						" AND Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +; // +  cVersao  + "'" + _ENTER CRLF +;
						" AND Z06.D_E_L_E_T_ = ' '" + _ENTER_
					_cRoteiro := ""
					TCQUERY cQryTTr NEW ALIAS "QRYTTR"
					If (!QRYTTR->(EOF()))
						MEMOWRITE("C:\TOTVS_RELATORIOS\EXPTOTTRT_" + aOrdCur[nCntOrd][1] + "_" + aOrdCur[nCntOrd][nCntTrt + 1][1] + ".sql", cQryTTr)

						_cRoteiro := QRYTTR->Z0T_ROTA
						While (!QRYTTR->(EOF()))
							nTTrMS += QRYTTR->TOTAL
							QRYTTR->(DBSkip())
						EndDo
					EndIf
					QRYTTR->(DBCloseArea())

					cCodRec := AllTrim(aOrdArq[nCntOrd][nCntTrt + 1][2])

					// ElseIf (aParRet[4] = 2)
					//
					// 	cCodRec := AllTrim(aOrdArq[nCntOrd][nCntTrt + 1][2])
					// 	nTTrMS  := aOrdArq[nCntOrd][nCntTrt + 1][3]
					//
					// EndIf

					aResult[#'ordens'][nCntOrd][#'mixtimer'][nCntTrt] := '0' //ZG1_TIMER
					aResult[#'ordens'][nCntOrd][#'receitas'][nCntTrt] := rTrim(POSICIONE("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC"))

					// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica

					cQryRec := " SELECT * " + _ENTER_ +;
						" FROM ( " + _ENTER_ +;
						" 		 SELECT DISTINCT " + _ENTER_ +;
						" 		       ZG1.ZG1_COD AS RECEITA, ZG1.ZG1_COMP AS ITEM" + _ENTER_ +;
						" 		     ,	ZG1.ZG1_QUANT / ISNULL((SELECT SUM(ZG.ZG1_QUANT) QTDE FROM ZG1010 ZG WHERE ZG.ZG1_FILIAL = ZG1.ZG1_FILIAL AND ZG.ZG1_COD = ZG1.ZG1_COD AND ZG.ZG1_SEQ = ZG1.ZG1_SEQ AND  ZG.D_E_L_E_T_ = ' ' ),1) AS QUANT " + _ENTER_ +;
						" 		     , Z0V.Z0V_INDMS AS INDMS" + _ENTER_ +;
						" 		     ,	ZG1.ZG1_TIMER AS TIMER,	ZG1.ZG1_TRT AS SEQ " + _ENTER_ +;
						" 		      FROM " + RetSqlName("ZG1") + " ZG1 " + _ENTER_ +;
						" 		RIGHT JOIN " + RetSqlName("Z0V") + " Z0V ON Z0V.Z0V_FILIAL = '" + xFilial("Z0V") + "'" + _ENTER_ +;
						" 										         AND Z0V.Z0V_COMP = ZG1.ZG1_COMP" + _ENTER_ +;
						" 										         AND Z0V.D_E_L_E_T_ = ' ' " + _ENTER_ +;
						" 		WHERE ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "'" + _ENTER_ +;
						" 		  AND ZG1.ZG1_COD = '" + cCodRec + "'" + _ENTER_ +;
						" 		  AND ZG1.ZG1_SEQ = (" + _ENTER_ +;
						" 			  			      		SELECT MAX(ZG1A.ZG1_SEQ)" + _ENTER_ +;
						" 			  			      		FROM " + RetSqlName("ZG1") + " ZG1A" + _ENTER_ +;
						" 			  			      		WHERE ZG1A.ZG1_FILIAL = '" + xFilial("ZG1") + "'" + _ENTER_ +;
						" 		  				      			AND ZG1A.ZG1_COD = ZG1.ZG1_COD" + _ENTER_ +;
						" 		  				      			AND ZG1A.D_E_L_E_T_ = ' '" + _ENTER_ +;
						"						        ) " + _ENTER_ +;
						" 		  AND Z0V.Z0V_DATA    = '" + DToS(Z0R->Z0R_DATA) + "'" + _ENTER_ +;
						" 		  AND Z0V.Z0V_VERSAO  = '" + Z0R->Z0R_VERSAO + "'" + _ENTER_ +;
						" 		   AND ZG1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
						" ) DADOS " + _ENTER_ +;
						" ORDER BY CONVERT(INT, SEQ) "

					// ElseIf (aParRet[4] == 2)
					//
					// 	cQryRec := " SELECT * " + _ENTER_ +;
						// 				" FROM ( " + _ENTER_ +;
						// 				" 		 SELECT DISTINCT " + _ENTER_ +;
						// 				"              ZG1.ZG1_COD AS RECEITA" + _ENTER_ +;
						// 				"             , ZG1.ZG1_COMP AS ITEM" + _ENTER_ +;
						// 				"             , ZG1.ZG1_QUANT AS QUANT" + _ENTER_ +;
						// 				"             , ZG1.ZG1_TIMER AS TIMER" + _ENTER_ +;
						// 				"             , SB1.B1_QB AS QB" + _ENTER_ +;
						// 				"             , ZG1.ZG1_TRT AS SEQ" + _ENTER_ +;
						// 				"         FROM " + RetSqlName("ZG1") + "  ZG1" + _ENTER_ +;
						// 				"            RIGHT JOIN " + RetSqlName("SB1") + " SB1" + _ENTER_ +;
						// 				"            		ON SB1.B1_COD = ZG1.ZG1_COD" + _ENTER_ +;
						// 				"            			AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + _ENTER_ +;
						// 				"            			AND SB1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
						// 				"            WHERE ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "'" + _ENTER_ +;
						// 				" 			  AND ZG1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
						// 				" 			  AND ZG1.ZG1_COD = '" + cCodRec + "'" + _ENTER_ +;
						// 				" 			  AND ZG1.ZG1_SEQ = (" + _ENTER_ +;
						// 				"                                    SELECT MAX(ZG1A.ZG1_SEQ)" + _ENTER_ +;
						// 				"                                    FROM " + RetSqlName("ZG1") + " ZG1A" + _ENTER_ +;
						// 				"                                    WHERE ZG1A.ZG1_FILIAL = '" + xFilial("ZG1") + "'" + _ENTER_ +;
						// 				"                                      AND ZG1A.D_E_L_E_T_ = ' '" + _ENTER_ +;
						// 				"                                 )" + _ENTER_ +;
						// 				" ) DADOS " + _ENTER_ +;
						// 				" ORDER BY CONVERT(INT, SEQ ) " // " ORDER BY CONVERT(INT, ZG1.ZG1_TRT) "
					// EndIf
					MEMOWRITE("C:\TOTVS_RELATORIOS\EXPRECEITA" + cCodRec + ".sql", cQryRec)
					TCQUERY cQryRec NEW ALIAS "QRYREC"

					nCntCmp := n2CntCmp := Contar("QRYREC","!EOF()")
					QRYREC->(DbGoTop())

					aResult[# 'ordens' ][nCntOrd][# 'ingredientes' ][nCntTrt]      := Array(nCntCmp)
					aResult[# 'ordens' ][nCntOrd][# 'pesosrequisitados' ][nCntTrt] := Array(nCntCmp)
					aResult[# 'ordens' ][nCntOrd][# 'tolerancias' ][nCntTrt]       := Array(nCntCmp)

					// If(aParRet[4] == 1)
					aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt] := Array(Len(aOrdCur[nCntOrd][2])) //Array(Len(aOrdCur[nCntOrd][2])) ////nQtdCMT - 1
					// ElseIf (aParRet[4] = 2)
					// 	aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt] := Array(Len(aOrdCur[nCntTrt][2])) //Array(Len(aOrdCur[nCntOrd][2]))
					// EndIf

					nCntCmp := 1
					nTTrMN  := 0
					// aCsvAux := {} // novo modelo 09.10.2021
					If (QRYREC->(EOF()))
						MsgInfo("Estrutura de Produto para a Receita '" + cCodRec + " - " + rTrim(POSICIONE("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC")) + "' nao encontrada. Abortando...")
						QRYREC->(DBCloseArea())
						// QRYEXP->(DBCloseArea())
						DisarmTransaction()
						Break
					EndIf

					While (!QRYREC->(EOF()))

						// MB : 21.02.2020
						If (nPos:=aScan(aTipo_carreg, { |x| x[1]==cCodRec .and. x[2]==QRYREC->ITEM })) == 0
							dbUseArea(.T.,'TOPCONN',TCGENQRY(,,;
								_cQry := " SELECT G1_ORIGEM --, * " + CRLF +;
								" FROM	  " +RetSqlName('SG1')+ " " + CRLF +;
								" WHERE  G1_FILIAL = '" + xFilial('SG1') +"'" + CRLF +;
								" 	  AND G1_COD = '" + cCodRec +"'" + CRLF +;
								" 	  AND G1_COMP = '" + QRYREC->ITEM +"'" + CRLF +;
								" 	  AND D_E_L_E_T_ = ' '";
								), "TMPSG1",.T.,.F.)
							If !(TMPSG1->(Eof()))
								aAdd( aTipo_carreg, { cCodRec,;
									QRYREC->ITEM,;
									TMPSG1->G1_ORIGEM } )
								nPos := len(aTipo_carreg)
							EndIf
							TMPSG1->(DbCloseArea())
						EndIf

						// If (cTipo_carreg := iIf(nPos==0, "", aTipo_carreg[nPos, 3])) == "P" // Phibro
						// 	aAdd( aPhibro, {;
							// 		/* 01 */ Z0X->Z0X_CODIGO,;
							// 		/* 02 */ cSeqOrd,;
							// 		/* 03 */ Z0X->Z0X_VERSAO,;
							// 		/* 04 */ AllTrim(STR(nCntTrt)),;
							// 		/* 05 */ cCodRec,;
							// 		/* 06 */ aTipo_carreg[nPos, 2],; // componente
						// 		/* 07 */ AllTrim(aOrdCur[nCntOrd][1]),; // IIf(aParRet[4] == 1, AllTrim(aOrdCur[nCntOrd][1]), ""),; // ROTA
						// 		/* 08 */ Z0X->Z0X_OPERAD,;//operador
						// 		/* 09 */ QRYREC->TIMER,;
							// 		/* 10 */ QRYREC->RECEITA,;
							// 		/* 11 */ QRYREC->ITEM,;
							// 		/* 12 */ nTTrMS,;
							// 		/* 13 */ nDivisa,;
							// 		/* 14 */ nNrTrt,;
							// 		/* 15 */ Round( Round((QRYREC->QUANT * nTTrMS) / (QRYREC->INDMS/100), 2) /* / nDivisa */, 2)/*  * nDivisa  */} )
						// EndIf
						// fim => MB : 21.02.2020

						// If(aParRet[4] == 1)

						aResult[# 'ordens' ][nCntOrd][# 'ingredientes' ][nCntTrt][nCntCmp]      := rTrim(POSICIONE("SB1", 1, xFilial("SB1")+ AllTrim(QRYREC->ITEM), "B1_XDESC")) //SUBSTR(, 1, 15) //B1_DSCBAL
						aResult[# 'ordens' ][nCntOrd][# 'pesosrequisitados' ][nCntTrt][nCntCmp] := Round(Round((QRYREC->QUANT * nTTrMS) / (QRYREC->INDMS/100),0)/nDivisa,0)*nDivisa
						aResult[# 'ordens' ][nCntOrd][# 'tolerancias' ][nCntTrt][nCntCmp]       := '0'

						//						nTTrMN += Round((100 * nTTrMS)/QRYREC->INDMS, 2)
						nTTrMN += Round((QRYREC->QUANT * nTTrMS)/(QRYREC->INDMS/100), 0)

						// ElseIf (aParRet[4] == 2)
						//
						// 	aResult[# 'ordens' ][nCntOrd][# 'ingredientes' ][nCntTrt][nCntCmp]      := rTrim(POSICIONE("SB1", 1, xFilial("SB1")+ AllTrim(QRYREC->ITEM), "B1_XDESC")) //SUBSTR(, 1, 15) //B1_DSCBAL
						// 	aResult[# 'ordens' ][nCntOrd][# 'pesosrequisitados' ][nCntTrt][nCntCmp] := AllTrim(STR(Round((QRYREC->QUANT / QRYREC->QB) * nTTrMS, -(Len(AllTrim(STR(nDivisa))) * -1))))
						// 	aResult[# 'ordens' ][nCntOrd][# 'tolerancias' ][nCntTrt][nCntCmp]       := '0'
						//
						// 	nTTrMN := Round ( Round((QRYREC->QUANT / QRYREC->QB) * nTTrMS, 0) / nDivisa, 0)* nDivisa
						//
						// EndIf

						// If (aParRet[4] == 1) // 1 == Trato; 2 = Fabrica
						// If (cTipo_carreg := iIf(nPos==0, "", aTipo_carreg[nPos, 3])) == "P" // qdo Fibro
						If (cTipo_carreg := iIf(nPos==0, "", aTipo_carreg[nPos, 3])) == ("P") .OR.  (cTipo_carreg := iIf(nPos==0, "", aTipo_carreg[nPos, 3])) == ("I") // qdo Fibro
							nQtdPre := Round( Round((QRYREC->QUANT * nTTrMS) / (QRYREC->INDMS/100), 2) /* / nDivisa */, 2) /* * nDivisa */
						Else
							nQtdPre := Round( Round((QRYREC->QUANT * nTTrMS) / (QRYREC->INDMS/100), 0) / nDivisa, 0) * nDivisa
						EndIf
						// Else
						// 	nQtdPre := Round((QRYREC->QUANT / QRYREC->QB) * nTTrMS, -(Len(AllTrim(STR(nDivisa))) * -1)) //Round ( Round((QRYREC->QUANT / QRYREC->QB) * nTTrMS, 0) / nDivisa, 0) * nDivisa
						// EndIf

						// MB : 24.11.2021
						If AllTrim(QRYREC->ITEM) == GetMV( "MB_PCPA13A",, "990012") // AGUA // Alert('Agua')
							if (nPos := aScan( _aReceitaOrigem, { |x| x[1] == cCodRec } )) > 0
								While nPos > 0

										/* If _aReceitaOrigem[ nPos, 3 ] == "P"
											_nDesAgua := GetMV( "MB_PCPA13P",, 70 )
											nQtdPre -= _nDesAgua // Desconto Phibro
											// fCriaZ0YAgua( "P", cSeqOrd, nCntTrt, cCodRec, _nDesAgua, aOrdCur, nCntOrd, @aCsvAux, nCntCmp+1 )
											aAdd( aAguaZ0Y, { "P", cSeqOrd, nCntTrt, cCodRec, _nDesAgua, aOrdCur, nCntOrd, @aCsvAux, n2CntCmp+2 } )
										Else */
										If _aReceitaOrigem[ nPos, 3 ] == "I"
											_nDesAgua := GetMV( "MB_PCPA13I",, 50 )
											nQtdPre -= _nDesAgua // Desconto Imbife
											aAdd( aAguaZ0Y, { "I", cSeqOrd, iIF( !Empty(_aZ0SQTCARR), _aZ0SQTCARR[ /*__nPAUX := */aScan( _aZ0SQTCARR, { |x| x[1] + x[2] == _cEquipamento + aOrdCur[nCntOrd][1] } ), 03], _nZ0SQTCARR ) /* nCntTrt */, cCodRec, _nDesAgua, aOrdCur, nCntOrd, @aCsvAux,;
											n2CntCmp+1 } )

											// MsgAlert("Posi��o: " + cValToChar(__nPAUX) + " valor: " + cValToChar(_aZ0SQTCARR[ __nPAUX, 03]) , "Ponto 03")
										EndIf
										
										nPos += 1
										If nPos > len(_aReceitaOrigem) .OR.;
											_aReceitaOrigem[ nPos, 1 ] <> cCodRec
											exit
										EndIf
									
									EndDo
									If nQtdPre < 0
										nQtdPre := 0
									EndIf
								EndIf
							
							ElseIf AllTrim(QRYREC->ITEM) == GetMV( "MB_PCPA13M",, "030001") .AND.; // MILHO UMIDO
									(nPos := aScan( _aReceitaOrigem, { |x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(cCodRec) } )) > 0
								/*  - Ultima linha do trato incluir a linha por ultimo
									- Receita que nao possue agua	*/
								While nPos > 0
									/* If _aReceitaOrigem[ nPos, 3 ] == "P"
										_nDesAgua := GetMV( "MB_PCPA13P",, 70 )
										aAdd( aAguaZ0Y, { "P", cSeqOrd, nCntTrt, cCodRec, _nDesAgua, aOrdCur, nCntOrd, @aCsvAux, n2CntCmp+2 } )
									Else */
									If _aReceitaOrigem[ nPos, 3 ] == "I"
										_nDesAgua := GetMV( "MB_PCPA13I",, 50 )
										aAdd( aAguaZ0Y, { "I", cSeqOrd, iIF( !Empty(_aZ0SQTCARR), _aZ0SQTCARR[  /*__nPAUX := */aScan( _aZ0SQTCARR, { |x| x[1] + x[2] == _cEquipamento + aOrdCur[nCntOrd][1] } ), 03], _nZ0SQTCARR ) /* nCntTrt */, cCodRec, _nDesAgua, aOrdCur, nCntOrd, @aCsvAux,;
											n2CntCmp+2 } )
									EndIf
									
									nPos += 1
									If nPos > len(_aReceitaOrigem) .OR.;
										_aReceitaOrigem[ nPos, 1 ] <> cCodRec
										exit
									EndIf
								EndDo
							EndIf

						/* MB : 18.04.2022
							-> Nao gerar linha no arquivo, se tiver quantidade ZERO */
						If nCntTrt < nNrTrt
							
							aAdd( xAux, {;
									/* 01 */ cSeqOrd,;
									/* 02 */ nCntTrt,;
									/* 03 */ QRYREC->ITEM,;
									/* 04 */ nQtdPre;
							})

						Else

							for _nAgr := 1 to Len(xAux)
								If xAux[ _nAgr, 03] == QRYREC->ITEM // xAux[1] == cSeqOrd .AND. 
									nQtdPre += xAux[_nAgr, 04]
								EndIf
							Next
							//ALERT("ROTA " +AllTrim(aOrdCur[nCntOrd][1]) + " QTDE" + cValToChar(_aZ0SQTCARR[nCntEqp, 3]))
							If nQtdPre > 0
								/* xx */ aAdd( aCsvAux, {} )
								/* 01 */ aAdd( aTail(aCsvAux), "C" )
								/* 02 */ aAdd( aTail(aCsvAux), AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT")) )
								/* 03 */ aAdd( aTail(aCsvAux), DTOC(Z0X->Z0X_DATA) )
								/* 04 */ aAdd( aTail(aCsvAux), cSeqOrd )
								/* 05 */ aAdd( aTail(aCsvAux), Z0X->Z0X_VERSAO )
								/* 06 */ aAdd( aTail(aCsvAux), AllTrim(STR( iIF( !Empty(_aZ0SQTCARR), _aZ0SQTCARR[ /*__nPAUX := */aScan( _aZ0SQTCARR, { |x| x[1] + x[2] == _cEquipamento + aOrdCur[nCntOrd][1] } ), 03], _nZ0SQTCARR ) ))/* AllTrim(STR(nCntTrt)) */ )
								/* 07 */ aAdd( aTail(aCsvAux), rTrim(cCodRec) )
								/* 08 */ aAdd( aTail(aCsvAux), rTrim(POSICIONE("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC")) )
								/* 09 */ aAdd( aTail(aCsvAux), AllTrim(QRYREC->SEQ) )
								/* 10 */ aAdd( aTail(aCsvAux), rTrim(QRYREC->ITEM) )
								/* 11 */ aAdd( aTail(aCsvAux), rTrim(POSICIONE("SB1", 1, xFilial("SB1")+ AllTrim(QRYREC->ITEM), "B1_XDESC")) )
								/* 12 */ AAdd( aTail(aCsvAux), nQtdPre )
								/* 13 */ AAdd( aTail(aCsvAux), cTipo_carreg )
								
								// MsgAlert("Posi��o: " + cValToChar(__nPAUX) + " valor: " + cValToChar(_aZ0SQTCARR[ __nPAUX, 03]) , "Ponto 02")
							EndIf

							DBSelectArea("Z0Y")
							Z0Y->(DBSetOrder(1))

							cCodigo := GetNextCod("Z0Y_CODIGO")
							RecLock("Z0Y", .T.)
								Z0Y->Z0Y_FILIAL := xFilial("Z0Y")
								Z0Y->Z0Y_CODIGO := cCodigo
								Z0Y->Z0Y_CODEI  := Z0X->Z0X_CODIGO
								Z0Y->Z0Y_TRATO  := "1" /* AllTrim(STR(nCntTrt)) */ // IIf(aParRet[4] = 1, AllTrim(STR(nCntTrt)), PADL(nCntTrt, 2))
								Z0Y->Z0Y_ORDEM  := cSeqOrd// IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
								Z0Y->Z0Y_AJUSTE := 0
								Z0Y->Z0Y_TIMER  := QRYREC->TIMER
								Z0Y->Z0Y_RECEIT := QRYREC->RECEITA
								Z0Y->Z0Y_COMP   := QRYREC->ITEM
								Z0Y->Z0Y_QTDPRE := nQtdPre
								Z0Y->Z0Y_QTDREA := 0
								Z0Y->Z0Y_TOLERA := 0
								Z0Y->Z0Y_ROTA   := AllTrim(aOrdCur[nCntOrd][1]) // IIf(aParRet[4] = 1, AllTrim(aOrdCur[nCntOrd][1]), "")
								Z0Y->Z0Y_DATA   := Z0X->Z0X_DATA
								Z0Y->Z0Y_VERSAO := Z0X->Z0X_VERSAO
								Z0Y->Z0Y_SEQ    := Val(AllTrim(QRYREC->SEQ))
								Z0Y->Z0Y_ORIGEM := cTipo_carreg
								// este campo nao existe no ambiente Z0Y->Z0Y_EQUIP  := _cEquipamento /*aParRet[3]*/  // MB : 01.04.2022 esta linha estava comentada, validar necessidade com toshio
							Z0Y->(MSUnlock())
							nCntCmp += 1
						EndIf
						
						QRYREC->(DBSkip())
					EndDo

					If nCntTrt == nNrTrt .AND. !Empty(len(aAguaZ0Y))

						_nQtdPreTT:= 0
						for nIagua := 1 to len(aAguaZ0Y)
							_nQtdPreTT += aAguaZ0Y[ nIagua, 05]
						Next nIagua
						fCriaZ0YAgua( aAguaZ0Y[ len(aAguaZ0Y), 01],;
										aAguaZ0Y[ len(aAguaZ0Y), 02],;
										aAguaZ0Y[ len(aAguaZ0Y), 03],;
										aAguaZ0Y[ len(aAguaZ0Y), 04],;
										_nQtdPreTT,;
										aAguaZ0Y[ len(aAguaZ0Y), 06],;
										aAguaZ0Y[ len(aAguaZ0Y), 07],;
										aAguaZ0Y[ len(aAguaZ0Y), 08],;
										aAguaZ0Y[ len(aAguaZ0Y), 09] )
						aAguaZ0Y := {}

					EndIf

					_cSql := " WITH DIETA AS (" + _ENTER_ +;
								" 		SELECT	ZG1.ZG1_COD AS RECEITA, ZG1.ZG1_COMP AS ITEM, " + _ENTER_ +;
								" 				    ZG1.ZG1_QUANT AS QUANT, Z0V.Z0V_INDMS AS INDMS, " + _ENTER_ +;
								" 				    ZG1.ZG1_TIMER AS TIMER, ZG1.ZG1_TRT AS SEQ,  " + _ENTER_ +;
								" 				    ROUND((ZG1_QUANT/(Z0V_INDMS/100))*1,4) QTMN" + _ENTER_ +;
								" 		FROM       " +RetSqlName('ZG1')+ "  ZG1  " + _ENTER_ +;
								" 		RIGHT JOIN " +RetSqlName('Z0V')+ " Z0V ON Z0V.Z0V_FILIAL = '" + xFilial("Z0V") + "' " + _ENTER_ +;
								"                           AND Z0V.Z0V_COMP = ZG1.ZG1_COMP " + _ENTER_ +;
								"							 AND Z0V.D_E_L_E_T_ = ' ' " + _ENTER_ +;
								" 		WHERE   ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "'" + _ENTER_ +;
								" 			AND ZG1.ZG1_COD    = '" + cCodRec + "' " + _ENTER_ +;
								" 			AND ZG1.ZG1_SEQ    = ( SELECT MAX(ZG1A.ZG1_SEQ) " + _ENTER_ +;
								" 							   			FROM " +RetSqlName('ZG1')+ " ZG1A " + _ENTER_ +;
								" 							   			WHERE ZG1A.ZG1_FILIAL = '" + xFilial("ZG1") + "' " + _ENTER_ +;
								" 							   			  AND ZG1A.ZG1_COD = ZG1.ZG1_COD " + _ENTER_ +;
								"							   			  AND ZG1A.D_E_L_E_T_ = ' ' " + _ENTER_ +;
								"                               ) " + _ENTER_ +;
								" 								AND Z0V.Z0V_DATA = '" + DToS(Z0R->Z0R_DATA) + "' " + _ENTER_ +;
								" 								AND Z0V.Z0V_VERSAO = '" + Z0R->Z0R_VERSAO + "' " + _ENTER_ +;
								" 			AND ZG1.D_E_L_E_T_ = ' '  " + _ENTER_ +;
								" )" + _ENTER_ +;
								" SELECT 	ROUND(SUM(QUANT)/SUM(QTMN)*100,2) PORCENTAGEM" + _ENTER_ +;
								" FROM 	DIETA"
					MEMOWRITE("C:\TOTVS_RELATORIOS\EXP_Percentagem_" + cCodRec + ".sql", _cSql)
					TCQUERY _cSql NEW ALIAS "QRYTMP"
					_cPerMtSeca := 0
					If !(QRYTMP->(Eof()))
						_cPerMtSeca := QRYTMP->PORCENTAGEM
					EndIf

					For nI := Len(aCsvAux) to nIniCsv Step -1
						If len(aCsvAux[nI]) == 13
							/* 14 */ aAdd( aCsvAux[nI], _cRoteiro )
							/* 15 */ aAdd( aCsvAux[nI], AllTrim(StrTran(Str(_cPerMtSeca), ".", ",")) )
						EndIf
					Next nI
					// nIniCsv := Len(aCsvAux)+1
					QRYREC->(DBCloseArea())
					QRYTMP->(DBCloseArea())

					// If (aParRet[4] == 1) // 4 == operacao // 1 == Trato; 2 = Fabrica
					
						aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt] := Array(Len(aOrdCur[nCntOrd][nCntTrt + 1]) - 1) //Array(nQtdCMT - 1)

						For nCntCur := 2 To Len(aOrdCur[nCntOrd][nCntTrt + 1])
							nPrcMT := (aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][2] * 100)/nTTrMS
							aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt][nCntCur - 1] := Round ( Round((nPrcMT * nTTrMN)/100, 0) / nDivisa, 0) * nDivisa
							
							DBSelectArea("Z0W")
							Z0W->(DBSetOrder(1))
							
							// cCodigo := GetSXENum("Z0W", "Z0W_CODIGO")
							// ConfirmSX8()
							cCodigo := GetNextCod("Z0W_CODIGO")
							RecLock("Z0W", .T.)
								Z0W->Z0W_FILIAL := xFilial("Z0W")
								Z0W->Z0W_CODIGO := cCodigo
								Z0W->Z0W_CODEI  := Z0X->Z0X_CODIGO
								Z0W->Z0W_TRATO  := AllTrim(STR(nCntTrt))
								Z0W->Z0W_CURRAL := AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][1])
								Z0W->Z0W_ROTA   := AllTrim(aOrdCur[nCntOrd][1])
								Z0W->Z0W_LOTE   := AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][3])
								Z0W->Z0W_QTDPRE := Round ( Round((nPrcMT * nTTrMN)/100, 0) / nDivisa, 0) * nDivisa
								Z0W->Z0W_QTDREA := 0
								Z0W->Z0W_RECEIT := cCodRec //aOrdCur[nCntOrd][nCntCur][4]
								Z0W->Z0W_ORDEM  := cSeqOrd // IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
								Z0W->Z0W_DATA   := Z0X->Z0X_DATA
								Z0W->Z0W_VERSAO := Z0X->Z0X_VERSAO
								// este campo nao existe no ambiente Z0W->Z0W_EQUIP  := _cEquipamento /*aParRet[3]*/ // MB : 01.04.2022 esta linha estava comentada, validar necessidade com toshio
							Z0W->(MSUnlock())
							
							//operacao;caminhao;data;ordem_producao;versao;num_trato;curral;lote;n_animais;cod_dieta;nome_dieta;qtde_prev
							/* 01 */ cCsvETr += "F;" 
							/* 02 */ cCsvETr += AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT")) + ";"
							/* 03 */ cCsvETr += DTOC(Z0X->Z0X_DATA) + ";"  
							/* 04 */ cCsvETr += cSeqOrd + ";"
							/* 05 */ cCsvETr += Z0X->Z0X_VERSAO + ";"
							/* 06 */ cCsvETr += AllTrim(STR(nCntTrt)) + ";" 
							/* 07 */ cCsvETr += AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][1]) + ";"
							/* 08 */ cCsvETr += AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][3]) + ";"
							/* 09 */ cCsvETr += AllTrim(STR(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][6])) + ";"
							/* 10 */ cCsvETr += rTrim(cCodRec) + ";"
							/* 11 */ cCsvETr += rTrim(Posicione("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC")) + ";"
							/* 12 */ cCsvETr += StrTran(AllTrim(Str( Round ( Round((nPrcMT * nTTrMN)/100, 0) / nDivisa, 0) * nDivisa )), ".", "") + ";"
							/* 13 */ cCsvETr += "0" + ";"
							/* 14 */ cCsvETr += "0" + ";"
							/* 15 */ cCsvETr += "0" + ";" // roteiro
							/* 16 */ cCsvETr += "0" // % materia seca
							/* 17 */ cCsvETr += _ENTER_	

						Next nCntCur

						/* MB	 : 05.04.2022
							-> Incluir tratos extras para ajuste final dos tratos nos lotes, conforme o ocorrido na pratica.  
						*/
						If nCntTrt == nNrTrt
							
							If aOrdCur[nCntOrd, 1]==a2OrdArq[nCntOrd, 1] .and. a2OrdArq[nCntOrd, 3] == 1
								xAux := aOrdCur[nCntOrd, len(aOrdCur[nCntOrd])]
								__nCntTrt := nCntTrt // Val(xAux[1])
								for nIm:=1 to aParRet[4]
									__nCntTrt += 1
									for nIj:=2 to len(xAux)

										cCodigo := GetNextCod("Z0W_CODIGO")
										RecLock("Z0W", .T.)
										Z0W->Z0W_FILIAL := xFilial("Z0W")
										Z0W->Z0W_CODIGO := cCodigo
										Z0W->Z0W_CODEI  := Z0X->Z0X_CODIGO
										Z0W->Z0W_TRATO  := AllTrim(STR(__nCntTrt))
										Z0W->Z0W_CURRAL := AllTrim(xAux[nIj, 01]) // AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][1])
										Z0W->Z0W_ROTA   := AllTrim(aOrdCur[nCntOrd][1])
										Z0W->Z0W_LOTE   := AllTrim(xAux[nIj, 03]) //AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][3])
										Z0W->Z0W_QTDPRE := 0 // Round ( Round((nPrcMT * nTTrMN)/100, 0) / nDivisa, 0) * nDivisa
										Z0W->Z0W_QTDREA := 0
										Z0W->Z0W_RECEIT := cCodRec //aOrdCur[nCntOrd][nCntCur][4]
										Z0W->Z0W_ORDEM  := cSeqOrd // IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
										Z0W->Z0W_DATA   := Z0X->Z0X_DATA
										Z0W->Z0W_VERSAO := Z0X->Z0X_VERSAO
										// este campo nao existe no ambiente Z0W->Z0W_EQUIP  := _cEquipamento /*aParRet[3]*/ // MB : 01.04.2022 esta linha estava comentada, validar necessidade com toshio
										Z0W->(MSUnlock())

										/* 01 */ cCsvETr += "F;" 
										/* 02 */ cCsvETr += AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT")) + ";"
										/* 03 */ cCsvETr += DTOC(Z0X->Z0X_DATA) + ";"  
										/* 04 */ cCsvETr += cSeqOrd + ";"
													//cCsvETr += IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd)) + ";"
										/* 05 */ cCsvETr += Z0X->Z0X_VERSAO + ";"
										/* 06 */ cCsvETr += AllTrim(STR(__nCntTrt)) + ";" 
										/* 07 */ cCsvETr += AllTrim(xAux[nIj, 01]) + ";" // AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][1]) + ";"
										/* 08 */ cCsvETr += AllTrim(xAux[nIj, 03]) + ";" // AllTrim(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][3]) + ";"
										/* 09 */ cCsvETr += AllTrim(STR(xAux[nIj, 06])) + ";" // AllTrim(STR(aOrdCur[nCntOrd][nCntTrt + 1][nCntCur][6])) + ";"
										/* 10 */ cCsvETr += rTrim(cCodRec) + ";"
										/* 11 */ cCsvETr += rTrim(Posicione("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC")) + ";"
										/* 12 */ cCsvETr += "0" + ";" // StrTran(AllTrim(Str( Round ( Round((nPrcMT * nTTrMN)/100, 0) / nDivisa, 0) * nDivisa )), ".", "") + ";"
										/* 13 */ cCsvETr += "0" + ";"
										/* 14 */ cCsvETr += "0" + ";"
										/* 15 */ cCsvETr += "0" + ";" // roteiro
										/* 16 */ cCsvETr += "0" // % materia seca
										/* 17 */ cCsvETr += _ENTER_	
									next
								next
							EndIf
						EndIf

						// ElseIf (aParRet[4] == 2) // 1 == Trato; 2 = Fabrica
						//
						// 	aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt] := Array(Len(aOrdCur[1]) - 1)
						// 	aResult[#'ordens'][nCntOrd][#'tratos'][nCntTrt][1] := "0"
						// EndIf

					Next nCntTrt

					// If (aParRet[4] == 1) // 1 == Trato; 2 = Fabrica
					For nCntCur := 2 To (Len(aOrdCur[nCntOrd][2]))
						aResult[#'ordens'][nCntOrd][#'currais'][nCntCur - 1] := AllTrim(aOrdCur[nCntOrd][2][nCntCur][1])
					Next nCntCur
					// ElseIf (aParRet[4] == 2)
					// 	aResult[#'ordens'][nCntOrd][#'currais'][1] := "0"
					// EndIf

					c2RArqChv := AllTrim(a2OrdArq[nCntOrd, 01])
					c2PArqChv := AllTrim(a2OrdArq[nCntOrd, 02])
				Next nCntOrd

			Else
				// MsgInfo("Nao existe " + IIf(aParRet[4] == 1, "Roteiro criado", "Programacao criada") + " no dia '" + DTOC(aParRet[1]) + "'. Verifique na Rotina de " + IIf(aParRet[4] = 1, "Roteirizacao.", "Programacao Fabrica.") +" Ou verifique se o equipamento selecionado est� vinculado a um roteiro." )
				MsgInfo("Nao existe Roteiro criado no dia '" + DTOC(aParRet[1]) + "'. Verifique na Rotina de Roteirizacao. Ou verifique se o equipamento selecionado est� vinculado a um roteiro." )
				lCnt := .F.
			EndIf
			// QRYEXP->(DBCloseArea())

		/* MB : 01.04
			# Validar, qdo gerar arquivo
		*/
		if nAllOuSoVazio==2 .and. nCntEqp < Len(aEqpJsn)
			lCnt := .F.
		EndIf
		// If (lCnt)

		cJsnExp := ToJson(aResult)

		// cLocArq := "\TOTVS_EXPIMP\" + IIf(aParRet[4] == 1, "TRATO\", "FABRICA\")
		cLocArq := "\TOTVS_EXPIMP\TRATO\"
		MakeDir(cLocArq)
		MakeDir("C:" + cLocArq)

		cLocArq += DTOS(aParRet[1]) + "-" +  cVersao  + "\"
		MakeDir(cLocArq)
		MakeDir("C:" + cLocArq)

		cEquip := ""
		If nAllOuSoVazio<>2
			cEquip := AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT"))
		EndIf
		cLocArq += cEquip + "\" //AllTrim(aParRet[3]) + "\"
		MakeDir(cLocArq)
		MakeDir("C:" + cLocArq)

		// cMsgExp := "Arquivo " + IIf(aParRet[5] = 1, "'programacao.csv'", "'programacao.json'") + " gerado na pasta 'C:" + cLocArq + "'. "
		// cMsgExp += iIf(Empty(cMsgExp), "Arquivo " + IIf(aParRet[5] = 1, "'.csv'", "'.json'") + " gerado na pasta 'C:" + _ENTER_, "") +;
			// 			"-> " + cLocArq + "'." + _ENTER_ + _ENTER_

		cMsgExp += iIf(Empty(cMsgExp), "Arquivo.csv gerado na pasta C:" + _ENTER_, "") +;
			"-> " + cLocArq + "'." + _ENTER_ + _ENTER_
		If Len(aCsvAux)>0
			// 1 = operacao
			// 4 = ordem producao
			// 9 = ordem ingrediente
			// ORDENACAO DO VETOR DE CARREGAMENTO
			/////// aSort( aCsvAux,,, { |x, y| x[1]+x[4]+x[8]+StrZero(Val(x[9]),3)+StrZero(Val(x[6]),3) < y[1]+y[4]+y[8]+StrZero(Val(y[9]),3)+StrZero(Val(y[6]),3) } )
			// AGRUPANDO POR OPERACAO X ORDEM DE PRODUCAO X INGREDIENTE (PRODUTO)
			///////     nCntBat := 1
			///////     While nCntBat <= Len(aCsvAux)-1 // linha
			///////     	If aCsvAux[nCntBat, 01]+aCsvAux[nCntBat, 04]+aCsvAux[nCntBat, 09]+aCsvAux[nCntBat, 10] == ;
				///////     		aCsvAux[nCntBat+1, 01]+aCsvAux[nCntBat+1, 04]+aCsvAux[nCntBat+1, 09]+aCsvAux[nCntBat+1, 10]
			///////
			///////     		nQtdPrev   += aCsvAux[nCntBat, 12] // 12 = Quant prevista
			///////     		aDel ( aCsvAux, nCntBat)
			///////     		aSize( aCsvAux, Len(aCsvAux)-1)
			///////     		If nCntBat == Len(aCsvAux)
			///////     			aCsvAux[nCntBat, 12] += nQtdPrev
			///////     			nQtdPrev := 0
			///////     		EndIf
			///////     	Else
			///////     		aCsvAux[nCntBat, 12] += nQtdPrev
			///////     		nQtdPrev := 0
			///////     		nCntBat+=1
			///////     	EndIf
			///////     EndDo

			// CALCULA PORCENTAGEM
			ordem_producao := aCsvAux[01, 04]
			nUltimo := 0
			lContinua := .T.
			While lContinua
				nInicio := nCntBat := nUltimo+1
				While nCntBat <= Len(aCsvAux)
					if ordem_producao == aCsvAux[nCntBat, 04]
						nCntBat+=1
					Else
						ordem_producao := aCsvAux[nCntBat, 04]
						nUltimo := nCntBat-1
						Exit
					EndIf
				EndDo
				// chegou no ultimo
				If nCntBat > Len(aCsvAux)
					nUltimo := nCntBat-1
					lContinua := .F.
				EndIf

				// mudou ordem -> fazer soma da ordem
				nTOTAL := 0
				for nI := nInicio To nUltimo
					nTOTAL += aCsvAux[nI, 12]
				next nI

				for nI := nInicio To nUltimo
					/* 16 */ aAdd( aCsvAux[nI], aCsvAux[nI, 12] / nTOTAL * 100 )
				next nI

			EndDo
		EndIf

		For nCntBat := 1 To Len(aCsvAux) // linha
			For nCol := 1 To 11 // Len(aCsvAux[ nCntBat ])
				If ValType( aCsvAux[nCntBat, nCol] ) == "C"
					cCsvEBt += aCsvAux[nCntBat, nCol] + ";"
				Else
					cCsvEBt += cValToChar( aCsvAux[nCntBat, nCol] ) + ";"
				EndIf
			Next nCol
			/* 12 */ cCsvEBt += AllTrim(Transform(aCsvAux[nCntBat, 12], iIf(aCsvAux[nCntBat, 13]=='P',"@E 999,999,999.99", "@E 999999999"))) + ";"
			/* 13 */ cCsvEBt += AllTrim(STRTRAN(STR(Round(aCsvAux[nCntBat, 16], 4)), ".", ",")) + ";"
			/* 14 */ cCsvEBt += aCsvAux[nCntBat, 13] + ";" // tipo de carregamento
			/* 15 */ cCsvEBt += aCsvAux[nCntBat, 14] + ";" // roteiro
			/* 16 */ cCsvEBt += aCsvAux[nCntBat, 15] + ";" // % materia seca
			cCsvEBt += _ENTER_
		Next nCntBat

		cCsvExp := cCsvEBt + cCsvETr

		// MB : 02.04.2022
		If (lCnt)
			// If (aParRet[5] == 1)
			cArqExC := "programacao-" + AllTrim(Str(DAY(Z0X->Z0X_DATA)))  +"-" +;
				AllTrim(Str(Month(Z0X->Z0X_DATA)))+"-" +;
				AllTrim(Str(Year(Z0X->Z0X_DATA))) +;
				Iif(Empty(cEquip),"","-" + cEquip) +;
				"-V" + Z0X->Z0X_VERSAO + ".csv"
			MEMOWRITE(cLocArq + cArqExC, cCsvExp)
			MEMOWRITE("C:" + cLocArq + cArqExC, cCsvExp)
			// Else
			// 	MEMOWRITE(cLocArq + cArqExJ, cJsnExp)
			// 	MEMOWRITE("C:" + cLocArq + cArqExJ, cJsnExp)
			// EndIf
		EndIf

		RecLock("Z0X", .F.)
		Z0X->Z0X_CNTEXP := cJsnExp + " | " + cCsvExp
		Z0X->Z0X_ARQEXP := cArqExJ + " | " + cArqExC
		Z0X->Z0X_STATUS := "G"
		Z0X->Z0X_DATEXP := Date()
		Z0X->Z0X_USUEXP := __cUserId
		Z0X->(MSUnlock())

		// /* if (aParRet[4] == 1) // 4 == operacao // 1 == trato; 2 = fabrica
		// 	if (Len(aPhibro)>0)
		// 		cRet    := gerarPhibro( aPhibro )
		// 		aPhibro := {}
		// 	EndIf
		// else */
		// If (aParRet[4] == 2)
		//
		// 	cQryExp := " UPDATE " + RetSqlName("Z0J") + _ENTER_
		// 	cQryExp += " 	SET Z0J_EXPGER = '1' " + _ENTER_
		// 	cQryExp += " WHERE Z0J_FILIAL = '" + xFilial("Z0J") + "'" + _ENTER_
		// 	cQryExp += "   AND Z0J_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_
		// 	// Nao existe tratameto de versao na f�brica.
		// 	// cQryExp += "   AND Z0J_VERSAO = '" +  cVersao  + "'" + _ENTER_
		// 	cQryExp += "   AND Z0J_EQUIPA = '" + aEqpJsn[nCntEqp] + "'" + _ENTER_
		// 	cQryExp += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
		//
		// 	If (TCSqlExec(cQryExp) < 0)
		// 		MsgInfo(TCSqlError())
		// 	EndIf
		// EndIf
		// MsgInfo(cMsgExp, "Arquivo JSON " + IIf (aParRet[4] = 1, "Carreg. | Trato", "Fabrica"))

		// EndIf
		lCnt := .T.

	End Transaction

Next nCntEqp
MsgInfo( cMsgExp, "Arquivo(s) JSON Carreg. | Trato." )

RestArea(aArea)
Return (Nil)


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 25.11.2021                                                           |
 | Cliente  : Livio                                                                |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Parametros :  - cTpCarreg: P=Phibro; I=Imbif                                    |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function fCriaZ0YAgua( cTpCarreg, cSeqOrd, nCntTrt, cCodRec, nQtdPre, aOrdCur, nCntOrd, aCsvAux, nCntSeq )
Local aArea   := GetArea()
Local cCodigo := GetNextCod("Z0Y_CODIGO")
Local _cAgua  := GetMV( "MB_PCPA13A",, "990012")
	
	/* xx */ aAdd( aCsvAux, {} )
	/* 01 */ aAdd( aTail(aCsvAux), "C" )
	/* 02 */ aAdd( aTail(aCsvAux), AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0") + _cEquipamento /*aParRet[3]*/, "ZV0_IDENT")) )
	/* 03 */ aAdd( aTail(aCsvAux), DTOC(Z0X->Z0X_DATA) )
	/* 04 */ aAdd( aTail(aCsvAux), cSeqOrd )
	/* 05 */ aAdd( aTail(aCsvAux), Z0X->Z0X_VERSAO )
	/* 06 */ aAdd( aTail(aCsvAux), AllTrim(STR(nCntTrt)) )
	/* 07 */ aAdd( aTail(aCsvAux), rTrim(cCodRec) )
	/* 08 */ aAdd( aTail(aCsvAux), rTrim(POSICIONE("SB1", 1, xFilial("SB1") + cCodRec, "B1_XDESC")) )
	/* 09 */ aAdd( aTail(aCsvAux), StrZero( nCntSeq, TamSX3('G1_TRT')[1]) )
	/* 10 */ aAdd( aTail(aCsvAux), rTrim(_cAgua/* QRYREC->ITEM */) )
	/* 11 */ aAdd( aTail(aCsvAux), rTrim(POSICIONE("SB1", 1, xFilial("SB1")+ AllTrim(_cAgua/* QRYREC->ITEM */), "B1_XDESC")) )
	/* 12 */ aAdd( aTail(aCsvAux), nQtdPre )
	/* 13 */ aAdd( aTail(aCsvAux), cTpCarreg )

	RecLock("Z0Y", .T.)
		Z0Y->Z0Y_FILIAL := xFilial("Z0Y")
		Z0Y->Z0Y_CODIGO := cCodigo
		Z0Y->Z0Y_CODEI  := Z0X->Z0X_CODIGO
		Z0Y->Z0Y_TRATO  := "1" /*  AllTrim(STR(nCntTrt))  */// IIf(aParRet[4] == 1, AllTrim(STR(nCntTrt)), PADL(nCntTrt, 2))
		Z0Y->Z0Y_ORDEM  := cSeqOrd// IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
		Z0Y->Z0Y_AJUSTE := 0
		Z0Y->Z0Y_TIMER  := "" // QRYREC->TIMER
		Z0Y->Z0Y_RECEIT := cCodRec // QRYREC->RECEITA
		Z0Y->Z0Y_COMP   := _cAgua // agua // QRYREC->ITEM
		Z0Y->Z0Y_QTDPRE := nQtdPre
		Z0Y->Z0Y_QTDREA := 0
		Z0Y->Z0Y_TOLERA := 0
		Z0Y->Z0Y_ROTA   :=  AllTrim(aOrdCur[nCntOrd][1])
		Z0Y->Z0Y_DATA   := Z0X->Z0X_DATA
		Z0Y->Z0Y_VERSAO := Z0X->Z0X_VERSAO
		Z0Y->Z0Y_SEQ    := nCntSeq // StrZero( nCntSeq, TamSX3('G1_TRT')[1])
		// Z0Y->Z0Y_EQUIP  := aParRet[3]
		Z0Y->Z0Y_ORIGEM := cTpCarreg
	Z0Y->(MSUnlock())

RestArea( aArea )
Return nil

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2019                                                           |
 | Cliente  : Livio                                                                |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local aRegs		:= {}
Local i := 0, j := 0

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

If cPerg == "PCPA13IMP"
	aAdd(aRegs, { cPerg, "01", "Tipo do Arquivo","","","mv_ch1","N",01,0,0,"C","","MV_PAR01","1=JSon","","","","","2=CSV","","","","","","","","","","","","","","","","","","","      ","N","","",""})

ElseIf cPerg == "IMPZ0WPCP1"
	aAdd(aRegs, { cPerg, '01', 'Selecionar Motivos?', '', '', 'MV_CH1', 'C',					  02, 						0, 0, 'G', 'U_fMotivos()', 'MV_PAR01', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '02', 'Curral?            ', '', '', 'MV_CH2', 'C', TamSX3('Z0W_CURRAL')[1],                       0, 0, 'G', ''            , 'MV_PAR02', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '03', 'Vagao?             ', '', '', 'MV_CH3', 'C', TamSX3('ZV0_DESC')[1]  ,                       0, 0, 'G', ''            , 'MV_PAR03', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '04', 'Codigo Receita?	   ', '', '', 'MV_CH4', 'C', TamSX3('Z0W_RECEIT')[1],                       0, 0, 'G', ''            , 'MV_PAR04', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '05', 'Ordem de Producao? ', '', '', 'MV_CH5', 'C', TamSX3('Z0W_ORDEM')[1] ,                       0, 0, 'G', ''            , 'MV_PAR05', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '06', 'Nro Fornecimento?  ', '', '', 'MV_CH6', 'C', TamSX3('Z0W_TRATO')[1] ,                       0, 0, 'G', ''            , 'MV_PAR06', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	aAdd(aRegs, { cPerg, '07', 'Qtd Realizada?     ', '', '', 'MV_CH7', 'C', TamSX3('Z0W_QTDREA')[1], TamSX3('Z0W_QTDREA')[2], 0, 'G', ''            , 'MV_PAR07', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
	
EndIf

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravacao das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
// FIM: GeraX1


/* ****************************************************************************************************** */
User Function ImpJSon()

Local aArea := GetArea()
Local cJsnImp  := ""
Local cQryImp  := ""
Local aCntJsn  := {}
Local cTrtBat  := ""
Local nLenOrd  := 0
Local nLenTrt  := 0
Local nCntOrd  := 0
Local nCntCmp  := 0
Local nCntTrt  := 0
Local nCntCur  := 0
//Local nQtdRea  := 0
//Local nQtdDif  := 0
Local cSttImp  := ""
Local cSepJsn  := ""
Local aDatHorI := {}
Local aDatHorF := {}

//cJsnImp := MEMOREAD(aParRet[1])
cJsnImp := u_LoadGig(aParRet[1])

DBSelectArea("Z0X")
Z0X->(DBSetOrder(2))

DBSelectArea("Z0Y")
Z0Y->(DBSetOrder(2))

DBSelectArea("Z0W")
Z0W->(DBSetOrder(1))

If  (!Empty(cJsnImp))

		aCntJsn := FromJson(cJsnImp)
		
		nLenOrd := aCntJsn[#'equips'][1][#'nordens']
		
		Begin Transaction

			For nCntOrd := 1 To nLenOrd
			
				nLenTrt := Len(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'receitas'])
				For nCntTrt := 1 To nLenTrt
				
					cTrtBat := IIf (Z0X->Z0X_OPERAC = "1", AllTrim(STR(nCntTrt)), PADL(nCntTrt, 2))
				
					If (Z0Y->(DBSeek(xFilial("Z0Y") + aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'ordemproducao'] + cTrtBat)))
				
						If !(Z0X->(DBSeek(xFilial("Z0X") + Z0Y->Z0Y_CODEI)))
							MsgInfo("Exportacao '" + Z0Y->Z0Y_CODEI + "' nao encontrada. Abortando...")
							DisarmTransaction()
							Break
						EndIf
				
						cCodOrd := Z0Y->Z0Y_ORDEM
						nCntCmp := 1
						
						aDatHorI := StrToKArr(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'starttimeload'][nCntTrt], '-')
						aDatHorF := StrToKArr(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'finishtimeload'][nCntTrt], '-')
						
						If (Len(aDatHorI) = 0)
							aDatHorI := {"", ""} 
						EndIf
						
						If (Len(aDatHorF) = 0)
							aDatHorF := {"", ""} 
						EndIf
						
						While ((Z0Y->Z0Y_ORDEM = cCodOrd) .AND. (Z0Y->Z0Y_TRATO = cTrtBat))
				
							RecLock("Z0Y", .F.)
								Z0Y->Z0Y_QTDREA := VAL(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'pesosrealizados'][nCntTrt][nCntCmp])
								Z0Y->Z0Y_DIFPES := VAL(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'diferencacarregamento'][nCntTrt][nCntCmp])
								Z0Y->Z0Y_DATINI := CTOD(AllTrim(aDatHorI[1]))
								Z0Y->Z0Y_HORINI := AllTrim(aDatHorI[2])
								Z0Y->Z0Y_DATFIN := CTOD(AllTrim(aDatHorF[1]))
								Z0Y->Z0Y_HORFIN := AllTrim(aDatHorF[2])
							Z0Y->(MSUnlock())
						
							Z0Y->(DBSkip())
							nCntCmp += 1
						EndDo
					Else
					
						MsgInfo("A exportacao da ordem ('" + aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'ordemproducao'] + "') do Carreg. para o Trato N " + AllTrim(STR(nCntTrt)) + " nao foi encontrada, verifique e tente novamente.")
						DisarmTransaction()
						Break
					EndIf
					
				Next nCntTrt
					
				If (Z0X->Z0X_OPERAC = "1")
					
					For nCntTrt := 1 To nLenTrt
							
						aDatHorI := StrToKArr(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'starttimedisc'][nCntTrt], '-')
						aDatHorF := StrToKArr(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'finishtimedisc'][nCntTrt], '-')
							
						If (Len(aDatHorI) = 0)
							aDatHorI := {"", ""} 
						EndIf
						
						If (Len(aDatHorF) = 0)
							aDatHorF := {"", ""} 
						EndIf
							
						For nCntCur := 1 To Len(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'currais'])
							
							If (Z0W->(DBSeek(xFilial("Z0W") + Z0X->Z0X_CODIGO + AllTrim(STR(nCntTrt)) + UPPER(AllTrim(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'currais'][nCntCur])))))
		
								RecLock("Z0W", .F.)
									Z0W->Z0W_QTDREA := VAL(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'tratosrealizados'][nCntTrt][nCntCur])
									Z0W->Z0W_DIFPES := VAL(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'diferencadescarregamento'][nCntTrt][nCntCur])
									Z0W->Z0W_DATINI := CTOD(AllTrim(aDatHorI[1]))
									Z0W->Z0W_HORINI := AllTrim(aDatHorI[2])
									Z0W->Z0W_DATFIN := CTOD(AllTrim(aDatHorF[1]))
									Z0W->Z0W_HORFIN := AllTrim(aDatHorF[2])
								Z0W->(MSUnlock())
		
								Z0W->(DBSkip())
							Else
								MsgInfo("A exportacao da ordem ('" + aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'ordemproducao'] + "') do Descarregamento para o Curral " + AllTrim(aCntJsn[#'equips'][1][#'ordens'][nCntOrd][#'currais'][nCntCur]) + " Trato N " + AllTrim(STR(nCntTrt)) + " nao foi encontrada, verifique e tente novamente.") 
								DisarmTransaction()
								Break
							EndIf
												
						Next nCntCur
					Next nCntTrt
				EndIf
			Next nCntOrd

			If (Z0X->Z0X_STATUS = "A")
				cSepJsn := Z0X->Z0X_STATUS + " | "
			Else
				cSepJsn := ""
			EndIf

			cQryImp := " SELECT * "
			cQryImp += " FROM " + RetSqlName("Z0Y") + " Z0Y "
			cQryImp += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'"
			cQryImp += "   AND Z0Y.Z0Y_QTDREA = 0 "
			cQryImp += "   AND Z0Y.D_E_L_E_T_ = ' ' "
			cQryImp += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'"

			TCQUERY cQryImp NEW ALIAS "QRYIMP"

			If (QRYIMP->(EOF()))
				cSttImp := "I"
			Else
				cSttImp := "A"
			EndIf
			QRYIMP->(DBCloseArea())

			Reclock("Z0X")
				Z0X->Z0X_CNTIMP := cSepJsn + cJsnImp
				Z0X->Z0X_ARQIMP := aParRet[1]
				Z0X->Z0X_DATIMP := Date()
				Z0X->Z0X_USUIMP := __cUserId
				Z0X->Z0X_STATUS := cSttImp
			Z0X->(MSUnlock())
			
			If (Z0X->Z0X_OPERAC = "1")
				If (cSttImp = 'I')
					DBSelectArea("Z0R")
					Z0R->(DBSetOrder(1))
					
					If (Z0R->(DBSeek(xFilial("Z0R") + DTOS(Z0X->Z0X_DATA) + Z0X->Z0X_VERSAO)))
						RecLock("Z0R", .F.)
							Z0R->Z0R_LOCK := '3'
						Z0R->(MSUnlock())
					EndIf
				EndIf

			EndIf
		End Transaction
	Else
		MsgInfo("Nao foi possivel abrir o arquivo '" + aParRet[1] + "', verifique e tente novamente.")
	EndIf
	MsgInfo("Importacao concluida com sucesso!")
	RestArea(aArea)
Return (Nil)



Static Function ExpImpRot()

Local aResult := {}
Local cQryRot := ""
// Local oMdlAt  := FWModelActive()
// Local oViwAt  := FWViewActive()
Local cTik    := aTik[1]


/* 	cQryRot := " SELECT DISTINCT(Z0Y.Z0Y_ORDEM) AS ORDEM, Z0Y.Z0Y_ROTA AS ROTA " + _ENTER_
	cQryRot += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
	cQryRot += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryRot += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryRot += " ORDER BY Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_ROTA " + _ENTER_ */
	cQryRot := " SELECT DISTINCT(Z0W.Z0W_ORDEM) AS ORDEM, Z0W.Z0W_ROTA AS ROTA " + _ENTER_
	cQryRot += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
	cQryRot += " WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "' AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryRot += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryRot += " ORDER BY Z0W.Z0W_ORDEM, Z0W.Z0W_ROTA " + _ENTER_

MEMOWRITE("C:\TOTVS_RELATORIOS\EXPIMPROT.SQL", cQryRot)
TCQUERY cQryRot NEW ALIAS "QRYROT"

While (!(QRYROT->(EOF())))
	AAdd(aResult, {cTik, U_CONFER(1, "", QRYROT->ORDEM), QRYROT->ORDEM, QRYROT->ROTA, .F.})
	QRYROT->(DBSkip())
	cTik := aTik[2]	
EndDo
QRYROT->(DBCloseArea())

Return (aResult)


Static Function ExpImpTrt()

Local aResult := {}
Local cQryTrt := ""
// Local oMdlAt  := FWModelActive()
// Local oViwAt  := FWViewActive()
Local cTik    := aTik[1]

// Local oViwAt := FWViewActive()
// If oViwAt:aFolders[1,5]:NOPTION == 1 // Carregamento
// 	cQryTrt := " SELECT DISTINCT(Z0Y.Z0Y_TRATO) AS TRATO, Z0Y.Z0Y_RECEIT AS RECEITA, (SELECT SB1.B1_DESC FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = Z0Y.Z0Y_RECEIT) AS DSCDIE " + _ENTER_
// 	cQryTrt += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
// 	cQryTrt += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
// 	cQryTrt += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
// 	cQryTrt += "   AND Z0Y.Z0Y_ORDEM = '" + aDadSel[1] + "'" + _ENTER_
// 	cQryTrt += " ORDER BY Z0Y.Z0Y_TRATO " + _ENTER_ 
// Else // If oViwAt:aFolders[1,5]:NOPTION == 2 == Trato
	cQryTrt := " SELECT DISTINCT(Z0W.Z0W_TRATO) AS TRATO, Z0W.Z0W_RECEIT AS RECEITA, (SELECT SB1.B1_DESC FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = Z0W.Z0W_RECEIT) AS DSCDIE " + _ENTER_
	cQryTrt += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
	cQryTrt += " WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "' AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryTrt += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryTrt += "   AND Z0W.Z0W_ORDEM = '" + aDadSel[1] + "'" + _ENTER_
	cQryTrt += " ORDER BY Z0W.Z0W_RECEIT, Z0W.Z0W_TRATO " + _ENTER_ 
// EndIf

MEMOWRITE("C:\TOTVS_RELATORIOS\EXPIMPTRT.SQL", cQryTrt)
TCQUERY cQryTrt NEW ALIAS "QRYTRT"

While (!(QRYTRT->(EOF())))
	AAdd(aResult, {cTik, U_CONFER(2, QRYTRT->TRATO,; // PadL(AllTrim(QRYTRT->TRATO), TamSX3('Z0W_TRATO')[1], "0")
									 aDadSel[1]),;
									 QRYTRT->TRATO,;
									 /*QRYTRT->RECEITA,*/ AllTrim(QRYTRT->DSCDIE), .F.})
	QRYTRT->(DBSkip())
	cTik    := aTik[2]
EndDo

If !Empty(aResult)
	aSort( aResult,,, { |x,y| AllTrim(x[4])+PadL(AllTrim(x[3]),2,"0") < AllTrim(y[4])+PadL(AllTrim(y[3]),2,"0") } ) // aSort( aResult,,, { |x,y| PadL(AllTrim(x[3]),2,"0") < PadL(AllTrim(y[3]),2,"0") } )
EndIf
QRYTRT->(DBCloseArea())

Return (aResult)


/* ****************************************************************************************************** */
Static Function ChgRot(nLin)

Local oMdlAt := FWModelActive()
Local oViwAt := FWViewActive()
Local lChgRt := .T.
Local nCntLn := 1

If (Len(oGrdFRt:aCols) > 0)

	if oViwAt:GetModel("MdGrdZ0Y"):IsUpdated() .or. ((Z0X->Z0X_OPERAC == "1") .and. oViwAt:GetModel("MdGrdZ0W"):IsUpdated())
	    FWFormCommit( oMdlAt )
	endif
	
	aDadSel[1] := oGrdFRt:aCols[nLin][3]
	aDadSel[2] := IIf(Z0X->Z0X_OPERAC $ ("13"), "1", " 1") // aDadSel[2] := IIf(Z0X->Z0X_OPERAC == "1", "1", " 1")
	aDadSel[3] := oGrdFRt:aCols[nLin][4]
	
	For nCntLn := 1 To Len(oGrdFRt:aCols)
		If (nCntLn = nLin)
			oGrdFRt:aCols[nCntLn][1] := aTik[1]
		Else
			oGrdFRt:aCols[nCntLn][1] := aTik[2]
		EndIf
	Next nCntLn
	
	oMdlAt:DeActivate()
	
	oMdlAt:GetModel("MdGrdZ0Y"):SetLoadFilter({{"Z0Y_CODEI", Z0X->Z0X_CODIGO},;
											   {"Z0Y_ORDEM", "'" + aDadSel[1] + "'"} ,; // /* , {"Z0Y_TRATO", "'" + aDadSel[2] + "'"} */ 
											   {"Z0Y_RECEIT", "'" + Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) + "'"} })
	
	If (Z0X->Z0X_OPERAC == "1")
		oMdlAt:GetModel("MdGrdZ0W"):SetLoadFilter({;
					{"Z0W_CODEI", Z0X->Z0X_CODIGO},;
					{"Z0W_TRATO", "'" + aDadSel[2] + "'"},;
					{"Z0W_ROTA" , "'" + aDadSel[3] + "'"}})
	EndIf
		
	oMdlAt:Activate()
 
	aClsGFT := ExpImpTrt()
	
	//oGrdFRt:SetArray(aClsGFR)
	oGrdFRt:Refresh(.T.)
	
	oGrdFTr:SetArray(aClsGFT)
	oGrdFTr:Refresh()	

	oViwAt:Refresh("MdGrdZ0Y")
	
	If (Z0X->Z0X_OPERAC = "1")
		oViwAt:Refresh("MdGrdZ0W")
	EndIf

	TotSl(Nil, .F.)
	TotEI(Nil, .F.)

	If (Z0X->Z0X_OPERAC = "1")
		/* Alert('ChgRot(nLin): ' + cValToChar(nLin)) */
		LegCur(Nil, .F.)
	EndIf
	
EndIf

Return (lChgRt)


/* ****************************************************************************************************** */
Static Function ChgTrt(nLin)

Local oMdlAt := FWModelActive()
Local oViwAt := FWViewActive()
Local lChgTr := .T.
Local nCntLn := 1

// Local aClsGFT := ExpImpTrt()
// oGrdFTr:SetArray(aClsGFT)
// oGrdFTr:Refresh()	

If (Len(oGrdFTr:aCols) > 0)
	
	if oViwAt:GetModel("MdGrdZ0Y"):IsUpdated() .or. ((Z0X->Z0X_OPERAC = "1") .and. oViwAt:GetModel("MdGrdZ0W"):IsUpdated())
	    FWFormCommit( oMdlAt )
	endif

	aDadSel[2] := oGrdFTr:aCols[nLin][3]
	
	For nCntLn := 1 To Len(oGrdFTr:aCols)
		If (nCntLn = nLin)
			oGrdFTr:aCols[nCntLn][1] := aTik[1]
		Else
			oGrdFTr:aCols[nCntLn][1] := aTik[2]
		EndIf
	Next nCntLn

	oMdlAt:DeActivate()

	oViwAt:GetModel("MdGrdZ0Y"):SetLoadFilter({{"Z0Y_CODEI", Z0X->Z0X_CODIGO},;
											   {"Z0Y_ORDEM", "'" + aDadSel[1] + "'"} ,; // /* , {"Z0Y_TRATO", "'" + aDadSel[2] + "'"} */ 
											   {"Z0Y_RECEIT", "'" + Posicione( "SB1", 3, xFilial("SB1")+oGrdFTr:aCols[ oGrdFTr:nAt, 4 ], "B1_COD" ) + "'"} })
	If (Z0X->Z0X_OPERAC == "1")
		oViwAt:GetModel("MdGrdZ0W"):SetLoadFilter({{"Z0W_CODEI", Z0X->Z0X_CODIGO},;
												   {"Z0W_TRATO", "'" + aDadSel[2] + "'"},;
												   {"Z0W_ROTA" , "'" + aDadSel[3] + "'"}})
	EndIf
	
	oMdlAt:Activate()
	
	oViwAt:Refresh("MdGrdZ0Y")
	
	If (Z0X->Z0X_OPERAC == "1")
		oViwAt:Refresh("MdGrdZ0W")
	EndIf

	oGrdFTr:Refresh(.T.)
	
	TotSl(Nil, .F.)

	If (Z0X->Z0X_OPERAC == "1")
		/* alert('ChgTrt(nLin): ' + cValToChar(nLin)) */
		LegCur(Nil, .F.)
	EndIf

EndIf

Return (lChgTr)


User Function Confer(nGrd, cTrt, cOrd)

Local cConfer := aTik[2]
Local cQryCfr := ""
// Local oMdlAt  := FWModelActive()
// Local oViwAt  := FWViewActive()
/* 
cQryCfr := " SELECT * " + _ENTER_
cQryCfr += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
cQryCfr += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
cQryCfr += "   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
cQryCfr += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
cQryCfr += "   AND Z0Y.Z0Y_ORDEM = '" + cOrd + "'" + _ENTER_
If (nGrd = 2)
	cQryCfr += "   AND lTrim(Z0Y.Z0Y_TRATO) = '" + AllTrim(cTrt) + "'"  + _ENTER_
EndIf
cQryCfr += "   AND Z0Y.Z0Y_CONFER = 'F' " + _ENTER_
*/

					cQryCfr := " SELECT * " + _ENTER_
					cQryCfr += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
					cQryCfr += " WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
					cQryCfr += "   AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
					cQryCfr += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
					cQryCfr += "   AND Z0W.Z0W_ORDEM = '" + cOrd + "'" + _ENTER_
					If (nGrd = 2)
						cQryCfr += "   AND lTrim(Z0W.Z0W_TRATO) = '" + AllTrim(cTrt) + "'"  + _ENTER_
					EndIf
					cQryCfr += "   AND Z0W.Z0W_CONFER = 'F' " + _ENTER_

					TCQUERY cQryCfr NEW ALIAS "QRYCFR"

					If (QRYCFR->(EOF()))
						cConfer := aTik[1]
					EndIf
					QRYCFR->(DBCloseArea())

					Return (cConfer)


User Function MotCor()

	Local cLstMC := ""
	Local cTabMC := AllTrim(GETMV("VA_TBMOTCO",,"ZX"))

	DBSelectArea("SX5")
	SX5->(DBSetOrder(1))

	If (SX5->(DBSeek(xFilial("SX5") + cTabMC)))
		While (SX5->X5_TABELA = cTabMC)

			cLstMC += IIf(Empty(cLstMC), "", ";") + AllTrim(SX5->X5_CHAVE) + "=" + AllTrim(SX5->X5_DESCRI)

			SX5->(DBSkip())
		EndDo
	EndIf

Return (cLstMC)


/* ############################################################################## */
User Function GRVPSD(nOpc)

	Local lVldPDG := .T.
	Local aArea   := GetArea()

	If (FUNNAME() == "VAPCPA13")

		If nOpc == 1

			Z0Y->(DBSetOrder(3))
			If (Z0Y->(DBSeek(xFilial("Z0Y")+FWFldGet("Z0Y_CODIGO"))))
				RecLock("Z0Y", .F.)
				Z0Y->Z0Y_PESDIG := FWFldGet("Z0Y_PESDIG")
				Z0Y->Z0Y_MOTCOR := FWFldGet("Z0Y_MOTCOR")
				MsUnlock()
			EndIf

		ElseIf (nOpc == 2)

			Z0W->(DBSetOrder(4))
			If (Z0W->(DBSeek(xFilial("Z0W")+FWFldGet("Z0W_CODIGO"))))
				RecLock("Z0W", .F.)
				Z0W->Z0W_PESDIG := FWFldGet("Z0W_PESDIG")
				Z0W->Z0W_MOTCOR := FWFldGet("Z0W_MOTCOR")
				MsUnlock()
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return (lVldPDG)


/* ############################################################################## */
User Function ShwFilTl()

	Local lVldFil := .T.
	Local aParBox := {}
	Local oViwAt  := FWViewActive()

	AAdd(aParBox, {1,"VERDE    ",0,"@E 9.999,99","",,"",50,.F.})          // aFilRet[1]
	AAdd(aParBox, {1,"LARANJA  ",0,"@E 9.999,99","",,"",50,.F.})          // aFilRet[2]
	AAdd(aParBox, {1,"VERMELHO ",0,"@E 9.999,99","",,"",50,.F.})          // aFilRet[3]
	aAdd(aParBox, {2,"Operacao ","1",{"1=Trato","2=Fabrica"},50,"",.F.})  // aFilRet[4]

	If (ParamBox(aParBox, "Filtros Exp|Imp Carreg.|Trato", @aFilRet) .AND. (oViwAt != Nil))
		oViwAt:Refresh()
	EndIf

Return (lVldFil)


/* ############################################################################## */
User Function LoadGig(cFile)
	Local nHandle := fOpen(cFile)
	Local cBufferVar := ""
	Local cStream := ""
	Local nBuffer := 65535

	If nHandle > -1
		While fread(nHandle, @cBufferVar, nBuffer) > 0
			cStream += cBufferVar
			cBufferVar := ""
		EndDo
	EndIf
	fClose(nHandle)
Return cStream


Static Function ShwDtL()

	Local aArea   := GetArea()
	Local lVldDtL := .T.
	Local oDlgDtL
	Local oGrdDtL
	Local aHdrDtL := {}
	Local aClsDtL := {}
	Local oTFntGr := TFont():New('Courier New',,16,.T.,.T.)
	Local oMdlAt  := FWModelActive()
	Local oViwAt  := FWViewActive()
	Local cLote   := oMdlAt:GetModel("MdGrdZ0W"):GetValue("Z0W_LOTE", oMdlAt:GetModel("MdGrdZ0W"):GetLine())

	AAdd(aHdrDtL, {"Trato"       ,"Trato"     , ""             , 02, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrDtL, {"Quantidade"  ,"Quantidade", "@R 999,999.99", 10, 2, "", "", "N", "", "R", "", "", "", "V"})

	DBSelectAre("Z0W")
	Z0W->(DBSetOrder(5)) //Lote+Data
	Z0W->(DBGoTop())
	If (Z0W->(DBSeek(xFilial("Z0W") + cLote + DTOS(Z0X->Z0X_DATA))))
		While (cLote = Z0W->Z0W_LOTE .AND. Z0W->Z0W_DATA = Z0X->Z0X_DATA)

			AAdd(aClsDtL, {Z0W->Z0W_TRATO, Z0W->Z0W_QTDPRE, .F.})
			Z0W->(DBSkip())
		EndDo
	Else
		MsgInfo("Lote (" + cLote + ") Nao encontrado na data " + DTOC(Z0X->Z0X_DATA) + ".")
	EndIf

	SetKey(VK_F2, {|| oDlgDtL:End()})

	DEFINE MSDIALOG oDlgDtL TITLE "Detalhes do Lote" FROM 000, 000 To 400, 500 PIXEL

	TSay():New(005, 005, {|| cLote}, oDlgDtL,,oTFntGr,,,,.T., CLR_BLACK, CLR_WHITE, 100, 20)
	oGrdDtL := MsNewGetDados():New(015, 005, 090, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgDtL, aHdrDtL, aClsDtL)

	oDlgDtL:lEscClose := .T.

	ACTIVATE MSDIALOG oDlgDtL CENTERED

	SetKey(VK_F2, {|| ShwDtL()})

	RestArea(aArea)

Return (lVldDtL)


User Function VAP13F3()

	Local oDlgF3R
	Local cQryRot := ""
	Local aHdrRot := {}
	Local aClsRot := {}
	Local nCntRot := 0

	Private oGrdF3R

	AAdd(aHdrRot, {"Sel."    ,"Selecionado", "@BMP"         , 01, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Rota"    ,"Rota"       , ""             , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Vag�o"    ,"Vag�o"       , ""             , 06, 0, "", "", "C", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Total"   ,"Total"      , "@R 999,999.99", 10, 2, "", "", "N", "", "R", "", "", "", "V"})
	AAdd(aHdrRot, {"Operador","Operador"   , ""             , 20, 0, "", "", "C", "", "R", "", "", "", "V"})


	cQryRot := " SELECT Z0S.Z0S_ROTA AS ROTA, ZV0_IDENT AS VAGAO, Z0S.Z0S_TOTTRT AS TOTAL, Z0S.Z0S_OPERAD AS OPERAD" + _ENTER_
	cQryRot += " FROM " + RetSqlName("Z0S") +  " Z0S " + _ENTER_
	cQryRot += " LEFT JOIN " + RetSqlName("ZV0") +  " ZV0 ON ZV0_CODIGO = Z0S_EQUIP AND ZV0.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryRot += " WHERE Z0S.Z0S_FILIAL = '" + xFilial("Z0S") + "'" + _ENTER_
	cQryRot += "   AND Z0S.Z0S_DATA = '" + DTOS(MV_PAR01) + "'" + _ENTER_
	cQryRot += "   AND Z0S.Z0S_VERSAO = ( SELECT MAX(Z0SA.Z0S_VERSAO) FROM " + RetSqlName("Z0S") + " Z0SA WHERE Z0SA.Z0S_FILIAL = '" + xFilial("Z0S") + "'" + _ENTER_
	cQryRot += "                                                                                           AND Z0SA.Z0S_DATA = '" + DTOS(MV_PAR01) + "'" + _ENTER_
	cQryRot += "                                                                                           AND Z0SA.D_E_L_E_T_ = ' '  " + _ENTER_
	cQryRot += "                                                                                           AND Z0SA.Z0S_EQUIP = '" + MV_PAR03 + "' ) " + _ENTER_
	IF !Empty(MV_PAR03)
		cQryRot += "   AND ISNULL(Z0S.Z0S_EQUIP, '      ') = '" + MV_PAR03 + "'" + _ENTER_
	EndIf
	cQryRot += "   AND Z0S.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryRot += " ORDER BY Z0S.Z0S_ROTA "

	MEMOWRITE("C:\TOTVS_RELATORIOS\F3ROTAS.SQL", cQryRot)

	TCQUERY cQryRot NEW ALIAS "QRYROT"

	While !(QRYROT->(EOF()))
		AAdd(aClsRot, {aTik[2] /*aTik[1]*/, QRYROT->ROTA, QRYROT->VAGAO, QRYROT->TOTAL, POSICIONE("Z0U", 1, xFilial("Z0U") + QRYROT->OPERAD, "Z0U_NOME"), .F.})

		QRYROT->(DBSkip())
	EndDo
	QRYROT->(DBCloseArea())

	DEFINE MSDIALOG oDlgF3R TITLE "Rotas para Exportar" FROM 000, 000 To 400, 500 PIXEL

	oGrdF3R := MsNewGetDados():New(015, 005, 090, 250,, "AllwaysTrue", "AllwaysTrue",,, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgF3R, aHdrRot, aClsRot)
	oGrdF3R:oBrowse:bLDblClick := {|| MarkRot(), oGrdF3R:Refresh()}

	tButton():New(180, 180, "Confirmar", oDlgF3R, {|| oDlgF3R:End()}, 60, 15,,,, .T.)

	oDlgF3R:lEscClose := .T.

	ACTIVATE MSDIALOG oDlgF3R CENTERED

	cRotSel := ""

	For nCntRot := 1 To Len(aClsRot)

		If (oGrdF3R:aCols[nCntRot, 1] = aTik[1])
			cRotSel += Iif (!Empty(cRotSel), ",", "") + "'" + oGrdF3R:aCols[nCntRot, 2] + "'"
		EndIf

	Next nCntRot

	&(ReadVar()) := cRotSel

Return (.T.)


Static Function MarkRot()

	Local lVldSRt := .T.

	If (oGrdF3R:aCols[oGrdF3R:nAt, 1] = aTik[1])
		oGrdF3R:aCols[oGrdF3R:nAt, 1] := aTik[2]
	Else
		oGrdF3R:aCols[oGrdF3R:nAt, 1] := aTik[1]
	EndIf

	oGrdF3R:Refresh(.T.)

Return (lVldSRt)



static function GetNextCod(cCampo)
	Local aArea := GetArea()
	Local cID := ""

	if cCampo == "Z0X_CODIGO"

		while !LockByName("GetNextCod_Z0X", .t., .f.)
			Sleep(1000)
		end

		if Empty(cID := GetMV("VA_Z0XCOD",,""))
			cID := StrZero(1, TamSX3("Z0X_CODIGO")[1])
		endif

		cID := Soma1(cID)

		while !PutMV("VA_Z0XCOD", cID)
			Sleep(1000)
		end

		UnlockByName("GetNextCod_Z0X")

	elseif cCampo == "Z0Y_CODIGO"

		while !LockByName("GetNextCod_Z0Y", .t., .f.)
			Sleep(1000)
		end

		if Empty(cID := GetMV("VA_Z0YCOD",,""))
			cID := StrZero(1, TamSX3("Z0Y_CODIGO")[1])
		endif

		cID := Soma1(cID)

		while !PutMV("VA_Z0YCOD", cID)
			Sleep(1000)
		end

		UnlockByName("GetNextCod_Z0Y")

	elseif cCampo == "Z0W_CODIGO"

		while !LockByName("GetNextCod_Z0W", .t., .f.)
			Sleep(1000)
		end

		if Empty(cID := GetMV("VA_Z0WCOD",,""))
			cID := StrZero(1, TamSX3("Z0W_CODIGO")[1])
		endif

		cID := Soma1(cID)

		while !PutMV("VA_Z0WCOD", cID)
			Sleep(1000)
		end

		UnlockByName("GetNextCod_Z0W")

	elseif cCampo == "ORDEM"

		while !LockByName("GetNextCod_ORDEM", .t., .f.)
			Sleep(1000)
		end

		if Empty(cID := GetMV("VA_SEQORD",,"")) .or. StrZero(Year(aParRet[1]), 4) <> SubStr(cID, 1, 4)
			cID := StrZero(Year(aParRet[1]), 4)+ "-00001"

		endif

		cID := substr(cID, 1, 5) + Soma1(substr(cID, 6))

		while !PutMV("VA_SEQORD", cID)
			Sleep(1000)
		end

		UnlockByName("GetNextCod_ORDEM")

	endif

	LogCod(cCampo, cID)

	if !Empty(aArea)
		RestArea(aArea)
	endif
return cID


static function LogCod(cCampo, cNum)
	Local cArqCont := MemoRead("vapcpa13.log")

	MemoWrite("vapcpa13.log", cArqCont + DToS(Date()) + Time() + " " + cCampo + ": '" + cNum + "'" + _ENTER_)

return nil

/* ====================================================================== */
Static Function EnviaMail()

	Local cJobChv		:= 'PCP13' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
	Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
	Local cHtml 			:= ""
	Local _cQry 		:= ""
	Local cBufferVar 	:= ""
	Local nBuffer 		:= 65535

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".SQL"
	EndIf
	If Type("nHdlJOBA13") == "U"
		Private nHdlJOBA13 	:= 0
	EndIf

	cHtml := '<HTML><BODY>'
	cHtml += '<hr>'
	cHtml += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	cHtml += '<b><font face="Verdana" SIZE=3>Agropecuaria Vista Alegre LTDA</b></p>'
	cHtml += '<br>'
	cHtml += '<font face="Verdana" SIZE=3>Fazenda Baixios de Santos Inacio, S/N - Distrito Nova Patria - CEP: 19300000 - Fone/Fax (18) 3289-7266</p>'
	cHtml += '<hr>'
	cHtml += '<b><font face="Verdana" SIZE=3>Este email apresenta a listagem dos lotes com pendencia de v�nculo de Curral e v�nculo com Plano Nutricional.</b></p>'
	cHtml += '<hr>'
	cHtml += '<b><As informac�es devem ser regularizadas, pois sao utilizadas na rotina de Plano de Trato, Cadastro das Notas de Coho</b></p>'
	cHtml += '<font face="Verdana" SIZE=3>Data: ' + dToC(__DATA) + ' Hora: ' + Time() + ' - [VAPCPA13]</p>'
	cHtml += '<br>'

	_cQry := " WITH PRODUCAO AS (" +_ENTER_
	_cQry += " 	    SELECT DISTINCT Z0Y_DATA, ZV0_TIPO, ZV0_DESC, Z0Y_ORDEM, Z0Y_RECEIT, B1_DESC, CASE Z0Y_DATPRC WHEN '        ' THEN 'NAO PROCESSADO' ELSE 'PROCESSADO' END AS STATUS_PROC, ZV0_ORDEM" +_ENTER_
	_cQry += " 		  FROM " +RetSqlName('Z0Y')+ " Z0Y" +_ENTER_
	_cQry += " 		  JOIN " +RetSqlName('Z0X')+ " Z0X ON Z0X_FILIAL = Z0Y_FILIAL AND Z0X_DATA = Z0Y_DATA AND Z0X_CODIGO = Z0Y_CODEI AND Z0X.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " 		  JOIN " +RetSqlName('ZV0')+ " ZV0 ON ZV0_FILIAL = ' ' AND ZV0_CODIGO = Z0X_EQUIP AND ZV0.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " 		  JOIN " +RetSqlName('SB1')+ " SB1 ON B1_FILIAL = ' ' AND B1_COD = Z0Y_RECEIT AND SB1.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " 		 WHERE Z0Y_DATA = '" + dToS(__DATA) + "' AND Z0Y_CONFER <> ' ' " +_ENTER_
	_cQry += " 		   AND Z0Y.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " )		" +_ENTER_
	_cQry += " , TRATO AS (		" +_ENTER_
	_cQry += " 	  SELECT DISTINCT Z0W_DATA, ZV0_TIPO, ZV0_DESC, Z0W_ORDEM, Z0W_RECEIT, B1_DESC, CASE Z0W_DATPRC WHEN '        ' THEN 'NAO PROCESSADO' ELSE 'PROCESSADO' END AS STATUS_PROC, ZV0_ORDEM" +_ENTER_
	_cQry += " 		FROM " +RetSqlName('Z0W')+ " Z0W" +_ENTER_
	_cQry += "         JOIN " +RetSqlName('Z0X')+ " Z0X ON Z0X_FILIAL = Z0W_FILIAL AND Z0X_DATA = Z0W_DATA AND Z0X_CODIGO = Z0W_CODEI AND Z0X.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += "         JOIN " +RetSqlName('ZV0')+ " ZV0 ON ZV0_FILIAL = ' ' AND ZV0_CODIGO = Z0X_EQUIP AND ZV0.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += "         JOIN " +RetSqlName('SB1')+ " SB1 ON B1_FILIAL = ' ' AND B1_COD = Z0W_RECEIT AND SB1.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " 	   WHERE Z0W_DATA = '" + dToS(__DATA) + "' AND Z0W_CONFER <> ' ' " +_ENTER_
	_cQry += " 		 AND Z0W.D_E_L_E_T_ = ' ' " +_ENTER_
	_cQry += " )" +_ENTER_
	_cQry += " " +_ENTER_
	_cQry += " SELECT Z0Y_DATA, P.ZV0_TIPO, P.ZV0_DESC, P.Z0Y_ORDEM, P.Z0Y_RECEIT, P.B1_DESC, ISNULL(P.STATUS_PROC,'') STATUS_FABRICA, ISNULL(T.STATUS_PROC,'') STATUS_TRATO " +_ENTER_
	_cQry += " FROM PRODUCAO P" +_ENTER_
	_cQry += " LEFT JOIN TRATO T ON P.ZV0_DESC = T.ZV0_DESC AND P.Z0Y_ORDEM = T.Z0W_ORDEM AND P.Z0Y_RECEIT = T.Z0W_RECEIT" +_ENTER_
	_cQry += " ORDER BY P.ZV0_ORDEM, T.ZV0_ORDEM, ZV0_TIPO" +_ENTER_

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"QRYALIAS",.T.,.F.)

	If (lImpCab1 := !QRYALIAS->(Eof()) )
		cHtml += '<br>'
		cHtml += '<br>'
		cHtml += '<font face="Verdana" SIZE=1>'
		cHtml += '<table width="85%" BORDER=1>'
		cHtml += '	<tr BGCOLOR=#778899 >'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Data</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Tipo</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Descricao</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Ordem</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Receita</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Status Fabrica</b></font></td>'
		cHtml += '		<td align=center><b><font color=#F5F5F5>Status Trato</b></font></td>'
		cHtml += '	</tr>'
	EndIf

	While !QRYALIAS->(Eof())

		cHtml += '	<tr>'
		cHtml += '		<td align=left >'+dToC(sToD(QRYALIAS->Z0Y_DATA))+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->ZV0_TIPO)+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->ZV0_DESC)+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->Z0Y_ORDEM)+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->Z0Y_RECEIT)+': '+AllTrim(QRYALIAS->B1_DESC)+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->STATUS_FABRICA)+'</td>'
		cHtml += '		<td align=left >'+AllTrim(QRYALIAS->STATUS_TRATO)+'</td>'
		//cHtml += '		<td align=center >'+Transform( QRYALIAS->B8_SALDO, X3Picture('B8_SALDO') )+'</td>'
		//cHtml += '		<td align=center >'+AllTrim(QRYALIAS->PENDENCIA)+'</td>'
		cHtml += '	</tr>'

		QRYALIAS->(dbSkip())

	EndDo
	QRYALIAS->(dbCloseArea())

	cHtml += '</table>' // fim da tabela de pedidos
	cHtml += '<br>'
	cHtml += '<br>'
	cHtml += '<br>'
	cHtml += '<h4>L O G  D O  P R O C E S S A M E N T O</h4>'
	cHtml += '<br>'
	cHtml += '<font face="Verdana" SIZE=2>'


	If (nHdlJOBA13:=FT_FUse(cFile)) > -1
		// Posiciona na primeria linha
		FT_FGoTop()
		While !FT_FEOF()
			cLine  := FT_FReadLn()
			cHtml += cLine + '<br>'
			FT_FSKIP()
		EndDo
		// Fecha o Arquivo
		FT_FUSE()
	Else
		ConOut("[EnviaMail] Nao foi possivel abrir o arquivo: " + AllTrim(cFile) )
	EndIf

	cHtml += '</BODY></HTML>'

	if lImpCab1 // lEnvia

		xAssunto:= "Livio Protheus - Processamento das Batidas e Lotes"
		xAnexo  := ""
		xDe     := "protheus@vistalegre.agr.br"
		xCopia  := ""
		xEmail  := ""

		xaDados := {}
		aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

		cQuery := " SELECT X5_CHAVE, X5_DESCRI "
		cQuery += " FROM " +RetSqlName('SX5')+ " SX5 "
		cQuery += " WHERE X5_TABELA = '" +cJobSX5+ "'"
		cQuery += "   AND SUBSTRING(X5_CHAVE,1,5)  = '" +cJobChv+ "'  "
		cQuery += "   AND D_E_L_E_T_<>'*' "
		cQuery += " ORDER BY X5_CHAVE "

		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),"QRYALIAS",.T.,.F.)

		xEmail := ""
		While !QRYALIAS->(Eof())

			xEmail  += Iif(Empty(xEmail),"",", ") + AllTrim(lower( QRYALIAS->X5_DESCRI))

			QRYALIAS->(dbSkip())
		EndDo

		//xEmail := "arthur.toshio@vistaalegre.agr.br" //"miguel.bernardo@vistaalegre.agr.br"
		If !Empty(xEmail)

			U_GravaArq( ,;
				"Email enviado para: " + xEmail,;
				.T./* lConOut */,;
				  /* lAlert */ )

			MemoWrite( "C:\totvs_relatorios\VAPCPA13.html", cHtml )

			Processa({ || u_EnvMail(xEmail	,;			//_cPara
			xCopia 				,;		//_cCc
			""					,;		//_cBCC
			xAssunto			,;		//_cTitulo
			xaDados				,;		//_aAnexo
			cHtml				,;		//_cMsg
			.T.)},"Enviando e-mail...")	//_lAudit
		EndIf
		QRYALIAS->(dbCloseArea())
	Else
		ConOut('SQL nao retornou resultado.')
	endif

Return nil


/* ====================================================================== */
User Function JOBPrcLote()	// U_JOBPrcLote()

	Local cTimeIni 		:= Time()

	Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".SQL"

	If Type("cLogFile") == "U"
		Private cLogFile := ""
	EndIf

	If Type("oMainWnd") == "U"
		U_GravaArq( cFile,;
			'-> Executado via Schedule <-',;
			.T./* lConOut */,;
				  /* lAlert */ )
			U_RunFunc("U_fPrcLote()",'01','01',3)
	Else
		U_GravaArq( cFile,;
			'-> Executado via Sistema <-',;
			.T./* lConOut */,;
			.T./* lAlert */ )
		U_fPrcLote()
	EndIf

	U_GravaArq( cFile,;
		'Inicio: ' + dToC(__DATA) + '-' + cTimeINI +_ENTER_+;
		'Final : ' + Time() +_ENTER_+;
		'Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) + _ENTER_,;
		.T./* lConOut */,;
		.T./* lAlert */ )
Return nil


/* ====================================================================== */
User Function fPrcLote()
	Local aArea	   		:= GetArea()
	Local _cQry    		:= ""

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".SQL"
	EndIf

	_cQry := " SELECT X.R_E_C_N_O_ RECNO
	_cQry += " FROM	  " +RetSqlName('Z0X')+ " X
	_cQry += "   JOIN " +RetSqlName('ZV0')+ " V ON ZV0_FILIAL=' ' AND Z0X_EQUIP=ZV0_CODIGO
	_cQry += " 			  	  AND X.D_E_L_E_T_=' '
	_cQry += " 			  	  AND V.D_E_L_E_T_=' '
	_cQry += " WHERE  Z0X_FILIAL =  '" +xFilial('Z0X')+ "'
	_cQry += " 	  AND Z0X_DATA   = '" +DTOS(__DATA)+ "'
	_cQry += " 	  AND Z0X_STATUS NOT IN ('G','P')
	_cQry += " ORDER BY V.ZV0_ORDEM, Z0X_CODIGO
	// G=Gerado;A=Import.Parcial;I=Import.Total;C=Conferido;P=Processado;B=Proces.Parcial

	TCQUERY _cQry NEW ALIAS "QRYZ0X"

	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPPRC_" + DTOS(__DATA) + ".SQL", _cQry)

	aParRet := {}
	AAdd(aParRet, __DATA)

	If (Len(aParRet) = 1)
		AAdd(aParRet, "")
	EndIf

	DBSelectArea("Z0X")
	Z0X->(DBSetOrder(1))

	While !(QRYZ0X->(EOF()))
		Z0X->(DbGoTo(QRYZ0X->RECNO))
		aParRet[2] := Z0X->Z0X_CODIGO

		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
			"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
			"Funcao: fPrcLote" + _ENTER_ +;
			"Processando os dados [" + Z0X->Z0X_CODIGO + "]",;
			.T./* lConOut */,;
					/* lAlert */ )

		FWMsgRun(, {|| U_PrcBatTrt() }, "Processando", "Processando os dados [" + Z0X->Z0X_CODIGO + "]" )

		QRYZ0X->(DBSkip())
	EndDo
	QRYZ0X->(DBCloseArea())

	//EnviaMail()

	RestArea(aArea)
Return nil


/* ====================================================================== */
User Function PrcBatTrt()

	Local aArea    		:= GetArea()
	Local cQryPrc  		:= ""
	Local cQryUpd  		:= ""
	Local cQryCfr  		:= ""
	Local cCodRec  		:= ""
	Local cCodOrd  		:= ""
	Local cSequen  		:= "" //GetSXENum("Z02", "Z02_SEQUEN")
	Local nQtdTot  		:= 0
	Local aEmp     		:= {}
	Local aDadTrt  		:= {}
	Local lBrk     		:= .F.
	Local nDifBT   		:= 0
	Local nPrcDf   		:= 0
	Local nQtdTrt  		:= 0
	Local __oQry		:= nil
	Local cArmazem		:= ""

	If Type("__DATA") == "U"
		Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
	EndIf
	If Type("cFile") == "U"
		Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".SQL"
	EndIf

	Private cNumOp := ""

	If (__DATA != Z0X->Z0X_DATA)
		MsgInfo("A data do sistema nao pode ser diferente da data do arquivo.")
		RestArea(aArea)
		Return (Nil)
	EndIf

	cQryPrc := " SELECT MAX(Z02.Z02_SEQUEN) AS SEQ " + _ENTER_
	cQryPrc += " FROM " + RetSqlName("Z02") + " Z02 " + _ENTER_
	cQryPrc += " WHERE Z02.Z02_FILIAL = '" + xFilial("Z02") + "'" + _ENTER_
	cQryPrc += "   AND Z02.D_E_L_E_T_ = ' ' " + _ENTER_

	TCQUERY cQryPrc NEW ALIAS "QRYPRC"

	cSequen :=  Soma1(QRYPRC->SEQ)

	QRYPRC->(DBCloseArea())

	Begin Transaction

		DBSelectArea("Z02")
		Z02->(DBSetOrder(1))

		RecLock("Z02", .T.)
		Z02->Z02_FILIAL := xFilial("Z02")
		Z02->Z02_SEQUEN := cSequen
		Z02->Z02_ARQUIV := aParRet[2]
		Z02->Z02_DTIMP  := Z0X->Z0X_DATA
		Z02->Z02_TPARQ  := '3'
		Z02->Z02_DATA   := Z0X->Z0X_DATA
		Z02->Z02_VERSAO := Z0X->Z0X_VERSAO
		Z02->Z02_EQUIP  := Z0X->Z0X_EQUIP
		Z02->(MSUnlock())

		cQryPrc := " SELECT Z0Y.Z0Y_ORDEM AS ORDEM, Z0Y.Z0Y_RECEIT AS RECEITA, Z0Y.Z0Y_COMP AS COMP, Z0Y.Z0Y_ROTA AS ROTA, Z0X.Z0X_OPERAD AS OPERAD, SUM(Z0Y.Z0Y_QTDPRE) AS QTDPRE, SUM(CASE Z0Y.Z0Y_PESDIG WHEN 0 THEN Z0Y.Z0Y_QTDREA ELSE Z0Y.Z0Y_PESDIG END) AS QTDREA " + _ENTER_
		cQryPrc += "     , (SELECT SUM(CASE Z0Y2.Z0Y_PESDIG WHEN 0 THEN Z0Y2.Z0Y_QTDREA ELSE Z0Y2.Z0Y_PESDIG END) FROM " + RetSqlName("Z0Y") + " Z0Y2 WHERE Z0Y2.Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND Z0Y2.Z0Y_ORDEM = Z0Y.Z0Y_ORDEM AND Z0Y2.Z0Y_RECEIT = Z0Y.Z0Y_RECEIT AND Z0Y2.Z0Y_DATINI <> '' AND Z0Y2.Z0Y_DATPRC = '' AND Z0Y2.Z0Y_CONFER = 'T' AND Z0Y2.D_E_L_E_T_ = ' ' ) AS TOT " + _ENTER_
		cQryPrc += " FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_
		cQryPrc += " LEFT JOIN " + RetSqlName("Z0Y") + " Z0Y ON Z0Y.Z0Y_CODEI = Z0X.Z0X_CODIGO AND Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
		cQryPrc += " WHERE Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_
		cQryPrc += "   AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_
		cQryPrc += "   AND Z0X.Z0X_CODIGO = '" + aParRet[2] + "'" + _ENTER_
		cQryPrc += "   AND Z0X.Z0X_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
		cQryPrc += "   AND Z0Y.Z0Y_DATINI <> '' " + _ENTER_
		cQryPrc += "   AND Z0Y.Z0Y_DATPRC = '' " + _ENTER_
		cQryPrc += "   AND Z0Y.Z0Y_CONFER = 'T' " + _ENTER_

		cQryPrc += " GROUP BY Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_RECEIT, Z0Y.Z0Y_COMP, Z0Y.Z0Y_ROTA, Z0X.Z0X_OPERAD " + _ENTER_
		cQryPrc += " ORDER BY Z0Y.Z0Y_ORDEM, Z0Y.Z0Y_RECEIT, Z0Y.Z0Y_COMP, Z0Y.Z0Y_ROTA " + _ENTER_

		TCQUERY cQryPrc NEW ALIAS "QRYPRCC"

		MEMOWRITE("C:\TOTVS_RELATORIOS\EXPIMPPRCC.SQL", cQryPrc)

		DBSelectArea("Z03")
		Z03->(DBsetOrder(1))

		If (!(QRYPRCC->(EOF())))
			cCodRec := QRYPRCC->RECEITA
			cCodOrd := QRYPRCC->ORDEM
			nQtdTot := QRYPRCC->TOT
		Else
			DisarmTransaction()
			QRYPRCC->(DBCloseArea())
			Break
		EndIf

		While (!(QRYPRCC->(EOF())) .and. !lBrk)

			RecLock("Z03", .T.)
				Z03->Z03_FILIAL := xFilial("Z03")
				Z03->Z03_SEQUEN := cSequen
				Z03->Z03_BATIDA := QRYPRCC->ORDEM
				Z03->Z03_DTIMP  := Z0X->Z0X_DATA
				Z03->Z03_HRIMP  := Substr(Time(), 1, 5)
				Z03->Z03_OPERAD := QRYPRCC->OPERAD
				Z03->Z03_DIETA  := QRYPRCC->RECEITA
				Z03->Z03_RECEIT := QRYPRCC->RECEITA
				Z03->Z03_TOTPRO := QRYPRCC->TOT
				Z03->Z03_INSUMO := QRYPRCC->COMP
				Z03->Z03_QTDE   := QRYPRCC->QTDREA
			Z03->(MSUnlock())

			If ((QRYPRCC->RECEITA != cCodRec) .OR. (QRYPRCC->ORDEM != cCodOrd))

				TryException
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
					"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" + _ENTER_+;
					"Funcao: PrcBatTrt" + _ENTER_ +;
					"Processando os dados [" + cSequen + "-" + AllTrim(QRYPRCC->ORDEM) + "]",;
					.T./* lConOut */,;
						  /* lAlert */ )
					FWMsgRun(, {|| U_VAEST003(cCodRec, nQtdTot, /* "01" */, aEmp) },;
					"Processando [VAEST003]" + "[" + AllTrim(Z0X->Z0X_CODIGO) + "]" ,;
					"Processando os dados [" + cSequen + "-" + AllTrim(QRYPRCC->ORDEM) + "]" )

				CatchException Using oException
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
					"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
					"ERRO1: " +oException:ErrorStack,;
					.T./* lConOut */,;
						  /* lAlert */ )
					u_ShowException(oException)
				DisarmTransaction()
				lBrk := .T.
				EndException

				If (lBrk)
					QRYPRCC->(DBCloseArea())
					Break
				EndIf

				cQryUpd := " UPDATE " + RetSqlName("Z03") + _ENTER_
				cQryUpd += " SET Z03_NUMOP = '" + cNumOp + "'" + _ENTER_
				cQryUpd += " WHERE Z03_FILIAL = '" + xFilial("Z03") + "'" + _ENTER_
				cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
				cQryUpd += "   AND Z03_BATIDA = '" + cCodOrd + "'" + _ENTER_
				cQryUpd += "   AND Z03_RECEIT = '" + cCodRec + "'" + _ENTER_

				If (TCSqlExec(cQryUpd) < 0)
					MsgInfo(TCSqlError())
					DisarmTransaction()
					QRYPRCC->(DBCloseArea())
					Break
				EndIf

				cCodRec := QRYPRCC->RECEITA
				cCodOrd := QRYPRCC->ORDEM
				nQtdTot := QRYPRCC->TOT
				aEmp := {}

				AAdd(aEmp, {QRYPRCC->COMP,;
			 /* "01" */,;
					QRYPRCC->QTDREA})

			Else

				AAdd(aEmp, {QRYPRCC->COMP,;
			 /* "01" */,;
					QRYPRCC->QTDREA})

			EndIf

			QRYPRCC->(DBSkip())
		EndDo
		QRYPRCC->(DBCloseArea())

		TryException

		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
			"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
			"Funcao: PrcBatTrt" + _ENTER_ +;
			"Processando os dados [" + AllTrim(cCodRec) + "-" + AllTrim(cCodRec) + AllTrim(cCodOrd) + "]",;
			.T./* lConOut */,;
				  /* lAlert */ )

		FWMsgRun(, {|| U_VAEST003(cCodRec, nQtdTot, /* "01" */, aEmp) },;
			"Processando [VAEST003]" + "[" + AllTrim(Z0X->Z0X_CODIGO) + "]" ,;
			"Processando os dados [" + AllTrim(cCodRec) + "-" + AllTrim(cCodRec) + AllTrim(cCodOrd) + "]" )

		CatchException Using oException
		U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
			"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
			"ERRO2: " +oException:ErrorStack,;
			.T./* lConOut */,;
						  /* lAlert */ )
			u_ShowException(oException)
		DisarmTransaction()
		lBrk := .T.
		EndException

		If (lBrk)
			Break
		EndIf

		cQryUpd := " UPDATE " + RetSqlName("Z03") + _ENTER_
		cQryUpd += " SET Z03_NUMOP = '" + cNumOp + "'" + _ENTER_
		cQryUpd += " WHERE Z03_FILIAL = '" + xFilial("Z03") + "'" + _ENTER_
		cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
		cQryUpd += "   AND Z03_BATIDA = '" + cCodOrd + "'" + _ENTER_
		cQryUpd += "   AND Z03_RECEIT = '" + cCodRec + "'" + _ENTER_

		If (TCSqlExec(cQryUpd) < 0)
			MsgInfo(TCSqlError())
			DisarmTransaction()
			Break
		EndIf

		//Atualiza Processamento Carregamento
		cQryUpd := " UPDATE " + RetSqlName("Z0Y") + _ENTER_
		cQryUpd += " SET Z0Y_DATPRC = '" + DTOS(Date()) + "'" + _ENTER_
		cQryUpd += "   , Z0Y_HORPRC = '" + SUBSTR(TIME(), 1, 5) + "'" + _ENTER_
		cQryUpd += " WHERE Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
		cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
		cQryUpd += "   AND Z0Y_CODEI = '" + aParRet[2] + "'" + _ENTER_
		cQryUpd += "   AND Z0Y_CONFER = 'T' "
		cQryUpd += "   AND Z0Y_DATPRC = '' "

		If (TCSqlExec(cQryUpd) < 0)
			MsgInfo(TCSqlError())
			DisarmTransaction()
			Break
		EndIf

		cQryCfr := " SELECT * " + _ENTER_
		cQryCfr += " FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_
		cQryCfr += " WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
		cQryCfr += "   AND Z0Y.D_E_L_E_T_ = ' ' " + _ENTER_
		cQryCfr += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
		cQryCfr += "   AND Z0Y.Z0Y_DATPRC = '' " + _ENTER_

		TCQUERY cQryCfr NEW ALIAS "QRYCFR"

		If (QRYCFR->(EOF()))
			RecLock("Z0X", .F.)
			Z0X->Z0X_STATUS := "P"
			Z0X->(MSUnlock())
		Else
			RecLock("Z0X", .F.)
			Z0X->Z0X_STATUS := "B"
			Z0X->(MSUnlock())
		EndIf
		QRYCFR->(DBCloseArea())

	End Transaction

	If (Z0X->Z0X_OPERAC = "1" .AND. Z0X->Z0X_STATUS != "G")

		Begin Transaction

			cSequen := Soma1(cSequen)

			RecLock("Z02", .T.)
				Z02->Z02_FILIAL := xFilial("Z02")
				Z02->Z02_SEQUEN := cSequen
				Z02->Z02_ARQUIV := aParRet[2]
				Z02->Z02_DTIMP  := Z0X->Z0X_DATA
				Z02->Z02_TPARQ  := '4'
				Z02->Z02_DATA   := Z0X->Z0X_DATA
				Z02->Z02_VERSAO := Z0X->Z0X_VERSAO
				Z02->Z02_EQUIP  := Z0X->Z0X_EQUIP
			Z02->(MSUnlock())

			cQryPrc := " SELECT Z0W.Z0W_CURRAL AS CURRAL, Z0W.Z0W_LOTE AS LOTE, SUM(Z0W.Z0W_QTDPRE) AS QTDPRE, SUM(CASE Z0W.Z0W_PESDIG WHEN 0 THEN Z0W.Z0W_QTDREA ELSE Z0W.Z0W_PESDIG END) AS QTDREA, Z0W.Z0W_RECEIT AS DIETA " + _ENTER_
			cQryPrc += "      , (SELECT Z05.Z05_CABECA FROM " + RetSqlName("Z05") + " Z05 WHERE Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ = ' ' AND Z05.Z05_DATA = '" + DTOS(aParRet[1]) + "' AND Z05.Z05_CURRAL = Z0W.Z0W_CURRAL) AS CBC "  + _ENTER_
			cQryPrc += "      , (SELECT SUM(CASE Z0Y.Z0Y_PESDIG WHEN 0 THEN Z0Y.Z0Y_QTDREA ELSE Z0Y.Z0Y_PESDIG END) FROM " + RetSqlName("Z0Y") + " Z0Y WHERE Z0Y.Z0Y_FILIAL = '" + xFilial("Z0Y") + "' AND Z0Y.D_E_L_E_T_ = ' ' AND Z0Y.Z0Y_ORDEM = Z0W.Z0W_ORDEM AND Z0Y.Z0Y_RECEIT = Z0W.Z0W_RECEIT AND Z0Y.Z0Y_DATPRC <> '' AND Z0Y.Z0Y_CONFER = 'T') AS TOTBAT "  + _ENTER_
			cQryPrc += "      , (SELECT SUM(CASE Z0WA.Z0W_PESDIG WHEN 0 THEN Z0WA.Z0W_QTDREA ELSE Z0WA.Z0W_PESDIG END) FROM " + RetSqlName("Z0W") + " Z0WA WHERE Z0WA.Z0W_FILIAL = '" + xFilial("Z0W") + "' AND Z0WA.D_E_L_E_T_ = ' ' AND Z0WA.Z0W_ORDEM = Z0W.Z0W_ORDEM AND Z0WA.Z0W_RECEIT = Z0W.Z0W_RECEIT AND Z0WA.Z0W_DATINI <> '' AND Z0WA.Z0W_DATPRC = '' AND Z0WA.Z0W_CONFER = 'T' AND Z0WA.Z0W_LOTE IN (SELECT DISTINCT SB8.B8_LOTECTL FROM " + RetSqlName("SB8") + " SB8 WHERE SB8.B8_FILIAL = " + xFilial("SB8") + " AND SB8.B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' )) AS TOTTRT "  + _ENTER_
			cQryPrc += " FROM " + RetSqlName("Z0X") + " Z0X " + _ENTER_
			cQryPrc += " LEFT JOIN " + RetSqlName("Z0W") + " Z0W ON Z0W.Z0W_CODEI = Z0X.Z0X_CODIGO AND Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "' AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
			cQryPrc += " WHERE Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_
			cQryPrc += "   AND Z0X.D_E_L_E_T_ = ' ' " + _ENTER_
			cQryPrc += "   AND Z0X.Z0X_CODIGO = '" + aParRet[2] + "'" + _ENTER_
			cQryPrc += "   AND Z0X.Z0X_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_
			cQryPrc += "   AND Z0W.Z0W_DATINI <> '' " + _ENTER_
			cQryPrc += "   AND Z0W.Z0W_DATPRC = '' " + _ENTER_
			cQryPrc += "   AND Z0W.Z0W_CONFER = 'T' " + _ENTER_
			cQryPrc += "   AND Z0W.Z0W_LOTE IN (SELECT SB8.B8_LOTECTL FROM " + RetSqlName("SB8") + " SB8 WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' ) "
			cQryPrc += " GROUP BY Z0W.Z0W_CURRAL, Z0W.Z0W_LOTE, Z0W.Z0W_RECEIT, Z0W.Z0W_ORDEM " + _ENTER_
			cQryPrc += " ORDER BY Z0W.Z0W_CURRAL, Z0W.Z0W_LOTE, Z0W.Z0W_RECEIT " + _ENTER_

			TCQUERY cQryPrc NEW ALIAS "QRYPRCT"

			MEMOWRITE("C:\TOTVS_RELATORIOS\EXPIMPPRCT.SQL", cQryPrc)

			DBSelectArea("Z04")
			Z04->(DBsetOrder(1))
			
			cQryPrc := " WITH LOTE AS ( " + CRLF
			cQryPrc += "			select DISTINCT B8_LOCAL, SUM(B8_SALDO) SALDO  " + CRLF
			cQryPrc += "			from " + RetSqlName("SB8") + " SB8  " + CRLF
			cQryPrc += "			WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
			cQryPrc += "			AND B8_LOTECTL = ?  " + CRLF
			cQryPrc += "			AND D_E_L_E_T_ = ' '  " + CRLF
			cQryPrc += "			GROUP BY B8_LOCAL " + CRLF
			cQryPrc += "			) " + CRLF
			cQryPrc += "			SELECT TOP(1) B8_LOCAL   " + CRLF
			cQryPrc += "				FROM LOTE  " + CRLF
			cQryPrc += "				 ORDER BY SALDO " + CRLF

			__oQry := FwExecStatement():New(cQryPrc)

			While (!(QRYPRCT->(EOF())))

				nDifBT := QRYPRCT->TOTBAT - QRYPRCT->TOTTRT

				If (nDifBT = 0 )
					nQtdTrt := QRYPRCT->QTDREA
				ElseIf (nDifBT > 0 )

					nPrcDf := ((100 * QRYPRCT->QTDREA)/QRYPRCT->TOTTRT)
					nQTdTrt := QRYPRCT->QTDREA + ((nPrcDf * nDifBT)/100)

				ElseIf (nDifBT < 0 )

					nDifBT := nDifBT * -1

					nPrcDf := ((100 * QRYPRCT->QTDREA)/QRYPRCT->TOTTRT)
					nQTdTrt := QRYPRCT->QTDREA - ((nPrcDf * nDifBT)/100)

				EndIf

				RecLock("Z04", .T.)
					Z04->Z04_FILIAL := xFilial("Z04")
					Z04->Z04_SEQUEN := cSequen
					Z04->Z04_CURRAL := QRYPRCT->CURRAL
					Z04->Z04_DIETA  := QRYPRCT->DIETA
					Z04->Z04_LOTE   := QRYPRCT->LOTE
					Z04->Z04_DTIMP  := Z0X->Z0X_DATA
					Z04->Z04_HRIMP  := Substr(Time(), 1, 5)
					Z04->Z04_NROCAB := QRYPRCT->CBC
					Z04->Z04_TOTREA := QRYPRCT->QTDPRE
					Z04->Z04_TOTAPR := nQTdTrt
				Z04->(MSUnlock())

				If Empty( cArmzRac := Posicione("SB1", 1, xFilial("SB1") + QRYPRCT->DIETA, "B1_LOCPAD") )
					cArmzRac := StrZero(1, TamSX3("B1_LOCPAD")[1])
				EndIf

				__oQry:SetString(1,QRYPRCT->LOTE)
				cArmazem := __oQry:ExecScalar("B8_LOCAL")

				AAdd(aDadTrt, {Z0X->Z0X_DATA, Substr(Time(), 1, 5), QRYPRCT->CURRAL, QRYPRCT->LOTE,;
					QRYPRCT->CBC, QRYPRCT->DIETA, STR(QRYPRCT->QTDPRE), STR(nQTdTrt),;
					cArmazem, cArmzRac})

				QRYPRCT->(DBSkip())
			EndDo
			QRYPRCT->(DBCloseArea())
			
			__oQry:Destroy()
			__oQry := Nil

			TryException

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
				"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
				"Funcao: PrcBatTrt" + _ENTER_ +;
				"Processando os dados [" + cSequen + "-" + AllTrim(Z0X->Z0X_CODIGO) + "]",;
				.T./* lConOut */,;
						/* lAlert */ )

			FWMsgRun(, {|| &('StaticCall(VAEST020, PROCZ02, aDadTrt, cSequen)') },;
				"Processando [VAEST020]" + "[" + AllTrim(Z0X->Z0X_CODIGO) + "]" ,;
				"Processando os dados [" + cSequen + "-" + AllTrim(Z0X->Z0X_CODIGO) + "]" )
			//	U_ProcZ02(aDadTrt, Z02->Z02_SEQUEN)

			CatchException Using oException
			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
				"[" + AllTrim(Z0X->Z0X_CODIGO) + "]" +_ENTER_+;
				"ERRO3: " +oException:ErrorStack,;
				.T./* lConOut */,;
						  /* lAlert */ )
				u_ShowException(oException)
			DisarmTransaction()
			lBrk := .T.
			EndException

			If (lBrk)
				Break
			EndIf

			//Atualiza Processamento Trato
			cQryUpd := " UPDATE " + RetSqlName("Z0W") + _ENTER_
			cQryUpd += " SET Z0W_DATPRC = '" + DTOS(Date()) + "'" + _ENTER_
			cQryUpd += "   , Z0W_HORPRC = '" + SUBSTR(TIME(), 1, 5) + "'" + _ENTER_
			cQryUpd += " WHERE Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
			cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
			cQryUpd += "   AND Z0W_CODEI = '" + aParRet[2] + "'" + _ENTER_
			cQryUpd += "   AND Z0W_CONFER = 'T' "
			cQryUpd += "   AND Z0W_DATPRC = '' "

			If (TCSqlExec(cQryUpd) < 0)
				DisarmTransaction()
				Break
				//MsgInfo(TCSqlError())
			EndIf

			cQryCfr := " SELECT * " + _ENTER_
			cQryCfr += " FROM " + RetSqlName("Z0W") + " Z0W " + _ENTER_
			cQryCfr += " WHERE Z0W.Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
			cQryCfr += "   AND Z0W.D_E_L_E_T_ = ' ' " + _ENTER_
			cQryCfr += "   AND Z0W.Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
			cQryCfr += "   AND Z0W.Z0W_DATPRC = ' ' " + _ENTER_

			TCQUERY cQryCfr NEW ALIAS "QRYCFR"

			If (QRYCFR->(EOF()))
				RecLock("Z0X", .F.)
				Z0X->Z0X_STATUS := "P"
				Z0X->(MSUnlock())
			Else
				RecLock("Z0X", .F.)
				Z0X->Z0X_STATUS := "B"
				Z0X->(MSUnlock())
			EndIf
			QRYCFR->(DBCloseArea())

		End Transaction
	EndIf

/*If (!lBrk)
	MsgInfo("Processamento concluido com sucesso!")
	
EndIf*/

RestArea(aArea)

Return (Nil)


/* ====================================================================== */
User Function GravaArq( cFile, cMsg, lConOut, lAlert )
Local nHandle := -1

Default cFile	:= ""
Default lConOut := .F.
Default lAlert	:= .F.

	If !Empty(cFile)
		// If (nHandle:=FT_FUse(cFile)) == -1
		If (nHandle:=fOpen(cFile, 2)) == -1
			if (nHandle:=FCreate( cFile )) == -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
				// Return nil
			EndIf		
		EndIf
		If nHandle > 0
			FSeek(nHandle, 0, FS_END) // FS_SET posicionar no inicio
			FWrite(nHandle, cMsg + _ENTER_ )
		Else
			conout("Erro ao Abrir arquivo: " + AllTrim(cFile) )
		EndIf
	EndIf
	
	If lConOut
		ConOut(cMsg)
	EndIf
	If lAlert
		Alert( cMsg )
	EndIf
	
	If nHandle > 0
		FClose(nHandle)
	EndIf
	
Return nil


/* ****************************************************************************************************** */
Static Function fMJValid(sData)
Local aArea 	:= GetArea()
Local cHtml		:= ""
Local lRet		:= .T.

Local cQry := " WITH " +CRLF+;
              " 	TRATO AS ( " +CRLF+;
              " 		SELECT  Z0Y_FILIAL, " +CRLF+;
              " 				Z0Y_COMP,  " +CRLF+;
              " 				Z0Y_DATA, " +CRLF+;
              " 				B1_DESC, " +CRLF+;
              " 				B1_LOCPAD, " +CRLF+;
              " 				Z0Y_DATPRC, " +CRLF+;
              " 				COUNT(Z0Y_COMP) QTD, " +CRLF+;
              " 				SUM(CASE  " +CRLF+;
              " 					WHEN Z0Y_PESDIG=0  " +CRLF+;
              " 						THEN Z0Y_QTDREA " +CRLF+;
              " 						ELSE Z0Y_PESDIG " +CRLF+;
              " 				END) PESO " +CRLF+;
              " 		FROM	" +RetSqlName('Z0Y')+ " Y " +CRLF+;
              " 		JOIN	" +RetSqlName('SB1')+ " C ON C.B1_FILIAL=' ' AND Z0Y_COMP=C.B1_COD AND Y.D_E_L_E_T_=' ' AND C.D_E_L_E_T_=' ' " +CRLF+;
              " 		WHERE	Z0Y_FILIAL	= '"+FwxFilial("Z0Y")+"'  " +CRLF+;
              " 			AND Z0Y_DATA	= '" + sData + "'" +CRLF+;
              "" +CRLF+;
              " 			-- AND Z0Y_COMP	= '020170' " +CRLF+;
              " 			-- AND Z0Y_ORDEM= '2019-03513' " +CRLF+;
              " 			AND Z0Y_CONFER	= 'T' " +CRLF+;
              " 			AND Z0Y_DATPRC = ' ' " +CRLF+;
              " 		GROUP BY Z0Y_FILIAL, " +CRLF+;
              " 				 Z0Y_COMP, B1_DESC, B1_LOCPAD, Z0Y_DATPRC, Z0Y_DATA " +CRLF+;
              " 				 --order by Z0Y_COMP " +CRLF+;
              " 	),  " +CRLF+;
              "" +CRLF+;
              " 	SALDO_SB2 AS ( " +CRLF+;
              " 		SELECT Z0Y_COMP,  " +CRLF+;
              " 			   B1_DESC, " +CRLF+;
              " 			   PESO, " +CRLF+;
              " 			   SUM(B2_QATU) SALDOSB2 " +CRLF+;
              " 		FROM TRATO T " +CRLF+;
              " 		JOIN " + RetSqlName('SB2') + " B ON B2_FILIAL=Z0Y_FILIAL AND  " +CRLF+;
              " 							B2_COD=Z0Y_COMP AND " +CRLF+;
              " 							B2_LOCAL=B1_LOCPAD AND " +CRLF+;
              " 							B.D_E_L_E_T_=' '  " +CRLF+;
              " 		GROUP BY Z0Y_FILIAL, " +CRLF+;
              " 				 Z0Y_COMP, " +CRLF+;
              " 				 B1_DESC, " +CRLF+;
              " 				 PESO,  " +CRLF+;
              " 				 T.Z0Y_DATA " +CRLF+;
              " 	), " +CRLF+;
              "" +CRLF+;
              " 	A_PRODUZIR AS ( " +CRLF+;
              " 		SELECT	Z0Y_RECEIT, " +CRLF+;
              " 				SUM(CASE  " +CRLF+;
              " 					WHEN Z0Y_PESDIG=0  " +CRLF+;
              " 						THEN Z0Y_QTDREA " +CRLF+;
              " 						ELSE Z0Y_PESDIG " +CRLF+;
              " 				END) APRODUZIR " +CRLF+;
              " 		FROM	" +RetSqlName('Z0Y')+ " Z0Y " +CRLF+;
              " 		   JOIN SALDO_SB2 X ON X.Z0Y_COMP=Z0Y_RECEIT  " +CRLF+;
              " 		   AND Z0Y_DATA	= '" + sData + "'" +CRLF+;
              " 		   AND Z0Y_DATPRC=' ' " +CRLF+;
              " 		   AND Z0Y.D_E_L_E_T_=' ' " +CRLF+;
              " 		GROUP BY Z0Y_RECEIT " +CRLF+;
              " 	) " +CRLF+;
              "" +CRLF+;
              " 	SELECT B2.Z0Y_COMP, " +CRLF+;
              " 			B2.B1_DESC, " +CRLF+;
              " 			B2.PESO,  " +CRLF+;
              " 			B2.SALDOSB2 + ISNULL(PRD.APRODUZIR,0) SALDO " +CRLF+;
              " 	FROM SALDO_SB2  B2 " +CRLF+;
              " 	LEFT JOIN A_PRODUZIR PRD ON B2.Z0Y_COMP=PRD.Z0Y_RECEIT " +CRLF+;
              " 	WHERE PESO > SALDOSB2+ISNULL(PRD.APRODUZIR,0) ";

MEMOWRITE("C:\TOTVS_RELATORIOS\SQL_Valid_Conferir.sql", cQry)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "ALIASTMP", .f., .f.)

if !(lRet := ALIASTMP->(Eof()))

	cHtml := ' <!DOCTYPE html>
    cHtml += ' <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    cHtml += ' <head>
    cHtml += '     <meta charset="utf-8" />
    cHtml += '     <title></title>
    cHtml += '     <style>
    cHtml += '         body {
    cHtml += '             background-color: #ebebeb;
    cHtml += '             text-align: center;
    cHtml += '             color: black;
    cHtml += '             font-family: Arial, Helvetica, sans-serif;
    cHtml += '         }
    cHtml += '     </style>
    cHtml += ' </head>
    cHtml += ' <body>
    cHtml += '     <h3>Saldo(s) Insuficiente(s)</h3>
    cHtml += '     <table border="1" style="border-collapse: collapse; width: 100%; text-align: center;">
    cHtml += '         <tbody>
    cHtml += '             <tr>
    cHtml += '                 <td><strong style="color: red;">Componentes</strong></td>
    cHtml += '                 <td><strong style="color: red;">Kg Necess�rio</strong></td>
    cHtml += '                 <td><strong style="color: red;">Kg Dispon�vel</strong></td>
    cHtml += '                 <td><strong style="color: red;">Diferenca</strong></td>
    cHtml += '             </tr>

	While !ALIASTMP->(Eof())

		cHtml += '         <tr>
		cHtml += '             <td>' + AllTrim(ALIASTMP->Z0Y_COMP) +': ' + AllTrim(ALIASTMP->B1_DESC) + '</td>
		cHtml += '             <td style="text-align: right;">' + Transform( ALIASTMP->PESO , X3Picture('B8_SALDO') ) + '</td>
		cHtml += '             <td style="text-align: right;">' + Transform( ALIASTMP->SALDO, X3Picture('B8_SALDO') ) + '</td>
		cHtml += '             <td style="text-align: right;">' + Transform( ALIASTMP->SALDO - ALIASTMP->PESO, X3Picture('B8_SALDO') ) + '</td>
		cHtml += '         </tr>

		ALIASTMP->(DbSkip())
	EndDo

    cHtml += ' 	        </tbody>
    cHtml += '     </table>
    cHtml += ' </body>

	// Alert('Operacao: ' + cValToChar(n_Oper))

	MsgInfo(cHtml)

EndIf
ALIASTMP->(DbCloseArea())
RestArea(aArea)
Return lRet


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2019                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Funcao atualizada com Pergunte para selecionar se arquivo JSON ou    |
 |            CSV;                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function ImpBatTrt(cFile)

	If Upper(SubS(AllTrim(cFile), -3)) == "CSV"
		U_ImpCSV(cFile)
	Else
		U_ImpJSon()
	EndIf

Return nil


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2019                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Funcao que realiza a importacao do arquivo CSV, enviado pelo         |
 |            sistema do Tiao;                                           		   |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function ImpCSV(cFile)
Local aArea 		:= GetArea()
Local nHandle 		:= FT_FUse(cFile) // fOpen(cFile)
Local cJsnImp  		:= ""
Local nCntTrt		:= 0
Local cOrdem		:= ""
Local cHoraI 		:= ""
Local aAux			:= {}
Local aHeaderCSV  	:= {}
Local aDados		:= {}
Local nI			:= 0
Local nPOrdemProd   := 0
Local nPNumCarreg	:= 0
Local nPOrdIngred   := 0
Local nPKGFornec    := 0
Local nPKGBalanc    := 0
Local nPKGRecal     := 0
Local nPKGMetaReca	:= 0
Local nPKGInic      := 0
Local nPKGFim       := 0
Local nPData    	:= 0
Local nCarreg       := 0
Local nPNumTrt		:= 0
Local nPCurral		:= 0
Local obj     		:= nil, cAliasQry := "", lRet := .T.
Local lErro			:= .F.
Local aCODEI		:= {}
Local _cCond		:= ""

	If nHandle <= 0 // > -1
		MsgInfo("Nao foi possivel abrir o arquivo '" + MV_PAR01 + "', verifique e tente novamente.")
	
		RestArea(aArea)
		lErro := .T.
		Return nil
	EndIf

	FT_FGoTop() // Posiciona na primeria linha
	If !FT_FEOF()
		If !Empty(cLine:=FT_FReadLn())

			// .and. At('NUM_TRATO',UPPER(cLine))==0 .and. At('ORDEM_PRODUCAO',UPPER(cLine))==0
			aHeaderCSV  := StrToKArr(cLine,';')
			
			FT_FSKIP()
		EndIf
	EndIf
	While !FT_FEOF()
		If !Empty(cLine:=FT_FReadLn())
			aAux := StrToKArr(cLine,';')
			aAdd( aDados	   , {} )
			For nI:=1 to Len(aAux)
				aAdd( aTail(aDados), aAux[nI] )
			Next nI
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE() // Fecha o Arquivo

	Begin Transaction	
		If ( nPOperacao  := aScan(aHeaderCSV, { |x| Upper(x) == 'OPERACAO'}) ) == 0
			MsgStop("A Coluna: [OPERACAO] nao foi localizada no arquivo.", "Atencao")
		EndIf
		If ( nPOrdemProd := aScan(aHeaderCSV, { |x| Upper(x) == 'ORD_PRODUCAO'}) ) == 0
			MsgStop("A Coluna: [ORD_PRODUCAO] nao foi localizada no arquivo.", "Atencao")
		EndIf
		If ( nPData		:= aScan(aHeaderCSV, { |x| Upper(x) == 'DATA'}) ) == 0
			MsgStop("A Coluna: [DATA] nao foi localizada no arquivo.", "Atencao")
		EndIf
		If ( nPHoraI		:= aScan(aHeaderCSV, { |x| Upper(x) == 'HORA'}) ) == 0
			MsgStop("A Coluna: [HORA] nao foi localizada no arquivo.", "Atencao")
		EndIf
		If ( nPCodDieta  := aScan(aHeaderCSV, { |x| Upper(x) == 'COD_DIETA'}) ) == 0
			MsgStop("A Coluna: [COD_DIETA] nao foi localizada no arquivo.", "Atencao")
		EndIf
		If ( nPVagao     := aScan(aHeaderCSV, { |x| Upper(x) == 'VAGAO'}) ) == 0
			MsgStop("A Coluna: [VAGAO] nao foi localizada no arquivo.", "Atencao")
		EndIf
		
		If aDados[1, nPOperacao] == "C" // Carregamento

			If ( nPHoraF     := aScan(aHeaderCSV, { |x|Upper(x)=='HORA_CARREG'   }) ) == 0
				MsgStop( "A Coluna [HORA_CARREG] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPNumCarreg := aScan(aHeaderCSV, { |x|Upper(x)=='NUM_CARREG'    }) ) == 0
				MsgStop( "A Coluna [NUM_CARREG] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPCodIngred := aScan(aHeaderCSV, { |x|Upper(x)=='COD_INGRED'    }) ) == 0
				MsgStop( "A Coluna [COD_INGRED] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPOrdIngred := aScan(aHeaderCSV, { |x|Upper(x)=='ORD_INGRED'    }) ) == 0
				MsgStop( "A Coluna [ORD_INGRED] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPKGFornec  := aScan(aHeaderCSV, { |x|Upper(x)=='KG_CARREG'     }) ) == 0
				MsgStop( "A Coluna [KG_CARREG] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPKGBalanc  := aScan(aHeaderCSV, { |x|Upper(x)=='KG_BALANCA'    }) ) == 0
				MsgStop( "A Coluna [KG_BALANCA] nao foi localizada no arquivo.", "Atencao")
			EndIf
			If ( nPKGRecal   := aScan(aHeaderCSV, { |x|Upper(x)=='KG_PREV_RECAL' }) ) == 0
				MsgStop( "A Coluna [KG_PREV_RECAL] nao foi localizada no arquivo.", "Atencao")
			EndIf
			
			// DBSele1ctArea("Z0Y")
			// Z0Y->(DBSetOrder(2)) // Z0Y_FILIAL+Z0Y_ORDEM+Z0Y_TRATO

			cOrdem := ""
			nCarreg := ""
			// ORDENACAO
			aSort( aDados ,,, {|x,y| x[nPOperacao]+x[nPOrdemProd]+x[nPNumCarreg]+StrZero(val(x[nPOrdIngred]),2) < y[nPOperacao]+y[nPOrdemProd]+y[nPNumCarreg]+StrZero(val(y[nPOrdIngred]),2) } )
			For nI := 1 to Len(aDados)
			
				If aDados[nI, nPOperacao] <> "C" // Carregamento
					lErro := .T.

					MsgInfo("Nao foi identificado o tipo de exportacao." +_ENTER_+;
							"Verifique o arquivo importado." +_ENTER_+;
							"Esta operacao ser� cancelada...")
					DisarmTransaction()
					Break
				EndIf
				If (cOrdem == aDados[nI, nPOrdemProd] .and. nCarreg <> aDados[nI, nPNumCarreg] )
				   nCarreg := aDados[nI, nPNumCarreg]
				   cHoraI := aDados[nI, nPHoraI]
				ElseIf (cOrdem <> aDados[nI, nPOrdemProd] .and. nCarreg <> aDados[nI, nPNumCarreg] )
					nCarreg := aDados[nI, nPNumCarreg]
					cOrdem   := aDados[nI, nPOrdemProd]
					cHoraI := aDados[nI, nPHoraI]
					// nCntTrt += 1
				EndIf

	_cQry := " UPDATE " +RetSqlName('Z0Y')+ " " + _ENTER_
	_cQry += " 	SET  Z0Y_QTDREA =  " + StrTran(aDados[nI, nPKGFornec],",",".") + "" + _ENTER_

	_cQry += " 	   , Z0Y_DIFPES = " + StrTran(cValToChar(abs(Val(aDados[nI, nPKGRecal]) - Val(aDados[nI, nPKGFornec]) )),",",".") + _ENTER_
	//_cQry += " 	   , Z0Y_DIFPES = " +cValToChar(aDados[nI, nPKGRecal])+ "-" + cValToChar(aDados[nI, nPKGFornec]) + " " + _ENTER_
	//_cQry += " 	   , Z0Y_DIFPES = ABS(Z0Y_QTDPRE-" + cValToChar(aDados[nI, nPKGFornec]) + ") " + _ENTER_
	If nPKGBalanc > 0
		_cQry += " 	   , Z0Y_KGINBA =  " + StrTran(aDados[nI, nPKGBalanc],",",".") + "" + _ENTER_
	EndIf
	If nPKGRecal > 0
		_cQry += " 	   , Z0Y_KGRECA =  " + StrTran(aDados[nI, nPKGRecal],",",".") + "" + _ENTER_
	EndIf

	_cQry += " 	   , Z0Y_DATINI = '" + DtoS(cToD(aDados[nI, nPData]))+ "'" + _ENTER_
	_cQry += " 	   , Z0Y_HORINI = '" + cHoraI+ "'" + _ENTER_

	_cQry += " 	   , Z0Y_DATFIN = '" + DtoS(cToD(aDados[nI, nPData]))+ "'" + _ENTER_
	_cQry += " 	   , Z0Y_HORFIN = '" + (cHoraI:=aDados[nI, nPHoraF])+ "'" + _ENTER_

	// MB : 09.03.2021
	aDados[nI, nPVagao] := Posicione("ZV0", 2, xFilial("ZV0") + aDados[nI, nPVagao], "ZV0_CODIGO")
	_cQry += " 	   , Z0Y_EQUIP = '"  + aDados[nI, nPVagao] + "'" + _ENTER_

	_cCond := " WHERE Z0Y_FILIAL = '" + xFilial('Z0Y') + "'" + _ENTER_ +;
		"   AND lTrim(Z0Y_TRATO)  = '" + "1" /* AllTrim(aDados[nI, nPNumCarreg]) */ + "'" + _ENTER_ +;
		"   AND Z0Y_ORDEM  = '" + aDados[nI, nPOrdemProd] + "'" + _ENTER_ +;
		"   AND Z0Y_COMP   = '" + aDados[nI, nPCodIngred] + "'" + _ENTER_ +;
		"   AND Z0Y_RECEIT = '" + aDados[nI, nPCodDieta] + "'" + _ENTER_ +;
		"   AND Z0Y_SEQ = '" + aDados[nI, nPOrdIngred] + "'" + _ENTER_ +;
		"   AND D_E_L_E_T_ = ' ' "
	_cQry += _cCond
	If (TCSqlExec(_cQry) < 0)
		lErro := .T.
		MsgInfo(TCSqlError())
		DisarmTransaction()
		Break
	EndIf

	// GUARDAR EM VETOR O CODEI
	_cQry := "SELECT DISTINCT Z0Y_CODEI " + _ENTER_ + "FROM " +RetSqlName('Z0Y')+ " " + _ENTER_
	_cQry += _cCond
	DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "ALIASTMP", .F., .F.)
	While !ALIASTMP->(Eof())
		If (aScan( aCODEI, {|x| x == ALIASTMP->Z0Y_CODEI}) < 1)
			aAdd( aCODEI, ALIASTMP->Z0Y_CODEI )
		EndIf
		ALIASTMP->(DbSkip())
	EndDo
	ALIASTMP->(DBCloseArea())

Next nI

ElseIf aDados[1, nPOperacao] == "F" // Fornecimento / Trato

	nCarreg :=""

	If ( nPNumTrt	:= aScan( aHeaderCSV, { |x| Upper(x) == 'NUM_FORNEC_CURRAL' }) ) == 0
		MsgStop("A coluna [NUM_FORNEC_CURRAL] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPLote      := aScan( aHeaderCSV, { |x| Upper(x) == 'NUM_LOTE'		    }) ) == 0
		MsgStop("A coluna [NUM_LOTE] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPCurral    := aScan( aHeaderCSV, { |x| Upper(x) == 'CURRAL'   		}) ) == 0
		MsgStop("A coluna [CURRAL] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPKGFornec  := aScan( aHeaderCSV, { |x| Upper(x) == 'KG_FORNEC'		}) ) == 0
		MsgStop("A coluna [KG_FORNEC] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPNumTrato  := aScan( aHeaderCSV, { |x| Upper(x) == 'NUM_FORNEC'        }) ) == 0
		MsgStop("A coluna [NUM_FORNEC] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPKGMetaReca:= aScan( aHeaderCSV, { |x| Upper(x) == 'KG_META_PREV_RECAL'}) ) == 0
		MsgStop("A coluna [KG_META_PREV_RECAL] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPKGInic 	:= aScan( aHeaderCSV, { |x| Upper(x) == 'KG_VAGAO_I'	    }) ) == 0
		MsgStop("A coluna [KG_VAGAO_I] nao foi localizada no arquivo.", "Atencao")
	EndIf
	If ( nPKGFim     := aScan( aHeaderCSV, { |x| Upper(x) == 'KG_VAGAO_F'	    }) ) == 0
		MsgStop("A coluna [KG_VAGAO_F] nao foi localizada no arquivo.", "Atencao")
	EndIf


	// DBSelectArea("Z0W")
	// Z0W->(DBSetOrder(1))

	cOrdem := ""
	// ORDENACAO
	aSort( aDados ,,, {|x,y| x[nPOperacao]+x[nPOrdemProd]+x[nPNumTrt]+x[nPCurral] < y[nPOperacao]+y[nPOrdemProd]+y[nPNumTrt]+y[nPCurral] } )
	_cCurral := ""
	For nI := 1 to Len(aDados)

		If aDados[nI, nPOperacao] <> "F" // Fornecimento / Trato
			lErro := .T.
			MsgInfo("Nao foi identificado o tipo de exportacao." +_ENTER_+;
				"Verifique o arquivo importado." +_ENTER_+;
				"Esta operacao ser� cancelada...")
			DisarmTransaction()
			Break
		EndIf

		// validar se todos os campos estao preenchidos
		If Len(aDados[1]) > Len(aDados[nI])

			MsgInfo('Erro na linha: ' + cValToChar(nI) + CRLF +;
				'Total Colunas: ' + cValToChar(Len(aDados[1])) + CRLF +;
				'Total Colunas na linha: ' + cValToChar(Len(aDados[nI])) + CRLF +;
				'</br>' + CRLF+;
				'Hora: ' + aDados[nI, nPHoraI] + CRLF+;
				'Ordem Producao: ' + aDados[nI, nPOrdemProd] + CRLF+;
				'Num Fornec Curral: ' + aDados[nI, nPNumTrt] + CRLF+;
				'Curral: ' + aDados[nI, nPCurral] + CRLF+;
				'Lote: ' + aDados[nI, nPLote] )
			Loop
		EndIf
		If (cOrdem == aDados[nI, nPOrdemProd] .and. nCarreg <> aDados[nI, nPNumTrato] )
			cOrdem  := aDados[nI, nPOrdemProd]
			cHoraI	:= aDados[nI, nPHoraI]
			nCarreg := aDados[nI, nPNumTrato]

		ElseIf (cOrdem <> aDados[nI, nPOrdemProd])
			cOrdem  := aDados[nI, nPOrdemProd]
			cHoraI	:= aDados[nI, nPHoraI]
			nCntTrt += 1
		EndIf

		_cQry  := " SELECT * " + _ENTER_ + " FROM " +RetSqlName('Z0W')+ " " + _ENTER_
		_cCond := " WHERE  Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_ +;
			"    AND Z0W_DATA   = '" + dToS( CToD( aDados[nI, nPData] ) ) + "'" + _ENTER_ +;
			"    AND Z0W_ORDEM  = '" + aDados[nI, nPOrdemProd] + "'" + _ENTER_ +;
			"    AND Z0W_TRATO  = '" + aDados[nI, nPNumTrt] + "'" + _ENTER_ +;
			"    AND Z0W_LOTE   = '" + aDados[nI, nPLote] + "'" + _ENTER_ +;
			"    AND Z0W_CURRAL = '" + aDados[nI, nPCurral] + "'" + _ENTER_ +;
			"    AND Z0W_RECEIT = '" + aDados[nI, nPCodDieta] + "'" + _ENTER_ +;
			"    AND D_E_L_E_T_ = ' ' "
		_cQry += _cCond
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "ALIASTMP", .f., .f.)
		if !ALIASTMP->(Eof())

			_cQry := " UPDATE " +RetSqlName('Z0W')+ " " + _ENTER_
			_cQry += "    SET Z0W_QTDREA = " + StrTran(aDados[nI, nPKGFornec],",",".") + _ENTER_
			_cQry += " 	    , Z0W_DIFPES = " + StrTran(cValToChar(abs(Val(aDados[nI, nPKGMetaReca]) - Val(aDados[nI, nPKGFornec]))),",",".") + _ENTER_

			If nPKGInic > 0 .and. nPKGFim > 0
				_cQry += "  , Z0W_KGINIC = " + StrTran(aDados[nI, nPKGInic],",",".") + _ENTER_
				_cQry += "  , Z0W_KGFIM  = " + StrTran(aDados[nI, nPKGFim] ,",",".") + _ENTER_
			Endif
			If nPKGMetaReca > 0
				_cQry += "  , Z0W_KGRECA = " + StrTran(aDados[nI, nPKGMetaReca],",",".") + _ENTER_
			EndIf

			_cQry += " 	    , Z0W_DATINI = '" + DtoS(cToD(aDados[nI, nPData]))+ "'" + _ENTER_
			_cQry += " 	    , Z0W_HORINI = '" + cHoraI+ "'" + _ENTER_

			_cQry += " 	    , Z0W_DATFIN = '" + DtoS(cToD(aDados[nI, nPData]))+ "'" + _ENTER_
			_cQry += " 	    , Z0W_HORFIN = '" + (cHoraI:=aDados[If(nI==(Len(aDados)),nI,nI+1), nPHoraI])+ "'" + _ENTER_

			// MB : 09.03.2021
					/* If nPVagao>0
						aDados[nI, nPVagao] := Posicione("ZV0", 2, xFilial("ZV0") + aDados[nI, nPVagao], "ZV0_CODIGO")
						_cQry += " 	    , Z0W_EQUIP  = '" + aDados[nI, nPVagao] + "'" + _ENTER_
					EndIf */
					_cQry += _cCond

					If ( TCSqlExec(_cQry) < 0 )
						lErro := .T.
						MsgInfo(TCSqlError())
						DisarmTransaction()
						Break
					EndIf
					// Alert("Retorno: " + cValToChar(nRet))

				Else
					If nPKGFornec > 0
						impZ0W(aDados, nI, nPCurral, @_cCurral, nPCodDieta, nPOrdemProd, nPNumTrt, nPKGInic, nPKGFim, nPKGMetaReca,;
							nPKGFornec, nPData, nPHoraI, @cHoraI, nPVagao)
					EndIf
				EndIf
				ALIASTMP->(DbCloseArea())

				// GUARDAR EM VETOR O CODEI
				_cQry := "SELECT DISTINCT Z0W_CODEI " + _ENTER_ + "FROM " +RetSqlName('Z0W')+ " " + _ENTER_
				_cQry += _cCond
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "ALIASTMP", .F., .F.)
				While !ALIASTMP->(Eof())
					If (aScan( aCODEI, {|x| x == ALIASTMP->Z0W_CODEI}) < 1)
						aAdd( aCODEI, ALIASTMP->Z0W_CODEI )
					EndIf
					ALIASTMP->(DbSkip())
				EndDo
				ALIASTMP->(DBCloseArea())
				
			Next nI

		Else
			lErro := .T.
			MsgInfo("Nao foi identificado o tipo de exportacao." +_ENTER_+;
				"Verifique o arquivo importado." +_ENTER_+;
				"Esta operacao ser� cancelada...")
			DisarmTransaction()
			Break
		EndIf

		If Len(aCODEI) > 0
			cSepJsn := ""
			cQryImp := " SELECT * " + _ENTER_ +;
					" FROM " + RetSqlName("Z0Y") + " Z0Y " + _ENTER_ +;
					" WHERE Z0Y.Z0Y_FILIAL = '"  + xFilial("Z0Y") + "'" + _ENTER_ +;
					"   AND Z0Y.Z0Y_CODEI IN "   + FormatIn(ArrTokStr(aCODEI , ";"), ";") + _ENTER_ +; // cQryImp += "   AND Z0Y.Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_ +;
					"   AND Z0Y.Z0Y_QTDREA = 0 " + _ENTER_ +;
					"   AND Z0Y.D_E_L_E_T_ = ' ' "
			TCQUERY cQryImp NEW ALIAS "QRYIMP"
			If (QRYIMP->(EOF()))
				cSttImp := "I"
			Else
				cSttImp := "A"
			EndIf
			QRYIMP->(DBCloseArea())

			cQry := " SELECT	R_E_C_N_O_ " + _ENTER_ +;
					" FROM		" +RetSqlName('Z0X')+ " " + _ENTER_ +;
					" WHERE		Z0X_CODIGO IN " + FormatIn(ArrTokStr(aCODEI , ";"), ";") + _ENTER_ +;
					" 		AND D_E_L_E_T_ = ' ' "
			TCQUERY cQry NEW ALIAS "TEMP"
			While !(TEMP->(EOF()))

				Z0X->(DbGoTo(TEMP->R_E_C_N_O_))

				Reclock("Z0X", .F.)
					Z0X->Z0X_CNTIMP := cSepJsn + cJsnImp
					Z0X->Z0X_ARQIMP := aParRet[1]
					Z0X->Z0X_DATIMP := Date()
					Z0X->Z0X_USUIMP := __cUserId
					Z0X->Z0X_STATUS := cSttImp
				Z0X->(MSUnlock())

				If (Z0X->Z0X_OPERAC == "1")
					If (cSttImp = 'I')
						DBSelectArea("Z0R")
						Z0R->(DBSetOrder(1))

						If (Z0R->(DBSeek(xFilial("Z0R") + DTOS(Z0X->Z0X_DATA) + Z0X->Z0X_VERSAO)))
							RecLock("Z0R", .F.)
							Z0R->Z0R_LOCK := '3'
							Z0R->(MSUnlock())
						EndIf
					EndIf
				EndIf

				TEMP->(DbSkip())
			EndDo
			TEMP->(DbCloseArea())
		EndIf
	End Transaction
RestArea(aArea)
Return lErro
// FIM: ImpCSV



/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 20.01.2020                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Cria fOpcoes para tipos de Motivos.                                  |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function fMotivos()

Local cTitulo	:=	""
Local MvParDef	:=	""
Local l1Elem 	:= .T.
Local MvPar		:= ""
Local oWnd
Local cTipoAu
Local cAliasQry := GetNextAlias()
Local cI		:= "0"

Private aResul	:={}

oWnd 	:= GetWndDefault()
MvPar	:=	&(AllTrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:=	AllTrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

cTitulo := "Tipos de Motivos"
// aResul  := {"Adiantamento", "Folha", "1a Parcela", "2a Parcela", "Extra", "Ferias"}
	beginSQL alias cAliasQry
		%noParser%
		SELECT X5_CHAVE, X5_DESCRI
		FROM %table:SX5%
		WHERE X5_FILIAL=%xFilial:SX5%
		  AND X5_TABELA='ZX'
		  AND %notDel%
	endSQL
	While !(cAliasQry)->(Eof())
		cI := Soma1(cI)
		MvParDef += cI

		aAdd( aResul, (cAliasQry)->X5_DESCRI )

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
// MvParDef:=	"123456"

	f_Opcoes(@MvPar, cTitulo, aResul, MvParDef, 12, 49, l1Elem, , 1)		// Chama funcao f_Opcoes
	&MvRet := mvpar 					   	// Devolve Resultado

Return


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 20.01.2020                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Gravar registro Z0W de trato que nao estava no planejamento;         |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function impZ0W(aDados, nI, nPCurral, _cCurral, nPCodDieta, nPOrdemProd, nPNumTrt, nPKGInic, nPKGFim, nPKGMetaReca,;
				nPKGFornec, nPData, nPHoraI, cHoraI, nPVagao )
/*
	trato sem planejamento
	
	1- preencher motivo 
	2- buscar numero de lote na sb8 pelo curral, saldo maior que 0,
	3- qual tiver o campo PESO DIGITADO preeenchido, forcar o preenchimento do campo MOTIVO DA CORRECAO;
	4- quando importar cara que nao estava no planejamento, o preenchimento do campo MOTIVO DA CORRECAO;

	// MJ : Estou implementando outra forma contendo informacoes dos dados a ser importado;
	lRet := .T.
	While lRet
		obj      := TExFilter():New("SX5",{"X5_CHAVE", "X5_DESCRI"}, "Motivos", , .F., "X5_TABELA='ZX'")
		aMotivos := aClone(obj:aSelect)
		
		If Len(aMotivos) == 1
			lRet := .F.
			
		ElseIf Len(aMotivos) == 0
			MsgInfo("E obrigatrio a selecao de um motivo.")
			
		ElseIf Len(aMotivos) > 1
			MsgInfo("Apenas um motivo pode ser selecionado por vez.")
			
		EndIf
	EndDo */
	
Local cPerg := "IMPZ0WPCP1"
Local lRet  := .T.

	If _cCurral <> aDados[nI, nPCurral]
		_cCurral := aDados[nI, nPCurral]
		GeraX1(cPerg)
		Pergunte(cPerg, .F.)
		U_PosSX1({{ cPerg, "02", aDados[nI, nPCurral]	 },;
				  { cPerg, "03", aDados[nI, nPVagao]     },;
				  { cPerg, "04", aDados[nI, nPCodDieta]	 },;
				  { cPerg, "05", aDados[nI, nPOrdemProd] },;
				  { cPerg, "06", aDados[nI, nPNumTrt]	 },;
				  { cPerg, "07", aDados[nI, nPKGFornec]	 }})
		While lRet
			Pergunte(cPerg, .T.) 
			
			If (lRet := Empty(MV_PAR01))
				MsgInfo("E Obrigatrio a selecao de um motivo.")
			EndIf
		EndDo
			// U_PrintSX1(cPerg)
	EndIf

	// pegar lote
	cAliasQry := GetNextAlias()
	beginSQL alias cAliasQry
		%noParser%
		SELECT DISTINCT B8_LOTECTL LOTE
		FROM %table:SB8%
		WHERE	B8_FILIAL=%xFilial:SB8%
			AND B8_SALDO>0
			AND B8_X_CURRA=%exp:aDados[nI, nPCurral]%
			AND %notDel%
	endSQL
	If !(cAliasQry)->(Eof())
		cLote := (cAliasQry)->LOTE
		// (cAliasQry)->(dbSkip())
	Else
		cLote := aDados[nI, nPLote]
	EndIf
	(cAliasQry)->(dbCloseArea())

	//  programar inclusao
	RecLock("Z0W", .T.)
		Z0W->Z0W_MOTCOR := PadL(AllTrim(MV_PAR01), 2, "0")
		Z0W->Z0W_ROTA   := Posicione('Z0Y', 1, xFilial('Z0Y')+Z0X->Z0X_CODIGO+aDados[nI, nPOrdemProd], 'Z0Y_ROTA')
		Z0W->Z0W_FILIAL := xFilial("Z0W")
		Z0W->Z0W_CODIGO := GetNextCod("Z0W_CODIGO")
		Z0W->Z0W_CODEI  := Z0X->Z0X_CODIGO
		Z0W->Z0W_VERSAO := StrZero(1,TamSX3('Z0W_VERSAO')[1])
		Z0W->Z0W_DATA   := CToD( aDados[nI, nPData] )
		Z0W->Z0W_ORDEM  := aDados[nI, nPOrdemProd]
		Z0W->Z0W_TRATO  := aDados[nI, nPNumTrt]
		Z0W->Z0W_LOTE   := cLote
		Z0W->Z0W_CURRAL := aDados[nI, nPCurral]
		Z0W->Z0W_RECEIT := aDados[nI, nPCodDieta]
		Z0W->Z0W_KGINIC := Val( aDados[nI, nPKGInic] )
		Z0W->Z0W_KGFIM  := Val( aDados[nI, nPKGFim]  )
		Z0W->Z0W_KGRECA := Val( aDados[nI, nPKGMetaReca] )
		Z0W->Z0W_QTDREA := VAL(aDados[nI, nPKGFornec])
		Z0W->Z0W_DIFPES := ABS( Z0W->Z0W_QTDPRE - Z0W->Z0W_QTDREA )
		Z0W->Z0W_DATINI := cToD(aDados[nI, nPData])
		Z0W->Z0W_HORINI := cHoraI
		Z0W->Z0W_DATFIN := cToD(aDados[nI, nPData])
		Z0W->Z0W_HORFIN := (cHoraI:=aDados[nI, nPHoraI])
	Z0W->(MSUnlock())

Return nil


// --> MJ : 13.12.2019 <--
User Function btnEst()

Local aEnButt := {{.F., NIL},;       // 01 - Copiar
                  {.F., NIL},;       // 02 - Recortar
                  {.F., NIL},;       // 03 - Colar
                  {.F., NIL},;       // 04 - Calculadora
                  {.F., NIL},;       // 05 - Spool
                  {.F., NIL},;       // 06 - Imprimir
                  {.F., NIL},;       // 07 - Confirmar
                  {.T., "Sair"},;    // 08 - Cancelar
                  {.F., NIL},;       // 09 - WalkTrhough
                  {.F., NIL},;       // 10 - Ambiente
                  {.F., NIL},;       // 11 - Mashup
                  {.T., NIL},;       // 12 - Help
                  {.F., NIL},;       // 13 - Formulario HTML
                  {.F., NIL}}        // 14 - ECM

	If (MsgYesNo("Confirma ESTORNO do Arquivo: '" + Z0X->Z0X_CODIGO + "' do Equipamento '" + AllTrim(POSICIONE("ZV0", 1, xFilial("ZV0")+Z0X->Z0X_EQUIP, "ZV0_DESC")) + "'?"))

		FWMsgRun(, {|| U_EstPrcArq()}, "Processando", "Estornando processamento...")

	EndIf

Return (Nil)


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 13.12.2019                                                           |
 | Cliente  : Livio                                                                |
 | Desc		:                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : Corrigido erro neste dia;                                            |
 '---------------------------------------------------------------------------------*/
User Function EstPrcArq()

Local cQryUpd := ""
Local cQryEst := ""
Local aOPEst  := {}
Local nCntEst := 1
Local lBrk    := .F.

Begin Transaction

	cQryUpd := " UPDATE " + RetSqlName("Z0Y") + _ENTER_
	cQryUpd += " SET Z0Y_DATPRC = '' " + _ENTER_
	cQryUpd += "   , Z0Y_HORPRC = '' " + _ENTER_
	cQryUpd += " WHERE Z0Y_FILIAL = '" + xFilial("Z0Y") + "'" + _ENTER_
	cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
	cQryUpd += "   AND Z0Y_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	
	If (TCSqlExec(cQryUpd) < 0)
		MsgInfo(TCSqlError())
		DisarmTransaction()
		Break
	EndIf
	
	cQryUpd := " UPDATE " + RetSqlName("Z0W") + _ENTER_
	cQryUpd += " SET Z0W_DATPRC = '' " + _ENTER_
	cQryUpd += "   , Z0W_HORPRC = '' " + _ENTER_
	cQryUpd += " WHERE Z0W_FILIAL = '" + xFilial("Z0W") + "'" + _ENTER_
	cQryUpd += "   AND D_E_L_E_T_ = ' ' " + _ENTER_
	cQryUpd += "   AND Z0W_CODEI = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	
	If (TCSqlExec(cQryUpd) < 0)
		MsgInfo(TCSqlError())
		DisarmTransaction()
		Break
	EndIf

	RecLock("Z0X", .F.)
		Z0X->Z0X_STATUS := "C"
	Z0X->(MSUnlock())

	cQryEst := " SELECT Z02.Z02_SEQUEN AS SEQ, CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), Z04.Z04_NUMOP)) AS NUMOP " + _ENTER_
	cQryEst += " FROM " + RetSqlName("Z02") + " Z02 " + _ENTER_
	cQryEst += " JOIN " + RetSqlName("Z04") + " Z04 ON Z04.Z04_SEQUEN = Z02.Z02_SEQUEN AND Z04.Z04_FILIAL = '" + xFilial("Z04") + "' AND Z04.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryEst += " WHERE Z02.Z02_FILIAL = '" + xFilial("Z02") + "'" + _ENTER_
	cQryEst += "   AND Z02.Z02_ARQUIV = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryEst += "   AND Z02.Z02_TPARQ  = '4' " + _ENTER_
	cQryEst += "   AND Z02.D_E_L_E_T_ = ' ' " + _ENTER_
//	cQryEst += " GROUP BY Z02.Z02_SEQUEN, Z04.Z04_NUMOP " + _ENTER_
	
	TCQUERY cQryEst NEW ALIAS "QRYEST"

	While (!QRYEST->(EOF()))
	
		aOPEst := &(QRYEST->NUMOP)
	
		If (!Empty(aOPEst[1]))
			For nCntEst := 1 To Len(aOPEst[1])
		
				TryException
					U_VAEST002(AllTrim(aOPEst[1][nCntEst]))
				CatchException Using oException
					QRYEST->(DBCloseArea())
					u_ShowException(oException)
					DisarmTransaction()
					lBrk := .T.
				EndException
		
				If (lBrk)
					Break
				EndIf
	
			Next nCntEst
		EndIf
		
		DBSelectArea("Z02")
		Z02->(DBSetOrder(1))
		
		If (Z02->(DBSeek(xFilial("Z02") + QRYEST->SEQ)))
			RecLock("Z02", .F.)
				DBDelete()
			Z02->(MSUnlock())
		EndIf
	
		DBSelectArea("Z04")
		Z04->(DBSetOrder(1))
		
		If (Z04->(DBSeek(xFilial("Z04") + QRYEST->SEQ)))
		
			While (Z04->Z04_SEQUEN = QRYEST->SEQ)
				RecLock("Z04", .F.)
					DBDelete()
				Z04->(MSUnlock())
				
				Z04->(DBSkip())
			EndDo
		
		EndIf
		
		QRYEST->(DBSkip())
		
	EndDo
	QRYEST->(DBCloseArea())
	
	cQryEst := " SELECT Z02.Z02_SEQUEN AS SEQ, Z03.Z03_NUMOP AS NUMOP" + _ENTER_
	cQryEst += " FROM " + RetSqlName("Z02") + " Z02 " + _ENTER_
	cQryEst += " JOIN " + RetSqlName("Z03") + " Z03 ON Z03.Z03_SEQUEN = Z02.Z02_SEQUEN AND Z03.Z03_FILIAL = '" + xFilial("Z03") + "' AND Z03.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryEst += " WHERE Z02.Z02_FILIAL = '" + xFilial("Z02") + "'" + _ENTER_
	cQryEst += "   AND Z02.Z02_ARQUIV = '" + Z0X->Z0X_CODIGO + "'" + _ENTER_
	cQryEst += "   AND Z02.Z02_TPARQ  = '3' " + _ENTER_
	cQryEst += "   AND Z02.D_E_L_E_T_ = ' ' " + _ENTER_
	cQryEst += " GROUP BY Z02.Z02_SEQUEN, Z03.Z03_NUMOP " + _ENTER_
	
	TCQUERY cQryEst NEW ALIAS "QRYEST"

	While (!QRYEST->(EOF()))
	
		TryException
		
			U_VAEST002(AllTrim(QRYEST->NUMOP))
		
		CatchException Using oException
			QRYEST->(DBCloseArea())
			u_ShowException(oException)
			DisarmTransaction()
			lBrk := .T.
		EndException

		If (lBrk)
			Break
		EndIf


		DBSelectArea("Z02")
		Z02->(DBSetOrder(1))
		
		If (Z02->(DBSeek(xFilial("Z02") + QRYEST->SEQ)))
			RecLock("Z02", .F.)
				DBDelete()
			Z02->(MSUnlock())
		EndIf

		DBSelectArea("Z03")
		Z03->(DBSetOrder(1))
		
		If (Z03->(DBSeek(xFilial("Z03") + QRYEST->SEQ)))
		
			While (Z03->Z03_SEQUEN = QRYEST->SEQ)
				RecLock("Z03", .F.)
					DBDelete()
				Z03->(MSUnlock())
				
				Z03->(DBSkip())
			EndDo
		
		EndIf
		
		QRYEST->(DBSkip())
	EndDo
	QRYEST->(DBCloseArea())
	
End Transaction

If (!lBrk)
	MsgInfo("Estorno concluido com sucesso!")
EndIf

Return (Nil) 

/*
Tabela A - Modos de acesso a arquvios bin�rios
Modo
Constante (fileio.ch)

Operacao
0	FO_READ			Aberto para leitura (padrao)
1	FO_WRITE		Aberto para gravacao
2	FO_READWRITE	Aberto para leitura e gravacao

https://tdn.totvs.com/display/tec/FOpen
*/
// U_JOBPrcLote()


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 22.02.2021                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Validar se existe versao maior que 0001; se tiver entao a operacao   |
 | Desc		:  nao pode continuar;                                                 |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function fTemVersaoMaior()
Local cAux  := ""
	cQryExp := " SELECT TOP 1 Z0X_DATA, Z0X_CODIGO, Z0X_VERSAO AS VERSAO " + _ENTER_ +;
			   " FROM " + RetSqlName("Z0X") + " Z0X "  + _ENTER_ +;
			   " WHERE Z0X.Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_ +;
			   "   AND Z0X.Z0X_DATA   = '" + DTOS(aParRet[1]) + "'" + _ENTER_ +;
			   "   AND Z0X_VERSAO 	  > '0001'" + _ENTER_ +; // esta 0001 � fixo mesmo;
			   "   AND Z0X.D_E_L_E_T_ = ' '" + _ENTER_ +;
			   " ORDER BY Z0X_VERSAO DESC"
	MEMOWRITE( "C:\TOTVS_RELATORIOS\VAPCPA13_Geral.sql", cQryExp)
	TCQUERY cQryExp NEW ALIAS "QRYTMP"
	
	If !(QRYTMP->(EOF()))
		cAux := dToC(sTod(QRYTMP->Z0X_DATA)) + "- Codigo: " + QRYTMP->Z0X_CODIGO + "- Versao: " + QRYTMP->VERSAO // QRYTMP->VERSAO
	EndIf
	QRYTMP->(dbCloseArea())	
Return cAux



/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 23.02.2021                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Verificar a necessidade da geracao de arquivo para a Phibro;         |
 | Desc		: Pode ou nao ser gerado um arquivo. de acordo com o campo G1_ORIGEM   |
 |             = P                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
// Static Function gerarPhibro( aPhibro )
// Local aArea   := GetArea()
// Local nI      := 0
// // Local _cOrdem := ""
// Local nCont   := 0
// Local nQtdPre := 0
// 
// DBSelectArea("Z0X")
// Z0X->(DBSetOrder(1))
// RecLock("Z0X", .T.)
// 	Z0X->Z0X_FILIAL := xFilial("Z0X")
// 	Z0X->Z0X_CODIGO := /* cCodigo := */GetNextCod("Z0X_CODIGO")
// 	Z0X->Z0X_DATA   := aParRet[1]
// 	Z0X->Z0X_VERSAO := aParRet[2]
// 	//Z0X->Z0X_EQUIP  := "PREMIX"//aParRet[3]
// 	//Z0X->Z0X_OPERAD := aPhibro[nI, 8] // IIf(aParRet[4] == 1, aPhibro[9], "")
// 	//Z0X->Z0X_TRATO  := AllTrim(STR( aPhibro[nI, 14] )) // nNrTrt
// 	Z0X->Z0X_OPERAC := '3' // AllTrim(STR(aParRet[4]))
// 	Z0X->Z0X_STATUS := "G"
// 	Z0X->Z0X_DATEXP := Date()
// 	Z0X->Z0X_USUEXP := __cUserId
// Z0X->(MSUnlock())
// 
// For nI := 1 to Len( aPhibro )
// 
// 	nCont   := 0
// 	// If _cOrdem <> aPhibro[nI, 2] // cSeqOrd
// 	// 	// /* criacao da Z0X */
// 	// 	DBSelectArea("Z0X")
// 	// 	Z0X->(DBSetOrder(1))
// 	// 	RecLock("Z0X", .T.)
// 	// 		Z0X->Z0X_FILIAL := xFilial("Z0X")
// 	// 		Z0X->Z0X_CODIGO := /* cCodigo := */GetNextCod("Z0X_CODIGO")
// 	// 		Z0X->Z0X_DATA   := aParRet[1]
// 	// 		Z0X->Z0X_VERSAO := aParRet[2]
// 	// 		Z0X->Z0X_EQUIP  := aParRet[3]
// 	// 		Z0X->Z0X_OPERAD := aPhibro[nI, 8] // IIf(aParRet[4] == 1, aPhibro[9], "")
// 	// 		Z0X->Z0X_TRATO  := AllTrim(STR( aPhibro[nI, 14] )) // nNrTrt
// 	// 		Z0X->Z0X_OPERAC := AllTrim(STR(aParRet[4]))
// 	// 		Z0X->Z0X_STATUS := "G"
// 	// 		Z0X->Z0X_DATEXP := Date()
// 	// 		Z0X->Z0X_USUEXP := __cUserId
// 	// 	Z0X->(MSUnlock())
// 	// 	_cOrdem := aPhibro[nI, 2] // cSeqOrd
// 	// EndIf
// 
// 	/* criacao da Z0Y */
// 	cQryRec := " SELECT * " + _ENTER_ +;
// 				" FROM ( " + _ENTER_ +;
// 				" 	SELECT DISTINCT " + _ENTER_ +;
// 				" 			ZG1.ZG1_COD AS RECEITA, ZG1.ZG1_COMP AS ITEM " + _ENTER_ +;
// 				" 		  ,	ZG1.ZG1_QUANT AS QUANT, Z0V.Z0V_INDMS AS INDMS " + _ENTER_ +;
// 				" 		  ,	ZG1.ZG1_TIMER AS TIMER,	ZG1.ZG1_TRT AS SEQ, SB1.B1_QB  " + _ENTER_ +;
// 				" 		   FROM ZG1010 ZG1  " + _ENTER_ +;
// 				"          JOIN SB1010 SB1 ON B1_COD = ZG1_COD AND SB1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
// 				" 	 RIGHT JOIN Z0V010 Z0V ON Z0V.Z0V_FILIAL = '" + xFilial("Z0V") + "' " + _ENTER_ +;
// 				"  											 AND Z0V.Z0V_COMP = ZG1.ZG1_COMP " + _ENTER_ +;
// 				"  											 AND Z0V.D_E_L_E_T_ = ' '  " + _ENTER_ +;
// 				" 	 WHERE ZG1.ZG1_FILIAL = '01' " + _ENTER_ +;
// 				" 	   AND ZG1.ZG1_COD = '" + aPhibro[nI, 6] + "' " + _ENTER_ +;
// 				" 	   AND ZG1.ZG1_SEQ = ( " + _ENTER_ +;
// 				"  	  			      			SELECT MAX(ZG1A.ZG1_SEQ) " + _ENTER_ +;
// 				"  	  			      			FROM ZG1010 ZG1A " + _ENTER_ +;
// 				"  	  			      			WHERE ZG1A.ZG1_FILIAL = '" + xFilial("ZG1") + "' " + _ENTER_ +;
// 				"    				      				AND ZG1A.ZG1_COD = ZG1.ZG1_COD " + _ENTER_ +;
// 				"    				      				AND ZG1A.D_E_L_E_T_ = ' ' " + _ENTER_ +;
// 				" 							)  " + _ENTER_ +;
// 				" 	   AND Z0V.Z0V_DATA   = '" + DToS(Z0X->Z0X_DATA) + "' " + _ENTER_ +;
// 				" 	   AND Z0V.Z0V_VERSAO <= '" + Z0X->Z0X_VERSAO + "' " + _ENTER_ +; // coloque o <= na data 15.03.2021
// 				" 	   AND ZG1.D_E_L_E_T_ = ' '  " + _ENTER_ +;
// 				" ) DADOS " + _ENTER_ +;
// 				" ORDER BY CONVERT(INT, SEQ) "
// 
//  	MEMOWRITE("C:\TOTVS_RELATORIOS\EXPRECEITA_Phibro_" + AllTrim(aPhibro[nI, 6]) + ".sql", cQryRec)
//  	TCQUERY cQryRec NEW ALIAS "QRYREC"
// 	 	
// 	While (!QRYREC->(EOF()))
// 		
// 		nCont   += 1
// 		//nQtdPre := Round( Round((QRYREC->QUANT * aPhibro[nI,12]) / (QRYREC->INDMS/100), 0) / aPhibro[nI,13], 0)* aPhibro[nI,13]
// 		nQtdPre := Round( (aPhibro[nI,15] / (QRYREC->B1_QB / QRYREC->QUANT)), 2)
// 
//  		RecLock("Z0Y", .T.)
//  			Z0Y->Z0Y_FILIAL := xFilial("Z0Y")
//  			Z0Y->Z0Y_CODIGO := /* cCodigo := */GetNextCod("Z0Y_CODIGO")
//  			Z0Y->Z0Y_CODEI  := Z0X->Z0X_CODIGO
//  			Z0Y->Z0Y_ORDEM  := aPhibro[nI, 2] // cSeqOrd // IIf(lMsmOrd, cSeqOrd, AllTrim(STR(Year(aParRet[1])) + "-" + cSeqOrd))
//  			Z0Y->Z0Y_TRATO  := aPhibro[nI, 4] // IIf(aParRet[4] = 1, AllTrim(STR(nCntTrt)), PADL(nCntTrt, 2))
//  			Z0Y->Z0Y_AJUSTE := 0
//  			Z0Y->Z0Y_TIMER  := aPhibro[nI, 9] // QRYREC->TIMER
//  			Z0Y->Z0Y_RECEIT := aPhibro[nI,11] // aPhibro[nI,10] // QRYREC->RECEITA
//  			Z0Y->Z0Y_COMP   := QRYREC->ITEM // aPhibro[nI,11] // QRYREC->ITEM
//  			Z0Y->Z0Y_QTDPRE := nQtdPre // aPhibro[nI,12+nCont] // nQtdPre
//  			Z0Y->Z0Y_QTDREA := 0
//  			Z0Y->Z0Y_TOLERA := 0
//  			Z0Y->Z0Y_ROTA   := aPhibro[nI, 7] // IIf(aParRet[4] = 1, AllTrim(aOrdCur[nCntOrd][1]), "")
//  			Z0Y->Z0Y_DATA   := Z0X->Z0X_DATA
//  			Z0Y->Z0Y_VERSAO := Z0X->Z0X_VERSAO
//  			// Z0Y->Z0Y_ORIGEM := "P" // Phibro
//  			// Z0Y->Z0Y_EQUIP := aParRet[3]
//  		Z0Y->(MSUnlock())
// 
//  		QRYREC->(DBSkip())
//  	EndDo
//  	QRYREC->(DBCloseArea())
// Next nI
// 
// RestArea(aArea)
// Return

/* 
	MB : 19.08.2021
		-> Verificar se existe EXPORTACAO gerada;
			Se houver, nao sera permitido continuar a geracao GERAL (para todos);
			apenas por caminhao;
*/
Static Function TemExpGerada()
	Local lRet := .F.
	_cQry := " SELECT	* " + _ENTER_ +;
		" FROM		" +RetSqlName('Z0X')+ " " + _ENTER_ +;
		" WHERE 	Z0X_FILIAL = '" + xFilial("Z0X") + "'" + _ENTER_ +;
		"   	AND Z0X_DATA = '" + DTOS(aParRet[1]) + "'" + _ENTER_ +;
		"   	AND D_E_L_E_T_	= ' ' "
	TCQUERY _cQry NEW ALIAS "QRYAlias"
	If !(QRYAlias->(EOF()))
		lRet := .T.
	EndIf
	QRYAlias->(DbCloseArea())
Return lRet


/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2021                                                           |
 | Cliente  : Livio                                                                |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function BTParH20()

Local cParPhibro := GetMV( "MB_PCPA13P" /* ,, 70 */ )
Local cParImbife := GetMV( "MB_PCPA13I" /* ,, 50 */ )
Local aPosSX1 	 := {}

Private cPerg 	 := "PERGH20   "

MsgInfo("Esta rotina servir� para atualizar os parametros que definem a quantidade de agua " +;
		"utilizada nos processos da Phibro e Imbife." + CRLF +;
		"PARAMETROS ATUAIS" + CRLF +;
		"Phibro: " + cValToChar(cParPhibro) + CRLF +;
		"Imbife: " + cValToChar(cParImbife) )

ValidPerg()

// Pergunte(cPerg, .F.)
aPosSX1 := { { cPerg, "01", cParPhibro },;
			 { cPerg, "02", cParImbife } }
U_PosSX1(aPosSX1)
If !Pergunte(cPerg,.t.)
 Return
Endif    

If cParPhibro <> MV_PAR01
	PutMV( "MB_PCPA13P", MV_PAR01 ) // Phibro
EndIf
If cParImbife <> MV_PAR02
	PutMV( "MB_PCPA13I", MV_PAR02 ) // Imbife
EndIf

Aviso("Configuracao atual dos par�metros",;
		"A quantidade de agua para configurada nos processos ficaram da seguinte maneira: " + CRLF+;
			  "Phibro: " + cValToChar(GetMV( "MB_PCPA13P" )) + CRLF +;
			  "Imbife: " + cValToChar(GetMV( "MB_PCPA13I" )) , {"OK"},1)   
Return nil

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 26.11.2021                                                           |
 | Cliente  : Livio                                                                |
 | Desc		:                                                    			       |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
Static Function ValidPerg()
Local _sAlias, i, j
Local aRegs := {}
_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)
 
AADD(aRegs,{cPerg,"01","Qtd. Agua Phibro:" ,"","","MV_CH1","N", 4, 0, 0, "C", "","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Qtd. Agua Imbife:" ,"","","MV_CH2","N", 4, 0, 0, "C", "","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)                                                                      
   If !dbSeek(cPerg+aRegs[i,2])
    RecLock("SX1",.T.)
	    For j := 1 to FCount()
	       If j <= Len(aRegs[i])
	       	 FieldPut(j,aRegs[i,j])
	       Endif
	    Next j
    MsUnlock()
    dbCommit()
   EndIf
Next i
 
 dbSelectArea(_sAlias)
Return

/* 
User Function PCPA13POS( oModel )
	Alert("PCPA13POS")
Return .T.

User Function PCPA13LPOS( oModelGrid )
	Alert("PCPA13LPOS")
Return .T.
 */


/* MB : 14.05.2022 
	-> For�ar Salvamento; */
// Static Function SVDTM( oModel )
// Local aArea  := GetArea()
// // Local nI
// 
// // // Z0Y	2	Z0Y_FILIAL+Z0Y_ORDEM+Z0Y_TRATO
// // Z0Y->(dbSetOrder(2))
// // If Z0Y->(dbSeek(oModel:GetValue( "MdGrdZ0Y", "Z0Y_FILIAL") +;
// // 				oModel:GetValue( "MdGrdZ0Y", "Z0Y_ORDEM" ) +;
// // 				oModel:GetValue( "MdGrdZ0Y", "Z0Y_TRATO" ) ))
// // 	For nI := 1 to oModel:GetModel("MdGrdZ0Y"):Length()
// // 		oModel:GetModel("MdGrdZ0Y"):GoLine(nI)
// // 		
// // 		DbSelectArea("SX3")
// // 		SX3->(DbSetOrder(1))
// // 		If SX3->( dbSeek( "Z0Y" ) )
// // 			While !(SX3->(eof())) .and. SX3->X3_ARQUIVO == "Z0Y" .AND. SX3->X3_CONTEXT<>'V' // .AND. X3USO(SX3->X3_USADO)
// // 				RecLock("Z0Y", .F.)
// // 					If !Empty(oModel:GetValue( "MdGrdZ0Y", SX3->X3_CAMPO))
// // 						&(SX3->X3_ARQUIVO+'->'+SX3->X3_CAMPO) := oModel:GetValue( "MdGrdZ0Y", SX3->X3_CAMPO)
// // 					EndIf
// // 				Z0Y->(MsUnlock())
// // 				SX3->(DbSkip())
// // 			EndDo
// // 		Endif
// // 	Next nI
// // EndIf
// // 
// // // Z0W	1	Z0W_FILIAL+Z0W_CODEI+Z0W_TRATO+Z0W_CURRAL
// // Z0W->(DBSetOrder(1))
// // If Z0W->( DbSeek( oModel:GetValue( "MdGrdZ0W", "Z0W_FILIAL") +;
// // 				  oModel:GetValue( "MdGrdZ0W", "Z0W_CODEI" ) +;
// // 				  oModel:GetValue( "MdGrdZ0W", "Z0W_TRATO" ) +;
// // 				  oModel:GetValue( "MdGrdZ0W", "Z0W_CURRAL") ))
// // 	For nI := 1 to oModel:GetModel("MdGrdZ0W"):Length()
// // 		oModel:GetModel("MdGrdZ0W"):GoLine(nI)
// // 		
// // 		DbSelectArea("SX3")
// // 		SX3->(DbSetOrder(1))
// // 		If SX3->( dbSeek( "Z0W" ) )
// // 			While !(SX3->(eof())) .and. SX3->X3_ARQUIVO == "Z0W" .AND. SX3->X3_CONTEXT<>'V' // .AND. X3USO(SX3->X3_USADO)
// // 				RecLock("Z0W", .F.)
// // 					If !Empty(oModel:GetValue( "MdGrdZ0W", SX3->X3_CAMPO))
// // 						&(SX3->X3_ARQUIVO+'->'+SX3->X3_CAMPO) := oModel:GetValue( "MdGrdZ0W", SX3->X3_CAMPO)
// // 					EndIf
// // 				Z0W->(MsUnlock())
// // 				SX3->(DbSkip())
// // 			EndDo
// // 		Endif
// // 	Next nI
// // EndIf
// FWFormCommit( oModel )
// 
// RestArea(aArea)
// Return .T.


/* MB : 08.06.2022
	-> Contar Quantas Dietas na rota */
Static Function CountRotaDieta( a2OrdArq ) /* , @a2OrdCur */
Local nI   := 0
Local nJ   := 0
Local nTot := len(a2OrdArq)
// Local nQtd := 0

If nTot > 1
	for nI := 1 to nTot-1
		for nJ := nI+1 to len(a2OrdArq)
			If a2OrdArq[nI, 01] == a2OrdArq[nJ, 01]
				a2OrdArq[nI, 03] += 1
				// a2OrdArq[nJ, 03] += 1
			EndIf
		Next nJ
	Next nI
EndIf

Return nil


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 28.07.2023                                                           |
 | Cliente  : Livio                                                                |
 | Desc		: Importar detalhado                                                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function ImpDetalhado(cFile)
Local aArea 		:= GetArea()
Local nHandle 		:= FT_FUse(cFile)
Local nI			:= 0
Local aAux			:= {}
Local aDados		:= {}
Local cMsg := ""

	If nHandle <= 0 // > -1
		MsgInfo("Nao foi possivel abrir o arquivo '" + MV_PAR01 + "', verifique e tente novamente.")
	
		RestArea(aArea)
		Return nil
	EndIf

	FT_FGoTop() // Posiciona na primeria linha
	If !FT_FEOF()
		If !Empty(cLine:=FT_FReadLn())
			aHeaderCSV  := StrToKArr(cLine,';')
			FT_FSKIP()
		EndIf
	EndIf
	While !FT_FEOF()
		If !Empty(cLine:=FT_FReadLn())
			aAux := StrToKArr(cLine,';')
			aAdd( aDados	   , {} )
			For nI:=1 to Len(aAux)
				aAdd( aTail(aDados), aAux[nI] )
			Next nI
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE() // Fecha o Arquivo

	If ( nPOrdemProd := aScan(aHeaderCSV, { |x| Upper(x) == 'ORD_PRODUCAO' }) ) == 0
		// MsgStop("A Coluna: [ORD_PRODUCAO] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [ORD_PRODUCAO] nao foi localizada no arquivo."
	EndIf
	If ( nPNumCarreg := aScan(aHeaderCSV, { |x|Upper(x)=='NUM_CARREG' }) ) == 0
		// MsgStop( "A Coluna [NUM_CARREG] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna [NUM_CARREG] nao foi localizada no arquivo."
	EndIf
	If ( nPReceita := aScan(aHeaderCSV, { |x|Upper(x)=='COD_DIETA' }) ) == 0
		// MsgStop( "A Coluna [COD_DIETA] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna [COD_DIETA] nao foi localizada no arquivo."
	EndIf
	If ( nPNumCarreg := aScan(aHeaderCSV, { |x|Upper(x)=='NUM_CARREG' }) ) == 0
		// MsgStop( "A Coluna [NUM_CARREG] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna [NUM_CARREG] nao foi localizada no arquivo."
	EndIf
	If ( nPOrdIngred := aScan(aHeaderCSV, { |x|Upper(x)=='ORD_INGRED' }) ) == 0
		// MsgStop( "A Coluna [ORD_INGRED] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna [ORD_INGRED] nao foi localizada no arquivo."
	EndIf
	If ( nPCodIngred := aScan(aHeaderCSV, { |x|Upper(x)=='COD_INGRED' }) ) == 0
		// MsgStop( "A Coluna [COD_INGRED] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna [COD_INGRED] nao foi localizada no arquivo."
	EndIf
	If ( nPVagao     := aScan(aHeaderCSV, { |x| Upper(x) == 'VAGAO'}) ) == 0
		// MsgStop( "A Coluna: [VAGAO] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [VAGAO] nao foi localizada no arquivo."
	EndIf
	If ( nPData		:= aScan(aHeaderCSV, { |x| Upper(x) == 'DATA'}) ) == 0
		// MsgStop( "A Coluna: [DATA] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [DATA] nao foi localizada no arquivo."
	EndIf
	If ( nPHora		:= aScan(aHeaderCSV, { |x| Upper(x) == 'HORA'}) ) == 0
		// MsgStop( "A Coluna: [HORA] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [HORA] nao foi localizada no arquivo."
	EndIf
	If ( nPHoraCarreg:= aScan(aHeaderCSV, { |x| Upper(x) == 'HORA_CARREG'}) ) == 0
		// MsgStop( "A Coluna: [HORA_CARREG] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [HORA_CARREG] nao foi localizada no arquivo."
	EndIf
	If ( nPKg_Prev  := aScan(aHeaderCSV, { |x| Upper(x) == 'KG_PREV'}) ) == 0
		// MsgStop( "A Coluna: [KG_PREV] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [KG_PREV] nao foi localizada no arquivo."
	EndIf
	If ( nPKgPrvRecal  := aScan(aHeaderCSV, { |x| Upper(x) == 'KG_PREV_RECAL'}) ) == 0
		// MsgStop( "A Coluna: [KG_PREV_RECAL] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [KG_PREV_RECAL] nao foi localizada no arquivo."
	EndIf
	If ( nPKg_Carreg := aScan(aHeaderCSV, { |x| Upper(x) == 'KG_CARREG'}) ) == 0
		// MsgStop( "A Coluna: [KG_CARREG] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [KG_CARREG] nao foi localizada no arquivo."
	EndIf
	If ( nPDesvio_Kg := aScan(aHeaderCSV, { |x| Upper(x) == 'DESVIO_KG'}) ) == 0
		// MsgStop( "A Coluna: [DESVIO_KG] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [DESVIO_KG] nao foi localizada no arquivo."
	EndIf
	If ( nPDesvPerc := aScan(aHeaderCSV, { |x| Upper(x) == 'DESVIO_PERC'}) ) == 0
		// MsgStop( "A Coluna: [DESVIO_PERC] nao foi localizada no arquivo.", "Atencao")
		cMsg += iIf(Empty( cMsg ),"", CRLF) + "A Coluna: [DESVIO_PERC] nao foi localizada no arquivo."
	EndIf
	
	If !Empty( cMsg )
		MsgStop( cMsg, "Atencao")
	Else

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		DbSelectArea("SC2")
		SC2->(DbSetOrder(1))

		Begin Transaction	
			
			DBSelectArea("Z0Z")
			Z0Z->(DBSetOrder(1))

			// ORDENACAO
			// aSort( aDados ,,, {|x,y| x[nPOrdemProd]+x[nPNumCarreg]+x[nPCodIngred] < y[nPOrdemProd]+y[nPNumCarreg]+y[nPCodIngred] } )

			For nI := 1 to Len(aDados)

				// IncRegua( "Processando: " + StrZero(nI, 4))

				Z0Z->(DbSetOrder(2)) // 1 = Z0Z_FILIAL+Z0Z_ORDEM+Z0Z_CARREG+Z0Z_COMP
				if Z0Z->( DbSeek( xFilial("Z0Z") + aDados[nI, nPOrdemProd ] + aDados[nI, nPNumCarreg ] +aDados[nI, nPOrdIngred ] + aDados[nI, nPCodIngred ] ) )
					cMsg += iIf(Empty( cMsg ),"", CRLF) + "Erro na linha: " + StrZero(nI, 4) + ", Item ja registrado: " + xFilial("SB1") + aDados[nI, nPOrdemProd ] + aDados[nI, nPNumCarreg ] + aDados[nI, nPCodIngred ]
				EndIf

				SB1->(DbSetOrder(1))
				if !SB1->( DbSeek( xFilial("SB1") + aDados[nI, nPReceita ] ) )
					cMsg += iIf(Empty( cMsg ),"", CRLF) + "Erro na linha: " + StrZero(nI, 4) + ", Codigo da Receita: " + aDados[nI, nPReceita ] + " nao cadastrado no Protheus"
				EndIf

				SB1->(DbSetOrder(1))
				if !SB1->( DbSeek( xFilial("SB1") + aDados[nI, nPCodIngred ] ) )
					cMsg += iIf(Empty( cMsg ),"", CRLF) + "Erro na linha: " + StrZero(nI, 4) + ", Codigo de Ingrediente: " + aDados[nI, nPCodIngred ] + " nao cadastrado no Protheus"
				EndIf

				Z0Y->(DbSetOrder(2)) // Z0Y_FILIAL+Z0Y_ORDEM+Z0Y_TRATO
				if !Z0Y->( DbSeek( xFilial("Z0Y") + aDados[nI, nPOrdemProd ] ) )
					cMsg += iIf(Empty( cMsg ),"", CRLF) + "Erro na linha: " + StrZero(nI, 4) + ", Ordem de produ��o: " + aDados[nI, nPOrdemProd ] + " nao localizada no Protheus"
				EndIf

				If Empty( cMsg )
					RecLock("Z0Z", .T.)
						Z0Z->Z0Z_FILIAL := xFilial("Z0Z")
						Z0Z->Z0Z_ORDEM  := aDados[nI, nPOrdemProd ]
						Z0Z->Z0Z_RECEIT := aDados[nI, nPReceita   ]
						Z0Z->Z0Z_CARREG := aDados[nI, nPNumCarreg ]
						Z0Z->Z0Z_SEQ    := Val(aDados[nI, nPOrdIngred ])
						Z0Z->Z0Z_COMP   := aDados[nI, nPCodIngred ]
						Z0Z->Z0Z_EQUIP  := aDados[nI, nPVagao     ]
						Z0Z->Z0Z_DATA   := cToD(aDados[nI, nPData ]) 		
						Z0Z->Z0Z_HORA   := aDados[nI, nPHora      ]
						Z0Z->Z0Z_HRCAR  := aDados[nI, nPHoraCarreg]
						Z0Z->Z0Z_KGPREV := GetdToVal(aDados[nI, nPKg_Prev   ])
						Z0Z->Z0Z_KGPRER := GetdToVal(aDados[nI, nPKgPrvRecal])
						Z0Z->Z0Z_KGCAR  := GetdToVal(aDados[nI, nPKg_Carreg ])
						Z0Z->Z0Z_DESVKG := GetdToVal(aDados[nI, nPDesvio_Kg ])
						Z0Z->Z0Z_DESCPE := GetdToVal(aDados[nI, nPDesvPerc  ])
					Z0Z->(MSUnlock())
				EndIf
			Next nI

			If !Empty( cMsg )
				MsgStop( ALLTRIM( cMsg ), "Atencao")
				DisarmTransaction()
			EndIf

		End Transaction
	EndIf
RestArea(aArea)
Return

User Function fRotZ0Z()
Local cTitulo  := "Importa��o Carregamentos - Detalhados"
Local cVldDel  := ".T."
Local cVldAlt  := ".T."
Local aRotAdic := {}

Private cAlias   := "Z0Z"

aAdd(aRotAdic, { "Importar Detalhado", "U_BIMPDT()"   , 0 , 3 })
aAdd(aRotAdic, { "Excluir por Data"  , "U_DeletZ0Z(1)", 0 , 6 })
aAdd(aRotAdic, { "Excluir por OP  "  , "U_DeletZ0Z(2)", 0 , 6 })

dbSelectArea( cAlias )
dbSetOrder(1)

AxCadastro( cAlias,;
            cTitulo,;
            cVldDel,;
            cVldAlt, ;
			aRotAdic,;
			/* bPre */, /* bOK */, /* bTTS */, /* bNoTTS */, , , ;
			/* aButtons */, , )

Return

User Function DeletZ0Z( nOpc )
Local aArea := GetArea()
Local cUpd := ""
	cUpd := " UPDATE "+RetSqlName("Z0Z")+" SET D_E_L_E_T_='*' " + CRLF
	cUpd += " WHERE  " + CRLF
		If nOpc == 1
			// ConOut("Deletar por Data")
			cUpd += " 	Z0Z_DATA = '" + dToS(Z0Z->Z0Z_DATA) + "' AND  " + CRLF
	ElseIf nOpc == 2
			// ConOut("Deletar por Ordem de Producao")
			cUpd += " 	Z0Z_ORDEM = '" + Z0Z->Z0Z_ORDEM + "' AND " + CRLF
	EndIf
	cUpd += " 	D_E_L_E_T_=' ' " + CRLF

	if (TCSqlExec(cUpd) < 0)
		Alert("TCSQLError(): " + TCSQLError())
	Else
		MsgInfo( "Todos os registros na " + iIf(nOpc == 1, "data: " + dToC(Z0Z->Z0Z_DATA), "ordem de producao nro:  " + Z0Z->Z0Z_ORDEM) + " foram excluidos com sucesso." )
	EndIf
RestArea(aArea)
Return nil
