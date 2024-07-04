#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "OMSXFUNC.CH"

#DEFINE NDOCEND_END    01
#DEFINE NDOCEND_BAIRRO 02
#DEFINE NDOCEND_CEP    03
#DEFINE NDOCEND_MUN    04
#DEFINE NDOCEND_EST    05
#DEFINE NDOCEND_CODIGO 06
#DEFINE NDOCEND_LOJA   07
#DEFINE NDOCEND_NREDUZ 08
#DEFINE NDOCEND_NOME   09
#DEFINE NDOCEND_CGC    10
#DEFINE NDOCEND_PESSOA 11
#DEFINE NDOCEND_PAIS   12
#DEFINE NDOCEND_TEL    13
#DEFINE NDOCEND_LENVET 13

Static lIntRot := SC6->(ColumnPos("C6_INTROT")) > 0
Static lExistDK5 := TableInDic('DK5')
Static cImagem := MaEntImage( "DAI", 1 )
Static cSeekPed := ""

/*
    Fonte que agrupa fun��es referente ao tracker de pedidos
*/

/*/{Protheus.doc} OMSTracker
Apresenta no tracker de pedidos as a��es realizadas pelo OMS, tais como:
- Pedido integrado com o Cockpit Log�stico
- Viagem gerada pelo Cockpit Log�stico
- Carga gerada
- Carga monitorada
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cNumPed, string, informa��o do n�mero do pedido e item do pedido
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Function OMSTracker(oTree,cNumPed,cTreeID,nLevel,nMaxLevel)
Default nMaxLevel := 1000000
Default cTreeID   := "000001"

    //Garante o posicionamento da SC6
    If !((SC6->C6_NUM+SC6->C6_ITEM) == cNumPed)
        SC6->(DbSetOrder(1))
        SC6->(DbSeek(xFilial("SC6")+cNumPed))
    EndIf

    //Seek da linha do pedido
    cSeekPed := Pad( "SC6-" + cNumPed, 50 )+cTreeID

    //Apresenta no tracker se pedido foi integrado com o cockpit log�stico
    OmsTrckInt(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possu� viagem gerada pelo cockpit log�stico
    OmsTrckDK0(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possu� carga gerada
    OmsTrckDAI(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possu� carga monitorada pelo cockpit log�stico
    OmsTrckMon(oTree,cTreeID,@nLevel,nMaxLevel)

Return
/*/{Protheus.doc} OmsTrckInt
Apresenta no tracker a informa��o que o pedido encontra-se integrado com o Cockpit Log�stico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Static Function OmsTrckInt(oTree,cTreeID,nLevel,nMaxLevel)
Local cTexto := ""
Local cChave := ""
    If lIntRot .And. !Empty(SC6->C6_INTROT) .And. !(SC6->C6_INTROT == "1")
        cTexto := STR0001 //Pedido / Item integrado com Cockpit Log�stico
        cChave := "OMS-CPL-" + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
    EndIf
