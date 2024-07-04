#include "protheus.ch"

#define CRLF chr(13) + chr(10)
#define _QTD_REG_ 50000

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA1300
Exportacao do PTU A1300 - Cadastro Nacional de Usuarios

@author Renan Sakai/Alexander
@since  06/05/15
@version P12
/*/
//-------------------------------------------------------------------	  
Function PLSUA1300
	Local cPerg := "PLSU1300"

	If Pergunte(cPerg,.T.)
		cCodLay   := mv_par01
		cUniOri   := mv_par02
		cUniDes   := mv_par03
		nTpMov    := mv_par04
		dDataIni  := mv_par05
		dDataFim  := mv_par06
		cDirNov   := mv_par07  
		cAno      := mv_par08
		cMes      := mv_par09
		cEmpDe    := mv_par10
		cEmpAte   := mv_par11
		cContDe   := mv_par12
		cContAte  := mv_par13
		cSubConDe := mv_par14
		cSubConAte:= mv_par15
		lGeraR311 := iif(mv_par16 = 1, .t., .f.)
		lGeraR307 := iif(mv_par17 = 1, .t., .f.)
		lXML      := .T. // PTU A1300 somente em XML
		nInfANS   := mv_par19
		nInfSib   := mv_par20
		Processa({||GA1300A()},"Geração do arquivo do PTU A1300","Processando...",.T.)
	EndIf
Return       


//-------------------------------------------------------------------
/*/{Protheus.doc} GA1300A
Gera PTU 1300 

