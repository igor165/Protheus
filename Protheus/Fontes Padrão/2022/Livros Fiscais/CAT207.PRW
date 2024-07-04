#Include "spedfiscal.ch"
#Include "PROTHEUS.CH"
Static nTamTRBIt := 50 //Tamanho do campo relac no TRB
Static lCmpCFF := CFF->(FieldPos('CFF_TIPO')) > 0
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAT207    บAutor  ณWilliam P. Alves    บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreparacao do meio magnetico CAT207 - Sistema de apuracao   บฑฑ
ฑฑบ          ณdo ICMS relativo ao custo das saidas de mercadorias e       บฑฑ
ฑฑบ          ณprestacoes de servicos                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CAT207(aWizard)
Local lEnd      := .F.
Local cNomWiz   := "CAT207"
Local oProcess

//STATIC nIndiceRet	
//STATIC lRetIndex := Iif(nIndiceRet == NIL,LoadCFFIndex(), .F.)

Local oReport
Local lProcessa := .T.
local cAliasREL := getNextAlias()
Local aArqTemp	:= {cAliasREL,""}
Local lImprime	:= .F.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Local lAutomato	:= IsBlind()

Default aWizard   := {}

If !lAutomato
	If !lVerpesssen .Or. !(MontWiz (cNomWiz))
		Return
	EndIf
EndIf	

If !lAutomato
	oProcess:= FISProgress():New({|lEnd| lEnd := PrCat207(@lEnd, aWizard, oProcess,@aArqTemp)},"Processamento da CAT207")
	oProcess:Activate()
Else
	lEnd := PrCat207(@lEnd, aWizard, oProcess,@aArqTemp,lAutomato)
EndIf

If !lAutomato
	IF AVISO("Aten็ใo!","Gerar relat๓rio conferencia do Demonstrativo da Gera็ใo de Cr้dito Acumulado – DGCA",{"Sim","Nใo"},1) == 1
		lImprime := .T.
	Endif

	If lImprime
		If !TRepInUse()
			Alert("A impressใo em TREPORT deverแ estar habilitada. Favor verificar o parโmetro MV_TREPORT.")
			lProcessa := .F.
		EndIf

		If lProcessa
			oReport:= ReportDef(aArqTemp[1])
			oReport:PrintDialog()
		EndIf
	Endif
EndIf

//Limpa arquivo temporario
DbSelectArea (aArqTemp[1])
(aArqTemp[1])->(DbCloseArea ())
Ferase (aArqTemp[2]+GetDBExtension ())
Ferase (aArqTemp[2]+OrdBagExt ())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrCat207  บAutor  ณWilliam P. Alves    บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao principal de processamento do arq. magnetico CAT207  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrCat207(lEnd,aWizard,oProcess,aArqTemp,lAutomato)
Local aAreaSM0 := SM0->(GetArea())
Local cFilBak  := cFilAnt
Local cFilDe   := ""
Local cFilAte  := ""
Local cPeriodo := ""
Local cDir     := ""
Local cNLivro  := ""
Local cNomeCfp := "CAT207"
Local cAlias   := ""
Local cAliasSF3:= "SF3"
Local cFiltro  := ""
Local cIndex   := ""
Local cLastReg := ""
Local lQuery   := .F.
Local aArq     := {}
Local aReg5010 := {}
Local aReg5315 := {}
Local aReg5340 := {}
Local aReg5320 := {}
Local aReg5325 := {}
Local aReg5330 := {}
Local aReg5335 := {}
Local aReg5350 := {}
Local aReg0300 := {}
Local aCred    := {}
Local dDataDe  := ctod("//")
Local dDataAte := ctod("//")
Local nIndex   := 0
Local nX       := 0
Local TimeFim  := Time()
Local TimeIni  := Time()
Local cAliasREL := ""
Local cFileDest := "CAT207.TXT"
Local nPercMedio:= 0
Local nForFilial:= 0
Local lSelFil   := .F.
Local aEmpresa  := {}
//Local cRelcArq		:= ""
Local aRelaCmp		:= {}

Private aReg0150 := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtribuo o conteudo do CFP gerado pelo wizard no array aWizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (!xMagLeWiz (cNomeCfp, @aWizard, .T.))
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do TRB para ser alimentado durante o processamento da rotinaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GeraTrb (1, @aArq, @cAlias)

cPeriodo := Alltrim(aWizard[1][1])
cDir     := Alltrim(aWizard[1][5])
cFileDest:= AllTrim(aWizard[1][6])
cNLivro  := Alltrim(aWizard[1][4])
dDataDe  := ctod("01/"+substr(cperiodo,1,2)+"/"+substr(cperiodo,3,4))
dDataAte := LastDate(dDataDe)
cFilDe   := Alltrim(aWizard[1][8])
cFilAte  := Alltrim(aWizard[1][9])

lSelFil  := Iif(SubStr(aWizard[1][10],1,1)=="1",.T.,.F.)

//-- Gestao de Empresas
If lSelFil
	aFilsCalc := MatFilCalc(lSelFil,,,Iif(SubStr(aWizard[1][11],1,1)=="1",.T.,.F.),,Iif(SubStr(aWizard[1][11],1,1)=="1",2,0))
	For nForFilial := 1 To Len( aFilsCalc )
		If aFilsCalc[ nForFilial, 1 ]
			aAdd(aEmpresa,{ IIf(!Empty(aFilsCalc[nForFilial][4]), aFilsCalc[nForFilial][4], Replic("0",14) ), cEmpAnt, aFilsCalc[nForFilial][2] } )
		EndIf
	Next nForFilial
EndIf

