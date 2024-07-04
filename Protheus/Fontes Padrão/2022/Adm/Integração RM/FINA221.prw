#INCLUDE "FINA221.CH"
#INCLUDE "PROTHEUS.CH"                                 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINA221  ³ Autor ³ Cesar B. e Karen H    ³ Data ³ 09/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivos ³ Cadastro de Operador de Caixa.                			  ³±±
±±³          ³                                                            ³±±
±±³          ³ Define o perfil de cada usuario para operacao de caixa.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA221()                                                  ³±±
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
Function FINA221()
Private cCadastro := OemToAnsi( STR0001 )                     
Private aRotina := {;
					{ OemtoAnsi(STR0002), "AXPESQUI"  , 0, 1 },;		// Pesquisar
					{ OemtoAnsi(STR0003), "FIN221Manu" , 0, 2 },; 		// Visualizar
					{ OemtoAnsi(STR0004), "FIN221Manu" , 0, 3, 81 },;	// Incluir
					{ OemtoAnsi(STR0005), "FIN221Manu" , 0, 4, 82 },;	// Alterar
					{ OemtoAnsi(STR0006), "FIN221Manu" , 0, 5, 3  },;	// Excluir
					{ OemtoAnsi(STR0044), "Fn221Leg"   , 0, 7, 3 } }	// Legenda
										

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o ambiente esta preparado com a UPDATE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if TCCanOpen(RetSqlName('FID'))
	mBrowse( 6, 1,22,75,"FID" )
else
	Aviso(STR0014,STR0015,{STR0016}) //Não foi possível executar esta rotina pois este ambiente nao possui a update de Caixa-Tesouraria aplicada.
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FIN221ManuºAutor  ³Cesar A. e Karen H. º Data ³  09/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Manutencao de Cadastro de Operadores de Caixa               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³FIN221Manu( ExpC1, ExpN1, ExpN2 )                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Alias do cabecalho do cadastro de operador           º±±
±±º          ³ExpN1: Alias do cabecalho do cadastro de operador           º±±
±±º          ³ExpN2: Opcao da rotina                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FIN221Manu( cAlias, nReg, nOpc)                   
Local oMainWnd
Local aSize		  := MsAdvSize(, .F., 430 )
Local aPosObj     := {}
Local aTipDesMul  := {"",STR0031,STR0032}
Local cOpera	  := ""
Private cTipMul	  := ""
Private cTipDes	  := ""
Private cTipJur	  := ""
Private cUsuario  := Space(6) 						//Variavel com o Cod de Usuario selecionado.
Private lBloq	  := .F. 							//Variavel tipo flag do objeto CheckBox - Usuario Bloqueado 
Private lDesc     := .F. 							//Variavel tipo flag do objeto CheckBox - Permite Desconto
Private lMultas   := .F.  							//Variavel tipo flag do objeto CheckBox - Permite Multa
Private lJuros	  := .F.  							//Variavel tipo flag do objeto CheckBox - Permite Juros
Private lTroco	  := .F.  							//Variavel tipo flag do objeto CheckBox - Troco Padrao
Private lAbreCx	  := .F. 							//Variavel tipo flag do objeto CheckBox - Permite Abrir Caixa
Private lFechaCx  := .F. 							//Variavel tipo flag do objeto CheckBox - Permite Fechar Caixa
Private lSuper	  := .F. 							//Variavel tipo flag do objeto CheckBox - Usuario Supervisor
Private lEstor	  := .F.							//Variavel tipo flag do objeto CheckBox - Permite Estornar Operacoes
Private lChPre	  := .F.	
Private nDesMax   := 0 								//Variavel auxiliar com o total maximo desconto permitido
Private nMulMax   := 0 			  					//Variavel auxiliar com o total maximo multa permitido                          
Private nJurMax   := 0 			  					//Variavel auxiliar com o total maximo juros permitido                          
Private nTroco	  := 0 			  					//Variavel auxiliar com o valor troco padrao
Private nLimChq	  := 0	
Private cNome  										//Variavel auxiliar com o nome do usuario selecionado
Private oDlg										//Objeto grafico do tipo "Dialog" - Main Principal
Private oSayUser									//Objeto grafico do tipo "Say" - Cod Usuario
Private oSayMaxDes									//Objeto grafico do tipo "Say" - Maximo Desc. Permitido
Private oSayMaxMul									//Objeto grafico do tipo "Say" - Maximo Multa Permitido
Private oSayMaxJur									//Objeto grafico do tipo "Say" - Maximo Juros Permitido
Private oSayTipMul
Private oSayTipDes
Private oCmbTipMul
Private oCmbTipDes
Private oGetUser									//Objeto grafico do tipo "Get" - Cod do Usuario
Private oGetNome									//Objeto grafico do tipo "Get" - Nome do Usuario
Private oGetDesMax									//Objeto grafico do tipo "Get" - Valor Maximo Desconto
Private oGetMulMax									//Objeto grafico do tipo "Get" - Valor Maximo Multa
Private oGetMulJur									//Objeto grafico do tipo "Get" - Valor Maximo Juros
Private oBoxChk										//Objeto grafico do tipo "Box" - Privilegios do Usuario
Private oChkBloq									//Objeto grafico do tipo "Check" - Usuario Bloqueado
Private oChkDesc									//Objeto grafico do tipo "Check" - Permite Desconto
Private oChkMul										//Objeto grafico do tipo "Check" - Permite Multa
Private oChkJur										//Objeto grafico do tipo "Check" - Permite Juros
Private oChkAbreCx									//Objeto grafico do tipo "Check" - Permite abrir caixa
Private oChkFechCx									//Objeto grafico do tipo "Check" - Permite fechar caixa
Private oChkSuper									//Objeto grafico do tipo "Check" - Usuario Supervisor
Private oChkEstor									//Objeto grafico do tipo "Check" - Permite Estorar Operacoes
Private oBtnOk										//Objeto grafico do tipo "Button" - Ok
Private oBtnCancel									//Objeto grafico do tipo "Button" - Cancelar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja alteracao ou exclusao, reserva o registro para edicao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5
	cUsuario  := FID->FID_USER
	cNome	  := FID->FID_NOME
	lBloq	  := iif(FID->FID_BLOQ == '1',.T.,.F.) 
	lDesc     := iif(FID->FID_DESC == '1',.T.,.F.)
	lMultas   := iif(FID->FID_MULTA == '1',.T.,.F.)
	lJuros	  := iif(FID->FID_JUROS == '1',.T.,.F.)
 	lAbreCx	  := iif(FID->FID_ABRECX == '1',.T.,.F.)
	lFechaCx  := iif(FID->FID_FECHCX == '1',.T.,.F.)
	lSuper	  := iif(FID->FID_SUPER == '1',.T.,.F.)
	lEstor	  := iif(FID->FID_ESTOR == '1',.T.,.F.)
	lChPre    := iif(FID->FID_CHEQP == '1',.T.,.F.)
	nLimChq	  := FID->FID_QTDCHQ 	
	nDesMax   := FID->FID_MAXDES
 	nMulMax   := FID->FID_MAXMUL
 	nJurMax	  := FID->FID_MAXJUR
 	nTroco	  := FID->FID_TROCOP
 	lTroco	  := nTroco > 0
 	if lDesc
		cTipDes := iif(FID->FID_TPDES == "V",STR0031,STR0032)
 	endif
  	if lMultas
	 	cTipMul := iif(FID->FID_TPMUL == "V",STR0031,STR0032)
 	endif
  	if lJuros
	 	cTipJur := iif(FID->FID_TPJUR == "V",STR0031,STR0032)
 	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Bloqueia o registro nas rotinas de alteracao e exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .or. nOpc == 5
	if !SoftLock("FID")
		Return
	endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o cabecalho do formulario principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nOpc == 2 
	cOpera :=  " - " + STR0003
