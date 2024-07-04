#Include 'Protheus.ch'

Function MATA020ARUS()

Return

/*/{Protheus.doc} RU01SA1INN
Simple validation func for A2_TPESSOA
////
@author  Andrews Egas
@since 01/05/2017
@version MA3 - Russia
/*/
Function RusVldSA2()

If M->A2_TIPO <> "1"
	M->A2_PASSPOR := ""
Elseif M->A2_TIPO <> "2"
	M->A2_INSCGAN := ""
EndIf

Return .T.

/*/{Protheus.doc} RU01SA1INN
Simple validation func for INN length

@author  Andrews Egas
@since 01/05/2017
@version MA3 - Russia
/*/
Function RU01SA2INN(cField1,cField2)

Local lRet as logical
Local nChkSize as integer

lRet := .F.
nChkSize := 12

if (M->&(cField1)='2')
	nChkSize := 10
Endif

if (Len(AllTrim(M->&(cField2))) == nChkSize)
	lRet := .T.
Endif

Return lRet

/*/{Protheus.doc} A020HeadQ
A2_CODZON 

@author  Andrews Egas
@since 01/05/2017
@version MA3 - Russia
/*/
Function A020HeadQ()
Local aArea := GetArea()

M->A2_CODZON := Posicione("SA2", 1, xFilial("SA2")+M->A2_HEAD + M->A2_HEADUN, "A2_CODZON")

RestArea(aArea)
Return .T.

//merge branch 12.1.19
// Russia_R5
