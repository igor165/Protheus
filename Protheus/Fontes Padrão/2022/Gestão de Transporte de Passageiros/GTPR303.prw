#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPR303.ch'

Static oGR303Table
Static aGR303Situaca	:= {}


/*/{Protheus.doc} GTPR303
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR303()
Local 	cPerg 	:= "GTPR303"
Private oReport := Nil

If Pergunte( cPerg, .T. )
	oReport := ReportDef( cPerg )	
	// GR303Destroy()
Endif

Return()


/*/{Protheus.doc} GR303SetQry
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GR303SetQry(dDataDe,dDataAte,cSetorDe,cSetorAte,cGrupoDe,cGrupoAte)

Local 	cQuery	:= ""

Default dDataDe		:= mv_par01
Default dDataAte	:= mv_par02
Default cSetorDe	:= mv_par03
Default cSetorAte	:= mv_par04
Default cGrupoDe	:= mv_par05
Default cGrupoAte	:= mv_par06

cQuery := "SELECT " + Chr(13)
cQuery += "	DISTINCT " + Chr(13)
cQuery += "	GYG_CODIGO, " + Chr(13)
cQuery += "	GYG_NOME, " + Chr(13)
cQuery += "	SUBSTRING(GYE_DTREF,7,2) + '/' + SUBSTRING(GYE_DTREF,5,2) + '/' + SUBSTRING(GYE_DTREF,1,4) GYE_DTREF, " + Chr(13)
cQuery += "	GYP_ESCALA, " + Chr(13)
cQuery += "	RA_FILIAL, " + Chr(13)
cQuery += "	RA_MAT, " + Chr(13)
cQuery += "	'(oGR303Table:GetAlias())->( GR303SitFolha(RA_FILIAL,RA_MAT,GYE_DTREF,aGR303Situaca) )' FUNC_SITU, " + Chr(13)
cQuery += "	RA_SITFOLH, " + Chr(13)
cQuery += "	'Iif(Len(aGR303Situaca) > 0, aGR303Situaca[Len(aGR303Situaca),1]," + chr(34) + chr(34) + ")' AFAS_DTINI, " + Chr(13)
cQuery += "	'Iif(Len(aGR303Situaca) > 0, aGR303Situaca[Len(aGR303Situaca),2]," + chr(34) + chr(34) + ")' AFAS_DTFIM " + Chr(13)
cQuery += "FROM " + Chr(13)
cQuery += "	" + RetSQLName("GYE") + " GYE " + Chr(13)
cQuery += "INNER JOIN " + Chr(13)
cQuery += "	" + RetSQLName("GYP") + " GYP " + Chr(13)
cQuery += "ON " + Chr(13)
cQuery += "	GYP_FILIAL = '" + xFilial("GYP") + "' " + Chr(13)
cQuery += "	AND GYP_ESCALA = GYE_ESCALA " + Chr(13)
cQuery += "	AND GYP.D_E_L_E_T_ = ' ' " + Chr(13)
cQuery += "INNER JOIN " + Chr(13)
cQuery += "	" + RetSQLName("GYO") + " GYO " + Chr(13)
cQuery += "ON " + Chr(13)
cQuery += "	GYO_FILIAL = GYP_FILIAL " + Chr(13)
cQuery += "	AND GYO_CODIGO = GYP_ESCALA " + Chr(13)
cQuery += "	AND GYO.D_E_L_E_T_ = ' ' " + Chr(13)
cQuery += "INNER JOIN " + Chr(13)
cQuery += "	" + RetSQLName("GYG") + " GYG " + Chr(13)
cQuery += "ON " + Chr(13)
cQuery += "	GYG_FILIAL = '"+ XFilial("GYG") + "' " + Chr(13)
cQuery += "	AND GYG_CODIGO = GYE_COLCOD " + Chr(13)
cQuery += "	AND GYG.D_E_L_E_T_ = ' ' " + Chr(13)
cQuery += "INNER JOIN " + Chr(13)
cQuery += "	" + RetSQLName("SRA") + " SRA " + Chr(13)
cQuery += "ON " + Chr(13)
cQuery += "	RA_FILIAL = '"+ XFilial("SRA") + "' " + Chr(13)
cQuery += "	AND RA_MAT = GYG_FUNCIO " + Chr(13)
cQuery += "	AND SRA.D_E_L_E_T_ = ' ' " + Chr(13)
cQuery += "WHERE " + Chr(13)
cQuery += "	GYE_FILIAL = '" + xFilial("GYE") + "' " + Chr(13)
cQuery += "	AND GYE_DTREF BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' " + Chr(13)
cQuery += "	AND GYE_ESCALA <> '' " + Chr(13)
cQuery += "	AND GYE.D_E_L_E_T_ = ' ' " + Chr(13)

