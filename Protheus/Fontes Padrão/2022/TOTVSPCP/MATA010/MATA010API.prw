#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA010API.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A010APICnt para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A010APICnt
//Campos do Grupo (cabeçalho)
#DEFINE ARRAY_PROD_POS_FILIAL    1
#DEFINE ARRAY_PROD_POS_PROD      2
#DEFINE ARRAY_PROD_POS_LOCPAD    3
#DEFINE ARRAY_PROD_POS_TIPO      4
#DEFINE ARRAY_PROD_POS_GRUPO     5
#DEFINE ARRAY_PROD_POS_QE        6
#DEFINE ARRAY_PROD_POS_EMIN      7
#DEFINE ARRAY_PROD_POS_ESTSEG    8
#DEFINE ARRAY_PROD_POS_PE        9
#DEFINE ARRAY_PROD_POS_TIPE      10
#DEFINE ARRAY_PROD_POS_LE        11
#DEFINE ARRAY_PROD_POS_LM        12
#DEFINE ARRAY_PROD_POS_TOLER     13
#DEFINE ARRAY_PROD_POS_NUMDEC    14
#DEFINE ARRAY_PROD_POS_TIPDEC    15
#DEFINE ARRAY_PROD_POS_RASTRO    16
#DEFINE ARRAY_PROD_POS_MRP       17
#DEFINE ARRAY_PROD_POS_REVATU    18
#DEFINE ARRAY_PROD_POS_EMAX      19
#DEFINE ARRAY_PROD_POS_PROSBP    20
#DEFINE ARRAY_PROD_POS_LOTSBP    21
#DEFINE ARRAY_PROD_POS_ESTORI    22
#DEFINE ARRAY_PROD_POS_APROPR    23
#DEFINE ARRAY_PROD_POS_HORFIX    24
#DEFINE ARRAY_PROD_POS_TPHFIX    25
#DEFINE ARRAY_PROD_POS_CPOTEN    26
#DEFINE ARRAY_PROD_POS_IDREG     27
#DEFINE ARRAY_PROD_POS_BLOQUEADO 28
#DEFINE ARRAY_PROD_POS_CONTRATO  29
#DEFINE ARRAY_PROD_POS_ROTEIRO   30
#DEFINE ARRAY_PROD_POS_CCUSTO    31
#DEFINE ARRAY_PROD_POS_LDTRANSF  32
#DEFINE ARRAY_PROD_POS_DESC      33
#DEFINE ARRAY_PROD_POS_DESCTP    34
#DEFINE ARRAY_PROD_POS_GRPCOM    35
#DEFINE ARRAY_PROD_POS_GCDESC    36
#DEFINE ARRAY_PROD_POS_UM        37
#DEFINE ARRAY_PROD_POS_OPC       38
#DEFINE ARRAY_PROD_POS_STR_OPC   39
#DEFINE ARRAY_PROD_POS_SIZE      39

#DEFINE ARRAY_TRANSF_POS_FILIAL   1
#DEFINE ARRAY_TRANSF_POS_LEADTIME 2
#DEFINE ARRAY_TRANSF_POS_AGLUTMRP 3
#DEFINE ARRAY_TRANSF_POS_SIZE     3

Static _lPCPREVAT := FindFunction('PCPREVATU') .AND. SuperGetMv("MV_REVFIL",.F.,.F.)
Static _lIntEstPA := FindFunction('MTA010G1PA')

