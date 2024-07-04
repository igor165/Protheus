#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PLSA260EVDEF //MATA035EvDef
Classe Responsavel pelo Evento de validações e
atualizações do Cadastro de Grupo do Grupo Familiar
@author    Totver
@since     12/08/2019
/*/
Class PLSA260EVDEF From FwModelEvent
	Data auMovStatus	As Array
	Data oModel			As Object

	Method New() Constructor
	Method AfterTTS( oModel, cIdModel  )
	Method After(oSubModel, cModelId, cAlias, lNewRecord)
	Method ModelPreVld( oModel, cModelId )
	Method ModelPosVld( oModel, cModelId )
	//Method Before(oModel, cModelId)
	//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
	//Method BeforeTTS(oModel, cModelId)
	//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Totver
@since     12/08/2019
/*/
Method new() Class PLSA260EVDEF
	Self:oModel 	:= Nil
	Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Totver
@since     12/08/2019
/*/

Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PLSA260EVDEF
	Local cChvFam := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	Local cChvBA1 := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
	Local oModel  := FwModelActive()

	BEGIN TRANSACTION

		If oModel:GetOperation() == MODEL_OPERATION_DELETE

			//Gratuidade da familia
			BH5->(DbSetOrder(1))//BH5_FILIAL+BH5_CODINT+BH5_CODEMP+BH5_MATRIC
			If BH5->(MsSeek(xFilial('BH5')+cChvFam))
				While !BH5->(Eof()) .AND. BH5->(BH5_FILIAL+BH5_CODINT+BH5_CODEMP+BH5_MATRIC) == xFilial("BH5") + cChvFam

					BH5->(reclock("BH5",.F.))
					BH5->(DbDelete())
					BH5->(msUnlock())

					BH5->(dbSkip())
				EndDo
			EndIF

			//Opcional da familia
			BF1->(DbSetOrder(1))
			If BF1->(MsSeek(xFilial("BF1")+cChvFam))
				While ! BF1->(Eof()) .And. BF1->(BF1_FILIAL+BF1_CODINT+BF1_CODEMP+BF1_MATRIC) == xFilial("BF1")+cChvFam
					BF1->(reclock("BF1",.F.))
					BF1->(DbDelete())
					BF1->(msUnlock())

					BF1->(dbSkip())
				EndDo
			EndIF


			//Doenças pré existentes Beneficiario
			BF3->(DbSetOrder(1))//BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG+BF3_CODDOE+BF3_PAGAGR+BF3_UNAGR
			If BF3->(MsSeek(xFilial("BF3")+cChvBA1))
				While ! BF3->(Eof()) .And. BF3->(BF3_FILIAL+BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG) == xFilial("BF3")+cChvBA1
					BF3->(reclock("BF3",.F.))
					BF3->(DbDelete())
					BF3->(msUnlock())

					BF3->(dbSkip())
				EndDo
			EndIF

			//Opcionais do Beneficiario
			BF4->(DbSetOrder(1))//BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO
			If BF4->(MsSeek(xFilial("BF4")+cChvBA1))
				While ! BF4->(Eof()) .And. BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG) == xFilial("BF4")+cChvBA1
					BF4->(reclock("BF4",.F.))
					BF4->(DbDelete())
					BF4->(msUnlock())

					BF4->(dbSkip())
				EndDo
			EndIF

			//Forma de Cobrança Beneficiario
			BYX->(DbSetOrder(1))//BYX_FILIAL+BYX_CODOPE+BYX_CODEMP+BYX_MATRIC+BYX_TIPREG+BYX_CODOPC+BYX_VEROPC+BYX_CODFOR
			If BYX->(MsSeek(xFilial("BYX")+cChvBA1))
				While ! BYX->(Eof()) .And. BYX->(BYX_FILIAL+BYX_CODOPE+BYX_CODEMP+BYX_MATRIC+BYX_TIPREG) == xFilial("BYX")+cChvBA1
					BYX->(reclock("BYX",.F.))
					BYX->(DbDelete())
					BYX->(msUnlock())

					BYX->(dbSkip())
				EndDo
			EndIF

			//Gratuidade do Beneficiario
			BH6->(DbSetOrder(1))//BH6_FILIAL+BH6_CODINT+BH6_CODEMP+BH6_MATRIC+BH6_TIPREG
			If BH6->(MsSeek(xFilial("BH6")+cChvBA1))
				While ! BH6->(Eof()) .And. BH6->(BH6_FILIAL+BH6_CODINT+BH6_CODEMP+BH6_MATRIC+BH6_TIPREG) == xFilial("BH6")+cChvBA1
					BH6->(reclock("BH6",.F.))
					BH6->(DbDelete())
					BH6->(msUnlock())

					BH6->(dbSkip())
				EndDo
			EndIF

			//Cobertura do Beneficiario
			BFE->(DbSetOrder(1))//BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG+BFE_CODGRU
			If BFE->(MsSeek(xFilial("BFE")+cChvBA1))
				While ! BFE->(Eof()) .And. BFE->(BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG) == xFilial("BFE")+cChvBA1
					BFE->(reclock("BFE",.F.))
					BFE->(DbDelete())
					BFE->(msUnlock())

					BFE->(dbSkip())
				EndDo
			EndIF


			//Situações Adversas do Beneficiario
			BHH->(DbSetOrder(1))//BHH_FILIAL+BHH_CODINT+BHH_CODEMP+BHH_MATRIC+BHH_TIPREG+BHH_CODSAD
			If BHH->(MsSeek(xFilial("BHH")+cChvBA1))
				While ! BHH->(Eof()) .And. BHH->(BHH_FILIAL+BHH_CODINT+BHH_CODEMP+BHH_MATRIC+BHH_TIPREG) == xFilial("BHH")+cChvBA1
					BHH->(reclock("BHH",.F.))
					BHH->(DbDelete())
					BHH->(msUnlock())

					BHH->(dbSkip())
				EndDo
			EndIF

			//Faixa etária especifica do Beneficiario
			BDK->(DbSetOrder(1))//BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG
			If BDK->(MsSeek(xFilial("BDK")+cChvBA1))
				While ! BDK->(Eof()) .And. BDK->(BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG) == xFilial("BDK")+cChvBA1
					BDK->(reclock("BDK",.F.))
					BDK->(DbDelete())
					BDK->(msUnlock())

					BDK->(dbSkip())
				EndDo
			EndIF
		EndIF

	End TRANSACTION

Return .T.


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre validação do modelo
@author    Totver
@since     12/08/2019
/*/
Method ModelPreVld( oModel, cModelId ) Class PLSA260EVDEF
	Local nOperation := oModel:GetOperation()
	Local aArea      := GetArea()
	Local aAreaBA3   := BA3->(GetArea())
	Local aAreaBA1   := BA1->(GetArea())
	Local nContProds := 0
	Local oBA3
	Local oBA1
	Local cMatricOld := "AUTO"
	Local cCodInt    := Substr(BQC->BQC_CODIGO,1,4) //00010002
	Local cCodEmp    := BQC->BQC_CODEMP
	Local cMatricNew := ""

	If cModelID == "BA3DETAIL" .AND. nOperation == MODEL_OPERATION_INSERT
		If lJuridico .AND. Empty(oModel:GetValue( 'BA3DETAIL',  'BA3_CODPLA')) .AND. oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS') == '2'
			BT6->( dbSetorder(1) )
			If BT6->( MsSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)) )
				nRegBT6 := BT6->( Recno() )
				While !BT6->(Eof()) .and. BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+;
						BT6->BT6_VERCON+BT6->BT6_SUBCON+BT6->BT6_VERSUB == BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
					nContProds++
					BT6->( dbSkip() )
				Enddo
				If nContProds == 1
					BT6->( dbGoto(nRegBT6) )
					oModel:LoadValue( 'BA3DETAIL',  'BA3_CODPLA',AllTrim(BT6->BT6_CODPRO))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_VERSAO',AllTrim(BT6->BT6_VERSAO))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_DESPLA',Substr(Posicione("BI3",1,xFilial("BI3")+SUBSTR(cKeySubCon,1,4)+BT6->(BT6_CODPRO+BT6_VERSAO),"BI3_DESCRI"),1,30))
					BT9->( dbSetorder(01) )
					If BT9->( MsSeek(xFilial("BT9")+BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)))
						oModel:LoadValue( 'BA3DETAIL',  'BA3_FORPAG',AllTrim(BT9->BT9_CODFOR) )
					Endif
					oModel:LoadValue( 'BA3DETAIL',  'BA3_RATSAI',AllTrim(BT6->BT6_RATSAI))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_DESMEN',BT6->BT6_DESMEN)

					PLSA260GCMvc(oModel)

					If !IsInCallStack("PL260MVC01")//Desvio para automação
						oView := FwViewActive()
						oView:Refresh()
					EndIf

				Endif
			Endif
		Endif


		RestArea(aAreaBA3)
		RestArea(aAreaBA1)

	Endif

	RestArea(aArea)

Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PLSA260EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    Totver
@since     12/08/2019
/*/
Method ModelPosVld( oModel, cModelId ) Class PLSA260EVDEF
	LOCAL nOperation := oModel:GetOperation()
	Local cMatricNew := "AUTO"
	Local cCodInt    := oModel:GetValue("BA3DETAIL","BA3_CODINT")
	Local cCodEmp    := oModel:GetValue("BA3DETAIL","BA3_CODEMP")
	Local _nH        := NIL
	Local cCodPla    := oModel:GetValue("BA3DETAIL","BA3_CODPLA")
	Local cVerPla    := oModel:GetValue("BA3DETAIL","BA3_VERSAO")
	Local cIdModel   := oModel:GetId()
	Local lRet 		 := .T.
	LOCAL dInclusao  := oModel:GetValue("BA1MASTER","BA1_DATINC") //INCLUSÃO BENEFICIARIO
	LOCAL cTipusu 	 := oModel:GetValue("BA1MASTER","BA1_TIPUSU")// T-TITULAR D-DEPENDENTE
	LOCAL dtIncFamilia 	 := oModel:GetValue("BA3DETAIL","BA3_DATBAS")


	//Deleção e View não precisa de valisdaçãoes abaixo
	If (nOperation == MODEL_OPERATION_VIEW) .OR. (nOperation == MODEL_OPERATION_DELETE)
		Return(.T.)
	EndIF

	//Validação da data de inclusão do Titular e do Dependente
	IF cTipusu == GetNewPar("MV_PLCDTIT")
		IF dInclusao <> dtIncFamilia
			Help(,, "Atenção!",,"A data de inclusão do TITULAR não pode ser diferente da data de inclusão da família.",1, 0,,,,,,{"Informe a data de inclusão do Beneficiario novamente"})
			Return .F.
		ENDIF
	ELSE
		IF dInclusao < BA3->BA3_DATBAS
			Help(,, "Atenção!",,"A data de inclusão do DEPENDENTE não pode ser menor do que a data de inclusão da família.",1, 0,,,,,,{"Informe a data de inclusão do Beneficiario novamente"})
			Return.F.
		ENDIF
	ENDIF

	// Validando as funcionalidades
	If BG9->BG9_TIPO == "2" .And. !PLSA260Vld(.T.)
		Return(.F.)
	Endif

	//Inicio da Transacao...
	_nH := PLSAbreSem("PLSA260EVE.SMF")

	Begin Transaction

		// Valida se a versao do produto esta ativa
		DbSelectArea("BIL")
		BIL->(DbSetOrder(1))
		BIL->(MsSeek(xFilial("BIL") + cCodInt + cCodPla + cVerPla))

		If !Empty(DtoS(BIL->BIL_DATFIN)) .AND. BIL->BIL_DATFIN < dDataBase .And.;
				Aviso(OemtoAnsi(STR0071),OemtoAnsi(STR0178)+CHR(10)+CHR(13)+; //"Atenção"###"A versão do produto informada na família está encerrada."
				OemtoAnsi(STR0179),{OemtoAnsi(STR0085),OemtoAnsi(STR0086)},1) <> 1 //"Deseja continuar?"###"Sim"###"Não"
			lRet := .F.
			DisarmTransaction()
			Return()
		EndIf


		If nOperation == MODEL_OPERATION_INSERT .And. !IsNumeric(oModel:GetValue('BA1MASTER',  'BA1_MATRIC'))
			If 	cModelId == "PL260DEPMVC" // inclusao de dependennte
				cMatricNew := Substr(oModel:GetValue("BA3DETAIL", "MATTIT"),9,6)
			Else
				cMatricNew := PLPROXMAT(cCodInt,cCodEmp, cFilBA1)
			Endif
			oModel:LoadValue( 'BA3DETAIL',  'BA3_MATRIC', cMatricNew)
			oModel:LoadValue( 'BA1MASTER',  'BA1_MATRIC', cMatricNew)
			oModel:LoadValue( 'BA1MASTER',  'BA1_CODEMP', cCodEmp)
			oModel:LoadValue( 'BA1MASTER',  'BA1_MUDFAI', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INTERD', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_OPERES', PLSINTPAD())
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCANS', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCATE', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCEMI', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_REEWEB', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_10ANOS', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INSALU', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INFCOB', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCSIB', '0')

			If oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS') == '2' //Iif(lJuridico,"2","1")
				oModel:LoadValue( 'BA3DETAIL',  'BA3_CONEMP', AllTrim(BQC->BQC_NUMCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_VERCON', AllTrim(BQC->BQC_VERCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_SUBCON', AllTrim(BQC->BQC_SUBCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_VERSUB', AllTrim(BQC->BQC_VERSUB))
				oModel:LoadValue( 'BA1MASTER',  'BA1_CONEMP', AllTrim(BQC->BQC_NUMCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_VERCON', AllTrim(BQC->BQC_VERCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_SUBCON', AllTrim(BQC->BQC_SUBCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_VERSUB', AllTrim(BQC->BQC_VERSUB))
			EndIF
			// Calcula o digito verificador
			oModel:LoadValue( 'BA1MASTER',  'BA1_DIGITO', Modulo11(PLSINTPAD()+cCodEmp+cMatricNew+oModel:GetValue( 'BA1MASTER',  'BA1_TIPREG')))

		Endif
	End Transaction
	PLSFechaSem(_nH,"EVE")


Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/
Method AfterTTS( oModel, cIdModel ) Class PLSA260EVDEF
	Local lRet			:= .T.
	Local nOperation    := oModel:GetOperation()
	Local nContProds	:= 0
	Local nContForma    := 0
	Local cIdModel   	:= oModel:GetId()
	Local lApiCentral   := GetNewPar("MV_PLAPICO",.F.)
	Local lDocNotEnt	:= .F.
	Local lAutomato 	:= IsInCallStack("PL260MVC01") .or. IsInCallStack("PL260MVC02") //Automação
	Local lVinc 		:= GetNewPar("MV_PLCAROP","0") <> 0


	//Posiciono a BA3, pois necessito do CODPLA da familia
	BA3->(DbSetOrder(1))
	BA3->(DbGotop())

	BA3->(DbSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

	//Outras Validações apos commit
	If  nOperation == MODEL_OPERATION_INSERT .And. !PL260MVCOK(nOperation,oModel)
		Return(.F.)
	EndIf


	If (!Empty(oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG')) .Or. BA1->BA1_TIPUSU <> "T") .and. nOperation == MODEL_OPERATION_INSERT .Or.  (nOperation == MODEL_OPERATION_DELETE)

		Begin Transaction
			//Atualização da faixa etaria
			If BA1->BA1_TIPUSU ="T"
				PLS260FAIXA(nOperation, oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS'),BA1->BA1_MATRIC)
			EndIF
			//Documentos Obrigatórios
			P260ChkDoc(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_TIPREG,BA1->BA1_TIPUSU,BA1->BA1_GRAUPA,BA1->BA1_SEXO,Calc_Idade( dDataBase , BA1->BA1_DATNAS ),nOperation,@lDocNotEnt)

			//Carrega taxa de adesao...
			If BA1->BA1_TIPUSU ="T"
				PL260AdeMVC(nOperation,BA1->BA1_TIPUSU,BA1->BA1_MATRIC)
			EndIF

			//Carrega Grupos Determinados..
			If BA1->BA1_TIPUSU ="T"
				PL260GrpDet(nOperation,BA1->BA1_TIPUSU,BA1->BA1_MATRIC)
			EndIF

			// Opcionais da Familia
			If lVinc .And. BA1_TIPUSU = "T" 
				PL260OpcMVC(nOperation, .T.)
			ElseIf lVinc .And. BA1->BA1_TIPUSU <> "T" 
				PL260OpcMVC(nOperation, .F.)
			EndIf

			//Habilita a cobrança de novos dependentes no ato da inclusão.
			If GetNewPar("MV_PLSCBND","0") == "1" .and. cIdModel == "PL260DEPMVC"
				P260CbInAto(oModel)
			Endif

			If lApiCentral
				//Envia informações para modulo da central de Obrigações
				PL260ENVBENCO(oModel)
			Endif

			//Gerando informação SA1/BA1/BA3/BTS
			GerSincronismo()



		End Transaction

		If lDocNotEnt .and. nOperation == MODEL_OPERATION_INSERT

			If lAutomato .or. MsgYesNo("Existem documentos obrigatorios não entregues. Deseja confirmar a entrega?")
				If (!lAutomato,FWExecView('','PLSA260BCP', 4,, { || .T. } ) <> 0 ,.T.)
			Endif

		Endif


	EndIF

Return .T.


/*/{Protheus.doc} GerSincronismo
Função chamada para atualizar SA1/BA3/BTS/BA1 funcionada como sincronixador de cadastro
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/

