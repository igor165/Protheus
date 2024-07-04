#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"

/*/{Protheus.doc} MATA180API
Eventos padrões do cadastro de roteiros
@author Douglas Heydt
@since 03/03/2021
@version P12.1.30
/*/

CLASS MATA180API FROM FWModelEvent

	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS(oModel, cModelId)

ENDCLASS

METHOD New() CLASS  MATA180API
	
	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.
	If AliasInDic("SMI", .F.)
		::lIntegraMRP := IntNewMRP("MRPPRODUCT", @::lIntegraOnline)
	EndIf

Return Self


/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Douglas Heydt
@since 03/03/2021
@version P12.1.30
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA180API
    
    Local aDadosInc := {}
    Local cAliasQry := GetNextAlias()
    Local cQuery    := ""
	Local oMdlSB5   := oModel:GetModel("SB5MASTER")

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

    cQuery +=  " SELECT  SB1.B1_FILIAL , "
    cQuery +=  "         SB1.B1_COD    , "
    cQuery +=  "         SB1.B1_LOCPAD , "
    cQuery +=  "         SB1.B1_TIPO   , "
    cQuery +=  "         SB1.B1_GRUPO  , "
    cQuery +=  "         SB1.B1_QE     , "
    cQuery +=  "         SB1.B1_EMIN   , "
    cQuery +=  "         SB1.B1_ESTSEG , "
    cQuery +=  "         SB1.B1_PE     , "
    cQuery +=  "         SB1.B1_TIPE   , "
    cQuery +=  "         SB1.B1_LE     , "
    cQuery +=  "         SB1.B1_LM     , "
    cQuery +=  "         SB1.B1_TOLER  , "
    cQuery +=  "         SB1.B1_TIPODEC, "
    cQuery +=  "         SB1.B1_RASTRO , "
    cQuery +=  "         SB1.B1_MRP    , "
    cQuery +=  "         SB1.B1_REVATU , "
    cQuery +=  "         SB1.B1_EMAX   , "
    cQuery +=  "         SB1.B1_PRODSBP, "
    cQuery +=  "         SB1.B1_LOTESBP, "
    cQuery +=  "         SB1.B1_ESTRORI, "
    cQuery +=  "         SB1.B1_APROPRI, "
    cQuery +=  "         SB1.B1_CPOTENC, "
    cQuery +=  "         SB1.B1_MSBLQL , "
    cQuery +=  "         SB1.B1_CONTRAT, "
    cQuery +=  "         SB1.B1_OPERPAD, "
    cQuery +=  "         SB1.B1_CCCUSTO, "
    cQuery +=  "         SB1.B1_DESC,    "
    cQuery +=  "         SB1.B1_GRUPCOM, "
    cQuery +=  "         SVK.VK_HORFIX,  "
    cQuery +=  "         SVK.VK_TPHOFIX, "
	cQuery +=  "         SB5.B5_FILIAL,  "
    cQuery +=  "         SB5.B5_LEADTR,  "
	cQuery +=  "         SB5.B5_COD,     "
	cQuery +=  "         CASE WHEN B5_AGLUMRP IN ('1', '6', '7') THEN NULL ELSE B5_AGLUMRP END B5_AGLUMRP "
	cQuery +=  " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVK") + " SVK"
	cQuery +=    " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=   " AND SVK.VK_FILIAL  = '" + xFilial("SVK") + "'"
	cQuery +=   " AND SVK.VK_COD     = SB1.B1_COD"
	cQuery +=   " AND SVK.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SB5") + " SB5"
	cQuery +=    " ON SB5.B5_COD  = SB1.B1_COD  "
	cQuery +=    " AND SB5.D_E_L_E_T_ = ' ' "
	cQuery +=   " WHERE SB1.B1_COD = '"+oMdlSB5:GetValue("B5_COD")+"' AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=	" AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

    If (cAliasQry)->(!Eof())

		//Adiciona nova linha no array de inclusão/atualização
		aAdd(aDadosInc, Array(A010APICnt("ARRAY_PROD_SIZE")))

		//Adiciona as informações no array de inclusão/atualização
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_FILIAL"   )] := (cAliasQry)->B1_FILIAL
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PROD"     )] := (cAliasQry)->B1_COD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LOCPAD"   )] := (cAliasQry)->B1_LOCPAD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPO"     )] := (cAliasQry)->B1_TIPO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GRUPO"    )] := (cAliasQry)->B1_GRUPO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_QE"       )] := (cAliasQry)->B1_QE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_EMIN"     )] := (cAliasQry)->B1_EMIN
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ESTSEG"   )] := (cAliasQry)->B1_ESTSEG
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PE"       )] := (cAliasQry)->B1_PE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPE"     )] := M010CnvFld("B1_TIPE"   , (cAliasQry)->B1_TIPE)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LE"       )] := (cAliasQry)->B1_LE
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LM"       )] := (cAliasQry)->B1_LM
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TOLER"    )] := (cAliasQry)->B1_TOLER
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TIPDEC"   )] := M010CnvFld("B1_TIPODEC", (cAliasQry)->B1_TIPODEC)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_RASTRO"   )] := M010CnvFld("B1_RASTRO" , (cAliasQry)->B1_RASTRO)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_MRP"      )] := M010CnvFld("B1_MRP"    , (cAliasQry)->B1_MRP)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_REVATU"   )] := (cAliasQry)->B1_REVATU
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_EMAX"     )] := (cAliasQry)->B1_EMAX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_PROSBP"   )] := M010CnvFld("B1_PRODSBP", (cAliasQry)->B1_PRODSBP)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LOTSBP"   )] := (cAliasQry)->B1_LOTESBP
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ESTORI"   )] := (cAliasQry)->B1_ESTRORI
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_APROPR"   )] := M010CnvFld("B1_APROPRI", (cAliasQry)->B1_APROPRI)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CPOTEN"   )] := (cAliasQry)->B1_CPOTENC
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_HORFIX"   )] := (cAliasQry)->VK_HORFIX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_TPHFIX"   )] := (cAliasQry)->VK_TPHOFIX
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_NUMDEC"   )] := "0" //Protheus não utiliza esse campo, passar 0 fixo
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_IDREG"    )] := (cAliasQry)->B1_FILIAL+(cAliasQry)->B1_COD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_BLOQUEADO")] := (cAliasQry)->B1_MSBLQL
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CONTRATO" )] := M010CnvFld("B1_CONTRAT", (cAliasQry)->B1_CONTRAT)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_ROTEIRO"  )] := (cAliasQry)->B1_OPERPAD
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_CCUSTO"   )] := (cAliasQry)->B1_CCCUSTO
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_DESC"     )] := (cAliasQry)->B1_DESC
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_DESCTP"   )] := M010CnvFld("B1_DESCTP", (cAliasQry)->B1_TIPO)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GRPCOM"   )] := (cAliasQry)->B1_GRUPCOM
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_GCDESC"   )] := M010CnvFld("B1_GCDESC", (cAliasQry)->B1_GRUPCOM)
		aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )] := {}

		While (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->(B5_COD))
				aAdd(aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )], Array(A010APICnt("ARRAY_TRANSF_POS_SIZE")))
				nPos := Len(aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )])
				
				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_FILIAL"  )] := (cAliasQry)->B5_FILIAL
				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasQry)->B5_LEADTR
				aDadosInc[1][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_AGLUTMRP")] := (cAliasQry)->B5_AGLUMRP
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo

		If (cAliasQry)->(Eof())
			//Chama a função do MATA010API para integrar os registros
			MATA010INT("INSERT", aDadosInc, Nil, Nil, .F. /*OnlyDel*/, /*cUUID*/, .F. /*Mantêm Registros*/)
			
			//Reseta as variaveis
			aSize(aDadosInc, 0)
		EndIf
	EndIf
		(cAliasQry)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} MATA180PCP
Função para verificar se o fonte existe dentro do MATA180 e substituir o FindClass, que não pode ser utilizado em binários anteriores.

@author ricardo.prandi
@since 24/05/2021
@version 12.1.33
@return .T.
/*/
Function MATA180PCP()
	Local lRet := .T.
Return lRet
