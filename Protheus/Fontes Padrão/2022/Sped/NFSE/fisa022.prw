#INCLUDE "Fisa022.ch"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"        
#DEFINE TAMMAXXML 400000  //- Tamanho maximo do XML em bytesS

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fisa022   ³ Autor ³ Roberto Souza         ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de controle de Nota Fiscal de Serviço Eletrônica.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//---

/*/
Function Fisa022()  
Local aArea       	:= GetArea()     
Local cUSERNEOG	  	:= GetNewPar("MV_USERCOL","")
Local cPASSWORD	  	:= GetNewPar("MV_PASSCOL","")
Local cCONFALL	   	:= GetNewPar("MV_CONFALL","S")
Local cDOCSCOL		:= GetNewPar("MV_DOCSCOL","")
Local cConteudo   	:= ""

Local nRetCol	  	:= GetNewPar("MV_NRETCOL",10)
Local nAmbCTeC	  	:= GetNewPar("MV_AMBCTEC",2)
Local nAmbNFeC	  	:= GetNewPar("MV_AMBICOL",2)
Local cParBrw   	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"Fisa022-Param"
Local aPerg     	:= {}

Local cCadastro := ""
Local lRetorno    	:= .T.
Local lOk		:= .F.
Local lUsaColab		:= .F.
Local oWs
Private cUsaColab	:= GetNewPar("MV_SPEDCOL","N")
Private cURL       	:= Padr(GetNewPar("MV_SPEDURL",""),250)
Private cInscMun   	:= Alltrim(SM0->M0_INSCM)
Private cIdEnt     	:= ""
Private cVerTSS    	:= ""
Private cTypeaXML  	:= ""
Private cEntSai		:= "1"
Private cAmbiente	:= ""
Private cTitBrowse  := ""

Private lBtnFiltro 	:= .F.
Private lDirCert   	:= .T.  
Private aUf			:= {}
Private cCodMun     := SM0->M0_CODMUN
Private aRotina   	:= {}
Private aSigaMat01	:= {}
Private lMvAdmnfse	:= GetNewPar("MV_ADMNFSE",.F.)
Private lIsAdm		:= PswAdmin(, ,RetCodUsr()) == 0
Private _oObj

if(!accessPD())
		return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

/*Customização para Princesa dos Campos NFS-e Curitiba - NÃO DIVULGAR E NÃO UTILIZAR EM OUTRO CLIENTE*/
aSigaMat01 := strTokArr( GetNewPar( "MV_MATNFSE","" ),";" )

if( !empty( aSigaMat01 ) )
	if( isSigaMatOK( aSigaMat01 ) ) 									// <-- Validacao dos parametros
		// Cria objeto da classe sigamatNFSE
		oSigamatX := sigamatNFSE():New()
		
		// Seta conteudo do parametro MV_MTNFSE1
		oSigamatX:M0_CODIGO		:= allTrim( aSigaMat01[ 01 ] )			// 01. Codigo
		oSigamatX:M0_CODFIL		:= allTrim( aSigaMat01[ 02 ] )			// 02. Codigo Filial
		oSigamatX:M0_TEL		:= allTrim( aSigaMat01[ 03 ] )			// 03. Telefone
		oSigamatX:M0_INSCM		:= allTrim( aSigaMat01[ 04 ] )			// 04. Inscricao Municipal
		oSigamatX:M0_INSC		:= allTrim( aSigaMat01[ 05 ] )			// 05. Inscricao Estadual
		oSigamatX:M0_CGC		:= allTrim( aSigaMat01[ 06 ] )			// 06. CNPJ
		oSigamatX:M0_NOME		:= allTrim( aSigaMat01[ 07 ] )			// 07. Nome Fantasia
		oSigamatX:M0_NOMECOM	:= allTrim( aSigaMat01[ 08 ] )			// 08. Razao Social
		oSigamatX:M0_CODMUN		:= allTrim( aSigaMat01[ 09 ] )			// 09. Codigo IBGE
		oSigamatX:M0_TPINSC		:= val( allTrim( aSigaMat01[ 10 ] ) )	// 10. Tipo de inscricao (CNPJ/CPF)
		oSigamatX:M0_ENDENT		:= allTrim( aSigaMat01[ 11 ] )			// 11. Endereco de Entrega
		oSigamatX:M0_CEPENT		:= allTrim( aSigaMat01[ 12 ] )			// 12. Cep de Entrega
		oSigamatX:M0_BAIRENT	:= allTrim( aSigaMat01[ 13 ] )			// 13. Bairro de entrega
		oSigamatX:M0_CIDENT		:= allTrim( aSigaMat01[ 14 ] )			// 14. Cidade de entrega
		oSigamatX:M0_COMPENT	:= allTrim( aSigaMat01[ 15 ] )			// 15. Complemento de entrega
		oSigamatX:M0_ESTENT		:= allTrim( aSigaMat01[ 16 ] )			// 16. UF de entrega

		oSigamatX:M0_ENDCOB		:= allTrim( aSigaMat01[ 11] )			// 11. Endereco de cobranca
		oSigamatX:M0_CEPCOB		:= allTrim( aSigaMat01[ 12] )			// 12. Cep de cobranca
		oSigamatX:M0_BAIRCOB	:= allTrim( aSigaMat01[ 13] )			// 13. Bairro de cobranca
		oSigamatX:M0_CIDCOB		:= allTrim( aSigaMat01[ 14] )			// 14. Cidade de cobranca
		oSigamatX:M0_COMPCOB	:= allTrim( aSigaMat01[ 15] )			// 15. Complemento de cobranca
		oSigamatX:M0_ESTCOB		:= allTrim( aSigaMat01[ 16] )			// 16. UF de cobranca

		// Atualiza conteudo das variaveis
		cInscMun				:= oSigamatX:M0_INSCM
		cCodMun					:= oSigamatX:M0_CODMUN
		cParBrw   				:= oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022-Param"
	endIf
endIf

	if !lUsaColab
		cIdEnt := GetIdEnt()
		cVerTss := getVersaoTSS()
		If 'S' $ alltrim (Upper(cUsaColab)).And. ("0" $ cDOCSCOL .Or. "3" $ cDOCSCOL)
			cCadastro := 	STR0001 + " - TOTVS Colaboração 1.0 " +" Entidade: "+cIdEnt+" - TSS: "+cVerTss + " - NFS-e" //"Monitoramento "
		Else
			cCadastro := STR0001 +"Entidade: "+cIdEnt+" - TSS: "+cVerTss + " - NFS-e" //"Monitoramento "
		Endif
	else
			cCadastro := STR0001 + " - TOTVS Colaboração 2.0" + " - NFS-e"
	endif
/*
Tipo de NFe  
			###"1-Saída"
			###"2-Entrada"
*/
aadd(aPerg,{2,STR0075,PadR("",Len("2-Entrada")),{STR0076,STR0077},120,".T.",.T.,".T."}) //"Tipo de NFe"###"1-Saída"###"2-Entrada"	  
	If ParamBox(aPerg,cCadastro,,,,,,,,cParBrw,.T.,.T.)   
		If SubStr(MV_PAR01,1,1) == "2"
		    		cEntSai	   := "0"	    	
		elseIf SubStr(MV_PAR01,1,1) == "1"
					cEntSai	   := "1"
		EndIf			
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a utilização do Totvs Colaboração 2.0                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If UsaColaboracao("3")
	//-- TOTVS Colaboracao 2.0
	lUsaColab := ColCheckUpd()
	If !lUsaColab
		MsgInfo(STR0178) //TOTVS Colaboração 2.0 não Licenciado. Desativado o uso do TOTVS Colaboração 2.0
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a utilização do WS - TSS                   					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUsaColab
	
	if (lRetorno := lSetupTSS())

		lOk := IsReady(cCodMun, cURL, 2) // Mudar o terceiro parâmetro para 2 após o código de município 003 ter sido homologado no método CFGREADYX do serviço NFSE001

		If !( lOk )
			// Caso não se tenha uma conexão ou certificado configurado corretamente no TSS, chama o wizard de configuração
			Fisa022Cfg()
			lOk	:= IsReady(cCodMun, cURL, 1)
		EndIf

		If lOk
			cVerTss := getVersaoTSS()
			cIdEnt  := GetIdEnt()
			cAmbiente 	:= GetAmbNfse(cIdEnt, .F.)
		EndIf

		If lOk .And. cVerTss >= "1.35"
			oWs:= WsSpedCfgNFe():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			oWS:cUSACOLAB  := cUsaColab
			oWS:nNUMRETNF  := nRetCol
			oWS:nAMBIENTE  := 0
			oWS:nMODALIDADE:= 0
			oWS:cVERSAONFE := ""
			oWS:cVERSAONSE := ""
			oWS:cVERSAODPEC:= ""
			oWS:cVERSAOCTE := ""
			oWS:cUSERNEOG  := cUSERNEOG
			oWS:cPASSWORD  := cPASSWORD
			oWS:cCONFALL   := cCONFALL

			If 'S' $ alltrim (Upper(cUsaColab))

				If cVerTss >= "1.43"

					if("1" $ Upper(cDOCSCOL) )//1–Emissão de NF-e;
							cConteudo += "1"
					EndiF
					if( "2" $ Upper(cDOCSCOL) )//2–Emissão de CT-e;
							cConteudo += "2"
					EndIF
					if( "3" $ Upper(cDOCSCOL) )//3–Emissão de NFS-e;
							cConteudo += "3"
					EndIF
					if( "5" $ Upper(cDOCSCOL) )//5-Carta de correção;
							cConteudo += "5"
					endif
					if( "6" $ Upper(cDOCSCOL) )//6–MD-e;
							cConteudo += "6"
					endif
					if( "7" $ Upper(cDOCSCOL) )//7–MDF-e;
							cConteudo += "7"
					endif
					if( "4" $ Upper(cDOCSCOL) )//4-Nenhum;
							cConteudo := "4"
					EndIf
					if("0" $ Upper(cDOCSCOL) )//0–Todos;
							cConteudo := "0"
					EndIF
					oWS:cDOCSCOL := cConteudo
				EndIf
				oWS:nAMBNFECOLAB:= IIF(nAmbNFeC >= 1 .And. nAmbNFeC <=2,nAmbNFeC,2)
				oWS:nAMBCTECOLAB:= IIF(nAmbCTeC >= 1 .And. nAmbCTeC <=2,nAmbCTeC,2)
			EndIF

			oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			ExecWSRet(oWS,"CFGPARAMSPED")
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf

While lRetorno
	lBtnFiltro:= .F.
    lRetorno := Fisa022Brw(cCodMun,lUsaColab)
	_oObj := GetObjBrow()
    If !lBtnFiltro
    	Exit
    EndIf
EndDo
RestArea(aArea)
FreeObj(oWS)
oWS := nil
DelClassIntF()
//-----------------------------------------------------------------------
/*/{Protheus.doc} Fisa022Brw
Funcao que executa o Browser de seleção da nota de serviço
Filtro  
			###"1-Autorizadas"
			###"2-Sem filtro"
			###"3-Não Autorizadas"
			###"4-Transmitidas"
			###"5-Não Transmitidas"

			###" SERIE "
@author Totvs
@since 12.11.2010
@version 1.0 
/*/
//-----------------------------------------------------------------------
Static Function Fisa022Brw(cCodMun,lUsaColab)
Local aPerg     := {}
Local aCores    := {}
Local aParam		:= {}
Local lRetorno  := .T.
Local aIndArq   := {}
Local cParBrw   := if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022-FilSer",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022-FilSer" )
Local cDOCSCOL  := GetNewPar("MV_DOCSCOL","")
local cMunCanc	:= ""
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFin		:= LastDay(dDataBase)
Private aRotina := {}
Private cCondicao := ""
Private cCadastro := ""
Private bFiltraBrw

	if !lUsaColab
		cIdEnt := GetIdEnt()
		If 'S' $ alltrim (Upper(cUsaColab)).And. ("0" $ cDOCSCOL .Or. "3" $ cDOCSCOL)
			cCadastro := 	STR0001 + " - TOTVS Colaboração 1.0 " +" Entidade: "+cIdEnt+" - TSS: "+cVerTss //"Monitoramento "
		Else
			cTitBrowse := STR0001 +"Entidade: "+cIdEnt+" - TSS: "+cVerTss //Variável alimentada com informação padrão para ser utilizada na atualização do título do browse, função AtuBrowse()
			cCadastro := cTitBrowse + " - Ambiente: " + cAmbiente //"Monitoramento "
		Endif
	else
			cCadastro := STR0001 + " - TOTVS Colaboração 2.0"
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das perguntas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
	aadd(aPerg,{2,STR0082,PadR("",Len("5-Não Transmitidas")),{STR0083,STR0084,STR0110,STR0111,STR0112},120,".T.",.T.,".T."}) //"Filtra"###"1-Autorizadas"###"2-Sem filtro"###"3-Não Autorizadas"###"4-Transmitidas"###"5-Não Transmitidas"
	aadd(aPerg,{1,STR0010,PadR("",Len(SF2->F2_SERIE)),"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0141,dDataIni,""	,"","",,50,.F.})	//"Data Inicial"
	aadd(aPerg,{1,STR0142,dDataFin,""	,"","",,50,.F.}) //"Data Final"
	aadd(aPerg,{1,STR0011,PadR("",Len(SF2->F2_DOC)),"",".T.","",".T.",30,.F.})	//"Nota fiscal inicial"
	aadd(aPerg,{1,STR0012,PadR("",Len(SF2->F2_DOC)),"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
	aadd(aPerg,{1,STR0301,PadR("",Len(SF2->F2_ESPECIE)),"",".T.","",".T.",30,.F.})	//"Especie da Nota Fiscal"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o serviço foi configurado - Somente o Adm pode configurar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ParamBox(aPerg,STR0261,,,,,,,,cParBrw,.T.,.T.)   //"NFS-e"
		If cEntSai	  == "1"	
				aCores    := {{"F2_FIMP==' '",'DISABLE' },;	//NF não transmitida
						{"F2_FIMP=='S'",'ENABLE'},;		//NF Autorizada
						{"F2_FIMP=='T'",'BR_AZUL'},;	//NF Transmitida
						{"F2_FIMP=='D'",'BR_CINZA'},;	//NF Uso Denegado
						{"F2_FIMP=='N'",'BR_PRETO'}}	//NF nao autorizada 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a Filtragem                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"
			If !Empty(MV_PAR02)
				cCondicao += ".AND.F2_SERIE=='"+MV_PAR02+"'"
			EndIf
	
			If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
				cCondicao += ".AND. DTOS(SF2->F2_EMISSAO) >= '"+DTOS(MV_PAR03)+"'.AND. DTOS(SF2->F2_EMISSAO) <= '"+DTOS(MV_PAR04)+"'"
			EndIf
			
			If !Empty(MV_PAR06)
				cCondicao += ".AND.F2_DOC >='"+MV_PAR05+"' .AND. F2_DOC <='"+MV_PAR06+"'"
			EndIf
			
			If SubStr(MV_PAR01,1,1) == "2" 			//"1-NF Autorizada"
				cCondicao += ".AND. F2_FIMP$'S' "
			ElseIf SubStr(MV_PAR01,1,1) == "3" 		//"3-Não Autorizadas"
				cCondicao += ".AND. F2_FIMP$'N' "
			ElseIf SubStr(MV_PAR01,1,1) == "4" 		//"4-Transmitidas"
				cCondicao +=  ".AND. F2_FIMP$'T' "
			ElseIf SubStr(MV_PAR01,1,1) == "5" 		//"5-Não Transmitidas"
				cCondicao += ".AND. F2_FIMP$' ' " 			
			EndIf

			If !Empty(MV_PAR07) 
				cCondicao += ".AND.F2_ESPECIE=='"+MV_PAR07+"'"
			EndIf

			cMunCanc	:= iif (lUsaColab,cCodMun,RetMunCanc())  //TC2.0 não utiliza
			aRotina 	:= MenuDef(cCodMun,lUsaColab,cEntSai,cMunCanc,.T.)
		
			bFiltraBrw := {|| FilBrowse("SF2",@aIndArq,@cCondicao) }
			Eval(bFiltraBrw)
			mBrowse( 6, 1,22,75,"SF2",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Restaura a integridade da rotina                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			dbSelectArea("SF2")
			RetIndex("SF2")
			dbClearFilter()
			aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
			
		ElseIf cEntSai == "0" .And. cCodMun $ GetMunNFT() .And. (Val(substr(cVerTss,1,2)) >= 12 .or. cVerTss >= "2.02")
			If SF1->(FieldPos("F1_FIMP"))>0
				aCores    := {{"F1_FIMP==' ' .AND. AllTrim(F1_ESPECIE)=='SPED'",'DISABLE' },;	//NF não transmitida
							  {"F1_FIMP=='S'",'ENABLE'},;									//NF Autorizada
							  {"F1_FIMP=='T'",'BR_AZUL'},;									//NF Transmitida
							  {"F1_FIMP=='D'",'BR_CINZA'},;									//NF Uso Denegado							  
							  {"F1_FIMP=='N'",'BR_PRETO'}}									//NF nao autorizada		
			Else
				aCores := Nil
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a Filtragem                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao := "F1_FILIAL=='"+xFilial("SF1")+"'"
			If !Empty(MV_PAR02)
				cCondicao += ".AND.F1_SERIE=='"+MV_PAR02+"'"
			EndIf

			If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
				cCondicao += ".AND. DTOS(SF1->F1_EMISSAO) >= '"+DTOS(MV_PAR03)+"'.AND. DTOS(SF1->F1_EMISSAO) <= '"+DTOS(MV_PAR04)+"'"
			EndIf
			
			If !Empty(MV_PAR06)
				cCondicao += ".AND. F1_DOC >='"+MV_PAR05+"' .AND. F1_DOC <='"+MV_PAR06+"'"
			EndIf

			If SubStr(MV_PAR01,1,1) == "2" .And. SF1->(FieldPos("F1_FIMP"))>0 //"1-NF Autorizada"
				cCondicao += ".AND. F1_FIMP$'S' "
			ElseIf SubStr(MV_PAR01,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-Não Autorizadas"
				cCondicao += ".AND. F1_FIMP$'N' "
			ElseIf SubStr(MV_PAR01,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"
				cCondicao += ".AND. F1_FIMP$'T' "        			
			ElseIf SubStr(MV_PAR01,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-Não Transmitidas"
				cCondicao += ".AND. F1_FIMP$' ' "				
			EndIf
			
			If !Empty(MV_PAR07)
				cCondicao += ".AND.F1_ESPECIE=='"+MV_PAR07+"'"
			EndIf
			
			cMunCanc	:= iif (lUsaColab,cCodMun,RetMunCanc())  //TC2.0 não utiliza
			aRotina 	:= MenuDef(cCodMun,lUsaColab,cEntSai,cMunCanc,.T.)
		
			bFiltraBrw := {|| FilBrowse("SF1",@aIndArq,@cCondicao) }
			Eval(bFiltraBrw)
			mBrowse( 6, 1,22,75,"SF1",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Restaura a integridade da rotina                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF1")
			RetIndex("SF1")
			dbClearFilter()
			aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})
		Else
			MsgAlert(STR0179,STR0261)//Configure o Parâmetro MV_NFTOMSE, antes de utilizar esta opção! - NFS-e
		
		EndIf				
	EndIf
	Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fisa022Leg³Autor  ³ Roberto Souza         ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda para o Browse de Nota Fisca de Serviços Eletônica.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fisa022                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Leg(cCodMun,lUsaColab)

Local aLegenda := {}
				aCores    := {{"F1_FIMP==' ','DISABLE'"  },;									//NF não transmitida
							  {"F1_FIMP=='S','ENABLE'"    },;						  			//NF Autorizada
							  {"F1_FIMP=='T','BR_AZUL'"  },;									//NF Transmitida
							  {"F1_FIMP=='N','BR_PRETO'"}}										//NF nao autorizada

Aadd(aLegenda, {"ENABLE"    ,STR0078}) //"NF autorizada"
Aadd(aLegenda, {"DISABLE"   ,STR0079}) //"NF não transmitida"
Aadd(aLegenda, {"BR_AZUL"   ,STR0080}) //"NF Transmitida"
Aadd(aLegenda, {"BR_PRETO"  ,STR0081}) //"NF nao autorizada" 

BrwLegenda(cCadastro,STR0117,aLegenda) //"Legenda"

Return(.T.)
//---------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criada para restrições de permissão ao fonte fisa022 e suas respectivas funções no menu

ParametrosParametros do array a Rotina:
          1. Nome a aparecer no cabecalho
          2. Nome da Rotina associada
          3. Reservado
          4. Tipo de Transão a ser efetuada:
          	  1 - Pesquisa e Posiciona em um Banco de Dados
              2 - Simplesmente Mostra os Campos
              3 - Inclui registros no Bancos de Dados
              4 - Altera o registro corrente
              5 - Remove o registro corrente do Banco de Dados
          5. Nivel de acesso
          6. Habilita Menu Funcional

Retorno   ³Array com opcoes da rotina.

@author	Cleiton Genuino da Silva
@since		27.03.2016
/*/
//---------------------------------------------------------------------------
Static Function MenuDef(cCodMun,lUsaColab,cEntSai,cMunCanc, lConsomeTSS )
Local 	 cUrl 		:= alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )
Private aRotina 	:= {}
Default cEntSai	:= "1"
Default cCodMun	:= SM0->M0_CODMUN
Default lUsaColab	:= UsaColaboracao("3")
default cMunCanc	:= ""
default lConsomeTSS := .F.

aadd(aRotina,{STR0004,"AxPesqui"      ,0,1,0 ,.F.}) //"Pesquisar"
aadd(aRotina,{STR0109,"Fisa022Vis"    ,0,2,0 ,NIL}) //"Visualiza Doc."
aadd(aRotina,{STR0008,"Fisa022Rem()"  ,0,2,0 ,NIL}) //"Transmissão."
aadd(aRotina,{STR0009,"Fis022Mnt1()"  ,0,2,0 ,NIL}) //"Monitor."
aadd(aRotina,{STR0117,"Fisa022Leg()"  ,0,2,0 ,NIL}) //"Legenda"

If lUsaColab
	//-- TOTVS Colaboracao 2.0
	aadd(aRotina,{STR0006,"Fis022Par"     ,0,2,0 ,NIL}) //"Parametros"
	aadd(aRotina,{STR0147,"Fis022MntC()"  ,0,2,0 ,NIL}) //"Cancelamento"
Else
	aadd(aRotina,{STR0005,"Fisa022CFG()"    ,0,3,0 ,NIL}) //"Wiz.Config."
	//-- Municipios da NFSE  do TSS de acordo com o servico informado
	if lConsomeTSS
		If isConnTSS()
			If (cCodMun $ Fisa022Cod("001") .Or. ;
					cCodMun $ Fisa022Cod("002") .Or. ;
					cCodMun $ Fisa022Cod("003") .Or. ;
					cCodMun $ Fisa022Cod("004") .Or. ;
					cCodMun $ Fisa022Cod("005") .Or. ;
					cCodMun $ Fisa022Cod("006") .Or. ;
					cCodMun $ Fisa022Cod("007") .Or. ;
					cCodMun $ Fisa022Cod("008") .Or. ;
					cCodMun $ Fisa022Cod("009") .Or. ;
					cCodMun $ Fisa022Cod("010") .Or. ;
					cCodMun $ Fisa022Cod("011") .Or. ;
					cCodMun $ Fisa022Cod("012") .Or. ;
					cCodMun $ Fisa022Cod("013") .Or. ;
					cCodMun $ Fisa022Cod("014")).And.;
					(cCodMun $ Fisa022Cod("201") .Or. !( cEntSai == "0" .And. cCodMun $ GetMunNFT()))  /* NFTS Sao Paulo e Rio de Janeiro*/ .Or.;
					cCodMun $ Fisa022Cod("015") .or.;
					cCodMun $ Fisa022Cod("016") .or.;
					cCodMun $ Fisa022Cod("017") .or.;
					cCodMun $ Fisa022Cod("018") .Or. ;
					cCodMun $ Fisa022Cod("019") .Or. ;
					cCodMun $ Fisa022Cod("020") .Or. ;
					cCodMun $ Fisa022Cod("022") .Or. ;
					cCodMun $ Fisa022Cod("023") .Or. ;
					cCodMun $ Fisa022Cod("024") .Or. ;
					cCodMun $ Fisa022Cod("025") .OR. ;
					cCodMun $ Fisa022Cod("026") .OR. ;
					cCodMun $ Fisa022Cod("027") .OR. ;
					cCodMun $ Fisa022Cod("028") .OR. ;
					cCodMun $ Fisa022Cod("029") .OR. ;
					cCodMun $ Fisa022Cod("030");

			//--"Cancelamento"
				If cCodMun $ cMunCanc
					aadd(aRotina,{STR0147,"Fis022MntC()"    ,0,3,0 ,NIL}) //"Cancelamento"
				EndIf
	
				If	cCodMun $ Fisa022Cod("010") .And. !(cCodMun $ "5221858" ) .Or. ;
						cCodMun $ Fisa022Cod("012")
					aadd(aRotina,{STR0180, "Fis022ViewAIDF()"    ,0,2,0 ,NIL})//Tabela AIDF
				endif
			//--"Abrir &URL"
				If 	MunUsaUrl( cCodMun )
					aadd(aRotina,{STR0181, "Fis22UrlNfse"    ,0,2,0 ,NIL})//"Abrir &URL"
				endif
			//--"Consulta RPS"
				If (!( cEntSai == "0" .And. cCodMun $ GetMunNFT() .And. cCodMun $ "3550308" /* São - SP NFTS*/ ) .And. cCodMun $ Fisa022Cod("002") .Or. ;
						cCodMun $ Fisa022Cod("005") .And. cCodMun == "3548906" .OR. ;
						cCodMun $ Fisa022Cod("006") .Or. ;
						cCodMun $ Fisa022Cod("007") .Or. ;
						cCodMun $ Fisa022Cod("001") .And. (!cCodMun == "1501402") .OR. cCodMun == "3513009" .Or. ;
						cCodMun $ Fisa022Cod("011") .Or. ;
						cCodMun $ Fisa022Cod("012") .Or. ;
						cCodMun $ Fisa022Cod("013") .Or. ;
						cCodMun $ Fisa022Cod("016") .Or. ;
						cCodMun $ Fisa022Cod("017") .OR. ;
						cCodMun $ Fisa022Cod("019") .OR. ;
						cCodMun $ Fisa022Cod("020") .OR. ;
						cCodMun $ Fisa022Cod("022") .OR. ;
						cCodMun $ Fisa022Cod("023") .OR. ;
						cCodMun $ Fisa022Cod("025") .OR. ;
						cCodMun $ Fisa022Cod("026")	.OR. ;
						cCodMun $ Fisa022Cod("028")	.OR. ;
						cCodMun $ Fisa022Cod("030"))

					aadd(aRotina,{STR0174,"Fis022CRPS()",0,2,0 ,NIL}) //"Consulta RPS"
				EndIf
			//--"Exp.Retorno Prefeitura"
				If !cCodMun $ Fisa022Cod("101") .and. !cCodMun $ Fisa022Cod("102")
					aadd(aRotina,{STR0116 ,"NFSeExport"    ,0,3,0 ,NIL})//"Exp.Retorno Prefeitura"
				EndIf
			//--"Imp.Retorno"
			ElseIf cCodMun $ Fisa022Cod("101") .Or. ( cEntSai == "0" .And. cCodMun $ GetMunNFT() /* Sao Paulo NFTS*/)
				aadd(aRotina,{STR0150,"Fisa022Imp"     ,0,2,0 ,NIL})//"Imp.Retorno"
			//--"Cancelamento"
				If cCodMun $ cMunCanc .And. !( cEntSai == "0" .And. cCodMun $ GetMunNFT() .And. cCodMun $ "3525300" /* Jaú - SP NFTS*/ )
					aadd(aRotina,{STR0147,"Fisa022Canc()"    ,0,2,0 ,NIL})//"Cancelamento"
				EndIf
			ElseIf cCodMun $ Fisa022Cod("102")
			//--"Imp.Retorno"
				aadd(aRotina,{STR0150,"Fisa022Imp"    ,0,2,0 ,NIL})//"Imp.Retorno"
			//--"Cancelamento"
				If cCodMun $ cMunCanc
					aadd(aRotina,{STR0147,"Fisa022Canc()"    ,0,2,0 ,NIL})//"Cancelamento"
				EndIf
			EndIf
		endif
	Else 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³     Sem Conexão com TSS devolvo menu padrão de funções    					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aRotina,{STR0147		,"Fis022MntC()"    	,0,3,0 ,NIL}) //"Cancelamento"
		aadd(aRotina,{STR0180	,"Fis022ViewAIDF()"	,0,2,0 ,NIL}) //"Tabela AIDF"
		aadd(aRotina,{STR0181	,"Fis22UrlNfse"    	,0,2,0 ,NIL}) //"Fis22UrlNfse" -Abrir &URL
		aadd(aRotina,{STR0174		,"Fis022CRPS()"		,0,2,0 ,NIL}) //"Consulta RPS"
		aadd(aRotina,{STR0116		,"NFSeExport"    		,0,3,0 ,NIL}) //"Exp.Retorno Prefeitura"
		aadd(aRotina,{STR0150		,"Fisa022Imp"     	,0,2,0 ,NIL}) //"Imp.Retorno"
		aadd(aRotina,{STR0147		,"Fisa022Canc()"    	,0,2,0 ,NIL}) //"Cancelamento"
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³     Ponto de entrada para o cliente customizar os botoes apresentados     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FIRSTNFSE")
	ExecBlock("FIRSTNFSE",.F.,.F.,{aRotina})
EndIf

Return aRotina
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022Vis³ Autor ³Roberto Souza          ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao para visualizar documentos de saida                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Vis(cAlias)

If cAlias == "SF2"  
	Mc090Visual("SF2",SF2->(RecNo()),1)
ElseIf cAlias == "SF1"
	A103NFiscal("SF1",SF1->(RecNo()),2)  
EndIf

Return             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022Rem³ Autor ³Roberto Souza          ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Rem(lUsaColab)

Local aArea		:= GetArea()
Local aPerg		:= {}   
Local aParam		:= {}

Local cAlias		:= "SF2"
Local cParTrans	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022Rem",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022Rem" )
Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cNotasOk	:= ""
Local cForca		:= ""            
Local cDEST		:= Space(10)
Local cMensRet	:= "" 
Local cMvPar06	:= ""
Local cNftMvPar6	:= ""
Local cWhen 		:= ".T."
Local cAmbNfse := ""
local cMsgAIDF 	:= ""

Local dDataIni	:= CToD('  /  /  ')
Local dDataFim  	:= CToD('  /  /  ')
LOCAL dData	 	:= Date()

Local lObrig		:= .T.
Local lNFT			:= .F.
Local lNFTE		:= .F.
Local lOk			:= .T.
Local nForca		:= 1
Local cRetorno	:= ""

Local cDtNFTS	:= GetNewPar( "MV_DTNFTS", "0" ) // 0-Filtro por Data de Emissao (Padrao) ou 1-Filtro por Data de Entrada
Local cDataDe	:= IIf( cDtNFTS == "1", "Data Entrada de", "Data de" )
Local cDataAte	:= IIf( cDtNFTS == "1", "Data Entrada ate", "Data ate" )

Local cFornec := ""
Local cLoja := ""


Default lUsaColab	:= UsaColaboracao("3")

If cEntSai == "1"
	cAlias	:= "SF2"
	aParam	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),"",1,dData,dData,""}
ElseIf cEntSai == "0"   
	cAlias	:= "SF1"                                                                                        
	aParam	:= {Space(Len(SF1->F1_SERIE)),Space(Len(SF1->F1_DOC)),Space(Len(SF1->F1_DOC)),"",1,dData,dData,"","",""}
EndIf

MV_PAR01:=cSerie   := aParam[01] := PadR(ParamLoad(cParTrans,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
MV_PAR02:=cNotaini := aParam[02] := PadR(ParamLoad(cParTrans,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
MV_PAR03:=cNotaFin := aParam[03] := PadR(ParamLoad(cParTrans,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
MV_PAR04:=""
MV_PAR05:=""
MV_PAR06:= dData
MV_PAR07:= dData
MV_PAR08:= aParam[08] := PadR(ParamLoad(cParTrans,aPerg,8,aParam[08]),100)
MV_PAR09:= ""
MV_PAR10:= ""


//Montagem das perguntas
aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

If lUsaColab
	//-- TOTVS Colaboracao 2.0
	lOk := ColParValid("NFS",@cRetorno)
	If lOk
		cAmbienteNFSe := ColGetPar("MV_AMBINSE","2")
		cVersaoNFSe   := ColGetPar("MV_VERNSE" ,"")
	Else
		Aviso(STR0261,STR0182+CRLF+cRetorno,{STR0114},3) //"Ok" - Execute a funcionalidade Parâmetros, antes de utilizar esta opção!
	EndIf
Else
	//-- Geracao XML Arquivo Fisico
	If ( cCodMun $ Fisa022Cod("101") .or. cCodMun $ Fisa022Cod("102") .Or. ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  ) ) .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202"))
		MV_PAR04:= cDEST  := aParam[04] := PadR(ParamLoad(cParTrans,aPerg,4,aParam[04]),10)
		MV_PAR05:= nForca := aParam[05] := PadR(ParamLoad(cParTrans,aPerg,5,aParam[05]), 1)
		aadd(aPerg,{1,STR0183,aParam[04],"",".T.","",cWhen,40,lObrig})			//"Nome do arquivo XML Gerado"
		aadd(aPerg,{2,STR0184,aParam[05],{"1-Sim","2-Não"},40,"",.T.,""})	//"Força Transmissão"
		If ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  )
			MV_PAR06:= dDataIni:= aParam[06] := ParamLoad(cParTrans,aPerg,6,aParam[06])
			MV_PAR07:= dDataFim:= aParam[07] := ParamLoad(cParTrans,aPerg,5,aParam[07])
			aadd(aPerg,{1,cDataDe,aParam[06],"",".T.","",".T.",50,.F.})				//"Data de:"
			aadd(aPerg,{1,cDataAte,aParam[07],"",".T.","","",50,.F.})  				//"Data ate:"
			lNFT := .T.
		EndIf
		cMvPar06 := MV_PAR06
		oWs := WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:lftpEnable      := nil
		If ( execWSRet( oWS ,"tssCfgFTP" ) )
			If ( oWS:lTSSCFGFTPRESULT )
//				aadd(aPerg,{6,"Caminho do arquivo","","","",040,.T.,"","",""})
				aAdd(aPerg,{6,STR0185,padr('',100),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})//"Caminho do arquivo"
			EndIf
		EndIf
	ElseIf ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  )
		MV_PAR06:= dDataIni:= aParam[06] := ParamLoad(cParTrans,aPerg,6,aParam[06])
		MV_PAR07:= dDataFim:= aParam[07] := ParamLoad(cParTrans,aPerg,5,aParam[07])
		aadd(aPerg,{1,cDataDe,aParam[06],"",".T.","",".T.",50,.F.})				//"Data de:"
		aadd(aPerg,{1,cDataAte,aParam[07],"",".T.","","",50,.F.})  				//"Data ate:"
		lNFTE := .T.
		MV_PAR09 := cFornec  := aParam[09] := PadR(ParamLoad(cParTrans,aPerg,9,aParam[09]),TamSx3("F1_FORNECE")[1])
		aadd(aPerg,{1,STR0304,aParam[09],"",".T.","",".T.",TamSx3("F1_FORNECE")[1],.F.})		//"Fornecedor"		
		MV_PAR10 := cLoja  := aParam[10] := PadR(ParamLoad(cParTrans,aPerg,10,aParam[10]),TamSx3("F1_LOJA")[1])
		aadd(aPerg,{1,STR0305,aParam[10],"",".T.","",".T.",TamSx3("F1_LOJA")[1],.F.})	//"Loja"		
	EndIf
EndIf

//Verifica se o serviço foi configurado - Somente o Adm pode configurar
If lUsaColab
cAmbNfse :=	IIF (ColGetPar("MV_AMBINSE","2") == '2',STR0057/*2-Homologação*/,STR0056/*1-Produção*/)
Endif
If lOk .And. ParamBox(aPerg,cAmbNfse+" NFS-e",,,,,,,,cParTrans,.T.,.T.)
	
	if ( lNFT )
		cGravaDest := MV_PAR08
		cNftMvPar6 := MV_PAR06
	else
		cGravaDest := MV_PAR06
	endif

	If lNFTE
		IF cCodMun $ "3550308" 
			MV_PAR09 := MV_PAR06
			MV_PAR10 := MV_PAR07
		EndIF
		MV_PAR06 := MV_PAR04
		MV_PAR07 := MV_PAR05
		MV_PAR04 := ""
		MV_PAR05 := ""
		cMvPar06 := MV_PAR06
	EndIf

	MV_PAR05 := Val(Substr(MV_PAR05,1,1))

	// Retornando ao valor original ao Mv_PAR06
	if ( lNFT )
		MV_PAR06 := cNftMvPar6
	else
		MV_PAR06 := cMvPar06
	endif

	Processa( {|| Fisa022Trs(cCodMun,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,cAlias,@cNotasOk,cDEST,MV_PAR05,@cMensRet,MV_PAR06,MV_PAR07,,,cGravaDest, lUsaColab, lNFTE, MV_PAR09, MV_PAR10)}, "Aguarde...","(1/2) Verificando dados...", .T. )
	If Empty(cNotasOk) 	
		Aviso(STR0261,STR0186+CRLF+cMensRet,{STR0114},3)//"Nenhuma nota foi transmitida."
	Else
		If lUsaColab .Or. ((cCodMun $ Fisa022Cod("101") .Or. cCodMun $ Fisa022Cod("102") .Or. (cCodMun $ GetMunNFT() .And. cEntSai == "0")) .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202")))
			Aviso(STR0261,STR0187 +CRLF+ cNotasOk,{STR0114},3)//"Arquivos Gerados:"
		Else		
			cMensRet := Iif("Uma ou mais notas nao puderam ser transmitidas:"$cNotasOk,"","Notas Transmitidas:"+CRLF)
			Aviso(STR0261,cMensRet + cNotasOk,{STR0114},3)//NFS-e
		EndIf
	EndIf
EndIf    

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022Trs³ Autor ³Roberto Souza          ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal de Serviços Eletronica.    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Trs(cCodMun,cSerie,cNotaini,cNotaFin,cForca,cAlias,cNotasOk,cDEST,nForca,cMensRet,dDataIni,dDataFim,lAuto,nMaxTrans,cGravaDest,lUsaColab,lNFTE,cFornec,cLoja)

	local aArea			:= GetArea()  
	local aNtXml		:= {}
	local aRemessa		:= {}
	local aTemp			:= {}
	local aArqTxt		:= {}
	local aTitIssRet	:= {}
	local aRetTit		:= {}
	local aMVTitNFT		:= &(GetNewPar("MV_TITNFTS","{}"))

	local cRetorno 		:= ""
	local cAliasSF3		:= "SF3"
	local cAliasSE2		:= "SE2"
	local cWhere    	:= ""
	local cNtXml		:= ""      
	local cSerieIni		:= cSerie
	local cSerieFim		:= cSerie
	local cTotal		:= ""		
	local cCodTit		:= ""
	local cAviso		:= ""
	local lOk			:= .F.
	local lRemessa		:= .F. 
	local lQuerySE2		:= .F.
	local lGeraArqimp	:= .F.
	local lContinua		:= .F.
	local lRecibo		:= .F.
	local lTitulo		:= .F.
	local lMontaRem		:= .T.
	local lcAlias		:= .F.
	
	local nX			:= 0
	local nY        	:= 0
	local nZ        	:= 0
	local nW        	:= 0
	local nTamXml		:= 0	
	local nCount		:= 0
	local nCodIssF3	:= tamSX3("F3_CODISS")[1]
	
	local cDtNFTS		:= GetNewPar( "MV_DTNFTS", "0" ) // 0-Filtro por Data de Emissao (Padrao) ou 1-Filtro por Data de Entrada
	local lRetNFTS		:= GetNewPar( "MV_RETNFTS", .F. ) // Considerar titulos pagos no mes de geracao do arquivo
	local cFtpT			:= Alltrim(GetNewPar("MV_TSSFTPM","1"))

	local dDtIniAnt		:= dDataIni
	local dDtFimAnt 	:= dDataFim

	local lFISVLNFSE	:= ExistBlock("FISVLNFSE")
	local lFISASQL01	:= ExistBlock("FISASQL01")
	local aValNFe		:= {}
	
	local cErrorMsg		:= ""
	private oRetorno
	private oWs
	
	Default cAlias 	:= ""
	Default lUsaColab	:= UsaColaboracao("3")
	Default lNFTE		:= .F.
	Default lAuto		:= .F.
	Default cFornec := ""
	Default cLoja  := ""
	

	//Restaura a integridade da rotina caso exista filtro	
    If !Empty (cAlias)
		(cAlias)->(dbClearFilter())
		retIndex(cAlias)
	Endif
	If !lUsaColab .And. ((cCodMun $ Fisa022Cod("101") .or. cCodMun $ Fisa022Cod("102")) .Or. (cEntSai == "0" .And. cCodMun $ GetMunNFT() .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202"))))
		lGeraArqimp := .T.
	
	endif
	
	#IFDEF TOP
	
		if cEntSai == "1" //Nota de Saída 
			cWhere := "%(SubString(SF3.F3_CFO,1,1) >= '5') "			

		elseIf cEntSai == "0" // Nota de entrada
			cWhere := "%"
			cWhere += "(SubString(SF3.F3_CFO,1,1) < '5')"

			if cCodMun $ getMunNFT() .And. Iif(lNFTE,( !empty( dDtIniAnt ) .And. !empty( dDtFimAnt ) ),( !empty( dDataIni ) .And. !empty( dDataFim ) ))
				If lNFTE
					if cDtNFTS == "1"	// Filtro por Data de Entrada
						cWhere += " And ( SF3.F3_ENTRADA >= '" +Dtos(dDtIniAnt)+"' And SF3.F3_ENTRADA <='"+Dtos(dDtFimAnt)+"' And SF3.F3_CODISS<>'')"
					else
						cWhere += " And ( SF3.F3_EMISSAO >= '" +Dtos(dDtIniAnt)+"' And SF3.F3_EMISSAO <='"+Dtos(dDtFimAnt)+"' And SF3.F3_CODISS<>'')"
					endif
				Else
					if cDtNFTS == "1"	// Filtro por Data de Entrada
						cWhere += " And ( SF3.F3_ENTRADA >= '" +Dtos(dDataIni)+"' And SF3.F3_ENTRADA <='"+Dtos(dDataFim)+"' And SF3.F3_CODISS<>'')"
					else
						cWhere += " And ( SF3.F3_EMISSAO >= '" +Dtos(dDataIni)+"' And SF3.F3_EMISSAO <='"+Dtos(dDataFim)+"' And SF3.F3_CODISS<>'')"
					endif
				EndIf
			endIf                                        

			if ( Empty( cSerie ) ) 		
				cSerieIni :=  "   "
				cSerieFim :=  "ZZZ"

			EndIf

		endif	
		
		if nForca == 2
			cWhere +=" AND (SF3.F3_CODRSEF = '' OR SF3.F3_CODRSEF = 'N') "
			cWhere +=" AND SF3.F3_CODRET <> 'T'"
		ElseIf nForca == 0
			cWhere +=" AND SF3.F3_CODRET <> 'T'"
		endif
		cWhere +=" AND SF3.F3_CODRSEF <> 'S' " // Autorizada
		if lAuto 
			cWhere +=" AND (SF3.F3_CODRSEF <> 'T' OR SF3.F3_CODRSEF = 'N') "
		endif

		If cEntSai == "0" .And. lRetNFTS .And. cCodMun $ GetMunNFT()
			cWhere += " AND SF3.F3_RECISS <> ''"
		EndIf

		If cCodMun $ "4106902"
			cWhere +=" AND (SF3.F3_CODISS  <> '" +Space(nCodIssF3)+"' OR SF3.F3_CODISS = '" +Space(nCodIssF3)+"')"
		Else
			cWhere +=" AND (SF3.F3_CODISS  <> '" + Space(nCodIssF3) +"')"
		EndIf	

		If !Empty(cFornec)
			cWhere += " AND F3_CLIEFOR = '" + cFornec +"' " 
		EndIf 

		If !Empty(cLoja)
			cWhere += " AND F3_LOJA = '" + cLoja +"' " 
		EndIf 
		
		cWhere += "%"

		cAliasSF3 := GetNextAlias()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³     Ponto de entrada para o cliente customizar a query do filto de busca  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFISASQL01
 			ExecBlock("FISASQL01",.F.,.F.,{cAliasSF3,cSerieIni,cSerieFim,cNotaIni,cNotaFin,cWhere,dDataIni,dDataFim})

			If Select(cAliasSF3) == 0
				//Aviso("",STR0299,{STR0114}) //Ocorreu erro na execução do ponto de entrada FISASQL01.
				lcAlias := .F.
			Else
				lcAlias := .T.	
			EndIf
			
		EndIf

		If !lcAlias .Or. !lFISASQL01
			BeginSql Alias cAliasSF3
				
				COLUMN F3_ENTRADA AS DATE
				COLUMN F3_DTCANC AS DATE
				COLUMN F3_EMISSAO AS DATE

				SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODNFE,SF3.F3_CODISS,F3_EMISSAO,F3_CODRSEF
				FROM %Table:SF3% SF3
				WHERE
				SF3.F3_FILIAL		= %xFilial:SF3% AND
				SF3.F3_SERIE		>= %Exp:cSerieIni% AND
				SF3.F3_SERIE		<= %Exp:cSerieFim% AND
				SF3.F3_NFISCAL	>= %Exp:cNotaIni% AND
				SF3.F3_NFISCAL	<= %Exp:cNotaFin% AND			
				SF3.F3_CODRET 	<> %Exp:'111'% AND
				%Exp:cWhere% AND //SF3.F3_CODISS  <> %Exp:Space(nCodIssF3)% AND - Agora está em condição no cWhere por conta de Curitiba
				SF3.F3_DTCANC 	= %Exp:Space(8)% AND
				SF3.%notdel%
			EndSql
		EndIf	
	
	#ELSE
		SF3->(dbSetOrder(5))	
		
		if cEntSai == "1"
			bCondicao := {||	SF3->F3_FILIAL	== xFilial("SF3") .And.;
								SF3->F3_SERIE		>= cSerieIni .And.;
								SF3->F3_SERIE		<= cSerieFim .And.;
								SF3->F3_NFISCAL	>= cNotaIni .And.;
								SF3->F3_NFISCAL	<= cNotaFin .And.;
								SF3->F3_CFO		>= '5' .And.;
								SF3->F3_DTCANC	== ctod("  /  /  ");	
							}		

		else
			bCondicao := {||	SF3->F3_FILIAL	== xFilial("SF3") .And.;
								SF3->F3_SERIE		>= cSerieIni .And.;
								SF3->F3_SERIE		<= cSerieFim .And.;
								SF3->F3_NFISCAL	>= cNotaIni .And.;
								SF3->F3_NFISCAL	<= cNotaFin .And.;
								SF3->F3_CFO		<	'5' .And.;
								SF3->F3_DTCANC	== ctod("  /  /  ");							
							}			

		endif
	
		SF3->(DbSetFilter(bCondicao,""))

		SF3->(dbGotop())	

	#ENDIF
	
	//Tratamento para NTFS,quando nao existir notas de entrada
	//apenas recibos lançandos no contas a pagar.
	if ( cEntSai == "0" .and. (len( aMVTitNFT ) == 2 .And. !Empty(aMVTitNFT[1][1])) .And. SE2->( FieldPos("E2_FIMP") ) > 0 ) .And. SE2->( FieldPos("E2_NFELETR") ) > 0 .And. !lRetNFTS
		
		for nz := 1 to 2 
			aAuxTit := aMVTitNFT[nz]
			for nw := 1 to len( aAuxTit )
				cCodTit += "'"+aAuxTit[nW]+"'"+","
			next nW	
		next nz

		cCodTit := SubStr(cCodTit, 1 , RAt(",",cCodTit)-1)
		
		If !empty( dDataIni ) .And. !empty( dDataFim )						

			lQuerySE2    := .T.	

			cAliasSE2 := GetNextAlias()

			cWhere := "%"
			cWhere += "SE2.E2_TIPO IN ("+cCodTit+") AND SE2.E2_ISS > 0"	
			cWhere += "%"

			#IFDEF TOP
			 	BeginSql Alias cAliasSE2

			 	COLUMN E2_EMISSAO AS DATE

				SELECT E2_FILIAL,E2_EMISSAO,E2_TIPO,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_ISS,E2_FORNECE,E2_LOJA,E2_FIMP,E2_NFELETR
					FROM %Table:SE2% SE2
						WHERE
						SE2.E2_FILIAL = %xFilial:SE2% AND
						SE2.E2_EMISSAO >= %Exp:dtos(dDataIni)% AND 
						SE2.E2_EMISSAO <= %Exp:dtos(dDataFim)% AND 
						%Exp:cWhere% AND
						SE2.%notdel%
				EndSql

			#ELSE

				SE2->( dbSetOrder(5) )

				bCondicao := {||	SE2->E2_FILIAL	== xFilial("SE2") .And.;
									SE2->E2_EMISSAO	>= dDataIni .And.;
									SE2->E2_EMISSAO	<= dDataFim .And.;
									SE2->E2_TIPO $ cCodTit;
							}

				SE2->(DbSetFilter(bCondicao,""))

				SE2->(dbGotop())
			#ENDIF

			lTitulo := .T.
		EndIf				

	elseif len( aMVTitNFT ) <> 2 .And. cEntSai == "0"
		Aviso("",STR0188 ,{STR0114})//"Parâmetro MV_TITNFTS não foi criado ou configurado corretamente, não serão considerados os recibos do financeiro!"
	elseif ( SE2->( FieldPos("E2_FIMP") ) == 0 .Or. SE2->( FieldPos("E2_NFELETR") ) == 0 ) .And. cEntSai == "0"
		Aviso("",STR0189 ,{STR0114})//"O campo E2_FIMP ou E2_NFELETR não existem, veiricar se o compatibilizador NFEP11R1 / update NFE11R136 foi executado corretamente!"
	endif		
		
	cTotal := cValtoChar( Val(cNotaFin)-Val(cNotaIni)+1 )	 
	
	ProcRegua( Val(cNotaFin)- Val(cNotaIni)+ 1 )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o nome do RDmake a ser utilizado                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRDMakeNFSe := getRDMakeNFSe(cCodMun,cEntSai)

	
	While (cAliasSF3)->(!Eof())
		
		nCount++
		lMontaRem := .T.

		incProc( "(" + cValTochar(nCount)+ "/"+cTotal + ")" + STR0022 + (cAliasSF3)->F3_NFISCAL ) //"Preparando nota: "

	    /*
	    +------------------------------------------------------+
		|PONTO DE ENTRADA PARA VALIDAÇÃO DA TRANSMISSAO DA NOTA|
		+------------------------------------------------------+
		*/
		If lFISVLNFSE                                          
			aValNFe:={}
			Aadd(aValNFe,IF((cAliasSF3)->F3_CFO < "5","E","S"))
			Aadd(aValNFe,(cAliasSF3)->F3_FILIAL)
			Aadd(aValNFe,(cAliasSF3)->F3_ENTRADA)
			Aadd(aValNFe,(cAliasSF3)->F3_NFISCAL) 
			Aadd(aValNFe,(cAliasSF3)->F3_SERIE)
			Aadd(aValNFe,(cAliasSF3)->F3_CLIEFOR)
			Aadd(aValNFe,(cAliasSF3)->F3_LOJA)
			Aadd(aValNFe,(cAliasSF3)->F3_ESPECIE)
			Aadd(aValNFe,(cAliasSF3)->F3_FORMUL)
			If !ExecBlock("FISVLNFSE",.F.,.F.,aValNFe)
				dbSelectArea(cAliasSF3)
				dbSkip()
				Loop
			EndIf
		EndIf
		
		//-----------------------------------------------------
		// NFTS - Dentro do mesmo municipio
		// Validacao para quando for transmitir uma NFTS
		// para o mesmo Municipio, entendesse que ja consta na
		// Prefeitura, e com isso nao eh para ser enviado 
		// remessa novamente.
		//-----------------------------------------------------
		If( alltrim( ( cAliasSF3 )->F3_ESPECIE ) == "NFS" )
			If( cEntSai == "0" .And. !empty( ( cAliasSF3 )->F3_CLIEFOR ) )				
				SA2->( dbSetOrder( 1 ) )
				dbSelectArea("SF1")
				SF1->( dbSetOrder( 1 ) )    //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                          
				
				If( SA2->( dbSeek( xFilial("SA2") + ( cAliasSF3 )->F3_CLIEFOR + ( cAliasSF3 )->F3_LOJA ) ) .Or. SF1->( dbSeek( xFilial("SF1") + ( cAliasSF3 )->F3_NFISCAL + ( cAliasSF3 )->F3_SERIE + ( cAliasSF3 )->F3_CLIEFOR + ( cAliasSF3 )->F3_LOJA ) ) )
				                                                                                                            
					If ( SA2->( A2_COD_MUN ) $ GetMunNFT() )
						If ( SA2->( A2_TIPO) == "F" ) .Or. empty( ( SF1->F1_NFELETR ) )
							lMontaRem = .T.
						Else
							lMontaRem = .F.
						EndIf

						//**********************************************************************************************************//
						//A prefeitura do Município do Rio de Janeiro promoveu alterações                                           // 
						//na legislação que disciplina a emissão da Nota Fiscal de Serviços Eletrônicas (NFS-e) - Nota Carioca,     //
						//para acrescentar, entre as hipóteses de dispensa da declaração de serviços,                               //
						//os prestados por microempreendedores individuais (MEI).                                                   //
						//Informações retida da documentação feita pela Consultoria Tributária no link:                             //
						//https://tdn.totvs.com/pages/releaseview.action?pageId=344458705                                           //
						//**********************************************************************************************************//
					elseIf ( SA2->( A2_TPJ) == "3" .And. SA2->( A2_COD_MUN ) == "04557") 
						lMontaRem := .F.
					endif
					
				EndIF
				SF1->( DbCloseArea() )
			EndIf			
		EndIf

		//Retorna Remessa para transmissao
		if lMontaRem		
			aTemp := montaRemessaNFSe(cAliasSF3,cRDMakeNFSe,/*lCanc*/,/*cCodCanc*/,/*cMotCancela*/,cIdent,/*lMontaXML*/,/*cCodTit*/,@cMensRet,/*aTitIssRet*/,lUsaColab)		                             
		endif

		if len(aTemp) > 0
			nTamXml += len(aTemp[7])
			
			if nTamXml <= TAMMAXXML
				If aScan(aRemessa,{|x| AllTrim(x[1]) == AllTrim(aTemp[1]) .and. AllTrim(x[2]) == AllTrim(aTemp[2]) .and. x[3]+x[4] == aTemp[3]+aTemp[4] .and. AllTrim(x[6]) == AllTrim(aTemp[6])}) == 0 // Regra implementada para Tela de Notas Transmitidas no FISA022, não duplicar o numero de NFS-e transmitidas, para cenários com 1 NFS-e que possui 2 itens com código de Serviço diferente.
					aadd(aRemessa, aTemp)
				EndIf	
			
			else

				if nTamXml > TAMMAXXML .and. len(aRemessa) == 0 
					MsgAlert(STR0302 + " (Tamanho do XML transmitido "+cValToChar(nTamXml)+" bytes).")  
					exit
				EndIf

				lRemessa := .T.
			
			endif			
			
			aadd(aArqTxt,aTemp)
		
		endif		
		If GravaRps( if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) )
			if !C0P->(dbSeek(xFilial("C0P") + padr(cValToChar(val(SF3->F3_NFISCAL)), tamSX3("C0P_RPS")[1] ) ) ) .AND. C0P->(dbSeek(xFilial("C0P") + "0" ) )
				reclock("C0P")
				C0P->C0P_RPS		:= val((cAliasSF3)->F3_NFISCAL)		
				C0P->(msunlock())					
			EndIf
		EndIf
		(cAliasSF3)->(dbSkip())
									
		if ( lRemessa )

			incProc( "(" + cValToChar(nCount) + "/" + cTotal + ")"+STR0023 )//+aTemp[2]+aTemp[6] )	//"Transmitindo XML da nota: "

			lOk := envRemessaNFSe(cIdEnt,cUrl,aRemessa,(nForca == 1),cEntSai,@cNotasOk, , ,cCodMun)
				
			if !lOk
				If !lUsaColab
					cMensRet := (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))	
				EndIf
			EndIf			
			lRemessa	:= .F.					
			aRemessa	:={}
			
			aadd(aRemessa, aTemp)
			
			nTamXml:= len(aTemp[7])		
			aNtXml	:= {}
			cNtXml	:= ""

		endif
				
	endDo
	
	While (cAliasSE2)->(!Eof()) .and. cEntSai == "0" .And. lTitulo
		
		nCount++
		
		incProc( "(" + cValTochar(nCount)+ "/"+cTotal + ")" + STR0022 + (cAliasSE2)->E2_NUM ) //"Preparando nota: "
				
		//Retorna Remessa para transmissao
		aTemp := montaRemessaNFSe(cAliasSE2,cRDMakeNFSe, ,/*cCodCanc*/,/*cMotCancela*/,cIdent,,cCodTit,@cMensRet)

		if len(aTemp) > 0
			nTamXml += len(aTemp[7])
			
			if nTamXml <= TAMMAXXML
				aadd(aRemessa, aTemp)				
			
			else
				lRemessa := .T.
			
			endif			
			
			aadd(aArqTxt,aTemp)
			
			lRecibo	:= .T.
			
		
		endif		

		(cAliasSE2)->(dbSkip())
									
		if ( lRemessa )

			incProc( "(" + cValToChar(nCount) + "/" + cTotal + ")"+STR0023 )//+aTemp[2]+aTemp[6] )	//"Transmitindo XML da nota: "

			lOk := envRemessaNFSe(cIdEnt,cUrl,aRemessa,(nForca == 1),cEntSai,@cNotasOk, , ,cCodMun,lRecibo)
				
			if !lOk .And. !lUsaColab
				cMensRet :=(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))	

			endif
			
			lRemessa	:= .F.					
			aRemessa	:={}
			
			aadd(aRemessa, aTemp)
			
			nTamXml:= len(aTemp[7])		
			aNtXml	:= {}
			cNtXml	:= ""

		endif
				
	endDo

	If cEntSai == "0" .and. lRetNFTS .And. cCodMun $ GetMunNFT()
		SE2->(DBClearFilter())

		aRetTit := TitIssRet(aRemessa,dDtIniAnt,dDtFimAnt,cSerieIni,cSerieFim,cNotaIni,cNotaFin)

		For Nx := 1 To Len(aRetTit)
			SF3->(dbGoTo(aRetTit[nX][1]))

			nCount++
			
			incProc( "(" + cValTochar(nCount)+ "/"+cTotal + ")" + STR0022 + SF3->F3_NFISCAL ) //"Preparando nota: "

			aTitIssRet := {}
			aAdd(aTitIssRet,aRetTit[nX][2])
			aAdd(aTitIssRet,aRetTit[nX][3])
			aAdd(aTitIssRet,aRetTit[nX][4])
			aAdd(aTitIssRet,aRetTit[nX][5])
			aAdd(aTitIssRet,aRetTit[nX][6])
			aAdd(aTitIssRet,aRetTit[nX][7])
			
			//Retorna Remessa para transmissao
			aTemp := montaRemessaNFSe("SF3",cRDMakeNFSe, , /*cCodCanc*/,/*cMotCancela*/,cIdent,,,@cMensRet,aTitIssRet)
	
			if len(aTemp) > 0
				nTamXml += len(aTemp[7])
				
				if nTamXml <= TAMMAXXML
					aadd(aRemessa, aTemp)				
				
				else
					lRemessa := .T.
				
				endif			
				
				aadd(aArqTxt,aTemp)
			
			endif		
										
			if ( lRemessa )
	
				incProc( "(" + cValToChar(nCount) + "/" + cTotal + ")"+STR0023 )//+aTemp[2]+aTemp[6] )	//"Transmitindo XML da nota: "
	
				lOk := envRemessaNFSe(cIdEnt,cUrl,aRemessa,(nForca == 1),cEntSai,@cNotasOk, , ,cCodMun)
					
				if !lOk
					If !lUsaColab
						cMensRet := (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))	
					EndIf
				EndIf
				lRemessa	:= .F.					
				aRemessa	:={}
				
				aadd(aRemessa, aTemp)
				
				nTamXml:= len(aTemp[7])		
				aNtXml	:= {}
				cNtXml	:= ""
	
			endif
		Next
	EndIf
		
	if ( len(aRemessa) > 0 )
		
		incProc("("+cValToChar(nCount)+"/"+cTotal+") "+STR0023)//+aTemp[2]+aTemp[6])	//"Transmitindo XML da nota: "
		
		Begin Transaction
		lOk := envRemessaNFSe(cIdEnt,cUrl,aRemessa,(nForca == 1),cEntSai,@cNotasOk, , ,cCodMun,lRecibo,@cMensRet)
				
		if lOk
			if lGeraArqimp
				
				cNotasok := ""
				
				incProc("("+cValToChar(nCount)+"/"+cTotal+") "+"Gerando arquivo das notas")//aTemp[2]+aTemp[6])	//"Transmitindo XML da nota: "
				
				//gera arquivo txt para os modelos 101,102 ou NFTS(São Paulo)
				geraArqNFSe(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,cForca,nForca,cSerieIni,cSerieFim,dDataIni,dDataFim,aArqTxt,@cNotasOk,lRecibo,cGravaDest,cFtpT)				
				cErrorMsg := GetWscError()
			endIf			

		else
			If !lUsaColab
				cMensRet :=(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))	
			EndIf
		endif

		if(!empty(cErrorMsg))
			disarmTransaction()
		endIf
		
		end Transaction
	endif

	#IFDEF TOP		
		if select(cAliasSF3) > 0
			(cAliasSF3)->(dbCloseArea())

		endif			

	#ENDIF                                                                         		

	restArea(aArea)

	delClassIntF()

return(cRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022Con³ Autor ³Roberto Souza          ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Con()

Local aArea       := GetArea()
Local aPerg       := {}
Local cAlias      := "SF2"
Local aParam      := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
Local cParTrans   := if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022Con",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022Con" )
Local cNotasOk    := ""

MV_PAR01:=cSerie   := aParam[01] := PadR(ParamLoad(cParTrans,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
MV_PAR02:=cNotaini := aParam[02] := PadR(ParamLoad(cParTrans,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
MV_PAR03:=cNotaFin := aParam[03] := PadR(ParamLoad(cParTrans,aPerg,3,aParam[03]),Len(SF2->F2_DOC))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem das perguntas                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o serviço foi configurado - Somente o Adm pode configurar   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ParamBox(aPerg,STR0190,,,,,,,,cParTrans,.T.,.T.)  //"Consulta NFS-E"
	Processa( {|| Fisa022Ret(MV_PAR01,MV_PAR02,MV_PAR03,cAlias,@cNotasOk)}, "Aguarde...","(1/2) Verificando dados...", .T. )
	If Empty(cNotasOk)	
		Aviso(STR0262,STR0191,{STR0114},3)//"Nenhuma nota processada."
	Else
		Aviso(STR0262,STR0192 +CRLF+ cNotasOk,{STR0114},3)//"Processamento das Notas"
	EndIf
EndIf
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022XML³ Autor ³Vitor Felipe           ³ Data ³24/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED - utilizada em personalizacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022XML(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,dDtxml,cDEST,cNtXml,aNtXml,nForca,cSerieIni,cSerieFim,dDataIni,dDataFim,cGravaDest,cFtpT)
	Local cDxml 		:= ""
	Local cNotasOk		:= ""
	Local cIDTHREAD		:= ""
	Local cBarra		:= If(isSrvUnix(),"/","\")
	Local cPath			:= ""
	Local nHandle 		:= 0
	Local cDestOri 		:= cDEST
	Local cDirArq		:= ""

	Local lOk			:= .F.
	Local lDownload		:= .F.

	Local nX			:= 0
	Local nY			:= 0
	Local nCount		:= 0
	Local nPort			:= GetNewPar("MV_TSSFTPP",21)

	Local oWs
	Local lServerCp        := ( !empty( cGravaDest ) .and. Type("cGravaDest") <> "D" .and. allTrim( substr( cGravaDest,1,1 ) ) == '\' )

	Default cSerieIni	:= ""
	Default cSerieFim	:= ""
	Default dDataIni	:= Date()
	Default dDataFim	:= Date()
	Default nForca		:= 1
	Default cDEST		:= ""
	Default cFtpT 		:= "1"

	nPort := IIf( nPort <= 0, 21, nPort )

	cDxml := SubSTR(dtos(dDtxml),5,2)+"/"+subSTR(dtos(dDtxml),1,4)
	cDEST := RemoveExt(Lower(AllTrim(cDEST)))
	
	oWS := WsNFSE001():New()
	oWS:cUSERTOKEN            := "TOTVS"
	oWS:cID_ENT               := cIdEnt
	oWS:cDEST		          := cDEST
	oWS:dDATEDECL			  := dDtxml
	oWS:lREPROC				  := If(nForca==1,.T.,.F.)
	oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
	oWS:cFtpT				  := cFtpT

	If cEntSai == "0" .And. !( cCodMun $ GetMunNFT() )
		oWS:dDATAINI		:= dDataIni
		oWS:dDATAFIM		:= dDataFim
	
		oWS:oWSNFSEARR:OWSNOTAS     := NFSE001_ARRAYOFNFSESID1():New()
    
		For nX:= 1 To Len( aNtXml )
			aadd(oWS:oWSNFSEARR:OWSNOTAS:OWSNFSESID1,NFSE001_NFSESID1():New())
			oWS:OWSNFSEARR:OWSNOTAS:OWSNFSESID1[nX]:CID      := aNtXml[nX][01]+(aNtXml[nx][02]+aNtXml[nX][05])
		Next
	
		lOk := ExecWSRet( oWS ,"GeraArqImpArr" )

		If Valtype(oWS:CGERAARQIMPARRRESULT) <> "U" .And. lOk
			cIDTHREAD	:= oWS:CGERAARQIMPARRRESULT
		EndIf
		
		If !lOk
			cIDTHREAD := IIf( Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf
	Else
		If !( cCodMun $ GetMunNFT() )
			oWS:cIDINICIAL	 	:= cSerieIni+cNotaini
			oWS:cIDFINAL		    := cSerieFim+cNotafin
		
			lOk 		:= ExecWSRet( oWS ,"GeraArqImp" )

			If Valtype(oWS:CGERAARQIMPRESULT) <> "U" .And. lOk
				cIDTHREAD	:= oWS:CGERAARQIMPRESULT
			EndIf

			If !lOk
				cIDTHREAD := IIf( Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf
		Else
			oWS:dDATAINI		:= dDataIni
			oWS:dDATAFIM		:= dDataFim
		
			oWS:oWSNFSEARR:OWSNOTAS     := NFSE001_ARRAYOFNFSESID1():New()
	    
			For nX:= 1 To Len( aNtXml )
				aadd(oWS:oWSNFSEARR:OWSNOTAS:OWSNFSESID1,NFSE001_NFSESID1():New())
				oWS:OWSNFSEARR:OWSNOTAS:OWSNFSESID1[nX]:CID      := aNtXml[nX][01]+(aNtXml[nx][02]+aNtXml[nX][05])
			Next
		
			lOk 		:= ExecWSRet( oWS ,"GeraArqImpArr" )

			If Valtype(oWS:CGERAARQIMPARRRESULT) <> "U" .And. lOk
				cIDTHREAD	:= oWS:CGERAARQIMPARRRESULT
			EndIf

			If !lOk
				cIDTHREAD := IIf( Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf
		EndIf
	
		if ( lOk )
			oWs := WsSpedCfgNFe():New()
			oWs:cUSERTOKEN      := "TOTVS"
			oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			oWS:lftpEnable      := nil
		
			if ( execWSRet( oWS ,"tssCfgFTP" ) .And. oWS:lTSSCFGFTPRESULT ) .OR. cFtpT == "2" .Or. cFtpT == "3" .AND. cCodMun $ "3505708"
				cTss := strTran(upper(AllTrim(cURL)),"HTTP://","")
			
				if ( AT( ":" , cTss ) > 0 )
					cTss := substr(cTss,1,AT( ":" , cTss )-1)
				else
					cTss := substr(cTss,1,AT( "/" , cTss )-1)
				endif
			
				while nCount < 5
					IF cFtpT <> "2" .AND. cFtpT <> "3" // se nao é transmissao em banco matem legado
						if FTPCONNECT ( cTss , nPort ,"anonymous", "anonymous" )
							if FTPDIRCHANGE ( "/arqger/" + cCodMun )
								aRetDir := FTPDIRECTORY ( "*.*" , )
							
								if ( !empty(aRetDir) )
									for nY := 1 to len(aRetDir)
									//Busca o Arquivo pelo nome e pelo nome+"_";
										If (Upper(AllTrim(cDEST)) == Upper( Substr(Alltrim(aRetDir[nY][1]),1,At(".",Alltrim(aRetDir[nY][1]))-1 ) ) .OR.;
												Upper(AllTrim(cDEST)) $ Upper( Substr(Alltrim(aRetDir[nY][1]),1,At(".",Alltrim(aRetDir[nY][1]))-1)) .AND.;
												Substr(Alltrim(aRetDir[nY][1]),len(Alltrim(cDEST))+1,1) == "_")
									
											cPath := getSrvProfString("StartPath","")
								
											if ( substr(cPath,len(cPath),1) <> cBarra )
												cPath := cPath + cBarra
											endif
										
											cGravaDest := allTrim(cGravaDest)
																
											if ( substr(cGravaDest,len(cGravaDest),1) <> cBarra )
												cGravaDest := cGravaDest + cBarra
											endif
										
											if ( len(aRetDir) > 0 .and. nY <= len(aRetDir)  )
												sleep(1000) // Aguarda o processamento do TSS
											
												if( FTPDOWNLOAD( allTrim( cPath ) + aRetDir[nY][1],aRetDir[nY][1] ) )
													if( !lServerCp )
														lDownload := CpyS2T( allTrim( cPath ) + aRetDir[nY][1],cGravaDest,.F. )
													else
														lDownload := __CopyFile( allTrim( cPath ) + aRetDir[nY][1],cGravaDest + aRetDir[nY][1] )
													endIf
													
													FErase( allTrim( cPath ) + aRetDir[nY][1] )
												EndIf
											endif
										endif
									next nY
								endif
							EndIf
							FTPDISCONNECT ()
						EndIf
					Elseif cFtpT == "2" .OR. cFtpT == "3" .AND. cCodMun $ "3505708" // grava arquivo recebido
						If !Empty(cIDTHREAD)
							cArqTXT := Decode64(cIDTHREAD)
							cIDTHREAD := ""
							If !Empty(cDest) .and. cDestOri == cDest
								cDirArq := Alltrim(cGravaDest) + Alltrim(cDest)
							ElseIf !Empty(cDestOri)
								cDirArq := Alltrim(cGravaDest) + Alltrim(cDestOri)
							Else 
								cDirArq := Alltrim(cGravaDest) + "arquivo_envio.txt"
							Endif 
							If File(cDirArq) // verifica se arquivo destino ja existe .. 
								Ferase(cDirArq) // se existe apaga 
							Endif 
							nHandle := FCREATE(cDirArq) // cria arquivo em branco para gravação 
							if nHandle = -1
								conout("Erro ao criar arquivo " + cDirArq + "- ferror " + Str(Ferror()))
							else
								FWrite(nHandle, cArqTXT, len(cArqTxt))
								FClose(nHandle)
							endif
							lDownload := .T.
						Else 
							lDownload := .F.
							exit
						Endif 
					Endif 
					if ( !lDownload )
						nCount++
						sleep(10000)
					else
						exit
					endif
				end

				If (cFtpT == "3")
					if ( !lDownload )
						alert(STR0193)//"Não foi possível salvar o arquivo no local escolhido, salvo na pasta FTP do TSS."
					else
						msgInfo( STR0194 )//"Arquivo salvo com sucesso."
					endif
				EndIf	
			endif
		endif
	EndIf

	If lOk
		If cSerieIni+cNotaini <> cSerieFim+cNotafin
			cNotasOk += cNtXml
		Else
			cNotasOk += cSerieIni+cNotaini + CRLF
		EndIf
	EndIf
 
	If Empty(cNotasOk)
		cNotasOk := "Uma ou mais notas nao puderam ser transmitidas:"+CRLF+CRLF
		cNotasOk += "Verifique as notas processadas."+CRLF+CRLF
		If cFtpT <> "2" .OR. cFtpT <> "3"
			cNotasOk += IIf (cIDTHREAD <> nil ,cIDTHREAD,"")
		Endif 
	EndIf

	FreeObj(oWS)
	oWS := nil
	delClassIntF()

Return(cNotasOk)

//-----------------------------------------------------------------------
/*/{Protheus.doc} Fisa022Imp
Funcao que executa o metodo de importacao de arquivo de NFSe  retornado 
pela prefeitura para o TSS.
Utilizado para os modelos 101 e 102

@author Henrique Brugugnoli
@since 12.11.2010
@version 1.0 
/*/
//-----------------------------------------------------------------------
Function Fisa022Imp()

Local aPerg     := {}
Local aParam    := {Space(90)} 

Local cCodMun   := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cParImp   := if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022Imp",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022Imp" )
Local cIDThread := ""
Local cStatNfse := ""  
Local cBarra	  := If(isSrvUnix(),"/","\") 

Local lOk       := .F.
Local lFTP		  := .F.  
Local lUpload	  := .F.

Local nPort	  := GetNewPar("MV_TSSFTPP",21)
Local oWS

local cFtpT		:=  Alltrim(GetNewPar("MV_TSSFTPM","1"))
Local cImpRet 	:= ""


nPort := IIf( nPort <= 0, 21, nPort )

aParam[01] := PadR(ParamLoad(cParImp,aPerg,1,aParam[01]),Len(Space(90)))   

oWs := WsSpedCfgNFe():New()
oWs:cUSERTOKEN      := "TOTVS"
oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"	 
oWS:lftpEnable      := nil

if ( execWSRet( oWS ,"tssCfgFTP" ) )

	if ( oWS:lTSSCFGFTPRESULT )
		aAdd(aPerg,{6,STR0195,padr('',90),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_NETWORKDRIVE})//"Arquivo a ser importado"
		lFTP := .T.
	endif
	
endif

oWs := nil

if ( !lFTP )
	aadd(aPerg,{1,STR0196,aParam[01],"",".T.","",".T.",100,.F.})	//"Arquivo de retorno
endif

If (cFtpT <> "3")
	If ParamBox(aPerg,STR0197,@aParam,,,,,,,cParImp,.T.,.T.) //Monta tela de parâmetros -- Transmissão NFS-e

		if ( lFTP ) .and. cFtpT <> "2"
		
			cPath 	:= cBarra + "ftp"  + cBarra
		
			makeDir(  cPath ) 
		
			cLocal 	:= allTrim(MV_PAR01)		
			cFile 	:= substr(cLocal,rAt(cBarra,cLocal)+1)

			if ( substr(cPath,len(cPath),1) <> cBarra )
				cPath := substr(cPath,1,len(cPath)-1) + cBarra
			endif 		
			
			if cLocal <> cFile	
				if ( cpyT2S(cLocal,cPath) )
					
					cTss := strTran(upper(AllTrim(cURL)),"HTTP://","")
					
					if ( AT( ":" , cTss ) > 0 )
						cTss := substr(cTss,1,AT( ":" , cTss )-1)		
					else
						cTss := substr(cTss,1,AT( "/" , cTss )-1)
					endif 
					
					if FTPCONNECT ( cTss , nPort ,"anonymous", "anonymous" )    
							
						if FTPDIRCHANGE ( "/arqimp/" + cCodMun )
						
							FTPSETPASV(.F.)					
							
							if FTPUPLOAD ( cPath+cFile, cFile )
								msgInfo(STR0198)//"Arquivo copiado com sucesso."
								lUpload := .T.
							EndIf				
						
		
						endif 
						
						FTPDISCONNECT()
						
					endif					
					
					fErase(cPath+cFile)
				
				endif 
			endif
			if ( !lUpload )
				if cLocal == cFile
					alert(STR0199)	//"Não foi possível copiar o arquivo.Local não especificado."		
				else
					alert(STR0200)//"Não foi possível copiar o arquivo."
				endif
			endif  
			
		else	
			cFile := Alltrim(aParam[01])
		endif

		iF cFtpT == "2"
			If File(cFile)
				cImpRet := Encode64(FLearq(cFile,.T.))
				cFile := substr(cFile,rAt(cBarra,cFile)+1)
			Else
				cImpRet := ""
			Endif
		Endif

		oWS             := WsNFSE001():New()
		oWS:cUSERTOKEN  := "TOTVS" 
		oWS:CARQTXT     := cFile
		oWS:CCODMUN     := cCodMun
		oWS:CID_ENT     := cIdEnt
		oWS:_URL        := AllTrim(cURL)+"/NFSE001.apw"
		oWS:cFtpT 		:= cFtpT
		oWS:cARQIMPRET	:= cImpRet

		lOk           := ExecWSRet( oWS ,"ProcImpNFSETXT" ) //Chamada do método ProcImpNFSETXT para importar o arquivo retornado pela Prefeitura
		cIDThread     := oWS:CPROCIMPNFSETXTRESULT
		
		If !Empty(cIDThread)
			oWS:cIDTHREAD := cIDThread
		Endif
		
		lOk        := ExecWSRet( oWS ,"StatusNfse" ) //Chamada do método StatusNfse para validar a Thread retornada por ProcImpNFSETXT
		cStatNfse  := oWS:cSTATUSNFSERESULT
	Endif
Else
	msgInfo(STR0303)
EndIf	

If (cFtpT <> "3")
	If !Empty(cStatNfse) .Or. lOk
		Aviso(STR0261,STR0201,{STR0114},3) //NFS-e - "O arquivo de Retorno da Prefeitura foi importado com sucesso."
	Else
		Aviso(STR0261,STR0202,{STR0114},3)//"Nenhum arquivo foi importado."
	Endif
Endif

Return			

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022Ret³ Autor ³Roberto Souza          ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de retorno da Nota fiscal Digital de Serviços        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie da NF                                          ³±±
±±³          ³ExpC2: Nota inicial                                         ³±±
±±³          ³ExpC3: Nota final                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022Ret(cSerie,cNotaini,cNotaFin,cAlias,cNotasOk)
Local aArea     := GetArea()
Local aNotas    := {}
Local aRetNotas := {}
Local cRetorno  := ""
Local aXml      := {}
Local cAliasSF3 := "SF3"
Local cWhere    := ""
Local cErro     := ""
Local lQuery    := .F.
Local lRetorno  := .T.
Local nX        := 0
Local nY        := 0
Local nNFes     := 0
Local nXmlSize  := 0
Local dDataIni  := Date()
Local cHoraIni  := Time()
Local oWs
Local cPassCpf  := GetNewPar("MV_PSWNFD","")
Local cCpfUser  := GetNewPar("MV_CPFNFD","")
Local cHashSenha:= AllTrim(cPassCpf)
Local cNfd      := ""
Local cNfdEntRet:= ""


ProcRegua(0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina caso exista filtro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbClearFilter()
RetIndex(cAlias)

ProcRegua(Val(cNotaFin)-Val(cNotaIni)+1)
dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
	If cEntSai == "1"
		cWhere := "%(SubString(SF3.F3_CFO,1,1) >= '5')%"
	ElseIF cEntSai == "0"
		cWhere := "%(SubString(SF3.F3_CFO,1,1) < '5')%"
	EndiF
	cAliasSF3 := GetNextAlias()
	lQuery    := .T.
	BeginSql Alias cAliasSF3
		
	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE
				
	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFeLETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_SERIE = %Exp:cSerie% AND 
			SF3.F3_NFISCAL >= %Exp:cNotaIni% AND 
			SF3.F3_NFISCAL <= %Exp:cNotaFin% AND 
			%Exp:cWhere% AND 
			SF3.F3_DTCANC = %Exp:Space(8)% AND 
			SF3.%notdel%
	EndSql
	cWhere := ".T."	
#ELSE
	MsSeek(xFilial("SF3")+cSerie+cNotaIni,.T.)
#ENDIF

If cEntSai == "1"
	cWhere := "(SubStr(F3_CFO,1,1) >= '5')"
ElseIF cEntSai == "0"
	cWhere := "(SubStr(F3_CFO,1,1) < '5')"
EndiF	

While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
	(cAliasSF3)->F3_SERIE == cSerie .And.;
	(cAliasSF3)->F3_NFISCAL >= cNotaIni .And.;
	(cAliasSF3)->F3_NFISCAL <= cNotaFin

	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. SubStr((cAliasSF3)->F3_CFO,1,1)<"5" ) .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0
		
		IncProc("(1/2) "+STR0022+(cAliasSF3)->F3_NFISCAL) //"Preparando nota: "
		
		If Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere
			aadd(aNotas,{})	
			nX := Len(aNotas)
			aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
			aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
			aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
			aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
			aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
			aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
		EndIf
	EndIf		
	dbSelectArea(cAliasSF3)
	dbSkip()	
EndDo
If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
EndIf
ProcRegua(Len(aNotas))

For nX := 1 To Len(aNotas)
	IncProc("(2/2) "+"Verificando nota "+aNotas[nX][4]) //"Transmitindo XML da nota: "

	If cEntSai == "1"
		cStatusNf := Posicione("SF2",1,xFilial("SF2")+aNotas[nx][4]+aNotas[nx][3]+aNotas[nx][5]+aNotas[nx][6],"SF2->F2_FIMP")
	Else
		cStatusNf := Posicione("SF1",1,xFilial("SF1")+aNotas[nx][4]+aNotas[nx][3]+aNotas[nx][5]+aNotas[nx][6],"SF1->F1_FIMP")
	EndIF	
	
	If AllTrim(cStatusNf) == "T"
		DbSelectArea("CDQ")
		DbSetOrder(3)  //"CDQ_FILIAL+CDQ_DOC+CDQ_SERIE+CDQ_CLIENT+CDQ_LOJA+CDQ_CODMSG"
	
		If DbSeek(xFilial("CDQ")+aNotas[nX][4]+aNotas[nX][3]+aNotas[nX][5]+aNotas[nX][6]+"OK")
			cNfd := CDQ->CDQ_XMLRET
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criptografa a Senha de uso para a transmissão                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   //	cHashSenha:=sha1(cHashSenha,2)    
		//	cHashSenha:=Encode64(cHashSenha) 
		
		  //  cHashSenha:="cRDtpNCeBiql5KOQsKVyrA0sAiA="
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama o WebService para Transmissão                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//	oWs:= WSWsSaida():New()  - Função comentada devido as funções não compiladas apontados pela Engenharia, já é de conhecimento que algum cliente ainda usa essa função
			oWs:_URL                       := cURL+"wssaida.asmx"
			oWs:cCpfUsuario                := cCpfUser
			oWs:cHashSenha                 := cHashSenha
			oWs:cRecibo                    := cNfd
			oWs:cInscricaoMunicipal        := cInscMun
		
			lOk         := ExecWSRet(oWs,"NfdSaida")
			IF lOk
				cNfdEntRet	:= oWs:cNfdSaidaResult
			Else
				cNfdEntRet	:= "Falha ao conectar no WebService."	
			EndIf	
			
		//	GravaRet(nX,aNotas,cNfdEntRet,cNfd,@cNotasOk) - Função comentada devido as funções não compiladas apontados pela Engenharia, já é de conhecimento que algum cliente ainda usa essa função
		//	oWs:cConsultarAtividadesResult := cConsultarAtividadesResult
		Else
		
		EndIf

	Else
		cMsg := "Nota não verificada: [" + cStatusNf + "]"    
		cNotasOk += aNotas[nX][3] +" / "+ aNotas[nX][4] + cMsg +CRLF	     
	EndIf
	
Next nX

Eval(bFiltraBrw)
RestArea(aArea)

Return(cRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ        
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fisa022CFG³ Autor ³Roberto Souza          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configura o Ambiente para NFD                               ³±±
±±³          ³(Nota Fiscal Digital de Serviços)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisa022CFG()

Local oWizard
Local oCombo, oComboAmbs
Local oCbxGrava, oCbxFtpT
Local cCodMun   := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cCert     := Space(250)
Local cKey      := Space(250)
Local cModulo   := Space(250)
Local cPassWord := Space(50)
Local cCombo    := STR0097
Local cSlot     := Space(4)
Local cLabel    := Space(250)
Local cUsuario  := Space(250)
Local cSenha    := Space(250)   
Local cCbxGrava	:= ""
Local cCbxFtpT	:= ""
Local cAEDFe	:= Space(50)
local cClientID	:= space(50)
local cSecretID	:= space(250)
Local cChaveAut	:= Space(250)
Local cIdHex	:= ""

Local aTexto    := {}
Local aPerg     := {}
Local aPerg2    := {}
Local aParam    := {}
Local aParam2   := {}
Local aDadosEmp := {}

Local cAmbienteNFSe := STR0057 //"2-Homologação"
Local cModNFSE      := "0"
Local cVersaoNFSe   := "1   "
Local cCodSIAFI     := Space(4)
Local cUso          :="NFSE" 
Local cCnpJAut      := "  .   .   /    -  "

Local nGrava		:= 2
Local cFtpT			:= "1"
Local lOk			:= .F.
Local lPermite		:= .T.
Local lUsaIdHex := GetNewPar("MV_A3IDHEX",.F.)

If type ("_oObj") == "U" 
	_oObj := GetObjBrow()//Alimento a variável com o objeto do Browse principal (a variável está declarada como Private) 
EndIf

// Verificação se o usuário é Administrador e validação do Parametro MV_ADMNFSE
If !lMvAdmnfse
	lPermite := .T.
Else
	If lIsAdm
		lPermite := .T.
	Else
		lPermite := .F.
	EndIf
EndIf

If !lPermite
	Help(, , STR0203, "SEMPERM", STR0204, 1, 0)//"Acesso Negado"-"Usuário sem permissão para utilizar esta rotina."
Else
	aDadosEmp    := GetMunSiaf(cCodMun)

	if len (aDadosEmp) > 0
	cCodSIAFI   := aDadosEmp[1][1]
	cCodServ    := aDadosEmp[1][2]
	cVersaoNFSe := aDadosEmp[1][3]
	//aadd(aDados,{cSiafi,cCodServ,cVersaoNFSe})
	Endif 

	aadd(aParam,PadR(SuperGetMv("MV_RELSERV"),250))

	If SuperGetMv("MV_RELAUTH",,.F.)
		aadd(aParam,PadR(SuperGetMv("MV_RELACNT",,""),250))
	Else
		aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
	EndIf
	aadd(aParam,PadR(SuperGetMv("MV_RELPSW"),250))
	aadd(aParam,PadR(SuperGetMv("MV_RELFROM",,""),250))
	aadd(aParam,SuperGetMv("MV_RELAUTH",,.F.))
	aadd(aParam,PadR("",250))

	aadd(aPerg,{1,STR0085,aParam[1],"",".T.","",".T.",120,.F.})	//"Servidor SMTP"
	aadd(aPerg,{1,STR0086,aParam[2],"",".T.","",".T.",120,.F.})	//"Login do e-mail"
	aadd(aPerg,{1,STR0087,aParam[3],"",".T.","",".T.",120,.F.})	//"Senha"
	aadd(aPerg,{1,STR0090,aParam[4],"",".T.","",".T.",120,.F.})	//"Conta de e-mail"
	aadd(aPerg,{4,STR0088,aParam[5],STR0089,040,".T.",.F.})       //"Autenticação"###"Requerida"
	aadd(aPerg,{1,STR0128,aParam[6],"",".T.","",".T.",120,.F.})	//"Conta de e-mail de notificação"

	aadd(aParam2,PadR(SuperGetMv("MV_RELSERV"),250))
	If SuperGetMv("MV_RELAUTH",,.F.)
		aadd(aParam2,PadR(SuperGetMv("MV_RELACNT",,""),250))
	Else
		aadd(aParam2,PadR(SuperGetMv("MV_RELFROM",,""),250))
	EndIf                                                          	
	aadd(aParam2,PadR(SuperGetMv("MV_RELPSW"),250))

	aadd(aPerg2,{1,STR0093,aParam[1],"",".T.","",".T.",120,.F.})	//"Servidor POP"
	aadd(aPerg2,{1,STR0086,aParam[2],"",".T.","",".T.",120,.F.})	//"Login do e-mail"
	aadd(aPerg2,{1,STR0087,aParam[3],"",".T.","",".T.",120,.F.})	//"Senha"


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Interface                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aTexto,{})
		aTexto[1] := STR0038+CRLF //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus com o serviço Totvs Services SPED. "
		aTexto[1] += STR0039 //"O primeiro passo é configurar a conexão do Protheus com o serviço."

		aadd(aTexto,{})
		aTexto[2] := STR0040

		DEFINE WIZARD oWizard ;
			TITLE STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
			HEADER STR0019; //"Atenção"
			MESSAGE STR0020; //"Siga atentamente os passos para a configuração da nota fiscal eletrônica."
			TEXT aTexto[1] ;
			NEXT {|| .T.} ;
			FINISH {|| .T.}

		CREATE PANEL oWizard  ;
			HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE ""	;
			BACK {|| .F.} ;
			NEXT {|| IsReady(cCodMun, cURL, 1)} ;
			PANEL

		@ 010,010 SAY STR0042 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe a URL do servidor Totvs Services"
		@ 025,010 GET cURL SIZE 270,010 PIXEL OF oWizard:oMPanel[2]

		
			CREATE PANEL oWizard  ;
				HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
				MESSAGE ""	;
				BACK {|| .T.} ;
				NEXT {|| Iif(lIsAdm .or. !lMvAdmnfse,IsCDReady(@oCombo:nAt,@cCert,@cKey,@cPassWord,@cSlot,@cLabel,@cModulo,@cIdHex),.T.)} ;
				PANEL 
		
		If lIsAdm .or. !lMvAdmnfse
			@ 005,010 SAY STR0095 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o tipo de certificado digital"
			@ 005,105 COMBOBOX oCombo VAR cCombo ITEMS {STR0097, STR0176,""} SIZE 120,010 OF oWizard:oMPanel[3] PIXEL //"Formato Apache(.pem)"###"Formato PFX(.pfx ou .p12)"###"HSM"
			@ 020,010 SAY STR0043 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do certificado digital"
			@ 030,010 GET cCert SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 1
			TButton():New( 030,250,STR0044,oWizard:oMPanel[3],{||cCert := cGetFile(IIF(oCombo:nAt == 2,STR0045,STR0098),STR0072,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) //"Drive:"###"Arquivos .PEM |*.PEM","Selecione o certificado"
			@ 050,010 SAY STR0047 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe senha do arquivo digital"
			@ 060,010 GET cPassWord SIZE 100,010 PIXEL OF oWizard:oMPanel[3] PASSWORD
			@ 080,010 SAY STR0133 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Slot do certificado digital"
			@ 080,100 GET cSlot SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 2 PICTURE "999999999999999999"
			If lUsaIdHex 
				@ 095,010 SAY STR0177 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"ID Hex do certificado digital"
				@ 095,100 GET cIdHex SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 2
			Else
				@ 095,010 SAY STR0134 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] //"Label do certificado digital"
				@ 095,100 GET cLabel SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 2
			EndIF
			@ 114,010 SAY STR0135 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] //"Informe o nome do arquivo do modulo HSM"
			@ 111,120 GET cModulo SIZE 100,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 2 
		Else
			@ 005,010 SAY STR0175 SIZE 270,020 PIXEL OF oWizard:oMPanel[3]
		EndIf

		CREATE PANEL oWizard  ;
			HEADER STR0041 ; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE ""	;
			BACK {|| .T.} ;
			NEXT {|| SetParams(cIdEnt,cUrl,cCodMun,AllTrim(cAmbienteNFSe),AllTrim(cModNFSE),AllTrim(cVersaoNFSe),AllTrim(cCodSIAFI),cCnpJAut,cUsuario,cSenha,nGrava,cAEDFe,aDadosEmp[1][2],cChaveAut,cClientID,cSecretID,cFtpT)} ;
			PANEL



		@ 010,010 SAY STR0205 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Ambiente"
		@ 020,010 COMBOBOX oComboAmb VAR cAmbienteNFSe ITEMS {STR0056,STR0057} SIZE 060,010 PIXEL OF oWizard:oMPanel[4] 

		@ 040,010 SAY STR0206 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Versao"
		@ 050,010 GET cVersaoNFSe SIZE 020,010 PIXEL OF oWizard:oMPanel[4]                                                                                  

		@ 070,010 SAY STR0207 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Codigo SIAFI"
		@ 080,010 GET cCodSIAFI SIZE 030,010 PIXEL OF oWizard:oMPanel[4]                                                                                  	

		@ 010,110 SAY STR0208 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"CNPJ do Certificado Digital"
		@ 020,110 GET cCnpJAut SIZE 080,010 PICTURE "99.999.999/9999-99" PIXEL OF oWizard:oMPanel[4]

		If cCodMun $ "4321634-2925303-3118601-3203205-2921005-3117504-1702109-2800308-3157807-3503307-3538709-3300704-1400100-3156700-4303905-3302403-2803500-3148103-3146107-4308201-3304508-3541406-3171204-2301000-4315602-1100205-3200607-3301900-4107652-3305505-2301109-2700300-3524907-4313300-4102307-4119152-4317202-4201307-4105805-3302601-4118204-3200300-3510807-3169901-5213103-3551702-2909307-2928901-4202008-3305000-4104204-3510807-3505500-3306305-3510609-3555000-3549102" .Or. cCodMun $ Fisa022Cod( "004" ) .or. cCodMun $ Fisa022Cod( "006" ) .or. cCodMun $ Fisa022Cod( "011" ) .or. cCodMun $ Fisa022Cod( "012" ) .or. cCodMun $ Fisa022Cod( "016" )	.or. cCodMun $ Fisa022Cod( "027" )
			If aDadosEmp[1][2] == "006" .and. !cCodMun $ "4105508"
				@ 040,110 SAY STR0209 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"CPF do usuario"
			ElseIf !( cCodMun $ "4101507" )
				@ 040,110 SAY STR0211 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Nome de usuario"
			EndIf
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
			if cCodMun == "4315602"
				oUsuario:disable()
			endif

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

		elseIf cCodMun $ Fisa022Cod("013") .Or. ( cCodMun $ Fisa022Cod( "101" ) .or. cCodMun $ Fisa022Cod( "102" ) .or. ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  ) ) 

			If cCodMun $ Fisa022Cod("202") .Or. cCodMun $ Fisa022Cod("013")

				@ 040,110 SAY STR0213 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Código de usuario"
				@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

				@ 070,110 SAY STR0214 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Código de contribuinte"
				@ 080,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]

				@ 100,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
				@ 110,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
			Else

				oWs := WsSpedCfgNFe():New()
				oWs:cUSERTOKEN      := "TOTVS"
				oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"	 
				oWS:lftpEnable      := nil
				oWS:ctssftpmetodo   := Alltrim(GetNewPar("MV_TSSFTPM","1"))

				if ( execWSRet( oWS ,"tssCfgFTP" ) ) .And. !cCodMun $ "3550308"

					nGrava := if ( oWS:lTSSCFGFTPRESULT, 1, 2 )
					cFtpT  := oWS:ctssftpmetodo  
					@ 040,110 SAY STR0300 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Qual método de transferencia deseja usar?"
					If cCodMun == "3505708"
						@ 050,110 COMBOBOX oCbxFtpT VAR cCbxFtpT ON CHANGE cFtpT := oCbxFtpT:nAt ITEMS {"1-FTP","2-Banco de Dados","3-Web Service"} SIZE 060, 010 OF oWizard:oMPanel[4] PIXEL
					Else
						@ 050,110 COMBOBOX oCbxFtpT VAR cCbxFtpT ON CHANGE cFtpT := oCbxFtpT:nAt ITEMS {"1-FTP","2-Banco de Dados"} SIZE 060, 010 OF oWizard:oMPanel[4] PIXEL
					EndIf
					oCbxFtpT:nAt := Val(cFtpT)

					@ 070,110 SAY STR0215 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Grava arquivo em diretório local?"
					@ 080,110 COMBOBOX oCbxGrava VAR cCbxGrava ON CHANGE nGrava := oCbxGrava:nAt ITEMS {"1-Sim","2-Não"} SIZE 060, 010 OF oWizard:oMPanel[4] PIXEL
					oCbxGrava:nAt := nGrava  

				endif   

				oWS := NIL

			EndIf

		EndIf

		If cCodMun == "2111300"
			@ 070,110 SAY STR0216 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Autorização AEDF-e"
			@ 080,110 GET cAEDFe SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
		// Tratamento para Osasco - SP
		ElseIf cCodMun $ "3534401" + Fisa022Cod("009")+Fisa022Cod("010")+Fisa022Cod("015") + fisa022Cod( "029" )
			@ 040,110 SAY STR0217 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave de Autenticação"
			@ 050,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]
		ElseIf cCodMun $ Fisa022Cod("012")
			@ 100,110 SAY STR0218 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Seq. Registro"
			@ 110,110 GET cChaveAut SIZE 080,010 PIXEL OF oWizard:oMPanel[4] 
			@ 010,210 SAY STR0219 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Cod. Validação"
			@ 020,210 GET cAEDFe SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
		ElseIf cCodMun $ "4113700" //Londrina
			@ 100,110 SAY STR0220 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Código CMC"
			@ 110,110 GET cAEDFe SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
		ElseIf cCodMun $ "3171204" 
			@ 100,110 SAY STR0217 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave de Autenticação"
			@ 110,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]
		ElseIf aDadosEmp[1][2] $ "014"

			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

			@ 100,110 SAY STR0222 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Código Mobiliário"
			@ 110,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]

		ElseIf cCodMun $ "3144805-3157807-3129806-3131901"
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

			@ 100,110 SAY STR0223 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Frase Secreta"
			@ 110,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

		ElseIf cCodMun $ "5006606-4215802-5007695"	
			@ 040,110 SAY STR0224 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave de Acesso"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0263 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave de Autorização"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		elseIf( cCodMun $ fisa022Cod( "017" ) )
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

			@ 100,110 SAY STR0225 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Autorização"
			@ 110,110 GET cChaveAut SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 10,210 SAY STR0264 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Client ID"
			@ 20,210 GET cClientID SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 40,210 SAY STR0265 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Client Secret"
			@ 50,210 GET cSecretID SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,210 SAY STR0266 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"AEDFe"
			@ 080,210 GET cAEDFe SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

		elseIf( cCodMun $ fisa022Cod( "018" ) )
			@ 040,110 SAY STR0267 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Login"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

			@ 100,110 SAY STR0226 SIZE 270,010 PIXEL OF oWizard:oMPanel[4] //"Senha App"
			@ 110,110 GET cChaveAut SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

		elseIf( cCodMun $ Fisa022Cod("005") .Or. cCodMun $ Fisa022Cod("019") + "-5206206-4314407-3507506") //GO - Cristalina / SC - Pelotas
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD

			@ 100,110 SAY STR0217 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave de Autenticação"
			@ 110,110 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]
		elseIf(( cCodMun == "4304408" ) .Or. cCodMun $ Fisa022Cod("020") .or. cCodMun $ Fisa022Cod( "022" ) +"-4125506-3205069-2932903-2307700-3117876-3300605-1100023-3545308-3511102" )// Canela - RS + FGMAISS + São José de Ribamar
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		elseIf( cCodMun $ "4101507-4303509-2903201-2917508" ) // Arapongas - PR 
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]

			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		elseIf( cCodMun $ "2706901-3502903-3504008-3548005-1505437-3517406-1502152-1100122-3513504-2207702" )
			@ 040,110 SAY STR0221 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Usuário"
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
			@ 070,110 SAY STR0212 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Senha"
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		elseIf( cCodMun $ "3526902-3109303") //Radu + 3109303 Buritis/MG
			@ 100,110 SAY STR0227 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Token prefeitura"
			@ 110,110 GET cChaveAut SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		elseIf( cCodMun $ fisa022Cod( "023" ) ) // Sorriso - MT
			@ 100,010 SAY STR0228 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave Digital"
			@ 110,010 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]
		elseIf( cCodMun $ fisa022Cod( "024" )  ) // Sorriso - MT
			@ 100,010 SAY STR0228 SIZE 270,010 PIXEL OF oWizard:oMPanel[4]  //"Chave Digital"
			@ 110,010 GET cChaveAut SIZE 110,010 PIXEL OF oWizard:oMPanel[4]
		elseIf( cCodMun $ fisa022Cod( "025" ) )
			@ 040,110 SAY "Usuário" SIZE 270,010 PIXEL OF oWizard:oMPanel[4]
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
			@ 070,110 SAY "Senha" SIZE 270,010 PIXEL OF oWizard:oMPanel[4]
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
			@ 100,110 SAY "Token API" SIZE 270,010 PIXEL OF oWizard:oMPanel[4]
			@ 110,110 GET cChaveAut SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD	
		elseIf( cCodMun $ fisa022Cod( "028" ) + fisa022Cod( "030" ) )	
			@ 040,110 SAY "Usuário" SIZE 270,010 PIXEL OF oWizard:oMPanel[4]
			@ 050,110 GET oUsuario VAR cUsuario SIZE 080,010 PIXEL OF oWizard:oMPanel[4]
			@ 070,110 SAY "Senha" SIZE 270,010 PIXEL OF oWizard:oMPanel[4]
			@ 080,110 GET cSenha SIZE 080,010 PIXEL OF oWizard:oMPanel[4] PASSWORD
		EndIf

		CREATE PANEL oWizard  ;
			HEADER STR0041; //"Assistente de configuração da Nota Fiscal Eletrônica"
			MESSAGE "";
			BACK {|| oWizard:SetPanel(2),.T.} ;
			FINISH {|| lOk := .T.} ;
			PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[5]

		ACTIVATE WIZARD oWizard CENTERED
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsReady   ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a conexao com a Totvs Sped Services pode ser    ³±±
±±³          ³estabelecida                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN2: Código do município                               OPC³±±
±±³          ³ExpC1: URL do Totvs Services SPED                        OPC³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsReady(cCodMun, cURL, nTipo)
	
	Local lRetorno := .T.
	Local oWs      := Nil
	Local lUsaColab := UsaColaboracao("3")
	Default cCodMun := SM0->M0_CODMUN
	Default cURL	  := Padr(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250)

If !lUsaColab
	
	If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
			PutMV("MV_SPEDURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		
		DEFAULT cURL  := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		Default nTipo := 1	
	
	// Verifica se o servidor da Totvs esta no ar
	if  Empty(cURL)
		lRetorno := .F.
	Else
			oWs := WsSpedCfgNFe():New()
			oWs:cUserToken := "TOTVS"
			oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			If ExecWSRet( oWs ,"CFGCONNECT" )
				lRetorno := .T.
				If ExecWSRet( oWs ,"CFGTSSVERSAO" )
					cVerTSS := oWs:cCfgTSSVersaoResult
				EndIf
			Else
				Aviso("NFS-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				lRetorno := .F.
			EndIf
	Endif
			// Verifica se o certificado digital ja foi transferido
			If lRetorno .And. nTipo == 2
				oWs := WsNFSe001():New()
				oWs:cUserToken := "TOTVS"
				oWs:cID_ENT    := GetIdEnt()
				oWs:cCODMUN    := cCodMun
				oWS:_URL       := AllTrim(cURL)+"/NFSe001.apw"
				If ExecWSRet( oWs ,"CFGREADYX" )
					lRetorno := .T.
				Else
					lRetorno := .F.
				EndIf
			EndIf
EndIf
	
Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsCDReady ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o certificado digital foi transferido com suces-³±±
±±³          ³so                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: [1] PFX; [2] HSM                                     ³±±
±±³          ³ExpC2: Certificado digital                                  ³±±
±±³          ³ExpC3: Private Key                                          ³±±
±±³          ³ExpC4: Password                                             ³±±
±±³          ³ExpC5: Slot                                                 ³±±
±±³          ³ExpC6: Label                                                ³±±
±±³          ³ExpC7: Modulo                                               ³±±
±±³          ³ExpC8: ID Hex do certificado digital                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsCDReady(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo, cIdHex)

Local lRetorno := .T.
Local cMsg     := ""

Default cIdHex := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 1 ) .Or. !IsReady()

	If nTipo <> 3 .And. !File(cCert)
		Aviso(STR0261,STR0048,{STR0114},3) //"Arquivo não encontrado"
		lRetorno := .F.
	EndIf

	If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
		
		If Fisa022Pfx(cIdEnt,cCert,AllTrim(cPassWord),@cMsg,"NFSE")
			lRetorno := .T.
		Else
			lRetorno := .F.
		EndIf	
	EndIf
//---------------------------------------------
//Adequacao para utilização do Certificado A3 .HSM  para transmissão de NFS-e no M. Protheus (DSERTSS2-7956).
//
//@autor: Felipe Duarte Luna  @Data: 09/04/2021
//---------------------------------------------	
ElseIf (!Empty(cPassWord) .And. !Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cModulo) .And. lRetorno .And. nTipo == 2) .or.(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 2) .Or.;
	   (!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 2) .or. !IsReady()
	
	oWs:= WsSpedCfgNFe():New()
	oWs:cUSERTOKEN   := "TOTVS"
	oWs:cID_ENT      := cIdEnt
	oWs:cSlot        := AllTrim(cSlot)
	oWs:cModule      := AllTrim(cModulo)
	oWs:cPASSWORD    := AllTrim(cPassWord)
	If !Empty( cIdHex )
		oWs:cIDHEX      := AllTrim(cIdHex)
		oWs:cLabel      := ""
	Else
		oWs:cIDHEX      := ""
		oWs:cLabel       := AllTrim(cLabel)

	EndIf
	If nTipo == 1
		oWs:cPrivateKey  := FsLoadTXT(cKey)
	EndIf
	oWs:cPASSWORD    := AllTrim(cPassWord)
	oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	
	If oWs:CfgHSM()
		Aviso(STR0285,oWS:cCfgHSMResult,{STR0114},3) //"SPED"
	Else
		lRetorno := .F.
		Aviso(STR0285,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3) //"SPED"
	EndIf
EndIf
Return(lRetorno)           
                   

Function Fisa022Pfx(cIdEnt,cCert,cPassWord,cMsg,cUsoCert)
Local oWS
Local lRetorno := .T.    
Local cURL     := AllTrim(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"))


oWS:= WsNFSE001():New()
oWs:cUSERTOKEN   := "TOTVS"
oWs:cID_ENT      := cIdEnt 
oWs:cCertificate := GENLoadTXT(cCert)
oWs:cPASSWORD    := AllTrim(cPassWord)
oWS:_URL         := AllTrim(cURL)+"/NFSE001.apw"
oWS:CUso         := "NFSE"

	lOk := ExecWSRet( oWS ,"CFGNFSeCertPfx" )
	
	If lOk 
		oRetorno := oWS:CCFGNFSeCertPfxRESULT
		Aviso("NFS-e",oRetorno,{STR0114},3)
    Else
    	cMsg :=(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
		Aviso("NFS-e",cMsg,{STR0114},3)		
    EndIf

Return(lRetorno)     




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Fis022Mnt1³ Autor ³Roberto Souza          ³ Data ³01.02.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de monitoramento da NFS-e                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fis022Mnt1(lAuto,aMonitor,lUsaColab)

Local aPerg    		:= {}
Local aParam 	  	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(14),Space(14),CTOD("  /  /    "),CTOD("  /  /    "), Space(Len(SF1->F1_FORNECE)), Space(Len(SF1->F1_LOJA))}
Local aSize    		:= {}
Local aObjects 		:= {}
Local aListBox 		:= {}
Local aInfo    		:= {}
Local aPosObj  		:= {}
Local oWS
Local oDlg

Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local cCodMun     	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cParMnt    	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fis022Mnt1",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fis022Mnt1" )
Local cAliasSF2		:= GetNExtAlias()
Local cParNfseRem	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "AUTONFSEREM",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "AUTONFSEREM" )

Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")
Local lOk			:= .F.
Local oWsTss

Private oListBox

Default lUsaColab	:= UsaColaboracao("3")
Default lAuto		:= .F.
Default aMonitor	:= {}

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

If cEntSai == "0"
	aadd(aPerg,{1,STR0143,aParam[04],"",".T.","",".T.",45,.F.}) //" CNPJ Inicial"
	aadd(aPerg,{1,STR0144,aParam[05],"",".T.","",".T.",45,.T.}) //" CNPJ Final"  
	aadd(aPerg,{1,STR0141,aParam[06],"",".T.","",".T.",45,.F.}) //"Data Inicial"
	aadd(aPerg,{1,STR0142,aParam[07],"",".T.","",".T.",45,.T.}) //"Data Final"
	aadd(aPerg,{1,STR0304,aParam[08],"",".T.","",".T.",45,.F.}) //"Fornecedor"
	aadd(aPerg,{1,STR0305,aParam[09],"","ValidLoja(Space(Len(SF1->F1_LOJA)))","",".T.",45,.F.})	//"Loja"
EndIf

aParam[01] := ParamLoad(cParMnt,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParMnt,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParMnt,aPerg,3,aParam[03]) 

If cEntSai == "0"
	aParam[04] := ParamLoad(cParMnt,aPerg,2,aParam[04])
	aParam[05] := ParamLoad(cParMnt,aPerg,3,aParam[05])
	aParam[06] := ParamLoad(cParMnt,aPerg,4,aParam[06])
	aParam[07] := ParamLoad(cParMnt,aPerg,5,aParam[07])
	aParam[08] := ParamLoad(cParMnt,aPerg,5,aParam[08])
	aParam[09] := ParamLoad(cParMnt,aPerg,5,aParam[09])
EndIf

If lUsaColab .Or. IsReady()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaColab .Or. !Empty(cIdEnt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAuto

			Private cVerTss := ""

			aParam[1] 	:= MV_PAR01
			aParam[2] 	:= MV_PAR02
			aParam[3]	:= MV_PAR03

			If !lUsaColab
			oWsTss:= WsSpedCfgNFe():New()
			oWsTss:cUSERTOKEN      := "TOTVS"
			oWsTss:cID_ENT         := cIdEnt
			oWSTss:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
			lOk                    := IsReady(cCodMun, cURL, 1) // Mudar o terceiro parâmetro para 2 após o código de município 003 ter sido homologado no método CFGREADYX do serviço NFSE001

			If lOk
				lOk     := oWsTss:CfgTSSVersao()
				cVerTss := oWsTss:cCfgTSSVersaoResult
				EndIf
			EndIf

			aMonitor	:= WsNFSeMnt( cIdEnt, aParam, lUsaColab )
		Else

			If ParamBox(aPerg,STR0229,@aParam,,,,,,,cParMnt,.T.,.T.)  //"Monitor NFS-e"

				aListBox := WsNFSeMnt( cIdEnt, aParam, lUsaColab )

				If !Empty(aListBox)
					aSize 		:= MsAdvSize()
					aObjects	:= {}

					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )

					aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj	:= MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE STR0261 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"NFS-e"

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0268,STR0205,STR0269,STR0231,STR0270,STR0051,STR0052,STR0053; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
					SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL

					oListBox:SetArray( aListBox )
					oListBox:bLine := {|| {	IIf( Empty(aListBox[ oListBox:nAT,5 ]), oNo, oOk ),;   // Legenda    = S/ Prot. oNo -  C/ Prot. oOk
											aListBox[ oListBox:nAT,2 ],; 								   // ID         = Serie + RPS
											IIf( aListBox[ oListBox:nAT,3 ] == 1, STR0056, STR0057 ),; // Ambiente   = "Produção"###"Homologação"
											STR0058,; 														   // Modalidade = "Normal"
											aListBox[ oListBox:nAT,5 ],;								   // Protocolo
											aListBox[ oListBox:nAT,1 ],;								   // Cod. Ret
											aListBox[ oListBox:nAT,6 ],;								   // Mensagem
											aListBox[ oListBox:nAT,7 ],;								   // RPS
											aListBox[ oListBox:nAT,8 ]}}								   // NFS-e
					bLineBkp := oListBox:bLine
					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0114 ACTION (oDlg:End(),aListBox:={}) OF oDlg PIXEL SIZE 035,011 //"OK"
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT STR0054 ACTION (Bt2NFSeMnt(aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Historico"
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn4 PROMPT STR0118 ACTION (aListBox := WsNFSeMnt(cIdEnt,aParam,lUsaColab),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),RefListBox(oListBox,aListBox,bLineBkp))) OF oDlg PIXEL SIZE 035,011 //"Refresh"
					//-- Exibir botao para padroes que tenham schemas
					If (!lUsaColab .And. ( cCodMun $ Fisa022Cod("002") .Or. cCodMun $ Fisa022Cod("001") .Or. cCodMun $ Fisa022Cod("007") .Or. cCodMun $ Fisa022Cod("008") .Or. cCodMun $ Fisa022Cod("016") .Or. cCodMun $ Fisa022Cod("015") .Or. cCodMun $ Fisa022Cod("023") .Or. cCodMun $ Fisa022Cod("011") .Or. cCodMun $ Fisa022Cod("012") .Or. cCodMun $ Fisa022Cod("026") .Or. cCodMun $ Fisa022Cod("028") .Or. cCodMun $ Fisa022Cod("029") .Or. cCodMun $ fisa022Cod( "030" ) .Or. cCodMun $ "3305505-3127701-3503307-3552809-3306008" ).And. ( cEntSai == "1" )) .and. !(cCodMun $ "1503903") 
						@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn5 PROMPT STR0115 ACTION (DetSchema(cIdEnt,cCodMun,aListBox[ oListBox:nAT,2 ],2),oListBox:Refresh()) OF oDlg PIXEL SIZE 035,011 //"Schema"
					EndIf
					ACTIVATE MSDIALOG oDlg
				EndIf
			EndIf
		EndIf
	Else
		Aviso(STR0261,STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf
Else
	Aviso(STR0261,STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

//FwFreeObj(aListBox)
ASIZE (aListBox,0)
aListBox := nil
DelClassIntF()

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} wsNFSeMnt
Funcao que executa o monitoramento manual

@author Sergio S. Fuzinaka
@since 20.12.2012
@version 1.0      

@param cIdEnt	  		Codigo da entidade
@param aParam			Array de parametros

@return	aListBox		Array - montagem da grid do monitor
/*/
//-----------------------------------------------------------------------
Function WsNFSeMnt( cIdEnt, aParam, lUsaColab , aRet )

Local nX			:= 0
Local aListBox	 	:= { .F., "", {} }
Local cSerie		:= ""
Local cIdInicial	:= ""
Local cIdFinal		:= ""
Local cCNPJIni		:= ""
Local cCNPJFim		:= ""
Local dDataIni		:= CtoD("  /  /    ")
Local dDataFim		:= CtoD("  /  /    ")
Local cFornec 		:= ""
Local cLoja 		:= ""
Local aIdNotas		:= {}
Local cMod004		:= ""
Local nTpMonitor	:= 1
Local cModelo		:= "56"
Local lCte			:= .F.
Local cAviso		:= ""

Default aRet		:= {}
Default cIdEnt		:= ""
Default aParam		:= {}
Default lUsaColab	:= UsaColaboracao("3")

If Len( aParam ) > 0

	If lUsaColab
		//-- TOTVS Colaboracao 2.0 Monitoramento da nota de serviço
		aRet := colNfsMonProc( aParam, nTpMonitor, cModelo, lCte, cAviso, lUsaColab )
		If !Empty(cAviso)
			Aviso( STR0261, cAviso, { STR0114 }, 3 ) //"Ok"
		EndIf
		
		Return( aRet ) // Retorno para o TC2.0
		
	Else
		cMod004		:= Fisa022Cod("004")
		cSerie		:= aParam[ 1 ]
		cIdInicial	:= aParam[ 2 ]
		cIdFinal	:= aParam[ 3 ]

		If cEntSai == "0"
			cCNPJIni := aParam[ 4 ]
			cCNPJFim := aParam[ 5 ]
			dDataIni := aParam[ 6 ]
			dDataFim := aParam[ 7 ]
			cFornec	 := IIF(!EMPTY(aParam[ 8 ]), aParam[ 8 ],'' )
			cLoja 	 := IIF(!EMPTY(aParam[ 9 ]), aParam[ 9 ],'' )
		Endif
		
		// aIdNotas[ 1 ]: Numero do documento
		// aIdNotas[ 2 ]: Flag ( documento ja retornado pelo TSS )
		aIdNotas := IdNfRet( aParam )
		
		Processa( {|| execMonitor( cIdEnt , cSerie , cCNPJIni , cCNPJFim, dDataIni, dDataFim , cMod004 , aIdNotas , @aListBox, cFornec, cLoja  ) } , STR0169 , STR0170 , .F. ) //"Aguarde..." ### "Monitorando Nota Fiscal Eletrônica de Serviços..."
		
		If !aListBox[1]

			If !Empty( aListBox[ 2 ] )

				Aviso( STR0261, aListBox[ 2 ], { STR0114 }, 3 )

			ElseIf ( Empty( aListBox[ 3 ] ) )

				Aviso( STR0261, STR0106, { STR0114 } ) //NFS-e

			Endif

		Endif

		If Len( aListBox[3] ) > 0
			aListBox[3] := aSort( aListBox[3],,,{|x,y| x[2] > y[2]} )
		Endif
	
		Return( aListBox[ 3 ] ) // Retorno para o TSS

	Endif

Endif

Return aRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} MonitorNFSE
Monitoramento manual e automatico da NFS-e

@author Sergio S. Fuzinaka
@since 20.12.2012

@version 1.0      
/*/
//-----------------------------------------------------------------------
Function MonitorNFSE( cIdEnt, cSerie, aLote, cCNPJIni, cCNPJFim, cMod004, dDataIni, dDataFim ,lUsaColab, cFornec, cLoja)

Local aListBox 		:= { .F., "", {} }
Local nTipoMonitor	:= 1
Local cIdInicial	:= ""
Local cIdFinal		:= ""
Local cIdNotas		:= ""
Local nBytes		:= 0
Local nX			:= 0

Default cIdEnt		:= ""
Default cSerie		:= ""
Default aLote		:= {}
Default cCNPJIni	:= ""
Default cCNPJFim	:= ""
Default dDataIni	:= CtoD("  /  /    ")
Default dDataFim	:= CtoD("  /  /    ")
default lUsaColab	:= UsaColaboracao("3")
Default cFornec		:= ""
Default cLoja		:= ""

For nX := 1 To Len( aLote )
	nBytes += Len( "'" + cSerie + Alltrim( aLote[nX] ) + "', " )
			
	If nBytes <= 950000
		cIdNotas += ( "'"  + cSerie + Alltrim( aLote[nX] ) + "'" ) + IIf( nX < Len( aLote ), ", ", "" )
	Else
		Exit
	Endif
Next
	
If Len( aLote ) > 0

	cIdInicial	:= aLote[ 1 ]
	cIdFinal	:= aLote[ Len( aLote ) ]
	
	aListBox 	:= FisMonitorX( cIdEnt, cSerie, cIdInicial, cIdFinal, cCNPJIni, cCNPJFim, nTipoMonitor, dDataIni, dDataFim, /* cHoraDe */, /* cHoraAte */, /* nTempo */, /* nDiasParaExclusao */, cIdNotas, cMod004, cFornec, cLoja )
Endif
	
Return( aListBox )

//-----------------------------------------------------------------------
/*/{Protheus.doc} FisMonitorX
Funcao executa o metodo MonitorX()

@author Sergio S. Fuzinaka
@since 20.12.2012
@version 1.0      

@param cIdEnt	  		Codigo da entidade
@param aParam			Array de parametros
@param aDados			Dados da Nfs-e

@return	aListBox[1]		Logico   - status processamento
@return	aListBox[2]		Caracter - mensagem de erro
@return	aListBox[3]		Array    - montagem da grid do monitor

@Obs	A rotina de monitoramento da nfs-e eh executado de forma manual e automatica (Auto-Nfse), por este motivo nao dever ser utilizada
		funcoes de alertas como: MsgInfo, MsgAlert, MsgStop, Alert, Aviso, etc.
/*/
//-----------------------------------------------------------------------
Static Function FisMonitorX( cIdEnt, cNumSerie, cIdInicial, cIdFinal, cCNPJIni, cCNPJFim, nTipoMonitor, dDataDe, dDataAte, cHoraDe, cHoraAte, nTempo, nDiasParaExclusao, cIdNotas, cMod004, cFornec, cLoja )

Local aRetorno				:= {}
Local aListBox 				:= {}
Local aMVTitNFT				:= &(GetNewPar("MV_TITNFTS",'{{""},{""}}'))
Local aMsg     				:= {}
Local aDataHora				:= {}
Local aParam			    := {Space(TamSX3("F2_SERIE")[1]),Space(TamSX3("F2_DOC")[1]),Space(TamSX3("F2_DOC")[1])}

Local dEmiNfe				:= CTOD( "" )
Local cMsgErro			:= ""
Local cHorNFe				:= ""  
Local cNumero				:= ""
Local cSerie				:= ""
Local cRecomendacao		:= ""
Local cNota				:= ""
Local cRPS					:= ""
Local cCnpjForn			:= ""
Local cProtocolo			:= ""
Local cURL     			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)     
Local cCodMun			:= AllTrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ))
Local cURLNfse			:= ""
Local cIdSerie			:= ""
Local lOk      			:= .F.
Local lRetorno			:= .T.
Local lRetNumRps			:= GetNewPar("MV_RETRPS",.F.)  // Número da NFS-e gerada pela Prefeitura.
Local lUsaColab				:= UsaColaboracao("3")
Local lFAtuNF			:= .F.
Local nX	 				:= 0
Local nXxmlTinus		:= 0 
Local nXtinus			:= 0
Local nY       			:= 0
Local nAmbiente			:= 2
Local cCallName			:= "PROTHEUS"	// Origem da Chamado do WebService

Local oRetorno			:= Nil
Local lErroNot			:= .F.
Local cNotasOk			:= ""
Private oWS    			:= Nil
Private oXml				:= Nil  
Private oRetxml			:= Nil  
Private oRetxmlrps	 	:= Nil  

Default cIdEnt			:= ""
Default cNumSerie			:= ""
Default cIdInicial		:= ""
Default cIdFinal			:= ""
Default cCNPJIni			:= ""
Default cCNPJFim			:= ""
Default nTipoMonitor		:= 1
Default dDataDe			:= CTOD( "01/01/1949" )
Default dDataAte			:= CTOD( "31/12/2049" )
Default cHoraDe			:= "00:00:00"
Default cHoraAte			:= "00:00:00"
Default nTempo			:= 0
Default nDiasParaExclusao:= 0
Default cIdNotas			:= ""
Default cFornec		:= ""
Default cLoja		:= ""

If ExistBlock("F022ATUNF") // Verificação fora do loop, de acordo com as regras internas
	lFAtuNF := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do Totvs Colaboração 2.0                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lUsaColab

	aParam[01] := cNumSerie  //MV_PAR01 Serie
	aParam[02] := cIdInicial  //MV_PAR02 Nota inicial
	aParam[03] := cIdFinal  //MV_PAR03 Nota final

	WsNFSeMnt(cIdEnt,aParam,,@aListBox)

	For nx := 1 To len (aListBox)
		autoNfseMsg( "[Monitoramento] Nota Monitorada: " + Alltrim(aListBox[nx][2])+" - "+Alltrim(aListBox[nx][6]) + ".	Thread ["+cValToChar(ThreadID())+"] ", .F. )
	Next
EndIf

If !lUsaColab
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do WebService da NFS-e                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

oWS := WsNFSE001():New()

oWS:cUSERTOKEN   		:= "TOTVS"
oWS:cID_ENT      		:= cIdEnt 
oWS:_URL         		:= AllTrim(cURL)+"/NFSE001.apw"
oWS:cCODMUN    			:= cCodMun
oWS:dDataDe       		:= dDataDe
oWS:dDataAte     		:= dDataAte
oWS:cHoraDe       		:= cHoraDe
oWS:cHoraAte 			:= cHoraAte
oWS:nTipoMonitor		:= nTipoMonitor
oWS:nTempo   			:= nTempo 

If Type("cVerTss") <> "U" .And. cVerTss >= "2.19"  .Or. Val(substr(cVerTss,1,2)) >= 12
	oWS:nDiasParaExclusao	:= nDiasParaExclusao
	oWS:cIdNotas	  		:= cIdNotas 
	oWS:cCallName			:= cCallName
Endif

If cEntSai == "0" .And. cCodMun $ "3304557"
	oWS:cIdInicial := cNumSerie+cIdInicial+cCNPJIni
	oWS:cIdFinal   := cNumSerie+cIdFinal+cCNPJFim+"FIN"
ElseIf (cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202")) .And. cCodMun $ GetMunNFT() .and. !cCodMun $ "3550308"
	oWS:cIdInicial := cNumSerie+PADR(cIdInicial,TamSX3("F1_DOC")[1])+cCNPJIni
	oWS:cIdFinal   := cNumSerie+PADR(cIdFinal,TamSX3("F1_DOC")[1])+cCNPJFim+"FIN"
Else 		
	oWS:cIdInicial := cNumSerie+cIdInicial
	oWS:cIdFinal   := cNumSerie+cIdFinal
EndIf

incProc( "["+ oWS:cIdInicial +"] - ["+ oWS:cIdFinal +"]" )

lOk := ExecWSRet(oWS,"MonitorX")

If ( lOk )

	oRetorno := oWS:OWSMONITORXRESULT
	
	SF3->(dbSetOrder(5))
	
	For nX := 1 To Len(oRetorno:OWSMONITORNFSE)
		
		aMsg 			:= {}
		lRegFin 		:= .F.
						
		oXml 			:= oRetorno:OWSMONITORNFSE[nX]
		If cCodmun $ "2503209"
			If !("dthremisnfse" $ oXml:CXMLRETTSS) .and. len(oRetorno:OWSMONITORNFSE) > 1
				nXxmlTinus := len(oRetorno:OWSMONITORNFSE)
					For nXtinus :=1 To nXxmlTinus
						If ("dthremisnfse" $ oRetorno:OWSMONITORNFSE[nXtinus]:CXMLRETTSS) .AND. (AllTrim(oRetorno:OWSMONITORNFSE[nXtinus]:CDATAHORA) == AllTrim(oXml:CDATAHORA))
							oXml:CXMLRETTSS := oRetorno:OWSMONITORNFSE[nXtinus]:CXMLRETTSS
							EXIT
						Else 
							oXml:CXMLRETTSS := ""
						Endif 
					Next nXtinus
			ElseIf ("DataEmissao" $ oXml:OWSNFE:CXMLPROT) .and. !("dthremisnfse" $ oXml:CXMLRETTSS)
				oXml:CXMLRETTSS := ""
			Endif 
		Endif 
		
		if lRegFin
	 		cNumero			:= PADR(SUBSTR(oXml:Cid,4,Len(oXml:Cid)),TamSX3("E2_NUM")[1])	
	 	else
		 	cNumero			:= PADR(Substr(oXml:cID,4,Len(oXml:cID)),TamSX3("F2_DOC")[1])	
	 	endif
		
		cProtocolo		:= oXml:cPROTOCOLO
		dEmiNfe			:= CTOD( "" )
		cHorNFe			:= ""
		cSerie			:= Substr(oXml:cID,1,3)
		If 'Retransmita o ID :' $ oXml:cRECOMENDACAO
			cIdSerie := cSerie + Alltrim(cNumero)
			cRecomendacao	:= "Nota ID: "+ cIdSerie +" não autorizada. Verifique o histórico e avalie o(s) motivo(s)."
		Else
			cRecomendacao	:=	oXml:cRECOMENDACAO
		EndIf	
		cNota			:= oXml:cNota
		cRPS			:= oXml:cRPS
		cCnpjForn		:= padR(Substr(oXml:cid,13,Len(oXml:cid)),14)
		nAmbiente		:= oXml:nAmbiente
		if Type("oXml:cURLNFSE") <> "U"
			cURLNfse := oXml:cURLNFSE
		endif
		
		if RAT( "FIN", oXml:cid ) > 0 .And. SubStr( oXml:cid, RAT( "FIN", oXml:cid ) ) == "FIN" .And. cEntSai == "0"
			lRegFin := .T.			
		endif

		// Ignora a data de hora para NFTS de SP
		if!( cCodMun == "3550308" .and. type( "oXml:oWSNFE:cXMLERP" ) <> "U" .and. "<NFTS>" $ oXml:oWSNFE:cXMLERP )
			// Retorna a Data e a Hora do arquivo XML
			aDataHora := FisRetDataHora( oRetorno:OWSMONITORNFSE[nX], cMod004 )
		
			If Len( aDataHora ) > 0
				dEmiNfe	:= aDataHora[ 1 ]	// Data
				cHorNFe	:= aDataHora[ 2 ]	// Hora
			Endif
		endIf
		
		// Atualiza os dados com as mensagens de transmissao
		If ( Type("oXml:OWSERRO:OWSERROSLOTE") <> "U" )
			
			For nY := 1 To Len(oXml:OWSERRO:OWSERROSLOTE)
				
				If ( oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM <> '' .Or. oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO <> '' )  
					If (oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO <> '' .and. oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM <> '')
						aadd(aMsg,{oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO,oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM})
					Elseif (oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO == '' .and. oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM <> '')
						oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO := '0000'
						aadd(aMsg,{oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO,oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM})
					Elseif (oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO <> '' .and. oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM == '')
						oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM := ' Sem mensagem de retorno da Prefeitura ' 
						aadd(aMsg,{oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO,oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM})
					Else
						aadd(aMsg,{oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO,oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM})
					EndIf
				Else
						lErroNot := .T.
				EndIf
				
			Next nY
			
		EndIf
		
		If ( Empty( aMsg ) )
				aAdd( aMsg, { "", "" } )
			Else
				lErroNot := .F.
		EndIf
		
			If FindFunction( "autoNfseMsg" )
				autoNfseMsg( "[Monitoramento] Nota Monitorada: " + cSerie + cNumero, .F. )
			EndIf
			//-- Atualizacao dos documentos
			Fis022Upd(cProtocolo, cNumero, cSerie, cRecomendacao, cNota, cCnpjForn, dEmiNfe, cHorNFe, cCodMun, lRegFin, aMsg, lUsaColab, cFornec, cLoja)
			If !lErroNot
				aAdd( aListBox, {	"",;
									cSerie + cNumero,;
									nAmbiente,; //"Produção"###"Homologação"
									STR0058,; //"Normal"
									cProtocolo,;
									PADR( cRecomendacao, 250 ),;
									cRPS,;
									cNota,;
									aMsg,;
									cURLNfse} )
			EndIf
			
			//Ponto de entrada para o cliente customizar a gravação de 
			//campos proprios no SF2/SF1 a partir do refreh no monitor de notas
			If lFAtuNF
				ExecBlock("F022ATUNF",.F.,.F.,{cSerie,cNumero,cProtocolo,cRPS,cNota,aMsg,cURLNfse})
			EndIf
		Next nX

		If Empty( aListBox )
			lRetorno := .F.
			cMsgErro := STR0106 //"Não há dados"
		EndIf
	Else
		lRetorno := .F.
		cMsgErro := IIf( Empty(GetWscError(3)), GetWscError(1), GetWscError(3) )
	EndIf

EndIf

	aRetorno	:= {}
	aAdd( aRetorno, lRetorno )
	aAdd( aRetorno, cMsgErro )
	aAdd( aRetorno, aListBox )

	FreeObj(oWS)
	FreeObj(oXml)
	FreeObj(oRetxml)
	FreeObj(oRetxmlrps)
	oWS			:= Nil
	oXml		:= Nil
	oRetxml		:= Nil
	oRetxmlrps	:= Nil
	delClassIntF()

Return( aRetorno )
//-------------------------------------------------------------------
/*/{Protheus.doc} Fis022Upd
Funcao de atualizacao dos documentos - SEFAZ / NFs-e.

@author	Flavio Luiz Vicco
@since		15/08/2014
@version	1.0
/*/
//-------------------------------------------------------------------
Function Fis022Upd(cProtocolo, cNumero, cSerie, cRecomendacao, cNota, cCnpjForn, dEmiNfe, cHorNFe, cCodMun, lRegFin, aMsg, lUsaColab, cFornec, cLoja)

Local aMVTitNFT		:= &(GetNewPar("MV_TITNFTS",'{{""},{""}}'))
Local cNotaArq		:= ""
Local lF3CODRSEF		:= SF3->(FieldPos("F3_CODRSEF")) > 0
Local lF3CODRET		:= SF3->(FieldPos("F3_CODRET" )) > 0 .And. SF3->(FieldPos("F3_DESCRET")) > 0
Local lE2FIMP			:= SE2->(FieldPos("E2_FIMP"   )) > 0
Local lE2NFELETR		:= SE2->(FieldPos("E2_NFELETR")) > 0
Local nTamDoc			:= TamSx3("F2_NFELETR")[1]
Local lExisCOP		:= AliasIndic("C0P")
Local lRetNumRps		:= GetNewPar("MV_RETRPS",.F.)  // Número da NFS-e gerada pela Prefeitura.
Local cIdEnt			:= GetIdEnt()
Local cUrl				:= Padr(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250)
local cAlias := ""
Default cProtocolo 	:= ""
Default cNumero		:= ""
Default cSerie		:= ""
Default cRecomendacao:= ""
Default cNota			:= ""
Default cCnpjForn		:= ""
Default dEmiNfe		:= CTOD( "" )
Default cHorNFe		:= ""
Default cCodMun		:= SM0->M0_CODMUN
Default lRegFin 		:= .F.
Default aMsg    		:= {}
Default lUsaColab		:= UsaColaboracao("3")

If lUsaColab 
    if ( 'aguarde o processamento' $ cRecomendacao )
		aMsg := {}
		aAdd(aMsg,{"  ",cRecomendacao})
    else
		aMsg := {}
		aAdd(aMsg,{"999",cRecomendacao})
	endif
ElseIf ( 'Schema Invalido' $ cRecomendacao )
	aMsg := {}
	aAdd(aMsg,{"999",cRecomendacao})
Endif
			
if Len( aMsg ) > 0 .And. !Empty( aMsg[1][1] )
	If ( cEntSai == "1" )
				//-- NFS-e Nao Autorizada
		SF2->(dbSetOrder(1))
		If ( SF2->(MsSeek(xFilial("SF2")+cNumero+cSerie,.T.)) )
						
			SF2->( RecLock("SF2") )
			IF ( "002 -" $  cRecomendacao )
				SF2->F2_FIMP := "T" //NF Transmitida ,'BR_AZUL'
			ELSEIF ( "005 -" $  cRecomendacao )
				SF2->F2_FIMP := "T" //NF Transmitida ,'BR_AZUL'
			ELSE
				SF2->F2_FIMP := "N" //NF nao autorizada, 'BR_PRETO'
			ENDIF
			SF2->( MsUnlock() )
						
			SF3->(dbSetOrder(5))
			If ( SF3->(MsSeek(xFilial("SF3")+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)) )
							
				If SF3->( FieldPos("F3_CODRSEF") ) > 0
					SF3->( RecLock("SF3") )
					IF ( "002 -" $  cRecomendacao )
						SF3->F3_CODRSEF := "T" //NF Transmitida ,'BR_AZUL'
						SF3->F3_CODRET  := "T" 
					ELSEIF ( "005 -" $  cRecomendacao )
						SF3->F3_CODRSEF := "C" //NF Transmitida ,'BR_AZUL'
						SF3->F3_CODRET  := "T" 
					ELSE
						SF3->F3_CODRSEF := "N" //NF nao autorizada, 'BR_PRETO'
					ENDIF
					If	lF3CODRET .And. Empty(SF3->F3_CODRET)
						SF3->F3_CODRET	:= aMsg[1][1]
						SF3->F3_DESCRET	:= aMsg[1][2]
									
					EndIf
								
					SF3->( MsUnlock() )
				EndIf
							
			EndIf
		EndIf
				
	elseif ( lRegFin )
				//-- Financeiro - Contas a Pagar
		SE2->(dbSetOrder(1))
					
		If ( SE2->(MsSeek(xFilial("SE2")+(cSerie+cNumero),.T.)) ) .And. SE2->( FieldPos("E2_FIMP") ) > 0
						
			While SE2->(!eof()) .And. xFilial("SE2") == SE2->E2_FILIAL .And. ( PADR(cNumero,LEN(SE2->E2_NUM)) == SE2->E2_NUM) .And. ( cSerie == SE2->E2_PREFIXO )
							
				If cCnpjForn == Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC") .And. ;
						aScan(aMVTitNFT,{|x| x[1]==SE2->E2_TIPO}) > 0 .And. SE2->E2_FIMP <> "N"
								
					RecLock("SE2")
					IF ( "002 -" $  cRecomendacao )
						SE2->E2_FIMP := "T" //NF Transmitida ,'BR_AZUL'
					ELSEIF ( "005 -" $  cRecomendacao )
						SE2->E2_FIMP := "T" //NF Transmitida ,'BR_AZUL'
					ELSE
						SE2->E2_FIMP := "N" //NF nao autorizada, 'BR_PRETO'
					ENDIF
					SE2->(MsUnlock())
								
				EndIf
						
				SE2->(dbSkip())
						
			EndDo
								 	
		EndIf
					
	Else
				//-- NFS-e
		SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
		If ( SF1->(MsSeek(xFilial("SF1")+cNumero+cSerie+cFornec+cLoja,.T.)) )
						
			SF1->( RecLock("SF1") )
			IF ( "002 -" $  cRecomendacao )
				SF1->F1_FIMP  := "T" //NF Transmitida ,'BR_AZUL'
			ELSEIF ( "005 -" $  cRecomendacao )
				SF1->F1_FIMP  := "T" //NF Transmitida ,'BR_AZUL'
			ELSE
				SF1->F1_FIMP := "N" //NF nao autorizada,'BR_PRETO'
			ENDIF
			SF1->( MsUnlock() )
					//-- Livros Fiscais
			SF3->(dbSetOrder(5))
			If SF3->( MsSeek( xFilial("SF3")+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA ) )
							
				If SF3->( FieldPos( "F3_CODRSEF" ) ) > 0
					SF3->( RecLock("SF3") )
					IF ( "002 -" $  cRecomendacao )
						SF3->F3_CODRSEF := "T" //NF Transmitida ,'BR_AZUL'
						SF3->F3_CODRET  := "T"
					ELSEIF ( "005 -" $  cRecomendacao )
						SF3->F3_CODRSEF := "C" //NF Transmitida ,'BR_AZUL'
						SF3->F3_CODRET  := "T"
					ELSE
						SF3->F3_CODRSEF := "N" //NF nao autorizada,'BR_PRETO'
						SF3->F3_CODRET  := ""
					ENDIF
					SF3->( MsUnlock() )
				EndIf
							
			EndIf
						
		EndIf
					
	EndIf

				//Atualização da tabela de AIDF
	if aliasIndic("C0P")
		C0P->(dbSetOrder(1))
		if C0P->(dbSeek(xFilial() +  padr(cValToChar(val(SF3->F3_NFISCAL)), tamSX3("C0P_RPS")[1] ) ) )
			reclock("C0P")
			C0P->C0P_AUT		:= "N"
			C0P->(msunlock())
		endif
	endif
endif

			
	If ( "Emissao de Nota Autorizada" $ cRecomendacao ) .Or. (lUsaColab .And. "Emissão de nota autorizada" $ cRecomendacao )
		aMsg := {}
		aAdd(aMsg,{"111",cRecomendacao})
	ElseIf ( 'Nota Fiscal Substituida' $ cRecomendacao )
		aMsg := {}
		aAdd(aMsg,{"222",cRecomendacao})
		ElseIf ( 'Cancelamento do RPS Autorizado' $ cRecomendacao ).OR.( 'Cancelamento da NFS-e autorizado' $ cRecomendacao )  
		aMsg := {}
		aAdd(aMsg,{"333",cRecomendacao})
	ElseIf ( 'aguarde o processamento' $ cRecomendacao ).And. lUsaColab 
		aMsg := {}
		aAdd(aMsg,{"  ",cRecomendacao})
	EndIf
			
	If ( cEntSai == "1"	)
			//-- NFS-e Autorizada
		SF2->( dbSetOrder(1) )
		If SF2->(MsSeek(xFilial("SF2")+cNumero+cSerie,.T.))
					
			SF2->( RecLock("SF2") )
					
			If ( !Empty(cNota) ) .And. !Empty(RTrim(cProtocolo))
				SF2->F2_FIMP 		:= "S" //NF Autorizada, 'BR_GREEN'
				SF2->F2_NFELETR	:= RIGHT(cNota,nTamDoc)
				SF2->F2_EMINFE	:= dEmiNfe
				SF2->F2_HORNFE	:= cHorNFe
				SF2->F2_CODNFE	:= RTrim(cProtocolo)
			EndIf
					
			SF2->( MsUnlock() )
				//-- Livros Fiscais
			SF3->(dbSetOrder(5))
			If ( SF3->(MsSeek(xFilial("SF3")+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)) )
						
				If ( SF3->(FieldPos("F3_CODRSEF")) > 0 )
							
					SF3->( RecLock("SF3") )
							
					If SF3->(FieldPos("F3_CODRET")) > 0 .And. SF3->(FieldPos("F3_DESCRET")) > 0
						If Len( aMsg ) > 0 .And. !Empty( aMsg[1][1] )
							SF3->F3_CODRET	:= aMsg[1][1]
							SF3->F3_DESCRET	:= aMsg[1][2]
						Endif
					EndIf
							
					If ( !Empty(cNota) ) .And. !Empty(RTrim(cProtocolo))
						SF3->F3_CODRSEF 	:= "S" //NF Autorizada, 'BR_GREEN'
						SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
						SF3->F3_EMINFE	:= dEmiNfe
						SF3->F3_HORNFE	:= cHorNFe
						SF3->F3_CODNFE	:= RTrim(cProtocolo)
					EndIf
							
					SF3->(MsUnlock())
				EndIf
			EndIf
				//-- Financeiro - Contas a Receber
			SE1->(dbSetOrder(2))
			If ( SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC)) )
						
				If ( Alltrim(SF3->F3_CODRSEF) == "S" )
					If ( !empty(cNota) )
								
						While SE1->(!eof()) .And. xFilial("SE1") == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC .Or.  ( SE1->(!eof()) .And. SE1->E1_FILORIG == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC )
									
							SE1->( RecLock("SE1") )
							SE1->E1_NFELETR := iif( lRetNumRps, cNota ,RIGHT(cNota,nTamDoc) )
							SE1->(MsUnlock())

							Iif(FindFunction("JAjusNfe"), JAjusNfe(SE1->(Recno()), SE1->E1_NFELETR), Nil)
							SE1->( dbSkip() )
						EndDo
								
					EndIf
				EndIf
						
			ElseIf 	( SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)) )
					//-- 						
				If ( Alltrim(SF3->F3_CODRSEF) == "S" )
					If ( !empty(cNota) )
								
						While SE1->(!eof()) .And. xFilial("SE1") == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DOC .Or. ( SE1->(!eof()) .And. SE1->E1_FILORIG == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DOC )
									
							SE1->( RecLock("SE1") )
							SE1->E1_NFELETR := iif( lRetNumRps, cNota ,RIGHT(cNota,nTamDoc) )
							SE1->( MsUnlock() )

							Iif(FindFunction("JAjusNfe"), JAjusNfe(SE1->(Recno()), SE1->E1_NFELETR), Nil)
							SE1->( dbSkip() )
						EndDo
								
					EndIf
				EndIf
			else
				NS7->( dbsetOrder(4) )
				if( NS7->( MsSeek( xFilial("NS7") + SF2->F2_FILIAL) ) )										
					cAlias := getNextAlias()
					beginSQL ALIAS cAlias
						SELECT NXA_CESCR, NXA_COD 	UFFILIAL
						FROM %Table:NXA% NXA
						WHERE NXA_FILIAL = %EXP:xFilial("NXA")% 
						AND NXA_DOC = %EXP: SF2->F2_DOC%
						AND NXA_SERIE =%EXP: SF2->F2_SERIE% 
						AND NXA_CESCR = %EXP:NS7->NS7_COD%
						AND %NOTDEL%
					EndSql

					if( (cAlias)->( !eof() ) )
						NXA->(dbSetOrder(1))
						NXA->( MsSeek( xFilial("NXA") + (cAlias)->NXA_CESCR + (cAlias)->UFFILIAL ) )
						SE1->( dbSetOrder(25) )
						if( SE1->( MsSeek( xFilial("SE1") + xFilial( 'NXA' ) + '-' + NXA->NXA_CESCR + '-' + NXA->NXA_COD + '-' + SF2->F2_FILIAL ) ) )											
							While SE1->(!Eof()) .And. alltrim(SE1->E1_JURFAT) == alltrim( xFilial( 'NXA' ) + '-' + NXA->NXA_CESCR + '-' + NXA->NXA_COD + '-' + SF2->F2_FILIAL)
								RecLock("SE1",.F.)
								SE1->E1_NFELETR := SF2->F2_NFELETR
								SE1->( MsUnlock() )

								Iif(FindFunction("JAjusNfe"), JAjusNfe(SE1->(Recno()), SE1->E1_NFELETR), Nil)
								SE1->( dbSkip() )
							Enddo
						endif		
					endif
					(cAlias)->( dbCloseArea() )
				endif
			EndIf

			//-- Financeiro - Contas a Pagar - Quando ISS for recolhido pelo prestador
			SE2->( dbSetOrder(1) )
			If (SE2->(MsSeek(xFilial("SF2")+SF2->F2_SERIE+SF2->F2_DOC)) )
				If ( Alltrim(SF3->F3_CODRSEF) == "S" ) .and. ( !Empty( cNota ) )
					While SE2->(!EOF()) .And. xFilial("SE1") == SF2->F2_FILIAL .AND. SE2->E2_PREFIXO == SF2->F2_SERIE .And. SE2->E2_NUM == SF2->F2_DOC

						SE2->( RecLock("SE2") )
						SE2->E2_NFELETR := RIGHT(cNota,nTamDoc)
						SE2->( MsUnlock() )
						SE2->( dbSkip() )

					EndDo
				EndIf
			EndIf

				//-- Livros Fiscais - Resumo
			SFT->(dbSetOrder(1))
			If ( SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)) )
						
				If ( Alltrim(SF3->F3_CODRSEF) == "S" )
							
					If ( !Empty(cNota) )
								
						While SFT->(!eof()) .And. xFilial("SFT") == SF2->F2_FILIAL .And. SFT->FT_TIPOMOV == "S" .And. SFT->FT_SERIE == SF2->F2_SERIE .And. SFT->FT_NFISCAL == SF2->F2_DOC .And. SFT->FT_CLIEFOR == SF2->F2_CLIENTE .And. SFT->FT_LOJA == SF2->F2_LOJA
							SFT->( RecLock("SFT") )
							SFT->FT_NFELETR	:= RIGHT(cNota,nTamDoc)
							SFT->FT_EMINFE	:= dEmiNfe
							SFT->FT_HORNFE	:= cHorNFe
							SFT->FT_CODNFE	:= RTrim(cProtocolo)
							SFT->( MsUnlock() )
									
							SFT->( dbSkip() )
						EndDo
								
					EndIf
				EndIf
			EndIf
				//-- NFST-e (SIGATMS)
			If IntTms()
				DT6->(DbSetOrder(1))
				If DT6->(DbSeek(xFilial("DT6")+SF2->F2_FILIAL+ SF2->F2_DOC+SF2->F2_SERIE))
					If ( Alltrim(SF3->F3_CODRSEF) == "S" )
						If ( !Empty(cNota) )
							While DT6->(!eof()) .And. DT6->DT6_SERIE == SF2->F2_SERIE .And. DT6->DT6_DOC == SF2->F2_DOC .And. DT6->DT6_CLIDEV == SF2->F2_CLIENTE .And. DT6->DT6_LOJDEV == SF2->F2_LOJA
										
								DT6->( RecLock("DT6") )
								DT6->DT6_NFELET := RIGHT(cNota,nTamDoc)
								DT6->DT6_EMINFE := dEmiNfe
								DT6->DT6_CODNFE := RTrim(cProtocolo)
								DT6->( MsUnlock() )
										
								//-- Executa integração do Datasul
								If FindFunction("TMSAE76")
									TMSAE76()
								EndIf	
								DT6->(dbSkip())
										
							EndDo
						EndIf
					EndIf
				EndIf
			EndIf
					
		Else
				//-- Livros Fiscais
			dbSelectArea("SF3")
			SF3->( dbSetOrder(5) )
			If SF3->( MsSeek( xFilial("SF3") + cSerie + cNumero ) )
				If SF3->( FieldPos("F3_CODRSEF") ) > 0
					SF3->( RecLock("SF3") )
					SF3->F3_CODRSEF := "S"
							
					If SF3->(FieldPos("F3_CODRET")) > 0 .And. SF3->(FieldPos("F3_DESCRET")) > 0
						If Len( aMsg ) > 0 .And. !Empty( aMsg[1][1] )
							SF3->F3_CODRET	:= aMsg[1][1]
							SF3->F3_DESCRET	:= aMsg[1][2]
						Endif
					EndIf
							
					If !Empty(cNota) .And. !Empty(cProtocolo)
						SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
						SF3->F3_EMINFE	:= dEmiNfe
						SF3->F3_HORNFE	:= cHorNFe
						SF3->F3_CODNFE	:= RTrim(cProtocolo)
						SF3->F3_CODRSEF 	:= "S" //NF Autorizada, 'BR_GREEN'
					EndIf
							
					SF3->( MsUnlock() )
				EndIf
			EndIf

			SFT->(dbSetOrder(1))
			If ( SFT->(MsSeek(xFilial("SFT")+"S"+cSerie+cNumero)) )
						
				If ( Alltrim(SF3->F3_CODRSEF) == "S" )
							
					If ( !Empty(cNota) )
								
						While SFT->(!eof()) .And. xFilial("SFT") == SF3->F3_FILIAL .And. SFT->FT_TIPOMOV == "S" .And. SFT->FT_SERIE == SF3->F3_SERIE .And. SFT->FT_NFISCAL == SF3->F3_NFISCAL .And. SFT->FT_CLIEFOR == SF3->F3_CLIEFOR .And. SFT->FT_LOJA == SF3->F3_LOJA
							SFT->( RecLock("SFT") )
							SFT->FT_NFELETR	:= RIGHT(cNota,nTamDoc)
							SFT->FT_EMINFE	:= dEmiNfe
							SFT->FT_HORNFE	:= cHorNFe
							SFT->FT_CODNFE	:= RTrim(cProtocolo)
							SFT->( MsUnlock() )
									
							SFT->( dbSkip() )
						EndDo
								
					EndIf
				EndIf
			EndIf	
				//-- WS
			If !lUsaColab
				lRetMonit := GetMonitRx(cIdEnt,cUrl)
			EndIf
		EndIf
			
	elseif lRegFin
					
		SE2->(dbSetOrder(1))
					
		If ( SE2->(DbSeek(xFilial("SE2")+(cSerie+cNumero))) ) .And. SE2->( FieldPos("E2_FIMP") ) > 0 .And. SE2->( FieldPos("E2_NFELETR") ) > 0
						
			While SE2->(!eof()) .And. xFilial("SE2") == SE2->E2_FILIAL .And. ( PADR(cNumero,LEN(SE2->E2_NUM)) == SE2->E2_NUM) .And. ( cSerie == SE2->E2_PREFIXO )
							
				If cCnpjForn == Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC") .And. ;
						aScan(aMVTitNFT,{|x| x[1]==SE2->E2_TIPO}) > 0 .And. SE2->E2_FIMP <> "S"
														
					RecLock("SE2")
					SE2->E2_FIMP := "S" //NF Autorizada, 'BR_GREEN'
					SE2->E2_NFELETR := cNota
					SE2->(MsUnlock())
								
				EndIf
						
				SE2->(dbSkip())
						
			EndDo
								 	
		EndIf
				
	Else
			//-- NFS-e
		SF1->(dbSetOrder(1))
		If ( SF1->(MsSeek(xFilial("SF1")+(PADR(cNumero,LEN(SF1->F1_DOC))+cSerie),.T.)) )
					
			While SF1->(!eof()) .And. xFilial("SF1") == SF1->F1_FILIAL .And. ( PADR(cNumero,LEN(SF1->F1_DOC)) == SF1->F1_DOC) .And. ( cSerie == SF1->F1_SERIE )
						
				If cCnpjForn == Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_CGC")
							
					SF1->( recLock( "SF1",.F. ) )	
					If ( !Empty(cNota) ) .And. !Empty(RTrim(cProtocolo))						
						SF1->F1_NFELETR	:= RIGHT(cNota,nTamDoc)
						SF1->F1_EMINFE	:= dEmiNfe
						SF1->F1_HORNFE	:= cHorNFe
						SF1->F1_CODNFE	:= RTrim(cProtocolo)						
						SF1->F1_FIMP 		:= "S" //NF Autorizada, 'BR_GREEN'
					EndIf

							
					SF1->( MsUnlock() )
						//-- Livros Fiscais
					SF3->( dbSetOrder(5) )
					If ( SF3->(MsSeek(xFilial("SF3")+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA)) )
								
						If ( SF3->(FieldPos("F3_CODRSEF")) > 0 )
									
								SF3->( RecLock("SF3") )
									
							If ( !Empty( cNota ) ) .And. !Empty(RTrim(cProtocolo))

								SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
								SF3->F3_EMINFE	:= dEmiNfe
								SF3->F3_HORNFE	:= cHorNFe
								SF3->F3_CODNFE	:= RTrim(cProtocolo)					
								SF3->F3_CODRSEF 	:= "S" //NF Autorizada, 'BR_GREEN'
							EndIf
									
							SF3->(MsUnlock())
									
						EndIf
					EndIf
						//-- Financeiro - Contas a Pagar
					SE2->( dbSetOrder(2) )
					If ( SE2->(MsSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC)) )
								
						If ( Alltrim(SF3->F3_CODRSEF) == "S" )
							If ( !Empty( cNota ) )
										
								While SE2->(!EOF()) .And. xFilial("SE1") == SF2->F2_FILIAL .And. SE2->E2_CLIENTE == SF1->F1_FORNECE .And. SE2->E2_LOJA == SF1->F1_LOJA .And. SE2->E2_PREFIXO == SF1->F1_SERIE .And. SE2->E2_NUM == SF1->F1_DOC
											
									SE2->( RecLock("SE2") )
									SE2->E2_NFELETR := RIGHT(cNota,nTamDoc)
									SE2->( MsUnlock() )
											
									SE2->( dbSkip() )
								EndDo
										
							EndIf
						EndIf
								
					EndIf
						//-- Livros Fiscais - Resumo
					SFT->( dbSetOrder(1) )
					If ( SFT->(MsSeek(xFilial("SFT")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA)) )
								
						If ( Alltrim(SF3->F3_CODRSEF) == "S" )
							If ( !Empty( cNota ) )
										
								While SFT->(!EOF()) .And. xFilial("SFT") == SF1->F1_FILIAL .And. SFT->FT_TIPOMOV == "E" .And. SFT->FT_SERIE == SF1->F1_SERIE .And. SFT->FT_NFISCAL == SF1->F1_DOC .And. SFT->FT_CLIEFOR == SF1->F1_FORNECE .And. SFT->FT_LOJA == SF1->F1_LOJA
											
									SFT->( RecLock("SFT") )
									SFT->FT_NFELETR	:= RIGHT(cNota,nTamDoc)
									SFT->FT_EMINFE	:= dEmiNfe
									SFT->FT_HORNFE	:= cHorNFe
									SFT->FT_CODNFE	:= RTrim(cProtocolo)
									SFT->( MsUnlock() )
											
									SFT->(dbSkip())
								EndDo
										
							EndIf
						EndIf
					EndIf
				EndIf
				SF1->(dbSkip())
			EndDo
		EndIf
	EndIf
			
	//atualização da tabela de AIDF
	if aliasIndic("C0P")
		SF3->(dbSetOrder(5))
	   If SF3->(MsSeek(xFilial("SF3") + cSerie + cNumero))
		
			C0P->(dbSetOrder(1))
			If (cCodMun == "3524006" .Or. cCodMun == "3505906") .and. !C0P->(dbSeek(xFilial() +  padr(cValToChar(Val(SF3->F3_NFISCAL)), TamSX3("C0P_RPS")[1] ) ) )
				cNotaArq := "0"
			Else
				cNotaArq := cValToChar(Val(SF3->F3_NFISCAL))
			EndIf
			If C0P->(dbSeek(xFilial() +  Padr(cNotaArq, TamSX3("C0P_RPS")[1]))) .And. Empty(C0P->C0P_AUT)
				reclock("C0P",.F.)
				C0P->C0P_AUT := "S"
				If cCodMun == "3524006" .Or. cCodMun == "3505906"
					C0P->C0P_RPS := Val(SF3->F3_NFISCAL)
				EndIf
				C0P->(msunlock())
			EndIf

		EndIf
	endif


Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} FisRetDataHora
Funcao que retorna Data e Hora do XML

@author Sergio S. Fuzinaka
@since 20.12.2012
@version 1.0      
/*/
//-----------------------------------------------------------------------
Static Function FisRetDataHora( oXml, cMod004 )

Local aRetorno		:= {}
Local aDados		:= {}
local aRet			:= {}
Local cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )

Local cRecXml		:= ""
Local cRethora		:= ""
Local cRetdata		:= ""
Local dDataConv		:= CTOD( "" )
Local cCID			:= "" 

Private oWS			:= NIL

If Type( "oXml" ) <> "U"
	oWS := oXml
Endif
   		
If Type( "oWS:cID" ) <> "U" .And. !Empty( Alltrim( oWS:cID ) )

	cCID := Alltrim( oWS:cID )

	If ( IsTSSModeloUnico() .And. Type( "oWS:XMLRETTSS" ) <> "U" .And. !Empty( oWS:XMLRETTSS ) )
		
		AADD( aDados, RetornaMonitor( cCID, oWS:XMLRETTSS ) )
		
	elseif ( IsTSSModeloUnico() .And. Type( "oWS:CXMLRETTSS" ) <> "U" .And. !Empty( oWS:CXMLRETTSS ) .and. !(cCodMun $ "3554102-4304705-3530607-5008305-3301702-5201108-5103403-5003702-4104808-3300407-4316907-4306106-3502507-3551009-3524402-3509502-5101704-2408102-3543402-4319901-4208203-3522406-3534401-2918001-3552809-3205002-3506102-5007695-4200101-1502400-4203006-4204202-4301206") )//data hora mogi das cruzes Campinas

		aAdd( aDados, RetornaMonitor( cCID, oWS:CXMLRETTSS ) )
	Else
	
		cRetdata	:= ""
		cRethora	:= ""
		dDataconv 	:= CTOD( "" )

		//---------------------------------------------------------------------------
		// Tratamento realizado Protheus e TSS, para retornar somente a data e hora
		// nao havendo necessidade de ler o xml do lote inteiro.
		//---------------------------------------------------------------------------
		if ( type("oXml:cDATAHORA") <> "U" )
			if ( len(oXml:cDATAHORA) == 19 )
				cRetData := substr(oXml:cDATAHORA,1,10)
				cRetHora := substr(oXml:cDATAHORA,12,8)
				cRetData := CTOD(SubStr(cRetData,9,2) + "/" + SubStr(cRetData,6,2)  + "/" + SubStr(cRetData,1,4))
				aAdd( aRet, cRetData )
				aAdd( aRet, cRetHora )
				//Os Ifs que estavam aqui estavam em duplicidade com a função retDataXMLNfse() mais a baixo
				If ( cCodMun $ "3524006-5007695" ) //DSERTSS2-8389 - Tratamento Itupeva (3524006)
					aRet := {}
				EndIf

			EndIf	
		endif

		if ( len(aRet) == 0 )
			if ( (cCodMun $ "3550308|2611606|4202404|4209102|3505708|3530607|3304904") .And. ( cEntSai == "1" ) )  //SAO PAULO, RECIFE, BLUMENAU, JOINVILLE e BARUERI.
				if Type( "oWS:OWSNFE:CXMLERP" ) <> "U" .And. !Empty( oWS:OWSNFE:CXMLERP )
					cRecxml		:= oWS:OWSNFE:CXMLERP			
				endif
			elseif (cCodMun $ "3304557-3200607-3200300-3305000-3554102-3167202-4320800-4104808-4214805-4208203-3162955-3136702-3526803-4123501-3524006-4205803-5007695-4200101-4309308-4301206" + Fisa022Cod("023"))  .And. ( Type("oWS:OWSNFE:CXMLPROT") <> "U" .And. !Empty( oWS:OWSNFE:CXMLPROT ) ) //DSERTSS2-8389 - Tratamento Itupeva (3524006)
				If cCodMun $ "3162955" // São José da Lapa - MG
					If Type( "oWS:OWSNFECANCELADA:CXMLPROT" ) <> "U" .And. !Empty( oWS:OWSNFECANCELADA:CXMLPROT ) // Quando existe XML com Data e Hora de CANCELAMENTO.
						cRecxml := oWS:OWSNFECANCELADA:CXMLPROT
					Else
						cRecxml := oWS:OWSNFE:CXMLPROT
					EndIf 
				Else	
					cRecxml := oWS:OWSNFE:CXMLPROT
				EndIf
			else
				If Type( "oWS:OWSNFE:CXML" ) <> "U" .And. !Empty( oWS:OWSNFE:CXML )
					cRecxml		:= oWS:OWSNFE:CXML			
				endif
			endif		
			
			aRet := retDataXMLNfse(cRecxml,cCodMun)		

			if ( ( ( cCodMun $ "3550308-4202404-4311205-3304904" ) .And. ( cEntSai == "1" ) ) .or.  GetMunSiaf(cCodMun)[1][2] $ "004-006-009"  )  //SAO PAULO E RECIFE E BLUMENAU
				aRet[2] := "00:00:00"
			Elseif GetMunSiaf(cCodMun)[1][2] $ "011" .Or. cCodMun $ "4308201-4313300-3505906-3530607" //DSERTSS2-8581 retirado o código 3524006 - Itupeva/SP
				If !(cCodMun $ "4104808-4214805-4123501-4205803-4309308-4301206") 
					aRet[1] := ddatabase
					aRet[2] := "00:00:00"
				endif
			Elseif (cCodMun $ "3205309-3526902-3530805")
				aRet[2] := "00:00:00"
			elseIf( empty( aRet[ 2 ] ) )		
				aRet[ 2 ] := "00:00:00"
				If( empty( aRet[ 1 ] ) ) // Validação realizada para NFSE Arquivo.Txt.
					aRet[ 1 ] := ddatabase
				EndIf
			endif
		endif
		
		// caso embu das artes ou se nao se enquadrou em nenhum antes e array esta vazia 
		If empty(aRet[1])
			cRetData := DATE()
			cRetHora := "00:00:00"
			aAdd( aRet, cRetData )
			aAdd( aRet, cRetHora )
		endif

		AADD( aDados, { cCID, aRet[1], aRet[2], "" } )
	
	EndIf	

Endif

aRetorno 	:= {}

If Len( aDados ) > 0

	AADD( aRetorno, aDados[ 1, 2 ] )
	AADD( aRetorno, aDados[ 1, 3 ] )

Endif

Return( aRetorno )

//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt2NFSeMnt
Funcao que exibe o historico da NFS-e

@author
@since
@version
/*/
//-----------------------------------------------------------------------
Static Function Bt2NFSeMnt(aMsg,lUsaColab)

Local aSize    := MsAdvSize()
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1
Default lUsaColab	:= UsaColaboracao("3")

If !Empty(aMsg) .And. !lUsaColab
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE "NFS-e" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "Cod Erro", "Mensagem"; 
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aMsg )
	oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,2 ]} }
	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114 ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011 //"Ok"
	ACTIVATE MSDIALOG oDlg
EndIf
If !Empty(aMsg) .And. lUsaColab	 // Somente para Totvs Colaboração 2.0
	//aSort(aMsg,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4]))+x[5] > if(Empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oDlg TITLE STR0261 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //NFS-e
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "Cod Erro","Recibo SEF","Mensagem","Cod.Env.Lote","Dt.Lote","Hr.Lote","Msg.Env.Lote","Nome Arquivo","Lote"; 
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
	oListBox:SetArray( aMsg )
	oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,6 ],aMsg[ oListBox:nAT,2 ],aMsg[ oListBox:nAT,3 ],aMsg[ oListBox:nAT,4 ],aMsg[ oListBox:nAT,5 ],aMsg[ oListBox:nAT,7 ],aMsg[ oListBox:nAT,8 ],aMsg[ oListBox:nAT,9 ]} }
	@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT STR0114 ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011 //"Ok"
	ACTIVATE MSDIALOG oDlg
EndIf
Return(.T.)


Static Function GENLoadTXT(cFileImp)
Local cTexto     := ""
Local cNewFile   := ""
Local cExt       := "" 
//Local cRootPath  := GetSrvProfString("RootPath","")
Local cStartPath := GetSrvProfString("StartPath","")
Local nHandle    := 0
Local nTamanho   := 0
Local cDrive     := ""
Local cPath		 :=	""
Local lCopied	 :=	.F.                     


cStartPath := StrTran(cStartPath,"/","\")
cStartPath +=If(Right(cStartPath,1)=="\","","\")

cFileOrig:= Alltrim(cFileImp)
If Substr(cFileImp,1,1) == "\"
//	cFileImp := AllTrim(cRootPath)+Alltrim(cFileImp)
EndIf    

SplitPath(cFileOrig,@cDrive,@cPath, @cNewFile,@cExt)

cNewFile	:=	cNewFile+cExt
If Empty(cDrive)
	lCopied := __CopyFile(cFileImp, cStartPath+cNewFile) 
Else
	If !IsSrvUnix()
		lCopied := CpyT2S(cFileImp,cStartPath)
	Else
		lCopied:= .T.
	EndIf
EndIf		

If lCopied
	nHandle 	:= 	IIF(IsSrvUnix(),FOpen(cFileImp),FOpen(cNewFile))
	If nHandle > 0
		nTamanho := Fseek(nHandle,0,FS_END)
		FSeek(nHandle,0,FS_SET)
		FRead(nHandle,@cTexto,nTamanho)
		FClose(nHandle)
		FErase(cNewFile)
	Else
	   	cAviso := "Falha ao tentar obter acesso ao arquivo "+cNewFile
	   	Aviso(STR0261,cAviso,{"OK"},3) //NFS-e
	EndIf

Else                                         
   	cAviso := "Falha ao tentar copiar o arquivo "+cNewFile +CRLF
   	cAviso += "para o diretorio raiz do Protheus."
  	Aviso(STR0261,cAviso,{"OK"},3)	//NFS-e
EndIf	

If lCopied
	FErase(cNewFile)
EndIf

Return(cTexto)





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetIdEnt(cError)

Local cIdEnt 	  := ""
Local lUsaColab := UsaColaboracao("3")
Default cError  := ""

IF lUsaColab
	if !( ColCheckUpd() )
		Aviso("SPED",STR0235,{STR0114},3)  //UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 3.0
	else
		cIdEnt := "000000"
	endif
Else
		if isConnTSS(@cError) // Verifica a conexão do TSS antes de iniciar o processo de validação da entidade
			cIdEnt := getCfgEntidade(@cError)
		endif
//		cIdEnt := getCfgEntidade(@cError)
//		If !Empty(cError)
//			Aviso("NFS-e",cError,{STR0114},3)
//		EndIf
EndIF

Return(cIdEnt)


Function Fisa022Cod(cCodServ, lUsaColab)

Local cRet      := ""
Local cURL      := ""
Local cIdEnt    := ""
Local oWs
default lUsaColab	 := UsaColaboracao("3")
default cCodServ	 := ""

//-- Retorna os Municipios  homologados no TSS de um determinado serviço de NFS-e (Função: RetMunServ -> Fonte: NFSe_Gen01.PRX)
If lUsaColab
	cRet := ""
Else
	cURL := Padr( GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250 )

	If !Empty(cURL) .And. isConnTSS()
		cIdEnt:= GetIdEnt()
	EndIf

	If !Empty(cIdEnt) .And. !Empty(cCodServ) .And. isConnTSS()
			oWS:= WsNFSE001():New()
			oWs:cUSERTOKEN   := "TOTVS"
			oWs:cID_ENT      := cIdEnt
			oWs:cCSERVICO    := cCodServ
			oWS:_URL         := AllTrim(cURL)+"/NFSE001.apw"
		
			If ExecWSRet(oWs,"RETMUNSERV")
				cRet := oWs:CRETMUNSERVRESULT
			Else
				cRet := ""
		EndIf
	EndIf
	FreeObj(oWS)
	oWS := nil
	delClassIntF()
EndIf

Return cRet


             
Static Function SetParams(cIdEnt, cUrl, cCodMun, cAmbienteNFSe, cModNFSE, cVersaoNFSe, cCodSIAFI, cCnpJAut, cUsuario, cSenha, nGrava,cAEDFe,cModelo,cChaveAut,cClientID,cSecretID,cFtpT)
	
	Local lRet       	:= .T.
	Local oWs        	:= Nil     
	Local oWS2		 	:= Nil
	Local lOk        	:= .F.
	Local cMetodServ	:= GetNewPar("MV_ENVSINC","N")
	Local cMaxLote		:= GetNewPar("MV_MAXLOTE","1")//Por padrão, o sistema utiliza 1 para MV_MAXLOTE no TSS
	
	Default cUsuario	:= ""
	Default cSenha		:= ""  
	
	Default nGrava		:= 2
	Default cAEDFe		:= ""
	Default cModelo		:= "0"
	// Tratamento para Osasco - SP
	Default cChaveAut		:= ""
	Default cVersaoNFSe	:= "1   "
	Default cClientID := ""
	Default cSecretID := ""
	
	oWS                       := WsNFSE001():New()
	oWS:cUSERTOKEN            := "TOTVS"
	oWS:cID_ENT               := cIdEnt
	oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
	oWS:cCODMUN               := cCodMun
	oWS:nAmbienteNFSe         := Val(Substr(cAmbienteNFSe,1,1))
	oWS:nModNFSE	            := Val(cModNFSE)
	oWS:cVersaoNFSe           := cVersaoNFSe
	oWS:cCodMun               := cCodMun
	oWS:cCodSIAFI             := cCodSIAFI
	oWS:cUso                  := "NFSE"
	oWS:cMaxLote              := cMaxLote
	oWS:cEnvSinc              := cMetodServ
		
	If cCodMun $ Fisa022Cod("013") .Or. (cCodMun $ Fisa022Cod("202") .And. cCodMun $ GetMunNFT())	//NFTS e NFSE E-Transparencia - Petrópolis/RJ (NFTS) / Limeira/SP (NFSE)
		oWS:cLogin 				:= AllTrim(cUsuario)				//Código de usuário
		oWS:cChaveAutenticacao 	:= Alltrim(cChaveAut)			//Código de contribuinte
	ElseIf ( cCodMun $ "4321634-2925303-3118601-3503307-3538709-3300704-1400100-3156700-4303905-3302403-2803500-3148103-3146107-4308201-3304508-3541406-2301000-3305505-2301109-4313300-2700300-4102307-3524907-3200607-3302601-3200300-3510807-3551702-2909307-2928901-4202008-3305000-5213103-3505500-3306305-3510609-3555000-3549102-3205069-2932903-3117876-3300605-1100023-3545308-3511102" .Or. cModelo $ "004-011-016") .And. cVerTSS >= "1.33" // Osasco - Campo Bom-RS - Farroupilha-RS e SIMPLISS
		oWS:cLogin := AllTrim(cUsuario)
		oWS:cPass  := AllTrim(cSenha)
	ElseIf cCodMun == "2111300"    
		oWS:cAutorizacao := Alltrim(cAEDFe)
	//Tratamento para Osasco - SP
	ElseIf cCodMun $ "3534401-3526803"+Fisa022Cod("009")+Fisa022Cod("010")+Fisa022Cod("015")
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)		
	ElseIf cCodMun $ "4113700-4315602-4317202-4201307-4105805-4118204-4104204" 
		oWS:cLogin := AllTrim(cUsuario)
		oWS:cPass  := AllTrim(cSenha)		
		If !cCodMun $ "4317202-4201307-4105805-4118204-4104204"
			oWS:cAutorizacao := Alltrim(cAEDFe)
		EndIf	
	ElseIf cCodMun $ Fisa022Cod("012") .Or. cCodMun $ "3171204"
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)
	 	oWS:cLogin := AllTrim(cUsuario)
		oWS:cPass  := AllTrim(cSenha)
		oWS:cAutorizacao := Alltrim(cAEDFe)
	ElseIf cCodMun $ Fisa022Cod("014") .or. cCodMun $ "3144805-3157807-3515004-3129806-3131901-4314407"
		oWS:cLogin := AllTrim(cUsuario)
		oWS:cPass  := AllTrim(cSenha)
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)
	Elseif cCodMun $ Fisa022Cod("006") + "3203205-2921005-3117504-1702109-2800308-5006606-4215802-2706901-3502903-3504008-3548005-1505437-3517406-5007695-1502152-1100122-3513504-2207702"
		oWS:cPass  := AllTrim(cSenha)
		oWS:cLogin := AllTrim(cUsuario)
	ElseIf cCodMun $ Fisa022Cod( "017" )
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )
		oWS:cAutorizacao := alltrim( cChaveAut )
		oWS:cClientID := alltrim( cClientID )
		oWS:cClientSecret := alltrim( cSecretID )
		oWS:cChaveAutenticacao := alltrim( cAEDFe )
	ElseIf cCodMun $ Fisa022Cod( "018" )
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )
		oWS:cAutorizacao := alltrim( cChaveAut )
	ElseIf cCodMun $ Fisa022Cod("005") .or. cCodMun $ Fisa022Cod("019") + "-5206206-3507506" //GO - Cristalina
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )
		oWS:cChaveAutenticacao := alltrim( cChaveAut )
	ElseIf cCodMun $ "4304408" .or. cCodMun $ Fisa022Cod("020") .or. cCodMun $ Fisa022Cod("022") + "-4125506" // RS - Canela - Fisa022Cod( "002" ) FGMAISS + São José de Ribamar
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )
	ElseIf cCodMun $ "4101507-4303509-2903201-2307700-2917508" + Fisa022Cod( "027" ) + Fisa022Cod( "028" ) + fisa022Cod( "030" )// PR - Arapongas
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )	
	ElseIf cCodMun $ "3526902-3109303" // Limeira - SP //Radu + 3109303 Buritis/MG
		oWS:cChaveAutenticacao := Alltrim(cChaveAut) // Token prefeitura	
	ElseIf cCodMun $ Fisa022Cod( "023" ) // Sorriso - MT
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)
	ElseIf cCodMun $ Fisa022Cod( "024" ) + Fisa022Cod("029")  // Jales - SP - RLZ - Rdencao PA - Prefeitura Moderna 
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)
	ElseIf( cCodMun $ fisa022Cod( "025" ) )
		oWS:cLogin := allTrim( cUsuario )
		oWS:cPass  := allTrim( cSenha )
		oWS:cChaveAutenticacao := Alltrim(cChaveAut)	
	EndIf

	If cVerTss >= "1.22"
		cCnpJAut := StrTran(cCnpJAut,".","")
		cCnpJAut := StrTran(cCnpJAut,"/","")
		cCnpJAut := StrTran(cCnpJAut,"-","")						
		oWS:nCNPJAut := Val(cCnpJAut)
	EndIf
	
	lOk := oWS:CFGambNFSE001()
	
	If lOk 
		oRetorno := oWS:cCFGambNFSE001RESULT
		Aviso("NFS-e",Capital(oRetorno),{STR0114},3)

		//Atualiza a variável global para alterar o ambiente no Browser
		cAmbiente := GetAmbNfse( cIdEnt, .T. )

		//Executo o refresh do Browser para atualizar o ambiente
		If Type( "_oObj" ) <> "U"
			AtuBrowse()
	    EndIf
	Else
    	cMsg :=(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
		Aviso(STR0261,cMsg,{STR0114},3)		
    EndIf

	if ( cCodMun $ Fisa022Cod( "101" ) .or. cCodMun $ Fisa022Cod( "102" ) .or. ( cCodMun $ GetMunNFT() .And. cEntSai == "0"  ) .And. !(cCodMun $ Fisa022Cod("201") .Or. cCodMun $ Fisa022Cod("202")) )
	
		oWs2 := WsSpedCfgNFe():New()
		oWs2:cUSERTOKEN      := "TOTVS"
		oWS2:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"	
		oWS2:lftpEnable      := if(nGrava==2,.F.,.T.)
		oWs2:ctssftpmetodo 	 := cFtpT
		If !Empty(cFtpT) // grava parametro MV_TSSFTPM com o que foi colocado no Wizard 
			PutMV("MV_TSSFTPM",cFtpT)
		Endif 
		
		
		if !( execWSRet( oWS2 ,"tssCfgFTP" ) )
	    	cMsg := (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
			Aviso(STR0261,cMsg,{STR0114},3)		
		endif
		
	endif           
 	FreeObj(oWS)
	FreeObj(oWS2)
	oWS  := nil
	oWS2 := nil
	delClassIntF()

Return(lRet)

//Funcao para retornar o Codigo SIAFI a partir do Cod IBGE
//Substituir futuramente por consulta na tabela CC2
Function GetMunSiaf(cCodMun)
Local aDados 		:= {}
Local cVersaoNFSe:= ""
Local cSiafi 		:= ""
Local cCodServ	:= ""
Local  lOk			:= .F.
	                     
Local oWsCfg		:= Nil
Local oWsNFSe		:= Nil
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
DEFAULT cCodMun	:= SM0->M0_CODMUN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     ATENCAO: A PARTIR DE 16/12/2014, OS CODIGOS NOVS DEVEM SER ADICIONADOS      ³
	//³     NO METODO GetMunSiaf DO WEBSERVICE NFS0001 DO TSS. NAO INCLUIR NOVOS        ³
	//³     CODIGOS NESTA LISTA                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If isConnTSS()
	cIdEnt := GetIdEnt()
	lOk := IsReady(cCodMun, cURL, 1)
	oWsCfg:= WsSpedCfgNFe():New()
	oWsCfg:cUSERTOKEN      := "TOTVS"
	oWsCfg:cID_ENT         := cIdEnt
	oWsCfg:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If	lOk
			oWsNFSe := WsNFSE001():New()
			oWsNFSe:cUSERTOKEN	:= "TOTVS"
			oWsNFSe:cID_ENT		:= cIdEnt
			oWsNFSe:cCodMun		:= Alltrim(cCodMun)
			oWsNFSe:_URL		:= AllTrim(cURL)+"/NFSE001.apw"
			If oWsNFSe:GetMunSiaf(oWsNFSe:cUSERTOKEN,Alltrim(cCodMun))
				cSiafi 		:= oWsNFSe:OWSGETMUNSIAFRESULT:CCODSIAF
				cCodServ		:= oWsNFSe:OWSGETMUNSIAFRESULT:CCODSERV
			EndIf
	   	EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³         ATENCAO: USO DA LISTA VIA "FISA022" LIBERADO ATE 01/07/2015         ³
				//³         APOS ESTA DATA, FORCAR A ATUALIZACAO DO TSS PELO CLIENTE            ³
				//³                      LISTA SERA REMOVIDA DO FONTE FISA022                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Val(substr(getVersaoTSS(),1,2)) >= 12 .Or. getVersaoTSS() >= "2.66"
		cVersaoNFSe	:= getNfseVersao()
	Else
		cVersaoNFSe := space(4)
		MsgStop(STR0243) //"Ambiente TSS desatualizado. Contacte o suporte TOTVS para atualização"
	EndIf

EndIf
aadd(aDados,{cSiafi,cCodServ,cVersaoNFSe})
	FreeObj(oWsCfg)
	FreeObj(oWsNFSe)
	oWsCfg	:= Nil 
	oWsNFSe	:= Nil
	DelClassIntF()

Return(aDados)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |DetSchema ³ Autor ³ Roberto Souza         ³ Data ³11/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe detalhe de schema.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DetSchema(cIdEnt,cCodMun,cIdNFe,nTipo,lAutomato)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS
Local cMsg     := ""
Local aRetAuto := {}
DEFAULT nTipo  := 1
Default lAutomato := .F.

	oWS := WsNFSE001():New()
	oWS:cUSERTOKEN            := "TOTVS"
	oWS:cID_ENT               := cIdEnt
	oWS:cCodMun               := cCodMun
	oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
	oWS:nDIASPARAEXCLUSAO     := 0
    oWS:OWSNFSEID:OWSNOTAS    := NFSe001_ARRAYOFNFSESID1():New()
      
		aadd(oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1,NFSE001_NFSES1():New())
		oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CCODMUN  := cCodMun
		oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cID      := cIdNFe
		oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cXML     := " "
		oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CNFSECANCELADA := " "               

// Rotina automatizada
If lAutomato
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("AUTONFSETestCase")		
		Aadd(aRetAuto, "")
	EndIf
Endif

If ExecWSRet(oWS,"RETORNANFSE")

	If Len(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5) > 0
		If nTipo == 1
			Do Case
				Case oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA <> Nil
					If !lAutomato
						Aviso("NFSE",oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXML,{STR0114},3)
					Else
						MemoWrite(GetSrvProfString("RootPath","") + "\baseline\tssschema.xml", oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXML)
						aRetAuto := oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXML
					EndIf
				OtherWise
					If !lAutomato
						Aviso("NFSE",oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP,{STR0114},3)
					Else
						MemoWrite(GetSrvProfString("RootPath","") + "\baseline\tssschema.xml", oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP)
						aRetAuto := oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP
					EndIf
			EndCase
		Else
			If cCodMun $ "4319901-3550308-3306008" 
				cMsg := DecodeUtf8(AllTrim(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP))
			elseIf cCodMun $ "1600303" // quando xml tem acento agudo vem desencodado .. quando nao tem acento agodu vem encodado .. 
				If !(DecodeUtf8(AllTrim(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP)) == NIL) // checa se esta encodado ou nao
					cMsg := DecodeUtf8(AllTrim(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP))
				Else
					cMsg := AllTrim(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP)
				Endif 
			Else
				cMsg := AllTrim(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP)
			Endif 
			If !Empty(cMsg)
				If !lAutomato
					Aviso("NFSE",@cMsg,{STR0114},3,/*cCaption2*/,/*nRotAutDefault*/,/*cBitmap*/,.T.)
				Else
					MemoWrite(GetSrvProfString("RootPath","") + "\baseline\TSSSchema.xml", cMsg)		
				EndIf
				oWS := WsNFSE001():New()
				oWS:cUSERTOKEN     := "TOTVS"
				oWS:cID_ENT        := cIdEnt
				oWS:cCodMun        := cCodMun

				oWs:oWsNF:oWSNOTAS:=  NFSE001_ARRAYOFNF001():New()
				aadd(oWs:oWsNF:oWSNOTAS:OWSNF001,NFSE001_NF001():New())

				oWs:oWsNF:oWSNOTAS:oWSNF001[1]:CID := cIdNfe
				oWs:oWsNF:oWSNOTAS:oWSNF001[1]:Cxml:= EncodeUtf8(cMsg)
				oWS:_URL                             := AllTrim(cURL)+"/NFSE001.apw"
				If ExecWSRet(oWS,"SchemaX")
					If Empty(oWS:OWSSCHEMAXRESULT:OWSNFSES4[1]:cMENSAGEM)
						Aviso(STR0261,STR0091,{STR0114})
					Else
						Aviso(STR0261,IIF(Empty(oWS:OWSSCHEMAXRESULT:OWSNFSES4[1]:cMENSAGEM),STR0091,oWS:OWSSCHEMAXRESULT:OWSNFSES4[1]:cMENSAGEM),{STR0114},3)
					EndIf
				Else
					Aviso(STR0261,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	Aviso(STR0261,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
EndIf

	FreeObj(oWS)
	oWS := nil
	delClassIntF()

Return
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/14/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function Fisa022Canc(lAuto,cNotasOk,aParam,lSF3Canc)

Local aArea     	:= GetArea()
Local aPerg     	:= {}

Local cAlias    	:= "SF2"
Local cCodMun  	 	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cParTrans		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fisa022Canc",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fisa022Canc" )
Local cParNfseRem  	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "AUTONFSEREM",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "AUTONFSEREM" )
Local cForca   		:= ""            
Local cDEST			:= Space(10)
Local cWhen 		:= ".T."
Local cMensRet		:= ""   

Local lProcessa	:= .T. 
Local lObrig		:= .T.

Local nForca   		:= 1   
Local lUsaColab		:= UsaColaboracao("3")
Local oWs   		:= Nil //Objeto local oWs inciado como Nil
Local lFreObj       := .F. //Variável que irá validar se o objeto estará com conteúdo
Local cFTPT			:=  Alltrim(GetNewPar("MV_TSSFTPM","1"))

Default lAuto		:= .F.
Default cNotasOk	:= ""
Default aParam	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),"",1}
Default lSF3Canc	:= .T. // Verdadeiro se a NFS ja foi cancelada

//Geracao XML Arquivo Fisico
If lUsaColab .Or. (!cCodMun $ Fisa022Cod("201") .And. (cCodMun $ Fisa022Cod("101") .Or. cCodMun $ Fisa022Cod("102") .Or. (cCodMun $ GetMunNFT() .And. cEntSai == "0")))

	MV_PAR01 := ""
	MV_PAR02 := ""
	MV_PAR03 := ""
	MV_PAR04 := "" //Nome do arquivo
	MV_PAR05 := "" //Caminho a ser salvo .TXT

	If !lAuto
		MV_PAR01:=cSerie   	:= aParam[01] := PadR(ParamLoad(cParTrans,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
		MV_PAR02:=cNotaini 	:= aParam[02] := PadR(ParamLoad(cParTrans,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
		MV_PAR03:=cNotaFin 	:= aParam[03] := PadR(ParamLoad(cParTrans,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
	Else
		MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfseRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
		MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfseRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
		MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfseRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC))
	EndIf		

	If !lUsaColab
		If ( cCodMun == "3168705" )
			cWhen    := ".F."
			MV_PAR04 := cDEST := aParam[04] := ""
			lObrig   := .F.
		Else
			MV_PAR04:= cDEST := aParam[04] := PadR(ParamLoad(cParTrans,aPerg,4,aParam[04]),10)
		EndIf
	EndIf

	//Montagem das perguntas
	aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})			//"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})			//"Nota fiscal inicial"
	aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) 			//"Nota fiscal final" 
	If !lAuto 
		aadd(aPerg,{1,STR0237,aParam[04],"",".T.","",cWhen,40,lObrig})	//"Nome do arquivo XML Gerado"	
	EndIf 


	If !lUsaColab
		oWs := WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"	 
		oWS:lftpEnable      := nil
		oWS:ctssftpmetodo   := cFTPT
		
		lFreObj := .T. //Objeto oWs populado, lFreObj := .T.

		if ( execWSRet( oWS ,"tssCfgFTP" )  )
		
			if ( oWS:lTSSCFGFTPRESULT )
				aAdd(aPerg,{6,STR0238,padr('',100),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY}) //"Caminho do arquivo"
			endif
			
		endif		
	
		//Verifica se o serviço foi configurado - Somente o Adm pode configurar
		if !lAuto
			If !ParamBox(aPerg,STR0239,,,,,,,,cParTrans,.T.,.T.)  //"Transmissão NFS-e"    
				
				lProcessa := .F.
		
			EndIf
		endif
	EndIf
EndIf	

If ( lProcessa )
	Processa( {|| FisaCanc(cCodMun,cAlias,@cNotasOk,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,lAuto,MV_PAR05,lUsaColab,lSF3Canc,cFTPT )}, "Aguarde...","(1/2) Verificando dados...", .T. )
EndIf

If !lAuto
	If Empty(cNotasOk)
		If !(IsBlind())
			Aviso(STR0261,STR0240,{STR0114},3) //"NFS-e"-"Nenhuma Nota foi Cancelada."
		EndIf
	Else
		If !(IsBlind())
			Aviso(STR0261,STR0241 +CRLF+ cNotasOk,{STR0114},3)  //"NFS-e"-"Notas Canceladas:"
	EndIf
	EndIf
EndIf
If !lAuto
	RestArea(aArea)  
EndIF

If lFreObj //Executo o FreeObj se o objeto oWs estiver populado
	FreeObj(oWS)
	oWS := nil
	delClassIntF()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fis022MntC(lAuto)
Local aPerg     := {}
Local cCodMun   := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cParMnt   := if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "Fis022MntC",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "Fis022MntC" )
Local aParam    := {ctod("//"),ctod("//"),.F.}

aadd(aPerg,{1,STR0148,aParam[01],"99/99/99",".T.","",".T.",50,.T.}) //"DATA INICIAL"
aadd(aPerg,{1,STR0149,aParam[02],"99/99/99",".T.","",".T.",50,.T.}) //"DATA FINAL"

aParam[01] := ParamLoad(cParMnt,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParMnt,aPerg,2,aParam[02])

If ParamBox(aPerg,STR0242,@aParam,,,,,,,cParMnt,.T.,.T.)  //" Cancelamento NFS-e"
	Processa({ || Fis022MtC() },"Espere...","Processando Dados...")
EndIf  

Return()  
                                                                                                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fis022MtC()

Local cCadastro 	:= ""
Local cQuery 		:= ""
Local dDatIni  	:= Iif(Valtype(MV_PAR01) =="C",ctod(MV_PAR01),Dtos(MV_PAR01))
Local dDatFim  	:= Iif(Valtype(MV_PAR02) =="C",ctod(MV_PAR02),Dtos(MV_PAR02))

Local aIndexSF3	:= {} 
Local cCodMun := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )

Local cFiltro	 	:= ""

Private bFiltraBrw2 := {|| Nil }

Private cMarca 
Private aRotina := {}

If type ("_oObj") == "U" 
	_oObj := GetObjBrow()//Alimento a variável com o objeto do Browse principal (a variável está declarada como Private) 
EndIf

aRotina := {	{STR0004,"AxPesqui"    ,0,1,0,.F.},; //"Pesquisar"
				{STR0146,"Fisa022Canc()",0,2,0 ,NIL}} //"Trans. Canc." -- Fisa022Can

	If Alltrim( TCGetDB()) $ "ORACLE#DB2#DB2/400"
		cQuery := "And SUBSTR(F3_CODRSEF,1,1) = 'S' "
	Else
		cQuery := "And SUBSTRING(F3_CODRSEF,1,1) = 'S' "
	Endif

If SF3->(FieldPos("F3_CODRET")) > 0
	cQuery += "AND F3_CODRET <> '333' " 
	cQuery += "AND F3_CODRET <> '222' "
EndIf

If cCodMun $ Fisa022Cod("201") .And. cEntSai $ "0"
	If Valtype(MV_PAR01) =="C"
		cFiltro := "F3_FILIAL = '"+xFilial("SF3")+"' AND F3_DTCANC >= '"+ctod(MV_PAR01)+"' AND F3_DTCANC <= '"+ctod(MV_PAR02)+"' " + cQuery 
	Else
		cFiltro := "F3_FILIAL = '"+xFilial('SF3')+"' AND F3_DTCANC >= '"+dtos(MV_PAR01)+"' AND F3_DTCANC <= '"+dtos(MV_PAR02)+"' " + cQuery 
	EndIf
				
	SF3->(DBSelectArea("SF3"))
	cMarca := GetMark()
	cCadastro := "Notas Fiscais Canceladas"
	FWMarkBrowse("SF3", "F3_OK", , , , cMarca, "MarcaT()", , , ,"Marca1()", , cFiltro, , )    
Else
	If Valtype(MV_PAR01) =="C"
		cFiltro := "F3_FILIAL = '"+xFilial("SF3")+"' AND F3_DTCANC >= '"+ctod(MV_PAR01)+"' AND F3_DTCANC <= '"+ctod(MV_PAR02)+"' " + cQuery 
	Else
		cFiltro := "F3_FILIAL = '"+xFilial('SF3')+"' AND F3_DTCANC >= '"+dtos(MV_PAR01)+"' AND F3_DTCANC <= '"+dtos(MV_PAR02)+"' " + cQuery 
	EndIf

	SF3->(DBSelectArea("SF3"))
	SF3->(DbSetOrder(8))
	cMarca := GetMark()
	cCadastro := "Notas Fiscais Canceladas"
	FWMarkBrowse("SF3", "F3_OK", , , , cMarca, "MarcaT()", , , ,"Marca1()", , cFiltro, , )    
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

Function MarcaT()

Local nRecno := SF3->(Recno())

SF3->(DBSelectArea("SF3"))
SF3->(DBGotop())

While !SF3->(EOF())
If SF3->(FieldPos("F3_OK")) > 0
	If (Empty(SF3->F3_OK) .or. SF3->F3_OK <> cMarca)
		Reclock("SF3",.F.)
		SF3->F3_OK := cMarca
		MsUnlock()
	else
		Reclock("SF3",.F.)
		SF3->F3_OK := "  "
		MsUnlock()
	EndIf                 
EndIf
	SF3->(DbSkip())
EndDo
SF3->(DBGoto(nRecno))    

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Marca1()

SF3->(DBSelectArea("SF3"))
If SF3->(FieldPos("F3_OK")) > 0
	If (Empty(SF3->F3_OK) .or. SF3->F3_OK <> cMarca)
		Reclock("SF3",.F.)
		SF3->F3_OK  := cMarca
		MsUnlock()
	else
		Reclock("SF3",.F.)
		SF3->F3_OK  := "  "
		MsUnlock()
	EndIf                                            
EndIf  

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA022   ºAutor  ³Microsiga           º Data ³  05/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FisaCanc(cCodMun,cAlias,cNotasOk,cSerie,cNotaIni,cNotaFim,cDest,lAuto,cGravaDest,lUsaColab,lSF3Canc,cFTPT)
 
	local aArea     	:= GetArea() 
	local aRemessa 		:= {}
	local aCancela 		:= {}
	local cAliasSF3 	:= "SF3"
	local cRetorno   	:= ""      
	local cMotCancela	:= "cancelamento automatico"  
	local cXjust		:= ""
	local cCodCanc		:= ""
	local cRdMakeNFSe	:= ""
	local cSerieIni	:= cSerie
	local cSerieFim	:= cSerie
		   
	local lXjust    	:= GetNewPar("MV_INFXJUS","") == "S"
	local lHabCanc		:= GetNewPar("MV_CODCANC",.F.) //Habilita a tela de seleção dos códigos de cancelamento (#Piloto Itajaí - SC)
	local lOk			:= .T.
	local lReproc		:= .F.	
	local lCanc			:= .T.
	local lMontaXML		:= .F.
	Local lContinua		:= .T.
	
	local nCount		:= 0
	local cCondQry	:= ""
		
	default cSerie		:= ""
	default cNotaIni	:= ""
	default cNotaFim	:= ""
	default cDest		:= ""
 	default lUsaColab	:= UsaColaboracao("3") 			
	default lSF3Canc	:= .T. // Verdadeiro se a NFS ja foi cancelada			
	default cGravaDest	:= ""
	default cFTPT		:= "1"

	cGravaDest	:= alltrim (cGravaDest)
	Procregua((cAliasSF3)->(reccount()))

	cCondQry:="%"
		
	If cEntSai == "1"
		
		cCondQry +="F3_CFO >= '5' "	
	
	ElseIF cEntSai == "0"	
	
		cCondQry +="F3_CFO < '5' "
	
	EndiF	
	
	If ( ( !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim) .And. ( cCodMun $ Fisa022Cod("101") .or. cCodMun $ Fisa022Cod("102") ) .Or. ( !cCodMun $ Fisa022Cod("201") .And. cCodMun $ GetMunNFT() .And. cEntSai == "0" )  .or. lAuto ) ) 

		cCondQry += " AND SF3.F3_SERIE		=  '" + cSerie		+ "'" 
		cCondQry += " AND SF3.F3_NFISCAL	>= '" + cNotaIni	+ "'"	
		cCondQry += " AND SF3.F3_NFISCAL	<= '" + cNotaFim	+ "'"

	else	

		if lOk
			
			If (cAliasSF3)->(FieldPos("F3_OK")) > 0
			
				cCondQry += " AND SF3.F3_OK = '" + cMarca + "'"
			
			else
			
				lOk := .F.			
			
			endif
		
		endif
	
	endif	
	
	
	cRdMakeNFSe	:= getRDMakeNFSe(cCodMun,cEntSai)
	lMontaXML		:= lMontaXML(cCodMun,cEntSai)


	If lOk
	
		cAliasSF3 := GetNextAlias()
	
		If cCodMun $ Fisa022Cod("201") .And. (cCodMun $ GetMunNFT() .And. cEntSai == "0") 		
			cCondQry +="%"
			BeginSql Alias cAliasSF3
				
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_DTCANC AS DATE
									
			SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					%Exp:cCondQry%
			EndSql
		Else		
			If lSF3Canc
				cCondQry += " AND SF3.F3_DTCANC <> '"+Space(8)+"' "
				cCondQry += " AND SF3.F3_CODRET <> '333' "
				cCondQry += " AND SF3.F3_CODRET <> '222' "
				If !cCodMun $ "3552403-3170701-2601201" //Fisa022Cod("101")
					cCondQry += " AND SF3.F3_CODRET <> 'T' "
				EndIf
			EndIf
			cCondQry +="%"
			BeginSql Alias cAliasSF3
					
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_DTCANC AS DATE
			// #------ Query para cancelamento
			SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% 
					AND %Exp:cCondQry%  				
					AND SF3.%notdel% 
			EndSql		
			if lAuto
				autoNfseMsg ("[Query Cancelamento  ] "+ getlastquery()[2],.F.)
			Endif
		EndIf

		cTotal := cValToChar((cAliasSF3)->(reccount()))

		While !(cAliasSF3)->(EOF()) .and. lOk
			
			nCount++
			
			IncProc("("+cValToChar(nCount)+"/"+cTotal+") "+STR0022+(cAliasSF3)->F3_NFISCAL) //"Preparando nota: "
				
			If lXjust .or. lHabCanc
				cMotCancela := " "
				ccodcanc	:= " "
				aCancela 	:= GetJustCanc((cAliasSF3)->F3_SERIE, (cAliasSF3)->F3_NFISCAL, cCodMun)
			EndIf	
				
			If ( Len(aCancela) >= 1 )
				ccodcanc 	:= aCancela[1]
				cMotCancela := NoAcento(aCancela[2])			
				lContinua	:= aCancela[3]
			EndIf
						
			
			//-- Gerar XML atraves do RDMAKE
			If lContinua
				aadd(aRemessa, montaRemessaNFSE(cAliasSF3,cRdMakeNFSe,lCanc,cCodCanc,cMotCancela,cIdent,lMontaXML,/*cCodTit*/,/*cAviso*/,/*aTitIssRet*/,lUsaColab))		
				(cAliasSF3)->(DbSkip())	
			Else
				lOk := .F.
			EndIf	
		EndDo	
				 
		lOk := envRemessaNFSe(cIdEnt,cUrl,aRemessa,lReproc,cEntSai,@cNotasOk,lcanc,cCodCanc,cCodMun,,,cMotCancela) 
		If !lUsaColab
			If lOk
				If ( (cCodMun $ Fisa022Cod("101") ) .Or. (cCodMun $ Fisa022Cod("102")) .Or. (!cCodMun $ Fisa022Cod("201") .And. cCodMun $ GetMunNFT() .And. cEntSai == "0") )
					cNotasOk := ""
					//-- gera arquivo txt para os modelos 101,102 ou NFTS(São Paulo)
					geraArqNFSe(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFim,cDEST,,cSerieIni,cSerieFim,,,aRemessa,@cNotasOk,,cGravaDest,cFtpT)
				EndIf
			Else
				cMsg :=(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))
			EndIf
		EndIf
		(cAliasSF3)->(dbCloseArea())
		
		SF3->(DbCloseArea())
		
		RestArea(aArea)   
	
	EndIf

Return(cRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |RetMunCanc³ Autor ³ Roberto Souza         ³ Data ³21/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os municipios que utilizam cancelamento por WS.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RetMunCanc()
Local cRetMunCanc	:= ""
Local cPipe		:= "-"
Local oWsCfg		:= Nil
Local oWsNFSe		:= Nil
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaColab	:= UsaColaboracao("3")
cRetMunCanc := iif (lUsaColab,if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ),"")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      ATENCAO: A PARTIR DE 16/12/2014, OS CODIGOS NOVS DEVEM SER ADICIONADOS     ³
	//³     NO METODO RETMUNCANC DO WEBSERVICE NFS0001 DO TSS. NAO INCLUIR NOVOS        ³
	//³     CODIGOS NA LISTA DO FISA022. APENAS NA LISTA DO METODO REMUNCANC DO TSS     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUsacolab .And. isConnTSS() .And. !Empty(GetIdEnt()) .And. !Empty(cURL)

	If Val(substr(getVersaoTSS(),1,2)) >= 12 .or. getVersaoTSS()  >= "2.42"
		oWsNFSe := WsNFSE001():New()
		oWsNFSe:cUSERTOKEN	:= "TOTVS"
		oWsNFSe:cID_ENT		:= GetIdEnt()
		oWsNFSe:_URL		:= AllTrim(cURL)+"/NFSE001.apw"
		If oWsNFSe:RetMunCanc()
			cRetMunCanc := oWsNFSe:cRetMunCancResult
		EndIf
	Else
		If Dtos(Date()) > "20150701"
			MsgStop(STR0236)  //"Ambiente TSS desatualizado. Contacte o suporte TOTVS para atualização"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³         ATENCAO: USO DA LISTA VIA "FISA022" LIBERADO ATE 01/07/2015         ³
			//³         APOS ESTA DATA, FORCAR A ATUALIZACAO DO TSS PELO CLIENTE            ³
			//³                      LISTA SERA REMOVIDA DO FONTE FISA022                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRetMunCanc += "3205002" + cPipe  // ES-Serra
			cRetMunCanc += "3203205" + cPipe  // ES-Linhares
			cRetMunCanc += "3117504" + cPipe  // MG-Conceicao do mato dentro
			cRetMunCanc += "1600303" + cPipe  // AP-Macapa						
			cRetMunCanc += "1302603" + cPipe  // AM-Manaus
			cRetMunCanc += "1400100" + cPipe  // RR-Boa Vista
			cRetMunCanc += "2111300" + cPipe  // MA-São Luiz
			cRetMunCanc += "2304400" + cPipe  // CE-Fortaleza
			cRetMunCanc += "2307650" + cPipe  // CE-Maracanaú
			cRetMunCanc += "2507507" + cPipe  // PB-Joao Pessoa
			cRetMunCanc += "2610707" + cPipe  // PE-PAULISTA	
			cRetMunCanc += "2611606" + cPipe  // PE-Recife
			cRetMunCanc += "2704302" + cPipe  // AL-Maceio
			cRetMunCanc += "2800308" + cPipe  // SE-Aracaju
			cRetMunCanc += "1702109" + cPipe  // PI-Araguaína
			cRetMunCanc += "2802106" + cPipe  // SE-Estância
			cRetMunCanc += "2910800" + cPipe  // BA-Feira de Santana
			cRetMunCanc += "2927408" + cPipe  // BA-Salvador
			cRetMunCanc += "4299599" + cPipe  // BA-Teixera de Freitas  já estava com este codigo
			cRetMunCanc += "3106200" + cPipe  // MG-Belo Horizonte
			cRetMunCanc += "3106705" + cPipe  // MG-Betim
			cRetMunCanc += "3115300" + cPipe  // MG-Cataguases
			cRetMunCanc += "3118601" + cPipe  // MG-Contagem
			cRetMunCanc += "3136207" + cPipe  // MG-João Monlevade
			cRetMunCanc += "3136702" + cPipe  // MG-Juiz de Fora
			cRetMunCanc += "3143906" + cPipe  // MG-Muriaé
			cRetMunCanc += "3147105" + cPipe  // MG-Pará de Minas
			cRetMunCanc += "3156700" + cPipe  // MG-Sabará
			cRetMunCanc += "3168705" + cPipe  // MG-Timoteo	
			cRetMunCanc += "3170107" + cPipe  // MG-Uberaba
			cRetMunCanc += "3170206" + cPipe  // MG-Uberlandia
			cRetMunCanc += "3201209" + cPipe  // ES-Cachoeiro de Itapemirim
			cRetMunCanc += "3201308" + cPipe  // ES- Cariacica
			cRetMunCanc += "3300100" + cPipe  // RJ-Angra dos Reis
			cRetMunCanc += "3300407" + cPipe  // RJ-Barra Mansa
			cRetMunCanc += "3300704" + cPipe  // RJ-Cabo Frio
			cRetMunCanc += "3301702" + cPipe  // RJ-Duque de Caxias
			cRetMunCanc += "3303302" + cPipe  // RJ-Niteroi
			cRetMunCanc += "3303500" + cPipe  // RJ-Nova Iguaçu
			cRetMunCanc += "3304557" + cPipe  // RJ-Rio de Janeiro
			cRetMunCanc += "3304904" + cPipe  // RJ-São Gonçalo		
			cRetMunCanc += "3501608" + cPipe  // SP-Americana
			cRetMunCanc += "3503307" + cPipe  // SP-Araras
			cRetMunCanc += "3505708" + cPipe  // SP-Barueri
			cRetMunCanc += "3509502" + cPipe  // SP-Campinas
			cRetMunCanc += "3513009" + cPipe  // SP-Cotia
			cRetMunCanc += "3513801" + cPipe  // SP-Diadema
			cRetMunCanc += "3515004" + cPipe  // SP-Embu das Artes
			cRetMunCanc += "3518404" + cPipe  // SP-Guaratinguetá
			cRetMunCanc += "3518701" + cPipe  // SP-Guaruja
			cRetMunCanc += "3518800" + cPipe  // SP-Guarulhos
			cRetMunCanc += "3519071" + cPipe  // SP-Hortolândia
			cRetMunCanc += "3523404" + cPipe  // SP-Itatiba
			cRetMunCanc += "3523909" + cPipe  // SP-Itu
			cRetMunCanc += "3524709" + cPipe  // SP-Jaguariuna
			cRetMunCanc += "3502507" + cPipe  // SP-Aparecida
			cRetMunCanc += "3525102" + cPipe  // SP-Jardinópolis
			cRetMunCanc += "3525904" + cPipe  // SP-Jundiai
			cRetMunCanc += "3529401" + cPipe  // SP-Mauá
			cRetMunCanc += "3534401" + cPipe  // SP-Osasco
			cRetMunCanc += "3536505" + cPipe  // SP-Paulínia
			cRetMunCanc += "3538709" + cPipe  // SP-Piracicaba
			cRetMunCanc += "3541406" + cPipe  // SP-Presidente Prudente
			cRetMunCanc += "3547809" + cPipe  // SP-Sto André
			cRetMunCanc += "3548500" + cPipe  // SP-Santos
			cRetMunCanc += "3548708" + cPipe  // SP-Sao Bernardo do Campo
			cRetMunCanc += "3549904" + cPipe  // SP-São José dos Campos
			cRetMunCanc += "3549805" + cPipe  // SP-São José do Rio Preto
			cRetMunCanc += "3550308" + cPipe  // SP-Sao Paulo
			cRetMunCanc += "3552205" + cPipe  // SP-Sorocaba
			cRetMunCanc += "3543402" + cPipe  // SP-Ribeirão Preto
			cRetMunCanc += "3554102" + cPipe  // SP-Taubaté
			cRetMunCanc += "4101507" + cPipe  // PR-Arapongas
			cRetMunCanc += "4104808" + cPipe  // PR-Cascavel
			cRetMunCanc += "4106407" + cPipe  // PR-Cornélio Procópio
			cRetMunCanc += "4106902" + cPipe  // PR-Curitiba
			cRetMunCanc += "4108304" + cPipe  // PR-Foz do Iguaçu
			cRetMunCanc += "4108403" + cPipe  // PR-Francisco Beltrão
			cRetMunCanc += "4118204" + cPipe  // PR-Paranaguá
			cRetMunCanc += "4119905" + cPipe  // PR-Ponta Grossa
			cRetMunCanc += "4125506" + cPipe  // PR-São José dos Pinhais
			cRetMunCanc += "4127700" + cPipe  // PR-Toledo
			cRetMunCanc += "4201307" + cPipe  // SC-Araquari
			cRetMunCanc += "4202305" + cPipe  // SC-Biguacu
			cRetMunCanc += "4202404" + cPipe  // SC-Blumenau
			cRetMunCanc += "4203006" + cPipe  // SC-Caçador
			cRetMunCanc += "4204608" + cPipe  // SC-Criciúma
			cRetMunCanc += "4208203" + cPipe  // SC-Itajaí
			cRetMunCanc += "4216602" + cPipe  // SC-São José	 
			cRetMunCanc += "4313409" + cPipe  // RS-Novo Hamburgo
			cRetMunCanc += "4318002" + cPipe  // RS-São Borja
			cRetMunCanc += "4318705" + cPipe  // RS-Sao Leopoldo
			cRetMunCanc += "4314407" + cPipe  // RS-Pelotas
			cRetMunCanc += "5002704" + cPipe  // MS-Campo Grande
			cRetMunCanc += "5103403" + cPipe  // MT-Cuiabá
			cRetMunCanc += "5201108" + cPipe  // GO-Anapolis
			cRetMunCanc += "3302403" + cPipe  // RJ-Macaé
			cRetMunCanc += "2803500" + cPipe  // SE-Lagarto
			cRetMunCanc += "3205309" + cPipe  // ES-Vitoria
			cRetMunCanc += "4115200" + cPipe  // PR-Maringá
			cRetMunCanc += "3162104" + cPipe  // MG-São Gotardo
			cRetMunCanc += "3127107" + cPipe  // MG-Frutal
			cRetMunCanc += "3148004" + cPipe  // MG-Patos de Minas
			cRetMunCanc += "3143302" + cPipe  // MG-Montes Claros
			cRetMunCanc += "3545209" + cPipe  // SP-Salto
			cRetMunCanc += "5218508" + cPipe  // GO-Quirinópolis
			cRetMunCanc += "3548807" + cPipe  // SP-Sao Caetano do Sul
			cRetMunCanc += "4303103" + cPipe  // RS-Cachoeirinha
			cRetMunCanc += "3148103" + cPipe  // MG-Patrocínio
			cRetMunCanc += "3146107" + cPipe  // MG-Ouro Preto
			cRetMunCanc += "4308201" + cPipe  // RS-Flores da Cunha
			cRetMunCanc += "4311403" + cPipe  // RS-Lajeado
			cRetMunCanc += "3304508" + cPipe  // RJ-Rio das Flores
			cRetMunCanc += "4304606" + cPipe  // RS-Canoas
			cRetMunCanc += "2301000" + cPipe  // CE-Aquiraz
			cRetMunCanc += "4207304" + cPipe  // SC-Imbituba
			cRetMunCanc += "4211306" + cPipe  // SC-Navegantes
			cRetMunCanc += "3552502" + cPipe  // SP-Suzano
			cRetMunCanc += "3302007" + cPipe  // RJ-Itaguaí
			cRetMunCanc += "4307708" + cPipe  // RS-Esteio
			cRetMunCanc += "4308508" + cPipe  // RS-Frederico Westphalen
			cRetMunCanc += "1200401" + cPipe  // AC-Rio Branco 
			cRetMunCanc += "3200607" + cPipe  // ES-Aracruz
			cRetMunCanc += "3550704" + cPipe  // SP-São Sebastião
			cRetMunCanc += "4307005" + cPipe  // RS-Erechim
			cRetMunCanc += "4215802" + cPipe  // SC-São Bento do Sul  
			cRetMunCanc += "3301900" + cPipe  // RJ-Itaboraí
			cRetMunCanc += "4107652" + cPipe  // PR-Fazenda Rio Grande
			cRetMunCanc += "3157807" + cPipe  // MG-Santa Luzia
			cRetMunCanc += "2933307" + cPipe  // BA-Vitória da Conquista
			cRetMunCanc += "3551009" + cPipe  // SP-São Vicente
			cRetMunCanc += "1721000" + cPipe  // ES-Palmas
			cRetMunCanc += "2704708" + cPipe  // AL-Marechal Deodoro
			cRetMunCanc += "3131703" + cPipe  // MG-Itabira
			cRetMunCanc += "4102307" + cPipe  // PR-Balsa Nova
			cRetMunCanc += "2301109" + cPipe  // CE-Aracati
			cRetMunCanc += "2700300" + cPipe  // AL-Arapiraca
			cRetMunCanc += "3524907" + cPipe  // SP-Jambeiro
			cRetMunCanc += "3205200" + cPipe  // ES-Vila Velha
			cRetMunCanc += "4313300" + cPipe  // RS-Nova Prata
			cRetMunCanc += "4305108" + cPipe  // RS-Caxias do Sul
			cRetMunCanc += "3101508" + cPipe  // MG-Além Paraíba
			cRetMunCanc += "4314902" + cPipe  // RS-Porto Alegre
			cRetMunCanc += "4202008" + cPipe  // SC_Balneário Camboriú
			cRetMunCanc += "3200300" + cPipe  // ES_Alfredo Chaves
			cRetMunCanc += "3510807" + cPipe  // SP-Casa Branca
			cRetMunCanc += "2909307" + cPipe  // BA_CORRENTINA
			cRetMunCanc += "3144805" + cPipe  // MG-Nova Lima
			cRetMunCanc += "3129806" + cPipe  // MG-Ibirité
			cRetMunCanc += "3510807" + cPipe  // SP- Casa Branca 
			cRetMunCanc += "5213103" + cPipe  // GO-Mineiros
			cRetMunCanc += "3554102" + cPipe  // SP-Taubaté
			cRetMunCanc += "4118204" + cPipe  // PR-Paranaguá
			cRetMunCanc += "3169901" + cPipe  // MG-Ubá
			cRetMunCanc += "3305000" + cPipe  // RJ-São João da Barra
			cRetMunCanc += "3302601" + cPipe  // RJ-Mangaratiba
			cRetMunCanc += "3303401" + cPipe  // RJ-Nova Friburgo
			cRetMunCanc += "5006606" + cPipe  // MS-Ponta Porã
			cRetMunCanc += "4204202" + cPipe  // SC-Chapeco
			cRetMunCanc += "4301206" + cPipe  // RS-Arroio do Tigre

			// Municípios do Modelo "101" Geração de arquivo TXT
			cRetMunCanc += "2610707" + cPipe  // PE-Paulista 
			cRetMunCanc += "3168705" + cPipe  // MG-Timoteo
			cRetMunCanc += "3505708" + cPipe  // SP-Barueri
			cRetMunCanc += "1501402" + cPipe  // PA-Belem
					
			// Municípios do Modelo "102" Geração de arquivo XML 
			cRetMunCanc += "3132404" + cPipe  // MG-Itajuba
			cRetMunCanc += "4209102" + cPipe  // SC-Joinville
			cRetMunCanc += "3158953" + cPipe  // MG-Santana do Paraiso
			cRetMunCanc += "3507605" + cPipe  // SP-Bragança Paulista
			
			// Municípios do Modelo "005"
			cRetMunCanc += "2504009" + cPipe  // PB-Campina Grande
			
			// Municípios do Modelo "006"
			cRetMunCanc += "4113700" + cPipe  // PR-Londrina
			cRetMunCanc += "4315602" + cPipe  // RS-Rio Grande

			// Municípios do Modelo "008" 
			cRetMunCanc += "4307906" + cPipe  // RS-Farroupilha
			
			// Municípios do Modelo "009" 
			cRetMunCanc += "3546801" + cPipe  // SP-Santa Isabel
			
			// Municípios do Modelo "010"	  // Provedor GOVERNA
			cRetMunCanc += Fisa022Cod( "010" ) + cPipe
			
			// Municípios do Modelo "011" 
			cRetMunCanc += "4208450" + cPipe  // SC-Itapoá
			cRetMunCanc += "4309209" + cPipe  // RS-Gravatai
			cRetMunCanc += "4216206" + cPipe  // São Francisco do Sul - SC
			cRetMunCanc += "4206306" + cPipe  // Guabiruba - SC
			cRetMunCanc += "4205506" + cPipe  // Fraiburgo - SC
			
			// Municípios do Modelo "012"
			cRetMunCanc += "3524006" + cPipe  // SP-Itupeva
			cRetMunCanc += "3505906" + cPipe  // SP-Batatais
			
			// Município do Modelo "015"
			cRetMunCanc += "3526803" + cPipe  // SP-Lençóis Paulista
			
			// Município do Modelo "017"
			cRetMunCanc += "4205407" + cPipe  // SC-Florianopolis

			// Município do Modelo "019"
			cRetMunCanc += Fisa022Cod( "019" ) + cPipe  // Provedor Intertec
			
			// Município do Modelo "020"
			cRetMunCanc += Fisa022Cod( "020" ) + cPipe  // Provedor FGMAISS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³         ATENCAO: NAO INCLUIR MAIS MUNICIPIOS NESTA LISTA.                   ³
			//³         USAR O METODO RETMUNCANC DO TSS PARA ESTA FINALIDADE                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
		EndIf
	EndIf
EndIf	

	FreeObj(oWsNFSe)
	oWsNFSe := nil
	delClassIntF()

Return(cRetMunCanc)



Static Function ExecWSRet( oWS, cMetodo )

Local bBloco	:= {||}

Local lRetorno	:= .F.    

Private oWS2 	:= NIL

DEFAULT oWS		:= NIL
DEFAULT cMetodo	:= ""

If ( ValType(oWS) <> "U" .And. !Empty(cMetodo) )

	oWS2 := oWS

	If ( Type("oWS2") <> "U" )
		bBloco 	:= &("{|| oWS2:"+cMetodo+"() }") 
		lRetorno:= eval(bBloco)
		
		If ( lRetorno == NIL )
			lRetorno := .F.			
		EndIf
		
	EndIf

	oWS2 := NIL
	
EndIf

Return lRetorno

Function CleanSpecChar(cString)
	
	Local cRetorno:=""
	Local nChar:=0
	Local cChar:='<>´"'+"'"
                   
	cRetorno:=cString	                       
 
	For nChar:=1 To len(cChar)
		cRetorno:=StrTran(cRetorno,Substr(cChar,nChar,1),"")
	 Next
	
Return cRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetMunNFT
Funcao retorna os municipios que trabalham com NFTS - Nota Fiscal
Tomador de Serviço.

@author Sergio Sueo Fuzinaka
@since 12.11.2010
@version 1.0 

@param		Nil

@return		Nil
@obs		A tabela SPED051 deve estar posicionada
/*/
//-----------------------------------------------------------------------
Function GetMunNFT()
	
Local cRetorno := " " 
	
	cRetorno := SuperGetMV("MV_NFTOMSE", ,"")//Parametro para informar quais os municipios que estão configurado para o envio da "NFTS"                   
 		
Return cRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} retornaMonitor
Funcao que executa o retornanfse e retorna a data e hora de transmissão do documento.

@author Henrique Brugugnoli
@since 30/01/2012
@version 1.0 

@param cXmlRet	XML unico de retorno do TSS

@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function retornaMonitor( cCID, cXmlRet )

Local aDados	:= {}

Local cHora		:= ""
Local cData		:= "" 
Local cAviso	:= "" 
Local cErro		:= ""
Local cCodVer	:= ""
Local dDataConv	:= CTOD( "" )
           
Private oXml	:= NIL

If ( !Empty(cXmlRet) )
 	
 	oXml := XmlParser( cXmlRet, "_", @cAviso, @cErro )  
 		
	cHora		:= ""
	cData		:= ""
	dDataConv	:= CTOD( "" )
 		
 	If ( empty(cErro) .And. empty(cAviso) ) 
 		
		if ( type("oXml:_nfseretorno:_identificacao:_dthremisnfse:TEXT") <> "U" )
			cHora := SubStr( oXml:_nfseretorno:_identificacao:_dthremisnfse:TEXT,12,8 )
			cData := SubStr( oXml:_nfseretorno:_identificacao:_dthremisnfse:TEXT,1,10 ) 
		elseif Type( "oXml:_nfseretorno:_identificacao:_dthremisrps:TEXT" ) <> "U"
			cHora := SubStr( oXml:_nfseretorno:_identificacao:_dthremisrps:TEXT,12,8 )
			cData := SubStr( oXml:_nfseretorno:_identificacao:_dthremisrps:TEXT,1,10 )  
		endif

		//***********************************//
		// Tratamento para cancelamento		//
		//***********************************//
		If Type( "oXml:_nfseretorno:_cancelamento:_datahora:TEXT" ) <> "U" .And. !Empty( oXml:_nfseretorno:_cancelamento:_datahora:TEXT ) 	
			cHora := SubStr( oXml:_nfseretorno:_cancelamento:_datahora:TEXT,12,8 )
			cData := SubStr( oXml:_nfseretorno:_cancelamento:_datahora:TEXT,1,10 )
			
 		EndIf

		If Empty( cData ) 
			If type("oWs:CDATAHORA") <> "U" .and. !Empty(oWs:CDATAHORA)
				 // analisando se o formato de datahora eh igual a "2020-12-21T15:06:00" para quando o retorno XmlRet_tss nao trouxer os dados de data hora 
				If Len(oWs:CDATAHORA) == 19 .and. Upper(SubStr( oWs:CDATAHORA,11,1 )) == "T" .and. !(Upper(SubStr( oWs:CDATAHORA,5,1 )) $ "0123456789") .OR. ;// primeiro checa se data esta na frente e depois se o ano vem primeiro AAAA-MM-DD
					( cCodMun $ "3170701" .and. Len(oWs:CDATAHORA) == 19 .and. !(Upper(SubStr( oWs:CDATAHORA,5,1 )) $ "0123456789"))  // Varginha não possui a letra "T" na data e hora 2022-09-08 11:52:57
						cHora 	:= Substr(oWs:CDATAHORA,12,8)
						cData 	:= Substr(oWs:CDATAHORA,1,10)
						If (type("oWs:CPROTOCOLO") <> "U") .and. !Empty(AllTrim(oWs:CPROTOCOLO))
							cCodVer := AllTrim(oWs:CPROTOCOLO)
						Endif 
				Endif 
			Endif 
		Endif 
		//Tratamento feito para pegar a hora
		If Empty( cHora ) 
			If type("oWs:CDATAHORA") <> "U" .and. !Empty(oWs:CDATAHORA)
				 // analisando se o formato de datahora eh igual a "2020-12-21T15:06:00" para quando o retorno XmlRet_tss nao trouxer os dados de data hora 
				If Len(oWs:CDATAHORA) == 19 .and. Upper(SubStr( oWs:CDATAHORA,11,1 )) == "T" .and. !(Upper(SubStr( oWs:CDATAHORA,5,1 )) $ "0123456789")// primeiro checa se data esta na frente e depois se o ano vem primeiro AAAA-MM-DD
					cHora 	:= Substr(oWs:CDATAHORA,12,8)
					If Empty( cCodVer )
						If (type("oWs:CPROTOCOLO") <> "U") .and. !Empty(AllTrim(oWs:CPROTOCOLO))
							cCodVer := AllTrim(oWs:CPROTOCOLO)
						Endif 
					EndIf	
				Endif 
			Endif 
		Endif 

		If !Empty( cData )
			dDataConv := cToD(SubStr(cData,9,2) + "/" + SubStr(cData,6,2)  + "/" + SubStr(cData,1,4)) 
		Endif
		
		If Type( "oXml:_nfseretorno:_identificacao:_codver:TEXT" ) <> "U"
			cCodVer := oXml:_nfseretorno:_identificacao:_codver:TEXT
		Endif
		
		aDados := { cCID, dDataConv, cHora, cCodVer }
		
 	EndIf		
 	
 EndIf
 		
Return( aDados )

//-----------------------------------------------------------------------
/*/{Protheus.doc} isModeloUnico
Funcao que verifica se e modelo unico de retorno que esta valendo.

@author Henrique Brugugnoli
@since 30/01/2012
@version 1.0 

@return	lModeloUnico	Se verdadeiro esta execuntando o modelo unico
/*/
//-----------------------------------------------------------------------
Function isTSSModeloUnico()

Local lModeloUnico	:= GetMV("MV_NFSEMOD",,.F.) 
Local lUsaColab		:= UsaColaboracao("3")

	If ( GetRpoRelease() > "11" ) .and. !lUsaColab 
		lModeloUnico := .T.	// Para versão 12		sempre .T.						
	Elseif lUsaColab
		lModeloUnico := .F. 	// Colaboração 2.0	sempre .F.
EndIf

Return lModeloUnico      


//-----------------------------------------------------------------------
/*/{Protheus.doc} GetMonitRx
Funcao que retorna informações referente ao Monitoramento da NFS-e do TSS

@author Simone dos Santos Oliveira
@since 12.03.2012
@version 1.0 

@param		Nil

@return		Nil
/*/
//-----------------------------------------------------------------------
Static Function GetMonitRx(cIdEnt,cUrl)

Local aArea	:= GetArea()
Local aNotas	:= {}  
Local cAliasSF3 := GetNextAlias()
Local cCodMun   := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) 
Local cNumAte	:= "" 
Local cNumDe  	:= ""
Local lOk       := .F.
local nAt		:= 0
Local nX        := 0  
Local oWS		:= Nil
Local oXmlMonit	:= Nil


BeginSql Alias cAliasSF3
	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE
	
	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFeLETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODRSEF,R_E_C_N_O_
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_DTCANC <> ' ' AND
			SF3.F3_CODRSEF = 'C' AND
			SF3.%notdel%
EndSql

If ( cAliasSF3 )->( Eof() )
	Return .F.
EndIf

While !( cAliasSF3 )->( Eof() )
	
	aAdd( aNotas, { allTrim( ( cAliasSF3 )->F3_SERIE ) + allTrim( ( cAliasSF3 )->F3_NFISCAL ), ( cAliasSF3 )->R_E_C_N_O_ } )
	
  	If (( cAliasSF3 )->F3_SERIE + ( cAliasSF3 )->F3_NFISCAL) < cNumDe .Or. Empty( cNumDe )
		cNumDe	:= ( cAliasSF3 )->F3_SERIE + allTrim( ( cAliasSF3 )->F3_NFISCAL )
	EndIf
	
	If (( cAliasSF3 )->F3_SERIE + ( cAliasSF3 )->F3_NFISCAL) > cNumAte .Or. Empty( cNumAte )
		cNumAte	:=  ( cAliasSF3 )->F3_SERIE + allTrim( ( cAliasSF3 )->F3_NFISCAL )
	EndIf
	
	( cAliasSF3 )->( DbSkip() )
	
EndDo  

oWS := WsNFSE001():New()
oWS:cUSERTOKEN             := "TOTVS"
oWS:cID_ENT                := cIdEnt 
oWS:_URL                   := AllTrim(cURL)+"/NFSE001.apw"
oWS:cCODMUN                := cCodMun
oWS:dDataDe                := cTod("01/01/1949")
oWS:dDataAte               := cTod("31/12/2049")
oWS:cHoraDe                := "00:00:00"
oWS:cHoraAte               := "00:00:00"
oWS:nTipoMonitor           := 1
oWS:cIdInicial             := cNumDe 
oWS:cIdFinal               := cNumAte 
oWS:nTempo                 := 0

lOk := ExecWSRet(oWS,"MonitorX")

If lOk
	
	oRetorno := oWS:OWSMONITORXRESULT
	
  	For nX := 1 To Len(oRetorno:OWSMONITORNFSE)
		
		oXmlMonit := oRetorno:OWSMONITORNFSE[nX]
					
		nAt	:= aScan( aNotas, { | x | x[1] == allTrim( SubStr( oXmlMonit:CID, 1, 3 ) ) + allTrim( SubStr( oXmlMonit:CID, 4, 9 ) ) } )
					
		If nAt > 0   
		
			If oXmlMonit:NSTATUSCANC == 3
				
				SF3->( DbGoTo( aNotas[nAt][2] ) )
				
				If SF3->(FieldPos("F3_CODRSEF")) > 0
					SF3->( RecLock("SF3",.F.) )
					SF3->F3_CODRSEF	:= "S"
					SF3->( MsUnlock() ) 
				EndIf 
				
			EndIf 
			
		EndIf 
		
	Next nX

EndIf

( cAliasSF3 )->( dbCloseArea() )

RestArea( aArea )

	FreeObj(oWS)
	oWS := nil
	delClassIntF()
 		
Return .T.    

static function geraArqNFSe(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,cDEST,nForca,cSerieIni,cSerieFim,dDataIni,dDataFim,aRemessa,cNotasOk,lRecibo,cGravaDest,cFtpT)				
    
	local aNtXml	:= {}
	local cNtXml	:= ""
	local cCnpj	:= ""
	local cFin		:= ""
	local nX		:= 0
	local dDtxml
  
    default dDataIni := dDataFim:= date()
    default lRecibo	:= .f.
    default nForca	:= 1
	default cFtpT 	:= "1"
    				
	for nX := 1 to len(aRemessa)
		if cEntSai == "0"
			cCnpj := alltrim(Posicione("SA2",1,xFilial("SA2")+aRemessa[nX][3]+aRemessa[nX][4],"SA2->A2_CGC"))
			if lRecibo
		   		cFin := "FIN"					
			endif 			
		endIf
		
		cNtXml+= aRemessa[nX][1]+aRemessa[nX][2]+cCnpj+cFin+CRLF					
		aadd(aNtXml, {})		
		aadd(aTail(aNtXml), aRemessa[nX][1])
		aadd(aTail(aNtXml), aRemessa[nX][2])
		aadd(aTail(aNtXml), aRemessa[nX][3])
		aadd(aTail(aNtXml), aRemessa[nX][4])
		aadd(aTail(aNtXml), cCnpj+cFin)
	next
   		
	dDtxml:= aRemessa[1][5]
	cNotasOk += Fisa022XML(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,dDtxml,cDEST,cNtXml,aNtXml,nForca,cSerieIni,cSerieFim,dDataIni,dDataFim,cGravaDest,cFtpT)

return nil
//-----------------------------------------------------------------------
/*/{Protheus.doc} retDataXMLNFSe
retorna a data e a hora contida no XML da NFSe

@author Renato Nagib
@since 18.03.2013
@version 1.0 

@param cXML	XML da NFSe 		

@Return aRet	array contendo a data e a hora
				aRet[1] - data
				aRet[2] - hora
/*/
//-----------------------------------------------------------------------   

static function retDataXMLNFSe(cXML,cCodMun)


	local aTiposData	:= {}
	local aTiposHora	:= {}
	local aTiposDia		:= {}
	local aTiposMes		:= {}
	local aTiposAno		:= {}
	local aRet			:= {"", ""}
	local cAviso		:= ""
	local cErro		:= ""	
	local cRetData	:= ""	 
	local cRetHora	:= ""
	local cConteudo	:= ""
	local cConteuDia:= ""
	local cConteuMes:= ""
	local cConteuAno:= ""
	local lDataHora	:= .T.
	local nPosData	:= 0
	local nPosHora	:= 0
	local nPosDia	:= 0
	local nPosMes	:= 0
	local nPosAno	:= 0
	
	private oXML 
	         
	default cXML	:= "" 
	
	cXML := StrTran(cXML,"tipos:","")
	cXML := StrTran(cXML,"tc:","")				    		   
	cXML := StrTran(cXML,"es:","")
	cXML := StrTran(cXML,"nfse:","")				    		   								
	cXML := StrTran(cXML,"sis:","")	
	cXML := StrTran(cXML,'xsi:type="xsd:int"',"")	
	cXML := StrTran(cXML,'xsi:type="xsd:string"',"")
	cXML := StrTran(cXML,'ns2:',"")
	
	//colaboracao                       
	aadd( aTiposData, "_RPS:_DATAEMISSAORPS" )
	
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS:_INFRPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS[1]:_INFRPS:_DATAEMISSAO" )
	aadd( aTiposData, "_P_ENVIARLOTERPSENVIO:_P_LOTERPS:_P1_LISTARPS:_P1_RPS:_P1_INFRPS:_P1_DATAEMISSAO" )

	//"3550308(SAO PAULO)-2611606(RECIFE)-4202404(BLUMENAU)
	aadd( aTiposData, "_RPS:_DATAEMISSAO" ) 

	//4318002(RS-São Borja)-4203006(SC-Caçador)-5218508(GO-Quirinópolis)-4207304(SC-Imbituba)-4211306(SC-Navegantes)
	aadd( aTiposData, "_E_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS[1]:_INFRPS:_DATAEMISSAO" )

	//4318002(RS-São Borja)-4203006(SC-Caçador)-5218508(GO-Quirinópolis)
	aadd( aTiposData, "_E_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS:_INFRPS:_DATAEMISSAO" )

	//3503307(SP-Araras)-3515004(SP-Embu das artes)-3538709(SP-Piracicaba)-3148103(MG-Patrocínio)-4202008(SC-Balneário Camboriú)
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_NFSE_LOTERPS:_NFSE_LISTARPS:_NFSE_RPS:_NFSE_INFRPS:_NFSE_DATAEMISSAO" )

	//"3106200|2927408|3170107|4106902|3501608|3301702|3136207|2304400|3543402|2704302|3115300|2507507|3547809|3513009|2604106|5201108|4104808|2800308|3548708|3513801|5103403|3525904|3518800|3118601|3519071|3518701|1302603|3156700|3549904|3303302|3549805|3548500|3300407|3147105|4118204|3300100|4125506|4108304|3131307|2910800|4208203|3536505|3518404|3529401|3523909|4216602|4204608|2802106|3143906|2307650|3136702|3106705|3169901|3303401" // |Belo Horizonte-MG|Salvador-BA|Uberaba-MG|Curitiba-PR|Americana-SP|Duque de Caxias-RJ|João Monlevade-MG|Fortaleza-CE|Ribeirão Preto-SP|Maceió-AL|Cataguases-MG|João Pessoa-PB|Santo André-SP|Cotia-SP|Caruaru-PE|Anápolis-GO|Cascavel-PR|Aracaju-SE|São Bernardo do Campo-SP|
	//Diadema-SP|Cuiabá-MT|Jundiai-SP|Guarulhos-SP|Contagem-MG|Hortolandia-SP|Guaruja-SP|Manaus-AM|Sabará-MG|São Borja-RS|São José dos Campos-SP|Niteroi|São José do Rio Preto-SP|Barra Mansa-RJ|Pará de Minas-MG|Paranaguá-PR|Angra dos Reis-RJ|São José dos Pinhais||Foz do Iguaçu-PR|Ipatinga-MG|Feira de Santana|Itajaí-SC|Paulinia|Guaratinguetá|Mauá|Itu|São José|Nova Friburgo|Criciúma|Estância-SE|Muriaé-MG|Maracanaú-CE|Juiz de Fora-MG|Betim-MG|Araquari-SC|
	aadd( aTiposData, "_CONSULTARLOTERPSRESPOSTA:_LISTANFSE:_COMPNFSE[1]:_NFSE:_INFNFSE:_DATAEMISSAO" )
	aadd( aTiposData, "_CONSULTARLOTERPSRESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO" )
	aadd( aTiposData, "_GERARNFSEENVIO:_LOTERPS:_LISTARPS:_RPS:_INFRPS:_DATAEMISSAO" )
	aadd( aTiposData, "_GERARNFSEENVIO:_RPS:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTERPS:_LISTARPS:_RPS[1]:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSSINCRONOENVIO:_LOTERPS:_LISTARPS:_RPS:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSSINCRONOENVIO:_LOTERPS:_LISTARPS:_RPS[1]:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSSINCRONORESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO" )
	aadd( aTiposData, "_ENVIARLOTERPSSINCRONORESPOSTA:_LISTANFSE:_COMPNFSE[1]:_NFSE:_INFNFSE:_DATAEMISSAO" )

	//"2111300|5002704|3170206|1501402|2211001|3303500|3509502|3552205" //Sao Luis|Campo Grande|Uberlandia|Belem|Teresina|Nova Iguaçu|Campinas|Sorocaba - Modelo DSFNET
	aadd( aTiposData, "_NS1_REQENVIOLOTERPS:_LOTE:_RPS[1]:_DATAEMISSAORPS" )
	aadd( aTiposData, "_NS1_REQENVIOLOTERPS:_LOTE:_RPS:_DATAEMISSAORPS" )
	
	//3300704(Cabo Frio)-1400100(RR-Boa Vista)
	aadd( aTiposData, "_SubstituirNfseEnvio:_SubstituicaoNfse:_Rps:_InfDeclaracaoPrestacaoServico:_Rps:_DataEmissao" ) 
	//3158953 //Santana do Paraiso-MG
	aadd( aTiposData, "_NOTAS:_NOTA_DATA_EMISSAO" )
	
	//Modelo 004
	aadd( aTiposData, "_TBNFD:_NFD:_DATAEMISSAO" )
	
	//Modelo 007                                                                  
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTE:_LISTARPS:_RPS:_DTEMISSAORPS")
	aadd( aTiposData, "_ENVIARLOTERPSENVIO:_LOTE:_LISTARPS:_RPS[1]:_DTEMISSAORPS")
	
	//Modelo 008
	aadd( aTiposData, "_ENVIOLOTE:_DHTRANS")
	//Modelo 009
	aadd( aTiposData, "_NFEELETRONICA:_DADOSNOTAFISCAL:_EMISSAO")
	aadd( aTiposData, "_NFEELETRONICA:_DADOSNOTAFISCAL[1]:_EMISSAO")
	//Definir os tipos,caso exista Municipio que contenha a informação da hora em uma tag especifica
	aadd( aTiposHora, "" )   
	
	//Definir os tipos, caso exista Municipio que contenha as informações do dia, mês e ano de emissão do RPS em uma tag especifica 
	aadd( aTiposDia, "_DESCRICAORPS:_RPS_DIA") 
	
	aadd( aTiposMes, "_DESCRICAORPS:_RPS_MES")
	
	aadd( aTiposAno, "_DESCRICAORPS:_RPS_ANO")
	
	//Aracruz
	aadd( aTiposData, "_RETURN:_NOTASFISCAIS:_DATAPROCESSAMENTO" )
	
	//Recife - NFSE
	aadd( aTiposData, "_INFRPS:_DATAEMISSAO" )			

	//Rio de Janeiro
	aadd( aTiposData, "_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO" )

	//Joinville - SC 
	aadd( aTiposData, "_INFDECLARACAOPRESTACAOSERVICO:_COMPETENCIA" )

	//Taubate - SP
	aadd( aTiposData, "_SDT_CONSULTANOTASPROTOCOLOOUT:_XML_NOTAS:_REG20:_REG20ITEM:_DTHRGERNF" )
	
	//NFTS
	aadd( aTiposData, "_PEDIDOENVIONFTS:_NFTS:_DATAPRESTACAO" )

	//VALPARAISO DE GOIAIS 
	aadd( aTiposData, "_TCGRCNFSE:_TCINFNFSE:_TSDATEMSNFSE" )

	//FLORIANÓPOLIS
	aadd( aTiposData, "_XMLPROCESSAMENTONFPSE:_DATAEMISSAO" )

	//Itajaí-SC 
	aadd( aTiposData, "_GERARNFSERESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO" )

	//CANCELAMENTO
	aadd( aTiposData, "_CANCELARNFSERESPOSTA:_RETCANCELAMENTO:_NFSECANCELAMENTO:_CONFIRMACAO:_DATAHORA" )

	//Sorriso - MT
	aadd( aTiposData, "_GERARNFSERESPOSTA:_NFSE:_DATAEMISSAO" )
	aadd( aTiposData, "_CONSULTARNFSERPSRESPOSTA:_NFSE:_DATAEMISSAO" )

	//Maringá - PR DSERTSS2-8581
	aAdd(aTiposData, "_SDT_WS_001_OUT_GERA_NFSE_X_PNFSE:_WS_001_OUT_NFSE_DATA_HORA")
	
	oXML := XmlParser(cXML,"_",@cAviso,@cErro)
	
   	If oXML == Nil
		oXML := XmlParser(EncodeUtf8(cXML),"_",@cAviso,@cErro) 
	EndIf 
	
	//verifica se a data é separada
	nPosDia := aScan(aTiposDia,{|X| type("oXML:"+X) <> "U" }) 
	nPosMes := aScan(aTiposMes,{|X| type("oXML:"+X) <> "U" })
	nPosAno := aScan(aTiposAno,{|X| type("oXML:"+X) <> "U" })
	
	if nPosDia > 0 .and. nPosMes > 0 .and. nPosAno > 0 
		cConteuDia := "oXML:"+aTiposDia[nPosDia]+":TEXT" 
		cConteuMes := "oXML:"+aTiposMes[nPosMes]+":TEXT" 
		cConteuAno := "oXML:"+aTiposAno[nPosAno]+":TEXT"
	else
		//pega a data 
		nPosData := aScan(aTiposData,{|X| type("oXML:"+X) <> "U" })
	
		if nPosData > 0
			cConteudo := "oXML:"+aTiposData[nPosData]+":TEXT"
		endif 
		
	endif
	
	if !Empty(cConteuDia) .And. !Empty(cConteuMes) .And. !Empty(cConteuAno)
		cConteudo := (&(cConteuAno)+"/"+&(cConteuMes)+"/"+&(cConteuDia))
	else
		cConteudo :=&(cConteudo)
	endif
	
	if cConteudo == nil
		cConteudo := ""
	endif

	cRetData	:= substr(cConteudo,1,10)

	if lDataHora 
		If (cCodMun $ "4208203-4200101" .And. len(cConteudo) < 19 ) // TRATAMENTO PARA MAX LOTE
			cRetHora	:= substr(cConteudo,10,8) 
		Else
			cRetHora	:= substr(cConteudo,12,8) 
		EndIf	

	else	 //busca a hora na tag especifica para hora
 
		nPosHora := aScan(aTiposHora,{|X| type("oXML:"+X) <> "U" })
	
		if nPosHora > 0
			cRetHora := "oXML:"+aTiposHora[nPosData]+":TEXT"
		endif 
		
		cRetHora :=&(cRetHora)
					
		if cRetHora == nil
			cRetHora := ""
		endif
	endif	
	//DSERTSS2-8581
	If !(cCodMun $ "3205002|3554102|3530607-4104808-4214805-5221858-4123501-3524006-4205803-5007695-4200101-4309308-4301206") //DSERTSS2-8389 - Tratamento Itupeva (3524006)
		cRetData 	:= CTOD(SubStr(cRetData,9,2) + "/" + SubStr(cRetData,6,2)  + "/" + SubStr(cRetData,1,4))
	ElseIF cCodMun $ "5221858"
		cRetData 	:= CTOD(SubStr(cRetData,7,2) + "/" + SubStr(cRetData,5,2)  + "/" + SubStr(cRetData,1,4))
		cRetHora 	:= "00:00:00"
	ElseIF cCodMun $ "4200101"	.and. len(cRetData) < 11 //Tratamento ConsultaLote retornando sem hifen na data
		cRetData 	:= CTOD(SubStr(cRetData,7,2) + "/" + SubStr(cRetData,5,2)  + "/" + SubStr(cRetData,1,4))
	Elseif cCodMun $ "4104808-4214805-4123501-4205803-4309308-4301206"
		if Type("oXml:_RETORNO:_DATA_NFSE") <> "U"
			cRetData := cTod(oXml:_RETORNO:_DATA_NFSE:TEXT)
			cRetHora := oXml:_RETORNO:_HORA_NFSE:TEXT
		Elseif Type("oXml:_NFSE:_NF:_DATA_NFSE") <> "U"
			cRetData := cTod(oXml:_NFSE:_NF:_DATA_NFSE:TEXT)
			cRetHora := oXml:_NFSE:_NF:_HORA_NFSE:TEXT
		Else 
			cRetData := DATE()
			cRetHora := "00:00:00"
		endif
	Else
		cRetData 	:= CTOD(cRetData)
	EndIf
		
	aRet[1]	:= cRetData
	aRet[2]	:= cRetHora
	
	FreeObj(oXML)
	oXML := nil
	delClassIntF()
			
return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RefListBox
Função de atualização do aListBox relacionado ao monitor ao selecionar o 
refresh

@author Natalia Sartori
@since 02/01/2014
@version 1.0 

@param  oListBox,aListBox,bLineBkp,lUsaColab	

@Return
/*/
//-----------------------------------------------------------------------   
Function RefListBox(oListBox,aListBox,bLineBkp,lUsaColab)

	Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
	Local oNo			:= LoadBitMap(GetResources(), "DISABLE")
	Default lUsaColab	:= UsaColaboracao("3")
If !lUsaColab
oListBox:SetArray( aListBox )
	oListBox:bLine := {|| {	IIf( Empty(aListBox[ oListBox:nAT,5 ]), oNo, oOk ),;
											aListBox[ oListBox:nAT,2 ],;
											IIf( aListBox[ oListBox:nAT,3 ] == 1, STR0056, STR0057 ),; //"Produção"###"Homologação"
											STR0058,;															// Modalidade = "Normal"
											aListBox[ oListBox:nAT,5 ],;  									// Protocolo
											aListBox[ oListBox:nAT,1 ],;									// Cod. Ret
											aListBox[ oListBox:nAT,6 ],;									// Mensagem
											aListBox[ oListBox:nAT,7 ],;									// RPS
											aListBox[ oListBox:nAT,8 ]}}									// NFS-e

oListBox:Refresh()
Endif	

If lUsaColab	
	oListBox:SetArray( aListBox )
	oListBox:bLine := {|| {	IIf( Empty(aListBox[ oListBox:nAT,5 ]), oNo, oOk ),;						// Protocolo
											aListBox[ oListBox:nAT,2 ],;									// ID         = Serie + RPS
											IIf( aListBox[ oListBox:nAT,3 ] == 1, STR0056, STR0057 ),; // Ambiente   = "Produção"###"Homologação"
											STR0058,;															// Modalidade = "Normal"
											aListBox[ oListBox:nAT,5 ],;  									// Protocolo
											aListBox[ oListBox:nAT,1 ],;									// Cod. Ret
											aListBox[ oListBox:nAT,6 ],;									// Mensagem
											aListBox[ oListBox:nAT,7 ],;									// RPS
											aListBox[ oListBox:nAT,8 ]}}									// NFS-e

	oListBox:Refresh()	
Endif	

Return
/*/{Protheus.doc} Fis022ImpAIDF
Importação de arquivos  AIDF

@author Renato Nagib
@since 26.12.2013
@version 1.0 

@Return nil
				
/*/
//-----------------------------------------------------------------------
function Fis022ImpAIDF()

	local cTexto		:= STR0151	//"Este assistente tem por objetivo auxiliá-lo na importação de arquivos AIDF para emissão de RPS"	
	local cTexto2		:= STR0040
	local cArq			:= ""
	local cRetorno	:= ""
	
	DEFINE WIZARD oWizard ;
		TITLE STR0152;		//"Importação de arquivo AIDF"
		HEADER STR0153;	//"Assistente para importação de aquivo AIDF"
		MESSAGE "";
		TEXT cTexto ;
		NEXT {|| .T.} ;
		FINISH {|| .T.}
	
	CREATE PANEL oWizard  ;
		HEADER STR0153;	//"Assistente para importação de arquivo de AIDF"
		MESSAGE STR0154;	//"selecione o arquivo de AIDF a ser importado."
		BACK {|| .T.} ;
		NEXT {|| geraAIDF(cArq,@cRetorno)};
		FINISH {|| .T.};
		PANEL
				
		TButton():New( 090,020,STR0044,oWizard:oMPanel[2],{||cArq := cGetFile("Arquivos .AIDF|*.AIDF","Selecione o arquivo",0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[2]:oFont,,.T.,.F.,,.T., ,, .F.)
		@ 090,050 GET cArq SIZE 220,010 PIXEL OF oWizard:oMPanel[2]	
		
	CREATE PANEL oWizard  ;
		HEADER STR0153;	//"Assistente para importação de arquivo de AIDF"
		MESSAGE STR0155;	//"Importacao finalizada."
		BACK {|| .T.} ;		
		FINISH {|| .T.};
		PANEL
		@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
	ACTIVATE WIZARD oWizard CENTERED
	
return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} geraAIDF
gera tabela AIDF

@author Renato Nagib
@since 26.12.2013
@version 1.0 

@param cFile	nome do arquivo a ser importado 		
@param cRetorno	resultado da importacao

@Return .T.
				
/*/
//-----------------------------------------------------------------------
static function geraAIDF(cFile,cRetorno)
	
	local aAuxiliar	:= {}
	local aRegistro	:= {}
	local aTabela		:= {}	
	local aTemp		:= {}
	local cLinha	:= ""
	local cDel		:= ""
	local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	local cChave	:= ""
	local cNomeArquivo:= cFile
	local cBarra		:= if( !IsSrvUnix(), "\", "/")
	
	local lRecLock	:= .F.
	
	local nX := 0
	
	local cBloco := ""	
	//obtem o nome do arquivo para gravação 		
	while cBarra $ cNomeArquivo
		cNomeArquivo:= substr(cNomeArquivo,At(cBarra,cNomeArquivo)+1)
	end 
	//Estrutura da tabela
	aStruct := getStructAIDF(cCodMun)
	
	if AliasIndic("C0P")
		dbSelectArea("C0P")	
		C0P->(dbSetOrder(aStruct[1]))
		
		//monta chave de indice
		cIndice := C0P->(indexkey(aStruct[1]))	
		aChave:= StrTokArr(cIndice,"+")
		
		//Delimitador do arquivo txt a ser importado,implementar caso necessario 
		//cDel := getDel(cCodMun)
	
		if file(cFile)
			if FT_FUse(cFile) <> -1 .and. len(aStruct[2]) > 0
				FT_FGotop()
				begin Transaction
					While ( !FT_FEof() )
		
						cLinha := FT_FREADLN()
						if !validReg(cCodMun,cLinha)
							FT_FSkip()
							loop
						endif

						If cCodMun $ "3524006-3505906"
							aRegistro := StrTokArr(cLinha,"|")
							If 	aRegistro[1] == "H" 
								cBloco := aRegistro[3]
							EndIf
						elseif empty(cDel) 
							nX:= 1
							while !empty(cLinha) .and. nX <= len(aStruct[2])  
								aadd(aRegistro, subst(cLinha,1,aStruct[2][nX][3]) )
								cLinha := subst( cLinha,aStruct[2][nX][3] + 1)
								nX++ 
							end
	 
						else				
							aRegistro := StrTokArr(cLinha,cDel)										
						endif
			
						//Monta chave de indice para busaca do registro na tabela 	
						If	cCodMun $ "3524006-3505906"
							C0P->(DbSetOrder(2))
							cChave := xFilial("C0P")+cBloco+aRegistro[2]
						Else										
							for nX := 1 to len(aChave) 
								if "FILIAL" $ aChave[nX] 
									cChave += xFilial("C0P")
								else
									nPos := aScan(aStruct[2], {|X| alltrim(X[1]) $ aChave[nX] })
									if nPos > 0  .and. nPos <= len(aChave) 
										cChave += padr(aRegistro[nPos],TamSx3(aStruct[2][nPos][1])[1])
									endif	
								endif		
							next	
						EndIf	
			 			
						if !(C0P->(dbSeek(cChave)))	
							If cCodMun $ "3524006-3505906"
								If 	aRegistro[1] == "D" 
									reclock("C0P",.T.)
									lRecLock:=.T.
								Else
									lRecLock:=.F.									
								EndIf
							Else		
								reclock("C0P",.T.)
								lRecLock:=.T.
							EndIf
						elseif !C0P->C0P_AUT $ 'TS'
							reclock("C0P",.F.)								
						else
							lReclock := .F.								
						endif
						
						if lRecLock
							
							//Atualização da tabela
							C0P->C0P_FILIAL	:= xFilial("C0P")
							C0P->C0P_ARQ		:= strTran(upper(cNomeArquivo), ".AIDF", "")
							for nX := 1 to len(aRegistro)
								If nX <= len(aStruct[2])
									if valtype( C0P->&(aStruct[2][nX][1]) ) == "N"
										C0P->&(aStruct[2][nX][1]) := val(aRegistro[nX])
									elseif valtype( C0P->&(aStruct[2][nX][1]) ) == "D"
										C0P->&(aStruct[2][nX][1]) := stod(aRegistro[nX])										
									else
										C0P->&(aStruct[2][nX][1]) := aRegistro[nX]
										If cCodMun $ "3524006-3505906"
											C0P->&(aStruct[2][5][1])  := cBloco
										EndIf
									endif		
								EndIf
							next					
							
							C0P->(msunlock())
						endif
						
						FT_FSkip()
						cChave:= ""
						aRegistro:= {}
					EndDo
				end transaction	
	
				FT_FUse()
	
				cRetorno := STR0156	//"Arquivo importado com sucesso."
			else
				cRetorno:= STR0157	//"Erro na leitura do arquivo: " + STR(FERROR())	
			endif
	
		else		
			cRetorno:= STR0158	//"Arquivo não encontrado "
		endIf
		C0P->(dbGotop())
	else	
		cRetorno:= STR0159 + STR0160	//"Não foi possível realizar a importação do arquivo. + O compatibilizador para importação de arquivo AIDF não foi executado."		
	endif	
return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} getStructAIDF
valida registro para importação

@author Renato Nagib
@since 26.12.2013
@version 1.0 

@param cCodMun		codigo do Municipio 		

@Return aStruct	Estrutura da tabela para a importação
			aStruct[1]			indice da tabela
			aStruct[2]			campos da tabela
			aStruct[2][nX][1]	nome do campo
			aStruct[2][nX][2]	Tipo do campo
			aStruct[2][nX][3]	tamanho do campo para preenchimento
				
/*/
//-----------------------------------------------------------------------
Function getStructAIDF(cCodMun)

	local aStruct	:= {}
	
	do Case
		case cCodMun $ Fisa022Cod( "010" )
			aadd(aStruct, 1)//numero do indice da tabela
			aadd(aStruct, {})
			aadd(aTail(aStruct), { "C0P_TIPO"	, "C", 05, "Tipo" })
			aadd(aTail(aStruct), { "C0P_SEQ"	, "C", 06, "Sequncia" })			
			aadd(aTail(aStruct), { "C0P_RPS"	, "C", 10, "RPS" })
			aadd(aTail(aStruct), { "C0P_CHAVE"	, "C", 10, "Chave" })		
		case cCodMun $ "3524006-3505906" // Itupeva - SP
			aadd(aStruct, 1)//numero do indice da tabela
			aadd(aStruct, {})
			aadd(aTail(aStruct), { "C0P_TIPO"	, "C", 01, "Tipo" })
			aadd(aTail(aStruct), { "C0P_SEQ"	, "C", 08, "Sequencia" })
			aadd(aTail(aStruct), { "C0P_CHAVE"	, "C", 10, "Chave" })	
			aadd(aTail(aStruct), { "C0P_RPS"	, "C", 10, "RPS" })
			aadd(aTail(aStruct), { "C0P_BLOCO"	, "C", 08, "Bloco" })			
					
	endCase	
			
return aStruct
//-----------------------------------------------------------------------
/*/{Protheus.doc} validReg
valida registro para importação

@author Renato Nagib
@since 26.12.2013
@version 1.0 

@param cCodMun		codigo do Municipio 		
@param cLinha		linha do arquivo a ser validado

@Return lRet	validação da linha
				
/*/
//----------------------------------------------------------------------- 
static function validReg(cCodMun,cLinha)
	
	local lRet := .F.
	
	default cCodMun	:= ""
	default cLinha	:= ""
	
	if cCodMun $ Fisa022Cod( "010" )
		lRet := len(cLinha) == 31//registro valido para importacao
	ElseIf cCodMun $ '3524006-3505906'
		lRet := len(cLinha) == 94//registro valido para importacao
	endif

return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} Fis022DelImpAIDF
realiza a exclusão dos registros importado

@author Renato Nagib
@since 27.12.2013
@version 1.0 

@Return lRet	validação da linha
				
/*/
//----------------------------------------------------------------------- 
function Fis022DelImpAIDF()

	local aFiles := getFilesAIDF()
	
	local cTexto		:= STR0161	//"Este assistente tem por objetivo auxiliá-lo na Exclusão de importação de arquivos AIDF para emissão de RPS"	
	local cTexto2		:= STR0040
	local cArq			:= ""
	local cRetorno	:= ""
	local cCombo		:= ""
	
	local oCombo		:= nil
		
	DEFINE WIZARD oWizard ;
		TITLE STR0162;	//"Exclusão de importação de arquivo de AIDF"
		HEADER STR0163;	//"Assistente para Exclusão de importação de aquivo AIDF"
		MESSAGE "";
		TEXT cTexto ;
		NEXT {|| .T.} ;
		FINISH {|| .T.}
	
	CREATE PANEL oWizard  ;
		HEADER STR0163;	//"Assistente para exclusão de importação de arquivo de AIDF"
		MESSAGE STR0164;	//"selecione o arquivo de AIDF a ser excluído da importação."
		BACK {|| .T.} ;
		NEXT {|| delArqAIDF(cCombo,@cRetorno)};
		FINISH {|| .T.};
		PANEL
				
 		@ 090,050 COMBOBOX oCombo VAR cCombo ITEMS aFiles SIZE 120,010 OF oWizard:oMPanel[2] PIXEL 
	
	CREATE PANEL oWizard  ;
		HEADER STR0163;	//"Assistente para exclusão de importação de arquivo de AIDF"
		MESSAGE STR0165;	//"exclusão finalizada."
		BACK {|| .T.} ;		
		FINISH {|| .T.};
		PANEL		
		@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
	ACTIVATE WIZARD oWizard CENTERED
	
return

//-----------------------------------------------------------------------
/*/{Protheus.doc} delArqAIDF
realiza a exclusão dos registros importado

@author Renato Nagib
@since 27.12.2013
@version 1.0 

@param cCodMun		codigo do Municipio 		
@param cRetorno	mensagem de retorno do processamento

@Return lRet	retorno da rotina
				
/*/
//-----------------------------------------------------------------------
static function delArqAIDF(cFile, cRetorno)

	local cAlias := getNextAlias()
	
	local lOk := .F.
	
	local nCount := 0
	
	if AliasIndic("C0P")

		BeginSql Alias cAlias			
			SELECT R_E_C_N_O_ REC FROM %table:C0P% C0P	  
			WHERE C0P_ARQ = %exp:cFile% AND			 
			C0P.%notdel%
		EndSql
	
		if (cAlias)->(!eof())	
			Begin Transaction
				while (cAlias)->(!eof()) 
					C0P->(dbGoTo((cAlias)->REC))
					if C0P->C0P_AUT $ "TS" .and. !lOk
						if !msgYesNo(STR0166)	//"Um ou mais registros já foram utilizados para a emissão de RPS e não poderão ser excluídos.Deseja excluir os registros disponíveis para utilização? "
							disarmTransaction()
							exit
						endif
						lOk := .T.					
					else 
						if !C0P->C0P_AUT $ "TS"
							reclock("C0P")
							C0P->(dbDelete())
							C0P->(msUnlock())
							nCount++
						endif	
					endif	
					(cAlias)->(dbSkip())
				end		
				 
			end Transaction					
			
			cRetorno := STR0165 + CRLF + STR0167	+ cValtoChar(nCount) //"Exclusão finalizada."+CRLF+" Registros excluídos: " 
		else
			cRetorno := STR0168	//"Não há arquivos para exclusão."
		endif	
	
		(cAlias)->(dbCloseArea())
		C0P->(dbGotop())
	endif	
		
return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetFilesAIDF
retorna o nome dos arquivos importados para a tabla AIDF

@author Renato Nagib
@since 27.12.2013
@version 1.0 

 		
@param cRetorno	mensagem de retorno do processamento

@Return aArq	arquivos
				
/*/
//-----------------------------------------------------------------------
static function GetFilesAIDF()

	local aArq := {}
	
	local cAlias := getNextAlias()

	BeginSql Alias cAlias			
		SELECT DISTINCT(C0P_ARQ) ARQ FROM %table:C0P% C0P	  
		WHERE C0P.%notdel%
	EndSql
	
	if (cAlias)->(!eof())	
		while (cAlias)->(!eof()) 
			aadd(aArq, (cAlias)->ARQ)
			(cAlias)->(dbSkip())
		end						
	endif		
	(cAlias)->(dbCloseArea())
return aArq

//-----------------------------------------------------------------------
/*/{Protheus.doc} getAidfRps
retorna o proximo AIDF a ser emitido

@author Renato Nagib
@since 06.01.2014
@version 1.0 

@param cCodMun		codigo do Municipio 		



@Return aAIDF	informações do AIDF
				
/*/
//-----------------------------------------------------------------------
function getAidfRps(cCodmun, cSerie, cNota, cAviso)

	local aAIDF	:= {" "," "," "} // Cria com 3 posiçoes 
	local aStruct	:= {}
	local cNItu	:= cNota
	local lTrans	:= .F.
	
	
	
	aStruct := getStructAIDF(cCodMun)	 
	
	cAviso := ""
		
	if AliasIndic("C0P") 
		cNota := cValToChar(val(cNota))
		C0P->(dbSetOrder(aStruct[1]))
		
		If cCodMun $ "3524006-3505906"
			cNota := "0"
			
			lTrans := C0P->(dbSeek(xFilial() + cNItu)) .OR. (!C0P->(dbSeek(xFilial() + cNItu)) .AND. C0P->(dbSeek(xFilial() + cNota)))
		Else
			lTrans := C0P->(dbSeek(xFilial() + cNota))
		EndIf
	
		if lTrans
			
			if !C0P->C0P_AUT $ "T|S"				 
			aAIDF	:= {} // Zera array
				If cCodMun $ "3524006-3505906"   
					aadd(aAIDF,C0P->C0P_CHAVE)
					aadd(aAIDF,C0P->C0P_BLOCO)
					aadd(aAIDF,C0P->C0P_SEQ)					
				Else
					aadd(aAIDF,C0P->C0P_CHAVE)
					aadd(aAIDF,cSerie)	
					aadd(aAIDF,str(C0P->C0P_RPS))
				EndIf			
			Else
				cAviso := CRLF + "Uma ou mais notas não transmitidas.AIDF já emitido."
			endif		
		else
			cAviso := CRLF + "Uma ou mais notas não transmitidas.AIDF não encontrado."
		endif
	endif		
return aAIDF

//-----------------------------------------------------------------------
/*/{Protheus.doc} UsaAidfRps
retorna se utiliza AIDF 

@author Karyna Rainho
@since 05.02.2014
@version 1.0 

@param cCodMun		codigo do Municipio 		


@Return lRet	
				
/*/
//-----------------------------------------------------------------------
function UsaAidfRps(cCodmun)

Local lRet := .F.
 
If (cCodmun $ Fisa022Cod( "010" ) + "-3524006-3505906" ) .and. !( cCodmun $ "5221858" )
	lRet := .T. 
EndIf 
 
Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaRps
retorna se utiliza AIDF 

@author Karyna Rainho
@since 05.02.2014
@version 1.0 

@param cCodMun		codigo do Municipio 		


@Return lRet	
				
/*/
//-----------------------------------------------------------------------
function GravaRps(cCodmun)

Local lRet := .F.
 
If cCodmun $ "3524006-3505906"
	lRet := .T. 
EndIf 
 
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} Fis022viewAIDF
visualização e manutenção da tabela de AIDF

@author Renato Nagib
@since 17.01.2014
@version 1.0 

@param 	

@Return nil
				

/*/
//-----------------------------------------------------------------------
Function Fis022viewAIDF( )

Local oBrow 
Local cPict		:= ""   
local cFile		:= "C0P"
local cCombo	:= ""
local cChave	:= ""
Local i    
Local aTables
local lC0P		:= .F.

//---------------------------------------------------------
//- Verifica a existencia da tabela C0P - Tabela de AIDF
//---------------------------------------------------------
if( chkFile( cFile ) )
	lC0P := .T.
else
	alert( STR0244 )  //"'C0P - Tabela de AIDF' inexistente. Por favor, atualize o dícionario de dados."
endIf

if( lC0P )
	cChave := space( tamSX3( "C0P_FILIAL" )[ 1 ] + tamSX3( "C0P_RPS" )[ 1 ] )
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 456,900 PIXEL
	
	oBrow := TCBrowse():New(014,001,450,190,,,,oDlg,,,,{||},,,,,,,,.F.,cFile,.T.,,.F.,,)
	
	oBrow := oBrow:GetBrowse()
	
	aStruBkp := (cFile)->(dbStruct())
	SX3->(dbSetOrder(2))
	For i:= 1 to Len(aStruBkp)
		SX3->(dbSeek(aStruBkp[i][1]))
		
		//If aStruBkp[i][1] <> "C0P_AUT"
			cPict := ""
			If aStruBkp[i][2] == "N"
				cPict  := Replicate("9",aStruBkp[i][3])
				If aStruBkp[i][4] >0
					cPict := Left(cPict,aStruBkp[i][3]-aStruBkp[i][4]) + "." + Right(cPict,aStruBkp[i][4])
				EndIf
			EndIf
			oBrow:AddColumn(TCColumn():New( X3Titulo(), &("{ || "+cFile+"->"+aStruBkp[i][1]+"}"),cPict ,,, , , .F., .F.,,,, .F.,))
		/*	
		Else
			oBrow:AddColumn(TCColumn():New( X3Titulo(), { || if((cFile)->&(aStruBkp[i][1])$ "TS", "Emitido","Disponivel")}, ,,, , , .F., .F.,,,, .F.,))
		EndIf*/
	Next
	i:=1
	
	oBrow:lColDrag   := .T.
	oBrow:lLineDrag  := .T.
	oBrow:lJustific  := .T.
	oBrow:nfreeze    := 1
	//oBrow:blDblClick := {||SduEdit(.F.)}
	oBrow:nColPos    := 1
	
	oBrow:Refresh()
	//SduShowMsg(oTabs:nOption) 
	
	@ 002,001 COMBOBOX oCombo VAR cCombo ITEMS {"Filial+Rps"} SIZE 080,010 OF oDlg PIXEL //"Formato Apache(.pem)"###"Formato PFX(.pfx ou .p12)"###"HSM"
	@ 002,084 MSGET oChave VAR cChave SIZE 100,008 OF oDlg PIXEL 
	@ 002,184 BITMAP RESNAME "PARAMETROS" OF oDlg SIZE 024,018 NOBORDER  PIXEL
	oBtPesquisar := TButton():New( 002, 198, STR0004,oDlg,{|| (lContinua := .T.,C0P->(dbSeek(cChave)))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Pesquisar"
	oBtImportar := TButton():New( 210, 309, STR0278,oDlg,{|| (lContinua := .T.,Fis022ImpAidf())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Importar"
	oBtExcluir := TButton():New( 210, 356, STR0279,oDlg,{|| (lContinua := .T.,Fis022DelImpAidf())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Excluir"
	oBtSair := TButton():New( 210, 403, STR0280,oDlg,{|| (lContinua := .T.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Sair"
	ACTIVATE MSDIALOG oDlg CENTERED
endIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MunUsaUrl
Funcao que verifica se o municipio retorna a URL da NFs-e.

@param		cCodmun	Código do Municipio.
						
@Return 	lUsaUrl	.T. quando municipio utilizar URL.

@author	Rafael Iauquinto
@since		23/05/2014
@version	12
/*/
//-------------------------------------------------------------------
function MunUsaUrl( cCodmun )
local	 lUsaUrl := .F.
Default cCodMun := SM0->M0_CODMUN

if (GetMunSiaf(cCodMun)[1][2] $ "012" .or. superGetMV( "MV_NFSLINK", .F., .F. )) .and. !(cCodMun == "2927408" .and. cEntSai == "0")
	lUsaUrl	:= .T.
endif

return lUsaUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis22UrlNfse
Funcao que verifica se o municipio retorna a URL da NFs-e.

@param		cCodmun	Código do Municipio.
						
@Return 	lUsaUrl	.T. quando municipio utilizar URL.

@author	Rafael Iauquinto
@since		23/05/2014
@version	12
/*/
//-------------------------------------------------------------------
Function Fis22UrlNfse( cAlias )

local cSerie
local cIdInicial
local cIdFinal
local nTipoMonitor := 2
local aMonitor	:= {}

If cAlias == "SF2"  
	cSerie 	:= SF2->F2_SERIE
	cIdInicial	:= SF2->F2_DOC
	cIdFinal 	:= SF2->F2_DOC		
ElseIf cAlias == "SF1"
	cSerie 	:= SF1->F1_SERIE
	cIdInicial	:= SF1->F1_DOC
	cIdFinal 	:= SF1->F2_DOC  
EndIf

Processa( {|| aMonitor 	:= FisMonitorX( cIdEnt, cSerie, cIdInicial, cIdFinal, /*cCNPJIni*/, /*cCNPJFim*/, /*nTipoMonitor*/, /* dDataDe */, /* dDataAte */, /* cHoraDe */, /* cHoraAte */, /* nTempo */, /* nDiasParaExclusao */, /* cIdNotas */, "" )}, "Aguarde...","(1/2) Buscando URL...", .T. )

if Len( aMonitor[3] ) > 0 .And. !Empty( aMonitor[3][1][10] )
	ShellExecute( "Open", Alltrim( aMonitor[3][1][10] ), "", "", 1 )	
else
	MsgAlert(STR0245)  //"URL para o documento não foi encontrada, verifique se o documento está autorizado!"
endif


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis022Par
Funcao Configura o Ambiente para TOTVS Colaboracao - NFs-e.

@author	Flavio Luiz Vicco
@since		06/08/2014
@version	1.0
/*/
//-------------------------------------------------------------------
Function Fis022Par()

//-- REALIZA A CONFIGURACAO DOS PARAMETRO DO TOTVS COLABORACAO 2.0
	ColParametros("NFS")

Return Nil

static function UsaColaboracao(cModelo)
Local lUsa := .F.
Local cMV_TCNEW := SuperGetMv( "MV_TCNEW" , .F. , "" ,  )
Private cEntSai := '0'

if IsBlind() .or. "0" $ cMV_TCNEW .or. "3" $ cMV_TCNEW
	cEntSai := '1'
EndIf
If cEntSai $ '1'
If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
	endif
endif
return (lUsa)

//-------------------------------------------------------------------
/*/{Protheus.doc} execMonitor
Funcao responsavel por controlar o monitoramento dos documentos selecionados no botao Monitor da rotina Fisa022.

Todos os documentos requisitados na rotina de monitoramento serao enviados ao TSS com o objetivo de obter o
status de cada documento. Devido a limitacao de 1mb do arquivo xml retornado pelo web service, podera haver
a necessidade de repetir esta requisicao por diversas vezes ao TSS.

Esta funcao somente deixara de enviar pacotes ao TSS quando nao houver mais retorno do metodo MonitorX, ou
seja, enquanto houver retorno do web service a rotina continuara consultando o TSS.

Foi estabelecido uma regra de 30 documentos ou mais para que a rotina emita um aviso ao usuario indicando
uma possivel demora no processo devido a quantidade selecionada para monitoramento. 

@param		cIdEnt		Codigo da entidade corrente
@param		cSerie		Serie dos documentos que serao monitorados
@param		cCNPJIni	CNPJ inicial no caso de monitoramento dos documentos de entrada
@param		cCNPJFim	CNPJ final no caso de monitoramento dos documentos de entrada
@param		cMod004		Codigo relacionado ao modelo 004
@param		aIdNotas	Array com todos os documentos que devem ser monitorados
@param		aListBox	Deve ser enviado como referencia, pois este array sera manipulado dentro da funcao para receber o resultado do monitoramento

@author		Luccas Curcio
@since		19/09/2014
@version	1.0
/*/
//-------------------------------------------------------------------
Static Function execMonitor( cIdEnt , cSerie , cCNPJIni , cCNPJFim, dDataIni, dDataFim , cMod004 , aIdNotas , aListBox, cFornec, cLoja )

local	lKeepProcess	:=	.T.
local	nPosIdNotas		:=	0
local	nInicial		:=	1
local	nX				:=	0
local	aLote			:=	{}
local	nLote			:=	0
local	aListBoxTmp		:=	{ .F. , "" , {} }
local	aRetListBox		:=	{}

if len( aIdNotas ) > 30
	//"Foi selecionada uma grande quantidade de documentos para monitoramento. Devido a isso a consulta será mais lenta e poderá demorar alguns minutos."
	//"Sugerimos que seja selecionado um range mais específico de documentos."
	//"Deseja continuar?"
	lKeepProcess := MsgYesNo( STR0171 + CRLF + CRLF + STR0172 + CRLF + CRLF + STR0173 ) 
endif

procRegua( recCount() )

while lKeepProcess
	//reseta conteudo do lote a ser consultado no TSS
	aLote	:=	{}
	nLote	:=	0
	
	for nX := nInicial to len( aIdNotas )
	
		nLote++
		
		//verifica se o documento ja foi retornado pelo TSS
		if !( aIdNotas[ nX , 2 ] )
			//adiciona o documento ao lote
			aAdd( aLote, aIdNotas[ nX , 1 ] )
		endif
		
		If nLote == 30
			Exit
		Endif
		
	next
	
	nInicial := ( nX + 1 )
	
	//consulta os documentos no TSS
	aRetListBox := MonitorNFSE( cIdEnt, cSerie, aLote, cCNPJIni, cCNPJFim, cMod004, dDataIni, dDataFim, /*lUsaColab*/ , cFornec, cLoja)
			
	for nX := 1 to len( aRetListBox[ 3 ] )
		
		aAdd( aListBoxTmp[ 3 ] , aRetListBox[ 3 , nX ] )
		
		//procura o documento no array aIdNotas
		//nPosIdNotas := aScan( aIdNotas , { |x| Val(x[ 1 ]) == Val(aRetListBox[ 3 , nX , 7 ]) } ) 
        nPosIdNotas := aScan( aIdNotas , { |x| x[1] $ aRetListBox[3 , nX , 2]})

		If nPosIdNotas > 0
			//altera o flag do documento no array aIdNotas
			aIdNotas[ nPosIdNotas , 2 ] := .T.
		EndIf
	next

	aListBoxTmp[1] := ( Len( aListBoxTmp[ 3 ] ) > 0 )
	aListBoxTmp[2] := iif( !empty( aRetListBox[ 2 ] ) .and. !empty( aListBoxTmp[ 2 ] ) , aRetListBox[ 2 ] , "" )
	
	if ( empty( aRetListBox[3] ) )
	
		If nInicial >= Len( aIdNotas )
			lKeepProcess	:= .F.
		Endif

		aListBox[ 3 ]	:= aClone( aListBoxTmp[ 3 ] )
		aListBox[ 1 ]	:= len( aListBox[3] ) > 0
		aListBox[ 2 ]	:= iif( !Empty( aListBoxTmp[2] ), aListBoxTmp[2], "" )

	endif

end

return aListBox

//-------------------------------------------------------------------
/*/{Protheus.doc} Fis022CRPS
Funcao para consurtar RPS caso a nota esteja autorizada na prefeitura
e no protheus estiver como rejeitada.

@author		Leonardo Kichitaro
@since		19/03/2015
@version	1.0
/*/
//-------------------------------------------------------------------
Function Fis022CRPS()

Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cCodMun		:= Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ))
Local cMsgRet	:= ""
Local cStatusCon:= ""
Local lUsaColab	:= UsaColaboracao("3")
Local aParam	:= {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(14),Space(14)}
Local aMonitor	:= {}

Local cAviso	:= ''
Local cErro		:= ''
Local cXmlRet	:= Nil



Private oWS		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do WebService da NFS-e                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !lUsaColab .And. !Empty(cURL)
oWS := WsNFSE001():New()

oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnt
oWS:_URL		:= AllTrim(cURL)+"/NFSE001.apw"
oWS:cCODMUN		:= cCodMun
oWS:cTSSID		:= SF2->F2_SERIE+SF2->F2_DOC
oWS:cNUMERORPS	:= allTrim( str( val( SF2->F2_DOC ) ) )
oWS:cSERIERPS	:= SF2->F2_SERIE

lOk := ExecWSRet(oWS,"TSSConsRPSNFSE")
endif
If (lOk)
	aParam[1] 	:= SF2->F2_SERIE
	aParam[2] 	:= SF2->F2_DOC
	aParam[3]	:= SF2->F2_DOC

	aMonitor	:= WsNFSeMnt( cIdEnt, aParam, lUsaColab )
	If cCodMun == '3203205'
		cXmlRet := IIf( Type( 'oWS:oWsTssConsRPSNfseResult:cXmlRetPref' ) <> 'U', oWS:oWsTssConsRPSNfseResult:cXmlRetPref, '' )
	 	oXml := XmlParser( cXmlRet, "_", @cAviso, @cErro )
		
		If !( Empty( cAviso + cErro ) ) //Erro no Parser
			Aviso(STR0174,cMsgRet,{STR0114})
		Else
			If !Empty( oXml:_Return:_NfeRpsNotaFiscal:_IdNota:Text )
				cMsgRet += "Codigo de autorização: "+ AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_IdNota:Text )+CRLF
			EndIf

			If !Empty( oXml:_Return:_NfeRpsNotaFiscal:_Numero:Text )
				cMsgRet += "Numeração da nota prefeitura: "+AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Numero:Text )+CRLF
			EndIf

			If !Empty( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text )
				If AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text ) == 'A'
					cStatusCon := "Autorizado"
				ElseIf 	AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text ) == 'N'
					cStatusCon := "Normal"
				ElseIf 	AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text ) == 'C'
					cStatusCon := "Cancelado"
				ElseIf 	AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text ) == 'S'
					cStatusCon := "Substituido"
				ElseIf 	AllTrim( oXml:_Return:_NfeRpsNotaFiscal:_Situacao:Text ) == 'I'
					cStatusCon := "Inexistente"
				Else
					cStatusCon := "Outros"
				EndIf
				
				cMsgRet += "Status: "+cStatusCon
			EndIf

			Aviso(STR0174,cMsgRet,{STR0114})			
		EndIf

	Else
		If !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CCODIGOAUTH)
			cMsgRet += "Codigo de autorização.: "+AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CCODIGOAUTH)+CRLF
		EndIf

		If !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CNOTA)
			cMsgRet += "Numeração da nota prefeitura.: "+AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CNOTA)+CRLF
		EndIf

		If !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CRPS) .and. !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CSERIERPS)
			cMsgRet += "Numero da RPS / Série.: " + AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CRPS) + " / " + AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSERIERPS) + CRLF
		ElseIf !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CSERIERPS)
			cMsgRet += "Série da RPS.: "+AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSERIERPS)+CRLF
		EndIf

		If !Empty(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE)
			If AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE) $ 'A-Ativa'
				cStatusCon := "Autorizado"
			ElseIf 	AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE) == 'N'
				cStatusCon := "Normal"
			ElseIf 	AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE) $ 'C-Cancelada'
				cStatusCon := "Cancelado"
			ElseIf 	AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE) == 'S'
				cStatusCon := "Substituido"
			ElseIf 	AllTrim(oWS:OWSTSSCONSRPSNFSERESULT:CSTATUSNFSE) == 'I'
				cStatusCon := "Inexistente"
			Else
				cStatusCon := "Outros"
			EndIf
			
			cMsgRet += "Status: "+cStatusCon
		EndIf

		Aviso(STR0174,cMsgRet,{STR0114},3)

	EndIf
Else
	cMsgRet := GetWscError(3)
	alert(allTrim(cMsgRet))
EndIf

	FreeObj(oWS)
	oWS := nil
	delClassIntF()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NFSeExport³ Autor ³Karyna Morato          ³ Data ³02.03.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de exportacao das notas de serviço eletronicas       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NFSeExport()

Local cIdEnt   	 := ""
Local aPerg   	 := {}
Local aParam  	 := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD(""),CToD("")}
Local cParNfeExp := if( type( "oSigamatX" ) == "U",SM0->M0_CODIGO + SM0->M0_CODFIL + "SPEDNFSEEXP",oSigamatX:M0_CODIGO + oSigamatX:M0_CODFIL + "SPEDNFSEEXP" )


aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.F.}) //"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
aadd(aPerg,{6,STR0119,aParam[04],"",".T.","!Empty(mv_par04)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.F.}) //"Diretório de destino"
//aadd(aPerg,{1,STR0141,aParam[05],"",".T.","",".T.",50,.F.}) //"Data Inicial"
//aadd(aPerg,{1,STR0142,aParam[06],"",".T.","",".T.",50,.F.}) //"Data Final"

aParam[01] := ParamLoad(cParNfeExp,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeExp,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeExp,aPerg,3,aParam[03])
aParam[04] := ParamLoad(cParNfeExp,aPerg,4,aParam[04])
//aParam[05] := ParamLoad(cParNfeExp,aPerg,5,aParam[05])
//aParam[06] := ParamLoad(cParNfeExp,aPerg,6,aParam[06])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
cIdEnt := GetIdEnt()
If !Empty(cIdEnt)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Instancia a classe                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cIdEnt)
	
		If ParamBox(aPerg,STR0246,@aParam,,,,,,,cParNfeExp,.T.,.T.)  //"NFSe - Retorno da prefeitura"
  			
			Processa({|lEnd| SpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04])},"Processando","Aguarde, exportando arquivos",.F.)
                
		EndIf
		
	EndIf
	
Else
	Aviso(STR0261,STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf


Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedPExp³ Autor ³Karyna Morato          ³ Data ³02.03.2008³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de exportacao das notas de serviço eletronicas       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest)

Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
Local cDestino 	:= ""
Local cDrive   	:= ""
Local cIdflush  := cSerie+cNotaIni
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cXml		:= ""
Local cNota 	:= cNotaIni // Recebe a nota inicial
Local cFile	:= "" // Recebe o caminho e o arquivo a ser gravado
Local cProc	:= ""

Local nHdl 	:= 0


Default cNotaIni:=""
Default cNotaFim:=""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrigi diretorio de destino                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SplitPath(cDirDest,@cDrive,@cDestino,"","")
cDestino := cDrive+cDestino


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia processamento                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While Val(cNota) <= Val(cNotaFim)

	ProcRegua(Val(cNota))
	
	cIdflush  := cSerie+cNota
	
	oWS := WsNFSE001():New()
	oWS:cUSERTOKEN            := "TOTVS"
	oWS:cID_ENT               := cIdEnt
	oWS:cCodMun               := cCodMun
	oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
	oWS:nDIASPARAEXCLUSAO     := 0
	oWS:OWSNFSEID:OWSNOTAS    := NFSe001_ARRAYOFNFSESID1():New()
	      
	aadd(oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1,NFSE001_NFSES1():New())
	oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CCODMUN  := cCodMun
	oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cID      := cIdflush
	oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cXML     := " "
	oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CNFSECANCELADA := " "               
	
	If ExecWSRet(oWS,"RETORNANFSE")
	
		If Len(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5) > 0
		
			cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLPROT)
			If !Empty(cXml)
			
				cFile := Alltrim(MV_PAR04) + "NFSe_" + Alltrim(cSerie) + AllTrim(cNota) + ".XML"
									
				nHdl  :=	MsFCreate (cFile)
	
				If ( nHdl >= 0 )
					FWrite (nHdl, cXml)
					FClose (nHdl)					
					cProc += AllTrim(cNota) +" Série: " + AllTrim(cSerie) +" | XML - Emissão." + CRLF	
				EndIf						
				
			EndIf

			//Tratamento para geração do XML Cancelado.FDL.

			If Type( "oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT" ) <> "U"
				cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT)
				If !Empty(cXml)
				
					cFile := Alltrim(MV_PAR04) + "NFSe_Cancelada_" + Alltrim(cSerie) + AllTrim(cNota) + ".XML"
										
					nHdl  :=	MsFCreate (cFile)
		
					If ( nHdl >= 0 )
						FWrite (nHdl, cXml)
						FClose (nHdl)					
						cProc += AllTrim(cNota) +" Série: " + AllTrim(cSerie) +" | XML - Cancelado." + CRLF	
					EndIf						
					
				EndIf
			EndIf	
		EndIf
	
	EndIf
	
	cNota := soma1(alltrim(cNota))
	
EndDo	

If !Empty(cProc)

	Aviso(STR0247,STR0248 + CRLF + cProc,{"OK"},3) //"XML de Retorno da Prefeitura"-"XML gerado das notas:"
	
EndIf

	FreeObj(oWS)
	oWS := nil
	delClassIntF()

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TitIssRet
Funcao para retornar titulos de ISS retido pagos no mes da geracao.

@author		Leonardo Kichitaro
@since		13/07/2015
/*/
//-------------------------------------------------------------------
Static Function TitIssRet(aRemessa,dDataIni,dDataFim,cSerieIni,cSerieFim,cNotaIni,cNotaFin)

Local aArea		:= GetArea()
Local bCondicao	:= Nil
Local aRet		:= {}
Local aMVTitNFT	:= &(GetNewPar("MV_TITNFTS","{}"))
Local cAliasTit	:= "SE2"
Local cCodTit	:= ""
Local lTopDbf	:= .T.
Local nX		:= 0
Local nY		:= 0
Default dDataIni	:= CTOD("  /  /    ")
Default dDataFim	:= CTOD("  /  /    ")

for nX := 1 to 2 
	aAuxTit := aMVTitNFT[nX]
	for nY := 1 to len( aAuxTit )
		cCodTit += "'"+aAuxTit[nY]+"'"+","
	next nY
next nX

cCodTit := SUBSTR(cCodTit,1,RAT(",",cCodTit)-1)

If Empty(dDataIni)
	dDataIni := CTOD("  /  /    ")
EndIf

#IFDEF TOP

	lTopDbf	:= .T.

	cAliasTit := GetNextAlias()

	cWhere := "%"
	cWhere += "SE2.E2_TIPO IN ("+cCodTit+") AND SE2.E2_ISS > 0 AND SF3.F3_RECISS = '2'"	
	cWhere += "%"

 	BeginSql Alias cAliasTit

	SELECT SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA,SF3.R_E_C_N_O_ RECNOSF3
		FROM %Table:SE2% SE2
		JOIN %Table:SF3% SF3 ON
		     SF3.F3_FILIAL = SE2.E2_FILIAL AND
		     SF3.F3_SERIE = SE2.E2_PREFIXO AND
		     SF3.F3_NFISCAL = SE2.E2_NUM AND
		     SF3.F3_CLIEFOR = SE2.E2_FORNECE AND
		     SF3.F3_LOJA = SE2.E2_LOJA
			WHERE
			SE2.E2_FILIAL 	 = %xFilial:SE2% AND
			SE2.E2_BAIXA 	>= %Exp:dtos(dDataIni)% AND 
			SE2.E2_BAIXA 	<= %Exp:dtos(dDataFim)% AND 
			SE2.E2_PREFIXO 	>= %Exp:cSerieIni% AND 
			SE2.E2_PREFIXO	<= %Exp:cSerieFim% AND 
			SE2.E2_NUM		>= %Exp:cNotaIni% AND 
			SE2.E2_NUM		<= %Exp:cNotaFin% AND
			%Exp:cWhere% AND
			SE2.%notdel%
	EndSql

#ELSE

	lTopDbf	:= .F.

	(cAliasTit)->( dbSetOrder(5) )

	bCondicao := {||	SE2->E2_FILIAL	== xFilial("SE2") .And. ;
						SE2->E2_BAIXA	>= dDataIni .And. ;
						SE2->E2_BAIXA	<= dDataFim .And. ;
						SE2->E2_TIPO	$  cCodTit .And. ;
						SE2->E2_ISS		>  0 }

	(cAliasTit)->(DbSetFilter(bCondicao,""))

	(cAliasTit)->(dbGotop())

#ENDIF

While (cAliasTit)->(!Eof())
	If aScan(aRemessa,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasTit)->E2_PREFIXO+(cAliasTit)->E2_NUM+(cAliasTit)->E2_FORNECE+(cAliasTit)->E2_LOJA}) == 0
		If lTopDbf
			aAdd(aRet,{(cAliasTit)->RECNOSF3,(cAliasTit)->E2_PREFIXO,(cAliasTit)->E2_NUM,(cAliasTit)->E2_PARCELA,(cAliasTit)->E2_TIPO,(cAliasTit)->E2_FORNECE,(cAliasTit)->E2_LOJA})
		Else
			SF3->(dbSetOrder(4))
			If SF3->(dbSeek(xFilial("SF3")+(cAliasTit)->E2_FORNECE+(cAliasTit)->E2_LOJA+(cAliasTit)->E2_NUM+(cAliasTit)->E2_PREFIXO))
				aAdd(aRet,{SF3->(Recno()),(cAliasTit)->E2_PREFIXO,(cAliasTit)->E2_NUM,(cAliasTit)->E2_PARCELA,(cAliasTit)->E2_TIPO,(cAliasTit)->E2_FORNECE,(cAliasTit)->E2_LOJA})
			EndIf
		EndIf
	EndIf

	(cAliasTit)->(dbSkip())
EndDo

SE2->(DBClearFilter())

If lTopDbf
	(cAliasTit)->(dbCloseArea())
EndIf

RestArea(aArea)
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IdNfRet
Funcao para retornar notas que existem na base realmente

@author		Leonardo Kichitaro
@since		14/09/2015
/*/
//-------------------------------------------------------------------
Static Function IdNfRet( aParam )
Local aArea			:= GetArea()
Local aRetNf		:= {}
Local cAliasSF3		:= "SF3"
Local lTopDbf		:= .T.
Local cWhere		:= ""
Local cValIdInicial := ""

if( cEntSai == "0" )
	cWhere := "%SF3.F3_NFISCAL BETWEEN '"+ aParam[ 2 ] +"' AND '"+ aParam[ 3 ] +"' AND "
	cWhere += "SF3.F3_ENTRADA BETWEEN '"+ dtos( aParam[ 6 ] ) +"' AND '"+ dtos( aParam[ 7 ] ) +"'"

	If !Empty(aParam[8])
		cWhere += " AND SF3.F3_CLIEFOR ='"+aParam[ 8 ] +"'" // SF3.F3_CLIEFOR = %Exp:aParam[ 8 ]% AND // luna
	EndIf
	
	If !Empty(aParam[9])
		cWhere += "AND SF3.F3_LOJA ='"+aParam[ 9 ] +"'" // SF3.F3_LOJA = %Exp:aParam[ 9 ]% AND // luna
	EndIf
	cWhere +=  "%"
else
	cWhere := "%SF3.F3_NFISCAL BETWEEN '"+ aParam[ 2 ] +"' AND '"+ aParam[ 3 ] +"'%"
endIf

//O bloco abaixo ira validar se o CNPJInicial é maior que o CNPJFinal e manipucar para nao gerar a mensagem de Nao ha dados
//Criado para validar NFTS quando for numero e serie igual e fornecedor diferente DSERTSS2-10320
IF(cEntSai == "0" .and. len(aParam) >= 5 )
	IF(aParam[4] > aParam[5] )
		cValIdInicial := aParam[4]
		aParam[4] := aParam[5]
		aParam[5] := cValIdInicial
	ENDIF
ENDIF

#IFDEF TOP

	lTopDbf	:= .T.

	cAliasSF3 := GetNextAlias()

	If Alltrim( TCGetDB()) $ "ORACLE" .or. AllTrim(Upper(TcGetDb())) $ "POSTGRES"
	
		if( cEntSai == "0" )
			BeginSql Alias cAliasSF3
			SELECT ( SF3.F3_NFISCAL || SA2.A2_CGC ) AS F3_NFISCAL
				FROM %Table:SF3% SF3
				JOIN %Table:SA2% SA2 ON
					SA2.A2_FILIAL = %xFilial:SA2% AND
					SA2.A2_COD = SF3.F3_CLIEFOR AND
					SA2.A2_LOJA = SF3.F3_LOJA AND
					SA2.A2_CGC BETWEEN %Exp:aParam[ 4 ]% AND %Exp:aParam[ 5 ]% AND
					SA2.%notdel%
				WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:aParam[ 1 ]% AND
					%Exp:cWhere% AND
					SF3.%notdel%
			EndSql
		else
			BeginSql Alias cAliasSF3
			SELECT SF3.F3_NFISCAL
				FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:aParam[ 1 ]% AND
					%Exp:cWhere% AND
					SF3.%notdel%
			EndSql
		endIf
	else
		if( cEntSai == "0" )
			BeginSql Alias cAliasSF3
			SELECT ( SF3.F3_NFISCAL + SA2.A2_CGC ) AS F3_NFISCAL
				FROM %Table:SF3% SF3
				JOIN %Table:SA2% SA2 ON
					SA2.A2_FILIAL = %xFilial:SA2% AND
					SA2.A2_COD = SF3.F3_CLIEFOR AND
					SA2.A2_LOJA = SF3.F3_LOJA AND
					SA2.A2_CGC BETWEEN %Exp:aParam[ 4 ]% AND %Exp:aParam[ 5 ]% AND
					SA2.%notdel%
				WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:aParam[ 1 ]% AND
					%Exp:cWhere% AND
					SF3.%notdel%
			EndSql
		else
			BeginSql Alias cAliasSF3
			SELECT SF3.F3_NFISCAL
				FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:aParam[ 1 ]% AND
					%Exp:cWhere% AND
					SF3.%notdel%
			EndSql
		EndIf	
	EndIf
#ELSE

	lTopDbf	:= .F.

	(cAliasSF3)->( dbSetOrder(5) )
	if( cEndSai == "0" )
		bCondicao := {||	SF3->F3_FILIAL	== xFilial("SF3") .And. ;
							SF3->F3_SERIE	== aParam[ 1 ] .And. ;
							SF3->F3_NFISCAL	>= aParam[ 2 ] .And. ;
							SF3->F3_NFISCAL	<= aParam[ 3 ] .and. ; 
							SF3->F3_ENTRADA	>= dtos( aParam[ 6 ] ) .and. ;
							SF3->F3_ENTRADA	<= dtos( aParam[ 7 ] ) }
	else
		bCondicao := {||	SF3->F3_FILIAL	== xFilial("SF3") .And. ;
							SF3->F3_SERIE	== aParam[ 1 ] .And. ;
							SF3->F3_NFISCAL	>= aParam[ 2 ] .And. ;
							SF3->F3_NFISCAL	<= aParam[ 3 ] }
	endIf
	
	(cAliasSF3)->(DbSetFilter(bCondicao,""))
	(cAliasSF3)->(dbGotop())

#ENDIF

While (cAliasSF3)->(!Eof())
	aAdd(aRetNf,{ AllTrim((cAliasSF3)->F3_NFISCAL) , .F. })

	(cAliasSF3)->(dbSkip())
EndDo

SF3->(DBClearFilter())

If lTopDbf
	(cAliasSF3)->(dbCloseArea())
EndIf

RestArea(aArea)

Return aRetNf

//-------------------------------------------------------------------
/*/{Protheus.doc} NoAcento
Retira acentos das strings

@author		Gustavo G. Rueda
@since		22.03.2011
/*/
//-------------------------------------------------------------------
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cTioMai:= "ÃÕ"
Local cCecid := "çÇ"
Local aCTag := {"&lt;","&gt;",">","<"}

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cTioMai
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cTioMai)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("AO",nY,1))
		EndIf
		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

For nX:= 1 To Len (aCTag)
	cString:= strTran( cString, aCTag[nX], "" ) 
Next      

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString
//-----------------------------------------------------------------------
/*/{Protheus.doc} CanWSNFSe
Retorna se o municipio da filial corrente permite cancelamento de NFSe através de webservice. 
@author reynaldo
@since 05/08/2015
@version 1.0
@return lógico, se verdadeiro existe webservice da prefeitura para cancelamento de NFSe
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------
Function CanWSNFSe()
Local nRet		:= -1 // erro de comunicacao
Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
/* *INICIO* declaracoes "replicadas" funcao FISA022() */          
Private cEntSai    := "1"
Private lUsaColab  := UsaColaboracao("3")
Private cURL       := Padr(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250)
Private cInscMun   := Alltrim(if( type( "oSigamatX" ) == "U",SM0->M0_INSCM,oSigamatX:M0_INSCM ))
Private cIdEnt     := ""
/* *FIM* declaracoes "replicadas" funcao FISA022() */          
	// TSS Ativo e estabelecido 
	If IsReady()
		nRet := 0 // assume que não tem servico de webservice de cancelamento
		If cCodMun $ RetMunCanc()
			If ! ( cCodMun $ Fisa022Cod("101")+ Fisa022Cod("102")  ) .or. lUsaColab
				nRet := 1 // prefeitura tem webservice de cancelamento
			Endif
		Endif
	EndIf
Return nRet
//-----------------------------------------------------------------------        
/*/{Protheus.doc} MonitNFSe
Nova Função de monitoramento de notas fiscais de Serviço Eletronica(NFSe) para o JOB FatJobNFe
@author reynaldo
@since 05.08.2015
@version 1.00 
@param	aInfNotas 	Array contendo as seguintes posições:
					[1] Série
					[2] Número nota inicial 
					[3] Número nota final
@return aListBox    Array com o retorno do monitoramento
/*/
//-----------------------------------------------------------------------
Function MonitNFSe(aInfNotas)
Local aBkpMV		:= {}
Local aRetNotas	:= {}
Local cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
/* *INICIO* declaracoes "replicadas" funcao FISA022() */          
Private cIdEnt	:= ""
Private cEntSai	:= "1"
Private lUsaColab	:= UsaColaboracao("3")
Private cURL		:= Padr(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250)
/* *FIM* declaracoes "replicadas" funcao FISA022() */          
	If Len(aInfNotas) > 0
		// TSS Ativo e estabelecido 
		If IsReady()
			If cCodMun $  iif (lUsaColab,cCodMun,RetMunCanc()) 
				If ! ( cCodMun $ Fisa022Cod("101")+ Fisa022Cod("102")  ) .or. lUsaColab
					// guarda o conteudo atual das MV´s
					aAdd(aBkpMV, MV_PAR01)
					aAdd(aBkpMV, MV_PAR02)
					aAdd(aBkpMV, MV_PAR03)
					MV_PAR01 := PadR(aInfNotas[1],TamSX3("F2_SERIE"	)[1])
					MV_PAR02 := PadR(aInfNotas[2],TamSX3("F2_DOC"		)[1])
					MV_PAR03 := PadR(aInfNotas[3],TamSX3("F2_DOC"		)[1])
					If !lUsaColab
						cIdEnt := GetIdEnt()
					EndIf
					//monitoramento da NFS-e 
					Fis022Mnt1(.T.,@aRetNotas,lUsaColab)
					// restaura o conteudo atual das MV´s
					MV_PAR01 := aBkpMV[1]
					MV_PAR02 := aBkpMV[2]
					MV_PAR03 := aBkpMV[3]
				EndIf
			EndIf
		EndIf
	EndIf	
Return aRetNotas
//-----------------------------------------------------------------------        
/*/{Protheus.doc} EnvCanNFSe
Função de envio do Cancelamento da NFSe ao TSS para uso do JOB FatJobNFe
@author reynaldo
@since 05.08.2015
@version 1.00 
@param	lAutoNF,	Logico,	Identifica se esta sendo chamado por Rotina Automatica
@param	aInfNotas, Array,	contendo as seguintes posições:
							[1] Série
							[2] Número nota inicial 
							[3] Número nota final
@return logico, Se conseguiu transmitir a solicicao de exclusao de NFSe
/*/
//-----------------------------------------------------------------------
Function EnvCanNFSe(lAutoNF, aInfNotas)
Local lCancOk		:= .F.
Local cNotasOk	:= ""
Local aBkpMV		:= {}
Local cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
/* *INICIO* declaracoes "replicadas" funcao FISA022() */          
Private cEntSai	:= "1"
Private lUsaColab	:= UsaColaboracao("3")
Private cIdEnt     := GetIdEnt()
Private cURL		:= Padr(GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250)
/* *FIM* declaracoes "replicadas" funcao FISA022() */          
	If Len(aInfNotas) > 0
		// TSS Ativo e estabelecido 
		If IsReady()
			If cCodMun $ iif (lUsaColab,cCodMun,RetMunCanc()) 
				If ! ( cCodMun $ Fisa022Cod("101")+ Fisa022Cod("102")  )
					// guarda o conteudo atual das MV´s
					aAdd(aBkpMV, MV_PAR01)
					aAdd(aBkpMV, MV_PAR02)
					aAdd(aBkpMV, MV_PAR03)
					aAdd(aBkpMV, MV_PAR04)
					aAdd(aBkpMV, MV_PAR05)
					MV_PAR01 := PadR(aInfNotas[1],TamSX3("F2_SERIE"	)[1])
					MV_PAR02 := PadR(aInfNotas[2],TamSX3("F2_DOC"		)[1])
					MV_PAR03 := PadR(aInfNotas[3],TamSX3("F2_DOC"		)[1])
					MV_PAR04 := ""
					MV_PAR05 := ""
					//envio do cancelamento da da NFS-e 
					Fisa022Canc(.T., @cNotasOk, aInfNotas,.F.)
					// restaura o conteudo atual das MV´s
					MV_PAR01 := aBkpMV[1]
					MV_PAR02 := aBkpMV[2]
					MV_PAR03 := aBkpMV[3]
					MV_PAR04 := aBkpMV[4]
					MV_PAR05 := aBkpMV[5]
					// se não for vazio, conseguiu excluir as notas
					lCancOk := !Empty(cNotasOk)
				EndIf
			EndIf
		EndIf
	EndIf
Return lCancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} lSetupTSS
Valida o setup necessário para utilização da integração do ERP com o TSS

@author		Cleiton Genuino da Silva
@since		29.09.2016
/*/
//-------------------------------------------------------------------
Static Function lSetupTSS()
Local lSetupTSS	:= .T.
Local lAlert		:= .T.
Local cError		:= ""
Default lFwMyTest := .F.						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Wizard config - Chama se URL vazia            					 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Padr(GetNewPar("MV_SPEDURL",""),250))
		lAlert := Fisa022Cfg()
		if !lAlert
			MsgAlert(STR0249,STR0261)  //"Configure o Parâmetro MV_SPEDURL, antes de utilizar esta opção!"
		endif
		Return	.F.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem comunicação com o TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. !(isConnTSS())
		If lIsAdm .And. lMvAdmnfse
			lAlert := Fisa022Cfg()
		Else
			lAlert := .F.
		EndIf
		if !lAlert
			MsgAlert(STR0250,STR0261) //" *** Verifique a conexão do TSS com o ERP *** "
		endif
		Return	.F.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem entidade gerada no TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. Empty(GetIdEnt(@cError))
		if lAlert
			MsgAlert(STR0251 + CRLF + cError,STR0261)  //"Sem entidade valida corrija e refaça o wizard de configuração"
		endif
		Return	.F.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se municipio não homologado no TSS              		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS 	.And. getNfseVersao() == "9.99"
		if lAlert
			Aviso("",STR0252+ if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) + " não homologado na versão do TSS - "+ getVersaoTSS() +"."+CRLF,{"Ok"})  //"Codigo de municipio "-" não homologado na versão do TSS - "
		endif
		Return	.F.
	EndIf
	IIF(lFwMyTest,cCodmun := "","")							
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Urania - SP nao esta homologado para nfs-e - caso homologue um dia remover este IF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodmun $ "3555802" .and. cEntSai = "1"
		if lAlert
			Aviso("",STR0252+ if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN ) + " Urânia - SP não homologado para transmitir NFS-e, somente NFTS, na versão do TSS - "+ getVersaoTSS() +" - ao entrar no Fisa022 ESCOLHA 2-ENTRADA -."+CRLF,{"Ok"})  //"Codigo de municipio "-" não homologado na versão do TSS - "
		endif
		Return	.F.
	EndIf


Return lSetupTSS
//-----------------------------------------------------------------------
Return ()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} isSigaMatOK
Validacao dos parametros aSigaMat01 e aSigaMat02

@author    Jonatas C. Almeida
@version   1.xx
@since     18/10/2017
/*/
//------------------------------------------------------------------------------------------
static function isSigaMatOK( aSigaMat01 )
	local lCont := .T.
	/*
	// Validacao do primeiro parametro
	if( empty( aSigaMat01[ 01 ] ) )
		//alert( "Corrigir posicao [ 01 ] do primeiro parametro" )
		lCont := .F.
	endIf
	
	if( lCont .and. empty( aSigaMat01[ 02 ] ) )
		//alert( "Corrigir posicao [ 02 ] do primeiro parametro" )
		lCont := .F.
	endIf*/
return lCont

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Justificativa Cancelamento NFS-e
Tela para digitação da justificativa específica e código de cancelamento quando houver, que será
enviado no xml 

@author    André Rupolo
@version   1.xx
@since     03/09/2018
/*/
//------------------------------------------------------------------------------------------
Static Function GetJustCanc(cSerie,cNFiscal,cCodmun)

Local aItCpo 	:= {}
local lHabCanc	:= GetNewPar("MV_CODCANC",.F.) //Habilita a tela de seleção dos códigos de cancelamento (#Piloto Itajaí - SC)
local cStrMotC  := "1 - Duplicidade na emissão do documento fiscal||2 - Não aceite pelo tomador ou intermediário do serviço||3 - Inexecução do serviço"		
local cMotNfse  := superGetMV( "MV_MOTCNFS",.F.,cStrMotC )
local aOpcMotC  := strTokArr( cMotNfse,'||' )
local lXjust    := GetNewPar("MV_INFXJUS","") == "S"
Local cXjust 	:= ''
local nx        := 0
Local cCbCpo 	:= "" 
Local oTButton2
Local oTButton1   

Default cCodmun := ""
Default lFwMyTest := .F.						
//========LEGADO======== Adicionando dados no Array do Combo ===========================
Do Case
  Case	cCodMun $ "4208203-4204202-4200101"   //Itajai
		aadd(aItCpo,"C001 - Dados do tomador incorretos")
		aadd(aItCpo,"C002 - Erro na descrição do serviço")
		aadd(aItCpo,"C003 - Erro no valor do serviço")	
		aadd(aItCpo,"C004 - Natureza da Operação e/ou Código do Item da Lista incorreto")
		aadd(aItCpo,"C005 - Informações de descontos/outros tributos incorretas")
		aadd(aItCpo,"C999 - Outros")
	Case cCodMun == "4305108" //Caxias do sul
	 	aadd(aItCpo,"1 - Serviço não foi prestado")
		aadd(aItCpo,"2 - NFS-e emitida com dados incorretos")
	Case cCodMun == "4104808" //Cascavel-PR	
		aadd(aItCpo,"1 - Duplicidade na emissão do documento fiscal")
		aadd(aItCpo,"2 - Não aceite pelo tomador ou intermediário do serviço")
		aadd(aItCpo,"3 - Inexecução do serviço")
	Case cCodMun == "4113700" // Londrina-PR
		aadd(aItCpo,"2 - Serviço não prestado")
		aadd(aItCpo,"4 - Duplicidade da nota")
	Case cCodMun == "4301206" // Arroio do Tigre - RS
		aadd(aItCpo,"1 - Duplicidade na emissão do documento fiscal")
		aadd(aItCpo,"2 - Não aceite pelo tomador ou intermediário do serviço")
		aadd(aItCpo,"3 - Inexecução do serviço")	
	OtherWise
		aItCpo := aOpcMotC	
EndCase
 
//======================= Inicializa uma linha com SAY e COMBO ===========================
If lHabCanc .AND. lXjust//habilita o combo com códigos de cancelamento e Motivo\Justificativa
	DEFINE MSDIALOG oDlg TITLE STR0253 FROM 0,0 TO  230, 400 PIXEL  //"Justificativa e Código de Cancelamento"
	DEFINE FONT oFont BOLD
	@ 5,5 SAY oSay PROMPT STR0254 OF oDlg FONT oFont PIXEL SIZE 230, 030  //"Selecione o código para o cancelamento: "
	@ 20,5 COMBOBOX oCombo VAR cCbCpo ITEMS aItCpo SIZE 190,30 PIXEL OF oDlg 
	@ 45,5 SAY oSay PROMPT STR0259 + cSerie +"e NF: "+ cNFiscal OF oDlg FONT oFont PIXEL SIZE 230, 030  //"Digite a justificativa de cancelamento para Serie: "
	@ 55,5 GET oGet VAR cXjust SIZE 190,30 MULTILINE OF oDlg PIXEL
	oTButton1 := TButton():New( 100, 060, STR0256,oDlg,{|| (lContinua := .T.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"OK"
	oTButton2 := TButton():New( 100, 110, STR0257,oDlg,{||(lContinua :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Cancelar"
ElseIf lXjust //habilita o combo com códigos de cancelamento
	DEFINE MSDIALOG oDlg TITLE STR0258 FROM 0,0 TO  180, 380 PIXEL  //"Justificativa de Cancelamento"
	DEFINE FONT oFont BOLD
	@ 5,5 SAY oSay PROMPT STR0255+ cSerie +"e NF: "+ cNFiscal OF oDlg FONT oFont PIXEL SIZE 180, 030  //"Digite a justificativa de cancelamento para Serie: "
	@ 20,5 GET oGet VAR cXjust SIZE 175,30 MULTILINE OF oDlg PIXEL
	oTButton1 := TButton():New( 070, 060, STR0256,oDlg,{|| (lContinua := .T.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"OK"
	oTButton2 := TButton():New( 070, 110, STR0257,oDlg,{||(lContinua :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Cancelar"
ElseIf lHabCanc //habilita Motivo\Justificativa
	DEFINE MSDIALOG oDlg TITLE STR0260 FROM 0,0 TO  180, 360 PIXEL  //"Código de Cancelamento"
	DEFINE FONT oFont BOLD
	@ 5,5 SAY oSay PROMPT STR0254 OF oDlg FONT oFont PIXEL SIZE 180, 030  //"Selecione o código para o cancelamento:
	@ 20,5 COMBOBOX oCombo VAR cCbCpo ITEMS aItCpo SIZE 175,30 PIXEL OF oDlg 
	oTButton1 := TButton():New( 050, 040, STR0256,oDlg,{|| (lContinua := .T.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"OK"
	oTButton2 := TButton():New( 050, 090, STR0257,oDlg,{||(lContinua :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Cancelar"
EndIf

IF !lFwMyTest // Automação
	ACTIVATE MSDIALOG oDlg CENTERED
EndiF
IIF(lFwMyTest,lContinua := .F.,"")	  

// Tratamento realizado para pegar o motivo do cancelamento, oriundo do parâmetro MV_MOTCNFS. 
If lHabCanc .And. Empty(cXjust)
	cXjust := allTrim( substr( cCbCpo,at( '-',cCbCpo ) + 1, len(cCbCpo) ) )
EndIf

cCbCpo := allTrim( substr( cCbCpo,1,at( '-',cCbCpo ) -1 ) )

Return {cCbCpo,cXjust,lContinua}

//Função removida temporáriamente por solicitação da Natália, entende-se que a alteração pode trazer mais 
//questionamentos ao cliente do auxílio na identificação do erro.
//-----------------------------------------------------------------------
/*/{Protheus.doc} TelaVldSchema
Responsavel por exibir a tela caso tenha algum incidente na funcao
xmlVldSchema.

@param		cTexto	Texto retornado na funcao.
			           
@author Douglas Parreja
@since  12/03/2020
@version 3.0 

//-----------------------------------------------------------------------
function TelaVldSchema( cTexto )

	default cTexto := ""


	DEFINE DIALOG oDlg TITLE "NFS-e" FROM 150,150 TO 550,900 PIXEL
		 
	
		oTFont := TFont():New('Consolas',,-12,.T.,.T.)
		oTFont2 := TFont():New('Consolas',,-12,.T.,.F.)

		@ 10,10		SAY oTSay PROMPT 'ATENÇÃO! Nenhuma nota foi transmitida.' SIZE 200,10 COLORS CLR_HRED,CLR_WHITE FONT oTFont OF oDlg PIXEL
		@ 30,10		SAY oTSay PROMPT "Verificar o retorno abaixo, caso conste um indicador"  SIZE 260,20 COLORS CLR_BLACK,CLR_WHITE FONT oTFont OF oDlg PIXEL
		@ 30,191 	SAY oTSay PROMPT " '^' "  SIZE 200,10 COLORS CLR_HRED,CLR_WHITE FONT oTFont OF oDlg PIXEL
		@ 30,206 	SAY oTSay PROMPT "(acento circunflexo) ele indica o possível" SIZE 260,20 COLORS CLR_BLACK,CLR_WHITE FONT oTFont OF oDlg PIXEL  
		@ 37,10   	SAY oTSay PROMPT "motivo da rejeição." SIZE 260,20 COLORS CLR_BLACK,CLR_WHITE FONT oTFont OF oDlg PIXEL  				
		oTSay := TSay():New( 01, 01,{||cTexto},oDlg,,oTFont2,.T.,.F.,.F.,.T.,0,,350,220,.F.,.T.,.F.,.F.,.F.,.F. )  
		@ 175, 320	BUTTON "Fechar" SIZE 40,13 OF oDlg PIXEL ACTION (oDlg:End())
	
		Name      := oTFont:Name   
		nWidth    := oTFont:nWidth   
		nHeigh    := oTFont:nHeight
		Bold      := oTFont:Bold   
		Italic    := oTFont:Italic   
		Underline := oTFont:Underline  


  	ACTIVATE DIALOG oDlg CENTERED

Return
/*/
//-----------------------------------------------------------------------

/*/{Protheus.doc} RemoveExt
Revome a extensão do nome dos arquivos que serão gerados

@param		cString		Nome do arquivo informado pelo usuário
			           
@author Caique Lima Fonseca
@since  24/03/2020
@version 1.0 
/*/
//-----------------------------------------------------------------------
Function RemoveExt(cString)

	Local 	aExt	:= {} 
	Local 	nX		:= 0

	Default cString := ""

	aadd(aExt, ".txt")
	aadd(aExt, ".xml")

	for nX := 1  to len(aExt)
		cString := StrTran(cString, aExt[nX])
	next

return cString 

/*/{Protheus.doc} AtuBrowse
Realiza a atualização do ambinete no Browse principal
			           
@author Caique Lima Fonseca
@since  24/03/2020
@version 1.0 
/*/
//-----------------------------------------------------------------------
Static Function AtuBrowse()

	Local cAtuBrowse := ""

	If !Empty(cTitBrowse)
		cAtuBrowse := cTitBrowse + " - Ambiente: " + cAmbiente
	EndIf

	If Type( "_oObj:OOWNER:ACONTROLS[3]:CCAPTION" ) <> "U" .and. Type( "_oObj:OOWNER:ACONTROLS[3]:CTITLE" ) <> "U"
		_oObj:cDescription := cAtuBrowse
		_oObj:OOWNER:ACONTROLS[3]:CCAPTION := cAtuBrowse
		_oObj:OOWNER:ACONTROLS[3]:CTITLE := cAtuBrowse
		_oObj:Default()
		_oObj:Refresh()
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} FLearq
Ler arquivo TXT ou XML informado no parametro cArquivo
@author Fabio Morales Parra
@since 22/09/2021
@version 1.0
@param cArquivo  Arquivo a ser lido
@param lCon .T. Faz connout no console do servidor 
@return Conteudo do arquivo lido
/*/
//-----------------------------------------------------------------------

Static Function FLearq(cArquivo,lCon)
Local nHandle    := 0
Local nTamTxt	 := 0 
Local cString 	 := ""

Default cArquivo := ""
Default lCon	 := .f.

		If File(cArquivo)
			nHandle := fopen(cArquivo, FO_READWRITE + FO_SHARED )
			nTamTxt := fSeek(nHandle,0,2) // verifica tamanho do arquivo TXT
			FSEEK(nHandle, 0) // posiciona ponteiro no inicio do arquivo
			cString := FReadStr( nHandle, nTamTxt )
			FCLOSE(nHandle)
			if lCon
				conout("Arquivo lido: " +cArquivo )
			Endif 
		Else 
			cString := "erro - 003 - Arquivo nao Encontrado"
		Endif 
		
Return cString

//-----------------------------------------------------------------------
/*/{Protheus.doc} Fdelarq
apaga arquivo TXT ou XML informado no parametro cArquivo
@author Fabio Morales Parra
@since 22/09/2021
@version 1.0
@param cArquivo  Arquivo a ser apagado
@param lCon .T. Faz connout no console do servidor 
@return true/false
/*/
//-----------------------------------------------------------------------

Static Function Fdelarq(cArquivo,lCon)
Local lRet 		:= .F. 
Local nRet 		:= -1

Default lCon	:= .f.

	If File(cArquivo)
		lRet := Iif(FErase(cArquivo) == -1, .F., .T.)
	Endif 		
	if lRet .and. lCon
		conout("Arquivo apagado: " + cArquivo )
	Elseif !lRet .and. lCon
		conout("Arquivo nao apagado: " + cArquivo )
	Endif 
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidLoja
Função responsavél por validar o Parâmetro de Fornecedor e Loja no Monitor,
para NFT-s
@author Felie Duarte Luna/Leandro Sousa dos Santos
@since 11/07/2022
@version 1.0
@param cEspaco - Espaço do tamanho do campo Loja da Tabela SF1.
@return true/false
/*/
//-----------------------------------------------------------------------
Function ValidLoja(cEspaco)

If( Empty(MV_PAR08) )
	 MV_PAR09 := cEspaco // Caso o Parâmetro de Fornecedor não estiver preenchido, limpamos o parâmetro de Loja do Fornecedor.
EndIf

Return .T.
