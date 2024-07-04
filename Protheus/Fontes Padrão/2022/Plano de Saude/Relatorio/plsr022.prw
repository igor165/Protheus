#INCLUDE "plsr022.ch"
#include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "PLSMGER.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

#define ALLMOV "1"
#define USRMOV "2"
#define FAMMOV "3"
#define __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*/{Protheus.doc} PLSR022
//Relatorio do Extrado de utilização do usuário
@author victor.silva
@since 25/04/2017
@param lWeb, logical, descricao
/*/
function PLSR022(cMV_PAR01,cMV_PAR02,cMV_PAR03,cMV_PAR04,cMV_PAR05,cMV_PAR06,cMV_PAR07,cMV_PAR08,cMV_PAR09,cMV_PAR10,cMV_PAR11,cMV_PAR12)
	local cOperad  	:= ""
	local cEmpresa 	:= "" 
	local cContrat 	:= ""
	local cSubCont 	:= ""
	local cFamilia 	:= ""
	local cBenefic 	:= ""
	local dDataDe  	:= CtoD('')
	local dDataAte	:= CtoD('')
	local cAnoDe   	:= ""
	local cMesDe   	:= ""
	local cAnoAte  	:= ""
	local cMesAte  	:= ""
	local cStatus	:= ""
	local nFase    	:= 0
	local cPerg   	:= "PLR022"
	local lWeb		:= FunName() == "RPC"
	local aRet		:= {}
	
	private oPrint	:= nil
	private cTitulo	:= "EXTRATO DE UTILIZACAO"
	private cRelName:= "PLSR022" + "_" + DtoS(Date()) + "_" + StrTran(Time(),":")
	private cPathSrv:= iif(lWeb,__RELIMP,GetNewPar("MV_RELT","\spool\"))

	aAlias := {"BA0","BD6","BTS","BIH","BI3","BII","BA1","BF7","BI6","BI4","BAT","BG9","BQC"}
	objCENFUNLGP:setAlias(aAlias)
	
	if lWeb
		Pergunte(cPerg,.F.)
		MV_PAR01 := cMV_PAR01 //Operadora
		MV_PAR02 := cMV_PAR02 //Empresa
		MV_PAR03 := cMV_PAR03 //Contrato
		MV_PAR04 := cMV_PAR04 //Sub-contrato
		MV_PAR05 := cMV_PAR05 //Familia
		MV_PAR06 := cMV_PAR06 //Usuario
		MV_PAR07 := cMV_PAR07 //Data inicial
		MV_PAR08 := cMV_PAR08 //Data final
		MV_PAR09 := cMV_PAR09 //Ano de
		MV_PAR10 := cMV_PAR10 //Mes de
		MV_PAR11 := cMV_PAR11 //Ano ate
		MV_PAR12 := cMV_PAR12 //Mes ate
		cStatus := AllTrim(GetNewPar("MV_PLSPEXT","3"))
	Else
		Pergunte(cPerg,.T.)
	Endif

	if lAutoSt
		Pergunte(cPerg,.F.)
	endif

	// Acessa parametros do relatorio...
	cOperad  := MV_PAR01
	cEmpresa := MV_PAR02
	cContrat := MV_PAR03
	cSubCont := MV_PAR04
	cFamilia := MV_PAR05
	cBenefic := MV_PAR06
	dDataDe  := MV_PAR07
	dDataAte := MV_PAR08
	cAnoDe   := MV_PAR09
	cMesDe   := MV_PAR10
	cAnoAte  := MV_PAR11
	cMesAte  := MV_PAR12
	nFase    := MV_PAR13
	
	if !lWeb .AND. !lAutoSt
		RptStatus({|lEnd| PLSR022Imp(	@lEnd,lWeb,cOperad, cEmpresa, cContrat, cSubCont, cFamilia, cBenefic,;
			dDataDe, dDataAte, cAnoDe, cMesDe, cAnoAte, cMesAte, nFase, cStatus)},cTitulo)
	else
		aRet := PLSR022Imp( .F.,lWeb,cOperad, cEmpresa, cContrat, cSubCont, cFamilia, cBenefic,;
			dDataDe, dDataAte, cAnoDe, cMesDe, cAnoAte, cMesAte, nFase, cStatus)
	endif
	
Return aRet

/*/{Protheus.doc} PLSR022Imp
//Realiza a impressão do relatorio
@author victor.silva
@since 25/04/2017
@param lEnd, logical, descricao
@param lWeb, , descricao
@param cStatus, characters, descricao
/*/
Static Function PLSR022Imp(lEnd,lWeb,cOperad, cEmpresa, cContrat, cSubCont, cFamilia, cBenefic, dDataDe, dDataAte, cAnoDe, cMesDe, cAnoAte, cMesAte, nFase, cStatus)
	local cArqTrab		:= GetNextAlias()
	local cCodInt		:= Subs(cBenefic,atCodOpe[1],atCodOpe[2])
	local cCodEmp 		:= Subs(cBenefic,atCodEmp[1],atCodEmp[2])
	local cMatric 		:= Subs(cBenefic,atMatric[1],atMatric[2])
	local cTipoReg		:= Subs(cBenefic,atTipReg[1],atTipReg[2])
	local cDigito 		:= Subs(cBenefic,atDigito[1],atDigito[2])
	local nLinBkp		:= 0
	local nColBkp		:= 0
	local nColCalc		:= 0
	local aDados		:= {}
	local aValBM1		:= {}
	local aValTot		:= {}
	local cTpFil		:= ""
	local nI			:= 1
	local nX			:= 1
	local nY			:= 1
	local nZ			:= 1
	local nLinRef		:= 0
	Local aDadCons 		:= {} // Consulta
	Local aDadExam 		:= {} // Exame/Terapia
	Local aDadOdon 		:= {} // Odontologia
	Local aDadInte 		:= {} // Internação
	Local aDadOutr 		:= {} // Outros
	Local nNx 			
	
	private nLinMax		:= 0
	private nColMax		:= 0
	private nLinIni		:= 0
	private nColIni		:= 0
	private oFontDef1  	:= TFont():New("Arial",  8,  8, , .F., , , , .T., .F.) // Padrao
	private oFontDef2	:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Padrao reduzida
	private oFontDef3  	:= TFont():New("Arial",  7,  7, , .F., , , , .T., .F.) // Padrao
	private oFontBld1	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	private oFontBld2	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	private oFontBld3	:= TFont():New("Arial",  7,  7, , .T., , , , .T., .F.) // Negrito
	
	default lEnd		:= .F.
	default lWeb        := .F.
	default cOperad     := ""
	default cEmpresa    := ""
	default cContrat    := ""
	default cSubCont    := ""
	default cFamilia    := ""
	default cBenefic    := ""
	default dDataDe     := StoD("")
	default dDataAte    := StoD("")
	default cAnoDe      := ""
	default cMesDe      := ""
	default cAnoAte     := ""
	default cMesAte     := ""
	default nFase       := 0
	default cStatus     := ""

	If lAutoSt
		lWeb := lAutoSt
	endif

	// Não é permitido gera o relatorio para anos diferentes, por exemplo de dez/2019 até jan/2020
	If YEAR(dDataDe) <> YEAR(dDataAte) .Or. ;
	    IIF(!lWeb .And. (Val(cAnoDe) > 0) .And. (Val(cAnoAte) > 0),cAnoDe <> cAnoAte,.F.) // Quando não for portal verifica também o cAnoDe e cAnoAte

		if !lWeb
			MsgAlert("Permitido somente para o mesmo ano informado (De/Até)")
			return()
		else
			return({.F.,"Permitido somente para o mesmo ano informado (De/Até)"})
		endif
	EndIf
	
	//Define como a rotina foi filtrada atraves dos parametros informados
	if empty(cBenefic + cFamilia)
		cTpFil := ALLMOV
	elseif !empty(cBenefic) .And. empty(cFamilia)
		cTpFil := USRMOV
	else
		cTpFil := FAMMOV
	endif
	
	//Monta o filtro de acordo com parametros
	cFilter := "%"
	if cTpFil == USRMOV
		cFilter += "BD6_OPEUSR = '" + cCodInt +  "' AND "
		cFilter += "BD6_CODEMP = '" + cCodEmp +  "' AND "
		cFilter += "BD6_MATRIC = '" + cMatric +  "' AND "
		cFilter += "BD6_TIPREG = '" + cTipoReg + "' AND "
		cFilter += "BD6_DIGITO = '" + cDigito +  "' AND "
	elseif cTpFil == FAMMOV
		cFilter += "BD6_OPEUSR = '" + cOperad +  "' AND "
		cFilter += "BD6_CODEMP = '" + cEmpresa + "'	AND "
		cFilter += "BD6_MATRIC = '" + cFamilia + "' AND "
		cFilter += "BD6_CONEMP = '" + cContrat + "'	AND "
		cFilter += "BD6_SUBCON = '" + cSubCont + "'	AND "
	else
		cFilter += "BD6_OPEUSR = '" + cOperad +  "' AND "
		cFilter += "BD6_CODEMP = '" + cEmpresa + "'	AND "
		cFilter += "BD6_CONEMP = '" + cContrat + "'	AND "
		cFilter += "BD6_SUBCON = '" + cSubCont + "'	AND "
	endif
	cFilter += "%"
	
	cWhere := "%"
	if !lWeb
		if nFase == 1
			cWhere += "BD6_FASE = '3' AND "
		elseif nFase == 2
			cWhere += "BD6_FASE = '4' AND " 
		elseif nFase == 3
			cWhere += "BD6_FASE = '2' AND "
		endif
	elseif !empty(cStatus)
		if At("/", cStatus)
			cWhere += "BD6_FASE IN " + FormatIn(cStatus,"/") + " AND"
		elseif At(",",cStatus)
			cWhere += "BD6_FASE IN " + FormatIn(cStatus,",") + " AND"
		else
			cWhere += "BD6_FASE = '" + cStatus + "' AND"
		endif
	endif
	cWhere += " BD6_LIBERA <> '1' AND %" 
	
	
	BeginSql Alias cArqTrab
		SELECT 	BD6_CODOPE, BD6_CONEMP, BD6_VERCON, BD6_SUBCON, BD6_VERSUB, BD6_OPEUSR, BD6_FADENT, BD6_CODEMP, BD6_MATRIC,
		BD6_TIPREG, BD6_DENREG, BD6_VLRTPF, BD6_DIGITO, BD6_ANOPAG, BD6_MESPAG, BD6_NOMUSR, BD6_CODRDA, BD6_NOMRDA,
		BD6_FASE,   BD6_DATPRO, BD6_QTDPRO, BD6_STAFAT, BD6_SITUAC, BD6_DESLOC, BD6_CODPAD, BD6_CODPRO, BD6_DESPRO,
		BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_VLRPAG, BD6_VLRTPF, BD6_MATVID, BD6_VLRGLO, BD6_CODPLA, BD6_TIPGUI,
		BD6_TIPRDA, BD6_CPFRDA, BD6_TPEVCT
		
		FROM %table:BD6% BD6
		
		WHERE 	BD6_FILIAL  = %xFilial:BD6% 		AND
		%exp:cFilter%
		BD6_DATPRO >= %exp:DTOS(dDataDe)%	AND
		BD6_DATPRO <= %exp:DTOS(dDataAte)%	AND
		BD6_ANOPAG >= %exp:cAnoDe%			AND
		BD6_MESPAG >= %exp:cMesDe%			AND
		BD6_ANOPAG <= %exp:cAnoAte%			AND
		BD6_MESPAG <= %exp:cMesAte%			AND
		%exp:cWhere%
		BD6.%notdel%
		
		
		ORDER BY
		BD6_DATPRO, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_TIPGUI
	EndSql
	
	if (cArqTrab)->(Eof())
		if !lWeb
			MsgAlert("Não existe registros a serem retornados")
			return()
		else
			return({.F.,"Nenhuma informação foi encontrada"})
		endif
	endif
	
	// Retorna os dados principais
	aDados := BuildData(cArqTrab,cTpFil,@aValTot,lWeb)
	
	// Retorna os valores
	aValBM1 := RetValBM1(cTpFil,cMesDe,cAnoDe,cMesAte,cAnoAte,cBenefic,cFamilia,cOperad,cEmpresa,cContrat,cSubCont,dDataDe, dDataAte)
	
	// Retorna os dados principais baseado no filtro realizado
	if cTpFil == USRMOV
		aDadUsr := BldDataUsr(aDados)

		For nNx := 1 To Len(aDadUsr[1][2])
			Do Case
				Case aDadUsr[1][2][nNx][15][1] == "Consulta"
					aAdd(aDadCons,aDadUsr[1][2][nNx])
				Case aDadUsr[1][2][nNx][15][1] == "Exames/Terapias"
					aAdd(aDadExam,aDadUsr[1][2][nNx])
				Case aDadUsr[1][2][nNx][15][1] == "internações"
					aAdd(aDadInte,aDadUsr[1][2][nNx])
				Case aDadUsr[1][2][nNx][15][1] == "Odonto"
					aAdd(aDadOdon,aDadUsr[1][2][nNx])
				Case aDadUsr[1][2][nNx][15][1] == "Outros"
					aAdd(aDadOutr,aDadUsr[1][2][nNx])
			EndCase
		Next

	elseif cTpFil == FAMMOV
		aDadFam := BldDataFam(aDados)
	else
		aDadMov := BldDataMov(aDados)
	endif
	
	(cArqTrab)->(dbCloseArea())
	
	// Posiciona na operadora informada
	BA0->(dbSetOrder(1)) //BA0_FILIAL + BA0_CODIDE + BA0_CODINT
	BA0->(MsSeek(xFilial("BA0")+ cOperad))
		
	oPrint := FWMSPrinter():New(cRelName,,.F.,cPathSrv,.T.,,,,,.F.)
	
	// Definindo as propriedades
	if lWeb
		oPrint:lServer := lWeb		// Indica se e oriundo do Portal do Beneficiario
		oPrint:setDevice(IMP_PDF)	// Força a impressao em PDF caso for portal
	else
		oPrint:Setup()				// Inicializa o SETUP

		If oPrint:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ({.F.,"",""})
		EndIf
	endif
	oPrint:SetLandscape()			// Seta o relatorio para o modo paisagem
	
	// Forca tamanho A4
	oPrint:setPaperSize(9)
	
	// Inicializa as variaveis de posicionamento
	nLinMax	:= 570
	nColMax	:= 820
	nLinIni := 010
	nColIni := 005
	
	oPrint:StartPage()				// Inicia a primeira pagina
	
	// Cria o box principal
	oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
	
	// Carrega cabeçalho Inicial
	oPrint:Say(	nLinIni + 0030, nColIni + (nColMax * 0.30), cTitulo, oFontBld1,,,,2)
	oPrint:Say(	nLinIni + 0040, nColIni + (nColMax * 0.30), objCENFUNLGP:verCamNPR("BA0_NOMINT",Alltrim(BA0->BA0_NOMINT)), oFontDef1,,,,2)
	oPrint:Say(	nLinIni + 0050, nColIni + (nColMax * 0.30), objCENFUNLGP:verCamNPR("BA0_END",Alltrim(BA0->BA0_END)) + " - CEP " +;
															objCENFUNLGP:verCamNPR("BA0_CEP",AllTrim(BA0->BA0_CEP)) + " " +;
															objCENFUNLGP:verCamNPR("BA0_CIDADE",AllTrim(BA0->BA0_CIDADE)) + " (" +;
															objCENFUNLGP:verCamNPR("BA0_EST",BA0->BA0_EST) + ")" , oFontDef1,,,,2)
	oPrint:Say(	nLinIni + 0060, nColIni + (nColMax * 0.30), "C.G.C. "+objCENFUNLGP:verCamNPR("BA0_CGC",Alltrim(Transform(BA0->BA0_CGC,PesqPict("BA0","BA0_CGC"))))+;
		if(BA0->(FieldPos("BA0_INCEST")) > 0, "  Insc.Est.: "+objCENFUNLGP:verCamNPR("BA0_INCEST",AllTrim(BA0->BA0_INCEST)),""),oFontDef1,,,,2)
	oPrint:Say(	nLinIni + 0070, nColIni + (nColMax * 0.30), "Registro da operadora na ANS. "+objCENFUNLGP:verCamNPR("BA0_SUSEP",Alltrim(BA0->BA0_SUSEP)))
	
	
	oPrint:Say(	nLinIni + 0030, (nColMax * 0.70), "Informações ANS", oFontBld1,,,,2)
	oPrint:Say(	nLinIni + 0040, (nColMax * 0.70) , "Endereço Av. Bela Cintra, nº 986 - 9º andar - Edifício Rachid Saliba", oFontDef2,,,,2)
	oPrint:Say(	nLinIni + 0050, (nColMax * 0.70) , "Bairro Jardim Paulista -São Paulo-São Paulo", oFontDef2,,,,2)
	oPrint:Say(	nLinIni + 0060, (nColMax * 0.70) , "CEP: 01415-000 Disque ANS: 0800 701 9656 ", oFontDef2,,,,2)
	oPrint:Say(	nLinIni + 0070, (nColMax * 0.70) , "Site: www.ans.gov.br", oFontDef2,,,,2)
	
	// Marca a referencia da proxima linha apos o cabecalho
	nLinRef := 70
	
	// Define o cabecalho resumo extrato
	aColsExt := DefCols(lWeb,cTpFil,"1")
	
	// Define o cabecalho membros familia
	aColsMem := DefCols(lWeb,cTpFil,"2")
	
	if cTpFil == USRMOV
		//Imprime o cabecalho com as informações do usuario
		impCabUsr(cBenefic,@nLinRef,dDataDe,dDataAte,lWeb)
		
		// Imprime o resumo financeiro do usuario
		impDadFin(cTpFil,aValTot,aValBM1,@nLinRef,lWeb)
		
		oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Resumo Extrato Utilização", oFontBld1)
		nLinRef += 10
		
		// Imprime o Box do extrato
		oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
		nLinRef += 10
		
		// Imprime o cabecalho  do extrato
		for nI := 1 to len(aColsExt)
			nColCalc := CalcPosCol(,aColsExt,nColMax,nI)
			oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nI][1], oFontBld3)
		next nI
		nLinRef += 10

		// Imprimi Consultas do Beneficiário
		If Len(aDadCons) > 0
			ImpDadUsr(aDadCons,@nLinRef,aValTot[1])
		EndIf
		
		// Imprimi Exame/Terapia do Beneficiário
		If Len(aDadExam) > 0
			ImpDadUsr(aDadExam,@nLinRef,aValTot[2])
		EndIf
		
		// Imprimi Ondotologia do Beneficiário	
		If Len(aDadOdon) > 0
			ImpDadUsr(aDadOdon,@nLinRef,aValTot[4])
		EndIf
		// Imprimi Internação do Beneficiário
		If Len(aDadInte) > 0
			ImpDadUsr(aDadInte,@nLinRef,aValTot[3])
		EndIf

		// Imprimi Outros do Beneficiário
		If Len(aDadOutr) > 0
			ImpDadUsr(aDadOutr,@nLinRef,aValTot[5])
		EndIf
		
	elseif cTpFil == FAMMOV
		// Imprime cabecalho da familia
		impCabFam(cFamilia,@nLinRef,dDataDe,dDataAte)
		
		// Imprime membros da familia
		impMemFam(cFamilia,@nLinRef,aColsMem,aDadFam)
		
		// Imprime o resumo financeiro da familia
		impDadFin(cTpFil,aValTot,aValBM1,@nLinRef)
		
		// Imprimr o resumo extrato caso nLinMax proxima pagina
		if nLinRef >= nLinMax * 0.95
			
			oPrint:EndPage()
			oPrint:StartPage()
			
			// Marca a referencia da proxima linha apos o cabecalho
			nLinRef := 30
			
			oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Resumo Extrato Utilização", oFontBld1)
			nLinRef += 05
			
			// Imprime o Box do extrato
			oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
			nLinRef += 10
		else
			oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Resumo Extrato Utilização", oFontBld1)
			nLinRef += 05
			
			oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
			nLinRef += 10
		endIf
		
		// Imprime o cabecalho
		for nI := 1 to len(aColsExt)
			nColCalc := CalcPosCol(,aColsExt,nColMax,nI)
			oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nI][1], oFontBld3)
		next nI
		nLinRef += 10
		
		
		// Imprime o extrato da familia
		for nI := 1 to len(aDadFam)
			
			// Posiciona no beneficiario
			BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
			BA1->(MsSeek(xFilial("BA1") + aDadFam[nI][1]))
			
			// Imprime a linha informando qual o beneficiario
			oPrint:Say(nLinIni + nLinRef, nColIni + 0030, 	objCENFUNLGP:verCamNPR("BA1_CODINT",BA1->BA1_CODINT)+"."+;
															objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+"."+;
															objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1->BA1_MATRIC)+"."+;
															objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1->BA1_TIPREG)+"."+;
															objCENFUNLGP:verCamNPR("BA1_DIGITO",BA1->BA1_DIGITO) + " - " +;
															objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR), oFontBld3)
			
			nLinRef += 10
			
			// Inicia uma proxima pagina
			if nLinRef >= nLinMax * 0.95
				
				oPrint:EndPage()
				oPrint:StartPage()
				
				// Marca a referencia da proxima linha apos o cabecalho
				nLinRef := 30
				
				// Cria o box principal
				oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
				
				// Imprime o Box do extrato
				oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
				nLinRef += 10
				
				// Imprime o cabecalho
				for nY := 1 to len(aColsExt)
					nColCalc := CalcPosCol(,aColsExt,nColMax,nY)
					oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nY][1], oFontBld3)
				next nY
				nLinRef += 10
				
			endif
			
			for nX := 1 to len(aDadFam[nI][2])
				impDados(aDadFam[nI][2][nX],aColsExt,@nLinRef)
				
				// Inicia uma proxima pagina
				if nLinRef >= nLinMax * 0.95
					
					oPrint:EndPage()
					oPrint:StartPage()
					
					// Marca a referencia da proxima linha apos o cabecalho
					nLinRef := 30
					
					// Cria o box principal
					oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
					
					// Imprime o Box do extrato
					oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
					nLinRef += 10
					
					// Imprime o cabecalho
					for nY := 1 to len(aColsExt)
						nColCalc := CalcPosCol(,aColsExt,nColMax,nY)
						oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nY][1], oFontBld3)
					next nY
					nLinRef += 10
					
				endif
				
			next nX
			
		next nI
		
	elseif cTpFil == ALLMOV
		
		//Imprime cabecalho Movimentações
		impCabMov(cEmpresa, cContrat, cSubCont, @nLinRef)
		
		//Imprime o resumo financeiro das movimentações
		impDadFin(cTpFil,aValTot,aValBM1,@nLinRef)
		
		oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Resumo Extrato Utilização", oFontBld1)
		nLinRef += 05
		
		// Imprime o Box do extrato
		oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
		nLinRef += 10
		
		// Imprime o cabecalho
		for nI := 1 to len(aColsExt)
			nColCalc := CalcPosCol(,aColsExt,nColMax,nI)
			oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nI][1], oFontBld3)
		next nI
		nLinRef += 10
		
		For Nx := 1 to Len(aDadMov)
			// Posiciona no beneficiario
			BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
			BA1->(MsSeek(xFilial("BA1") + aDadMov[Nx][1]))
			
			// Imprime a linha informando qual o beneficiario
			oPrint:Say(nLinIni + nLinRef, nColIni + 0030, 	objCENFUNLGP:verCamNPR("BA1_CODINT",BA1->BA1_CODINT)+"."+;
															objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+"."+;
															objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1->BA1_MATRIC)+"."+;
															objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1->BA1_TIPREG)+"."+;
															objCENFUNLGP:verCamNPR("BA1_DIGITO",BA1->BA1_DIGITO) + " - " +;
															objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR), oFontBld3)
			nLinRef += 10
			// Inicia uma proxima pagina
			if nLinRef >= nLinMax * 0.95
				
				oPrint:EndPage()
				oPrint:StartPage()
				
				// Marca a referencia da proxima linha apos o cabecalho
				nLinRef := 30
				
				// Cria o box principal
				oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
				
				// Imprime o Box do extrato
				oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
				nLinRef += 10
				
				// Imprime o cabecalho
				for nY := 1 to len(aColsExt)
					nColCalc := CalcPosCol(,aColsExt,nColMax,nY)
					oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nY][1], oFontBld3)
				next nY
				nLinRef += 10
				
			endif		
			// Imprime o extrato dos usuario
			for nI := 1 to len(aDadMov[Nx][2])
				impDados(aDadMov[Nx][2][nI],aColsExt,@nLinRef)
				
				// Inicia uma proxima pagina
				if nLinRef >= nLinMax * 0.95
					
					oPrint:EndPage()
					oPrint:StartPage()
					
					// Marca a referencia da proxima linha apos o cabecalho
					nLinRef := 30
					
					// Cria o box principal
					oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
					
					// Imprime o Box do extrato
					oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
					nLinRef += 10
					
					// Imprime o cabecalho
					for nY := 1 to len(aColsExt)
						nColCalc := CalcPosCol(,aColsExt,nColMax,nY)
						oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nY][1], oFontBld3)
					next nY
					nLinRef += 10
					
				endif
				
			next nI
		next Nx
	endif
	
	
	
	
	// Imprime
	oPrint:Print()
	
return ({.T.,'',cRelName + ".PDF"})

static function DefCols(lWeb,cTpFil,cTpCol)
	local aRetCols 	:= {}
	
	default lWeb		:= .F.
	default cTpFil	:= "2"
	default cTpCol	:= "1"
	
	
	/*
	ESTRUTURA aRetCols
	[1] - Nome
	[2] - ID
	[3] - Posicao em relacao a coluna max.
	*/
	
	/*
	Definicao cTpCol
	1 - Extrato de utilizacao do usuario
	2 - Membros da familia
	*/
	
	do case
	case cTpFil == USRMOV
		if !lWeb
			aRetCols := {	{"Data",				"DATPRO",	96.875/100},;
				{"Prestador",		 				"NOMRDA",	92.000/100},;
				{"L. Dig",							"CODLDP",	74.500/100},;
				{"PEG",								"CODPEG",	71.000/100},;
				{"Numero",							"NUMERO",	67.000/100},;
				{"Local Atend.",					"DESLOC",	63.000/100},;
				{"Codigo Proc.",					"CODPRO",	51.750/100},;
				{"Descrição Proc.",					"DESPRO",	46.250/100},;
				{"Qtd.",							"QTDPRO",	28.250/100},;
				{"Den./Reg.",						"DENREG",	26.375/100},;
				{"Face",							"FADENT",	21.500/100},;
				{"Vl.Cop.",							"VLRTPF",	18.500/100},;
				{"Vl.Pag.",							"VLRPAG",	14.500/100},;
				{"Vl.Glo.",							"VLRGLO",	10.750/100},;
				{"Status Fat.",						"FASE"  ,	07.250/100}}
		else
			aRetCols := {	{"Data de Realização",  	"DATPRO",	96.875/100},;
				{"Prestador",		 					"NOMRDA",	89.000/100},;
				{"CPF/CNPJ",                            "CPFRDA",   68.000/100},;
				{"Categ. Despesa.",						"TIPO"  ,	60.000/100},;
				{"Origem.",								"ORIGEM",	50.000/100},;				
				{"Codigo Proc.",						"CODPRO",	45.000/100},;
				{"Descrição Proc.",						"DESPRO",	37.250/100},;
				{"Qtd.",								"QTDPRO",	14.375/100},;
				{"Vl.Pag.",								"VLRPAG",	11.500/100}}
		endif
		
	case cTpFil == FAMMOV
		if cTpCol == "1"
			aRetCols := {	{"Data",				"DATPRO",	96.875/100},;
				{"Prestador",		 				"NOMRDA",	92.000/100},;
				{"L. Dig",							"CODLDP",	74.500/100},;
				{"PEG",								"CODPEG",	71.000/100},;
				{"Numero",							"NUMERO",	67.000/100},;
				{"Local Atend.",					"DESLOC",	63.000/100},;
				{"Codigo Proc.",					"CODPRO",	51.750/100},;
				{"Descrição Proc.",					"DESPRO",	46.250/100},;
				{"Qtd.",							"QTDPRO",	28.250/100},;
				{"Den./Reg.",						"DENREG",	26.375/100},;
				{"Face",							"FADENT",	21.500/100},;
				{"Vl.Cop.",							"VLRTPF",	18.500/100},;
				{"Vl.Pag.",							"VLRPAG",	14.500/100},;
				{"Vl.Glo.",							"VLRGLO",	10.750/100},;
				{"Status Fat.",						"FASE"  ,	07.250/100}}
		elseif cTpCol == "2"
			aRetCols := {	{"Tipo",					"TPUSR",	96.875/100},;
				{"Matricula",							"MATUSR",	80.000/100},;
				{"Nome Beneficiario",					"NOMUSR",	70.000/100},;
				{"Idade",								"IDADE",	56.500/100},;
				{"Plano Código",						"PLANO",	40.000/100},;
				{"Descrição",							"DESPLA",	20.000/100}}
		endif
	case cTpFil == ALLMOV
		aRetCols := {	{"Data",				"DATPRO",	96.875/100},;
			{"Prestador",					 	"NOMRDA",	92.000/100},;
			{"L. Dig",							"CODLDP",	74.500/100},;
			{"PEG",								"CODPEG",	71.000/100},;
			{"Numero",							"NUMERO",	67.000/100},;
			{"Local Atend.",					"DESLOC",	63.000/100},;
			{"Codigo Proc.",					"CODPRO",	51.750/100},;
			{"Descrição Proc.",					"DESPRO",	46.250/100},;
			{"Qtd.",							"QTDPRO",	28.250/100},;
			{"Den./Reg.",						"DENREG",	26.375/100},;
			{"Face",							"FADENT",	21.500/100},;
			{"Vl.Cop.",							"VLRTPF",	18.500/100},;
			{"Vl.Pag.",							"VLRPAG",	14.500/100},;
			{"Vl.Glo.",							"VLRGLO",	10.750/100},;
			{"Status Fat.",						"FASE"  ,	07.250/100}}
	endcase
	
