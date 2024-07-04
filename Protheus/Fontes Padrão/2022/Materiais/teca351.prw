#include "TECA351.CH"
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "XMLXFUN.CH"  

#DEFINE VAL_MAT			1
#DEFINE VAL_VERBA		2
#DEFINE VAL_VALOR		3
#DEFINE VAL_QTDTOT		4
#DEFINE VAL_QTDMIN		5
#DEFINE VAL_TIPOVERB	6
#DEFINE VAL_FILIAL		7
#DEFINE VAL_CCUSTO		8
#DEFINE VAL_RECNO		9
#DEFINE VAL_PROCESSO	10
#DEFINE VAL_ITEM		11
#DEFINE VAL_CLVL		12
#DEFINE VAL_LANCDIARIO	13

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA351()
Chamada de menu. Envio de Beneficio ao RH
@author Vendas CRM
@since 20/02/2013
/*/
//-------------------------------------------------------------------- 
Function TECA351(lSemTela, aParams, aContracts)

Local cTpExp := SuperGetMV("MV_GSOUT", .F., "1") //1 - Integração RH protheus(Default) - 2 Ponto de Entrada - 3 Arquivo CSV
Local cDirArq := At351RHD()
Local lProcessa := .T.
Local nHandle := 0
Local nOpc := 0
Local nX
Local cPE := "At351IBe"
Local lContinua := .T.
Local aRet := {.T.,{}}
Local lGerOs := SuperGetMv("MV_GSGEROS",,'1') == '1'
Local lTECA351B := TecHasPerg("MV_PAR01","TECA351B")
Local cPergunta := IIF(lTECA351B,"TECA351B","TECA351A") //Pergunta TECA351A descontinuada. Remover referências quando a 12.1.27 for descontinuada
Local cFilBkp := cFilAnt
Local aMtFil := {}
Local cTexMsg := ""

Default lSemTela := .F.
Default aParams := {}
Default aContracts := {}

IF !lGerOs .AND. !(HasABBBene())
	lContinua := .F.
	MsgAlert(STR0034)
	//"O parâmetro de Geração de OS (MV_GSGEROS) está desabilitado, porém o campo ABB_BENENV não foi localizado no sistema. 
	//Habilite o parâmetro ou crie o campo para utilizar esta funcionalidade"
EndIf

If lContinua
	If !lSemTela
		lContinua := Pergunte(cPergunta,.T.)
	Else
		Pergunte(cPergunta,.F.)
	EndIf
EndIf

If !Empty(aParams)
	MV_PAR01 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR01"})][2]
	MV_PAR02 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR02"})][2]
	MV_PAR03 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR03"})][2]
	MV_PAR04 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR04"})][2]
	MV_PAR05 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR05"})][2]
	MV_PAR06 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR06"})][2]
	MV_PAR07 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR07"})][2]
	MV_PAR08 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR08"})][2]
	If ASCAN(aParams, {|d| d[1] == "MV_PAR09"}) > 0 
		MV_PAR09 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR09"})][2]
	EndIf
	If ASCAN(aParams, {|d| d[1] == "MV_PAR10"}) > 0 
		MV_PAR10 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR10"})][2]
	EndIf
	If ASCAN(aParams, {|d| d[1] == "MV_PAR11"}) > 0 
		MV_PAR11 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR11"})][2]
	EndIf
	If ASCAN(aParams, {|d| d[1] == "MV_PAR12"}) > 0 
		MV_PAR12 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR12"})][2]
	EndIf
EndIf

If lContinua
	If TecHasPerg("MV_PAR10","TECA351B")
		IF EMPTY(MV_PAR10)
			aAdd(aMtfil,cFilant)
		Else
			At900PMtFl(MV_PAR10,@aMtFil,cPergunta,"MV_PAR10")
		EndIF
	Else
		AADD(aMtFil, cFilAnt)
	EndIf
	nOpc := IIF(MV_PAR08 == 1, 3, 5)

	If nOpc == 5
		cPe := "At351EBe"
	EndIf	
	
	If "2" $ cTpExp .and. !ExistBlock(cPE)
		If !lSemTela
			Help(,, "TECA351",STR0021+cPe+STR0022,,1, 0) //"Ponto de Entrada "##" não compilado." 
		Else
			AADD(aRet[2], STR0021+cPe+STR0022 )
		EndIf
		
		cTpExp := StrTran(cTpExp, "2", "")
	EndIf
	
	For nX := 1 To LEN(aMtFil)
		cFilant := aMtFil[nX]
		If "3" $ cTpExp .AND. nOpc <> 5
			nHandle := At351RHF("at351", cDirArq, .T., nOpc)
		
			If nHandle == -1
				aRet[1]	:= .F.
				AADD(aRet[2], STR0023)
				lContinua := .F.
				If !lSemTela
					Help(,, "TECA351",STR0023 ,, 1, 0)//"Problemas na criação do arquivo CSV."
				EndIf
			EndIf
		EndIf
		
		If lProcessa
			If nOpc <> 5  
				If !lSemTela
					Processa( { || At351Init(cTpExp,nHandle,lSemTela, @aRet, aContracts, @cTexMsg) }, STR0004, STR0003, .F.)
				Else
					At351Init(cTpExp,nHandle,lSemTela, @aRet, aContracts, @cTexMsg)
				EndIf
			Else
				If !lSemTela
					Processa( { || At351Excl(cTpExp, lSemTela, @aRet, aContracts, @cTexMsg) }, STR0004, STR0016, .F.)
				Else
					At351Excl(cTpExp, lSemTela, @aRet, aContracts, @cTexMsg)
				EndIf
			EndIf
		EndIf
		If nHandle > 0
			fClose(nHandle)
		EndIf
	Next nX

	AtShowLog(cTexMsg,STR0001,.T.,.T.,.T.,.F.) 
	
EndIf

cFilAnt := cFilBkp

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At351Init()
Inicializador do processo de envio de beneficio ao RH
@author Vendas CRM
@since 20/02/2013
/*/
//-------------------------------------------------------------------- 
Function At351Init( cTpExp,nHandle,lSemTela, aRet, aContracts, cTexMsg) 
Local cAliasABB 		:= ''
Local aValores	:= {} //acumulador dos beneficios por funcionario/verba
Local nPosBenefi	:= 0 //posicao do beneficio no array aValores (auxiliar para fazer o agrupamento dos valores por atendente/verba
Local nValorBenef	:= 0 //axiliar - para calcular o valor do beneficio a ser pago (baseado na verba)
Local nFator		:= 0 //auxiliar - multiplicador (dias ou horas) para calcular o valor do beneficio
Local aBenefPagar	:= {} //beneficios que serao pagos
Local cRetorno	:= ''
Local cAux		:= ""
Local nPerc 	:= 100 // valor percentual a considerar do valor da verba
Local cCusto := ""//Centro de Custo
Local cCodPer 	:= MV_PAR05
Local cCodPag 	:= MV_PAR06
Local cCodRot 	:= IF(Empty(MV_PAR07), "FOL", MV_PAR07)
Local lGCT 		:= .T.
Local aAtdDias 	:= {}  // lista com os dia já calculados para as a verbas por dia formato { filial, mat, { dDia1, dDia2, ... , dUltDia } }
Local nPosAtd 	:= 0
Local nPosDia 	:= 0
Local nRegEnv 	:= 0
Local nRegProb	:= 0
Local nTotalReg := 0
Local lSemOs	:= HasABBBene() .AND. SuperGetMv("MV_GSGEROS",,'1') == '2'
Local lContabil	:= TecEntCtb("ABS")

Default cTpExp := "1"
Default nHandle := 0
Default lSemTela := .F.
Default aRet := {.T.,{}}
Default aContracts := {}

//----------------------------------------------------------------------------------------------
// Estrutura do aValores
// [n]
// [n][1] - matricula do funcionario
// [n][2] - codigo da verba do beneficio
// [n][3] - valor acumulado (total) do beneficio
// [n][4] - qtde acumulado (dias ou horas) trabalhadas do atendente - necessaria para validar qtde min para pagar o beneficio
// [n][5] - qtde minima exigida para pagar o beneficio da verba 
// [n][6] - Tipo Verba
// [n][7] - Filial
// [n][8] - Centro de Custo
// [n][9] - Recnos do AB9
// [n][10] - Codigo do processo

//----------------------------------------------------------------------------------------------

// Bloqueada a opção para contrato de manutenção do field service
cAliasABB := At351Qry(.T., aContracts )

