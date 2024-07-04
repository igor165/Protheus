#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR028
Relatorio Conferencia Estorno Credito PIS/COFINS IPI

@author Flavio Luiz Vicco
@since 19/02/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISR028()
Local oReport
Local cMsgX1	:= ""
Local lContinua	:= .T.
Local oTable	:= NIL

Private cAliasNF := ""
Private cArqRel  := ""
Private oTempR028 := ""

If FindFunction("RetNFOri")
	If Pergunte("FISR028",.T.)
		cMsgX1 := VldSx1()
		If Len(Alltrim(cMsgX1)) > 0
			Help(" ",1,"Help","Help",cMsgX1,1,0)
			lContinua := .F.
		EndIf
		If lContinua
			oReport:=ReportDef("FISR028",@oTable)
			oReport:PrintDialog()
		EndIf
	EndIf
Else
	Help(" ",1,"Help","Help","Atualizar patch do programa SIGACUS.PRW !!!",1,0)
EndIf

//Limpeza de arquivos temporarios
If ValType(oTempR028) == "O"
	oTempR028:Delete()
EndIf
If ValType(oTable) == "O"
	oTable:Delete()
ElseIf (cAliasNF) <> ""
	(cAliasNF)->(DbCloseArea())
EndIF

Return

//+------------------------------------------------------------------
//! Rotina para montagem dos dados do relatório.
//+------------------------------------------------------------------
Static Function ReportPrint(oReport,oTable)
Local oRelat1 := oReport:Section(1)
Local oRelat2 := oReport:Section(2)

oRelat1:Print()
oRelat2:Print()

Return

//+------------------------------------------------------------------
//! Função para criação da estrutura do relatório.
//+------------------------------------------------------------------
Static Function ReportDef(cPerg,oTable)
Local cTitle  := "Listagem Conferência Estorno de Crédito de ICMS, PIS/Cofins e IPI."
Local cHelp   := "Listagem dos documentos fiscais isentos para conferencia do estorno do credito de ICMS, PIS/Cofins e IPI."
Local oReport
Local oSection1
Local oSection2

//Criacao da tabela temporaria utlizada no relatorio
SelRelR028(@oTable)

oReport := TReport():New("FISR028",cTitle,cPerg,{|oReport|ReportPrint(oReport,@oTable)},cHelp)
oReport:SetLandscape()
oReport:HideParamPage()
oReport:ParamReadOnly(.T.)
oReport:DisableOrientation()

oSection1 := TRSection():New(oReport,"Notas Fiscais Vendas",{"REL"})
TRCell():New(oSection1,"PRODUTO"  ,"REL"   ,"Produto"	,,TamSX3("FT_PRODUTO")[1])
TRCell():New(oSection1,"DESCR"     ,"REL"   ,"Descric"	,,TamSX3("B1_DESC"   )[1],,{|| Posicione("SB1",1,xFilial("SB1")+REL->PRODUTO,"B1_DESC")})
TRCell():New(oSection1,"NFISCAL"  ,"REL"   ,"Not.Fis"	,,TamSX3("FT_NFISCAL")[1])
TRCell():New(oSection1,"SERIE"    ,"REL"   ,"Serie"		,,TamSX3("FT_SERIE"  )[1])
TRCell():New(oSection1,"CLIEFOR"  ,"REL"   ,"Cliente"	,,TamSX3("FT_CLIEFOR")[1])
TRCell():New(oSection1,"LOJA"     ,"REL"   ,"Loja"		,,TamSX3("FT_LOJA"   )[1])
TRCell():New(oSection1,"QUANT"    ,"REL"   ,"Qtd."		,PesqPict("SD1","D1_QUANT"),TamSx3("D1_QUANT")[1])