return aRetCols

static function BuildData(cArqTrab,cTpFil,aValTot,lWeb)
	local aData		:= {}
	local aMovUsr	:= {}
	local aTotFam	:= {}
	local cMatUsr	:= ""
	local nTotCons	:= 0
	local nTotSadt	:= 0
	local nTotInte	:= 0
	local nTotOdon	:= 0
	local nTotMisc	:= 0
	local nTotCop	:= 0
	local nTotPgto 	:= 0
	local nTotGlo 	:= 0
	local nCont		:= 0
	local nRecCont	:= 0
	Local cNomeTip 	:= ''
	Local cOrigem	:= "Convenio"
	Local nTotRemb	:= 0
	Local cClas		:= ""
	Local cNomeRda	:= ""
	Local cCpfCnpj  := ""
	Local cAliasCab	:= ""
	
	default aValTot	:= {}
	default lWeb	:=.F.
	
	B45->(DbSetOrder(4))
	BK6->(DbSetOrder(4))
	while (cArqTrab)->(!Eof())
		// Atribui a matricula do usuario
		cMatUsr	:= (cArqTrab)->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO)
		cMatFam	:= (cArqTrab)->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC)
		
		while (cArqTrab)->(!Eof()) .And. cMatUsr == (cArqTrab)->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO)
			
			cAliasCab 	:= PlRetAlias(BD6->BD6_OPEUSR,BD6->BD6_TIPGUI)
			cClas 		:= (cArqTrab)->BD6_TPEVCT

			If cClas $ "01" // Consulta
				nTotCons +=  (cArqTrab)->(BD6_VLRPAG)
			ElseIf cClas $ "02/03/04/05"// Exames/Terapias
				nTotSadt += (cArqTrab)->(BD6_VLRPAG)
			ElseIf cClas $ "06/07/08/09/10/11"  // Internações
				nTotInte +=  (cArqTrab)->(BD6_VLRPAG)
			ElseIf cClas $ "12/13/  " // Outros
				nTotMisc +=  (cArqTrab)->(BD6_VLRPAG)
			Else // Odonto
				nTotOdon +=  (cArqTrab)->(BD6_VLRPAG)
			Endif

			cNomeTip := PLGetTpEvDesc(cClas)
			
			If (cArqTrab)->BD6_TIPGUI =='04'
				cOrigem:="Reembolso"
				B45->( DBSeek( xFilial("B45") + cMatUsr+(cArqTrab)->(BD6_CODPAD+BD6_CODPRO+BD6_DATPRO)))
				
				BK6->( msSeek( xFilial("BK6") + B45->B45_CODREF ) )
				cNomeRda:=substr(AllTrim(BK6->BK6_NOME),1,30)
				If Empty(cNomeRda)
					cNomeRda:=substr(AllTrim((cArqTrab)->BD6_NOMRDA),1,30)
				Endif
			Else
				cNomeRda:=substr(AllTrim((cArqTrab)->BD6_NOMRDA),1,30)
				cOrigem	:="Convenio"
			Endif
			
			if (cArqTrab)->BD6_TIPRDA == "F"
			    cCpfCnpj := AllTrim((cArqTrab)->(Transform(BD6_CPFRDA, "@R 999.999.999-99")))
			else
			    cCpfCnpj := AllTrim((cArqTrab)->(Transform(BD6_CPFRDA, "@R 99.999.999/9999-99")))
			endif
			
			aAdd(aMovUsr,{{AllTrim(DtoC(StoD((cArqTrab)->BD6_DATPRO)))	  	,"DATPRO"},;	// [01] Data do atendimento
			{cNomeRda				 			                            ,"NOMRDA"},;	// [02] Nome do Prestador de Serviço - RDA
			{AllTrim((cArqTrab)->BD6_CODLDP)								,"CODLDP"},;	// [03] Local Dig.
			{AllTrim((cArqTrab)->BD6_CODPEG)	 							,"CODPEG"},;	// [04] Peg.
			{AllTrim((cArqTrab)->BD6_NUMERO)	 							,"NUMERO"},;	// [05] Numero.
			{substr(AllTrim((cArqTrab)->BD6_DESLOC),1,22)					,"DESLOC"},;	// [06] Local Antendimento.
			{AllTrim((cArqTrab)->(BD6_CODPRO)) 								,"CODPRO"},;	// [07] Código Procedimento
			{substr(AllTrim((cArqTrab)->(BD6_DESPRO)),1,36)					,"DESPRO"},;	// [08] Descrição Procedimento
			{AllTrim(Str((cArqTrab)->(BD6_QTDPRO)))							,"QTDPRO"},;	// [09] Qtde do Procedimento
			{AllTrim((cArqTrab)->(BD6_DENREG))								,"DENREG"},;	// [10] Dente/Região
			{AllTrim((cArqTrab)->(BD6_FADENT))								,"FADENT"},;	// [11] Face
			{AllTrim((cArqTrab)->(Transform(BD6_VLRTPF, "@E 999,999.99")))	,"VLRTPF"},;	// [12] Valor Co-Participação
			{AllTrim((cArqTrab)->(Transform(BD6_VLRPAG, "@E 999,999.99")))	,"VLRPAG"},;	// [13] Valor Pagamento
			{AllTrim((cArqTrab)->(Transform(BD6_VLRGLO, "@E 999,999.99")))	,"VLRGLO"},;	// [14] Valor Glosa
			{cNomeTip 														,"TIPO"  },;	// [15] Tipo
			{cOrigem 														,"ORIGEM"},;	// [16] Origem
			{if((cArqTrab)->BD6_FASE == "4", "Faturado", "Não Faturado") 	,"FASE"  },;	// [17] Fase
			{cCpfCnpj                                                       ,"CPFRDA"}})    // [18] CPF RDA
			
			// Incrementa as variaveis de valores

		
		nTotCop		+= (cArqTrab)->(BD6_VLRTPF)
		nTotPgto  	+= (cArqTrab)->(BD6_VLRPAG)
		nTotGlo		+= (cArqTrab)->(BD6_VLRGLO)
		
		(cArqTrab)->(dbSkip())
	enddo
	
	if cTpFil == USRMOV
		// Adiciona os totais
		aAdd(aValTot,	nTotCons)
		aAdd(aValTot,	nTotSadt)
		aAdd(aValTot,	nTotInte)
		aAdd(aValTot,	nTotOdon)
		aAdd(aValTot,	nTotMisc)
		aAdd(aValTot,	nTotCop )
		aAdd(aValTot,	nTotPgto)
		aAdd(aValTot,	nTotRemb)
	endif
	
	// Adiciona os dados na matriz principal
	aAdd(aData,{cMatUsr,aClone(aMovUsr)})
	
	// Adiciona os valores totais
	if cTpFil == ALLMOV .And. (cMatFam <> (cArqTrab)->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC) .Or. (cArqTrab)->(Eof()))
		// Se for familia ou toda a movimentacao, deve fazer a checagem se trata-se do ultimo registro ou se trocou de familia
		aAdd(aTotFam,aClone(aValTot))
		
		nTotCons := 0
		nTotSadt := 0
		nTotInte := 0
		nTotOdon := 0
		nTotMisc := 0
		nTotCop  := 0
		nTotPgto := 0
		nTotGlo  := 0
	endif
	
	// Remove o conteudo para o proximo beneficiario
	PlsFreArr(@aMovUsr)
