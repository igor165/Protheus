#INCLUDE "LOJR540.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJR540
Relatorio de Comissao x Financeiro
@author  Varejo
@version 	P12.1.17
@since   	23/11/2017
@obs     
@sample LOJR540()
/*/
//-------------------------------------------------------------------

Function LOJR540()

Local oReport
Private cAliasQry := GetNextAlias()

Private cAlias    := cAliasQry

	oReport := ReportDef()
	oReport:PrintDialog()  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ³ReportDef
Relatorio de Comissao x Financeiro - Criação da estrutura do relatório
@param   	
@author  Varejo
@version 	P12.1.17
@since   	23/11/2017
@obs     
@sample ReportDef()
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oComissaoS
Local cVend  		:= ""
Local nBasePrt  	:= 0
Local nComPrt   	:= 0
Local nAc1			:= 0
Local nAc2			:= 0
Local nAc3      	:= 0
Local nAc4      	:= 0

oReport := TReport():New("LOJR540", STR0001, "LJR540", {|oReport| ReportPrint(oReport, cAliasQry, oComissaoS)}, STR0002)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte("LJR540",.F.)

oComissaoS := TRSection():New(oReport,STR0004,{"SE3","SA3"},{STR0003},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoS:SetTotalInLine(.F.)

TRCell():New(oComissaoS,"E3_VEND" ,"SE3" ,/*Titulo*/    ,/*Picture*/               	,/*Tamanho*/          	,/*lPixel*/	,{|| cVend })
TRCell():New(oComissaoS,"A3_NOME" ,"SA3" ,/*Titulo*/    ,/*Picture*/				,/*Tamanho*/          	,/*lPixel*/	,{|| SA3->A3_NOME })
TRCell():New(oComissaoS,"TOTALTIT",""    ,STR0005   	,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc3 })
TRCell():New(oComissaoS,"TOTALCOM",""    ,STR0006		,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{|| nAc4 })
TRCell():New(oComissaoS,"E3_BASE" ,cAlias,STR0007       ,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc1 })
TRCell():New(oComissaoS,"E3_COMIS",cAlias,STR0008       ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{|| nAc2 })
TRCell():New(oComissaoS,"E3_PORC" ,cAlias,STR0009       ,PesqPict('SE3','E3_PORC') 	,TamSx3("E3_PORC")[1] 	,/*lPixel*/	,{|| Round(((nAc2*100) / nAc1), TamSx3("E3_PORC")[2])})
TRCell():New(oComissaoS,"TOTALDIF",""    ,STR0010       ,PesqPict('SE3','E3_BASE')	,TamSx3("E3_BASE")[1]	,/*lPixel*/	,{|| nAc2 - nAc4 })

oReport:Section(1):SetHeaderPage()
oReport:Section(1):Setedit(.T.)

oComissaoS:Cell("TOTALTIT"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTALCOM"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTALDIF"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_BASE" ):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_PORC" ):SetHeaderAlign("RIGHT")

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Relatorio de Comissao x Financeiro - processamento do relatório
@param   oReport - Objeto Report
@param   cAliasQry - Alias Principal
@param	 oComissaoS - Objeto Section
@author  Varejo
@version 	P12.1.17
@since   	23/11/2017
@obs     
@sample ReportDef()
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasQry, oComissaoS)

Local cOrder     := ""
Local nTotPorc	 := 0
Local nTotPerVen := 0
Local nTotPerGer := 0

Local nTotBase	:= 0
Local nTotComis	:= 0
Local nSection	:= 0
Local nTGerBas  := 0
Local nTGerCom  := 0
Local cQuery    := ''
Local cAliasSE1 := "VENDSE1"
Local nCredito  := 0
Local lComiDev  := GetMV("MV_COMIDEV")
Local aDevVend  := {}
Local nPosVnd   := 0