@author TOTVS
@since 11/12/2015
@version P11
/*/
//-------------------------------------------------------------------
Function GA1300A(lAuto)  

	Local cCodPEA    := Alltrim(GetNewPar("MV_PLSCPEA",""))    
	Local cDescEmp   := Alltrim(GetNewPar("MV_PTDS130",""))    
	Local lContUtlzd := .F.
	Local lVidaUtlzd := .F.  
	Local aAreaBA1   := {}
	Local aVetAbrang := {}       
	Local aVetCarenc := {}
	Local aRetCarenc := {}
	Local aR308For   := {}
	Local cChvProduto:= ""           
	Local cChaBA1    := ""  
	Local cChaCON	 := ""
	Local cChvR308   := ""
	Local lExistB9B  := PLSALIASEXI("B9B")
	Local lExistB9C  := PLSALIASEXI("B9C")
	Local lExistB5F  := PLSALIASEXI("B5F")
	Local nCont      := 0
	Local nFor       := 0
	Local nQuant	 := 0

	Local lUsuRepass := .F.

	//Variaveis registro 302	     			                              
	Local cCD_FILIAL  		:= ""
	Local cNM_EMPR_COMP		:= ""
	Local cNM_EMPR_ABRE		:= ""
	Local cCD_CNPJ_CEI  	:= ""
	Local cR2_CPNJ          := ""
	Local cR2_CEI           := ""
	Local cCD_INSC_EST  	:= ""
	Local cDS_END_PRI 		:= ""
	Local cDS_END_CPL   	:= ""
	Local cR2_DS_BAIRRO		:= ""
	Local cR2_NR_CEP   		:= ""
	Local cR2_DS_CIDADE		:= ""
	Local cR2_CD_UF			:= ""
	Local cR2_NR_DDD		:= ""     
	Local cR2_DT_INCL_UNI	:= ""     
	Local cR2_DT_EXCL_UNI	:= ""
	Local cCD_EMPR_ORI		:= ""     
	Local cR2_CD_MUNIC		:= ""
	Local cR2_NR_FONE		:= ""
	Local cNR_FAX			:= ""
	Local cR2_NR_CONTRATO	:= ""
	Local cNM_FANTASIA_EMPR	:= ""     

	//Variaveis registro 303	     			                              
	Local cNM_BENEF  := ""
	Local cDT_NASC   := ""
	Local cTP_SEXO   := ""
	Local cCD_CPF    := ""
	Local cCD_IDENT  := ""
	Local cORGAO_EMI := ""
	Local cCD_PAIS   := ""
	Local cCD_CNS    := ""
	Local cNM_MAE    := ""
	Local cCD_ECIVIL := ""
	Local cPIS_PASEP := ""
	Local cCD_MUNIC  := ""  
	Local cNM_SOCIAL := ""  
	Local cNM_COMPL  := ""
	Local cID_ESTRANG:= ""   
	Local cGeraRCP   := '1'
	Local cTPGENSOC  := ""
	Local cNMSOCCAR  := "" //Nome Social Cartão
	Local cECIVILPE  := ""

	//Variaveis registro 305	     			                          
	Local cIND_RESID     := ""
	Local cTP_END        := ""
	Local cDS_LOGRAD     := ""
	Local cNR_LOGRAD     := ""
	Local cCOMPL_LOGRAD  := ""
	Local cDS_BAIRRO	 := ""
	Local cDS_CIDADE     := ""
	Local cNR_CEP	     := ""
	Local cCD_UF         := ""
	Local cNR_DDD	     := ""
	Local cNR_RAMAL	     := ""
	Local cEND_EMAIL     := ""
	Local cTIP_EMAIL     := ""
	Local cNR_FONE	     := ""
	Local cTP_FONE       := ""
	Local cTP_LOGRADOURO := ""        
	Local cCepUsr        := ""

	//Variaveis registro 306	     			                          
	Local cCD_UNI      := ""
	Local cID_BENEF    := ""
	Local cIDBENEFTIT  := ""
	Local cCD_DEPE     := ""
	Local cDT_INCL_UNI := ""
	Local cDT_EXCL_UNI := ""
	Local cID_SIB      := ""
	Local cNR_PLA_PORT := ""
	Local cID_REMIDO   := ""	 
	Local cBEN_COOP    := ""
	local cCRM         := ""
	local cUF_CRM      := ""	    

	//Variaveis registro 307	     			                               
	Local cCD_UNI_OR   := ""
	Local cCD_UNI_DE   := ""
	Local cDT_INI_RE   := ""
	Local cDT_FIM_RE   := ""
	LOCAL cDT_RISCO    := ""
	Local cTP_REPASS   := ""
	Local CD_UNI_DES   := ""
	Local ID_BENEF_DES := ""
	Local aRepasse     := {}

	//Variaveis registro 308	     			                                 
	Local cNM_CONTR    		 := ""
	Local cDT_INIVIG   		 := ""
	Local cDT_FIMVIG   		 := ""
	Local cTP_ABRANG   		 := ""
	Local cTP_NATURE   		 := ""
	Local cTP_ACOMOD   		 := ""
	Local cID_REG_PL   		 := ""
	Local cREG_PLANO   		 := ""
	Local cSEG_PLANO   		 := ""
	Local cCD_REDE     		 := ""
	Local cNM_REDE     		 := ""
	Local cVIA_CARTAO  		 := ""
	Local cVIA_CARPE  		 := ""
	Local cDT_VAL_CAR  		 := ""
	Local cCD_LCAT     		 := ""
	Local cID_CPT      		 := ""
	Local cDT_FIM_CPT  		 := ""
	Local cTP_CONTRAT  		 := ""
	Local cMOTIVO_EXC  		 := ""	
	Local cNM_ADM_BEN  		 := ""
	Local cNM_PRODUTO  		 := ""
	Local cRAZ_SOC_ADM_BENEF := ""
	Local cNR_CONTRATO 		 := ""
	Local cDT_CONTR_PLANO 	 := "" 
	Local cTP_REDE		     := ""
	Local cCNPJADM_BEN   	 := "" 
	Local cTP_ACOMPE         := ""

	//Variaveis registro 316
	Local cR16_CDUNI         := ""
	Local cR16_MATRI         := ""
	Local cR16_DTEXC         := ""

	//Variaveis registro 317	 
	Local cCD_CNPJ   		:= ""
	Local cCD_AUT_GEST	:= ""

	//Variaveis registro 318
	Local nPF_CO_LOC := 0
	Local nPF_PP_LOC := 0
	Local nPJ_CO_LOC := 0
	Local nPJ_PP_LOC := 0
	Local nPF_REP_CO := 0
	Local nPF_REP_PP := 0
	Local nPJ_REP_CO := 0
	Local nPJ_REP_PP := 0
	Local nPF_REC_CO := 0
	Local nPF_REC_PP := 0
	Local nPJ_REC_CO := 0
	Local nPJ_REC_PP := 0

	//Variaveis registro 319	 
	Local nReg302 := 0	
	Local nReg311 := 0
	Local nReg307 := 0
	Local nReg316 := 0
	Local nReg317 := 0

	Local cCmpPTU := GetNewPar("MV_PTC1300","BA1_DATNAS;BA1_SEXO;BA1_CPFUSR;BA1_NOMUSR;BA1_MAE;BA1_TIPUSU;BA1_ENDERE;BA1_CEPUSR;BA1_MUNICI;BA1_ESTADO")
	Local nCmpPTU := 0
	Local cCmpIn := "('')"
	Local lExisPETag := .F.    
	Local lRemido := BA1->(FieldPos("BA1_REMIDO")) > 0  
	Local lUsaRemd := GetNewPar("MV_PLUSARD",.F.) 
	Local lTipoTel := BA1->(FieldPos("BA1_TIPTEL")) > 0 .And. BTS->(FieldPos("BTS_TIPTEL")) > 0  
	Local cCodInt := PlsIntPad()
	Local cDtVLRC := ""
	Local lCaepf := BQC->(FieldPos("BQC_CAEPF")) > 0
	Local lCnpjAdm := BQC->(FieldPos("BQC_CNPADM")) > 0
	Local lGenSoc := BTS->(FieldPos("BTS_GENSOC")) > 0
	Local lNomSoc := BTS->(FieldPos("BTS_NOMSOC")) > 0
	Local lAutGes := BQC->(FieldPos("BQC_AUTGES")) > 0
	Local lAutoGestao := .F.

	Local xFilBA1 := xFilial("BA1")
	Local xFilBA3 := xFilial("BA3")
	Local xFilBG9 := xFilial("BG9")
	Local xFilBQC := xFilial('BQC')
	Local xFilBTS := xFilial("BTS")
	Local xFilBC9 := xFilial("BC9")
	Local xFilBRP := xFilial("BRP")
	Local xFilB5F := xFilial("B5F")
	Local xFilBI3 := xFilial("BI3")
	Local xFilBIL := xFilial("BIL")
	Local xFilBF7 := xFilial("BF7")
	Local xFilBI4 := xFilial("BI4")
	Local xFilBI6 := xFilial("BI6")
	Local xFilBG3 := xFilial("BG3")
	Local xFilBG1 := xFilial("BG1")
	Local xFilBQU := xFilial("BQU")
	Local xFilB9B := xFilial("B9B")
	Local xFilB9C := xFilial("B9C")
	Local xFilB18 := xFilial("B18")
	Local xFilBA0 := xFilial('BA0')

	Local lBI3TipR := BI3->(FieldPos("BI3_TIPRED")) > 0

	Local nSpace1 := Space(1)
	Local nSpace2 := Space(2)
	Local nSpace3 := Space(3)
	Local nSpace4 := Space(4)
	Local nSpace8 := Space(8)
	Local nSpace9 := Space(9)
	Local nSpace13 := Space(13)
	Local nSpace18 := Space(18)
	Local nSpace20 := Space(20)
	Local nSpace25 := Space(25)
	Local nSpace30 := Space(30)
	Local nSpace40 := Space(40)
	Local nSpace70 := Space(70)

	Local sStrZ15 := Strzero(0,15)

	Local nReplic4 := Replicate("0",4)
	Local nReplic20 := Replicate("0",20)
	Local nReplic9 := Replicate("0",9)
	Local nReplic15	:= Replicate("0",15)
	Local nReplic14	:= Replicate("0",14)
	Local nReplic8 := Replicate("0",8)
	Local nReplic7 := Replicate("0",7)

	local oTab301
	local oTab302            
	local oTab303           
	local oTab305 
	local oTab306
	local oTab307  
	local oTab308 
	local oTab309  
	local oTab310
	local oTab311
	local oTab316
	local oTab317

	// Ponto de Entrada
	Local cNmEmprComp := ""
	Local cNmEmprAbre := ""
	Local cNmFantasiaEmpr := ""
	Local cNmContr := ""
	Local aAbrangPE := {}
	Local nNx := 0
	Local lPL1300ABRA := .F.
	Local cDtValCarPE := ""
	Local cNmPRODPE := ""
	
	private oXML1300

	private nQtdIEmp := 0
	private nQtdIPes := 0
	private nQtdIAut := 0

	private nQtdAEmp := 0
	private nQtdAPes := 0
	private nQtdAAut := 0

	private nQtdExc := 0

	Private lPEContag := .F.  

	private lPF

	Default lAuto	:= .F.

	If ExistBlock( "PL1300TAG" )
		lExisPETag := .T.
	EndIf 

	If ExistBlock( "PL1300CONT" )
		lPEContag := .T.
	EndIf

	If ExistBlock( "PL1300ABRA" )
		lPL1300ABRA := .T.
	EndIf

	//Verifica se o mes/ano da contagem foram informados                       
	If Empty(cAno).Or. Empty(cMes)
		MsgInfo("O Mês e(ou) Ano para Contagem de Beneficiários não foram preenchidos.")		
		Return	
	EndIf   

	If nTpMov == 4 .And. cCodLay < "A1300D"
		MsgInfo("A opção 'Somente Exclusão' está disponível somente para a versão 10.0 ou superior.")		
		Return	
	EndIf

	criaXMLArea(@oTab301, @oTab302, @oTab303, @oTab305, @oTab306, @oTab307, @oTab308, @oTab309, @oTab310, @oTab311, @oTab316, @oTab317)	

	//Setando os indices que serao utilizados										
	BA1->(DbGoTop()) 
	BTS->(DbSetOrder(1))//BTS_FILIAL + BTS_MATVID
	BRP->(DbSetOrder(1))//BRP_FILIAL + BRP_CODIGO
	BG9->(DbSetOrder(1))//BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
	BI3->(DbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO   
	BI4->(DbSetOrder(1))//BI4_FILIAL + BI4_CODACO
	BI6->(DbSetOrder(1))//BI6_FILIAL + BI6_CODSEG
	BA3->(DbSetOrder(1))//BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
	BIL->(DbSetOrder(1))//BIL_FILIAL + BIL_CODIGO + BIL_VERSAO + DTOS(BIL_DATINI)
	BF7->(DbSetOrder(1))//BF7_FILIAL + BF7_CODORI      
	BG3->(DbSetOrder(1))//BG3_FILIAL + BG3_CODBLO
	BG1->(DbSetOrder(1))//BG1_FILIAL + BG1_CODBLO + BG1_TIPBLO
	BC9->(DbSetOrder(1))//BC9_FILIAL + BC9_CEP
	B18->(DbSetOrder(1))//B18_FILIAL + B18_CODIGO
	BQC->(DbSetOrder(1))//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	BAU->(DbSetOrder(1))//BAU_FILIAL + BAU_CODIGO

	dDataIniSq := dtos(dDataIni)
	dDataFimSq := dtos(dDataFim)

	If lExistB9B .And. lExistB9C
		B9B->(DbSetOrder(1))//B9B_FILIAL+B9B_CODORI+B9B_CODMUN
		B9C->(DbSetOrder(1))//B9C_FILIAL+B9C_CODORI+B9C_ESTADO
	EndIf    

	//Pega os registros que teve AlteraÃ§Ã£o Cadastro								
	If nTpMov == 3
		//Vou verificar todos os campos que tiveram alteracao						
		cCmpIn := "('"
		For nCmpPTU := 1 To Len(cCmpPTU)	
			If SubStr(cCmpPTU,nCmpPTU,1) == ";"
				cCmpIn += "','"
			Else
				cCmpIn += SubStr(cCmpPTU,nCmpPTU,1)
			EndIf
		Next
		cCmpIn += "')"
	EndIf

	//Verificar , select diferente para quando o tipo de movimentação é somente exclusão, pois selecionando só o recno, não garante que 
	//matriculas repetidas não fossem trazidas, assim quando o arquivo era validado no webStart, criticava beneficiário duplicado.
	If nTpMov == 4   													
		cSQL := "SELECT BA1_CODINT , BA1_CODEMP, BA1_MATRIC , BA1_TIPREG , BA1_DIGITO "
	Else
		cSQL := "SELECT BA1.R_E_C_N_O_ RECBA1, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "
	EndIf	
	cSQL += " FROM "+RetSQLName("BA1")+" BA1 WHERE "
	cSQL += retCondBA1()

	//Verifica o tipo de movimentacao                                              
	//A = Cadastro Ativo - massa total somente com beneficiarios ativos           
	//M = Cadastro Completo - massa total com beneficiarios ativos e excluidos    
	//    de todos os períodos já enviados e existentes no cadastro.              
	//P = Movimentação Periodica, com inclusoes, alteracoes e exclusoes.          
	//E = Somente exclusoes (R301, R316 e R319)          
	If nTpMov == 1 //A = Cadastro Ativo
		cSQL += " AND BA1_MOTBLO = ' ' "  
		If !Empty(dDataFimSq)  
			cSQL += " AND BA1_DATINC >= '" + dDataIniSq + "' "	
			cSQL += " AND BA1_DATINC <= '" + dDataFimSq + "' "	
		EndIf
	Endif

	//P = Movimentação Periodica
	If nTpMov == 3
		cSQL += " AND ("
		cSQL += " (BA1_DATINC >= '" + dDataIniSq + "' AND BA1_DATINC <= '" + dDataFimSq + "' )"
		cSQL += " OR (BA1_DATREP <> ' ' AND BA1_DATREP >= '" + dDataIniSq + "' AND BA1_DATREP <= '" + dDataFimSq + "' ) "
		cSQL += " OR (BA1_DATBLO <> ' ' AND BA1_DATBLO >= '" + dDataIniSq + "' AND BA1_DATBLO <= '" + dDataFimSq + "' ) "
		cSQL += " )"
	ElseIf nTpMov == 4
		cSQL += " AND (BA1_DATBLO <> ' '  AND BA1_MOTBLO <> ' ' AND  BA1_DATBLO >= '" + dDataIniSq + "' AND BA1_DATBLO <= '" + dDataFimSq + "' ) "
	EndIf

	cSQL += " AND BA1.D_E_L_E_T_ = ' ' "

	//Union com as alteracoes
	If nTpMov == 3 .And. !Empty(cCmpIn)
		cSQL += " UNION SELECT BA1.R_E_C_N_O_ RECBA1, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "
		cSQL += " FROM "+RetSQLName("BX1")+" BX1 "

		cSQL += " INNER JOIN "+RetSQLName("BA1")+" BA1 ON "
		cSQL += retCondBA1()
		cSQL += " 	 AND CAST(BX1_RECNO AS INT) = BA1.R_E_C_N_O_ "
		cSQL += " 	 AND BA1.D_E_L_E_T_ = ' ' "

		cSQL += " INNER JOIN "+RetSQLName("BX2")+" BX2 "
		cSQL += " 	 ON  BX2.BX2_FILIAL = '"+xFilial("BX2")+"' "
		cSQL += " 	 AND BX2.BX2_CAMPO IN " + cCmpIn
		cSQL += "  	 AND BX2.D_E_L_E_T_ = ' ' "
		
		cSQL += " WHERE BX1.BX1_FILIAL = '"+xFilial("BX1")+"' "
		cSQL += "    AND BX1.BX1_ALIAS = 'BA1' "
		cSQL += "    AND BX1.BX1_TIPO = 'A' "
		cSQL += "    AND BX1.BX1_DATA >= '" + dDataIniSq + "' "
		cSQL += "    AND BX1.BX1_DATA <= '" + dDataFimSq + "' "
		cSQL += "    AND BX1.BX1_SEQUEN = BX2.BX2_SEQUEN "
		cSQL += "    AND BX1.D_E_L_E_T_ = ' ' "

		//Verifica inclusoes retroativas
		cSQL += " UNION SELECT BA1.R_E_C_N_O_ RECBA1, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "
		cSQL += " FROM "+RetSQLName("BX1")+" BX1 "

		cSQL += " INNER JOIN "+RetSQLName("BA1")+" BA1 ON "
		cSQL += retCondBA1()
		cSQL += " 	 AND CAST(BX1_RECNO AS INT) = BA1.R_E_C_N_O_ "
		cSQL += " 	 AND BA1.D_E_L_E_T_ = ' ' "
		
		cSQL += " WHERE BX1.BX1_FILIAL = '"+xFilial("BX1")+"' "
		cSQL += "    AND BX1.BX1_ALIAS = 'BA1' "
		cSQL += "    AND BX1.BX1_TIPO = 'I' "
		cSQL += "    AND BX1.BX1_DATA >= '" + dDataIniSq + "' "
		cSQL += "    AND BX1.BX1_DATA <= '" + dDataFimSq + "' "
		cSQL += "    AND BX1.D_E_L_E_T_ = ' ' "
	EndIf

	If nTpMov == 3
		cSQL := QueryUnionA1300(cSQL, dDataIniSq, dDataFimSq)
	EndIf

	//Finaliza a Query
	If nTpMov == 4
		cSQL += "GROUP BY BA1_CODINT , BA1_CODEMP, BA1_MATRIC , BA1_TIPREG , BA1_DIGITO "
	Else
		cSQL += "ORDER BY BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "
	EndIf
	If ExistBlock( "PL1300QRY" )
		cSQL := ExecBlock( "PL1300QRY", .F., .F., {cSQL} )
	EndIf

	//Se selecionado somente exclusoes, gera somente os registros R301, R316 e R319
	If nTpMov == 4
		geraR316(cSQL,lAuto)
		fechaXMLArea(@oTab301, @oTab302, @oTab303, @oTab305, @oTab306, @oTab307, @oTab308, @oTab309, @oTab310, @oTab311, @oTab316, @oTab317)
		Return 
	EndIf

	// aContratos := {}
	// aVidas	   := {}
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBA1",.F.,.T.)

	While ! TRBBA1->( EOF() )
		lPF := .f.
		cGeraRCP := '1'	
		BA1->(dbGoto(TRBBA1->RECBA1))
		
		lVidaUtlzd := .F.
		lContUtlzd := .F. 
		lUsuRepass := .F.  
		lBenefAlt  := .F.    
		lDepend    := .F.   
		lAutoGestao := .F.
		
		aRepasse   := {}
		cR16_CDUNI := ""

		//Verificacoes que retiram o usuario do arquivo
		//Usuario de intercambio eventual nao entra                               
		If BA1->BA1_CODEMP $ cDescEmp
			TRBBA1->(DbSkip())
			Loop
		EndIf
		
		cChaCON := BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB)
		cChaBA1 := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)

		If Empty(BA1->BA1_CODPLA)
			If BA3->(DbSeek(xFilBA3+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				cChvProduto := BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
			EndIf
		Else
			cChvProduto := BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
		EndIf		

		aAreaT302 := T302->(getarea())
		T302->(dbgotop())
		T302->(DbSetOrder(1))
		if T302->(dbseek(cChaCON))
			lContUtlzd := .t.
		endif 
		restarea(aAreaT302)

		aAreaT303 := T303->(getarea())
		T303->(dbgotop())
		if T303->(dbseek(cChaCON+cChaBA1))
			lVidaUtlzd := .T. 
		endif
		restarea(aAreaT303)

		//Variaveis relacionadas ao registro R302 - Dados da Empresa Contratante.
		if BG9->(msSeek(xFilBG9+BA1->(BA1_CODINT+BA1_CODEMP)))

			cCD_FILIAL  	:= Strzero(Val(BG9->BG9_FILIAL),3)

			cNM_EMPR_COMP	:= Padl(BG9->BG9_DESCRI,40)
			// Ponto de Entrada para Tag (nm_empr_comp)
			If lExisPETag	     
				cNmEmprComp := ExecBlock( "PL1300TAG", .F., .F., {"nm_empr_comp",BA1->(Recno())} )
				If !Empty(cNmEmprComp)
					cNM_EMPR_COMP :=  Padl(cNmEmprComp,40)
				EndIF
			EndIf

			cNM_EMPR_ABRE	:= Padl(BG9->BG9_NREDUZ,30)
			// Ponto de Entrada para Tag (nm_empr_abre)
			If lExisPETag	     
				cNmEmprAbre := ExecBlock( "PL1300TAG", .F., .F., {"nm_empr_abre",BA1->(Recno())} )
				If !Empty(cNmEmprAbre)
					cNM_EMPR_ABRE :=  Padl(cNmEmprAbre,30)
				EndIF
			EndIf

			cNM_FANTASIA_EMPR	:= padr(BG9->BG9_DESCRI,40)
			// Ponto de Entrada para Tag (nm_fantasia_empr)
			If lExisPETag	     
				cNmFantasiaEmpr := ExecBlock( "PL1300TAG", .F., .F., {"nm_fantasia_empr",BA1->(Recno())} )
				If !Empty(cNmFantasiaEmpr)
					cNM_FANTASIA_EMPR :=  Padl(cNmFantasiaEmpr,40)
				EndIF
			EndIf
		
			if BQC->(msSeek(xFilBQC+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))) 
				
				If !Empty(BQC->BQC_CNPJ)
					cCD_CNPJ_CEI  		:= StrZero(Val(BQC->BQC_CNPJ),15)
				Elseif lCaepf .And. cCodLay >= "A1300E"	.And. !Empty(BQC->BQC_CAEPF)					
					cCD_CNPJ_CEI    := StrZero(Val(BQC->BQC_CAEPF),15)
					cR2_CEI         := StrZero(Val(BQC->BQC_CAEPF),14)
				Else
					cCD_CNPJ_CEI  	:= StrZero(Val(BQC->BQC_CEINSS),15)
					cR2_CEI 		:= StrZero(Val(BQC->BQC_CEINSS),14)
				EndIF				
				cR2_CPNJ  			:= StrZero(Val(BQC->BQC_CNPJ),15)	

				// Se CNPJ, CAEPF e CEINSS estiver em branco busca no SA1
				IF Empty(BQC->BQC_CNPJ) .And. Empty(BQC->BQC_CAEPF) .And. Empty(BQC->BQC_CEINSS)  
					If SA1->(MsSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
						cR2_CPNJ := StrZero(Val(IIF(CNPJ(SA1->A1_CGC),SA1->A1_CGC,"")),15) // Busca o CNPJ
						cR2_CEI	 := StrZero(Val(SA1->A1_CEINSS),14) // Busca o CEI 			 	
					Endif	
				Endif 	
									   	
				cCD_INSC_EST  		:= nReplic20
				cDS_END_PRI 		:= PadR(PlRetponto(BQC->BQC_LOGRAD),40)
				cDS_END_CPL   		:= PadR(BQC->BQC_COMPLE,20)
				cR2_DS_BAIRRO		:= PadR(PlRetponto(BQC->BQC_BAIRRO),30)
				cR2_NR_CEP   		:= StrZero(Val(BQC->BQC_CEP),8)
				cR2_DS_CIDADE		:= left(BQC->BQC_MUN,30)
				cR2_CD_UF			:= BQC->BQC_ESTADO
				cR2_NR_DDD			:= nReplic4    
				cR2_DT_INCL_UNI		:= dtos(BQC->BQC_DATCON)     
				cR2_DT_EXCL_UNI		:= dtos(BQC->BQC_DATBLO)
				cCD_EMPR_ORI		:= StrZero(Val(BQC->BQC_CODIGO),10)
				cR2_CD_MUNIC		:= StrZero(Val(BQC->BQC_CODMUN),7)		
				cR2_NR_FONE			:= StrZero(Val(RemovChar(Substr(BQC->BQC_TEL,1,9))),9)
				cNR_FAX				:= nReplic9
				cR2_NR_CONTRATO		:= Padr(BA1->(BA1_SUBCON+BA1_VERSUB),15)
			else
				cNM_EMPR_ABRE		:= Padl(BG9->BG9_NREDUZ,30)
				cCD_CNPJ_CEI  		:= nReplic15
				cR2_CPNJ            := nReplic15
				cR2_CEI             := nReplic14
				cCD_INSC_EST  		:= nReplic20
				cDS_END_PRI 		:= nSpace40
				cDS_END_CPL   		:= nSpace20
				cR2_DS_BAIRRO		:= nSpace30
				cR2_NR_CEP   		:= nReplic8
				cR2_DS_CIDADE		:= nSpace30
				cR2_CD_UF			:= nSpace2
				cR2_NR_DDD			:= nReplic4     
				cR2_DT_INCL_UNI		:= nSpace8     
				cR2_DT_EXCL_UNI		:= nSpace8
				cCD_EMPR_ORI		:= StrZero(Val(BA1->BA1_CODEMP),10)
				cR2_CD_MUNIC		:= nReplic7 
				cR2_NR_FONE			:= nReplic9 
				cNR_FAX				:= nReplic9
				cR2_NR_CONTRATO		:= padr(BA1->(BA1_CODINT+BA1_CODEMP),15)
				cNM_FANTASIA_EMPR	:= padr(BG9->BG9_NREDUZ,40)

				lPF := .t.
			endIf
		else
			TRBBA1->(dbSkip())
			loop	
		endIf

		// Consulta a tabela temporario R302, se já existe CNPJ cadastrado, se já houver não cadastra novamente a empresa contrante
		If !Empty(cR2_CPNJ) .AND. cR2_CPNJ != replicate("0", 15) .AND. lXML
			aAreaT302 := T302->(getarea())
			T302->(dbgotop())
			T302->(DbSetOrder(2))
			If T302->(dbseek(right(cR2_CPNJ, 14)))
				lContUtlzd := .T.
			Endif 
			restarea(aAreaT302)
		EndIf		
		
		//Variaveis relacionadas ao registro R303 - Dados da Pessoa                   
		BTS->(DbSeek(xFilBTS+BA1->BA1_MATVID))
		
		cNM_BENEF  	:= BTS->BTS_NOMCAR 
		cDT_NASC   	:= Dtos(BA1->BA1_DATNAS)
		
		//1=Masculino;2=Feminino
		cTP_SEXO   := iif(BA1->BA1_SEXO=="1","M","F")
		cCD_CPF    := Strzero(Val(BA1->BA1_CPFUSR),15)
		
		If lGenSoc .AND. cCodLay >= "1300E"
			Do Case
				Case BTS->BTS_GENSOC == "1" //Feminino 
					cTPGENSOC := "F"
				Case BTS->BTS_GENSOC == "2" //Masculino
					cTPGENSOC := "M"
				Case BTS->BTS_GENSOC == "3" //Ignorado
					cTPGENSOC := "I"	   
				OtherWise
					cTPGENSOC := "I"
			EndCase  					
		
			cNMSOCCAR := BTS->BTS_NOMCAR
		EndIF
		
		//Se dependente, vou armazenar as informacoes do titular como endereco        
		aDadosTit := {}                 

		If BA1->BA1_TIPUSU == "D"
			aAreaBA1 := BA1->(GetArea())  
			BA1->(DbSetOrder(1))
			If BA1->(DbSeek(xFilBA1+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+"T"))) 
				lDepend := .T.
				Aadd(aDadosTit,Padr(Substr(PlRetponto(BA1->BA1_ENDERE),1,40),40))//1  
				Aadd(aDadosTit,Substr(PlRetponto(BA1->BA1_NR_END),1,6))//2
				Aadd(aDadosTit,Substr(PlRetponto(BA1->BA1_COMEND),1,20))//3
				Aadd(aDadosTit,Padr(PlRetponto(BA1->BA1_BAIRRO),30))  //4
				Aadd(aDadosTit,Substr(BA1->BA1_MUNICI,1,30))        //5
				Aadd(aDadosTit,Strzero(Val(BA1->BA1_CODMUN),7))     //6
				Aadd(aDadosTit,BA1->BA1_CEPUSR)	                    //7
				Aadd(aDadosTit,Substr(BA1->BA1_ESTADO,1,2))         //8
				Aadd(aDadosTit,Strzero(Val(BA1->BA1_DDD),4))        //9
				Aadd(aDadosTit,nReplic4)                    //10
				Aadd(aDadosTit,Padr(BA1->BA1_EMAIL,40))             //11
				Aadd(aDadosTit,StrZero(Val(RemovChar(Substr(BA1->BA1_TELEFO,1,9))),9))//12     
				Aadd(aDadosTit,iif(lTipoTel,BA1->BA1_TIPTEL,"0"))    //13
			EndIf
			RestArea(aAreaBA1)	
		EndIf
		
		If BTS->(DbSeek(xFilBTS+BA1->BA1_MATVID))
			cCD_CNS 	:= Padr(BTS->BTS_NRCRNA,15)    
			cCD_IDENT  	:= Substr(BTS->BTS_CDIDEN,1,30) //Padr(BTS->BTS_DRGUSR,30
			cORGAO_EMI 	:= Substr(BTS->BTS_ORGEMI,1,30) //BTS->BTS_BTS_ORGEM
			cNM_COMPL	:= Substr(AllTrim(BTS->BTS_NOMUSR) + " " + AllTrim(BTS->BTS_SOBRN),1,70)
			//
			If lNomSoc
				cNM_SOCIAL	:= Iif(Empty(BTS->BTS_NOMSOC), Substr(BTS->BTS_NOMSOC,1,70),nSpace70) 		
			Else
				cNM_SOCIAL	:= Iif(Empty(BTS->BTS_NOMCAR), Substr(BTS->BTS_NOMRED,1,30),Substr(BTS->BTS_NOMCAR,1,30)) 	
			EndIF

			If !Empty(BTS->BTS_CDPAIS)
				cCD_PAIS   := Substr(BTS->BTS_CDPAIS,1,3)  //BTS->BTS_RGEST  
			Else
				cCD_PAIS   := nSpace3  //BTS->BTS_RGEST  
			EndIf
			If (cPaisLoc == 'BRA' .And. BTS->BTS_NACION == '10') .OR. (cPaisLoc == "URU" .And. BTS->BTS_NACION == '25')
				cID_ESTRANG := 'N'
			ElseIf Empty(BTS->BTS_NACION)
				cID_ESTRANG := 'N'
			Else	
				cID_ESTRANG := 'S'
			EndIf 
		Else
			cCD_CNS    := nSpace25	
			cCD_IDENT  := nSpace30
			cORGAO_EMI := nSpace30
			cCD_PAIS   := nSpace3
		EndIf	  
		cNM_MAE    := Substr(BA1->BA1_MAE,1,70)
		Do Case
			Case BA1->BA1_ESTCIV == "C" //Casado(a) 
				cCD_ECIVIL := "M"
			Case BA1->BA1_ESTCIV == "D" //Divorciado(a)
				cCD_ECIVIL := "D"
			Case BA1->BA1_ESTCIV == "M" //Marital
				cCD_ECIVIL := "U"
			Case BA1->BA1_ESTCIV == "Q" //Desquitado(a) 
				cCD_ECIVIL := nSpace1
			Case BA1->BA1_ESTCIV == "S" //Solteiro(a)
				cCD_ECIVIL := "S"
			Case BA1->BA1_ESTCIV == "V" //Viuvo(a)
				cCD_ECIVIL := "W"  
			OtherWise
				cCD_ECIVIL := nSpace1
		EndCase  
		
		//Se BA1 nao preenchido, tenta buscar informacao na BTS
		If Empty(cCD_ECIVIL)
			Do Case
				Case BTS->BTS_ESTCIV == "C" //Casado(a) 
					cCD_ECIVIL := "M"
				Case BTS->BTS_ESTCIV == "D" //Divorciado(a)
					cCD_ECIVIL := "D"
				Case BTS->BTS_ESTCIV == "M" //Marital
					cCD_ECIVIL := nSpace1
				Case BTS->BTS_ESTCIV == "Q" //Desquitado(a) 
					cCD_ECIVIL := nSpace1
				Case BTS->BTS_ESTCIV == "S" //Solteiro(a)
					cCD_ECIVIL := "S"
				Case BTS->BTS_ESTCIV == "V" //Viuvo(a)
					cCD_ECIVIL := "W"  
				OtherWise
					cCD_ECIVIL := nSpace1
			EndCase
		EndIf
		
		If lExisPETag	     
			cECIVILPE := ExecBlock( "PL1300TAG", .F., .F., {"CD_ECIVIL",BA1->(Recno())} )
			If !Empty(cECIVILPE)
				cCD_ECIVIL := cECIVILPE
			EndIF
		EndIf
		
		If !Empty(BA1->BA1_PISPAS)
			cPIS_PASEP := Strzero(Val(BA1->BA1_PISPAS),11)
		Else
			cPIS_PASEP := Strzero(Val(BTS->BTS_PISPAS),11)
		EndIf	

		//Variaveis relacionadas ao registro R305 - Complemento cadastral             
		cIND_RESID     := "1"
		cTP_END        := "1"

		cDS_LOGRAD := Padr(Substr(PlRetponto(BA1->BA1_ENDERE),1,40),40) 
		If Empty(cDS_LOGRAD) .And. lDepend 
			If !Empty(BTS->BTS_ENDERE)
				cDS_LOGRAD := Padr(Substr(PlRetponto(BTS->BTS_ENDERE),1,40),40)
			Else
				cDS_LOGRAD:= aDadosTit[1]
			Endif	
		EndIf
				
		cNR_LOGRAD := Substr(BA1->BA1_NR_END,1,6)
		If Empty(cNR_LOGRAD) .And. lDepend  
			If !Empty(BTS->BTS_NR_END)
				cNR_LOGRAD := Substr(BTS->BTS_NR_END,1,6)
			Else
				cNR_LOGRAD := aDadosTit[2]
			EndIf	
		EndIf   
		
		If Empty(cNR_LOGRAD)
			cNR_LOGRAD := "S/N   "
		Endif
		
		cCOMPL_LOGRAD  := Substr(PlRetponto(BA1->BA1_COMEND),1,20)
		If Empty(cCOMPL_LOGRAD) .And. lDepend
			If !Empty(BTS->BTS_COMEND)
				cCOMPL_LOGRAD:= Substr(PlRetponto(BTS->BTS_COMEND),1,20)
			Else
				cCOMPL_LOGRAD:= aDadosTit[3]
			EndIf	
		EndIf   
		
		cDS_BAIRRO := Padr(PlRetponto(BA1->BA1_BAIRRO),30) 
		If Empty(cDS_BAIRRO) .And. lDepend  
			If !Empty(PlRetponto(BTS->BTS_BAIRRO))
				cDS_BAIRRO := Padr(PlRetponto(BTS->BTS_BAIRRO),30)
			Else
				cDS_BAIRRO := aDadosTit[4]
			EndIf	
		EndIf   
		
		cDS_CIDADE := Substr(BA1->BA1_MUNICI,1,30)
		If Empty(cDS_CIDADE) .And. lDepend
			If !Empty(BTS->BTS_MUNICI)
				cDS_CIDADE := Substr(BTS->BTS_MUNICI,1,30)
			Else	
				cDS_CIDADE := aDadosTit[5]
			EndIf	
		EndIf  
		
		cCD_MUNIC := Strzero(Val(BA1->BA1_CODMUN),7) 
		If Empty(cCD_MUNIC) .And. lDepend  
			If !Empty(BTS->BTS_CODMUN)   
				cCD_MUNIC := Strzero(Val(BTS->BTS_CODMUN),7) 
			Else
				cCD_MUNIC := Strzero(Val(aDadosTit[6]),7)
			Endif	
		EndIf  
		
		cNR_CEP := Strzero(Val(BA1->BA1_CEPUSR),8)	
		If Empty(cNR_CEP) .And. lDepend 
			If !Empty(BTS->BTS_CEPUSR)    
				cNR_CEP := Strzero(Val(BTS->BTS_CEPUSR),8)	
			Else
				cNR_CEP := Strzero(Val(aDadosTit[7]),8)
			Endif	
		EndIf  
		
		cCD_UF := Substr(BA1->BA1_ESTADO,1,2)  
		If Empty(cCD_UF) .And. lDepend
			If !Empty(BTS->BTS_ESTADO)  
				cCD_UF := Substr(BTS->BTS_ESTADO,1,2)  
			Else
				cCD_UF := aDadosTit[8]
			EndIf	
		EndIf  
		
		cNR_DDD := Strzero(Val(BA1->BA1_DDD),4) 
		If Empty(cNR_DDD) .And. lDepend  
			If !Empty(BTS->BTS_DDD)   
				cNR_DDD := Strzero(Val(BTS->BTS_DDD),4) 
			Else
				cNR_DDD := Strzero(Val(aDadosTit[9]),4) 
			EndIf	
		EndIf  
		
		cNR_RAMAL := nReplic4       
		If Empty(cNR_RAMAL) .And. lDepend
			cNR_RAMAL := aDadosTit[10]
		EndIf  
		
		cEND_EMAIL := Padr(BA1->BA1_EMAIL,40)
		If Empty(cEND_EMAIL) .And. lDepend   
			If !Empty(BTS->BTS_EMAIL)
				cEND_EMAIL := Padr(BTS->BTS_EMAIL,40)
			Else
				cEND_EMAIL := aDadosTit[11]
			EndIf	
		EndIf  
		
		cTIP_EMAIL := "1"
		
		cNR_FONE := StrZero(Val(RemovChar(Substr(BA1->BA1_TELEFO,1,9))),9)

		If	lTipoTel
			cTP_FONE := Iif(Empty(BA1->BA1_TIPTEL),"1",BA1->BA1_TIPTEL)
		Else
			cTP_FONE := "1" 

		Endif	
		
		If Empty(cNR_FONE) .And. lDepend   
			If !Empty(BTS->BTS_TELEFO)
				cNR_FONE := StrZero(Val(RemovChar(Substr(BTS->BTS_TELEFO,1,9))),9)
				If lTipoTel
				cTP_FONE := Iif(Empty(BTS->BTS_TIPTEL),"1",BTS->BTS_TIPTEL)
				Else
				cTP_FONE := "1" 
				Endif   
			Else
				cNR_FONE := aDadosTit[12]
				cTP_FONE := aDadosTit[13]
			EndIf	
		EndIf    
		If Empty(cNR_FONE) .Or. Empty(cTP_FONE)
			cTP_FONE := "1"
		EndIf    
		
		If !Empty(BA1->BA1_CEPUSR)
			cCepUsr := BA1->BA1_CEPUSR
		ElseIf !Empty(BTS->BTS_CEPUSR)  
			cCepUsr := BTS->BTS_CEPUSR	
		ElseIf lDepend 
			cCepUsr := aDadosTit[7]
		EndIf
		
		cTP_LOGRADOURO := "00"
		If !Empty(cCepUsr) .And. BC9->(DbSeek(xFilBC9+cCepUsr))
			If !Empty(BC9->BC9_TIPLOG) .And. B18->(DbSeek(xFilB18+BC9->BC9_TIPLOG))
				cTP_LOGRADOURO := B18->B18_CODEDI 
			EndIf
		EndIf	

		//Variaveis relacionadas ao registro R306 - Dados Beneficiarios               
		cCD_UNI       := BA1->BA1_CODINT
		cID_BENEF     := BA1->(BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
		If BA1->BA1_TIPUSU == "T"
			cIDBENEFTIT := BA1->(BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
		Else
			BA1->(DbSetOrder(1))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
			aAreaBA1 := BA1->(GetArea())
			If BA1->(DbSeek(xFilBA1+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+"T")))
				cIDBENEFTIT := BA1->(BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
			Else
				cIDBENEFTIT := nSpace13
			EndIf 
			RestArea(aAreaBA1)
		EndIf	
		
		If BRP->(DbSeek(xFilBRP+BA1->BA1_GRAUPA))
			cCD_DEPE  := BRP->BRP_CODPTU
		Else
			cCD_DEPE  := "00"
		EndIf	

		cDT_INCL_UNI  := Dtos(BA1->BA1_DATINC)
		cDT_EXCL_UNI  := Dtos(BA1->BA1_DATBLO)
		cID_SIB       := IIf(BA1->BA1_INFSIB=="1","S","N") 
		cNR_PLA_PORT  := IIf(!Empty(BA1->BA1_PLPOR),PadR(BA1->BA1_PLPOR,20),nSpace20) 
		cBEN_COOP     := IIf(BA1->BA1_COOPER=="1","S","N")

		if cBEN_COOP == "S"
			areaBAU := BAU->(getarea())
			BAU->(dbsetorder(4))
			if BAU->(msseek(xfilial("BAU")+BA1->BA1_CPFUSR))
				cCRM := rtrim(BAU->BAU_CONREG)
				cUF_CRM := codUF(BAU->BAU_ESTCR)
			endif 
			BAU->(dbclosearea())
			restarea(areaBAU)
		endif 
		
		If lRemido .And. lUsaRemd   
			IF BA1->BA1_REMIDO == "1"
				cID_REMIDO:="S"
			Else	
				cID_REMIDO:="N"
			EndIf	
		Else	
			IIF(cCodPEA == BA1->BA1_CODEMP,cID_REMIDO:="S",cID_REMIDO:="N")     
		EndIf
		
		//Variaveis relacionadas ao registro R307 - Dados de Repasse 
		cDtVLRC := Dtos(BA1->BA1_DTVLCR)  
		If lExisPETag	     
			cDtValCarPE := ExecBlock( "PL1300TAG", .F., .F., {"dt_val_carteira",BA1->(Recno())} )
			If !Empty(cDtValCarPE)
				cDtVLRC := cDtValCarPE
			EndIF
		EndIf

		If (!Empty(BA1->BA1_OPEORI) .And. !Empty(BA1->BA1_OPEDES)) .And. (BA1->BA1_OPEORI <> BA1->BA1_OPEDES)
			cCD_UNI_OR 	 := BA1->BA1_OPEORI
			cCD_UNI_DE 	 := BA1->BA1_OPEDES
			cDT_INI_RE 	 := IIf(cCodLay >= "1300E", nSpace8 ,Dtos(BA1->BA1_DATREP))
			cDT_FIM_RE 	 := nSpace8 
			CD_UNI_DES 	 := SubStr(BA1->BA1_MATANT,1,4)
			ID_BENEF_DES := SubStr(BA1->BA1_MATANT,5,13)   
			cDT_VAL_CAR  :=  cDtVLRC
			cVIA_CARTAO  := Strzero(BA1->BA1_VIACAR,2)		
			If lExisPETag	     
				cVIA_CARPE := ExecBlock( "PL1300TAG", .F., .F., {"cVIA_CARTAO",BA1->(Recno())} )
				If !Empty(cVIA_CARPE)
					cVIA_CARTAO := cVIA_CARPE
				EndIF
			EndIf
			If BI3->(DbSeek(xFilBI3+cChvProduto))   
				If Alltrim(BI3->BI3_MODPAG) == "1"
					cTP_REPASS := "P"
				Else
					cTP_REPASS := "C"
				EndIf	
			Else
				cTP_REPASS := nSpace1
			EndIf 
			lUsuRepass := .T.
			Aadd(aRepasse,{"","R307",cCD_UNI_OR,cCD_UNI_DE,cTP_REPASS,cDT_INI_RE,cDT_FIM_RE,CD_UNI_DES,ID_BENEF_DES,cVIA_CARTAO,cDT_VAL_CAR,cDT_RISCO})  
		EndIf                 
		
		//Campos de Repasse em Pos - Versao 10
		If lExistB5F .And. cCodLay >= "A1300D"							
			B5F->(DbSetOrder(3))//B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO
			If B5F->(MsSeek(xFilB5F+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1->BA1_DIGITO)))
				While B5F->(B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO) == xFilB5F+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1->BA1_DIGITO) .And. !B5F->(Eof())
					If B5F->B5F_OPEHAB <> cCodInt .And. B5F->B5F_OPEORI == cCodInt .And. B5F->B5F_STATUS == "3"
						lUsuRepass := .T.    
						
						cTP_REPASS   := "C"	
						cCD_UNI_OR   := B5F->B5F_OPEORI  
						cCD_UNI_DE   := B5F->B5F_OPEHAB 
						cDT_INI_RE   := Dtos(B5F->B5F_VIGINI)  
						cDT_RISCO    := Dtos(B5F->B5F_VIGINI) 					 
						cDT_FIM_RE   := Dtos(B5F->B5F_VIGFIM)
						CD_UNI_DES   := Substr(B5F->B5F_MATHAB,1,4)
						ID_BENEF_DES := Substr(B5F->B5F_MATHAB,5,13)
						cDT_VAL_CAR  := cDtVLRC
						cVIA_CARTAO  := Strzero(BA1->BA1_VIACAR,2)
						If lExisPETag	     
							cVIA_CARPE := ExecBlock( "PL1300TAG", .F., .F., {"cVIA_CARTAO",BA1->(Recno())} )
							If !Empty(cVIA_CARPE)
								cVIA_CARTAO := cVIA_CARPE
							EndIF
						EndIf
						Aadd(aRepasse,{"","R307",cCD_UNI_OR,cCD_UNI_DE,cTP_REPASS,cDT_INI_RE,cDT_FIM_RE,CD_UNI_DES,ID_BENEF_DES,cVIA_CARTAO,cDT_VAL_CAR,cDT_RISCO})					
					EndIf
					B5F->(DbSkip())
				EndDo
			EndIf	
		EndIf 
		
		//Variaveis relacionadas ao registro R308 - Dados do Plano                    
		If BG9->(DbSeek(xFilBG9+BA1->(BA1_CODINT+BA1_CODEMP)))
			cNM_CONTR := Substr(BG9->BG9_DESCRI,1,40)
			// Ponto de Entrada para Tag (nm_contr)
			If lExisPETag	     
				cNmContr := ExecBlock( "PL1300TAG", .F., .F., {"nm_contr",BA1->(Recno())} )
				If !Empty(cNmContr)
					cNM_CONTR := Substr(cNmContr,1,40)
				EndIF
			EndIf
		Else
			cNM_CONTR := nSpace40
		EndIf  

		If Empty(BA1->BA1_CODPLA)
			If BA3->(DbSeek(xFilBA3+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				cChvProduto := Alltrim(BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO))
			EndIf
		Else
			cChvProduto := Alltrim(BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO))
		EndIf
		
		If BI3->(DbSeek(xFilBI3+cChvProduto)) 
		
			//Vou definir o usuario na contagem de beneficiarios
			Contagem(cAno,cMes,@nPF_CO_LOC,@nPF_PP_LOC,@nPJ_CO_LOC,@nPJ_PP_LOC,@nPF_REP_CO,@nPF_REP_PP,@nPJ_REP_CO,@nPJ_REP_PP,@nPF_REC_CO,@nPF_REC_PP,@nPJ_REC_CO,@nPJ_REC_PP)   
			
			aR308For := {}
			If BIL->(DbSeek(xFilBIL+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
				aR308For := RetBIL(aR308For,cDT_INIVIG,cDT_FIMVIG)
			Else
				cDT_INIVIG := nSpace8
				cDT_FIMVIG := nSpace8
				aAdd(aR308For,{BI3->(BI3_CODINT+BI3_CODIGO),BI3->BI3_VERSAO,cDT_INIVIG,cDT_FIMVIG}) 
			EndIf	                             
			
			If BF7->(DbSeek(xFilBF7+BI3->BI3_ABRANG))
				cTP_ABRANG := BF7->BF7_CODEDI	
			Else
				cTP_ABRANG := "0"
			EndIf 
			
		
			Do Case
				Case BI3->BI3_CLAPLS == "1" //Individual
					cTP_NATURE := "2"
				Case BI3->BI3_CLAPLS == "2" //Coletivo Empresarial
					cTP_NATURE := "3"
				Case BI3->BI3_CLAPLS == "3" //Coletivo por Adesao
					cTP_NATURE := "4"	
				Otherwise
					cTP_NATURE := "0"
			EndCase	

			
			If BI4->(DbSeek(xFilBI4+BI3->BI3_CODACO))
				Do Case
					Case BI4->BI4_CODEDI == "1"//Apartamento(Individual)
						cTP_ACOMOD := Padr("B",2)
					Case BI4->BI4_CODEDI == "2"//Enfermaria(Coletiva) 
						cTP_ACOMOD := Padr("A",2)   
					Case BI4->BI4_CODEDI $ "3/4"//Não se aplica ou Ambulatorial
						cTP_ACOMOD := Padr("C",2)
					Case !Empty(BI4->BI4_CODEDI)
						cTP_ACOMOD := Padr(BI4->BI4_CODEDI,2)
					Otherwise
						cTP_ACOMOD := nSpace2
				EndCase
			Else
				cTP_ACOMOD := nSpace2
			EndIf

			If lExisPETag
				cTP_ACOMPE := ExecBlock( "PL1300TAG", .F., .F., {"TP_ACOMOD",BA1->(Recno())} )
				If !Empty(cTP_ACOMPE)
					cTP_ACOMOD := cTP_ACOMPE
				EndIf
			EndIf
			
			Do Case
				Case BI3->BI3_APOSRG == "0" //Plano nao regulamentado
					cID_REG_PL := "2"
				Case BI3->BI3_APOSRG == "1" //Plano regulamentado
					cID_REG_PL := "1" 	  
				Case BI3->BI3_APOSRG == "2" //Plano adaptado
					cID_REG_PL := "3" 	  
				Otherwise
					cID_REG_PL := "0" 	
			EndCase	 
			
			If BI3->BI3_APOSRG == "1" // Regulamentado 
				cREG_PLANO := Padr(BI3->BI3_SUSEP,20)
			ElseIf BI3->BI3_APOSRG $ "0/2" // Não regulamentado ou Adaptado
				cREG_PLANO := Padr(BI3->BI3_SCPA,20) 
			EndIf
			
			If BI6->(DbSeek(xFilBI6+BI3->BI3_CODSEG))
				cSEG_PLANO := Strzero(Val(BI6->BI6_CODEDI),2)	
			Else
				cSEG_PLANO := "00"	
			EndIf  
			
			//Por algum motivo o Inicializador Padrão do campo BI3_REDREF está como 1 na base dos clientes.
			If !Empty(BI3->BI3_REDREF) .And. !(AllTrim(BI3->BI3_REDREF) == "1")
				cCD_REDE := BI3->BI3_REDREF  
			Else
				cCD_REDE := Substr(BI3->BI3_REDEDI,1,4) 
			EndIf
			
			cNM_REDE := Substr(BI3->BI3_RRFDES,1,40)
		
			cVIA_CARTAO := Strzero(BA1->BA1_VIACAR,2)
			cDT_VAL_CAR := cDtVLRC       
			cTP_CONTRAT := IIf(Alltrim(BI3->BI3_MODPAG) == "1","1","2")  
			If lExisPETag	     
				cVIA_CARPE := ExecBlock( "PL1300TAG", .F., .F., {"cVIA_CARTAO",BA1->(Recno())} )
				If !Empty(cVIA_CARPE)
					cVIA_CARTAO := cVIA_CARPE
				EndIF
			EndIf
			If !Empty(BA1->BA1_MOTBLO)
				Do Case
					Case BA1->BA1_CONSID == "U"
						If BG3->(DbSeek(xFilBG3+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BG3->BG3_CODEDI
						EndIf 
					Case BA1->BA1_CONSID == "F"	
						If BG1->(DbSeek(xFilBG1+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BG1->BG1_CODEDI
						EndIf 
					Case BA1->BA1_CONSID == "S"	
						If BQU->(DbSeek(xFilBQU+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BQU->BQU_CODEDI
						EndIf 	
					Otherwise
						cMOTIVO_EXC := "00"
				EndCase
				
				cR16_CDUNI := BA1->BA1_CODINT
				cR16_MATRI := BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
				cR16_DTEXC := Dtos(BA1->BA1_DATBLO)
			Else
				cMOTIVO_EXC := "00"
			EndIf   
					
			cDT_FIM_CPT  := CHKCPT()        
			If !Empty(BA1->BA1_DATCPT) .Or. !Empty(cDT_FIM_CPT)
				cID_CPT      := "S"					
				If Empty(cDT_FIM_CPT)
					cDT_FIM_CPT:= dTos(BA1->BA1_DATCPT)
				EndIf
			Else
				cID_CPT      := "N"
				cDT_FIM_CPT  := nSpace8
			EndIf
			
			cCD_LCAT 	:= Strzero(Val(BI3->BI3_LATEDI),4)
			
			If lBI3TipR  
				cTP_REDE	:= PadR(BI3->BI3_TIPRED,1)
			EndIf
			
			If Empty(BQC->BQC_SEASPL) .or. (Substr(BQC->BQC_SEASPL,1,1) == "N" .AND. LEN(Alltrim(BQC->BQC_SEASPL)) == 1)//Alterado para garantir o funcionamento anterior.
				cNM_ADM_BEN	 := nSpace40
				cCNPJADM_BEN := sStrZ15
				cRAZ_SOC_ADM_BENEF := nSpace40
			Else
				cNM_ADM_BEN	 := left(BQC->BQC_SEASPL,40)				
				cCNPJADM_BEN := IIf(lCnpjAdm,StrZero(Val(BQC->BQC_CNPADM),15),sStrZ15)
				cRAZ_SOC_ADM_BENEF := IIf(!Empty(cCNPJADM_BEN),Left(BQC->BQC_RAZSBE,40),nSpace40)
			EndIf

			cNM_PRODUTO := Substr(BI3->BI3_DESCRI,1,60)    

			If lExisPETag	     
				cNmPRODPE := ExecBlock( "PL1300TAG", .F., .F., {"NM_PRODUTO",BA1->(Recno())} )
				If !Empty(cNmPRODPE)
					cNM_PRODUTO := cNmPRODPE
				EndIF
			EndIf   
			
			if BQC->(msSeek(xFilBQC+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				//cRAZ_SOC_ADM_BENEF 	:= left(BQC->BQC_RAZSBE,40)
				cNR_CONTRATO 		:= Padr(BQC->(BQC_NUMCON+BQC_VERCON),15)
				cDT_CONTR_PLANO		:= dtos(BQC->BQC_DATCON)
			else
				cRAZ_SOC_ADM_BENEF 	:= nSpace40
				cNR_CONTRATO 		:= padr(BA1->(BA1_CODINT+BA1_CODEMP),15)
				cDT_CONTR_PLANO		:= dtos(BA1->BA1_DATINC)
			endIf	 
		
		EndIf   
		
		aVetAbrang := {}
		For nFor := 1 To Len(aR308For)
			//Variaveis relacionadas ao registro R309 - Abrangencia
			cChvR308 := aR308For[nFor][01]+aR308For[nFor][02]
			If BI3->(DbSeek(xFilBI3+cChvR308)) .And. !Empty(BI3->BI3_ABRANG) 
		
				If BF7->(DbSeek(xFilBF7+BI3->BI3_ABRANG))
					If lPL1300ABRA // P.E - Faz o tratamento para o grupo do município e o grupo de estados (Caso o cliente utilize outras tabelas)						     
						aAbrangPE := ExecBlock( "PL1300ABRA", .F., .F., {BF7->BF7_CODEDI,BF7->BF7_CODORI,BA1->(Recno()),BI3->(Recno())} )
						If Len(aAbrangPE) > 0
							For nNx := 1 To Len(aAbrangPE)
								Aadd(aVetAbrang,{cChvR308,;
												IIF(!Empty(aAbrangPE[nNx][1]),aAbrangPE[nNx][1],nSpace2),; // Estado
												IIF(!Empty(aAbrangPE[nNx][2]),Strzero(Val(Alltrim(aAbrangPE[nNx][2])),7),nReplic7)}) // Município
							Next nNx
						EndIF							
					Else
						If BF7->BF7_CODEDI == "4"//Regional B - Grupo de Municípios
							If B9B->(DbSeek(xFilB9B+BF7->BF7_CODORI))
								While xFilB9B+BF7->BF7_CODORI  == xFilB9B+B9B->B9B_CODORI .And. !B9B->(Eof())
									Aadd(aVetAbrang,{cChvR308,nSpace2,Strzero(Val(Alltrim(B9B->B9B_CODMUN)),7)})
									B9B->(DbSkip())
								EndDo
							EndIf
						ElseIf BF7->BF7_CODEDI == "2" //Regional A - Grupo de Estados 	  
							If B9C->(DbSeek(xFilB9C+BF7->BF7_CODORI))
								While xFilB9C+BF7->BF7_CODORI  == xFilB9C+B9C->B9C_CODORI .And. !B9C->(Eof())
									Aadd(aVetAbrang,{cChvR308,B9C->B9C_ESTADO,nReplic7})
									B9C->(DbSkip())
								EndDo
							EndIf
						EndIf
					EndIf	
					
				EndIf
			EndIf
		Next nFor
		
		//Variaveis relacionadas ao registro R310 - Carencias Beneficiarios                    
		aVetCarenc := {}
		aRetCarenc := PLSCLACAR(BA1->BA1_CODINT,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),/*dDataBase*/)
		
		If Len(aRetCarenc) > 0 .And. aRetCarenc[1]
			For nCont := 1 to len(aRetCarenc[2])
				If Len(aRetCarenc[2][nCont]) > 7 .And. !aRetCarenc[2][nCont][5] 
					If !Empty(aRetCarenc[2][nCont][8])
						nPosCar := aScan(aVetCarenc,{|x| AllTrim(x[1]) == aRetCarenc[2][nCont][8]}) 
						If nPosCar > 0 
							If DtoS(aRetCarenc[2][nCont][3]) > aVetCarenc[nPosCar][2] 
								aVetCarenc[nPosCar][2] := DtoS(aRetCarenc[2][nCont][3])
							EndIf
						Else
							Aadd(aVetCarenc,{aRetCarenc[2][nCont][8],Dtos(aRetCarenc[2][nCont][3]), BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)})
						EndIf
					Endif	
				Endif	
			Next    
		Endif
		
		//Gravacao dos registros no arquivo temporario 		
		//Grava R302 do arquivo temporario...
		If BA3->(DbSeek(xFilBA3+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))) .AND. BA3->BA3_TIPOUS <> '1'						                 
			cGeraRCP := '0'
		EndIf
		
		cTipReg := "I"
		if ! empty(cR16_CDUNI)
			cTipReg := "E"
		elseif BA1->BA1_DATINC >= dDataIni .and. BA1->BA1_DATINC <= dDataFim
			cTipReg := 'I'
		else
			nQuant := 0
			cQuery := " SELECT COUNT(*) CONTADOR "
			cQuery += " FROM " + retsqlname("BX1") + " "
			cQuery += " WHERE BX1_FILIAL = '" + xfilial("BX1") + "' "
			cQuery += " 	AND BX1_ALIAS = 'BA1' "
			cQuery += " 	AND BX1_RECNO = '" + strzero(TRBBA1->RECBA1, 10) + "' "
			cQuery += "		AND BX1_TIPO = 'A' "
			cQuery += " 	AND BX1_DATA >= '" + dtos(dDataIni) + "' "
			cQuery += " 	AND BX1_DATA <= '" + dtos(dDataFim) + "' "
			cQuery += " 	AND D_E_L_E_T_ = ' ' "

			nQuant := MPSysExecScalar(cQuery, "CONTADOR")

			If nQuant > 0
				cTipReg := "A"
			EndIf
			
			If cTipReg <> "A"
				Do Case
					Case CheckMovBenef("BED", BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG, BA1->BA1_DIGITO, dDataIni, dDataFim)
						cTipReg := "A"
					Case CheckMovBenef("BCA", BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG, BA1->BA1_DIGITO, dDataIni, dDataFim)
						cTipReg := "A"
				EndCase
			EndIf
		endif

		if !lContUtlzd
			if (lPF .and. val(cR2_CEI) != 0) .or. !lPF
				T302->(reclock("T302",.t.))
					T302->CHAVE 	 := cChaCON
					T302->TIPO 		 := cTipReg
					T302->CD_CPNJ 	 := right(cR2_CPNJ, 14)
					T302->CD_CAEPF 	 := iif(empty(cR2_CEI) .OR. cR2_CEI == replicate("0", 14), ' ', cR2_CEI)
					T302->CD_INS_EST := iif(val(cCD_INSC_EST) = 0, ' ', cCD_INSC_EST)
					T302->NM_EMP_COM := RemovChar(cNM_EMPR_COMP)
					T302->NM_FAN_EMP := RemovChar(cNM_FANTASIA_EMPR)
					T302->NM_EMP_ABR := RemovChar(cNM_EMPR_ABRE)
				T302->(msunlock())

				If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T302", T302->(Recno()), BA1->(Recno())})
				EndIf

				somaTpReg(cTipReg, '302')
			endif 
			
			If cGeraRCP == '0'
				nReg302++
			EndIf
		endIf

		If BA0->(dbSeek(xFilBA0 + cUniOri))

			If lAutGes .And. BQC->BQC_AUTGES == '1'
				lAutoGestao := .T.
			Else
				If BA0->BA0_AUTGES == '1'
					lAutoGestao := .T.
				EndIf
			EndIf

		EndIf
		
		If !lVidaUtlzd .and. !lAutoGestao
			T303->(reclock("T303", .t.))
				T303->CHAVE 	:= cChaCON+cChaBA1
				T303->TIPO 		:= cTipReg
				T303->NM_COM_BEN:= RemovChar(padR(cNM_COMPL,70))
				T303->NM_SOCIAL := RemovChar(padR(cNM_SOCIAL,70))
				T303->DT_NASC 	:= cDT_NASC
				T303->TP_SEXO 	:= cTP_SEXO
				T303->GEN_SOCIAL:= cTP_SEXO
				T303->CD_CPF 	:= iif(val(cCD_CPF) = 0, '', right(cCD_CPF, 11))
				T303->ID_ESTRANG:= PadR(cID_ESTRANG,1)
				T303->CD_IDENT 	:= cCD_IDENT
				T303->ORGAO_EMIS:= cORGAO_EMI
				T303->CD_UF 	:= codUF(cCD_PAIS)
				T303->CD_PAIS 	:= cCD_PAIS
				T303->CD_CNS 	:= cCD_CNS
				T303->CD_EST_CIV:= cCD_ECIVIL
				T303->NM_MAE 	:= cNM_MAE
				T303->PIS_PASEP := iif(cPIS_PASEP == replicate("0", 11), '', cPIS_PASEP)
				T303->CD_MUNINAT:= cCD_MUNIC
				T303->CD_MUNIC 	:= cCD_MUNIC
			T303->(msunlock())

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T303", T303->(Recno()), BA1->(Recno())})
			EndIf

			somaTpReg(cTipReg, '303')			
		EndIf

		If !lVidaUtlzd			
			T305->(reclock("T305",.t.))
				T305->CHAVE 	:= cChaCON+cChaBA1
				T305->IND_RESID := cIND_RESID
				T305->TP_END 	:= RemovChar(cTP_END)
				T305->TP_LOGRAD := iif(val(cTP_LOGRADOURO) = 0, getnewpar("MV_TLOGPTU",' '), cTP_LOGRADOURO)
				T305->DS_LOGRAD := RemovChar(cDS_LOGRAD)
				T305->NR_LOGRAD := alltrim(cNR_LOGRAD)
				T305->COMP_LOGRD:= RemovChar(cCOMPL_LOGRAD)
				T305->DS_BAIRRO := RemovChar(cDS_BAIRRO)
				T305->CD_MUNIC 	:= cCD_MUNIC
				T305->NR_CEP 	:= cNR_CEP
			T305->(msunlock())	

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T305", T305->(Recno()), BA1->(Recno())})
			EndIf
		EndIf

		If !lVidaUtlzd .and. lGeraR311			
			T311->(reclock("T311",.t.))
				T311->CHAVE 	:= cChaCON+cChaBA1
				T311->TP_FONE 	:= cTP_FONE
				T311->NR_DDD 	:= cNR_DDD
				T311->NR_FONE 	:= cNR_FONE
				T311->TP_EMAIL 	:= cTIP_EMAIL
				T311->END_EMAIL	:= cEND_EMAIL
			T311->(msunlock())

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T311", T311->(Recno()), BA1->(Recno())})
			EndIf			

			nReg311++  	
		EndIf

		If !lVidaUtlzd			 
			T306->(reclock("T306",.t.))
				T306->CHAVE 		:= cChaCON+cChaBA1
				T306->CD_UNIMED 	:= cCD_UNI
				T306->ID_BENEF 		:= cID_BENEF
				T306->NM_BENEF 		:= RemovChar(PadR(cNM_BENEF,25))
				T306->NM_SOCCART 	:= RemovChar(PadR(cNM_SOCIAL,25))
				T306->CD_DEPE 		:= cCD_DEPE
				T306->ID_BENEFTI 	:= cIDBENEFTIT
				T306->DT_INC_UNI 	:= cDT_INCL_UNI
				T306->DT_EXC_UNI 	:= ' '
				T306->ID_SIB 		:= cID_SIB
				T306->NR_PLA_POR 	:= cNR_PLA_PORT
				T306->ID_REMIDO 	:= cID_REMIDO
				T306->ID_BENECOP 	:= cBEN_COOP
				T306->CD_CRM 		:= cCRM 
				T306->CD_UFCONSE 	:= cUF_CRM
				T306->CD_CNPJ 		:= IIF(cR2_CPNJ != replicate("0", 15),right(cR2_CPNJ, 14),' ')
				T306->CD_CAEPF 		:= IIF(Empty(cR2_CEI) .OR. cR2_CEI == replicate("0", 14) , ' ', cR2_CEI)
			T306->(msunlock())
			
			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T306", T306->(Recno()), BA1->(Recno())})
			EndIf

		Endif
		
		//Grava R307 do arquivo temporario...						                 
		If lUsuRepass .And. len(aRepasse) > 0   
			For nCont := 1 to len(aRepasse)				
				if lGeraR307
					T307->(reclock("T307",.t.))
					T307->CHAVE := cChaCON+cChaBA1
					T307->CD_UNI_DES := aRepasse[nCont][4]
					T307->CD_UNI_ORI := aRepasse[nCont][3]
					T307->TP_COM_RIS := aRepasse[nCont][5]
					T307->DT_COM_RIS := aRepasse[nCont][6]
					T307->DTFIMCOMRI := aRepasse[nCont][7]
					T307->CDUNIDESCO := aRepasse[nCont][8]
					T307->ID_BENEDES := aRepasse[nCont][9]
					T307->VIA_CARTAO := iif(val(aRepasse[nCont][10]) = 0, '', aRepasse[nCont][10])
					T307->DT_VALCART := aRepasse[nCont][11]
					T307->(msunlock())
				endif	

				If ExistBlock("PL1300XML")
					ExecBlock("PL1300XML", .F., .F.,{"T307", T307->(Recno()), BA1->(Recno())})
				EndIf

				nReg307++ 
			Next
		EndIf

		For nFor := 1 To Len(aR308For)
			cDT_INIVIG := IIF (nFor == 1, cDT_INCL_UNI, aR308For[nFor][03]) // O primeiro sempre sera o "Data de inclusao na Unimed."
			cDT_FIMVIG := aR308For[nFor][04]
			//Se for o ultimo registro de aR308For, trato a "Data de fim de vigência" com a data de bloqueio quando houver.
			If nFor == Len(aR308For) .AND. !Empty(cDT_EXCL_UNI)
				cDT_FIMVIG := cDT_EXCL_UNI
			EndIf			
			
			T308->(reclock("T308",.t.))
			T308->CHAVE := cChaCON+cChaBA1 // +aR308For[nFor][01]+aR308For[nFor][02]
			T308->CHAVE_FULL := cChaCON+cChaBA1+aR308For[nFor][01]+aR308For[nFor][02]
			T308->NM_CONTR := RemovChar(cNM_CONTR)
			T308->DT_INI_VIG := cDT_INIVIG
			T308->DT_FIM_VIG := '' //cDT_FIMVIG
			T308->TP_ABRANGE := cTP_ABRANG
			T308->TPCONTRATA := cTP_NATURE
			T308->TP_ACOMODA := PadR(cTP_ACOMOD,1)
			T308->IDREGPLANS := cID_REG_PL
			T308->REGPLA_ANS := cREG_PLANO
			T308->SEG_PLANO := cSEG_PLANO
			T308->CD_REDE := cCD_REDE
			T308->NM_REDE := cNM_REDE
			T308->VIA_CARTAO := iif(val(cVIA_CARTAO) = 0, '', cVIA_CARTAO)
			T308->DT_VALCART := cDT_VAL_CAR
			T308->CD_LCAT := cCD_LCAT
			T308->ID_CPT := cID_CPT
			T308->DT_FIM_CPT := cDT_FIM_CPT
			T308->TP_CONTRAT := IIF(cTP_CONTRAT == "1","P","C")
			T308->CNPJADMBEN := cCNPJADM_BEN
			T308->RZSOCADMBE := RemovChar(cRAZ_SOC_ADM_BENEF)
			T308->NMADMBENEF := cNM_ADM_BEN
			T308->NM_PRODUTO := cNM_PRODUTO
			T308->NR_CONTRAT := cNR_CONTRATO
			T308->DTCONTRPLA := cDT_CONTR_PLANO
			T308->TP_REDEMIN := StrZero(Val(cTP_REDE),1)
			T308->(msunlock()) 			

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T308", T308->(Recno()), BA1->(Recno())})
			EndIf

		Next nFor
		
		//Grava R309 do arquivo temporario...						                 
		If len(aVetAbrang) > 0
			For nCont := 1 to len(aVetAbrang)				
				T309->(reclock("T309",.t.))
				T309->CHAVE := cChaCON+cChaBA1+aVetAbrang[nCont][1]+cID_BENEF
				T309->CD_MUNIC := iif(val(aVetAbrang[nCont][3])>0, aVetAbrang[nCont][3], '')
				T309->CD_UF := codUF(aVetAbrang[nCont][2])
				T309->(msunlock())

				If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T309", T309->(Recno()), BA1->(Recno())})
				EndIf 
			Next   
		Endif
		
		//Grava R310 do arquivo temporario...						                 
		If len(aVetCarenc) > 0 
			For nCont := 1 to len(aVetCarenc)				
				T310->(reclock("T310",.t.))
				T310->CHAVE := cChaCON+cChaBA1+aVetCarenc[nCont][3]
				T310->TP_COBERTU := aVetCarenc[nCont][1]
				T310->DT_FIMCARE := aVetCarenc[nCont][2]
				T310->(msunlock())

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T310", T310->(Recno()), BA1->(Recno())})
			EndIf
			Next
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava R316 do arquivo temporario...						               	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
		If !Empty(cR16_CDUNI)			
			T316->(reclock("T316",.t.))
			T316->CD_UNIMED := cR16_CDUNI
			T316->ID_BENEF := cR16_MATRI
			T316->DT_EXC_UNI := cR16_DTEXC
			T316->MOT_EXCBEN := cMOTIVO_EXC
			T316->REG_PLAANS := cREG_PLANO
			T316->DT_FIM_VIG := cDT_FIMVIG
			T316->(msunlock())

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T316", T316->(Recno()), BA1->(Recno())})
			EndIf

			somaTpReg(cTipReg, '316')
			   
			nReg316 ++    	
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava R317 do arquivo temporario...						                 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
			If lAutoGestao
				cCD_CNPJ   	:= BA0->BA0_CGC
				cCD_AUT_GEST	:= BA0->BA0_SUSEP
				
				T317->(reclock("T317",.t.))
				T317->TIPO := cTipReg
				T317->CD_UNIMED := cCD_UNI
				T317->ID_BENEF := PadR(cID_BENEF,13)
				T317->NM_BENEF := PadR(cNM_COMPL,70)
				T317->DT_NASC := PadR(cDT_NASC,8)
				T317->TP_SEXO := PadR(cTP_SEXO,1)
				T317->CD_CNS := PadR(cCD_CNS,15)
				T317->CD_CNPJ := PadR(cCD_CNPJ,14)
				T317->CAUTGESANS := PadR(cCD_AUT_GEST,10)
				T317->CD_CPF := iif(val(cCD_CPF) = 0, '', right(cCD_CPF, 11))
				T317->DT_INCL := cDT_INCL_UNI
				T317->DT_EXCL := cDT_EXCL_UNI
				T317->(msunlock())

				If ExistBlock("PL1300XML")
					ExecBlock("PL1300XML", .F., .F.,{"T317", T317->(Recno()), BA1->(Recno())})
				EndIf

				somaTpReg(cTipReg, '317')
				
				nReg317 ++
			EndIf

		TRBBA1->(dbSkip())
	EndDo

	TRBBA1->(dbCloseArea())	

	//Gera arquivo fisico
	gerArq1300(lAuto)

	//Fecha arquivo temporario...	
	fechaXMLArea(@oTab301, @oTab302, @oTab303, @oTab305, @oTab306, @oTab307, @oTab308, @oTab309, @oTab310, @oTab311, @oTab316, @oTab317)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RemovChar
