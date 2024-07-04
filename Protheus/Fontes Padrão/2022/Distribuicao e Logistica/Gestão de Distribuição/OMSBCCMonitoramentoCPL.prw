#include 'protheus.ch'
#include "OMSBCCMonitoramentoCPL.ch"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} OMSBCCMonitoramentoCPL
Classe com os atributos e funções correspondentes à integração da carga com o Módulo de Execução (monitoramento) do Cockpit Logístico.
@author    amanda.vieira
@since     05/09/2019
@version   1.0
/*/
class OMSBCCMonitoramentoCPL 
	DATA cXMLEnvio As Character
	DATA cMensagemErro As Character
	DATA cCarga As Character
	DATA cSeqCarga As Character
	DATA cIdViagem As Character
	DATA lSucesso As Logical

	METHOD new() 
	METHOD getXMLEnvio()
	METHOD getMensagemErro()
	METHOD getSucesso()
	METHOD setXMLEnvio()
	METHOD setCarga()
	METHOD setSeqCarga()
	METHOD setIdViagem()
	METHOD getMonitoravelId()
	METHOD postAquisicaoMonitoravel()
	METHOD montaXMLAquisicaoMonitoravel()
	METHOD montaXMLCancelamentoMonitoravel()
	METHOD deleteMonitoravel()
	METHOD gravaDK5(cStatus)
	METHOD validaEnvioCarga()
endclass

/*/{Protheus.doc} new
Metodo construtor.
@author    amanda.vieira
@since     05/09/2019
@version   1.0
/*/
METHOD new() class OMSBCCMonitoramentoCPL
	Self:cXMLEnvio := ""
return

METHOD getXMLEnvio() CLASS OMSBCCMonitoramentoCPL
Return Self:cXMLEnvio

METHOD getMensagemErro() CLASS OMSBCCMonitoramentoCPL
Return Self:cMensagemErro

METHOD getSucesso() CLASS OMSBCCMonitoramentoCPL
Return Self:lSucesso

METHOD setXMLEnvio(cXMLEnvio) CLASS OMSBCCMonitoramentoCPL
   Self:cXMLEnvio := cXMLEnvio
Return

METHOD setCarga(cCarga) CLASS OMSBCCMonitoramentoCPL
   Self:cCarga := cCarga
Return

METHOD setSeqCarga(cSeqCarga) CLASS OMSBCCMonitoramentoCPL
   Self:cSeqCarga := cSeqCarga
Return

METHOD setIdViagem(cIdViagem) CLASS OMSBCCMonitoramentoCPL
   Self:cIdViagem := cIdViagem
Return

METHOD getMonitoravelId() CLASS OMSBCCMonitoramentoCPL
Return Alltrim(OMSXGETFIL("DAK",.F.))+"-"+Self:cCarga+"-"+Self:cSeqCarga

/*/{Protheus.doc} validaEnvioCarga
Valida se a carga poderá ser integrada com para o monitoramento.
@author    amanda.vieira
@since     13/09/2019
@version   1.0
/*/
METHOD validaEnvioCarga() CLASS OMSBCCMonitoramentoCPL
Local lRet      := .T.
Local cAliasQry := ""

	Self:cMensagemErro := "" 
	
	If Empty(Self:cCarga) .Or. Empty(Self:cSeqCarga)
		Self:cMensagemErro += STR0001+CRLF //O código e/ou sequência da carga não foram informados na classe de monitamento
		Return .F.
	EndIf
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SC9.C9_CARGA
		  FROM %Table:SC9% SC9
		 WHERE SC9.C9_FILIAL =  %xFilial:SC9%
		   AND SC9.C9_CARGA = %Exp:Self:cCarga%
		   AND SC9.C9_SEQCAR = %Exp:Self:cSeqCarga%
		   AND SC9.C9_NFISCAL = ' '
		   AND SC9.D_E_L_E_T_ = ' '
	EndSql
	If (cAliasQry)->(!EoF())
		Self:cMensagemErro += STR0015+CRLF // O envio para monitoramento apenas é permitido para cargas com todos os pedidos faturados.
		Return .F.
	EndIf
	(cAliasQry)->(DbCloseArea())

	//Busca clientes da carga que encontram-se sem as informações básicas obrigatórias (país, estado, cidade e endereço)
	//Caso o cliente de entrega possua alguma informação preenchida, todas as demais deverão encontrar-se informadas(endereço entrega, estado entrega, etc.)
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DAI.DAI_COD, 
			   DAI.DAI_CLIENT,
			   DAI.DAI_LOJA,
			   SA1A.A1_ENDENT,
			   SA1A.A1_MUNE,
			   SA1A.A1_ESTE,
			   SA1A.A1_PAIS, 
			   SA1A.A1_END,
			   SA1A.A1_MUN,
			   SA1A.A1_EST
		 FROM %Table:DAI% DAI
		INNER JOIN %Table:SA1% SA1A
		   ON SA1A.A1_FILIAL = %xFilial:SA1%
		  AND SA1A.A1_COD = DAI.DAI_CLIENT
		  AND SA1A.A1_LOJA = DAI.DAI_LOJA
		  AND SA1A.%NotDel%
		WHERE DAI.DAI_FILIAL = %xFilial:DAI%
		  AND DAI.DAI_COD = %Exp:Self:cCarga%
		  AND DAI.DAI_SEQCAR = %Exp:Self:cSeqCarga%
		  AND NOT EXISTS (SELECT 1
		  				   FROM %Table:SA1% SA1B
		  				  WHERE SA1B.A1_FILIAL = %xFilial:SA1%
		  				    AND SA1B.A1_COD = DAI.DAI_CLIENT
		  				    AND SA1B.A1_LOJA = DAI.DAI_LOJA
		  				    AND ((SA1B.A1_ENDENT <> ' ' AND SA1B.A1_MUNE <> ' ' AND SA1B.A1_ESTE <> ' ' AND SA1B.A1_PAIS <> ' ') OR 
		  				         (SA1B.A1_ENDENT = ' ' AND SA1B.A1_MUNE = ' ' AND SA1B.A1_ESTE = ' ' AND SA1B.A1_END <> ' ' AND SA1B.A1_MUN <> ' ' AND SA1B.A1_EST <> ' ' AND SA1B.A1_PAIS <> ' '))
		  				    AND SA1B.%NotDel%)
		  AND DAI.%NotDel%
		GROUP BY DAI.DAI_COD, 
			     DAI.DAI_CLIENT,
			     DAI.DAI_LOJA,
			     SA1A.A1_ENDENT,
			     SA1A.A1_MUNE,
			     SA1A.A1_ESTE,
			     SA1A.A1_PAIS, 
			     SA1A.A1_END,
			     SA1A.A1_MUN,
			     SA1A.A1_EST
	EndSql
	While (cAliasQry)->(!EoF())
		lRet := .F.
		Self:cMensagemErro += OmsFmtMsg(STR0002,{{"[VAR01]",(cAliasQry)->DAI_CLIENT},{"[VAR02]",(cAliasQry)->DAI_LOJA}})+CRLF //O cliente [VAR01] loja [VAR02] encontra-se com informações obrigatórias não preenchidas:
		If Empty((cAliasQry)->A1_PAIS)
			Self:cMensagemErro += STR0003+CRLF //País não preenchido (A1_PAIS).
		EndIf
		If !Empty((cAliasQry)->(A1_ENDENT+A1_MUNE+A1_ESTE))	//Verifica endereço de entrega
			If Empty((cAliasQry)->A1_ENDENT)
				Self:cMensagemErro += STR0004+CRLF //Endereço de entrega não preenchido (A1_ENDENT).
			EndIf
			If Empty((cAliasQry)->A1_MUNE)
				Self:cMensagemErro += STR0005+CRLF //Código do município de entrega não preenchido (A1_CODMUNE).
			EndIf
			If Empty((cAliasQry)->A1_ESTE)
				Self:cMensagemErro += STR0006+CRLF //Estado de entrega não preenchido (A1_ESTE).
			EndIf
		Else
			If Empty((cAliasQry)->A1_END)
				Self:cMensagemErro += STR0007+CRLF //Endereço não preenchido (A1_END).
			EndIf
			If Empty((cAliasQry)->A1_MUN)
				Self:cMensagemErro += STR0008+CRLF //Código do município não preenchido (A1_CODMUN).
			EndIf
			If Empty((cAliasQry)->A1_EST)
				Self:cMensagemErro += STR0009+CRLF //Estado não preenchido (A1_EST).
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DK5.DK5_CARGA
		  FROM %Table:DK5% DK5
		 WHERE DK5.DK5_FILIAL = %xFilial:DK5%
		   AND DK5.DK5_CARGA = %Exp:Self:cCarga%
		   AND DK5.DK5_SEQCAR = %Exp:Self:cSeqCarga%
		   AND DK5.DK5_STATUS = '1'
		   AND DK5.%NotDel%
	EndSql
	If (cAliasQry)->(!EoF())
		lRet := .F.
		Self:cMensagemErro += STR0010+CRLF //Carga já integrada para o monitoramento.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
/*/{Protheus.doc} montaXMLAquisicaoMonitoravel
Realiza a construção do XML para comunicação com o WebService de monitoráveis do Cokcpit Logístico.
@author    amanda.vieira
@since     05/09/2019
@version   1.0
/*/
METHOD montaXMLAquisicaoMonitoravel() CLASS OMSBCCMonitoramentoCPL
Local cAliasCarga := ""
Local cAliasItens := ""
Local cAliasNotas := ""
Local cPais       := ""
Local cViagId     := ""
Local cIdInvoice  := ""
Local cLocation   := ""
Local cWhereDK1A  := ""
Local cWhereDK1B  := ""
Local cChegada    := ""
Local cSaida      := ""
Local cIniDes     := ""
Local cFimDes     := ""
Local cAliasTip   := ""
Local cHoraSai    := ""
Local cFilialSA1  := Alltrim(OMSXGETFIL("SA1",.F.))
Local cFilialDA4  := Alltrim(OMSXGETFIL("DA4",.F.))
Local cFilialDAK  := Alltrim(OMSXGETFIL("DAK",.F.))
Local cPesoCarga  := SuperGetMv("MV_PESOCAR",.F.,"L")
Local aEndEnt     := {}
Local aChildren   := {}
Local nI          := 1
Local nQtdReg     := 0
Local nSequen     := 0
Local lDAIFilPv   := DAI->( ColumnPos("DAI_FILPV" ) ) > 0
Local lIntPrd2UM  := (SuperGetMv("MV_CPLUMMT",.F.,"1") == "2") // Indica a UM do produto a ser considerada na integração com do Monitoramento junto CPL
Local nQtdePed	  := 0
Local nPesoNF	  := 0	
	
	//Limpa variável
	Self:cXMLEnvio := ""
	
	If lDAIFilPv
		cWhereDK1A := " AND DK1AUX.DK1_FILPED = DAI.DAI_FILPV "
		cWhereDK1B := " AND DK1.DK1_FILPED = DAI.DAI_FILPV "
	EndIf
	cWhereDK1A := "%"+cWhereDK1A+"%"
	cWhereDK1B := "%"+cWhereDK1B+"%"
	
	cAliasCarga := GetNextAlias()
	BeginSql Alias cAliasCarga
		SELECT DAK.DAK_COD,
			   DAK.DAK_SEQCAR,
			   DAK.DAK_PESO,
			   DAK.DAK_CAPVOL,
			   DAK.DAK_VALOR,
			   DA4.DA4_COD,
			   DA4.DA4_NOME,
			   DA4.DA4_CGC,
			   DA4.DA4_MAT,
			   DA4.DA4_NREDUZ,
			   DA3.DA3_COD,
			   DA3.DA3_DESC,
			   DA3.DA3_PLACA,
			   SA4.A4_COD,
			   SA4.A4_NOME,
			   DK0.DK0_VIAGID
		FROM %Table:DAK% DAK
		LEFT JOIN %Table:DA4% DA4
		  ON DA4.DA4_FILIAL = %xFilial:DA4%
		 AND DA4.DA4_COD = DAK.DAK_MOTORI
		 AND DA4.%NotDel%
		LEFT JOIN %Table:DA3% DA3
		  ON DA3.DA3_FILIAL = %xFilial:DA3%
		 AND DA3.DA3_COD = DAK.DAK_CAMINH
		 AND DA3.%NotDel%
		LEFT JOIN %Table:SA4% SA4
		  ON SA4.A4_FILIAL = %xFilial:SA4%
		 AND SA4.A4_COD = DAK.DAK_TRANSP
		 AND SA4.%NotDel%
		LEFT JOIN %Table:DK0% DK0
		 ON DK0.DK0_FILIAL = %xFilial:DK0%
		AND DK0.DK0_CARGA = DAK.DAK_COD
		AND DK0.DK0_VIAGID = %Exp:Self:cIdViagem%
		AND DK0.%NotDel%
	  WHERE DAK.DAK_FILIAL = %xFilial:DAK%
	    AND DAK.DAK_COD = %Exp:Self:cCarga%
	    AND DAK.DAK_SEQCAR = %Exp:Self:cSeqCarga%
	    AND DAK.%NotDel%
	EndSql
	If (cAliasCarga)->(!EoF())
		Self:cXMLEnvio += '<mon:monitorableSet>'
		//Informações do motorista
		If !Empty((cAliasCarga)->DA4_COD)
			Self:cXMLEnvio += '<mon:driver>'
			Self:cXMLEnvio += '<mon:driver>'
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",cFilialDA4+"-"+(cAliasCarga)->DA4_COD,cFilialDA4+"-"+(cAliasCarga)->DA4_COD,"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasCarga)->DA4_NOME),RTrim((cAliasCarga)->DA4_NOME),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:driver>'
			If !Empty((cAliasCarga)->DA4_CGC)
				Self:cXMLEnvio += WSSoapValue("mon:identifier",RTrim((cAliasCarga)->DA4_CGC),RTrim((cAliasCarga)->DA4_CGC),"string",   .F. , .F., 0 , NIL, .F.)
			ElseIf !Empty((cAliasCarga)->DA4_MAT)
				Self:cXMLEnvio += WSSoapValue("mon:identifier",RTrim((cAliasCarga)->DA4_MAT),RTrim((cAliasCarga)->DA4_MAT),"string",   .F. , .F., 0 , NIL, .F.)
			Else
				Self:cXMLEnvio += WSSoapValue("mon:identifier",RTrim((cAliasCarga)->DA4_COD),RTrim((cAliasCarga)->DA4_COD),"string",   .F. , .F., 0 , NIL, .F.)
			EndIf
			Self:cXMLEnvio += '</mon:driver>'
		EndIf
		//Monitoráveis
		Self:cXMLEnvio += '<mon:monitorables>'
		Self:cXMLEnvio += '<mon:monitorable>'
		cViagId := Self:getMonitoravelId()
		Self:cXMLEnvio += WSSoapValue("mon:sourceId",cViagId,cViagId,"string",   .F. , .F., 0 , NIL, .F.)
		Self:cXMLEnvio += WSSoapValue("mon:type","TRIP","TRIP","string",   .F. , .F., 0 , NIL, .F.)
		//Veículo
		If !Empty((cAliasCarga)->DA3_COD)
			Self:cXMLEnvio += '<mon:vehicle>'
			Self:cXMLEnvio += WSSoapValue("mon:vehicle",RTrim((cAliasCarga)->DA3_COD),RTrim((cAliasCarga)->DA3_COD),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasCarga)->DA3_DESC),RTrim((cAliasCarga)->DA3_DESC),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:vehicle>'
		Endif
		//Placa
		If !Empty((cAliasCarga)->DA3_PLACA)
			Self:cXMLEnvio += '<mon:truck>'
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",RTrim((cAliasCarga)->DA3_PLACA),RTrim((cAliasCarga)->DA3_PLACA),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:truck>'
		EndIf
		//Transportadora
		If !Empty((cAliasCarga)->A4_COD)
			Self:cXMLEnvio += '<mon:carrier>'
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",(cAliasCarga)->A4_COD,(cAliasCarga)->A4_COD,"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasCarga)->A4_NOME),RTrim((cAliasCarga)->A4_NOME),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:description",RTrim((cAliasCarga)->DA4_NREDUZ),RTrim((cAliasCarga)->DA4_NREDUZ),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:carrier>'
		EndIf
		//Informações gerais
		Self:cXMLEnvio += WSSoapValue("mon:value",(cAliasCarga)->DAK_VALOR,(cAliasCarga)->DAK_VALOR,"double",   .F. , .F., 0 , NIL, .F.)  //Valor do documento
		Self:cXMLEnvio += WSSoapValue("mon:volume",(cAliasCarga)->DAK_CAPVOL,(cAliasCarga)->DAK_CAPVOL,"double",   .F. , .F., 0 , NIL, .F.) //Volume do documento
		Self:cXMLEnvio += WSSoapValue("mon:weight",(cAliasCarga)->DAK_PESO,(cAliasCarga)->DAK_PESO,"double",   .F. , .F., 0 , NIL, .F.) //peso do documento
		//Verifica tipo da carga
		cAliasTip := GetNextAlias()
		BeginSql Alias cAliasTip
			SELECT DISTINCT SX5.X5_DESCRI AS DESCRI
			  FROM %Table:SF2% SF2
			 INNER JOIN %Table:SD2% SD2
			    ON SD2.D2_FILIAL = %xFilial:SD2%
			   AND SD2.D2_DOC = SF2.F2_DOC
			   AND SD2.D2_SERIE = SF2.F2_SERIE
			   AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
			   AND SD2.D2_LOJA = SF2.F2_LOJA
			   AND SD2.%NotDel%
			 INNER JOIN %Table:SB1% SB1
			    ON SB1.B1_FILIAL = %xFilial:SB1%
			   AND SB1.B1_COD = SD2.D2_COD
			   AND SB1.%NotDel%
			  LEFT JOIN %Table:DB0% DB0
			    ON DB0.DB0_FILIAL = %xFilial:DB0%
			   AND DB0.DB0_CODMOD = SB1.B1_TIPCAR
			   AND DB0.%NotDel%
			LEFT JOIN %Table:SX5% SX5
			  ON SX5.X5_FILIAL = %xFilial:SX5%
			 AND SX5.X5_TABELA = 'DU'
			 AND SX5.X5_CHAVE = DB0.DB0_TIPCAR
			 AND SX5.%NotDel%
		   WHERE SF2.F2_FILIAL = %xFilial:SF2%
			 AND SF2.F2_CARGA = %Exp:Self:cCarga%
			 AND SF2.F2_SEQCAR = %Exp:Self:cSeqCarga%
			 AND SF2.%NotDel%
		EndSql
		If (cAliasTip)->(!EoF())
			(cAliasTip)->(DBEval({ || nQtdReg++}))
			(cAliasTip)->(DbGoTop())
			If nQtdReg == 1
				If Alltrim((cAliasTip)->DESCRI) == "CONGELADA"
					Self:cXMLEnvio += WSSoapValue("mon:temperatureType","Congelada","Congelada","string",   .F. , .F., 0 , NIL, .F.)
				ElseIf Alltrim((cAliasTip)->DESCRI) == "RESFRIADA"
					Self:cXMLEnvio += WSSoapValue("mon:temperatureType","Resfriada","Resfriada","string",   .F. , .F., 0 , NIL, .F.)
				Else
					Self:cXMLEnvio += WSSoapValue("mon:temperatureType","Default","Default","string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			Else
				Self:cXMLEnvio += WSSoapValue("mon:temperatureType","Default","Default","string",   .F. , .F., 0 , NIL, .F.)
			EndIf 
		Endif
		(cAliasTip)->(DbCloseArea())
		Self:cXMLEnvio += '<mon:transitions>'
		cAliasItens := GetNextAlias()
		BeginSql Alias cAliasItens
			SELECT SUM(DAI.DAI_PESO) DAI_PESO,
				   SUM(DAI.DAI_CAPVOL) DAI_CAPVOL,
				   DAI.DAI_DTSAID,
				   DAI.DAI_HRSAID,
				   DAI.DAI_DTCHEG,
				   DAI.DAI_CHEGAD,
				   SA1.A1_COD,
				   SA1.A1_LOJA,
				   SA1.A1_NOME,
				   SA1.A1_END,
				   SA1.A1_BAIRRO,
				   SA1.A1_EST,
				   SA1.A1_CEP,
				   SA1.A1_NREDUZ,
				   SA1.A1_PAIS,
				   SA1.A1_MUN,
				   SA1.A1_ENDENT,
				   SA1.A1_CEPE,
				   SA1.A1_BAIRROE,
				   SA1.A1_MUNE,
				   SA1.A1_ESTE,
				   CC2A.CC2_MUN CC2_MUN,
				   CC2B.CC2_MUN CC2_MUNE,
				   DK1AUX.DK1_CHEGAD,
				   DK1AUX.DK1_TSAIDA,
				   DK1AUX.DK1_INIDES,
				   DK1AUX.DK1_FIMDES
			  FROM %Table:DAI% DAI
			 INNER JOIN %Table:SA1% SA1
			    ON SA1.A1_FILIAL = %xFilial:SA1%
			   AND SA1.A1_COD = DAI.DAI_CLIENT
			   AND SA1.A1_LOJA = DAI.DAI_LOJA
			   AND SA1.%NotDel%
			  LEFT JOIN %Table:CC2% CC2A
			    ON CC2A.CC2_FILIAL = %xFilial:CC2%
			   AND CC2A.CC2_EST = SA1.A1_EST 
			   AND CC2A.CC2_CODMUN = SA1.A1_CODMUN
			   AND CC2A.%NotDel%
			  LEFT JOIN %Table:CC2% CC2B
			    ON CC2B.CC2_FILIAL = %xFilial:CC2%
			   AND CC2B.CC2_EST = SA1.A1_ESTE
			   AND CC2B.CC2_CODMUN = SA1.A1_CODMUNE
			   AND CC2B.%NotDel%
			   LEFT JOIN (	SELECT DK1.DK1_CHEGAD,
			   					   DK1.DK1_TSAIDA,
			   					   DK1.DK1_INIDES,
			   					   DK1.DK1_FIMDES,
			   					   DK1.DK1_PEDIDO,
			   					   DK1.DK1_FILPED,
			   					   DK0.DK0_CARGA
			   			      FROM %Table:DK0% DK0
			   			     INNER JOIN %Table:DK1% DK1
			   			        ON DK1.DK1_FILIAL = %xFilial:DK1%
			   			       AND DK1.DK1_REGID = DK0.DK0_REGID
			   			       AND DK1.DK1_VIAGID = DK0.DK0_VIAGID 
			   			       AND DK1.%NotDel%
			   			     WHERE DK0.DK0_FILIAL = %xFilial:DK0%
			   			       AND DK0.DK0_CARGA = %Exp:Self:cCarga%
							   AND DK0.DK0_VIAGID = %Exp:Self:cIdViagem%
			   			       AND DK0.%NotDel%
			   			     GROUP BY DK1.DK1_CHEGAD,
			   			     		  DK1.DK1_TSAIDA,
			   			     		  DK1.DK1_INIDES,
			   			     		  DK1.DK1_FIMDES,
			   			     		  DK1.DK1_PEDIDO,
			   			     		  DK1.DK1_FILPED,
			   			     		  DK0.DK0_CARGA) DK1AUX
				 ON DK1AUX.DK1_PEDIDO = DAI.DAI_PEDIDO
				AND DK1AUX.DK0_CARGA = DAI.DAI_COD
				%Exp:cWhereDK1A%
			  WHERE DAI.DAI_FILIAL = %xFilial:DAI%
			    AND DAI.DAI_COD = %Exp:Self:cCarga%
			    AND DAI.DAI_SEQCAR = %Exp:Self:cSeqCarga%
			    AND DAI.%NotDel%
			  GROUP BY DAI.DAI_DTSAID,
			  		   DAI.DAI_HRSAID,
			  		   DAI.DAI_DTCHEG,
			  		   DAI.DAI_CHEGAD,
			  		   SA1.A1_COD,
			  		   SA1.A1_LOJA,
			  		   SA1.A1_NOME,
			  		   SA1.A1_END,
			  		   SA1.A1_BAIRRO,
			  		   SA1.A1_EST,
			  		   SA1.A1_CEP,
			  		   SA1.A1_NREDUZ,
			  		   SA1.A1_PAIS,
			  		   SA1.A1_MUN,
			  		   SA1.A1_ENDENT,
			  		   SA1.A1_CEPE,
			  		   SA1.A1_BAIRROE,
			  		   SA1.A1_MUNE,
			  		   SA1.A1_ESTE,
			  		   CC2A.CC2_MUN,
			  		   CC2B.CC2_MUN,
			  		   DK1AUX.DK1_CHEGAD,
			  		   DK1AUX.DK1_TSAIDA,
			  		   DK1AUX.DK1_INIDES,
			  		   DK1AUX.DK1_FIMDES
		EndSql
		While (cAliasItens)->(!EoF())
			//Localização do Ponto de Parada
			cLocation := '<mon:location>'
			cLocation += '<mon:locality>'
			cLocation += WSSoapValue("mon:sourceId",cFilialSA1+"-"+(cAliasItens)->A1_COD+"-"+(cAliasItens)->A1_LOJA,cFilialSA1+"-"+(cAliasItens)->A1_COD+"-"+(cAliasItens)->A1_LOJA,"string",   .F. , .F., 0 , NIL, .F.)
			cLocation += WSSoapValue("mon:name",RTrim((cAliasItens)->A1_NOME),RTrim((cAliasItens)->A1_NOME),"string",   .F. , .F., 0 , NIL, .F.)
			cLocation += WSSoapValue("mon:description",RTrim((cAliasItens)->A1_NREDUZ),RTrim((cAliasItens)->A1_NREDUZ),"string",   .F. , .F., 0 , NIL, .F.)
			cLocation += '</mon:locality>'
			//Endereço
			cLocation += '<mon:address>'
			IF !Empty((cAliasItens)->A1_ENDENT)
				aEndEnt := LjFiGetEnd((cAliasItens)->A1_ENDENT, (cAliasItens)->A1_ESTE, .T.)
				If !Empty(aEndEnt[1])
					cLocation += WSSoapValue("mon:street",StrTrim(aEndEnt[1],200),StrTrim(aEndEnt[1],200),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty(aEndEnt[3])
					cLocation += WSSoapValue("mon:number",StrTrim(aEndEnt[3],30),StrTrim(aEndEnt[3],30),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->A1_BAIRROE)
					cLocation += WSSoapValue("mon:district",RTrim((cAliasItens)->A1_BAIRROE),RTrim((cAliasItens)->A1_BAIRROE),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->CC2_MUNE)
					cLocation += WSSoapValue("mon:city",RTrim((cAliasItens)->CC2_MUNE),RTrim((cAliasItens)->CC2_MUNE),"string",   .F. , .F., 0 , NIL, .F.)
				ElseIf !Empty((cAliasItens)->A1_MUNE)
					cLocation += WSSoapValue("mon:city",RTrim((cAliasItens)->A1_MUNE),RTrim((cAliasItens)->A1_MUNE),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->A1_ESTE)
					cLocation += WSSoapValue("mon:state",(cAliasItens)->A1_ESTE,(cAliasItens)->A1_ESTE,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If Empty((cAliasItens)->A1_CEPE)
					cLocation += WSSoapValue("mon:zipCode",(cAliasItens)->A1_CEPE,(cAliasItens)->A1_CEPE,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			Else
				aEndEnt := LjFiGetEnd((cAliasItens)->A1_END, (cAliasItens)->A1_EST, .T.)
				If !Empty(aEndEnt[1])
					cLocation += WSSoapValue("mon:street",StrTrim(aEndEnt[1],200),StrTrim(aEndEnt[1],200),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty(aEndEnt[3])
					cLocation += WSSoapValue("mon:number",StrTrim(aEndEnt[3],30),StrTrim(aEndEnt[3],30),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->A1_BAIRRO)
					cLocation += WSSoapValue("mon:district",RTrim((cAliasItens)->A1_BAIRRO),RTrim((cAliasItens)->A1_BAIRRO),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->CC2_MUN)
					cLocation += WSSoapValue("mon:city",RTrim((cAliasItens)->CC2_MUN),RTrim((cAliasItens)->CC2_MUN),"string",   .F. , .F., 0 , NIL, .F.)
				ElseIf !Empty((cAliasItens)->A1_MUN)
					cLocation += WSSoapValue("mon:city",RTrim((cAliasItens)->A1_MUN),RTrim((cAliasItens)->A1_MUN),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->A1_EST)
					cLocation += WSSoapValue("mon:state",(cAliasItens)->A1_EST,(cAliasItens)->A1_EST,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasItens)->A1_CEP)
					cLocation += WSSoapValue("mon:zipCode",(cAliasItens)->A1_CEP,(cAliasItens)->A1_CEP,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			EndIf
			If Empty((cAliasItens)->A1_PAIS) .Or. (cAliasItens)->A1_PAIS == '105'
				cLocation += WSSoapValue("mon:country","BR","BR","string",   .F. , .F., 0 , NIL, .F.)
			Else			
				cPais := StrTrim(Posicione('SYA',1,xFilial('SYA')+(cAliasItens)->A1_PAIS,'YA_SIGLA'),2)
				If !Empty(cPais)
					cLocation += WSSoapValue("mon:country",cPais,cPais,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			EndIf
			cLocation += '</mon:address>'
			cLocation += '</mon:location>'
			//---Transição de Chegada no Cliente
			cHoraSai := Iif(Empty((cAliasItens)->DAI_HRSAID), AtSomaHora((cAliasItens)->DAI_CHEGAD,0.5), (cAliasItens)->DAI_HRSAID)
			cChegada := Iif(!Empty((cAliasItens)->DK1_CHEGAD),(cAliasItens)->DK1_CHEGAD,FWTimeStamp(5,StoD((cAliasItens)->DAI_DTCHEG),(cAliasItens)->DAI_CHEGAD+":00.000"))
			cSaida   := Iif(!Empty((cAliasItens)->DK1_TSAIDA),(cAliasItens)->DK1_TSAIDA,FWTimeStamp(5,StoD((cAliasItens)->DAI_DTSAID),cHoraSai+":00.000"))
			cIniDes  := Iif(!Empty((cAliasItens)->DK1_INIDES),(cAliasItens)->DK1_INIDES,"")
			cFimDes  := Iif(!Empty((cAliasItens)->DK1_FIMDES),(cAliasItens)->DK1_FIMDES,"")
			nSequen += 1
			Self:cXMLEnvio += '<mon:transition>'
			Self:cXMLEnvio += WSSoapValue("mon:name",STR0011,STR0011,"string",   .F. , .F., 0 , NIL, .F.) //Chegada no Cliente
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",StrZero(nSequen,3),StrZero(nSequen,3),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:expectedTimestamp",cChegada,cChegada,"dateTime",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:limitTimestamp",cChegada,cChegada,"dateTime",   .F. , .F., 0 , NIL, .F.)
			//Localidade
			Self:cXMLEnvio += cLocation
			Self:cXMLEnvio += '</mon:transition>'
			//---Transição de Início do Descarregamento
			If !Empty(cIniDes)
				nSequen += 1
				Self:cXMLEnvio += '<mon:transition>'
				Self:cXMLEnvio += WSSoapValue("mon:name",STR0012,STR0012,"string",   .F. , .F., 0 , NIL, .F.) //Início Descarregamento
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",StrZero(nSequen,3),StrZero(nSequen,3),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:expectedTimestamp",cIniDes,cIniDes,"dateTime",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:limitTimestamp",cIniDes,cIniDes,"dateTime",   .F. , .F., 0 , NIL, .F.)
				//Localidade
				Self:cXMLEnvio += cLocation
				Self:cXMLEnvio += '</mon:transition>'
			EndIf
			//---Transição de Fim do Descarregamento
			If !Empty(cFimDes)
				nSequen += 1
				Self:cXMLEnvio += '<mon:transition>'
				Self:cXMLEnvio += WSSoapValue("mon:name",STR0013,STR0013,"string",   .F. , .F., 0 , NIL, .F.) //Fim Descarregamento
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",StrZero(nSequen,3),StrZero(nSequen,3),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:expectedTimestamp",cFimDes,cFimDes,"dateTime",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:limitTimestamp",cFimDes,cFimDes,"dateTime",   .F. , .F., 0 , NIL, .F.)
				//Localidade
				Self:cXMLEnvio += cLocation
				Self:cXMLEnvio += '</mon:transition>'
			EndIf
			//---Transição de Saída do Cliente
			nSequen += 1
			Self:cXMLEnvio += '<mon:transition>'
			Self:cXMLEnvio += WSSoapValue("mon:name",STR0014,STR0014,"string",   .F. , .F., 0 , NIL, .F.) //Saída do Cliente
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",StrZero(nSequen,3),StrZero(nSequen,3),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:expectedTimestamp",cSaida,cSaida,"dateTime",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:limitTimestamp",cSaida,cSaida,"dateTime",   .F. , .F., 0 , NIL, .F.)
			//Localidade
			Self:cXMLEnvio += cLocation
			Self:cXMLEnvio += '</mon:transition>'
			(cAliasItens)->(DbSkip())
		EndDo
		(cAliasItens)->(DbCloseArea())
		Self:cXMLEnvio += '</mon:transitions>'
		Self:cXMLEnvio += '</mon:monitorable>'
		
		//Monitoráveis do tipo INVOICE
		cAliasNotas := GetNextAlias()
		BeginSql Alias cAliasNotas
			SELECT SF2.F2_DOC,
				   SF2.F2_SERIE,
				   SF2.F2_PLIQUI,
				   SF2.F2_PBRUTO,
				   SF2.F2_VALFAT,
				   SF2.F2_CLIENT,
				   SF2.F2_LOJENT,
				   SA1.A1_COD,
				   SA1.A1_LOJA,
				   SA1.A1_NOME,
				   SA1.A1_END,
				   SA1.A1_BAIRRO,
				   SA1.A1_EST,
				   SA1.A1_CEP,
				   SA1.A1_MUN,
				   SA1.A1_NREDUZ,
				   SA1.A1_PAIS,
				   SA1.A1_ENDENT,
				   SA1.A1_CEPE,
				   SA1.A1_BAIRROE,
				   SA1.A1_MUNE,
				   SA1.A1_ESTE,
				   CC2A.CC2_MUN CC2_MUN,
				   CC2B.CC2_MUN CC2_MUNE,
				   DAI.DAI_DTCHEG,
				   DAI.DAI_CHEGAD,
				   DK1.DK1_CHEGAD,
				   DK1.DK1_TSAIDA,
				   DK1.DK1_INIDES,
				   DK1.DK1_FIMDES
			  FROM %Table:SF2% SF2
			 INNER JOIN %Table:SA1% SA1
			    ON SA1.A1_FILIAL = %xFilial:SA1%
			   AND SA1.A1_COD = SF2.F2_CLIENT
			   AND SA1.A1_LOJA = SF2.F2_LOJENT
			   AND SA1.%NotDel%
			 INNER JOIN %Table:DAI% DAI
			 	ON DAI.DAI_FILIAL = %xFilial:DAI%
			   AND DAI.DAI_COD = SF2.F2_CARGA
			   AND DAI.DAI_SEQCAR = SF2.F2_SEQCAR
			   AND DAI.DAI_CLIENT = SF2.F2_CLIENT
			   AND DAI.DAI_LOJA = SF2.F2_LOJENT
			   AND DAI.%NotDel%
			  LEFT JOIN %Table:CC2% CC2A
			  	ON CC2A.CC2_FILIAL = %xFilial:CC2%
			   AND CC2A.CC2_EST = SA1.A1_EST 
			   AND CC2A.CC2_CODMUN = SA1.A1_CODMUN
			   AND CC2A.%NotDel%
			  LEFT JOIN %Table:CC2% CC2B
			  	ON CC2B.CC2_FILIAL = %xFilial:CC2%
			   AND CC2B.CC2_EST = SA1.A1_ESTE
			   AND CC2B.CC2_CODMUN = SA1.A1_CODMUNE
			   AND CC2B.%NotDel%
			  LEFT JOIN %Table:DK0% DK0
			    ON DK0.DK0_FILIAL = %xFilial:DK0%
			   AND DK0.DK0_CARGA = DAI.DAI_COD
			   AND DK0.DK0_VIAGID = %Exp:Self:cIdViagem% 
			   AND DK0.%NotDel%
			  LEFT JOIN %Table:DK1% DK1
			    ON DK1.DK1_FILIAL = %xFilial:DK1%
			   AND DK1.DK1_REGID  = DK0.DK0_REGID
			   AND DK1.DK1_VIAGID = DK0.DK0_VIAGID
			   AND DK1.DK1_PEDIDO = DAI.DAI_PEDIDO
			   AND DK1.%NotDel%
			   %Exp:cWhereDK1B%
			  WHERE SF2.F2_FILIAL = %xFilial:SF2%
			    AND SF2.F2_CARGA = %Exp:Self:cCarga%
			    AND SF2.F2_SEQCAR = %Exp:Self:cSeqCarga%
			    AND SF2.%NotDel%
			  GROUP BY SF2.F2_DOC,
			           SF2.F2_SERIE,
			           SF2.F2_PLIQUI,
			           SF2.F2_PBRUTO,
			           SF2.F2_VALFAT,
			           SF2.F2_CLIENT,
			           SF2.F2_LOJENT,
			           SA1.A1_COD,
			           SA1.A1_LOJA,
			           SA1.A1_NOME,
			           SA1.A1_END,
			           SA1.A1_BAIRRO,
			           SA1.A1_EST,
			           SA1.A1_CEP,
			           SA1.A1_MUN,
			           SA1.A1_NREDUZ,
			           SA1.A1_PAIS,
			           SA1.A1_ENDENT,
			           SA1.A1_CEPE,
			           SA1.A1_BAIRROE,
			           SA1.A1_MUNE,
			           SA1.A1_ESTE,
			           CC2A.CC2_MUN,
			           CC2B.CC2_MUN,
			           DAI.DAI_DTCHEG,
			           DAI.DAI_CHEGAD,
			           DAI.DAI_DTSAID,
			           DK1.DK1_CHEGAD,
			           DK1.DK1_TSAIDA,
			           DK1.DK1_INIDES,
			           DK1.DK1_FIMDES
			  ORDER BY SF2.F2_DOC,
			           SF2.F2_SERIE
		EndSql
		While (cAliasNotas)->(!EoF())
			//Monitorável
			cIdInvoice := Alltrim((cAliasNotas)->F2_DOC)+"-"+Alltrim((cAliasNotas)->F2_SERIE)
			aAdd(aChildren,cIdInvoice)
			Self:cXMLEnvio += '<mon:monitorable>'
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",cIdInvoice,cIdInvoice,"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:type","INVOICE","INVOICE","string",   .F. , .F., 0 , NIL, .F.)
			//Veículo
			If !Empty((cAliasCarga)->DA3_COD)
				Self:cXMLEnvio += '<mon:vehicle>'
				Self:cXMLEnvio += WSSoapValue("mon:vehicle",RTrim((cAliasCarga)->DA3_COD),RTrim((cAliasCarga)->DA3_COD),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasCarga)->DA3_DESC),RTrim((cAliasCarga)->DA3_DESC),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:vehicle>'
			Endif
			//Placa
			If !Empty((cAliasCarga)->DA3_PLACA)
				Self:cXMLEnvio += '<mon:truck>'
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",RTrim((cAliasCarga)->DA3_PLACA),RTrim((cAliasCarga)->DA3_PLACA),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:truck>'
			EndIf
			//Transportadora
			If !Empty((cAliasCarga)->A4_COD)
				Self:cXMLEnvio += '<mon:carrier>'
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",(cAliasCarga)->A4_COD,(cAliasCarga)->A4_COD,"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasCarga)->A4_NOME),RTrim((cAliasCarga)->A4_NOME),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:description",RTrim((cAliasCarga)->DA4_NREDUZ),RTrim((cAliasCarga)->DA4_NREDUZ),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:carrier>'
			EndIf
			//Informações gerais
			Self:cXMLEnvio += WSSoapValue("mon:value",(cAliasNotas)->F2_VALFAT,(cAliasNotas)->F2_VALFAT,"double",   .F. , .F., 0 , NIL, .F.)  //Valor do documento
			If cPesoCarga == "L"
				Self:cXMLEnvio += WSSoapValue("mon:weight",(cAliasNotas)->F2_PLIQUI,(cAliasNotas)->F2_PLIQUI,"double",   .F. , .F., 0 , NIL, .F.) //peso do documento
			Else
				Self:cXMLEnvio += WSSoapValue("mon:weight",(cAliasNotas)->F2_PBRUTO,(cAliasNotas)->F2_PBRUTO,"double",   .F. , .F., 0 , NIL, .F.) //peso do documento
			EndIf
			//Transições
			Self:cXMLEnvio += '<mon:transitions>'
			Self:cXMLEnvio += '<mon:transition>'
			Self:cXMLEnvio += WSSoapValue("mon:name",STR0011,STR0011,"string",   .F. , .F., 0 , NIL, .F.) //Chegada no Cliente
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",cIdInvoice+"-"+"001",cIdInvoice+"-"+"001","string",   .F. , .F., 0 , NIL, .F.)
			cChegada := Iif(!Empty((cAliasNotas)->DK1_CHEGAD),(cAliasNotas)->DK1_CHEGAD,FWTimeStamp(5,StoD((cAliasNotas)->DAI_DTCHEG),(cAliasNotas)->DAI_CHEGAD+":00.000")) 
			Self:cXMLEnvio += WSSoapValue("mon:expectedTimestamp",cChegada,cChegada,"dateTime",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:limitTimestamp",cChegada,cChegada,"dateTime",   .F. , .F., 0 , NIL, .F.)
			//Localidade
			Self:cXMLEnvio += '<mon:location>'
			Self:cXMLEnvio += '<mon:locality>'
			Self:cXMLEnvio += WSSoapValue("mon:sourceId",cFilialSA1+"-"+(cAliasNotas)->A1_COD+"-"+(cAliasNotas)->A1_LOJA,cFilialSA1+"-"+(cAliasNotas)->A1_COD+"-"+(cAliasNotas)->A1_LOJA,"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasNotas)->A1_NOME),RTrim((cAliasNotas)->A1_NOME),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:description",RTrim((cAliasNotas)->A1_NREDUZ),RTrim((cAliasNotas)->A1_NREDUZ),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:locality>'
			//Endereço
			Self:cXMLEnvio += '<mon:address>'
			IF !Empty((cAliasNotas)->A1_ENDENT)
				aEndEnt := LjFiGetEnd((cAliasNotas)->A1_ENDENT, (cAliasNotas)->A1_ESTE, .T.)
				If !Empty(aEndEnt[1])
					Self:cXMLEnvio += WSSoapValue("mon:street",StrTrim(aEndEnt[1],200),StrTrim(aEndEnt[1],200),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty(aEndEnt[3])
					Self:cXMLEnvio += WSSoapValue("mon:number",StrTrim(aEndEnt[3],30),StrTrim(aEndEnt[3],30),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_BAIRROE)
					Self:cXMLEnvio += WSSoapValue("mon:district",RTrim((cAliasNotas)->A1_BAIRROE),RTrim((cAliasNotas)->A1_BAIRROE),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->CC2_MUNE)
					Self:cXMLEnvio += WSSoapValue("mon:city",RTrim((cAliasNotas)->CC2_MUNE),RTrim((cAliasNotas)->CC2_MUNE),"string",   .F. , .F., 0 , NIL, .F.)
				ElseIf !Empty((cAliasNotas)->A1_MUNE)
					Self:cXMLEnvio += WSSoapValue("mon:city",RTrim((cAliasNotas)->A1_MUNE),RTrim((cAliasNotas)->A1_MUNE),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_ESTE)
					Self:cXMLEnvio += WSSoapValue("mon:state",(cAliasNotas)->A1_ESTE,(cAliasNotas)->A1_ESTE,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_CEPE)
					Self:cXMLEnvio += WSSoapValue("mon:zipCode",(cAliasNotas)->A1_CEPE,(cAliasNotas)->A1_CEPE,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			Else
				aEndEnt := LjFiGetEnd((cAliasNotas)->A1_END, (cAliasNotas)->A1_EST, .T.)
				If !Empty(aEndEnt[1])
					Self:cXMLEnvio += WSSoapValue("mon:street",StrTrim(aEndEnt[1],200),StrTrim(aEndEnt[1],200),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty(aEndEnt[3])
					Self:cXMLEnvio += WSSoapValue("mon:number",StrTrim(aEndEnt[3],30),StrTrim(aEndEnt[3],30),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_BAIRRO)
					Self:cXMLEnvio += WSSoapValue("mon:district",RTrim((cAliasNotas)->A1_BAIRRO),RTrim((cAliasNotas)->A1_BAIRRO),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->CC2_MUN)
					Self:cXMLEnvio += WSSoapValue("mon:city",RTrim((cAliasNotas)->CC2_MUN),RTrim((cAliasNotas)->CC2_MUN),"string",   .F. , .F., 0 , NIL, .F.)
				ElseIf !Empty((cAliasNotas)->A1_MUN)
					Self:cXMLEnvio += WSSoapValue("mon:city",RTrim((cAliasNotas)->A1_MUN),RTrim((cAliasNotas)->A1_MUN),"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_EST)
					Self:cXMLEnvio += WSSoapValue("mon:state",(cAliasNotas)->A1_EST,(cAliasNotas)->A1_EST,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
				If !Empty((cAliasNotas)->A1_CEP)
					Self:cXMLEnvio += WSSoapValue("mon:zipCode",(cAliasNotas)->A1_CEP,(cAliasNotas)->A1_CEP,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			EndIf
			If Empty((cAliasNotas)->A1_PAIS) .Or. (cAliasNotas)->A1_PAIS == '105'
				Self:cXMLEnvio += WSSoapValue("mon:country","BR","BR","string",   .F. , .F., 0 , NIL, .F.)
			Else
				cPais := StrTrim(Posicione('SYA',1,xFilial('SYA')+(cAliasNotas)->A1_PAIS,'YA_SIGLA'),2)
				If !Empty(cPais)
					Self:cXMLEnvio += WSSoapValue("mon:country",cPais,cPais,"string",   .F. , .F., 0 , NIL, .F.)
				EndIf
			EndIf
			Self:cXMLEnvio += '</mon:address>'
			Self:cXMLEnvio += '</mon:location>'
			Self:cXMLEnvio += '</mon:transition>'
			Self:cXMLEnvio += '</mon:transitions>'
			//Itens
			Self:cXMLEnvio += '<mon:items>'
			cAliasProds := GetNextAlias()
			BeginSql Alias cAliasProds
				SELECT SD2.D2_COD,
					   SD2.D2_QUANT,
					   SD2.D2_QTSEGUM,
					   SD2.D2_TOTAL,
					   SD2.D2_PESO,
					   SD2.D2_DOC,
					   SD2.D2_SERIE,
					   SD2.D2_LOTECTL,
					   SD2.D2_ITEM,
					   SB1.B1_COD,
					   SB1.B1_DESC,
					   (SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC) AS D2_VOLUME,
					   B1_TIPCONV,
					   B1_CONV
				  FROM %Table:SF2% SF2
				 INNER JOIN %Table:SD2% SD2
				    ON SD2.D2_FILIAL = %xFilial:SD2%
				   AND SD2.D2_DOC = SF2.F2_DOC
				   AND SD2.D2_SERIE = SF2.F2_SERIE
				   AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
				   AND SD2.D2_LOJA = SF2.F2_LOJA
				   AND SD2.%NotDel%
				 INNER JOIN %Table:SB1% SB1
				    ON SB1.B1_FILIAL = %xFilial:SB1%
				   AND SB1.B1_COD = SD2.D2_COD
				   AND SB1.%NotDel%
				  LEFT JOIN %Table:SB5% SB5
				   	ON SB5.B5_FILIAL = %xFilial:SB5%
				   AND SB5.B5_COD = SD2.D2_COD
				   AND SB5.%NotDel%
				 WHERE SF2.F2_FILIAL = %xFilial:SF2%
				   AND SF2.F2_DOC = %Exp:(cAliasNotas)->F2_DOC%
				   AND SF2.F2_SERIE = %Exp:(cAliasNotas)->F2_SERIE%
				   AND SF2.F2_CARGA = %Exp:Self:cCarga%
				   AND SF2.F2_SEQCAR = %Exp:Self:cSeqCarga%
				   AND SF2.%NotDel%
			EndSql
			While (cAliasProds)->(!EoF())
			
				IF lIntPrd2UM .AND. (cAliasProds)->B1_CONV > 0  // Indica a UM do produto a ser considerada na integração com do Monitoramento junto CPL
					nQtdePed	:= (cAliasProds)->D2_QTSEGUM
					
					// Deve calcular o peso com base na segunda UM do produto
					If (cAliasProds)->B1_TIPCONV == "D"
						nPesoNF := (cAliasProds)->D2_PESO * nQtdePed * (cAliasProds)->B1_CONV
					Else
						nPesoNF := ((cAliasProds)->D2_PESO * nQtdePed) / (cAliasProds)->B1_CONV
					EndIf
					
				Else
					nQtdePed	:= (cAliasProds)->D2_QUANT
					nPesoNF		:= (cAliasProds)->D2_PESO * nQtdePed		
				EndiF
			
				//Itens
				Self:cXMLEnvio += '<mon:item>'
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",cIdInvoice+"-"+(cAliasProds)->D2_ITEM,cIdInvoice+"-"+(cAliasProds)->D2_ITEM,"string",   .F. , .F., 0 , NIL, .F.)
				//Produto
				Self:cXMLEnvio += '<mon:product>'
				Self:cXMLEnvio += WSSoapValue("mon:sourceId",RTrim((cAliasProds)->B1_COD),RTrim((cAliasProds)->B1_COD),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:name",RTrim((cAliasProds)->B1_DESC),RTrim((cAliasProds)->B1_DESC),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:product>'
				//Informações gerais do item
				Self:cXMLEnvio += WSSoapValue("mon:quantity",nQtdePed,nQtdePed,"int",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:value",(cAliasProds)->D2_TOTAL,(cAliasProds)->D2_TOTAL,"double",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:weight",nPesoNF,nPesoNF,"double",   .F. , .F., 0 , NIL, .F.) //Rever Cálculo
				If !Empty((cAliasProds)->D2_VOLUME)
					Self:cXMLEnvio += WSSoapValue("mon:volume",nQtdePed*(cAliasProds)->D2_VOLUME,nQtdePed*(cAliasProds)->D2_VOLUME,"double",   .F. , .F., 0 , NIL, .F.) //Volume do documento
				EndIf
				//Informações complementares
				Self:cXMLEnvio += '<mon:extensions>'
				Self:cXMLEnvio += '<mon:extension>'
				Self:cXMLEnvio += WSSoapValue("mon:key","Lote","Lote","string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += WSSoapValue("mon:textValue",RTrim((cAliasProds)->D2_LOTECTL),RTrim((cAliasProds)->D2_LOTECTL),"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:extension>'
				Self:cXMLEnvio += '</mon:extensions>'
				Self:cXMLEnvio += '</mon:item>'
				(cAliasProds)->(DbSkip())
			EndDo
			(cAliasProds)->(DbCloseArea())
			Self:cXMLEnvio += '</mon:items>'
			Self:cXMLEnvio += '</mon:monitorable>'
			(cAliasNotas)->(DbSkip())
		EndDo
		(cAliasNotas)->(DbCloseArea())
		If !Empty((cAliasCarga)->DK0_VIAGID)
			Self:cXMLEnvio += '<mon:extensions>'
			Self:cXMLEnvio += '<mon:extension>'
			Self:cXMLEnvio += WSSoapValue("mon:key","Viagem","Viagem","string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += WSSoapValue("mon:textValue",RTrim((cAliasCarga)->DK0_VIAGID),RTrim((cAliasCarga)->DK0_VIAGID),"string",   .F. , .F., 0 , NIL, .F.)
			Self:cXMLEnvio += '</mon:extension>'
			Self:cXMLEnvio += '</mon:extensions>'
		EndIf
		Self:cXMLEnvio += '</mon:monitorables>'
		//Relacionamentos
		If !Empty(aChildren)
			Self:cXMLEnvio += '<mon:relationships>'
			For nI := 1 To Len(aChildren)
				Self:cXMLEnvio += '<mon:relationship>'
				Self:cXMLEnvio += WSSoapValue("mon:parentSourceId",cViagId,cViagId,"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '<mon:children>'
				Self:cXMLEnvio += WSSoapValue("mon:childSourceIds",aChildren[nI],aChildren[nI],"string",   .F. , .F., 0 , NIL, .F.)
				Self:cXMLEnvio += '</mon:children>'
				Self:cXMLEnvio += '</mon:relationship>'
			Next nI
			Self:cXMLEnvio += '</mon:relationships>'
		EndIf
		Self:cXMLEnvio += '</mon:monitorableSet>'
	EndIf
	(cAliasCarga)->(DbCloseArea())
Return
/*/{Protheus.doc} postAquisicaoMonitoravel
Realiza a comunicação (POST) com o WebService de monitoráveis do Cokcpit Logístico.
@author    amanda.vieira
@since     05/09/2019
@version   1.0
/*/
METHOD postAquisicaoMonitoravel() class OMSBCCMonitoramentoCPL
Local lIntMon   := SuperGetMv("MV_CPLMON",.F.,"2") == "1"
Local cUrlWSMon := SuperGetMv("MV_WSMONI",.F.,"")
Local oWsCpl    := Nil

	If lIntMon .And. !Empty(cUrlWSMon)
		If !Self:validaEnvioCarga()
			Self:lSucesso := .F.
		Else
			BEGIN WSMETHOD
				Self:montaXMLAquisicaoMonitoravel()
				oWsCpl := OMSXCPLWS():New()
				oWsCpl:SetUrl(cUrlWSMon)
				oWsCpl:SetTabela("DK5")
				oWsCpl:AddSoap(EncodeUTF8(Self:cXMLEnvio))
				oWsCpl:SetServico("monitorable")
				oWsCpl:SetMetodo("request")
				oWsCpl:SetXmlNameSpace("monitoring/monitorable")
				oWsCpl:SetIniMetodo('<mon:request xmlns:mon="http://www.neolog.com.br/cpl/acquisition/monitoring/monitorable/">')
				oWsCpl:SetFimMetodo('</mon:request>')
				oWsCPL:SetNomeArquivoXML(Self:getMonitoravelId())
				oWsCpl:SetOperacao(3)
				If !(Self:lSucesso := oWsCpl:Envia())
					Self:cMensagemErro := oWsCpl:cMsgRet
				Else 
					Self:gravaDK5()
				EndIf
			END WSMETHOD
		EndIf
	EndIf
	
Return Self:lSucesso
/*/{Protheus.doc} gravaDK5
Grava registro (DK5) para indicar que a carga foi integrada com o monitoramento.
@author    amanda.vieira
@since     05/09/2019
@version   1.0
/*/
METHOD gravaDK5(cStatus) class OMSBCCMonitoramentoCPL
Default cStatus := "1"
	If TableInDic('DK5')
		cAliasDK5 := GetNextAlias()
		BeginSql Alias cAliasDK5
			SELECT R_E_C_N_O_ RECNODK5
			  FROM %Table:DK5% DK5
			 WHERE DK5.DK5_FILIAL = %xFilial:DK5%
			   AND DK5.DK5_CARGA  = %Exp:Self:cCarga%
			   AND DK5.DK5_SEQCAR = %Exp:Self:cSeqCarga%
			   AND DK5.%NotDel%
		EndSql
		If (cAliasDK5)->(!EoF())
			DK5->(DbGoTo((cAliasDK5)->RECNODK5))
			RecLock("DK5",.F.)
			DK5->DK5_DATINT := Date()
			DK5->DK5_HORINT := Time()
			DK5->DK5_STATUS := cStatus
			DK5->(MsUnLock())
		Else
			RecLock("DK5",.T.)
			DK5->DK5_FILIAL := xFilial('DK5')
			DK5->DK5_CARGA  := Self:cCarga
			DK5->DK5_SEQCAR := Self:cSeqCarga 
			DK5->DK5_DATINT := Date()
			DK5->DK5_HORINT := Time()
			DK5->DK5_STATUS := cStatus
			DK5->(MsUnLock())   
		EndIf
		(cAliasDK5)->(DbCloseArea())
	EndIf
Return
/*/{Protheus.doc} montaXMLCancelamentoMonitoravel
Realiza a construção do XML a solicitação de cancelamento de monitoráveis
@author    amanda.vieira
@since     03/10/2019
@version   1.0
/*/
METHOD montaXMLCancelamentoMonitoravel() CLASS OMSBCCMonitoramentoCPL
Local cFilialDAK := Alltrim(OMSXGETFIL("DAK",.F.))
Local cViagId    := Self:getMonitoravelId()
	Self:cXMLEnvio := ""
	Self:cXMLEnvio += WSSoapValue("mon:key","Viagem","Viagem","string",   .F. , .F., 0 , NIL, .F.)
	Self:cXMLEnvio += "<upd:monitorableUpdateSet>"
	Self:cXMLEnvio += WSSoapValue("upd:operation","CANCEL","CANCEL","string", .F. ,.F.,0,NIL,.F.)
	Self:cXMLEnvio += "<upd:monitorableSet>"
	Self:cXMLEnvio += "<mon:monitorables>"
	Self:cXMLEnvio += "<mon:monitorable>"
	Self:cXMLEnvio += WSSoapValue("mon:sourceId",cViagId,cViagId,"string", .F. ,.F.,0,NIL,.F.)
	Self:cXMLEnvio += WSSoapValue("mon:type","TRIP","TRIP","string", .F. ,.F.,0,NIL,.F.)
	Self:cXMLEnvio += "</mon:monitorable>"
	Self:cXMLEnvio += "</mon:monitorables>"
	Self:cXMLEnvio += "</upd:monitorableSet>"
	Self:cXMLEnvio += "</upd:monitorableUpdateSet>"
Return

/*/{Protheus.doc} deleteMonitoravel
Realiza a comunicação (DELETE) com o WebService de monitoráveis do Cokcpit Logístico.
@author    amanda.vieira
@since     03/10/2019
@version   1.0
/*/
METHOD deleteMonitoravel() class OMSBCCMonitoramentoCPL
Local lIntMon   := SuperGetMv("MV_CPLMON",.F.,"2") == "1"
Local cUrlWSMon := SuperGetMv("MV_WSMONI",.F.,"")
Local oWsCpl    := Nil

	If lIntMon .And. !Empty(cUrlWSMon)
		BEGIN WSMETHOD
			Self:montaXMLCancelamentoMonitoravel()
			oWsCpl := OMSXCPLWS():New()
			oWsCpl:SetUrl(cUrlWSMon)
			oWsCpl:SetTabela("DK5")
			oWsCpl:AddSoap(EncodeUTF8(Self:cXMLEnvio))
			oWsCpl:SetServico("monitorable")
			oWsCpl:SetMetodo("request")
			oWsCpl:SetXmlNameSpace("monitoring/update")
			oWsCpl:SetIniMetodo('<upd:requestUpdate xmlns:upd="http://www.neolog.com.br/cpl/acquisition/monitoring/update/" xmlns:mon="http://www.neolog.com.br/cpl/acquisition/monitoring/monitorable/">')
			oWsCpl:SetFimMetodo('</upd:requestUpdate>')
			oWsCPL:SetNomeArquivoXML(Self:getMonitoravelId())
			oWsCpl:SetOperacao(5)
			If !(Self:lSucesso := oWsCpl:Envia())
				Self:cMensagemErro := oWsCpl:cMsgRet
			Else 
				Self:gravaDK5("2")
			EndIf
		END WSMETHOD
	EndIf
	
Return Self:lSucesso