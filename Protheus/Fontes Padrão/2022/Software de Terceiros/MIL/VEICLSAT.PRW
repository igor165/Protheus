////////////////
// Versao 013 //
////////////////

#include "protheus.ch"
#include "VEICLSAT.CH"

Function VEICLSAT()
Return()

/*/{Protheus.doc} DMS_Tecnico
	Classe para manipulacao de informacoes da equipe tecnica
	
	@type class
	@author Rubens
	@since 18/11/2015
	@version 1.0
/*/
Class DMS_Tecnico
	Data cCodigo
	Data cNome
	Data oConfig
	Method New() CONSTRUCTOR
	Method SetTecnico()
	Method SetTecByUserID()
	Method GetCodigo()
	Method GetConfig()
	Method Clean()
	
	Method LoadTecnico() // Não deve ser executado manualmente ...
	Method FindTecnico() // Não deve ser executado manualmente ...
	Method LoadConfig()  // Não deve ser executado manualmente ...
EndClass

/*/{Protheus.doc} New
	Metodo construtor de classe
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param _Codigo, character, Codigo do Tecnico
/*/
Method New(_Codigo) Class DMS_Tecnico
	Default _Codigo := ""
	Self:oConfig := DMS_DataContainer():New({})
	If !Empty(_Codigo)
		Self:SetTecnico(_Codigo)
	EndIf
Return Self

/*/{Protheus.doc} SetTecnico
	Carrega informacoes do tecnico pelo codigo do tecnico
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param _Codigo, character, Codigo do Tecnico
/*/
Method SetTecnico(_Codigo) Class DMS_Tecnico
	Self:FindTecnico(_Codigo,1)
Return

/*/{Protheus.doc} SetTecByUserID
	Carrega informacoes do tecnico pelo User ID (Codigo do usuario do Protheus)
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param _Codigo, character, Codigo do Tecnico
/*/
Method SetTecByUserID(cCodUserID) Class DMS_Tecnico
	Self:FindTecnico(cCodUserID,4)
Return

/*/{Protheus.doc} FindTecnico
Procura um tecnico pelo código e indice do protheus passado por parametro
@type method
@author Rubens
@since 25/11/2015
@version 1.0
@param _Codigo, caracter, Codigo utilizado para pesquisa
@param nOrdem, numérico, Numero do indice utilizado para pesquisa
/*/
Method FindTecnico(_Codigo,nOrdem) Class DMS_Tecnico
	Local cAtuAlias := Alias()
	Local aVAIArea := VAI->(GetArea())
	VAI->(dbSetOrder(nOrdem))
	If VAI->(MsSeek(xFilial("VAI") + _Codigo))
		Self:LoadTecnico()
	Else
		Self:Clean()
	EndIf
	RestArea(aVAIArea)
	If !Empty(cAtuAlias)
		dbSelectArea(cAtuAlias)
	EndIf
Return

/*/{Protheus.doc} LoadTecnico
Carrega propriedades do Tecnico a partir do registro do VAI posicionado na base de dados
@type method
@author Rubens
@since 25/11/2015
@version 1.0
/*/
Method LoadTecnico() Class DMS_Tecnico
	self:cCodigo := VAI->VAI_CODTEC
	self:cNome   := VAI->VAI_NOMTEC
	Self:LoadConfig()
Return

/*/{Protheus.doc} Clean
Limpa as propriedades da Classe
@type method
@author Rubens
@since 25/11/2015
@version 1.0
/*/
Method Clean() Class DMS_Tecnico
	self:cCodigo := ""
	self:cNome   := ""
	Self:oConfig:SetValue("VAI_FTESTQ" , "0" )
Return

/*/{Protheus.doc} LoadConfig
Carrega configuracoes do Tecnico
@type method
@author Rubens
@since 25/11/2015
@version 1.0
/*/
Method LoadConfig() Class DMS_Tecnico
	Self:oConfig:SetValue("VAI_FTESTQ" , IIF( VAI->(FieldPos("VAI_FTESTQ")) <> 0 , VAI->VAI_FTESTQ , "0" ) )
	Self:oConfig:SetValue("VAI_PROFIL" , VAI->VAI_PROFIL, "" )
	Self:oConfig:SetValue("VAI_FILPRO" , VAI->VAI_FILPRO, "" )
