#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA1010.CH"
#INCLUDE "HEADERGD.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FILEIO.CH"
#Include "MSOle.ch"

Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lRetific		:= SuperGetMv("MV_RETSOC",,.F.)
Static cNTSV		:= SuperGetMv("MV_NTSV",,"")
Static cVersEnvio	:= ""
Static cVersGPE   	:= ""
Static lNT15		:= .F. // NT 15/2019
Static lGera2300	:= .T.
Static aTabS130	 	:= {}
Static lParcial		:= .F.
Static lVerRJ5 		:= If(IsInCallStack("MATA020"), .F. , FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial))
Static lOpeSoc		:= SuperGetMv("MV_OPESOC", NIL, .F.)

/*/{Protheus.doc} GPEM017C
@Author   allyson.mesashi
@Since    30/04/2020
@Version  1.0
@Obs      Migrado do GPEA010 em 30/04/2020
/*/
Function GPEM017C()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP10ENew ³ Autor ³ Glaucia M.		    ³ Data ³ 06/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificar se a eSocial foi implantada versus MV_EFDAVIS.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP10ENew()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGP10ENew(nOpcy,lGp010Auto)

Local aArea 		:= GetArea()
Local lRet 			:= .T.
Local cCampos		:= ""
Local cDef			:= ""
Local cCateg		:= ""
Local cMsgSoci		:= ""
Local aCampos		:= {}
Local aCamposT		:= {"RA_CIC","RA_RACACOR","RA_CPAISOR","RA_NACIONC","RA_CATEFD"}
Local aCamLogrBR	:= {}
Local aCamLogrBT	:= {"RA_LOGRTP","RA_LOGRDSC","RA_ESTADO","RA_CODMUN","RA_CEP","RA_LOGRNUM"}
Local aCamLogrEX	:= {}
Local aCamLogrET	:= {"RA_LOGRDSC", "RA_MUNICIP"}
Local aCpoEstran	:= {}
Local aCpoEstraT	:= {}
Local x				:= 0
Local cSConselho	:= "305" //Servidor Publico vinculado a RPPS indicado para conselho ou orgao representativo
Local cCI			:=  "201|202|305|721|722|731|734|738|761" //Contribuinte Individual (TSV)
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo (TCV)
Local cMsg			:= ""
Local cMsg2			:= ""
Local aCpVdCtps		:= {"RA_UFCP"}
Local nCont			:= 0
Local lDesRem		:= SRA->(ColumnPos("RA_DESEPS")) > 0
Local cEFDAviso		:= Alltrim(FSubst(If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")))) //Integracao com TAF)
Local lPassou		:= .F.
Local lImport		:= IsincallStack("RHIMPGEN") .Or. IsincallStack("U_RHIMP08")
Local cCatTSV		:= If(Empty(cNTSV), "701|711|712|741|", cNTSV )
Local cCPF			:= ""
Local cStatus		:= ""
Local cCBOS130		:= ""
Local cCBOSRA		:= ""
Local lAchou		:= .F.
Local lVerCNH		:= .F.
Local lVerOC		:= .F.
Local lRJ5Ok		:= .F.
Local lFilT 	 	:= .F.
Local aRH5Filt	 	:= {}
Local aAreaSR6      := {}
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. M->RA_DESCEP == "1"

Default lGp010Auto	:= .F.

lGera2300 := .T.

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE, , @lNT15)
	EndIf

	If Empty(cVersGPE)
		cVersGPE := cVersEnvio
	EndIf

	If (lIntTAF .Or. lMiddleware) .Or. cEFDAviso == "1"
		If (EMPTY(M->RA_CIC) .OR. EMPTY(M->RA_CATEFD))
			cMsg := OemtoAnsi(STR0341) + CRLF 			//"Como a integração com o módulo TAF está ativa, os campos 'CPF' e 'Categ.eSoci'"
			cMsg += OemtoAnsi(STR0342) + CRLF 			//"deverão ser preenchidos obrigatoriamente, indepentemente do conteúdo do "
			cMsg += OemtoAnsi(STR0343)					//"parametro MV_EFDAVIS."
			Help("",1,OemtoAnsi(STR0301),,cMsg,1,0)		//"Regra não Atendida"
			lRet:= .F.
		EndIf

		If lRet .AND. nOpcy == 4
			//A categoria eSocial e CPF poderao ser diferentes da carga S-2100 ou S-2200 no TAF
			//aguardar liberacao regra oficial eSocial
			If !EMPTY(SRA->RA_CATEFD) .AND. (M->RA_CATEFD <> SRA->RA_CATEFD)
				if (M->RA_CATEFD == "101" .AND. SRA->RA_CATEFD $ "102|103|105|106|107|108|111") .OR. (M->RA_CATEFD == "111" .AND. SRA->RA_CATEFD $ "101|103")
					lRet := .T.
				Else
					cMsg := ""
					cMsg := OemtoAnsi(STR0337)//"A Categoria eSocial pode ser alterada dos tipos 102/103/105/106/107/108/111 para 101 ou de 101/103 para 111. Se não for o caso é necessário encerrar um vinculo e iniciar outro."
					Aviso(OemToAnsi(STR0076), OemToAnsi(cMsg), {OemToAnsi(STR0001)})
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet .And. lOpeSoc .And. cVersEnvio >= "9.0.00"
			If (!EMPTY(M->RA_DTENTRA) .Or. !EMPTY(M->RA_TIPINF) .Or. !EMPTY(M->RA_DTREC)) .And. (M->RA_CATFUNC <> "9" .And. M->RA_EAPOSEN $ " |2")
				cMsg := OemtoAnsi(STR0478) + CRLF						//" Informações dos campos: RA_DTENTRA, RA_TIPINF ou RA_DTREC incompatíveis com a categoria(RA_CATFUNC) e o campo de aposentado(RA_EAPOSEN) 
				Help("",1,OemtoAnsi(STR0076),,cMsg,1,0)					//Atenção
				lRet:= .F.												//Atenção
			Endif

			If !EMPTY(M->RA_DTENTRA) .And. EMPTY(M->RA_TIPINF)
				cMsg := OemtoAnsi(STR0475) + CRLF  						//"A Data de inicio do Cadastro do beneficiário foi preenchida. Obrigatorio informar se é Incapacitado"
				Help("",1,OemtoAnsi(STR0076),,cMsg,1,0)					//Atenção
				lRet:= .F.
			Endif
			If !EMPTY(M->RA_TIPINF) .And. EMPTY(M->RA_DTENTRA)
				cMsg := OemtoAnsi(STR0476) + CRLF						//"O campo Incapacitado foi preenchido. Obrigatorio preenchimento da Data de Inicio do Cadastro do Beneficiario"
				Help("",1,OemtoAnsi(STR0076),,cMsg,1,0)					//Atenção
				lRet:= .F.
			Endif
			If M->RA_TIPINF == "1"  .And. EMPTY(M->RA_DTREC)
				cMsg := OemtoAnsi(STR0477) + CRLF						//"Informar a Data de Reconhecimento da Incapacidade - Orgão Público""Informar a Data de Reconhecimento da Incapacidade - Orgão Público"
				Help("",1,OemtoAnsi(STR0076),,cMsg,1,0)					//Atenção
				lRet:= .F.												//Atenção
			Endif
		Endif
		// VALIDA O COMPARTILHAMENTO ENTRE AS TABELAS C9V/C9Y/CUP/T3L/CRQ/T80/T90/T1U/T1V/TOF/CUU/T3A E A TABELA SRA.
		If lRet .And. !lGp010Auto
			fVldCmpTab()
		EndIf

	EndIf

	If lRet .And. M->RA_CATEFD $ "107/108".And. dToS(M->RA_ADMISSA) >= "20200421"
		cMsg := OemtoAnsi(STR0440) + CRLF 			//"Data de admissão incompatível com a categoria do funcionário"
		Help("",1,OemtoAnsi(STR0301),,cMsg,1,0)		//"Regra não Atendida"
		lRet := .F.
	EndIf

	If lRet .And. cVersEnvio >= "9.0.00" .And. cPaisLoc == "BRA"
		If Len(AllTrim(M->RA_CLASEST)) == 2
			Help(,, OemToAnsi(STR0465),,OemToAnsi(STR0466),1,0)	//"Classificação Estrangeiro"Campo RA_CLASEST está com conteudo referente ao leiaute 2.5. Favor corrigir o campo conforme Leiaute S-1.0"
			lRet := .F.
		EndIf
		If lRet .And. SRA->(ColumnPos("RA_TIPOVIA")) > 0
			If !Empty(M->RA_CPAISOR) .And. M->RA_CPAISOR <> '01058' .And. dToS(M->RA_ADMISSA) >= "20210510" .And. Empty(M->RA_TIPOVIA)
				Help(,, 'TMPRESID',, + CRLF + OemToAnsi(STR0462) + AllTrim(TITSX3("RA_TIPOVIA")[1]) + OemToAnsi(STR0463), 1, 0 ) // "O preenchimento do campo: "##" é obrigatório."
				// VALIDA SE BLOQUEIA OU NÃO O CADASTRO DE ACORDO COM O MV_EFDAVIS
				lRet := Iif(cEFDAviso == "0", .T., .F.)
			ElseIf M->RA_TIPOVIA == '1' .And. M->RA_CLASEST $ '2 |5 '		//"Regra não atendida"
				Help("", 1, OemToAnsi(STR0301), , OemToAnsi(STR0467), 1, 0) //"Para o Tempo de Residência = 1 (indeterminado) não podem ser informadas as Classificações de Estrangeiro 2 ou 5."
				lRet := .F.
			ElseIf M->RA_TIPOVIA == '2' .And. M->RA_CLASEST == '1 '
				Help("", 1, OemToAnsi(STR0301), , OemToAnsi(STR0468), 1, 0) //"Para o Tempo de Residência = 2 (determinado) não pode ser informada a Classificação de Estrangeiro 1."
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. M->RA_CTPCD == "1" .And. ( Empty(M->RA_PORTDEF) .Or. M->RA_PORTDEF == "******" )
			Help("", 1, OemToAnsi(STR0301), , OemToAnsi(STR0488), 1, 0) //"Para a Cota de Deficiente (RA_CTPCD), somente pode ser 1=Sim se informado pelo menos um dos tipos de Deficiência eSocial (RA_PORTDEF)."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If cPaisLoc == 'BRA'
			If !(M->RA_CATEFD $ "901*903*904") .And. cVersEnvio < "9.0.00"
				AADD(aCamposT,"RA_PIS")
			EndIF

			cDef		:= M->RA_PORTDEF
			cCateg		:= M->RA_CATEFD
			aCampos		:= {M->RA_CIC,M->RA_RACACOR,M->RA_CPAISOR,M->RA_NACIONC,M->RA_CATEFD}

			If !(M->RA_CATEFD $ "901*903*904") .And. cVersEnvio < "9.0.00"
				AADD(aCampos,M->RA_PIS)
			EndIF

			if lnt15
				aCamLogrBR	:= {M->RA_LOGRDSC,M->RA_ESTADO,M->RA_CODMUN,M->RA_CEP,M->RA_LOGRNUM}
			else
				aCamLogrBR	:= {M->RA_LOGRTP,M->RA_LOGRDSC,M->RA_ESTADO,M->RA_CODMUN,M->RA_CEP,M->RA_LOGRNUM}
			endif

			aCamLogrEX	:= {M->RA_LOGRDSC, M->RA_MUNICIP}

			If cVersEnvio >= "9.0.00"
				aCpoEstraT	:= {"RA_CLASEST"}
				aCpoEstran	:= {M->RA_CLASEST}
			ElseIf cVersEnvio >= "2.4.02"
				aCpoEstraT	:= {"RA_CASADBR","RA_FILHOBR","RA_CLASEST"}
				aCpoEstran	:= {M->RA_CASADBR,M->RA_FILHOBR,M->RA_CLASEST}
			Else
				aCpoEstraT	:= {"RA_DATCHEG", "RA_CASADBR","RA_FILHOBR","RA_CLASEST"}
				aCpoEstran	:= {M->RA_DATCHEG,M->RA_CASADBR,M->RA_FILHOBR,M->RA_CLASEST}
			Endif
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbGoTop()

			//-----------------------------
			//| Validacação tipo de contrato
			//| Se for 'determinado', tem que preencher o campo
			//-------------------------------------------------
			If ( cVersGPE >= "2.3" )
				If (M->RA_TPCONTR == "2")
					If ( Empty( M->RA_CLAURES ))
						SX3->(msSeek( "RA_CLAURES" ))
						cCampos += X3Titulo("RA_CLAURES") + CRLF
					EndIf
					If Empty(M->RA_DTFIMCT) .And. ( SRA->(ColumnPos("RA_TIPOCON")) == 0 .Or. M->RA_TIPOCON != "1" )
						SX3->(msSeek("RA_DTFIMCT" ))
						cCampos += X3Titulo(RA_DTFIMCT) + CRLF
					EndIf
				EndIf
			EndIf

			//-----------------------------
			//| Validação Campos Cadastrais
			//| CPF, Raça, Pais Origem, Pais Nasc, Cat eSocial
			//-------------------------------------------------
			For x:=1 to len(aCampos)
				If EMPTY(aCampos[x])
					SX3->(msSeek( aCamposT[x] ))
					cCampos += X3Titulo(aCamposT[x]) + CRLF
				EndIf
			Next x

			//-------------------------------------------
			//| Validação Campos de Logradouro BR ou EXT
			//| Tp Logra, Dsc Logra, Estado, Cod Municipo, CEP
			//-------------------------------------------------
			if lnt15
				aCamLogrBT	:= {"RA_LOGRDSC","RA_ESTADO","RA_CODMUN","RA_CEP","RA_LOGRNUM"}
			endif
			If M->RA_RESEXT <>"1" //Reside no Brasil
				For x:=1 to len(aCamLogrBR)
					If EMPTY(aCamLogrBR[x])
						SX3->(msSeek( aCamLogrBT[x] ))
						cCampos += X3Titulo(aCamLogrBT[x]) + CRLF
					EndIf
				Next x

			Else
				For x:=1 to len(aCamLogrEX)
					If EMPTY(aCamLogrEX[x])
						dbSeek( aCamLogrET[x] )
						cCampos += X3Titulo(aCamLogrET[x]) + CRLF
					EndIf
				Next x
			EndIf

			//Layout 2.2 - eSocial
			cMsgSoci := ""

			//----------------------------------
			//| Validação Campos de CTPS
			//| Estado e Emissao
			//----------------------------------
			if lnt15
				aCpVdCtps 	:= {}
				lPassou 	:= .T.
			endif
			If( !Empty(M->RA_NUMCP) ) .And. cVersEnvio < "9.0.00"
				For nCont:= 1 To Len( aCpVdCtps )
					If Empty(M->&(aCpVdCtps[nCont])) .and. !lnt15
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbSeek( aCpVdCtps[nCont] )

						if Empty(cMsg) .AND. !lPassou
							cMsgSoci += OemToAnsi(STR0344) +	CRLF //"Se o Campo: RA_NUMCP estiver preenchido, o(s) campo(s) tornam-se obrigatório(s):"
							lPassou := .T.
						EndIf
						cCampos += X3Titulo() + CRLF
						cMsgSoci += aCpVdCtps[nCont] +" - "+ X3Titulo() + CRLF
					EndIf
				Next
				lPassou := .F.
			EndIf

			//----------------------------------
			//| Alerta de preenchimento
			//| Se o campo XX estiver preenchido o outro deve estar tambem
			//-------------------------------------------------------------
			cMsgSoci += CRLF

			If cVersGPE >= "2.3" .And. lDesRem
				if Empty(M->RA_DESEPS) .And. M->RA_CATFUNC $ "C/T" .And. M->RA_SALARIO == 0
					dbSeek( "RA_DESEPS" )
					cCampos += "RA_DESEPS-"+ X3Titulo() + CRLF
				Endif
			EndIf
			//---------------------------
			//| Validação de Estrangeiro
			//---------------------------
			cMsgSoci += CRLF
			If !EMPTY(M->RA_CPAISOR) .AND. M->RA_CPAISOR <> '01058'	//Estrangeiro (nao existe definicao para estrangeiro no leiaute)
				For x:=1 to len(aCpoEstraT)
					If (cVersEnvio < "2.4.02" .And. aCpoEstraT[x]== "RA_DATCHEG" .AND. aCpoEstran[x]==CTOD("//"))  .OR. (Empty(aCpoEstran[x]))
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbSeek( aCpoEstraT[x] )

						If Empty(cMsg)
							cMsgSoci := OemToAnsi(STR0329) + CRLF//Se o Campo: RA_CPAISOR estiver preenchido, os campos se tornam obrigatórios
						EndIf
						cMsgSoci += aCpoEstraT[x] +" - "+ X3Titulo() + CRLF
					EndIf
				Next x

				If cVersEnvio < "9.0.00"
					If cVersEnvio >= "2.4.02" .And. M->RA_CLASEST <> "06"
						If Empty(M->RA_DATCHEG)
							SX3->(msSeek("RA_DATCHEG" ))
							cCampos += X3Titulo(RA_DATCHEG) + CRLF
						Endif
					Endif
					If Empty(M->RA_CASADBR)
						SX3->(msSeek("RA_CASADBR" ))
						cCampos += X3Titulo(RA_CASADBR) + CRLF
					EndIf
					If Empty(M->RA_FILHOBR)
						SX3->(msSeek("RA_FILHOBR" ))
						cCampos += X3Titulo(RA_FILHOBR) + CRLF
					EndIf
				EndIf
				If Empty(M->RA_CLASEST)
					SX3->(msSeek("RA_CLASEST" ))
					cCampos += X3Titulo(RA_CLASEST) + CRLF
				EndIf
			EndIf

			//---------------------------
			//| Validação Tipo Deficiencia
			//---------------------------
			If !Empty(M->RA_TPDEFFI) .AND. (M->RA_TPDEFFI) # '0' .AND.  Empty(M->RA_PORTDEF)		//Portador de deficiencia fisica
				SX3->(msSeek("RA_PORTDEF" ))
				cCampos += X3Titulo(RA_PORTDEF) + CRLF
			EndIf

			//---------------------------
			//| Validação RA_SALARIO para 
			//| Categoria 906 - Beneficiário do Programa Nacional de Prestação de Serviço Civil Voluntário
			//---------------------------
			If M->RA_CATEFD == "906" .And. Empty(M->RA_SALARIO)
				SX3->(msSeek("RA_SALARIO" ))
				cCampos += Alltrim(X3Titulo(RA_SALARIO)) + " ("+ OemtoAnsi(STR0491) + M->RA_CATEFD + ") " + CRLF // "Salário (preencher para a categoria ###) " + CRLF
			EndIf

			//--------------------------------------------
			//| Validações importantes para Trab Com Vinc
			//--------------------------------------------
			If cCateg $ cTrabVincu

				If cVersEnvio < "9.0" .Or. !(M->RA_VIEMRAI $ '30|31|35') //S-1.0 apenas para tpRegTrab 1 
					If !Empty(M->RA_PORTDEF) .And. M->RA_PORTDEF <> "******" .AND. EMPTY(M->RA_CTPCD)		//Cota para deficiente
						SX3->(msSeek("RA_CTPCD" ))
						cCampos += X3Titulo(RA_CTPCD) + CRLF
					EndIf
				EndIf

				//Validacao Tp Jorn Trab
				If Empty(M->RA_TPJORNA)
					SX3->(msSeek("RA_TPJORNA"))
					cCampos += X3Titulo(RA_TPJORNA) + CRLF
				EndIf

				//A regra abaixo so valera para tipo de jornada "submetido a jornada de trabalho"
				If M->RA_TPJORNA =='1'
					//Validacao Regra de Apontamento
					If Empty(M->RA_REGRA)
						SX3->(msSeek("RA_REGRA"))
						cCampos += X3Titulo(RA_REGRA) + CRLF
					EndIf

					//Validacao Sequencia Inicio Turno
					If Empty(M->RA_SEQTURN)
						SX3->(msSeek("RA_SEQTURN"))
						cCampos += X3Titulo(RA_SEQTURN) + CRLF
					EndIf
				Endif

				//Tipo Previdencia
				If Empty(M->RA_TPPREVI)
					SX3->(msSeek("RA_TPPREVI" ))
					cCampos += X3Titulo(RA_TPPREVI) + CRLF
				EndIf

				//Codigo do Sindicato
				If Empty(M->RA_SINDICA) .And. aScan(aSraHeader, { |x| x[2] == "RA_SINDICA" }) > 0
					SX3->(msSeek("RA_SINDICA" ))
					cCampos += X3Titulo(RA_SINDICA) + CRLF
				EndIf

			EndIf

			If !(cVersGPE >= "2.4")
				//---------------------------------
				//| Validações Campo Aposentadoria
				//---------------------------------
				If Empty(M->RA_EAPOSEN)
					SX3->(msSeek("RA_EAPOSEN"))
					cCampos += X3Titulo(RA_EAPOSEN) + CRLF
				EndIf
			EndIf

			if !lNT15
				If M->RA_CPAISOR == "01058" .And. Empty(M->RA_CODMUNN)
					SX3->(msSeek("RA_CODMUNN"))
					cCampos += X3Titulo(RA_CODMUNN) + OemtoAnsi(STR0380) + CRLF //, pois o pais de origem é Brasil"
				Endif
			endif

			//Validação CNH/OC
			If Empty(aTabS130)
				fCarrTab( @aTabS130, "S130", dDataBase, .T. )
			EndIf

			For nCont := 1 To Len(aTabS130)
				cCBOS130 := AllTrim(strTran(aTabS130[nCont, 6], "-", ""))
				cCBOSRA  := M->RA_CODCBO
				If Len(cCBOS130) == 4
					cCBOSRA := Left(cCBOSRA,4)
				EndIf
				If aTabS130[nCont, 2] == M->RA_FILIAL .And. cCBOS130 == cCBOSRA
					lAchou := .T.
				ElseIf Empty(aTabS130[nCont, 2]) .And. cCBOS130 == cCBOSRA
					lAchou := .T.
				EndIf
				If lAchou
					If aTabS130[nCont, 5] == "01"
						lVerCNH := .T.
					Else
						lVerOC := .T.
					EndIf
				EndIf

			Next nCont

			//--------------------------------------------------
			//| Criando mensagem com campos importantes eSocial
			//| Verifica se cCampos possui informação e verifica parâmetro MV_EFDAVIS
			//| Sim: Entra pois existem campos obrigatórios para eSocial que não estão preenchidos, monta a mensagem
			//| Não: Pula o bloco pois todos os campos obrigatórios para eSocial estão preenchidos
			//--------------------------------------------------
			If !Empty(cCampos)
				cMsg:= OemtoAnsi(STR0283)							//"O(s)  seguinte(s) campos (e)sao obrigatorios na eSocial, "

				//-------------------------
				//| Importante: MV_EFDAVIS
				//| "0": Somente informa a obrigatoriedade, mas permite passar caso MV_RHTAF=.F.
				//| "1": Bloqueia se encontrar inconsistências
				//| "2": Não exibe a mensagem de inconsistências, mas exibe e impede o processo caso MV_RHTAF=.T.
				//--------------------------------------------

				If cEFDAviso == "0"
					cMsg+= OemtoAnsi(STR0295)						//"mas conforme o conteúdo do parâmetro MV_EFDAVIS, "
					cMsg+= OemtoAnsi(STR0284) + CRLF + CRLF + cCampos 		//"nao sera impeditivo para a gravacao dos dados deste funcionario."
				ElseIf cEFDAviso == "1" .Or. (lIntTAF .Or. lMiddleware)//Invalida tudo se for obrigatório o eSocial na base
					cMsg+= OemtoAnsi(STR0285) + CRLF + CRLF + cCampos		//"sera necessario o preenchimento dos mesmos para efetivar a gravacao dos dados deste funcionario."
					lRet :=  .F.
				EndIf

				// Se for rotina automática não apresenta o log.
				If !(lImport .And. cEFDAviso == "0")

					If (GetMemVar("RA_CATEFD") $ cCatTSV)
						If !lMiddleware
							If cVersEnvio >= "9.0"
								cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + Iif(lGeraMat, GetMemVar("RA_CODUNIC"), "") + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
							Else
								cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
							EndIf
							cStatus := TAFGetStat( "S-2300", cCPF )
						Else
							If cVersEnvio >= "9.0" .And. lGeraMat
								cCPF := AllTrim( GetMemVar("RA_CODUNIC"))
							Else
								cCPF := AllTrim( GetMemVar("RA_CIC") ) + AllTrim( GetMemVar("RA_CATEFD") ) + DTOS( GetMemVar("RA_ADMISSA") )
							EndIf
							cStatus := "-1"
							fPosFil( cEmpAnt, cFilAnt )
							aInfoC   := fXMLInfos()
							If LEN(aInfoC) >= 4
								cTpInsc  := aInfoC[1]
								lAdmPubl := aInfoC[4]
								cNrInsc  := aInfoC[2]
							Else
								cTpInsc  := ""
								lAdmPubl := .F.
								cNrInsc  := "0"
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, fTamRJEKey(), " ")
							cStatus 	:= "-1"
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStatus )
						EndIf
					EndIf

					If !lGp010Auto .And. ((lIntTAF .Or. lMiddleware) .Or. cEFDAviso $ "0|1") .And. (!(M->RA_CATEFD $ cCatTSV) .OR. (cStatus <> "-1" .AND. (lMiddleware .Or. !lMiddleware .And. !(C9V->C9V_NOMEVE == "TAUTO")) )) //necessario verificar se não é TAUTO
						Help("",1,OemtoAnsi(STR0286),,cMsg + CRLF + cMsgSoci,1,0)					//"Campo nao preenchido"
					EndIf
				EndIf
			EndIf

			If lRet
				If (cCateg $ cTrabVincu) .OR. (cCateg $ cSConselho) .OR. (cCateg $ cCI)
					If Empty(M->RA_CODCBO)
						M->RA_CODCBO := f010CBO()

						If Empty(M->RA_CODCBO)
							cMsg2+= OemtoAnsi(STR0296) + CRLF	//"A funcao escolhida não possui Codigo de CBO, e para categoria eSocial escolhida, este campo e obrigatorio."
						ENDIF
					EndIf
				EndIf

				If M->RA_ESTCIVI == "O"
					cMsg2+= OemtoAnsi(STR0298) + CRLF//"O estado civil não poderá ser utilizado no eSocial. Por favor escolha outro Estado Civil"
				EndIf

				If cCateg $ "101|102|103|105|106|107|108|111" .AND. M->RA_TPPREVI == "2"
					cMsg2 += OemToAnsi(STR0411)+CRLF //"Campo Tipo de Reg Prev. inconsistente. Categorias 101, 102, 103, 105, 106 e 111 não pode ser preenchido com '2'."
				Endif

				If lVerRJ5
					lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0

					If !lFilT
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + M->RA_CC ) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == M->RA_CC
								If AnoMes(dDataBase) >= RJ5->RJ5_INI
									lRJ5Ok	:= .T.
									Exit
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
						If !lRJ5Ok
							cMsg2 += OemtoAnsi(STR0421) + M->RA_CC + OemtoAnsi(STR0422) + CRLF//"O centro de custo: XXXX (RA_CC) não está cadastrado na tabela RJ5 - Relacionamentos CTT."
						EndIf
					Else
						aRH5Filt := fRJ5Filt()
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						RJ5->(dbGotop())
						If Len(aRH5Filt) > 0
							If RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + M->RA_CC + cFilAnt ) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", M->RA_FILIAL) .And.  RJ5->RJ5_CC == M->RA_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == cFilAnt, .T.)
									If AnoMes(dDataBase) >= RJ5->RJ5_INI
										lRJ5Ok	:= .T.
										Exit
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						Endif
						If Len(aRH5Filt) == 0 .Or. !lRJ5Ok
							If RJ5->( dbSeek( xFilial("RJ5", M->RA_FILIAL) + M->RA_CC ) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL ==  xFilial("RJ5", M->RA_FILIAL) .And. RJ5->RJ5_CC == M->RA_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==cFilAnt, .T.)
									If AnoMes(dDataBase) >= RJ5->RJ5_INI
										lRJ5Ok	:= .T.
										Exit
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						Endif
						If !lRJ5Ok
							cMsg2 += OemtoAnsi(STR0421) + M->RA_CC + OemtoAnsi(STR0422) + CRLF//"O centro de custo: XXXX (RA_CC) não está cadastrado na tabela RJ5 - Relacionamentos CTT."
						EndIf
					EndIf
				Endif

				If !Empty(cMsg2)
					cMsg:= OemtoAnsi(STR0299)+CRLF			//"As seguintes regras deverao ser atendidas conforme leiaute eSocial."

					If cEFDAviso == "0"
						cMsg+= OemtoAnsi(STR0300)+ CRLF + CRLF			//"E conforme conteudo do parametro MV_EFDAVIS "
						cMsg+= OemtoAnsi(STR0284) + CRLF + CRLF + cMsg2	//"nao sera impeditivo para a gravacao dos dados deste funcionario."
					ElseIf cEFDAviso == "1" .Or. (lIntTAF .Or. lMiddleware)
						cMsg+= OemtoAnsi(STR0285)+ CRLF + CRLF + cMsg2		//"e sera necessario o preenchimento dos mesmos para efetivar a gravacao dos dados deste funcionario."
						lRet :=  .F.
					Endif

					// Se for rotina automática não apresenta o log.
					If !(M->RA_CATEFD $ cCatTSV )
						If lGp010Auto .And. ((lIntTAF .Or. lMiddleware) .Or. cEFDAviso == "1")
							Help("",1,OemtoAnsi(STR0286),,cMsg,1,0)					//"Campo nao preenchido"
						ElseIf !lGp010Auto .And. ((lIntTAF .Or. lMiddleware) .Or. cEFDAviso $ "0|1")
							Help("",1,OemtoAnsi(STR0286),,cMsg,1,0)					//"Campo nao preenchido"
						EndIf
					EndIf
				EndIf
			EndIf

			If (!lRet .And. FunName() $ "GPEA010|GPEA011|GPEA925") .And. (M->RA_CATEFD $ cCatTSV)
				lRet := .T.
				lGera2300 := .F.
			EndIf

			If (cVersEnvio >= "9.0.00") .And. M->RA_TPJORNA <> "3"
				If (lRet)
					If (!Empty(M->RA_TNOTRAB))
						DbSelectArea("SR6")
						If (FieldPos("R6_ESNOTU") > 0)
							aAreaSR6 := SR6->(GetArea())

							SR6->(DbSetOrder(1))
							If (SR6->(DbSeek(xFilial("SR6") + PadR(M->RA_TNOTRAB, TamSX3("R6_TURNO")[1]))))
								If ((lRet) .And. (Empty(SR6->R6_ESNOTU)))
									cMsg := OemToAnsi(STR0459) + CRLF //"Campo 'Turno Trab' (RA_TNOTRAB)"
									cMsg += OemToAnsi(STR0460) + CRLF //"não pode possuir campo 'Jorn Sem Not'"
									cMsg += OemToAnsi(STR0461) + CRLF //"(R6_ESNOTU) em branco."
									Help("", 1, OemToAnsi(STR0301), , cMsg, 1, 0) //"Regra não atendida"
									lRet := .F.
								Endif
							Endif

							RestArea(aAreaSR6)
						Endif
					Endif
				Endif
			Endif

		EndIf
	EndIf

	If lGp010Auto .And. !Empty(cMsg) .And. ((lIntTAF .Or. lMiddleware) .Or. cEFDAviso == "1")
		Conout(AnsiToOEM(cMsg) + CRLF + "Funcionario: " + M->RA_MAT)
		AutoGRLog(cMsg + CRLF + "Funcionario: " + M->RA_MAT)
		lMsErroAuto := .T.
	EndIf

	RestArea(aArea)
Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 fGp10TafNew³ Autor ³ Alessandro Santos     | Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificar campos de integracao com TAF. MV_INTTAF.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGp10TafNew()										 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGp10TafNew(nOpc,aRotAuto,cCodUnico,lAdmPre)

	Local aArea 		:= GetArea()
	Local lRet 			:= .T.
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
	Local cTrabSemVinc:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Trabalhador sem vinculo
	Local cCPF			:= ""
	Local cStatus		:= "-1"
	Local aErros		:= {}
	Local aTpAlt		:= {}
	Local lIntegra		:= .T.
	Local cVersEnvio	:= ""
	Local cVersGPE		:= ""
	Local cSal2206		:= ""
	Local nPos			:= 0
	Local nI			:= 0
	Local lMsgAuto		:= .F.
	Local aCposRein		:= {"RA_FECREI", "RA_DEMIANT", "RA_TPREINT", "RA_NRPROC", "RA_NRLEIAN", "RA_DTEFRET", "RA_DTEFRTN"}
	Local cCatTSV		:= If(Empty(cNTSV), "701|711|712|741|", cNTSV )
	Local nAltPis		:= 0
	Local dAltSal
	Local lTpcon		:= .T.
	//Variáveis utilizadas em rotinas automáticas
	Local cTipoAux		:= ""
	Local aAutAux		:= {}
	Local aTempSRA		:= SRA->( dbStruct() )
	Local nS			:= 0
	Local nContField	:= Len( aTempSRA )

	Local lAuxInclui	:= .F.
	Local lAuxAltera	:= .F.
	Local lGera2205		:= M->RA_SITFOLH == "D" .And. dDataBase < M->RA_DEMISSA
	Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"
	Local cGeraMat		:= If(lGeraMat, M->RA_DESCEP, "")
	Local cRetf2300		:= "1"

	Default aRotAuto 	:= {}
	Default cCodUnico	:= ""
	Default lAdmPre		:= .F.

	Begin Sequence

		If Type("lGp010Auto") == "U"
			Private lGp010Auto := .F.
		EndIf

		//Aviso sobre alteracoes nos campos de reintegracao
		If cPaisLoc == "BRA" .AND. (lIntTaf .Or. lMiddleware) .AND. FUNNAME() <> "GPEM035"
			If FindFunction("fVersEsoc")
				fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE, , @lNT15)
			EndIf

			If nOpc == 4
				If GetMemVar("RA_CATEFD") $ cTrabVincu .OR. GetMemVar("RA_CATEFD") $ cTrabSemVinc //Verifica vinculo
					//Verifica se rotina automatica

					If !lGp010Auto //Alteracao manual
						If GetMemVar("RA_FECREI") <> SRA->RA_FECREI .OR. GetMemVar("RA_DEMIANT") <> SRA->RA_DEMIANT .OR. GetMemVar("RA_TPREINT") <> SRA->RA_TPREINT .OR.;
							GetMemVar("RA_NRPROC") <> SRA->RA_NRPROC .OR. GetMemVar("RA_NRLEIAN") <> SRA->RA_NRLEIAN .OR. GetMemVar("RA_DTEFRET") <> SRA->RA_DTEFRET .OR.;
							GetMemVar("RA_DTEFRTN") <> SRA->RA_DTEFRTN
							Help("", 1, OemtoAnsi(STR0076),, OemtoAnsi(STR0434), 1, 0,,,,,, {OemtoAnsi(STR0346)})//##"Atenção"##"Para dados de reintegracao, utilize a rotina de Reintegraçao de Funcionario"
						Endif
						If GetMemVar("RA_CIC") <> SRA->RA_CIC
							Help("",1,OemtoAnsi(STR0076),,STR0336,1,0)	//##"Atenção"##"O campo CPF é chave para o registro do trabalhador, você deve exclui-lo e inclui-lo novamente."
							lRet := .F.
							Break
						Endif

						If ( GetMemVar("RA_CATEFD") $ cTrabVincu )
							If GetMemVar("RA_DEMISSA") <> SRA->RA_DEMISSA
								Help("",1,OemtoAnsi(STR0076),,STR0345,1,0)	//##"Atenção"##"Informacao de Desligamento deve ser informado através da rotina de rescisao."
								lRet := .F.
								Break
							Endif
						EndIf

						//Verifica se tabela RS9 possui dados caso o campo de Cota Def. esteja preenchido com sim
						If cVersEnvio >= "9.0.00" .And. GetMemVar("RA_CTPCD") <> SRA->RA_CTPCD .And. GetMemVar("RA_CTPCD") == "1"
							IF fPesRS9(SRA->RA_FILIAL + SRA->RA_MAT)
								Help("",1,OemtoAnsi(STR0076),,STR0464,1,0)	//##"Atenção"##"A informação de Cota de PCD só pode ser informada para tipo de Regime de trabalho igual a 1"
								lRet := .F.
								Break
							EndIf
						EndIf

						//Verificação de qual o tipo de alteração foi realizada
						lRet := fVTpAltNew(@aTpAlt,lRet,,cVersEnvio)

					Else //Alteracao automatica
						For nI := 1 To Len(aCposRein)
							If (nPos := aScan(aRotAuto,{|x| UPPER(Alltrim(x[1]))== aCposRein[nI]})) > 0 //Verifica se campos de reintegracao foram alterados
								If aRotAuto[nPos, 2] <> FieldGet(FieldPos(aCposRein[nI]))
									lMsgAuto := .T.
									Exit
								EndIf
							EndIf
						Next nI

						If lMsgAuto
							//Verifica se existe reintegracao no TAF
							AutoGRLog(OemToAnsi(STR0076) + ". " + OemToAnsi(STR0346)) //##"Atenção"##"Para dados de reintegracao, utilize a rotina de Reintegraçao de Funcionario. A alteracao não sera efetivada"
							AutoGRLog(Replicate("-",80))

						EndIf

						//Verificação de qual o tipo de alteração foi realizada
						lRet := fVTpAltNew(@aTpAlt,lRet,,cVersEnvio)

					EndIf
				EndIf
			EndIf
			If IsInCallStack("GPEA810") .And. (lIntTAF .Or. lMiddleware) .And. Type("c810codUnic")== "C"
				c810CodUnic:= ALLTRIM(SRA->RA_CODUNIC) := c810codUnic
			EndIf
			// efetua a gravacao no TAF
			If (lIntTAF .Or. lMiddleware) .AND. ( cValToChar( nOpc ) $ "3|4|7" ) .and. lRet .And. !IsInCallStack("GPEA810")

				//Verifica se o Centro de Custos do funcionario possui codigo de lotacao informada
				If !lVerRJ5 .And. ( !Empty( GetMemVar("RA_CC") ) .And. Empty( Posicione('CTT',1,xFilial("CTT",cFilAnt)+Alltrim(GetMemVar("RA_CC")),'CTT_TPLOT')) )
					If lGp010Auto
						AutoGrLog(OemToAnsi( "O Centro de Custos: '" + AllTrim( GetMemVar("RA_CC") ) + "' não foi integrado ao TAF porque o campo 'Tipo Lotação' não está informado (campo CTT_TPLOT)." ))
					Else
						MsgInfo(OemToAnsi( "O Centro de Custos: '" + AllTrim( GetMemVar("RA_CC") ) + "' não foi integrado ao TAF porque o campo 'Tipo Lotação' não está informado (campo CTT_TPLOT)." ))
					EndIf
				EndIf

				//Se for uma inclusão ou cópia
				If nOpc == 3 .or. nOpc == 7 .And. FindFunction("fIncPreAd")

					If lGp010Auto .And. LEN(aRotAuto) > 0
						For nS := 1 To nContField
							//Garante que todos os campos da SRA estarão no array da rotina automática (evita-se error.log na geração do XML)
							If aScan( aRotAuto , { |x| Upper(AllTrim(x[1])) == Upper( AllTrim( aTempSRA[ nS , 1 ] ) ) } ) == 0
								aAdd(aAutAux, aTempSRA[ nS , 1 ] )
								cTipoAux := aTempSRA[nS, 2]
								Do Case
									Case(cTipoAux $ "C|M")
										aAdd(aAutAux, "" )
									Case(cTipoAux =="D")
										aAdd(aAutAux, CTOD("//") )
									Case(cTipoAux =="N")
										aAdd(aAutAux, 0 )
								End Case
								aAdd( aRotAuto , aClone( aAutAux ) )
								aAutAux := {}
							EndIF
						Next nS
					EndIf
					//Gera evento S-2400 Beneficiarios Orgãos Publicos
					If cVersEnvio >= "9.0" .And. lOpeSoc .And. (GetMemVar("RA_CATFUNC") == "9" .Or. GetMemVar("RA_EAPOSEN") == "1" )
						lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2400", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE ), .T.)
						If ( lIntegra )
							// PREENCHE A VARIAVEL cCodUnico CORRETAMENTE.
							If lGp010Auto
								cCodUnico := SRA->RA_CODUNIC
							Else
								cCodUnico:= fRACodUnic(.F.)
							EndIf
							PutFileInEof("SRA") //Remove o posicionamento da SRA. */
							lRet:= fInt2400New("SRA",/*lAltCad*/,nOpc,"S2400",/*cTFilial*/,/*aDep*/,cCodUnico,/*oModel*/, "ADM", @aErros, cVersEnvio)
						Endif

						//Verifica se o sistema informa ou não a integração com sucesso no TAF
						If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
							fEFDMsg()
						EndIf
					//Gera registro S-2300 - Trab. Sem Vinc
					ElseIf (GetMemVar("RA_CATEFD") $ cTrabSemVinc) .And. lGera2300 .And. !(M->RA_CATEFD $ cCatTSV )

						lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2300", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)
						If ( lIntegra )
							If cVersEnvio >= "9.0"// .And. cGeraMat == "1"
								If lGp010Auto
									cCodUnico := SRA->RA_CODUNIC
								Else
									cCodUnico:= fRACodUnic(.F.)
								EndIf
							EndIf
							PutFileInEof("SRA") //Remove o posicionamento da SRA.
							lRet:= fInt2300New("SRA",/*lAltCad*/,nOpc,"S2300",/*cTFilial*/,/*aDadosXml*/,cVersEnvio,,,,,,,,,,"1"/*cGeraMat*/,cCodUnico)
							lRet2206 := lRet
							If lRet .And. cVersEnvio >= "9.0" .And. SRA->(ColumnPos("RA_DESCEP")) > 0
								SetMemVar( "RA_DESCEP", "1" )
							Endif
						EndIf
						//Verifica se o sistema informa ou não a integração com sucesso no TAF
						If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
							fEFDMsg()
						EndIf
					ElseIf (GetMemVar("RA_CATEFD") $ cTrabVincu)

						// PREENCHE A VARIAVEL cCodUnico CORRETAMENTE.
						If lGp010Auto
							cCodUnico := SRA->RA_CODUNIC
						Else
							cCodUnico:= fRACodUnic(.F.)
						EndIf

						leSocCompl := fG17VSRA("SRA",1,,,cVersEnvio)

						If leSocCompl //todos os campos do eSocial foram preenchidos
							//Gera registro S-2100 ou S-2200 - Trab. Com Vinc
							lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)

							If lIntegra .And. ( lTpcon := fTpConSVA() )
								PutFileInEof("SRA") //Remove o posicionamento da SRA.
								lRet:= fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2200",/*cTFilial*/,/*aDep*/,cCodUnico,/*oModel*/, "ADM", @aErros, cVersEnvio)
							EndIf
						ElseIf Empty(aRotAuto) .And. !lGp010Auto
							If (MsgYesNo(oEmtoAnsi(STR0414),oEmtoAnsi(STR0076))) // #STR0414 = "Os campos de preencimento obrigatório para o eSocial não foram preenchidos, deseja confirmar a gravação e gerar o Registro Preliminar de Admissão ('S-2190')?" // #STR0076 = "Atenção"
								lRet 	:= fIncPreAd(cCodUnico)
								If lRet
									lAdmPre := .T.
								EndIf
							Else
								lRet := .F.
							Endif
						EndIf
						//Verifica se o sistema informa ou não a integração com sucesso no TAF
						If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto .And. lTpcon
							fEFDMsg()
						EndIf
					Endif

				ElseIf nOpc == 4

					IF !(M->RA_PIS == SRA->(RA_PIS)) .And. cVersEnvio < "9.0.00"
						If !lGp010Auto .And. GetMemVar("RA_CATEFD") $ cTrabSemVinc .And. lGera2300 .And. M->RA_CATEFD $ cCatTSV
							aTpAlt[1]	:= .F.
							aTpAlt[3]	:= .F.
							nAltPis		:= 4

						ElseIf ! lGp010Auto
							DEFINE DIALOG oDlg TITLE STR0407 FROM 10, 10 TO 200, 450 PIXEL STYLE DS_MODALFRAME //Escolha uma opção
								oDlg:lEscClose := .F.

								@ 10, 10 SAY STR0408 SIZE 220,10 PIXEL //"Identificamos uma alteração no campo P.I.S, escolha abaixo qual ação deseja realizar."

								aItems := {Iif(GetMemVar("RA_CATEFD") $ cTrabSemVinc, 'S-2300', 'S-2200'),'S-2205','Cancelar alterações'}
								oRadio := TRadMenu():New (30,10,aItems,/*bSetGet*/,oDlg,/*uParam6*/,/*bChange*/, /*nClrText*/,/*nClrPane*/,/*cMsg*/,/*uParam11*/,/*bWhen*/,150,30;
												,/*bValid*/,/*uParam16*/,/*uParam17*/,/*lPixel*/,/*lHoriz*/,.T.)

								oRadio:bSetGet := {|u| IIF (PCount()==0, nAltPis, nAltPis := u)}

								@ 70,150 BUTTON oBtn PROMPT "Confirmar" SIZE 60, 15 PIXEL OF oDlg ACTION ( oDlg:End())

							ACTIVATE DIALOG oDlg CENTERED
						Else
							//Quando rotina automática sempre irá enviar uma alteração
							nAltPis := 2
						EndIf

						IF nAltPis == 1 	 //Se escolheu opção S-2200
							aTpAlt[1] := .T.
							aTpAlt[3] := .F.

						ELSEIF nAltPis == 2  //Se escolheu opção S-2205
							aTpAlt[1] := .F.
							aTpAlt[3] := .T.

						ELSEIF nAltPis == 3	 //Se escolheu opção "Cancelar alterações"
							MsgAlert(oemToAnsi(STR0409),; // "De acordo com a opção escolhida, o campo PIS não será alterado.
									oEmtoAnsi(STR0076))  //  "Atencao"

							//Se for escolhida a opção 3 - Cancelar alteração, o PIS não é alterado para integrar com o TAF.
							M->RA_PIS := SRA->RA_PIS

							//Verifica novamente qual o tipo de alteração foi realizada
							lRet := fVTpAltNew(@aTpAlt,lRet,,cVersEnvio)
						ELSEIF nAltPis == 0
							MsgAlert(;
									oemToAnsi(STR0410),; // "Não foi possível identificar a opção escolhida. Suas alterações serão desconsideradas.
									oEmtoAnsi(STR0076))  //  "Atencao"

							lRet := .F.
						ENDIF
					ENDIF

					If cVersEnvio >= "9.0" .And. lOpeSoc .And. (GetMemVar("RA_CATFUNC") == "9" .Or. GetMemVar("RA_EAPOSEN") == "1" ) .And. lRet
						cCodUnico := SRA->RA_CODUNIC
						If( Empty(cCodUnico) )
							cCodUnico:= fRACodUnic(.F.)
						EndIf

						IF lRetific .AND. !aTpAlt[1] .AND. (aTpAlt[3] .OR. aTpAlt[4]) .AND. M->RA_SITFOLH <> "D"
							cStatus := TAFGetStat("S-2400", AllTrim(SRA->RA_CIC) )
							IF cStatus == "4" .AND. (MSGYESNO(STR0416))
								aTpAlt[1] := .T.
							ENDIF
						Endif
						if aTpAlt[1]
							cStatus := TAFGetStat("S-2400", AllTrim(SRA->RA_CIC) )
							If cStatus == "4"    // Para gerar a retificação
								lRet:= fInt2400New("SRA",/*lAltCad*/,nOpc,"S2400",/*cTFilial*/,/*aDep*/,cCodUnico, /*oModel*/, "ADM", @aErros, cVersEnvio)

								If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
									fEFDMsg()
								EndIf
							Endif
						Else
							If aTpAlt[3] .And. M->RA_SITFOLH <> "D"
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2405", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)
								If lIntegra
									lRet:= fInt2400New("SRA",/*lAltCad*/,nOpc,"S2405",/*cTFilial*/,/*aDep*/,cCodUnico,/*oModel*/, "ADM", @aErros, cVersEnvio)
										//Verifica se o sistema informa ou não a integração com sucesso no TAF
									If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
										fEFDMsg()
									EndIf
								Endif
							EndIf
						Endif
					//---------------------------
					//| Trabalhador com Vinculo
					//---------------------------
					ElseIf (GetMemVar("RA_CATEFD") $ cTrabVincu) .AND. lRet
						cCodUnico := SRA->RA_CODUNIC

						If( Empty(cCodUnico) )
							cCodUnico:= fRACodUnic(.F.)
						EndIf

						IF lRetific .AND. !aTpAlt[1] .AND. (aTpAlt[3] .OR. aTpAlt[4]) .AND. M->RA_SITFOLH <> "D"
							If !lMiddleware
								cStatus := TAFGetStat("S-2200", AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC))
							Else
								cStatus := "-1"
								fPosFil( cEmpAnt, SRA->RA_FILIAL )
								aInfoC   := fXMLInfos()
								If LEN(aInfoC) >= 4
									cTpInsc  := aInfoC[1]
									lAdmPubl := aInfoC[4]
									cNrInsc  := aInfoC[2]
								Else
									cTpInsc  := ""
									lAdmPubl := .F.
									cNrInsc  := "0"
								EndIf
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
								cStatus 	:= "-1"
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								GetInfRJE( 2, cChaveMid, @cStatus )
							EndIf
							IF cStatus == "4" .AND. (MSGYESNO(STR0416))
								aTpAlt[1] := .T.
							ENDIF
						ENDIF

						if aTpAlt[1]
							if M->RA_VIEMRAI == SRA->RA_VIEMRAI .OR. (SRA->RA_VIEMRAI $ '30|31|35' .And. !M->RA_VIEMRAI $ '30|31|35') .OR. (!(SRA->RA_VIEMRAI $ '30|31|35') .AND. M->RA_VIEMRAI $ '30|31|35')	// GERAR S2200
								If !lMiddleware
									cStatus := TAFGetStat("S-2200", AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC))
								Endif

								leSocCompl := fG17VSRA("SRA",1,,,cVersEnvio)
								If leSocCompl  .Or. cStatus <> "-1" //todos os campos do eSocial foram preenchidos
									lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15), .T.)

									If lIntegra .And. fTpConSVA()
										lRet:= fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2200",/*cTFilial*/,/*aDep*/,cCodUnico, /*oModel*/, "ADM", @aErros, cVersEnvio)
										lRet2206 := lRet
									Endif
								ElseIf Empty(aRotAuto) .And. !lGp010Auto
									If (MsgYesNo(oEmtoAnsi(STR0414),oEmtoAnsi(STR0076))) // #STR0414 = "Os campos de preencimento obrigatório para o eSocial não foram preenchidos, deseja confirmar a gravação e gerar o Registro Preliminar de Admissão ('S-2190')?" // #STR0076 = "Atenção"
										lRet 	:= fIncPreAd(cCodUnico)
										If lRet
											lAdmPre	:= .T.
										EndIf
									Else
										lRet := .F.
									Endif
								Endif
								//Verifica se o sistema informa ou não a integração com sucesso no TAF
								If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
									fEFDMsg()
								EndIf

							elseif (SRA->RA_VIEMRAI $ '20|25|70|75' .And. !M->RA_VIEMRAI $ '20|25|70|75') .Or. (!SRA->RA_VIEMRAI $ '20|25|70|75' .And. M->RA_VIEMRAI $ '20|25|70|75');
									.Or. (M->RA_TPCONTR <> SRA->RA_TPCONTR .And. cVersEnvio < "9.0.00")																											// GERAR S2206
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2206", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15), .T.)

								If lIntegra .And. fTpConSVA()
									dAltSal 	:= If( !Empty(GetMemVar("RA_DATAALT")), GetMemVar("RA_DATAALT"), Nil )
									cSal2206	:= If( !Empty(GetMemVar("RA_SALARIO")), GetMemVar("RA_SALARIO"), Nil )

									lAuxInclui	:= Inclui
									lAuxAltera	:= Altera
									lRet:=fInt2206("SRA", /*lAltCad*/, nOpc, "S2206", /*cTFilial*/, /*dtEf*/, /*cTurno*/, /*cRegra*/, /*cSeqT*/, /*oModel*/, cVersEnvio, /*oMdlRS9*/, dAltSal, /*lTransf*/, /*cCTT2206*/, /*aErros*/, /*lMsgHlp*/, .T. ,cSal2206)
									Inclui	:= lAuxInclui
									Altera	:= lAuxAltera

									lRet2206 := lRet

									//Verifica se o sistema informa ou não a integração com sucesso no TAF
									If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
										fEFDMsg()
									EndIf
								EndIf
							ENDIF
						Else
							If aTpAlt[3] .And. (M->RA_SITFOLH <> "D" .Or. lGera2205)
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2205", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)

								If lIntegra
									lRet := fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2205",/*cTFilial*/,/*aDep*/,/*cCodUnico*/,/*oModel*/,/*cOrigem*/,/*@aErros*/,cVersEnvio)

									//Verifica se o sistema informa ou não a integração com sucesso no TAF
									If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
										fEFDMsg()
									EndIf
								Endif
							EndIf

							// VERIFICA SE HOUVE ALTERAÇÃO CONTRATUAL OU VINCULO EMPR. PARA GERAÇÃO DO S-2206
							If aTpAlt[4] .Or. (SRA->RA_VIEMRAI <> M->RA_VIEMRAI .And. GdFieldPos("RA_VIEMRAI", aSraHeader) > 0)
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2206", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)

								If lIntegra .And. fTpConSVA()
									dAltSal 	:= If( !Empty(GetMemVar("RA_DATAALT")), GetMemVar("RA_DATAALT"), Nil )
									cSal2206	:= If( !Empty(GetMemVar("RA_SALARIO")), GetMemVar("RA_SALARIO"), Nil )

									lAuxInclui	:= Inclui
									lAuxAltera	:= Altera
									lRet:=fInt2206("SRA", /*lAltCad*/, nOpc, "S2206", /*cTFilial*/, /*dtEf*/, /*cTurno*/, /*cRegra*/, /*cSeqT*/, /*oModel*/, cVersEnvio, /*oMdlRS9*/, dAltSal, /*lTransf*/, /*cCTT2206*/, /*aErros*/, /*lMsgHlp*/, .T., cSal2206, /*cSVAObs*/, lGp010Auto, aRotAuto)
									Inclui	:= lAuxInclui
									Altera	:= lAuxAltera

									lRet2206 := lRet

									//Verifica se o sistema informa ou não a integração com sucesso no TAF
									If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
										fEFDMsg()
									EndIf
								EndIf
							EndIf
						Endif

					//---------------------------
					//| Trabalhador sem Vinculo
					//---------------------------
					ElseIf ( GetMemVar("RA_CATEFD") $ cTrabSemVinc ) .AND. lRet
						//Verifica se ele esta sendo demitido e gera o evento de desligamento direto da tela
						If( SRA->RA_DEMISSA != M->RA_DEMISSA )

							//Verifica se o registro esta sendo demitido
							If lRet
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2399", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE, , @lNT15 ), .T.)
								If !lMiddleware
									If cVersEnvio >= "9.0"
										cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + Iif(lGeraMat, GetMemVar("RA_CODUNIC"), "") + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
									Else
										cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
									EndIf
									cStatus := TAFGetStat( "S-2300", cCPF )
								Else
									If cVersEnvio >= "9.0" .And. lGeraMat
										cCPF := AllTrim( GetMemVar("RA_CODUNIC"))
									Else
										cCPF := AllTrim( GetMemVar("RA_CIC") ) + AllTrim( GetMemVar("RA_CATEFD") ) + DTOS( GetMemVar("RA_ADMISSA") )
									EndIf

									cStatus := "-1"
									fPosFil( cEmpAnt, cFilAnt )
									aInfoC   := fXMLInfos()
									If LEN(aInfoC) >= 4
										cTpInsc  := aInfoC[1]
										lAdmPubl := aInfoC[4]
										cNrInsc  := aInfoC[2]
									Else
										cTpInsc  := ""
										lAdmPubl := .F.
										cNrInsc  := "0"
									EndIf
									cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
									cStatus 	:= "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									GetInfRJE( 2, cChaveMid, @cStatus )
								EndIf
								If ( lIntegra ) .And. !(GetMemVar("RA_CATEFD") $ cCatTSV) .or. ( cStatus <> "-1" .And. GetMemVar("RA_CATEFD") $ cCatTSV .And. (lMiddleware .Or. !lMiddleware .And. C9V->C9V_NOMEVE != "TAUTO") )
									If cStatus != "4"
										Help(,,OemToAnsi(STR0076),,OemToAnsi(STR0435),1,0)//"Registro não foi enviado pois o funcionário não foi transmitido ao RET."
										lRet := .F.
									Else
										If(!Empty( M->RA_DEMISSA ))
											lRet:= fInt2399New(/*aCols*/,/*aErros*/,"S2399",/*cCodDslg*/,"1",  /*aPd*/,/*dDataRes*/,/*cDiasInde*/,cVersEnvio, nOpc)
											//Valida a Demissão do funcionario
											If lRet
												M->RA_SITFOLH := "D"
											EndIf
										Else
											lRet:= fInt2399New(/*aCols*/,/*aErros*/,"S2399",/*cCodDslg*/,"1",  /*aPd*/,/*dDataRes*/,/*cDiasInde*/,cVersEnvio, 5)
										EndIf
									EndIf

									//Verifica se o sistema informa ou não a integração com sucesso no TAF
									If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
										fEFDMsg()
									EndIf
								EndIf
							EndIf

						//Alteração Contratual
						Else
							If cVersEnvio >= "9.0.00"
								cCodUnico := SRA->RA_CODUNIC

								If( Empty(cCodUnico) )
									cCodUnico:= fRACodUnic(.F.)
								EndIf
							Endif
							//Inclusão de novo evento
							If ( aTpAlt[1] )
								lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2300", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE, , @lNT15 ), .T.)
								If ( lIntegra )  .And. lGera2300
									If !lMiddleware
										If cVersEnvio >= "9.0.00"
											cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + Iif(lGeraMat, GetMemVar("RA_CODUNIC"), "") + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
										Else
											cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
										Endif
										cStatus := TAFGetStat( "S-2300", cCPF )

										If (SRA->RA_ADMISSA <> GetMemVar("RA_ADMISSA") ) .And. lRet .And. nOpc == 4
											If cStatus == '4'
												Help(,,OemToAnsi(STR0076),,OemToAnsi(STR0447),1,0)//"A data de admissão não pode ser alterada, pois o registro de admissão ja foi transmitido ao Ret
												lRet := .F.
											Endif
										Endif
									Else
										cCPF := If(cVersEnvio >= "9.0" .And. lGeraMat, GetMemVar("RA_CODUNIC"), AllTrim( GetMemVar("RA_CIC") ) + AllTrim( GetMemVar("RA_CATEFD") ) + DTOS( GetMemVar("RA_ADMISSA")))
										cStatus := "-1"
										fPosFil( cEmpAnt, cFilAnt )
										aInfoC   := fXMLInfos()
										If LEN(aInfoC) >= 4
											cTpInsc  := aInfoC[1]
											lAdmPubl := aInfoC[4]
											cNrInsc  := aInfoC[2]
										Else
											cTpInsc  := ""
											lAdmPubl := .F.
											cNrInsc  := "0"
										EndIf
										cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, fTamRJEKey(), " ")
										//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
										GetInfRJE( 2, cChaveMid, @cStatus, , @cRetf2300 )
									Endif
									If lRet
										//Caso nao tenha sido enviado ao Ret ou se for retificação com campo RA_DESCEP igual a 1
										If cVersEnvio >= '9.0' .And. (lGeraMat  .And. cStatus=="4") .Or. (cStatus <> "4" .And. If(lMiddleware, cRetf2300 <>"2", Empty(C9V->C9V_VERANT) ) )
											cGeraMat := "1"
											lRet := fInt2300New("SRA",/*lAltCad*/,nOpc,"S2300",/*lAltCad*/,/*aDadosXml*/,cVersEnvio,,,,,,,,,,cGeraMat)
											If lRet
												SetMemVar( "RA_DESCEP", "1" )
											Endif
										Else
											lRet := fInt2300New("SRA",/*lAltCad*/,nOpc,"S2300",/*lAltCad*/,/*aDadosXml*/,cVersEnvio)
										ENDIF
										lRet2206 := lRet

										//Verifica se o sistema informa ou não a integração com sucesso no TAF
										If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
											fEFDMsg()
										EndIf
									Endif
								EndIf
							ElseIf (lMiddleware .Or. (!lMiddleware .And. C9V->C9V_NOMEVE != "TAUTO") )// A tabela C9V foi posicionada na chamada da função TAFGetStat
								//A alteração cadastral do TSV é feito através do evento S-2205 também.
								If ( aTpAlt[3] )  .And. lGera2300 .And. M->RA_SITFOLH <> "D"
									lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2205", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE, , @lNT15 ), .T.)

									If( lIntegra )
										lRet := fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2205",/*cTFilial*/,/*aDep*/,/*cCodUnico*/,/*oModel*/,/*cOrigem*/,/*@aErros*/,cVersEnvio)

										//Verifica se o sistema informa ou não a integração com sucesso no TAF
										If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
											fEFDMsg()
										EndIf
									EndIf
								EndIf

								//Alteração Contratual
								If( aTpAlt[4] )  .And. lGera2300
									lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2306", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE, , @lNT15), .T.)

									If !lMiddleware
										If cVersEnvio >= "9.0"
											cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + Iif(lGeraMat, GetMemVar("RA_CODUNIC"), "") + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
										Else
											cCPF := AllTrim( GetMemVar("RA_CIC") ) + ";" + AllTrim( GetMemVar("RA_CATEFD") ) + ";" + DTOS( GetMemVar("RA_ADMISSA") )
										EndIf
										cStatus := TAFGetStat( "S-2300", cCPF )
									Else
										If cVersEnvio >= "9.0" .And. lGeraMat
											cCPF := AllTrim( GetMemVar("RA_CODUNIC"))
										Else
											cCPF := AllTrim( GetMemVar("RA_CIC") ) + AllTrim( GetMemVar("RA_CATEFD") ) + DTOS( GetMemVar("RA_ADMISSA") )
										EndIf

										cStatus := "-1"
										fPosFil( cEmpAnt, cFilAnt )
										aInfoC   := fXMLInfos()
										If LEN(aInfoC) >= 4
											cTpInsc  := aInfoC[1]
											lAdmPubl := aInfoC[4]
											cNrInsc  := aInfoC[2]
										Else
											cTpInsc  := ""
											lAdmPubl := .F.
											cNrInsc  := "0"
										EndIf
										cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
										cStatus 	:= "-1"
										//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
										GetInfRJE( 2, cChaveMid, @cStatus )
									EndIf

									If( lIntegra )  .And. cStatus == "4"
										dAltSal := If( !Empty(GetMemVar("RA_DATAALT")), GetMemVar("RA_DATAALT"), Nil )
										lRet := fInt2306New("SRA",/*lAltCad*/,nOpc,"S2306",/*lAltCad*/,/*lAltCad*/, cVersEnvio, Nil, Nil, Nil, dAltSal, .T.)
										lRet2206 := lRet

										//Verifica se o sistema informa ou não a integração com sucesso no TAF
										If( lRet ) .And. FindFunction("fEFDMsg") .And. ! lGp010Auto
											fEFDMsg()
										EndIf
									EndIf

								EndIf
							EndIf
						EndIf
					EndIf
				Endif

			EndIf

		EndIf

	End Sequence

	RestArea(aArea)