/*/{Protheus.doc} A010APICnt
Recupera o valor das constantes utilizadas para auxiliar na montagem do array para integração

@type  Function
@author douglas.heydt
@since 03/10/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A010APICnt(cInfo)
	Local nValue := ARRAY_PROD_POS_SIZE
	Do Case
		Case cInfo == "ARRAY_PROD_POS_FILIAL"
			nValue := ARRAY_PROD_POS_FILIAL
		Case cInfo == "ARRAY_PROD_POS_PROD"
			nValue := ARRAY_PROD_POS_PROD
		Case cInfo == "ARRAY_PROD_POS_LOCPAD"
			nValue := ARRAY_PROD_POS_LOCPAD
		Case cInfo == "ARRAY_PROD_POS_TIPO"
			nValue := ARRAY_PROD_POS_TIPO
		Case cInfo == "ARRAY_PROD_POS_GRUPO"
			nValue := ARRAY_PROD_POS_GRUPO
		Case cInfo == "ARRAY_PROD_POS_QE"
			nValue := ARRAY_PROD_POS_QE
		Case cInfo == "ARRAY_PROD_POS_EMIN"
			nValue := ARRAY_PROD_POS_EMIN
		Case cInfo == "ARRAY_PROD_POS_ESTSEG"
			nValue := ARRAY_PROD_POS_ESTSEG
		Case cInfo == "ARRAY_PROD_POS_PE"
			nValue := ARRAY_PROD_POS_PE
		Case cInfo == "ARRAY_PROD_POS_TIPE"
			nValue := ARRAY_PROD_POS_TIPE
		Case cInfo == "ARRAY_PROD_POS_LE"
			nValue := ARRAY_PROD_POS_LE
		Case cInfo == "ARRAY_PROD_POS_LM"
			nValue := ARRAY_PROD_POS_LM
		Case cInfo == "ARRAY_PROD_POS_TOLER"
			nValue := ARRAY_PROD_POS_TOLER
		Case cInfo == "ARRAY_PROD_POS_TIPDEC"
			nValue := ARRAY_PROD_POS_TIPDEC
		Case cInfo == "ARRAY_PROD_POS_RASTRO"
			nValue := ARRAY_PROD_POS_RASTRO
		Case cInfo == "ARRAY_PROD_POS_MRP"
			nValue := ARRAY_PROD_POS_MRP
		Case cInfo == "ARRAY_PROD_POS_REVATU"
			nValue := ARRAY_PROD_POS_REVATU
		Case cInfo == "ARRAY_PROD_POS_EMAX"
			nValue := ARRAY_PROD_POS_EMAX
		Case cInfo == "ARRAY_PROD_POS_PROSBP"
			nValue := ARRAY_PROD_POS_PROSBP
		Case cInfo == "ARRAY_PROD_POS_LOTSBP"
			nValue := ARRAY_PROD_POS_LOTSBP
		Case cInfo == "ARRAY_PROD_POS_ESTORI"
			nValue := ARRAY_PROD_POS_ESTORI
		Case cInfo == "ARRAY_PROD_POS_APROPR"
			nValue := ARRAY_PROD_POS_APROPR
		Case cInfo == "ARRAY_PROD_POS_HORFIX"
			nValue := ARRAY_PROD_POS_HORFIX
		Case cInfo == "ARRAY_PROD_POS_TPHFIX"
			nValue := ARRAY_PROD_POS_TPHFIX
		Case cInfo == "ARRAY_PROD_POS_NUMDEC"
			nValue := ARRAY_PROD_POS_NUMDEC
		Case cInfo == "ARRAY_PROD_POS_CPOTEN"
			nValue := ARRAY_PROD_POS_CPOTEN
		Case cInfo == "ARRAY_PROD_POS_IDREG"
			nValue := ARRAY_PROD_POS_IDREG
		Case cInfo == "ARRAY_PROD_POS_BLOQUEADO"
			nValue := ARRAY_PROD_POS_BLOQUEADO
		Case cInfo == "ARRAY_PROD_POS_CONTRATO"
			nValue := ARRAY_PROD_POS_CONTRATO
		Case cInfo == "ARRAY_PROD_POS_ROTEIRO"
			nValue := ARRAY_PROD_POS_ROTEIRO
		Case cInfo == "ARRAY_PROD_POS_CCUSTO"
			nValue := ARRAY_PROD_POS_CCUSTO
		Case cInfo == "ARRAY_PROD_POS_LDTRANSF"
			nValue := ARRAY_PROD_POS_LDTRANSF
		Case cInfo == "ARRAY_PROD_POS_DESC"
			nValue := ARRAY_PROD_POS_DESC
		Case cInfo == "ARRAY_PROD_POS_DESCTP"
			nValue := ARRAY_PROD_POS_DESCTP
		Case cInfo == "ARRAY_PROD_POS_GRPCOM"
			nValue := ARRAY_PROD_POS_GRPCOM
		Case cInfo == "ARRAY_PROD_POS_GCDESC"
			nValue := ARRAY_PROD_POS_GCDESC
		Case cInfo == "ARRAY_PROD_POS_UM"
			nValue := ARRAY_PROD_POS_UM
		Case cInfo == "ARRAY_PROD_POS_SIZE"
			nValue := ARRAY_PROD_POS_SIZE
		Case cInfo == "ARRAY_TRANSF_POS_FILIAL"
			nValue := ARRAY_TRANSF_POS_FILIAL
		Case cInfo == "ARRAY_TRANSF_POS_LEADTIME"
			nValue := ARRAY_TRANSF_POS_LEADTIME
		Case cInfo == "ARRAY_TRANSF_POS_SIZE"
			nValue := ARRAY_TRANSF_POS_SIZE
		Case cInfo == "ARRAY_PROD_POS_OPC"
			nValue := ARRAY_PROD_POS_OPC
		Case cInfo == "ARRAY_PROD_POS_STR_OPC"
			nValue := ARRAY_PROD_POS_STR_OPC
		Case cInfo == "ARRAY_TRANSF_POS_AGLUTMRP"
			nValue := ARRAY_TRANSF_POS_AGLUTMRP
		Otherwise
			nValue := ARRAY_PROD_POS_SIZE
	EndCase
Return nValue 

/*/{Protheus.doc} MATA010API
Eventos de integração do Cadastro de Produtos

@author douglas.heydt
@since 03/10/2019
@version P12.1.27
/*/
CLASS MATA010API FROM FWModelEvent

	DATA cFantasm       AS CHARACTER
	DATA cB1MSBLQL      AS CHARACTER
	DATA nQtdBaseEst    AS CHARACTER
	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC

	METHOD New() CONSTRUCTOR

	METHOD BeforeTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)
ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de integração das integrações do Cadastro de Produtos

@author douglas.heydt
@since 03/10/2019
@version P12.1.27
/*/
METHOD New() CLASS MATA010API

	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.
	::cFantasm       := Nil
	::cB1MSBLQL      := Nil

	::lIntegraMRP := IntNewMRP("MRPPRODUCT", @::lIntegraOnline)