DbSelectArea(cAliasABB)
If (cAliasABB)->(EOF()) 
	aRet[1] := .F.
	AADD(aRet[2],STR0006)
	
	If !lSemTela
		cTexMsg += STR0039+" - "+cFilAnt+" / "+STR0006+", "+STR0005+CRLF//"Filial"/"Benefícios do Contrato"//"Não há benefício a enviar"
	EndIf
Else
	
	While !(cAliasABB)->(EOF())
	
		//------------------------------------------------------------------
		//Calcula valor a ser pago
		//-------------------------------------------------------------------
		If (cAliasABB)->RV_TIPO == "H" //verba por hora
			cAux := (cAliasABB)->TOTFAT
			If lSemOs
				cAux := Alltrim(cAux)
				cAux := STRTRAN(cAux, "D")
				cAux := STRTRAN(cAux, CHAR(9))
				cAux := StrZero(VAL(STRTOKARR2( cAux, ":")[1]),2) + ":" + STRTOKARR2( cAux, ":")[2]
			Else
				cAux := RIGHT(STRTOKARR2( cAux, ":")[1],2) + ":" + STRTOKARR2( cAux, ":")[2]
			EndIf
			nFator := HoraToInt(cAux)
		ElseIf  (cAliasABB)->RV_TIPO == "D" //verba por dia 
			// avaliar a qtde de dias na diferença e se ele já foi considerado
			// esse formato pode acabar gerando um dia de diferença nos benefícios quando existir turnos que usem a madrugada como horário de trabalho e intervalos
			If ( nPosAtd := aScan( aAtdDias, {|x| x[1] == (cAliasABB)->RA_FILIAL .And. x[2] == (cAliasABB)->RA_MAT .And. x[3] == (cAliasABB)->TFF_COD } ) ) > 0
				
				// caso encontre o atendente, verifica se o dia já foi calculado
				If ( nPosDia := aScan( aAtdDias[nPosAtd, 4], {|x| x == StoD((cAliasABB)->DTINI) } ) ) == 0
					// adiciona somente o dia
					aAdd( aAtdDias[nPosAtd, 4], STOD((cAliasABB)->DTINI) )
				Else
					// quando encontra o dia, o fator é zero para não calcular
					nFator := 0
				EndIf
			Else
				nFator 		:= (StoD((cAliasABB)->DTFIM) - StoD((cAliasABB)->DTINI)) + 1
				
				// adiciona a informação do atendente e dia calculado no array
				aAdd( aAtdDias, { (cAliasABB)->RA_FILIAL, (cAliasABB)->RA_MAT, (cAliasABB)->TFF_COD, { StoD((cAliasABB)->DTINI) } } )
			EndIf
		ElseIf  (cAliasABB)->RV_TIPO == "V" //verba por valor (paga uma vez só no processamento todo) 
			nFator 		:= 1
		EndIf
		
		//------------------------------------------------------------------
		//  caso o percentual seja zero, considera o valor integral da verba 
		//-------------------------------------------------------------------
		If (cAliasABB)->RV_PERC != 0
			 nPerc := (cAliasABB)->RV_PERC / 100
		Else
			nPerc := 100
		EndIf
		
		nValorBenef := (cAliasABB)->ABP_VALOR * nFator * nPerc
		
		//-----------------------------------------------------------------------------------------------------
		//Verifica se ja foi incluido no aValores algum valor de beneficio da mesma verba para o funcionario
		//-----------------------------------------------------------------------------------------------------
		nPosBenefi := AScan(aValores, {|x| AllTrim(x[1]) == AllTrim((cAliasABB)->RA_MAT) .AND. Alltrim(x[2]) == Alltrim((cAliasABB)->RV_COD) } ) 
		
		//------------------------------------------------------------------
		//Adiciona os valores totais no aValores
		//-------------------------------------------------------------------
		If nPosBenefi == 0 //Se ainda nao tiver a verba para o atendente, adiciona no aValores
			cCusto := If(!lGCT,(cAliasABB)->AAH_CCUSTO,(cAliasABB)->ABS_CCUSTO)
			
			If Empty(cCusto)
				cCusto := (cAliasABB)->RA_CC//por padrão pega centro de custo do funcionário
			EndIf
			AADD(aValores, {(cAliasABB)->RA_MAT,;
							(cAliasABB)->RV_COD,;
							nValorBenef,;
							nFator,;
							(cAliasABB)->ABP_QTDMIN,;
							(cAliasABB)->RV_TIPO,;
							(cAliasABB)->RA_FILIAL,;
							cCusto,;
							{(cAliasABB)->RECNO},;
							(cAliasABB)->RA_PROCES,;
							If(lContabil, (cAliasABB)->ABS_CLVL, ""),;
							If(lContabil, (cAliasABB)->ABS_ITEM, ""),;
							(cAliasABB)->RV_LCTODIA})
		Else
			If (cAliasABB)->RV_TIPO <> "V" //Se ja tiver a verba para o atendente (e a verba nao for do tipo "valor"), soma o valor ao que ja tem no aValores	 
				aValores[nPosBenefi][VAL_VALOR] += nValorBenef
				aValores[nPosBenefi][VAL_QTDTOT] += nFator
			EndIf
			Aadd(aValores[nPosBenefi][VAL_RECNO], (cAliasABB)->RECNO)
		EndIf
	
		(cAliasABB)->(DbSkip())
	End
	
	//valida beneficios abaixo da qtde minima para pagamento
	At351ValMin(aValores, @aBenefPagar)
	nTotalReg := Len(aBenefPagar)
	
	//envia beneficios ao RH
	cRetorno := At351EnvRH(aBenefPagar,cCodPer,cCodRot,cCodPag, cTpExp,nHandle,lSemTela,@aRet, @nRegEnv, @nRegProb)
	
	//Cria log com o retorno do envio e com os beneficios que nao atingiram a quantidade mínima para pagamento
	At351Log(cRetorno, lSemTela, @aRet, nTotalReg,  nRegEnv, nRegProb, @cTexMsg)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At351Qry()