Return(lRet)

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fVTpAltNew³ Autor ³ Marcos Coutinho       | Data ³ 12/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificar qual o tipo de alteração foi realizada no cad	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fVTpAltNew()    						       				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fVTpAltNew(aTpAlt,lRet,lAltContr,cVersEnvio,aBkpCpos)
Local lRetif  		:= .F.
Local lAltCad 		:= .F.
Local lAltCon 		:= .F.
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local cTrabSemVinc	:= fCatTrabEFD("TSV") //"201|202|304|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Trabalhador sem vinculo
Local cCPF
Local cStatus
Local cStat1
Local aContainer 	:= {}
Local lAgntPubl 	:= Iif(FunName() == "GPEA931", .T., .F.)
Local lTrabVinc		:= .F.
Local lTrabSVinc	:= .F.
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"
Local aInfoC		:= {}
Local cBkpFil		:= cFilAnt
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.

DEFAULT lRet := .T.
DEFAULT lAltContr := .F.
DEFAULT cVersEnvio	:= "2.2"
DEFAULT aBkpCpos	:= {}

If Funname() == "GPEA931"
	lTrabVinc 	:= SRA->RA_CATEFD $ cTrabVincu
	lTrabSVinc	:= SRA->RA_CATEFD $ cTrabSemVinc
