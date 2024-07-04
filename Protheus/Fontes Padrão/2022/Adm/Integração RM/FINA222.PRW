#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FINA222.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA222  ³ Autor ³ Cesar Augusto Bianchi ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivos ³     Rotina de Abertura/Fechamento de Caixa-Tesouraria 	  ³±±
±±³          ³*Permite realizar a abertura/fechamento de um ou mais caixas³±±
±±³          ³(FINA220) atraves das permissoes concedidas ao usuario loga-³±±
±±³          ³do ou ao usuario Supervisor de caixa.                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA222()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FINA222()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Interface grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

Fn220Wiz()

 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222Wiz  ºAutor  ³Cesar A. Bianchi    º Data ³  18/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a interface grafica tipo "Wizard" para auxiliar o usuaº±±
±±º          ³rio a realizar a abertuta/Fechamento de Caixa.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn220Wiz()

Local cTextoIni := ""
Private	nHdlECF  := 1
Private lAbre  := .F.
Private lFecha := .F.
Private lOpera := .F.
Private lSuper := .F.
Private lSangria := .T.
Private lImpRes := .T.
Private cCodSup := Space(25)
Private cNomSup := Space(40)
Private cSenSup := Space(20)
Private cCxAbr  := Space(TamSx3('A1_COD')[1])
Private nTroco  := 0

Private cUser 	  := ""
Private cCodConta := ""
Private cLote     := ""

Private nRDN  := 0
Private nRCH  := 0
Private nRCC  := 0
Private nRCD  := 0
Private nRNC  := 0
Private nPDN  := 0
Private nPCH  := 0
Private nPCC  := 0
Private nPCD  := 0
Private nPNC  := 0
Private nDDN  := 0
Private nDCH  := 0
Private nDCC  := 0
Private nDCD  := 0 
Private nDNC  := 0 
 