Return

/*/{Protheus.doc} GetConfig
Retorna uma determinada configuracao do Tecnico
@type method
@author Rubens
@since 25/11/2015
@version 1.0
@param cParConfig, character, Configuracao a ser retornada
/*/
Method GetConfig(cParConfig) Class DMS_Tecnico
Return Self:oConfig:GetValue(cParConfig)

/*/{Protheus.doc} GetCodigo
	Retorna o codigo do tecnico 
	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
/*/
Method GetCodigo() Class DMS_Tecnico
Return self:cCodigo

/*/{Protheus.doc} DMS_Transferencia
	Classe para fazer transferencia de itens para outras filiais
	
	@type class
	@author Vinicius Gati
	@since 22/12/2015
	@version 1.0
/*/
Class DMS_Transferencia
	Data cOrigem
	Data cDestino
	Data aItens
	Data aTransfsLote
	Data cArmDes
	Data aErros

	Method New() CONSTRUCTOR
	Method AjustaRes()
	Method Desreserva()
	Method Efetivar()
	Method Prepare()
	Method CalcPeso()
	Method CalcPesos()
EndClass

/*/{Protheus.doc} New
	Simples construtor

	@author       Vinicius Gati
	@since        26/11/15

/*/
Method New(cOrigem, cDestino, cArmDes, aItens) CLASS DMS_Transferencia
	::cOrigem      := cOrigem
	::cDestino     := cDestino
	::aItens       := aItens
	::cArmDes      := cArmDes
	::aTransfsLote := {}
	::aErros       := {}
Return SELF