Function GerSincronismo(oModel)

	Local cTipTit 		:= SuperGetMv("MV_PLCDTIT")
	Local aAreaBA1		:= BA1->(GetArea())
	Local lExiOutResp	:= .F.
	Local nRecOutResp	:= BA1->(Recno())
	Local nRecRespTit	:= BA1->(Recno())
	Local cCriaCli		:= GetNewPar("MV_PLSFMCL","1")
	Local cCodSA1		:=''
	Local cLojSa1		:=''

	Default oModel = nil
	DbSelectArea("BA1")
	SET FILTER TO
	BA1->(DbSetOrder(1))

	cCodInt	:=	BA1->BA1_CODINT
	cCodEmp	:=	BA1->BA1_CODEMP
	cMatric	:=	BA1->BA1_MATRIC

	//Descobrindo o responsavel da familia ou o endereco de origem

	//Descobrindo o responsavel da familia ou o endereco de origem
	If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

		While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric
			If BA1->BA1_TIPUSU	= cTipTit
				If cCriaCli ='1'
					// Gravando Cliente a partir do titular
					SA1->( dbSetorder(3) )
					If !SA1->( MsSeek(xFilial("SA1")+BA1->BA1_CPFUSR) )
						SA1->(RecLock("SA1",.T.))
						SA1->A1_FILIAL := xFilial("SA1")
						cVlCod         := CriaVar("A1_COD")
						cVlLoj         := CriaVar("A1_LOJA")
						cCodSa1        := If(!Empty(cVlCod),cVlCod,GetSX8Num("SA1","A1_COD"))
						cLojSa1        := If(!Empty(cVlLoj),cVlLoj,StrZero(1,TamSx3("A1_LOJA")[1]))

						SA1->A1_COD    := cCodSA1
						SA1->A1_LOJA   := cLojSA1
						SA1->A1_TIPO   := "F"
						PlsSinc("PLSA260","BA1","SA1",NIL,.T.,BA1->(RECNO()),NIL,NIL,SA1->(RECNO()))
						SA1->(MsUnLock())
						ConfirmSX8()


					Else
						PlsSinc("PLSA260","BA1","SA1",NIL,.T.,BA1->(RECNO()),NIL,NIL,SA1->(RECNO()))

						/*	If oModel <> nil
						oModel:GetModel("BA3MASTER"):LoadValue("BA3_CODCLI"	,SA1->A1_COD)
						oModel:GetModel("BA3MASTER"):LoadValue("BA3_LOJA"	,SA1->A1_LOJA)
						Endif	*/

					Endif
					If BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
						// Gravando familia
						BA3->(RecLock("BA3",.F.))
						BA3->BA3_CODCLI = SA1->A1_COD
						BA3->BA3_LOJA	= SA1->A1_LOJA
						If BA3->BA3_TIPOUS == '1'
							// Se tratando de pessoa Fisica ja gravo o nivel
							BA3->BA3_COBNIV = "1"
						EndIF

						BA3->(MsUnLock())

					Endif
				Endif

			Endif


			If  (BA1->BA1_ORIEND $ '1|5' .And. BA1->BA1_TIPUSU	== cTipTit ) .Or. (BA1->BA1_ORIEND $ '1|5' .And. BA1->BA1_RESFAM = '1' )

				cCodInt	:=	BA1->BA1_CODINT
				cCodEmp	:=	BA1->BA1_CODEMP
				cMatric	:=	BA1->BA1_MATRIC
				cCepUsr :=	BA1->BA1_CEPUSR
				cEndere	:= 	BA1->BA1_ENDERE
				cBairro :=	BA1->BA1_BAIRRO
				cMunici :=	BA1->BA1_MUNICI
				cEstado :=	BA1->BA1_ESTADO
				cCodMun	:=	BA1->BA1_CODMUN
				cNrEnd 	:=	BA1->BA1_NR_END
				cComend	:=	BA1->BA1_COMEND
				cTipEnd :=	BA1->BA1_TIPEND
				cResExt	:=	BA1->BA1_RESEXT
				nRecRespTit	:= BA1->(Recno())
				Exit
			Endif
			BA1->(DbSkip())
		Enddo
	Endif

	//Apos Veiricar o endereco do titular ou responsavel sera aplciado nos usuarios da mesma famila caso esteja configurado BA1->BA1_ORIEND	 ou BA1_RESFAM
	BA1->(DbGoTop())
	If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

		While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric

			If  BA1->BA1_ORIEND $ '1|5' .And.  nRecRespTit <> BA1->(Recno())

				BA1->(RecLock("BA1",.F.))
				BA1->BA1_CODINT	:= cCodInt
				BA1->BA1_CODEMP	:= cCodEmp
				BA1->BA1_MATRIC	:= cMatric
				BA1->BA1_CEPUSR	:= cCepUsr
				BA1->BA1_ENDERE	:= cEndere
				BA1->BA1_BAIRRO	:= cBairro
				BA1->BA1_MUNICI	:= cMunici
				BA1->BA1_ESTADO	:= cEstado
				BA1->BA1_CODMUN	:= cCodMun
				BA1->BA1_NR_END := cNrEnd
				BA1->BA1_COMEND	:= cComend
				BA1->BA1_TIPEND	:= cTipEnd
				BA1->BA1_RESEXT	:= cResExt
				BA1->(Msunlock())
			Endif

			If BA1->BA1_RESFAM = '1' .And. BA1->BA1_TIPUSU	<> cTipTit .and. !Empty(BA1->BA1_DATBLO)
				lExiOutResp:= .T.
				nRecOutResp:= BA1->(Recno())
			Endif


			BA1->(DbSkip())
		Enddo
	Endif


	If GetNewPar("MV_PLRESFA",.F.) .And. BA1->( FieldPos("BA1_RESFAM") ) > 0 .And. lExiOutResp
		BA1->(DbGoTo(nRecOutResp))

		cCodInt	:=	BA1->BA1_CODINT
		cCodEmp	:=	BA1->BA1_CODEMP
		cMatric	:=	BA1->BA1_MATRIC
		cCepUsr :=	BA1->BA1_CEPUSR
		cEndere	:= 	BA1->BA1_ENDERE
		cBairro :=	BA1->BA1_BAIRRO
		cMunici :=	BA1->BA1_MUNICI
		cEstado :=	BA1->BA1_ESTADO
		cCodMun	:=	BA1->BA1_CODMUN
		cNrEnd 	:=	BA1->BA1_NR_END
		cComend	:=	BA1->BA1_COMEND
		cTipEnd :=	BA1->BA1_TIPEND
		cResExt	:=	BA1->BA1_RESEXT
		BA1->(DbGoTop())

		If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

			While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric

				If BA1->(Recno()) <> nRecOutResp .And. BA1->BA1_ORIEND $ '1|5'

					BA1->(RecLock("BA1",.F.))
					BA1->BA1_CODINT	:= cCodInt
					BA1->BA1_CODEMP	:= cCodEmp
					BA1->BA1_MATRIC	:= cMatric
					BA1->BA1_CEPUSR	:= cCepUsr
					BA1->BA1_ENDERE	:= cEndere
					BA1->BA1_BAIRRO	:= cBairro
					BA1->BA1_MUNICI	:= cMunici
					BA1->BA1_ESTADO	:= cEstado
					BA1->BA1_CODMUN	:= cCodMun
					BA1->BA1_NR_END := cNrEnd
					BA1->BA1_COMEND	:= cComend
					BA1->BA1_TIPEND	:= cTipEnd
					BA1->BA1_RESEXT	:= cResExt
					BA1->(Msunlock())
				Endif

				BA1->(DbSkip())
			Enddo
		Endif

	Endif

	RestArea(aAreaBA1)

