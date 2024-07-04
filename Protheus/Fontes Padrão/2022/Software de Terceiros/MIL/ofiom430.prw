// ษออออออออหออออออออป
// บ Versao บ 109    บ
// ศออออออออสออออออออผ

#include "PROTHEUS.CH"
#INCLUDE "OFIOM430.CH"
#include "TopConn.ch"
#Include "FONT.CH"
#Include "COLORS.CH"

Static cMotCanc  := "000020" // Motivo de Cancelamento de Transfer๊ncia

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OFIOM430 ณ Autor ณ  Thiago               ณ Data ณ 29/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ 	Transferencia de Pecas                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM430(lAuto, nOpcAuto)
//
Local cFaseTransf  := GetNewPar("MV_MIL0104","") // Fase Default Conferencia/Reserva para Transferencia de Pecas ( OFIOM430 )
//
Private cTipoNota  := GetNewPar("MV_MIL0027","2")
Private cCadastro  := STR0001
Private oOk        := LoadBitmap( GetResources(), "LBOK" )
Private cFilialDe  := Space(TAMSX3("VS3_FILIAL")[1])
Private cArmaDe    := "  "
Private cFilialAte := Space(TAMSX3("VS3_FILIAL")[1])
Private cArmaAte   := "  "
Private nAceita    := 1
Private o430GetPecas
//
Private cPerg      := "OFM430"
Private oNo        := LoadBitmap( GetResources(), "LBNO" )
Private nPos       := 0
Private aItensNew  := {}
Private nLinhas    := 400
Private nUsado     := 0
Private aCols      := {} , aHeader := {} , aCpoEnchoice  := {}
Private cAliasSB1  := "SQLSB1"
Private cAliasVS3  := "SQLVS3"
Private cAliasVS3A := "SQLVS3"
Private cProdDe    := Space(TAMSX3("B1_COD")[1])
Private cProdAte   := cProdDe
Private aPecasAlt  := {}
Private cTudoOk    := ""
Private cNroOrc    := Space(TAMSX3("VS1_NUMORC")[1])
Private cFilDes    := Space(TAMSX3("VS1_FILDES")[1])
Private cArmDes    := Space(TAMSX3("VS1_ARMDES")[1])
Private dDtaOrc    := dDataBase
Private cTpoOrc    := STR0002
Private cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private cTpOper    := "  "
Private c_MV_PAR00 := ""
Private aRetorn := {}        
Private c_MV_PAR01 := ""
Private c_MV_PAR02 := ""
Private c_MV_PAR03 := ""
Private c_MV_PAR04 := ""    
Private c_MV_PAR05 := ""
Private c_MV_PAR06 := ""
Private c_MV_PAR07 := Space(TAMSX3("VS3_OPER")[1])
Private c_MV_PAR08 := ""
Private c_MV_PAR09 := Space(TAMSX3("VS1_CODBCO")[1])
Private c_MV_PAR10 := Space(TAMSX3("VS1_NATURE")[1])
Private c_MV_PAR11 := Space(TAMSX3("VS1_PGTFRE")[1])   
Private c_MV_PAR12 := Space(TAMSX3("VS3_CENCUS")[1])
Private c_MV_PAR13 := Space(TAMSX3("VS3_CONTA")[1])
Private c_MV_PAR14 := Space(TAMSX3("VS3_ITEMCT")[1])
Private c_MV_PAR15 := Space(TAMSX3("VS3_CLVL")[1])
Private c_MV_PAR16 := Space(6)
Private nQtdIni    := 0 
Private nQtdPec    := 0 
Private nTotGer    := 0 
Private nTotPec    := 0 
Private lAchou     := .f.
Private aItensSD1   := {}
Private nOpca := 1
Private cCliEnt := ""
Private cCliSai := ""
Private aRotina    := MenuDef()
Private cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4"))                                             // Fase de Conferencia e Separacao (default 4)
Private lFaseConfer := (At(cFaseConfer,IIf(!Empty(cFaseTransf),cFaseTransf,GetMv("MV_FASEORC"))) <> 0)  // Verifica a existencia da Fase de Conferencia
Private lFaseReserv := (At("R"        ,IIf(!Empty(cFaseTransf),cFaseTransf,GetMv("MV_FASEORC"))) <> 0)  // Verifica a existencia da Fase de Reserva (R)
Private cGruFor     := "04"
Default lAuto       := .F.
Private lAutoE      := lAuto
Private oLogger     := DMS_Logger():New()
Private oTransf     := DMS_Transferencia():New()
Private aDiverg     := {}
Private nMaxItNF  := GetMv("MV_NUMITEN") 

Private oPeca       := DMS_Peca():New()

Private lJDPrism    := .f.
Private lVS3_TRSFER := VS3->(FieldPos('VS3_TRSFER')) > 0
Private lVS3_QE 	:= IIf(len(FWSX3Util():GetFieldStruct( "VS3_QE")) > 0,.t., .f.) //Campo VS3_QE ้ virtual, nใo sendo possํvel utilizar fieldpos e columnpos

Private OFP8600016  := ExistFunc("OFP8600016_VerificacaoFormula")

ValidPerg()

dbSelectArea("VS1")
dbSetOrder(1) // NRO DO ORCAMENTO

aCores := {	;
	{'VS1->VS1_STATUS == "0"','BR_BRANCO'  },;	// Or็amento Digitado
	{'VS1->VS1_STATUS == "'+cFaseConfer+'"','BR_VERDE'   },;	// Aguardando conferencia
	{'VS1->VS1_STATUS == "F"','BR_PRETO'   },;	// Conferido
	{'VS1->VS1_STATUS == "X"','BR_VERMELHO'},;	// Transferido
	{'VS1->VS1_STATUS == "C"','BR_AZUL'    }}	// Cancelado

if lAuto
	Pergunte("OFM430",.F.)
	c_MV_PAR00 := "0" // Avulsa
	c_MV_PAR01 := MV_PAR01
	c_MV_PAR02 := MV_PAR02
	c_MV_PAR03 := MV_PAR03
	c_MV_PAR04 := MV_PAR04
	c_MV_PAR05 := MV_PAR05
	c_MV_PAR06 := MV_PAR06
	c_MV_PAR07 := MV_PAR07
	c_MV_PAR08 := MV_PAR08
	c_MV_PAR09 := MV_PAR09
	c_MV_PAR10 := MV_PAR10
	c_MV_PAR11 := MV_PAR11
	c_MV_PAR12 := MV_PAR12
	c_MV_PAR13 := MV_PAR13
	c_MV_PAR14 := MV_PAR14
	c_MV_PAR15 := MV_PAR15
	c_MV_PAR16 := MV_PAR16
	MBrowseAuto( nOpcAuto , , "VS1" , .f. , .t. )
else
	mBrowse( 6, 1,22,75,"VS1",,,,,,aCores,,,,,,,, " VS1_TIPORC = '3' " )
	DbSelectArea("VS1")
endIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430INCL บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incluir                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430INCL(cAlias,nReg,nOpc)
Local lMesmaFil := .t. 
Local aPerg     := {}
Local aTipTra   := X3CBOXAVET("VDD_TIPTRA","0") // {"0=Avulsa","1=Reposi็ใo","2=Devolu็ใo","3=Garantia"}
Local aRet      := {}
Local aParamBox := {}
Local cAux      := ""
Local nTam      := 0
Local nPos      := 0

lJDPrism := .f.

cFilialAte := Space(TAMSX3("VS3_FILIAL")[1])
cArmaAte   := "  "
cArmaAte   := "  "
nQtdPec    := 0 
nTotGer    := 0 
nTotPec    := 0 
c_MV_PAR00 := "0"
If len(aTipTra) > 0
	aAdd(aParamBox,{2,STR0178,"0",aTipTra,70,"",.f.}) // Tipo de Transferencia
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
		c_MV_PAR00 := aRet[01]
		cAux := GetNewPar("MV_MIL0090","") // Transferencia de Pecas entre Filiais – Relacionamento entre o Tipo Transferencia e Almoxarifado Destino
		nTam := TAMSX3("VS1_ARMDES")[1]
		cArmDes := space(nTam)
		If !Empty(cAux)
			nPos := At(c_MV_PAR00+"=",cAux)
			If nPos > 0
				cArmDes := substr(cAux+space(20),nPos+2,nTam)
			EndIf
		EndIf
	Else
		Return
	EndIf
	/////////////////////////////////////////////////
	//  Manipulando conteudo da Pergunte "OFM430"  //
	/////////////////////////////////////////////////
		Pergunte("OFM430",.f., , , , , @aPerg)     //
		MV_PAR06 := cArmDes                        //
		__SaveParam("OFM430",aPerg)                //
	/////////////////////////////////////////////////
Else
	c_MV_PAR00 := ""
EndIf
while lMesmaFil
	if !Pergunte("OFM430",.t.)
		Return(.f.)
	Endif
	if Alltrim(xFilial("SD2")) == Alltrim(MV_PAR05)
		lMesmaFil := .t.
		MsgStop(STR0086,STR0084)
	else
		lMesmaFil := .f.
	endif
enddo
c_MV_PAR01 := MV_PAR01
c_MV_PAR02 := MV_PAR02
c_MV_PAR03 := MV_PAR03
c_MV_PAR04 := MV_PAR04
c_MV_PAR05 := MV_PAR05
c_MV_PAR06 := MV_PAR06
c_MV_PAR07 := MV_PAR07
c_MV_PAR08 := MV_PAR08
c_MV_PAR09 := MV_PAR09
c_MV_PAR10 := MV_PAR10
c_MV_PAR11 := MV_PAR11
c_MV_PAR12 := MV_PAR12
c_MV_PAR13 := MV_PAR13
c_MV_PAR14 := MV_PAR14
c_MV_PAR15 := MV_PAR15
c_MV_PAR16 := MV_PAR16
Processa( { || FS_GERA()} )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GERA  บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incluir - Geracao                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GERA()

Local cGruVei  := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv  := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
Local nHeadRec := 0
Local aAuxACols := {}
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

// Data atual para inclusใo
dDtaOrc := dDataBase

// F๓rmula
if Empty(c_MV_PAR08)
	MsgInfo(STR0130)
	Return(.f.)
ElseIf OFP8600016 .And. !(OFP8600016_VerificacaoFormula(c_MV_PAR08))
	Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
Endif

// Filial Destino e Armazem Destino
if Empty(c_MV_PAR05) .or. Empty(c_MV_PAR06)
	MsgInfo(STR0013)
	Return(.f.)
Endif

// Form.Prc.Vda
if !Empty(c_MV_PAR16) .And. OFP8600016 .And. !(OFP8600016_VerificacaoFormula(c_MV_PAR16))
	Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
