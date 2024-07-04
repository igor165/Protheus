#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} GTPJ003
Função responsavel pela criação do job para acertar bilhetes integrados errados
@type function
@author jacomo.fernandes
@since 31/12/2018
@version 1.0
@param aParam, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPJ003(aParam, lAuto)
local lJob		 := Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cFilOk 	 := ""
Local cUserOk    := ""
Local nPosEmp    := 0
Local nPosFil    := 0
Local aProc      := {}

Default lAuto    := .F.
//---Inicio Ambiente

If lJob // Schedule
	nPosEmp := IF(Len(aParam) == 8, 5, 1)
	nPosFil := IF(Len(aParam) == 8, 6, 2)

	RPCSetType(3)
	
	PREPARE ENVIRONMENT EMPRESA aParam[nPosEmp] FILIAL aParam[nPosFil] MODULO "FAT"
EndIf   

If Len(aParam) == 8 .OR. FwIsInCall('GTPJ03A')
	AADD(aProc,aParam[1]) //Data de
	AADD(aProc,aParam[2]) //Data até
	AADD(aProc,aParam[3]) //agengia de
	AADD(aProc,aParam[4]) //agencia ate
EndIf

cFilOk := cfilant
cUserOk := __cUserId 
 
AcertaBilhete(aProc, lAuto)

cFilAnt	:= cFilOk
 __cUserId := cUserOk 

Return

Static Function AcertaBilhete(aProc, lAuto)
Local aRecGZV	:= {} //Guarda o Recno da GZV para acerta-lo Dps

Default aProc := {}
//Função responsavel pelo Acerto do BilRef
AcertaBilRef(aRecGZV,aProc, lAuto)

//Função responsavel pelo acerto da viagem
AcertaViagem(aRecGZV,aProc, lAuto)

//Função Responsavel para atualizar o Status da GZV
AtualizaStatus(aRecGZV)

GTPDestroy(aRecGZV)

Return



/*/{Protheus.doc} AcertaBilRef
(long_description)
@type function
@author jacomo.fernandes
@since 31/12/2018
@version 1.0
@param aRecGZV, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AcertaBilRef(aRecGZV,aProc, lAuto)
Local cAliasTmp	:= GetNextAlias()
Local aAreaGIC	:= GIC->(GetArea())

Local nRecGZV := 0
Local cBilRef := ""
Local cExtGIC := ""
Local cCodSrv := ""
Local cExtGYN := ""
Local cWhere  := "%%"

If Len(aProc) > 0
	cWhere := "%AND GIC.GIC_DTVEND BETWEEN '" + aProc[1] + "' AND '" + aProc[2] + "' "
	cWhere += "AND GIC.GIC_AGENCI BETWEEN '" + aProc[3] + "' AND '" + aProc[4] + "' %"
EndIf

BeginSql Alias cAliasTmp
	select 
		GIC.GIC_FILIAL,
		GIC.GIC_CODIGO,
		GIC.GIC_BILREF,
		GZV.GZV_EXTGIC,
		GIC.GIC_CODSRV,
		GZV.GZV_EXTGYN,
		GIC.R_E_C_N_O_ as GICREC,
		GZV.R_E_C_N_O_ as GZVREC,
		XXFGIC.XXF_INTVAL as INTVAL
	From %Table:GZV% GZV
		INNER JOIN %Table:GIC% GIC ON
			GIC.GIC_FILIAL+GIC.GIC_CODIGO = GZV.GZV_CHAVE
			AND GIC.GIC_BILREF = '' 
			AND GZV.GZV_EXTGIC <> ''
			%Exp:cWhere%
			AND GIC.%NotDel%
		INNER JOIN XXF XXFGIC on
			XXFGIC.XXF_ALIAS = 'GIC'
			and XXFGIC.XXF_EXTVAL = GZV.GZV_EXTGIC
			and XXFGIC.%NotDel%
		
	WHERE 
		GZV.GZV_ALIAS = 'GIC'
		AND GZV.GZV_STATUS <> '1' 
		AND GZV.%NotDel%
	ORDER BY GZV.GZV_STATUS
EndSql

DbSelectArea('GIC')

While (cAliasTmp)->(!Eof())
	GIC->(DbGoTo((cAliasTmp)->GICREC))
	RecLock('GIC',.F.)

		GIC->GIC_BILREF := Separa((cAliasTmp)->INTVAL, '|' )[3]
		
	GIC->(MsUnLock())
	
	nRecGZV := (cAliasTmp)->GZVREC
	cBilRef := GIC->GIC_BILREF
	cExtGIC := (cAliasTmp)->GZV_EXTGIC
	cCodSrv := GIC->GIC_CODSRV
	cExtGYN := (cAliasTmp)->GZV_EXTGYN
		
	SetRecGZV(aRecGZV,nRecGZV,cBilRef,cExtGIC,cCodSrv,cExtGYN, lAuto)
	
	(cAliasTmp)->(DbSkip())							
EndDo

(cAliasTmp)->(DbCloseArea())

RestArea(aAreaGIC)

Return


/*/{Protheus.doc} AcertaViagem
(long_description)
@type function
@author jacomo.fernandes
@since 31/12/2018
@version 1.0
@param aRecGZV, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AcertaViagem(aRecGZV,aProc, lAuto)
Local cAliasTmp	:= GetNextAlias()
Local aAreaGIC	:= GIC->(GetArea())

Local nRecGZV := 0
Local cBilRef := ""
Local cExtGIC := ""
Local cCodSrv := ""
Local cExtGYN := ""
Local cWhere  := "%%"

If Len(aProc) > 0
	cWhere := "%AND GIC.GIC_DTVEND BETWEEN '" + aProc[1] + "' AND '" + aProc[2] + "' "
	cWhere += "AND GIC.GIC_AGENCI BETWEEN '" + aProc[3] + "' AND '" + aProc[4] + "' %"