Return .T.

/*/{Protheus.doc}  PLSA260OK()
Função chamada para validar os itens na inclusão da familia
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/

Function PL260MVCOK(nOpc,oModel)

	Local  lRet			:= .T.

	// Parametro controla a criacao automatica de cliente na inclusao da familia |
	Local cCriaCli	:= GetNewPar("MV_PLSFMCL","1")
	Local cIdModel	:= oModel:GetId()
	Local lAutomato := IsInCallStack("PL260MVC01") .or. IsInCallStack("PL260MVC02") //Automação

	If BA3->BA3_TIPOUS == "2" .and. lRet .And. cIdModel == "PLSA260MVC" // pessoa juridica
		BQC->(DbSetOrder(1))
		If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
			BT5->(DbSetOrder(1))
			If BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)) )
				If BQC->BQC_OBRFAM == "1"  .And. BA3->BA3_COBNIV  # "1"
					If(!lAutomato,ApMsgAlert(OemtoAnsi(STR0070) ,OemtoAnsi(STR0071)),) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "
					lRet := .F.
				ElseIf BQC->BQC_COBNIV <> "1" .And. BT5->BT5_COBNIV <> "1" .And. Empty(BG9->BG9_CODCLI)
					If(!lAutomato,ApMsgAlert(OemtoAnsi(STR0070)+Chr(13)+OemtoAnsi(STR0171) ,OemtoAnsi(STR0071)),) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "###"A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato)."
					If(!lAutomato,FWExecView('Edição','PLSA260FD1COB', MODEL_OPERATION_UPDATE,, { || .T. } ),)
				EndIf
			EndIf
		EndIf
	Elseif BA3->BA3_TIPOUS == "1" .And. lRet // pessoa Fisica
		If Empty(BA3->BA3_CODCLI) .And. cCriaCli <> "1"
			If(!lAutomato,MsgAlert(OemtoAnsi(STR0068)+OemtoAnsi(STR0069)),) //  //"A criacao automatica de clientes esta desabilitada no paramentro MV_PLSFMCL, "##"e obrigatorio informa-lo manualmente juntamente com a data de vencimento"
			lRet := .F.
		Endif
	EndIf

	// Ponto de entrada para validacao de usuario para inclusao da familia.
	If lRet .and. ExistBlock("PLS260VU")
		lRet := Execblock("PLS260VU",.F.,.F.,{nOpc})
		If !lRet
			Return(.F.)
		EndIf
	EndIf

	// Valida se a versao do produto esta ativa
	DbSelectArea("BIL")
	BIL->(DbSetOrder(1))
	If (BA3->BA3_CODPLA <> M->BA3_CODPLA .Or.;
			BA3->BA3_VERSAO <> M->BA3_VERSAO) .And.;
			BIL->(MsSeek(xFilial("BIL") + M->BA3_CODINT + M->BA3_CODPLA + M->BA3_VERSAO))
		If !Empty(DtoS(BIL->BIL_DATFIN)) .AND. BIL->BIL_DATFIN < dDataBase .And.;
				If(!lAutomato,Aviso(OemtoAnsi(STR0071),OemtoAnsi(STR0178)+CHR(10)+CHR(13)+ OemtoAnsi(STR0179),{OemtoAnsi(STR0085),OemtoAnsi(STR0086)},1) <> 1,) ////"Atenção"###"A versão do produto informada na família está encerrada." ##"Deseja continuar?"###"Sim"###"Não"
			lRet := .F.
		EndIf
	EndIf

Return(lRet)



/*/{Protheus.doc}  P260CbInAto()
Função chamada para  a cobrança de novos dependentes no ato dainclusão.
Realizo as integrações
@author    Totver
@since     12/12/2019
/*/


Function P260CbInAto(oModel)

	Local aUsrCobAto	:= {}
	Local aAux			:= {}
	Local cAnoFt 		:= StrZero(Year(oModel:GetModel('BA1MASTER'):GetValue('BA1_DATINC')),4)
	Local cMesFt 		:= StrZero(Month(oModel:GetModel('BA1MASTER'):GetValue('BA1_DATINC')),2)
	Local lFatura 		:= .F.


	aadd(aUsrCobAto,BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+oModel:GetModel('BA1MASTER'):GetValue('BA1_TIPREG')+oModel:GetModel('BA1MASTER'):GetValue('BA1_DIGITO'))

	aAux := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),	BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,1)

	If Len(aAux) > 0 .And. Len(aAux[1]) > 17
		cNiv := aAux[1][18]
		If cNiv == "1" // Empresa
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP
		ElseIf cNiv == "2" //Nivel contrato
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON
		ElseIf cNiv == "3"  //Nivel subcontrato
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
		ElseIf cNiv == "4" //Nivel familia
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		ElseIf cNiv == "5" //Usuario
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		EndIf

		BBT->(DbSetOrder(Val(cNiv)))
		If BBT->(MsSeek(xFilial("BBT")+cNiv+cChv+cAnoFt+cMesFt))
			lFatura := .T.
		EndIf

	Else
		//Caso nao consiga pegar o nivel de cobranca, faz o tratamento fixo na Familia como ja existia...
		BBT->(dbSetOrder(4))
		If BBT->(MsSeek(xFilial("BBT")+"4"+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAnoFt+cMesFt))
			lFatura := .T.
		EndIf

	EndIf

	If !lFatura .And. !(Empty(cAnoFt) .Or. Empty(cMesFt))
		Aviso("Atenção","Ainda não foi gerado o faturamento da competência "+cAnoFt+"/"+cMesFt+" para esta família."+CHR(10)+CHR(13)+;//Atenção###"Ainda não foi gerado o faturamento da competência "###" para esta família."
			"A cobrança do(s) dependente(s) incluso(s) será processada ao gerar a cobrança da família na rotina de faturamento.",{"Ok"},2) //"A cobrança do(s) dependente(s) incluso(s) será processada ao gerar a cobrança da família na rotina de faturamento."###"Ok"
	ElseIf Len(aUsrCobAto) > 0 .And.(BA3->BA3_TIPOUS == "1" .or. (BA3->BA3_TIPOUS <> '1' .AND. BA3->BA3_COBNIV == '1') ) .And.	lFatura .And.;
			(Aviso("A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato).","Deseja cobrar os novos dependentes incluidos neste momento ?",{"Sim","Não"},1)==1) // "Deseja cobrar os novos dependentes incluidos neste momento ?"

		PLSCBMSINC(aUsrCobAto,.T.,BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),'4',cAnoFt,cMesFt,2)
		lMsgDepInc := .F.
	EndIf



Return


/*/{Protheus.doc}  P260ChkDoc()
Função chamada para  tratamento de documentos obrigatorios
Realizo as integrações
@author    Totver
@since     12/12/2019
/*/

Function P260ChkDoc(cCodInt,cCodEmp,cMatric,cTpRg,cTipUsu,cGrauPar,cSexo,nIdade,nOperation,lDocNotEnt)

	Local aArea   := GetArea()
	LOCAL cSQL
	LOCAL cNumCon := BA1->BA1_CONEMP
	LOCAL cVerCon := BA1->BA1_VERCON
	LOCAL cSubCon := BA1->BA1_SUBCON
	LOCAL cVerSub := BA1->BA1_VERSUB
	LOCAL cCodPla := BA3->BA3_CODPLA
	LOCAL cVerPla := BA3->BA3_VERSAO
	LOCAL nAcha   := 0
	Local lFlag	  := .F.
	Local oModelBCP := nil
	Default lDocNotEnt	:=.F.

	DbSelectArea("BCP")
	DbSetOrder(1)

	oModelBCP := FWLoadModel("PLSA260BCP")


	oModelBCP:SetDescription( "Inclusão de Documentos" )
	oModelBCP:SetOperation(nOperation)
	oModelBCP:activate(.T.)


	oBA1 := oModelBCP:getModel( 'BA1MASTER' )
	oBCP := oModelBCP:getModel( 'BCPDETAIL' )

	aSaveLines := FWSaveRows()
	nLine:= 1



	//Deletando os dados tanto pessoa fisica como juridica
	If  (nOperation == MODEL_OPERATION_DELETE)

		If BCP->(DbSeek( xFilial('BCP')+cCodInt+cCodEmp+cMatric))
			while !BCP->(Eof()) .and. BCP->(BCP_FILIAL+BCP_CODOPE+BCP_CODEMP+BCP_MATRIC) == xFilial('BCP')+cCodInt+cCodEmp+cMatric
				RecLock("BCP",.F.)
				dbDelete()
				Msunlock()
				BCP->(dbSkip())
			Enddo

		Endif
		Return (.T.)
	Endif



	//Posiciona nos documentos definidos no Sub Contrato...
	BCO->(DbSetOrder(1))
	if BCO->(MsSeek(xFilial("BCO")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))
		nAcha := 1
	endif

	If nAcha == 0
		BQP->(DbSetOrder(1))
		If BQP->(MsSeek(xFilial("BQP")+cCodInt+cCodPla+cVerPla))
			nAcha := 2
		EndIf
	endif
	If nAcha == 1

		cSQL := "SELECT  BCO_CODOPE, BCO_CODEMP, BCO_CODDOC, BCO_TIPUSR, BCO_GRAUPA, BCO_SEXO, BCO_IDAINI,BCO_IDAFIN,BCO_DOCOBR FROM "+RetSQLName("BCO")+" WHERE "
		cSQL += "BCO_FILIAL = '"+xFilial("BCO")+"' AND "
		cSQL += "BCO_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BCO_CODEMP = '"+cCodEmp+"' AND "
		cSQL += "BCO_NUMCON = '"+cNumCon+"' AND "
		cSQL += "BCO_VERCON = '"+cVerCon+"' AND "
		cSQL += "BCO_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BCO_VERSUB = '"+cVerSub+"' AND "
		cSQL += " D_E_L_E_T_= ''"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBCO", .T., .T.)

		TrbBCO->(DBGoTop())
		oBCP:GoLine(nLine)

		While !TrbBCO->(Eof())
			oBCP:LoadValue("BCP_FILIAL", xFilial("BCP"))
			oBCP:LoadValue("BCP_CODDOC", TrbBCO->(BCO_CODDOC))
			oBCP:LoadValue("BCP_ENTREG", TrbBCO->(BCO_DOCOBR))
			oBCP:LoadValue("BCP_CODOPE", TrbBCO->(BCO_CODOPE))
			oBCP:LoadValue("BCP_CODEMP", TrbBCO->(BCO_CODEMP))
			oBCP:LoadValue("BCP_MATRIC", BA1->BA1_MATRIC)
			oBCP:LoadValue("BCP_TIPREG", BA1->BA1_TIPREG)
			oBCP:LoadValue("BCP_DATINC", Date())
			oBCP:LoadValue("BCP_DOCOBR", TrbBCO->(BCO_DOCOBR))
			oBCP:LoadValue("BCP_DESCRI", Posicione("BD2",1,xFilial("BD2")+TrbBCO->(BCO_CODDOC),"BD2_DESCRI"))

			If TrbBCO->(BCO_DOCOBR) == '1' .And. TrbBCO->(BCO_DOCOBR) == '0'
				lDocNotEnt	:=.T.
			Endif

			TrbBCO->(DbSkip())
			If !TrbBCO->(Eof())
				nLine := oBCP:AddLine()
			Else
				If oModelBCP:VldData()
					oModelBCP:CommitData()
				Else
					aError := oModelBCP:GetErrorMessage()
				EndIf
			Endif
		Enddo
		TrbBCO->(DbCloseArea())
	Elseif nAcha == 2

		cSQL := "SELECT BQP_CODIGO, BQP_VERSAO, BQP_CODDOC, BQP_TIPUSR, BQP_GRAUPA, BQP_SEXO, BQP_IDAINI, BQP_IDAFIN, BQP_DOCOBR FROM "+RetSQLName("BQP")+" WHERE "
		cSQL += "BQP_FILIAL = '"+xFilial("BQP")+"' AND "
		cSQL += "BQP_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += "BQP_VERSAO = '"+cVerPla+"' AND "
		cSQL += " D_E_L_E_T_= ' '"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBCN", .T., .T.)


		While !TrbBCN->(Eof())
			oBCP:LoadValue("BCP_FILIAL", xFilial("BCP"))
			oBCP:LoadValue("BCP_CODDOC", TrbBCN->BQP_CODDOC)
			oBCP:LoadValue("BCP_ENTREG", If(TrbBCN->BQP_DOCOBR=='1','0','1'))
			oBCP:LoadValue("BCP_CODOPE", BA1->BA1_CODINT)
			oBCP:LoadValue("BCP_CODEMP", BA1->BA1_CODEMP)
			oBCP:LoadValue("BCP_MATRIC", BA1->BA1_MATRIC)
			oBCP:LoadValue("BCP_TIPREG", BA1->BA1_TIPREG)
			oBCP:LoadValue("BCP_DOCOBR", TrbBCN->BQP_DOCOBR)
			oBCP:LoadValue("BCP_DESCRI", Posicione("BD2",1,xFilial("BD2")+TrbBCN->(BQP_CODDOC),"BD2_DESCRI"))

			If TrbBCN->(BQP_DOCOBR) == '1' .And. TrbBCN->BQP_DOCOBR == '1'
				lDocNotEnt	:=.T.
			Endif

			TrbBCN->(DbSkip())

			If !TrbBCN->(Eof())
				nLine := oBCP:AddLine()
			Else
				If oModelBCP:VldData()
					oModelBCP:CommitData()
				Else
					aError := oModelBCP:GetErrorMessage()
				EndIf
			Endif

		Enddo
		TrbBCN->(DbCloseArea())
	Endif

	RestArea(aArea)

Return




/*/{Protheus.doc} PL260ENVBENCO
Função chamada para atualizar central de obrigações
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/