enddo

// Caso nao seja de toda a movimentacao ou por familia, deve adicionar os totais somente ao finalizar o laço
if cTpFil == ALLMOV
	aValTot := aClone(aTotFam)
elseif cTpFil == FAMMOV
	// Adiciona os totais
	aAdd(aValTot,	nTotCons)
	aAdd(aValTot,	nTotSadt)
	aAdd(aValTot,	nTotInte)
	aAdd(aValTot,	nTotOdon)
	aAdd(aValTot,	nTotMisc)
	aAdd(aValTot,	nTotCop )
	aAdd(aValTot,	nTotPgto)
	aAdd(aValTot,	nTotGlo)
endif

return aData

static function BldDataUsr(aDados,aValBM1)
	
return aDados

static function BldDataFam(aDados,aValBM1)
	
return aDados

static function BldDataMov(aDados,aValBM1)
	
return aDados


static function impCabUsr(cBenefic,nLinRef,dDataDe,dDataAte,lWeb)
	
	local nLinBox	 := 0
	Local cMatric	 := ""
	Local aDados	 := {}
	Local aDadCar	 := {}
	Local nI		 := 0
	Local nJ		 := 0
	Local aCarencia	 := []
	Local nCarencia	 := 0
	local nQtdDe 	 := 0
	local nQtdAte	 := 25
	local aAuxCar	 := {}
	local nCount 	 := 1
	local lDescCaren := .F.
	public nBoxFim 	 := 0
	
	
	default nLinRef  := 0
	default dDataDe  := StoD("")
	default dDataAte := StoD("")
	default lWeb	 := .F.
	
	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
	BA1->(MsSeek(xFilial("BA1") + cBenefic))
	
	BA3->(DbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	BA3->(MsSeek(xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	
	BTS->(DbSetorder(1))
	BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))
	
	if empty(BA1->BA1_CODPLA)
		cCodPla := BA3->BA3_CODPLA
	else
		cCodPla := BA1->BA1_CODPLA
	endif
	
	//nIdade := Calc_Idade(dDataBase, BA1->BA1_DATNAS,BA1->BA1_DATNAS)
	BIH->(DbSetOrder(1)) //BIH_FILIAL+BIH_CODTIP
	BIH->(MsSeek(xFilial("BIH") + BA1->BA1_TIPUSU))
	
	cTipUsr := BIH->BIH_DESCRI
	
	BI3->(DbSetOrder(1)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
	BI3->(MsSeek(xFilial("BI3") + BA1->BA1_CODINT + cCodPla))
	//³ Verifica Regulamentação do Plano                                    ³
	
	
	
	aDadCar := PLSLISMSGC(	BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), BI3->(BI3_CODINT+BI3_CODIGO),;
		BA3->BA3_VERSAO,BA1->BA1_DATCAR,BA1->BA1_SEXO)
	
	
	// LINHA 1 - INICIO
	// Dados do Beneficiário
	oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Dados do Beneficiário", oFontBld1)
	nLinRef += 10
	// LINHA 1 - FIM
	
	// LINHA 2 - INICIO
	// Box Matrícula
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + 0110, nColIni + (nColMax*0.17))
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Matrícula", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0025,objCENFUNLGP:verCamNPR("BA1_CODINT",BA1->BA1_CODINT)+"."+;
												 objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+"."+;
												 objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1->BA1_MATRIC)+"."+;
												 objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1->BA1_TIPREG)+"."+;
												 objCENFUNLGP:verCamNPR("BA1_DIGITO",BA1->BA1_DIGITO), oFontDef2)
	nLinBox += 10
	
	// Box Plano
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.18), nLinIni + 0110, nColIni + (nColMax*0.46))
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.18) + 0010, "Nome", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.18) + 0010, objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR), oFontDef2)
	nLinBox += 10
	
	// Box Período
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.47), nLinIni + 0110, nColIni + (nColMax*0.72))
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.47) + 0010, "Período", oFontBld1)
	nLinBox += 10
	if empty(dDataAte) .And. !empty(dDataDe)
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.47) + 0010, "A partir de " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataDe)), oFontDef2)
	elseif empty(dDataDe) .And. !empty(dDataAte)
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.47) + 0010, "Até " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)), oFontDef2)
	elseif empty(dDataDe) .And. empty(dDataAte)
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.47) + 0010, "Toda movimentação " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)), oFontDef2)
	else
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.47) + 0010, objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataDe)) + " a " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)), oFontDef2)
	endif
	nLinBox += 20
	//nLinRef := nLinBox
	
	// Box Período
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.76), nLinIni + 0110, nColIni + (nColMax*0.98))//03-07
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.76) + 0010, "CNS", oFontBld1)//03-07
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.76) + 0010, objCENFUNLGP:verCamNPR("BTS_NRCRNA",BTS->BTS_NRCRNA), oFontDef2)
	nLinBox += 20
	nLinRef := nLinBox
	
	// LINHA 2 - FIM
	
	// LINHA 3 - INICIO
	// Box Tipo"
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + 0150, nColIni + (nColMax*0.18) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Tipo", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, objCENFUNLGP:verCamNPR("BIH_DESCRI",cTipUsr)   , oFontDef2)
	nLinBox += 10
	
	// Box Nome
	nLinBox := nLinRef //largua                               //posicao                        //tamanho horizontal
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.18), nLinIni + 0150, nColIni + (nColMax*0.5) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.18) + 0010, "Plano", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.18) + 0010, objCENFUNLGP:verCamNPR("BI3_SUSEP",BI3->(BI3_SUSEP)) +;
															 " - " + objCENFUNLGP:verCamNPR("BI3_DESCRI",BI3->(BI3_DESCRI)), oFontDef2)
	nLinBox += 20
	
	
	// Box Nome
	nLinBox := nLinRef //largua                               //posicao                        //tamanho horizontal
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.68), nLinIni + 0150, nColIni + (nColMax*0.51) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.68) - 0130, "Regul.Plano", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.68) - 0130, objCENFUNLGP:verCamNPR("BI3_APOSRG",Alltrim(PLSTXTSX3("BI3_APOSRG", BI3->BI3_APOSRG))), oFontDef2)
	nLinBox += 10
	
	// Box Nome
	nLinBox := nLinRef //largua                               //posicao                        //tamanho horizontal
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.88), nLinIni + 0150, nColIni + (nColMax*0.68) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.78) -80, "Contrato", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.78) - 80, 	objCENFUNLGP:verCamNPR("BA1_CODINT",BA1->BA1_CODINT)+;
																	objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+;
																	objCENFUNLGP:verCamNPR("BA1_CONEMP",BA1->BA1_CONEMP)+;
																	objCENFUNLGP:verCamNPR("BA1_VERCON",BA1->BA1_VERCON), oFontDef2)
	nLinBox += 10
	
	// Box Idade
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.9), nLinIni + 0150, nColIni + nColMax - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.9) + 0010, "Dt.Nasc.", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.9) +0005, objCENFUNLGP:verCamNPR("BA1_DATNAS",dtoc(BA1->BA1_DATNAS)), oFontDef2)
	nLinBox += 25
	nLinRef := nLinBox
	
	//Box Tipo.Contrat. Data.Contrat. Abrangencia Segmenta Carencias
	nBoxFim := 150 + (len(aDadCar) + 2) * 17
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + nBoxFim + 10, nColIni + (nColMax - 00010)) 
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Tipo.Contrat.", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, objCENFUNLGP:verCamNPR("BII_DESCRI",Alltrim(Posicione("BII",1,xFilial("BII")+BI3->BI3_TIPCON,"BII_DESCRI")))   , oFontDef2)
	nLinBox += 20
	
	nLinBox := nLinRef //largua
	oPrint:Say(nLinIni + nLinBox+10 , (nColMax * 0.2), "Data.Contrat.", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.2), objCENFUNLGP:verCamNPR("BA1_DATINC",Dtoc(BA1->BA1_DATINC))   , oFontDef2)
	nLinBox += 20
	
	nLinBox := nLinRef //largua
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.30), "Abrangencia", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.30), objCENFUNLGP:verCamNPR("BF7_DESORI",Alltrim(Posicione("BF7",1,xFilial("BF7")+BI3->BI3_ABRANG,"BF7_DESORI")))   , oFontDef2)
	nLinBox += 20
	
	nLinBox := nLinRef //largua
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.40), "Segmentação", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.40), objCENFUNLGP:verCamNPR("BI6_DESCRI",padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56))   , oFontDef2)
	nLinBox += 20
	
	nLinBox := nLinRef //largua
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.72), "Acomodação", oFontBld1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox+10, (nColMax * 0.72), objCENFUNLGP:verCamNPR("BI4_DESCRI",Alltrim(Posicione("BI4",1,xFilial("BI4")+BI3->BI3_CODACO,"BI4_DESCRI")))   , oFontDef2) //03-07
	nLinBox += 20
	nLinRef+=10 //03-07
	
	oPrint:Say(nLinIni + nLinRef, (nColMax * 0.87), "Carencias", oFontBld1) 
	nLinRef += 10
	
	for nI := 1 to len(aDadCar)

		nCount := len(alltrim(aDadCar[nI][2])) / nQtdAte
		for nJ := 1 to Ceiling(nCount)
		
			aadd(aAuxCar,Substr(aDadCar[nI][2],nQtdDe,nQtdAte))
			nQtdDe += nQtdAte + 1
			if nJ == Ceiling(nCount) .and. len(Alltrim(aAuxCar[nJ])) <= (nQtdAte - len(dtoc(aDadCar[nI][3])))
				oPrint:Say(nLinIni + nLinRef, (nColMax * 0.84), objCENFUNLGP:verCamNPR("BAT_DESCRI",Alltrim(aAuxCar[nJ])) + "-" + objCENFUNLGP:verCamNPR("BA1_DATCAR",dtoc(aDadCar[nI][3])),oFontDef2)
				lDescCaren := .F.
			else
				oPrint:Say(nLinIni + nLinRef, (nColMax * 0.84), objCENFUNLGP:verCamNPR("BAT_DESCRI",Alltrim(aAuxCar[nJ])),oFontDef2)
				lDescCaren := .T.
			endif
				if nJ == Ceiling(nCount) .and. lDescCaren
					nLinRef += 08
				 	oPrint:Say(nLinIni + nLinRef, (nColMax * 0.84), objCENFUNLGP:verCamNPR("BA1_DATCAR",dtoc(aDadCar[nI][3])),oFontDef2)
				endif
			nLinRef += 08

		next nJ
			nLinRef+=03
			aAuxCar := {}
			nQtdDe := 0
		next nI
			
	nLinRef := nBoxFim + 60

	If !lWeb
		nLinbox+=30
		nLinRef+=40
	Endif