Return Self

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author renan.roeder
@since 04/11/2019
@version P12.1.27
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS MATA010API
	Local oMdlSB1 := oModel:GetModel("SB1MASTER")

	::cFantasm    := Nil
	::cB1MSBLQL   := Nil
	::nQtdBaseEst := Nil

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If SB1->( dbSeek( xFilial("SB1") + oMdlSB1:GetValue("B1_COD") ) )
			::cFantasm    := SB1->B1_FANTASM
			::cB1MSBLQL   := SB1->B1_MSBLQL
			::nQtdBaseEst := SB1->B1_QB
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author renan.roeder
@since 04/11/2019
@version P12.1.27
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA010API
	Local oMdlSB1 := oModel:GetModel("SB1MASTER")
	Local oMdlSGI := oModel:GetModel("SGIDETAIL")

	If ::lIntegraMRP == .T.
		If ::cFantasm != Nil .And. ::cFantasm != oMdlSB1:GetValue("B1_FANTASM")
			If oMdlSGI == Nil .Or. !oMdlSGI:IsModified()
				IntEstrMRP(oMdlSB1:GetValue("B1_COD"))
			EndIf
		EndIf

		If _lIntEstPA
			If (::cB1MSBLQL   != Nil .And. ::cB1MSBLQL   != oMdlSB1:GetValue("B1_MSBLQL")) .Or. ;
			   (::nQtdBaseEst != Nil .And. ::nQtdBaseEst != SB1->B1_QB)
				MTA010G1PA(oMdlSB1:GetValue("B1_COD"), oMdlSB1:GetValue("B1_MSBLQL"))
			EndIf
		EndIf
	EndIf

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

	A010IntPrd(oModel, Self, IIf(oModel:GetOperation() == MODEL_OPERATION_DELETE, "DELETE", "INSERT"))

Return Nil