Faz a contagem dos beneficiarios

@author Renan Sakai
@since  06/05/15
@version P12
/*/
//-------------------------------------------------------------------
Static Function RemovChar(cText)
	cText := StrTran(cText,"-","")    		
	cText := StrTran(cText,"'","")
	cText := StrTran(cText,'"',"")
	cText := StrTran(cText,"!","")
	cText := StrTran(cText,"@","")  
	cText := StrTran(cText,"#","")
	cText := StrTran(cText,"$","")
	cText := StrTran(cText,"%","")
	cText := StrTran(cText,"¨","")
	cText := StrTran(cText,"*","")
	cText := StrTran(cText,"(","")
	cText := StrTran(cText,")","")
	cText := StrTran(cText,"_","")
	cText := StrTran(cText,"=","")
	cText := StrTran(cText,"+","")
	cText := StrTran(cText,"´","")
	cText := StrTran(cText,"`","")
	cText := StrTran(cText,"[","")
	cText := StrTran(cText,"]","")
	cText := StrTran(cText,"{","")
	cText := StrTran(cText,"}","")
	cText := StrTran(cText,",","")
	cText := StrTran(cText,".","")
	cText := StrTran(cText,";","")
	cText := StrTran(cText,":","")
	cText := StrTran(cText,"/","")
	cText := StrTran(cText,"\","")    		
	cText := StrTran(cText,"|","")
	cText := StrTran(cText,'?',"")
	cText := StrTran(cText,"~","")
	cText := StrTran(cText,"^","")
	cText := StrTran(cText,"&","")
Return fwcutoff(cText, .t.)            
 

//-------------------------------------------------------------------
/*/{Protheus.doc} Contagem
Faz a contagem dos beneficiarios

