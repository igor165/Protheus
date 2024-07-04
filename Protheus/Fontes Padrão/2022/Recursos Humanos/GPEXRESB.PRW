#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXRESB.CH" 

Static __lMemCalc
Static lContrInt
Static lResAntPLR
Static lIniTab 		:= .T.
Static lTemSeqMV
Static lConsig		:= GetMvRH("MV_CONSIG",, .F.)
Static lCpoFlagIC	:= SRG->(ColumnPos("RG_CONFIC")) > 0
Static nTamSind		:= TamSX3("RA_SINDICA")[1]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr.  ³08/12/13³M12RH01         ³Unificacao das Folhas. Projeto Versao 12  ³±±
±±³             ³        ³REQ.: 001973    ³Criacao do Fon"te. Funcoes de calculo      ³±±
±±³             ³        ³                ³utilizadas na rescisao do Brasil          ³±±
±±³Flavio C.    ³09/06/14³TPUOTR     	  ³REPLICA V11 Ajuste p/ tratar nova opcao   ³±±
±±³             ³        ³           	  ³preenchimento do campo X14_RECFAT.	     ³±±  
±±³Raquel Hager ³25/06/14³TPUQVJ     	  ³Replica V11 - Ajuste campo RD_DATPGT e na ³±±
±±³             ³        ³           	  ³funcao fPagMultConEx.	 			     ³±±
±±³Wagner Mobile³23/01/15³TQQXD5     	  ³Calculo de multa por quebra de contrato p/³±±
±±³             ³        ³           	  ³tempo determinado    	 			     ³±±
±±³Allyson M    ³15/10/15³TTJMBX     	  ³Tratamento para abater da garantia de     ³±±
±±³             ³        ³           	  ³comissao as medias de ferias, 13o. e      ³±±
±±³             ³        ³           	  ³aviso previo.                             ³±±
±±³Gustavo M    ³01/12/15³PCDEF-86054  	  ³Correção da busca por pagamentos de 13    ³±±
±±³Allyson M    ³07/12/15³TTYQ63     	  ³Correção da busca por pagamentos de 13    ³±±
±±|Allyson M    |08/12/15|TTQKD1     	  |Tratamento para nao gerar valor negativo  ³±±
±±|             |        |           	  |na rescisao complementar					 ³±±
±±|M. Silveira  |10/12/15|TTXUZU     	  |Correcao na validacao os itens do aPd sem ³±±
±±|             |        |           	  |valor na funcao fAbatPago.                ³±±
±±³Cícero Alves ³28/12/15³TUBXVA          ³Correção nas chamadas da função fGetCodFol³±±
±±³             ³        ³                ³      				     ³±±
±±³Cícero Alves ³28/12/15³TUBQGB          ³Ajuste p/ gerar o valor da 1o. parcela do ³±±
±±³             ³        ³                ³13o. calculada no mesmo mes da rescisao.  ³±±
±±³Allyson M    ³29/12/15³TUCRG2     	  ³Ajuste em fCaraPdR() p/ carregar as verbas³±±
±±³             ³        ³           	  ³dos Ids 0106 e 0107 que estejam no roteiro³±±
±±³             ³        ³           	  ³ADI no calculo de rescisao                ³±±
±±³Allyson M    ³05/01/16³TUCUTQ     	  ³Ajuste em fCal13o() p/ calculo do ID 0114 ³±±
±±³             ³        ³           	  ³p/ nao somar os adicionais do funcionario.³±±
±±³             ³        ³           	  ³Somente ira considerar o Salario ou SalMes³±±
±±³Allyson M    ³14/01/16³TUFEU0     	  ³Ajuste em fCaraPdR() p/ carregar as verbas³±±
±±³             ³        ³           	  ³dos Ids 0106 e 0107 que estejam na SRD e  ³±±
±±³             ³        ³           	  ³no roteiro ADI e no calculo de rescisao   ³±±
±±³Allyson M    ³05/02/16³TUJCHW     	  ³Ajuste em fCaraPdR() p/ carregar as verbas³±±
±±³             ³        ³           	  ³dos Ids 0009 e 0010 que estejam na SRD/RGB³±±
±±³             ³        ³           	  ³e no roteiro ADI p/ o calculo de rescisao.³±±
±±³             ³        ³           	  ³Tambem foi efetuado ajuste p/ trazer as   ³±±
±±³             ³        ³           	  ³mesmas verbas quando estiverem na SRC, ou ³±±
±±³             ³        ³           	  ³seja, adiantamento calculado mas sem ter  ³±±
±±³             ³        ³           	  ³sido feito o fechamento.  				 ³±±
±±³             ³        ³           	  ³Ajuste em fCal13o() p/ calculo do ID 0115 ³±±
±±³             ³        ³           	  ³p/ nao somar os adicionais do funcionario.³±±
±±³             ³        ³           	  ³Somente ira considerar o Salario ou SalMes³±±
±±³Claudinei S.³18/02/2016³TUCD45         ³Incluido novo controle para o Aviso Previo³±±
±±³            ³          ³               ³Trabalhado e Indenizado.                  ³±±
±±³Claudinei S.³29/02/2016³TUCD45         ³Incluido tratamento para gravacao do novo ³±±
±±³            ³          ³               ³campo RG_DTPROAV.                         ³±±
±±³Claudinei S.³07/03/2016³TUCD45         ³Ajuste para nao projetar a data quando o  ³±±
±±³            ³          ³               ³tipo do aviso for N ou D.                 ³±±
±±³Claudinei S.³16/03/2016³TURBCB         ³Ajuste em fAtAvProj() para considerar os  ³±±
±±³            ³          ³               ³dias de aviso para a projeção quando o    ³±±
±±³            ³          ³               ³tempo de casa mais 30 dias completar 1 ano³±±
±±ºClaudinei S.³18/03/2016³TUSEC0         ³Ajustada a fAvProj para não projetar os   ³±±
±±º            ³          ³               ³dias do aviso quando o tipo do aviso na   ³±±
±±º            ³          ³               ³S043 for "N".                             ³±±
±±ºClaudinei S.³21/03/2016³TUUEUC         ³fAvProj para não projetar os dias do aviso³±±
±±º            ³          ³               ³quando o tipo do aviso na S043 = "N" e    ³±±
±±º            ³          ³               ³Projeta Aviso = "N", limpar as variaveis  ³±±
±±º            ³          ³               ³do aviso antes de iniciar outro calculo.  ³±±
±±ºRenan Borges³06/04/2016³TUPGC9         ³Ajuste para levar o FGTS do mes anterior  ³±±
±±º            ³          ³               ³na rescisão quando o tipo de rescisão pos-³±±
±±º            ³          ³               ³suir "S" para o campo "FGTS Mes Ant".     ³±±
±±ºRenan Borges³12/04/2016³TUTXB8         ³Ajuste para carregar campo de data aviso e³±±
±±º            ³          ³               ³numeros de aviso corretamente.            ³±±
±±ºRaquel Hager³20/04/2016³TV0922         ³Ajuste para levar Desconto de Ins Saldo   ³±±
±±º            ³          ³               ³(ID 046) informado da Rescisao Original.  ³±±
±±º            ³          ³               ³Ajuste para não considerar para abatimento³±±
±±º            ³          ³               ³verbas informadas.                        ³±±
±±ºAllyson M.  ³13/06/2016³TVBL05         ³Ajuste em fAtDCump() pois a funcao somente³±±
±±º            ³          ³               ³recebera o parametro lIndeniz e recalcular³±±
±±º            ³          ³               ³as ferias devido mudança nos dias de aviso³±±
±±º            ³          ³               ³previo indenizado						 ³±±
±±º            ³          ³TVJSRJ         ³Ajuste quando carregar os lançamentos da  ³±±
±±º            ³          ³               ³RGB p/ so verificar sequencia quando verba³±±
±±º            ³          ³               ³for do tipo horas						 ³±±
±±³Marcia Moura³06/07/2016³TVMEN0         ³Criacao do controle para RA_HOJORVA, onde   ³±±
±±³            ³         ³                ³sera utilizada media de horas como sal. base³±±
±±³Allyson M   ³08/07/2016³TVPHAJ     	  ³Ajuste em fCal13o() p/ calculo do ID 0115 ³±±
±±³            ³          ³           	  ³p/ somar os adicionais do funcionario	 ³±±
±±³Allyson M   ³18/07/2016³TVNTNE     	  ³Ajuste p/ não checar validação de data de ³±±
±±³            ³          ³           	  ³demissão ao preencher os dias de aviso    ³±±
±±³            ³          ³           	  ³devido ao conceito de poder alterar os    ³±±
±±³            ³          ³           	  ³dias de aviso.    						 ³±±
±±³Allyson M   ³02/08/2016³TVSZUF    	  ³Ajuste em fCaraPdR() p/ considerar dados  ³±±
±±³            ³          ³           	  ³da RGB do período seguinte	 			 ³±±
±±|Claudinei S.|05/08/2016|TVQQXK         |Incluida a função fSdSalHoVa() para tratar|±±
±±|            |          |               |as verbas do grupo 0 (RV_GRPVERB) lançadas|±±
±±|            |          |               |na rescisão, as horas dessas verbas serão |±±
±±|            |          |               |as horas do saldo de salário.             |±±
±±³Allyson M   ³29/08/2016³TVWPD8     	  ³Ajuste em fCaraPdR() p/ considerar dados  ³±±
±±³            ³          ³           	  ³da RGB do período seguinte	 			 ³±±
±±³Allyson M   ³19/09/2016³TVVTPR     	  ³Ajuste p/ recalcular os dias de férias ao ³±±
±±³            ³          ³           	  ³alterar os dias de aviso cumprido		 ³±±
±±³Cícero Alves³29/09/2016³TVAZX2     	  ³Ajuste para considerar os dias informados ³±±
±±³            ³          ³           	  ³no cadastro do sindicato para o aviso pre-³±±
±±³            ³          ³           	  ³vio, mesmo com memos de um ano de casa	 ³±±
±±³Allyson M   ³26/10/2016³TWHDNC     	  ³Ajuste em fCaraPdR() p/ também verificar  ³±±
±±³            ³          ³           	  ³os lançamentos no roteiro de PLR		 	 ³±±
±±³Allyson M   ³08/11/2016³TWIMTS     	  ³Ajuste em fSdSalHoVa() p/ não gerar error ³±±
±±³            ³          ³           	  ³log quando a verba de Id 0033 está na RGB ³±±
±±|Claudinei S.|30/11/2016|MRH-1469       |Ajustada fCal13o() para gerar a verba 1385|±±
±±|            |          |TUQEAR         |para empresas que deixaram a desoneração. |±±
±±ºRenan Borges³13/12/2016³MRH-2409       ³Ajuste para gerar saldo de salario correta³±±
±±º            ³          ³               ³mente quando verbas lançadas estiverem ra-³±±
±±º            ³          ³               ³teadas por centro de custo.               ³±±
±±ºRaquel Hager³17/01/2017³MRH-4934       ³Ajuste na função fAtAvProj para calcular  ³±±
±±º            ³          ³               ³anos de casa com projeção de acordo com o ³±±
±±º            ³          ³               ³mnemônico P_CAVPPROJ.                     ³±±
±±ºRenan Borges³29/03/2017³MRH-8998       ³Ajuste para quando realizar o cancelamento³±±
±±º            ³          ³               ³ da integração da rescisão seja retornado ³±±
±±º            ³          ³               ³aos roteiros originais as verbas integra- ³±±
±±º            ³          ³               ³das. Para a efetivação da correção é neces³±±
±±º            ³          ³               ³sário a integração e cancelamento dos da- ³±±
±±º            ³          ³               ³dos novamente.                            ³±±
±±|Claudinei S.|28/04/2017|MRH-482        |Implementado o cálculo para funcionários  |±±
±±|            |          |               |com regime parcial. fAtAvProj()           |±±
±±|Jônatas A.  |16/05/2017|DRHPAG-396     |Ajustes para correta apuração da garantia |±±
±±|            |          |               |de comissão sobre verbas rescisórias,     |±±
±±|            |          |               |desconsiderando as médias de horas extras.|±±
±±³Eduardo K.  ³06/07/2017³MPRIMESP-10549 ³Ajuste em fCaraPdR() p/ considerar dados  ³±±
±±³            ³          ³           	  ³da RGB do período seguinte	 			 ³±±
±±³Jaqueline L.³21/12/2017³DRHPAG-10333   ³Declaração da varíavel LMETFALV para funci³±±
±±³            ³          ³           	  ³onar igual ao fonte gpem040 na FATAVPROJ	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fCaraPdR(lSemAnt,aPdCarr)

	Local cCodPd		:= ""
	Local cRGBSeek		:= SRA->( RA_FILIAL + RA_PROCES + RA_MAT )
	Local cSRCSeek		:= ""
	Local cSRDSeek		:= ""
	Local cCodMSeg		:= ""
	Local cBsFerPg		:= ""
	Local cRotRGB		:= IIf( SRA->RA_CATFUNC $ "A*P" , fGetCalcRot("9") , fGetCalcRot("1") ) + "*" + fGetCalcRot("4") + "*" + fGetCalcRot("2") + "*" + fGetCalcRot("F") //FOL ou AUT*RES*ADI*PLR
	Local cRotAdi		:= fGetCalcRot("2") //ADI
	Local cRotFol		:= fGetRotOrdinar()
	Local cRotRes		:= fGetCalcRot("4") //RES
	Local cRot132		:= fGetCalcRot("6") //132
	Local cTipo2		:= ""
	Local cCodAbon		:= ""
	Local cPerAtu		:= M->RG_PERIODO + M->RG_SEMANA
	Local cPerSeg		:= SomaMesAno(M->RG_PERIODO) + M->RG_SEMANA
	Local cSeqAux		:= ""
	Local cVerbSalSem	:= ( fGetCodFol( "0031", .F. ) + '*' + fGetCodFol( "0032", .F. ) + '*' + fGetCodFol( "0033", .F. ) )
	Local dDataFer		:= CtoD("")
	Local dRefAux		:= CtoD("")
	Local lNoRescMes	:= !( cAnoMes == AnoMes(dDataDem) )
	Local lExistParc	:= .F.
	Local lPagSem		:= ( SRA->RA_TIPOPGT == "S" )
	Local lCarrData		:= .F.
	Local lRefAbono		:= .F.
	Local lVerMultv		:= .F.
	Local nFgtSemAnt	:= 0
	Local nVFgtSemAnt	:= 0
	Local nVCsSemAnt	:= 0
	Local nPosPd		:= 0.00
	Local nPosFer		:= 0
	Local nValAboMs		:= 0.00
	Local nValFerMs		:= 0.00
	Local aAreaRGB		:= {}
	Local aPdAtu		:= {}
	Local aPerAtu		:= {}
	Local aCodFolTran	:= {}
	Local aPerComp		:= {}
	Local nCont			:= 0
	Local nPerComp		:= 0
	Local cChaveCodPd	:= ""
	Local cPdPLR		:= aCodFol[151,1]
	Local lRvCpoPlr		:= SRV->(Columnpos("RV_REFPLR") > 0)
	Local lEmpCons		:= .F.
	Local lOutrosVb		:= .F.
	Local lTemMultV		:= .F.
	Local nPos			:= 0
	Local nSalDev		:= 0
	Local nHorAux		:= 0
	Local nValAux		:= 0
	Local nRefAux		:= 0
	Local nX			:= 0
	Local aVbAuxFer		:= {}
	Local cPdDel		:= aCodFol[35,1] + "/"
	Local aAreaSRD		:= SRD->( GetArea() )
	Local aAreaSRH		:= SRH->( GetArea() )
	Local aAuxGS		:= {}
	Local dIniGS		:= cToD("//")
	Local dFimGS		:= cToD("//")
	Local lIntegGS		:= GetMvRH("MV_TECXRH", NIL, .F. ) .And. FindFunction("Tec353HrRs")
	Local nHrsGS		:= 0
	Local nPosGS		:= 0
	Local cBCalIns		:= ""
	Local cBCalPer		:= ""
	Local nInsGS		:= 0
	Local nPerc_Peri	:= 0
	Local nPerc_Ins		:= 0
	Local nValUmTA		:= 0
	Local nValUmTF		:= 0
	Local cVerbaPLR		:= ( fGetCodFol( "0151", .F. ) + '*' + fGetCodFol( "0152", .F. ) + '*' + fGetCodFol( "0300", .F. ) + '*' + fGetCodFol( "0411", .F. ) + '*' + fGetCodFol( "0835", .F. ) + '*' + fGetCodFol( "0836", .F. ) )

	DEFAULT lSemAnt		:= .T.
	DEFAULT aPdCarr		:= {}

	aPd 				:= aPdCarr
	aPdSemAnt			:= {}		//-- Matriz que armazena lancamentos das semanas anteriors ao pagamento
	lRescPLR			:= .F.
	lResAntPLR			:= .F.
	lVerMultv   		:= If ( Type("P_MULTV") == "U",.F.,P_MULTV)
    cRoteiro			:= cRot

	Static nSRCOrd		:= RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD")
	
	DEFAULT lTemSeqMV	:= If(SRC->(ColumnPos( 'RC_SEQMV' )) > 0,.T.,.F.)

	If lVerMultv .and. lTemSeqMV
		//Verifica se funcionário possui múltiplos vinculos
		lTemMultV := fLoadMultv(.F.) 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o array aCodFolTran com os codigos de verbas de ferias³
	//³do mes e do mes seguinte que devem ser modificados conforme   ³
	//³fechamento mensal. Sera utilizado quando a rescisao for no mes³
	//³seguinte ao mes em aberto.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fCargaTrans(@aCodFolTran,aCodFol)
	
	// Verifica se a rescisão anterior foi para pagamento de PLR no mesmo mês da atual
	If cCompl == "S" .and. (Ascan(aPdResc, {|x| x[1] == cPdPLR .And. AnoMes(x[18]) == AnoMes(M->RG_DTGERAR) .And. x[9] != "D"}) > 0)
		lResAntPLR := .T.
	EndIf
	
	//CAREGA AS VERBAS INFORMADAS NA RESCISAO ANTERIOR, QUANDO COMPLEMENTAR
	If cCompl == "S"
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se a verba de desconto de insuficiencia de saldo (id 46) ja ³
		³foi descontada em alguma rescisao.	Se sim, armazenar este valor para ³
		³nao desconta-lo novament.						                      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nPos := aScan(aPdResc,{ |x| x[1] == aCodFol[046,1] .and. x[9] # "D" }) 
		IF nPos > 0                                                            
			nSalDev := aPdResc[nPos,5] 
		EndIF
		
		For nCont := 1 to Len(aPdResc)
			//Se a verba for informada, ter sido calculada no mesmo mês da última complementar e já existir ela no aPd  indica que esta é o último cálculo da diferença
			//portanto elimina ela do Apd para que seja recalculada.
			If aPdResc[nCont,7] == "I" .and. AnoMes(aPdResc[nCont,18]) == AnoMes(M->RG_DTGERAR) .and. aScan(aPd, {|X| x[1] == aPdResc[nCont,1] .And.  x[2] == aPdResc[nCont,2] .and. AnoMes(x[18]) < AnoMes(aPdResc[nCont,18]) }) > 0
				aPdResc[nCont,9] := "D"
				Loop
			EndIf

			//Se possuir verba de PLR de outra complementar no mesmo mês não carrega na rescisão complementar atual
			If aPdResc[nCont,1] $ cVerbaPLR .And. cCompl == "S" .And. AnoMes(aPdResc[nCont,18]) == AnoMes(M->RG_DTGERAR) .And. !fcheckRGB()
				aPdResc[nCont,9] := "D"
				Loop
			Endif 

			If cCompl == "S" .And. lProxMes .And. aPdResc[nCont, 1] == aCodFol[048, 1] .And. aPdResc[nCont, 7] == "I" .And. AnoMes(aPdResc[nCont, 18]) < AnoMes(M->RG_DTGERAR)
				Loop
			EndIf

			If (!(AllTrim(aPdResc[nCont,7]) $ "P*S*A*K*C*R*V*F") .and. aPdResc[nCont,5] <> 0) .Or. aPdResc[nCont,1] == aCodfol[045,1] //045 = insuficiencia de saldo
				
				// Desconto Insuficiencia de Saldo Informada
				If aPdResc[nCont,1] == aCodfol[046,1] 
					If aPdResc[nCont,7] == "I" .and. aPdResc[nCont,5]-nSalDev > 0
						fIncide(aPdResc[nCont,1]) //Carrega verb no aPDV
						aAdd(aPd,aClone(aPdResc[nCont]))
					EndIf
				Else	
					//insuficiencia de saldo		
					If aPdResc[nCont,1] == aCodfol[045,1] 
						aPdResc[nCont,1] := aCodfol[046,1]
						aPdResc[nCont,5] := aPdResc[nCont,5] - nSalDev
						aPdResc[nCont,7] := "I"
						If nPos > 0 .And. aPdResc[nCont,5] == 0
							aPdResc[nPos,5] := 0
							nSalDev 		:= 0
						EndIf
					EndIf			
					fIncide(aPdResc[nCont,1]) //Carrega verb no aPDV
					aAdd(aPd,aClone(aPdResc[nCont]))
				EndIf
			EndIf
		Next nCont
	EndIf
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Posiciona no Funcionario e carrega as Verbas do Movimento em³
	³aPd														 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DbSelectARea("RGB")
	DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_SEQ+DTOS(RGB_DTREF)"))
	
	If RGB->( DbSeek( cRGBSeek ) )
		
		While RGB->( !Eof() .and. cRGBSeek == RGB_FILIAL + RGB_PROCES + RGB_MAT )
			
			If RGB->( ! (RGB_PERIOD + RGB_SEMANA == cPerAtu) .And. ! (RGB_PERIOD + RGB_SEMANA == cPerSeg))
				RGB->(DbSkip())
				Loop
			ElseIf RGB -> ((RGB_PERIOD + RGB_SEMANA == cPerAtu) .And. (RGB_ROTEIR == "PLR") .And. (RGB_TIPO2 == "I"))
				RGB->(DbSkip())
				Loop
			EndIf
			
			If RGB->RGB_ROTEIR == cRot132
				If !Empty( aCodFol[290,1] ) .and. aCodFol[290,1] == RGB->RGB_PD
					RGB->( fMatriz(RGB_PD,RGB_VALOR,RGB_HORAS,Space(02),RGB_CC,RGB_TIPO1,RGB_TIPO2,0.00,"",RGB_DTREF ) )
				ElseIf !Empty( aCodFol[291,1] ) .and. aCodFol[291,1] == RGB->RGB_PD
					RGB->( fMatriz(RGB_PD,RGB_VALOR,RGB_HORAS,Space(02),RGB_CC,RGB_TIPO1,RGB_TIPO2,0.00,"",RGB_DTREF ) )
				EndIf
				
				If aIncres[5] == "S"
					If !Empty( aCodFol[109,1] ) .and. aCodFol[109,1] == RGB->RGB_PD 		//-- Vlr FGTS 13 Salario
						RGB->( fMatriz(RGB_PD,RGB_VALOR,RGB_HORAS,Space(02),RGB_CC,RGB_TIPO1,RGB_TIPO2,0.00,"D",RGB_DTREF ) ) 
					ElseIf !Empty( aCodFol[299,1] ) .and. aCodFol[299,1] == SRI->RI_PD 	//-- Vlr Contr.Social 13 Salario
						RGB->( fMatriz(RGB_PD,RGB_VALOR,RGB_HORAS,Space(02),RGB_CC,RGB_TIPO1,RGB_TIPO2,0.00,"D",RGB_DTREF ) )
					EndIf
				EndIf	
			EndIf
			
			If !(RGB->RGB_ROTEIR $ cRotRGB)
				RGB->(DbSkip())
				Loop
			EndIf
			
			If RGB->RGB_ROTEIR == cRotAdi .And. !(RGB->RGB_PD $ aCodFol[106,1] + "/" + aCodFol[107,1])//Rend. Bruto Ir. Anter.##Desc. Ir. Anterior
				RGB->(DbSkip())
				Loop
			EndIf
			
			//Caso seja roteiro RES e verba importada do Ponto, verifica se existe lançamento de ponto no roteiro FOL, que foi efetuada pelo processo de integração PON x GPE.
			//Caso exista, a verba do roteiro RES será desprezada do cálculo
			If RGB->RGB_ROTEIR == cRotRes .And. RGB->RGB_ROTORI == "PON"
				aAreaRGB := RGB->( GetArea() )
				nHorAux  := RGB->RGB_HORAS
				dRefAux  := RGB->RGB_DTREF
				RGB->( DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_MAT+RGB_PERIOD+RGB_ROTEIR+RGB_SEMANA+RGB_PD")) )			
				If RGB->( dbSeek( RGB->RGB_FILIAL + RGB->RGB_MAT + RGB->RGB_PERIOD + cRotFol + RGB->RGB_SEMANA + RGB->RGB_PD ) ) .And. RGB->RGB_HORAS == nHorAux .And. RGB->RGB_DTREF == dRefAux
					RestArea( aAreaRGB )
					RGB->(DbSkip())
					Loop
				EndIf			
				RestArea( aAreaRGB )
			EndIf
			
			If lIntegGS .And. AllTrim(RGB->RGB_NUMID) == "GS"
				dIniGS	:= sToD( M->RG_PERIODO + "01" )
				dFimGS	:= LastDate( dIniGS )
				aAuxGS	:= Tec353HrRs(RGB->RGB_FILIAL, RGB->RGB_MAT, dIniGS, dFimGS)
				If (nPosGS := aScan( aAuxGS, { |x| x[1] == RGB->RGB_PD } )) > 0
					nHrsGS := aAuxGS[nPosGS, 2]
					If RGB->RGB_PD $ (aCodFol[36,1] ) .And. SRA->RA_ADCPERI == '1'
						cBCalPer 	:= fBuscaRG4("RCE_BCALPE", dDataAte, .T., .T.)
						nPerc_Peri 	:= RCE->RCE_PERPE
						Pericul(aCodfol, @nIntPercul, SalMes, SalHora, "N", .F. , 0,  RGB->RGB_PD, nHrsGS, cBCalPer, nPerc_Peri, .F.)
						dbSelectArea("RGB")
					ElseIf RGB->RGB_PD $ (aCodFol[37,1] + "/" + aCodFol[38,1] + "/" + aCodFol[39,1]) .And. SRA->RA_ADCINS == '1'
						cBCalIns 	:= fBuscaRG4("RCE_BCALIN", dDataAte, .T., .T.)
						If RGB->RGB_PD == aCodFol[37,1]
							nPerc_Ins  := RCE->RCE_PINSMI
						ElseIf RGB->RGB_PD == aCodFol[38,1]
							nPerc_Ins  := RCE->RCE_PINSME
						Else
							nPerc_Ins  := RCE->RCE_PINSMA
						EndIf
						Insalub(aCodfol, Val_SalMin, @nInsGS, "N",  SalHora, .T., RGB->RGB_PD, nHrsGS, cBCalIns, nPerc_Ins, "2")
						nIntInsal 	:= nInsGS
						dbSelectArea("RGB")
					EndIf
				EndIf
			EndIf

			aRGBSalv	:= {}
			aPerComp	:= {}
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Inicializa cDel                                             ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cDel := " "
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Quando Rescisao for Posterior ao Mes em Aberto nao Carregar³
			³ verbas cuja Data de Pagamento seja inferior ao Mes/Ano   da³
			³ Demissao													 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If ( RGB->RGB_PERIOD < AnoMes(dDataDem) )
				cDel := "D"
			EndIf
			
			cCodPd	:= RGB->RGB_PD
			cTipo2	:= RGB->RGB_TIPO2
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para as verbas de ferias do mes seguinte.                           ³
			//³Devem permanecer no movimento quando ocorrer uma rescisao para o proximo mes   ³
			//³sempre que o mes aberto for diferente do mes da rescisao.                      ³
			//³Serao trocados os codigos das verbas do mes seguinte para os codigos das verbas³
			//³de ferias do mes.                                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNoRescMes
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Despreza as verbas de ferias normais / Base de Ir e Ir mes anterior.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  RGB->RGB_TIPO2 <> "I" .AND. ;
					RGB->RGB_PD $ aCodFol[072,1]+","+aCodFol[075,1]+","+aCodFol[343,1]+","+;
								 aCodFol[345,1]+","+aCodFol[077,1]+","+aCodFol[080,1]+","+;
								 aCodFol[082,1]+","+aCodFol[159,1]+","+aCodFol[074,1]+","+;
								 aCodFol[079,1]+","+aCodFol[084,1]+","+aCodFol[168,1]+","+;
								 aCodFol[410,1]+","+aCodFol[016,1]+","+aCodFol[104,1]+","+;
								 aCodFol[106,1]+","+aCodFol[107,1]+","+aCodFol[044,1]+","+;
								 aCodFol[046,1]
					RGB->(dbskip())
					Loop
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ajusta a verba de 1a parcela do 13o salario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCodPd == aCodFol[022,1]
					cDel		:= " "
					cTipo2		:= "V"
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ajusta as que tem parcela 99 para que nao  ³
				//³sejam excluidas do movimento.              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If RGB->RGB_PARCEL == 99 .And. RGB->RGB_TIPO2 $"E*G*I"
					cDel		:= " "
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa as verbas de ferias e troca os codigos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				If (nPosFer := Ascan(aCodFolTran,{|X| x[1] == cCodPd .And. x[3] == "F"})) > 0
					If cCodPd <> aCodFol[232,1]  // Nao somar valor do INSS erias mes seguinte, pois verba e gerada separadamente.
						cCodPd		:= aCodFolTran[nPosFer,2]
						nValFerMs	+= RGB->RGB_VALOR
						cDel		:= " "
						dDataFer	:= RGB->RGB_DTREF
						cTipo2		:= "V"
					EndIf	
				ElseIf (nPosFer := Ascan(aCodFolTran,{|X| x[1] == cCodPd .And. x[3] == "A"})) > 0
					cCodPd		:= aCodFolTran[nPosFer,2]
					nValAboMs	+= RGB->RGB_VALOR
					cDel		:= " "
					dDataFer	:= RGB->RGB_DTREF
					cTipo2		:= "V"
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa as verbas de Base de Ir e Ir s/folha  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
				If (nPosFer	:= Ascan(aCodFolTran,{|X| x[1] == cCodPd .and. x[1]$aCodFol[015,1]+","+aCodFol[066,1]+","+aCodFol[043,1]+","+aCodFol[045,1] })) > 0 .AND. RGB->RGB_TIPO2 <> 'I'
					cCodPd		:= aCodFolTran[nPosFer,2]
					cDel		:= " "
					dDataFer	:= RGB->RGB_DTREF
					cTipo2		:= "V"
				EndIf
			EndIf
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se nao Existir a Verba para o Centro de Custo em aPd Carrega³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cSeqAux := RGB->RGB_SEQ
			While .T.
				If RGB->( ( nPosPd := aScan(aPd,{ |x| x[01] + x[02] + x[03] + DtoS(x[10]) == cCodPd + RGB_CC + RGB_SEMANA + DtoS(RGB_DTREF) .And. If( RGB->RGB_TIPO1 == "H", x[11] == cSeqAux, .T. ) .and. If(Empty(RGB_NUMID),.T.,RGB_NUMID == x[15]) } ) ) == 0 )
				
								
					RGB->( Aeval(aPd,{ |x| If ( x[01] + x[02] + x[03] == cCodPd + RGB_CC + RGB_SEMANA .And. If( RGB->RGB_TIPO1 == "H", x[11] == cSeqAux, .T. ), cSeqAux := Soma1(cSeqAux),Nil ) }) )
					
					If !Empty(cSeqAux)
						RGB->( Aeval(aPd,{ |x| If ( x[01] + x[02] + x[03]  == cCodPd + RGB_CC + RGB_SEMANA .And. AnoMes(x[18]) <> AnoMes(M->RG_DTGERAR), x[9] := "D",Nil ) }) )			
					EndIf 
					
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Verifica se Existe Parcelas								 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					lExistParc := RGB->( RGB_PARCEL > 0 .and. RGB_PARCEL < 99 )
					
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Verifica se deve Carregar a Data. Nos Casos em que o Tipo de³
					³Pagamento for igual a "S" as Datas das Semanas Anteriores de³
					³verao ser Carregadas para que as Bases de Imposto de Renda e³
					³INSS sejam Montadas corretamente. Nos Casos de Verba  Deleta³
					³da em aPd nao carregar a Data pois consideraremos que o  efe³
					³tivo pagamento se dara na Rescisao caso o usuario  desmarque³
					³a Delecao													 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					lCarrData := ( ( lPagSem .and. RGB->RGB_SEMANA < cSemana ) .or. ( cDel # "D" ) )
					
					nValAux  := RGB->(IF(lExistParc, RGB_VALOR * RGB_PARCEL, RGB_VALOR))
					nRefAux  := RGB->(IF(lExistParc, RGB_HORAS * RGB_PARCEL, RGB_HORAS))
					lEmpCons := RetValSRV(cCodPd,SRA->RA_FILIAL,"RV_EMPCONS") == "1"
					
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Carrega a verba em aPD utilizando fMatriz					 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					RGB->( fMatriz(	cCodPd,	nValAux, nRefAux, RGB_SEMANA, RGB_CC, RGB_TIPO1, cTIPO2, RGB_PARCEL, cDel, IF(lCarrData,RGB_DTREF,NIL),,cSeqAux,Nil,Nil,Nil,RGB_NUMID,lEmpCons,RGB_IDCMPL,,,,,""))
									
					If cCompl == "S" .And. !lRescDis .And. AnoMes(dDataDem) <> RGB->RGB_PERIOD //Ignora se for complementar no mesmo mês da original pois deve recalcular tudo.
						If cPdPLR == cCodPd //Se foi lançado verba de PLR
							lRescPLR := .T.
						ElseIf cTIPO2 != "F" .And. (!lRvCpoPlr .Or. RetValSRV(cCodPd, SRA->RA_FILIAL, "RV_REFPLR") != "S")
							lOutrosVb := .T.
						EndIf
					EndIf

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Se for verba de valor e rescisão complementar no mês seguinte, soma valores calculados anteriormente para pagar o valor exato informado - MASP - Reestrutação da rescisão - DRHPAG-29168³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					If cCompl == "S" .and. lProxMes .And. !lResAntPLR .And. aPd[Len(aPd),1] == cCodPd
						nHorAux := 0
						For nX := 1 to Len(aPdResc)
							If aPdResc[nX,1] == aPd[Len(aPd),1] .And. aPdResc[nX,3] == cSemana .And. aPdResc[nX,9] <> "D" .And. AnoMes(aPdResc[nX,18]) < M->RG_PERIODO
								If RGB->RGB_TIPO1 == "V"
									aPd[Len(aPd),5] += aPdResc[nX,5]
									If RetValSRV(aPdResc[nX,1],SRA->RA_FILIAL,"RV_INCORP") == "S"
										//Verifica se a verba é de desconto, se for deverá ser abatido o valor do salmes e não somado
										If RetValSRV(aPdResc[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "2"
											IncorpSal(aPdResc[nX,5],,.T.)
										Else
											IncorpSal(aPdResc[nX,5])
										EndIf									
									EndIf
								Else
									If AnoMes(aPdResc[nX, 10]) < M->RG_PERIODO 
										If ( nPerComp := aScan( aPerComp, { |x| x[1] == AnoMes(aPdResc[nX, 10]) } ) ) == 0
											aAdd( aPerComp, { AnoMes(aPdResc[nX, 10]), aPdResc[nX, 4] } )
										ElseIf aPdResc[nX, 4] > aPerComp[nPerComp, 2]
											aPerComp[nPerComp, 2] := aPdResc[nX, 4]
										EndIf
									EndIf
								EndIf								
								aPd[Len(aPd),11] := aPdResc[nX,11]
							EndIf
						Next nX
						If !Empty(aPerComp)
							aEval(aPerComp, { |x| aPd[Len(aPd), 4] += x[2] })
						EndIf
					EndIf
					
					If Len(aPd) > 0
						For nCont:= 1 to Len(aPd[1])
							If nCont = 1
								cChaveCodPd	:= aPd[Len(aPd)][nCont]
							EndIf
						Next 
					EndIf
					Exit
				Else
					If RGB->RGB_TIPO1 <> "H"
						aPd[ nPosPd, 04 ] += RGB->RGB_HORAS
						aPd[ nPosPd, 05 ] += RGB->RGB_VALOR
						//Somente incorpora ao SalMes caso a verba esteja com S para incorpora.
						If !(aPd[nPosPd,7] $ "C*F*R*K") .And. RetValSRV(aPd[nPosPd,1],SRA->RA_FILIAL,"RV_INCORP") == "S"							
							SalMes  += aPd[ nPosPd, 05 ]
							SalHora += (aPd[ nPosPd, 05 ] / nHrsCal)
							SalDia  += (aPd[ nPosPd, 05 ] / nDiasC)
						EndIf
						
						Exit
					Else
						cSeqAux := Soma1(cSeqAux)
					EndIf
				EndIf
			EndDo
			
			//Se não for dissídio, se for roteiro da rescisão e a verba tem origem no roteiro FER
			SRH->( dbSetOrder(3) )
			If !lDissidio .And. RGB->RGB_TIPO2 == "K" .And. SRH->( dbSeek( RGB->RGB_FILIAL + RGB->RGB_MAT + "FER" + dToS( RGB->RGB_DTREF ) ) )
				aAdd( aVbAuxFer, aClone( aPd[Len(aPd)] ) )
			EndIf
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Proximo Registro da RGB                                    ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			RGB->( dbSkip() )
		EndDo
	EndIf

	//Gera as verbas para pagamento do 1/3 adiado devido MP 927/2020
	If !Empty(P_ADIPINI) .And. !Empty(P_ADIPFIM) .And. !Empty(P_ADIUTFM) .And. !Empty(P_ADIPGFE)
        SRD->( dbSetOrder(4) )//RD_FILIAL+RD_MAT+DTOS(RD_DATPGT)+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
        SRH->( dbSetOrder(2) )//RH_FILIAL+RH_MAT+DTOS(RH_DATAINI)
		If SRH->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT ) )
			While SRH->( !EoF() ) .And. SRH->RH_FILIAL+SRH->RH_MAT == SRA->RA_FILIAL+SRA->RA_MAT 
				If AnoMes( SRH->RH_DATAINI ) >= P_ADIPINI .And. AnoMes( SRH->RH_DATAINI ) <= P_ADIPFIM 
					If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTFM ) )
						While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+dToS(SRD->RD_DATPGT)+SRD->RD_PD == SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTFM
							If Empty(SRD->RD_NUMID) .AND. SRD->RD_TIPO2 != "F"
								nValUmTF	+= SRD->RD_VALOR
								aAdd( aRecResUT, { SRD->( Recno() ), cPerAtu + cRoteiro + P_ADIPGFE } )
							EndIf
							SRD->( dbSkip() )
						EndDo
					EndIf
					If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTFMS ) )
						While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+dToS(SRD->RD_DATPGT)+SRD->RD_PD == SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTFMS
							If Empty(SRD->RD_NUMID) .AND. SRD->RD_TIPO2 != "F"
								nValUmTF	+= SRD->RD_VALOR
								aAdd( aRecResUT, { SRD->( Recno() ), cPerAtu + cRoteiro + P_ADIPGFE } )
							EndIf
							SRD->( dbSkip() )
						EndDo
					EndIf
					If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTAM ) )
						While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+dToS(SRD->RD_DATPGT)+SRD->RD_PD == SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTAM
							If Empty(SRD->RD_NUMID) .AND. SRD->RD_TIPO2 != "F"
								nValUmTA	+= SRD->RD_VALOR
								aAdd( aRecResUT, { SRD->( Recno() ), cPerAtu + cRoteiro + P_ADIPGAB } )
							EndIf
							SRD->( dbSkip() )
						EndDo
					EndIf
					If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTAMS ) )
						While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+dToS(SRD->RD_DATPGT)+SRD->RD_PD == SRA->RA_FILIAL+SRA->RA_MAT+dToS(SRH->RH_DTRECIB)+P_ADIUTAMS
							If Empty(SRD->RD_NUMID) .AND. SRD->RD_TIPO2 != "F"
								nValUmTA	+= SRD->RD_VALOR
								aAdd( aRecResUT, { SRD->( Recno() ), cPerAtu + cRoteiro + P_ADIPGAB } )
							EndIf
							SRD->( dbSkip() )
						EndDo
					EndIf	
				EndIf
				SRH->( dbSkip() )
			EndDo
		EndIf

		If nValUmTF > 0 .And. aScan( aPd, {|x| x[1] == P_ADIPGFE .and. x[9] != 'D'} ) == 0
			fMatriz( P_ADIPGFE, nValUmTF, 0, Nil, Nil, "V", "F" )
		EndIf
		If nValUmTA > 0 .And. aScan( aPd, {|x| x[1] == P_ADIPGAB .and. x[9] != 'D'} ) == 0
			fMatriz( P_ADIPGAB, nValUmTA, 0, Nil, Nil, "V", "F")
		EndIf

		RestArea( aAreaSRD )
		RestArea( aAreaSRH )
	EndIf

	//Gera a base do IR de ferias - Id 1562
	If !Empty(aVbAuxFer)
		fGerBasFer( aVbAuxFer )
	EndIf

	//Se calcula PLR para demitidos, busca pagamento de PLR no movimento
	If cCompl == "S" .and. GetMvRH("MV_PLRDEM",,"N") == "S" .and. !lResAntPLR //Se já foi pago PLR no mesmo mês, não busca novamente.
		DbSelectArea("SRC")
		DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))
		cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetCalcRot("F") + cPerAtu
		If DbSeek( cSRCSeek )	
			While SRC->(!Eof() .and. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
				fMatriz( SRC->RC_PD, SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, "G", Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )		
				lRescPLR := .T.
				SRC->(DbSkip())
			EndDo
		EndIf		
	EndIf
	
	//Se for informado verba de PLR, "zera" as demais verbas para cálculo apenas de valores referentes a PLR - MASP - DRHPAG-29169
	If lRescPLR
		For nPosPd := 1 to Len(aPd)
			If !(aPd[nPosPd,1] == cPdPLR) .And. (!lRvCpoPlr .Or. (lRvCpoPlr .And. !(RetValSRV(aPd[nPosPd,1], SRA->RA_FILIAL, 'RV_REFPLR') == "S")))
				cPdDel += RetValSrv(aPd[nPosPd,1],xfilial("SRV"),"RV_CODDSR") + "/"
				aDel(aPd,nPosPd)	
				aSize(aPd,Len(aPd)-1)
				nPosPd--
			EndIf
			If nPosPd == Len(aPd)
				Exit
			EndIf
		Next nPosPd
		For nPosPd := 1 to Len(aPdResc)
			If !(aPdResc[nPosPd,1] $ cPdPLR + "/" + aCodFol[152,1] + "/" + aCodFol[835,1] + "/" + aCodFol[303,1] + "/" + aCodFol[126,1]) .and. aPdResc[nPosPd,7] <> 'I' .and. AnoMes(aPdResc[nPosPd,10]) <> M->RG_PERIODO .and. !(aPdResc[nPosPd,1] $ cPdDel)
				If !lRvCpoPlr .Or. RetValSRV(aPdResc[nPosPd,1], SRA->RA_FILIAL, "RV_REFPLR") != "S"
					If ( nPos := aScan(aPd,{|x| x[1] == aPdResc[nPosPd,1] .and. x[9] <> 'D' .and. x[15] == aPdResc[nPosPd,15] } ) ) == 0
						aAdd(aPd, aClone(aPdResc[nPosPd]))
						aPd[Len(aPd),7] := "I"
					Else
						aPd[nPos,5] += aPdResc[nPosPd,5]
					EndIf
				EndIf
			EndIf
		Next nPosPd

	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Somar os Salarios Ja Pagos nas Semanas Anteriores          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If ( SRA->RA_TIPOPGT == "S" )
		DbSelectArea("SRD")
		DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

		cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetRotOrdinar() + cPeriodo

		If DbSeek( cSRDSeek )

			While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO == cSRDSeek )

				If ( cCodPd $ cVerbSalSem ) .And. If( SRA->RA_CATFUNC == "S", ( SRD->RD_SEMANA == cSemana ), .T. )
					nSalPgto += SRD->RD_VALOR
				EndIf

				If !Empty(aCodFol[649,1]) .And. SRD->RD_PD == aCodFol[017,1] .And. SRD->RD_SEMANA < cSemana
					nFgtSemAnt	+= SRD->RD_VALOR
				EndIf

				If !Empty(aCodfol[650,1]) .And. SRD->RD_PD == aCodFol[018,1] .And. SRD->RD_SEMANA < cSemana
					nVFgtSemAnt += SRD->RD_VALOR
				EndIf

				If !Empty(aCodfol[651,1]) .And. SRD->RD_PD == aCodFol[298,1] .And. SRD->RD_SEMANA < cSemana
					nVCsSemAnt += SRD->RD_VALOR
				EndIf

				SRD->( fMatriz(	RD_PD, RD_VALOR, RD_HORAS, RD_SEMANA, RD_CC, RD_TIPO1, RD_TIPO2, NIL, " ", RD_DTREF, NIL, RD_SEQ, Nil, Nil, Nil, RD_NUMID, (RetValSRV(RD_PD, SRA->RA_FILIAL, "RV_EMPCONS") == "1"), RD_IDCMPL, Nil, Nil, Nil, Nil, ""))

				SRD->(DbSkip())
			EndDo
		EndIf
	EndIf

	//Procura o roteiro do adiantamento que foi calculado referente ao periodo de calculo da rescisao
	DbSelectArea("SRC")
	DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

	cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + M->RG_PERIODO + M->RG_SEMANA
	If DbSeek( cSRCSeek )	
		While SRC->(!Eof() .and. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
			//Rend. Bruto Ir. Anter.##Desc. Ir. Anterior##IR Adto##Base Adto##Pagto do Adiantamento
			If SRC->RC_PD $ aCodFol[106,1] + "/" + aCodFol[107,1] + "/" + aCodFol[009,1] + "/" + aCodFol[010,1] + "/" + aCodFol[006,1]
				fMatriz( If( SRC->RC_PD == aCodFol[006,1], aCodFol[007,1], If( SRC->RC_PD == aCodFol[009,1], aCodFol[012,1], SRC->RC_PD ) ), SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, SRC->RC_TIPO2, Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ,Nil,Nil,Nil,SRC->RC_NUMID )
			ElseIf SRC->RC_PD == aCodFol[1329,1]
				fMatriz( aCodFol[008,1], SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, SRC->RC_TIPO2, Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ,Nil,Nil,Nil,SRC->RC_NUMID )
			EndIf		
			SRC->(DbSkip())
		EndDo
	EndIf

	//Procura o roteiro do adiantamento que ja foi fechado referente ao periodo de calculo da rescisao
	DbSelectArea("SRD")
	DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

	cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + cRotAdi + M->RG_PERIODO + M->RG_SEMANA
	If DbSeek( cSRDSeek )	
		While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
			//Rend. Bruto Ir. Anter.##Desc. Ir. Anterior##IR Adto##Base Adto##Desc do Adiantamento
			If SRD->RD_PD $ aCodFol[106,1] + "/" + aCodFol[107,1] + "/" + aCodFol[012,1] + "/" + aCodFol[010,1] + "/" + aCodFol[007,1]
				fMatriz( SRD->RD_PD, SRD->RD_VALOR, SRD->RD_HORAS, SRD->RD_SEMANA, SRD->RD_CC, SRD->RD_TIPO1, SRD->RD_TIPO2, Nil, Nil, SRD->RD_DATPGT, Nil, SRD->RD_SEQ )
			ElseIf SRD->RD_PD == aCodFol[006,1] .And. ( ( nPosPd := aScan(aPd,{ |x| x[01] == aCodFol[007,1] } ) ) == 0 )  
				fMatriz( aCodFol[007,1], SRD->RD_VALOR, SRD->RD_HORAS, SRD->RD_SEMANA, SRD->RD_CC, SRD->RD_TIPO1, SRD->RD_TIPO2, Nil, Nil, SRD->RD_DATPGT, Nil, SRD->RD_SEQ )
			EndIf	
			SRD->(DbSkip())
		EndDo
	EndIf

	//Procura o roteiro de folha pelo IR quando rescisao calculada em periodo seguinte ao em aberto
	DbSelectArea("SRC")
	DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))

	If fGetPerAtual( @aPerAtu, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, fGetRotOrdinar() ) .And. M->RG_PERIODO > aPerAtu[1, 1]
		cSRCSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetRotOrdinar() + aPerAtu[1, 1] + M->RG_SEMANA
		lRefAbono:= If(SRV->(ColumnPos( 'RV_REFABON' )) > 0,.T.,.F.)
		cCodAbon := aCodFol[205,1] + "*" + aCodFol[0206,1] + "*" + aCodFol[207,1] + "*" + aCodFol[208,1] + "*" + aCodFol[633,1] + "*" + aCodFol[634,1] + "*" + aCodFol[635,1] + "*" + aCodFol[1313,1] + "*" + aCodFol[1315,1] + "*" + aCodFol[1317,1] + "*" + aCodFol[1319,1] + "*" + aCodFol[1321,1] + "*" + aCodFol[1323,1] + "*" + aCodFol[1325,1] + "*" + aCodFol[1327,1] + "*" + aCodFol[1331,1] + "*" + aCodFol[1409,1] + "*" + aCodFol[1410,1] + "*" + aCodFol[1418,1] + "*" + aCodFol[1419,1]
		If DbSeek( cSRCSeek )	
			While SRC->(!Eof() .and. RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA == cSRCSeek )
				//Base Imposto de Renda##I.R.
				If SRC->RC_PD $ aCodFol[015,1] + "/" + aCodFol[066,1]
					fMatriz( If( SRC->RC_PD == aCodFol[015,1], aCodFol[106,1], aCodFol[107,1] ), SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, "F", Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )
				ElseIf SRC->RC_PD $ aCodFol[17,1] + "/" + aCodFol[18,1] + "/" + aCodFol[109,1] + "/" + aCodfol[117,1] + "/" + aCodFol[118,1]
					fMatriz( SRC->RC_PD, SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, "F", Nil, "D", SRC->RC_DATA, Nil, SRC->RC_SEQ )
				ElseIf SRC->RC_PD == aCodFol[0045,1]
					fMatriz( aCodFol[0046,1], SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, SRC->RC_TIPO2, Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )
				ElseIf SRC->RC_PD == aCodFol[22,1] //Gera adiantamento de 13º pago nas férias
					fMatriz( aCodFol[116,1], SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, SRC->RC_TIPO2, Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )
				ElseIf !Empty( cCodMSeg := RetValSRV(SRC->RC_PD,SRA->RA_FILIAL,"RV_CODMSEG") ) .and. RetValSRV(SRC->RC_PD,SRA->RA_FILIAL,"RV_REFFER") == "S" //Existe verba que seria transferida para o mês seguinte
					cBsFerPg := If( SRC->RC_PD $ cCodAbon .Or. If(lRefAbono, RetValSRV(SRC->RC_PD,SRA->RA_FILIAL,"RV_REFABON") == "1", .F.), aCodFol[1449,1], aCodFol[164,1])	// Abono / Férias 
					fMatriz( cCodMSeg, SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, "F", Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )
					If ( nPos := aScan(aPd,{ |X| X[1] == cBsFerPg .and. X[9] # "D" .And. X[7] == 'F' } ) ) == 0
						fMatriz( cBsFerPg, SRC->RC_VALOR, SRC->RC_HORAS, SRC->RC_SEMANA, SRC->RC_CC, SRC->RC_TIPO1, "F", Nil, Nil, SRC->RC_DATA, Nil, SRC->RC_SEQ )
					ElseIf RetValSRV(SRC->RC_PD, SRA->RA_FILIAL, "RV_TIPOCOD") == "1"
						aPd[nPos,5] += SRC->RC_VALOR
					ElseIf RetValSRV(SRC->RC_PD, SRA->RA_FILIAL, "RV_TIPOCOD") == "2"
						aPd[nPos,5] -= SRC->RC_VALOR
					EndIf
				EndIf
						
				SRC->(DbSkip())
			EndDo
		EndIf
	EndIf

	//Procura o roteiro de folha pelo FGTS mes anterior
	DbSelectArea("SRD")
	DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))

	If !lRescPLR .And. fGetPerAtual( @aPerAtu, xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, "RES" )
		cSRDSeek := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetRotOrdinar() + SubMesAno(aPerAtu[Len(aPerAtu), 1]) + M->RG_SEMANA
		If DbSeek( cSRDSeek )	
			While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA == cSRDSeek )
				If SRD->RD_PD $ aCodFol[17,1] + "/" + aCodFol[18,1] + "/" + aCodFol[109,1] + "/" + aCodfol[117,1] + "/" + aCodFol[118,1]
					fMatriz( SRD->RD_PD, SRD->RD_VALOR, SRD->RD_HORAS, SRD->RD_SEMANA, SRD->RD_CC, SRD->RD_TIPO1, "F", Nil, "D", SRD->RD_DATPGT, Nil, SRD->RD_SEQ )
				EndIf		
				SRD->(DbSkip())
			EndDo
		EndIf
	EndIf	

	//-- Geracao da verba de ferias pagas no mes anterior
	If lNoRescMes
		If nValFerMs > 0
			fMatriz(aCodFol[164,1],nValFerMs,,,,,"V",,,dDataFer,,,)
		EndIf
		If nValAboMs > 0
			fMatriz(aCodFol[1449,1],nValAboMs,,,,,"V",,,dDataFer,,,)
		EndIf		
	EndIf

	//-- Se pagamento Semanal e deve separar a semana, esta opcao ocorre no calculo de 
	//--rescisao inidividual, na rescisao coletiva não deve seprar a semana
	If ( lPagSem )  .And. !(lSemAnt)

		Aeval(aPd,{ |x| If ( x[3] < cSemana, Aadd(aPdSemAnt,aClone(x)),Aadd(aPdAtu,Aclone(x)) ) })
		//-- Limpar Marca de Deletado do Array Anterior.
		//--	Aeval(aPdSemAnt,{ |x|  x[9] := " " })

		//-- Salavar a Matriz com as verbas da semana de calculo.
		aPd := aClone(aPdAtu)	
		If !Empty(aCodFol[649,1]) .And. nFgtSemAnt > 0
			fMatriz(aCodFol[649,1],nFgtSemAnt,,,,,"V",,,,,,)
		EndIf
		If !Empty(aCodfol[650,1]) .And. nVFgtSemAnt > 0
			fMatriz(aCodFol[650,1],nVFgtSemAnt,,,,,"V",,,,,,)
		EndIf
		If !Empty(aCodfol[651,1]) .And. nVCsSemAnt > 0
			fMatriz(aCodFol[651,1],nVCsSemAnt,,,,,"V",,,,,,)
		EndIf

	EndIf

	If lVerMultv 
		If lTemSeqMV
			If lTemMultV
				CSEQMV := " "
				SRC->(DbSetOrder(nSRCOrd))
				If SRC->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo + cRoteiro + cNumPag )) //Busca base ir outras empresas
					CSEQMV := SRC->RC_SEQMV
				EndIf
				fLoadMultv(.T.)
			EndIf
		Else 
			P_MULTV := .F.  //Se não foi criado o campo, torna o mnemonico falso para consitnuar com o processo padrão.
		EndIf 
	EndIf

	If !IsBlind() .And. lRescPLR .And. lOutrosVb .And. !MsgNoYes(STR0002 + CRLF + STR0003 + CRLF + STR0004, STR0001)//"Houve a inclusão em lançamentos por funcionário (tabela RGB) da verba de PLR e de outras verbas que não são referente PLR."##"Dessa forma, será considerado que o cálculo será para pagamento de PLR e as outras verbas que não são referente PLR serão desprezadas do cálculo."##'Clique em "Não" para abortar o cálculo ou em "Sim" para prosseguir com o cálculo dessa forma.'##"Atenção"
		aPd := {}
		NOPRCREG()
	EndIf

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fCarFgtsR ³ Autor ³ Equipe RH             ³ Data ³25/07/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Busca FGTS Depositado e FGTS Mes Anterior                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fCarFgtsR()                                                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Generico                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fCarFgtsR()

	Local cNom		:= ""                 
	Local cAnoMes	:= ""
	Local dDataD 	:= If (Type("dDataDem1") # "U" , dDataDem1, dDataDem) 
	Local nFgtsDep 	:= 0
	Local nPos		:= 0
	Local nVFGTSant	:= 0

	//--Montagem da data de Busca do Saldo sempre um mes antes da data da rescisao.
	If Month(dDataD) = 1
		cAnoMes	:= StrZero(Year(dDataD)-1,4)+"11"
	ElseIf Month(dDataD) = 2
		cAnoMes	:= StrZero(Year(dDataD)-1,4)+"12"
	Else	
		cAnoMes	:= StrZero(Year(dDataD),4)+StrZero(Month(dDataD)-2,2)
	EndIf	

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Busca no Arquivo SRS - Saldos FGTS o FGTS Depositado       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If aIncRes[7] == "S"
		cNom := Alias()
		dbSelectArea("SRS")
		If aCodfol[118,1] # Space(3)
			SRS->( MsSeek( SRA->RA_FILIAL + SRA->RA_MAT + cAnoMes , .T.) )
			While !Eof() .and. SRA->RA_FILIAL + SRA->RA_MAT == SRS->RS_FILIAL + SRS->RS_MAT
				If SRS->RS_ANO+SRS->RS_MES <= MesAno(dDataDem1)
					nFgtsDep := SRS->RS_SALATU
				EndIf
				dbSelectArea("SRS")					
				dbSkip()
			EndDo
		EndIf
		If nFgtsDep > 0
			If aScan(aPd,{ |X| X[1] = aCodFol[118,1] .and. X[9] # "D" .And. X[7] # 'I' } ) = 0
				fMatriz(aCodFol[118,1],nFgtsDep, ,cSemana, ,"V","R")
			EndIf
		EndIf
		dbSelectArea(cNom)
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Fgts Mes Anterior e Fgts mes 13 salario                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If aIncRes[5] == "S"

		If ( nPos :=  aScan(aPd,{ |X| X[1] == aCodFol[18,1]  } ) ) > 0 		//-- Vlr FGTS Deposito
			nVFGTSant	+= aPd[nPos,5]

		ElseIf ( nPos :=  aScan(aPd,{ |X| X[1] == aCodFol[17,1]  } ) ) > 0 	//?- Base FGTS Deposito
			If SRA->RA_PERFGTS > 0
				nPFgts 	:= (SRA->RA_PERFGTS / 100)
			Else
				nPFgts 	:= If (SRA->RA_TPCONTR$ " *1", aInssEmp[4,1] , aInssEmp[4,2])
			EndIf
			nVFGTSant	+= NoRound((aPd[nPos,5] * nPFgts),2)
		EndIf
		If (nPos:=  aScan(aPd,{ |X| X[1] == aCodFol[109,1]  } )	) > 0 		//-- Vlr FGTS 13§ Salario
			nVFGTSant	+= aPd[nPos,5]
		EndIf	

		If nVFGTSant > 0  .and. aCodfol[117,1] # Space(3)					//-- Vlr FGTS Mes Anterior
			fMatriz(aCodFol[117,1],nVFGTSant )
		EndIf
	EndIf

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DiasTrabResºAutor  ³RH                  º Data ³  04/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Verifica se a demissao ocorreu no mesmo mes/ano da admissao º±±
±±º         ³ e retorna os dias trabalhados.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiasTrabRes(DiasTrab)

	Local aDiasPer	:= {}
	Local lBissexto := ( Mod( Year(dDatadem), 4 ) == 0 )
	Local bUltDia	:= { || If( lBissexto, 29, 28 ) }
	Local nCount	:= 0
	Local nDiasSem 	:= 0

	If (SRA->RA_CATFUNC $ "M*C*E" .Or. (SRA->RA_TIPOPGT == "M" .And. SRA->RA_CATFUNC $"I*J*0*1*2*3*4*5*6*7*8*9") .Or.;
	(SRA->RA_CATFUNC == "T" .And. SRA->RA_TIPOPGT == "M" .And. cDiasMes == "N") ) .And. ;
	(Day(dDatadem) > 30 .Or. (Month(dDataDem) == 2 .And. Day(dDataDem)>=Eval(bUltDia)))
		If MesAno(SRA->RA_ADMISSA) == MesAno(dDatadem) .and. DAY(SRA->RA_ADMISSA) # 1
			DiasTrab := Day(dDataDem) - Day(SRA->RA_ADMISSA) + 1
		Else
			DiasTrab := nDiasC
		EndIf
	ElseIf (SRA->RA_CATFUNC $ "S*T" .And. SRA->RA_TIPOPGT == "S" )

		If nPosSem > 0

			aDiasPer	:= aClone( aPeriodo[ nPosSem, 5 ] )		//Informacoes dos Dias do Periodo selecionado
			nDiasSem 	:= Len( aPeriodo[ nPosSem, 5 ] )		//Qtde. total de dias da semana

			For nCount := 1 To nDiasSem

				If ( ( Day( aPeriodo[ nPosSem, 3 ] ) + nCount -1 ) <= Day( dDataDem ) ) .And.;
				( If( MesAno( SRA->RA_ADMISSA ) == MesAno( dDataDem ), ( ( Day( aPeriodo[ nPosSem, 3 ] ) + nCount -1 ) >= Day( SRA->RA_ADMISSA ) ), .T. ) )
					If aDiasPer[ nCount, 2 ] == "1"
						DiasTrab += 1
					ElseIf aDiasPer[ nCount, 2 ] $ "3*4"
						DiasDsr += 1
					EndIf
				EndIf
			Next nCount
		Else
			DiasTrab := Day(dDataDem)
		EndIf
	Else
		If MesAno(SRA->RA_ADMISSA) == MesAno(dDatadem) .and. DAY(SRA->RA_ADMISSA) # 1
			DiasTrab := Day(dDataDem) - Day(SRA->RA_ADMISSA) + 1
		ElseIf Day(dDataDem) > 30 .And. P_DIASRES == 2 .And. SRA->RA_CATFUNC <> "H"
			DiasTrab := NDIASC
		Else
			DiasTrab := Day(dDataDem)
		EndIf
	EndIf

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³BuscaMed 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Buscar os Valores de Medias Geradas Pela GpexMed()   		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³BuscaMed(nMedFerv,nMedFerp,nMed13o,nMedAviso,nDesc13)		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function BuscaMed(nMedFerv,nMedFerp,nMed13o,nMedAviso,nDesc13,nMedDobra)

	Local nDsrm_fv := nDsrm_fp := nDsrm_av := nDsrm_13 := 0.00
	Local nMedPer  := nMedIns  := nBasePer := nBasIns  := 0.00
	Local cTipMed,k
	Local nDiasFer	  := IIf( Len(aTabFer) > 0,aTabFer[3],0 )
	Local nAnos	   	  :=	0
	Local cMesAnoRef  := cAnoMes // Mnemonico com o Mes/Ano Referencia
	Local nDsrHrsAtiv := 0
	Local nPosSemana  := 0
	Local nPosValor   := 0
	Local nPosMed	  := 0
	Local nMedHeAv	  := 0 // médias de horas extras referentes ao aviso prévio
	Local nMedHeFv	  := 0 // médias de horas extras referentes às férias vencidas.
	Local nMedHeFp    := 0 // médias de horas extras referentes às férias proporcionais
	Local nMedHe13    := 0 // médias de horas extras referentes ao 13º salário.
	Local nMedAux	  := 0
	Local lCalInV	  := ( cPaisLoc == "BRA" .And. SRA->RA_ADCINS $ "2*3*4" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALIN") == "3")
	Local lCalPerV	  := cPaisLoc == "BRA" .And. SRA->RA_ADCPERI == "2" .and. Posicione("RCE",1,xFilial("RCE")+SRA->RA_SINDICA,"RCE_BCALPE") == "2"
	Local nMedFp	  := 0
	Local lAdcsResc   := Len(aCodFol) >= 1680 .And. !Empty(aCodFol[1680,1])
	Local nDsrm_fvT	  := 0
	Local nDsrm_fpT	  := 0
	Local nDsrm_13T	  := 0
	Local nDsrm_avT	  := 0
		


	DEFAULT __lMemCalc := cPaisLoc == "BRA" .And. FindFunction("fMemCalc") .And. fMemCalc() // Memória de Cálculo

	//Calcula adicionais sobre medias quando configuracao do sindicato e Salario + Verbas	
	P_ADISMED := If( Type("P_ADISMED") == "U", .T., P_ADISMED )

	If cPaisLoc == "PAR"
		IF Year(dDataBase) - Year(SRA->RA_NASC) <= 17  .Or. ;
		(Year(dDataBase) - Year(SRA->RA_NASC) == 18 .And.;
		Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRA->RA_NASC),5,4))
			nDiasFer	:=	aTabFer[3]
		Else		
			nAnos	:= (Year(dDataBase) - Year(SRA->RA_ADMISSA)) - If(Substr(Dtos(dDataBase),5,4) <= Substr(Dtos(SRA->RA_ADMISSA),5,4),1,0 )
			Do Case
				Case nAnos > 10
				nDiasFer	:=	aTabFer[3]
				Case nAnos > 5 .And. nAnos <= 10
				nDiasFer	:=	18
				Case nAnos <= 5
				nDiasFer	:=	12
			EndCase					
		EndIf
	ElseIf cPaisLoc == "CHI"
		nAnos	:= (Year(dDataBase) - Year(SRA->RA_ADMISSA)) - If(Substr(Dtos(dDataBase),5,4) <= Substr(Dtos(SRA->RA_ADMISSA),5,4),1,0 )
		nDiasFer	:=	15
		If nAnos >= 13
			nDiasFer	+=	Int((nAnos-10)/3)
		EndIf
	EndIf	

	dbSelectArea(cTBLXMED)
	If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "997" + "9598" )
		nDesc13 := (cTBLXMED)->RP_VALATU
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a rescisao for no mes seguinte ao mes que esta aberto  ³
	//³soma o valor da 1a parcela paga nas ferias na variavel de ³
	//³desconto da 1a parcela do 13o salario e exclui a verba de ³
	//³1a parcela que esta no aPd quando esta verba foi gerada   ³
	//³pelo sistema ("V").                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( cMesAnoRef == MesAno( dDataDem ) ) .And. !lRecRes
		If Type("oSrr") == "U"
			Aeval(aPd,{|x| nDesc13 += If(x[1] == aCodFol[022,1] .And. x[3] == cSemana,x[5],0)})
			Aeval(aPd,{|x| x[9] := If(x[1] == aCodFol[022,1] .And. x[3] == cSemana .And. x[7] == "V","D",x[9])})
		Else
			nDesc13 := FO_SOMAALLREGS(@&cObjeto,cCpoValor,{cCpoPd,cCpoNPagto},{FGETCODFOL("0022"),cSemana})
		EndIf
	ElseIf !( cMesAnoRef == MesAno( dDataDem ) ) .And. lRecRes .And. Type("aCols") == "A" .And. nDesc13 == 0
		nPosSemana	:= GdFieldPos("RR_SEMANA")
		nPosValor 	:= GdFieldPos("RR_VALOR")
		Aeval(aCols,{|x| nDesc13 += If(x[1] == aCodFol[116,1] .And. x[nPosSemana] == cSemana,x[nPosValor],0)})
		Aeval(aCols,{|x| nDesc13 += If(x[1] == aCodFol[183,1] .And. x[nPosSemana] == cSemana,x[nPosValor],0)})
	EndIf

	dbSelectArea(cTBLXMED)
	If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While ! Eof() .and. SRA->RA_FILIAL+SRA->RA_MAT = (cTBLXMED)->RP_FILIAL+(cTBLXMED)->RP_MAT
			IF (cTBLXMED)->RP_PD > "900"
				dbSkip( 1 )
				Loop
			EndIf
			IF (cTBLXMED)->RP_TIPO $ "156789" .and. (cTBLXMED)->RP_DATARQ = "99MD"
				nDsrm_fv += (cTBLXMED)->RP_VALATU				
			ElseIf (cTBLXMED)->Rp_TIPO $ "2" .and. (cTBLXMED)->RP_DATARQ = "9999"
				nDsrm_fp += (cTBLXMED)->RP_VALATU
			ElseIf (cTBLXMED)->RP_TIPO $ "3" .and. (cTBLXMED)->RP_DATARQ = "9999"
				nDsrm_13 += (cTBLXMED)->RP_VALATU
			ElseIf (cTBLXMED)->RP_TIPO $ "4" .and. (cTBLXMED)->RP_DATARQ = "9999"
				nDsrm_av += (cTBLXMED)->RP_VALATU
			EndIf
			dbSkip(1)
		EndDo

		If cPaisLoc == "ARG"
			lFerVen := ( FTABELA("S012",VAL(CTIPRES),9) == "S" )
			lFerPro := lFerVen
			l13Sal  := ( FTABELA("S012",VAL(CTIPRES),10) == "S" )
			lAviso  := ( FTABELA("S012",VAL(CTIPRES),7) == "S" )
		ElseIf !Empty(aIncRes)
			lFerVen := ( aIncRes[8] = "S" )
			lFerPro := lFerVen
			l13Sal  := ( aIncRes[9] = "S" )
			lAviso  := ( aIncRes[10] = "S" )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do Dsr s/ Medias                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFerVen
			nDsrm_fvT	  := (nDsrm_fv * Descanso) / Normal
			If nDsrm_fvT > 0
				GRA_TOT(SRA->RA_MAT,"1","999","ZZ03",0,nDsrm_fvT,nDsrm_fvT,"N",0)
			EndIf
		EndIf
		If lFerPro
			nDsrm_fpT	  := (nDsrm_fp * Descanso) / Normal
			If nDsrm_fpT > 0
				GRA_TOT(SRA->RA_MAT,"2","999","ZZ03",0,nDsrm_fpT,nDsrm_fpT,"N",0)
			EndIf
		EndIf
		If l13Sal
			nDsrm_13T	  := (nDsrm_13 * Descanso) / Normal
			If nDsrm_13T > 0
				GRA_TOT(SRA->RA_MAT,"3","999","ZZ03",0,nDsrm_13T,nDsrm_13T,"N",0)
			EndIf
		EndIf
		If lAviso
			nDsrm_avT	  := (nDsrm_av * Descanso) / Normal
			If nDsrm_avT > 0
				GRA_TOT(SRA->RA_MAT,"4","999","ZZ03",0,nDsrm_avT,nDsrm_avT,"N",0)
			EndIf
		EndIf

		nDsrm_fv := IF(nDsrm_fv > 0.00 .and. lFerVen,nDsrm_fvT,0.00)
		nDsrm_fp := IF(nDsrm_fp > 0.00 .and. lFerPro,nDsrm_fpT,0.00)
		nDsrm_13 := IF(nDsrm_13 > 0.00 .and. l13Sal	,nDsrm_13T,0.00)
		nDsrm_av := IF(nDsrm_av > 0.00 .and. lAviso ,nDsrm_avT,0.00)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Memória de Cálculo 										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If __lMemCalc
			fAddMemLog("Horas descanso : " + cValtochar(Descanso),1,1) 
			fAddMemLog("Horas Normal : " + cValtochar(Normal),1,1) 
			
			fAddMemLog("DSR Ferias Vencidas - media (nDsrm_fv) : " + cValtochar(nDsrm_fv),1,1) 
			fAddMemLog("DSR Ferias Proporcional - media (nDsrm_fp) : " + cValtochar(nDsrm_fp),1,1) 
			fAddMemLog("DSR 13 salario - media (nDsrm_13) : " + cValtochar(nDsrm_13),1,1) 
			fAddMemLog("DSR Aviso Previo - media (nDsrm_av) : " + cValtochar(nDsrm_av),1,1) 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Media de Ferias Vencidas (Tratamento de Mais de Um Periodo)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Memória de Cálculo
		If __lMemCalc
			fAddMemLog("Media Férias Vencidas" ,1,1) 
		EndIf
		For k := 1 To 6
			cTipMed	:= Str( IF(k ==1, 1,k+3), 1)
			IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTipMed + "999" + "99MD" )
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Media Férias Vencidas Periodo("+cTipMed+") : " ,1,2) 
					fAddMemLog("Valor Media (TRP->RP_VALATU) : " + cValtoChar((cTBLXMED)->RP_VALATU) ,1,3)
				EndIf	
				nMedAux  := (cTBLXMED)->RP_VALATU + IF(k = 1,nDsrm_fv,0) + fDsrHrsAtiv(cTipMed,aCodFol)
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("TRP->RP_VALATU + IF(k = 1,nDsrm_fv,0) + fDsrHrsAtiv(cTipMed,aCodFol) - (nMedAux) : " + cValtoChar(nMedAux) ,1,3) 
				EndIf
				nMedFerv += nMedAux
				If Type("aPerMedia") != "U" .and. ( nPosMed := aScan(aPerMedia, {|x| x[1] = cTipMed}) ) > 0
					aPerMedia[nPosMed,4] += nMedAux
				EndIf			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Peric./Insalub Sobre Verba de Medias  incidencia   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								
				nMedPer := nMedIns := 0.00
				NMEDINSFV := NMEDPERFV := 0
				FMedPerIns(@nMedPer,@nMedIns,cTipMed,SalHora,Val_BInsal,aCodFol,,,,P_ADISMED)

				If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
					NMEDINSFV += nMedIns
					NMEDPERFV += nMedPer					
				Else
				nMedFerv += (nMedPer+nMedIns)
				EndIf

				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Periculosidade sobre verba de media - (nMedPer+nMedIns) : " + cValtoChar(nMedPer+nMedIns) ,1,3) 
				EndIf
				//-- Iguala a media do primeiro periodo para pagamento da Dobra se houver
				If K = 1
					nMedDobra := nMedFerv
				EndIf	
				If nGComisFv > 0
					//Verifica se existe médias em horas.
					If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTipMed + "999" + "98MD" )
						nMedHeFv += (cTBLXMED)->RP_VALATU + IF(k = 1,nDsrm_fv,0)
					EndIf
					//Para o pagamento da garantia de comissão, as médias em horas não devem ser consideradas.
					// Caso as médias Totais (nMedFerv) menos as médias de horas (nMedHeFv) forem maiores que a garantia, então não possui mais garantia.
					// Caso contrário, as médias de horas devem computar como garantia.
					// Exemplo
					// Garantia = 2500,00 -- Médias Totais = 2100,00 -- Médias em Horas = 100,00. Neste caso, o funcionário deve receber 500,00 de Férias Vencidas.
					// Calculo: 2500,00 - 2100,00 + 100,00 = 500,00
					If nMedFerv - nMedHeFv > nGComisFv
						nGComisFv := 0
					Else
						nGComisFv := nGComisFv - nMedFerv + nMedHeFv
					EndIf
				Endif
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Media Ferias Vencidas -> (nMedFerv) : " + cValtoChar(nMedFerv) ,1,3) 
				EndIf
			EndIf
		Next k
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Media de Ferias Proporcionais                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTBLXMED)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "999" + "9999" )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva Registro da Media                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecFerp := Recno()
			nMedPer := nMedIns := 0.00
			NMEDPERFP := NMEDINSFP := 0

			//Memória de Cálculo
			If __lMemCalc
				fAddMemLog("Media Férias Proporcionais"  ,1,2) 
				fAddMemLog("Valor Media (TRP->RP_VALATU) : " + cValtoChar((cTBLXMED)->RP_VALATU) ,1,3)
			EndIf
			If lCalInV .or. lCalPerV

				nBasPer := nBasIns := 0.00

				If lCalInV //Insalubridade sobre verbas

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Soma Para Ferias Verbas Devem Ser Somadas Per. S/ Media    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,8,"S", , , , ,aCodFol) })
					Else
						nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MEDFER"},{"S","S"})
					EndIf
					nBasIns  := (nBasIns /  12 )
				EndIf

				If lCalPerV //Periculosidade sobre verbas
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Soma Para Ferias Verbas Devem Ser Somadas Per. S/ Media    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,8,"S", , , , ,aCodFol) })
					Else
						nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MEDFER"},{"S","S"})
					EndIf
					nBasPer  := (nBasePer / 12)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Peric./Insalub Verba de Medias Tem Incidencia      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMedPer := nMedIns := 0.00
				FMedPerIns(@nMedPer,@nMedIns,"2",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns,P_ADISMED)
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Periculosidade sobre verba de media - (nMedPer+nMedIns) : " + cValtoChar(nMedPer+nMedIns) ,1,3) 
				EndIf
				dbGoto(nRecFerp)
			EndIf

			nDsrHrsAtiv := fDsrHrsAtiv("2",aCodFol,"9999") //Calculo do DSR / Horas Atividade de professores

			lDFerAvi := !(SRG->RG_DFERAVI == 0 .and. nDiasAv > 0 .and. cCompl == "S")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A rotina de media gera os periodos de acordo com a data de demissao sem   ³
			//³ o aviso previo e o periodo para media pode ser proporcional e com o aviso ³
			//³ as ferias mudou de proporcional para vencidas e a media ficou gravada no  ³
			//³ periodo proporcional, nessa situacao utilizar media proporcional para o   ³
			//³ calculo das ferias vencidas.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lDFerAvi
				If ( (nDFerV == 0 .And. nMedFerv = 0) .Or. (nDFerV > 0 .And. (nDFerA + nDFerInd ) == aTabFer[3]) ) .And. nDFerA > 0 .And. nDFerVen > 0
					If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
						nMedFerv := (cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv
						NMEDINSFP := nMedIns
						NMEDPERFP := nMedPer						
					Else
						nMedFerv := (cTBLXMED)->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv
					EndIf
					//Memória de Cálculo
					If __lMemCalc
						fAddMemLog("Media Ferias Vencidas -> (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) : " + cValtoChar(nMedFerv) ,1,3) 
					EndIf
				ElseIf cMedDir == "S"
					If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
						nMedFerp := ( (cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv )
						NMEDINSFP := nMedIns
						NMEDPERFP := nMedPer						
					Else
						nMedFerp := ( (cTBLXMED)->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv )
					EndIf
					//Memória de Cálculo
					If __lMemCalc
						fAddMemLog("Media Ferias Proporcionais -> (TRP->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv) : " + cValtoChar(nMedFerp) ,1,3) 
					EndIf
				Else
					If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
						nMedFerp := (( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer )
						NMEDINSFP := ( nMedIns * M->RG_DFERPRO ) / nDiasFer
						NMEDPERFP := ( nMedPer * M->RG_DFERPRO ) / nDiasFer						
					Else
						nMedFerp := (( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer )
					EndIf
					//Memória de Cálculo
					If __lMemCalc
						fAddMemLog("Media Ferias Proporcionais -> ((( (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer )) : " + cValtoChar(nMedFerp) ,1,3) 
					EndIf
				EndIf
			Else
				IF cMedDir == "S"
					If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
						nMedFerp := ( (cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv )
						NMEDINSFP := nMedIns
						NMEDPERFP := nMedPer						
					Else
						nMedFerp := ( (cTBLXMED)->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv )
					EndIf
					//Memória de Cálculo
					If __lMemCalc
						fAddMemLog("Media Ferias Proporcionais -> (TRP->RP_VALATU + nDsrm_fp + nMedIns + nMedPer + nDsrHrsAtiv ) : " + cValtoChar(nMedFerp) ,1,3) 
					EndIf
				Else 
					//Para o calculo da media, devemos considerar os dias de aviso, limitando a 30 dias
					If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
						nMedFp := ( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer
						nMedFerp := (( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nDsrHrsAtiv) * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer )
						NMEDINSFP := ( nMedIns * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer
						NMEDPERFP := ( nMedPer * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer			
					Else
						nMedFp := ( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * M->RG_DFERPRO ) / nDiasFer
						nMedFerp := (( ((cTBLXMED)->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer )
					EndIf
					//Memória de Cálculo
					If __lMemCalc
						fAddMemLog("Media Ferias Proporcionais -> ((( (TRP->RP_VALATU + nDsrm_fp + nMedPer + nMedIns + nDsrHrsAtiv) * Min(M->RG_DFERPRO + M->RG_DFERAVI,30) ) / nDiasFer ) ) : " + cValtoChar(nMedFerp) ,1,3) 
					EndIf
				EndIf
			EndIf	
			If nGComisFp > 0
				//Para o pagamento da garantia de comissão, as médias em horas não devem ser consideradas.
				// Caso as médias Totais (nMedFp) menos as médias de horas (nMedHeFp) forem maiores que a garantia, então não possui mais garantia.
				// Caso contrário, as médias de horas devem computar como garantia.
				// Exemplo
				// Garantia = 2500,00 -- Médias Totais = 2100,00 -- Médias em Horas = 100,00. Neste caso, o funcionário deve receber 500,00 de Férias Proporcionais.
				// Calculo: 2500,00 - 2100,00 + 100,00 = 500,00
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "999" + "9899" )
					nMedHeFp += (cTBLXMED)->RP_VALATU
				EndIf
				nMedHeFp := ( nMedHeFp * M->RG_DFERPRO ) / nDiasFer
				If nMedFp - nMedHeFp > nGComisFp
					nGComisFp := 0
				Else
					nGComisFp := nGComisFp - nMedFp + nMedHeFp
				EndIf
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Media de 13§ Salario                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTBLXMED)
		IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "999" + "9999" )
			//Memória de Cálculo
			If __lMemCalc
				fAddMemLog("Media 13 salario"  ,1,2) 
				fAddMemLog("Valor Media (TRP->RP_VALATU) : " + cValtoChar((cTBLXMED)->RP_VALATU) ,1,3)
			EndIf
			nRec13 := Recno()
			nMedPer := nMedIns := 0.00
			NMEDINS13 := NMEDPER13 := 0
			If lCalInV .or. lCalPerV
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma Para 13§ Verbas Devem Ser Somadas Para Per. S/ Media  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nBasPer := nBasIns := 0.00

				If lCalInV
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,7,"S", , , , ,aCodFol) })
					Else
						nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MED13"},{"S","S"})
					EndIf
					nBasIns := (nBasIns /  12 )
				EndIf
				If lCalPerV
					If Type("oSrr") == "U"
						aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,7,"S", , , , ,aCodFol) })
					Else
						nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MED13"},{"S","S"})
					EndIf
					nBasPer  := (nBasePer / 12)
				EndIf			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Peric./Insalub Verba de Medias Que Tem Incidencia  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FMedPerIns(@nMedPer,@nMedIns,"3",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns,P_ADISMED)
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Periculosidade sobre verba de media - (nMedPer+nMedIns) : " + cValtoChar(nMedPer+nMedIns) ,1,3) 
				EndIf
				dbGoto(nRec13)
			EndIf
			If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
				nMed13o := (cTBLXMED)->RP_VALATU + nDsrm_13 + fDsrHrsAtiv("3",aCodFol,"9999")
				NMEDINS13 := nMedIns
				NMEDPER13 := nMedPer
			Else
				nMed13o := (cTBLXMED)->RP_VALATU + nDsrm_13 + nMedPer + nMedIns + fDsrHrsAtiv("3",aCodFol,"9999")
			EndIf
			//Memória de Cálculo
			If __lMemCalc
				fAddMemLog("Media 13 salario -> (TRP->RP_VALATU + nDsrm_13 + nMedPer + nMedIns + fDsrHrsAtiv('3',aCodFol,'9999') ) : " + cValtoChar(nMed13o) ,1,3) 
			EndIf
			If nGComis13 > 0
				//Para o pagamento da garantia de comissão, as médias em horas não devem ser consideradas.
				// Caso as médias Totais (nMed13o) menos as médias de horas (nMedHe13) forem maiores que a garantia, então não possui mais garantia.
				// Caso contrário, as médias de horas devem computar como garantia.
				// Exemplo
				// Garantia = 2500,00 -- Médias Totais = 2100,00 -- Médias em Horas = 100,00. Neste caso, o funcionário deve receber 500,00 de 13º Salário.
				// Calculo: 2500,00 - 2100,00 + 100,00 = 500,00
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "999" + "9899" )
					nMedHe13 += (cTBLXMED)->RP_VALATU
				EndIf
				If nMed13o - nMedHe13 > nGComis13
					nGComis13 := 0
				Else
					nGComis13 := nGComis13 - nMed13o + nMedHe13
				EndIf
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faltas 13§ Salario                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTBLXMED)
		IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "3" + "998" + "9998" )
			nAvosFal13  := (cTBLXMED)->RP_HORAS
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Media Aviso Previo                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTBLXMED)
		IF dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "4" + "999" + "9999" )
			//Memória de Cálculo
			If __lMemCalc
				fAddMemLog("Media Aviso Previo"  ,1,2) 
				fAddMemLog("Valor Media (TRP->RP_VALATU) : " + cValtoChar((cTBLXMED)->RP_VALATU) ,1,3)
			EndIf
			nRecAv  := Recno()
			nMedPer := nMedIns := 0.00
			NMEDINSAV := NMEDPERAV := 0
			If lCalInV .or. lCalPerV
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma Para Aviso Verbas Devem Ser Somadas Para Per. S/ Media³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nBasPer := nBasIns := 0.00
				If dDataDem - SRA->RA_ADMISSA < 365
					If lCalInV
						If Type("oSrr") == "U"
							aEval( aPd ,{ |X| SomaInc(X,10,@nBasIns,23,"S", , , , ,aCodFol) })
						Else
							nBasIns := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_INSALUB","RV_MEDAVI"},{"S","S"})
						EndIf
						nBasIns  := (nBasIns /  12 )
					EndIf
					If lCalPerV
						If Type("oSrr") == "U"
							aEval( aPd ,{ |X| SomaInc(X, 9,@nBasPer,23,"S", , , , ,aCodFol) })
						Else
							nBasPer := FO_SOMAINCSRV(@&cObjeto,cCpoValor,{"RV_PERICUL","RV_MEDAVI"},{"S","S"})
						EndIf
						nBasPer  := (nBasePer / 12)
					EndIf

				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Peric./Insalub Verba de Medias Que Tem Incidencia  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMedPer := nMedIns := 0.00
				FMedPerIns(@nMedPer,@nMedIns,"4",SalHora,Val_BInsal,aCodFol,'9999',nBasPer,nBasIns,P_ADISMED)
				//Memória de Cálculo
				If __lMemCalc
					fAddMemLog("Periculosidade sobre verba de media - (nMedPer+nMedIns) : " + cValtoChar(nMedPer+nMedIns) ,1,3) 
				EndIf
				dbGoto(nRecAv)
			EndIf
			If lAdcsResc .and. ( cCompl <> "S" .or. LTEMIDRESC)
				nMedAviso   := (cTBLXMED)->RP_VALATU + nDsrm_av + fDsrHrsAtiv("4",aCodFol,"9999")
				NMEDINSAV := nMedIns
				NMEDPERAV := nMedPer
			Else
				nMedAviso   := (cTBLXMED)->RP_VALATU + nDsrm_av + nMedPer + nMedIns + fDsrHrsAtiv("4",aCodFol,"9999")
			EndIf
			//Memória de Cálculo
			If __lMemCalc
				fAddMemLog("Media Aviso Previo-> (TRP->RP_VALATU + nDsrm_av + nMedPer + nMedIns + fDsrHrsAtiv('4',aCodFol,'9999') ) : " + cValtoChar(nMedAviso) ,1,3) 
			EndIf			
			If nGComisAv > 0
				//Para o pagamento da garantia de comissão, as médias em horas não devem ser consideradas.
				// Caso as médias Totais (nMedAviso) menos as médias de horas (nMedHeAv) forem maiores que a garantia, então não possui mais garantia.
				// Caso contrário, as médias de horas devem computar como garantia.
				// Exemplo
				// Garantia = 2500,00 -- Médias Totais = 2100,00 -- Médias em Horas = 100,00. Neste caso, o funcionário deve receber 500,00 de Aviso Indenizado.
				// Calculo: 2500,00 - 2100,00 + 100,00 = 500,00
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "4" + "999" + "9899" )
					nMedHeAv += (cTBLXMED)->RP_VALATU
				EndIf
				If nMedAviso - nMedHeAv > nGComisAv
					nGComisAv := 0
				Else
					nGComisAv := nGComisAv - nMedAviso + nMedHeAv
				EndIf
			Endif
		EndIf
	EndIf

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fCal13o 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Apurar os Valores de 13o. na Rescisao						³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fCal13o(aPd,aCodfol,nMed13o)								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fCal13o( aPd , aCodfol , nMed13o )

	Local aAfastD	:= {}
	Local aAfastO	:= {}
	Local aCodBenef	:= {}
	Local aPdBkp	:= {}
	Local aCodBen131:= {}
	Local aTabS033	:= {}
	Local cAnoRef	:= Val(SubStr(cAnoMes,1,4))
	Local cMesRef	:= Val(substr(cAnoMes,5,2))
	Local cAnoDemi  := Year(dDataDem)
	Local cDesFol	:= GetMvRH("MV_DESFOL",,"")
	Local cOneFol	:= If (Type("P_FDESFOL") # "U", P_FDESFOL, "")
	Local cRecFatEmp:= ""
	Local cSRCKey	:= ""
	Local cSRDKey	:= ""
	Local cPer13	:= ""
	Local dDataAux	:= CtoD('01/01/'+StrZero(Year(dDataDem)) , "DDMMYY")
	Local dDataDes	:= CtoD("//")
	Local dDataOne	:= CtoD("//")
	Local dDtPago13	:= CtoD("//")
	Local n132Pago	:= 0.00
	Local n131Pago	:= 0.00
	Local n13oMed	:= 0.00
	Local n13oMedM	:= 0.00
	Local n13oVal	:= 0.00
	Local n13oValM	:= 0.00
	Local nAvosAv	:= 0.00
	Local nAvosAf	:= 0.00
	Local nAvosAfD	:= 0.00
	Local nAvosAfO	:= 0.00
	Local nAvosDes	:= 0.00
	Local nAvosOne	:= 0.00
	Local nAvosDesc	:= 0.00
	Local nAvosF13D := 0.00
	Local nAvosF13O	:= 0.00
	Local nFalADes	:= 0.00
	Local nFalAOne	:= 0.00
	Local nFgts2Pa	:= 0
	Local nPosSB	:= 0
	Local nMed13Av	:= nMed13o
	Local nMed13Des	:= nMed13o
	Local nMed13One	:= nMed13o
	Local nMed13oM	:= nMed13o
	Local nVal13	:= 0.00
	Local nVal13M	:= 0.00
	Local nVal13Des	:= 0.00
	Local nVal13One	:= 0.00
	Local nVal1aP	:= 0
	Local nUltDOne	:= 0
	Local nValAux	:= 0
	Local nAvFalMes := 0
	Local nBase13	:= 0
	Local nSavPer	:= 0
	Local nSavIns	:= 0
	Local nDMatern 	:= 0 // Dias anuais de maternidade.
	Local lProj		:= .T.
	Local AuxSal	:= 0
	Local AuxSal1	:= 0
	Local lIntermite:= SRA->RA_TPCONTR == "3" // Contrato intermitente
	Local lContrVA	:= (SRA->RA_CATEFD $ '107/108')
	Local LVB13MAT	:= ( Len( aCodfol ) >= 1447 .And. !Empty(aCodFol[1446,1]) .And. !Empty(aCodFol[1447,1])  )
	Local nX		:= 0
	Local cSRC131Key:= cSRD131Key := ""
	Local cKeyAux	:= ""
	Local nBsDed13	:= 0
	Local nBsDedM13	:= 0
	Local lAdcsResc	:= ( Len(aCodFol) >= 1680 .And. !Empty(aCodFol[1680,1]) ) //Novos Adicionais em rescisão
	Local lTem1437	:= ( Len(aCodFol) >= 1437 )
	Local nVal13Ats := 0 // 13 sobre ATS
	Local nVal13Ins := 0 // 13 sobre Insalubridade.
	Local nVal13Per := 0 // 13 sobre periculosidade.
	Local nVal13Con := 0 // 13 sobre confiança.
	Local nVal13Tra := 0 // 13 sobre transferência.
	
	Local nVal13MAts := 0 // 13 Maternidade sobre ATS
	Local nVal13MIns := 0 // 13 Maternidade sobre Insalubridade.
	Local nVal13MPer := 0 // 13 Maternidade sobre periculosidade.
	Local nVal13MCon := 0 // 13 Maternidade sobre confiança.
	Local nVal13MTra := 0 // 13 Maternidade sobre transferência.
	Local nBase13M	 := 0 // 13 Base para verbas de maternidade.

	Local nMdPer13Av := 0 //Periculosidade sobre médias 13 aviso
	Local nMdIns13Av := 0 //Insalubridade sobre médias 13 aviso
	Local nPosFal	 := 0 //Posição no apd da verba de Faltas Id 0054
	
	Local nPos		 := 0
	Local lArred13   := .F. //Se houve arredondamento 13o
	
	If Type( "nAvosFal13" ) == "U"
		Private nAvosFal13 := 0.00
	EndIf

	If !Empty(SRA->RA_SINDICA) .And. RCE->(ColumnPos( "RCE_PRJAVT")) > 0
		If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_PRJAVT" )) == "2"
			lProj := .F.
		Endif
	Else
		lProj := .T.
	Endif

	P_PRJESTAB	:= If( Type("P_PRJESTAB") == "U", .F. , P_PRJESTAB)
	dDtEst936	:= If( Type("dDtEst936") == "U", cToD("") , dDtEst936)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa a variavel do numero de avos e array dos afastados   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAvos  	:= 0.00
	nAvosDes:= 0.00
	nAvosOne:= 0.00
	aAfast 	:= {}
	nInssP 	:= 0  
	nBAtLim	:= 0
	nBAcLim	:= 0
	nAvFalMes:= 0

	If Day(dDataDem) < 15 .and. nAvosFal13 > 0
		If (cTBLXMED)->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"+"998"+AnoMes(dDataDem))) //Verifica se houve faltas no mês da rescisão
			//Se houve mais que 16 faltas no mês da rescisão, subtrai um avo pois ele já foi perdido por ter menos de 15 dias trabalhados
			If (cTBLXMED)->RP_HORAS > 15
				nAvFalMes := 1
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao que Retorna os Avos do Funcionario                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fAvos13(@nAvos,dDataDem,@nAvosFal13 - nAvFalMes,nFalAtuD,,dDataDem)
	nDMatern := fDiasSm13(Str(Year(dDataDem)))
	
	If cPaisLoc == "BRA"
		If !lIntermite .And. !lContrVA
			cRecFatEmp := If( SRA->RA_TPCONTR $ " *1", aInssEmp[27,1] , aInssEmp[27,2] )
			If ( SubStr ( cOneFol, 1, 4 ) ==  StrZero( cAnoRef,4 )) .And. ( StrZero ( cMesRef,2) >= SubStr ( cOneFol, 5, 2 ) )
				fCarrTab( @aTabS033, "S033", dDataDem )
				dDataOne := cToD( "01/" + SubStr( cOneFol, 5, 2 ) + "/" + SubStr( cOneFol, 1, 4 ) )
				nUltDOne := F_ULTDIA(dDataOne)
				dDataOne := cToD( Str(nUltDOne,2) + "/" + SubStr( cOneFol, 5, 2 ) + "/" + SubStr( cOneFol, 1, 4 ) )
				dDataOne := If( dDataOne > dDataDem, dDataDem, dDataOne )
				fAvos13(@nAvosOne,dDataOne,@nAvosF13O,nFalAtuD,,dDataDem)
				fRetAfas(dDataAux,dDataOne,"13",@nAvosAfO,,,@aAfastO,,,,,.T.,nFalAOne)
				nAvosOne := Max( nAvosOne - nAvosAfO , 0 ) //Abater Afastamentos	
			ElseIf ( StrZero(cAnoRef,4) <=  SubStr( cDesFol, 1, 4 )) .And.  cRecFatEmp $ "S*M*C" 
				dDataDes := cToD( "01/" + SubStr( cDesFol, 5, 2 ) + "/" + SubStr( cDesFol, 1, 4 ) )	
				dDataDes := If( dDataDes > dDataDem, dDataDem, dDataDes )
				fAvos13(@nAvosDes,dDataDes,@nAvosF13D,nFalAtuD,,dDataDes)
				fRetAfas(dDataAux,dDataDes,"13",@nAvosAfD,,,@aAfastD,,,,,.T.,nFalADes)
				nAvosDes := Max( nAvosDes - nAvosAfD , 0 ) //Abater Afastamentos	
			EndIf
			if ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
				AuxSal := salario
				AuxSal1 := SalMes
				salario := nSalMes13
				SalMes := nSalMes13
			Endif
		Else
			// Os avos não serão usados no cálculo quando o contrato for intermitente, irá aparecer apenas como referência
			nAvos := 1
		EndIf 

		//O salario base de horista para o calculo dos adicionais que integram Ferias e 13o deve ser calculado com base em 30 dias.
        If SRA->RA_CATFUNC $ "H"
			//Guarda o valor integral para restaurar apos o termino da rotina
	        nSavPer		:= nIntPercul
	        nSavIns		:= nIntInsal
	        nIntPercul	:= If( Type('nIntResPer') <> "U" .And. nIntResPer > 0, nIntResPer, nIntPercul )
	        nIntInsal	:= If( Type('nIntResIns') <> "U" .And. nIntResIns > 0, nIntResIns, nIntInsal )
	 	EndIf
		
	EndIf

	If !lIntermite .And. !lContrVA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retornar os Avos de Afastamento do Funcionario             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fRetAfas(dDataAux,dDataDem,"13",@nAvosAf,,,@aAfast,,,,,.T.,nFalAtuD)
		
		If nAvosAf > 0 .Or. cPgSalMat == "N"
			nAvos := Max( nAvos - nAvosAf , 0 ) //Abater Afastamentos
		Else
			nAvos := Max( nAvos - nAvosMat , 0 ) //Abater Afastamentos
		EndIf
	
		If !LVB13MAT
			nAvos	 += nAvosMat
			nAvosMat := 0
		Else
			If nAvos > 0 .or. nAvosMat > 0
				nAvos	 += nAvosMat
				nAvosMat := Round(nDMatern/30,0)
				nAvos -= nAvosMat
			Else
				nDMatern := 0 //Zera dias de maternidade pois não possui avos o suficiente para pagamento
			EndIf
		EndIf
	
		//Caso a verba do ID 1446 esteja cadastrada e não exista no calculo original
		//refaz o calculo do 13º indenizado e media de 13º
		If LVB13MAT .And. cCompl == "S" .And. lProxMes .And. aScan( aPdResc, { |x| x[1] == aCodFol[1446,1] } ) == 0 .and. nDMatern > 0
			aPdBkp	:= aClone(aPd)
			aPd		:= {}
			For nX := 1 To Len(aPdResc)
				If aPdResc[nX, 1] $ aCodFol[114,1]
					n13oVal += aPdResc[nX, 5] 
				ElseIf aPdResc[nX, 1] $ aCodFol[251,1]
					n13oMed += aPdResc[nX, 5]
				EndIf
			Next nX
			aEval( aPdResc, { |x| If(x[1] $ aCodFol[114,1]+"/"+aCodFol[251,1] , x[9] := "D", Nil) } )
			n13oValM := ((n13oVal / 12) / 30) * nDMatern
			n13oMedM := ((n13oMed / 12) / 30) * nDMatern
			n13oVal  := ((n13oVal / (nAvos+nAvosMat)) * (nAvos+nAvosMat)) - n13oValM
			n13oMed  := ((n13oMed / (nAvos+nAvosMat)) * (nAvos+nAvosMat)) - n13oMedM			
			fMatriz(aCodfol[114,1],Round(n13oVal,2),Int(nAvos)+0.12, , ,"V","R")
			fMatriz(aCodfol[251,1],Round(n13oMed,2),Int(nAvos)+0.12, , ,"V","R")
			fMatriz(aCodfol[1446,1],Round(n13oValM,2),Int(nAvosMat)+0.12, , ,"V","R")
			fMatriz(aCodfol[1447,1],Round(n13oMedM,2),Int(nAvosMat)+0.12, , ,"V","R")
			For nX := 1 To Len(aPd) 
				aAdd( aPdResc, aClone(aPd[nX]) )
			Next nX
			aPd := aClone(aPdBkp)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma o Mnemonico nA13oIndP ref. indenizacao do Professor   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type( "nA13oIndP" ) == "N" .And. ( SRA->RA_CATFUNC $ "I*J" .And. Type("cCodPgInd")=="C" .And. cTipRes $ cCodPgInd )
			nAvos += nA13oIndP
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Zera array de pensoes descontadas na 2a. parcela do 13o.	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aValP132") == "A"
			aValP132 := {}
		EndIf
	EndIf

	If cPaisLoc == "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 13o  Indenizado                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aIncRes[3] = "S" .and. aCodfol[114,1] # "   "
			nMed13oM := IF(cMedDir = "S" .and. nAvos > 0, ((nMed13oM / (nAvos+nAvosMat)) / 30) * nDMatern, NoRound( (( nMed13oM / 12 ) / 30) * nDMatern, MsDecimais(1) ) )
			If SRA->RA_TPCONTR == "3"
				nMed13o  := IF(cMedDir = "S" .and. nAvos > 0, nMed13o - nMed13oM, ( nMed13o / 12 ) * (nAvos+nAvosMat) - nMed13oM )
				nMed13o  := ( nMed13o / Max( aConvocacao[7] * Max(nDiasC, DiasTrab/aConvocacao[7]) , DiasTrab ) ) * DiasTrab
			Else
				nMed13o  := IF(cMedDir = "S" .and. nAvos > 0, nMed13o - nMed13oM, NoRound(( nMed13o / 12 ) * (nAvos+nAvosMat) - nMed13oM , MsDecimais(1) ) )
			EndIf
			NMEDPER13  := IF(cMedDir = "S" .and. nAvos > 0, NMEDPER13 , NoRound(( NMEDPER13 / 12 ) * (nAvos+nAvosMat), MsDecimais(1) ) )
			NMEDINS13  := IF(cMedDir = "S" .and. nAvos > 0, NMEDINS13 , NoRound(( NMEDINS13 / 12 ) * (nAvos+nAvosMat), MsDecimais(1) ) )
			
			//Media 13o. Salario Rescisao
			If Empty(aCodFol[251,1]) .or. ( cCompl == "S" .and. ( aScan(aPdResc,{|x| x[1] == aCodFol[251,1]}) ) == 0 .and. !fBuscaPdHist(dDataDem,aCodFol[251,1]))//-- Se for complementar e não houve geração da verba na original, faz o cálculo como se a verba de média não existir para não ocorrer problema na fabatpago
				If aScan(aPd,{ |X| X[1] = aCodfol[114,1] .and. X[9] # "D" } ) == 0
					If !lIntermite .And. !lContrVA
						//Verifica se não possui os novos adicionais.
						If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
							nVal13M := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1446')) / 12) / 30 * nDMatern ) + nMed13oM
							nVal13 	:= (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0114')) / 12) * (nAvos+nAvosMat) - nVal13M ) + nMed13o
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0114')
						Else
							nVal13M := (((Salario + nGComis13 + nGTaref13 + fIncSemId('1446')) / 12) / 30 * nDMatern ) + nMed13oM
							nVal13 := (((Salario + nGComis13 + nGTaref13 +  fIncSemId('0114')) / 12) * (nAvos+nAvosMat) - nVal13M ) + nMed13o
							
							If nAdtServ > 0
								nVal13MAts := ( ( nAdtServ / 12) / 30 ) * nDMatern 
								nVal13Ats := Max(( ( nAdtServ / 12) * (nAvos+nAvosMat) ) - nVal13MAts ,0)
							EndIf
							If nIntInsal > 0
								nVal13MIns := ( ( nIntInsal / 12) / 30 ) * nDMatern 
								nVal13Ins := Max(( ( nIntInsal / 12) * (nAvos+nAvosMat) ) - nVal13MIns,0)
							EndIf
							If nIntPercul > 0
								nVal13MPer := ( ( nIntPercul / 12) / 30 ) * nDMatern 
								nVal13Per := Max(( ( nIntPercul / 12) * (nAvos+nAvosMat) ) - nVal13MPer,0)
							EndIf
							If nAdcConf > 0
								nVal13MCon := ( ( nAdcConf / 12) / 30 ) * nDMatern
								nVal13Con := Max(( ( nAdcConf / 12) * (nAvos+nAvosMat) ) - nVal13MCon ,0)
							EndIf
							If nAdcTrf > 0
								nVal13MTra := ( ( nAdcTrf / 12) / 30 ) * nDMatern 
								nVal13Tra := Max(( ( nAdcTrf / 12) * (nAvos+nAvosMat) ) - nVal13MTra ,0)
							EndIf
							
							nBase13   := Salario
							nBase13M  := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1446')
						EndIf
					ElseIf lContrVA
						nBase13 := SALMES
						nVal13 := nBase13 / 12 / 30 * DIASTRAB
					Else
						// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
						nBase13 := 0
						nVal13  := fFer13oInt(@nBase13, .T.)
					EndIf
					
					// Evita gerar valor negativo por conta da lincença meternidade
					nVal13 := Max(nVal13, 0) 

					If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[114,1] } ) ) == 0
						nOrdGrPd++
						aAdd(aSalBase,{aCodfol[114,1],nBase13,nOrdGrPd})
					Else
						aSalBase[nPosSB,2] := nBase13
						aSalBase[nPosSB,3] := nOrdGrPd
					EndIf					
					If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)		
						fMatriz(aCodfol[114,1],Round(nVal13,2),Int(nAvos)+0.12, , ,"V","R")					
					Else
						//Grava as informações no array aSalBase para a correta gravação do campo Base de cálculo.
						//ATS
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1708,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1708,1],nAdtServ,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdtServ
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//PERICULOSIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1684,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1684,1],nIntPercul,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntPercul
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//INSALUBRIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1696,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1696,1],nIntInsal,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntInsal
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//CONFIANÇA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1720,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1720,1],nAdcConf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcConf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//TRANSFERÊNCIA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1714,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1714,1],nAdcTrf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcTrf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						
						//Gera as verbas no APD
						fMatriz(aCodfol[114,1],Round(nVal13,2),Int(nAvos)+0.12, , ,"V","R") // Valor 13 Sem adicionais.
						fMatriz(aCodfol[1708,1],Round(nVal13Ats,2),Int(nAvos)+0.12, , ,"V","R") //ATS 13 Indenizado					 
						fMatriz(aCodfol[1684,1],Round(nVal13Per,2),Int(nAvos)+0.12, , ,"V","R")	//Peric 13 Indenizado
						fMatriz(aCodfol[1690,1],Round(NMEDPER13,2),Int(nAvos+nAvosMat)+0.12, , ,"V","R")	//Peric sobre Médias 13 Indenizado				 
						fMatriz(aCodfol[1696,1],Round(nVal13Ins,2),Int(nAvos)+0.12, , ,"V","R")	//Insal 13 Indenizado
						fMatriz(aCodfol[1702,1],Round(NMEDINS13,2),Int(nAvos+nAvosMat)+0.12, , ,"V","R")	//Insal sobre Médias 13 Indenizado				
						fMatriz(aCodfol[1720,1],Round(nVal13Con,2),Int(nAvos)+0.12, , ,"V","R")	//Confi 13 Indenizado				
						fMatriz(aCodfol[1714,1],Round(nVal13Tra,2),Int(nAvos)+0.12, , ,"V","R")	//Transf 13 Indenizado.
					EndIf
					If LVB13MAT
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1446,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1446,1],nBase13M ,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13M
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf	
						fMatriz(aCodfol[1446,1],Round(nVal13M + nVal13MAts + nVal13MPer + nVal13MIns + nVal13MCon + nVal13MTra,2),Round(nDMatern/30,0)+0.12, , ,"V","R")	
					EndIf
				EndIf
				If cRecFatEmp $ "S*M*C" .And. nAvosDes > 0 .And. ( SubStr ( cOneFol, 5, 2 ) > StrZero ( cMesRef,2) .Or. Empty(cOneFol) )
					If aScan(aPd,{ |X| X[1] = aCodfol[991,1] .and. X[9] # "D" } ) == 0
						If !lIntermite  .And. !lContrVA
							nVal13Des := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0991')) / 12) * nAvosDes ) + nMed13o
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0991')
						ElseIf lContrVA
							nBase13 := SALMES
							nVal13des := nBase13 / 12 / 30 * DIASTRAB
						Else
							// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
							nBase13 	:= 0
							nVal13Des 	:= fFer13oInt(@nBase13, .T.)
						EndIf
						
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[991,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[991,1],nBase13,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf						
						fMatriz(aCodfol[991,1],Round(nVal13Des,2),Int(nAvosDes)+0.12, , ,"V","R")
					EndIf
				ElseIf (nAvosOne > 0 ) .And. ( SubStr ( cOneFol, 1, 4 ) ==  StrZero( cAnoRef,4 )) .And. ( StrZero ( cMesRef,2) > SubStr ( cOneFol, 5, 2 ) ) .And. Len(aTabS033) > 1
					If aScan(aPd,{ |X| X[1] = aCodfol[1385,1] .and. X[9] # "D" } ) == 0
						If !lIntermite  .And. !lContrVA
							nVal13One := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1385')) / 12) * nAvosOne ) + nMed13o
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1385')
						ElseIf lContrVA
							nBase13 := SALMES
							nVal13one := nBase13 / 12 / 30 * DIASTRAB
						Else
							// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
							nBase13 	:= 0
							nVal13One 	:= fFer13oInt(@nBase13,.T.)
						EndIf
						
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1385,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1385,1],nBase13,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						fMatriz(aCodfol[1385,1],Round(nVal13One,2),Int(nAvosOne)+0.12, , ,"V","R")
					EndIf
				EndIf
				
			Else
				nVal13M := (((SalMes + nGComis13 + nGTaref13) / 12) / 30 * nDMatern )
				nVal13  := (((SalMes + nGComis13 + nGTaref13) / 12) * (nAvos + nAvosMat) - nVal13M )
				If aScan(aPd,{ |X| X[1] = aCodfol[114,1] .and. X[9] # "D" } ) = 0
					If !lIntermite  .And. !lContrVA
						If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
							nVal13M := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1446')) / 12) / 30 * nDMatern )
							nVal13  := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0114')) / 12) * (nAvos+nAvosMat) - nVal13M )
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0114')
						Else
							nVal13M := (((Salario + nGComis13 + nGTaref13 + fIncSemId('1446')) / 12) / 30 * nDMatern )
							nVal13 := (((Salario + nGComis13 + nGTaref13 + fIncSemId('0114')) / 12) * (nAvos+nAvosMat) - nVal13M )
							nVal13MAts := ( ( nAdtServ / 12) / 30 ) * nDMatern
							nVal13MIns := ( ( nIntInsal / 12) / 30 ) * nDMatern
							nVal13MPer := ( ( nIntPercul / 12) / 30 ) * nDMatern
							nVal13MCon := ( ( nAdcConf / 12) / 30 ) * nDMatern
							nVal13MTra := ( ( nAdcTrf / 12) / 30 ) * nDMatern
							
							nVal13Ats := Max(( ( nAdtServ / 12) * (nAvos+nAvosMat) ) - nVal13MAts,0)
							nVal13Ins := Max(( ( nIntInsal / 12) * (nAvos+nAvosMat) ) - nVal13MIns,0)
							nVal13Per := Max(( ( nIntPercul / 12) * (nAvos+nAvosMat) ) - nVal13MPer,0)
							nVal13Con := Max(( ( nAdcConf / 12) * (nAvos+nAvosMat) ) - nVal13MCon,0)
							nVal13Tra := Max(( ( nAdcTrf / 12) * (nAvos+nAvosMat) ) - nVal13MTra,0)
							nBase13   := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0114')
							nBase13M  := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 +  fIncSemId('1446')
						EndIf
					ElseIf lContrVA
						nBase13 := SALMES
						nVal13 := nBase13 / 12 / 30 * DIASTRAB
					Else
						// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
						nBase13 := 0
						nVal13 	:= fFer13oInt(@nBase13,.T.)
					EndIf
					
					// Evita gerar valor negativo por conta da lincença meternidade
					nVal13 := Max(nVal13, 0) 
					
					If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[114,1] } ) ) == 0
						nOrdGrPd++
						aAdd(aSalBase,{aCodfol[114,1],nBase13,nOrdGrPd})
					Else
						aSalBase[nPosSB,2] := nBase13
						aSalBase[nPosSB,3] := nOrdGrPd
					EndIf
					If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
						fMatriz(aCodfol[114,1],Round(nVal13,2),Int(nAvos)+0.12, , ,"V","R")
					Else
						//Grava as informações no array aSalBase para a correta gravação do campo Base de cálculo.
						//ATS
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1708,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1708,1],nAdtServ,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdtServ
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//PERICULOSIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1684,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1684,1],nIntPercul,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntPercul
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//INSALUBRIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1696,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1696,1],nIntInsal,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntInsal
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//CONFIANÇA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1720,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1720,1],nAdcConf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcConf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//TRANSFERÊNCIA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1714,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1714,1],nAdcTrf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcTrf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						
						//Gera as Verbas no APD.
						fMatriz(aCodfol[114,1],Round(nVal13,2),Int(nAvos)+0.12, , ,"V","R") // Valor 13 Sem adicionais.
						fMatriz(aCodfol[1708,1],Round(nVal13Ats,2),Int(nAvos)+0.12, , ,"V","R") //ATS 13 Indenizado					 
						fMatriz(aCodfol[1684,1],Round(nVal13Per,2),Int(nAvos)+0.12, , ,"V","R")	//Peric 13 Indenizado				 
						fMatriz(aCodfol[1690,1],Round(NMEDPER13,2),Int(nAvos+nAvosMat)+0.12, , ,"V","R")	//Peric sobre Médias 13 Indenizado
						fMatriz(aCodfol[1696,1],Round(nVal13Ins,2),Int(nAvos)+0.12, , ,"V","R")	//Insal 13 Indenizado				
						fMatriz(aCodfol[1702,1],Round(NMEDINS13,2),Int(nAvos+nAvosMat)+0.12, , ,"V","R")	//Insal sobre Médias 13 Indenizado				
						fMatriz(aCodfol[1720,1],Round(nVal13Con,2),Int(nAvos)+0.12, , ,"V","R")	//Confi 13 Indenizado				
						fMatriz(aCodfol[1714,1],Round(nVal13Tra,2),Int(nAvos)+0.12, , ,"V","R")	//Transf 13 Indenizado
						
					EndIf
					If LVB13MAT
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1446,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1446,1],nBase13M,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13M
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						fMatriz(aCodfol[1446,1],Round(nVal13M + nVal13MAts + nVal13MPer + nVal13MIns + nVal13MCon + nVal13MTra,2),Round(nDMatern/30,5), , ,"V","R")
					EndIf
				EndIf
				If aScan(aPd,{ |X| X[1] = aCodfol[251,1] .and. X[9] # "D" } ) = 0
					fMatriz(aCodfol[251,1],Round(nMed13o,2),Int(nAvos)+0.12, , ,"V","R")
				EndIf
				If LVB13MAT .And. aScan(aPd,{ |X| X[1] = aCodfol[1447,1] .and. X[9] # "D" } ) == 0
					fMatriz(aCodfol[1447,1],Round(nMed13oM,2),Round(nDMatern/30,0)+0.12, , ,"V","R")
				EndIf 
				If (cRecFatEmp $ "S*M*C" .And. nAvosDes > 0) .And. ( SubStr ( cOneFol, 5, 2 ) > StrZero ( cMesRef,2) .Or. Empty(cOneFol) )
					If aScan(aPd,{ |X| X[1] = aCodfol[991,1] .and. X[9] # "D" } ) == 0
						If !lIntermite  .And. !lContrVA
							nVal13Des := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 +  fIncSemId('0991')) / 12) * nAvosDes )
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0991')
						ElseIf lContrVA
							nBase13 := SALMES
							nVal13Des := nBase13 / 12 / 30 * DIASTRAB
						Else
							// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
							nBase13 	:= 0
							nVal13Des 	:= fFer13oInt(@nBase13,.T.)
						EndIf
						nMed13Des := IF(cMedDir = "S" .and. nAvos > 0, nMed13Des , ( nMed13Des / 12 ) * nAvosDes )	
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[991,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[991,1],nBase13,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						fMatriz(aCodfol[991,1],Round(nVal13Des+nMed13Des,2),Int(nAvosDes)+0.12, , ,"V","R")
					EndIf
				ElseIf nAvosOne > 0 .And. ( SubStr ( cOneFol, 1, 4 ) ==  StrZero( cAnoRef,4 )) .And. ( StrZero ( cMesRef,2) > SubStr ( cOneFol, 5, 2 ) )
					If aScan(aPd,{ |X| X[1] = aCodfol[1385,1] .and. X[9] # "D" } ) == 0
						If !lIntermite  .And. !lContrVA
							nVal13One := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1385')) / 12) * nAvosOne )
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('1385')
						ElseIf lContrVA
							nBase13 := SALMES
							nVal13one := nBase13 / 12 / 30 * DIASTRAB
						Else
							// Para contrato intemitente o cálculo será realizado apenas sobre o valor recebido em cada convocação
							nBase13 	:= 0
							nVal13One 	:= fFer13oInt(@nBase13,.T.)
						EndIf
						nMed13One := IF(cMedDir = "S" .and. nAvos > 0, nMed13One , ( nMed13One / 12 ) * nAvosOne )	
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1385,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1385,1],nBase13,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nBase13
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						fMatriz(aCodfol[1385,1],Round(nMed13One,2),Int(nAvosOne)+0.12, , ,"V","R")
					EndIf
				EndIf
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconta 13o ja Pago                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fBusCadBenef( @aCodBenef, fGetCalcRot("6") )
		fBusCadBenef( @aCodBen131, fGetCalcRot("5") )
		
		dbSelectArea("SRC")
		DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))
		
		dbSelectArea("SRD")
		DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"))
		
		cSRCKey := cSRDKey := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetCalcRot("6") + AllTrim(Str(cAnoDemi)) //Inclusao do ano de referencia para procurar somente em periodos do ano atual
		cSRC131Key := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetCalcRot("5") + AllTrim(Str(cAnoDemi)) //Inclusao do ano de referencia para procurar somente em periodos do ano atual
		cSRD131Key := SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_PROCES + fGetCalcRot("5") + AllTrim(Str(cAnoDemi)) //Inclusao do ano de referencia para procurar somente em periodos do ano atual
		
		If ( cAnoRef >= cAnoDemi ) .and. SRD->( MsSeek( cSRDKey ) )
			While SRD->(!Eof() .and. cSRDKey == RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + SubStr(RD_PERIODO,1,4))
				If !(Year(SRD->RD_DATPGT) == cAnoDemi)
					SRD->(DbSkip())
					Loop
				EndIf
				
				//--Soma valores de 13o. na Segunda Parcela
				If RetValSRV(SRD->RD_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" //Provento
					n132Pago += SRD->RD_VALOR
					If SRD->RD_PD == aCodFol[26,1]
						lArred13 := .T.
					EndIf
				EndIf
				//--Grava o Desconto da Antecipacao da 1a. Parcela
				If SRD->RD_PD == aCodFol[183,1]
					n132Pago -= SRD->RD_VALOR //Subtrai Antecipacao
					If aScan(aPd,{ |x| x[1] = aCodfol[183,1] .and. x[9] # "D" } ) = 0
						fMatriz(aCodfol[183,1],SRD->RD_VALOR, , , ,"V","R")
						nBsDed13 += SRD->RD_VALOR	
					EndIf
				EndIf
				//--Inns ja Descontado na 2a. Parcela
				If SRD->RD_PD == aCodFol[070,1]
					nInssP += SRD->RD_VALOR
				EndIf

				//--Base do Inns Ate Limite ja Descontado na 2a. Parcela
				If SRD->RD_PD == aCodFol[019,1]
					nBAtLim += SRD->RD_VALOR
				EndIf
				//--Base do Inns Acima Limite ja Descontado na 2a. Parcela
				If SRD->RD_PD == aCodFol[020,1]
					nBAcLim += SRD->RD_VALOR
				EndIf
				//--Valor do Irrf ja Descontado na 2a. Parcela
				If SRD->RD_PD == aCodFol[071,1]
					nIr13P += SRD->RD_VALOR
				EndIf
				
				//--Valor da Base do Irrf ja Descontado na 2a. Parcela
				If SRD->RD_PD == aCodFol[027,1]
					nIr13_BP += SRD->RD_VALOR
				EndIf

				//--FGTS Calculado na 2a. Parcela
				If SRD->RD_PD == aCodFol[109,1]
					nFgts2Pa	:= SRD->RD_VALOR     
					nFgtsP		:= SRD->RD_VALOR
					dDtPago13   := SRD->RD_DATPGT
					cPer13		:= SRD->RD_PERIODO
				EndIf

				//--Base FGTS Calculado na 2a. Parcela
				If SRD->RD_PD == aCodFol[108,1]
					nFgts_BP	:= SRD->RD_VALOR
				EndIf

				//--Verifica se Teve Inusf. Saldo no 13o.
				If SRD->RD_PD == aCodFol[030,1]
					nInsAnt := 0
					nPos := aScan(aPd,{ |x| x[1] == aCodFol[046,1] .and. x[9] # "D" })
					If nPos > 0
						nInsAnt 	:= aPd[nPos,5]
						aPd[nPos,9] := "D"
					EndIf
					fMatriz(aCodFol[046,1],SRD->RD_VALOR+nInsAnt,,,,,,,,,.T.)
				EndIf	
				//--Valor de pensao alimenticia descontado na 2a. parcela
				If Len(aCodBenef) > 0 .And. Type("aValP132") == "A" .And. Ascan(aCodBenef,{ |x| x[1] == SRD->RD_PD }) > 0
					aAdd( aValP132, { SRD->RD_PD, SRD->RD_VALOR })
				EndIf

				If lTem1437 .And. SRD->RD_PD $ aCodFol[1435,1]+"/"+aCodFol[1436,1]+"/"+aCodFol[1437,1]
					nBsDedM13 += SRD->RD_VALOR
				EndIf

				SRD->(dbSkip())
			EndDo

			//--Grava o Bruto da 2a. Parcela ja subtraida a antecipacao
			If n132Pago > 0 .and. !Empty(aCodfol[247,1])
				If aScan(aPd,{ |x| x[1] == aCodfol[247,1] .and. x[9] # "D" } ) == 0
					fMatriz(aCodfol[247,1],n132Pago, , , ,"V","R", , , , , , , , , , , ,dDtPago13)
					nBsDed13 += n132Pago

					//--Se tem verba de Arredondamento na rescisão e já foi somado no 13o, abate da base
					nPos := aScan(aPd,{ |x| x[1] == aCodfol[044,1] .And. x[9] # "D" })
					If nPos > 0 .And. lArred13
						nBsDed13 -= aPd[nPos,5]
					EndIf
				EndIf
			EndIf

			//--Gravar o valor do FGTS 2.Parcela do 13.Sal, caso tenha gerado a verba id 247
			If aScan(aPd,{ |x| x[1] = aCodfol[247,1] .and. x[9] # "D" } ) > 0 .and. nFgts2Pa > 0 
				fMatriz(aCodfol[722,1],nFgts2Pa, , , ,"V","R")
			EndIf
		ElseIf ( cAnoRef == cAnoDemi ) .and. SRC->( MsSeek( cSRCKey ) )
			While SRC->(!Eof() .and. cSRCKey == RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + SubStr(RC_PERIODO,1,4))
				If !(Year(SRC->RC_DATA) == cAnoDemi)
					SRC->(DbSkip())
					Loop
				EndIf

				//--Soma valores de 13o. na Segunda Parcela
				If RetValSRV(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" //Provento
					n132Pago += SRC->RC_VALOR
					If SRC->RC_PD == aCodFol[26,1]
						lArred13 := .T.
					EndIf
				EndIf
				//--Grava o Desconto da Antecipacao da 1a. Parcela
				If SRC->RC_PD == aCodFol[183,1]
					n132Pago -= SRC->RC_VALOR //Subtrai Antecipacao
					If aScan(aPd,{ |x| x[1] = aCodfol[183,1] .and. x[9] # "D" } ) = 0
						fMatriz(aCodfol[183,1],SRC->RC_VALOR, , , ,"V","R")
						nBsDed13 += SRC->RC_VALOR
					EndIf
				EndIf
				//--Inns ja Descontado na 2a. Parcela
				If SRC->RC_PD == aCodFol[070,1]
					nInssP += SRC->RC_VALOR
				EndIf

				//--Base do Inns Ate Limite ja Descontado na 2a. Parcela
				If SRC->RC_PD == aCodFol[019,1]
					nBAtLim += SRC->RC_VALOR
				EndIf
				//--Base do Inns Acima Limite ja Descontado na 2a. Parcela
				If SRC->RC_PD == aCodFol[020,1]
					nBAcLim += SRC->RC_VALOR
				EndIf
				//--Valor do Irrf ja Descontado na 2a. Parcela
				If SRC->RC_PD == aCodFol[071,1]
					nIr13P += SRC->RC_VALOR
				EndIf
				
				//--Valor da Base do Irrf ja Descontado na 2a. Parcela
				If SRC->RC_PD == aCodFol[027,1]
					nIr13_BP += SRC->RC_VALOR
				EndIf

				//--FGTS Calculado na 2a. Parcela
				If SRC->RC_PD == aCodFol[109,1]
					nFgts2Pa	:= SRC->RC_VALOR     
					nFgtsP		:= SRC->RC_VALOR
				EndIf
				
				//--Base FGTS Calculado na 2a. Parcela
				If SRC->RC_PD == aCodFol[108,1]
					nFgts_BP	:= SRC->RC_VALOR
				EndIf

				If SRC->RC_PD $ aCodFol[109,1]+"*"+aCodFol[22,1]
					dDtPago13   := SRC->RC_DATA
					cPer13		:= SRC->RC_PERIODO
				EndIf

				//--Verifica se Teve Inusf. Saldo no 13o.
				If SRC->RC_PD == aCodFol[030,1]
					nInsAnt := 0
					nPos := aScan(aPd,{ |x| x[1] == aCodFol[046,1] .and. x[9] # "D" })
					If nPos > 0
						nInsAnt 	:= aPd[nPos,5]
						aPd[nPos,9] := "D"
					EndIf
					fMatriz(aCodFol[046,1],SRC->RC_VALOR+nInsAnt,,,,,,,,,.T.)
				EndIf	
				//--Valor de pensao alimenticia descontado na 2a. parcela
				If Len(aCodBenef) > 0 .And. Type("aValP132") == "A" .And. Ascan(aCodBenef,{ |x| x[1] == SRC->RC_PD }) > 0
					aAdd( aValP132, { SRC->RC_PD, SRC->RC_VALOR })
				EndIf

				If lTem1437 .And. SRC->RC_PD $ aCodFol[1435,1]+"/"+aCodFol[1436,1]+"/"+aCodFol[1437,1]
					nBsDedM13 += SRC->RC_VALOR
				EndIf

				SRC->(dbSkip())
			EndDo

			//--Grava o Bruto da 2a. Parcela ja subtraida a antecipacao
			If n132Pago > 0 .and. !Empty(aCodfol[247,1])
				If aScan(aPd,{ |x| x[1] == aCodfol[247,1] .and. x[9] # "D" } ) == 0
					fMatriz(aCodfol[247,1],n132Pago, , , ,"V","R", , , , , , , , , , , ,dDtPago13)
					nBsDed13 += n132Pago

					//--Se tem verba de Arredondamento na rescisão e já foi somado no 13o, abate da base
					nPos := aScan(aPd,{ |x| x[1] == aCodfol[044,1] .And. x[9] # "D" })
					If nPos > 0 .And. lArred13
						nBsDed13 -= aPd[nPos,5]
					EndIf
				EndIf
			EndIf

			//--Gravar o valor do FGTS 2.Parcela do 13.Sal, caso tenha gerado a verba id 247
			If aScan(aPd,{ |x| x[1] = aCodfol[247,1] .and. x[9] # "D" } ) > 0 .and. nFgts2Pa > 0 
				fMatriz(aCodfol[722,1],nFgts2Pa, , , ,"V","R")
			EndIf

		ElseIf ( cAnoRef == cAnoDemi ) .and. SRD->( MsSeek( cSRD131Key ) )
			While SRD->(!Eof() .and. cSRD131Key == RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + SubStr(RD_PERIODO,1,4))
				If !(Year(SRD->RD_DATPGT) == cAnoDemi)
					SRD->(DbSkip())
					Loop
				EndIf

				//--Soma valores de 13o. na Primeira Parcela
				If RetValSRV(SRD->RD_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" //Provento
					n131Pago += SRD->RD_VALOR
				EndIf

				//--FGTS Calculado na 1a. Parcela
				If SRD->RD_PD == aCodFol[109,1]
					nFgts2Pa	:= SRD->RD_VALOR     
					dDtPago13   := SRD->RD_DATPGT
					cPer13		:= SRD->RD_PERIODO
				EndIf

				//--Verifica se Teve Inusf. Saldo no 13o.
				If SRD->RD_PD == aCodFol[030,1]
					nInsAnt := 0
					nPos := aScan(aPd,{ |x| x[1] == aCodFol[046,1] .and. x[9] # "D" })
					If nPos > 0
						nInsAnt := aPd[nPos,5]
					EndIf	
					fMatriz(aCodFol[046,1],SRD->RD_VALOR+nInsAnt,,,,,,,,,.T.)
				EndIf	
				//--Valor de pensao alimenticia descontado na 1a. parcela
				If Len(aCodBen131) > 0 .And. Type("aValP132") == "A" .And. Ascan(aCodBen131,{ |x| x[1] == SRD->RD_PD }) > 0
					fMatriz(SRD->RD_PD,SRD->RD_VALOR, , , ,"V","R")
				EndIf
				SRD->(dbSkip())
			EndDo

			SRR->(DbSetOrder(9)) //--RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)
			
			cKeyAux := SRA->RA_FILIAL + SRA->RA_MAT + "F" + AllTrim(Str(cAnoDemi))
			
			If SRR->( MsSeek( cKeyAux ) ) //--Verifica se houve pagamento de 13º tb nas férias
				While SRR->(!Eof() .and. cKeyAux == RR_FILIAL + RR_MAT + RR_TIPO3 + SubStr(RR_PERIODO,1,4))

					//--Soma valores de 13o. na Primeira Parcela
					If SRR->RR_PD == aCodFol[22,1]
						n131Pago += SRR->RR_VALOR
						Exit
					EndIf
					SRR->(dbSkip())
				EndDo			
			EndIf

			//Verifica se houve antecipação de 13º informado na folha
			SRD->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PD+RD_ROTEIR+DTOS(RD_DATPGT)")))

			cKeyAux := SRA->RA_FILIAL + SRA->RA_MAT + aCodFol[0022,1] + fGetCalcRot("1") + AllTrim(Str(cAnoDemi))

			If SRD->(DbSeek(cKeyAux))
				While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PD + RD_ROTEIR + AllTrim(Str(Year(RD_DATPGT))) == cKeyAux )
					If SubStr(SRD->RD_PERIODO,1,4) == AllTrim(Str(cAnoDemi)) .and. SRD->RD_TIPO2 $ "I/G"
						n131Pago += SRD->RD_VALOR
					EndIf
					SRD->(DbSkip())
				EndDo
			EndIf

			//--Retorna ordem original
			SRD->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA")))

			//--Grava o Valor da 1a. Parcela paga no mes da demissao
			If n131Pago > 0 .And. !(cCompl == "S" .And. lProxMes)
				If cPer13 == AnoMes(dDataDem)
					If aScan(aPd,{ |X| X[1] = aCodfol[1415,1] .and. X[9] # "D" } ) = 0
						fMatriz(aCodfol[1415,1],n131Pago, , , ,"V","R")
					EndIf
				Else
					If aScan(aPd,{ |X| X[1] = aCodfol[116,1] .and. X[9] # "D" } ) = 0
						fMatriz(aCodfol[116,1],n131Pago, , , ,"V","R")
					EndIf			
				EndIf
			EndIf
			//--Gravar o valor do FGTS 2.Parcela do 13.Sal, caso tenha gerado a verba id 247
			If aScan(aPd,{ |x| x[1] = aCodfol[247,1] .and. x[9] # "D" } ) > 0 .and. nFgts2Pa > 0 
				fMatriz(aCodfol[722,1],nFgts2Pa, , , ,"V","R")
			EndIf
		ElseIf ( cAnoRef == cAnoDemi ) .and. SRC->( MsSeek( cSRC131Key ) )
			While SRC->(!Eof() .and. cSRC131Key == RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + SubStr(RC_PERIODO,1,4))
				If !(Year(SRC->RC_DATA) == cAnoDemi)
					SRC->(DbSkip())
					Loop
				EndIf

				//--Soma valores de 13o. na Primeira Parcela
				If RetValSRV(SRC->RC_PD,SRA->RA_FILIAL,"RV_TIPOCOD") == "1" //Provento
					n131Pago += SRC->RC_VALOR
				EndIf

				//--FGTS Calculado na 1a. Parcela
				If SRC->RC_PD == aCodFol[109,1]
					nFgts2Pa	:= SRC->RC_VALOR     
				EndIf

				If SRC->RC_PD $ aCodFol[109,1]+"*"+aCodFol[22,1]
					dDtPago13   := SRC->RC_DATA
					cPer13		:= SRC->RC_PERIODO
				EndIf

				//--Verifica se Teve Inusf. Saldo no 13o.
				If SRC->RC_PD == aCodFol[030,1]
					nInsAnt := 0
					nPos := aScan(aPd,{ |x| x[1] == aCodFol[046,1] .and. x[9] # "D" })
					If nPos > 0
						nInsAnt := aPd[nPos,5]
					EndIf	
					fMatriz(aCodFol[046,1],SRC->RC_VALOR+nInsAnt,,,,,,,,,.T.)
				EndIf	
				//--Valor de pensao alimenticia descontado na 1a. parcela
				If Len(aCodBen131) > 0 .And. Type("aValP132") == "A" .And. Ascan(aCodBen131,{ |x| x[1] == SRC->RC_PD }) > 0
					fMatriz(SRC->RC_PD,SRC->RC_VALOR, , , ,"V","R")
				EndIf
				SRC->(dbSkip())
			EndDo

			SRR->(DbSetOrder(9)) //--RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)
			
			cKeyAux := SRA->RA_FILIAL + SRA->RA_MAT + "F" + AllTrim(Str(cAnoDemi))
			
			If SRR->( MsSeek( cKeyAux ) ) //--Verifica se houve pagamento de 13º tb nas férias
				While SRR->(!Eof() .and. cKeyAux == RR_FILIAL + RR_MAT + RR_TIPO3 + SubStr(RR_PERIODO,1,4))

					//--Soma valores de 13o. na Primeira Parcela
					If SRR->RR_PD == aCodFol[22,1]
						n131Pago += SRR->RR_VALOR
						Exit
					EndIf
					SRR->(dbSkip())
				EndDo			
			EndIf			

			//--Grava o Valor da 1a. Parcela paga no mes da demissao
			If n131Pago > 0 .And. !(cCompl == "S" .And. lProxMes)

				If cPer13 == AnoMes(dDataDem)
					If aScan(aPd,{ |X| X[1] = aCodfol[1415,1] .and. X[9] # "D" } ) = 0
						fMatriz(aCodfol[1415,1],n131Pago, , , ,"V","R")
					EndIf
				Else
					If aScan(aPd,{ |X| X[1] = aCodfol[116,1] .and. X[9] # "D" } ) = 0
						fMatriz(aCodfol[116,1],n131Pago, , , ,"V","R")
					EndIf
				EndIf
			EndIf
			//--Gravar o valor do FGTS 2.Parcela do 13.Sal, caso tenha gerado a verba id 247
			If aScan(aPd,{ |x| x[1] = aCodfol[247,1] .and. x[9] # "D" } ) > 0 .and. nFgts2Pa > 0 
				fMatriz(aCodfol[722,1],nFgts2Pa, , , ,"V","R")
			EndIf

		ElseIf nDesc13 > 0 .And. !Empty(aCodFol[116,1]) .And. !Empty(aCodFol[183,1]) .And. ( cCompl # "S" .or. !lProxMes)
			//--Desconto o 13o. Pago em Meses Anteriores, senao for rescisao complementar
			If cCompl # "S" .and. ( nPos := aScan(aPd,{ |X| X[1] = aCodfol[22,1] .and. X[9] # "D" } ) ) > 0 // Soma a 1a. parcela paga no mes
				nVal1aP	:= aPd[nPos,5]
			EndIf
			If aScan(aPd,{ |X| X[1] = aCodfol[116,1] .and. X[9] # "D" } ) = 0
				fMatriz(aCodfol[116,1],nDesc13+nVal1aP, , , ,"V","R")
			EndIf
		ElseIf !Empty(aCodFol[116,1]) .and. !Empty(aCodFol[183,1])
			//--VerIFica se o 13o. Foi Antecipado no Mes e Efetua o Desconto
			If Month(dDataDem) = 12 //Quando Demissao em Dezembro, gerar no Id. 183
				If ( nPos := aScan(aPd,{ |X| X[1] = aCodfol[22,1] .and. X[9] # "D" } ) ) > 0
					fMatriz(aCodfol[183,1],aPd[nPos,5], , , ,"V","R")
					nBsDed13 += aPd[nPos,5]
				EndIf
			Else					//Caso contrario, gerar no Id. 116
				If ( nPos := aScan(aPd,{ |X| X[1] = aCodfol[22,1] .and. X[9] # "D" } ) ) > 0
					fMatriz(aCodfol[116,1],aPd[nPos,5], , , ,"V","R")
				EndIf	
			EndIf	
		EndIf



		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ 13o. Ind. Av. Previo                                       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If aIncRes[3] = "S" .and. aCodfol[115,1] # "   " .and. (aIncRes[2] $ "SIA" .Or. ;
		(aIncRes[17] == "S" .And. lProj .And. aIncRes[2] $ "TB") )  
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Funcao que Retorna os Avos Com Av. Previo do Funcionario   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			//-- Quando o aviso previo for indenizado, as faltas ja foram consideradas para calculo
			//-- do abatimento de avos (n13MenosAvos) no GPEXMED e, portanto, nao iremos considerar
			//-- na verificacao do avo referente ao mes acrescido com os dias do aviso previo
			If !lIntermite  .And. !lContrVA
				nAvFalMes := 0
				If nAvosFal13 > 0 .And. cCompl != "S" .and. nDiaInde > 0 .And. Day(dDataDem) >= 15
					If (cTBLXMED)->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"3"+"998"+AnoMes(dDataDem))) //Verifica se houve faltas no mês da rescisão
						//Se houve menos que 16 faltas no mês da rescisão, subtrai um avo perdido por falta, pois deverá ser recalculado o mês inteiro considerando os dias de aviso
						If (cTBLXMED)->RP_HORAS <= 15 .And. (Day(dDataDem) - (cTBLXMED)->RP_HORAS) < 15
							nAvFalMes := 1
						EndIf
					Endif
					//Se o cálculo da rescisão não considerar o mês para média avaliamos no apd se há verba de falta
					If !lMesAtu
						nPosFal := aScan(apd, { |x| x[1] == aCodFol[54,1] .And. x[9] # "D" } )
						If nPosFal > 0 .And. aPd[nPosFal,4] < 15 .And. (Day(dDataDem) - aPd[nPosFal,4]) < 15
							nAvFalMes := 1
						EndIf
					EndIf
				EndIf
				If aIncRes[2] $ "T*B"
					fAvos13(@nAvosAv, Iif(cPaisLoc == "BRA" .And. P_PRJESTAB .And. dDtEst936 > dDataDem, dDtEst936 + nDiaInde, dDataDem + nDiaInde), nAvosFal13 - nAvFalMes, nFalAtuD, , dDataDem, , .T.)
				Else
					fAvos13(@nAvosAv, Iif(cPaisLoc == "BRA" .And. P_PRJESTAB .And. dDtEst936 > dDataDem, dDtEst936 + nDiasAv, dDataDem + nDiasAv), nAvosFal13 - nAvFalMes, nFalAtuD, , dDataDem, , .T.)
				Endif

				If nAvosAf > 0 .or. cPgSalMat == "N"
					If aIncRes[2]$ "T"
						fRetAfas(dDataAux,dDataDem+nDiaInde,"13",@nAvosDesc,,,@aAfast,,,,,.T.,nFalAtuD)
					Else		
						fRetAfas(dDataAux,dDataDem+nDiasAv,"13",@nAvosDesc,,,@aAfast,,,,,.T.,nFalAtuD)
					Endif	
					nAvosAv := Max( nAvosAv - nAvosAf , 0 ) //Abater Afastamentos
					If !LVB13MAT
						nAvosAv	 += nAvosMat
						nAvosMat := 0
					Else
						nAvosAv	 += nAvosMat
						nAvosMat := Round(nDMatern/30,0)
						nAvosAv -= nAvosMat
					EndIf
					nAvosAv :=  Max( nAvosAv  - ( nAvos + If(nAvos == 0, nAvosFal13 - Iif(nAvosAv == 1, nAvFalMes, 0), 0) )  , 0 ) //Abater Afastamentos
				Else
					nAvosAv -= nAvos + nAvosMat
				EndIf
			Else
				// Os avos não serão usados no cálculo quando o contrato for intermitente, irá aparecer apenas como referência
				nAvosAv := 1
			EndIf

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Quando avos de 13o for Zero e houver avos indenizados apurar media pelo avos indenizado ³
			³caso contratio apura media do avo indenizado sobre a media paga no 13o.				 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If nAvos = 0 .And. nAvosAv > 0
				nMed13oA := If(cMedDir = "S", nMed13Av/nAvosAv , nMed13Av / 12 )
				nMdPer13Av := If(cMedDir = "S", NMEDPER13/nAvosAv , NMEDPER13 / 12 )
				nMdIns13Av := If(cMedDir = "S", NMEDINS13/nAvosAv , NMEDINS13 / 12 )
			Else
				nMed13oA := If (nAvos > 0,nMed13o / nAvos,0)
				nMdPer13Av := If (nAvos > 0,NMEDPER13 / (nAvos+nAvosMat),0)
				nMdIns13Av := If (nAvos > 0,NMEDINS13 / (nAvos+nAvosMat),0)
			EndIf	

			nValAux := 0

			//Media 13o. Salario Sobre Aviso Indenizado Rescisao
			If Empty(aCodFol[253,1]) .or. ( cCompl == "S" .and. ( aScan(aPdResc,{|x| x[1] == aCodFol[253,1]}) ) == 0 .and. !fBuscaPdHist(dDataDem,aCodFol[253,1])) //--Se a verba não foi calculada na original, efetua o cálculo como se ela não existisse, para não ocorrer problemas em fAbatPago
				If aScan(aPd,{ |X| X[1] = aCodfol[115,1] .and. X[9] # "D" } ) == 0
					If !lIntermite  .And. !lContrVA
						If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
							nVal13av := ((((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0115')) / 12 ) + nMed13oA)  * nAvosAv)
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0115')
						Else
							nVal13av := ((((Salario + nGComis13 + nGTaref13 + fIncSemId('0115')) / 12 ) + nMed13oA)  * nAvosAv)
							If nAdtServ > 0
								nVal13Ats := ( nAdtServ / 12 ) * nAvosAv
							EndIf
							If nIntPercul > 0
								nVal13Per := ( nIntPercul / 12 ) * nAvosAv
							EndIf
							If nIntInsal > 0
								nVal13Ins := ( nIntInsal / 12 ) * nAvosAv
							EndIf
							If nAdcConf > 0
								nVal13Con := ( nAdcConf / 12 ) * nAvosAv
							EndIf
							If nAdcTrf > 0
								nVal13Tra := ( nAdcTrf / 12 ) * nAvosAv
							EndIf
							nMdPer13Av := nMdPer13Av * nAvosAv
							nMdIns13Av := nMdIns13Av * nAvosAv
							nBase13 := Salario + nGComis13 + nGTaref13 + fIncSemId('0115')
						EndIf
					Else
						nBase13 := Salario / NDIASC * NDIASAV
						nVal13av := nBase13 / 12
					EndIf
					
					If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[115,1] } ) ) == 0
						nOrdGrPd++
						aAdd(aSalBase,{aCodfol[115,1],nBase13,nOrdGrPd})
					Else
						aSalBase[nPosSB,2] := nBase13
						aSalBase[nPosSB,3] := nOrdGrPd
					EndIf
					If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
						fMatriz(aCodfol[115,1],Round(nVal13av,2),Int(nAvosAv)+0.12, , ,"V","R")
					Else
						//Grava as informações no array aSalBase para a correta gravação do campo Base de cálculo.
						//ATS
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1709,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1709,1],nAdtServ,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdtServ
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//PERICULOSIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1685,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1685,1],nIntPercul,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntPercul
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//INSALUBRIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1697,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1697,1],nIntInsal,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntInsal
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//CONFIANÇA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1721,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1721,1],nAdcConf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcConf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//TRANSFERÊNCIA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1715,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1715,1],nAdcTrf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcTrf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf

						//Grava as verbas no APD.
						IIF(nVal13av < 0 , nVal13av := 0 ,fMatriz(aCodfol[115,1],Round(nVal13av,2),Int(nAvosAv)+0.12, , ,"V","R")) // 13 Sobre Aviso Prévio
						IIF(nVal13Ats < 0, nVal13Ats := 0,fMatriz(aCodfol[1709,1],Round(nVal13Ats,2),Int(nAvosAv)+0.12, , ,"V","R")) // ATS 13. Aviso						
						IIF(nMdPer13Av < 0, nMdPer13Av := 0,fMatriz(aCodfol[1691,1],Round(nMdPer13Av,2),Int(nAvosAv)+0.12, , ,"V","R")) // Periculosidade Média 13. Aviso
						IIF(nVal13Ins < 0, nVal13Ins := 0 ,fMatriz(aCodfol[1697,1],Round(nVal13Ins,2),Int(nAvosAv)+0.12, , ,"V","R")) // Insalubridade 13. Aviso
						IIF(nMdIns13Av < 0, nMdIns13Av :=0, fMatriz(aCodfol[1703,1],Round(nMdIns13Av,2),Int(nAvosAv)+0.12, , ,"V","R")) // Insalubridade Média 13. Aviso
						IIF(nVal13Con < 0, nVal13Con := 0, fMatriz(aCodfol[1721,1],Round(nVal13Con,2),Int(nAvosAv)+0.12, , ,"V","R")) // Adic. Confiança 13. Aviso
						IIF(nVal13Tra < 0, nVal13Tra := 0, fMatriz(aCodfol[1715,1],Round(nVal13Tra,2),Int(nAvosAv)+0.12, , ,"V","R")) // Adic. Transferência 13. Aviso
						If aScan(aPd,{|x| x[1] == aCodFol[1685,1] .And. x[9] != "D" .And. x[7] == "I" } ) == 0
							IIF(nVal13Per < 0 , nVal13Per := 0,fMatriz(aCodfol[1685,1],Round(nVal13Per,2),Int(nAvosAv)+0.12, , ,"V","R")) // Periculosidade 13. Aviso
						EndIf
					EndIf
				EndIf
			Else
				nMed13oA := nMed13oA * nAvosAv
				If aScan(aPd,{ |X| X[1] = aCodfol[115,1] .and. X[9] # "D" } ) = 0
					If !lIntermite  .And. !lContrVA
						If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
							nVal13av := (((Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0115')) / 12 ) * nAvosAv)
							nBase13 := Salario + nAdtServ + nIntPercul + nIntInsal + nAdcConf + nAdcTrf + nGComis13 + nGTaref13 + fIncSemId('0115')
						Else
							nVal13av := ( (Salario + nGComis13 + nGTaref13 + fIncSemId('0115')) / 12 ) * nAvosAv
							nVal13Ats :=  ( nAdtServ / 12 ) * nAvosAv
							nVal13Per :=  ( nIntPercul / 12 ) * nAvosAv
							nVal13Ins :=  ( nIntInsal / 12 ) * nAvosAv
							nVal13Con :=  ( nAdcConf / 12 )  * nAvosAv
							nVal13Tra :=  ( nAdcTrf / 12 )  * nAvosAv
							nMdIns13Av := nMdIns13Av * nAvosAv
							nMdPer13Av := nMdPer13Av * nAvosAv
							nBase13 := Salario + nGComis13 + nGTaref13 + fIncSemId('0115')
						EndIf
					Else
						nBase13 := Salario / NDIASC * NDIASAV
						nVal13av := nBase13 / 12
						fFer13oInt( , .T., .T. )
					EndIf
					If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[115,1] } ) ) == 0
						nOrdGrPd++
						aAdd(aSalBase,{aCodfol[115,1],nBase13,nOrdGrPd})
					Else
						aSalBase[nPosSB,2] := nBase13
						aSalBase[nPosSB,3] := nOrdGrPd
					EndIf
					If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)
						fMatriz(aCodfol[115,1],Round(nVal13av,2),Int(nAvosAv)+0.12 , , ,"V","R")
					Else
						//Grava as informações no array aSalBase para a correta gravação do campo Base de cálculo.
						//ATS
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1709,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1709,1],nAdtServ,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdtServ
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//PERICULOSIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1685,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1685,1],nIntPercul,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntPercul
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//INSALUBRIDADE
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1697,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1697,1],nIntInsal,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nIntInsal
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//CONFIANÇA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1721,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1721,1],nAdcConf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcConf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf
						//TRANSFERÊNCIA.
						If ( nPosSB := aScan(aSalBase, { |X| X[1] == aCodfol[1715,1] } ) ) == 0
							nOrdGrPd++
							aAdd(aSalBase,{aCodfol[1715,1],nAdcTrf,nOrdGrPd})
						Else
							aSalBase[nPosSB,2] := nAdcTrf
							aSalBase[nPosSB,3] := nOrdGrPd
						EndIf

						//Grava as verbas no APD
						IIF(nVal13av < 0 , nVal13av := 0 ,fMatriz(aCodfol[115,1],Round(nVal13av,2),Int(nAvosAv)+0.12, , ,"V","R")) // 13 Sobre Aviso Prévio
						IIF(nVal13Ats < 0, nVal13Ats := 0,fMatriz(aCodfol[1709,1],Round(nVal13Ats,2),Int(nAvosAv)+0.12, , ,"V","R")) // ATS 13. Aviso						
						IIF(nMdPer13Av < 0, nMdPer13Av := 0,fMatriz(aCodfol[1691,1],Round(nMdPer13Av,2),Int(nAvosAv)+0.12, , ,"V","R")) // Periculosidade Média 13. Aviso
						IIF(nVal13Ins < 0, nVal13Ins := 0 ,fMatriz(aCodfol[1697,1],Round(nVal13Ins,2),Int(nAvosAv)+0.12, , ,"V","R")) // Insalubridade 13. Aviso
						IIF(nMdIns13Av < 0, nMdIns13Av :=0, fMatriz(aCodfol[1703,1],Round(nMdIns13Av,2),Int(nAvosAv)+0.12, , ,"V","R")) // Insalubridade Média 13. Aviso
						IIF(nVal13Con < 0, nVal13Con := 0, fMatriz(aCodfol[1721,1],Round(nVal13Con,2),Int(nAvosAv)+0.12, , ,"V","R")) // Adic. Confiança 13. Aviso
						IIF(nVal13Tra < 0, nVal13Tra := 0, fMatriz(aCodfol[1715,1],Round(nVal13Tra,2),Int(nAvosAv)+0.12, , ,"V","R")) // Adic. Transferência 13. Aviso
						If aScan(aPd,{|x| x[1] == aCodFol[1685,1] .And. x[9] != "D" .And. x[7] == "I" } ) == 0
							IIF(nVal13Per < 0 , nVal13Per := 0,fMatriz(aCodfol[1685,1],Round(nVal13Per,2),Int(nAvosAv)+0.12, , ,"V","R")) // Periculosidade 13. Aviso
						EndIf
					EndIf
				EndIf
				If aScan(aPd,{ |X| X[1] = aCodfol[253,1] .and. X[9] # "D" } ) = 0 
					fMatriz(aCodfol[253,1],Round(nMed13oA,2),Int(nAvosAv)+0.12, , ,"V","R")
				EndIf
			EndIf
		EndIf
	EndIf

	//Gera verba de Id 1661 - Base dedutora INSS 13º
	If Len(aCodFol) >= 1661 .And. aCodfol[1661,1] # Space(3) .And. aScan(aPD, { |x| x[1] == aCodFol[247,1] .And. x[9] <> "D" .And. x[5] > 0} ) > 0 
		fMatriz(aCodFol[1661,1],nBsDed13,,,,"V","R")
	EndIf

	//Gera verba de Id 1878 - Base dedutora maternidade 13º
	If Len(aCodFol) >= 1878 .And. aCodfol[1878,1] # Space(3) .And. aScan(aPD, { |x| x[1] == aCodFol[1446,1] .And. x[9] <> "D" .And. x[5] > 0} ) > 0 
		fMatriz(aCodFol[1878,1],nBsDedM13,,,,"V","R")
	EndIf

	If cPaisLoc == "BRA"
		If SRA->RA_CATFUNC == "H" 
			If LHOJORVA 
				Salario := AuxSal
				SalMes  := AuxSal1
			EndIf
	        nIntPercul	:= nSavPer
	        nIntInsal	:= nSavIns
	 	EndIf			
	Endif

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fCalAvi 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Apurar os Valores de Aviso Previo na Rescisao				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fCalAvi( aPd , aCodfol , nMedAviso )						³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fCalAvi( aPd , aCodfol , nMedAviso )

	Local nValAv	:= nValAvd :=  0.00
	Local nMeses	:= 0
	Local nSalAux	:= 0
	Local nValAux	:= 0
	Local nPos		:= 0

	//--Achar o Numero de Meses Trabalhados
	nMeses := ( Year(dDatadem) - Year(SRA->RA_ADMISSA) ) * 12
	nMeses += ( Month(dDataDem) - Month(SRA->RA_ADMISSA) )
	nMeses := IF (nMeses > 12 , 12 , nMeses )


	If cPaisLoc == "BRA"
		If aIncRes[2]$ "SIA" .Or. (aIncRes[2]$ "T" .And. nDiaInde>0) 
			If aIncRes[2]$ "T" .And. nDiaInde>0	
				nBkpAv:= nDiasAv
				nDiasAv := nDiaInde
			Endif
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Soma das Verbas Mensais c/ Inc. para Media Av.Previo       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If RetValSRV(aCodfol[111,1],SRA->RA_FILIAL,"RV_BASCAL") <> "2"
				nSalAux := Salario + nAdtServ + nPeric + nInsalub + nAdcConf + nAdcTrf + NINCSEMID
			Else
				If RetValSRV( cCodAdt, SRA->RA_FILIAL, "RV_INCORP" ) != "S"
					nValAux += nAdtServ
				EndIf
				If RetValSRV( cCodConf, SRA->RA_FILIAL, "RV_INCORP" ) != "S"
					nValAux += nAdcConf
				EndIf
				If RetValSRV( cCodIns, SRA->RA_FILIAL, "RV_INCORP" ) != "S"
					nValAux += nInsalub
				EndIf					
				If RetValSRV( cCodPer, SRA->RA_FILIAL, "RV_INCORP" ) != "S"
					nValAux += nPeric
				EndIf
				If RetValSRV( cCodTrf, SRA->RA_FILIAL, "RV_INCORP" ) != "S"
					nValAux += nAdcTrf
				EndIf
				nSalAux := SalMes + nValAux
			EndIf
			If Empty(aCodFol[250,1])//Media Aviso Previo Rescisao
				If !Empty(aCodfol[111,1]) .and. nDiasAv > 0 .and. aScan(aPd,{ |X| X[1] = aCodfol[111,1] .and. X[9] # "D" } ) == 0
					// Nao considerar a verba de Periculosidade (ID 036) se estiver como Incorpora no Salario
					// na composicao do Aviso Indenizado devido este valor ja estar somado no SALMES.
					nValAv := (nSalAux + nGComisAv + nMedAviso + nGTarefAv ) / 30 * nDiasAv
					fMatriz(aCodfol[111,1],Round(nValav,2),nDiasAv, , ,'V',"R")
				EndIf
			Else
				If !Empty(aCodfol[111,1]) .and. nDiasAv > 0

					// Nao considerar a verba de Periculosidade (ID 036) se estiver como Incorpora no Salario
					// na composicao do Aviso Indenizado devido este valor ja estar somado no SALMES.
					nPos := Ascan( aPD, { |x| x[1] == aCodfol[036,1] } )

					// Nao considerar a verba de Periculosidade (ID 036) se estiver como Incorpora no Salario
					nValAv	:= ( nSalAux + nAdtServ + nPeric + nInsalub + nGComisAv + nGTarefAv + nAdcConf + nAdcTrf) / 30 * nDiasAv

					nMedAviso	:= ( (nMedAviso / 30 ) * nDiasAv )
				EndIf
				If aScan(aPd,{ |X| X[1] = aCodfol[111,1] .and. X[9] # "D" } ) == 0
					fMatriz(aCodfol[111,1],Round(nValav,2),nDiasAv, , ,'V',"R")
				EndIf
				If aScan(aPd,{ |X| X[1] = aCodfol[250,1] .and. X[9] # "D" } ) == 0
					fMatriz(aCodfol[250,1],Round(nMedAviso,2),nDiasAv, , ,'V',"R")
				EndIf
			EndIf
			If aIncRes[2]$ "T" .And. nDiaInde>0	 // vai calcular agora os dias trabalhados
				nDiasAv := nBkpAv
				fCalAPTrab(aPd , aCodfol , nMedAviso) // Calcula dias de aviso Previo trabalhado
			Endif
		ElseIf aIncRes[2]$ "T" .and. ( !Empty(M->RG_DTAVISO) .or. nDiasAv > 0 ) .and. aCodfol[112,1] # Space(3) .and. nDiasAv <> fComplAvP(dDatadem1,nAnosCasa)
			fCalAPTrab(aPd , aCodfol , nMedAviso) // Calcula dias de aviso Previo trabalhado

		ElseIf aIncRes[2]$ "D" .and. nDiasAv > 0 .and. aCodfol[113,1] # Space(3)

			If RetValSRV(aCodfol[113,1],SRA->RA_FILIAL,"RV_BASCAL") <> "2"
				nValAvd  := ( Salario / 30 ) * nDiasAv
			Else
				nValAvd  := ( SalMes / 30 ) * nDiasAv
			EndIf

			// Geracao da Verba de Desconto para Media do Aviso Previo //
			If P_DESCMEDA == "S"
				nMedAviso	:= ( (nMedAviso / 30 ) * nDiasAv )
				If aCodfol[972,1] # "   " .and. nDiasAv > 0
					If aScan(aPd,{ |X| X[1] = aCodfol[972,1] .and. X[9] # "D" } ) = 0
						fMatriz(aCodfol[972,1],Round(nMedAviso,2),nDiasAv, , ,'V',"R")
					EndIf
				ElseIf nDiasAv > 0
					nValAvd += nMedAviso
				EndIf
			EndIf

			If aScan(aPd,{ |X| X[1] = aCodfol[113,1] .and. X[9] # "D" } ) = 0
				fMatriz(aCodfol[113,1],Round(nValavd,2),nDiasAv, , ,'V',"R")
			EndIf
		EndIf
	EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fPagMultConEx ³ Autor ³ Allyson M 	³ Data ³ 19.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera a verba de multa de contrato de experiencia e para 	  ³±±
±±³          ³ para contratos determinados artigos 479 e 480 da CLT.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function fPagMultConEx( nTpMulta, lMulDeterm )

	Local dVctoExp := CtoD("")
	Local aAfast    := {}
	Local cCodAfa   := ""
	Local dDtCong   := CtoD("")
	Local dDtRet    := CtoD("")
	Local nBase	   := 0
	Local nComis   := 0
	Local nGComis  := 0
	Local nMedCom  := 0
	Local nMeses   := 0
	Local nAdic	   := 0   
	Local cCodPd   := 0
	Local nPosPd   := 0
	Local nDiasAf 	:= 0
	Local nDiasAux 	:= 0 
	Local nPosAfas	:= 0
	Local nPosUltAf	:= 0
	Local nQtDiasOP	:= 0
	Local nNewSalBs	:= 0
	Local nDiasMlt	:= 0
	Local lGrMulta	:= .F.
	Local lTrDiasCMl := Type("P_RESMULTH") # "U"

	Default nTpMulta 	:= 1
	Default lMulDeterm	:= .F.

	If SRA->RA_CATFUNC == "C" .And. SRA->RA_SALARIO == 0
		//Garantia de comissao do sindicato do funcionario
		nGComis := fDesc("RCE", SRA->RA_SINDICA, "RCE_GCOMISS", Nil, SRA->RA_FILIAL)
		//Numero de meses para media
		nMeses 	:= DateDiffMonth( SRA->RA_ADMISSA , dDataDem ) + 1
		//Busca o valor das verbas de comissao e garantia de comissao no acumulado desde a admissao ate a data de demissao
		nComis 	:= fBuscaAcm(aCodfol[121,1]+"/"+aCodfol[122,1]+"/"+aCodfol[165,1]+"/"+aCodfol[166,1]+"/"+aCodfol[347,1],,SRA->RA_ADMISSA,dDataDem,"V")
		//Se considerar o mes atual para as medias, busca o valor das verbas geradas no calculo da rescisao
		If lMesAtu
			aEval( aPd ,{ |aPd| IF(aPd[1] $ aCodfol[121,1]+"/"+aCodfol[122,1]+"/"+aCodfol[165,1]+"/"+aCodfol[166,1]+"/"+aCodfol[347,1] .And. aPd[3] = cSemana .And. aPd[9] # "D", nComis += aPd[5], Nil) } )	
		EndIf
		//Divide o total da comissao pelo numero de meses trabalhados
		nMedCom := nComis / nMeses
		//Caso a media seja menor do que a garantia de comissao utiliza a garantia de comissao
		nBase := If( nMedCom < nGComis , nGComis, nMedCom)
	Else
		If RetValSRV(aCodfol[176,1],SRA->RA_FILIAL,"RV_BASCAL") <> "2" 
			nBase := Salario
			If SRA->RA_CATFUNC == "H"
				If lTrDiasCMl // Troca Salario Base e Dias de Calculo para Multa
					nDiasMlt := If( ((aPeriodo[nPosSem,18] == 31 .Or. aPeriodo[nPosSem,16] == "02") .And. P_RESMULTH = 1), aPeriodo[nPosSem,18],If(P_RESMULTH == 2, 30, aPeriodo[nPosSem,20]))    
					If P_RESMULTH == 1
						nBase := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * aPeriodo[nPosSem,18]),2)
					Else
						nBase := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * 30),2)
					EndIf
				Else
					If P_DIASRES == 1
						// No caso do horista, SALARIO é sempre o contratual (Salário Hora x Horas Mensais - 220h, 30 dias)
						nBase := SRA->RA_SALARIO * nHrsCal  
					EndIf
				EndIf			
			EndIf
		Else 	
			nBase := SalMes			
			If SRA->RA_CATFUNC == "H"
				If lTrDiasCMl // Troca Salario Base e Dias de Calculo para Multa
					nDiasMlt := If( ((aPeriodo[nPosSem,18] == 31 .Or. aPeriodo[nPosSem,16] == "02") .And. P_RESMULTH = 1), aPeriodo[nPosSem,18],If(P_RESMULTH == 2, 30, aPeriodo[nPosSem,20]))    
					If P_RESMULTH == 1
						// Subtrai salário mês calculado de acordo com P_DIASRES e soma novo salário base de acordo 
						// com novo mnemônico
						nNewSalBs := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * aPeriodo[nPosSem,18]),2)
						nBase	  := SalMes - (SRA->RA_SALARIO * nHrsCal)  
						nBase	  += nNewSalBs
					Else
						nNewSalBs := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * 30),2)
						nBase	  := SalMes - SRA->RA_SALARIO * nHrsCal  
						nBase	  += nNewSalBs
					EndIf
				EndIf			
			EndIf
		EndIf
	EndIf

	dVctoExp := If( nTpMulta == 1, SRA->RA_VCTOEXP, SRA->RA_VCTEXP2 )
	dVctoExp := If( lMulDeterm, SRA->RA_DTFIMCT, dVctoExp )

	// Busca afastamentos do funcionário que possam ter ocorrido
	// durante o período de expiração de contrato
	fRetAfas(SRA->RA_VCTOEXP,SRA->RA_VCTEXP2,"F",,@nDiasAf,,@aAfast,,.F.,,,,,) 
	If Len( aAfast ) > 0
		For	nPosAfas := 1 To Len( aAfast )
			If aAfast[nPosAfas,16] $ "O1*P1"
				nQtDiasOP += aAfast[ nPosAfas, 2 ] // Qtde. de dias de afastamento no periodo
			EndIf
		Next nPosAfas

		If nQtDiasOP > 15
			// Busca Data de Congelamento de Contrato,  data após pagamento dos Dias Empresa
			nPosUltAf := aScan( aAfast, { | x | ( x[ 3 ] <= dVctoExp .And. dVctoExp <= x[ 4 ] ) } )
			If nPosUltAf > 0
				cCodAfa	:= aAfast[ nPosUltAf, 7 ]
				If ( nPosConAf := aScan( aAfast, { |x| x[8] == cCodAfa } ) ) > 0
					dDtCong	:= aAfast[ nPosConAf, 3 ] + aAfast[nPosConAf, 15]
					dDtRet	:= aAfast[ nPosConAf, 4 ]
				Else
					dDtCong  := aAfast[ nPosUltAf, 3 ] + aAfast[nPosUltAf, 15]
					dDtRet	:= aAfast[ nPosUltAf, 4 ]
				EndIf  
			EndIf

			// Busca quantidade de dias entre Data de Congelamento e Data de Expiração 2
			nDiasAux := If( SRA->RA_VCTEXP2 >= dDtCong .And. dDtCong <= SRA->RA_VCTOEXP, 0 , SRA->RA_VCTEXP2 - dDtCong + 1 )  
			
			// Nova Data de Vencimento de Contrato será Data do retorno do afastamento somado
			// a quantidade de dias que funcionário ainda tem direito a cumprir
			If !Empty(dDtRet)
				dVctoExp :=  dDtRet + nDiasAux 
			EndIf
			lGrMulta := If (nTpMulta == 1, If( lMulDeterm, dVctoExp > DDATADEM , dVctoExp > dDataDem1 ), SRA->RA_VCTOEXP < dDataDem1 .AND. dVctoExp > dDataDem1)
		Else
			lGrMulta :=  If (nTpMulta == 1, If( lMulDeterm, SRA->RA_DTFIMCT > DDATADEM , SRA->RA_VCTOEXP > dDataDem1 ), SRA->RA_VCTOEXP < dDataDem1 .AND. SRA->RA_VCTEXP2 > dDataDem1)
		EndIf
	Else
	 	lGrMulta :=  If (nTpMulta == 1, If( lMulDeterm, SRA->RA_DTFIMCT > DDATADEM , SRA->RA_VCTOEXP > dDataDem1 ), SRA->RA_VCTOEXP < dDataDem1 .AND. SRA->RA_VCTEXP2 > dDataDem1)
	EndIf

	If lGrMulta
		If P_ADIMULEX
			nAdic := NPERIC + NINSALUB + VAL_ANU + VAL_BIE + VAL_TRI + VAL_QUA + VAL_QUI + NADCCONF + NADCTRF + NADTSERV  
			// Atualiza valor de base de calculo
			nOrdGrPd++    
			cCodPd	:= aCodfol[176,1]
			If ( nPosPd := aScan(aSalBase, { |X| X[1] == cCodPd } ) ) == 0
				aAdd(aSalBase,{cCodPd,nBase + nAdic,nOrdGrPd})
			Else
				aSalBase[nPosPd,2] := nBase + nAdic
				aSalBase[nPosPd,3] := nOrdGrPd
			EndIf		
			If !lMulDeterm
				fGeraVerba(aCodfol[176,1],Round( ( ( ( nBase + nAdic ) / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem1) ) / 2,2))
			Else
				fGeraVerba(aIncRes[19],Round( ( ( ( nBase + nAdic ) / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem1) ) / 2,2))
			Endif		
		Else	
			If !lMulDeterm
				fGeraVerba(aCodfol[176,1],Round( ( (nBase / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem1) ) / 2,2))
			Else
				fGeraVerba(aIncRes[19],Round( ( (nBase / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem1) ) / 2,2))	
			Endif
		EndIf
	EndIf

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fAbatPago 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Se For Complementar e depois da Valoriza Subtrair o Valor ja³
³          ³pago na Rescisao Anterior guardado na Matriz aPdResc		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fAbatPago()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fAbatPago()

	Local cRefFer		:= GetMvRH("MV_REFFER",NIL,"A")
	Local aPdAux		:= {}
	Local nPos			:= 0.00
	Local nX			:= 0.00
	Local nLenaPd		:= 0
	Local nLenoObj		:= 0
	Local nPosPeriodo	:= 0
	Local nPosObjPd		:= 0
	Local nPosObjHoras	:= 0
	Local nPosObjValor	:= 0
	Local nPosObjTipo2	:= 0
	Local nPosPd		:= 0
	Local nPosHoras		:= 0
	Local nPosValor		:= 0
	Local nPosTipo2		:= 0
	Local nPosDelet		:= 0
	Local nValAux		:= 0
	Local nHorasAux		:= 0

	Local cComplSind 	:= ""
	Local cDtIniBus		:= ""
	Local cDtFimBus		:= ""
	Local cPDAviso		:= ( aCodFol[111,1] + "_" + aCodFol[115,1] + "_" + aCodFol[230,1] + "_" + aCodFol[231,1] + "_";
	+ aCodFol[252,1] + "_" + aCodFol[250,1] + "_" + aCodFol[253,1] + "_" + aCodFol[1681,1] + "_" + aCodFol[1682,1] + "_" ;
	+ aCodFol[1683,1] + "_" + aCodFol[1684,1] + "_" + aCodFol[1685,1])
	Local cPDRescis		:= aCodFol[048,1]
	Local dDataDiss		:= CtoD("//")
	Local lDissApos		:= .F.		
	Local lRateio		:= .F. 
	
	If cPaisLoc == "BRA" .and. GetMvRH("MV_RATPROV",,"N") == "S"
		fRateio(  , 2 ,dTos(M->RG_DTGERAR))
		lRateio := Len(aRateio) > 0
	EndIf

	If lRescDis .And. SRG->(ColumnPos("RG_PDRESC")) > 0
		cComplSind := M->RG_PDRESC
		cDtIniBus := Alltrim(STR(Year(SRG->RG_DATADEM)) + STRZERO(Month(SRG->RG_DATADEM),2) + STRZERO(Day(SRG->RG_DATADEM)+1,2))
		cDtFimBus := Alltrim(STR(Year(SRG->RG_DATADEM)+10) + STRZERO(Month(SRG->RG_DATADEM),2) + STRZERO(Day(SRG->RG_DATADEM)+1,2))

		//Verifica se possui reajuste por dissídio e se ele foi dado após a data de demissão.
		lDissApos:= fAumentSal(SRG->RG_FILIAL, SRG->RG_MAT, cDtIniBus,cDtFimBus,@dDataDiss)
	EndIf

	//Tratamento para FASE 4 que utiliza objeto
	If Type("oSrr") == "U"
		nLenaPd := Len( aPdResc )
		aPdAux := aClone(aPdResc)

		For nX := 1 To nLenaPD
		
			//Se a verba de multa do contrato de experiencia foi informada, não efetua subtração dos valores
			If aPdAux[nX,1] == aCodFol[177,1] .and. aPdAux[nX,9] # "D" .and. aPdAux[nX,7] == "I"
				Loop
			EndIf
			
			//Se tratar-se de complementar calculada no mesmo mês da complementar atual, não efetua o abatimento.
			If AnoMes(aPdAux[nX,18]) == AnoMes(M->RG_DTGERAR)
				Loop
			EndIf
			
			IF aPdAux[nX, 9] != "D" .And. ( ;
				( nPos := aScan(aPd, { |x| x[1]+ x[11] == aPdAux[nX, 1] + aPdAux[nX, 11] .And.  Iif(lRateio, x[2] == aPdAux[nX, 2], .T.) .And. x[9] # "D" .And. x[5] > 0 .And. !( x[1] == aCodFol[046,1] ) } ) ) > 0.00 ;
				.Or. ( nPos := aScan(aPd, { |x| x[1] == aPdAux[nX, 1] .And.  iif(lRateio, x[2] == aPdAux[nX,2],.T.) .And. x[9] # "D" .And. x[5] > 0 .And. !( x[1] == aCodFol[046,1] ) .And. x[7] # "G" } ) ) > 0.00 ;
				.Or. ( nPos := aScan(aPd, { |x| x[1]+ x[11] == aPdAux[nX, 1] + aPdAux[nX, 11] .And. x[9] # "D" .And. x[5] > 0 .And. !( x[1] == aCodFol[046,1] ) } ) ) > 0.00;
				.Or. ( nPos := aScan(aPd, { |x| x[1] == aPdAux[nX, 1] .And. x[9] # "D" .And. x[5] > 0 .And. !( x[1] == aCodFol[046,1] ) .And. x[7] # "G" } ) ) > 0.00 )

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Se nao for Verbas de Insalubridade.                        ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF !( aPD[nPos,1] $ ( aCodFol[037,1] + "_" + aCodFol[038,1] + "_" + aCodFol[039,1] ) )
					//-- Trata verbas indenizadas calculadas para um unico periodo. (Legado)
					If ( aPdAux[nX,1]$ aCodFol[086,1]+"."+ aCodFol[248,1]) .and. ( ( cRefFer == "A" .and. Int(aPdAux[nX,4] ) > 12 ) .or. (cRefFer == "D" .and. Int(aPdAux[nX,4] ) > 30))
						//- Se apresenta mais de um periodo de ferias sob um unico lancamento
						//-- Deve apurar a diferencia proporcionalmente
						aPd[nPos,5] -= ( Int( aPd[nPos,4] ) *  aPdAux[nX,5] ) / ( Int( aPdAux[nX,4] ) )
					ElseIf aPd[nPos,1] $ aCodFol[288,1] + "/" + aCodFol[289,1] + "/" + aCodFol[992,1] + "/" + aCodFol[993,1] .and. apd[nPos,11] == "9" .and. AnomEs(aPdAux[nX,18]) <> AnoMes(aPd[nPos,18])
						Loop
					Else	
						nValAux := aPd[nPos,5]
						aPd[nPos,5] := aPd[nPos,5] - aPdAux[nX,5]
						aPdAux[nX,5] -= nValAux
						
						If aPd[nPos, 6] == "H" .And. ( aPd[nPos, 7] == "I" .Or. aScan( aPdv, { |x| x[32] == aPd[nPos,1] } ) > 0)
							nHorasAux := aPd[nPos, 4]
							aPd[nPos, 4] := aPd[nPos, 4] - aPdAux[nX, 4]
							aPdAux[nX, 4] -= nHorasAux
						EndIf
					EndIf

					If aPd[nPos,5] < 0
						aPd[nPos,9] := "D"
					EndIf

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Caso Contrario, verifica se o novo Valor e Menor que o   An³
					³ teriormente Calculado e: Se nao For Valor do Ponto Eletroni³
					³ co, Gerado ou Informado, Deleta de aPd Caso Contrario  zera³
					³ o Valor													 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				ElseIf aPd[nPos,5] < aPdAux[nX,5]
					IF aPd[nPos,7] $ "EGI"
						aPd[nPos,5] := 0.00
					Else
						aPd[nPos,9] := "D"
					EndIf	
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Se nao, apura a Diferenca.                                 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				Else
					//-- Trata verbas indenizadas calculadas para um unico periodo. (Legado)
					If (aPdAux[nX,1]$ aCodFol[086,1]+"."+ aCodFol[248,1]) .and. ( Int(aPdAux[nX,4] ) > 12 )
						//- Se apresenta mais de um periodo de ferias sob um unico lancamento
						//-- Deve apurar a diferencia proporcionalmente
						aPd[nPos,5] -= ( Int( aPd[nPos,4] ) *  aPdAux[nX,5] ) / ( Int( aPdAux[nX,4] ) )
					Else
						nValAux := aPd[nPos,5]
						aPd[nPos,5] := aPd[nPos,5] - aPdAux[nX,5]
						aPdAux[nX,5] -= nValAux
					EndIf	
				EndIf
				If aPd[nPos,5] == 0 .and. aPd[nPos,9] <> "D" .and. aPd[nPos,7] <> "I" //Se valor for zerado, marca a verba como deletada para não interferir no calculo do FGTS.
					aPd[nPos,9] := "D"
				EndIf

				//Se for rescisão complementar por dissídio, com dissídio concedido e data de reajuste após a data de demissão
				//Considera o campo RCE_PDRESC do sindicato para o calculo das diferenças.
				If lRescDis .And. lDissApos .And. !Empty(cComplSind)
					//Se no sindicato o RCE_PDRESC estiver "2" = aviso, considera somente as verbas de aviso e
					//faz a proporção dos dias de aviso do mês da rescisão.
					If cComplSind == "2" 
						nBaseDias := ( (SRG->RG_DTAVISO + NDIASAV) - dDataDiss ) + 1
						//Se a data do reajuste por dissídio for maior que a data final do aviso, nenhuma verba é considerada.
						If	(SRG->RG_DTAVISO + NDIASAV) < dDataDiss
							aPd[nPos,9] := "D"
							aPd[nPos,5] := 0.00
							//Se a data do reajuste por dissídio estiver dentro da data do aviso, considera somente as verbas de aviso.
						Else
							//Se não for uma verba de aviso, não será considerada
							If !( aPD[nPos,1] $ cPDAviso ) 
								aPd[nPos,9] := "D"
								aPd[nPos,5] := 0.00
							Else
								If aPd[nPos,4] == NDIASAV
									aPd[nPos,4] := nBaseDias
								Endif
								//Faz a proporção do valor com os dias de aviso do mês.
								aPd[nPos,5] := (aPd[nPos,5] / NDIASAV * nBaseDias)
							Endif
						Endif
						//Se no sindicato o RCE_PDRESC estiver "3" = verbas rescisórias + aviso, não considera o saldo de salário.
					ElseIf cComplSind == "3"
						//Não considera o saldo de salário
						If ( aPD[nPos,1] $ cPDRescis )
							aPd[nPos,9] := "D"
							aPd[nPos,5] := 0.00
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX

		If lRescDis .And. lDissApos .And. !Empty(cComplSind) .and. cComplSind == "2"
			For nPos := 1 to Len(aPd)
				//Se as verbas existirem no aPdResc já foram tratadas no laço anterior
				If ( aScan(aPdResc, { |x| x[1] == aPd[nPos,1] } ) ) == 0 .and. !(aPd[nPos,1] $ cPDAviso)
					aPd[nPos,9] := "D"
					aPd[nPos,5] := 0.00
				EndIf
			Next nX
		EndIf

		nPos := aScan(aPdAux,{ |x| x[1] == aCodFol[177,1] .and. x[9] # "D" }) 

		If nPos > 0
			nVlMultaPg := aPdAux[nPos,5]
			If aPdAux[nPos,7] == "I" //Se a multa foi informada zera o valor no Apd
				aPdAux[nPos,5] := 0
				If (nPos := aScan(aPd,{ |x| x[1] == aCodFol[177,1] .and. x[9] # "D" })) > 0
					aPd[nPos,5] := 0
				EndIf				
			EndIf
		EndIf	
	Else
		nPosPeriodo		:= GdFieldPos( "RR_PERIODO", oSrr:aHeader )
		nPosObjPd		:= GdFieldPos( "RR_PD", oSrr:aHeader )
		nPosObjHoras	:= GdFieldPos( "RR_HORAS", oSrr:aHeader )
		nPosObjValor	:= GdFieldPos( "RR_VALOR", oSrr:aHeader )
		nPosObjTipo2	:= GdFieldPos( "RR_TIPO2", oSrr:aHeader )
		nPosPd			:= GdFieldPos( "RR_PD", aSrrHeader )
		nPosHoras		:= GdFieldPos( "RR_HORAS", aSrrHeader )
		nPosValor		:= GdFieldPos( "RR_VALOR", aSrrHeader )
		nPosTipo2		:= GdFieldPos( "RR_TIPO2", aSrrHeader )
		nPosDelet		:= Len( aSrrHeader )+1
		nLenoObj		:= Len( oSrr:aCols )

		For nX := 1 To nLenoObj           

			If ( nPos := aScan( aColsResc, { |x| x[ nPosPd ] == oSrr:aCols[ nX, nPosObjPd ] .and. !x[nPosDelet] }) ) > 0.00

				/*                          
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Se nao for Verbas de Insalubridade.                        ³   
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If !( oSrr:aCols[nX, nPosObjPd] $ ( fGetCodFol( "0037", .F. ) + "_" + fGetCodFol( "0038", .F. ) + "_" + fGetCodFol( "0039", .F. )) ) .Or.;
				( cPaisLoc $ "COL|BOL|PER|EQU" .And. !(oSrr:aCols[nX, nPosObjPd] $ ( fGetCodFol( "0037", .F. ) + "_" + fGetCodFol( "0038", .F. ) + "_" + fGetCodFol( "0039", .F. ) + "_" + fGetCodFol( "0126", .F. ))) )

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Resc. Anterior³ Resc. Atual ³ Esperado  ³
					³    Calculada  ³	Calculada   ³ subtracao ³
					³    Informada  ³	Calculada   ³ Zera      ³
					³    Informada  ³	Informada	³ Ignora    ³
					³    Calculada  ³	Informada   ³ Ignora    ³                              
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					If aColsResc[nPos, nPosTipo2] == "I" .and. oSrr:aCols[nX, nPosObjTipo2] # "I" 
						oSrr:aCols[nX, nPosObjHoras] := 0.00
						oSrr:aCols[nX, nPosObjValor] := 0.00  
					Else
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Se ambas as verbas forem calculadas, ou ambas informadas e que sejam  ³
						³ do mesmo periodo, realiza a subtracao.                                ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						If  ( oSrr:aCols[nX, nPosObjTipo2] # "I" .And. aColsResc[nPos, nPosTipo2] # "I") .Or. ;
						( oSrr:aCols[nX, nPosObjTipo2] = "I" .And. aColsResc[nPos, nPosTipo2] == "I" .And. oSrr:aCols[nX, nPosPeriodo]  == aColsResc[nPos, 10] )
							oSrr:aCols[nX, nPosObjHoras] := Round(oSrr:aCols[nX, nPosObjHoras],X3DECIMAL("RR_HORAS")) - Round(aColsResc[nPos, nPosHoras],X3DECIMAL("RR_HORAS"))
							oSrr:aCols[nX, nPosObjHoras] := IIF(oSrr:aCols[nX, nPosObjHoras] < 0, 0, oSrr:aCols[nX, nPosObjHoras])
							oSrr:aCols[nX, nPosObjValor] := Round(oSrr:aCols[nX, nPosObjValor],X3DECIMAL("RR_VALOR")) - Round(aColsResc[nPos, nPosValor],X3DECIMAL("RR_VALOR"))
							oSrr:aCols[nX, nPosObjValor] := IIF(oSrr:aCols[nX, nPosObjValor] < 0, 0, oSrr:aCols[nX, nPosObjValor])
						Endif  
					Endif	

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Caso Contrario, verifica se o novo Valor e Menor que o   An³                          
					³ teriormente Calculado e: Se nao For Valor do Ponto Eletroni³
					³ co, Gerado ou Informado, Deleta de aPd Caso Contrario  zera³
					³ o Valor													 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				ElseIf oSrr:aCols[nX, nPosObjValor] < aColsResc[nPos, nPosValor]
					If oSrr:aCols[nX, nPosObjTipo2] $ "EG"
						oSrr:aCols[nX, nPosObjValor] := 0.00
					Else
						oSrr:aCols[nX, nPosDelet] := .T. 
					EndIf

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Se nao, apura a Diferenca.                                 ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				Else
					oSrr:aCols[nX, nPosObjHoras] := Round(oSrr:aCols[nX, nPosObjHoras],X3DECIMAL("RR_HORAS")) - Round(aColsResc[nPos, nPosHoras],X3DECIMAL("RR_HORAS"))
					oSrr:aCols[nX, nPosObjHoras] := IIF(oSrr:aCols[nX, nPosObjHoras] < 0, 0, oSrr:aCols[nX, nPosObjHoras])
					oSrr:aCols[nX, nPosObjValor] := Round(oSrr:aCols[nX, nPosObjValor],X3DECIMAL("RR_VALOR")) - Round(aColsResc[nPos, nPosValor],X3DECIMAL("RR_VALOR"))
					oSrr:aCols[nX, nPosObjValor] := IIF(oSrr:aCols[nX, nPosObjValor] < 0, 0, oSrr:aCols[nX, nPosObjValor])
				EndIf
			EndIf
		Next nX	
	EndIf

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fFgtsRes 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Apurar os Valores de FGTS a serem pagos na Rescisao			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fFgtsRes()													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fFgtsRes()

	Local cPdAvi 	:= ""
	Local nFgtsRec 	:= 0
	Local nPercRec 	:= 0
	Local nPerFgts
	Local nPos	   	:= 0
	Local nFgtsRec1	:= 0
	Local nBsFGTSDis:= 0
	Local nRegAnt	:= 0
	Local nPos247	:= 0
	Local nFgts_bAV := 0
	Local lTemId1676:= Len(aCodFol) >= 1678 .And. !Empty(aCodFol[1676, 1])
	Local lTemId1849:= Len(aCodFol) >= 1848 .And. !Empty(aCodFol[1849, 1])
	Local lTemId1883:= Len(aCodFol) >= 1883 .And. !Empty(aCodFol[1883, 1])
	Local lTemId1887:= Len(aCodFol) >= 1887 .And. !Empty(aCodFol[1887, 1])

	lRescDis	:= If( Type("lRescDis")=="U",.F.,lRescDis)//Rescisao Complementar por Dissidio

	//--Verifica Qual Percentual de FGTS deve Aplicar
	IF Type("SRA->RA_PERFGTS") # "U" .and. SRA->RA_PERFGTS > 0.00
		nPerFgts := SRA->RA_PERFGTS / 100
	Else
		nPerFgts := IF (SRA->RA_TPCONTR$ " *1",nFgtsCt1,nFgtsCt2)
	EndIf

	If lRescDis .and. !lProxMes
		nRegAnt	:= SRG->(Recno())
		SRG->(DbGoTo(nRegSrg))
		SRR->(DbSetOrder(1)) //RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
	EndIf		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  CALCULO DO FGTS                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFgts_b := nFgts13_b := nFgts13_Mil := nFgts13_Aci := 0.00

	If aIncRes[6] = "S" 

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Tratamento da incidencia Verba 247 - Desc. Liquido 13o. 2a. Parc. Rescisao    ³ 
		³ Recolhimento do FGTS 13.Salario para "DISPENSA PELO EMPREGADOR" sera realizado³
		³ GRFC, por e por isso a verba 247 NAO devera possuir incidencia para FGTS      ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
		nPos	:= aScan(apdv,{|X| X[1] == aCodFol[247,1]})
		nPos247 := aScan(apd,{|X| X[1] == aCodFol[247,1]})

		If nPos > 0
			//Se a segunda parcela do 13º tiver sido paga no periodo ANTERIOR a rescisão, 
			//o recolhimento do FGTS já foi feito na folha de pagamento do período anterior, 
			//portanto não deve considerar a base cheia e a incidencia de FGTS permance com "S"
			If nPos247 == 0 .or. AnoMes(aPd[npos247,18]) == cPeriodo 
				aPdv[nPos,6]	:= "N"
			EndIf 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CALCULO DO FGTS SALARIO                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF aScan(aPd,{ |X| X[1] = aCodfol[119,1] .and. X[9] # "D" } ) = 0
			fCFgts(aCodfol,@nfgts_b,,,'R')	// FGTS DO MES

			//--Tratamento Fgts salario negativo
			If nFgts_b < 0	  
				nFgts_b 	:= nFgts_b * (-1)
				nFgtsRec1 	:= NoRound(nFgts_b * nPerFgts,2)
				If !Empty(aCodfol[823,1]) // se tiver identificador de fgts a recuperar salario
					//--Carrega o Percentual da Verba para aplicar no valor a recuperar
					nPercRec := RetValSRV(aCodFol[823,1],SRA->RA_FILIAL,"RV_PERC")/100
					nFgtsRec1:= nFgtsRec1 * nPercRec
					fMatriz(aCodfol[823,1], nFgtsRec1  , , , , ,"R" )
				EndIf	
				nFgts_b := 0.00
			EndIf

			//Obtem a base de FGTS sobre aviso prévio
			If nFgts_b > 0 .and. lTemId1887
				cPdAvi 	:= aCodFol[0111,1]+"/"+aCodFol[0250,1]+"/"+aCodFol[1683,1]+"/"+aCodFol[1689,1]+"/"+aCodFol[1695,1]+"/"+aCodFol[1701,1]+"/"+aCodFol[1707,1]+"/"+aCodFol[1713,1]+"/"+aCodFol[1719,1]
				Aeval( aPd ,{ |x| Iif( x[1] $ cPdAvi, SomaInc(X, 6, @nFgts_bAV, 12, "N", Nil, Nil, Nil, .T., aCodFol), Nil ) }) 
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CALCULO DO FGTS 13o .                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fCFgts13(aCodfol, @nfgts13_b, Nil, Nil, 'R', Nil, @nfgts13_Mil, @nfgts13_Aci)

			//--Tratamento Fgts 13o negativo por deposito antecipado em ferias
			IF nFgts13_b < 0
				nFgts13_b 	:= nFgts13_b * (-1)
				nFgtsRec	:= 	NoRound(nfgts13_b * nPerFgts,2)
				IF aCodfol[292,1] # Space(3)
					//--Carrega o Percentual da Verba para aplicar no valor a recuperar
					nPercRec := RetValSRV(aCodFol[292,1],SRA->RA_FILIAL,"RV_PERC")/100
					nFgtsRec := nFgtsRec * nPercRec
					fMatriz(aCodfol[292,1], nFgtsRec   , , , , ,"R" )
				EndIf	
				nFgts13_b 	:=	0.00
			EndIf	     	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava no codigo de Pagto. de Rescisao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//--Tratamento Fgts Salario negativo 
			If nFgts_b > 0	  
				If lRescDis  
					If lProxMes
						fMatriz(aCodfol[339,1], NoRound(nfgts_b * nPerFgts,2) , , , , ,"R" )		
						//--Base Fgts
						fMatriz(aCodfol[337,1], nfgts_b   , , , , ,"R" )
					Else
						If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[293,1] )) //Base FGTS
							fMatriz(aCodfol[337,1], Max(nfgts_b-SRR->RR_VALOR,0) , , , , ,"R" )		

							fMatriz(aCodfol[293,1], SRR->RR_VALOR , , , , ,"R" ) //--Base Fgts
							nBsFGTSDis := Max(nfgts_b-SRR->RR_VALOR,0)

							If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[119,1] )) //--FGTS rescisao
								fMatriz(aCodfol[119,1],SRR->RR_VALOR , , , , ,"R" )		
							EndIf    		
							fMatriz(aCodfol[339,1], NoRound(nBsFGTSDis * nPerFgts,2) , , , , ,"R" )//--FGTS Dissidio		
						EndIf
					EndIf	
				Else
					If nFgts_bAV > 0 .and. cCompl == "S" //Se for complementar verifica se na rescisão anterior foi gerada a verba 1887
						If aScan(aPdResc,{ |x| x[1] == aCodFol[1887,1] .and. x[9] # "D" }) == 0
							nFgts_bAV := 0 //Se não foi calculado na principal, zera para que seja gerado tudo na verba 0293
						EndIf
					EndIf
					
					//--Base Fgts sobre Aviso
					If nFgts_bAV > 0
						fMatriz(aCodfol[1887,1], nFgts_bAV   , , , , ,"R" )
					EndIf

					nfgts_b := Max(nfgts_b - nFgts_bAV, 0)

					fMatriz(aCodfol[119,1], NoRound((nfgts_b + nFgts_bAV) * nPerFgts,2) , , , , ,"R" )		
					fMatriz(aCodfol[293,1], nfgts_b, , , , ,"R" )
				EndIf	
			EndIf

			IF nFgts13_b > 0
				If lRescDis 
					If lProxMes
						//--Fgts 13o
						fMatriz(aCodfol[400,1], NoRound( (nfgts13_b+nfgts13_Mil) * nPerFgts,2) , , , , ,"R" )		
						//Base fgts 13o
						fMatriz(aCodfol[398,1], (nfgts13_b+nfgts13_Mil) , , , , ,"R" )
					Else 
						If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[294,1] ))
							fMatriz(aCodfol[398,1], Max((nfgts13_b+nfgts13_Mil)-SRR->RR_VALOR,0 ) , , , , ,"R" )//--Base Fgts 13o Dissidio

							fMatriz(aCodfol[294,1], SRR->RR_VALOR , , , , ,"R" ) //--Base Fgts 13o Dissidio

							nBsFGTSDis := Max((nfgts13_b+nfgts13_Mil)-SRR->RR_VALOR,0)

							If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[214,1] )) //FGTS 13o
								fMatriz(aCodfol[214,1],  SRR->RR_VALOR , , , , ,"R" )		
							EndIf	
							fMatriz(aCodfol[400,1], NoRound( nBsFGTSDis * nPerFgts,2) , , , , ,"R" )//--Fgts 13o Dissidio				
						EndIf
					EndIf	
				Else
					If cTipoRot == "4" .And. lTemId1676 .And. aScan(aPd, { |x| x[1] == aCodFol[247, 1] .And. x[9] != "D" } ) > 0  .And. nFgtsP > NoRound( (nfgts13_b+nfgts13_Mil) * nPerFgts,2)
						FMatriz(aCodfol[1676,1], nFgtsP - NoRound( (nfgts13_b+nfgts13_Mil) * nPerFgts,2))
						FMatriz(aCodfol[1677,1], nFgts_BP - nFgts13_B)
					Else
						//--Fgts 13o
						fMatriz(aCodfol[214,1], NoRound( (nfgts13_b+nfgts13_Mil) * nPerFgts,2) , , , , ,"R" )		
						//Base fgts 13o
						fMatriz(aCodfol[294,1], nfgts13_b , , , , ,"R" )
					EndIf
					
					If lTemId1849 .and. nfgts13_Mil > 0
						fMatriz(aCodfol[1849,1], nfgts13_Mil , , , , ,"R" )
					EndIf
					If lTemId1883 .and. nfgts13_Aci > 0
						fMatriz(aCodfol[1883,1], nfgts13_Aci , , , , ,"R" )
					EndIf
				EndIf	
			EndIf			

		EndIf
	Else
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Tratamento da incidencia Verba 247 - Desc. Liquido 13o. 2a. Parc. Rescisao    ³ 
		³ Recolhimento do FGTS 13.Salario para "PEDIDO DE DEMISSAO"sera realizado na    ³
		³ SEFIP, por e por isso a verba 247 devera possuir incidencia para FGTS         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
		nPos	:= aScan(apdv,{|X| X[1] == aCodFol[247,1]})
		If nPos > 0 
			apdv[nPos,6]	:= "S" 
		EndIf

		//#######################################################################################
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CALCULO DO FGTS SALARIO                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no Codigo de Deposito Mensal                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
		If lRescDis  
			fCFgts(aCodfol,@nfgts_b,,nAfasFgts,"R")
			fCFgts13(aCodfol,@nfgts13_b,,,"R")
		Else
			fCFgts(aCodfol,@nfgts_b,"S",nAfasFgts,"R")
			fCFgts13(aCodfol,@nfgts13_b,"S",,"R")
		EndIf

		//--Tratamento Fgts 13o negativo por deposito antecipado em ferias
		IF nFgts13_b < 0
			nFgts13_b 	:= nFgts13_b * (-1)
			nFgtsRec	:= 	NoRound(nfgts13_b * nPerFgts,2)
			IF aCodfol[292,1] # Space(3)
				//--Carrega o Percentual da Verba para aplicar no valor a recuperar
				nPercRec := RetValSRV(aCodFol[292,1],SRA->RA_FILIAL,"RV_PERC")/100
				nFgtsRec := nFgtsRec * nPercRec
				fMatriz(aCodfol[292,1], nFgtsRec   , , , , ,"R" )
			EndIf	
			nFgts13_b 	:=	0.00
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no codigo de Pagto. de Rescisao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF nFgts_b > 0	  
			If lRescDis  
				If lProxMes
					fMatriz(aCodfol[339,1], NoRound(nfgts_b * nPerFgts,2) , , , , ,"R" )		
					//--Base Fgts
					fMatriz(aCodfol[337,1], nfgts_b   , , , , ,"R" )
				Else
					If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[17,1] )) //BASE FGTS DISSIDIO
						fMatriz(aCodfol[337,1], Max(nfgts_b-SRR->RR_VALOR,0) , , , , ,"R" )		
						fMatriz(aCodfol[017,1], SRR->RR_VALOR , , , , ,"R" ) //--Base Fgts
						nBsFGTSDis := Max(nfgts_b-SRR->RR_VALOR,0)
						fMatriz(aCodfol[339,1], NoRound(nBsFGTSDis * nPerFgts,2) , , , , ,"R" )//--FGTS Dissidio		
					EndIf
				EndIf	
			EndIf	
		EndIf

		IF nFgts13_b > 0
			If lRescDis 
				If lProxMes
					//--Fgts 13o
					fMatriz(aCodfol[400,1], NoRound(nfgts13_b * nPerFgts,2) , , , , ,"R" )		
					//Base fgts 13o
					fMatriz(aCodfol[398,1], nfgts13_b , , , , ,"R" )
				Else 
					If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[108,1] ))
						fMatriz(aCodfol[398,1], Max(nfgts13_b-SRR->RR_VALOR,0 ) , , , , ,"R" )//--Base Fgts 13o Dissidio
						fMatriz(aCodfol[108,1], SRR->RR_VALOR , , , , ,"R" ) //--Base Fgts 13o Dissidio
						nBsFGTSDis := Max(nfgts13_b-SRR->RR_VALOR,0)
						fMatriz(aCodfol[400,1], NoRound( nBsFGTSDis * nPerFgts,2) , , , , ,"R" )//--Fgts 13o Dissidio				
					EndIf
				EndIf	
			EndIf	
		EndIf			

	EndIf

	If !Empty(nRegAnt)
		SRG->(DbGoTo(nRegAnt))
	EndIf

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fFgtsMulta 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Apurar os Valores de Multa FGTS a serem pagos na Rescisao	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fFgtsMulta( nContrMul )										³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fFgtsMulta( nContrMul, nCtrMulDis )

	Local NvMul40 	:= 0
	Local nPerFgts
	Local nFgtSemAnt:= 0
	Local nFgtsDiss := 0
	Local nVMulDiss := 0
	Local nRegAnt	:= 0
	Static cFilCtr
	Static nPCtr
	Static nPCtrDis
	
	//--Verifica Qual Percentual de FGTS deve Aplicar
	IF Type("SRA->RA_PERFGTS") # "U" .and. SRA->RA_PERFGTS > 0.00
		nPerFgts := SRA->RA_PERFGTS / 100
	Else
		nPerFgts := IF (SRA->RA_TPCONTR$ " *1",nFgtsCt1,nFgtsCt2)
	EndIf
	
	If lRescDis .and. !lProxMes
		nRegAnt	:= SRG->(Recno())
		SRG->(DbGoTo(nRegSrg))
		SRR->(DbSetOrder(1)) //RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo da Multa 40 %                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF aIncRes[7] = "S"
		nValDep := 0.00
		nPos := aScan(aPd,{ |X| X[1] = aCodfol[118,1] .and. X[9] # "D" } )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Multa qdo for complementar                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF nPos > 0
			nValDep := aPd[nPos,5]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FGTS Mes Anterior                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := aScan(aPd,{ |X| X[1] = aCodfol[117,1] .and. X[9] # "D" } )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Vlr multa qdo for complementar                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF nPos > 0
			nValDep += aPd[nPos,5]
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FGTS Semanas Anteriores                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S"
			nPos := aScan(aPd,{ |X| X[1] = aCodfol[649,1] .and. X[9] # "D" } )
			IF nPos > 0
				nFgtSemAnt += aPd[nPos,5]
			EndIf
		EndIf
		
		aEval(aPd, {|aPd| If( aPd[1] == aCodfol[337,1] .and. aPd[9] # "D", nFgts_b += aPd[5], ) } )
		aEval(aPd, {|aPd| If( aPd[1] == aCodfol[398,1] .and. aPd[9] # "D", nFgts13_b += aPd[5], ) } )
		//Em caso de total do Saldo for par, soma 1 centavo para igualar ao sistema Concectividade da Caixa. 
		//Necessário pois o sistema da Caixa realiza o cálculo direto, multiplicando por 50%, enquanto gravamos 40% + 10%.
		
		nVMul40 := (nValDep + (NoRound((nFgts13_b * nPerFgts),2) + NoRound((nFgts_b * nPerFgts),2) + NoRound((nFgtSemAnt * nPerFgts),2)))
		
		If nVMul40 != 0 .And. Mod(nVMul40*100,2) == 0
			nVMul40 := NoRound(nVMul40 * nPercFgts, 2) + 0.01
		Else
			nVMul40 := NoRound(nVMul40 * nPercFgts, 2)
		EndIf
		
		nVMul40 -= fAbatVA() //contrato verde amarelo
		
		If !lRescDis  	
			fMatriz(aCodfol[120,1],nVMul40, , , , ,"R")
		ElseIf lRescDis .and. !lProxMes
			If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[120,1] ))
				fMatriz(aCodfol[120,1],SRR->RR_VALOR, , , , ,"R")
			EndIf
		EndIf	
		
		If lRescDis
			aEval(aPd, {|aPd| If( aPd[1] == aCodfol[337,1] .and. aPd[9] # "D", nFgtsDiss += aPd[5], ) } )
			aEval(aPd, {|aPd| If( aPd[1] == aCodfol[398,1] .and. aPd[9] # "D", nFgtsDiss += aPd[5], ) } )
			
			nVMulDiss := NoRound( ( NoRound( nFgtsDiss * nPerFgts, 2 ) ) * nPercFgts, 2 )
			fMatriz(aCodfol[712,1],nVMulDiss, , , , ,"R")
		EndIf
		
		IF !(aIncRes[2] $ "A*B") .And. (aCodFol[297,1] # Space(3) .Or. aCodFol[727,1] # Space(3))
			//--Carregar o % da contribuicao sobre Fgts
			IF cFilCtr = Nil .or. cFilCtr # SRA->RA_FILIAL
				cFilCtr := SRA->RA_FILIAL
				If aCodFol[297,1] # Space(3)	
					nPCtr	:= RetValSRV(aCodFol[297,1],SRA->RA_FILIAL,"RV_PERC") /100
					If nPCtr == 0 .And. cCompl == "S" .And. aScan(aPdResc,{ |x| x[1] == aCodFol[297,1] .and. x[9] # "D" }) > 0
						nPCtr := 0.1
					EndIf
				EndIf
				IF aCodFol[727,1] # Space(3)
					nPCtrDis	:= RetValSRV(aCodFol[727,1],SRA->RA_FILIAL,"RV_PERC") /100
					If nPCtrDis == 0 .And. cCompl == "S" .And. aScan(aPdResc,{ |x| x[1] == aCodFol[727,1] .and. x[9] # "D" }) > 0
						nPCtrDis := 0.1
					EndIf
				EndIf
			EndIf	
			IF ValType( nPCtr ) == "N" .And. nPCtr > 0	
				If !lRescDis	
					nContrMul := NoRound((nValDep + (NoRound((nFgts13_b * nPerFgts),2) + NoRound((nFgts_b * nPerFgts),2) + NoRound((nFgtSemAnt * nPerFgts),2))) * nPCtr, 2)
				ElseIf lRescDis .and. !lProxMes
					If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[297,1] ))
						fMatriz(aCodfol[297,1],SRR->RR_VALOR, , , , ,"R")
					EndIf
				EndIf	
			EndIf	
			IF lRescDis .And. ValType( nPCtrDis ) == "N" .And. nPCtrDis > 0	
				nCtrMulDis := NoRound( ( NoRound(nFgtsDiss * nPerFgts, 2 ) ) * nPCtrDis, 2 )
			EndIf
		EndIf	
	EndIf
	
	If !Empty(nRegAnt)
		SRG->(DbGoTo(nRegAnt))
	EndIf
	
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³fDesMultConEx ³ Autor ³ Allyson M 	    ³ Data ³ 22.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera a verba de multa de contrato de experiencia       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function fDesMultConEx( nTpMulta )

	Local aAfast    := {}
	Local cCodAfa   := ""
	Local cFilTare	:= ""
	Local dVctoExp  := CtoD("")
	Local dDtCong   := CtoD("")
	Local dDtRet    := CtoD("")
	Local nBase	   := 0
	Local nComis   := 0
	Local nGComis  := 0
	Local nMedCom  := 0
	Local nMeses   := 0
	Local nAdic	   := 0
	Local nDiasAf 	:= 0
	Local nDiasAux 	:= 0 
	Local nPosAfas	:= 0
	Local nPosUltAf	:= 0
	Local nQtDiasOP	:= 0
	Local nNewSalBs	:= 0
	Local nDiasMlt	:= 0
	Local lGrMulta	:= .F.
	Local lTrDiasCMl := Type("P_RESMULTH") # "U"

	Default nTpMulta := 1

	dVctoExp := If( nTpMulta == 1, SRA->RA_VCTOEXP, SRA->RA_VCTEXP2 )

	// Busca afastamentos do funcionário que possam ter ocorrido
	// durante o período de expiração de contrato
	fRetAfas(SRA->RA_VCTOEXP,SRA->RA_VCTEXP2,"",,@nDiasAf,,@aAfast,,.F.,,,,,) 
	If Len( aAfast ) > 0 

		For	nPosAfas := 1 To Len( aAfast )
			If aAfast[nPosAfas,16] $ "O1*P1"
				nQtDiasOP += aAfast[ nPosAfas, 2 ] // Qtde. de dias de afastamento no periodo
			EndIf
		Next nPosAfas


		If nQtDiasOP > 15
			// Busca Data de Congelamento de Contrato,  data após pagamento dos Dias Empresa
			dDtRet := dVctoExp
			nPosUltAf := aScan( aAfast, { | x | ( x[ 3 ] <= dVctoExp .And. dVctoExp <= x[ 4 ] ) } )
			If nPosUltAf > 0
				cCodAfa	:= aAfast[ nPosUltAf, 7 ]
				If ( nPosConAf := aScan( aAfast, { |x| x[8] == cCodAfa } ) ) > 0
					dDtCong	:= aAfast[ nPosConAf, 3 ] + aAfast[nPosConAf, 15]
					dDtRet	:= aAfast[ nPosConAf, 4 ]
				Else
					dDtCong  := aAfast[ nPosUltAf, 3 ] + aAfast[nPosUltAf, 15]
					dDtRet	:= aAfast[ nPosUltAf, 4 ]
				EndIf  
			EndIf

			// Busca quantidade de dias entre Data de Congelamento e Data de Expiração 2
			nDiasAux := If( SRA->RA_VCTEXP2 >= dDtCong .And. dDtCong <= SRA->RA_VCTOEXP, 0 , SRA->RA_VCTEXP2 - dDtCong + 1 )  
			
			// Nova Data de Vencimento de Contrato será Data do retorno do afastamento somado
			// a quantidade de dias que funcionário ainda tem direito a cumprir
			dVctoExp :=  dDtRet + nDiasAux 
			lGrMulta := .T.
		Else
			lGrMulta :=  If (nTpMulta == 1, SRA->RA_VCTOEXP > dDataDem, SRA->RA_VCTOEXP < dDataDem .And. SRA->RA_VCTEXP2 > dDataDem)
		EndIf
	Else
	 	lGrMulta :=  If (nTpMulta == 1, SRA->RA_VCTOEXP > dDataDem, SRA->RA_VCTOEXP < dDataDem .And. SRA->RA_VCTEXP2 > dDataDem)
	EndIf

	If lGrMulta
		If SRA->RA_CATFUNC == "C" .And. SRA->RA_SALARIO == 0
			//Garantia de comissao do sindicato do funcionario
			nGComis := fDesc("RCE", SRA->RA_SINDICA, "RCE_GCOMISS", Nil, SRA->RA_FILIAL)
			//Numero de meses para media
			nMeses 	:= DateDiffMonth( SRA->RA_ADMISSA , dDataDem ) + 1
			//Busca o valor das verbas de comissao e garantia de comissao no acumulado desde a admissao ate a data de demissao
			nComis 	:= fBuscaAcm(aCodfol[121,1]+"/"+aCodfol[122,1]+"/"+aCodfol[165,1]+"/"+aCodfol[166,1]+"/"+aCodfol[347,1],,SRA->RA_ADMISSA,dDataDem,"V")
			//Se considerar o mes atual para as medias, busca o valor das verbas geradas no calculo da rescisao
			If lMesAtu
				aEval( aPd ,{ |aPd| IF(aPd[1] $ aCodfol[121,1]+"/"+aCodfol[122,1]+"/"+aCodfol[165,1]+"/"+aCodfol[166,1]+"/"+aCodfol[347,1] .And. aPd[3] = cSemana .And. aPd[9] # "D", nComis += aPd[5], Nil) } )	
			EndIf
			//Divide o total da comissao pelo numero de meses trabalhados
			nMedCom := nComis / nMeses
			//Caso a media seja menor do que a garantia de comissao utiliza a garantia de comissao
			nBase := If( nMedCom < nGComis , nGComis, nMedCom)
		ElseIf SRA->RA_CATFUNC == "T" .And. SRA->RA_SALARIO == 0
			//Numero de meses para media
			nMeses 	:= DateDiffMonth( SRA->RA_ADMISSA , dDataDem ) + 1

			cFilTare := "!Empty(SRV->RV_TAREFA) .And. AllTrim(SRV->RV_TAREFA)#'N'"

			nBase 	:= fBuscaAcm(,cFilTare,SRA->RA_ADMISSA,dDataDem,"V")

			//Se considerar o mes atual para as medias, busca o valor das verbas geradas no calculo da rescisao
			If lMesAtu
				aEval( aPd ,{ |x| IF(!Empty(RetValSRV(x[1],SRA->RA_FILIAL,"RV_TAREFA")) .And. x[3] = cSemana .And. x[9] # "D", nBase += x[5], Nil) } )	
			EndIf

			nBase := nBase / nMeses
		Else
			If RetValSRV(aCodfol[177,1],SRA->RA_FILIAL,"RV_BASCAL") <> "2"
				nBase := Salario
				If SRA->RA_CATFUNC == "H"
					If lTrDiasCMl // Troca Salario Base e Dias de Calculo para Multa
						nDiasMlt := If( ((aPeriodo[nPosSem,18] == 31 .Or. aPeriodo[nPosSem,16] == "02") .And. P_RESMULTH = 1), aPeriodo[nPosSem,18],If(P_RESMULTH == 2, 30, aPeriodo[nPosSem,20]))    
						If P_RESMULTH == 1
							nBase := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * aPeriodo[nPosSem,18]),2)
						Else
							nBase := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * 30),2)
						EndIf
					EndIf			
				EndIf
			Else 	
				nBase := SalMes			
				If SRA->RA_CATFUNC == "H"
					If lTrDiasCMl // Troca Salario Base e Dias de Calculo para Multa
						nDiasMlt := If( ((aPeriodo[nPosSem,18] == 31 .Or. aPeriodo[nPosSem,16] == "02") .And. P_RESMULTH = 1), aPeriodo[nPosSem,18],If(P_RESMULTH == 2, 30, aPeriodo[nPosSem,20]))    
						If P_RESMULTH == 1
							// Subtrai salário mês calculado de acordo com P_DIASRES e soma novo salário base de acordo 
							// com novo mnemônico
							nNewSalBs := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * aPeriodo[nPosSem,18]),2)
							nBase	  := SalMes - (SRA->RA_SALARIO * nHrsCal)  
							nBase	  += nNewSalBs
						Else
							nNewSalBs := SRA->RA_SALARIO * Round((SRA->RA_HRSDIA * 30),2)
							nBase	  := SalMes - SRA->RA_SALARIO * nHrsCal  
							nBase	  += nNewSalBs
						EndIf
					EndIf			
				EndIf
			EndIf
		EndIf

	
		If P_ADIMULEX         
			nAdic := NPERIC + NINSALUB + VAL_ANU + VAL_BIE + VAL_TRI + VAL_QUA + VAL_QUI + NADCCONF + NADCTRF + NADTSERV
			nMulta := Round( ( ( ( nBase + nAdic ) / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem) ) / 2, 2)
		Else	
			nMulta := Round( ( (nBase / If(SRA->RA_CATFUNC == "H" .And. lTrDiasCMl, nDiasMlt, nDiasC)) * (dVctoExp - dDatadem) ) / 2, 2)
		EndIf
	EndIf

Return(nMulta)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fIntegraRes³ Autor ³ Marcelo Silveira	    ³ Data ³ 29/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Integracao do calculo de rescisao				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fIntegraRes(cFilFun, cMatFun, cProcesso, cRotDe, cRotPara, cPerDe, cPerPara, cNPagDe, cNPagPara, lIntIc)
	Local aArea		:= GetArea()
	Local aAreaSRR  := SRR->( GetArea() )
	Local cEfetiva	:= ""
	Local cChaveAux := ""
	Local cSeqAux   := " "
	Local dDataAux	:= CtoD("")
	Local dDataPag	:= CtoD("")
	Local dDataGer	:= CtoD("")
	Local nCompAnt  := 0
	Local nRecSRR	:= 0
	Local lVerData  := .T.
	Local lRet		:= .T.
	Local aRecRGB	:= {}
	Local nOrdemSRR := RetOrder("SRR","RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_SEQ+DTOS(RR_DATA)")
	Local nValAnt   := 0
	Local nCont		:= 0
	Local lSliq		:= .F.
	
	DEFAULT lIntIc	:= .F.

	RGB->( DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_MAT+RGB_PD+RGB_SEQ")) )

	DbSelectArea("SRG")
	DbSetOrder(1) //RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)

	DbSelectArea("SRR")
	DbSetOrder(nOrdemSRR)

	If SRG->(DbSeek(cFilFun+cMatFun))
		While SRG->(!Eof() .and. RG_FILIAL + RG_MAT == cFilFun + cMatFun)
			cEfetiva	:= ""
			If SRG->RG_PROCES == cProcesso .and. SRG->RG_PERIODO == cPerDe
				cEfetiva := SRG->RG_EFETIVA
				dDataAux := SRG->RG_DTGERAR
				If cPaisLoc == "BRA" .And. SRG->RG_EFETIVA == "S" .And. lConsig .And. lCpoFlagIC .And. lIntIc .And. SRG->RG_CONFIC == "4"
					IF SRG->( Reclock("SRG", .F.) )
						SRG->RG_CONFIC := "2"
						SRG->( Msunlock() )
					EndIf
				EndIf
				If cPaisLoc == "BRA" .And. cEfetiva == "S" .And. ( SRG->RG_RESCDIS == "0" .or. AnoMes(SRG->RG_DTGERAR) == AnoMes(SRG->RG_DATADEM) ).And. fTemCompl( cFilFun+cMatFun, AnoMes(SRG->RG_DTGERAR), SRG->( Recno() ), (cFilFun+cMatFun+cPerDe+cRotDe+cNPagDe), nOrdemSRR )
					SRG->( dbSkip() )
					Loop
				EndIf
			EndIf

			If cEfetiva == "S" .and. SRR->(DbSeek(cFilFun+cMatFun+cPerDe+cRotDe+cNPagDe))
				//Verifica se existe outros roteiros integrados
				If RGB->(DbSeek(cFilFun + cProcesso + cPerPara + cNPagPara + cRotPara + cMatFun))
					fAtuRGB(cFilFun,cMatFun,cProcesso,cPerPara,cNPagPara)
				EndIf

				lVerData := .T.

				While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA == cFilFun+cMatFun+cPerDe+cRotDe+cNPagDe)
					If SRR->RR_DATA == dDataAux

						If lVerData .and. !Empty(dDataPag) .and. dDataPag == SRR->RR_DATAPAG
							cSeqAux 	:= Soma1(cSeqAux)
							dDataGer 	:= SRR->RR_DATA
						Else
							If dDataGer <> SRR->RR_DATA
								cSeqAux  := " "
								dDataPag := SRR->RR_DATAPAG
							EndIf
						EndIf

						lVerData := .F.

						nCompAnt := 0

						//Se a verba for sem ID, informada e existe valor pago anteriormente, verifica se houve pagamento de outra complementar no mesmo mês para subtrair o valor
						If ( SRR->RR_TIPO2 == "I" .and. SRR->RR_VALORI > 0 .and. Empty(RetValSRV(SRR->RR_PD, SRR->RR_FILIAL, "RV_CODFOL")) ) .Or. RetValSRV(SRR->RR_PD, SRR->RR_FILIAL, "RV_CODFOL") $ "0303/0064"
							nRecSRR := SRR->(Recno())

							cChaveAux := SRR->(RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD)

							If SRR->(DbSeek(cChaveAux))
								While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD == cChaveAux )
									If SRR->RR_DATA < dDataAux .and. SRR->RR_PERIODO <> AnoMes(SRG->RG_DATADEM) //Ignora complementar no mesmo mês da rescisão pois já foi considerada apenas a última
										nCompAnt += SRR->RR_VALOR
									EndIf
									SRR->(DbSkip())
								EndDo
							EndIf

							SRR->(DbGoTo(nRecSRR))
						EndIf

						If SRR->RR_VALOR - nCompAnt > 0

							RGB->( RecLock( "RGB" , .T. ) )
							
							RGB->RGB_FILIAL	:= SRR->RR_FILIAL
							RGB->RGB_MAT 	:= SRR->RR_MAT
							RGB->RGB_CC		:= SRR->RR_CC
							RGB->RGB_PD		:= SRR->RR_PD
							RGB->RGB_HORAS	:= SRR->RR_HORAS
							RGB->RGB_DTREF	:= SRR->RR_DATAPAG
							RGB->RGB_TIPO1	:= SRR->RR_TIPO1
							RGB->RGB_TIPO2	:= "G"
							RGB->RGB_VALOR	:= SRR->RR_VALOR - nCompAnt
							RGB->RGB_PARCEL	:= 0
							RGB->RGB_SEQ	:= If(Empty(SRR->RR_SEQ) .or. SRR->RR_SEQ < cSeqAux, cSeqAux, SRR->RR_SEQ)
							RGB->RGB_ITEM 	:= SRR->RR_ITEM
							RGB->RGB_CLVL 	:= SRR->RR_CLVL
							RGB->RGB_PROCES	:= cProcesso
							RGB->RGB_PERIOD	:= cPerPara
							RGB->RGB_ROTEIR	:= cRotPara
							RGB->RGB_SEMANA	:= cNPagPara
							RGB->RGB_ROTORI	:= cRotDe
							RGB->RGB_NUMID  := SRR->RR_NUMID
							If cPaisLoc == "BRA"
								RGB->RGB_IDCMPL	:= SRR->RR_IDCMPL
							EndIf

							RGB->(MsUnLock())

							If RetValSRV(SRR->RR_PD, SRR->RR_FILIAL, "RV_CODFOL") == "0126"
								aAdd(aRecRGB,RGB->(Recno()))
								lSliq	:= .T.
							Elseif RetValSRV(SRR->RR_PD, SRR->RR_FILIAL, "RV_CODFOL") == "0303"
								nValAnt := RGB->RGB_VALOR
							EndIf
						EndIf						
					EndIf

					SRR->(DbSkip())
				EndDo
			EndIf

			SRG->(DbSkip())
		EndDo

	EndIf

	If lSliq .And. nValAnt > 0
		For nCont := 1 to Len(aRecRGB)
			RGB->(DbGoTo(aRecRGB[nCont]))
			If RGB->RGB_VALOR - nValAnt == 0
				Reclock('RGB',.F.)
					RGB->(DbDelete())
				MsUnLock()
			EndIf
		Next nCont
	Endif

	RestArea(aAreaSRR)
	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaTRP   ³ Autor ³ Leandro Drumond	    ³ Data ³ 09/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca registros na tabela temporaria TRP			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BuscaTRP(cChave,nHoras)
	Local aArea	:= GetArea()
	Local lRet 	:= .F.

	If (cTBLXMED)->(DbSeek(cChave))
		lRet   := .T.
		nHoras := (cTBLXMED)->RP_HORAS
	EndIf

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fComplAvP ºAutor  ³ Mauricio MR        º Data ³  20/10/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Complementa aviso previo conforme anos de casa, a partir deº±±
±±º          ³ 13.10.11 para o Brasil.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 / GPEM630                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fComplAvP(dDatadem1, nAnosCasa, cTipoAviso, lFormula, cTpAvRFY, lGPEA925)
	//--Lei do Aviso Prévio Proporcional no. 12.506, de 11.10.2011 - DOU de 13.10.2011  
	//-- 30 dias de aviso para ate 1 ano de serviço na mesma empresa. Acrescido de 3 dias por ano de serviço prestado na mesma empresa
	//-- ate o maximo de 60 (sessenta) dias, perfazendo um total de até 90 (noventa) dias.
	Local nOri			:= 0
	Local lProj 		:= .F.
	Local lProjeta		:= .F.
	Local nAnosAfas     := 0
	Private nDiasAv		:= 30

	Default lFormula	:= .F.
	Default cTpAvRFY	:= ""
	Default lGPEA925	:= .F.

	If !lFormula
		nDiasAv:= (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" ))
		If nDiasAv == 0
			nDiasAv:= 30
		Endif
	Endif

	P_ANOAVPRO := Max(P_ANOAVPRO,1) 

	If Type("P_CAVPPROJ") <> "U" .And. P_CAVPPROJ == "S"
		lProjeta := .T.
	Endif


	If !Empty(SRA->RA_SINDICA) .And. RCE->(ColumnPos( "RCE_PRJAVT")) > 0
		If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_PRJAVT" )) == "1"
			lProj := .T.
		Endif
	Else
		lProj := .F.
	Endif

	lProJav := If(Type("lProJav") <> "L", .F., lProJav)

	If nDiasAv == 0 .and. !lProJav
		nDiasAv := 30
	Endif

	If cPaisLoc=="BRA" .And. ( dDatadem1 >= CtoD('13/10/11')) .And. lProJav .And. nAnosCasa >= P_ANOAVPRO .And. (( lProj .And. cTipoAviso $ "T*B") .Or. ! cTipoAviso $ "T*B")
		fAnosAfas(@nAnosAfas, dDatadem1 )
		nDiasAv := 30 +  Min(Int( ( ( nAnosCasa - nAnosAfas ) - ( P_ANOAVPRO - 1 ) ) ) * 3, 60 ) 
	EndIf

	If lProj .And. lProJav .And. lProjeta .And. (( lProj .And. cTipoAviso $ "T*B") .Or. ! cTipoAviso $ "T*B") // Se projeta o aviso prévio no tipo de rescisão e no sindicato
		nOri := 1
		fAvProj(dDatadem1, nAnosCasa, dDatadem1, cTipoAviso, nOri, nDiasCum, nDiaInde, cTpAvRFY, Nil, lGPEA925)
	Endif

	If lFormula .And. nDiasAv == 30
		nDiasAv := 0
	Endif

Return nDiasAv

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fIncResc  ³ Autor ³ Equipe RH             ³ Data ³25/07/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Carrega Incidencia do 32 - Tipos de Rescisao               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³ fIncRes(cExp1,cExp2,aExp3,nExp4,cExp5,cExp6,cExp7)			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cExp1 - Filial para Pesquisa                               ³
³          ³ cExp2 - Codigo do Tipo de Rescisao                         ³
³          ³ aExp3 - Array com as Incidendias      (Referencia)         ³
³          ³ nExp4 - % do FGTS                     (Referencia)         ³
³          ³ cExp5 - Codigo de Rescisao da Rais    (Referencia)         ³
³          ³ cExp6 - Codigo de Afastamento do FGTS (Referencia)         ³
³          ³ cExp7 - Codigo AM                     (Referencia)         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³ .T. Se Encontrou Codigo, Caso contrario .F.                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Generico                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fIncRes( cExp1 , cExp2 , aExp3 , nExp4 , cExp5 , cExp6 ,cExp7 )
	
	Local aTabS043	:= {}
	Local cTab		:= "S043"
	Local cFilAux	:= ""
	Local lRet 		:= .F.
	Local nPosTab	:= 0
	Local nTamTab	:= 0
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Inicializando os Parametros                                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DEFAULT cExp1 := SRA->RA_FILIAL
	DEFAULT cExp2 := ""
	
	aExp3 := {}
	nExp4 := 0.00
	cExp5 := ""
	cExp6 := ""
	cExp7 := ""
	
	cFilAux := cExp1
	
	If lIniTab
		GpIniTab()
		lIniTab := .F.
	EndIf
	
	If cPaisLoc == "BOL"
		cTab := "S013"
	EndIf
	
	If Empty(cExp2)
		fCarrTab( @aTabS043, cTab, , .T. )
		nTamTab := Len(aTabS043)
		
		nPosTab := fPosTab( cTab,cFilAux,"=",1)
		
		If nPosTab == 0
			cFilAux := Space(FWGetTamFilial)
			nPosTab := fPosTab( cTab, cFilAux, "=", 1,,,,,,,, cFilAux )
		EndIf
	Else
		nPosTab := fPosTab( cTab,cFilAux,"=",1,cExp2,"=",4)
		
		If nPosTab == 0
			cFilAux := Space(FWGetTamFilial)
			nPosTab := fPosTab( cTab, cFilAux, "=", 1, cExp2, "=", 4,,,,, cFilAux )
		EndIf
		nTamTab := nPosTab
	EndIf
	
	If nPosTab > 0
	
		For nPosTab := nPosTab to nTamTab
			lRet := .T.
			
			If cPaisLoc == "BRA"
				aAdd(aExp3,fTabela(cTab,nPosTab,6))  			// 01 Indenizacao
				aAdd(aExp3,fTabela(cTab,nPosTab,7))  			// 02 Aviso Previo
				aAdd(aExp3,fTabela(cTab,nPosTab,8))  			// 03 13o. Sal Resc.
				aAdd(aExp3,fTabela(cTab,nPosTab,9))  			// 04 Ferias Proporcional
				aAdd(aExp3,fTabela(cTab,nPosTab,10))  			// 05 Fgts Mes Anterior
				aAdd(aExp3,fTabela(cTab,nPosTab,11))  			// 06 Fgts Mes Rescisao
				aAdd(aExp3,fTabela(cTab,nPosTab,12))  			// 07 Fgts Multa 40%
				aAdd(aExp3,fTabela(cTab,nPosTab,13))  			// 08 Dsr s/ Med. Ferias
				aAdd(aExp3,fTabela(cTab,nPosTab,14))  			// 09 Dsr s/ Med 13o.
				aAdd(aExp3,fTabela(cTab,nPosTab,15))  			// 10 Dsr s/ Med Av. Previo
				aAdd(aExp3,"")  				        		// 11 Desconto de Ass.Medica - NAO USADO
				aAdd(aExp3,fTabela(cTab,nPosTab,20))  			// 12 Pagto. Multa Contr. Exp.
				aAdd(aExp3,fTabela(cTab,nPosTab,21))  			// 13 Desc. Multa Contr. Exp.
				aAdd(aExp3,fTabela(cTab,nPosTab,22))  			// 14 Multa Disp Antes Dissidio
				aAdd(aExp3,fTabela(cTab,nPosTab,23))  			// 15 Saldo de Salario
				aAdd(aExp3,fTabela(cTab,nPosTab,26))  			// 16 Mot. eSocial
				aAdd(aExp3,fTabela(cTab,nPosTab,27))  			// 17 Projeta Aviso?
				aAdd(aExp3,fTabela(cTab,nPosTab,28))  			// 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3,fTabela(cTab,nPosTab,29))  			// 19 Pagamento Multa Contrato Tempo Determinado
				aAdd(aExp3,fTabela(cTab,nPosTab,30))  			// 20 Ferias Vencidas
				aAdd(aExp3,fTabela(cTab,nPosTab,32))  			// 21 Desconta Benefícios
				nExp4	:= fTabela(cTab,nPosTab,16)/100			// % do FGTS
				cExp5	:= fTabela(cTab,nPosTab,17)            	// Codigo de Rescisao RaIS
				cExp6	:= fTabela(cTab,nPosTab,18)            	// Codigo Afastamento FGTS
				cExp7	:= fTabela(cTab,nPosTab,19)				// Codigo para AM
			ElseIf cPaisLoc == "PAR"   //Compatibilizar
				aAdd(aExp3  ,Subs(SRX->RX_TXT,31,1))  // 01 Ferias Proporcional
				aAdd(aExp3  ,Subs(SRX->RX_TXT,32,1))  // 02 13ro Proporcional
				aAdd(aExp3  ,Subs(SRX->RX_TXT,33,1))  // 03 Pagar Indemnizacao
				aAdd(aExp3  ,Subs(SRX->RX_TXT,34,1))  // 04 Desc. Indemnizacao
				aAdd(aExp3  ,Subs(SRX->RX_TXT,35,1))  // 05 Pagar Pre-Aviso
				aAdd(aExp3  ,Subs(SRX->RX_TXT,36,1))  // 06 Desc. Pre-Aviso
				aAdd(aExp3  ,"")  						  // 07 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 08 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 09 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 10 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 11 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 12 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 13 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 14 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"S")  						  // 15 Saldo de Salario
				aAdd(aExp3  ,"")  						  // 16 eSocial
				aAdd(aExp3  ,"N")  						  // 17 Projeta Aviso
				aAdd(aExp3  ,"  ")  		                    	          // 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3  ,"   ")  			                          // 19 Pagamento Multa Contrato Tempo Determinado
				nExp4  	:= 0
				cExp5  	:= ""
				cExp6  	:= ""
				cExp7  	:= ""
			ElseIf cPaisLoc == "CHI" //Compatibilizar
				aAdd(aExp3  ,Subs(SRX->RX_TXT,31,1))  // 01 Ferias Proporcional
				aAdd(aExp3  ,Subs(SRX->RX_TXT,32,1))  // 02 Pagar Pre-Aviso
				aAdd(aExp3  ,Subs(SRX->RX_TXT,34,1))  // 03 Pagar Indemnizacao
				aAdd(aExp3  ,Subs(SRX->RX_TXT,35,3))  // 04 Anos Limite Ind 1981
				aAdd(aExp3  ,Subs(SRX->RX_TXT,38,3))  // 05 Limite en UFs Ind 1981
				aAdd(aExp3  ,Subs(SRX->RX_TXT,41,3)) // 06 Anos Limite Ind. 1989     
				aAdd(aExp3  ,Subs(SRX->RX_TXT,44,3)) // 07 Limite en UFs Ind 1989    
				aAdd(aExp3  ,"")  						  // 08 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 09 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 10 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 11 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 12 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 13 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,"")  						  // 14 Compatibilidade GPE BRASIL
				aAdd(aExp3  ,Subs(SRX->RX_TXT,33,1)) 	  // 15 Saldo de Salario
				aAdd(aExp3  ,"")  						  // 16 eSocial
				aAdd(aExp3  ,"N")  						  // 17 Projeta Aviso
				aAdd(aExp3  ,"  ")  		                    	          // 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3  ,"   ")  			                          // 19 Pagamento Multa Contrato Tempo Determinado
				nExp4  		:= 0
				cExp5  	:= ""
				cExp6  	:= ""
				cExp7  	:= ""
			ElseIf cPaisLoc == "URU" //Compatibilizar
				Aadd(aExp3  ,Subs(SRX->RX_TXT,31,1))  // 01 Ferias Proporcional
				Aadd(aExp3  ,Subs(SRX->RX_TXT,32,1))  // 02 13ro Proporcional
				Aadd(aExp3  ,Subs(SRX->RX_TXT,33,1))  // 03 Pagar Indemnizacao
				Aadd(aExp3  ,Subs(SRX->RX_TXT,34,5))  // 04 Minimo de Jornadas
				Aadd(aExp3  ,Subs(SRX->RX_TXT,40,1))  // 05 IPD - Aguinaldo
				Aadd(aExp3  ,Subs(SRX->RX_TXT,41,1))  // 06 IPD - Vacaciones
				Aadd(aExp3  ,Subs(SRX->RX_TXT,42,1))  // 07 IPD - Salario Vacacional
				Aadd(aExp3  ,Subs(SRX->RX_TXT,43,1))  // 08 IPD - Quantidade
				Aadd(aExp3  ,Subs(SRX->RX_TXT,44,1))  // 09 Indenizacao Maternidade
				Aadd(aExp3  ,"")  						  // 10 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 11 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 12 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 13 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 14 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,Subs(SRX->RX_TXT,39,1))     // 15 Saldo de Salario
				aAdd(aExp3  ,"")  						  // 16 eSocial
				aAdd(aExp3  ,"N")  						  // 17 Projeta Aviso
				aAdd(aExp3  ,"  ")  		                    	          // 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3  ,"   ")  			                          // 19 Pagamento Multa Contrato Tempo Determinado
				nExp4  		:= 0
				cExp5  	:= ""
				cExp6  	:= ""
				cExp7  	:= ""
			ElseIf cPaisLoc == "ARG" //Compatibilizar
				aAdd(aExp3,Subs(SRX->RX_TXT,31,1))  			// 01 Indenizacao
				aAdd(aExp3,Subs(SRX->RX_TXT,32,1))  			// 02 Aviso Previo Pago
				aAdd(aExp3,Subs(SRX->RX_TXT,33,1))  			// 03 Aviso Previo Desc.
				aAdd(aExp3,Subs(SRX->RX_TXT,34,1))  			// 04 SAC Sal Resc.
				aAdd(aExp3,Subs(SRX->RX_TXT,35,1))  			// 05 Ferias Proporcional
				Aadd(aExp3,Subs(SRX->RX_TXT,36,1))  		   // 06 Composicion del mes
				Aadd(aExp3,Subs(SRX->RX_TXT,37,1))  		   // 07 Aviso Previo Trabalhado
				Aadd(aExp3  ,"")  						  // 08 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 09 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 10 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 11 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 12 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 13 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 14 Compatibilidade GPE BRASIL
				aAdd(aExp3,Subs(SRX->RX_TXT,38,1))  	  // 15 Saldo de Salario
				aAdd(aExp3  ,"")  						  // 16 eSocial
				aAdd(aExp3  ,"N")  						  // 17 Projeta Aviso
				aAdd(aExp3  ,"  ")  		                    	          // 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3  ,"   ")  			                          // 19 Pagamento Multa Contrato Tempo Determinado
				nExp4	:= 0
				cExp5	:= ""
				cExp6	:= ""
				cExp7	:= ""
			ElseIf cPaisLoc == "DOM"  //Compatibilizar
				aAdd(aExp3	,Subs(SRX->RX_TXT,31,1))  // 01 Indenizacao
				aAdd(aExp3	,Subs(SRX->RX_TXT,32,1))  // 02 Aviso Previo
				aAdd(aExp3	,Subs(SRX->RX_TXT,33,1))  // 03 13o. Sal Resc.
				aAdd(aExp3	,Subs(SRX->RX_TXT,34,1))  // 04 Ferias Proporcional
				aAdd(aExp3	,Subs(SRX->RX_TXT,35,1))  // 05 Desc. Aviso Previo
				Aadd(aExp3  ,Subs(SRX->RX_TXT,36,1))  // 06 Indemnizacao Morte Invalidez
				Aadd(aExp3  ,Subs(SRX->RX_TXT,37,1))  // 07 Liquidacion Anual
				Aadd(aExp3  ,"")  						  // 08 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 09 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 10 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 11 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 12 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 13 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,"")  						  // 14 Compatibilidade GPE BRASIL
				Aadd(aExp3  ,Subs(SRX->RX_TXT,38,1))     // 15 Saldo de Salario
				aAdd(aExp3  ,"")  						  // 16 eSocial
				aAdd(aExp3  ,"N")  						  // 17 Projeta Aviso
				aAdd(aExp3  ,"  ")  		                    	          // 18 Tipo Rescisão Diretor - NAO USADO
				aAdd(aExp3  ,"   ")  			                          // 19 Pagamento Multa Contrato Tempo Determinado
				nExp4  		:= 0
				cExp5  	:= ""
				cExp6  	:= ""
				cExp7  	:= ""
			ElseIf cPaisLoc == "BOL" //Compatibilizar
				aAdd(aExp3, fTabela(cTab, nPosTab, 7))			// 01 Aguinaldo
				aAdd(aExp3, fTabela(cTab, nPosTab, 8))			// 02 Vacaciones
				aAdd(aExp3, fTabela(cTab, nPosTab, 9))			// 03 Desahucio
				aAdd(aExp3, fTabela(cTab, nPosTab, 10))			// 04 Indenizacao
				aAdd(aExp3, fTabela(cTab, nPosTab, 11))			// 05 Prima Anual
				aAdd(aExp3, "")									// 06 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 07 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 08 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 09 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 10 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 11 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 12 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 13 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 14 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 15 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 16 Compatibilidade GPE BRASIL
				aAdd(aExp3, fTabela(cTab, nPosTab, 6))			// 17 Saldo de Salario
				aAdd(aExp3, "")									// 18 Compatibilidade GPE BRASIL
				aAdd(aExp3, "")									// 19 Compatibilidade GPE BRASIL
				nExp4 := ""
				cExp5 := ""
				cExp6 := ""
				cExp7 := ""
			EndIf

		Next nPosTab

	EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtAvProj ºAutor  ³ Leandro Drumond    º Data ³  14/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza e projeta os dias de aviso previo.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 / Valid RG_DTAVISO                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fAtAvProj(lDiasAvis,lChgDtGer)

	Local dDtAvi	:= &(ReadVar())
	Local oModel
	Local cTpAviso	:= ""
	Local lRet		:= .T.
	Local lProjeta	:= .T.
	Local lEstab	:= SRG->( ColumnPos( "RG_DTESTAB") ) > 0
	
	lMetFalV	:= If( Type("lMetFalV") == "U", .F., lMetFalV)

	DEFAULT nDferven  := 0
	DEFAULT nDferave  := 0
	DEFAULT nFaltasv  := 0
	DEFAULT nFaltasp  := 0
	DEFAULT lDiasAvis := .F.
	DEFAULT lChgDtGer := .T.

	lTemRFY := If(Type("lTemRFY") == "U", .F., lTemRFY)
	dDtProje	:= CtoD("")

	If !Empty(SRA->RA_SINDICA) .And. RCE->(ColumnPos( "RCE_PRJAVT")) > 0
		If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_PRJAVT" )) == "2"
			lProj := .F.
		Endif
	Else
		lProj := .T.
	Endif

	If Type("P_CAVPPROJ") <> "U" .And. P_CAVPPROJ == "N"
		lProjeta := .F.
	Endif

	P_lPPEAtiv	:= If( Type("P_lPPEAtiv") == "U", .F. , P_lPPEAtiv)
	P_PRJESTAB	:= If( Type("P_PRJESTAB") == "U", .F. , P_PRJESTAB)
	dDtEst936	:= If( Type("dDtEst936") == "U", cToD("") , dDtEst936)
	nPerEst936	:= If( Type("nPerEst936") == "U", 0 , nPerEst936)

	cTpRes := M->RG_TIPORES
	oModel := FWModelActive()

	If !lDiasAvis
		dDataAvis := dDtAvi
	Else
		dDtAvi := dDataAvis
	Endif

	If !lTemRFY .And. cPaisLoc == "BRA"
		nDiasCum := 0
		nDiaInde := 0
		nDiasAV  := 0
		dDtProje := CTOD("//")
		fIncRes(SRA->RA_FILIAL,cTpRes,@aIncRes,@nPercFgts,@cRescrais,@cAfasfgts,@Cod_Am)
		cTpAviso := aIncRes[2]  
		If cPaisLoc == "BRA" .And. P_lPPEAtiv .And. !(cAfasfgts $ "H /J /") .And. cTpAviso != "A"
			fEstab936(dDtAvi, @dDtEst936, @nPerEst936)
		EndIf
		nAnosCasa := fAnosCasa( If(lProjeta, Iif( cPaisLoc == "BRA" .And. P_PRJESTAB .And. dDtEst936 > dDtAvi, dDtEst936+30, dDtAvi+30), dDtAvi)  , SRA->RA_ADMISSA )
		If lProjav .and. ( (lProj .And. cTpAviso $ "T*B") .Or. ! cTpAviso $ "T*B" )  
			If cTpAviso $ 'T|I|D|N|A|B'
				nDiasAv := fAvProj(dDtAvi,nAnosCasa,@dDatadem1,cTpAviso,,@nDiasCum,@nDiaInde,,Iif( cPaisLoc == "BRA" .And. P_PRJESTAB, dDtEst936, Nil))
			EndIf
		Else
			nDiasAv:= (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" ))
			If nDiasAv == 0
				nDiasAv:= 30
			Endif
			dDatadem1		:= DaySum( dDtAvi , nDiasAv )		
			If cTpAviso == "T"
				nDiasCum := nDiasAv 
				dDatadem1:= dDtAvi + nDiasCum
			Else
				dDatadem1:= dDtAvi
			EndIf
			If cTpAviso $ "N|D"
				dDtProje := CTOD("//")
				If cTpAviso == "N"
					nDiasAv := 0
				Endif
			ElseIf !Empty(dDtAvi)
				dDtProje := dDtAvi + nDiasAv
			EndIf
		EndIf
		oModel:LoadValue("GPEM040_MSRG","RG_DAVISO",nDiasAV)
		If SRG->(ColumnPos( "RG_DAVCUM")) > 0
			oModel:LoadValue("GPEM040_MSRG","RG_DAVCUM",nDiasCum)
			oModel:LoadValue("GPEM040_MSRG","RG_DAVIND",nDiaInde)
			oModel:LoadValue("GPEM040_MSRG","RG_DTPROAV",dDtProje)
		EndIf
		oModel:LoadValue("GPEM040_MSRG","RG_DATADEM",dDataDem1)
		If lChgDtGer
			oModel:LoadValue("GPEM040_MSRG","RG_DTGERAR",dDataDem1)
		EndIf
		If cPaisLoc == "BRA" .And. lEstab
			oModel:LoadValue("GPEM040_MSRG", "RG_DTESTAB", dDtEst936)
		EndIf
	ElseIf cPaisLoc == "BOL" .And. lRecRes .And. lChgDtGer
		oModel:LoadValue("GPEM040_MSRG", "RG_DTGERAR", SRG->RG_DTGERAR)
	EndIf

	If lRet .And. cPaisLoc == "BRA"
		//Calcula dias de ferias
		aPerFerias := {}
		fdFerRes(.T.,dDataDem1)

		oModel:LoadValue("GPEM040_MSRG","RG_DFERVEN", If(!lMetFalv, If(!lTempoParc, nDferven - nFaltasv, 0), nDferven / 2))
		oModel:LoadValue("GPEM040_MSRG","RG_DFERPRO", If(!lMetFalp, If(!lTempoParc, nDferave - nFaltasp, 0), nDferave / 2))
		If SRA->RA_TPCONTR == "3" .and. nDferInd > 0
			nDferInd := 2.5	// Intermitente sempre será 1 avo
		EndIf
		If aIncRes[2] <> "N"
			oModel:LoadValue("GPEM040_MSRG","RG_DFERAVI",nDferInd)
		EndIf
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAvProj 	ºAutor  ³ Gustavo M.         º Data ³  26/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para projetar os dias de aviso previo				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fAvProj(dDtAvi, nAnosCasa, dDatadem1, cTpAviso, nOri, nDiascum, nDiaInde, cTpAvRFY, dDtEstab, lGPEA925)
	//--Lei do Aviso Prévio Proporcional no. 12.506, de 11.10.2011 - DOU de 13.10.2011  
	//-- 30 dias de aviso para ate 1 ano de serviço na mesma empresa. Acrescido de 3 dias por ano de serviço prestado na mesma empresa
	//-- ate o maximo de 60 (sessenta) dias, perfazendo um total de até 90 (noventa) dias.

	Local dProjAv	:= CtoD("")
	Local lProj		:= .T.
	Local lProjeta	:= .F.
	Local nDiasAv2	:= 0
	Local nDAviso	:= 0
	Local nDiaCump2	:= 30
	Local lArrAviso := If( Type("P_LARRAVP") # "U", P_LARRAVP, .F. ) //Default não arredonda
	Local nLinha	:= 0
	Local nLinTab	:= 0

	Private cAvPrev := ""

	DEFAULT cTpAviso	:= ""
	DEFAULT cTpAvRFY	:= ""
	DEFAULT nDiasCum	:= 30
	DEFAULT nOri		:= 0
	DEFAULT dDtEstab	:= cToD("//")
	DEFAULT lGPEA925 	:= .F.

	cAvPrev := cTpAviso

	nDAviso:= (fDesc( "RCE", SRA->RA_SINDICA, "RCE_DIASAV" ))
	If nDAviso == 0
		nDAviso := 30
	Endif

	nDiasAv2 := nDAviso

	If nOri <> 1
		nDiaCump2	:= IIf(nDiaCump2 > 0, nDiaCump2, nDiasCum)
	Endif

	P_ANOAVPRO := Max(P_ANOAVPRO,1) 

	If Type("P_CAVPPROJ") <> "U" .And. P_CAVPPROJ == "S"
		lProjeta := .T.
	Endif

	If !Empty(SRA->RA_SINDICA) .And. RCE->(ColumnPos( "RCE_PRJAVT")) > 0
		If (fDesc( "RCE", SRA->RA_SINDICA, "RCE_PRJAVT" )) == "2"
			lProj := .F.
		Endif
	Else
		lProj := .T.
	Endif

	If cPaisLoc=="BRA" .and. ( dDtAvi >= CtoD('13/10/11')) .and. nAnosCasa >= P_ANOAVPRO
		If P_ANOAVPRO > 1 
			nAnosCasa--
		EndIf
		
		If lProjeta
			dProjAv:= Iif( Empty(dDtEstab) .Or. dDtEstab < dDtAvi, dDtAvi, dDtEstab) + Min( nAnosCasa * 3 , 60) + 30
			nAnosCasa := fAnosCasa( dProjAv  , SRA->RA_ADMISSA )
			
			If P_ANOAVPRO > 1 
				nAnosCasa--
			EndIf
		EndIf
		fAnosAfas(@nAnosCasa, Iif( Empty(dDtEstab) .Or. dDtEstab < dDtAvi, dDtAvi, dDtEstab) )

		If ( ( nLinha := fPosTab( "S149", SRA->RA_SINDICA, "=", 4, nAnosCasa, "<=", 5, Nil, Nil, @nLinTab, .T., SRA->RA_FILIAL, Nil, Nil, Nil, Nil, {1, 2, 3, 4, 5} ) ) > 0 .Or.;
			( nLinha := fPosTab( "S149", Space(nTamSind), "=", 4, nAnosCasa, "<=", 5, Nil, Nil, @nLinTab, .T., SRA->RA_FILIAL, Nil, Nil, Nil, Nil, {1, 2, 3, 4, 5} ) ) > 0 )
			nDiasAv2 := nDAviso + fTabela("S149", nLinha, 6, Nil, SRA->RA_FILIAL)//AVISO
		Else
			nDiasAv2 := nDAviso + Min(Int( ( nAnosCasa ) ) * 3,60)  
		EndIf
	EndIf        

	If cTpAviso == 'I' 
		nDiaInde := nDiasAv2
		nDiasCum := 0                       
	ElseIf cTpAviso == 'A' 
		nDiaInde := IIf(lArrAviso, Round( (nDiasAv2 / 2), 0), nDiasAv2 / 2)
		nDiasCum := 0                       
	Elseif  cTpAviso == 'D'       
		nDiasAv :=  nDiasAv2  
		nDiasCum := 0
		nDiaInde := 0
	Elseif cTpAviso $ 'TB' 
		nDiaInde := nDiasAv2 - nDiaCump2
		nDiasCum := nDiaCump2
	Elseif cTPAviso == 'N'
		nDiascum:=0
		nDiaInde:=0 
		dDatadem1:= dDtAvi
	Elseif !Empty(cTpAviso)
		nDiaInde := nDiasAv2 - 30
		nDiasCum := 30
	Endif

	nDiasAv := iif(nDiasAv > 0, nDiasAv, nDiasAv2)

	If nOri == 1 .Or. ( ( (lProj .And. cTpAviso $ "T*B") .Or. ! cTpAviso $ "T*B") .And. lProjav .And. FunName() $ "GPEM040" )
		nDiasAv :=  Max(nDiasAv2,nDiasAv)
	Endif

	If cTpAviso == 'A'
		nDiasAv  := nDiaInde
	EndIf

	//--Chamada Execblock Dias de Aviso
	IF ExistBlock("GPDAV040")
		Execblock("GPDAV040",.F.,.F.)
	EndIF	

	If cTpAviso $ "TB"
		dDatadem1:= dDtAvi + nDiasCum
	Else
		dDatadem1:= dDtAvi
	EndIf
	
	dDtProje	:= CtoD("")

	If cTpAviso $ "N|D"
		dDtProje := CTOD("//")
		If cTpAviso == "N"
			nDiasAv := 0
		Endif
	ElseIf !Empty(dDtAvi)
		If Empty(dDtEstab) .Or. dDtEstab < dDtAvi
			If ((!lGPEA925 .And. lSabDom) .Or. (lGPEA925 .And. GetMvRH("MV_SABDOM") == "S")) .and. ( Dow( dDtAvi ) == 6 .or. Dow( dDtAvi ) == 7 )
				dDtProje := dDtAvi + nDiasAv + IF(Dow( dDtAvi ) == 6, 2, 1)
			Else
				dDtProje := dDtAvi + nDiasAv
			EndIf
		Else
			dDtProje := dDtEstab + nDiaInde
		EndIf
	EndIf

Return nDiasAv

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fInitMnenem	³ Autor ³ Mauricio T. Takakura³ Data ³14/03/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Inicializador dos Mnemonicos               					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fInitMnenem													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³Generico  												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fInitMnenem() 

	Local cFilRCA		:= xFilial( "RCA" )

	Begin Sequence

		cProcesso	:= SRA->RA_PROCES							// Codigo do periodo
		If cPaisLoc $ "BRA/COL"
			cRot	:= fGetCalcRot('4')
		Else
			cRot	:= GetMvRH("MV_ROTEIRO",, Space( GetSx3Cache("RY_CALCULO", "X3_TAMANHO") ))				// Roteiro de Calculo
		EndIf
		cDiasMes	:= GetMvRH("MV_DIASMES")						// Utilizar Dias do Mes para Calculo dos HO
		cMedDir		:= P_MEDDIREN						// Indica se serao pagas medias de direito 
		cAboAnt		:= GetMvRH("MV_ABOPEC")						// Parametro para abono antes das ferias
		cAbatAfas   := GetMvRH("MV_ABATAFA") 						// Abater Afastamento no 13§
		cPgSalMat   := GetMvRH("MV_PGSALMA")						// Abater Afastamento Aux. Maternidade no 13§
		cRefFer		:= GetMvRH("MV_REFFER",,"A")					// Gravar Ref. Ferias/13 Avos ou dias
		cTafaFer    := GetMvRH("MV_TAFAFER" )      				// Trata Perda de Periodo Para Afastados

		GETSRR( @OSRR, "1 = 0" )								// Objeto do Arquivo de Rescisao - SRR

		aTarefas	:= GetContMnemon( cFilRCA, "aTarefas" )		// Utilizada em fFiltrApd
		aSalProf	:= GetContMnemon( cFilRCA, "aSalProf" )		// Utilizada em fFiltrApd
		aTabFer		:= GetContMnemon( cFilRCA, "aTabFer" )		// array com os peridos de ferias
		aIncRes		:= GetContMnemon( cFilRCA, "aIncRes" )		// Incidencia de Rescisao
		aCodFol		:= GetContMnemon( cFilRCA, "aCodFol" )		// Codigo de Identificadores de Calculo
		aPdProfRec	:= GetContMnemon( cFilRCA, "aPdProfRec" )	// Array com movimento professores para recalculo rescisao
		aPeriodo	:= GetContMnemon( cFilRCA, "aPeriodo" )		// Array com as semanas para calculo
		cPeriodo	:= GetContMnemon( cFilRCA, "cPeriodo" )		// Codigo do Periodo
		cNumPag		:= GetContMnemon( cFilRCA, "cNumPag" )		// Numero de Pagamento
		cCompl 		:= GetContMnemon( cFilRCA, "cCompl" )		// Se eh uma rescisao complementar ou nao
		cFolMes		:= GetContMnemon( cFilRCA, "cFolMes" )		// Ano e Mes de Calculo da Folha
		cTipRes		:= GetContMnemon( cFilRCA, "cTipRes" )		// Tipo de Rescisao
		cRescRais	:= GetContMnemon( cFilRCA, "cRescRais" )	// Codigo da Rescisao na Rais
		cAfasfgts	:= GetContMnemon( cFilRCA, "cAfasfgts" )	// Codigo de Afastamento FGTS
		cMedAtu		:= GetContMnemon( cFilRCA, "cMedAtu" )		// Media Atualizada
		Cod_Am		:= GetContMnemon( cFilRCA, "Cod_Am" )		// Codigo de Autorizacao do Movimento FGTS
		dDataDem	:= GetContMnemon( cFilRCA, "dDataDem" )		// Data da Demissao
		dDataAv		:= GetContMnemon( cFilRCA, "dDataAv" )		// Data do Aviso Previo
		dDtTarDe 	:= GetContMnemon( cFilRCA, "dDtTarDe" )		// Data para Tarefeiro De:
		dDtTarAte   := GetContMnemon( cFilRCA, "dDtTarAte" )	// Data para Tarefeiro Ate:
		dDtGerar 	:= GetContMnemon( cFilRCA, "dDtGerar" )		// Data da geracao da rescisao
		lMesAtu		:= GetContMnemon( cFilRCA, "lMesAtu" )		// Considera o Mes para Media por Sindicato 
		lProxMes	:= GetContMnemon( cFilRCA, "lProxMes" )		// Se a Rescisão sera para o proximo mes
		lUltSemana	:= GetContMnemon( cFilRCA, "lUltSemana" )	// Ultima Semana Mes, Variavel Logica  
		nPosSem		:= GetContMnemon( cFilRCA, "nPosSem" )		// Posicao da Semana
		nDiasAv		:= GetContMnemon( cFilRCA, "nDiasAv" )		// Numero de Dias do Aviso
		nDferave 	:= GetContMnemon( cFilRCA, "nDFerAve" )		// Nro. Dias Ferias a Vencer
		nDferV		:= GetContMnemon( cFilRCA, "nDFerV" )		// Nro. Dias Ferias Vencidas
		nDFerA		:= GetContMnemon( cFilRCA, "nDFerA" )		// Nro. Dias Ferias a Vencer
		nPercFgts	:= GetContMnemon( cFilRCA, "nPercFgts" )	// Percentagem da Multa FGTS
		nDFerInd	:= GetContMnemon( cFilRCA, "nDFerInd" )		// Dias de Ferias Indenizadas
		nDFerVen	:= GetContMnemon( cFilRCA, "nDFerVen" )		// Dias Ferias Vencidas
		nFaltasv	:= GetContMnemon( cFilRCA, "nFaltasv" )		// Dias Faltas Vencidas - Tab. Faltas
		nFaltasp	:= GetContMnemon( cFilRCA, "nFaltasp" )		// Dias de Faltas a Vencer - Tab. Faltas
		ndDobro		:= GetContMnemon( cFilRCA, "ndDobro" )		// Dias de Ferias em Dobro
		nDsr_hrex	:= GetContMnemon( cFilRCA, "nDsr_hrex" )	// DSR sobre Horas Extras-RES
		nFalAtuD	:= GetContMnemon( cFilRCA, "nFalAtuD" )		// Nro de Dias Faltas
		nSalPgto	:= GetContMnemon( cFilRCA, "nSalPgto" )		// Soma valores dos semanalistas
		nDiasSalAv	:= GetContMnemon( cFilRCA, "nDiasSalAv" )	// Nro de Dias Aviso Previo
		Dsr_hhex 	:= GetContMnemon( cFilRCA, "Dsr_hhex" )		// HRS Horas DSR s/ Horas Extras
		nMedFerv 	:= GetContMnemon( cFilRCA, "nMedFerv" )		// Media de Ferias Vencidas  
		nMedFerp 	:= GetContMnemon( cFilRCA, "nMedFerp" )		// Media de Ferias Proporcionais  
		nMed13o 	:= GetContMnemon( cFilRCA, "nMed13o" )		// Media de 13o
		nMed13oA 	:= GetContMnemon( cFilRCA, "nMed13oA" )		// Media de 13o. Salario
		nMedAviso 	:= GetContMnemon( cFilRCA, "nMedAviso" )	// Media de Aviso Previo
		nDesc13 	:= GetContMnemon( cFilRCA, "nDesc13" )		// Vlr Desc. 13o Pago Meses Anteriores.-RES 
		nMedDobra 	:= GetContMnemon( cFilRCA, "nMedDobra" )	// Valor da Media para a dobra de ferias
		nSal_fami 	:= GetContMnemon( cFilRCA, "nSal_fami" )	// Salario-Familia
		nContri 	:= GetContMnemon( cFilRCA, "nContri" )		// Contribuicao Sindical
		nSeguro	 	:= GetContMnemon( cFilRCA, "nSeguro" )		// Vlr Seguro
		nSegEmp  	:= GetContMnemon( cFilRCA, "nSegEmp" )		// Vlr Seguro Empresa
		Seguro_B 	:= GetContMnemon( cFilRCA, "Seguro_B" )		// Base Seguro Saude
		nValProv 	:= GetContMnemon( cFilRCA, "nValProv" ) 	// Vlr Total Verbas Proventos
		nValDesc 	:= GetContMnemon( cFilRCA, "nValDesc" )	 	// Vlr Total Verbas Descontos
		nAnosCasa	:= GetContMnemon( cFilRCA, "nAnosCasa" )	// Anos de Casa do Funcionario
		SalMes		:= GetContMnemon( cFilRCA, "SalMes" )		// Salario Composto pelas verbas Incorporadas
		SalDia		:= GetContMnemon( cFilRCA, "SalDia" )		// Salario Dia Composto
		SalHora		:= GetContMnemon( cFilRCA, "SalHora" )		// Salario Hora Composto
		Normal		:= GetContMnemon( cFilRCA, "Normal" )		// Horas Normais do Funcionario
		Descanso	:= GetContMnemon( cFilRCA, "Descanso" )		// Horas de Descanso do Funcionario

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verbas que nao devem ser deletadas no recalculo.           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cVerbaNDel  	:= 	fGetCodFol( "0118", .F. ) + "_" +; // Saldo Fgts para calculop da Multa
		fGetCodFol( "0303", .F. )          // Liquido rescisao anterior

	End Sequence

Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³ fChamaRot ³ Autor ³ Microsiga            ³ Data ³06/17/03   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Funcao para tratamento de chamada de rotina com get dados	 ³
³          ³de outros programas.										 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³                              							     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³             										         ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fChamaRot(cRotina, cAlias, cOpcao)

	Local aArea			:= GetArea()
	Local aRotSv		:= aClone(aRotina)
	Local aColsSv		:= aClone(oGet:aCols)
	Local aHeaderSv		:= aClone(aSrrHeader)

	Local cCadSv		:= cCadastro

	Local nSv			:= oGet:nAt
	Local oGetSv		:= oGet

	nOpcao 				:= If ( cOpcao = "I", 3, If (cOpcao = "A", 4, 2))

	aRotina := { {"Visualizar", cRotina , 0 , 1},; 	//"Pesquisa"
	{"Visualizar", cRotina , 0 , 2}} 	//"Visualizar"

	cRoda := cRotina + "(" +"'"+cAlias+"'"+","+AllTrim(Str((cAlias)->(Recno())))+","+Alltrim(Str(nOpcao))+")"
	xRet  := Eval( { || &( cRoda ) } ) 

	//--Restaura as configuracoes originais	
	RestArea(aArea)
	oGet:aCols		:= aColsSv
	oGet:aHeader 	:= aHeaderSv
	oGet:nAt		:= nSv
	oget			:= oGetSv
	cCadastro 		:= cCadSv
	aRotina 		:= aClone(aRotSv)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fConvHoras  ³ Autor ³ Microsiga           ³ Data ³07/01/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Funcao conversao de horas conforme parametro digitacao, em	³
³          ³minutos ou centesimal.                                    	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ nHoras = Horas a serem convertidas							³
³          ³ cTipo  = "1" - Centesimal para Hexagesimal					³
³          ³          "2" - Hexagesimal para Centesimal					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fConvHoras( nHoras, cTipo )

	Local cDigHoras := Upper( AllTrim( GetMvRH( "MV_HORASDE" ) ) )

	Local nHor2 	 := nHoras

	If cDigHoras == "S" .And. cTipo == "1" 
		nHor2 := nHoras - Int(nHoras)
		nHor2 := ( nHor2 / 100 ) * 60
		nHor2 := Round( Int(nHoras) + nHor2 , 2 )
	ElseIf cDigHoras == "S" .And. cTipo == "2" 
		nHor2 := nHoras - Int(nHoras)
		nHor2 := ( nHor2 / 60 ) * 100
		nHor2 := Round( Int(nHoras) + nHor2 , 2 )
	EndIf

Return( nHor2 )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fInsertCols ³ Autor ³ Mauricio T. Takakura³ Data ³15/02/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Inserir linhas no aCols seguindo estrutura do aHeader     	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ Vide Parametros                               				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fInsertCols(aCols,aHeader,cCod,nValor,nHoras,cSem,cCct,cTip1,cTip2,cMes,cPeriodo,cRoteiro,lDel,dData,nValInfo,nHorInfo,cSeq,cNumID,cCodFunc,cItem,cCLVL,cMesMed)

	Local aCols1

	Local nReg
	Local lItemClVl   := GetMvRH( "MV_ITMCLVL", .F., "2" ) $ "1*3" // Define se utiliza Item Contabil e Classe de Valor

	DEFAULT cSem	:= ""
	DEFAULT cCct	:= SRA->RA_CC
	DEFAULT cTip1	:= "V"
	DEFAULT cTip2 	:= "C"
	DEFAULT cMes	:= CtoD("//")
	DEFAULT cPeriodo:= ""
	DEFAULT cRoteiro:= ""
	DEFAULT nValor  := 0.00
	DEFAULT nHoras 	:= 0.00
	DEFAULT nValInfo:= 0.00
	DEFAULT nHorInfo:= 0.00
	DEFAULT lDel	:= .F.
	DEFAULT cSeq	:= ""
	DEFAULT cNumID	:= ""
	DEFAULT cItem	:= If(lItemClvl,SRA->RA_ITEM,Nil)
	DEFAULT cCLVL	:= If(lItemClvl,SRA->RA_CLVL,Nil)

	aCols1 := GdRmkaCols( aHeader, .F., .T., .F.)	// Gerar uma linha do aCols

	aAdd( aCols, aClone( aCols1[1] ) )

	nReg := Len( aCols )
	If nReg>0 
		If ValType(aCols[1][1])<>"L"
			If dData==Nil
				dData:=Ctod("  /  /  ")	
			EndIf
			aCols[ nReg, GdFieldPos( "RR_PD"		, aHeader ) ] 	:= cCod
			aCols[ nReg, GdFieldPos( "RR_DESCPD"	, aHeader ) ] 	:= DescPd( cCod )
			aCols[ nReg, GdFieldPos( "RR_VALOR"		, aHeader ) ] 	:= nValor
			aCols[ nReg, GdFieldPos( "RR_HORAS"		, aHeader ) ] 	:= nHoras
			aCols[ nReg, GdFieldPos( "RR_SEMANA"	, aHeader ) ] 	:= cSem
			aCols[ nReg, GdFieldPos( "RR_CC"		, aHeader ) ] 	:= cCct
			aCols[ nReg, GdFieldPos( "RR_TIPO1"		, aHeader ) ] 	:= cTip1
			aCols[ nReg, GdFieldPos( "RR_TIPO2"		, aHeader ) ] 	:= cTip2
			aCols[ nReg, GdFieldPos( "RR_DATAPAG"	, aHeader ) ] 	:= cMes
			aCols[ nReg, GdFieldPos( "RR_PERIODO"	, aHeader ) ] 	:= cPeriodo
			aCols[ nReg, GdFieldPos( "RR_ROTEIR"	, aHeader ) ] 	:= cRoteiro
			aCols[ nReg, GdFieldPos( "RR_DATA"		, aHeader ) ] 	:= dData
			aCols[ nReg, GdFieldPos( "RR_HORINFO"	, aHeader ) ] 	:= nHorInfo
			aCols[ nReg, GdFieldPos( "RR_VALINFO"	, aHeader ) ] 	:= nValInfo
			aCols[ nReg, GdFieldPos( "RR_SEQ"		, aHeader ) ] 	:= cSeq
			aCols[ nReg, GdFieldPos( "RR_NUMID"		, aHeader ) ] 	:= cNumID
			If GdFieldPos( "RR_CODFUNC", aHeader ) > 0 .And. cCodFunc <> Nil
				aCols[ nReg, GdFieldPos( "RR_CODFUNC"	, aHeader ) ] 	:= cCodFunc
			EndIf
			aCols[ nReg, Len(aHeader)+1 ] 							:= lDel
			If Empty( aCols[ nReg, GdFieldPos( "RR_PROCES" , aHeader ) ] )
				If ValType(cProcesso) != "U"
					aCols[ nReg, GdFieldPos( "RR_PROCES" , aHeader ) ] := cProcesso
				EndIf
			EndIf
			If lItemClvl
				aCols[ nReg, GdFieldPos( "RR_ITEM"		, aHeader ) ] 	:= cItem
				aCols[ nReg, GdFieldPos( "RR_CLVL"		, aHeader ) ] 	:= cCLVL
			EndIf
			If GdFieldPos( "RR_MESMED", aHeader ) > 0 .And. cMesMed <> Nil
				aCols[ nReg, GdFieldPos( "RR_MESMED"	, aHeader ) ] 	:= cMesMed
			EndIf
		EndIf
	EndIf
Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fAnosCasa ³ Autor ³ Marinaldo             ³ Data ³25/07/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica o Tempo de Casa do Funcionario                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fAnosCasa( dDataFim , dDataIni )                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³No. Anos                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Generico                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fAnosCasa( dDataFim , dDataIni )

Return( Int( NoRound( ( Val( Dtos( dDataFim ) ) - Val( Dtos( dDataIni ) ) ) / 10000 ) ) )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³SRGDESCTP  ³ Autor ³ Mauricio T. Takakura ³ Data ³15/09/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retornar a Descricao do Tipo de Rescisao         			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³Relacao do SRG									    		³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function SRGDESCTP( cTipRes, cChave )

	Local cDescRes	:= ""
	Local nSpace	:= 30

	DEFAULT cTipRes		:= ""
	DEFAULT cChave		:= If( cPaisLoc $ "BRA","32",If(cPaisLoc=="ARG","68","61" ))

	cDescRes := Substr( fDesc("SRX",cChave+cTipRes,"RX_TXT",,SRA->RA_FILIAL) , 1 , nSpace )

Return( cDescRes )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GpTipoRes  |Autor  ³ Leandro Drumond	    ³ Data ³ 05/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria consulta padrão da tabela S043 - Tipo de Rescisao.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GpTipoRes(cCons)
	Local xRet
	Local cCpoRet	:=  "TIPORESC"
	Local nCpn		:= 0

	DEFAULT cCons := "S043"

	If Type('n') =="N"
		nCpn := n
	EndIf

	xRet := Gp310SXB(cCons, cCpoRet, {|| .T. } )

	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	EndIf

	If nCpn > 0
		n := nCpn
	EndIf

	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf

Return( xRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fGLiqRescA 	³ Autor ³ Equipe Advanced RH  ³ Data ³04/03/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Gera liquido pago na rescisao anterior.                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fGLiqRescA()												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGLiqRescA()
	Local aArea			:= GetArea()
	Local aAreaSRG		:= SRG->(GetArea())
	Local nValor		:= 0
	Local nValorFam		:= 0
	Local cMesAnoGer	:= ""	
	Local cVerba		:= aCodFol[126,1]
	Local cVerbaFam		:= aCodFol[034,1]
	Local cVerbaPLR		:= ( fGetCodFol( "0151", .F. ) + '*' + fGetCodFol( "0152", .F. ) + '*' + fGetCodFol( "0300", .F. ) + '*' + fGetCodFol( "0411", .F. ) + '*' + fGetCodFol( "0835", .F. ) + '*' + fGetCodFol( "0836", .F. ) )
	Local lRescPLRMes	:= .F.
	Local lTemDedFam	:= ( Len(aCodFol) >= 1879 .And. !Empty(aCodFol[1879,1]) )
	Local nCont			:= 0

	//Se for complementar para pagamento de PLR, não carrega liquidos das rescisões anteriores
	If lRescPLR .And. !lResAntPLR
		Return
	EndIf

	If lProxMes
		cMesAnoGer := cPeriodo
	Else
		DbSelectArea("SRG")
		DbGoTo(nRegSRG)
		cMesAnoGer :=  MesAno( SRG->RG_DTGERAR )
	EndIf
	SRR->(DbSetOrder(3))

	If SRG->(dbSeek(xFilial("SRG",SRA->RA_FILIAL)+SRA->RA_MAT))
		While SRG->(!Eof() .and. RG_FILIAL + RG_MAT == xFilial("SRG",SRA->RA_FILIAL) + SRA->RA_MAT )
			If MesAno( SRG->RG_DTGERAR ) == cMesAnoGer .And.  SRG->RG_EFETIVA == "S"
				If SRR->( dbSeek( SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS( SRG->RG_DTGERAR ) + cVerba) ) 
					nValor +=SRR->RR_VALOR
				EndIf
				If SRR->( dbSeek( SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS( SRG->RG_DTGERAR ) + cVerbaFam) ) 
					nValorFam += SRR->RR_VALOR
				EndIf
			EndIf
			SRG->(dbSkip())
		EndDo
	EndIf

	For nCont := 1 to Len(aPdResc)
			If aPdResc[nCont,1] $ cVerbaPLR .And. cCompl == "S" .And. AnoMes(aPdResc[nCont,18]) == AnoMes(M->RG_DTGERAR)
				lRescPLRMes		 := .T.
				Exit
			Endif
	Next nCont

	//Se possuir verba de PLR na complementar no mesmo mês não gero o liquido da rescisao anterior
	If nValor > 0 .And. !lRescPLRMes
		fGeraVerba(aCodfol[303,1],nValor)
	EndIf
	//Se possuir verba de salário família na complementar no mesmo mês mas não calculou na rescisão atual gera dedução no ID 1879
	If cPaisLoc == "BRA" .And. nValorFam > 0 .And. !lRescPLRMes .And. ( aScan(aPd, { |x| x[1] == aCodfol[34,1] .And. X[9] # "D"}) == 0 )
		If lTemDedFam
			fGeraVerba(aCodFol[1879,1], nValorFam)
		Else
			AddLogExecRot( STR0005 )//"Não há cadastro de verba para o ID 1879 para a geração da dedução do salário família pago na rescisão original."
			AddLogExecRot( STR0006 )//"Verifique a documentação no TDN disponível em https://tdn.totvs.com/x/BeSLJg para mais informações."
			AddLogExecRot( STR0007 )//"Obs.: o cálculo não será realizado até que seja efetuado o cadastro da verba de ID 1879."
			FinalCalc()
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSRG)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtDCump  ºAutor  ³ Gustavo M.   - P11 º Data ³  26/08/2013 º±±
±±º          ³          º       ³ Claudinei S. - P12 º Data ³  24/11/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza e projeta os dias de aviso Cumprido				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM040 / 		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fAtDCump(lIndeniz,lModel,dDtAvAux)

	Local lRet			:= .T.
	Local nBkpAvi		:= nDiaInde
	Local nBkpCum		:= nDiascum
	Local nAviInf       := 0 // Dias de Aviso Informado.
	Local nAviCum       := 0 // Aviso Cumprido Informado.
	Local nAviInd       := 0 // Aviso Indenizado Informado.
	Local dDataBkp		
	Local dDataBkp1
	
	DEFAULT lIndeniz 	:= .F.
	DEFAULT lModel 		:= .T. //Define se deve carregar as informações no model

	If lModel
		dDataAvi := M->RG_DTAVISO
		If !lIndeniz
			nDiascum := &(ReadVar())
		Else
			nDiaInde := &(ReadVar())
		EndIf
	Else
		dDataAvi := dDtAvAux
	EndIf

	lTemRFY := If(Type("lTemRFY") == "U", .F., lTemRFY)
	
	//Tratativa para que, caso o usuário altere os dias de aviso prévio, assuma o valor alterado e efetue o cálculo com os novos valores.
	If lModel
		nAviInf := M->RG_DAVISO
		nAviCum := M->RG_DAVCUM
		nAviInd := nAviInf - nAviCum

		nDiasAv := nAviInf
		nDiascum := nAviCum
		nDiaInde := nAviInd
	EndiF
	
	If !lTemRFY
		cAvPrev := aIncRes[2]
		If cAvPrev $ 'T*B'
			If nDiascum == 0
				nDiascum := 30
			EndIf
		Endif   
		If  nDiascum > nDiasAv
			Return .F.
		Endif

		If !lIndeniz
			nDiaInde := 0 
			If cAvPrev == 'T' .OR. cAvPrev == 'I' .OR. cAvPrev == 'B'  
				nDiaInde := nDiasAv - nDiascum
			ElseIf cAvPrev == 'A'       
				nDiaInde := (nBkpCum+nBkpAvi) - nDiascum
			Endif
		Else
			If cAvPrev == 'T' .OR. cAvPrev == 'I' .OR. cAvPrev == 'B'      
				nDiasCum := nDiasAv - nDiaInde
			ElseIf cAvPrev == 'A'      
				nDiasCum := nBkpAvi - nDiaInde
			Endif
		Endif	

		If cAvPrev <> 'D'
			dDatadem1:= dDataAvi + nDiasAv - nDiaInde
		Endif

		If lModel
			oModel := FWModelActive()
			oModel:LoadValue("GPEM040_MSRG","RG_DAVISO",nDiasAV)
			If SRG->(ColumnPos( "RG_DAVCUM")) > 0
				oModel:LoadValue("GPEM040_MSRG","RG_DAVCUM",nDiasCum)
				oModel:LoadValue("GPEM040_MSRG","RG_DAVIND",nDiaInde)
			EndIf
			//Se for menor que 30, então quer dizer que alterou os dias cumpridos
			If nAviCum < 30
				oModel:LoadValue("GPEM040_MSRG","RG_DATADEM",dDataAvi + nDiasCum)
				oModel:LoadValue("GPEM040_MSRG","RG_DTGERAR",dDataAvi + nDiasCum)
			Else
				oModel:LoadValue("GPEM040_MSRG","RG_DATADEM",dDataDem1)
				oModel:LoadValue("GPEM040_MSRG","RG_DTGERAR",dDataDem1)
			EndIf
			oModel:LoadValue("GPEM040_MSRG","RG_DTPROAV",dDataDem1+nDiaInde)

			//Calcula dias de ferias
			aPerFerias := {}
			dDataBkp   := dDataDem
			dDataBkp1   := dDataDem1
			If nAviCum < 30
				dDataDem := dDataAvi + nDiasCum
				dDataDem1 := dDataDem
			Else
				dDataDem := dDataDem1
			EndIf
			fdFerRes(.T.,dDataDem)
			dDataDem1 := dDataBkp1
			dDataDem := dDataDem1
			If !SRA->RA_CATFUNC $ "E*G" //Se for estagiario não calcula férias
				oModel:LoadValue("GPEM040_MSRG","RG_DFERVEN", nDferven - nFaltasv)
				oModel:LoadValue("GPEM040_MSRG","RG_DFERPRO", nDferave - nFaltasp)
				oModel:LoadValue("GPEM040_MSRG","RG_DFERAVI", nDferInd)
				
				M->RG_DFERVEN := nDferven - nFaltasv
				M->RG_DFERPRO := nDferave - nFaltasp
	
				If(cPaisLoc == 'BRA')
					M->RG_DFERAVI := nDferInd
				EndIf		
				
			EndIf
		EndIf
	EndIf	

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fCalAPTrab 	³ Autor ³ Marcia Moura    ³ Data ³29/07/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Calcular aviso trabalhado                   				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fCalAvi( aPd , aCodfol , nMedAviso )						³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL 														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³GPEM040   												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fCalAPTrab( aPd , aCodfol , nMedAviso )

	Local nBkpAv	:= 0

	If aIncRes[15]$ "N" 
		nBkpAv  := nDiasAv
		nDiasAv := DiasTrab

		If RetValSRV(aCodfol[112,1],SRA->RA_FILIAL,"RV_BASCAL") <> "2"
			nSalAux := Salario
		Else
			nSalAux := SalMes
		EndIf

		IF nDiasAv > 0
			nValAv  := ( nSalAux / 30 ) * nDiasAv
		Else
			nValAv  := ((dDatadem - M->RG_DTAVISO)+1) * ( nSalAux / 30 )
			nDiasAv := ((dDatadem - M->RG_DTAVISO)+1)
		EndIF

		IF aScan(aPd,{ |X| X[1] = aCodfol[112,1] .and. X[9] # "D" } ) = 0
			fMatriz(aCodfol[112,1],Round(nValav,2),nDiasAv, , ,'V',"R")
		EndIF
		nDiasAv := nBkpAv
	EndIf

Return( NIL )

/*/{Protheus.doc} fSdSalHoVa
Verifica se no APD existem verbas lançadas que devem compor o saldo de salário (Horista com Jornada Variável)
1. Identifica quais são as verbas que estão no grupo 0 e portanto farão média salarial.
2. Verifica se alguma verba do grupo 0 esta no APD, se sim soma ou subtrai as suas horas.
3. Atribui o total de horas para a verba de saldo de salário e exclui as verbas do grupo 0 do APD para evitar duplicidade

@type function

@author Claudinei Soares
@since 05/08/2015
@version P12.1.7

@param APD, array, verbas lançadas
@param APDV, array, incidencias das verbas lançadas

@return Nil
/*/
Function fSdSalHoVa(aPd, aPdv)

	Local cFil			:= xFilial ("SRV")
	Local cVerbas_Aux	:= ""
	Local nPd			:= 0
	Local nPosPd		:= 0
	Local nValPd		:= 0
	Local aPdRat		:= {}
	Local nPdCc 		:= 0
	Local nPdSeq		:= 0
	Local cPdCC 		:= ""
	Local nY			:= 0
	Local lSeq			:= .F.
	Local lMdMesRes     := If( Type("P_SDHOVGR") # "U", P_SDHOVGR, .T. ) 

	IF lMdMesRes
		gp140GrpVerb(cFil,@cVerbas_Aux,"0")
	else
		cVerbas_Aux := aCodFol[32,1]
	Endif

	If Len(cVerbas_Aux) > 0 .And. ASCAN(APD,{ |X| X[1] $ cVerbas_Aux .And. x[1] <> aCodFol[33,1] .And. X[9] # "D"}) > 0 
		For nPd := 1 To Len(APD)
			nValPd := 0
			If APD[nPd,1] $ cVerbas_Aux .And. APD[nPd,1] <> aCodFol[33,1]
				nPosPd := ASCAN(APDV,{ |X| X[1] = APD[nPd,1]  .AND. X[9] # "D" })
				cTipVerba := APDV[nPosPd,27]
				If cTipVerba == "1"
					nValPd += APD[nPd,4]	
				Else
					nValPd -= APD[nPd,4]	
				EndIf
				cPdCC := APD[nPd,2]	
				If (nPdCc := ASCAN(aPdRat,{ |X| X[1] == cPdCC })) == 0
					aAdd(aPdRat,{cPdCC,{{nValPd,nPd,nPosPd,APD[nPd,1],APD[nPd,11]}}}) // Verba que irei modificar
				Else
					lSeq := Empty(APD[nPd,11])
					If (nPdSeq := ASCAN(aPdRat[nPdCc,2],{ |X| If(lSeq,X[5] == "1",X[5] == APD[nPd,11] )})) == 0
						aAdd(aPdRat[nPdCc,2],{nValPd,nPd,nPosPd,APD[nPd,1],APD[nPd,11]}) //Verba de sequencia que modificarei
					Else
						aPdRat[nPdCc,2,nPdSeq,1] += nValPd
						If aPdRat[nPdCc,2,nPdSeq,4] <> APD[nPd,1] //Não é a verba que irei modificar
							Apd[nPd,9] := "D"
							Apdv[nPosPd,9] := "D"
						EndIf
					EndIf
				Endif
			EndIf
		Next nPD

		For nPd := 1 To Len(aPdRat)
			For nY := 1 to Len(aPdRat[nPd,2])
				If APD[aPdRat[nPd,2,ny,2],9] # "D" .And. aPdRat[nPd,2,ny,1] > 0
					APD[aPdRat[nPd,2,ny,2],4] := aPdRat[nPd,2,ny,1]
					APD[aPdRat[nPd,2,ny,2],1] := aCodfol[048,1]
					APDV[aPdRat[nPd,2,ny,3],1] := aCodfol[048,1]
				EndIF
			Next nY
		Next nPd
	EndIf

Return
/*/{Protheus.doc} fAumentSal
Busca os reajustes salariais por dissídio do funcionário.
@type function

@author Claudinei Soares
@since 08/08/2016
@version P11

@param cFil, caracter, filial do funcionario
@param cMatr, caracter, matricula do funcionario
@param cDataIni, caracter, data do Inicio do intervalo a ser pesquisado
@param cDataFim, caracter, data do Fim do intervalo a ser pesquisado
@param dDataDiss, data, data do reajuste por dissídio

@return lógico, Se encontrou algum reajuste por dissídio
/*/
Function fAumentSal(cFil, cMatr, cDataIni, cDataFim, dDataDiss)

	Local aArea			:= GetArea()
	Local cAliasQry 	:=	GetNextAlias()   
	Local cChavePesq	:=	""  
	Local lRet			:= .F. 

	DEFAULT dDataDiss	:= CtoD("//")

	//-- Query que apura as alteracoes salariais ocorridas no mes.
	BeginSql alias cAliasQry
		SELECT SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA, SR3.R3_TIPO, SR3.R3_VALOR, SR3.R3_SEQ
		FROM %table:SR3% SR3
		INNER JOIN %table:RHH% RHH ON SR3.R3_FILIAL = RHH.RHH_FILIAL 
			AND RHH.RHH_MAT = SR3.R3_MAT
			AND SR3.R3_TIPO = RHH.RHH_TPOAUM
			AND RHH.RHH_DATA BETWEEN %exp:Left(cDataIni,6)% AND %exp:Left(cDataFim,6)%
			AND RHH.%notDel%
		WHERE SR3.%notDel% AND SR3.R3_PD = '000' 
			AND SR3.R3_DATA BETWEEN %exp:cDataIni% AND %exp:cDataFim%
			AND SR3.R3_MAT = %exp:cMatr%
		ORDER BY SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA DESC, SR3.R3_SEQ DESC, SR3.R3_TIPO
	EndSql

	//-- Ajusta o campo de data da alteracao salarial
	TCSetField(cAliasQry, "R3_DATA", "D", 8, 0)

	//-- Abre a area dos historicos salariais para pesquisar o penultimo valor antes do aumento
	Dbselectarea("SR3")
	//-- Apura os valores e percentuais das diferencas salarias
	Dbselectarea(cAliasQry)
	While !(cAliasQry)->(eof())
		cChavePesq	:= (cAliasQry)->(cFil+cMatr)
		SR3->(DbSetOrder(2))
		If SR3->( Dbseek(cChavePesq+DTOS((cAliasQry)->(R3_DATA))+(cAliasQry)->(R3_SEQ)+(cAliasQry)->(R3_TIPO))) .And. !lRet
			lRet := .T.
			dDataDiss := (cAliasQry)->(R3_DATA)
		Endif          
		(cAliasQry)->(dbskip())
	Enddo    

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} MedSalInte
Realiza o cálculo da média dos últimos 12 meses das convocações de um funcionário com contrato intermitente para o cálculo do aviso prévio
@author cicero.pereira
@since 27/12/2017
@version 12.1.17
/*/
Function MedSalInte()

	Local cAliasSRD	:= GetNextAlias()
	Local CodPd		:= fGetCodFol( "0318", .F. )
	Local nMeses	:= 0
	Local nValPago	:= 0
	Local nSaldo	:= 0
	Local DatarqAux	:= ""

	BeginSql Alias cAliasSRD

		SELECT RD_VALOR, RD_DATARQ

		FROM %Table:SRD% SRD

		WHERE SRD.RD_FILIAL = %Exp:SRA->RA_FILIAL%
		AND SRD.RD_MAT = %Exp:SRA->RA_MAT%
		AND SRD.RD_DATARQ BETWEEN %Exp:MesAno(YearSub(dDataDem, 1))% AND %Exp:MesAno(dDataDem, 1)%
		AND RD_PD = %Exp:CodPd%
		AND SRD.%NotDel%

		ORDER BY RD_DATARQ

	EndSql

	While ! (cAliasSRD)->(Eof())

		nValPago += (cAliasSRD)->RD_VALOR

		If ! (cAliasSRD)->RD_DATARQ == DatarqAux
			DatarqAux := (cAliasSRD)->RD_DATARQ
			nMeses ++
		EndIf

		(cAliasSRD)->(dbSkip())
	EndDo

	(cAliasSRD)->(dbCloseArea())

	// Busca Convocações no mês da rescisão
	calcConvoc(@nSaldo, @DiasTrab, Nil, Nil, Nil, .T.)

	If nSaldo > 0
		nValPago += nSaldo
		nMeses ++
	EndIf

	If nMeses > 0 
		ACONVOCACAO[4] := nValPago / nMeses
	EndIf

Return

/*/{Protheus.doc} calcConvoc
Realiza o cálculo das convocações no mês da rescisão (Saldo de salário)
@author cicero.pereira
@since 27/12/2017
@version 12.1.17
/*/
Function calcConvoc(nSaldoSal, DiasTrab, nSaldoDSR, nHrsDSR, nHrsCal, lMedia)
	
	Local aConvoc		:= BuscaConv( , GetMemVar("RG_DATADEM"))
	Local lPreenche		:= Empty(aConvRes)
	Local nCont			:= 0
	Local nDsr			:= 0
	Local nBkpSalHor	:= SalHor
	Local nBkpNormal	:= Normal
	Local nBkpDescanso	:= Descanso
	Local nBkpHTrab		:= nHorasTrab
	Local nBkpHDsr		:= nHorasDSR
	Local nTotNorm		:= 0
	Local nTotDesc		:= 0
	Local nTotTrab		:= 0
	Local nTotDsr		:= 0
	
	Default lMedia		:= .F.

	nSaldoSal 	:= 0
	nSaldoDSR	:= 0
	nHrsDSR		:= 0
	nHrsCal		:= 0
	
	For nCont := 1 To Len(aConvoc)
		nDsr		:= 0 
		Normal		:= 0
		Descanso	:= 0
		nHorasTrab	:= 0
		nHorasDsr	:= 0
		SetConvocCalc( aConvoc[nCont, 1], aConvoc[nCont])
		aConvocacao := RetConvoc()
		SalHor		:= aConvoc[nCont, 4]
		DiaDSRInte(@Normal, @Descanso)
		DiasTrab  	:= (Normal + Descanso)
		FCalcDSR(@nDsr, lAdmissao, @nHorasTrab, @nHorasDsr)
		nSaldoSal	+= nSalPg
		nSaldoDSR	+= nDSR
		nTotNorm	+= Normal
		nTotDesc	+= Descanso
		nTotTrab	+= nHorasTrab
		nTotDsr		+= nHorasDsr	
		If lPreenche
			aAdd( aConvRes, { aConvoc[nCont, 1], (nSalPg + nDSR), aConvoc[nCont, 7], Iif(nDiasAfas > 15, (nHorasTrab + nHorasDsr), (Normal + Descanso)) } )
		EndIf
	Next
	 
	If lMedia
		nSaldoSal 	:= Round(nSaldoSal+nSaldoDSR, MSDECIMAIS(1))
		DiasTrab  	:= (nTotNorm + nTotDesc)
	Else
		nSaldoSal 	:= Round(nSaldoSal, MSDECIMAIS(1))
		nSaldoDSR 	:= Round(nSaldoDSR, MSDECIMAIS(1))
		DiasTrab  	:= nTotNorm
		nHrsDSR		:= nTotDesc
	EndIf
	
	If nDiasAfas > 15
		nHrsCal		:= (nTotTrab + nTotDsr)
	Else
		nHrsCal		:= (nTotNorm + nTotDesc)
	EndIf

	SalHor		:= nBkpSalHor
	Normal		:= nBkpNormal
	Descanso	:= nBkpDescanso
	nHorasTrab	:= nBkpHTrab
	nHorasDSR	:= nBkpHDsr

Return

/*/{Protheus.doc} fAnosAfas
Retorna os anos de afastamento do funcionário, para a contagem e abatimento da indenização do aviso prévio.
@author henrique.ferreira
@since 07/05/2018
@version 12.1.17
/*/
Function fAnosAfas( nAnos, dDataAv )

Local DtAdm 		:= SRA->RA_ADMISSA
Local aAfastam  	:= {}
Local dDtFimAf		:= cToD("//")
Local nCntAfast 	:= 0
Local nDiasAfa		:= 0

DEFAULT nAnos 	    := 0
DEFAULT dDataAv     := dDataBase

 //Busco os afastamentos do funcionário, somente de acordo com os tipos contidos no mnemonico.
 fBuscaAfast(SRA->RA_ADMISSA,dDataAv,@aAfastam)
 If Len(aAfastam) > 0
 	For nCntAfast := 1 to Len(aAfastam)
	// Verifca se existe data de término do afastamento preenchida. Caso não esteja preenchida, não será possível fazer a demissão.
		If	!Empty(aAfastam[nCntAfast,2]) .And. aAfastam[nCntAfast,4] <> "F" .And. aAfastam[nCntAfast, 11] > 15 .And. aAfastam[nCntAfast, 10] == SPACE(3)
			nDiasAfa += aAfastam[nCntAfast, 11] //- aAfastam[nCntAfast, 9] // soma os dias de afastamento desconsiderando a parte empresa.
		ElseIf !Empty(aAfastam[nCntAfast,2]) .And. aAfastam[nCntAfast,4] <> "F" .And. aAfastam[nCntAfast, 11] > 15 .And. aAfastam[nCntAfast, 10] <> SPACE(3)
			nConti := aAfastam[nCntAfast, 10]
			nContiPos := Ascan (aAfastam , { |x| x[15]==nConti })	
			If nContiPos > 0 
				If 	aAfastam[nContiPos, 11] > 15 // se afastamento original tiver mais de 15 dias já somado os dias portanto deve-se apenas somar os dias da continuação do afastamento
					nDiasAfa += aAfastam[nCntAfast, 11]
				Else
					nDiasAfa += aAfastam[nCntAfast, 11] + aAfastam[nContiPos, 11]
				Endif
			EndIf
		EndIf
 	Next nCntAfast
 EndIf

If nDiasAfa > 0
	dDtFimAf := DaySub(dDataAv, nDiasAfa) + 1 //Subtraímos da data de demissão os dias de afastamento, desta forma temos uma data demissão somente com os dias trabalhados. Soma +1 para 365 dias de afastamento ser considerado 1 ano.
	nAnos 	 := DateDiffYear(dDtFimAf, DtAdm)
EndIf

Return

/*/{Protheus.doc} fAbatInterm
Verifica se funcionário já teve contrato intermitente anteriormente e abate os valores de férias e 13. já pagos
@author Leandro Drumond
@since 24/05/2019
@version 12.1.17
/*/
Function fAbatInterm()
Local aArea
Local aValAux
Local aVerbas	:= {}
Local aTransf   := {}
Local aFilMat	:= {}
Local cAliasQry
Local cWhere
Local cPerFerIni
Local cPerFerFim
Local cFerIndIni
Local cFerIndFim
Local cPer13Ini
Local cPer13Fim
Local cPdAux	:= ""
Local lFerInter := !Empty(aCodFol[1724,1])
Local l13Inter  := !Empty(aCodFol[1725,1]) .And. cTipoRot != "3"
Local lAchou    := .F.
Local nX		:= 0
Local nY		:= 0
Local nBasFer	:= 0
Local nBas13	:= 0

DEFAULT lContrInt := If(SRC->(ColumnPos( 'RC_CONVOC' )) > 0,.T.,.F.) .and. Len(aCodFol) > 1723 .and. ( !Empty(aCodFol[1724,1]) .or. !Empty(aCodFol[1725,1]) )

If (lFerInter .or. l13Inter) .and. lContrInt .and. SRA->RA_TPCONTR != "3" //Se não for intermitente, verifica se já foi intermitente anteriormente
	aArea := GetArea()
	
	If fTransfFil( @aTransf) //Busca as transferências de filial do funcionário
		aAdd(aFilMat, { SRA->RA_FILIAL , SRA->RA_MAT })
		For nX := 1 To Len(aTransf)
			If AnoMes(aTransf[nX,7]) <= cPeriodo .and. aTransf[nX,2] <> aTransf[nX,5]//Se houve transferência de filial ou matrícula este ano, busca na origem
				aAdd(aFilMat, {aTransf[nX,8], aTransf[nX,9]})
			EndIf
		Next nX
	Else
		aAdd(aFilMat, { SRA->RA_FILIAL , SRA->RA_MAT} )
	EndIf

	DbSelectArea("SV7")
	DbSetOrder(1)

	//Verifica se houve convocação, implicando que existiu contrato intermitente
	For nX := 1 to Len(aFilMat)
		If (lAchou := SV7->(DbSeek(aFilMat[nX,1] + aFilMat[nX,2])))
			Exit
		EndIf
	Next nX
	
	If lAchou
		cAliasQry := GetNextAlias()
		cWhere := "%" 
		If Len(aFilmat) == 1
			cWhere += " SRD.RD_FILIAL = '" + SRA->RA_FILIAL + "' AND "
			cWhere += " SRD.RD_MAT ='" + SRA->RA_MAT + "' AND "
		Else
			cWhere += " ( "
			For nX := 1 to Len(aFilMat)
				cWhere += If(nX == 1, " (", " OR (")
				cWhere += " SRD.RD_FILIAL = '" + aFilMat[nX,1] + "' AND "
				cWhere += " SRD.RD_MAT ='" + aFilMat[nX,2] + "' )"
			Next nX
			cWhere += " ) AND "
		EndIf
		cWhere += " SRD.RD_CONVOC <> '      ' AND "
		cWhere += " SRD.RD_PD IN ('" + aCodFol[24,1] + "','" + aCodFol[72,1] + "','" + aCodFol[77,1] + "') "
		cWhere += "%"

		BeginSql Alias cAliasQry
			SELECT RD_PD, RD_PERIODO, RD_VALOR  FROM  %table:SRD%  SRD
			WHERE %exp:cWhere%
			AND   SRD.%NotDel%
		EndSql

		If (cAliasQry)->(!Eof())
			While (cAliasQry)->( !Eof() )
				aAdd(aVerbas,{RD_PD, RD_VALOR, RD_PERIODO,.F.})
				(cAliasQry)->(DbSkip())
			EndDo
		EndIf

		(cAliasQry)->(DbCloseArea())
		
		If !Empty(aVerbas)
			aValAux := {{},{},{}}
			
			GetLastPerAq(@cPerFerIni,@cPerFerFim) //Per. Aquisivo ferias proporcionais
			
			If ( nX := aScan(aPd,{ |x| x[1] == aCodFol[86,1] .and. x[9] # "D" }) ) > 0
				cFerIndIni := SubStr(aPd[nX,15],1,6)
				cFerIndFim := SubStr(aPd[nX,15],12,6)
			EndIf
			
			cPer13Ini  := SubStr(cPeriodo,1,4) + "01"
			cPer13Fim  := SubStr(cPeriodo,1,4) + "12"

			For nX := 1 to Len(aPd)
				If lFerInter
					If aPd[nX,1] $ aCodFol[86,1] + "/" + aCodFol[125,1] //Férias indenizadas - 1/3 Férias indenizadas
						cPdAux := If(aPd[nX,1] == aCodFol[86,1], aCodFol[72,1], aCodFol[77,1])
						For nY := 1 to Len(aVerbas)
							If aVerbas[nY,1] == cPdAux .and. aVerbas[nY,3] >= cFerIndIni .and. aVerbas[nY,3] <= cFerIndFim
								aVerbas[nY,4] := .T. 
							EndIf 
						Next nY
					ElseIf aPd[nX,1] $ aCodFol[87,1] + "/" + aCodFol[625,1] //Férias proporcionais - 1/3 Férias proporcionais
						cPdAux := If(aPd[nX,1] == aCodFol[87,1], aCodFol[72,1], aCodFol[77,1])
						For nY := 1 to Len(aVerbas)
							If aVerbas[nY,1] == cPdAux .and. aVerbas[nY,3] >= cPerFerIni .and. aVerbas[nY,3] <= cPerFerFim
								aVerbas[nY,4] := .T. 
							EndIf 
						Next nY
					ElseIf aPd[nX,1] $ aCodFol[72,1] + "/" + aCodFol[77,1] //Pagto Ferias - Adicional 1/3 sobre Ferias
						For nY := 1 to Len(aVerbas)
							If aVerbas[nY,1] $ aPd[nX,1] .And. aVerbas[nY,3] >= cPerFerIni .And. aVerbas[nY,3] <= cPerFerFim
								aVerbas[nY,4] := .T. 
							EndIf 
						Next nY
					EndIf
				EndIf
				If l13Inter .and. aPd[nX,1] == aCodFol[114,1] //13. salário
					cPdAux := aCodFol[24,1]
					For nY := 1 to Len(aVerbas)
						If aVerbas[nY,1] == cPdAux .and. aVerbas[nY,3] >= cPer13Ini .and. aVerbas[nY,3] <= cPer13Fim
							aVerbas[nY,4] := .T. 
						EndIf 
					Next nY
				EndIf
			Next nX
			
			//Cria as verbas de base de férias e 13. pagos quando era intermitente
			For nX := 1 to Len(aVerbas)
				If aVerbas[nX,4]
					If aVerbas[nX,1] $ aCodFol[72,1] + "/" + aCodFol[77,1]
						nBasFer += aVerbas[nX,2] 
					Else
						nBas13 += aVerbas[nX,2]
					EndIf						
				EndIf
			Next nX
			
			If lFerInter .and. nBasFer > 0
				fMatriz(aCodFol[1724,1],nBasFer,,,,"V","R")
			EndIf
			
			If l13Inter .and. nBas13 > 0
				fMatriz(aCodFol[1725,1],nBas13,,,,"V","R")
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
EndIf 

Return Nil

/*/{Protheus.doc} GetLastPerAq
Obtem o último período aquisitivo do funcionário
@author Leandro Drumond
@since 27/05/2019
@version 12.1.17
/*/
Static Function GetLastPerAq(cPerFerIni,cPerFerFim)
Local aArea 	:= GetArea()
Local aAreaSRF	:= SRF->(GetArea())

SRF->(DbSetOrder(1))
If SRF->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
	While SRF->(!Eof() .and. RF_FILIAL + RF_MAT == SRA->RA_FILIAL + SRA->RA_MAT)
		cPerFerIni := AnoMes(SRF->RF_DATABAS)
		cPerFerFim := AnoMes(SRF->RF_DATAFIM)
		SRF->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
RestArea(aArea)

Return Nil

/*/{Protheus.doc} fIncSemId
//Se a verba deve ser calcula pelo salario incorporado, retorna o valor do Mnemonico NINCSEMID, que tem o valor das verbas sem id com incorporação de salario
@author flavio.scorrea
@since 24/07/2019
@param cId, characters, ID da verba
@return return, valor
/*/
Function fIncSemId(cId)
Local nValor := 0

If RetValSrv(cId, SRA->RA_FILIAL, "RV_BASCAL",2) == "2"
	nValor := NINCSEMID
EndIf

Return nValor

/*/{Protheus.doc} fFgtsVA
//FGTS contrato verde amarelo , categoria 108
@author flavio.scorrea
@since 24/12/2019
@param cId, characters, ID da verba
@return return, valor
/*/
Function fFgtsVA()
Local nValor 	:= 0
Local nBase		:= 0
Local nPerc		:= 0.20
Local aTab		:= {}
Local nPosTab	:= 0

fCarrTab(@aTab,"S043")	//Tabela de tipos de rescisao	
nPosTab := fPosTab("S043","A","==",7,,,) // Tipo de Rescisao
If nPosTab <> 0 
   nPerc := fTabela("S043",nPosTab,16) / 100
EndIf

aEval( aPd ,{ |X| SomaInc(X,5,@nBase,6,"S", , , , ,aCodFol) })

If nBase != 0 .And. Mod(nBase*100,2) == 0
	nValor := NoRound((nBase * (SRA->RA_PERFGTS / 100)) * nPerc, 2) + 0.01
Else
	nValor := NoRound((nBase * (SRA->RA_PERFGTS / 100)) * nPerc, 2)
EndIf
fMatriz(aCodfol[1731,1],nValor)

Return nValor

/*/{Protheus.doc} fAbatVA
Verifica se funcionário já teve multa FGTS descontada e abate
@author Flavio Correa
@since 02/01/2020
/*/
Function fAbatVA()
Local aArea
Local cAliasQry
Local cWhere	:= ""
Local nValMulta	:= 0

If (SRA->RA_CATEFD $ '107/108') .and. Len(aCodFol) >= 1731 .and. !Empty(aCodFol[1731,1])
	aArea := GetArea()
	cAliasQry := GetNextAlias()
	cWhere := "%" 
	cWhere += " SRD.RD_FILIAL = '" + SRA->RA_FILIAL + "' AND "
	cWhere += " SRD.RD_MAT ='" + SRA->RA_MAT + "' AND "
	cWhere += " SRD.RD_PD =  '" + aCodFol[1731,1] + "'"
	cWhere += "%"

	BeginSql Alias cAliasQry
		SELECT Sum(RD_VALOR) AS VALOR  FROM  %table:SRD%  SRD
		WHERE %exp:cWhere%
		AND   SRD.%NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		nValMulta := (cAliasQry)->(VALOR)
	EndIf
	(cAliasQry)->(DbCloseArea())
	
	RestArea(aArea)
EndIf 

Return nValMulta

/*/{Protheus.doc} fEstab936
Verifica se funcionário está no período de estabilidade da MP 936/2020
@author Allyson Mesashi
@since 23/09/2020
/*/
Function fEstab936( dDataFim, dFimEstab, nPerEstab )

Local aAfastSus		:= {}
Local cPPECod		:= ""
Local dFimAcord		:= cToD("//")
Local nContPPE		:= 0
Local nDiasAcor		:= 0
Local nDiasAnt		:= 0
Local nDiasDiff		:= 0
Local nDiasPror		:= 0
Local nDiasTot		:= 0
Local nCont			:= 0
Local nPerRed		:= 0
Local nPosTab		:= 0

Default dDataFim 	:= dDatabase
Default dFimEstab 	:= cToD("//")
Default nPerEstab	:= 0

fInssResEx()
fRetAfas( CtoD("01/03/2020"), dDataFim,,,,, @aAfastSus)

For nContPPE := 1 To Len(aPPE)
	If aPPE[ nContPPE, 1 ] == "1" .And. !(aPPE[nContPPE, 5] $ "1/2")//RGE_PPE|RGE_STATUS
		If !Empty(dFimAcord) 
			nDiasDiff := aPPE[nContPPE, 2] - (dFimAcord+nDiasAcor)
			If nDiasDiff > 1
				If nContPPE > 1 .and. ( nCont := aScan(aAfastSus, {|x| x[3] > aPPE[nContPPE - 1, 3] .and. x[4] < aPPE[nContPPE, 2]}) ) > 0 .and. Posicione("RCM", 1, xFilial("RCM", SRA->RA_FILIAL) + aAfastSus[nCont, 13], "RCM_TPEFD") == "37"
					nDiasAcor -= ( ( aAfastSus[nCont,3] - aPPE[nContPPE - 1, 3] ) - 1 )
					nDiasAcor -= ( ( aPPE[nContPPE, 2] - aAfastSus[nCont,4] ) - 1 )
					nDiasAcor +=  aAfastSus[nCont, 4] - aAfastSus[nCont, 3] + 1
				Else
					nDiasAcor := 0
				EndIf
			ElseIf (aPPE[nContPPE, 2] - (dFimAcord+1)) != 0
				nDiasAcor -= nDiasAnt
				nDiasAcor += DateDiffDay( aPPE[nContPPE, 2]-1, dFimAcord+nDiasAnt )
			EndIf
		EndIf
		dFimAcord 	:= aPPE[nContPPE, 3]//RGE_DATAFI
		nDiasAcor	+= aPPE[nContPPE, 3] - aPPE[nContPPE, 2] + 1
		nDiasAnt	:= aPPE[nContPPE, 3] - aPPE[nContPPE, 2] + 1
		nDiasPror 	:= 0
		cPPECod		:= aPPE[nContPPE, 4]//RGE_COD
		nPosTab 	:= fPosTab("S061", cPPECOD, "==", 4)
		If nPosTab > 0
			If aPPE[nContPPE, 5] == "3"
				nDiasPror := fTabela("S061", nPosTab, 12)//Dias de prorrogação
				nDiasAcor += nDiasPror
				nDiasAnt  += nDiasPror
			EndIf
			nPerRed	:= fTabela("S061", nPosTab, 8)	//Percentual de reducao
			If nPerRed >= 25 .And. nPerRed < 50
				nPerEstab := 0.5
			ElseIf nPerRed >= 50 .And. nPerRed < 70
				nPerEstab := 0.75
			ElseIf nPerRed >= 70 .Or. Empty(nPerRed)
				nPerEstab := 1
			EndIf
			dFimAcord	:= DaySum( dFimAcord, nDiasPror )			
		Else
			dFimAcord 	:= cToD("//")
		EndIf
	EndIf
Next nContPPE
nDiasTot	:= Max(nDiasAcor,0)

For nCont := 1 To Len(aAfastSus)
	If Posicione("RCM", 1, xFilial("RCM", SRA->RA_FILIAL) + aAfastSus[nCont, 13], "RCM_TPEFD") == "37" .And. aAfastSus[nCont, 4] > dFimAcord
		If !Empty(dFimAcord)
			nDiasDiff := aAfastSus[nCont, 3] - (dFimAcord+nDiasAnt)
			If nDiasDiff > 1
				nDiasTot  -= nDiasAnt
			ElseIf (aAfastSus[nCont, 3] - (dFimAcord+1)) != 0
				nDiasTot  -= nDiasAnt
				nDiasTot  += DateDiffDay( aAfastSus[nCont, 3]-1, dFimAcord+nDiasAnt )
			EndIf
		EndIf
		dFimAcord 	:= aAfastSus[nCont, 4]//SR8->R8_DATAFIM
		nDiasTot	+= aAfastSus[nCont, 4] - aAfastSus[nCont, 3] + 1
		nDiasAnt	:= aAfastSus[nCont, 4] - aAfastSus[nCont, 3] + 1
		nPerEstab	:= 1
	EndIf
Next nCont
If !Empty(dFimAcord)
	dFimEstab	:= DaySum( dFimAcord, nDiasTot )
	//Se existiu licença maternidade no período de estabilidade, paralisa a estabilidade pelos dias de licença maternidade e soma os dias restantes ao final.
	aEval(aAfastSus, {|x| If(x[16] $ "Q1*Q2*Q3*Q4*Q5*Q6" .and. x[3] > dFimAcord .and. x[3] < dFimEstab, ( nDiasTot := nDiasTot - (x[3] - (dFimAcord + 1)), dFimAcord := x[4], dFimEstab := DaySum( dFimAcord, nDiasTot )) , Nil)})
EndIf

Return

/*/{Protheus.doc} fBuscaPdHist
Verifica a existência de determinada verba no histórico
@author Leandro Drumond
@since 26/02/2021
/*/
Function fBuscaPdHist(dDataAux, cVerba)
Local aArea		:= GetArea()
Local cQuery    := ""
Local cAliasAux := GetNextAlias()
Local cPerAux   := SubStr(DtoS(dDataAux),1,6)
Local lRet		:= .F.

Static __oSt
Static __cEmpAux

If __oSt == Nil .or. __cEmpAux == Nil .or. __cEmpAux <> cEmpAnt

	__oSt := FWPreparedStatement():New()

	cQuery := "SELECT COUNT(*) AS CONTADOR "
	cQuery += "FROM " + RetSqlName("SRD")+ " SRD "
	cQuery += "WHERE SRD.RD_FILIAL = ? AND "
	cQuery += "SRD.RD_PD = ? AND "
	cQuery += "SRD.RD_PERIODO <= ? AND "
	cQuery += "SRD.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
		
	__oSt:SetQuery(cQuery)
	__cEmpAux := cEmpAnt

EndIf

__oSt:SetString(1,SRA->RA_FILIAL)
__oSt:SetString(2,cVerba)
__oSt:SetString(3,cPerAux)

cQuery := __oSt:getFixQuery()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux)

If (cAliasAux)->( !Eof() ) .and.  (cAliasAux)->CONTADOR > 0
	lRet := .T.
EndIf

(cAliasAux)->(dbCloseArea())

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fFer13oInt
Calcula férias e 13º salário de intermitente na rescisão
@author Allyson Mesashi
@since 25/02/2021
/*/
Function fFer13oInt( nBase, l13Sal, lAviso )

Local nCont		:= 0
Local nFer13o	:= 0
Local nVal13Ats := 0
Local nVal13Ins := 0
Local nVal13Per := 0
Local nVal13Con := 0
Local nVal13Tra := 0
Local lAdcsResc := Len(aCodFol) >= 1680 .And. !Empty(aCodFol[1680,1])
Local cRefFer   := GETMVRH("MV_REFFER",NIL,"A")

DEFAULT nBase	:= 0
DEFAULT l13Sal  := .F.
DEFAULT lAviso  := .F.

For nCont := 1 To Len(aConvRes)
	nBase	+= aConvRes[nCont, 2]
	nFer13o += ( aConvRes[nCont, 2] / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4]) ) * aConvRes[nCont, 4]
	If !lAviso
		If nAdtServ > 0
			nVal13Ats += Max( ( ( nAdtServ / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4] )) * aConvRes[nCont, 4] ),0)
		EndIf
		If nIntInsal > 0
			nVal13Ins += Max( ( ( nIntInsal / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4] )) * aConvRes[nCont, 4] ),0)
		EndIf
		If nIntPercul > 0
			nVal13Per += Max( ( ( nIntPercul / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4] )) * aConvRes[nCont, 4] ),0)
		EndIf
		If nAdcConf > 0
			nVal13Con += Max( ( ( nAdcConf / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4] )) * aConvRes[nCont, 4] ),0)
		EndIf
		If nAdcTrf > 0
			nVal13Tra += Max( ( ( nAdcTrf / 12 / Max( aConvRes[nCont, 3] * nDiasC, aConvRes[nCont, 4] )) * aConvRes[nCont, 4] ),0)
		EndIf
	EndIf
Next nCont

If !lAdcsResc .Or. (cCompl == "S" .And. !LTEMIDRESC)		
	nFer13o += Round(nVal13Ats,2) + Round(nVal13Ins,2) + Round(nVal13Per,2) + Round(nVal13Con,2) + Round(nVal13Tra,2)
Else
	If l13Sal
		If lAviso
			If nAdtServ > 0
				nVal13Ats += nAdtServ / P_QTDIAMES * ( nDiasAv / 12 )
				fMatriz(aCodfol[1709,1],Round(nVal13Ats,2),1.12, , ,"V","R") 	//ATS 13 Aviso Indenizado					 
			EndIf
			If nIntInsal > 0
				nVal13Ins += nIntInsal / P_QTDIAMES * ( nDiasAv / 12 )
				fMatriz(aCodfol[1697,1],Round(nVal13Ins,2),1.12, , ,"V","R")	//Insal 13 Aviso Indenizado
			EndIf
			If nIntPercul > 0
				nVal13Per += nIntPercul / P_QTDIAMES * ( nDiasAv / 12 )
				fMatriz(aCodfol[1685,1],Round(nVal13Per,2),1.12, , ,"V","R")	//Peric 13 Aviso Indenizado
			EndIf
			If nAdcConf > 0
				nVal13Con += nAdcConf / P_QTDIAMES * ( nDiasAv / 12 )
				fMatriz(aCodfol[1721,1],Round(nVal13Con,2),1.12, , ,"V","R")	//Confi 13 Aviso Indenizado				
			EndIf
			If nAdcTrf > 0
				nVal13Tra += nAdcTrf / P_QTDIAMES * ( nDiasAv / 12 )
				fMatriz(aCodfol[1715,1],Round(nVal13Tra,2),1.12, , ,"V","R")	//Transf 13 Aviso Indenizado.
			EndIf			
		Else
			fMatriz(aCodfol[1708,1],Round(nVal13Ats,2),Int(nAvos)+0.12, , ,"V","R") //ATS 13 Indenizado					 
			fMatriz(aCodfol[1696,1],Round(nVal13Ins,2),Int(nAvos)+0.12, , ,"V","R")	//Insal 13 Indenizado
			fMatriz(aCodfol[1684,1],Round(nVal13Per,2),Int(nAvos)+0.12, , ,"V","R")	//Peric 13 Indenizado
			fMatriz(aCodfol[1720,1],Round(nVal13Con,2),Int(nAvos)+0.12, , ,"V","R")	//Confi 13 Indenizado				
			fMatriz(aCodfol[1714,1],Round(nVal13Tra,2),Int(nAvos)+0.12, , ,"V","R")	//Transf 13 Indenizado.
		EndIf
	Else
		fMatriz(aCodfol[1705,1],Round(nVal13Ats,2),IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( GETMEMVAR("RG_DFERPRO") / ATABFER[4] ) + 0.12), , ,"V","R") //ATS 13 Indenizado					 
		fMatriz(aCodfol[1693,1],Round(nVal13Ins,2),IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( GETMEMVAR("RG_DFERPRO") / ATABFER[4] ) + 0.12), , ,"V","R")	//Insal 13 Indenizado
		fMatriz(aCodfol[1681,1],Round(nVal13Per,2),IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( GETMEMVAR("RG_DFERPRO") / ATABFER[4] ) + 0.12), , ,"V","R")	//Peric 13 Indenizado
		fMatriz(aCodfol[1717,1],Round(nVal13Con,2),IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( GETMEMVAR("RG_DFERPRO") / ATABFER[4] ) + 0.12), , ,"V","R")	//Confi 13 Indenizado				
		fMatriz(aCodfol[1711,1],Round(nVal13Tra,2),IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( GETMEMVAR("RG_DFERPRO") / ATABFER[4] ) + 0.12), , ,"V","R")	//Transf 13 Indenizado.
	EndIf
EndIf

Return nFer13o

/*/{Protheus.doc} fcheckRGB
Returna se o registro da chave existe na RGB considerando a data de referência
@author fernando.guilherme
@since 22/02/2021
@version P12
@param 
/*/
Static Function fcheckRGB()
	Local aArea		:= GetArea()
	Local aAreaRGB	:= RGB->( GetArea() )
	Local lAchou    := .F.
	Local cChaveRGB := ""	

	cChaveRGB := SRA->RA_FILIAL + cProcesso + SRA->RA_MAT + cPeriodo + cSemana +cRoteiro + fGetCodFol( "0151", .F. ) + SRA->RA_CC
	
	DbSelectArea("RGB")
	RGB->( DbSetOrder(RetOrder("RGB","RGB_FILIAL + RGB_PROCES + RGB_MAT + RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_PD + RGB_CC")) )			
	If RGB->( DbSeek( AllTrim(cChaveRGB) ) )
		cDadosRGB := "RGB->( RGB_FILIAL + RGB_PROCES + RGB_MAT + RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_PD + RGB_CC )"
		While RGB->( !EOF() .and. RGB_FILIAL + RGB_PROCES + RGB_MAT + RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_PD + RGB_CC == cChaveRGB )
			If RGB->RGB_TIPO2 $ "I"
				lAchou := .T.
				Exit
			EndIf

			RGB->( DbSkip() )
		EndDo
	EndIf

	RestArea (aAreaRGB)
	RestArea(aArea)

Return lAchou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtuRGB    ºAutor  ³Leandro Drumond    º Data ³  12/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza incidencias para roteiro rescisao      			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAtuRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag)

	Local aArea		:= GetArea()
	Local cKeyRGB	:= cFil + cProcesso + cMat + cPeriodo + cNumPag
	Local cKeyAtu	:= ""
	Local cDataAux	:= ""
	Local cRotRES	:= fGetCalcRot("4")
	Local cSeqAux	:= "1"
	Local nRecRGB	:= 0
	Local lAtuRGB	:= .T.

	DbSelectArea("RGB")
	DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)"))

	If DbSeek(cKeyRGB)
		While RGB->( !Eof() .and. RGB_FILIAL + RGB_PROCES + RGB_MAT + RGB_PERIOD + RGB_SEMANA == cKeyRGB )
			If RGB->RGB_ROTEIR == cRotRES .OR. RGB->RGB_ROTORI == cRotRES
				RGB->(DbSkip())
				Loop
			EndIf

			lAtuRGB := .T.
			nRecRGB := Recno()
			cKeyAtu := cKeyRGB + cRotRES + RGB_PD + RGB_CC + RGB_ITEM + RGB_CLVL
			cDataAux:= DtoS(RGB_DTREF)
			cSeqAux	:= "1"

			While lAtuRGB
				If DbSeek(cKeyAtu + cSeqAux	+ cDataAux)
					cSeqAux := Soma1(cSeqAux)
				Else
					lAtuRGB := .F.
				EndIf			
			EndDo

			DbGoTo(nRecRGB)
			
			RecLock("RGB",.F.)
			RGB_ROTORI := If(Empty(RGB->RGB_ROTORI), RGB_ROTEIR, RGB->RGB_ROTORI)
			RGB_ROTEIR := cRotRes
			RGB_SEQ	   := cSeqAux
			MsUnLock()

			DbSeek(cKeyRGB)
		EndDo
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fTemCompl
Retorna se há rescisão complementar no mesmo período que gerou a verba de ID 0303 ou se na rescisão original foi gerado insuficiência de saldo e na complementar do mesmo mês há líquido
/*/
Static Function fTemCompl( cFilMat, cPerDem, nRecSRG, cChaveSRR, nOrdemSRR )

Local lTemComp	:= .F.
Local lTemInsuf	:= .F.

SRR->( dbSetOrder(1) )//RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC+RR_PROCES
lTemInsuf := SRR->( dbSeek( cFilMat+"R"+dToS(SRG->RG_DTGERAR)+fGetCodFol("0045", .F.) ) )
SRR->( dbSetOrder(nOrdemSRR) )

While SRG->( !Eof() ) .And. SRG->RG_FILIAL+SRG->RG_MAT == cFilMat
	If SRG->(Recno()) <> nRecSRG .and. SRG->RG_EFETIVA == "S" .And. AnoMes( SRG->RG_DTGERAR ) == cPerDem .And. SRG->RG_RESCDIS != "0" .And. ( SRR->( dbSeek(cChaveSRR+fGetCodFol("0303", .F.))) .Or. ( lTemInsuf .And. SRR->( dbSeek( cChaveSRR+fGetCodFol("0126", .F.) ) ) ) )
		lTemComp	:= .T.
		Exit
	EndIf
	SRG->(DbSkip())
EndDo

SRG->( dbGoTo( nRecSRG ) )

Return lTemComp