Return
/*/{Protheus.doc} OmsTrckDK0
Apresenta no tracker a informa��o qual viagem foi gerada pelo Cockpit Log�stico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Static Function OmsTrckDK0(oTree,cTreeID,nLevel,nMaxLevel)
Local cAliasDK1 := GetNextAlias()
Local cTexto    := ""
Local cChave    := ""
    BeginSql Alias cAliasDK1
        SELECT DISTINCT DK1.DK1_REGID,
                        DK1.DK1_VIAGID
          FROM %Table:DK1% DK1
         INNER JOIN %Table:DK0% DK0
            ON DK0.DK0_FILIAL = %xFilial:DK0%
           AND DK0.DK0_REGID = DK1.DK1_REGID
           AND DK0.DK0_VIAGID = DK1.DK1_VIAGID
           AND DK0.DK0_SITINT IN ('0','1','2')
           AND DK0.%NotDel%
         WHERE DK1.DK1_FILIAL = %xFilial:DK1%
           AND DK1.DK1_FILPED = %Exp:SC6->C6_FILIAL%
           AND DK1.DK1_PEDIDO = %Exp:SC6->C6_NUM%
           AND DK1.DK1_ITEMPE = %Exp:SC6->C6_ITEM%
           AND DK1.%Notdel%
    EndSql
    While (cAliasDK1)->(!EoF())
        cTexto := STR0002+(cAliasDK1)->DK1_VIAGID //Viagem Cockpit Log�stico
        cChave := "OMS-DK1-" + (cAliasDK1)->DK1_REGID + (cAliasDK1)->DK1_VIAGID + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
        (cAliasDK1)->(DbSkip())
    EndDo
    (cAliasDK1)->(DbCloseArea())
Return
/*/{Protheus.doc} OmsTrckDAI
Apresenta no tracker a informa��o qual carga foi gerada pelo OMS.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Static Function OmsTrckDAI(oTree,cTreeID,nLevel,nMaxLevel,aTree)
Local cAliasSC9 := GetNextAlias()
Local cTexto    := ""
Local cChave    := ""
Local cItCarga  := ""
	BeginSql Alias cAliasSC9
		SELECT DISTINCT SC9.C9_CARGA, 
			            SC9.C9_SEQCAR
		  FROM %Table:SC9% SC9
		 WHERE SC9.C9_FILIAL = %xFilial:SC9%
		   AND SC9.C9_PEDIDO = %Exp:SC6->C6_NUM%
		   AND SC9.C9_ITEM = %Exp:SC6->C6_ITEM%
		   AND SC9.C9_PRODUTO = %Exp:SC6->C6_PRODUTO%
		   AND SC9.C9_CARGA <> ' '
		   AND SC9.C9_SEQCAR <> ' '
		   AND SC9.%NotDel%
	EndSql
	While (cAliasSC9)->(!Eof())
        cItCarga  := (cAliasSC9)->C9_CARGA + (cAliasSC9)->C9_SEQCAR + SC6->C6_NUM + SC6->C6_FILIAL            
        cTexto    := Pad( STR0003 + Transform( (cAliasSC9)->C9_CARGA+(cAliasSC9)->C9_SEQCAR, "@R 999999/99" ),100) // Carga / Seq.Carga
        cChave    := Pad( "OMS-DAI-" + cItCarga, 50 )+ cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
		(cAliasSC9)->( dbSkip() )
	EndDo
	(cAliasSC9)->(DbCloseArea())