/*/{Protheus.doc} Efetivar
	Criar orçamentos de transferencia e efetiva
	@type method
	@author Vinicius Gati
	@since 22/03/2016
	@version 1.0
/*/
Method Efetivar(cFileName) Class DMS_Transferencia
	Local nIdx    := 1
	Local nIdxC   := 1
	Local oFilHlp := DMS_FilialHelper():New()
	Local oCfgRes := DMS_EstoqueConfig():New()
	Local oEst    := DMS_Estoque():New()
	Local oPeca   := DMS_Peca():New()
	Local oMail   := DMS_EmailHelper():New()
	Local oLogger := DMS_Logger():New()
	Local cIteAnt := ""
	Local aItens  := {}
	Local aItensUnq := {}
	Local nPos    := 0
	Local cFilBck := cFilAnt
	Local lAny    := .F.
	Local oEmail     := DMS_EmailHelper():New()
	Local aDadEmail  := {{'Item', 'Quantidade'}}
	Local aDetEmail  := {{'Item', 'Detalhe'}}
	Local cEmDest := ""
	Local oItem   := nil
	Local cNumOrc
	

	self:Prepare()

	SA1->(DbGoTo( oFilHlp:GetCliente(self:cDestino) ))

	cFilAnt := self:cDestino
	cEmDest := GetNewPar("MV_MIL0089", "")
	cFilAnt := self:cOrigem
	cNumOrc := GetSXENum("VS1","VS1_NUMORC") // nao subir, tem que ser getsxe da origem


	nInd     := ASCAN(FWLoadSM0(), {|i| i[1] == cEmpAnt .AND. i[2] == cFilAnt })
	cCGCOrig := FWLoadSM0()[nInd][18]
	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))
	If !MsSeek(xFilial("SA2")+cCGCOrig)
		conout(STR0008 /*"Erro no posicionamento do fornecedor "*/+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
			AllTrim(RetTitle("A2_CGC"))+": "+Transform(cCGCOrig,x3Picture("A2_CGC")),"Atenção")
		Return(.f.)
	EndIf

	//
	// Validação de dados necessários para transferencia
	//
	Pergunte("OFM430",.F.)
	If ExistBlock("VCLSAT3") // PE para manipulação das Respostas da Pergunte OFM430 Transferência JDPrism
		ExecBlock("VCLSAT3",.f.,.f., {self:cOrigem, self:cDestino})
	EndIf
	cPVS3_OPER  := MV_PAR07
	cPVS3_FORMU := MV_PAR08
	if Empty(cPVS3_FORMU) .OR. Empty(cPVS3_OPER)
		oLogger:LogToTable({;
			{'VQL_AGROUP', 'DPMXFER' },;
			{'VQL_TIPO'  , 'WARNING' },;
			{'VQL_DADOS' , STR0009   } ;
		})
		conout(STR0009/*'Dados basicos para geração da nota não detectados, favor configurar na rotina OFINJD35("JDPRISM") importação cancelada.'*/)
		return .f.
	end

	for nIdx := 1 to LEN(self:aTransfsLote)
		oItem := self:aTransfsLote[nIdx]
		nPos := ASCAN(aItensUnq, {|oEl| oEl:GetValue('B1_COD') == oItem:GetValue('B1_COD') })
		if nPos > 0
			nTot := VAL(oItem:GetValue('QUANTIDADE')) + VAL(aItensUnq[nPos]:GetValue('QUANTIDADE'))
			aItensUnq[nPos]:SetValue('QUANTIDADE', STR(nTot))
		else
			AADD(aItensUnq, oItem)
		endif
	next

	For nIdx := 1 To Len(aItensUnq)
		oItem := aItensUnq[nIdx]

		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + oItem:GetValue('B1_COD') ))

		SB5->(dbSetOrder(1))
		SB5->(dbSeek( xFilial('SB5') + oItem:GetValue('B1_COD') ))

		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek( xFilial('SBZ') + oItem:GetValue('B1_COD') ))

		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))

		cTESEnt := MaTesInt(1,cPVS3_OPER,SA2->A2_COD,SA2->A2_LOJA,"C",SB1->B1_COD)
		cTESSai := MaTesInt(2,cPVS3_OPER,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)

		If Empty(cTESSai)
			conout("Erro TES -> " + STR0013 + STR0011 /*"Item:"*/ + SB1->B1_COD)
			AADD(self:aErros, {"Erro TES", STR0013 + STR0011 /*"Item:"*/ + SB1->B1_COD})
		else
			oItem:SetValue("TES_ENT", cTESEnt)
			oItem:SetValue("TES_SAI", cTESSai)
		EndIf
	Next

	if LEN(self:aErros) > 0
		for nIdx := 1 to LEN(self:aErros)
			AADD(aDetEmail, self:aErros[nIdx])
		next

		cTitulo := "[ERRO JDPRISM TRANSFER]" + STR0003 /*" Filial: "*/ + VS1->VS1_FILIAL + STR0007 /*" Destino: "*/ + self:cDestino
		if ! OFINJD3503_JaEnviouEmail(cFileName)
			oEmail:SendTemplate({;
				{'template'          , "jd_order"                  },;
				{'assunto'           , cTitulo                     },;
				{':titulo'           , cTitulo                     },;
				{':cabecalho1'       , STR0005/*'Dados:'*/         },;
				{':dados_cabecalho1' , {}                          },;
				{':cabecalho2'       , STR0006/*"Detalhes:"*/      },;
				{':dados_cabecalho2' , aDetEmail                   },;
				{'origem'            , GetNewPar("MV_MIL0088", "") },;
				{'destino'           , GetNewPar("MV_MIL0089", "") + ";" + cEmDest } ;
			})
		endif
		killapp(.t.)
	endif

	For nIdx := 1 To Len(aItensUnq)
		oItem := aItensUnq[nIdx]
		//
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + oItem:GetValue('B1_COD') ))
		//
		SB5->(dbSetOrder(1))
		SB5->(dbSeek( xFilial('SB5') + oItem:GetValue('B1_COD') ))
		//
		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek( xFilial('SBZ') + oItem:GetValue('B1_COD') ))
		//
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
		//

		if EMPTY(oItem:GetValue("LOTE", ""))
			lCtrlLote := .F.
			nSaldo := SaldoSb2()
			If nSaldo <= 0
				oLogger:LogToTable({;
					{'VQL_AGROUP', 'DPMXFER' },;
					{'VQL_TIPO'  , 'WARNING' },;
					{'VQL_DADOS' , STR0002 /* 'Item sem saldo para transferência' */ + " " + STR0011 /*"Peça: "*/ + oItem:GetValue('B1_COD') } ;
				})
				AADD(aDadEmail, { oItem:GetValue('B1_COD'), oItem:GetValue('QUANTIDADE') })
				loop
			EndIf
		Else
			lCtrlLote := .T.
		EndIf

		lAny := .T. //  se tem algum item em estoque

		reclock("VS3", .T.)
		VS3->VS3_FILIAL := xFilial('VS3')
		VS3->VS3_NUMORC := cNumOrc
		VS3->VS3_GRUITE := SB1->B1_GRUPO
		VS3->VS3_CODITE := SB1->B1_CODITE
		VS3->VS3_SEQUEN := STRZERO(nIdx, tamsx3("VS3_SEQUEN")[1])
		VS3->VS3_ARMORI := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		VS3->VS3_LOCAL  := VS3->VS3_ARMORI
		If lCtrlLote
			VS3->VS3_NUMLOT := oItem:GetValue('SUBLOTE')
			VS3->VS3_LOTECT := oItem:GetValue('LOTE')
			VS3->VS3_QTDITE := VAL( oItem:GetValue('QUANTIDADE') )
			AADD(aDadEmail, { SB1->B1_COD, VS3->VS3_QTDITE })
		Else
			If nSaldo < VAL( oItem:GetValue('QUANTIDADE') )
				VS3->VS3_QTDITE := nSaldo
			Else
				VS3->VS3_QTDITE := VAL( oItem:GetValue('QUANTIDADE') )
				AADD(aDadEmail, { SB1->B1_COD, STR(VS3->VS3_QTDITE) })
			EndIf
		EndIf
		VS3->VS3_QTDINI := VS3->VS3_QTDITE
		VS3->VS3_OPER   := cPVS3_OPER
		VS3->VS3_TESSAI := oItem:GetValue('TES_SAI')
		VS3->VS3_CODTES := VS3->VS3_TESSAI
		VS3->VS3_TESENT := oItem:GetValue('TES_ENT')
		VS3->VS3_VALPEC := FG_FORMULA( cPVS3_FORMU )
		VS3->VS3_FORMUL := cPVS3_FORMU
		VS3->VS3_VALTOT := VS3->VS3_VALPEC * VS3->VS3_QTDITE
		VS3->VS3_TRSFER := '1'
		VS3->VS3_CENCUS := SB1->B1_CC

		//
		// RESERVA
		//
		VS3->VS3_QTDRES := VS3->VS3_QTDINI
		VS3->VS3_RESERV := '1'
		VS3->VS3_DOCSDB := oEst:TransfereLote(SB1->B1_COD, oItem:GetValue('LOCAL'), GetMv("MV_RESITE"), VS3->VS3_QTDITE, oItem:GetValue('LOTE'), oItem:GetValue('SUBLOTE'))
		if Empty(VS3->VS3_DOCSDB) .or. VS3->VS3_DOCSDB == "ERRO"
			conout("### "+STR0010)//Erro na reserva detectado.
			return .F.
		endif
		//
		// Campos customizáveis entram aqui
		//
		aCust := IIF(ExistBlock('VCLSAT2'), ExecBlock("VCLSAT2",.f.,.f.),  {})
		for nIdxC := 1 to LEN(aCust)
			If aCust[nIdxC][1] == "VS3_FORMUL"
				VS3->VS3_VALPEC := FG_FORMULA( aCust[nIdxC][2] )
				VS3->VS3_VALTOT := VS3->VS3_VALPEC * VS3->VS3_QTDITE
			EndIf
			
			VS3->&(aCust[nIdxC][1]) := aCust[nIdxC][2]
		next
		VS3->(msUnlock())

		OX001VE6(cNumOrc, .t.)
	Next

	if ! lAny
		oLogger:LogToTable({;
			{'VQL_AGROUP', 'DPMXFER'},;
			{'VQL_TIPO'  , 'ERROR'  },;
			{'VQL_DADOS' , STR0001 /* 'Nenhum item do DPMXFER com saldo para transferência'*/ } ;
		})
		return .T. // não pode retornar erro, pois não ter itens não significa erro, somente falta de estoque
	Endif

	reclock("VS1", .T.)
	VS1->VS1_FILIAL := xFilial('VS1')
	VS1->VS1_TIPORC := "3" // transferencia
	VS1->VS1_STATUS := "0" // digitado
	VS1->VS1_NUMORC := cNumOrc
	VS1->VS1_DATORC := dDatabase
	VS1->VS1_CLIFAT := SA1->A1_COD
	VS1->VS1_LOJA   := SA1->A1_LOJA
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_FILDES := self:cDestino
	VS1->VS1_ARMDES := self:cArmDes
	VS1->VS1_RESERV := '1'
	VS1->VS1_STARES := '1'
	If VS1->(FieldPos("VS1_TRFRES")) > 0
		VS1->VS1_TRFRES := "1" // 0=Nao / 1=Sim - Reserva a Transferencia automaticamente
	EndIf
	//
	// Campos customizáveis entram aqui
	//
	aCust := IIF(ExistBlock('VCLSAT1'), ExecBlock("VCLSAT1",.f.,.f.),  {})
	for nIdxC := 1 to LEN(aCust)
		VS1->&(aCust[nIdxC][1]) := aCust[nIdxC][2]
	next
	//
	oLogger:LogToTable({;
		{'VQL_AGROUP', "DPMXFER"       },;
		{'VQL_TIPO'  , "ORC"           },;
		{'VQL_DADOS' , cNumOrc         } ;
	})
	confirmsx8()
	VS1->(msUnlock())

	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0014 ) // Grava Data/Hora na Mudança de Status do Orçamento / Transferêcia de Peças
	EndIf

	//
	// Erros falta de estoque quando utiliza lote
	//
	for nIdx := 1 to LEN(self:aErros)
		AADD(aDetEmail, self:aErros[nIdx])
	next
	//
	// Envia e-mail 
	//
	If ExistBlock("PECLSAT1") // Temporario PECLSAT1
		aParam := {VS1->VS1_NUMORC}
		ExecBlock("PECLSAT1",.f.,.f., aParam)
	EndIf

	cTitulo := "[JDPRISM TRANSFER]" + STR0003 /*" Filial: "*/ + VS1->VS1_FILIAL + STR0007 /*" Destino: "*/ + self:cDestino +" "+ STR0004 /*' Num. Orc: '*/ + VS1->VS1_NUMORC
	AADD(aDetEmail, {"Nome arquivo", cFileName})
	oEmail:SendTemplate({;
		{'template'          , "jd_order"                      },;
		{'assunto'           , cTitulo                         },;
		{':titulo'           , cTitulo                         },;
		{':cabecalho1'       , STR0005/*'Dados:'*/             },;
		{':dados_cabecalho1' , aDadEmail                       },;
		{':cabecalho2'       , STR0006/*"Detalhes:"*/          },;
		{':dados_cabecalho2' , aDetEmail                       },;
		{'origem'            , GetNewPar("MV_MIL0088", "")     },;
		{'destino'           , GetNewPar("MV_MIL0089", "") + ";" + cEmDest } ;
	})

	

	for nIdx := 1 to LEN(self:aItens)
		self:aItens[nIdx]:SetValue("NUMERO_ORCAMENTO", VS1->VS1_NUMORC)
	next

	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} Prepare
	Essa função foi criada para calcular lote e endereçamento

	@type method
	@author Vinicius Gati
	@since 18/10/2016
	@version 1.0