Function PL260ENVBENCO(oModel)


	Local   cUrl        := GetNewPar("MV_PLURLCO",'http://10.10.12.8080/rest/healthcare/v1')
	Local   oRestClient := FWRest():New(cUrl)
	Local   aHeader		:= {}
	Local   cJson       := ''
	Local 	cCodTitular	:= oModel:GetModel('BA1MASTER'):GetValue('BA1_CODINT')+oModel:GetModel('BA1MASTER'):GetValue('BA1_CODEMP')+oModel:GetModel('BA1MASTER'):GetValue('BA1_MATRIC')+oModel:GetModel('BA1MASTER'):GetValue('BA1_TIPREG')+oModel:GetModel('BA1MASTER'):GetValue('BA1_DIGITO')
	Local 	lExiteB3k	:= .F.


	Private oJson




	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0")+PlsIntPad()))

	BI3->(DbSetOrder(1))
	BI3->(DbSeek(xFilial("BI3")+PlsIntPad()+oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')))


	B3K->(DbSetOrder(8))
	If B3K->(DbSeek(xFilial("B3K")+BA1->BA1_CPFUSR))
		lExiteB3k:= .T.
	Endif
	cJson       :=	'{"address"'				+':"'+ Alltrim(BA1->BA1_ENDERE)		+'","
	cJson       +=  'addressComplement"'		+':"'+ Alltrim(BA1->BA1_COMEND)		+'","
	cJson       +=	'birthdate"'				+':"'+ Dtos(BA1->BA1_DATNAS)		+'","
	cJson       +=	'blockDate"'				+':"'+ ''							+'","
	cJson       +=	'cityCode"'					+':"'+ Alltrim(BTS->BTS_CODMUN)		+'","
	cJson       +=	'codeCco"'					+':"'+ Alltrim(BA1->BA1_CODCCO)		+'","
	cJson       +=	'codeSCPA"'					+':"'+ ''							+'","
	cJson       +=	'codeSusep"'				+':"'+ Alltrim(BI3->BI3_SUSEP)		+'","
	cJson       +=	'district"'					+':"'+ Alltrim(BA1->BA1_BAIRRO)		+'","
	cJson       +=	'effectiveDate"'			+':"'+ Dtos(BA1->BA1_DATINC)		+'","
	cJson       +=	'excludedItems"'			+':"'+ "0"							+'","
	cJson       +=	'gender"'					+':"'+ Alltrim(BA1->BA1_SEXO)		+'","
	cJson       +=	'guarantorCNPJ"'			+':"'+ Alltrim(BA0->BA0_CGC)		+'","
	cJson       +=	'healthInsuranceCode"'		+':"'+ Alltrim(BI3->(BI3_CODIGO+BI3_VERSAO))		+'","
	cJson       +=	'healthInsurerCode"'		+':"'+ Alltrim(BA0->BA0_SUSEP)		+'","
	cJson       +=	'holderCPF"'				+':"'+ Alltrim(BA1->BA1_CPFUSR)		+'","
	cJson       +=	'holderRelationship"'		+':"'+ Alltrim(BA1->BA1_TIPREG)		+'","
	cJson       +=	'motherCPF"'				+':"'+ Alltrim(BA1->BA1_CPFMAE)		+'","
	cJson       +=	'mothersName"'				+':"'+ Alltrim(BA1->BA1_MAE)		+'","
	cJson       +=	'name"'						+':"'+ Alltrim(BA1->BA1_NOMUSR)		+'","
	cJson       +=	'nationalHealthCard"'		+':"'+ Alltrim(BA1->BA1_NRCRNA)		+'","
	cJson       +=	'notifyANS"'				+':"'+ 'True '						+'","
	cJson       +=	'StatusANS"'				+':"'+ 'I'							+'","
	cJson       +=	'partialCoverage"'			+':"'+ "0"							+'","
	cJson       +=	'residentAbroad"'			+':"'+ "0"							+'","
	cJson       +=	'sponsorCPF"'				+':"'+ " "							+'","
	cJson       +=	'stateAbbreviation"'		+':"'+ Alltrim(BA1->BA1_ESTADO)		+'","
	cJson       +=	'subscriberId"'				+':"'+ cCodTitular					+'","
	cJson       +=	'blockingReason"'			+':"'+ ""							+'","
	cJson       +=	'HouseNumbering"'			+':"'+ Alltrim(BA1->BA1_NR_END)		+'","
	cJson       +=	'TypeOfAddress"'			+':"'+ "2"							+'","
	cJson       +=	'skipRuleName"'				+':"'+ "0"							+'","
	cJson       +=	'skipRuleMothersName"'		+':"'+ "0"							+'","
	cJson       +=	'OperatorPlanCode"'			+':"'+ ""							+'","
	cJson       +=	'ZIPCode"'					+':"'+ Alltrim(BA1->BA1_CEPUSR)		+'"}"

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8" )
	aAdd(aHeader, "Accept: application/json" )
	aAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")


	If lExiteB3k //Alterando
		oRestClient:setPath("/beneficiaries"+"/"+cCodTitular+"/?healthInsurerCode="+BA0->BA0_SUSEP+"&codeCco="+ Alltrim(B3K->B3K_CODCCO)	)
		If oRestClient:Put(aHeader, cJson)
			ConOut("PUT", oRestClient:GetResult())
		Else
			ConOut("PUT", oRestClient:GetLastError())
		EndIf
	Else
		oRestClient:SetPostParams(cJson)
		oRestClient:setPath("/beneficiaries")
		If oRestClient:Post(aHeader)
			ConOut("POST", oRestClient:GetResult())
		Else
			ConOut("POST", oRestClient:GetLastError())
		EndIf
	Endif

Return



/*/{Protheus.doc} PL260ENVBENCO
Função para atualização da forma de cobranca pessoa fisica ou juridica
Realizo as integrações
@author    Totver
@since     18/02/2019
/*/
Function PLS260FAIXA(nOperation,cTipUsu,cMatric)

	Local	oModelBjk 	:= FwLoadModel("PLSA260BJK")
	Local	oBJK		:= oModelBjk:GetModel("BJKDETAIL")
	Local	oBFY		:= oModelBjk:GetModel("BFYDETAIL")
	Local	oBBU		:= oModelBjk:GetModel("BBUDETAIL")
	Local 	nContForma	:= 0
	Local 	nContProds	:= 0
	Local	cChave		:=''
	Local 	lRet 		:= .F.

	Default cTipUsu		:= "0"

	oModelBjk:SetOperation(nOperation)
	oModelBjk:SetDescription( "Faixa de Cobrança" )
	oModelBjk:Activate()


	//Deletando os dados tanto pessoa fisica como juridica
	If  (nOperation == MODEL_OPERATION_DELETE)
		If BJK->(msSeek( xFilial('BJK')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			If oModelBjk:VldData()
				FwFormCommit(oModelBjk)
			Endif
		Endif
		Return(.T.)
	Endif

	If cTipUsu == "1" // Pessoa Fisica

		oModelBjk:SetValue("BJKDETAIL","BJK_CODFOR",BA3->BA3_FORPAG)
		If oModelBjk:VldData()
			lRet := FWFormCommit(oModelBjk)
		Endif

	ElseIf cTipUsu =="2"	// Pesso Juridica

		cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)//Alterar
		//Verifico se existe apenas 1 produto no subcontrato.
		BT6->( dbSetorder(01) )
		If BT6->( MsSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) ))
			nRegBT6 := BT6->( Recno() )
			While !BT6->(Eof()) .and. BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+;
					BT6->BT6_VERCON+BT6->BT6_SUBCON+BT6->BT6_VERSUB == BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
				nContProds++
				BT6->( dbSkip() )
			Enddo
		EndIF
		If nContProds == 1
			//Verifico se existe apenas uma forma de cobrança atrelada ao produto
			BT9->( dbSetorder(01) )
			If BT9->( MsSeek(xFilial("BT9")+BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)))
				While !BT9->(Eof()) .and. Substr(BT9->BT9_CODIGO,1,4)+Substr(BT9->BT9_CODIGO,5,4)+BT9->(BT9_NUMCON+BT9_VERCON+;
						BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO) == BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+;
						BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)
					nContForma++
					BT9->( dbSkip() )
				Enddo
			Endif
		EndIF
		If nContForma == 1

			oModelBjk:SetValue("BJKDETAIL","BJK_CODFOR",BT9->BT9_CODFOR)
			If oModelBjk:VldData()
				lRet := FWFormCommit(oModelBjk)
			Endif

		EndIf
	Endif


