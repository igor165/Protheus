#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} User Function VlrAbast
	Fun��o chamada no X3_VLDUSER do campo TQQ_QUANT e TQN_FROTA para ver se trata-se de Veiculo de Terceiro
	T9_PROPRIE igual a 2	
	@type  Function
	@author Manoel Filho
	@since 20/02/2022
	@version version
	@return 
/*/
User Function VlrAbast()
local lRet := .t.
local cQuery := ""
local nPOSTTABA := 0

nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VTTABA"})
nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VUNABA"})
nPOSFORT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_FORST9"})
nPOSLOJT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_LOJST9"})

aCols[n][nPOSFORT9] := ""
aCols[n][nPOSLOJT9] := ""
aCols[n][nPOSVUABA] := 0
aCols[n][nPOSTTABA] := 0

// Verifica se � de terceiro
If Select("TMPST9") > 0
	TMPST9->(dbCloseArea())
EndIf

cQuery := "SELECT ST9.T9_PROPRIE, ST9.T9_FORNECE, ST9.T9_LOJA "
cQuery += " FROM "+RetSqlName("ST9")+" ST9 "
If ReadVar() == "M->TQN_FROTA"
	cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+M->TQN_FROTA+"'"
Else
	cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+aCols[n][nPOSFROTA]+"'"
Endif
DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPST9", .f., .f.)

If !TMPST9->(Eof()) // � ve�culo de Terceiro

	If TMPST9->T9_PROPRIE <> '2' 
		MsgInfo("Este ve�culo est� cadastrado com nome TERCEIRO, por�m o Propriet�rio est� como Pr�prio! Favor corrigir o cadastro do ve�culo!","Aten��o")
		lRet := .f.
	Endif

	If lRet

		// Busca pre�o vigente do combustivel
		If Select("TMPZAT") > 0
			TMPZAT->(dbCloseArea())
		EndIf

		cQuery := "SELECT ZAT_VALCOM "
		cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
		cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+cCODCOM+"'"
		cQuery += " AND ZAT.ZAT_DATCAD <= '"+Dtos(aCols[n][nPOSDATAB])+"' AND ZAT.D_E_L_E_T_ = ' '"
		DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

		aCols[n][nPOSFORT9] := TMPST9->T9_FORNECE
		aCols[n][nPOSLOJT9] := TMPST9->T9_LOJA
		If !TMPZAT->(Eof())
			aCols[n][nPOSVUABA] := TMPZAT->(ZAT_VALCOM)
			If ReadVar() == "M->TQN_FROTA"
				aCols[n][nPOSTTABA] := aCols[n][nPOSQUANT] * TMPZAT->(ZAT_VALCOM)
			Else
				aCols[n][nPOSTTABA] := M->TQQ_QUANT * TMPZAT->(ZAT_VALCOM)
			Endif
		else
			If MsgYesNo("N�o existe Pre�o de Combust�vel cadastrado para esta data! Deseja Continuar?", "Aten��o")
				lRet := .t.
			Else
				lRet := .f.
			Endif
		Endif
		TMPZAT->(dbCloseArea())

	Endif

Endif
TMPST9->(dbCloseArea())

Return lRet
