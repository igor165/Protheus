#Include "PROTHEUS.CH"
#Include "TMSR645.CH"

//+-------------------------------------------------------------------------- 
/*/{Protheus.doc} 
Description
Impressao do Picking List de Carregamento
@owner lucas.brustolin
@author lucas.brustolin
@since 16/07/2014
@param 
@return Nulo
@sample 
@project 
@menu Relatórios - Operacionais - Picking List 
@version P12
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function TMSR645()
Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

RestArea(aArea)

Return

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.
@owner lucas.brustolin
@author lucas.brustolin
@since 16/07/2014
@param 
@return Objeto do relatório
@sample 
@project 
@menu 
@version P12
@obs Obs
@history History
/*/  
//+--------------------------------------------------------------------------
Static Function ReportDef()
 
Local oReport
Local oProg
Local oVeiculo
Local oMotorista
Local oDocumento
Local oValores
Local oNotaFiscal
Local oAgendamento
Local oTotalGeral
Local oTotProg
Local oTotaliz
Local aAreaSM0  := SM0->(GetArea())
Local cAliasDF8 := GetNextAlias()
Local cAliasDT6 := GetNextAlias()
Local cAliasDYD := GetNextAlias()
Local lDTC_IDREM := DTC->(FieldPos("DTC_IDREM")) > 0
Local lDF8_SEQPRG:= DF8->(FieldPos("DF8_SEQPRG")) > 0

oReport := TReport():New("TMSR645",STR0002,"TMSR645", {|oReport| ReportPrint(oReport,cAliasDF8,cAliasDT6,cAliasDYD)},STR0001) //"Este programa irá emitir o Picking List para carregamento." -- "Picking List para carregamento"
oReport:SetLandscape()			//-- paisagem
oReport:HideParamPage()			//-- inibe impressao da pagina de parametros
oReport:SetTotalInLine(.F.)	//-- define se os totalizadores serao impressos em linha ou coluna

