#INCLUDE "TMSR600.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSR600   ³ Autor ³Rodolfo K. Rosseto     ³ Data ³25/05/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Contrato de Carreteiro por Periodo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSR600()

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oContrato
Local oDetalhes
Local cAliasDTY   := GetNextAlias()
Local cTipUso     := Iif(nModulo==43,"1","2")

If cTipUso == "1" //Viagem
	oReport := TReport():New("TMSR600",STR0001,"TMR600", {|oReport| ReportPrint(oReport,cAliasDTY,cTipUso)},STR0002) //"Contrato de Coleta e Entrega" ### "Este programa ira emitir o Contrato de Coleta e Entrega"
ElseIf cTipUso == "2" //--Carga
	oReport := TReport():New("TMSR600",STR0023,"TMR600", {|oReport| ReportPrint(oReport,cAliasDTY,cTipUso)},STR0024) //"Contrato Por Periodo" ### "Este programa ira emitir o Contrato por Perido"
EndIf
oReport:SetTotalInLine(.F.)
Pergunte("TMR600",.F.)

oContrato := TRSection():New(oReport,STR0003,{"DTY","SA2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Contrato"
oContrato:SetPageBreak(.T.)
oContrato:SetTotalInLine(.F.)

TRCell():New(oContrato,"DTY_NUMCTC"	,"DTY",STR0004,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nr. Contrato"
TRCell():New(oContrato,"DTY_DATCTC"	,"DTY",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dt.Contr."
TRCell():New(oContrato,"DTY_CODFOR"	,"DTY",STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Codigo"
TRCell():New(oContrato,"DTY_LOJFOR"	,"DTY",STR0006,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Loja"
TRCell():New(oContrato,"A2_NOME"		,"SA2",STR0007,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Proprietario"

If cTipUso == "1" //--Viagem
	oDetalhes := TRSection():New(oContrato,STR0008,{"DTQ","DTY"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Viagens"
ElseIf cTipUso == "2" //Carga
	oDetalhes := TRSection():New(oContrato,STR0025,{"DAK","DTY"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Cargas"
EndIf
oDetalhes:SetTotalInLine(.F.)
If cTipUso == "1" //--Viagem
	TRCell():New(oDetalhes,"DTQ_DATENC"	,"DTQ",STR0009/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
	TRCell():New(oDetalhes,"DTQ_SERTMS"	,"DTQ",STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||  }*/) //"Serv.Trans."
	TRCell():New(oDetalhes,"SERTMSDESC"	,"   ",STR0022,/*Picture*/,10/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasDTY+'->DTQ_SERTMS',.F.) }) //"Desc."
	TRCell():New(oDetalhes,"DTQ_TIPTRA"	,"DTQ",STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||  }*/) //"Tipo Transp."
	TRCell():New(oDetalhes,"TIPTRADESC"	,"   ",STR0022,/*Picture*/,10/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasDTY+'->DTQ_TIPTRA',.F.) }) //"Desc."
	TRCell():New(oDetalhes,"DTY_FILORI"	,"DTY",STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fil.Ori"
	TRCell():New(oDetalhes,"DTY_VIAGEM"	,"DTY",STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Viagem"
ElseIf cTipUso == "2" //Carga
	TRCell():New(oDetalhes,"DAK_COD"		,"DAK",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cod.Carga"
	TRCell():New(oDetalhes,"DAK_SEQCAR"	,"DAK",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Seq."
	TRCell():New(oDetalhes,"DAK_DTACCA"	,"DAK",STR0009,/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
	TRCell():New(oDetalhes,"SERTMS"		,""	,STR0010,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| "3" }) //"Serv.Trans."
	TRCell():New(oDetalhes,"SERTMSDESC"	,"   ",STR0022,/*Picture*/,10/*Tamanho*/,/*lPixel*/,{|| "Entrega" }) //"Desc."
	TRCell():New(oDetalhes,"TIPTRA"		,""	,STR0011,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| "1" }) //"Tipo Transp."
	TRCell():New(oDetalhes,"TIPTRADESC"	,"   ",STR0022,/*Picture*/,13/*Tamanho*/,/*lPixel*/,{|| "Rodoviário" }) //"Desc."
EndIf
TRCell():New(oDetalhes,"DTY_QTDVOL"	,"DTY",STR0014,PesqPict('DTY','DTY_INSS'),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd.Vol."
TRCell():New(oDetalhes,"DTY_QTDDOC"	,"DTY",STR0015,PesqPict('DTY','DTY_INSS'),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd.Doc."
TRCell():New(oDetalhes,"DTY_PESO"	,"DTY",STR0016,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peso"
TRCell():New(oDetalhes,"DTY_VALFRE"	,"DTY",STR0017,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Frete"
TRCell():New(oDetalhes,"DTY_IRRF"	,"DTY",STR0018,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"IRRF"
TRCell():New(oDetalhes,"DTY_SEST"	,"DTY",STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"SEST/SENAT"
TRCell():New(oDetalhes,"DTY_INSS"	,"DTY",STR0020,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"INSS"
TRCell():New(oDetalhes,"VALLIQ"		,"   ",STR0021,PesqPict('DTY','DTY_INSS'),/*Tamanho*/,/*lPixel*/,{|| (cAliasDTY)->DTY_VALFRE - (cAliasDTY)->DTY_IRRF - (cAliasDTY)->DTY_SEST - (cAliasDTY)->DTY_INSS }) //"Vl. Liquido"

TRFunction():New(oDetalhes:Cell("DTY_QTDVOL")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_QTDDOC")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_PESO")		,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_VALFRE")	,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_IRRF")		,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_SEST")		,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("DTY_INSS")		,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDetalhes:Cell("VALLIQ")			,,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Eduardo Riera          ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasDTY,cTipUso)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao Contrato                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()
If cTipUso == "1" //--Vaigem
	BeginSql Alias cAliasDTY

			SELECT DTY_NUMCTC, DTY_CODFOR, DTY_LOJFOR, DTY_FILORI, DTY_QTDVOL, DTY_QTDDOC, DTY_PESO, DTY_VALFRE,
					 DTY_IRRF, DTY_SEST, DTY_INSS, A2_NOME, DTQ_DATENC, DTQ_SERTMS, DTQ_TIPTRA, DTY_VIAGEM
	
		FROM %table:DTY% DTY

		JOIN %table:SA2% SA2 ON
	 	A2_FILIAL = %xFilial:SA2%
 		AND A2_COD = DTY_CODFOR
 		AND A2_LOJA = DTY_LOJFOR
 		AND SA2.%NotDel%

		JOIN %table:DTQ% DTQ ON
 		DTQ_FILIAL = %xFilial:DTQ%
 		AND DTQ_VIAGEM = DTY_VIAGEM
 		AND DTQ_SERTMS IN('1','3') //Somente Coleta e Entrega
 		AND DTQ.%NotDel%

		WHERE DTY_FILIAL = %xFilial:DTY%
			AND DTY_CODFOR >= %Exp:mv_par02%
			AND DTY_CODFOR <= %Exp:mv_par04%
			AND DTY_LOJFOR >= %Exp:mv_par03%
			AND DTY_LOJFOR <= %Exp:mv_par05%
			AND DTY.%NotDel%

			ORDER BY DTY_FILIAL, DTY_NUMCTC, DTQ_DATENC
			
	EndSql
ElseIf cTipUso == "2" //--Carga
	oReport:Section(1):BeginQuery()
	
		BeginSql Alias cAliasDTY
	
			SELECT DTY_NUMCTC, DTY_CODFOR, DTY_DATCTC, DTY_LOJFOR, DTY_FILORI, DTY_QTDVOL, DTY_QTDDOC, DTY_PESO, DTY_VALFRE,
					 DTY_IRRF, DTY_SEST, DTY_INSS, A2_NOME, DAK_COD, DAK_SEQCAR, DAK_DTACCA
					 
			FROM %table:DTY% DTY
	
			JOIN %table:SA2% SA2 ON
			A2_FILIAL   = %xFilial:SA2%
			AND A2_COD  = DTY_CODFOR
			AND A2_LOJA = DTY_LOJFOR
			AND SA2.%NotDel%
	 		
			JOIN %table:DAK% DAK ON
			DAK_FILIAL = %xFilial:DAK%
			AND DAK_IDENT  = DTY_IDENT
			AND DAK.%NotDel%
			
			WHERE DTY_FILIAL = %xFilial:DTY%
				AND DTY_CODFOR >= %Exp:mv_par02%
				AND DTY_CODFOR <= %Exp:mv_par04%
				AND DTY_LOJFOR >= %Exp:mv_par03%
				AND DTY_LOJFOR <= %Exp:mv_par05%
				AND DTY.%NotDel%	

			ORDER BY DTY_FILIAL, DTY_NUMCTC, DAK_DTACCA

		EndSql
EndIf

oReport:Section(1):EndQuery(MV_PAR01)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:SetMeter(DTY->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
If cTipUso == "1" //--Viagem
	oReport:Section(1):Section(1):SetParentFilter({ |cParam| DTY_NUMCTC == cParam },{ || (cAliasDTY)->DTY_NUMCTC })
ElseIf cTipUso == "2" //--Carga
	oReport:Section(1):Section(1):SetParentFilter({ |cParam| DTY_CODFOR+DTY_LOJFOR == cParam },{ || (cAliasDTY)->DTY_CODFOR+(cAliasDTY)->DTY_LOJFOR })
EndIf
oReport:Section(1):Print()

Return