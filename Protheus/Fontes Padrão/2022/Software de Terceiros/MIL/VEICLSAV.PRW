////////////////
// Versao 001 //
////////////////

#include "protheus.ch"
//#include "VEICLSAV.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  10/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007279_1"


Function VEICLSAV()
Return

/*/{Protheus.doc} DMS_Veiculo
	@author       Andre Luis Almeida
	@since        19/06/2017
	@description  Acessa o banco para processar veiculos(VV1)
/*/
Class DMS_Veiculo

	Data cBloqStat
	Data lSelVeiUti
	Data cFilStatEmAtendimento

	Method New() CONSTRUCTOR
	Method GetB1_COD()
	Method CriaVeiculo()
	Method CriaPeca()
	Method Bloqueado()
	Method DtUltimaMovimentacao()

	Method emAtendimento()
	Method emPedidoDeVenda()

	Method _loadParams()
EndClass


/*/{Protheus.doc} New
	Construtor simples DMS_Veiculo

	@author Andre Luis Almeida
	@since 19/06/2017
/*/
Method New() Class DMS_Veiculo
	self:cBloqStat := ""
	self:lSelVeiUti := ""
	self:cFilStatEmAtendimento := ""
Return SELF

/*/{Protheus.doc} GetB1_COD
	Retorna o B1_COD do Veiculo

	@author Andre Luis Almeida
	@since 19/06/2017
/*/
Method GetB1_COD(cChaInt) Class DMS_Veiculo
Return Left(GetMv("MV_GRUVEI")+Space(10),TamSX3("B1_GRUPO")[1])+"_"+cChaInt

/*/{Protheus.doc} CriaVeiculo
	Cria o Veiculo VV1

	@author Andre Luis Almeida
	@since 19/06/2017
/*/
Method CriaVeiculo(cCodVV1,nOpcVV1,aData,cPE) Class DMS_Veiculo
	Local ni        := 0
	Private aIncVV1 := {}
	Default cCodVV1 := ""
	Default nOpcVV1 := 3
	Default aData   := {}
	Default cPE     := ""
	If nOpcVV1 == 3 // Incluir
		If Empty(cCodVV1)
			AADD(aIncVV1, { "VV1_FILIAL" , xFilial("VV1")                , Nil })
			AADD(aIncVV1, { "VV1_CHAINT" , GetSXENum("VV1","VV1_CHAINT") , Nil })
			ConfirmSX8()
		EndIf
	Else // nOpcVV1 <> 3 // Alterar
		If Empty(cCodVV1)
			Return .f.
		EndIf
		DbSelectArea("VV1")
		DbSetOrder(1)
		If !DbSeek(xFilial("VV1")+cCodVV1)
			Return .f.
		EndIf
	EndIf
	aEVAL(aData, { |x| AADD(aIncVV1, { x[1] , x[2] , Nil }) }) // Adicionar CAMPOS/CONTEUDOS no Vetor de Integracao
	If !Empty(cPE)
		If ExistBlock(cPE)
			aIncVV1 := ExecBlock(cPE,.f.,.f.,{aIncVV1}) // Executa PE para manipular o Vetor de Integracao
		EndIf
	EndIf
	DbSelectArea("VV1")
	RecLock("VV1",(nOpcVV1==3)) // .t. (Incluir) ou .f. (Alterar)
	For ni := 1 to len(aIncVV1)
		If VV1->(FieldPos(aIncVV1[ni,1])) > 0 // Existe o campo
			&("VV1->"+aIncVV1[ni,1]) := aIncVV1[ni,2] // Atribui valor para o campo
		EndIf
	Next
	MsUnLock()
Return .t.

	
Return lRet

