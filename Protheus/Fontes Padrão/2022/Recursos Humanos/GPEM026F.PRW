#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM026.CH"

Static __afCatEfd__
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lOpeSoc		:= SuperGetMv("MV_OPESOC", NIL, .F.)

/*/{Protheus.doc} fInt2400New
Geração dos eventos S-2400 e S-2405 Beneficiarios Orgãos Publicos
@author Silvia Taguti
@since 27/09/2021
@version P12.1.27
@Type     Function
/*/

Function fInt2400New(cAliasSRA, lAltCad, nOpca, cReg, cTFilial, aDep, cCodUn, oModel, cOrigem, aErros , cVersEnvio, lMsgHlp)

	Local aArea			:= GetArea()
	Local cFilEnv    	:= ""
	Local aEstCivi		:= GpeEstCivi("1")
	Local nPosEC 		:= 0
	Local aRacaCor		:= {{'2','1'},{'4','2'},{'8','3'},{'6','4'},{'1','5'},{'9','6'}}
	Local aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
							{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}
	Local nPosInstr		:= 0
	Local aTpRegTrab	:= {{'30'},{'31'}, {'35'}}
	Local nTpRegTrab	:= 0
	Local aDependent	:= {}
	Local nI			:= 0
	Local dAdmissao
	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local lMemo			:= .F.
	Local cNomTrab		:= ""
	Local cNomAux		:= ""
	Local cXml			:= ""
	Local cObsDef		:= ""
	Local CodUnico		:= ""
	Local aAreaSVA		:= ""
	Local cCatEFD		:= ""
	Local lGravou 		:= .T.
	Local cFilTrab		:= ""
	Local lGpa180		:= IsInCallStack("GPEA180MAT") .Or. IsInCallStack("fEnvTaf180")
	Local cTpContSVA	:= ""
	Local cObsSVA		:= ""
	Local dDtCorte		:= SuperGetMV("MV_DTCGINI",nil,DDATABASE)
	Local aFil1x1		:= {}

	Local nOpcAx	 	:= 0
	Local lNT15			:= .F.
	Local lMTAFCFGE 	:= SuperGetMv("MV_TAFCFGE ",,.F.)

	Default lNovoCPF	:= .F.
	Default cNovoCodUnic:= ""

	Default oMdlRS9		:= Nil
	Default lAltCad		:= .F.
	Default nOpca		:= 0
	Default cReg		:= "S2400"
	Default cTFilial	:= ""
	Default aDep		:={}
	Default aVinc		:= {}
	Default cCodUn		:= (cAliasSRA)->RA_CODUNIC
	Default cOrigem		:= "ADM"
	Default aErros		:= {}
	Default oMdlRFZ		:= Nil
	Default aFilial		:= {}
	Default dDtAdm		:= cToD("//")
	Default cFilTrf		:= ""
	Default cFilDe		:= ""
	Default lMsgHlp		:= .T.
	Default cCCAte		:= ""
	Default cEmpP		:= Nil
	Default cSVAObs		:= ""
	Default lTrfCNPJ	:= .F.

	If !Empty(cCodUn)
	   cCodUn := StrTran(cCodUn, "&","&#38;" )
	Endif
	If !Empty(cNovoCodUnic)
	   cNovoCodUnic:= StrTran(cNovoCodUnic, "&","&#38;" )
	Endif

	nOpcAx := nOpca

	If nOpca == 3
		fGp23Cons(@aFil1x1, {cFilAnt})
	EndIf

	If nOpca == 3 .And. ( Len(aFil1x1) > 0 .And. Len(aFil1x1[1,3]) <> 1 .And. FUNNAME() <> "GPEM023" ) //Se vier da carga inicial enviamos filial do funcionário quando 1xN
		cFilTrab := cFilAnt
	Else
		cFilTrab:=	If(Empty((cAliasSRA)->RA_FILIAL) , cFilAnt, (cAliasSRA)->RA_FILIAL )
	Endif

	//Responsavel por alimentar a tag <CadIni>
	If ( cOrigem  == "CRG" ) .Or. ( nModulo == 35 .And. Empty(M->RA_CATEFD)) //Carga Inicial ou SIGAMDT
		RegToMemory("SRA",,,.F.)
	EndIf

	//Carrega para memoria o centro de custo definido na rotina de transferencias
	If !Empty(cCCAte)
		SetMemVar( "RA_CC", cCCAte )
	EndIf

	dAdmissao := M->RA_ADMISSA
	dAdmissao := If( Empty(dDtAdm), dAdmissao, dDtAdm )

	If dAdmissao < dDtCorte
		cOrigem := "S" //Vinda da Carga Inicial
	Else
		cOrigem := "N" //Vindo da Admissao
	Endif

	//-------------------------------------------------------------
	//| Se o layout de trabalho for 2.5
	//-------------------------------------------------------------
	If cVersEnvio >= "2.5.00"
		If M->RA_TPCONTR == '2'
			aAreaSVA := SVA->(GetArea())
			dbSelectArea("SVA")
			SVA->(DbSetOrder(1))
			If SVA->(dbSeek(cFilTrab+M->RA_MAT+"01")) .Or. !Empty(cSVAObs)
				cTpContSVA := "3"
				If !Empty(cSVAObs)
					cObsSVA := cSVAObs
				Else
					cObsSVA := SVA->VA_OBSERV
				Endif
			EndIf
		EndIf
	EndIf

	If Len(aFilial) > 0
		aFilInTaf := aFilial[1,1]
		aArrayFil := aFilial[1,2]
		cFilEnv	  := aFilial[1,3]
	Else
		// ENCONTRA A FILIAL DE ENVIO NO CASO DE 1 X N.
		If lGpa180
				cFilEnv := FTafGetFil(AllTrim(cEmpAnt) + cFilDe,,, .T.)
		Else
			cFilEnv := FTafGetFil(AllTrim(cEmpAnt) + AllTrim(SRA->RA_FILIAL),,, .T.)
		EndIf

		If !lGpa180
			fGp23Cons(@aFilInTaf, {cFilAnt}, @cFilEnv)
		Else
			fGp23Cons(@aFilInTaf, {Iif(Empty(cFilEnv), cTFilial, cFilEnv), cFilTrab})
		EndIf
	EndIf
	fVersEsoc( "S2400", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, , , @lNT15 )

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	//tratamento para empresa configurada como 1x1 ou 1xN
	If Len(GetAPOInfo("TafTransfTrab.prw")) == 0
		If !lMiddleware .And. !lMTAFCFGE .And. Len(aFilInTaf) > 0 .And. Len(aFilInTaf[1,3]) == 1 .And. !lGpa180 //1X1
			cFilEnv:= cFilTrab
		EndIf
	EndIf

	If lGravou

		Begin Transaction
			//CATEGORIA DO FUNCIONARIO
			cCatEFD := M->RA_CATEFD

			//TRABALHADOR
			cNomAux  := IIF(!EMPTY(ALLTRIM(M->RA_NOMECMP)),SUBSTR(M->RA_NOMECMP,1,60),ALLTRIM(M->RA_NOME) )
			cNomTrab := FSubst(cNomAux)
			nPosEC	  := aScan(aEstCivi,{|x| Alltrim(x[1]) == M->RA_ESTCIVI})
			nPosInstr := aScan(aInstrucao,{|x| Alltrim(x[1]) == M->RA_GRINRAI})
			nPosRacaCor	  := aScan(aRacaCor,{|x| Alltrim(x[1]) == M->RA_RACACOR})

			//NASCIMENTO
			cPais	  := fM23Pais(ALLTRIM(M->RA_CPAISOR))

			//INFO DEFICIÊNCIA
			If M->RA_DEFIFIS == "1" .And. !fEmptyMemo(M->RA_OBSDEFI)
				lMemo 	:= .T.
				cObsDef	:= ALLTRIM(M->RA_OBSDEFI)
			EndIf

			//DEPENDENTES
			aDependent:= {}

			If(FunName() == "GPEA020")
				If len(aDep) > 0
					aDependent:= aDep
				EndIf
			Else
				if len(aDep) == 0
					aDependent := fGM23Dep(cFilTrab, M->RA_MAT)
				else
					aDependent:= aDep
				Endif
			EndIf

			nTpRegTrab	:= aScan(aTpRegTrab,{|x| Alltrim(x[1]) == M->RA_VIEMRAI})//Retorno: 0-CLT | >0-Estatutario

			//Início da Geração do XML
			If !(EMPTY(cFilEnv))
				//Geração do registro S-2400
				If !Empty( cCatEFD )
					cXml += '<eSocial>'
					if cReg == 'S2400'
						cXml += '	<evtCdBenefIn>'
					Elseif cReg == 'S2405'
						cXml += '	<evtCdBenefAlt>'
					Endif

					//TRABALHADOR
					if cReg == 'S2400' //.OR. cReg == 'S2100'
						cXml += '<beneficiario>'
					elseif cReg == 'S2405'
						cXml += '<ideBenef>'
					endif

					cXml += '<cpfBenef>'    	+ ALLTRIM(M->RA_CIC)	+ '</cpfBenef>'

					if cReg == 'S2405'
						cXml += '</ideBenef>'
					Endif

					// Registro de alteracao cadastral
					If cReg == 'S2405'
						cXml += '	<alteracao>'
						cXml += ' <dtAlteracao>' + DTOS(dDataBase) + '</dtAlteracao>'
						cXml += '<dadosBenef>'
					Endif

					if cReg == 'S2400' .OR. cReg == 'S2405'

						cXml += '<nmBenefic>'+ Alltrim(cNomTrab)			+ '</nmBenefic>'
                    Endif
                    If cReg == 'S2400'
						cXml += '<dtNascto>' + DtoS(M->RA_NASC)		+ '</dtNascto>'

						cXml += '<dtInicio>' + IIf(M->RA_DTENTRA < dDtCorte, Dtos(dDtCorte),DtoS(M->RA_DTENTRA) )	+ '</dtInicio>'   //Incluir validação MV_DTCGINI
                    Endif
					cXml += '<sexo>'		 + M->RA_SEXO	 		+ '</sexo>'

    				cXml += '<racaCor>' 	 + IIf(nPosRacaCor> 0, aRacaCor[nPosRacaCor,2], "")    	+ '</racaCor>'

					If ( nPosEC > 0 )
						cXml += '<estCiv>' 		+ aEstCivi[nPosEC,2] + '</estCiv>'
					Else
						cXml += '<estCiv>' 		+ '' + '</estCiv>'
					EndIf

                    cXml += '<incFisMen>'		  	+ IIf(M->RA_TIPINF == "1", "S","N")	+ '</incFisMen>'
                    If cReg == 'S2400'
                        If M->RA_TIPINF == "1"
                           cXml += '<dtIncFisMen>'	+ DtoS(M->RA_DTREC)	+ '</dtIncFisMen>'
                        Endif
                    Endif
					cXml += '<endereco>'

					//ENDEREÇO
					If EMPTY(M->RA_RESEXT) .OR. M->RA_RESEXT=='2'
						cXml += '<brasil>'
						if !Empty(M->RA_LOGRTP)
							cXml += '<tpLograd>'	+ M->RA_LOGRTP + '</tpLograd>'
						endif
						cXml += '<dscLograd>'	+ M->RA_LOGRDSC	+ '</dscLograd>'
						cXml += '<nrLograd>'	+ M->RA_LOGRNUM	+ '</nrLograd>'
						cXml += '<complemento>'	+ M->RA_COMPLEM 	+ '</complemento>'
						cXml += '<bairro>'		+ M->RA_BAIRRO	+ '</bairro>'
						cXml += '<cep>'			+ M->RA_CEP		+ '</cep>'
						cXml += '<codMunic>'	+ AllTrim(M->RA_CODMUN) + '</codMunic>'
						cXml += '<uf>'			+ M->RA_ESTADO 	+ '</uf>'
						cXml += '</brasil>'
   					Else
						cXml += '<exterior>'
						cXml += '<paisResid>'	+ fM23Pais(ALLTRIM(M->RA_PAISEXT)) + '</paisResid>'
						cXml += '<dscLograd>'	+ M->RA_LOGRDSC	+ '</dscLograd>'
						cXml += '<nrLograd>'	+ Iif( !Empty( M->RA_LOGRNUM ), M->RA_LOGRNUM, "S/N")	+ '</nrLograd>'
						cXml += '<complemento>'	+ M->RA_COMPLEM 	+ '</complemento>'
						cXml += '<bairro>'		+ M->RA_BAIRRO	+ '</bairro>'
						cXml += '<nmCid>'		+ M->RA_MUNICIP	+ '</nmCid>'
						cXml += '<codPostal>'	+ M->RA_CPOSTAL 	+ '</codPostal>'
						cXml += '</exterior>'
					Endif
					cXml += '</endereco>'

                   	//DEPENDENTES
					If Len(aDependent) > 0
						For nI:= 1 To Len(aDependent)
							cXml += '<dependente>'
							cXml += fTpDep(aDependent[nI],cVersEnvio)
							cXml += '<nmDep>'		+ aDependent[nI,2]	+ '</nmDep>'
							cDtDep := iif (valtype(aDependent[nI,3]) == "D",DTOS(aDependent[nI,3]),aDependent[nI,3])
							cXml += '<dtNascto>' + cDtDep 	+ '</dtNascto>'
							cXml += '<cpfDep>'		+ aDependent[nI,4]	+ '</cpfDep>'
							If nTpRegTrab <> 0
								cXml += '<sexoDep>' + aDependent[nI,10] + '</sexoDep>'
							Endif
							cXml += '<depIRRF>'		+ aDependent[nI,5]	+ '</depIRRF>'
							//Dependente Incapaz
							//Se RB_TPDEP for igual a 5 ou 11 = <incTrab> S </incTrab>
							//Se RB_INCT  for igual a 1 = <incTrab> S </incTrab>
							if (aDependent[nI,1] $ "05|11") .OR. (aDependent[nI,9] == "S")
								cXml += '<incFisMen>S</incFisMen>'
							else
								cXml += '<incFisMen>N</incFisMen>'
							Endif
							cXml += '</dependente>'
						Next nI
                    Endif

					if cReg == 'S2405'
						cXml += '</dadosBenef>'
						cXml += 	'</alteracao>'
						cXml += 	'</evtCdBenefAlt>'
					elseif cReg == 'S2400'
						cXml += '</beneficiario>'
						cXml += '</evtCdBenefIn>'
					Endif
					cXml += '</eSocial>'
				Else
					lGravou := .F.
					//##"Atenção"##"Categoria não pode ser branca"
					If lMsgHlp
						Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0064), 1, 0 )
					EndIf
				EndIf
				//Fim do XML

				//Realiza geração de XML na System
				GrvTxtArq(alltrim(cXml), cReg)

				//Aguardando o tratamento do TAF para o evento S-2400
				If lGravou

					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg,,,,,,"GPE",,,, ,, , , , )

					/* Sera usado quando implementar a transferencia
					If !Empty(cEmpP) .And. lTrfCNPJ
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg,,,,,,"GPE",cTFilial,,,cEmpP, , , , , )
					ElseIf Len(GetAPOInfo("TafTransfTrab.prw")) > 0
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg,,,,,,"GPE",If(lGpa180, cTFilial, cFilDe),,,If(lGpa180, cEmpAnt, ""), , , , , )
					Else
						aErros := TafPrepInt( cEmpAnt, If( lGpa180, cTFilial, cFilEnv), cXml, ,"1", cReg,,,,,,"GPE",cFilDe, , , , , , , , )
					Endif */

					If Len( aErros ) > 0
						If !IsInCallStack("GPEM023") .And. lMsgHlp
							Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" não enviado(a) ao TAF. Erro: "
						EndIf
						lGravou := .F.
					EndIf
				EndIf
			EndIf
		End Transaction
	Else
		If ( Len(aErros) > 0 ) .And. lMsgHlp
			Help( ,, OemToAnsi(STR0001) ,,OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0036) + aErros[1], 1, 0 )//" não enviado(a) ao TAF. Erro: "
		Endif
	EndIf
	RestArea(aArea)