TRFunction():New(oComissaoS:Cell("TOTALTIT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissaoS:Cell("TOTALCOM"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissaoS:Cell("E3_BASE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissaoS:Cell("E3_COMIS"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_COMIS'),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissaoS:Cell("E3_PORC"),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_PORC'),{||nTotPorc},.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissaoS:Cell("TOTALDIF"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)

nSection := 1
	
oReport:Section(nSection):Cell("TOTALTIT" ):SetBlock({|| nAc3 })		
oReport:Section(nSection):Cell("TOTALCOM" ):SetBlock({|| nAc4 })		
oReport:Section(nSection):Cell("E3_VEND"  ):SetBlock({|| cVend })		
oReport:Section(nSection):Cell("E3_BASE"  ):SetBlock({|| nAc1 })		
oReport:Section(nSection):Cell("E3_COMIS" ):SetBlock({|| nAc2 })		
oReport:Section(nSection):Cell("E3_PORC"  ):SetBlock({|| Round(((nAc2*100) / nAc1),TamSX3("E3_PORC")[2]) })		
oReport:Section(nSection):Cell("TOTALDIF" ):SetBlock({|| nAc4 - nAc2 })		

cVend		:= ""
nAc1		:= 0
nAc2		:= 0
nAc3		:= 0
nAc4        := 0

// Indexa de acordo com ordem
dbSelectArea("SE3")
dbSetOrder(2)   

cOrder := "%E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_TIPO, E3_PARCELA%"

// Buscar as devolucoes do periodo agrupadas por vendedor para MV_COMIDEV = .T.
If lComiDev
	aDevVend := L540DevVen()
Endif

//-------------------------------------------------------------------
// Query do relatório da secao 1                                     
//-------------------------------------------------------------------
MakeSqlExpr(oReport:uParam)	

oReport:Section(nSection):BeginQuery()

BEGIN REPORT QUERY oComissaoS
	BeginSql Alias cAliasQry
	SELECT E3_FILIAL,E3_BASE, E3_COMIS, E3_VEND, E3_PORC, A3_NOME, E3_PREFIXO,E3_NUM, E3_PARCELA,E3_TIPO,E3_CODCLI,E3_LOJA,E3_AJUSTE,E3_BAIEMI,E3_EMISSAO,E3_DATA, E3_SERIE
		FROM %table:SE3% SE3
		LEFT JOIN %table:SA3% SA3
	        ON A3_COD = E3_VEND
		WHERE A3_FILIAL = %xFilial:SA3%
			AND E3_FILIAL = %xFilial:SE3%

			AND	E3_EMISSAO >= %Exp:Dtos(MV_PAR01)%
			AND E3_EMISSAO <= %Exp:Dtos(MV_PAR02)%
			AND SE3.E3_VEND BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND E3_COMIS > 0 
			AND SA3.%NotDel%
			AND SE3.%notdel%
	ORDER BY %Exp:cOrder%
	EndSql
END REPORT QUERY oComissaoS 

oReport:Section(nSection):EndQuery()

TRPosition():New(oReport:Section(nSection),"SA3",1,{|| xFilial("SA3")+cVend })

//-------------------------------------------------------------------
// Inicio da impressao do fluxo do relatório                         
//-------------------------------------------------------------------
nTotBase	:= 0
nTotComis	:= 0

dbSelectArea("SE1")
dbSetOrder(1)

dbSelectArea("SE3")
dbSetOrder(2)

dbSelectArea(cAlias)
dbGoTop()

oReport:SetMeter(SE3->(LastRec()))
dbSelectArea(cAlias)
While !oReport:Cancel() .And. !&(cAlias)->(Eof())
	
	cVend := &(cAlias)->(E3_VEND)
	nAc1  := 0
	nAc2  := 0
	nAc3  := 0
	nAc4  := 0	
	nTotPerVen := 0
	nCredito   := 0

	oReport:Section(nSection):Init()
	
	// Acumula por vendedor os valores da SE3
	While !Eof() .And. xFilial("SE3") == (cAlias)->E3_FILIAL .And. (cAlias)->E3_VEND == cVend
		nBasePrt   := 0
		nComPrt    := 0
		
		SE3->(dbSeek(xFilial("SE3")+cVend+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA)))
				
		nBasePrt :=	(cAlias)->E3_BASE
		nComPrt  :=	(cAlias)->E3_COMIS
		
		nAc1 += nBasePrt
		nAc2 += nComPrt

		If Alltrim((cAlias)->E3_TIPO) == 'CR'
		   nCredito += nBasePrt
		Endif

		nTotPerVen += (nBasePrt*(cAlias)->E3_PORC)/100
		nTotPerGer += nTotPerVen

		dbSelectArea(cAlias)
		dbSkip()
	End
	
	nTotBase 	+= nAc1
	nTotComis 	+= nAc2
	nTotPorc	:= Round((nTotComis / nTotBase)*100,TamSx3("E3_COMIS")[2])
	nTotPerVen  := Round((nTotPerVen/nAc1)*100,TamSx3("E3_PORC")[2])

	cQuery := "SELECT SUM(E1_BASCOM1+E1_BASCOM2+E1_BASCOM3+E1_BASCOM4+E1_BASCOM5) TOTCOMIS"
	cQuery += " FROM "+RetSqlName('SE1')+" SE1 "
	cQuery += " WHERE E1_FILIAL = '"+xFilial('SE1')+"'" 	
	cQuery += " AND (E1_VEND1 = '"+cVend+"' OR E1_VEND2 = '"+cVend+"' OR E1_VEND3 = '"+cVend+"' OR E1_VEND4 = '"+cVend+"' OR E1_VEND5 = '"+cVend+"')"
	cQuery += " AND E1_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'"
	cQuery += " AND E1_TIPO <> 'CR'"

	If lComiDev
	   cQuery += " AND E1_TIPO <> 'NCC'"	
	Endif

	cQuery += " AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.F.)

	If !((cAliasSE1)->(Eof()))
		nAc3  += ((cAliasSE1)->TOTCOMIS + nCredito)
		
		If lComiDev .AND. Len(aDevVend) > 0   // Abate do valor financeiro as devolucoes do vendedor no periodo
			nPosVnd := aScan(aDevVend, {|x| x[1] == cVend})

			If nPosVnd > 0
				nAc3 -= aDevVend[nPosVnd, 2]
			Endif
		Endif

		nAc4  := If(nAc1 == nAc3, nAc2, (nAc3*(nTotPerVen/100)))
	Endif

	(cAliasSE1)->(DbCloseArea())

	oReport:Section(nSection):Init()				
	oReport:Section(nSection):PrintLine()

	oReport:Section(nSection):Finish()
	
	oReport:IncMeter()
		
	nTGerBas    += nAc1
    nTGerCom    += nAc2	
EndDo

nTotPorc := ((nTGerCom*100)/nTGerBas) 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} L540DevVen
Relatorio de Comissao x Financeiro - buscar as devolucoes no periodo por vendedor
@Retorno Array com as devolucoes no periodo por vendedor
@author  Varejo
@version 	P12.1.17
@since   	13/12/2017
@obs     
@sample L540DevVen()
/*/
//-------------------------------------------------------------------
Static Function L540DevVen()
Local aRet      := {}
Local aArea     := GetArea()
Local cAliasDEV := "VENDDEV"
Local cQuery    := ''
Local nPosVnd   := 0
Local nI        := 0
Local cVend     := ''

	SD2->(DbSetOrder(3))	
	SF2->(DbSetOrder(1))	

	cQuery := "SELECT D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_NFORI, D1_SERIORI, D1_ITEMORI, D1_COD, D1_TOTAL"
	cQuery += " FROM "+RetSqlName('SD1')+" SD1 "
	cQuery += " WHERE D1_FILIAL = '"+xFilial('SD1')+"'" 	
	cQuery += " AND D1_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"'"
    cQuery += " AND D1_TIPO = 'D'"	
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery += " ORDER BY D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDEV,.F.,.F.)

	While !(cAliasDEV)->(Eof())
		If SD2->(DbSeek(xFilial('SD2')+(cAliasDEV)->D1_NFORI+(cAliasDEV)->D1_SERIORI+(cAliasDEV)->D1_FORNECE+(cAliasDEV)->D1_LOJA+(cAliasDEV)->D1_COD+(cAliasDEV)->D1_ITEMORI))
			If SF2->(DbSeek(xFilial('SF2')+(cAliasDEV)->D1_NFORI+(cAliasDEV)->D1_SERIORI+(cAliasDEV)->D1_FORNECE+(cAliasDEV)->D1_LOJA))			
				For nI := 1 to 5
					cVend := &("SF2->F2_VEND"+Str(nI,1))

					If !Empty(cVend)
						nPosVnd := aScan(aRet, {|x| x[1] == cVend})

						If nPosVnd > 0
							aRet[nPosVnd, 2] += (cAliasDEV)->D1_TOTAL
						Else
							Aadd(aRet, {cVend, (cAliasDEV)->D1_TOTAL})
						Endif	
					Endif
				Next				
			Endif
		Endif

		(cAliasDEV)->(DbSkip())
	End

(cAliasDEV)->(DbCloseArea())

RestArea(aArea)

Return aRet