/*/{Protheus.doc} CriaPeca
	Cria Peca (SB1) com o Veiculo

	@author Andre Luis Almeida
	@since 19/06/2017
/*/
Method CriaPeca(cCodVV1,nOpcSB1,aData,cPE, cCodSB1) Class DMS_Veiculo
	Local oParams
	Local oPeca     := DMS_Peca():New()
	Private aIncSB1 := {}
	Default cCodVV1 := ""
	Default nOpcSB1 := 3
	Default aData   := {}
	Default cPE     := ""
	Default cCodSB1   := ""

	// Apos implementacao do cadatro de veiculo em MVC a utilizacao deste método deve ser 
	// descontinuada e utilizada o cadastro em MVC
	// quando necessário "ExecAuto", utilizar a integração através da MODEL VEIA070
	//
	If Empty(cCodVV1)
		Return .f.
	EndIf
	//
	VV1->(DbSetOrder(1))
	If !VV1->(DbSeek(xFilial("VV1")+cCodVV1)) // VV1->VV1_CHAINT
		Return .f.
	EndIf
	//
	DbSelectArea("VV1")
	RegToMemory("VV1",.f.) // Cria variaveis de Memoria que podem ser utilizadas nos PEs de criacao do SB1
	//
	If Empty(cCodSB1) .OR. nOpcSB1 == 3
		cCodSB1 := Self:GetB1_COD(cCodVV1) // Retorna B1_COD do Veiculo
	EndIf
	//
	If nOpcSB1 == 3 // Inclusao
		//
		oParams := DMS_DataContainer():New(aData)
		//
		aAdd(aIncSB1,{"B1_FILIAL"  , oParams:GetValue("B1_FILIAL" ,xFilial("SB1"))})
		aAdd(aIncSB1,{"B1_COD"     , oParams:GetValue("B1_COD"    ,cCodSB1)})
		aAdd(aIncSB1,{"B1_CODITE"  , oParams:GetValue("B1_CODITE" ,VV1->VV1_CHAINT)})
		aAdd(aIncSB1,{"B1_DESC"    , oParams:GetValue("B1_DESC"   ,VV1->VV1_CHASSI)})
		aAdd(aIncSB1,{"B1_LOCPAD"  , oParams:GetValue("B1_LOCPAD" ,VV1->VV1_LOCPAD)})
		aAdd(aIncSB1,{"B1_PRV1"    , oParams:GetValue("B1_PRV1"   ,VV1->VV1_SUGVDA)})
		aAdd(aIncSB1,{"B1_PESO"    , oParams:GetValue("B1_PESO"   ,VV1->VV1_PESLIQ)})
		aAdd(aIncSB1,{"B1_PESBRU"  , oParams:GetValue("B1_PESBRU" ,VV1->VV1_PESBRU)})
		If X3Obrigat("B1_CODBAR") // Veiculos - somente passa o B1_CODBAR se o campo for obrigatorio
			aAdd(aIncSB1,{"B1_CODBAR"  , oParams:GetValue("B1_CODBAR" ,VV1->VV1_CHAINT)})
		EndIf
		aAdd(aIncSB1,{"B1_ORIGEM"  , oParams:GetValue("B1_ORIGEM" ,VV1->VV1_PROVEI)})
		aAdd(aIncSB1,{"B1_POSIPI"  , oParams:GetValue("B1_POSIPI" ,VV1->VV1_POSIPI)})
		aAdd(aIncSB1,{"B1_GRTRIB"  , oParams:GetValue("B1_GRTRIB" ,VV1->VV1_GRTRIB)})
		aAdd(aIncSB1,{"B1_TIPO"    , oParams:GetValue("B1_TIPO"   ,GetMv("MV_TIPVEI"))})
		aAdd(aIncSB1,{"B1_GRUPO"   , oParams:GetValue("B1_GRUPO"  ,GetMv("MV_GRUVEI"))})
		aAdd(aIncSB1,{"B1_UM"      , oParams:GetValue("B1_UM"     ,"UN")})
		aAdd(aIncSB1,{"B1_PICM"    , oParams:GetValue("B1_PICM"   ,0)})
		aAdd(aIncSB1,{"B1_IPI"     , oParams:GetValue("B1_IPI"    ,0)})
		aAdd(aIncSB1,{"B1_TE"      , oParams:GetValue("B1_TE"     ,"")})
		aAdd(aIncSB1,{"B1_CONTA"   , oParams:GetValue("B1_CONTA"  ,"")})
		aAdd(aIncSB1,{"B1_CC"      , oParams:GetValue("B1_CC"     ,"")})
		aAdd(aIncSB1,{"B1_FABRIC"  , oParams:GetValue("B1_FABRIC" ,"")})
		aAdd(aIncSB1,{"B1_TIPOCQ"  , oParams:GetValue("B1_TIPOCQ" ,"M")})
		aAdd(aIncSB1,{"B1_CONTRAT" , oParams:GetValue("B1_CONTRAT","N")})
		aAdd(aIncSB1,{"B1_LOCALIZ" , oParams:GetValue("B1_LOCALIZ","N")})
		aAdd(aIncSB1,{"B1_IRRF"    , oParams:GetValue("B1_IRRF"   ,"N")})
		aAdd(aIncSB1,{"B1_CONTSOC" , oParams:GetValue("B1_CONTSOC","N")})
		aAdd(aIncSB1,{"B1_MRP"     , oParams:GetValue("B1_MRP"    ,"N")})
		If GetNewPar("MV_MARGSOL",0) > 0
			aAdd(aIncSB1,{"B1_PICMENT" , oParams:GetValue("B1_PICMENT",GetNewPar("MV_MARGSOL",0))})
		EndIf
		If SB1->(FieldPos("B1_CHASSI")) > 0
			aAdd(aIncSB1,{"B1_CHASSI"  , oParams:GetValue("B1_CHASSI" ,Left(VV1->VV1_CHASSI,TamSX3("B1_CHASSI")[1]))})
		EndIf
		If SB1->(FieldPos("B1_CEST")) > 0 .and. VV1->(FieldPos("VV1_CEST")) > 0
			aAdd(aIncSB1,{"B1_CEST"    , oParams:GetValue("B1_CEST"   ,VV1->VV1_CEST)})
		EndIf
		aAdd(aIncSB1,{"B1_CONTA"   , oParams:GetValue("B1_CONTA"  ,VV1->VV1_CONTA)})
		aAdd(aIncSB1,{"B1_CC"      , oParams:GetValue("B1_CC"     ,VV1->VV1_CC)})
		aAdd(aIncSB1,{"B1_ITEMCC"  , oParams:GetValue("B1_ITEMCC" ,VV1->VV1_ITEMCC)})
		aAdd(aIncSB1,{"B1_CLVL"    , oParams:GetValue("B1_CLVL"   ,VV1->VV1_CLVL)})

		// Bloqueio/Desbloqueio de Chassi
		If SB1->(FieldPos("B1_MSBLQL")) > 0 .and. VV1->(FieldPos("VV1_MSBLQL")) > 0
			aAdd(aIncSB1,{"B1_MSBLQL"  , oParams:GetValue("B1_MSBLQL" ,VV1->VV1_MSBLQL)})
		EndIf

		// Grupo TI
		If SB1->(FieldPos("B1_GRPTI")) > 0 .and. VV1->(FieldPos("VV1_GRPTI")) > 0
			aAdd(aIncSB1,{"B1_GRPTI"   , oParams:GetValue("B1_GRPTI"  ,VV1->VV1_GRPTI)})
		EndIf
	Else // Alteracao
		//
		aIncSB1 := aClone(aData) // Adicionar CAMPOS/CONTEUDOS no Vetor de Integracao
		//
	EndIf