Gera a tabela temporaria para trazer os beneficios a serem enviados ao RH
@author Vendas CRM
@since 20/02/2013
@return 	Caracter, Identificação da tabela temporária com o resultado da query.
@param 		nOpcao, numérico, define qual tipo de contrato usar 1=Manut. Field Service, 2=GCT.
@param 		, lógico, define se o processamento é para enviar (verdadeiro) ou excluir (falso).
/*/
//-------------------------------------------------------------------- 
Function At351Qry(lEnvia, aContracts )
Local nX
Local cAliasABB := GetNextAlias()
Local cSql := ""
Local cSitBenEnv
Local lMV_GSXINT := SuperGetMv("MV_GSXINT",,"2") != "2"
Local lSemOs := HasABBBene() .AND. SuperGetMv("MV_GSGEROS",,'1') == '2'
Local cComAA1 := FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA := FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local lMultFil := SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local lContabil	:= TecEntCtb("ABS")

Default lEnvia := .T.
Default aContracts := {}

If !lEnvia
	cSitBenEnv := "'T'"
Else
	cSitBenEnv := "'F','',' '"
EndIf

cSql += "SELECT DISTINCT "
If !lMV_GSXINT
	cSql += " SRA.RA_FILIAL "
Else
	cSql += " AA1.AA1_FUNFIL AS RA_FILIAL "
Endif
cSql += " , AA1.AA1_CDFUNC AS RA_MAT, "
cSql += " SRA.RA_PROCES, "
cSql += " SRA.RA_CC, 
cSql += " ABS.ABS_CCUSTO, "
cSql += " SRV.RV_COD, "
cSql += " SRV.RV_TIPO, "
cSql += " SRV.RV_PERC, "
cSql += " SRV.RV_LCTODIA, "
cSql += " ABP.ABP_VALOR, "
cSql += " ABP.ABP_QTDMIN, "
cSql += " ABP.ABP_CODPRO, "
If lContabil
	cSql += " ABS.ABS_CLVL, "
	cSql += " ABS.ABS_ITEM, "
EndIf
If lSemOs
	cSql += " ABB.ABB_HRTOT TOTFAT, "
	cSql += " ABB.ABB_DTINI DTINI, "
	cSql += " ABB.ABB_DTFIM DTFIM, "
	cSql += " ABB.R_E_C_N_O_ RECNO, "
Else
	cSql += " AB9.AB9_TOTFAT TOTFAT, "
	cSql += " AB9.AB9_DTINI DTINI, "
	cSql += " AB9.AB9_DTFIM DTFIM, "
	cSql += " AB9.R_E_C_N_O_ RECNO, "
EndIf
cSql += " TFF.TFF_COD "
cSql += " FROM " + RetSqlName("ABB") + " ABB "
If lSemOs
	cSql += " INNER JOIN "+RetSqlName("TDV")+" TDV ON "
	If lMultFil
		cSql += FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.)
	Else
		cSql += " TDV.TDV_FILIAL='"+xfilial("TDV")+"' "
	EndIf
	cSql += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.D_E_L_E_T_= ' ' "
	cSql += " AND TDV.TDV_DTREF >='" + DtoS(MV_PAR03) + "' AND TDV.TDV_DTREF <= '" + DtoS(MV_PAR04) + "' "
Else
	cSql += " INNER JOIN " + RetSqlName("AB9") + " AB9  ON " 
	If lMultFil
		cSql += FWJoinFilial("ABB" , "AB9" , "ABB", "AB9", .T.)
	Else
		cSql += " AB9.AB9_FILIAL = '" + xfilial("AB9") + "' "
	EndIf
	cSql += " AND AB9.AB9_ATAUT = ABB.ABB_CODIGO AND AB9.D_E_L_E_T_= ' ' AND AB9.AB9_ATAUT != '" + Space(TamSX3("AB9_ATAUT")[1]) + "' "
	cSql += " AND AB9.AB9_BENENV IN (" + cSitBenEnv + ") "
	cSql += " AND AB9.AB9_DTINI >='" + DtoS(MV_PAR03) + "' AND AB9.AB9_DTINI <= '" + DtoS(MV_PAR04) + "' "
EndIf
cSql += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON AA1.AA1_FILIAL = '" + xfilial("AA1") + "' "
cSql += " AND AA1.AA1_CODTEC = ABB.ABB_CODTEC AND AA1.AA1_ALOCA = '1' AND AA1.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN " + RetSqlName("SRA") + " SRA ON "
If lMultFil
	cSql += " SRA.RA_FILIAL = AA1.AA1_FUNFIL AND "
	cSql += FWJoinFilial("SRA" , "AA1" , "SRA", "AA1", .T.)
Else
	cSql += " SRA.RA_FILIAL = '" + xfilial("SRA") + "' "
EndIf
cSql += " AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON "
If lMultFil
	cSql += FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.)
Else
	cSql += " ABQ.ABQ_FILIAL = '" + xfilial("ABQ") + "' "
EndIf
cSql += " AND ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND ABQ.ABQ_ORIGEM = 'CN9' AND "
cSql += " ABQ.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN "+RetSqlName("TFF")+" TFF ON TFF.TFF_FILIAL=ABQ.ABQ_FILTFF AND "
cSql += " TFF.TFF_COD=ABQ.ABQ_CODTFF AND TFF.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN "+RetSqlName("ABP")+" ABP ON "
If lMultFil
	cSql += FWJoinFilial("ABP" , "TFF" , "ABP", "TFF", .T.)
Else
	cSql += " ABP.ABP_FILIAL='"+xFilial("ABP")+"' "
EndIf
cSql += " AND ABP.ABP_ITRH = TFF.TFF_COD AND ABP.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN "+RetSqlName("TFL")+" TFL ON "
If lMultFil
	cSql += FWJoinFilial("TFL" , "TFF" , "TFL", "TFF", .T.)
Else
	cSql += " TFL.TFL_FILIAL='"+xFilial("TFL")+"' "
EndIf
cSql += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI AND TFL.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN "+RetSqlName("ABS")+" ABS ON "
If lMultFil
	cSql += FWJoinFilial("TFL" , "ABS" , "TFL", "ABS", .T.)
Else
	cSql += " ABS.ABS_FILIAL='"+xFilial("ABS")+"' "
EndIf
cSql += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL AND ABS.D_E_L_E_T_= ' ' "
cSql += " INNER JOIN "+RetSqlName("SRV")+" SRV ON "
If lMultFil
	cSql += FWJoinFilial("ABP" , "SRV" , "ABP", "SRV", .T.)
Else
	cSql += " SRV.RV_FILIAL='"+xfilial("SRV")+"' "
EndIf
cSql += " AND SRV.RV_COD = ABP.ABP_VERBA AND SRV.D_E_L_E_T_= ' ' "
cSql += " WHERE "
cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND ABB.D_E_L_E_T_ = ' ' AND "
If lSemOs
	cSql += " ABB.ABB_BENENV IN ("+cSitBenEnv+") AND "
EndIf
cSql += " ABB.ABB_CHEGOU = 'S' AND ABB.ABB_ATENDE = '1' AND "

If TecHasPerg("MV_PAR11","TECA351B") .AND. TecHasPerg("MV_PAR12","TECA351B")
	cSql += " ABB.ABB_CODTEC BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "
EndIf

cSql += " ABP.ABP_ENTIDA = '' AND "
If !EMPTY(aContracts)
	cSql += " ABQ.ABQ_CONTRT IN ( "
	For nX := 1 to LEN(aContracts)
		cSql += "'" + aContracts[nX] + "',"
	Next nX
	cSql := LEFT(cSql, LEN(cSql) - 1)
	cSql += " ) "
Else
	cSql += " ABQ.ABQ_CONTRT >='" + ALLTRIM(MV_PAR01) + "' AND ABQ.ABQ_CONTRT <= '" + ALLTRIM(MV_PAR02) + "' "
EndIf

cSql += " ORDER BY RA_FILIAL, RA_MAT "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasABB, .F., .T.)

Return cAliasABB


//-------------------------------------------------------------------
/*/{Protheus.doc} At351ValMin()

Trata o Array base retirando os registros que estiverem abaixo do valor mínimo

@param aValores , array, Acumulador de beneficios
@param aBenef , array, array com apenas os beneficios a serem pagos (removido os que nao atingiram a qtdemin)
@todo separar os registros retirados para guardar em log
    
@author Vendas CRM
@since 20/02/2013
/*/
//-------------------------------------------------------------------- 
Function At351ValMin(aValores, aBenef)
Local nI := 0

//beneficios do aBenef serao pagos
//beneficios do aRetirados nao serao pagos, mas serao logados para consulta

For nI := 1 to Len(aValores)
	
	//se a verba for do tipo "valor" ou se a quantidade minima para pagamento for atingida, separa nos registros a pagar 
	If aValores[nI][VAL_TIPOVERB] == "V" .OR. aValores[nI][VAL_QTDTOT] >= aValores[nI][VAL_QTDMIN]
		Aadd(aBenef,aValores[nI])
	EndIf
Next

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} At351EnvRH()

Envia os beneficios ao RH

@param aBenefPagar array, Apenas os beneficios a serem pagos (removido os que nao atingiram a qtdemin)
@return mensagem de erro na inclusao dos beneficios ao rh 
    
@author Vendas CRM
@since 20/02/2013
/*/
//-------------------------------------------------------------------- 
Function At351EnvRH(aBenefPagar,cCodPer,cCodRot,cCodPag, cTpExp,nHandle, lSemTela, aRet, nEnviados, nProblemas)
Local cRet			:= ''
Local aCabec    	:= {}
Local aItens    	:= {}
Local aItensFinal	:= {}
Local nI			:= 0
Local nJ			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nA			:= 0
Local cUltMat		:= ''
Local lErro		:= .F.
Local lInclusao	:= .T.
Local lAtuAB9 	:= .F.
Local lCab		:= .T.
Local nOpc		:= IIF(MV_PAR08 == 1, 3, 5)
Local aLogErro	:= {}
Local cErro 	:= ""
Local cGsxInt 	:= SuperGetMV("MV_GSXINT",,"2")
Local uValor 	:= 0
Local cFuncLog 	:= ""
Local nRegs		:= 0
Local oGsLog	:= GsLog():new()
Local lMV_GSLOG   := SuperGetMV('MV_GSLOG',,.F.)
Local nProc		:= Randomize( 10, 1000 ) //Gera um numero aleatorio para gerar um arquivo por processamento
Local lSemOs	:= HasABBBene() .AND. SuperGetMv("MV_GSGEROS",,'1') == '2'
Local cComAA1 := FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA := FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local lMultFil := SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local cFilBkp		:= ""
Local lAlteraRH := ExistBlock("AT351Alt")
Local aPEenvBen := {}

Private lGPEA011 := .T.
PRIVATE lMsErroAuto := .F.
PRIVATE lAutoErrNoFile := .T.

Default cTpExp := "1"
Default nHandle :=0
Default lSemTela := .F.
Default aRet := {.T.,{}}
Default nEnviados := 0
Default nProblemas := 0

//obs: aBenefPagar esta ordenado por Filial, Matricula