/*/{Protheus.doc} A010IntPrd
Integra dados com a API
@author douglas.heydt
@since 23/07/2019
@version P12
@param 01 oModel   , Object   , Modelo principal
@param 02 oSelf    , Object   , Instância atual desta classe
@param 03 cOperacao, Character, Indicador da operação ("DELETE","INSERT")
@param 04 cAlias   , Character, Alias para buscar as informações (se passado, não será considerado o modelo)
@param 05 cGCDesc  , Character, Descrição do grupo de compras que foi alterado (Origem: COMA086)
@return Nil
/*/
Function A010IntPrd(oModel, oSelf, cOperacao, cAlias, cGCDesc)

	Local aDadosDel := {}
	Local aDadosInc := {}
	Local lModel    := .F.
	Local lIntegSB5 := FWAliasInDic("SMI", .F.) .And. ("SB5" $ SuperGetMV("MV_CADPROD",.F.,.F.))
	Local nPos      := 0
	Local oMdlSB1   := Nil
	Local oMdlSB5   := Nil
	Local oMdlSVK   := Nil

	Default cGCDesc := ""

	If Empty(cAlias)
		lModel  := .T.
		oMdlSB1 := oModel:GetModel("SB1MASTER")
		oMdlSVK := oModel:GetModel("SVKDETAIL")

		If lIntegSB5
			oMdlSB5 := oModel:GetModel("SB5DETAIL")
		EndIf
	EndIf

	If cOperacao == "DELETE"
		//Adiciona todas as datas que devem ser deletadas
		aAdd(aDadosDel,Array(ARRAY_PROD_POS_SIZE))
		nPos  := Len(aDadosDel)

		//Adiciona as informações no array de exclusão
		aDadosDel[nPos][ARRAY_PROD_POS_FILIAL] := IIf(lModel, oMdlSB1:GetValue("B1_FILIAL"), (cAlias)->B1_FILIAL)
		aDadosDel[nPos][ARRAY_PROD_POS_PROD  ] := IIf(lModel, oMdlSB1:GetValue("B1_COD"   ), (cAlias)->B1_COD   )
		aDadosDel[nPos][ARRAY_PROD_POS_IDREG ] := aDadosDel[nPos][ARRAY_PROD_POS_FILIAL] + aDadosDel[nPos][ARRAY_PROD_POS_PROD]
	Else
		//Adiciona nova linha no array de inclusão/atualização.
		aAdd(aDadosInc,Array(ARRAY_PROD_POS_SIZE))
		nPos := Len(aDadosInc)

		//Adiciona as informações no array de inclusão/atualização.
		aDadosInc[nPos][ARRAY_PROD_POS_FILIAL   ] := IIf(lModel, oMdlSB1:GetValue("B1_FILIAL" ), (cAlias)->B1_FILIAL )
		aDadosInc[nPos][ARRAY_PROD_POS_PROD     ] := IIf(lModel, oMdlSB1:GetValue("B1_COD"    ), (cAlias)->B1_COD    )
		aDadosInc[nPos][ARRAY_PROD_POS_LOCPAD   ] := IIf(lModel, oMdlSB1:GetValue("B1_LOCPAD" ), (cAlias)->B1_LOCPAD )
		aDadosInc[nPos][ARRAY_PROD_POS_TIPO     ] := IIf(lModel, oMdlSB1:GetValue("B1_TIPO"   ), (cAlias)->B1_TIPO   )
		aDadosInc[nPos][ARRAY_PROD_POS_GRUPO    ] := IIf(lModel, oMdlSB1:GetValue("B1_GRUPO"  ), (cAlias)->B1_GRUPO  )
		aDadosInc[nPos][ARRAY_PROD_POS_QE       ] := IIf(lModel, oMdlSB1:GetValue("B1_QE"     ), (cAlias)->B1_QE     )
		aDadosInc[nPos][ARRAY_PROD_POS_EMIN     ] := IIf(lModel, oMdlSB1:GetValue("B1_EMIN"   ), (cAlias)->B1_EMIN   )
		aDadosInc[nPos][ARRAY_PROD_POS_ESTSEG   ] := IIf(lModel, oMdlSB1:GetValue("B1_ESTSEG" ), (cAlias)->B1_ESTSEG )
		aDadosInc[nPos][ARRAY_PROD_POS_PE       ] := IIf(lModel, oMdlSB1:GetValue("B1_PE"     ), (cAlias)->B1_PE     )
		aDadosInc[nPos][ARRAY_PROD_POS_LOTSBP   ] := IIf(lModel, oMdlSB1:GetValue("B1_LOTESBP"), (cAlias)->B1_LOTESBP)
		aDadosInc[nPos][ARRAY_PROD_POS_ESTORI   ] := IIf(lModel, oMdlSB1:GetValue("B1_ESTRORI"), (cAlias)->B1_ESTRORI)
		aDadosInc[nPos][ARRAY_PROD_POS_EMAX     ] := IIf(lModel, oMdlSB1:GetValue("B1_EMAX"   ), (cAlias)->B1_EMAX   )
		aDadosInc[nPos][ARRAY_PROD_POS_LE       ] := IIf(lModel, oMdlSB1:GetValue("B1_LE"     ), (cAlias)->B1_LE     )
		aDadosInc[nPos][ARRAY_PROD_POS_LM       ] := IIf(lModel, oMdlSB1:GetValue("B1_LM"     ), (cAlias)->B1_LM     )
		aDadosInc[nPos][ARRAY_PROD_POS_TOLER    ] := IIf(lModel, oMdlSB1:GetValue("B1_TOLER"  ), (cAlias)->B1_TOLER  )
		aDadosInc[nPos][ARRAY_PROD_POS_BLOQUEADO] := Iif(lModel, oMdlSB1:GetValue("B1_MSBLQL" ), (cAlias)->B1_MSBLQL )
		aDadosInc[nPos][ARRAY_PROD_POS_REVATU   ] := IIf(lModel, oMdlSB1:GetValue("B1_REVATU" ), IIf(_lPCPREVAT, PCPREVATU((cAlias)->B1_COD), (cAlias)->B1_REVATU))
		aDadosInc[nPos][ARRAY_PROD_POS_TIPE     ] := RetTpPrazo(IIf(lModel, oMdlSB1:GetValue("B1_TIPE")   , (cAlias)->B1_TIPE   ))
		aDadosInc[nPos][ARRAY_PROD_POS_PROSBP   ] := RetProdSBP(IIf(lModel, oMdlSB1:GetValue("B1_PRODSBP"), (cAlias)->B1_PRODSBP))
		aDadosInc[nPos][ARRAY_PROD_POS_RASTRO   ] := RetRastro( IIf(lModel, oMdlSB1:GetValue("B1_RASTRO") , (cAlias)->B1_RASTRO ))
		aDadosInc[nPos][ARRAY_PROD_POS_TIPDEC   ] := RetTpDec(  IIf(lModel, oMdlSB1:GetValue("B1_TIPODEC"), (cAlias)->B1_TIPODEC))
		aDadosInc[nPos][ARRAY_PROD_POS_APROPR   ] := RetAprop(  IIf(lModel, oMdlSB1:GetValue("B1_APROPRI"), (cAlias)->B1_APROPRI))
		aDadosInc[nPos][ARRAY_PROD_POS_MRP      ] := RetMrp(    IIf(lModel, oMdlSB1:GetValue("B1_MRP")    , (cAlias)->B1_MRP    ))
		aDadosInc[nPos][ARRAY_PROD_POS_CONTRATO ] := RetContrat(IIf(lModel, oMdlSB1:GetValue("B1_CONTRAT"), (cAlias)->B1_CONTRAT))
		aDadosInc[nPos][ARRAY_PROD_POS_ROTEIRO  ] := Iif(lModel, oMdlSB1:GetValue("B1_OPERPAD"), (cAlias)->B1_OPERPAD)
		aDadosInc[nPos][ARRAY_PROD_POS_CCUSTO   ] := Iif(lModel, oMdlSB1:GetValue("B1_CCCUSTO"), (cAlias)->B1_CCCUSTO)
		aDadosInc[nPos][ARRAY_PROD_POS_CPOTEN   ] := IIf(PotencLote(aDadosInc[nPos][ARRAY_PROD_POS_PROD]), '1', '2')
		aDadosInc[nPos][ARRAY_PROD_POS_DESC     ] := IIf(lModel, oMdlSB1:GetValue("B1_DESC"   ), (cAlias)->B1_DESC   )
		aDadosInc[nPos][ARRAY_PROD_POS_DESCTP   ] := RetDescTp( IIf(lModel, oMdlSB1:GetValue("B1_TIPO")   , (cAlias)->B1_TIPO   ))
		aDadosInc[nPos][ARRAY_PROD_POS_GRPCOM   ] := IIf(lModel, oMdlSB1:GetValue("B1_GRUPCOM"), (cAlias)->B1_GRUPCOM)
		aDadosInc[nPos][ARRAY_PROD_POS_GCDESC   ] := IIf(lModel, RetGcDesc(oMdlSB1:GetValue("B1_GRUPCOM")), IIf(Empty(cGCDesc), RetGcDesc((cAlias)->B1_GRUPCOM), cGCDesc))
		aDadosInc[nPos][ARRAY_PROD_POS_UM       ] := IIf(lModel, oMdlSB1:GetValue("B1_UM"), (cAlias)->B1_UM)
		aDadosInc[nPos][ARRAY_PROD_POS_OPC      ] := IIf(lModel, oMdlSB1:GetValue("B1_MOPC"), (cAlias)->B1_MOPC)
		aDadosInc[nPos][ARRAY_PROD_POS_STR_OPC  ] := IIf(lModel, oMdlSB1:GetValue("B1_OPC"), (cAlias)->B1_OPC)

		If lIntegSB5
			aDadosInc[nPos][ARRAY_PROD_POS_LDTRANSF ] := {}
			addDadosB5(aDadosInc[nPos], oMdlSB5)
		EndIf

		If lModel .And. Empty(aDadosInc[nPos][ARRAY_PROD_POS_FILIAL]) .And. oMdlSB1:GetOperation() == MODEL_OPERATION_INSERT
			//Tratativa para quando utiliza modelo e é uma inclusão de produto.
			//Nesse cenário, a filial não vai estar preenchida no modelo.
			aDadosInc[nPos][ARRAY_PROD_POS_FILIAL] := xFilial("SB1")
		EndIf

		If oMdlSVK == NIL
			SVK->( dbSetOrder(1) )
			If SVK->( dbSeek( xFilial("SVK") + aDadosInc[nPos][ARRAY_PROD_POS_PROD] ) )
				aDadosInc[nPos][ARRAY_PROD_POS_HORFIX] := SVK->VK_HORFIX
				aDadosInc[nPos][ARRAY_PROD_POS_TPHFIX] := SVK->VK_TPHOFIX
			EndIf
		Else
			aDadosInc[nPos][ARRAY_PROD_POS_HORFIX] := oMdlSVK:GetValue("VK_HORFIX")
			aDadosInc[nPos][ARRAY_PROD_POS_TPHFIX] := oMdlSVK:GetValue("VK_TPHOFIX")
		EndIf

		aDadosInc[nPos][ARRAY_PROD_POS_NUMDEC] := "0"//Protheus não utiliza esse campo, passar 0 fixo
		aDadosInc[nPos][ARRAY_PROD_POS_IDREG ] := aDadosInc[nPos][ARRAY_PROD_POS_FILIAL] + aDadosInc[nPos][ARRAY_PROD_POS_PROD]
	EndIf

	If Len(aDadosDel) > 0
		MATA010INT("DELETE", aDadosDel)
	EndIf

	If Len(aDadosInc) > 0
		MATA010INT("INSERT", aDadosInc)
	EndIf