oSection2 := TRSection():New(oReport,"Notas Fiscais Compras",{cAliasNF})
TRCell():New(oSection2,"D1_DOC"   ,cAliasNF,"Not.Fis"	,,TamSX3("D1_DOC"    )[1])
TRCell():New(oSection2,"D1_SERIE" ,cAliasNF,"Serie"		,,TamSX3("D1_SERIE"  )[1])
TRCell():New(oSection2,"PROD_PA"  ,cAliasNF,"Produto"	,,TamSX3("D1_COD"    )[1])
TRCell():New(oSection2,"DESC_PA"  ,cAliasNF,"Descric"	,,TamSX3("B1_DESC"   )[1],,{|| Posicione("SB1",1,xFilial("SB1")+(cAliasNF)->PROD_PA,"B1_DESC")})
TRCell():New(oSection2,"TIPO",cAliasNF,"Tipo"		,,6)
TRCell():New(oSection2,"D1_VALICM",cAliasNF,"Vl.ICMS"	,PesqPict("SD1","D1_VALICM"),TamSx3("D1_VALICM")[1])
TRCell():New(oSection2,"D1_VALIPI",cAliasNF,"Vl.IPI."	,PesqPict("SD1","D1_VALIPI"),TamSx3("D1_VALIPI")[1])
TRCell():New(oSection2,"D1_VALIMP6",cAliasNF,"Vl.PIS"	,PesqPict("SD1","D1_VALIMP6"),TamSx3("D1_VALIMP6")[1])
TRCell():New(oSection2,"D1_VALIMP5",cAliasNF,"Vl.COF."	,PesqPict("SD1","D1_VALIMP5"),TamSx3("D1_VALIMP5")[1])

Return(oReport)

Static Function GetFil(aSelFil)
Local aAreaSM0	:= {}
Local aSM0		:= {}
Local nFil		:= 0

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")

//-------------------------------------------------------------------
//Irá preencher aSM0 somente com as filiais selecionadas pelo cliente
//-------------------------------------------------------------------
If Len(aSelFil)> 0
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aSelFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. aSelFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf
	SM0->(RestArea(aAreaSM0))
EndIf

Return aSM0

//-------------------------------------------------------------------
//! Validacao datas (Pergunte)
//-------------------------------------------------------------------
Static Function VldSx1()
Local cMensagem	:= ""

If Empty(mv_par01) .Or. Empty(mv_par03)
	cMensagem	:= "É necessário informar data inicial."
ElseIf Empty(mv_par02) .Or. Empty(mv_par04)
	cMensagem	:= "É necessário informar data final."
ElseIf mv_par02 < mv_par01 .Or. mv_par04 < mv_par03
	cMensagem	:= "Data Final deverá ser maior que data inicial."
EndIf

Return cMensagem

//-------------------------------------------------------------------
//! Montagem arquivo temporario de processamento das saidas
//-------------------------------------------------------------------
Static Function MontaTrb()
Local cAlias := "REL"
Local aCampos := {}

If Select(cAlias)>0
	(cAlias)->(DbCloseArea())
EndIf

oTempR028 := FWTemporaryTable():New( cAlias )

aAdd(aCampos,{"PRODUTO"	,"C",TamSX3("FT_PRODUTO")[1],0})
aAdd(aCampos,{"DESCR"    ,"C",TamSX3("B1_DESC"   )[1],0})
aAdd(aCampos,{"NFISCAL"	,"C",TamSX3("FT_NFISCAL")[1],0})
aAdd(aCampos,{"SERIE"	,"C",TamSX3("FT_SERIE"  )[1],0})
aAdd(aCampos,{"ITEM"	,"C",TamSX3("FT_ITEM"   )[1],0})
aAdd(aCampos,{"CLIEFOR"	,"C",TamSX3("FT_CLIEFOR")[1],0})
aAdd(aCampos,{"LOJA"	,"C",TamSX3("FT_LOJA"   )[1],0})
aAdd(aCampos,{"QUANT"	,"N",TamSX3("FT_QUANT"  )[1],2})

oTempR028:SetFields( aCampos )
oTempR028:AddIndex("01", {"PRODUTO","NFISCAL","SERIE","ITEM","CLIEFOR","LOJA"} )

oTempR028:Create()

Return Nil

