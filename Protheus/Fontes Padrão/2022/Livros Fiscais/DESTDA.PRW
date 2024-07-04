#Include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Declaração de Substituição Tributária, Diferencial de Alíquota e Antecipação - DESTDA 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80
@param	dDtIni -> Data Incial
		dDtFin -> Data Final

/*/
//-------------------------------------------------------------------
Function DESTDA(dDtIni,dDtFin)
Local	 aTMP		:= {}
 
Default dDtIni	:= CTOD("  /  /   ")
Default dDtFin	:= CTOD("  /  /   ")

If Empty(dDtIni)
	ApagaTemp(aTMP)
Else	
	aTMP := GeraTemp()
	Processa({||ProDESTDA(dDtIni,dDtFin,aTMP)})
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Processa os registros para gerar o arquivo da DESTDA 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80
@param	dDtIni -> Data Incial
		dDtFin -> Data Final

/*/
//-------------------------------------------------------------------
Static Function ProDESTDA(dDtIni,dDtFin,aTMP)
Local cSubTrib		:= AllTrim(IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), SuperGetMv("MV_SUBTRIB")))
Local nI, nJ		:= 0
Local nTot0002		:= 0
Local nTotG600		:= 1
Local nTotG605		:= 4      
Local nTotG610		:= 0
Local nTotG615		:= 0      
Local nTotG620		:= 1
Local nTotG625		:= 0      
Local cSelect		:= "%"
Local cFrom			:= "%"
Local cWhere		:= "%"
Local cAliasQry		:= "SFT"
Local cMvCODRSEF	:= SuperGetMv("MV_CODRSEF", .F., "'','100'")

cMvCODRSEF  := IIF(Empty(cMvCODRSEF), "'','100'", cMvCODRSEF)


cSelect	+= "SFT.FT_FILIAL , SFT.FT_TIPOMOV, SFT.FT_SERIE , SFT.FT_NFISCAL, SFT.FT_CLIEFOR, SFT.FT_LOJA  , SFT.FT_ITEM , SFT.FT_PRODUTO, "
cSelect	+= "SFT.FT_CFOP   , SFT.FT_ESPECIE, SFT.FT_ESTADO, SFT.FT_EMISSAO, SFT.FT_ENTRADA, SFT.FT_DTCANC, SFT.FT_DIFAL, SFT.FT_CODISS , "
cSelect += "SFT.FT_ICMSCOM, SFT.FT_VALANTI, SFT.FT_ICMSRET, SFT.FT_FORMUL, SF4.F4_CONSUMO, SF4.F4_ATUATF, SF4.F4_ANTICMS, SF3.F3_CODRSEF "
cSelect	+= "%" 

cFrom	+= RetSqlName("SFT") + " SFT "
cFrom	+= "INNER JOIN " + RetSqlName("SF3") + " SF3 ON (SF3.F3_FILIAL='" + xFilial("SF3") + "' AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_ESPECIE=SF3.F3_ESPECIE AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.FT_ENTRADA=SF3.F3_ENTRADA AND SF3.D_E_L_E_T_ = ' ' )"
cFrom	+= " LEFT JOIN " + RetSqlName("SF4") + " SF4 ON (SF4.F4_FILIAL='" + xFilial("SF4") + "' AND SF4.F4_CODIGO=SFT.FT_TES AND SF4.D_E_L_E_T_=' ') "
cFrom   += "%" 

cWhere	+= "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
cWhere	+= "SFT.FT_ENTRADA BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFin) + "' AND "	
cWhere 	+= "(SFT.FT_TIPOMOV = 'E' AND SFT.FT_CFOP NOT IN ('1601','1602','1605') OR  "
cWhere 	+= "(SFT.FT_TIPOMOV = 'S' AND SFT.FT_CFOP NOT IN ('5601','5602','5605') AND SFT.FT_CODISS='" + Space(TamSx3('FT_CODISS')[1]) + "' AND  "
cWhere  += "  ((SFT.FT_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN (" + cMvCODRSEF + ")) OR
cWhere  += "    SFT.FT_ESPECIE NOT IN ('SPED','CTE','NFCE')))"
cWhere  += ") AND "
cWhere	+= "SFT.FT_DTCANC = '' AND SFT.D_E_L_E_T_ = ''"
cWhere  += "%"

