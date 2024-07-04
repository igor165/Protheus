#INCLUDE "JURA162.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'MSOLE.CH'
#INCLUDE 'TOTVS.CH'

Static lActive     := .F.
Static aConfPesq   := {}
Static xVarTAJ     := '' // Variavel Static do C�digo do Tipo de assunto juridico para passagem de valores entre fun��es
Static lWSTLegal := .F. // Vari�vel identificadora do TOTVS Legal. Deixar com False!!!

Static Function GetTPPesq()
Return oPesq:cTipoPesq

Static oPesq := Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} JURA162
Pesquisa de Processos

@author Felipe Bonvicini Conti
@since 28/09/09
@version 1.0
/*/
//---------------------------------------------------------------------
Function JURA162(cTpPesq, cTitulo, cRotina)
Private lPesquisa  := .T.
Private cSQLFeito  := ''
Private lPesquisou := .F.
Private oCmbConfig := Nil
Private aHead      := {}
Private aNTE       := {}

Private cTipoAJ
Private cTipoAsJ

Public c162TipoAs := ''

Default cTpPesq := "1" //Processo
Default cTitulo := STR0016
Default cRotina := "JURA095"

Do case
	Case cTpPesq == "2"
		oPesq := TJurPesqFW():New (cTpPesq, cTitulo, cRotina)
	Case cTpPesq == "3"
		oPesq := TJurPesqGar():New (cTpPesq, cTitulo, cRotina)
	Case cTpPesq == "1"
		oPesq := TJurPesqAsj():New (cTpPesq, cTitulo, cRotina)
	Case cTpPesq == "4"
		oPesq := TJurPesqAnd():New (cTpPesq, cTitulo, cRotina)
	Case cTpPesq == "5"
		oPesq := TJurPesqDes():New (cTpPesq, cTitulo, cRotina)
    Case cTpPesq == "6"
        oPesq := TJurPesqDoc():New (cTpPesq, cTitulo, cRotina)
End Case

lActive := .T.

if oPesq != Nil
	oPesq:Activate()
Endif

if oPesq != Nil
	freeObj(oPesq)
Endif

INCLUI := .F.
ALTERA := .T.

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} J162CmpPes
Fun��o para retornar os campos da pesquisa..
Uso Geral.

@Return oObjCmpPes retorna objeto contendo os campos carregados na tela de pesquisa.

@author Reginaldo N Soares
@since 02/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162CmpPes()
	Local oObjCmpPes := oPesq:aObj
Return oObjCmpPes

//-------------------------------------------------------------------
/*/{Protheus.doc} J162XBEscri
Fun��o que verifica os escrit�rios jur�dicos que o usu�rio esta
habilitado a incluir processo para o filtro do F3.
Uso Geral.

@Param cCodigo  Valor que ser� retornado caso n�o exista restri��o.
@Return cEscritorio  Lista de Escritorios permitidos separados por v�rgula (,).

@author Antonio Carlos Ferreira
@since 28/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162XBEscri(cCodigo, cRestEscri)
Local cRet := "@#@#"

Default cCodigo := ""

cRestEscri := JurSetESC()

If !Empty(cRestEscri)
	cRet := "@#NS7->NS7_COD IN (" + cRestEscri + ")@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J162XBArea
Fun��o que verifica as areas jur�dicas que o usu�rio esta
habilitado a incluir processo para o filtro do F3.
Uso Geral.

@Param cCodigo  Valor que ser� retornado caso n�o exista restri��o.
@Param lAtivo  Se for ativo processa caso contrario retorna falso.
@Return cArea  Lista de Areas permitidas separadas por v�rgula (,).

@author Antonio Carlos Ferreira
@since 28/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162XBArea(cCodigo, lAtivo, cRestArea)
Local cRet 		:= "@#@#"

Default cCodigo := ""
Default lAtivo  := .T.

cRestArea := ""

If lAtivo
	cRestArea := JurSetAREA()
EndIf

If !Empty(cRestArea)
	cRet := "@#NRB->NRB_ATIVO == '1' .AND. NRB->NRB_COD IN (" + cRestArea + ") @#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162VerAssunto
Fun��o verifica qual � o tipo de assunto juridico

@author Rafael Rezende Costa
@since 04/04/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162Assun()
Local aArea        := GetArea()
local aTipoAssunto := {}
local cResult      := ''

	cTipo := alltrim(J162GetVCom())
	DbSelectArea("NVJ")

	NVJ-> (DbSetOrder(2))
	If NVJ->(DbSeek(xFilial("NVJ")+cTipo))

	  While !NVJ->(Eof()) .And. ((NVJ->NVJ_CPESQ) == cTipo)
			aAdd(aTipoAssunto, NVJ->NVJ_CASJUR )
			NVJ->(dbSkip())
		End

		cResult := AtoC(aTipoAssunto,',')

	EndIf

	RestArea(aArea)

Return cResult


//-------------------------------------------------------------------
/*/{Protheus.doc} J162GetVCom
Fun��o verifica qual � o tipo de assunto juridico

@author Rafael Rezende Costa
@since 24/04/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function J162GetVCom()
Return J162GetPesq()

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162GetTAJ
Retorna o valor guardado na vari�vel
Uso Geral.

@Return xVarTAJ	 	Codigo do tipo de assunto

@author Jorge Luis Branco Martins Junior
@since 30/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162GetTAJ()
Return oPesq:xVarTAJ

//-------------------------------------------------------------------
/*/{Protheus.doc} J162VTPAS
Validacao do assunto Juridico
Uso Geral.

@Param cTipoPesq  Tipo da pesquisa do campo de valida��o onde '2' Follow-Up, '3' Garantias, '4' Andamentos, '5' Despesas e Custas e '6' Solic. Documentos

@author Jorge Luis Branco Martins Junior
@since 29/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162VTPAS(cTipoPesq)
Local lRet := .T.

If IsInCallStack('JURA162') .And. cTipoPesq == '3'
	If INCLUI .AND. !IsInCallStack('JA098LEV') .AND. !IsInCallStack('JURCORVLRS')
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT2_CAJURI'),'NSZ_TIPOAS') $ (JA162GetTAJ())
	ElseIf oCmbConfig <> NIL
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT2_CAJURI'),'NSZ_TIPOAS') $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
	EndIf
ElseIf IsInCallStack('JURA162') .And. cTipoPesq == '2'
	If INCLUI
		lRet := (Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NTA_CAJURI'),'NSZ_TIPOAS') $ (JA162GetTAJ())) .Or. ;
		        (Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NTA_CAJURI'),'NSZ_TIPOAS') $ (JurTpAsJr(__CUSERID)))
	ElseIf oCmbConfig <> NIL
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NTA_CAJURI'),'NSZ_TIPOAS') $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
	EndIf
ElseIf IsInCallStack('JURA162') .And. cTipoPesq == '4'
	If INCLUI
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT4_CAJURI'),'NSZ_TIPOAS') $ (JA162GetTAJ())
	ElseIf oCmbConfig <> NIL
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT4_CAJURI'),'NSZ_TIPOAS') $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
	EndIf
ElseIf IsInCallStack('JURA162') .And. cTipoPesq == '5'
	If INCLUI
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT3_CAJURI'),'NSZ_TIPOAS') $ (JA162GetTAJ())
	ElseIf oCmbConfig <> NIL
		lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('NT3_CAJURI'),'NSZ_TIPOAS') $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
	EndIf
ElseIf IsInCallStack('JURA162') .And. cTipoPesq == '6'
    If INCLUI
        lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('O0M_CAJURI'),'NSZ_TIPOAS') $ (JA162GetTAJ())
    ElseIf oCmbConfig <> NIL
        lRet := Posicione('NSZ',1,xFilial("NSZ")+FwFldGet('O0M_CAJURI'),'NSZ_TIPOAS') $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162Cas(cCliente, cLoja, cCaso)
Valida as informa��es de cliente loja e n�mero do caso
Uso no cadastro de Envolvidos.
@author Cl�vis Eduardo Teixeira
@param cCliente - C�digo do Cliente
@param cLoja - C�digo da Loja
@param cCaso - N�mero do Caso
@return lRet
@since 07/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162Cas(cCliente, cLoja, cNumCaso)
Local lRet := .T.

if SuperGetMV("MV_JCASO1",, "1") == "1"
  if Empty(cCliente) .Or. Empty(cLoja)
    JurMsgErro(STR0079)//"� necess�rio preencher os campos de Cliente e Loja para determinar se o n�mero do caso � v�lido"
    lRet := .F.
  Else
    lRet := ExistCpo('NVE',cCliente + cLoja + cNumCaso,1)
  Endif