Return oPeca:CriaPeca(cCodSB1,nOpcSB1,aIncSB1,cPE)

/*/{Protheus.doc} Bloqueado
	Verifica se o veículo está bloqueado através do campo VV1_MSBLQL
	e se parametrizado mostrará o help

	@return boolean, .t.|.f. se bloqueado ou não
	@author Fernando Vitor Cavani
	@since 07/06/2018
	@version 1.0
	@param cChassi, characters, descricao
	@param lShowHlp, logical, descricao
	@type function
/*/
Method Bloqueado(cChaInt, cChassi, lShowHlp) Class DMS_Veiculo
	Local cMsg       := ""
	Local lBloq      := .F.
	Local aArea
	Local aAreaA1

	Default cChaInt  := ""
	Default cChassi  := ""
	Default lShowHlp := .T.

	If VV1->(FieldPos("VV1_MSBLQL")) > 0
		aArea      := GetArea()
		aAreaA1    := VV1->(GetArea())

		dbSelectarea('VV1')
		If !Empty(cChaInt)
			dbSetOrder(1)
			msSeek(xFilial('VV1') + cChaInt)
		Else
			dbSetOrder(2)
			msSeek(xFilial('VV1') + cChassi)
		EndIf

		If VV1->(Found()) .And. VV1->VV1_MSBLQL == '1'
			lBloq := .T.
		EndIf

		If lBloq .And. lShowHlp
			cMsg := chr(13) + chr(10) + "VV1" + chr(13) + chr(10)
			cMsg += RetTitle("VV1_CHAINT") + ":" + VV1->VV1_CHAINT + chr(13) + chr(10)
			cMsg += RetTitle("VV1_CHASSI") + ":" + VV1->VV1_CHASSI + chr(13) + chr(10)
			cMsg += RetTitle("VV1_CODMAR") + ":" + VV1->VV1_CODMAR + " - "
			cMsg += RetTitle("VV1_MODVEI") + ":" + VV1->VV1_MODVEI + chr(13) + chr(10)
			cMsg += RetTitle("VV1_PLAVEI") + ":" + VV1->VV1_PLAVEI + chr(13) + chr(10)

			HELP(" ", 1, "REGBLOQ",, cMsg, 3, 1)
		EndIf

		RestArea(aAreaA1)
		RestArea(aArea)
	EndIf