For nI := 1 to Len(aBenefPagar)
	lAtuAB9 	:= .T.
	
	cUltMat := aBenefPagar[nI][VAL_MAT]
	nPosFunc := AScan(aCabec, {|x| AllTrim(x[2]) == AllTrim(aBenefPagar[nI][VAL_MAT]) } ) 
	
	If nPosFunc == 0 //Inclui o funcionario no aCabec apenas uma vez
		Aadd(aCabec,{"RA_FILIAL" 	, aBenefPagar[nI][VAL_FILIAL], Nil  })		
		aadd(aCabec,{"RA_MAT" 		, aBenefPagar[nI][VAL_MAT], Nil  })
		Aadd(aCabec,{"CPERIODO"		, cCodPer, Nil })
		Aadd(aCabec,{"CROTEIRO"		, cCodRot, Nil })
		Aadd(aCabec,{"CNUMPAGTO"	, cCodPag, Nil })
		
		cFuncLog := STR0024 + aBenefPagar[nI][VAL_MAT] + STR0025 + cCodPer //"Matrícula: "##" Período: "
		
	End
	aItens := {}
	If lMultFil
		Aadd(aItens,{"RGB_FILIAL"	,	xFilial("RGB",aBenefPagar[nI][VAL_FILIAL])	,	Nil })
	Else
		Aadd(aItens,{"RGB_FILIAL"	,	xFilial("RGB")				,	Nil })
	EndIf
	Aadd(aItens,{"RGB_MAT"		,	aBenefPagar[nI][VAL_MAT]		,	Nil })
	Aadd(aItens,{"RGB_PD"  		,	aBenefPagar[nI][VAL_VERBA]	,	Nil })
	Aadd(aItens,{"RGB_TIPO1" 	,	"V"								,	Nil })
	If cGsxInt == "2"
		uValor := At351BenVa( aBenefPagar[nI], cCodPer, cCodRot, cCodPag, @lInclusao)
	Else
		uValor := aBenefPagar[nI][VAL_VALOR]
	EndIf
	Aadd(aItens,{"RGB_VALOR"	,	uValor/*aBenefPagar[nI][VAL_VALOR]*/	,	Nil })
	Aadd(aItens,{"RGB_CC"		,	aBenefPagar[nI][VAL_CCUSTO]	,	Nil })
	Aadd(aItens,{"RGB_SEMANA"	,	cCodPag	,	Nil })
	Aadd(aItens,{"RGB_ITEM"	,	aBenefPagar[nI][VAL_CLVL],	Nil })
	Aadd(aItens,{"RGB_CLVL"	,	aBenefPagar[nI][VAL_ITEM],	Nil })
	If aBenefPagar[nI][VAL_LANCDIARIO] == "S"
		Aadd(aItens,{"RGB_DTREF"	, dDataBase,	Nil })
	EndIf	
	Aadd(aItensFinal, aItens)
	nRegs++
	//roda o ExecAuto para cada funcionario diferente. Agrupa os dados nos arrays aCabec e aItensFinal e processa cada funcionario
	//executa esse processo quando for o ultimo registro de um determinado funcionario (olha o próximo -> nI+1)
	If (nI == Len(aBenefPagar)) .OR. (!Empty(cUltMat) .AND. (cUltMat <> aBenefPagar[nI+1][VAL_MAT]))
		lMsErroAuto := .F.
		
		If "1" $ cTpExp .AND. cGsxInt == "2"
			If lMV_GSLOG
				oGsLog:addLog(cFuncLog, STR0035 + cValtoChar(nI) + STR0036 + cValToChar(Len(aBenefPagar)) + CRLF) //"Processando registro " ## " de "
				For nX := 1 To Len(aCabec)
					oGsLog:addLog(cFuncLog, aCabec[nX][1]+": "+aCabec[nX][2])
				Next nX
				oGsLog:addLog(cFuncLog, " --- ")
				oGsLog:addLog(cFuncLog, STR0037) //"Itens: "
				For nX := 1 To Len(aItensFinal)
					For nY := 1 To LEN(aItensFinal[nX])
						oGsLog:addLog(cFuncLog, aItensFinal[nX][nY][1] +": " + AllToChar(aItensFinal[nX][nY][2]) )
					Next nY
					oGsLog:addLog(cFuncLog, " - ")
				Next nX
			EndIf
			IF lMultFil
				cFilBkp := cFilAnt
				cFilAnt := aBenefPagar[nI][VAL_FILIAL]
			EndIf

			If lAlteraRH
				aPEenvBen := ACLONE(EXECBLOCK("AT351Alt", .F., .F.,{ aCabec, aItensFinal, nOpc}  ))
				aCabec := aPEenvBen[1]
				aItensFinal := aPEenvBen[2]
			EndIf	

			If !(FindFunction("AtTst351")) .OR. !(AtTst351())
				MsExecAuto({|w,x,y,z| GPEA580(w,x,y,z)} , nil ,aCabec,aItensFinal,IIF(lInclusao,3,4) ) // 3 - Inclusão, 4 - Alteração, 5 - Exclusão
			EndIf

			IF lMultFil
				cFilAnt := cFilBkp
			EndIf
			If lMV_GSLOG
				oGsLog:addLog(cFuncLog, STR0038 + aBenefPagar[nI][VAL_MAT] + CRLF) //"Processamento finalizado para a matrícula: "
			EndIf
			If lMsErroAuto
				aLogErro := GetAutoGRLog()
			EndIf	
			If lMsErroAuto .AND. Len(aLogErro) > 0
				lMsErroAuto := .F.
				lErro := .T.
				cErro := ""
				AEval( aLogErro, { |a| cErro += ( a + CRLF ) } )
				cRet := STR0008 + aBenefPagar[nI][VAL_MAT] + STR0007 + aBenefPagar[nI][VAL_VERBA] + CRLF + cErro //" - Verba: "//"Matrícula: "#log Erro CRLF "#"
				oGsLog:addLog(cFuncLog, cRet )
				If !lMV_GSLOG
					oGsLog:printLog(cFuncLog,STR0039 + " - " + cFilAnt + " - BenefErro"+ " - " + AllTrim(DToS(Date())) + " - " + cValToChar(nProc) ) //Filial
				EndIf
				lAtuAB9 	:= .F.
			EndIf
			If lMV_GSLOG
				oGsLog:printLog(cFuncLog,STR0039 + " - " + cFilAnt + " - BenefErro"+ " - " + AllTrim(DToS(Date())) + " - " + cValToChar(nProc) ) //Filial
			EndIf
		EndIf
		
		If "2" $ cTpExp
			lAtuAB9 := ExecBlock("At351IBe", .f., .f., {aCabec, aItensFinal, nOpc, lCab}) .AND. lAtuAB9
		EndIf
		
		If "3" $ cTpExp 
			lAtuAB9 := At351MCSV(aCabec, aItensFinal, nHandle, lCab) .and. lAtuAB9
		EndIf
		
		If  "1" $ cTpExp .AND. cGsxInt <> "2"
			//Envia o benefício para o RM
			lAtuAB9 := At351ItWS(aCabec, aItensFinal, cGsxInt, @cErro, .T.) .and. lAtuAB9
			If !lAtuAB9
				cRet := cFuncLog + CRLF + cErro
				oGsLog:addLog(cFuncLog, cRet )
				oGsLog:printLog(cFuncLog,"BenefErro"+ " - " + AllTrim(DToS(Date())) + " - " + cValToChar(nProc) )
			EndIf
		EndIf
		
		//limpa arrays para guardar os dados do proximo funcionario
		aCabec 		:= {}
		lInclusao 		:= .T.
		lCab := .F.
		If !lAtuAB9
			lErro := .T.
			nProblemas += nRegs
		Else
			 nEnviados += nRegs
			//Marca os atendimentos de OS processados
			If lSemOs
				DbSelectArea("ABB")
				For nJ := 1 to Len(aBenefPagar[nI][VAL_RECNO])
					DbGoTo(aBenefPagar[nI][VAL_RECNO][nJ])
					If RecLock("ABB", .F.)
						REPLACE ABB_BENENV	WITH .T. 
						ABB->(MsUnlock())
					EndIf 	
				Next
			Else
				DbSelectArea("AB9")
				For nJ := 1 to Len(aBenefPagar[nI][VAL_RECNO])
					DbGoTo(aBenefPagar[nI][VAL_RECNO][nJ])
					If RecLock("AB9", .F.)
						REPLACE AB9_BENENV	WITH .T. 
						AB9->(MsUnlock())
					EndIf 	
				Next
			EndIf
			If LEN(aItensFinal) > 1
				//Os itens foram agrupados para envio mas os RECNOs de ABB/AB9 não
				//Necessário atualizar _BENENV dos registros agrupados
				If lSemOs
					DbSelectArea("ABB")
					For nZ := 1 To LEN(aBenefPagar)
						If aBenefPagar[nZ][VAL_MAT] == aBenefPagar[nI][VAL_MAT] .AND.;
								aBenefPagar[nZ][VAL_FILIAL] == aBenefPagar[nI][VAL_FILIAL]
							For nA := 1 To LEN(aBenefPagar[nZ][VAL_RECNO])
								DbGoTo(aBenefPagar[nZ][VAL_RECNO][nA])
								If RecLock("ABB", .F.)
									REPLACE ABB_BENENV	WITH .T. 
									ABB->(MsUnlock())
								EndIf 	
							Next nA
						EndIf
					Next nZ
				Else
					DbSelectArea("AB9")
					For nZ := 1 To LEN(aBenefPagar)
						If aBenefPagar[nZ][VAL_MAT] == aBenefPagar[nI][VAL_MAT] .AND.;
								aBenefPagar[nZ][VAL_FILIAL] == aBenefPagar[nI][VAL_FILIAL]
							For nA := 1 To LEN(aBenefPagar[nZ][VAL_RECNO])
								DbGoTo(aBenefPagar[nZ][VAL_RECNO][nA])
								If RecLock("AB9", .F.)
									REPLACE AB9_BENENV	WITH .T. 
									AB9->(MsUnlock())
								EndIf 	
							Next nA
						EndIf
					Next nZ
				EndIf
			EndIf
		EndIf
		aItensFinal	:= {}
		nRegs := 0

	EndIf