DumpFile(1, @cDir, @cFileDest,lAutomato)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao da ordem das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Tabelas Genericas
SX5->(DbSetOrder (1))
//Cadastro do Cliente
SA1->(DbSetOrder (1))
//Cadastro do Fornecedor
SA2->(DbSetOrder (1))
//Cabecalho das Notas Fiscais de Entrada
SF1->(DbSetOrder (1))
//Cabecalho das Notas Fiscais de Saida
SF2->(DbSetOrder (1))
//Condicao de pagamento
SE4->(DbSetOrder (1))
//Posicionando Livros Fiscais
SF3->(DbSetOrder (1))
//Posicionando Livros Fiscais por item
SFT->(DbSetOrder (1))
//Cadastro de TES
SF4->(DbSetOrder (1))
//GNRE
SF6->(DbSetOrder (1))
//Itens das Nfs de Entrada
SD1->(DbSetOrder (1))
//Itens das Nfs de Saida
SD2->(DbSetOrder (3))
//Cadastro de Produtos
SB1->(DbSetOrder (1))
// Enquadramento Legal da Operacao
CFE->(DbSetOrder (1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao registro Reg0000 - Abertura do arquivo digital e identificacao do contribuinteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Reg0000 (aWizard, cAlias)

If !lSelFil
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	SM0->(DbSeek(cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima
Else
	nForFilial:= 1
EndIf

//ณTRB REL = Relatorio para DEMONSTRATIVO DA GERAวรO DE CRษDITO ACUMULADO - DGCA
aRelaCmp	:=	{}
aAdd (aRelaCmp, {"R_FILIAL"		,	"C", 	FWGETTAMFILIAL})
aAdd (aRelaCmp, {"R_CFOP"		,	"C", 	4})
aAdd (aRelaCmp, {"R_INTER7"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_INTER12"	,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_INTERNA7"	,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_RED7"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_RED12"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_RED18"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_EXPORT"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_DIFER"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_ISENTO"		,	"N", 	14,	2})
aAdd (aRelaCmp, {"R_MIVA"		,	"N", 	7,	4})


aArqTemp[2]	:=	CriaTrab(aRelaCmp)
cAliasREL	:= aArqTemp[1]
DbUseArea (.T., __LocalDriver, aArqTemp[2], aArqTemp[1])
IndRegua (aArqTemp[1], aArqTemp[2], "R_FILIAL+R_CFOP")
//--------------------------


Do While Iif(!lSelFil,!SM0->(Eof ()) .And. (cEmpAnt==SM0->M0_CODIGO) .And. (SM0->M0_CODFIL<=cFilAte),nForFilial <= Len(aEmpresa))

	If !lSelFil
		cFilAnt := SM0->M0_CODFIL
	Else
		cFilAnt := aEmpresa[nForFilial][3]
	EndIf

	//-- grava็ใo da tabela CFF
	ProcCFF(dDataDe,dDataAte)

	If !lAutomato
		oProcess:Inc1Progress("Processando Filial : " + FWGETCODFILIAL)
		oProcess:SetDetProgress("Inํcio do Processamento",TimeIni,;
								"Fim Do processamento"   ,"",;
								"Tempo de processamento" ,"","","")
	EndIf

	//cFilAnt := SM0->M0_CODFIL
	nPercMedio := PercMedio(dDataDe, dDataAte)
	aReg5010 := {}
	aReg5315 := {}
	aReg5320 := {}
	aReg5325 := {}
	aReg5330 := {}
	aReg5335 := {}
	aReg5350 := {}

	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			lQuery := .T.
			cAliasSF3 := GetNextAlias()
			BeginSql Alias cAliasSF3
				SELECT
					SF3.F3_FILIAL,  SF3.F3_ENTRADA, SF3.F3_ESPECIE, SF3.F3_NFISCAL, SF3.F3_SERIE,
					SF3.F3_CLIEFOR, SF3.F3_LOJA,    SF3.F3_DTCANC,  SF3.F3_CFO,     SF3.F3_TIPO,  SF3.F3_CROUTSP
				FROM
					%Table:SF3% SF3
				WHERE
					SF3.F3_FILIAL=%xFilial:SF3% AND
					SF3.F3_ENTRADA>=%Exp:dDataDe% AND
					SF3.F3_ENTRADA<=%Exp:dDataAte% AND
					SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% AND
					SF3.%NotDel%
				ORDER BY %Order:SF3%
			EndSql
		Else
	#ENDIF
			DbSelectArea("SF3")
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F3_FILIAL=="' + xFilial("SF3") + '" .and. '
			cFiltro += 'DtoS(F3_ENTRADA)>="'+DtoS(dDataDe)+'" .and. '
			cFiltro += 'DtoS(F3_ENTRADA)<="'+DtoS(dDataAte)+'" .and. '
			cFiltro += 'Empty(F3_DTCANC) '
			IndRegua("SF3", cIndex, SF3->(IndexKey ()),, cFiltro)
			nIndex := RetIndex("SF3")
	#IFNDEF TOP
			DbSetIndex(cIndex+OrdBagExt ())
			DbSelectArea(cAliasSF3)
			(cAliasSF3)->(DbSetOrder (nIndex))
	#ENDIF

	#IFDEF TOP
		EndIf
	#ENDIF

	cLastReg := ""

	// Se retornou dados, gerar 0150 para o contribuinte.
	If !(cAliasSF3)->(Eof())
		SM00150(@aReg0150)
	EndIf

	If !lAutomato
		oProcess:Inc2Progress("Processando documentos")
	EndIf

	While !(cAliasSF3)->(Eof())
		If cLastReg <> (cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) .And. Substr((cAliasSF3)->F3_CFO,1,1) >= '5'
			//-- Movimentacao de itens (Ficha 1A)
			MovFic1A(cAlias, @aReg5315, dDataDe, dDataAte, @aReg5320, (cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE, @aReg5350, @aReg5325, aWizard, @aReg5330, @aReg5335, aCred, nPercMedio, (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, aReg5340, (cAliasSF3)->F3_CROUTSP, @aReg0300, cAliasREL)
			cLastReg := (cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
		EndIf
		(cAliasSF3)->(DbSkip())
	EndDo
	If lQuery
		(cAliasSF3)->(DbCloseArea())
	EndIf

	If !lAutomato	
		oProcess:Inc2Progress("Processando registros")
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravacao dos registros:                ณ
	//ณ5010 - Abertura da ficha 1A            ณ
	//ณ5015 - Movimentacao de itens           ณ
	//ณ5020 - IPI e outros tributos na entradaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GrRegDep (cAlias, aReg5315, aReg5320)
	GrRegDep (cAlias, aReg5315, aReg5325,.T.)
	GrRegDep (cAlias, aReg5315, aReg5330,.T.)
	GrRegDep (cAlias, aReg5315, aReg5335,.T.)
	GrRegDep (cAlias, aReg5315, aReg5340,.T.)
	GrRegDep (cAlias, aReg5315, aReg5350,.T.)

	If !lSelFil
		DbSelectArea("SM0")
		SM0->(DbSkip())
	Else
		nForFilial ++
	EndIf

EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do registro Reg0150 - Identificacao do participante  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to len(aReg0150)
	GrCatTrb (cAlias,aReg0150[nX][2], {aReg0150[nX]})
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do registro Reg0300 - Enquadramento Legal da Operacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GrCatTrb(cAlias,,aReg0300)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao dos indicadores de movimento dos registros ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GrvIndMov (cAlias)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGeracao arquivo magneticoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lAutomato
	oProcess:Inc2Progress("Gerando arquivo")
EndIf

OrgTxt (cAlias, cFileDest)

DumpFile(2,,cFileDest,lAutomato)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFechar TRB geradoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GeraTrb (2, @aArq, @cAlias)

If !lAutomato
	oProcess:Inc2Progress("Concluํdo")
	TimeFim := Time()
	oProcess:SetDetProgress("Inํcio do Processamento",TimeIni,;
							"Fim do Processamento"   ,TimeFim,;
							"Tempo de Processamento" ,ELAPTIME(TimeIni,TimeFim),"","")
EndIf

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0000   บAutor  ณWilliam P. Alves    บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do arquivo digital e identificacao do contribuinteบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg0000 (aWizard, cAlias)
Local aReg := {}
Local lRet := .T.
Local nPos := 0

aAdd(aReg, {})
nPos := Len (aReg)
aAdd (aReg[nPos], "0000")																														//01 - REG
aAdd (aReg[nPos], "LASIMCA")																													//02 - LASIMCA
aAdd (aReg[nPos], SubStr (aWizard[1][2], 1, 2))																								//03 - COD_VER
aAdd (aReg[nPos], SubStr (aWizard[1][3], 1, 2))																								//04 - COD_FIN
aAdd (aReg[nPos], SubStr (aWizard[1][1], 1, 6))																								//05 - PERIODO
aAdd (aReg[nPos], SM0->M0_NOMECOM)																												//06 - NOME
aAdd (aReg[nPos], ConvType(VldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, ""))))														//07 - CNPJ
aAdd (aReg[nPos], ConvType(VldIE(SM0->M0_INSC,.F.,.F.)))																						//08 - IE
aAdd (aReg[nPos], ConvType(VldIE(SM0->M0_CNAE,.F.,.F.)))																						//09 - CNAE
aAdd (aReg[nPos], Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN))	//10 - COD_MUN
aAdd (aReg[nPos], SubStr (aWizard[1][7], 1, 12))																								//11 - IE_INTIMA

GrCatTrb (cAlias,, aReg)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0150   บAutor  ณWilliam P. Alves    บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRegistro 0150 - Cadastro de participantes                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ2 - varios por arquivo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg0150(aReg0150,aDadosReg)

Local nPos := 0
Local nX   := 0

/*
Estrutura do Array aDadosReg:

01 REG - "0150"
02 COD_PART
03 NOME
04 COD_PAIS
05 CNPJ
06 IE
07 UF
08 CEP
09 END
10 NUM
11 COMPL
12 BAIRRO
13 COD_MUN
14 FONE
*/

nPos := aScan(aReg0150,	{|aX| AllTrim(aX[2]) == AllTrim(aDadosReg[2]) .Or. ;
                             (AllTrim(aX[5]) == AllTrim(aDadosReg[5]) .And. !Empty(aX[5]))})
If nPos == 0
	aAdd (aReg0150, {})
	nPos := Len(aReg0150)
	For nX := 1 to Len(aDadosReg)
		aAdd (aReg0150[nPos], aDadosReg[nX])
	Next
EndIf

Return (nPos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg0300   บAutor  ณWilliam P. Alves    บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura do arquivo digital e identificacao do contribuinteบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CatReg0300(aReg0300, cCodigo)

Local nPos := 0
Local cCodEnq := ""

If !Empty(cCodigo)

	If (nPos := aScan(aReg0300, {|x| x[3] == cCodigo})) == 0
		
		If CFE->(MsSeek(xFilial("CFE") + cCodigo))
		
			aAdd(aReg0300, {})
			nPos := Len(aReg0300)
			aAdd(aReg0300[nPos], "0300")			//01 - REG					//02 - LASIMCA
			aAdd(aReg0300[nPos], StrZero(nPos,4))	//02 - COD_LEGAL
			aAdd(aReg0300[nPos], CFE->CFE_CODIGO)	//03 - DESC
			aAdd(aReg0300[nPos], CFE->CFE_ANEXO)	//04 - ANEX
			aAdd(aReg0300[nPos], CFE->CFE_ART)	//05 - ART
			aAdd(aReg0300[nPos], CFE->CFE_INC)	//06 - INC
			aAdd(aReg0300[nPos], CFE->CFE_ALIN)	//07 - ALIN
			aAdd(aReg0300[nPos], CFE->CFE_PRG)	//08 - PRG
			aAdd(aReg0300[nPos], CFE->CFE_ITM)	//09 - ITM
			aAdd(aReg0300[nPos], CFE->CFE_LTR)	//10 - LTR
			aAdd(aReg0300[nPos], CFE->CFE_OBS)	//11 - OBS
			
		EndIf
		
	EndIf

	cCodEnq := aReg0300[nPos, 2]

EndIf

Return cCodEnq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg5315   บAutor  ณWilliam P. Alves    บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMovimentacao de itens (ficha 1A)                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ3 - varios por arquivo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MovFic1A(cAlias, aReg5315, dDataDe, dDataAte, aReg5320, cNfiscal, cSerie, aReg5350, aReg5325, aWizard, aReg5330, aReg5335, aCred, nPercMedio, cCliente, cLoja, aReg5340, nCrOutSP, aReg0300, cAliasREL)
Local nPos5315  := 0
Local nPos5320  := 0
Local nPos5325  := 0
Local nPos5330  := 0
Local nPos5335  := 0
Local nCredAcum := 0
Local nIdxDev   := 1
Local nX        := 0
Local nZ        := 0
Local lRet      := .T.
Local aDevol    := {}
Local aSaid     := {}
Local aCredAcum := {}
Local cCodLegal := ""
Local cCodInc   := ""
Local cDeclExp  := ""
Local cCodExp 	:= ""
Local cNrLivro  := Alltrim(aWizard[1][4])
Local lEEC      := GetNewPar("MV_EECFAT",.F.)
Local cDataOri	:= ""
Local cNfOri	:= ""
Local cSerieOri	:= ""
Local lEnt		:= .F.
Local l5315		:= .F.
Local l5320		:= .F.
Local l5325		:= .F.
Local l5330		:= .F.
Local l5335		:= .F.
Local nCredEst	:= 0
Local cNotaDev	:= ""
Local cSerDev  	:= ""
Local nCredAdev	:= 0
Local cNroDec	:= ""
Local cExpInd	:= ""
Local cAlisCdl 	:= ""
Local dDatDoc	:= ""
Local cCFOPInd 	:= GetNewPar("MV_EXPIND","5501/5502/6501/6502")

DEFAULT aReg5315   := {}
DEFAULT aReg5320   := {}
DEFAULT aReg5325   := {}
DEFAULT aReg5330   := {}
DEFAULT aReg5335   := {}
DEFAULT aReg5350   := {}
DEFAULT cNfiscal   := ""
DEFAULT cSerie     := ""
DEFAULT aCred      := {}
DEFAULT nPercMedio := 0
DEFAULT nCrOutSP   := 0
DEFAULT aReg0300   := {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ   Devolucoes   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aDevol := BuscEntr(dDataDe, dDataAte, cNfiscal, cSerie, cCliente, cLoja)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ   Movimentacoes de Saida   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSaid := BuscSaida(dDataDe, dDataAte, cNfiscal, cSerie, .F., nPercMedio, cNrLivro, @aCredAcum, cAliasREL)

/*
Conforme consulta realizada na SEFAZ, caso a nota possua itens com hip๓teses de gera็ใo de cr้dito acumulado diferentes ou 
com hip๓teses nใo geradoras de cr้dito acumulado, estes devem ser informados em registros 5315 diferentes. 
Por este motivo o array aSaid possui quebra pelo campo F4_CRDACUM.
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInclui Saidas aReg5315ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aSaid)
		
	//-- Se operacao geradora de credito acumulado.
	If aSaid[nX][8] == "1"
		
		//-- Credito acumulado = Cr้dito estimado - ICMS Tributado
		nCredAcum := aSaid[nX][19] - aSaid[nX][20]
		
		//-- Se a operacao gerou Credito Acumulado > 0
		If nCredAcum >= 0
			
			//-- Geracao do registro 0300 - Enquadramento legal da operacao			
			cCodLegal := CatReg0300(@aReg0300, aSaid[nX][16])
			
			//-- Codigo da Hipotese de Geracao de Credito Acumulado
			cCodInc := aSaid[nX][16] 
			
			/*
				Chamada do registro 5315 c/ lAcumula = .F. pois o array
				aSaid ja vem agrupado POR HIPOTESE. Este array nao deve
				ser agrupado por ITEM. Deve ser gerado um conjunto de
				5315/5325 com os valores somados de cada hipotese da NF.			
			*/
			
			nPos5315 := Reg5315(@aReg5315, aSaid[nX], nCrOutSP, .F., .F.)
		
			//-- Registro 5325 - Operacoes geradoras de credito acumulado
			aAdd(aReg5325, {})
			nPos5325 := Len(aReg5325)
			aAdd(aReg5325[nPos5325], nPos5315)					  //Posicao de relacionamento com o registro 5315
			aAdd(aReg5325[nPos5325], "5325")					  // 01 - REG
			aAdd(aReg5325[nPos5325], cCodLegal)			  // 02 - COD_LEGAL
			aAdd(aReg5325[nPos5325], aSaid[nX, 17])			  // 03 - IVA_UTLIZADO
			aAdd(aReg5325[nPos5325], aSaid[nX, 18])			  // 04 - PER_MED_ICMS
			aAdd(aReg5325[nPos5325], aSaid[nX, 19] * nIdxDev) // 05 - CRED_EST_ICMS
			aAdd(aReg5325[nPos5325], nCredAcum * nIdxDev)	  // 06 - ICMS_GERA
			
			If cCodInc$"01|02|03|04|05|06"	
						
				//-- Registro 5330 - Fichas 6A (Aliq.Diversas) e 6B (Reducao)
				aAdd(aReg5330, {})
				nPos5330 := Len(aReg5330)
				aAdd(aReg5330[nPos5330], nPos5315)					//Posicao de relacionamento com o registro 5315
				aAdd(aReg5330[nPos5330], "5330")					// 01 - REG
				aAdd(aReg5330[nPos5330], aSaid[nX, 21] * nIdxDev)	// 02 - VALOR_BC
				aAdd(aReg5330[nPos5330], aSaid[nX, 20] * nIdxDev)	// 03 - ICMS_DEB
								
			ElseIf ( (aSaid[nX][23] == "EX" .Or. Alltrim(aSaid[nX][25]) $ cCFOPInd) .And. (!Alltrim(aSaid[nX][25])$"5663/5664/5665/5666/6663/6664/6665/6666") ) // Compara็ใo identica a da MATA926 
				
				cExpInd := ""
				If lEEC 
					//Caso possua integra็ใo com o m๓dulo EEC irแ buscar dados da fun็ใo AvGetExpSped localizada no fonte avgeral.prw		
					AvGetExpSped(dDataDe, dDataAte, .F.)

					If Select("SPED1100") > 0 .And. SPED1100->(DbSeek(aSaid[nX][26]) )
					
						//-- Registro 5335 - Fichas 6C (Exportacao) e 6D (ZFM)
						If Select("SPED1110") > 0 .And. SPED1110->(DbSeek(aSaid[nX][26]+SPED1100->ID ) )
							cNroDec := "INDIRETA"
							cExpInd	:= "0"
						Elseif Alltrim(SPED1100->NRO_DE) <> ''
							cNroDec := SPED1100->NRO_DE
							cExpInd	:= "0"
						Else
							cNroDec := ''
							cExpInd	:= "1"
						Endif

						aAdd(aReg5335, {})
						nPos5335 := Len(aReg5335)
						aAdd(aReg5335[nPos5335], nPos5315)									//Posicao de relacionamento com o registro 5315
						aAdd(aReg5335[nPos5335], "5335")							 		// 01 - REG
						aAdd(aReg5335[nPos5335], cNroDec)									// 02 - NUM_DECL_EXP
						aAdd(aReg5335[nPos5335], cExpInd)									// 03 - COMP_OPER - Comprovacao da Operacao = 0-Sim;1-Nao

						If cExpInd == "0" .and. cNroDec == "INDIRETA"
							While SPED1110->(!Eof()) .And. (aSaid[nX][26]+SPED1100->ID) == SPED1110->(PREEMB+ID)
								//-- Registro 5340 - DADOS DA EXPORTACAO INDIRETA COMPROVADA - FICHA 5H //-- Tipo Exp.= 1-Indireta	
								dDatDoc := Stod(Right(SPED1110->DT_DOC,4) + SubStr(SPED1110->DT_DOC,3,2) + Left(SPED1110->DT_DOC,2) ) // Necessario fazer esta tratativa p๓is o retorno estava em formato de caracter DDMMAAAA
								If aScan(aReg5340, {|x| x[1] == nPos5315  		  .And.;
														x[3] == dDatDoc  		  .And.;
														x[4] == SPED1110->NUM_DOC .And.;
														x[5] == SPED1110->SER     .And.;
														x[6] == SPED1110->NR_MEMO} ) == 0												
									aAdd(aReg5340, {})
									nReg5340 := Len(aReg5340)
									aAdd(aReg5340[nReg5340], nPos5315)				//Posicao de relacionamento com o registro 5315
									aAdd(aReg5340[nReg5340], "5340")				// 01 - REG
									aAdd(aReg5340[nReg5340], dDatDoc)	  			// 02 - DATA_DOC_IND
									aAdd(aReg5340[nReg5340], SPED1110->NUM_DOC)		// 03 - NUM_DOC_IND
									aAdd(aReg5340[nReg5340], SPED1110->SER)			// 04 - SER_DOC_IND
									aAdd(aReg5340[nReg5340], SPED1110->NR_MEMO)		// 05 - NUM_DECL_EXP_IND
								Endif	
								SPED1110->(dbSkip())
							Enddo	
						Endif		
					Endif	
				Endif							
				If !lEEC .Or. Empty(cExpInd)

					//-- Complemento de Exportacao
			 		If BuscCDL(aSaid[nX][1], aSaid[nX][2], aSaid[nX][24], aSaid[nX][4], @cAlisCdl)
					
						// Sem integra็ใo com EEC
						// Doc + Serie + Cli/For + Loja 
						If ((cAlisCdl)->(Alltrim(CDL_DOC) + Alltrim(CDL_SERIE) + Alltrim(CDL_CLIENT) + Alltrim(CDL_LOJA) ) == (Alltrim(aSaid[nX][1]) + Alltrim(aSaid[nX][2]) + Alltrim(aSaid[nX][24]) + Alltrim(aSaid[nX][4]) ) )						
							If (cAlisCdl)->CDL_NATEXP == "1"
								cDeclExp := "INDIRETA"
								cCodExp  := "0"
							Elseif Alltrim((cAlisCdl)->CDL_NUMDE) <> ''
								cDeclExp := (cAlisCdl)->CDL_NUMDE //Numero da declaracao simplificada de exportacao
								cCodExp  := "0"
							Else
								cDeclExp := (cAlisCdl)->CDL_NUMDE //Numero da declaracao simplificada de exportacao
								cCodExp  := "1"
							Endif	

							//-- Registro 5335 - Fichas 6C (Exportacao Direta e Indireta) e 6D (ZFM)
							aAdd(aReg5335, {})
							nPos5335 := Len(aReg5335)
							aAdd(aReg5335[nPos5335], nPos5315)								//Posicao de relacionamento com o registro 5325
							aAdd(aReg5335[nPos5335], "5335")								// 01 - REG
							aAdd(aReg5335[nPos5335], cDeclExp)								// 02 - NUM_DECL_EXP
							aAdd(aReg5335[nPos5335], cCodExp)								// 03 - COMP_OPER - Comprovacao da Operacao = 0-Sim;1-Nao

							If cCodExp == "0" .and. (cAlisCdl)->CDL_NATEXP == "1"
								(cAlisCdl)->(DbGotop())
								While (cAlisCdl)->(!Eof()) .And. ((cAlisCdl)->(Alltrim(CDL_DOC) + Alltrim(CDL_SERIE) + Alltrim(CDL_CLIENT) + Alltrim(CDL_LOJA) ) == (Alltrim(aSaid[nX][1]) + Alltrim(aSaid[nX][2]) + Alltrim(aSaid[nX][24]) + Alltrim(aSaid[nX][4]) ) )						
									//-- Registro 5340 - DADOS DA EXPORTACAO INDIRETA COMPROVADA - FICHA 5H
									If aScan(aReg5340, {|x| x[1] == nPos5315 .And.;
															x[3] == (cAlisCdl)->CDL_EMIEXP .And.;
															x[4] == (cAlisCdl)->CDL_NFEXP  .And.;
															x[5] == (cAlisCdl)->CDL_SEREXP .And.;
															x[6] == (cAlisCdl)->CDL_NUMDE}) == 0
										aAdd(aReg5340, {})
										nReg5340 := Len(aReg5340)
										aAdd(aReg5340[nReg5340], nPos5315)     				//Posicao de relacionamento com o registro 5325
										aAdd(aReg5340[nReg5340], "5340")		    		// 01 - REG
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_EMIEXP)	// 02 - DATA_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_NFEXP)		// 03 - NUM_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_SEREXP)  	// 04 - SER_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_NUMDE)   	// 05 - NUM_DECL_EXP_IND
									Endif	
									(cAlisCdl)->(DbSkip())
								Enddo
							Endif	
						Endif
					Endif	
				Endif	
			EndIf
		Else
			//-- Se calculo credito acumulado (CAMPO 6 - REGISTRO 5325) for negativo
			/*
				Chamada do registro 5315 com lAcumula = .T. pois quando nao houver
				geracao de credito presumido os valores devem ser acumulados em um
				unico conjunto de 5315/5350 sem quebrar por hipotese.
			*/
			nPos5315 := Reg5315(@aReg5315, aSaid[nX], nCrOutSP, .T., .F.)
			//-- Registro 5350: Operacoes Nao Geradoras de Credito Acumulado - Ficha 6F 
			Reg5350(@aReg5350, aSaid[nX], nPos5315, .F.)

		EndIf
	Else		
		/*
			Chamada do registro 5315 com lAcumula = .T. pois quando nao houver
			geracao de credito presumido os valores devem ser acumulados em um
			unico conjunto de 5315/5350 sem quebrar por hipotese.
		*/
		nPos5315 := Reg5315(@aReg5315, aSaid[nX], nCrOutSP, .T., .F.)
		//-- Registro 5350: Operacoes Nao Geradoras de Credito Acumulado - Ficha 6F
		Reg5350(@aReg5350, aSaid[nX], nPos5315, .F.)
	EndIf


	//Altera็ใo para gera็ใo dos Registros da Nota de Devolu็ใo de venda quando nota original devolvida teve cr้dito acumulado
	If aScan(aDevol, {|x| x[1] + x[2] == aSaid[nX, 1] + aSaid[nX, 2]}) > 0
		//guardar os dados da nota de venda para o registro 5320 e o CFOP 
		cDataOri		:= aSaid[nX,5] // data
		cNfOri			:= aSaid[nX,1] //numero
		cSerieOri		:= aSaid[nX,2] //serie
		lEnt			:= .F.
		l5320 			:= .F.
		l5325 			:= .F.
		l5330 			:= .F.
		l5335 			:= .F.
		l5315 			:= .F.
		lOrder			:= .F.
		cNotaDev		:= ""
		cSerieDev		:= ""
		For nz := 1 to Len(aDevol)		
            //Zera as variaveis de controle quando se tratar de uma outra nota de devolu็ใo para a mesma nota de saํda
			If aDevol[nZ,3] <> cNotaDev .Or. aDevol[nZ,4] <> cSerDev 
				lEnt   		:= .F.
				l5320  		:= .F.
				l5325  		:= .F.
				l5330  		:= .F.
				l5335  		:= .F.
				l5315  		:= .F.
				cNotaDev  	:= aDevol[nZ,3]
				cSerDev   	:= aDevol[nZ,4]
			Endif
			//Controle criado para ordena็ใo dos registro. Ap๓s a cria็ใo dos registros das devolu็๕es com credito aculado sairแ fo FOR das devolu็๕es,
			//para que assim possa criar os registros das saํdas sem credito aculado antes de criar os registros das dewvolu็๕es sem credito acumulado.
			If !lEnt .And. aDevol[nZ,14] == "1" .And. aDevol[nZ,15] == " "
				lEnt := .T.
			ElseIf lEnt .And. aDevol[nZ,14] == "2"
				Exit	
			Endif
			//Controle criado para que quando retornar para o FOR das devolu็๕es nใo passe pelos registros do Array aDevol que jแ foram tratados anteriormente.
			If aDevol[nZ,15] == "X"
				Loop
			Else
				aDevol[nZ,15] := "X"	
			Endif	

			nIdxDev := -1
			nCredEst	 := ((aDevol[nZ,8] / (1 + aSaid[nX,17,1])) * (aSaid[nX,18,1] / 100))//Calculo credito estimado

			nCredAdev := nCredEst - aDevol[nZ,10]//Cแlcula de Cr้dito Gerado com os valores da nota de devolu็ใo sobrescrevendo o Calculo da nota de venda para gera็ใo do 5325
			
			//Tratativa efetuada para que na primeira passagem do for force a cria็ใo de um novo registro e nas demais passagem acumule no mesmo registro criado anteriormente.
			If !l5315
				nPos5315 := Reg5315(@aReg5315, aSaid[nX], nCrOutSP, .F., .T., aDevol[nZ])
				aReg5315[nPos5315, 10] := .T.
				l5315 := .T.
			Else
				nPos5315 := Reg5315(@aReg5315, aSaid[nX], nCrOutSP, .T., .T., aDevol[nZ])
			Endif	

			//-- Registro 5320 - Devolucao de Saida (nao gerar duplicado se diversos doc.saida)
			If !l5320
				//-- Devolucao ocorrida no mesmo periodo da saida deve ser lancada nesta ficha de modo a anular, nas mesmas colunas, os lancamentos da saida correspondente.
				//-- Informado numero do documento fiscal de saida (na NF de venda) e nao do documento de devolucao (NF de devolucao).				
				aAdd(aReg5320, {})
				nPos5320 := Len(aReg5320)
				aAdd(aReg5320[nPos5320], nPos5315)					//Posicao de relacionamento com o registro 5315
				aAdd(aReg5320[nPos5320], "5320")					// 01 - REG
				aAdd(aReg5320[nPos5320], cDataOri)					// 02 - DT_SAI
				aAdd(aReg5320[nPos5320], aDevol[nZ,6])				// 03 - TIP_DOC
				aAdd(aReg5320[nPos5320], cSerieOri)					// 04 - SER
				aAdd(aReg5320[nPos5320], cNfOri)					// 05 - NUM_DOC
				l5320 := .T.
			EndIf

			If (aDevol[nZ,14] == "1") .and. nCredAcum >= 0 // nCredAcum - Se gerou cr้dito acumulado na saํda
				
				//-- Registro 5325 - Operacoes geradoras de credito acumulado
				If !l5325
					aAdd(aReg5325, {})
					nPos5325 := Len(aReg5325)
					aAdd(aReg5325[nPos5325], nPos5315)					  	//Posicao de relacionamento com o registro 5315
					aAdd(aReg5325[nPos5325], "5325")					  	// 01 - REG
					aAdd(aReg5325[nPos5325], cCodLegal)			  			// 02 - COD_LEGAL
					aAdd(aReg5325[nPos5325], aSaid[nX, 17])			  		// 03 - IVA_UTLIZADO
					aAdd(aReg5325[nPos5325], aSaid[nX, 18])			  		// 04 - PER_MED_ICMS
					aAdd(aReg5325[nPos5325], nCredEst * nIdxDev) 			// 05 - CRED_EST_ICMS
					aAdd(aReg5325[nPos5325], nCredAdev * nIdxDev)	  		// 06 - ICMS_GERA
					l5325 := .T.
				Else
					aReg5325[nPos5325,6] += nCredEst * nIdxDev 				// 05 - CRED_EST_ICMS
					aReg5325[nPos5325,7] += nCredAdev * nIdxDev 	    	// 06 - ICMS_GERA
				Endif

				If cCodInc$"01|02|03|04|05|06"	
					//-- Registro 5330 - Fichas 6A (Aliq.Diversas) e 6B (Reducao)
					If !l5330
						aAdd(aReg5330, {})
						nPos5330 := Len(aReg5330)
						aAdd(aReg5330[nPos5330], nPos5315)					//Posicao de relacionamento com o registro 5315
						aAdd(aReg5330[nPos5330], "5330")					// 01 - REG
						aAdd(aReg5330[nPos5330], aDevol[nZ,09] * nIdxDev)	// 02 - VALOR_BC
						aAdd(aReg5330[nPos5330], aDevol[nZ,10] * nIdxDev)	// 03 - ICMS_DEB
						l5330 := .T.
					Else
						aReg5330[nPos5330,3] += aDevol[nZ,09] * nIdxDev		// 02 - VALOR_BC
						aReg5330[nPos5330,4] += aDevol[nZ,10] * nIdxDev		// 03 - ICMS_DEB
					Endif					
			
				// Devolu็ใo de exporta็ใo esta buscando dados da nota origem pois era desta forma que esta fazendo no legado.			
				ElseIf aSaid[nX][23] == "EX" .And. (!Alltrim(aDevol[nZ,18])$"1663/1664/2663/2664") // Compara็ใo identica a da MATA926 

					cExpInd	:= ""
					if lEEC
						//Caso possua integra็ใo com o m๓dulo EEC irแ buscar dados da fun็ใo AvGetExpSped localizada no fonte avgeral.prw		
						If !l5335 .And. Select("SPED1100") > 0 .And. SPED1100->(DbSeek(aSaid[nX][26]) ) 
							//-- Registro 5335 - Fichas 6C (Exportacao) e 6D (ZFM)
							If Select("SPED1110") > 0 .And. SPED1110->(DbSeek(aSaid[nX][26]+SPED1100->ID ) )
								cNroDec := "INDIRETA"
								cExpInd	:= "0"
							Elseif Alltrim(SPED1100->NRO_DE) <> ''
								cNroDec := SPED1100->NRO_DE
								cExpInd	:= "0"
							Else
								cNroDec := ''
								cExpInd	:= "1"
							Endif

							aAdd(aReg5335, {})
							nPos5335 := Len(aReg5335)
							aAdd(aReg5335[nPos5335], nPos5315)									//Posicao de relacionamento com o registro 5315
							aAdd(aReg5335[nPos5335], "5335")							 		// 01 - REG
							aAdd(aReg5335[nPos5335], cNroDec)									// 02 - NUM_DECL_EXP
							aAdd(aReg5335[nPos5335], cExpInd)									// 03 - COMP_OPER - Comprovacao da Operacao = 0-Sim;1-Nao
							l5335 := .T.

							If cExpInd == "0"
								While SPED1110->(!Eof()) .And. (aSaid[nX][26]+SPED1100->ID) == SPED1110->(PREEMB+ID)
									dDatDoc := Stod(Right(SPED1110->DT_DOC,4) + SubStr(SPED1110->DT_DOC,3,2) + Left(SPED1110->DT_DOC,2) ) // Necessario fazer esta tratativa p๓is o retorno estava em formato de caracter DDMMAAAA
									//-- Registro 5340 - DADOS DA EXPORTACAO INDIRETA COMPROVADA - FICHA 5H //-- Tipo Exp.= 1-Indireta			
									If aScan(aReg5340, {|x| x[1] == nPos5315		  .And.;
															x[3] == dDatDoc  		  .And.;
															x[4] == SPED1110->NUM_DOC .And.;
															x[5] == SPED1110->SER     .And.;
															x[6] == SPED1110->NR_MEMO} ) == 0										
										aAdd(aReg5340, {})
										nReg5340 := Len(aReg5340)
										aAdd(aReg5340[nReg5340], nPos5315)				//Posicao de relacionamento com o registro 5315
										aAdd(aReg5340[nReg5340], "5340")				// 01 - REG
										aAdd(aReg5340[nReg5340], dDatDoc)				// 02 - DATA_DOC_IND
										aAdd(aReg5340[nReg5340], SPED1110->NUM_DOC)		// 03 - NUM_DOC_IND
										aAdd(aReg5340[nReg5340], SPED1110->SER)			// 04 - SER_DOC_IND
										aAdd(aReg5340[nReg5340], SPED1110->NR_MEMO)		// 05 - NUM_DECL_EXP_IND
									Endif	
									SPED1110->(dbSkip())
								Enddo	
							Endif
						Endif	
					Endif
					
					If (!lEEC .Or. Empty(cExpInd)) .And. Select("cAlisCdl") > 0
						//-- Complemento de Exportacao
						// Sem integra็ใo com EEC
                        // Doc + Serie + Cli/For + Loja 
						(cAlisCdl)->(DbGotop())
						If (cAlisCdl)->(!EOF()) .And. ((cAlisCdl)->(Alltrim(CDL_DOC) + Alltrim(CDL_SERIE) + Alltrim(CDL_CLIENT) + Alltrim(CDL_LOJA) ) == (Alltrim(aSaid[nX][1]) + Alltrim(aSaid[nX][2]) + Alltrim(aSaid[nX][24]) + Alltrim(aSaid[nX][4]) ) )						
							If (cAlisCdl)->CDL_NATEXP == "1"
								cDeclExp := "INDIRETA"
								cCodExp  := "0"
							Else
								cDeclExp := (cAlisCdl)->CDL_NUMDE //Numero da declaracao simplificada de exportacao
								cCodExp  := "1"
							Endif	

							//-- Registro 5335 - Fichas 6C (Exportacao Direta e Indireta) e 6D (ZFM)
							aAdd(aReg5335, {})
							nPos5335 := Len(aReg5335)
							aAdd(aReg5335[nPos5335], nPos5315)								//Posicao de relacionamento com o registro 5325
							aAdd(aReg5335[nPos5335], "5335")								// 01 - REG
							aAdd(aReg5335[nPos5335], cDeclExp)								// 02 - NUM_DECL_EXP
							aAdd(aReg5335[nPos5335], cCodExp)								// 03 - COMP_OPER - Comprovacao da Operacao = 0-Sim;1-Nao
							l5335 := .T.

							If cCodExp == "0" 			
								(cAlisCdl)->(DbGotop())
								While (cAlisCdl)->(!Eof()) .And. ((cAlisCdl)->(Alltrim(CDL_DOC) + Alltrim(CDL_SERIE) + Alltrim(CDL_CLIENT) + Alltrim(CDL_LOJA) ) == (Alltrim(aSaid[nX][1]) + Alltrim(aSaid[nX][2]) + Alltrim(aSaid[nX][24]) + Alltrim(aSaid[nX][4]) ) )						
									//-- Registro 5340 - DADOS DA EXPORTACAO INDIRETA COMPROVADA - FICHA 5H
									If aScan(aReg5340, {|x|	x[1] == nPos5315 .And.;
															x[3] == (cAlisCdl)->CDL_EMIEXP .And.;
															x[4] == (cAlisCdl)->CDL_NFEXP  .And.;
															x[5] == (cAlisCdl)->CDL_SEREXP .And.;
															x[6] == (cAlisCdl)->CDL_NUMDE}) == 0
										aAdd(aReg5340, {})
										nReg5340 := Len(aReg5340)
										aAdd(aReg5340[nReg5340], nPos5315) 	    			//Posicao de relacionamento com o registro 5325
										aAdd(aReg5340[nReg5340], "5340")			    	// 01 - REG
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_EMIEXP)	// 02 - DATA_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_NFEXP)		// 03 - NUM_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_SEREXP)	// 04 - SER_DOC_IND
										aAdd(aReg5340[nReg5340], (cAlisCdl)->CDL_NUMDE)   	// 05 - NUM_DECL_EXP_IND
									Endif	
									(cAlisCdl)->(DbSkip())
								Enddo
							EndIf
						Endif	
					Endif	
				EndIf
			Else

				Reg5350(@aReg5350, aSaid[nX], nPos5315, .T., aDevol[nZ])
			Endif
			GeraRel(aDevol[nZ,8]*nIdxDev,cAliasREL,aSaid[nX,16],aSaid[nX,22],aSaid[nX,17,1])//Acrescenta o valor no relat๓rio
		Next(nZ)
		nIdxDev := 1
	EndIf
Next(nX)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg5350   บAutor  ณFlavio Luiz Vicco   บ Data ณ  18/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRegistro 5350 - Ficha 6F                                    บฑฑ
ฑฑบ          ณOperacoes Nao Geradoras de Credito Acumulado ou que nao se  บฑฑ
ฑฑบ          ณenquadram nas hipoteses de geracao previstas no artigo 71   บฑฑ
ฑฑบ          ณdo RICMS/00                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ5 - varios por arquivo                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg5350(aReg5350, aSaid, nPos5315, lDev, aDevol)
Local nPos5350   := 0

DEFAULT lDev := .F.
DEFAULT aDevol := {}

lDev := Iif(lDev .And. Len(aDevol) < 10, .F., lDev)

If (nPos5350 := aScan(aReg5350, {|x| x[1] == nPos5315})) == 0
	aAdd(aReg5350, {})
	nPos5350 := Len(aReg5350)
	aAdd(aReg5350[nPos5350], nPos5315)			//Posicao de relacionamento com o registro 5315
	aAdd(aReg5350[nPos5350], "5350")								// 01 - REG
	aAdd(aReg5350[nPos5350], Iif(!lDev,aSaid[12],aDevol[09] * -1))	// 02 - VALOR_BC
	aAdd(aReg5350[nPos5350], Iif(!lDev,aSaid[13],aDevol[10] * -1))	// 03 - ICMS_DEB
	aAdd(aReg5350[nPos5350], "")									// 04 - NUM_DECL_EXP_IND
Else
	aReg5350[nPos5350, 3] += Iif(!lDev,aSaid[12],aDevol[09] * -1)
	aReg5350[nPos5350, 4] += Iif(!lDev,aSaid[13],aDevol[10] * -1)	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9900   บAutor  ณWilliam P. Alves    บ Data ณ  28/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao e gravacao do registro 9900                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ2 - varios por arquivo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9900 (cAlias, aReg9900)
Local lRet := .T.
GrCatTrb(cAlias,,aReg9900,)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReg9999   บAutor  ณWilliam P. Alves    บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEncerramneto do arquivo digital                             บฑฑ
ฑฑบ          ณGeracao e gravacao do registro                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบNivel Hierณ0 - um por arquivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg9999 (cAlias)
Local lRet := .T.
Local nPos := 0
Local aReg := {}

aAdd(aReg, {})
nPos := Len (aReg)
nTotLin := (cAlias)->(RecCount()) + 1
aAdd (aReg[nPos], "9999")					//01 - REG
aAdd (aReg[nPos], Alltrim(STR(nTotLin)))	//02 - QTD_LIN
GrCatTrb (cAlias,,aReg,)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontWiz   บAutor  ณWilliam P. Alves    บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Wizard da rotina.                                  บฑฑ
ฑฑบ          ณ Retorna .T. se finalizado com sucesso                      บฑฑ
ฑฑบ          ณ Retorna .F. se foi cancelado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontWiz(cNomWiz)
Local aTxtApre := {}
Local aPaineis := {}
Local aItens1  := {}
Local cTitObj1 := ""
Local cTitObj2 := ""
Local lRet     := .T.

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 0ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aTxtApre, "Parโmetros necessแrios.")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aTxtApre, "Informa็๕es necessแrias para a gera็ใo do meio-magn้tico CAT207.")
//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 1ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aPaineis, {})
nPos := Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aPaineis[nPos], "Parโmetros para Gera็ใo")
aAdd (aPaineis[nPos], {})
//
cTitObj1 := "Mes/Ano de referencia (MMAAAA)";					cTitObj2 := "Versao Leiaute"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
cTitObj1 := Replicate ("X", 6);									cTitObj2 := Replicate ("X", 2)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,6});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,2})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := "C๓digo da Finalidade do Arquivo";					cTitObj2 := "Livro"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aItens1 := {};													cTitObj2 := Replicate ("X", 1)
aAdd (aItens1, "01-Rem regular de arquivo")
aAdd (aItens1, "02-Rem requerido por intimacao especifica")
aAdd (aItens1, "03-Rem subst arq remetido anteriormente")
aAdd (aItens1, "04-Rem arq com inf compl. Siscomex / Suframa")
//
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,1})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := "Diret๓rio do Arquivo Destino";						cTitObj2 := "Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1 := Replicate ("X", 50);								cTitObj2 := Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := "IE Gerador Crd. Acum. por Intimacao Especifica"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := Replicate ("X", 12)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,12});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := "Filial de"; 										cTitObj2 := "Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1 := Replicate ("X", 10);								cTitObj2 := Replicate ("X", 10)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1 := "Seleciona Filial?";								cTitObj2 := "Aglutina CNPJ+IE?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aItens1 := {}
aAdd (aItens1, "1-Sim")
aAdd (aItens1, "2-Nใo")
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
//
aAdd (aPaineis[nPos][3], {1,"",,,,,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})
//
lRet := xMagWizard (aTxtApre, aPaineis, cNomWiz)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraTrb   บAutor  ณWilliam P. Alves    บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao da estrutura do TRB                                 บฑฑ
ฑฑบ          ณGeracao da estrutura do TRB utilizado em todo processamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet -> .T.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnTipo  -> 1=Gerar o TRB, 2=Fechar o TRB                     บฑฑ
ฑฑบ          ณcArq   -> Nome fisico do TRB criado                         บฑฑ
ฑฑบ          ณcAlias -> Alias do TRB criado                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraTrb (nTipo, aArq, cAlias)
Local lRet := .T.
Local aCmp := {}
Local cArq := ""
Local nI   := 0