Return lBloq

/*/{Protheus.doc} emAtendimento
	Verifica se o veiculo foi selecionado em um pedido de venda (Montadora)

	@return boolean, .t.|.f. se foi selecionado ou não
	@author Rubens Takahashi
	@since 21/10/2019
	@version 1.0
	@param cCpoPesq, characters, CHASSI ou CHAINT
	@param cChavPesq, characters, Chave de pesquisa
	@type function
/*/
Method emAtendimento(cCpoPesq, cChavPesq, cNumTraDescons, cItemNumTraDescons , lPesqPedVen) Class DMS_Veiculo

	Local cQuery 
	Local lSelec

	Default cNumTraDescons := ""
	Default cItemNumTraDescons := ""
	Default lPesqPedVen := .f.

	If Empty( self:lSelVeiUti )
		self:_loadParams()
	EndIF

	If ! self:lSelVeiUti .or. ! Empty(self:cFilStatEmAtendimento) // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro

		cQuery := ;
			"SELECT COUNT(*)" +;
			 " FROM " + RetSQLName("VVA") + " VVA " +;
				" JOIN " + RetSQLName("VV0") + " VV0 " +;
					" ON VV0.VV0_FILIAL = VVA.VVA_FILIAL AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' ' " +;
				" JOIN " + RetSQLName("VV9") + " VV9 " +;
					" ON VV9.VV9_FILIAL = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_ = ' ' " +;
					" AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D')" +;
					IIf( ! Empty( self:cFilStatEmAtendimento ), " AND VV9.VV9_STATUS NOT IN (" + self:cFilStatEmAtendimento + ")" , "" ) +;
			" WHERE "

		If cCpoPesq == "CHASSI"
			cQuery += " VVA.VVA_CHASSI='" + cCpoPesq + "'" // Necessario devido a validação nas demais Filiais
		Else
			cQuery += " VVA.VVA_CHAINT='" + cCpoPesq + "'"
			cQuery += " AND VVA.VVA_CHASSI=' '" // Necessario devido a validação nas demais Filiais
		EndIf
		cQuery += "  AND VVA.D_E_L_E_T_=' '"

		If ! Empty(cNumTraDescons)
			cQuery += ;
				" ( " +;
					"( VVA.VVA_FILIAL = '" + xFilial("VVA") + "'" +;
						" AND VVA.VVA_NUMTRA <> '" + cNumTraDescons + "'" +;
						IIF( ! Empty( cItemNumTraDescons ) , " AND VVA.VVA_ITETRA <> '" + cItemNumTraDescons + "'" , "" ) +;
					" ) " +;
					" OR " +;
					"( VVA.VVA_FILIAL <> '" + xFilial("VVA") + "' ) " +;
				" ) "
		EndIf

		lSelec := FM_SQL(cQuery)

		If lSelec .and. lPesqPedVen
			lSelec := self:emPedidoDeVenda(cCpoPesq, cChavPesq)
		EndIf
	
	EndIf

Return lSelec

