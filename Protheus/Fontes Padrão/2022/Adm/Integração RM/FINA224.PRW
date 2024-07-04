#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FINA224.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FINA224  ณ Autor ณ Cesar Augusto Bianchi ณ Data ณ 16/04/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObjetivos ณ   Rotina de Encerramento de Operacoes do Caixa-Tesouraria  ณฑฑ
ฑฑณ          ณ*Permite realizar o encerramento de atividades de Caixa/Loteณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FINA224()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAGE/SIGAFIN - Contas a Receber                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Fina224()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Interface graficaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 

	Fn224Wiz()


Return   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Wiz  บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a interface tipo "Wizard" para Encerramento/Reativacaoบฑฑ
ฑฑบ          ณdo caixa.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224Wiz()
Local cPulo 		:= Chr(13) + Chr(10)
Local cPulo2 		:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Private lEncerra    := .F.
Private lAtiva		:= .F.
Private cCxAbr		:= Posicione('FID',1,xFilial('FID')+ __cUserID,'FID_NCAIXA') //Space(TamSx3("FID_NCAIXA")[1])
Private cCodOp		:= Posicione('FID',1,xFilial('FID')+ __cUserID,'FID_USER')   //Space(TamSx3("FID_USER")[1])
Private cNomOp		:= Posicione('FID',1,xFilial('FID')+ __cUserID,'FID_NOME')   //Space(TamSx3("FID_NOME")[1])
Private cCodSup		:= Space(25)
Private cSenSup		:= Space(20)
Private cStatus		:= ""
//Objetos graficos
Private oBoxOpr
Private oBoxCxa
Private oBoxSup
Private oChkEnc
Private oChkAtv
Private oSayDesc
Private oSayCxAbr
Private oSayStat
Private oSayCodOp
Private oSaySuper
Private oSayFinal 
Private oSaySenSup
Private oGetCxa
Private oGetStat
Private oGetCodOp
Private oGetNomOp
Private oGetSenSup
Private oGetCodSup	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto oWizard com o primeiro painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard := APWizard():New(STR0001/*<chTitle>*/, ""/*<chMsg>*/, STR0001/*<cTitle>*/, STR0002 + STR0003 + STR0004 + cPulo2 + STR0005 /*<cText>*/, {||.T. }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o segundo Painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:NewPanel(STR0006/*<chTitle>*/, STR0007/*<chMsg>*/,{ ||.T.}/*<bBack>*/,{|| (lAtiva .or. lEncerra) .and. Fn224Dsp() }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Say "Descricao das operacoes"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayDesc:= TSAY():Create(oWizard:oMPanel[2])
oSayDesc:cName			:= "oSayDesc"
oSayDesc:cCaption 		:= STR0008 + STR0009 + cPulo2 + STR0010 + STR0011 + STR0012
oSayDesc:nLeft 			:= 40
oSayDesc:nTop 			:= 40
oSayDesc:nWidth 	   	:= 510
oSayDesc:nHeight 		:= 100
oSayDesc:lShowHint 		:= .F.
oSayDesc:lReadOnly 		:= .F.
oSayDesc:Align 			:= 0
oSayDesc:lVisibleControl:= .T.
oSayDesc:lWordWrap 	  	:= .F.
oSayDesc:lTransparent 	:= .F.
oSayDesc:nClrText 		:= CLR_BLACK

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Box "Opera็ใo"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBoxOpr:= TGROUP():Create(oWizard:oMPanel[2])
oBoxOpr:cName 	   := "oBoxOpr"
oBoxOpr:cCaption     := STR0013 //"Opera็ใo
oBoxOpr:nLeft 	   := 200
oBoxOpr:nTop  	   := 160
oBoxOpr:nWidth 	   := 180 
oBoxOpr:nHeight 	   := 90
oBoxOpr:lShowHint    := .F.
oBoxOpr:lReadOnly    := .F.
oBoxOpr:Align        := 0
oBoxOpr:lVisibleControl := .T.  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o CheckBox "Encerramento Caixa"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oChkEnc:= TCHECKBOX():Create(oWizard:oMPanel[2])
oChkEnc:cName 		:= "oChkEnc"
oChkEnc:cCaption 	:= STR0014 //"Encerramento de Caixa"
oChkEnc:nLeft 		:= 220
oChkEnc:nTop  		:= 185
oChkEnc:nWidth 		:= 135
oChkEnc:nHeight 	:= 15
oChkEnc:lShowHint 	:= .F.
oChkEnc:lReadOnly 	:= .F.
oChkEnc:Align 		:= 0
oChkEnc:cVariable 	:= "lEncerra"
oChkEnc:bSetGet 	:= {|u| If(PCount()>0,lEncerra:=u,lEncerra)}
oChkEnc:lVisibleControl := .T.
oChkEnc:blClicked  := {|| Fn224Oper('E') }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o CheckBox "Ativa็ใo Caixa"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oChkAtv:= TCHECKBOX():Create(oWizard:oMPanel[2])
oChkAtv:cName 		:= "oChkAtv"
oChkAtv:cCaption 	:= STR0015 //"Ativacao de Caixa"
oChkAtv:nLeft 		:= 220
oChkAtv:nTop  		:= 215
oChkAtv:nWidth 		:= 135
oChkAtv:nHeight 	:= 15
oChkAtv:lShowHint 	:= .F.
oChkAtv:lReadOnly 	:= .F.
oChkAtv:Align 		:= 0
oChkAtv:cVariable 	:= "lAtiva"
oChkAtv:bSetGet 	:= {|u| If(PCount()>0,lAtiva:=u,lAtiva)}
oChkAtv:lVisibleControl := .T.
oChkAtv:blClicked  := {|| Fn224Oper('A') }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o terceiro Painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:NewPanel(STR0016/*<chTitle>*/, STR0018 /*<chMsg>*/,{ ||.T.}/*<bBack>*/,{|| Fn224CxOk() .and. Fn224SenOk() .and. Fn224Sint() }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Box "Dados do Caixa"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBoxCxa:= TGROUP():Create(oWizard:oMPanel[3])
oBoxCxa:cName 	   := "oBoxCxa"
oBoxCxa:cCaption     := STR0019 //"Dados do caixa a ser encerrado/re-ativo
oBoxCxa:nLeft 	   := 50
oBoxCxa:nTop  	   := 30
oBoxCxa:nWidth 	   := 460 
oBoxCxa:nHeight 	   := 100
oBoxCxa:lShowHint    := .F.
oBoxCxa:lReadOnly    := .F.
oBoxCxa:Align        := 0
oBoxCxa:lVisibleControl := .T. 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Say - Selecione o Caixa     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayCxAbr:= TSAY():Create(oWizard:oMPanel[3])
oSayCxAbr:cName				:= "oSayCxAbr"
oSayCxAbr:cCaption 			:= STR0023 //"Cod Caixa:"
oSayCxAbr:nLeft 			:= 60
oSayCxAbr:nTop 				:= 60
oSayCxAbr:nWidth 	   		:= 100
oSayCxAbr:nHeight 			:= 15
oSayCxAbr:lShowHint 		:= .F.
oSayCxAbr:lReadOnly 		:= .F.
oSayCxAbr:Align 			:= 0
oSayCxAbr:lVisibleControl	:= .T.
oSayCxAbr:lWordWrap 	  	:= .F.
oSayCxAbr:lTransparent 		:= .F.
oSayCxAbr:nClrText 			:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a get "Selecione o caixa"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetCxa:= TGET():Create(oWizard:oMPanel[3])
oGetCxa:cName 	 		:= "oGetCxa"
oGetCxa:nLeft 	 		:= 120
oGetCxa:nTop 	 		:= 58
oGetCxa:nWidth 	 		:= 95
oGetCxa:nHeight 	 	:= 20
oGetCxa:lShowHint 		:= .F.
oGetCxa:lReadOnly 		:= .F.
oGetCxa:Align 	 		:= 0
oGetCxa:lVisibleControl := .T.
oGetCxa:lPassword 		:= .F.
oGetCxa:lHasButton		:= .F.
oGetCxa:cVariable 		:= "cCxAbr"
oGetCxa:bSetGet 	 	:= {|u| If(PCount()>0,cCxAbr:=u,cCxAbr)}
oGetCxa:Picture   		:= "@!"
oGetCxa:bWhen     		:= {|| .F. }
oGetCxa:cF3				:= "SA6_CX"
oGetCxa:bChange			:= {|| Fn224LCxa() }
oGetCxa:bValid			:= {|| .T. } 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Say - Status Caixa     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayStat:= TSAY():Create(oWizard:oMPanel[3])
oSayStat:cName				:= "oSayStat"
oSayStat:cCaption 			:= STR0027 //Status
oSayStat:nLeft 				:= 230
oSayStat:nTop 				:= 60
oSayStat:nWidth 	   		:= 100
oSayStat:nHeight 			:= 15
oSayStat:lShowHint 			:= .F.
oSayStat:lReadOnly 			:= .F.
oSayStat:Align 				:= 0
oSayStat:lVisibleControl	:= .T.
oSayStat:lWordWrap 	  		:= .F.
oSayStat:lTransparent 		:= .F.
oSayStat:nClrText 			:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a get "Status caixa"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetStat:= TGET():Create(oWizard:oMPanel[3])
oGetStat:cName 	 		:= "oGetCxa"
oGetStat:nLeft 	 		:= 270
oGetStat:nTop 	 		:= 58
oGetStat:nWidth 	 	:= 225
oGetStat:nHeight 	 	:= 20
oGetStat:lShowHint 		:= .F.
oGetStat:lReadOnly 		:= .F.
oGetStat:Align 	 		:= 0
oGetStat:lVisibleControl := .T.
oGetStat:lPassword 		:= .F.
oGetStat:lHasButton		:= .F.
oGetStat:cVariable 		:= "cStatus"
oGetStat:bSetGet 	 	:= {|u| If(PCount()>0,cStatus:=u,cStatus)}
oGetStat:Picture   		:= "@!"
oGetStat:bWhen     		:= {|| .F. }
oGetStat:bChange		:= {|| }
oGetStat:bValid			:= {|| .T. } 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Say - Codigo Operador    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayCodOp:= TSAY():Create(oWizard:oMPanel[3])
oSayCodOp:cName				:= "oSayCodOp"
oSayCodOp:cCaption 			:= STR0024 //"Cod Caixa:"
oSayCodOp:nLeft 			:= 60
oSayCodOp:nTop 				:= 90
oSayCodOp:nWidth 	   		:= 100
oSayCodOp:nHeight 			:= 15
oSayCodOp:lShowHint 		:= .F.
oSayCodOp:lReadOnly 		:= .F.
oSayCodOp:Align 			:= 0
oSayCodOp:lVisibleControl	:= .T.
oSayCodOp:lWordWrap 	  	:= .F.
oSayCodOp:lTransparent 		:= .F.
oSayCodOp:nClrText 			:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a get Codigo Operador ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetCodOp:= TGET():Create(oWizard:oMPanel[3])
oGetCodOp:cName 	 		:= "oGetCodOp"
oGetCodOp:nLeft 	 		:= 135
oGetCodOp:nTop 	 	  		:= 88
oGetCodOp:nWidth 	 		:= 80
oGetCodOp:nHeight 	   		:= 20
oGetCodOp:lShowHint 		:= .F.
oGetCodOp:lReadOnly 		:= .F.
oGetCodOp:Align 	 		:= 0
oGetCodOp:lVisibleControl 	:= .T.
oGetCodOp:lPassword 		:= .F.
oGetCodOp:lHasButton		:= .F.
oGetCodOp:cVariable 		:= "cCodOp"
oGetCodOp:bSetGet 	  		:= {|u| If(PCount()>0,cCodOp:=u,cCodOp)}
oGetCodOp:Picture   		:= "@!"
oGetCodOp:bWhen     		:= {|| .F. }
oGetCodOp:bChange			:= {|| }
oGetCodOp:bValid			:= {|| .T. }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Say - Nome Operador    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayNomOp:= TSAY():Create(oWizard:oMPanel[3])
oSayNomOp:cName				:= "oSayNomOp"
oSayNomOp:cCaption 			:= STR0025 //"Nome Op"
oSayNomOp:nLeft 			:= 230
oSayNomOp:nTop 				:= 90
oSayNomOp:nWidth 	   		:= 100
oSayNomOp:nHeight 			:= 15
oSayNomOp:lShowHint 		:= .F.
oSayNomOp:lReadOnly 		:= .F.
oSayNomOp:Align 			:= 0
oSayNomOp:lVisibleControl	:= .T.
oSayNomOp:lWordWrap 	  	:= .F.
oSayNomOp:lTransparent 		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a get Codigo Operador ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetNomOp:= TGET():Create(oWizard:oMPanel[3])
oGetNomOp:cName 	 		:= "oGetNomOp"
oGetNomOp:nLeft 	 		:= 265
oGetNomOp:nTop 	 	  		:= 88
oGetNomOp:nWidth 	 		:= 230
oGetNomOp:nHeight 	   		:= 20
oGetNomOp:lShowHint 		:= .F.
oGetNomOp:lReadOnly 		:= .F.
oGetNomOp:Align 	 		:= 0
oGetNomOp:lVisibleControl 	:= .T.
oGetNomOp:lPassword 		:= .F.
oGetNomOp:lHasButton		:= .F.
oGetNomOp:cVariable 		:= "cNomOp"
oGetNomOp:bSetGet 	  		:= {|u| If(PCount()>0,cNomOp:=u,cNomOp)}
oGetNomOp:Picture   		:= "@!"
oGetNomOp:bWhen     		:= {|| .F. }
oGetNomOp:bChange			:= {|| }
oGetNomOp:bValid			:= {|| .T. }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Box "Dados do Supervisor"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBoxSup:= TGROUP():Create(oWizard:oMPanel[3])
oBoxSup:cName 	   := "oBoxSup"
oBoxSup:cCaption     := STR0022 //Dados do usuแrio-supervisor
oBoxSup:nLeft 	   := 50
oBoxSup:nTop  	   := 150
oBoxSup:nWidth 	   := 460 
oBoxSup:nHeight 	   := 60
oBoxSup:lShowHint    := .F.
oBoxSup:lReadOnly    := .F.
oBoxSup:Align        := 0
oBoxSup:lVisibleControl := .T.  
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Say - Cod. Supervisor       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSaySuper:= TSAY():Create(oWizard:oMPanel[3])
oSaySuper:cName				:= "oSaySuper"
oSaySuper:cCaption 			:= STR0028 //"C๓d Supervisor: "
oSaySuper:nLeft 			:= 60
oSaySuper:nTop 				:= 177
oSaySuper:nWidth 	   		:= 130
oSaySuper:nHeight 			:= 15
oSaySuper:lShowHint 		:= .F.
oSaySuper:lReadOnly 		:= .F.
oSaySuper:Align 			:= 0
oSaySuper:lVisibleControl	:= .T.
oSaySuper:lWordWrap 	  	:= .F.
oSaySuper:lTransparent 		:= .F.
oSaySuper:nClrText 			:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o objeto Get "Cod Supervisor"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetCodSup:= TGET():Create(oWizard:oMPanel[3])
oGetCodSup:cName 	 		:= "oGetCodSup"
oGetCodSup:nLeft 	 		:= 140
oGetCodSup:nTop 	 		:= 175
oGetCodSup:nWidth 	 		:= 80
oGetCodSup:nHeight 	 		:= 20
oGetCodSup:lShowHint 		:= .F.
oGetCodSup:lReadOnly 		:= .F.
oGetCodSup:Align 	 		:= 0
oGetCodSup:lVisibleControl 	:= .T.
oGetCodSup:lPassword 		:= .F.
oGetCodSup:lHasButton		:= .F.
oGetCodSup:cVariable 		:= "cCodSup"
oGetCodSup:cF3       		:= "FID"
oGetCodSup:bSetGet 	 		:= {|u| If(PCount()>0,cCodSup:=u,cCodSup)}
oGetCodSup:Picture   		:= "@!"
oGetCodSup:bWhen     		:= {|| .T. }
oGetCodSup:bChange			:= {||  }
oGetCodSup:bValid			:= {|| .T. }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a legenda "Senha"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSaySenSup:= TSAY():Create(oWizard:oMPanel[3])
oSaySenSup:cName			:= "oSaySenSup"
oSaySenSup:cCaption 		:= STR0029 //Senha
oSaySenSup:nLeft 			:= 250
oSaySenSup:nTop 			:= 177
oSaySenSup:nWidth 	   		:= 80
oSaySenSup:nHeight 			:= 15
oSaySenSup:lShowHint 		:= .F.
oSaySenSup:lReadOnly 		:= .F.
oSaySenSup:Align 			:= 0
oSaySenSup:lVisibleControl	:= .T.
oSaySenSup:lWordWrap 	  	:= .F.
oSaySenSup:lTransparent 	:= .F.
oSaySenSup:nClrText 		:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Get "Senha Sup"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetSenSup:= TGET():Create(oWizard:oMPanel[3])
oGetSenSup:cName 	 		:= "oGetCodSup"
oGetSenSup:nLeft 	 		:= 290
oGetSenSup:nTop 	 		:= 175
oGetSenSup:nWidth 	 		:= 80
oGetSenSup:nHeight 	 		:= 20
oGetSenSup:lShowHint 		:= .F.
oGetSenSup:lReadOnly 		:= .F.
oGetSenSup:Align 	 		:= 0
oGetSenSup:lVisibleControl 	:= .T.
oGetSenSup:lPassword 		:= .F.
oGetSenSup:lHasButton		:= .F.
oGetSenSup:cVariable 		:= "cSenSup"
oGetSenSup:bSetGet 	 		:= {|u| If(PCount()>0,cSenSup:=u,cSenSup)}
oGetSenSup:bWhen     		:= {|| .T.}
oGetSenSup:bChange			:= {|| }
oGetSenSup:bValid			:= {|| .T. }
oGetSenSup:lPassword        := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Quarto Painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:NewPanel(STR0030/*<chTitle>*/, STR0031+STR0032 /*<chMsg>*/,{ ||.T.}/*<bBack>*/,{|| .T. }/*<bNext>*/, {|| Fn224Fim()}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a legenda "Senha"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSayFinal:= TSAY():Create(oWizard:oMPanel[4])
oSayFinal:cName				:= "oSayFinal"
oSayFinal:cCaption 			:= "" 
oSayFinal:nLeft 			:= 40
oSayFinal:nTop 				:= 40
oSayFinal:nWidth 	   		:= 350
oSayFinal:nHeight 			:= 200
oSayFinal:lShowHint 		:= .F.
oSayFinal:lReadOnly 		:= .F.
oSayFinal:Align 			:= 0
oSayFinal:lVisibleControl	:= .T.
oSayFinal:lWordWrap 	  	:= .F.
oSayFinal:lTransparent 		:= .F.
oSayFinal:nClrText 		:= CLR_HBLUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o status do caixaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Fn224LCxa()
oGetStat:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExibe o objeto oWizard apos montar todos seus paineisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Oper บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte a marca das opcoes presentes no box "Operacoes"     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Fn224Oper(cOper)

if cOper == 'E'
	lEncerra := .T.
	lAtiva := .F.
elseif cOper == 'A'
	lEncerra := .F.
	lAtiva := .T.
endif     

oChkEnc:Refresh()
oChkAtv:Refresh()  

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224LCxa บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a situacao do caixa selecionado, o codigo e nome do บฑฑ
ฑฑบ          ณoperador responsavel.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224LCxa()
Local cQuery := ""
Local nRecno  := 0

if !empty(cCxAbr)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona no ultimo registro de abertura do caixa selecionadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CursorWait()
	cQuery := " SELECT FIB.FIB_USER CUSER, FID.FID_NOME NOME, FIB.FIB_ENCER, FIB.FIB_DTFCH, FIB.R_E_C_N_O_ RECN FROM " 
	cQuery += retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
	cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
	cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
	cQuery += " 	AND FID.FID_NCAIXA = '" + cCxAbr + "'"
	cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
	cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FIB.FIB_DTABR ASC, FIB.FIB_HRABR ASC "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	While SQL->(!Eof())
		nRecno := SQL->RECN
		cCodOp := alltrim(SQL->CUSER)	
		cNomOp := alltrim(SQL->NOME)
		SQL->(dbSkip())
	EndDo
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbSelectArea('FIB')
	FIB->(dbGoTo(nRecno))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณColeta a situacao do caixaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if !Empty(FIB->FIB_DTFCH)
		cStatus := "FECHADO"
	elseif Empty(FIB->FIB_DTFCH) .and. alltrim(FIB->FIB_ENCER) == '1'
		cStatus := "ENCERRADO, AGUARDANDO FECHAMENTO"
	elseif Empty(FIB->FIB_DTFCH) .and. alltrim(FIB->FIB_ENCER) == '2'
		cStatus := "ATIVO"
	endif
else
	cCodOp := ""
	cNomOp := ""
	cStatus:= "" 
endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os objetos graficosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Fn224Atu()

CursorArrow()
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Dsp  บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe ou oculta os objetos graficos do painel III conforme aบฑฑ
ฑฑบ          ณoperacao escolhida pelo usuario.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224Dsp()

if lEncerra
	oBoxCxa:cCaption := STR0019 + STR0020
	oBoxSup:lVisible := .F. 	
	oGetSenSup:lVisible := .F. 	
	oSaySenSup:lVisible := .F. 	
	oSaySuper:lVisible := .F. 	
	oGetCodSup:lVisible := .F. 	
else
	oBoxCxa:cCaption := STR0019 + STR0021
	oBoxSup:lVisible := .T.
	oGetSenSup:lVisible := .T.
	oSaySenSup:lVisible := .T.
	oSaySuper:lVisible := .T.
	oGetCodSup:lVisible := .T.
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os objetos graficosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Fn224Atu()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224CxOk บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o caixa selecionado 								  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224CxOk()
Local lRet := .T.
Local cQuery := ""
Local cEncer := ""
Local cFech  := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for encerramentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lEncerra
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se o caixa foi preenchidoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if !Empty(cCxAbr)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se o caixa preenchido existe como conta caixaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Fn222ValCx(cCxAbr)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida se o caixa esta ativoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery := " SELECT FIB.FIB_DTFCH FECHADO, FIB.FIB_ENCER ENCERRADO, FIB.R_E_C_N_O_ RECN FROM " 
			cQuery += retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
			cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
			cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
			cQuery += " 	AND FID.FID_NCAIXA = '" + cCxAbr + "'"
			cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
			cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
			cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY FIB.FIB_DTABR ASC, FIB.FIB_HRABR ASC "
			cQuery := ChangeQuery(cQuery)
			iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
			While SQL->(!Eof())
				cFech  := SQL->FECHADO
				cEncer := SQL->ENCERRADO
				SQL->(dbSkip())
			EndDo
			
			If !Empty(cFech) .or. cEncer == '1'
				Aviso(STR0039,STR0040,{STR0038}) 	//O Caixa selecionado nใo encontra-se atualmente em estado ATIVO, portanto nใo pode ser encerrado.	
				lRet := .F.
			endif
		else
		   	Aviso(STR0039,STR0041,{STR0038}) 		//O Caixa informado nใo existe no cadastro de contas caixas
		   	lRet := .F.
		endif
	else
		Aviso(STR0036,STR0037,{STR0038})  			//Selecione um caixa vแlido antes de prosseguir com esta opera็ใo
		lRet := .F.
	endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for Re-Ativacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se o caixa foi preenchidoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if !Empty(cCxAbr)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se o caixa preenchido existe como conta caixaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Fn222ValCx(cCxAbr)
		 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida se o caixa esta ativoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery := " SELECT FIB.FIB_DTFCH FECHADO, FIB.FIB_ENCER ENCERRADO, FIB.R_E_C_N_O_ RECN FROM " 
			cQuery += retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
			cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
			cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
			cQuery += " 	AND FID.FID_NCAIXA = '" + cCxAbr + "'"
			cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
			cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
			cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY FIB.FIB_DTABR ASC, FIB.FIB_HRABR ASC "
			cQuery := ChangeQuery(cQuery)
			iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
			While SQL->(!Eof())
				cFech  := SQL->FECHADO
				cEncer := SQL->ENCERRADO
				SQL->(dbSkip())
			EndDo
			
			If !Empty(cFech) .or. cEncer == '2'
				Aviso(STR0039,STR0048,{STR0038}) 	//O Caixa selecionado nใo encontra-se atualmente em estado ATIVO, portanto nใo pode ser encerrado.	
				lRet := .F.
			endif
		else
		   	Aviso(STR0039,STR0041,{STR0038}) 		//O Caixa informado nใo existe no cadastro de contas caixas
		   	lRet := .F.
		endif
	else
		Aviso(STR0036,STR0037,{STR0038})  			//Selecione um caixa vแlido antes de prosseguir com esta opera็ใo
		lRet := .F.
	endif
endif

iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224SenOkบAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a senha de supervisor conforme o arquivo de senhas doบฑฑ
ฑฑบ          ณmicrosiga Protheus Remote.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224SenOk()
Local lRet := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida senha somente se for Re-Ativacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lAtiva

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se o supervisor existe na FIDณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if Fn222ValSp(cCodSup)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se o supervisor nao esta bloqueadoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Posicione('FID',1,xFilial('FID')+cCodSup,'FID_BLOQ') == '2'
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida a senha do supervisorณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			PswOrder(1) 					//Ordena a busca por  Nome do usuario/grupo
			If PswSeek(cCodSup,.T.)			//Posiciona no Cod Usuario informado
				if !PswName(cSenSup)		//Retorna True se senha passada como parametro for igual a senha do nome posicionado acima
					Aviso(STR0042,STR0043,{STR0038}) 	//A digitada nใo corresponde a senha do supervisor selecionado
					lRet := .F.
				endif
			else
				Aviso(STR0044,STR0045,{STR0038}) 		//O Usuario digitado nao consta no cadastro de usuarios do Protheus
				lRet := .F.
			endif
		else
		   Aviso(STR0049,STR0050,{STR0038})			//Usuario bloqueado
		   lRet := .F.
		endif
	else
		Aviso(STR0046,STR0047,{STR0038})  			//O Cod de Supervisor digitado nใo ้ um c๓digo de supervisor valido.
		lRet := .F.
	endif
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Sint บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o texto sintese exibido no ultimo painel.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224Sint()
Local cPula1 := CHR(13) + CHR(10)
Local cPula2 := CHR(13) + CHR(10) + CHR(13) + CHR(10)
Local cAux 	 := ""

cAux := "OPERAวรO: " + iif(lAtiva," Re-ativa็ใo de Caixa","Encerramento de Caixa") + cPula1
cAux += "CAIXA: " + cCxAbr  + cPula1
cAux += "DATA: " +  DTOC(dDataBase) + cPula1
cAux += "HORA: " +  Time() + cPula1
cAux += "CำD. OPERADOR RESPONSมVEL: " + cCodOp + cPula1
cAux += "NOME OPERADOR RESPONSมVEL: " + cNomOp + cPula1
if lAtiva
	cAux += "CำD. SUPERVISOR RESPONSมVEL: " +  cCodSup + cPula1
	cAux += "NOME SUPERVISOR RESPONSมVEL: " +  alltrim(Posicione('FID',1,xFilial('FID')+cCodSup,"FID_NOME")) + cPula1
endif
cAux += cPula2
cAux += "Certifique-se de que os dados apresentados estใo corretos."
cAux += "Para confirmar e concluir o procedimento, clique em <Finalizar>"

oSayFinal:cCaption 	:= cAux
oSayFinal:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Fim  บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFinaliza a rotina de Encerramento/Re-ativacao, gravando os  บฑฑ
ฑฑบ          ณdados necessarios                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224Fim()
Local nRecno := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona na FIBณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := " SELECT FIB.R_E_C_N_O_ RECN FROM "
cQuery += retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND FID.FID_NCAIXA = '" + cCxAbr + "'"
cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY FIB.FIB_DTABR ASC, FIB.FIB_HRABR ASC "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
While SQL->(!Eof())
	nRecno := SQL->RECN
	SQL->(dbSkip())
EndDo

dbSelectArea('FIB')
FIB->(dbGoTo(nRecno))

RecLock('FIB',.F.)
FIB->FIB_ENCER := iif(lAtiva,'2','1')
FIB->(msUnlock())

iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN224Atu  บAutor  ณCesar A. Bianchi    บ Data ณ  17/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta refresh dos objetos graficos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP811/912 - Integracao Protheus x Classis .NET             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Fn224Atu()

oBoxOpr:Refresh()
oBoxCxa:Refresh()
oBoxSup:Refresh()
oChkEnc:Refresh()
oChkAtv:Refresh()
oSayDesc:Refresh()
oSayCxAbr:Refresh()
oSayStat:Refresh()
oSayCodOp:Refresh()
oSaySuper:Refresh()
oSayFinal:Refresh()
oSaySenSup:Refresh()
oGetCxa:Refresh()
oGetStat:Refresh()
oGetCodOp:Refresh()
oGetNomOp:Refresh()
oGetSenSup:Refresh()
oGetCodSup:Refresh()

Return