If (nTipo==1)
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณTRB Geralณ
	//ภฤฤฤฤฤฤฤฤฤู
	cAlias := "TRB"
	aAdd (aCmp, {"TRB_TPREG",	"C",	004,			0})
	aAdd (aCmp, {"TRB_RELAC",	"C",	nTamTRBIt*2,	0})
	aAdd (aCmp, {"TRB_FLAG",	"C",	001,			0})
	aAdd (aCmp, {"TRB_CONT",	"C",	999,			0})
	aAdd (aCmp, {"TRB_ITEM",	"N",	007,			0})
	cArq := CriaTrab (aCmp)
	DbUseArea (.T., __LocalDriver, cArq, cAlias)
	IndRegua (cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero(TRB_ITEM, 7, 0)")
	aAdd (aArq, {cAlias, cArq})
Else
	For nI := 1 To Len (aArq)
		DbSelectArea (aArq[nI][1])
		(aArq[nI][1])->(DbCloseArea ())
		Ferase (aArq[nI][2]+GetDBExtension ())
		Ferase (aArq[nI][2]+OrdBagExt ())
	Next nI
EndIf
cAlias := "TRB"	//Devo sempre retornar para os casos que nao tiverem TRB proprio.
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrCatTrb  บAutor  ณWilliam P. Alves    บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao do registro no TRB                                 บฑฑ
ฑฑบ          ณGravacao do registro passado como parametro (aReg) no TRB   บฑฑ
ฑฑบ          ณque sera posteiormente lido e gerado o TXT.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet -> .T.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcAlias -> Alias do TRB gerado na funcao principal           บฑฑ
ฑฑบ          ณnRelac -> Codigo de indicacao de relacionamento com outros  บฑฑ
ฑฑบ          ณ registros.                                                 บฑฑ
ฑฑบ          ณaReg -> Registro a ser gravado no TRB.                      บฑฑ
ฑฑบ          ณnItem -> Identificador de itens para um mesmo relacionamentoบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GrCatTrb (cAlias, nRelac, aReg, nItem, nFlag)
Local lRet     := .T.
Local cDelimit := "|"
Local cLinha   := ""
Local cReg     := ""
Local nX       := 0
Local nZ       := 0
Local nLenReg  := 0
Local cRegSer  := "5315|5320|5340"
Local nPosSer  := 0

Default nRelac := 0
Default nFlag  := 0

If nFlag == 0
	cFlag := Iif(Valtype(nRelac)=="N",StrZero(nRelac, nTamTRBIt, 0),nRelac)
Else
	cFlag := StrZero(nFlag, nTamTRBIt, 0)
EndIf

For nZ := 1 To Len (aReg)
	cLinha := ""
	
	// A ultima posicao do registro 5315 eh utilizada apenas como flag.
	// Nao deverแ ser impressa no arquivo.
	If aReg[nZ][1] $ "5315"
		nLenReg := Len(aReg[nZ]) - 1
	Else
		nLenReg := Len(aReg[nZ])
	EndIf
	
	//-- Montagem cLinha para gravar no TRB
	For nX := 1 To nLenReg
		
		/* 
			Tratamento p/ impressao do campo SERIE dos documentos.
			Quando se tratar destes campos (definidos na funcao RegPosSer) 
			devo imprimir apenas as 3 primeiras posicoes.
		*/
		
		If nX == 1 .And. aReg[nZ][nX] $ cRegSer
			nPosSer := RegPosSer(aReg[nZ][nX]) 
		EndIf
	
		If (ValType (aReg[nZ][nX])="A")
			If nX == nPosSer
				cLinha += RetStr (SubStr(aReg[nZ][nX][1],1,3), aReg[nZ][nX][2])+cDelimit
			Else
				cLinha += RetStr (aReg[nZ][nX][1], aReg[nZ][nX][2])+cDelimit
			EndIf
		Else
			If nX == nPosSer
				cLinha += RetStr (SubStr(aReg[nZ][nX],1,3))+cDelimit
			Else
				cLinha += RetStr (aReg[nZ][nX])+cDelimit
			EndIf
		EndIf
		
	Next (nX)
	
	cLinha := AllTrim(Left(cLinha,Len(cLinha)-1))
	cReg   := SubStr(cLinha, 1, 4)
	
	//-- Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT.
	If Len(cLinha) > Len((cAlias)->TRB_CONT)
		cLinha := AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))
	EndIf
	
	//-- Gravacao TRB
	RecLock (cAlias, .T.)
	(cAlias)->TRB_TPREG := cReg
	(cAlias)->TRB_RELAC := Alltrim(cFilAnt)+cFlag+Iif(Valtype(nRelac)=="N",StrZero(nRelac, nTamTRBIt, 0),nRelac)
	(cAlias)->TRB_CONT  := cLinha
	(cAlias)->TRB_ITEM  := nItem
	MsUnLock ()