return

static function impDadFin(cTpFil,aValTot,aCompCob,nLinRef,lWeb)
	
	local nLinBox	:= 0
	local nTotUsr
	default nLinRef := 0
	Default lWeb	:=.F.
	
	nLinMax += 40
	if cTpFil == USRMOV
		// LINHA 1 - INICIO
		// Dados do Financeiro
		oPrint:Say(nLinIni + nLinRef - 40, nColIni + 0020, "Dados Financeiro", oFontBld1)
		nLinRef -= 30
		// LINHA 1 - FIM
		
		// LINHA 2 - INICIO
		nLinBox := nLinRef 
            
		If !lWeb
            //Box Totais
			oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + nBoxFim + 130, nColIni + (nColMax/7) - 0008)
			nLinBox += 10
			oPrint:Say(nLinIni + nLinBox , nColIni + 0021, "Receita do Plano", oFontDef1)
			nLinBox += 30
			oPrint:Say(nLinIni + nLinBox, nColIni + 0021, "(R$) " + transform(aCompCob[1],"@E 999,999.99") , oFontDef2,,,,1)
			nLinBox += 10
			nLinBox := nLinRef		
		
            //Box Co-Participação (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.14286), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*2) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "Co-Participação (R$)", oFontDef1)
            nLinBox += 30
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "(R$)" + transform(aValTot[6],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
		
		    //Box Pagamento(R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.285), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*3) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "Pagamento", oFontDef1)
            nLinBox += 30
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "(R$)" + transform(aValTot[7],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef       
		
			//Box Glosa  (R$)"
			oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*3), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*4) - 0010)
			nLinBox += 10
			oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, Iif( !lWeb,"Glosas","Reembolso"), oFontDef1)
			nLinBox += 30
			oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, "(R$)" + transform(aValTot[8],"@E 999,999.99") , oFontDef2,,,,1)
			nLinBox += 10
			nLinBox := nLinRef		
		
            //Box Consulta/Exame (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*4), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*5) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*4) + 0002, "Consulta " , oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*4) + 0002, "(R$)" + transform(aValTot[1],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*4) + 0002, "Exame / Terapia ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*4) + 0002, "(R$)" + transform(aValTot[2],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
            
            //Box Odontologia/Internação    (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*5), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*6) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*5) + 0002, "Odontologia ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*5) + 0002, "(R$)" + transform(aValTot[4],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*5) + 0002, "Internação ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*5) + 0002, "(R$)" + transform(aValTot[3],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
            
            //Box Outros  (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*6), nLinIni + nBoxFim + 130, nColIni + (nColMax/7*7) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*6) + 0002, "Outros ", oFontDef1)
            nLinBox += 30
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*6) + 0002, "(R$)" + transform(aValTot[5],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 40           
		Else
            //Box Pagamento(R$)"
			
            oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + nBoxFim + 90, nColIni + (nColMax/7) - 0008)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox , nColIni + 0021, "Pagamento", oFontDef1)
            nLinBox += 30
            oPrint:Say(nLinIni + nLinBox , nColIni + 0021, "(R$)" + transform(aValTot[7],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
            
            //Box Consulta/Exame (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.14286), nLinIni + nBoxFim + 90, nColIni + (nColMax/7*2) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "Consulta " , oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "(R$)" + transform(aValTot[1],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "Exame / Terapia ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "(R$)" + transform(aValTot[2],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
            
            //Box Odontologia/Internação    (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.285), nLinIni + nBoxFim + 90, nColIni + (nColMax/7*3) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "Odontologia ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "(R$)" + transform(aValTot[4],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "Internação ", oFontDef1)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "(R$)" + transform(aValTot[3],"@E 999,999.99"), oFontDef2,,,,1)
            nLinBox += 10
            nLinBox := nLinRef
            
            //Box Outros  (R$)"
            oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*3), nLinIni + nBoxFim + 90, nColIni + (nColMax/7*4) - 0010)
            nLinBox += 10
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, "Outros ", oFontDef1)
            nLinBox += 30
            oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, "(R$)" + transform(aValTot[5],"@E 999,999.99") , oFontDef2,,,,1)
            nLinBox += 65
		Endif
		
		// LINHA 2 - FIM
        nLinRef := nLinBox  
		
	elseif  cTpFil == FAMMOV
		
		
		// LINHA 1 - INICIO
		// Dados do Financeiro
		oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Dados Financeiro", oFontBld1)
		nLinRef += 05
		// LINHA 1 - FIM
		
		// LINHA 2 - INICIO
		// Box Totais
		nLinBox := nLinRef
		oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinBox + 55, nColIni + (nColMax/7) - 0008)
		nLinBox += 10
		oPrint:Say(nLinIni + nLinBox, nColIni + 0021, "Receita do Plano: ", oFontDef1)
		nLinBox += 30
		oPrint:Say(nLinIni + nLinBox, nColIni + 0021, "(R$) " + transform(aCompCob[1],"@E 999,999.99") , oFontDef2,,,,1)
		nLinBox += 10
		nLinBox := nLinRef
		
		//Total Co-Participação (R$)"
		oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.14286), nLinBox + 55, nColIni + (nColMax/7*2) - 0010)
		nLinBox += 10
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "Co-Participação", oFontDef1)
		nLinBox += 30
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "(R$)"  + transform(aValTot[6],"@E 999,999.99") , oFontDef2,,,,1)
		nLinBox += 10
		nLinBox := nLinRef
		
		//Total Pagamento(R$)"
		oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.285),nLinBox + 55, nColIni + (nColMax/7*3) - 0010)
		nLinBox += 10
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "Pagamento ", oFontDef1)
		nLinBox += 30
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "(R$)"  + transform(aValTot[7],"@E 999,999.99"), oFontDef2,,,,1)
		nLinBox += 10
		nLinBox := nLinRef
		
		//Valor Glosa  (R$)"
		oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax/7*3),nLinBox + 55, nColIni + (nColMax/7*4) - 0010)
		nLinBox += 10
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, "Glosas ", oFontDef1)
		nLinBox += 30
		oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax/7*3) + 0002, "(R$)"  + transform(aValTot[8],"@E 999,999.99") , oFontDef2,,,,1)
		nLinBox += 30
		// LINHA 2 - FIM
		nLinRef := nLinBox
		
		
	elseIf cTpFil == ALLMOV
		
		
		// LINHA 1 - INICIO
		// Dados do Financeiro

		oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Dados Financeiro", oFontBld1)
		nLinRef += 5
		// LINHA 1 - FIM
		
		// LINHA 2 - INICIO
		// Box Totais
		nLinBox := nLinRef
		oPrint:Box(nLinIni + nLinBox, nColIni + 0020 ,nLinBox + 65, nColIni + (nColMax/7) - 0008)
		nLinBox += 10
		oPrint:Say(nLinIni + nLinBox, nColIni + 0021, "Total de despesas: ", oFontDef1)
		nLinBox += 40
		oPrint:Say(nLinIni + nLinBox, nColIni + 0021, "(R$) " + transform(aCompCob[1],"@E 999,999.99")   , oFontDef2,,,,1)
		nLinBox += 30
		nLinRef := nLinBox
		//nLinRef += 10
		
		// oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.14286), nLinBox + 65, nColIni + (nColMax/7*2) - 0010)
		// nLinBox += 10
		// oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "Contrato", oFontDef1)
		// nLinBox += 40
		// oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.145), "(R$)"    , oFontDef2,,,,1)
		// nLinBox += 10
		// nLinBox := nLinRef
		
		// oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax* 0.285),nLinBox + 65, nColIni + (nColMax/7*3) - 0010)
		// nLinBox += 10
		// oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "Empresa ", oFontDef1)
		// nLinBox += 40
		// oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax* 0.288), "(R$)"   , oFontDef2,,,,1)
		// nLinBox += 40
		// nLinRef := nLinBox
		// LINHA 2 - FIM
		
	endIf
	nLinMax -= 40
