#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSA090.CH"

#define __aCdCri104 {"912",STR0054}//"Rede de atendimento de Alto Custo"
#define __aCdCri106 {"907",STR0056}//"Data de atendimento informada na transacao de internacao (On-Line)"
#define __aCdCri200 {"980","Procedimento do tipo 'Pacote' em autorização PTU On-line"}
#define __aCdCri202 {"978","Registro DS_OBSERVA informado, guia automaticamente enviada para Auditoria"}
#define __aCdCri203 {"979","Registro DS_OPME informado, serviço não existe na tabela de Intercâmbio Nacional"}
#define __aCdCri107 {"910","Processo de autorizacao On-Line (Cancelado)"}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTRTPTU
RDMAKE para tratamento do PTU online (RECEBIMENTO)

@author  Eduardo Motta
@version P11
@since   12.02.04
/*/
//-------------------------------------------------------------------
User Function PlsTrtPtu()

	LOCAL nFor
	LOCAL aRetRda
	LOCAL cNomUsr
	LOCAL cTpPessoa
	LOCAL cOpeSol
	LOCAL nPos
	LOCAL cTmpPro
	LOCAL cTranOri
	LOCAL cTranDes
	LOCAL cTpTran
	LOCAL cTpResp
	LOCAL TpTab
	LOCAL cOpeDes
	LOCAL cCodOri       := ""
	LOCAL cCodPrfSol    := ""
	LOCAL cRet 			:= ""
	LOCAL lDtAten		:= .F.
	LOCAL lUmAut		:= .F.
	LOCAL lUmNeg		:= .F.
	LOCAL lUmAud		:= .F.
	LOCAL lFirst		:= .F.
	LOCAL cDescTran		:= "CONSULTA OU SADT"
	LOCAL cTipo 		:= "2"
	LOCAL lIntern		:= .F.
	LOCAL lAudito		:= .F.
	LOCAL lAudEmp		:= .F.
	LOCAL lCriticou		:= .F.
	LOCAL lCriCab		:= .F.
	LOCAL lPacote       := .F.
	LOCAL lEvoSadt      := .F.
	Local lConsulta     := .F.
	LOCAL nPosCri		:= 0
	LOCAL nPosSeq		:= 0
	local nPosAnexo		:= 0
	LOCAL aRetCri		:= {}
	LOCAL aIte 	   		:= {}
	LOCAL aRet 	   		:= {}
	Local aRetBTU       := {}
	LOCAL aRetGer		:= {}
	LOCAL cCodInt  		:= ""
	LOCAL cCodUsu  		:= ""
	LOCAL cCodMed  		:= ""
	LOCAL cCodMed2 		:= ""
	LOCAL nTamObs   	:= (TamSX3("BEA_MSG01")[1])
	LOCAL dData    		:= Date()
	LOCAL dDataAt       := CtoD("")
	LOCAL cCidPri  		:= ""
	LOCAL cCodPad       := ""
	LOCAL cCodPadMV		:= SubStr(GetNewPar("MV_PLSTBPD","01") ,1,2)
	LOCAL cCodPad2		:= GetNewPar("MV_PTUTAB2","02")
	LOCAL cCodPro  		:= ""
	LOCAL cUniSol  		:= ""
	LOCAL nI 			:= 0
	LOCAL nJ 	   		:= 0
	LOCAL nX			:= 0
	LOCAL nQtd	 		:= 0
	LOCAL nOpme         := 0
	LOCAL cAt			:= ""
	LOCAL cAtIt			:= ""
	LOCAL cTmpIni 		:= Time()
	LOCAL lRet			:= .T.
	LOCAL cAutori		:= ""
	LOCAL cCodCri 		:= ""
	LOCAL cDesCri 		:= ""
	LOCAL cOldDesCri	:= ""
	LOCAL cResRev		:= ""
	LOCAL cTipInt 		:= "1"
	LOCAL cSenhaAut     := ""
	LOCAL cTextoMsg3    := ""
	LOCAL cLastTran     := ""
	LOCAL cTranResp     := ""
	LOCAL cTipTra       := ""
	LOCAL cRetA1100     := ""
	LOCAL cTpCliente    := ""
	LOCAL cAliasCab		:= ''
	LOCAL cObsReturn    := ""
	lOCAL aRetA1100     := {}
	LOCAL aCriticas 	:= {}
	LOCAL aEventosNeg 	:= {}
	LOCAL aOpme         := {}
	LOCAL aRetPtu       := {}
	LOCAL aObsReturn    := {}
	LOCAL lNMonit		:= .f.
	LOCAL lGravaTran    := .t.
	LOCAL lA1100        := .f.
	LOCAL lAnexo 		:= .f.
	local lConfOSInt	:= .f.
	LOCAL lConverProc   := !Empty(GetNewPar("MV_PTUTAB2"," "))
	LOCAL lFindSol      := .F.
	LOCAL cCodMedGen    := GetNewPar("MV_PLMEDPT","")
	LOCAL cCodMatGen    := GetNewPar("MV_PLMATPT","")
	LOCAL cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
	LOCAL cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
	LOCAL lOpme         := .F.
	LOCAL cNrTrol 		:= ""
	LOCAL cOpeOri 		:= PlsPtuGet("CD_UNI_ORI",aDados)
	LOCAL cTagOPME 		:= ""
	LOCAL cOld		 	:= '0'
	LOCAL cTpAnexo		:= '0'
	LOCAL aIteAnexo		:= {}
	LOCAL aDadosAux     := {}
	LOCAL cTraPrest     := ""
	LOCAL cTraOriBen    := ""
	LOCAL cDtValOS      := ""
	LOCAL cTraOriOS     := ""
	LOCAL aIteOS        := {}
	LOCAL l404Triang    := .F.
	LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70"
	LOCAL cGuiAneOri    := ""
	LOCAL lPLPtuIte     := ExistBlock("PLPTUITE")
	LOCAL cNumArq       := ""
	LOCAL lRetA750      := .F.
	LOCAL cDsObserv     := ""
	LOCAL nPosDesGen    := 0
	LOCAL cDescGen      := ""
	LOCAL cCriUrgAud    := GetNewPar("MV_PTAUDUR","")
	LOCAL nPosCodPro    := 0
	LOCAL lAuto         := paramixb[1]
	LOCAL lPTUOn80		:= Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	Local nPosTpTab		:= 0
	Local lMatTNUM		:= .F.
	Local lMatTUSS		:= .F.
	Local cPacoteGen    := Alltrim(GetNewPar("MV_PLPACPT",""))
	Local aPacoteGuia	:= {}
	Local nBuscPacote := 0
	Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
	Local cVerPTUOnline := "0"+GetNewPar("MV_PTUVEON", "90")
	Local cSaudeOcupacional := ""
	Local cCobEspecial := ""
	Local cCBOSolicitante := ""
	Local cCBOExecutante := ""
	Local aDadosInternacao := {}
	Local lInterClinica := .F.
	Local lUrgenEmergen := .F.
	Local lGuiaInternacao := .F.

	//Zera variavel privada
	cDelimit := ""
	cCodPadMV := cCodPadMV

	//Alimenta variavies
	cOpeSol   := AllTrim( PlsPtuGet("CD_UNI_ORI",aDados) )
	cTpTran   := Upper(PlsPtuGet("CD_TRANS",aDados))
	cTranOri := StrZero( Val( PlsPtuGet("NR_IDENT_O",aDados) ),10)
	cNrTrol  := PADR(StrZero( Val( PlsPtuGet("NR_TRANS_R",aDados) ),10), TAMSX3("BEA_NRTROL")[1])


	cTranDes  := PlsPtuGet("NR_IDENT_D",aDados)
	cCodInt   := PlsIntPad()
	cUniSol	  := Iif(ctptran <> "00806",PlsPtuGet("CD_UNI",aDados),PlsPtuGet("CD_UNI_BEN",aDados))
	cOpeDes   := PlsPtuGet("CD_UNI_ORI",aDados)
	cCodMed   := PlsPtuGet("CD_PREST",aDados)
	cCodMed2  := PlsPtuGet("CD_PRE_REQ",aDados)
	cCidPri   := Iif( Empty( Upper(PlsPtuGet("CD_CID",aDados)) ),"Z000",Upper(PlsPtuGet("CD_CID",aDados)) )


	//Ajusta variaveis de operadoras
	cOpeOri := Strzero(Val(cOpeOri),4)
	cOpeSol := Strzero(Val(cOpeSol),4)
	cOpeDes := Strzero(Val(cOpeDes),4)
	cUniSol := Strzero(Val(cUniSol),4)
	cCodUsu   := cValToChar(cUniSol) + PadL(PlsPtuGet("ID_BENEF",aDados),13,"0")

	If cTpTran == "00360"
		cTranOri := StrZero( Val( PlsPtuGet("NR_IDENT_E",aDados)),10)
		cOpeSol  := StrZero( Val( PlsPtuGet("CD_UNI_EXE",aDados)),4)
	EndIf


	//Verifica se e uma transacao de monitoramento
	If cOpeDes == GETNEWPAR("MV_PLOPEMO","0999")
		lNMonit := ( GetNewPar("MV_MONUNI","0") == "0" )
		PlsPtuLog("")
		PlsPtuLog("Para ativar a checagem de regra no monitoramento, ative o parametro MV_MONUNI como o valor 1")
		PlsPtuLog("")
	EndIf


	//Verifica se ha os indices
	If cTpTran == "00600"
		SIX->( DbSetOrder(1) )
		If !SIX->( MsSeek("BEAM") )
			cRet := "INDICE (M) NO BEA NAO EXISTE"
		EndIf

		If !SIX->( MsSeek("BE4A") )
			cRet := "INDICE (A) NO BE4 NAO EXISTE"
		EndIf

		PlsPtuLog("")
		If !Empty(cRet)
			PlsPtuLog("*** "+cRet+" ***")
		EndIf
	EndIf

	//Se esta ok
	If Empty(cRet)

		BB0->(DbSetOrder(6))//BB0_FILIAL + BB0_CODOPE + BB0_CODIGO
		If BB0->( MsSeek( xFilial("BB0")+cOpeSol ) )
			cCodPrfSol := BB0->BB0_CODIGO
			cCodOri    := BB0->BB0_CODORI
		Else
			BA0->(DbSetOrder(1))//BA0_FILIAL + BA0_CODIDE + BA0_CODINT....
			If BA0->( MsSeek( xFilial("BA0")+cOpeSol ) )
				PlSveProfAll("SOLIC. PAD. OPER. "+cOpeSol, GETMV("MV_PLSIGLA"), BA0->BA0_EST, "OPE"+cOpeSol, cOpeSol, '', '1', cOpeSol+"999999", {})
				cCodPrfSol := BB0->BB0_CODIGO
				cCodOri    := BB0->BB0_CODORI
			Endif
		EndIf

		PlsPtuLog("***********************************")
		PlsPtuLog("INICIO DA TRANSACAO")
		PlsPtuLog("***********************************")

		//Para uso no plsxmov
		PlsPtuPut("TPGRV","5",aDados)
		PlsPtuPut("LVEIOCOMU",.T.,aDados)
		PlsPtuPut("INTERN",lIntern,aDados)
		PlsPtuPut("TIPOMAT","1",aDados)
		PlsPtuPut("CDPFSO",cCodPrfSol,aDados)
		PlsPtuPut("AUDEMP",.T.,aDados)
		PlsPtuPut("TIPO",cTipo,aDados)
		PlsPtuPut("ALTOCUS",Iif( PlsPtuGet("ID_ALTO_CU",aDados) $ "S1",.T.,.F.),aDados)
		IIf (cTpTran <> "00605",PlsPtuPut("NRTRAN",cTranOri,aDados),PlsPtuPut("NRTRAN",StrZero( Val(PlsPtuGet("NR_TRANS_R",aDados) ),10) ,aDados))


		If PlsPtuGet("TP_CLIENTE",aDados) == "A1100"
			If cTpTran == "00605"
				PlsPtuPut("NRTRAN",StrZero( Val(PlsPtuGet("NR_TRANS_R",aDados)),10) ,aDados)
			Else
				PlsPtuPut("NRTRAN",StrZero( Val(PlsPtuGet("NR_IDENT_O",aDados)),10) ,aDados)
			EndIf
			PlsPtuPut("NRAOPE1100",StrZero( Val(PlsPtuGet("NR_IDENT_D",aDados)),10) ,aDados)
		EndIf
		PlsPtuPut("CDOPEX",PlsIntPad(),aDados)
		PlsPtuPut("CODLDP",GetNewPar("MV_PLSPEGE","0000"),aDados)
		PlsPtuPut("OPEMOV",cCodInt,aDados)
		PlsPtuPut("DVALSE",STOD(PlsPtuGet("DT_VALIDAD",aDados)),aDados)

		If !Empty(PlsPtuGet("DT_ATENDIM",aDados)) .and. PlsPtuGet("TP_CLIENTE",aDados) == "A1100"
			PlsPtuPut("DATPRO"	,ctod(Subs(PlsPtuGet("DT_ATENDIM",aDados),7,2)+"/"+Subs(PlsPtuGet("DT_ATENDIM",aDados),5,2)+"/"+Subs(PlsPtuGet("DT_ATENDIM",aDados),1,4)),aDados)
			PlsPtuPut("HORAPRO"	,substr(PlsPtuGet("DT_ATENDIM",aDados),11,2)+ substr(PlsPtuGet("DT_ATENDIM",aDados),14,2),aDados)

		Elseif !Empty(PlsPtuGet("DT_ATENDIM",aDados))

			PlsPtuPut("DATPRO",STOD(PlsPtuGet("DT_ATENDIM",aDados)),aDados)
			PlsPtuPut("HORAPRO",SubStr(StrTran(Time(),":",""),1,4),aDados)

		Else

			PlsPtuPut("DATPRO",dDataBase,aDados)
			PlsPtuPut("HORAPRO",SubStr(StrTran(Time(),":",""),1,4),aDados)
		EndIf

		PlsPtuPut("DATPRVINT",dDataAt,aDados)
		PlsPtuPut("CIDPRI",cCidPri,aDados)
		If !lPTUOn90
			PlsPtuPut("VIACAR",PlsPtuGet("NR_VIA_CAR",aDados),aDados)
		EndIf
		PlsPtuPut("TIPINT",GetNewPar("MV_PLTPINT","01"),aDados)
		PlsPtuPut("OPEINT",cOpeDes,aDados)
		PlsPtuPut("TIPSAI",GetNewPar("MV_TIPSAI","3"),aDados)
		PlsPtuPut("CODORI",cCodOri,aDados)


		//Se a transacao esta sendo executada, retorna sem processar
		If PlsAliasExi("B93") .And. !lNMonit
			If !RegTranB93(cOpeSol,cTpTran,cTranOri)
				Return()
			EndIf
		EndIf

		//Posiciona no usuario
		BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If !BA1->(dbSeek(xFilial("BA1")+cCodUsu))
			BA1->(DbSetOrder(5))
			BA1->(dbSeek(xFilial("BA1")+cCodUsu))
		EndIf

		//Posiciona na familia
		BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

		cNomUsr   := PadR(BA1->BA1_NOMUSR,25)
		If Empty(cNomUsr) .And. !(BA1->(Found()))
			cNomUsr := "BENEFICIARIO INEXISTENTE"
		EndIf
		cTpPessoa := If(BA3->BA3_TIPOUS=="1","2","1")
		cCodUsu   := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

		//Transacoes de solicitacao/auditoria alimenta campos
		If cTpTran $ '00600-00605-00404'
			PlsPtuPut("NOMUSR",cNomUsr,aDados)
			PlsPtuPut("USUARIO",cCodUsu,aDados)
			PlsPtuPut("TP_PESSOA",cTpPessoa,aDados)
			PlsPtuPut("NM_BENEF",cNomUsr,aDados)
		EndIf
		PlsPtuPut("PTUONLINE",.T.,aDados)

		//Ajusta codigo dos itens com zeros no inicio
		if cTpTran $ '00600-00605-00404'
			for nX := 1 to len(aItens)
				if nPosCodPro == 0
					nPosCodPro := Ascan(aItens[nX],{|x| x[1] == "CD_SERVICO"})
					nPosTpTab  := Ascan(aItens[nX],{|x| x[1] == "TP_TABELA"})
				endIf

				if nPosCodPro > 0
					If nPosTpTab > 0 .And. aItens[nX,nPosTpTab,2] == "00" .And. lPTUOn80
						aItens[nX,nPosCodPro,2] := Strzero(Val(aItens[nX,nPosCodPro,2]),10)
					Else
						aItens[nX,nPosCodPro,2] := Strzero(Val(aItens[nX,nPosCodPro,2]),Len(aItens[nX,nPosCodPro,2]))
					EndIf
				endIf
			next
		endIf

		Do Case
			Case cTpTran == "00600" .or. cTpTran == "00605"

				PlsPtuLog("codigoTransacao                => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente                    => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf
				PlsPtuLog("codigoUnimedPrestadora         => "+PlsPtuGet("CD_UNI_ORI",aDados))
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_DES",aDados))
				PlsPtuLog("numeroTransacaoPrestadora      => "+cTranOri)
				PlsPtuLog("identificacaoBeneficiario/codigoUnimed        => "+PlsPtuGet("CD_UNI",aDados))
				PlsPtuLog("identificacaoBeneficiario/codigoIdentificacao => "+PlsPtuGet("ID_BENEF",aDados))
				If !lPTUOn90
					PlsPtuLog("identificacaoBeneficiario/numeroViaCartao     => "+PlsPtuGet("NR_VIA_CAR",aDados))
					PlsPtuLog("codigoCID     => "+PlsPtuGet("CD_CID",aDados))
				EndIf

				If !lPTUOn90
					PlsPtuLog("tpRedeMIN     => "+PlsPtuGet("TIPO_REDE_",aDados))
					PlsPtuLog("prestador/nomePrestador   => "+PlsPtuGet("NM_PRESTAD",aDados))
					PlsPtuLog("prestador/codigoPrestador => "+PlsPtuGet("CD_PREST",aDados))
					PlsPtuLog("prestador/codigoUnimed    => "+PlsPtuGet("CD_UNI_PRE",aDados))
				EndIf

				PlsPtuLog("observacao       => "+PlsPtuGet("DS_OBSERVA",aDados))
				PlsPtuLog("indicacaoClinica => "+PlsPtuGet("DS_IND_CLI",aDados))

				If lPTUOn90
					PlsPtuLog("prestadorSolicitante => "+PlsPtuGet("", aDados))
					PlsPtuLog("codigoUnimed         => "+PlsPtuGet("CD_UNI_REQ", aDados))
					PlsPtuLog("codigoPrestador      => "+PlsPtuGet("CD_PRE_REQ", aDados))
					PlsPtuLog("nomePrestadorSolic   => "+PlsPtuGet("NM_PRO_SOLIC", aDados))
					PlsPtuLog("siglaConselho        => "+PlsPtuGet("SG_CONSEL", aDados))
					PlsPtuLog("numeroConselho       => "+PlsPtuGet("NM_CONSEL", aDados))
					PlsPtuLog("unidadeFederativa    => "+PlsPtuGet("UN_FEDERA", aDados))
					PlsPtuLog("numeroCBO            => "+PlsPtuGet("CD_CBO_SOL", aDados))

					PlsPtuLog("prestadorExexcutante => "+PlsPtuGet("", aDados))
					PlsPtuLog("codigoUnimed         => "+PlsPtuGet("CD_UNI_PRE", aDados))
					PlsPtuLog("codigoPrestador      => "+PlsPtuGet("CD_PREST", aDados))
					PlsPtuLog("nomePrestador        => "+PlsPtuGet("NM_PRESTAD", aDados))
					PlsPtuLog("numeroCBO            => "+PlsPtuGet("CD_CBO_EXEC", aDados))
				Else
					PlsPtuLog("prestadorRequisitante/codigoUnimed    => "+PlsPtuGet("CD_UNI_REQ",aDados))
					PlsPtuLog("prestadorRequisitante/codigoPrestador => "+PlsPtuGet("CD_PRE_REQ",aDados))
					PlsPtuLog("codigoEspecialidadeMedica   => "+PlsPtuGet("CD_ESPEC",aDados))
				EndIf

				PlsPtuLog("idUrgenciaEmergencia        => "+PlsPtuGet("ID_URG_EME",aDados))

				//Tratamento da Rda
				If !lNMonit
					If GetNewPar("MV_PLESPTU","0") == "1"
						aRetRda := PLSRTCRDAO( cOpeOri,cCodMed2,PlsPtuGet("CD_ESPEC",aDados),.T. )
					Else
						aRetRda := PLSRTCRDAO( cOpeOri,cCodMed2 )
					EndIf
				Else
					aRetRda := {.T.}
				EndIf

				//Se a Rda e valida
				If aRetRDA[1]

					//Se informado a data do atendimento diferente da atual, vai pra auditoria
					If !empty(PlsPtuGet("DT_ATENDIM",aDados))
						dDataAt := STOD(PlsPtuGet("DT_ATENDIM",aDados))  //Data do atendimento
						If dDataAt < dDataBase .And. GetNewPar("MV_PTDTRET","1") == "1"
							lDtAten := .T.
							cTextoMsg3 := "Data Retroativa "+Substr(DtoS(dDataAt),7,2)+"/"+Substr(DtoS(dDataAt),5,2)+"/"+Substr(DtoS(dDataAt),1,4)
						EndIf
					Else
						dDataAt := dDataBase
					EndIf

					//Se TP_TABELA do tipo pacote (4) envia diretamente para a auditoria
					For nI := 1 to len(aItens)
						If PlsPtuGet("TP_TABELA",aItens[nI]) $ "4/98"
							lPacote := .T.
							Exit
						EndIf
					Next

					If !lNMonit
						PlsPtuPut("CODRDA",aRetRda[3],aDados)
						PlsPtuPut("CODLOC",aRetRda[4],aDados)
						PlsPtuPut("CODESP",aRetRda[5],aDados)
						PlsPtuPut("CDPFSO",aRetRda[6],aDados)
						PlsPtuPut("CDPFEX",aRetRda[6],aDados)
						PlsPtuPut("TPPRES",aRetRda[7],aDados)
						PlsPtuPut("TPRDA" ,aRetRda[8],aDados)
					EndIf

					If PlsPtuGet("ID_RN",aDados) == "S"
						PlsPtuPut("ATENRN","1",aDados)
					Else
						PlsPtuPut("ATENRN","0",aDados)
					EndIf

					If !lPTUOn90
						Do Case
							Case PlsPtuGet("ID_ACIDENT",aDados) == "1" //1 = Acidente de Trabalho
								PlsPtuPut("INDACI","0",aDados)
							Case PlsPtuGet("ID_ACIDENT",aDados) == "2" //2 = Acidente de Trânsito
								PlsPtuPut("INDACI","1",aDados)
							Case PlsPtuGet("ID_ACIDENT",aDados) == "3" //3 = Acidente – Outros
								PlsPtuPut("INDACI","2",aDados)
							OtherWise
								PlsPtuPut("INDACI","9",aDados) //9 = Não acidente
						EndCase
					EndIf


					//Verifica se o atendimento e de Urgencia
					If PlsPtuGet("ID_URG_EME",aDados) == "S"
						PlsPtuPut("CARSOL","U",aDados)
					Endif

					If Val( PlsPtuGet("CD_PREST",aDados) ) <> 0
						PlsPtuPut("RDAEDI",PlsPtuGet("CD_PREST",aDados),aDados)
						PlsPtuPut("NOMEDI",PlsPtuGet("NM_PRESTAD",aDados),aDados)
					EndIf

					Iif( PlsPtuGet("ID_ALTO_CU",aDados) $ "S1",cTextoMsg3 += "Prest Alto Custo: "+ PlsPtuGet("NM_PRESTAD",aDados)+" ","")

					PlsPtuPut("OPESOL",cOpeSol,aDados)
					cDsObserv := PlsPtuGet("DS_OBSERVA",aDados)
					If BEA->( FieldPos("BEA_MSG08") ) > 0 .And. BEA->( fieldPos("BEA_MSG09") ) > 0
						PlsPtuPut("MSG01",SubStr( cDsObserv,1,nTamObs),aDados)
						PlsPtuPut("MSG02",SubStr( cDsObserv,nTamObs+1,nTamObs),aDados)
						PlsPtuPut("MSG08",SubStr( cDsObserv,(nTamObs*2)+1,nTamObs),aDados)
						PlsPtuPut("MSG09",SubStr( cDsObserv,(nTamObs*3)+1,nTamObs),aDados)
					Else
						PlsPtuPut("MSG01",SubStr( cDsObserv,1,nTamObs),aDados)
						PlsPtuPut("MSG02",SubStr( cDsObserv,nTamObs+1,Len(cDsObserv)),aDados)
					EndIf
					PlsPtuPut("MSG03",cTextoMsg3 + " " + PlsPtuGet("DS_LINHA_O",aDados),aDados)
					PlsPtuPut("INDCLI",PlsPtuGet("DS_IND_CLI",aDados),aDados)
					PlsPtuPut("FORBLO",.T.,aDados)

					IF cTpTran == "00605" .And. BQV->( FieldPos("BQV_OBSER1") ) > 0 .And. !Empty(PlsPtuGet("DS_LINHA_O",aDados))
						PlsPtuPut("OBSEVO",PlsPtuGet("DS_LINHA_O",aDados),aDados)
					EndIf


					//Quando tem obs nao precisa checar regra vai direto para auditoria
					If !Empty( PlsPtuGet("DS_OBSERVA",aDados) )
						PlsPtuPut("CHKREG",.F.,aDados)   // NAO CHECA REGRAS
						PlsPtuPut("FORCAUD",.T.,aDados)  // MANDA DIRETO PARA AUDITORIA
					EndIf

					//Data de atendimento diferente da atual, vai diretamente para auditoria
					If lDtAten
						PlsPtuPut("CHKREG",.F.,aDados)   // NAO CHECA REGRAS
						PlsPtuPut("FAUDATE",.T.,aDados)  // MANDA DIRETO PARA AUDITORIA
					EndIf

					//Quando tem data de atendimento diferente da atual, ou procedimento do
					//tipo pacote, vai diretamente para auditoria

					If lPacote
						PlsPtuPut("CHKREG",.F.,aDados)   // NAO CHECA REGRAS
						PlsPtuPut("PACAUDI",.T.,aDados)  // MANDA DIRETO PARA AUDITORIA
					EndIf

					//Verifica se e processamento A1100
					If  PlsPtuGet("TP_CLIENTE",aDados) == "A1100"
						lA1100 := .T.
						PlsPtuPut("CHKREG",.F.,aDados)   // NAO CHECA REGRAS
						PlsPtuPut("PTUA1100",.T.,aDados) // INDICA UM ARQUIVO PTU A1100
					EndIf

					//Campos PTU 7.0
					If lPTUOn70
						PlsPtuPut("PROTOC",PlsPtuGet("PROT_ATEND",aDados),aDados)
						PlsPtuPut("TOKEDI",PlsPtuGet("TOKEN",aDados),aDados)
					EndIf

					If lPTUOn80
						If cTpTran == "00600"
							PlsPtuPut("ETAAUT", PlsPtuGet("TP_ETAP_AUT",aDados),aDados)
							PlsPtuPut("DTSOLI", StoD(PlsPtuGet("DT_SOLICIT",aDados)),aDados)
							PlsPtuPut("TPGUIA", PlsPtuGet("TP_GUIA",aDados),aDados)
							PlsPtuPut("TPACOM", PlsPtuGet("TP_ACOMODAC",aDados),aDados)
							PlsPtuPut("ALIASPTU", IIF(PlsPtuGet("TP_GUIA",aDados) == "3","BE4","BEA"),aDados)
							PlsPtuPut("TRANSPTU", "00600",aDados)
						Else
							PlsPtuPut("TPACOM", PlsPtuGet("TP_ACOMODAC",aDados),aDados)
							PlsPtuPut("ALIASPTU", "BQV",aDados)
							PlsPtuPut("TRANSPTU", "00605",aDados)
						EndIf

						If Val( PlsPtuGet("CD_PREST",aDados) ) <> 0
							PlsPtuPut("RDAPAC",PlsPtuGet("CD_PREST",aDados),aDados)
						EndIf

					EndIf

					// Novos Campos de Cabeçalho do PTU Online v90
					If lPTUOn90
						If cTpTran == "00600"
							
							cCobEspecial := PlsPtuGet("ID_COBESPE", aDados)

							If !Empty(cCobEspecial)
								PlsPtuPut("COBESPE", StrZero(Val(cCobEspecial), 2), aDados)
							EndIf

							cSaudeOcupacional := PlsPtuGet("ID_SAUDEOCUP", aDados)

							If !Empty(cSaudeOcupacional)
								Do Case
									Case cSaudeOcupacional == "1" // Admissional
										PlsPtuPut("TIPATE", "14", aDados)

									Case cSaudeOcupacional == "2" // Demissional
										PlsPtuPut("TIPATE", "15", aDados)

									Case cSaudeOcupacional == "3" // Periódico
										PlsPtuPut("TIPATE", "16", aDados)

									Case cSaudeOcupacional == "4" // Retorno ao trabalho 
										PlsPtuPut("TIPATE", "17", aDados)

									Case cSaudeOcupacional == "5" // Mudança de função 
										PlsPtuPut("TIPATE", "18", aDados)

									Case cSaudeOcupacional == "6" // Promoção à saúde
										PlsPtuPut("TIPATE", "19", aDados)
								EndCase
							EndIf
						EndIf

						cCBOSolicitante := PlsPtuGet("CD_CBO_SOL", aDados)
						cCBOExecutante := PlsPtuGet("CD_CBO_EXEC", aDados)

						BAQ->(DbSetORder(4))

						If !Empty(cCBOSolicitante)
							If BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+cCBOSolicitante)) .Or. BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+SubStr(cCBOSolicitante, 1, 4)+"."+SubStr(cCBOSolicitante, 5, 2)))
								PlsPtuPut("ESPSOL", AllTrim(BAQ->BAQ_CODESP), aDados)				
							Endif						
						EndIf

						If !Empty(cCBOExecutante)
							If BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+cCBOExecutante)) .Or. BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+SubStr(cCBOExecutante, 1, 4)+"."+SubStr(cCBOExecutante, 5, 2)))
								PlsPtuPut("ESPEXE", AllTrim(BAQ->BAQ_CODESP), aDados)				
							Endif						
						EndIf
					EndIf

					//Verifica se o ultima linha da matriz esta em branco
					If Empty(PlsPtuGet("CD_SERVICO",aItens[Len(aItens)],""))
						aSize(aItens,Len(aItens)-1)
					EndIf

					//Pega o codigo e qtd e implementa a nova matriz aite
					PlsPtuLog("PROCEDIMENTOS SOLICITADOS")
					PlsPtuLog("***********************************")

					BR8->( DbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN

					//verifica se esta guia ja existe quando for ordem de servico
					if (IIf(!lPTUOn90, PlsPtuGet("ID_ORDEM_S",aDados) == "S", !Empty(PlsPtuGet("NR_IDE_OS", aDados))))

						BEA->( dbSetOrder(22) )//BEA_FILIAL+BEA_NRTROL+BEA_OPESOL
						If BEA->( msSeek( xFilial("BEA") + PADR(PlsPtuGet("NR_IDE_OS",aDados), TAMSX3("BEA_NRTROL")[1]) + PlsIntPad() ) )
							if cTpTran == "00600"
								PlsPtuPut("NUMLIB",BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),aDados)
								PlsPtuPut("EVOLU",.f.,aDados)
								PlsPtuPut("INTERN",.f.,aDados)
								PlsPtuPut("ORIGEM",'1',aDados)
							endIf
						else
							BE4->( dbSetOrder(10) )
							if BE4->( msSeek( xFilial("BE4") + PADR(PlsPtuGet("NR_IDE_OS",aDados), TAMSX3("BEA_NRTROL")[1]) + PlsIntPad() ) )

								if cTpTran == "00600"
									lConfOSInt := .t.

									BEL->(dbSetOrder(1)) //BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN
									BEJ->(dbSetOrder(1)) //BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
									if BEJ->( msSeek( xFilial('BEJ') + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT ) )

										while !BEJ->(eof()) .and. BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == xFilial('BEJ') + BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)

											cSeqMov	:= BEJ->BEJ_SEQUEN
											cCodPad	:= BEJ->BEJ_CODPAD
											cCodPro	:= BEJ->BEJ_CODPRO
											cDescri	:= BEJ->BEJ_DESPRO
											nQtdSol	:= BEJ->BEJ_QTDSOL
											nQtdAut	:= BEJ->BEJ_QTDPRO

											//autorizado
											if BEJ->BEJ_STATUS == '1'
												aadd(aEventosAut,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,'','',"","",""})
											else
												aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,'','',"","",""})

												if BEL->( msSeek( xFilial('BEL') + BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )

													while !BEL->(eof()) .and. BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) == xFilial('BEL') + BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN)

														aadd( aCriticas,{cSeqMov,BEL->BEL_CODGLO,BEL->BEL_DESGLO,cCodPad,cCodPro,'',''} )

														BEL->(dbSkip())
													endDo

												endIf

											endIf

											BEJ->(dbSkip())
										endDo
									endIf

									//devolve o aRet da inclusao 00806 e nao entra na PLSXAUTP logo abaixo.
									aRet := {	BE4->BE4_STATUS=='1',;									//1
										BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),; 	//2
										BE4->BE4_SENHA,;									//3
										aCriticas,;                                             //4
										aEventosAut,;                                           //5
										aEventosNeg,;                                           //6
										0,;                                               		//7
										'',;                                             		//8
										'',;                                            		//9
										{},;                                               		//10
										.f.,;													//11
										ctod(""),;                                              //12
										'0',; 				                            		//13
										BE4->BE4_DATVAL }				  						//14

								endIf
							endIf
						endIf
					endIf

					//Verifica se e uma evolucao
					If cTpTran == "00605"

						BEA->( dbSetOrder(22) )//BEA_FILIAL+BEA_NRTROL+BEA_OPESOL
						If BEA->( msSeek( xFilial("BEA") + cNrTrol + cOpeSol ) ) .and. BEA->BEA_TIPGUI <> '03'
							cDescTran := "COMPLEMENTO SADT"
							PlsPtuPut("EVOSADT",.T.,aDados)
							lEvoSadt := .T.
						Else
							cDescTran := "EVOLUCAO"
							PlsPtuPut("EVOLU",.T.,aDados)
						Endif

						//Pega os dados do cabecalho da internacao
						aDadSeq := PlsGetBSA(cTranOri,cOpeSol)
						For nI := 1 To Len(aDadSeq[1])

							nPos := aScan( aDados, { |x| AllTrim(x[1]) == AllTrim(aDadSeq[1,nI,1]) } )

							If nPos == 0 .or. ( ValType(aDados[nPos,2]) == "C" .And.  Empty(aDados[nPos,2]) )
								PlsPtuPut(aDadSeq[1,nI,1],PlsPtuGet(aDadSeq[1,nI,1],aDadSeq[1]),aDados)
							EndIf

						Next

					EndIf

					//Zera
					aIte := {}
					For nI := 1 to Len(aItens)

						//Monta campos
						cCodPro  	:= PlsPtuGet("CD_SERVICO",aItens[nI])
						cCodPad     := cCodPadMV

						//Verifica se na guia existe pelo menos um evento de anexo
						if !lAnexo
							lAnexo	:= PlsPtuGet("TP_ANEXO",aItens[nI]) $ "1,2,3"
						endIf

						//Ponto de entrada para troca de procedimento
						If lPLPtuIte
							aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECENT","",PlsPtuGet("TP_TABELA",aItens[nI]),cCodPad,cTranOri,nil})
							cCodPad := aPlPtuIte[1]
							cCodPro := aPlPtuIte[2]
						Else
							// De-para somente pela tabela BTU (Terminologia TISS)
							If lPTUOn80
								If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados))
									aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cPacoteGen,,.T.,,.T.)
									aAdd(aPacoteGuia, {PlsPtuGet("SQ_ITEM",aItens[nI]), PlsPtuGet("CD_SERVICO",aItens[nI])})
								Else
									aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),PlsPtuGet("CD_SERVICO",aItens[nI]),,.T.,,.T.)
								EndIf

								If len(aRetBTU) > 0
									cCodPad := aRetBTU[1]
									cCodPro := aRetBTU[2]
								EndIf
							Else
								//Realiza De/Para AMB/CBHPM
								If lConverProc
									PLBusProTab(cCodPro,.F.,,,lConverProc,,,cCodPad2,cCodPad)
									If BR8->(Found())
										cCodPad := BR8->BR8_CODPAD
										cCodPro := BR8->BR8_CODPSA
									EndIf

									//Realiza De/Para BR8_CODEDI ou tabela B1M
								ElseIf GetNewPar("MV_PTDPION","0") == "1"
									PLBusProTab(cCodPro,.F.,,dDataAt,,,,,)
									If BR8->(Found())
										cCodPad := BR8->BR8_CODPAD
										cCodPro := BR8->BR8_CODPSA
									Endif

									//Realiza De/Para com a tabela de terminologias TISS BTU
								ElseIf GetNewPar("MV_PTDPION","0") == "2"
									aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,nil,.T.)
									If len(aRetBTU) > 0
										cCodPad := aRetBTU[1]
										cCodPro := aRetBTU[2]
									EndIf
								EndIf
							EndIf
						EndIf

						/*Regra de descricao preenchida, em alguns casos o evento vai diretamente para a auditoria

						Alteracao que entra em vigencia em 04/06/2019:
						Para códigos genéricos já é obrigatório informar a descrição serviço.
						A partir de 04/06/2019 entrará em produção a seguinte regra:
						Itens com tipo tabela 2 (TNUMM), 5 (TUSS) e OPME será obrigatório informar descrição serviço.
						O arquivo ptu_SimpleTypes-V70_00.zip se refere a esta atualização no PTU online.
						Para o PTU online no momento não estão definidas outras alterações, assim que for definido será informado através de boletim.
						*/
						cTagOPME:="DS_SERVICO"

						lMatTNUM := PlsPtuGet("TP_TABELA",aItens[nI]) == "00" .And. Substr(PlsPtuGet("CD_SERVICO",aItens[nI]),1,2) == "19"
						lMatTUSS := PlsPtuGet("TP_TABELA",aItens[nI]) == "19"

						if PlsPtuGet("TP_TABELA",aItens[nI]) $ "2/3" .Or. (lPTUOn80 .And. (lMatTNUM .Or. lMatTUSS))
							//Se codificacao generica, envia para auditoria
							if Alltrim(cCodPro) == cCodMedGen .Or.;
									Alltrim(cCodPro) == cCodMatGen .Or.;
									Alltrim(cCodPro) == cCodTaxGen .Or.;
									Alltrim(cCodPro) == cCodOpmGen

								lOpme := .T.
							endIf

							//Verifico se o evento existe e esta cadastrado como Opme na BR8
							if BR8->(DbSeek(xFilial("BR8")+cCodPad+cCodPro)) .And. BR8->BR8_TPPROC == "5" .And. ;
									allTrim(BR8->BR8_DESCRI) <> allTrim(PlsPtuGet(cTagOPME,aItens[nI]))

								lOpme := .T.
							endIf

							//Envio para auditoria
							if lOpme
								PlsPtuPut("DSEVENTO",'1',aItens[nI])
								PlsPtuPut("FAUDMOP",.T.,aItens[nI])
							endIf
						endIf

						//Na versao 5.0 itens das tabelas 1, 2 e 3 utiliza 03 inteiros e 04 decimais
						nQtd := Val(PlsPtuGet("QT_SERVICO",aItens[nI]) )


						//Verifica se e uma consulta ou sadt
						If Len(aItens) == 1 .And. PLSISCON(cCodPad,cCodPro)
							cTipo := "1"
						EndIf

						//Nova Matriz
						AaDd(aIte,{})
						AaDd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
						AaDd(aIte[nI],{"CODPAD",cCodPad })
						AaDd(aIte[nI],{"CODPRO",cCodPro })
						AaDd(aIte[nI],{"QTD",nQtd })
						AaDd(aIte[nI],{"QTDAUT",nQtd })
						AaDd(aIte[nI],{"DSEVENTO",PlsPtuGet("DSEVENTO",aItens[nI]) })

						//Novos campos PTU 5.0 - Integra com a TISS 3.00.00
						AaDd(aIte[nI],{"TP_ORDEM",PlsPtuGet("TP_ORDEM",aItens[nI]) })
						AaDd(aIte[nI],{"CD_ANVISA",PlsPtuGet("CD_ANVISA",aItens[nI]) })
						AaDd(aIte[nI],{"CD_REF_FAB",PlsPtuGet("CD_REF_FAB",aItens[nI]) })
						AaDd(aIte[nI],{"CD_VIA_ADM",PlsPtuGet("CD_VIA_ADM",aItens[nI]) })
						AaDd(aIte[nI],{"QT_FREQUEN",Val(PlsPtuGet("QT_FREQUEN",aItens[nI])) })
						AaDd(aIte[nI],{"TP_ANEXO",PlsPtuGet("TP_ANEXO",aItens[nI]) })
						If PlsPtuGet("ID_PACOTE",aItens[nI]) == "S" .And. !lPTUOn80
							AaDd(aIte[nI],{"PACOTE","1" })
						Endif

						// Novos campos PTU 6.0 - Integra com a TISS 3.03.00
						AaDd(aIte[nI],{"SQ_ITEM",Strzero(Val(PlsPtuGet("SQ_ITEM",aItens[nI])),2) })
						AaDd(aIte[nI],{"UNI_MEDIDA",Strzero(Val(PlsPtuGet("UNI_MEDIDA",aItens[nI])),3) })
						AaDd(aIte[nI],{"TOT_DOSAGE",PlsPtuGet("TOT_DOSAGE",aItens[nI]) })

						If lA1100
							Aadd(aIte[nI],{"ID_RESPWSD",PlsPtuGet("ID_RESPWSD",aItens[nI])})
							Aadd(aIte[nI],{"CD_MENS_ER",PlsPtuGet("CD_MENS_ER",aItens[nI])})
						EndIf

						If lPTUOn70
							Aadd(aIte[nI],{"TOKEDI",PlsPtuGet("TOKEN",aDados)})
							Aadd(aIte[nI],{"PROTOC",PlsPtuGet("PROT_ATEND",aDados)})
						EndIf

						BR8->(DbSetOrder(1))
						If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
							If lPTUOn80
								// 18 = TUSS Taxas hospitalares,diárias e gases medicinais
								// 19 = TUSS Materiais
								// 20 = TUSS Medicamentos
								// 22 = TUSS Procedimentos e eventos em saúde(medicina,odonto e demais áreas de saúde)
								// 98 = Tabela Própria de Pacotes
								// 00 = Tabela Própria das Operadoras
								TpTab := PtTpTabTus(,,.T.)
							Else
								//0=Procedimento							(0=AMB)
								//1=Material	    						(2=Material)
								//2=Medicamento							(3=Medicamento)
								//3=Taxas									(1=Hospitalar)
								//4=Diarias								(1=Hospitalar)
								//5=Ortese/Protese					  		(1=Hospitalar)
								//6=Pacote 								(1=Hospitalar)
								TpTab := Iif(BR8->BR8_TPPROC=='0' .Or. BR8->BR8_TPPROC==' ','0',Iif(BR8->BR8_TPPROC=='1','2',Iif(BR8->BR8_TPPROC=='2','3',Iif(BR8->BR8_TPPROC=='6','4','1') ) ) )
							EndIf
							//Se for diraria e uma internacao ou quando o tipo da guia for 3 - Internação
							If (BR8->BR8_TPPROC == '4' .And. !lEvoSadt) .Or. (PlsPtuGet("TP_GUIA",aDados) == "3" .And. !lEvoSadt)
								lIntern := .T.
								cTipo	:= "3"
								cDescTran := "INTERNACAO"
							EndIf
						EndIf

						If lPTUOn80 .And. TpTab == "98"
							aAdd(aIte[nI], {"CDPACOTE",PlsPtuGet("CD_SERVICO",aItens[nI])})
							aAdd(aIte[nI], {"QTPACOTE",PlsPtuGet("QT_SERVICO",aItens[nI])})
							PlsPtuPut("UNIORI", PlsPtuGet("CD_UNI_ORI",aDados),aDados)
						EndIf

						//se e procedimento cirurgico
						AaDd(aIte[nI],{"PROCCI",If(BR8->BR8_TIPEVE$"2,3","1","0") })

						//Mostra o Log
						PlsPtuLog("codigoServico => "+PlsPtuGet("CD_SERVICO",aItens[nI])+' - '+PlsPtuGet("QT_SERVICO",aItens[nI]) )

						//Tipo do evento 1=Clinico;2=Cirurgico;3=Ambos
						Do Case
							Case PlsPtuGet("TP_INTERNA",aDados) == "1" //1 = Internação Clínica
								cTipInt := "1"
							Case PlsPtuGet("TP_INTERNA",aDados) == "2" //2 = Internação Cirúrgica
								cTipInt := "2"
							Case PlsPtuGet("TP_INTERNA",aDados) == "3" //3 = Internação Obstétrica
								cTipInt := "3"
							Case PlsPtuGet("TP_INTERNA",aDados) == "6" //6 = Internação Pediátrica
								cTipInt := "4"
							Case PlsPtuGet("TP_INTERNA",aDados) == "7" //7 = Internação Psiquiátrica
								cTipInt := "5"
						EndCase


						//Informa o codigo da transacao para tratativa de complemento
						AaDd(aIte[nI],{"TRAITEPTU",cTranOri})

						//Decricao do OPME
						If !Empty(PlsPtuGet(cTagOPME,aItens[nI]))   //Descricao do procedimento de ortese/protese e material
							AaDd(aIte[nI],{"DESCOPME",PlsPtuGet(cTagOPME,aItens[nI])})
							AaDd(aOpme,{PlsPtuGet("CD_SERVICO",aItens[nI]),PlsPtuGet(cTagOPME,aItens[nI])})
						EndIf

						//Alimenta indicador de valor
						If !Empty(PlsPtuGet("VL_SERVICO",aItens[nI]))
							AaDd(aIte[nI],{"VLRAPR", Val(PlsPtuGet("VL_SERVICO",aItens[nI]))/1/nQtd})
						EndIf

					Next

					//Implementa qtd de diarias para internacao
					PlsPtuPut("TPEVEN",cTipInt,aDados)
					PlsPtuPut("INTERN",lIntern,aDados)
					PlsPtuPut("TIPO",cTipo,aDados)
					PlsPtuPut("TIPPAC",GetNewPar("MV_PTTPPAC",""),aDados)

					//Verifica se a solicitando esta com o codigo de transacao repetido
					If !lNMonit .And. VerReenvio(cTranOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTranOri) ),cTpTran,cOpeSol)
						If PlsAliasExi("B93")
							DelTranB93(cOpeSol,cTpTran,cTranOri)
						EndIf
						Return
					EndIf

					// Regra para Autorização de Internações Clinicas de Urgência e Emergência
					If GetNewPar("MV_PTINTUR", .F.)

						If cTpTran == "00605" .And. PLSRETDAD(aDados, "EVOLU", .F.) // Prorrogação de Internação

							aDadosInternacao := PlsGetBSA(cNrTrol, cOpeSol)

							If Len(aDadosInternacao[1]) > 0
								lInterClinica := PlsPtuGet("TP_INTERNA", aDadosInternacao[1]) == "1"
								lUrgenEmergen := PlsPtuGet("ID_URG_EME", aDadosInternacao[1]) == "S" 
								lGuiaInternacao := PlsPtuGet("TP_GUIA", aDadosInternacao[1]) == "3"
							EndIf
														
						Else
							lInterClinica := cTipInt == "1"
							lUrgenEmergen := PlsPtuGet("ID_URG_EME", aDados) == "S"
							lGuiaInternacao := PlsPtuGet("TP_GUIA", aDados) == "3"
						EndIf

						If lInterClinica .And. lUrgenEmergen .And. lGuiaInternacao
							PlsPtuPut("INTCLIURG", .T., aDados)
						EndIf

					EndIf

					//Entra no processo de autorizacao
					PlsPtuLog("***********************************")
					PlsPtuLog("INICIO DA AUTORIZACAO - ( "+cDescTran+" )")
					PlsPtuLog("***********************************")
					PlsPtuLog("Processando.....")

					if !lNMonit
						PlsPtuLog("***********************************")
						PlsPtuLog("Gerando Resposta Monitoramento     ")
					endIf

					cTmpPro 	:= Time()

					//Vai processar somente se nao for uma acao de monitoramento
					if !lNMonit

						lConsulta := PtAteCons(aIte)

						//somente se nao for uma order de servico de internacao
						if !lConfOSInt
							aRet := PLSXAUTP(aDados,aIte)
						endIf

						//Gera guia de anexo se houver
						if lAnexo .and. PlsAliasExi("B4A")

							nPosAnexo := ascan(aIte[1], {|X|, X[1] == 'TP_ANEXO'})
							aIte 	 := aSort(aIte,,, { |x, y|  x[nPosAnexo,2] < y[nPosAnexo,2] })
							cOld		 := '0'
							aIteAnexo := {}

							If cTpTran == "00605"
								BEA->( DbSetOrder(22) )
								If BEA->( msSeek( xFilial("BEA") + cNrTrol + cOpeSol ) )
									cGuiAneOri := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
								EndIf
							EndIf

							for nI := 1 to len(aIte)

								cTpAnexo := PlsPtuGet("TP_ANEXO",aIte[nI])

								if cTpAnexo $ "1,2,3"

									if cTpAnexo <> cOld

										cOld := cTpAnexo

										if len(aIteAnexo)>0

											If GetNewPar("MV_PLTHANE","0") == "1"
												aThreads := {}
												StartJob("PLANEPTUOT",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,aDados,aIteAnexo,aQuimio,aRadio,iif(cTpTran == "00605",cGuiAneOri,aRet[2]) ,dDataAt,.T.,cTpTran,cCodUsu)
											Else
												PLANEPTUOT(nil,nil,nil,aDados,aIteAnexo,aQuimio,aRadio,iif(cTpTran == "00605",cGuiAneOri,aRet[2]),dDataAt,.F.,cTpTran,cCodUsu)
											EndIf

										endIf

										aIteAnexo := {}
									endIf

									aadd(aIteANexo,aIte[nI])

								endIf

							next

							if len(aIteAnexo)>0
								If GetNewPar("MV_PLTHANE","0") == "1"
									aThreads := {}
									StartJob("PLANEPTUOT",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,aDados,aIteAnexo,aQuimio,aRadio,iif(cTpTran == "00605",cGuiAneOri,aRet[2]),dDataAt,.T.,cTpTran,cCodUsu)
								Else
									PLANEPTUOT(nil,nil,nil,aDados,aIteAnexo,aQuimio,aRadio,iif(cTpTran == "00605",cGuiAneOri,aRet[2]),dDataAt,.F.,cTpTran,cCodUsu)
								EndIf
							endIf

						endIf
					else
						aCriticas 	:= {}
						aEventosNeg 	:= {}

						PLSPOSGLO(PLSINTPAD(),__aCdCri011[1],__aCdCri011[2])
						AaDd( aCriticas,{"001",__aCdCri011[1],PLSBCTDESC(),cCodPad,cCodPro} )
						AaDd( aEventosNeg,{"001",cCodPad,cCodPro,0,"",0} )

						aRet := {	.F.,; 			// 1
							"",;   			// 2
							"",;			// 3
							aCriticas,; 	// 4
							{},;        	// 5
							aEventosNeg,;   // 6
							0,;             // 7
							"",;            // 8
							"",;            // 9
							{}}             // 10
					endIf

					PlsPtuLog("***********************************")
					PlsPtuLog("Tempo de processamento : "+ElapTime(cTmpPro,Time())+" (Inicio: "+cTmpPro+" Fim : "+Time()+" )")
					PlsPtuLog("***********************************")
					PlsPtuLog("INICIO DA RESPOSTA")
					PlsPtuLog("***********************************")

					PlsPtuPut("CD_TRANS","00501",aDados)

					//Gravacao do arquivo de solicitacoes de ptu online BSA
					If !lNMonit
						PLSGrvIEOL(aDados, aIte, AllTrim(cTranOri), cOpeSol)
						PlsPtuPut("DT_VALIDAD",Dtos(aRet[14]),aDados)
						PlsPtuPut("NR_VERSAO", cVerPTUOnline, aDados)

						If lPTUOn90
							PlsPtuPut("NR_IDADE", cValToChar(Calc_Idade(dDataBase, BA1->BA1_DATNAS)), aDados)

							If BA1->(FieldPos("BA1_NOMSOC")) > 0 .And. !Empty(BA1->BA1_NOMSOC)
								PlsPtuPut("NM_NOMSOC", Alltrim(BA1->BA1_NOMSOC), aDados)
							EndIf
						Else
							PlsPtuPut("DT_NASC", DtoS(BA1->BA1_DATNAS),aDados)
						EndIf

						PlsPtuPut("TP_SEXO",IIf(BA1->BA1_SEXO == "1", "1", "3"), aDados)
					EndIf


					//Ponto de entrada para troca de procedimento
					If lPLPtuIte
						For nX := 1 to Len (aRet[4])
							aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{aRet[4][nX][5],"RECSAI","",NIL,aRet[4][nX][4],cTranOri,nil})
							aRet[4][nX][5] := aPlPtuIte[2]
						Next
					Else
						If lPTUOn80 // De-para pela tabela BTU (Terminologia TISS)
							For nX := 1 to Len (aRet[4])
								If aRet[4][nX][5] == cPacoteGen
									nBuscPacote := aScan(aPacoteGuia,{ |x| Val(x[1]) == Val(aRet[4][nX][1]) })
									If nBuscPacote > 0
										aRet[4][nX][5] := aPacoteGuia[nBuscPacote][2]
									EndIf
								Else
									aRetBTU := PTUDePaBTU(nil,aRet[4][nX][5],aRet[4][nX][4],.F.,.T.,.T.)
									If len(aRetBTU) > 0
										aRet[4][nX][5] := aRetBTU[2]
									EndIf
								EndIf
							Next
						Else
							//De-Para AMB/CBHPM para ajuste de criticas
							If lConverProc .And. len(aRet[4]) > 0
								For nX := 1 to Len (aRet[4])
									PLBusProTab(aRet[4][nX][5],.F.,,,lConverProc,,,cCodPad,cCodPad2)
									If BR8->(Found())
										aRet[4][nX][5] := Alltrim(BR8->BR8_CODPSA)
									EndIf
								Next

								//Utiliza o De/Para BR8_CODEDI ou tabela B1M
							ElseIf GetNewPar("MV_PTDPION","0") == "1"
								For nX := 1 to Len (aRet[4])
									aRet[4][nX][5] := PLDeParINT(cCodPad,aRet[4][nX][5],dDataAt,,"E")
								Next

								//Realiza De/Para com a tabela de terminologias TISS BTU
							ElseIf GetNewPar("MV_PTDPION","0") == "2"
								For nX := 1 to Len (aRet[4])
									aRetBTU := PTUDePaBTU(nil,aRet[4][nX][5],aRet[4][nX][4],.F.,.T.)
									If len(aRetBTU) > 0
										aRet[4][nX][5] := aRetBTU[2]
									EndIf
								Next
							EndIf
						EndIf
					EndIf
					If cTpTran $ '00600-00605-00404' .And. !lNMonit
						If (nPos := aScan(aDados,{|x|x[1] == "NM_BENEF"})) > 0
							If Empty (aDados[nPos][2])
								aDados[nPos][2]:=cNomUsr
							EndIf
						EndIf
					EndIf

					//Retorna o numero da senha/transacao
					If cTpTran == "00600"
						PlsPtuPut("NR_IDENT_D",Strzero(Val(aRet[3]),10),aDados)

						//Tipo de acomodacao
						If !lNMonit
							PlsPtuPut("TP_ACOMODA",IIf(ValType(aRet[10])=="A",aRet[10][1],"X"),aDados)
						Else
							PlsPtuPut("TP_ACOMODA",Space(1)+"A",aDados)
						EndIf
					ElseIf cTpTran == "00605"

						cSql := " SELECT BQV_NRAOPE FROM "+RetSqlName("BQV")
						cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV") +"' "
						cSql += " AND BQV_NRTROL = '"+PadL(PlsPtuGet("NR_IDENT_O",aDados),10,"0")+"' "
						cSql += " AND D_E_L_E_T_ <> '*' "

						cSql := ChangeQuery(cSql)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpBQV",.T.,.F.)

						TmpBQV->(DbGotop())
						While !TmpBQV->( Eof() )
							If !Empty(TmpBQV-> BQV_NRAOPE) .And. Val(TmpBQV-> BQV_NRAOPE) <> 0
								cSenhaAut := TmpBQV-> BQV_NRAOPE
								Exit
							EndIf
							TmpBQV->( DbSkip() )
						EndDo
						TmpBQV->( dbClosearea() )

						PlsPtuPut("NR_IDENT_D",Strzero(Val(cSenhaAut),10),aDados)

					EndIf

					//Tipo de acomodacao
					If !lNMonit
						PlsPtuPut("TP_ACOMODA",IIf(ValType(aRet[10])=="A",aRet[10][1],"X"),aDados)
					Else
						PlsPtuPut("TP_ACOMODA",Space(1)+"A",aDados)
					EndIf
					PlsPtuPut("TP_AUTORIZ","1",aDados)

					//Se Autorizado ou Nao
					cAt := Iif(aRet[1],"2","1")

					//Ajusta Criticas
					If Len(aRet[4]) > 0
						For nI := 1 To Len(aRet[4])
							If !Empty(aRet[4,nI,2])

								//se nao existe a sequencia e a critica
								If aScan( aRetCri, { |x| ( x[1]+x[2]+x[4] ) == ( aRet[4,nI,1]+aRet[4,nI,2]+aRet[4,nI,5] ) } ) == 0
									nPosDesGen := 0
									cDescGen   := ""
									if Alltrim(aRet[4,nI,5]) $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen
										nPosDesGen := AScan(aRet[6],{|x| x[1] == aRet[4,nI,1] })
										cDescGen := aRet[6,nPosDesGen,5]
									endIf

									AaDd( aRetCri,{aRet[4,nI,1],aRet[4,nI,2],aRet[4,nI,3],aRet[4,nI,5],IIf(len(aRet[4,ni])>7 .And. aRet[4,nI,8,1],aRet[4,nI,8,2],""),cDescGen } )
								EndIf
							EndIf
						Next
					EndIf

					//Novas regras PTU Online 3.5, casos que vao para auditoria:
					//- OPME preenchido
					//- Procedimento de Alto Custo
					//- Data de atendimento diferente da Database
					//- Procedimento do tipo pacote (TP_TABELA "4")
					If (aScan(aRetCri,{ |x| x[2] == __aCdCri203[1]} ) > 0  .Or. ;				//OPME
							aScan(aRetCri,{ |x| x[2] == __aCdCri104[1]} ) > 0  .Or. ;				//Alto Custo
							aScan(aRetCri,{ |x| x[2] == __aCdCri106[1]} ) > 0  .Or. ;				//Data de Atendimento diferente
							aScan(aRetCri,{ |x| x[2] == __aCdCri200[1]} ) > 0  .Or. ;				//Pacote
							aScan(aRetCri,{ |x| x[2] == __aCdCri202[1]} ) > 0) .And. !lA1100//DS_OBSERVA informado

						lAudito := .T.
						cAt 	  := "3"
					EndIf


					//Verifico se tem alguma critica que manda para auditoria (Urgencia/Emergencia nao posso enviar)
					If cAt <> "3" .And. Len(aRetCri) > 0 .And. BCT->( FieldPos("BCT_AUDITO") ) > 0

						BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
						For nX := 1 To Len(aRetCri)

							// Este trecho trata a regra de atendimento de urgencia/emergencia nao poderem
							// enviar o atedimento para Auditoria. A unica excecao sao as criticas indicadas
							// no parametro MV_PTAUDUR
							if PlsPtuGet("ID_URG_EME",aDados) == "S" .And. !(aRetCri[nX,2] $ cCriUrgAud)
								loop
							endIf

							//Verifica se ha resposta ja definida (solicitacao valor inferior a 6 cons.
							If !Empty(aRetCri[nX,5] )
								If aRetCri[nX,5] == "1"
									lAudito := .T.
									cAt     := "3"
									Exit
								EndIf
							Else

								//Verifico se e Auditoria ou Empresa
								If (aRetCri[nX,2] == __aCdCri051[1] .Or. aRetCri[nX,2] == __aCdCri052[1]) .And. !lA1100
								If aScan(aRetCri,{ |x| x[2] == __aCdCri051[1]} ) > 0
									lAudito := .T.
								Else
									lAudEmp := .T.
								EndIf
								cAt := "3"
							EndIf

							If BCT->( MsSeek( xFilial("BCT")+PlsIntPad()+aRetCri[nX,2] ) ) .And. !lA1100 .And. !lAudEmp
								If BCT->BCT_AUDITO == "1"
									lAudito := .T.
									cAt 	:= "3"
									Exit
								EndIf
							EndIf
						EndIf
						Next
					EndIf

					//Limpa a critica
					cCodCri := ""

					//Atualiza a critica do cabecalho
					If Len(aRetCri) > 0 .And. cAt <> "2"

						//For de criticas
						For nJ := 1 To 5

							//Pega a Critica
							If nJ <= Len(aRetCri)
								cCodCri := aRetCri[nJ,2]
							EndIf

							//Verifica se e critica de outro procedimento
							If nJ <= Len(aRetCri) .And. aScan( aRetGer , { |x| x == cCodCri } ) == 0

								//Verifica se e auditoria ou autorizacao empresa
								If lAudito
									cAt := "4"
								ElseIf lAudEmp
									cAt := "3"
								Else
									cAt := "1"
								EndIf

								//Se for critica de cabecalho mostra
								If lCriCab
									PlsPtuLog( "CRITICA =>" + AllTrim( RetCodEdi(cCodCri) + " - " + AllTrim( Upper( aRetCri[nJ,3] ) ) ) )
									If RetCodEdi(cCodCri) == '0000'
										PlsPtuLog("AJUSTE CRITICA => SISTEMA - " + AllTrim( cCodCri ) + " PTU - CAMPO BCT_CODED2 - " + RetCodEdi(cCodCri) )
									EndIf
								EndIf
							EndIf

							//Para nao repetir a critica
							AaDd(aRetGer,cCodCri)
						Next
					EndIf

					//Limpa para os itens
					cCodCri := ""
					cAtIt   := ""

					//For para atualizacao dos itens (procedimentos)
					If lAudito .Or. lAudEmp
						If lAudito
							cCodCri := __aCdCri051[1]
							cDesCri := PLSBCTDESC()
							cAt     := "4"
						Else
							cCodCri := __aCdCri052[1]
							cDesCri := PLSBCTDESC()
							cAt     := "3"
						EndIf

						//Itens
						nOpme := 1
						For nI := 1 to Len(aItens)

							// descricaoServico - Mandatório apenas para Codificações Genéricas, para demais codificações, o campo não deverá ser preenchido.
							If !lPTUOn90 .Or. Alltrim(PlsPtuGet("CD_SERVICO", aItens[nI])) $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen				

								//Atualizo a descricao do servico
								If Len(aOpme)>0 .And. Alltrim(aOpme[nOpme][1]) == Alltrim(PlsPtuGet("CD_SERVICO",aItens[nI]))
									PlsPtuPut("DS_SERVICO",aOpme[nOpme][2],aItens[nI]) //Descricao do procedimento
									If nOpme <len(aOpme)
										nOpme ++
									Endif
								Else

									//Ponto de entrada para troca de procedimento
									If lPLPtuIte
										aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aItens[nI]),"RECDES","",PlsPtuGet("TP_TABELA",aItens[nI]),nil,cTranOri,nil})
										PlsPtuPut("DS_SERVICO",PadR(aPlPtuIte[3],80),aItens[nI])
									Else
										// De-para pela tabela BTU (Terminologia TISS)
										If lPTUOn80
											If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados))
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cPacoteGen,,.T.,,.T.)
											Else
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),PlsPtuGet("CD_SERVICO",aItens[nI]),,.T.,,.T.)
											EndIf
											If len(aRetBTU) > 0
												PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nI]) //Descricao do procedimento
											Else
												//Se nao achou o De/Para, faz a pesquisa normal do sistema
												If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
													PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
													If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
														aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
													EndIf
												Else
													PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
												EndIf
											EndIf
										Else
											BR8->(DbSetOrder(1))

											//Utiliza o De/Para BR8_CODEDI ou tabela B1M
											If GetNewPar("MV_PTDPION","0") == "1"

												PLBusProTab(PlsPtuGet("CD_SERVICO",aItens[nI]),.F.,,dDataAt,,,,,)

												If BR8->(Found())
													PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
													If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
														aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
													EndIf
												Else

													//Se nao achou o De/Para, faz a pesquisa normal do sistema
													If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
														PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
														If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
															aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
														EndIf
													Else
														PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
													EndIf
												EndIf

												//Utiliza o De/Para BR8_CODEDI ou tabela BTU
											ElseIf GetNewPar("MV_PTDPION","0") == "2"
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),PlsPtuGet("CD_SERVICO",aItens[nI]),,.T.)
												If len(aRetBTU) > 0
													PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nI]) //Descricao do procedimento
												Else

													//Se nao achou o De/Para, faz a pesquisa normal do sistema
													If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
														PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
														If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
															aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
														EndIf
													Else
														PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
													EndIf
												EndIf

												//Faz a pesquisa normal do sistema
											ElseIf BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
												PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
												If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
													aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
												EndIf
											Else
												PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf

							lFirst := .T.
							For nJ := 1 To 5

								//Criticas do procedimento
								//NOVA REGRA -> SEGUNDO A UNIMED, NAO ENVIAR CODIGO DE CRITICA QUANDO FOR ENVIADO A GUIA A AUDITORIA
								PlsPtuPut("CD_MENS_E"+AllTrim(Str(nJ)),'0000',aItens[nI])  //ANTIGA REGRA -> PlsPtuPut("CD_MENS_E"+AllTrim(Str(nJ)),RetCodEdi(cCodCri),aItens[nI])			Codigo da Critica

								If RetCodEdi(cCodCri) == '0000'
									PlsPtuLog("AJUSTE CRITICA => SISTEMA - " + AllTrim( cCodCri ) + " PTU - CAMPO BCT_CODED2 - " + RetCodEdi(cCodCri) )
								EndIf

								//Mostra o log
								If lFirst

									//Se nao tiver na matriz de criticas
									If aScan(aRetCri,{ |x| x[4] == PlsPtuGet( "CD_SERVICO",aItens[nI] ) } ) == 0
										PlsPtuLog("codigoServico =>" + IIf(lConverProc,cCodPad2,cCodPad) + '-' + AllTrim( PlsPtuGet("CD_SERVICO",aItens[nI] ) ) + " - AUTORIZADO" )
									Else
										PlsPtuLog("codigoServico =>" + IIf(lConverProc,cCodPad2,cCodPad) + '-' + AllTrim( PlsPtuGet( "CD_SERVICO",aItens[nI] ) ) + " - " + Upper( AllTrim( PlsPtuGet("DS_SERVICO",aItens[nI] ) )+ " - NEGADO - " + AllTrim( PlsPtuGet( "CD_MENS_E"+AllTrim( Str(nJ) ),aItens[nI] ) ) ) )
									EndIf
									lFirst := .F.
								EndIf
							Next

							//Se autorizou ou nao
							PlsPtuPut("ID_AUTORIZ",cAt,aItens[nI])
							If cAt <> '2' .And. !Empty(cAt)
								PlsPtuPut("NR_IDENT_D","",aDados)

								//Versao 7.0 so envio quantidade dos itens se o mesmo estiver autorizado
								If lPTUOn70 .And. (nPos := Ascan(aItens[nI],{|x|x[1] == "QT_SERVICO"}) ) > 0
									aItens[nI][nPos][2]	:= 0
								EndIf
							EndIf

						Next
					Else
						nOpme := 1
						For nI := 1 to Len(aItens)

							//Pega a posicao do procedimento negado
							If Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen
								nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4])+Alltrim(x[6]) == Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) + Alltrim(PlsPtuGet( "DS_SERVICO",aItens[nI] )) } )
							Else
								If PlsPtuGet("TP_TABELA",aItens[nI]) == "00"
									nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4]) == Substr(Alltrim(PlsPtuGet("CD_SERVICO", aItens[nI])),3) .And.;
										Val(x[1]) == Val(PlsPtuGet("SQ_ITEM", aItens[nI]))})
								Else
									nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4]) == Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) .And.;
										Val(x[1]) == Val(PlsPtuGet("SQ_ITEM", aItens[nI]))})
								EndIf
							EndIf
							lCriticou := .F.

							// descricaoServico - Mandatório apenas para Codificações Genéricas, para demais codificações, o campo não deverá ser preenchido.
							If !lPTUOn90 .Or. Alltrim(PlsPtuGet("CD_SERVICO", aItens[nI])) $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen

								//Atualizo a descricao do servico
								If Len(aOpme) >0 .And. Alltrim(aOpme[nOpme][1]) == Alltrim(PlsPtuGet("CD_SERVICO",aItens[nI]))
									PlsPtuPut("DS_SERVICO",aOpme[nOpme][2],aItens[nI]) //Descricao do procedimento
									If nOpme <len(aOpme)
										nOpme ++
									Endif
								Else
									If lPLPtuIte
										aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aItens[nI]),"RECDES","",nil,nil,cTranOri,nil})
										PlsPtuPut("DS_SERVICO",PadR(aPlPtuIte[3],80),aItens[nI])
									Else
										// De-para pela tabela BTU (Terminologia TISS)
										If lPTUOn80
											If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados))
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cPacoteGen,,.T.,,.T.)
											Else
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),PlsPtuGet("CD_SERVICO",aItens[nI]),,.T.,,.T.)
											EndIf
											If len(aRetBTU) > 0
												PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nI]) //Descricao do procedimento
											Else
												//Se nao achou o De/Para, faz a pesquisa normal do sistema
												If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
													PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
													If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
														aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
													EndIf
												Else
													PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
												EndIf
											EndIf
										Else
											//Utiliza o De/Para BR8_CODEDI ou tabela B1M
											If GetNewPar("MV_PTDPION","0") == "1"
												PLBusProTab(PlsPtuGet("CD_SERVICO",aItens[nI]),.F.,,dDataAt,,,,,)
												If BR8->(Found())
													PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
													If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
														aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
													EndIf
												Else

													//Se nao achou o De/Para, faz a pesquisa normal do sistema
													If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
														PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
														If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
															aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
														EndIf
													Else
														PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
													EndIf
												EndIf

												//Realiza De/Para com a tabela de terminologias TISS BTU
											ElseIf GetNewPar("MV_PTDPION","0") == "2"
												aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),PlsPtuGet("CD_SERVICO",aItens[nI]),,.T.)
												If len(aRetBTU) > 0
													PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nI]) //Descricao do procedimento
												Else

													//Se nao achou o De/Para, faz a pesquisa normal do sistema
													If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
														PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
														If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
															aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
														EndIf
													Else
														PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
													EndIf
												EndIf
											Else

												//Busca a descricao do evento
												BR8->(DbSetOrder(1))
												If BR8->(DbSeek(xFilial("BR8")+IIf(lConverProc,cCodPad2,cCodPad)+PlsPtuGet("CD_SERVICO",aItens[nI])))
													PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nI]) //Descricao do procedimento
													If BR8->(FieldPos("BR8_OBSEDI")) > 0 .And. !Empty(BR8->BR8_OBSEDI)
														aAdd(aObsReturn,Alltrim(BR8->BR8_OBSEDI))
													EndIf
												Else
													PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nI]) //Descricao do procedimento
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf

							EndIf


							//Se nao tiver critica para o procedimento
							If nPosCri == 0 .And. !lCriCab
								cAt := "2"
							EndIf

							//Alimenta criticas
							If nPosCri > 0 .Or. lCriCab
								lCriticou := .T.
								For nJ := 1 To 5

									//Negado
									If nPosCri > 0 .Or. lCriCab
										cAt := "1"
									EndIf

									//Criticas do procedimento
									If nPosCri > 0
										PlsPtuPut("CD_MENS_E"+AllTrim(Str(nJ)),RetCodEdi(aRetCri[nPosCri,2]),aItens[nI])	//Codigo da Critica
										If RetCodEdi(aRetCri[nPosCri,2]) == '0000'
											PlsPtuLog("AJUSTE CRITICA => SISTEMA - " + AllTrim(aRetCri[nPosCri,2]) + " PTU - CAMPO BCT_CODED2 - " + RetCodEdi(aRetCri[nPosCri,2]) )
										EndIf
									ElseIf lCriCab
										If nJ <= Len(aRetCri)
											PlsPtuPut("CD_MENS_E"+AllTrim(Str(nJ)),RetCodEdi(aRetCri[nJ,2]),aItens[nI])	//Codigo da Critica
											If RetCodEdi(aRetCri[nJ,2]) == '0000'
												PlsPtuLog("AJUSTE CRITICA => SISTEMA - " + AllTrim(aRetCri[nJ,2]) + " PTU - CAMPO BCT_CODED2 - " + RetCodEdi(aRetCri[nJ,2]) )
											EndIf
										EndIf
									EndIf

									//Mostra o log
									If !Empty( PlsPtuGet( "CD_MENS_E"+AllTrim( Str(nJ) ),aItens[nI] ) ) .And. !lCriCab
										PlsPtuLog("SERVICO =>" +IIf(lConverProc,cCodPad2,cCodPad)+ '-' + AllTrim( PlsPtuGet( "CD_SERVICO",aItens[nI] ) ) + " - " + Upper( AllTrim( PlsPtuGet("DS_SERVICO",aItens[nI] ) ) + " - NEGADO - " + AllTrim( PlsPtuGet( "CD_MENS_E"+AllTrim( Str(nJ) ),aItens[nI] ) ) ) )
									EndIf

									//Altera o codigo do procedimento para nao pegar novamente
									If nPosCri > 0
										aRetCri[nPosCri,4] := aRetCri[nPosCri,4]+'*'
										aRetCri[nPosCri,1] := aRetCri[nPosCri,1]+'*'
									EndIf

									//Adiciona msg de critica (somente a primeira)
									If nPosCri > 0 .And. nJ == 1
										PlsPtuPut("DS_MENS_ES",Padr(aRetCri[nPosCri][3],500),aItens[nI])
									EndIf

									//Pega outra critica
									If nPosCri > 0
										If Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen
											nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4])+Alltrim(x[6]) == Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) + Alltrim(PlsPtuGet( "DS_SERVICO",aItens[nI] )) } )
										Else
											If PlsPtuGet("TP_TABELA",aItens[nI]) == "00"
												nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4]) == Substr(Alltrim(PlsPtuGet("CD_SERVICO", aItens[nI])),3) .And.;
													Val(x[1]) == Val(PlsPtuGet("SQ_ITEM", aItens[nI]))})
											Else
												nPosCri := aScan(aRetCri,{ |x| Alltrim(x[4]) == Alltrim(PlsPtuGet( "CD_SERVICO",aItens[nI] )) .And.;
													Val(x[1]) == Val(PlsPtuGet("SQ_ITEM", aItens[nI]))})
											EndIf
										EndIf
									EndIf
								Next
							EndIf

							//Se autorizou ou nao
							PlsPtuPut("ID_AUTORIZ",cAt,aItens[nI])

							//Mostra log de Autorizacao
							If cAt == "2" .Or. !lCriticou
								PlsPtuLog("codigoServico =>" + IIf(lConverProc,cCodPad2,cCodPad) + '-' + AllTrim( PlsPtuGet("CD_SERVICO",aItens[nI] ) ) + " - AUTORIZADO" )
							EndIf

							//Versao 7.0 so envio quantidade dos itens se o mesmo estiver autorizado
							If lPTUOn70 .And. cAt != "2" .And. (nPos := Ascan(aItens[nI],{|x|x[1] == "QT_SERVICO"}) ) > 0
								aItens[nI][nPos][2]	:= 0
							EndIf
						Next
					EndIf

					//Informa observacao para PTU 5.0
					If len(aObsReturn) > 0
						For nJ := 1 to len(aObsReturn)
							cObsReturn := cObsReturn + aObsReturn[nJ]
						Next
						PlsPtuPut("DS_LINHA_O",cObsReturn,aDados)
					EndIf


					PlsPtuLog("")

					Do Case
						Case Len( aRet[4] ) == 0
							PlsPtuLog("*** AUTORIZADO ***")
							cRetA1100 := "Autorizado"
						Case Len( aRet[4] ) > 0 .And. Len( aRet[5] ) > 0 .And. !lAudito .And. !lAudEmp
							PlsPtuLog("*** AUTORIZADO PARCIAL ***")
							cRetA1100 := "Autorizado Parcial"
						Case (Len( aRet[4] ) > 0 .And. Len( aRet[5] ) == 0) .Or. lAudito .Or. lAudEmp
							If cAt == "3" .Or. cAt == "4"
								PlsPtuLog("*** AUTORIZADO PENDENTE DE (AUDITORIA OU AUTORIZACAO DA EMPRESA) ***")
								cRetA1100 := "Autorizado Pendente (Auditoria)"
							Else
								PlsPtuLog("*** NAO AUTORIZADO ***")
								cRetA1100 := "Não Autorizado"
							EndIf
					EndCase

					//Carrega array de retorno para A1100
					If lA1100 .And. len(aRet) > 1 .And. ValType(aRet[2]) <> 'U'
						Aadd(aRetA1100,{aRet[2],cRetA1100})
					EndIf

					If Len(aRet[4]) > 0
						PlsPtuLog("***")
						For nI := 1 to len(aRet[4])
							If !Empty(aRet[4,nI,2])
								PlsPtuLog("*** CRITICA BCT -> "+aRet[4,nI,2]+" - "+aRet[4,nI,3])
							EndIf
						Next
						PlsPtuLog("***")
					EndIf
				Else


					PlsPtuLog("VERIFICAR A RDA")
					PlsPtuLog("*** NAO AUTORIZADO ***")

					//Implementa na matriz adados numero da transacao de retorno (mesma da solic.)
					PlsPtuPut("NR_IDENT_D",cTranOri,aDados)
					PlsPtuLog(aRetRDA[2])

					//Negada
					For nI := 1 to Len(aItens)
						cCodPro  	:= PlsPtuGet("CD_SERVICO",aItens[nI])

						BR8->(DbSetOrder(1))
						If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
							PlsPtuPut("DS_SERVICO",Alltrim(BR8->BR8_DESCRI),aItens[nI])
						Else
							PlsPtuPut("DS_SERVICO","EVENTO NAO ENCONTRADO",aItens[nI])
						EndIf

						PlsPtuPut("ID_AUTORIZ","1",aItens[nI])

						//Critica
						PlsPtuPut("CD_MENS_E1","2041",aItens[1])
					Next
					aRet := {aRetRDA[1]}

					lGravaTran := .F.
					PlsPtuPut("TP_ACOMODA","X",aDados)

				EndIf

				//Pega a resposta da auditoria	e prepara para enviar a 00209/00309
			Case cTpTran == "00404"

				//Plsxmov
				PlsPtuPut("CHKREG",.F.,aDados)  // NAO CHECA REGRAS, POIS ERA AUDITORIA E FOI AUTORIZADO

				//Mostra o Log
				PlsPtuLog("codigoTransacao                => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente                    => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf
				PlsPtuLog("codigoUnimedPrestadora         => "+PlsPtuGet("CD_UNI_ORI",aDados))
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_DES",aDados))
				PlsPtuLog("numeroTransacaoPrestadora      => "+cTranOri)
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+PlsPtuGet("NR_IDENT_D",aDados))
				PlsPtuLog("mensagemLivre                     => "+PlsPtuGet("DS_LINHA_O",aDados))

				//Pega a Transacao original
				cResRev  := PlsPtuGet("DS_LINHA_O",aDados)

				//esta pegando da bsa e nao da B0T
				aDadSeq  	:= PlsGetBSA(cTranOri,PlsIntPad())
				aDadosAux := aClone(aDadSeq[1])

				//Envia 804 se nao for auditoria
				If (IIf(!lPTUOn90, PlsPtuGet("ID_ORDEM_S", aDadosAux) == "S", !Empty(PlsPtuGet("NR_IDE_OS", aDados))))

					//Busca BSA do solicitacao de Ordem de Servico
					aDados806 := PlsGetB0T(PlsPtuGet("NR_IDE_OS",aDadosAux),"00806",PlsIntPad(),2,"1")[1]

					cOpeSol   := PlsPtuGet("CD_UNI_SOL",aDados806)
					aIteOS    := aItens
					cSenhaOS  := PlsPtuGet("NR_IDENT_D",aDados)
					cDtValOS  := PlsPtuGet("DT_VALIDAD",aDados)

					If cOpeSol != cOpeDes .and. cOpeSol != PlsIntPad()
						cTraOriOS 	:= PlsPtuGet("NR_IDE_OS",aDadosAux)
						cTraPrest 	:= PadL(PlsPtuGet("NR_IDENT_O",aDadosAux),13,"0")
						cTraOriBen 	:= cSenhaOs
						l404Triang  := .T.

						aThreads := {}
						StartJob("PTUAUTOSV6",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,aDadosAux,aIteOS,cTraOriOS,cTraPrest,cTraOriBen,cDtValOS,cOpeSol)
					EndIf
				EndIf

				For nI := 1 To Len(aDadSeq[1])
					If AllTrim(aDadSeq[1,nI,1]) <> "CD_TRANS"
						PlsPtuPut(aDadSeq[1,nI,1],PlsPtuGet(aDadSeq[1,nI,1],aDadSeq[1]),aDados)
					EndIf
				Next

				//Verifica se a solicitando esta com o codigo de transacao repetido
				If VerReenvio(cTranOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTranOri) ),cTpTran,PlsPtuGet("CD_UNI_DES",aDados),2)
					If PlsAliasExi("B93")
						DelTranB93(cOpeSol,cTpTran,cTranOri)
					EndIf
					Return
				EndIf

				//Verifica nome do usario
				BA1->(DbSetOrder(5))
				If BA1->(dbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI_DES",aDados)+PlsPtuGet("USUARIO",aDados)))
					cNomUsr := BA1->BA1_NOMUSR
				EndIf

				//Pega e Mostra os procedimentos para processamento da resposta
				PlsPtuLog("PROCEDIMENTOS")
				PlsPtuLog("***********************************")
				aIte := {}

				For nI := 1 to Len(aItens)

					//Monta campos
					cOldDesCri := ""
					cCodPro := PlsPtuGet("CD_SERVICO",aItens[nI])

					//Ponto de entrada para troca de procedimento
					If lPLPtuIte
						aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECENT","",nil,nil,cTranOri,nil})
						cCodPro := aPlPtuIte[2]
					Else
						If lPTUOn80 // De-para pela tabela BTU (Terminologia TISS)
							If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_ORI",aDados))
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cPacoteGen,,.T.,,.T.)
							Else
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,,.T.,,.T.)
							EndIf
							If len(aRet) > 0
								cCodPad := aRet[1]
								cCodPro := aRet[2]
							EndIf
						Else
							//Realiza De/Para AMB/CBHPM
							If lConverProc
								PLBusProTab(cCodPro,.F.,,,.T.,,,cCodPad2,cCodPad )
								If BR8->(Found())
									cCodPro:= Alltrim(BR8->BR8_CODPSA)
								Endif
							EndIf

							//Realiza De/Para BR8_CODEDI ou tabela B1M
							If GetNewPar("MV_PTDPION","0") == "1"
								PLBusProTab(cCodPro,.F.,,dDataBase,,,,,)
								If BR8->(Found())
									cCodPad := BR8->BR8_CODPAD
									cCodPro := Alltrim(BR8->BR8_CODPSA)
								EndIf

								//Realiza De/Para com a tabela de terminologias TISS BTU
							ElseIf GetNewPar("MV_PTDPION","0") == "2"
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,,.T.)
								If len(aRet) > 0
									cCodPad := aRet[1]
									cCodPro := aRet[2]
								EndIf
							EndIf
						EndIf
					EndIf

					//Na versao 5.0 itens das tabelas 1, 2 e 3 utiliza 03 inteiros e 04 decimais
					nQtd := Val(PlsPtuGet("QT_SERVICO",aItens[nI]) )


					cAutori := PlsPtuGet("ID_AUTORIZ",aItens[nI])
					cSeq    := Strzero(Val(PlsPtuGet("SQ_ITEM",aItens[nI])),2)

					//Nova Matriz para ajuste no be2
					AaDd(aIte,{cCodPro,cAutori,nQtd,{},Alltrim(PlsPtuGet("DS_SERVICO",aItens[nI])),nil, Alltrim(PlsPtuGet("DS_MENS_ES",aItens[nI])),cSeq } )

					//Mostra o Log
					PlsPtuLog("codigoServico => "+PlsPtuGet("CD_SERVICO",aItens[nI]) )

					//Checa se nao foi autorizado
					If cAutori <> "2"

						//Mostra as criticas
						For nFor := 1 To 5

							//Pendente Auditoria ou autorizacao empresa
							If cAutori == "3" .Or. cAutori == "4"
								lUmAud	 := .T.
								If cAutori == "3"
									If PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2])
										cCodCri := __aCdCri052[1]
										cDesCri := PLSBCTDESC()
									EndIf
								Else
									If PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2])
										cCodCri := __aCdCri051[1]
										cDesCri := PLSBCTDESC()
									EndIf
								EndIf

								//Se a critica estiver disabled											  |

								If Empty(cCodCri)
									cCodCri := "999"
									cDesCri := "CRITICA DESABILITADA"
								EndIf

								//Negado																	  |

							ElseIf cAutori == "1"
								lUmNeg	 := .T.
								cCodCri := PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor)),aItens[nI])
								cDesCri := ""
								If cCodCri <> "0000"
									cDesCri := PlsRtcdCed(PlsIntPad(),cCodCri,3)
									cCodCri := PlsRtcdCed(PlsIntPad(),cCodCri,4)
									If !Empty(cDesCri)
										PLSPtuLog( "CRITICA " + cDesCri )
									EndIf
								EndIf
							EndIf

							//Implementa as criticas
							If !Empty(cDesCri) .And. cDesCri <> cOldDesCri
								AaDd( aIte[nI,4] ,{cCodCri,cDesCri,cAutori,PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor)),aItens[nI])} )
								cOldDesCri := cDesCri
							EndIf
						Next
					Else
						lUmAut	:= .T.
					EndIf
				Next

				//Vai processar a resposta
				PlsPtuLog("***********************************")
				PlsPtuLog("INICIO DO PROCESSAMENTO")
				PlsPtuLog("***********************************")
				PlsPtuLog("Processando.....")
				cTmpPro := Time()

				//Processa	alteracao no cabecalho,item e critica da guia (bea,be2 e beg)
				cRet := PLSACOMP(cTranOri,cTranDes,cResRev,aIte,cTpTran,cOpeSol,PlsPtuGet("DT_VALIDAD",aDados),nil,l404Triang)

				If !Empty(cRet) .And. SubStr(cRet,1,13) $ "FALHA ARQUIVO"
					PlsPtuLog(cRet)

					//lTimeOut e acionado quando ha um problema na composicao do arquivo
					lTimeOut   := .T.
					lGravaTran := .F.
					PlsPtuLog("***************************************************************************************")
					PlsPtuLog("FORAM ENCONTRADOS PROBLEMAS NO ARQUIVO PROCESSADO")
					PlsPtuLog("Nao foi possivel gerar arquivo 00309 de resposta")
					PlsPtuLog("***************************************************************************************")

					//Monta o 00309 com o TP_IDENTIF invalido "2"
					cOpeDes 	:= PlsPtuGet("CD_UNI_DES",aDados)
					aDados	:= {}
					aItens   := {}
					PlsPtuPut("CD_TRANS","00309",aDados)
					PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
					PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
					PlsPtuPut("NR_IDENT_D",cTranDes,aDados)
					PlsPtuPut("TP_IDENTIF",IIF(Empty(cRet),"1","2"),aDados)
				Else

					PlsPtuLog("")
					If !Empty(cRet)
						PlsPtuLog(cRet)
						lGravaTran := .F.
					EndIf

					//Verifica se algum ficou na auditoria ainda
					If Empty(cRet)
						Do Case
							Case lUmAut .And. !lUmNeg .And. !lUmAud
								PlsPtuLog("*** AUTORIZADO ***")
								cAutori := "1"
							Case lUmAut .And. lUmNeg .And. !lUmAud
								PlsPtuLog("*** AUTORIZADO PARCIALMENTE ***")
								cAutori := "2"
							Case !lUmAut .And. lUmNeg .And. !lUmAud
								PlsPtuLog("*** NAO AUTORIZADO ***")
								cAutori := "3"
							Case !lUmAut .And. !lUmNeg .And. lUmAud
								PlsPtuLog("*** AUTORIZADO PENDENTE DE (AUDITORIA OU AUTORIZACAO DA EMPRESA) ***")
								cAutori := "4"
						EndCase
					EndIf

					//Msg
					PlsPtuLog("***********************************")
					PlsPtuLog("Tempo de processamento : "+ElapTime(cTmpPro,Time())+" (Inicio: "+cTmpPro+" Fim : "+Time()+" )")
					PlsPtuLog("***********************************")

					PlsPtuLog("")

					//Vou gerar a resposta para a operadora com o registro 00209/00309
					PlsPtuLog("***********************************")
					PlsPtuLog("GERANDO RESPOSTA 00309")
					PlsPtuLog("***********************************")
					PlsPtuLog("Processando.....")

					cOpeDes 	:= PlsPtuGet("CD_UNI_DES",aDados)
					aDados	:= {}
					aItens   := {}
					PlsPtuPut("CD_TRANS","00309",aDados)
					PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
					PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
					PlsPtuPut("NR_IDENT_D",cTranDes,aDados)
					PlsPtuPut("TP_IDENTIF",IIF(Empty(cRet),"1","2"),aDados)

					//Mostra o Log
					PlsPtuLog("codigoTransacao                   => 00309")
					PlsPtuLog("codigoUnimedPrestadora            => "+PlsIntPad())
					PlsPtuLog("codigoUnimedOrigemBeneficiario    => "+cOpeDes)
					PlsPtuLog("numeroTransacaoPrestadora         => "+cTranOri)
					PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+cTranDes)
					PlsPtuLog("identificador                     => "+IIF(Empty(cRet),"1","2"))
					PlsPtuLog("***********************************")
					PlsPtuLog("GERADA RESPOSTA 00309")
					PlsPtuLog("***********************************")
				EndIf


				//Decurso de prazo
			Case cTpTran == "00700"

				//Mostra o Log
				If !lPTUOn90
					cTpCliente := PlsPtuGet("TP_CLIENTE",aDados)
				EndIf

				cTranOri   := allTrim(PlsPtuGet("NR_IDENT_E",aDados))
				cOpeSol    := allTrim(PlsPtuGet("CD_UNI_ORI",aDados))
				cOpeOri    := allTrim(PlsPtuGet("CD_UNI_DES",aDados))

				cOpeSol  := Strzero(Val(cOpeSol),4)
				cOpeOri  := Strzero(Val(cOpeOri),4)
				cTranOri := StrZero(Val(cTranOri),10)

				PlsPtuLog("codigoTransacao                => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente                    => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIF
				PlsPtuLog("codigoUnimedPrestadora         => "+PlsPtuGet("CD_UNI_ORI",aDados))
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_DES",aDados))
				PlsPtuLog("numeroTransacaoPrestadora      => "+cTranOri)

				//Vai processar a resposta
				PlsPtuLog("***********************************")
				PlsPtuLog("INICIO DO PROCESSAMENTO")
				PlsPtuLog("***********************************")
				PlsPtuLog("Processando.....")
				cTmpPro := Time()

				BEA->( dbSetOrder(22) )//BEA_FILIAL+BEA_NRTROL+BEA_OPESOL
				If BEA->( msSeek( xFilial("BEA") + cTranOri + Space( TamSX3("BEA_NRTROL")[1]-Len(cTranOri)) + cOpeSol ) )
					cAliasCab := 'BEA'
				Else
					BE4->( dbSetOrder(10) )
					If BE4->( msSeek( xFilial("BE4") + cTranOri + Space( TamSX3("BE4_NRTROL")[1]-Len(cTranOri)) + cOpeSol ) )
						cAliasCab := 'BE4'
					EndIf
				EndIf

				aDados   := {}
				aItens   := {}

				//montando resposta
				PlsPtuPut("CD_TRANS","00309",aDados)
				PlsPtuPut("CD_UNI_ORI",cOpeSol,aDados)
				PlsPtuPut("CD_UNI_DES",cOpeOri,aDados)
				PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
				PlsPtuPut("NR_IDENT_D",cTranOri,aDados)

				//log
				lGravaTran := .F.
				PlsPtuLog("GERANDO RESPOSTA 00309")
				PlsPtuLog("***********************************")

				if !empty(cAliasCab)

					//Processa	alteracao no cabecalho,item e critica da guia (bea,be2 e beg)
					cTranDes := ''
					cRet := PLSA090Dec(cAliasCab,cTranOri,cOpeSol,@cTranDes)

					//montando resposta
					PlsPtuPut("TP_IDENTIF",cRet,aDados)
					if cRet == '1'
						PlsPtuPut("NR_IDENT_D",StrZero( Val( cTranDes ),10) ,aDados)
					endIf

					//log
					PlsPtuLog("***********************************")
					PlsPtuLog("Tempo de processamento : "+ElapTime(cTmpPro,Time())+" (Inicio: "+cTmpPro+" Fim : "+Time()+" )")
					PlsPtuLog("***********************************")
					PlsPtuLog("")
					PlsPtuLog("codigoTransacao => 00309")
					PlsPtuLog("identificador   => "+cRet )
					PlsPtuLog("***********************************")
					PlsPtuLog("GERADA RESPOSTA 00309")
					PlsPtuLog("***********************************")
				else
					PlsPtuLog("SOLICITACAO NAO ENCONTRADA, TRANSACAO ->" + cTranOri)
					PlsPtuLog("")

					//montando resposta
					PlsPtuPut("TP_IDENTIF","2",aDados)
				endIf


				//Solicitacao de revisao
			Case cTpTran == "00302"

				//Pega variaveis
				cResRev := PlsPtuGet("DS_MENS_LI",aDados)

				//Mostra o Log
				PlsPtuLog("codigoTransacao                   => "+Upper( PlsPtuGet( "CD_TRANS",aDados ) ) )
				PlsPtuLog("numeroTransacaoPrestadora         => "+Upper( cTranOri ) )
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+Upper( cTranDes ) )
				PlsPtuLog("mensagemLivre                     => "+Upper( cResRev ) )


				//Verifica se e um reenvio
				If VerReenvio(cTranOri,cTpTran,PlsPtuGet( "CD_UNI_ORI",aDados ),1)
					If PlsAliasExi("B93")
						DelTranB93(cOpeSol,cTpTran,cTranOri)
					EndIf
					Return
				Endif

				PlsPtuLog("***********************************")
				PlsPtuLog("RECEBIMENTO DO PEDIDO DE REVISAO")
				PlsPtuLog("***********************************")


				//Nome do beneficiario para armazenar B0S e B0T
				BEA->(DbSetOrder(22))//BEA_FILIAL+BEA_NRTROL+BEA_OPESOL
				If BEA->(DbSeek(xFilial("BEA") + cTranOri+Space( TamSX3("BEA_NRTROL")[1]-Len(cTranOri)) + cOpeSol))
					cNomUsr := BEA->BEA_NOMUSR
				Else
					BE4->(DbSetOrder(10))
					If BE4->(DbSeek(xFilial("BE4") + cTranOri+Space( TamSX3("BE4_NRTROL")[1]-Len(cTranOri)) + cOpeSol))
						cNomUsr := BEA->BEA_NOMUSR
					EndIf
				EndIf


				//Atualiza a guia
				aRetPtu := PLSACOMC(cTranOri,cTranDes,cResRev,{},cTpTran,,,,cOpeSol)
				cRet      := aRetPtu[1]
				cSenhaAut := Strzero(Val(aRetPtu[2]),10)

				//Mostra no log
				PlsPtuLog("PROCESSADO")
				PlsPtuLog("***********************************")
				If !Empty(cRet)
					PlsPtuLog(cRet)
				EndIf

				//Vou gerar a resposta para a operadora com o registro 00209/00309
				PlsPtuLog("***********************************")
				PlsPtuLog("GERANDO RESPOSTA 00309")
				PlsPtuLog("***********************************")
				PlsPtuLog("Processando.....")

				cOpeOri := PlsPtuGet("CD_UNI_ORI",aDados)
				aDados   := {}
				aItens   := {}
				PlsPtuPut("CD_TRANS","00309",aDados)
				PlsPtuPut("CD_UNI_ORI",cOpeDes,aDados)
				PlsPtuPut("CD_UNI_DES",PlsIntPad(),aDados)
				PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
				PlsPtuPut("NR_IDENT_D",IIF(!Empty(cTranDes) .And. Val(cTranDes) <> 0,cTranDes,Replicate("0",10)),aDados)
				PlsPtuPut("TP_IDENTIF","1",aDados)

				//Mostra o Log
				PlsPtuLog("codigoTransacao                   => 00309")
				PlsPtuLog("codigoUnimedPrestadora            => "+cOpeOri)
				PlsPtuLog("codigoUnimedOrigemBeneficiario    => "+PlsIntPad())
				PlsPtuLog("numeroTransacaoPrestadora         => "+cTranDes)
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+cTranOri)
				PlsPtuLog("identificador                     => 1 ")
				PlsPtuLog("***********************************")
				PlsPtuLog("GERADA RESPOSTA 00309")
				PlsPtuLog("***********************************")

				//Solicitacao de cancelamento
			Case  cTpTran == "00311"

				//Mostra o Log
				PlsPtuLog("codigoTransacao                   => "+Upper( PlsPtuGet("CD_TRANS",aDados) ) )
				PlsPtuLog("numeroTransacaoPrestadora         => "+Upper( cTranOri ) )
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+Upper( cTranDes ) )
				PlsPtuLog("TRANSACAO - CANCELADA")
				PlsPtuLog("***********************************")
				PlsPtuLog("RECEBIMENTO DE CANCELAMENTO")
				PlsPtuLog("***********************************")

				//Verifica se e um reenvio
				If VerReenvio(cTranOri,cTpTran,PlsPtuGet( "CD_UNI_ORI",aDados ),1)
					If PlsAliasExi("B93")
						DelTranB93(cOpeSol,cTpTran,cTranOri)
					EndIf
					Return
				Endif


				//Nome do beneficiario para armazenar B0S e B0T
				BEA->(DbSetOrder(22))//BEA_FILIAL+BEA_NRTROL+BEA_OPESOL
				If BEA->(DbSeek(xFilial("BEA") + cTranOri + cOpeSol))
					cNomUsr := BEA->BEA_NOMUSR
				Else
					BE4->(DbSetOrder(10))
					If BE4->(DbSeek(xFilial("BE4") + cTranOri + cOpeSol))
						cNomUsr := BEA->BEA_NOMUSR
					EndIf
				EndIf

				//Atualiza a guia
				aRetPtu := PLSACOMC(cTranOri,cTranDes,"",{},cTpTran,"1",,,cOpeSol,PlsPtuGet("DS_MOTIVO",aDados))
				cRet := aRetPtu[1]
				cSenhaAut := Strzero(Val(aRetPtu[2]),10)

				//Mostra no log
				If !Empty(cRet)
					PlsPtuLog(cRet)
				EndIf

				//Vou gerar a resposta para a operadora com o registro 00209/00309
				PlsPtuLog("GERANDO RESPOSTA 00309")
				PlsPtuLog("***********************************")
				PlsPtuLog("Processando.....")

				cOpeOri := PlsPtuGet("CD_UNI_ORI",aDados)
				aDados   := {}
				aItens   := {}
				PlsPtuPut("CD_TRANS","00309",aDados)
				PlsPtuPut("CD_UNI_ORI",cOpeOri,aDados)
				PlsPtuPut("CD_UNI_DES",PlsIntPad(),aDados)
				PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
				PlsPtuPut("NR_IDENT_D",IIF(Empty(cSenhaAut) .Or. Val(cSenhaAut)==0,cTranDes,cSenhaAut),aDados)
				Iif(Empty(cRet),PlsPtuPut("TP_IDENTIF","1",aDados),PlsPtuPut("TP_IDENTIF","2",aDados))

				//Mostra o Log
				PlsPtuLog("codigoTransacao   => 00309")
				PlsPtuLog("codigoUnimedPrestadora => "+cOpeOri)
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsIntPad())
				PlsPtuLog("numeroTransacaoPrestadora => "+cTranOri)
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+cTranDes)
				Iif(Empty(cRet),PlsPtuLog("TP_IDENTIF => 1 "),PlsPtuLog("TP_IDENTIF => 2 "))
				PlsPtuLog("***********************************")
				PlsPtuLog("GERADA RESPOSTA 00309")
				PlsPtuLog("***********************************")

				//Solicitacao de dados de usuario
			Case  cTpTran == "00412"
				PtuRetUsuA(aDados)
				lGravaTran := .F.

				//Solicitacao de dados de prestador
			Case cTpTran == "00418"
				PtuRetPreA(aDados)
				lGravaTran := .F.

				//Requisicao de ordem de servico
			Case cTpTran == "00806"

				PlsPtuLog("idUrgenciaEmergencia        => "+PlsPtuGet("ID_URG_EME",aDados))
				If PlsPtuGet("ID_URG_EME",aDados) == "S"
					PlsPtuPut("CARSOL","U",aDados)
				Endif

				If PlsPtuGet("ID_RN",aDados) == "S"
					PlsPtuPut("ATENRN","1",aDados)
				Else
					PlsPtuPut("ATENRN","0",aDados)
				EndIf

				If VerReenvio(PlsPtuGet("NR_IDENT_S",aDados)+Space( TamSX3("B0S_NUMSEQ")[1]-Len(PlsPtuGet("NR_IDENT_S",aDados)) ),cTpTran,PlsPtuGet("CD_UNI_SOL",aDados))

					If PlsAliasExi("B93")
						DelTranB93(cOpeSol,cTpTran,cTranOri)
					EndIf

					Return
				Else
					PtuReqSerA(aDados,aItens,aQuimio,aRadio,lAuto)
				EndIf

				lGravaTran := .f.

				//Resposta do Status da Transacao
			Case cTpTran == "00360"
				PlsPtuLog("00360 - STATUS DA TRANSACAO")
				PlsPtuLog("***********************************")
				PlsPtuLog("cabecalhoTransacao             => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente                    => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf
				PlsPtuLog("codigoUnimedPrestadora         => "+PlsPtuGet("CD_UNI_EXE",aDados))
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_BEN",aDados))
				PlsPtuLog("numeroTransacaoPrestadora      => "+PlsPtuGet("NR_IDENT_E",aDados))
				PlsPtuLog("***********************************")

				If !lPTUOn90
					cTpCliente := PlsPtuGet("TP_CLIENTE",aDados)
				EndIf

				cTranOri   := Alltrim(PlsPtuGet("NR_IDENT_E",aDados))
				cOpeSol    := Alltrim(PlsPtuGet("CD_UNI_EXE",aDados))

				cTranOri := StrZero(Val(cTranOri),10)
				cOpeSol  := Strzero(Val(cOpeSol),4)

				lGravaTran := .F.
				PlsPtuLog("GERANDO RESPOSTA 00361")
				PlsPtuLog("***********************************")

				//Verifica se transacao solicitada existe
				B0S->(DbSetOrder(1))
				If B0S->(DbSeek(xFilial("B0S")+cTranOri+"00600"+cOpeSol)) //Pedido de Autorizacao
					lFindSol := .T.
					cTipTra  := "00600"
				ElseIf B0S->(DbSeek(xFilial("B0S")+cTranOri+"00605"+cOpeSol)) //Pedido de Complemento de Autorizacao
					lFindSol := .T.
					cTipTra  := "00605"
				EndIf

				If lFindSol

					//Verifica se ja foi respondido, se e uma solicitacao ou complemento
					Do Case

						Case B0S->(DbSeek(xFilial("B0S")+cTranOri+"00404"+cOpeSol)) //Auditoria respondida
							cSql := " SELECT B0S_TIPTRA FROM " + RetSqlName("B0S")
							cSql += " WHERE B0S_FILIAL = '"+xFilial("B0S")+"' "
							cSql += " AND B0S_NUMSEQ = '"+cTranOri+"' "
							cSql += " AND B0S_OPESOL = '"+cOpeSol+"' "
							cSql += " AND D_E_L_E_T_ = ' ' "
							cSql += " ORDER BY B0S_DATPRO DESC, B0S_HORPRO DESC, R_E_C_N_O_ DESC "

							cSql := ChangeQuery(cSql)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

							TmpPac->(DbGotop())
							If !TmpPac->( Eof() )
								cLastTran := TmpPac->B0S_TIPTRA
							EndIf
							TmpPac->( dbClosearea() )

							//Se ultima transacao foi uma insistencia, busca uma transacao qualquer para
							//montar as linhas de procedimento
							If cLastTran == "00302"
								B0S->(DbSeek(xFilial("B0S")+cTranOri+cTipTra+cOpeSol))//Posiciona no registro para copia
								cTranResp := cTipTra
								cNumArq   := B0S->B0S_NUMARQ

								//Se ultima transacao nao foi uma insistencia, busca ultima transacao realizada
								//(B0S_NUMARQ) para gerar resposta
							Else
								cSql := " SELECT B0S_NUMARQ FROM " + RetSqlName("B0S")
								cSql += " WHERE B0S_FILIAL = '"+xFilial("B0S")+"' "
								cSql += " AND B0S_NUMSEQ = '"+cTranOri+"' "
								cSql += " AND B0S_TIPTRA = '00404' "
								cSql += " AND B0S_OPESOL = '"+cOpeSol+"' "
								cSql += " AND D_E_L_E_T_ = ' ' "
								cSql += " ORDER BY B0S_NUMARQ DESC "

								cSql := ChangeQuery(cSql)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

								TmpPac->(DbGotop())
								If !TmpPac->( Eof() )
									cNumArq   := TmpPac->B0S_NUMARQ
								EndIf
								TmpPac->( dbClosearea() )

								cTranResp := "00404"
							EndIf

						Case B0S->(DbSeek(xFilial("B0S")+cTranOri+"00600"+cOpeSol)) //Pedido de Autorizacao
							cNumArq   := B0S->B0S_NUMARQ
							If B0S->(DbSeek(xFilial("B0S")+cTranOri+"00302"+cOpeSol))//Verifica se ha insistencia
								cLastTran := "00302"
							EndIf
							cTranResp := "00600"

						Case B0S->(DbSeek(xFilial("B0S")+cTranOri+"00605"+cOpeSol)) //Pedido de Complemento de Autorizacao
							cNumArq   := B0S->B0S_NUMARQ
							If B0S->(DbSeek(xFilial("B0S")+cTranOri+"00302"+cOpeSol))//Verifica se ha insistencia
								cLastTran := "00302"
							EndIf
							cTranResp := "00605"
					EndCase

					aRet   := PlsGetB0T(cTranOri,cTranResp,cOpeSol,1,cNumArq)
					aDados := aRet[1]
					aItens := aRet[2]

					//Ajusta resposta quando ultima transacao for insistencia
					//(nao foi gerada a resposta ainda
					If cLastTran == "00302"
						For nI := 1 to len(aItens)
							For nJ := 1 to len(aItens[nI])
								If Substr(aItens[nI][nJ][1],1,9) == "CD_MENS_E"
									aItens[nI][nJ][2] := ""
								EndIf

								If Alltrim(aItens[nI][nJ][1]) == "DS_MENS_ES"
									aItens[nI][nJ][2] := ""
								EndIf

								If Alltrim(aItens[nI][nJ][1]) == "ID_AUTORIZ"
									aItens[nI][nJ][2] := "4"
								EndIf
							Next
						Next
					EndIf

					//Monta arquivo de resposta 00361
					PlsPtuPut("CD_TRANS","00361",aDados)
					PlsPtuPut("CD_UNI_EXE",cOpeSol,aDados)
					PlsPtuPut("CD_UNI_BEN",PlsIntPad(),aDados)
					PlsPtuPut("NR_IDENT_E",PlsPtuGet("NR_IDENT_O",aDados),aDados)
					PlsPtuPut("NR_IDENT_B",PlsPtuGet("NR_IDENT_D",aDados),aDados)
					PlsPtuPut("TP_IDENTIF","1",aDados)
					PlsPtuPut("DS_OBSERVA",PlsPtuGet("DS_LINHA_O",aDados),aDados)

					If !lPTUOn90
						//Utiliza TP_CLIENTE do arquivo TP_CLIENTE
						If (nPos := aScan(aDados,{|x|x[1] == "TP_CLIENTE"})) > 0
							aDados[nPos][2] := cTpCliente
						EndIf
					EndIf

					//Log Resposta 00361
					PlsPtuLog("codigoUnimedPrestadora            => "+PlsPtuGet("CD_UNI_PRE",aDados))
					PlsPtuLog("codigoUnimedOrigemBeneficiario    => "+PlsPtuGet("CD_UNI_DES",aDados))
					PlsPtuLog("numeroTransacaoPrestadora         => "+PlsPtuGet("NR_IDENT_O",aDados))
					PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+PlsPtuGet("NR_IDENT_D",aDados))
					PlsPtuLog("tpIdentificadorConfirmacao        => 1")
					PlsPtuLog("observacao                        => "+PlsPtuGet("DS_LINHA_O",aDados))
					PlsPtuLog("")

					//Processa itens da solicitacao
					For nI := 1 to len(aItens)
						PlsPtuPut("QT_AUTORIZ",PlsPtuGet("QT_SERVICO",aItens[nI]),aItens[nI])
						PlsPtuPut("ID_RESPOST",PlsPtuGet("ID_AUTORIZ",aItens[nI]),aItens[nI])

						//Log itens
						PlsPtuLog("***********************************")
						PlsPtuLog("PROCEDIMENTOS SOLICITADOS")
						PlsPtuLog("***********************************")
						Do Case
							Case PlsPtuGet("ID_AUTORIZ",aItens[nI]) == "1"
								cStatus := "1 - NEGADO"
							Case PlsPtuGet("ID_AUTORIZ",aItens[nI]) == "2"
								cStatus := "2 - AUTORIZADO"
							Case PlsPtuGet("ID_AUTORIZ",aItens[nI]) == "3"
								cStatus := "3 - PENDENTE EMPRESA"
							Case PlsPtuGet("ID_AUTORIZ",aItens[nI]) == "4"
								cStatus := "4 - PENDENTE AUDITORIA"
						EndCase

						PlsPtuLog("SERVICO =>" + AllTrim( PlsPtuGet("CD_SERVICO",aItens[nI] ) ) + " - " + ;
							AllTrim( PlsPtuGet("DS_SERVICO",aItens[nI] ) ) + " => " +cStatus )
					Next
				Else

					//Monta resposta 00361 para guia nao encontrada, utiliza layout "02360" que
					//finaliza com FIM$ ao encerrar o cabecalho
					PlsPtuPut("CD_TRANS","02361",aDados)
					PlsPtuPut("TP_IDENTIF","2",aDados)

					PlsPtuLog("SOLICITACAO NAO ENCONTRADA, TRANSACAO ->" + cTranOri)
					PlsPtuLog("")
				EndIf

				//Contagem de beneficiarios
			Case cTpTran == "00430" .And. PLSALIASEX("B0Z")

				cOpeSol := PlsPtuGet("CD_UNI_REQ",aDados)
				cOpeDes := PlsPtuGet("CD_UNI_DES",aDados)
				PlsPtuLog("00430 - CONTAGEM DE BENEFICIARIOS")
				PlsPtuLog("***********************************")
				PlsPtuLog("codigoTransacao                => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente                    => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf
				PlsPtuLog("codigoUnimedPrestadora         => "+cOpeSol)
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+cOpeDes)
				PlsPtuLog("anoReferencia                  => "+PlsPtuGet("ANO_REFERE",aDados))
				PlsPtuLog("mesReferencia                  => "+PlsPtuGet("MES_REFERE",aDados))
				PlsPtuLog("***********************************")
				PlsPtuLog("GERANDO RESPOSTA 00431")
				PlsPtuLog("***********************************")

				B0Z->(DbSetOrder(1))//B0Z_FILIAL+B0Z_ANO+B0Z_MES
				If B0Z->(DbSeek(xFilial("B0Z")+PlsPtuGet("ANO_REFERE",aDados)+PlsPtuGet("MES_REFERE",aDados)))
					aDados := {}
					PlsPtuPut("CD_TRANS","00431",aDados)
					PlsPtuPut("CD_UNI_REQ",cOpeSol,aDados)
					PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
					PlsPtuPut("ST_RETORNO","1",aDados)

					PlsPtuPut("QT_PFCOQTD",StrZero(B0Z->B0Z_PFCOLO+B0Z->B0Z_PFRPCO+B0Z->B0Z_PFRCCO,10),aDados) // custoOperacional > pessoaFisica
					PlsPtuPut("QT_PJCOQTD",StrZero(B0Z->B0Z_PJCOLO+B0Z->B0Z_PJRPCO+B0Z->B0Z_PJRCCO,10),aDados) // custoOperacional > pessoaJuridica
					PlsPtuPut("QT_PFPPQTD",StrZero(B0Z->B0Z_PFPPLO+B0Z->B0Z_PFRPPP+B0Z->B0Z_PFRCPP,10),aDados) // prePagamento > pessoaFisica
					PlsPtuPut("QT_PJPPQTD",StrZero(B0Z->B0Z_PJPPLO+B0Z->B0Z_PJRPPP+B0Z->B0Z_PJRCPP,10),aDados) // prePagamento > pessoaJuridica

					//Gera log para o console
					PlsPtuLog("codigoTransacao                => 00431")
					PlsPtuLog("codigoUnimedPrestadora         => "+cOpeSol)
					PlsPtuLog("codigoUnimedOrigemBeneficiario => "+cOpeDes)
					PlsPtuLog("statusResposta                 => 1")

					PlsPtuLog("QT_PFCOQTD => "+StrZero(B0Z->B0Z_PFCOLO+B0Z->B0Z_PFRPCO+B0Z->B0Z_PFRCCO,10))
					PlsPtuLog("QT_PJCOQTD => "+StrZero(B0Z->B0Z_PJCOLO+B0Z->B0Z_PJRPCO+B0Z->B0Z_PJRCCO,10))
					PlsPtuLog("QT_PFPPQTD => "+StrZero(B0Z->B0Z_PFPPLO+B0Z->B0Z_PFRPPP+B0Z->B0Z_PFRCPP,10))
					PlsPtuLog("QT_PJPPQTD => "+StrZero(B0Z->B0Z_PJPPLO+B0Z->B0Z_PJRPPP+B0Z->B0Z_PJRCPP,10))

				Else
					aDados := {}
					PlsPtuPut("CD_TRANS","00431",aDados)
					PlsPtuPut("CD_UNI_REQ",cOpeSol,aDados)
					PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
					PlsPtuPut("ST_RETORNO","3",aDados)

					PlsPtuPut("QT_PFCOQTD",Replicate("0",10),aDados) // custoOperacional > pessoaFisica
					PlsPtuPut("QT_PJCOQTD",Replicate("0",10),aDados) // custoOperacional > pessoaJuridica
					PlsPtuPut("QT_PFPPQTD",Replicate("0",10),aDados) // prePagamento > pessoaFisica
					PlsPtuPut("QT_PJPPQTD",Replicate("0",10),aDados) // prePagamento > pessoaJuridica

					//Gera log para o console
					PlsPtuLog("QT_PFCOQTD => "+Replicate("0",10))
					PlsPtuLog("QT_PJCOQTD => "+Replicate("0",10))
					PlsPtuLog("QT_PFPPQTD => "+Replicate("0",10))
					PlsPtuLog("QT_PJPPQTD => "+Replicate("0",10))

				EndIf

			//Comunicação de internação ou alta do beneficiário
			Case cTpTran == "00750"

				PlsPtuLog("00750 - COMUN DE INTERNACAO OU ALTA DO BENEFICIARIO")
				PlsPtuLog("***********************************")
				PlsPtuLog("codigoTransacao => "+Upper(PlsPtuGet("CD_TRANS",aDados)))

				If !lPTUOn90
					PlsPtuLog("tipoCliente => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf

				PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_ORI",aDados))
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_DES",aDados))
				PlsPtuLog("numeroTransacaoPrestadora => "+PlsPtuGet("NR_IDENT_O",aDados))
				PlsPtuLog("dataEvento => "+PlsPtuGet("DT_EVENTO",aDados))
				PlsPtuLog("tpEvento => "+PlsPtuGet("TP_EVENTO",aDados))

				If !Empty(PlsPtuGet("MT_ENCERR",aDados))
					PlsPtuLog("motivoEncerramento => "+PlsPtuGet("MT_ENCERR",aDados))
				EndIf

				If !Empty(PlsPtuGet("TP_INTERN",aDados))
					PlsPtuLog("tpInternacao => "+PlsPtuGet("TP_INTERN",aDados))
				EndIf

				PlsPtuLog("***********************************")

				cTpEvento := PlsPtuGet("TP_EVENTO",aDados)
				cTranOri := StrZero( Val( PlsPtuGet("NR_IDENT_O",aDados) ),10)
				cOpeSol := StrZero( Val( PlsPtuGet("CD_UNI_ORI",aDados) ),4)

				cOpeOri := PlsPtuGet("CD_UNI_ORI",aDados)
				cOpeDes := PlsPtuGet("CD_UNI_DES",aDados)

				If PLSALIASEX("B0S")
					B0S->(DbSetOrder(1))//B0T_FILIAL+B0T_NUMSEQ+B0T_TIPTRA+B0T_OPESOL+B0T_IDENT+B0T_VARIAV
					If B0S->(DbSeek(xFilial("B0S")+cTranOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTranOri) )+cTpTran+cOpeSol)) .And. B0S->(FieldPos("B0S_NUMARQ")) > 0
						lGravaTran :=.F.
					EndIf
				EndIf

				BE4->(DbSetOrder(10))//BE4_FILIAL+BE4_NRTROL+BE4_OPESOL
				If BE4->(MsSeek(xFilial("BE4")+cTranOri+Space(TAMSX3("BE4_NRTROL")[1] - len(cTranOri))+cOpeSol))

					If cTpEvento == "I"
						PLSA92DtIn(.T.,StoD(PlsPtuGet("DT_EVENTO",aDados)),StrTran(Time(),":","") )
					ElseIf cTpEvento == "A"
						PLSADtAlt(.F.,StoD(PlsPtuGet("DT_EVENTO",aDados)),StrTran(Time(),":",""), PlsPtuGet("MT_ENCERR",aDados) )
					EndIf

					lRetA750 := .T.
				EndIf

				//Monta resposta 00309
				aDados := {}
				aItens := {}

				PlsPtuPut("CD_TRANS","00309",aDados)
				PlsPtuPut("CD_UNI_ORI",cOpeOri,aDados)
				PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
				PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
				PlsPtuPut("NR_IDENT_D",cTranDes,aDados)
				PlsPtuPut("TP_IDENTIF",IIF(lRetA750,"1","2"),aDados)

				//00804 - Autorizacao de Ordem de Servico
			Case cTpTran == "00804"

				//Plsxmov
				PlsPtuPut("CHKREG",.F.,aDados)  // NAO CHECA REGRAS, POIS ERA AUDITORIA E FOI AUTORIZADO

				//Mostra o Log
				PlsPtuLog("codigoTransacao   => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
				If !lPTUOn90
					PlsPtuLog("tipoCliente => "+PlsPtuGet("TP_CLIENTE",aDados))
				EndIf
				PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_EXE",aDados))
				PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_BEN",aDados))
				PlsPtuLog("codigoUnimedSolicitante => "+PlsPtuGet("CD_UNI_SOL",aDados))
				PlsPtuLog("numeroTransacaoPrestadora => "+PlsPtuGet("NR_IDENT_E",aDados))
				PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+PlsPtuGet("NR_IDENT_B",aDados))
				PlsPtuLog("numeroTransacaoUnimedSolicitante => "+PlsPtuGet("NR_IDENT_S",aDados))
				PlsPtuLog("dataValidadeAutorizacao => "+Substr(PlsPtuGet("DT_VALIDAD",aDados),7,2)+"/"+Substr(PlsPtuGet("DT_VALIDAD",aDados),5,2)+"/"+Substr(PlsPtuGet("DT_VALIDAD",aDados),1,4))
				PlsPtuLog("numeroVersaoPTU  => "+PlsPtuGet("NR_VERSAO ",aDados))
				PlsPtuLog("mensagemLivre => "+Alltrim(PlsPtuGet("DS_MENS_LI",aDados)))

				cTranOri := PlsPtuGet("NR_IDENT_S",aDados)
				cTranDes := PlsPtuGet("NR_IDENT_B",aDados)
				cOpeSol  := PlsIntPad()

				//Verifica se a solicitando esta com o codigo de transacao repetido
				If VerReenvio(cTranOri+Space( TamSX3("B0S_NUMSEQ")[1]-Len(cTranOri) ),cTpTran,PlsPtuGet("CD_UNI_DES",aDados),2)
					If PlsAliasExi("B93")
						DelTranB93(cOpeSol,cTpTran,cTranOri)
					EndIf
					Return
				EndIf

				//Pega a Transacao original
				aDadSeq  := PlsGetBSA(cTranOri,PlsIntPad())
				For nI := 1 To Len(aDadSeq[1])
					If AllTrim(aDadSeq[1,nI,1]) <> "CD_TRANS"
						PlsPtuPut(aDadSeq[1,nI,1],PlsPtuGet(aDadSeq[1,nI,1],aDadSeq[1]),aDados)
					EndIf
				Next

				//Verifica nome do usario
				BA1->(DbSetOrder(5))
				If BA1->(dbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI_BEN",aDados)+PlsPtuGet("USUARIO",aDados)))
					cNomUsr := BA1->BA1_NOMUSR
				EndIf

				//Pega e Mostra os procedimentos para processamento da resposta
				PlsPtuLog("PROCEDIMENTOS")
				PlsPtuLog("***********************************")
				aIte := {}
				For nI := 1 to Len(aItens)

					//Monta campos
					cOldDesCri := ""
					cCodPro := PlsPtuGet("CD_SERVICO",aItens[nI])

					//Ponto de entrada para troca de procedimento
					If lPLPtuIte
						aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECENT","",nil,nil,cTranOri,nil})
						cCodPro := aPlPtuIte[2]
					Else
						// De-para somente pela tabela BTU (Terminologia TISS)
						If lPTUOn80
							If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_EXE",aDados))
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cPacoteGen,,.T.,,.T.)
							Else
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,,.T.,,.T.)
							EndIf
							If len(aRet) > 0
								cCodPad := aRet[1]
								cCodPro := aRet[2]
							EndIf
						Else
							//Realiza De/Para AMB/CBHPM
							If lConverProc
								PLBusProTab(cCodPro,.F.,,,.T.,,,cCodPad2,cCodPad )
								If BR8->(Found())
									cCodPro:= Alltrim(BR8->BR8_CODPSA)
								Endif
							EndIf

							//Realiza De/Para BR8_CODEDI ou tabela B1M
							If GetNewPar("MV_PTDPION","0") == "1"
								PLBusProTab(cCodPro,.F.,,dDataBase,,,,,)
								If BR8->(Found())
									cCodPad := BR8->BR8_CODPAD
									cCodPro := Alltrim(BR8->BR8_CODPSA)
								EndIf

								//Realiza De/Para com a tabela de terminologias TISS BTU
							ElseIf GetNewPar("MV_PTDPION","0") == "2"
								aRet := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,,.T.)
								If len(aRet) > 0
									cCodPad := aRet[1]
									cCodPro := aRet[2]
								EndIf
							EndIf
						EndIf
					EndIf

					//Na versao 5.0 itens das tabelas 1, 2 e 3 utiliza 03 inteiros e 04 decimais
					nQtd 		:= Val(PlsPtuGet("QT_AUTORIZ",aItens[nI]) )

					cAutori   := PlsPtuGet("ID_AUTORIZ",aItens[nI])

					//Nova Matriz para ajuste no be2
					AaDd(aIte,{cCodPro,cAutori,nQtd,{},Alltrim(PlsPtuGet("DS_SERVICO",aItens[nI])),nil, Alltrim(PlsPtuGet("DS_MENS_ES",aItens[nI]))} )

					//Mostra o Log
					PlsPtuLog("codigoServico => "+PlsPtuGet("CD_SERVICO",aItens[nI]) )

					//Checa se nao foi autorizado
					If cAutori <> "2"

						//Mostra as criticas
						For nFor := 1 To 5

							//Pendente Auditoria ou autorizacao empresa
							If cAutori == "3" .Or. cAutori == "4"
								lUmAud	 := .T.
								If cAutori == "3"
									If PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2])
										cCodCri := __aCdCri052[1]
										cDesCri := PLSBCTDESC()
									EndIf
								Else
									If PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2])
										cCodCri := __aCdCri051[1]
										cDesCri := PLSBCTDESC()
									EndIf
								EndIf

								//Se a critica estiver disabled
								If Empty(cCodCri)
									cCodCri := "999"
									cDesCri := "CRITICA DESABILITADA"
								EndIf

								//Negado
							ElseIf cAutori == "1"
								lUmNeg	 := .T.
								cCodCri := PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor)),aItens[nI])
								cDesCri := ""
								If cCodCri <> "0000"
									cDesCri := PlsRtcdCed(PlsIntPad(),cCodCri,3)
									cCodCri := PlsRtcdCed(PlsIntPad(),cCodCri,4)
									If !Empty(cDesCri)
										PLSPtuLog( "CRITICA " + cDesCri )
									EndIf
								EndIf
							EndIf

							//Implementa as criticas
							If !Empty(cDesCri) .And. cDesCri <> cOldDesCri
								AaDd( aIte[nI,4] ,{cCodCri,cDesCri,cAutori} )
								cOldDesCri := cDesCri
							EndIf
						Next
					Else
						lUmAut	:= .T.
					EndIf
				Next

				//Vai processar a resposta
				PlsPtuLog("***********************************")
				PlsPtuLog("INICIO DO PROCESSAMENTO")
				PlsPtuLog("***********************************")
				PlsPtuLog("Processando.....")
				cTmpPro := Time()

				//Processa	alteracao no cabecalho,item e critica da guia (bea,be2 e beg)
				cRet := PLSACOMP(cTranOri,cTranDes,cResRev,aIte,cTpTran,cOpeSol,PlsPtuGet("DT_VALIDAD",aDados))

				If !Empty(cRet) .And. SubStr(cRet,1,13) $ "FALHA ARQUIVO"
					PlsPtuLog(cRet)

					//lTimeOut e acionado quando ha um problema na composicao do arquivo
					lTimeOut   := .T.
					lGravaTran := .F.
					PlsPtuLog("***************************************************************************************")
					PlsPtuLog("FORAM ENCONTRADOS PROBLEMAS NO ARQUIVO PROCESSADO")
					PlsPtuLog("Nao foi possivel gerar arquivo 00309 de resposta")
					PlsPtuLog("***************************************************************************************")
				Else

					PlsPtuLog("")
					If !Empty(cRet)
						PlsPtuLog(cRet)
						lGravaTran := .F.
					EndIf

					//Verifica se algum ficou na auditoria ainda
					If Empty(cRet)
						Do Case
							Case lUmAut .And. !lUmNeg .And. !lUmAud
								PlsPtuLog("*** AUTORIZADO ***")
								cAutori := "1"
							Case lUmAut .And. lUmNeg .And. !lUmAud
								PlsPtuLog("*** AUTORIZADO PARCIALMENTE ***")
								cAutori := "2"
							Case !lUmAut .And. lUmNeg .And. !lUmAud
								PlsPtuLog("*** NAO AUTORIZADO ***")
								cAutori := "3"
							Case !lUmAut .And. !lUmNeg .And. lUmAud
								PlsPtuLog("*** AUTORIZADO PENDENTE DE (AUDITORIA OU AUTORIZACAO DA EMPRESA) ***")
								cAutori := "4"
						EndCase
					EndIf


					PlsPtuLog("***********************************")
					PlsPtuLog("Tempo de processamento : "+ElapTime(cTmpPro,Time())+" (Inicio: "+cTmpPro+" Fim : "+Time()+" )")
					PlsPtuLog("***********************************")
					PlsPtuLog("")

					//Vou gerar a resposta para a operadora com o registro 00209/00309
					PlsPtuLog("***********************************")
					PlsPtuLog("GERANDO RESPOSTA 00309")
					PlsPtuLog("***********************************")
					PlsPtuLog("Processando.....")

					cOpeDes := PlsPtuGet("CD_UNI_DES",aDados)
					aDados   := {}
					aItens   := {}
					PlsPtuPut("CD_TRANS","00309",aDados)
					PlsPtuPut("CD_UNI_DES",cOpeDes,aDados)
					PlsPtuPut("NR_IDENT_O",cTranOri,aDados)
					PlsPtuPut("NR_IDENT_D",cTranDes,aDados)
					PlsPtuPut("TP_IDENTIF",IIF(Empty(cRet),"1","2"),aDados)

					//Mostra o Log
					PlsPtuLog("codigoTransacao        => 00309")
					PlsPtuLog("codigoUnimedPrestadora => "+PlsIntPad())
					PlsPtuLog("codigoUnimedOrigemBeneficiario => "+cOpeDes)
					PlsPtuLog("numeroTransacaoPrestadora => "+cTranOri)
					PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+cTranDes)
					PlsPtuLog("identificador => "+IIF(Empty(cRet),"1","2"))
					PlsPtuLog("***********************************")
					PlsPtuLog("GERADA RESPOSTA 00309")
					PlsPtuLog("***********************************")
				EndIf

		EndCase

		//Grava arquivo de resposta gerado para possivel reenvio
		If lGravaTran
			If cTpTran == "00404"
				PLPTGRVREN(aDados,aItens,AllTrim(cTranOri),cTpTran,cCodInt,cOpeDes,"2",cNomUsr)
			Else
				PLPTGRVREN(aDados,aItens,AllTrim(cTranOri),cTpTran,cOpeSol,cCodInt,"2",cNomUsr)
			Endif
		EndIf
	EndIf

	//Tempo total do processo
	PlsPtuLog("****")
	PlsPtuLog("**** Tempo de processamento : "+ElapTime(cTmpIni,Time())+" (Inicio: "+cTmpIni+" Fim : "+Time()+" )")
	PlsPtuLog("****")

	//Atualiza registro de controle
	If !lNMonit .And. PlsAliasExi("B93")
		DelTranB93(cOpeSol,cTpTran,cTranOri)
	EndIf