Else
	lTrabVinc 	:= M->RA_CATEFD $ cTrabVincu
	lTrabSVinc	:= M->RA_CATEFD $ cTrabSemVinc
Endif

	//Cadastro normal
	If !lAgntPubl
		lRetif :=  fAltRetNew(cVersEnvio, aBkpCpos)

		If !lRetif
			lAltCad := fAltCadNew(cVersEnvio, aBkpCpos) // alterado cadastro
			lAltCon := fAltConNew(lAltContr, cVersEnvio, aBkpCpos ) // alterado dados contrato
		EndIf

	//Agente Publico
	Else
		lAltCon := lAltContr  // alterado dados contrato agente publico
	Endif

	aAdd( aContainer, { lRetif, lAltCad, lAltCon } )

	aTpAlt := {.F.,.F.,.F.,.F.}
	//posicao 1 - 2200
	//posicao 2 - 2100
	//posicao 3 - 2205
	//posicao 4 - 2206 ou 2306

	//-------------------------
	//| Verificao de alteração
	//| Verifica se houve alguma alteração Retificadora, Cadastral ou Contratual dentro da SRA
	//| OU verifica se houve alguma alteração Contratual dentro da RFS (Estagiário)
	//------------------------------------------------------------------------------
	If (lRetif .or. lAltCad .or. lAltCon .or. lAltContr) .and. lRet
		If  (cVersEnvio >= "9.0" .And. lOpeSoc .And. (SRA->RA_CATFUNC == "9" .Or. SRA->RA_EAPOSEN == "1" ))
			cCPF := AllTrim(SRA->RA_CIC)
		ElseIf lTrabVinc
			cCPF := AllTrim(SRA->RA_CIC) + ";" + SRA->RA_CODUNIC
		ElseIf lTrabSVinc
			If cVersEnvio >= "9.0"
				If !lMiddleware
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				Else
					If lGeraMat //chave mid antiga ou só codunic
						cCPF := SRA->RA_CODUNIC
					Else
						cCPF := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
					EndIf
				EndIf
			Else
				If !lMiddleware
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
				Else
					cCPF := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
				EndIf
			EndIf
		EndIf

		If cVersEnvio >= "9.0" .And. lOpeSoc .And. (SRA->RA_CATFUNC == "9" .Or. SRA->RA_EAPOSEN == "1" )
			cStatus := TAFGetStat( "S-2400", cCPF )
			cStat1 		:= "-1"
		ElseIf (M->RA_CATEFD $ cTrabVincu) // Se for trabalhador com vinculo
			If !lMiddleware
				cStatus := TAFGetStat( "S-2200", cCPF )
				cStat1 := TAFGetStat( "S-2100", cCPF )
			Else
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, fTamRJEKey(), " ")
				cStatus 	:= "-1"
				cStat1 		:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus )
			EndIf
		elseif(M->RA_CATEFD $ cTrabSemVinc) //Se for trabalhador sem vinculo
			If !lMiddleware
				cStatus := TAFGetStat( "S-2300", cCPF )
			Else
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, fTamRJEKey(), " ")
				cStatus 	:= "-1"
				cStat1 		:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus )
			EndIf
			cStat1 := "-1"
		Endif

		lRet := fStatusTAF(@aTpAlt,cStatus,cStat1,"GPEA010", aContainer)

	Endif