Return lRet

/*/{Protheus.doc} PL260FSalMVC
Substitui a função PL260Adesao
Sugere as formas de cobranca de adesao de acordo produto
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
Function PL260AdeMVC(nOperation,cTipUsu,cMatric)

	Local	oModelBJL	:= FwLoadModel("PLSA260BJL")
	Local	lTipUsu		:=  Empty(BA3->BA3_SUBCON)
	Local 	lRet		:= .F.

	Default nOperation	:= 3
	Default cTipUsu		:= BA1->BA1_TIPUSU
	Default cMatric		:= BA1->BA1_MATRIC

	oModelBJL:SetOperation(nOperation)
	oModelBJL:SetDescription( "Taxa de Adesão" )
	oModelBJL:Activate()

	BJL->(DbSetOrder(1))
	BFX->(DbSetOrder(1))

	//Deletando os dados tanto pessoa fisica como juridica
	If  (nOperation == MODEL_OPERATION_DELETE)
		If BJL->(DbSeek( xFilial('BJL')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			If oModelBJL:VldData()
				FwFormCommit(oModelBJL)
			Endif
		Endif
		Return(.T.)
	Endif


	If lTipUsu	// Pessoa Fisica - Taxa de Adesao

		dbSelectarea("BRY")
		BRY->(DbSetOrder(1))
		If BRY->(DbSeek(	xFilial("BRY") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + BA3->BA3_FORCTX))

			oModelBJL:LoadValue("BJLDETAIL","BJL_CODOPE",BA3->BA3_CODINT)
			oModelBJL:LoadValue("BJLDETAIL","BJL_MATRIC",cMatric)
			oModelBJL:LoadValue("BJLDETAIL","BJL_CODFOR",BRY->BRY_CODFOR)
			oModelBJL:LoadValue("BJLDETAIL","BJL_AUTOMA","1")

			If oModelBJL:VldData()
				lRet := FWFormCommit(oModelBJL)
			Endif
		EndIF

	Else	// Pessoa Juridica - Taxa de Adesao


		BR6->(DbSetOrder(1))

		If BR6->(DbSeek(	xFilial("BR6") + BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB + BA3->BA3_CODPLA + BA3->BA3_VERSAO ))

			oModelBJL:SetValue("BJLDETAIL","BJL_CODOPE",BA3->BA3_CODINT)
			oModelBJL:SetValue("BJLDETAIL","BJL_MATRIC",cMatric)
			oModelBJL:SetValue("BJLDETAIL","BJL_CODFOR",BR6->BR6_CODFOR)
			oModelBJL:SetValue("BJLDETAIL","BJL_AUTOMA","1")
		Endif
		If oModelBJL:VldData()
			lRet := FWFormCommit(oModelBJL)
		Endif


	EndIF


Return lRet



/*/{Protheus.doc} PL260FSalMVC
Substitui a função PL260Adesao
Carrega grupos DeTerminado na Familia
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
Function PL260GrpDet(nOperation,cTipUsu,cMatric)

	Local	oModelBFC	:= FwLoadModel("PLSA260BFC")
	Local	oBBFC		:= oModelBFC:GetModel("BFCDETAIL")
	Local	oBBVC		:= oModelBFC:GetModel("BVCDETAIL")

	Local	lTipUsu		:=  Empty(BA3->BA3_SUBCON)


	oModelBFC:SetOperation(nOperation)
	oModelBFC:SetDescription( "Grupos de Cobertura da Familia" )
	oModelBFC:Activate()

	BFC->(DbSetOrder(1))
	BVC->(DbSetOrder(1))

	//Deletando os dados tanto pessoa fisica como juridica
	If  (nOperation == MODEL_OPERATION_DELETE)
		If BFC->(DbSeek( xFilial('BFC')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			If oModelBFC:VldData()
				FwFormCommit(oModelBFC)
			Endif
		Endif
		Return(.T.)
	Endif


	If lTipUsu	// Pessoa Fisica - Carrega grupos DeTerminado

		dbSelectarea("BRV")
		BRV->(DbSetOrder(1))
		If BRV->(DbSeek(	xFilial("BRV") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO ))

			while !BRV->(eof()) .and. BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)

				oBBFC:LoadValue("BFC_CODINT",BA3->BA3_CODINT)
				oBBFC:LoadValue("BFC_CODEMP",BA3->BA3_CODEMP)
				oBBFC:LoadValue("BFC_MATRIC",cMatric)
				oBBFC:LoadValue("BFC_CODGRU",BRV->BRV_CODGRU)

				BRV->(dbSkip())
				If  BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
					oBBFC:AddLine()
				Endif

			EndDo

			dbSelectarea("BHI")
			BHI->(DbSetOrder(1))
			If BHI->(DbSeek(	xFilial("BHI") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO ))

				while !BHI->(eof()) .and. BHI->(BHI_FILIAL+BHI_CODINT+BHI_CODPLA+BHI_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)

					oBBVC:LoadValue("BVC_CODINT"	,BA3->BA3_CODINT)
					oBBVC:LoadValue("BVC_CODEMP"	,BA3->BA3_CODEMP)
					oBBVC:LoadValue("BVC_MATRIC"	,cMatric)
					oBBVC:LoadValue("BVC_CODGRU"	,BHI->BHI_CODGRU)
					oBBVC:LoadValue("BVC_TIPO"		,BHI->BHI_TIPO)
					oBBVC:LoadValue("BVC_CODGRU"	,BHI->BHI_CODGRU)
					oBBVC:LoadValue("BVC_CODGRU"	,BHI->BHI_CODGRU)
					oBBVC:LoadValue("BVC_QTD"		,BHI->BHI_QTD)
					oBBVC:LoadValue("BVC_PERCOP"	,BHI->BHI_PERCOP)
					oBBVC:LoadValue("BVC_VALCOP"	,BHI->BHI_VLRCOP)
					oBBVC:LoadValue("BVC_VALUS" 	,BHI->BHI_VALUS)
					oBBVC:LoadValue("BVC_LIMFRA" 	,BHI->BHI_LIMFRA)
					oBBVC:LoadValue("BVC_CODTAB"	,BHI->BHI_CODTAB)
					oBBVC:LoadValue("BVC_TXADM" 	,BHI->BHI_TXADM)
					oBBVC:LoadValue("BVC_SOMCOM"	,BHI->BHI_SOMCOM)
					oBBVC:LoadValue("BVC_PAGATO"	,BHI->BHI_PAGATO)
					oBBVC:LoadValue("BVC_PAGRDA"	,BHI->BHI_PAGRDA)
					oBBVC:LoadValue("BVC_SOMPRO"	,BHI->BHI_SOMPRO)
					oBBVC:LoadValue("BVC_VIGINI"	,BHI->BHI_VIGDE)
					oBBVC:LoadValue("BVC_VIGFIN"	,BHI->BHI_VIGATE)

					BHI->(dbSkip())
					If  BHI->(BHI_FILIAL+BHI_CODPLA+BHI_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
						oBBVC:AddLine()
					Endif

				EndDo
			Endif

			If oModelBFC:VldData()
				lRet := FWFormCommit(oModelBFC)
			Endif

		EndIF


	Else	// Pessoa Juridica - - Carrega grupos DeTerminado

		dbSelectarea("BT7")
		BT7->(DbSetOrder(1))
		If BT7->(DbSeek(	xFilial("BT7") + BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)))

			while !BT7->(eof()) .and. BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB ) == BA3->(BA3_FILIAL + BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB)

				oBBFC:LoadValue("BFC_CODINT"	,BA3->BA3_CODINT)
				oBBFC:LoadValue("BFC_CODEMP"	,BA3->BA3_CODEMP)
				oBBFC:LoadValue("BFC_MATRIC"	,cMatric)
				oBBFC:LoadValue("BFC_CODGRU"	,BT7->BT7_CODGRU)

				BT7->(dbSkip())
				If  BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB ) == BA3->(BA3_FILIAL +BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)
					oBBFC:AddLine()
				Endif

			EndDo

			dbSelectarea("BHF")
			BHF->(DbSetOrder(1))
			If BHF->(DbSeek(	xFilial("BHF") + BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB) ))

				while !BHF->(eof()) .and. BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB ) ==  BA3->(BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)

					oBBVC:LoadValue("BVC_CODINT"	,BA3->BA3_CODINT)
					oBBVC:LoadValue("BVC_CODEMP"	,BA3->BA3_CODEMP)
					oBBVC:LoadValue("BVC_MATRIC"	,cMatric)
					oBBVC:LoadValue("BVC_CODGRU"	,BHF->BHF_CODGRU)
					oBBVC:LoadValue("BVC_TIPO"		,BHF->BHF_TIPO)
					oBBVC:LoadValue("BVC_CODGRU"	,BHF->BHF_CODGRU)
					oBBVC:LoadValue("BVC_CODGRU"	,BHF->BHF_CODGRU)
					oBBVC:LoadValue("BVC_QTD"		,BHF->BHF_QTD)
					oBBVC:LoadValue("BVC_PERCOP"	,BHF->BHF_PERCOP)
					oBBVC:LoadValue("BVC_VALCOP"	,BHF->BHF_VALCOP)
					oBBVC:LoadValue("BVC_VALUS" 	,BHF->BHF_VALUS)
					oBBVC:LoadValue("BVC_LIMFRA"	,BHF->BHF_LIMFRA)
					oBBVC:LoadValue("BVC_CODTAB"	,BHF->BHF_CODTAB)
					oBBVC:LoadValue("BVC_TXADM" 	,BHF->BHF_TXADM)
					oBBVC:LoadValue("BVC_SOMCOM"	,BHF->BHF_SOMCOM)
					oBBVC:LoadValue("BVC_PAGATO"	,BHF->BHF_PAGATO)
					oBBVC:LoadValue("BVC_PAGRDA"	,BHF->BHF_PAGRDA)
					oBBVC:LoadValue("BVC_SOMPRO"	,BHF->BHF_SOMPRO)
					oBBVC:LoadValue("BVC_VIGINI"	,BHF->BHF_VIGINI)
					oBBVC:LoadValue("BVC_VIGFIN"	,BHF->BHF_VIGFIN)
					oBBVC:LoadValue("BVC_FINATE"	,BHF->BHF_FINATE)

					BHF->(dbSkip())
					If  BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB ) ==  BA3->(BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3->BA3_SUBCON + BA3_VERSUB)
						oBBVC:AddLine()
					Endif

				EndDo


			EndIF

			If oModelBFC:VldData()
				lRet := FWFormCommit(oModelBFC)
			Endif

		EndIF


	EndIF