return

static function impDados(aDad,aCols,nLinRef)
	local nI	:= 1
	local nCol	:= 0
	local cDado	:= ""
	
	default nLinRef := 0
	
	for nI := 1 to len(aDad)
		
		// Retorna o dado
		if !empty(aDad[nI][1])
			cDado := aDad[nI][1]
		else
			cDado := "N/D"
		endif
		
		// Retorna o posicionamento
		nCol := CalcPosCol(aDad[nI][2],aCols,nColMax)
		
		if nCol > 0
			// Imprime a linha
			oPrint:Say(nLinIni + nLinRef, nCol, objCENFUNLGP:verCamNPR("BD6_"+aDad[nI][2],cDado), oFontDef3)
		endif
		
	next nI
	
	nLinRef += 10
	
return

static function impCabFam(cFamilia,nLinRef,dDataDe,dDataAte)
	local nLinBox		:= 0
	
	default cFamilia	:= ""
	default nLinRef	:= 0
	default dDataDe	:= StoD("")
	default dDataAte	:= StoD("")
	
	// LINHA 1 - INICIO
	// Dados do Familia
	oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Dados da Familia", oFontBld1)
	nLinRef += 05
	// LINHA 1 - FIM
	
	// LINHA 2 - INICIO
	//Período
	nLinBox := nLinRef
	oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + 0110, nColIni + (nColMax*0.35) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Período", oFontBld1)
	nLinBox += 15
	if empty(dDataAte) .And. !empty(dDataDe)
		oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "A partir de " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataDe)) , oFontDef2)
	elseif empty(dDataDe) .And. !empty(dDataAte)
		oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Até " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)) , oFontDef2)
	elseif empty(dDataDe) .And. empty(dDataAte)
		oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Toda movimentação " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)) , oFontDef2)
	else
		oPrint:Say(nLinIni + nLinBox, nColIni + 0030, objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataDe)) + " a " + objCENFUNLGP:verCamNPR("BD6_DATPRO",DtoC(dDataAte)) , oFontDef2)
	endif
	nLinBox += 10
	nLinBox := nLinRef
	
	//Matricula
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.35), nLinIni + 0110, nColIni + (nColMax*0.6) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.35) + 0010, "Matricula", oFontBld1)
	nLinBox += 15
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.35) + 0010, objCENFUNLGP:verCamNPR("BD6_MATRIC",cFamilia) , oFontDef2)
	nLinBox += 30
	nLinRef := nLinBox
	// LINHA 2 - FIM
	