Next (nZ)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvIndMov บAutor  ณWilliam P. Alves    บ Data ณ  13/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava indicador de movimento dos registros de abertura e    บฑฑ
ฑฑบ          ณencerramento do arquivo                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvIndMov (cAlias)
Local lRet     := .T.
Local nQtd0990 := 0
Local nQtd5990 := 0
Local nQtd9990 := 0
Local aReg9900 := {}
//
DbSelectArea (cAlias)
(cAlias)->(DbSetOrder(1))
(cAlias)->(DbGoTop())
//
Do While !(cAlias)->(Eof())
	If (nPos := aScan (aReg9900, {|aX| aX[2]==(cAlias)->TRB_TPREG}))==0
		aAdd (aReg9900, {"9900",(cAlias)->TRB_TPREG,"1"})
	Else
		aReg9900[nPos][3] := Alltrim(STR( Val( aReg9900[nPos][3] )+1))
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณREGISTROS - 0ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (Left ((cAlias)->TRB_TPREG, 1)$"0")
		nQtd0990++
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณREGISTROS - 5ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"5")
		nQtd5990++
	EndIf
	(cAlias)->(DbSkip ())
EndDo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do indicador de movimento do bloco 0.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BlAbEnc ("A", cAlias, "0001", Iif (nQtd0990>0, "0", "1"),)
BlAbEnc ("E", cAlias, "0990",, nQtd0990)
aAdd (aReg9900, {"9900","0001","1"})
aAdd (aReg9900, {"9900","0990","1"})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do indicador de movimento do bloco 5.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BlAbEnc ("A", cAlias, "5001", Iif (nQtd5990>0, "0", "1"),)
BlAbEnc ("E", cAlias, "5990",, nQtd5990)
aAdd (aReg9900, {"9900","5001","1"})
aAdd (aReg9900, {"9900","5990","1"})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOutros registros que devem ser totalizados       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd (aReg9900, {"9900","9001","1"})
aAdd (aReg9900, {"9900","9990","1"})
aAdd (aReg9900, {"9900","9999","1"})
aAdd (aReg9900, {"9900","9900",STR(len(aReg9900)+1)})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do bloco 9 (Totalizacao dos registros)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Reg9900 (cAlias, aReg9900)
nQtd9990 := len(aReg9900) + 1
BlAbEnc ("A", cAlias, "9001", Iif (nQtd9990>0, "0", "1"),)
BlAbEnc ("E", cAlias, "9990",, nQtd9990)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do registro 9999 (Encerramento do arquivo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Reg9999 (cAlias)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBlAbEnc   บAutor  ณWilliam P. Alves    บ Data ณ  13/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de gravacao do bloco de indicador de movimentos      บฑฑ
ฑฑบ          ณconforme passagem de parametro                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcAbEnt -> Indicador do bloco: (A)Abertura ou (E)Encerramentoบฑฑ
ฑฑบ          ณcAlias -> Alias do TRB onde sera gravada as informacoes     บฑฑ
ฑฑบ          ณcReg   -> Codigo do registro                                บฑฑ
ฑฑบ          ณcIndMov-> Indicador de movimento: (0)Sim ou (1)Nao          บฑฑ
ฑฑบ          ณnQtdLin-> Quantidade de linha do registro                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BlAbEnc (cAbEnc, cAlias, cReg, cIndMov, nQtdLin)
Local lRet     := .T.
Local aBlAbEnc := {}

aAdd(aBlAbEnc, {})
nPos := Len (aBlAbEnc)

If ("A"$cAbEnc)
	aAdd (aBlAbEnc[nPos], cReg)
	aAdd (aBlAbEnc[nPos], cIndMov)
Else
	aAdd (aBlAbEnc[nPos], cReg)
	// O + 2 para somar o registro de abertura mais o registro de encerramento
	aAdd (aBlAbEnc[nPos], Alltrim(STR(nQtdLin+2)))
EndIf

GrCatTrb (cAlias,,aBlAbEnc,)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInfPart   บAutor  ณWilliam P. Alves    บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as informacoes do participante do documento fiscal    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcAlsSA -> Alias da tabela SA1, SA2 ou SA4.                  บฑฑ
ฑฑบ          ณaReg0150 -> Array para geracao do registro 0150. Quando     บฑฑ
ฑฑบ          ณeste nao for passado, significa que nao deve ser gerado     บฑฑ
ฑฑบ          ณo registro 0150 para este participante                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InfPart(aReg0150, cAlias)

Local aDadosReg := {}
Local aEnd      := {}
Local nPos0150  := 0
Local cCodPais  := ""
Local cCGCPart  := ""
Local cCodPart  := ""
Local lExte     := .F.

Default cAlias := "SFT"
If !(cAlias)->FT_TIPO $ 'D|B'
	If SA1->(MsSeek(xFilial("SA1")+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA))
		cCodPais := IIF(Empty(SA1->A1_CODPAIS),"01058",SA1->A1_CODPAIS)
		//-- codigo participante com prefixo "1" usado para clientes
		cCodPart := "1"+StrZero(SA1->(RecNo()), 9)
		cCGCPart := Iif("01058" $ cCodPais, StrZero(Val(SA1->A1_CGC), 14), "")
		If (nPos0150 := aScan(aReg0150,	{|aX| AllTrim(aX[2]) == AllTrim(cCodPart) .Or. ;
											( AllTrim(aX[5]) == AllTrim(cCGCPart) .And. !Empty(aX[5]))})) == 0
			aEnd := MyGetEnd(SA1->A1_END, "SA1")
			lExte:= SA1->A1_EST == "EX"
			aAdd(aDadosReg, "0150")
			aAdd(aDadosReg, cCodPart)
			aAdd(aDadosReg, SA1->A1_NOME)
			aAdd(aDadosReg, cCodPais)
			aAdd(aDadosReg, cCGCPart)
			aAdd(aDadosReg, ConvType(VldIE(SA1->A1_INSCR)))
			aAdd(aDadosReg, IIf(lExte, " ", SA1->A1_EST))
			aAdd(aDadosReg, IIf(lExte, " ", Alltrim(SA1->A1_CEP)))
			aAdd(aDadosReg, IIf(lExte, " ", ConvType(aEnd[1])))
			aAdd(aDadosReg, IIf(lExte, " ", Iif(!Empty(aEnd[2]), aEnd[3], "SN")))
			aAdd(aDadosReg, IIf(lExte, " ", aEnd[4]))
			aAdd(aDadosReg, IIf(lExte, " ", ConvType(SA1->A1_BAIRRO)))
			//-- Tratamento p/ municipio. Se nao for Brasil, apresentar 9999999
			If !("01058" $ cCodPais) .And. SA1->A1_EST <> "EX"
				aAdd(aDadosReg, "9999999")
			ElseIf !("01058" $ cCodPais) .And. SA1->A1_EST == "EX"
				aAdd(aDadosReg, " ")
			Else
				aAdd(aDadosReg, UfCodIBGE(SA1->A1_EST) + Alltrim(SA1->A1_COD_MUN))
			EndIf
			aAdd(aDadosReg, IIf("01058" $ cCodPais, ConvType(SA1->A1_TEL), ""))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณREGISTRO 0150 - REGISTRO DE CADASTRO DE PARTICIPANTESณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nPos0150 := Reg0150(@aReg0150, aDadosReg)
		EndIf
	EndIf
Else
	If SA2->(MsSeek(xFilial("SA2")+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA))
		cCodPais := IIF(Empty(SA2->A2_CODPAIS),"01058",SA2->A2_CODPAIS)
		//-- codigo participante com prefixo "2" usado para fornecedores
		cCodPart := "2"+StrZero(SA2->(RecNo()), 9)
		cCGCPart := Iif("01058" $ cCodPais, StrZero(Val(SA2->A2_CGC), 14), "")
		If (nPos0150 := aScan(aReg0150,	{|aX| AllTrim(aX[2]) == AllTrim(cCodPart) .Or. ;
											( AllTrim(aX[5]) == AllTrim(cCGCPart) .And. !Empty(aX[5]))})) == 0
			aEnd := MyGetEnd(SA2->A2_END, "SA2")
			lExte:= SA2->A2_EST == "EX"
			aAdd(aDadosReg, "0150")
			aAdd(aDadosReg, cCodPart)
			aAdd(aDadosReg, SA2->A2_NOME)
			aAdd(aDadosReg, cCodPais)
			aAdd(aDadosReg, cCGCPart)
			aAdd(aDadosReg, ConvType(VldIE(SA2->A2_INSCR)))
			aAdd(aDadosReg, IIf(lExte, " ", SA2->A2_EST))
			aAdd(aDadosReg, IIf(lExte, " ", Alltrim(SA2->A2_CEP)))
			aAdd(aDadosReg, IIf(lExte, " ", ConvType(aEnd[1])))
			aAdd(aDadosReg, IIf(lExte, " ", Iif(!Empty(aEnd[2]), aEnd[3], "SN")))
			aAdd(aDadosReg, IIf(lExte, " ", aEnd[4]))
			aAdd(aDadosReg, IIf(lExte, " ", ConvType(SA2->A2_BAIRRO)))
			//-- Tratamento p/ municipio. Se nao for Brasil, apresentar 9999999
			If !("01058" $ cCodPais) .And. SA2->A2_EST <> "EX"
				aAdd(aDadosReg, "9999999")
			ElseIf !("01058" $ cCodPais) .And. SA2->A2_EST == "EX"
				aAdd(aDadosReg, " ")
			Else
				aAdd(aDadosReg, UfCodIBGE(SA2->A2_EST) + Alltrim(SA2->A2_COD_MUN))
			EndIf
			aAdd(aDadosReg, IIf("01058" $ cCodPais, ConvType(SA2->A2_TEL), ""))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณREGISTRO 0150 - REGISTRO DE CADASTRO DE PARTICIPANTESณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nPos0150 := Reg0150(@aReg0150, aDadosReg)
		EndIf
	EndIf
EndIf

Return (nPos0150)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSM00150   บAutor  ณNatalia Antonucci   บ Data ณ  27/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as informac๕es do Cadastro do Pr๓prio                 บฑฑ
ฑฑฬ          ณestabelecimento do contribuinte.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaReg0150 - Array para geracao do registro 0150.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SM00150(aReg0150)
Local aDadosReg := {}
Local nPos0150  := 0

aAdd (aDadosReg, "0150")																				//01 - REG
//-- codigo participante sem prefixo "0" usado para filiais
aAdd (aDadosReg, StrZero(SM0->(RecNo()), 10))															//02 - COD_PART
aAdd (aDadosReg, SM0->M0_NOMECOM)																		//03 - NOME		//06 - NOME
aAdd (aDadosReg, "01058")																				//04 - COD_PAIS
aAdd (aDadosReg, ConvType(VldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, ""))))				//05 - CNPJ
aAdd (aDadosReg, ConvType(VldIE(SM0->M0_INSC,.F.,.F.)))												//06 - IE
aAdd (aDadosReg, SM0->M0_ESTENT)																		//07 - UF
aAdd (aDadosReg, SM0->M0_CEPENT)																		//08 - CEP
aAdd (aDadosReg, Substr (SM0->M0_ENDENT, 1, At(",", SM0->M0_ENDENT)-1))								//09 - END
aAdd (aDadosReg, Substr (SM0->M0_ENDENT, At(",", SM0->M0_ENDENT)+1, Len (AllTrim (SM0->M0_ENDENT))))	//10 - NUM
aAdd (aDadosReg, SM0->M0_COMPENT)																		//11 - COMPL
aAdd (aDadosReg, SM0->M0_BAIRENT)																		//12 - BAIRRO
aAdd (aDadosReg, SM0->M0_CODMUN)																		//13 - COD_MUN
aAdd (aDadosReg, SM0->M0_TEL)																			//14 - FONE

nPos0150 := Reg0150(@aReg0150, aDadosReg)

Return (nPos0150)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณMyGetEnd  ณ Autor ณ William P. Alves             ณ Data ณ 16/04/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica se o participante e do DF, ou se tem um tipo de endereco ณฑฑ
ฑฑณ          ณ que nao se enquadra na regra padrao de preenchimento de endereco  ณฑฑ
ฑฑณ          ณ por exemplo: Enderecos de Area Rural (essa verific็ใo e feita     ณฑฑ
ฑฑณ          ณ atraves do campo ENDNOT).                                         ณฑฑ
ฑฑณ          ณ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ณฑฑ
ฑฑณ          ณ Endereco (sem numero ou complemento). Caso contrario ira retornar ณฑฑ
ฑฑณ          ณ o padrao do FisGetEnd                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Obs.     ณ Esta funcao so pode ser usada quando ha um posicionamento de      ณฑฑ
ฑฑณ          ณ registro, pois serแ verificado o ENDNOT do registro corrente      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAFIS                                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MyGetEnd(cEndereco,cAlias)

Local aRet := {"",0,"",""}

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)

If SA1->A1_EST == "DF" .Or. SA1->A1_ENDNOT == "1"
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco)
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrRegDep  บAutor  ณWilliam P. Alves    บ Data ณ  22/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravo registros dependentes                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObservacaoณTratamento para cabecalho/itens, onde posso ter varios itensบฑฑ
ฑฑบ          ณpor cabe็alho, neste caso a primeira posicao do registro    บฑฑ
ฑฑบ          ณfilho indica a posicao do registro pai. Procuro por filhos  บฑฑ
ฑฑบ          ณque tenham na primeira posicao a posicao lida do pai.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrRegDep (cAlias, aRegPai, aRegFilho, lRegPaiDup, nRegEcf, lCtdtem, nFlag)
Local lRet  := .T.
Local aReg  := {}
Local nCtd  := 1
Local nZ    := 0
Local nX    := 0
Local nCont := 1

DEFAULT lRegPaiDup := .F.
DEFAULT nRegEcf    := 0
DEFAULT lCtdtem    := .T.
DEFAULT nFlag      := 0

For nZ := 1 To Len (aRegPai)
	If !lRegPaiDup
		GrCatTrb (cAlias, nZ, {aRegPai[nZ]},,nFlag)
	Endif
	If Len(aRegFilho) >= 1 .And. aScan(aRegFilho, {|x| x[1] == nZ}) > 0
		nCont := Len(aRegFilho)
		nCtd  := 1
	    //Bloco abaixo varre todo Array aRegFilho para localizar o registro filho correspondente do registro pai, foi nescessแrio ser montado desta maneira pois pode ocorrer situa็๕es onde
		//o aRegFilho foi gerado desordenamente, (registro 02 na posi็ใo 1, etc.) 
		While nCont >= nCtd
			If aRegFilho[nCtd,1] == nZ 
				aReg := {}
				For nX := 2 To Len(aRegFilho[nCtd])
					aAdd (aReg, aRegFilho[nCtd][nX])
				Next (nX)	
				GrCatTrb (cAlias, nZ, {aReg}, Iif(lCtdtem,nCtd,aRegFilho[nCtd][1]), nFlag)
			Endif
			nCtd++
		EndDo
	EndIf