Next 

If lErro
	cRet := STR0039 + " - " + cFilAnt + "BenefErro"+ " - " + AllTrim(DToS(Date())) + " - " + cValToChar(nProc) //Filial
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At351Log()

Exibe mensagem na finalização do envio

@param cTexto , caractere, mensagem de erro recebida

@todo implementar um controle de logs para facilitar identificação de problemas nos cadastros
    
@author Vendas CRM
@since 20/02/2013
/*/
//-------------------------------------------------------------------- 
Function At351Log(cTexto, lSemTela, aRet,  nTotalReg,  nRegEnv, nRegProb, cTexMsg)
//Local cMsg 		:= ''
Local cTitulo 	:= ''
Local lSucesso	:= .T.

Default lSemTela	:= .F.
Default aRet		:= {.T., {}}
Default nTotalReg 	:= 0
Default nRegEnv 	:= 0
Default nRegProb 	:= 0

If Empty(cTexto)
	//Registros enviados para o RH com sucesso
	
	cTexMsg += STR0010+CRLF//"Registros enviados para o RH com sucesso!"
	
	cTexMsg := STR0010+CRLF+Chr(13)+Chr(10)//"Registros enviados para o RH com sucesso!"
	cTexMsg += STR0026+Alltrim(cValTochar(nTotalReg))+STR0027+Alltrim(cValTochar(nRegEnv))+STR0028+Alltrim(cValTochar(nRegProb))+CRLF+cTexMsg+CRLF+Chr(13)+Chr(10) //"Total Registros a Enviar: "##" Enviados: "##" Problemas: "
	cTitulo := STR0039+" - "+cFilAnt+" / "+STR0011 //"Filial" ## "Processamento concluído"

Else
	lSucesso := .F.
	//Ocorreram erros no processamento .....
	cTexMsg += STR0033+TxLogPath("BenefErro") // "Foi gerado o log no arquivo "
	cTexMsg += cTexMsg+CRLF
	cTexMsg += STR0039+" - "+cFilAnt+" / "+STR0013 //"Filial" ## "Ocorreram erros"
EndIf

If !lSemTela
	cTexMsg += cTitulo+","+CRLF		
Else
	If lSucesso 
		aRet[1] := .T.
		AADD(aRet[2], cTexMsg+CRLF)
	Else
		aRet[1] := .F.
		AADD(aRet[2], cTitulo+CRLF+cTexMsg+CRLF)
	EndIf
EndIf

Return

/*/{Protheus.doc} At351BenVa
@author Vendas CRM
@since 19/09/2014
@version 1.0
@param aBenefPagar, array
@param cCodPer, character
@param cCodRot, character
@param cCodPag, character
@param lInclusao
@return Valor
/*/
Static Function At351BenVa(aBenefPagar,cCodPer,cCodRot,cCodPag,lInclusao)
Local nValor  		:= aBenefPagar[VAL_VALOR]
Local cFilAux 		:= aBenefPagar[VAL_FILIAL] 
Local cMatricula	:= aBenefPagar[VAL_MAT]
Local cVerba		:= aBenefPagar[VAL_VERBA]
Local cProcesso		:= aBenefPagar[VAL_PROCESSO]
Local cQry 			:= GetNextAlias()

BeginSQL Alias cQry
	SELECT 1 REC
	FROM %Table:RGB% RGB
	WHERE RGB.RGB_FILIAL = %Exp:cFilAux%
		AND RGB.%NotDel%
		AND RGB.RGB_PROCES = %Exp:cProcesso%
		AND RGB.RGB_PERIOD = %Exp:cCodPer%
		AND RGB.RGB_ROTEIR = %Exp:cCodRot%
		AND RGB.RGB_MAT = %Exp:cMatricula%
EndSQL

lInclusao := (cQry)->(EOF())
(cQry)->(DbCloseArea())

dBSelectArea("RGB")
dbSetorder(8) // RGB_FILIAL + RGB_PD + RGB_PROCES + RGB_PERIOD + RGB_ROTEIR + RGB_MAT
If dbSeek(cFilAux+cVerba+cProcesso+cCodPer+cCodRot+cMatricula)
	nValor += RGB->RGB_VALOR
EndIf

Return nValor

/*/{Protheus.doc} At351Excl
@description 	Realiza a exclusão dos lançamentos dos atendentes que tiveram agenda nos contratos dentro do período informado.
@author 		josimar.assuncao
@since 			01.06.2017
@version 		12
/*/
Function At351Excl(cTpExp, lSemTela, aRet, aContracts, cTexMsg)
Local cTmpAgAB9 	:= ""
Local aAgentes 		:= {}
Local lRet 			:= .T.
Local nI 			:= 0
Local cCodPer 		:= MV_PAR05
Local cCodPag 		:= MV_PAR06
Local cCodRot 		:= IF(Empty(MV_PAR07), "FOL", MV_PAR07)
Local cRet 			:= ""
Local nPosAtd 		:= 0
Local nPosVerba 	:= 0
Local nC 			:= 0
Local lRetProc		:= .T.
Local nTotalReg		:= 0
Local nRegProb		:= 0
Local nRegEnv		:= 0
Local lSemOs		:= HasABBBene() .AND. SuperGetMv("MV_GSGEROS",,'1') == '2'
Local lContabil		:= TecEntCtb("ABS")

Default lSemTela	:= .F.
Default aRet		:= {.T.,{}}
Default aContracts	:= {}

Default cTpExp := "1"

cTmpAgAB9 := At351Qry(.F. /*lEnvia*/,aContracts )

If (cTmpAgAB9)->( EOF() )
	If !lSemTela
		
		cTexMsg += STR0039+" - "+cFilAnt+" / "+STR0006+", "+STR0017+CRLF //"Filial" ## "Benefícios do Contrato" ### "Não há benefícios para excluir."
	Else
		aRet[1]	:= .F.
		AADD(aRet[2], STR0006)
	EndIf