cAliasQry	:=	GetNextAlias()

BeginSql Alias cAliasQry
		
	COLUMN FT_EMISSAO AS DATE
	COLUMN FT_ENTRADA AS DATE
	COLUMN FT_DTCANC AS DATE
		
	SELECT 
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE 
		%Exp:cWhere%
	
	ORDER BY 
		1,2,3,4,5,6,7,8
			
EndSql

Gera0002(cSubTrib,@nTot0002)

// GERA O REGISTRO G600
dbSelectArea("G01")
G01->(DbSetOrder(1))
RecLock("G01",.T.)
REF			:= StrZero(Recno(),4)
LINHA		:= "G600"
TOTNFANT	:= 0
TOTAJANT	:= 0
TOTDCANT	:= 0
cRef := REF
MsUnlock()
// GERA AS 4 OCORRÊNCIAS PARA O REGISTRO G605
For nI := 0 To 3
	If !G01->(dbSeek("G605"+cValToChar(nI)))
		RecLock("G01",.T.)					
		REF			:= cRef
		LINHA		:= "G605"
		INDSIT		:= cValToChar(nI)
		TOTNFANT	:= 0
		TOTAJANT	:= 0
		TOTDCANT	:= 0
		MsUnlock()
	EndIf
Next
// GERA O REGISTRO G620
// o indicador de tipo de emissão foi fixado na criação do campo como 1
// a cada iteração dos lançamentos o campo é atualizado
dbSelectArea("G03")
G03->(DbSetOrder(1))
RecLock("G03",.T.)
REF		:= StrZero(Recno(),4)
LINHA	:= "G620"
INDOPER	:= "1"
INDEMIT	:= "1"
TOTNFST	:= 0
TOTAJST	:= 0
TOTDCST	:= 0
TOTCBST	:= 0
cRef := REF
MsUnlock()

//Registro G625
aUfs := StrTokArr(cSubTrib, "/")
aAdd(aUfs, Getnewpar("MV_ESTADO",""))

For nI := 1 To Len(aUfs)
	cUf := Left(aUfs[nI], 2)
	For nJ := 0 To 3		
		RecLock("G03",.T.)					
		REF		:= cRef
		LINHA	:= "G625"
		INDOPER	:= "1"
		INDEMIT	:= "1"
		UF		:= cUf
		INDTPST	:= cValToChar(nJ)
		TOTNFST	:= 0
		TOTAJST	:= 0
		TOTDCST	:= 0
		TOTCBST	:= 0
		nTotG625++			
		MsUnlock()
	Next
Next

Do While !((cAliasQry)->(Eof()))
		
	AtuG600(cAliasQry)	

	GeraG610(cAliasQry,@nTotG610,@nTotG615)	

	AtuG620(cAliasQry)	
	
	(cAliasQry)->(dbSkip())
Enddo

GeraBlocoG()                      					

(cAliasQry)->(DbCloseArea())

// Grava os totais de linhas de cada tipo de registro
dbSelectArea("TOT")   
RecLock("TOT", .T.)
TOT->Tot0002 := nTot0002 
TOT->TotG600 := nTotG600 
TOT->TotG605 := nTotG605 
TOT->TotG610 := nTotG610 
TOT->TotG615 := nTotG615 
TOT->TotG620 := nTotG620 
TOT->TotG625 := nTotG625
MsUnlock()

//Posiciona as tabelas no inicio 
For nI := 1 To Len(aTMP)
	(aTMP[nI][2])->(DbGoTop())
Next	                       