Return({aRetA1100})


//-------------------------------------------------------------------
/*/{Protheus.doc} VerReenvio
Grava montagem de uma transacao Ptu Online para posterior  reenvio

@author  Microsiga
@version P11
@since   26.10.11
/*/
//-------------------------------------------------------------------
Static Function VerReenvio(cTranOri,cTpTran,cCodOpe,nInd)
	LOCAL lRet       := .F.
	LOCAL cHorAud    := "0000"
	LOCAL dDatResAud := Stod("20010101")
	LOCAL cHorIns    := "0000"
	LOCAL dDatResIns := Stod("20010101")
	LOCAL cKeyAud    := ""
	LOCAL cNumArq    := "1"
	DEFAULT nInd := 1

	DbSelectArea("B0S")
	B0S->(DbSetOrder(nInd))

	If B0S->(DbSeek(xFilial("B0S")+cTranOri+cTpTran+cCodOpe))

		//Verifica ultimo
		If cTpTran == "00404" .Or. cTpTran == "00302"

			IIf(cTpTran == "00404",cPesq := "00302",cPesq := "00404")

			//Verifica horario da ultima resposta de auditoria recebida
			cKeyAud := xFilial("B0S")+B0S->(B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL)
			While cKeyAud == B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL) .And. !B0S->(Eof())
				If B0S->B0S_DATPRO >= dDatResAud
					If B0S->B0S_HORPRO >= cHorAud
						dDatResAud := B0S->B0S_DATPRO
						cHorAud    := B0S->B0S_HORPRO
						cNumArq    := B0S->B0S_NUMARQ
					EndIf
				EndIf
				B0S->(DbSkip())
			EndDo

			//Procura ultima insistencia realizada
			B0S->(DbSetOrder(2))
			If B0S->(DbSeek(xFilial("B0S")+cTranOri+cPesq+IIf(cTpTran=="00404",cCodOpe,PlsIntPad())))
				cKeyAud := xFilial("B0S")+B0S->(B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL)
				While cKeyAud == B0S->(B0S_FILIAL+B0S_NUMSEQ+B0S_TIPTRA+B0S_OPESOL) .And. !B0S->(Eof())
					If B0S->B0S_DATPRO >= dDatResIns
						If B0S->B0S_HORPRO >= cHorIns
							dDatResIns := B0S->B0S_DATPRO
							cHorIns    := B0S->B0S_HORPRO
						EndIf
					EndIf
					B0S->(DbSkip())
				EndDo
			EndIf

			//Verifica se ha insistencia com horario posterior a ultima resp. auditoria
			If !(dDatResIns >= dDatResAud .And. cHorIns >= cHorAud)
				lRet := .T.
			EndIf
		Else
			cNumArq := B0S->B0S_NUMARQ
			lRet := .T.
		EndIf
	EndIf

	If lRet

		//Se a transacao ja foi processada, realiza o reenvio com primeira resposta
		PlsPtuLog("******************************************************")
		PlsPtuLog("PROCESSANDO O REENVIO - "+cTpTran   )
		PlsPtuLog("OPERADORA SOLIC -> "+cCodOpe   )
		PlsPtuLog("TRANSACAO -> "+cTpTran   )
		PlsPtuLog("******************************************************")

		aRet := PlsGetB0T(cTranOri,cTpTran,cCodOpe,nInd,cNumArq)
		aDados := aRet[1]
		aItens := aRet[2]
	EndIf

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PtuRetUsuA
Processa solicitacao 00312/00412 (consulta dados usuarios)

