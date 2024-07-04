#INCLUDE	"Protheus.ch"
#INCLUDE	"FWMVCDEF.CH"
#INCLUDE	"MNTA651.ch"

//---------------------------------------------------------------------
/*/MNTA651
Cadastro de Transfer�ncias de Combust�vel entre Postos.

TABELAS:
SB1 - Produtos
SB2 - Saldo em Estoque
SD3 - Movimenta��o no Estoque
SD4 - Requisi��es Empenhadas
TQF - Postos
TQI - Tanques de Combust�veis
TQJ - Bombas de Combust�veis
TQM - Tipos de Combust�veis
TTV - Contador da Bomba
TTX - Motivos de Sa�da de Combust�vel
TUI - Cadastro de Transfer�ncias entre Postos

@author Wagner Sobral de Lacerda
@since 23/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651()

	Local aNGBEGINPRM
	Local oBrowse

	If FindFunction( 'MNTAmIIn' ) .And. !MNTAmIIn( 95 )
		Return .F.
	EndIf

	aNGBEGINPRM := NGBEGINPRM()

	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	If !MNTA651OP()
		Return .F.
	EndIf

	// Declara as Vari�veis PRIVATE
	MNTA651VAR()

	//----------------
	// Monta o Browse
	//----------------
	dbSelectArea("TUI")
	dbSetOrder(1)
	dbGoTop()

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()

		// Defini��o da tabela do Browse
		oBrowse:SetAlias("TUI")

		// Defini��o da legenda
		MNTA651LEG(@oBrowse)

		// Descri��o do Browse
		oBrowse:SetDescription(cCadastro)

		// Menu Funcional relacionado ao Browse
		oBrowse:SetMenuDef("MNTA651")

	// Ativa��o da Classe
	oBrowse:Activate()
	//----------------
	// Fim do Browse
	//----------------

	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	// Retorna a Empresa e Filial iniciais
	fPrepTbls(, .T.)

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 23/02/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.MNTA651" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MNTA651" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MNTA651" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "MNTA651EST()"	 OPERATION 4 ACCESS 0 // "Estornar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MNTA651" OPERATION 5 ACCESS 0 // "Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651OP
Valida o programa, verificando se � poss�vel execut�-lo. (MNTA651Open)
* Est� fun��o pode ser utilizada por outras rotinas.

@author Wagner Sobral de Lacerda
@since 24/02/2012

@return .T. caso o programa possa ser executado; .F. no caso de uma falha e o programa n�o puder ser executado
/*/
//---------------------------------------------------------------------
Function MNTA651OP()

	Local lParam := ( SuperGetMv("MV_NGDPST9",.F.,"0") == "2" )
	Local cMotTra := AllTrim(SuperGetMv("MV_NGMOTTR"))

	Private lHelp := .F. // Vari�vel private para o fun��o 'FWAliasInDic()' mostrar (.T.) ou nao (.F.) uma mensagem de Help caso a tabela n�o exista


	DbSelectArea("TTX")
	DbSetOrder(01)
	If !DbSeek(xFilial("TTX")+(cMotTra))
		MsgInfo(STR0039+CRLF+CRLF+STR0040)//"N�o existe cadastrado um registro de Motivo de Transfer�ncia igual ao definido no parametro MV_NGMOTTR (C�digo do Motivo de Transfer�ncias de Combust�vel)."##"Configure corretamente o par�metro para continuar."
		Return .F.
	EndIf

	If !lParam
		MsgInfo(STR0041) //"Para o correto funcionamento do processo ExcelBr, o par�metro MV_NGDPST9 que indica se podera duplicar c�digo do Bem deve estar configurado com o valor 2(Por Filial)."
		Return .F.
	EndIf

	// A Integra��o com o Estoque � obrigat�rio para esta rotina
	If AllTrim(SuperGetMV("MV_NGMNTES", .F., "N")) <> "S"
		Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
				STR0007,; // "Para utilizar esta rotina, � obrigat�rio que o sistema esteja com a Integra��o com o Estoque habilitada."
				1, 0)
		Return .F.
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DO < MODELO > * MVC                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 24/02/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local cAuxOriDes := ""
	Local cAuxCampo  := ""
	Local cAuxGrupo  := ""
	Local nX := 0

	Local aTrigger := {}

	// Estrutura da tabela TUI do Modelo de Dados
	Local oStruTUI := FWFormStruct(1, "TUI", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de Dados
	Local oModel

	// Verifica a vers�o da Release.
	Local lRPORel17 := GetRPORelease() <= '12.1.017'

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA651", /*bPreValid*/, {|oModel| fMPosValid(oModel) }/*bPosValid*/, {|oModel| fMCommit(oModel) }/*bFormCommit*/, /*bFormCancel*/)

		//------------------------------
		// Componentes do Modelo
		//------------------------------

		// Adiciona ao Modelo um componente de Formul�rio Principal
		oModel:AddFields("TUIMASTER" /*cID*/, /*cIDOwner*/, oStruTUI/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)

		// Define a descri��o do Modelo
		oModel:GetModel("TUIMASTER"):SetDescription(STR0008) // "Transfer�ncias de Combust�vel"

		// Define a descri��o do Modelo
		oModel:SetDescription(STR0008) // "Transfer�ncias de Combust�vel"

		If lRPORel17
			//------------------------------
			// Defini��o de campos MEMO VIRTUAIS
			//------------------------------
			FWMemoVirtual(oStruTUI, { {"TUI_CODOBS", "TUI_OBSERV"} } )
		EndIf

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit
Grava��o manual do Modelo de Dados.

@author Wagner Sobral de Lacerda
@since 02/03/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fMCommit(oModel)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Esturutra do Modelo
	Local oModelTUI := oModel:GetModel("TUIMASTER")

	// Vari�veis com os valores dos campos do Modelo
	Local cCodigo	 := oModelTUI:GetValue("TUI_CODIGO")
	Local dDataTrans := oModelTUI:GetValue("TUI_DATA")
	Local cHoraTrans := oModelTUI:GetValue("TUI_HORA")
	Local cStatTrans := oModelTUI:GetValue("TUI_STATUS")
	Local cEmpOrigi  := oModelTUI:GetValue("TUI_EMPORI")
	Local cFilOrigi  := oModelTUI:GetValue("TUI_FILORI")
	Local cPostoOrig := oModelTUI:GetValue("TUI_POSORI")
	Local cLojaOrig  := oModelTUI:GetValue("TUI_LOJORI")
	Local cTanquOrig := oModelTUI:GetValue("TUI_TANORI")
	Local cCombuOrig := oModelTUI:GetValue("TUI_COMORI")
	Local cSaidaOrig := oModelTUI:GetValue("TUI_SAIORI")
	Local cBombaOrig := oModelTUI:GetValue("TUI_BOMORI")
	Local nQuantidad := oModelTUI:GetValue("TUI_QUANTI")
	Local cEmpDesti  := oModelTUI:GetValue("TUI_EMPDES")
	Local cFilDesti  := oModelTUI:GetValue("TUI_FILDES")
	Local cPostoDest := oModelTUI:GetValue("TUI_POSDES")
	Local cLojaDest  := oModelTUI:GetValue("TUI_LOJDES")
	Local cTanquDest := oModelTUI:GetValue("TUI_TANDES")
	Local cCombuDest := oModelTUI:GetValue("TUI_COMDES")
	Local cProduOrig := oModelTUI:GetValue("TUI_PROORI")
	Local cProduDest := oModelTUI:GetValue("TUI_PRODES")

	// Vari�veis para a Movimenta��o no Estoque
	Local cNumDocSD3 := ""
	Local lEstornar  := IsInCallStack("MNTA651EST")
	Local lEstornoOk := lEstornar

	// Vari�veis para gravar Negocia��o e Pre�o
	Local aTQG := {}, nTQG := 0
	Local aTQH := {}, nTQH := 0
	Local nQtdeRegs  := 0 // Quantidade de Registros a serem retrocedidos
	Local cPreNeg 	 := 0
	Local cPreBom 	 := 0
	Local cNameUsr	 := UsrRetName(RetCodUsr())
	Local dDataNeg 	 := ""
	Local cHoraNeg 	 := ""
	Local dDataPre 	 := ""
	Local cHoraPre 	 := ""
	Local cNumSeq1 	 := '', cNumSeq2 := ''
	Local aTabelas 	 := { {"SB1"}, {"SB2"}, {"SD3"}, {"SD4"}, {"TQF"}, {"TQG"}, {"TQH"}, {"TQI"}, {"TQJ"}, {"TQM"}, {"TTV"}, {"TTX"} }
	Local aRet       := {}
	Local lRet       := .T.

	Private cPRSB2Ori := SuperGetMv( "MV_NGPRSB2",,,cFilOrigi)
	Private cPRSB2Des := SuperGetMv( "MV_NGPRSB2",,,cFilDesti)
	Private cNumSeOrig := oModelTUI:GetValue("TUI_NSEORI")
	Private cNumSeDest := oModelTUI:GetValue("TUI_NSEDES")

	Private lGerNegPre := .F.
 	
	 //------------------------------------------------------------------------
	 // Verifica se deve gerar negocia��o e pre�o
	 // para mesmo posto e combust�vel n�o deve gerar pois ser� o mesmo valor
	 //------------------------------------------------------------------------
	If cPRSB2Des == 'N' .And. (;
		cEmpOrigi + cFilOrigi + cPostoOrig + cLojaOrig + cCombuOrig != 	;
		cEmpDesti + cFilDesti + cPostoDest + cLojaDest + cCombuDest)

		lGerNegPre := .T.
	EndIf

	// Vari�veis Private utlizadas por fun��es de outras rotinas
	Private cCusMed  := SuperGetMV("MV_CUSMED", .F., "") // Utilizada no MATA240, pela fun��o 'A240DesAtu()'

	// Prepara a Empresa e Filial originais
	NGPrepTbl(aTabelas,cEmpOrigi, cFilInicia)

	//--------------------------------------------------
	// Grava��o Personalizada
	//--------------------------------------------------

	// Atualiza o Estoque apenas se o Status for 'Normal'
	If cStatTrans == "1"

		If nOperation == 3 // Inclus�o

			//------------------------------
			// Movimenta��o do Estoque ORIGEM
			//------------------------------
			// Prepara a Empresa e Filial
			NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

			If cEmpOrigi + cFilOrigi == cEmpDesti + cFilDesti

				aRet := aClone( MNT651TRAN( dDataTrans, cProduOrig, cTanquOrig, nQuantidad, cProduDest, cTanquDest, 3 ) )

				If !aRet[1]

					oModel:SetErrorMessage( 'TUIMASTER', , , , STR0006, aRet[2] ) // Aten��o
					l651Final := .F.
					lRet      := .F.

				EndIf

			Else

				//------------------------------
				// Movimenta��o do Estoque ORIGEM
				//------------------------------
				// Prepara a Empresa e Filial
				NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

				// Realiza o D�BITO (requisi��o) na empresa e filial origem
				cNumDocSD3 := NextNumero("SD3", 2, "D3_DOC", .T.)
				cNumSeOrig := MntMovEst("RE0"/*cCodigo*/, cTanquOrig/*cAlmoxarifado*/, cProduOrig/*cProduto*/, nQuantidad/*nQuantidade*/, dDataTrans/*dData*/, cNumDocSD3/*cDocumento*/, Nil/*cFilMov*/, Nil/*cCCusto*/, .F./*lEstorno*/, /*cNumSeq*/)

				//------------------------------
				// Movimenta��o do Estoque DESTINO
				//------------------------------
				// Prepara a Empresa e Filial
				NGPrepTbl(aTabelas,cEmpDesti, cFilDesti)

				// Realiza o CR�DITO (devolu��o) na empresa e filial destino
				cNumDocSD3 := NextNumero("SD3", 2, "D3_DOC", .T.)
				cNumSeDest := MntMovEst("DE0"/*cCodigo*/, cTanquDest/*cAlmoxarifado*/, cProduDest/*cProduto*/, nQuantidad/*nQuantidade*/, dDataTrans/*dData*/, cNumDocSD3/*cDocumento*/, Nil/*cFilMov*/, Nil/*cCCusto*/, .F./*lEstorno*/, /*cNumSeq*/)

			EndIf

			NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

		ElseIf nOperation == 5 .Or. lEstornar // Exclus�o ou Estorno

			//------------------------------
			// Movimenta��o do Estoque ORIGEM
			//------------------------------
			// Prepara a Empresa e Filial
			NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

			If cEmpOrigi + cFilOrigi == cEmpDesti + cFilDesti

				aRet := aClone( MNT651TRAN( dDataTrans, cProduOrig, cTanquOrig, nQuantidad, cProduDest, cTanquDest, 4,;
				 cNumSeOrig ) )

				If !aRet[1]

					oModel:SetErrorMessage( 'TUIMASTER', , , , STR0006, aRet[2] ) // Aten��o
					l651Final := .F.
					lRet      := .F.

				EndIf

			Else

				//------------------------------
				// Movimenta��o do Estoque ORIGEM
				//------------------------------
				// Prepara a Empresa e Filial
				NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

				// Realiza o CR�DITO (devolu��o) na empresa e filial origem, anulando assim a transfer�ncia
				If NGIFDBSEEK("SD3", cProduOrig + cTanquOrig + DtoS(dDataTrans) + cNumSeOrig, 7) //D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_NUMSEQ
					cNumSeq1 := SD3->D3_NUMSEQ
					cNumSeq2 := MntMovEst("RE0"/*cCodigo*/, SD3->D3_LOCAL/*cAlmoxarifado*/, SD3->D3_COD/*cProduto*/, SD3->D3_QUANT/*nQuantidade*/, SD3->D3_EMISSAO/*dData*/, SD3->D3_DOC/*cDocumento*/, Nil/*cFilMov*/, Nil/*cCCusto*/, .T./*lEstorno*/, /*cNumSeq*/cNumSeOrig)
					lEstornoOk := !Empty(cNumSeq2)
				EndIf


				If !Empty(cNumSeq2) .And. lEstornoOk
				    //------------------------------
					// Movimenta��o do Estoque DESTINO
					//------------------------------
					// Prepara a Empresa e Filial
					NGPrepTbl(aTabelas,cEmpDesti, cFilDesti)

					// Realiza o D�BITO (requisi��o) na empresa e filial destino, anulando assim a transfer�ncia
					If NGIFDBSEEK("SD3", cProduDest + cTanquDest + DtoS(dDataTrans) + cNumSeDest, 7) //D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_NUMSEQ
						MntMovEst("DE0"/*cCodigo*/, SD3->D3_LOCAL/*cAlmoxarifado*/, SD3->D3_COD/*cProduto*/, SD3->D3_QUANT/*nQuantidade*/, SD3->D3_EMISSAO/*dData*/, SD3->D3_DOC/*cDocumento*/, Nil/*cFilMov*/, Nil/*cCCusto*/, .T./*lEstorno*/, /*cNumSeq*/cNumSeDest)
					EndIf
				EndIf

			EndIf

		EndIf

	EndIf

	If lRet

		If nOperation == 3

			//--------------------------------------------------
			// Grava��o do Modelo de Dados
			//--------------------------------------------------
			FWFormCommit( oModel )

			dbSelectArea( 'TUI')
			dbSetOrder( 1 )
			If dbSeek( xFilial( 'TUI' ) + cCodigo )

				RecLock( 'TUI', .F. )
					TUI->TUI_NSEORI := cNumSeOrig
					TUI->TUI_NSEDES := cNumSeDest
				TUI->( MsUnlock() )

			EndIf

		ElseIf lEstornoOk

			RecLock( 'TUI', .F. )
				TUI->TUI_STATUS := '2' // Estornada
			TUI->( MsUnlock() )

			//--------------------------------------------------
			// Grava��o do Modelo de Dados
			//--------------------------------------------------
			FWFormCommit( oModel )

		ElseIf nOperation == 5 .Or. !lEstornar

			//--------------------------------------------------
			// Grava��o do Modelo de Dados
			//--------------------------------------------------
			FWFormCommit( oModel )

		EndIf

		//------------------------------
		// Atualiza o Status da Transfer�ncia
		//------------------------------
		NGPrepTbl(aTabelas,cEmpDesti, cFilInicia)

		//------------------------------
		// Contador da Bomba
		//------------------------------
		If nOperation == 3 .Or.;
			((nOperation == 5 .Or. lEstornar))// .And. lEstornoOk)

			// Se a sa�da de combust�vel for pela Bomba, incrementa o contador
			If cSaidaOrig == "1"
				// Prepara a Empresa e Filial
				NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

				If nOperation == 3
					// Incrementar o Contador da Bomba (via Aferi��o de Bomba)
					NGIncTTV(cPostoOrig, cLojaOrig, cTanquOrig, cBombaOrig, dDataTrans, cHoraTrans, "5", Nil, nQuantidad, Nil)
				Else
					// Deleta o Contador da Bomba
					If NGIFDBSEEK("TTV", cPostoOrig + cLojaOrig + cTanquOrig + cBombaOrig + DTOS(dDataTrans) + cHoraTrans, 1)
						NGDelTTV()
					EndIf
				EndIf
			EndIf

		EndIf

		//------------------------------
		// Negocia��o e Pre�o Negociado
		//------------------------------
		// APENAS PARA O POSTO DESTINO
		If nOperation == 5 .Or. lEstornar

			NGPrepTbl(aTabelas,cEmpDesti, cFilDesti)

				// Deleta a Negocia��o do Posto Destino
				dbSelectArea("TQG")
				dbSetOrder(3)
				If dbSeek(xFilial("TQG") + cCodigo)
					RecLock("TQG", .F.)
					dbDelete()
					MsUnlock("TQG")
				EndIf

				// Deleta o Pre�o Negociado do Posto Destino
				dbSelectArea("TQH")
				dbSetOrder(5)
				If dbSeek(xFilial("TQH") + cCodigo)
					RecLock("TQH", .F.)
					dbDelete()
					MsUnlock("TQH")
				EndIf

		Else

			// Prepara a Empresa e Filial Origem
			NGPrepTbl(aTabelas,cEmpOrigi, cFilOrigi)

			// Recebe a �ltima Negocia��o do Posto Origem, de acordo com a Data e Hora da Transfer�ncia
			aTQG := {}
			nQtdeRegs := 2
			dbSelectArea("TQG")
			dbSetOrder(1)
			dbSeek(xFilial("TQG") + cPostoOrig + cLojaOrig + DTOS(dDataTrans) + cHoraTrans, .T.)

			While !Bof() .And. nQtdeRegs > 0

				If TQG->TQG_FILIAL == xFilial("TQG") .And. TQG->TQG_CODPOS == cPostoOrig .And. TQG->TQG_LOJA == cLojaOrig .And. ;
					( TQG->TQG_DTNEG < dDataTrans .Or. ( TQG->TQG_DTNEG == dDataTrans .And. TQG->TQG_HRNEG <= cHoraTrans ) )

					dDataNeg := TQG->TQG_DTNEG
					cHoraNeg := TQG->TQG_HRNEG

					aAdd(aTQG, {"TQG->TQG_FILIAL", cFilDesti			})					  // 1  - Filial
					aAdd(aTQG, {"TQG->TQG_CODPOS", cPostoDest			})					  // 2  - C�digo do Posto
					aAdd(aTQG, {"TQG->TQG_LOJA"  , cLojaDest			})					  // 3  - Loja do Posto
					aAdd(aTQG, {"TQG->TQG_DTNEG" , If(!lMVPreSB2,dDataNeg,dDataTrans)})  // 4  - Data da Negocia��o
					aAdd(aTQG, {"TQG->TQG_HRNEG" , If(!lMVPreSB2,cHoraNeg,cHoraTrans )}) // 5  - Hora da Negocia��o
					aAdd(aTQG, {"TQG->TQG_ORDENA", TQG->TQG_ORDENA	})					  // 6  - Ordena��o
					aAdd(aTQG, {"TQG->TQG_CODTRA", cCodigo        		})					  // 7  - C�digo da Transfer�ncia
					aAdd(aTQG, {"TQG->TQG_PRAZO"	 , TQG->TQG_PRAZO		})					  // 8  - N� Dias Pgto
					aAdd(aTQG, {"TQG->TQG_DIAFAT", TQG->TQG_DIAFAT	})					  // 9  - N� Dias Fat.
					aAdd(aTQG, {"TQG->TQG_DIALIM", TQG->TQG_DIALIM	})					  // 10 - N�D.Envio F
					aAdd(aTQG, {"TQG->TQG_CONTAT", TQG->TQG_CONTAT	})					  // 11 - Contato
					aAdd(aTQG, {"TQG->TQG_FUNCAO", TQG->TQG_FUNCAO	})					  // 12 - Fun��o

					nQtdeRegs := 0
				EndIf

				nQtdeRegs--

				dbSelectArea("TQG")
				dbSkip(-1)
			End

			// Recebe o �ltimo Pre�o Negociado do Posto Origem, de acordo com a Data e Hora da Transfer�ncia
			aTQH := {}
			nQtdeRegs := 2
			dbSelectArea("TQH")
			dbSetOrder(1)
			dbSeek(xFilial("TQH") + cPostoOrig + cLojaOrig + cCombuOrig + DTOS(dDataTrans) + cHoraTrans, .T.)

			While !Bof() .And. nQtdeRegs > 0

				If TQH->TQH_FILIAL == xFilial("TQH") .And. TQH->TQH_CODPOS == cPostoOrig .And. TQH->TQH_LOJA == cLojaOrig .And. TQH->TQH_CODCOM == cCombuOrig .And. ;
					( TQH->TQH_DTNEG < dDataTrans .Or. ( TQH->TQH_DTNEG == dDataTrans .And. TQH->TQH_HRNEG <= cHoraTrans ) )

					dDataPre	:= TQH->TQH_DTNEG
					cHoraPre	:= TQH->TQH_HRNEG
					cPreNeg	:= TQH->TQH_PRENEG
					cPreBom 	:= TQH->TQH_PREBOM

					If cPRSB2Ori == 'S' .And. cPRSB2Des == 'N'
						DbSelectArea("SB2")
						DbSetOrder(01)
						DbSeek(cFilOrigi+cProduOrig+cTanquOrig)
						cPreNeg := SB2->B2_CM1
						cPreBom := SB2->B2_CM1
					EndIf

					aAdd(aTQH, {"TQH->TQH_FILIAL", cFilDesti					})			// 1 - Filial
					aAdd(aTQH, {"TQH->TQH_CODPOS", cPostoDest					})			// 2 - C�digo do Posto
					aAdd(aTQH, {"TQH->TQH_LOJA"  , cLojaDest					})			// 3 - Loja do Posto
					aAdd(aTQH, {"TQH->TQH_CODCOM", cCombuDest					})			// 4 - C�digo do Combust�vel
					aAdd(aTQH, {"TQH->TQH_DTNEG" , If(!lMVPreSB2,dDataPre,dDataTrans)})// 5 - Data da Negocia��o
					aAdd(aTQH, {"TQH->TQH_HRNEG" , If(!lMVPreSB2,cHoraPre,cHoraTrans)})// 6 - Hora da Negocia��o
					aAdd(aTQH, {"TQH->TQH_PREBOM", cPreBom						})			// 7 - Pre�o da Bomba
					aAdd(aTQH, {"TQH->TQH_PRENEG", cPreNeg						}) 			// 8 - Pre�o Negociado
					aAdd(aTQH, {"TQH->TQH_DESCON", TQH->TQH_DESCON			}) 			// 9 - Desconto
					aAdd(aTQH, {"TQH->TQH_DTATUA", TQH->TQH_DTATUA			}) 			// 10 - Data de Atualiza��o
					aAdd(aTQH, {"TQH->TQH_USUARI", cNameUsr					}) 			// 11 - Usu�rio
					aAdd(aTQH, {"TQH->TQH_ORDENA", TQH->TQH_ORDENA			}) 			// 12 - Ordena��o
					aAdd(aTQH, {"TQH->TQH_CODTRA", cCodigo						})			// 13 - C�digo da Transfer�ncia

					nQtdeRegs := 0
				EndIf

				nQtdeRegs--

				dbSelectArea("TQH")
				dbSkip(-1)
			End

			// Prepara a Empresa e Filial Destino
			NGPrepTbl(aTabelas,cEmpDesti, cFilDesti)

			// Grava a Negocia��o do Posto Destino
			If Len(aTQG) > 0 .And. lGerNegPre
				dbSelectArea("TQG")
				dbSetOrder(1)
				If !dbSeek(xFilial("TQG") + cPostoDest + cLojaDest + DTOS(aTQG[4][2]) + aTQG[5][2])
					RecLock("TQG", .T.)
				Else
					RecLock("TQG", .F.)
				EndIf
				For nTQG := 1 To Len(aTQG)
					If "_FILIAL" $ aTQG[nTQG][1]
						&(aTQG[nTQG][1]) := xFilial("TQG",aTQG[nTQG][2])
					Else
						&(aTQG[nTQG][1]) := aTQG[nTQG][2]
					EndIf
				Next nTQG
				MsUnlock("TQG")
			EndIf

			// Grava o Pre�o Negociado do Posto Destino
			If Len(aTQH) > 0 .And. lGerNegPre
				dbSelectArea("TQH")
				dbSetOrder(1)
				If !dbSeek(xFilial("TQH") + cPostoDest + cLojaDest + cCombuDest + DTOS(aTQH[5][2]) + aTQH[6][2])
					RecLock("TQH", .T.)
				Else
					RecLock("TQH", .F.)
				EndIf
				For nTQH := 1 To Len(aTQH)
					If "_FILIAL" $ aTQH[nTQH][1]
						&(aTQH[nTQH][1]) := xFilial("TQH",aTQH[nTQH][2])
					Else
						&(aTQH[nTQH][1]) := aTQH[nTQH][2]
					EndIf
				Next nTQH
				MsUnlock("TQH")
			EndIf

		EndIf

	EndIf

	// Devolve Empresa e Filial
	NGPrepTbl(aTabelas,cEmpDesti, cFilInicia)

Return lRet

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DA < VIEW > * MVC                                                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 24/02/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cAuxOriDes := ""
	Local cAuxGrupo  := ""
	Local nX := 0

	// Objeto do Modelo de Dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("MNTA651")

	// Estrutura da tabela TUI da View
	Local oStruTUI := FWFormStruct( 2, "TUI", , .F., , .F., )

	// View
	Local oView

	// Cria o objeto da View
	oView := FWFormView():New()

		// Define o Modelo de Dados utilizado pela View
		oView:SetModel(oModel)

		// Valida a Inicializa��o da View
		oView:SetViewCanActivate({|oView| fVActivate(oView) }/*bBloclVld*/)

		//------------------------------
		// Propriedades das Esturutras da View
		//------------------------------

		// Define o Agrupamento dos Campos
		// Grupos:
		//  - Dados da Transfer�ncia
		//  - Posto Origem
		//  - Posto Destino
		oStruTUI:AddGroup("GRP_DADOS"  /*cID*/, STR0009/*cTitulo*/, ""/*cIDFolder*/, 2/*nType*/) // "Dados da Transfer�ncia"
		oStruTUI:AddGroup("GRP_ORIGEM" /*cID*/, STR0010/*cTitulo*/, ""/*cIDFolder*/, 2/*nType*/) // "Posto Origem"
		oStruTUI:AddGroup("GRP_DESTINO" /*cID*/, STR0011/*cTitulo*/, ""/*cIDFolder*/, 2/*nType*/) // "Posto Destino"

			// Colocando todos os campos para o agrupamento Principal
			oStruTUI:SetProperty("*"/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, "GRP_DADOS"/*xValue*/)

			// Trocando alguns campos para outros campos
			For nX := 1 To 2
				cAuxOriDes := If(nX == 1, "ORI", "DES")
				cAuxGrupo  := If(nX == 1, "GRP_ORIGEM", "GRP_DESTINO")

				oStruTUI:SetProperty("TUI_EMP" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_FIL" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_POS" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_LOJ" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_TAN" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				If nX == 1 //Somente no Posto Origem
					oStruTUI:SetProperty("TUI_BOM" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				EndIf
				oStruTUI:SetProperty("TUI_COM" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_PRO" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
				oStruTUI:SetProperty("TUI_NSE" + cAuxOriDes/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, cAuxGrupo/*xValue*/)
			Next nX

			oStruTUI:SetProperty("TUI_SAIORI"/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, "GRP_ORIGEM"/*xValue*/)
			oStruTUI:SetProperty("TUI_QUANTI"/*cIDField*/, MVC_VIEW_GROUP_NUMBER/*nProperty*/, "GRP_ORIGEM"/*xValue*/)

		// Retira alguns campos da esturutra da View
		oStruTUI:RemoveField("TUI_CODOBS")
		oStruTUI:RemoveField("TUI_FILIAL")

		//------------------------------
		// Componentes da View
		//------------------------------

		// Adiciona a View um controle do tipo Formul�rio
		oView:AddField("VIEW_TUIMASTER"/*cFormModelID*/, oStruTUI/*oViewStruct*/, "TUIMASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona um "Outro" tipo de objeto, o qual n�o faz necessariamente parte do Modelo
		oView:AddOtherObject("VIEW_INFORM_ORIGEM" /*cFormModelID*/, {|oPanel| fOtherInfo(oPanel, 1) }/*bActivate*/, {|oPanel| If(ValType(oPanel) == "O", oPanel:FreeChildren(), ) }/*bDeActivate*/, /*bRefresh*/)
		oView:AddOtherObject("VIEW_INFORM_DESTINO"/*cFormModelID*/, {|oPanel| fOtherInfo(oPanel, 2) }/*bActivate*/, {|oPanel| If(ValType(oPanel) == "O", oPanel:FreeChildren(), ) }/*bDeActivate*/, /*bRefresh*/)

		//----------
		// Layout
		//----------

		// Cria os componentes "Box" Horizontais que cont�m os elementos da View
		oView:CreateHorizontalBox("BOX_TRANSF"/*cID*/, 060/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFORM"/*cID*/, 040/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

			// Cria os componentes "Box" Verticais que cont�m os elementos da View
			oView:CreateVerticalBox("BOX_INFORM_ORIGEM" /*cID*/, 050/*nPercHeight*/, "BOX_INFORM"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			oView:CreateVerticalBox("BOX_INFORM_DESTINO"/*cID*/, 050/*nPercHeight*/, "BOX_INFORM"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

		// Relaciona o "Box" com um elemento da View
		oView:SetOwnerView("VIEW_TUIMASTER"     /*cFormModelID*/, "BOX_TRANSF"        /*cIDUserView*/)
		oView:SetOwnerView("VIEW_INFORM_ORIGEM" /*cFormModelID*/, "BOX_INFORM_ORIGEM" /*cIDUserView*/)
		oView:SetOwnerView("VIEW_INFORM_DESTINO" /*cFormModelID*/, "BOX_INFORM_DESTINO"/*cIDUserView*/)

		// Adiciona um T�tulo para a View
		oView:EnableTitleView("VIEW_INFORM_ORIGEM" , STR0032) // "Informa��es: Posto Origem"
		oView:EnableTitleView("VIEW_INFORM_DESTINO", STR0033) // "Informa��es: Posto Destino"

		//------------------------------
		// Defini��es finais da View
		//------------------------------

		// Ac��es da View
		oView:SetViewAction("BUTTONOK"    , {|oView| fPrepTbls(, .T.) })
		oView:SetViewAction("BUTTONCANCEL", {|oView| fPrepTbls(, .T.) })

		// A��es de P�s-Valida��o dos Campos da View
		oView:SetFieldAction("TUI_DATA"  /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TUI_HORA"  /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		For nX := 1 To 2
			cAuxOriDes := If(nX == 1, "ORI", "DES")

			oView:SetFieldAction("TUI_FIL" + cAuxOriDes/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
			oView:SetFieldAction("TUI_POS" + cAuxOriDes/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
			oView:SetFieldAction("TUI_LOJ" + cAuxOriDes/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
			oView:SetFieldAction("TUI_TAN" + cAuxOriDes/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
			oView:SetFieldAction("TUI_COM" + cAuxOriDes/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		Next nX
		oView:SetFieldAction("TUI_SAIORI" /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TUI_QUANTI" /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldAction
Define uma a��o a ser executada quando um campo � Alterado/Validado
com sucesso.

@author Wagner Sobral de Lacerda
@since 29/02/2012

@param oView
	Objeto da View * Obrigat�rio
@param cIDView
	ID da da View * Obrigat�rio
@param cField
	Campo acionado * Obrigat�rio
@param xValue
	Valor atual do campo * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFieldAction(oView, cIDView, cField, xValue)

	Local oModelTUI := oView:GetModel("TUIMASTER")

	Local aCposEstoq := {} // Campos que atualiza��o as informa��es do Estoque
	Local aCposBomba := {} // Campos que atualiza��o as informa��es da Bomba

	If cField == "TUI_TANORI"
		oModelTUI:SetValue('TUI_COMORI', Space(Len(M->TUI_COMORI )))
		oModelTUI:SetValue('TUI_PROORI', Space(Len(M->TUI_PROORI )))
		oModelTUI:SetValue('TUI_NSEORI', Space(Len(M->TUI_NSEORI )))
		oModelTUI:SetValue('TUI_BOMORI', Space(Len(M->TUI_BOMORI )))
		oModelTUI:SetValue('TUI_QUANTI', 0)
		cOriComNom := ""
		cOriProDes := ""
		cOriProUni := ""
		nOriSalCom := 0
	ElseIf cField == "TUI_TANDES"
		oModelTUI:SetValue('TUI_COMDES', Space(Len(M->TUI_COMDES )))
		oModelTUI:SetValue('TUI_PRODES', Space(Len(M->TUI_PRODES )))
		oModelTUI:SetValue('TUI_NSEDES', Space(Len(M->TUI_NSEDES )))
	EndIf

	If cField == "TUI_FILORI"
		oModelTUI:SetValue('TUI_POSORI', Space(Len(M->TUI_POSORI )))
		oModelTUI:SetValue('TUI_LOJORI', Space(Len(M->TUI_LOJORI )))
		oModelTUI:SetValue('TUI_TANORI', Space(Len(M->TUI_TANORI )))
		oModelTUI:SetValue('TUI_COMORI', Space(Len(M->TUI_COMORI )))
		oModelTUI:SetValue('TUI_PROORI', Space(Len(M->TUI_PROORI )))
		oModelTUI:SetValue('TUI_NSEORI', Space(Len(M->TUI_NSEORI )))
		oModelTUI:SetValue('TUI_BOMORI', Space(Len(M->TUI_BOMORI )))
		oModelTUI:SetValue('TUI_QUANTI', 0)
		cOriPosNom := ""
		cOriComNom := ""
		cOriProDes := ""
		cOriProUni := ""
		nOriSalCom := 0
		nOriFimCom := 0
		cOriTipPos := ""
	ElseIf cField == "TUI_FILDES"
		oModelTUI:SetValue('TUI_POSDES', Space(Len(M->TUI_POSDES )))
		oModelTUI:SetValue('TUI_LOJDES', Space(Len(M->TUI_LOJDES )))
		oModelTUI:SetValue('TUI_TANDES', Space(Len(M->TUI_TANDES )))
		oModelTUI:SetValue('TUI_COMDES', Space(Len(M->TUI_COMDES )))
		oModelTUI:SetValue('TUI_PRODES', Space(Len(M->TUI_PRODES )))
		oModelTUI:SetValue('TUI_NSEDES', Space(Len(M->TUI_NSEDES )))
		cDesPosNom := ""
		cDesComNom := ""
		cDesProDes := ""
		cDesProUni := ""
		nDesSalCom := 0
		nDesFimCom := 0
	EndIf

	//------------------------------
	// Estoque
	//------------------------------
	aAdd(aCposEstoq, "TUI_DATA")
	aAdd(aCposEstoq, "TUI_HORA")

	aAdd(aCposEstoq, "TUI_POSORI")
	aAdd(aCposEstoq, "TUI_LOJORI")
	aAdd(aCposEstoq, "TUI_TANORI")
	aAdd(aCposEstoq, "TUI_COMORI")

	aAdd(aCposEstoq, "TUI_QUANTI")

	aAdd(aCposEstoq, "TUI_POSDES")
	aAdd(aCposEstoq, "TUI_LOJDES")
	aAdd(aCposEstoq, "TUI_TANDES")
	aAdd(aCposEstoq, "TUI_COMDES")

	//------------------------------
	// Bomba
	//------------------------------
	aAdd(aCposBomba, "TUI_SAIORI")

	//------------------------------
	// Atualiza
	//------------------------------
	If aScan(aCposEstoq, {|x| x == cField }) > 0
		fAtuEstoq( If("ORI" $ cField, 1, 2) )
	EndIf
	If aScan(aCposBomba, {|x| x == cField }) > 0
		// Limpa o conte�do da Bomba
		oModelTUI:LoadValue("TUI_BOMORI", Space( TAMSX3("TUI_BOMORI")[1] ))
	EndIf

	oView:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651EST
Monta View para o Estorno da Transfer�ncia.

@author Wagner Sobral de Lacerda
@since 07/03/2012

@return nOk 0 - Confirma��o; 1 - Cancelamento
/*/
//---------------------------------------------------------------------
Function MNTA651EST()

	Local nOk := 1

	If TUI_STATUS == '3'
		MsgInfo(STR0037,STR0038)//"N�o � poss�vel realizar estorno do registro de transfer�ncia, pois n�o houve movimenta��o de estoque."##"Opera��o Inv�lida"
		Return .F.
	EndIf

	// o FWExecView retorna 0 em caso de Confirma��o, e 1 no caso de Cancelamento
	nOk := FWExecView(STR0004/*cTitulo*/, "MNTA651"/*cPrograma*/, MODEL_OPERATION_UPDATE/*nOperation*/, /*oDlg*/,; // "Estornar"
		{|| .T. }/*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)

Return nOk

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DOS "OTHER OBJECT" PARA A VIEW DO * MVC                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fOtherInfo
Monta as Informa��es do Posto Origem.

@author Wagner Sobral de Lacerda
@since 24/02/2012

@param oPanel
	Painel pai dos objetos * Obrigat�rio
@param nOriDes
	Indica se o painel � do Posto Origem ou Destino * Obrigat�rio
	   1 - Origem
	   2 - Destino

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fOtherInfo(oPanel, nOriDes)

	Local aAreaSX3 := SX3->( GetArea() )

	// Objetos
	Local oPnlPai := Nil
	Local oScroll := Nil

	Local oFontBold := TFont():New(, , , , .T.) // Fonte em Negrito

	Local oPnlBack := Nil
	Local nColorBack := RGB(250, 250, 250)

	// Vari�veis auxiliares para montar o painel
	Local cAuxOriDes := If(nOriDes == 1, "ORI", "DES")
	Local cAuxTitulo := ""
	Local cAuxSetVr  := ""
	Local cAuxSetGet := ""

	Local nPosTop := If(INCLUI, 0, 15)
	Local nBckWid := 0, nBckHei := 0
	Local nPaiWid := 0, nPaiHei := 0

	// Tamanhos dos campos em Tela
	Local nGetPOSTO  := 0
	Local nGetLOJA   := 0
	Local nGetNOME   := 0
	Local nGetCOMBUS := 0
	Local nGetNOMCOM := 0

	Local nGetPRODUT := 0
	Local nGetDESCRI := 0
	Local nGetUNIDAD := 0
	Local nGetALMOXA := 0
	Local nGetSALATU := 0
	Local nGetSALRET := 0

	Local aCampos := { "TQF_CODIGO", "TQF_LOJA", "TQF_NREDUZ", "TQI_CODCOM", "TQM_NOMCOM",;
					 "B1_COD", "B1_DESC", "B1_UM", "B1_LOCPAD", "B2_QATU", "TUI_QUANTI"}
	Local aVals   := {}

	Local nInd       := 0
	Local nTamTot    := 0

	// Recebe os Tamanhos dos campos em Tela
	nTamTot := Len(aCampos)
	For nInd := 1 To nTamTot

		If !Empty( Posicione("SX3",2, aCampos[nInd], "X3_CAMPO") )
			aAdd( aVals, CalcFieldSize( Posicione("SX3",2, aCampos[nInd], "X3_TIPO"), Posicione("SX3",2, aCampos[nInd], "X3_TAMANHO"),;
									Posicione("SX3",2, aCampos[nInd], "X3_DECIMAL"), AllTrim(Posicione("SX3",2, aCampos[nInd], "X3_PICTURE")),;
									AllTrim(Posicione("SX3",2, aCampos[nInd], "X3Titulo()")) ) )
		Else
			aAdd( aVals,0)
		EndIF

	Next nInd

	// Adiciona os tamanhos recebidos nas variaveis.
	nGetPOSTO  := aVals[1]
	nGetLOJA   := aVals[2]
	nGetNOME   := aVals[3]
	nGetCOMBUS := aVals[4]
	nGetNOMCOM := aVals[5]
	nGetPRODUT := aVals[6]
	nGetDESCRI := aVals[7]
	nGetUNIDAD := aVals[8]
	nGetALMOXA := aVals[9]
	nGetSALATU := aVals[10]
	nGetSALRET := aVals[11]

	// Cria o Scroll no Painel Principal da View
	oScroll := TScrollBox():New(oPanel, 0, 0, 0, 0, .T., .T., .T.)
	oScroll:nClrPane := nColorBack
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	oScroll:CoorsUpdate()

		nBckWid := ( oScroll:nClientWidth * 0.493)
		nBckHei := ( oScroll:nClientHeight * 0.485)

		nPaiWid := 250
		nPaiHei := 155-nPosTop

		// Apenas cria o Painel de fundo se estiver sobrando espa�o em tela
		If nPaiWid <= nBckWid .Or. nPaiHei <= nBckHei
			// Painel de Fundo
			oPnlBack := TPanel():New(0, 0, , oScroll, , , , CLR_BLACK, nColorBack, nBckWid, nBckHei, .F., .F.)
		EndIf

		// Painel Pai das Informa��es
		oPnlPai := TPanel():New(0, 0, , oScroll, , , , CLR_BLACK, nColorBack, nPaiWid, nPaiHei, .F., .F.)

			// Posto
			cAuxSetVr  := "TUI_POS" + cAuxOriDes
			cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
			cAuxReadVr := "'" + cAuxSetVr + "'"
			@ 010,010 SAY OemToAnsi(AllTrim( RetTitle("TQF_CODIGO") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
			TGet():New(009, 055, &(cAuxSetGet), oPnlPai, nGetPOSTO, 008, "",;
							{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
							.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)
			// Loja
			cAuxSetVr  := "TUI_LOJ" + cAuxOriDes
			cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
			cAuxReadVr := "'" + cAuxSetVr + "'"
			@ 010,147 SAY OemToAnsi(AllTrim( RetTitle("TQF_LOJA") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
			TGet():New(009, 170, &(cAuxSetGet), oPnlPai, nGetLOJA, 008, "",;
							{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
							.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

			// Nome Reduzido (Fantasia)
			cAuxSetVr  := If(nOriDes == 1, "cOriPosNom", "cDesPosNom")
			cAuxSetGet := "{|| " + cAuxSetVr + " }"
			cAuxReadVr := "'" + cAuxSetVr + "'"
			@ 025,010 SAY STR0035 FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
			TGet():New(024, 055, &(cAuxSetGet), oPnlPai, nGetNOME, 008, "",;
							{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
							.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

			// Combust�vel
			cAuxSetVr  := "TUI_COM" + cAuxOriDes
			cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
			cAuxReadVr := "'" + cAuxSetVr + "'"
			@ 040,010 SAY OemToAnsi(AllTrim( RetTitle("TQI_CODCOM") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
			TGet():New(039, 055, &(cAuxSetGet), oPnlPai, nGetCOMBUS, 008, "",;
							{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
							.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)
			cAuxSetVr  := If(nOriDes == 1, "cOriComNom", "cDesComNom")
			cAuxSetGet := "{|| " + cAuxSetVr + " }"
			cAuxReadVr := "'" + cAuxSetVr + "'"
			TGet():New(039, 105, &(cAuxSetGet), oPnlPai, nGetNOMCOM, 008, "",;
							{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
							.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

			// Situa��o do Estoque
			@ 060,010 SAY If (nOriDes==1,"Situa��o do Produto no Estoque de Origem:","Situa��o do Produto no Estoque de Destino:") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL // "Situa��o do Produto no Estoque de Origem:"

				// Produto
				cAuxSetVr  := "TUI_PRO" + cAuxOriDes
				cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
				cAuxReadVr := "'" + cAuxSetVr + "'"
				@ 075,015 SAY OemToAnsi(AllTrim( RetTitle("B1_COD") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
				TGet():New(074, 060, &(cAuxSetGet), oPnlPai, nGetPRODUT, 008, "",;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

				// Descri��o
				cAuxSetVr  := If(nOriDes == 1, "cOriProDes", "cDesProDes")
				cAuxSetGet := "{|| " + cAuxSetVr + " }"
				cAuxReadVr := "'" + cAuxSetVr + "'"
				@ 090,015 SAY OemToAnsi(AllTrim( RetTitle("B1_DESC") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
				TGet():New(089, 060, &(cAuxSetGet), oPnlPai, nGetDESCRI, 008, "",;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

				// Unidade de Medida
				cAuxSetVr  := If(nOriDes == 1, "cOriProUni", "cDesProUni")
				cAuxSetGet := "{|| " + cAuxSetVr + " }"
				cAuxReadVr := "'" + cAuxSetVr + "'"
				@ 105,015 SAY OemToAnsi(AllTrim( RetTitle("B1_UM") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
				TGet():New(104, 060, &(cAuxSetGet), oPnlPai, nGetUNIDAD/*nGetALMOXA*/, 008, "",;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)
				// Armazenamento Padr�o (Almoxarifado/Local) (no caso de Postos, � o TANQUE)
				cAuxSetVr  := "TUI_TAN" + cAuxOriDes
				cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
				cAuxReadVr := "'" + cAuxSetVr + "'"
				@ 105,130 SAY OemToAnsi(AllTrim( RetTitle("B1_LOCPAD") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
				TGet():New(104, 175, &(cAuxSetGet), oPnlPai, nGetALMOXA, 008, "",;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

				If INCLUI
					// Saldo Atual
					cAuxSetVr  := If(nOriDes == 1, "nOriSalCom", "nDesSalCom")
					cAuxSetGet := "{|| " + cAuxSetVr + " }"
					cAuxReadVr := "'" + cAuxSetVr + "'"
					@ 120,015 SAY OemToAnsi(AllTrim( RetTitle("B2_QATU") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
					TGet():New(119, 060, &(cAuxSetGet), oPnlPai, nGetSALATU, 008, PesqPict("SB2", "B2_QATU", ),;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

					// Saldo a Retirar/Debitar
					cAuxTitulo := "OemToAnsi('" + If(nOriDes == 1, STR0013, STR0014) + "')" // "Saldo a Debitar:" ### "Saldo a Creditar:"
					cAuxSetVr  := "TUI_QUANTI"
					cAuxSetGet := "{|| MNT651FGET( '" + cAuxSetVr + "') }"
					cAuxReadVr := "'" + cAuxSetVr + "'"
					@ 120,130 SAY &(cAuxTitulo) FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
					TGet():New(119, 175, &(cAuxSetGet), oPnlPai, nGetSALRET, 008, PesqPict("TUI", "TUI_QUANTI", ),;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

					// Saldo ap�s a Transfer�ncia ser conclu�da
					cAuxSetVr  := If(nOriDes == 1, "nOriFimCom", "nDesFimCom")
					cAuxSetGet := "{|| " + cAuxSetVr + " }"
					cAuxReadVr := "'" + cAuxSetVr + "'"
					@ 135,015 SAY OemToAnsi(STR0015) FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL // "Saldo ap�s a Transfer�ncia:"
					TGet():New(134, 100, &(cAuxSetGet), oPnlPai, nGetSALATU, 008, PesqPict("SB2", "B2_QATU", ),;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)
				Else
					// Saldo Transferido
					cAuxSetVr  := "TUI_QUANTI"
					cAuxSetGet := "{|| If(MNT651FGET( 'TUI_STATUS') == '1', " + cAuxSetVr + ", 0) }"
					cAuxReadVr := "'" + cAuxSetVr + "'"
					@ 120,015 SAY OemToAnsi(STR0016) FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL // "Saldo Transferido:"
					TGet():New(119, 070, &(cAuxSetGet), oPnlPai, nGetSALRET, 008, PesqPict("TUI", "TUI_QUANTI", ),;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)

					// Saldo Atual
					cAuxSetVr  := If(nOriDes == 1, "nOriSalCom", "nDesSalCom")
					cAuxSetGet := "{|| " + cAuxSetVr + " }"
					cAuxReadVr := "'" + cAuxSetVr + "'"
					@ 120,130 SAY OemToAnsi(AllTrim( RetTitle("B2_QATU") ) + ":") FONT oFontBold COLOR CLR_BLACK OF oPnlPai PIXEL
					TGet():New(119, 175, &(cAuxSetGet), oPnlPai, nGetSALATU, 008, PesqPict("SB2", "B2_QATU", ),;
								{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/,;
								.F., .F., , .F./*lReadOnly*/, .F., "", ""/*cReadVar*/, , , , .T./*lHasButton*/)
				EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DAS VALIDA��ES * MVC                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.

@author Wagner Sobral de Lacerda
@since 29/02/2012

@return .T. pode inicializar; .F. n�o pode
/*/
//---------------------------------------------------------------------
Static Function fVActivate(oView)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oView:GetOperation()

	// Declara que n�o � a valida��o final do cadastro
	l651Final := .F.

	// Retorna a Empresa e Filial iniciais
	fPrepTbls(, .T.)

	// Em opera��es de Altera��o ou Exclus�o, somente o respons�vel pela Transfer�ncia ou o Adminstrador podem alter�-la/exclu�-la
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

		If If(FindFunction("FWIsAdmin"), !FWIsAdmin(), (PswAdmin(, , RetCodUsr()) <> 0)) .And. TUI->TUI_RESPON <> RetCodUsr()
			Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
				STR0017,; // "Somente o Respons�vel pela Transfer�ncia, ou um usu�rio com permiss�o de Administrador, pode executar esta a��o."
				1, 0)
			Return .F.
		EndIf

	EndIf

	// Salva um Backup da View
	oBkpView := oView

	// Carrega as vari�eveis
	fLoadVars(nOperation)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
P�s-valida��o do modelo de dados.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oModel
	Objeto do modelo de dados * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMPosValid(oModel)

	Local lRet := .T.

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Esturutra do Modelo
	Local oModelTUI := oModel:GetModel("TUIMASTER")

	// Vari�veis com os valores dos campos do Modelo
	Local dDataTrans := oModelTUI:GetValue("TUI_DATA")
	Local cHoraTrans := oModelTUI:GetValue("TUI_HORA")

	Local cFiliOrig  := oModelTUI:GetValue("TUI_FILORI")
	Local cPostoOrig := oModelTUI:GetValue("TUI_POSORI")
	Local cLojaOrig  := oModelTUI:GetValue("TUI_LOJORI")
	Local cTanquOrig := oModelTUI:GetValue("TUI_TANORI")

	Local cFiliDes  := oModelTUI:GetValue("TUI_FILDES")
	Local cPostoDes := oModelTUI:GetValue("TUI_POSDES")
	Local cLojaDes  := oModelTUI:GetValue("TUI_LOJDES")
	Local cTanquDes := oModelTUI:GetValue("TUI_TANDES")

	Local cSaidaOrig := oModelTUI:GetValue("TUI_SAIORI")
	Local cBombaOrig := oModelTUI:GetValue("TUI_BOMORI")

	Local nQuantidad := oModelTUI:GetValue("TUI_QUANTI")

	Local cProOri := oModelTUI:GetValue("TUI_PROORI")
	Local cProDes := oModelTUI:GetValue("TUI_PRODES")

	// Data de Fechamento do Estoque
	Local dDtFecha := If(FindFunction("MVUlmes"), MVUlmes(), SuperGetMV("MV_ULMES", .F., CTOD("")))
	// Identifica se permitie Saldo Negativo no Estoque
	Local lEstNeg := ( SuperGetMV("MV_ESTNEG", .F., "N") == "S" )
	// Altera��o para Estornar
	Local lEstornar := IsInCallStack("MNTA651EST")

	// Vari�veis auxiliares da valida��o
	Local nBomUltCon := 0
	Local nBomAtuCon := 0

	// Indica que � a valida��o final do cadastro
	l651Final := .T.

	// Prepara a Empresa e Filial
	fPrepTbls(, .T.)

	//--------------------------------------------------
	// Valida os dados do Modelo
	//--------------------------------------------------
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		// Verifica o Fechamento do Estoque
		If dDtFecha >= dDataTrans
			Help(" ", 1, "FECHTO")
			l651Final := .F.
			Return .F.
		EndIf
		// Verifica Saldo Negativo
		If !lEstornar .And. !lEstNeg .And. nOriFimCom < 0
			Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
					STR0034,; // "Saldo do Estoque ficar� negativo. Opera��o Inv�lida."
					1, 0)
			l651Final := .F.
			Return .F.
		EndIf
		// M�todo Padr�o
		If !oModelTUI:VldData()
			l651Final := .F.
			Return .F.
		EndIf
		// Verifica a Bomba
		If !MNTA651BOM(oModelTUI)
			l651Final := .F.
			Return .F.
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT

		If IsInCallStack("MNTA651")
			If cFiliOrig == cFiliDes .AND. cProOri == cProDes .AND. cTanquOrig == cTanquDes
				Help( ,, STR0006,, STR0042, 1, 0 ) //"Aten��o"##"N�o � poss�vel realizar a transfer�ncia de combust�vel para o mesmo armazem."
				Return .F.
			EndIf

			If cProOri <> cProDes
				If !MsgYesNo(STR0043+CRLF+CRLF+;			//"O produto de origem que est� sendo transferido � diferente do produto de destino."
							   STR0044+cProOri+CRLF+;		//"Produto Origem :  "
							   STR0045+cProDes+CRLF+CRLF+;	//"Produto Destino:  "
							   STR0046,STR0006)				//"Deseja continuar assim mesmo?"##"Aten��o"

					Help( ,, STR0006,, STR0047, 1, 0 )		//"Aten��o"##"Altere o produto de origem ou o produto de destino."

					Return .F.
				EndIf
			EndIf
		EndIf

		//carrega variaveis INCLUI e ALTERA para funcao NGVDHBomba
		lOldInclui := If(Type("Inclui")=="L",Inclui,Nil)
		lOldAltera := If(Type("Altera")=="L",Altera,Nil)
		SetInclui()

		//--------------------------------------------------
		// Valida Negocia��o e Pre�o Negociado do posto destino
		//--------------------------------------------------
		// Prepara a Empresa e Filial
		fPrepTbls(2)

		//--------------------------------------------------
		// Se a sa�da de combust�vel for pela Bomba, valida essa sa�da
		//--------------------------------------------------
		If cSaidaOrig == "1"
			// Prepara a Empresa e Filial
			fPrepTbls(1)

			// Verifica o Contador da Bomba
			If NGVDHBomba(cPostoOrig, cLojaOrig, cTanquOrig, cBombaOrig, dDataTrans, cHoraTrans, Nil, Nil, Nil, Nil)
				Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
					STR0018,; // "J� existe um lan�amento para o Contador da Bomba nesta data e hora da Transfer�ncia."
					1, 0)
				l651Final := .F.
				lRet := .F.
			EndIf

			// Verifica o Limite do Contador da Bomba
			If lRet .And. NGIFDBSEEK("TQJ", cPostoOrig + cLojaOrig + cTanquOrig + cBombaOrig, 1)
				nBomUltCon := NGUltConBom(cPostoOrig, cLojaOrig, cTanquOrig, cBombaOrig, dDataTrans, cHoraTrans, Nil)
				nBomAtuCon := ( nBomUltCon + nQuantidad )

				If nBomAtuCon > TQJ->TQJ_LIMCON
					Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
						STR0019 + CRLF + CRLF + ; // "Este lan�amento � inv�lido pois o Contador da Bomba superou o seu limite."
						STR0020 + " " + Transform(nBomAtuCon, PesqPict("TQJ", "TQJ_LIMCON", )) + CRLF + ; // "Contador:"
						STR0021 + " " + Transform(TQJ->TQJ_LIMCON, PesqPict("TQJ", "TQJ_LIMCON", )),; // "Limite:"
						1, 0)
					l651Final := .F.
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If !lRet
			Inclui := lOldInclui
			Altera := lOldAltera
			Return .F.
		EndIf

	ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

		If nOperation == MODEL_OPERATION_DELETE .Or. lEstornar
			//--------------------------------------------------
			// Verifica o Fechamento do Estoque
			//--------------------------------------------------
			If dDtFecha >= dDataTrans
				Help(" ", 1, "FECHTO")
				l651Final := .F.
				Return .F.
			EndIf
		EndIf

	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651LEG
Fun��o para adicionar uma Legenda padronizada ao browse de
Transfer�ncias de Combust�vel (tabela TUI)

@author Wagner Sobral de Lacerda
@since 05/03/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigat�rio

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNTA651LEG(oObjBrw)

	Local lRetorno := .F.

	Local cStatus1 := AllTrim( NGRetSX3Box("TUI_STATUS", "1") )
	Local cStatus2 := AllTrim( NGRetSX3Box("TUI_STATUS", "2") )
	Local cStatus3 := AllTrim( NGRetSX3Box("TUI_STATUS", "3") )

	Default oObjBrw := Nil

	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TUI"
			oObjBrw:AddLegend("TUI_STATUS == '1'", "GREEN", cStatus1)
			oObjBrw:AddLegend("TUI_STATUS == '2'", "RED"  , cStatus2)
			oObjBrw:AddLegend("TUI_STATUS == '3'", "GRAY" , cStatus3)

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651VAR
Declara as vari�veis Private utilizadas na Transfer�ncia de Combust�vel.
* Lembrando que essas vari�veis ficam declaradas somente para a fun��o
que � Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651VAR()

	Local cEmpAtual := FWGrpCompany()
	Local cFilAtual := FWxFilial()

	Local lIntEstoq := ( AllTrim(SuperGetMV("MV_NGMNTES", .F., "N")) == "S" ) // Usa Integra��o com Estoque?
	Local lPrecoSB2 := ( AllTrim(SuperGetMV("MV_NGPRSB2", .F., "N")) == "S" ) // Utiliza o pre�o m�dio da tabela SB2?

	Local nValToler := SuperGetMV("MV_NGTOLVL", .F., 0) // Valor de toler�ncia para fechar a NF (Documento)

	Local aTables := { {"SB1"}, {"SB2"}, {"SD3"}, {"SD4"}, {"TQF"}, {"TQG"}, {"TQH"}, {"TQI"}, {"TQJ"}, {"TQM"}, {"TTV"}, {"TTX"} }

	//----------------------------------------
	// Declara as vari�veis
	//----------------------------------------

	// Vari�veis do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0008)) // "Transfer�ncias de Combust�vel"
	_SetOwnerPrvt("l651Final", .F.) // Vari�vel para indicar que a rotina est� em suas valida��es finais, e que qualquer inconsist�ncia deve impedir o cadastro
	_SetOwnerPrvt("lAtuEstoq", .F.) // Vari�vel para indicar se o estoque deve ser atualizado (depende do Motivo)
	_SetOwnerPrvt("lMVIntEst", lIntEstoq)
	_SetOwnerPrvt("lMVPreSB2", lPrecoSB2)
	_SetOwnerPrvt("nMVValTol", nValToler)

	_SetOwnerPrvt("oBkpView", Nil) // Objeto da View Atual do cadstro do Indicador

	// Vari�veis da Consulta SXB Gen�rica
	_SetOwnerPrvt("cMntGenFun", "MNTA651F3()")
	_SetOwnerPrvt("cMntGenRet", "MNTA651F3R()")
	_SetOwnerPrvt("aCamposF3" , {})
	_SetOwnerPrvt("bOnLoadF3" , {})
	_SetOwnerPrvt("cCampoF3"  , "")
	_SetOwnerPrvt("nF3Campo"  , 1)
	_SetOwnerPrvt("nF3ConPad" , 2)
	_SetOwnerPrvt("nF3Alias"  , 3)
	_SetOwnerPrvt("nF3CpoRet" , 4)
	_SetOwnerPrvt("cF3LojOri" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Posto Origem -> Loja Origem
	_SetOwnerPrvt("cF3LojDes" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Posto Destino -> Loja Destino
	_SetOwnerPrvt("cF3ComOri" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Tanque Origem -> Combust�vel Origem
	_SetOwnerPrvt("cF3ComDes" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Tanque Destino -> Combust�vel Destino
	_SetOwnerPrvt("cF3ProOri" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Combust�vel Origem -> Produto Origem
	_SetOwnerPrvt("cF3ProDes" , "") // Vari�vel auxiliar para gatilhar a Informa��o do Combust�vel Destino -> Produto Destino

	_SetOwnerPrvt("cEmpFiltro", cEmpAtual) // Vari�vel utilizada para a Consulta (SXB) de Empresas / Filiais
	_SetOwnerPrvt("cPosto"    , "") // Vari�vel utilizada para a Consulta (SXB) de Tanques e Bombas do Posto
	_SetOwnerPrvt("cLoja"     , "") // Vari�vel utilizada para a Consulta (SXB) de Tanques e Bombas do Posto
	_SetOwnerPrvt("cTanque"   , "") // Vari�vel utilizada para a Consulta (SXB) de Tanques e Bombas do Posto

	// Vari�veis das altera��o entre Empresas e Filiais
	_SetOwnerPrvt("cEmpInicia", cEmpAtual) // Vari�vel utilizada para a controlar a Empresa Inicial, quando se inicializou a rotina
	_SetOwnerPrvt("cFilInicia", cFilAtual) // Vari�vel utilizada para a controlar a Filial Inicial, quando se inicializou a rotina
	_SetOwnerPrvt("aPrepTbls" , aTables) // Vari�vel utilizada para armazenar as tabelas utilizadas pela rotina

	_SetOwnerPrvt("cEmpOpened", cEmpAtual) // Vari�vel utilizada para a controlar a Empresa aberta atualmente
	_SetOwnerPrvt("cFilOpened", cFilAtual) // Vari�vel utilizada para a controlar a Filial aberta atualmente

	_SetOwnerPrvt("cEmpOrigem", "") // Vari�vel utilizada para a controlar a Empresa de Origem
	_SetOwnerPrvt("cFilOrigem", "") // Vari�vel utilizada para a controlar a Filial de Origem
	_SetOwnerPrvt("cEmpDestin", "") // Vari�vel utilizada para a controlar a Empresa de Destino
	_SetOwnerPrvt("cFilDestin", "") // Vari�vel utilizada para a controlar a Filial de Destino

	// Vari�veis para as Informa��es dos Postos
	_SetOwnerPrvt("cOriPosNom", "") // Vari�vel utilizada para receber o nome do Posto Origem
	_SetOwnerPrvt("cOriComNom", "") // Vari�vel utilizada para receber o nome do Combust�vel Origem
	_SetOwnerPrvt("cOriProDes", "") // Vari�vel utilizada para receber a Descri��o do Produto do combust�vel origem
	_SetOwnerPrvt("cOriProUni", "") // Vari�vel utilizada para receber a Unidade de Medida do Produto do combust�vel origem
	_SetOwnerPrvt("nOriSalCom", 0) // Vari�vel utilizada para receber o Saldo Atual do Combust�vel Origem
	_SetOwnerPrvt("nOriFimCom", 0) // Vari�vel utilizada para receber o Saldo ap�s a Transfer�ncia do Combust�vel Origem
	_SetOwnerPrvt("cOriTipPos", "") // Vari�vel utilizada para receber o Tipo do Posto (Conveniado, Posto Interno, N�o Conveniado)

	_SetOwnerPrvt("cDesPosNom", "") // Vari�vel utilizada para receber o nome do Posto Destino
	_SetOwnerPrvt("cDesComNom", "") // Vari�vel utilizada para receber o nome do Combust�vel Destino
	_SetOwnerPrvt("cDesProDes", "") // Vari�vel utilizada para receber a Descri��o do Produto do combust�vel destino
	_SetOwnerPrvt("cDesProUni", "") // Vari�vel utilizada para receber a Unidade de Medida do Produto do combust�vel destino
	_SetOwnerPrvt("nDesSalCom", 0) // Vari�vel utilizada para receber o Saldo Atual do Combust�vel Destino
	_SetOwnerPrvt("nDesFimCom", 0) // Vari�vel utilizada para receber o Saldo ap�s a Transfer�ncia para o Combust�vel Destino

	_SetOwnerPrvt("lWhenFil", .T.) // Vari�vel utilizada para abrir o campo filial quando nao houver movimenta��o com estoque.

	//----------------------------------------
	// Define algumas vari�veis
	//----------------------------------------

	//--------------------
	// Campos do F3
	//--------------------
	// 1     ; 2  ; 3                  ; 4
	// Campo ; F3 ; Tabela da Consulta ; Campo de Retorno
	aAdd(aCamposF3, {"TUI_MOTIVO", "TTX", "TTX", "TTX->TTX_MOTIVO"})

	aAdd(aCamposF3, {"TUI_FILORI", "NGXM0", "SM0", "SM0->M0_CODFIL"})
	aAdd(aCamposF3, {"TUI_FILDES", "NGXM0", "SM0", "SM0->M0_CODFIL"})

	aAdd(aCamposF3, {"TUI_POSORI", "NGN", "TQF", "TQF->TQF_CODIGO"})
	aAdd(aCamposF3, {"TUI_POSDES", "NGN", "TQF", "TQF->TQF_CODIGO"})

	aAdd(aCamposF3, {"TUI_TANORI", "NGM", "TQI", "TQI->TQI_TANQUE"})
	aAdd(aCamposF3, {"TUI_TANDES", "NGM", "TQI", "TQI->TQI_TANQUE"})

	aAdd(aCamposF3, {"TUI_BOMORI", "TQJ", "TQJ", "TQJ->TQJ_BOMBA"})

	aAdd(aCamposF3, {"TUI_COMORI", "NGMCOM", "TQI", "TQI->TQI_CODCOM"})
	aAdd(aCamposF3, {"TUI_COMDES", "NGMCOM", "TQI", "TQI->TQI_CODCOM"})

	//--------------------
	// Bloco de C�digo do F3
	//--------------------
	bOnLoadF3 := {|| fLoadEmpFil() }

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadEmpFil
Prepara a Consulta F3.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadEmpFil()

	Local cCampo := If(!Empty(cCampoF3), cCampoF3, ReadVar())

	Local aCpoInicia := {}
	Local aCpoOrigem := {}
	Local aCpoDestin := {}
	Local aAux := {}, cAuxOriDes := ""
	Local nX   := 0

	If IsInCallStack("MNTA700")
		If ReadVar() == "M->TUI_POSDES" .OR. ReadVar() == "M->TUI_TANDES" .OR. ReadVar() == "M->TUI_COMDES" .OR. ReadVar() == "M->TUI_PRODES"
			cEmpDestin := cEmpAnt
			cFilDestin := MNT651FGET( "TUI_FILDES" )
		ElseIf ReadVar() == "M->TUI_POSORI" .OR. ReadVar() == "M->TUI_TANORI" .OR. ReadVar() == "M->TUI_COMORI" .OR. ReadVar() == "M->TUI_PROORI"
			cEmpOrigem := cEmpAnt
			cFilOrigem := MNT651FGET( "TUI_FILORI" )
		EndIf
	EndIf

	// Recebe o Campo
	cCampo := StrTran(cCampo, "M->", "")

	// Define os campos de Origem e Destino
	aCpoInicia := {"TUI_MOTIVO"}

	For nX := 1 To 2
		cAuxOriDes := If(nX == 1, "ORI", "DES")

		aAux := {}
		aAdd(aAux, "TUI_EMP" + cAuxOriDes)
		aAdd(aAux, "TUI_FIL" + cAuxOriDes)
		aAdd(aAux, "TUI_POS" + cAuxOriDes)
		aAdd(aAux, "TUI_LOJ" + cAuxOriDes)
		aAdd(aAux, "TUI_TAN" + cAuxOriDes)
		If nX == 1 //Somente no Posto Origem
			aAdd(aAux, "TUI_BOM" + cAuxOriDes)
		EndIf
		aAdd(aAux, "TUI_COM" + cAuxOriDes)
		aAdd(aAux, "TUI_PRO" + cAuxOriDes)

		If nX == 1
			aCpoOrigem := aClone( aAux )
		Else
			aCpoDestin := aClone( aAux )
		EndIf
	Next nX

	// Prepara as Tabelas de acordo com o campo
	If aScan(aCpoInicia, {|x| x == cCampo }) > 0
		fPrepTbls(, .T.)
	ElseIf aScan(aCpoOrigem, {|x| x == cCampo }) > 0
		cPosto  := MNT651FGET("TUI_POSORI")
		cLoja   := MNT651FGET("TUI_LOJORI")
		cTanque := MNT651FGET("TUI_TANORI")

		fPrepTbls(1)
	ElseIf aScan(aCpoDestin, {|x| x == cCampo }) > 0
		cPosto  := MNT651FGET("TUI_POSDES")
		cLoja   := MNT651FGET("TUI_LOJDES")
		cTanque := MNT651FGET("TUI_TANDES")

		fPrepTbls(2)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrepTbls
Prepara as tabelas para uma determinada Empresa e Filial.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerOriDes
	Indica se � para preparar as tabelas do Posto Origem ou Destino * Obrigat�rio

@param nVerOriDes
	Indica se � para preparar as tabelas para a Empresa/Filial Inicial * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrepTbls(nVerOriDes, lInicial)

	Local cPrepEmp := ""
	Local cPrepFil := ""

	Local aAreaSM0 := SM0->( GetArea() )

	Default nVerOriDes := 0
	Default lInicial   := .F.

	// Recebe a Empresa e Filial para preparar as tabelas
	If lInicial
		cPrepEmp := cEmpInicia
		cPrepFil := cFilInicia
	Else
		If nVerOriDes == 1 // Origem
			cPrepEmp := cEmpOrigem
			cPrepFil := cFilOrigem
		ElseIf nVerOriDes == 2 // Destino
			cPrepEmp := cEmpDestin
			cPrepFil := cFilDestin
		EndIf
	EndIf

	//------------------------------
	// Valida a Empresa
	//------------------------------
	// Verifica se a Empresa est� vazia
	If Empty(cPrepEmp)
		Return .F.
	EndIf

	// Verifica se a Empresa � v�lida
	dbSelectArea("SM0")
	dbSetOrder(1)
	If !dbSeek(cPrepEmp)
		RestArea(aAreaSM0)
		Return .F.
	EndIf

	If !Empty(cPrepFil)
		RestArea(aAreaSM0)
	EndIf

	// Verifica se est� Empresa/Filial j� est� aberta
	If cEmpOpened == cPrepEmp .And. ( Empty(cPrepFil) .Or. cFilOpened == cPrepFil )
		Return .F.
	EndIf

	//------------------------------
	// Prepara as tabelas para a Empresa
	//------------------------------
	NGPrepTbl(aPrepTbls,cPrepEmp,cPrepFil)

	cEmpOpened := cPrepEmp
	cFilOpened := cPrepFil

	cEmpFiltro := cPrepEmp

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadVars
Carrega as Vari�veis Private da rotina.

@author Wagner Sobral de Lacerda
@since 05/03/2012

@param nOperation
	Indica a opera��o sobre o Model/View * Obrigat�rio
	   MODEL_OPERATION_VIEW
	   MODEL_OPERATION_INSERT
	   MODEL_OPERATION_UPDATE
	   MODEL_OPERATION_DELETE
	   MODEL_OPERATION_ONLYUPDATE

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadVars(nOperation)

	Local nOriDes := 0

	Local lBase := (nOperation <> MODEL_OPERATION_INSERT)

	//------------------------------
	// Abre a Empresa e Filial
	//------------------------------
	fPrepTbls(, .T.)

	//------------------------------
	// Carrega Vari�veis
	//------------------------------
	// Atualiza Estoque?
	If lBase
		fLoadSeek("TTX", 0, .T.)
	Else
		lAtuEstoq := .F.
	EndIf

	// Vari�veis da Consulta SXB Gen�rica
	cCampoF3  := ""
	cF3LojOri := ""
	cF3LojDes := ""
	cF3ComOri := ""
	cF3ComDes := ""
	cF3ProOri := ""
	cF3ProDes := ""

	cPosto  := ""
	cLoja   := ""
	cTanque := ""

	// Vari�veis das altera��o entre Empresas e Filiais
	cEmpOrigem := If(lBase, TUI->TUI_EMPORI, cEmpOpened)
	cFilOrigem := If(lBase, TUI->TUI_FILORI, cFilOpened)
	cEmpDestin := If(lBase, TUI->TUI_EMPDES, cEmpOpened)
	cFilDestin := If(lBase, TUI->TUI_FILDES, cFilOpened)

	// Vari�veis para as Informa��es dos Postos
	cOriPosNom := ""
	cOriComNom := ""
	cOriProDes := ""
	cOriProUni := ""
	nOriSalCom := 0
	nOriFimCom := 0
	cOriTipPos := ""

	cDesPosNom := ""
	cDesComNom := ""
	cDesProDes := ""
	cDesProUni := ""
	nDesSalCom := 0
	nDesFimCom := 0

	If lBase
		For nOriDes := 1 To 2
			fLoadSeek("SB1", nOriDes, .T.)
			fLoadSeek("TQF", nOriDes, .T.)
			fLoadSeek("TQM", nOriDes, .T.)
		Next nOriDes
	EndIf

	//------------------------------
	// Devolve a Empresa e Filial
	//------------------------------
	fPrepTbls(, .T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadSeek
Recebe as vari�veis privates provenientes de Seeks nas tabelas.

@author Wagner Sobral de Lacerda
@since 29/02/2012

@param cSeekTbl
	Tabela do Seek * Obrigat�rio
@param nOriDes
	Indica que as tabelas a serem preparadas ser�o de: * Obrigat�rio
	   0 - Iniciais
	   1 - Origem
	   2 - Destino
@param lFromBase
	Indica se deve obter o conte�do da base de dados * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadSeek(cSeekTbl, nOriDes, lFromBase)

	Local oView     := If(ValType(oBkpView) == "O", FWViewActive(oBkpView), Nil)
	Local oModelTUI := If(ValType(oView) == "O", oView:GetModel("TUIMASTER"), Nil)

	Local aAreaSB1 := SB1->( GetArea() )
	Local aAreaTQF := TQF->( GetArea() )
	Local aAreaTQM := TQM->( GetArea() )
	Local aAreaTTX := TTX->( GetArea() )

	Local cPesqPosto := ""
	Local cPesqLoja  := ""
	Local cPesqComb  := ""
	Local cPesqProd  := ""

	Local cGetNReduz := ""
	Local cGetTipPos := ""
	Local cGetNomCom := ""
	Local cGetDescri := ""
	Local cGetUnidad := ""

	Local cOriDes := ""

	Default lFromBase := .F.

	// Verifica se h� Modelo
	If ValType(oModelTUI) <> "O"
		Return .F.
	EndIf

	// Prepara as tabela para a Empresa e Filial desejada
	If nOriDes == 0
		fPrepTbls(, .T.)
	Else
		fPrepTbls(nOriDes)
	EndIf

	// Carrega as vari�veis de acordo com os dados da tabela
	cOriDes := If(nOriDes == 1, "ORI", "DES")

	If cSeekTbl == "SB1"

		cPesqProd := If(!lFromBase, MNT651FGET("TUI_PRO" + cOriDes), &("TUI->TUI_PRO" + cOriDes))

		If NGIFDBSEEK("SB1", cPesqProd, 1)
			cGetDescri := SB1->B1_DESC
			cGetUnidad := SB1->B1_UM
		EndIf

		If nOriDes == 1 // Origem
			cOriProDes := cGetDescri
			cOriProUni := cGetUnidad
		Else // Destino
			cDesProDes := cGetDescri
			cDesProUni := cGetUnidad
		EndIf

	ElseIf cSeekTbl == "TQF"

		cPesqPosto := If(!lFromBase, MNT651FGET("TUI_POS" + cOriDes), &("TUI->TUI_POS" + cOriDes))
		cPesqLoja  := If(!lFromBase, MNT651FGET("TUI_LOJ" + cOriDes), &("TUI->TUI_LOJ" + cOriDes))

		If NGIFDBSEEK("TQF", cPesqPosto + cPesqLoja, 1)
			cGetNReduz := TQF->TQF_NREDUZ
			cGetTipPos := TQF->TQF_TIPPOS
		EndIf

		If nOriDes == 1 // Origem
			cOriPosNom := cGetNReduz
			cOriTipPos := cGetTipPos
		Else // Destino
			cDesPosNom := cGetNReduz
		EndIf

	ElseIf cSeekTbl == "TQM"

		cPesqComb := If(!lFromBase, MNT651FGET("TUI_COM" + cOriDes), &("TUI->TUI_COM" + cOriDes))

		cGetNomCom := NGSEEK("TQM", cPesqComb, 1, "TQM_NOMCOM")

		If nOriDes == 1 // Origem
			cOriComNom := cGetNomCom
		Else // Destino
			cDesComNom := cGetNomCom
		EndIf

	ElseIf cSeekTbl == "TTX"

		// Verifica se atualiza o Estoque
		lAtuEstoq := .F.
		If lFromBase .And. lMVIntEst
			// Atribui o valor da vari�vel de 'Atualiza Estoque?'
			lAtuEstoq := ( TUI->TUI_STATUS == "1" ) // Se for 'Normal'
		ElseIf ValType(oModelTUI) == "O"
			If NGIFDBSEEK("TTX", MNT651FGET("TUI_MOTIVO"), 1) .And. ( lMVIntEst .And. TTX->TTX_ATUEST == "1" )
				// Atribui o valor da vari�vel de 'Atualiza Estoque?'
				lAtuEstoq := .T.
				oModelTUI:SetValue("TUI_STATUS", "1") // Normal
			Else
				oModelTUI:SetValue("TUI_STATUS", "3") // Sem Estoque
			EndIf
		EndIf

	EndIf

	If nOriDes == 0
		fAtuEstoq(, .T., lFromBase)
	Else
		fAtuEstoq(nOriDes, .F., lFromBase)
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaTQF)
	RestArea(aAreaTQM)
	RestArea(aAreaTTX)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuEstoq
Atualiza as Informa��es do Estoque do Combust�vel.

@author Wagner Sobral de Lacerda
@since 29/02/2012

@param nOriDes
	Indica qual o Estoque ir� atualzar * Obrigat�rio
	   1 - Origem
	   2 - Destino
@param lAmbos
	Indica se atualizar� ambos os estoques * Opcional
	Default: .T.
@param lFromBase
	Indica se deve obter o conte�do da base de dados * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuEstoq(nOriDes, lAmbos, lFromBase)

	Local aAreaSB1 := {}
	Local aAreaTQI := {}

	Local cPesqPosto := ""
	Local cPesqLoja  := ""
	Local cPesqTanqu := ""
	Local cPesqProd  := ""

	Local dPesqData := CTOD("")
	Local cPesqComb := ""

	Local nQuantid  := 0

	Local nSaldAtu := 0
	Local cDescric := ""
	Local cUnidade := ""

	Local cOriDes := ""

	Default nOriDes   := 1
	Default lAmbos    := .T.
	Default lFromBase := .F.

	// Define se atualzar� ambos os estoques
	If lAmbos
		nOriDes := 1
	EndIf

	// Prepara as tabelas
	fPrepTbls(nOriDes)

	aAreaSB1 := SB1->( GetArea() )
	aAreaTQI := TQI->( GetArea() )

	//------------------------------
	// Recebe Conte�do
	//------------------------------
	cOriDes := If(nOriDes == 1, "ORI", "DES")

	dPesqData := If(!lFromBase, MNT651FGET("TUI_DATA"), TUI->TUI_DATA)
	nQuantid  := If(!lFromBase, MNT651FGET("TUI_QUANTI"), TUI->TUI_QUANTI)

	cPesqPosto := If(!lFromBase, MNT651FGET("TUI_POS" + cOriDes), &("TUI->TUI_POS" + cOriDes))
	cPesqLoja  := If(!lFromBase, MNT651FGET("TUI_LOJ" + cOriDes), &("TUI->TUI_LOJ" + cOriDes))
	cPesqTanqu := If(!lFromBase, MNT651FGET("TUI_TAN" + cOriDes), &("TUI->TUI_TAN" + cOriDes))

	cPesqComb := If(!lFromBase, MNT651FGET("TUI_COM" + cOriDes), &("TUI->TUI_COM" + cOriDes))
	cPesqProd := If(!lFromBase, MNT651FGET("TUI_PRO" + cOriDes), &("TUI->TUI_PRO" + cOriDes))

	//------------------------------
	// Atualiza
	//------------------------------
	// Recebe os dados do Produto no Estoque
	nSaldAtu := fGetSaldo(cPesqProd, cPesqTanqu, dPesqData)

	If nOriDes == 1 // Origem
		nOriSalCom := nSaldAtu
		nOriFimCom := If(lAtuEstoq, ( nOriSalCom - nQuantid ), nSaldAtu)
	ElseIf nOriDes == 2 // Destino
		nDesSalCom := nSaldAtu
		nDesFimCom := If(lAtuEstoq, ( nDesSalCom + nQuantid ), nSaldAtu)
	EndIf

	// Chamada recursiva para atualizar o outro estoque
	If lAmbos
		fAtuEstoq(++nOriDes, .F., lFromBase)
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaTQI)

	// Prepara a Empresa e Filial originais
	fPrepTbls(, .T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetSaldo
Retorna o Saldo em Estoque de um dado Combust�vel.

@author Wagner Sobral de Lacerda
@since 29/02/2012

@param cVerProdut
	Indica o c�digo do Combust�vel * Obrigat�rio
@param dVerData
	Indica a Data do saldo * Obrigat�rio

@return {Produto, Local, Saldo}
/*/
//---------------------------------------------------------------------
Static Function fGetSaldo(cVerProdut, cVerLocal, dVerData)

	Local aAreaSB1 := {}
	Local aAreaSB2 := {}

	Local nGetSaldo := 0

	// Se utilizar Integra��o com Estoque, recebe o Saldo dispon�vel na tabela SB2
	If lMVIntEst
		aAreaSB1 := SB2->( GetArea() )
		aAreaSB2 := SB2->( GetArea() )

		If NGIFDBSEEK("SB1", cVerProdut, 1) .And. !Empty(cVerLocal) .And. !Empty(dVerData)
			dbSelectArea("SB2")
			dbSetOrder(1)
			If !dbSeek(xFilial("SB2") + cVerProdut + cVerLocal)
				CriaSB2(cVerProdut, cVerLocal)
				MsUnlock("SB2")
			EndIf
			nGetSaldo := SaldoSB2(.F., .T./*Considera Empenho*/, dVerData, .F.)
		EndIf

		RestArea(aAreaSB1)
		RestArea(aAreaSB2)
	EndIf

Return nGetSaldo

//---------------------------------------------------------------------
/*/{Protheus.doc} fZeraTrigger
Zera as vari�veis utilizadas nos Triggers manuais.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fZeraTrigger()

	// Se n�o for um Trigger sendo executado nem a valida��o autom�tica do Campo
	If !IsInCallStack("FWMVCEVALTRIGGER") .And. !IsInCallStack("VALIDFIELD")
		// Zera as vari�veis auxiliares de F3
		cF3LojOri := ""
		cF3LojDes := ""
		cF3ComOri := ""
		cF3ComDes := ""
		cF3ProOri := ""
		cF3ProDes := ""
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES UTILIZADAS NO DICION�RIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651DAT
Fun��o da Valida��o da Data.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651DAT()

	If MNT651FGET("TUI_DATA") > dDataBase
		Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
			STR0026 + " '" + AllTrim( RetTitle("TUI_DATA") ) + "' " + STR0027,; // "O campo" ### "n�o pode conter uma data maior que a Data Atual do sistema."
			1, 0)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651HOR
Fun��o da Valida��o da Hora.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651HOR()

If !NGVALHORA(MNT651FGET("TUI_HORA"))
	Return .F.
Elseif MNT651FGET("TUI_DATA") == dDataBase .And. MNT651FGET("TUI_HORA") > Time()
	ShowHelpDlg( STR0006 , ;
				{ STR0026 + " '" + AllTrim( RetTitle("TUI_HORA") ) + "' " + STR0028 } , 2 , ;
				{ STR0036 } , 2 )
	Return .F.
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651MOT
Fun��o da Valida��o do Motivo da Transfer�ncia.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651MOT()

	Local cValMot := MNT651FGET("TUI_MOTIVO")

	// Prepara a empresa e filial
	fLoadEmpFil()

	// Valida o Motivo
	If !ExistCpo("TTX", cValMot, 1)
		Return If(l651Final, .F., Empty(cValMot))
	ElseIf TTX->TTX_ATUEST == "1"
		M->TUI_FILORI := cFilAnt
		M->TUI_FILDES := cFilAnt
		lWhenFil := .F.
	Else
		lWhenFil := .T.
	EndIf

	// Carrega a vari�vel de 'Atualiza Estoque?'
	fLoadSeek("TTX", 0)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651FIL
Fun��o da Valida��o da Filial.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerFil
	Indica qual a Filial que est� validando * Obrigat�rio
	   1 - Filial Origem
	   2 - Filial Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651FIL(nVerFil)

	Local cOriDes := If(nVerFil == 1, "ORI", "DES")

	Local cValEmp := MNT651FGET("TUI_EMP" + cOriDes)
	Local cValFil := MNT651FGET("TUI_FIL" + cOriDes)

	// Valida a Filial
	If !FWFilExist(cValEmp, cValFil)
		Return .F.
	EndIf

	// Atribui a Filial as vari�veis de controle
	If nVerFil == 1
		cFilOrigem := cValFil
	Else
		cFilDestin := cValFil
	EndIf

	DbSelectArea("SM0")
	DbGoTop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651POS
Fun��o da Valida��o do Posto.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerPos
	Indica qual o Posto que est� validando * Obrigat�rio
	   1 - Posto Origem
	   2 - Posto Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651POS(nVerPos)

	Local aAreaTQF := TQF->( GetArea() )

	Local cOriDes := If(nVerPos == 1, "ORI", "DES")

	Local cValPos := MNT651FGET("TUI_POS" + cOriDes)
	Local cValLoj := If(IsInCallStack("MNTA651LOJ"), MNT651FGET("TUI_LOJ" + cOriDes), "")

	Local aCposLimpa := {}

	Local lReturn := .T.

	// Prepara a empresa e filial
	fLoadEmpFil()

	// Valida o Posto

	If !Empty(cValPos) .AND. !ExistCpo("TQF", cValPos + cValLoj, 1)
		lReturn := If(l651Final, .F., Empty(cValPos))
		Return .F.
	Else
		// Tipo do Posto
		If NGIFDBSEEK("TQF", cValPos + cValLoj, 1) .And. TQF->TQF_TIPPOS <> "2" // Diferente de Posto Interno
			Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
				STR0030,; // "A transfer�ncia somente pode ser realizada entre Postos Internos."
				1, 0)
			lReturn := .F.
		EndIf
	EndIf

	If lReturn
		// Dados do Posoto
		fLoadSeek("TQF", nVerPos)
	EndIf

	// Limpa os campos dependentes desta informa��o
	If !IsInCallStack("MNTA651LOJ")
		aAdd(aCposLimpa, "TUI_LOJ" + cOriDes)
	EndIf
	aAdd(aCposLimpa, "TUI_TAN" + cOriDes)
	aAdd(aCposLimpa, "TUI_COM" + cOriDes)
	aAdd(aCposLimpa, "TUI_PRO" + cOriDes)
	fClearCpos(aCposLimpa)

	RestArea(aAreaTQF)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651LOJ
Fun��o da Valida��o da Loja do Posto.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerLoj
	Indica qual a Loja que est� validando * Obrigat�rio
	   1 - Loja Origem
	   2 - Loja Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651LOJ(nVerLoj)

	// Zera Triggers
	fZeraTrigger()

	// Valida o Posto e a Loja
	If !MNTA651POS(nVerLoj)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651TAN
Fun��o da Valida��o do Tanque do Posto.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerTan
	Indica qual o Tanque que est� validando * Obrigat�rio
	   1 - Tanque Origem
	   2 - Tanque Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651TAN(nVerTan)

	Local cOriDes := If(nVerTan == 1, "ORI", "DES")

	Local cValPos := MNT651FGET("TUI_POS" + cOriDes)
	Local cValLoj := MNT651FGET("TUI_LOJ" + cOriDes)
	Local cValTan := MNT651FGET("TUI_TAN" + cOriDes)

	Local aCposLimpa := {"TUI_COM" + cOriDes, "TUI_PRO" + cOriDes}

	Local lReturn := .T.

	// Prepara a empresa e filial
	fLoadEmpFil()

	// Valida o Tanque
	If !ExistCpo("TQI", cValPos + cValLoj + cValTan, 1)
		lReturn := If(l651Final, .F., Empty(cValTan))
		//Return .F.
	EndIf
	fManualTrigger(lReturn)

	// Limpa os campos dependentes desta informa��o
	fClearCpos(aCposLimpa)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651BOM
Fun��o da Valida��o da Bomba do Tanque do Posto.
* Apenas para o Posto Origem, porque o combust�vel pode SAIR por uma
Bomba, mas n�o entrar.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerBom
	Indica qual a Bomba que est� validando * Obrigat�rio
	   1 - Bomba Origem
	   2 - Bomba Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651BOM(oModel)

	Local cValPos, cValLoj, cValTan, cValSai, cValBom, cFilOri
	Local cBkpFil := cFilAnt

	Local aTabelas := { {"TQJ"} }


	If oModel <> Nil
		cFilOri := oModel:GetValue("TUI_FILORI")
		cValPos := oModel:GetValue("TUI_POSORI")
		cValLoj := oModel:GetValue("TUI_LOJORI")
		cValTan := oModel:GetValue("TUI_TANORI")
		cValSai := oModel:GetValue("TUI_SAIORI")
		cValBom := oModel:GetValue("TUI_BOMORI")
	Else
		cFilOri := MNT651FGET("TUI_FILORI")
		cValPos := MNT651FGET("TUI_POSORI")
		cValLoj := MNT651FGET("TUI_LOJORI")
		cValTan := MNT651FGET("TUI_TANORI")
		cValSai := MNT651FGET("TUI_SAIORI")
		cValBom := MNT651FGET("TUI_BOMORI")
	EndIf

	// Se a sa�da de combust�vel for pela Bomba, valida a Bomba
	If cValSai == "1"
		// Prepara a empresa e filial
		fLoadEmpFil()
		NGPrepTbl(aTabelas,cEmpAnt,cFilOri)
		// Valida a Bomba
		If Empty(cValBom)
			If l651Final
				Help(Nil, Nil, STR0006, Nil,; // "Aten��o"
					STR0031,; // "A Bomba dever� ser informada quando a Sa�da de Combust�vel for pela Bomba."
					1, 0)
				Return .F.
			EndIF
		ElseIf !ExistCpo("TQJ", cValPos + cValLoj + cValTan + cValBom, 1)
			Return .F.
		EndIf
		NGPrepTbl(aTabelas,cEmpAnt,cBkpFil)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651COM
Fun��o da Valida��o do Combust�vel do Tanque do Posto.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerCom
	Indica qual o Combust�vel que est� validando * Obrigat�rio
	   1 - Combust�vel Origem
	   2 - Combust�vel Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651COM(nVerCom)

	Local aAreaTQI := TQI->( GetArea() )
	Local aAreaTQM := TQM->( GetArea() )

	Local cOriDes := If(nVerCom == 1, "ORI", "DES")

	Local cValPos := MNT651FGET("TUI_POS" + cOriDes)
	Local cValLoj := MNT651FGET("TUI_LOJ" + cOriDes)
	Local cValTan := MNT651FGET("TUI_TAN" + cOriDes)
	Local cValCom := MNT651FGET("TUI_COM" + cOriDes)

	Local aCposLimpa := {"TUI_PRO" + cOriDes}

	Local lReturn := .T.

	// Zera Triggers
	fZeraTrigger()

	// Prepara a empresa e filial
	fLoadEmpFil()

	// Valida o Combust�vel
	If !ExistCpo("TQI", cValPos + cValLoj + cValTan + cValCom, 1)
		lReturn := If(l651Final, .F., Empty(cValCom))
	EndIf
	fManualTrigger(lReturn)

	// Dados do Combust�vel
	fLoadSeek("TQM", nVerCom)

	// Limpa os campos dependentes desta informa��o
	fClearCpos(aCposLimpa)

	RestArea(aAreaTQI)
	RestArea(aAreaTQM)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651PRO
Fun��o da Valida��o do Produto do Combust�vel do Tanque do Posto.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@param nVerPro
	Indica qual o Produto que est� validando * Obrigat�rio
	   1 - Produto Origem
	   2 - Produto Destino

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651PRO(nVerPro)

	Local aAreaSB1 := SB1->( GetArea() )

	Local cOriDes := If(nVerPro == 1, "ORI", "DES")

	Local cValPro := MNT651FGET("TUI_PRO" + cOriDes)

	Local lReturn := .T.

	// Zera Triggers
	fZeraTrigger()

	// Prepara a empresa e filial
	fLoadEmpFil()

	// Valida o Produto
	If !ExistCpo("SB1", cValPro, 1)
		lReturn := If(l651Final, .F., Empty(cValPro))
	EndIf

	// Dados do Produto
	fLoadSeek("SB1", nVerPro)

	RestArea(aAreaSB1)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651WHN
Fun��o para definir o WHEN dos campos.

@author Wagner Sobral de Lacerda
@since 27/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651WHN()

	Local cCampo := StrTran(ReadVar(), "M->", "")

	Local aWhnBomba := {}
	Local aWhnValOri := {}, aWhnValDes := {}

	// Define os campos de uso da Bomba
	aWhnBomba := {"TUI_BOMORI"}

	//--------------------
	// Executa o WHEN
	//--------------------
	If aScan(aWhnBomba, {|x| x == cCampo }) > 0

		Return ( MNT651FGET("TUI_SAIORI") == "1" )

	ElseIf aScan(aWhnValOri, {|x| x == cCampo }) > 0

		// Utiliza Pre�o da tabela SB2
		If lMVPreSB2
			Return .F.
		ElseIf cOriTipPos <> "3" // diferente de Posto N�o Conveniado
			Return .F.
		EndIf

	ElseIf aScan(aWhnValDes, {|x| x == cCampo }) > 0

		// Utiliza Pre�o da tabela SB2
		If lMVPreSB2
			Return .F.
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651F3
Fun��o para executar o F3 dos campos.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA651F3()

	Local cCampo  := ""
	Local nScan   := 0
	Local aAreaSM0 := SM0->( GetArea() )
	Local lConPad := .F.

	// Recebe o campo
	cCampoF3 := ReadVar()
	cCampo   := StrTran(cCampoF3, "M->", "")

	// Executa o bloco de c�digo
	If ValType(bOnLoadF3) == "B"
		Eval(bOnLoadF3)
	EndIf

	//----------------------------------------
	// Retorna executando a Consulta Padr�o
	//----------------------------------------
	nScan := aScan(aCamposF3, {|x| x[nF3Campo] == cCampo })
	If nScan == 0
		Return .F.
	Else
		lConPad := ConPad1(Nil, Nil, Nil, aCamposF3[nScan][nF3ConPad]/*cAlias*/, Nil/*cCampoRet*/, Nil, .F./*lOnlyView*/, Nil/*cVar*/, Nil, Nil/*uContent*/)

		If !lConPad
			dbSelectArea(aCamposF3[nScan][nF3Alias])
			PutFileInEof(aCamposF3[nScan][nF3Alias])

		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA651F3R
Fun��o para retornar o conte�do selecinado no F3 do campo.

@author Wagner Sobral de Lacerda
@since 28/02/2012

@return cReturn
/*/
//---------------------------------------------------------------------
Function MNTA651F3R()

	// Vari�vel de Retorno
	Local cReturn := Space( Len(&(cCampoF3)) )

	// Vari�veis auxiliares para o Retorno
	Local cCampo    := StrTran(cCampoF3, "M->", "")
	Local cRetAlias := ""
	Local cRetCampo := ""
	Local nScan := 0

	// Recebe o Retorna do Consulta Padr�o
	nScan := aScan(aCamposF3, {|x| x[nF3Campo] == cCampo })
	If nScan > 0
		cRetAlias := aCamposF3[nScan][nF3Alias]
		cRetCampo := aCamposF3[nScan][nF3CpoRet]

		dbSelectArea(cRetAlias)
		cReturn := &(cRetCampo)
		If Eof() // Se estiver posicionado em final de arquivo
			cReturn := If(!Empty(&(cCampoF3)), &(cCampoF3), cReturn) // Recebe o conte�do anterior ao F3
		EndIf

		// Se for o Posto, preenche a loja
		If cRetAlias == "TQF"
			// Gatilha a Loja
			If "_POSORI" $ cCampo
				cF3LojOri := TQF->TQF_LOJA
			ElseIf "_POSDES" $ cCampo
				cF3LojDes := TQF->TQF_LOJA
			EndIf
		ElseIf cRetAlias == "TQI"
			// Gatilha o Combust�vel
			If "_TANORI" $ cCampo .Or. "_COMORI" $ cCampo
				cF3ComOri := TQI->TQI_CODCOM
				cF3ProOri := TQI->TQI_PRODUT
			ElseIf "_TANDES" $ cCampo .Or. "_COMDES" $ cCampo
				cF3ComDes := TQI->TQI_CODCOM
				cF3ProDes := TQI->TQI_PRODUT
			EndIf
		EndIf
	EndIf

	// Zera a vari�vel do campo sendo consultado
	cCampoF3 := ""

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT651FGET
Fun��o para receber o conte�do de um campo.

@author Wagner Sobral de Lacerda
@since 13/06/2012

@param cCampo
	Campo do modelo ou da mem�ria para receber * Obrigat�rio;

@return uReturn
/*/
//---------------------------------------------------------------------
Function MNT651FGET(cCampo)

	// Vari�vel do retorno
	Local uReturn

	// Defaults
	Default cCampo := ReadVar()

	// Recebe o conte�do
	If ValType(oBkpView) == "O"
		uReturn := FWFldGet(cCampo)
	Else
		uReturn := &("M->"+cCampo)
	EndIf

Return uReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fClearCpos
Fun��o que limpa o conte�do dos campos em tela.

@author Wagner Sobral de Lacerda
@since 20/07/2012

@param aCampos
	Array com os campos do Modelo * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fClearCpos(aCampos)

	Local oView     := If(ValType(oBkpView) == "O", FWViewActive(oBkpView), Nil)
	Local oModelTUI := If(ValType(oView) == "O", oView:GetModel("TUIMASTER"), Nil)

	Local nCpo

	Default aCampos := {}

	// Limpa
	If ValType(oModelTUI) == "O"
		For nCpo := 1 To Len(aCampos)
			oModelTUI:LoadValue(aCampos[nCpo], Space( TAMSX3(aCampos[nCpo])[1] )) // Limpa o conte�do do campo (deixa em branco)
		Next nCpo
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fManualTrigger
Executa um Trigger Manual, para quando a rotina n�o for o pr�prio MNTA651.

@author Wagner Sobral de Lacerda
@since 14/12/2012

@param lExecuta
	Indica se Executa o Gatilho * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fManualTrigger(lExecuta)

	// Vari�veis auxiliares para o Retorno
	Local cCampo := ""

	If lExecuta .And. !IsInCallStack("MNTA651")
		cCampoF3 := ReadVar()
		cCampo := StrTran(cCampoF3, "M->", "")
		MNTA651F3R()

		If "TUI_POS" $ cCampo
			If "ORI" $ cCampo
				M->TUI_LOJORI := cF3LojOri
			ElseIf "DES" $ cCampo
				M->TUI_LOJDES := cF3LojDes
			EndIf
		ElseIf "TUI_TAN" $ cCampo
			If "ORI" $ cCampo
				M->TUI_COMORI := cF3ComOri
				M->TUI_PROORI := cF3ProOri
			ElseIf "DES" $ cCampo
				M->TUI_COMDES := cF3ComDes
				M->TUI_PRODES := cF3ProDes
			EndIf
		ElseIf "TUI_COM" $ cCampo
			If "ORI" $ cCampo
				M->TUI_PROORI := cF3ProOri
			ElseIf "DES" $ cCampo
				M->TUI_PRODES := cF3ProDes
			EndIf
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT651SX7C
Define Chave para os gatilhos dos campos TUI_POSORI, TUI_POSDES
TUI_COMORI,TUI_COMDES

@author Felipe Helio dos Santos
@since 17/06/2013

@return .T.
/*/
//---------------------------------------------------------------------
Function MNT651SX7C(nOpc)

Local cReturn

//Campos posto origem
Local cFilOri := MNT651FGET("TUI_FILORI")
Local cPosOri := MNT651FGET("TUI_POSORI")
Local cLojOri := If(Empty("TUI_LOJORI"),MNT651FGET("TUI_LOJORI"),TQF->TQF_LOJA)
Local cTanOri := MNT651FGET("TUI_TANORI")
Local cComOri := MNT651FGET("TUI_COMORI")

//Campos posto destino
Local cFilDes := MNT651FGET("TUI_FILDES")
Local cPosDes := MNT651FGET("TUI_POSDES")
Local cLojDes := If(Empty("TUI_LOJDES"),MNT651FGET("TUI_LOJDES"),TQF->TQF_LOJA)
Local cTanDes := MNT651FGET("TUI_TANDES")
Local cComDes := MNT651FGET("TUI_COMDES")

If cValToChar(nOpc) $ "3/4" //Condi��o para buscar dados do Posto Origem/Destino
	cFilDes := xFilial("TQF",cFilDes)
	cFilOri := xFilial("TQF",cFilOri)
ElseIf cValToChar(nOpc) $ "1/2" //Condi��o para buscar dados de Combust�vel Origem/Destino
	cFilDes := xFilial("TQI",cFilDes)
	cFilOri := xFilial("TQI",cFilOri)
EndIf

If nOpc == 1 //TUI_COMDES
	cReturn := cFilDes+cPosDes+cLojDes+cTanDes+cComDes
ElseIf nOpc == 2 //TUI_COMORI
	cReturn := cFilOri+cPosOri+cLojOri+cTanOri+cComOri
ElseIf nOpc == 3 //TUI_POSDES
	cReturn := cFilDes+cPosDes+cLojDes
ElseIf nOpc == 4 //TUI_POSORI
	cReturn := cFilOri+cPosOri+cLojOri
EndIf

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGTRANCOMB
Transfere o combustivel quando utilizada a transferencia
de produto no m�dulo de estoque
Fun��o utilizada na rotina de estoque MATA310

@param cCodProd 	C�digo do produto
@param cLocalProd	Local de produto = tanque do posto
@param nQuantid 	Quantidade a ser transferida
@param cNumDoc      Numero do documento de saida
@param cSerieDoc    Serie do documento de saida

@since 17/11/2017
@version MP12
@return L�gico
/*/
//---------------------------------------------------------------------
Function NGTRANCOMB(cCodProd,cLocalProd,nQuantid,cNumDoc,cSerieDoc)

	Local cQuery := ""
	Local aDBF := {}
	Local nSizeFil := FwSizeFilial()

	Private cAliasQry := GetNextAlias()

	Default cCodProd   := ""
	Default cLocalProd := ""
	Default nQuantid   := 0
	Default cNumDoc    := ""
	Default cSerieDoc  := ""

	aAdd(aDBF,{"TQJ_FILIAL", "C" , nSizeFil, 0 })
	aAdd(aDBF,{"TQJ_CODPOS", "C" , TAMSX3('TQJ_CODPOS')[1] , 0 })
	aAdd(aDBF,{"TQJ_LOJA"  , "C" , TAMSX3('TQJ_LOJA')[1]   , 0 })
	aAdd(aDBF,{"TQJ_TANQUE", "C" , TAMSX3('TQJ_TANQUE')[1] , 0 })
	aAdd(aDBF,{"TQJ_BOMBA", "C"  , TAMSX3('TQJ_BOMBA')[1]  , 0 })
	aAdd(aDBF,{"TQF_NREDUZ", "C" , TAMSX3('TQF_NREDUZ')[1] , 0 })
	aAdd(aDBF,{"OK"       , "C"  , 2, 0 })

	//Buscar Tanque e Bomba relacionados ao Produto e Local
	cQuery := " SELECT TQJ_CODPOS, TQJ_LOJA, TQJ_TANQUE, TQJ_BOMBA, TQF_NREDUZ "
	cQuery += " FROM " + RetSqlName("TQJ") + " TQJ "
	cQuery += "   JOIN " + RetSqlName("TQI") + " TQI "
	cQuery += "     ON TQJ_FILIAL = TQI_FILIAL AND TQJ_CODPOS = TQI_CODPOS "
	cQuery += "     AND TQJ_LOJA = TQI_LOJA AND TQJ_TANQUE = TQI_TANQUE "
	cQuery += "   JOIN " + RetSqlName("TQF") + " TQF "
	cQuery += "     ON TQI_FILIAL = TQF_FILIAL AND TQI_CODPOS = TQF_CODIGO "
	cQuery += "     AND TQI_LOJA = TQF_LOJA "
	cQuery += "   WHERE TQI_PRODUT = " + ValToSQL(cCodProd)
	cQuery += "   AND TQI_TANQUE  = " + ValToSQL(cLocalProd)
	cQuery += "   AND TQI_FILIAL  = " + ValToSQL(xFilial("TQI"))
	cQuery += "   AND TQI.D_E_L_E_T_ <> '*' "
	cQuery += "   AND TQJ.D_E_L_E_T_ <> '*' "
	cQuery += "   AND TQF.D_E_L_E_T_ <> '*' "

	//Tranfere dados obtidos na query para tabela tempor�ria criada anteriormente.
	aIndAux   := {"TQJ_CODPOS", "TQJ_LOJA", "TQJ_TANQUE", "TQJ_BOMBA"}
    //Instancia classe FWTemporaryTable
	oTmpTbl2:= FWTemporaryTable():New( cAliasQry, aDBF )
	//Adiciona os Indices
	oTmpTbl2:AddIndex( "Ind01" , aIndAux)
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	SqlToTrb(cQuery, aDBF, cAliasQry)

	If !Eof()

		If MsgYesNo(STR0048 +; //"Existe Posto(s) relacionado(s) a este produto, "
		        STR0049) //"deseja atualizar o contador da bomba?"
			//Fun��o para selecionar o Posto
			fSelectPost(nQuantid,cNumDoc,cSerieDoc)
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectPost
Seleciona o Posto que sera retirado o combustivel

@param nQuantid 	Quantidade a ser transferida
@param cNumDoc      Numero do documento de saida
@param cSerieDoc    Serie do documento de saida

@author Tain� Alberto Cardoso
@since 17/11/2017
@version MP12
@return L�gico
/*/
//---------------------------------------------------------------------
Static Function fSelectPost(nQuantid, cNumDoc, cSerieDoc)

	Local oPanelAll
	Local aFieldsMRK := {}
	Local lOk := .F.

	Default nQuantid := 0
	Default cNumDoc := ""
	Default cSerieDoc := ""

	Private oMarPosto
	Private cMarca := GetMark()
	Private lInverte := .F.

	aADD(aFieldsMRK, {RetTitle("TQJ_CODPOS"),"TQJ_CODPOS","C",TAMSX3('TQJ_CODPOS')[1],0,PesqPict("TQJ", "TQJ_CODPOS") })
	aADD(aFieldsMRK, {RetTitle("TQJ_LOJA")  ,"TQJ_LOJA"  ,"C",TAMSX3('TQJ_LOJA')[1]  ,0,PesqPict("TQJ", "TQJ_LOJA")	  })
	aADD(aFieldsMRK, {RetTitle("TQF_NREDUZ"),"TQF_NREDUZ","C",TAMSX3('TQF_NREDUZ')[1],0,PesqPict("TQF", "TQF_NREDUZ") })
	aADD(aFieldsMRK, {RetTitle("TQJ_TANQUE"),"TQJ_TANQUE","C",TAMSX3('TQJ_TANQUE')[1],0,PesqPict("TQJ", "TQJ_TANQUE") })
	aADD(aFieldsMRK, {RetTitle("TQJ_BOMBA") ,"TQJ_BOMBA" ,"C",TAMSX3('TQJ_BOMBA')[1] ,0,PesqPict("TQJ", "TQJ_BOMBA")  })

	DEFINE MSDIALOG oDlg FROM 0,0 To 500,900 TITLE STR0050 OF oMainWnd PIXEL //"Transferencia de Combustivel"

		//Painel de Campos
		oPanelAll := TPanel():New(00,00,,oDlg,,,,,,200,080,.F.,.F.)
		oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

			//Cria MarkBrowse de OS
			oMarPosto := FWMarkBrowse():New()
			oMarPosto:SetOwner(oPanelAll)
			oMarPosto:SetDescription(STR0050) //'Transferencia de Combustivel'
			oMarPosto:SetAlias(cAliasQry)
			oMarPosto:SetTemporary(.T.)
			oMarPosto:DisableReport()
			oMarPosto:SetFields(aFieldsMRK)
			oMarPosto:SetFieldMark( 'OK' )
			oMarPosto:SetSemaphore(.T.)
			oMarPosto:IsInvert( .F. )
			oMarPosto:SetWalkThru(.F.)
			oMarPosto:DisableReport()
			oMarPosto:DisableSaveConfig()
			oMarPosto:DisableConfig()
			oMarPosto:SetAfterMark( {|| AfterMark( oMarPosto, cAliasQry ) } )
			oMarPosto:Activate()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| IIf(CheckMarks(oMarPosto, cAliasQry, .T.), (lOk := .T., oDlg:End()), ) },;
													{|| IIf(CheckMarks(oMarPosto, cAliasQry, .F.), (lOk := .F., oDlg:End()), ) }) Centered

	If lOk
		dbSelectArea(cAliasQry)
		dbGoTop()
		While !Eof()

			If !Empty((cAliasQry)->OK)
				//Grava o registro de saida de combustivel
				NGIncTTV((cAliasQry)->TQJ_CODPOS, (cAliasQry)->TQJ_LOJA, (cAliasQry)->TQJ_TANQUE,;
				 		(cAliasQry)->TQJ_BOMBA, dDataBase, SubStr(Time(),1,5), "5", Nil, nQuantid, Nil, cNumDoc, cSerieDoc)
				Exit
			EndIf

			dbSelectArea(cAliasQry)
			dbSkip()
		End

	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} AfterMark
Realiza valida��o das marca��es. Quando uma op��o � marcada as outras s�o
desmarcadas, pois � poss�vel selecionar apenas um posto.

@param oMarPosto 	Objeto do MarkBrowse
@param cAliasQry    Alias da tabela tempor�ria

@author Tain� Alberto Cardoso
@since 20/11/2017

@return Nil Nulo
/*/
//---------------------------------------------------------------------
Static Function AfterMark( oMarPosto, cAliasQry )

	Local aArea		:= GetArea()
	Local cPostoMark	:= (cAliasQry)->TQJ_CODPOS + (cAliasQry)->TQJ_LOJA

	dbSelectArea( cAliasQry )
	dbSetOrder()
	dbGoTop()
	While !EoF()

		If (cAliasQry)->TQJ_CODPOS + (cAliasQry)->TQJ_LOJA <> cPostoMark
			If oMarPosto:IsMark()
				( cAliasQry )->( RecLock( cAliasQry, .F. ) )
				( cAliasQry )->OK := " "
				( cAliasQry )->( MsUnLock() )
			EndIf
		EndIf

		dbSelectArea( cAliasQry )
		dbSkip()
	EndDo

	RestArea(aArea)

Return .T.


//----------------------------------------------------------------------
/*/{Protheus.doc} CheckMarks
Verifica se algum posto foi marcada quando a tela foi confirmada.

@param oMarPosto 	Objeto do MarkBrowse
@param cAliasQry    Alias da tabela tempor�ria
@param lConfirm     Verificar se � na confirma��o da tela ou cancelamento

@author Tain� Alberto Cardoso
@since 20/11/2017

@return Nil Nulo
/*/
//---------------------------------------------------------------------
Static Function CheckMarks( oMarPosto, cAliasQry, lConfirm )

	Local lRet		:= .F.
	Local aArea	:= GetArea()

	Default lConfirm := .T.

	If lConfirm
		dbSelectArea( cAliasQry )
		dbSetOrder()
		dbGoTop()
		While !EoF()

			If oMarPosto:IsMark()
				lRet := .T.
			EndIf

			(cAliasQry)->( dbSkip() )
		EndDo

		If !lRet
			ShowHelpDlg(STR0006, {STR0051}, 2, ; //"Aten��o" ## "Nenhuma posto foi selecionado."
								{STR0052}, 2) //"Selecione um Posto/Loja para retirada de combustivel."
		EndIf
	ElseIf MsgYesNo(STR0053 +; //"Deseja n�o realizar a saida de combustivel ? "
	               STR0054) //"Caso n�o realizar, pode ser feita pela rotina de saida de combustivel no m�dulo de manuten��o de ativos."
		lRet := .T.
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT651DTTV
Deleta o registro de hist�rico da bomba ao deletar op
documento de saida do estoque
Fun��o utilizada na rotina de estoque MATA520

@param cNumDoc      Numero do documento de saida
@param cSerieDoc    Serie do documento de saida

@author Tain� Alberto Cardoso
@since 23/11/2017
@version MP12
@return L�gico
/*/
//---------------------------------------------------------------------
Function MNT651DTTV(cNumDoc, cSerieDoc)

	Local cQuery := ""
	Local cAliasQry := ''

	If NGCADICBASE("TTV_DOC","A","TTV",.F.)

		cAliasQry := GetNextAlias()

		//Buscar o registro de histor�co de bomba relacionado ao Documento de Saida
		cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("TTV") + " TTV "
		cQuery += "   WHERE TTV_DOC = " + ValToSQL(cNumDoc)
		cQuery += "   AND TTV_SERIE  = " + ValToSQL(cSerieDoc)
		cQuery += "   AND TTV.D_E_L_E_T_ <> '*' "

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()
		If !Eof()

			dbSelectArea("TTV")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			//Deleta o hist�rico da bomba
			NGDelTTV()

		EndIf

		(cAliasQry)->(DbCloseArea())

	EndIf

Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} MNT651TRAN
Realiza transferencia do produto
@type function

@author Tain� Alberto Cardoso
@since 30/07/2018

@param dDataTrans   Data da transferencia                     - Obrigat�rio
@param cProduOrig   C�digo do produto origem                  - Obrigat�rio
@param cTanquOrig   C�digo do almoxarifado do produto         - Obrigat�rio
@param nQauntidad   Quantidade a ser transferencia            - Obrigat�rio
@param cProduDest   C�digo do produto destino                 - Obrigat�rio
@param cTanquDest   C�digo do almoxafirado do produto destino - Obrigat�rio
@param nOpcx        3 = Inclus�o, 4 = Estorno                 - Obrigat�rio
@param cNumSeqEst   C�digo para gerar o estorno na SD3        - N�o obrigat�rio
@return Array,  [1] - Define se o processo foi realizado com �xito.
				[2] - Mensagem de erro, caso exista.
/*/
//-----------------------------------------------------------------------------
Static Function MNT651TRAN(dDataTrans,cProduOrig,cTanquOrig,nQuantidad,cProduDest,cTanquDest,nOpcx,cNumSeqEst)

	Local aAuto     := {}
	Local aLinha    := {}
	Local cAliasSD3 := ""
	Local cError    := ''
	Local lRet      := .T.
	Local nQuantSd3 := Round( nQuantidad, TAMSX3("D3_QUANT")[2] )

	Default cNumSeqEst := ""

	Private lMsErroAuto := .F.

	//Inclus�o
	If nOpcx == 3
		
		// Cabecalho a Incluir
		aAdd( aAuto, { NextNumero( 'SD3', 2, 'D3_DOC', .T. ), dDataTrans } )

		// Origem
		dbSelectArea( 'SB1' )
		dbSetOrder( 1 )
		If dbSeek( xFilial( 'SB1' ) + cProduOrig )
			
			aadd(aLinha,{"ITEM",'001',Nil})
			aadd(aLinha,{"D3_COD", cProduOrig, Nil}) //Cod Produto origem
			aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
			aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
			aadd(aLinha,{"D3_LOCAL", cTanquOrig, Nil}) //armazem origem
			aadd(aLinha,{"D3_LOCALIZ", "",Nil}) //Informar endere�o origem
		
		Else

			lRet   := .F.
			cError := STR0055 // N�o foi possivel localizar o combust�vel destino.

		EndIf

		//Destino
		dbSelectArea( 'SB1' )
		dbSetOrder( 1 )
		If lRet .And. dbSeek( xFilial( 'SB1' ) + cProduDest )
			
			aadd(aLinha,{"D3_COD", cProduDest, Nil}) //cod produto destino
			aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
			aadd(aLinha,{"D3_LOCAL", cTanquDest, Nil}) //armazem destino
			aadd(aLinha,{"D3_LOCALIZ", "",Nil}) //Informar endere�o destino

		Else

			lRet   := .F.
			cError := STR0056 // N�o foi possivel localizar o combust�vel destino.

		EndIf
		
		If lRet
		
			//Campos obrigat�rios para o ExecAuto
			aadd(aLinha,{"D3_NUMSERI", "",       Nil}) //Numero serie
			aadd(aLinha,{"D3_LOTECTL", "",       Nil}) //Lote Origem
			aadd(aLinha,{"D3_NUMLOTE", "", 		 Nil}) //sublote origem
			aadd(aLinha,{"D3_DTVALID", '',       Nil}) //data validade
			aadd(aLinha,{"D3_POTENCI", 0,        Nil}) // Potencia
			aadd(aLinha,{"D3_QUANT", nQuantidad, Nil}) //Quantidade
			aadd(aLinha,{"D3_QTSEGUM", 0,        Nil}) //Seg unidade medida
			aadd(aLinha,{"D3_ESTORNO", "",       Nil}) //Estorno
			aadd(aLinha,{"D3_NUMSEQ", "",        Nil}) // Numero sequencia D3_NUMSEQ

			aadd(aLinha,{"D3_LOTECTL", "",       Nil}) //Lote destino
			aadd(aLinha,{"D3_NUMLOTE", "",       Nil}) //sublote destino
			aadd(aLinha,{"D3_DTVALID", '',       Nil}) //validade lote destino
			aadd(aLinha,{"D3_ITEMGRD", "",       Nil}) //Item Grade

			aAdd(aAuto,aLinha)

		EndIf

	Else //Estorno
		dbSelectArea( 'SD3' )
		dbSetOrder( 4 ) //D3_FILIAL + D3_NUMSEQ + D3_CHAVE + D3_COD
		If MsSeek( xFilial( 'SD3' ) + PadR( cNumSeqEst, Len( SD3->D3_NUMSEQ ) ) )
			aAuto := { { SD3->D3_DOC, SD3->D3_EMISSAO } }
		EndIf
	EndIf

	If lRet

		MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcx)

		If lMsErroAuto

			cError := MostraErro( GetSrvProfString( 'Startpath', '' ) )
			lRet   := .F.

		ElseIf nOpcx == 3

			cAliasSD3 := GetNextAlias()

			BeginSQL Alias cAliasSD3
				
				SELECT 
					SD3.D3_NUMSEQ
				FROM 
					%table:SD3% SD3
				WHERE 
					SD3.D3_FILIAL  = %xFilial:SD3%    AND
					SD3.D3_DOC     = %exp:aAuto[1,1]% AND
					SD3.%NotDel%
					
			EndSQL

			If (cAliasSD3)->( !EoF() )

				//Busca o NumSeq da transferencia
				cNumSeOrig := (cAliasSD3)->D3_NUMSEQ
				cNumSeDest := (cAliasSD3)->D3_NUMSEQ

			EndIf

			(cAliasSD3)->(dbCloseArea())

		EndIf

	EndIf

Return { lRet, cError }