Next (nZ)
Return (lRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuncoes de tratamento de caracteres especiais copiadas do NFESEFAZ  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function ConvType(xValor,nTam)
Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf

Default nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
Return(cNovo)

Static Function VldIE(cInsc,lContr,lIsent)
Local cRet := ""
Local nI   := 1

Default lContr := .T.
Default lIsent := .T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoAcento  บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Remove acentos e caracteres especiais que implicam em      บฑฑ
ฑฑบ          ณ problemas na geracao de arquivos.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcString -> String que deve ser tratada                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcString -> String sem os caracteres especiais               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
Local cCrase := "เ่์๒๙"+"ภศฬาู"
Local cTio   := "ใ๕"
Local cCecid := "็ว"

For nX:= 1 To Len(cString)
	cChar := SubStr(cString, nX, 1)
	If cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY := At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY := At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY := At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY := At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY := At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY := At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	EndIf
Next
For nX := 1 To Len(cString)
	cChar := SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString := StrTran(cString,cChar,".")
	EndIf
Next nX
cString := _NoTags(cString)
Return cString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOrgTxt    บAutor  ณWilliam P. Alves    บ Data ณ  23/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao do TRB em meio magnetico                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcAlias -> Alias do TRB gerado na funcao principal           บฑฑ
ฑฑบ          ณcFile  -> Nome do arquivo magnetico a ser gerado            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OrgTxt (cAlias, cFile)
Local lRet       := .T.
Local nHandle    := -1
Local cRelac     := ""
Local cChave     := ""
Local aAreaLoc   := {}
Local aArea2     := {}

If	File (cFile)
	FErase (cFile)
EndIf
nHandle := MsFCreate (cFile)

DbSelectArea (cAlias)
(cAlias)->(DbSetOrder (1)) //TRB_TPREG+TRB_RELAC+StrZero(TRB_ITEM, 7, 0)
ProcRegua ((cAlias)->(RecCount ()))
(cAlias)->(DbGoTop ())

Do While !(cAlias)->(Eof())
	IncProc(STR0004) //"Gerando arquivo texto"
	If Empty((cAlias)->TRB_FLAG)
		cRelac   := (cAlias)->TRB_RELAC
		aAreaLoc := (cAlias)->(GetArea ())
		If ("5315"$(cAlias)->TRB_TPREG)
			aArea2  := (cAlias)->(GetArea ())
			GravaLinha (nHandle, cAlias)
			RegPorNf (nHandle, cAlias, "5320", (cAlias)->TRB_RELAC)
			cChave := "5325"+cRelac
			If (cAlias)->(msSeek (cChave)) .And. Empty((cAlias)->TRB_FLAG)
				Do While !(cAlias)->(Eof()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
					GravaLinha (nHandle, cAlias)
					RegPorNf (nHandle, cAlias, "5330", (cAlias)->TRB_RELAC)
					RegPorNf (nHandle, cAlias, "5335", (cAlias)->TRB_RELAC)
					RegPorNf (nHandle, cAlias, "5340", (cAlias)->TRB_RELAC)
					(cAlias)->(DbSkip ())
				EndDo
			EndIf
			RestArea (aArea2)
			RegPorNf (nHandle, cAlias, "5350", (cAlias)->TRB_RELAC)
		ElseIf !(cAlias)->TRB_TPREG$"5320/5325/5335/5340/5350"
			GravaLinha (nHandle, cAlias)
		EndIf
		RestArea (aAreaLoc)
	EndIf
	(cAlias)->(DbSkip ())
EndDo

If (nHandle>=0)
	FClose (nHandle)
Endif
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  |GravaLinhaณ Autor ณWilliam P. Alves       ณ Data ณ16.04.2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ                                                            ณฑฑ
ฑฑณ          ณ      GRAVACAO DE UM REGISTRO E MARCA COMO GRAVADO          ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservacaoณGravo o registro posicionado do TRB e marco ele como ja gra-ณฑฑ
ฑฑณ          ณ vado evitanto duplicidade.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณNivel HierณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณlRet -> .T.                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros|nHandle -> Handle do arquivo txt aberto.                    ณฑฑ
ฑฑณ          |cAlias -> Alias do TRB criado atraves da funcao principal.  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GravaLinha (nHandle, cAlias)
Local cConteudo := AllTrim ((cAlias)->TRB_CONT)+Chr (13)+Chr (10)

FWrite (nHandle, cConteudo, Len (cConteudo))
RecLock (cAlias, .F.)
(cAlias)->TRB_FLAG := "*"
MsUnLock ()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  |RegPorNf  ณ Autor ณWilliam P. Alves       ณ Data ณ16.04.2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ                                                            ณฑฑ
ฑฑณ          ณ   GRAVACAO DE UM REGISTRO RELACIONADO COM SEU SUPERIOR     ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservacaoณPosiciono no registro com a chave passada como parametro e  ณฑฑ
ฑฑณ          ณ gero o TXT na funcao Gravalinha                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณNivel HierณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณlRet -> .T.                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros|nHandle -> Handle do arquivo txt aberto.                    ณฑฑ
ฑฑณ          |cAlias -> Alias do TRB criado atraves da funcao principal.  ณฑฑ
ฑฑณ          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ณฑฑ
ฑฑณ          |cRelac -> Relacionamento do registro que compoe a chave de  ณฑฑ
ฑฑณ          | pesquisa                                                   ณฑฑ
ฑฑณ          |nItem -> Item por relacionamento.                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RegPorNf (nHandle, cAlias, cTpReg, cRelac, nItem)
Local lRet     := .T.
Local cChave   := cTpReg+cRelac
Local aAreaLoc := (cAlias)->(GetArea ())

If (nItem<>Nil .And. nItem>0)
	cChave += StrZero(nItem, 7, 0)
EndIf

If (cAlias)->(msSeek (cChave))
	Do While !(cAlias)->(Eof()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif (nItem<>Nil .And. nItem>0, StrZero((cAlias)->TRB_ITEM, 7, 0),"")
		If Empty((cAlias)->TRB_FLAG)
			GravaLinha (nHandle, cAlias)
		EndIf
		(cAlias)->(DbSkip ())
	EndDo
EndIf

RestArea (aAreaLoc)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetStr    บAutor  ณWilliam P. Alves    บ Data ณ  23/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecebe, transforma e retorna a string no formato exigido    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณxValor -> Conteudo a ser padronizado                        บฑฑ
ฑฑบ          ณnDec   -> Quantidade de decimais para valores numericos     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณxRet -> A string ou valor no padrao do layout               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetStr (xValor, nDec)
Local xRet

Default nDec := 2

If (ValType (xValor)=="N")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTodas as variaveis numericas que nao tiverem definicao de casas decimais     |
	//ณserao convertidas para apresentarem 2 decimais (Default)                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	xRet := AllTrim (StrTran (Str (xValor,,nDec), ".", ","))
ElseIf (ValType (xValor)=="C")
	xRet := AllTrim (xValor)
ElseIf (ValType (xValor)=="D")
	xRet := StrZero(Day (xValor), 2)+StrZero(Month (xValor), 2)+StrZero(Year (xValor), 4)
Else
	xRet := ""
EndIf
Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTipoNot   บAutor  ณWilliam P. Alves    บ Data ณ  29/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o codigo do tipo de documento fiscal de acordo com  บฑฑ
ฑฑบ          ณa tabela 4.2 do manual da CAT207/09                         บฑฑ
ฑฑบ          ณa tabela 4.2 do manual da CAT207/09                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณcEspecie - Especie do documento fiscal                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TipoNot(cEspecie)
Local cCodigo:="01" // 01- Default Nota Fiscal ou Nota Fiscal Fatura

Do Case
	Case Alltrim(cEspecie)=="CA"
		cCodigo := "12" // 10- Conh.Aereo
	Case Alltrim(cEspecie)=="CTA"
		cCodigo := "11" // 9- Conh.Transp.Aquaviario
	Case Alltrim(cEspecie)=="CTF"
		cCodigo := "13" // 11- Conh.Transp.Ferroviario
	Case Alltrim(cEspecie)=="CTR"
		cCodigo := "09" // 08- Conh.Transp.Rodoviario
	Case Alltrim(cEspecie)=="NFCEE"
		cCodigo := "07" // 06- Conta de Energia Eletrica
	Case Alltrim(cEspecie)=="NFE"
		cCodigo := "01" // 01- NF Entrada
	Case Alltrim(cEspecie)=="NFPS"
		cCodigo := "   " // "  "- NF Prestacao de Servico
	Case Alltrim(cEspecie)=="NFS"
		cCodigo := "   " // "  "- NF Servico
	Case Alltrim(cEspecie)=="NFST"
		cCodigo := "08" // 07- NF Servico de Transporte
	Case Alltrim(cEspecie)=="NFSC"
		cCodigo := "21" // 021- NF Servico de Comunicacao
	Case Alltrim(cEspecie)=="NTSC"
		cCodigo := "21" // 021- NF Servico de Comunicacao
	Case Alltrim(cEspecie)=="NTST"
		cCodigo := "22" // 022- NF Servico de Telecomunicacoes
	Case Alltrim(cEspecie)=="NFCF"
		cCodigo := "03" // 02- NF de venda a Consumidor Final
	Case Alltrim(cEspecie)=="NFP"
		cCodigo := "06" // 04- NF de Produtor
	Case Alltrim(cEspecie)=="RMD"
		cCodigo := "19" // 018- Resumo Movimento Diario
	Case Alltrim(cEspecie)=="CTM"
		cCodigo := "26" // 026- Conh.Transp.Multimodal
	Case Alltrim(cEspecie)=="CF" .OR. Alltrim(cEspecie)=="ECF"
		cCodigo := "04" // 2D- Cupon Fiscal gerado pelo SIGALOJA
	Case Alltrim(cEspecie)=="RPS"
		cCodigo := "   " // "  "- Recibo Provisorio de Servicos - Nota Fiscal Eletronica de Sao Paulo
	Case Alltrim(cEspecie)=="SPED"
		cCodigo := "31" // 55- Nota fiscal eletronica do SEFAZ.
	Case Alltrim(cEspecie)=="NFFA"
		cCodigo := "27" // 27- Nota fiscal de fornecimento de agua
	Case Alltrim(cEspecie)=="NFCFG"
		cCodigo := "28" // 028- Nota fiscal/conta de fornecimento de gas
	Case Alltrim(cEspecie)=="CTE"
		cCodigo := "32" // 057- Conhecimento de Transporte Eletronico
EndCase
Return (cCodigo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscEntr  บAutor  ณWilliam P. Alves    บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca notas fiscais de devolucao de venda                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscEntr(dDataDe, dDataAte, cNFiscal, cSerie, cCliente, cLoja)
Local aDados   := {}
Local cAlias   := "SD1"
Local cIndex   := ""
Local cEspecie := ""
Local nIndex   := 0
Local nPos     := 0
Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrder   := ""

#IFDEF TOP

	cSelect += "SFT.FT_FILIAL,  SFT.FT_NFISCAL, SFT.FT_SERIE,   SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_TIPO, SA1.A1_TIPO,  "
	cSelect += "SFT.FT_ESPECIE, SFT.FT_NFORI,   SFT.FT_SERORI,  SFT.FT_ITEMORI, SFT.FT_EMISSAO, SFT.FT_ESTADO, "
	cSelect += "SFT.FT_TES, SFT.FT_ITEM, SFT.FT_VALIPI,  SFT.FT_VALCONT, SFT.FT_BASEICM, SFT.FT_VALICM, SF4.F4_CRDACUM, "
	cSelect += "SFT.FT_CFOP "

	cFrom := RetSqlName("SFT") + " SFT "

	cFrom += "JOIN " + RetSqlName("SF4") + " SF4 ON "
	cFrom += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
	cFrom += "SFT.FT_TES = SF4.F4_CODIGO AND "
	cFrom += "SF4.D_E_L_E_T_ = ' ' "

	cFrom += "JOIN " + RetSqlName("SA1") + " SA1 ON "
	cFrom += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cFrom += "SA1.A1_COD = SFT.FT_CLIEFOR AND "
	cFrom += "SA1.A1_LOJA = SFT.FT_LOJA AND "
	cFrom += "SA1.D_E_L_E_T_ = ' ' "

	cWhere := "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
	cWhere += "SFT.FT_TIPOMOV = 'E' AND "
	cWhere += "SFT.FT_EMISSAO >= '" + dToS(dDataDe) + "' AND "
	cWhere += "SFT.FT_EMISSAO <= '" + dToS(dDataAte) + "' AND "
	cWhere += "SFT.FT_CLIEFOR = '" + cCliente + "' AND "
	cWhere += "SFT.FT_LOJA = '" + cLoja + "' AND "
	cWhere += "SFT.FT_NFORI = '" + cNfiscal + "' AND "
	cWhere += "SFT.FT_SERORI = '" + cSerie + "' AND "
	cWhere += "SFT.FT_TIPO = 'D' AND "
	cWhere += "SFT.FT_DTCANC = ' ' AND "
	cWhere += "SFT.D_E_L_E_T_ = ' ' "

	cOrder := "ORDER BY SFT.FT_FILIAL, SFT.FT_NFORI, SFT.FT_SERORI, SF4.F4_CRDACUM " //Ordenado desta maneira para que seja localiza็๕ primeiro os registro com cr้dito aculado.

	//-- Ajustando variแveis para a execu็ใo do BeginSQL
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + cOrder + "%" 

	If TcSrvType()<>"AS/400"
		cAlias := GetNextAlias()

		BeginSql Alias cAlias
			COLUMN FT_EMISSAO AS DATE
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
		EndSql
	Else
#ENDIF
		Return(aDados)
		cIndex  := CriaTrab(NIL,.F.)
		cFiltro := "D1_FILIAL == '" + xFilial("SD1") + "' .AND. "
		cFiltro += "dtos(D1_DTDIGIT) >= '"+dtos(dDataDe)+"' .AND. "
		cFiltro += "dtos(D1_DTDIGIT) <= '"+dtos(dDataAte)+"' .AND. "
		cFiltro += "D1_NFORI == '"+cNfiscal+"' .AND. "
		cFiltro += "D1_SERIORI == '"+cSerie+"' .AND. "
		cFiltro += "D1_TIPO == 'D' "
		IndRegua (cAlias, cIndex, (cAlias)->(IndexKey ()),, cFiltro)
		nIndex := RetIndex(cAlias)
#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
#ENDIF
		DbSelectArea (cAlias)
		DbSetOrder (nIndex)
#IFDEF TOP
	EndIf
#ENDIF

While !(cAlias)->(Eof())
	//-- Busca modelo da nota fiscal
	cEspecie := TipoNot((cAlias)->FT_ESPECIE)
	// Conforme layout, s๓ pode haver um registro de devolucao (5320) por nota.
	// Verificar, pois pode haver mais de uma dev. parcial da mesma NF e, neste caso, o layout nao permite a geracao do 5320 para todas as notas.
	//If (nPos := aScan(aDados, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim((cAlias)->FT_NFORI) + AllTrim((cAlias)->FT_SERORI)})) == 0	
		aAdd(aDados,{})
		nPos := Len(aDados)
		aAdd(aDados[nPos], AllTrim((cAlias)->FT_NFORI))		//01 - NF Original
		aAdd(aDados[nPos], AllTrim((cAlias)->FT_SERORI))		//02 - Serie NF Original
		aAdd(aDados[nPos], Alltrim((cAlias)->FT_NFISCAL))		//03 - NF - Devolucao
		aAdd(aDados[nPos], Alltrim((cAlias)->FT_SERIE))		//04 - Serie - Devolucao
		aAdd(aDados[nPos], (cAlias)->FT_EMISSAO)				//05 - Dt. Emissao - Devolucao
		aAdd(aDados[nPos], cEspecie)							//06 - Especie - Devolucao
		aAdd(aDados[nPos], (cAlias)->FT_VALIPI)					//07 - VL IPI
		aAdd(aDados[nPos], (cAlias)->FT_VALCONT)				//08 - VALOR CONTABIL
		aAdd(aDados[nPos], (cAlias)->FT_BASEICM)				//09 - BASE ICMS
		aAdd(aDados[nPos], (cAlias)->FT_VALICM)					//10 - VALOR ICMS
		aAdd(aDados[nPos], (cAlias)->FT_CLIEFOR)     			//11 - CLIENTE
		aAdd(aDados[nPos], (cAlias)->FT_LOJA)        			//12 - LOJA
		aAdd(aDados[nPos], (cAlias)->FT_ITEM)        			//13 - ITEM
		aAdd(aDados[nPos], (cAlias)->F4_CRDACUM)       			//14 - CาDIGO DE CUMULATIVIDADE
		aAdd(aDados[nPos], " "                 )                //15 - MARCADOR
		aAdd(aDados[nPos], (cAlias)->FT_ESTADO)       			//16 - UF DO CLIENTE DA NOTA DE DEVOLUวรO
		aAdd(aDados[nPos], (cAlias)->A1_TIPO)       			//17 - TIPO DO CLIENTE DA NOTA DE DEVOLUวรO
		aAdd(aDados[nPos], (cAlias)->FT_CFOP)       			//18 - CFOP
	//EndIf
	(cAlias)->(DbSkip())
EndDo

DbSelectArea(cAlias)
(cAlias)->(DbCloseArea())

Return(aDados)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscSaida บAutor  ณWilliam P. Alves    บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca notas fiscais de devolucao de Entrada                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscSaida(dDataDe, dDataAte, cNfiscal, cSerie, lCredImp, nPercMedio, cNrLivro, aCredAcum, cAliasREL)
Local aDados   := {}
Local cAlias   := "SD2"
Local cIndex   := ""
Local cEspecie := ""
Local cCodPro  := ""
Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrder   := ""
Local nIndex   := 0
Local nPos     := 0
Local nMedio   := 0
Local nPosPart := 0
Local nPosAcum := 0
Local nCredICM := 0
Local nValIva  := iIf( ValType(SuperGetMV("MV_IVAUTIL",,0)) == "N", SuperGetMV("MV_IVAUTIL",,0), 0)

Default lCredImp   := .F.
Default nPercMedio := 0
Default aCredAcum  := {}

#IFDEF TOP

	cSelect += "SFT.FT_FILIAL,  SFT.FT_EMISSAO, SFT.FT_NFISCAL, SFT.FT_SERIE,   SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_TIPO, "
	cSelect += "SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_NFORI,   SFT.FT_ITEMORI, SFT.FT_SERORI,  SFT.FT_PRODUTO, "
	cSelect += "SFT.FT_ESPECIE, SFT.FT_VALCONT, SFT.FT_VALIPI,  SFT.FT_ESTADO,  SF4.F4_PERCMED, SF4.F4_CRDACUM, SF4.F4_IVAUTIL, SF4.F4_LFICM, "
	cSelect += "SF4.F4_CROUTSP, SFT.FT_CFOP, SFT.FT_ITEM, SD2.D2_PREEMB, "
	
	// Campos tabela CFF
	cSelect += "CFF.CFF_ITEMNF, CFF.CFF_CODLEG, CFF.CFF_CODIGO, CFF.CFF_ANEXO, CFF.CFF_ART, CFF.CFF_INC, CFF.CFF_ALIN, CFF.CFF_PRG, "
	cSelect += "CFF.CFF_ITM, CFF.CFF_LTR, CFF.CFF_OBS "

	cFrom := RetSqlName("SFT") + " SFT "

	cFrom += "JOIN " + RetSqlName("SD2") + " SD2 ON "
	cFrom += "SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
	cFrom += "SD2.D2_DOC     = SFT.FT_NFISCAL  AND "
	cFrom += "SD2.D2_SERIE   = SFT.FT_SERIE AND "
	cFrom += "SD2.D2_CLIENTE = SFT.FT_CLIEFOR  AND "
	cFrom += "SD2.D2_LOJA    = SFT.FT_LOJA AND "
	cFrom += "SD2.D2_COD     = SFT.FT_PRODUTO AND "
	cFrom += "SD2.D2_ITEM    = SFT.FT_ITEM AND "
	cFrom += "SD2.D_E_L_E_T_ = ' ' "

	cFrom += "JOIN " + RetSqlName("SF4") + " SF4 ON "
	cFrom += "SF4.F4_FILIAL  = '" + xFilial("SF4") + "' AND "
	cFrom += "SF4.F4_CODIGO  = SD2.D2_TES AND "
	cFrom += "SF4.D_E_L_E_T_ = ' ' "
	
	cFrom += "LEFT JOIN " + RetSqlName("CFF") + " CFF ON "
	cFrom += "CFF.CFF_FILIAL = '" + xFilial("CFF") + "' AND "
	cFrom += "CFF.CFF_NUMDOC = SFT.FT_NFISCAL AND "
	cFrom += "CFF.CFF_SERIE  = SFT.FT_SERIE AND "
	cFrom += "CFF.CFF_ITEMNF = SFT.FT_ITEM AND "
	cFrom += "CFF.CFF_CLIFOR = SFT.FT_CLIEFOR AND "
	cFrom += "CFF.CFF_LOJA   = SFT.FT_LOJA AND "

	If lCmpCFF
		cFrom += "CFF.CFF_TIPO   = SD2.D2_TIPO AND "
		cFrom += "CFF.CFF_TPMOV  = SFT.FT_TIPOMOV AND "
	EndIf
	
	cFrom += "CFF.D_E_L_E_T_ = ' ' "

	cWhere += "SFT.FT_FILIAL   = '" + xFilial("SFT") + "' AND "
	cWhere += "SFT.FT_TIPOMOV  = 'S' AND "
	cWhere += "SFT.FT_EMISSAO >= '" + dToS(dDataDe) + "' AND "
	cWhere += "SFT.FT_EMISSAO <= '" + dToS(dDataAte) + "' AND "
	cWhere += "SFT.FT_NFISCAL  = '" + cNfiscal + "' AND "
	cWhere += "SFT.FT_SERIE = '" + cSerie + "' AND "
	cWhere += "SFT.FT_TIPO <> 'S' AND "

	If (!Empty(cNrLivro)) .AND. cNrLivro <> "*"
		cWhere += "SFT.FT_NRLIVRO = '" + cNrLivro + "' AND "
	EndIf

	cWhere += "SFT.D_E_L_E_T_ = ' ' "

	cOrder += "ORDER BY SFT.FT_FILIAL, SFT.FT_EMISSAO, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SF4.F4_CRDACUM " //Ordenado desta maneira para que seja localiza็๕ primeiro os registro com cr้dito aculado.

	//-- Ajustando variแveis para a execu็ใo do BeginSQL
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + cOrder + "%"

	If TcSrvType()<>"AS/400"
		cAlias := GetNextAlias()

		BeginSql Alias cAlias
			COLUMN FT_EMISSAO AS DATE
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
		EndSql
	Else
#ENDIF
		Return(aDados)
		dbSelectArea("SD2")
		cIndex  := CriaTrab(NIL,.F.)
		cFiltro := "D2_FILIAL == '" + xFilial("SD2") + "' .AND. "
		cFiltro += "dtos(D2_EMISSAO) >= '"+dtos(dDataDe)+"' .AND. "
		cFiltro += "dtos(D2_EMISSAO) <= '"+dtos(dDataAte)+"' .AND. "
		cFiltro += "D2_TIPO <> 'D' .AND. D2_TIPO <> 'B' .AND. D2_COD = ' "+cCodPro+ " '
		IndRegua (cAlias, cIndex, (cAlias)->(IndexKey ()),, cFiltro)
		nIndex := RetIndex(cAlias)
#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
#ENDIF
		DbSelectArea (cAlias)
		DbSetOrder (nIndex)
#IFDEF TOP
	EndIf
#ENDIF

While !(cAlias)->(Eof())

	//-- Geracao do registro 0150
	nPosPart := InfPart(@aReg0150, cAlias)
	
	//-- Modelo da nota fiscal
	cEspecie := TipoNot((cAlias)->FT_ESPECIE)
	
	//-- Percentual Medio
	If Empty((cAlias)->F4_PERCMED) .Or. (cAlias)->F4_PERCMED == 0
		nMedio := nPercMedio
	Else
		nMedio := (cAlias)->F4_PERCMED
	EndIf
	
	nValIva := Iif(nValIva > 0, nValIva, (cAlias)->F4_IVAUTIL)
	//-- Credito Estimado
	If AllTrim((cAlias)->F4_CRDACUM) == "1"
		nCredICM := (((cAlias)->FT_VALCONT / (1 + nValIva)) * (nMedio / 100))
	Else
		nCredICM := 0
	EndIf
						
	If (nPos := aScan(aDados, {|x|	AllTrim(x[1]) + AllTrim(x[2]) + x[3] + AllTrim(x[4]) + AllTrim(x[8]) + AllTrim(x[16]) == ;
									Alltrim((cAlias)->FT_NFISCAL) + Alltrim((cAlias)->FT_SERIE) + ;
									aReg0150[nPosPart][2] + Alltrim((cAlias)->FT_LOJA) + ;
									AllTrim((cAlias)->F4_CRDACUM) + AllTrim((cAlias)->CFF_CODIGO)})) == 0
		aAdd(aDados,{})
		nPos := Len(aDados)
		aAdd(aDados[nPos], Alltrim((cAlias)->FT_NFISCAL))		//01 - NUM NF
		aAdd(aDados[nPos], Alltrim((cAlias)->FT_SERIE))		    //02 - SERIE
		aAdd(aDados[nPos], aReg0150[nPosPart][2])				//03 - PARTICIPANTE
		aAdd(aDados[nPos], Alltrim((cAlias)->FT_LOJA))			//04 - LOJA
		aAdd(aDados[nPos], (cAlias)->FT_EMISSAO)				//05 - DT DIGITACAO
		aAdd(aDados[nPos], 1)									//06 - IND MOVIMENTO
		aAdd(aDados[nPos], cEspecie)							//07 - ESPECIE
		aAdd(aDados[nPos], (cAlias)->F4_CRDACUM)				//08 - CREDITO ACUMULADO
		aAdd(aDados[nPos], (cAlias)->F4_CROUTSP)				//09 - CREDITO OUTORGADO
		aAdd(aDados[nPos], (cAlias)->FT_VALIPI)					//10 - VL IPI
		aAdd(aDados[nPos], (cAlias)->FT_VALCONT)				//11 - VALOR CONTABIL
		aAdd(aDados[nPos], (cAlias)->FT_BASEICM)				//12 - BASE ICMS
		aAdd(aDados[nPos], (cAlias)->FT_VALICM)					//13 - VALOR ICMS
		aAdd(aDados[nPos], (cAlias)->CFF_ITEMNF)				//14 - ITEM DA NF
		aAdd(aDados[nPos], (cAlias)->CFF_CODLEG)				//15 - COD_LEGAL
		aAdd(aDados[nPos], (cAlias)->CFF_CODIGO)				//16 - DESC
		
		If AllTrim((cAlias)->F4_CRDACUM) == "1"
			
			aAdd(aDados[nPos], {nValIva, 4})                                    // 17 - IVA utilizado (Indice de Valor acrescido)
			aAdd(aDados[nPos], IIf((cAlias)->FT_TIPO=="I", {0,0}, {nMedio, 4})) // 18 - Perc.Medio de Cre. do Imp
			aAdd(aDados[nPos], nCredICM)								     	// 19 - Credito Estimado do Imposto
			aAdd(aDados[nPos], (cAlias)->FT_VALICM)						     	// 20 - ICMS
			aAdd(aDados[nPos], (cAlias)->FT_BASEICM)						    // 21 - Base ICMS
			aAdd(aDados[nPos], (cAlias)->FT_ALIQICM)					     	// 22 - ALIQUOTA ICMS	
			
		Else
		
			aAdd(aDados[nPos], {0,0})
			aAdd(aDados[nPos], {0,0})
			aAdd(aDados[nPos],     0)
			aAdd(aDados[nPos],     0)
			aAdd(aDados[nPos],     0)
			aAdd(aDados[nPos],     0)
			
		EndIf
		
		aAdd(aDados[nPos], (cAlias)->FT_ESTADO)					//23 - UF CLIENTE
		aAdd(aDados[nPos], (cAlias)->FT_CLIEFOR)				//24 - CLIENTE 
		aAdd(aDados[nPos], (cAlias)->FT_CFOP)					//25 - CFOP 
		aAdd(aDados[nPos], (cAlias)->D2_PREEMB)					//26 - D2_PREEMB - NUMERO DO VINCULO COM O MODULO EEC
		
	Else
	
		aDados[nPos, 10] += (cAlias)->FT_VALIPI
		aDados[nPos, 11] += (cAlias)->FT_VALCONT
		aDados[nPos, 12] += (cAlias)->FT_BASEICM
		aDados[nPos, 13] += (cAlias)->FT_VALICM
		
		If AllTrim((cAlias)->F4_CRDACUM) == "1"
					
			aDados[nPos, 19] += nCredICM
			aDados[nPos, 20] += (cAlias)->FT_VALICM
			aDados[nPos, 21] += (cAlias)->FT_BASEICM
			
		EndIf
	EndIf
	
	/*Atualiza Arquivo temporario do relatorio
	C๓digo Inciso artigo 71-RICMS/00:
	01-Inciso I - Op. Interest. alํq.7%
	02-Inciso I - Op. Interest. alํq.12%
	03-Inciso I - Op. Int. alํq 7%
	04-Inciso I - Op .Internas
	05-Inciso I - Outras
	06-Inciso II - Red. de Base
	07-Inciso III - Exporta็ใo
	08-Inciso III - Exporta็ใo Indireta
	09-Inciso III - ZF Manaus
	10-Inciso III - Diferimento
	11-Inciso III - Isen็ใo
	12-Inciso III - ST
	13-Inciso III - Outras
	*/
	If AllTrim((cAlias)->F4_CRDACUM) == "1"

		//Criar linha por filial para relatorio CAT207_DGCA
		If !(cAliasREL)->(MsSeek(cFilAnt+Alltrim((cAlias)->FT_CFOP)))
			RecLock (cAliasREL, .T.)
			(cAliasREL)->R_FILIAL	:= cFilAnt
			(cAliasREL)->R_CFOP		:= Alltrim((cAlias)->FT_CFOP)
		Else
			RecLock (cAliasREL, .F.)
		Endif
	
		
		Do Case
			Case (cAlias)->CFF_CODIGO $ '01' // 01-Inciso I - Op. Interest. alํq.7%
				(cAliasREL)->R_INTER7  += (cAlias)->FT_VALCONT
			Case (cAlias)->CFF_CODIGO $ '02' // 02-Inciso I - Op. Interest. alํq.12%
				(cAliasREL)->R_INTER12 += (cAlias)->FT_VALCONT
			Case (cAlias)->CFF_CODIGO $ '03' // 03-Inciso I - Op. Int. alํq 7%
				(cAliasREL)->R_INTERNA7 += (cAlias)->FT_VALCONT
			Case (cAlias)->CFF_CODIGO $ '06' // 06-Inciso II - Red. de Base
				If (cAlias)->FT_ALIQICM == 7		//Red. 7% P/4,1%
					(cAliasREL)->R_RED7	 += (cAlias)->FT_VALCONT
				Elseif (cAlias)->FT_ALIQICM == 12	//Red. 12% P/ 8,8%
					(cAliasREL)->R_RED12 += (cAlias)->FT_VALCONT
				Elseif (cAlias)->FT_ALIQICM == 18  //Red. 18% P/ 5,6%
					(cAliasREL)->R_RED18 += (cAlias)->FT_VALCONT
				Endif			
			Case (cAlias)->CFF_CODIGO $ '07|08' // 07-Inciso III - Exporta็ใo 	08-Inciso III - Exporta็ใo Indireta
				(cAliasREL)->R_EXPORT += (cAlias)->FT_VALCONT
			Case (cAlias)->CFF_CODIGO $ '10' // 10-Inciso III - Diferimento
				(cAliasREL)->R_DIFER  += (cAlias)->FT_VALCONT
			Case (cAlias)->CFF_CODIGO $ '11' // 11-Inciso III - Isen็ใo
				(cAliasREL)->R_ISENTO += (cAlias)->FT_VALCONT
		EndCase
		
		IF nValIva > (cAliasREL)->R_MIVA
			(cAliasREL)->R_MIVA := nValIva //Maior IVA
		Endif
		
		//Arquivo temp relatorio 
		(cAliasREL)->(MsUnlock())
	Endif
	
	//-- Se operacao c/ credito acumulado, separo os valores no array aCredAcum p/ geracao dos registros 5325.
	If AllTrim((cAlias)->F4_CRDACUM) == "1"
		//-- Credito Estimado do Imposto
		nCredICM := (((cAlias)->FT_VALCONT / (1 + nValIva)) * (nMedio / 100))

		If (nPosAcum := aScan(aCredAcum, {|x|	AllTrim(x[1]) + AllTrim(x[2]) + x[3] + AllTrim(x[4]) + AllTrim(x[11]) == ;
												Alltrim((cAlias)->FT_NFISCAL) + Alltrim((cAlias)->FT_SERIE) + ;
												aReg0150[nPosPart][2] + Alltrim((cAlias)->FT_LOJA) + AllTrim((cAlias)->CFF_CODIGO)})) == 0
			aAdd(aCredAcum, {})
			nPosAcum := Len(aCredAcum)
			aAdd(aCredAcum[nPosAcum], Alltrim((cAlias)->FT_NFISCAL))				// 01 - Nota Fiscal
			aAdd(aCredAcum[nPosAcum], Alltrim((cAlias)->FT_SERIE))					// 02 - Serie
			aAdd(aCredAcum[nPosAcum], aReg0150[nPosPart][2])							// 03 - Codigo Participante
			aAdd(aCredAcum[nPosAcum], Alltrim((cAlias)->FT_LOJA))					// 04 - Loja
			aAdd(aCredAcum[nPosAcum], {nValIva, 4})	                                // 05 - IVA utilizado (Indice de Valor acrescido)
			aAdd(aCredAcum[nPosAcum], IIf((cAlias)->FT_TIPO=="I",0,{nMedio, 4}))	// 06 - Perc.Medio de Cre. do Imp
			aAdd(aCredAcum[nPosAcum], nCredICM)										// 07 - Credito Estimado do Imposto
			aAdd(aCredAcum[nPosAcum], (cAlias)->FT_VALICM)							// 08 - ICMS
			aAdd(aCredAcum[nPosAcum], (cAlias)->FT_BASEICM)							// 09 - Base ICMS
			aAdd(aCredAcum[nPosAcum], (cAlias)->CFF_ITEMNF)							// 10 - Item da NF
			aAdd(aCredAcum[nPosAcum], (cAlias)->CFF_CODIGO)							// 11 - Cod. Enquadramento
		Else
			aCredAcum[nPosAcum, 7] += nCredICM
			aCredAcum[nPosAcum, 8] += (cAlias)->FT_VALICM
			aCredAcum[nPosAcum, 9] += (cAlias)->FT_BASEICM
		EndIf
	EndIf
	
	(cAlias)->(DbSkip())
EndDo

DbSelectArea(cAlias)
(cAlias)->(DbCloseArea())

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPercMedio บAutor  ณGraziele M. Paro    บ Data ณ  03/02/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPercentual Medio de Credito do Imposto                      บฑฑ
ฑฑบ          ณaliquota media das entradas das mercadorias, insumos e      บฑฑ
ฑฑบ          ณservicos recebidos relacionados as saidas geradoras de      บฑฑ
ฑฑบ          ณcredito acumulado, obtida conforme legislacao vigente.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PercMedio(dDataDe, dDataAte)
Local cCFOPSom   := "1101','1102','1116','1117','1118','1120','1121','1122','1126','1917','1151','1152','1153','1154','1251','1252','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1351','1352','1353','1354','1355','1356','1360','1931','1932','1401','1403','1651','1652','1408','1409','1658','1659','1653','1910','1124','1125','2101','2102','2116','2117','2118','2120','2121','2122','2126','2917','2151','2152','2153','2154','2251','2252','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2351','2352','2353','2354','2355','2356','2931','2932','2401','2403','2651','2652','2408','2409','2658','2659','2653','2910','2124','2125','3101','3102','3126','3127','3651','3652','3251','3301','3351','3352','3353','3354','3355','3356','3653','3930"
Local cCFOPSub   := "5201','5202','5205','5206','5207','5208','5209','5210','5918','5410','5411','5660','5661','5662','6201','6202','6205','6206','6207','6208','6209','6210','6918','6410','6411','6660','6661','6662','7201','7202','7205','7206','7207','7210','7211','7930"
Local cValContEn := "1101','1102','1116','1117','1118','1120','1121','1122','1126','1917','1151','1152','1153','1154','1351','1352','1353','1354','1355','1356','1360','1931','1932','1401','1403','1651','1652','1408','1409','1658','1659','1910','1124','1125','2101','2102','2116','2117','2118','2120','2121','2122','2126','2917','2151','2152','2153','2154','2351','2352','2353','2354','2355','2356','2931','2932','2401','2403','2651','2652','2408','2409','2658','2659','2910','2124','2125','3101','3102','3126','3127','3651','3652','3351','3352','3353','3354','3355','3356','3930"
Local cBasCalcEn := "1251','1252','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1653','2251','2252','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2653','3251','3301','3653"
Local cValContSa := "5201','5202','5205','5206','5207','5208','5209','5210','5918','5410','5411','5660','5661','6201','6202','6205','6206','6207','6208','6209','6210','6918','6410','6411','6660','6661','7201','7202','7205','7206','7207','7210','7211','7930"
Local cBasCalcSa := "5662','6662"
Local cAlias     := ""
Local lQuery     := .F.
Local nPercMed   := 0
Local VALICMENT  := 0
Local VALICMSAI  := 0
Local VALCONTENT := 0
Local BASEICMENT := 0
Local VALCONTSAI := 0
Local BASEICMSAI := 0
Local dDtIni     := dDataDe
Local dDtFin     := dDataAte

/*
Consultoria Tributaria - TRBQAU
Entendemos que para obter os valores de "Saida" e "Entrada" aplicadas nas formulas de obtencao do Percentual Medio de Credito devera obedecer a regra determinada no o item 7,item 2o, art. 30 da DDTT do RICMS SP conforme descrito a seguir:
Para a geracao do credito acumulado do imposto deverao ser consideradas as operacoes de:
Se o pedido de apropriacao do credito for solicitado no ano posterior, de Janeiro a Dezembro do ano da apropriacao.
Se o pedido de apropriacao do credito for solicitado ate  junho,       de Janeiro a Dezembro do ano anterior.
Se o pedido de apropriacao do credito for solicitado apos junho,       de Janeiro a mes anterior do ano da apropriacao.
*/
If Year(dDataBase) > Year(dDataDe)
	dDtIni := ctod("01/01/"+StrZero(Year(dDataAte),4))
	dDtFin := ctod("31/12/"+StrZero(Year(dDataAte),4))
Else
	If Month(dDataBase) <= 6
		dDtIni := ctod("01/01/"+StrZero(Year(dDataAte)-1,4))
		dDtFin := ctod("31/12/"+StrZero(Year(dDataAte)-1,4))
	Else
		dDtIni := ctod("01/01/"+StrZero(Year(dDataAte),4))
		dDtFin := LastDate(ctod("01/"+StrZero(Month(dDataAte)-1,2)+"/"+StrZero(Year(dDataAte),4)))
	EndIf
EndIf

#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		cAlias := GetNextAlias()
		lQuery := .T.
		BeginSql Alias cAlias
			//-- SOMA ICMS ENTRADAS
			SELECT SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cCFOPSom%)
			THEN SF3.F3_VALICM ELSE 0 END) AS VALICMENT,
			//-- SOMA ICMS SAIDAS
			SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cCFOPSub%)
			THEN SF3.F3_VALICM ELSE 0 END) AS VALICMSAI,
			//-- Valor Contabil Entradas
			SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cValContEn%)
			THEN SF3.F3_VALCONT ELSE 0 END) AS VALCONTENT,
			//-- Base calculo Entradas
			SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cBasCalcEn%)
			THEN SF3.F3_BASEICM ELSE 0 END) AS BASEICMENT,
			//-- Valor Contabil Saidas
			SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cValContSa%)
			THEN SF3.F3_VALCONT ELSE 0 END) AS VALCONTSAI,
			//-- Base calculo saidas
			SUM ( CASE 
			WHEN SF3.F3_CFO IN(%Exp:cBasCalcSa%)
			THEN SF3.F3_BASEICM ELSE 0 END) AS BASEICMSAI

			FROM
				%Table:SF3% SF3
			WHERE
				SF3.F3_FILIAL=%xFilial:SF3% AND
				SF3.F3_ENTRADA>=%Exp:dDtIni% AND
				SF3.F3_ENTRADA<=%Exp:dDtFin% AND
				SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% AND
				SF3.%NotDel%
		EndSql
	Else