Return .T.

/*/{Protheus.doc} PL260OpcMVC
Substitui a função PL260Opc
Atualiza os opcionais/forma de cobrança de acordo com produto ou subcontrato
@author Dev TOTVS
@since 13/05/2022
@version P12
/*/

Function PL260OpcMVC(nOperation, lFamilia)

	Local oModelBF1 	:= FwLoadModel("PLS260BF1MVC") //Opcionais da Familia
	Local oModelBF4     := FwLoadModel("PLBF4OPCMVC") //Opcionais do Beneficiário
	Local oBBF1 		:= oModelBF1:GetModel("BF1DETAIL")
	Local oBBF4		    := oModelBF4:GetModel("MASTERBF4")
	Local oBBK0			:= oModelBF1:GetModel("BK0DETAIL")
	Local oBBYX			:= oModelBF4:GetModel("BYXDETAIL")
	Local lIncSoVinc 	:= GetNewPar("MV_PLCAROP","0") == 2 //0=Nenhum;1=Todos;2=Apenas Vinculados
	Local nCount 		:= 1
	Local nTamDescr 	:= TamSX3('BF1_DESPRO')[1]
	Local nTamDesBF4    := TamSX3('BF4_DESPRO')[1]
	Local nTamBK0		:= TamSX3('BK0_DESFOR')[1]
	Local nTamBYX		:= TamSX3('BYX_DESFOR')[1]
	Local lRet          := .F.
	Local lAchou		:= .F.

	If lFamilia
		oModelBF1:SetOperation(nOperation)
		oModelBF1:SetDescription("Opcionais")
		oModelBF1:Activate()
	EndIf

	BF1->(DbsetOrder(1))
	BF4->(DbsetOrder(1))
	BK0->(DbSetOrder(1))
	BYX->(DbSetOrder(1))
	BHS->(DbSetorder(1))

	cKeyBHS := 	BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB+;
		BA3_CODPLA + BA3_VERSAO)
	cKeyBF4 := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BA1->BA1_TIPREG+BA1->BA1_CODPLA

	If M->BA3_TIPOUS <> "1" //2-Juridico
		// Posiciona nos opcionais do Subcontrato
		If BHS->( MsSeek(xFilial("BHS")+cKeyBHS) )
			cKeyBYX := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BHS->(BHS_CODPLA+BHS_VERPLA)+BA1->BA1_TIPREG
			cKeyBK0 := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BHS->(BHS_CODPLA+BHS_VERPLA)
			While !BHS->( Eof() ) .and. BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+;
					BHS_CODPRO+BHS_VERPRO) == cKeyBHS

				//Quando o parâmetro MV_PLCAROP for igual a 2, só trago os opcionais vinculados
				If lIncSoVinc .AND. BHS->BHS_TIPVIN == '0'
					BHS->( dbSkip() )
					Loop
				EndIf

				If lFamilia

					if empty( oModelBF1:getmodel('MasterBA1'):getvalue("BA1_MATRIC") )
						oModelBF1:getmodel('MasterBA1'):loadvalue("BA1_MATRIC", BA3->BA3_MATRIC)
					endif

					If !oBBF1:SeekLine({{"BF1_CODPRO", BHS->BHS_CODPLA}, {"BF1_VERPRO", BHS->BHS_VERPLA}})
						If(nCount > 1)
							oBBF1:AddLine()
						EndIF
						oBBF1:Goline( nCount )
						oBBF1:LoadValue("BF1_CODINT", BHS->BHS_CODINT)
						oBBF1:LoadValue("BF1_CODPRO", BHS->BHS_CODPLA)
						oBBF1:LoadValue("BF1_VERSAO", BHS->BHS_VERPLA)
						oBBF1:LoadValue("BF1_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BHS->BHS_CODINT+BHS->BHS_CODPLA,"BI3_DESCRI"), 1, nTamDescr))
						oBBF1:LoadValue("BF1_DATBAS", BA3->BA3_DATBAS)
						oBBF1:LoadValue("BF1_A300", "0")
						oBBF1:LoadValue("BF1_TIPVIN", BHS->BHS_TIPVIN)
						oBBF1:loadValue("BF1_MATRIC", BA3->BA3_MATRIC)
						nCount++

					EndIf
				Else
					If !BF4->(DBSeek(xFilial("BF4")+ cKeyBF4))
						oModelBF4:SetOperation(nOperation)
						oModelBF4:SetDescription("Opcionais do Beneficiário")
						oModelBF4:Activate()

						oBBF4:LoadValue("BF4_CODEMP", BA3->BA3_CODEMP)
						oBBF4:LoadValue("BF4_TIPREG", BA1->BA1_TIPREG)
						oBBF4:LoadValue("BF4_CODINT", BHS->BHS_CODINT)
						oBBF4:LoadValue("BF4_CODPRO", BHS->BHS_CODPLA)
						oBBF4:LoadValue("BF4_VERSAO", BHS->BHS_VERPLA)
						oBBF4:LoadValue("BF4_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BHS->BHS_CODINT+BHS->BHS_CODPLA,"BI3_DESCRI"), 1, nTamDesBF4))
						oBBF4:LoadValue("BF4_DATBAS", iif(empty(BA1->BA1_DATINC),CTOD(""),BA1->BA1_DATINC))
						oBBF4:LoadValue("BF4_A300", "0")
						oBBF4:LoadValue("BF4_TIPVIN", BHS->BHS_TIPVIN)
						oBBF4:SetValue("BF4_MATRIC", BA1->BA1_MATRIC)

						If BHS->BHS_TIPVIN == '1'
							If oModelBF4:VldData()
								lRet := FWFormCommit(oModelBF4)
							EndIF
							oModelBF4:DeActivate()
						EndIf
					EndIf
				EndIf

				If BHS->BHS_TIPVIN == '0' //Quando o opcional não é vinculado também leva as formas de cobrança
					BJW->(dbSetOrder(1))
					cKeyBJW := BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB)+;
						BHS->(BHS_CODPRO+BHS_VERPRO+BHS_CODPLA+BHS_VERPLA)
					If BJW->(MsSeek(xFilial("BJW")+cKeyBJW))
						While !BJW->( Eof() ) .And. BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC) == cKeyBJW

							If lFamilia
								If !BK0->(dbSeek(xFilial("BK0") + cKeyBK0))
									oBBK0:LoadValue("BK0_CODOPE", BHS->BHS_CODINT)
									oBBK0:LoadValue("BK0_CODEMP", BA3->BA3_CODEMP)
									oBBK0:LoadValue("BK0_MATRIC", BA3->BA3_MATRIC)
									oBBK0:LoadValue("BK0_VEROPC", BHS->BHS_VERPLA)
									oBBK0:LoadValue("BK0_CODOPC", BHS->BHS_CODPLA)
									oBBK0:LoadValue("BK0_CODFOR", BJW->BJW_CODFOR)
									oBBK0:LoadValue("BK0_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJW->BJW_CODFOR,"BJ1_DESCRI"),1, nTamBK0)
				
								EndIf
							Else
								If !BYX->(dbSeek(xFilial("BYX") + cKeyBYX))
									oBBYX:LoadValue("BYX_VEROPC", BHS->BHS_VERPLA)
									oBBYX:LoadValue("BYX_CODOPC", BHS->BHS_CODPLA)
									oBBYX:LoadValue("BYX_CODFOR", BJW->BJW_CODFOR)
									oBBYX:LoadValue("BYX_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJW->BJW_CODFOR,"BJ1_DESCRI"), 1, nTamBYX)
									oBBYX:LoadValue("BYX_TIPREG", BA1->BA1_TIPREG)
									oBBYX:LoadValue("BYX_RGIMP", '0')

									If oModelBF4:VldData()
										lRet := FWFormCommit(oModelBF4)
									EndIF

								EndIf
								oModelBF4:DeActivate()
							EndIf
							BJW->(dbSkip())
						EndDo
					EndIf
				EndIf
				BHS->(dbSkip())
			EndDo
		EndIf
	Else //1-Física
		cKeyBYX := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BT3->(BT3_CODPLA+BT3_VERPLA)+BA1->BA1_TIPREG
		cKeyBK0 := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BT3->(BT3_CODPLA+BT3_VERPLA)
		// Posiciona nos Opcionais do Produto
		If !BT3->( MsSeek(xFilial("BT3")+ BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
			Return .T.
		Else

			While !BT3->(Eof()) .And. BT3->(BT3_CODIGO+BT3_VERSAO) == BA3->BA3_CODINT+Iif(!lAchou, BA3->(BA3_CODPLA+BA3_VERSAO), BA1->(BA1_CODPLA+BA1_VERSAO))

				//Quando o parâmetro MV_PLCAROP for igual a 2, só trago os opcionais vinculados
				If lIncSoVinc .And. BT3->BT3_TIPVIN == '0'
					BT3->(dbSkip())
					Loop
				EndIf

				If lFamilia
					if empty( oModelBF1:getmodel('MasterBA1'):getvalue("BA1_MATRIC") )
						oModelBF1:getmodel('MasterBA1'):loadvalue("BA1_MATRIC", BA3->BA3_MATRIC)
					endif
					If !oBBF1:SeekLine({{"BF1_CODPRO", BT3->BT3_CODPLA}, {"BF1_VERPRO", BT3->BT3_VERPLA}})
						If(nCount > 1)
							oBBF1:AddLine()
						EndIF
						oBBF1:Goline( nCount )
						oBBF1:LoadValue("BF1_CODINT", BA3->BA3_CODINT)
						oBBF1:LoadValue("BF1_CODPRO", BT3->BT3_CODPLA)
						oBBF1:LoadValue("BF1_VERSAO", BT3->BT3_VERPLA)
						oBBF1:LoadValue("BF1_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BT3->(SubSTR(BT3_CODIGO,1,4)+BT3->(BT3_CODPLA+BT3_VERPLA)),"BI3_DESCRI"), 1, nTamDescr))
						oBBF1:LoadValue("BF1_DATBAS", BA3->BA3_DATBAS)
						oBBF1:LoadValue("BF1_A300", "0")
						oBBF1:LoadValue("BF1_TIPVIN", BT3->BT3_TIPVIN)
						oBBF1:loadValue("BF1_MATRIC", BA3->BA3_MATRIC)
						nCount++
					EndIf
				Else
					If !BF4->(DBSeek(xFilial("BF4")+ cKeyBF4))
						oModelBF4:SetOperation(nOperation)
						oModelBF4:SetDescription("Opcionais do Beneficiário")
						oModelBF4:Activate()

						oBBF4:LoadValue("BF4_CODEMP", BA1->BA1_CODEMP)
						oBBF4:LoadValue("BF4_TIPREG", BA1->BA1_TIPREG)
						oBBF4:LoadValue("BF4_CODINT", BA1->BA1_CODINT)
						oBBF4:LoadValue("BF4_CODPRO", BT3->BT3_CODPLA)
						oBBF4:LoadValue("BF4_VERSAO", BT3->BT3_VERPLA)
						oBBF4:LoadValue("BF4_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BT3->(SubSTR(BT3_CODIGO,1,4)+BT3->(BT3_CODPLA+BT3_VERPLA)),"BI3_DESCRI"), 1, nTamDesBF4))
						oBBF4:LoadValue("BF4_DATBAS", iif(empty(BA1->BA1_DATINC),CTOD(""),BA1->BA1_DATINC))
						oBBF4:LoadValue("BF4_A300", "0")
						oBBF4:LoadValue("BF4_TIPVIN", BT3->BT3_TIPVIN)
						oBBF4:SetValue("BF4_MATRIC", BA1->BA1_MATRIC)

						If BT3->BT3_TIPVIN == '1'
							If oModelBF4:VldData()
								lRet := FWFormCommit(oModelBF4)
							EndIF

							oModelBF4:DeActivate()
						EndIf
					EndIf
				EndIf

				If BT3->BT3_TIPVIN == '0' //Quando o opcional não é vinculado também leva as formas de cobrança

					BJY->(dbSetOrder(1))
					cKeyBJY := BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)

					If BJY->(MsSeek(xFilial("BJY")+cKeyBJY))
						While !BJY->( Eof() ) .and. BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY
							If lFamilia
								if !BK0->(dbSeek(xFilial("BK0") + cKeyBK0))
									oBBK0:LoadValue("BK0_CODFOR", BJY->BJY_CODFOR)
									oBBK0:LoadValue("BK0_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJY->BJY_CODFOR,"BJ1_DESCRI"),1, nTamBK0)

								EndIf
							Else
								If !BYX->(dbSeek(xFilial("BYX") + cKeyBYX))
									oBBYX:LoadValue("BYX_VEROPC", BT3->BT3_VERPLA)
									oBBYX:LoadValue("BYX_CODOPC", BT3->BT3_CODPLA)
									oBBYX:LoadValue("BYX_CODFOR", BJY->BJY_CODFOR)
									oBBYX:LoadValue("BYX_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJY->BJY_CODFOR,"BJ1_DESCRI"), 1, nTamBYX)
									oBBYX:LoadValue("BYX_RGIMP", '0')
									oBBYX:LoadValue("BYX_TIPREG", BA1->BA1_TIPREG)

									If oModelBF4:VldData()
										lRet := FWFormCommit(oModelBF4)
									EndIF
								EndIf
								oModelBF4:DeActivate()
							EndIf
							BJY->(dbSkip())
						EndDo
					EndIF
				EndIf
				BT3->(dbSkip())
			EndDo
		EndIF
	EndIf
	If lFamilia
		If oModelBF1:VldData()
			lRet := FWFormCommit(oModelBF1)
		EndIf
	EndIF

Return lRet