Return
/*/{Protheus.doc} OmsTrckMon
Apresenta no tracker a informa��o que a carga encontra-se monitorada pelo Cockpit Log�stico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Static Function OmsTrckMon(oTree,cTreeID,nLevel,nMaxLevel)
Local cAliasQry := ""
    If lExistDK5
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT SC9.C9_CARGA,
                   SC9.C9_SEQCAR
              FROM %Table:SC9% SC9
             INNER JOIN %Table:DK5% DK5
                ON DK5.DK5_FILIAL = %xFilial:DK5%
               AND DK5.DK5_CARGA = SC9.C9_CARGA
               AND DK5.DK5_SEQCAR = SC9.C9_SEQCAR
               AND DK5.DK5_STATUS = '1'
               AND DK5.%NotDel%
             WHERE SC9.C9_FILIAL = %xFilial:SC9%
		       AND SC9.C9_PEDIDO = %Exp:SC6->C6_NUM%
		       AND SC9.C9_ITEM = %Exp:SC6->C6_ITEM%
		       AND SC9.C9_PRODUTO = %Exp:SC6->C6_PRODUTO%
		       AND SC9.C9_CARGA <> ' '
		       AND SC9.C9_SEQCAR <> ' '
		       AND SC9.%NotDel% 
        EndSql
        If (cAliasQry)->(!EoF())
            cTexto := STR0004 // Carga monitorada pelo Cockpit Log�stico
            cChave := "OMS-DK5-" + (cAliasQry)->C9_CARGA +  (cAliasQry)->C9_SEQCAR + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
            AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
        EndIf
        (cAliasQry)->(DbCloseArea())
    EndIf
Return
/*/{Protheus.doc} AddItemTree
Adiciona item � �rvore.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do n� da �rvore de apresenta��o
@param nLevel, number, n�vel atual da �rvore de apresenta��o
@param nMaxLevel, number, n�vel m�ximo suportado pela �rvore de apresenta��o
@return sem retorno
/*/
Static Function AddItemTree(oTree,cTexto,cChave,nLevel,nMaxLevel)
    nLevel++
    If nLevel <= nMaxLevel
        oTree:TreeSeek( cSeekPed )
	    oTree:AddItem( cTexto, cChave, cImagem, cImagem ,,,nLevel)
	    oTree:TreeSeek( cChave )
    EndIf
    nLevel--
Return
/*/{Protheus.doc} OmsPreView
Realiza visualiza��o do item da �rvore
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da �rvore
@return sem retorno
/*/
Function OmsPreView(cChave)
Local cTabela := Substr( cChave, 5, 3 )
    If (cTabela == "DAI" .Or. cTabela == "DK5")
        ViewCarga(cChave)
    ElseIf (cTabela == "DK1")
        ViewViagem(cChave)
    ElseIf (cTabela == "CPL")
        ViewPedido(cChave)
    EndIf
Return
/*/{Protheus.doc} ViewCarga
Realiza abertura da rotina para visualiza��o da carga
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da �rvore
@return sem retorno
/*/
Static Function ViewCarga(cChave)
Local nTamCod := TamSX3("DAK_COD")[1]
Local nTamSeq := TamSX3("DAK_SEQCAR")[1]
Local cCarga  := Substr(cChave, 9, nTamCod)
Local cSeqCar := Substr(cChave, 9+nTamCod, nTamSeq)
Local cAliasDAK := GetNextAlias()
    BeginSql Alias cAliasDAK
        SELECT R_E_C_N_O_ RECNODAK
          FROM %Table:DAK% DAK
         WHERE DAK.DAK_FILIAL = %xFilial:DAK%
           AND DAK.DAK_COD = %Exp:cCarga%
           AND DAK.DAK_SEQCAR = %Exp:cSeqCar%
           AND DAK.%NotDel%
    EndSql
    If (cAliasDAK)->(!EoF())
        If Type( "cCadastro" ) == "C"
            cCadastro := STR0006 //Montagem de Carga - Visualizar
        EndIf
        DAK->(DbGoto((cAliasDAK)->RECNODAK))
        Os200Visual("DAK",DAK->(Recno()),2)
    EndIf
    (cAliasDAK)->(DbCloseArea())
Return
/*/{Protheus.doc} ViewViagem
Realiza abertura da rotina para visualiza��o da viagem
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da �rvore
@return sem retorno
/*/
Static Function ViewViagem(cChave)
Local nTamRegId := TamSX3("DK0_REGID")[1]
Local nTamViag  := TamSX3("DK0_VIAGID")[1]
Local cRegId    := Substr(cChave, 9, nTamRegId)
Local cViagId   := Substr(cChave, 9+nTamRegId, nTamViag)
Local cAliasDK0 := GetNextAlias()
    BeginSql Alias cAliasDK0
        SELECT R_E_C_N_O_ RECNODK0
          FROM %Table:DK0% DK0
         WHERE DK0.DK0_FILIAL = %xFilial:DK0%
           AND DK0.DK0_REGID = %Exp:cRegId%
           AND DK0.DK0_VIAGID = %Exp:cViagId%
           AND DK0.%NotDel%
    EndSql
    If (cAliasDK0)->(!EoF())
        DK0->(DbGoTo((cAliasDK0)->RECNODK0))
		FWExecView(STR0005,"OMSXCPL7", MODEL_OPERATION_VIEW ,, { || .T. } ,, ) // Visualiza��o Viagem
    EndIf
    (cAliasDK0)->(DbCloseArea())
Return
/*/{Protheus.doc} ViewPedido
Realiza abertura da rotina para visualiza��o do pedido
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da �rvore
@return sem retorno
/*/
Static Function ViewPedido(cChave)
Local nTamPed   := TamSX3("C5_NUM")[1]
Local cNumPed   := Substr(cChave, 9, nTamPed)
Local cAliasSC5 := GetNextAlias()
    BeginSql Alias cAliasSC5
        SELECT R_E_C_N_O_ RECNOSC5
          FROM %Table:SC5% SC5
         WHERE SC5.C5_FILIAL = %xFilial:SC5%
           AND SC5.C5_NUM = %Exp:cNumPed%
           AND SC5.%NotDel%
    EndSql
    If (cAliasSC5)->(!EoF())
        SC5->(DbGoTo((cAliasSC5)->RECNOSC5))
        MaMakeView("SC5")
    EndIf
    (cAliasSC5)->(DbCloseArea())
Return

/*{Protheus.doc} OMSDocEnd
Busca endere�o de documento de carga
Seguindo a regra do documento.
@author Valdemar Roberto Mognon
@since 29/08/2022
*/