Return Nil				

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Gera 0002 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function Gera0002(cSubTrib,nTot0002)
Local nPos		:= 0
Local cUf		:= ""
Local cIE_ST	:= ""

While Len(cSubTrib)>0
	nPos := At("/",cSubTrib)
	If nPos==1
		cSubTrib := AllTrim(SubStr(cSubTrib,nPos+1,Len(cSubTrib)))
		Loop
	Endif			
	cUf			:= Left(cSubTrib,2)
	cIE_ST		:= SubStr(cSubTrib,3,nPos-3)
	cSubTrib	:= AllTrim(SubStr(cSubTrib,nPos+1,Len(cSubTrib)))
	L02->(DbSetOrder(1))
	dbSelectArea("L02")   
	RecLock("L02",.T.)		
	L02->UF	:= cUf
	L02->IE_ST	:= cIE_ST
	MsUnlock()
	nTot0002++
Enddo 
L02->(DbGoTop())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Gera G600 e G605 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function AtuG600(cAliasQry)
Local nIND_SIT	:= "0"
Local nVlrNF		:= 0

//entradas interestaduais
If Substr((cAliasQry)->FT_CFOP,1,1) == "2" .And. ((cAliasQry)->FT_ICMSCOM>0 .Or. (cAliasQry)->FT_VALANTI > 0)	
	If (cAliasQry)->FT_ICMSCOM > 0  //Diferencial alíquota		
		nVlrNF := (cAliasQry)->FT_ICMSCOM
		If (cAliasQry)->F4_ATUATF == "S" //Ativo
			nIND_SIT := "0"
		Endif
		If	(cAliasQry)->F4_CONSUMO == "S" //Uso e consumo
			nIND_SIT := "1"
		EndIf
	Endif
	If (cAliasQry)->F4_ANTICMS = "1" .And. (cAliasQry)->FT_VALANTI > 0
		nVlrNF		:= (cAliasQry)->FT_VALANTI //Antecipação
		nIND_SIT	:= "2"
	Endif
	
	dbSelectArea("G01")
	G01->(DbSetOrder(1))
	//LINHA G600: TOTALIZADORES ICMS ANTECIPAÇÃO E DIFERENCIAL DE ALÍQUOTAS ENTRADAS
	dbSeek("G600")
	RecLock("G01",.F.)
	TOTNFANT	+= nVlrNF
	TOTDCANT	+= nVlrNF
	MsUnlock()
	//Registro G605: 
	dbSeek("G605"+nIND_SIT)
	RecLock("G01",.F.)
	TOTNFANT	+= nVlrNF
	TOTDCANT	+= nVlrNF
	MsUnlock()

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Gera G610 e G615 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function GeraG610(cAliasQry,nTotG610,nTotG615)
Local	cRef	:= ""

//Saídas/Valor partilha
If Substr((cAliasQry)->FT_CFOP,1,1)=="6" .And. (cAliasQry)->FT_DIFAL > 0 
	//LINHA G610: TOTALIZADOR ICMS DE PARTILHA NA VENDA INTERESTADUAL PARA CONSUMIDOR FINAL
	G02->(DbSetOrder(1))
	dbSelectArea("G02")   
	If !G02->(dbSeek("G610"))
		RecLock("G02",.T.)		
		REF			:= StrZero(Recno(),4)
		LINHA		:= "G610"
		TOTNFPAR	:= (cAliasQry)->FT_DIFAL
		TOTAJPAR	:= 0
		TOTDCPAR	:= (cAliasQry)->FT_DIFAL
		nTotG610++
		MsUnlock()
	Else			
		RecLock("G02",.F.)
		TOTNFPAR	+= (cAliasQry)->FT_DIFAL
		TOTDCPAR	+= (cAliasQry)->FT_DIFAL
		MsUnlock()
	Endif	
	cRef := REF
	
	//LINHA G615: ICMS DE PARTILHA POR UF NA VENDA INTERESTADUAL PARA CONSUMIDOR FINAL			
	cUf	:= (cAliasQry)->FT_ESTADO
	If !G02->(dbSeek("G615"+cUF))
		RecLock("G02",.T.)		
		REF			:= cRef
		LINHA		:= "G615"
		UF 			:= cUF
		TOTNFPAR	:= (cAliasQry)->FT_DIFAL
		TOTAJPAR	:= 0
		TOTDCPAR	:= (cAliasQry)->FT_DIFAL
		MsUnlock()
   		nTotG615++	
	Else
		RecLock("G02",.F.)
		TOTNFPAR	+= (cAliasQry)->FT_DIFAL
		TOTDCPAR	+= (cAliasQry)->FT_DIFAL
		MsUnlock()
	Endif	
