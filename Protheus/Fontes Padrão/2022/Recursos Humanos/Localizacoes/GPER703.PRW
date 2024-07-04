#Include "PROTHEUS.CH"
#Include "GPER703.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER703  ³ Autor ³ Ricardo Berti	                  ³ Data ³08/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³	Geracao de TXT - DEPENDIENTES para Sistema DAVINCI 					³±±
±±³          ³  			Localizacao BOLIVIA		                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER703()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ CHAMADO  	 ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³              ³                                          ³±±
±±³Jonathan Glz³06/05/2015³    PCREQ-4256³Se elimina la funcion AjustaSx1,la cual   ³±±
±±³            ³          ³              ³realiza la modificacion aldiccionario de  ³±±
±±³            ³          ³              ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³          ³              ³estructura de SXs para version 12         ³±±
±±³Jonathan Glz³27/12/2016³SERINN001-792 ³Se modifica uso de tablas temporales por  ³±±
±±³            ³          ³              ³motivo de limpieza de CTREE en la funcion ³±±
±±³            ³          ³              ³G703CriTMP().                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER703()

Local cPerg		:= "GPR703"
Local nOpca		:= 0
Local cMsg		:= ""
Local aSays		:= {}, aButtons := {} //<== arrays locais de preferencia
Local cTitMoeda := SubStr(GetMV("MV_SIMB1"),1,3)+" "

Private nVlDepDVin	:= 0
Private aOrder     := {}
Private oTmpTable

// Obtem Mnemonico
dbSelectArea("RCA")
dbSetorder(1)
If dbSeek(xFilial('RCA') + "P_NVLDEPDVIN")
	nVlDepDVin := Val(RCA->RCA_CONTEU)
EndIf

Pergunte(cPerg,.F.)

AADD(aSays,STR0002)		//"Este programa gera o arquivo TXT de Dependentes, que tenham ingresos, saldos"
AADD(aSays,STR0003+cTitMoeda+Ltrim(Transform(nVlDepDVin,GetSx3Cache("RA_SALARIO","X3_PICTURE")))+STR0004)		//"ou salários brutos superiores a Bs 7.000,00 (*) para uso no Sistema DAVINCI."
AADD(aSays,"")
AADD(aSays,"")
AADD(aSays,"")
AADD(aSays,STR0005)		//"(*) Este valor referência é o parâmetro NVLDEPDVIN (Mnemônico)"
AADD(aSays,STR0006)		//"     e pode ser atualizado pela rotina de Mnemônicos."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpTudoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( STR0001, aSays, aButtons ) // "Geração do arquivo TXT - Dependentes DaVinci"

If nOpca == 1

	Processa({|lEnd| GPR703Proc(cPerg),STR0001})

EndIf

If oTmpTable <> Nil   //JGR
	oTmpTable:Delete()  //JGR
	oTmpTable := Nil //JGR
Endif //JGR


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ gpTudoOK ³ Autor ³ Ricardo Berti	                  ³ Data ³08/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao dos dados antes de executar o processo						³±±
±±³          ³		                                                				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gpTudoOK(ExpC1)	                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Grupo de pergunte 		                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER703                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function gpTudoOK(cPerg)

Local lRet	:= .T.
Local cFile	:= AllTrim(mv_par12)

Pergunte(cPerg,.F.)

If Empty(mv_par01) .Or. Empty(mv_par02) .Or. Empty(mv_par03)
	MsgAlert(STR0012) // "Os parâmetros Selecao de Processos, Roteiro e Mês/Ano são de preenchimento obrigatório!"
	lRet := .F.
EndIf

If lRet .And. nVlDepDVin <= 0
	MsgAlert( STR0013 + STR0014) // "Valor inválido para parâmetro NVLDEPDVIN (Mnemônico)."####" Vide Boletim Técnico."
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o Arquivo TXT                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. File(cFile) .And. !MsgYesNo(STR0007+CRLF+STR0008)	//  "O arquivo já existe."###"Deseja sobrescrever?"
	lRet := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GPR703Proc ³ Autor ³ Ricardo Berti	      ³ Data ³08/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do TXT Dependientes DaVinci							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER703                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR703Proc(cPerg)