Else
  lRet := ExistCpo('NVE',cNumCaso,3)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162F3NSZ
Customiza a consulta padr�o JURNSZ para filtrar os casos vinculados ao assunto e ao perfil selecionado
Uso na pesquisa de Follow-ups.
@Return cfilz  - filtro para tipo de assunto
@author Paulo Borges
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162F3NSZ()
Local lRet		:= .T.
Local lFilial	:= FWModeAccess("NSZ",1) == "E"
Local cPesqPai	:= ""
Local cAssJur   := ""

If Type('cTipoAJ') != 'U' .And. !Empty(cTipoAJ)

	cAssJur := cTipoAJ

	If cAssJur < '051' .And. !Ja095F3Asj()
		cPesqPai := J162PaiAJur(JA162GetTAJ())
		cAssJur := cPesqPai
	EndIf

	If lFilial //valida se a tabela est� exclusiva
		//lRet :=  NSZ->NSZ_TIPOAS == cTipoAJ .AND. NSZ->NSZ_FILIAL == cFilAnt
		lRet :=  NSZ->NSZ_TIPOAS == cAssJur .AND. NSZ->NSZ_FILIAL == cFilAnt
	Else
		//lRet :=  NSZ->NSZ_TIPOAS == cTipoAJ
		lRet :=  NSZ->NSZ_TIPOAS == cAssJur
	Endif

ElseIf Type('oCmbConfig') != 'U'
	If lFilial //valida se a tabela est� exclusiva
		lRet :=  NSZ->NSZ_TIPOAS $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor)) .AND. NSZ->NSZ_FILIAL == cFilAnt
	Else
		lRet :=  NSZ->NSZ_TIPOAS $(JurTpAsJr(__CUSERID,,oCmbConfig:cValor))
	Endif
Else
	If lFilial //valida se a tabela est� exclusiva
		lRet :=  NSZ->NSZ_TIPOAS $(JurTpAsJr(__CUSERID,,)) .AND. NSZ->NSZ_FILIAL == cFilAnt
	Else
		lRet :=  NSZ->NSZ_TIPOAS $(JurTpAsJr(__CUSERID,,))
	Endif
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162F3SU5
Customiza a consulta padr�o de advogado credenciado para verificar o
escrit�rio credenciado do assunto jur�dico
Uso no cadastro de Follow-ups.

@param 	cClient - C�d. Cliente
@Return cLoja	- C�d. Loja
@Return lRet	- .T./.F. As informa��es s�o v�lidas ou n�o
@author Cl�vis Eduardo Teixeira


@since 22/07/09
@version 1.0
/*/
//--------------------------------------------------------------------
Function JA162F3SU5()
Local lRet     := .F.
Local cQuery   := ''
Local aPesq    := {"U5_CODCONT","U5_CONTAT"}

cQuery   := JA162SU5(cCodCorr, cLojCorr)

cQuery   := ChangeQuery(cQuery, .F.)
uRetorno := ''

If JurF3Qry( cQuery, 'JURA106F3', 'SU5RECNO', @uRetorno, , aPesq,,,,,'SU5' )
  SU5->( dbGoto( uRetorno ) )
  lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162SU5
Monta a query de advogado a partir de par�metro para filtro de
Uso no cadastro de Follow-up.

@param cAssJur	    Campo de c�digo de Assunto Jur�dico
@Return cQuery	 	Query montada
@author Cl�vis Eduardo Teixeira
@since 29/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162SU5(cCorresp, cLoja)
Local cQuery   := ""

cQuery += "SELECT DISTINCT U5_CODCONT, U5_CONTAT, SU5.R_E_C_N_O_ SU5RECNO "
cQuery += " FROM "+RetSqlName("SU5")+" SU5,"+RetSqlName("SA2")+" SA2,"+RetSqlName("AC8")+" AC8"
cQuery += " WHERE U5_FILIAL = '"+xFilial("SU5")+"'"
cQuery += " AND A2_FILIAL = '"+xFilial("SA2")+"'"
cQuery += " AND AC8_FILIAL = '"+xFilial("AC8")+"'"
cQuery += " AND AC8_CODCON = U5_CODCONT"
cQuery += " AND AC8_ENTIDA = 'SA2'"
cQuery += " AND A2_COD     = SUBSTRING( AC8_CODENT, 1," + AllTrim( Str( TamSX3('A2_COD')[1] ) ) + ")"
cQuery += " AND A2_LOJA    = SUBSTRING( AC8_CODENT, 7," + AllTrim( Str( TamSX3('A2_LOJA')[1] ) ) + ")"
cQuery += " AND SU5.D_E_L_E_T_ = ' '"
cQuery += " AND SA2.D_E_L_E_T_ = ' '"
cQuery += " AND AC8.D_E_L_E_T_ = ' '"

If !Empty(cCorresp) .And. !Empty(cLoja)
  cQuery += " AND AC8.AC8_CODENT = '"+cCorresp+"'+'"+cLoja+"'"
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J162GtDscP

@Return Retorna o Descritivo do Assunto Selecionado no combo da pesquisa
@author Willian Yoshiaki Kazahaya
@since 30/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162GtDscP()
Local cDesc := Iif(Valtype(oPesq)=='U','',oPesq:aConfPesq[oPesq:oCmbConfig:nat][2])
Return cDesc

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Jura162NQC � Autor � Marcos Kato          � Data �01/03/2010���
�������������������������������������������������������������������������Ĵ��
���Locacao   � Juridico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consultachamada no SXB para filtrar localizacao 2 nivel    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function JURA162NQC()
Local lRet := .F.
Default cComarc:=""
If !Empty(cComarc)
	lRet := ( NQC->NQC_CCOMAR == cComarc )
Endif
Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Jura162NQE  � Autor � Marcos Kato         � Data �01/03/2010���
�������������������������������������������������������������������������Ĵ��
���Locacao   � Juridico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consulta chamada no SXB para filtrar localizacao 3 nivel   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function JURA162NQE(cForo)
Local lRet := .F.
Default cForo:=""

If !Empty(cForo)
	lRet := ( NQE->NQE_CLOC2N == cForo )
Endif
Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Jura162NVE  � Autor � Marcos Kato         � Data �01/03/2010���
�������������������������������������������������������������������������Ĵ��
���Locacao   � Juridico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consulta chamada no SXB para filtrar numero de caso por    ���
���          � Cliente                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function JURA162NVE()
Local cRet     := "@#@#"
Local aArea    := GetArea()
Default cClient:=""
Default cLoja  :=""
If !Empty(cClient) .And. !Empty(cLoja)
	cRet := "@#NVE->NVE_CCLIEN == '"+cClient+"' .AND. NVE->NVE_LCLIEN == '"+cLoja+"'@#"
ElseIf !Empty(cClient) .And. Empty(cLoja)
	cRet := "@#NVE->NVE_CCLIEN == '"+cClient+"'@#"
Endif

RestArea(aArea)

Return cRet

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa   �CoordX() � Autor � Marcos Kato                  � Data �08/02/2010���
��������������������������������������������������������������������������������Ĵ��
���Descricao  � Posiciona horizontal do Menu Popup                               ���
��������������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function CoordX()
Local nRet := 130
If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
	nRet := 320
EndIf
Return nRet


/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa   �CoordY() � Autor � Marcos Kato                  � Data �08/02/2010���
��������������������������������������������������������������������������������Ĵ��
���Descricao  � Posiciona vertical do Menu Popup                                 ���
��������������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function CoordY()
Local nRet := 160
If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
	nRet := 620
EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J162Active
Retorna se a tela est� ativa

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162Active()
Return lActive

//-------------------------------------------------------------------
/*/{Protheus.doc} J162CasNew()
Fun��o recursiva para localizar o ultimo caso remanejado.

@Param	cClient	C�digo do cliente do caso remanejado.
@Param	cLoja	C�digo da loja do caso remanejado.
@Param	cCaso	C�digo do caso remanejado.

@Return aCaso	Array com ultimo cliente/loja/caso remanejado

@author Luciano Pereira dos Santos
@since 01/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162CasNew(cClient, cLoja, cCaso)
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaNVE := NVE->(GetArea())
Local cMvJcas1 := SuperGetMV('MV_JCASO1',, '1') //Seq��ncia da numera��o do caso (1 - Por cliente / 2 - Independente)
Local lMvJcas3 := SuperGetMV('MV_JCASO3',, .F.) //Preserva o numero do caso origem
Local cClientN := ''
Local cLojaN   := ''
Local cCasoN   := ''
Local aCliLoja := {}
Local aCaso    := {}


