#Include "MATR241.CH"
#Include 'Protheus.ch'
#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K300 17
#Define K301 18
#Define K302 19
#Define K990 20
#Define 0200 21
#Define K290 22
#Define K291 23
#Define K292 24

//-------------------------------------------------------------------
/*/{Protheus.doc} MATR241
Relatório Analitico para o Bloco K do SPED Fiscal
@author robson.ribeiro
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATR241()

Local oReport
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Interface de impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario
@author robson.ribeiro
@since 28/09/2015
@version 1.0
@return oReport, Objeto oReport
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oSecK001,oSecK100,oSecK200,oSecK210,oSecK215,oSecK220,oSecK230,oSecK235,oSecK250
Local oSecK255,oSecK260,oSecK265,oSecK270,oSecK275,oSecK280,oSecK990,oSec0210,oSec0200
Local oSecK300,oSecK301,oSecK302
Local oSecK290,oSecK291,oSecK292
Local oReport
Local nSpace	:= 15
Local cDesc		:= STR0001//"Este relatório tem como objetivo apresentar os registros apurados do Bloco K do SPED Fiscal."
Local nTamProd	:= TamSX3("B1_COD")[1]
Local nTamNSeq	:= 30
Local nTamChave  := nTamProd + TamSX3("D3_EMISSAO")[1]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamQtd	:= 16
Local cPicQtd	:= ""
Local cPicQtdOld:= "@E 999,999,999,999.999"
Local cPicCmp	:= "@E 999,999,999.999999"
Local cPicPrd	:= "@E 99,999,999,999.9999"
// --------------------------------------------------------
Local cAli0210	:= GetNextAlias()
Local cAliK001	:= GetNextAlias()
Local cAliK100	:= GetNextAlias()
Local cAliK200	:= GetNextAlias()
Local cAliK210	:= GetNextAlias()
Local cAliK215	:= GetNextAlias()
Local cAliK220	:= GetNextAlias()
Local cAliK230	:= GetNextAlias()
Local cAliK235	:= GetNextAlias()
Local cAliK250	:= GetNextAlias()
Local cAliK255	:= GetNextAlias()
Local cAliK260	:= GetNextAlias()
Local cAliK265	:= GetNextAlias()
Local cAliK270	:= GetNextAlias()
Local cAliK275	:= GetNextAlias()
Local cAliK280	:= GetNextAlias()
Local cAliK290	:= GetNextAlias()
Local cAliK291	:= GetNextAlias()
Local cAliK292	:= GetNextAlias()
Local cAliK300	:= GetNextAlias()
Local cAliK301	:= GetNextAlias()
Local cAliK302	:= GetNextAlias()
Local cAliK990	:= GetNextAlias()
Local cAli0200	:= GetNextAlias()
Local aAlias	:= {cAli0210,cAliK001,cAliK100,cAliK200,cAliK210,cAliK215,cAliK220,cAliK230,;
					cAliK235,cAliK250,cAliK255,cAliK260,cAliK265,cAliK270,cAliK275,cAliK280,;
					cAliK300,cAliK301,cAliK302,cAliK990,cAli0200,cAliK290,cAliK291,cAliK292}

oReport := TReport():New("MATR241","","MTR241",{|oReport| ReportPrint(oReport,aAlias)},cDesc)
oReport:SetTitle(STR0002)//"Relação Bloco K Analítico"
oReport:SetPortrait()
oReport:DisableOrientation()
oReport:SetEdit(.F.)

Pergunte("MTR241",.F.)

Private cVersSped := VerBlocoK(MV_PAR01)

// ------ Tamanhos conforme especificado no Guia EFD ------
nTamQtd	:= 16
If cVersSped < '013'
	cPicQtd	:= "@E 999,999,999,999.999"
Else
	cPicQtd	:= "@E 999,999,999.999999"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K001                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK001 := TRSection():New(oReport,STR0003,{cAliK001})//"Registro K001"
oSecK001:SetReadOnly()
oSecK001:SetLineStyle()
oSecK001:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK001,"REG"     ,cAliK001,STR0004,,2*nSpace,,,,,,,,,,,)		//"Registro"
TRCell():New(oSecK001,"IND_MOV" ,cAliK001,STR0005,,3*nSpace,,,,,,,,,,,)		//"Ind. Movimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K100                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK100 := TRSection():New(oReport,STR0006,{cAliK100})//"Registro K100"
oSecK100:SetReadOnly()
oSecK100:SetLineStyle()
oSecK100:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK100,"REG"     ,cAliK100,STR0007,,nSpace,,,,,,,,,,,)			//"Registro"
TRCell():New(oSecK100,"DT_INI"  ,cAliK100,STR0008,,nSpace,,,,,,,,,,,)			//"DT. Inicial"
TRCell():New(oSecK100,"DT_FIN"  ,cAliK100,STR0009,,nSpace,,,,,,,,,,,)			//"DT. Final"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K200                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK200 := TRSection():New(oReport,STR0010,{cAliK200})//"Registro K200"
oSecK200:SetReadOnly()
oSecK200:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK200,"REG"     ,cAliK200,STR0011,,nSpace,,,,,,,,,,,)			//"Registro"
TRCell():New(oSecK200,"DT_EST"  ,cAliK200,STR0012,,nSpace,,,,,,,,,,,)			//"DT. Estoque"
TRCell():New(oSecK200,"COD_ITEM",cAliK200,STR0013,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK200,"QTD"     ,cAliK200,STR0014,cPicQtdOld,nTamQtd,,,,,,,,,,,)	//"Quantidade"
TRCell():New(oSecK200,"IND_EST" ,cAliK200,STR0015,,nSpace,,,,,,,,,,,)			//"Indicador Est."
TRCell():New(oSecK200,"COD_PART",cAliK200,STR0016,,nSpace,,,,,,,,,,,)			//"Participante."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K210                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK210 := TRSection():New(oReport,STR0078,{cAliK210}) //"Registro K210"
oSecK210:SetReadOnly()
oSecK210:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK210,"REG"     	,cAliK210,STR0011,,nSpace,,,,,,,,,,,)			//"Registro"
TRCell():New(oSecK210,"DT_INI_OS"	,cAliK210,STR0079,,nSpace,,,,,,,,,,,)			//"DT.INI."
TRCell():New(oSecK210,"DT_FIN_OS"	,cAliK210,STR0080,,nSpace,,,,,,,,,,,)			//"DT.FIN."
TRCell():New(oSecK210,"COD_DOC_OS"	,cAliK210,STR0081,,nTamNSeq,,,,,,,,,,,)			//"Doc/OS"
TRCell():New(oSecK210,"COD_ITEM_O"	,cAliK210,STR0013,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK210,"QTD_ORI"     ,cAliK210,STR0014,cPicQtd,nTamQtd,,,,,,,,,,,)	//"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K215                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK215 := TRSection():New(oReport,STR0082,{cAliK215}) //"Registro K215"
oSecK215:SetReadOnly()
oSecK215:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK215,"REG"     	,cAliK215,STR0011,,nSpace,,,,,,,,,,,)			//"Registro"
TRCell():New(oSecK215,"COD_DOC_OS"	,cAliK215,STR0081,,nTamNSeq,,,,,,,,,,,)			//"Doc/OS"
TRCell():New(oSecK215,"COD_ITEM_D"	,cAliK215,STR0013,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK215,"QTD_DES"     ,cAliK215,STR0014,cPicQtd,nTamQtd,,,,,,,,,,,)	//"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K220                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK220 := TRSection():New(oReport,STR0017,{cAliK220})//"Registro K220"
oSecK220:SetReadOnly()
oSecK220:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK220,"REG"       ,cAliK220,STR0018,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK220,"DT_MOV"    ,cAliK220,STR0019,,nSpace,,,,,,,,,,,)				//"DT. Estoque"
TRCell():New(oSecK220,"COD_ITEM_O",cAliK220,STR0020,,nTamProd+nSpace,,,,,,,,,,,)	//"Código Origem"
TRCell():New(oSecK220,"COD_ITEM_D",cAliK220,STR0021,,nTamProd+nSpace,,,,,,,,,,,)	//"Código Destino"
TRCell():New(oSecK220,"QTD_ORI"   ,cAliK220,'Quant. Origem',cPicQtd,nTamQtd,,,,,,,,,,,)		//"Quant. Origem"
TRCell():New(oSecK220,"QTD_DEST"  ,cAliK220,"Quant. Destino",cPicQtd,nTamQtd,,,,,,,,,,,)		//"Quantidade Destino"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K230                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK230 := TRSection():New(oReport,STR0023,{cAliK230})//"Registro K230"
oSecK230:SetReadOnly()
oSecK230:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK230,"REG"       ,cAliK230,STR0024,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK230,"DT_INI_OP" ,cAliK230,STR0025,,nSpace,,,,,,,,,,,)				//"DT. Ini. OP"
TRCell():New(oSecK230,"DT_FIN_OP" ,cAliK230,STR0026,,nSpace,,,,,,,,,,,)				//"DT. Fin. OP"
TRCell():New(oSecK230,"COD_DOC_OP",cAliK230,STR0027,,nSpace,,,,,,,,,,,)				//"Número OP"
TRCell():New(oSecK230,"COD_ITEM"  ,cAliK230,STR0028,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK230,"QTD_ENC"   ,cAliK230,STR0029,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Quantidade"
TRCell():New(oSecK230,"QTDORI"    ,cAliK230,STR0076,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. OP"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K235                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK235 := TRSection():New(oReport,STR0030,{cAliK235})//"Registro K235"
oSecK235:SetReadOnly()
oSecK235:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK235,"REG"       ,cAliK235,STR0031,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK235,"DT_SAIDA"  ,cAliK235,STR0032,,nSpace,,,,,,,,,,,)				//"DT. Saída"
TRCell():New(oSecK235,"COD_DOC_OP",cAliK235,STR0033,,nSpace,,,,,,,,,,,)				//"Número OP"
TRCell():New(oSecK235,"COD_ITEM"  ,cAliK235,STR0034,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK235,"COD_INS_SU",cAliK235,STR0035,,nTamProd+nSpace,,,,,,,,,,,)	//"Código Subs."
TRCell():New(oSecK235,"QTD"       ,cAliK235,STR0036,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Quantidade"
TRCell():New(oSecK235,"EMPENHO"   ,cAliK235,STR0077,,,,,,,,,,,,,)					//"Empenho?"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K250                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK250 := TRSection():New(oReport,STR0037,{cAliK250})//"Registro K250"
oSecK250:SetReadOnly()
oSecK250:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK250,"REG"     ,cAliK250,STR0038,,nSpace,,,,,,,,,,,)			//"Registro"
TRCell():New(oSecK250,"DT_PROD" ,cAliK250,STR0039,,nSpace,,,,,,,,,,,)			//"DT. Produção"
TRCell():New(oSecK250,"CHAVE"   ,cAliK250,STR0040,,2*nSpace,,,,,,,,,,,)			//"Chave"
TRCell():New(oSecK250,"COD_ITEM",cAliK250,STR0041,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK250,"QTD"     ,cAliK250,STR0042,cPicQtd,nTamQtd,,,,,,,,,,,)	//"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K255                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK255 := TRSection():New(oReport,STR0043,{cAliK255})//"Registro K255"
oSecK255:SetReadOnly()
oSecK255:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK255,"REG"       ,cAliK255,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK255,"DT_CONS"   ,cAliK255,STR0045,,nSpace,,,,,,,,,,,)				//"DT. Saída"
TRCell():New(oSecK255,"CHAVE"     ,cAliK255,STR0046,,2*nSpace,,,,,,,,,,,)			//"Chave"
TRCell():New(oSecK255,"COD_ITEM"  ,cAliK255,STR0047,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSecK255,"COD_INS_SU",cAliK255,STR0048,,nTamProd+nSpace,,,,,,,,,,,)	//"Código Subs."
TRCell():New(oSecK255,"QTD"       ,cAliK255,STR0049,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K260                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK260 := TRSection():New(oReport,STR0085,{cAliK260}) //"Registro K260"
oSecK260:SetReadOnly()
oSecK260:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK260,"REG"			,cAliK260,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK260,"COD_OP_OS"	,cAliK260,STR0086,,nSpace,,,,,,,,,,,)				//"OP/OS"
TRCell():New(oSecK260,"COD_ITEM" 	,cAliK260,STR0047,,nTamProd+nSpace,,,,,,,,,,,)		//"Código"
TRCell():New(oSecK260,"DT_SAIDA"	,cAliK260,STR0032,,nSpace,,,,,,,,,,,)				//"Dt. Saída"
TRCell():New(oSecK260,"QTD_SAIDA"	,cAliK260,STR0087,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Saída"
TRCell():New(oSecK260,"DT_RET"		,cAliK260,STR0088,,nSpace,,,,,,,,,,,)				//"Dt. Ret."
TRCell():New(oSecK260,"QTD_RET"		,cAliK260,STR0089,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Ret."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K265                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK265 := TRSection():New(oReport,STR0090,{cAliK265}) //"Registro K265"
oSecK265:SetReadOnly()
oSecK265:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK265,"REG"			,cAliK265,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK265,"COD_OP_OS"	,cAliK265,STR0086,,nSpace,,,,,,,,,,,)				//"OP/OS"
TRCell():New(oSecK265,"COD_ITEM" 	,cAliK265,STR0047,,nTamProd+nSpace,,,,,,,,,,,)		//"Código"
TRCell():New(oSecK265,"QTD_CONS"	,cAliK265,STR0091,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Cons."
TRCell():New(oSecK265,"QTD_RET"		,cAliK265,STR0092,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Ret."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K270                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK270 := TRSection():New(oReport,STR0093,{cAliK270}) //"Registro K270"
oSecK270:SetReadOnly()
oSecK270:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK270,"REG"			,cAliK270,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK270,"DT_INI_AP"	,cAliK270,STR0094,,nSpace,,,,,,,,,,,)				//"Dt. Ini. Ap."
TRCell():New(oSecK270,"DT_FIN_AP"	,cAliK270,STR0095,,nSpace,,,,,,,,,,,)				//"Dt. Fin. Ap."
TRCell():New(oSecK270,"COD_OP_OS"	,cAliK270,STR0086,,nSpace,,,,,,,,,,,)				//"OP/OS"
TRCell():New(oSecK270,"COD_ITEM" 	,cAliK270,STR0047,,nTamProd+nSpace,,,,,,,,,,,)		//"Código"
TRCell():New(oSecK270,"QTD_COR_P"	,cAliK270,STR0096,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Pos."
TRCell():New(oSecK270,"QTD_COR_N"	,cAliK270,STR0097,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Neg"
TRCell():New(oSecK270,"ORIGEM"		,cAliK270,STR0098,,nSpace,,,,,,,,,,,)				//"Origem"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K275                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK275 := TRSection():New(oReport,STR0099,{cAliK275}) //"Registro K275"
oSecK275:SetReadOnly()
oSecK275:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK275,"REG"			,cAliK275,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK275,"COD_ITEM" 	,cAliK275,STR0047,,nTamProd+nSpace,,,,,,,,,,,)		//"Código"
TRCell():New(oSecK275,"QTD_COR_P"	,cAliK275,STR0096,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Pos."
TRCell():New(oSecK275,"QTD_COR_N"	,cAliK275,STR0097,cPicQtd,nTamQtd,,,,,,,,,,,)		//"Qtd. Neg"
TRCell():New(oSecK275,"COD_INS_SU"	,cAliK275,STR0048,,nTamProd+nSpace,,,,,,,,,,,)		//"Código Subs."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K280                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK280 := TRSection():New(oReport,STR0100,{cAliK280}) //"Registro K280"
oSecK280:SetReadOnly()
oSecK280:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK280,"REG"			,cAliK280,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK280,"DT_EST"  	,cAliK280,STR0012,,nSpace,,,,,,,,,,,)				//"DT. Estoque"
TRCell():New(oSecK280,"COD_ITEM" 	,cAliK280,STR0047,,nTamProd+nSpace,,,,,,,,,,,)		//"Código"
TRCell():New(oSecK280,"QTD_COR_P"	,cAliK280,STR0096,cPicQtdOld,nTamQtd,,,,,,,,,,,)		//"Qtd. Pos."
TRCell():New(oSecK280,"QTD_COR_N"	,cAliK280,STR0097,cPicQtdOld,nTamQtd,,,,,,,,,,,)		//"Qtd. Neg"
TRCell():New(oSecK280,"IND_EST" 	,cAliK280,STR0015,,nSpace,,,,,,,,,,,)				//"Indicador Est."
TRCell():New(oSecK280,"COD_PART"	,cAliK280,STR0016,,nSpace,,,,,,,,,,,)				//"Participante."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K290                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK290 := TRSection():New(oReport,STR0112,{cAliK290}) //"Registro K290"
oSecK290:SetReadOnly()
oSecK290:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK290,"REG"			,cAliK290,STR0044,,nSpace,,,,,,,,,,,) //"Registro"
TRCell():New(oSecK290,"DT_INI_OP"  	,cAliK290,STR0025,,nSpace,,,,,,,,,,,) //"DT. Ini. OP"
TRCell():New(oSecK290,"DT_FIN_OP" 	,cAliK290,STR0026,,nSpace,,,,,,,,,,,) //"DT. Fin. OP"
TRCell():New(oSecK290,"COD_DOC_OP"	,cAliK290,STR0027,,nSpace,,,,,,,,,,,) //"Número OP"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K291                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK291 := TRSection():New(oReport,STR0113,{cAliK291}) //"Registro K291"
oSecK291:SetReadOnly()
oSecK291:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK291,"REG"			,cAliK291,STR0044,,nSpace,,,,,,,,,,,) //"Registro"
TRCell():New(oSecK291,"COD_DOC_OP"  ,cAliK291,STR0027,,nSpace,,,,,,,,,,,) //"Número OP"
TRCell():New(oSecK291,"COD_ITEM" 	,cAliK291,STR0028,,nTamProd+nSpace,,,,,,,,,,,) //"Código"
TRCell():New(oSecK291,"QTD"			,cAliK291,STR0049,cPicQtd,nTamQtd,,,,,,,,,,,) //"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K292                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK292 := TRSection():New(oReport,STR0114,{cAliK292}) //"Registro K292"
oSecK292:SetReadOnly()
oSecK292:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK292,"REG"			,cAliK292,STR0044,,nSpace,,,,,,,,,,,) //"Registro"
TRCell():New(oSecK292,"COD_DOC_OP"  ,cAliK292,STR0027,,nSpace,,,,,,,,,,,) //"Número OP"
TRCell():New(oSecK292,"COD_ITEM" 	,cAliK292,STR0028,,nTamProd+nSpace,,,,,,,,,,,) //"Código"
TRCell():New(oSecK292,"QTD"			,cAliK292,STR0049,cPicQtd,nTamQtd,,,,,,,,,,,) //"Quantidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K300                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK300 := TRSection():New(oReport,"Registro K300",{cAliK300})
oSecK300:SetReadOnly()
oSecK300:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK300,"REG"			,cAliK300,STR0044,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSecK300,"DT_PROD"  	,cAliK300,"Data da produção",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK300,"CHAVE"  		,cAliK300,"Chave",,nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K301                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK301 := TRSection():New(oReport,"Registro K301",{cAliK301})
oSecK301:SetReadOnly()
oSecK301:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK301,"REG"			,cAliK301,STR0044,,nSpace,,,,,,,,,,,)
TRCell():New(oSecK301,"COD_ITEM"  	,cAliK301,"Codigo",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK301,"QTD"  		,cAliK301,"Qtd.",cPicQtdOld,nSpace,,,,,,,,,,,)
TRCell():New(oSecK301,"CHAVE"  		,cAliK301,"Chave",,nTamChave,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K302                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK302 := TRSection():New(oReport,"Registro K302",{cAliK302})
oSecK302:SetReadOnly()
oSecK302:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK302,"REG"			,cAliK302,STR0044,,nSpace,,,,,,,,,,,)
TRCell():New(oSecK302,"COD_ITEM"  	,cAliK302,"Codigo",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK302,"QTD"  		,cAliK302,"Qtd.",cPicQtdOld,nSpace,,,,,,,,,,,)
TRCell():New(oSecK302,"CHAVE"  		,cAliK302,"Chave",,nTamChave,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K990                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK990 := TRSection():New(oReport,STR0050,{cAliK990})//"Registro K990"
oSecK990:SetReadOnly()
oSecK990:SetLineStyle()
oSecK990:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK990,"REG"      ,cAliK990,STR0051,,2*nSpace,,,,,,,,,,,)	//"Registro"
TRCell():New(oSecK990,"QTD_LIN_K",cAliK990,STR0052,,2*nSpace,,,,,,,,,,,)	//"Quantidade Linhas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 0210                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSec0210 := TRSection():New(oReport,STR0053,{cAli0210})//"Registro 0210"
oSec0210:SetReadOnly()
oSec0210:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSec0210,"REG"       ,cAli0210,STR0054,,nSpace,,,,,,,,,,,)				//"Registro"
TRCell():New(oSec0210,"COD_ITEM"  ,cAli0210,STR0055,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSec0210,"COD_I_COMP",cAli0210,STR0056,,nTamProd+nSpace,,,,,,,,,,,)	//"Código Comp."
TRCell():New(oSec0210,"QTD_COMP"  ,cAli0210,STR0057,cPicCmp,nTamQtd,,,,,,,,,,,)		//"Quantidade"
TRCell():New(oSec0210,"PERDA"     ,cAli0210,STR0058,cPicPrd,nTamQtd,,,,,,,,,,,)		//"Perda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 0200                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSec0200 := TRSection():New(oReport,STR0106,{cAli0200})//"Registro 0200"
oSec0200:SetReadOnly()
oSec0200:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSec0200,"COD_ITEM"  ,cAli0200,STR0055,,nTamProd+nSpace,,,,,,,,,,,)	//"Código"
TRCell():New(oSec0200,"B1_UM"	  ,cAli0200,"Unid.Med.",,05,,,,,,,,,,,)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressao do relatorio
@author robson.ribeiro
@since 28/09/2015
@version 1.0
@param oReport, objeto, Objeto oReport
@param cAliK200, character, Alias do Registro K200
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,aAlias)

Local nMeter		:= 0
Local aIndices		:= {}
Local aAliProc[24]
Local dDataDe		:= MV_PAR01
Local dDataAte		:= MV_PAR02
Local lEstrMov		:= MV_PAR03 == 1
Local lSum			:= MV_PAR04 == 2
Local lProcAll		:= MV_PAR05 == 2
Local nTamCli		:= TamSX3("A1_COD" )[1]
Local nTamLjCli		:= TamSX3("A1_LOJA")[1]
Local nTamFor		:= TamSX3("A2_COD" )[1]
Local nTamLjFor		:= TamSX3("A2_LOJA")[1]
Local cSemReg		:= STR0059//"*** Não há registros para o período selecionado."
Local oSecK001		:= oReport:Section(1)
Local oSecK100		:= oReport:Section(2)
Local oSecK200		:= oReport:Section(3)
Local oSecK210		:= oReport:Section(4)
Local oSecK215		:= oReport:Section(5)
Local oSecK220		:= oReport:Section(6)
Local oSecK230		:= oReport:Section(7)
Local oSecK235		:= oReport:Section(8)
Local oSecK250		:= oReport:Section(9)
Local oSecK255		:= oReport:Section(10)
Local oSecK260		:= oReport:Section(11)
Local oSecK265		:= oReport:Section(12)
Local oSecK270		:= oReport:Section(13)
Local oSecK275		:= oReport:Section(14)
Local oSecK280		:= oReport:Section(15)
Local oSecK290		:= oReport:Section(16)
Local oSecK291		:= oReport:Section(17)
Local oSecK292		:= oReport:Section(18)
Local oSecK300		:= oReport:Section(19)
Local oSecK301		:= oReport:Section(20)
Local oSecK302		:= oReport:Section(21)
Local oSecK990		:= oReport:Section(22)
Local oSec0210		:= oReport:Section(23)
Local oSec0200		:= oReport:Section(24)
Local nX
Local cVersSped		:= VerBlocoK(MV_PAR01)
Local cAliasOld		:= ""

oReport:SetTitle(STR0060)//"Relação do Bloco K do SPED Fiscal - Analítico"

// Imprime tudo ou K200/K280
If lProcAll
	AFill(aAliProc,.T.)
Else
	AFill(aAliProc,.F.)
	aAliProc[K200] := .T.
	aAliProc[K280] := .T.
EndIf

If cVersSped < "013"
	aAliProc[K290] := .F.
	aAliProc[K291] := .F.
	aAliProc[K292] := .F.
	aAliProc[K300] := .F.
	aAliProc[K301] := .F.
	aAliProc[K302] := .F.
EndIf

If cVersSped >= "016"
	aAliProc[0210] := .F.
ENDiF

If !oReport:Cancel()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao do Bloco K               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aIndices := SPDBlocoK(dDataDe,dDataAte,@aAlias,aAliProc,lEstrMov,lSum,.F.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Impressao do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aAlias)
		If Select(aAlias[nX])>0
			nMeter += (aAlias[nX])->(LastRec())
		EndIf
	Next nX
	oReport:SetMeter(nMeter)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K001                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText(STR0061)//"REGISTRO K001 - Abertura do Bloco K"
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K001])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K001])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK001:Init()
			oSecK001:Cell("REG"		):setValue((aAlias[K001])->REG)
			If (aAlias[K001])->IND_MOV == "0"
				oSecK001:Cell("IND_MOV"):setValue(STR0062)//"0 - Existem informações no Bloco K"
			ElseIf (aAlias[K001])->IND_MOV == "1"
				oSecK001:Cell("IND_MOV"):setValue(STR0063)//"1 - Não existem informacoes no Bloco K"
			EndIf
			oSecK001:PrintLine()
			(aAlias[K001])->(dbSkip())
		EndDo
	EndIf
	oSecK001:Finish()
	oReport:PrintText(" ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K100                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText(STR0064)//"REGISTRO K100 - Período de Apuração do ICMS/IPI"
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K100])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K100])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK100:Init()
			oSecK100:Cell("REG"		):setValue((aAlias[K100])->REG)
			oSecK100:Cell("DT_INI"	):setValue((aAlias[K100])->DT_INI)
			oSecK100:Cell("DT_FIN"	):setValue((aAlias[K100])->DT_FIN)
			oSecK100:PrintLine()
			(aAlias[K100])->(dbSkip())
		EndDo
	EndIf
	oSecK100:Finish()
	oReport:PrintText(" ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K200                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K200]
		oReport:PrintText(STR0065)//"REGISTRO K200 - Estoque Escriturado"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K200])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K200])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf

				If (aAlias[K200])->QTD <> 0
					oSecK200:Init()
					oSecK200:Cell("REG"			):setValue((aAlias[K200])->REG)
					oSecK200:Cell("DT_EST"		):setValue((aAlias[K200])->DT_EST)
					oSecK200:Cell("COD_ITEM"	):setValue((aAlias[K200])->COD_ITEM)
					oSecK200:Cell("QTD"			):setValue((aAlias[K200])->QTD)
					If (aAlias[K200])->IND_EST == "0"
						oSecK200:Cell("IND_EST"):setValue(STR0066)//"Próprio"
					ElseIf (aAlias[K200])->IND_EST == "1"
						oSecK200:Cell("IND_EST"):setValue(STR0067)//"Em Terceiros"
					ElseIf (aAlias[K200])->IND_EST == "2"
						oSecK200:Cell("IND_EST"):setValue(STR0068)//"De Terceiros"
					EndIf
					If SubStr((aAlias[K200])->COD_PART,1,3) == "SA2"
						oSecK200:Cell("COD_PART"):setValue("F: "+SubStr((aAlias[K200])->COD_PART,4,nTamFor)+"-"+SubStr((aAlias[K200])->COD_PART,4+nTamFor,nTamLjFor))
					ElseIf SubStr((aAlias[K200])->COD_PART,1,3) == "SA1"
						oSecK200:Cell("COD_PART"):setValue("C: "+SubStr((aAlias[K200])->COD_PART,4,nTamCli)+"-"+SubStr((aAlias[K200])->COD_PART,4+nTamCli,nTamLjCli))
					Else
						oSecK200:Cell("COD_PART"):setValue("")
					EndIf
					oSecK200:PrintLine()
				EndIf

				(aAlias[K200])->(dbSkip())
			EndDo
		EndIf
		oSecK200:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K210                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K210]
		oReport:PrintText(STR0083) //"REGISTRO K210 - Desmontagem de Produtos: Origem"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K210])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K210])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK210:Init()
				oSecK210:Cell("REG"			):setValue((aAlias[K210])->REG)
				oSecK210:Cell("DT_INI_OS"	):setValue((aAlias[K210])->DT_INI_OS)
				oSecK210:Cell("DT_FIN_OS"	):setValue((aAlias[K210])->DT_FIN_OS)
				oSecK210:Cell("COD_DOC_OS"	):setValue((aAlias[K210])->COD_DOC_OS)
				oSecK210:Cell("COD_ITEM_O"	):setValue((aAlias[K210])->COD_ITEM_O)
				oSecK210:Cell("QTD_ORI"		):setValue((aAlias[K210])->QTD_ORI)
				oSecK210:PrintLine()
				(aAlias[K210])->(dbSkip())
			EndDo
		EndIf
		oSecK210:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K215                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0084) //"REGISTRO K215 - Desmontagem de Produtos: Destino"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K215])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K215])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK215:Init()
				oSecK215:Cell("REG"			):setValue((aAlias[K215])->REG)
				oSecK215:Cell("COD_DOC_OS"	):setValue((aAlias[K215])->COD_DOC_OS)
				oSecK215:Cell("COD_ITEM_D"	):setValue((aAlias[K215])->COD_ITEM_D)
				oSecK215:Cell("QTD_DES"		):setValue((aAlias[K215])->QTD_DES)
				oSecK215:PrintLine()
				(aAlias[K215])->(dbSkip())
			EndDo
		EndIf
		oSecK215:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K220                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K220]
		oReport:PrintText(STR0069)//"REGISTRO K220 - Outras Movimentações Internas entre Mercadorias"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K220])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K220])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK220:Init()
				oSecK220:Cell("REG"			):setValue((aAlias[K220])->REG)
				oSecK220:Cell("DT_MOV"		):setValue((aAlias[K220])->DT_MOV)
				oSecK220:Cell("COD_ITEM_O"	):setValue((aAlias[K220])->COD_ITEM_O)
				oSecK220:Cell("COD_ITEM_D"	):setValue((aAlias[K220])->COD_ITEM_D)
				oSecK220:Cell("QTD_ORI"			):setValue((aAlias[K220])->QTD_ORI)
				oSecK220:Cell("QTD_DEST"		):setValue((aAlias[K220])->QTD_DEST)
				oSecK220:PrintLine()
				(aAlias[K220])->(dbSkip())
			EndDo
		EndIf
		oSecK220:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K230                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K230]
		oReport:PrintText(STR0070)//"REGISTRO K230 - Itens Produzidos"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K230])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			If !lEstrMov
				oSecK230:Cell("QTDORI"):Disable()
			EndIf
			While !(aAlias[K230])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK230:Init()
				oSecK230:Cell("REG"			):setValue((aAlias[K230])->REG)
				oSecK230:Cell("DT_INI_OP"	):setValue((aAlias[K230])->DT_INI_OP)
				oSecK230:Cell("DT_FIN_OP"	):setValue((aAlias[K230])->DT_FIN_OP)
				oSecK230:Cell("COD_DOC_OP"	):setValue((aAlias[K230])->COD_DOC_OP)
				oSecK230:Cell("COD_ITEM"	):setValue((aAlias[K230])->COD_ITEM)
				oSecK230:Cell("QTD_ENC"		):setValue((aAlias[K230])->QTD_ENC)
				oSecK230:Cell("QTDORI"		):setValue((aAlias[K230])->QTDORI)
				oSecK230:PrintLine()
				(aAlias[K230])->(dbSkip())
			EndDo
		EndIf
		oSecK230:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K235                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0071)//"REGISTRO K235 - Insumos Consumidos"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K235])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			If !lEstrMov
				oSecK235:Cell("EMPENHO"):Disable()
			EndIf
			While !(aAlias[K235])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK235:Init()
				oSecK235:Cell("REG"			):setValue((aAlias[K235])->REG)
				oSecK235:Cell("DT_SAIDA"	):setValue((aAlias[K235])->DT_SAIDA)
				oSecK235:Cell("COD_ITEM"	):setValue((aAlias[K235])->COD_ITEM)
				oSecK235:Cell("QTD"			):setValue((aAlias[K235])->QTD)
				oSecK235:Cell("COD_INS_SU"	):setValue((aAlias[K235])->COD_INS_SU)
				oSecK235:Cell("COD_DOC_OP"	):setValue((aAlias[K235])->COD_DOC_OP)
				oSecK235:Cell("EMPENHO"		):setValue(If((aAlias[K235])->EMPENHO == "S","Sim","Não"))
				oSecK235:PrintLine()
				(aAlias[K235])->(dbSkip())
			EndDo
		EndIf
		oSecK235:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K250                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K250]
		oReport:PrintText(STR0072)//"REGISTRO K250 - Industrialização Efetuada por Terceiros (Itens Produzidos)"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K250])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K250])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK250:Init()
				oSecK250:Cell("REG"			):setValue((aAlias[K250])->REG)
				oSecK250:Cell("DT_PROD"		):setValue((aAlias[K250])->DT_PROD)
				oSecK250:Cell("COD_ITEM"	):setValue((aAlias[K250])->COD_ITEM)
				oSecK250:Cell("QTD"			):setValue((aAlias[K250])->QTD)
				oSecK250:Cell("CHAVE"		):setValue((aAlias[K250])->CHAVE)
				oSecK250:PrintLine()
				(aAlias[K250])->(dbSkip())
			EndDo
		EndIf
		oSecK250:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K255                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0073)//"REGISTRO K255 - Industrialização Efetuada por Terceiros (Insumos Consumidos)"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K255])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K255])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK255:Init()
				oSecK255:Cell("REG"			):setValue((aAlias[K255])->REG)
				oSecK255:Cell("DT_CONS"		):setValue((aAlias[K255])->DT_CONS)
				oSecK255:Cell("COD_ITEM"	):setValue((aAlias[K255])->COD_ITEM)
				oSecK255:Cell("COD_INS_SU"	):setValue((aAlias[K255])->COD_INS_SU)
				oSecK255:Cell("QTD"			):setValue((aAlias[K255])->QTD)
				oSecK255:Cell("CHAVE"		):setValue((aAlias[K255])->CHAVE)
				oSecK255:PrintLine()
				(aAlias[K255])->(dbSkip())
			EndDo
		EndIf
		oSecK255:Finish()
		oReport:PrintText(" ")
	EndIf

	If aAliProc[K260]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K260                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0101) //"REGISTRO K260 - Reprocessamento/Reparo de Produto/Insumo"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K260])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK26X")
				oReport:PrintText("Ponto de entrada REGK26X não compilado.")
			EndIf
		Else
			While !(aAlias[K260])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK260:Init()
				oSecK260:Cell("REG"			):setValue((aAlias[K260])->REG)
				oSecK260:Cell("COD_OP_OS"	):setValue((aAlias[K260])->COD_OP_OS)
				oSecK260:Cell("COD_ITEM"	):setValue((aAlias[K260])->COD_ITEM)
				oSecK260:Cell("DT_SAIDA"	):setValue((aAlias[K260])->DT_SAIDA)
				oSecK260:Cell("QTD_SAIDA"	):setValue((aAlias[K260])->QTD_SAIDA)
				oSecK260:Cell("DT_RET"		):setValue((aAlias[K260])->DT_RET)
				oSecK260:Cell("QTD_RET"		):setValue((aAlias[K260])->QTD_RET)
				oSecK260:PrintLine()
				(aAlias[K260])->(dbSkip())
			EndDo
		EndIf
		oSecK260:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K265                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0102) //"REGISTRO K265 - Reprocessamento/Reparo - Mercadorias Consumidas e/ou Retornadas"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K265])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK26X")
				oReport:PrintText("Ponto de entrada REGK26X não compilado.")
			EndIf
		Else
			While !(aAlias[K265])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK265:Init()
				oSecK265:Cell("REG"			):setValue((aAlias[K265])->REG)
				oSecK265:Cell("COD_OP_OS"	):setValue((aAlias[K265])->COD_OP_OS)
				oSecK265:Cell("COD_ITEM"	):setValue((aAlias[K265])->COD_ITEM)
				oSecK265:Cell("QTD_CONS"	):setValue((aAlias[K265])->QTD_CONS)
				oSecK265:Cell("QTD_RET"		):setValue((aAlias[K265])->QTD_RET)
				oSecK265:PrintLine()
				(aAlias[K265])->(dbSkip())
			EndDo
		EndIf
		oSecK265:Finish()
		oReport:PrintText(" ")
	EndIf

	If  aAliProc[K270]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K270                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0103) //"REGISTRO K270 - Correção de Apontamento: K210, K220, K230, K250 e K260"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K270])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK27X")
				oReport:PrintText("Ponto de entrada REGK27X não compilado.")
			EndIf
		Else
			While !(aAlias[K270])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK270:Init()
				oSecK270:Cell("REG"			):setValue((aAlias[K270])->REG)
				oSecK270:Cell("DT_INI_AP"	):setValue((aAlias[K270])->DT_INI_AP)
				oSecK270:Cell("DT_FIN_AP"	):setValue((aAlias[K270])->DT_FIN_AP)
				oSecK270:Cell("COD_OP_OS"	):setValue((aAlias[K270])->COD_OP_OS)
				oSecK270:Cell("COD_ITEM"	):setValue((aAlias[K270])->COD_ITEM)
				oSecK270:Cell("QTD_COR_P"	):setValue((aAlias[K270])->QTD_COR_P)
				oSecK270:Cell("QTD_COR_N"	):setValue((aAlias[K270])->QTD_COR_N)
				oSecK270:Cell("ORIGEM"		):setValue((aAlias[K270])->ORIGEM)
				oSecK270:PrintLine()
				(aAlias[K270])->(dbSkip())
			EndDo
		EndIf
		oSecK270:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K275                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0104) //"REGISTRO K275 - Correção de Apontamento: K215, K220, K235, K255 e K265"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K275])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK27X")
				oReport:PrintText("Ponto de entrada REGK27X não compilado.")
			EndIf
		Else
			While !(aAlias[K275])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK275:Init()
				oSecK275:Cell("REG"			):setValue((aAlias[K275])->REG)
				oSecK275:Cell("COD_ITEM"	):setValue((aAlias[K275])->COD_ITEM)
				oSecK275:Cell("QTD_COR_P"	):setValue((aAlias[K275])->QTD_COR_P)
				oSecK275:Cell("QTD_COR_N"	):setValue((aAlias[K275])->QTD_COR_N)
				oSecK275:Cell("COD_INS_SU"	):setValue((aAlias[K275])->COD_INS_SU)
				oSecK275:PrintLine()
				(aAlias[K275])->(dbSkip())
			EndDo
		EndIf
		oSecK275:Finish()
		oReport:PrintText(" ")
	EndIf

	If aAliProc[K280]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K280                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText(STR0105) //"REGISTRO K280 - Correção de Apontamento - Estoque Escriturado"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K280])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK280")
				oReport:PrintText("Ponto de entrada REGK280 não compilado.")
			EndIf
		Else
			While !(aAlias[K280])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK280:Init()
				oSecK280:Cell("REG"			):setValue((aAlias[K280])->REG)
				oSecK280:Cell("DT_EST"		):setValue((aAlias[K280])->DT_EST)
				oSecK280:Cell("COD_ITEM"	):setValue((aAlias[K280])->COD_ITEM)
				oSecK280:Cell("QTD_COR_P"	):setValue((aAlias[K280])->QTD_COR_P)
				oSecK280:Cell("QTD_COR_N"	):setValue((aAlias[K280])->QTD_COR_N)
				oSecK280:Cell("IND_EST"		):setValue((aAlias[K280])->IND_EST)
				oSecK280:Cell("COD_PART"	):setValue((aAlias[K280])->COD_PART)
				oSecK280:PrintLine()
				(aAlias[K280])->(dbSkip())
			EndDo
		EndIf
		oSecK280:Finish()
		oReport:PrintText(" ")
	EndIf


	If aAliProc[K290]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K290                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K290 - Produção Conjunta - Ordem de Produção") //"REGISTRO K290 - Produção Conjunta - Ordem de Produção"
		oReport:ThinLine()
		oReport:PrintText(" ")

		While !(aAlias[K290])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK290:Init()
			oSecK290:Cell("REG"			):setValue((aAlias[K290])->REG)
			oSecK290:Cell("DT_INI_OP"	):setValue((aAlias[K290])->DT_INI_OP)
			oSecK290:Cell("DT_FIN_OP"	):setValue((aAlias[K290])->DT_FIN_OP)
			oSecK290:Cell("COD_DOC_OP"	):setValue((aAlias[K290])->COD_DOC_OP)
			oSecK290:PrintLine()
			(aAlias[K290])->(dbSkip())
		EndDo

		oSecK290:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K291                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K291 - Produção Conjunta - Itens Produzidos") //"REGISTRO K291 - Produção Conjunta - Itens Produzidos"
		oReport:ThinLine()
		oReport:PrintText(" ")

		While !(aAlias[K291])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK291:Init()
			oSecK291:Cell("REG"			):setValue((aAlias[K291])->REG)
			oSecK291:Cell("COD_DOC_OP"	):setValue((aAlias[K291])->COD_DOC_OP)
			oSecK291:Cell("COD_ITEM"	):setValue((aAlias[K291])->COD_ITEM)
			oSecK291:Cell("QTD"		    ):setValue((aAlias[K291])->QTD)
			oSecK291:PrintLine()
			(aAlias[K291])->(dbSkip())
		EndDo

		oSecK291:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K292                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K292 - Produção Conjunta - Insumos Consumidos") //"REGISTRO K292 - Produção Conjunta - Insumos Consumidos"
		oReport:ThinLine()
		oReport:PrintText(" ")

		While !(aAlias[K292])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK292:Init()
			oSecK292:Cell("REG"			):setValue((aAlias[K292])->REG)
			oSecK292:Cell("COD_DOC_OP"	):setValue((aAlias[K292])->COD_DOC_OP)
			oSecK292:Cell("COD_ITEM"	):setValue((aAlias[K292])->COD_ITEM)
			oSecK292:Cell("QTD"		    ):setValue((aAlias[K292])->QTD)
			oSecK292:PrintLine()
			(aAlias[K292])->(dbSkip())
		EndDo

		oSecK292:Finish()
		oReport:PrintText(" ")
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K300                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K300]
		oReport:PrintText("REGISTRO K300: PRODUCAO CONJUNTA - INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K300])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K300])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK300:Init()
				oSecK300:Cell("REG"			):setValue((aAlias[K300])->REG)
				oSecK300:Cell("DT_PROD"		):setValue((aAlias[K300])->DT_PROD)
				oSecK300:Cell("CHAVE"		):setValue((aAlias[K300])->CHAVE)
				oSecK300:PrintLine()
				(aAlias[K300])->(dbSkip())
			EndDo
		EndIf
		oSecK300:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K301                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K301: PRODUÇÃO CONJUNTA - INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS - ITENS PRODUZIDOS")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K301])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K301])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK301:Init()
				oSecK301:Cell("REG"			):setValue((aAlias[K301])->REG)
				oSecK301:Cell("COD_ITEM"	):setValue((aAlias[K301])->COD_ITEM)
				oSecK301:Cell("QTD"			):setValue((aAlias[K301])->QTD)
				oSecK301:Cell("CHAVE"		):setValue((aAlias[K301])->CHAVE)
				oSecK301:PrintLine()
				(aAlias[K301])->(dbSkip())
			EndDo
		EndIf
		oSecK301:Finish()
		oReport:PrintText(" ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K302                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K302: PRODUÇÃO CONJUNTA - INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS - ITENS CONSUMIDOS")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K302])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K302])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK302:Init()
				oSecK302:Cell("REG"			):setValue((aAlias[K302])->REG)
				oSecK302:Cell("COD_ITEM"	):setValue((aAlias[K302])->COD_ITEM)
				oSecK302:Cell("QTD"			):setValue((aAlias[K302])->QTD)
				oSecK302:Cell("CHAVE"		):setValue((aAlias[K302])->CHAVE)
				oSecK302:PrintLine()
				(aAlias[K302])->(dbSkip())
			EndDo
		EndIf
		oSecK302:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K990                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText(STR0074)//"REGISTRO K990 - Encerramento do Bloco K"
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K990])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K990])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK990:Init()
			oSecK990:Cell("REG"			):setValue((aAlias[K990])->REG)
			oSecK990:Cell("QTD_LIN_K"	):setValue((aAlias[K990])->QTD_LIN_K)
			oSecK990:PrintLine()
			(aAlias[K990])->(dbSkip())
		EndDo
	EndIf
	oSecK990:Finish()
	oReport:PrintText(" ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro 0210                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[0210]
		oReport:PrintText(STR0075)//"REGISTRO 0210 - Consumo Específico Padronizado"
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[0210])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[0210])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSec0210:Init()
				oSec0210:Cell("REG"			):setValue((aAlias[0210])->REG)
				oSec0210:Cell("COD_ITEM"	):setValue((aAlias[0210])->COD_ITEM)
				oSec0210:Cell("COD_I_COMP"	):setValue((aAlias[0210])->COD_I_COMP)
				oSec0210:Cell("QTD_COMP"  	):setValue((aAlias[0210])->QTD_COMP)
				oSec0210:Cell("PERDA"     	):setValue((aAlias[0210])->PERDA)
				oSec0210:PrintLine()
				(aAlias[0210])->(dbSkip())
			EndDo
		EndIf
		oSec0210:Finish()
		oReport:PrintText(" ")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro 0200                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText(STR0107)//"0200 Temporario - Produtos utilizados no Bloco K"
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[0200])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[0200])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSec0200:Init()
			oSec0200:Cell("COD_ITEM"):setValue((aAlias[0200])->COD_ITEM)
			cAliasOld := Alias()
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+(aAlias[0200])->COD_ITEM)
			oSec0200:Cell("B1_UM"	):setValue( SB1->B1_UM )
			If !Empty(cAliasOld)
				dbSelectArea(cAliasOld)
			EndIf
			oSec0200:PrintLine()
			(aAlias[0200])->(dbSkip())
		EndDo
	EndIf
	oSec0200:Finish()
	oReport:PrintText(" ")
	oReport:PrintText(STR0115)//"Configurações Utilizadas na Extração do Bloco K"
	oReport:ThinLine()
	BlkQryCfg(oReport)
	oReport:PrintText(" ")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos Temporarios    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BlkApgArq (aAlias)



Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BlkQryCfg
Query para coletar configurações utilizadas na geração do BlocoK
@author andre.maximo
@since 23/11/2018
@version 2.0
/*/
//-------------------------------------------------------------------