Return lGravou


Function fInt2410(oModel, nOper, cReg, aErros, lRetif )

Local aArea	:= GetArea()
Local lRet := .T.
Local cVersEnvio
Local cXml			:= ""
Local oModel		:= oModel:GetModel("GPEA019_RI0")
Local lGravou 	:= .T.
Local cFilEnv		:= ""
Local aFilInTaf		:= {}
Local cStatus		:= ""
Local cpfBenef		:= ""

Default oModel 		:= Nil
Default nOper		:= 0
Default cRet		:= ""
Default aErros	    := {}
Default cReg		:= "S2410"
Default lRetif	    := .F.

	fVersEsoc( "S2410", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )

	fGp23Cons(@aFilInTaf, {cFilAnt}, @cFilEnv)
	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	//Início da Geração do XML
	If lRet .And. !(EMPTY(cFilEnv))
		//Geração do registro S-2410

		cXml += '<eSocial>'
		if cReg == 'S2410'
			cXml += '	<evtCdBenIn>'
			If lRetif
				cXml +='<ideEvento>'
				cXml +='	<indRetif>2</indRetif>'
				cXml +='</ideEvento>'
			Endif
			cXml += 		'<beneficiario>'
			cXml += 			'<cpfBenef>' + Alltrim(oModel:GetValue("RI0_CPF"))	+ '</cpfBenef>'
			cXml += 			'<matricula>' + oModel:GetValue("RI0_CODUNI")	+ '</matricula>'
			cXml += 			'<cnpjOrigem>'    	+ oModel:GetValue("RI0_CNPJO")	+ '</cnpjOrigem>'
			cXml += 		'</beneficiario>'

			cXml +=		 	'<infoBenInicio>'
			cXml += 			'<cadIni>'    	+ If(oModel:GetValue("RI0_CADINI")== "1","S","N") + '</cadIni>'
			cXml += 			'<indSitBenef>'    	+ oModel:GetValue("RI0_SITBEN")	+ '</indSitBenef>'
			cXml +=		 		'<nrBeneficio>'    	+ Alltrim(oModel:GetValue("RI0_NRBEN") )	+ '</nrBeneficio>'
			cXml +=		 		'<dtIniBeneficio>'    	+ DtoS(oModel:GetValue("RI0_DTINIB")) + '</dtIniBeneficio>'
			cXml +=		 		'<dtPublic>'    	+ DtoS(oModel:GetValue("RI0_DTPUBL")) + '</dtPublic>'

			cXml += 			'<dadosBeneficio>'
			cXml += 				'<tpBeneficio>'    	+ oModel:GetValue("RI0_TPBEN") + '</tpBeneficio>'
			cXml += 				'<tpPlanRP>'    	+ oModel:GetValue("RI0_TPPLAN") + '</tpPlanRP>'
			cXml +=					'<dsc>' 			+ Alltrim(oModel:GetValue("RI0_DSCMEM")) + '</dsc>'
			cXml += 				'<indDecJud>'    	+ If(oModel:GetValue("RI0_DECJUD")== "1","S","N") + '</indDecJud>'
			If !Empty(oModel:GetValue("RI0_TPBEN")) .And. Substr(oModel:GetValue("RI0_TPBEN"),1,2) = "06"
				cXml += 			'<infoPenMorte>'
				cXml += 				'<tpPenMorte>'   + oModel:GetValue("RI0_TPMORT") + '</tpPenMorte>'
				If oModel:GetValue("RI0_CADINI") == "2"
					cXml += 			'<instPenMorte>'
					cXml += 					'<cpfInst>'  + oModel:GetValue("RI0_CPFMOR")	+ '</cpfInst>'
					cXml += 					'<dtInst>'  + DtoS(oModel:GetValue("RI0_DTOBIT")) + '</dtInst>'
					cXml += 				'</instPenMorte>'
				Endif
				cXml += 				'</infoPenMorte>'
			Endif
			cXml += 			'</dadosBeneficio>'
			If !Empty(oModel:GetValue("RI0_SITBEN")) .And. oModel:GetValue("RI0_SITBEN") == "2"
				cXml += 			'<sucessaoBenef>'
				cXml += 				'<cnpjOrgaoAnt>'  + oModel:GetValue("RI0_CNPJA")	+ '</cnpjOrgaoAnt>'
				cXml += 				'<nrBeneficioAnt>'  + oModel:GetValue("RI0_NRBENA")	+ '</nrBeneficioAnt>'
				cXml += 				'<dtTransf>'  + Dtos(oModel:GetValue("RI0_DTTRAN"))	+ '</dtTransf>'
				cXml += 				'<observacao>'  + Alltrim(oModel:GetValue("RI0_OBSMEM")) + '</observacao>'
				cXml +=     		'</sucessaoBenef>'
			Endif
			If !Empty(oModel:GetValue("RI0_SITBEN")) .And. oModel:GetValue("RI0_SITBEN") == "3"
				cXml +=	 			'<mudancaCPF>'
				cXml += 					'<cpfAnt>'  + oModel:GetValue("RI0_CPFANT")	+ '</cpfAnt>'
				cXml += 					'<nrBeneficioAnt >'  + oModel:GetValue("RI0_NRBEAN")	+ '</nrBeneficioAnt>'
				cXml += 					'<dtAltCPF >'  + Dtos(oModel:GetValue("RI0_DTALTC"))	+ '</dtAltCPF>'
				cXml += 					'<observacao>'  + Alltrim(oModel:GetValue("RI0_OBSAME")) + '</observacao>'
				cXml += 			    '</mudancaCPF>'
			Endif
			If (!Empty(oModel:GetValue("RI0_SITBEN") ) ) .And. (oModel:GetValue("RI0_SITBEN") == "2" .Or. oModel:GetValue("RI0_CADINI") == "1" ) .And.  !Empty(oModel:GetValue("RI0_DTTERM") )
				cXml += 			'<infoBenTermino>'
				cXml += 				'<dtTermBeneficio>'  + Dtos(oModel:GetValue("RI0_DTTERM"))+ '</dtTermBeneficio>'
				cXml += 				'<mtvTermino>'  + oModel:GetValue("RI0_TERMOT")	+ '</mtvTermino>'
				cXml +=   		  	'</infoBenTermino>'
			Endif
			cXml +=   	  '</infoBenInicio>'
			cXml +=    '</evtCdBenIn>'
			cXml += '</eSocial>'
		Endif
		//Fim do XML

		//Realiza geração de XML na System
		GrvTxtArq(alltrim(cXml), cReg)

		If lGravou
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", cReg)
			If Len( aErros ) > 0
				lRet := .F.
			EndIf
		EndIf

	Endif