If cMvJcas1 == '1' .And. !Empty(cClient) .And. !Empty(cLoja) .And. !Empty(cCaso)
	lRet := .T.
ElseIf cMvJcas1 == '2' .And. !lMvJcas3 .And. !Empty(cCaso)
	If !Empty(aCliLoja := JCasoAtual(cCaso))
		cClient := aCliLoja[1,1]
		cLoja   := aCliLoja[1,2]
		lRet := .T.
	EndIf
EndIf

If lRet

	NVE->(DbSetOrder(1)) //NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC

	If NVE->(Dbseek(xFilial('NVE') + cClient + cLoja + cCaso ) )
		cClientN := NVE->NVE_CCLINV
		cLojaN   := NVE->NVE_CLJNV
		cCasoN   := NVE->NVE_CCASNV

		If NVE->(Dbseek(xFilial('NVE') + cClientN + cLojaN + cCasoN ) )
			If !Empty(NVE->NVE_CCLINV) .and. !Empty(NVE->NVE_CLJNV) .and. !Empty(NVE->NVE_CCASNV)
				aCaso := J162CasNew(cClientN, cLojaN, cCasoN)
			Else
				aCaso := {cClientN, cLojaN, cCasoN}
			Endif

		EndIf

	EndIf
EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return aCaso

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162RstUs
Verifica as restri��es do usu�rio e pesquisa utilizada
@Return aRest	 	Array com as restri��es

@Param	oCmbConfig	Combo que cont�m as configura��es de Layout.

@author Juliana Iwayama Velho
@since 22/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162RstUs(cCodPart,cPesq,lCli,lWSTLegal)    // Parametros para verificar a restricao de grupos de clientes e correspondentes para filtro dos registros de acordo com a restricao utilizada (sendo por c�digo de cliente/fornecedor) LPS

Local aRest     := {}
Local aArea     := GetArea()
Local aAreaNWO  := NWO->( GetArea() )
Local aAreaNY2  := Nil
Local aAreaNVK  := NVK->( GetArea() )
Local aAreaSA1  := SA1->( GetArea() )
Local cGrpRest  := ""
Local lGrupo    := .F.
Local bCondicao := {|| .F.}
Local aSql      := {}
Local nI        := 0
Local cAlias    := GetNextAlias()

Default cCodPart  := __CUSERID
Default cPesq     := If(ValType(oPesq)=='U', '', oPesq:JGetPesq()) // Neces�rio a verifica��o do oPesq pois pode ser chamado pelo JURA101 (Desdobramento de Nota)
Default lCli      := .F.
Default lWSTLegal := .F. // Verifica se a chamada est� vindo do TOTVS Legal

aAreaNY2 := NY2->( GetArea() )

	If lWSTLegal

		DbSelectArea("NVK")

		//Restricao por grupo de correspondente
		cQrySelect := " SELECT NVK.NVK_COD NVK_COD "
		cQrySelect += "       ,NVK.NVK_CCORR NVK_CCORR "
		cQrySelect += "       ,NVK.NVK_CLOJA NVK_CLOJA "

		cQryFrom   := " FROM " + RetSqlName('NVK') + " NVK "

		cQryWhere := " WHERE ( NVK.NVK_CUSER = '" + cCodPart + "' "

		//Usu�rios x Grupos
		If ColumnPos("NVK_CGRUP") > 0 .And. FWAliasInDic("NZY")
			cQryWhere += " OR NVK_CGRUP IN (SELECT NZY_CGRUP"
			cQryWhere +=   " FROM " + RetSqlName("NZY") + " NZY"
			cQryWhere += " WHERE  NZY_FILIAL = '" + xFilial("NZY") + "'"
			cQryWhere += " AND NZY.NZY_CUSER  = '" + cCodPart + "'"
			cQryWhere += " AND NZY.D_E_L_E_T_ = ' ') )"
		Else
			cQryWhere += " )"
		EndIf

		cQryWhere += " AND NVK.NVK_CCORR <> '' "
		cQryWhere += " AND NVK.NVK_CLOJA <> '' "
		cQryWhere += " AND NVK.D_E_L_E_T_ = ' ' "

		// Verifica Clientes
		cQryWhere += " UNION "
		cQryWhere += " SELECT NVK.NVK_COD NVK_COD "
		cQryWhere += "       ,NWO.NWO_CCLIEN NWO_CCLIEN "
		cQryWhere += "       ,NWO.NWO_CLOJA NWO_CLOJA "
		cQryWhere += " FROM " + RetSqlName('NVK') + " NVK INNER JOIN " + RetSqlName('NWO') + " NWO ON (NVK.NVK_COD = NWO.NWO_CCONF) "
		cQryWhere += " WHERE ( NVK.NVK_CUSER = '" + cCodPart + "'"

		// Usu�rios x Grupos
		If ColumnPos("NVK_CGRUP") > 0 .And. FWAliasInDic("NZY")
			cQryWhere += " OR NVK_CGRUP IN (SELECT NZY_CGRUP"
			cQryWhere += " FROM " + RetSqlName("NZY") + " NZY"
			cQryWhere += " WHERE  NZY_FILIAL = '" + xFilial("NZY") + "'"
			cQryWhere += " AND NZY.NZY_CUSER  = '" + cCodPart + "'"
			cQryWhere += " AND NZY.D_E_L_E_T_ = ' ') )"
		Else
			cQryWhere += " )"
		EndIf
		cQryWhere += " AND NWO.D_E_L_E_T_ = ' ' "

		// Verifica Grupo de Clientes
		cQryWhere += " UNION "
		cQryWhere += " SELECT NVK.NVK_COD NVK_COD "
		cQryWhere += "        ,SA1.A1_COD A1_COD "
		cQryWhere += "        ,SA1.A1_LOJA  A1_LOJA "
		cQryWhere += " FROM " + RetSqlName('NVK') + " NVK INNER JOIN " + RetSqlName('NY2') + " NY2 ON (NVK.NVK_COD = NY2.NY2_CCONF) "
		cQryWhere +=                                    " INNER JOIN " + RetSqlName('SA1') + " SA1 ON (SA1.A1_GRPVEN = NY2.NY2_CGRUP) "
		cQryWhere += " WHERE ( NVK.NVK_CUSER = '" + cCodPart + "'"

		//Usu�rios x Grupos
		If ColumnPos("NVK_CGRUP") > 0 .And. FWAliasInDic("NZY")
			cQryWhere += " OR NVK_CGRUP IN (SELECT NZY_CGRUP"
			cQryWhere += " FROM " + RetSqlName("NZY") + " NZY"
			cQryWhere += " WHERE  NZY_FILIAL = '" + xFilial("NZY") + "'"
			cQryWhere += " AND NZY.NZY_CUSER  = '" + cCodPart + "'"
			cQryWhere += " AND NZY.D_E_L_E_T_ = ' ') )"
		Else
			cQryWhere += " )"
		EndIf
		cQryWhere += " AND NY2.D_E_L_E_T_ = ' ' "
		cQryWhere += " AND SA1.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQrySelect + cQryFrom + cQryWhere)

		cQuery := StrTran(cQuery,",' '",",''")

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		While !(cAlias)->(EOF())
			aAdd(aRest, {(cAlias)->NVK_COD,(cAlias)->NVK_CCORR,(cAlias)->NVK_CLOJA})
			(cAlias)->( dbSkip() )
		End

		(cAlias)->( dbcloseArea() )

		Return aRest
		
	Endif

