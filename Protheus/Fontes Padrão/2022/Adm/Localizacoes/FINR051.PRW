#INCLUDE "FINR051.ch"
#include "protheus.ch"
#include "report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR051   ºAutor  ³Bruno Sobieski      º Data ³  08/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de comprovantes de detracciones PERU              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FINR051()
Local oReport
Local oSA2
Local oSE2
Private cAlias := GetNextAlias()

Pergunte("FINR051",.F.)

DEFINE REPORT oReport NAME "FINR051" TITLE STR0001 PARAMETER "FINR051" ACTION {|oReport| PrintReport(cAlias,oReport)} //"Detrações"

	DEFINE SECTION oSA2 OF oReport TITLE STR0002 TABLES "SA2","SE2" ORDERS {STR0003,STR0004,STR0005,STR0006} //"Títulos de detração"###'Emissão'###'Baixa'###'Data depósito'###'Nro comprovante'

		DEFINE CELL NAME "A2_COD" OF oSA2 ALIAS "SA2"
		DEFINE CELL NAME "A2_LOJA" OF oSA2 ALIAS "SA2"
		DEFINE CELL NAME "A2_NOME" OF oSA2 ALIAS "SA2"

		DEFINE CELL NAME "E2_NUM" OF oSA2 ALIAS "SE2"
		DEFINE CELL NAME "E2_PREFIXO" OF oSA2 ALIAS "SE2"
		DEFINE CELL NAME "E2_TIPO"  OF oSA2 ALIAS "SE2"
		DEFINE CELL NAME "E2_EMIS1" OF oSA2 ALIAS "SE2"
		DEFINE CELL NAME "E2_BAIXA" OF oSA2 ALIAS "SE2"
		DEFINE CELL NAME "E2_VALOR" OF oSA2 BLOCK {|| (cAlias)->E2_VALOR * Iif((cAlias)->E2_TIPO=="TXA",-1,1) } ALIAS "SE2"

		DEFINE CELL NAME "FE_EMISSAO" OF oSA2 TITLE STR0007 ALIAS "SFE" //"Dt. Deposito"
		DEFINE CELL NAME "FE_CERTDET" OF oSA2 ALIAS "SFE"

		DEFINE FUNCTION FROM oSA2:Cell("E2_VALOR") FUNCTION SUM

		oBreak	:=	TRBreak():New ( oSA2, {|| E2_FORNECE } , STR0008 , .f. /*[ lTotalInLine ]*/)  //'Total fornecedor'
		TRFunction():New(oSA2:Cell("E2_VALOR"),"","SUM",oBreak,,,,.F.,.F.)



oReport:PrintDialog()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor   ³Bruno Sobieski      º Data ³  08/18/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Endereçamento para funcao de impressao                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(cAlias,oReport)

#IFDEF TOP
	Local cChave
	Local nOrder := oReport:Section(1):GetOrder()
	If mv_par11 > 2
  		oReport:Section(1):Cell("FE_CERTDET"):Hide()
  		oReport:Section(1):Cell("FE_CERTDET"):SetTitle('')
  		oReport:Section(1):Cell("FE_CERTDET"):SetSize(0)
  		oReport:Section(1):Cell("FE_EMISSAO"):Hide()
  		oReport:Section(1):Cell("FE_EMISSAO"):SetTitle('')
  		oReport:Section(1):Cell("FE_EMISSAO"):SetSize(0)
	Endif
	If nOrder == 1
		cChave	:="%A2_COD,A2_LOJA,E2_EMIS1,E2_TIPO,E2_PREFIXO,E2_NUM%"
	ElseIf nOrder == 2
		cChave	:="%A2_COD,A2_LOJA,E2_BAIXA,E2_TIPO,E2_PREFIXO,E2_NUM%"
	ElseIf	nOrder == 3
		cChave	:="%A2_COD,A2_LOJA,FE_EMISSAO,FE_CERTDET%"
	ElseIf	nOrder == 4
		cChave	:="%A2_COD,A2_LOJA,FE_CERTDET,FE_EMISSAO%"
	Endif
	MakeSqlExp("FINR051")
BEGIN REPORT QUERY oReport:Section(1)
If mv_par11 == 1

	BeginSql alias cAlias
		SELECT A2_COD,A2_LOJA,A2_NOME, E2_FORNECE,E2_LOJA,E2_EMIS1,E2_PREFIXO, E2_TIPO, E2_NUM, E2_VALOR , E2_BAIXA, FE_CERTDET , FE_EMISSAO
		FROM %table:SA2% SA2, %table:SE2% SE2
		LEFT JOIN %table:SFE% SFE ON  (
			FE_FILIAL =  %xfilial:SFE% AND
			FE_FORNECE = E2_FORNECE AND
			FE_LOJA = E2_LOJA AND
			FE_NFISCAL = E2_NUM AND
			FE_SERIE = E2_PREFIXO AND
			FE_ESPECIE = E2_TIPO AND
			FE_PARCELA = E2_PARCELA AND
			FE_TIPO = 'D' AND
			SFE.%notDel% )

		WHERE A2_FILIAL = %xfilial:SA2% AND SA2.%notDel% AND
			E2_FILIAL = %xfilial:SE2% AND SE2.%notDel% AND
			E2_NATUREZ = %EXP:mv_par12% AND
			E2_FORNECE = A2_COD AND
			E2_LOJA = A2_LOJA AND
			A2_COD >= %exp:mv_par01% AND
			A2_LOJA>= %exp:mv_par02% AND
			A2_COD <= %exp:mv_par03% AND
			A2_LOJA<= %exp:mv_par04% AND
			E2_EMIS1 BETWEEN %exp:mv_par05 % AND %exp:mv_par06 %  AND
			E2_TIPO  IN ('TX ','TXA')

		ORDER BY %Exp:cChave%
	EndSql