Return lRet

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAltCadNew³ Autor ³ Marcia Moura          | Data ³ 11/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificar se eh uma alteracao cadastral            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fAltCadNew()    					       				 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fAltCadNew(cVersEnvio, aBkpCpos)

	Local aArea 		:= GetArea()
	Local lRet 			:= .F.
	Local nI			:= 0
	Local nPos
	Local lMsgAuto		:= .F.
	Local lGpe010		:= !( Type("aSraHeader") == "U" )
	Local aCposCad		:= {"RA_NOMECMP","RA_NOME","RA_SEXO","RA_RACACOR","RA_ESTCIVI","RA_GRINRAI","RA_CLASEST",;
						"RA_PORTDEF","RA_OBSDEFI", "RA_LOGRTP", "RA_LOGRDSC", "RA_LOGRNUM", "RA_COMPLEM", "RA_BAIRRO",;
						"RA_CEP","RA_CODMUN","RA_ESTADO","RA_PAISEXT","RA_EMAIL","RA_DDDFONE","RA_TELEFON",;
						"RA_CPOSTAL","RA_NSOCIAL"}
						//"RA_DDDCELU","RA_NUMCELU","RA_CPOSTAL","RA_NSOCIAL", "RA_CTPCD"}
	Local aAntS10		:= {"RA_DDDCELU","RA_NUMCELU","RA_EMAIL2","RA_PIS","RA_NUMCP",'RA_SERCP',"RA_UFCP","RA_NUMRIC","RA_EMISRIC",;
						"RA_DEXPRIC","RA_RG","RA_RGEXP","RA_DTRGEXP","RA_RNE","RA_RNEORG","RA_RNEDEXP","RA_CODIGO",;
						"RA_OCEMIS","RA_OCDTEXP","RA_OCDTVAL","RA_HABILIT","RA_DTEMCNH","RA_UFCNH","RA_DTVCCNH","RA_CATCNH",;
						"RA_DATCHEG","RA_CASADBR","RA_FILHOBR"}

	DEFAULT cVersEnvio := "2.2"
	DEFAULT aBkpCpos   := {}

	If cVersEnvio >= "2.3"
		If lOpeSoc
			If cVersEnvio >=  '9.0.00
				aCposCad := {"RA_NOMECMP","RA_NOME","RA_SEXO","RA_RACACOR","RA_ESTCIVI","RA_LOGRTP", "RA_LOGRDSC", "RA_LOGRNUM", ;
				 			"RA_COMPLEM", "RA_BAIRRO","RA_CEP","RA_CODMUN","RA_ESTADO","RA_PAISEXT","RA_EMAIL","RA_DDDFONE","RA_TELEFON",;
							"RA_CPOSTAL","RA_TIPINF"}
			Endif
		Else
			If cVersEnvio <  '9.0.00'
				aAdd(aCposCad,"RA_DTINCON")
			EndIf
			If cVersEnvio >=  '2.4.02'
				If cVersEnvio <  '9.0.00'
					aAdd(aCposCad,"RA_MAE")
					aAdd(aCposCad,"RA_PAI")
				EndIf
				aAdd(aCposCad,"RA_NASC")
				if !lnt15
					aAdd(aCposCad,"RA_CODMUNN")
				endif
				aAdd(aCposCad,"RA_CPAISOR")
				aAdd(aCposCad,"RA_NACIONC")
				aAdd(aCposCad,"RA_VIEMRAI")
			EndIf

			If cVersEnvio >=  '9.0.00
				aAdd(aCposCad,"RA_CTPCD")
			EndIf

			If cVersEnvio >= "9.0.00" .And. cPaisLoc == "BRA" .And. SRA->(ColumnPos("RA_TIPOVIA")) > 0
				aAdd(aCposCad, "RA_TIPOVIA")
			EndIf
		Endif
	Endif

	If cVersEnvio < "9.0.00"
		For nI := 1 To Len(aAntS10)
			aAdd(aCposCad,aAntS10[nI])
		Next
	EndIf

	If cPaisLoc == "BRA"
		//Verifica se rotina automatica
		If !IsBlind()
			For nI := 1 To Len(aCposCad)
				//Considera somente os campos que estao disponiveis para alteracao
				If &('SRA->' + aCposCad[nI]) <> GETMEMVAR(aCposCad[nI])
					// CASO TENHA ALTERADO O CONTEUDO DO CAMPO RA_NOME, VALIDA SE O CAMPO RA_NOMECMP
					// ESTA EM BRANCO PARA ENVIAR O EVENTO S-2205.
					If Alltrim(aCposCad[nI]) == 'RA_NOME' .And. !Empty(GETMEMVAR('RA_NOMECMP'))
						Loop
					Else
						lRet := If( lGpe010, aScan(aSraHeader, { |x| x[2] == aCposCad[nI] }) > 0, .T. )
					EndIf
				Endif
			neXT nI
		Else
			If Empty(aBkpCpos)
				aCposMem := aClone(aSaveCpos)
			Else
				aCposMem := aClone(aBkpCpos)
			EndIf
			For nI:= 1 to Len(aCposCad)
				If (nPos := aScan(aCposMem, {|x| x[1] == aCposCad[nI]})) > 0
					If &("SRA->" + aCposCad[nI]) != aCposMem[nPos][2]
						lRet := .T.
						EXIT
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	RestArea(aArea)