If !Empty(cCodPart) .And. !Empty(cPesq)

	cGrpRest := JurGrpRest(cCodPart)  //grupo de restricao

	//Restricao por grupo de clientes
	If 'CLIENTES' $ cGrpRest

		//Retorna a condicao da restri��o
		bCondicao := ModoRest(cCodPart, cPesq)

		Do While !NVK->(EOF()) .And. Eval(bCondicao)

			If AllTrim(NVK->NVK_CPESQ) == cPesq
				// Verifica Clientes
				NWO->(DBSetOrder(1))
				If NWO->(DBSeek(xFILIAL('NVK') + NVK->NVK_COD))
					Do While !NWO->(EOF()) .And. NWO->NWO_CCONF == NVK->NVK_COD
						aAdd(aRest, {NVK->NVK_COD,NWO->NWO_CCLIEN,NWO->NWO_CLOJA} )
						NWO->(dbSkip())
					EndDo
				Endif
				// Verifica Grupo de Clientes
				NY2->(DBSetOrder(1))
				If NY2->(DBSeek(xFILIAL('NY2') + NVK->NVK_COD))
					While !NY2->(EOF()) .And. NY2->NY2_CCONF == NVK->NVK_COD
						SA1->(DBSetOrder(6))
						If SA1->(DBSeek(xFILIAL('SA1') + NY2->NY2_CGRUP))
							Do While !SA1->(EOF()) .And. SA1->A1_GRPVEN == NY2->NY2_CGRUP
								lGrupo := .T.
								aAdd(aRest, {NVK->NVK_COD, SA1->A1_COD,SA1->A1_LOJA} )
								SA1->(dbSkip())
							EndDo
						EndIf
						NY2->(dbSkip())
					EndDo

					//Caso n�o tenha encontrato nenhum cliente com este grupo, for�a para n�o retornar dados de nenhum cliente
					If !lGrupo
						aAdd(aRest, {NVK->NVK_COD, "SEMGRUPO", "XX"} )
					EndIf
				EndIf
			EndIf
			NVK->(dbSkip())
		EndDo

	//Restricao por grupo de correspondente
	ElseIf 'CORRESPONDENTES' $ cGrpRest

			//Retorna a condi��o da restri��o
			bCondicao := ModoRest(cCodPart, cPesq)

			Do While !NVK->(EOF()) .And. Eval(bCondicao)
				If AllTrim(NVK->NVK_CPESQ) == cPesq
					If !Empty(NVK->NVK_CCORR) .AND. !Empty(NVK->NVK_CLOJA)
						aAdd(aRest, {NVK->NVK_COD,NVK->NVK_CCORR,NVK->NVK_CLOJA} )
					EndIf
				EndIf
				NVK->(dbSkip())
			EndDo

			If lCli .And. Type("INCLUI") <> "U" .And. !INCLUI   //condicao para filtrar os registros referentes a restri�ao de correspondente, senao filtra restri��o de clientes  LPS //Verifica funcao inclui no model //Se nao for inclusao efetuar restricao
				aSql := JURSQL(j095CliSql(aRest),{"A1_COD","A1_LOJA"})
				aSize(aRest,0)

				For nI := 1 to len(aSQL)
					aAdd(aRest,{NVK->NVK_COD,aSQL[1][1],aSQL[1][2]})
				Next
			Endif

	EndIf
EndIf

RestArea(aAreaNWO)
RestArea(aAreaNVK)
RestArea(aAreaSA1)
RestArea(aAreaNY2)
RestArea(aArea)

Return aRest

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162AcRst
Indica se a rotina ficar� dispon�vel ou n�o a partir de configura��o
na restri��o

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@param  cRotina		C�digo da rotina
					01 - Incidentes
					02 - Vinculados
					03 - Anexos
					04 - Andamentos
					05 - Follow-ups
					06 - Valores
					07 - Garantias
					08 - Despesas
					09 - Contrato Correspondente
					10 - Contrato Faturamento
					11 - Hist�rico
					12 - Exporta��o Personalizada
					13 - Relat�rio
@param  nOpc		N�mero da opera��o
					2 - Visualizar
					3 - Incluir
					4 - Alterar
					5 - Excluir

@author Juliana Iwayama Velho
@since 02/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA162AcRst(cRotina, nOpc)
Local lRet     := .T.
Local cPesq    := ""
Local cParam   := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
Local aArea
Local aAreaNVK
Local aAreaNWP
Local bCondicao := {|| .F.}
Local lTemConce := .F.		//Define se tem a rotina Concess�es configurada na restri��o de rotinas
Local nRotinas	:= 0

Default nOpc := 2

If IsPlugin()
	If cRotina == '03'
		If cParam == '1'
			Return .F.
		EndIf
	EndIf
EndIf

If oApp:lMdi .And. IsInCallStack("GETMENUDEF")
	Return .F.
Else
	If IsInCallStack("JURA162")
		cPesq := IIF(oPesq:oCmbConfig <> NIL,oPesq:oCmbConfig:cValor,"")
	Else
		Return lRet
	EndIf
EndIf

aArea 	 := GetArea()
aAreaNVK := NVK->( GetArea() )
aAreaNWP := NWP->( GetArea() )

If !Empty(oPesq:cGrpRest) .And. !Empty(cPesq)

	//Retorna a condicao da restri��o
	bCondicao := ModoRest(oPesq:cUser, oPesq:JGetPesq())

	While !NVK->(EOF()) .And. Eval(bCondicao)
		If AllTrim(NVK->NVK_CPESQ) == oPesq:JGetPesq()
			NWP->(DBSetOrder(1))
			If NWP->(DBSeek(xFILIAL("NVK") + NVK->NVK_COD))
				While !NWP->(EOF()) .And. NWP->NWP_CCONF == NVK->NVK_COD
					If NWP->NWP_CROT == cRotina
						Do case
							Case nOpc == 2
								lRet := NWP->NWP_CVISU  == '1'
								Exit
							Case nOpc == 3
								lRet := NWP->NWP_CINCLU == '1'
								Exit
							Case nOpc == 4
								lRet := NWP->NWP_CALTER == '1'
								Exit
							Case nOpc == 5
								lRet := NWP->NWP_CEXCLU == '1'
								Exit
						End Case
					Else
						lRet := .F.
					EndIf

					NWP->(dbSkip())
				EndDo

				//Tratamento para habilitar as demais rotinas quando s� tiver Concess�es configurada nas restri��es
				If AllTrim(oPesq:cGrpRest) == "MATRIZ" .And. cRotina <> "15"

					//Verifica se tem Concess�es
					NWP->(DBSetOrder(1))
					If NWP->(DBSeek(xFILIAL("NVK") + NVK->NVK_COD + "15"))
						lTemConce := .T.
					EndIf

					If lTemConce

						//Verifica se tem mais alguma rotina alem de concess�es
						NWP->(DBSetOrder(1))
						If NWP->(DBSeek(xFILIAL("NVK") + NVK->NVK_COD))
							While !NWP->(EOF()) .And. NWP->NWP_CCONF == NVK->NVK_COD
								nRotinas := nRotinas + 1
								If nRotinas > 1
									Exit
								EndIf
								NWP->( DbSkip() )
							EndDo
						EndIf

						If nRotinas == 1
							lRet := .T.
						EndIf
					EndIf
				EndIf

			Else
				//Caso n�o tenha encontrado nenhuma rotina configurada e seja MATRIZ, libera acesso a todas rotinas
				//Exce��o, se for MATRIZ e Concess�es, deve ter a rotina de Concess�es configurada na restri��o de rotina
				If AllTrim(oPesq:cGrpRest) <> "MATRIZ" .Or. (AllTrim(oPesq:cGrpRest) == "MATRIZ" .And. cRotina == "15")
					lRet := .F.
				EndIf
			EndIf
		EndIf
		NVK->(dbSkip())
	EndDo
EndIf

RestArea(aAreaNVK)
RestArea(aAreaNWP)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J162GetPesq
Retorna se a tela est� ativa

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162GetPesq(nTipo)
Return oPesq:JGetPesq(nTipo)