Else

	DbSelectArea("AB9")
	AB9->( DbSetorder( 1 ) )  // AB9_FILIAL + AB9_NUMOS + AB9_CODTEC + AB9_SEQ

	While (cTmpAgAB9)->( !EOF() )
		
		// Guarda os atendentes que terão as informações excluídas
		If ( nPosAtd := ( aScan( aAgentes, {|x| x[1] == (cTmpAgAB9)->RA_FILIAL .And. x[2] == (cTmpAgAB9)->RA_MAT } ) ) ) == 0
			aAdd( aAgentes, { 	(cTmpAgAB9)->RA_FILIAL,;
			 					(cTmpAgAB9)->RA_MAT, ;
								{ { If( Empty((cTmpAgAB9)->ABS_CCUSTO), (cTmpAgAB9)->ABS_CCUSTO, (cTmpAgAB9)->RA_CC ), ;
										(cTmpAgAB9)->RV_COD, ;
										(cTmpAgAB9)->RV_TIPO } },;
										{}} )
			nPosAtd := Len(aAgentes)
			nTotalReg++			
		Else
			If ( nPosVerba := ( aScan( aAgentes[nPosAtd,3], {|x| x[2]==(cTmpAgAB9)->RV_COD } ) ) ) == 0
				aAdd( aAgentes[nPosAtd,3], { If( Empty((cTmpAgAB9)->ABS_CCUSTO), (cTmpAgAB9)->ABS_CCUSTO, (cTmpAgAB9)->RA_CC), ;
												(cTmpAgAB9)->RV_COD, ;
												(cTmpAgAB9)->RV_TIPO,;
										 		If(lContabil, (cTmpAgAB9)->ABS_ITEM, ""),;
										 		If(lContabil, (cTmpAgAB9)->ABS_CLVL, "") } )
				nTotalReg++
			EndIf
		EndIf
		
		aAdd(aAgentes[nPosAtd, 4], (cTmpAgAB9)->RECNO)
		
		
		(cTmpAgAB9)->( DbSkip() )
	End

	// Remove os lançamentos dos atendentes
	For nI := 1 To Len( aAgentes )
		lRetProc := At351ExcRh( aAgentes[nI,1], aAgentes[nI,2], cCodPer, cCodRot, cCodPag, aAgentes[nI,3], @cRet,cTpExp, lSemTela, @aRet)
		
		If lRetProc
			If lSemOs
				DbSelectArea("ABB")
				For nC := 1 to Len(aAgentes[nI,4])
				// Posiciona na AB9 e devolve o flag para permitir o reenvio
					ABB->( DbGoTo( aAgentes[nI,4, nC] ) )
					RecLock("ABB", .F.)
						REPLACE ABB_BENENV	WITH .F.
					ABB->(MsUnlock())
				Next nC 
			Else
				DbSelectArea("AB9")
				For nC := 1 to Len(aAgentes[nI,4])
				// Posiciona na AB9 e devolve o flag para permitir o reenvio
					AB9->( DbGoTo( aAgentes[nI,4, nC] ) )
					RecLock("AB9", .F.)
						REPLACE AB9_BENENV	WITH .F.
					AB9->(MsUnlock())
				Next nC 
			EndIf
			nRegEnv += Len(aAgentes[nI,3])
		Else
			nRegProb += Len(aAgentes[nI,3])
			lRet := .F.
		EndIf
	Next nI
	
	If "2" $ cTpExp
		(cTmpAgAB9)->( DbGoTop() )
		lRet :=  ExecBlock("At351EBe", .f., .f., {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, cTmpAgAB9}) .AND. lRet
	EndIf
	 
	 cTexMsg += STR0026+Alltrim(cValTochar(nTotalReg))+STR0027+Alltrim(cValTochar(nRegEnv))+STR0028+Alltrim(cValTochar(nRegProb))+CRLF //"Total Registros a Enviar: "##" Enviados: "##" Problemas "
	If lRet
		If !lSemTela			
			cTexMsg += STR0018+CRLF+STR0039+" - "+cFilAnt+" / "+STR0019+CRLF  // "Processamento finalizado com sucesso." ### "Exclusão" /
		Else
			aRet[1]	:= .T.
			AADD(aRet[2],(STR0018+" / "+STR0039+" - " +cFilAnt+STR0019+""+cTexMsg))//+CRFL))
			
		EndIf
	Else
		If !lSemTela
			cTexMsg += STR0039+" - "+cFilAnt+" / "+cRet+", "+STR0020+CRLF+cTexMsg+CRLF  // "Erro no processamento"
		Else
			aRet[1] := .F.
			AADD(aRet[2], STR0020+""+cTexMsg+CRLF)			
		EndIf
	EndIf
EndIf

(cTmpAgAB9)->( DbCloseArea())

Return

/*/{Protheus.doc} At351ExcRh
@description 	Chama a execauto para exclusão dos lançamentos no RH.
@author 		josimar.assuncao
@since 			01.06.2017
@version 		12
@return 		Lógico, indica se a exclusão dos lançamentos aconteceu com sucesso.
@param 			cFilMat, Caracter, código da filial da matrícula a ter o conteúdo excluído.
@param 			cAtdMat, Caracter, matrícula do atendente para exclusão do conteúdo.
@param 			cCodPer, Caracter, código do período para a exclusão dos dados.
@param 			cCodRot, Caracter, código do roteiro para a exclusão dos dados.
@param 			cCodPag, Caracter, sequência de pagamento para a exclusão dos dados.
/*/
Static Function At351ExcRh( cFilMat, cAtdMat, cCodPer, cCodRot, cCodPag, aInfoVerba, cRet, cTpExp, nHandle, lCab, lSemTela, aRet )
Local lRet 			:= .T.
Local aCabec 		:= {}
Local aItens 		:= {}
Local aItensFinal 	:= {}
Local cFilRGB 		:= xFilial("RGB", cFilMat)
Local cErro			:= ""
Local cCRLF			:= "##"
Local cGsxInt 		:= SuperGetMV("MV_GSXINT",,"2")
Local nC 			:= 0
Local nModo			:= 1
Local cComAA1		:= FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA		:= FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local lMultFil		:= SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local cFilBkp		:= ""
Local lAlteraRH     := ExistBlock("AT351Alt")
Local aPEenvBen     := {}

Default lSemTela	:= .F.
Default aRet		:= {.T.,{}}

Private lGPEA011 	:= .T.
Private lMsErroAuto 	:= .F.

cRet := ""

DbSelectArea("SRA")
SRA->( DbSetorder( 1 ) )  // RA_FILIAL + RA_MAT

DbSelectArea("RGB")
RGB->( DbSetorder( 6 ) )  // RGB_FILIAL + RGB_MAT + RGB_PERIOD + RGB_ROTEIR + RGB_SEMANA + RGB_PD