Return lRet

/*/{Protheus.doc} fCarg2400
Realiza carga inicial dos eventos S-2400 - Cadastro de Beneficiário - Entes Públicos - Início
@type  Function
@author isabel.noguti
@since 06/04/2022
@version S-1.0
@param nPar1, Numerico, Opção carga (1-geração, 2-relat)
@param aLogProc, Array, log inconsistências
@param dDtRef, Data,	Data carga
@param aDados, Array,	log geração
@param aFilis, Array,	aFilInTaf inteiro
@param nPFil, Numerico,	posição do aFilInTaf no loop
@param cVersEnvio, caractere, layout eSocial
/*/
Function fCarg2400(nPar1, aLogProc, dDtRef, aDados, aFilis, nPFil, cVersEnvio)
	Local aArea			:= GetArea()
	Local cAliasSRA		:= GetNextAlias()
	Local cSitQuery		:= "%"
	Local cStat2400		:= ""
	Local nX, nK		:= 0
	Local cDadosBen		:= ""
	Local cFilEnv		:= ""
	Local aFilTAF		:= {}
	Local aErros		:= {}
	Local nContador		:= 0
	Local nContErr		:= 0
	Local aIncons		:= {}
	Local aConcat		:= {}
	Local cMsgIni		:= ""
	Local lGeraTAF		:= .F.
	Local nHrInicio		:= Seconds()
	Local nHrFim		:= 0
	Local cDtCorte		:= DtoS(SuperGetMV("MV_DTCGINI",nil,CtoD("22/11/2021")))
	Local aCposSRA		:= { "RA_DTENTRA", "RA_SEXO", "RA_DTREC", "RA_PAISEXT", "RA_MUNICIP", "RA_CEP", "RA_CODMUN", "RA_ESTADO",; //campos com validações adicionais (não alterar ordem)
							"RA_CIC", "RA_NOME", "RA_NASC", "RA_RACACOR", "RA_TIPINF", "RA_LOGRDSC", "RA_LOGRNUM" } //demais campos validar preenchimento
	Local aCposVld		:= {}
	Local aCposSRB		:= {"RB_CIC","RB_SEXO","RB_TPDEP","RB_NOME","RB_DTNASC","RB_TIPIR","RB_INCT"}
	Local aCposDep		:= {}
	Local aAreaSRB		:= {}

	Default nPar1		:= 0
	Default dDtRef 		:= date()
	Default aFilis		:= {}
	Default nPFil		:= 1
	Default cVersEnvio	:= "9.0"

		For nX := 1 to Len(aCposSRA)
			aAdd(aCposVld, { aCposSRA[nX], FWSX3Util():GetDescription(aCposSRA[nX]) }) //retorna x3_descric
		Next
		For nX := 1 to len(aCposSRB)
			aAdd(aCposDep, { aCposSRB[nX], FWSX3Util():GetDescription(aCposSRB[nX]) })
		Next

		aFilTAF := fGM23Fil(aFilis,nPFil)
		cFilEnv := aFilis[nPFil,2]

		If !Empty(cSituacao)
			cSitQuery += fSqlIN( cSituacao, 1 ) +"%"
		Else
			cSitQuery += "'*'%"
		EndIf

		BeginSql alias cAliasSRA
			SELECT
				RA_FILIAL, RA_MAT, RA_CIC, RA_NOMECMP, RA_NOME, RA_NASC,
				RA_DTENTRA, RA_SEXO, RA_RACACOR, RA_TIPINF, RA_DTREC, RA_ESTCIVI,
				RA_LOGRDSC, RA_LOGRNUM, RA_CEP, RA_CODMUN, RA_PAISEXT, RA_MUNICIP,
				RA_LOGRTP, RA_COMPLEM, RA_BAIRRO, RA_ESTADO, RA_RESEXT
			FROM
				%table:SRA% SRA
			WHERE
				(SRA.RA_CATFUNC = '9' OR SRA.RA_EAPOSEN = '1')
				AND SRA.RA_FILIAL IN(%exp:aFilTAF[1]%) AND SRA.RA_FILIAL >= (%exp: cFilDe%) AND SRA.RA_FILIAL <= (%exp: cFilAte%)
				AND SRA.RA_MAT >= (%exp: cMatDe%) AND SRA.RA_MAT <= (%exp: cMatAte%)
				AND SRA.RA_CC >= (%exp: cCCDe%) AND SRA.RA_CC <= (%exp: cCCAte%)
				AND SRA.RA_NOME >= (%exp: cNomeDe%) AND SRA.RA_NOME <= (%exp: cNomeAte%)
				AND SRA.RA_SITFOLH IN ( %exp:cSitQuery% )
				AND SRA.%notDel%
			ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
		EndSql

		While (cAliasSRA)->(!EoF())
			ProcRegua(nK++)
			aIncons := {}
			lGeraTaf := .T.

			If Empty((cAliasSRA)->RA_DTENTRA)
				lGeraTaf := .F.
				aAdd(aIncons, aCposVld[1,1] + " - " + AllTrim(aCposVld[1,2]) + OemtoAnsi(STR0268) )	//" - Mot.: Campo deve ser preenchido caso o registro seja referente à beneficiário"
			Else
				If (cAliasSRA)->RA_DTENTRA < cDtCorte .Or. (cAliasSRA)->RA_DTENTRA > dToS(dDtRef)
					lGeraTaf := .F.
					aAdd(aIncons, aCposVld[1,1] + " - " + AllTrim(aCposVld[1,2]) + OemtoAnsi(STR0263) ) //" - Mot.: Deve ser igual ou posterior ao início da obrigatoriedade dos eventos (MV_DTCGINI) para o ente público no eSocial e igual ou anterior à data de referência utilizada na carga"
				EndIf
				If (cAliasSRA)->RA_DTENTRA > cDtCorte .And. Empty((cAliasSRA)->RA_SEXO)
					lGeraTaf := .F.
					aAdd(aIncons, aCposVld[2,1] + " - " + AllTrim(aCposVld[2,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
				EndIf
			EndIf

			If (cAliasSRA)->RA_TIPINF == "1" .And. Empty((cAliasSRA)->RA_DTREC)
				lGeraTaf := .F.
				aAdd(aIncons, aCposVld[3,1] + " - " + AllTrim(aCposVld[3,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
			EndIf

			If (cAliasSRA)->RA_RESEXT == "1" //exterior
				For nX := 4 to 5 // RA_PAISEXT/RA_MUNICIP
					If Empty( (cAliasSRA)->(&(aCposVld[nX,1])) )
						aAdd(aIncons, aCposVld[nX,1] + " - " + AllTrim(aCposVld[nX,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
						lGeraTaf := .F.
					EndIf
				Next
			Else //brasil
				For nX := 6 to 8 // RA_CEP/RA_CODMUN/RA_ESTADO
					If Empty( (cAliasSRA)->(&(aCposVld[nX,1])) )
						aAdd(aIncons, aCposVld[nX,1] + " - " + AllTrim(aCposVld[nX,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
						lGeraTaf := .F.
					EndIf
				Next
			EndIf

			For nX := 9 to Len(aCposVld)
				If Empty( (cAliasSRA)->(&(aCposVld[nX,1])) )
					aAdd(aIncons, aCposVld[nX,1] + " - " + AllTrim(aCposVld[nX,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
					lGeraTaf := .F.
				EndIf
			Next

			//Dependentes
			aAreaSRB := SRB->(GetArea())
			DbSelectArea("SRB")
			dbSetOrder (1)
			If SRB->(dbSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT))
				While SRB->(!EoF()) .And. SRB->RB_FILIAL + SRB->RB_MAT == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT
					If SRB->RB_TIPIR <> "4" .And. Empty(SRB->RB_CIC)
						aAdd(aIncons, aCposDep[1,1] + " - " + AllTrim(aCposDep[1,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
						lGeraTaf := .F.
					EndIf
					If (cAliasSRA)->RA_DTENTRA > cDtCorte .And. Empty(SRB->RB_SEXO)
						aAdd(aIncons, aCposDep[2,1] + " - " + AllTrim(aCposDep[2,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
						lGeraTaf := .F.
					EndIf
					For nX := 3 to Len(aCposDep)
						If Empty( SRB->(&(aCposDep[nX,1])) )
							aAdd(aIncons, aCposDep[nX,1] + " - " + AllTrim(aCposDep[nX,2]) + OemtoAnsi(STR0264) )	//" - Mot.: Campo em branco"
							lGeraTaf := .F.
						EndIf
					Next
					SRB->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaSRB)

			If nPar1 == 2 //Inconsistências
				If !lGeraTaf
					If Empty(cMsgIni)
						cMsgIni := STR0265	//"Inconsistências: S-2400 Cadastro de Beneficiário - Entes Públicos - Início"
						aAdd(aLogProc, cMsgIni)
						aAdd(aLogProc, "")
						aAdd(aLogProc, STR0266)	//"Devido ao(s) seguinte(s) campo(s), o(s) registro(s) a seguir não poderá(ão) ser enviado(s) ao TAF:"
						aAdd(aLogProc, "")
					EndIf
					cDadosBen := STR0051 + (cAliasSRA)->RA_FILIAL + "-" + STR0180 + (cAliasSRA)->RA_MAT + "-" + (cAliasSRA)->RA_NOME	//"Filial##- Matrícula: "
					aAdd(aLogProc, cDadosBen)
					For nX := 1 to Len(aIncons)
						aAdd(aLogProc, aIncons[nX] )
					Next
					aAdd(aLogProc, "")
				EndIf

			ElseIf nPar1 == 1 //carga

				cStat2400	:= TAFGetStat( "S-2400", (cAliasSRA)->RA_CIC )
				cDadosBen	:= PADR(OemToAnsi(STR0267), 15) + PADR( OemToAnsi(STR0065) + " " + (cAliasSRA)->RA_FILIAL + "/" + (cAliasSRA)->RA_MAT + " - " + OemToAnsi(STR0066) +": " + Alltrim((cAliasSRA)->RA_CIC) + " - " + Alltrim((cAliasSRA)->RA_NOMECMP), 77 ) + " "	//"Beneficiário Filial/Mat:"#"CPF"

				If cStat2400 == "4" .And. nRetifica == 2
					nContErr++
					cDadosBen += PADR(OemToAnsi(STR0094), 33) //"Beneficiário"##"Não foi retificado.
					aAdd(aDados, cDadosBen)
					aAdd(aDados, "")
				elseIf cStat2400 $ "2/6"
					nContErr++
					cDadosBen += PADR(OemToAnsi(STR0173), 33) //"Beneficiário"##"Está em trânsido ao RET.
					aAdd(aDados, cDadosBen)
					aAdd(aDados, "")
				ElseIf lGeraTaf .And. ( cStat2400 != "4" .Or. nRetifica == 1 )
					SRA->(DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT))
					If fInt2400New(cAliasSRA,,,"S2400",,,"",,"CRG", @aErros, cVersEnvio, .F.)
						nContador++
						cDadosBen += PADR(OemToAnsi(STR0074), 33) //"Enviado ao TAF com sucesso."
						aAdd(aDados, cDadosBen)
						aAdd(aDados, "")
					elseIf Len(aErros) > 0
						nContErr++
						cDadosBen += PADR(OemToAnsi(STR0075), 33) //"Não enviado ao TAF."
						aAdd(aDados, cDadosBen)
						aConcat := StrTokArr(aErros[1], chr(13)+chr(10))
						If Len(aConcat) > 0
							For nX := 1 To len(aConcat)
								aAdd(aDados, aConcat[nX] )
							Next
							aAdd(aDados, "")
						EndIf
					EndIf
				Else
					nContErr++
					cDadosBen += PADR(OemToAnsi(STR0075), 33) //"Não enviado ao TAF."
					aAdd(aDados, cDadosBen)
					For nX := 1 To len(aIncons)
						aAdd(aDados, aIncons[nX] )
					Next
					aAdd(aDados, "" )
				EndIf

				//Incrementa regua
				IncProc(OemToAnsi(STR0067) + " " +(cAliasSRA)->RA_FILIAL+ "-" +(cAliasSRA)->RA_MAT) //##"Gerando o registro de: "
			EndIf

			(cAliasSRA)->(dbskip())
		EndDo

		(cAliasSRA)->(DbCloseArea())

		If nPar1 == 1 .And. nK > 0
			aAdd(aDados,"")
			aAdd(aDados,(OemToAnsi(STR0068)+" "+ OemToAnsi(STR0069) + " " + OemToAnsi(STR0267) ))	//"Resumo" ###"Carga Inicial" "Beneficiário"
			aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
			nHrFim := SecsToTime(Seconds())
			aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
			aAdd(aDados,"")
			aAdd(aDados,OemToAnsi(STR0071)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento

			aAdd(aDados,OemToAnsi(STR0072)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
			aAdd(aDados,OemToAnsi(STR0073)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
			aAdd(aDados,"")
			aAdd(aDados,"")
		EndIf

	RestArea(aArea)
Return lGeraTaf

/*/{Protheus.doc} fEmptyMemo
Verifica se um campo memo é vazio, descartando as quebras de linha
@type      	Static Function
@author Silvia Taguti
@since 09/05/2022
@version	1.0
@return lRet
/*/
Static Function fEmptyMemo(cCpoMemo)

Local lRet := .F.
Local cQuebra := CHR(13) + CHR(10)
Default cCpoMemo := ""

cCpoMemo := STRTRAN(cCpoMemo,cQuebra,"")

If Empty(cCpoMemo)
	lRet := .T.
EndIf

Return lRet