elseif nOpc == 3 
	cOpera := " - " + STR0004
elseif nOpc == 4
	cOpera := " - " + STR0005
elseif nOpc == 5
	cOpera := " - " + STR0006
endif
aadd(aPosObj, {10,30,200,20})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o formulario Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlg:= MSDIALOG():Create()
oDlg:cName     		:= "ODlgChq"
oDlg:cCaption  		:= STR0001 + cOpera 
oDlg:nLeft     		:= 50
oDlg:nTop      		:= 20
oDlg:nWidth    		:= 450
oDlg:nHeight   		:= 550
oDlg:lShowHint 		:= .F.
oDlg:lCentered 		:= .T. 
oDlg:bInit 			:= {|| EnchoiceBar(oDlg, {||( Fin221Grv(nOpc) )} , {||( oDlg:End() )},,{}) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotulo Usuario      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayUser:= TSAY():Create(oDlg)
oSayUser:cName				:= "oSayUser"
oSayUser:cCaption 			:= STR0013 //"Usuário"
oSayUser:nLeft 				:= aPosObj[1][1]
oSayUser:nTop 				:= aPosObj[1][2]
oSayUser:nWidth 	   		:= aPosObj[1][3]
oSayUser:nHeight 			:= aPosObj[1][4]
oSayUser:lShowHint 			:= .F.
oSayUser:lReadOnly 			:= nOpc == 2
oSayUser:Align 				:= 0
oSayUser:lVisibleControl	:= .T.
oSayUser:lWordWrap 	  		:= .F.
oSayUser:lTransparent 		:= .F.   
oSayUser:nClrText 	  		:= CLR_HBLUE	

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Get User  ³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
oGetUser:= TGET():Create(oDlg)
oGetUser:cName 	 			:= "oGetUser"
oGetUser:nLeft 	 			:= aPosObj[1][1] + 60 
oGetUser:nTop 	 			:= aPosObj[1][2]
oGetUser:nWidth 	 		:= aPosObj[1][3] - 40
oGetUser:nHeight 	 		:= aPosObj[1][4]
oGetUser:lShowHint 			:= .F.
oGetUser:lReadOnly 			:= nOpc == 2
oGetUser:Align 	 			:= 0
oGetUser:lVisibleControl 	:= .T.
oGetUser:lPassword 			:= .F.
oGetUser:lHasButton			:= .F. 
oGetUser:cVariable 			:= "cUsuario"
oGetUser:cF3       			:= "US2"     
oGetUser:bSetGet 	 		:= {|u| If(PCount()>0,cUsuario:=u,cUsuario)}
oGetUser:bWhen     			:= {|| nOpc == 3}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get Nome User     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetNome:= TGET():Create(oDlg)
oGetNome:cName 	 			:= "oGetNome"
oGetNome:nLeft 	 			:= aPosObj[1][1] + 230
oGetNome:nTop 	 			:= aPosObj[1][2]
oGetNome:nWidth 			:= aPosObj[1][3]
oGetNome:nHeight 			:= aPosObj[1][4]
oGetNome:lShowHint 			:= .F.
oGetNome:lReadOnly 			:= nOpc == 2
oGetNome:Align 	 			:= 0
oGetNome:lVisibleControl 	:= .T.
oGetNome:lPassword 			:= .F.
oGetNome:lHasButton			:= .F. 
oGetNome:cVariable 			:= "cNome"
oGetNome:bSetGet 			:= {|u| If(PCount()>0,cNome:=u,cNome)}
oGetNome:bWhen     			:= {|| .F.} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Box com itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBoxChk:= TGROUP():Create(oDlg)
oBoxChk:cName 	    		:= "oBoxChk"
oBoxChk:cCaption    		:= STR0012 //"Privilegios do Usuario"
oBoxChk:nLeft 	    		:= aPosObj[1][1] - 5
oBoxChk:nTop  	    		:= aPosObj[1][2] + 30
oBoxChk:nWidth 	    		:= aPosObj[1][3] + 234
oBoxChk:nHeight 			:= aPosObj[1][4] + 390
oBoxChk:lShowHint   		:= .F.
oBoxChk:lReadOnly   		:= nOpc == 2
oBoxChk:Align       		:= 0
oBoxChk:lVisibleControl 	:= .T.   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checkbox "Usuario Bloqueado"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkBloq := TCHECKBOX():Create(oDlg)
oChkBloq:cName 		:= "oChkBloq"
oChkBloq:cCaption 	:= STR0011 //"Usuário bloqueado?"
oChkBloq:nLeft 		:= aPosObj[1][1]
oChkBloq:nTop  		:= aPosObj[1][2] + 50
oChkBloq:nWidth 	:= aPosObj[1][3]
oChkBloq:nHeight 	:= aPosObj[1][4]
oChkBloq:lShowHint 	:= .F.
oChkBloq:lReadOnly 	:= nOpc == 2
oChkBloq:Align 		:= 0
oChkBloq:cVariable 	:= "lBloq"
oChkBloq:bSetGet 	:= {|u| If(PCount()>0,lBloq:=u,lBloq) }
oChkBloq:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³checkbox "Pode alterar Desconto"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkDesc := TCHECKBOX():Create(oDlg)
oChkDesc:cName 				:= "oChkDesc"
oChkDesc:cCaption 			:= STR0008 //"Pode dar desconto?"
oChkDesc:nLeft 				:= aPosObj[1][1]
oChkDesc:nTop 				:= aPosObj[1][2] + 80
oChkDesc:nWidth 			:= aPosObj[1][3]
oChkDesc:nHeight 			:= aPosObj[1][4]
oChkDesc:lShowHint 			:= .F.
oChkDesc:lReadOnly 			:= nOpc == 2
oChkDesc:Align 				:= 0
oChkDesc:cVariable 			:= "lDesc"
oChkDesc:bSetGet 			:= {|u| If(PCount()>0,lDesc:=u,lDesc) }
oChkDesc:lVisibleControl 	:= .T.
oChkDesc:blClicked    		:= {|| Fn221Upd()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Tipo de Desconto"     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTipDes:= TSAY():Create(oDlg)
oSayTipDes:cName			:= "oSayMaxDes"
oSayTipDes:cCaption 		:= STR0029 //"Tipo de Desconto:"
oSayTipDes:nLeft 			:= aPosObj[1][1] + 30
oSayTipDes:nTop 			:= aPosObj[1][2] + 110
oSayTipDes:nWidth 	   		:= 140
oSayTipDes:nHeight 			:= aPosObj[1][4]
oSayTipDes:lShowHint 		:= .F.
oSayTipDes:lReadOnly 		:= nOpc == 2
oSayTipDes:Align 			:= 0
oSayTipDes:lVisibleControl	:= .T.
oSayTipDes:lWordWrap 	  	:= .F.
oSayTipDes:lTransparent 	:= .F.  
oSayTipDes:nClrText			:= iif(lMultas,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Monta a Combo "Tipo de Desconto"      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCmbTipDes:= TCOMBOBOX():Create(oDlg)
oCmbTipDes:cName 	  		:= "oCmbTipDes"
oCmbTipDes:nLeft 	  		:= aPosObj[1][1] + 130
oCmbTipDes:nTop 	  		:= aPosObj[1][2] + 110
oCmbTipDes:nWidth 	  		:= 90
oCmbTipDes:nHeight   		:= 20
oCmbTipDes:lShowHint 		:= .F.
oCmbTipDes:lReadOnly 		:= nOpc == 2
oCmbTipDes:Align 	  		:= 0
oCmbTipDes:cVariable 		:= "cTipDes"
oCmbTipDes:bSetGet   		:= {|u| If(PCount()>0,cTipDes:=u,cTipDes)}
oCmbTipDes:lVisibleControl  := .T.
oCmbTipDes:aItems    		:= aClone(aTipDesMul)
oCmbTipDes:bWhen     		:= {|| lDesc} 
oCmbTipDes:bChange			:= {|| }   
If nOpc = 2 .or. nOpc = 4 .or. nOpc = 5
	oCmbTipDes:nAt 			:= iif(FID->FID_TPDES == "V",2,3)
endif
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Valor Maximo Desconto"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayMaxDes:= TSAY():Create(oDlg)
oSayMaxDes:cName			:= "oSayMaxDes"
oSayMaxDes:cCaption 		:= STR0017 //"Valor Max Desconto:"
oSayMaxDes:nLeft 			:= aPosObj[1][1] + 245
oSayMaxDes:nTop 			:= aPosObj[1][2] + 110
oSayMaxDes:nWidth 	   		:= 140
oSayMaxDes:nHeight 			:= aPosObj[1][4]
oSayMaxDes:lShowHint 		:= .F.
oSayMaxDes:lReadOnly 		:= nOpc == 2
oSayMaxDes:Align 			:= 0
oSayMaxDes:lVisibleControl	:= .T.
oSayMaxDes:lWordWrap 	  	:= .F.
oSayMaxDes:lTransparent 	:= .F.   
oSayMaxDes:nClrText			:= iif(lMultas,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get "Max Desconto" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDesMax:= TGET():Create(oDlg)
oGetDesMax:cName 	 		:= "oGetDesMax"
oGetDesMax:nLeft 	 		:= aPosObj[1][1] + 350
oGetDesMax:nTop 	 		:= aPosObj[1][2] + 110
oGetDesMax:nWidth 			:= aPosObj[1][3] - 130
oGetDesMax:nHeight 			:= aPosObj[1][4]
oGetDesMax:lShowHint 		:= .F.
oGetDesMax:lReadOnly 		:= nOpc == 2
oGetDesMax:Align 	 		:= 0
oGetDesMax:lVisibleControl	:= .T.
oGetDesMax:lPassword 		:= .F.
oGetDesMax:lHasButton		:= .F. 
oGetDesMax:cVariable 		:= "nDesMax"
oGetDesMax:bSetGet 			:= {|u| If(PCount()>0,nDesMax:=u,nDesMax)}
oGetDesMax:bWhen     		:= {|| lDesc} 
oGetDesMax:Picture 			:= "9999.99"
                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³checkbox Pode Alterar Multa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                   
oChkMul:= TCHECKBOX():Create(oDlg)
oChkMul:cName 				:= "oChkJur"
oChkMul:cCaption 			:= STR0010 //"Pode liberar multas?"
oChkMul:nLeft 	 			:= aPosObj[1][1]
oChkMul:nTop 	 			:= aPosObj[1][2] + 140
oChkMul:nWidth 				:= aPosObj[1][3]
oChkMul:nHeight 			:= aPosObj[1][4]
oChkMul:lShowHint 			:= .F.
oChkMul:lReadOnly 			:= nOpc == 2
oChkMul:Align 				:= 0
oChkMul:cVariable 			:= "lMultas"
oChkMul:bSetGet 			:= {|u| If(PCount()>0,lMultas:=u,lMultas) }
oChkMul:lVisibleControl 	:= .T.  
oChkMul:blClicked    		:= {|| Fn221Upd()}
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Tipo de Multa"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTipMul:= TSAY():Create(oDlg)
oSayTipMul:cName			:= "oSayMaxMul"
oSayTipMul:cCaption 		:= STR0030 //"Tipo de Multa:"
oSayTipMul:nLeft 			:= aPosObj[1][1] + 30
oSayTipMul:nTop 			:= aPosObj[1][2] + 170
oSayTipMul:nWidth 	   		:= 140
oSayTipMul:nHeight 			:= aPosObj[1][4]
oSayTipMul:lShowHint 		:= .F.
oSayTipMul:lReadOnly 		:= nOpc == 2
oSayTipMul:Align 			:= 0
oSayTipMul:lVisibleControl	:= .T.
oSayTipMul:lWordWrap 	  	:= .F.
oSayTipMul:lTransparent 	:= .F. 
oSayTipMul:nClrText			:= iif(lMultas,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Monta a Combo "Tipo de Multa"         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCmbTipMul:= TCOMBOBOX():Create(oDlg)
oCmbTipMul:cName 	  		:= "oCmbTipMul"
oCmbTipMul:nLeft 	  		:= aPosObj[1][1] + 130
oCmbTipMul:nTop 	  		:= aPosObj[1][2] + 170
oCmbTipMul:nWidth 	  		:= 90
oCmbTipMul:nHeight   		:= 20
oCmbTipMul:lShowHint 		:= .F.
oCmbTipMul:lReadOnly 		:= nOpc == 2
oCmbTipMul:Align 	  		:= 0
oCmbTipMul:cVariable 		:= "cTipMul"
oCmbTipMul:bSetGet   		:= {|u| If(PCount()>0,cTipMul:=u,cTipMul)}
oCmbTipMul:lVisibleControl  := .T.
oCmbTipMul:aItems    		:= aClone(aTipDesMul)
oCmbTipMul:bWhen     		:= {|| lMultas} 
oCmbTipMul:bChange			:= {|| }
If nOpc = 2 .or. nOpc = 4 .or. nOpc = 5
	oCmbTipMul:nAt 			:= iif(FID->FID_TPMUL == "V",2,3)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Valor Maximo Multa"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayMaxMul:= TSAY():Create(oDlg)
oSayMaxMul:cName			:= "oSayMaxMul"
oSayMaxMul:cCaption 		:= STR0018 //"Valor Max Multa:"
oSayMaxMul:nLeft 			:= aPosObj[1][1] + 245
oSayMaxMul:nTop 			:= aPosObj[1][2] + 170
oSayMaxMul:nWidth 	   		:= 140
oSayMaxMul:nHeight 			:= aPosObj[1][4]
oSayMaxMul:lShowHint 		:= .F.
oSayMaxMul:lReadOnly 		:= nOpc == 2
oSayMaxMul:Align 			:= 0
oSayMaxMul:lVisibleControl	:= .T.
oSayMaxMul:lWordWrap 	  	:= .F.
oSayMaxMul:lTransparent 	:= .F.   
oSayMaxMul:nClrText			:= iif(lMultas,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get "Max Multa"    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetMulMax:= TGET():Create(oDlg)
oGetMulMax:cName 	 	:= "oGetMulMax"
oGetMulMax:nLeft 	 	:= aPosObj[1][1] + 350
oGetMulMax:nTop 	 	:= aPosObj[1][2] + 170
oGetMulMax:nWidth 		:= aPosObj[1][3] - 130
oGetMulMax:nHeight 		:= aPosObj[1][4]
oGetMulMax:lShowHint 	:= .F.
oGetMulMax:lReadOnly 	:= nOpc == 2
oGetMulMax:Align 	 	:= 0
oGetMulMax:lVisibleControl := .T.
oGetMulMax:lPassword 	:= .F.
oGetMulMax:lHasButton	:= .F. 
oGetMulMax:cVariable 	:= "nMulMax"
oGetMulMax:bSetGet 		:= {|u| If(PCount()>0,nMulMax:=u,nMulMax)}
oGetMulMax:bWhen     	:= {|| lMultas} 
oGetMulMax:Picture 		:= "9999.99"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³checkbox Pode Alterar Juros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                   
oChkJur:= TCHECKBOX():Create(oDlg)
oChkJur:cName 				:= "oChkJur"
oChkJur:cCaption 			:= STR0009 //"Pode alterar juros?"
oChkJur:nLeft 	 			:= aPosObj[1][1]
oChkJur:nTop 	 			:= aPosObj[1][2] + 200
oChkJur:nWidth 				:= aPosObj[1][3]
oChkJur:nHeight 			:= aPosObj[1][4]
oChkJur:lShowHint 			:= .F.
oChkJur:lReadOnly 			:= nOpc == 2
oChkJur:Align 				:= 0
oChkJur:cVariable 			:= "lJuros"
oChkJur:bSetGet 			:= {|u| If(PCount()>0,lJuros:=u,lJuros) }
oChkJur:lVisibleControl 	:= .T.  
oChkJur:blClicked    		:= {|| Fn221Upd()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Tipo de Juros"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTipJur:= TSAY():Create(oDlg)
oSayTipJur:cName			:= "oSayTipJur"
oSayTipJur:cCaption 		:= STR0041 //"Tipo de Juros:"
oSayTipJur:nLeft 			:= aPosObj[1][1] + 30
oSayTipJur:nTop 			:= aPosObj[1][2] + 230
oSayTipJur:nWidth 	   		:= 140
oSayTipJur:nHeight 			:= aPosObj[1][4]
oSayTipJur:lShowHint 		:= .F.
oSayTipJur:lReadOnly 		:= nOpc == 2
oSayTipJur:Align 			:= 0
oSayTipJur:lVisibleControl	:= .T.
oSayTipJur:lWordWrap 	  	:= .F.
oSayTipJur:lTransparent 	:= .F. 
oSayTipJur:nClrText			:= iif(lJuros,CLR_BLACK,CLR_GRAY)
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Monta a Combo "Tipo de Juros"         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCmbTipJur:= TCOMBOBOX():Create(oDlg)
oCmbTipJur:cName 	  		:= "oCmbTipJur"
oCmbTipJur:nLeft 	  		:= aPosObj[1][1] + 130
oCmbTipJur:nTop 	  		:= aPosObj[1][2] + 230
oCmbTipJur:nWidth 	  		:= 90
oCmbTipJur:nHeight   		:= 20
oCmbTipJur:lShowHint 		:= .F.
oCmbTipJur:lReadOnly 		:= nOpc == 2
oCmbTipJur:Align 	  		:= 0
oCmbTipJur:cVariable 		:= "cTipJur"
oCmbTipJur:bSetGet   		:= {|u| If(PCount()>0,cTipJur:=u,cTipJur)}
oCmbTipJur:lVisibleControl  := .T.
oCmbTipJur:aItems    		:= aClone(aTipDesMul)
oCmbTipJur:bWhen     		:= {|| lJuros} 
oCmbTipJur:bChange			:= {|| }
If nOpc = 2 .or. nOpc = 4 .or. nOpc = 5
	oCmbTipJur:nAt 			:= iif(FID->FID_TPJUR == "V",2,3)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Valor Maximo Juros"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayMaxJur:= TSAY():Create(oDlg)
oSayMaxJur:cName			:= "oSayMaxJur"
oSayMaxJur:cCaption 		:= STR0042 //"Valor Max Juros:"
oSayMaxJur:nLeft 			:= aPosObj[1][1] + 245
oSayMaxJur:nTop 			:= aPosObj[1][2] + 230
oSayMaxJur:nWidth 	   		:= 140
oSayMaxJur:nHeight 			:= aPosObj[1][4]
oSayMaxJur:lShowHint 		:= .F.
oSayMaxJur:lReadOnly 		:= nOpc == 2
oSayMaxJur:Align 			:= 0
oSayMaxJur:lVisibleControl	:= .T.
oSayMaxJur:lWordWrap 	  	:= .F.
oSayMaxJur:lTransparent 	:= .F.   
oSayMaxJur:nClrText			:= iif(lJuros,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get "Max Juros"    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetMulJur:= TGET():Create(oDlg)
oGetMulJur:cName 	 	:= "oGetMulJur"
oGetMulJur:nLeft 	 	:= aPosObj[1][1] + 350
oGetMulJur:nTop 	 	:= aPosObj[1][2] + 230
oGetMulJur:nWidth 		:= aPosObj[1][3] - 130
oGetMulJur:nHeight 		:= aPosObj[1][4]
oGetMulJur:lShowHint 	:= .F.
oGetMulJur:lReadOnly 	:= nOpc == 2
oGetMulJur:Align 	 	:= 0
oGetMulJur:lVisibleControl := .T.
oGetMulJur:lPassword 	:= .F.
oGetMulJur:lHasButton	:= .F. 
oGetMulJur:cVariable 	:= "nJurMax"
oGetMulJur:bSetGet 		:= {|u| If(PCount()>0,nJurMax:=u,nJurMax)}
oGetMulJur:bWhen     	:= {|| lJuros} 
oGetMulJur:Picture 		:= "9999.99"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CheckBox "Recebe Cheque-Pre"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkChPre := TCHECKBOX():Create(oDlg)
oChkChPre:cName 		:= "oChkChPre"
oChkChPre:cCaption 		:= STR0037  //"Recebe Cheque Pré-Datado:"
oChkChPre:nLeft 		:= aPosObj[1][1]
oChkChPre:nTop 			:= aPosObj[1][2] + 260
oChkChPre:nWidth 		:= aPosObj[1][3]
oChkChPre:nHeight 		:= aPosObj[1][4]
oChkChPre:lShowHint 	:= .F.
oChkChPre:lReadOnly 	:= nOpc == 2
oChkChPre:Align 		:= 0
oChkChPre:cVariable 	:= "lChPre"
oChkChPre:bSetGet 		:= {|u| If(PCount()>0,lChPre:=u,lChPre) }
oChkChPre:lVisibleControl := .T.
oChkChPre:blClicked		:= {|| Fn221Upd()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Limite dias Cheque"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayLimChq:= TSAY():Create(oDlg)
oSayLimChq:cName			:= "oSayLimChq"
oSayLimChq:cCaption 		:= STR0038 //"Limite dias no Cheque-Pré:"
oSayLimChq:nLeft 			:= aPosObj[1][1] + 210
oSayLimChq:nTop 			:= aPosObj[1][2] + 263
oSayLimChq:nWidth 	   		:= 140
oSayLimChq:nHeight 			:= aPosObj[1][4]
oSayLimChq:lShowHint 		:= .F.
oSayLimChq:lReadOnly 		:= nOpc == 2
oSayLimChq:Align 			:= 0
oSayLimChq:lVisibleControl	:= .T.
oSayLimChq:lWordWrap 	  	:= .F.
oSayLimChq:lTransparent 	:= .F.   
oSayLimChq:nClrText			:= iif(lChPre,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get "Lim Cheque"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetLimChq:= TGET():Create(oDlg)
oGetLimChq:cName 	 	:= "oGetLimChq"
oGetLimChq:nLeft 	 	:= aPosObj[1][1] + 350
oGetLimChq:nTop 	 	:= aPosObj[1][2] + 260
oGetLimChq:nWidth 		:= aPosObj[1][3] - 130
oGetLimChq:nHeight 		:= aPosObj[1][4]
oGetLimChq:lShowHint 	:= .F.
oGetLimChq:lReadOnly 	:= nOpc == 2
oGetLimChq:Align 	 	:= 0
oGetLimChq:lVisibleControl := .T.
oGetLimChq:lPassword 	:= .F.
oGetLimChq:lHasButton	:= .F. 
oGetLimChq:cVariable 	:= "nLimChq"
oGetLimChq:bSetGet 		:= {|u| If(PCount()>0,nLimChq:=u,nLimChq)}
oGetLimChq:bWhen     	:= {|| lChPre} 
oGetLimChq:Picture 		:= "@E 999"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CheckBox "Usuario Abre Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkAbreCx := TCHECKBOX():Create(oDlg)
oChkAbreCx:cName 		:= "oChkAbreCx"
oChkAbreCx:cCaption 	:= STR0019 //"Pode abrir o caixa"
oChkAbreCx:nLeft 		:= aPosObj[1][1]
oChkAbreCx:nTop 		:= aPosObj[1][2] + 290
oChkAbreCx:nWidth 		:= aPosObj[1][3]
oChkAbreCx:nHeight 		:= aPosObj[1][4]
oChkAbreCx:lShowHint 	:= .F.
oChkAbreCx:lReadOnly 	:= nOpc == 2
oChkAbreCx:Align 		:= 0
oChkAbreCx:cVariable 	:= "lAbreCx"
oChkAbreCx:bSetGet 	:= {|u| If(PCount()>0,lAbreCx:=u,lAbreCx) }
oChkAbreCx:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CheckBox "Usuario Fecha Caixa"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkFechCx := TCHECKBOX():Create(oDlg)
oChkFechCx:cName 		:= "oChkFechCx"
oChkFechCx:cCaption 	:= STR0020 //"Pode fechar o caixa"
oChkFechCx:nLeft 		:= aPosObj[1][1]
oChkFechCx:nTop 		:= aPosObj[1][2] + 320
oChkFechCx:nWidth 		:= aPosObj[1][3]
oChkFechCx:nHeight 		:= aPosObj[1][4]
oChkFechCx:lShowHint 	:= .F.
oChkFechCx:lReadOnly 	:= nOpc == 2
oChkFechCx:Align 		:= 0
oChkFechCx:cVariable 	:= "lFechaCx"
oChkFechCx:bSetGet 	:= {|u| If(PCount()>0,lFechaCx:=u,lFechaCx) }
oChkFechCx:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CheckBox "Usuario Supervisor" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkEstor:= TCHECKBOX():Create(oDlg)
oChkEstor:cName 		:= "oChkEstor"
oChkEstor:cCaption 		:= STR0039 //Pode estornar Operacoes
oChkEstor:nLeft 		:= aPosObj[1][1]
oChkEstor:nTop 			:= aPosObj[1][2] + 350
oChkEstor:nWidth 		:= aPosObj[1][3]
oChkEstor:nHeight 		:= aPosObj[1][4]
oChkEstor:lShowHint 	:= .F.
oChkEstor:lReadOnly 	:= nOpc == 2
oChkEstor:Align 		:= 0
oChkEstor:cVariable 	:= "lEstor"
oChkEstor:bSetGet 		:= {|u| If(PCount()>0,lEstor:=u,lEstor) }
oChkEstor:lVisibleControl := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CheckBox "Usuario Supervisor" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oChkSuper := TCHECKBOX():Create(oDlg)
oChkSuper:cName 		:= "oChkSuper"
oChkSuper:cCaption 		:= STR0021 //"Usuario Supervisor"
oChkSuper:nLeft 		:= aPosObj[1][1]
oChkSuper:nTop 			:= aPosObj[1][2] + 380
oChkSuper:nWidth 		:= aPosObj[1][3]
oChkSuper:nHeight 		:= aPosObj[1][4]
oChkSuper:lShowHint 	:= .F.
oChkSuper:lReadOnly 	:= nOpc == 2
oChkSuper:Align 		:= 0
oChkSuper:cVariable 	:= "lSuper"
oChkSuper:bSetGet 		:= {|u| If(PCount()>0,lSuper:=u,lSuper) }
oChkSuper:lVisibleControl := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checkbox Entrada Troco Padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                   
oChkTroco:= TCHECKBOX():Create(oDlg)
oChkTroco:cName 			:= "oChkTroco"
oChkTroco:cCaption 			:= STR0047 //"Usuario com entrada de troco padrao"
oChkTroco:nLeft 	 		:= aPosObj[1][1]
oChkTroco:nTop 	 			:= aPosObj[1][2] + 410
oChkTroco:nWidth 			:= aPosObj[1][3] + 20
oChkTroco:nHeight 			:= aPosObj[1][4]
oChkTroco:lShowHint 		:= .F.
oChkTroco:lReadOnly 		:= nOpc == 2
oChkTroco:Align 			:= 0
oChkTroco:cVariable 		:= "lTroco"
oChkTroco:bSetGet 			:= {|u| If(PCount()>0,lTroco:=u,lTroco) }
oChkTroco:lVisibleControl 	:= .T.  
oChkTroco:blClicked    		:= {|| Fn221Upd()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Say "Valor Troco"   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTroco:= TSAY():Create(oDlg)
oSayTroco:cName		  		:= "oSayTroco"
oSayTroco:cCaption 	  		:= STR0048 //"Valor Troco"
oSayTroco:nLeft 			:= aPosObj[1][1] + 280
oSayTroco:nTop 		  		:= aPosObj[1][2] + 413
oSayTroco:nWidth 	   		:= 140
oSayTroco:nHeight 			:= aPosObj[1][4]
oSayTroco:lShowHint 		:= .F.
oSayTroco:lReadOnly 		:= nOpc == 2
oSayTroco:Align 			:= 0
oSayTroco:lVisibleControl	:= .T.
oSayTroco:lWordWrap 	  	:= .F.
oSayTroco:lTransparent 		:= .F.   
oSayTroco:nClrText			:= iif(lTroco,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get "Valor Troco"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetTroco:= TGET():Create(oDlg)
oGetTroco:cName 	 	:= "oGetTroco"
oGetTroco:nLeft 	 	:= aPosObj[1][1] + 350
oGetTroco:nTop 	 		:= aPosObj[1][2] + 410
oGetTroco:nWidth 		:= aPosObj[1][3] - 130
oGetTroco:nHeight 		:= aPosObj[1][4]
oGetTroco:lShowHint 	:= .F.
oGetTroco:lReadOnly 	:= nOpc == 2
oGetTroco:Align 	 	:= 0
oGetTroco:lVisibleControl := .T.
oGetTroco:lPassword 	:= .F.
oGetTroco:lHasButton	:= .F. 
oGetTroco:cVariable 	:= "nTroco"
oGetTroco:bSetGet 		:= {|u| If(PCount()>0,nTroco:=u,nTroco)}
oGetTroco:bWhen     	:= {|| lTroco} 
oGetTroco:Picture 		:= "9999.99" 

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Botao Ok  ³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
oBtnOk:= TButton():Create(oDlg)
oBtnOk:cName 			:= "oBtnOk"
oBtnOk:cCaption 		:= STR0022 //"Ok"
oBtnOk:nLeft 			:= aPosObj[1][1] + 357
oBtnOk:nTop  			:= aPosObj[1][2] + 450
oBtnOk:nWidth    		:= 70
oBtnOk:nHeight 			:= 30
oBtnOk:lShowHint 		:= .F.
oBtnOk:lReadOnly 		:= .F.
oBtnOk:Align 			:= 0
oBtnOk:bAction 			:= {||( Fin221Grv(nOpc) )} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botao Cancelar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBtnCancel:= TButton():Create(oDlg)
oBtnCancel:cName 			:= "oBtnCancel"
oBtnCancel:cCaption 		:= STR0007 //Cancelar
oBtnCancel:nLeft 			:= aPosObj[1][1] + 280
oBtnCancel:nTop  			:= aPosObj[1][2] + 450 
oBtnCancel:nWidth    		:= 70
oBtnCancel:nHeight 			:= 30
oBtnCancel:lShowHint 		:= .F.
oBtnCancel:lReadOnly 		:= .F.
oBtnCancel:Align 			:= 0
oBtnCancel:bAction 			:= {||( oDlg:End() )}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza as cores das gets³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fn221Upd()
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a interface grafica montada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlg:Activate()
dbSelectArea(cAlias)
                 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fin221Grv ºAutor  ³Cesar A. e Karen H. º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua gravacao ou exclui dados referentes ao cadastro de   º±±
±±º          ³departamentos.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fin221Grv( nOpc )
Local nCaixa	 := 0
Local lNovo 	 := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja visualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2
	Return
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja inclusao ou alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
elseif nOpc == 3 .or. nOpc == 4

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se nenhuma combo foi deixada em branco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty(cTipDes) .and. lDesc
		Aviso(STR0033,STR0034,{STR0036})
		Return
	elseif Empty(cTipMul) .and. lMultas
		Aviso(STR0033,STR0035,{STR0036})
		Return
	elseif Empty(cTipJur) .and. lJuros
		Aviso(STR0033,STR0043,{STR0036})
		Return	
	endif
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se este usuario eh novo ou ja existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('FID')
	FID->(dbSetOrder(1)) 
	lNovo := !FID->(dbSeek( xFilial( "FID" ) + cUsuario ))   
    CursorWait() 
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se inclusao, entao grava um novo caixa na SA6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	if lNovo
		nCaixa := Fn221NCxa(.T.)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os dados inseridos/modificados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("FID",lNovo)	
	FID->FID_FILIAL := xFilial( "FID" )
	FID->FID_USER   := cUsuario
	FID->FID_BLOQ   := Iif(lBloq,"1", "2")
	FID->FID_DESC   := Iif(lDesc,"1", "2")
	FID->FID_MAXDES := Iif(lDesc,nDesMax,0)
	FID->FID_TPDES  := Iif(lDesc,upper(substr(cTipDes,1,1)),"")
	FID->FID_MULTA  := Iif(lMultas,"1","2")
	FID->FID_MAXMUL := Iif(lMultas,nMulMax,0)
	FID->FID_TPMUL  := Iif(lMultas,upper(substr(cTipMul,1,1)),"")
	FID->FID_JUROS  := Iif(lJuros,"1","2")
	FID->FID_MAXJUR := Iif(lJuros,nJurMax,0)
	FID->FID_TPJUR  := Iif(lJuros,upper(substr(cTipJur,1,1)),"")	
	FID->FID_SUPER  := Iif(lSuper,"1","2")
	FID->FID_ABRECX := Iif(lAbreCx,"1","2")
	FID->FID_FECHCX := Iif(lFechaCx,"1","2")
	FID->FID_ESTOR  := Iif(lEstor,"1","2")
	FID->FID_TROCOP := Iif(lTroco,nTroco,0)
	FID->FID_CHEQP  := Iif(lChPre,"1","2")
	FID->FID_QTDCHQ := Iif(lChPre,nLimChq,0)
	FID->FID_NOME   := cNome
	if lNovo
		FID->FID_NCAIXA := nCaixa
	endif
	FID->(MsUnlock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe mensagem de ao usuario, comunicando gravacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CursorArrow()
	msgInfo(STR0023 + alltrim(cNome) + iif(lNovo,STR0024,STR0025))
	oDlg:end()
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja exclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Elseif nOpc == 5
	if MsgNoYes(STR0026 + cUsuario + " - " + cNome)
		RecLock('FID',.F.)
		FID->(dbDelete())
		FID->(msUnlock())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe mensagem de ao usuario, comunicando exclusao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		msgInfo(STR0027 + alltrim(cNome) + STR0028)
	endif
	oDlg:end()
End
              
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN221NCxa ºAutor  ³Cesar A. Bianchi    º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria uma nova conta do tipo "Caixa" na SA6/SX5              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn221NCxa(lCria)
Local cCodCxa := "C01"
Local cQuery  := ""
Local nPos 	  := 0	 
Local aLetras := {'A','B','C','D','E','F','G','H','I','J','H',/*'L'*/'M','N','O','P','Q','R','S','T','V','X','Z'} //NAO PODE HAVER A LETRA L

if lCria           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o proximo cod de caixa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cQuery := "SELECT MAX(SA6.A6_COD) MAIOR FROM " 
	cQuery += retsqlname('SX5') + " SX5, " + retsqlname('SA6') + " SA6 "
	cQuery += " WHERE SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
	cQuery += " 	AND SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
	cQuery += " 	AND SX5.X5_TABELA = '23' " 			//::Tabela de contas caixa - SIGALOJA
	cQuery += " 	AND SX5.X5_CHAVE NOT LIKE 'CL%' "   //::Caixas que iniciam com CL pertencem a caixa geral do sigaloja
	cQuery += " 	AND SA6.A6_COD = SX5.X5_CHAVE "
	cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	//::Verifica se ja existe alguma conta caixa.
	If !Empty(SQL->MAIOR)
		cCodCxa := alltrim(SQL->MAIOR)
		//::Verifica o ultimo digito se eh menor que 9 (nove)
		if substr(cCodCxa,3,1) < '9'
			//::Se menor que nove, apenas acrescenta mais 1 ao final.
			cCodCxa := substr(cCodCxa,1,2) + alltrim(str(val(substr(cCodCxa,3,1))+1))
		else
			//Se nao eh menor que nove, verifica se o penultimo digito eh menor que nove.
			if substr(cCodCxa,2,1) < '9'
				//Se eh menor que nove, apenas acrescenta mais 1 ao segundo digito
				cCodCxa := substr(cCodCxa,1,1) + alltrim(str(val(substr(cCodCxa,2,1))+1)) + "1"
			elseif substr(cCodCxa,2,1) = '9'
				//Se eh igual a nove, recebe a letra A na segunda posicao.
				cCodCxa := substr(cCodCxa,1,1) + "A1"
			else
				//Se eh uma letra, acrescenta a proxima.
				//PS: PULA A LETRA L POIS PERTENCE A CAIXA-GERAL NO SIGALOJA
				nPos    := aScan(aLetras,substr(cCodCxa,2,1)) + 1
				if nPos > 1 .and. nPos <= 22 
					cCodCxa := substr(cCodCxa,1,1) + aLetras[nPos] + "1"
				else
					msgStop('Falha ao obter novo código de caixa.')
					Return
				endif
			endif
		endif						
	endif
	SQL->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria a conta na SA6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SA6')
	RecLock('SA6',.T.)
	SA6->A6_FILIAL  := xFilial('SA6')
	SA6->A6_COD     := cCodCxa
	SA6->A6_AGENCIA := '.'
	SA6->A6_NOMEAGE := ''
	SA6->A6_NUMCON  := '.'
	SA6->A6_NOME    := alltrim(cNome)
	SA6->A6_NREDUZ  := alltrim(cNome)
	SA6->A6_DATAFCH := dDataBase
	SA6->A6_HORAFCH := Time()
	SA6->A6_MOEDA   := 1
	SA6->A6_FLUXCAI := 'S'
	SA6->(msUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria a conta no SX5 como conta CAIXA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SX5')                                                                                          
	RecLock('SX5',.T.)
	SX5->X5_FILIAL := xFilial('SX5')
	SX5->X5_TABELA := '23'
	SX5->X5_CHAVE  := cCodCxa
	SX5->X5_DESCRI := cNome
	SX5->X5_DESCSPA := cNome
	SX5->X5_DESCENG := cNome
	SX5->(msUnlock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista a integracao Protheus x Classis Net.³
	//³Cria o caixa na GBANCO, GAGENCIA, FCONTA, FCXA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar('MV_RMCLASS',.F.)
		//Cria o caixa nas tabelas do Classis		
		if SA6->(Recno()) > 0
			Processa( { || ClsInBcoAg(.F.,"0",.T.,"I",SM0->M0_CODIGO,SA6->A6_FILIAL,.T.,"FIN221",SA6->A6_COD,SA6->A6_NOME,SA6->A6_NREDUZ,SA6->A6_AGENCIA,SA6->A6_NOMEAGE,SA6->A6_END,SA6->A6_BAIRRO,SA6->A6_MUN,SA6->A6_EST,SA6->A6_CEP,SA6->A6_TEL,SA6->A6_PAISBCO,SA6->A6_NUMCON," ",SM0->M0_NOME,SA6->A6_CODCED,SA6->A6_TIPOCAR,SA6->A6_CARTEIR,SA6->A6_COD,SA6->A6_SALATU,SA6->A6_BLOCKED) }, STR0040 ) //Integração Protheus x Classis
		endif
	endif
	
else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui a conta da SA6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Nao implementado pois pode haver problemas de relacionamento com sigaloja ou com contabilidade. - SIGA3286
endif

Return cCodCxa

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN221Upd  ºAutor  ³Cesar A. Bianchi    º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera/Bloqueia a edicao dos valores maximos de desconto e  º±±
±±º          ³multa. Executa o refresh dos objetos ao clique do mouse.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fn221Upd()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controla as cores das legendas de multa e desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSayTipDes:nClrText:= iif(lDesc,CLR_BLACK,CLR_GRAY)
oSayMaxDes:nClrText:= iif(lDesc,CLR_BLACK,CLR_GRAY)
oSayTipMul:nClrText:= iif(lMultas,CLR_BLACK,CLR_GRAY)
oSayMaxMul:nClrText:= iif(lMultas,CLR_BLACK,CLR_GRAY)
oSayTipJur:nClrText:= iif(lJuros,CLR_BLACK,CLR_GRAY)
oSayMaxJur:nClrText:= iif(lJuros,CLR_BLACK,CLR_GRAY)
oSayLimChq:nClrText:= iif(lChPre,CLR_BLACK,CLR_GRAY)
oSayTroco:nClrText:= iif(lTroco,CLR_BLACK,CLR_GRAY)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o refresh dos objetos graficos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDesMax:Refresh()
oGetMulMax:Refresh()
oGetLimChq:Refresh()
oCmbTipMul:Refresh()
oCmbTipDes:Refresh()
oSayMaxMul:Refresh()
oSayMaxDes:Refresh()
oSayMaxJur:Refresh()
oSayTipMul:Refresh()
oSayTipDes:Refresh()
oSayTipJur:Refresh()
oGetTroco:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN221Leg  ºAutor  ³Cesar A. Bianchi    º Data ³  14/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a dialog de legendas/cores							  º±±
±±º          ³															  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fn221Leg()

BrwLegenda(STR0001,STR0044,	{	{ "BR_VERDE"   , STR0045},;  //"Usuario com caixa Aberto e Ativo no momento"
								{ "BR_LARANJA" , STR0049},;  //"Usuário com caixa Aberto e Encerrado no momento"
								{ "BR_VERMELHO", STR0046}})  //"Usuario com caixa Fechado e Encerrado no momento"
								
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FN221SitCxºAutor  ³Cesar A. Bianchi    º Data ³  14/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna cor de situacao do caixa do usuario passado atraves º±±
±±º          ³do parametro cUserCxa. 									  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ SIGAGE/SIGAFIN - Contas a Receber                          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fn221SitCx(cUserCxa,cCodCxa)
Local cRet := "BR_VERMELHO"
Local aArea := getArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o caixa esta Aberto e Encerrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(*) TOTAL FROM "
cQuery += retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5, " + retsqlname('FIB') + " FIB, "  + retsqlname('FID') + " FID "
cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
cQuery += " 	AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
cQuery += " 	AND SA6.A6_COD = '" + cCodCxa + "'"
cQuery += " 	AND SA6.A6_DATAABR <> ' ' "
cQuery += " 	AND SA6.A6_DATAFCH = ' ' "
cQuery += " 	AND SA6.A6_COD = FID.FID_NCAIXA "
cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
cQuery += " 	AND SX5.X5_TABELA = '23' "
cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
cQuery += " 	AND FIB.FIB_USER = '" + cUserCxa + "'"
cQuery += " 	AND FIB.FIB_DTABR <> ' ' "
cQuery += " 	AND FIB.FIB_DTFCH = ' ' "
cQuery += " 	AND FIB.FIB_ENCER = '1' "
cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
if SQL->TOTAL > 0
	cRet := "BR_LARANJA"	
else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Caixa esta Aberto e Ativo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT(*) TOTAL FROM "
	cQuery += retsqlname('SA6') + " SA6, " + retsqlname('SX5') + " SX5, " + retsqlname('FIB') + " FIB, "  + retsqlname('FID') + " FID "
	cQuery += " WHERE SA6.A6_FILIAL = '" + xFilial('SA6') + "'"
	cQuery += " 	AND SX5.X5_FILIAL = '" + xFilial('SX5') + "'"
	cQuery += " 	AND FIB.FIB_FILIAL = '" + xFilial('FIB') + "'"
	cQuery += " 	AND FID.FID_FILIAL = '" + xFilial('FID') + "'"
	cQuery += " 	AND SA6.A6_COD = '" + cCodCxa + "'"
	cQuery += " 	AND SA6.A6_DATAABR <> ' ' "
	cQuery += " 	AND SA6.A6_DATAFCH = ' ' "
	cQuery += " 	AND SA6.A6_COD = FID.FID_NCAIXA "
	cQuery += " 	AND SX5.X5_CHAVE = SA6.A6_COD "
	cQuery += " 	AND SX5.X5_TABELA = '23' "
	cQuery += " 	AND FIB.FIB_USER = FID.FID_USER "
	cQuery += " 	AND FIB.FIB_USER = '" + cUserCxa + "'"
	cQuery += " 	AND FIB.FIB_DTABR <> ' ' "
	cQuery += " 	AND FIB.FIB_DTFCH = ' ' "
	cQuery += " 	AND FIB.FIB_ENCER = '2' "
	cQuery += " 	AND SA6.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SX5.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND FIB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('SQL')>0,SQL->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
	if SQL->TOTAL > 0
	    cRet := "BR_VERDE"
	endif
endif
SQL->(dbCloseArea())

RestArea(aArea)
Return cRet