return

static function impMemFam(cFamilia,nLinRef,aColsMem,aDadFam)
	local nI	:= 1
	local aDadosMem := DefMemFam(aDadFam)
	local nBoxFim := (len(aDadosMem) + 2) * 10
	local nLinBox	:= 0
	default nLinRef := 0
	
	oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Membros", oFontBld1)
	nLinRef += 05
	// Imprime box membros familia
	oPrint:Box(nLinIni + nLinRef, nColIni + 0020, nLinIni + nLinRef + nBoxFim, nColIni + nColMax  - 0008)
	nLinRef += 10
	
	// Imprimi cabecalho Membros da Familia
	for nI := 1 to len(aColsMem)
		nColCalc := CalcPosCol(,aColsMem,nColMax,nI)
		oPrint:Say(nLinIni + nLinRef, nColCalc, aColsMem[nI][1], oFontBld1)
	next nI
	nLinRef += 15
	
	for nI := 1 to len(aDadosMem)
		// Imprime o extrato da familia
		impDados(aDadosMem[nI],aColsMem,@nLinRef)
	next nI
	
	nLinRef += 20
	
return

static function DefMemFam(aDadFam)
	local nI 	:= 0
	local aRet	:= {}
	local aUser := {}
	
	for nI := 1 to Len(aDadFam)
		
		BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
		BA1->(MsSeek(xFilial("BA1") + aDadFam[nI][1]))
		
		BA3->(DbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
		BA3->(MsSeek(xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		
		BTS->(DbSetorder(1))
		BTS->(MsSeek(xFilial("BTS") + BA1->BA1_MATVID))
		
		if empty(BA1->BA1_CODPLA)
			cCodPla := BA3->BA3_CODPLA
		else
			cCodPla := BA1->BA1_CODPLA
		endif
		
		nIdade := Calc_Idade(dDataBase, BA1->BA1_DATNAS,BA1->BA1_DATNAS)
		
		BIH->(DbSetOrder(1)) //BIH_FILIAL+BIH_CODTIP
		BIH->(MsSeek(xFilial("BIH") + BA1->BA1_TIPUSU))
		
		cTipUsr := BIH->BIH_DESCRI
		
		BI3->(DbSetOrder(1)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
		BI3->(MsSeek(xFilial("BI3") + BA1->BA1_CODINT + cCodPla))
		
		aAdd(aUser, {cTipUsr,    																							"TPUSR" })
		aAdd(aUser, {BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"."+BA1_DIGITO),				"MATUSR"})
		aAdd(aUser, {BA1->BA1_NOMUSR,																						"NOMUSR"})
		aAdd(aUser, {AllTrim(Str(nIdade)),																					"IDADE" })
		aAdd(aUser, {cCodPla,																								"PLANO" })
		aAdd(aUser, {BI3->(BI3_DESCRI)	,								 													"DESPLA"})
		
		aAdd(aRet,aClone(aUser))
		
		PlsFreArr(@aUser)
		
	next nI
	
return aRet

static function impCabMov(cEmpresa, cContrat, cSubCont, nLinRef)
	local nLinBox	:= 0
	local cDesEmp	:= Substr(Posicione("BG9",1,xFilial("BG9") + PlsIntPad() + cEmpresa,"BG9_DESCRI"),1,30)
	local cDesSub	:= substr(Posicione("BQC",1,xFilial("BQC") + PlsIntPad() + cEmpresa + cContrat,"BQC_DESCRI"),1,30)

	default nLinRef := 0

	// LINHA 1 - INICIO
	// Dados do Beneficiário
	oPrint:Say(nLinIni + nLinRef, nColIni + 0020, "Movimentações", oFontBld1)
	nLinRef += 10
	// LINHA 1 - FIM
	nLinBox := nLinRef
	// LINHA 2 - INICIO
	//Beneficiario
	oPrint:Box(nLinIni + nLinBox, nColIni + 0020, nLinIni + 0110, nColIni + (nColMax*0.35) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030, "Empresa", oFontDef1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + 0030,objCENFUNLGP:verCamNPR("BG9_DESCRI",cDesEmp), oFontDef2)
	nLinBox += 10
	nLinBox := nLinRef
	//Empresa
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.35), nLinIni + 0110, nColIni + (nColMax*0.6) - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.35) + 0010, "Contrato", oFontDef1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.35) + 0010,objCENFUNLGP:verCamNPR("BD6_CONEMP",cContrat)  , oFontDef2)
	nLinBox += 10
	nLinBox := nLinRef
	//Contrato
	oPrint:Box(nLinIni + nLinBox, nColIni + (nColMax * 0.6), nLinIni + 0110, nColIni + nColMax - 0010)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.6) + 0010, "Sub-Contrato", oFontDef1)
	nLinBox += 10
	oPrint:Say(nLinIni + nLinBox, nColIni + (nColMax * 0.6) + 0010,objCENFUNLGP:verCamNPR("BQC_DESCRI",cDesSub), oFontDef2)
	nLinBox += 50
	nLinRef := nLinBox
	
