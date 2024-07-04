#INCLUDE "PROTHEUS.CH"
#INCLUDE "PFSLOAD.CH"

Static __aSituac   := {} // Array com as Situações da pré-fatura

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSLOAD()
Rotina para carregar as situações no menu de pré-fatura 

@Return		nil

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSLOADEXEC()

	MsgRun(STR0001, ,{|| JurSitLoad()} ) // "Carregando situações..."
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurSitLoad()
Rotina para carregar o array de situações de pré-fatura 

@Return	 nil

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSitLoad()
Local aSX5 := {}
Local nI   := 0
Local nSX5 := 0

If Empty(__aSituac)

	aSX5 := FWGetSX5( "JS" )
	nSX5 := Len(aSX5)

	If nSX5 > 0
		For nI := 1 To nSX5 
			aAdd(__aSituac, {Alltrim(aSX5[nI][3]), Capital(Alltrim(aSX5[nI][4]))} )
		Next nI
	Else
		aAdd(__aSituac, {"",""} )
	EndIf

EndIf

Return (__aSituac)

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurSitGet()
Rotina para recuperar a descrição de uma situação contida no array de 
situações de pré-fatura. 

@param     cCodSit  - Código da chave da tabela de situação de pré-fatura. 

@Return    cRet     - Descrição da Situação

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSitGet(cCodSit)
Local nPos := 0
Local cRet := ""

Default cCodSit := ''

If !Empty(cCodSit)
	If (nPos := aScan( __aSituac, {|x| x[1] == cCodSit} ) ) > 0

		cRet := __aSituac[nPos][2]

	EndIf
EndIf

Return cRet
