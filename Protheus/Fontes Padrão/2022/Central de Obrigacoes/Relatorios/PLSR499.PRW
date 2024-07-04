#Include "PROTHEUS.CH"
#Include "PLSR249.ch"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#Define D_EVENT	 1 //Eventos
#Define D_BENEF	 2 //Beneficiarios
#Define D_DESPE	 3 //Despesas
#Define D_AMD 1
#Define D_HOS 2
#Define D_OBS 3
#Define D_ODO 4
#Define ALIGN_LEFT   1
#Define ALIGN_CENTER 2
#Define ALIGN_RIGHT  3
#Define HEADER_SEP "|"
#Define SIP_CLA    1
#Define SIP_VLR    2
#Define SIP_GIH    3
#Define SIP_QTD    4
#Define SIP_CODRDA 5
#Define SIP_NOMRDA 6
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR499

Relatorio para conferencia dos itens do SIP

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSR499(cTipo)

	Local oSIP_Report := Nil

	Private aTipPla := {1,2,3}
	Private aEstados := {	"AC",;
		"AL",;
		"AM",;
		"AP",;
		"BA",;
		"CE",;
		"DF",;
		"ES",;
		"GO",;
		"MA",;
		"MT",;
		"MS",;
		"MG",;
		"PA",;
		"PB",;
		"PR",;
		"PE",;
		"PI",;
		"RJ",;
		"RN",;
		"RO",;
		"RS",;
		"RR",;
		"SC",;
		"SE",;
		"SP",;
		"TO",;
		"NC"}

	Default cTipo = "1"

	If cTipo == "1" //Sip
		PlArXMLSIP()
		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Relatório Sintético", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif
		If FindFunction("TRepInUse") .And. TRepInUse()
			oSIP_Report := oReportDef()
			oSIP_Report:PrintDialog()
		Else
			MsgAlert(STR0001+Chr(13)+STR0002) //"Função TReport não esta em uso."###"Não é possivel executar o relatório."
		EndIf
	Else

		Alert("Operação não disponível para este tipo de obrigação.")

	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlArXMLSIP

Funcao criada para alimentar a matriz aItensSIP com os itens assistenciais

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlArXMLSIP()
	Local aItensSIP := {}
	Local nI:=0

	aAdd(aItensSIP,{"A - CONSULTAS MÉDICAS"						,"consultasMedicas"			,{D_EVENT,D_BENEF,D_DESPE}		,"A"  })
	aAdd(aItensSIP,{"A.1 - Consultas médicas ambulatoriais"		,"consultasMedicasAmb"		,{D_EVENT,D_BENEF,D_DESPE}		,"A1"})
	aAdd(aItensSIP,{"A.1.1 - Alergia e Imunologia"					,"alergiaImunologia"			,{D_EVENT}							,"A11"})
	aAdd(aItensSIP,{"A.1.2 - Angiologia"									,"angiologia" 				,{D_EVENT}							,"A12"})
	aAdd(aItensSIP,{"A.1.3 - Cardiologia"								,"cardiologia" 				,{D_EVENT}							,"A13"})
	aAdd(aItensSIP,{"A.1.4 - Cirurgia geral"							,"cirurgiaGeral" 				,{D_EVENT}							,"A14"})
	aAdd(aItensSIP,{"A.1.5 - Clínica médica"							,"clinicaMedica" 				,{D_EVENT}							,"A15"})
	aAdd(aItensSIP,{"A.1.6 - Dermatologia"								,"dermatologia" 				,{D_EVENT}							,"A16"})
	aAdd(aItensSIP,{"A.1.7 - Endocrinologia"							,"endocrinologia" 		  	,{D_EVENT}							,"A17"})
	aAdd(aItensSIP,{"A.1.8 - Gastroenterologia"						,"gastroenterologia" 	  	,{D_EVENT}							,"A18"})
	aAdd(aItensSIP,{"A.1.9 - Geriatria"									,"geriatria" 					,{D_EVENT}							,"A19"})
	aAdd(aItensSIP,{"A.1.10 - Ginecologia e Obstetrícia"			,"ginecologiaObstetricia" 	,{D_EVENT}							,"A110"})
	aAdd(aItensSIP,{"A.1.11 - Hematologia"								,"hematologia" 				,{D_EVENT}							,"A111"})
	aAdd(aItensSIP,{"A.1.12 - Mastologia"								,"mastologia" 				,{D_EVENT}							,"A112"})
	aAdd(aItensSIP,{"A.1.13 - Nefrologia"								,"nefrologia" 				,{D_EVENT}							,"A113"})
	aAdd(aItensSIP,{"A.1.14 - Neurocirurgia"							,"neurocirurgia" 				,{D_EVENT}							,"A114"})
	aAdd(aItensSIP,{"A.1.15 - Neurologia"								,"neurologia" 				,{D_EVENT}							,"A115"})
	aAdd(aItensSIP,{"A.1.16 - Oftalmologia"								,"oftalmologia" 				,{D_EVENT}							,"A116"})
	aAdd(aItensSIP,{"A.1.17 - Oncologia"									,"oncologia" 					,{D_EVENT}							,"A117"})
	aAdd(aItensSIP,{"A.1.18 - Otorrinolaringologia"					,"otorrinolaringologia"		,{D_EVENT}							,"A118"})
	aAdd(aItensSIP,{"A.1.19 - Pediatria"									,"pediatria" 					,{D_EVENT}							,"A119"})
	aAdd(aItensSIP,{"A.1.20 - Proctologia"								,"proctologia" 			  	,{D_EVENT}							,"A120"})
	aAdd(aItensSIP,{"A.1.21 - Psiquiatria"								,"psiquiatria" 			  	,{D_EVENT}							,"A121"})
	aAdd(aItensSIP,{"A.1.22 - Reumatologia"								,"reumatologia" 				,{D_EVENT}							,"A122"})
	aAdd(aItensSIP,{"A.1.23 - Tisiopneumologia"							,"tisiopneumologia" 			,{D_EVENT}							,"A123"})
	aAdd(aItensSIP,{"A.1.24 - Traumatologia-ortopedia"					,"traumatologiaOrtopedica"	,{D_EVENT}							,"A124"})
	aAdd(aItensSIP,{"A.1.25 - Urologia"									,"urologia" 				  	,{D_EVENT}							,"A125"})
	aAdd(aItensSIP,{"A.2 - Consultas médicas em Pronto Socorro"	,"consultaMedProntSoc"		,{D_EVENT,D_BENEF,D_DESPE}		,"A2"})
	aAdd(aItensSIP,{"B - OUTROS ATENDIMENTOS AMBULATORIAIS"		,"outrosAtendAmb"				,{D_EVENT,D_BENEF,D_DESPE}		,"B"})
	aAdd(aItensSIP,{"B.1 - Consultas/sessões com "+CRLF+;
		"Fisioterapeuta"							,"consultaSessaoFisio" 		,{D_EVENT}							,"B1"})
	aAdd(aItensSIP,{"B.2 - Consultas/sessões com Fonoaudiólogo"	,"consultaSessaoFono"		,{D_EVENT}							,"B2"})
	aAdd(aItensSIP,{"B.3 - Consultas/sessões com Nutricionista"	,"consultaSessaoNutri"		,{D_EVENT}							,"B3"})
	aAdd(aItensSIP,{"B.4 - Consultas/sessões com Terapeuta"+CRLF+;
		"Ocupacional"									,"consultaSessaoTerap"		,{D_EVENT}							,"B4"})
	aAdd(aItensSIP,{"B.5 - Consultas/sessões com Psicólogo"		,"consultaSessaoPsico"		,{D_EVENT}							,"B5"})
	aAdd(aItensSIP,{"C - EXAMES"									,"itensExames"				,{D_EVENT,D_BENEF,D_DESPE}		,"C"})
	aAdd(aItensSIP,{"C.1 - Ressonância magnética"					,"ressonanciaMagnet" 		,{D_EVENT}							,"C1"})
	aAdd(aItensSIP,{"C.2 - Tomografia computadorizada"				,"tomografiaComputa"			,{D_EVENT}							,"C2"})
	aAdd(aItensSIP,{"C.3 - Procedimento diagnóstico em "+CRLF+;
		"citopatologia cérvico-vaginal"+CRLF+;
		"oncótica em mulheres de 25 a 59 anos"	,"procedDiagnCitopat"		,{D_EVENT,D_BENEF}				,"C3"})
	aAdd(aItensSIP,{"C.4 - Densitometria óssea – qualquer"+CRLF+;
		"segmento"									,"densitometriaOssea"		,{D_EVENT}							,"C4"})
	aAdd(aItensSIP,{"C.5 - Ecodopplercardiograma transtorácico"	,"ecodopplerTranstora",{D_EVENT}							,"C5"})
	aAdd(aItensSIP,{"C.6 - Broncoscopia com ou sem biopsia"		,"broncoscopiabiopsia"		,{D_EVENT}							,"C6"})
	aAdd(aItensSIP,{"C.7 - Endoscopia digestiva alta"				,"endoscopiaDigestiva"		,{D_EVENT}							,"C7"})
	aAdd(aItensSIP,{"C.8 - Colonoscopia"								,"colonoscopia"				,{D_EVENT}							,"C8"})
	aAdd(aItensSIP,{"C.9 - Holter de 24 horas"						,"holter24h"					,{D_EVENT}							,"C9"})
	aAdd(aItensSIP,{"C.10 - Mamografia convencional e digital"		,"mamografiaConvDig"			,{D_EVENT}							,"C10"})
	aAdd(aItensSIP,{"C.10.1 - Mamografia em mulheres de 50 a 69"+CRLF+;
		"anos"										,"mamografia50a69"			,{D_EVENT,D_BENEF}				,"C101"})
	aAdd(aItensSIP,{"C.11  - Cintilografia miocárdica"				,"cintilografiaMiocard"		,{D_EVENT}							,"C11"})
	aAdd(aItensSIP,{"C.12 - Cintilografia renal dinâmica"			,"cintilografiaRenal"		,{D_EVENT}							,"C12"})
	aAdd(aItensSIP,{"C.13 - Hemoglobina glicada"						,"hemoglobinaGlicada"		,{D_EVENT}							,"C13"})
	aAdd(aItensSIP,{"C.14 - Pesquisa de sangue oculto nas fezes"	,"pesqSangueOculto"			,{D_EVENT,D_BENEF}				,"C14"})
	aAdd(aItensSIP,{"C.15 - Radiografia"								,"radiografia"				,{D_EVENT}							,"C15"})
	aAdd(aItensSIP,{"C.16 - Teste ergométrico"						,"testeErgometrico"			,{D_EVENT}							,"C16"})
	aAdd(aItensSIP,{"C.17 - Ultra-sonografia diagnóstica de"+CRLF+;
		"abdome total"							,"ultraSonAbdoTotal"			,{D_EVENT}							,"C17"})
	aAdd(aItensSIP,{"C.18 - Ultra-sonografia diagnóstica de"+CRLF+;
		"abdome inferior"							,"ultraSonAbdoInfer"			,{D_EVENT}							,"C18"})
	aAdd(aItensSIP,{"C.19 - Ultra-sonografia diagnóstica de"+CRLF+;
		"abdome superior"							,"ultraSonAbdoSuper"			,{D_EVENT}							,"C19"})
	aAdd(aItensSIP,{"C.20 - Ultra-sonografia obstétrica "+CRLF+;
		"morfológica"								,"ultraSonObstMorfo"			,{D_EVENT}							,"C20"})
	aAdd(aItensSIP,{"D - TERAPIAS"									,"terapias"					,{D_EVENT,D_BENEF,D_DESPE}		,"D"})
	aAdd(aItensSIP,{"D.1 - Transfusão ambulatorial"					,"transfusaoAmbulatorial" 	,{D_EVENT}							,"D1"})
	aAdd(aItensSIP,{"D.2 - Quimioterapia sistêmica"					,"quimioSistemica" 			,{D_EVENT}							,"D2"})
	aAdd(aItensSIP,{"D.3 - Radioterapia megavoltagem"				,"radioterapiaMegavolt" 		,{D_EVENT}							,"D3"})
	aAdd(aItensSIP,{"D.4 - Hemodiálise aguda"						,"hemodialiseAguda" 			,{D_EVENT}							,"D4"})
	aAdd(aItensSIP,{"D.5 - Hemodiálise crônica"						,"hemodialiseCronica" 		,{D_EVENT}							,"D5"})
	aAdd(aItensSIP,{"D.6 - Implante de dispositivo "+CRLF+;
		"intrauterino – DIU"						,"implanteDispIntrauterino" ,{D_EVENT}							,"D6"})
	aAdd(aItensSIP,{"E - INTERNAÇÕES"								,"internacoes"				,{D_EVENT,D_BENEF,D_DESPE}		,"E"})
	aAdd(aItensSIP,{"E.1 - Tipo de Internação"						,"tipoInternacao"				,{D_EVENT}							,"E1"})
	aAdd(aItensSIP,{"E.1.1 - Clínica"									,"clinica" 					,{D_EVENT}							,"E11"})
	aAdd(aItensSIP,{"E.1.2 - Cirúrgica"									,"cirurgica"					,{D_EVENT}							,"E12"})
	aAdd(aItensSIP,{"E.1.2.1 - Cirurgia bariátrica"						,"cirurgiaBariatrica" 		,{D_EVENT}							,"E121"})
	aAdd(aItensSIP,{"E.1.2.2 - Laqueadura tubária"						,"laqueaduraTubaria"			,{D_EVENT}							,"E122"})
	aAdd(aItensSIP,{"E.1.2.3 - Vasectomia"								,"vasectomia" 				,{D_EVENT}							,"E123"})
	aAdd(aItensSIP,{"E.1.2.4 - Fratura de fêmur (60 anos ou mais)"	,"fraturaFemur60"				,{D_EVENT,D_BENEF}				,"E124"})
	aAdd(aItensSIP,{"E.1.2.5 - Revisão de artroplastia"					,"revisaoArtroplastia" 		,{D_EVENT}							,"E125"})
	aAdd(aItensSIP,{"E.1.2.6 - Implante de CDI (cardio"+CRLF+;
		" desfibrilador implantável)"			,"implanteCdi" 				,{D_EVENT}							,"E126"})
	aAdd(aItensSIP,{"E.1.2.7 - Implantação de marcapasso"				,"implantacaoMarcap" 		,{D_EVENT}							,"E127"})
	aAdd(aItensSIP,{"E.1.3 - Obstétrica"								,"obstetrica" 				,{D_EVENT}							,"E13"})
	aAdd(aItensSIP,{"E.1.3.1 - Parto normal"								,"partoNormal"				,{D_EVENT}							,"E131"})
	aAdd(aItensSIP,{"E.1.3.2 - Parto cesáreo"							,"partoCesareo"				,{D_EVENT}							,"E132"})
	aAdd(aItensSIP,{"E.1.4 - Pediátrica"								,"pediatrica" 	 			,{D_EVENT}							,"E14"})
	aAdd(aItensSIP,{"E.1.4.1 - Internação de 0 a 5 anos de "+CRLF+;
		"idade por doenças respiratórias"		,"internacaoRespira"			,{D_EVENT,D_BENEF}				,"E141"})
	aAdd(aItensSIP,{"E.1.4.2 - Internação em UTI no período "+CRLF+;
		"neonatal"									,"internacaoUtiNeo" 			,{D_EVENT}							,"E142"})
	aAdd(aItensSIP,{"E.1.4.2.1 - Internações em UTI no período"+CRLF+;
		"neonatal por até 48 horas"				,"internacoesUtiNeo48" 		,{D_EVENT}							,"E1421"})
	aAdd(aItensSIP,{"E.1.5 - Psiquiátrica"								,"psiquiatrica"  				,{D_EVENT}							,"E15"})
	aAdd(aItensSIP,{"E.2 - Regime de internação"					,"regimeInternacao" 			,{D_EVENT}							,"E2"})
	aAdd(aItensSIP,{"E.2.1 - Hospitalar"								,"hospitalar" 				,{D_EVENT,D_BENEF}				,"E21"})
	aAdd(aItensSIP,{"E.2.2 - Hospital-dia"								,"hospitalDia" 				,{D_EVENT,D_BENEF}				,"E22"})
	aAdd(aItensSIP,{"E.2.2.1 - Hospital-dia para saúde mental"			,"hospitalSaudeMental" 		,{D_EVENT}							,"E221"})
	aAdd(aItensSIP,{"E.2.3 - Domiciliar"								,"domiciliar" 				,{D_EVENT,D_BENEF}				,"E23"})
	//ITEM F - CAUSAS SELECIONADAS DE INTERNAÇÃO
	aAdd(aItensSIP,{"F.1 - Neoplasias"								,"neoplasias"  				,{D_EVENT}							,"F1"})
	aAdd(aItensSIP,{"F.1.1 - Câncer de mama feminino"					,"cancerMamaFem"  			,{D_EVENT}							,"F11"})
	aAdd(aItensSIP,{"F.1.1.1 - Tratamento cirúrgico de "+CRLF+;
		"câncer de mama feminino"				,"tratCirurgCancerMam"		,{D_EVENT}							,"F111"})
	aAdd(aItensSIP,{"F.1.2 - Câncer de colo de útero"					,"cancerColoUtero"  			,{D_EVENT}							,"F12"})
	aAdd(aItensSIP,{"F.1.2.1 - Tratamento cirúrgico de "+CRLF+;
		"câncer de colo de útero"				,"tratCirurgCancerColo"		,{D_EVENT}							,"F121"})
	aAdd(aItensSIP,{"F.1.3 - Câncer de cólon e reto"					,"cancerColonReto"  			,{D_EVENT}							,"F13"})
	aAdd(aItensSIP,{"F.1.3.1 - Tratamento cirúrgico de "+CRLF+;
		"câncer de cólon e reto"					,"tratCirurgCancerColoReto"	,{D_EVENT}							,"F131"})
	aAdd(aItensSIP,{"F.1.4 - Câncer de próstata"						,"cancerProstata"  			,{D_EVENT}							,"F14"})
	aAdd(aItensSIP,{"F.1.4.1 - Tratamento cirúrgico de "+CRLF+;
		"câncer de próstata"						,"tratCirurgCancerProst"		,{D_EVENT}							,"F141"})
	aAdd(aItensSIP,{"F.2 - Diabetes mellitus"						,"diabetesMellitus" 			,{D_EVENT}							,"F2"})
	aAdd(aItensSIP,{"F.3 - Doenças do aparelho "+CRLF+;
		"circulatório"							,"doencasAparelhoCirc" 		,{D_EVENT}							,"F3"})
	aAdd(aItensSIP,{"F.3.1 - Infarto agudo do miocárdio"				,"infartoAgudoMiocardio"		,{D_EVENT}							,"F31"})
	aAdd(aItensSIP,{"F.3.2 - Doenças hipertensivas"					,"doencasHipertensivas"		,{D_EVENT}							,"F32"})
	aAdd(aItensSIP,{"F.3.3 - Insuficiência cardíaca "+CRLF+;
		"congestiva"								,"insuficienciaCardCong"		,{D_EVENT}							,"F33"})
	aAdd(aItensSIP,{"F.3.4 - Doenças cerebrovasculares"				,"doencasCerebrovasc" 		,{D_EVENT}							,"F34"})
	aAdd(aItensSIP,{"F.3.4.1 - Acidente vascular cerebral"				,"acidenteVascularCere"		,{D_EVENT}							,"F341"})
	aAdd(aItensSIP,{"F.4 - Doenças do aparelho"+CRLF+;
		" respiratório"							,"doencasAparelhoResp" 		,{D_EVENT}							,"F4"})
	aAdd(aItensSIP,{"F.4.1 - Doença pulmonar obstrutiva"+CRLF+;
		" crônica"									,"doencaPulmoObstrCron"		,{D_EVENT}							,"F41"})
	aAdd(aItensSIP,{"F.5 - Causas externas"							,"causasExternas"				,{D_EVENT}							,"F5"})
	aAdd(aItensSIP,{"G - NASCIDO VIVO"								,"nascidoVivo" 				,{D_EVENT}							,"G"})
	aAdd(aItensSIP,{"H - DEMAIS DESPESAS MÉDICO-HOSPITALARES"	,"demaisDespMedHosp"			,{D_DESPE}							,"OO"})
	aAdd(aItensSIP,{"H - DEMAIS DESPESAS MÉDICO-HOSPITALARES"	,"demaisDespMedHosp"			,{D_DESPE}							,"H"})
	aAdd(aItensSIP,{"I - PROCEDIMENTOS ODONTOLÓGICOS"			,"procedimentosOdonto"		,{D_EVENT,D_BENEF,D_DESPE}		,"I"})
	aAdd(aItensSIP,{"I.1 - Consultas odontológicas iniciais"		,"consultasOdontoInic"		,{D_EVENT,D_BENEF,D_DESPE}		,"I1"})
	aAdd(aItensSIP,{"I.2 - Exames radiográficos"					,"examesRadiograficos"		,{D_EVENT,D_BENEF}				,"I2"})
	aAdd(aItensSIP,{"I.3 - Procedimentos preventivos"				,"procedimentosPrevent"		,{D_EVENT,D_BENEF,D_DESPE}		,"I3"})
	aAdd(aItensSIP,{"I.3.1 - Atividade educativa individual"			,"atividadeEduIndividual" 	,{D_EVENT}							,"I31"})
	aAdd(aItensSIP,{"I.3.2 - Aplicação tópica profissional"+CRLF+;
		"de flúor por hemi-arcada"				,"aplicTopProfFluorHemi" 	,{D_EVENT}							,"I32"})
	aAdd(aItensSIP,{"I.3.3 - Selante por elemento dentário"+CRLF+;
		" (menores de 12 anos)"					,"selanteElemDentario"		,{D_EVENT,D_BENEF}				,"I33"})
	aAdd(aItensSIP,{"I.4 - Raspagem supra-gengival por "+CRLF+;
		"hemi-arcada (12 anos ou mais)"			,"raspSupraGengHemi"			,{D_EVENT,D_BENEF}				,"I4"})
	aAdd(aItensSIP,{"I.5 - Restauração em dentes decíduos"+CRLF+;
		"por elemento (menores de 12 anos)"	,"restauraDenteDeciduo"		,{D_EVENT,D_BENEF}				,"I5"})
	aAdd(aItensSIP,{"I.6 - Restauração em dentes permanentes"+CRLF+;
		" por elemento (12 anos ou mais)"		,"restauraDentePerma"		,{D_EVENT,D_BENEF}				,"I6"})
	aAdd(aItensSIP,{"I.7 - Exodontias simples de permanentes"+CRLF+;
		"(12 anos ou mais)"						,"exodontiasSimplesPer"		,{D_EVENT,D_BENEF,D_DESPE}		,"I7"})
	aAdd(aItensSIP,{"I.8 - Tratamento endodôntico concluído"+CRLF+;
		"em dentes decíduos por elemento"+CRLF+;
		"(menores de 12 anos)"					,"trataEndoConclDentesD"		,{D_EVENT,D_BENEF}				,"I8"})
	aAdd(aItensSIP,{"I.9 - Tratamento endodôntico concluído"+CRLF+;
		"em dentes permanentes por elemento"+CRLF+;
		"(12 anos ou mais)"						,"trataEndoConclDentesP"		,{D_EVENT,D_BENEF}				,"I9"})
	aAdd(aItensSIP,{"I.10 - Próteses odontológicas"					,"protesesOdontologicas"		,{D_EVENT,D_BENEF,D_DESPE}		,"I10"})
	aAdd(aItensSIP,{"I.11 - Próteses odontológicas unitárias"+CRLF+;
		"(Coroa Total e Restauração Metálica"+CRLF+;
		" Fundida)"								,"protesesOdontoUnitarias"	,{D_EVENT,D_DESPE}				,"I11"})

	for nI:=1 to Len(aItensSIP)
		aItensSIP[nI,1]:= DecodeUTF8(aItensSIP[nI,1])
		aItensSIP[nI,2]:= DecodeUTF8(aItensSIP[nI,2])
	next nI