EndIf

BeginSql Alias cAliasTmp
	select 
		GIC.GIC_FILIAL,
		GIC.GIC_CODIGO,
		GIC.GIC_CODSRV,
		GZV.GZV_EXTGYN,
		GIC.GIC_BILREF,
		GZV.GZV_EXTGIC,
		GIC.R_E_C_N_O_ as GICREC,
		GZV.R_E_C_N_O_ as GZVREC,
		XXFGYN.XXF_INTVAL as INTVAL
	From %Table:GZV% GZV
		INNER JOIN %Table:GIC% GIC ON
			GIC.GIC_FILIAL+GIC.GIC_CODIGO = GZV.GZV_CHAVE
			AND GIC.GIC_CODSRV = '' 
			AND GZV.GZV_EXTGYN <> ''
			%Exp:cWhere%
			AND GIC.%NotDel%
		INNER JOIN XXF XXFGYN on
			XXFGYN.XXF_ALIAS = 'GYN'
			and XXFGYN.XXF_EXTVAL = GZV.GZV_EXTGYN
			and XXFGYN.%NotDel%
		
	WHERE 
		GZV.GZV_ALIAS = 'GIC'
		AND GZV.GZV_STATUS <> '1'  
		AND GZV.%NotDel%
	ORDER BY GZV.GZV_STATUS
EndSql

DbSelectArea('GIC')

While (cAliasTmp)->(!Eof())
	GIC->(DbGoTo((cAliasTmp)->GICREC))
	RecLock('GIC',.F.)

		GIC->GIC_CODSRV := Separa((cAliasTmp)->INTVAL, '|' )[3]
		
	GIC->(MsUnLock())
	
	nRecGZV := (cAliasTmp)->GZVREC
	cBilRef := GIC->GIC_BILREF
	cExtGIC := (cAliasTmp)->GZV_EXTGIC
	cCodSrv := GIC->GIC_CODSRV
	cExtGYN := (cAliasTmp)->GZV_EXTGYN
		
	SetRecGZV(aRecGZV,nRecGZV,cBilRef,cExtGIC,cCodSrv,cExtGYN, lAuto)
	
	(cAliasTmp)->(DbSkip())							
EndDo

(cAliasTmp)->(DbCloseArea())

RestArea(aAreaGIC)

Return


/*/{Protheus.doc} AtualizaStatus
(long_description)
@type function
@author jacomo.fernandes
@since 31/12/2018
@version 1.0
@param aRecGZV, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualizaStatus(aRecGZV)
Local aAreaGZV	:= GZV->(GetArea())
Local n1		:= 0

DbSelectArea('GZV')

For n1 := 1 To Len(aRecGZV)
	GZV->(DbGoTo(aRecGZV[n1][1]))
	
	RecLock('GZV',.F.)
		
		GZV->GZV_STATUS := aRecGZV[n1][2] 
	
	GZV->(MsUnLock())
Next

RestArea(aAreaGZV)

Return


/*/{Protheus.doc} SetRecGZV
(long_description)
@type function
@author jacomo.fernandes
@since 31/12/2018
@version 1.0
@param aRecGZV, array, (Descrição do parâmetro)
@param nRecGZV, numérico, (Descrição do parâmetro)
@param cBilRef, character, (Descrição do parâmetro)
@param cExtGIC, character, (Descrição do parâmetro)
@param cCodSrv, character, (Descrição do parâmetro)
@param cExtGYN, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetRecGZV(aRecGZV,nRecGZV,cBilRef,cExtGIC,cCodSrv,cExtGYN, lAuto)
Local lOk		:= .T.
Local cStatus	:= "1" //Sucesso
Local nPos		:= 0

if lAuto //!IsBlind()
	If (nPos := aScan(aRecGZV,{|x| x[1] == nRecGZV })) == 0
		aAdd(aRecGZV,{nRecGZV,''})
		nPos := Len(aRecGZV)
		
	Endif
Endif

//Se o ExtVal estiver Preenchido e o Campo Referencia não, quer dizer que esta errado
If !Empty(cExtGIC) .and. Empty(cBilRef)
	lOk	:= .F.
Elseif !Empty(cExtGYN) .and. Empty(cCodSrv)
	lOk	:= .F.
Endif

If !lOk	
	cStatus := "4" //Reprocessado
Endif 

aRecGZV[nPos][2] := cStatus

Return

/*/{Protheus.doc} GTPJ03A
Função para chamada de função
@type function
@author GTP
@since 16/11/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPJ03A()

Local aParamBox	:= {}
Local aPergRet	:= {}
Local dDataDe   := FirstDate(Date())
Local dDataAt   := LastDate(Date())

aAdd(aParamBox, {1, "Data da venda de:" , dDataDe,  "", ".T.", "", ".T.", 80,  .F.})// Pergunta 01 : Data da venda de:
aAdd(aParamBox, {1, "Data da venda até:", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})// Pergunta 02 : Data da venda até:
aAdd(aParamBox, {1, "Agencia De:"       ,  Space(6)	 , "@!" ,, "GI6",, 50, .F.} )	// Pergunta 03 : Agencia De:
aAdd(aParamBox, {1, "Agencia Até"       ,  Space(6)	 , "@!" ,, "GI6",, 50, .T.} )	// Pergunta 04 : Agencia Até

If ParamBox(aParamBox, "Informe os dados", aPergRet) 	
	FWMsgRun(, {|| GTPJ003({DTOS(aPergRet[1]),DTOS(aPergRet[2]),aPergRet[3],aPergRet[4]})},"", "Processando registros")
	FwAlertInfo("Processamento finalizado com sucesso!","Finalizado")
EndIf

Return()