@author  Microsiga
@version P11
@since   15.12.10
/*/
//-------------------------------------------------------------------
Function PtuRetUsuA(aDados)
	Local nI         := 0
	Local nX         := 0
	Local nPosTag    := 0
	Local cUniSol    := ""
	Local cUniOrig   := ""
	Local cMatric    := ""
	Local cFirstName := ""
	Local cLastName  := ""
	Local cCodPla    := ""
	Local cSql       := ""
	Local cTranOri   := ""
	Local cTranDes   := ""
	Local cCPF       := ""
	Local cCNS       := ""
	Local aUsuarios  := {}
	Local aCabRet    := {}
	Local aIteRet    := {}
	Local cDataNasc  := CToD(" / / ")
	Local lDtNas     := .T.
	Local lLastN     := .T.
	Local aTagObrig  := {}
	Local lPTUOn90   := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
	Default aDados   := {}

	//Armazena dados enviados pelo 00312/00412 de outra Unimed
	cUniSol    := Strzero(Val(PlsPtuGet("CD_UNI_EXE",aDados)),4)
	cUniOrig   := Strzero(Val(PlsPtuGet("CD_UNI_BEN",aDados)),4)

	cMatric    := PadL(PlsPtuGet("ID_BENEF",aDados),13,"0")

	If !lPTUOn90
		cFirstName := PlsPtuGet("NM_BENEF",aDados)
		cLastName  := PlsPtuGet("SB_NM_BENE",aDados)
		cDataNasc  := PlsPtuGet("DT_NASC",aDados)
	EndIf

	cTranOri   := PlsPtuGet("NR_IDENT_E",aDados)
	cCPF       := PlsPtuGet("NR_CPF",aDados)

	If !lPTUOn90
		cCNS       := PlsPtuGet("NR_CNS",aDados)
	EndIf

	//Primeira verificacao e por matricula
	If Val(Alltrim(cMatric)) > 0
		cMatric:= cUniOrig+cMatric
		DbSelectArea("BA1")
		DbSetOrder(2)//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		If BA1->(DbSeek(xFilial("BA1")+cMatric))
			Aadd(aUsuarios,BA1->(Recno()))
		EndIf

		//Se a matricula nao estiver preenchida e realizada a verificacao secundaria
	Else
		cSql := " SELECT BA1.R_E_C_N_O_ FROM "+RetSqlName("BA1") + " BA1, " + RetSqlName("BTS") + " BTS "
		cSql += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' "
		cSql += " AND   BTS_FILIAL = '"+xFilial("BTS")+"' "
		cSql += " AND BA1_MATVID = BTS_MATVID "

		If !lPTUOn90
			If !Empty(cDataNasc)
				cSql += " AND BA1_DATNAS = '"+cDataNasc+"' "
			Else
				lDtNas := .F.
			EndIf

			If !Empty(cFirstName) .And. !Empty(cLastName)
				cSql += " AND BA1_NOMUSR LIKE '%"+Upper(Alltrim(cFirstName))+"%"+Upper(Alltrim(cLastName))+"%' "
			ElseIf !Empty(cFirstName)
				cSql += " AND BA1_NOMUSR LIKE '"+Upper(Alltrim(cFirstName))+"%' "
			ElseIf !Empty(cLastName)
				cSql += " AND BA1_NOMUSR LIKE '%"+Upper(Alltrim(cFirstName))+"' "
			Else
				lLastN := .F.
			EndIf
		EndIf

		If !Empty(cCPF)
			cSql += " AND BA1_CPFUSR = '"+cCPF+"' "
		EndIf

		If !lPTUOn90 .And. !Empty(cCNS)
			cSql += " AND BTS_NRCRNA = '"+cCNS+"' "
		EndIf

		cSql += " AND BA1.D_E_L_E_T_ <> '*' "
		cSql += " AND BTS.D_E_L_E_T_ <> '*' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpUsu",.T.,.F.)

		TmpUsu->(DbGotop())
		While !TmpUsu->( Eof() ) .And. IIf(!lPTUOn90, lDtNas .And. lLastN, .T.)
			Aadd(aUsuarios,TmpUsu->R_E_C_N_O_)
			TmpUsu->( dbSkip() )
		EndDo
		TmpUsu->( dbClosearea() )

	EndIf

	//Define codigo da transacao na Unimed Destino
	If PLSALIASEX("BSN")
		DbSelectArea("BSN")
		cTranDes := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranDes
		BSN->(MsUnLock())
		ConfirmSX8()
	Endif

	//Se encontrou usuarios, utiliza o layout 00313 que chama o 01313 onde e
	//gerado as linhas de usuarios. Caso nao encontre usuarios, utiliza layout
	//02313 que finaliza com FIM$ ao encerrar o cabecalho


	//Monta cabecalho de retorno
	PlsPtuPut("CD_TRANS","00413",aCabRet)
	PlsPtuPut("CD_UNI_EXE",cUniSol,aCabRet)
	PlsPtuPut("CD_UNI_BEN",PlsIntPad(),aCabRet)

	//Se nao ha usuarios, busca cód da critica correspondente no BCT
	If len(aUsuarios) > 0
		PlsPtuPut("ID_CONFIRM","S",aCabRet)
	Else
		PlsPtuPut("ID_CONFIRM","N",aCabRet)

		//Critica, nao encontrou o usuario
		PLSPOSGLO(PLSINTPAD(),__aCdCri199[1],__aCdCri199[2])
		If Empty(RetCodEdi(__aCdCri199[1])) .Or. RetCodEdi(__aCdCri199[1]) == "0000"
			PlsPtuPut("CD_MENS_ER","5001",aCabRet)
		Else
			PlsPtuPut("CD_MENS_ER",RetCodEdi(__aCdCri199[1]),aCabRet)
		EndIf
	EndIf
	PlsPtuPut("NR_IDENT_E",cTranOri,aCabRet)
	PlsPtuPut("NR_IDENT_B",cTranDes,aCabRet)


	//Monta Log de Retorno -> Cabecalho
	PlsPtuLog("***********************************************")
	PlsPtuLog("RECEBIDO TRANS. 00412 - CONS. DADOS USUARIO")
	PlsPtuLog("GERANDO RETORNO -> TRANSACAO 00413")
	PlsPtuLog("***********************************************")
	PlsPtuLog("codigoTransacao => 00413")
	PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_EXE",aCabRet))
	PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_BEN",aCabRet))
	PlsPtuLog("identificaSolicitacaoConfirmada => "+PlsPtuGet("ID_CONFIRM",aCabRet))
	PlsPtuLog("codigoMensagemErro => "+PlsPtuGet("CD_MENS_ER",aCabRet))
	PlsPtuLog("numeroTransacaoPrestadora => "+PlsPtuGet("NR_IDENT_E",aCabRet))
	PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+PlsPtuGet("NR_IDENT_B",aCabRet))
	If len(aUsuarios)==0
		PlsPtuLog("")
		PlsPtuLog("NAO FOI ENCONTRADO USUARIO COM OS DADOS INFORMADOS")
	EndIf
	PlsPtuLog("")

	//Achou usuario, monta bloco com usuarios que atendem a condicao
	If len(aUsuarios) > 0

		//Indica tags obrigatorias
		AAdd(aTagObrig,{"codigoUnimed"         ,"CD_UNI"    ,"BA1_CODINT" })
		AAdd(aTagObrig,{"codigoIdentificacao"  ,"ID_BENEF"  ,"BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO"})
		If !lPTUOn90
			AAdd(aTagObrig,{"nome"                 ,"NM_BENEF"  ,"BA1_NOMUSR" })
			AAdd(aTagObrig,{"dataNascimento"       ,"DT_NASC"   ,"BA1_DATNAS" })
		EndIF
		AAdd(aTagObrig,{"nomeCompleto"         ,"NM_COMPL_B","BA1_NOMUSR" })

		If !lPTUOn90
			AAdd(aTagObrig,{"nomeEmpresa"          ,"M_EMPR_ABR","BG9_NREDUZ" })
			AAdd(aTagObrig,{"nomePlano"            ,"NM_PLANO"  ,"BI3_NREDUZ" })
		EndIf
		AAdd(aTagObrig,{"tpAcomodacao"         ,"TP_ACOMOD" ,"BI3_CODACO" })
		AAdd(aTagObrig,{"tipoAbrangencia"      ,"TP_ABRANGE","BF7_CODEDI" })
		AAdd(aTagObrig,{"localAtendimento"     ,"CD_LCAT"   ,"PlsIntPad()" })
		AAdd(aTagObrig,{"dataInclusaoUnimed"   ,"DT_INCL_UN","BA1_DATINC" })
		If !lPTUOn90
			AAdd(aTagObrig,{"dataValidadeCarteira" ,"DT_VAL_CAR","BA1_DTVLCR" })
		EndIf
		AAdd(aTagObrig,{"cdRede"               ,"CD_REDE"   ,"BI3_REDEDI" })
		If !lPTUOn90
			AAdd(aTagObrig,{"idPlano"              ,"ID_PLANO"  ,"BI3_APOSRG" })
		EndIf
		//Monta matriz
		For nI := 1 to len(aUsuarios)

			AaDd(aIteRet,{})
			BA1->(DbGoto(aUsuarios[nI]))
			PlsPtuLog("")
			PlsPtuLog("GERANDO INFORMACOES -> "+Substr(BA1->BA1_NOMUSR,1,25))//Gera Log
			
			If !lPTUOn90
				PlsPtuPut("NM_BENEF",Substr(BA1->BA1_NOMUSR,1,25),aIteRet[Len(aIteRet)])//Nome do Beneficiário
				PlsPtuPut("DT_NASC",Dtos(BA1->BA1_DATNAS),aIteRet[Len(aIteRet)]) //Data de Nascimento do Beneficiário
	
				//Posiciona na empresa
				BG9->(DbSelectArea(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
				If BG9->(DbSeek(xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP)))
					PlsPtuPut("M_EMPR_ABR",Substr(BG9->BG9_NREDUZ,1,19),aIteRet[Len(aIteRet)])//Nome da Empresa Abreviado
				EndIf
			EndIf

			PlsPtuPut("CD_UNI",BA1->BA1_CODINT,aIteRet[Len(aIteRet)])//Código da Unimed
			PlsPtuPut("ID_BENEF",PadL(BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),13,"0"),aIteRet[Len(aIteRet)])//Código de identificação do beneficiário
			PlsPtuPut("NM_COMPL_B",Substr(BA1->BA1_NOMUSR,1,120),aIteRet[Len(aIteRet)])//Nome Completo do beneficiário

			If lPTUOn90
				PlsPtuPut("NR_IDADE", cValToChar(Calc_Idade(dDataBase, BA1->BA1_DATNAS)), aIteRet[Len(aIteRet)])
			EndIf

			If lPTUOn90 .And. !Empty(BA1->BA1_NOMSOC)
				PlsPtuPut("NM_NOMSOC",Substr(BA1->BA1_NOMSOC, 1, 70), aIteRet[Len(aIteRet)]) // Nome Social do Beneficiário
			EndIf

			//Posiciona Produto, se o BA1_CODPLA nao estiver preenchido verifica familia
			BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			If BA3->(DbSeeK(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				If BA3->BA3_TIPOUS == "1" 	//Pessoa Fisica
					IIf(!Empty(BA1->BA1_CODPLA),cCodPla := BA1->(BA1_CODPLA+BA1_VERSAO),cCodPla := BA3->(BA3_CODPLA+BA3_VERSAO))
				Else //Pessoa Juridica
					IIf(!Empty(BA1->BA1_CODPLA),cCodPla := BA1->(BA1_CODPLA+BA1_VERCON),cCodPla := BA3->(BA3_CODPLA+BA3_VERCON))
				Endif
			EndIf

			BI3->(DbSetOrder(1))//BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
			If BI3->(DbSeeK(xFilial("BI3")+BA1->BA1_CODINT+cCodPla))

				If !lPTUOn90
					PlsPtuPut("NM_PLANO",BI3->BI3_NREDUZ,aIteRet[Len(aIteRet)])//Nome Plano Beneficiário
				EndIf

				//Verifica abrangencia
				If !Empty(BI3->BI3_ABRANG)
					DbSelectArea("BF7")
					DbSetOrder(1)//BF7_FILIAL+BF7_CODORI
					If BF7->(DbSeeK(xFilial("BF7")+BI3->BI3_ABRANG))
						PlsPtuPut("TP_ABRANGE",BF7->BF7_CODEDI,aIteRet[Len(aIteRet)])//Abrangência do Plano
					EndIf
				EndIf
			EndIf

			//Verifica acomodação do plano
			BI4->(DbSetOrder(1))//BI4_FILIAL+BI4_CODACO
			If BI4->(DbSeek(xFilial("BI4")+BI3->BI3_CODACO)) .And. BI4->BI4_CODEDI == "1" //Apartamento
				PlsPtuPut("TP_ACOMOD","B",aIteRet[Len(aIteRet)])
			ElseIf BI4->(DbSeek(xFilial("BI4")+BI3->BI3_CODACO)) .And. BI4->BI4_CODEDI == "2" //Enfermaria
				PlsPtuPut("TP_ACOMOD","A",aIteRet[Len(aIteRet)])
			ElseIf BI4->(DbSeek(xFilial("BI4")+BI3->BI3_CODACO)) .And. BI4->BI4_CODEDI $ "3/4" //Nao se aplica ou Ambulatorial
				PlsPtuPut("TP_ACOMOD","C",aIteRet[Len(aIteRet)]) //Nao se aplica
			ElseIf BI4->(DbSeek(xFilial("BI4")+BI3->BI3_CODACO)) .And. !Empty(BI4->BI4_CODEDI)
				PlsPtuPut("TP_ACOMOD",BI4->BI4_CODEDI,aIteRet[Len(aIteRet)])
			EndIf

			PlsPtuPut("CD_LCAT",PlsIntPad(),aIteRet[Len(aIteRet)])//Local de cobrança
			PlsPtuPut("DT_INCL_UN",Dtos(BA1->BA1_DATINC),aIteRet[Len(aIteRet)])//Data Inclusão do beneficiário na Unimed

			If !Empty(BA1->BA1_DATBLO)
				PlsPtuPut("DT_EXCL_UN",Dtos(BA1->BA1_DATBLO),aIteRet[Len(aIteRet)])//Data Exclusão do beneficiário da Unimed
			Endif

			If !lPTUOn90
				PlsPtuPut("DT_VAL_CAR",Dtos(BA1->BA1_DTVLCR),aIteRet[Len(aIteRet)])//Data da Validade da carteira
		
				If BA1->BA1_SEXO == "1"
					PlsPtuPut("TP_SEXO","1",aIteRet[Len(aIteRet)])//Sexo do Beneficiário - Masculino
				ElseIf BA1->BA1_SEXO == "2"
					PlsPtuPut("TP_SEXO","3",aIteRet[Len(aIteRet)])//Sexo do Beneficiário - Feminino
				EndIf

				PlsPtuPut("NR_VIA_CAR",StrZero(BA1->BA1_VIACAR,2),aIteRet[Len(aIteRet)])//Via de cartão válida
			EndIf

			Do Case
				Case Alltrim(BI3->BI3_APOSRG) == "0"
					PlsPtuPut("ID_PLANO","1",aIteRet[Len(aIteRet)])//1 - Plano Não Regulamentado
				Case Alltrim(BI3->BI3_APOSRG) == "1"
					PlsPtuPut("ID_PLANO","3",aIteRet[Len(aIteRet)])//3 - Plano Regulamentado
				Case Alltrim(BI3->BI3_APOSRG) == "2"
					PlsPtuPut("ID_PLANO","2",aIteRet[Len(aIteRet)])//2 - Plano Adaptado
			EndCase
			

			PlsPtuPut("CD_REDE",Substr(BI3->BI3_REDEDI,1,4),aIteRet[Len(aIteRet)])//Rede de Atendimento *** Levantar conteudo

			//Verifica se todas as tags obrigatorias foram preenchidas
			for nX := 1 to len(aTagObrig)
				if (nPosTag := Ascan(aIteRet[Len(aIteRet)],{|x| Alltrim(x[1]) == Alltrim(aTagObrig[nX,2]) }) ) > 0
					if Empty(aIteRet[Len(aIteRet),nPosTag,2])
						PlsPtuLog("Tag obrigatoria '"+aTagObrig[nX,1] +"' nao preenchida. Consulte o(s) campo(s) "+aTagObrig[nX,3]+" correspondente(s).")
					endIf
				else
					PlsPtuLog("Tag obrigatoria '"+aTagObrig[nX,1] +"' nao preenchida")
				endIf
			next

		Next
	EndIf

	//Clona as matrizes para geracao do arquivo              					 ³

	aDados := aClone(aCabRet)
	aItens := aClone(aIteRet)
	PlsPtuLog("***********************************************")
	PlsPtuLog("FINALIZANDO TRANSACAO 00413")
	PlsPtuLog("***********************************************")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PtuRetPreA
Processa solicitacao 00318/00418 (consulta dados prestador)

@author  Microsiga
@version P11
@since   20.12.10
/*/
//-------------------------------------------------------------------
Function PtuRetPreA(aDados)
	Local nI         := 0
	Local cUniSol    := ""
	Local cUniOrig   := ""
	Local cNomePres  := ""
	Local cTranOri   := ""
	Local cCNPJ      := ""
	Local cConselho  := ""
	Local cRegistro  := ""
	Local cUf        := ""
	Local cTranDes   := ""
	Local aPrest     := {}
	Local aCabRet    := {}
	Local aIteRet    := {}
	Default aDados   := {}

	//Armazena dados enviados pelo 00318/00418 de outra Unimed

	cUniSol    := Strzero(Val(PlsPtuGet("CD_UNI_EXE",aDados)),4)
	cUniOrig   := Strzero(Val(PlsPtuGet("CD_UNI_BEN",aDados)),4)
	cTranOri   := PlsPtuGet("NR_IDENT_E",aDados)
	cNomePres  := PlsPtuGet("NM_PREST",aDados)
	cCNPJ      := PlsPtuGet("CD_CGC_CPF",aDados)
	cConselho  := PlsPtuGet("SG_CONS_PR",aDados)
	cRegistro  := PlsPtuGet("NR_CONS_PR",aDados)
	cUf        := PlsPtuGet("UF_CONS_PR",aDados)

	//Verifica a existencia do prestador

	cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BAU")
	cSql += " WHERE BAU_FILIAL = '"+xFilial("BAU")+"' "
	cSql += " AND (BAU_NOME LIKE '%"+Upper(Alltrim(cNomePres))+"%' "
	cSql += " OR BAU_NREDUZ LIKE '%"+Upper(Alltrim(cNomePres))+"%' "
	cSql += " OR BAU_NFANTA LIKE '%"+Upper(Alltrim(cNomePres))+"%' )"
	cSql += " AND D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPres",.T.,.F.)

	TmpPres->(DbGotop())
	While !TmpPres->( Eof() )
		Aadd(aPrest,TmpPres->R_E_C_N_O_)
		TmpPres->( dbSkip() )
	EndDo
	TmpPres->( dbClosearea() )

	//Define codigo da transacao na Unimed Destino

	If PLSALIASEX("BSN")
		DbSelectArea("BSN")
		cTranDes := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranDes
		BSN->(MsUnLock())
		ConfirmSX8()
	Endif

	//Se encontrou prestador, utiliza o layout 00319 que chama o 01319 onde e
	//gerado as linhas de prestadores. Caso nao encontre usuarios, utiliza
	//layout 02319 que finaliza com FIM$ ao encerrar o cabecalho


	//Monta cabecalho de retorno
	PlsPtuPut("CD_TRANS","00419",aCabRet)
	PlsPtuPut("CD_UNI_EXE",cUniSol,aCabRet)
	PlsPtuPut("CD_UNI_BEN",PlsIntPad(),aCabRet)
	PlsPtuPut("NR_IDENT_E",cTranOri,aCabRet)
	PlsPtuPut("NR_IDENT_B",cTranDes,aCabRet)

	//Se nao ha prestadores, busca cód da critica correspondente no BCT

	If len(aPrest) > 0
		PlsPtuPut("ID_CONFIRM","S",aCabRet)
	Else
		PlsPtuPut("ID_CONFIRM","N",aCabRet)

		//Critica, nao encontrou o prestador

		PLSPOSGLO(PLSINTPAD(),__aCdCri201[1],__aCdCri201[2])
		If Empty(RetCodEdi(__aCdCri201[1])) .Or. RetCodEdi(__aCdCri201[1]) == "0000"
			PlsPtuPut("CD_MENS_ER","5001",aCabRet)
		Else
			PlsPtuPut("CD_MENS_ER",RetCodEdi(__aCdCri201[1]),aCabRet)
		EndIf
	EndIf

	//Monta Log de Retorno -> Cabecalho

	PlsPtuLog("***********************************************")
	PlsPtuLog("RECEBIDO TRANS. 00418 - CONS. DADOS PRESTADOR")
	PlsPtuLog("GERANDO RETORNO -> TRANSACAO 00419")
	PlsPtuLog("***********************************************")
	PlsPtuLog("codigoTransacao => 00419")
	PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_EXE",aCabRet))
	PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsPtuGet("CD_UNI_BEN",aCabRet))
	PlsPtuLog("numeroTransacaoPrestadora => "+PlsPtuGet("NR_IDENT_E",aCabRet))
	PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+PlsPtuGet("NR_IDENT_B",aCabRet))
	PlsPtuLog("identificaSolicitacaoConfirmada => "+PlsPtuGet("ID_CONFIRM",aCabRet))
	PlsPtuLog("codigoMensagemErro => "+PlsPtuGet("CD_MENS_ER",aCabRet))
	If len(aPrest)==0
		PlsPtuLog("")
		PlsPtuLog("NAO FOI ENCONTRADO PRESTADOR COM OS DADOS INFORMADOS")
	EndIf
	PlsPtuLog("")

	//Achou prestador, monta bloco com prestadores que atendem a condicao

	If len(aPrest) > 0

		//Monta matriz
		For nI := 1 to len(aPrest)
			BAU->(DbGoto(aPrest[nI]))
			If !Empty(BAU->BAU_CODIGO) .And. !Empty(BAU->BAU_NOME) .And. !Empty(BAU->BAU_TIPRED)
			AaDd(aIteRet,{})
			PlsPtuPut("CD_UNI_PRE",PlsIntPad(),aIteRet[Len(aIteRet)])
			PlsPtuPut("NM_PREST",Substr(BAU->BAU_NOME,1,40),aIteRet[Len(aIteRet)])//Nome do Prestador.
			PlsPtuPut("CD_PREST",Strzero(Val(BAU->BAU_CODIGO),8),aIteRet[Len(aIteRet)])//Codigo do Prestador
			PlsPtuLog("GERANDO INFORMACOES -> "+Substr(BAU->BAU_NOME,1,25))//Gera Log

			//Verifica especialidade
			BBF->(DbSetOrder(1))//BBF_FILIAL+BBF_CODIGO+BBF_CODINT+BBF_CDESP
			If BBF->(DbSeeK(xFilial("BBF")+BAU->BAU_CODIGO+cUniOrig))
				BAQ->(DbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP
				If BAQ->(DbSeeK(xFilial("BAQ")+BBF->(BBF_CODINT+BBF_CDESP)))
					PlsPtuPut("CD_ESPEC",BAQ->BAQ_INTERC,aIteRet[Len(aIteRet)])//Código da Especialidade Médica.
				EndIf
			EndIF
			IIf(BAU->BAU_ALTCUS == "1",PlsPtuPut("ID_ALTO_CU","1",aIteRet[Len(aIteRet)]),PlsPtuPut("ID_ALTO_CU","3",aIteRet[Len(aIteRet)]))//Identifica se prestador da transação é de Alto Custo
			PlsPtuPut("TP_REDE_MIN",BAU->BAU_TIPRED,aIteRet[Len(aIteRet)])//Tipo de Rede
		EndIf
		Next
	EndIf

	//Clona as matrizes para geracao do arquivo
	aDados := aClone(aCabRet)
	aItens := aClone(aIteRet)
	PlsPtuLog("***********************************************")
	PlsPtuLog("FINALIZANDO TRANSACAO 00419")
	PlsPtuLog("***********************************************")
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PtuReqSerA
Processa solicitacao 00806(req. de ordem de servico)

@author  Microsiga
@version P11
@since   23.12.10
/*/
//-------------------------------------------------------------------
Function PtuReqSerA(aDados,aItens,aQuimio,aRadio,lAuto)
	LOCAL nI        := 0
	LOCAL cUniPrest := ""
	LOCAL cTranOri  := ""
	LOCAL cTranDes  := ""
	LOCAL cMatric   := ""
	LOCAL aCabRet   := {}
	LOCAL aIteRet   := {}
	LOCAL aRetRda   := {}
	LOCAL aThreads  := {}
	LOCAL cNomUsr   := AllTrim( PlsPtuGet(" NM_BENEF",aDados) )
	LOCAL cUniSol   := ""
	LOCAL cCodPad   := SubStr( GETMV("MV_PLSTBPD") ,1,2)
	LOCAL cCodMed   := PlsPtuGet("CD_PREST",aDados)
	LOCAL lNaoPode  := .F.
	LOCAL lItern    := .F.
	LOCAL lOSAutori := .F.
	LOCAL nPosIDIte := 0
	LOCAL cUniExe	:= ""
	local cCarSol   := PLSRETDAD( aDados,"CARSOL","" )
	LOCAL aDadosOS  := {}
	LOCAL aItensOS  := {}
	LOCAL aQuimioOS := {}
	LOCAL aRadioOS  := {}
	Default aQuimio := {}
	Default aRadio  := {}
	Default lAuto   := .F.
	//Armazena dados enviados pelo 00318/00418 de outra Unimed
	PLGRVORDSE(aDados,aItens)

	aDadosOS   := aDados
	aItensOS   := aItens
	aQuimioOS  := aQuimio
	aRadioOS   := aRadio

	cUniPrest := PlsPtuGet("CD_UNI",aDados)
	cTranOri  := PlsPtuGet("NR_IDENT_B",aDados)
	cMatric   := PlsPtuGet("ID_BENEF",aDados)
	cUniSol   := PlsPtuGet("CD_UNI_BEN",aDados)
	cTranSol  := PlsPtuGet("NR_IDENT_S",aDados)
	cUniExe   := PlsPtuGet("CD_UNI_EXE",aDados)

	//Codigo do prestador
	cCodPrest := PlsPtuGet("CD_UNI_PRE",aDados) + PlsPtuGet("CD_PREST",aDados)

	//Monta cabecalho de retorno
	PlsPtuPut("CD_TRANS","00807",aCabRet)
	PlsPtuPut("CD_UNI_BEN",cUniSol,aCabRet)
	PlsPtuPut("CD_UNI_EXE",cUniExe,aCabRet)
	PlsPtuPut("NR_IDENT_B",PlsPtuGet("NR_IDENT_S",aDados),aCabRet)
	PlsPtuPut("CD_UNI_SOL",cUniSol,aCabRet)

	If PLSALIASEX("BSN")

		cTranDes := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)

		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranDes
		BSN->(MsUnLock())
		ConfirmSX8()

	Endif

	PlsPtuPut("NR_IDENT_E",cTranDes,aCabRet)
	PlsPtuPut("CD_UNI",cUniPrest,aCabRet)
	PlsPtuPut("ID_BENEF",PadL(cMatric,13,"0"),aCabRet)

	//Monta Log de Retorno -> Cabecalho
	PlsPtuLog("***********************************************")
	PlsPtuLog("RECEBIDO TRANS. 00807 - REQ. ORDEM SERVICO")
	PlsPtuLog("GERANDO RETORNO -> TRANSACAO 00807")
	PlsPtuLog("***********************************************")
	PlsPtuLog("codigoTransacao => 00807")
	PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_BEN",aCabRet))
	PlsPtuLog("numeroTransacaoPrestadora => "+PlsPtuGet("NR_IDENT_E",aCabRet))
	PlsPtuLog("numeroTransacaoUnimedSolicitante => "+PlsPtuGet("NR_IDENT_B",aCabRet))
	PlsPtuLog("codigoUnimed =>     "+PlsPtuGet("CD_UNI",aCabRet))
	PlsPtuLog("codigoIdentificacao =>   "+PlsPtuGet("ID_BENEF",aCabRet))
	PlsPtuLog("")

	If PlsPtuGet("ID_URG_EME",aDados) == "S"
		PlsPtuPut("CARSOL",cCarSol,aDados)
	Endif
	DbSelectArea("BR8")
	BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA

	//Verifico se tem item de internacao
	For nI := 1 to len(aItens)
		If BR8->(DbSeek(xFilial("BR8")+cCodPad+Alltrim(PlsPtuGet("CD_SERVICO",aItens[nI])))) .And. BR8->BR8_TPPROC == '4'
			lItern := .T.
			Exit
		EndIf
	Next

	//Verifico se enviou uma RDA valida
	If lItern
		aRetRda := PLSRTPREST( Substr(cCodMed,len(cCodMed) - len(BAU->BAU_CODIGO)+1,len(cCodMed)),.T.,PlsIntPad() )
		If !aRetRda[1]
			lNaoPode := .T.
		Endif
	EndIf

	//Monta itens de retorno
	For nI := 1 to len(aItens)
		AaDd(aIteRet,{})
		PlsPtuLog("GERANDO INFORMACOES -> "+PlsPtuGet("CD_SERVICO",aItens[nI]))//Gera Log

		PlsPtuPut("TP_TABELA",PlsPtuGet("TP_TABELA",aItens[nI]),aIteRet[Len(aIteRet)])
		PlsPtuPut("CD_SERVICO",PlsPtuGet("CD_SERVICO",aItens[nI]),aIteRet[Len(aIteRet)])
		PlsPtuPut("QT_AUTORIZ",PlsPtuGet("QT_AUTORIZ",aItens[nI]),aIteRet[Len(aIteRet)])

		If BR8->(DbSeek(xFilial("BR8")+cCodPad+Alltrim(PlsPtuGet("CD_SERVICO",aItens[nI])))) .And. BR8->BR8_PROBLO <> "1" .And. !lNaoPode
			PlsPtuPut("ID_STATUS ","2",aIteRet[Len(aIteRet)])
		Else
			PlsPtuPut("ID_STATUS ","1",aIteRet[Len(aIteRet)])
			PlsPtuPut("CD_MENS_E1","2010",aIteRet[Len(aIteRet)])
		EndIf
		PlsPtuPut("SQ_ITEM",PlsPtuGet("SQ_ITEM",aItens[nI]),aIteRet[Len(aIteRet)])
	Next

	//Clona as matrizes para geracao do arquivo
	aDados := aClone(aCabRet)
	aItens := aClone(aIteRet)

	PlsPtuLog("***********************************************")
	PlsPtuLog("FINALIZANDO TRANSACAO 00807")
	PlsPtuLog("***********************************************")

	//Versao 6.0 ou superior gera aqui a guia de solicitacao
	For nI := 1 to len(aItens)
		nPosIDIte := Ascan(aItens[nI],{|x|Alltrim(x[1]) == "ID_STATUS"})

		If Alltrim(aItens[nI][nPosIDIte][2]) == "2"
			lOSAutori := .t.
			Exit
		EndIf
	Next

	//Se houve pelo menos um item autorizado gera guia para posterior solicitacao
	If lOSAutori
		if !lAuto
			StartJob("PTUOSV60",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,aDadosOS,aItensOS,aQuimioOS,aRadioOS)
		else
			PTUOSV60(/*cEmpAnt*/,/*cFilAnt*/,/*aThreads*/,aDadosOS,aItensOS,aQuimioOS,aRadioOS,lAuto)
		endIf
		aDadosOS := {}
		aItensOS := {}
	Endif


	PLPTGRVREN(aDados,aItens,AllTrim(cTranSol),"00806",cUniSol,AllTrim( PlsPtuGet(" CD_UNI_EXE",aDados) ),"2",cNomUsr  )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPREPTUA
Consulta de Dados do Prestador no Ptu Online (00318/00418)

@author  Microsiga
@version P11
@since   17.12.10
/*/
//-------------------------------------------------------------------
Function PLSPREPTUA(aAuto)
	LOCAL cTitulo := STR0456//"Consulta Prestador"
	LOCAL oFontTit	:= nil
	LOCAL oListBox	:= nil
	LOCAL bOKFor    := {|| IIF(VldConsPTU("2",cCodUnimed,,,,,cNomePrest),(nOpca := 1, oDlg:End()),nOpca := 0) }
	LOCAL bCancel   := {|| nOpca := 0, oDlg:End() }
	LOCAL nOpca     := 0
	LOCAL nFor      := 0
	LOCAL cCodUnimed := Space(4)
	LOCAL cNomePrest := Space(40)
	LOCAL cCNPJ      := Space(15)
	LOCAL cSigla     := Space(12)
	LOCAL cNumConsel := Space(15)
	LOCAL cUF        := Space(2)
	LOCAL aDados     := {}
	LOCAL aRetOln    := {}
	LOCAL aLog       := {}
	LOCAL aRet       := {}
	LOCAL cMsgXsdErr := ""
	LOCAL aDadosAuto := {}
	DEFAULT aAuto    := {.F.,""}

	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011


	//Define variaveis que serao utilizadas
	If PLSALIASEX("BSN")
		cTranOri := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranOri
		BSN->(MsUnLock())
		ConfirmSX8()
	Endif

	if aAuto[1]

		nOpca := 1
		aDadosAuto := aAuto[3]
		cCodUnimed := PlsPtuGet("CUNIDOM"   ,aDadosAuto)
		cNomePrest := PlsPtuGet("NM_PREST"  ,aDadosAuto)
		cCNPJ      := PlsPtuGet("CD_CGC_CPF",aDadosAuto)

	else
		//Define dialogo...
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.0,010.3 TO 034.4,100.3

		@ 020,005 SAY oSay PROMPT STR0457  SIZE 330,010 OF oDlg PIXEL  COLOR CLR_RED //"Consulta dados de prestador através da transação on-line"

		@ 050,005 SAY oSay PROMPT STR0420  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Código Unimed"
		@ 050,100 MSGET cCodUnimed SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 065,005 SAY oSay PROMPT STR0458  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"Nome Prestador"
		@ 065,100 MSGET cNomePrest SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 080,005 SAY oSay PROMPT STR0459  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"CNPJ/CPF Prestador"
		@ 080,100 MSGET cCNPJ SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 095,005 SAY oSay PROMPT STR0460  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"Sigla Conselho"
		@ 095,100 MSGET cSigla SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 110,005 SAY oSay PROMPT STR0461  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//""Número Conselho""
		@ 110,100 MSGET cNumConsel SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		@ 125,005 SAY oSay PROMPT STR0462  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"UF"
		@ 125,100 MSGET cUF SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		//Ativa dialogo....
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOKFor,bCancel,.F.) } )
	endIf

	If nOpca == 1

		//Verifica se a variavel existe											 |
		If Type('lComunica') == "U"
			lComunica := .T.
		EndIf

		//Monta array com dados para gerar a transacao 00318/00418
		PlsPtuPut("CD_TRANS","00418",aDados)
		PlsPtuPut("CUNIDOM",cCodUnimed,aDados)
		PlsPtuPut("CD_UNI_BEN",cCodUnimed,aDados)
		PlsPtuPut("NR_IDENT_E",cTranOri,aDados)
		PlsPtuPut("NM_PREST",cNomePrest,aDados)
		PlsPtuPut("CD_CGC_CPF",cCNPJ,aDados)
		PlsPtuPut("SG_CONS_PR",cSigla,aDados)
		PlsPtuPut("NR_CONS_PR",cNumConsel,aDados)
		PlsPtuPut("UF_CONS_PR",cUF,aDados)

		if aAuto[1]
			aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.T.,nil,nil,nil,@cMsgXsdErr,aAuto )
		else
			//Comunicacao e tratamento
			MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.F.,nil,nil,nil,@cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."
		endIf

		//Verifica se houve retorno 00210/00310 (falha na transacao)     			 |
		If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
			BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
			If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
				Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			Else
				PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
				Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			EndIf
			Return
		EndIf

		//Trata o Retorno da Comunicacao											 |
		If Len(aRetOln) > 0
			If PlsPtuGet("ID_CONFIRM",aRetOln[1]) == "S" .And. Len(aRetOln[2]) == 0
				Aviso( STR0120,STR0179,{ STR0146 }, 2 )  			   			    //"Atencao" //"Inconsistencia no retorno!" //"Ok"

				//Verifica se foi enviada a transacao correta na resposta       			 |
			ElseIf PlsPtuGet("CD_TRANS ",aRetOln[1]) <> "00419"
				AaDd(aLog,{STR0425,STR0426+"00419"})//"Transação de Resposta Incorreta"#"Diferente de"
				PLSCRIGEN(aLog,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"

				//Verifica se foi enviada uma critica na resposta 00419					 |
			ElseIf  PlsPtuGet("CD_TRANS ",aRetOln[1]) == "00419" .And. !Empty(PlsPtuGet("CD_MENS_ER ",aRetOln[1]))
				Do Case
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5001"
						cDescCri := " -> Nenhum registro encontrado"
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5002"
						cDescCri := " -> Problemas no processamento"
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5003"
						cDescCri := " -> Unimed Offline não responde esta transação"
				EndCase

				If PlsPtuGet("ID_CONFIRM ",aRetOln[1]) == "X"
					Aviso( STR0120,"Requisição Negada. Crítica: " +PlsPtuGet("CD_MENS_ER ",aRetOln[1])+cDescCri,{ STR0146 }, 2 )
				ElseIf PlsPtuGet("ID_CONFIRM ",aRetOln[1]) == "N"
					Aviso( STR0120,"Requisição apresentou erro(s). Crítica: " +PlsPtuGet("CD_MENS_ER ",aRetOln[1])+cDescCri,{ STR0146 }, 2 )
				EndIf

				//Processa resposta                                    					 |
			Else
				BA0->(DbSetOrder(1))
				BA0->(MsSeek(xFilial("BA0")+cCodUnimed))
				cNomOpe := BA0->BA0_NOMINT

				//Exibe dados parametros informados pelo usuario	    					 |
				AaDd(aLog,{STR0427,""})//"Parametros da Pesquisa"
				AaDd(aLog,{"",""})
				AaDd(aLog,{STR0237,cCodUnimed+" - "+cNomOpe})//"Operadora Origem
				AaDd(aLog,{STR0458,cNomePrest})//"Nome Prestador"
				AaDd(aLog,{STR0458,cCNPJ})//"CNPJ/CPF Prestador"
				AaDd(aLog,{STR0460,cSigla})//"Sigla Conselho"
				AaDd(aLog,{STR0461,cNumConsel})//"Número Conselho"
				AaDd(aLog,{STR0462,cUF})//"UF"
				AaDd(aLog,{STR0241,cTranOri})//Transacao Origem

				//Se a resposta veio negativa, finaliza o log e apresenta a critica        |
				If PlsPtuGet("ID_CONFIRM",aRetOln[1]) == "N"
					AaDd(aLog,{"----------------------------","------------------------------------"})
					If PlsPtuGet("CD_MENS_ER",aRetOln[1]) <> "0000"
						BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
						If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_ER",aRetOln[1])))
							AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})//"Código Mensagem Erro"
							AaDd(aLog,{STR0433,BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI})//"Crítica Sistema"
						Else
							AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})//"Código Mensagem Erro"
							AaDd(aLog,{STR0433,STR0434})//"Crítica Sistema"#"Não foi encontrada a crítica correspondente na tabela BCT"
						EndIf
					Else
						AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})//"Código Mensagem Erro"
					EndIf

					//Exibe prestadores retornados pela Unimed                                 |
				Else
					AaDd(aLog,{"",""})
					AaDd(aLog,{"----------------------------","------------------------------------"})
					AaDd(aLog,{STR0463,""})//"Prestadores Encontrados"
					AaDd(aLog,{"----------------------------","------------------------------------"})
					For nFor := 1 to len(aRetOln[2])
						AaDd(aLog,{STR0458,PlsPtuGet("NM_PREST",aRetOln[2][nFor])})//Nome Prestador
						AaDd(aLog,{STR0464,PlsPtuGet("CD_UNI_PRE",aRetOln[2][nFor])})//"Unimed Prestador"
						AaDd(aLog,{STR0135,PlsPtuGet("CD_PREST",aRetOln[2][nFor])})//"Código Prestador"

						BAQ->(DbSetOrder(5))//BAQ_FILIAL+BAQ_INTERC
						If BAQ->(DbSeek(xFilial("BAQ")+PlsPtuGet("CD_ESPEC",aRetOln[2][nFor]))) .And. BAQ->(FieldPos("BAQ_INTERC")) > 0
							AaDd(aLog,{STR0465,PlsPtuGet("CD_ESPEC",aRetOln[2][nFor])+" - "+BAQ->BAQ_DESCRI})//"Especialidade"
						Else
							AaDd(aLog,{STR0465,PlsPtuGet("CD_ESPEC",aRetOln[2][nFor])})//"Especialidade"
						EndIf

						If PlsPtuGet("ID_ALTO_CU",aRetOln[2][nFor]) == "1"
							AaDd(aLog,{STR0466,STR0326})//"Alto Custo"#"Sim"
						ElseIf PlsPtuGet("ID_ALTO_CU",aRetOln[2][nFor]) $ "2"
							AaDd(aLog,{STR0466,"Tabela Propria"})//"Alto Custo"#"Tabela Propria"
						ElseIf PlsPtuGet("ID_ALTO_CU",aRetOln[2][nFor]) $ "3"
							AaDd(aLog,{STR0466,"Basico"})//"Alto Custo"#"Basico"
						EndIf

						If PlsPtuGet("TP_REDE_MIN",aRetOln[2][nFor]) == "1"
							AaDd(aLog,{"Tipo de Rede","Básica"})
						ElseIf PlsPtuGet("TP_REDE_MIN",aRetOln[2][nFor]) $ "2"
							AaDd(aLog,{"Tipo de Rede","Especial (Tabela Própria)"})//"Alto Custo"#"Tabela Propria"
						ElseIf PlsPtuGet("TP_REDE_MIN",aRetOln[2][nFor]) $ "3"
							AaDd(aLog,{"Tipo de Rede","Master (Alto Custo)"})//"Alto Custo"#"Basico"
						EndIf
						AaDd(aLog,{"----------------------------","------------------------------------"})
					Next
				EndIf

				if !aAuto[1]
					//Apresenta o resultado da transacao                                       |
					PLSCRIGEN(aLog,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"
				endIf
			EndIf
		Else
			PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
			If !Empty(cMsgXsdErr)
				MsgInfo(cMsgXsdErr)
			Else
				Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			EndIf
			AaDd(aRet,{"3" ,"000",{ { __aCdCri065[1],PLSBCTDESC(),"" } } ,"","",""} )
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUSRPTUA
Consulta de Dados do Beneficiário no Ptu Online (00302)

@author  Microsiga
@version P11
@since   14.12.10
/*/
//-------------------------------------------------------------------
Function PLSUSRPTUA(aAuto)
	LOCAL cTitulo := STR0418 //"Consulta Dados do Beneficiario"
	LOCAL oFontTit
	LOCAL oListBox
	LOCAL bOKFor    := {|| IIF(VldConsPTU("1",cCodUnimed,cMatric,cFirstName,cLastName,dDataNasc,nil,cCPF),(nOpca := 1, oDlg:End()),nOpca := 0) }
	LOCAL bCancel   := {|| nOpca := 0, oDlg:End() }
	LOCAL nOpca     := 0
	LOCAL nFor      := 0
	LOCAL nLin      := 050
	LOCAL cCodUnimed := Space(4)
	LOCAL cMatric    := Space(17)
	LOCAL cFirstName := Space(25)
	LOCAL cLastName  := Space(10)
	LOCAL cCPF       := Space(11)
	LOCAL cCNS       := Space(15)
	LOCAL dDataNasc  := Ctod(Space(8))
	LOCAL aDados     := {}
	LOCAL aLog       := {}
	LOCAL aRetOln    := {}
	LOCAL aRet       := {}
	LOCAL cDescCri   := ""
	LOCAL cMsgXsdErr := ""
	LOCAL cAcomod    := ""
	LOCAL cAbrang    := ""
	LOCAL cData      := ""
	LOCAL lPTUOn80   := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	LOCAL cToken	 := space(10)
	LOCAL aDadosAuto := {}
	LOCAL lPTUOn90   := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
	DEFAULT aAuto    := {.F.,""}

	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011


	//Define variaveis que serao utilizadas
	If PLSALIASEX("BSN")
		cTranOri := StrZero( Val( BSN->(GetSx8Num("BSN","BSN_SEQUEN") ) ),10)
		BSN->(RecLock("BSN",.T.))
		BSN->BSN_FILIAL := xFilial("BSN")
		BSN->BSN_SEQUEN := cTranOri
		BSN->(MsUnLock())
		ConfirmSX8()
	Endif

	if aAuto[1]

		nOpca := 1
		aDadosAuto := aAuto[3]
		cCodUnimed := PlsPtuGet("CUNIDOM", aDadosAuto)

		If !lPTUOn90
			cFirstName := PlsPtuGet("NM_BENEF"  ,aDadosAuto)
			cLastName  := PlsPtuGet("SB_NM_BENE",aDadosAuto)
			dDataNasc  := PlsPtuGet("DT_NASC"   ,aDadosAuto)
		Else
			cMatric := PlsPtuGet("ID_BENEF", aDadosAuto)
			cCPF  := PlsPtuGet("NR_CPF", aDadosAuto)
		EndIf

	else
		//Define dialogo...
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.0,010.3 TO 034.4,100.3

		@ 020,005 SAY oSay PROMPT STR0419  SIZE 330,010 OF oDlg PIXEL  COLOR CLR_RED //"Consulta dados de beneficiários através da transação on-line"

		@ nLin,005 SAY oSay PROMPT STR0420  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED//"Código Unimed"
		@ nLin,100 MSGET cCodUnimed SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK

		nLin += 15
		@ nLin,005 SAY oSay PROMPT STR0421  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Matrícula"
		@ nLin,100 MSGET cMatric SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cCPF) .And. Empty(cCNS) .And. Empty(dDataNasc) .And. Empty(cFirstName) .And. Empty(cLastName)}

		If !lPTUOn90
			nLin += 15
			@ nLin,005 SAY oSay PROMPT STR0422  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Data Nascimento"
			@ nLin,100 MSGET dDataNasc SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cMatric) .And. Empty(cCPF) .And. Empty(cCNS) }

			nLin += 15
			@ nLin,005 SAY oSay PROMPT STR0423  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Primeiro Nome do Beneficiário"
			@ nLin,100 MSGET cFirstName SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cMatric) .And. Empty(cCPF) .And. Empty(cCNS)}

			nLin += 15
			@ nLin,005 SAY oSay PROMPT STR0424  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Último Nome do Beneficiário"
			@ nLin,100 MSGET cLastName SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cMatric) .And. Empty(cCPF) .And. Empty(cCNS)}
		EndIf

		nLin += 15
		@ nLin,005 SAY oSay PROMPT "Cadastro Pessoa Física - CPF" SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Cadastro Pessoa Física - CPF"
		@ nLin,100 MSGET cCPF SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cMatric) .And. Empty(cCNS) .And. Empty(dDataNasc) .And. Empty(cFirstName) .And. Empty(cLastName)}

		If !lPTUOn90
			nLin += 15
			@ nLin,005 SAY oSay PROMPT "Cartão Nacional de Saúde - CNS"  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Cartão Nacional de Saúde - CNS"
			@ nLin,100 MSGET cCNS SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||Empty(cMatric) .And. Empty(cCPF) .And. Empty(dDataNasc) .And. Empty(cFirstName) .And. Empty(cLastName)}
		EndIf

		If lPTUOn80
			nLin += 15
			@ nLin,005 SAY oSay PROMPT "Token"  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED //"Token"
			@ nLin,100 MSGET cToken SIZE 080,006 OF oDlg PIXEL FONT oFontTit COLOR CLR_BLACK
		EndIf

		//Ativa dialogo....
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOKFor,bCancel,.F.) } )
	endIf

	If nOpca == 1

		//Verifica se a variavel existe											 |
		If Type('lComunica') == "U"
			lComunica := .T.
		EndIf

		//Monta array com dados para gerar a transacao 00412
		PlsPtuPut("CD_TRANS","00412",aDados)
		PlsPtuPut("CUNIDOM",cCodUnimed,aDados)
		PlsPtuPut("CD_UNI_BEN",cCodUnimed,aDados)
		PlsPtuPut("NR_IDENT_E",cTranOri,aDados)
		PlsPtuPut("CD_UNI",cCodUnimed,aDados)
		PlsPtuPut("ID_BENEF",IIF(lPTUOn80,PadL(Substr(cMatric,5,13),13,"0"),Substr(cMatric,5,13)),aDados)

		If !lPTUOn90
			PlsPtuPut("DT_NASC",DtoS(dDataNasc),aDados)
			PlsPtuPut("NM_BENEF",cFirstName,aDados)
			PlsPtuPut("SB_NM_BENE",cLastName,aDados)				
		EndIf

		PlsPtuPut("NR_CPF",cCPF,aDados)

		If !lPTUOn90
			PlsPtuPut("NR_CNS",cCNS,aDados)
		EndIf
		
		If lPTUOn80
			PlsPtuPut("TOKEN",cToken,aDados)
		EndIf

		if aAuto[1]
			aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.T.,nil,nil,nil,@cMsgXsdErr,aAuto )
		else
			//Comunicacao e tratamneto												 |
			MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3),,.F.,nil,nil,nil,@cMsgXsdErr ) }, 'Comunicando' , STR0177, .F.) //"Aguarde..."
		endif

		//Verifica se houve retorno 00210/00310 (falha na transacao)       		 |
		If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
			BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
			If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
				Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			Else
				PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
				Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			EndIf
			Return
		EndIf

		//Trata o Retorno da Comunicacao											 |
		If Len(aRetOln) > 0
			If PlsPtuGet("ID_CONFIRM",aRetOln[1]) == "S" .And. Len(aRetOln[2]) == 0
				Aviso( STR0120,STR0179,{ STR0146 }, 2 )  			   			    //"Atencao" //"Inconsistencia no retorno!" //"Ok"

				//Verifica se foi enviada a transacao correta na resposta					 |
			ElseIf PlsPtuGet("CD_TRANS ",aRetOln[1]) <> "00413"
				AaDd(aLog,{STR0425,STR0426+"00413"})//"Transacao de Resposta Incorreta"##"Diferente de "
				PLSCRIGEN(aLog,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"

				//Verifica se foi enviada uma critica na resposta 00413					 |
			ElseIf  PlsPtuGet("CD_TRANS ",aRetOln[1]) == "00413" .And. !Empty(PlsPtuGet("CD_MENS_ER ",aRetOln[1]))

				Do Case
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5001"
						cDescCri := " -> Nenhum registro encontrado"
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5002"
						cDescCri := " -> Problemas no processamento"
					Case PlsPtuGet("CD_MENS_ER ",aRetOln[1]) == "5003"
						cDescCri := " -> Unimed Offline não responde esta transação"
				EndCase

				If PlsPtuGet("ID_CONFIRM ",aRetOln[1]) == "X"
					Aviso( STR0120,"Requisição Negada. Crítica: " +PlsPtuGet("CD_MENS_ER ",aRetOln[1])+cDescCri,{ STR0146 }, 2 )
				ElseIf PlsPtuGet("ID_CONFIRM ",aRetOln[1]) == "N"
					Aviso( STR0120,"Requisição apresentou erro(s). Crítica: " +PlsPtuGet("CD_MENS_ER ",aRetOln[1])+cDescCri,{ STR0146 }, 2 )
				EndIf

				//Processa resposta                                   					 |
			Else
				BA0->(DbSetOrder(1))
				BA0->(MsSeek(xFilial("BA0")+cCodUnimed))
				cNomOpe := BA0->BA0_NOMINT

				//Exibe parametros informados pelo usuario			    				 |
				AaDd(aLog,{STR0427,""})//Parametros da Pesquisa
				AaDd(aLog,{"",""})
				AaDd(aLog,{STR0237,cCodUnimed+" - "+cNomOpe})//"Operadora Origem
				AaDd(aLog,{STR0428,cMatric})//"Matrícula"
				If !lPTUOn90
					cData := DtoS(dDataNasc)
					cData := Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/" +Substr(cData,1,4)
					AaDd(aLog,{STR0429,cData})//"Data Nascimento"
					AaDd(aLog,{STR0430,cFirstName})//""Primeiro Nome"
					AaDd(aLog,{STR0431,cLastName})//"Último Nome"
				EndIf
				AaDd(aLog,{STR0241,cTranOri})//Transacao Origem

				//Se a resposta veio negativa, finaliza o log e apresenta a critica        |
				If PlsPtuGet("ID_CONFIRM",aRetOln[1]) == "N"
					AaDd(aLog,{"----------------------------","------------------------------------"})
					If PlsPtuGet("CD_MENS_ER",aRetOln[1]) <> "0000"
						BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
						If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_ER",aRetOln[1])))
							AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})//"Código Mensagem Erro"
							AaDd(aLog,{STR0433,BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI})//"Crítica Sistema"
						Else
							AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})////"Código Mensagem Erro"
							AaDd(aLog,{STR0433,STR0434})//"Crítica Sistema"##"Não foi encontrada a crítica correspondente na tabela BCT"
						EndIf
					Else
						AaDd(aLog,{STR0432,PlsPtuGet("CD_MENS_ER",aRetOln[1])})////"Código Mensagem Erro"
					EndIf

					//Exibe usuarios enviados pela Unimed                                      |
				Else
					AaDd(aLog,{"",""})
					AaDd(aLog,{"----------------------------","------------------------------------"})
					AaDd(aLog,{STR0435,""})//"Beneficiários Encontrados"
					AaDd(aLog,{"----------------------------","------------------------------------"})
					For nFor := 1 to len(aRetOln[2])

						If !lPTUOn90
							AaDd(aLog,{STR0436,PlsPtuGet("NM_BENEF",aRetOln[2][nFor])})//"Nome"
					
							cData := PlsPtuGet("DT_NASC",aRetOln[2][nFor])
							cData := Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/" +Substr(cData,1,4)
							AaDd(aLog,{STR0429,cData})//Data Nascimento

							AaDd(aLog,{STR0437,PlsPtuGet("M_EMPR_ABR",aRetOln[2][nFor])})//"Empresa Abreviada"
						EndIf

						
						AaDd(aLog,{STR0438,PlsPtuGet("CD_UNI",aRetOln[2][nFor])})//"Unimed Beneficiário"
						AaDd(aLog,{STR0428,PlsPtuGet("CD_UNI",aRetOln[2][nFor])+PlsPtuGet("ID_BENEF",aRetOln[2][nFor])})//"Matrícula"
						AaDd(aLog,{STR0439,PlsPtuGet("NM_COMPL_B",aRetOln[2][nFor])})//"Nome Completo
						If !lPTUOn90
							AaDd(aLog,{STR0440,PlsPtuGet("NM_PLANO",aRetOln[2][nFor])})//"Plano"
						EndIf

						cAcomod := Alltrim(PlsPtuGet("TP_ACOMOD",aRetOln[2][nFor]))
						Do Case
							Case Upper(cAcomod) == "A"
								cAcomod := STR0619 //"A=Coletiva"
							Case Upper(cAcomod) == "B"
								cAcomod := STR0620 //"B=Individual"
							Case Upper(cAcomod) == "C"
								cAcomod := STR0621 //"C=Não Se Aplica"
						EndCase
						AaDd(aLog,{STR0441,cAcomod})//"Acomodação"

						cAbrang := PlsPtuGet("TP_ABRANGE",aRetOln[2][nFor])
						Do Case
							Case cAbrang == "1"
								AaDd(aLog,{STR0442,STR0443})//"Abrangência"#"1=Nacional"
							Case cAbrang == "2"
								AaDd(aLog,{STR0442,STR0444})//"Abrangência"#"2=Regional A - Grupo de Estados"
							Case cAbrang == "3"
								AaDd(aLog,{STR0442,STR0445})//"Abrangência"#"3=Estadual"
							Case cAbrang == "4"
								AaDd(aLog,{STR0442,STR0446})//"Abrangência"#"4=Regional B - Grupo de Municípios"
							Case cAbrang == "5"
								AaDd(aLog,{STR0442,STR0447})//"Abrangência"#"5=Municipal"
						EndCase
						AaDd(aLog,{STR0448,PlsPtuGet("CD_LCAT",aRetOln[2][nFor])})//"Local Cobrança"

						cData := PlsPtuGet("DT_INCL_UN",aRetOln[2][nFor])
						cData := Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/" +Substr(cData,1,4)
						AaDd(aLog,{STR0449,cData})//"Data Inclusão"

						cData := PlsPtuGet("DT_EXCL_UN",aRetOln[2][nFor])
						If !Empty(cData)
							cData := Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/" +Substr(cData,1,4)
						EndIf
						AaDd(aLog,{STR0450,cData})//"Data Exclusão"

						If !lPTUOn90
							cData := PlsPtuGet("DT_VAL_CAR",aRetOln[2][nFor])
							cData := Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/" +Substr(cData,1,4)
							AaDd(aLog,{STR0451,cData})//"Data Validade Cartão"

							If PlsPtuGet("TP_SEXO",aRetOln[2][nFor])$ "Mm"
								AaDd(aLog,{STR0452,STR0453})//Sexo#Masculino
							ElseIf PlsPtuGet("TP_SEXO",aRetOln[2][nFor])$ "Ff"
								AaDd(aLog,{STR0452,STR0454})//Sexo#Feminino
							EndIf
	
							AaDd(aLog,{STR0455,PlsPtuGet("NR_VIA_CAR",aRetOln[2][nFor])})//Via Cartão
						EndIf

						AaDd(aLog,{"Rede de Atendimento",PlsPtuGet("CD_REDE",aRetOln[2][nFor])})//Rede de Atendimento
						If !lPTUOn90
							Do Case
								Case PlsPtuGet("ID_PLANO",aRetOln[2][nFor]) == "1"
									AaDd(aLog,{"Identificador do plano","1 - Plano Não Regulamentado"})//1 - Plano Não Regulamentado
								Case PlsPtuGet("ID_PLANO",aRetOln[2][nFor]) == "2"
									AaDd(aLog,{"Identificador do plano","2 - Plano Adaptado"})//2 - Plano Adaptado
								Case PlsPtuGet("ID_PLANO",aRetOln[2][nFor]) == "3"
									AaDd(aLog,{"Identificador do plano","3 - Plano Regulamentado"})//3 - Plano Regulamentado
							EndCase
						EndIf

						AaDd(aLog,{"----------------------------","------------------------------------"})
					Next
				EndIf

				if !aAuto[1]
					//Apresenta o resultado da transacao                                       |
					PLSCRIGEN(aLog,{ {STR0243,"@C",90} , {STR0244,"@C",80 } },STR0245) //"Campo"###"Conteudo"###"Resumo da Comunicacao"
				endIf

			EndIf
		Else
			PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
			AaDd(aRet,{"3" ,"000",{ { __aCdCri065[1],PLSBCTDESC(),"" } } ,"","",""} )
			If !Empty(cMsgXsdErr)
				MsgInfo(cMsgXsdErr)
			Else
				Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0146 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
			EndIf
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VldConsPTU
Valida o preenchimento das consultas de dados do PTU OnLine