#ENDIF
		DbSelectArea ("SF3")
		SF3->(DbSetOrder(1)) //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM, 5, 2)
		SF3->(dbSeek(xFilial("SF3")+DtoS(dDataDe)))
		While !SF3->(Eof()) .And. SF3->F3_FILIAL==xFilial("SF3") .And. DtoS(SF3->F3_ENTRADA)>=DtoS(dDtIni) .And. DtoS(SF3->F3_ENTRADA)<=DtoS(dDtFin)
			If Empty(SF3->F3_DTCANC)
				//-- SOMA ICMS ENTRADAS
				If AllTrim(SF3->F3_CFO) $ cCFOPSom
					VALICMENT += SF3->F3_VALICM
				EndIf
				//-- SOMA ICMS SAIDAS
				If AllTrim(SF3->F3_CFO) $ cCFOPSub
					VALICMSAI += SF3->F3_VALICM
				EndIf
				//-- Valor Contแbil Entradas
				If AllTrim(SF3->F3_CFO) $ cValContEn
					VALCONTENT += SF3->F3_VALCONT
				EndIf
				//-- Base calculo Entradas
				If AllTrim(SF3->F3_CFO) $ cBasCalcEn
					BASEICMENT += SF3->F3_BASEICM
				EndIf
				//-- Valor Contแbil Saidas
				If AllTrim(SF3->F3_CFO) $ cValContSa
					VALCONTSAI += SF3->F3_VALCONT
				EndIf
				//-- Base calculo saidas
				If AllTrim(SF3->F3_CFO) $ cBasCalcSa
					BASEICMSAI += SF3->F3_BASEICM
				EndIf
			EndIf
			SF3->(DbSkip())
		EndDo