//-------------------------------------------------------------------
/*/{Protheus.doc} J162PaiAJur
Fun��o que retorna o tipo de assunto jur�dico vinculado a pesquisa atual.

@Return C�digo do assunto jur�dico vinculado a pesquisa.

@author Andr� Spirigoni Pinto
@since 21/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162PaiAJur(cAssJur)
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cRet := "0"


BeginSql Alias cAliasQry
		SELECT NYB.NYB_COD, NYB.NYB_CORIG
		FROM %table:NYB% NYB
		WHERE
		NYB.NYB_FILIAL = %xFilial:NYB%
		AND NYB.%notDel%
		AND NYB.NYB_COD = %Exp:cAssJur%
EndSql

While !(cAliasQry)->( EOF())

	cRet := IIF(Empty((cAliasQry)->NYB_CORIG),(cAliasQry)->NYB_COD,(cAliasQry)->NYB_CORIG)
	(cAliasQry)->(DbSkip())

End

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetAREA
Fun��o que verifica as areas jur�dicas que o usu�rio esta
habilitado a incluir processo.
Uso Geral.

@param cCodPart   c�digo do participante
@param cPesq      c�digo da pesquisa
@param cAsJur     c�digos dos tipos de assuntos jur�dicos dos grupos

@Return cArea  Lista de Areas permitidas separadas por v�rgula (,).

@author Antonio Carlos Ferreira
@since 28/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetAREA(cCodPart,cPesq,cAsJur)

Local aArea 	:= GetArea()
Local cAliasQry	:= ''
Local cArea		:= ''
Local cQuery	:= ""

Default cCodPart 	:= __CUSERID
Default cPesq    	:= If(ValType(oPesq)=='U', '', oPesq:JGetPesq())
Default cAsJur      :=  ""

If  !( Empty(cCodPart) ) .And. (!( Empty(cPesq) ) .Or. !( Empty(cAsJur) ))

    cAliasQry	:= GetNextAlias()

	cQuery := " SELECT NYL.NYL_CAREA"
    cQuery += " FROM " + RetSqlName("NYL") + " NYL, " + RetSqlName("NVK") + " NVK, " + RetSqlName("NRB") + " NRB"
    cQuery += " WHERE NYL.NYL_CCONF = NVK.NVK_COD "
	If !Empty(cAsJur)
		cQuery += " AND ( NVK.NVK_CASJUR IN ("+cAsJur+") "
		cQuery += " OR NVK_CPESQ IN ( "
		cQuery +=                   " SELECT NVJ_CPESQ FROM "+ RetSqlName("NVJ") 
		cQuery +=                   " WHERE NVJ_CASJUR IN ("+cAsJur+") "
		cQuery +=                   " AND D_E_L_E_T_ = ' ' "
		cQuery +=                   " AND NVJ_FILIAL = '" + xFilial("NVJ") + "'"
		cQuery += " )) "
	Else
    	cQuery += 	" AND NVK.NVK_CPESQ  = '" + cPesq + "' "
	EndIf
	cQuery += 	" AND NYL.NYL_CAREA = NRB.NRB_COD "
    cQuery += 	" AND NRB.NRB_ATIVO  = '1' "
	cQuery += 	" AND NYL.NYL_FILIAL = '" + xFilial("NYL") + "'"
	cQuery += 	" AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "'"
	cQuery += 	" AND NRB.NRB_FILIAL = '" + xFilial("NRB") + "'"
	cQuery += 	" AND NYL.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NRB.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NVK.D_E_L_E_T_ = ' '"

	//Modo novo de restri��es de usuarios
	DbSelectArea("NVK")
	If ColumnPos("NVK_CGRUP") > 0

		cQuery += " AND ( NVK.NVK_CUSER = '" + cCodPart + "'"
		cQuery += 	 " OR NVK.NVK_CGRUP IN (  SELECT NZY_CGRUP"
		cQuery +=  							" FROM " + RetSqlName("NZY")
		cQuery += 							" WHERE   NZY_FILIAL = '" + xFilial("NZY") + "'"
		cQuery += 								" AND NZY_CUSER = '" + cCodPart + "'"
		cQuery += 								" AND D_E_L_E_T_ = ' ' ) )"

	//Modo antigo de restri��es de usuarios
	Else

		cQuery += " AND NVK.NVK_CUSER = '" + cCodPart + "'"
	EndIf

    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F.)

    While !(cAliasQry)->( Eof() )

	    cArea += If(Empty(cArea),"'",",'") + (cAliasQry)->NYL_CAREA + "'"

	    (cAliasQry)->( DbSkip() )
    EndDo

	(cAliasQry)->( DbcloseArea() )
EndIf

RestArea(aArea)

Return cArea

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetESC
Fun��o que verifica os escrit�rios jur�dicos que o usu�rio esta
habilitado a incluir processo.
Uso Geral.

@param cCodPart   c�digo do participante
@param cPesq      c�digo da pesquisa
@param cAsJur     c�digos dos tipos de assuntos jur�dicos dos grupos

@Return cEscritorio  Lista de Escritorios permitidos separados por v�rgula (,).

@author Antonio Carlos Ferreira
@since 27/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetESC(cCodPart,cPesq, cAsJur)

Local aArea 		:= GetArea()
Local cAliasQry		:= ''
Local cEscritorio	:= ''
Local cQuery		:= ""

Default cCodPart 	:= __CUSERID
Default cPesq    	:= If(ValType(oPesq)=='U', '', oPesq:JGetPesq())
Default cAsJur      := ""

If  !( Empty(cCodPart) ) .And. (!( Empty(cPesq) ) .Or. !( Empty(cAsJur) ))

    cAliasQry	:= GetNextAlias()

	cQuery := " SELECT NYK.NYK_CESCR"
	cQuery += " FROM " + RetSqlName("NYK") + " NYK, " + RetSqlName("NVK") + " NVK"
	cQuery += " WHERE NYK.NYK_CCONF = NVK.NVK_COD "
	If !Empty(cAsJur)
		cQuery += " AND ( NVK.NVK_CASJUR IN ("+cAsJur+") "
		cQuery += " OR NVK_CPESQ IN ( "
		cQuery +=                   " SELECT NVJ_CPESQ FROM "+ RetSqlName("NVJ") 
		cQuery +=                   " WHERE NVJ_CASJUR IN ("+cAsJur+") "
		cQuery +=                   " AND D_E_L_E_T_ = ' ' "
		cQuery +=                   " AND NVJ_FILIAL = '" + xFilial("NVJ") + "'"
		cQuery += " )) "
	Else
		cQuery += " AND NVK.NVK_CPESQ  = '" + cPesq + "' "
	EndIf
	cQuery += " AND NYK.NYK_FILIAL = '" + xFilial("NYK") + "'"
	cQuery += " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "'"
	cQuery += " AND NYK.D_E_L_E_T_ = ' '"
	cQuery += " AND NVK.D_E_L_E_T_ = ' '"

	//Modo novo de restri��es de usuarios
	DbSelectArea("NVK")
	If ColumnPos("NVK_CGRUP") > 0

		cQuery += " AND ( NVK.NVK_CUSER = '" + cCodPart + "'"
		cQuery += 	 " OR NVK.NVK_CGRUP IN (  SELECT NZY_CGRUP"
		cQuery += 							" FROM " + RetSqlName("NZY")
		cQuery += 							" WHERE   NZY_FILIAL = '" + xFilial("NZY") + "'"
		cQuery += 								" AND NZY_CUSER  = '" + cCodPart + "'"
		cQuery += 								" AND D_E_L_E_T_ = ' ' ) )"

	//Modo antigo de restri��es de usuarios
	Else

		cQuery += " AND NVK.NVK_CUSER = '" + cCodPart + "'"
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F.)

    Do While !(cAliasQry)->( EOF() )

		cEscritorio += If(Empty(cEscritorio),"'",",'") + (cAliasQry)->NYK_CESCR + "'"

		(cAliasQry)->( DbSkip() )
    EndDo

    (cAliasQry)->( DbcloseArea() )
EndIf

RestArea(aArea)

Return cEscritorio

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetTAS
Fun��o que verifica os tipo de assuntos jur�dicos que o usu�rio esta
habilitado a incluir processo e para qual tipo de assunto jur�dico
ser� inclu�do o novo processo.
Uso Geral.

@Param  oCmbConfig	Combo que cont�m as configura��es de Layout.
@param  lTela 		Boleano para mostrar tela (.T./.F.)
@param  lSepara 	Boleano para concatenar os tipos para consulta padr�o (.T./.F.)

@author Cl�vis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetTAS(lTela, lSepara, cCod)
Local aArea     := GetArea()
Local aVetor    := {}
Local cTipoAj   := '000'
Local nI        := 0
Local cQuery    := ''
Local cAliasQry := ''

Default cCod    := If(ValType(oPesq)=='U', '', oPesq:JGetPesq())
Default lTela   := .T.
Default lSepara := .T.

	If !Empty(cCod)

		cAliasQry	:= GetNextAlias()

		cQuery := "SELECT NVJ.NVJ_CASJUR, NYB.NYB_DESC"
		cQuery += " FROM " + RetSqlName("NVJ") + " NVJ, "
		cQuery += RetSqlName("NYB") + " NYB "
		cQuery += " WHERE NVJ.NVJ_CPESQ  = '" +cCod +"'"
		cQuery += " AND NVJ.NVJ_CASJUR = NYB.NYB_COD "
		cQuery += " AND NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "'"
		cQuery += " AND NYB.NYB_FILIAL = '" + xFilial("NYB") + "'"
		cQuery += " AND NVJ.D_E_L_E_T_ = ' '"
		cQuery += " AND NYB.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F.)

		While !(cAliasQry)->( EOF())

			aAdd(aVetor, {(cAliasQry)->NVJ_CASJUR , (cAliasQry)->NYB_DESC })
			(cAliasQry)->(DbSkip())

		EndDo

		(cAliasQry)->( DbcloseArea() )

	EndIf

	If Len(aVetor) == 1
		If lTela
			cTipoAj := aVetor[1][1]
		Else
			cTipoAj := "'"+aVetor[1][1]+"'"
		EndIf
	ElseIf Len(aVetor) > 1

		If lTela
			cTipoAj := oPesq:SelTipoAj(cCod)
		Else
			If lSepara
				cTipoAj := ''
				For nI := 1 to LEN(aVetor)
					cTipoAj += "'"+aVetor[nI][1]+"'"
					If nI < LEN(aVetor)
						cTipoAj += ","
					Endif
				Next
			Else
				cTipoAj := "'"
				For nI := 1 to LEN(aVetor)
					cTipoAj += aVetor[nI][1]
					If nI < LEN(aVetor)
					cTipoAj += "/"
				Endif
				Next
				cTipoAj += "'"
			EndIf

		EndIF
	
	Endif

	RestArea(aArea)

Return cTipoAj

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetPesq
Fun��o para retorna o codigo a pesquisa que esta sendo utilizada.
Uso Geral.

@author Andre Lago
@since 08/05/15
@version 1.0
/*/
//-------------------------------------------------------------------