/*/
Method Prepare() Class DMS_Transferencia
	Local nIdx    := 1
	Local nIdx2   := 1
	Local oPeca   := DMS_Peca():New()
	Local cFilBck := cFilAnt
	Local oItem   := nil
	cFilAnt := self:cOrigem
	//
	For nIdx := 1 To Len(self:aItens)
		oItem := self:aItens[nIdx]
		//
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial('SB1') + oItem:GetValue('B1_COD') ))
		//
		SB5->(dbSetOrder(1))
		SB5->(dbSeek( xFilial('SB5') + oItem:GetValue('B1_COD') ))
		//
		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek( xFilial('SBZ') + oItem:GetValue('B1_COD') ))
		//
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
		//
		If Rastro(SB1->B1_COD)
			//
			oPeca := DMS_Peca():New(SB1->B1_GRUPO, SB1->B1_COD)
			//
			// SaldoLoteMov retorna essa estrutura de dados:
			// [01] Lote de Controle
			// [02] Sub-Lote
			// [03] Localizacao
			// [04] Numero de Serie
			// [05] Quantidade
			// [06] Quantidade 2aUM
			// [07] Data de Validade
			// [08] Registro do SB2
			// [09] Registro do SBF
			// [10] Array com Registros do SB8 e qtd
			// [11] Local
			// [12] Potencia
			// [13] Prioridade do endereco (BF_PRIOR)
			//
			nQtdFalta := VAL(oItem:GetValue('QUANTIDADE'))
			aLotes := oPeca:SaldoLoteMovimentacao(SB2->B2_LOCAL, nQtdFalta, '', '', {})
			aSort(aLotes,,,{|x,y| x[13] < y[13] })// usando prioridade de lote
			//
			for nIdx2 := 1 to Len(aLotes)
				aLote    := aLotes[nIdx2]
				//
				oTrf := DMS_DataContainer():New({;
					{"B1_COD"     , SB1->B1_COD    },;
					{"LOTE"       , aLote[01]      },;
					{"SUBLOTE"    , aLote[02]      },;
					{"QUANTIDADE" , STR(aLote[05]) },; // estou convertendo pra string para manter o padrao do que vem do arquivo da JD e funcao que usa os dados converte para numerico.
					{"VALIDADE"   , aLote[07]      },;
					{"LOCAL"      , aLote[11]      } ;
				})
				//
				AADD(self:aTransfsLote, oTrf)
				nQtdFalta := nQtdFalta - aLote[05]
			next 
			//
			if nQtdFalta > 0
				AADD(self:aErros, {SB1->B1_COD, STR(nQtdFalta) + STR0012}) //" faltante(s) em estoque."
			EndIf
		Else
			oTrf := DMS_DataContainer():New({;
				{"B1_COD"    , SB1->B1_COD                              },;
				{"LOTE"      , ""                                       },;
				{"SUBLOTE"   , ""                                       },;
				{"QUANTIDADE", oItem:GetValue('QUANTIDADE')             },; 
				{"LOCAL"     , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") } ;
			})
			AADD(self:aTransfsLote, oTrf)
		EndIf
		
	Next
	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} AjustaRes
	Ajusta reserva de uma transferencia que foi alterada para evitar problemas de estoque
	Ela transfere do armazem de reserva para o armazem de uso e em seguida reserva a nova quantidade ajustada

	@type method
	@author Vinicius Gati
	@since 18/11/2016
	@version 1.0
/*/
Method AjustaRes(recno_vs3) Class DMS_Transferencia
	Local oEst    := DMS_Estoque():New()
	Local cDocSDB := ""

	dbSelectArea('VS3')
	VS3->(dbSetOrder(1))
	VS3->(DbGoTo(recno_vs3))

	SB1->(dbSetOrder(7)) //B1_FILIAL+B1_GRUPO+B1_CODITE
	SB1->(dbSeek( xFilial('SB1') + VS3->VS3_GRUITE + VS3->VS3_CODITE ))

	SB5->(dbSetOrder(1))
	SB5->(dbSeek( xFilial('SB5') + SB1->B1_COD ))

	SBZ->(dbSetOrder(1))
	SBZ->(dbSeek( xFilial('SBZ') + SB1->B1_COD ))

	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
	//
	// desreservar
	//
	If VS3->VS3_QTDRES > 0 
		cDocSDB := oEst:TransfereLote(SB1->B1_COD, ;
			GetMv("MV_RESITE"),; 
			SB2->B2_LOCAL     ,;
			VS3->VS3_QTDRES   ,;
			VS3->VS3_NUMLOT   ,; 
			VS3->VS3_LOTECT)
			if Empty(cDocSDB) .or. cDocSDB == "ERRO"
				conout("### "+STR0010)//Erro na reserva detectado.
				return .F.
			endif
	Endif
	//
	// reservar
	//
	cDocSDB := oEst:TransfereLote(SB1->B1_COD, ;
		SB2->B2_LOCAL     ,; 
		GetMv("MV_RESITE"),;
		VS3->VS3_QTDITE   ,;
		VS3->VS3_NUMLOT   ,; 
		VS3->VS3_LOTECT)

	if Empty(cDocSDB) .or. cDocSDB == "ERRO"
		conout("### "+STR0010)//Erro na reserva detectado.
		return .F.
	endif

	reclock('VS3', .F.)
	VS3->VS3_QTDRES := VS3->VS3_QTDITE
	VS3->VS3_RESERV := '1'
	VS3->VS3_DOCSDB := cDocSDB
	VS3->(msUnlock())