Endif
//
aCliForLj := oFilHlp:GetCodFor(cFilAnt, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA2->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA2")
dbSetOrder(2)

aCliForLj := oFilHlp:GetCodCli(c_Mv_Par05, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA1->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA1")
dbSetOrder(2)

RegToMemory("VS3",.T.,.T.,.f.)
M->VS1_TIPORC := "3"
M->VS1_TRFRES := "0" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
If lJDPrism
	M->VS1_TRFRES := "1" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
Else
	If VS1->(FieldPos("VS1_TRFRES")) > 0
		M->VS1_TRFRES := CriaVar("VS1_TRFRES")
		If Empty(M->VS1_TRFRES)
			M->VS1_TRFRES := "0" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
		EndIf
	EndIf
EndIf

// Isto ้ feito para manter em cache os dados de TES
cCliEnt  := SA2->A2_COD+"+"+SA2->A2_LOJA
cCliSai  := SA1->A1_COD+"+"+SA1->A1_LOJA
aEntData := StrTokArr(cCliEnt, "+")
aSaiData := StrTokArr(cCliSai, "+")
//cTESEnt  := MaTesInt(1, c_MV_PAR07, aEntData[1], aEntData[2],"C", SB1->B1_COD) // entrada
//cTESSai  := MaTesInt(2, c_MV_PAR07, aSaiData[1], aSaiData[2],"C", SB1->B1_COD) // saida
//

nOpcE := 3
nOpcG := 3
nOpc  := 3
//cLinOkP    := "FG_OBRIGAT()"
//cFieldOkP  := "FG_MEMVAR() .AND. OM430PREPEC() .AND. OM430FOK()"

MontaAHeader(3)
aAuxACols := CriaLinhaAcols(@nHeadRec)
aCols   := {}
nReg    := 0

if Empty(c_MV_PAR01) .AND. Empty(c_MV_PAR02)
	nReg += 1
	AADD( aCols , aClone(aAuxACols) )

	// Preenchimento dos valores informados nos Parโmetros
	OM4300016_PreenchimentoAutomaticoInclusao(nReg)
Else
	cQuery := "SELECT SB1.B1_GRUPO,SB1.B1_CODITE,SB1.B1_COD,SB1.B1_DESC,SB1.B1_COD,SB2.B2_CM1,SB2.B2_QATU,SB2.B2_LOCAL "
	If lVS3_QE
		cQuery += ",SB1.B1_QE "
	endif
	cQuery += "FROM " + RetSqlName( "SB1" ) + " SB1 , "+RetSqlName( "SB2" ) + " SB2 WHERE "
	cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD>='"+c_MV_PAR01+"' AND SB1.B1_COD<='"+c_MV_PAR02+"' AND SB1.B1_GRUPO<>'"+cGruVei+"' AND SB1.B1_GRUPO<>'"+cGruSrv+"' AND SB1.D_E_L_E_T_=' ' AND "
	cQuery += "SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB1.B1_COD=SB2.B2_COD AND SB2.B2_LOCAL>='"+c_MV_PAR03+"' AND SB2.B2_LOCAL<='"+c_MV_PAR04+"' AND SB2.B2_QATU>0 AND SB2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY SB1.B1_GRUPO,SB1.B1_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB1, .T., .T. )
	Do While !( cAliasSB1 )->( Eof() )
		if OFIOM43001_ArmazemValido( ( cAliasSB1 )->B2_LOCAL )

			cTESEnt  := MaTesInt(1, c_MV_PAR07, aEntData[1], aEntData[2],"F", ( cAliasSB1 )->B1_COD) // entrada
			cTESSai  := MaTesInt(2, c_MV_PAR07, aSaiData[1], aSaiData[2],"C", ( cAliasSB1 )->B1_COD) // saida

			nReg += 1
			DBSelectArea("SB1")
			DBSetOrder(7)
			DBSeek(xFilial("SB1")+( cAliasSB1 )->B1_GRUPO+( cAliasSB1 )->B1_CODITE)
			DBSelectArea("SB2")
			DBSetOrder(1)
			dbSeek(xFilial("SB2")+SB1->B1_COD+( cAliasSB1 )->B2_LOCAL)
		
			AADD( aCols , aClone(aAuxACols) )
			aCols[nReg,FG_POSVAR("VS3_GRUITE")] := ( cAliasSB1 )->B1_GRUPO
			aCols[nReg,FG_POSVAR("VS3_CODITE")] := ( cAliasSB1 )->B1_CODITE
			aCols[nReg,FG_POSVAR("VS3_DESITE")] := ( cAliasSB1 )->B1_DESC
			If lVS3_QE
				aCols[nReg,FG_POSVAR("VS3_QE")] := ( cAliasSB1 )->B1_QE
			Endif
			aCols[nReg,FG_POSVAR("VS3_QTDEST")] := SaldoSB2()
			aCols[nReg,FG_POSVAR("VS3_VALPEC")] := Fg_Formula(c_MV_PAR08)
			aCols[nReg,FG_POSVAR("VS3_TESSAI")] := cTESSai
			aCols[nReg,FG_POSVAR("VS3_TESENT")] := cTESEnt
			aCols[nReg,FG_POSVAR("VS3_ARMORI")] := ( cAliasSB1 )->B2_LOCAL

			// Preenchimento dos valores informados nos Parโmetros
			OM4300016_PreenchimentoAutomaticoInclusao(nReg)

			if nReg == 999
				MsgInfo(STR0015,STR0016)
				exit
			Endif

			dbSelectArea(cAliasSB1)
		end
		( cAliasSB1 )->(DbSkip())
	Enddo
	( cAliasSB1 )->( dbCloseArea() )
EndIf

if Empty(aCols)
	nReg += 1
	AADD( aCols , aClone(aAuxACols) )

	// Preenchimento dos valores informados nos Parโmetros
	OM4300016_PreenchimentoAutomaticoInclusao(nReg)
end

cFilDes := c_MV_PAR05
cArmDes := c_MV_PAR06
//Busca Proximo  n๚mero do Or็amento
If FindFunction( "OX001PrxNro" )
	cNroOrc := OX001PrxNro()
Else
	cNroOrc := GetSXENum("VS1","VS1_NUMORC")
	ConfirmSx8()
Endif

FS_MONTATELA(nOpc,cFilDes)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  FS_OK   บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ OK janela de Inclusao                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OK(nOpc)

Local lVS3_TIPTRA := ( VS3->(FieldPos("VS3_TIPTRA")) > 0 )
Local lVS3_VENTRA := ( VS3->(FieldPos("VS3_VENTRA")) > 0 )
Local lVS3_QTDAPR := ( VS3->(FieldPos("VS3_QTDAPR")) > 0 )
Local lVS3_MOTPED := ( VS3->(FieldPos("VS3_MOTPED")) > 0 )
Local lVS1PRISEP  := VS1->(ColumnPos("VS1_PRISEP")) > 0
Local lVS1OBSCON  := VS1->(ColumnPos("VS1_OBSCON")) > 0

Local lPEOM430GRV := ExistBlock("OM430GRV")

Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

Local ni := 0
Local i  := 0
Local y  := 0

Local aRegSD2     := {}
Local aRegSE1     := {}
Local aRegSE2     := {}
Local cTpFre      := ""
Local nAuxRec
Local nAuxRecVS1 

Local lVS1_TRFRES := ( VS1->(FieldPos("VS1_TRFRES")) > 0 )

lAchou  := .f.
lEntrou := .t.

If ExistBlock("OM430VLD")
	lRet := ExecBlock("OM430VLD",.f.,.f.)   
	if !lRet
		Return(.f.)
	Endif	
EndIf

OM4308001_RefreshJdprismVars()

// ##############################################################################
// Verifica se estourou tamanho do Acols de Pe็as para de acordo com MV_NUMITEN #
// ##############################################################################
if !FS_QTDLIN("2")
	Return(.f.)
Endif		

if nOpc == 3 // Inclusao
	lInclui := .f.
	For y := 1 to Len(aCols)
		if aCols[y,Len(aCols[y])]
			Loop
		Endif
		lInclui := .t.
		if aCols[y,FG_POSVAR("VS3_QTDINI")] > 0
			// nota precisa dos 2 TES
			if cTipoNota == "1"
				If Empty(aCols[y,FG_POSVAR("VS3_TESSAI")]) .OR. Empty(aCols[y,FG_POSVAR("VS3_TESENT")])
					MsgInfo(STR0024)
					Return(.f.)
				EndIf
			ElseIf cTipoNota == "2" .AND. Empty(aCols[y,FG_POSVAR("VS3_TESSAI")]) // pre nota s๓ saํda
				MsgInfo(STR0094)
				Return(.f.)
			Endif
		Endif

		// Verifica็ใo F๓rmula
		If aCols[y,FG_POSVAR("VS3_FORMUL")] <> ""
			If OFP8600016 .And. !(OFP8600016_VerificacaoFormula(aCols[y,FG_POSVAR("VS3_FORMUL")]))
				Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
			EndIf
		EndIf
	Next

	if !lInclui
		MsgInfo(STR0123) // Nใo hแ itens neste or็amento para realizar a transfer๊ncia
		Return(.f.)
	Endif
	For i := 1 to Len(aCols)
		if aCols[i,Len(aCols[i])]
			Loop
		Endif
		if aCols[i,FG_POSVAR("VS3_QTDINI")] > 0
			lAchou := .t.
		Endif
	Next
	if lAchou == .f.
		MsgInfo(STR0025)
		Return(.f.)
	Endif

	DbSelectArea("VAI")
	Dbsetorder(4)
	DbSeek(xFilial("VAI")+__cUserID)

	aCliForLj := oFilHlp:GetCodCli(c_MV_PAR05, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
	If !Empty(aCliForLj[1]+aCliForLj[2])
		SA1->(DbGoTo(aCliForLj[3]))
	EndIf

	Begin Transaction

	dbSelectArea("VS1")
	RecLock("VS1",.t.)
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := cNroOrc
	VS1->VS1_TIPORC := "3" // Transferencia
	VS1->VS1_DATORC := dDtaOrc
	VS1->VS1_CLIFAT := SA1->A1_COD
	VS1->VS1_LOJA   := SA1->A1_LOJA
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_STATUS := "0"
	VS1->VS1_FILDES := c_MV_PAR05
	VS1->VS1_ARMDES := c_MV_PAR06
	VS1->VS1_CODBCO := c_MV_PAR09
	VS1->VS1_NATURE := c_MV_PAR10   
	if c_MV_PAR11 == 1    
		cTpFre := "C"
	Elseif c_MV_PAR11 == 2
		cTpFre := "F"
	Elseif c_MV_PAR11 == 3
		cTpFre := "T"
	Elseif c_MV_PAR11 == 4
		cTpFre := "S"
	Endif
	VS1->VS1_PGTFRE := cTpFre
	VS1->VS1_CODVEN := VAI->VAI_CODVEN
	If lVS1_TRFRES
		VS1->VS1_TRFRES := M->VS1_TRFRES // Reservar Itens da Transferencia Automaticamente ( 0-Nao / 1-Sim )
	EndIf
	If lFaseConfer // Possui Fase de Conferencia
		If lVS1PRISEP
			VS1->VS1_PRISEP := M->VS1_PRISEP
		EndIf
		If lVS1OBSCON
			VS1->VS1_OBSCON := M->VS1_OBSCON
		EndIf
	EndIf
	MsUnlock()
	nAuxRecVS1 := VS1->(Recno())
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
	EndIf
	
	If FindFunction("FM_GerLog") //grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIF
	
	nSeq := 1
	For ni := 1 to Len(aCols)
		if aCols[ni,Len(aCols[ni])]
		   Loop
		Endif
		if aCols[ni,FG_POSVAR("VS3_QTDINI")] > 0
			dbSelectArea("VS3")
			cErrors := OFIOM43003_ValidaVS3(aCols[ni])
			if Empty( cErrors )

				N := ni
				
			    DbSelectArea("VS3")
				RecLock("VS3",.t.)
				VS3->VS3_FILIAL := xFilial("VS3")
				VS3->VS3_NUMORC := cNroOrc
				VS3->VS3_SEQUEN := strzero(nSeq,TamSX3("VS3_SEQUEN")[1])
				VS3->VS3_GRUITE := aCols[ni,FG_POSVAR("VS3_GRUITE")]
				VS3->VS3_CODITE := aCols[ni,FG_POSVAR("VS3_CODITE")]
				VS3->VS3_QTDINI := aCols[ni,FG_POSVAR("VS3_QTDINI")]
				VS3->VS3_OPER   := aCols[ni,FG_POSVAR("VS3_OPER")]
				VS3->VS3_TESSAI := aCols[ni,FG_POSVAR("VS3_TESSAI")]
				VS3->VS3_CODTES := VS3->VS3_TESSAI
				VS3->VS3_TESENT := aCols[ni,FG_POSVAR("VS3_TESENT")]
				VS3->VS3_QTDITE := aCols[ni,FG_POSVAR("VS3_QTDINI")]
				VS3->VS3_ARMORI := aCols[ni,FG_POSVAR("VS3_ARMORI")]
				VS3->VS3_LOCAL  := VS3->VS3_ARMORI
				VS3->VS3_VALPEC := aCols[ni,FG_POSVAR("VS3_VALPEC")]
				VS3->VS3_FORMUL := aCols[ni,FG_POSVAR("VS3_FORMUL")]
				VS3->VS3_CENCUS := aCols[ni,FG_POSVAR("VS3_CENCUS")]
				VS3->VS3_CONTA  := aCols[ni,FG_POSVAR("VS3_CONTA")]
				VS3->VS3_ITEMCT := aCols[ni,FG_POSVAR("VS3_ITEMCT")]
				VS3->VS3_CLVL   := aCols[ni,FG_POSVAR("VS3_CLVL")]
				VS3->VS3_VALTOT := aCols[ni,FG_POSVAR("VS3_VALTOT")]
				//
				VS3->VS3_VALPIS := aCols[ni,FG_POSVAR("VS3_VALPIS")]
				VS3->VS3_VALCOF := aCols[ni,FG_POSVAR("VS3_VALCOF")]
				VS3->VS3_ICMCAL := aCols[ni,FG_POSVAR("VS3_ICMCAL")]
				VS3->VS3_VALCMP := aCols[ni,FG_POSVAR("VS3_VALCMP")]
				VS3->VS3_DIFAL  := aCols[ni,FG_POSVAR("VS3_DIFAL" )]
				VS3->VS3_VICMSB := aCols[ni,FG_POSVAR("VS3_VICMSB")]
				If !Empty(VS3->VS3_CODTES)
					VS3->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL") // Nao mostra na tela - buscar do Fiscal
					VS3->VS3_BICMSB := MaFisRet(n,"IT_BASESOL") // Nao mostra na tela - buscar do Fiscal
				EndIf
				//
				If lVS3_TIPTRA
					VS3->VS3_TIPTRA := c_MV_PAR00
				EndIf
				If lVS3_VENTRA
					VS3->VS3_VENTRA := VS1->VS1_CODVEN
				EndIf
				If lVS3_QTDAPR
					VS3->VS3_QTDAPR := aCols[ni,FG_POSVAR("VS3_QTDINI")]
				EndIf

				If !Empty(VS3->VS3_CODTES) .and.;
					VS3->(FieldPos("VS3_IPITRF")) > 0 .and.;
					MaFisRet(n,"IT_VALIPI") > 0

					SB1->(DbSetOrder(7))
					SB1->(DbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ))
					
					VS3->VS3_IPITRF := Fg_Formula(c_MV_PAR16) * VS3->VS3_QTDINI

				EndIf

				MsUnlock()

				If lPEOM430GRV
					ExecBlock("OM430GRV",.f.,.f.,{ nOpc , aCols[ni] , VS3->(RecNo()) }) // Ponto de Entrada apos a grava็ใo do VS3
				EndIf

			Else
				aEval( aCols , { |x| x[FG_POSVAR("VS3_REC_WT")] := 0 } ) // Volta RECNO dos VS3
				Help(" ",1,"OM430ARMORI",,cErrors,1,1 ) // O armaz้m de origem do item estแ indisponํvel, pois o mesmo ้ utilizado como armaz้m de Reserva ou Oficina. Item: 
				DisarmTransaction()
				Return .F.
			EndIf
			nSeq += 1
		Endif
	Next
	If M->VS1_TRFRES == "1" // Reservar Itens da Transferencia Automaticamente ( 0-Nao / 1-Sim )
		If !OM430RESITE(.t.,.t.)
			aEval( aCols , { |x| x[FG_POSVAR("VS3_REC_WT")] := 0 } ) // Volta RECNO dos VS3
			DisarmTransaction()
			Return .f.
		EndIf
	EndIf

	End Transaction

	if inclui
		if ExistBlock("OM430DGV")
			ExecBlock("OM430DGV",.f.,.f.)
		Endif
		MsgInfo(STR0026+VS1->VS1_NUMORC+STR0027)
		lAchou := .t.
	Endif
Elseif nOpc == 4 // Alteracao
	lAltera := .f.
	nAuxRecVS1 := VS1->(Recno())

	For y := 1 to Len(aCols)
		if aCols[y,Len(aCols[y])]
			Loop
		Endif   
		if aCols[y,FG_POSVAR("VS3_QTDINI")]  > 0  //aCols[y,6] > 0
			// nota precisa dos 2 TT
			if cTipoNota == "1"
			 	If Empty(aCols[y,FG_POSVAR("VS3_TESSAI")]) .OR. Empty(aCols[y,FG_POSVAR("VS3_TESENT")])
					MsgInfo(STR0024)
					Return(.f.)
				EndIf
			ElseIf cTipoNota == "2" .AND. Empty(aCols[y,FG_POSVAR("VS3_TESSAI")]) // pre nota s๓ saํda
				MsgInfo(STR0094)
				Return(.f.)
			Endif
			lAltera := .t.
		Endif

		// Verifica็ใo F๓rmula
		If aCols[y,FG_POSVAR("VS3_FORMUL")] <> ""
			If OFP8600016 .And. !(OFP8600016_VerificacaoFormula(aCols[y,FG_POSVAR("VS3_FORMUL")]))
				Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
			EndIf
		EndIf
	Next
	if !lAltera 
		MsgInfo(STR0123) // Nใo hแ itens neste or็amento para realizar a transfer๊ncia
		Return(.f.)
	Endif
	
	lAltera := .f.
	For i := 1 to Len(aCols)
		dbSelectArea("VS3")
		dbSetOrder(1)
		
		nAuxRec := aCols[i,FG_POSVAR("VS3_REC_WT")]
		
		if nAuxRec > 0
			dbgoto( nAuxRec )
			If aCols[i,LEN(aCols[i])] .or. aCols[i,FG_POSVAR("VS3_QTDINI")] == 0 //Deletado ou Quantidade zerada
				// delecao do vs3...
				if VS3->VS3_QTDRES > 0
					// desreserva
					If oTransf:Desreserva( VS3->(recno()) , 0 )
						OX001VE6(VS3->VS3_NUMORC, .f.)
					else
						Return .f.
					Endif
				endIf
				RecLock("VS3",.f., .t.)
				DbDelete()
				MsUnlock()
				Loop
			EndIf
		Else
			If aCols[i,LEN(aCols[i])] // Deletado
				Loop
			EndIf
		EndIf
		cErrors := OFIOM43003_ValidaVS3( aCols[i] )
		DbSelectArea("VS3")
		If Empty( cErrors )
			If nAuxRec <> 0
				RecLock("VS3", .f.)
			Else
				RecLock("VS3",.t.)
				VS3->VS3_FILIAL := xFilial("VS3")
				VS3->VS3_NUMORC := VS1->VS1_NUMORC
			EndIf
		Else
			Help(" ",1,"OM430ARMORI",,cErrors,1,1 ) // O armaz้m de origem do item estแ indisponํvel, pois o mesmo ้ utilizado como armaz้m de Reserva ou Oficina. Item: 
			return .f.
		Endif

		VS3->VS3_SEQUEN := strzero(i,TamSX3("VS3_SEQUEN")[1])
		VS3->VS3_GRUITE := aCols[i,FG_POSVAR("VS3_GRUITE")]
		VS3->VS3_CODITE := aCols[i,FG_POSVAR("VS3_CODITE")]
		VS3->VS3_QTDINI := aCols[i,FG_POSVAR("VS3_QTDINI")]
		VS3->VS3_OPER   := aCols[i,FG_POSVAR("VS3_OPER")]
		VS3->VS3_TESSAI := aCols[i,FG_POSVAR("VS3_TESSAI")]
		VS3->VS3_CODTES := VS3->VS3_TESSAI
		VS3->VS3_TESENT := aCols[i,FG_POSVAR("VS3_TESENT")]
		VS3->VS3_QTDITE := aCols[i,FG_POSVAR("VS3_QTDINI")]
		VS3->VS3_ARMORI := aCols[i,FG_POSVAR("VS3_ARMORI")]
		VS3->VS3_LOCAL  := VS3->VS3_ARMORI
		VS3->VS3_VALPEC := aCols[i,FG_POSVAR("VS3_VALPEC")]
		VS3->VS3_FORMUL := aCols[i,FG_POSVAR("VS3_FORMUL")]
		VS3->VS3_CENCUS := aCols[i,FG_POSVAR("VS3_CENCUS")]
		VS3->VS3_CONTA  := aCols[i,FG_POSVAR("VS3_CONTA")]
		VS3->VS3_ITEMCT := aCols[i,FG_POSVAR("VS3_ITEMCT")]
		VS3->VS3_CLVL   := aCols[i,FG_POSVAR("VS3_CLVL")]
		VS3->VS3_VALTOT := aCols[i,FG_POSVAR("VS3_VALTOT")]
		//
		VS3->VS3_VALPIS := aCols[i,FG_POSVAR("VS3_VALPIS")]
		VS3->VS3_VALCOF := aCols[i,FG_POSVAR("VS3_VALCOF")]
		VS3->VS3_ICMCAL := aCols[i,FG_POSVAR("VS3_ICMCAL")]
		VS3->VS3_VALCMP := aCols[i,FG_POSVAR("VS3_VALCMP")]
		VS3->VS3_DIFAL  := aCols[i,FG_POSVAR("VS3_DIFAL" )]
		VS3->VS3_VICMSB := aCols[i,FG_POSVAR("VS3_VICMSB")]
		If !Empty(VS3->VS3_CODTES)
			VS3->VS3_PICMSB := MaFisRet(i,"IT_ALIQSOL") // Nao mostra na tela - buscar do Fiscal
			VS3->VS3_BICMSB := MaFisRet(i,"IT_BASESOL") // Nao mostra na tela - buscar do Fiscal
		EndIf
		//
		If lVS3_TIPTRA
			VS3->VS3_TIPTRA := c_MV_PAR00
		EndIf
		If lVS3_VENTRA
			VS3->VS3_VENTRA := VS1->VS1_CODVEN
		EndIf
		If lVS3_QTDAPR
			VS3->VS3_QTDAPR := aCols[i,FG_POSVAR("VS3_QTDINI")]
		EndIf
		//
		if lVS3_TRSFER
			If M->VS1_TRFRES == "1" .or. lJDPrism
				VS3->VS3_TRSFER := "1"
			Else
				VS3->VS3_TRSFER := "0"
			Endif
		Endif

		If !Empty(VS3->VS3_CODTES) .and.;
			VS3->(FieldPos("VS3_IPITRF")) > 0 .and.;
			MaFisRet(n,"IT_VALIPI") > 0

			SB1->(DbSetOrder(7))
			SB1->(DbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ))
			
			VS3->VS3_IPITRF := Fg_Formula(c_MV_PAR16) * VS3->VS3_QTDINI

		EndIf
		//
		VS3->(MsUnlock())

		If lPEOM430GRV
			ExecBlock("OM430GRV",.f.,.f.,{ nOpc , aCols[i] , VS3->(RecNo()) }) // Ponto de Entrada apos a grava็ใo do VS3
		EndIf

		Begin Transaction
			// Faz o ajuste da reserva caso a quantidade tenha sido alterada pelo usuแrio
			If lVS1_TRFRES .and. VS1->VS1_TRFRES <> M->VS1_TRFRES
				DbSelectArea("VS1")
				RecLock("VS1",.f.)
					VS1->VS1_TRFRES := M->VS1_TRFRES
				MsUnLock()
			EndIf
			if M->VS1_TRFRES == "1" .or. lJDPrism // Reserva Itens da Transferencia automaticamente ?  ou  JD PRISM ?
				if VS3->VS3_QTDITE != VS3->VS3_QTDRES // alterou quantidade e tem reserva? reserva precisa ser atualizada
					If oTransf:AjustaRes( VS3->(recno()) )
						OX001VE6(VS3->VS3_NUMORC, .t.)
					else
						DisarmTransaction()
						Return .f.
					Endif
				endIf
			EndIf
		End Transaction

		lAltera := .t.
	Next
	if !lAltera 
		MsgInfo(STR0123) // Nใo hแ itens neste or็amento para realizar a transfer๊ncia
		Return(.f.)
	Endif
	if altera
		DbSelectArea("VS1")
		DbGoto(nAuxRecVS1)
		If lFaseConfer // Possui Fase de Conferencia
			RecLock("VS1",.f.)
			If lVS1PRISEP
				VS1->VS1_PRISEP := M->VS1_PRISEP
			EndIf
			If lVS1OBSCON
				VS1->VS1_OBSCON := M->VS1_OBSCON
			EndIf
			MsUnLock()
		EndIf
		if ExistBlock("OM430DGV")
			ExecBlock("OM430DGV",.f.,.f.)
		Endif
		MsgInfo(STR0056) // Altera็ใo realizada com sucesso
	Endif
Elseif nOpc == 5 //Cancelamento

	if VS1->VS1_STATUS == "X" .and. !MsgYesNo(STR0068) // "Orcamento ja transferido tem certeza que deseja cancelar a nota fiscal de Entrada/Saida?"
		Return .f.
	EndIf
	
	OM430CANTRANSF()
		
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIF
	
Else
	oDlg1:End()
Endif

If (nOpc == 3 .or. nOpc == 4)
	// Ponto de entrada para validar se o Or็amento gerado deve seguir para confer๊ncia/transfer๊ncia ou nใo
	If ExistBlock("OM430AVA")
		lRet := ExecBlock("OM430AVA", .f., .f.)
		If !lRet
			Return .t. // Retornar .t. para fechar a janela automaticamente, mantendo assim a funcionalidade padrใo
		EndIf
	EndIf

	If MsgYesNo(IIf(lFaseConfer,STR0129,STR0124)) // "Deseja avan็ar or็amento para confer๊ncia ?" / "Deseja transferir or็amento ?"
		VS1->(dbGoTo(nAuxRecVS1))
		If M->VS1_TRFRES <> "1" .and. !lJDPrism // Se nao ้ Reserva de Itens automatica  e  Nใo ้ JD PRISM
			If lFaseReserv .and. MsgYesNo(STR0125) // Existe a Fase de Reserva  e  Pergunta se "Deseja reservar pe็as ?"
				If !OM430RESITE(.t.,.t.)
					DisarmTransaction()
					Return .f.
				Endif
				If lVS1_TRFRES
					DBSelectArea("VS1")
					RecLock("VS1",.f.)
						VS1->VS1_TRFRES := "1" // Reserva Automatica
					VS1->(MsUnLock())
				EndIf
			EndIf
		EndIf
		DBSelectArea("VS1")
		RecLock("VS1",.f.)
		If lFaseConfer
			VS1->VS1_STATUS := cFaseConfer // Aguardando conferencia
		Else
			VS1->VS1_STATUS := "F" // Pronto para Transferir
		Endif
		VS1->(MsUnLock())
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
		EndIf
		If VS1->VS1_STATUS == cFaseConfer // Foi para Fase de Conferencia
			If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
				OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , VS1->VS1_NUMORC ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso nใo exista o registro
			EndIf
		EndIf
	EndIf

EndIf

Return(.t.)


/*/{Protheus.doc} OM430CANTRANSF
Cancela transferencia de Pe็as
@type function
@author Rubens
@since 10/12/2015
@version 1.0
/*/
Static Function OM430CANTRANSF()

Local cFornece := ""
Local cLojaFor := ""
Local cNumPed  := ""
Local aOrcRecno := {}
Local cNumOrcs := ""
Local nRetPerg := 0
Local ni := 0
Local lNFeCancel  := (SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0)
Local aMotCancel  := {}

If VS1->VS1_STATUS == "X" .and. !OM430VCANTRANSF(VS1->VS1_SERNFI , VS1->VS1_NUMNFI , VS1->VS1_FILDES , @cFornece , @cLojaFor)
	Return .f.
EndIf

Begin Transaction

	If lNFeCancel .and. VS1->VS1_STATUS == "X"
		If !OM430CNFSAIDA( VS1->VS1_SERNFI, VS1->VS1_NUMNFI , VS1->VS1_CLIFAT , VS1->VS1_LOJA , @cNumPed, lNFeCancel )
			DisarmTransaction()
			Return(.f.)
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Motivo do Cancelamento do Transfer๊ncia  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aMotCancel := OFA210MOT(cMotCanc,"4",xFilial("VS1"),VS1->VS1_NUMORC,.T.)
	If Len(aMotCancel) == 0 
		DisarmTransaction()
		Return(.f.)
	EndIf
	cMotCancVS1 := aMotCancel[1]

	// Nota fiscal jแ foi gerada 
	If VS1->VS1_STATUS == "X"

		
		cQuery := "SELECT VS1.R_E_C_N_O_ VS1RECNO, VS1.VS1_NUMORC FROM "+RETSQLNAME("VS1")+" VS1 WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1.VS1_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND "
		cQuery += "VS1.VS1_SERNFI = '"+VS1->VS1_SERNFI+"' AND VS1.VS1_CLIFAT = '"+VS1->VS1_CLIFAT+"' AND VS1.VS1_LOJA = '"+VS1->VS1_LOJA +"' AND VS1.D_E_L_E_T_ = ' ' "
		TcQuery cQuery New Alias "TMPVS1"
		
		While !TMPVS1->(Eof())
			aAdd(aOrcRecno,TMPVS1->(VS1RECNO))
			cNumOrcs += TMPVS1->(VS1_NUMORC) +"/"
			TMPVS1->(DbSkip())
		EndDo
		TMPVS1->(DbCloseArea())
		
		If Len(aOrcRecno) > 1			
			nRetPerg := Aviso(STR0084,STR0143+CHR(13) + CHR(10) +;
								STR0144+CHR(13) + CHR(10)+;
								cNumOrcs,;
								{STR0145, STR0146},3 )
			If nRetPerg == 1 .or. nRetPerg == 0
				DisarmTransaction()
				Return(.f.)
			EndIf
		EndIf
			
		// Cancela Nota Fiscal de Saida 
		If !lNFeCancel .and. !OM430CNFSAIDA( VS1->VS1_SERNFI, VS1->VS1_NUMNFI , VS1->VS1_CLIFAT , VS1->VS1_LOJA , @cNumPed, lNFeCancel )
			DisarmTransaction()
			Return(.f.)
		EndIf
		
		lMsErroAuto := .F.
		OM430CPEDV( cNumPed ) // Cancela Pedido de Venda
		If lMsErroAuto
			if lAutoE
				oLogger:LogSysErr("OFIOM430.log")
			else
				MostraErro()
			endIf
			lMostraErro	:=.T.
			DisarmTransaction()
			Return(.f.)
		EndIf
		
		// Cancela Nota Fiscal de Entrada da Filial de Destino ...
		If !OM430CNFENTRADA( VS1->VS1_SERNFI , VS1->VS1_NUMNFI , VS1->VS1_FILDES , cFornece , cLojaFor )
			DisarmTransaction()
			RollBAckSx8()
			if lAutoE
				oLogger:LogSysErr("OFIOM430.log")
			else
				MostraErro()
			endIf
			lMostraErro	:=.T.
			Return(.f.)
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Motivo do Cancelamento do Transfer๊ncia  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While Len(aMotCancel) == 0
			aMotCancel := OFA210MOT(cMotCanc,"4",xFilial("VS1"),VS1->VS1_NUMORC,.T.)
		EndDo
		cMotCancVS1 := aMotCancel[1]
	
		For ni := 1 to Len(aOrcRecno)
			VS1->(DbGoTo(aOrcRecno[ni]))
			RecLock("VS1",.f.)
			VS1->VS1_STATUS := "C"
			VS1->VS1_MOTIVO := cMotCancVS1
			MsUnlock()
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
			EndIf
		Next
		
	Else

		If VS1->VS1_STARES $ "12" .and. !OM430RESITE(.f., .t.)
			DisarmTransaction()
			Return .f.
		EndIf
		dbSelectArea("VS1")
		RecLock("VS1",.f.)
		VS1->VS1_STATUS := "C"
		VS1->VS1_MOTIVO := cMotCancVS1
		MsUnlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
		EndIf

	Endif

	// Ponto de entrada depois da gravacao do processo de Cancelamento do Or็amento de Transfer๊ncia
	if ExistBlock("OM430DCA")
		If !ExecBlock("OM430DCA",.f.,.f.)
			DisarmTransaction()
			Return .f.
		Endif
	Endif

End Transaction
	
Return

/*/{Protheus.doc} OM430VCANTRANSF
Verifica se ้ possํvel cancelar transferencia de pe็as
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cSerie, character, (Descri็ใo do parโmetro)
@param cNota, character, (Descri็ใo do parโmetro)
@param cFilDestino, character, (Descri็ใo do parโmetro)
@param cFornece, character, (Descri็ใo do parโmetro)
@param cLojaFor, character, (Descri็ใo do parโmetro)
@return logico, Indica se ้ possํvel cancelar transferencia
/*/
Static Function OM430VCANTRANSF(cSerie, cNota, cFilDestino, cFornece, cLojaFor)

Local lRetorno := .t.
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}
Local cBkpFil := cFilAnt

aCliForLj := oFilHlp:GetCodFor(cFilAnt, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA2->(DbGoTo(aCliForLj[3]))
Else
	lRetorno := .f.
EndIf
dbSelectArea("SA2")
dbSetOrder(2)

If lRetorno

	cFornece := SA2->A2_COD
	cLojaFor := SA2->A2_LOJA

	cFilAnt := cFilDestino
	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+VS1->VS1_NUMNFI+VS1->VS1_SERNFI+SA2->A2_COD+SA2->A2_LOJA)
	if !Empty(SF1->F1_STATUS)
		MsgStop(STR0069,STR0070)
		lRetorno := .f.
	Endif
	cFilAnt := cBkpFil

EndIf

Return lRetorno

	
/*/{Protheus.doc} OM430CNFSAIDA
Rotina responsแvel por cancelar a nota fiscal de saida da transferencia da peca
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cSerie, character, (Descri็ใo do parโmetro)
@param cDoc, character, (Descri็ใo do parโmetro)
@param cFatPar, character, (Descri็ใo do parโmetro)
@param cLoja  , character, (Descri็ใo do parโmetro)
@param cNumPed, character, (Descri็ใo do parโmetro)
@param lNFeCancel, booleano, Indica se o cancelamento sera pelo Totvs Colaboracao 
@return logico, Indica se foi possํvel excluir nota fiscal de saida da peca
/*/
Static Function OM430CNFSAIDA( cSerie, cDoc, cFatPar, cLoja, cNumPed, lNFeCancel )

Local aRegSD2     := {}
Local aRegSE1     := {}
Local aRegSE2     := {}

dbSelectArea("SF2")
dbSetOrder(1)
If dbSeek( xFilial("SF2") + cDoc + cSerie )

	If lNFeCancel .and. FGX_STATF2("D",cSerie,cDoc,SF2->F2_CLIENTE,SF2->F2_LOJA,"S") // verifica se NF foi Deletada
		Return .t.
	EndIf
	if Empty(cFatPar)   
		cFatPar := SF2->F2_CLIENTE
		cLoja   := SF2->F2_LOJA
	Endif 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o estorno do documento de saํda pode ser feito     ณ    
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SD2")
dbSetOrder(3)
If DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE )
	cNumPed := SD2->D2_PEDIDO
Endif

If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
	/*Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2, Array com os registro do SE1, Array com os registro do SE2 ) */
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Estorna o documento de saida                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PERGUNTE("MTA521",.f.)
	If lNFeCancel
		If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
			Return .f.
		EndIf
	Else
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
	EndIf
Else
	Return(.f.)
EndIf

If lNFeCancel .and. !FGX_STATF2("V",cSerie,cDoc,cFatPar,cLoja,"S") /// Verifica STATUS da NF no SEFAZ
	Return .f.
EndIf


Return .t.

/*/{Protheus.doc} OM430CPEDV
Rotina responsแvel por cancelar o pedido de venda que gerou a nota fiscal de transferencia
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cNumPed, character, (Descri็ใo do parโmetro)
@return logico, Indica se foi possํvel excluir nota fiscal de saida da peca
/*/
Static Function OM430CPEDV( cNumPed )

dbSelectArea("SC5")
dbSetOrder(1)
if dbSeek(xFilial("SC5")+cNumPed)
	aMata410Cab   := {{"C5_NUM"      , cNumPed,Nil}}   //Numero do pedido SC5
	aMata410Itens := {{"C6_NUM"      , cNumPed,Nil}}   //Numero do Pedido SC6
	//Exclui Pedido
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9")+cNumPed))
	While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
Endif

Return .t.

/*/{Protheus.doc} OM430CNFENTRADA
Rotina responsแvel por cancelar nota fiscal de entrada
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cSerie, character, (Descri็ใo do parโmetro)
@param cNota, character, (Descri็ใo do parโmetro)
@param cFilDestino, character, (Descri็ใo do parโmetro)
@param cFornece, character, (Descri็ใo do parโmetro)
@param cLojaFor, character, (Descri็ใo do parโmetro)
@return logico, Indica se foi possํvel excluir nota fiscal de saida da peca
/*/
Static Function OM430CNFENTRADA(cSerie, cNota, cFilDestino, cFornece, cLojaFor)

Local cBkpFil := cFilAnt

cFilAnt := cFilDestino

dbSelectArea("SF1")
dbSetOrder(1)
If !dbSeek(xFilial("SF1")+cNota+cSerie+cFornece+cLojaFor)
	cFilAnt := cBkpFil
	Return .t. // Se estiver DELETADA ้ que ja foi cancelada pela rotina de Compras
EndIf
If !Empty(SF1->F1_STATUS)
	Return .f.
EndIf
// Cabecalho da nota fiscal de entrada
aCabec   := {}
aadd(aCabec,{"F1_TIPO"   	,SF1->F1_TIPO})
aadd(aCabec,{"F1_FORMUL" 	,SF1->F1_FORMUL})
aadd(aCabec,{"F1_DOC"    	,SF1->F1_DOC})
aadd(aCabec,{"F1_SERIE"  	,SF1->F1_SERIE})
aadd(aCabec,{"F1_EMISSAO"	,SF1->F1_EMISSAO})
aadd(aCabec,{"F1_FORNECE"	,SF1->F1_FORNECE})
aadd(aCabec,{"F1_LOJA"   	,SF1->F1_LOJA})
aadd(aCabec,{"F1_ESPECIE"	,SF1->F1_ESPECIE})
aadd(aCabec,{"F1_COND"		,SF1->F1_COND})
aadd(aCabec,{"F1_EST"		,SF1->F1_EST})
// Itens da nota fiscal de entrada
aLinha   := {}
aItens   := {}
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
While !Eof() .And. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	// Incrementa regua de processamento
	IncProc()
	if !Empty(SD1->D1_TES)
		RecLock("SD1",.f.)
		SD1->D1_TES := ""
		MsUnlock()
	Endif
	aadd(aLinha,{"D1_ITEM"	,SD1->D1_ITEM,Nil})
	aadd(aLinha,{"D1_COD"	,SD1->D1_COD,Nil})
	aadd(aLinha,{"D1_QUANT"	,SD1->D1_QUANT,Nil})
	aadd(aLinha,{"D1_VUNIT"	,SD1->D1_VUNIT,Nil})
	aadd(aLinha,{"D1_TOTAL"	,SD1->D1_TOTAL,Nil})
	//-- Pesquisa armazem destino
	aadd(aLinha,{"D1_LOCAL"	,SD1->D1_LOCAL	,Nil})
	aadd(aLinha,{"D1_GRADE",SD1->D1_GRADE,Nil})
	aadd(aLinha,{"D1_ITEMGRD",SD1->D1_ITEMGRD,Nil})
	aadd(aLinha,{"D1_TES","",Nil})
	aadd(aItens,aLinha)
	dbSelectArea("SD1")
	dbSkip()
Enddo
// Caso tenha itens e cabecalho definidos
If Len(aItens) > 0 .And. Len(aCabec) > 0
	// Exclui
	MATA140(aCabec,aItens,5)
EndIf
//
cFilAnt := cBkpFil
// Checa erro de rotina automatica
If lMsErroAuto
	Return .f.
EndIf

Return .t. 