Function BlkQryCfg(oReport)
Local nCountTxt := 0
Local cQuery 	:= " "
Local cAliasTmp	:= GetNextAlias()
Local cTxt		:= " "

cQuery +="SELECT Max(R_E_C_N_O_)REC  "
cQuery +=	"FROM   "+RetSqlName("CV8")+" "
cQuery +=	"WHERE  CV8_MSG LIKE( 'Mensagem : Informações auxiliares%' ) "
cQuery +=			 " AND CV8_FILIAL = '"+xFilial('CV8')+"' "
cQuery +=			 " AND CV8_PROC	  = 'MATXSPED' "
cQuery +=			 " AND D_E_L_E_T_ = ' ' "
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

CV8->(dbGoTo((cAliasTmp)->REC))
cTxt:= CV8->CV8_DET

(cAliasTmp)->(dbCloseArea())

cTexto := ""
nPos := 0
nCountTxt := len(cTxt)
While len(cTxt) > 0
	nPos:= At(chr(10),cTxt)
	If nPos > 0
		cTexto := left(cTxt,nPos)
		oReport:PrintText(cTexto)
	Else
		cTexto := cTxt
		oReport:PrintText(cTexto)
	EndIf

    cTexto := Substr(cTxt,nPos+1,len(cTxt))
    cTxt := cTexto
    nCountTxt--
    If  nCountTxt <  0
    	Exit
    EndIf
EndDo

Return