Return(lRet)


/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAltRetNew³ Autor ³ Marcia Moura          | Data ³ 03/08/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificar se eh retificacao                       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fAltRetNew()    						       			 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao aplica.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fAltRetNew(cVersEnvio, aBkpCpos)
Local aArea 		:= GetArea()
Local lRet 			:= .F.
Local nI			:= 0
Local nPos
Local lMsgAuto		:= .F.
Local lGpe010		:= !( Type("aSraHeader") == "U" )
Local aCposCad		:= {"RA_ADMISSA","RA_OPCAO"}
Local aCposMem		:= {}
Local LVERGP010		:= TYPE("LGP010AUTO") == "U"

DEFAULT cVersEnvio := "2.2"
DEFAULT aBkpCpos   := {}

If LVERGP010
	lGp010Auto := .F.
EndIf

//Inclui os campos RA_TIPOADM e RA_ALTOPC que estavam na array aCposCad quando versão do eSocial menor que S-1.0
If cVersEnvio < "9.0.00"
	aAdd(aCposCad,"RA_TIPOADM")
	aAdd(aCposCad,"RA_ALTOPC")
EndIf

If cVersEnvio >= "2.4"
	If lOpeSoc
		If cVersEnvio >= "9.0.00"
			aCposCad := {}
			aAdd(aCposCad,"RA_DTREC")
		EndIf
	Else
		aAdd(aCposCad,"RA_VIEMRAI")
		If cVersEnvio >= '2.6.00' .And. cVersEnvio < "9.0.00"
			aAdd(aCposCad,"RA_TIPOAFP")
			aAdd(aCposCad,"RA_DECRLEI")
		Endif
		If cVersEnvio < '2.4.02'
			aAdd(aCposCad,"RA_MAE")
			aAdd(aCposCad,"RA_PAI")
			aAdd(aCposCad,"RA_NASC")
			if !lnt15
				aAdd(aCposCad,"RA_CODMUNN")
			endif
			aAdd(aCposCad,"RA_CPAISOR")
			aAdd(aCposCad,"RA_NACIONC")
		EndIf
		If cVersEnvio < "9.0.00"
			aAdd(aCposCad,"RA_NATURAL")
		EndIf
		If cVersEnvio >= "9.0.00"
			aAdd(aCposCad,"RA_NASC")
			aAdd(aCposCad,"RA_CPAISOR")
			If lGpe010 
			   If M->RA_TPCONTR <> "1"
					aAdd(aCposCad,"RA_CLAURES")
				Endif	
			Else
				If 	SRA->RA_TPCONTR <> "1"  
					aAdd(aCposCad,"RA_CLAURES")
				Endif	
			Endif
		EndIf
	Endif