#IFDEF TOP
	EndIf
#ENDIF

#IFDEF TOP
	If lQuery
		nPercMed := ((((cAlias)->VALICMENT) - ((cAlias)->VALICMSAI)) / ((((cAlias)->VALCONTENT) +((cAlias)->BASEICMENT)) - (((cAlias)->VALCONTSAI) + ((cAlias)->BASEICMSAI)))) * 100
		(cAlias)->(DbCloseArea())
	Else
#ENDIF
		nPercMed := (((VALICMENT) - (VALICMSAI)) / (((VALCONTENT) +(BASEICMENT)) - ((VALCONTSAI) + (BASEICMSAI)))) * 100
#IFDEF TOP
	EndIf
#ENDIF

Return Round(nPercMed,4)

//-- Complemento - Enquadramento legal da operacao geradora de credito acumulado de ICMS 
Static Function BuscCFF(cAliasSF3,aCred)
Local cAlias  := "CFF"
Local nPos    := 0
Local lQuery  := .F.
Local cWhere  := ""

//FORAM INCLUอDAS LINHAS PARA TRATAMENTO DA CFF POR PREOCAUวรO, POIS ESSA FUNวรO NรO ESTม SENDO USADA EM LUGAR ALGUM
#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		cAlias  := GetNextAlias()
		lQuery  := .T.
		cWhere  := "%"
		cWhere  += "CFF.CFF_NUMDOC ='"+(cAliasSF3)->F3_NFISCAL+"' AND "
		cWhere  += "CFF.CFF_SERIE  ='"+(cAliasSF3)->F3_SERIE  +"' AND "
		cWhere  += "CFF.CFF_CLIFOR ='"+(cAliasSF3)->F3_CLIEFOR+"' AND "
		cWhere  += "CFF.CFF_LOJA   ='"+(cAliasSF3)->F3_LOJA   +"' AND%"

		//If lCmpCFF
		//	cWhere  += "CFF.CFF_TIPO   ='"+(cAliasSF3)->F3_TIPO   +"' AND "
		//	cWhere  += "CFF.CFF_TPMOV ="+Iff((cAliasSF3)->F3_CFO <= 3, 'E', 'S') + " AND "
		//EndIf

		//cWhere += "%"

		BeginSql Alias cAlias
			SELECT
				CFF.*
			FROM
				%Table:CFF% CFF
			WHERE
				CFF.CFF_FILIAL=%xFilial:CFF% AND
				%Exp:cWhere%
				CFF.%NotDel%
		EndSql
	Else
#ELSE
		//If lCmpCFF
		//	CFF->(dbSetOrder(4)) //CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_TPMOV+CFF_TIPO+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_ALIN+CFF_PRG
		//	CFF->(MsSeek(xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+Iif((cAliasSF3)->F3_CFO <= 3, 'E', 'S')+(cAliasSF3)->F3_TIPO))
		//else
			CFF->(dbSetOrder(1)) //CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_ALIN+CFF_PRG+CFF_ITM+CFF_LTR
			CFF->(MsSeek(xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		//EndIf
#ELSE
	EndIf
#ENDIF
	While !((cAlias)->(Eof()))
		If	lQuery .Or. (;
			((cAlias)->CFF_FILIAL == xFilial("SF3"))          .And. ;
			((cAlias)->CFF_NUMDOC == (cAliasSF3)->F3_NFISCAL) .And. ;
			((cAlias)->CFF_SERIE  == (cAliasSF3)->F3_SERIE)   .And. ;
			((cAlias)->CFF_CLIFOR == (cAliasSF3)->F3_CLIEFOR) .And. ;
			((cAlias)->CFF_LOJA   == (cAliasSF3)->F3_LOJA))
			If (aScan(aCred, {|aX|	aX[01]==(cAlias)->CFF_FILIAL .And. ;
									aX[02]==(cAlias)->CFF_NUMDOC .And. ;
									aX[03]==(cAlias)->CFF_SERIE  .And. ;
									aX[04]==(cAlias)->CFF_CLIFOR .And. ;
									aX[05]==(cAlias)->CFF_LOJA   .And. ;
									aX[06]==(cAlias)->CFF_CODLEG .And. ;
									aX[07]==(cAlias)->CFF_CODIGO .And. ;
									aX[08]==(cAlias)->CFF_ANEXO  .And. ;
									aX[09]==(cAlias)->CFF_ART    .And. ;
									aX[10]==(cAlias)->CFF_INC    .And. ;
									aX[11]==(cAlias)->CFF_ALIN   .And. ;
									aX[12]==(cAlias)->CFF_PRG    .And. ;
									aX[13]==(cAlias)->CFF_ITM    .And. ;
									aX[14]==(cAlias)->CFF_LTR    .And. ;
									aX[15]==(cAlias)->CFF_OBS	 .And. ;
									aX[16]==(cAlias)->CFF_ITEMNF } ) ) == 0
				aAdd (aCred, {})
				nPos := Len (aCred)
				aAdd (aCred[nPos],(cAlias)->CFF_FILIAL)		//01 - Filial
				aAdd (aCred[nPos],(cAlias)->CFF_NUMDOC)		//02 - Doc.Fiscal
				aAdd (aCred[nPos],(cAlias)->CFF_SERIE)		//03 - Serie
				aAdd (aCred[nPos],(cAlias)->CFF_CLIFOR)		//04 - Cliente/Fornec
				aAdd (aCred[nPos],(cAlias)->CFF_LOJA)		//05 - Loja
				aAdd (aCred[nPos],(cAlias)->CFF_CODLEG)		//06 - Legisl
				aAdd (aCred[nPos],(cAlias)->CFF_CODIGO)		//07 - Codigo
				aAdd (aCred[nPos],(cAlias)->CFF_ANEXO)		//08 - Anexo
				aAdd (aCred[nPos],(cAlias)->CFF_ART)		//09 - Artigo
				aAdd (aCred[nPos],(cAlias)->CFF_INC)		//10 - Inciso
				aAdd (aCred[nPos],(cAlias)->CFF_ALIN)		//11 - Alinea
				aAdd (aCred[nPos],(cAlias)->CFF_PRG)		//12 - Paragrafo
				aAdd (aCred[nPos],(cAlias)->CFF_ITM)		//13 - Item
				aAdd (aCred[nPos],(cAlias)->CFF_LTR)		//14 - Letra
				aAdd (aCred[nPos],(cAlias)->CFF_OBS)		//15 - Observacao
				aAdd (aCred[nPos],StrZero(nPos,4))			//16 - COD_LEGAL
				aAdd (aCred[nPos],(cAlias)->CFF_ITEMNF)   //17 - Item NF 
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo
#IFDEF TOP
	If lQuery
		(cAlias)->(DbCloseArea())
	EndIf
#ENDIF

Return(aCred)

//-- Complemento - Exportacao
Static Function BuscCDL(cNumNf, cSerNf, cClifor, cLojaCli, cAlisCdl)
Local lQuery  	:= .F.
Local cSelecCdl	:= ""
Local cWhere  	:= ""
Local lRet		:= .F.

Default cNumNf := cSerNf := cClifor := cLojaCli := ""

cAlisCdl := "CDL"

#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		cAlisCdl  	:= GetNextAlias()
		lQuery  	:= .T.
		cSelecCdl	:= " CDL_FILIAL, CDL_DOC, CDL_SERIE, CDL_CLIENT, CDL_LOJA, CDL_NUMDE, "
		cSelecCdl	+= " CDL_ITEMNF, CDL_SEREXP, CDL_NATEXP, CDL_EMIEXP, CDL_NFEXP "
		cWhere  	:= " CDL.CDL_DOC    ='"+cNumNf  +"' AND "
		cWhere  	+= " CDL.CDL_SERIE  ='"+cSerNf  +"' AND "
		cWhere  	+= " CDL.CDL_CLIENT ='"+cClifor +"' AND "
		cWhere  	+= " CDL.CDL_LOJA   ='"+cLojaCli+"' AND CDL.D_E_L_E_T_ = ' ' "
		cWhere  	+= " ORDER BY "+SqlOrder(CDL->(IndexKey()))+" "
							//Doc + Serie + Cli/For + Loja + Item Nf

		cSelecCdl := "%" + cSelecCdl + "%"
		cWhere    := "%" + cWhere  +   "%" 

		BeginSql Alias cAlisCdl
			COLUMN CDL_EMIEXP AS DATE
			SELECT
				%Exp:cSelecCdl%
			FROM
				%Table:CDL% CDL
			WHERE
				CDL.CDL_FILIAL=%xFilial:CDL% AND
				%Exp:cWhere%
		EndSql
	EndIf
#ENDIF

If (cAlisCdl)->(!Eof())
	lRet := .T.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณFisGrvCFF บAutor  ณVICCO                 บ Data ณ 13/03/2015 บฑฑ
ฑฑฬอออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณGravacao Complemento Apuracao de Credito Acumulado ICMS      บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณExcutado na geracao dos itens doctos. fiscais de saida.      บฑฑ
ฑฑบ         ณFunction MaPvl2Sd2 -> MATA461.PRW / SIGAFAT                  บฑฑ
ฑฑบ         ณTabelas SF4 e SF2 posicionadas!                              บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function FisGrvCFF(aPvlNfs, cChave, nItNF, lReproc)

Local aAreaAnt 	:= GetArea()
Local cEnqLegUF	:= GetNewPar("MV_ENQLEG","") //Cod.Enq.Legal para cada UF conforme aliquota (estadual ou interestadual).
Local cEnqLeq  	:= ""

Default cChave 	:= Iif(lCmpCFF, xFilial("CFF")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+'S'+SF2->F2_TIPO), xFilial("CFF")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
Default nItNF  	:= SD2->D2_ITEM
Default lReproc := .F.

//-- Se operacao geradora de credito acumulado ICMS (1=Sim)
If SF4->F4_CRDACUM == "1"
	//-- Se informado Cod.Enq.Legal Cred.Acumul.ICMS CAT207
	If !Empty(SF4->F4_ENQLEG)
		cEnqLeq := SF4->F4_ENQLEG
	Else
		//-- Pesquisa parametro MV_ENQLEG se existe Cod.Enq.Legal para UF do cliente.
		cEnqLeq := Substr(cEnqLegUF,At(SF2->F2_EST,cEnqLegUF)+2,2)
	EndIf
	DbSelectArea("CFF")

	If lCmpCFF
		CFF->(DbSetOrder (4))//CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_TPMOV+CFF_TIPO+CFF_ITEMNF+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_PRG
	Else
		CFF->(DbSetOrder (3))//CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_ITEMNF+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_PRG+CFF_ITM+CFF_LTR
	EndIf
	
	CFF->(DbGoTop()) 
	If !Empty(cEnqLeq)	
		If CFE->(MsSeek(xFilial("CFE")+cEnqLeq))
			//CFF->( dbSetOrder( nIndiceRet ) )
			//If !CFF->(DbSeek(cChave+CFE->CFE_CODLEG+cEnqLeq+CFE->CFE_ANEXO+CFE->CFE_ART+CFE->CFE_INC+Iif(nIndiceRet == 1, CFE->CFE_ALIN, "")+CFE->CFE_PRG+;
			//CFE->CFE_ITM+CFE->CFE_LTR)) 

			// Ao executar o reprocessamento de CFF (FISA118) casoestaja com enquadramento legal diferente do cadastro atual irแ Excluir o registro Antigo para nใo gerar duplicidade no processamento. 
			If CFF->(DbSeek(cChave+nItNF)) .And. ((CFF->CFF_CODLEG <> CFE->CFE_CODLEG) .Or. (CFF->CFF_CODIGO <> cEnqLeq)) .And. lReproc
				RecLock("CFF",.F.)
				CFF->(DbDelete())
				MsUnLock()
			EndIf			
				//-- Gravar complemento Enq. Legal Cred. Acumul ICMS (CFF)
			If !CFF->(DbSeek(cChave+nItNF+CFE->CFE_CODLEG+cEnqLeq))
				RecLock("CFF",.T.)
				CFF_FILIAL := xFilial("CFF")
				CFF_CODLEG := CFE->CFE_CODLEG
				CFF_CODIGO := CFE->CFE_CODIGO
				CFF_ANEXO  := CFE->CFE_ANEXO
				CFF_ART    := CFE->CFE_ART
				CFF_INC    := CFE->CFE_INC
				CFF_ALIN   := CFE->CFE_ALIN
				CFF_PRG    := CFE->CFE_PRG
				CFF_ITM    := CFE->CFE_ITM
				CFF_LTR    := CFE->CFE_LTR
				CFF_OBS    := CFE->CFE_OBS
				CFF_NUMDOC := SF2->F2_DOC
				CFF_SERIE  := SF2->F2_SERIE
				CFF_CLIFOR := SF2->F2_CLIENTE
				CFF_LOJA   := SF2->F2_LOJA
				CFF_ITEMNF := nItNF

				If lCmpCFF
					CFF_TPMOV := 'S'
					CFF_TIPO  := SD2->D2_TIPO
				EndIf

				MsUnLock()
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaAnt)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCFF()
Fun็ใo que irแ buscar da tabela SD2 movimenta็๕es para a grava็ใo da tabela CFF

@param dDtIni,Date,Data inicial do Processamento
@param dDtAte,Date,Data Final do Processamento

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcCFF(dDtIni,dDtAte)
Local aAreaSav := GetArea()
Local cAliaQry := ''

cAliaQry := QrySD2(dDtIni,dDtAte)
DbSelectArea(cAliaQry)
(cAliaQry)->(DbGoTop())
Do While !(cAliaQry)->(Eof())
	SF2->(dbGoto((cAliaQry)->SF2RecNo))
	SF4->(dbGoto((cAliaQry)->SF4RecNo))
	SD2->(dbGoto((cAliaQry)->SD2RecNo))
	//-- Gravacao Complemento Apuracao de Credito Acumulado ICMS
	FisGrvCFF()
	(cAliaQry)->(DbSkip())
EndDo
DbSelectArea(cAliaQry)
(cAliaQry)->(DbCloseArea())
RestArea(aAreaSav)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} QrySD2()
Fun็ใo que monta a query para processamento da SD2