/* 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430LEG บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda do Browse                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430LEG()

Local aLegenda := {;
	{'BR_BRANCO'  ,STR0126},;
	{'BR_VERDE'   ,STR0028},;
	{'BR_PRETO'   ,STR0029},;
	{'BR_VERMELHO',STR0030},;
	{'BR_AZUL'    ,STR0031}}

BrwLegenda(cCadastro,STR0012 ,aLegenda) //Legenda

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430LibFecบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Conferencia de Orcamento                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430LibFec()
if VS1->VS1_STATUS == "F"
	MsgStop(STR0032)
	Return(.f.)
Endif
if VS1->VS1_STATUS == "C"
	MsgStop(STR0033)
	Return(.f.)
Endif
if VS1->VS1_STATUS == "X"
	MsgStop(STR0034)
	Return(.f.)
Endif
OFIXX002(VS1->VS1_NUMORC) // Chamar Tela de Conferencia
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430GeraNFบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera NF Fiscal                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430GeraNF()
Local aParam   	:= {}
Local y        	:= 0
Local cFornece 	:= ""
Local cLojaFor 	:= ""
Local cCliente 	:= ""
Local cLojaCli 	:= ""
Local cPrefBAL 	:= GetNewPar("MV_PREFBAL","BAL")
Local cAliasSE1	:= "SqlSE1"
Local cQuery   	:= ""    
Local nPos 		:= 0
Local i 			:= 0
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

if VS1->VS1_STATUS == "X"
	MsgInfo(STR0035)
	Return(.f.)
Endif
if VS1->VS1_STATUS == "C"
	MsgInfo(STR0033)
	Return(.f.)
Endif
if VS1->VS1_STATUS <> "F"
	MsgInfo(STR0036)
	Return(.f.)
Endif
c_MV_PAR05 := VS1->VS1_FILDES
c_MV_PAR06 := VS1->VS1_ARMDES
c_MV_PAR11 := VS1->VS1_PGTFRE

if lFaseConfer
	If !FS_DIVERG(VS1->VS1_NUMORC) // Monta tela de divergencia
		Return .f.
	EndIf
Endif
cQuery := "SELECT VS3.VS3_NUMORC , VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_ARMORI , VS3.VS3_QTDINI , "
cQuery += 		" VS3.VS3_NUMLOT , VS3.VS3_LOTECT , VS3.VS3_OPER   , VS3.VS3_TESSAI , VS3.VS3_TESENT , "
cQuery += 		" VS3.VS3_VALPEC , VS3.VS3_FORMUL , VS3.VS3_QTDCON , VS3.VS3_QTDITE , VS3.R_E_C_N_O_ VS3RECNO , "
cQuery += 		" VS3.VS3_NUMORC , VS3.VS3_CENCUS , VS3.VS3_CONTA  , VS3.VS3_ITEMCT , VS3.VS3_CLVL "

If VS3->(FieldPos("VS3_IPITRF")) > 0
	cQuery += ", VS3.VS3_IPITRF "
EndIf

cQuery += "FROM "+RetSqlName("VS3")+" VS3 "
cQuery += "WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"' AND VS3.VS3_NUMORC='"+VS1->VS1_NUMORC+"' AND VS3.D_E_L_E_T_=' ' ORDER BY VS3.VS3_NUMORC"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
aItens := {}
	
Do While !( cAliasVS3 )->( Eof() )
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+( cAliasVS3 )->VS3_GRUITE+( cAliasVS3 )->VS3_CODITE)
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+SB1->B1_COD+( cAliasVS3 )->VS3_ARMORI)       
	nQtdIni := ( cAliasVS3 )->VS3_QTDITE	
	nPos := aScan(aItens,{|x| x[1]+x[2]+x[6]+x[15]+x[16] == ( cAliasVS3 )->VS3_GRUITE+( cAliasVS3 )->VS3_CODITE + SB2->B2_LOCAL + ( cAliasVS3 )->VS3_LOTECT+( cAliasVS3 )->VS3_NUMLOT})
	If nPos > 0
		aItens[nPos,9] += nQtdIni
	Else
		nValPec := ( cAliasVS3 )->VS3_VALPEC
		If nValPec == 0
			nValPec := SB2->B2_CM1
		EndIf
		aadd(aItens,{	( cAliasVS3 )->VS3_GRUITE,;
						( cAliasVS3 )->VS3_CODITE,;
						SB1->B1_DESC,;
						SaldoSB2(),;
						FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"),;
						SB2->B2_LOCAL,;
						0,;
						SB1->B1_COD,;
						nQtdIni,;
						( cAliasVS3 )->VS3_OPER,;
						( cAliasVS3 )->VS3_TESENT,;
						( cAliasVS3 )->VS3_TESSAI,;
						.F.,;
						nValPec,;
						( cAliasVS3 )->VS3_LOTECT,;
						( cAliasVS3 )->VS3_NUMLOT,;
						( cAliasVS3 )->VS3RECNO,;
						( cAliasVS3 )->VS3_NUMORC,;
						( cAliasVS3 )->VS3_CENCUS,;
						( cAliasVS3 )->VS3_CONTA,;
						( cAliasVS3 )->VS3_ITEMCT,;
						( cAliasVS3 )->VS3_CLVL,;
						If( VS3->(FieldPos("VS3_IPITRF")) > 0, ( cAliasVS3 )->VS3_IPITRF, "")})
	Endif
	dbSelectArea(cAliasVS3)
	( cAliasVS3 )->(DbSkip())
Enddo
( cAliasVS3 )->( dbCloseArea() )

aCliForLj := oFilHlp:GetCodFor(cFilAnt, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA2->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA2")
dbSetOrder(2)

cFornece := SA2->A2_COD
cLojaFor := SA2->A2_LOJA

aCliForLj := oFilHlp:GetCodCli(c_Mv_Par05, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA1->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA1")
dbSetOrder(2)

cCliente := SA1->A1_COD
cLojaCli := SA1->A1_LOJA

lPerg := CriaParam(aItens,"0")
if !lPerg
	MsgInfo(STR0041,STR0047)
	Return .F.
Endif

For i := 1 to Len(aRetorn)
	AAdd(aParam,aRetorn[i])
Next

cLocalizSai := GetMv("MV_RESLOC")
aItensNew := {}
For y := 1 to Len(aItens)  
	AADD(aItensNew,{aItens[y,2],;
					aItens[y,8],;
					IIf(LOCALIZA(aItens[y,2]),cLocalizSai,Space(15)),;
					aItens[y,9],;
					0,;
					VS1->VS1_FILDES,;
					IIf(LOCALIZA(aItens[y,2]),cLocalizSai,Space(15)),;
					cCliente,;
					cLojaCli,;
					cFornece,;
					cLojaFor,;
					"",;
					"",;
					"",;
					"",;
					"",;
					aItens[y,11],;
					VS1->VS1_ARMDES,;
					,;
					aItens[y,12],;
					aItens[y,14],;
					VS1->VS1_CODVEN,;
					aItens[y,6],;
					aItens[y,15],;
					aItens[y,16],;
					aItens[y,17],;
					aItens[y,18],;
					aItens[y,19],;
					aItens[y,20],;
					aItens[y,21],;
					aItens[y,22],;
					aItens[y,23]})
Next
lRet := FS_GERATRANS(@aItensNew,@aParam)
If lRet
	//		MsgInfo("Movimenta็ใo efetuada com sucesso" + Chr(13) + Chr(13) + "Da Filial : "+aItens[nLinha,2] + Chr(13)+ "Para Filial : "+cFilialAte+ Chr(13) +"Notas Saida/Serie : "+cNumNotaFis+" "+cSerisFis+ Chr(13)+"Notas de Entrada/Serie :"+cNumNotaFis+" "+cSerisFis+ Chr(13)+"",STR0084)
	if ! lAutoE
		MsgInfo(STR0040)
	endIf
	dbSelectArea("VS1")
	RecLock("VS1",.f.)
	VS1->VS1_STATUS := "X"
	VS1->VS1_NUMNFI := SF2->F2_DOC
	VS1->VS1_SERNFI := SF2->F2_SERIE
	MsUnlock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
	EndIf
    
	DBSelectArea("SF2")
	reclock("SF2",.f.)
	cPrefAnt := SF2->F2_PREFIXO
	SF2->F2_PREFORI := cPrefBAL
	cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
	SF2->F2_PREFIXO := cPrefNF
	msunlock()

	If !Empty(SF2->F2_DUPL)
		cQuery    := "SELECT SE1.R_E_C_N_O_ RECSE1 "
		cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
		cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO = '"+cPrefAnt+"' AND SE1.E1_NUM = '"+SF2->F2_DUPL+"' AND  "
		cQuery    += "SE1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
		While ( cAliasSE1 )->(!Eof())
			DbSelectArea("SE1")
			DbGoTo(( cAliasSE1 )->RECSE1)
			RecLock("SE1",.f.)
				SE1->E1_PREFIXO := SF2->F2_PREFIXO
				SE1->E1_PREFORI := SF2->F2_PREFORI
			msunlock()
			( cAliasSE1 )->(DbSkip())
		Enddo
		( cAliasSE1 )->( dbCloseArea() )
	EndIf

	dbSelectArea("VS1")

	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIF
	
Endif
//
If ExistBlock("OM430FIM")
	ExecBlock("OM430FIM",.f.,.f.,{lRet})   
EndIf
//
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GERATRANSบAutor  ณThiago            บ Data ณ  29/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTransferi os produto dos armazens (botใo de Transferir      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GERATRANS(aDadosTransf,aParam040,lMultOrc,aOrcTrf)
// Variavel com a filial origem

// Array com os parametros do programa
Local aParam460     := Array(30)
Local cPedido       := ""
Local cWhile        := ""
Local cNotaFeita    := ""
Local cPedidos      := ""
Local cSeekD1       := ""
Local aPvlNfs       := {}
Local aBloqueio     := {{"","","","","","","",""}}
Local aNotas        := {}
Local aDadosAux     := {}
Local nItemNf       := 0
Local nSaveSX8      := 0
Local nAchoSerie    := 0
Local nPrcVen       := 0
Local nPosLocal     := 0      
Local ii            := 0 
Local i_			:= 0
Local nBloqueio     := 0
Local ni            := 1
Local nx            := 1
Local nZ            := 1
Local aSeries       := {}
Local nTamSD2	    := TamSX3("D2_DOC")[1]
Local lRet		    := .T.
Local aParam	    := {}
Local aNotaFeita    := {} // Array com notas geradas
Local lESTNEG       := (GetMV("MV_ESTNEG") == "S")
// Variaveis para rotina automatica
Local lMostraErro   := .F.
Local lReferencia   := .F.
Local cGrade        := "N"
Local aColsAux      := {}
Local nItGrd        := 0
Local aBackItens	:= {}
Local aBackCabec	:= {}
Local aLinha		:= {}
Local cTesIntE      := ""
Local cTesIntS      := ""
Local cMsgSC9       := ""
Local cRasFilDes    := ""
Local cNumIte       := "00"
Local cTpFre        := ""
Local lF1_FILORIG   := ( SF1->(FieldPos("F1_FILORIG")) > 0 )
Local lF2_FILDEST   := ( SF2->(FieldPos("F2_FILDEST")) > 0 )
Local nModBkp
Local cModBkp
Local cFilOri       := cFilAnt
Local oLogTrf       := DMS_Logger():New("OFIOM430_"+Dtos(Date()) + ".LOG")

Private cSerie      := ""
Private cNumero     := ""
// Variavel utilizada para verificar se o numero da nota foi alterado pelo usuario (notas de saida e entrada com formulario proprio).
Private lMudouNum   := .F.
//Private lContinua   := .T.
Private aCabec      := {}
Private aItens      := {}

Default lMultOrc := .f.
Default aOrcTrf  := {}

// Verifica se o array esta vazio
If Empty(aDadosTransf)
	Aviso(STR0042,STR0043,{STR0044}) //"Nใo existe nenhuma tranferencia de materiais pendente a ser executada."
EndIf

///// Verifica se hแ rastreabiluidade na Filial Destino
cFilant := aDadosTransf[1,6]
cRasFilDes := Left(GetMv("MV_RASTRO"),1) <> "S"
cFilant := cFilOri
//
ni := 1
// Obtem serie para as notas desta filial
cSerie  := ""
cNumero := ""

if ! lAutoE
	Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),cFilAnt)
	// Caso tenha selecionado numero
	If Empty(cNumero) .and. Empty(cSerie) 
		MsgStop(STR0081)
		Return(.f.)
	Endif
	cNumero := PADR(cNumero,TamSX3("F1_DOC")[1])
	AADD(aSeries,{cFilAnt,cSerie,cNumero})
else
	cSerie := GetNewPar("MV_MIL0085", "1 ")
	AADD(aSeries,{cFilAnt,cSerie,""})
EndIf  

oLogTrf:Log( { '_________' } )
oLogTrf:Log( { 'TIMESTAMP' , "1. Inicio do Processo de Transfer๊ncia" } )
oLogTrf:Log( { 'TIMESTAMP' , "1. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )

//
/////					cFilant:=xFilial("SB2")
// Serie para geracao da nota
/////					cSerie:=aSeries[nAchoSerie,2]
// Cabecalho do pedido
//cPedido := CriaVar("C5_NUM")
//aadd(aCabec,{"C5_NUM",cPedido,Nil})
aadd(aCabec,{"C5_TIPO"	,"N",Nil})
aadd(aCabec,{"C5_CLIENTE",aDadosTransf[ni,8],Nil})
aadd(aCabec,{"C5_LOJACLI",aDadosTransf[ni,9],Nil})
aadd(aCabec,{"C5_LOJAENT",aDadosTransf[ni,9],Nil})
aadd(aCabec,{"C5_CONDPAG",Iif(!Empty(aParam040[01]),aParam040[01],RetCondVei()),Nil})
aadd(aCabec,{"C5_VEND1",aDadosTransf[ni,22],Nil})
aAdd(aCabec,{"C5_TIPOCLI",SA1->A1_TIPO ,Nil}) // Tipo do Cliente
If SC5->(FieldPos("C5_INDPRES")) > 0 
	aAdd(aCabec,{"C5_INDPRES"  ,'0'	,Nil}) 	// Presenca do Comprador
Endif
aAdd(aCabec, {"C5_TRANSP" , MV_PAR02  	, Nil})
aAdd(aCabec, {"C5_PESOL"  , MV_PAR03    , Nil})
aAdd(aCabec, {"C5_PBRUTO" , MV_PAR04    , Nil})
aAdd(aCabec, {"C5_VEICULO", MV_PAR05    , Nil})
aAdd(aCabec, {"C5_VOLUME1", MV_PAR06    , Nil})
aAdd(aCabec, {"C5_VOLUME2", MV_PAR07    , Nil})
aAdd(aCabec, {"C5_VOLUME3", MV_PAR08    , Nil})
aAdd(aCabec, {"C5_VOLUME4", MV_PAR09    , Nil})
aAdd(aCabec, {"C5_ESPECI1", MV_PAR10    , Nil})
aAdd(aCabec, {"C5_ESPECI2", MV_PAR11    , Nil})
aAdd(aCabec, {"C5_ESPECI3", MV_PAR12    , Nil})
aAdd(aCabec, {"C5_ESPECI4", MV_PAR13    , Nil})
if EMPTY(VS1->VS1_NATURE)
	aAdd(aCabec, {"C5_NATUREZ", c_MV_PAR10  , Nil})
else
	aAdd(aCabec, {"C5_NATUREZ", VS1->VS1_NATURE , Nil})
endif
if EMPTY(VS1->VS1_CODBCO)
	aAdd(aCabec, {"C5_BANCO"  , c_MV_PAR09  , Nil})
else
	aAdd(aCabec, {"C5_BANCO"  , VS1->VS1_CODBCO , Nil})
endif
aAdd(aCabec, {"C5_MENPAD" , MV_PAR14    , Nil})
aAdd(aCabec, {"C5_MENNOTA", MV_PAR15    , Nil})

/*if c_MV_PAR11 == 1    
	cTpFre := "C"
Elseif c_MV_PAR11 == 2
	cTpFre := "F"
Elseif c_MV_PAR11 == 3
	cTpFre := "T"
Elseif c_MV_PAR11 == 4
	cTpFre := "S"
Endif
aadd(aCabec, {"C5_TPFRETE" ,cTpFre  , Nil})
*/
aadd(aCabec, {"C5_TPFRETE" ,c_MV_PAR11  , Nil})