@author  Microsiga
@version P11
@since   14.12.10
/*/
//-------------------------------------------------------------------
Static Function VldConsPTU(cTipo,cCodUnimed,cMatric,cFirstName,cLastName,dDataNasc,cNomePres,cCPF)
	
	Local lRet := .T.
	Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"

	Default cCPF := ""

	If Empty(cCodUnimed) .Or. cCodUnimed == PlsIntPad() .Or. (Val(cCodUnimed) < 1 .Or. Val(cCodUnimed) > 999) .Or. len(Alltrim(cCodUnimed)) <> 4
		Aviso( STR0120,STR0476,{ STR0146 }, 2 ) //"Atencao" //"Código de operadora informado inválido" //"Ok"
		lRet := .F.
	ElseIf cTipo == "1" .And. Empty(cMatric) .And. IIf(lPTUOn90, Empty(cCPF), ((Empty(cFirstName) .And. Empty(cLastName) ) .Or. Empty(dDataNasc)))
		If lPTUOn90
			Aviso( STR0120, "Necessário informar a matrícula ou CPF do beneficiário", { STR0146 }, 2)
		Else
			Aviso( STR0120,STR0477,{ STR0146 }, 2 ) //"Atencao" //"Necessário informar a matrícula OU primeiro/último nome e data de nascimento do beneficiário" //"Ok"
		EndIf
		lRet := .F.
	ElseIf cTipo == "2" .And. Empty(cNomePres)
		Aviso( STR0120,STR0478,{ STR0146 }, 2 ) //"Atencao" //"Obrigatório o preechimento do nome do prestador" //"Ok"
		lRet := .F.
	ElseIf cTipo == "1" .And. !Empty(cMatric) .And. Empty(cFirstName) .And. Empty(cLastName) .And. len(Alltrim(cMatric)) <> 17
		Aviso( STR0120,"Necessário preencher a matrícula completa (17 caracteres)",{ STR0146 }, 2 ) //"Atencao" //"Necessário preencher a matrícula completa (17 caracteres)" //"Ok"
		lRet := .F.
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RegTranB93
Registra transacao em processamento para evitar duplicidade³

@author  Microsiga
@version P11
@since   11.08.14
/*/
//-------------------------------------------------------------------
Static Function RegTranB93(cOpeSol,cTipTra,cNrTrol)
	Local lRet := .T.
	Local cSql := ""

	//A cada meia hora limpa a tabela dos registros ja processados/deletados
	If Substr(Time(),4,2) $ "00/30"
		cSql := " DELETE FROM " + RetSQLName("B93")
		cSql += " WHERE B93_FILIAL = '"+xFilial("B93")+"' AND D_E_L_E_T_ = '*' "
		TCSqlExec(cSql)
	EndIf

	//Deleta registros pendentes caso algum processamento nao foi finalizado por erro
	B93->(DbSetOrder(1))//B93_FILIAL+B93_OPESOL+B93_NRTROL+B93_TIPTRA
	B93->(DbGoTop())
	While !B93->(Eof())
		If Val(Substr(Time(),4,2)) - Val(Substr(B93->B93_HORA,3,2)) > 5 .Or. ;
				( Val(Substr(Time(),1,2)) > Val(Substr(B93->B93_HORA,1,2)) .And. (Val(Substr(Time(),4,2)) +60) - Val(Substr(B93->B93_HORA,3,2)) > 5 ) .Or. ;
				dDataBase > B93->B93_DATA

			B93->(RecLock("B93",.F.))
			B93->(DbDelete())
			B93->(MsUnLock())

		EndIf
		B93->(DbSkip())
	EndDo

	//Verifica se a transacao esta em processamento                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If B93->(DbSeek(xFilial("B93")+cOpeSol+cNrTrol+Space(TamSX3("B93_NRTROL")[1]-len(cNrTrol))+cTipTra))
		PlsPtuLog(" ATENÇÃO")
		PlsPtuLog("******************************************************")
		PlsPtuLog("A transacao '"+cNrTrol+"' da Operadora '"+cOpeSol+"' ainda esta em processamento." )
		PlsPtuLog("******************************************************")
		PlsPtuLog("")
		lRet := .F.
	Else
		B93->(RecLock("B93",.T.))
		B93->B93_FILIAL := xFilial("B93")
		B93->B93_OPESOL := cOpeSol
		B93->B93_NRTROL := cNrTrol
		B93->B93_TIPTRA := cTipTra
		B93->B93_DATA   := dDataBase
		B93->B93_HORA   := Substr(Time(),1,2)+Substr(Time(),4,2)
		B93->(MsUnLock())
	EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} DelTranB93