If  "1" $ cTpExp 
	If ( ("1" $ cTpExp  .and. cGsxInt == "2"  )  .AND. ;
	     ( SRA->(DbSeek( cFilMat + cAtdMat ) )  .And. ;
		   RGB->(DbSeek( cFilRGB + cAtdMat + cCodPer + cCodRot + cCodPag)) ) )  .or. cGsxInt <> "2" 
	
		Aadd(aCabec,{"RA_FILIAL", 	cFilMat, 	Nil })		
		Aadd(aCabec,{"RA_MAT", 		cAtdMat, 	Nil })
		Aadd(aCabec,{"CPERIODO", 	cCodPer, 	Nil })
		Aadd(aCabec,{"CROTEIRO", 	cCodRot, 	Nil })
		Aadd(aCabec,{"CNUMPAGTO", 	cCodPag, 	Nil })
		


		If "1" $ cTpExp .AND. cGsxInt == "2"
			While (RGB->( !EOF() ) .And. RGB->RGB_FILIAL == cFilRGB .And. RGB->RGB_MAT == cAtdMat .And. ;
				RGB->RGB_PERIOD == cCodPer .And. RGB->RGB_ROTEIR == cCodRot .And. RGB->RGB_SEMANA == cCodPag) 
				
				If ASCAN(aInfoVerba, {|a| a[2] == RGB->RGB_PD}) > 0
					aItens := {} 
					Aadd(aItens,{"RGB_FILIAL", 	cFilRGB, 			Nil })
					Aadd(aItens,{"RGB_MAT", 	cAtdMat, 			Nil })
					Aadd(aItens,{"RGB_PERIOD", 	cCodPer, 			Nil })
					Aadd(aItens,{"RGB_ROTEIR", 	cCodRot, 			Nil })
					Aadd(aItens,{"RGB_SEMANA", 	cCodPag, 			Nil })
					Aadd(aItens,{"RGB_CC", 		RGB->RGB_CC, 		Nil })
					Aadd(aItens,{"RGB_PD", 		RGB->RGB_PD, 		Nil })
					Aadd(aItens,{"RGB_TIPO1", 	RGB->RGB_TIPO1, 	Nil })
					Aadd(aItens,{"RGB_VALOR", 	RGB->RGB_VALOR, 	Nil })
					Aadd(aItens,{"RGB_CLVL", 	RGB->RGB_CLVL,	 	Nil })
					Aadd(aItens,{"RGB_ITEM", 	RGB->RGB_ITEM, 		Nil })
					If !Empty(RGB->RGB_DTREF)
						Aadd(aItens,{"RGB_DTREF", 	RGB->RGB_DTREF, 		Nil })
					EndIf
					Aadd(aItensFinal, aItens)
				Else
					nModo := 2
				EndIf
				RGB->( DbSkip() )
				// Copia para o formato de linhas correto
			End
		ElseIf cGsxInt <> "2" 	
		
			Do While (nC := nC + 1) <= Len(aInfoVerba)
				aItens := {} 
				Aadd(aItens,{"RGB_FILIAL", 	cFilRGB, 			Nil })
				Aadd(aItens,{"RGB_MAT", 	cAtdMat, 			Nil })
				Aadd(aItens,{"RGB_PERIOD", 	cCodPer, 			Nil })
				Aadd(aItens,{"RGB_ROTEIR", 	cCodRot, 			Nil })
				Aadd(aItens,{"RGB_SEMANA", 	cCodPag, 			Nil })
				Aadd(aItens,{"RGB_CC", 		aInfoVerba[nC, 01], 		Nil })
				Aadd(aItens,{"RGB_PD", 		aInfoVerba[nC, 02], 		Nil })
				Aadd(aItens,{"RGB_TIPO1", 	aInfoVerba[nC, 03], 	Nil })	
				Aadd(aItens,{"RGB_CLVL", 	aInfoVerba[nC, 04],	 	Nil })
				Aadd(aItens,{"RGB_ITEM", 	aInfoVerba[nC, 05], 		Nil })
				
				// Copia para o formato de linhas correto
				Aadd(aItensFinal, aItens)
			EndDo
		
		EndIf

		If "1" $ cTpExp .AND. cGsxInt == "2" 
			// Processa a exclusão no RH
			IF lMultFil
				cFilBkp := cFilAnt
				cFilAnt := cFilMat
			EndIf

			If lAlteraRH
				aPEenvBen := ACLONE(EXECBLOCK("AT351Alt", .F., .F.,{ aCabec, aItensFinal, 5 }  ))
				aCabec := aPEenvBen[1]
				aItensFinal := aPEenvBen[2]
			EndIf	
			If nModo != 2 .OR. !EMPTY(aItensFinal)
				If !(FindFunction("AtTst351")) .OR. !(AtTst351())
					MsExecAuto({|w,x,y,z,t| GPEA580(w,x,y,z,t)} , nil ,aCabec, aItensFinal, 5, nModo ) // 3 - Inclusão, 4 - Alteração, 5 - Exclusão
				EndIf	
			EndIf
			IF lMultFil
				cFilAnt := cFilBkp
			EndIf
			If lMsErroAuto
				lMsErroAuto := .F.
				lRet := .F.
				cRet += STR0008 + cFilMat + "/" + cAtdMat + CRLF  // "Matrícula: "
				If !lSemTela
					cRet += CRLF + CRLF + MostraErro(STR0009)//"beneficio"
				Else
					aRet[1] := .T.
					aEval(GetAutoGRLog(),{|x| cErro +=  x + cCRLF })
					AADD(aRet[2], cErro)
					aRet[1]	:= .F.
					AADD(aRet[2], (STR0009+": "+cRet))
				EndIf
			EndIf
		ElseIf  cGsxInt <> "2" 
			lRet := At351ItWS(aCabec, aItensFinal, cGsxInt, @cErro, .F.) 
			If !lRet
				cRet += CRLF + STR0008 + cFilMat + "/" + cAtdMat + CRLF  // "Matrícula: "
				If !lSemTela
					cRet += CRLF + CRLF + cErro //"beneficio"
				Else
					aRet[1] := .T.
					AADD(aRet[2], cErro)
					aRet[1]	:= .F.
					AADD(aRet[2], (STR0009+": "+cRet))
				EndIf
			EndIf

		EndIf
		
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At351MCSV
@description Grava o Arquivo CSV dos Benefícios
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param aCabec: Array Contendo a filial e matricula do atendente
@param aItens:Array de Marcaçoes do atendende do Atendimento que será atualizado
@param nHandle:Handle do Arquivo
@param lCab:Gera o cabeçalho da marcação
@return lRet - .T. - Sucesso /.F. Erro
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At351MCSV(aCabec, aItens, nHandle, lCab)
Local lRet 		:= .T.
Local cCab 		:= ""
Local cDetCab 	:= ""
Local cLinha 	:= ""
Local cDetLinha := ""
Local nY 		:= 0
Local nC 		:= 0

For nC := 1 to len(aCabec)
	cCab += AllTrim(aCabec[nC, 01]) +";"
	cDetCab += Alltrim(IIF( ValType(aCabec[nC, 02])<> "D",cValToChar(aCabec[nC, 02])  , DtoS(aCabec[nC, 02])))+";"
Next nC 

For nC := 1 to Len(aItens)

	cLinha := cCab
	cDetLinha := cDetCab 
	For nY := 1 to Len(aItens[nC])
		cLinha += AllTrim(aItens[nC, nY, 01])+";"
		cDetLinha +=  Alltrim(IIF( ValType(aItens[nC, nY, 02])<> "D",cValToChar(aItens[nC, nY, 02])  , DtoS(aItens[nC, nY, 02])))+";"	
	Next nY
	If lCab	
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF		
		fWrite(nHandle, cLinha)
		lCab := .f.
	EndIf
	
	cDetLinha := Substr(cDetLinha, 1, Len(cDetLinha)-1) + CRLF
	fWrite(nHandle, cDetLinha)
Next nC

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At351RHD
@description  Retorna o Diretório de Exportação do Arquivo CSV da Integração RH
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@return cDirArq - Diretório do server a ser gerado o arquivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At351RHD()
Local cDirArq := SuperGetMV("MV_GSRHDIR", .F., "")

If !Empty(cDirArq) .AND. Right(cDirArq, 1) <> "\"
	cDirArq += "\"
EndIf

If !Empty(cDirArq) .AND. Left(cDirArq, 1) <> "\"
	cDirArq := "\" +cDirArq
EndIf

Return cDirArq

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At351MCSV
@description Gera o Arquivo CSV  dos Benefícios
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param cRotina: Prefixo da rotina/aquivo
@param cDirArq:Diretóirio de gravação do arquivo
@param lDelete: Exclui arquivo caso ele exista?
@param nOpc: Opção da Rotina Automática 
@return nHandle - Handle do Arquivo Gerado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At351RHF(cRotina, cDirArq, lDelete, nOpc)
Local nHandle := 0
Local aDir := {}
Local nC := 0
Local cDirTmp := ""