Function JurGetPesq()
Return oPesq:JGetPesq()

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja162SQLRt
Verifica as restri��es do usu�rio e retorna o comando em SQL
@Return cSQLFim	 	Comando SQL com as restri��es

@Param	aRestricao	Array de restri��es
@Param	cCliente	Campo de cliente para restringir
@Param	cLoja  		Campo de loja do cliente para restringir
@Param	cCorresp	Campo de correspondente para restringir
@Param	cLojaCor  	Campo de loja do correspondente para restringir
@Param	cpCorresp	Campo de correspondente da processo para restringir
@Param	cpLojaCor	Campo de loja do correspondente da processo para restringir
@Param	cFwCdCorre	Campo de correspondente do follow-up para restringir
@Param	cFwLjCorre	Campo de loja do correspondente do follow-up para restringir
@Param	cTpAJ		Codigos dos tipos de assuntos juridicos

@author Juliana Iwayama Velho
@since 26/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja162SQLRt(aRestricao, cCliente, cLoja, cCorresp, cLojaCor, cpCorresp, cpLojaCor, cFwCdCorre, cFwLjCorre, cTpAJ, cCodPart, cPesq, cTabela)
Local cSQL    		:= ""
Local cSQLAux  		:= ""
Local cSQLFim 		:= ""
Local nPos    		:= 0
Local nI      		:= 0
Local nFlxCorres	:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jur�dico? (1=Follow-up ; 2=Assunto Jur�dico)"
Local cGrpRest 		:= ""

Default cCliente 	:= 'NSZ_CCLIEN'
Default cLoja    	:= 'NSZ_LCLIEN'
Default cCorresp 	:= 'NUQ_CCORRE'
Default cLojaCor	:= 'NUQ_LCORRE'
Default cpCorresp 	:= 'NSZ_CCORRE'
Default cpLojaCor 	:= 'NSZ_LCORRE'
Default cFwCdCorre	:= 'NTA_CCORRE'
Default cFwLjCorre	:= 'NTA_LCORRE'
Default cTpAJ		:= "''"
Default cCodPart 	:= __CUSERID
Default cPesq    	:= If(ValType(oPesq)=='U','', oPesq:JGetPesq())
Default cTabela		:= ""

If !Empty(aRestricao)

	cSQL :=""
	cGrpRest 		:= JurGrpRest(cCodPart)

	For nI := 1 to LEN(aRestricao)
		If 'CLIENTES' $ cGrpRest
			cSQL += " ( "+cCliente+" = '"+aRestricao[nI][2]+"' AND "+cLoja+" = '"+aRestricao[nI][3]+"' ) OR "
		ElseIf 'CORRESPONDENTES' $ cGrpRest

			//Fluxo de correspondente por Assunto Jur�dico
			If nFlxCorres == 2

				cSQL += " ("+cpCorresp+" = '"+aRestricao[nI][2]+"' AND "+cpLojaCor+" = '"+aRestricao[nI][3]+"' ) OR "

				cWhere := " AND " +cCorresp+" = '"+aRestricao[nI][2]+"' AND "+cLojaCor+" = '"+aRestricao[nI][3]+"' "

				//Filtra pela instancia atual
				If (SuperGetMV('MV_JINSATU',, '2') == '2')
					cWhere += "AND NUQ_INSATU = '1' "
				EndIf

				cExists := JurGtExist(RetSqlName("NUQ"),cWhere, "NSZ_FILIAL")
				cSQL	+= SubStr(cExists,5) + " OR "

			//Fluxo de correspondente por Follow-up
			Else

				If (cTabela == "NTA")
					cSQL += " NTA_CCORRE = '" +aRestricao[nI][2]+ "' AND NTA_LCORRE = '" +aRestricao[nI][3]+ "' OR "
				Else
					cSQLAux := " AND "+cFwCdCorre+" = '"+aRestricao[nI][2]+"' AND "+cFwLjCorre+" = '"+aRestricao[nI][3]+"' "
					cSQLAux := JurGtExist( RetSqlName("NTA"), cSQLAux )
					cSQLAux := SubStr( cSQLAux, 5, Len(cSQLAux) )
					cSQL 	+= cSQLAux + " OR "
				Endif
			EndIf

		EndIf
	Next

EndIf

nPos   := Len(AllTrim(cSQL))
cSQLFim:= SUBSTRING(cSQL,1,nPos-1)

Return cSQLFim