Local aRegSRA	:= {}
Local aVerba 	:= Array(14,1)
Local cAliasQry := GetNextAlias()
Local cAliasTMP := GetNextAlias()
Local cAuxPrc	:= ""
Local cDtGerTXT := DTOS(CTOD("//"))
Local cSitQuery	:= ""
Local cCatQuery	:= ""
Local cProcQuery:= ""
Local cRotQuery := ""
Local cFilPd	:= If( Alltrim(FWModeAccess("SRV",3)) == "C", "%'" + xFilial("SRV") + "'%", "%SRA.RA_FILIAL%" )
Local cOrdem	:= "% RA_FILIAL, RA_MAT, PD, SEQ %"
Local cNumCI
Local cUFCI
Local cPRISOBR
Local cSECSOBR
Local cPRINOME
Local cSECNOME
Local cENDEREC
Local nTamCod	:= 0
Local nX		:= 0
Local nMax		:= 0
Local nRegSRA	:= 0
Local nTotGanad := 0

Local cProcessos:= mv_par01
Local cRoteiro	:= mv_par02
Local cPeriodo	:= SubStr(mv_par03,3,4) + SubStr(mv_par03,1,2)
Local cFilDe	:= mv_par04
Local cFilAte	:= mv_par05
Local cMatDe	:= mv_par06
Local cMatAte	:= mv_par07
Local cCCDe		:= mv_par08
Local cCCAte	:= mv_par09
Local cNomDe 	:= mv_par10
Local cNomAte 	:= mv_par11
Local cSituacao	:= mv_par12
Local cCategoria:= mv_par13

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //  Selecao de Processos				 	   ³
³ mv_par02        //  Roteiro							       ³
³ mv_par03        //  Mes/Ano Competencia ? 		           |
³ mv_par04        //  Filial De						           ³
³ mv_par05        //  Filial Ate						       ³
³ mv_par06        //  Matricula 	                           ³
³ mv_par07        //  Matricula 	                           ³
³ mv_par08        //  Centro de Custo De                       ³
³ mv_par09        //  Centro de Custo Ate                      ³
³ mv_par10        //  Nome De                                  ³
³ mv_par11        //  Nome Ate                                 ³
³ mv_par12        //  Situacoes ?		                       ³
³ mv_par13        //  Categorias ?      		               ³
³ mv_par14        //  Path/Nome Arquivo TXT ?                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private aInfo		:= Array(26)
Private cArqNome	:= mv_par14				// Nome arquivo TXT

G703CriTMP(cAliasTMP)		//--- Cria arquivo temporario

// Processos
nTamCod := GetSx3Cache( "RCJ_CODIGO" , "X3_TAMANHO" )
For nX := 1 to Len(cProcessos) step 5
	If Len(Subs(cProcessos,nX,5)) < nTamCod
		cAuxPrc := Subs(cProcessos,nX,5) + Space(nTamCod - Len(Subs(cProcessos,nX,5)))
	Else
		cAuxPrc := Subs(cProcessos,nX,5)
	EndIf
	cProcQuery += "'" + cAuxPrc + "',"
Next nX
cProcQuery := "%" + Substr( cProcQuery, 1, Len(cProcQuery)-1) + "%"

// Roteiros
For nX:=1 to Len(cRoteiro) Step 3
	If Subs(cRoteiro,nX,3) <> '***'
		cRotQuery += "'"+Subs(cRoteiro,nX,3)+"', "
	EndIf
Next nX
cRotQuery	:= "%" + Subs(cRotQuery,1,Len(cRotQuery)-2) + "%"

cSitQuery	:= ""
If !Empty(cSituacao)
	For nX:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nX,1)+"'"
		If ( nX+1 ) <= Len(cSituacao)
			cSitQuery += ","
		Endif
	Next
	cSitQuery := "%" + cSitQuery + "%"
EndIf