Else
	aAdd(aCposCad,"RA_MAE")
	aAdd(aCposCad,"RA_PAI")
	aAdd(aCposCad,"RA_NASC")
	if !lnt15
		aAdd(aCposCad,"RA_CODMUNN")
	endif
	aAdd(aCposCad,"RA_CPAISOR")
	aAdd(aCposCad,"RA_NACIONC")
EndIf


If cPaisLoc == "BRA"
	//Verifica se rotina automatica
	If !IsBlind()
		For nI := 1 To Len(aCposCad)
			If &('SRA->' + aCposCad[nI])  <> GETMEMVAR(aCposCad[nI])
				//Considera somente os campos que estao disponiveis para alteracao
				If !(aCposCad[nI] = "RA_VIEMRAI") .Or. (cVersEnvio < "9.0.00") .Or.;
				((aCposCad[nI] = "RA_VIEMRAI") .And. &('SRA->' + aCposCad[nI]) $ "30*31*35" .And. !(GETMEMVAR(aCposCad[nI]) $ "30*31*35")) .Or.;
				((aCposCad[nI] = "RA_VIEMRAI") .And. !(&('SRA->' + aCposCad[nI]) $ "30*31*35") .And. (GETMEMVAR(aCposCad[nI]) $ "30*31*35"))
					lRet := If( lGpe010, aScan(aSraHeader, { |x| x[2] == aCposCad[nI] }) > 0, .T. )
				EndIf
			EndIf
		neXT nI
	Else
		If Empty(aBkpCpos)
			aCposMem := aClone(aSaveCpos)
		Else
			aCposMem := aClone(aBkpCpos)
		EndIf
		For nI:= 1 to Len(aCposCad)
			If (nPos := aScan(aCposMem, {|x| x[1] == aCposCad[nI]})) > 0
				If &("SRA->" + aCposCad[nI]) != aCposMem[nPos][2]
					If !(aCposCad[nI] = "RA_VIEMRAI") .Or. (cVersEnvio < "9.0.00") .Or.;
					((aCposCad[nI] = "RA_VIEMRAI") .And. &('SRA->' + aCposCad[nI]) $ "30*31*35" .And. !(aCposMem[nPos][2] $ "30*31*35")) .Or.;
					((aCposCad[nI] = "RA_VIEMRAI") .And. !(&('SRA->' + aCposCad[nI]) $ "30*31*35") .And. (aCposMem[nPos][2] $ "30*31*35"))
						lRet := .T.
						EXIT
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndIf

	RestArea(aArea)
