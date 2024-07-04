#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 

User Function MNTA080()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
 
Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
 
 
If aParam <> NIL
      
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3]
	
	If cIdPonto == 'MODELVLDACTIVE'
	ElseIf cIdPonto == 'MODELPOS'
		
		//Validação total do model
		if empty(FwFldGet("T9_ITEMCTA")) .and. FwFldGet("T9_PROPRIE")='1'
			ApMsgInfo('O item contabil deve estar em branco quando for Bem de Terceiro.')
			return .F.
		elseif !empty(FwFldGet("T9_ITEMCTA")) .and. FwFldGet("T9_PROPRIE") != '1'
			FwFldPut("T9_ITEMCTA", Space(TamSX3("T9_ITEMCTA")[1]))
			ApMsgInfo('O item contabil não deve estar preenchido quando for Bem de Terceiro.')
			return .F.
		elseif empty(FwFldGet("T9_FORNECE")) .and. FwFldGet("T9_PROPRIE") != '1'
			ApMsgInfo('O Fornecedor deve ser informado quando for Bem de Terceiro.')
			return .F.
		endIf
		
	ElseIf cIdPonto == 'FORMPOS'
	ElseIf cIdPonto == 'FORMLINEPRE'
	ElseIf cIdPonto == 'FORMLINEPOS'
	ElseIf cIdPonto == 'MODELCOMMITTTS'
	ElseIf cIdPonto == 'MODELCOMMITNTTS'
	ElseIf cIdPonto == 'MODELCANCEL'
	ElseIf cIdPonto == 'BUTTONBAR'
	EndIf
 
EndIf
 
Return xRet

User Function MNTA084()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
 
Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
 
 
If aParam <> NIL
      
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3]
	
	If cIdPonto == 'MODELVLDACTIVE'
	ElseIf cIdPonto == 'MODELPOS'
		
		//Validação total do model
		if empty(FwFldGet("T9_ITEMCTA")) .and. FwFldGet("T9_PROPRIE")='1'
			ApMsgInfo('O item contabil deve estar em branco quando for Bem de Terceiro.')
			return .F.
		elseif !empty( FwFldGet("T9_ITEMCTA") ) .and. FwFldGet("T9_PROPRIE") != '1'
			FwFldPut("T9_ITEMCTA", Space(TamSX3("T9_ITEMCTA")[1]))
			ApMsgInfo('O item contabil não deve estar preenchido quando for Bem de Terceiro.')
			return .F.
		elseif empty(FwFldGet("T9_FORNECE")) .and. FwFldGet("T9_PROPRIE") != '1'
			ApMsgInfo('O Fornecedor deve ser informado quando for Bem de Terceiro.')
			return .F.
		endIf
		
	ElseIf cIdPonto == 'FORMPOS'
	ElseIf cIdPonto == 'FORMLINEPRE'
	ElseIf cIdPonto == 'FORMLINEPOS'
	ElseIf cIdPonto == 'MODELCOMMITTTS'
	ElseIf cIdPonto == 'MODELCOMMITNTTS'
	ElseIf cIdPonto == 'MODELCANCEL'
	ElseIf cIdPonto == 'BUTTONBAR'
	EndIf
 
EndIf
 
Return xRet