If !ExistDir(cDirArq)
	aDir := StrTokArr(cDirArq, "\")
	For nC := 1 to Len(aDir)
		cDirTmp += "\" +aDir[nC] +"\"
		MakeDir(cDirTmp)
	Next nC 
EndIf
	
cNomeArq := cDirArq+cRotina+"_"+LTrim(Str(nOpc))+"_"+Dtos(Date())+"_"+StrTran(Time(), ":")+".csv" 

If File(cNomeArq)
	If lDelete
		fErase(cNomeArq)
	Else
		nHandle := FOpen(cNomeArq, FO_READWRITE)
		FSeek(nHandle, 0, 2)
	EndIf
EndIf
If nHandle = 0
	nHandle := fCreate(cNomeArq)
EndIf

Return nHandle


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At351ItWS
@description Envia as Verbas para o sistema externo
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param aCabec: Cabeçalho dos dados -
@param aItensFinal: Detalhe dos dados
@param cGsxInt: Parametro de Integracao
@param cMsg: Mensagem de Retorno 
@param lEnvia: Envia ou deleta o registro
@return lRet - Dados integrados com sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At351ItWS(aCabec, aItensFinal, cGsxInt, cMsg, lEnvia  )
Local lRet 		:= .T.
Local lSucesso 	:= .T.
Local cError 	:= ""
Local cWarning 	:= ""
Local cCodFilRM	:= ""
Local cCodEmpRM := ""
Local cXML 		:= ""
Local cLinha	:= ""
Local cPk 		:= ""
Local uRet 		:= NIL
Local oXML2 	:= NIL
Local oNode 	:= NIL
Local oXML 		:= NIL
Local nValor 	:= 0
Local nZ 		:= 0
Local nY 		:= 0
Local nC 		:= 0
Local nPosPer 	:= 0
Local nPosMat 	:= 0
Local nPosNumPgto := 0
Local nPosEve	:= 0
Local aPKs 		:= {}
Local cMarca 	:= IIF(cGsxInt == "3", "RM", "")
Local cPicValor := GetSx3Cache("RGB_VALOR", "X3_PICTURE")
Local lTECA351B := TecHasPerg("MV_PAR01","TECA351B")
Local cPergunta := IIF(lTECA351B,"TECA351B","TECA351A")
Local lCons 	:= lEnvia .AND. (!TecHasPerg("MV_PAR09",cPergunta) .OR. MV_PAR09 <> 1)
Local cMetodo   := IIF(lEnvia, " SaveRecord ", " DeleteRecordByKey")

If cMarca == "RM"
	oWS :=  GSItRMWS(cMarca, .F., @cMsg, @cCodFilRM, @cCodEmpRM)
	
	If oWS <> NIL

		//Gera o Objeto XML
		oWS:cFiltro := "1=1"
		oWS:cDataServerName := "FopLancExternoData"
		oXml := XmlParser( "<FopLancExterno></FopLancExterno>", "_", @cError, @cWarning )
		If Empty(cError)
		// Criando um node
			
			For nC := 1 to Len(aItensFinal)
				
				If lEnvia
					cLinha := "oXML:_FopLancExterno:PFMOVTEMP"+AllTrim(Str(nC))
											
					XmlNewNode(oXml:_FopLancExterno, "PFMOVTEMP"+AllTrim(Str(nC)), "PFMOVTEMP", "NOD" )
					&(cLinha+":RealName") := "PFMOVTEMP"	
					XmlNewNode(&(cLinha), "CODCOLIGADA", "CODCOLIGADA", "NOD" )
					&(cLinha+":CODCOLIGADA:Text") := cCodEmpRM	
									
					For nY := 1 to Len(aCabec)
						Do Case
						Case aCabec[nY, 01] == "RA_MAT"
							XmlNewNode(&(cLinha), "CHAPA", "CHAPA", "NOD" )
							&(cLinha+":CHAPA:Text") := RTrim(aCabec[nY, 02])
						
						Case aCabec[nY, 01] == "CPERIODO"
							XmlNewNode(&(cLinha), "ANOCOMP", "ANOCOMP", "NOD" )
							&(cLinha+":ANOCOMP:Text") := Left(aCabec[nY, 02],4)	
							XmlNewNode(&(cLinha), "MESCOMP", "MESCOMP", "NOD" )
							&(cLinha+":MESCOMP:Text") := AllTrim(cValToChar(Val(Substr(aCabec[nY, 02],5))))		
						Case aCabec[nY, 01] == "CNUMPAGTO"	
							XmlNewNode(&(cLinha), "IDMOVTEMP", "IDMOVTEMP", "NOD" )
							&(cLinha+":IDMOVTEMP:Text") := AllTrim(aCabec[nY, 02])				
						EndCase
					Next nY	
														
					XmlNewNode(&(cLinha), "TIPOLANCAMENTO", "TIPOLANCAMENTO", "NOD" )
					&(cLinha+":TIPOLANCAMENTO:Text") := cValToChar(15) //Sistemas externos
	
					For nZ := 1 to Len(aItensFinal[nC])			
						Do Case
						Case aItensFinal[nC, nZ, 01] == "RGB_PD"
								XmlNewNode(&(cLinha), "CODEVENTO", "CODEVENTO", "NOD" )
								uRet := GSItVeb(, , cMarca, aItensFinal[nC, nZ, 02], .f., @cMsg)
								If !Empty(uRet)
									&(cLinha+":CODEVENTO:Text") := AllTrim(uRet)	
								EndIf		
						Case aItensFinal[nC, nZ, 01] == "RGB_VALOR"
							XmlNewNode(&(cLinha), "VALOR", "VALOR", "NOD" )
							nValor := aItensFinal[nC, nZ, 02]		
						Case aItensFinal[nC, nZ, 01] == "RGB_CC" .AND. !Empty(aItensFinal[nC, nZ, 02])
							XmlNewNode(&(cLinha), "CODCCUSTO", "CODCCUSTO", "NOD" )						
							uRet:= GSItCC(, , cMarca, aItensFinal[nC, nZ, 02], .F., @cMsg)
							&(cLinha+":CODCCUSTO:Text") := AllTrim(uRet)
						EndCase	
	
						If !Empty(cMsg)
							Exit
						EndIf	
					Next nZ	
					
					If !Empty(cMsg)
						Exit
					EndIf
					
					cPk := cCodEmpRM+";"+ &(cLinha+":CHAPA:Text") +";"+&(cLinha+":ANOCOMP:Text")+";"+&(cLinha+":MESCOMP:Text")+";"+&(cLinha+":CODEVENTO:Text") + ";"+&(cLinha+":IDMOVTEMP:Text")
				
					If lCons
					
						oWS:cPrimaryKey := cPK
						If oWS:ReadRecord()
							If !Empty(oWS:cReadRecordResult)
								cXML := oWS:cReadRecordResult
								oXML2 := XmlParser(cXML, "_", @cError, @cWarning)
								If Empty(cError)
									oNode := XmlChildEx ( oXML2:_FopLancExterno, "_PFMOVTEMP" ) 
									If ValType(oNode) == "O"
										oNode := XmlChildEx ( oNode, "_VALOR" ) 
										If ValType(oNode) == "O"
											nValor += Val(oNode:Text)	
											FreeObj(oNode)
										EndIf
									EndIf								
									If oXML2 <> NIL
										FreeObj(oXML2)
									EndIf
								EndIf
		
							EndIf
							oWS:cPrimaryKey := ""
						EndIf
					EndIf	
													
					aAdd(aPKs, cPK)
					&(cLinha+":VALOR:Text") :=  StrTran(AllTrim(Transform(nValor, cPicValor)),".")					
					XmlNewNode(&(cLinha), "HORAFORMATADA", "HORAFORMATADA", "NOD" )
					&(cLinha+":HORAFORMATADA:Text") := '00:00'
					XmlNewNode(&(cLinha), "HORA", "HORA", "NOD" )
					&(cLinha+":HORA:Text") := "0"
					XmlNewNode(&(cLinha), "REF", "REF", "NOD" )
					&(cLinha+":REF:Text") := "0"				


				Else //Delete
					
					nPosPer := aScan(aCabec, {|c| c[1] == "CPERIODO"})
					nPosMat := aScan(aCabec, {|c| c[1] == "RA_MAT"})
					nPosNumPgto := aScan(aCabec, {|c| c[1] == "CNUMPAGTO"})
					nPosEve := aScan(aItensFinal[nC], {|c| c[1] == "RGB_PD"})
					If nPosEve > 0
						uRet := GSItVeb(, , cMarca, aItensFinal[nC,nPosEve, 02], .f., @cMsg)	
					EndIf
					
					If nPosPer > 0 .AND. nPosMat > 0  .AND. nPosNumPgto > 0 .AND. !Empty(uRet) .AND. Empty(cMsg)
										
						cPk := cCodEmpRM+";"+ AllTrim(aCabec[nPosMat, 02]) +";"+Left(AllTrim(aCabec[nPosPer, 02]),4)+";"+AllTrim(cValToChar(Val(Substr(aCabec[nPosPer, 02],5))))+";"+Alltrim(uRet) + ";"+AllTrim(aCabec[nPosNumPgto, 02])										
						oWS:cPrimaryKey := cPK
						If lSucesso := oWs:DeleteRecordByKey()
							cXML := oWs:cDeleteRecordByKeyResult
							lSucesso := RAt("realizado com sucesso", cXML) > 0
						Else
							cMsg := STR0031 + cMetodo + "["+cPk+"]"  //"Problemas ao executar o método 
						EndIf  
						oWS:cPrimaryKey := ""
					
					Else
						cMsg := STR0030 //"Problemas ao configurar chave primária para localizar registro"
					EndIf
				EndIf
			
				If !Empty(cMsg)
					Exit
				EndIf
								
			Next nC 
			
			If Empty(cMsg) .AND. lEnvia
				SAVE oXml XMLSTRING cXML 
				oWS:cXML := cXML
				If lSucesso := oWs:SaveRecord()
					cXML := oWs:cSaveRecordResult
				Else
					cXML := ""
				EndIf
				nC := 0
				Do While lSucesso .AND. (nC := nC + 1 ) <= Len(aPKs)
					lSucesso := aPKs[nC] $ cXML							
				EndDo
				
				If !lSucesso
					cMsg := STR0031 + cMetodo + "["+cXML+"]"//"Problemas ao executar o método "
				EndIf
			EndIf
		Else
			cMsg := STR0032 + cMetodo  //"Erro na montagem do XML base"
		EndIf
		If oXML <> NIL
			FreeObj(oXML)
			oXML := NIL
		EndIf

		lRet := Empty(cMsg)

		If oWS <> NIL
			FreeObj(oWS)		
			oWS := NIL
		EndIf
	EndIf
EndIf

Return lRet
//------------------------------------------------------------------------
/*/{Protheus.doc} HasABBBene
@description  Verifica se o campo ABB_BENENV está ativo

@author mateus.barbosa
@since 09/07/2020
/*/
//------------------------------------------------------------------------
Static Function HasABBBene()

Return (ABB->(ColumnPos("ABB_BENENV")) > 0)
