#INCLUDE "mt240tok.ch"
#INCLUDE "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMT240TO
Avaliar Digitacao de movimentações internas

@author TOTVS
@return _lRet
@since 08/02/2017
@version P11
/*/
//-------------------------------------------------------------------
Function DCLMT240TO()

Local _aArea        := GetArea()
Local _aAreaSD3     := SD3->(GetArea())
Local _lRet			:= .T.
Local _Mens			:= ""

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If (M->D3_TPMOVAJ == "PR" .OR. M->D3_TPMOVAJ == "TR") .AND. ALLTRIM(FUNNAME())=="MATA240"
	
	If Empty(M->D3_NFORP) .AND. M->D3_TPMOVAJ == "PR"
		_Mens:=_Mens+OemToAnsi(STR0001)+chr(13) //"-> Nr. da ORP deve existir "
		_lRet:=.F.
	EndIf
	SD3->(dbSetOrder(9))
	If M->D3_TPMOVAJ == "PR"
		If (SD3->(msSeek(xFilial("SD3")+M->D3_NFORP)))
			_Mens:=_Mens+OemToAnsi(STR0002)+chr(13) //"-> Ja' existe esta ORP gravada "
			_lRet:=.F.
		EndIf
	EndIf
	SD3->(dbSetOrder(1))
	If Empty(M->D3_TANQUE)
		_Mens:=_Mens+OemToAnsi(STR0003)+chr(13) //"-> Codigo do Tanque deve ser informado "
		_lRet:=.F.
	Else
		If ! (DH6->(msSeek(xFilial("DH6")+M->D3_TANQUE+M->D3_COD)))
			_Mens:=_Mens+OemToAnsi(STR0004)+CHR(13) //"-> Tanque Nao cadastrado para este produto "
			_lRet:=.F.
		EndIf
	EndIf
	If ! _lRet
		MsgStop(_Mens,OemToAnsi(STR0005)) //"Gravacao nao sera' efetuada"
	EndIf

EndIf


//Posiciona na cessionaria
IF !l240Auto .AND. _lRet  // Caso nao seja rotina automatica valida volume maximo.
	D35->(dbSetOrder(1))
	If  D35->(dbSeek(xFilial('D35')+M->D3_LOCAL))
		_lRet:= DCLEA10VMAX (M->D3_COD,D35->D35_COD,D35->D35_LOJA,M->D3_LOCAL,"2",M->D3_QUANT)
	Endif
Endif
// Verifica se o saldo em estoque ficara negativo
If _lRet .And. ((M->D3_TM > "500" .And. IsInCallStack("A240Inclui")))
	_lRet := ValEstDcl(M->D3_COD,M->D3_LOCAL,M->D3_QUANT,M->D3_EMISSAO,3)
EndIf	


SD3->(RestArea(_aAreaSD3))
RestArea(_aArea)

Return(_lRet)