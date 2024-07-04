#Include "Protheus.ch"
#Include "Report.ch"
#Include "GPEA070.ch"

Static lCorpManage := fIsCorpManage( FWGrpCompany() )
Static cLayoutGC   := FWSM0Layout(cEmpAnt)
Static nStartEmp   := At("E",cLayoutGC)
Static nStartUnN   := At("U",cLayoutGC)
Static nEmpLength  := Len(FWSM0Layout(cEmpAnt, 1))
Static nUnNLength  := Len(FWSM0Layout(cEmpAnt, 2))

/*/{Protheus.doc} GPER071
Relatório de divergências de provisão: Apresenta os funcionários que possuiam saldo na provisão do mês anterior e no mês atual não possuem provisão
@author gabriel.almeida
@since 27/11/2017
@version P12
@history 27/11/2017, Gabriel A., Criação do relatório
/*/
Function GPER071()
	Local oReport
	Local aArea := GetArea()
	
	Private cPerg := "GPER071"
	
	Private cEmpr     := ""
	Private cDescEmpr := ""
	Private cUnid     := ""
	Private cDescUnid := ""
	Private cFili     := ""
	Private cDescFili := ""
	Private cCentroC  := ""
	Private cDescCC   := ""
	Private cFilFun   := ""
	Private cMatFun   := ""
	Private cNomeFun  := ""
	Private cTpProv   := ""
	Private cCodPd    := ""
	Private cDescPd   := ""
	Private cValorPd  := ""
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} ReportDef
Definição dos componentes do relatório
@author gabriel.almeida
@since 27/11/2017
@version P12
/*/
Static Function ReportDef()

	Local oReport
	Local oSecEm
	Local oSecUN
	Local oSecFil
	Local oSecCC
	Local oSecFun
	Local oSecDet
	Local cAliasQry := GetNextAlias()
	
	Local aOrd := {}
	
	Aadd(aOrd, STR0069)//1 - Filial + C.Custo + Matrícula
	Aadd(aOrd, STR0070)//2 - C.Custo+Filial+Matrícula
	
	DEFINE REPORT oReport NAME "GPER071" TITLE STR0071 PARAMETER cPerg ACTION {|oReport| RelatImp(oReport,cAliasQry)} //"Relatório de Divergências de Provisão"
		// - Verifica se o cliente possui Gestão Corporativa no Grupo Logado 
		// - Caso possua imprimi com UN na margem na posição (02)
		If lCorpManage
			DEFINE SECTION oSecEm OF oReport TITLE STR0074 TABLE "SRA" ORDERS aOrd //"Empresa"
				DEFINE CELL NAME "EMPRESA" OF oSecEm BLOCK {|| cEmpr} TITLE STR0072 //"Cod. Empr."
				DEFINE CELL NAME "DESC_EM" OF oSecEm BLOCK {|| cDescEmpr} TITLE STR0072 //"Nome Empr."
				
			DEFINE SECTION oSecUN OF oSecEm TITLE STR0075//"Unidade de Negócio"
				DEFINE CELL NAME "UNID_NEG" OF oSecUN BLOCK {|| cUnid} TITLE STR0076 //"Cod. UN"
				DEFINE CELL NAME "DESC_UN" OF oSecUN BLOCK {|| cDescUnid} TITLE STR0077 //"Nome UN"
				
				oSecUN:SetLeftMargin(2)
			
			DEFINE SECTION oSecFil OF oSecUN TITLE STR0078 //"Filial"
				DEFINE CELL NAME "RA_FILIAL" OF oSecFil BLOCK {|| cFili} TITLE STR0079 //"Cod. Fil."
				DEFINE CELL NAME "DESC_FIL" OF oSecFil BLOCK {|| cDescFili} TITLE STR0080 //"Nome Fil."
										
				DEFINE FUNCTION FROM oSecFil:Cell("RA_FILIAL") OF oSecFil FUNCTION COUNT TITLE STR0078 NO END SECTION
					
				oSecFil:SetLeftMargin(4)
			
			DEFINE SECTION oSecCC OF oSecFil TITLE STR0081 //"Centro de Custo"
				DEFINE CELL NAME "RA_CC"   OF oSecCC BLOCK {|| cCentroC } TITLE STR0082 //"Cod. C. Custo"
				DEFINE CELL NAME "DESC_CC" OF oSecCC BLOCK {|| cDescCC  } TITLE STR0083 //"Desc. C. Custo"
												
				DEFINE FUNCTION FROM oSecCC:Cell("RA_CC") OF oSecCC FUNCTION COUNT TITLE STR0081 NO END SECTION
			
				oSecCC:SetLeftMargin(6)
	
			DEFINE SECTION oSecFun OF oSecCC TITLE STR0092 //"Funcionários com Divergências"						
							
				DEFINE CELL NAME "RA_FILIAL"          OF oSecFun BLOCK {|| cFilFun  } TITLE STR0078
				DEFINE CELL NAME "RA_MAT"             OF oSecFun BLOCK {|| cMatFun  } TITLE STR0084
				DEFINE CELL NAME "RA_NOME"            OF oSecFun BLOCK {|| cNomeFun } TITLE STR0085
				DEFINE CELL NAME "RT_DATACAL"         OF oSecFun BLOCK {|| cDataCal } TITLE STR0086
				DEFINE CELL NAME "RT_DFERVEN"         OF oSecFun BLOCK {|| cDFerVen } TITLE STR0087
				DEFINE CELL NAME "RT_DFERPRO"         OF oSecFun BLOCK {|| cDFerPro } TITLE STR0088
				DEFINE CELL NAME "RT_DFERANT"         OF oSecFun BLOCK {|| cDFerAnt } TITLE STR0089
				DEFINE CELL NAME "RT_AVOS13S"         OF oSecFun BLOCK {|| cAvos13  } TITLE STR0090
				DEFINE CELL NAME "RT_SALARIO"         OF oSecFun BLOCK {|| cSalario } TITLE STR0091
				
				DEFINE FUNCTION FROM oSecFun:Cell("RA_MAT") OF oSecFun FUNCTION COUNT TITLE STR0092 NO END SECTION
				
				oSecFun:SetLeftMargin(8)
			
			DEFINE SECTION oSecDet OF oSecFun TITLE STR0093 //"Detalhe Provisão"
							
				DEFINE CELL NAME "RT_TIPPROV" OF oSecDet BLOCK {|| cTpProv  } TITLE STR0094
				DEFINE CELL NAME "RT_VERBA"   OF oSecDet BLOCK {|| cCodPd   } TITLE STR0095
				DEFINE CELL NAME "DESC_VERBA" OF oSecDet BLOCK {|| cDescPd  } TITLE STR0096
				DEFINE CELL NAME "RT_VALOR"   OF oSecDet BLOCK {|| cValorPd } TITLE STR0097
				
				oSecDet:SetLeftMargin(10)
		Else			
			DEFINE SECTION oSecFil OF oReport TITLE STR0078 ORDERS aOrd
				DEFINE CELL NAME "RA_FILIAL" OF oSecFil BLOCK {|| cFili} TITLE STR0078
				DEFINE CELL NAME "DESC_FIL" OF oSecFil BLOCK {|| cDescFili} TITLE STR0080
										
				DEFINE FUNCTION FROM oSecFil:Cell("RA_FILIAL") OF oSecFil FUNCTION COUNT TITLE STR0078 NO END SECTION
			
			DEFINE SECTION oSecCC OF oSecFil TITLE STR0081
				DEFINE CELL NAME "RA_CC"   OF oSecCC BLOCK {|| cCentroC } TITLE STR0082
				DEFINE CELL NAME "DESC_CC" OF oSecCC BLOCK {|| cDescCC  } TITLE STR0083
												
				DEFINE FUNCTION FROM oSecCC:Cell("RA_CC") OF oSecCC FUNCTION COUNT TITLE STR0081 NO END SECTION
			
				oSecCC:SetLeftMargin(2)
	
			DEFINE SECTION oSecFun OF oSecCC TITLE STR0092 //"Funcionários com Divergências"						
							
				DEFINE CELL NAME "RA_FILIAL"          OF oSecFun BLOCK {|| cFilFun  } TITLE STR0078
				DEFINE CELL NAME "RA_MAT"             OF oSecFun BLOCK {|| cMatFun  } TITLE STR0084
				DEFINE CELL NAME "RA_NOME"            OF oSecFun BLOCK {|| cNomeFun } TITLE STR0085
				DEFINE CELL NAME "RT_DATACAL"         OF oSecFun BLOCK {|| cDataCal } TITLE STR0086
				DEFINE CELL NAME "RT_DFERVEN"         OF oSecFun BLOCK {|| cDFerVen } TITLE STR0087
				DEFINE CELL NAME "RT_DFERPRO"         OF oSecFun BLOCK {|| cDFerPro } TITLE STR0088
				DEFINE CELL NAME "RT_DFERANT"         OF oSecFun BLOCK {|| cDFerAnt } TITLE STR0089
				DEFINE CELL NAME "RT_AVOS13S"         OF oSecFun BLOCK {|| cAvos13  } TITLE STR0090
				DEFINE CELL NAME "RT_SALARIO"         OF oSecFun BLOCK {|| cSalario } TITLE STR0091
				
				DEFINE FUNCTION FROM oSecFun:Cell("RA_MAT") OF oSecFun FUNCTION COUNT TITLE STR0092 NO END SECTION
				
				oSecFun:SetLeftMargin(4)
			
			DEFINE SECTION oSecDet OF oSecFun TITLE STR0093
							
				DEFINE CELL NAME "RT_TIPPROV" OF oSecDet BLOCK {|| cTpProv  } TITLE STR0094
				DEFINE CELL NAME "RT_VERBA"   OF oSecDet BLOCK {|| cCodPd   } TITLE STR0095
				DEFINE CELL NAME "DESC_VERBA" OF oSecDet BLOCK {|| cDescPd  } TITLE STR0096
				DEFINE CELL NAME "RT_VALOR"   OF oSecDet BLOCK {|| cValorPd } TITLE STR0097
				
				oSecDet:SetLeftMargin(6)
		EndIf
Return (oReport)


/*/{Protheus.doc} RelatImp()
Definicoes de uso das sections.
Definicoes de uso dos totalizadores (functions e collections).
Realizacao da query para o relatorio.
@author gabriel.almeida
@version P12
@param oReport, objeto, Objeto TReport
@param cAliasQry, caractere, Alias da area utilizada para busca no banco
/*/
Static Function RelatImp(oReport, cAliasQry)
	Local oSecEm
	Local oSecUN
	Local oSecFil
	Local oSecCC
	Local oSecFun
	Local oSecDet
	Local nOrdem    := 0
	Local cOrdem    := ""
	
	Local dDataRef  := MV_PAR01 //Data Referência
	Local cFilDe    := MV_PAR02
	Local cFilAte   := MV_PAR03
	Local cCCDe     := MV_PAR04
	Local cCCAte    := MV_PAR05
	Local cMatDe    := MV_PAR06
	Local cMatAte   := MV_PAR07
	Local cNomeDe   := MV_PAR08
	Local cNomeAte  := MV_PAR09
	Local cCateg    := MV_PAR10
	Local nAnaSin   := MV_PAR11
	
	Local cCatQuery := ""
	Local cWhere    := ""
	Local aArea     := GetArea()
	Local cEmprAux  := ""
	Local cUnidAux  := ""
	Local cFiliAux  := ""
	Local cCCAux    := ""
	Local cFunAux   := ""
	Local nReg      := 0
	Local dDtRefAnt
	Local lSkip     := .F.
	
	Local lHeaderFun := .F.
	
	If Empty(dDataRef)
		MsgAlert(STR0098) //"A Data de Referência é necessária para emissão do relatório"
		Return Nil
	Else
		dDtRefAnt := dDataRef - f_UltDia(dDataRef)
	EndIf

	For nReg:=1 To Len(cCateg)
		cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCateg)
			cCatQuery += "," 
		Endif
	Next nReg

	If !(Empty(cFilDe))
		cWhere += " SRT2.RT_FILIAL >= '" + cFilDe + "' AND "
	EndIf

	If !(Empty(cFilAte))
		cWhere += " SRT2.RT_FILIAL <= '" + cFilAte + "' AND "
	EndIf
     
	If !(Empty(cCCDe))
		cWhere += " SRT2.RT_CC >= '" + cCCDe + "' AND "
	EndIf
	
	If !(Empty(cCCAte))
		cWhere += " SRT2.RT_CC <= '" + cCCAte + "' AND "
	EndIf
	
	If !(Empty(cMatDe))
		cWhere += " SRT2.RT_MAT >= '" + cMatDe + "' AND "
	EndIf
	
	If !(Empty(cMatAte))
		cWhere += " SRT2.RT_MAT <= '" + cMatAte + "' AND "
	EndIf
	
	If !(Empty(cNomeDe))
		cWhere += " SRA.RA_NOME >= '" + cNomeDe + "' AND "
	EndIf
	
	If !(Empty(cNomeAte))
		cWhere += " SRA.RA_NOME <= '" + cNomeAte + "' AND "
	EndIf
	
	If !(Empty(cCateg))
		cWhere += " SRA.RA_CATFUNC IN (" + Upper(cCatQuery) + ") AND "
	EndIf
	
	If !(Empty(cWhere))
		cWhere		:= "%" + cWhere + "%"
	Else
		cWhere		:= "% %"
	EndIf
	
	If lCorpManage
		oSecEm  := oReport:Section(1)
		oSecUN  := oReport:Section(1):Section(1)
		oSecFil := oReport:Section(1):Section(1):Section(1)
		oSecCC  := oReport:Section(1):Section(1):Section(1):Section(1)
		oSecFun := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
		oSecDet := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
		
		nOrdem := oSecEm:GetOrder()
	Else
		oSecFil := oReport:Section(1)
		oSecCC  := oReport:Section(1):Section(1)
		oSecFun := oReport:Section(1):Section(1):Section(1)
		oSecDet := oReport:Section(1):Section(1):Section(1):Section(1)
		
		nOrdem := oSecFil:GetOrder()
	EndIf
	
	If nAnaSin == 2
		oSecDet:Hide()
	EndIf
	
	If nOrdem == 2 //C.Custo + Filial + Matrícula
		oSecFil:Hide()
		cOrdem := "% 5,1,2 %"
	Else //Filial + C.Custo + Matrícula
		cOrdem := "% 1,5,2 %"
	EndIf
	
	//Busca no banco de dados
	BeginSql Alias cAliasQry
		SELECT
			RA_FILIAL, RA_MAT, RA_NOME, SRA.RA_CATFUNC, SRT2.RT_CC
			, SRT2.RT_DATACAL, SRT2.RT_DFERVEN, SRT2.RT_DFERPRO, SRT2.RT_DFERANT, SRT2.RT_AVOS13S, SRT2.RT_SALARIO
		FROM
			%Table:SRA% SRA
			INNER JOIN
				(SELECT * FROM %Table:SRT% SRTINT
					WHERE SRTINT.RT_DATACAL = %Exp:dDtRefAnt%
						AND SRTINT.RT_DATABAS <> ''
						AND ( SRTINT.RT_DFERVEN > 0 OR SRTINT.RT_DFERPRO > 0 OR SRTINT.RT_DFERANT > 0 OR SRTINT.RT_AVOS13S > 0 )
						AND SRTINT.%NotDel%
				) SRT2
				ON SRA.RA_FILIAL = SRT2.RT_FILIAL AND SRA.RA_MAT = SRT2.RT_MAT
			LEFT JOIN %Table:SRT% SRT1 ON SRT1.RT_FILIAL = SRA.RA_FILIAL AND SRT1.RT_MAT = SRA.RA_MAT AND SRT1.RT_DATACAL = %Exp:dDataRef%
		WHERE
			%Exp:cWhere%
			SRA.%NotDel%
			AND ( SRT1.%NotDel% OR SRT1.D_E_L_E_T_ IS NULL )
			AND SRT2.%NotDel%
			AND SRT1.RT_DATACAL IS NULL
		GROUP BY
			RA_FILIAL, RA_MAT, RA_NOME, SRA.RA_CATFUNC, SRT2.RT_CC, SRT2.RT_DATACAL, SRT2.RT_DFERVEN, SRT2.RT_DFERPRO, SRT2.RT_DFERANT, SRT2.RT_AVOS13S, SRT2.RT_SALARIO
		ORDER BY
			%Exp:cOrdem%
	EndSql
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If lCorpManage
		oSecEm:Init()
		oSecUN:Init()
	EndIf
	oSecFil:Init()
	oSecCC:Init()
	oSecFun:Init()
	oSecDet:Init()
	
	While !(cAliasQry)->(Eof())
		//Movimenta Regua Processamento
		oReport:IncMeter(1)
		
		//Cancela Impressao
		If oReport:Cancel()
			Exit
		EndIf
		
		If lCorpManage
			cEmpr := SubStr( (cAliasQry)->RA_FILIAL,nStartEmp,nEmpLength )
			If !(cEmpr $ cEmprAux)
				cDescEmpr := FWCompanyName(cEmpAnt,(cAliasQry)->RA_FILIAL)
				If !( Empty(cEmprAux) )
					oReport:SkipLine(nAnaSin - (nOrdem - 1))
					oSecEm:PrintHeader()
				EndIf
				oSecEm:PrintLine()
				cEmprAux += cEmpr + "/"
			EndIf
			
			cUnid := SubStr( (cAliasQry)->RA_FILIAL,nStartUnN,nUnNLength )
			If !(cUnid $ cUnidAux)
				cDescUnid := FWUnitName(cEmpAnt,(cAliasQry)->RA_FILIAL)
				If !( Empty(cUnidAux) )
					oReport:SkipLine()
					oSecUN:PrintHeader()
				EndIf
				oSecUN:PrintLine()
				cUnidAux += cUnid + "/"
			EndIf
		EndIf
		
		cFili := (cAliasQry)->RA_FILIAL
		If !(cFili $ cFiliAux)
			cDescFili := FWFilialName(cEmpAnt,(cAliasQry)->RA_FILIAL)
			If !( Empty(cFiliAux) )
				If !lCorpManage
					oReport:SkipLine(nAnaSin - (nOrdem - 1))
				Else
					oReport:SkipLine()
				EndIf
				oSecFil:PrintHeader()
			EndIf
			oSecFil:PrintLine()
			cFiliAux += cFili + "/"
		EndIf
		
		cCentroC := (cAliasQry)->RT_CC
		If !(cCentroC $ cCCAux)
			cDescCC := fDesc("CTT", cCentroC, "CTT_DESC01",, xFilial("CTT",cFili), 1)
			If !( Empty(cCCAux) )
				oReport:SkipLine(1)
				oSecCC:PrintHeader()
			EndIf
			oSecCC:PrintLine()
			cCCAux += cCentroC + "/"
		EndIf
		
		cFilFun  := (cAliasQry)->RA_FILIAL
		cMatFun  := (cAliasQry)->RA_MAT
		If !(cFilFun+cMatFun $ cFunAux)
			cNomeFun := (cAliasQry)->RA_NOME
			cDataCal := DToC(SToD((cAliasQry)->RT_DATACAL))
			cDFerVen := (cAliasQry)->RT_DFERVEN
			cDFerPro := (cAliasQry)->RT_DFERPRO
			cDFerAnt := (cAliasQry)->RT_DFERANT
			cAvos13  := (cAliasQry)->RT_AVOS13S
			cSalario := (cAliasQry)->RT_SALARIO
			
			If lHeaderFun
				oReport:SkipLine(1)
				oSecFun:PrintHeader()
				lHeaderFun := .F.
			EndIf
		
			oSecFun:PrintLine()
			If nAnaSin == 1 .And. !( Empty(cFunAux) )
				oReport:SkipLine(1)
				oSecDet:PrintHeader()
			EndIf
			cFunAux += cFilFun+cMatFun + "/"
		EndIf
		
		DbSelectArea("SRT")
		DbSetOrder(5) //Filial + Matrícula + Data Cal.
		
		If SRT->( MsSeek(cFilFun + cMatFun + (cAliasQry)->RT_DATACAL) )
			While SRT->( !EOF() ) .And. cFilFun + cMatFun + (cAliasQry)->RT_DATACAL == SRT->RT_FILIAL + SRT->RT_MAT + DToS(SRT->RT_DATACAL)
				cTpProv  := fTpProv(SRT->RT_TIPPROV)
				cCodPd   := SRT->RT_VERBA
				cDescPd  := fDesc("SRV", SRT->RT_VERBA, "RV_DESC",,xFilial("SRV",cFilFun))
				cValorPd := SRT->RT_VALOR
				
				SRT->( DbSkip() )
				oSecDet:PrintLine()
			EndDo
			
			If nAnaSin == 1
				(cAliasQry)->(DbSkip())
				If (cAliasQry)->( !EOF() )
					oReport:SkipLine(1)
					If !( (cAliasQry)->RA_FILIAL <> cFilFun .Or. (cAliasQry)->RT_CC <> cCentroC )
						oSecFun:PrintHeader()
					Else
						lHeaderFun := .T.
					EndIf
				EndIf
				lSkip := .T.
			Else
				(cAliasQry)->(DbSkip())
				If (cAliasQry)->( !EOF() ) .And. ( (cAliasQry)->RA_FILIAL <> cFilFun .Or. (cAliasQry)->RT_CC <> cCentroC )
					lHeaderFun := .T.
				EndIf
				lSkip := .T.
			EndIf
		EndIf
		
		If !lSkip
			(cAliasQry)->(DbSkip())
		EndIf
		lSkip := .F.
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	//Termino do relatorio
	If lCorpManage
		oSecEm:Finish()
		oSecUN:Finish()
	EndIf
	oSecFil:Finish()
	oSecCC:Finish()
	oSecFun:Finish()
	oSecDet:Finish()
	
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fTpProv
Retorna a descrição do tipo de rescisão
@author gabriel.almeida
@since 29/11/2017
@version 1.0
@param cTip, C, Código do tipo de provisão
@return cTpProv, Descrição do tipo de provisão
/*/
Static Function fTpProv(cTip)
	Local cTpProv := ""
	
	If cTip == "1"
		cTpProv := STR0099 //"Fer.Venc."
	ElseIf cTip == "2"
		cTpProv := STR0100 //"Fer.Prop."
	ElseIf cTip == "3"
		cTpProv := STR0101 //"13o.Sal."
	EndIf
Return cTpProv