Return .T.


/*/{Protheus.doc} Desreserva
	Desreserva toda ou a quantidade que esta de fato reservada do VS3

	@type method
	@author Vinicius Gati
	@since 18/11/2016
	@version 1.0
/*/
Method Desreserva(recno_vs3,nQtdDes) Class DMS_Transferencia
	Local oEst    := DMS_Estoque():New()
	Local cDocSDB := ""
	Default nQtdDes := 0

	dbSelectArea('VS3')
	VS3->(dbSetOrder(1))
	VS3->(DbGoTo(recno_vs3))
	
	If nQtdDes == 0
		nQtdDes := VS3->VS3_QTDRES
	EndIf

	SB1->(dbSetOrder(7)) //B1_FILIAL+B1_GRUPO+B1_CODITE
	SB1->(dbSeek( xFilial('SB1') + VS3->VS3_GRUITE + VS3->VS3_CODITE ))

	SB5->(dbSetOrder(1))
	SB5->(dbSeek( xFilial('SB5') + SB1->B1_COD ))

	SBZ->(dbSetOrder(1))
	SBZ->(dbSeek( xFilial('SBZ') + SB1->B1_COD ))

	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
	// desreservar
	//
	cDocSDB := oEst:TransfereLote(SB1->B1_COD, ;
		GetMv("MV_RESITE"),; 
		SB2->B2_LOCAL     ,;
		nQtdDes           ,;
		VS3->VS3_NUMLOT   ,; 
		VS3->VS3_LOTECT)

	if Empty(cDocSDB) .or. cDocSDB == "ERRO"
		conout("### "+STR0010)//Erro na reserva detectado.
		return .F.
	endif

	reclock('VS3', .F.)
	VS3->VS3_QTDRES := 0
	VS3->VS3_RESERV := '0'

	VS3->(msUnlock())
