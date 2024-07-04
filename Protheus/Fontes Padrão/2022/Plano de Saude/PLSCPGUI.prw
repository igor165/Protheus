User Function PLSCPGUI()
LOCAL cTipGuia 	:= paramixb[1] //"1" //Consulta "2" //Sadt "3" //Internacao "4" //ODontologico
LOCAL cRet		:= ""
If cTipGuia == "2"
	cRet := "cCbosExe" //  campos separados por pipe "|"   contidos nas rotinas PPLSCONS,PPLSSADT,PPLSSOIN,PPLSGTOP
	// ALTERAR PARA NUMERO DO CAMPO DA GUIA   EXEMPLO 45 = CBOS EXECUTANTE E PASSAR COMO ARRAY
ElseIf cTipGuia == "1"
	cRet := "cCbos"
EndIf
Return(cRet)