Endif
Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Gera G620 e G625 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function AtuG620(cAliasQry)
Local 	cUf			:= ""
Local	cIndTPST	:= "0"
Local	cIndOper	:= "1"
Local	cIndEmit	:= ""
Local	cEntSai	:= Substr((cAliasQry)->FT_CFOP,1,1)

//Saidas interestaduais
If cEntSai == "6" .And. (cAliasQry)->FT_ICMSRET > 0

	//Tipo de formulario
	If (cAliasQry)->FT_FORMUL=="S"	//Emissão própria 
		cIndEmit	:= "0"
	Else	
		cIndEmit	:= "1"				//Emissão por terceiros
	Endif
	cUf			:= (cAliasQry)->FT_ESTADO

	dbSelectArea("G03")
	G03->(DbSetOrder(1))

	If dbSeek("G620")
		RecLock("G03",.F.)
		INDEMIT	:= cIndEmit
		TOTNFST	+= (cAliasQry)->FT_ICMSRET
		TOTDCST	+= (cAliasQry)->FT_ICMSRET
		MsUnlock()
	EndIf

	If dbSeek("G625"+cIndOper+cIndEmit+cUf+cIndTPST)
		RecLock("G03",.F.)
		INDEMIT	:= cIndEmit
		TOTNFST	+= (cAliasQry)->FT_ICMSRET
		TOTDCST	+= (cAliasQry)->FT_ICMSRET
		MsUnlock()
	EndIf
	
Endif		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Cria os arquivos temporários 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function GeraTemp()
Local aStru	:= {}
Local aTMP		:= {} 	 
Local cArq		:= ""   

//LINHA 0002: INSCRIÇÕES ESTADUAIS COMO CONTRIBUINTE SUBSTITUTOS EM OUTRA UF
aStru	:= {}
cArq	:= ""  
AADD(aStru,{"UF",		"C",002,0}) //Sigla da unidade da Federação do domicílio fiscal do contribuinte substituto
AADD(aStru,{"IE_ST",	"C",014,0}) //Inscrição estadual do participante emitente contribuinte-substituto na unidade da Federação do destinatário
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"L02")                      	
IndRegua("L02",cArq,"UF")
aAdd(aTMP, {cArq, Alias()})

//LINHA G600: TOTALIZADORES ICMS ANTECIPAÇÃO E DIFERENCIAL DE ALÍQUOTAS ENTRADAS			
//LINHA G605: ANTECIPAÇÃO OU DIFERENCIAL POR UF
aStru	:= {}
cArq	:= ""  
AADD(aStru,{"REF",		"C",004,0}) //
AADD(aStru,{"LINHA",		"C",004,0}) //
AADD(aStru,{"INDSIT",	"C",001,0}) //Indicador de situação de diferencial de aliquota e antecipação em operações interestaduais
AADD(aStru,{"TOTNFANT",	"N",015,2}) //Valor total das Antecipações ou Diferencial de Alíquotas destacados nas NFs de entradas interestaduais	
AADD(aStru,{"TOTAJANT",	"N",015,2}) //Valor total dos Ajustes das compras sujeitas a Antecipações ou Diferencial de Alíquotas nas entradas interestaduais	
AADD(aStru,{"TOTDCANT",	"N",015,2}) //Valor total a declarar de ICMS das Antecipações ou Diferencial de Alíquotas nas entradas interestaduais	
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"G01")                      	
cIndA	:=	Padr(cArq,7)+"A"
cIndB	:=	Padr(cArq,7)+"B"
IndRegua("G01",cIndA,"LINHA+INDSIT+REF")
IndRegua("G01",cIndB,"REF+LINHA+INDSIT")
dbClearIndex()
OrdListAdd(cIndA+OrdBagExt())
OrdListAdd(cIndB+OrdBagExt())
dbSetOrder(1)
aAdd(aTMP,{cArq,Alias()})

