#include "protheus.ch"
#include "parmtype.ch"
#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJ010.CH"
//aParam := {'01','000093'}
//GTPJ010({'01','000093'})
//GTPJ010({'',''})
//GTPJ010()
/*/{Protheus.doc} GTPJ010
Job de criação automatica das fichas de remessa
@type function
@author henrique.toyada
@since 03/04/2019
@version 1.0
@param aParam, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPJ010(aParam)

local lJob		 := Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cFilOk 	 := ""
Local cUserOk    := ""
Local cFilG6x    := ""
Local cAgencia   := ""

If ValType(aParam) == "A" .AND. Len(aParam) > 0
	If lJob .and. Len(aParam) > 4
		cFilG6x  := aParam[1] 
		cAgencia := aParam[2]
	EndIf
EndIf
//---Inicio Ambiente

If lJob // Schedule
	RPCSetType(3)
	If Len(aParam) > 4
		PREPARE ENVIRONMENT EMPRESA aParam[3] FILIAL aParam[4] MODULO "FAT"
	Else
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "FAT"
	EndIf
EndIf   

cFilOk := cfilant
cUserOk := __cUserId 
 
GT421BAUTO(aParam)

cFilAnt	:= cFilOk
 __cUserId := cUserOk 
Return()

/*/{Protheus.doc} GT421BAUTO
(long_description)
@type function
@author henrique.toyada
@since 03/04/2019
@version 1.0
@param aParam, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GT421BAUTO(aParam)
 
Local oModel     := FWLoadModel("GTPA421B") 
Local oModelGex  := oModel:GetModel("G6XMASTER")
Local nI         := 0
Local aDados     := {}
Local aNumFch    := {}
Local nLoop      := 0
Local nPos       := 0
Local lAux       := .T.
Local lRet       := .T.
Local cFilG6x    := ""
Local cAgencia   := ""

Default aParam := {}

cFilG6x := IIF(LEN(aParam) > 4,aParam[1],"" )
cAgencia :=IIF(LEN(aParam) > 4,aParam[2],"" )

aNumFch := GeraNxFch(cFilG6x, cAgencia)

If Len(aNumFch) > 0
	For nLoop := 1 To Len(aNumFch)
		If EMPTY(__cUserId)
			__cUserId := IIF(LEN(aParam) > 4,aParam[5],aParam[3] )
		EndIf
		oModel:SetOperation(MODEL_OPERATION_INSERT) 
		
		oModel:Activate() // Ativa o Modelo
		oModelGex:SetOnlyQuery(.F.) 
		oStruct := oModelGex:GetStruct()
		aAux	:= oStruct:GetFields()
		aDados := aclone(aNumFch[nLoop])
		For nI := 1 To Len( aDados )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aDados[nI][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( "G6XMASTER", aDados[nI][1], aDados[nI][2] ) )
					lRet    := .F.
					Exit
				EndIf
			EndIf
		Next
		
		If oModel:VldData()
			oModel:CommitData()
			Exec421Auto()
		EndIf
		oModel:DeActivate()
	Next
EndIf

Return

/*/{Protheus.doc} GeraNxFch
Verifica para quais fichas estão com status deferente de aberto para ser criadas
@type function
@author henrique.toyada
@since 03/04/2019
@version 1.0
@param cFilG6x, character, (Descrição do parâmetro)
@param cAgencia, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraNxFch(cFilG6x, cAgencia)

Local cWhere  := ""
Local aNumFch := {}
Local cNextAlias := GetNextAlias()

Default cFilG6x  := ''
Default cAgencia := ''

If !(EMPTY(cFilG6x))
	cWhere := " AND G6XI.G6X_FILIAL = '" + cFilG6x + "' "
EndIf
If !(EMPTY(cAgencia)) 
	cWhere += " AND G6XI.G6X_AGENCI = '" + cAgencia + "' "
EndIf
cWhere := "%" + cWhere + "%"
BeginSql Alias cNextAlias
SELECT
	G6X.G6X_FILIAL
  , G6X.G6X_AGENCI
  , G6X.G6X_NUMFCH
FROM
	(
		SELECT
			G6XI.G6X_FILIAL
		  , G6XI.G6X_AGENCI
		  , MAX(G6XI.G6X_NUMFCH) FICHA
		FROM
			%Table:G6X% G6XI
		WHERE
			G6XI.%NotDel%
			%Exp:cWhere%
		GROUP BY
			G6XI.G6X_FILIAL
		  , G6XI.G6X_AGENCI
	)
	AS TB
	INNER JOIN
		%Table:G6X% G6X
		ON
			G6X.G6X_FILIAL     = TB.G6X_FILIAL
			AND G6X.G6X_AGENCI = TB.G6X_AGENCI
			AND G6X.G6X_NUMFCH = TB.FICHA
			AND G6X.%NotDel%
WHERE
	G6X.G6X_STATUS NOT IN ('1'',5') //RADU: Ajustado para ficha Reaberta - 25/11/21
EndSql

While !((cNextAlias)->(Eof()))
	AADD(;
		aNumFch,{;
					{"G6X_FILIAL",(cNextAlias)->G6X_FILIAL},;
					{"G6X_AGENCI",(cNextAlias)->G6X_AGENCI};
				};
	)
	(cNextAlias)->(DbSkip())
End

(cNextAlias)->(DBCloseArea())

Return aNumFch

/*/{Protheus.doc} Exec421Auto
Executa commit da GTPA421
@type function
@author henrique.toyada
@since 03/04/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Exec421Auto()

Local oModel     := FWLoadModel("GTPA421") 
Local oModelG6x  := oModel:GetModel("G6XMASTER")
oModel:SetOperation(MODEL_OPERATION_INSERT) 
		
oModel:Activate() // Ativa o Modelo
oModelG6x:SetOnlyQuery(.F.)
oModel:SetValue( "G6XMASTER", "G6X_STATUS", "1" ) //Radu: Por ser uma inclusão, o status deve ficar '1'
		
If oModel:VldData()
	oModel:CommitData()
EndIf

oModel:DeActivate()

Return