ElseIf mv_par11 == 2
	BeginSql alias cAlias
		SELECT A2_COD,A2_LOJA,A2_NOME, E2_FORNECE,E2_LOJA,E2_PREFIXO, E2_EMIS1,E2_TIPO, E2_NUM, E2_VALOR , E2_BAIXA, FE_CERTDET , FE_EMISSAO
		FROM %table:SA2% SA2, %table:SE2% SE2,%table:SFE% SFE
		WHERE A2_FILIAL = %xfilial:SA2% AND SA2.%notDel% AND
			E2_FILIAL = %xfilial:SE2% AND SE2.%notDel% AND
			E2_FORNECE = A2_COD AND
			E2_NATUREZ = %EXP:mv_par12% AND
			E2_LOJA = A2_LOJA AND
			A2_COD >= %exp:mv_par01% AND
			A2_LOJA>= %exp:mv_par02% AND
			A2_COD <= %exp:mv_par03% AND
			A2_LOJA<= %exp:mv_par04% AND
			E2_EMIS1 BETWEEN %exp:mv_par05 % AND %exp:mv_par06 %  AND
			E2_TIPO  IN ('TX ','TXA') AND
			FE_FILIAL =  %xfilial:SFE% AND
			FE_FORNECE = E2_FORNECE AND
			FE_LOJA = E2_LOJA AND
			FE_NFISCAL = E2_NUM AND
			FE_SERIE = E2_PREFIXO AND
			FE_TIPO = 'D' AND
			FE_ESPECIE = E2_TIPO AND
			FE_PARCELA = E2_PARCELA AND

			FE_EMISSAO 	BETWEEN %exp:mv_par07% AND %exp:mv_par08% AND
			FE_CERTDET BETWEEN %exp:mv_par09% AND %exp:mv_par10% AND
			SFE.%notDel%

		ORDER BY %Exp:cChave%
	EndSql
ElseIf mv_par11 == 3
	//Os D_E_L_E_T_ para FE_CERTDET e para fe_emissao sao pois o embedded nao suporta o comando "'' as campo"
	BeginSql alias cAlias
		SELECT A2_COD,A2_LOJA,A2_NOME, E2_FORNECE,E2_LOJA,E2_PREFIXO, E2_EMIS1,E2_TIPO, E2_NUM, E2_VALOR , E2_BAIXA, SA2.D_E_L_E_T_  FE_CERTDET , SA2.D_E_L_E_T_  FE_EMISSAO
		FROM %table:SA2% SA2, %table:SE2% SE2
		WHERE A2_FILIAL = %xfilial:SA2% AND SA2.%notDel% AND
			E2_FILIAL = %xfilial:SE2% AND SE2.%notDel% AND
			E2_FORNECE = A2_COD AND
			E2_LOJA = A2_LOJA AND
			E2_NATUREZ = %EXP:mv_par12% AND
			A2_COD >= %exp:mv_par01% AND
			A2_LOJA>= %exp:mv_par02% AND
			A2_COD <= %exp:mv_par03% AND
			A2_LOJA<= %exp:mv_par04% AND
			E2_EMIS1 BETWEEN %exp:mv_par05 % AND %exp:mv_par06 %  AND
			E2_TIPO  IN ('TX ','TXA') AND
			E2_BAIXA = ' '

		ORDER BY %Exp:cChave%
	EndSql
ElseIf mv_par11 == 4
	BeginSql alias cAlias
		SELECT A2_COD,A2_LOJA,A2_NOME, E2_FORNECE,E2_LOJA,E2_PREFIXO, E2_EMIS1,E2_TIPO, E2_NUM, E2_VALOR , E2_BAIXA, SA2.D_E_L_E_T_  FE_CERTDET , SA2.D_E_L_E_T_  FE_EMISSAO
		FROM %table:SA2% SA2, %table:SE2% SE2
		WHERE A2_FILIAL = %xfilial:SA2% AND SA2.%notDel% AND
			E2_FILIAL = %xfilial:SE2% AND SE2.%notDel% AND
			E2_FORNECE = A2_COD AND
			E2_NATUREZ = %EXP:mv_par12% AND
			E2_LOJA = A2_LOJA AND
			A2_COD >= %exp:mv_par01% AND
			A2_LOJA>= %exp:mv_par02% AND
			A2_COD <= %exp:mv_par03% AND
			A2_LOJA<= %exp:mv_par04% AND
			E2_EMIS1 BETWEEN %exp:mv_par05 % AND %exp:mv_par06 %  AND
			E2_TIPO  IN ('TX ','TXA') AND
			E2_BAIXA <> ' '  AND
				(SELECT COUNT(*) FROM  %table:SFE% SFE
					WHERE FE_FILIAL =  %xfilial:SFE% AND
					FE_FORNECE = E2_FORNECE AND
					FE_LOJA = E2_LOJA AND
					FE_PARCELA = E2_PARCELA AND
					FE_NFISCAL = E2_NUM AND
					FE_SERIE = E2_PREFIXO AND
					FE_TIPO = 'D' AND
					FE_ESPECIE = E2_TIPO AND
					SFE.%notDel%) = 0

		ORDER BY %Exp:cChave%
	EndSql
Endif
END REPORT QUERY oReport:Section(1)

oReport:Section(1):Print()
#ENDIF
Return