//LINHA G610: TOTALIZADOR ICMS DE PARTILHA NA VENDA INTERESTADUAL PARA CONSUMIDOR FINAL
//LINHA G615: ICMS DE PARTILHA POR UF NA VENDA INTERESTADUAL PARA CONSUMIDOR FINAL			
aStru	:= {}
cArq	:= ""  
AADD(aStru,{"REF",		"C",004,0}) //
AADD(aStru,{"LINHA",		"C",004,0}) //
AADD(aStru,{"UF",			"C",002,0}) //Sigla da unidade da Federação de destino das operações interestaduais
AADD(aStru,{"TOTNFPAR",	"N",015,2}) //Valor da partilha do ICMS nas vendas interestaduais para consumidor final por UF destacado nas NFs  
AADD(aStru,{"TOTAJPAR",	"N",015,2}) //Valor dos Ajustes na partilha do ICMS nas vendas interestaduais para consumidor final por UF  
AADD(aStru,{"TOTDCPAR",	"N",015,2}) //Valor a declarar  na partilha do ICMS nas vendas interestaduais para consumidor final por UF  
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"G02")                      	
cIndA	:=	Padr(cArq,7)+"A"
cIndB	:=	Padr(cArq,7)+"B"
IndRegua("G02",cIndA,"LINHA+UF+REF")
IndRegua("G02",cIndB,"REF+LINHA+UF")
dbClearIndex()
OrdListAdd(cIndA+OrdBagExt())
OrdListAdd(cIndB+OrdBagExt())
dbSetOrder(1)
aAdd(aTMP,{cArq,Alias()})

//LINHA G620: ICMS SUBSTITUIÇÃO TRIBUTÁRIA
//LINHA G625: ST - SUBSTITUIÇÃO POR UF DE DESTINO		
aStru	:= {}
cArq	:= ""  
AADD(aStru,{"REF",		"C",004,0}) //
AADD(aStru,{"LINHA",		"C",004,0}) //
AADD(aStru,{"INDOPER",	"C",001,0}) //Indicador de totalização da operações interestaduais
AADD(aStru,{"INDEMIT",	"C",001,0}) //Indicador do emitente do documento fiscal
AADD(aStru,{"UF",		 	"C",002,0}) //Indicador de totalização da operações interestaduais
AADD(aStru,{"INDTPST",	"C",001,0}) //Indicador do emitente do documento fiscal
AADD(aStru,{"TOTNFST",	"N",015,2}) //Valor da partilha do ICMS nas vendas interestaduais para consumidor final por UF destacado nas NFs  
AADD(aStru,{"TOTAJST",	"N",015,2}) //Valor dos Ajustes na partilha do ICMS nas vendas interestaduais para consumidor final por UF  
AADD(aStru,{"TOTDCST",	"N",015,2}) //Valor a declarar  na partilha do ICMS nas vendas interestaduais para consumidor final por UF  
AADD(aStru,{"TOTCBST",	"N",015,2}) //Valor total referente a ST de combustível  
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"G03")                      	
cIndA	:=	Padr(cArq,7)+"A"
cIndB	:=	Padr(cArq,7)+"B"
IndRegua("G03",cIndA,"LINHA+INDOPER+INDEMIT+UF+INDTPST")
IndRegua("G03",cIndB,"REF+LINHA+INDOPER+INDEMIT+UF+INDTPST")
dbClearIndex()
OrdListAdd(cIndA+OrdBagExt())
OrdListAdd(cIndB+OrdBagExt())
dbSetOrder(1)
aAdd(aTMP,{cArq,Alias()})