return

static function CalcPosCol(cId,aCols,nColRef,nPos)
	local nCol	:= 0
	local nCoef	:= 0
	
	default cId	    := ""
	default aCols	:= {}
	default nColRef	:= {}
	default nPos 	:= 0
	
	if nPos == 0
		// Busco o ID do cabecalho atraves do ID do item
		nPos := aScan(aCols,{|x| x[2] == cId})
	endif
	
	// Faz o calculo com base no percentual de recuo que devo aplicar no nColMax
	if nPos > 0
		nCoef := aCols[nPos][3]
		
		nCol := nColRef - (nColRef * nCoef)
	endif
	
return nCol

static function RetValBM1(cTpFil,cMesDe,cAnoDe,cMesAte,cAnoAte,cMatUsr,cMatFam,cCodInt,cCodEmp,cCodCon,cCodSub,dDataDe, dDataAte)
	local cAliBM1		:= GetNextAlias()
	local cCodTip		:= "%" + FormatIn("   ","/") + "%"
	local aRet			:= {}
	local cChvEmp 	:= 0
	local nTotUsr		:= 0
	local nTotFam		:= 0
	local nTotAllMov	:= 0
	Local cPtoEnt		:=""
	Local lPe			:=.F.
	
	default cTpFil	:= ""
	default cMesDe	:= ""
	default cAnoDe	:= ""
	default cMesAte	:= ""
	default cAnoAte	:= ""
	default cMatUsr	:= ""
	default cMatFam	:= ""
	default cCodInt	:= ""
	default cCodEmp	:= ""
	default cCodCon	:= ""
	default cCodSub	:= ""
	default dDataDe     := StoD("")
	default dDataAte    := StoD("")
	
	//P.E. Que  Indica códigos de lançamentos de cobrança que não serão considerados na composição do custo BM1_CODTIP
	If ExistBlock("PLSR020TP")
		cPtoEnt := ExecBlock("PLSR020TP",.F.,.F.)
		If ! Empty(cPtoEnt)
			cCodTip := cPtoEnt
			lPe:=.T.
		Endif
	Endif
	
	
	if cTpFil == USRMOV
		//BM1_FILIAL + BM1_MATUSU + BM1_MES + BM1_ANO + BM1_CODTIP
		BeginSql Alias cAliBM1
			SELECT SUM(BM1_VALOR) AS BM1_VALOR FROM %table:BM1% BM1
			WHERE	BM1_FILIAL	 = %xFilial:BM1%	AND
			BM1_MATUSU	 = %exp:cMatUsr%	AND
			BM1_MES	>= %exp:cMesDe%	AND
			BM1_ANO	>= %exp:cAnoDe%	AND
			BM1_MES	<= %exp:cMesAte%	AND
			BM1_ANO	<= %exp:cAnoAte%	AND
			BM1_CODTIP not in %exp:cCodTip%	AND
			BM1.%notdel%
		EndSql
		
		if (cAliBM1)->(!Eof())
			nTotUsr := (cAliBM1)->(BM1_VALOR)
		endif
		
		aAdd(aRet,nTotUsr)
		
	elseif cTpFil == FAMMOV
		// BM1_FILIAL + BM1_CODINT + BM1_CODEMP + BM1_CONEMP + BM1_VERCON + BM1_SUBCON + BM1_VERSUB + BM1_MATRIC + BM1_TIPREG + BM1_CODTIP + BM1_ANO + BM1_MES
		BeginSql Alias cAliBM1
			SELECT SUM(BM1_VALOR) AS BM1_VALOR FROM %table:BM1% BM1
			WHERE	BM1_FILIAL	 = %xFilial:BM1%	AND
			BM1_CODINT	 = %exp:cCodInt%	AND
			BM1_CODEMP	 = %exp:cCodEmp%	AND
			BM1_CONEMP	 = %exp:cCodCon%	AND
			BM1_SUBCON	 = %exp:cCodSub%	AND
			BM1_MATRIC	 = %exp:cMatFam%	AND
			BM1_CODTIP not in %exp:cCodTip%	AND
			
			BM1_MES	<= %exp:cMesAte%	AND
			BM1_ANO	<= %exp:cAnoAte%	AND
			BM1.%notdel%
		EndSql
		
		if (cAliBM1)->(!Eof())
			nTotFam := (cAliBM1)->(BM1_VALOR)
		endif
		
		aAdd(aRet,nTotFam)
		
	else
		// BM1_FILIAL + BM1_CODINT + BM1_CODEMP + BM1_CONEMP + BM1_VERCON + BM1_SUBCON + BM1_VERSUB + BM1_MATRIC + BM1_TIPREG + BM1_CODTIP + BM1_ANO + BM1_MES
		BeginSql Alias cAliBM1
			SELECT BM1_VALOR, BM1_CODINT, BM1_CODEMP,BM1_CONEMP, BM1_SUBCON, BM1_MATRIC
			FROM %table:BM1% BM1
			WHERE	BM1_FILIAL	 = %xFilial:BM1%	AND
			BM1_CODINT	 = %exp:cCodInt%	AND
			BM1_CODEMP	 = %exp:cCodEmp%	AND
			BM1_CONEMP	 = %exp:cCodCon%	AND
			BM1_SUBCON	 = %exp:cCodSub%	AND
			BM1_CODTIP not in %exp:cCodTip%	AND
			BM1_MES	<= %exp:cMesAte%	AND
			BM1_ANO	<= %exp:cAnoAte%	AND
			BM1.%notdel%
			ORDER BY BM1_CODINT, BM1_CODEMP, BM1_CONEMP, BM1_SUBCON, BM1_MATRIC
		EndSql
		
		while (cAliBM1)->(!Eof())
			//Salva a chave da empresa atual
			cChvEmp := (cAliBM1)->(BM1_CODINT + BM1_CODEMP + BM1_CONEMP + BM1_SUBCON + BM1_MATRIC)
			
			//Faz a somatoria dos registros da familia posicionada
			while (cAliBM1)->(!Eof()) .And. cChvEmp == (cAliBM1)->(BM1_CODINT + BM1_CODEMP + BM1_CONEMP + BM1_SUBCON + BM1_MATRIC)
				nTotAllMov += BM1_VALOR
				(cAliBM1)->(dbSkip())
			enddo
			
		enddo
		
		aAdd(aRet,nTotAllMov)
		
	endif
	