Finaliza processamento de uma transaco liberando a mesma

@author  Microsiga
@version P11
@since   11.08.14
/*/
//-------------------------------------------------------------------
Static Function DelTranB93(cOpeSol,cTipTra,cNrTrol)

	B93->(DbSetOrder(1))//B93_FILIAL+B93_OPESOL+B93_NRTROL+B93_TIPTRA
	If B93->(DbSeek(xFilial("B93")+cOpeSol+cNrTrol+Space(TamSX3("B93_NRTROL")[1]-len(cNrTrol))+cTipTra))
		B93->(RecLock("B93",.F.))
		B93->(DbDelete())
		B93->(MsUnLock())
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PTUDePaBTU
Realiza De/Para de codigos procedimentos atraves da BTU

@author  Microsiga
@version P11
@since   11.08.14
/*/
//-------------------------------------------------------------------
Function PTUDePaBTU(cTipTab,cCodPro,cCodPad,lReceb,lEnvio,lRegraPTU)

	Local lOk := .F.
	Local aRet := {}
	Local lPTUOn80 := "0"+GetNewPar("MV_PTUVEON","80") >= "080"
	Local cTabRef := "" // Tabela TISS de Referencia quando o TipoTabela for igual a 00

	Default lEnvio := .F.
	Default lReceb := .F.
	Default lRegraPTU := .F.

	/* Tipo de Tabela
	18 = TUSS Taxas hospitalares, diárias e gases medicinais
	19 = TUSS Materiais
	20 = TUSS Medicamentos
	22 = TUSS Procedimentos e eventos em saúde (medicina, odonto e demais áreas de saúde)
	98 = Tabela Própria de Pacotes
	00 = Tabela Própria das Operadoras
	*/

	// Quandor for tab 00 retirar os dois primeiros digitos que corresponde tipo de tabela TISS de referência
	If cTipTab == "00" .And. lRegraPTU .And. lReceb .And. lPTUOn80
		cTabRef := Substr(cCodPro,1,2)
		cCodPro := Substr(cCodPro,3)
	EndIf

	// Para códigos próprios (não pertencentes à TUSS) das tabelas nacionais TNUMM, Rol Unimed e Tabela 18 Unimed
	// será informados com 10 dígitos, sendo os 2 primeiros com o tipo de tabela de referência da TUSS.
	If lReceb .And. Len(cCodPro) >= 10
		cCodPro := Substr(cCodPro, 3)
	EndIf

	cCodPro := Alltrim(cCodPro)

	If lReceb
		BTU->(DbSetOrder(7))//BTU_FILIAL+BTU_ALIAS+BTU_CDTERM+BTU_CODTAB
		If BTU->(DbSeek(xFilial("BTU")+"BR8"+cCodPro))

			While BTU->(BTU_FILIAL+BTU_ALIAS)+Alltrim(BTU->BTU_CDTERM) == xFilial("BTU")+"BR8"+cCodPro .And. !BTU->(Eof())

				If Alltrim(BTU->BTU_CODTAB) <> cTipTab .And. lRegraPTU
					BTU->(DbSkip())
					Loop
				EndIf

				BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
				If BR8->(DbSeek(Rtrim(BTU->BTU_VLRSIS)))
					If lRegraPTU
						Do Case
							Case cTipTab == "18" .Or. cTabRef == "18"
								If BR8->BR8_TPPROC $ "3/4/7"
									lOk := .T.
								EndIf
							Case cTipTab == "19" .Or. cTabRef == "19"
								If BR8->BR8_TPPROC $ "1/5"
									lOk := .T.
								EndIf
							Case cTipTab == "20" .Or. cTabRef == "20"
								If BR8->BR8_TPPROC == "2"
									lOk := .T.
								EndIf
							Case cTipTab == "22" .Or. cTabRef == "22"
								If Empty(BR8->BR8_TPPROC) .Or. BR8->BR8_TPPROC == "0"
									lOk := .T.
								EndIf
							Case cTipTab == "98"
								If BR8->BR8_TPPROC == "6"
									lOk := .T.
								EndIf

						EndCase
					Else
						Do Case
							Case cTipTab == "0" //ROL Unimed/AMB/CBHPM
								If Empty(BR8->BR8_TPPROC) .Or. BR8->BR8_TPPROC == "0"
									lOk := .T.
								EndIf
							Case cTipTab == "1" //Serviços Hospitalares / Taxas / Complementos (Códigos da Tabela C - Anexo 01)
								If BR8->BR8_TPPROC $ "34"
									lOk := .T.
								EndIf
							Case cTipTab == "2" //Materiais (Códigos da Tabela E - Anexo 01)
								If BR8->BR8_TPPROC $ "15"
									lOk := .T.
								EndIf
							Case cTipTab == "3" //3 = Medicamentos (Códigos da Tabela D - Anexo 01)
								If BR8->BR8_TPPROC $ "2"
									lOk := .T.
								EndIf
							Case cTipTab == "4" //4 = Serviço com Custo Fechado / Pacote (ainda sem códigos definidos)
								If BR8->BR8_TPPROC $ "678"
									lOk := .T.
								EndIf
							Case cTipTab $ "5"
								If BR8->BR8_TPPROC $ "15"
									lOk := .T.
								EndIf
							Case cTipTab $ "6"
								If BR8->BR8_TPPROC $ "2"
									lOk := .T.
								EndIf

						EndCase
					EndIf
				EndIf
				If lOk
					Exit
				EndIf
				BTU->(DbSkip())
			Enddo
		EndIf
		If lOk
			aRet := {BR8->BR8_CODPAD,Alltrim(BR8->BR8_CODPSA),BR8->BR8_DESCRI}
		EndIf

	ElseIf lEnvio
		BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
		If BR8->(DbSeek(xFilial("BR8")+cCodPad+cCodPro))
			BTU->(DbSetOrder(6))//BTU_FILIAL+BTU_ALIAS+BTU_VLRSIS+BTU_CODTAB
			If BTU->(DbSeek(xFilial("BTU")+"BR8"+BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA)))
				lOk := .T.
			EndIf
		EndIf
		If lOk
			If lRegraPTU .And. cTipTab == "00" // Regra para utilizar no PTU 8
				Do Case
					Case BR8->BR8_TPPROC == '0' .Or. Empty(BR8->BR8_TPPROC) // Procedimento
						cTabRef := '22'
					Case BR8->BR8_TPPROC $ '1/5' // Material e Ortese/Protese
						cTabRef := '19'
					Case BR8->BR8_TPPROC == '2' // Medicamento
						cTabRef := '20'
					Case BR8->BR8_TPPROC == '6' // Pacote
						cTabRef := '98'
					OtherWise // Taxas, Diarias, Gases Medicinais, Alugueis e Outros
						cTabRef := '18'
				EndCase

				aRet := {BR8->BR8_CODPAD,cTabRef+Alltrim(BTU->BTU_CDTERM),BR8->BR8_DESCRI}
			Else

				aRet := {BR8->BR8_CODPAD,Alltrim(BTU->BTU_CDTERM),BR8->BR8_DESCRI}
			EndIf
		EndIf

	EndIf

	if ExistBlock("PLPTUBTU")
		aRet := ExecBlock("PLPTUBTU",.F.,.F.,{lReceb,lEnvio,cTipTab,cCodPad,cCodPro,aRet,BR8->(Recno()),cTabRef,lRegraPTU})
	endIf

Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PTUOSV50
Processa Ordem de Servico para a versao 5.0 ou superior
Gera uma guia e faz uma solicitacao (00600) para a Operadora Origem do beneficiario