//-------------------------------------------------------------------
//! Processamento das vendas e das compras de materiais para producao
//-------------------------------------------------------------------
Static Function SelRelR028(oTable)
Local aAreaSM0	:= 	SM0->(GetArea())
Local nContFil	:= 	0
Local nPosAprod	:= 	0
Local nVlEstICM	:=	0 	
Local nVlEstIPI 	:=	0
Local nVlEstPIS	:=	0
Local nVlEstCOF	:=	0
Local aSelFil		:= {}
Local aFil			:= {}
Local aProdutos 	:= {}
Local aProdComp	:= {}
Local dDtIni		:= mv_par01
Local dDtFim		:= mv_par02
Local dDtIniCom	:= mv_par03
Local dDtFimCom	:= mv_par04
Local cCfSaid		:= StrTran(AllTrim(mv_par05),",","','")
Local cCstIcm		:= StrTran(AllTrim(mv_par07),",","','")
Local cCstIPI		:= StrTran(AllTrim(mv_par08),",","','")
Local cCstPC		:= StrTran(AllTrim(mv_par09),",","','")
Local aCpoSD1		:= {}// Campos da SD1 que serao listados no arquivo de trabalho
Local cQueryCST	:=	""
Local cTcGetDb	:= TcGetDb()
Local aRetAuto  := {}
Local nPosProd  := 0
Local oProdjs   := JsonObject():New()
Local nX        := 0

MontaTrb()

DbSelectArea("SM0")

If mv_par06 == 1
	If !IsBlind()
		aSelFil := MatFilCalc( .T. )
	Else
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto("FISR028TestCase")
			If Valtype(aRetAuto) == "A"
				aSelFil  := aRetAuto
			EndIf
		Endif
	Endif
Else
	aSelFil := {{.T.,cFilAnt,SM0->M0_FILIAL,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_TEL}}
EndIf
aFil := GetFil(aSelFil)

cAliasQry := GetNextAlias()
If 'MSSQL' $ cTcGetDb
	cQueryCST	+=  "% SUBSTRING(SFT.FT_CLASFIS,2,2) IN ('"+%Exp:cCstIcm%+"')%"
Else
	cQueryCST	+=  "% SUBSTR(SFT.FT_CLASFIS,2,2) IN ('"+%Exp:cCstIcm%+"')%"
EndIf
For nContFil := 1 To Len(aFil)
	SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL
	BeginSql Alias cAliasQry
		COLUMN FT_ENTRADA AS DATE
		SELECT
			SFT.FT_PRODUTO,
			SFT.FT_NFISCAL,
			SFT.FT_SERIE,
			SFT.FT_ITEM,
			SFT.FT_CLIEFOR,
			SFT.FT_LOJA,
			SFT.FT_QUANT,
			SFT.FT_CLASFIS,
			SFT.FT_CTIPI,
			SFT.FT_CSTPIS,
			SFT.FT_CSTCOF
		FROM
			%table:SFT% SFT
		WHERE
			SFT.FT_FILIAL   = %xFilial:SFT% AND
			SFT.FT_DTCANC   = '        ' AND
			SFT.FT_ENTRADA >= %Exp:mv_par01% 	AND
			SFT.FT_ENTRADA <= %Exp:mv_par02% AND
			SFT.FT_CFOP    IN (%Exp:cCfSaid%) 	AND
			(%Exp:cQueryCST%	OR
			SFT.FT_CTIPI	 IN (%Exp:cCstIPI%)	OR
			SFT.FT_CSTPIS	 IN (%Exp:cCstPC%))	AND
			SFT.FT_TIPOMOV  = 'S' AND
			SFT.%NotDel%
		ORDER BY
			FT_PRODUTO,FT_NFISCAL,FT_SERIE,FT_ITEM,FT_CLIEFOR,FT_LOJA
	EndSql
	//--
	Do While !(cAliasQry)->(Eof())
		IF !REL->(MsSeek((cAliasQry)->(FT_PRODUTO+FT_NFISCAL+FT_SERIE+FT_ITEM+FT_CLIEFOR+FT_LOJA)))
			nPosAprod := aScan(aProdutos,{|x|x==(cAliasQry)->FT_PRODUTO})
			If nPosAprod == 0
				aAdd(aProdutos,(cAliasQry)->FT_PRODUTO)
				aAdd(aProdComp,{(cAliasQry)->FT_PRODUTO, (cAliasQry)->FT_QUANT, (cAliasQry)->FT_CLASFIS,(cAliasQry)->FT_CTIPI,(cAliasQry)->FT_CSTPIS})
			Else
				aProdComp[nPosAprod][2] += (cAliasQry)->FT_QUANT
			EndIf
			Reclock("REL",.T.)
			REL->PRODUTO	:= (cAliasQry)->FT_PRODUTO
			REL->NFISCAL	:= (cAliasQry)->FT_NFISCAL
			REL->SERIE		:= (cAliasQry)->FT_SERIE
			REL->ITEM		:= (cAliasQry)->FT_ITEM
			REL->CLIEFOR	:= (cAliasQry)->FT_CLIEFOR
			REL->LOJA		:= (cAliasQry)->FT_LOJA
			REL->QUANT		:= (cAliasQry)->FT_QUANT
			MsUnLock()
		EndIf			
		(cAliasQry)->(DbSkip())
	EndDo
	dbSelectArea(cAliasQry)
	dbCloseArea()