//Declaracao dos objetos graficos
Private oWizard          		//Objeto grafico tipo "Wizard" - Menu Principal
Private oBoxPar					//Objeto grafico tipo "Box" - 
Private oBoxSup					//Objeto grafico tipo "Box" -  
Private oBoxUsr					//Objeto grafico tipo "Box" - 
Private oBoxTp					//Objeto grafico tipo "Box" - 
Private oBoxAbr					//Objeto grafico tipo "Box" - 
Private oBoxVlrE				//Objeto grafico tipo "Box" - 
Private oBoxVlrR				//Objeto grafico tipo "Box" - 
Private oBoxVlrD				//Objeto grafico tipo "Box" - 
Private oBoxOpc					//Objeto grafico tipo "Box" - 
Private oFontBold				//Objeto grafico tipo "Font" - Fonte Negrito
Private oFontNorm				//Objeto grafico tipo "Font" - Fonte Normal
Private oFontMin				//Objeto grafico tipo "Font" - Fonte tamanho reduzido
Private oSayUsuario				//Objeto grafico tipo "Say" - Cod. Usuario
Private oSayTpOpera				//Objeto grafico tipo "Say" - Tipo de Operacao
Private oSayDesc				//Objeto grafico tipo "Say" - Descricao
Private oSayDtSup				//Objeto grafico tipo "Say" - Detalhes Superior
Private oSaySuper				//Objeto grafico tipo "Say" - Usuario Supervisor
Private oSayNomSup				//Objeto grafico tipo "Say" - Nome Supervisor
Private oSaySenSup				//Objeto grafico tipo "Say" - Senha Supervisor
Private oSayCxAbr				//Objeto grafico tipo "Say" - Caixa a ser aberto/fechado
Private oSayDtUsu				//Objeto grafico tipo "Say" - Detalhes do Usuario
Private oSayDetTro				//Objeto grafico tipo "Say" - Detalhes Troco
Private oSayTroco				//Objeto grafico tipo "Say" - Valor Troco
Private oSayMapRes				//Objeto grafico tipo "Say" - Detalhes Mapa Resumo
Private oSayRDN					//Objeto grafico tipo "Say" - Valor Efetivo em Dinheiro
Private oSayRCH					//Objeto grafico tipo "Say" - Valor Efetivo em Cheques
Private oSayRCC					//Objeto grafico tipo "Say" - Valor Efetivo em Cartao Credito
Private oSayRCD					//Objeto grafico tipo "Say" - Valor Efetivo em Cartao Debito
Private oSayRNC					//Objeto grafico tipo "Say" - Valor Efetivo em NCC
Private oSayInfo				//Objeto grafico tipo "Say" - Detalhes do valor efetivo em dinheiro
Private oSayPDN					//Objeto grafico tipo "Say" - Valor Presente em Dinheiro
Private oSayPCH					//Objeto grafico tipo "Say" - Valor Presente em Cheques
Private oSayPCC					//Objeto grafico tipo "Say" - Valor Presente em Cartao Credito
Private oSayPCD					//Objeto grafico tipo "Say" - Valor Presente em Cartao Debito
Private oSayPNC					//Objeto grafico tipo "Say" - Valor Presente em NCC
Private oSayDDN					//Objeto grafico tipo "Say" - Valor Diferenca em Dinheiro
Private oSayDCH					//Objeto grafico tipo "Say" - Valor Diferenca em Cheques
Private oSayDCC					//Objeto grafico tipo "Say" - Valor Diferenca em Cartao Credito
Private oSayDCD					//Objeto grafico tipo "Say" - Valor Diferenca em Cartao Debito
Private oSayDNC					//Objeto grafico tipo "Say" - Valor Diferenca em NCC
Private oChkAbre				//Objeto grafico tipo "Check" - CheckBox abrir Caixa
Private oChkFecha				//Objeto grafico tipo "Check" - CheckBox fechar Caixa
Private oChkSangria				//Objeto grafico tipo "Check" - 
Private oChkImpRes				//Objeto grafico tipo "Check" - 
Private oChkOpera				//Objeto grafico tipo "Check" - 
Private oChkSuper				//Objeto grafico tipo "Check" - 
Private oGetCodSup				//Objeto grafico tipo "oGet" - 
Private oGetNomSup				//Objeto grafico tipo "oGet" - 
Private oGetSenSup				//Objeto grafico tipo "oGet" - 
Private oGetCxa					//Objeto grafico tipo "oGet" - 
Private oGetTroco				//Objeto grafico tipo "oGet" - 
Private oGetRDN					//Objeto grafico tipo "oGet" - 
Private oGetRCH					//Objeto grafico tipo "oGet" - 
Private oGetRCC					//Objeto grafico tipo "oGet" - 
Private oGetRCD					//Objeto grafico tipo "oGet" - 
Private oGetRNC					//Objeto grafico tipo "oGet" - 
Private oGetPDN					//Objeto grafico tipo "oGet" - 
Private oGetPCH					//Objeto grafico tipo "oGet" - 
Private oGetPCC					//Objeto grafico tipo "oGet" - 
Private oGetPCD					//Objeto grafico tipo "oGet" - 
Private oGetPNC					//Objeto grafico tipo "oGet" - 
Private oGetDDN					//Objeto grafico tipo "oGet" - 
Private oGetDCH					//Objeto grafico tipo "oGet" - 
Private oGetDCC					//Objeto grafico tipo "oGet" - 
Private oGetDCD					//Objeto grafico tipo "oGet" - 
Private oGetDNC					//Objeto grafico tipo "oGet" - 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta as fontes utilizadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Define FONT oFontBold NAME "Arial" SIZE 7, 15  BOLD
Define FONT oFontNorm NAME "Arial" SIZE 7, 15  
Define FONT oFontMin NAME "Arial" SIZE 5 , 10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o texto inicial a ser exbido no Painel 1 da wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTextoIni := STR0001 + chr(13)+chr(10)
cTextoIni += STR0002 + chr(13)+chr(10)
cTextoIni += chr(13)+chr(10)
cTextoIni += STR0003 + chr(13)+chr(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto oWizard com o primeiro painel³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard := APWizard():New(STR0004/*<chTitle>*/, ""/*<chMsg>*/, STR0005/*<cTitle>*/, cTextoIni/*<cText>*/, {||  Fn220ValTl("TELA01")}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box "Selecione"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxPar:= TGROUP():Create(oWizard:oMPanel[1])
oBoxPar:cName 	   := "oBoxPar"
oBoxPar:cCaption   := STR0006 //"Parametros"
oBoxPar:nLeft 	   := 130
oBoxPar:nTop  	   := 170
oBoxPar:nWidth 	   := 320 
oBoxPar:nHeight    := 70
oBoxPar:lShowHint  := .F.
oBoxPar:lReadOnly  := .F.
oBoxPar:Align      := 0
oBoxPar:lVisibleControl := .T.      


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Data"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTpOpera:= TSAY():Create(oWizard:oMPanel[1])
oSayTpOpera:cName			:= "oSayTpOpera"
oSayTpOpera:cCaption 		:= STR0007 //"Procedimento:"
oSayTpOpera:nLeft 			:= 180
oSayTpOpera:nTop 			:= 188
oSayTpOpera:nWidth 	   		:= 130
oSayTpOpera:nHeight 		:= 15
oSayTpOpera:lShowHint 		:= .F.
oSayTpOpera:lReadOnly 		:= .F.
oSayTpOpera:Align 			:= 0
oSayTpOpera:lVisibleControl	:= .T.
oSayTpOpera:lWordWrap 	  	:= .F.
oSayTpOpera:lTransparent 	:= .F.
oSayTpOpera:nClrText 		:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto checkBox "Abertura de Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkAbre:= TCHECKBOX():Create(oWizard:oMPanel[1])
oChkAbre:cName 		:= "oChkAbre"
oChkAbre:cCaption 	:= STR0008 //"Abertura de Caixa"
oChkAbre:nLeft 		:= 270
oChkAbre:nTop  		:= 185
oChkAbre:nWidth 	:= 130
oChkAbre:nHeight 	:= 15
oChkAbre:lShowHint 	:= .F.
oChkAbre:lReadOnly 	:= .F.
oChkAbre:Align 		:= 0
oChkAbre:cVariable 	:= "lAbre"
oChkAbre:bSetGet 	:= {|u| If(PCount()>0,lAbre:=u,lAbre) }
oChkAbre:lVisibleControl := .T.
oChkAbre:blClicked  := {|| FN222Check('A') }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto checkBox "Fechamento de Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkFecha:= TCHECKBOX():Create(oWizard:oMPanel[1])
oChkFecha:cName 		:= "oChkAbre"
oChkFecha:cCaption 		:= STR0009 //"Fechamento de Caixa"
oChkFecha:nLeft 		:= 270
oChkFecha:nTop  		:= 210
oChkFecha:nWidth 		:= 130
oChkFecha:nHeight 		:= 15
oChkFecha:lShowHint 	:= .F.
oChkFecha:lReadOnly 	:= .F.
oChkFecha:Align 		:= 0
oChkFecha:cVariable 	:= "lFecha"
oChkFecha:bSetGet 		:= {|u| If(PCount()>0,lFecha:=u,lFecha) }
oChkFecha:lVisibleControl := .T.
oChkFecha:blClicked  := {|| FN222Check('F') }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o painel II ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0005/*<chTitle>*/, STR0010 /*<chMsg>*/,{ ||.T.}/*<bBack>*/,{|| Fn220ValTl("TELA02") }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto "Say" - Desc Tipo de Usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTextoIni := STR0011 + chr(13)+chr(10) + chr(13)+chr(10)
cTextoIni += STR0012 + chr(13)+chr(10)
cTextoIni += STR0013
oSayDesc:= TSAY():Create(oWizard:oMPanel[2])
oSayDesc:cName			:= "oSayDesc"
oSayDesc:cCaption 		:= cTextoIni
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box "Selecione"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxTp:= TGROUP():Create(oWizard:oMPanel[2])
oBoxTp:cName 	   := "oBoxTp"
oBoxTp:cCaption     := STR0006 //"Parametros"
oBoxTp:nLeft 	   := 170
oBoxTp:nTop  	   := 170
oBoxTp:nWidth 	   := 250
oBoxTp:nHeight 	   := 70
oBoxTp:lShowHint    := .F.
oBoxTp:lReadOnly    := .F.
oBoxTp:Align        := 0
oBoxTp:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto "Say" - Realizado por ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayUsuario:= TSAY():Create(oWizard:oMPanel[2])
oSayUsuario:cName			:= "oSayUsuario"
oSayUsuario:cCaption 		:= STR0014 //"Realizado Por: "
oSayUsuario:nLeft 			:= 180
oSayUsuario:nTop 			:= 188
oSayUsuario:nWidth 	   		:= 130
oSayUsuario:nHeight 		:= 15
oSayUsuario:lShowHint 		:= .F.
oSayUsuario:lReadOnly 		:= .F.
oSayUsuario:Align 			:= 0
oSayUsuario:lVisibleControl	:= .T.
oSayUsuario:lWordWrap 	  	:= .F.
oSayUsuario:lTransparent 	:= .F.
oSayUsuario:nClrText 		:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto checkBox "Operador"         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkOpera:= TCHECKBOX():Create(oWizard:oMPanel[2])
oChkOpera:cName 		:= "oChkOpera"
oChkOpera:cCaption 		:= STR0015 //"Operador Simples"
oChkOpera:nLeft 		:= 270
oChkOpera:nTop  		:= 185
oChkOpera:nWidth 		:= 130
oChkOpera:nHeight 		:= 15
oChkOpera:lShowHint 	:= .F.
oChkOpera:lReadOnly 	:= .F.
oChkOpera:Align 		:= 0
oChkOpera:cVariable 	:= "lOpera"
oChkOpera:bSetGet 		:= {|u| If(PCount()>0,lOpera:=u,lOpera) }
oChkOpera:lVisibleControl := .T.
oChkOpera:blClicked  	:= {|| FN222Check('O') }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto checkBox "Supervisor"       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkSuper:= TCHECKBOX():Create(oWizard:oMPanel[2])
oChkSuper:cName 		:= "oChkSuper"
oChkSuper:cCaption 		:= STR0016 //"Operador Supervisor"
oChkSuper:nLeft 		:= 270
oChkSuper:nTop  		:= 210
oChkSuper:nWidth 		:= 130
oChkSuper:nHeight 		:= 15
oChkSuper:lShowHint 	:= .F.
oChkSuper:lReadOnly 	:= .F.
oChkSuper:Align 		:= 0
oChkSuper:cVariable 	:= "lSuper"
oChkSuper:bSetGet 		:= {|u| If(PCount()>0,lSuper:=u,lSuper) }
oChkSuper:lVisibleControl := .T.
oChkSuper:blClicked  	:= {|| FN222Check('S') }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o painel III³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0005/*<chTitle>*/, STR0017 /*<chMsg>*/,{|| Fn222Clean() }/*<bBack>*/,{|| Fn220ValTl("TELA03") .and. Fn222Soma()} /*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say - Detalhes Supervisor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDtSup:= TSAY():Create(oWizard:oMPanel[3])
oSayDtSup:cName				:= "oSayDtUsu"
oSayDtSup:cCaption 			:= ''
oSayDtSup:nLeft 			:= 40
oSayDtSup:nTop 				:= 30
oSayDtSup:nWidth 	   		:= 500
oSayDtSup:nHeight 			:= 100
oSayDtSup:lShowHint 		:= .F.
oSayDtSup:lReadOnly 		:= .F.
oSayDtSup:Align 			:= 0
oSayDtSup:lVisibleControl	:= .T.
oSayDtSup:lWordWrap 	  	:= .F.
oSayDtSup:lTransparent 		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box "Selecione o Supervisor"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxSup:= TGROUP():Create(oWizard:oMPanel[3])
oBoxSup:cName 	   := "oBoxSup"
oBoxSup:cCaption   := ""
oBoxSup:nLeft 	   := 30
oBoxSup:nTop  	   := 155
oBoxSup:nWidth 	   := 460
oBoxSup:nHeight    := 100
oBoxSup:lShowHint  := .F.
oBoxSup:lReadOnly  := .F.
oBoxSup:Align      := 0
oBoxSup:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto Say - Cod. Supervisor       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSaySuper:= TSAY():Create(oWizard:oMPanel[3])
oSaySuper:cName				:= "oSaySuper"
oSaySuper:cCaption 			:= STR0023 //"Cód Supervisor: "
oSaySuper:nLeft 			:= 43
oSaySuper:nTop 				:= 182
oSaySuper:nWidth 	   		:= 130
oSaySuper:nHeight 			:= 15
oSaySuper:lShowHint 		:= .F.
oSaySuper:lReadOnly 		:= .F.
oSaySuper:Align 			:= 0
oSaySuper:lVisibleControl	:= .T.
oSaySuper:lWordWrap 	  	:= .F.
oSaySuper:lTransparent 		:= .F.
oSaySuper:nClrText 			:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto Get "Cod Supervisor"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetCodSup:= TGET():Create(oWizard:oMPanel[3])
oGetCodSup:cName 	 		:= "oGetCodSup"
oGetCodSup:nLeft 	 		:= 130
oGetCodSup:nTop 	 		:= 180
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
oGetCodSup:bWhen     		:= {|| lSuper }
oGetCodSup:bChange			:= {|| cNomSup := Posicione('FID',1,xFilial('FID')+cCodSup,"FID_NOME") }
oGetCodSup:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto Say - Nome Supervisor       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayNomSup:= TSAY():Create(oWizard:oMPanel[3])
oSayNomSup:cName			:= "oSayNomSup"
oSayNomSup:cCaption 		:= STR0024 //"Nome:"
oSayNomSup:nLeft 			:= 223
oSayNomSup:nTop 			:= 182
oSayNomSup:nWidth 	   		:= 130
oSayNomSup:nHeight 			:= 15
oSayNomSup:lShowHint 		:= .F.
oSayNomSup:lReadOnly 		:= .F.
oSayNomSup:Align 			:= 0
oSayNomSup:lVisibleControl	:= .T.
oSayNomSup:lWordWrap 	  	:= .F.
oSayNomSup:lTransparent 	:= .F.
oSayNomSup:nClrText 		:= CLR_BLACK

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto Get "NomeSupervisor"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetNomSup:= TGET():Create(oWizard:oMPanel[3])
oGetNomSup:cName 	 		:= "oGetNomSup"
oGetNomSup:nLeft 	 		:= 260
oGetNomSup:nTop 	 		:= 180
oGetNomSup:nWidth 	 		:= 200
oGetNomSup:nHeight 	 		:= 20
oGetNomSup:lShowHint 		:= .F.
oGetNomSup:lReadOnly 		:= .F.
oGetNomSup:Align 	 		:= 0
oGetNomSup:lVisibleControl 	:= .T.
oGetNomSup:lPassword 		:= .F.
oGetNomSup:lHasButton		:= .F.
oGetNomSup:cVariable 		:= "cNomSup"
oGetNomSup:bSetGet 	 		:= {|u| If(PCount()>0,cNomSup:=u,cNomSup)}
oGetNomSup:Picture   		:= "@!"
oGetNomSup:bWhen     		:= {|| .F. }
oGetNomSup:bChange			:= {|| }
oGetNomSup:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a legenda "Senha"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSaySenSup:= TSAY():Create(oWizard:oMPanel[3])
oSaySenSup:cName			:= "oSaySenSup"
oSaySenSup:cCaption 		:= STR0025 //"Senha Superv."
oSaySenSup:nLeft 			:= 43
oSaySenSup:nTop 			:= 222
oSaySenSup:nWidth 	   		:= 80
oSaySenSup:nHeight 			:= 15
oSaySenSup:lShowHint 		:= .F.
oSaySenSup:lReadOnly 		:= .F.
oSaySenSup:Align 			:= 0
oSaySenSup:lVisibleControl	:= .T.
oSaySenSup:lWordWrap 	  	:= .F.
oSaySenSup:lTransparent 	:= .F.
oSaySenSup:nClrText 		:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Get "Senha Sup"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetSenSup:= TGET():Create(oWizard:oMPanel[3])
oGetSenSup:cName 	 		:= "oGetCodSup"
oGetSenSup:nLeft 	 		:= 130
oGetSenSup:nTop 	 		:= 220
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
//oGetSenSup:Picture   		:= "@!"
oGetSenSup:bWhen     		:= {|| !Empty(cCodSup)}
oGetSenSup:bChange			:= {|| }
oGetSenSup:bValid			:= {|| .T. }
oGetSenSup:lPassword        := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o objeto Say - Selecione o Caixa     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayCxAbr:= TSAY():Create(oWizard:oMPanel[3])
oSayCxAbr:cName				:= "oSayCxAbr"
oSayCxAbr:cCaption 			:= STR0026 //"Selecione o Caixa:"
oSayCxAbr:nLeft 			:= 223
oSayCxAbr:nTop 				:= 220
oSayCxAbr:nWidth 	   		:= 130
oSayCxAbr:nHeight 			:= 15
oSayCxAbr:lShowHint 		:= .F.
oSayCxAbr:lReadOnly 		:= .F.
oSayCxAbr:Align 			:= 0
oSayCxAbr:lVisibleControl	:= .T.
oSayCxAbr:lWordWrap 	  	:= .F.
oSayCxAbr:lTransparent 		:= .F.
oSayCxAbr:nClrText 			:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a get "Selecione o caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetCxa:= TGET():Create(oWizard:oMPanel[3])
oGetCxa:cName 	 		:= "oGetCxa"
oGetCxa:nLeft 	 		:= 315
oGetCxa:nTop 	 		:= 220
oGetCxa:nWidth 	 		:= 145
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
oGetCxa:bWhen     		:= {|| !Empty(cCodSup) }
oGetCxa:cF3				:= "SA6_CX"
oGetCxa:bChange			:= {|| }
oGetCxa:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o box "Informacoes do usuario e caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxUsr:= TGROUP():Create(oWizard:oMPanel[3])
oBoxUsr:cName 	   := "oBoxUsr"
oBoxUsr:cCaption     := ""
oBoxUsr:nLeft 	   := 30
oBoxUsr:nTop  	   := 35
oBoxUsr:nWidth 	   := 460
oBoxUsr:nHeight 	   := 160
oBoxUsr:lShowHint    := .F.
oBoxUsr:lReadOnly    := .F.
oBoxUsr:Align        := 0
oBoxUsr:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o label Detalhes do Usuario e Caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTextoIni := STR0027 + __cUserID + chr(13)+chr(10)  //OPERADOR: 
cTextoIni += STR0028 + alltrim(Posicione('FID',1,xFilial('FID')+__cUserID,"FID_NOME")) + chr(13)+chr(10)  //NOME: 
cTextoIni += STR0029 + chr(13)+chr(10) //TIPO USUARIO: Operador Simples
cTextoIni += STR0030 + Posicione('FID',1,xFilial('FID')+__cUserID,"FID_NCAIXA") + chr(13)+chr(10)  //NRO CAIXA:
cTextoIni += STR0031 + DTOC(dDatabase) + chr(13)+chr(10)
cTextoIni += STR0032 + Time() + chr(13)+chr(10)
oSayDtUsu:= TSAY():Create(oWizard:oMPanel[3])
oSayDtUsu:cName				:= "oSayDtUsu"
oSayDtUsu:cCaption 			:= cTextoIni
oSayDtUsu:nLeft 			:= 60
oSayDtUsu:nTop 				:= 60
oSayDtUsu:nWidth 	   		:= 250
oSayDtUsu:nHeight 			:= 120
oSayDtUsu:lShowHint 		:= .F.
oSayDtUsu:lReadOnly 		:= .F.
oSayDtUsu:Align 			:= 0
oSayDtUsu:lVisibleControl	:= .T.
oSayDtUsu:lWordWrap 	  	:= .F.
oSayDtUsu:lTransparent 		:= .F.
oSayDtUsu:nClrText 			:= CLR_BLACK

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o painel IV ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0005/*<chTitle>*/, STR0033 /*<chMsg>*/,{|| Fn222Clean() }/*<bBack>*/,/*<bNext>*/, {|| Fn222Run()}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box "Abertura de Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxAbr:= TGROUP():Create(oWizard:oMPanel[4])
oBoxAbr:cName 	   := "oBoxAbr"
oBoxAbr:cCaption     := STR0006 //"Parametros"
oBoxAbr:nLeft 	   := 170
oBoxAbr:nTop  	   := 170
oBoxAbr:nWidth 	   := 250
oBoxAbr:nHeight 	   := 70
oBoxAbr:lShowHint    := .F.
oBoxAbr:lReadOnly    := .F.
oBoxAbr:Align        := 0
oBoxAbr:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Detalhes Troco"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTextoIni := STR0034 + chr(13) + chr(10) + chr(13) + chr(10)
cTextoIni += STR0035 + chr(13) + chr(10)
cTextoIni += STR0036 + chr(13) + chr(10)
oSayDetTro:= TSAY():Create(oWizard:oMPanel[4])
oSayDetTro:cName			:= "oSayTroco"
oSayDetTro:cCaption 		:= cTextoIni
oSayDetTro:nLeft 			:= 40
oSayDetTro:nTop 			:= 40
oSayDetTro:nWidth 	   		:= 450
oSayDetTro:nHeight 			:= 100
oSayDetTro:lShowHint 		:= .F.
oSayDetTro:lReadOnly 		:= .F.
oSayDetTro:Align 			:= 0
oSayDetTro:lVisibleControl	:= .T.
oSayDetTro:lWordWrap 	  	:= .F.
oSayDetTro:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Valor Inicial em Dinheiro "³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTroco:= TSAY():Create(oWizard:oMPanel[4])
oSayTroco:cName				:= "oSayTroco"
oSayTroco:cCaption 			:= STR0037  //"Valor Inicial em Dinheiro R$:"
oSayTroco:nLeft 			:= 180
oSayTroco:nTop 				:= 202
oSayTroco:nWidth 	   		:= 150
oSayTroco:nHeight 			:= 15
oSayTroco:lShowHint 		:= .F.
oSayTroco:lReadOnly 		:= .F.
oSayTroco:Align 			:= 0
oSayTroco:lVisibleControl	:= .T.
oSayTroco:lWordWrap 	  	:= .F.
oSayTroco:lTransparent 		:= .F.
oSayTroco:nClrText 			:= CLR_HBLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a get "Troco" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetTroco:= TGET():Create(oWizard:oMPanel[4])
oGetTroco:cName 	 		:= "oGetTroco"
oGetTroco:nLeft 	 		:= 320
oGetTroco:nTop 	 			:= 200
oGetTroco:nWidth 	 		:= 80
oGetTroco:nHeight 	 		:= 20
oGetTroco:lShowHint 		:= .F.
oGetTroco:lReadOnly 		:= .F.
oGetTroco:Align 	 		:= 0
oGetTroco:lVisibleControl 	:= .T.
oGetTroco:lPassword 		:= .F.
oGetTroco:lHasButton		:= .F.
oGetTroco:cVariable 		:= "nTroco"
oGetTroco:bSetGet 	 		:= {|u| If(PCount()>0,nTroco:=u,nTroco)}
oGetTroco:Picture   		:= "9999.99"
oGetTroco:bWhen     		:= {|| nTroco == 0 }
oGetTroco:bChange			:= {|| }
oGetTroco:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Mapa Resumo Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayMapRes:= TSAY():Create(oWizard:oMPanel[4])
oSayMapRes:cName			:= "oSayMapRes"
oSayMapRes:cCaption 		:= STR0038 //"Entre abaixo com os valores reais presentes em caixa para que os totalizadores finais possam ser representados."
oSayMapRes:nLeft 			:= 01
oSayMapRes:nTop 			:= 02
oSayMapRes:nWidth 	   		:= 550
oSayMapRes:nHeight 			:= 15
oSayMapRes:lShowHint 		:= .F.
oSayMapRes:lReadOnly 		:= .F.
oSayMapRes:Align 			:= 0
oSayMapRes:lVisibleControl	:= .T.
oSayMapRes:lWordWrap 	  	:= .F.
oSayMapRes:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box Valores efetivados em caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxVlrE:= TGROUP():Create(oWizard:oMPanel[4])
oBoxVlrE:cName 	   := "oBoxVlrE"
oBoxVlrE:cCaption     := STR0039 //"Efetivados em caixa"
oBoxVlrE:nLeft 	   := 01
oBoxVlrE:nTop  	   := 25
oBoxVlrE:nWidth 	   := 170
oBoxVlrE:nHeight 	   := 200
oBoxVlrE:lShowHint    := .F.
oBoxVlrE:lReadOnly    := .F.
oBoxVlrE:Align        := 0
oBoxVlrE:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box Valores Reais em caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxVlrR:= TGROUP():Create(oWizard:oMPanel[4])
oBoxVlrR:cName 	   := "oBoxVlrR"
oBoxVlrR:cCaption     := STR0040 //"Valores Reais em caixa"
oBoxVlrR:nLeft 	   := 190
oBoxVlrR:nTop  	   := 25
oBoxVlrR:nWidth 	   := 170
oBoxVlrR:nHeight 	   := 200
oBoxVlrR:lShowHint    := .F.
oBoxVlrR:lReadOnly    := .F.
oBoxVlrR:Align        := 0
oBoxVlrR:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box Diferencas em caixa    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxVlrD:= TGROUP():Create(oWizard:oMPanel[4])
oBoxVlrD:cName 	   := "oBoxVlrD"
oBoxVlrD:cCaption     := STR0041 //"Diferença Efetivado x Real"
oBoxVlrD:nLeft 	   := 380
oBoxVlrD:nTop  	   := 25
oBoxVlrD:nWidth 	   := 170
oBoxVlrD:nHeight 	   := 200
oBoxVlrD:lShowHint    := .F.
oBoxVlrD:lReadOnly    := .F.
oBoxVlrD:Align        := 0
oBoxVlrD:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Box Opcoes de Resumo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxOpc:= TGROUP():Create(oWizard:oMPanel[4])
oBoxOpc:cName 	   := "oBoxOpc"
oBoxOpc:cCaption     := STR0042 //"Opções de fechamento"
oBoxOpc:nLeft 	   := 01
oBoxOpc:nTop  	   := 230
oBoxOpc:nWidth 	   := 550
oBoxOpc:nHeight 	   := 40
oBoxOpc:lShowHint    := .F.
oBoxOpc:lReadOnly    := .F.
oBoxOpc:Align        := 0
oBoxOpc:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em DN"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayRDN:= TSAY():Create(oWizard:oMPanel[4])
oSayRDN:cName			:= "oSayRDN"
oSayRDN:cCaption 		:= STR0043 //"Tot. Dinheiro:"
oSayRDN:nLeft 			:= 10
oSayRDN:nTop 			:= 60
oSayRDN:nWidth 	   		:= 100
oSayRDN:nHeight 		:= 15
oSayRDN:lShowHint 		:= .F.
oSayRDN:lReadOnly 		:= .F.
oSayRDN:Align 			:= 0
oSayRDN:lVisibleControl	:= .T.
oSayRDN:lWordWrap 	  	:= .F.
oSayRDN:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cheques"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayRCH:= TSAY():Create(oWizard:oMPanel[4])
oSayRCH:cName			:= "oSayRCH"
oSayRCH:cCaption 		:= STR0044 //"Tot. Cheques:"
oSayRCH:nLeft 			:= 10
oSayRCH:nTop 			:= 90
oSayRCH:nWidth 	   		:= 100
oSayRCH:nHeight 		:= 15
oSayRCH:lShowHint 		:= .F.
oSayRCH:lReadOnly 		:= .F.
oSayRCH:Align 			:= 0
oSayRCH:lVisibleControl	:= .T.
oSayRCH:lWordWrap 	  	:= .F.
oSayRCH:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cartao Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayRCC:= TSAY():Create(oWizard:oMPanel[4])
oSayRCC:cName			:= "oSayRCC"
oSayRCC:cCaption 		:= STR0045 //"Tot. C. Crédito:"
oSayRCC:nLeft 			:= 10
oSayRCC:nTop 			:= 120
oSayRCC:nWidth 	   		:= 100
oSayRCC:nHeight 		:= 15
oSayRCC:lShowHint 		:= .F.
oSayRCC:lReadOnly 		:= .F.
oSayRCC:Align 			:= 0
oSayRCC:lVisibleControl	:= .T.
oSayRCC:lWordWrap 	  	:= .F.
oSayRCC:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cartao Debito"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayRCD:= TSAY():Create(oWizard:oMPanel[4])
oSayRCD:cName			:= "oSayRCD"
oSayRCD:cCaption 		:= STR0046 //"Tot. C. Débito:"
oSayRCD:nLeft 			:= 10
oSayRCD:nTop 			:= 150
oSayRCD:nWidth 	   		:= 100
oSayRCD:nHeight 		:= 15
oSayRCD:lShowHint 		:= .F.
oSayRCD:lReadOnly 		:= .F.
oSayRCD:Align 			:= 0
oSayRCD:lVisibleControl	:= .T.
oSayRCD:lWordWrap 	  	:= .F.
oSayRCD:lTransparent 	:= .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em NCC" 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayRNC:= TSAY():Create(oWizard:oMPanel[4])
oSayRNC:cName			:= "oSayRNC"
oSayRNC:cCaption 		:= STR0088 //"Tot. C. Débito:"
oSayRNC:nLeft 			:= 10
oSayRNC:nTop 			:= 180
oSayRNC:nWidth 	   		:= 100
oSayRNC:nHeight 		:= 15
oSayRNC:lShowHint 		:= .F.
oSayRNC:lReadOnly 		:= .F.
oSayRNC:Align 			:= 0
oSayRNC:lVisibleControl	:= .T.
oSayRNC:lWordWrap 	  	:= .F.
oSayRNC:lTransparent 	:= .F.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "* Valor em dinheiro ja contempla o valor inicial de troco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oSayInfo:= TSAY():Create(oWizard:oMPanel[4])
//oSayInfo:cName			:= "oSayInfo"
//oSayInfo:cCaption 		:= STR0047 //"* Total em dinheiro ja contempla o valor inicial carregado na abertura do Caixa"
//oSayInfo:nLeft 			:= 10
//oSayInfo:nTop 			:= 173
//oSayInfo:nWidth 	   	:= 150
//oSayInfo:nHeight 		:= 43
//oSayInfo:lShowHint 		:= .F.
//oSayInfo:lReadOnly 		:= .F.
//oSayInfo:Align 			:= 0
//oSayInfo:lVisibleControl:= .T.
//oSayInfo:lWordWrap 	  	:= .T.
//oSayInfo:lTransparent 	:= .F.  
//oSayInfo:nClrText 		:= CLR_BLUE
//oSayInfo:oFont			:= oFontMin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Presente Total em DN"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayPDN:= TSAY():Create(oWizard:oMPanel[4])
oSayPDN:cName			:= "oSayRDN"
oSayPDN:cCaption 		:= STR0043 //"Tot. Dinheiro:"
oSayPDN:nLeft 			:= 200
oSayPDN:nTop 			:= 60
oSayPDN:nWidth 	   		:= 100
oSayPDN:nHeight 		:= 15
oSayPDN:lShowHint 		:= .F.
oSayPDN:lReadOnly 		:= .F.
oSayPDN:Align 			:= 0
oSayPDN:lVisibleControl	:= .T.
oSayPDN:lWordWrap 	  	:= .F.
oSayPDN:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Presente Total em Cheques"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayPCH:= TSAY():Create(oWizard:oMPanel[4])
oSayPCH:cName			:= "oSayRCH"
oSayPCH:cCaption 		:= STR0044  //"Tot. Cheques:"
oSayPCH:nLeft 			:= 200
oSayPCH:nTop 			:= 90
oSayPCH:nWidth 	   		:= 100
oSayPCH:nHeight 		:= 15
oSayPCH:lShowHint 		:= .F.
oSayPCH:lReadOnly 		:= .F.
oSayPCH:Align 			:= 0
oSayPCH:lVisibleControl	:= .T.
oSayPCH:lWordWrap 	  	:= .F.
oSayPCH:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Presente Total em Cartao Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayPCC:= TSAY():Create(oWizard:oMPanel[4])
oSayPCC:cName			:= "oSayRCC"
oSayPCC:cCaption 		:= STR0045 //"Tot. C. Crédito:"
oSayPCC:nLeft 			:= 200
oSayPCC:nTop 			:= 120
oSayPCC:nWidth 	   		:= 100
oSayPCC:nHeight 		:= 15
oSayPCC:lShowHint 		:= .F.
oSayPCC:lReadOnly 		:= .F.
oSayPCC:Align 			:= 0
oSayPCC:lVisibleControl	:= .T.
oSayPCC:lWordWrap 	  	:= .F.
oSayPCC:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Presente Total em Cartao Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayPCD:= TSAY():Create(oWizard:oMPanel[4])
oSayPCD:cName			:= "oSayRCD"
oSayPCD:cCaption 		:= STR0046 //"Tot. C. Débito:"
oSayPCD:nLeft 			:= 200
oSayPCD:nTop 			:= 150
oSayPCD:nWidth 	   		:= 100
oSayPCD:nHeight 		:= 15
oSayPCD:lShowHint 		:= .F.
oSayPCD:lReadOnly 		:= .F.
oSayPCD:Align 			:= 0
oSayPCD:lVisibleControl	:= .T.
oSayPCD:lWordWrap 	  	:= .F.
oSayPCD:lTransparent 	:= .F.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Presente Total em Cartao Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayPNC:= TSAY():Create(oWizard:oMPanel[4])
oSayPNC:cName			:= "oSayRNC"
oSayPNC:cCaption 		:= STR0088 //"Tot. NCC:"
oSayPNC:nLeft 			:= 200
oSayPNC:nTop 			:= 180
oSayPNC:nWidth 	   		:= 100
oSayPNC:nHeight 		:= 15
oSayPNC:lShowHint 		:= .F.
oSayPNC:lReadOnly 		:= .F.
oSayPNC:Align 			:= 0
oSayPNC:lVisibleControl	:= .T.
oSayPNC:lWordWrap 	  	:= .F.
oSayPNC:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Diferenca Total em DN"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDDN:= TSAY():Create(oWizard:oMPanel[4])
oSayDDN:cName			:= "oSayDDN"
oSayDDN:cCaption 		:= STR0043 //"Tot. Dinheiro:"
oSayDDN:nLeft 			:= 390
oSayDDN:nTop 			:= 60
oSayDDN:nWidth 	   		:= 100
oSayDDN:nHeight 		:= 15
oSayDDN:lShowHint 		:= .F.
oSayDDN:lReadOnly 		:= .F.
oSayDDN:Align 			:= 0
oSayDDN:lVisibleControl	:= .T.
oSayDDN:lWordWrap 	  	:= .F.
oSayDDN:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Diferenca Total em Cheques³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDCH:= TSAY():Create(oWizard:oMPanel[4])
oSayDCH:cName			:= "oSayDCH"
oSayDCH:cCaption 		:= STR0044 //"Tot. Cheques:"
oSayDCH:nLeft 			:= 390
oSayDCH:nTop 			:= 90
oSayDCH:nWidth 	   		:= 100
oSayDCH:nHeight 		:= 15
oSayDCH:lShowHint 		:= .F.
oSayDCH:lReadOnly 		:= .F.
oSayDCH:Align 			:= 0
oSayDCH:lVisibleControl	:= .T.
oSayDCH:lWordWrap 	  	:= .F.
oSayDCH:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cartao Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDCC:= TSAY():Create(oWizard:oMPanel[4])
oSayDCC:cName			:= "oSayDCC"
oSayDCC:cCaption 		:= STR0045 //"Tot. C. Crédito:"
oSayDCC:nLeft 			:= 390
oSayDCC:nTop 			:= 120
oSayDCC:nWidth 	   		:= 100
oSayDCC:nHeight 		:= 15
oSayDCC:lShowHint 		:= .F.
oSayDCC:lReadOnly 		:= .F.
oSayDCC:Align 			:= 0
oSayDCC:lVisibleControl	:= .T.
oSayDCC:lWordWrap 	  	:= .F.
oSayDCC:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cartao Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDCD:= TSAY():Create(oWizard:oMPanel[4])
oSayDCD:cName			:= "oSayDCD"
oSayDCD:cCaption 		:= STR0046 //"Tot. C. Débito:"
oSayDCD:nLeft 			:= 390
oSayDCD:nTop 			:= 150
oSayDCD:nWidth 	   		:= 100
oSayDCD:nHeight 		:= 15
oSayDCD:lShowHint 		:= .F.
oSayDCD:lReadOnly 		:= .F.
oSayDCD:Align 			:= 0
oSayDCD:lVisibleControl	:= .T.
oSayDCD:lWordWrap 	  	:= .F.
oSayDCD:lTransparent 	:= .F.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Say "Efeitvo Total em Cartao Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayDNC:= TSAY():Create(oWizard:oMPanel[4])
oSayDNC:cName			:= "oSayDNC"
oSayDNC:cCaption 		:= STR0088 //"Tot. C. Débito:"
oSayDNC:nLeft 			:= 390
oSayDNC:nTop 			:= 180
oSayDNC:nWidth 	   		:= 100
oSayDNC:nHeight 		:= 15
oSayDNC:lShowHint 		:= .F.
oSayDNC:lReadOnly 		:= .F.
oSayDNC:Align 			:= 0
oSayDNC:lVisibleControl	:= .T.
oSayDNC:lWordWrap 	  	:= .F.
oSayDNC:lTransparent 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Efeitvo em Dinheiro"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRDN:= TGET():Create(oWizard:oMPanel[4])
oGetRDN:cName 	 		:= "oGetRDN"
oGetRDN:nLeft 	 		:= 80
oGetRDN:nTop 	 		:= 58
oGetRDN:nWidth 	 		:= 75
oGetRDN:nHeight 	 	:= 20
oGetRDN:lShowHint 		:= .F.
oGetRDN:lReadOnly 		:= .F.
oGetRDN:Align 	 		:= 0
oGetRDN:lVisibleControl := .T.
oGetRDN:lPassword 		:= .F.
oGetRDN:lHasButton		:= .F.
oGetRDN:cVariable 		:= "nRDN"
oGetRDN:bSetGet 		:= {|u| If(PCount()>0,nRDN:=u,nRDN)}
oGetRDN:Picture   		:= "999,999.99"
oGetRDN:bWhen     		:= {|| .F. }
oGetRDN:bChange			:= {|| }
oGetRDN:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Efeitvo em Chques"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRCH:= TGET():Create(oWizard:oMPanel[4])
oGetRCH:cName 	 		:= "oGetRCH"
oGetRCH:nLeft 	 		:= 80
oGetRCH:nTop 	 		:= 88
oGetRCH:nWidth 	 		:= 75
oGetRCH:nHeight 	 	:= 20
oGetRCH:lShowHint 		:= .F.
oGetRCH:lReadOnly 		:= .F.
oGetRCH:Align 	 		:= 0
oGetRCH:lVisibleControl := .T.
oGetRCH:lPassword 		:= .F.
oGetRCH:lHasButton		:= .F.
oGetRCH:cVariable 		:= "nRCH"
oGetRCH:bSetGet 		:= {|u| If(PCount()>0,nRCH:=u,nRCH)}
oGetRCH:Picture   		:= "999,999.99"
oGetRCH:bWhen     		:= {|| .F. }
oGetRCH:bChange			:= {|| }
oGetRCH:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Efeitvo em Cartao Credito"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRCC:= TGET():Create(oWizard:oMPanel[4])
oGetRCC:cName 	 		:= "oGetRCC"
oGetRCC:nLeft 	 		:= 80
oGetRCC:nTop 	 		:= 118
oGetRCC:nWidth 	 		:= 75
oGetRCC:nHeight 	 	:= 20
oGetRCC:lShowHint 		:= .F.
oGetRCC:lReadOnly 		:= .F.
oGetRCC:Align 	 		:= 0
oGetRCC:lVisibleControl := .T.
oGetRCC:lPassword 		:= .F.
oGetRCC:lHasButton		:= .F.
oGetRCC:cVariable 		:= "nRCC"
oGetRCC:bSetGet 		:= {|u| If(PCount()>0,nRCC:=u,nRCC)}
oGetRCC:Picture   		:= "999,999.99"
oGetRCC:bWhen     		:= {|| .F. }
oGetRCC:bChange			:= {|| }
oGetRCC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Efeitvo em Cartao Debito"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRCD:= TGET():Create(oWizard:oMPanel[4])
oGetRCD:cName 	 		:= "oGetRCD"
oGetRCD:nLeft 	 		:= 80
oGetRCD:nTop 	 		:= 148
oGetRCD:nWidth 	 		:= 75
oGetRCD:nHeight 	 	:= 20
oGetRCD:lShowHint 		:= .F.
oGetRCD:lReadOnly 		:= .F.
oGetRCD:Align 	 		:= 0
oGetRCD:lVisibleControl := .T.
oGetRCD:lPassword 		:= .F.
oGetRCD:lHasButton		:= .F.
oGetRCD:cVariable 		:= "nRCD"
oGetRCD:bSetGet 		:= {|u| If(PCount()>0,nRCD:=u,nRCD)}
oGetRCD:Picture   		:= "999,999.99"
oGetRCD:bWhen     		:= {|| .F. }
oGetRCD:bChange			:= {|| }
oGetRCD:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Efeitvo em NCC"    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRNC:= TGET():Create(oWizard:oMPanel[4])
oGetRNC:cName 	 		:= "oGetRNC"
oGetRNC:nLeft 	 		:= 80
oGetRNC:nTop 	 		:= 178
oGetRNC:nWidth 	 		:= 75
oGetRNC:nHeight 	 	:= 20
oGetRNC:lShowHint 		:= .F.
oGetRNC:lReadOnly 		:= .F.
oGetRNC:Align 	 		:= 0
oGetRNC:lVisibleControl := .T.
oGetRNC:lPassword 		:= .F.
oGetRNC:lHasButton		:= .F.
oGetRNC:cVariable 		:= "nRNC"
oGetRNC:bSetGet 		:= {|u| If(PCount()>0,nRNC:=u,nRNC)}
oGetRNC:Picture   		:= "999,999.99"
oGetRNC:bWhen     		:= {|| .F. }
oGetRNC:bChange			:= {|| }
oGetRNC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Presente em Dinheiro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetPDN:= TGET():Create(oWizard:oMPanel[4])
oGetPDN:cName 	 		:= "oGetPDN"
oGetPDN:nLeft 	 		:= 270
oGetPDN:nTop 	 		:= 58
oGetPDN:nWidth 	 		:= 75
oGetPDN:nHeight 	 	:= 20
oGetPDN:lShowHint 		:= .F.
oGetPDN:lReadOnly 		:= .F.
oGetPDN:Align 	 		:= 0
oGetPDN:lVisibleControl := .T.
oGetPDN:lPassword 		:= .F.
oGetPDN:lHasButton		:= .F.
oGetPDN:cVariable 		:= "nPDN"
oGetPDN:bSetGet 		:= {|u| If(PCount()>0,nPDN:=u,nPDN)}
oGetPDN:Picture   		:= "999,999.99"
oGetPDN:bWhen     		:= {|| .T. }
oGetPDN:bChange			:= {|| Fn222Dif('1')}
oGetPDN:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Presente em Cheques ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetPCH:= TGET():Create(oWizard:oMPanel[4])
oGetPCH:cName 	 		:= "oGetPCH"
oGetPCH:nLeft 	 		:= 270
oGetPCH:nTop 	 		:= 88
oGetPCH:nWidth 	 		:= 75
oGetPCH:nHeight 	 	:= 20
oGetPCH:lShowHint 		:= .F.
oGetPCH:lReadOnly 		:= .F.
oGetPCH:Align 	 		:= 0
oGetPCH:lVisibleControl := .T.
oGetPCH:lPassword 		:= .F.
oGetPCH:lHasButton		:= .F.
oGetPCH:cVariable 		:= "nPCH"
oGetPCH:bSetGet 		:= {|u| If(PCount()>0,nPCH:=u,nPCH)}
oGetPCH:Picture   		:= "999,999.99"
oGetPCH:bWhen     		:= {|| .T. }
oGetPCH:bChange			:= {|| Fn222Dif('2')}
oGetPCH:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Presente em Cartao Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetPCC:= TGET():Create(oWizard:oMPanel[4])
oGetPCC:cName 	 		:= "oGetPCC"
oGetPCC:nLeft 	 		:= 270
oGetPCC:nTop 	 		:= 118
oGetPCC:nWidth 	 		:= 75
oGetPCC:nHeight 	 	:= 20
oGetPCC:lShowHint 		:= .F.
oGetPCC:lReadOnly 		:= .F.
oGetPCC:Align 	 		:= 0
oGetPCC:lVisibleControl := .T.
oGetPCC:lPassword 		:= .F.
oGetPCC:lHasButton		:= .F.
oGetPCC:cVariable 		:= "nPCC"
oGetPCC:bSetGet 		:= {|u| If(PCount()>0,nPCC:=u,nPCC)}
oGetPCC:Picture   		:= "999,999.99"
oGetPCC:bWhen     		:= {|| .T. }
oGetPCC:bChange			:= {|| Fn222Dif('3')}
oGetPCC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Presente em Cartao Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetPCD:= TGET():Create(oWizard:oMPanel[4])
oGetPCD:cName 	 		:= "oGetPCD"
oGetPCD:nLeft 	 		:= 270
oGetPCD:nTop 	 		:= 148
oGetPCD:nWidth 	 		:= 75
oGetPCD:nHeight 	 	:= 20
oGetPCD:lShowHint 		:= .F.
oGetPCD:lReadOnly 		:= .F.
oGetPCD:Align 	 		:= 0
oGetPCD:lVisibleControl := .T.
oGetPCD:lPassword 		:= .F.
oGetPCD:lHasButton		:= .F.
oGetPCD:cVariable 		:= "nPCD"
oGetPCD:bSetGet 		:= {|u| If(PCount()>0,nPCD:=u,nPCD)}
oGetPCD:Picture   		:= "999,999.99"
oGetPCD:bWhen     		:= {|| .T. }
oGetPCD:bChange			:= {|| Fn222Dif('4')}
oGetPCD:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "NCC"                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetPNC:= TGET():Create(oWizard:oMPanel[4])
oGetPNC:cName 	 		:= "oGetPNC"
oGetPNC:nLeft 	 		:= 270
oGetPNC:nTop 	 		:= 178
oGetPNC:nWidth 	 		:= 75
oGetPNC:nHeight 	 	:= 20
oGetPNC:lShowHint 		:= .F.
oGetPNC:lReadOnly 		:= .F.
oGetPNC:Align 	 		:= 0
oGetPNC:lVisibleControl := .T.
oGetPNC:lPassword 		:= .F.
oGetPNC:lHasButton		:= .F.
oGetPNC:cVariable 		:= "nPNC"
oGetPNC:bSetGet 		:= {|u| If(PCount()>0,nPNC:=u,nPNC)}
oGetPNC:Picture   		:= "999,999.99"
oGetPNC:bWhen     		:= {|| .T. }
oGetPNC:bChange			:= {|| Fn222Dif('5')}
oGetPNC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Diferenca em Dinheiro"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDDN:= TGET():Create(oWizard:oMPanel[4])
oGetDDN:cName 	 		:= "oGetDDN"
oGetDDN:nLeft 	 		:= 460
oGetDDN:nTop 	 		:= 58
oGetDDN:nWidth 	 		:= 75
oGetDDN:nHeight 	 	:= 20
oGetDDN:lShowHint 		:= .F.
oGetDDN:lReadOnly 		:= .F.
oGetDDN:Align 	 		:= 0
oGetDDN:lVisibleControl := .T.
oGetDDN:lPassword 		:= .F.
oGetDDN:lHasButton		:= .F.
oGetDDN:cVariable 		:= "nDDN"
oGetDDN:bSetGet 		:= {|u| If(PCount()>0,nDDN:=u,nDDN)}
oGetDDN:Picture   		:= "999,999.99"
oGetDDN:bWhen     		:= {|| .F. }
oGetDDN:bChange			:= {|| }
oGetDDN:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Diferenca em Cheques"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDCH:= TGET():Create(oWizard:oMPanel[4])
oGetDCH:cName 	 		:= "oGetDCH"
oGetDCH:nLeft 	 		:= 460
oGetDCH:nTop 	 		:= 88
oGetDCH:nWidth 	 		:= 75
oGetDCH:nHeight 	 	:= 20
oGetDCH:lShowHint 		:= .F.
oGetDCH:lReadOnly 		:= .F.
oGetDCH:Align 	 		:= 0
oGetDCH:lVisibleControl := .T.
oGetDCH:lPassword 		:= .F.
oGetDCH:lHasButton		:= .F.
oGetDCH:cVariable 		:= "nDCH"
oGetDCH:bSetGet 		:= {|u| If(PCount()>0,nDCH:=u,nDCH)}
oGetDCH:Picture   		:= "999,999.99"
oGetDCH:bWhen     		:= {|| .F. }
oGetDCH:bChange			:= {|| }
oGetDCH:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Diferenca em Cartao Credito"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDCC:= TGET():Create(oWizard:oMPanel[4])
oGetDCC:cName 	 		:= "oGetDCC"
oGetDCC:nLeft 	 		:= 460
oGetDCC:nTop 	 		:= 118
oGetDCC:nWidth 	 		:= 75
oGetDCC:nHeight 	 	:= 20
oGetDCC:lShowHint 		:= .F.
oGetDCC:lReadOnly 		:= .F.
oGetDCC:Align 	 		:= 0
oGetDCC:lVisibleControl := .T.
oGetDCC:lPassword 		:= .F.
oGetDCC:lHasButton		:= .F.
oGetDCC:cVariable 		:= "nDCC"
oGetDCC:bSetGet 		:= {|u| If(PCount()>0,nDCC:=u,nDCC)}
oGetDCC:Picture   		:= "999,999.99"
oGetDCC:bWhen     		:= {|| .F. }
oGetDCC:bChange			:= {|| }
oGetDCC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Diferenca Cartao Debito"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDCD:= TGET():Create(oWizard:oMPanel[4])
oGetDCD:cName 	 		:= "oGetDCD"
oGetDCD:nLeft 	 		:= 460
oGetDCD:nTop 	 		:= 148
oGetDCD:nWidth 	 		:= 75
oGetDCD:nHeight 	 	:= 20
oGetDCD:lShowHint 		:= .F.
oGetDCD:lReadOnly 		:= .F.
oGetDCD:Align 	 		:= 0
oGetDCD:lVisibleControl := .T.
oGetDCD:lPassword 		:= .F.
oGetDCD:lHasButton		:= .F.
oGetDCD:cVariable 		:= "nDCD"
oGetDCD:bSetGet 		:= {|u| If(PCount()>0,nDCD:=u,nDCD)}
oGetDCD:Picture   		:= "999,999.99"
oGetDCD:bWhen     		:= {|| .F. }
oGetDCD:bChange			:= {|| }
oGetDCD:bValid			:= {|| .T. } 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Get "Diferenca NCC"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDNC:= TGET():Create(oWizard:oMPanel[4])
oGetDNC:cName 	 		:= "oGetDNC"
oGetDNC:nLeft 	 		:= 460
oGetDNC:nTop 	 		:= 178
oGetDNC:nWidth 	 		:= 75
oGetDNC:nHeight 	 	:= 20
oGetDNC:lShowHint 		:= .F.
oGetDNC:lReadOnly 		:= .F.
oGetDNC:Align 	 		:= 0
oGetDNC:lVisibleControl := .T.
oGetDNC:lPassword 		:= .F.
oGetDNC:lHasButton		:= .F.
oGetDNC:cVariable 		:= "nDNC"
oGetDNC:bSetGet 		:= {|u| If(PCount()>0,nDNC:=u,nDNC)}
oGetDNC:Picture   		:= "999,999.99"
oGetDNC:bWhen     		:= {|| .F. }
oGetDNC:bChange			:= {|| }
oGetDNC:bValid			:= {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o CheckBox "Realizar Sangria de Caixa ao concluir"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkSangria:= TCHECKBOX():Create(oWizard:oMPanel[4])
oChkSangria:cName 			:= "oChkSangria"
oChkSangria:cCaption 		:= STR0048 //"Realizar Sangria de caixa"
oChkSangria:nLeft 			:= 20
oChkSangria:nTop  			:= 245
oChkSangria:nWidth 			:= 220
oChkSangria:nHeight 		:= 15
oChkSangria:lShowHint 		:= .F.
oChkSangria:lReadOnly 		:= iif(GetNewPar("MV_FINPSGR",.F.),.T.,.F.)
oChkSangria:bWhen			:= {|| !oChkSangria:lReadOnly}
oChkSangria:Align 			:= 0
oChkSangria:cVariable 		:= "lSangria"
oChkSangria:bSetGet 		:= {|u| If(PCount()>0,lSangria:=u,lSangria) }
oChkSangria:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o CheckBox "Imprimir Mapa Resumo de Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkImpRes:= TCHECKBOX():Create(oWizard:oMPanel[4])
oChkImpRes:cName 			:= "oChkImpRes"
oChkImpRes:cCaption 		:= STR0049 //"Ao concluir, imprimir Mapa Resumo de Caixa"
oChkImpRes:nLeft 			:= 250
oChkImpRes:nTop  			:= 245
oChkImpRes:nWidth 			:= 280
oChkImpRes:nHeight 			:= 15
oChkImpRes:lShowHint 		:= .F.
oChkImpRes:lReadOnly 		:= .F.
oChkImpRes:Align 			:= 0
oChkImpRes:cVariable 		:= "lImpRes"
oChkImpRes:bSetGet 			:= {|u| If(PCount()>0,lImpRes:=u,lImpRes) }
oChkImpRes:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe o objeto oWizard apos montar todos seus paineis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222CheckºAutor  ³Cesar A. Bianchi    º Data ³  18/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a atualizacao da opcao selecionada no painel 1 da wiº±±
±±º          ³zard. "Abertura de Caixa" ou "Fechamento de Caixa"          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FN222Check(cOpc)

if cOpc = 'A'
	lAbre := .T.
	lFecha := .F.
elseif cOpc = 'F'
	lAbre := .F.
	lFecha := .T.
elseif cOpc = 'O'
	lOpera := .T.
	lSuper := .F.
elseif cOpc = 'S'
	lOpera := .F.
	lSuper := .T.
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os objetos graficos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fn220Visib()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222VisibºAutor  ³Cesar A. Bianchi    º Data ³  18/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define quais os objetos estarao visiveis no painel II da wi-º±±
±±º          ³zard principal, de acordo com o tipo de usuario escolhido   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn220Visib()
Local cAux := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o tipo de usuario escolhido seja SUPERVISOR³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lSuper
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem exibidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxSup:lVisible := .T.
	oSaySuper:lVisible := .T.
	oGetCodSup:lVisible := .T.
	oSayNomSup:lVisible := .T.
	oGetNomSup:lVisible := .T.
	oSaySenSup:lVisible := .T.
	oGetSenSup:lVisible := .T.
	oSayCxAbr:lVisible := .T.
	oGetCxa:lVisible := .T.
	oSayDtSup:lVisible := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem ocultados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxUsr:lVisible := .F.
	oSayDtUsu:lVisible := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o tipo de usuario escolhido seja OPERADOR  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif lOpera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem exibidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxUsr:lVisible := .T.
	oSayDtUsu:lVisible := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem ocultados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxSup:lVisible := .F.
	oSaySuper:lVisible := .F.
	oGetCodSup:lVisible := .F.
	oSayNomSup:lVisible := .F.
	oGetNomSup:lVisible := .F.
	oSaySenSup:lVisible := .F.
	oGetSenSup:lVisible := .F.
	oSayCxAbr:lVisible := .F.
	oGetCxa:lVisible := .F.
	oSayDtSup:lVisible := .F.
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a opcao seja Abrir Caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lAbre
	oBoxSup:cCaption := STR0050 //"Selecione o Supervisor e o Caixa a ser Aberto"
	oBoxUsr:cCaption := STR0051 //"Informacoes sobre o Operador e Caixa a ser Aberto"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a legenda "Detalhes do supervisor"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cAux := STR0018 + chr(13)+chr(10) + chr(13)+chr(10)
	cAux += STR0019 + chr(13)+chr(10)
	cAux += STR0020 + chr(13)+chr(10)
	cAux += STR0021 + chr(13)+chr(10)
	cAux += STR0022 + chr(13)+chr(10)		
	oSayDtSup:cCaption := cAux
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem exibidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxAbr:lVisible := .T.
	oSayTroco:lVisible := .T.
	oGetTroco:lVisible := .T.
	oSayDetTro:lVisible := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem ocultados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxVlrE:lVisible := .F.
	oBoxVlrR:lVisible := .F.
	oBoxVlrD:lVisible := .F.
	oBoxOpc:lVisible := .F.
	oSayRDN:lVisible := .F.
	oSayRCH:lVisible := .F.
	oSayRCC:lVisible := .F.
	oSayRCD:lVisible := .F.
	oSayRNC:lVisible := .F.
	oSayPDN:lVisible := .F.
	oSayPCH:lVisible := .F.
	oSayPCC:lVisible := .F.
	oSayPCD:lVisible := .F.
	oSayPNC:lVisible := .F.
	oSayDDN:lVisible := .F.
	oSayDCH:lVisible := .F.
	oSayDCC:lVisible := .F.
	oSayDCD:lVisible := .F.
	oSayDNC:lVisible := .F.
	oGetRDN:lVisible := .F.
	oGetRCH:lVisible := .F.
	oGetRCC:lVisible := .F.
	oGetRCD:lVisible := .F.
	oGetRNC:lVisible := .F.
	oGetPDN:lVisible := .F.
	oGetPCH:lVisible := .F.
	oGetPCC:lVisible := .F.
	oGetPCD:lVisible := .F.
	oGetPNC:lVisible := .F.
	oGetDDN:lVisible := .F.
	oGetDCH:lVisible := .F.
	oGetDCC:lVisible := .F.
	oGetDCD:lVisible := .F.
	oGetDNC:lVisible := .F.
	oSayMapRes:lVisible := .F.
	oChkImpRes:lVisible := .F.
	oChkSangria:lVisible := .F.
	//oSayInfo:lVisible := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a opcao seja Fechar Caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif lFecha
	oBoxSup:cCaption := STR0052 //"Selecione o Supervisor e o Caixa a ser Fechado"
	oBoxUsr:cCaption := STR0053 //"Informacoes sobre o Operador e Caixa a ser Fechado"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a legenda "Detalhes do supervisor"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cAux := STR0018 + chr(13)+chr(10) + chr(13)+chr(10)
	cAux += STR0084 + chr(13)+chr(10)
	cAux += STR0085 + chr(13)+chr(10)
	cAux += STR0086 + chr(13)+chr(10)
	cAux += STR0087 + chr(13)+chr(10)		
	oSayDtSup:cCaption := cAux
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem exibidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxVlrE:lVisible := .T.
	oBoxVlrR:lVisible := .T.
	oBoxVlrD:lVisible := .T.
	oBoxOpc:lVisible := .T.
	oSayRDN:lVisible := .T.
	oSayRCH:lVisible := .T.
	oSayRCC:lVisible := .T.
	oSayRCD:lVisible := .T.
	oSayRNC:lVisible := .T.
	oSayPDN:lVisible := .T.
	oSayPCH:lVisible := .T.
	oSayPCC:lVisible := .T.
	oSayPCD:lVisible := .T.
	oSayPNC:lVisible := .T.
	oSayDDN:lVisible := .T.
	oSayDCH:lVisible := .T.
	oSayDCC:lVisible := .T.
	oSayDCD:lVisible := .T.
	oSayDNC:lVisible := .T.
	oGetRDN:lVisible := .T.
	oGetRCH:lVisible := .T.
	oGetRCC:lVisible := .T.
	oGetRCD:lVisible := .T.
	oGetRNC:lVisible := .T.
	oGetPDN:lVisible := .T.
	oGetPCH:lVisible := .T.
	oGetPCC:lVisible := .T.
	oGetPCD:lVisible := .T.
	oGetPNC:lVisible := .T.
	oGetDDN:lVisible := .T.
	oGetDCH:lVisible := .T.
	oGetDCC:lVisible := .T.
	oGetDCD:lVisible := .T.
	oGetDNC:lVisible := .T.
	oSayMapRes:lVisible := .T.
	oChkImpRes:lVisible := .T.
	oChkSangria:lVisible := .T.
	//oSayInfo:lVisible := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos a serem ocultados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBoxAbr:lVisible := .F.
	oSayTroco:lVisible := .F.
	oGetTroco:lVisible := .F.
	oSayDetTro:lVisible := .F.
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os objetos graficos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxPar:Refresh()
oBoxSup:Refresh()
oBoxUsr:Refresh()
oBoxTp:Refresh()
oBoxAbr:Refresh()
oBoxVlrE:Refresh()
oBoxVlrR:Refresh()
oBoxVlrD:Refresh()
oBoxOpc:Refresh()
oSaySuper:Refresh()
oGetCodSup:Refresh()
oSayNomSup:Refresh()
oGetNomSup:Refresh()
oSaySenSup:Refresh()
oGetSenSup:Refresh()
oSayCxAbr:Refresh()
oGetCxa:Refresh()
oSayDtSup:Refresh()
oBoxAbr:Refresh()
oBoxVlrE:Refresh()
oBoxVlrR:Refresh()
oBoxVlrD:Refresh()
oBoxOpc:Refresh()
oSayMapRes:Refresh()
oSayTroco:Refresh()
oGetTroco:Refresh()
oSayRDN:Refresh()
oSayRCH:Refresh()
oSayRCC:Refresh()
oSayRCD:Refresh()
oSayRNC:Refresh()
oSayPDN:Refresh()
oSayPCH:Refresh()
oSayPCC:Refresh()
oSayPCD:Refresh()
oSayPNC:Refresh()
oSayDDN:Refresh()
oSayDCH:Refresh()
oSayDCC:Refresh()
oSayDCD:Refresh()
oSayDNC:Refresh()
oGetRDN:Refresh()
oGetRCH:Refresh()
oGetRCC:Refresh()
oGetRCD:Refresh()
oGetRNC:Refresh()
oGetPDN:Refresh()
oGetPCH:Refresh()
oGetPCC:Refresh()
oGetPCD:Refresh()
oGetPNC:Refresh()
oGetDDN:Refresh()
oGetDCH:Refresh()
oGetDCC:Refresh()
oGetDCD:Refresh()
oGetDNC:Refresh()
oSayDtSup:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222ValTlºAutor  ³Cesar A. Bianchi    º Data ³  19/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a validacao dos parametros selecionados em cada telaº±±
±±º          ³da Wizard.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn220ValTl(cTela)
Local lRet := .T.

if cTela == "TELA01"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza as validacoes da primeira tela da Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lAbre == lFecha
		lRet := .F.
		Aviso(STR0054,STR0055,{STR0056}) //necessário selecionar um tipo de operação antes de proseguir
	endif
	
	
	
elseif cTela == "TELA02"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza as validacoes da segunda  tela da Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lOpera == lSuper
		lRet := .F.
		Aviso(STR0057,STR0058,{STR0056}) //É necessário selecionar um tipo de usuário antes de proseguir
	endif
	
elseif cTela == "TELA03"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza as validacoes da terceira tela da Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lSuper
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se todos os parametros estao preenchidos caso seja supervisor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !Empty(cCxAbr) .and. !Empty(cCodSup)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se a conta-caixa existe na SA6 e SX5-23³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Fn222ValCx(cCxAbr)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida se o supervisor existe na FID³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if Fn222ValSp(cCodSup)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida a senha do supervisor³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PswOrder(1) 					//Ordena a busca por  Nome do usuario/grupo
					If PswSeek(cCodSup,.T.)			//Posiciona no Cod Usuario informado
						if !PswName(cSenSup)		//Retorna True se senha passada como parametro for igual a senha do nome posicionado acima
							lRet := .F.
							Aviso(STR0059,STR0060,{STR0056}) 		//A digitada não corresponde a senha do supervisor selecionado
						endif
					else
						lRet := .F.
						Aviso(STR0061,STR0062,{STR0056}) //O Usuario digitado nao consta no cadastro de usuarios do Protheus
					endif
				else
					lRet := .F.
					Aviso(STR0063,STR0064,{STR0056})  //O Cod de Supervisor digitado não é um código de supervisor valido.
				endif
			else
				lRet := .F.
				Aviso(STR0065,STR0066,{STR0056})  //O caixa digitado não pertence a uma conta-caixa valida
			endif
		elseif Empty(cCodSup)
			lRet := .F.
			Aviso(STR0063,STR0067,{STR0056}) //Selecione um Cod Supervisor para proseguir com esta operação
		elseif Empty(cCxAbr)
			lRet := .F.
			Aviso(STR0065,STR0068,{STR0056})  //Selecione um caixa para proseguir com esta operação
		endif
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for usuario simples, verifica se possui valor de troco padrao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTroco := Posicione('FID',1,xFilial('FID')+__cUserID,"FID_TROCOP")
		oGetTroco:Refresh()
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifca se o Supervisor/Usuario tem permissao para Abri/Fechar caixas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := iif(lRet,Fn222Acess(),.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for Fechamento, valida se o caixa foi encerrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lRet	
		if !lAbre
			if !Fn222Encer(FID->FID_NCAIXA)
				lRet := .F.
				Aviso(STR0093,STR0094,{STR0056}) //Este caixa nao foi encerrado
			endif
		endif
	endif
	
	
		
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222ValCxºAutor  ³Cesar A. Bianchi    º Data ³  19/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a conta caixa existe na SA6/SX5                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fn222ValCx(cCodConta)
Local aArea:= getArea()
Local lRet := .F.
Local cQuery := ""

cQuery := "SELECT COUNT(*) TOTAL FROM "
cQuery += retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5, " + retsqlname('FID') + " FID "
cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND SA6.A6_COD = '" + cCodConta + "'"
cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
cQuery += " 	AND SX5.X5_TABELA = '23' "
cQuery += " 	AND FID.FID_NCAIXA = SX5.X5_CHAVE "
cQuery += " 	AND FID.FID_BLOQ = '2'" //Usuario nao bloqueado
cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
lRet := iif(SQL->TOTAL > 0,.T.,.F.)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222ValSpºAutor  ³Cesar A. Bianchi    º Data ³  19/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o codigo digitado pertence a um supervisor valido º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fn222ValSp(cSupervisor)
Local lRet := .T.
Local cQuery := ""

cQuery := "SELECT COUNT(*) TOTAL FROM " + retsqlname('FID') + " FID "
cQuery += " WHERE FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND FID.FID_USER = '" + cSupervisor + "'"
cQuery += " 	AND FID.FID_BLOQ = '2' "   //Usuarios nao bloqueados
cQuery += " 	AND FID.FID_SUPER = '1' "  //Usuarios Supervisores
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
lRet := iif(SQL->TOTAL > 0,.T.,.F.)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222AcessºAutor  ³Microsiga           º Data ³  12/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o Usuario/Supervisor tem permissao para abrir ouº±±
±±º          ³fechar caixas                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn222Acess()
Local lRet := .T.
Local cTypeUser := iif(lSuper,STR0069,STR0070)
Local cTypeOper := iif(lAbre,STR0071,STR0072)
Local cUser     := iif(lSuper,cCodSup,__cUserID)
Local cQuery    := ""
Local cMens     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta query sobre a FID para verificar se o usuario pode abrir/fechar caixas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(*) TOTAL FROM " + retsqlname('FID') + " FID "
cQuery += " WHERE FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND FID.FID_USER = '" + cUser + "'"
if lAbre
	cQuery +=  " AND FID.FID_ABRECX = '1' "
else
	cQuery +=  " AND FID.FID_FECHCX = '1' "
endif
cQuery += " AND FID.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a janela de nao-permissao ao usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if SQL->TOTAL <= 0
	lRet := .F.
	cMens := "O " + cTypeUser + STR0073 + cTypeOper + STR0074
	Aviso(STR0075,cMens,{STR0056})
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario nao esta bloqueado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lRet
	cQuery := "SELECT COUNT(*) TOTAL FROM " + retsqlname('FID') + " FID "
	cQuery += " WHERE FID.FID_FILIAL = '" + xFilial('FID') + "'"
	cQuery += " 	AND FID.FID_USER = '" + cUser + "'"
	cQuery += " 	AND FID.FID_BLOQ = '2' "	
	cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a janela de usuario bloqueado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if SQL->TOTAL <= 0
		lRet := .F.
		Aviso(STR0075,STR0083,{STR0056})
	endif
endif
SQL->(dbCloseArea())


Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222CleanºAutor  ³Cesar A. Bianchi    º Data ³  19/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa a senha do supervisor caso seja pressionado o botao   º±±
±±º          ³voltar da Wizard                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn222Clean()

cSenSup := Space(20)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222Run  ºAutor  ³Cesar A. Bianchi    º Data ³  19/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza as consequencias da abertura/fechamento de caixa    º±±
±±º          ³Processa os registros da FIBxSA6                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fn222Run()
Local cUser   := ""
Local cQuery  := ""
Local cNextLt := ""
Local nSaveSX8:= GetSX8Len()
Local lRet 	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo de usuario e o codigo da conta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lSuper
	cCodConta := cCxAbr
	cUser     := Posicione('FID',2,xFilial('FID')+cCodConta,"FID_USER")
else
	cUser 	  := __cUserID
	cCodConta := Posicione('FID',1,xFilial('FID')+cUser,'FID_NCAIXA')
endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza os procedimentos de abertura de caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lAbre
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o caixa ja esta aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT(*) TOTAL FROM "
	cQuery += retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5, " + retsqlname('FIB') + " FIB, "  + retsqlname('FID') + " FID "
	cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
	cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
	cQuery += " 	AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
	cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
	cQuery += " 	AND SA6.A6_COD = '" + cCodConta + "'"
	cQuery += " 	AND SA6.A6_DATAABR <> ' ' "
	cQuery += " 	AND SA6.A6_DATAFCH = ' ' "
	cQuery += " 	AND SA6.A6_COD = FID.FID_NCAIXA "
	cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
	cQuery += " 	AND SX5.X5_TABELA = '23' "
	cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
	cQuery += " 	AND FIB.FIB_USER = '" + cUser + "'"
	cQuery += " 	AND FIB.FIB_DTABR <> ' ' "
	cQuery += " 	AND FIB.FIB_DTFCH = ' ' "
	cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	if SQL->TOTAL > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe mensagem de caixa em aberto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso(STR0076,STR0077,{STR0056}) //Este caixa encontra-se atualmente em aberto. Execute o procedimento de fechamento de caixa antes de realizar uma nova abertura.
		lRet := .F.
	else
		BEGIN TRANSACTION
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra abertura na SA6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT MAX(SA6.R_E_C_N_O_) REC FROM " + retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5 "
		cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
		cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
		cQuery += " 	AND SA6.A6_COD = '" + cCodConta + "'"
		cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
		cQuery += " 	AND SX5.X5_TABELA = '23' "
		cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		
		dbSelectArea('SA6')
		SA6->(dbGoTo(SQL->REC))
		SQL->(dbCloseArea())
		RecLock('SA6',.F.)
		SA6->A6_DATAABR  := iif(valtype(SA6->A6_DATAABR) == 'D',dDataBase,dtos(dDataBase))
		SA6->A6_HORAABR  := Time()
		SA6->A6_DATAFCH	 := CTOD("  /  /    ")
		SA6->A6_HORAFCH	 := ""
		SA6->(msUnlock())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o proximo codigo de Lote da FIB³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNextLt	:= GetSXENum("FIB", "FIB_LOTE")
		While (GetSX8Len() > nSaveSX8)
			ConfirmSX8()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra abertura na FIB³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea('FIB')
		FIB->(dbSetOrder(1))
		RecLock('FIB',.T.)
		FIB->FIB_FILIAL := xFilial('FIB')
		FIB->FIB_LOTE   := cNextLt
		FIB->FIB_USER   := cUser
		FIB->FIB_DTABR  := iif(valtype(FIB->FIB_DTABR) == 'D',dDataBase,dtos(dDataBase))
		FIB->FIB_HRABR  := Time()
		FIB->FIB_VLRABR := nTroco
		FIB->FIB_TPABRE := iif(lSuper,"S","O")
		FIB->FIB_USABRE := iif(lSuper,cCodSup,__cUserID)
		FIB->FIB_ENCER	:= '2' 
		FIB->(msUnlock())
		END TRANSACTION
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe alerta comunicando o final do processamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lRet
			MsgInfo(STR0078) //Operação de abertura de caixa concluida com sucesso.
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza os procedimentos de abertura de caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif lFecha
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o caixa ja esta fechado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT(*) TOTAL FROM "
	cQuery += retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5, " + retsqlname('FIB') + " FIB, "  + retsqlname('FID') + " FID "
	cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
	cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
	cQuery += " 	AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
	cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
	cQuery += " 	AND SA6.A6_COD = '" + cCodConta + "'"
	cQuery += " 	AND SA6.A6_DATAABR = ' ' "
	cQuery += " 	AND SA6.A6_DATAFCH <> ' ' "
	cQuery += " 	AND SA6.A6_COD = FID.FID_NCAIXA "
	cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
	cQuery += " 	AND SX5.X5_TABELA = '23' "
	cQuery += " 	AND FIB.FIB_USER = '" + cUser + "'"
	cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
	cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	if SQL->TOTAL > 0
		Aviso(STR0079,STR0080,{STR0056}) //Este caixa ja foi fechado anteriormente. Nenhum procedimento foi executado.
		lRet := .F.
	else
		BEGIN TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra fechamento na SA6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT MAX(SA6.R_E_C_N_O_) REC FROM " + retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5 "
		cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
		cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
		cQuery += " 	AND SA6.A6_COD = '" + cCodConta + "'"
		cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
		cQuery += " 	AND SX5.X5_TABELA = '23' "
		cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
			
		dbSelectArea('SA6')
		SA6->(dbGoTo(SQL->REC))
		RecLock('SA6',.F.)
		SA6->A6_DATAABR := CTOD("  /  /    ")
		SA6->A6_HORAABR := ""
		SA6->A6_DATAFCH	:= iif(Valtype(SA6->A6_DATAFCH) == 'D',dDataBase,dtos(dDataBase))
		SA6->A6_HORAFCH	:= Time()
		SA6->(msUnlock())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registra fechamento na FIB³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT FIB.R_E_C_N_O_ REC FROM " + retsqlname('FIB') + " FIB "
		cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
		cQuery += " 	AND FIB.FIB_USER = '" + cUser + "'"
		cQuery += " 	AND FIB.FIB_DTABR <> ' ' "
		cQuery += " 	AND FIB.FIB_HRABR <> ' ' "
		cQuery += " 	AND FIB.FIB_DTFCH = ' ' "
		cQuery += " 	AND FIB.FIB_HRFCH = ' ' "
		cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
		if SQL->REC > 0
			dbSelectArea('FIB')
			FIB->(dbGoTo(SQL->REC))
			RecLock('FIB',.F.)
			FIB->FIB_DTFCH := iif(Valtype(FIB->FIB_DTFCH) == 'D',dDataBase,dtos(dDataBase))
			FIB->FIB_HRFCH := Time()
			FIB->FIB_VLRDN := nPDN
			FIB->FIB_VLRCH := nPCH
			FIB->FIB_VLRCC := nPCC
			FIB->FIB_VLRCD := nPCD
			FIB->FIB_VLRNC := nPNC
			FIB->FIB_TPFECH := iif(lSuper,"S","O")
			FIB->FIB_USFECH := iif(lSuper,cCodSup,__cUserID) 
			FIB->(msUnlock())
		endif
		END TRANSACTION

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se fechamento OK, imprime relatorio caso esteja marcado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lRet .and. lImpRes
			If Pergunte("FIN222", .T.)
				if MV_PAR01 == 1
					//Imprime via ECF
					nHdlECF  := IFAbrir( LJGetStation("IMPFISC") , LJGetStation("PORTIF" ) )  
					Processa({|| Fnr220Ecf(cUser,FIB->FIB_LOTE),STR0081}) 
					IFFechar( nHdlECF , LJGetStation("PORTIF"))  //::Impressora ECF (autenticadora)
				else
					//Imprime via SetPrint
					Aviso(STR0089,STR0090+STR0091,{STR0092})
					FINR220(FIB->FIB_USER,FIB->FIB_LOTE)
				endif
			EndIf
		endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe alerta comunicando o final do processamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lRet
			MsgInfo(STR0082) //Operação de fechamento de caixa concluida com sucesso.
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se fechamento OK, executa rotina de sangrias caso esteja marcado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lRet .and. lSangria
			if ExistBlock("FN222Sgr")
				ExecBlock( "FN222Sgr", .F., .F., {cUser,cCodConta,FIB->FIB_LOTE,{nPDN,nPCH,nPCC,nPCD,nPNC}} )  
			else
				Fina100()
			endif
		endif
		
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pontos de Entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lAbre .and. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada executado na abertura do caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FN222Abr")
		//Params:					   	UserLogin,Cod Caixa,Nro Lote,DataAbre      , HoraAbre, ValorTroco, TpUserAbre    , CodUserAbre
		ExecBlock( "FN222Abr", .F., .F., {cUser,cCodConta,cNextLt,FIB->FIB_DTABR,FIB->FIB_HRABR,nTroco,FIB->FIB_TPABRE,FIB->FIB_USABRE})
	Endif
	
elseif lFecha .and. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada executado no fechamento do Caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FN222Fec")
		//Params:					   	UserLogin,Cod Caixa,Nro Lote     ,DataFecha     ,HoraFecha,      VlDn ,VLCh,VlCC,VLCD, TpUserFecha     ,CodUserFecha
		ExecBlock( "FN222Fec", .F., .F., {cUser,cCodConta,FIB->FIB_LOTE,FIB->FIB_DTFCH,FIB->FIB_HRFCH,{nPDN,nPCH,nPCC,nPCD,nPNC},FIB->FIB_TPFECH,FIB->FIB_USFECH})	
	Endif		
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222Soma ºAutor  ³Cesar A. Bianchi    º Data ³  02/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a somatoria dos totais movimentados pelo caixa duranº±±
±±º          ³suas operacoes, para que o valor possa ser exibido na wizardº±±
±±º          ³de "Fechamento de Caixa"									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn222Soma()
Local aArea     := getArea()
Local cQuery    := ""

if lFecha	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo de usuario e o codigo da conta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lSuper
		cCodConta := cCxAbr
		cUser := Posicione('FID',2,xFilial('FID')+cCodConta,"FID_USER")
	else
		cUser 	  := __cUserID
		cCodConta := Posicione('FID',1,xFilial('FID')+cUser,'FID_NCAIXA')
	endif
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo do lote a ser fechado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT FIB.FIB_LOTE LOTE, FIB.FIB_VLRABR VLRABRE FROM " + retsqlname('FIB') + " FIB "
	cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
	cQuery += " 	AND FIB.FIB_USER = '" + cUser + "'"
	cQuery += " 	AND FIB.FIB_DTABR <> ' ' "
	cQuery += " 	AND FIB.FIB_HRABR <> ' ' "
	cQuery += " 	AND FIB.FIB_DTFCH = ' ' "
	cQuery += " 	AND FIB.FIB_HRFCH = ' ' "
	cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)
    
	cLote := QRY->LOTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os totais efetivados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nRDN := FN222Calc(cCodConta,cLote,'1',.F.)	
	nRCH := FN222Calc(cCodConta,cLote,'2',.F.)
	nRCC := FN222Calc(cCodConta,cLote,'4',.F.)
	nRCD := FN222Calc(cCodConta,cLote,'3',.F.)
	nRNC := FN222Calc(cCodConta,cLote,'5',.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se considera o valor de troco, de acordo com parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if GetNewPar('MV_FINTRC',.F.)	
		nRDN += QRY->VLRABRE
	endif
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Refresh nos objetos de totais efetivados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetRCD:Refresh()
	oGetRCH:Refresh()
	oGetRCC:Refresh()
	oGetRCD:Refresh() 
	oGetRNC:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha Area³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ	
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
endif

RestArea(aArea)	
Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222Calc ºAutor  ³Cesar A. Bianchi    º Data ³  30/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza os calculos do total movimentado pelo caixa em Dinheº±±
±±º          ³iro, cheques, cartao credito, cartao debito.  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FN222Calc(cCaixa,cLote,cForma,lRetString)
Local aArea := getArea()
Local cQuery := ""
Local uRet   
Local nTotal := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta os totais movimentados de acordo com o caixa + lote e a forma de pagamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "	SELECT SUM(FIC.FIC_VLRREC) TOTAL FROM " 
cQuery += retsqlname('FIC') + " FIC, " + retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
cQuery += " WHERE FIC.FIC_FILIAL = '" + xFilial('FIC') + "'"
cQuery += "     AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
cQuery += "     AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += "		AND FIC.FIC_LOTE = '" + cLote + "'"
cQuery += " 	AND FIC.FIC_TPPAG = '" + cForma + "'"
cQuery += " 	AND FID.FID_NCAIXA = '" + cCaixa + "'"
cQuery += " 	AND FIB.FIB_LOTE = FIC.FIC_LOTE "
cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FIC.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotal := SQL->TOTAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta os totais movimentados de acordo com o caixa + lote (somente MIX)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if '1' $ cForma 
	cQuery := "	SELECT SUM(FIC.FIC_MIXDIN) TOTAL FROM "
elseif '2' $ cForma
	cQuery := "	SELECT SUM(FIC.FIC_MIXCHQ) TOTAL FROM "
elseif '3' $ cForma
	cQuery := "	SELECT SUM(FIC.FIC_MIXDEB) TOTAL FROM "	               
elseif '4' $ cForma
	cQuery := "	SELECT SUM(FIC.FIC_MIXCRD) TOTAL FROM "
elseif '5' $ cForma
	cQuery := "	SELECT SUM(FIC.FIC_MIXNCC) TOTAL FROM "
endif
cQuery += retsqlname('FIC') + " FIC, " + retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
cQuery += " WHERE FIC.FIC_FILIAL = '" + xFilial('FIC') + "'"
cQuery += "     AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
cQuery += "     AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += "		AND FIC.FIC_LOTE = '" + cLote + "'"
cQuery += " 	AND FIC.FIC_TPPAG = '6'" //Mix de Pagamento
cQuery += " 	AND FID.FID_NCAIXA = '" + cCaixa + "'"
cQuery += " 	AND FIB.FIB_LOTE = FIC.FIC_LOTE "
cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FIC.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotal += SQL->TOTAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o tipo do retorno, de acordo com o parametro lRetString³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lRetString
	uRet := alltrim(Transform(nTotal,"@E 999,999,999.99"))
else
	uRet := nTotal
endif
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
RestArea(aArea)

Return uRet
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN222Dif  ºAutor  ³Cesar A. Bianchi    º Data ³  02/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o calculo das diferencas entre o valor Efetivado e oº±±
±±º          ³valor real em caixa	                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn222Dif(cTipo)
    
//ÚÄÄÄÄÄÄÄÄ¿
//³Dinheiro³
//ÀÄÄÄÄÄÄÄÄÙ
if cTipo == '1'
	nDDN :=  (FN222Calc(cCodConta,cLote,'1',.F.)  - nPDN ) * (-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incrementa o valor do troco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if GetNewPar('MV_FINTRC',.F.)
		nDDN += Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR")
	endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colore a legenda do objeto de vermelho caso VALOR NEGATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDDN < 0
		oGetDDN:nClrText 		:= CLR_HRED
		oGetDDN:oFont 			:= oFontBold
	else
		oGetDDN:nClrText 		:= CLR_BLACK
		oGetDDN:oFont 			:= oFontNorm	
	endif
	oGetDDN:Refresh()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cheques       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif cTipo == '2'
	nDCH :=  (FN222Calc(cCodConta,QRY->LOTE,'2',.F.) - nPCH ) * (-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colore a legenda do objeto de vermelho caso VALOR NEGATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDCH < 0
		oGetDCH:nClrText 		:= CLR_HRED
		oGetDCH:oFont 			:= oFontBold
	else
		oGetDCH:nClrText 		:= CLR_BLACK
		oGetDCH:oFont 			:= oFontNorm	
	endif
	oGetDCH:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cartao de Credito |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif cTipo == '3'  
	nDCC :=  (FN222Calc(cCodConta,cLote,'4',.F.) - nPCC ) * (-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colore a legenda do objeto de vermelho caso VALOR NEGATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDCC < 0
		oGetDCC:nClrText 		:= CLR_HRED
		oGetDCC:oFont 			:= oFontBold
	else
		oGetDCC:nClrText 		:= CLR_BLACK
		oGetDCC:oFont 			:= oFontNorm	
	endif
	oGetDCC:Refresh()
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cartao de Debito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif cTipo == '4'
	nDCD :=  (FN222Calc(cCodConta,cLote,'3',.F.) - nPCD ) * (-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colore a legenda do objeto de vermelho caso VALOR NEGATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDCD < 0
		oGetDCD:nClrText 		:= CLR_HRED
		oGetDCD:oFont 			:= oFontBold
	else
		oGetDCD:nClrText 		:= CLR_BLACK
		oGetDCD:oFont 			:= oFontNorm	
	endif
	oGetDCD:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³NCC              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif cTipo == '5'
	nDNC :=  (FN222Calc(cCodConta,cLote,'5',.F.) - nPNC ) * (-1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colore a legenda do objeto de vermelho caso VALOR NEGATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nDNC < 0
		oGetDNC:nClrText 		:= CLR_HRED
		oGetDNC:oFont 			:= oFontBold
	else
		oGetDNC:nClrText 		:= CLR_BLACK
		oGetDNC:oFont 			:= oFontNorm	
	endif
	oGetDNC:Refresh()
	
endif
	
Return .T.  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fn222EncerºAutor  ³Cesar A. Bianchi    º Data ³  17/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o caixa ja foi encerrado 						  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP811/912 - Integracao Protheus x Classis .NET             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn222Encer(cCodCxa)
Local lRet := .T.
Local cQuery := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe algum registro na FIB nao encerrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT COUNT(*) TOTAL FROM "
cQuery += retsqlname('FIB') + " FIB, " + retsqlname('FID') + " FID "
cQuery += " WHERE FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND FID.FID_NCAIXA = '" + cCodCxa + "'"
cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
cQuery += " 	AND FIB.FIB_ENCER = '2' " //Caixa Nao Encerrado
cQuery += " 	AND FID.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
lRet := !SQL->TOTAL > 0
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)

Return lRet 