Function OMSDocEnd(cNumNFc,cSerNFc)
Local aAreas   := {DAI->(GetArea()),SA1->(GetArea()),GetArea()}
Local aRet     := {Array(NDOCEND_LENVET),Array(NDOCEND_LENVET)}
Local aSM0Data := {}

Default cNumNFC := ""
Default cSerNFc := ""

DAI->(DbSetOrder(3))
If DAI->(DbSeek(xFilial("DAI") + cNumNFc + cSerNFc))
	Afill(aRet[1],"")
	aRet[1,NDOCEND_PAIS] := {"BR","BRASIL"}
	Afill(aRet[2],"")
	aRet[2,NDOCEND_PAIS] := {"BR","BRASIL"}

	//-- Origem
	aSM0Data := FWSM0Util():GetSM0Data()
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + DTC->(DTC_CLIDES + DTC_LOJDES)))
		aRet[1,NDOCEND_CODIGO] := Space(Len(SA1->A1_COD))
		aRet[1,NDOCEND_LOJA]   := Space(Len(SA1->A1_LOJA))
		aRet[1,NDOCEND_NREDUZ] := aSM0Data[4,2]
		aRet[1,NDOCEND_NOME]   := aSM0Data[4,2]
		aRet[1,NDOCEND_CGC]    := aSM0Data[10,2]
		aRet[1,NDOCEND_PESSOA] := "J"
		aRet[1,NDOCEND_PAIS]   := "BRASIL"
		aRet[1,NDOCEND_END]    := aSM0Data[14,2]
		aRet[1,NDOCEND_BAIRRO] := aSM0Data[16,2]
		aRet[1,NDOCEND_CEP]    := aSM0Data[19,2]
		aRet[1,NDOCEND_MUN]    := aSM0Data[17,2]
		aRet[1,NDOCEND_EST]    := aSM0Data[18,2]
		aRet[1,NDOCEND_TEL]    := aSM0Data[6,2]
	EndIf

	//-- Destino
	If SA1->(DbSeek(xFilial("SA1") + DAI->(DAI_CLIENT + DAI_LOJA)))
		aRet[2,NDOCEND_CODIGO] := SA1->A1_COD
		aRet[2,NDOCEND_LOJA]   := SA1->A1_LOJA
		aRet[2,NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
		aRet[2,NDOCEND_NOME]   := AllTrim(SA1->A1_NOME)
		aRet[2,NDOCEND_CGC]    := AllTrim(SA1->A1_CGC)
		aRet[2,NDOCEND_PESSOA] := SA1->A1_PESSOA
		aRet[2,NDOCEND_PAIS]   := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
		aRet[2,NDOCEND_END]    := AllTrim(SA1->A1_END)
		aRet[2,NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
		aRet[2,NDOCEND_CEP]    := AllTrim(SA1->A1_CEP)
		aRet[2,NDOCEND_MUN]    := AllTrim(SA1->A1_MUN)
		aRet[2,NDOCEND_EST]    := AllTrim(SA1->A1_EST)
		aRet[2,NDOCEND_TEL]    := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet
