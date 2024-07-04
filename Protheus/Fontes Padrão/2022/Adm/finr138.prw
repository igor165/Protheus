#include 'totvs.ch'
#include 'finr138.ch'
#INCLUDE "fwcommand.ch"

STATIC aSelFil := {}
STATIC cRngFilSE1 := NIL
STATIC cRngFilSED := NIL
Static __oSE1138  := Nil
Static __oSED138  := Nil

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINR138
T�tulos a receber por natureza

@Author Marcos Berto
@Since 26/12/2012
/*/
//-------------------------------------------------------------------------------------------
Function Finr138()
Local oReport
Private lExistFKD := TableInDic('FKD')

If TRepInUse()
	oReport := ReportDef()
	oReport:SetUseGC(.F.)
	oReport:PrintDialog()
Else
	MsgAlert(STR0011)
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Defini��o da estrutura do relat�rio
	Primeira sess�o - Dados dos t�tulos
	Segunda sess�o - Totalizador pelas sint�ticas

@author    Marcos Berto
@version   11.80
@since     26/12/12

@return oReport - Objeto de Relat�rio

/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

Local nX		 	:= 0
Local nTam			:= 0
Local nPosFim		:= 0

Local oSecTit
Local oSecTot
Local oReport

oReport:= TReport():New("FINR138",STR0002 /*Titulos a Receber por Natureza*/,"FIN138",{|oReport| ReportPrint(oReport)},STR0002)
oReport:SetLandscape(.T.)

dbSelectArea("SE1")

oSecTit := TRSection():New(oReport,STR0002,{'SE1'})/*Titulos a Receber por Natureza*/

TRCell():New(oSecTit,"CLIENTE"	,,RetTitle("E1_CLIENTE")		,PesqPict("SE1","E1_CLIENTE")	,TamSX3("E1_CLIENTE")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"LOJA"		,,RetTitle("E1_LOJA")			,PesqPict("SE1","E1_LOJA")		,TamSX3("E1_LOJA")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"A1_NREDUZ",,STR0010 /*Nome*/				,PesqPict("SA1","A1_NREDUZ")	,TamSX3("A1_NREDUZ")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"PREFIXO"	,,RetTitle("E1_PREFIXO")		,PesqPict("SE1","E1_PREFIXO")	,TamSX3("E1_PREFIXO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"NUMERO"	,,RetTitle("E1_NUM")			,PesqPict("SE1","E1_NUM")		,TamSX3("E1_NUM")[1]		,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"PARCELA"	,,RetTitle("E1_PARCELA")		,PesqPict("SE1","E1_PARCELA")	,TamSX3("E1_PARCELA")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"TIPO"		,,RetTitle("E1_TIPO")			,PesqPict("SE1","E1_TIPO")		,TamSX3("E1_TIPO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"EMISSAO"	,,RetTitle("E1_EMISSAO")		,PesqPict("SE1","E1_EMISSAO")	,TamSX3("E1_EMISSAO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VENCTO"	,,RetTitle("E1_VENCTO")			,PesqPict("SE1","E1_VENCTO")	,TamSX3("E1_VENCTO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VENCREA"	,,RetTitle("E1_VENCREA")		,PesqPict("SE1","E1_VENCREA")	,TamSX3("E1_VENCREA")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"BANCO"	,,RetTitle("E1_PORTADO")		,PesqPict("SE1","E1_PORTADO")	,TamSX3("E1_PORTADO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"NUMBANCO"	,,RetTitle("E1_NUMBCO")			,PesqPict("SE1","E1_NUMBCO")	,TamSX3("E1_NUMBCO")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VALORIG"	,,RetTitle("E1_VALOR")			,PesqPict("SE1","E1_VALOR")		,TamSX3("E1_VALOR")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"SALDO"	,,STR0006 /*Saldo*/				,PesqPict("SE1","E1_VALOR")		,TamSX3("E1_VALOR")[1]+5	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"VALCORR"	,,STR0007 /*Valor Corrigido*/	,PesqPict("SE1","E1_VALOR")		,TamSX3("E1_VALOR")[1]+7	,.F.,,,,,,,.F.)
If lExistFKD 
	TRCell():New(oSecTit,"VALACESS"	,,STR0012					,PesqPict("FKD","FKD_VLCALC")	,TamSX3("FKD_VLCALC")[1],.F.,,,,,,,.F.)
EndIf
TRCell():New(oSecTit,"JUROS"	,,STR0008 /*Juros*/				,PesqPict("SE1","E1_JUROS")		,TamSX3("E1_JUROS")[1]	,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"ATRASO"	,,STR0009 /*Dias de Atraso*/	,/*Picture*/""					,5							,.F.,,,,,,,.F.)
TRCell():New(oSecTit,"E1_HIST"		,,RetTitle("E1_HIST")			,PesqPict("SE1","E1_HIST")		,TamSX3("E1_HIST")[1]	,.F.,,,,,,,.F.)

oSecTit:SetTotalInLine(.F.)
oSecTit:SetHeaderPage(.T.)

oSecTit:Cell("VALORIG"):SetAlign("RIGHT")
oSecTit:Cell("SALDO"):SetAlign("RIGHT")
oSecTit:Cell("VALCORR"):SetAlign("RIGHT")
oSecTit:Cell("JUROS"):SetAlign("RIGHT")

oSecTit:Cell("VALORIG"):SetHeaderAlign("RIGHT")
oSecTit:Cell("SALDO"):SetHeaderAlign("RIGHT")
oSecTit:Cell("VALCORR"):SetHeaderAlign("RIGHT")
oSecTit:Cell("JUROS"):SetHeaderAlign("RIGHT")

oSecTit:Cell("VALORIG"):SetNegative("PARENTHESES")
oSecTit:Cell("SALDO"):SetNegative("PARENTHESES")
oSecTit:Cell("VALCORR"):SetNegative("PARENTHESES")
oSecTit:Cell("JUROS"):SetNegative("PARENTHESES")

oSecTot := TRSection():New(oReport,STR0003 /*Totais*/,,,,,,,,,,,,,,.F.)

//Processa as colunas
nPosFim := aScan(oSecTit:aCell,{|x| x:cName == "NUMBANCO"})

For nX := 1 to nPosFim
	nTam += oSecTit:Cell(oSecTit:aCell[nX]:cName):GetSize()
	nTam += oReport:nColSpace //Adiciona os espa�os entre as colunas
Next nX

TRCell():New(oSecTot,"TITULO"		,,"",,nTam-28,.F.,,,,,,,.F.)
TRCell():New(oSecTot,"VALORIG"		,,"",PesqPict("SE1","E1_VALOR")	,	TamSX3("E1_VALOR")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTot,"SALDO"		,,"",PesqPict("SE1","E1_VALOR")	, 	TamSX3("E1_VALOR")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTot,"VALCORR"		,,"",PesqPict("SE1","E1_VALOR")	,	TamSX3("E1_VALOR")[1],.F.,,,,,,,.F.)
TRCell():New(oSecTot,"JUROS"		,,"",PesqPict("SE1","E1_JUROS")	,	TamSX3("E1_JUROS")[1]+7,.F.,,,,,,,.F.)

oSecTot:SetTotalInLine(.F.)
oSecTot:SetHeaderPage(.F.)

oSecTot:Cell("VALORIG"):SetAlign("RIGHT")
oSecTot:Cell("SALDO"):SetAlign("RIGHT")
oSecTot:Cell("VALCORR"):SetAlign("RIGHT")
oSecTot:Cell("JUROS"):SetAlign("RIGHT")

oSecTot:Cell("VALORIG"):SetHeaderAlign("RIGHT")
oSecTot:Cell("SALDO"):SetHeaderAlign("RIGHT")
oSecTot:Cell("VALCORR"):SetHeaderAlign("RIGHT")
oSecTot:Cell("JUROS"):SetHeaderAlign("RIGHT")

oSecTot:Cell("VALORIG"):SetNegative("PARENTHESES")
oSecTot:Cell("SALDO"):SetNegative("PARENTHESES")
oSecTot:Cell("VALCORR"):SetNegative("PARENTHESES")
oSecTot:Cell("JUROS"):SetNegative("PARENTHESES")

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impress�o do relat�rio

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relat�rio

/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local cNatPai		:= ""
Local cNatureza		:= ""
Local nHandle		:= 0
Local oSecTit		:= oReport:Section(1)
Local oSecTot		:= oReport:Section(2)
Local oBreak
//Gestao
Local nRegSM0		:= SM0->(Recno())
Local aTmpFil		:= {}
Local cTmpSE1Fil	:= ""
Local cTmpSEDFil	:= ""
Local nX			:= 0   


//For�a preenchimento dos parametros mv_parXX
Pergunte("FIN138",.F.)

//Gestao
nRegSM0 := SM0->(Recno())

If MV_PAR36 == 1
	If Empty(aSelFil)
		AdmSelecFil("FIN138",36,.F.,@aSelFil,"SED",.F.)
	Endif
Else
	Aadd(aSelFil,cFilAnt)
Endif

SM0->(DbGoTo(nRegSM0))

cRngFilSE1 := GetRngFil( aSelFil, "SE1", .T., @cTmpSE1Fil )
aAdd(aTmpFil, cTmpSE1Fil)
cRngFilSED := GetRngFil( aSelFil, "SED", .T., @cTmpSEDFil )
aAdd(aTmpFil, cTmpSEDFil)

IF Empty(MV_PAR34) 
	MV_PAR34 := dDataBase
Endif


//Alimenta o arquivo tempor�rio
F138GerTrb()

//Totaliza por natureza
F138TotNat()


oSecTit:Cell("CLIENTE"):SetBlock({|| SE1138->E1_CLIENTE })
oSecTit:Cell("LOJA"):SetBlock({|| SE1138->E1_LOJA })
oSecTit:Cell("A1_NREDUZ"):SetBlock({|| SE1138->E1_NREDUZ })
oSecTit:Cell("PREFIXO"):SetBlock({|| SE1138->E1_PREFIXO })
oSecTit:Cell("NUMERO"):SetBlock({|| SE1138->E1_NUM })
oSecTit:Cell("PARCELA"):SetBlock({|| SE1138->E1_PARCELA })
oSecTit:Cell("TIPO"):SetBlock({|| SE1138->E1_TIPO })
oSecTit:Cell("EMISSAO"):SetBlock({|| SE1138->E1_EMISSAO })
oSecTit:Cell("VENCTO"):SetBlock({|| SE1138->E1_VENCTO })
oSecTit:Cell("VENCREA"):SetBlock({|| SE1138->E1_VENCREA })
oSecTit:Cell("BANCO"):SetBlock({|| SE1138->E1_PORTADO })
oSecTit:Cell("NUMBANCO"):SetBlock({|| SE1138->E1_NUMBCO })
oSecTit:Cell("VALORIG"):SetBlock({|| SE1138->E1_VALOR })
oSecTit:Cell("SALDO"):SetBlock({|| SE1138->E1_SALDO })
oSecTit:Cell("VALCORR"):SetBlock({|| SE1138->E1_VALCORR })
If lExistFKD 
	oSecTit:Cell("VALACESS"):SetBlock({|| IIf(ExistFunc('FValAcess'),FValAcess(SE1138->E1_PREFIXO,SE1138->E1_NUM,SE1138->E1_PARCELA,SE1138->E1_TIPO,SE1138->E1_CLIENTE,;
											SE1138->E1_LOJA,SE1138->E1_NATUREZ, Iif(Empty(SE1138->E1_BAIXA),.F.,.T.),"","R",SE1138->E1_BAIXA),0)})
EndIf
oSecTit:Cell("JUROS"):SetBlock({|| SE1138->E1_JUROS })
oSecTit:Cell("ATRASO"):SetBlock({|| SE1138->E1_ATRASO })
oSecTit:Cell("E1_HIST"):SetBlock({|| SE1138->E1_HIST })

//Configura as quebras baseadas na tabela tempor�ria
oBreak := TRBreak():New(oSecTit,{|| SE1138->E1_NATUREZ+SE1138->E1_NATPAI },{|| STR0004+MascNat(cNatureza)}) /*TOTAL DA NATUREZA ANAL�TICA*/
TRFunction():New(oSecTit:Cell("VALORIG"),"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("SALDO"),"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("VALCORR"),"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSecTit:Cell("JUROS"),"","SUM",oBreak,,,,.F.,.F.)
If lExistFKD 
	TRFunction():New(oSecTit:Cell("VALACESS"),"","SUM",oBreak,,,,.F.,.F.)
EndIf

oSecTot:Cell("VALORIG"):SetBlock({||SED138->VALORIG})
oSecTot:Cell("SALDO"):SetBlock({||SED138->SALDO})
oSecTot:Cell("VALCORR"):SetBlock({||SED138->VALCORR})
oSecTot:Cell("JUROS"):SetBlock({||SED138->JUROS})

//Impress�o dos dados
dbSelectArea("SE1138")
SE1138->(dbSetOrder(1))
SE1138->(dbGoTop())

While !SE1138->(Eof())
	
	cNatPai := SE1138->E1_NATPAI
	
	If Empty(cNatPai)
		SE1138->(dbSkip())
		Loop
	EndIf
	
	oSecTit:Init()
	While SE1138->E1_NATPAI == cNatPai
		If SE1138->E1_SALDO <> 0
			SE1->(DBGOTO(SE1138->SE1RECNO))	
			oSecTit:PrintLine()
			oReport:IncMeter()
		EndIf
		
		cNatureza := SE1138->E1_NATUREZ		
		SE1138->(dbSkip())
						
	EndDo
	oSecTit:Finish()
	
	dbSelectArea("SED138")
	SED138->(dbGoTop())
		
	While cNatPai <> ""
		If SED138->(dbSeek(cNatPai))
		
			//S� imprime o totalizador da sint�tica no �ltimo n�vel
			If 	SED138->NIVEL == 1		
				oSecTot:Init()
				oSecTot:Cell("TITULO"):SetTitle(STR0005+MascNat(SED138->NATUREZA)) /*TOTAL DA NATUREZA SINT�TICA*/
				oSecTot:PrintLine()	
				oSecTot:Finish()		
				
				oReport:IncMeter()
			Else
				Reclock("SED138",.F.)
				SED138->NIVEL -= 1
				SED138->(MsUnlock())
			EndIf
			
			//Controle de atualiza��o das superiores imediatas
			cNatPai := SED138->NATPAI
		Else
			cNatPai := ""	
		EndIf	
		
		SED138->(dbSkip())	
	EndDo						
EndDo

If(__oSE1138 <> NIL)
	__oSE1138:Delete()
	__oSE1138 := NIL
EndIf

If(__oSED138 <> NIL)
	__oSED138:Delete()
	__oSED138 := NIL
EndIf

//Gestao
For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])   
Next
FwFreeArray(aTmpFil)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F138GerTrb

Gera o arquivo tempor�rio

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relat�rio

/*/
//------------------------------------------------------------------------------------------
Function F138GerTrb()

Local aStruct		:= {}
Local aSaldo		:= {}
Local cCampo		:= ""
Local cTipoIn		:= ""
Local cTipoOut		:= ""
Local cQuery		:= ""
Local cCposQry		:= ""
Local cAliasQry 	:= GetNextAlias()
Local dDtReaj		:= dDataBase
Local lCreate		:= .F.
Local nX			:= 0
Local nI			:= 0
Local nDecs  		:= 0
Local nTaxa			:= 0
Local nFator		:= 1
Local nJuros		:= 0
Local nValOrig		:= 0
Local nValSaldo		:= 0
Local nValCorr		:= 0
Local nTotAbat		:= 0
Local nDiaAtrs		:= 0
Local nHandle		:= 0    
//Gestao
Local cTipoNotIn	:= ""
Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontadas)
Local cNatur		:= ""

/****************************************
mv_par01 - Do Cliente ?
mv_par02 - Ate o Cliente ?
mv_par03 - Da Loja ?
mv_par04 - Ate a Loja ?
mv_par05 - Do Prefixo ?
mv_par06 - Ate o Prefixo ?
mv_par07 - Do Titulo ?
mv_par08 - Ate o Titulo ?
mv_par09 - Da Natureza ?
mv_par10 - Ate a Natureza ?
mv_par11 - Do Banco ?
mv_par12 - Ate o Banco ?
mv_par13 - Da Emissao ?
mv_par14 - Ate a Emissao ?
mv_par15 - Do Vencimento ?
mv_par16 - Ate o Vencimento ?
mv_par17 - Qual Moeda ?
mv_par18 - Outras Moedas ?
mv_par19 - Converte valores pela ?
mv_par20 - Imprime Provisorios ?
mv_par21 - Converte Vencto. por ?
mv_par22 - Imp. Tit. em Desconto ?
mv_par23 - Compoe Saldo Retroativo ?
mv_par24 - Cons. Filiais Abaixo ?
mv_par25 - Da Filial ?
mv_par26 - Ate a Filial ?
mv_par27 - Da Data Contabil ?
mv_par28 - Ate a Data Contabil ?
mv_par29 - Imprime Tipos ?
mv_par30 - N�o Imprime Tipos ?
mv_par31 - Considera Adiantamentos ?
mv_par32 - Abatimentos ?
mv_par33 - Somente Tit. p/ Fluxo ?
mv_par34 - Data Base ?
mv_par35 - Tit. Emissao Futura ?
mv_par36 - Seleciona Filiais ?
*****************************************/

nDecs := MsDecimais(mv_par17)

/*****************************
 Sele��o de T�tulos a Receber
******************************/

cCposQry := ""

DbSelectArea("SE1")
aEval(SE1->(dbStruct()),{|e| cCposQry += ","+AllTrim(e[1])})

DbSelectArea("SED")
aEval(SED->(dbStruct()),{|e| cCposQry += ","+AllTrim(e[1])})

DbSelectArea("SA1")
aEval(SA1->(dbStruct()),{|e| cCposQry += ","+AllTrim(e[1])})

cQuery := "SELECT "+SubStr(cCposQry,2)+",SE1.R_E_C_N_O_ SE1RECNO FROM "
cQuery += 		RetSqlName("SE1") + " SE1, " 
cQuery += 		RetSqlName("SED") + " SED, " 
cQuery += 		RetSqlName("SA1") + " SA1 " 
cQuery += 		"WHERE "

If mv_par36 = 1 
	cQuery += "SE1.E1_FILIAL " + cRngFilSE1 + " AND "
ElseIf mv_par24 = 1
	cQuery += "SE1.E1_FILIAL BETWEEN '" +mv_par25+ "' AND '" + mv_par26+ "' AND "
Else
	cQuery += "SE1.E1_FILIAL = '" +xFilial("SE1")+ "' AND "	
EndIf

cQuery +=			"SE1.E1_PREFIXO BETWEEN '" 	+mv_par05+ "' AND '" +mv_par06+ "' AND "
cQuery +=			"SE1.E1_NUM BETWEEN '" 		+mv_par07+ "' AND '" +mv_par08+ "' AND "
cQuery +=			"SE1.E1_CLIENTE BETWEEN '" 	+mv_par01+ "' AND '" +mv_par02+ "' AND "
cQuery +=			"SE1.E1_LOJA BETWEEN '" 	+mv_par03+ "' AND '" +mv_par04+ "' AND "
cQuery +=			"SE1.E1_NATUREZ BETWEEN '" 	+mv_par09+ "' AND '" +mv_par10+ "' AND "
cQuery +=			"SE1.E1_PORTADO BETWEEN '" 	+mv_par11+ "' AND '" +mv_par12+ "' AND "
cQuery +=			"SE1.E1_EMISSAO BETWEEN '" 	+DtoS(mv_par13)+ "' AND '" +DtoS(mv_par14)+ "' AND "
cQuery +=			"SE1.E1_VENCTO BETWEEN '" 	+DtoS(mv_par15)+ "' AND '" +DtoS(mv_par16)+ "' AND "
cQuery +=			"SE1.E1_EMIS1 BETWEEN '" 	+DtoS(mv_par27)+ "' AND '" +DtoS(mv_par28)+ "' AND "

If mv_par18 = 2
	cQuery +=		"SE1.E1_MOEDA = " +Str(mv_par17)+ " AND "
EndIf

//Tipos que ser�o impressos
If !Empty(mv_par29)
	cTipoIn 	:= FormatIn(mv_par29,";")
	cQuery +=		"SE1.E1_TIPO IN " +cTipoIn+ " AND "
EndIf 

//Tipos que n�o ser�o impressos
If !Empty(mv_par30)
	cTipoOut 	:= FormatIn(mv_par30,";") 
	cQuery +=		"SE1.E1_TIPO NOT IN " + cTipoOut + " AND "
EndIf

//Provisorios
If mv_par20 == 2 
	cTipoNotIn += MVPROVIS
EndIf 
		
//Adiantamento
If mv_par31 == 2
	cTipoNotIn += MV_CRNEG+"|"+MVRECANT
EndIf
		
//Abatimento
If mv_par32 <> 1
	cTipoNotIn += MVABATIM +"|"+MVFUABT
EndIf

//Monta o NOT IN de Provisorios, Adiantamento e Abatimento
//dependendo da parametrizacao das perguntas
If !Empty(cTipoNotIn)	
	cQuery += 		"SE1.E1_TIPO NOT IN " + FR138NotIN(cTipoNotIn) + " AND "	
Endif

//Desconsiderar titulos em carteira descontada
If mv_par22 = 2
	cQuery +=		"SE1.E1_SITUACA NOT IN "+FormatIn(cLstDesc,'|')+" AND "		
EndIf

If mv_par23 = 1
	cQuery +=		"(SE1.E1_SALDO <> 0 OR SE1.E1_BAIXA > '"+DtoS(mv_par34)+"') AND "
Else
	cQuery +=		"SE1.E1_SALDO <> 0 AND "
EndIf

If mv_par33 = 1 //Considera somente t�tulos para fluxo
	cQuery +=		"SE1.E1_FLUXO <> 'N'  AND "
EndIf

If mv_par35 == 2 //Nao considerar titulos com emissao futura
	cQuery += 		"SE1.E1_EMISSAO <= '" + DtoS(mv_par34) + "' AND "
Endif

//NATUREZAS
cQuery +=			"SED.ED_FILIAL = '" +xFilial("SED")+ "' AND "

cQuery +=			"SED.ED_CODIGO = SE1.E1_NATUREZ AND " 
cQuery +=			"SED.ED_PAI <> ''  AND " 

//CLIENTE
cQuery +=			"SA1.A1_FILIAL = '" +xFilial("SA1")+ "' AND "

cQuery +=			"SA1.A1_COD = SE1.E1_CLIENTE AND " 
cQuery +=			"SA1.A1_LOJA = SE1.E1_LOJA AND " 

cQuery +=			"SED.D_E_L_E_T_ = '' AND "
cQuery +=			"SA1.D_E_L_E_T_ = '' AND "
cQuery +=			"SE1.D_E_L_E_T_ = '' "

cQuery +=		"ORDER BY SED.ED_PAI,SED.ED_CODIGO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

//Gera o arquivo tempor�rio
aStruct := SE1->(dbStruct())

aAdd(aStruct,{"E1_NREDUZ"	,"C",40,0})
aAdd(aStruct,{"E1_ATRASO"	,"N",10,0})
aAdd(aStruct,{"E1_VALCORR"	,"N",TamSx3("E1_VALOR")[1]	,TamSx3("E1_VALOR")[2]}		)
aAdd(aStruct,{"E1_NATPAI"	,"C",TamSx3("E1_NATUREZ")[1],TamSx3("E1_NATUREZ")[2]}	)
aAdd(aStruct,{"SE1RECNO"	,"N",10,0})

If(__oSE1138 <> NIL)
	__oSE1138:Delete()
	__oSE1138 := NIL
EndIf

__oSE1138 := FWTemporaryTable():New( 'SE1138' )
__oSE1138:SetFields( aStruct )
__oSE1138:AddIndex('01', {"E1_NATPAI","E1_NATUREZ"} )
__oSE1138:Create()

//Grava o retorno no arquivo tempor�rio
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(Eof())

	/****************************
		Valida se imprime o t�tulos
	*****************************/
	cNatur:= (cAliasQry)->E1_NATUREZ
	//Rateio Multinatureza
	If MV_MULNATR .And. (cAliasQry)->E1_MULTNAT == "1"
		If !PesqNatSev(cAliasQry,"E1", mv_par09, mv_par10)
			(cAliasQry)->(dbSkip())
			Loop
		Endif
		cNatur:= ""
	EndIf

	//Data base para reajuste de t�tulos baixados
	If mv_par21 = 2 .And. StoD((cAliasQry)->E1_VENCREA) < mv_par34
		dDtReaj := StoD((cAliasQry)->E1_VENCREA)	
	Else
		dDtReaj := mv_par34		
	EndIf

	//Posiciona no registro na SE1 para composi��o de saldo
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	SE1->(dbSeek((cAliasQry)->E1_FILIAL+(cAliasQry)->E1_PREFIXO+(cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA+(cAliasQry)->E1_TIPO+(cAliasQry)->E1_CLIENTE+(cAliasQry)->E1_LOJA))

	//Calculo de valores
	aSaldo := SdoTitNat((cAliasQry)->E1_PREFIXO,;	 	//PREFIXO
							(cAliasQry)->E1_NUM,;		//NUMERO
							(cAliasQry)->E1_PARCELA,;	//PARCELA
							(cAliasQry)->E1_TIPO,;		//TIPO
							(cAliasQry)->E1_CLIENTE,;	//CLIENTE
							(cAliasQry)->E1_LOJA,;		//LOJA
							cNatur,;	//NATUREZA
							"R",;						//CARTEIRA 
							"SE1",;						//ALIAS
							(cAliasQry)->E1_MOEDA,;		//MOEDA -> Passamos a moeda do t�tulo para n�o haver conversao pela fun��o
							mv_par23 = 1,;				//RECOMPOE PELA DATA BASE?
							dDtReaj )					//DATA DO REAJUSTE
							
	//Grava o registro 
	For nI := 1 to Len(aSaldo)
		Reclock("SE1138",.T.)
		For nX := 1 to Len(aStruct)
		
			IF aStruct[nX,2] == "M"
				loop
			Endif
			
			cCampo := aStruct[nX,1]
			
			Do Case
				Case cCampo == "E1_NREDUZ"
					xConteudo := (cAliasQry)->A1_NREDUZ			
				Case cCampo == "E1_ATRASO"
					nDiaAtrs := mv_par34 - StoD((cAliasQry)->E1_VENCREA) //(Data base do relat�rio - Vencimento Real)
					xConteudo := Iif (nDiaAtrs > 0,nDiaAtrs,0)		
				Case cCampo == "E1_VALCORR"
					xConteudo := 0				
				Case cCampo == "E1_JUROS"
					xConteudo := 0
				Case cCampo == "E1_NATPAI"
					xConteudo := (cAliasQry)->ED_PAI	
				Otherwise	
					xConteudo := (cAliasQry)->&cCampo
					
					//Ajuste para campos do tipo data
					If aStruct[nX,2] == "D"
						xConteudo := StoD(xConteudo)
					ElseIf aStruct[nX,2] == "L"
						xConteudo := (xConteudo == 'T')
					EndIf	
			EndCase
					
			//Adiciona conte�do ao campo
			nPosCampo := SE1138->(FieldPos(cCampo))
			SE1138->(FieldPut(nPosCampo,xConteudo))
			
		Next nX
		
		/****************************************
			Recompoe os valores que ser�o impressos
		*****************************************/
		
		//Verifica a taxa de convers�o do t�tulo, quando aplic�vel
		If mv_par19 = 2
			If !Empty((cAliasQry)->E1_TXMOEDA)
				nTaxa := (cAliasQry)->E1_TXMOEDA
			Else
				nTaxa := RecMoeda(StoD((cAliasQry)->E1_EMISSAO),mv_par17)
			EndIf
		Else
			nTaxa := 0	//Zera a taxa para utiliza��o da taxa do dia			
		EndIf 				
		
		//Valida o fator de multiplica��o
		If (cAliasQry)->E1_TIPO $ MVABATIM +"|"+MVFUABT+"|"+MV_CRNEG+"|"+MVRECANT
			nFator := -1
		Else
			nFator := 1
		EndIf
		
		If mv_par32 = 2 //nao listar
			nTotAbat := aSaldo[nI][5]
		EndIf
		
		nValOrig  	:= Round(NoRound(xMoeda(aSaldo[nI][4],(cAliasQry)->E1_MOEDA,mv_par17,mv_par34,nDecs+1,nTaxa),nDecs+1),nDecs)
		nValSaldo	:= Round(NoRound(xMoeda(aSaldo[nI][2]-nTotAbat,(cAliasQry)->E1_MOEDA,mv_par17,mv_par34,nDecs+1,nTaxa),nDecs+1),nDecs)
		
		SE1138->E1_NATUREZ := aSaldo[nI][1]
		
		//Altera a natureza Pai
		If MV_MULNATR .And. (cAliasQry)->E1_MULTNAT == "1"
			dbSelectArea("SED")
			SED->(dbSetOrder(1))
			If dbSeek(xFilial("SED")+aSaldo[nI][1])
				SE1138->E1_NATPAI := SED->ED_PAI	
			EndIf
		EndIf
		
		SE1138->E1_SALDO   := nValSaldo * nFator
		SE1138->E1_VALOR   := nValOrig *nFator
		
		nJuros 	:= fa070Juros(mv_par17,,"SE1138")	
		nValCorr	:= (nValSaldo + nJuros)
		
		SE1138->E1_VALCORR	:= nValCorr * nFator
		SE1138->E1_JUROS		:= nJuros * nFator
		
		SE1138->(MsUnlock())
		
		//Zera os valores calculados
		nJuros		:= 0
		nValOrig	:= 0
		nValCorr	:= 0
		nValSaldo	:= 0
	
	Next nI		
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea()) 

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F138TotNat

Totaliza as naturezas anal�ticas nas sint�ticas

@author    Marcos Berto
@version   11.80
@since     27/12/12

@param oReport - Objeto de Relat�rio

/*/
//------------------------------------------------------------------------------------------
Function F138TotNat()

Local aStruct		:= {}
Local cNatureza		:= ""
Local cQuery		:= ""
Local cAliasQry1 	:= GetNextAlias()
Local cAliasQry2 	:= GetNextAlias()
Local lCreate		:= .F.
Local nHandle		:= 0

/*************************************
 Busca todas as naturezas sint�ticas
**************************************/

cQuery := "SELECT SED.ED_CODIGO,SED.ED_DESCRIC,SED.ED_PAI FROM "
cQuery +=		RetSqlName("SED") + " SED " 
cQuery +=		"WHERE "
If mv_par36 = 1
	cQuery +=	"SED.ED_FILIAL " + cRngFilSED + " AND "
ElseIf  mv_par24 = 1 
	cQuery += "SED.ED_FILIAL BETWEEN '" +mv_par25+ "' AND '" +mv_par26+ "' AND "
Else
	cQuery +="SED.ED_FILIAL = '" +xFilial("SED")+ "' AND "	
EndIf
cQuery +=		"SED.ED_TIPO = '1' AND "	
cQuery +=		"SED.D_E_L_E_T_ = ''	"

cQuery +=	"ORDER BY ED_CODIGO DESC"	

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry1,.F.,.T.)

//Cria o arquivo tempor�rio

aAdd(aStruct,{"NATUREZA","C",TamSX3("ED_CODIGO")[1],TamSX3("ED_CODIGO")[2]})
aAdd(aStruct,{"NATPAI"	,"C",TamSX3("ED_CODIGO")[1],TamSX3("ED_CODIGO")[2]})
aAdd(aStruct,{"VALORIG"	,"N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]} )
aAdd(aStruct,{"SALDO"	,"N",TamSx3("E1_SALDO")[1],TamSx3("E1_SALDO")[2]} )
aAdd(aStruct,{"VALCORR"	,"N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]} )
aAdd(aStruct,{"JUROS"	,"N",TamSx3("E1_JUROS")[1],TamSx3("E1_JUROS")[2]} )
aAdd(aStruct,{"NIVEL"	,"N",10,0})

If(__oSED138 <> NIL)
	__oSED138:Delete()
	__oSED138 := NIL
EndIf

__oSED138 := FWTemporaryTable():New( 'SED138' )
__oSED138:SetFields( aStruct )
__oSED138:AddIndex('01', {"NATUREZA"} )
__oSED138:Create()

While !(cAliasQry1)->(Eof())
		
	RecLock("SED138",.T.)
	SED138->NATUREZA 	:= (cAliasQry1)->ED_CODIGO
	SED138->NATPAI 	:= (cAliasQry1)->ED_PAI
	SED138->(MsUnlock())
	
	(cAliasQry1)->(dbSkip())
EndDo

/******************************************************************
	Busca na tabela tempor�ria os registros pertecentes �s sint�ticas
*******************************************************************/

cQuery := "SELECT "
cQuery +=		"E1_NATPAI, "
cQuery +=		"SUM(E1_VALOR) E1_VALOR, "
cQuery +=		"SUM(E1_SALDO) E1_SALDO, "
cQuery +=		"SUM(E1_VALCORR) E1_VALCORR, "
cQuery +=		"SUM(E1_JUROS) E1_JUROS "
cQuery +=		"FROM "+ __oSE1138:GetRealName() +" TMPSE1138 "
cQuery +=		"GROUP BY E1_NATPAI "	

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry2,.F.,.T.)

dbSelectArea("SED138")
SED138->(dbSetOrder(1))

While !(cAliasQry2)->(Eof())

	If SED138->(dbSeek((cAliasQry2)->E1_NATPAI))
		
		cNatureza := SED138->NATUREZA
		
		While cNatureza <> ""
			If SED138->(dbSeek(cNatureza))
						
				RecLock("SED138",.F.)
				SED138->VALORIG	+= (cAliasQry2)->E1_VALOR
				SED138->SALDO		+= (cAliasQry2)->E1_SALDO
				SED138->VALCORR	+= (cAliasQry2)->E1_VALCORR
				SED138->JUROS		+= (cAliasQry2)->E1_JUROS
				SED138->NIVEL		+= 1
				SED138->(MsUnlock())
				
				//Controle de atualiza��o das superiores imediatas
				cNatureza := SED138->NATPAI
			Else
				cNatureza := ""	
			EndIf		
		EndDo						
	EndIf
	
	(cAliasQry2)->(dbSkip())
EndDo

(cAliasQry2)->(dbCloseArea())
(cAliasQry1)->(dbCloseArea())

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FR138NotIN

Montagem da expressao para query (Tipos de Titulo)

@author    Mauricio Pequim Jr
@version   11.80
@since     03/10/13

@param cTipos   = Tipos para montagem da string do NOT IN

@return cTipos  = Tipos formatados na string do NOT IN

/*/
//------------------------------------------------------------------------------------------
Static Function FR138NotIN(cTipos)

DEFAULT cTipos := ""

//Unifico os separadores 
cTipos	:=	StrTran(cTipos,',','/')
cTipos	:=	StrTran(cTipos,';','/')
cTipos	:=	StrTran(cTipos,'|','/')
cTipos	:=	StrTran(cTipos,'\','/')

cTipos := Formatin(cTipos,"/")

Return cTipos