//Registros do bloco G
aStru	:= {}
cArq	:= ""  
AADD(aStru,{"LINHA","C",500,0})
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"G99")                      	
aAdd(aTMP,{cArq,Alias()})

//Cria tabela de totalizadores
aStru	:= {}
AADD(aStru,{"Tot0002",	"N",004,0})   
AADD(aStru,{"TotG600",	"N",004,0})   
AADD(aStru,{"TotG605",	"N",004,0})   
AADD(aStru,{"TotG610",	"N",004,0})  
AADD(aStru,{"TotG615",	"N",004,0}) 
AADD(aStru,{"TotG620",	"N",004,0})  
AADD(aStru,{"TotG625",	"N",004,0})
oTempRel 	:= FWTemporaryTable():New("TOT")
oTempRel:SetFields( aStru )
oTempRel:Create()
aAdd(aTMP,{"", Alias()})

Return aTMP

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@description Apaga os arquivos temporários 
@author Mauro A. Gonçalves
@since 21/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ApagaTemp(aTMP)
Local nI := 0

For nI := 1 To Len(aTMP)
	If ValType(aTMP[nI]) == "A"
		DbSelectArea(aTMP[nI][2])
		(aTMP[nI][2])->(DbCloseArea())
		Ferase(aTMP[nI][1]+GetDBExtension())
		Ferase(aTMP[nI][1]+OrdBagExt())
	ElseIf ValType(aTMP[nI]) == "O"
		aTMP[nI]:Delete()
	EndIf
Next	                       
Return

Static Function GeraBlocoG()
Local nI 		:= 0
Local cAliasG := ""
Local cLinha	:= ""           					

For nI:=1 to 3
	cAliasG := "G0"+Str(nI,1)
	(cAliasG)->(DbSetOrder(2))
	DbSelectArea(cAliasG)
	(cAliasG)->(DbGoTop())
	While !EOF()
		Do Case
			Case (cAliasG)->LINHA=="G600"
				cLinha	 := "|"+LINHA+"|||"+ConvVal(TOTDCANT)
			Case (cAliasG)->LINHA=="G605"
				cLinha	 := "|"+LINHA+"|"+INDSIT+"|||"+ConvVal(TOTDCANT)
			Case (cAliasG)->LINHA=="G610"
				cLinha	 := "|"+LINHA+"|"+ConvVal(TOTNFPAR)+"|"+ConvVal(TOTAJPAR)+"|"+ConvVal(TOTDCPAR)
			Case (cAliasG)->LINHA=="G615"
				cLinha	 := "|"+LINHA+"|"+UF+"|"+ConvVal(TOTNFPAR)+"|"+ConvVal(TOTAJPAR)+"|"+ConvVal(TOTDCPAR)
			Case (cAliasG)->LINHA=="G620"
				cLinha	 := "|"+LINHA+"|"+INDOPER+"|"+INDEMIT+"|||"+ConvVal(TOTDCST)+"|"+ConvVal(TOTCBST)
			Case (cAliasG)->LINHA=="G625"
				cLinha	 := "|"+LINHA+"|"+UF+"|"+INDTPST+"|||"+ConvVal(TOTDCST)
		EndCase			
		DbSelectArea("G99")
		RecLock("G99",.T.)
		G99->LINHA := cLinha
		MsUnlock()
		DbSelectArea(cAliasG)
		(cAliasG)->(DbSkip())
	Enddo
Next	
	
Return	
			
Static Function ConvVal(nVal)
Return AllTrim(TRANSFORM(nVal,"@E 99999999999.99"))			