@author Microsiga
@since  06/05/15
@version P12
/*/
//-------------------------------------------------------------------
Static Function Contagem(cAno,cMes,nPF_CO_LOC,nPF_PP_LOC,nPJ_CO_LOC,nPJ_PP_LOC,nPF_REP_CO,nPF_REP_PP,nPJ_REP_CO,nPJ_REP_PP,nPF_REC_CO,nPF_REC_PP,nPJ_REC_CO,nPJ_REC_PP)   
	Local aPECont := {}
	Local aRet    := {}
	Local cCodInt := PlsIntPad()

	//Verifica ultimo dia do mes                                               
	If cMes $ "01-03-05-07-08-10-12"        
		dData := Ctod("31/"+cMes+"/"+cAno)
	ElseIf cMes $ "04-06-09-11"
		dData := Ctod("30/"+cMes+"/"+cAno)
	Else
		dData := Ctod("29/"+cMes+"/"+cAno)
	EndIf	   

	If BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		If lPEContag 
			aPECont := {nPF_CO_LOC,nPF_PP_LOC,nPJ_CO_LOC,nPJ_PP_LOC,nPF_REP_CO,nPF_REP_PP,nPJ_REP_CO,nPJ_REP_PP,nPF_REC_CO,nPF_REC_PP,nPJ_REC_CO,nPJ_REC_PP}
			
			aRet := ExecBlock( "PL1300CONT", .F., .F., {aPECont,BA1->(Recno())} ) 
			
			nPF_CO_LOC := aRet[1]
			nPF_PP_LOC := aRet[2]
			nPJ_CO_LOC := aRet[3]
			nPJ_PP_LOC := aRet[4]
			nPF_REP_CO := aRet[5]
			nPF_REP_PP := aRet[6]
			nPJ_REP_CO := aRet[7]
			nPJ_REP_PP := aRet[8]
			nPF_REC_CO := aRet[9]
			nPF_REC_PP := aRet[10]
			nPJ_REC_CO := aRet[11]
			nPJ_REC_PP := aRet[12]
		Else
			//Número de Beneficiários ativos Pessoa Física com contrato em Custo Operacional não repassado 
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. Empty(BA1->BA1_DATREP) .And. BA1->BA1_DATINC <= dData .And. ;  
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '1' .And. Alltrim(BI3->BI3_MODPAG) <> '1'
		
				nPF_CO_LOC ++  
			EndIf	
			
			//Número de Beneficiários ativos Pessoa Física com contrato em Pré Pagamento não repassado
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. Empty(BA1->BA1_DATREP) .And. BA1->BA1_DATINC <= dData .And. ;  
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '1' .And. Alltrim(BI3->BI3_MODPAG) == '1'
			
				nPF_PP_LOC ++   
			EndIf
			
			//Número de Beneficiários ativos Pessoa Jurídica com contrato em Custo Operacional não repassado
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. Empty(BA1->BA1_DATREP) .And. BA1->BA1_DATINC <= dData .And.;  
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '2' .And. Alltrim(BI3->BI3_MODPAG) <> '1'
				
				nPJ_CO_LOC ++    
			EndIf
			
			//Número de Beneficiários ativos Pessoa Jurídica com contrato em Pré Pagamento não repassado
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. Empty(BA1->BA1_DATREP) .And. BA1->BA1_DATINC <= dData .And.;  
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '2' .And. Alltrim(BI3->BI3_MODPAG) == '1'
				
				nPJ_PP_LOC ++  
			EndIf  
			
			//Número de Beneficiários ativos Pessoa Física repassados para outra Unimed em Custo Operacional
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES <> cCodInt .And. ;
				BA3->BA3_TIPOUS == '1' .And. Alltrim(BI3->BI3_MODPAG) <> '1' 
		
				nPF_REP_CO ++ 
			EndIf
			
			//Número de Beneficiários ativos Pessoa Física repassados para outra Unimed em Pré Pagamento
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES <> cCodInt .And. ;
				BA3->BA3_TIPOUS == '1' .And. Alltrim(BI3->BI3_MODPAG) == '1'
				
				nPF_REP_PP ++
			EndIf
			
			//Número de Beneficiários ativos Pessoa Jurídica repassados para outra Unimed em Custo Operacional
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES <> cCodInt .And. ;
				BA3->BA3_TIPOUS == '2' .And. Alltrim(BI3->BI3_MODPAG) <> '1'
				
				nPJ_REP_CO ++	
			EndIf
			
			//Número de Beneficiários ativos Pessoa Jurídica repassados para outra Unimed em Pré Pagamento
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI == cCodInt .And. BA1->BA1_OPEDES <> cCodInt .And. ;  
				BA3->BA3_TIPOUS = '2' .And. Alltrim(BI3->BI3_MODPAG) == '1'  
		
				nPJ_REP_PP ++ 
			Endif
			
			//Número de Beneficiários ativos Pessoa Física recebidos de outra Unimed em Custo Operacional
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI <> cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS = '1' .And. Alltrim(BI3->BI3_MODPAG) <> '1'
		
				nPF_REC_CO ++ 
			EndIf
			
			//Número de Beneficiários ativos Pessoa Física recebidos de outra Unimed em Pré Pagamento
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI <> cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '1' .And. Alltrim(BI3->BI3_MODPAG) == '1'
			
				nPF_REC_PP ++
			EndIf
			
			//Número de Beneficiários ativos Pessoa Jurídica recebidos de outra Unimed em Custo Operacional
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI <> cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;
				BA3->BA3_TIPOUS == '2' .And. Alltrim(BI3->BI3_MODPAG) <> '1'
		
				nPJ_REC_CO ++
			EndIf	  
			
			//Número de Beneficiários ativos Pessoa Jurídica recebidos de outra Unimed em Pré Pagamento 
			If Empty(BA3->BA3_MOTBLO) .And. Empty(BA1->BA1_MOTBLO) .And. BA1->BA1_DATREP <= dData .And. BA1->BA1_DATINC <= dData .And. ;
				BA1->BA1_OPEORI <> cCodInt .And. BA1->BA1_OPEDES == cCodInt .And. ;	
				BA3->BA3_TIPOUS == '2' .And. Alltrim(BI3->BI3_MODPAG) == '1
				
				nPJ_REC_PP ++		 
			EndIf 
		EndIf	   
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CHKCPT
Ajusta ASC
@author José Paulo de Azevedo
@since  03/02/2017
@version P12
 /*/
