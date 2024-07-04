#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR044.CH"
#INCLUDE "REPORT.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISR044

Relatório auxiliar TFRM/MG

@author
@since 24/11/2013
@version 11.80

/*/
//-------------------------------------------------------------------
Function FISR044()

Local oReport

DBSELECTAREA("SB1")
If TRepInUse()

	oReport	:= ReportDef()
	oReport:PrintDialog()

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
		
@return Nil
			
@author Cleber Maldonado
@since  24/11/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oRelat
Local oNomes
Local oBreak
Local cPerg := "FISR044"

oReport := TReport():New("FISR044",STR0001,"FISR044", {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:SetLandscape()

Pergunte("FISR044",.T.)

oQuadro:=TRSection():New(oReport,STR0001,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
oQuadro:SetHeaderSection(.T.)
oQuadro:SetHeaderPage(.T.)
oQuadro:SetHeaderBreak(.T.)
oQuadro:SetLeftMargin(20)

//Secao Relatorio
oRelat:=TRSection():New(oReport,STR0001,{"REL"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

If MV_PAR04 == 1
	TRCell():New(oRelat,"PRODUTO"		,"REL",STR0004,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"DESC"			,"REL",STR0024,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"UM"			,"REL",STR0005,"@!",2,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS1"		,"REL",STR0006,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS2"		,"REL",STR0007,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS3"		,"REL",STR0008,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS4"		,"REL",STR0009,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS5"		,"REL",STR0010,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS6"		,"REL",STR0011,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS7"		,"REL",STR0012,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS8"		,"REL",STR0013,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oRelat,"PRODUTO"		,"REL",STR0004,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"UM"			,"REL",STR0005,"@!",2,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"DESC"			,"REL",STR0024,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)	
	TRCell():New(oRelat,"CAMPOS1"		,"REL",STR0014,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS2"		,"REL",STR0015,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS3"		,"REL",STR0016,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS4"		,"REL",STR0017,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS5"		,"REL",STR0018,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/) 
	TRCell():New(oRelat,"CAMPOS6"		,"REL",STR0019,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS7"		,"REL",STR0020,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS8"		,"REL",STR0021,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS9"		,"REL",STR0022,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oRelat,"CAMPOS10"		,"REL",STR0023,"@E 99,999,999,999.99",14,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif

oReport:Section(1):SetHeaderPage(.T.)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

@param 	oReport   	-> Objeto TREPORT		
		
@return Nil
			
@author Cleber Maldonado
@since  24/11/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local dDtIni	:= MV_PAR01
Local dDtFim	:= MV_PAR02
Local nUM		:= MV_PAR03
Local nMov		:= MV_PAR04
Local cGrpIni	:= MV_PAR05
Local cGrpFim	:= MV_PAR06
Local cTesS4	:= SuperGetMV("MV_TFRMS4", .F., "")
Local cTesS5	:= SuperGetMV("MV_TFRMS5", .F., "")
Local cTesS6	:= SuperGetMV("MV_TFRMS6", .F., "")
Local cTesS7	:= SuperGetMV("MV_TFRMS7", .F., "")
Local cTesS8	:= SuperGetMV("MV_TFRMS8", .F., "")
Local cTesS9	:= SuperGetMV("MV_TFRMS9", .F., "")
Local cTesS10	:= SuperGetMV("MV_TFRMS10",.F., "")
Local cTesE1	:= SuperGetMV("MV_TFRME1", .F., "")
Local cTesE2	:= SuperGetMV("MV_TFRME2", .F., "")
Local cTesE3	:= SuperGetMV("MV_TFRME3", .F., "")
Local cTesE6	:= SuperGetMV("MV_TFRME6", .F., "")
Local cTesE7	:= SuperGetMV("MV_TFRME7", .F., "")
Local cTesE8	:= SuperGetMV("MV_TFRME8", .F., "")
Local oQuadro	:= oReport:Section(1)
Local oRelat	:= oReport:Section(2)
Local nTamVlr1	:= TamSX3("D2_QUANT")[1]
Local nTamVlr2	:= TamSX3("D2_QUANT")[2]
Local oTFont 	:= TFont():New('Arial',,11,,.T.)

aCampos:={{"PRODUTO"	,"C", TamSX3("B1_COD")[1],0},;
		  {"UM"			,"C", TamSX3("B1_UM")[1],0},;
		  {"DESC"		,"C", TamSX3("B1_DESC")[1],0},;
		  {"CAMPOS1"	,"N", 14,2},;
		  {"CAMPOS2"	,"N", 14,2},;
		  {"CAMPOS3"	,"N", 14,2},;
		  {"CAMPOS4"	,"N", 14,2},;
		  {"CAMPOS5"	,"N", 14,2},;
		  {"CAMPOS6"	,"N", 14,2},;
		  {"CAMPOS7"	,"N", 14,2},;
		  {"CAMPOS8"	,"N", 14,2},;
		  {"CAMPOS9"	,"N", 14,2},;
		  {"CAMPOS10"	,"N", 14,2}}

cArqRel := CriaTrab(aCampos)
dbUseArea(.F.,, cArqRel, "REL", .F., .F. )
IndRegua("REL",cArqRel,"PRODUTO")

If nMov == 1
	If nUm == 1
		Begin Report Query oQuadro

			cAliasREL	:=	GetNextAlias()

			BeginSql Alias cAliasREL

				SELECT
					D1_COD,D1_UM,D1_QUANT AS QUANT,D1_CF,D1_TES
				FROM
					%table:SD1% SD1
				WHERE
					SD1.D1_FILIAL = %xFilial:SD1%
					AND SD1.D1_DTDIGIT >= %exp:dDtIni%
					AND SD1.D1_DTDIGIT <= %exp:dDtFim%
					AND SD1.D1_GRUPO >= %exp:cGrpIni%
					AND SD1.D1_GRUPO <= %exp:cGrpFim%
					AND	SD1.%notDel%
			EndSql

		End Report Query oQuadro
	Else
		Begin Report Query oQuadro

			cAliasREL	:=	GetNextAlias()

			BeginSql Alias cAliasREL

				SELECT
					D1_COD,D1_UM,D1_SEGUM,D1_QTSEGUM AS QUANT,D1_CF,D1_TES
				FROM
					%table:SD1% SD1
				WHERE
					SD1.D1_FILIAL = %xFilial:SD1%
					AND SD1.D1_DTDIGIT >= %exp:dDtIni%
					AND SD1.D1_DTDIGIT <= %exp:dDtFim%
					AND SD1.D1_GRUPO >= %exp:cGrpIni%
					AND SD1.D1_GRUPO <= %exp:cGrpFim%
					AND	SD1.%notDel%
			EndSql

		End Report Query oQuadro
	Endif
Else
	If nUm == 1
		Begin Report Query oQuadro

			cAliasREL	:=	GetNextAlias()

			BeginSql Alias cAliasREL
				SELECT
					D2_COD,D2_UM,D2_SEGUM,D2_QUANT AS QUANT,D2_CF,D2_TES
				FROM
					%table:SD2% SD2
				WHERE
					SD2.D2_FILIAL = %xFilial:SD2%
					AND SD2.D2_EMISSAO >= %exp:dDtIni%
					AND SD2.D2_EMISSAO <= %exp:dDtFim%
					AND SD2.D2_GRUPO >= %exp:cGrpIni%
					AND SD2.D2_GRUPO <= %exp:cGrpFim%
					AND	SD2.%notDel%
			EndSql
		End Report Query oQuadro
	Else
		Begin Report Query oQuadro

			cAliasREL	:=	GetNextAlias()

			BeginSql Alias cAliasREL
				SELECT
					D2_COD,D2_UM,D2_SEGUM,D2_QTSEGUM AS QUANT,D2_CF,D2_TES
				FROM
					%table:SD2% SD2
				WHERE
					SD2.D2_FILIAL = %xFilial:SD2%
					AND SD2.D2_EMISSAO >= %exp:dDtIni%
					AND SD2.D2_EMISSAO <= %exp:dDtFim%
					AND SD2.D2_GRUPO >= %exp:cGrpIni%
					AND SD2.D2_GRUPO <= %exp:cGrpFim%
					AND	SD2.%notDel%
			EndSql
		End Report Query oQuadro
	Endif
Endif

Do While !(cAliasREL)->(Eof ())
	If nMov == 2
		IF !REL->(MsSeek((cAliasREL)->D2_COD))
			Reclock("REL",.T.)
			REL->PRODUTO	:= (cAliasREL)->D2_COD
			REL->DESC		:= Posicione("SB1",1,xFilial("SB1")+(cAliasREL)->D2_COD,"B1_DESC")
			REL->UM			:= IIF(nUm == 1,(cAliasREL)->D2_UM,(cAliasREL)->D2_SEGUM)
			REL->CAMPOS1	:= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			REL->CAMPOS2	:= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '6',(cAliasREL)->QUANT,0)
			REL->CAMPOS3	:= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '7',(cAliasREL)->QUANT,0)
			REL->CAMPOS4	:= IIF((cAliasREL)->D2_TES $ cTesS4,(cAliasREL)->QUANT,0)	
			REL->CAMPOS5	:= IIF((cAliasREL)->D2_TES $ cTesS5 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '6',(cAliasREL)->QUANT,0)
			REL->CAMPOS6	:= IIF((cAliasREL)->D2_TES $ cTesS6,(cAliasREL)->QUANT,0)
			REL->CAMPOS7	:= IIF((cAliasREL)->D2_TES $ cTesS7,(cAliasREL)->QUANT,0)
			REL->CAMPOS8	:= IIF((cAliasREL)->D2_TES $ cTesS8 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			REL->CAMPOS9	:= IIF((cAliasREL)->D2_TES $ cTesS9,(cAliasREL)->QUANT,0)
			REL->CAMPOS10	:= IIF((cAliasREL)->D2_TES $ cTesS10 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			MsUnLock()
		Else
			Reclock("REL",.F.)
			REL->CAMPOS1	+= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			REL->CAMPOS2	+= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '6',(cAliasREL)->QUANT,0)
			REL->CAMPOS3	+= IIF(SUBSTRING((cAliasREL)->D2_CF,1,1) == '7',(cAliasREL)->QUANT,0)
			REL->CAMPOS4	+= IIF((cAliasREL)->D2_TES $ cTesS4,(cAliasREL)->QUANT,0)
			REL->CAMPOS5	+= IIF((cAliasREL)->D2_TES $ cTesS5 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '6',(cAliasREL)->QUANT,0)
			REL->CAMPOS6	+= IIF((cAliasREL)->D2_TES $ cTesS6,(cAliasREL)->QUANT,0)
			REL->CAMPOS7	+= IIF((cAliasREL)->D2_TES $ cTesS7,(cAliasREL)->QUANT,0)
			REL->CAMPOS8	+= IIF((cAliasREL)->D2_TES $ cTesS8 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			REL->CAMPOS9	+= IIF((cAliasREL)->D2_TES $ cTesS9,(cAliasREL)->QUANT,0)
			REL->CAMPOS10	+= IIF((cAliasREL)->D2_TES $ cTesS10 .And. SUBSTRING((cAliasREL)->D2_CF,1,1) == '5',(cAliasREL)->QUANT,0)
			MsUnLock()
		Endif
	Else
		IF !REL->(MsSeek((cAliasREL)->D1_COD))
			Reclock("REL",.T.)
			REL->PRODUTO	:= (cAliasREL)->D1_COD
			REL->DESC		:= Posicione("SB1",1,xFilial("SB1")+(cAliasREL)->D1_COD,"B1_DESC")
			REL->UM			:= IIF(nUm == 1,(cAliasREL)->D1_UM,(cAliasREL)->D1_SEGUM)
			REL->CAMPOS1	:= IIF((cAliasREL)->D1_TES $ cTesE1,(cAliasREL)->QUANT,0)
			REL->CAMPOS2	:= IIF((cAliasREL)->D1_TES $ cTesE2,(cAliasREL)->QUANT,0)
			REL->CAMPOS3	:= IIF((cAliasREL)->D1_TES $ cTesE3,(cAliasREL)->QUANT,0)
			REL->CAMPOS4	:= IIF(SUBSTRING((cAliasREL)->D1_CF,1,1)  == '1',(cAliasREL)->QUANT,0)
			REL->CAMPOS5	:= IIF(SUBSTRING((cAliasREL)->D1_CF,1,1)  == '2',(cAliasREL)->QUANT,0)
			REL->CAMPOS6	:= IIF((cAliasREL)->D1_TES $ cTesE6 .And. SUBSTRING((cAliasREL)->D1_CF,1,1) == '2',(cAliasREL)->QUANT,0)
			REL->CAMPOS7	:= IIF((cAliasREL)->D1_TES $ cTesE7,(cAliasREL)->QUANT,0)
			REL->CAMPOS8	:= IIF((cAliasREL)->D1_TES $ cTesE8 .And. SUBSTRING((cAliasREL)->D1_CF,1,1) == '1',(cAliasREL)->QUANT,0)
			MsUnLock()
		Else
			Reclock("REL",.F.)
			REL->CAMPOS1	+= IIF((cAliasREL)->D1_TES $ cTesE1,(cAliasREL)->QUANT,0)
			REL->CAMPOS2	+= IIF((cAliasREL)->D1_TES $ cTesE2,(cAliasREL)->QUANT,0)
			REL->CAMPOS3	+= IIF((cAliasREL)->D1_TES $ cTesE3,(cAliasREL)->QUANT,0)
			REL->CAMPOS4	+= IIF(SUBSTRING((cAliasREL)->D1_CF,1,1) == '1',(cAliasREL)->QUANT,0)
			REL->CAMPOS5	+= IIF(SUBSTRING((cAliasREL)->D1_CF,1,1) == '2',(cAliasREL)->QUANT,0)
			REL->CAMPOS6	+= IIF((cAliasREL)->D1_TES $ cTesE6 .And. SUBSTRING((cAliasREL)->D1_CF,1,1) == '2',(cAliasREL)->QUANT,0)
			REL->CAMPOS7	+= IIF((cAliasREL)->D1_TES $ cTesE7,(cAliasREL)->QUANT,0)
			REL->CAMPOS8	+= IIF((cAliasREL)->D1_TES $ cTesE8 .And. SUBSTRING((cAliasREL)->D1_CF,1,1) == '1',(cAliasREL)->QUANT,0)
			MsUnLock()
		Endif
	Endif
	(cAliasREL)->(DbSkip())
End
oQuadro:Init()
oQuadro:Finish()
oReport:SkipLine(10)
oRelat:Print()
REL->(DbCloseArea())
FErase(cArqRel+GetDBExtension())
FErase(cArqRel+IndexExt())

Return