Return aItensSIP
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} oReportDef

Retorna o objeto de relatorio

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function oReportDef()
	Local cDesRel	:= STR0003 //"Gera o relatório para conferência dos valores do SIP."
	Local cAliasB3M := GetNextAlias()
	Local oReport	:= TReport():New("PLSR499",DecodeUTF8("Relatório SIP Sintético"),"",{|oReport| ReportPrint(oReport,cAliasB3M)},cDesRel)  //"Relatório Sintético do SIP"
	Local aItensSIP := PlArXMLSIP()

	oReport:SetTotalInLine(.F.)
	oReport:SetLandscape()
	oReport:nColSpace := 0
	oReport:DisableOrientation()
	//Definicao da sessao 1 = oReport:Section(1) => oSecCab => Sessao SIP
	oSecCab := TRSection():New(oReport,"Cabeçalho",{cAliasB3M}) //Guias

	//oSecSeg := TRSection():New(oSecCab,"Segmento",{cAliasB3M})
	oSecDet := TRSection():New(oSecCab,"Detalhe",{cAliasB3M})

	oSecDet:SetAutoSize(.F.)
	oSecDet:SetEdit(.F.)
	oSecDet:SetEditCell(.F.)
	oSecDet:SetReadOnly(.T.)
	oSecDet:lForceLineStyle	:= .T.
	oSecDet:lLineStyle		:= .F.

	oSecCab:SetHeaderPage(.T.)    	                             //Indica que cabecalho da secao sera impresso no topo da pagina
	oSecCab:SetHeaderSection(.F.)                               //Indica se cabecalho da secao sera impresso (padrao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao das colunas da Sessao Cabeçalho                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TRCell():New(oSecCab,"REG_ANS"		,cAliasB3M,"Registro ANS"  ,,15,,{||cRegAns := (cAliasB3M)->B3M_CODOPE })
	TRCell():New(oSecCab,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecCab,"RAZAO"   	    ,cAliasB3M,"Razao Social",,25,,{||cNomeOpe :=  Posicione("BA0",5,xFilial("B3M")+(cAliasB3M)->B3M_CODOPE,"BA0_NOMINT")  })//"Guia GIH"
	TRCell():New(oSecCab,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecCab,"PERIODO" 	    ,cAliasB3M,"Período",,15,,{||cPeriodo := B3D->B3D_REFERE  })//"Guia GIH"
	TRCell():New(oSecCab,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecCab,"DT_OCOR" 	    ,cAliasB3M,"Dt. Ocorr",,15,,{||cPerOco := (cAliasB3M)->B3M_TRIOCO  })//"Guia GIH"
	TRCell():New(oSecCab,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecCab,"TIPO_PLANO"  ,cAliasB3M,"Tipo contratação",,25,,{||cTipoPlano := fTipoPlan((cAliasB3M)->B3M_FORCON) })//"Guia GIH"
	TRCell():New(oSecCab,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao das colunas da Sessao Detalhe                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSecDet,"ITEM_ASSIST"	,cAliasB3M,"Item Assistencial"  ,,40,,{||cItem := fDesItem(AllTrim((cAliasB3M)->B3M_ITEM),aItensSIP) })//"Sequencia"
	TRCell():New(oSecDet,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecDet,"UF_EVENTO"   		,cAliasB3M,"UF"    ,,25,,{||cUF := (cAliasB3M)->B3M_UF  })//"Guia GIH"
	TRCell():New(oSecDet,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecDet,"EVENTOS"   	,cAliasB3M,"Eventos Ocor. "+CRLF+" por UF"    ,,25,,{||cEventos := AllTrim(Str( Int((cAliasB3M)->B3M_QTDEVE) )) })//"Guia GIH"
	TRCell():New(oSecDet,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecDet,"BENEFICIARIOS",cAliasB3M,"Benef. "+CRLF+"expostos",,15,,{||cBenef := (cAliasB3M)->B3M_QTDBEN})//"Cod. RDA"
	TRCell():New(oSecDet,"SEPARADOR"	,,HEADER_SEP ,,00,,{||HEADER_SEP})
	TRCell():New(oSecDet,"DESPESAS"   	,cAliasB3M,"Total Desp. "+CRLF+"Líq. por UF" ,,15,,{||cDesp := fRetDesp(AllTrim((cAliasB3M)->B3M_ITEM),(cAliasB3M)->B3M_VLRTOT)})//"Nome RDA"

	oSecCab:SetPageBreak(.T.)

	Pergunte(oReport:uParam,.F.)