Return(lRet)


/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAltConNew³ Autor ³ Marcia Moura          | Data ³ 03/08/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificar se eh alteracao contratual                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fAltConNew()    						       				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lAltEst - Verifica alteracao contratual estagiario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010  - Botao Confirmar da rotina                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fAltConNew( lAltEst, cVersEnvio, aBkpCpos)

	Local aArea 		:= GetArea()
	Local lRet 			:= .F.
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
	Local cTrabSemVincu	:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Trabalhador sem vinculo
	Local nI			:= 0
	Local nPos
	Local lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.)
	Local lGpe010		:= !( Type("aSraHeader") == "U" )
	Local aCposCad		:= {}
	Local aAntS10		:= {"RA_TPCONTR","RA_TNOTRAB","RA_HOPARC","RA_REGRA"}

	Default lAltEst := .F.
	DEFAULT cVersEnvio := "2.2"
	DEFAULT aBkpCpos   := {}

	 // S-2206 
	If SRA->RA_CATEFD $ cTrabVincu
		aCposCad		:= {"RA_TPPREVI","RA_TPJORNA","RA_CATEFD","RA_SALARIO","RA_CATFUNC","RA_DTFIMCT","RA_HRSEMAN","RA_NJUD14","RA_TIPOPGT","RA_CODFUNC","RA_SINDICA"}
	// S-2306 
	ElseIf SRA->RA_CATEFD $ cTrabSemVincu 
		aCposCad		:= {"RA_TPPREVI","RA_CATEFD","RA_SALARIO","RA_CATFUNC","RA_TIPOPGT","RA_CODFUNC"}
	EndIf

	If M->RA_CATEFD == '103' // Inclusão de dois campos para verificação, caso o funcinário seja Menor Aprendiz
		aAdd(aCposCad,"RA_PLAPRE")
		aAdd(aCposCad,"RA_TIPCTA")
	EndIf

	If lCargSQ3
		aAdd(aCposCad,"RA_CARGO")
	EndIf

	If cVersEnvio < '9.0'
		For nI := 1 to Len(aAntS10)
			aAdd(aCposCad,aAntS10[nI])
		Next nI
	EndIf
	If cVersEnvio >= "2.3"
		aAdd(aCposCad,"RA_DESEPS")
		If SRA->(ColumnPos("RA_TIPOCON")) > 0 .And. cVersEnvio < '9.0'
			aAdd(aCposCad,"RA_TIPOCON")
		EndIf
		If cVersEnvio == "2.3"
			aAdd(aCposCad,"RA_VIEMRAI")
		Endif
	Else
		aAdd(aCposCad,"RA_VIEMRAI")
	Endif

	If cPaisLoc == "BRA"
		If SRA->RA_CATEFD $ cTrabVincu .OR. SRA->RA_CATEFD $ cTrabSemVincu //Verifica vinculo
			// verifica se é rotina automática
			If !IsBlind()

				//Realiza se houve alteração contratual nos campos da SRA - Cadastro de Funcionário
				For nI := 1 To Len(aCposCad)
					if &('SRA->' + aCposCad[nI])  <> GETMEMVAR(aCposCad[nI])
						//Considera somente os campos que estao disponiveis para alteracao
						lRet := If( lGpe010, aScan(aSraHeader, { |x| x[2] == aCposCad[nI] }) > 0, .T. )
					Endif
				neXT nI
			Else
				If Empty(aBkpCpos)
					aCposMem := aClone(aSaveCpos)
				Else
					aCposMem := aClone(aBkpCpos)
				EndIf
				For nI:= 1 to Len(aCposCad)
					If (nPos := aScan(aCposMem, {|x| x[1] == aCposCad[nI]})) > 0
						If &("SRA->" + aCposCad[nI]) != aCposMem[nPos][2]
							lRet := .T.
							EXIT
						EndIf
					EndIf
				Next
			EndIf
		EndIf

		//Se houve alteração nos dados do estagiário (contrato), lRet recebe seu valor
		If lAltEst
			lRet := lAltEst
		EndIf

	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} fTpConSVA