//-------------------------------------------------------------------
Function CHKCPT()
	LOCAL dDatCpt := ctod("  /  /  ")
	LOCAL dDatFim := ctod("  /  /  ")

	BF3->(dbSetOrder(1))
	BF3->(msSeek(xFilial("BF3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			
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
				If  Empty(BF3->BF3_DATCPT)
					If  Empty(BA1->BA1_DATCPT)
						nDias	:=	Abs(( date() -MonthSum( date() , 0 )))
						dDatCPt:= date()+nDias
					Else  											
						nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
						dDatFim := BA1->BA1_DATCPT + nDias
					EndIf
				Else
					nDias   := PLSCarDias(BF3->BF3_MESAGR,BF3->BF3_UNAGR)
					dDatFim := BF3->BF3_DATCPT + nDias
				Endif		
				
				If  dDatFim > dDatCpt
					dDatCpt := dDatFim
				Endif
			Endif
		Endif	
		BF3->(dbSkip())
	Enddo
Return (dtos(dDatCpt))   


//-------------------------------------------------------------------
/*/{Protheus.doc} AjusASC
Ajusta ASC
@author José Paulo de Azevedo
@since  03/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function AjusASC(cExp)
	cExp := StrTran(cExp," "," ") 
	cExp := StrTran(cExp,"­","-") 
Return(cExp)


//-------------------------------------------------------------------
/*/{Protheus.doc} geraR316
Gera arquivo somente de exclusao  

@author Renan Sakai
@since  15/05/2018
@version P11
/*/
//-------------------------------------------------------------------                                  
Static Function geraR316(cSql,lAuto)        
	Local cDescEmp    := Alltrim(GetNewPar("MV_PTDS130","")) 
	Local cChvProduto := ""   
	Local cR16_CDUNI  := ""
	Local cR16_MATRI  := ""
	Local cR16_DTEXC  := ""
	Local cDT_FIMVIG  := ""
	Local cMOTIVO_EXC := ""
	Local cRegPlaANS  := ""
	Local cR316       := ""
	Local nReg316     := 0
	Local aDatFonte   := {}
	Local nReplic7    := Replicate("0",7)
	Local nSpace8     := Space(8)
	Local nSpace3     := Space(3)
	Local cCodInt     := PlsIntPad()
	Local xFilBA1     := xFilial("BA1")
	Local xFilBA3     := xFilial("BA3")
	Local xFilBI3	  := xFilial("BI3")
	Local xFilBIL     := xFilial("BIL")
	Local xFilBG3     := xFilial("BG3")
	Local xFilBG1     := xFilial("BG1")
	Local xFilBQU     := xFilial("BQU")
	Local xFilBA0     := xFilial('BA0') 

	Default lAuto 	  := .F.

	//cSQL := ChangeQuery(cSQL)
	aDatFonte := GetAPOInfo("PLSUA1300.prw")
	PLSLOGFIL("Data do fonte PLSUA1300:"+dTos(aDatFonte[4]),"PTUA1300.LOG")   
	PLSLOGFIL("Hora do fonte PLSUA1300:"+aDatFonte[5],"PTUA1300.LOG")      
		
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBA1",.F.,.T.)
	BA1->(DbSetorder(2))

	While !TRBBA1->( EOF() )

		//BA1->(dbGoto(TRBBA1->RECBA1))   
		If BA1->( MsSeek( xFilBA1 + TRBBA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO )))  
		
			//Usuario de intercambio eventual nao entra                               
			If BA1->BA1_CODEMP $ Alltrim(cDescEmp) 
				TRBBA1->(DbSkip())
				Loop
			EndIf
			
			//Busca chave
			If Empty(BA1->BA1_CODPLA)
				If BA3->(DbSeek(xFilBA3+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
					cChvProduto := BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
				EndIf
			Else
				cChvProduto := BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
			EndIf
			
			//Busca vigencia do plano
			If BI3->(DbSeek(xFilBI3+cChvProduto))
				If BIL->(DbSeek(xFilBIL+BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
					cDT_FIMVIG := DtoS(BIL->BIL_DATFIN)
				Else
					cDT_FIMVIG := nSpace8
				EndIf

				If BI3->BI3_APOSRG == "1" // Regulamentado 
					cRegPlaANS := Padr(BI3->BI3_SUSEP,20)
				ElseIf BI3->BI3_APOSRG $ "0/2" // Não regulamentado ou Adaptado
					cRegPlaANS := Padr(BI3->BI3_SCPA,20) 
				EndIf
			EndIf			
			
			If Empty(cDT_FIMVIG)
				cDT_FIMVIG := Dtos(BA1->BA1_DATBLO)
			EndIf
			
			If !Empty(BA1->BA1_MOTBLO)
				Do Case
					Case BA1->BA1_CONSID == "U"
						If BG3->(DbSeek(xFilBG3+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BG3->BG3_CODEDI
						EndIf
					Case BA1->BA1_CONSID == "F"
						If BG1->(DbSeek(xFilBG1+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BG1->BG1_CODEDI
						EndIf
					Case BA1->BA1_CONSID == "S"
						If BQU->(DbSeek(xFilBQU+BA1->BA1_MOTBLO))
							cMOTIVO_EXC := BQU->BQU_CODEDI
						EndIf
					Otherwise
						cMOTIVO_EXC := "00"
				EndCase
				
				cR16_CDUNI := BA1->BA1_CODINT
				cR16_MATRI := BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
				cR16_DTEXC := Dtos(BA1->BA1_DATBLO)
			Else
				cMOTIVO_EXC := "00"
			EndIf       
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava R316 do arquivo temporario...						               	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			T316->(reclock("T316",.t.))
			T316->CD_UNIMED := cR16_CDUNI
			T316->ID_BENEF := cR16_MATRI
			T316->DT_EXC_UNI := cR16_DTEXC
			T316->MOT_EXCBEN := cMOTIVO_EXC
			T316->REG_PLAANS := cRegPlaANS
			T316->DT_FIM_VIG := cDT_FIMVIG
			T316->(msunlock()) 

			If ExistBlock("PL1300XML")
				ExecBlock("PL1300XML", .F., .F.,{"T316", T316->(Recno()), BA1->(Recno())})
			EndIf 
				
			somaTpReg("E", '316') // Soma mais um exclusão
			  	
		EndIf

		TRBBA1->( DbSkip() )  
	EndDo

	TRBBA1->(DbCloseArea())


	T316->(dbgotop())

	T301->(reclock("T301",.t.))
	T301->NRVTRA_PTU := '11'
	T301->CD_UNI_DES := cUniDes
	T301->CD_UNI_ORI := cUniOri
	T301->DT_GERACAO := dtos(ddatabase)
	T301->(msunlock())	

	If ExistBlock("PL1300XML")
		ExecBlock("PL1300XML", .F., .F.,{"T301", T301->(Recno()), 0})
	EndIf

	//Gera arquivo fisico
	gerArq1300(lAuto)  
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} gerArq1300

Gera arquivo fisico

@author Renan Sakai
@since  07/12/2016
@version P11
/*/
//-------------------------------------------------------------------    
Static Function gerArq1300(lAuto)
	Local cArqNom    := ""
	Local cContA1300 := ""
	Local nCont1300  := 0
	Local dDtGer     := Dtos(dDataBase)
	local nRetCont

	Default lAuto	 := .F.

	//Verifica o nome que o arquivo sera gerado   								
	cContA1300 := GetNewPar("MV_PT1300C","")     
	If Substr(cContA1300,1,8) == dDtGer
		nCont1300 := Val(Substr(cContA1300,9,1))  
		If nCont1300 == 9
			cContA1300 := dDtGer+"1"
		Else
			nCont1300 ++ 
			cContA1300 := dDtGer+cValToChar(nCont1300)
		EndIf	 
	Else
		cContA1300 := dDtGer+"1" 
	EndIf
	cArqNom := "CN"+Substr(dDtGer,7,2)+Substr(dDtGer,5,2)+Substr(dDtGer,3,2)+strzero(val(Substr(cContA1300,9,1)),4)+"."+Substr(cUniOri,2,3)


	T301->(reclock("T301",.t.))
	T301->NRVTRA_PTU := '18'
	T301->CD_UNI_DES := cUniDes
	T301->CD_UNI_ORI := cUniOri
	T301->DT_GERACAO := dDtGer
	T301->(msunlock())

	If ExistBlock("PL1300XML")
		ExecBlock("PL1300XML", .F., .F.,{"T301", T301->(Recno()), 0})
	EndIf

	cArqNom := "CN"+Substr(dDtGer,7,2)+Substr(dDtGer,5,2)+Substr(dDtGer,3,2)

	nRetCont := geraXML(cArqNom, val(Substr(cContA1300,9,1)),lAuto)
	cContA1300 := left(cContA1300, 8) + cvaltochar(nRetCont)	

	//Registra no parametro MV_PT1300C a numeracao utilizada 					
	If getMV("MV_PT1300C",.T.)
		putMV( "MV_PT1300C",cContA1300 )
	EndIf

Return


/*/{Protheus.doc} geraXML
Função realiza a geração do arquivo XML.

@type static function
@since 07/01/2020
@version 1.0

@param cArqNom, caracter, Nome do arquivo que será gerado.
@param nSeqIni, numerico, Numero sequencial para geracao.
/*/
static function geraXML(cArqNom, nSeqIni,lAuto)
	local aQtd := {T302->(lastrec()), T303->(lastrec()), T317->(lastrec())}
	local nQtd := nSeqIni, nX
	local cNames := "Arquivos gerados: " + CRLF + CRLF
	local aCriticas := {}

	Default lAuto := .F.

	T302->(dbgotop())
	T303->(dbgotop())
	T306->(dbgotop())
	T317->(dbgotop())

	asort(aQtd)

	if atail(aQtd) > _QTD_REG_
		nQtd := iif( mod(atail(aQtd), _QTD_REG_) != 0,  int(atail(aQtd)/_QTD_REG_)+1, int(atail(aQtd)/_QTD_REG_)  ) + nSeqIni - 1
	endif

	for nX := nSeqIni to nQtd
		oXML1300 := XMLA1300():new(nTpMov, PadR(cCodLay, 6), cDirNov, cArqNom + strzero(nX,4) )
		oXML1300:setDataFile(nX, nQtd, {{nQtdIEmp, nQtdIPes, nQtdIAut},{nQtdAEmp, nQtdAPes, nQtdAAut},nQtdExc})
		aadd(aCriticas, oXML1300:fileXML())
		
		cNames += cArqNom + strzero(nX,4) + "." + Substr(T301->CD_UNI_ORI,2,3) + CRLF
	next nX

	If !lAuto	
		for nX := 1 to len(aCriticas)
			if ! empty(aCriticas[nX])
				PLSCRIGEN(aCriticas[nX],{ {"Críticas encontradas no arquivo " + cArqNom + strzero((nX + nSeqIni) -1,4) + ":","@C",200} },"Não foi possível gerar o arquivo PTU " + cCodLay)
			endif 
		next nX

		msginfo(cNames)
	Else
		aCritAuto   := aClone(aCriticas) // Alimente Array da Automação (Private da Automação)
		lArqGerAuto := .T.               // Arquivo Gerado com sucesso! (Private da Automação)
	EndIf
return nQtd


//-------------------------------------------------------------------
/*/{Protheus.doc} RetBIL

Retorna os dados da tabela BIL
@author PLS TEAM
@since  08/05/2019
@version P12
/*/
//------------------------------------------------------------------- 
Static Function RetBIL(aR308For, cDT_INIVIG, cDT_FIMVIG)
	Local nSpace8 := Space(8)
	Local dDtAtu  := DToS(dDataBase)
	Local xFilBIL := xFilial("BIL")

	If nTpMov == 2 //M = Cadastro Completo
		// Guardo em aR308For as versões partindo da versão atual do produto até a ultima versão vigente
		While !BIL->(Eof()) .AND. xFilBIL+BI3->(BI3_CODINT+BI3_CODIGO) == xFilBIL+BIL->BIL_CODIGO
			If Empty(BIL->BIL_DATFIN) .OR. DToS(BIL->BIL_DATFIN) > dDtAtu 
				cDT_INIVIG := DtoS(BIL->BIL_DATINI)
				cDT_FIMVIG := nSpace8
				aAdd(aR308For,{BIL->BIL_CODIGO,BIL->BIL_VERSAO,cDT_INIVIG,cDT_FIMVIG})
				Exit // É a ultima versão vigente
			Else
				cDT_INIVIG := DtoS(BIL->BIL_DATINI)
				cDT_FIMVIG := DtoS(BIL->BIL_DATFIN)
				aAdd(aR308For,{BIL->BIL_CODIGO,BIL->BIL_VERSAO,cDT_INIVIG,cDT_FIMVIG})
			EndIf
			BIL->(DbSkip())
		EndDo
	Else
		cDT_INIVIG := DtoS(BIL->BIL_DATINI)
		cDT_FIMVIG := nSpace8
		aAdd(aR308For,{BIL->BIL_CODIGO,BIL->BIL_VERSAO,cDT_INIVIG,cDT_FIMVIG})
	EndIf

Return aR308For


/*/{Protheus.doc} criaXMLArea
Realiza a criação das areas de trabalho para os dados do XML.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oTab301, object, Objeto do layout 301.
@param oTab302, object, Objeto do layout 302.
@param oTab303, object, Objeto do layout 303.
@param oTab305, object, Objeto do layout 305.
@param oTab306, object, Objeto do layout 306.
@param oTab307, object, Objeto do layout 307.
@param oTab308, object, Objeto do layout 308.
@param oTab309, object, Objeto do layout 309.
@param oTab310, object, Objeto do layout 310.
@param oTab311, object, Objeto do layout 311.
@param oTab316, object, Objeto do layout 316.
@param oTab317, object, Objeto do layout 317.
/*/
static function criaXMLArea(oTab301, oTab302, oTab303, oTab305, oTab306, oTab307, oTab308, oTab309, oTab310, oTab311, oTab316, oTab317)
	local aStrR301 := {}
	local aStrR302 := {}           
    local aStrR303 := {}            
    local aStrR305 := {} 
    local aStrR306 := {} 
    local aStrR307 := {}  
    local aStrR308 := {}  
    local aStrR309 := {}   
    local aStrR310 := {}
	local aStrR311 := {}
	local aStrR316 := {}
	local aStrR317 := {}
	
	fechaXMLArea(@oTab301, @oTab302, @oTab303, @oTab305, @oTab306, @oTab307, @oTab308, @oTab309, @oTab310, @oTab311, @oTab316, @oTab317)

	aadd(aStrR301, {"NRVTRA_PTU","C",2,0})
	aadd(aStrR301, {"CD_UNI_DES","C",4,0})
	aadd(aStrR301, {"CD_UNI_ORI","C",4,0})
	aadd(aStrR301, {"DT_GERACAO","C",8,0})
	oTab301 := fwtemporarytable():new("T301")
	oTab301:setfields(aStrR301)
	oTab301:create()
	dbselectarea("T301")
	
	aadd(aStrR302, {"CHAVE","C",100,0})
	aadd(aStrR302, {"TIPO","C",1,0})
	aadd(aStrR302, {"CD_CPNJ","C",14,0})
	aadd(aStrR302, {"CD_CAEPF","C",14,0})
	aadd(aStrR302, {"CD_INS_EST","C",20,0})
	aadd(aStrR302, {"NM_EMP_COM","C",40,0})
	aadd(aStrR302, {"NM_FAN_EMP","C",40,0})
	aadd(aStrR302, {"NM_EMP_ABR","C",30,0})
	oTab302 := fwtemporarytable():new("T302")
	oTab302:setfields(aStrR302)
	oTab302:addindex("01",{"CHAVE"})
	oTab302:addindex("02",{"CD_CPNJ"})
	oTab302:create()
	dbselectarea("T302")

	aadd(aStrR303, {"CHAVE","C",100,0})
	aadd(aStrR303, {"TIPO","C",1,0})
	aadd(aStrR303, {"NM_COM_BEN","C",70,0})
	aadd(aStrR303, {"NM_SOCIAL","C",70,0})
	aadd(aStrR303, {"DT_NASC","C",8,0})
	aadd(aStrR303, {"TP_SEXO","C",1,0})
	aadd(aStrR303, {"GEN_SOCIAL","C",1,0})
	aadd(aStrR303, {"CD_CPF","C",11,0})
	aadd(aStrR303, {"ID_ESTRANG","C",1,0})
	aadd(aStrR303, {"CD_IDENT","C",15,0})
	aadd(aStrR303, {"ORGAO_EMIS","C",30,0})
	aadd(aStrR303, {"CD_UF","C",2,0})
	aadd(aStrR303, {"CD_PAIS","C",3,0})
	aadd(aStrR303, {"CD_CNS","C",15,0})
	aadd(aStrR303, {"CD_EST_CIV","C",1,0})
	aadd(aStrR303, {"NM_MAE","C",70,0})
	aadd(aStrR303, {"PIS_PASEP","C",11,0})
	aadd(aStrR303, {"CD_MUNINAT","C",7,0})
	aadd(aStrR303, {"CD_MUNIC","C",7,0})
	oTab303 := fwtemporarytable():new("T303")
	oTab303:setfields(aStrR303)
	oTab303:addindex("01",{"CHAVE"})
	oTab303:create()
	dbselectarea("T303")

	aadd(aStrR305, {"CHAVE","C",100,0})
	aadd(aStrR305, {"IND_RESID","C",1,0})
	aadd(aStrR305, {"TP_END","C",1,0})
	aadd(aStrR305, {"TP_LOGRAD","C",2,0})
	aadd(aStrR305, {"DS_LOGRAD","C",40,0})
	aadd(aStrR305, {"NR_LOGRAD","C",6,0})
	aadd(aStrR305, {"COMP_LOGRD","C",20,0})
	aadd(aStrR305, {"DS_BAIRRO","C",30,0})
	aadd(aStrR305, {"CD_MUNIC","C",7,0})
	aadd(aStrR305, {"NR_CEP","C",8,0})
	oTab305 := fwtemporarytable():new("T305")
	oTab305:setfields(aStrR305)
	oTab305:addindex("01",{"CHAVE"})
	oTab305:create()
	dbselectarea("T305")

	aadd(aStrR306, {"CHAVE","C",100,0})
	aadd(aStrR306, {"CD_UNIMED","C",4,0})
	aadd(aStrR306, {"ID_BENEF","C",13,0})
	aadd(aStrR306, {"NM_BENEF","C",25,0})
	aadd(aStrR306, {"NM_SOCCART","C",25,0})
	aadd(aStrR306, {"CD_DEPE","C",2,0})
	aadd(aStrR306, {"ID_BENEFTI","C",13,0})
	aadd(aStrR306, {"DT_INC_UNI","C",8,0})
	aadd(aStrR306, {"DT_EXC_UNI","C",8,0})
	aadd(aStrR306, {"ID_SIB","C",1,0})
	aadd(aStrR306, {"NR_PLA_POR","C",20,0})
	aadd(aStrR306, {"ID_REMIDO","C",1,0})
	aadd(aStrR306, {"ID_BENECOP","C",1,0})
	aadd(aStrR306, {"CD_CRM","C",15,0})
	aadd(aStrR306, {"CD_UFCONSE","C",2,0})
	aadd(aStrR306, {"CD_CNPJ","C",14,0})
	aadd(aStrR306, {"CD_CAEPF","C",14,0})
	oTab306 := fwtemporarytable():new("T306")
	oTab306:setfields(aStrR306)
	oTab306:addindex("01",{"CHAVE"})
	oTab306:create()
	dbselectarea("T306")

	aadd(aStrR307, {"CHAVE","C",100,0})
	aadd(aStrR307, {"CD_UNI_DES","C",4,0})
	aadd(aStrR307, {"CD_UNI_ORI","C",4,0})
	aadd(aStrR307, {"TP_COM_RIS","C",1,0})
	aadd(aStrR307, {"DT_COM_RIS","C",8,0})
	aadd(aStrR307, {"DTFIMCOMRI","C",8,0})
	aadd(aStrR307, {"CDUNIDESCO","C",4,0})
	aadd(aStrR307, {"ID_BENEDES","C",13,0})
	aadd(aStrR307, {"VIA_CARTAO","C",2,0})
	aadd(aStrR307, {"DT_VALCART","C",8,0})
	oTab307 := fwtemporarytable():new("T307")
	oTab307:setfields(aStrR307)
	oTab307:addindex("01",{"CHAVE"})
	oTab307:create()
	dbselectarea("T307")

	aadd(aStrR308, {"CHAVE","C",100,0})
	aadd(aStrR308, {"CHAVE_FULL","C",100,0})
	aadd(aStrR308, {"NM_CONTR","C",40,0})
	aadd(aStrR308, {"DT_INI_VIG","C",8,0})
	aadd(aStrR308, {"DT_FIM_VIG","C",8,0})
	aadd(aStrR308, {"TP_ABRANGE","C",1,0})
	aadd(aStrR308, {"TPCONTRATA","C",1,0})
	aadd(aStrR308, {"TP_ACOMODA","C",1,0})
	aadd(aStrR308, {"IDREGPLANS","C",1,0})
	aadd(aStrR308, {"REGPLA_ANS","C",20,0})
	aadd(aStrR308, {"SEG_PLANO","C",2,0})
	aadd(aStrR308, {"CD_REDE","C",4,0})
	aadd(aStrR308, {"NM_REDE","C",40,0})
	aadd(aStrR308, {"VIA_CARTAO","C",2,0})
	aadd(aStrR308, {"DT_VALCART","C",8,0})
	aadd(aStrR308, {"CD_LCAT","C",4,0})
	aadd(aStrR308, {"ID_CPT","C",1,0})
	aadd(aStrR308, {"DT_FIM_CPT","C",8,0})
	aadd(aStrR308, {"TP_CONTRAT","C",1,0})
	aadd(aStrR308, {"CNPJADMBEN","C",15,0})
	aadd(aStrR308, {"RZSOCADMBE","C",40,0})
	aadd(aStrR308, {"NMADMBENEF","C",40,0})
	aadd(aStrR308, {"NM_PRODUTO","C",60,0})
	aadd(aStrR308, {"NR_CONTRAT","C",15,0})
	aadd(aStrR308, {"DTCONTRPLA","C",8,0})
	aadd(aStrR308, {"TP_REDEMIN","C",1,0})
	oTab308 := fwtemporarytable():new("T308")
	oTab308:setfields(aStrR308)
	oTab308:addindex("01",{"CHAVE"})
	oTab308:create()
	dbselectarea("T308")

	aadd(aStrR309, {"CHAVE","C",100,0})
	aadd(aStrR309, {"CD_MUNIC","C",7,0})
	aadd(aStrR309, {"CD_UF","C",2,0})
	oTab309 := fwtemporarytable():new("T309")
	oTab309:setfields(aStrR309)
	oTab309:addindex("01",{"CHAVE"})
	oTab309:create()
	dbselectarea("T309")

	aadd(aStrR310, {"CHAVE","C",100,0})
	aadd(aStrR310, {"TP_COBERTU","C",3,0})
	aadd(aStrR310, {"DT_FIMCARE","C",8,0})
	oTab310 := fwtemporarytable():new("T310")
	oTab310:setfields(aStrR310)
	oTab310:addindex("01",{"CHAVE"})
	oTab310:create()
	dbselectarea("T310")

	aadd(aStrR311, {"CHAVE","C",100,0})
	aadd(aStrR311, {"TP_FONE","C",1,0})
	aadd(aStrR311, {"NR_DDD","C",4,0})
	aadd(aStrR311, {"NR_FONE","C",9,0})
	aadd(aStrR311, {"TP_EMAIL","C",1,0})
	aadd(aStrR311, {"END_EMAIL","C",70,0})
	oTab311 := fwtemporarytable():new("T311")
	oTab311:setfields(aStrR311)
	oTab311:addindex("01",{"CHAVE"})
	oTab311:create()
	dbselectarea("T311")

	aadd(aStrR316, {"CHAVE","C",100,0})
	aadd(aStrR316, {"CD_UNIMED","C",4,0})
	aadd(aStrR316, {"ID_BENEF","C",13,0})
	aadd(aStrR316, {"DT_EXC_UNI","C",8,0})
	aadd(aStrR316, {"MOT_EXCBEN","C", 2,0})
	aadd(aStrR316, {"REG_PLAANS","C",20,0})
	aadd(aStrR316, {"DT_FIM_VIG","C",8,0})
	oTab316 := fwtemporarytable():new("T316")
	oTab316:setfields(aStrR316)
	oTab316:create()
	dbselectarea("T316")

	aadd(aStrR317, {"CHAVE","C",100,0})
	aadd(aStrR317, {"TIPO","C",1,0})
	aadd(aStrR317, {"CD_UNIMED","C",4,0})
	aadd(aStrR317, {"ID_BENEF","C",13,0})
	aadd(aStrR317, {"NM_BENEF","C",70,0})
	aadd(aStrR317, {"DT_NASC","C",8,0})
	aadd(aStrR317, {"TP_SEXO","C",1,0})
	aadd(aStrR317, {"CD_CNS","C",15,0})
	aadd(aStrR317, {"CD_CNPJ","C",15,0})
	aadd(aStrR317, {"CAUTGESANS","C",10,0})
	aadd(aStrR317, {"CD_CPF","C",11,0})
	aadd(aStrR317, {"DT_INCL","C",8,0})
	aadd(aStrR317, {"DT_EXCL","C",8,0})
	oTab317 := fwtemporarytable():new("T317")
	oTab317:setfields(aStrR317)
	oTab317:create()
	dbselectarea("T317")

return


/*/{Protheus.doc} fechaXMLArea
Realiza o fechamento das areas de trabalho criadas para os dados do XML.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param oTab301, object, Objeto do layout 301.
@param oTab302, object, Objeto do layout 302.
@param oTab303, object, Objeto do layout 303.
@param oTab305, object, Objeto do lT302ayout 307.
@param oTab308, object, Objeto do layout 308.
@param oTab309, object, Objeto do layout 309.
@param oTab310, object, Objeto do layout 310.
@param oTab311, object, Objeto do layout 311.
@param oTab316, object, Objeto do layout 316.
@param oTab317, object, Objeto do layout 317.
/*/
static function fechaXMLArea(oTab301, oTab302, oTab303, oTab305, oTab306, oTab307, oTab308, oTab309, oTab310, oTab311, oTab316, oTab317)
	if select("T301") > 0
		oTab301:delete()
	endif

	if select("T302") > 0
		oTab302:delete()
	endif

	if select("T303") > 0
		oTab303:delete()
	endif

	if select("T305") > 0
		oTab305:delete()
	endif

	if select("T306") > 0
		oTab306:delete()
	endif

	if select("T307") > 0
		oTab307:delete()
	endif

	if select("T308") > 0
		oTab308:delete()
	endif 

	if select("T309") > 0
		oTab309:delete()
	endif 
	
	if select("T310") > 0
		oTab310:delete()
	endif 
	
	if select("T311") > 0
		oTab311:delete()
	endif 

	if select("T316") > 0
		oTab316:delete()
	endif

	if select("T317") > 0
		oTab317:delete()
	endif 

return


/*/{Protheus.doc} somaTpReg
Função para realizar o somátorio de registros inseridos nas tabelas temporárias.

@author Gabriel Hegler Klok

@type static function
@since 2019/11
@version 1.0

@param cTipReg, caracter, Indica o tipo de registro.
@param cCdLay, caracter, Indica o layout referente as tags XML.
/*/
static function somaTpReg(cTipReg, cCdLay)
	do case
		case cTipReg == 'I'

			if cCdLay == '302'
				nQtdIEmp++
			elseif cCdLay == '303'
				nQtdIPes++
			elseif cCdLay == '317'
				nQtdIAut++
			endif 

		case cTipReg == 'A'

			if cCdLay == '302'
				nQtdAEmp++
			elseif cCdLay == '303'
				nQtdAPes++
			elseif cCdLay == '317'
				nQtdAAut++
			endif 

		case cTipReg == 'E'
			nQtdExc++
	endcase 
return


/*/{Protheus.doc} codUF
Retorna o codigo do estado segundo manual UNIMED PTU Versao 1.0 MS.081 Rev.06

@type static function
@since 14/01/2020
@version 1.0

@param cUF, caracter, Sigla do estado.

@return cCod, caracter, Codigo da unidade federativa conforme manual.
/*/
static function codUF(cUF)
	do case 
		// norte
		case cUF == "RO"
			return "11"
		case cUF == "AC"
			return "12"
		case cUF == "AM"
			return "13"
		case cUF == "RR"
			return "14"
		case cUF == "PA"
			return "15"
		case cUF == "AP"
			return "16"
		case cUF == "TO"
			return "17"
		
		// nordeste
		case cUF == "MA"
			return "21"
		case cUF == "PI"
			return "22"
		case cUF == "CE"
			return "23"
		case cUF == "RN"
			return "24"
		case cUF == "PB"
			return "25"
		case cUF == "PE"
			return "26"
		case cUF == "AL"
			return "27"
		case cUF == "SE"
			return "28"
		case cUF == "BA"
			return "29"

		// sudeste
		case cUF == "MG"
			return "31"
		case cUF == "ES"
			return "32"
		case cUF == "RJ"
			return "33"
		case cUF == "SP"
			return "35"

		// sul
		case cUF == "PR"
			return "41"
		case cUF == "SC"
			return "42"
		case cUF == "RS"
			return "43"

		// centro-oeste
		case cUF == "MS"
			return "50"
		case cUF == "MT"
			return "51"
		case cUF == "GO"
			return "52"
		case cUF == "DF"
			return "53"

		// Estrangeiro
		case cUF == "EX"
			return "98"
			
	endcase 
return ""


//-------------------------------------------------------------------
/*/{Protheus.doc} retCondBA1

Retorna a condicao da query BA1
@author  sakai
@version P12
@since   10/11/2020
/*/
//------------------------------------------------------------------- 
Static Function retCondBA1()

	Local cSQL       := ''
	Local cCodEmpInt := Alltrim(GetNewPar("MV_PLSGEIN",""))  

	cSQL += " BA1_FILIAL = '"+xFilial("BA1")+"' "
	cSQL += " AND BA1_CODINT = '"+ PlsIntPad() +"' "
	If !Empty(cEmpDe) .And. !Empty(cEmpAte)
		cSQL += " AND BA1_CODEMP >= '"+ cEmpDe +"' " 
		cSQL += " AND BA1_CODEMP <= '"+ cEmpAte +"' " 	
		If !Empty(cContDe) .And. !Empty(cContAte)
			cSQL += " AND BA1_CONEMP >= '"+ cContDe +"' " 
			cSQL += " AND BA1_CONEMP <= '"+ cContAte +"' " 
			If !Empty(cSubConDe) .And. !Empty(cSubConAte)
				cSQL += " AND BA1_SUBCON >= '"+ cSubConDe +"' " 
				cSQL += " AND BA1_SUBCON <= '"+ cSubConAte +"' " 
			Endif
		Endif
	Endif
	//Usuario de intercambio eventual nao entra
	cSQL += " AND BA1_CODEMP <> '"+ cCodEmpInt +"' "

	If ValType(nInfANS) == "N" .And. ValType(nInfSib) == "N" 
		cSQL += IIF(nInfANS == 1 .Or. nInfANS == 2," AND BA1_INFANS = '"+cValToChar(nInfANS)+"' ","")
		cSQL += IIF(nInfSib == 1 .Or. nInfSib == 2," AND BA1_INFSIB = '"+cValToChar(nInfSib)+"' ","")
	EndIf

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryUnionA1300

Realiza uma união na query do A1300, verificando os registros da via
do cartão e do desbloqueio do beneficiário.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   01/03/2021
/*/
//------------------------------------------------------------------- 
Static Function QueryUnionA1300(cQuery, cDtInicial, cDtFinal)

		Default cQuery := ""

		// Verifica nova via do cartão do beneficiário
		If !Empty(cQuery)
			cQuery += " UNION "
		EndIf
		cQuery += "SELECT BA1.R_E_C_N_O_ RECBA1, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG " 
		cQuery += " FROM "+RetSQLName("BED")+" BED "

		cQuery += " INNER JOIN "+RetSQLName("BA1")+" BA1 ON "
		cQuery += retCondBA1()
		cQuery += " AND BA1.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE BED.BED_FILIAL = '"+xFilial("BED")+"' "
		cQuery += "   AND BED.BED_CODINT = BA1.BA1_CODINT "
		cQuery += "	  AND BED.BED_CODEMP = BA1.BA1_CODEMP "
		cQuery += "	  AND BED.BED_MATRIC = BA1.BA1_MATRIC "
		cQuery += "	  AND BED.BED_TIPREG = BA1.BA1_TIPREG "
		cQuery += "	  AND BED.BED_DIGITO = BA1.BA1_DIGITO "
		cQuery += "	  AND BED.BED_DTSOLI >= '"+cDtInicial+"' "
		cQuery += "	  AND BED.BED_DTSOLI <= '"+cDtFinal+"' "
		cQuery += "   AND BED.D_E_L_E_T_ = ' ' "

		// Verifica desbloqueio do beneficiário
		cQuery += " UNION SELECT BA1.R_E_C_N_O_ RECBA1, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG " 
		cQuery += " FROM "+RetSQLName("BCA")+" BCA "

		cQuery += " INNER JOIN "+RetSQLName("BA1")+" BA1 ON "
		cQuery += retCondBA1()
		cQuery += " AND BA1.BA1_DATBLO = ' ' AND BA1.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE BCA.BCA_FILIAL = '"+xFilial("BCA")+"' "
		If AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES"
			cQuery += "	  AND BCA.BCA_MATRIC = BA1.BA1_CODINT || BA1.BA1_CODEMP || BA1.BA1_MATRIC "
		Else
			cQuery += "	  AND BCA.BCA_MATRIC = BA1.BA1_CODINT + BA1.BA1_CODEMP + BA1.BA1_MATRIC "
		EndIf
		cQuery += "	  AND BCA.BCA_TIPREG = BA1.BA1_TIPREG "
		cQuery += "	  AND BCA.BCA_TIPO = '1' "
		cQuery += "	  AND BCA.BCA_DATLAN >= '"+cDtInicial+"' "
		cQuery += "	  AND BCA.BCA_DATLAN <= '"+cDtFinal+"' "
		cQuery += "   AND BCA.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckMovBenef

Verifica se há movimentação do beneficiário de nova via do cartão
ou desbloqueio

@author  Vinicius Queiros Teixeira
@version Protheus 12 
@since   01/03/2021
/*/
//------------------------------------------------------------------- 
Static Function CheckMovBenef(cAlias, cCodInt, cCodEmp, cMatric, cTipo, cDigito, dDtInicial, dDtFinal)

	Local cQuery := ""
	Local lMovimentacao := .F.
	Local nQuantidade := 0

	Do Case
		Case cAlias == "BED"
			cQuery := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("BED")+" BED "
			cQuery += " WHERE BED.BED_FILIAL = '"+xFilial("BED")+"' "
			cQuery += "		  AND BED.BED_CODINT = '"+cCodInt+"' "
			cQuery += "	 	  AND BED.BED_CODEMP = '"+cCodEmp+"' "
			cQuery += "	 	  AND BED.BED_MATRIC = '"+cMatric+"' "
			cQuery += "	 	  AND BED.BED_TIPREG = '"+cTipo+"' "
			cQuery += "	 	  AND BED.BED_DIGITO = '"+cDigito+"' "
			cQuery += "	      AND BED.BED_DTSOLI >= '"+DToS(dDtInicial)+"' "
			cQuery += "	      AND BED.BED_DTSOLI <= '"+DToS(dDtFinal)+"' "
			cQuery += "       AND BED.D_E_L_E_T_ = ' ' "

			nQuantidade := MPSysExecScalar(cQuery, "CONTADOR")			
		Case cAlias == "BCA"
			cQuery := " SELECT COUNT(*) CONTADOR FROM "+RetSQLName("BCA")+" BCA "
			cQuery += " WHERE BCA.BCA_FILIAL = '"+xFilial("BCA")+"' "
			cQuery += "	  AND BCA.BCA_MATRIC = '"+cCodInt+cCodEmp+cMatric+"' "
			cQuery += "	  AND BCA.BCA_TIPREG = '"+cTipo+"' "
			cQuery += "	  AND BCA.BCA_TIPO = '1' "
			cQuery += "	  AND BCA.BCA_DATLAN >= '"+DToS(dDtInicial)+"' "
			cQuery += "	  AND BCA.BCA_DATLAN <= '"+DToS(dDtFinal)+"' "
			cQuery += "   AND BCA.D_E_L_E_T_ = ' ' "

			nQuantidade := MPSysExecScalar(cQuery, "CONTADOR")
	EndCase

	If nQuantidade > 0
		lMovimentacao := .T.
	EndIf

Return lMovimentacao