@param dDtIni,Date,Data inicial do Processamento
@param dDtAte,Date,Data Final do Processamento

@author Flavio Luiz Vicco
@since 22/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function QrySD2(dDtIni, dDtAte )
Local cAliaQry := GetNextAlias()

BeginSql Alias cAliaQry
	SELECT
		SF2.R_E_C_N_O_ SF2RecNo, SF4.R_E_C_N_O_ SF4RecNo, SD2.R_E_C_N_O_ SD2RecNo
	FROM
		%Table:SD2% SD2
	JOIN
		%table:SF2% SF2
	ON	SF2.F2_FILIAL  = %xFilial:SF2% AND
		SF2.F2_DOC     = SD2.D2_DOC AND
		SF2.F2_SERIE   = SD2.D2_SERIE AND
		SF2.F2_CLIENTE = SD2.D2_CLIENTE AND
		SF2.F2_LOJA    = SD2.D2_LOJA AND
		SF2.F2_TIPO    = SD2.D2_TIPO AND
		SF2.%NotDel%
	JOIN
		%table:SF4% SF4
	ON	SF4.F4_FILIAL  = %xFilial:SF4% AND
		SF4.F4_CODIGO  = SD2.D2_TES AND
		SF4.%NotDel%
	WHERE
		SD2.D2_FILIAL   = %xFilial:SD2% AND
		SD2.D2_EMISSAO >= %Exp:dTos(dDtIni)% AND 
		SD2.D2_EMISSAO <= %Exp:dTos(dDtAte)% AND
		SD2.%NotDel%
EndSql

Return cAliaQry

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณReg5315   บAutor  ณjoao.pellegrini       บ Data ณ 08/12/2015 บฑฑ
ฑฑฬอออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณGeracao do Registro 5315: Operacoes de Saida                 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reg5315(aReg5315, aSaid, nCrOutSP, lAcumula, lDevol, aDevol)

Local nPos5315 := 0

DEFAULT lAcumula := .F.
DEFAULT lDevol   := .F.
DEFAULT aDevol	 := {}

lDev := Iif(lDev .And. Len(aDevol) < 8, .F., lDev)

If lAcumula
	If lDevol
		nPos5315 := aScan(aReg5315, {|x| x[2] == aDevol[05] .And. x[3] == aDevol[06] .And. x[4] == aDevol[04] .And.;
											x[5] == aDevol[03] .And. x[6] == aSaid[03] .And. x[10] == lAcumula})  
	Else
		nPos5315 := aScan(aReg5315, {|x| x[2] == aSaid[05] .And. x[3] == aSaid[07] .And. x[4] == aSaid[02] .And.;
		 									x[5] == aSaid[01] .And. x[6] == aSaid[03] .And. x[10] == lAcumula})  
	Endif										
Endif

If nPos5315 == 0
	aAdd(aReg5315, {})
	nPos5315 := Len(aReg5315)
	aAdd(aReg5315[nPos5315], "5315")									// 01 - REG
	aAdd(aReg5315[nPos5315], Iif(!lDevol,aSaid[05],aDevol[05]))			// 02 - DT_EMISSAO
	aAdd(aReg5315[nPos5315], Iif(!lDevol,aSaid[07],aDevol[06]))			// 03 - TIPO_DOC
	aAdd(aReg5315[nPos5315], Iif(!lDevol,aSaid[02],aDevol[04]))			// 04 - SER
	aAdd(aReg5315[nPos5315], Iif(!lDevol,aSaid[01],aDevol[03]))			// 05 - NUM_DOC
	aAdd(aReg5315[nPos5315], aSaid[03])									// 06 - COD_PART
	aAdd(aReg5315[nPos5315], Iif(!lDevol,aSaid[11],aDevol[08] * -1))	// 07 - VL_SAI
	aAdd(aReg5315[nPos5315], aSaid[09])									// 08 - PERC_CRDOUT
	aAdd(aReg5315[nPos5315], nCrOutSP)									// 09 - VALOR_CRDOUT
	aAdd(aReg5315[nPos5315], lAcumula)									// 10 - FLAG SE O REGISTRO EH ACUMULADO
Else
	aReg5315[nPos5315, 7] += Iif(!lDevol,aSaid[11],aDevol[08] * -1)
	aReg5315[nPos5315, 9] += nCrOutSP  	
EndIf

Return nPos5315
			
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณReg5315   บAutor  ณjoao.pellegrini       บ Data ณ 19/01/2016 บฑฑ
ฑฑฬอออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณRetorna a posicao do campo SERIE conforme o registro.        บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RegPosSer(cReg)

Local cPos4 := "5315|5320" // Registros que o campo SERIE eh a posicao 4 do array.
Local nPos  := 0
//Local cPos5 := "5340" 

Do Case
	Case cReg $ cPos4
		nPos := 4
	//Case cReg $ cPos5
	//	nPos := 5
EndCase

Return nPos

/*
//-------------------------------------------------------------------
/{Protheus.doc} LoadCFFIndex
 
@author Allan Santos da Silva
@since 25/04/2017
@version 11.80

/
//-------------------------------------------------------------------

Static Function LoadCFFIndex()

nIndiceRet 	:= RetCFFIndex()  // AliasIndic

Return Nil



//-------------------------------------------------------------------
/{Protheus.doc} RetCFFIndex
 
@author Allan Santos da Silva
@since 25/04/2017
@version 11.80

/
//-------------------------------------------------------------------

Function RetCFFIndex()

Local cAlias		:= "CFF3"
Local nIndiceRet	:= 0

SIX->(DbSetOrder(1))

If SIX->(DbSeek(cAlias))
    nIndiceRet := Val(SIX->ORDEM)
End

//Se por algum motivo nao econtre o indice equivamente, por padrao retorna o indice "1".
If nIndiceRet == 0
    nIndiceRet := 1
EndIf

Return nIndiceRet*/


//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Rafael S.Oliveira
@since 30/03/2017
@version 12.1.16
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cAliasREL)

Local oReport
Local oRepVal
Local nTamCont := TamSx3("FT_VALCONT")[1]
Local oBreak

oReport:= TReport():New("CAT207_DGCA ","Demonstrativo da gera็ใo de cr้dito acumulado","",{|oReport| ReportPrint(oReport,cAliasREL)})
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:HideParamPage()

oRepVal:= TRSection():New(oReport,"Notas Fiscais",{cAliasREL},/*{Array com as ordens do relat๓rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oRepVal,"R_FILIAL"		,cAliasREL	,"Filial"					,/*Picture*/			,FWGETTAMFILIAL	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_CFOP"		,cAliasREL	,"CFOP"						,/*Picture*/			,4				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_INTER7"		,cAliasREL	,"Inter. 7%"				,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_INTER12"	,cAliasREL	,"Inter. 12%"				,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_INTERNA7"	,cAliasREL	,"Interna 7%"				,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_RED7"		,cAliasREL	,"Reducao 7% P/4,1%"		,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_RED12"	    ,cAliasREL	,"Reducao 12% P/8,8%"		,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_RED18"		,cAliasREL	,"Reducao 18% P/5,6%"		,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_EXPORT"		,cAliasREL	,"Exportacao"				,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_DIFER"		,cAliasREL	,"Diferimento"				,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_ISENTO"		,cAliasREL	,"Isen.Manut.Cred."			,"@E 99,999,999,999.99"	,nTamCont		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oRepVal,"R_MIVA"		,cAliasREL	,"Maior IVA"				,"@E 99.9999"			,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oRepVal,{|| R_FILIAL},"Totalizadores",.F.,'Totalizadores',.T.)
TRFunction():New(oRepVal:Cell("R_INTER7"),NIL,"SUM",oBreak,'Inter. 7%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_INTER12"),NIL,"SUM",oBreak,'Inter. 12%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_INTERNA7"),NIL,"SUM",oBreak,'Interna 7%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_RED7"),NIL,"SUM",oBreak,'Reducao 7% P/4,1%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_RED12"),NIL,"SUM",oBreak,'Reducao 12% P/8,8%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_RED18"),NIL,"SUM",oBreak,'Reducao 18% P/5,6%',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_EXPORT"),NIL,"SUM",oBreak,'Exportacao',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_DIFER"),NIL,"SUM",oBreak,'Diferimento',,,.F.,.F.)
TRFunction():New(oRepVal:Cell("R_ISENTO"),NIL,"SUM",oBreak,'Isen.Manut.Cred.',,,.F.,.F.)

oRepVal:SetHeaderBreak(.T.) //Imprime cabe็alho das c้lulas ap๓s quebra
oRepVal:SetHeaderSection(.T.)

Return(oReport) 


        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relat๓rio.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
Local oRepVal	:= oReport:Section(1)

oRepVal:Print()

return

//-------------------------------------------------------------------
/*/{Protheus.doc}
@description geracao do arquivo texto
@author Flavio Luiz Vicco
@since 15/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DumpFile(nAcao, cDir, cFileDest, lAutomato)
Local cLib       := ""
Local cStartPath := AllTrim(GetSrvProfString("StartPath",""))
Local nRemType   := GetRemoteType(@cLib)
Local lHtml      := IIf(nRemType == 5 ,.T.,.F.)
Local nRet       := 0

Default nAcao    := 1
Default cDir     := ""
Default cFileDest:= ""
Default lAutomato:= .F.

If nAcao == 1
	If Empty(cDir) .Or. lHtml
		cDir := cStartPath
	EndIf
	If !SubStr(cDir,Len(cDir),1)$"\/"
		cDir += "\"
	EndIf
	cFileDest := AllTrim(cFileDest)
	cFileDest := cDir+cFileDest
	If IsSrvUnix() .Or. nRemType == 2
		cFileDest := StrTran(cFileDest,"\","/")
		cFileDest := StrTran(StrTran(StrTran(Alltrim(cFileDest)," ","_"),chr(13),""),chr(10),"")
	Else
		//Se o drive nao existir, pergunto ao usuario se deseja cria-lo atraves da funcao LjDirect()
		If !ExistDir(cDir) .And. !lAutomato
			LjDirect(cDir,.T.)
		Endif
	EndIf
Else
	If File(cFileDest)
		If lHtml			
			MsgAlert("Em fun็ใo do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo serแ desconsiderado, e serแ processado conforme configura็ใo do navegador.")
			
			nRet := CPYS2TW(cFileDest)
			If nRet == 0
				FErase(cFileDest)
				MsgInfo(OemToAnsi(STR0001 + cFileDest + STR0002)) //"Arquivo "###" gerado com sucesso!"
			EndIf
		ElseIf !lAutomato
			MsgInfo(OemToAnsi(STR0001 + cFileDest + STR0002)) //"Arquivo "###" gerado com sucesso!"
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0003)) //"Nใo foi possํvel gerar o arquivo!"
	EndIf
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc}
@description inclusใo de valores no relat๓rio da CAT207 para as notas de devolu็ใo
@author ricardo.cavalcante
@since 26/07/2019
@version 1.0
nValCont - Valor Contแbil da NF
cAliasREL - Tabela Gerada para o Relat๓rio
nCodigo - C๓digo de Enquadramento Legal
nAliq - Aliquota de ICMS
nIvaUtil - Iva Utilizado
/*/
//-------------------------------------------------------------------
Static Function GeraRel(nValCont,cAliasREL,nCodigo,nAliq,nIvaUtil)


If !(cAliasREL)->(MsSeek(cFilAnt+Alltrim(("SFT")->FT_CFOP)))
		RecLock (cAliasREL, .T.)
		(cAliasREL)->R_FILIAL	:= cFilAnt
		(cAliasREL)->R_CFOP		:= Alltrim(("SFT")->FT_CFOP)
	Else
		RecLock (cAliasREL, .F.)
Endif
	
		
	Do Case
		Case nCodigo $ '01' // 01-Inciso I - Op. Interest. alํq.7%
			(cAliasREL)->R_INTER7  += nValCont
		Case nCodigo $ '02' // 02-Inciso I - Op. Interest. alํq.12%
			(cAliasREL)->R_INTER12 += nValCont
		Case nCodigo $ '03' // 03-Inciso I - Op. Int. alํq 7%
			(cAliasREL)->R_INTERNA7 += nValCont
		Case nCodigo $ '06' // 06-Inciso II - Red. de Base
			If nAliq == 7		//Red. 7% P/4,1%
				(cAliasREL)->R_RED7	 += nValCont
			Elseif nAliq == 12	//Red. 12% P/ 8,8%
				(cAliasREL)->R_RED12 += nValCont
			Elseif nAliq == 18  //Red. 18% P/ 5,6%
				(cAliasREL)->R_RED18 += nValCont
			Endif			
		Case nCodigo $ '07|08' // 07-Inciso III - Exporta็ใo 	08-Inciso III - Exporta็ใo Indireta
			(cAliasREL)->R_EXPORT += nValCont
		Case nCodigo $ '10' // 10-Inciso III - Diferimento
			(cAliasREL)->R_DIFER  += nValCont
		Case nCodigo $ '11' // 11-Inciso III - Isen็ใo
			(cAliasREL)->R_ISENTO += nValCont
	EndCase

	IF nIvaUtil > (cAliasREL)->R_MIVA
		(cAliasREL)->R_MIVA := nIvaUtil //Maior IVA
	Endif
	
	//Arquivo temp relatorio 
	(cAliasREL)->(MsUnlock())
		

Return Nil
