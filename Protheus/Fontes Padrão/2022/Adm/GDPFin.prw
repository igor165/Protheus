#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINXTIPOS
Retorna os tipos de títulos que são considerados pelo sistema para
situações como abatimentos, recebimento antecipado, pagamento
antecipado e taxas

@author  Arnaldo R. Junior
@since  23/07/2010
@version 12
/*/
//-------------------------------------------------------------------
FUNCTION FINXTIPOS(CMVTIPO)

STATIC __AFINTIPOS := {}

Local cReturn		:= ""
Local nPosTipos		:= 0
Local cMVABATIM		:= ""
Local cMVABATOU		:= ""
Local cMVABATMP		:= ""
Local cMVCRNEG      := ""
Local cMVCPNEG      := ""
Local cPARus		:= If(cPaisLoc=="RUS", "|PP ", "") //specific type for Russia. Equal behavior of PA.

Public MVI2ABT := "I2-"

IF LEN(__AFINTIPOS) == 0

	AADD(__AFINTIPOS,{"MVPROVIS"	,GetSESNew("PR ","3")})
	AADD(__AFINTIPOS,{"MVPAGANT"	,GetSESNew("PA ","2")+cPARus})
	AADD(__AFINTIPOS,{"MVRECANT"	,GetSESNew("RA ","1")})
	AADD(__AFINTIPOS,{"MVNOTAFIS"	,GetSESNew("NF ","3")})
	AADD(__AFINTIPOS,{"MVDUPLIC"	,GetSESNew("DP ","3")})
	AADD(__AFINTIPOS,{"MVFATURA"	,GetSESNew("FT ","3")})
	AADD(__AFINTIPOS,{"MVCHEQUE"	,GetSESNew("CH ","3")})
	AADD(__AFINTIPOS,{"MVCHEQUES"	,GetSESNew("CH ","3")+"|"+GetSESNew("CHF","3")+"|"+GetSESNew("CHP","3")+"|"+GetSESNew("CHR","3")})
	AADD(__AFINTIPOS,{"MVRPA"		,GetSESNew("RPA","2")})
	AADD(__AFINTIPOS,{"MVTAXA"		,GetSESNew("TX ","3")})
	AADD(__AFINTIPOS,{"MVISS"		,GetSESNew("ISS","3")})
	AADD(__AFINTIPOS,{"MVTXA"		,GetSESNew("TXA","3")})
	AADD(__AFINTIPOS,{"MVIRF"		,GetSESNew("IRF","1")})
	AADD(__AFINTIPOS,{"MVINSS"		,GetSESNew("INS","2")})
	AADD(__AFINTIPOS,{"MVCOFINS"	,GetSESNew("COF","1")})
	AADD(__AFINTIPOS,{"MVPIS"		,GetSESNew("PIS","1")})
	AADD(__AFINTIPOS,{"MVFUABT"		,GetSESNew("FU-","1")})
	AADD(__AFINTIPOS,{"MVCS"		,GetSESNew("CSS","1")})
	AADD(__AFINTIPOS,{"MVENVBCOR"	,GetSESTipos({ || ES_TRANSFE == "2"},"1")})
	AADD(__AFINTIPOS,{"MVENVBCOP"	,GetSESTipos({ || ES_TRANSFE == "2"},"2")})

	//--------------------------------------------------
	// TRATAMENTO DOS TIPOS DE TITULOS DE ABATIMENTOS
	//--------------------------------------------------
	cMVABATMP := GetSESNew("FP-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVFPABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("IR-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVIRABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("IN-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVINABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("IS-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVISABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("PI-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVPIABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("CF-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVCFABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("CS-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVCSABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("FE-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVFEABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("IV-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVIVABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("I2-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVI2ABT"		,cMVABATMP})

	cMVABATMP := GetSESNew("IM-","3")
	cMVABATOU += '|'+cMVABATMP
	AADD(__AFINTIPOS,{"MVIMABT"		,cMVABATMP})
	
	If cPaisLoc == 'BRA'
		//NÃO RETIRAR esse tratamento, mesmo que acuse no SonarQube
		//Feito esse tratamento para atender VAREJO que ainda usa base local CTREE
		//Pequim alinhou com Ivan PC
		#IFDEF TOP
			cMVABATIM := GetSX5Abat()
		#ELSE
			cMVABATIM := GetSESTipos({ || ES_ABATIM == "1"},"3")
		#ENDIF
		
		cMVABATIM += '|FC-|FE-'
		
		AADD(__AFINTIPOS,{"MVABATIM"	,If ( Empty(cMVABATIM), 'AB-|FB-|FC-|FU-' + cMVABATOU, cMVABATIM ) } )
		
	Else
		cMVABATIM := GetSESTipos({ || ES_ABATIM == "1"},"3")
		If cPaisLoc == "DOM"
			AADD(__AFINTIPOS,{"MVABATIM"	,If ( Empty(cMVABATIM), 'AB-|FB-|FC-|IT-', cMVABATIM ) + cMVABATOU})
		Else
			AADD(__AFINTIPOS,{"MVABATIM"	,If ( Empty(cMVABATIM), 'AB-|FB-|FC-|FU-', cMVABATIM ) + cMVABATOU})
		EndIf
	EndIf

	If ! Empty(cMVABATIM)
	    cMVCRNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ cMVABATIM+cMVABATOU+"/"+MVRECANT},"1")
    	cMVCPNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ cMVABATIM+cMVABATOU+"/"+MVPAGANT},"2")
 	Else
 		If cPaisLoc == "DOM"
	 		cMVCRNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ 'AB-|FB-|FC-|IT-'+cMVABATOU+"/"+MVRECANT},"1")
		    cMVCPNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ 'AB-|FB-|FC-|IT-'+cMVABATOU+"/"+MVPAGANT},"2")
		Else
			cMVCRNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ 'AB-|FB-|FC-|FU-'+cMVABATOU+"/"+MVRECANT},"1")
		    cMVCPNEG := GetSESTipos({ || ES_SINAL == "-".AND. !ES_TIPO $ 'AB-|FB-|FC-|FU-'+cMVABATOU+"/"+MVPAGANT},"2")
		EndIf
 	EndIf

	AADD(__AFINTIPOS,{"MV_CRNEG"	,If ( Empty(cMVCRNEG), 'NCC', cMVCRNEG) })

	If cPaisLoc == "BRA"
	   AADD(__AFINTIPOS,{"MV_CPNEG"	,If ( Empty(cMVCPNEG), 'NDF', cMVCPNEG) + "|DIC" })
    Else
	   AADD(__AFINTIPOS,{"MV_CPNEG"	,If ( Empty(cMVCPNEG), 'NCP|NDI ', cMVCPNEG) })
	EndIf
ENDIF

IF (nPosTipos := aScan(__AFINTIPOS,{|aTipo| aTipo[1] == CMVTIPO}))>0
	cReturn := __AFINTIPOS[nPosTipos][2]
ENDIF

RETURN cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSX5Abat
Monta e retorna o conteúdo para o MVABATIM com base nos titulos do
tipo abatimento na SX5 (tipos que tenham o hifen (-) na terceira
posição

@author Mauricio Pequim Jr.
@since  22/05/2018
@version 12
/*/
//-------------------------------------------------------------------
Function GetSX5Abat()

Local cAbatim	:= ""
Local cTpAbt	:= ""
Local cTmp		:= ""
Local cSelSX5	:= ""

cTmp  := CriaTrab(,.F.)
cSelSX5 := "%" + " DISTINCT SX5.X5_CHAVE CHAVE" + "%"
cTpAbt  := "%" + " SX5.X5_CHAVE LIKE '__-%' " + "%"

BeginSQL Alias cTmp
	SELECT %Exp:cSelSX5%
	FROM %table:SX5% SX5
	WHERE
		SX5.X5_TABELA  = '05'
		AND %Exp:cTpAbt%
		AND SX5.%NotDel%
EndSQL

While !(cTmp)->(EoF())
	cAbatim += "|" + Substr((cTmp)->CHAVE,1,3)
	(cTmp)->(dbSkip())
EndDo

If !Empty(cAbatim)
	cAbatim := Substr(cAbatim,2,Len(cAbatim))
EndIf

(cTmp)->(dbCloseArea())

Return cAbatim