cCatQuery	:= ""
If !Empty(cSituacao)
	For nX:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nX,1)+"'"
		If ( nX+1 ) <= Len(cCategoria)
			cCatQuery += ","
		Endif
	Next
	cCatQuery := "%" + cCatQuery + "%"
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Processa os dados gravando arq. temporario   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

BeginSql alias cAliasQry

		SELECT	SRA.RA_FILIAL,			SRA.RA_MAT,				SRA.RA_CC,				SRA.RA_NOME,
				SRA.RA_PRISOBR,			SRA.RA_SECSOBR,			SRA.RA_PRINOME,			SRA.RA_SECNOME,
				SRA.RA_CATFUNC,			SRA.RA_CIC,				SRA.RA_SALARIO,			SRA.RA_SITFOLH,
				SRA.RA_UFCI,			SRA.RA_ENDEREC,			SRA.R_E_C_N_O_ REGSRA,
				SRC.RC_FILIAL FILIAL,	SRC.RC_MAT MAT,			SRC.RC_CC CCUSTO,		SRC.RC_PD PD,
				SRC.RC_VALOR VALOR,		SRC.RC_SEQ SEQ,			SRC.RC_PROCES PROCES,
				SRC.RC_PERIODO PERIODO,	SRC.RC_NUMID NUMID,		SRC.RC_ROTEIR ROTEIR,
				SRV.RV_COD,				SRV.RV_INFSAL INFSAL,	SRV.RV_INSS INSS
		FROM %table:SRA% SRA

		INNER JOIN	%table:SRC% SRC
		ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
				SRA.RA_MAT    = SRC.RC_MAT		AND
				SRA.RA_CC     = SRC.RC_CC

		INNER JOIN 	%table:SRV% SRV
		ON		SRV.RV_FILIAL = %exp:cFilPd%	AND
				SRV.RV_COD    = SRC.RC_PD

		WHERE	SRA.RA_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte% AND
				SRA.RA_MAT    BETWEEN %Exp:cMatDe% AND %Exp:cMatAte% AND
				SRA.RA_CC     BETWEEN %Exp:cCcDe%  AND %Exp:cCcAte%  AND
				SRA.RA_NOME   BETWEEN %Exp:cNomDe% AND %Exp:cNomAte% AND
				SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
		   		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		   		SRA.RA_DTDEPDV  = (%exp:cDtGerTXT%) AND
		   		SRC.RC_PROCES  IN (%exp:Upper(cProcQuery)%)  AND
		   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
		   		SRC.RC_ROTEIR  IN  (%exp:Upper(cRotQuery)%)  AND
		   		SRV.RV_INFSAL <> %exp:""% AND
		   		SRV.RV_INSS = (%exp:"S"%) AND
				SRA.%notDel% AND SRC.%notDel% AND SRV.%notDel%
		UNION

		(SELECT SRA.RA_FILIAL,			SRA.RA_MAT,				SRA.RA_CC,				SRA.RA_NOME,
				SRA.RA_PRISOBR,			SRA.RA_SECSOBR,			SRA.RA_PRINOME,			SRA.RA_SECNOME,
				SRA.RA_CATFUNC,			SRA.RA_CIC,				SRA.RA_SALARIO,			SRA.RA_SITFOLH,
				SRA.RA_UFCI,			SRA.RA_ENDEREC,			SRA.R_E_C_N_O_ REGSRA,
				SRD.RD_FILIAL FILIAL,	SRD.RD_MAT MAT,			SRD.RD_CC CCUSTO,		SRD.RD_PD PD,
				SRD.RD_VALOR VALOR,		SRD.RD_SEQ SEQ,			SRD.RD_PROCES PROCES,
				SRD.RD_PERIODO PERIODO,	SRD.RD_NUMID NUMID,		SRD.RD_ROTEIR ROTEIR,
				SRV.RV_COD,				SRV.RV_INFSAL INFSAL,	SRV.RV_INSS INSS
		FROM %table:SRA% SRA

		INNER JOIN %table:SRD% SRD
		ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
				SRA.RA_MAT    = SRD.RD_MAT		AND
				SRA.RA_CC     = SRD.RD_CC

		INNER JOIN %table:SRV% SRV
		ON		SRV.RV_FILIAL 	= %exp:cFilPd%	AND
				SRV.RV_COD    	= SRD.RD_PD

		WHERE	SRA.RA_FILIAL BETWEEN %Exp:cFilDe% AND %Exp:cFilAte% AND
				SRA.RA_MAT    BETWEEN %Exp:cMatDe% AND %Exp:cMatAte% AND
				SRA.RA_CC     BETWEEN %Exp:cCcDe%  AND %Exp:cCcAte%  AND
				SRA.RA_NOME   BETWEEN %Exp:cNomDe% AND %Exp:cNomAte% AND
				SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
		   		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		   		SRA.RA_DTDEPDV  = (%exp:cDtGerTXT%) AND
		   		SRD.RD_PROCES  IN (%exp:Upper(cProcQuery)%)  AND
		   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
		   		SRD.RD_ROTEIR  IN (%exp:Upper(cRotQuery)%)   AND
		   		SRV.RV_INFSAL <> (%exp:""%) AND
		   		SRV.RV_INSS = (%exp:"S"%) AND
				SRA.%notDel% AND SRD.%notDel% AND SRV.%notDel%)
		ORDER BY %exp:cOrdem%

