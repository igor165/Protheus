#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJCTE.CH"


/*/{Protheus.doc} GTPJCTE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 15/10/2019
@version 1.0
@return ${return}, ${return_description}
@param aParam, array, descricao
@type function
/*/
Function GTPJCTE(aParam)

	Local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
	Local cFilOk 		:= ""
	//---Inicio Ambiente

	If lJob // Schedule
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "GTP"
	EndIf   

	cFilOk := cfilant

	GTPATUCTE(ljob)
	GTPATUEVE(ljob)

	cFilAnt	:= cFilOk

Return

/*/{Protheus.doc} GTPATUCTE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 15/10/2019
@version 1.0
@return ${return}, ${return_description}
@param ljob, logical, descricao
@type function
/*/
Static Function GTPATUCTE(ljob)

	Local cTmpAlias := GetNextAlias() 	
	Default ljob		:= .F.


	BeginSql Alias cTmpAlias
	    SELECT G99_SERIE SERIE,MIN(G99_NUMDOC) DOCMIN,MAX(G99_NUMDOC) DOCMAX
	    FROM %Table:G99% G99
	    WHERE 
	    G99.G99_STATRA='1' AND
	    G99.G99_FILIAL = %xFilial:G99% AND
	    G99.%NotDel%	     
	    GROUP BY G99_SERIE 
	EndSql

	If (cTmpAlias)->(!Eof())
		While (cTmpAlias)->(!Eof())
			ProcRetCte( Nil , Nil , Nil , (cTmpAlias)->SERIE, (cTmpAlias)->DOCMIN, (cTmpAlias)->DOCMAX, Nil )    
			(cTmpAlias)->(dbSkip())
		End	
	Endif

	(cTmpAlias)->(dbCloseArea())

	If !lJob
		Aviso(STR0003, STR0004, {'OK'}, 2)//"Job atualização CTE "##"Atualização efetuada."
	Endif
		
return .T.


/*/{Protheus.doc} GTPATUEVE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 28/10/2019
@version 1.0
@return ${return}, ${return_description}
@param ljob, logical, descricao
@type function
/*/
Static Function GTPATUEVE(ljob)
	GTP812AtuEv() 		
return .T.