Return

/*/{Protheus.doc} MATA010INT
Função que executa a integração de Produtos com o MRP.
@type  Function
@author douglas.heydt
@since 23/07/2019
@version P12
@param cOperation, Caracter, Operação que será executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso
@param aError    , Array   , Carrega os registros que não foram integrados por erro
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lBuffer	 , Logic   , Define a sincronização em processo de buffer.
@return Nil
/*/
Function MATA010INT(cOperation, aDados, aSuccess, aError, lOnlyDel, cUUID, lBuffer)
	Local aReturn   := {}
	Local lAllError := .F.
	Local nIndex    := 0
	Local nIndIncl  := 0
	Local nIndExcl  := 0
	Local nIndSB5    := 0
	Local nTotal    := 0
	Local oJsonIncl := Nil
	Local oJsonExcl := Nil
	Local cApi      := "MRPPRODUCT"

	Default aSuccess := {}
	Default aError   := {}
	Default cUUID    := ""
	Default lOnlyDel := .F.
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonIncl := JsonObject():New()
	oJsonIncl["items"] := {}

	oJsonExcl := JsonObject():New()
	oJsonExcl["items"] := {}

	For nIndex := 1 To nTotal

		If cOperation $ "|INSERT|SYNC|" .And. (aDados[nIndex][ARRAY_PROD_POS_BLOQUEADO] == Nil .Or. aDados[nIndex][ARRAY_PROD_POS_BLOQUEADO] <> '1')
			nIndIncl++
			AAdd(oJsonIncl["items"], JsonObject():New())

			oJsonIncl["items"][nIndIncl]["branchId"] := aDados[nIndex][ARRAY_PROD_POS_FILIAL]

			If ! (lOnlyDel .And. cOperation == "SYNC")
				oJsonIncl["items"][nIndIncl]["code"                         ] := aDados[nIndex][ARRAY_PROD_POS_IDREG]
				oJsonIncl["items"][nIndIncl]["product"                      ] := aDados[nIndex][ARRAY_PROD_POS_PROD]
				oJsonIncl["items"][nIndIncl]["warehouse"                    ] := aDados[nIndex][ARRAY_PROD_POS_LOCPAD]
				oJsonIncl["items"][nIndIncl]["type"                         ] := aDados[nIndex][ARRAY_PROD_POS_TIPO]
				oJsonIncl["items"][nIndIncl]["group"                        ] := aDados[nIndex][ARRAY_PROD_POS_GRUPO]
				oJsonIncl["items"][nIndIncl]["packingQuantity"              ] := aDados[nIndex][ARRAY_PROD_POS_QE]
				oJsonIncl["items"][nIndIncl]["orderPoint"                   ] := aDados[nIndex][ARRAY_PROD_POS_EMIN]
				oJsonIncl["items"][nIndIncl]["safetyStock"                  ] := aDados[nIndex][ARRAY_PROD_POS_ESTSEG]
				oJsonIncl["items"][nIndIncl]["deliveryLeadTime"             ] := aDados[nIndex][ARRAY_PROD_POS_PE]
				oJsonIncl["items"][nIndIncl]["typeDeliveryLeadTime"         ] := aDados[nIndex][ARRAY_PROD_POS_TIPE]
				oJsonIncl["items"][nIndIncl]["economicLotSize"              ] := aDados[nIndex][ARRAY_PROD_POS_LE]
				oJsonIncl["items"][nIndIncl]["minimumLotSize"               ] := aDados[nIndex][ARRAY_PROD_POS_LM]
				oJsonIncl["items"][nIndIncl]["tolerance"                    ] := aDados[nIndex][ARRAY_PROD_POS_TOLER]
				oJsonIncl["items"][nIndIncl]["decimalType"                  ] := aDados[nIndex][ARRAY_PROD_POS_TIPDEC]
				oJsonIncl["items"][nIndIncl]["traceability"                 ] := aDados[nIndex][ARRAY_PROD_POS_RASTRO]
				oJsonIncl["items"][nIndIncl]["enterMRP"                     ] := aDados[nIndex][ARRAY_PROD_POS_MRP]
				oJsonIncl["items"][nIndIncl]["currentBillOfMaterialRevision"] := aDados[nIndex][ARRAY_PROD_POS_REVATU]
				oJsonIncl["items"][nIndIncl]["maximumStock"                 ] := aDados[nIndex][ARRAY_PROD_POS_EMAX]
				oJsonIncl["items"][nIndIncl]["processByProduct"             ] := aDados[nIndex][ARRAY_PROD_POS_PROSBP]
				oJsonIncl["items"][nIndIncl]["byProductLot"                 ] := aDados[nIndex][ARRAY_PROD_POS_LOTSBP]
				oJsonIncl["items"][nIndIncl]["byProductBillOfMaterials"     ] := aDados[nIndex][ARRAY_PROD_POS_ESTORI]
				oJsonIncl["items"][nIndIncl]["appropriation"                ] := aDados[nIndex][ARRAY_PROD_POS_APROPR]
				oJsonIncl["items"][nIndIncl]["fixedHorizon"                 ] := aDados[nIndex][ARRAY_PROD_POS_HORFIX]
				oJsonIncl["items"][nIndIncl]["fixedHorizonType"             ] := aDados[nIndex][ARRAY_PROD_POS_TPHFIX]
				oJsonIncl["items"][nIndIncl]["numberDecimals"               ] := aDados[nIndex][ARRAY_PROD_POS_NUMDEC]
				oJsonIncl["items"][nIndIncl]["controlPotential"             ] := aDados[nIndex][ARRAY_PROD_POS_CPOTEN]
				oJsonIncl["items"][nIndIncl]["blocked"                      ] := aDados[nIndex][ARRAY_PROD_POS_BLOQUEADO]
				oJsonIncl["items"][nIndIncl]["purchaseContract"             ] := aDados[nIndex][ARRAY_PROD_POS_CONTRATO]
				oJsonIncl["items"][nIndIncl]["defaultRouting"               ] := aDados[nIndex][ARRAY_PROD_POS_ROTEIRO]
				oJsonIncl["items"][nIndIncl]["costCenterForCosting"         ] := aDados[nIndex][ARRAY_PROD_POS_CCUSTO]
				oJsonIncl["items"][nIndIncl]["productDescription"           ] := aDados[nIndex][ARRAY_PROD_POS_DESC]
				oJsonIncl["items"][nIndIncl]["productTypeDescription"       ] := aDados[nIndex][ARRAY_PROD_POS_DESCTP]
				oJsonIncl["items"][nIndIncl]["purchaseGroup"                ] := aDados[nIndex][ARRAY_PROD_POS_GRPCOM]
				oJsonIncl["items"][nIndIncl]["purchaseGroupDescription"     ] := aDados[nIndex][ARRAY_PROD_POS_GCDESC]
				oJsonIncl["items"][nIndIncl]["measurementUnit"              ] := aDados[nIndex][ARRAY_PROD_POS_UM]

				If aDados[nIndex][ARRAY_PROD_POS_LDTRANSF] <> Nil
					oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"] := {}
					For nIndSB5 := 1 To Len(aDados[nIndex][ARRAY_PROD_POS_LDTRANSF])
						aTransf := aDados[nIndex][ARRAY_PROD_POS_LDTRANSF][nIndSB5]

						Aadd(oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"], JsonObject():New())
						oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"][nIndSB5]["branchId"        ] := aTransf[ARRAY_TRANSF_POS_FILIAL  ]
						oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"][nIndSB5]["transferLeadTime"] := aTransf[ARRAY_TRANSF_POS_LEADTIME]
						oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"][nIndSB5]["aglutinaMRP"     ] := aTransf[ARRAY_TRANSF_POS_AGLUTMRP]
						
					Next nIndSB5
				//Else
				//	oJsonIncl["items"][nIndIncl]["listOfLeadTimeTransfer"] := {}
				EndIf

				//Faz a soma de +1 na quantidade do ponto de pedido.
				If oJsonIncl["items"][nIndIncl]["orderPoint"] <> 0
					oJsonIncl["items"][nIndIncl]["orderPoint"]++
				EndIf

				If Empty(aDados[nIndex][ARRAY_PROD_POS_OPC])
					oJsonIncl["items"][nIndIncl]["erpMemoOptional"] := Nil
					oJsonIncl["items"][nIndIncl]["optional"]        := Nil
				Else
					oJsonIncl["items"][nIndIncl]["erpMemoOptional"] := aDados[nIndex][ARRAY_PROD_POS_OPC]
					oJsonIncl["items"][nIndIncl]["optional"]        := MOpcToJson(aDados[nIndex][ARRAY_PROD_POS_OPC], 2)
				EndIf

				If Empty(aDados[nIndex][ARRAY_PROD_POS_STR_OPC])
					oJsonIncl["items"][nIndIncl]["erpStringOptional"] := Nil
				Else
					oJsonIncl["items"][nIndIncl]["erpStringOptional"] := aDados[nIndex][ARRAY_PROD_POS_STR_OPC]
				EndIf
			EndIf
		Else
			nIndExcl++
			AAdd(oJsonExcl["items"], JsonObject():New())

			oJsonExcl["items"][nIndExcl]["branchId"] := aDados[nIndex][ARRAY_PROD_POS_FILIAL]
			oJsonExcl["items"][nIndExcl]["product" ] := aDados[nIndex][ARRAY_PROD_POS_PROD]
			oJsonExcl["items"][nIndExcl]["code"    ] := aDados[nIndex][ARRAY_PROD_POS_IDREG]

		EndIf
	Next nIndex

	If nIndIncl > 0 .Or. cOperation == "SYNC"
		If cOperation == "INSERT"
			aReturn := MrpPrdPost(oJsonIncl)
		Else
			aReturn := MrpPrdSync(oJsonIncl, lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonIncl, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	EndIf

	If nIndExcl > 0
		aReturn := MrpPrdDel(oJsonExcl)
		PrcPendMRP(aReturn, cApi, oJsonExcl, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
	EndIf

	FreeObj(oJsonIncl)
	oJsonIncl := Nil
	FreeObj(oJsonExcl)
	oJsonExcl := Nil

Return Nil

/*/{Protheus.doc} RetTpPrazo
Retorna o código do tipo de prazo de entrega
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cPrazp, Caracter, Tipo de prazo (H=Horas;D=Dias;S=Semana;M=Mês;A=Ano)
@return cRet, Caracter,  1=Horas; 2=Dias; 3=Semana; 4=Mês; 5=Ano
/*/
Static Function RetTpPrazo(cPrazo)

	Do Case
		Case cPrazo == 'H'//Hora
			Return '1'
		Case cPrazo == 'D'//Dia
			Return '2'
		Case cPrazo == 'S'//Semana
			Return '3'
		Case cPrazo == 'M'//Mes
			Return '4'
		Case cPrazo == 'A'//Ano
			Return '5'
	EndCase

Return

/*/{Protheus.doc} RetTpDec
Retorna o código do tipo de decimal
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo de decimal (N=Normal; A=Arredonda; I=Incrementa; T=Trunca)
@return cRet, Caracter,  1=Normal; 2=Arredonda; 3=Incrementa; 4=Trunca
/*/
Static Function RetTpDec(cTipo)

	Do Case
		Case cTipo == 'N'//Normal
			Return '1'
		Case cTipo == 'A'//Arredonda
			Return '2'
		Case cTipo == 'I'//Incrementa
			Return '3'
		Case cTipo == 'T'//Trunca
			Return '4'
	EndCase

Return

/*/{Protheus.doc} RetRastro
Retorna o código do tipo rastro
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo de decimal (S=Sublote; L=Lote; N=Nao arredonda)
@return Caracter,  1=Sublote; 2=Lote; 3=Nao utiliza
/*/
Static Function RetRastro(cTipo)

	 Do Case
		Case cTipo == 'S'//Sublote
			Return '1'
		Case cTipo == 'L'//Lote
			Return '2'
		Case cTipo == 'N'//Não utiliza
			Return '3'
	EndCase

Return

/*/{Protheus.doc} RetProdSBP
Retorna o código do tipo rastro
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo de decimal (P=Produzindo; C=Comprando)
@return Caracter,  1=Produzindo; 2=Comprando;
/*/
Static Function RetProdSBP(cTipo)

	If cTipo == 'P'//Produzindo
		Return '1'
	ElseIf cTipo == 'C'//Comprando
		Return '2'
	EndIf

Return

/*/{Protheus.doc} RetRastro
Retorna o código do tipo rastro
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo de decimal (D=Direto; I=Indireto)
@return Caracter,  1=Direto; 2=Indireto;
/*/
Static Function RetAprop(cTipo)

	If cTipo == 'D'//Direto
		Return '1'
	ElseIf cTipo == 'I'//Indireto
		Return '2'
	EndIf

Return

/*/{Protheus.doc} RetMrp
Retorna o tipo de uso do MRP
@type  Static Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo do MRP (S=Sim; N=Não; E=Especial)
@return Caracter,  1=Sim; 2=Não;
/*/
Static Function RetMrp(cTipo)

	If cTipo == 'S'//Sim
		Return '1'
	ElseIf cTipo == 'N'//Não
		Return '2'
	ElseIf cTipo == 'E'//Especial
		Return '2'
	EndIf

Return

/*/{Protheus.doc} RetContrat
Retorna o código do tipo de contrato
@type  Static Function
@author ricardo.prandi
@since 02/03/2020
@version P12.1.30
@param cTipo, Caracter, Tipo do contrato (S=Sim; A=Ambos; N=Não)
@return Caracter,  1=Sim; 2=Não;
/*/
Static Function RetContrat(cTipo)

	If cTipo == 'S'     //Sim
		Return '1'
	ElseIf cTipo == 'A' //Ambos
		Return '1'
	Else                //Não/branco
		Return '2'
	EndIf

Return

/*/{Protheus.doc} RetDescTp
Retorna a descrição do tipo do produto
@type  Function
@author parffit.silva
@since 13/04/2021
@version P12
@param cTipo, Caracter, Tipo do produto (SB1.B1_TIPO)
@return cRet, Caracter, Descrição do tipo (SX5-Tabela 02)
/*/
Static Function RetDescTp(cTipo)
Local aDadosSx5 := {}
Local cDescTipo := STR0001 //"Tipo não cadastrado na SX5"

aDadosSx5 := FWGetSX5('02', cTipo)

IF !EMPTY(aDadosSx5)
	cDescTipo := AllTrim(aDadosSx5[1][4])
ENDIF

Return cDescTipo

/*/{Protheus.doc} RetGcDesc
Retorna a descrição do grupo de compras
@type  Function
@author parffit.silva
@since 13/04/2021
@version P12
@param cGrCom, Caracter, Grupo de compras (SB1.B1_GRUPCOM)
@return cRet, Caracter, Descrição do grupo de compras (SAJ.AJ_DESC)
/*/
Static Function RetGcDesc(cGrCom)
	Local cAliasSAJ  := ""
	Local cGCDesc    := ""

	If Empty(cGrCom)
		Return ""
	EndIf

	cAliasSAJ  := GetNextAlias()
	BeginSql Alias cAliasSAJ
		SELECT AJ_DESC
		  FROM %table:SAJ% SAJ
		 WHERE AJ_FILIAL = %xFilial:SAJ%
		   AND SAJ.AJ_GRCOM = %Exp:cGrCom%
		   AND SAJ.%notDel%
	EndSql

	If (cAliasSAJ)->(!Eof())
		cGCDesc := (cAliasSAJ)->(AJ_DESC)
	EndIf
	(cAliasSAJ)->(dbCloseArea())

Return cGCDesc

/*/{Protheus.doc} M010CnvFld
Retorna o campo convertido no formato a ser enviado para a API (chamada pelo PCPA140)
@type  Function
@author marcelo.neumann
@since 23/10/2019
@version P12
@param 01 cField, Caracter, campo (coluna da SB1) a ser convertida
@param 02 cValue, Caracter, valor a ser convertido
@return cValue  , Caracter, valor convertido no formato da API
/*/
Function M010CnvFld(cField, cValue)

	Do Case
		Case cField == "B1_TIPE"
			cValue := RetTpPrazo(cValue)
		Case cField == "B1_TIPODEC"
			cValue := RetTpDec(cValue)
		Case cField == "B1_RASTRO"
			cValue := RetRastro(cValue)
		Case cField == "B1_MRP"
			cValue := RetMrp(cValue)
		Case cField == "B1_PRODSBP"
			cValue := RetProdSBP(cValue)
		Case cField == "B1_APROPRI"
			cValue := RetAprop(cValue)
		Case cField == "B1_CONTRAT"
			cValue := RetContrat(cValue)
		Case cField == "B1_DESCTP"
			cValue := RetDescTp(cValue)
		Case cField == "B1_GCDESC"
			cValue := RetGcDesc(cValue)
	EndCase

Return cValue

/*/{Protheus.doc} IntEstrMRP
Função para integrar o produto com as estruturas no MRP.

@type  Function
@author renan.roeder
@since 04/11/2019
@version P12
@param cProduto, Character, Código do produto
@return Nil
/*/
Static Function IntEstrMRP(cProduto)

	//Abre uma thread para fazer a integração do produto com as estruturas no MRP.
	StartJob("MTA010IEST", GetEnvServer(), .F., cEmpAnt, cFilAnt, cProduto, .T.)

Return

/*/{Protheus.doc} addDadosB5
Função para carregar os dados da SB5 para integrar todos os registros com o MRP

@type  Function
@author douglas.heydt
@since 22/03/2021
@version P12
@param cProduto, Character, Código do produto
@return Nil
/*/
Static Function addDadosB5(aDadosB5, oMdlSB5)

	Local cAliasQry  := GetNextAlias()
	Local cProduto   := aDadosB5[ARRAY_PROD_POS_PROD]
	Local nInd       := 0
	Local nTamLeadTr := GetSx3Cache("B5_LEADTR", "X3_TAMANHO")
	Local nDecLeadTr := GetSx3Cache("B5_LEADTR", "X3_DECIMAL")

	BeginSql Alias cAliasQry
		COLUMN B5_LEADTR AS NUMERIC(nTamLeadTr, nDecLeadTr)
		SELECT B5_FILIAL, B5_LEADTR, 
		       CASE WHEN B5_AGLUMRP IN ('1', '6', '7') THEN NULL ELSE B5_AGLUMRP END B5_AGLUMRP
		  FROM %table:SB5%
		 WHERE B5_COD = %Exp:cProduto%
		   AND %notDel%
	EndSql

	While (cAliasQry)->(!Eof())
		aAdd(aDadosB5[ARRAY_PROD_POS_LDTRANSF], Array(ARRAY_TRANSF_POS_SIZE))
		nInd++
		aDadosB5[ARRAY_PROD_POS_LDTRANSF][nInd][ARRAY_TRANSF_POS_FILIAL] := (cAliasQry)->B5_FILIAL

		If oMdlSB5 <> NIL .And. oMdlSB5:GetValue("B5_FILIAL") == (cAliasQry)->B5_FILIAL
			aDadosB5[ARRAY_PROD_POS_LDTRANSF][nInd][ARRAY_TRANSF_POS_LEADTIME] := oMdlSB5:GetValue("B5_LEADTR")
			If oMdlSB5:GetValue("B5_AGLUMRP") $ "| |2|3|4|5|"
				aDadosB5[ARRAY_PROD_POS_LDTRANSF][nInd][ARRAY_TRANSF_POS_AGLUTMRP] := oMdlSB5:GetValue("B5_AGLUMRP")
			EndIf
		Else
			aDadosB5[ARRAY_PROD_POS_LDTRANSF][nInd][ARRAY_TRANSF_POS_LEADTIME] := (cAliasQry)->B5_LEADTR
			aDadosB5[ARRAY_PROD_POS_LDTRANSF][nInd][ARRAY_TRANSF_POS_AGLUTMRP] := (cAliasQry)->B5_AGLUMRP
		EndIf

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return