Checa RA_TIPOCON + se tem SVA p/ integrar ou não o tipo de contrato determinado pela ocorrência de um fato
@author  isabel.noguti
@since   10/07/2019
@version 12.1.25
/*/
Static Function fTpConSVA()
	Local lInteg	:= .T.
	Local aArea		:= GetArea()
	Local lTipoCon	:= SRA->(ColumnPos("RA_TIPOCON")) > 0

	If GetMemVar("RA_TPCONTR") == "2" .And. Empty(GetMemVar("RA_DTFIMCT"))
		If Chkfile("SVA")
			If lTipoCon .And. GetMemVar("RA_TIPOCON") == "1"
				dbSelectArea("SVA")
				SVA->(dbSetOrder(1))//VA_FILIAL+VA_MATRIC
				If !SVA->( dbSeek( xFilial("SRA") + GetMemVar("RA_MAT") ))
					Help("",1,OemtoAnsi(STR0076),,OemtoAnsi(STR0429),1,0) //Tipo de contrado determinado pela ocorrência de um fato sem registro na tabela SVA. O cadastro do funcionário será gravado na SRA, porém para integração com o TAF será necessário informar suas Observações Contratuais.
					lInteg := .F.
				EndIf
			EndIf
		Else
			Help( ,,OemtoAnsi(STR0076),,StrTran(STR0379,"[U]","UPDDISTR"), 1, 0 ) //Favor realizar a aplicação do UPDDISTR, para a criação da tabela SVA - Observ Contrato de Trabalho
			lInteg := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lInteg

/*/{Protheus.doc} SaveMenVar
Salva o conteúdo atual (Valor gravado na SRA) dos campos passados no aRotAuto
@author Cícero Alves
@since 26/11/2018
@version 12.1.17
/*/
Function SaveMenVar(aRotAuto)

	Local aArea := GetArea()
	local nPosMat := Ascan(aRotAuto,{|x| Alltrim(x[1]) == "RA_MAT"})
	Local nPosFil := Ascan(aRotAuto,{|x| Alltrim(x[1]) == "RA_FILIAL"})
	Local nI

	Static aSaveCpos := {}

	dbSelectArea("SRA")
	dbSetOrder(1)

	If nPosFil > 0 .And. nPosMat > 0 .And. SRA->(dbSeek(aRotAuto[nPosFil][2] + aRotAuto[nPosMat][2]))
		aSaveCpos := {}
		For nI:= 1 to Len(aRotAuto)
			// Apenas campos Reais
			If aRotAuto[nI][1] != "INDEX" .And. GetSx3Cache(aRotAuto[nI][1], "X3_CONTEXT") $ " |R"
				Aadd(aSaveCpos, {aRotAuto[nI][1], &("SRA->" + aRotAuto[nI][1])})
			EndIf
		Next
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} fRJ5Filt
Pesquisa as lotações com campo da filial do trabalhador preenchidos
@type      	Static Function
@author Silvia Taguti
@since 04/11/2020
@version	1.0
@return aRJ5Fil
/*/

Static Function fRJ5Filt()
Local aAreaRJ5   	:= RJ5->(GetArea())
Local aRJ5Fil   := {}
Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0

RJ5->(dbSetOrder(7))
RJ5->(dbGotop())

	While RJ5->(!Eof()) .AND. RJ5->RJ5_FILIAL == XFILIAL('RJ5')
		If lFilT .And. !Empty(RJ5->RJ5_FILT)
			AADD(aRJ5Fil,{RJ5->RJ5_FILIAL, RJ5->RJ5_CC, RJ5->RJ5_FILT, RJ5->RJ5_COD, RJ5->RJ5_INI})
		Endif
		RJ5->(dbSkip())
	EndDo

RJ5->(dbGotop())

RestArea(aAreaRJ5)

Return aRJ5Fil


/*/{Protheus.doc} fPesRS9
Pesquisa se há registro na tabela RS9 para a matrícula
@type      	Static Function
@author lidio.oliveira
@since 03/01/2021
@version	1.0
@return lRet
/*/
Static Function fPesRS9(cChave)

Local aArea   	:= GetArea()
Local lRet		:= .F.
Local lAudesp	:= SuperGetMv('MV_AUDESP',, .F.)

Default cChave	:= ""

	If !Empty(cChave)
		dbSelectArea("RS9")
		RS9->(dbSetOrder(1))//RS9_FILIAL+RS9_MAT
		If RS9->( dbSeek( cChave ))
			If lAudesp .AND. RS9->RS9_REGJUR=="1"
                lRet := .F.
            Else 
                lRet := .T.
            EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