EndSql

Count TO nMax
ProcRegua(nMax) // Número de registros a procesar
dbGoTop()
cCodFilial := "_"

Do While (cAliasQry)->(!Eof())

	For nX := 1 To 6
		aVerba[nX,1] := 0
	Next

	If cCodFilial <> (cAliasQry)->RA_FILIAL
		cCodFilial	:= (cAliasQry)->RA_FILIAL
		fInfo(@aInfo,(cAliasQry)->RA_FILIAL)	//Carrega array com informacoes da Filial
	EndIf
	cMatAnt := (cAliasQry)->RA_MAT
	nRegSRA	:= (cAliasQry)->REGSRA
	cNumCI	:= (cAliasQry)->RA_CIC
	cUFCI	:= (cAliasQry)->RA_UFCI
	cPRISOBR:= (cAliasQry)->RA_PRISOBR
	cSECSOBR:= (cAliasQry)->RA_SECSOBR
	cPRINOME:= (cAliasQry)->RA_PRINOME
	cSECNOME:= (cAliasQry)->RA_SECNOME
	cENDEREC:= (cAliasQry)->RA_ENDEREC

	IncProc("Procesando...")

	Do While (cAliasQry)->(!Eof()) .And. (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT == cCodFilial+cMatAnt

		Do Case
			Case (cAliasQry)->INFSAL $ "A"
				aVerba[1,1] += (cAliasQry)->VALOR
			Case (cAliasQry)->INFSAL == "B"
		   		aVerba[2,1] += (cAliasQry)->VALOR
			Case (cAliasQry)->INFSAL == "C"
		   		aVerba[3,1] += (cAliasQry)->VALOR
			Case (cAliasQry)->INFSAL == "D"
			   	aVerba[4,1] += (cAliasQry)->VALOR
			Case (cAliasQry)->INFSAL == "F"
		   		aVerba[5,1] += (cAliasQry)->VALOR
			Case (cAliasQry)->INFSAL == "E"
			   	aVerba[6,1] += (cAliasQry)->VALOR
		EndCase

		(cAliasQry)->(DbSkip())
	EndDo

	nTotGanad := aVerba[1,1] + aVerba[2,1] + aVerba[3,1] + aVerba[4,1] + aVerba[5,1] + aVerba[6,1]

	If nTotGanad > 0 .And. nTotGanad > nVlDepDVin

		Aadd(aRegSRA,{nRegSRA})

		G703Grava(cAliasTMP,cNumCI,cUFCI,cPRISOBR,cSECSOBR,cPRINOME,cSECNOME,cENDEREC)

	EndIf

EndDo
(cAliasQry)->(dbCloseArea())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Gera o arquivo texto                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Len(aRegSRA) > 0

	G703GerTXT(cAliasTMP,aRegSRA)

Else
	MsgStop(STR0009+cArqNome)	// "Não foi gerado o arquivo "
Endif

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ G703Grava  ³ Autor ³ Ricardo Berti	      ³ Data ³08/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Grava um registro no arq. temporario		                 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER703		                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function G703Grava(cAliasTMP,cNumCI,cUFCI,cPRISOBR,cSECSOBR,cPRINOME,cSECNOME,cENDEREC)

RecLock(cAliasTMP,.T.)
(cAliasTMP)->TMP_CI		:= cNumCI
(cAliasTMP)->TMP_UFCI	:= cUFCI
(cAliasTMP)->TMP_APPAT	:= cPRISOBR
(cAliasTMP)->TMP_APMAT	:= cSECSOBR
(cAliasTMP)->TMP_NOME	:= Left(Trim(cPRINOME)+" "+cSECNOME ,20)
(cAliasTMP)->TMP_DIREC	:= cENDEREC
(cAliasTMP)->TMP_NIT	:= aInfo[8]
(cAliasTMP)->(MsUnlock())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³G703CriTMP³ Autor ³ Ricardo Berti	      	³ Data ³08/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria arquivo temporario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPER703									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G703CriTMP(cAliasTMP)

Local aCampos   := {}
Local cTrab

aAdd( aCampos, { 'TMP_CI'		, "C",  9	, 0 } )
aAdd( aCampos, { 'TMP_UFCI'		, "C",  2	, 0 } )
aAdd( aCampos, { 'TMP_APPAT'	, "C", 20	, 0 } )
aAdd( aCampos, { 'TMP_APMAT'	, "C", 20	, 0 } )
aAdd( aCampos, { 'TMP_NOME'		, "C", 20	, 0 } )
aAdd( aCampos, { 'TMP_DIREC'	, "C", 40	, 0 } )
aAdd( aCampos, { 'TMP_NIT'		, "C", 14	, 0 } )

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
EndIf

//Efetua a criacao do arquivo temporario
aOrder	:=	{"TMP_CI"} //JGR
oTmpTable := FWTemporaryTable():New(cAliasTMP) //JGR
oTmpTable:SetFields( aCampos ) //JGR
oTmpTable:AddIndex("I01", aOrder) //JGR
oTmpTable:Create() //JGR

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G703GerTXT   ³ Autor ³ Ricardo Berti	     ³ Data ³ 08/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que gera o arquivo texto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER703		                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G703GerTXT(cAliasTMP,aRegSRA)

Local cLinDet	:= ""
Local cSep	  	:= "|"
Local nX		:= 0
Local nHandle 	:= MSFCREATE(cArqNome)

If FERROR() # 0 .Or. nHandle < 0
	Help('',1, "OPENERROR",,STR0010+cArqNome,1)  // "Erro na criação do arquivo "
	FClose(nHandle)
	Return Nil
EndIf

dbSelectArea(cAliasTMP)
dbGoTop()

While !Eof()

	cLinDet	:=	"CI"						+cSep+;
				AllTrim(TMP_CI)	  			+cSep+;
				AllTrim(TMP_UFCI)	  		+cSep+;
				AllTrim(TMP_APPAT)	  		+cSep+;
				AllTrim(TMP_APMAT)	  		+cSep+;
				AllTrim(TMP_NOME)	  		+cSep+;
				AllTrim(TMP_DIREC)	  		+cSep+;
				AllTrim(TMP_NIT)
	FWrite(nHandle,cLinDet+CRLF)

	dbSkip()
EndDo
FClose(nHandle)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Atualiza Data de Geracao TXT no cad. funcionario    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
dbSelectArea("SRA")

ProcRegua(Len(aRegSRA)) // Número de registros a procesar

For nX:=1 To Len(aRegSRA)
	//-- Posiciona SRA
	IncProc("Procesando TXT...")
	SRA->(DbGoto(aRegSRA[nX,1]))
	If Empty(SRA->RA_DTDEPDV)
		RecLock("SRA",.F.)
		SRA->RA_DTDEPDV := dDataBase
		MsUnlock()
	EndIf
Next nX

MsgInfo(STR0011) // "O arquivo foi gerado com sucesso."

Return Nil