@author  Microsiga
@version P11
@since   13.10.14
/*/
//-------------------------------------------------------------------
Function PTUOSV50(cEmp,cFil,aThreads,aDados,aItens,lAuto)
	Local aRet      	:= {}
	Local aIte      	:= {}
	Local aPlPtuIte 	:= {}
	Local cTipo     	:= "2"
	Local lIntern  	 	:= .F.
	Local cSql      	:= ""
	Local nI        	:= 0
	Local nPos      	:= 0
	Local cCodUsu   	:= ""
	LOCAL lConverProc	:= .F.
	LOCAL cCodMed   	:= ""
	LOCAL aRetRDA   	:= {}
	LOCAL dData
	LOCAL lPLPtuIte     := .F.
	LOCAL cCodPad       := ""
	LOCAL lPTUOn80
	Default aThreads    := {}
	Default lAuto       := .F.

	if !lAuto
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	endIf

	lConverProc	:= !Empty(GetNewPar("MV_PTUTAB2"," "))
	cCodMed   	:= PlsPtuGet("CD_PREST",aDados)
	dData    	:= date()
	cCodPad     := SubStr( GETMV("MV_PLSTBPD") ,1,2)
	lPLPtuIte   := ExistBlock("PLPTUITE")
	cIdUsuResp  := GetNewPar( "MV_PLRESRN" , "" )
	lPTUOn80	:= Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"

	For nI := 1 to Len(aItens)

		//Monta campos
		cCodPro  := PlsPtuGet("CD_SERVICO",aItens[nI])

		//Ponto de entrada para troca de procedimento
		If lPLPtuIte
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECENT","",PlsPtuGet("TP_TABELA",aItens[nI]),cCodPad,cTranOri,nil})
			cCodPad := aPlPtuIte[1]
			cCodPro := aPlPtuIte[2]
		Else
			// De-para pela tabela BTU (Terminologia TISS)
			If lPTUOn80
				If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_EXE",aDados))
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),Alltrim(GetNewPar("MV_PLPACPT")),nil,.T.,,.T.)
				Else
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,nil,.T.,,.T.)
				EndIf
				If len(aRetBTU) > 0
					cCodPad := aRetBTU[1]
					cCodPro := aRetBTU[2]
				EndIf
			Else
				//Realiza De/Para AMB/CBHPM
				If lConverProc

					PLBusProTab(cCodPro,.F.,,,lConverProc,,,,cCodPad)

					If BR8->(Found())
						cCodPad := BR8->BR8_CODPAD
						cCodPro := BR8->BR8_CODPSA
					EndIf
					//Realiza De/Para BR8_CODEDI ou tabela B1M
				ElseIf GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(cCodPro,.F.,,dDataAt,,,,,)

					If BR8->(Found())
						cCodPad := BR8->BR8_CODPAD
						cCodPro := BR8->BR8_CODPSA
					Endif
					//Realiza De/Para com a tabela de terminologias TISS BTU
				ElseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,nil,.T.)

					If len(aRetBTU) > 0
						cCodPad := aRetBTU[1]
						cCodPro := aRetBTU[2]
					EndIf
				EndIf
			EndIf
		EndIf

		nQtd := Val(Substr(PlsPtuGet("QT_AUTORIZ",aItens[nI]),1,4)+"."+Substr(PlsPtuGet("QT_AUTORIZ",aItens[nI]),5,4))

		//Verifica se e uma consulta ou sadt
		If Len(aItens) == 1 .And. PLSISCON(cCodPad,cCodPro)
			cTipo := "1"
		EndIf

		//Nova Matriz
		AaDd(aIte,{})
		AaDd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
		AaDd(aIte[nI],{"CODPAD",cCodPad })
		AaDd(aIte[nI],{"CODPRO",cCodPro })
		AaDd(aIte[nI],{"QTD",nQtd })
		AaDd(aIte[nI],{"QTDAUT",nQtd })

		BR8->(DbSetOrder(1))
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
			If lPTUOn80
				// 18 = TUSS Taxas hospitalares,diárias e gases medicinais
				// 19 = TUSS Materiais
				// 20 = TUSS Medicamentos
				// 22 = TUSS Procedimentos e eventos em saúde(medicina,odonto e demais áreas de saúde)
				// 98 = Tabela Própria de Pacotes
				// 00 = Tabela Própria das Operadoras
				TpTab := PtTpTabTus(,,.T.)
			Else
				//³0=Procedimento	(0=AMB)
				//³1=Material	    (2=Material)
				//³2=Medicamento	(3=Medicamento)
				//³3=Taxas			(1=Hospitalar)
				//³4=Diarias		(1=Hospitalar)
				//³5=Ortese/Protese	(1=Hospitalar)
				//³6=Pacote 		(1=Hospitalar)
				TpTab := Iif(BR8->BR8_TPPROC=='0' .Or. BR8->BR8_TPPROC==' ','0',Iif(BR8->BR8_TPPROC=='1','2',Iif(BR8->BR8_TPPROC=='2','3',Iif(BR8->BR8_TPPROC=='6','4','1') ) ) )
			EndIf
			//Se for diraria e uma internacao ou quando o tipo da guia for 3 - Internação
			If (BR8->BR8_TPPROC == '4' .And. !lEvoSadt) .Or. (PlsPtuGet("TP_GUIA",aDados) == "3" .And. !lEvoSadt)
				lIntern := .T.
				cTipo	:= "3"
			EndIf
			//se e procedimento cirurgico
			AaDd(aIte[nI],{"PROCCI",If(BR8->BR8_TIPEVE$"2,3","1","0") })

		EndIf
	Next

	//Vou buscar o Solicitante
	aRetRda := PLSRTCRDAO( PlsPtuGet("CD_UNI_SOL",aDados),cCodMed )
	If aRetRDA[1]
		PlsPtuPut("CDPFSO",aRetRda[6],aDados)
		PlsPtuPut("CDPFEX",aRetRda[6],aDados)
	Else
		PlsPtuLog("VERIFICAR A RDA")
		PlsPtuLog("*** NAO AUTORIZADO ***")
		PlsPtuLog(aRetRDA[2])
	EndIf

	aRetRda := PLSRTPREST( Substr(cCodMed,len(cCodMed) - len(BAU->BAU_CODIGO)+1,len(cCodMed)) )
	If aRetRDA[1]
		PlsPtuPut("CODRDA",aRetRda[3],aDados)
		PlsPtuPut("CODLOC",aRetRda[4],aDados)
		PlsPtuPut("CODESP",aRetRda[5],aDados)
		PlsPtuPut("TPPRES",aRetRda[6],aDados)
		PlsPtuPut("TPRDA" ,aRetRda[7],aDados)
	Else
		PlsPtuLog("VERIFICAR A RDA")
		PlsPtuLog("*** NAO AUTORIZADO ***")
		PlsPtuLog(aRetRDA[2])
	EndIf

	BA1->(DbSetOrder(5)) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
	If BA1->(DbSeek(xFilial("BA1")+PlsPtuGet("CD_UNI",aDados)+PlsPtuGet("ID_BENEF",aDados)))
		PlsPtuPut("USUARIO",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),aDados)
	Else
		PlsPtuPut("USUARIO",PlsPtuGet("CD_UNI",aDados)+PlsPtuGet("ID_BENEF",aDados),aDados)
	Endif

	PlsPtuPut("INTERN",lIntern,aDados)
	PlsPtuPut("TIPO",cTipo,aDados)
	If cTipo <> "3"
		PlsPtuPut("ORIGEM","2",aDados)
	EndIf
	PlsPtuPut("PTUONOS",.T.,aDados)
	PlsPtuPut("NOMUSR",PlsPtuGet("NM_BENEF",aDados),aDados)
	PlsPtuPut("TRANORDSERV",StrZero(Val(PlsPtuGet("NR_IDENT_S",aDados)),10),aDados)
	PlsPtuPut("DATPRO",dData,aDados)
	PlsPtuPut("OPEMOV",PlsIntPad(),aDados)
	PlsPtuPut("OPESOLOS",PlsPtuGet("CD_UNI_SOL",aDados),aDados)

	If (nPos := aScan(aDados,{|x|x[1] == "PTUONLINE" })) > 0
		aDados[nPos][2] := .F.
	EndIf

	//Grava a guia e envia a transacao 00600, apos o retorno 00501 na orderm de servico/triangulacao tenho que enviar o 00804.
	//Neste momento dentro do xmov a funcao PLSXMOVONL sera acionada que por sua vez aciona a PLSANAINT que
	//faz a comunicacao enviando 00600 e trata o retorno 00501.

	aRet := PLSXAUTP(aDados,aIte)

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PTUAUTOSV5
Processa triangulacao para a versao 5.0 ou superior, envia a confirmacao 00804

@author  Microsiga
@version P11
@since   13.10.14
/*/
//-------------------------------------------------------------------
Function PTUAUTOSV5(aDadosCab,aItens,cTraOrig,cTraPrest,cTraOriBen,cDatValAut,cOpeSol)
	Local aDados     := {}
	Local aGrvTraPTU := {}
	Local lWeb       := .T.
	Local nCont      := 0
	local nY		 := 0
	Local cMsgXsdErr := ""
	local dDataAt    := stod(PlsPtuGet("DT_ATENDIM",aDados))
	LOCAL cCodPad    := SubStr( GETMV("MV_PLSTBPD") ,1,2)
	LOCAL lPLPtuIte  := existBlock("PLPTUITE")
	Local lPTUOn80	 := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"

	PlsPtuLog("***********************************")
	PlsPtuLog("GERANDO TRANSACAO 00804")
	PlsPtuLog("***********************************")

	PlsPtuLog("codigoTransacao => 00804")
	PlsPtuLog("codigoUnimedOrigemBeneficiario => "+PlsIntPad())
	PlsPtuLog("codigoUnimedPrestadora => "+PlsPtuGet("CD_UNI_DES",aDadosCab))
	PlsPtuLog("codigoUnimedSolicitante => "+cOpeSol)
	PlsPtuLog("numeroTransacaoPrestadora => "+cTraPrest)
	PlsPtuLog("numeroTransacaoOrigemBeneficiario => "+cTraOriBen)
	PlsPtuLog("numeroTransacaoUnimedSolicitante => "+cTraOrig)
	PlsPtuLog("dataValidadeAutorizacao => "+cDatValAut)
	PlsPtuLog("CUNIDOM => "+cOpeSol)
	PlsPtuLog("")

	PlsPtuPut("CD_TRANS","00804",aDados)
	PlsPtuPut("CD_UNI_EXE",PlsIntPad(),aDados)
	PlsPtuPut("CD_UNI_BEN",PlsPtuGet("CD_UNI_DES",aDadosCab),aDados)
	PlsPtuPut("CD_UNI_SOL",cOpeSol,aDados)
	PlsPtuPut("NR_IDENT_E",cTraPrest,aDados)
	PlsPtuPut("NR_IDENT_B",cTraOriBen,aDados)
	PlsPtuPut("NR_IDENT_S",cTraOrig,aDados)
	PlsPtuPut("DT_VALIDAD",cDatValAut,aDados)
	PlsPtuPut("CUNIDOM",cOpeSol,aDados)

	//procedimentos
	for nCont := 1 to len(aItens)

		cTpAut 	:= PlsPtuGet( "ID_AUTORIZ",aItens[nCont] )
		cTpTab  := PlsPtuGet( "TP_TABELA",aItens[nCont] )
		cCodPro	:= PlsPtuGet( "CD_SERVICO",aItens[nCont] )
		nQtd	:= PlsPtuGet( "QT_SERVICO",aItens[nCont] )

		PlsPtuPut("TP_TABELA",  cTpTab , aItens[nCont])
		PlsPtuPut("CD_SERVICO", cCodPro, aItens[nCont])
		PlsPtuPut("ID_AUTORIZ", cTpAut, aItens[nCont])
		PlsPtuPut("QT_AUTORIZ", nQtd ,aItens[nCont])

		if lPLPtuIte
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECDES","",nil,nil,cTraOrig,nil})
			PlsPtuPut("DS_SERVICO",PadR(aPlPtuIte[3],80),aItens[nCont])
		else
			// De-para pela tabela BTU (Terminologia TISS)
			If lPTUOn80
				aRetBTU := PTUDePaBTU(cCodPad,cCodPro,,.T.,,.T.)

				If len(aRetBTU) > 0
					PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nCont])
				Else
					//Se nao achou o De/Para, faz a pesquisa normal do sistema
					If BR8->( DbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
					Else
						PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
					EndIf
				EndIf
			Else
				//Utiliza o De/Para BR8_CODEDI ou tabela B1M
				if GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(cCodPro,.F.,,dDataAt,,,,,)

					if BR8->(found())

						//Descricao do procedimento
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont])

					else
						//Se nao achou o De/Para, faz a pesquisa normal do sistema
						if BR8->( dbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
							PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont])
						else
							PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
						endIf
					endIf

					//Realiza De/Para com a tabela de terminologias TISS BTU
				elseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(cCodPad,cCodPro,,.T.)

					if len(aRetBTU) > 0
						PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nCont])
					else
						//Se nao achou o De/Para, faz a pesquisa normal do sistema
						if BR8->( DbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
							PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
						else
							PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
						endIf
					endIf

				else
					//Busca a descricao do evento
					BR8->(DbSetOrder(1))
					if BR8->( DbSeek( xFilial("BR8")+ cCodPad + cCodPro ) )
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
					else
						PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
					endIf
				endIf
			EndIf
		endIf

		//Atualiza o procedimento
		if cTpAut != "2"

			for nY := 1 to 5

				//Caso exista criticas
				cCodCri := PlsPtuGet( "CD_MENS_E" + allTrim( str(nY) ) ,aItens[nCont] )

				if val(cCodCri) > 0
					PlsPtuPut( "CD_MENS_E" + allTrim( str(nY) ), cCodCri ,aItens[nCont] )
				endIf

			next

		endIf
	next

	aGrvTraPTU := {AllTrim(cTraOrig),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),cOpeSol,PlsPtuGet("NM_BENEF",aDadosCab)}

	PlsPtuOln(aDados,aItens,AllTrim(cTraOrig)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,nil,nil,@cMsgXsdErr)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRTPREST
Retorna o prestador que vai executar a Ordem de Servico

@author  Tulio Cesar
@version P11
@since   01.04.2005
/*/
//-------------------------------------------------------------------
Function PLSRTPREST(cCodRda,lIntern,cOper)
	LOCAL cMsg    	 := ""
	LOCAL cCodLoc 	 := ""
	LOCAL cCodEsp 	 := ""
	LOCAL cTipPre  	 := ""
	LOCAL cTipRda 	 := ""
	LOCAL lOK     	 := .F.
	LOCAL bRet    	 := { || {lOK,cMsg,cCodRda,cCodLoc,cCodEsp,cTipPre,cTipRda} }
	LOCAL cMVPLSRDAG := GetNewPar("MV_PLSRDAG","999999")
	DEFAULT lIntern  := .F.
	DEFAULT cOper    := ""

	BAU->( DbSetOrder(1) )//BAU_FILIAL + BAU_CODOPE
	If BAU->( MsSeek(xFilial("BAU")+cCodRda) )
		cTipPre := BAU->BAU_TIPPRE
		cTipRda := BAU->BAU_TIPPE
		BB8->( DbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
		If BB8->( MsSeek(xFilial("BB8")+BAU->BAU_CODIGO) )
			cCodLoc := BB8->BB8_CODLOC
			BAX->( DbSetOrder(1) )//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
			If BAX->( MsSeek(xFilial("BAX")+BAU->BAU_CODIGO+BB8->BB8_CODINT+BB8->BB8_CODLOC) )
				cCodEsp := BAX->BAX_CODESP
				lOk := .T.
			Else
				cMsg := "Prestador ["+cCodRda+STR0049 //"Unimed Destino ["###"] cadastrada como RDA sem especialidade."
			Endif
		Else
			cMsg := "Prestador ["+cCodRda+STR0050 //"Unimed Destino ["###"] cadastrada como RDA sem local de atendimento."
		Endif
	Else
		cMsg    := "Prestador ["+cCodRda+STR0051 //"Unimed Destino ["###"] nao cadastrada como RDA."
	Endif

	//Se nao for internacao, busca RDA Generica
	If !lIntern .And. !lOk
		BAU->( DbSetOrder(1) )//BAU_FILIAL + BAU_CODOPE
		If BAU->( MsSeek(xFilial("BAU")+cMVPLSRDAG) )
			cCodRda := cMVPLSRDAG
			cTipPre := BAU->BAU_TIPPRE
			cTipRda := BAU->BAU_TIPPE
			BB8->( DbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
			If BB8->( MsSeek(xFilial("BB8")+BAU->BAU_CODIGO+cOper) )
				cCodLoc := BB8->BB8_CODLOC
				BAX->( DbSetOrder(1) )//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
				If BAX->( MsSeek(xFilial("BAX")+BAU->BAU_CODIGO+BB8->BB8_CODINT+BB8->BB8_CODLOC) )
					cCodEsp := BAX->BAX_CODESP
					lOk := .T.
				Endif
			Endif
		Endif
	EndIf

Return(Eval(bRet))



//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTUAtAne
Atualiza as guias de Anexo ao confirmar a inclusao de Guia

@author  PLS TEAM
@version P11
@since   23.08.17
/*/
//-------------------------------------------------------------------
Function PLPTUAtAne(aHeaderITE,aColsITE,aCabCri,aDadCri,cAliasIte,cAliasCri,cNrSeqTR,cPesqAnex,cNraOpe,nOpc,lWeb)
	LOCAL cTpAut        := ""
	LOCAL nX            := 0
	LOCAL nY            := 0
	LOCAL nStaNeg       := 0
	LOCAL nStaAut       := 0
	LOCAL nPosPro		:= 0
	LOCAL nPosPad 		:= 0
	LOCAL nPosAud		:= 0
	LOCAL nPosSta 		:= 0
	LOCAL nPosSeq       := 0
	LOCAL nPosSeqCri    := 0
	LOCAL nPosCodCri    := 0
	LOCAL nPosDesCri    := 0
	LOCAL nPosCriEDI    := 0
	LOCAL nPosCodEDI    := 0
	LOCAL nPosNrtrol    := 0
	LOCAL nPosNraOpe    := 0
	LOCAL nItemB4C      := 0
	LOCAL nIteB4CNeg    := 0
	LOCAL lAudB4C       := .F.

	DEFAULT cNraOpe     := ""
	DEFAULT lWeb        := .F.


	If nOpc == K_Excluir
		While !B4A->( Eof() ) .And. xFilial("B4A") + cPesqAnex == xFilial("B4A") + B4A->B4A_GUIREF

			If Alltrim(B4A->B4A_NRTROL) == Alltrim(cNrSeqTR) .And. B4A->B4A_CANCEL != "1"
				PTCancB4A(lWeb)
			EndIf

			B4A->(DbSkip())
		EndDo
	Else
		nPosPro := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_CODPRO"})
		nPosPad := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_CODPAD"})
		nPosAud := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_AUDITO"})
		nPosSta := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_STATUS"})
		nPosSeq := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_SEQUEN"})
		If cAliasIte == "BQV"
			nPosNrtrol := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_NRTROL"})
			nPosNraOpe := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_NRAOPE"})
		EndIf

		B4C->( DbSetOrder(1) )//B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_SEQUEN

		While !B4A->( Eof() ) .And. xFilial("B4A") + cPesqAnex == xFilial("B4A") + B4A->B4A_GUIREF

			If Empty(B4A->B4A_NRTROL)

				If B4C->( msSeek( xFilial("B4C") +  B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) ) )
					While xFilial("B4A")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) == xFilial("B4C")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT) .And. !B4C->(Eof())

						If Empty(B4C->B4C_NRTROL)
							cTpAut := ""
							For nX := 1 to len(aColsITE)
								If Alltrim(aColsITE[nX][nPosPro]) == Alltrim(B4C->B4C_CODPRO) .And. Alltrim(aColsITE[nX][nPosPad]) == Alltrim(B4C->B4C_CODPAD)

									If cAliasIte == "BQV"
										If Alltrim(aColsITE[nX][nPosNrtrol]) != Alltrim(cNrSeqTR)
											Loop
										Else
											cNraOpe := Alltrim(aColsITE[nX][nPosNraOpe])
										EndIf
									EndIf

									Do Case
										//Evento em Auditoria
										Case Alltrim(aColsITE[nX][nPosAud]) == "1"
											cTpAut := "4"
											lAudB4C := .T.
											nStaNeg++

											//Evento Autorizado
										Case Alltrim(aColsITE[nX][nPosSta]) == "1"
											cTpAut := "2"
											//Deleto criticas existentes
											BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
											If BEG->(MsSeek(xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ))
												While B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) == BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) .And. !BEG->(Eof())
													BEG->(RecLock("BEG",.F.))
													BEG->(DbDelete())
													BEG->(MsUnLock())

													BEG->(DbSkip())
												EndDo
											EndIf
											nStaAut++

											//Evento Negado
										Case Alltrim(aColsITE[nX][nPosSta]) == "0"
											cTpAut := "1"
											nStaNeg++

											BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
											//Deleto criticas existentes
											If BEG->(MsSeek(xFilial("BEG")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) ))
												While B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN) == BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) .And. !BEG->(Eof())
													BEG->(RecLock("BEG",.F.))
													BEG->(DbDelete())
													BEG->(MsUnLock())

													BEG->(DbSkip())
												EndDo
											EndIf

											nPosSeqCri := AScan(aCabCri,{|x|x[2] == cAliasCri+"_SEQUEN"})
											nPosCodCri := AScan(aCabCri,{|x|x[2] == cAliasCri+"_CODGLO"})
											nPosDesCri := AScan(aCabCri,{|x|x[2] == cAliasCri+"_DESGLO"})
											nPosCriEDI := AScan(aCabCri,{|x|x[2] == cAliasCri+"_CRIEDI"})
											nPosCodEDI := AScan(aCabCri,{|x|x[2] == cAliasCri+"_CODEDI"})
											//Gravo as novas criticas
											For nY := 1 to len(aDadCri)

												If Alltrim(aColsITE[nX][nPosSeq]) == aDadCri[nY][nPosSeqCri] .And. !aDadCri[nY][len(aCabCri)+1]
													BEG->( RecLock("BEG",.T.) )
													BEG->BEG_FILIAL := xFilial("BEG")
													BEG->BEG_OPEMOV := B4C->B4C_OPEMOV
													BEG->BEG_ANOAUT := B4C->B4C_ANOAUT
													BEG->BEG_MESAUT := B4C->B4C_MESAUT
													BEG->BEG_NUMAUT := B4C->B4C_NUMAUT
													BEG->BEG_SEQUEN := B4C->B4C_SEQUEN
													BEG->BEG_SEQCRI := StrZero(nY, Len(BEG->BEG_SEQCRI))
													BEG->BEG_CODGLO := IIF(nPosCodCri>0,Alltrim(aDadCri[nY][nPosCodCri]),"")
													BEG->BEG_DESGLO := IIF(nPosDesCri>0,Alltrim(aDadCri[nY][nPosDesCri]),"")
													BEG->BEG_CRIEDI := IIF(nPosCriEDI>0,Alltrim(aDadCri[nY][nPosCriEDI]),"")
													BEG->BEG_CODEDI := IIF(nPosCodEDI>0,Alltrim(aDadCri[nY][nPosCodEDI]),"")
													BEG->( MsUnLock() )
												EndIf
											Next
									EndCase

									Exit
								EndIf
							Next

							//Atualiza item
							B4C->(RecLock("B4C",.F.))
							B4C->B4C_NRTROL := cNrSeqTR
							B4C->B4C_NRAOPE := cNraOpe
							B4C->B4C_COMUNI := "1"
							If !Empty(cTpAut)
								B4C->B4C_AUDITO := Iif(cTpAut == "4" .Or. cTpAut == "3","1","0")
								B4C->B4C_STATUS := Iif(cTpAut == "2","1","0")
							EndIf
							B4C->(MsUnlock())
						EndIf
						B4C->(DbSkip())
					EndDo

					//Atualiza Item
					B4A->(RecLock("B4A",.F.))
					B4A->B4A_NRTROL := cNrSeqTR
					B4A->B4A_NRAOPE := cNraOpe
					B4A->B4A_COMUNI := "1"
					B4A->B4A_AUDITO := Iif(lAudB4C,"1","0")
					B4A->B4A_STATUS := IIF(nStaNeg > 0 .And. nStaAut > 0 ,"2",IIf(nStaAut > 0 .And. nStaNeg == 0,"1","3"))
					B4A->(MsUnlock())

					//Guia de Radioterapia nao tem evento, manipulo o AUDITO e STATUS baseado nos itens da Guia Principal
				ElseIf B4A->B4A_TIPANE == "1"
					nPosSeq := AScan(aHeaderITE,{|x|x[2] == cAliasIte+"_NRTROL"})

					For nX := 1 to len(aColsITE)
						If cAliasIte == "BQV" .And. Alltrim(aColsITE[nX][nPosSeq]) != Alltrim(cNrSeqTR)
							Loop
						EndIf

						Do Case
							Case Alltrim(aColsITE[nX][nPosAud]) == "1" //Evento em Auditoria
								lAudB4C := .T.
								nStaNeg++
							Case Alltrim(aColsITE[nX][nPosSta]) == "1" //Evento Autorizado
								nStaAut++
							Case Alltrim(aColsITE[nX][nPosSta]) == "0" //Evento Negado
								nStaNeg++
						EndCase
					Next

					If cAliasIte == "BQV" .And. Empty(cNraOpe)
						BQV->(DbSetOrder(5))//BQV_FILIAL+BQV_NRTROL
						If BQV->(MsSeek(xFilial("BQV")+cNrSeqTR))
							cNraOpe := Alltrim(BQV->BQV_NRAOPE)
						EndIf
					EndIf

					B4A->(RecLock("B4A",.F.))
					B4A->B4A_NRTROL := cNrSeqTR
					B4A->B4A_NRAOPE := cNraOpe
					B4A->B4A_COMUNI := "1"
					B4A->B4A_AUDITO := Iif(lAudB4C,"1","0")
					B4A->B4A_STATUS := Iif(nStaNeg > 0,"3","1")//1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada
					B4A->(MsUnlock())
				EndIf

				//Verifica se ha exclusao de anexos
			ElseIf Alltrim(B4A->B4A_NRTROL) == Alltrim(cNrSeqTR) .And. cAliasIte == "BQV"

				If B4C->( msSeek( xFilial("B4C") +  B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) ) )
					While xFilial("B4A")+B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) == xFilial("B4C")+B4C->(B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT) .And. !B4C->(Eof())

						If !Empty(B4C->B4C_NRTROL)
							For nX := 1 to len(aColsITE)
								If Alltrim(aColsITE[nX][nPosPro]) == Alltrim(B4C->B4C_CODPRO) .And. Alltrim(aColsITE[nX][nPosPad]) == Alltrim(B4C->B4C_CODPAD)
									nItemB4C ++
									If aColsITE[nX][len(aHeaderITE)+1]
										nIteB4CNeg ++
									EndIf

									Loop
								EndIf
							Next
						EndIf

						B4C->(DbSkip())
					EndDo

					If (nItemB4C > 0 .And. nIteB4CNeg > 0 ) .And. nItemB4C == nIteB4CNeg
						PTCancB4A(lWeb)
					EndIf

					//Guia de Radio cancela diretamente
				ElseIf B4A->B4A_TIPANE == "1"
					PTCancB4A(lWeb)
				EndIf
			EndIf

			B4A->(dbSkip())
		EndDo
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PTCancB4A
Cancela Guia de Anexo

@author  PLS TEAM
@version P11
@since   23.08.17
/*/
//-------------------------------------------------------------------
Static Function PTCancB4A(lWeb)
	Local aRetAnx   := {}
	Local cGuiasAne := ""
	Local nX        := 0

	aRetAnx := PLSA0A2CAN(.T., .F.)
	If !lWeb
		If len(aRetAnx) > 2
			For nX := 1 to len(aRetAnx[3])
				If aRetAnx[3][nX][1] == "B4A"
					B4A->(DbGoto(aRetAnx[3][nX][2]))
					cGuiasAne += IIf(!Empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)
				EndIf
			Next
		EndIf

		If !Empty(cGuiasAne)
			Aviso( STR0120,STR0626+cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"Foram canceladas as guias de Anexos Clínico vinculadas a guia cancelada: " //"Ok"
		Else
			//Verifica se ha anexos pendentes
			B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
			If B4A->(MsSeek(xFilial("B4A")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
				While B4A->B4A_GUIREF == BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) .And. !B4A->(Eof())
					cGuiasAne += IIf(!Empty(cGuiasAne),", ","") + B4A->(B4A_OPEMOV+"-"+B4A_ANOAUT+"."+B4A_MESAUT+"-"+B4A_NUMAUT)
					B4A->(DbSkip())
				EndDo

				If !Empty(cGuiasAne)
					Aviso( STR0120,STR0627+cGuiasAne,{ STR0146 }, 2 ) //"Atencao" //"Há guias de Anexos Clínico pendentes vinculadas a guia cancelada: " //"Ok"
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PtTpTabTus
Retorna o Tipo de Tabela de um evento para arquivo PTU Online
Obs: O registro deve estar com a BR8 posicionada

@author  PLS TEAM
@version P12
@since
@history 24/03/2020
		 	Parametro lTbTISS, retornar tabela TISS (vinicius.queiros)
		 10/08/2020
	   		Parametro lRfTISS, retorna a tabela TISS referente a tabela propria das
			Operadoras
/*/
//-------------------------------------------------------------------
Function PtTpTabTus(lExiTUSEDI,lExPlVTb,lTbTISS,lRfTISS)
	Local cTpTab       := ""
	Default lExiTUSEDI := .F.
	Default lExPlVTb   := .F.
	Default lTbTISS	   := .F.
	Default lRfTISS	   := .F.

	If lTbTISS
		lExPlVTb := ExistBlock("PLSVATBI") // Ponto de Entrada para retornar o tipo de tabela (PTU Online)

		BTU->(DbSetOrder(6))
		If BTU->(DbSeek(xFilial("BTU")+"BR8"+BR8->BR8_FILIAL+BR8->BR8_CODPAD+BR8->BR8_CODPSA))

			If lRfTISS
				If BTU->BTU_CODTAB == "00"
					Do Case
						Case BR8->BR8_TPPROC == '0' .Or. Empty(BR8->BR8_TPPROC) // Procedimento
							cTpTab := '22'
						Case BR8->BR8_TPPROC $ '1/5' // Material e Ortese/Protese
							cTpTab := '19'
						Case BR8->BR8_TPPROC == '2' // Medicamento
							cTpTab := '20'
						Case BR8->BR8_TPPROC == '6' // Pacote
							cTpTab := '98'
						OtherWise // Taxas, Diarias, Gases Medicinais, Alugueis e Outros
							cTpTab := '18'
					EndCase
				Else
					cTpTab := ""
				EndIf
			Else
				cTpTab := BTU->BTU_CODTAB
			EndIf

		Else
			cTpTab := ""
		EndIf
	Else
		Do Case
			Case lExiTUSEDI .And. BR8->BR8_TUSEDI == "1" //Materiais TUSS
				cTpTab := '5'
			Case lExiTUSEDI .And. BR8->BR8_TUSEDI == "2" //Medicamentos TUSS
				cTpTab := '6'
			Case BR8->BR8_TPPROC=='0' .or. Empty(BR8->BR8_TPPROC) //Procedimento
				cTpTab := '0'
			Case BR8->BR8_TPPROC $ '1/5' //Materiais
				cTpTab := '2'
			Case BR8->BR8_TPPROC=='2' //Medicamentos
				cTpTab := '3'
			Case BR8->BR8_TPPROC=='6' //Diarias
				cTpTab := '4'
			OtherWise //Materiais em Geral
				cTpTab := '1'
		EndCase
	EndIf

	If lExPlVTb
		cTpTab := ExecBlock("PLSVATBI", .F., .F., {cTpTab,lTbTISS,lRfTISS})
	endIf

Return cTpTab

//-------------------------------------------------------------------
/*/{Protheus.doc} PtAteCons
Retorna se e um atendimento de consulta

@author  PLS TEAM
@version P12
@since
/*/
//-------------------------------------------------------------------
Static Function PtAteCons(aIte)
	Local lConsulta := .F.

	if len(aIte) == 1
		lConsulta := PLSISCON(PlsPtuGet("CODPAD",aIte[1]),PlsPtuGet("CODPRO",aIte[1]))
	endIf
Return lConsulta


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTAuxCol
Funcao Apoio automacao

@author  PLS TEAM
@version P12
@since
/*/
//-------------------------------------------------------------------
Function PLPTAuxCol(cAlias,aCols,aHeader,aTrb,lBlank,cCondWhile)

	Default lBlank := .F.

	Store Header cAlias TO aHeader For .T.
	if lBlank
		STORE COLS BLANK cAlias TO aCols FROM aHeader
	else
		Store COLS cAlias TO aCols FROM aHeader VETTRAB aTrb While &(cCondWhile)
	endIf

Return