return aRet



Static Function Plr022CPT()
	Local dDatCPt := ctod("  /  /  ")
	Local dDatFim := ctod("  /  /  ")
	Local nDias:=0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  data de término da Cobertura Parcial Temporária - CPT, quando houver;                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BF3->(dbSetOrder(1))
	BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
	
	dDatCpt := ctod("  /  /  ")
	
	While ! BF3->(eof()) .and. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
		
		If  ! empty(BF3->BF3_CODDOE)
			If BF3->BF3_UNAGR == "3" //"Meses"
				If  Empty(BF3->BF3_DATCPT)
					If  Empty(BA1->BA1_DATCPT)
						nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
						dDatCPt:= date()+nDias
					Else
						nDias	:=	Abs((BA1->BA1_DATCPT -MonthSum(BA1->BA1_DATCPT , BF3->BF3_MESAGR )))
						dDatCPt:= BA1->BA1_DATCPT+nDias
					Endif
				Else
					nDias	:=	Abs((BF3->BF3_DATCPTT -MonthSum(BF3->BF3_DATCPTT , BF3->BF3_MESAGR )))
					dDatCPt:= BF3->BF3_DATCPT+nDias
				Endif
			Else
				nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
				dDatFim := BF3->BF3_DATCPT + nDias
				If  dDatFim > dDatCpt
					dDatCpt := dDatFim
				Endif
			Endif
		Endif
		BF3->(dbSkip())
	Enddo
	
Return(dDatCPt)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpDadUsr
Imprimi o extrato do beneficiário de acordo com os dados passados por
parametro, onde poderá ser a categoria (aDados) de:
	Consultas
	Exame/Terapia
	Ondotologia
	Internação
	Outros
@author  Vinicius.Queiros
@version P12
@since   30/07/2020
@Param  aDados  : Array com o dados
	 	nLinRef : Linha de Referencia
		nVlrTot : Valor total dos dados
@Obs
	Variaveis do tipo private utilizadas na função:
		oPrint, aColsExt, nLinMax, nLinIni, nColIni
		oFontBld3
/*/
//------------------------------------------------------------------- 

Static Function ImpDadUsr(aDados,nLinRef,nVlrTot)

// Variaveis
Local nNx, nNy, nColCalc, nColuna

// Imprimir os dados do beneficiario
For nNx := 1 To Len(aDados)
	impDados(aDados[nNx],aColsExt,@nLinRef)
	
	// Inicia uma proxima pagina
	If nLinRef >= nLinMax * 0.95
				
		oPrint:EndPage()
		oPrint:StartPage()
				
		// Marca a referencia da proxima linha apos o cabecalho
		nLinRef := 30
				
		// Cria o box principal
		oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
				
		// Imprime o Box do extrato
		oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
		nLinRef += 10
				
		// Imprime o cabecalho
		For nNy := 1 To Len(aColsExt)
			nColCalc := CalcPosCol(,aColsExt,nColMax,nNy)
			oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nNy][1], oFontBld3)
		Next nNy

		nLinRef += 10				
	Endif			
Next nNx

// Imprimi quantidade e valor total da categoria
nColuna := CalcPosCol("CODPRO",aColsExt,nColMax)
oPrint:Say(nLinIni + nLinRef, nColuna - 111, "Quantidade Total de Procedimentos: "+cValToChar(Len(aDados)), oFontBld3)
nColuna := CalcPosCol("VLRPAG",aColsExt,nColMax)
oPrint:Say(nLinIni + nLinRef, nColuna - 48, "Valor Total: R$" + transform(nVlrTot,"@E 999,999.99"), oFontBld3)
nLinRef += 20

// Inicia uma proxima pagina
If nLinRef >= nLinMax * 0.95
				
	oPrint:EndPage()
	oPrint:StartPage()
			
	// Marca a referencia da proxima linha apos o cabecalho
	nLinRef := 30
			
	// Cria o box principal
	oPrint:Box(nLinIni + 0010, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )
			
	// Imprime o Box do extrato
	oPrint:Box(nLinIni + nLinRef, nColIni + (nColMax * 0.02432), nLinIni + (nLinMax * 0.95) , nColIni + nColMax - 0010)
	nLinRef += 10
			
	// Imprime o cabecalho
	For nNy := 1 To Len(aColsExt)
		nColCalc := CalcPosCol(,aColsExt,nColMax,nNy)
		oPrint:Say(nLinIni + nLinRef, nColCalc, aColsExt[nNy][1], oFontBld3)
	Next nNy

	nLinRef += 10				
Endif

Return

function PLSR022las(lvalor)
lAutoSt := lvalor
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLGetTpEvDesc
Retorna a descrição do servico com base no campo BD6_TPEVCT, definido
através da função PLTpServ

@author Vinicius Queiros Teixeira
@since 26/05/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLGetTpEvDesc(cTipo)

	Local cDescricao := ""

	Default cTipo := ""

	Do Case
		Case cTipo == "01"
			cDescricao := "Consulta"
		
		Case cTipo $ "02/03/04/05"
			cDescricao := "Exames/Terapias"
		
		Case cTipo $ "06/07/08/09/10/11"
			cDescricao := "internações"
		
		Case cTipo $ "12/13/  "
			cDescricao := "Outros"
		
		OtherWise
			cDescricao := "Odonto"
	EndCase

Return cDescricao