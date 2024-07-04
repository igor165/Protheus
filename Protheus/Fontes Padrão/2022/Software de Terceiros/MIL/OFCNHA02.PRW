#INCLUDE 'TBICONN.CH'
#include "PROTHEUS.CH"
#include "OFCNHA02.CH"

//Static FMXAjustaSX1 := FindFunction("FMX_AJSX1")
//Static cGetVersao := GetVersao(.f.,.f.)

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  16/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFCNHA02
	Rotina scheduler para importação de dados - Importação PartsInfo CNH
	
	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug

	@author Vinicius Gati
	@since  16/01/2018
/*/
function OFCNHA02()
	Local cPerg := "OFCNHA02"
	Private lSchedule := FWGetRunSchedule()
	Private lDebug := "OFCNHA02" $ GetNewPar("MV_XMILDBG", "NAO")
	//
	//OFCNHA029SX1(cPerg) // Cria SX1 (Pergunte)
	//
	If lSchedule
		Pergunte("OFCNHA02",.f.)
	Else
		If !Pergunte("OFCNHA02",.t.)
			Return .t.
		EndIf
	EndIf
	OFCNHA02EXEC()
//	BatchProcess("Importação PartsInfo CNH","Este processo funciona via agendador ou menu ele vai importar os dados de peças do arquivo CNH, Direct Shipment e Lista de Preços.",;
//				cPerg,;
//				{ || OFCNHA02EXEC() })
Return .T.

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 16/01/2018
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFCNHA02",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/{Protheus.doc} OFCNHA02EXEC
	Execucao da rotina de Importacao
	
	@type function
	@author Andre Luis Almeida
	@since 31/08/2020
/*/
Static Function OFCNHA02EXEC()
If !lSchedule
	RptStatus( {|lEnd| Processo() },STR0002,STR0001, .T. ) // Aguarde... / Importando arquivo de pecas e precos CNH.
Else
	Processo()
Endif
Return