//-------------------------------------------------------------------
/*/{Protheus.doc} VerRestricao(cSQL)
Fun��o utilizada para obter as restri��es de escrit�rio e �rea.
Uso Geral.
@param cCodPart   c�digo do participante
@param cPesq      c�digo da pesquisa
@param cAsJur     c�digos dos tipos de assuntos jur�dicos dos grupos

@Return	cSQL   Query com as restri��es, caso haja, adicionadas.

@author Antonio Carlos Ferreira
@since 30/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function VerRestricao(cCodPart,cPesq,cAsJur)
Local cSQL       := ''
Local cRestEscr  := ''
Local cRestArea  := ''

Default cCodPart := __CUSERID
Default cPesq    := If(ValType(oPesq)=='U', '', oPesq:JGetPesq())
Default cAsJur   := ""

//Restricao de escritorio
cRestEscr := JurSetESC(cCodPart,cPesq, cAsJur)
If  !( Empty(cRestEscr) )
  cSQL += " AND NSZ_CESCRI IN (" + cRestEscr + ")" + CRLF
EndIf

//Restricao de area
cRestArea := JurSetAREA(cCodPart,cPesq, cAsJur)
If  !( Empty(cRestArea) )
	cSQL += " AND NSZ_CAREAJ IN (" + cRestArea + ")" + CRLF
EndIf

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} J162PetFlg
Rotina que emite modelo de peti��o para que seja incluido no FLUIG

@Param cRelat Nome do relat�rio
@Param aTxt Array com o Texto incluido na configura��o de relat�rio
@Param aVar Array com as Variaveis incluidas na configura��o de relat�rio
@Param nCont Numero de variaveis/texto
@Param cPath Diretorio onde o relat�rio ser� criado
@Param cCajuri Codigo do assunto juridico
@Param cNome Nome do arquivo
@Param lChkDoc  Imprime documentos (T/F)
@Param cFiliNsz  Filial da NSZ
@Param cChrTipImp Tipo de impress�o (P: PDF; W: Word)

@Return cArq  Caminho e nome do arquivo

@author Wellington Coelho
@since 04/09/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162PetFlg(cRelat, aTxt, aVar, nCont, cPath, cCajuri, cNome, lChkDoc, cFiliNsz, cChrTipImp)
Local oWord
Local oOleFormat  := ""
Local nI          := 0
Local cCliente    := ""
Local cLoja       := ""
Local cCaso       := ""
Local cFileDot    := ""
Local cTempPath   := ""
Local cFileDotTmp := ""
Local cFileName   := ""
Local cFileExt    := ".doc"

Default cPath      := GetSrvProfString("RootPath", "\undefined") +"\spool\"
Default lChkDoc    := .F.
Default cFiliNsz   := xFilial("NSZ")
Default cNome      := ""
Default cChrTipImp := "W"

cCliente := JurGetDados("NSZ",1,cFiliNsz + cCajuri, "NSZ_CCLIEN")
cLoja    := JurGetDados("NSZ",1,cFiliNsz + cCajuri, "NSZ_LCLIEN")
cCaso    := JurGetDados("NSZ",1,cFiliNsz + cCajuri, "NSZ_NUMCAS")

If cChrTipImp == "P"
	cFileExt   := ".pdf"
	oOleFormat :=  ""
EndIf

If Empty(cNome)
	cFileName := cPath + cRelat + "_" + cCliente + "_" + cLoja + "_" + cCaso + "_" + cCajuri + cFileExt
Else
	cFileName := cPath + cNome
Endif

//Altera��es para rodar em WS
if type("oMainWnd") == "U"
	Private oMainWnd
	oMainWnd := TWindow():New(0,0,0,0,"")
Endif

If !Empty(AllTrim(cFileName))
	cFileDot := SuperGetMV('MV_MODPET',, GetSrvProfString("StartPath", "\undefined")) + ALLTRIM(cRelat)

	If File( cFileDot +'.dot')
		cFileDot := cFileDot +'.dot'
	Else
		cFileDot := cFileDot +'.dotx'

		If !File( cFileDot )
			If (isBlind())
				Conout( STR0130, STR0143 ) //"Modelo de integra��o com MS-Word (.DOT / .DOTX) n�o encontrado."
			Else
				ApMsgAlert( STR0130, STR0143 ) //"Modelo de integra��o com MS-Word (.DOT / .DOTX) n�o encontrado."
			Endif
			Return NIL
		Endif
	EndIf

	// Caminho onde ficar� o arquivo gerado.(diretorio TEMP) da maquina do usuario para executar
	cTempPath := GetTempPath()

	cTempPath += IIf( Right( AllTrim( cTempPath ) , 1 ) <> '\' , '\', '' )

	cFileDotTmp := cTempPath + ExtractFile( cFileDot )

	If File( cFileDotTmp )
		If FErase( cFileDotTmp ) < 0
			If (!isBlind())
				ApMsgAlert( STR0131, STR0143 ) //"N�o foi poss�vel deletar o arquivo de modelo do MS-Word (.DOT) da pasta tempor�ria "
			Else
				Conout( STR0131, STR0143 ) //"N�o foi poss�vel deletar o arquivo de modelo do MS-Word (.DOT) da pasta tempor�ria "
			Endif
			Return NIL
		EndIf
	EndIf

	If (!isBlind())
		If !CpyS2T( cFileDot, cTempPath )
			If (!isBlind())
				ApMsgAlert( STR0132, STR0143 ) //"N�o foi poss�vel transferir para pasta tempor�ria o arquivo de modelo do MS-Word (.DOT)"
			Else
				Conout( STR0132, STR0143 ) //"N�o foi poss�vel transferir para pasta tempor�ria o arquivo de modelo do MS-Word (.DOT)"
			Endif
			Return NIL
		EndIf
	Else
		if !_copyfile(cFileDot,cFileDotTmp)
			Return NIL //Arquivo n�o existe.
		Endif
	Endif

	If oWord <> NIL
		If SubStr( Trim( oApp:cVersion ) , 1, 3 ) == 'MP8'
			OLE_CloseLink( oWord , .F. )
		Else
			OLE_CloseLink( oWord )
		EndIf
	EndIf

	oWord := OLE_CreateLink( 'TMsOleWord97',,.T. )

	//Abre o arquivo e ajusta as suas propriedades
	OLE_NewFile( oWord, cFileDotTmp )

	OLE_SetProperty( oWord, oleWdPrintBack, .T. )

	For nI := 1 to Len(aTxt)
		If cCajuri == aTxt[nI][3]
			OLE_SetDocumentVar( oWord, aTxt[nI][1], aTxt[nI][2] )
		EndIf
	Next

	For nI := 1 to Len(aVar)
		If cCajuri == aVar[nI][3]
			OLE_SetDocumentVar( oWord, aVar[nI][1], aVar[nI][2] )
		EndIf
	Next

	OLE_UpdateFields(oWord)

	if File(cFileName)
		FErase(cFileName)
	Endif

	If lChkDoc
		OLE_PrintFile( oWord, "ALL",,, 1 )
	EndIf

	// O tipo de Impress�o � a partir do valor num�rico do WdSaveFormat.
	// Os c�digos podem ser consultados no Link abaixo.
	// https://docs.microsoft.com/pt-br/office/vba/api/word.wdsaveformat
	If cChrTipImp == "P"
		OLE_SaveAsFile ( oWord, cFileName, , ,.F., 17) //PDF
	Else
		OLE_SaveAsFile ( oWord, cFileName, , ,.F., oleWdFormatDocument) //Word
	EndIf

	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )

EndIf

Return cFileName

//-------------------------------------------------------------------
/*/{Protheus.doc} J162TrtTxt
Rotina que trata texto e suas variaveis para montagem do modelo de
peti��o para FLUIG

@author Jorge Luis Branco Martins Junior
@since 30/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162TrtTxt(cTxt, nTipo)
Local cVar    := "" // VARIAVEL
Local cStrVar := "" // @#VARIAVEL#@
Local cForm   := "" // FORMULA DA VARIAVEL
Local xRetForm

Default nTipo := 0 // 0 -> Indica que se trata de tratamento de texto que cont�m variaveis.
                   // 1 -> Indica tratamento de uma vari�vel
If nTipo == 0
	While RAT("#@", cTxt) > 0
		cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
		cStrVar  := SUBSTR(cTxt,AT("@#", cTxt), (AT("#@", cTxt)+ 2)-AT("@#", cTxt) )
		cForm    := ALLTRIM(JURGETDADOS("NYN", 1, xFilial("NYN")+AllTrim(cVar), "NYN_FORM"))
		xRetForm := EVAL( &( '{|| '+cForm+ " }" ) )
		cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xRetForm) + SUBSTR(cTxt, AT("#@", cTxt)+2)
	End
Else
	cForm    := ALLTRIM(JURGETDADOS("NYN", 1, xFilial("NYN")+AllTrim(cTxt), "NYN_FORM"))
	cTxt     := ALLTRIM(EVAL( &( '{|| '+cForm+ " }" ) ))
EndIf

Return cTxt

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpPeticao( cCfgRelat, cCajuri )

Fun��o para impress�o dos modelos de peti��o em arquivo DOT, e envio para o fluig sem interven��o

Uso Geral

@Param cCajuri   Codigo do assunto juridico
@Param cCfgRelat C�digo do Relat�rio
@Param cNome     Nome do documento
@Param cFiliNsz  Filial da NSZ
@Param cPath     Caminho para a impress�o
@Param cChrTipImp Tipo de Impress�o (P-PDF; W-Word)

@Return nDocID	   Id do documento enviado para o fluig

@author Wellington Coelho
@since 04/09/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function ImpPeticao(cCfgRelat, cCajuri, cNome, cFiliNsz, cPath, cChrTipImp )
Local aArea     := GetArea()
Local aAreaNSZ  := NSZ->( GetArea() )
Local cAliasNYO := GetNextAlias()
Local cRelat    := ''
Local cTxt      := ''
Local cQuery    := ''
Local cArq      := ''
Local nI        := 0
Local aVar      := {}
Local aTxt      := {}

Default cNome      := "" //prefixo do nome do arquivo
Default cFiliNsz   := xFilial("NSZ")
Default cPath      := Nil //pasta do arquivo
Default cChrTipImp := "W"

cRelat := Alltrim(JurGetDados("NQY", 1, xFilial("NQY")+ Alltrim(cCfgRelat), "NQY_CRPT"))//Codigo do relat�rio
cRelat := Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ SubStr(cRelat,1,TAMSX3('NQY_CRPT')[1]), "NQR_NOMRPT")) //Nome do relat�rio

cQuery := " SELECT NYO_NOMVAR NOMVAR, NYO_FLAG FLAG"+ CRLF
cQuery +=     " FROM "+RetSqlName("NYO")+" NYO "+ CRLF
cQuery +=   " WHERE NYO_FILIAL = '"+xFilial("NYO")+"' " + CRLF
cQuery +=     " AND NYO.D_E_L_E_T_ = ' ' " + CRLF
cQuery +=     " AND NYO.NYO_CODCON = '" + cCfgRelat + "' " + CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNYO,.T.,.T.)

(cAliasNYO)->( dbGoTop() )

While !(cAliasNYO)->( EOF() )
	If (cAliasNYO)->FLAG == "1"
			aadd(aVar, {(Alltrim((cAliasNYO)->NOMVAR)), "", cCajuri})
		ElseIf (cAliasNYO)->FLAG == "2"
			aadd(aTxt, {(Alltrim((cAliasNYO)->NOMVAR)), "", cCajuri})
		EndIf
	(cAliasNYO)->(DbSkip())
End

If Len(aTxt) > 0
	For nI := 1 to Len(aTxt)
		cTxt := J162TrtMemo(2, "NYM", aTxt[nI][1])
		DbSelectArea("NSZ")
		NSZ->(DBSetOrder(1))
		NSZ->(dbGoTop())
		NSZ->(DBSeek(cFiliNsz + aTxt[nI][3]))
		aTxt[nI][2] := J162TrtTxt(cTxt)
	Next