Pergunte("TMSR645",.F.)
//---------------------------------------------
// SEÇÃO PROGRAMACAO 
//---------------------------------------------
oProg := TRSection():New(oReport,STR0003,{"DF8"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //Programação
oProg:SetPageBreak(.T.)
oProg:SetTotalInLine(.F.)
TRCell():New(oProg,"DF8_FILORI"		,"DF8",STR0004,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fil.Ori."
TRCell():New(oProg,"DF8_VIAGEM"		,"DF8",STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Viagem"
TRCell():New(oProg,"DF8_NUMPRG"		,"DF8",STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Prog. Carreg."
If lDF8_SEQPRG
	TRCell():New(oProg,"DF8_SEQPRG"		,"DF8",STR0065,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Seq. Prog. Carreg."
EndIf	
TRCell():New(oProg,"STATUS"	       ,"   ",STR0066,/*Picture*/,10,/*lPixel*/,{|| cDescSta:= TMR645STA((cAliasDF8)->DF8_STATUS) }) //"Status Programação"
TRCell():New(oProg,"DF8_ROTA"		,"DF8",STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"ROTA"
//---------------------------------------------
// SEÇÃO VEICULO 
//---------------------------------------------
oVeiculo := TRSection():New(oProg,STR0008,{"DA3","DUT","DVB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Veiculo"
oVeiculo:SetTotalInLine(.F.)
TRCell():New(oVeiculo,"DA3_COD"			,"DA3",STR0008,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Veiculo"
TRCell():New(oVeiculo,"DA3_DESC"		,"DA3",STR0009,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descricao"
TRCell():New(oVeiculo,"DUT_DESCRI"		,"DUT",STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tip.Veic."
TRCell():New(oVeiculo,"DA3_CAPACM"		,"DA3",STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Capacidade"
TRCell():New(oVeiculo,"DA3_PLACA"		,"DA3",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Placa"
TRCell():New(oVeiculo,"DA3_MUNPLA"		,"DA3",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cidade Placa"
TRCell():New(oVeiculo,"DA3_ESTPLA"		,"DA3",STR0014,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Estado Placa"
TRCell():New(oVeiculo,"DVB_LACRE"		,"DA3",STR0015,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Lacres"
//---------------------------------------------
// SEÇÃO MOTORISTA 
//---------------------------------------------
oMotorista := TRSection():New(oVeiculo,STR0016,{"DA4"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Motorista"
oMotorista:SetTotalInLine(.F.)
TRCell():New(oMotorista,"DA4_COD"		,"DA4",STR0016,   /*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Motorista"
TRCell():New(oMotorista,"DA4_NREDUZ"	,"DA4",STR0017,   /*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nome Reduz."
TRCell():New(oMotorista,"DA4_NUMCNH"	,"DA4",STR0018,   /*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"CNH"
//---------------------------------------------
// SEÇÃO DOCUMENTO 
//---------------------------------------------
oDocumento := TRSection():New(oProg,STR0019,{"DT6","SA1","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Documentos"
oDocumento:SetTotalInLine(.F.)
oDocumento:SetLineBreak(.T.)
oDocumento:SetAutoSize(.T.) 

TRCell():New(oDocumento,"DT6_DOC"		,"DT6",,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->DT6_DOC } ) //Num. Docto
TRCell():New(oDocumento,"DT6_SERIE"	,"DT6",,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->DT6_SERIE } ) //Serie do Documento
TRCell():New(oDocumento,"DESCDOC"      ,"","Tp Docto",/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cRet := TMR645Pesq((cAliasDT6)->DT6_DOCTMS)} ) //Descr Tipo Docto
TRCell():New(oDocumento,"DT6_DATEMI"	,"DT6",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->DT6_DATEMI }) //"Emissão"
TRCell():New(oDocumento,"DUD_SEQENT"	,"DUD",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->SEQENT }) //"Seq.Entr"
// DADOS REMETENTE
// objeto   ,cName      		,cAlias,cTitle, cPicture  ,nSize      ,lPixel     ,bBlock ,cAlign  ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
TRCell():New(oDocumento,"A1_NREDUZ"		,"SA1",STR0023,/*Picture*/,15,/*lPixel*/,{|| (cAliasDT6)->NOMEREM }) //"Remetente"
TRCell():New(oDocumento,"A1_END"		,"SA1",STR0024,/*Picture*/,25,/*lPixel*/,{|| (cAliasDT6)->ENDREM }) //"Endereco"
TRCell():New(oDocumento,"A1_MUN"		,"SA1",STR0025,/*Picture*/,15,/*lPixel*/,{|| (cAliasDT6)->CIDREM }) //"Cidade"
TRCell():New(oDocumento,"A1_EST"		,"SA1",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->UFREM  }) //"UF"
TRCell():New(oDocumento,"A1_CEP"		,"SA1",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->CEPREM  }) //"CEPREM"


// DADOS DESTINATARIO
TRCell():New(oDocumento,"A1_NREDUZ"	,"SA1",STR0028,/*Picture*/,15,/*lPixel*/,{|| (cAliasDT6)->NOMEDES }) //"Destinatario"
TRCell():New(oDocumento,"A1_END"		,"SA1",STR0024,/*Picture*/,25 ,/*lPixel*/,{|| (cAliasDT6)->ENDDES } ) //"Endereco"
TRCell():New(oDocumento,"A1_MUN"		,"SA1",STR0025,/*Picture*/,15,/*lPixel*/,{|| (cAliasDT6)->CIDDES }) //"Cidade"
TRCell():New(oDocumento,"A1_EST"		,"SA1",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->UFDES  }) //"UF"
TRCell():New(oDocumento,"A1_CEP"		,"SA1",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDT6)->CEPDES }) //"CEPDES"

//---------------------------------------------
// SUB-SEÇÃO DA SEÇÃO DOCUMENTO - 
//---------------------------------------------
oValores	:= TRSection():New(oDocumento,STR0033,{"DT6","SA1","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //Valores
// DADOS QTD/VOL/PESO
TRCell():New(oValores,"DT6_QTDVOL"	,"DT6",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Volumes"
TRCell():New(oValores,"DT6_PESO"	,"DT6",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Real"
TRCell():New(oValores,"DT6_PESCOB"	,"DT6",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cob."
TRCell():New(oValores,"DT6_PESOM3"	,"DT6",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cub."
//DADOS VALOR MERC./TIPO/VAL.FRE./VAL.ICMS
TRCell():New(oValores,"DT6_VALMER"	,"DT6",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Merc."
TRCell():New(oValores,"DT6_TIPFRE"	,"DT6",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tipo"
TRCell():New(oValores,"DT6_FILORI"	,"DT6",STR0036,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Orig"
TRCell():New(oValores,"DFILORI" 	,""   ,STR0009,/*Picture*/,15/*Tamanho*/,/*lPixel*/, {|| Posicione("SM0",1,cEmpAnt+(cAliasDT6)->DT6_FILORI,"M0_FILIAL") } )
TRCell():New(oValores,"DT6_FILDES"	,"DT6",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dest"
TRCell():New(oValores,"DFILDES" 	,""   ,STR0009,/*Picture*/,15/*Tamanho*/,/*lPixel*/, {|| Posicione("SM0",1,cEmpAnt+(cAliasDT6)->DT6_FILDES,"M0_FILIAL") } )
TRCell():New(oValores,"DT6_VALFRE"	,"DT6",STR0038,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Vlr.Frete"
TRCell():New(oValores,"F2_VALFAT"	,"SF2",STR0039,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Valor.Fatura"
TRCell():New(oValores,"F2_BASEICM"	,"SF2",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Base p/ICMS"
TRCell():New(oValores,"F2_VALICM"	,"SF2",STR0041,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)//"Vlr.ICMS"
//---------------------------------------------
// SEÇÃO NOTA FISCAL 
//---------------------------------------------
oNotaFiscal := TRSection():New(oDocumento,STR0042,{"DTC","DUH","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Nota Fiscal"
oNotaFiscal:SetTotalInLine(.F.)
TRCell():New(oNotaFiscal,"DTC_NUMNFC"	,"DTC",STR0042,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
TRCell():New(oNotaFiscal,"DTC_SERNFC"	,"DTC",STR0043,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Serie"
TRCell():New(oNotaFiscal,"B1_DESC"		,"SB1",STR0044,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Diz Conter"
	If lDTC_IDREM
		TRCell():New(oNotaFiscal,"DTC_IDREM","DTC",STR0045,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Id. Remessa"
	EndIf
TRCell():New(oNotaFiscal,"DUH_LOCAL"	,"DUH",STR0046,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Armazem"
TRCell():New(oNotaFiscal,"DUH_LOCALI"	,"DUH",STR0024,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Endereco"
//-------------------
// SEÇÃO AGENDAMENTO|
//-------------------
oAgendamento	:= TRSection():New(oDocumento,STR0047,{"DYD"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //Agendamento
TRCell():New(oAgendamento,"NUMAGD"		,"DYD",STR0047,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasDYD)->NUMAGD  })//"Agendamento"
TRCell():New(oAgendamento,"DATAGD"		,"DYD",STR0048,/*"@R 99/99/9999"*/,/*Tamanho*/,/*lPixel*/,{|| STOD((cAliasDYD)->DATAGD) })//"Data Agd. Entr"
TRCell():New(oAgendamento,"INIAGD"		,"DYD",STR0049,"@R 99:99",/*Tamanho*/,/*lPixel*/,{|| (cAliasDYD)->INIAGD })//"Hora Agd. Entr"
//---------------------------------------------
// SEÇÃO TOTALIZADORES  
//---------------------------------------------
//-- Variaveis totalizadoras por pagina
//-- Totalizador Resumo do Picking List CIF
oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALMER"),"VALMER_CIF_PAG","SUM",/*oBreak*/,/*cTitle*//*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALFRE"),"VALFRE_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALFAT"),"VALNTRIB_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_BASEICM"),"VALTRIB_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALICM"),"VALICM_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_QTDVOL"),"QTDVOL_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESO"),"PESO_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESOM3"),"PESCUB_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESCOB"),"PESCOB_CIF_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oDocumento:Cell("DT6_DOC"),"QTDCTRC_CIF_PAG","COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

//-- Totalizador Resumo do prog FOB
oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALMER"),"VALMER_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALFRE"),"VALFRE_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALFAT"),"VALNTRIB_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_BASEICM"),"VALTRIB_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALICM"),"VALICM_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_QTDVOL"),"QTDVOL_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESO"),"PESO_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESOM3"),"PESCUB_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESCOB"),"PESCOB_FOB_PAG","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oDocumento:Cell("DT6_DOC"),"QTDCTRC_FOB_PAG","COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

//-- Variaveis prog - Total Geral
//-- Totalizador Resumo do prog CIF
oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALMER"),"VALMER_CIF","SUM",/*oBreak*/,/*cTitle*//*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALFRE"),"VALFRE_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALFAT"),"VALNTRIB_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_BASEICM"),"VALTRIB_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALICM"),"VALICM_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_QTDVOL"),"QTDVOL_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESO"),"PESO_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESOM3"),"PESCUB_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESCOB"),"PESCOB_CIF","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oDocumento:Cell("DT6_DOC"),"QTDCTRC_CIF","COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) })

//-- Totalizador Resumo do prog FOB
oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALMER"),"VALMER_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_VALFRE"),"VALFRE_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALFAT"),"VALNTRIB_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_BASEICM"),"VALTRIB_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("F2_VALICM"),"VALICM_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_QTDVOL"),"QTDVOL_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESO"),"PESO_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESOM3"),"PESCUB_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oValores:Cell("DT6_PESCOB"),"PESCOB_FOB","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

oTotaliz:=TRFunction():New(oDocumento:Cell("DT6_DOC"),"QTDCTRC_FOB","COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasDT6)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) })

//-- Secao Totalizadora - Resumo da Programacao
oTotProg := TRSection():New(oProg,STR0050,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Resumo Do Picking List"
oTotProg :SetHeaderSection()
TRCell():New(oTotProg,"TEXTO"		,"",STR0051,,7,/*lPixel*/,/*{|| code-block de impressao }*/) //"CIF"###"FOB"
TRCell():New(oTotProg,"VALMER"		,"",STR0052,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Mercadoria"
TRCell():New(oTotProg,"VALFRE"		,"",STR0053,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Frete"
TRCell():New(oTotProg,"VALTRIB"		,"",STR0054,,16,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Tributavel"
TRCell():New(oTotProg,"VALICMS"		,"",STR0055,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMS"
TRCell():New(oTotProg,"VOLUME"		,"",STR0056,,05,/*lPixel*/,/*{|| code-block de impressao }*/) //"Vols"
TRCell():New(oTotProg,"PESOREAL"	,"",STR0057,,11,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Real"
TRCell():New(oTotProg,"PESOCUB"		,"",STR0058,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cub."
TRCell():New(oTotProg,"PESOCOB"		,"",STR0059,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cob."
TRCell():New(oTotProg,"QTDCTRC"		,"",STR0060,,03,/*lPixel*/,/*{|| code-block de impressao }*/) //"CTRCs"


//-- Secao Totalizadora - Resumo Geral da Programacao
oTotalGeral := TRSection():New(oReport,STR0061,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Resumo Geral do Picking List"
oTotalGeral :SetHeaderSection()
TRCell():New(oTotalGeral,"TEXTO"	,"",STR0051,,7,/*lPixel*/,/*{|| code-block de impressao }*/) //"CIF"###"FOB"###"TOTAL"
TRCell():New(oTotalGeral,"VALMER"	,"",STR0052,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Mercadoria"
TRCell():New(oTotalGeral,"VALFRE"	,"",STR0053,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Frete"
TRCell():New(oTotalGeral,"VALTRIB"	,"",STR0054,,16,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Tributavel"
TRCell():New(oTotalGeral,"VALICMS"	,"",STR0055,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMS"
TRCell():New(oTotalGeral,"VOLUME"	,"",STR0056,,05,/*lPixel*/,/*{|| code-block de impressao }*/) //"Vols"
TRCell():New(oTotalGeral,"PESOREAL","",STR0057,,11,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Real"
TRCell():New(oTotalGeral,"PESOCUB"	,"",STR0058,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cub."
TRCell():New(oTotalGeral,"PESOCOB"	,"",STR0059,,14,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso Cob."
TRCell():New(oTotalGeral,"QTDCTRC"	,"",STR0060,,03,/*lPixel*/,/*{|| code-block de impressao }*/) //"CTRCs"


RestArea(aAreaSM0)

Return(oReport)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.
@owner lucas.brustolin
@author lucas.brustolin
@since 16/07/2014
@param Objeto Report do Relatório, Alias das secoes
@return Nulo
@sample 
@project 
@menu Relatórios - Operacionais - Picking List 
@version P12
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasDF8,cAliasDT6,cAliasDYD)

Local oProg      		:= oReport:Section(1)  
Local oVeiculo   		:= oReport:Section(1):Section(1) 				
Local oMotorista 		:= oReport:Section(1):Section(1):Section(1) 
Local oDocumento 		:= oReport:Section(1):Section(2)
Local oValores		:= oReport:Section(1):Section(2):Section(1)
Local oNotaFiscal  	:= oReport:Section(1):Section(2):Section(2)
Local oAgendamento 	:= oReport:Section(1):Section(2):Section(3)
Local oTotProg		:= oReport:Section(1):Section(3)
Local oTotGeral  		:= oReport:Section(2)

Local cAliasDA3  := ''
Local cAliasDA4  := ''
Local cAliasDTC  := ''
Local cCodVei    := ''
Local cFilNfc    := ''
Local cNumNfc    := ''
Local cSerNfc    := ''
Local cFilSF2    := ''
Local lDTC_IDREM := DTC->(FieldPos("DTC_IDREM")) > 0
Local cWhere     := ""

If Empty(xFilial('SF2'))
	cFilSF2:= "%'" + xFilial('SF2') + "'%"
Else
	cFilSF2:= "%DT6_FILDOC%"
EndIf

//-- Condicoes para impressão do relatorio
cWhere := "%"
cWhere += " AND DF8_STATUS <> '" + StrZero(9,Len(DF8->DF8_STATUS)) + "' "   //Status Cancelado  
cWhere += " AND EXISTS ( SELECT 1 FROM "    //Somente programacoes com DT6
cWhere += RetSQLName("DUD")+" DUD "
cWhere += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' " 
cWhere += " AND DUD_FILORI = DF8_FILORI "
cWhere += " AND DUD_VIAGEM = DF8_VIAGEM
cWhere += " AND DUD.D_E_L_E_T_= ' ' ) "
cWhere += " AND EXISTS ( SELECT 1 FROM "   
cWhere += RetSQLName("DTR")+" DTR "
cWhere += " WHERE DTR_FILIAL = '" + xFilial("DTR") + "' " 
cWhere += " AND DTR_FILORI = DF8_FILORI "
cWhere += " AND DTR_VIAGEM = DF8_VIAGEM
cWhere += " AND DTR_CODVEI BETWEEN '" + mv_par06 + "' "  
cWhere += " AND '" + mv_par07 + "' "
cWhere += " AND DTR.D_E_L_E_T_= ' ' ) "

cWhere += "%"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao Programação                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProg:BeginQuery()

	BeginSql Alias cAliasDF8
	
	SELECT DF8_FILORI, DF8_VIAGEM,DF8_NUMPRG, DF8_ROTA, DF8_STATUS , DF8_SEQPRG  
		FROM %table:DF8% DF8

		INNER JOIN %table:DTQ% DTQ ON
		DTQ_FILIAL = %xFilial:DTQ%
		AND DTQ_FILORI = DF8_FILORI
		AND DTQ_VIAGEM = DF8_VIAGEM
		AND DTQ_ROTA  BETWEEN %Exp:mv_par08% AND %Exp:mv_par09% 
		AND DTQ.%NotDel%
		
		WHERE DF8_FILIAL = %xFilial:DF8%
			AND DF8_FILORI = %Exp:mv_par01%
			AND DF8_VIAGEM BETWEEN %Exp:mv_par02% AND %Exp:mv_par03% 
			AND DF8_NUMPRG BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
			AND DF8.%NotDel%
			%Exp:cWhere%  //Somente Documento de Transporte (DT6) 
			
	EndSql

oProg:EndQuery(/*Array com os parametros do tipo Range*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao Veiculos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oVeiculo

	cAliasDA3 := GetNextAlias()

	BeginSql Alias cAliasDA3

		SELECT DA3_COD, DA3_DESC, DA3_PLACA, DA3_CAPACM, DA3_TIPVEI, DTR_FILIAL, DTR_FILORI,
				 DTR_VIAGEM, DTR_ITEM, DTR_CODVEI, DA3_MUNPLA, DA3_ESTPLA, DVB_LACRE

		FROM %table:DTR% DTR

		INNER JOIN %table:DA3% DA3 ON
		DA3_FILIAL  = %xFilial:DA3%
		AND DA3_COD = DTR_CODVEI
		AND DA3.%NotDel%

		LEFT JOIN %table:DVB% DVB ON
		DVB_FILIAL     = %xFilial:DVB%
		AND DVB_FILORI = DTR_FILORI
		AND DVB_VIAGEM = DTR_VIAGEM
		AND DVB_CODVEI = DTR_CODVEI
		AND DVB.%NotDel%

		WHERE DTR_FILIAL  = %xFilial:DTR%
			AND DTR_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
			AND DTR_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%
			AND DTR.%NotDel%

		UNION ALL

		SELECT DA3_COD, DA3_DESC, DA3_PLACA, DA3_CAPACM, DA3_TIPVEI, DTR_FILIAL, DTR_FILORI,
				 DTR_VIAGEM, DTR_ITEM, DTR_CODRB1 DTR_CODVEI, DA3_MUNPLA, DA3_ESTPLA, ' ' DVB_LACRE

		FROM %table:DTR% DTR

		INNER JOIN %table:DA3% DA3 ON
		DA3_FILIAL  = %xFilial:DA3%
		AND DA3_COD = DTR_CODRB1
		AND DA3.%NotDel%

		WHERE DTR_FILIAL  = %xFilial:DTR%
			AND DTR_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
			AND DTR_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%
			AND DTR.%NotDel%

		UNION ALL

		SELECT DA3_COD, DA3_DESC, DA3_PLACA, DA3_CAPACM, DA3_TIPVEI, DTR_FILIAL, DTR_FILORI,
				 DTR_VIAGEM, DTR_ITEM, DTR_CODRB2 DTR_CODVEI, DA3_MUNPLA, DA3_ESTPLA, ' ' DVB_LACRE

		FROM %table:DTR% DTR

		INNER JOIN %table:DA3% DA3 ON
		DA3_FILIAL  = %xFilial:DA3%
		AND DA3_COD = DTR_CODRB2
		AND DA3.%NotDel%

		WHERE DTR_FILIAL  = %xFilial:DTR%
			AND DTR_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
			AND DTR_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%
			AND DTR.%NotDel%
		
		UNION ALL
			
		SELECT DA3_COD, DA3_DESC, DA3_PLACA, DA3_CAPACM, DA3_TIPVEI, DTR_FILIAL, DTR_FILORI,
				DTR_VIAGEM, DTR_ITEM, DTR_CODRB3 DTR_CODVEI, DA3_MUNPLA, DA3_ESTPLA, ' ' DVB_LACRE

		FROM %table:DTR% DTR

		INNER JOIN %table:DA3% DA3 ON
		DA3_FILIAL  = %xFilial:DA3%
		AND DA3_COD = DTR_CODRB3
		AND DA3.%NotDel%

		WHERE DTR_FILIAL  = %xFilial:DTR%
			AND DTR_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
			AND DTR_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%
			AND DTR.%NotDel%

		ORDER BY DTR_FILIAL, DTR_ITEM

	EndSql

END REPORT QUERY oVeiculo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao Motoristas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oMotorista

	cAliasDA4 := GetNextAlias()

	BeginSql Alias cAliasDA4

		SELECT DA4_COD, DA4_NREDUZ, DA4_NUMCNH

		FROM %table:DA4% DA4, %table:DUP% DUP

		WHERE DA4_FILIAL  = %xFilial:DA4%
			AND DUP_CODMOT = DA4_COD
			AND DUP_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
			AND DUP_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%
			AND DUP.%NotDel%
			AND DA4.%NotDel%

	EndSql

END REPORT QUERY oMotorista

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao Documentos                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oDocumento


	BeginSql Alias cAliasDT6

		SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE,DT6_NUMAGD, DT6_DATEMI, DT6_DOCTMS,
		SA11.A1_NREDUZ NOMEREM, SA11.A1_INSCR INSCREM,  SA11.A1_END ENDREM, SA11.A1_MUN CIDREM, SA11.A1_EST UFREM, SA11.A1_CEP CEPREM,
		SA12.A1_NREDUZ NOMEDES, SA12.A1_INSCR INSCDES,  SA12.A1_END ENDDES, SA12.A1_MUN CIDDES, SA12.A1_EST UFDES, SA12.A1_CEP CEPDES,
		DUD.DUD_SEQENT SEQENT, DT6_QTDVOL, DT6_PESO, DT6_PESOM3, DT6_PESCOB, DT6_VALMER, DT6_TIPFRE, DT6_FILORI, DT6_FILDES, DT6_VALFRE,
		F2_VALFAT, F2_VALICM, (F2_VALFAT-F2_BASEICM) NTRIB, F2_BASEICM, F2_VALICM, 
		DYD.DYD_NUMAGD NUMAGD, DYD.DYD_DATAGD DATAGD
	
		FROM %table:DT6% DT6

		INNER JOIN %table:SA1% SA11 ON
		SA11.A1_FILIAL   = %xFilial:SA1%
		AND SA11.A1_COD  = DT6_CLIREM
		AND SA11.A1_LOJA = DT6_LOJREM
		AND SA11.%NotDel%

		INNER JOIN %table:SA1% SA12 ON
		SA12.A1_FILIAL   = %xFilial:SA1%
		AND SA12.A1_COD  = DT6_CLIDES
		AND SA12.A1_LOJA = DT6_LOJDES
		AND SA12.%NotDel%

		INNER JOIN %table:DUD% DUD ON
		DUD_FILIAL     = %xFilial:DUD%
		AND DUD_FILORI = %report_param:(cAliasDF8)->DF8_FILORI%
		AND DUD_VIAGEM = %report_param:(cAliasDF8)->DF8_VIAGEM%

		AND DUD_FILDOC = DT6_FILDOC
		AND DUD_DOC    = DT6_DOC
		AND DUD_SERIE  = DT6_SERIE
		AND DUD.%NotDel%

		INNER JOIN %table:SF2% SF2 ON
		F2_FILIAL    = %exp:cFilSF2%
		AND F2_DOC   = DT6_DOC
		AND F2_SERIE = DT6_SERIE
		AND SF2.%NotDel%
		
		LEFT JOIN %table:DYD% DYD ON
		DYD_FILIAL	     = %xFilial:DYD%
		AND DYD_NUMAGD = DT6_NUMAGD
		//AND DYD_ITEAGD = DT6_ITEAGD
		AND DYD.%NotDel%

		WHERE DT6_FILIAL = %xFilial:DT6%
			AND DT6.%NotDel%

	EndSql


END REPORT QUERY oDocumento

//-- Definir Query da seção PAI
oValores:SetParentQuery( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao Notas Fiscais e Enderecamentos              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oNotaFiscal

	cAliasDTC := GetNextAlias()
	
	If !lDTC_IDREM
		
		BeginSql Alias cAliasDTC
	
			SELECT DTC_FILORI, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM, DUH_LOCAL, DUH_LOCALI, B1_DESC
	
			FROM %table:DTC% DTC
	
			LEFT JOIN %table:DUH% DUH ON
			DUH_FILIAL = %xFilial:DUH%
			AND DUH_FILORI = DTC_FILORI
			AND DUH_NUMNFC = DTC_NUMNFC
			AND DUH_SERNFC = DTC_SERNFC
			AND DUH_CLIREM = DTC_CLIREM
			AND DUH_LOJREM = DTC_LOJREM
			AND DUH.%NotDel%
	
			INNER JOIN %table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DTC_CODPRO
			AND SB1.%NotDel%
	
			WHERE DTC_FILIAL = %xFilial:DTC%
				AND DTC_FILDOC = %report_param:(cAliasDT6)->DT6_FILDOC%
				AND DTC_DOC    = %report_param:(cAliasDT6)->DT6_DOC%
				AND DTC_SERIE  = %report_param:(cAliasDT6)->DT6_SERIE%
				AND DTC.%NotDel%
			UNION
			SELECT DY4_FILORI, DY4_NUMNFC, DY4_SERNFC, DY4_CLIREM, DY4_LOJREM, DUH_LOCAL, DUH_LOCALI, B1_DESC
			
			FROM %table:DY4% DY4
			
			LEFT JOIN %table:DUH% DUH ON
			DUH_FILIAL = %xFilial:DUH%
			AND DUH_FILORI = DY4_FILORI
			AND DUH_NUMNFC = DY4_NUMNFC
			AND DUH_SERNFC = DY4_SERNFC
			AND DUH_CLIREM = DY4_CLIREM
			AND DUH_LOJREM = DY4_LOJREM
			AND DUH.%NotDel%
			
			INNER JOIN %table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DY4_CODPRO
			AND SB1.%NotDel%
			
			WHERE DY4_FILIAL = %xFilial:DY4%
				AND DY4_FILDOC = %report_param:(cAliasDT6)->DT6_FILDOC%
				AND DY4_DOC    = %report_param:(cAliasDT6)->DT6_DOC%
				AND DY4_SERIE  = %report_param:(cAliasDT6)->DT6_SERIE%
				AND DY4.%NotDel%	
	
		EndSql
	Else		
		BeginSql Alias cAliasDTC
	
			SELECT DTC_FILORI, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM,DTC_IDREM, DUH_LOCAL, DUH_LOCALI, B1_DESC
	
			FROM %table:DTC% DTC
	
			LEFT JOIN %table:DUH% DUH ON
			DUH_FILIAL = %xFilial:DUH%
			AND DUH_FILORI = DTC_FILORI
			AND DUH_NUMNFC = DTC_NUMNFC
			AND DUH_SERNFC = DTC_SERNFC
			AND DUH_CLIREM = DTC_CLIREM
			AND DUH_LOJREM = DTC_LOJREM
			AND DUH.%NotDel%
	
			INNER JOIN %table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DTC_CODPRO
			AND SB1.%NotDel%
	
			WHERE DTC_FILIAL = %xFilial:DTC%
				AND DTC_FILDOC = %report_param:(cAliasDT6)->DT6_FILDOC%
				AND DTC_DOC    = %report_param:(cAliasDT6)->DT6_DOC%
				AND DTC_SERIE  = %report_param:(cAliasDT6)->DT6_SERIE%
				AND DTC.%NotDel%				
			UNION
			SELECT DY4_FILORI, DY4_NUMNFC, DY4_SERNFC, DY4_CLIREM, DY4_LOJREM, ' ' AS DTC_IDREM, DUH_LOCAL, DUH_LOCALI, B1_DESC
			
			FROM %table:DY4% DY4
			
			LEFT JOIN %table:DUH% DUH ON
			DUH_FILIAL = %xFilial:DUH%
			AND DUH_FILORI = DY4_FILORI
			AND DUH_NUMNFC = DY4_NUMNFC
			AND DUH_SERNFC = DY4_SERNFC
			AND DUH_CLIREM = DY4_CLIREM
			AND DUH_LOJREM = DY4_LOJREM
			AND DUH.%NotDel%
			
			INNER JOIN %table:SB1% SB1 ON
			B1_FILIAL = %xFilial:SB1%
			AND B1_COD = DY4_CODPRO
			AND SB1.%NotDel%
			
			WHERE DY4_FILIAL = %xFilial:DY4%
				AND DY4_FILDOC = %report_param:(cAliasDT6)->DT6_FILDOC%
				AND DY4_DOC    = %report_param:(cAliasDT6)->DT6_DOC%
				AND DY4_SERIE  = %report_param:(cAliasDT6)->DT6_SERIE%
				AND DY4.%NotDel%	
	
		EndSql	
	EndIf

END REPORT QUERY oNotaFiscal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao Agendamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oAgendamento

	BeginSql Alias cAliasDYD

		SELECT DYD.DYD_NUMAGD NUMAGD, DYD.DYD_DATAGD DATAGD, DYD.DYD_INIAGD INIAGD
	
		FROM %table:DYD% DYD

		WHERE DYD_FILIAL = %xFilial:DYD%
			AND DYD_NUMAGD = %report_param:(cAliasDT6)->DT6_NUMAGD%
			AND DYD.%NotDel%

	EndSql

END REPORT QUERY oAgendamento

TRPosition():New(oVeiculo,"DUT",1,{|| xFilial("DUT")+(cAliasDA3)->DA3_TIPVEI })





//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(DF8->(LastRec()))

dbSelectArea(cAliasDF8)
While !oReport:Cancel() .And. !(cAliasDF8)->(Eof())

	//-- Programacao
	oProg:Init()
	oProg:PrintLine()
	oProg:Finish()
		
	//-- Veiculos
	oVeiculo:ExecSql()
	dbSelectArea(cAliasDA3)
	oVeiculo:Init()
	While !oReport:Cancel() .And. !(cAliasDA3)->(Eof())
		cCodVei := (cAliasDA3)->DTR_CODVEI
		oVeiculo:PrintLine()
		dbSelectArea(cAliasDA3)
		(cAliasDA3)->(dbSkip())

		While (cAliasDA3)->DTR_CODVEI = cCodVei

			oVeiculo:Cell("DA3_COD"):Hide()
			oVeiculo:Cell("DA3_DESC"):Hide()
			oVeiculo:Cell("DUT_DESCRI"):Hide()
			oVeiculo:Cell("DA3_CAPACM"):Hide()
			oVeiculo:Cell("DA3_PLACA"):Hide()
			oVeiculo:Cell("DA3_MUNPLA"):Hide()
			oVeiculo:Cell("DA3_ESTPLA"):Hide()

			oVeiculo:PrintLine()

			dbSelectArea(cAliasDA3)
			(cAliasDA3)->(dbSkip())
		EndDo
		oVeiculo:Cell("DA3_COD"):Show()
		oVeiculo:Cell("DA3_DESC"):Show()
		oVeiculo:Cell("DUT_DESCRI"):Show()
		oVeiculo:Cell("DA3_CAPACM"):Show()
		oVeiculo:Cell("DA3_PLACA"):Show()
		oVeiculo:Cell("DA3_MUNPLA"):Show()
		oVeiculo:Cell("DA3_ESTPLA"):Show()
	EndDo
	oVeiculo:Finish()

	
	//Motoristas
	oMotorista:ExecSql()
	dbSelectArea(cAliasDA4)
	oMotorista:Init()
	While !oReport:Cancel() .And. !(cAliasDA4)->(Eof())
		
		oMotorista:PrintLine()

		dbSelectArea(cAliasDA4)
		(cAliasDA4)->(dbSkip())

	EndDo
	oMotorista:Finish()
	
	//-- CTRCs
	oDocumento:ExecSql()
	dbSelectArea(cAliasDT6)
	While !oReport:Cancel() .And. !(cAliasDT6)->(Eof())
		oDocumento:Init()
		oDocumento:PrintLine()
		
		//-- Valores
		oValores:Init()
		oValores:PrintLine()
		oValores:Finish()

		//-- Notas-Fiscais e Enderecamento
		oNotaFiscal:ExecSql()
		dbSelectArea(cAliasDTC)
		While !oReport:Cancel() .And. !(cAliasDTC)->(Eof())
			cFilNfc := (cAliasDTC)->DTC_FILORI
			cNumNfc := (cAliasDTC)->DTC_NUMNFC
			cSerNfc := (cAliasDTC)->DTC_SERNFC
			oNotaFiscal:Init()
			oNotaFiscal:PrintLine()

			dbSelectArea(cAliasDTC)
			(cAliasDTC)->(dbSkip())

			While (cAliasDTC)->(DTC_FILORI == cFilNfc .And. DTC_NUMNFC == cNumNfc .And. DTC_SERNFC == cSerNfc)

				oNotaFiscal:Cell("DTC_NUMNFC"):Hide()
				oNotaFiscal:Cell("DTC_SERNFC"):Hide()

				oNotaFiscal:PrintLine()
				dbSelectArea(cAliasDTC)
				(cAliasDTC)->(dbSkip())
			EndDo
			oNotaFiscal:Cell("DTC_NUMNFC"):Show()
			oNotaFiscal:Cell("DTC_SERNFC"):Show()
		EndDo
		oNotaFiscal:Finish()
		
		//--Agendamento
		oAgendamento:ExecSql()
		oAgendamento:Init()
		oAgendamento:PrintLine()
		oAgendamento:Finish()	

		oDocumento:Finish()

		dbSelectArea(cAliasDT6)
		(cAliasDT6)->(dbSkip())

	EndDo

	//-- Resumo por prog
	oTotProg:Init()
	oTotProg:Cell("TEXTO"):SetValue(STR0062) //"CIF"
	oTotProg:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_CIF_PAG"):ReportValue())
	oTotProg:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_CIF_PAG"):ReportValue())
	oTotProg:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_CIF_PAG"):ReportValue())
	oTotProg:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_CIF_PAG"):ReportValue())
	oTotProg:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_CIF_PAG"):ReportValue())
	oTotProg:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_CIF_PAG"):ReportValue())
	oTotProg:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_CIF_PAG"):ReportValue())
	oTotProg:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_CIF_PAG"):ReportValue())
	oTotProg:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_CIF_PAG"):ReportValue())
	oTotProg:PrintLine()

	oTotProg:Cell("TEXTO"):SetValue(STR0063) //"FOB"
	oTotProg:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_FOB_PAG"):ReportValue())
	oTotProg:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_FOB_PAG"):ReportValue())
	oTotProg:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_FOB_PAG"):ReportValue())
	oTotProg:PrintLine()

	oTotProg:Cell("TEXTO"):SetValue(STR0064) //"TOTAL"
	oTotProg:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_CIF_PAG"):ReportValue() + oValores:GetFunction("VALMER_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_CIF_PAG"):ReportValue() + oValores:GetFunction("VALFRE_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_CIF_PAG"):ReportValue()+oValores:GetFunction("VALTRIB_FOB_PAG"):ReportValue())
	oTotProg:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_CIF_PAG"):ReportValue()+ oValores:GetFunction("VALICM_FOB_PAG"):ReportValue())
	oTotProg:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_CIF_PAG"):ReportValue() + oValores:GetFunction("QTDVOL_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_CIF_PAG"):ReportValue() + oValores:GetFunction("PESO_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_CIF_PAG"):ReportValue()+ oValores:GetFunction("PESCUB_FOB_PAG"):ReportValue())
	oTotProg:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_CIF_PAG"):ReportValue()+ oValores:GetFunction("PESCOB_FOB_PAG"):ReportValue())
	oTotProg:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_CIF_PAG"):ReportValue()+ oDocumento:GetFunction("QTDCTRC_FOB_PAG"):ReportValue())
	oTotProg:PrintLine()
	oTotProg:Finish()
	

	//-- Zerar apos a impressao devido a quebra por programação
	oValores:GetFunction("VALMER_CIF_PAG"):ResetReport()
	oValores:GetFunction("VALFRE_CIF_PAG"):ResetReport()
	oValores:GetFunction("VALTRIB_CIF_PAG"):ResetReport()
	oValores:GetFunction("VALICM_CIF_PAG"):ResetReport()
	oValores:GetFunction("QTDVOL_CIF_PAG"):ResetReport()
	oValores:GetFunction("PESO_CIF_PAG"):ResetReport()
	oValores:GetFunction("PESCUB_CIF_PAG"):ResetReport()
	oValores:GetFunction("PESCOB_CIF_PAG"):ResetReport()
	oDocumento:GetFunction("QTDCTRC_CIF_PAG"):ResetReport()
	oValores:GetFunction("VALMER_FOB_PAG"):ResetReport()
	oValores:GetFunction("VALFRE_FOB_PAG"):ResetReport()
	oValores:GetFunction("VALTRIB_FOB_PAG"):ResetReport()
	oValores:GetFunction("VALICM_FOB_PAG"):ResetReport()
	oValores:GetFunction("QTDVOL_FOB_PAG"):ResetReport()
	oValores:GetFunction("PESO_FOB_PAG"):ResetReport()
	oValores:GetFunction("PESCUB_FOB_PAG"):ResetReport()
	oValores:GetFunction("PESCOB_FOB_PAG"):ResetReport()
	oDocumento:GetFunction("QTDCTRC_FOB_PAG"):ResetReport()
	

	dbSelectArea(cAliasDF8)
	(cAliasDF8)->(dbSkip())
	oReport:IncMeter()
EndDo

//-- Impressao do Resumo Geral da prog
oTotGeral:Init()
oTotGeral:Cell("TEXTO"):SetValue(STR0062) //"CIF"
oTotGeral:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_CIF"):ReportValue())
oTotGeral:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_CIF"):ReportValue())
oTotGeral:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_CIF"):ReportValue())
oTotGeral:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_CIF"):ReportValue())
oTotGeral:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_CIF"):ReportValue())
oTotGeral:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_CIF"):ReportValue())
oTotGeral:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_CIF"):ReportValue())
oTotGeral:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_CIF"):ReportValue())
oTotGeral:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_CIF"):ReportValue())
oTotGeral:PrintLine()

oTotGeral:Cell("TEXTO"):SetValue(STR0063) //"FOB"
oTotGeral:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_FOB"):ReportValue())
oTotGeral:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_FOB"):ReportValue())
oTotGeral:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_FOB"):ReportValue())
oTotGeral:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_FOB"):ReportValue())
oTotGeral:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_FOB"):ReportValue())
oTotGeral:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_FOB"):ReportValue())
oTotGeral:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_FOB"):ReportValue())
oTotGeral:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_FOB"):ReportValue())
oTotGeral:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_FOB"):ReportValue())
oTotGeral:PrintLine()

oTotGeral:Cell("TEXTO"):SetValue(STR0064) //"TOTAL"
oTotGeral:Cell("VALMER"):SetValue(oValores:GetFunction("VALMER_CIF"):ReportValue() + oValores:GetFunction("VALMER_FOB"):ReportValue())
oTotGeral:Cell("VALFRE"):SetValue(oValores:GetFunction("VALFRE_CIF"):ReportValue() + oValores:GetFunction("VALFRE_FOB"):ReportValue())
oTotGeral:Cell("VALTRIB"):SetValue(oValores:GetFunction("VALTRIB_CIF"):ReportValue() + oValores:GetFunction("VALTRIB_FOB"):ReportValue())
oTotGeral:Cell("VALICMS"):SetValue(oValores:GetFunction("VALICM_CIF"):ReportValue() + oValores:GetFunction("VALICM_FOB"):ReportValue())
oTotGeral:Cell("VOLUME"):SetValue(oValores:GetFunction("QTDVOL_CIF"):ReportValue() + oValores:GetFunction("QTDVOL_FOB"):ReportValue())
oTotGeral:Cell("PESOREAL"):SetValue(oValores:GetFunction("PESO_CIF"):ReportValue() + oValores:GetFunction("PESO_FOB"):ReportValue())
oTotGeral:Cell("PESOCUB"):SetValue(oValores:GetFunction("PESCUB_CIF"):ReportValue() + oValores:GetFunction("PESCUB_FOB"):ReportValue())
oTotGeral:Cell("PESOCOB"):SetValue(oValores:GetFunction("PESCOB_CIF"):ReportValue() + oValores:GetFunction("PESCOB_FOB"):ReportValue())
oTotGeral:Cell("QTDCTRC"):SetValue(oDocumento:GetFunction("QTDCTRC_CIF"):ReportValue() + oDocumento:GetFunction("QTDCTRC_FOB"):ReportValue())
oTotGeral:PrintLine()
oTotGeral:Finish()


Return


//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
@author Ramon Prado
@since 05/03/2015
@Obs Funcao que rertorna descrição do tipo de documento a partir do DocTms
@param Nulo
@return Nulo
@sample Samples
@project Projects
@menu Menu
@version Version
@history History
/*/
//+--------------------------------------------------------------------------
Static Function TMR645Pesq(cDocTms) 
Local cRet := TmsValField('DT6_DOCTMS',.F.)

Return cRet


//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
@author Ramon Prado
@since 05/03/2015
@Obs Funcao que rertorna descrição status da Programação
@param Nulo
@return Nulo
@sample Samples
@project Projects
@menu Menu
@version Version
@history History
/*/
//+--------------------------------------------------------------------------

Static Function TMR645STA(cStatusDF8)
Local aRetBox1    := {}
Local cRet        := ""

Default cStatusDF8:= ""

aRetBox1:= RetSx3Box( Posicione('SX3', 2, 'DF8_STATUS', 'X3CBox()' ),,, 1 )
cRet    := AllTrim( aRetBox1[ Ascan( aRetBox1, { |x| x[ 2 ] == cStatusDF8 } ) , 3 ] )

Return cRet