/*/{Protheus.doc} Processo
	Realiza a importação das peças partsinfo, direct shipment e lista de precos
	
	@type function
	@author Vinicius Gati
	@since 31/01/2018
/*/
Static Function Processo()
	local lSucess   := .T.
	local cTimeIni  := Time()
	local aPecDS    := {}
	local aPecPI    := {}
	local aPecLP    := {}
	local cFilePI   := "TB_PARTINFO2.txt"
	local cFileDS   := "PECAS_DSH.txt"
	local cFileLP   := "LP.txt"
	local oFile     := Nil
	local oLog      := DMS_Logger():New()
	local cCodLog   := ''
	Private nTotReg := 0
	Private cError  := ''

	DbSelectArea("SB1")
	DbSelectArea("SB5")
	DbSelectArea("SBZ")
	DbSelectArea("VBF")

	makeDir("/cnh")
	makeDir("/cnh/partsinfo")

	oFile := FWFileReader():New("/cnh/partsinfo/" + cFilePI) // PartsInfo
	if oFile:Open()
		while oFile:HasLine()
			cLinha := oFile:GetLine()
			if LEFT(cLinha, 1) != "-"
				AADD(aPecPI, cLinha)
			endif
		end
		oFile:Close()
	endif
	nTotReg += len(aPecPI)

	oFile := FWFileReader():New("/cnh/partsinfo/" + cFileDS) // DS
	if oFile:Open()
		while oFile:HasLine()
			cLinha := oFile:GetLine()
			if LEFT(cLinha, 1) != "-"
				AADD(aPecDS, cLinha)
			endif
		end
		oFile:Close()
	endif
	nTotReg += len(aPecDS)

	cCodLog := oLog:LogToTable({;
		{'VQL_AGROUP'     , 'OFCNHA02'     },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO' },;
		{'VQL_DADOS'      , ''             } ;
	})

	cFileTstp := STRTRAN(FwTimeStamp(3), ':', '-')

	If !lSchedule
		SetRegua(0) // 0 = barra infinita
		IncRegua() // Inicia barra
	EndIf

	If len(aPecPI) > 0
		begin transaction
			lSucess := OFCNHA0201ImportaPec(aPecPI)
			if ! lSucess
				DisarmTransaction()
				ShowHelpDlg(STR0003, {STR0004},5,{cError,STR0005},5) // Atenção / Erro detectado, lamentamos pelo incidente / Abra chamado para rotina OFCNHA02
			endif
		end transaction
		nStatus := FRenameEx("/cnh/partsinfo/" + cFilePI, "/cnh/partsinfo/" + "IMPORTADO_" + cFileTstp + '_' + cFilePI)
		IF nStatus == -1
			If !lSchedule
				MsgStop(STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
			Else
				conout("OFCNHA02 - "+STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
			EndIf
		Endif
	EndIf

	If len(aPecDS) > 0
		begin transaction
			lSucess := OFCNHA0202ImportaDs(aPecDS)
			if ! lSucess
				DisarmTransaction()
				ShowHelpDlg(STR0003, {STR0007},5,{STR0008,STR0005},5) // Atenção / Erro de SQL detectado, lamentamos pelo incidente / Verifique se a tabela SB5 contém o campo B5_ISDSHIP / Abra chamado para rotina OFCNHA02
			endif
		end transaction
		nStatus := FRenameEx("/cnh/partsinfo/" + cFileDS, "/cnh/partsinfo/" + "IMPORTADO_" + cFileTstp + '_' + cFileDS)
		IF nStatus == -1
			If !lSchedule
				MsgStop(STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
			Else
				conout("OFCNHA02 - "+STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
			EndIf
		Endif
	EndIf

	lSucess := OFCNHA0203ImportaListaPrecos(cFileLP)
	if ! lSucess
		ShowHelpDlg(STR0003, {STR0004},5,{cError,STR0005},5) // Atenção / Erro detectado, lamentamos pelo incidente / Abra chamado para rotina OFCNHA02
	endif
	nStatus := FRenameEx("/cnh/partsinfo/" + cFileLP, "/cnh/partsinfo/" + "IMPORTADO_" + cFileTstp + '_' + cFileLP)
	IF nStatus == -1
		If !lSchedule
			MsgStop(STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
		Else
			conout("OFCNHA02 - "+STR0006+" "+str(ferror(),4)) // Falha na operação 2 : FError 
		EndIf
	Endif

	OFCNHA0210_GeraN01()

	oLog:CloseOpened(cCodLog)

	If ExistBlock("OFCNH2PE") // PE utilizado importacao do arquivo
		ExecBlock("OFCNH2PE",.F.,.F.,{ lSchedule })
	EndIf

	If !lSchedule
		MsgInfo(STR0009+" "+cTimeIni+" -> "+Time()+" ( "+Alltrim(str(nTotReg))+" "+STR0010+" )", STR0003) // Importação concluída / registros / Atenção
	Else
		conout("OFCNHA02 - "+STR0009+" "+cTimeIni+" -> "+Time()+" ( "+Alltrim(str(nTotReg))+" "+STR0010+" )") // Importação concluída / registros
	EndIf

Return .T.

/*/{Protheus.doc} OFCNHA0201ImportaPec
	Importa as peças do arquivo da CNH
	
	@type function
	@author Vinicius Gati
	@since 31/01/2018
/*/
Function OFCNHA0201ImportaPec(aPecas)
	local nX        := 2
	local cCodigo   := ''
	local oArHlp    := DMS_ArrayHelper():New()
	local nSizeArray:= Len(aPecas)
	local cDados    := ''
	local aDadosPec := {}
	local cCodPec   := cDesc := cNHAG := cNHCE := cCIH := cCACE := ''
	local cQuery    := ''
	local cFilVBF   := xFilial('VBF')
	local cTblVBF   := RetSqlName('VBF')
	Local nT        := 0
	
	// troca os dados atuais para secundarios
	if tcSqlExec(" UPDATE " + cTblVBF + " SET VBF_FLGUSO = VBF_FLGUSO + 1 WHERE VBF_FLGUSO < 4 ") < 0
		cError := LEFT(TCSQLError(), 100)
		conout(TCSQLError())
		return .f.
	endif

	For nX := 2 to nSizeArray
		//
		If !lSchedule
			nT++
			If nT == 1000
				nT := 0
				IncRegua() // Inclui barra
			EndIf
		EndIf
		//
		cDados    := aPecas[nX]
		aDadosPec := Strtokarr2(cDados, "|", .T.) /* retorna tbm qdo resultado for branco */

		// Part Number|Descricao|NHAG|NHCE|CIH|CACE|
		cCodPec := ALLTRIM(aDadosPec[2])
		cDesc   := ALLTRIM(aDadosPec[3])
		cNHAG   := ALLTRIM(aDadosPec[4])
		cNHCO   := ALLTRIM(aDadosPec[5])
		cCAG    := ALLTRIM(aDadosPec[6])
		cCCO    := ALLTRIM(aDadosPec[7])

		reclock("VBF", .T.)
		VBF->VBF_FILIAL := cFilVBF
		VBF->VBF_CODIGO := GetSxeNum('VBF', 'VBF_CODIGO')
		VBF->VBF_PRODUT := cCodPec
		VBF->VBF_GRPPRD := '' // será preenchido depois
		VBF->VBF_CODCRI := ''
		VBF->VBF_ISCAAG := IIF(cCAG  == "Y", 'S', 'N')
		VBF->VBF_ISCACO := IIF(cCCO  == "Y", 'S', 'N')
		VBF->VBF_ISNHAG := IIF(cNHAG == "Y", 'S', 'N')
		VBF->VBF_ISNHCO := IIF(cNHCO == "Y", 'S', 'N')
		VBF->VBF_ISDSHI := 'N'
		VBF->VBF_FLGUSO := '1'
		VBF->VBF_ARMZEM := 'F01'
		VBF->VBF_FLGARQ := 'N'
		VBF->(MsUnlock())
		ConfirmSx8()
	Next

	// atualiza os produtos no VBF
	If !OFCNHA024AtualProdVBF()
		cError := LEFT(TCSQLError(), 100)
		conout(TCSQLError())
		return .f.
	EndIf

	// remove dados antigos para que a tabela não fique gigante
	if tcSqlExec(" DELETE FROM " + cTblVBF + " WHERE VBF_FLGUSO > '2' ") < 0
		cError := LEFT(TCSQLError(), 100)
		conout(TCSQLError())
		return .f.
	endif

Return .T.

/*/{Protheus.doc} OFCNHA0202ImportaDs
	Importa as peças do arquivo da CNH

	@type function
	@author Vinicius Gati
	@since 31/01/2018
/*/
Function OFCNHA0202ImportaDs(aPecas)
	local nX      := 2
	local lErr    := .f.
	local cCodigo := ''
	local cTblVBF := RetSqlName('VBF')
	Local nT      := 0

	// limpa dados anteriores
	if tcSqlExec(" UPDATE " + cTblVBF + " SET VBF_ISDSHI = 'N' WHERE VBF_ISDSHI = 'S' AND VBF_FLGUSO = '1' AND D_E_L_E_T_ = ' ' ") < 0
		Return .f.
	endif
	For nX := 2 to Len(aPecas) // começa no 2 pq o 1 é cabeçalho
		//
		If !lSchedule
			nT++
			If nT == 1000
				nT := 0
				IncRegua() // Inclui barra
			EndIf
		EndIf
		//
		cCodigo := ALLTRIM( SubStr(aPecas[nX], 3, 17) )
		if tcSqlExec(" UPDATE " + cTblVBF + " SET VBF_ISDSHI = 'S' WHERE VBF_PRODUT = '"+cCodigo+"' AND VBF_FLGUSO = '1' AND D_E_L_E_T_ = ' ' ") < 0
			lErr := .t.
			exit
		endif
	Next
	If lErr
		Return .f.
	endif

Return .t.

/*/{Protheus.doc} OFCNHA0203ImportaListaPrecos
	Importa a Lista de Preços da CNH
	
	@type function
	@author Andre Luis Almeida
	@since 22/02/2018
/*/
Function OFCNHA0203ImportaListaPrecos(cFileLP)
local nX        := 1
local oArHlp    := DMS_ArrayHelper():New()
local cDados    := ''
local cA := cB := cC := cD := cE := cF := cG := cH := cI := cJ := cK := cL := cM := cN := cO := ''
//
local cQIni     := ''
local cQFin     := ''
local nRecSB1   := 0
local nRecSB5   := 0
local nRecVBF   := 0
local cTblSB1   := RetSqlName('SB1')
local cFilSB1   := xFilial('SB1')
local cTblSB5   := RetSqlName('SB5')
local cFilSB5   := xFilial('SB5')
local cTblVBF   := RetSqlName('VBF')
local cFilVBF   := xFilial('VBF')
local lSB1      := .t.
local lVBF      := .t.
//
local cQuery    := ""
local cAlAux    := "SQLAUX"
//
local cPerg     := "OFCNHA02"
local cFabric   := ""
local cForaEst  := ""
//
Local nT        := 0
//
local nCntFor      := 0
local aCposSB1     := {}
//
If ExistBlock("OFCNH2B1") // PE utilizado para passar campos com conteudos a serem gravados nas tabelas para Lista de Preco
	aCposSB1 := ExecBlock("OFCNH2B1",.F.,.F.) // {{ "B1_TESTE" , "123" }}
EndIf
//
DBSelectArea("SB1")
DBSelectArea("SB5")
DBSelectArea("VBF")
//
DBSelectArea("VE1")
DBSetOrder(1)
DBSeek(xFilial("VE1") + MV_PAR03 )
cFabric  := left(VE1->VE1_DESMAR,20)
cForaEst := IIf(MV_PAR06==1,"N","S")
//
/////////////
// SB1/VBF //
/////////////
cQIni := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , SB5.R_E_C_N_O_ AS RECSB5 , VBF.R_E_C_N_O_ AS RECVBF "
cQIni += " FROM " + cTblSB1 + " SB1 "
cQIni += " LEFT JOIN " + cTblSB5 + " SB5 ON SB5.B5_FILIAL='"+cFilSB5+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' "
cQIni += " LEFT JOIN " + cTblVBF + " VBF ON VBF.VBF_FILIAL='"+cFilVBF+"' AND VBF.VBF_PRODUT=SB1.B1_COD AND VBF.D_E_L_E_T_ = ' ' "
cQIni += "WHERE SB1.B1_FILIAL = '" + cFilSB1 + "'"
cQIni += "  AND SB1.B1_COD = '"
//
cQFin := "' AND SB1.D_E_L_E_T_ = ' ' "
//
oFile := FWFileReader():New("/cnh/partsinfo/" + cFileLP) // Lista de Preços
if oFile:Open()
	while oFile:HasLine()
		cDados := oFile:GetLine()
		if LEFT(cDados, 1) != "-"
			nTotReg++
			//
			If !lSchedule
				nT++
				If nT == 1000
					nT := 0
					IncRegua() // Inclui barra
				EndIf
			EndIf
			//
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// 28/02/2018 - Andre - E-mail resposta de Gabriela Anselmo ( CNHI - Parts Pricing – LATAM )                 //
			// Segundo a Gabriela é necessario SEMPRE gravar/atualizar SB1/VBF com todas informações contidas no arquivo //
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			cA := ALLTRIM(substr(cDados,001,015))												// A	X(15)	15  posições alfa-numericas		Número da Peça //
			cB := ALLTRIM(substr(cDados,016,027))												// B	X(27)	27 posições alfa-numericas		Descrição do Material
			cC := ALLTRIM(substr(cDados,043,001))												// C	X(01)	01 posição alfa-numerica		Origem ( 0 = Nacional, 1 = Importado, 6 = Importada sem Similar Nacional )
			cD := ALLTRIM(substr(cDados,044,010))												// D	X(10)	10 posições alfa-numericas		Classificação Fiscal
			cE := ALLTRIM(substr(cDados,054,002)) +"."+ ALLTRIM(substr(cDados,056,002)) +"0"	// E	9(02)V9	02 inteiros + 1 decimal			Percentual do IPI
			cF := ALLTRIM(substr(cDados,058,009))												// F	9(09)	09 inteiros (gramas)			Peso Liquido em Gramas
			cG := ALLTRIM(substr(cDados,067,011)) +"."+ ALLTRIM(substr(cDados,078,002)) +"0"	// G	9(11)V99	11 inteiros + 2 decimais	Preço de Venda com IPI
			cH := ALLTRIM(substr(cDados,080,003))												// H	9(03)	03 inteiros						Quantidade Mínima por Embalagem
			cI := ALLTRIM(substr(cDados,083,001))												// I	X(01)	01 inteiro						Código de Desconto ( 0 = 45%, 1 = 35%, 2 = 30% , 3 = 25%, 7 = 15%, 9 = 0% )
			cJ := ALLTRIM(substr(cDados,084,001))												// J	X(01)	01 posição alfa-numerica		M = Identificação de PIS/Cofins Monofásico ( em branco = Integral )
			cK := ALLTRIM(substr(cDados,085,001))												// K	X(01)	01 posição alfa-numerica		Negócio ( Aplicação/modelo/Linha de Produto )
			cL := ALLTRIM(substr(cDados,086,005))												// L	X(05)	05 posição alfa-numerica		MPC = Marketing Product Code ( familia da peça )
			cM := ALLTRIM(substr(cDados,091,002)) +"."+ ALLTRIM(substr(cDados,093,001)) +"0"	// M	9(02)V9	02 inteiros + 1 decimail		EME ( % de  Desconto promocional para Emergência )
			cN := ALLTRIM(substr(cDados,094,002)) +"."+ ALLTRIM(substr(cDados,096,001)) +"0"	// N	9(02)V9	02 inteiros + 1 decimail		EST  ( % de Desconto promocional para Estoque )
			cO := ALLTRIM(substr(cDados,097,003))												// O	X(03)	03 posições alfa-numericas		Unidade de Medida ( PC, M, MM, ML, PE, GAL, KG, UM, M2, L )
			//
			If left(cA,3) == "ï»¿" // Em algumas situações esta vindo esses caracteres zuados no inicio item
				cA := substr(cA,4)
			EndIf
			//
	//		conout("OFCNHA02 - SB1/VBF/SB5: "+cA)
			//
			nRecSB1 := 0
			nRecSB5 := 0
			nRecVBF := 0
			dbUseArea(.T., "TOPCONN", TcGenQry( ,, cQIni + cA + cQFin ), cAlAux , .F. , .T.)
			If !(cAlAux)->(Eof())
				nRecSB1 := (cAlAux)->( RECSB1 )
				nRecSB5 := (cAlAux)->( RECSB5 )
				nRecVBF := (cAlAux)->( RECVBF )
			EndIf
			(cAlAux)->(DbCloseArea())
			DbSelectArea("SB1")
			If nRecSB1 > 0
				SB1->(DbGoTo(nRecSB1))
				lSB1 := .f. // Alterar SB1
			Else
				lSB1 := .t. // Inlcuir SB1
			EndIf
			RecLock("SB1",lSB1)
			If lSB1
				SB1->B1_FILIAL  := cFilSB1
				SB1->B1_COD     := cA
				SB1->B1_CODITE  := cA
				SB1->B1_GRUPO   := MV_PAR01
				SB1->B1_LOCPAD  := MV_PAR02
				SB1->B1_FABRIC  := cFabric
				SB1->B1_PROC    := MV_PAR04
				SB1->B1_LOJPROC := MV_PAR05
				SB1->B1_FORAEST := cForaEst
				SB1->B1_CONTA   := MV_PAR07
				SB1->B1_CC      := MV_PAR08
				SB1->B1_TS      := MV_PAR09
				SB1->B1_TE      := MV_PAR10
				// Campos com conteudo FIXO ( igual OFNJD01 )
				SB1->B1_PERINV  := 180
				SB1->B1_CONV    := 1
				SB1->B1_PICMENT := 0
				SB1->B1_FLAGSUG := "1"
				SB1->B1_CLASSVE := "1"
				SB1->B1_ANUENTE := "2"
				SB1->B1_MSBLQL  := "2"
				SB1->B1_BALANCA := "0"
				SB1->B1_ENVOBR  := "0"
				SB1->B1_LOCALIZ := "N"
				SB1->B1_CONTSOC := "N"
				SB1->B1_SITPROD := "N"
				SB1->B1_MONO    := "N"
				SB1->B1_FANTASM := "N"
				SB1->B1_TIPODEC := "N"
				SB1->B1_CONTRAT := "N"
				SB1->B1_IRRF    := "N"
				SB1->B1_GRADE   := "N"
				SB1->B1_IMPZFRC := "N"
				SB1->B1_TIPOCQ  := "M"
				SB1->B1_APROPRI := "D"
				SB1->B1_TIPO    := "ME"
				SB1->B1_ATIVO   := "S"
				SB1->B1_CLASSE  := ""
				SB1->B1_GARANT  := "2"
			EndIf
			SB1->B1_DESC   := cB					// B	X(27)	27 posições alfa-numericas		Descrição do Material
			SB1->B1_ORIGEM := cC					// C	X(01)	01 posição alfa-numerica		Origem ( 0 = Nacional, 1 = Importado, 6 = Importada sem Similar Nacional )
			SB1->B1_POSIPI := cD					// D	X(10)	10 posições alfa-numericas		Classificação Fiscal
			SB1->B1_IPI    := val(cE)				// E	9(02)V9	02 inteiros + 1 decimal			Percentual do IPI
			SB1->B1_PESO   := (val(cF)/1000)		// F	9(09)	09 inteiros (gramas)			Peso Liquido em Gramas
			SB1->B1_PESBRU := (val(cF)/1000)		// F	9(09)	09 inteiros (gramas)			Peso Liquido em Gramas
			SB1->B1_PRV1   := val(cG)				// G	9(11)V99	11 inteiros + 2 decimais	Preço de Venda com IPI
			SB1->B1_QE     := val(cH)				// H	9(03)	03 inteiros						Quantidade Mínima por Embalagem
			SB1->B1_PIS    := IIf(cJ=="M","S","N")	// J	X(01)	01 posição alfa-numerica		M = Identificação de PIS/Cofins Monofásico ( em branco = Integral )
			SB1->B1_COFINS := IIf(cJ=="M","S","N")	// J	X(01)	01 posição alfa-numerica		M = Identificação de PIS/Cofins Monofásico ( em branco = Integral )
			SB1->B1_UM     := lefT(cO,2)			// O	X(03)	03 posições alfa-numericas		Unidade de Medida ( PC, M, MM, ML, PE, GAL, KG, UM, M2, L )
			SB1->B1_UREV    := dDataBase
			SB1->B1_DTREFP1 := dDataBase
			If len(aCposSB1) > 0
				For nCntFor := 1 to len(aCposSB1)
					&("SB1->"+aCposSB1[nCntFor,1]) := aCposSB1[nCntFor,2]
				Next
			EndIf
			SB1->(MsUnlock())
			//
			If nRecVBF > 0
				VBF->(DbGoTo(nRecVBF))
				lVBF := .f. // Alterar VBF
			Else
				lVBF := .t. // Inlcuir VBF
			EndIf
			RecLock("VBF",lVBF)
			If lVBF
				VBF->VBF_FILIAL := cFilVBF
				VBF->VBF_CODIGO := GetSxeNum('VBF', 'VBF_CODIGO')
				VBF->VBF_PRODUT := SB1->B1_COD
				VBF->VBF_GRPPRD := SB1->B1_GRUPO
				VBF->VBF_ISDSHI := 'N'
				VBF->VBF_FLGUSO := '1'
				VBF->VBF_ARMZEM := 'F01'
				VBF->VBF_FLGARQ := 'N'
				VBF->VBF_ISCAAG := 'N'
				VBF->VBF_ISCACO := 'N'
				VBF->VBF_ISNHAG := 'N'
				VBF->VBF_ISNHCO := 'N'
				ConfirmSx8()
			EndIf
			VBF->VBF_DESEME := val(cM)	// M	9(02)V9	02 inteiros + 1 decimail		EME ( % de  Desconto promocional para Emergência )
			VBF->VBF_DESEST := val(cN)	// N	9(02)V9	02 inteiros + 1 decimail		EST  ( % de Desconto promocional para Estoque )
			VBF->VBF_CODDES := cI		// I	X(01)	01 inteiro						Código de Desconto ( 0 = 45%, 1 = 35%, 2 = 30% , 3 = 25%, 7 = 15%, 9 = 0% )
			VBF->VBF_NEGOCI := cK		// K	X(01)	01 posição alfa-numerica		Negócio ( Aplicação/modelo/Linha de Produto )
			VBF->VBF_MPCODE := cL		// L	X(05)	05 posição alfa-numerica		MPC = Marketing Product Code ( familia da peça )
			VBF->(MsUnlock())
			//
			If nRecSB5 > 0
				SB5->(DbGoTo(nRecSB5))
				RecLock("SB5",.f.)
				SB5->B5_MARPEC := MV_PAR11
				SB5->B5_CODLIN := VBF->VBF_NEGOCI
				SB5->B5_CODFAM := VBF->VBF_MPCODE
				SB5->B5_CEME   := SB1->B1_DESC
				SB5->B5_UMIND  := "1"
				SB5->(MsUnLock())
			EndIf
			//
		endif
	end
	oFile:Close()
endif

//conout("OFCNHA02 - Inserir SB5 ")
/////////////////
// Inserir SB5 //
/////////////////
cQuery := " SELECT VBF.VBF_PRODUT , "
cQuery += "        VBF.VBF_NEGOCI , "
cQuery += "        VBF.VBF_MPCODE , "
cQuery += "        SB1.B1_DESC "
cQuery += "   FROM "+cTblVBF+" VBF "
cQuery += "   JOIN "+cTblSB1+" SB1 ON ( SB1.B1_FILIAL = '" + cFilSB1 + "' AND SB1.B1_COD = VBF.VBF_PRODUT AND SB1.D_E_L_E_T_ = ' ' ) "
cQuery += "  WHERE VBF.VBF_FILIAL='"+cFilVBF+"'"
cQuery += "    AND VBF.VBF_FLGUSO = '1'"
cQuery += "    AND VBF.D_E_L_E_T_ = ' '"
cQuery += "    AND NOT EXISTS ("
cQuery += "        SELECT SB5.B5_COD"
cQuery += "          FROM "+cTblSB5+" SB5"
cQuery += "         WHERE SB5.B5_FILIAL = '"+cFilSB5+"'"
cQuery += "           AND SB5.B5_COD = VBF.VBF_PRODUT"
cQuery += "           AND SB5.D_E_L_E_T_ = ' ' )"
//
dbUseArea(.T., "TOPCONN", TcGenQry( ,, cQuery ), cAlAux , .F. , .T.)
DbSelectArea("SB5")
While !(cAlAux)->(Eof())
	//
	If !lSchedule
		nT++
		If nT == 1000
			nT := 0
			IncRegua() // Inclui barra
		EndIf
	EndIf
	//
//	conout("OFCNHA02 - SB5: "+(cAlAux)->( VBF_PRODUT ))
	RecLock("SB5",.t.)
	SB5->B5_FILIAL := cFilSB5
	SB5->B5_COD    := (cAlAux)->( VBF_PRODUT )
	SB5->B5_CEME   := (cAlAux)->( B1_DESC )
	SB5->B5_MARPEC := MV_PAR11
	SB5->B5_CODLIN := (cAlAux)->( VBF_NEGOCI )
	SB5->B5_CODFAM := (cAlAux)->( VBF_MPCODE )
	SB5->B5_UMIND  := "1"
	SB5->(MsUnLock())
	(cAlAux)->(DbSkip())
Enddo
(cAlAux)->(DbCloseArea())
DbSelectArea("SB1")
// conout("OFCNHA02 - Final: "+Time())
//
Return .T.

/*/{Protheus.doc} OFCNHA024AtualProdVBF
	Atualiza o Produto no VBF
	
	@type function
	@author Vinicius Gati
	@since 22/02/2018
/*/
Static Function OFCNHA024AtualProdVBF()
	local cTblVBF := RetSqlName('VBF')
	local cTblSB1 := RetSqlName('SB1')
	local cFilVBF := xFilial('VBF')
	local cFilSB1 := xFilial('SB1')

	if tcGetDb() == "ORACLE"
		cQuery := " UPDATE "+cTblVBF+" T1 "
		cQuery += "    SET ( VBF_GRPPRD , VBF_PRODUT ) = ( "
		cQuery += "         SELECT T2.B1_GRUPO, T2.B1_COD "
		cQuery += "           FROM "+ cTblSB1 +" T2 "
		cQuery += "          WHERE T2.B1_FILIAL  = '"+cFilSB1+"' "
		cQuery += "            AND T2.B1_COD     = T1.VBF_PRODUT "
		cQuery += "            AND T2.D_E_L_E_T_ = ' ' "
		cQuery += " ) "
		cQuery += " WHERE T1.VBF_FILIAL = '"+cFilVBF+"' "
		cQuery += "   AND T1.D_E_L_E_T_ = ' ' "
		cQuery += "   AND EXISTS ( "
		cQuery += "       SELECT PRODUT "
		cQuery += "         FROM "+ cTblSB1 +" T3 "
		cQuery += "        WHERE T3.B1_FILIAL  = '"+cFilSB1+"' "
		cQuery += "          AND T3.B1_COD    = T1.VBF_PRODUT "
		cQuery += "          AND T3.D_E_L_E_T_ = ' ' "
		cQuery += "   ) "
	else
		cQuery := " UPDATE " + cTblVBF
		cQuery += " SET VBF_GRPPRD = TMP.B1_GRUPO "
		cQuery += "   , VBF_PRODUT = TMP.B1_COD "
		cQuery += " FROM ("
		cQuery += "   SELECT B1_FILIAL, B1_COD, B1_GRUPO "
		cQuery += "     FROM " + cTblSB1
		cQuery += "    WHERE B1_FILIAL = '"+cFilSB1+"' "
		cQuery += "      AND D_E_L_E_T_ = ' ' "
		cQuery += " ) TMP "
		cQuery += " WHERE VBF_FILIAL = '"+cFilVBF+"' "
		cQuery += "   AND " + cTblVBF + ".VBF_PRODUT = TMP.B1_COD "
		cQuery += "   AND " + cTblVBF + ".D_E_L_E_T_ = ' ' "
	endif

	if tcSqlExec(cQuery) < 0 // query que preenche os B1_COD no VBF caso a peça já exista na base
		return .f.
	endif

Return .t.

/*/{Protheus.doc} OFCNHA029SX1
	Criação do SX1 (Pergunte)
	
	@type function
	@author Andre Luis Almeida
	@since 23/02/2018
Static Function OFCNHA029SX1(cPerg)
Local aRegs := {}
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aRegs,{RetTitle('B1_GRUPO')   ,RetTitle('B1_GRUPO')   ,RetTitle('B1_GRUPO')   ,"MV_CH1","C",TamSX3('B1_GRUPO')[1]   ,0,0,"G",'',"MV_PAR01",'','','','','','','','','','','','','','','','','','','','','','','','','SBM','S','','','',''})
AADD(aRegs,{RetTitle('B1_LOCPAD')  ,RetTitle('B1_LOCPAD')  ,RetTitle('B1_LOCPAD')  ,"MV_CH2","C",TamSX3('B1_LOCPAD')[1]  ,0,0,"G",'',"MV_PAR02",'','','','','','','','','','','','','','','','','','','','','','','','','NNR','S','','','',''})
AADD(aRegs,{RetTitle('VE1_CODMAR') ,RetTitle('VE1_CODMAR') ,RetTitle('VE1_CODMAR') ,"MV_CH3","C",TamSX3('VE1_CODMAR')[1] ,0,0,"G",'',"MV_PAR03",'','','','','','','','','','','','','','','','','','','','','','','','','VE1','S','','','',''})
AADD(aRegs,{RetTitle('B1_PROC')    ,RetTitle('B1_PROC')    ,RetTitle('B1_PROC')    ,"MV_CH4","C",TamSX3('B1_PROC')[1]    ,0,0,"G",'',"MV_PAR04",'','','','','','','','','','','','','','','','','','','','','','','','','SA2','S','','','',''})
AADD(aRegs,{RetTitle('B1_LOJPROC') ,RetTitle('B1_LOJPROC') ,RetTitle('B1_LOJPROC') ,"MV_CH5","C",TamSX3('B1_LOJPROC')[1] ,0,0,"G",'',"MV_PAR05",'','','','','','','','','','','','','','','','','','','','','','','','',''   ,'S','','','',''})
AADD(aRegs,{RetTitle('B1_FORAEST') ,RetTitle('B1_FORAEST') ,RetTitle('B1_FORAEST') ,"MV_CH6","N",TamSX3('B1_FORAEST')[1] ,0,0,"C",'',"MV_PAR06",'Nao','Nao','Nao','','','Sim','Sim','Sim','','','','','','','','','','','','','','','','',''   ,'S','','','',''})
AADD(aRegs,{RetTitle('B1_CONTA')   ,RetTitle('B1_CONTA')   ,RetTitle('B1_CONTA')   ,"MV_CH7","C",TamSX3('B1_CONTA')[1]   ,0,0,"G",'',"MV_PAR07",'','','','','','','','','','','','','','','','','','','','','','','','','CT1','S','','','',''})
AADD(aRegs,{RetTitle('B1_CC')      ,RetTitle('B1_CC')      ,RetTitle('B1_CC')      ,"MV_CH8","C",TamSX3('B1_CC')[1]      ,0,0,"G",'',"MV_PAR08",'','','','','','','','','','','','','','','','','','','','','','','','','CTT','S','','','',''})
AADD(aRegs,{RetTitle('B1_TS')      ,RetTitle('B1_TS')      ,RetTitle('B1_TS')      ,"MV_CH9","C",TamSX3('B1_TS')[1]      ,0,0,"G",'',"MV_PAR09",'','','','','','','','','','','','','','','','','','','','','','','','','SF4','S','','','',''})
AADD(aRegs,{RetTitle('B1_TE')      ,RetTitle('B1_TE')      ,RetTitle('B1_TE')      ,"MV_CHA","C",TamSX3('B1_TE')[1]      ,0,0,"G",'',"MV_PAR10",'','','','','','','','','','','','','','','','','','','','','','','','','SF4','S','','','',''})
AADD(aRegs,{RetTitle('B5_MARPEC')  ,RetTitle('B5_MARPEC')  ,RetTitle('B5_MARPEC')  ,"MV_CHB","C",TamSX3('B5_MARPEC')[1]  ,0,0,"G",'',"MV_PAR11",'','','','','','','','','','','','','','','','','','','','','','','','','VQS','S','','','',''})
//
If cGetVersao >= "12" .and. FMXAjustaSX1
	FMX_AJSX1(cPerg,aRegs)
ElseIf cGetVersao < "12"
	AjustaSX1(cPerg,aRegs)
EndIf
//
Return
/*/

/*/{Protheus.doc} OFCNHA0110_GeraN01
	Inserção de Itens N01 na VBF
	
	@type function
	@author Manoel Filho
	@since 01/03/2018
/*/
function OFCNHA0210_GeraN01()
	local cQuery  := ""
	local cAl     := GetNextAlias()
	local cFilVBF := xFilial('VBF')
	local cQConta := ""
	local cQPrinc := ""
	local nQtdAdd := 0
	local nQtdTra := 0
	local nQtdGra := 0
	local nQtdReg := 2000
	local nFor    := 1
	local oSqlHlp := DMS_SqlHelper():New()

	cQConta  := "SELECT COUNT(*) FROM "+oSqlHlp:Nolock('SB1')
	cQuery   := " JOIN "+oSqlHlp:NoLock('SBM')+" ON BM_FILIAL  = '"+xFilial("SBM")+"' AND B1_GRUPO = BM_GRUPO  AND BM_TIPGRU NOT IN ('4 ','7 ') AND SBM.D_E_L_E_T_ = ' ' "
	cQuery   += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery   += " AND NOT EXISTS ( "
	cQuery   += "         SELECT VBF_PRODUT "
	cQuery   += "           FROM "+oSqlHlp:Nolock('VBF')
	cQuery   += "          WHERE VBF_FILIAL = '"+xFilial("VBF")+"' "
	cQuery   += "            AND VBF_PRODUT = SB1.B1_COD AND VBF.D_E_L_E_T_= ' ' "
	cQuery   += " ) "
	cQuery   += " AND SB1.D_E_L_E_T_ = ' ' "
	nQtdAdd  := FM_SQL(cQConta+cQuery)
	cQPrinc  := "SELECT B1_COD, B1_GRUPO FROM "+oSqlHlp:Nolock('SB1')
	dbUseArea(.T., "TOPCONN", TcGenQry( ,, cQPrinc+cQuery ), cAl , .F. , .T.)

	DbSelectArea("VBF")

	nQtdTra  := Int(nQtdAdd / nQtdReg) + 1 // Aqui trabalhamos com 2000 registros inseridos por transação

	For nFor := 1 to nQtdTra

		nQtdGra := 0
		Begin Transaction

		While !(cAl)->(Eof()) .and. nQtdGra < nQtdReg

				nQtdGra++

				RecLock("VBF",.t.)
				VBF->VBF_FILIAL := cFilVBF
				VBF->VBF_CODIGO := GetSxeNum('VBF', 'VBF_CODIGO')
				VBF->VBF_PRODUT := (cAl)->(B1_COD)
				VBF->VBF_GRPPRD := (cAl)->(B1_GRUPO)
				VBF->VBF_CODCRI := ''
				VBF->VBF_ISCAAG := 'N'
				VBF->VBF_ISCACO := 'N'
				VBF->VBF_ISNHAG := 'N'
				VBF->VBF_ISNHCO := 'N'
				VBF->VBF_ISDSHI := 'N'
				VBF->VBF_CODDES := '' // esse código não vem na lista de preços do brasil
				VBF->VBF_FLGUSO := '1'
				VBF->VBF_ARMZEM := 'N01'
				VBF->VBF_FLGARQ := 'N'
				MsUnlock()
				ConfirmSx8()

				(cAl)->(DbSkip())

		Enddo

		End Transaction

	Next
	(cAl)->(DbCloseArea())
Return .t.