IF !(Empty(cGrupoDe) .Or. Empty(cGrupoAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GZA") +" GZA "+ Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GYI") + " GYI " + Chr(13)
	cQuery += "				ON  " + Chr(13)
	cQuery += "					GYI.GYI_FILIAL = '"+ xFilial("GYI") + "' " 	+ Chr(13)
	cQuery += "					AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO " + Chr(13)
	cQuery += "					AND GYI.GYI_COLCOD = GYG_CODIGO " + Chr(13)
	cQuery += "					AND GYI.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GZA.GZA_FILIAL = '" + xFilial("GZA") + "' "  + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO >= '" + cGrupoDe + "' " + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO <= '" + cGrupoAte + "' " + Chr(13)
	
	IF !(Empty(cSetorDe) .Or. Empty(cSetorAte))
	
		cQuery += "					AND GZA.GZA_SETOR >= '" + cSetorDe + "' " + Chr(13)
		cQuery += "					AND GZA.GZA_SETOR <= '" + cSetorAte + "' " + Chr(13)
		
	EndIF
	
	cQuery += "					AND GZA.D_E_L_E_T_=' ' " + Chr(13)
	cQuery += "			) 	" + Chr(13)
	
//SETOR
ElseIF !(Empty(cSetorDe) .Or. Empty(cSetorAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)				
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GYT") +" GYT " + Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GY2") +" GY2 " + Chr(13)
	cQuery += "				ON 	" + Chr(13)	
	cQuery += "					GY2.GY2_FILIAL ='" + xFilial("GY2") + "' " + Chr(13)		
	cQuery += "					AND GY2.GY2_SETOR = GYT_CODIGO	" + Chr(13)
	cQuery += "					AND GY2.GY2_CODCOL = GYG_CODIGO " + Chr(13)	
	cQuery += "					AND GY2.D_E_L_E_T_ = ' '	" + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GYT.GYT_FILIAL='" + xFilial("GYT") + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO >='" + cSetorDe + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO <='" + cSetorAte + "' " + Chr(13)
	cQuery += "					AND GYT.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				) "	 + Chr(13)
	
EndIf

cQuery += "ORDER BY " + Chr(13)
cQuery += "	GYG_CODIGO, " + Chr(13)
cQuery += "	GYE_DTREF " + Chr(13) 

GTPTemporaryTable(cQuery,GetNextAlias(),,,@oGR303Table)//,{{"DT_REFER","D",8}}) oGR303Table := GTPTemporaryTable(cQuery,GetNextAlias(),/*{{"IDX",{"GYE_DTREF","GYP_ESCALA","GYP_ITEM"}}}*/)//,{{"DT_REFER","D",8}})

Return()


/*/{Protheus.doc} GR303Destroy
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
// Function GR303Destroy()

// If ( ValType(oGR303Table) == "O" )
// 	oGR303Table:Delete()
// EndIf

// Return()


/*/{Protheus.doc} ReportDef
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef(cPerg)

Local oReport	:= Nil
Local bPrint	:= {|oRpt|	ReportPrint(oRpt)}


GR303SetQry()
(oGR303Table:GetAlias())->(dbGotop())

oReport := TReport():New('GTPR303', STR0005, cPerg, bPrint, , .F. /*lLandscape*/, /*uTotalText*/, /*lTotalInLine*/, /*cPageTText*/, /*lPageTInLine*/, /*lTPageBreak*/, /*nColSpace*/)//"Relatório de Conflitos de Escala"//"Gera Relatório"

SetSections(oReport)
oReport:PrintDialog()

Return()


/*/{Protheus.doc} SetSections
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetSections(oReport)

Local oSecColab	:= Nil
Local oSecAgenda:= Nil
Local oSecTotal	:= Nil
Local aSecColab		:= GR303CellCollect("SEC_COLAB")	//SEÇÃO 1: DADOS DO COLABORADOR
Local nX	:= 0

//Definição das Seções do Relatório - instanciando os objetos - Início
oSecColab 	:= TRSection():New(oReport, "SEC_COLAB", {'GYG','SRA','GYE','GYP'})		//SEÇÃO 1
//Definição das Seções do Relatório - instanciando os objetos - Fim
//Definição das Células das seções - início
//Células da Seção 1 - Início
For nX := 1 To len(aSecColab)
	TRCell():New(oSecColab, aSecColab[nX,1], aSecColab[nX,2], aSecColab[nX,3], aSecColab[nX,4],; 
					aSecColab[nX,5],,,aSecColab[nX,6])					
Next nX
//Células da Seção 1 - Fim
//Definição das Células das seções - fim
Return()



/*/{Protheus.doc} GR303CellCollect
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GR303CellCollect(cSection)

Local aRet		:= {}

If ( cSection == "SEC_COLAB" )
	
	aRet := { 	{"GYG_CODIGO","GYG",GetSx3Cache("GYG_CODIGO","X3_TITULO"),"",GetSx3Cache("GYG_CODIGO","X3_TAMANHO"),"LEFT"},;									
				{"GYG_NOME","GYG",GetSx3Cache("GYG_NOME","X3_TITULO"),"",GetSx3Cache("GYG_NOME","X3_TAMANHO"),"LEFT"},;
				{"GYE_DTREF","GYE","Data de Alocação","",GetSx3Cache("GYE_DTREF","X3_TAMANHO"),"LEFT"},;
				{"FUNC_SITU","GYP",GetSx3Cache("RA_SITFOLH","X3_TITULO"),"",GetSx3Cache("RCM_DESCRI","X3_TAMANHO"),"LEFT"},;
				{"AFAS_DTINI","SR8","Dt. Inicio","",8,"LEFT"},;
				{"AFAS_DTFIM","SR8","Dt. Fim","",8,"LEFT"}}

EndIf

Return(aRet)


/*/{Protheus.doc} ReportPrint
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport)

Local cHrsSoma		:= ""
Local cHrsOutSoma	:= ""
Local cHrsOut		:= ""
Local dData			:= SToD("")
Local oSecColab		:= oReport:Section(1)						//SEÇÃO 1: DADOS DO COLABORADOR
Local lPrintColab 	:= .f.

While ( (oGR303Table:GetAlias())->(!Eof()) )

	oReport:StartPage()
	oSecColab:Init()
	
	GR303PutValues(oGR303Table:GetAlias(), oSecColab, "SEC_COLAB")
	
	(oGR303Table:GetAlias())->(DbSkip())
	
End While

oSecColab:Finish()

Return()

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TR50PutValues
Função que atualiza o conteúdo das células de uma determinada seção.

@type 		Function
@author 	Fernando Radu Muscalu
@since 		29/02/2016
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function GR303PutValues(cAlias, xSection, cSecCell)

Local nI := 0
Local nX := 0 
Local nP := 0
Local cConteudo	:= ""
Local aCells 	:= GR303CellCollect(cSecCell)

If ( Valtype(xSection) == "O" )	
	For nI := 1 to Len(aCells)		
		If ( ValType((cAlias)->&(aCells[nI,1])) == "C" )		
			nP := RAt(")",(cAlias)->&(aCells[nI,1]))			
			If ( nP > 0 )			
				cConteudo := SubStr((cAlias)->&(aCells[nI,1]),1,nP)
				cConteudo := &(cConteudo)				
			Else
				cConteudo := (cAlias)->&(aCells[nI,1])	
			Endif		
		Else
			cConteudo := (cAlias)->&(aCells[nI,1])
		Endif		
		xSection:Cell(aCells[nI,1]):SetValue(cConteudo)		
	Next nI
	
	xSection:PrintLine()
	
Else
	
	For nX := 1 to Len(xSection)			
		For nI := 1 to Len(aCells[nX])			
			If ( "LBL_" $ aCells[nX][nI,1] )
				cConteudo := GTPLabelCo(aCells[nX][nI,1])
			Else				
				If ( ValType((cAlias)->&(aCells[nX][nI,1])) == "C" )				
					nP := At(")",(cAlias)->&(aCells[nX][nI,1]) )			
					If ( nP > 0 )					
						cConteudo := SubStr((cAlias)->&(aCells[nX][nI,1]),1,nP)						
						If ( FindFunction(cConteudo) )
							cConteudo := &(cConteudo)
						Endif					
					Else
						cConteudo := (cAlias)->&(aCells[nX][nI,1])
					Endif				
				Else
					cConteudo := (cAlias)->&(aCells[nX][nI,1])
				Endif				
			Endif			
			xSection[nX]:Cell(aCells[nX][nI,1]):SetValue(cConteudo)
		Next nI
		
		xSection[nX]:PrintLine()
			
	Next nX
	
Endif

Return()

/*/{Protheus.doc} GR303SitFolha
//Relatório 
@type function
@author GTP
@since 23/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GR303SitFolha(cFilMat,cMatFunc,dDataRef,aSitFolha)
					
Local cSituacao := 	"" //Posicione("SRA",1,Padr(cFilMat,TamSX3("RA_FILIAL")[1]) + Padr(cMatFunc,TamSX3("RA_MAT")[1]),"RA_SITFOLH")//RetSituacao(cFilMat,cMatFunc),.F.,CToD(dDataRef),,,,CToD(dDataRef))[1]

SRA->(DbSetOrder(1))

If ( SRA->(DbSeek(Padr(cFilMat,TamSX3("RA_FILIAL")[1]) + Padr(cMatFunc,TamSX3("RA_MAT")[1]))) )

	fBuscaAfast(CToD(dDataRef),CToD(dDataRef),aSitFolha,@cSituacao)//,cTipAfas,cVrbExcep,cVbTpAfas,cTipoPesq)

EndIf

If ( !Empty(cSituacao) )
	If ( cSituacao == "A" .And. Len(aSitFolha) > 0 )		
		If ( AT("AFASTADO", Upper(aSitFolha[len(aSitFolha),25])) == 0 )
			cSituacao := "AFASTADO - "
		EndIf		
		cSituacao += Alltrim(aSitFolha[len(aSitFolha),25])			
	ElseIf ( cSituacao == "D" )
		cSituacao := "DEMITIDO"
	ElseIf ( cSituacao == "F" )
		cSituacao := "FERIAS"
	Else
		cSituacao := "TRABALHADO"	
	EndIf		
Else
	cSituacao	:= "TRABALHADO"
EndIf

Return(cSituacao)