Return .T.

/*/{Protheus.doc} CalcPeso
	Calcula o peso bruto e liquido de uma transferencia
	utilizando as peças da mesma

	@type function
	@author Vinicius Gati
	@since 14/08/2019
	@returns object with net and gross weight as liquido e bruto attributes for pt-BR
/*/
Method CalcPeso(cNumTrf) class DMS_Transferencia
	local aRegs  := {}
	local cQuery := ""
	local oSql   := DMS_SqlHelper():New()

	cQuery := " SELECT sum(B1_PESBRU * VS3_QTDITE) as bruto, sum(B1_PESO * VS3_QTDITE) as liquido   "
	cQuery += "   FROM " + retsqlname('VS3') + " VS3 "
	cQuery += "   JOIN " + retsqlname('VS1') + " VS1 ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VS3_NUMORC AND VS1_TIPORC = '3'        AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + retsqlname('SB1') + " SB1 ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO   = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE VS3_FILIAL = '"+xFilial('VS3')+"' "
	cQuery += "    AND VS3_NUMORC = '"+cNumTrf+"' "
	cQuery += "    AND VS3.D_E_L_E_T_ = ' ' "

	aRegs := oSql:GetSelect({;
		{'campos', {'bruto', 'liquido'}},;
		{'query' , cQuery};
	})
	oPeso := aRegs[1]
return oPeso

/*/{Protheus.doc} CalcPesos
	Calcula o peso de N orcamentos

	@type function
	@author Vinicius Gati
	@since 28/08/2019
/*/
Method CalcPesos(aNumOrcs) Class DMS_Transferencia
	local nX := 1
	local nSumBruto := 0.0
	local nSumLiq := 0.0
	local oPeso := nil
	for nX := 1 to len(aNumOrcs)
		oPeso := self:CalcPeso(aNumOrcs[nX])
		nSumBruto += oPeso:GetValue('bruto')
		nSumLiq += oPeso:GetValue('liquido')
	next
	oPeso:setValue('bruto', nSumBruto)
	oPeso:setValue('liquido', nSumLiq)
Return oPeso