EndIf

If Len(aVar) > 0
	For nI := 1 to Len(aVar)
		NSZ->(DBSetOrder(1))
		NSZ->(dbGoTop())
		NSZ->(DBSeek(cFiliNsz + aVar[nI][3]))
		aVar[nI][2] := J162TrtTxt(aVar[nI][1], 1)
	Next
EndIf

(cAliasNYO)->( dbcloseArea() )
cArq := J162PetFlg(cRelat, aTxt, aVar, nI,cPath, cCajuri, cNome,,cFiliNsz, cChrTipImp) //Chamada da fun��o de impress�o do relat�rio

RestArea(aAreaNSZ)
RestArea(aArea)

Return cArq

//-------------------------------------------------------------------
/*/{Protheus.doc} J162TrtMemo
Rotina que trata campo tipo MEMO

@author Jorge Luis Branco Martins Junior
@since 30/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162TrtMemo(nTipo, cTabela, cNome)
Local aArea     := GetArea()
Local cVlrCampo := NIL
Local cQuery    := ""
Local nRecno    := 0
Local cAlias    := GetNextAlias()

	cQuery += "SELECT R_E_C_N_O_ TABRECNO "
	cQuery += "  FROM "+ RetSqlName( cTabela ) + " " + cTabela
	cQuery += " WHERE "+cTabela+"_FILIAL = '" + xFilial( cTabela ) + "' "
	cQuery += "   AND "+cTabela+"_NOME = '" + cNome + "' "
	cQuery += "   AND "+cTabela+".D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		nRecno := (cAlias)->TABRECNO
		(cAlias)->(DbSkip())
	End

	(cAlias)->( dbcloseArea() )

	If nTipo == 2
		If  nRecno > 0
			NYM->( dbGoTo( nRecno ))
			cVlrCampo := NYM->NYM_TEXTO
		EndIf
	ElseIf nTipo == 1
		If  nRecno > 0
			NYN->( dbGoTo( nRecno ))
			cVlrCampo := NYN->NYN_FORM
		EndIf
	EndIf

	RestArea(aArea)

Return cVlrCampo


//-------------------------------------------------------------------
/*/{Protheus.doc} J201StartBG
Cria a tabela temporaria de gera��o de prt em thread.

@Param cCfgRelat - Config de relat�rio
@Param cCAJuri   - Assunto juridico
@Param cPasta    - Pasta
@Param lFluig    - Indica se � Fluig ou n�o
@Param cFilNsz   - Filial do Assunto Juridico
@Param cTipImpr  - Tipo de impress�o - P: PDF | W: Word

@author Felipe Bonvicini Conti
@since 25/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J162StartBG(cCfgRelat, cCAJuri, cPasta, lFluig, cFilNsz, cTipImpr)
Local cParams    := ""
Local cCommand   := ""
Local cFileDot   := ""
Local cDocID     := ""
Local cPath      := ""
Local cNomeDoc   := ""

Default cPasta   := ""
Default lFluig   := .T.
Default cFilNsz  := cFilAnt
Default cTipImpr := "W"

cCommand := GetPvProfString(GetEnvServer(), "SMARTCLIENTPATH", "", GetADV97())

If lFluig
	If cTipImpr == "W"
		cNomeDoc := "minuta_" + cCajuri + ".doc"
	Else
		cNomeDoc := "minuta_" + cCajuri + ".pdf"
	EndIf
Else
	If cTipImpr == "W"
		cNomeDoc := "doc_" + cCajuri +"_"+ DtoS( Date() ) + ".doc"
	Else
		cNomeDoc := "pdf_" + cCajuri +"_"+ DtoS( Date() ) + ".pdf"
	EndIf
EndIf

cParams  := cCfgRelat + "||" + ;
            __cUserID + "||" + ;
            cEmpAnt   + "||" + ;
            cFilNsz   + "||" + ;
            cCajuri   + "||" + ;
            cNomeDoc  + "||" + ;
            cTipImpr

//Se o par�metro n�o estiver definido
If Empty(cCommand)
	JurConout( I18n(STR0161, {"SMARTCLIENTPATH"}) )		//"Chave #1, n�o localizada no appserver.ini"
	Return ""
Else
	cPath	 := SubStr(cCommand,1,RAT("\",cCommand))
	cCommand := '"' + cCommand + '"'
EndIf

cParams := ' -Q -M -P=U_J162GrMin -E=' + GetEnvServer() + ' -A="' + cParams + '"' // Multiplas Instancias
JurConout(cCommand + cParams)

If WaitRunSrv( cCommand + cParams, .T., cPath )

	cFileDot := "\spool\" + cNomeDoc	//Caminho e nome do arquivo
	JurConout(cFileDot)

	If File(cFileDot)
		If lFluig
			cDocID := JDocFluig(cFileDot, cPasta)	//Chamada da fun��o de envido do documento para o fluig
		Else
			cDocID := cFileDot
		Endif
	Endif
Endif

Return cDocID

//-------------------------------------------------------------------
/*/{Protheus.doc} J162GrMin
Emiss�o de relat�rios por SmartClient secund�rio.

@Param cParams - Par�metros passados na chamada da UserFunction.

@author Andr� Spirigoni Pinto
@since 04/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
User Function J162GrMin(cParams)
Local aParam   := {}
Local cUser    := ""
Local cEmpAux  := ""
Local cFilAux  := ""
Local cNome    := ""
Local cTipImpr := "W"
Local nI       := 0

	aParam := StrToArray(cParams, "||")

	For nI := 0 To Len(aParam)
		Do Case
			Case nI == 1
				cCfgRelat := aParam[1] // Configura��o do Relat�rio
			Case nI == 2
				cUser     := aParam[2] // Usu�rio
			Case nI == 3
				cEmpAux   := aParam[3] // Empresa
			Case nI == 4
				cFilAux   := aParam[4] // Filial
			Case nI == 5
				cCajuri   := aParam[5] // Cajuri
			Case nI == 6
				cNome     := aParam[6] // Nome do Arquivo
			Case nI == 7
				cTipImpr  := aParam[7] // Tipo de Impress�o
		EndCase
	Next nI

	RpcSetType(3)
	RpcSetEnv(cEmpAux, cFilAux,,,'JURI')

	__cUserId	:= cUser

	conout(ImpPeticao(cCfgRelat, cCajuri, cNome, , , cTipImpr))

	RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModoRest
Define como ser� validado a restri��o de acesso dos usuarios.
Necessario por causa do congelamento do release.

@param	cUser	  - usuario que ira ver as restri��es
@param	cPesquisa - pesquisa que esta sendo utilizada
@return bCondicao - condi��o que ser� utilizada para validar as restri��o
@author Rafael Tenorio da Costa
@since  12/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModoRest(cUser, cPesquisa)

	Local bCondicao  := {|| .F.}
	Local aGrupos	 := {}
	Local nCont		 := 0
	Local lEncontrou := .F.

	//Modo novo de restri��es de usuarios
	DbSelectArea("NVK")
	If ColumnPos("NVK_CGRUP") > 0

		//Busca restri��es pelo usu�rio
		NVK->( DbSetOrder(2) )		//NVK_FILIAL+NVK_CUSER+NVK_CPESQ+NVK_TIPOA
		lEncontrou := NVK->( DbSeek(xFilial("NVK") + cUser + cPesquisa) )
		bCondicao  := {|| NVK->NVK_FILIAL = xFilial("NVK") .And. NVK->NVK_CUSER == cUser .And. NVK->NVK_CPESQ == cPesquisa }

		//Busca restri��es pelo grupo
		If !lEncontrou

			//Retorna grupos do usuario
 			aGrupos := J218RetGru(cUser)

			NVK->( DbSetOrder(5) )		//NVK_FILIAL+NVK_CGRUP+NVK_CPESQ+NVK_TIPOA
			For nCont:=1 To Len(aGrupos)
				If NVK->( DbSeek(xFilial("NVK") + aGrupos[nCont] + cPesquisa) )
					bCondicao  := {|| NVK->NVK_FILIAL == xFilial("NVK") .And. NVK->NVK_CGRUP == aGrupos[nCont] .And. NVK->NVK_CPESQ == cPesquisa }
					Exit
				EndIf
			Next nCont
		EndIf

	//Modo antigo de restri��es de usuarios
	Else

		NVK->(DBSetOrder(2))
		NVK->(DBSeek(xFILIAL("NVK") + cUser))
		bCondicao := {|| NVK->NVK_CUSER == cUser }
	EndIf

Return bCondicao