Return oReport
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Funcao para impressao do corpo do relatorio

@param oReport		Objeto report do relatorio
@param cAliasB3M	Alias de trabalho criado com os dados do relatorio

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasB3M)
	Local oSecCab	:= oReport:Section(1)
	//Local oSecSeg	:= oReport:Section(1):Section(1)
	//Local oSecDet	:= oReport:Section(1):Section(1):Section(1)
	Local oSecDet	:= oReport:Section(1):Section(1)

	cPerData := Alltrim(B3D->B3D_ANO) + StrZero(val(SubStr(B3D->B3D_REFERE,1,1)),2)
	cRegOpe := B3D->B3D_CODOPE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consulta analitica do SIP.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSecCab:BeginQuery()

	BeginSql Alias cAliasB3M
		Select
			B3M.B3M_CODOPE,
			B3M.B3M_FORCON B3M_FORCON,
			B3M.B3M_SEGMEN B3M_SEGMEN,
			B3M.B3M_UF B3M_UF,
			B3M.B3M_ITEM B3M_ITEM,
			B3M.B3M_VLRTOT B3M_VLRTOT,
			B3M.B3M_QTDEVE B3M_QTDEVE,
			B3M.B3M_TRIOCO B3M_TRIOCO,
			B3M.B3M_QTDBEN B3M_QTDBEN
		From
			%table:B3M% B3M
		Where
			B3M.B3M_FILIAL = %xFilial:B3M%
			AND B3M.B3M_CODOPE = %Exp:cRegOpe%
			AND B3M.B3M_UF <> 'FC'
			AND (
				B3M.B3M_QTDEVE > 0
				OR B3M.B3M_VLRTOT > 0
				OR B3M.B3M_QTDBEN > 0
			)
			AND B3M.B3M_TRIREC = %Exp:cPerData%
			And B3M.D_E_L_E_T_ = ' '
		Order By
			B3M.B3M_FORCON,
			B3M.B3M_SEGMEN,
			B3M.B3M_TRIOCO,
			B3M.B3M_UF,
			B3M.B3M_ITEM
	EndSql
	//MemoWrit("PLSR249.SQL",GetLastQuery()[2])//Debug Query
	oSecCab:EndQuery(/*Array com os parametros do tipo Range*/)

	oSecDet:SetParentQuery()
	oSecDet:SetParentFilter({|cParam| (cAliasB3M)->(B3M_FORCON+B3M_SEGMEN+B3M_UF+B3M_TRIOCO) == cParam},{|| (cAliasB3M)->(B3M_FORCON+B3M_SEGMEN+B3M_UF+B3M_TRIOCO)})
	//oSecDet:SetParentFilter({|| .T.},{|| })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do relatorio.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter((cAliasB3M)->(LastRec()))
	oSecCab:Print()
	(cAliasB3M)->(DbCloseArea())

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fDesItem

Funcao criada para retorna a descricao do item

@param cItem	Codigo do item a ser pesquisado

@return cRet	Descricao do item encontrada

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function fDesItem(cItem,aItensSIP)
	Local nPos := 0
	Default aItensSIP := PlArXMLSIP()

	nPos := aScan(aItensSIP,{|x|x[4]==cItem})

	If nPos > 0
		cRet := aItensSIP[nPos][1]
	Else
		cRet := cItem
	EndIf

Return cRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRetDesp

Funcao criada para retornar o valor do item

@param cItem	Codigo do item a ser pesquisado
@param nValor	Valor de despesa do item

@return nRet	Valor de despesa do item

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function fRetDesp(cItem,nValor)
	Local nPos := 0
	Local aItensSIP := PlArXMLSIP()

	nPos := aScan(aItensSIP,{|x|x[4]==cItem})

	If nPos > 0
		nPos2 := aScan(aItensSIP[nPos][3],{|x| x== D_DESPE})
		if nPos2> 0
			nRet := nValor
		Else
			nRet := 0
		EndIf
	Else
		nRet := nValor
	EndIf

Return nRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fTipoPlan

Funcao criada para retornar a descricao do tipo de plano

@param cTipPla		Codigo do tipo de plano

@return cRet		Descricao do tipo de plano

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function fTipoPlan(cTipPla)
	Local cRet := ""

	If cTipPla == "1"
		cRet		:= "Individual Familiar"
	ElseIf cTipPla == "2"
		cRet		:= "Coletivo Empresarial"
	ElseIf cTipPla == "3"
		cRet		:= "Coletivo por Adesao"
	EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³ParseToDB ºAutor  ³PLS-Team            º Data ³ 18/01/2011  º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³.  º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       |PLSR249                                                     º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ParseToDB

Trata a concatenacao de campo em banco diferente de MSSQL

@param cStatement	Query a ser analisada

@return cNewStat	Query atualizada de acordo com o banco

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ParseToDB(cStatement)
	Local cNewStat := cStatement

	If TCGetDB() != "MSSQL"
		cNewStat := StrTran(cStatement, "+", " || ")
	EndIf

Return cNewStat