/*/{Protheus.doc} emPedidoDeVenda
	Verifica se o veiculo foi selecionado em um pedido de venda (Montadora)

	@return boolean, .t.|.f. se foi selecionado ou não
	@author Rubens Takahashi
	@since 21/10/2019
	@version 1.0
	@param cCpoPesq, characters, CHASSI ou CHAINT
	@param cChavPesq, characters, Chave de pesquisa
	@type function
/*/
Method emPedidoDeVenda(cCpoPesq, cChavPesq, cPedVenDescons, cItemPedVenDescons, cNumTraDescons, cItemNumTraDescons ) Class DMS_Veiculo

	Local cQuery 
	Local cChassi
	Local lSelec

	Default cPedVenDescons := ""
	Default cItemPedVenDescons := ""
	Default cNumTraDescons := ""
	Default cItemNumTraDescons := ""

	If ! FWAliasInDic("VRJ")
		Return .f.
	EndIf

	If cCpoPesq == "CHAINT"
		cChassi := FM_SQL(;
			"SELECT VV1_CHASSI " +;
			 " FROM " + RetSQLName("VV1") + " VV1 " +;
			" WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'" +;
			  " AND VV1.VV1_CHAINT = '" + cChavPesq + "'" +;
			  " AND VV1.D_E_L_E_T_ = ' '")
	Else
		cChassi := cChavPesq
	EndIf

	// VRKCONS.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
	// " AND

	cQuery := ;
		" SELECT COUNT(VRKCONS.VRK_PEDIDO) " +;
			" FROM " + RetSqlName("VRK") + " VRKCONS " +;
				" JOIN " + RetSqlName("VRJ") + " VRJCONS " +;
					"  ON VRJCONS.VRJ_FILIAL = VRKCONS.VRK_FILIAL " +;
					" AND VRJCONS.VRJ_PEDIDO = VRKCONS.VRK_PEDIDO " +;
					" AND VRJCONS.D_E_L_E_T_ = ' ' " +;
		" WHERE  VRKCONS.VRK_CHASSI = '" + cChassi + "' " +;
			" AND VRKCONS.VRK_CANCEL IN ('0',' ') " +;
			" AND ( VRJCONS.VRJ_STATUS NOT IN ('C','R','F') OR (VRJCONS.VRJ_STATUS = 'F' AND VRKCONS.VRK_NUMTRA = ' ' ) )" +;
			" AND VRKCONS.D_E_L_E_T_ = ' '"

	// Desconsiderar pedido de venda informado no parametro do metodo
	If ! Empty(cPedVenDescons)
		cQuery += ;
			" AND ( " +;
				" (  VRKCONS.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
					" AND ( VRKCONS.VRK_PEDIDO <> '" + cPedVenDescons + "'" +;
					IIF( ! Empty( cItemPedVenDescons ) , " OR ( VRKCONS.VRK_PEDIDO = '" + cPedVenDescons + "' AND VRKCONS.VRK_ITEPED <> '" + cItemPedVenDescons + "' )" , "" ) +;
				" ) ) " +;
				" OR " +;
				" ( VRKCONS.VRK_FILIAL <> '" + FWxFilial("VRK") + "' ) " +;
			" ) "
	EndIf
	// Desconsiderar atendimento informado no parametro do metodo
	If ! Empty(cNumTraDescons)
		cQuery += ;
			" AND ( " +;
				" ( VRKCONS.VRK_FILTRA = '" + FWxFilial("VV9") + "'" +;
					" AND ( VRKCONS.VRK_NUMTRA <> '" + cNumTraDescons + "'" +;
					IIF( ! Empty( cItemNumTraDescons ) , " OR ( VRKCONS.VRK_NUMTRA <> '" + cNumTraDescons + "' AND VRKCONS.VRK_ITETRA <> '" + cItemNumTraDescons + "' )" , "" ) +;
				" ) ) " +;
				" OR " +;
				" ( VRKCONS.VRK_FILTRA <> '" + FWxFilial("VV9") + "' ) " +;
			" ) "
	EndIf

	lSelec := FM_SQL(cQuery)

Return lSelec


Method _loadParams() Class DMS_Veiculo

	Local nAuxPos

	self:cBloqStat  := AllTrim(GetNewPar("MV_BLQSTAV","LO")) // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
	self:lSelVeiUti := ( GetNewPar("MV_MIL0018","1") == "1" ) // Seleciona o veiculo quando o mesmo ja esta relacionado em outro atendimento? (0=Nao/1=Sim)

	If ! self:lSelVeiUti // Bloqueia selecao de veiculos informados em outro atendimento
		self:cFilStatEmAtendimento := "'A','P','O','L',"
	EndIf

	If ! Empty(self:cBloqStat)
		For nAuxPos := 1 to Len(self:cBloqStat)
			self:cFilStatEmAtendimento += "'" + SubStr(self:cBloqStat,nAuxPos,1) + "',"
		Next nAuxPos
	EndIf

	If ! Empty(self:cFilStatEmAtendimento)
		self:cFilStatEmAtendimento := Left(self:cFilStatEmAtendimento,Len(self:cFilStatEmAtendimento) - 1)
	EndIf

Return

/*/{Protheus.doc} DtUltimaMovimentacao
	Retorna a Data da Ultima Movimentacao do Veiculo

	@return data , Data da ultima movimentacao
	@author Andre Luis Almeida
	@since 30/06/2020
	@version 1.0
	@param cChassi, caracter
	@type function
/*/
Method DtUltimaMovimentacao(cChassi) Class DMS_Veiculo
	Local dDatRet   := ctod("")
	Local aMovVei   := {}
	Default cChassi := ""
	If !Empty(cChassi)
		aMovVei := FGX_VEIMOVS( cChassi , , )
		If len(aMovVei) > 0
			dDatRet := aMovVei[1,6] // Data do Movimento
		EndIf
	EndIf
Return dDatRet