nItGrd:=0
// ATENCAO - VARIAVEL CRIADAS POR CAUSA DA QUEBRA NO FATURAMENTO
aNotaFeita:={}
//					ni:=len(aDadosTransf)
nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDadosTransf[ni,2],"B1_CUSTD")
//
SC9->(dbSelectArea("SC9"))
SC9->(dbSetOrder(1))
//
SC6->(dbSelectArea("SC6"))
SC6->(dbSetOrder(1))
//
SB1->(dbSelectArea("SB1"))
SB1->(dbSetOrder(1))
//
VS3->(dbSelectArea("VS3"))
VS3->(dbSetOrder(2))
//
While .T.
	// Processamento das Transferencias
	if lAutoE
		Pergunte("MT460A",.F.)
	else
		if ! Pergunte("MT460A",.T.)
			MsgInfo(STR0041,STR0047)
			Return .F.
		endIf
	endIf


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta regua de processamento                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcRegua(Len(aDadosTransf)*2)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processa geracao de documentos de saida                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega parametros do programa                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nx := 1 to 30
		aParam460[nx] := &("mv_par"+StrZero(nx,2))
	Next nx
	// Sorteia array para aglutinar por filial origem e destino
	ASORT(aDadosTransf,,,{|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] })
	
	// Variavel para rotina automatica
	lMsErroAuto := .F.
	// Array auxiliar
	aDadosAux   := {}
	// Atualiza para a filial origem
	//		cFilant:=xFilial("SB2")
	// Array para geracao de notas
	aNotas   := {}
	// Arrays com itens e bloqueios
	aPvlNfs  := {}
	aBloqueio:= {}
	// Cabecalho do pedido
	aCabecPC:={}
	aItensPC:={}
	// Variavel que controla numeracao
	nSaveSX8 := GetSx8Len()
	// Variavel para processamento
	cWhile:=aDadosTransf[ni,1]+aDadosTransf[ni,6]
	// Obtem serie para as notas desta filial
	nAchoSerie:=ASCAN(aSeries,{|x| x[1] == cFilAnt})
	// Caso tenha selecionado serie para esta filial
	Begin Transaction
	If nAchoSerie > 0

		// Estorna reserva para faturamento ...
		If !lMultOrc
			oLogTrf:Log( { 'TIMESTAMP' , "1.1 Inicio da transicao - Antes do OM430RESITE - MultOrc Falso" } )
			oLogTrf:Log( { 'TIMESTAMP' , "1.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt+" - Status Reserva: "+VS1->VS1_STARES } )

			If VS1->VS1_STARES $ "12"
				if !OM430RESITE(.f., .t.,oLogTrf)
					DisarmTransaction()
					oLogTrf:Log( { 'TIMESTAMP' , "1.1 Disarme causado por Retorno Falso do OM430RESITE - MultOrc Falso" } )
					oLogTrf:Log( { 'TIMESTAMP' , "1.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
					Return .f.
				EndIf
			EndIf
		Else
			For ni := 1 to Len(aOrcTrf)
				If aOrcTrf[ni,1]
					VS1->(DbGoTo(aOrcTrf[ni,5]))
					oLogTrf:Log( { 'TIMESTAMP' , "1.2 Inicio da transicao - Antes do OM430RESITE - MultOrc Verdadeiro" } )
					oLogTrf:Log( { 'TIMESTAMP' , "1.2 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt+" - Status Reserva: "+VS1->VS1_STARES } )
					If VS1->VS1_STARES $ "12"
						if !OM430RESITE(.f., .t.,oLogTrf)
							DisarmTransaction()
							oLogTrf:Log( { 'TIMESTAMP' , "1.2 Disarme causado por Retorno Falso do OM430RESITE - MultOrc Verdadeiro" } )
							oLogTrf:Log( { 'TIMESTAMP' , "1.2 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
							Return .f.
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		//

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//|Gerando pedido de compra da filial destino  |
		//ณInformacoes do cabecalho do pedido de compraณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SB1->(dbSelectArea("SB1"))
		SB1->(dbSetOrder(1))
		//
		SB2->(dbSelectArea("SB2"))
		SB2->(dbSetOrder(1))
		//
		SF1->(dbSelectArea("SF1"))
		SF1->(dbSetOrder(1))
		For ni := 1 to Len(aDadosTransf)
			
			SB1->(dbSeek(xFilial("SB1")+aDadosTransf[ni,2]))
			SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+aDadosTransf[ni,23]) )
			nPrcVen:=aDadosTransf[ni,21]// SB2->B2_CM1
			
			If nPrcVen > 0
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//|FINAL DA GERAวรO DO PEDIDO DE COMPRA		   |
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				lMsErroAuto := .F.
				// Verifica se Numero e serie jแ foram cadastrados
				If SF1->(MsSeek(aDadosTransf[ni,06]+aSeries[nAchoSerie,3]+aSeries[nAchoSerie,2]+aDadosTransf[ni,10]+aDadosTransf[ni,11]))
					Aviso(STR0046,STR0045,{STR0044}) //"A numera็ใo informada para esta transferencia jแ possui um documento registrado com a mesma numera็ใo, favor informar uma nova numera็ใo. "
					RollBAckSx8()
					DisarmTransaction()
					oLogTrf:Log( { 'TIMESTAMP' , "1.3 Disarme causado por Duplicidade na SF1, na verifica็ใo anterior เ chamada do Pedido de Vendas (MATA410)" } )
					oLogTrf:Log( { 'TIMESTAMP' , "1.3 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
					Return .F.
				EndIf
				
				cNumNotaFis  := aSeries[nAchoSerie,3]
				cSerisFis    := aSeries[nAchoSerie,2]
				
				// Senao encontrou nenhum valor assume 1
				If nPrcVen <= 0
					nPrcVen := 1
				EndIf
				if ExistBlock("OFM430TES")
					cTesIntS := ExecBlock("OFM430TES",.f.,.f.,{"S"})
				Else
					cTesIntS := aDadosTransf[ni,20]
				Endif

				cNumIte := SOMA1(cNumIte)

				aLinha := {}
				aadd(aLinha,{"C6_ITEM"   	,cNumIte								,Nil})
				aadd(aLinha,{"C6_PRODUTO"	,aDadosTransf[ni,2]						,Nil})
				aadd(aLinha,{"C6_LOCAL"  	,aDadosTransf[ni,23]  					,Nil})
				aadd(aLinha,{"C6_QTDVEN" 	,aDadosTransf[ni,4]						,Nil})
				aadd(aLinha,{"C6_PRCVEN"	,A410Arred(nPrcVen,"C6_PRCVEN")			,Nil})
				aadd(aLinha,{"C6_PRUNIT" 	,A410Arred(nPrcVen,"C6_PRUNIT")			,Nil})
				aadd(aLinha,{"C6_VALOR"  	,A410Arred((aDadosTransf[ni,4]*A410Arred(nPrcVen,"C6_PRUNIT")),"C6_VALOR"),Nil})
				//aadd(aLinha,{"C6_QTDLIB" 	,aDadosTransf[ni,4]						,Nil})
				aadd(aLinha,{"C6_QTDLIB" 	,0                            ,Nil})
				aadd(aLinha,{"C6_TES"   	,Alltrim(cTesIntS)						,Nil})  
				aAdd(aLinha,{"C6_LOTECTL" ,aDadosTransf[ni,24]        		,Nil})
				aAdd(aLinha,{"C6_NUMLOTE" ,aDadosTransf[ni,25]       		,Nil})			
				If SC6->(FieldPos("C6_CC"))>0 .and. (VS3->(FieldPos("VS3_CENCUS"))>0 .and. !Empty(aDadosTransf[ni,28]) )
					aAdd(aLinha,{"C6_CC" , aDadosTransf[ni,28] , Nil})
				Endif
				If SC6->(FieldPos("C6_CONTA"))>0 .and. (VS3->(FieldPos("VS3_CONTA"))>0 .and. !Empty(aDadosTransf[ni,29]) )
					aAdd(aLinha,{"C6_CONTA" , aDadosTransf[ni,29] , Nil})
				Endif
				If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. (VS3->(FieldPos("VS3_ITEMCT"))>0 .and. !Empty(aDadosTransf[ni,30]) )
					aAdd(aLinha,{"C6_ITEMCTA" , aDadosTransf[ni,30] , Nil})
				Endif
				If SC6->(FieldPos("C6_CLVL"))>0 .and. (VS3->(FieldPos("VS3_CLVL"))>0 .and. !Empty(aDadosTransf[ni,31]) )
					aAdd(aLinha,{"C6_CLVL" , aDadosTransf[ni,31] , Nil})
				Endif
				
				If VS3->(FieldPos("VS3_IPITRF")) > 0 .and. !Empty(aDadosTransf[ni,32])
					aadd(aLinha, {"C6_IPITRF"	,A410Arred(aDadosTransf[ni,32],"C6_IPITRF")         ,Nil})
				EndIf
				
				aadd(aItens,aLinha)
			Else
				cMsgSC9 := STR0091 + SB1->B1_DESC + STR0092 + SB1->B1_COD + STR0093 + CHR(13) + CHR(10)
			Endif
		Next

		If !Empty(cMsgSC9)
			MsgStop(cMsgSC9)
			cMsgSC9 := ""
			RollBAckSx8()
			DisarmTransaction()
			oLogTrf:Log( { 'TIMESTAMP' , "1.4 Disarme causado por problemas no Pre็o de Venda da Pe็a "+SB1->B1_COD+" "+SB1->B1_DESC } )
			oLogTrf:Log( { 'TIMESTAMP' , "1.4 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
			Return .F.
		EndIf
		
		If nPrcVen > 0 .AND. Empty(cMsgSC9)
			
			if ExistBlock("OM430APV")		
				ExecBlock("OM430APV",.f.,.f.)
			Endif

			oLogTrf:Log( { 'TIMESTAMP' , "2. Antes da Cria็ใo do Pedido de Vendas" } )
			oLogTrf:Log( { 'TIMESTAMP' , "2. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt } )

			// Inclusao do pedido
			MATA410(aCabec,aItens,3)
			// Checa erro de rotina automatica
			If lMsErroAuto
				if lAutoE
					oLogger:LogSysErr("OFIOM430.log")
				else
					MostraErro()
				endIf
				RollBAckSx8()
				lMostraErro	:=.T.
				DisarmTransaction()
				oLogTrf:Log( { 'TIMESTAMP' , "2.1 Disarme causado por problemas no Execauto do MATA410" } )
				oLogTrf:Log( { 'TIMESTAMP' , "2.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
				lRet := .F.
				//						Exit
			Else

				oLogTrf:Log( { 'TIMESTAMP' , "3. Ap๓s a Cria็ใo do Pedido de Vendas" } )
				oLogTrf:Log( { 'TIMESTAMP' , "3. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt } )
				
				lMsErroAuto := .F.
				
				//################################################################
				//# Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade      #
				//################################################################
				cNumPed := SC5->C5_NUM
				//

				lCredito := .t.
				lEstoque := .t.
				lLiber   := .t.
				lTransf  := .f.
				cMsgSC9  := ""

				SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
				While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM

					If !SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
						nQtdLib := SC6->C6_QTDVEN
						nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
						if SC6->C6_QTDVEN != nQtdLib .AND. !lESTNEG
							// altera VS3
							SB1->(dbSeek( xFilial("SB1") + SC6->C6_PRODUTO ))

//							nPosVS3 := aScan(aDadosTransf,{|x| x[2]+x[20]+cValToChar(x[4])+cValToChar(x[21]) == SC6->C6_PRODUTO+SC6->C6_TES+cValToChar(SC6->C6_QTDVEN)+cValToChar(SC6->C6_PRCVEN)})
							nPosVS3 := aScan(aDadosTransf,{|x| x[2]+x[20]+x[24]+x[25] == SC6->C6_PRODUTO+SC6->C6_TES+SC6->C6_LOTECTL+SC6->C6_NUMLOTE})// Retirado quantidade do ascan porque pode ter caso de transferencias parciais que a quantidade nao ้ igual
							If aDadosTransf[nPosVS3,21] <> SC6->C6_PRCVEN
								For ii := nPosVS3 to len(aDadosTransf)
									If (aDadosTransf[ii,2]+aDadosTransf[ii,20]+aDadosTransf[ii,24]+aDadosTransf[ii,25] == SC6->C6_PRODUTO+SC6->C6_TES+SC6->C6_LOTECTL+SC6->C6_NUMLOTE) .and. (ABS(aDadosTransf[ii,21] - SC6->C6_PRCVEN) < 0.05)
									 	nPosVS3 := ii
									 	exit
									Endif
								Next
							Endif
															
							VS3->(DbGoTo(aDadosTransf[nPosVS3,26]))
							RecLock("VS3", .F.)
							VS3->VS3_QTDINI := nQtdLib
							VS3->(MsUnlock())
							
							// quantidade em estoque , atende parcialmente o pedido
							cMsgSC9 += AllTrim(RetTitle("C6_PRODUTO"))+": "+Alltrim(SC6->C6_PRODUTO)+" - "+AllTrim(RetTitle("C6_BLEST"))+": " ;
								+ STR0087 + AllTrim(STR(SC6->C6_QTDVEN)) + STR0088 + AllTrim(STR(nQtdLib)) + CHR(13) + CHR(10)
						EndIf
					EndIf

					SC6->(dbSkip())
				Enddo

				if ! Empty(cMsgSC9) .AND. !lESTNEG
					cMsgSC9 := STR0089 + CHR(13) + CHR(10) + cMsgSC9
					// deseja fazer transferencia parcial?
					if ! MsgYesNo( cMsgSC9 + CHR(13) + CHR(10) + STR0090 , STR0016 ) 
						RollBAckSx8()
						DisarmTransaction()
						oLogTrf:Log( { 'TIMESTAMP' , "3.1 Disarme causado por problemas na Libera็ใo do Pedido de Vendas (MaLibDoFat)" } )
						oLogTrf:Log( { 'TIMESTAMP' , "3.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
						Return .F.
					EndIf
				EndIf
				
				cMsgSC9 := ""
				
				//################################################################
				//# Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade      #
				//################################################################

				cNumPed := SC5->C5_NUM
				//
				aPvlNfs := {}
				SB1->(dbSetOrder(1))
				SC5->(dbSetOrder(1))
				SC5->(MsSeek(xFilial("SC5")+cNumPed))
				//
				SC6->(dbSetOrder(1))
				SB5->(dbSetOrder(1))
				SB2->(dbSetOrder(1))
				SF4->(dbSetOrder(1))
				SE4->(dbSetOrder(1))
				SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))

				//
				While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
					If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
						SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
						SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
						SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
						SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
						SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
						SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
						SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
						nPrcVen := SC9->C9_PRCVEN
						If ( SC5->C5_MOEDA <> 1 )
							nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
						EndIf
						Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							nPrcVen,;
							SC9->C9_PRODUTO,;
							.F.,;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo()) } )

					Else
						If !Empty(SC9->C9_BLCRED)
							cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO")) + ": " + Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13) + CHR(10)
						EndIf
						If !Empty(SC9->C9_BLEST)
							cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO")) + ": " + Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13) + CHR(10)
						EndIf
					EndIf
					//
					SC9->(dbSkip())
				EndDo
				//
				If !Empty(cMsgSC9)
					DisarmTransaction()
					RollBAckSx8() // pra nao perder numera็ใo no pedido
					MsgStop(STR0046+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9) // Existem um ou mais item do pedido de venda (SC5) que nใo foram liberado! / Atencao
					oLogTrf:Log( { 'TIMESTAMP' , "3.2 Disarme causado por problemas na Libera็ใo de Cr้dito/Estoque Pedidos!" } )
					oLogTrf:Log( { 'TIMESTAMP' , "3.2 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
					Return(.f.)
				EndIf
       
				If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) // Verifica SC5 bloqueado
					DisarmTransaction()
					RollBAckSx8() // pra nao perder numera็ใo no pedido
					oLogTrf:Log( { 'TIMESTAMP' , "3.2 Disarme causado por problemas na cria็ใo do aPvlNfs (estแ vazio)" } )
					oLogTrf:Log( { 'TIMESTAMP' , "3.2 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
					Return(.f.)
				EndIf

				If Len(aPvlNfs) > 0 .AND. Empty(cMsgSC9)
					nItemNf  := a460NumIt(cSerie)
					aadd(aNotas,{})
					// Efetua as quebras de acordo com o numero de itens
					For nX := 1 To Len(aPvlNfs)
						If Len(aNotas[Len(aNotas)])>=nItemNf
							aadd(aNotas,{})
						EndIf
						aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
					Next nX
					// Gera as notas de acordo com a quebra
	
					oLogTrf:Log( { 'TIMESTAMP' , "4. Inํcio da Gera็ใo da NF (MaPvlNfs)" } )
					oLogTrf:Log( { 'TIMESTAMP' , "4. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt+" - "+time()+" - Pedido: "+SC5->C5_NUM } )

					For nX := 1 To Len(aNotas)
//						dbSelectArea('CLN')
						nModBkp := nModulo
						cModBkp := cModulo
						nModulo := 5
						cModulo := "FAT"
						cNotaFeita := MaPvlNfs(aNotas[nX],cSerie,aParam460[01]==1,aParam460[02]==1,aParam460[03]==1,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[16]==1,aParam460[16]==2)
						nModulo := nModBkp
						cModulo := cModBkp
						If lMsErroauto
							DisarmTransaction()
							RollbackSx8()
							MsUnlockAll()
							if lAutoE
								MostraErro(ALLTRIM(" \system\logsmil\ "), "erros_xfer.log")
							else
								MostraErro()
							endIf
							oLogTrf:Log( { 'TIMESTAMP' , "4.1 Disarme causado por problemas na cria็ใo do gera็ใo da NF "+aNotaFeita[nx]+"/"+cSerie } )
							oLogTrf:Log( { 'TIMESTAMP' , "4.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
							Return(.f.)
						else
							AADD(aNotaFeita,PADR(cNotaFeita,nTamSD2))
							oLogTrf:Log( { 'TIMESTAMP' , "5. Gera็ใo da NF de Saํda (MaPvlNfs)" } )
							oLogTrf:Log( { 'TIMESTAMP' , "5. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt+" - "+time()+" - Pedido: "+SC5->C5_NUM+" - Nro NF: "+PADR(cNotaFeita,nTamSD2) } )
						EndIf
					Next nX

					// Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
					For nx:=1 to Len(aNotaFeita)
						aColsAux:={}
						//
						aNotaFeita[nx] := PadR(aNotaFeita[nx],TamSX3("D2_DOC")[1])
						//
						cNotaEntrada := aNotaFeita[nx]
						cNotasSaida  := aNotaFeita[nx]
						nItem	     :=0
						nItGrd	     :=0
						
						If lF2_FILDEST
							dbSelectArea("SF2")
							dbSetOrder(1)
							If dbSeek(xFilial("SF2")+aNotaFeita[nx]+cSerie) .and. Empty(SF2->F2_FILDEST)
								RecLock("SF2",.f.)
									SF2->F2_FILDEST := aDadosTransf[1,6] // Filial de Destino
								MsUnLock()
							EndIf
						EndIf
						
						dbSelectArea("SD2")
						dbSetOrder(3)
						If dbSeek(xFilial("SD2")+aNotaFeita[nx]+cSerie+aDadosTransf[1,8]+aDadosTransf[1,9])
							
							if VDD->(FieldPos("VDD_FILIAL")) > 0
								If !lMultOrc
									DBSelectArea("VDD")
									DBSetOrder(5)
									if DBSeek(xFilial("VDD")+VS1->VS1_FILIAL+VS1->VS1_NUMORC)
										While !eof() .and. VDD->VDD_FILIAL+VDD->VDD_FILPED+VDD->VDD_ORCFOR == xFilial("VDD")+VS1->VS1_FILIAL+VS1->VS1_NUMORC
								   		reclock("VDD",.f.)
											VDD->VDD_NUMNFI := aNotaFeita[nx]
											VDD->VDD_SERNFI := cSerie
											VDD->VDD_CODFOR :=aDadosTransf[1,10]
											VDD->VDD_LOJA   :=aDadosTransf[1,11]
											VDD->VDD_STATUS := "E"
											msunlock()            
											DbSkip()
										Enddo
									Endif
								Else
									DBSelectArea("VDD")
									DBSetOrder(5)
									For ni := 1 to Len(aOrcTrf)
										If aOrcTrf[ni,1]
											VS1->(DbGoTo(aOrcTrf[ni,5]))
											if VDD->(DBSeek(xFilial("VDD")+VS1->VS1_FILIAL+VS1->VS1_NUMORC))
												While !eof() .and. VDD->VDD_FILIAL+VDD->VDD_FILPED+VDD->VDD_ORCFOR == xFilial("VDD")+VS1->VS1_FILIAL+VS1->VS1_NUMORC
										   		reclock("VDD",.f.)
													VDD->VDD_NUMNFI := aNotaFeita[nx]
													VDD->VDD_SERNFI := cSerie
													VDD->VDD_CODFOR :=aDadosTransf[1,10]
													VDD->VDD_LOJA   :=aDadosTransf[1,11]
													VDD->VDD_STATUS := "E"
													msunlock()            
													DbSkip()
												Enddo
											endif
										EndIf
									Next
								EndIf
							endif

							DBSelectArea("SA2")
							DBSetOrder(1)
							DBSeek(xFilial("SA2")+aDadosTransf[1,10]+aDadosTransf[1,11])
							
							dbSelectArea("SD2")
							
							// Cabecalho da nota fiscal de entrada
							aCabec   := {}
							aadd(aCabec,{"F1_TIPO"   	,"N"})
							aadd(aCabec,{"F1_FORMUL" 	,"N"})
							aadd(aCabec,{"F1_DOC"    	,aNotaFeita[nx]})
							aadd(aCabec,{"F1_SERIE"  	,cSerie})
							aadd(aCabec,{"F1_EMISSAO"	,dDataBase})
							aadd(aCabec,{"F1_FORNECE"	,aDadosTransf[1,10]})
							aadd(aCabec,{"F1_LOJA"   	,aDadosTransf[1,11]})
							aadd(aCabec,{"F1_ESPECIE"	,"SPED"})
							aadd(aCabec,{"F1_COND"		,aParam040[01]})
							aadd(aCabec,{"F1_EST"		,SA2->A2_EST}) // Altera็ao realizada pois estava gravando incorretamente quando transferencia entre estado - MAQNELSON
							// Itens da nota fiscal de entrada
							aItens   := {}
							While !Eof() .And. xFilial("SD2")+aNotaFeita[nx]+cSerie+aDadosTransf[1,8]+aDadosTransf[1,9] == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
								// Incrementa regua de processamento
								IncProc()
								SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))

								nPosVS3 := aScan(aDadosTransf,{|x| x[2]+x[20]+x[24]+x[25] == SD2->D2_COD+SD2->D2_TES+SD2->D2_LOTECTL+SD2->D2_NUMLOTE}) // Retirado quantidade do ascan porque pode ter caso de transferencias parciais que a quantidade nao ้ igual
                                                              
								If aDadosTransf[nPosVS3,21] <> SD2->D2_PRUNIT
									For ii := nPosVS3 to len(aDadosTransf)
										If (aDadosTransf[ii,2]+aDadosTransf[ii,20]+aDadosTransf[ii,24]+aDadosTransf[ii,25] == SD2->D2_COD+SD2->D2_TES+SD2->D2_LOTECTL+SD2->D2_NUMLOTE) .and. (ABS(aDadosTransf[ii,21] - SD2->D2_PRUNIT) < 0.05)
										 	nPosVS3 := ii
										 	exit
										Endif
									Next
								Endif
								
								cGrade   := "N"
								aLinha   :=  {}
								cProdRef := SD2->D2_COD
								lReferencia:=MatGrdPrrf(@cProdRef,.T.)
								If lReferencia
									nAchou:=AScan(aColsAux,{|x|x[1]==cProdRef.and. x[2]==aDadosTransf[ni,7]})
									If nAchou >0
										nItem:=AcolsAux[nAchou,3]
										nItgrd ++
									Else
										nItem++
										nItgrd:=1
										aadd(aColsAux,{cProdRef,aDadosTransf[ni,7],nItem,nItGrd})
									Endif
									cGrade:="S"
								Else
									nItem++
								Endif
								if ExistBlock("OFM430TES")
									cTesIntE := ExecBlock("OFM430TES",.f.,.f.,{"E"})
								Else
									cTesIntE := aDadosTransf[nPosVS3,17]//VS3->VS3_TESENT
								Endif 
								
								If Empty(aDadosTransf[nPosVS3,18]) // LOCAL EM BRANCO
									DbSelectArea("CBJ")
									DbSetOrder(1)
									DbSeek(aDadosTransf[nPosVS3,6]+SD2->D2_COD)
									If !Empty(CBJ->CBJ_ARMAZ)
										aDadosTransf[nPosVS3,18] := CBJ->CBJ_ARMAZ
									Else
										cFilAnt := aDadosTransf[nPosVS3,6] 
										DbSelectArea("SB1")
										DbSetOrder(1)
										DbSeek(xFilial("SB1")+SD2->D2_COD)
										aDadosTransf[nPosVS3,18] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
										cFilAnt := cFilOri 
									EndIf
								EndIf
								
								aadd(aLinha,{"D1_ITEM"	,Strzero(nItem,Len(SD1->D1_ITEM)),Nil})
								aadd(aLinha,{"D1_COD"	,SD2->D2_COD,Nil})
								aadd(aLinha,{"D1_QUANT"	,SD2->D2_QUANT,Nil})
								aadd(aLinha,{"D1_VUNIT"	,SD2->D2_PRCVEN,Nil})
								aadd(aLinha,{"D1_TOTAL"	,SD2->D2_TOTAL,Nil})
								//-- Pesquisa armazem destino
								nPosLocal := Ascan(aDadosAux,{|x| x[1]+x[2] == SD2->D2_PEDIDO+SD2->D2_ITEMPV})
								aadd(aLinha,{"D1_LOCAL"	,aDadosTransf[nPosVS3,18]	,Nil})
								aadd(aLinha,{"D1_GRADE",cGrade,Nil})
								aadd(aLinha,{"D1_ITEMGRD",IIf(cGrade=="S",Strzero(nItGrd,2)," "),Nil})
								
								if cTipoNota == "2"
									aadd(aLinha,{"D1_TESACLA",Alltrim(cTesIntE),Nil})
								Else
									aadd(aLinha,{"D1_TES",Alltrim(cTesIntE),Nil})
								EndIf
								
								// Checa se utiliza rastreabilidade
								If Rastro(SD2->D2_COD,"L") .and. !cRasFilDes
									aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf
								If Rastro(SD2->D2_COD,"S") .and. !cRasFilDes
									aadd(aLinha,{"D1_NUMLOTE",SD2->D2_NUMLOTE,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf

								If SFT->(DbSeek(xFilial("SFT") + "S" + SD2->D2_SERIE + SD2->D2_DOC + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_ITEM ) )

									If !Empty(SFT->FT_VSTANT)
										aadd(aLinha,{"D1_ICMNDES",SFT->FT_VSTANT,Nil})
										aadd(aLinha,{"D1_BASNDES",SFT->FT_BSTANT,Nil})
										aadd(aLinha,{"D1_ALQNDES",SFT->FT_PSTANT,Nil})
									Endif

								Endif

								aadd(aItens,aLinha)
								dbSelectArea("SD2")
								dbSkip()
							End
							
							// Caso tenha itens e cabecalho definidos
							If Len(aItens) > 0 .And. Len(aCabec) > 0
								// Atualiza para a filial destino
								cFilant := aDadosTransf[1,6]
								// Reinicializa ambiente para o fiscal
								If MaFisFound()
									MaFisEnd()
								EndIf

								oLogTrf:Log( { 'TIMESTAMP' , "6. Inicio da Chamada da Gera็ใo da NF / PreNF de Entrada" } )
								oLogTrf:Log( { 'TIMESTAMP' , "6. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt+" - "+time()+" - Nro NF: "+aNotaFeita[nx] } )

								// Checa geracao de documento   
								If cTipoNota == "1"
									// Inclui nota de entrada
									MATA103(aCabec,aItens,3)
								Else
									// Inclui pre-nota
									SetFunName("MATA140I")  
									lParam := .f.
									if GETMV("MV_PCNFE") == .T.
										PutMv("MV_PCNFE",".F.")
										lParam := .t.
									Endif
									MATA140(aCabec,aItens,3)
									if lParam
										PutMv("MV_PCNFE",".T.")
									Endif	
									SetFunName("OFIOM430")
								EndIf

								// Ponto de entrada depois da gravacao da nota fiscal de entrada ou da pre-nota.
								aItensSD1 := aClone(aDadosTransf)
								if ExistBlock("OM430DPG")
									ExecBlock("OM430DPG",.f.,.f.)
								Endif
								
								// Checa erro de rotina automatica
								If lMsErroAuto
									lMostraErro	:=.T.
									RollBAckSx8()
									DisarmTransaction()
									oLogTrf:Log( { 'TIMESTAMP' , "6.1 Disarme causado por problemas na gera็ใo da NF de Entrada "+aNotaFeita[nx]+"/"+cSerie } )
									oLogTrf:Log( { 'TIMESTAMP' , "6.1 Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt } )
								EndIf
								
								If lF1_FILORIG
									dbSelectArea("SF1")
									dbSetOrder(1)
									If dbSeek(xFilial("SF1")+aNotaFeita[nx]+cSerie+aDadosTransf[1,10]+aDadosTransf[1,11]) .and. Empty(SF1->F1_FILORIG)
										RecLock("SF1",.f.)
											SF1->F1_FILORIG := cFilOri // Filial de Origem
										MsUnLock()
									EndIf
								EndIf

								// Atualiza para a filial origem
								cFilant := cFilOri

								oLogTrf:Log( { 'TIMESTAMP' , "7. Final da Gera็ใo da  NF / PreNF de Entrada" } )
								oLogTrf:Log( { 'TIMESTAMP' , "7. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt+" - "+time()+" - Nro NF: "+SF1->F1_DOC } )

							EndIf               
							
						EndIf
					Next nx
				Else
					cPedidos := ""
					For nBloqueio := 1 To Len(aBloqueio)
						If nBloqueio # 1 .And. aBloqueio[nBloqueio,1] == aBloqueio[nBloqueio-1,1]
							Loop
						EndIf
						cPedidos += aBloqueio[nBloqueio,1]+"/"
					Next nBloqueio
					Aviso(STR0048,STR0049 + SubStr(cPedidos,1,Len(cPedidos)-1) + " " + STR0050,{STR0044}) //"PV Bloqueado"###"O(s) Pedido de Venda(s) Nro(s) "###" foram bloqueados, por este motivo o processo de Transferencia de Materiais foi cancelado. Para maiores detalhes verificar os pedidos de vendas bloqueados atraves do modulo de Faturamento."
					lRet := .F.
				EndIf
			EndIf
		Else
			MsgInfo(STR0051,STR0047)
			lRet := .F.
		Endif
	Else
		// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
		Help(" ",1,"A310SERERR",,cFilAnt,1,10)
		// Variavel para processamento
		cWhile:=aDadosTransf[1,1]
		ni := 1
		// Varre todos os itens com esta filial origem
		While (ni <= Len(aDadosTransf)) .And. aDadosTransf[1,1] == cWhile
			IncProc()
			ni++
		End
	EndIf
	End Transaction
	
	Exit
Enddo

// Restaura filial original
cFilAnt := cFilOri

// Mostra erro em rotina automatica
If lMostraErro
	if lAutoE
		oLogger:LogSysErr("OFIOM430.log")
	else
		MostraErro()
	endIf
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX6")
MsRUnLock()

oLogTrf:Log( { 'TIMESTAMP' , "8. Final do Processo de Tranferencia" } )
oLogTrf:Log( { 'TIMESTAMP' , "8. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Atual: "+cFilAnt } )
oLogTrf:Log( { '_________' } )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430VIS   บAutor  ณThiago            บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualizar                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430VIS(cAlias,nReg,nOpc)

RegToMemory("VS3",.T.,.T.,.f.)

OM4308001_RefreshJdprismVars()

MontaAHeader(2)
MontaACols(VS1->VS1_NUMORC)

cNroOrc := VS1->VS1_NUMORC
cFilDes := VS1->VS1_FILDES
cArmDes := VS1->VS1_ARMDES
dDtaOrc := VS1->VS1_DATORC

If lJDPrism
	M->VS1_TRFRES := "1" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
Else
	M->VS1_TRFRES := "0" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
	If VS1->(FieldPos("VS1_TRFRES")) > 0 .and. !Empty(VS1->VS1_TRFRES)
		M->VS1_TRFRES := VS1->VS1_TRFRES
	EndIf
EndIf
FS_MONTATELA(nOpc,cFilDes)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430ALT   บAutor  ณThiago            บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alterar                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430ALT(cAlias,nReg,nOpc)

If VS1->VS1_STATUS <> "0"
	MsgInfo(STR0127) // "Nใo ้ permitida altera็ใo de or็amento com status diferente de Or็amento Digitado."
	Return .f.
EndIf

RegToMemory("VS1",.T.,.T.,.f.)
RegToMemory("VS3",.T.,.T.,.f.)

M->VS1_TIPORC := "3"

Pergunte("OFM430",.F.)
c_MV_PAR16 := MV_PAR16

OM4308001_RefreshJdprismVars()

MontaAHeader(4)
MontaACols(VS1->VS1_NUMORC)

cNroOrc := VS1->VS1_NUMORC
cFilDes := VS1->VS1_FILDES
cArmDes := VS1->VS1_ARMDES
dDtaOrc := VS1->VS1_DATORC
If lJDPrism
	M->VS1_TRFRES := "1" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
Else
	M->VS1_TRFRES := "0" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
	If VS1->(FieldPos("VS1_TRFRES")) > 0 .and. !Empty(VS1->VS1_TRFRES)
		M->VS1_TRFRES := VS1->VS1_TRFRES
	EndIf
EndIf
FS_MONTATELA(nOpc,cFilDes)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430CANC  บAutor  ณThiago            บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelar                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430CANC(cAlias,nReg,nOpc)

if VS1->VS1_STATUS == "C"
	MsgInfo(STR0033)
	Return(.f.)
Endif

RegToMemory("VS3",.T.,.T.,.f.)

OM4308001_RefreshJdprismVars()

MontaAHeader(5)
MontaACols(VS1->VS1_NUMORC)

cNroOrc := VS1->VS1_NUMORC
cFilDes := VS1->VS1_FILDES
cArmDes := VS1->VS1_ARMDES
dDtaOrc := VS1->VS1_DATORC
If lJDPrism
	M->VS1_TRFRES := "1" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
Else
	M->VS1_TRFRES := "0" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
	If VS1->(FieldPos("VS1_TRFRES")) > 0 .and. !Empty(VS1->VS1_TRFRES)
		M->VS1_TRFRES := VS1->VS1_TRFRES
	EndIf
EndIf
FS_MONTATELA(nOpc,cFilDes)

cQuery := " "
cQuery += " UPDATE "+RetSqlName('VDD')+" SET "
cQuery += "        VDD_ORCFOR = ' ' , VDD_STATUS = 'S'"
cQuery += "  WHERE VDD_ORCFOR = '"+cNroOrc+"'"
cQuery += "    AND VDD_FILIAL = '"+xFilial("VDD")+"' "
cQuery += "    AND VDD_FILPED = '"+xFilial("VS1")+"' "
cQuery += "    AND D_E_L_E_T_  = ' ' "
If TcsqlExec(cQuery) < 0
	ALERT(TCSQLError())
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ CriaParamณ Autor ณ Thiago			        ณ Data ณ10/01/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Criacao da parambox.			                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriaParam(aItens,cTipo, aOrcTrans)
Local aParamBox := {}  
Local _i        := 0    
Local lDuplic   := .f.
Local oTrf      := DMS_Transferencia():New()
Local oArHlp    := DMS_ArrayHelper():New()
Local oPeso
Local aOrcs
default aOrcTrans := {}

if Empty(aOrcTrans)
	oPeso := oTrf:CalcPeso(VS1->VS1_NUMORC)
else
	aOrcs := oArHlp:Select(aOrcTrans, {|aEl| aEl[1]}) //selecionados na tela
	aOrcs := oArHlp:Map(aOrcs, {|aEl| aEl[2]}) // somente numero do orcamento
	oPeso := oTrf:CalcPesos(aOrcs)
endif

aAdd(aParamBox,{1,STR0059,Space(TamSX3("E4_CODIGO")[1]),"@!","OM430CONDPG()","SE4","",0,.f.}) 
aAdd(aParamBox,{1,STR0097,Space(TamSX3("A4_COD")[1]),"@!","","SA4","",0,.f.}) 
aAdd(aParamBox,{1,STR0099,oPeso:GetValue('liquido'),PesqPict("SC5","C5_PESOL"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0101,oPeso:GetValue('bruto'),PesqPict("SC5","C5_PBRUTO"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0103,Space(TamSX3("C5_VEICULO")[1]),"@!","","DA3","",0,.f.}) 
aAdd(aParamBox,{1,STR0106,0,PesqPict("SC5","C5_VOLUME1"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0108,0,PesqPict("SC5","C5_VOLUME2"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0110,0,PesqPict("SC5","C5_VOLUME3"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0112,0,PesqPict("SC5","C5_VOLUME4"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0114,Space(TamSX3("C5_ESPECI1")[1]),PesqPict("SC5","C5_ESPECI1"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0115,Space(TamSX3("C5_ESPECI2")[1]),PesqPict("SC5","C5_ESPECI2"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0116,Space(TamSX3("C5_ESPECI3")[1]),PesqPict("SC5","C5_ESPECI3"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0117,Space(TamSX3("C5_ESPECI4")[1]),PesqPict("SC5","C5_ESPECI4"),"","","",50,.f.}) 
aAdd(aParamBox,{1,STR0173,Space(TamSX3("C5_MENPAD")[1]),"@!","","SM4","",50,.f.}) 
aAdd(aParamBox,{1,STR0174,Space(TamSX3("C5_MENNOTA")[1]),"@!","","","",120,.f.}) 

While .t.
	If !ParamBox(aParamBox,STR0010,@aRetorn,,,,,,,,.f.)
		Return(.f.)
	Endif
	if Empty(MV_PAR01)
		For _i := 1 to Len(aItens)
			SF4->(dbSetOrder(1))  
			SF4->(dbSeek(xFilial("SF4")+Iif(cTipo == "0",aItens[_i,12],aItens[_i,20]))) 
			if SF4->F4_DUPLIC == "S"
				MsgStop(STR0176) 
				lDuplic := .t.	
				Exit				
			Endif
		Next	
		if !lDuplic
			Exit
		Endif	
	Else
		Exit
	Endif
Enddo
	
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430FIL บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Filial                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430FIL()
Local lRet := .t.
If !ExistCpo("SM0",cEmpAnt+MV_PAR05)
	MsgInfo(STR0062)
	lRet := .f.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430ARMAZบAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Armazem                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430ARMAZ()
Local lRet := .f.
DbSelectArea("NNR")
DbGoTop()
Do While ! Eof()
	If NNR->NNR_CODIGO == MV_PAR06 // Armazem Destino
		lRet := .t.
		Exit
	EndIf
	dbSkip()
End
If !lRet
	MsgInfo(STR0063)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430CONDPGบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Condicao de Pagamento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430CONDPG()
Local lRet := .f.
if !Empty(MV_PAR01)
	dbSelectArea("SE4")
	dbSetOrder(1)
	if dbSeek(xFilial("SE4")+MV_PAR01)
		lRet := .t.
	Else
		MsgInfo(STR0067)
	Endif
Else
	lRet := .t.
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณThiago              บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria Pergunte SX1                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
aAdd(aRegs,{cPerg,"01",STR0071,"","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"02",STR0072,"","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"03",STR0073,"","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","NNR",""})
aAdd(aRegs,{cPerg,"04",STR0074,"","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","NNR",""})
aAdd(aRegs,{cPerg,"05",STR0075,"","","mv_ch5","C",TAMSX3("VS3_FILIAL")[1],0,0,"G","OM430FIL()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01",""})
aAdd(aRegs,{cPerg,"06",STR0003,"","","mv_ch6","C",02,0,0,"G","OM430ARMAZ()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","NNR",""})
aAdd(aRegs,{cPerg,"07",STR0076,"","","mv_ch7","C",02,0,0,"G","OM430TPOPER()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","DJ",""})
aAdd(aRegs,{cPerg,"08",STR0131,"","","mv_ch8","C",06,0,0,"G","OFP8600016_VerificacaoFormula(mv_par08)","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","VEG",""})
aAdd(aRegs,{cPerg,"09",STR0132,"","","mv_ch9","C",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","A62",""})
aAdd(aRegs,{cPerg,"10",STR0133,"","","mv_chA","C",10,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SED",""})
aAdd(aRegs,{cPerg,"11",STR0134,"","","mv_chB","C",1,0,0,"C","","mv_par11",STR0135,"","","","",STR0136,"","","","",STR0137,"","","","",STR0138,"","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12",STR0169,"","","mv_chC","C",9,0,0,"G","(Vazio() .or. Ctb105CC())","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
aAdd(aRegs,{cPerg,"13",STR0170,"","","mv_chD","C",20,0,0,"G","(Vazio() .or. Ctb105CTA())","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","CT1",""})
aAdd(aRegs,{cPerg,"14",STR0171,"","","mv_chE","C",9,0,0,"G","(Vazio() .or. Ctb105ITEM())","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","CTD",""})
aAdd(aRegs,{cPerg,"15",STR0172,"","","mv_chF","C",9,0,0,"G","(Vazio() .or. Ctb105CLVL())","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","CTH",""})
aAdd(aRegs,{cPerg,"16",STR0192,"","","mv_chG","C",06,0,0,"G","OFP8600016_VerificacaoFormula(mv_par16)","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","VEG",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OFM430OPERบAutor  ณThiago           บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada no VALID do SX3 -> VS3                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_OFM430OPER()
Local nQtdRes := 0
Local nPosRec := 0
Local nRecVS3 := 0

if !FM_PILHA("OFIOM430")
	return .t.
endif

if acols[n,len(aheader)+1] == .t.
	acols[n,len(aheader)+1] := .f.
Endif

Do Case
	Case ReadVar() == "M->VS3_TESENT"
		if aCols[n,FG_POSVAR("VS3_TESENT")] <> M->VS3_TESENT
			aCols[n,FG_POSVAR("VS3_OPER")] := M->VS3_OPER := "  "
		Endif
	Case ReadVar() == "M->VS3_TESSAI"
		if aCols[n,FG_POSVAR("VS3_TESSAI")] <> M->VS3_TESSAI
			aCols[n,FG_POSVAR("VS3_OPER")] := M->VS3_OPER := "  "
		Endif
	Case ReadVar() == "M->VS3_OPER"
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xfilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)

		aCols[n,FG_POSVAR("VS3_TESENT")] := cTESEnt := MaTesInt(1,M->VS3_OPER,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)
		aCols[n,FG_POSVAR("VS3_TESSAI")] := cTESSai := MaTesInt(2,M->VS3_OPER,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
	Case ReadVar() == "M->VS3_QTDINI"                
		if GetNewPar("MV_ESTNEG","N") == "N"
			nQtdRes := 0
			nPosRec := FG_POSVAR("VS3_REC_WT")
			If nPosRec > 0
				nRecVS3 := aCols[n,nPosRec] // RecNo VS3
				If nRecVS3 > 0
					VS3->(DbGoTo(nRecVS3))
					If VS3->VS3_RESERV == "1" // Teve Reserva
						nQtdRes := VS3->VS3_QTDRES // Qtde Reservada
					EndIf
				EndIf
			EndIf
			if ( aCols[n,FG_POSVAR("VS3_QTDEST")] + nQtdRes ) < M->VS3_QTDINI
				MsgInfo(STR0077)
				Return(.f.)
			Endif
		Endif	
EndCase

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430TPOPERบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do Tipo de Opercao                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430TPOPER()
If !Empty(MV_PAR07)
	Existcpo("SX5","DJ"+MV_PAR07)
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430PREPECบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Digitacao do Item VS3_CODITE                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430PREPEC()

Local cBx_ORIGEM := ""
Local i := 0                                             
local nRecno := 0
Local nPosRec := FG_POSVAR("VS3_REC_WT")

// NAO DEIXAR ALTERAR O GRUITE / CODITE CASO O VS3 JA ESTEJA SALVO
If nPosRec > 0 .and. aCols[n,nPosRec] > 0 // RecNo VS3
	If ReadVar() == "M->VS3_GRUITE" .and. !Empty(cGruIte) .and. cGruIte <> M->VS3_GRUITE
		MsgStop(STR0184,STR0084) // Impossํvel Alterar o Grupo do Item. Se necessแrio, Delete o registro e crie um novo. / Aten็ใo
		Return .f.
	ElseIf ReadVar() == "M->VS3_CODITE" .and. !Empty(cCodIte) .and. cCodIte <> M->VS3_CODITE
		MsgStop(STR0185,STR0084) // Impossํvel Alterar o C๓digo do Item. Se necessแrio, Delete o registro e crie um novo. / Aten็ใo
		Return .f.
	EndIf
EndIf

if ReadVar() == "M->VS3_GRUITE" 
// ##############################################################################
// Verifica se estourou tamanho do Acols de Pe็as para de acordo com MV_NUMITEN #
// ##############################################################################
	if !FS_QTDLIN("1")
		Return(.f.)
	Endif		
Endif

if ReadVar() == "M->VS3_OPER"
	FS_OFM430OPER()
EndIf

if ReadVar() == "M->VS3_CODITE" .and. M->VS3_CODITE != aCols[n,FG_POSVAR("VS3_CODITE")]
	nRecno := aCols[n, len(aCols[n])-1]
	if nRecno > 0 .and. OM430014_esta_reservado(nRecno)
		MsgInfo(STR0180,STR0070) //"A pe็a nใo pode ser alterada pois estแ reservada."
		return .f.
	endif
endif

if ReadVar() == "M->VS3_CODITE"

// ##############################################################################
// Verifica se estourou tamanho do Acols de Pe็as para de acordo com MV_NUMITEN #
// ##############################################################################
	if !FS_QTDLIN("1")
		Return(.f.)
	Endif		
	
	FG_POSSB1("M->VS3_CODITE","SB1->B1_CODITE","M->VS3_GRUITE")
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
	If !FOUND()
		return .f.
	EndIf

	If Empty(M->VS3_OPER)
		If !Empty(c_MV_PAR07)
			M->VS3_OPER := c_MV_PAR07
		Else
			M->VS3_OPER := POSICIONE("VS3",3,xFilial("VS3")+VS1->VS1_NUMORC,"VS3_OPER") //Posiciona na alteracao
		EndIf
	Endif

	cTESEnt := MaTesInt(1,M->VS3_OPER,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)
	cTESSai := MaTesInt(2,M->VS3_OPER,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
	
	DBSelectArea("SB2")
	DBSetOrder(1)
	dbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
	
	if SB2->B2_QATU > 0
		aCols[n,FG_POSVAR("VS3_GRUITE")] := M->VS3_GRUITE
		aCols[n,FG_POSVAR("VS3_DESITE")] := M->VS3_DESITE := SB1->B1_DESC
		If lVS3_QE
		   aCols[n,FG_POSVAR("VS3_QE")] := M->VS3_QE := SB1->B1_QE
		Endif
		aCols[n,FG_POSVAR("VS3_OPER")]   := M->VS3_OPER
		aCols[n,FG_POSVAR("VS3_TESSAI")] := M->VS3_TESSAI := cTESSai
		aCols[n,FG_POSVAR("VS3_TESENT")] := M->VS3_TESENT := cTESEnt
		aCols[n,FG_POSVAR("VS3_ARMORI")] := M->VS3_ARMORI := SB2->B2_LOCAL
	Else
		aCols[n,FG_POSVAR("VS3_GRUITE")] := M->VS3_GRUITE := Space(TAMSX3("VS3_GRUITE")[1])
		aCols[n,FG_POSVAR("VS3_ARMORI")] := M->VS3_ARMORI := Space(TAMSX3("VS3_ARMORI")[1])
		MsgInfo(STR0079,STR0070)
		Return(.f.)
	Endif
	aCols[n,FG_POSVAR("VS3_QTDEST")] := M->VS3_QTDEST := 0
	aCols[n,FG_POSVAR("VS3_VALPEC")] := M->VS3_VALPEC := 0
	If !Empty(MV_Par08)
		aCols[n,FG_POSVAR("VS3_FORMUL")] := M->VS3_FORMUL := MV_Par08
	Else
		aCols[n,FG_POSVAR("VS3_FORMUL")] := M->VS3_FORMUL := POSICIONE("VS3",3,xFilial("VS3")+VS1->VS1_NUMORC,"VS3_FORMUL") //Posiciona na alteracao
	EndIf

	// Preenchimento dos valores informados nos Parโmetros
	OM4300016_PreenchimentoAutomaticoInclusao(n)
Endif
if ReadVar() == "M->VS3_ARMORI" .or. (ReadVar() == "M->VS3_CODITE" .and. !Empty(M->VS3_ARMORI))
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
	DBSelectArea("SB2")
	DBSetOrder(1)
	if !dbSeek(xFilial("SB2")+SB1->B1_COD+M->VS3_ARMORI)
	   MsgStop(STR0119)
	   Return(.f.)
	Endif
	aCols[n,FG_POSVAR("VS3_QTDEST")] := M->VS3_QTDEST := SaldoSB2()
	If !Empty(M->VS3_FORMUL)
		aCols[n,FG_POSVAR("VS3_VALPEC")] := M->VS3_VALPEC := Fg_Formula(M->VS3_FORMUL)
	Else
		aCols[n,FG_POSVAR("VS3_VALPEC")] := M->VS3_VALPEC := SB2->B2_CM1
	Endif
	For i := 1 to Len(aCols)
		if aCols[i,FG_POSVAR("VS3_GRUITE")]+aCols[i,FG_POSVAR("VS3_CODITE")]+aCols[i,FG_POSVAR("VS3_ARMORI")] == M->VS3_GRUITE+M->VS3_CODITE+M->VS3_ARMORI .and. !aCols[i,Len(aCols[i])] .and. n <> i
			MsgInfo(STR0078,STR0070)
			Return(.f.)
		Endif
	Next
Endif
if ReadVar() == "M->VS3_FORMUL" .and. !Empty(M->VS3_FORMUL)
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
	DBSelectArea("SB2")
	DBSetOrder(1)
	if !dbSeek(xFilial("SB2")+SB1->B1_COD+M->VS3_ARMORI)
	   MsgStop(STR0119)
	   Return(.f.)
	Endif
	aCols[n,FG_POSVAR("VS3_VALPEC")] := M->VS3_VALPEC := Fg_Formula(M->VS3_FORMUL)
Endif
if ReadVar() == "M->VS3_QTDINI"
	if M->VS3_QTDINI > M->VS3_QTDEST
		MsgStop(STR0085)
		return .f.
	endif
	nQtdPec := 0       
	nTotPec := 0 
	nTotGer := 0 
	nQtdItens := 0
	For i := 1 to Len(aCols)
		if aCols[i,Len(aCols[i])]
		   Loop
		Endif  
		if i == n   
			if M->VS3_QTDINI == 0 
			   Loop
			Endif
			nQtdPec += M->VS3_QTDINI
			nTotPec += M->VS3_VALPEC
			nTotGer += M->VS3_VALPEC*M->VS3_QTDINI
		Else
			if aCols[i,FG_POSVAR("VS3_QTDINI")]	== 0 
			   Loop
			Endif
			nQtdPec += aCols[i,FG_POSVAR("VS3_QTDINI")]		
			nTotPec += aCols[i,FG_POSVAR("VS3_VALPEC")]
			nTotGer += aCols[i,FG_POSVAR("VS3_VALPEC")]*aCols[i,FG_POSVAR("VS3_QTDINI")]
		Endif	
		nQtdItens += 1
	Next
	if !FS_QTDLIN("3",nQtdItens)
		Return(.f.)
	Endif		
Endif

aCols[n,FG_POSVAR(substr(ReadVar(),4))] := &(ReadVar()) // Atribuindo valor do M-> para aCols

// Disparar fiscal para carregar variaveis Fiscais //
Do Case 

	Case ReadVar() == "M->VS3_GRUITE" .or. ReadVar() == "M->VS3_CODITE"
		MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
		MaFisRef("IT_TES"    ,"VS300",aCols[n,FG_POSVAR("VS3_TESSAI")])
		MaFisRef("IT_PRCUNI" ,"VS300",aCols[n,FG_POSVAR("VS3_VALPEC")])
		MaFisRef("IT_VALMERC","VS300",aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])
		cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")
		if !Empty(cBx_ORIGEM) 
			If !Empty(aCols[n,FG_POSVAR("VS3_TESSAI")])
				SF4->(dbSeek(xFilial("SF4")+aCols[n,FG_POSVAR("VS3_TESSAI")]))
				If !Empty(SF4->F4_SITTRIB)
					MaFisRef("IT_CLASFIS","VS300",Left(cBx_ORIGEM,1) + SF4->F4_SITTRIB)
				EndIf
			EndIf
		EndIf

	Case ReadVar() == "M->VS3_QTDINI" .OR. ReadVar() == "M->VS3_QTD2UM"

		oPeca:SetGrupo(aCols[n,FG_POSVAR("VS3_GRUITE")])
		oPeca:SetCodigo(aCols[n,FG_POSVAR("VS3_CODITE")])
		If ReadVar() == "M->VS3_QTDINI"
			M->VS3_QTD2UM := oPeca:CONV2UM(M->VS3_QTDINI)
			aCols[n,FG_POSVAR("VS3_QTD2UM")] := M->VS3_QTD2UM

		Else // ReadVar() == "M->VS3_QTD2UM"
			M->VS3_QTDINI := oPeca:CONV1UM(M->VS3_QTD2UM)
			aCols[n,FG_POSVAR("VS3_QTDINI")] := M->VS3_QTDINI
		EndIf

		MaFisRef("IT_QUANT"  ,"VS300",aCols[n,FG_POSVAR("VS3_QTDINI")])
		MaFisRef("IT_VALMERC","VS300",aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])

	Case ReadVar() == "M->VS3_OPER" .or. ReadVar() == "M->VS3_TESSAI"
		MaFisRef("IT_TES"    ,"VS300",aCols[n,FG_POSVAR("VS3_TESSAI")])
		If !Empty(aCols[n,FG_POSVAR("VS3_TESSAI")])
			SF4->(dbSeek(xFilial("SF4")+aCols[n,FG_POSVAR("VS3_TESSAI")]))
			cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")
			If !Empty(cBx_ORIGEM) .and. !Empty(SF4->F4_SITTRIB)
				MaFisRef("IT_CLASFIS","VS300",Left(cBx_ORIGEM,1) + SF4->F4_SITTRIB)
			EndIf
		EndIf

	Case ReadVar() == "M->VS3_FORMUL"
		MaFisRef("IT_PRCUNI" ,"VS300",aCols[n,FG_POSVAR("VS3_VALPEC")])
		MaFisRef("IT_VALMERC","VS300",aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])
		
EndCase
//
OM430ATUFIS("VS3_VALTOT",n,aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])
//
If !Empty(aCols[n,FG_POSVAR("VS3_TESSAI")])
	OM430ATUFIS("VS3_VALPIS",n,MaFisRet(n,"IT_VALPIS")+MaFisRet(n,"IT_VALPS2"))
	OM430ATUFIS("VS3_VALCOF",n,MaFisRet(n,"IT_VALCOF")+MaFisRet(n,"IT_VALCF2"))
	OM430ATUFIS("VS3_ICMCAL",n,MaFisRet(n,"IT_VALICM"))
	OM430ATUFIS("VS3_VALCMP",n,MaFisRet(n,"IT_VALCMP"))
	OM430ATUFIS("VS3_DIFAL" ,n,MaFisRet(n,"IT_DIFAL"))
	OM430ATUFIS("VS3_PICMSB",n,MaFisRet(n,"IT_ALIQSOL"))
	OM430ATUFIS("VS3_BICMSB",n,MaFisRet(n,"IT_BASESOL"))
	OM430ATUFIS("VS3_VICMSB",n,MaFisRet(n,"IT_VALSOL"))
EndIf
//
If ExistBlock("OM430LIN") // Ponto de Entrada no final do FieldOK 
	ExecBlock("OM430LIN",.f.,.f.)
EndIf
//
oQtdPec:Refresh()
oTotPec:Refresh()
oTotGer:Refresh()
o430GetPecas:oBrowse:Refresh()

return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM430IMPORDบAutor  ณThiago             บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao da Ordem de Busca                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430IMPORD()
if ExistBlock("ORDBUSCB")
	ExecBlock("ORDBUSCB",.f.,.f.,{"O"})
Else
	MsgInfo(STR0080)
Endif
Return(.t.)

/*/{Protheus.doc} OFIOM43003_ValidaVS3
	Valida o registro do VS3 e retorna uma string contendo os erros encontrados

	@type function
	@author Vinicius Gati
	@since 09/03/2017
	@version 1.0
	@param aVS3Data, Array, Array contendo os dados do VS3, vem do browse
/*/
Static Function OFIOM43003_ValidaVS3(aVS3Data)
	Local cErrors := ""
	lAtivo := ! aVS3Data[Len(aVS3Data)] // se nใo estแ deletado

	if lAtivo
		if ! OFIOM43001_ArmazemValido( aVS3Data[FG_POSVAR("VS3_ARMORI")] )
			cErrors += STR0188 + aVS3Data[FG_POSVAR("VS3_CODITE")] + chr(13) + chr(10) // /*"O armaz้m de origem do item estแ indisponํvel, pois o mesmo ้ utilizado como armaz้m de Reserva ou Oficina. Item: " */
		end
	EndIf

Return cErrors


/*/{Protheus.doc} OFIOM43001_ArmazemValido
	Validarแ se o armazem de origem pode ser utilizado na transfer๊ncia
	@type function
	@author Vinicius Gati
	@since 09/03/2017
	@version 1.0
	@param cArmOri, character, Armazem digitado para origem da peca para transferencia
/*/
function OFIOM43001_ArmazemValido(cArmOri)
	local lValid := .T.
	cArmRes := GetNewPar("MV_RESITE","SBZ")
	if ALLTRIM(cArmOri) == ALLTRIM(cArmRes) // ้ o armazem de reserva?
		lValid := .F.
	elseif ALLTRIM(cArmOri) $ OFIOM43002_ArmazensRequisicaoDePecas() // contido nos armazem que nใo se pode usar?
		lValid := .F.
	end
return lValid


/*/{Protheus.doc} OFIOM43002_ArmazensRequisicaoDePecas
	Retorna todos os armazens de requisicao de pe็as que nใo podem ser utilizados para transferencia
	@type function
	@author Vinicius Gati
	@since 09/03/2017
	@version 1.0
/*/
Function OFIOM43002_ArmazensRequisicaoDePecas()
  Local cSQL     := ""
  Local oSqlHlp  := DMS_SqlHelper():New()
  Local oArHlp   := DMS_ArrayHelper():New()
  Local cIn      := ""
  cSQL += " SELECT DISTINCT VOI_CODALM "
  cSQL += "   FROM " + oSqlHlp:NoLock('VOI')
  cSQL += "  WHERE VOI_FILIAL='"+xFilial('VOI')+"' "
  cSQL += "    AND VOI_REQPEC = '1' "
  cSQL += "    AND D_E_L_E_T_ = ' ' "
  aResults := oSqlHlp:GetSelect({; 
    {'campos', {"VOI_CODALM"} }, ;
    {'query' , cSQL           }  ;
  })
  aResults := oArHlp:Map(aResults, { |res| "'" + ALLTRIM(res:GetValue('VOI_CODALM')) + "'" })
  cIn := oArHlp:Join(aResults, ',')
Return cIn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma: OM430ATUFIS    Autor: Andre Luis Almeidaบ Data ณ  29/06/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Atualiza variaveis Fiscais e Total do Item na aCols          ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM430ATUFIS(cCpo,nLinaCols,nVlr)
Local nPosColuna := FG_POSVAR(cCpo)
&("M->"+cCpo) := nVlr
If nLinaCols > 0 .and. nPosColuna > 0
	aCols[nLinaCols,nPosColuna] := nVlr
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma: OM430ATUTESINT Autor: Vinicius Gati     บ Data ณ  30/10/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Verifica se foi digitada tes inteligente e grava os dados    ฑฑ
ฑฑ              da entrada e saํda                                         ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM430ATUTESINT(aVS3Data)
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

	If aVS3Data[FG_POSVAR("VS3_OPER")] != M->VS3_OPER // se alterou a operacao
		SB1->(DbSetOrder(7))
		If SB1->(dbSeek( xFilial("SB1") + M->VS3_GRUITE + M->VS3_CODITE ))

			if LEN(cCliEnt) == 0

				aCliForLj := oFilHlp:GetCodFor(cFilAnt, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
				If !Empty(aCliForLj[1]+aCliForLj[2])
					SA2->(DbGoTo(aCliForLj[3]))
				Else
					Return(.f.)
				EndIf
				dbSelectArea("SA2")
				dbSetOrder(2)

				aCliForLj := oFilHlp:GetCodCli(c_Mv_Par05, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
				If !Empty(aCliForLj[1]+aCliForLj[2])
					SA1->(DbGoTo(aCliForLj[3]))
				Else
					Return(.f.)
				EndIf
				dbSelectArea("SA1")
				dbSetOrder(2)

				cCliEnt := SA2->A2_COD+"+"+SA2->A2_LOJA
				cCliSai := SA1->A1_COD+"+"+SA1->A1_LOJA
			EndIf
			
			aEntData := StrTokArr(cCliEnt, "+")
			aSaiData := StrTokArr(cCliSai, "+")
			aVS3Data[FG_POSVAR("VS3_TESENT")] := MaTesInt(1, M->VS3_OPER, aEntData[1], aEntData[2],"F", SB1->B1_COD) // entrada
			aVS3Data[FG_POSVAR("VS3_TESSAI")] := MaTesInt(2, M->VS3_OPER, aSaiData[1], aSaiData[2],"C", SB1->B1_COD) // saida
		EndIf
		SB1->(DbSetOrder(1))
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma: ณOM430FOK   บAutor: ณ Vinicius Gati     บ Data ณ  30/10/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณevento de alteracao de coluna nos grids de VO3              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM430FOK()
	OM430ATUTESINT(aCols[n])
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_MONTATELA ณAutor ณ Thiago                ณ Data ณ 29/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Monta Tela.   	  	                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MONTATELA(nOpc,_cFilDes)

//variaveis controle de janela
Local cBx_ORIGEM := ""
Local nTam     := 0
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local aLinha   := {}
Local aCabec   := {}
Local aItens   := {}
Local cFornece := ""
Local cLojaFor := ""
Local aNewBot  := {}  
Local aCposGet := {}
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}
Local aNaoSim  := {"0="+STR0181,"1="+STR0182} // Nใo / Sim
Local lWhenTRFRES := .f.
Local cVS1_TRFRES := ""
Local cDef_TRFRES := ""
Local aCposAux    := {}
Local lVS1PRISEP  := VS1->(ColumnPos("VS1_PRISEP")) > 0
Local lVS1OBSCON  := VS1->(ColumnPos("VS1_OBSCON")) > 0

Private bRefresh    := { || .t. } 									// Variavel necessaria ao MAFISREF

Private cMotCancVS1 := ""
Private cGruIte     := ""
Private cCodIte     := ""

nOpcE := nOpcG := nOpc

/////////////////////////////////////////
// Reserva Automatica da Transferencia //
/////////////////////////////////////////
If nOpc == 3 .or. nOpc == 4 // Incluir OU Alterar
	If !lJDPrism // NรO ้ JDPrism
		If VS1->(FieldPos("VS1_TRFRES")) > 0 .and. M->VS1_TRFRES <> "1"
			cVS1_TRFRES := CriaVar("VS1_TRFRES")
			If Empty(cVS1_TRFRES) // Deixar alterar somente se nao tiver Inicializador Padrao
				lWhenTRFRES := .t. // Permite selecionar para fazer Reserva Automatica
			EndIf
		EndIf
	EndIf
EndIf
cDef_TRFRES :=  cVS1_TRFRES

//#############################################
//# Zera qualquer montagem previa do fiscal   #
//#############################################
If MaFisFound()
	MaFisEnd()
EndIf

aCliForLj := oFilHlp:GetCodCli(_cFilDes, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA1->(DbGoTo(aCliForLj[3]))
Else
	Return
EndIf

MaFisIni(SA1->A1_COD,;// 1-Codigo Cliente
	SA1->A1_LOJA,;		// 2-Loja do Cliente
	'C',;				// 3-C:Cliente
	'N',;				// 4-Tipo da NF
	SA1->A1_TIPO)		// 5-Tipo do Cliente
//	MaFisRelImp("OFIOM430",{"VS1","VS3"}))

cLinOkP    := "FG_OBRIGAT()"
if nOpc == 3 .or. nOpc == 4
	cFieldOkP  := "OM430PREPEC() .AND. OM430FOK()"
Else
	cFieldOkP := " .t. "
Endif 

SF4->(dbSetOrder(1))

nQtdPec := 0 
nTotPec := 0
nTotGer := 0 
For nCntFor := 1 to Len(aCols)
	//
	n := nCntFor
	//
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+aCols[nCntFor,FG_POSVAR("VS3_GRUITE")]+aCols[nCntFor,FG_POSVAR("VS3_CODITE")]))
	SB1->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+aCols[nCntFor,FG_POSVAR("VS3_TESSAI")]))
	//
	MaFisIniLoad(n,{SB1->B1_COD,;
					aCols[nCntFor,FG_POSVAR("VS3_TESSAI")],;
					" "  ,;
					aCols[nCntFor,FG_POSVAR("VS3_QTDINI")],;
					"",;
					"",;
					SB1->(RecNo()),;	//IT_RECNOSB1
					SF4->(RecNo()),;	//IT_RECNOSF4
					0 }) 			//IT_RECORI
	MaFisLoad("IT_PRODUTO",SB1->B1_COD,n)
	MaFisLoad("IT_QUANT",aCols[nCntFor,FG_POSVAR("VS3_QTDINI")],n)
	MaFisLoad("IT_TES",aCols[nCntFor,FG_POSVAR("VS3_TESSAI")],n)
	MaFisLoad("IT_PRCUNI",aCols[nCntFor,FG_POSVAR("VS3_VALPEC")],n)
	MaFisLoad("IT_VALMERC",aCols[nCntFor,FG_POSVAR("VS3_VALPEC")]*aCols[nCntFor,FG_POSVAR("VS3_QTDINI")],n)
	cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")
	If !Empty(cBx_ORIGEM) .and. !Empty(SF4->F4_SITTRIB)
		MaFisLoad("IT_CLASFIS",Left(cBx_ORIGEM,1) + SF4->F4_SITTRIB,n)
	EndIf
	MaFisRecal("",n)
	MaFisEndLoad(n,1)

	if aCols[nCntFor,FG_POSVAR("VS3_QTDINI")] <> 0
		nQtdPec += aCols[nCntFor,FG_POSVAR("VS3_QTDINI")]		
		nTotPec += aCols[nCntFor,FG_POSVAR("VS3_VALPEC")]
		nTotGer += aCols[nCntFor,FG_POSVAR("VS3_VALPEC")]*aCols[nCntFor,FG_POSVAR("VS3_QTDINI")]
	Endif
	//
Next
n := 1
If len(aCols) > 0
	FG_MEMVAR()
EndIf

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 20 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 20 , .T. , .T. } )  //list box superior
AAdd( aObjects, { 01, 20 , .T. , .F. } )  //list box superior

AADD( aNewBot , {"BACKORDER", {|| OM430Impos() }, STR0139    })
If lFaseConfer // Possui Fase de Conferencia
	If lVS1PRISEP
		M->VS1_PRISEP := criavar("VS1_PRISEP")
		If nOpc <> 3
			M->VS1_PRISEP := VS1->VS1_PRISEP
		EndIf
	EndIf
	If lVS1OBSCON
		M->VS1_OBSCON := criavar("VS1_OBSCON")
		If nOpc <> 3
			M->VS1_OBSCON := VS1->VS1_OBSCON
		EndIf
	EndIf
	AADD( aNewBot , {"PARAMETROS", {|| OM4300021_ObservacaoPrioridadeSeparacao(nOpc) }, STR0193 }) // Observa็ใo e Prioridade de Separa็ใo da Confer๊ncia
EndIf

If ( ExistBlock("OM430ABT") )  // Incluir Opcoes no Acoes relacionadas
	aNewBot := ExecBlock("OM430ABT",.f.,.f.,{aNewBot})
EndIf

DbSelectArea("VS3") // Necessแrio setar ALIAS - estava dando erro de "Alias not exist" dentro do MsGetDados

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg1 TITLE STR0118  From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3]+014,aPosObj[1,4] LABEL ("") OF oDlg1 PIXEL // Caixa - Descricao Item / Meses Demanda

nTam := ( aPosObj[1,4] / 6) //variavel que armazena o resutlado da divisao da tela.
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*0)+((((nTam*1)-(nTam*0))-60)/2)-00 SAY STR0019 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*1)-20 MSGET oNroOrc  VAR cNroOrc PICTURE "@!" SIZE 45,08 OF oDlg1 PIXEL when .f.
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*2)+((((nTam*3)-(nTam*2))-60)/2)-20 SAY STR0020 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*3)-40 MSGET oTpoOrc  VAR cTpoOrc PICTURE "@!" SIZE 55,08 OF oDlg1 PIXEL when .f.
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2)-50 SAY STR0021 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+003+(nTam*5)-50 MSGET oDtaOrc  VAR dDtaOrc PICTURE "@D" SIZE 40,08 OF oDlg1 PIXEL when .f.

@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*0)+((((nTam*1)-(nTam*0))-60)/2)-00 SAY STR0022 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*1)-20 MSGET oFilDes  VAR cFilDes PICTURE "@!" SIZE 20,08 OF oDlg1 PIXEL when .f.
@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*2)+((((nTam*3)-(nTam*2))-60)/2)-20 SAY STR0023 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*3)-40 MSGET oFilDes  VAR cArmDes PICTURE "@!" SIZE 20,08 OF oDlg1 PIXEL when .f.
@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2)-50 SAY STR0183 SIZE 120,08 OF oDlg1 PIXEL COLOR CLR_BLUE // Reserva Itens Automaticamente
@ aPosObj[1,1]+020,aPosObj[1,2]+003+(nTam*5)-50 MSCOMBOBOX oVS1_TRFRES VAR M->VS1_TRFRES SIZE 40,08 COLOR CLR_BLACK ITEMS aNaoSim OF oDlg1 PIXEL WHEN lWhenTRFRES

aCposGet := {"VS3_GRUITE","VS3_CODITE","VS3_ARMORI","VS3_QTDINI","VS3_QTD2UM","VS3_OPER","VS3_TESSAI","VS3_TESENT","VS3_FORMUL","VS3_CENCUS","VS3_CONTA","VS3_ITEMCT","VS3_CLVL"}

If ExistBlock("OM430EDT") // Campos Adicionais da tabela VS3 a serem editados na tela - Obs.: a rotina tambem obedece/executa o X3_WHEN do campo
	aCposAux := ExecBlock("OM430EDT",.f.,.f.)
	For nCntFor := 1 to len(aCposAux)
		aAdd(aCposGet,aCposAux[nCntFor])
	Next
EndIf

o430GetPecas                   := MsGetDados():New(aPosObj[2,1]+014,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOkP,cTudoOk,"+VS3_SEQUEN",.T.,aCposGet,,,nLinhas,cFieldOkP,,,,oDlg1)
o430GetPecas:oBrowse:bChange   := {|| FG_MEMVAR(), cGruIte := aCols[n,FG_POSVAR("VS3_GRUITE","aHeader")] , cCodIte := aCols[n,FG_POSVAR("VS3_CODITE","aHeader")] }
o430GetPecas:oBrowse:bEditCol  := {|| .t. }
o430GetPecas:oBrowse:bDelete   := {|| Iif(FS_QTDLIN("0") .and. FS_DELETE(),aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])],aCols[n,Len(aCols[n])]:=aCols[n,Len(aCols[n])]),o430GetPecas:oBrowse:SetFocus(),o430GetPecas:oBrowse:Refresh(),FG_MEMVAR() }
o430GetPecas:oBrowse:bGotFocus := {|| o430GetPecas:oBrowse:Refresh()}

@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*0)+((((nTam*1)-(nTam*0))-60)/2)-00 SAY STR0120 SIZE 40,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*1)-45 MSGET oTotPec VAR nTotPec PICTURE "@E 999,999,999.99" SIZE 60,08 OF oDlg1 PIXEL when .f.

@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*2)+((((nTam*3)-(nTam*2))-60)/2)-20 SAY STR0121 SIZE 40,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*3)-60 MSGET oQtdPec VAR nQtdPec PICTURE "999999" SIZE 55,08 OF oDlg1 PIXEL when .f.

@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2)-50 SAY STR0122 SIZE 40,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+007,aPosObj[3,2]+045+(nTam*5)-90 MSGET oTotGer VAR nTotGer PICTURE "@E 999,999,999.99" SIZE 60,08 OF oDlg1 PIXEL when .f.

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| IIf(FS_OK(nOpc),(oDlg1:End(),nOpca := 1),.f.) } , {|| oDlg1:End(),nOpca := 2},,aNewBot)
if nOpca == 2
	RollBAckSx8()
Endif

M->VS1_TRFRES := cDef_TRFRES // Volta conteudo Default para Variavel

MaFisEnd()

Return(.t.)

/*/{Protheus.doc} FS_DELETE
Valida็ใo da dele็ใo de Itens
@type function
@author Thiago
@since 24/04/2015
@version 1.0             
@return L๓gico
/*/
Static Function FS_DELETE()
Local i := 0    

If (aCols[n,Len(aCols[n])]) // Esta deletado, vai voltar registro - VALIDAR
	For i := 1 to Len(aCols)     
		if !(aCols[i,Len(aCols[i])]) .and. n <> i
			if aCols[i,FG_POSVAR("VS3_GRUITE")]+aCols[i,FG_POSVAR("VS3_CODITE")]+aCols[i,FG_POSVAR("VS3_ARMORI")] == aCols[n,FG_POSVAR("VS3_GRUITE")]+aCols[n,FG_POSVAR("VS3_CODITE")]+aCols[n,FG_POSVAR("VS3_ARMORI")]
				MsgInfo(STR0078,STR0070)
				Return(.f.)
			Endif
		Endif	
	Next  
EndIf

if aCols[n,FG_POSVAR("VS3_QTDINI")] <> 0
	MaFisDel(n,aCols[n,Len(aCols[n])])
	if aCols[n,Len(aCols[n])]
		nQtdPec -= aCols[n,FG_POSVAR("VS3_QTDINI")]		
		nTotPec -= aCols[n,FG_POSVAR("VS3_VALPEC")]	
		nTotGer -= (aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])
	Else
		nQtdPec += aCols[n,FG_POSVAR("VS3_QTDINI")]		
		nTotPec += aCols[n,FG_POSVAR("VS3_VALPEC")]
		nTotGer += (aCols[n,FG_POSVAR("VS3_VALPEC")]*aCols[n,FG_POSVAR("VS3_QTDINI")])
	Endif      
	oQtdPec:Refresh()
	oTotPec:Refresh()
	oTotGer:Refresh()
Endif

Return(.t.)

/*/{Protheus.doc} MontaAHeader
Retorna matriz do aHeader ( nOpcTela: 2-Visualizar / 3-Incluir / 4-Alterar / 5-Excluir )
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@return array, Array com valores iniciais da aCols
/*/
Static Function MontaAHeader(nOpcTela)

Local cCpoAdicional := ""
Default nOpcTela    := 2

cCampos := "VS3_FILIAL/VS3_GRUITE/VS3_CODITE/VS3_DESITE/VS3_QTDEST/VS3_QTDINI/VS3_QTD2UM/VS3_VALPEC/VS3_OPER/VS3_VALTOT/"   
cCampos += "VS3_TESENT/VS3_TESSAI/VS3_ARMORI/VS3_FORMUL/VS3_CENCUS/VS3_CONTA/VS3_ITEMCT/VS3_CLVL/"
cCampos += "VS3_VALPIS/VS3_VALCOF/VS3_ICMCAL/VS3_VALCMP/VS3_VICMSB/VS3_DIFAL/" // Impostos Calculados
If lVS3_QE
	cCampos += "VS3_QE/"
Endif

If ExistBlock("OM430CPO") // Campos Adicionais da tabela VS3 para montar a tela 
	cCpoAdicional := ExecBlock("OM430CPO",.f.,.f.,{ nOpcTela }) // 2-Visualizar / 3-Incluir / 4-Alterar / 5-Excluir
EndIf

aHeader:={}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS3")
nUsado:=0

While !Eof().And.(x3_arquivo=="VS3")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.(  Alltrim(x3_campo) $ cCampos + cCpoAdicional )
		nUsado:=nUsado+1
		
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		
		If aHeader[nUsado,2] == "VS3_QTDINI"
			aHeader[nUsado,1] := STR0052
		Endif
		
	Endif
	
	dbSkip()
	
End

ADHeadRec("VS3",aHeader)

Return

/*/{Protheus.doc} CriaLinhaAcols
Retorna um array com os valores iniciais da aCols
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param nHeadRec, num้rico, Parametro para receber o numero da coluna de RECNO
@return array, Array com valores iniciais da aCols
/*/
Static Function CriaLinhaAcols(nHeadRec)
Local nUsado := Len(aHeader)
Local aAuxACols := {}
Local _ni
Local lPEOM430COL := ExistBlock("OM430COL") // Batizar conteudo nos campos da aCols

aAuxACols := Array(nUsado+1)
aAuxACols[nUsado+1]:=.F.
For _ni:=1 to nUsado
	If IsHeadRec(aHeader[_ni,2])
		aAuxACols[_ni] := 0
		nHeadRec := _ni
	ElseIf IsHeadAlias(aHeader[_ni,2])
		aAuxACols[_ni] := "VS3"
	Else
		aAuxACols[_ni]:=CriaVar(aHeader[_ni,2])
	EndIf
Next

If lPEOM430COL
	aAuxACols := ExecBlock("OM430COL",.f.,.f.,{ aClone(aAuxACols) , 0 , 0 }) // Carregar conteudo dos campos customizados da linha na Inclusao do aCols
EndIf

Return aClone(aAuxACols)

/*/{Protheus.doc} MontaACols
Monta a matriz aCols com os valores gravados na base de dados
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cNumOrc, character, Numero do Orcamento
@return array, aCols da GetDados
/*/
Static Function MontaACols(cNumOrc)

Local lPEOM430COL := ExistBlock("OM430COL") // Batizar conteudo nos campos da aCols
Local aAuxACols := {}
Local nHeadRec
Default cNumOrc := VS1->VS1_NUMORC

aAuxACols := CriaLinhaAcols(@nHeadRec)

aCols := {}
nReg := 0

cQuery := "SELECT VS3.R_E_C_N_O_ AS RECVS3 , VS3.VS3_GRUITE , VS3.VS3_ARMORI , VS3.VS3_CODITE , VS3.VS3_QTDINI , VS3.VS3_OPER , VS3.VS3_TESSAI ,"
cQuery +=       " VS3.VS3_TESENT , VS3.VS3_VALPEC , VS3.VS3_FORMUL , VS3.VS3_CENCUS , VS3.VS3_CONTA , VS3.VS3_ITEMCT , VS3.VS3_CLVL ,"
cQuery +=       " VS3.VS3_VALTOT , VS3.VS3_VALPIS , VS3.VS3_VALCOF , VS3.VS3_ICMCAL , VS3.VS3_VALCMP , VS3.VS3_DIFAL , VS3.VS3_PICMSB , VS3.VS3_BICMSB , VS3.VS3_VICMSB ,"
cQuery +=       " SB1.R_E_C_N_O_ AS RECSB1 , SB1.B1_DESC , SB2.B2_QATU, SB2.R_E_C_N_O_ AS RECSB2"
IF lVS3_QE
	cQuery +=       " , SB1.B1_QE "
Endif
cQuery +=  " FROM " + RetSqlName( "VS3" ) + " VS3 "
cQuery +=  " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO = VS3.VS3_GRUITE AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.D_E_L_E_T_ = ' '"
cQuery +=  " JOIN " + RetSQLName("SB2") + " SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL = VS3.VS3_ARMORI AND SB2.D_E_L_E_T_ = ' '"
cQuery += " WHERE VS3.VS3_FILIAL='"+ xFilial("VS3")+ "'"
cQuery +=   " AND VS3.VS3_NUMORC = '"+cNumOrc+"'"
cQuery +=   " AND VS3.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3A, .T., .T. )
Do While !( cAliasVS3A )->( Eof() )

	SB1->(DbGoto(( cAliasVS3A )->RECSB1))
	SB2->(DbGoto(( cAliasVS3A )->RECSB2))

	nReg ++
	AADD( aCols , aClone( aAuxACols ) )
	aCols[nReg,FG_POSVAR("VS3_GRUITE")] := ( cAliasVS3A )->VS3_GRUITE
	aCols[nReg,FG_POSVAR("VS3_CODITE")] := ( cAliasVS3A )->VS3_CODITE
	aCols[nReg,FG_POSVAR("VS3_DESITE")] := ( cAliasVS3A )->B1_DESC
	If lVS3_QE
		aCols[nReg,FG_POSVAR("VS3_QE")] := ( cAliasVS3A )->B1_QE
	Endif
	aCols[nReg,FG_POSVAR("VS3_QTDINI")] := ( cAliasVS3A )->VS3_QTDINI
	aCols[nReg,FG_POSVAR("VS3_VALPEC")] := ( cAliasVS3A )->VS3_VALPEC //SB2->B2_CM1
	aCols[nReg,FG_POSVAR("VS3_OPER")  ] := ( cAliasVS3A )->VS3_OPER
	aCols[nReg,FG_POSVAR("VS3_FORMUL")] := ( cAliasVS3A )->VS3_FORMUL
	aCols[nReg,FG_POSVAR("VS3_QTDEST")] := SaldoSB2()
	aCols[nReg,FG_POSVAR("VS3_TESSAI")] := ( cAliasVS3A )->VS3_TESSAI
	aCols[nReg,FG_POSVAR("VS3_TESENT")] := ( cAliasVS3A )->VS3_TESENT
	aCols[nReg,FG_POSVAR("VS3_ARMORI")] := ( cAliasVS3A )->VS3_ARMORI
	aCols[nReg,FG_POSVAR("VS3_CENCUS")] := ( cAliasVS3A )->VS3_CENCUS
	aCols[nReg,FG_POSVAR("VS3_CONTA")]  := ( cAliasVS3A )->VS3_CONTA
	aCols[nReg,FG_POSVAR("VS3_ITEMCT")] := ( cAliasVS3A )->VS3_ITEMCT
	aCols[nReg,FG_POSVAR("VS3_CLVL")]   := ( cAliasVS3A )->VS3_CLVL
	aCols[nReg,FG_POSVAR("VS3_VALTOT")] := ( cAliasVS3A )->VS3_VALTOT
	//
	aCols[nReg,FG_POSVAR("VS3_VALPIS")] := ( cAliasVS3A )->VS3_VALPIS
	aCols[nReg,FG_POSVAR("VS3_VALCOF")] := ( cAliasVS3A )->VS3_VALCOF
	aCols[nReg,FG_POSVAR("VS3_ICMCAL")] := ( cAliasVS3A )->VS3_ICMCAL
	aCols[nReg,FG_POSVAR("VS3_VALCMP")] := ( cAliasVS3A )->VS3_VALCMP
	aCols[nReg,FG_POSVAR("VS3_DIFAL" )] := ( cAliasVS3A )->VS3_DIFAL
	aCols[nReg,FG_POSVAR("VS3_VICMSB")] := ( cAliasVS3A )->VS3_VICMSB
	//
	aCols[nReg,nHeadRec] := ( cAliasVS3A )->RECVS3
	//
	If lPEOM430COL
		aCols[nReg] := ExecBlock("OM430COL",.f.,.f.,{ aClone(aCols[nReg]) , ( cAliasVS3A )->RECVS3 , ( cAliasVS3A )->RECSB1 }) // Carregar conteudo dos campos customizados da linha na aCols
	EndIf
	//
	( cAliasVS3A )->(DbSkip())
Enddo
( cAliasVS3A )->( dbCloseArea() )
dbSelectArea("VS1")

Return aCols

/*/{Protheus.doc} OM430RESERV
Funcao para reservar pe็as do or็amento de transferencia
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param cAlias, character, (Descri็ใo do parโmetro)
@param nReg, num้rico, (Descri็ใo do parโmetro)
@param nOpc, num้rico, (Descri็ใo do parโmetro)
/*/
Function OM430RESERV(cAlias,nReg,nOpc)

If !MsgYesNo(STR0128) // "Confirma a reserva dos itens ?"
	Return .f.
EndIf

Begin Transaction
	RegToMemory("VS3",.T.,.T.,.f.)
	If !OM430RESITE(.t.,.t.)
		DisarmTransaction()
	EndIf
End Transaction

Return

/*/{Protheus.doc} OM430RESITE
Fun็ใo responsแvel por Reservar ou Desreservar as pe็as do or็amento
@type function
@author Rubens
@since 10/12/2015
@version 1.0
@param lReserv, logico, Indica se a rotina ira Reservar ou Desreservar as pe็as
@param lCarregaHeader, logico, Indica se ้ necessแrio montar aHeader
@return logico, Indica se foi possivel reservar ou desreservar as pe็as
/*/
Static Function OM430RESITE(lReserv, lCarregaHeader, oLogTrf)

Local lGerLog := .t.

If lCarregaHeader
	MontaAHeader(4)
	MontaACols(VS1->VS1_NUMORC)
EndIf

If !(oLogTrf == Nil)
	oLogTrf:Log( { 'TIMESTAMP' , "1. Inicio do OM430RESITE" } )
	oLogTrf:Log( { 'TIMESTAMP' , "1. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt+" - Status Reserva: "+VS1->VS1_STARES } )
EndIf

OM4308001_RefreshJdprismVars()

if lJDPrism .AND. lReserv
	return .T.
EndIf

dbSelectArea("VS1")

aHeaderP := aClone(aHeader)
oGetPecas := DMS_GetDAuto():Create()
oGetPecas:aCols := aCols
oGetPecas:aHeader := aHeader
oGetPecas:nAt := 1

If !(oLogTrf == Nil)
	oLogTrf:Log( { 'TIMESTAMP' , "2. Execucao do OX001RESITE" } )
	oLogTrf:Log( { 'TIMESTAMP' , "2. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt+" - Status Reserva: "+VS1->VS1_STARES } )
EndIf

If Empty(OX001RESITE(VS1->VS1_NUMORC,lReserv, IIf( !lReserv , {"9999"}, NIL ), .f., lGerLog ))
	Return .f.
EndIf

If !(oLogTrf == Nil)
	oLogTrf:Log( { 'TIMESTAMP' , "3. Fim execucao do OX001RESITE" } )
	oLogTrf:Log( { 'TIMESTAMP' , "3. Orcto Transf: "+VS1->VS1_NUMORC+" - Filial Corrente: "+cFilAnt+" - Status Reserva: "+VS1->VS1_STARES } )
EndIf

If lReserv
	RecLock("VS1",.f.)
	VS1->VS1_RESERV := "1"
	VS1->(MsUnLock())
	
	VS3->(dbSetOrder(1))
	VS3->(dbSeek(xFilial("VS3") + VS1->VS1_NUMORC ))
	While !VS3->(Eof()) .and. VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		RecLock("VS3" , .f. )
		VS3->VS3_QTDRES := VS3->VS3_QTDITE
		VS3->VS3_RESERV := "1"
		VS3->(MsUnLock())
		VS3->(dbSkip())
	End
EndIf

Return .t.

/*/{Protheus.doc} MenuDef
Menu da Rotina
@type function
@author Rubens
@since 10/12/2015
@version 1.0
/*/
Static Function MenuDef()

Local aRecebe
Local aRotina := {}

AADD(aRotina, { STR0004,"axPesqui"   , 0 , 1 })	// Pesquisar
AADD(aRotina, { STR0005,"OM430VIS"   , 0 , 2 })	// Visualizar
AADD(aRotina, { STR0006,"OM430INCL"  , 0 , 3 })	// Incluir
AADD(aRotina, { STR0007,"OM430ALT"   , 0 , 4 })	// Alterar
AADD(aRotina, { STR0008,"OM430CANC"  , 0 , 5 })	// Cancelar
AADD(aRotina, { STR0009,"OM430GeraNF", 0 , 6 })	// Transferir (Gerar NF)
AADD(aRotina, { STR0177,"OM430TrfAgr", 0 , 10})	// Transferir Agrupado
AADD(aRotina, { STR0010,"OM430LibFec", 0 , 7 })	// Conferir
AADD(aRotina, { STR0011,"OM430IMPORD", 0 , 8 })	// Impressao da Ordem de Busca
AADD(aRotina, { STR0012,"OM430LEG"   , 0 , 9 })	// Legenda

If ExistBlock("O430AROT")
	aRecebe := ExecBlock("O430AROT",.f.,.f.,{aRotina} )
Endif
If Valtype(aRecebe) == "A"
	aRotina := aClone(aRecebe)
Endif

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM430Impos บAutor  ณ Thiago           บ Data ณ  05/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Planilha financeira.							                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM430Impos( nOpc, lRetTotal, aRefRentab)
Local oDlg
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a tela de exibicao dos valores fiscais ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE STR0140 FROM 09,00 TO 28,80 //"Planilha Financeira"
	MaFisRodape(1,,,{005,001,310,60},Nil,.T.)
	@ 070,005 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL 
	@ 070,105 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL 
	@ 070,205 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL 
	@ 085,005 SAY RetTitle("F2_FRETAUT")	SIZE 40,10 PIXEL 
	@ 085,105 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL 
	@ 085,205 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL 
	@ 070,050 MSGET MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. 
	@ 070,150 MSGET MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. 
	@ 070,250 MSGET MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONTO",16,2)	SIZE 50,07 PIXEL WHEN .F.
	@ 085,050 MSGET MaFisRet(,"NF_AUTONOMO")	PICTURE PesqPict("SF2","F2_FRETAUT",16,2)	SIZE 50,07 PIXEL WHEN .F.
	@ 085,150 MSGET MaFisRet(,"NF_DESPESA")		PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. 
	@ 085,250 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. 
	@ 105,005 TO 106,310 PIXEL 
	@ 110,005 SAY STR0141  SIZE 40,10 PIXEL  //"Total da Nota"
	@ 110,050 MSGET MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc=="CHI",TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2))                   	SIZE 50,07 PIXEL WHEN .F. 
	@ 110,270 BUTTON STR0142		SIZE 040,11 ACTION oDlg:End()  PIXEL		//"Sair"

ACTIVATE MSDIALOG oDlg CENTERED //ON INIT CursorArrow()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM430  บAutor  ณRenato Vinicius     บ Data ณ  26/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de sele็ใo dos or็amentos que serใo transferidos      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function OM430TrfAgr()

Local nj := 0  
Local ni := 0

Local lMarca     := .t.
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTitulo    := STR0147 //Transfer๊ncias agrupada
Local cCdEmp     := Space(TAMSX3("VS3_FILIAL")[1])
Local cBkpFil    := cFilAnt

Private cNomEmp := Space(TAMSX3("A1_NOME")[1])
Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Private oVERD    := LoadBitmap( GetResources() , "BR_VERDE" )
Private oVERM    := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oAZUL    := LoadBitmap( GetResources() , "BR_AZUL" )
Private aCabTab := {}
Private aIteTab := {}
Private aIteEst := {}
Private aIteOrc := {}
		
aAdd(aCabTab,{RetTitle("VS1_NUMORC")     ,"C",40,"@!"               }) 
aAdd(aCabTab,{RetTitle("VS1_DATORC")     ,"D",35,"@D"     })           
aAdd(aCabTab,{RetTitle("VS3_VALTOT")     ,"N",55,"@E 999,999,999.99"}) 
aAdd(aIteTab,{"",cTod(""),0})
aAdd(aIteEst,{"","","","","","","",0,0,{{"",0}}})
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 13 , .T. , .F. } ) // Titulo / Botoes
aAdd( aObjects, { 0 , 60 , .T. , .T. } ) // ListBox Orcamentos
aAdd( aObjects, { 0 , 40 , .T. , .T. } ) // ListBox Itens
aPos := MsObjSize( aInfo, aObjects )

For ni := 1 to len(aIteTab) // Adicionar campo de TIK no vetor (1a.coluna)
	aIteTab[ni] := aSize(aIteTab[ni],Len(aIteTab[ni])+1) // Criar uma posicao a mais no vetor
	aIteTab[ni] := aIns(aIteTab[ni],1) // inserir 1a. coluna
	aIteTab[ni,1] := .t.
Next
_aCabImp := aClone(aCabTab)
For ni := 1 to len(_aCabImp)
	If _aCabImp[ni,2] == "C" // alinhar colunas CARACTER
		nTam := 1
		For nj := 1 to len(aIteTab)
			If nTam < len(aIteTab[nj,ni+1])
				nTam := len(aIteTab[nj,ni+1])
			EndIf
		Next
		_aCabImp[ni,1] := left(_aCabImp[ni,1]+space(nTam),nTam)
		For nj := 1 to len(aIteTab)
			aIteTab[nj,ni+1] := left(aIteTab[nj,ni+1]+space(nTam),nTam)
		Next
	ElseIf _aCabImp[ni,2] == "D" // alinhar colunas DATA
		nTam := len(Transform(dDatabase,_aCabImp[ni,4]))
		_aCabImp[ni,1] := left(_aCabImp[ni,1]+space(nTam),nTam)
	ElseIf _aCabImp[ni,2] == "N" // alinhar colunas NUMERICO
		nTam := len(Transform(1,_aCabImp[ni,4]))
		_aCabImp[ni,1] := right(space(nTam)+_aCabImp[ni,1],nTam)
	EndIf
Next

DEFINE MSDIALOG oDlgTrfAg FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cTitulo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oDlgTrfAg:lEscClose := .F.
	oLbOrcTrf := TWBrowse():New(aPos[2,1]+2,aPos[2,2]+2,(aPos[2,4]-aPos[2,2]-4),(aPos[2,3]-aPos[2,1]-4),,,,oDlgTrfAg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbOrcTrf:nAT := 1
	oLbOrcTrf:SetArray(aIteTab)
	oLbOrcTrf:addColumn( TCColumn():New( "" , { || IIf(aIteTab[oLbOrcTrf:nAt,1] , oOkTik , oNoTik ) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	For ni := 1 to len(aCabTab)
		If aCabTab[ni,2] == "L"
			oLbOrcTrf:addColumn( TCColumn():New( aCabTab[ni,1] , &("{ || aIteTab[oLbOrcTrf:nAt,"+Alltrim(str(ni+1))+"] }")	,,,, "LEFT" , aCabTab[ni,3],.F.,.F.,,,,.F.,) )	// Colunas LOGICAS
		Else
			oLbOrcTrf:addColumn( TCColumn():New( aCabTab[ni,1] , &("{ || Transform(aIteTab[oLbOrcTrf:nAt,"+Alltrim(str(ni+1))+"],aCabTab["+Alltrim(str(ni))+",4]) }")	,,,, IIf(aCabTab[ni,2]<>"N","LEFT","RIGHT") , aCabTab[ni,3],.F.,.F.,,,,.F.,) ) // DEMAIS Colunas
		EndIf
	Next
	oLbOrcTrf:bLDblClick := { || ( aIteTab[oLbOrcTrf:nAt,1] := !aIteTab[oLbOrcTrf:nAt,1] , OM4300041_Levanta_Itens_com_Estoques(aIteTab) ) }
	oLbOrcTrf:bHeaderClick := { |oObj,nCol| IIf( nCol==1, ( lMarca := !lMarca , aEval( aIteTab , { |x| x[1] := lMarca } ) , oLbOrcTrf:Refresh() , OM4300041_Levanta_Itens_com_Estoques(aIteTab) ),oLbOrcTrf:Refresh()) }
	oLbOrcTrf:Refresh()

	oLbIteEst := TWBrowse():New(aPos[3,1]+2,aPos[3,2]+2,(aPos[3,4]-aPos[3,2]-230),(aPos[3,3]-aPos[3,1]-4),,,,oDlgTrfAg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbIteEst:nAT := 1
	oLbIteEst:SetArray(aIteEst)
	oLbIteEst:addColumn( TCColumn():New( "" , { || IIf(aIteEst[oLbIteEst:nAt,3]=="1",oAZUL,IIf(aIteEst[oLbIteEst:nAt,8]>=aIteEst[oLbIteEst:nAt,9],oVERD,oVERM)) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Legenda Item
	oLbIteEst:addColumn( TCColumn():New( STR0153 , { || aIteEst[oLbIteEst:nAt,1] }	,,,, "LEFT" , 50,.F.,.F.,,,,.F.,) ) // Grupo
	oLbIteEst:addColumn( TCColumn():New( STR0154 , { || aIteEst[oLbIteEst:nAt,2] }	,,,, "LEFT" , 100,.F.,.F.,,,,.F.,) ) // C๓d. Item
	oLbIteEst:addColumn( TCColumn():New( STR0155 , { || aIteEst[oLbIteEst:nAt,7] }	,,,, "LEFT" , 140,.F.,.F.,,,,.F.,) ) // Descri็ใo
	oLbIteEst:addColumn( TCColumn():New( STR0196 , { || IIf(aIteEst[oLbIteEst:nAt,3]=="1","",Transform(aIteEst[oLbIteEst:nAt,8],GetSX3Cache("B2_QATU"   ,"X3_PICTURE"))) }	,,,, "RIGHT" , 80,.F.,.F.,,,,.F.,) ) // Qtd. Disponivel
	oLbIteEst:addColumn( TCColumn():New( STR0197 , { || Transform(aIteEst[oLbIteEst:nAt,9],GetSX3Cache("B2_QATU"   ,"X3_PICTURE")) }	,,,, "RIGHT" , 80,.F.,.F.,,,,.F.,) ) // Qtd. Total sele็ใo
	oLbIteEst:bLDblClick := { || ( OM4300051_Legenda_Itens() ) }
	oLbIteEst:bChange := { || OM4300061_Lista_Orcamentos_do_Item_selecionado() }

	oLbIteOrc := TWBrowse():New(aPos[3,1]+2,aPos[3,4]-aPos[3,2]-220,220,(aPos[3,3]-aPos[3,1]-4),,,,oDlgTrfAg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbIteOrc:nAT := 1
	oLbIteOrc:SetArray(aIteOrc)
	oLbIteOrc:addColumn( TCColumn():New( STR0198 , { || aIteOrc[oLbIteOrc:nAt,1] }	,,,, "LEFT" , 070,.F.,.F.,,,,.F.,) ) // Or็amento
	oLbIteOrc:addColumn( TCColumn():New( STR0199 , { || Transform(aIteOrc[oLbIteOrc:nAt,2],GetSX3Cache("B2_QATU"   ,"X3_PICTURE")) }	,,,, "RIGHT" , 80,.F.,.F.,,,,.F.,) ) // Qtd. no Or็amento

	@ aPos[1,1]+002,aPos[1,4]-260 SAY STR0022 OF oDlgTrfAg PIXEL COLOR CLR_BLUE //Destino
	@ aPos[1,1]+001,aPos[1,4]-235 MSGET oPesqEmp VAR cCdEmp  OF oDlgTrfAg F3 "SM0" VALID !Empty(cCdEmp) .and. FS_VLDEMP(cCdEmp) SIZE 50,11 PIXEL
	@ aPos[1,1]+001,aPos[1,4]-185 MSGET oNomeEmp VAR cNomEmp OF oDlgTrfAg SIZE 100,11 PIXEL WHEN .f.
	@ aPos[1,1]+001,aPos[1,4]-073 BUTTON oFiltr PROMPT STR0150 OF oDlgTrfAg SIZE 50,11 PIXEL ACTION FS_FILREG(cCdEmp) // Filtrar
	
ACTIVATE MSDIALOG oDlgTrfAg ON INIT EnchoiceBar(oDlgTrfAg,{|| IIf(OM4300031_Valida_e_Processa(aIteTab,cCdEmp), oDlgTrfAg:End(),.t.) },{|| oDlgTrfAg:End() },,)

cFilAnt := cBkpFil // Volta Filial

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILREG บAutor  ณRenato Vinicius     บ Data ณ  29/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra os or็amentos que poderใo ser selecionados para a    บฑฑ
ฑฑบ          ณ transferencia                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_FILREG(_cCdEmp)

Local cQry := ""
Default _cCdEmp := Space(TAMSX3("VS3_FILIAL")[1])
aIteTab := {}
cQry := GetNextAlias()

cQuery := "SELECT VS1_NUMORC, VS1_DATORC, VS1.R_E_C_N_O_ RECNOVS1, VS1_FILDES, VS1_ARMDES, VS1_CODVEN, VS1_PGTFRE, SUM(VS3.VS3_VALPEC * VS3.VS3_QTDITE) TOTORC FROM "+RetSQLName("VS1")+" VS1 "
cQuery += " JOIN "+RetSqlName("VS3")+" VS3 ON VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS3.VS3_FILIAL = VS1.VS1_FILIAL AND VS1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
cQuery +=   " AND VS1.VS1_FILDES = '"+_cCdEmp+"' "
cQuery +=   " AND VS1.VS1_TIPORC = '3' "
cQuery +=   " AND VS1.VS1_STATUS = 'F' "
cQuery +=   " AND VS1.D_E_L_E_T_ = ' ' "
cQuery +=   " GROUP BY VS1_NUMORC, VS1_DATORC, VS1.R_E_C_N_O_, VS1_FILDES, VS1_ARMDES, VS1_CODVEN, VS1_PGTFRE "
cQuery +=   " HAVING SUM(VS3.VS3_VALPEC * VS3.VS3_QTDITE) > 0

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQry, .F., .T. )

while !((cQry)->(eof()))
	
	aAdd(aIteTab,{.t.,;
	(cQry)->(VS1_NUMORC),;
	stod((cQry)->(VS1_DATORC)),;
	(cQry)->(TOTORC),;
	(cQry)->(RECNOVS1),;
	(cQry)->(VS1_FILDES),;
	(cQry)->(VS1_ARMDES),;
	(cQry)->(VS1_CODVEN),;
	(cQry)->(VS1_PGTFRE) })
	(cQry)->(dbSkip())
enddo             

(cQry)->(DBCloseArea())

If Len(aIteTab) = 0
	aAdd(aIteTab,{.t.,"",cTod(""),0,0,"","","",""})
EndIf

oLbOrcTrf:SetArray(aIteTab)
oLbOrcTrf:Refresh()

OM4300041_Levanta_Itens_com_Estoques(aIteTab)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GERTRA บAutor  ณRenato Vinicius     บ Data ณ  29/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo de transferencia para os or็amentos selecionados   บฑฑ
ฑฑบ          ณ Transferencia Agrupada                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GERTRA(aOrcTrans,_cCdEmp)

Local ni := 0
Local lAprMsg := .f.
Local aParam   := {}
Local cFornece := ""
Local cLojaFor := ""
Local cCliente := ""
Local cLojaCli := ""    
Local i        := 0 
Local y        := 0
Local cQuery      := "" 
Local cAliasSE1   := "SqlSE1"
Local cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Local lMultOrc := .t.
Local nPosIte := 0
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

c_MV_PAR11 := Space(TAMSX3("VS1_PGTFRE")[1])
c_MV_PAR10 := Space(TAMSX3("VS1_NATURE")[1])

Default aOrcTrans := {}
Default _cCdEmp := Space(TAMSX3("VS3_FILIAL")[1])

cLocalizSai := GetMv("MV_RESLOC")

aCliForLj := oFilHlp:GetCodFor(cFilAnt, .T.) //  Busca Codigo e Loja de Fornecedor da Filial Origem
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA2->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA2")
dbSetOrder(2)

cFornece := SA2->A2_COD
cLojaFor := SA2->A2_LOJA

aCliForLj := oFilHlp:GetCodCli(_cCdEmp, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA1->(DbGoTo(aCliForLj[3]))
Else
	Return(.f.)
EndIf
dbSelectArea("SA1")
dbSetOrder(2)

cCliente := SA1->A1_COD
cLojaCli := SA1->A1_LOJA

dbSelectArea("SB1")
dbSetOrder(7)
dbSelectArea("SB2")
dbSetOrder(1)

aItensNew := {}

Begin Transaction
For ni := 1 to Len(aOrcTrans)
	IncProc()
	If aOrcTrans[ni,1]
		If Empty(c_MV_PAR05)
			c_MV_PAR05 := aOrcTrans[ni,6]
	    EndIf
		If Empty(c_MV_PAR06)
			c_MV_PAR06 := aOrcTrans[ni,7]
		EndIf
		If Empty(c_MV_PAR11)
			c_MV_PAR11 := aOrcTrans[ni,9]
		EndIf		
		If Empty(c_MV_PAR10)
			VS1->(DbGoTo(aOrcTrans[ni,5]))
			c_MV_PAR10 := VS1->VS1_NATURE
		EndIf

		lAprMsg := .t.

		cQuery := "SELECT VS3.VS3_GRUITE , VS3.VS3_QTDCON , VS3.VS3_CODITE , VS3.VS3_ARMORI , VS3.VS3_QTDINI , "
		cQuery += 		" VS3.VS3_NUMLOT , VS3.VS3_LOTECT , VS3.VS3_OPER   , VS3.VS3_TESSAI , VS3.VS3_TESENT , "
		cQuery += 		" VS3.VS3_VALPEC , VS3.VS3_FORMUL , VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_NUMORC , "
		cQuery += 		" VS3.VS3_CENCUS , VS3.VS3_CONTA  , VS3.VS3_ITEMCT , VS3.VS3_CLVL , VS3.VS3_QTDITE "
		
		If VS3->(FieldPos("VS3_IPITRF")) > 0
			cQuery += " , VS3.VS3_IPITRF "
		EndIf

		cQuery += "FROM "+RetSqlName("VS3")+" VS3 "
		cQuery += "WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"' AND VS3.VS3_NUMORC='"+aOrcTrans[ni,2]+"' AND VS3.D_E_L_E_T_=' ' ORDER BY VS3.VS3_NUMORC"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )

		Do While !( cAliasVS3 )->( Eof() )
			
			SB1->(dbSeek(xFilial("SB1")+( cAliasVS3 )->VS3_GRUITE+( cAliasVS3 )->VS3_CODITE))
			SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+( cAliasVS3 )->VS3_ARMORI))
			nPosIte := aScan(aItensNew,{|x| x[2]+x[20]+x[24]+x[25]+x[23]+cValToChar(x[21])+x[28]+x[29]+x[30]+x[31] == SB1->B1_COD+( cAliasVS3 )->VS3_TESSAI+( cAliasVS3 )->VS3_LOTECT+( cAliasVS3 )->VS3_NUMLOT+SB2->B2_LOCAL+cValToChar(( cAliasVS3 )->VS3_VALPEC)+( cAliasVS3 )->VS3_CENCUS+( cAliasVS3 )->VS3_CONTA+( cAliasVS3 )->VS3_ITEMCT+( cAliasVS3 )->VS3_CLVL})

			nQtdIni := ( cAliasVS3 )->VS3_QTDITE	

			If nPosIte == 0
				AADD(aItensNew,{( cAliasVS3 )->VS3_CODITE,;
								SB1->B1_COD,;
								IIf(LOCALIZA(( cAliasVS3 )->VS3_CODITE),cLocalizSai,Space(15)),;
								nQtdIni,;
								0,;
								aOrcTrans[ni,6],;
								IIf(LOCALIZA(( cAliasVS3 )->VS3_CODITE),cLocalizSai,Space(15)),;
								cCliente,;
								cLojaCli,;
								cFornece,;
								cLojaFor,;
								"",;
								"",;
								"",;
								"",;
								"",;
								( cAliasVS3 )->VS3_TESENT,;
								aOrcTrans[ni,7],;
								,;
								( cAliasVS3 )->VS3_TESSAI,;
								( cAliasVS3 )->VS3_VALPEC,;
								aOrcTrans[ni,8],;
								SB2->B2_LOCAL,;
								( cAliasVS3 )->VS3_LOTECT,;
								( cAliasVS3 )->VS3_NUMLOT,;
								( cAliasVS3 )->VS3RECNO,;
								( cAliasVS3 )->VS3_NUMORC,;
								( cAliasVS3 )->VS3_CENCUS,;
								( cAliasVS3 )->VS3_CONTA,;
								( cAliasVS3 )->VS3_ITEMCT,;
								( cAliasVS3 )->VS3_CLVL,;
								If( VS3->(FieldPos("VS3_IPITRF")) > 0, ( cAliasVS3 )->VS3_IPITRF, "")})
			Else
				If aItensNew[nPosIte,17] <> ( cAliasVS3 )->VS3_TESENT
					MsgStop(STR0148+CHR(10)+CHR(13)+CHR(10)+CHR(13)+;
					RetTitle("VS3_CODITE")+ ": "+( cAliasVS3 )->VS3_CODITE+CHR(10)+CHR(13)+;
					RetTitle("VS1_NUMORC")+ ": "+aItensNew[nPosIte,27]+ " / "+( cAliasVS3 )->VS3_NUMORC,STR0084)
					( cAliasVS3 )->( dbCloseArea() )
					Return(.f.)
				EndIf
				aItensNew[nPosIte,4] += nQtdIni
			EndIf
			( cAliasVS3 )->(DbSkip())
			
		Enddo
		( cAliasVS3 )->( dbCloseArea() )
	EndIf
Next

lPerg := CriaParam(aItensNew,"1", aOrcTrans)
if !lPerg
	MsgInfo(STR0041,STR0047)
	DisarmTransaction()
	Return .F.
Endif

End Transaction

If lAprMsg	

	For i := 1 to Len(aRetorn)
		AAdd(aParam,aRetorn[i])
	Next

	lRet := FS_GERATRANS(@aItensNew,@aParam,lMultOrc,aOrcTrans)
	
	If lRet	
		For ni := 1 to Len(aOrcTrans)
			IncProc()
			If aOrcTrans[ni,1]
				VS1->(DbGoTo(aOrcTrans[ni,5]))
				dbSelectArea("VS1")
				RecLock("VS1",.f.)
				VS1->VS1_STATUS := "X"
				VS1->VS1_NUMNFI := SF2->F2_DOC
				VS1->VS1_SERNFI := SF2->F2_SERIE
				MsUnlock()
				If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
					OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0118 ) // Grava Data/Hora na Mudan็a de Status do Or็amento / Transfer๊ncia de Pe็as entre Filial
				EndIf
			EndIf
		Next
		
		DBSelectArea("SF2")
		reclock("SF2",.f.)
		cPrefAnt := SF2->F2_PREFIXO
		SF2->F2_PREFORI := cPrefBAL
		cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
		SF2->F2_PREFIXO := cPrefNF
		msunlock()
	
		If !Empty(SF2->F2_DUPL)
			cQuery    := "SELECT SE1.R_E_C_N_O_ RECSE1 "
			cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
			cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO = '"+cPrefAnt+"' AND SE1.E1_NUM = '"+SF2->F2_DUPL+"' AND  "
			cQuery    += "SE1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
			While ( cAliasSE1 )->(!Eof())
				DbSelectArea("SE1")
				DbGoTo(( cAliasSE1 )->RECSE1)
				RecLock("SE1",.f.)
					SE1->E1_PREFIXO := SF2->F2_PREFIXO
					SE1->E1_PREFORI := SF2->F2_PREFORI
				msunlock()
				( cAliasSE1 )->(DbSkip())
			Enddo
			( cAliasSE1 )->( dbCloseArea() )
		EndIf
				
		MsgInfo(STR0149) //Transfer๊ncia agrupada concluํda
	
	EndIf

	If ExistBlock("OM430FIM")
		ExecBlock("OM430FIM",.f.,.f.,{lRet})   
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDEMP บAutor  ณRenato Vinicius     บ Data ณ  29/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da Empresa Destino e Armaz้m Destino             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                            .            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VLDEMP(_cCdEmp)

Local cEmpDest := cEmpLog := ""
Local aSM0 := {}
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliForLj := {}

Default _cCdEmp := cFilAnt

If !ExistCpo("SM0",cEmpAnt+_cCdEmp)
	Return .f.
EndIf

aSM0 := FWArrFilAtu(cEmpAnt,) // Filial Origem (Filial logada)
cEmpLog := aSM0[18]

aSM0 := FWArrFilAtu(cEmpAnt,_cCdEmp) // Filial Destino (MV_PAR05)
cEmpDest := aSM0[18] // SM0->M0_CGC

If cEmpLog == cEmpDest
	MsgStop(STR0086,STR0084) //Nใo ้ possํvel realizar transfer๊ncias para a mesma filial , Aten็ใo
	Return .f.
EndIf

aCliForLj := oFilHlp:GetCodCli(_cCdEmp, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
If !Empty(aCliForLj[1]+aCliForLj[2])
	SA1->(DbGoTo(aCliForLj[3]))
	cNomEmp := SA1->A1_NOME
EndIf
dbSelectArea("SA1")
dbSetOrder(2)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SAIR  บAutor  ณ Thiago			     บ Data ณ  06/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Botao Sair tela de divergencia                             บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SAIR()
           
nAceita := 2          
oDlgDiv:End()

Return(.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONFIRMAR บAutor  ณ Thiago		     บ Data ณ  06/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirmar divergencia			                             บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONFIRMAR()
Local lOk     := .t.
Local nCntFor := 0
For nCntFor := 1 to len(aDiverg)
	If aDiverg[nCntFor,8] > aDiverg[nCntFor,5]
		MsgStop(STR0190+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				aDiverg[nCntFor,1]+" "+aDiverg[nCntFor,2]+CHR(13)+CHR(10)+aDiverg[nCntFor,3],STR0084) // Atencao
		lOk := .f.
		Exit
	EndIf
Next
If lOk
	nAceita := 1          
	oDlgDiv:End()
EndIf
Return lOk
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DIVERG   บAutor  ณ Thiago		     บ Data ณ  22/11/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de divergencia		                             บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DIVERG(cNumOrc)
Local oTmpTable
Local cQuery  := ""
Local aSize   := FWGetDialogSize( oMainWnd )
Local aCampos := {} // Array para campos da tabela temporแria e campos da View
Local lRet    := .t.
Local lTemDiverg := .f.
Local lOkTela := .f.

// Criando tabela temporแria
aadd(aCampos, {"XXX_GRUITE",GetSX3Cache("VS3_GRUITE","X3_TIPO"),GetSX3Cache("VS3_GRUITE","X3_TAMANHO")	,0} ) // VS3_GRUITE
aadd(aCampos, {"XXX_CODITE",GetSX3Cache("VS3_CODITE","X3_TIPO"),GetSX3Cache("VS3_CODITE","X3_TAMANHO")	,0} ) // VS3_CODITE
aadd(aCampos, {"XXX_DESC"  ,GetSX3Cache("B1_DESC"   ,"X3_TIPO"),GetSX3Cache("B1_DESC"   ,"X3_TAMANHO")	,0} ) // B1_DESC
aadd(aCampos, {"XXX_QATU"  ,GetSX3Cache("B2_QATU"   ,"X3_TIPO"),GetSX3Cache("B2_QATU"   ,"X3_TAMANHO")	,0} ) // B2_QATU
aadd(aCampos, {"XXX_QTDCON",GetSX3Cache("VS3_QTDCON","X3_TIPO"),GetSX3Cache("VS3_QTDCON","X3_TAMANHO")	,0} ) // VS3_QTDCON
aadd(aCampos, {"XXX_QTDITE",GetSX3Cache("VS3_QTDITE","X3_TIPO"),GetSX3Cache("VS3_QTDITE","X3_TAMANHO")	,0} ) // VS3_QTDITE
aadd(aCampos, {"XXX_VS3REC","N",15	,0} ) // RecNo VS3
oTmpTable := OFDMSTempTable():New()
oTmpTable:cAlias := "TEMP"
oTmpTable:aVetCampos := aCampos
oTmpTable:AddIndex(, {"XXX_GRUITE","XXX_CODITE"} )
oTmpTable:CreateTable()

aCampos := {}

aadd(aCampos,{STR0153,"XXX_GRUITE", GetSX3Cache("VS3_GRUITE","X3_TIPO"),20,0, Alltrim(GetSX3Cache("VS3_GRUITE","X3_PICTURE")),GetSX3Cache("VS3_GRUITE","X3_DECIMAL"),.f.})// VS3_GRUITE
aadd(aCampos,{STR0154,"XXX_CODITE", GetSX3Cache("VS3_CODITE","X3_TIPO"),20,0, Alltrim(GetSX3Cache("VS3_CODITE","X3_PICTURE")),GetSX3Cache("VS3_CODITE","X3_DECIMAL"),.f.})// VS3_CODITE
aadd(aCampos,{STR0155,"XXX_DESC"  , GetSX3Cache("B1_DESC"   ,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("B1_DESC"   ,"X3_PICTURE")),GetSX3Cache("B1_DESC"   ,"X3_DECIMAL"),.f.})// B1_DESC
aadd(aCampos,{STR0156,"XXX_QATU"  , GetSX3Cache("B2_QATU"   ,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("B2_QATU"   ,"X3_PICTURE")),GetSX3Cache("B2_QATU"   ,"X3_DECIMAL"),.f.})// B2_QATU
aadd(aCampos,{STR0157,"XXX_QTDCON", GetSX3Cache("VS3_QTDCON","X3_TIPO"),20,0, Alltrim(GetSX3Cache("VS3_QTDCON","X3_PICTURE")),GetSX3Cache("VS3_QTDCON","X3_DECIMAL"),.f.})// VS3_QTDCON
aadd(aCampos,{STR0158,"XXX_QTDITE", GetSX3Cache("VS3_QTDITE","X3_TIPO"),20,0, Alltrim(GetSX3Cache("VS3_QTDITE","X3_PICTURE")),GetSX3Cache("VS3_QTDITE","X3_DECIMAL"),.f.})// VS3_QTDITE

cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3RECNO, VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_QTDCON , VS3.VS3_QTDITE, SB2.B2_QATU, SB1.B1_DESC "
cQuery += "FROM "+RetSqlName("VS3")+" VS3 "
cQuery += " JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.B1_GRUPO = VS3.VS3_GRUITE AND SB1.D_E_L_E_T_=' '  "
cQuery += " JOIN " + RetSqlName('SB2') + " SB2 ON SB2.B2_FILIAL  = '" + xFilial('SB2') + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL = VS3.VS3_ARMORI AND SB2.D_E_L_E_T_=' ' "
cQuery += "WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"' AND VS3.VS3_NUMORC='"+cNumOrc+"' AND VS3.VS3_QTDCON < VS3.VS3_QTDITE AND VS3.D_E_L_E_T_=' ' ORDER BY VS3.VS3_NUMORC"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
aDiverg := {}
Do While !( cAliasVS3 )->( Eof() )

	aadd(aDiverg,{	( cAliasVS3 )->VS3_GRUITE,;
					( cAliasVS3 )->VS3_CODITE,;
					( cAliasVS3 )->B1_DESC,;
					( cAliasVS3 )->B2_QATU,;
					( cAliasVS3 )->VS3_QTDCON,;
					( cAliasVS3 )->VS3_QTDITE,;
					( cAliasVS3 )->(VS3RECNO),;
					( cAliasVS3 )->VS3_QTDITE;
				})

	// Cria Registros Temportarios
	RecLock("TEMP",.T.)
		TEMP->XXX_GRUITE := ( cAliasVS3 )->VS3_GRUITE
		TEMP->XXX_CODITE := ( cAliasVS3 )->VS3_CODITE
		TEMP->XXX_DESC   := ( cAliasVS3 )->B1_DESC
		TEMP->XXX_QATU   := ( cAliasVS3 )->B2_QATU
		TEMP->XXX_QTDCON := ( cAliasVS3 )->VS3_QTDCON
		TEMP->XXX_QTDITE := ( cAliasVS3 )->VS3_QTDITE
		TEMP->XXX_VS3REC := ( cAliasVS3 )->(VS3RECNO)
	TEMP->(MsUnlock())
	
	lTemDiverg := .t.

	dbSelectArea(cAliasVS3)
	( cAliasVS3 )->(DbSkip())
	
Enddo
( cAliasVS3 )->( dbCloseArea() )

if lTemDiverg

	lRet := .f.

	oDlgDiv := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0198+":"+cNumOrc+" - "+STR0152, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Orcamento

		// Cria็ใo do browse de tela
		oBrowseTmp := FWMBrowse():New( )
		oBrowseTmp:SetOwner(oDlgDiv)
		oBrowseTmp:SetTemporary(.T.) 
		oBrowseTmp:SetMenuDef("")
		oBrowseTmp:SetIgnoreARotina(.t.)
		oBrowseTmp:DisableDetails()
		oBrowseTmp:DisableConfig()
		oBrowseTmp:DisableReport()
		oBrowseTmp:SetFixedBrowse(.T.)
		oBrowseTmp:SetAlias("TEMP")
		oBrowseTmp:SetFields(aCampos)
		oBrowseTmp:AddButton(STR0159, {|| lOkTela := FS_CONFIRMAR() },,,, .F., 2)
		oBrowseTmp:AddButton(STR0160, {|| FS_SAIR() },,,, .F., 2)
		oBrowseTmp:ForceQuitButton()
		oBrowseTmp:SetDescription(STR0198+":"+cNumOrc+" - "+STR0152) // Orcamento
		oBrowseTmp:SetEditCell(.T., { || OM430021_DigitaQuantidade(.f.) })
		oBrowseTmp:SetDelete(.T. , { || OM430021_DigitaQuantidade(.t.) , oBrowseTmp:Refresh() })
		oBrowseTmp:Activate()
		oBrowseTmp:GetColumn(6):SetEdit(.T.)
		oBrowseTmp:GetColumn(6):SetReadVar("XXX_QTDITE")

	oDlgDiv:Activate( , , , , , , ) //ativa a janela

EndIf

If nAceita == 1 .and. lOkTela
	lRet := OM430031_Corrigir_Qtdes(cNumOrc)
EndIf

oTmpTable:CloseTable()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณFS_QTDLIN   บAutor  ณ Thiago		                     บ Data ณ  22/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออออออออออออออออนฑฑ
ฑฑณDescricao ณ Verifica se estourou tamanho do Acols de Pe็as p/ de acordo com MV_NUMITEN ณฑฑ
ฑฑณ			 ณ cOpcao 0= Delecao do item												  ณฑฑ
ฑฑณ			 ณ cOpcao 1= Inclusao de item novo   										  ณฑฑ
ฑฑณ			 ณ cOpcao 2= Faturamento do or็amento/Pedido  								  ณฑฑ
ฑฑณ			 ณ cOpcao 3= Digitacao da quantidade do item  								  ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_QTDLIN(cOpcao,nQtdLin)
Local i:= 0  
Local lRet := .t. 
Default nQtdLin := 0 

if cOpcao <> "3"
	if cOpcao == "0" .and. !aCols[n,Len(aCols[n])] // So faz a verificacao se o item estiver deletado e o usuario tentar voltar o item para ativo
		Return(.t.)
	Endif
	
	For i:= 1 to Len(aCols)
		if !aCols[i,Len(aCols[i])] .and. aCols[i,FG_POSVAR("VS3_QTDINI")] > 0  
			if !Empty(aCols[i,fg_posvar("VS3_GRUITE")]) .and. !Empty(aCols[i,fg_posvar("VS3_CODITE")])
				nQtdLin+=1 
			Endif	
		Endif	
	Next
	If nQtdLin > 0 .and. nMaxItNF > 0 .and. nQtdLin >= nMaxItNF .and. cOpcao <> "2"
		if ReadVar() == "M->VS3_GRUITE" .or. ReadVar() == "M->VS3_CODITE"
			M->VS3_GRUITE := space(TamSx3("VS3_GRUITE")[1])  
			M->VS3_CODITE := space(TamSx3("VS3_CODITE")[1])  
			aCols[n,fg_posvar("VS3_GRUITE")]  := space(TamSx3("VS3_GRUITE")[1])  
			aCols[n,fg_posvar("VS3_CODITE")] := space(TamSx3("VS3_CODITE")[1])  
		Endif	
		lRet := .f.
	Elseif nQtdLin > 0 .and. nMaxItNF > 0 .and. nQtdLin > nMaxItNF .and. cOpcao == "2"
		lRet := .f.                                                                      
	Endif
Else 
	If nQtdItens > 0 .and. nMaxItNF > 0 .and. nQtdItens > nMaxItNF
		lRet := .f.                                                                      
	Endif
Endif
if !lRet
	ShowHelpDlg ( "OM430NUMITEM", { STR0179 }) // "Estourou o n๚mero maximo de Itens pra gera็ใo de NF, conforme parโmetro MV_NUMITEN."
	Return .f.
Endif
if cOpcao == "2"
	if Empty(aCols[Len(aCols),fg_posvar("VS3_CODITE")])
		o430GetPecas:oBrowse:GoTop()
	Endif
Endif

Return(.t.)

/*/{Protheus.doc} OM4308001_RefreshJdprismVars
	Reseta variaveis do dpm para utiliza็ใo atual
	Criado para que ao fechar janela e incluir novo orcamento as variaveis nใo tenho lixo dos valores anteriores
	
	@type function
	@author Vinicius Gati
	@since 03/07/2018
/*/
static function OM4308001_RefreshJdprismVars()
	if lVS3_TRSFER
		If FM_SQL("SELECT COALESCE(COUNT(*),0) QTD from " + RetSQLName('VS3') + " WHERE VS3_FILIAL ='"+xFilial('VS3')+"' AND VS3_NUMORC = '"+VS1->VS1_NUMORC+"' AND D_E_L_E_T_ = ' ' AND VS3_TRSFER = '1' ") > 0
			lJDPrism := .t.
		else
			lJDPrism := .f.
		endif
	else
		lJDPrism := .f.
	endif
return


/*/{Protheus.doc} OM430014_esta_reservado
	Verifica se o recno estแ reservado para fazer tratamentos posteriores
	
	@type function
	@author Vinicius Gati
	@since 26/02/2019
/*/
static function OM430014_esta_reservado(nRecnoVS3)
	local cQuery := "SELECT COALESCE(COUNT(*),0) QTD from " + RetSQLName('VS3') + " WHERE R_E_C_N_O_ = '"+cValToChar(nRecnoVS3)+"' AND D_E_L_E_T_ = ' ' AND VS3_RESERV = '1' "
return fm_sql(cQuery) >= 1


/*/{Protheus.doc} OM430021_DigitaQuantidade

@author Andre Luis Almeida
@since 10/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM430021_DigitaQuantidade(lDeleta)
	Local nPosDiv   := 0
	Local lRetorno  := .f.
	Default lDeleta := .f.
	
	If lDeleta
		If TEMP->XXX_QTDITE > 0
			If MsgYesNo(STR0186,STR0047) // A quantidade do Item serแ zerada e o Item nใo serแ Transferido. Deseja Continuar? / Atencao
				TEMP->XXX_QTDITE := 0 // Deletar Item => ZERAR QTDE
			Else
				lRetorno := .t.
			EndIf
		EndIf
	Else
		If TEMP->XXX_QTDITE == 0
			MsgInfo(STR0187,STR0047) // Ao zerar a quantidade do Item, o mesmo nใo serแ Transferido. / Atencao
		EndIf
	EndIf

	If TEMP->XXX_QTDITE >= 0

		If TEMP->XXX_QTDITE <= TEMP->XXX_QTDCON

			lRetorno := .t.

		EndIf

	EndIf

	nPosDiv := aScan(aDiverg,{|x| x[7] == TEMP->XXX_VS3REC })
	if nPosDiv > 0 
		aDiverg[nPosDiv,8] := TEMP->XXX_QTDITE
	EndIf

Return lRetorno

/*/{Protheus.doc} OM430031_Corrigir_Qtdes

@author Andre Luis Almeida
@since 11/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM430031_Corrigir_Qtdes(cNumOrc)
Local nCntFor     := 0
Local lVS1_TRFRES := VS1->(FieldPos("VS1_TRFRES")) > 0
Local lRet        := .f.

DbSelectArea("VS1")
DbSetOrder(1)
DbSeek( xFilial("VS1") + cNumOrc )

For nCntFor := 1 to len(aDiverg)
	If aDiverg[nCntFor,8] > 0 // Verifica se existe Itens/Quantidades para Gerar NF
		lRet := .t.
		Exit
	EndIf
Next

If lRet

	Begin Transaction

	For nCntFor := 1 to len(aDiverg)

		DbSelectArea("VS3")
		DbGoTo(aDiverg[nCntFor,7])
		RecLock("VS3",.f.)
			VS3->VS3_QTDITE := aDiverg[nCntFor,8]
		MsUnLock()

		if VS3->VS3_QTDITE != VS3->VS3_QTDRES // alterou quantidade e tem reserva? reserva precisa ser atualizada
			// delecao do vs3...
			if VS3->VS3_QTDRES > 0
			// desreserva
				If oTransf:Desreserva( VS3->(recno()) , VS3->VS3_QTDCON )
					OX001VE6(VS3->VS3_NUMORC, .f.)
				else
					DisarmTransaction()
					Return .f.
				Endif
			endIf
			If lVS1_TRFRES .and. VS1->VS1_TRFRES == "1" // Reservou anteriormente
				If oTransf:AjustaRes( VS3->(recno()) )
					OX001VE6(VS3->VS3_NUMORC, .t.)
				else
					DisarmTransaction()
					Return .f.
				Endif
			Endif
		endIf

		DbSelectArea("VS3")
		If VS3->VS3_QTDITE == 0 .and. VS3->VS3_QTDRES == 0 // Deletar os Itens ZERADOS
			RecLock("VS3",.f., .t.)
			DbDelete()
			MsUnlock()
		EndIf 

	Next

	End Transaction

Else

	MsgStop(STR0189,STR0084) // Necessแrio informar a quantidade desejada dos itens para possibilitar a Transfer๊ncia. / Atencao

EndIf

Return lRet

/*/{Protheus.doc} OM4300016_PreenchimentoAutomaticoInclusao
Preenche a linha corretamente com os valores informados nos Parโmetros
@author Fernando Vitor Cavani
@since 31/01/2020
@version 1.0
@param nLinha, num้rico, Linha da aCols
@return l๓gico
@type function
/*/
Static Function OM4300016_PreenchimentoAutomaticoInclusao(nLinha)
Default nLinha := 1

If Empty(aCols[nLinha, FG_POSVAR("VS3_OPER")])
	aCols[nLinha, FG_POSVAR("VS3_OPER")]   := c_MV_PAR07
EndIf

If Empty(aCols[nLinha, FG_POSVAR("VS3_FORMUL")])
	aCols[nLinha, FG_POSVAR("VS3_FORMUL")] := c_MV_PAR08
EndIf

If Empty(aCols[nLinha, FG_POSVAR("VS3_CENCUS")])
	aCols[nLinha, FG_POSVAR("VS3_CENCUS")] := c_MV_PAR12
EndIf

If Empty(aCols[nLinha, FG_POSVAR("VS3_CONTA")])
	aCols[nLinha, FG_POSVAR("VS3_CONTA")]  := c_MV_PAR13
EndIf

If Empty(aCols[nLinha, FG_POSVAR("VS3_ITEMCT")])
	aCols[nLinha, FG_POSVAR("VS3_ITEMCT")] := c_MV_PAR14
EndIf

If Empty(aCols[nLinha, FG_POSVAR("VS3_CLVL")])
	aCols[nLinha, FG_POSVAR("VS3_CLVL")]   := c_MV_PAR15
EndIf
Return .t.

/*/{Protheus.doc} OM4300021_ObservacaoPrioridadeSeparacao
Preenche a Observa็ใo e Prioridade de Separa็ใo da Confer๊ncia

@author Andre Luis Almeida
@since 18/05/2021
@version 1.0
@type function
/*/
Function OM4300021_ObservacaoPrioridadeSeparacao(nOpc)
Local nLinha     := 0
Local aParamBox  := {}
Local aRetParam  := {}
Local lVS1PRISEP := VS1->(ColumnPos("VS1_PRISEP")) > 0
Local lVS1OBSCON := VS1->(ColumnPos("VS1_OBSCON")) > 0
Local lAltCpos   := ( nOpc == 3 .or. ( nOpc == 4 .and. VS1->VS1_STATUS == "0" ) ) // Inclusao ou Alteracao quando Status 0
Private cFiltroVX5 := "077" // Prioridade de Separa็ใo da Confer๊ncia
If lVS1PRISEP
	AADD(aParamBox,{ 1,RetTitle("VS1_PRISEP"),M->VS1_PRISEP,"@!",'vazio().or.FG_Seek("VX5","'+"'077'"+'+MV_PAR01",1)',"VX5AUX",IIf(lAltCpos,".t.",".f."),45,.f.}) // Prioridade de Separa็ใo da Confer๊ncia
EndIf
If lVS1OBSCON
	AADD(aParamBox,{ 1,RetTitle("VS1_OBSCON"),M->VS1_OBSCON,"@!",'',"",IIf(lAltCpos,".t.",".f."),120,.f.}) // Observacao
EndIf
If len(aParamBox) > 0
	If ParamBox(aParamBox,STR0194,@aRetParam,,,,,,,,.f.) // Confer๊ncia de Pe็as
		If lVS1PRISEP
			M->VS1_PRISEP := aRetParam[++nLinha]
		EndIf
		If lVS1OBSCON
			M->VS1_OBSCON := aRetParam[++nLinha]
		EndIf
	EndIf
EndIf
Return

/*/{Protheus.doc} OM4300031_Valida_e_Processa
Validar antes de realizar a Transferencia Agrupada

@author Andre Luis Almeida
@since 18/09/2021
@version 1.0
@type function
/*/
Static Function OM4300031_Valida_e_Processa(aIteTab,cCdEmp)
Local lRet       := .t.
Local aItensVS3  := {}
Local c_MV_PAR11 := ""
Local cOrcBase   := ""
Local cQueryAux  := ""
Local cQuery     := ""
Local cAliasVS3  := "SQLVS3"
Local nPos       := 0
Local nCntFor    := 0
Local lESTNEG    := (GetMV("MV_ESTNEG") == "S")
//
cQueryAux := "SELECT SB1.B1_COD ,"
cQueryAux += "       VS3.VS3_ARMORI ,"
cQueryAux += "       VS3.VS3_NUMLOT ,"
cQueryAux += "       VS3.VS3_LOTECT ,"
cQueryAux += "       SB2.B2_QATU ,"
cQueryAux += "       VS3.VS3_QTDITE "
cQueryAux += "  FROM "+RetSqlName("VS3")+" VS3 "
cQueryAux += "  JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VS3.VS3_GRUITE AND SB1.B1_CODITE=VS3.VS3_CODITE AND SB1.D_E_L_E_T_=' '"
cQueryAux += "  JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL=VS3.VS3_ARMORI AND SB2.D_E_L_E_T_=' '"
//
// Validar Saldo das Pecas se nใo ouve a Reserva - Transferencia Agrupada 
For nCntFor := 1 to len(aIteTab)
	If aIteTab[nCntFor,1] // Orcamento selecionado
		If Empty(c_MV_PAR11)
			c_MV_PAR11 := aIteTab[nCntFor,9]
			cOrcBase := aIteTab[nCntFor,2]
		EndIf
		If c_MV_PAR11 <> aIteTab[nCntFor,9]
			MsgStop(STR0191+CHR(10)+CHR(13)+CHR(10)+CHR(13)+; // Entre os or็amentos selecionados hแ Tipo de Frete diferente. Favor verificar.
			RetTitle("VS1_NUMORC")+ ": "+cOrcBase+ " / "+aIteTab[nCntFor,2],STR0084) // Atencao
			lRet := .f.
			Exit
		EndIf
		if lFaseConfer
			If !FS_DIVERG(aIteTab[nCntFor,2]) // Monta Tela de divergencia
				lRet := .f.
				Exit
			EndIf
		Endif
		If !lESTNEG // Se NรO permite Estoque Negativo, validar estoque
			cQuery := cQueryAux
			cQuery += " WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"'"
			cQuery += "   AND VS3.VS3_NUMORC='"+aIteTab[nCntFor,2]+"'"
			cQuery += "   AND VS3.VS3_RESERV <> '1'" // Validar Estoque apenas se nao teve reserva
			cQuery += "   AND VS3.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
			Do While !( cAliasVS3 )->( Eof() )
				nPos := aScan(aItensVS3,{|x| x[1]+x[2]+x[3]+x[4] ==	( cAliasVS3 )->B1_COD+;
																	( cAliasVS3 )->VS3_ARMORI+;
																	( cAliasVS3 )->VS3_LOTECT+;
																	( cAliasVS3 )->VS3_NUMLOT})
				If nPos == 0
					aAdd(aItensVS3,{ ( cAliasVS3 )->B1_COD,;
									 ( cAliasVS3 )->VS3_ARMORI,;
									 ( cAliasVS3 )->VS3_LOTECT,;
									 ( cAliasVS3 )->VS3_NUMLOT,;
									 ( cAliasVS3 )->B2_QATU,;
									 ( cAliasVS3 )->VS3_QTDITE })
				Else
					aItensVS3[nPos,6] += ( cAliasVS3 )->VS3_QTDITE
				EndIf
				( cAliasVS3 )->(DbSkip())
			Enddo
			( cAliasVS3 )->( dbCloseArea() )
		EndIf
	EndIf
Next
If lRet
	For nCntFor := 1 to len(aItensVS3)
		If aItensVS3[nCntFor,5] < aItensVS3[nCntFor,6]
			MsgStop(STR0195,STR0084) // Estoque nใo disponivel para Transfer๊ncia Agrupada. Verifique. / Atencao
			OM4300041_Levanta_Itens_com_Estoques(aIteTab)
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
//
DbSelectArea("VS1")
If lRet
	Processa( { || FS_GERTRA(aIteTab,cCdEmp) } )
EndIf
Return lRet

/*/{Protheus.doc} OM4300041_Levanta_Itens_com_Estoques
Levanta Estoque e Mostra os Itens Orcamentos selecionados

@author Andre Luis Almeida
@since 20/09/2021
@version 1.0
@type function
/*/
Static Function OM4300041_Levanta_Itens_com_Estoques(aIteTab)
Local cQueryAux  := ""
Local cQuery     := ""
Local cAliasVS3  := "SQLVS3"
Local nPos1      := 0
Local nPos2      := 0
Local nCntFor    := 0
//
aIteEst := {}
//
cQueryAux := "SELECT VS3.VS3_GRUITE ,"
cQueryAux += "       VS3.VS3_CODITE ,"
cQueryAux += "       VS3.VS3_ARMORI ,"
cQueryAux += "       VS3.VS3_NUMLOT ,"
cQueryAux += "       VS3.VS3_LOTECT ,"
cQueryAux += "       VS3.VS3_RESERV ,"
cQueryAux += "       SB1.B1_DESC ,"
cQueryAux += "       SB2.B2_QATU ,"
cQueryAux += "       VS3.VS3_QTDITE "
cQueryAux += "  FROM "+RetSqlName("VS3")+" VS3 "
cQueryAux += "  JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VS3.VS3_GRUITE AND SB1.B1_CODITE=VS3.VS3_CODITE AND SB1.D_E_L_E_T_=' '"
cQueryAux += "  JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL=VS3.VS3_ARMORI AND SB2.D_E_L_E_T_=' '"
//
// Validar Saldo das Pecas se nใo ouve a Reserva - Transferencia Agrupada 
For nCntFor := 1 to len(aIteTab)
	If aIteTab[nCntFor,1] // Orcamento selecionado
		cQuery := cQueryAux
		cQuery += " WHERE VS3.VS3_FILIAL='"+xFilial("VS3")+"'"
		cQuery += "   AND VS3.VS3_NUMORC='"+aIteTab[nCntFor,2]+"'"
		cQuery += "   AND VS3.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
		Do While !( cAliasVS3 )->( Eof() )
			nPos1 := aScan(aIteEst,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == ( cAliasVS3 )->VS3_GRUITE+;
																		 ( cAliasVS3 )->VS3_CODITE+;
																		 ( cAliasVS3 )->VS3_RESERV+;
																		 ( cAliasVS3 )->VS3_ARMORI+;
																		 ( cAliasVS3 )->VS3_LOTECT+;
																		 ( cAliasVS3 )->VS3_NUMLOT})
			If nPos1 == 0
				aAdd(aIteEst,{	( cAliasVS3 )->VS3_GRUITE,;
								( cAliasVS3 )->VS3_CODITE,;
								( cAliasVS3 )->VS3_RESERV,;
								( cAliasVS3 )->VS3_ARMORI,;
								( cAliasVS3 )->VS3_LOTECT,;
								( cAliasVS3 )->VS3_NUMLOT,;
								( cAliasVS3 )->B1_DESC,;
								( cAliasVS3 )->B2_QATU,;
								( cAliasVS3 )->VS3_QTDITE ,;
								{ { aIteTab[nCntFor,2] , ( cAliasVS3 )->VS3_QTDITE } } })
			Else
				aIteEst[nPos1,9] += ( cAliasVS3 )->VS3_QTDITE
				nPos2 := aScan(aIteEst[nPos1,10],{|x| x[1] == aIteTab[nCntFor,2] })
				If nPos2 == 0
					aAdd(aIteEst[nPos1,10],{ aIteTab[nCntFor,2] , ( cAliasVS3 )->VS3_QTDITE })
				Else
					aIteEst[nPos1,10,nPos2,2] += ( cAliasVS3 )->VS3_QTDITE
				EndIf
			EndIf
			( cAliasVS3 )->(DbSkip())
		Enddo
		( cAliasVS3 )->( dbCloseArea() )
	EndIf
Next
If len(aIteEst) == 0
	aAdd(aIteEst,{"","","","","","","",0,0,{{"",0}}})
EndIf
oLbIteEst:nAT := 1
oLbIteEst:SetArray(aIteEst)
oLbIteEst:Refresh()
OM4300061_Lista_Orcamentos_do_Item_selecionado()
Return

/*/{Protheus.doc} OM4300051_Legenda_Itens
Legenda dos Itens

@author Andre Luis Almeida
@since 20/09/2021
@version 1.0
@type function
/*/
Static Function OM4300051_Legenda_Itens()

Local aLegenda := {}

alegenda := {{'BR_VERDE'   ,STR0200},; // Item com Estoque Disponivel
             {'BR_VERMELHO',STR0201},; // Item sem Estoque Disponivel
             {'BR_AZUL'    ,STR0203}} //Item Reservado

BrwLegenda(STR0202,STR0204,aLegenda) // Legenda / Itens

Return

/*/{Protheus.doc} OM4300061_Lista_Orcamentos_do_Item_selecionado
Lista Orcamentos do Item selecionado

@author Andre Luis Almeida
@since 20/09/2021
@version 1.0
@type function
/*/
Static Function OM4300061_Lista_Orcamentos_do_Item_selecionado()

aIteOrc := aClone(aIteEst[oLbIteEst:nAt,10])
oLbIteOrc:nAT := 1
oLbIteOrc:SetArray(aIteOrc)
oLbIteOrc:Refresh()

Return