Next nContFil
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

For nX := 1 To Len (aProdComp)
	oProdjs[aProdComp[nX,1]] := nX
Next nX

REL->(DbGotop())
//--
aCpoSD1 := {"D1_VALICM","D1_VALIPI","D1_VALIMP6","D1_VALIMP5","D1_TIPO"}
cAliasNF := RetNFOri(dDtIni,dDtFim,dDtIniCom,dDtFimCom,aProdutos,aCpoSD1,.T.,@oTable) 
(cAliasNF)->(DbGotop())


If (cAliasNF)->(!Eof())
	nPosProd := oProdjs[(cAliasNF)->PROD_PA]
EndIf

While (cAliasNF)->(!Eof())
	
	If EmPty((cAliasNF)->PROD_COMP)

		If AllTrim((cAliasNF)->PROD_PA) <> AllTrim(aProdComp[nPosProd][1])
			nPosProd := oProdjs[(cAliasNF)->PROD_PA]
		EndIf
		
		If (cAliasNF)->PROD_PA == aProdComp[nPosProd][1] .And. EmPty((cAliasNF)->PROD_COMP) 
				
			Reclock(cAliasNF,.F.)
			nVlEstICM 	:=	((cAliasNF)->D1_VALICM	/ 	(cAliasNF)->QUANT) * aProdComp[nPosProd][2]
			nVlEstIPI 	:=	((cAliasNF)->D1_VALIPI	/	(cAliasNF)->QUANT) * aProdComp[nPosProd][2]
			nVlEstPIS	:=	((cAliasNF)->D1_VALIMP6	/	(cAliasNF)->QUANT) * aProdComp[nPosProd][2]
			nVlEstCOF	:=	((cAliasNF)->D1_VALIMP5	/	(cAliasNF)->QUANT) * aProdComp[nPosProd][2]
			/*/--Notas de Complemento com quantidade Zerada, devem levar o valor integral do Imposto retido
			C = Complemento | I = Complemento de ICMS | P = Complemento de IPI /*/
			If (cAliasNF)->D1_TIPO $ "C,I,P" 
				nVlEstICM 	+=	(cAliasNF)->D1_VALICM
				nVlEstIPI 	+=	(cAliasNF)->D1_VALIPI
				nVlEstPIS	+=	(cAliasNF)->D1_VALIMP6
				nVlEstCOF	+=	(cAliasNF)->D1_VALIMP5						
			EndIf
			//--
			(cAliasNF)->QUANT			:=	aProdComp[nPosProd][2]
			If SubStr(aProdComp[nPosProd][3],2,2) $ cCstIcm .And. !Empty(cCstIcm)
				(cAliasNF)->D1_VALICM	:=	nVlEstICM
			Else
				(cAliasNF)->D1_VALICM 	:= 	0
			EndIf
			If aProdComp[nPosProd][4] $ cCstIPI .And. !Empty(cCstIPI)
				(cAliasNF)->D1_VALIPI	:=	nVlEstIPI
			Else
				(cAliasNF)->D1_VALIPI	:=	0
			EndIf
			If aProdComp[nPosProd][5]  $ cCstPC .And. !Empty(cCstPC)
				(cAliasNF)->D1_VALIMP6	:=	nVlEstPIS
				(cAliasNF)->D1_VALIMP5	:=	nVlEstCOF
			Else
				(cAliasNF)->D1_VALIMP6	:=	0
				(cAliasNF)->D1_VALIMP5	:=	0						
			EndIf
			(cAliasNF)->(MsUnLock())	
		EndIf			
	EndIf	
	(cAliasNF)->(DbSkip())	
EndDo


FreeObj(oProdjs)
oProdjs := Nil
	
Return Nil
