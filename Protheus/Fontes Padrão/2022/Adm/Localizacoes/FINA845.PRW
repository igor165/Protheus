#INCLUDE "FINA845.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE 87BOK "LBOK"
#DEFINE 87BNO "LBNO"
#DEFINE 87BPT "F10_VERD"   

STATIC lMod2	:= .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA845	บAutor  ณJair Ribeiro		 บ Data ณ  08/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Documentos em Transito                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA845()
Local aDimensao		:= FWGetDialogSize(oMainWnd)
Local oDlg			:= Nil
Local oPanelM		:= Nil
Local oPanelT		:= Nil
Local oPanelB		:= Nil
Local oGCliente		:= Nil 
Local oGRecibos		:= Nil
Local oSay1			:= Nil
Local oSay2			:= Nil
Local oSay3			:= Nil
Local oGet1			:= Nil
Local oGet2			:= Nil 
Local oGet3			:= Nil 
Local oGet4			:= Nil 
Local oGet5			:= Nil 
Local oGet6			:= Nil 
Local oGet7			:= Nil 
Local oGet8			:= Nil 
Local oCheck1		:= Nil 
Local oGetDados		:= Nil

Local cCodCli1		:= Space(TamSX3("EL_CLIENTE")[1])
Local cLojaCli1		:= Space(TamSX3("EL_LOJA")[1])
Local cNomeCli1		:= Space(TamSX3("A1_NOME")[1])  
Local cCodCli2		:= Space(TamSX3("EL_CLIENTE")[1])
Local cLojaCli2		:= Space(TamSX3("EL_LOJA")[1])
Local cNomeCli2		:= Space(TamSX3("A1_NOME")[1])

Local cData1		:= Criavar("EL_EMISSAO")
Local cData2		:= Criavar("EL_EMISSAO")
Local lCheck		:= .T.
Local nI			:= 0 

Local aArea			:= {}
Local cF3Cli		:= "SA1"
Local aButtons		:= {}
Local aColsI		:= {} 
Local aHeaderI		:= {}
Local aCamposSEL	:= {}
Local aIndiceSEL	:= {}
Local aRatCert		:= {}
Local aAlter		:= {"EL_FILIAL","EL_DTENTRA"}
Local bValidCli1	:= {|| aArea := GetArea(),cNomeCli1 := Posicione("SA1", 1, xFilial("SA1")+PadR(cCodCli1,TamSx3("A1_COD")[1])+PadR(cLojaCli1,TamSx3("A1_LOJA")[1]),"A1_NOME"),RestArea(aArea),.T.}
Local bValidCli2	:= {|| aArea := GetArea(),cNomeCli2 := Posicione("SA1", 1, xFilial("SA1")+PadR(cCodCli2,TamSx3("A1_COD")[1])+PadR(cLojaCli2,TamSx3("A1_LOJA")[1]),"A1_NOME"),RestArea(aArea),.T.}
Local bValidLoj1	:= {|| aArea := GetArea(),cNomeCli1 := Posicione("SA1", 1, xFilial("SA1")+PadR(cCodCli1,TamSx3("A1_COD")[1])+PadR(cLojaCli1,TamSx3("A1_LOJA")[1]),"A1_NOME"),RestArea(aArea),.T.}
Local bValidLoj2	:= {|| aArea := GetArea(),cNomeCli2 := Posicione("SA1", 1, xFilial("SA1")+PadR(cCodCli2,TamSx3("A1_COD")[1])+PadR(cLojaCli2,TamSx3("A1_LOJA")[1]),"A1_NOME"),RestArea(aArea),.T.}

Local bTudoOk		:= {|lRet| lRet := Fin845TdOk(oGetDados)}
Local bUpdate		:= {|| If (Eval(bTudoOk),(Fin845Upd(oGetDados,aIndiceSEL,aRatCert,cCertRet,cPerg),oDlg:End()),.F.)}
Local bEndWin		:= {|| oDlg:End()} 
Local bFiltro		:= {|| Fin845Filt(oGetDados,aCamposSEL,aIndiceSEL,cCodCli1,cLojaCli1,cCodCli2,cLojaCli2,cData1,cData2,lCheck)} 
Local bSearch		:= {|| Fin845BFin(oGetDados)}
Local bVisual		:= {|| Fin845Vis(aIndiceSEL,oGetDados:nAt)}

Local bFilt3 		:= {|| ((FJS->FJS_RCOP == "3") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
Local cCertRet		:= ""

Local cTitulo		:= STR0001 //"Registro de Entrada de Documentos em Transito"
Local cPerg			:= 'FIN845' 

/*
 * Verifica็ใo do processo que estแ configurado para ser utilizado no M๓dulo Financeiro (Argentina)
 */
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf
                                                                 
If Fin845Amb() .and. Pergunte(cPerg,.T.) 
	cCertRet := FinGetTipo(bFilt3,"FJS",xFilial("FJS"),"FJS_TIPO",1)
	
	aAdd(aButtons,{"RPMDES",bFiltro,STR0002	   		,STR0003}) //"Realiza o fitro informado"###"Exec. Filtro"
	aAdd(aButtons,{"RPMDES",bSearch,STR0004	,STR0005}) //"Pesquisa por recibo especifico"###"Pesquisar"
	aAdd(aButtons,{"RPMDES",bVisual,STR0006			,STR0007}) //"Exibe recibo posicionado"###"Visualizar"
	
	Fin845SEL(aCamposSEL)
	Fin845HMrk(aHeaderI)
	
	For nI := 1 To Len(aCamposSEL)
		If "EL_LOJA" $ aCamposSEL[nI]
			Fin845Hdr(aHeaderI,aCamposSEL[nI])
			Fin845Hdr(aHeaderI,"A1_NOME")	 
		Else
			Fin845Hdr(aHeaderI,aCamposSEL[nI])
		EndIf	
	Next nI
	
	Fin845HAlt(aHeaderI,"EL_DTENTRA",13,"(M->EL_FILIAL == '"+87BOK+"')") 
	
	RegToMemory("SEL",.F.)
		
	aAdd(aColsI,Array(Len(aHeaderI)+1))
	aColsI[Len(aColsI),Len(aHeaderI)+1] := .F.
			
	For nI := 1 To Len(aHeaderI)
		aColsI[Len(aColsI)][nI] := Criavar(aHeaderI[nI][2])   
		If Alltrim(aHeaderI[nI,2]) == "EL_FILIAL"
			aColsI[Len(aColsI)][nI] := 87BNO
		Endif	
	Next nI
	
	oDlg:=MSDialog():New(aDimensao[1],aDimensao[2],aDimensao[3],aDimensao[4],cTitulo,,,,,,,,,.T.)	
			
		oPanelM	:= TPanel():New(0,0,'',oDlg	,,.T.,.T.,,,30,30,.T.,.T.)
		oPanelM:Align:= CONTROL_ALIGN_ALLCLIENT 	
		
		oPanelT		:= TPanel():New(0,0								,'',oPanelM	,,.T.,.T.,,,Fin845Pos(100,oPanelM,.F.),Fin845Pos(15,oPanelM),.F.,.F.)
		oPanel1		:= TPanel():New(0,Fin845Pos(001,oPanelM,.F.)	,'',oPanelT	,,.T.,.T.,,,Fin845Pos(063,oPanelM,.F.),Fin845Pos(15,oPanelM),.F.,.F.)
		oPanel2		:= TPanel():New(0,Fin845Pos(065,oPanelM,.F.)	,'',oPanelT	,,.T.,.T.,,,Fin845Pos(035,oPanelM,.F.),Fin845Pos(15,oPanelM),.F.,.F.)
	
		oGCliente	:= tGroup():New(aDimensao[1],5							,Fin845Pos(15,oDlg),Fin845Pos(65,oDlg,.F.)		,STR0008  		,oPanel1,,,.T.) //"Cliente"
		oGCliente:Align:= CONTROL_ALIGN_ALLCLIENT	 
		oGRecibos	:= tGroup():New(aDimensao[1],Fin845Pos(66,oDlg,.F.)	,Fin845Pos(15,oDlg),Fin845Pos(99,oDlg,.F.)		,STR0009  		,oPanel2,,,.T.)	 //"Recibos"
		oGRecibos:Align:= CONTROL_ALIGN_ALLCLIENT
				
		oPanelB	:= TPanel():New(Fin845Pos(16,oPanelM),Fin845Pos(1,oPanelM,.F.),'',oPanelM	,,.T.,.T.,,,Fin845Pos(99,oPanelM,.F.),Fin845Pos(78,oPanelM),.F.,.F.) 	
		
	
		oSay1	:= TSay():New(15,005				,{|| STR0010 },oGCliente,,,,,,.T.) //"Cliente Inicial"
		oGet1	:= TGet():New(25,005				,{|u| if(PCount()>0,cCodCli1:=u,cCodCli1)}		,oPanel1,35,10,'@!',bValidCli1	,,,,,,.T.,,,,,,,,,cF3Cli		,"cCodCli1")
		oGet2	:= TGet():New(25,045	  			,{|u| if(PCount()>0,cLojaCli1:=u,cLojaCli1)}	,oPanel1,10,10,'@!',bValidLoj1	,,,,,,.T.,,,,,,,,,			,"cLojaCli1")
		oGet3	:= TGet():New(25,065	  			,{|u| if(PCount()>0,cNomeCli1:=u,cNomeCli1)}	,oPanel1,80,10,'@!',				,,,,,,.T.,,,,,,,.T.,,			,"cNomeCli1")		
	
		oSay2	:= TSay():New(15,155	  			,{|| STR0011 },oGCliente,,,,,,.T.) //"Cliente Final"
		oGet4	:= TGet():New(25,155	   			,{|u| if(PCount()>0,cCodCli2:=u,cCodCli2)}		,oPanel1,35,10,'@!',bValidCli2	,,,,,,.T.,,,,,,,,,cF3Cli		,"cCodCli2")
		oGet5	:= TGet():New(25,195	   			,{|u| if(PCount()>0,cLojaCli2:=u,cLojaCli2)}	,oPanel1,10,10,'@!',bValidLoj2	,,,,,,.T.,,,,,,,,,   			,"cLojaCli2")
		oGet6	:= TGet():New(25,215	   			,{|u| if(PCount()>0,cNomeCli2:=u,cNomeCli2)}	,oPanel1,80,10,'@!',				,,,,,,.T.,,,,,,,.T.,,	   	   	,"cNomeCli2")		
	 
		oSay3	:= TSay():New(15,05					,{|| STR0012 },oGRecibos,,,,,,.T.) //"Emitidos Entre"
		oGet7	:= TGet():New(25,05	 				,{|u| if(PCount()>0,cData1:=u,cData1)}			,oPanel2,40,10,'@!',,,,,,,.T.,,,,,,,,,		,"cData1")
		oGet8	:= TGet():New(25,55					,{|u| if(PCount()>0,cData2:=u,cData2)}			,oPanel2,40,10,'@!',,,,,,,.T.,,,,,,,,,	   	,"cData2")
	   	oCheck1 := TCheckBox():New(27,100			,'Doc. Recebidos',,oPanel2,100,10,,,,,,,,.T.,,,)
		oCheck1:bSetGet 	:= {|| lCheck }
		oCheck1:bLClicked 	:= {|| lCheck:=!lCheck }
		
		If cPaisLoc == "COS"
			aAdd(aAlter,"EL_NUMERO")
			aAdd(aAlter,"EL_TIPODOC")
		EndIf

		oGetDados:=  MsNewGetDados():New(0,0,150,200,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlter,,,"AllwaysTrue",,"AllwaysTrue",oPanelB,aHeaderI,aColsI)
		oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	   	oGetDados:bChange :={|| M->EL_FILIAL := GdFieldGet("EL_FILIAL",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols)}
		//oGetDados:AddAction("EL_FILIAL",{|| Fin087GtM(oGetDados,aRatCert,cCertRet,aIndiceSEL)}) Evento falha na atualizacao da getdados
		oGetDados:oBrowse:bLDblClick := {|| Fin845DbcM(oGetDados,aRatCert,cCertRet,aIndiceSEL)}
	ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bUpdate,bEndWin,,aButtons)
EndIf 
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845DbcMบAutor  ณJair Ribeiro        บ Data ณ  08/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao executada para evento bLDblClick da Getdados		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑบ			 ณ aRatCert: Array de distribuicao da retencao    			  บฑฑ
ฑฑบ			 ณ cCertRet: String com os certificados de retencao			  บฑฑ 
ฑฑบ			 ณ aIndiceSEL: Array com os indices da SEL					  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845DbcM(oGetDados,aRatCert,cCertRet,aIndiceSEL)
Local nPosMrk	:= GdFieldPos("EL_FILIAL",oGetDados:aHeader)

If oGetDados:oBrowse:nColPos == nPosMrk
	oGetDados:aCols[oGetDados:nAt,nPosMrk]:= Fin845GMrk(oGetDados,aRatCert,cCertRet,aIndiceSEL)
Else
	oGetDados:EDITCELL()
EndIf
oGetDados:oBrowse:Refresh()
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Amb บAutor  ณJair Ribeiro		 บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Varifica se ambiente esta ok para execucao da rotina       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Amb()

Local lRet	:= .T.

If !(cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN")
	Help(" ",1,"FINCAMPOS",,STR0014,1,0) //"Ausencia dos campos necessarios para rotina de valores em transito! Aplique compatibilizador"
	lRet	:= .F.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845GMrkบAutor  ณJair Ribeiro        บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Evento Action da getdados para alterar bitmap              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845GMrk(oGetDados,aRatCert,cCertRet,aIndiceSEL)
Local cMarca	:= GdFieldGet("EL_FILIAL",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols)
Local lOk		:= .T.
Local nPosMrk	:= GdFieldPos("EL_FILIAL",oGetDados:aHeader)
Local nPosDtE	:= GdFieldPos("EL_DTENTRA",oGetDados:aHeader)
Local cCliente	:= GdFieldGet("EL_CLIENTE",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols)
Local cTipoDoc	:= GdFieldGet("EL_TIPO",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols) 
Local aRetSEL	:= {}
Local cDescTp	:= ""

If !Empty(cCliente)	
	If nPosMrk > 0
		cMarca := oGetDados:aCols[oGetDados:nAt,nPosMrk] 
		If !(87BPT $ cMarca)
			cMarca := IiF(87BNO $ cMarca,87BOK,87BNO)
		EndIf
	EndIf
		
	If nPosDtE > 0 
		If cMarca == 87BNO 
			oGetDados:aCols[oGetDados:nAt,nPosDtE]:= STOD("")
			If cTipoDoc $ cCertRet
				nPosRat := AsCan(aRatCert,{|aX| aX[1] == oGetDados:nAt})
				If nPosRat > 0 
					aRatCert[nPosRat,2] := {}   		
				EndIf
			EndIf
		ElseIf cMarca == 87BOK	
			If cTipoDoc $ cCertRet
		   		Fin845CRet(oGetDados,aRatCert,aIndiceSEL)		   				   	
		   		nPosRat := AsCan(aRatCert,{|aX| aX[1] == oGetDados:nAt}) 
		   		aRetSEL:= SEL->(GetAdvFVal("SEL",{"EL_VALOR","EL_NUMERO","EL_TIPODOC","EL_TIPO"},aIndiceSEL[oGetDados:nAt],8,{0,"",""}))
		   		cDescTp:= FJS->(GetAdvFVal("FJS","FJS_DESC",xFilial("FJS")+aRetSEL[4],1,""))
		   	 	lOk := Fin845DCt(cDescTp,aRetSEL[1],aRetSEL[2],aRatCert[nPosRat,2],aRetSEL[3]) 
			EndIf			
			If lOk
				oGetDados:aCols[oGetDados:nAt,nPosDtE]:= dDatabase
			Else
				cMarca := 87BNO 	
			EndIf 
		EndIf 
	EndIf 
EndIf
Return cMarca
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845CRetบAutor  ณJair Ribeiro        บ Data ณ  08/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche array para cetificados de retencao                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑบ			 ณ aRatCert: Array de distribuicao da retencao    			  บฑฑ
ฑฑบ			 ณ aIndiceSEL: Array com os indices da SEL					  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Fin845CRet(oGetDados,aRatCert,aIndiceSEL)
Local cTipoDoc	:= GdFieldGet("EL_TIPODOC",oGetDados:nAt,,oGetDados:aHeader,oGetDados:aCols)
Local aAux		:= {}
Local aArea		:= SEL->(GetArea())
//Local cIndice	:= SubStr(aIndiceSEL[oGetDados:nAt],1,(TamSx3("EL_FILIAL")[1]+TamSx3("EL_SERIE")[1]+TamSx3("EL_RECIBO")[1]))+"TB"
Local cIndice	:= SubStr(aIndiceSEL[oGetDados:nAt],1,(TamSx3("EL_FILIAL")[1]+SerieNfId("SEL",6,"EL_SERIE")+TamSx3("EL_RECIBO")[1]))+"TB"
SEL->(DbSetOrder(8))
SEL->(DbSeek(cIndice))
While SEL->(!EOF()) .and. SEL->(EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC) == cIndice
	aAdd(aAux,Array(7))
	aAux[Len(aAux)][1] := SEL->EL_PREFIXO
	aAux[Len(aAux)][2] := SEL->EL_NUMERO
	aAux[Len(aAux)][3] := SEL->EL_PARCELA
	aAux[Len(aAux)][4] := SEL->EL_TIPO
	aAux[Len(aAux)][5] := 0
	aAux[Len(aAux)][6] := SEL->EL_RECIBO
	aAux[Len(aAux)][7] := cTipoDoc	
	SEL->(DbSkip())
EndDo

If (nPosRat := AsCan(aRatCert,{|aX| aX[1] == oGetDados:nAt})) > 0
	aRatCert[nPosRat,2] := aClone(aAux)
Else
	aAdd(aRatCert,{oGetDados:nAt,aAux})
EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845BFinบAutor  ณJair Ribeiro        บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de busca dos registros apresentados na getdados       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845BFin(oGetDados)
Local oDlg			:= Nil
Local oGCliente		:= Nil
Local oGDoc			:= Nil
Local oSay1			:= Nil
Local oSay2			:= Nil
Local oSay3			:= Nil
Local oSay4			:= Nil
Local oSay5			:= Nil
Local oSay6			:= Nil
Local oSay7			:= Nil
Local oGet1			:= Nil
Local oGet2			:= Nil
Local oGet3			:= Nil
Local oGet4			:= Nil
Local oGet5			:= Nil
Local oGet6			:= Nil
Local oCombo		:= Nil

Local cCodCli		:= Space(TamSX3("EL_CLIENTE")[1])
Local cLojaCli		:= Space(TamSX3("EL_LOJA")[1])
Local cNomeCli		:= Space(TamSX3("A1_NOME")[1]) 
Local cPrefixo		:= Space(TamSX3("EL_PREFIXO")[1]) 
Local cNumero		:= Space(TamSX3("EL_NUMERO")[1])
Local cParcela		:= Space(TamSX3("EL_PARCELA")[1])   
Local cTipoDoc		:= Space(TamSX3("EL_TIPODOC")[1])
Local aCombo		:= Separa(FA840TpTit(),";",.F.)

Local bValidCli1	:= {|| Iif(Empty(cCodCli),.T.,Fin845Cli(cCodCli))}
Local bValidLoj1	:= {|| Iif(Empty(cLojaCli),.T.,Iif(ExistCpo("SA1",PadR(cCodCli,TamSx3("A1_COD")[1])+PadR(cLojaCli,TamSx3("A1_LOJA")[1])),Fin845Cli(cCodCli,cLojaCli,@cNomeCli,.T.),.F.))}

Local bSearch		:= {|| (Fin845SGet(oGetDados,cCodCli,cLojaCli,cPrefixo,cNumero,cParcela,cTipoDoc),oDlg:End())}
Local bEndWin		:= {|| oDlg:End()}
Local cTitulo		:= STR0005 //"Pesquisar"

oDlg:=MSDialog():New(65,0,280,450,cTitulo,,,,,,,,oMainWnd,.T.)
	oPanelM	:= TPanel():New(0,0,'',oDlg	,,.T.,.T.,,,30,30,.T.,.T.)
	oPanelM:Align:= CONTROL_ALIGN_ALLCLIENT                                             
	
	oGCliente	:= tGroup():New(5,5		,45,221		,STR0008  		,oPanelM,,,.T.)	  //"Cliente"
	
	oSay1	:= TSay():New(15,010				,{|| STR0015 }			,oGCliente,,,,,,.T.)  //"Codigo"
	oGet1	:= TGet():New(25,010				,{|u| if(PCount()>0,cCodCli:=u,cCodCli)}		,oGCliente,35,10,'@!',bValidCli1	,,,,,,.T.,,,,,,,,,"SA1"		,"cCodCli")
	oSay2	:= TSay():New(15,050				,{|| STR0016 }			,oGCliente,,,,,,.T.) //"Loja"
	oGet2	:= TGet():New(25,050	  			,{|u| if(PCount()>0,cLojaCli:=u,cLojaCli)}	,oGCliente,10,10,'@!',bValidLoj1	,,,,,,.T.,,,,,,,,,			,"cLojaCli")
	oSay3	:= TSay():New(15,070				,{|| STR0017 }	,oGCliente,,,,,,.T.) //"Razao Social"
	oGet3	:= TGet():New(25,070	  			,{|u| if(PCount()>0,cNomeCli:=u,cNomeCli)}	,oGCliente,90,10,'@!',				,,,,,,.T.,,,,,,,.T.,,			,"cNomeCli")		
		
	oGDoc		:= tGroup():New(50,5	,90,221		,STR0018  		,oPanelM,,,.T.)	  //"Documento"
	
	oSay4	:= TSay():New(60,010				,{|| STR0019 }			,oGDoc,,,,,,.T.)  //"Prefixo"
	oGet4	:= TGet():New(70,010				,{|u| if(PCount()>0,cPrefixo:=u,cPrefixo)}		,oGDoc,30,10,'@!',,,,,,,.T.,,,,,,,,,,"cPrefixo")
	oSay5	:= TSay():New(60,045				,{|| STR0020 }			,oGDoc,,,,,,.T.) //"Numero"
	oGet5	:= TGet():New(70,045	  			,{|u| if(PCount()>0,cNumero:=u,cNumero)}		,oGDoc,50,10,'@!',,,,,,,.T.,,,,,,,,,,"cNumero")
	oSay6	:= TSay():New(60,100				,{|| STR0021 }	,oGDoc,,,,,,.T.) //"Parcela"
	oGet6	:= TGet():New(70,100	  			,{|u| if(PCount()>0,cParcela:=u,cParcela)}		,oGDoc,20,10,'@!',,,,,,,.T.,,,,,,,,,,"cNomeCli")		
	oSay7	:= TSay():New(60,125				,{|| STR0022 }	,oGDoc,,,,,,.T.) //"Tipo Valor"
	oCombo	:= tComboBox():New(70,125			,{|u| if(PCount()>0,cTipoDoc:=u,cTipoDoc)}		,aCombo,80,20,oGDoc,,,,,,.T.,,,,,,,,,'cTipoDoc')             
ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bSearch,bEndWin) 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845SGetบAutor  ณJair Ribeiro	     บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua busca na getdados e posiciona na linha se encontradoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑบ			 ณ cCodCli: Codigo do cliente a ser encontrado na getdados    บฑฑ
ฑฑบ			 ณ cLojaCli: Loja do cliente a ser encontrado na getdados     บฑฑ 
ฑฑบ			 ณ cPrefixo: Prefixo do recibo a ser encontrado na getdados   บฑฑ 
ฑฑบ			 ณ cNumero: Numero do recibo a ser encontrado na getdados     บฑฑ 
ฑฑบ			 ณ cTipoDoc: Tipo do recibo a ser encontrado na getdados      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845SGet(oGetDados,cCodCli,cLojaCli,cPrefixo,cNumero,cParcela,cTipoDoc)
Local aHeaderX		:= aClone(oGetDados:aHeader)
Local aColsX		:= aClone(oGetDados:aCols)
Local nLinha		:= 1
Local nI			:= 0
Local lFiltro		:= .T.
Local lFound		:= .F.	 

For nI := 1 To Len(aColsX)
	If lFiltro .and. !Empty(cCodCli) 
		lFiltro := (PadR(GdFieldGet("EL_CLIENTE",nI,,aHeaderX,aColsX),TamSx3("EL_CLIENTE")[1])  $ PadR(cCodCli,TamSx3("EL_CLIENTE")[1])) 
	EndIf 
	
	If lFiltro .and. !Empty(cLojaCli)
		lFiltro := (PadR(GdFieldGet("EL_LOJA",nI,,aHeaderX,aColsX),TamSx3("EL_LOJA")[1])  $ PadR(cLojaCli,TamSx3("EL_LOJA")[1])) 
	EndIf 
	
	If lFiltro .and. !Empty(cPrefixo) 
		lFiltro := (PadR(GdFieldGet("EL_PREFIXO",nI,,aHeaderX,aColsX),TamSx3("EL_PREFIXO")[1])  $ PadR(cPrefixo,TamSx3("EL_PREFIXO")[1])) 
	EndIf 
	
	If lFiltro .and. !Empty(cNumero) 
		lFiltro := (PadR(GdFieldGet("EL_NUMERO",nI,,aHeaderX,aColsX),TamSx3("EL_NUMERO")[1])  $ PadR(cNumero,TamSx3("EL_NUMERO")[1]))  
	EndIf 
	
	If lFiltro .and. !Empty(cParcela) 
		lFiltro := (PadR(GdFieldGet("EL_PARCELA",nI,,aHeaderX,aColsX),TamSx3("EL_PARCELA")[1])  $ PadR(cParcela,TamSx3("EL_PARCELA")[1]))  
	EndIf 
	
	If lFiltro .and. !Empty(cTipoDoc)
		lFiltro := (PadR(GdFieldGet("EL_TIPODOC",nI,,aHeaderX,aColsX),TamSx3("EL_TIPODOC")[1])  $ PadR(cTipoDoc,TamSx3("EL_TIPODOC")[1]))  
	EndIf
	If lFiltro 
		nLinha := nI
		lFound := .T.	
		Exit
	EndIf
	lFiltro		:= .T. 
Next nI
If !lFound
	Help(" ",1,"FINNOFOUND",,STR0023,1,0) //"Documento nao localizado"
EndIf
oGetDados:GoTo(nLinha)
Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845FiltบAutor  ณJair Ribeiro        บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa filtro para preencimento do aCols                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑบ          ณ aCamposSEL: Campos da tabela SEL usadas no filtro          บฑฑ
ฑฑบ          ณ aIndiceSEL: Array com indice da tabela SEL			      บฑฑ
ฑฑบ          ณ cCodCli1: Codigo cliente inicial a ser considerado		  บฑฑ
ฑฑบ          ณ cLojaCli1: Loja inicial a ser considerado				  บฑฑ
ฑฑบ          ณ cCodCli2: Codigo cliente final a ser considerado			  บฑฑ
ฑฑบ          ณ cLojaCli2: Loja final a ser considerado					  บฑฑ
ฑฑบ          ณ cData1: data de emissao incial a ser considerado			  บฑฑ
ฑฑบ          ณ cData1: data de emissao final a ser considerado			  บฑฑ
ฑฑบ          ณ lRecebidos: Considera recebidos? .T./.F.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Filt(oGetDados,aCamposSEL,aIndiceSEL,cCodCli1,cLojaCli1,cCodCli2,cLojaCli2,cData1,cData2,lRecebidos)
Local cSql		:= ""
Local aHeaderX	:= aClone(oGetDados:aHeader)
Local aColsX	:= {}
Local nI		:= 0
Local nJ		:= 0
Local cAliasTRB	:= GetNextAlias()
Local lRetSql	:= .T.

aIndiceSEL 	:= {}
aRatCert	:= {}

cSql	+= "SELECT "
cSql	+= "FJT_RECIBO,FJT_SERIE,FJT_VERSAO,"
cSql	+= "EL.EL_FILIAL," 
cSql	+= "EL.EL_SERIE,"
cSql	+= "EL.EL_RECIBO," 
cSql	+= "EL.EL_TIPODOC," 
cSql	+= "EL.EL_PREFIXO," 
cSql	+= "EL.EL_NUMERO,"
cSql	+= "EL.EL_PARCELA," 
cSql	+= "EL.EL_TIPO,"
 
For nI:= 1 To Len(aCamposSEL)
	If !(AllTrim(aCamposSEL[nI]) $ cSql)  
		If nI != Len(aCamposSEL)
			cSql	+= "EL."+AllTrim(aCamposSEL[nI])+","+CRLF 
	 	Else
	 		cSql	+= "EL."+AllTrim(aCamposSEL[nI])+CRLF 
	 	EndIf
	 EndIf 
Next nI

cSql	+= " FROM " + RetSQLName("FJT") + " FJT, " + RetSqlName("SEL")+" EL "+CRLF
cSql	+= " WHERE"
cSql	+= " FJT_FILIAL = '" + xFilial("FJT") + "'"  
cSql	+= " AND FJT_CLIENT BETWEEN  '" + cCodCli1 + "' AND '" + cCodCli2 + "'"
cSql	+= " AND FJT_LOJA BETWEEN  '" + cLojaCli1 + "' AND '" + cLojaCli2 + "'"
cSql	+= " AND FJT_CANCEL = ' '"
cSql	+= " AND FJT_VERATU = '1'"  
cSql	+= " AND FJT_DTDIGI BETWEEN '"+DTOS(cData1)+"' AND '"+DTOS(cData2)+"'"
cSql	+= " AND FJT.D_E_L_E_T_ = ' '"
cSql	+= " AND EL.EL_CLIENTE = FJT_CLIENT"  
cSql	+= " AND EL.EL_LOJA = FJT_LOJA"
cSql	+= " AND EL.EL_RECIBO = FJT_RECIBO"
cSql	+= " AND EL.EL_SERIE = FJT_SERIE"
cSql	+= " AND EL.EL_VERSAO = FJT_VERSAO  

If !lRecebidos
	cSql+= "AND EL.EL_DTENTRA = '' "+CRLF
EndIf

cSql	+= "AND EL.EL_TRANSIT <> '2'"
cSql	+= "AND EL.EL_TIPO <> 'NCC'"
cSql	+= "AND EL.EL_TIPO <> 'NDC'"
cSql	+= "AND EL.EL_TIPO <> 'RA'"
cSql	+= "AND EL.EL_TIPODOC <> 'TB'"
cSql	+= "AND EL.EL_FILIAL = '"+xFilial("SEL")+"'" 
cSql	+= "AND EL.D_E_L_E_T_ = ' '"
cSql	+= "ORDER BY EL.EL_CLIENTE,"
cSql	+= "EL.EL_DTDIGIT,"
cSql	+= "EL.EL_NUMERO"

If Select(cAliasTRB) > 0
	(cAliasTRB)->(DbCloseArea())
EndIf

cSql := ChangeQuery(cSql)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasTRB,.T.,.F.) 

If (cAliasTRB)->(Eof())
	(cAliasTRB)->(DbCloseArea())
	lRetSql := .F.
	aAdd(aColsX,Array(Len(aHeaderX)+1))
	aColsX[Len(aColsX),Len(aHeaderX)+1] := .F. 
	
	For nI := 1 To Len(aHeaderX)
		aColsX[Len(aColsX)][nI] := Criavar(aHeaderX[nI][2])   
		If Alltrim(aHeaderX[nI,2]) == "EL_FILIAL"
			aColsX[Len(aColsX)][nI] := 87BNO
		Endif		
	Next nI
	Help(" ",1,"FINNOFOUND",,STR0024,1,0) //"Nao foi possivel localizar documentos de acordo com os parametros informados"
EndIf 

If lRetSql
	nI	:= 0 
	SEL->(DbSetOrder(8))
	While (cAliasTRB)->(!Eof())
		aAdd(aColsX,Array(Len(aHeaderX)+1))
		nI++
		
		For nJ := 1 To Len(aHeaderX)
			aColsX[nI,nJ] := Criavar(aHeaderX[nJ][2]) 
			If aHeaderX[nJ][2] == "EL_FILIAL"  
				If Empty((cAliasTRB)->EL_DTENTRA)
					aColsX[nI,nJ] := 87BNO
				Else
					aColsX[nI,nJ] := 87BPT
				EndIf                                     
			ElseIf "A1_NOME" $ aHeaderX[nJ][2] 
				aColsX[nI,nJ] := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+PadR((cAliasTRB)->EL_CLIENTE,TamSx3("A1_COD")[1])+PadR((cAliasTRB)->EL_LOJA,TamSx3("A1_LOJA")[1]),1,"")
			ElseIf(cAliasTRB)->(FieldPos(aHeaderX[nJ][2]))> 0
				If aHeaderX[nJ][8] == "D" 
					aColsX[nI,nJ] := STOD((cAliasTRB)->(FieldGet(FieldPos(aHeaderX[nJ][2]))))
				ElseIf aHeaderX[nJ][8] == "C"  
			   		aColsX[nI,nJ] := (cAliasTRB)->(FieldGet(FieldPos(aHeaderX[nJ][2])))
			 	Else
			 		aColsX[nI,nJ] := (cAliasTRB)->(FieldGet(FieldPos(aHeaderX[nJ][2])))
				EndIf
			Endif
		Next nJ
		
		aColsX[nI][Len(aHeaderX)+1]:= .F.		
		
		aAdd(aIndiceSEL,(cAliasTRB)->(EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO))
		
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
EndIf
oGetDados:aCols	:= aClone(aColsx)
oGetDados:ForceRefresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845TdOkบAutor  ณJair Ribeiro        บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para tudook                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845TdOk(oGetDados)
Local lRet		:= .T.
Local nI		:= 0
Local nJ		:= 0 
Local aColsX	:= aClone(oGetDados:aCols) 
Local aHeaderX	:= aClone(oGetDados:aHeader)
Local nPosMrk	:= GdFieldPos("EL_FILIAL",aHeaderX)
Local nPosData	:= GdFieldPos("EL_DTENTRA",aHeaderX)

If nPosMrk > 0 .and. nPosData > 0
	For nI := 1 To Len(aColsX)
   		If (aColsX[nI,nPosMrk] == 87BOK) .and. Empty(aColsX[nI,nPosData])
			Help(" ",1,"FINDATAENT",,STR0025,1,0) //"Favor preencher a data de entrada de todos documentos marcados"
			oGetDados:GoTo(nI)
			lRet := .F.			
   		ElseIf (aColsX[nI,nPosMrk] == 87BOK)
   			nJ ++
   		EndIf 	
	Next nI
	If nJ == 0 .and. lRet
		Help(" ",1,"FINDATAENT",,STR0026,1,0) //"Nao foram selecionados documentos para serem processados"
		lRet := .F.			
	EndIf	
EndIf 
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Upd บAutor  ณJair Ribeiro        บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as movimentacoes necessarios devido entrega do     บฑฑ
ฑฑบ          ณ documento em transito                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ
ฑฑบ			 ณ aIndiceSEL: Array com os indices da SEL					  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Upd(oGetDados,aIndiceSEL,aRatCert,cCertRet,cPerg)
Local cCredMed	:= ""
Local cCredInm	:= ""
Local nI		:= 0
Local nJ		:= 0
Local nQtMoedas	:= Moedfin()
Local aCpoMoeda	:= {}
Local aTxMoeda	:= Array(nQtMoedas)
Local aColsX	:= aClone(oGetDados:aCols)
Local nPosMrk	:= GdFieldPos("EL_FILIAL",oGetDados:aHeader)
Local nPosTpDoc	:= GdFieldPos("EL_TIPODOC",oGetDados:aHeader)
Local nPosNumero:= GdFieldPos("EL_NUMERO",oGetDados:aHeader)
Local nPosCli	:= GdFieldPos("EL_CLIENTE",oGetDados:aHeader)
Local nPosLoja	:= GdFieldPos("EL_LOJA",oGetDados:aHeader)
Local nPosData	:= GdFieldPos("EL_DTENTRA",oGetDados:aHeader)
Local nPosTipo	:= GdFieldPos("EL_TIPO",oGetDados:aHeader)
Local bFilt1 	:= {|| ((FJS->FJS_RCOP == "1") .and. (FJS->FJS_CARTE $ "1|3"))} 
Local bFilt2 	:= {|| ((FJS->FJS_RCOP == "2") .and. (FJS->FJS_CARTE $ "1|3"))} 
Local cChave	:= xFilial("FJS")
Local cAlias	:= "FJS"
Local cCampo	:= "FJS_TIPO" 
Local nOrder	:= 1
Local nPosRat	:= 0 
Local lRatImp	:= GetMv("MV_RATIMP",.F.,"0") == "0"
Private aDiario := {}  

For nJ:= 1 To nQtMoedas
	If nJ == 1
		aAdd(aCpoMoeda,"EL_TXMOEDA")
	ElseIf nJ > 1 .and. nJ < 10
		aAdd(aCpoMoeda,"EL_TXMOE0"+AllTrim(STR(nJ)))
	Else
   		aAdd(aCpoMoeda,"EL_TXMOE"+AllTrim(STR(nJ)))
	EndIf
Next nJ

cCredMed	:=	FinGetTipo(bFilt1,cAlias,cChave,cCampo,nOrder)
cCredInm	:=	FinGetTipo(bFilt2,cAlias,cChave,cCampo,nOrder)

PcoIniLan("000361")
Begin Transaction
SEL->(DbSetOrder(8))
For nI := 1 To Len(aColsX)
	If aColsX[nI][nPosMrk] == 87BOK
	 	If SEL->(DbSeek(aIndiceSEL[nI]))	    
		    SEL->(RecLock("SEL",.F.))
		    SEL->EL_DTENTRA := aColsX[nI][nPosData]
		    If cPaisLoc == "COS"
		    	SEL->EL_NUMERO  := aColsx[nI][nPosNumero]
		    	SEL->EL_TIPODOC := aColsx[nI][nPosTpDoc]
		    EndIf
		    SEL->(MsUnlock())	    	
	    
			If (aColsX[nI][nPosTipo] $ cCredMed)
				For nJ := 1 To Len(aCpoMoeda)
		    		If SEL->(FieldPos(aCpoMoeda[nJ]))>0
		    			aTxMoeda[nJ] := SEL->&(aCpoMoeda[nJ])
		    		Else
			    		aTxMoeda[nJ] := 0
		    		EndIf
		    	Next nJ 
		    	
				Fin840SE1(PadR(aColsX[nI][nPosCli],TamSx3("EL_CLIENTE")[1]),PadR(aColsX[nI][nPosLoja],TamSX3("EL_LOJA")[1]),aTxMoeda,SEL->EL_TPCRED,SEL->EL_SERIE,SEL->EL_RECIBO,cCredInm)
			EndIf		
			
			If (SEL->EL_TPCRED $ "1|2" .or. aColsX[nI][nPosTipo] $ cCredInm)
				Fa840GSE5(2,SEL->EL_TPCRED,SEL->EL_NATUREZ,SEL->EL_RECIBO,SEL->EL_SERIE,aTxMoeda,SEL->EL_DIACTB,"NOR")
			EndIf
			
			If aColsX[nI][nPosTpDoc] == "CH"
				Fin840SEF(cCredInm)
			EndIf
		
		
			If (aColsX[nI][nPosTipo] $ cCertRet)
				nPosRat := AsCan(aRatCert,{|aX| aX[1] == oGetDados:nAt})
				If nPosRat > 0 
					Fin845SFE(aRatCert[nPosRat,2],SEL->EL_TIPODOC,SEL->EL_NUMERO,SEL->EL_RECIBO,aColsX[nI][nPosData],SEL->EL_VALOR,SEL->EL_CLIENTE,SEL->EL_LOJA,lRatImp)
				EndIf
			EndIf
		EndIf	
	EndIf	                 
Next nI

SEL->(DbSetOrder(8))
For nI := 1 To Len(aColsX)
	If aColsX[nI][nPosMrk] == 87BOK
	 	If SEL->(DbSeek(aIndiceSEL[nI]))
			PcoDetLan("000361","07","FINA087A")
   			Fa845Cont(cPerg)
   		EndIf
   EndIf
Next nI
End Transaction
PcoFinLan("000361") 

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Cli บAutor  ณJair Ribeiro        บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida cliente e loja e preenche nome cliente              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ cCliente: Codigo cliente 								  บฑฑ
ฑฑบ          ณ cLoja: Loja 												  บฑฑ
ฑฑบ          ณ cNomeCli: Nome/Razao Social do cliente	 				  บฑฑ
ฑฑบ          ณ lRetName: Identifica se preenche campo Nome				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Cli(cCliente,cLoja,cNomeCli,lRetName)
Local aArea		:= SA1->(GetArea())  
Local lRet		:= .T.
Default cCliente:= ""
Default cLoja	:= ""
Default	lRetName:= .F.

If SA1->(DbSeek(xFilial("SA1")+PadR(cCliente,TamSx3("A1_COD")[1])))
 	If cLoja != "" .and. SA1->(DbSeek(xFilial("SA1")+PadR(cCliente,TamSx3("A1_COD")[1])+PadR(cLoja,TamSx3("A1_LOJA")[1]))) .and. SA1->A1_MSBLQL == "1"  
		Help(" ",1,"REGBLOQ")
		lRet:= .F.
	Endif
Else
 		lRet:= .F.
EndIf
If lRetName .and. lRet
	cNomeCli := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+PadR(cCliente,TamSx3("A1_COD")[1])+PadR(cLoja,TamSx3("A1_LOJA")[1]),1,"")
EndIf
	
SA1->(RestArea(aArea))
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Vis บAutor  ณJair Ribeiro        บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualizacao do recibo                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: Objeto MsNewGetDados                            บฑฑ
ฑฑบ			 ณ nLinha: Linha da getdados								  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Vis(aIndiceSEL,nLinha)
Local aArea := SEL->(GetArea())
If !Empty(aIndiceSEL)   
	If cPaisLoc $ "ANG|ARG|AUS|BOL|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|TRI|URU|VEN"
		FJT->(DbSetOrder(1))
		If FJT->(DbSeek(SubStr(aIndiceSEL[nLinha],1,(TamSx3("FJT_FILIAL")[1]+SerieNfId("FJT",6,"FJT_SERIE")+TamSx3("FJT_RECIBO")[1])  ) ) )
			FWExecView (STR0009, 'FINA846', 1 /*nOperation*/, Nil /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ ) //'Recibos'
		Endif
	Else
		SEL->(DbSetOrder(8))
		If SEL->(DbSeek(aIndiceSEL[nLinha]))
			fa088Visual()
		EndIf
	Endif
EndIf
SEL->(RestArea(aArea))	
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845SEL บAutor  ณJair Ribeiro        บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche array com os campos que serao usados na getdados  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aCamposSEL: Campos da tabela SEL usadas no filtro          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845SEL(aCamposSEL)
aAdd(aCamposSEL,"EL_DTENTRA")
aAdd(aCamposSEL,"EL_CLIENTE")
aAdd(aCamposSEL,"EL_LOJA")
aAdd(aCamposSEL,"EL_RECIBO")
aAdd(aCamposSEL,"EL_SERIE")
aAdd(aCamposSEL,"EL_VERSAO")
aAdd(aCamposSEL,"EL_DTDIGIT")
aAdd(aCamposSEL,"EL_TIPO")
aAdd(aCamposSEL,"EL_TIPODOC")
aAdd(aCamposSEL,"EL_PREFIXO")
aAdd(aCamposSEL,"EL_NUMERO")
aAdd(aCamposSEL,"EL_PARCELA")
aAdd(aCamposSEL,"EL_VALOR")
aAdd(aCamposSEL,"EL_MOEDA")
aAdd(aCamposSEL,"EL_EMISSAO")
aAdd(aCamposSEL,"EL_BANCO")
aAdd(aCamposSEL,"EL_AGENCIA")
aAdd(aCamposSEL,"EL_CONTA")
aAdd(aCamposSEL,"EL_BCOCHQ")
aAdd(aCamposSEL,"EL_AGECHQ")
aAdd(aCamposSEL,"EL_CTACHQ")
aAdd(aCamposSEL,"EL_VLMOED1")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845HMrkบAutor  ณJair Ribeiro        บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui campo do tipo Bitmap no aHeader                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderX: aHeader a ser preenchido                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845HMrk(aHeaderx)
aAdd(aHeaderX,{;
	"",; 	  					// 01 - Titulo
	"EL_FILIAL",;					// 02 - Campo
	"@BMP",;			   		// 03 - Picture
	10,;						// 04 - Tamanho
	0,;					   		// 05 - Decimal
	"",;				   		// 06 - Valid
	"ววววววววววววววแ",;	  		// 07 - Usado
	"C",;				  		// 08 - Tipo
	"",;				  		// 09 - F3
	"R",;			   	  		// 10 - Contexto
	"",;				  		// 11 - ComboBox
	"",;				  		// 12 - Relacao
	"",;        	 	 		// 13 - When
	"V",;				 		// 14 - Visual
	"",;				 		// 15 - ValidUser
	"",;				  		// 16 - PictVar	
	.T.})				  		// 17 - Obrigat
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Hdr บAutor  ณJair Ribeiro        บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche aHeader                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderX: aHeader a ser preenchido                         บฑฑ
ฑฑบ          ณ cCampo: Campo contido no dicionario X3_CAMPO               บฑฑ
ฑฑบ          ณ cTitulo: Novo Titulo                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Hdr(aHeaderX,cCampo,cTitulo)
Local aArea		:= SX3->(GetArea())
Default cTitulo := ""

SX3->(DbSetOrder(2))
If SX3->(DbSeek(cCampo))
	cTitulo := Iif(Empty(cTitulo),X3Titulo(),cTitulo)
 	aAdd(aHeaderX,{;
		cTitulo,; 	  				// 01 - Titulo
		SX3->X3_CAMPO,;				// 02 - Campo
		SX3->X3_PICTURE,;			// 03 - Picture
		SX3->X3_TAMANHO,;			// 04 - Tamanho
		SX3->X3_DECIMAL,;			// 05 - Decimal
		SX3->X3_VALID,;				// 06 - Valid
		SX3->X3_USADO,;				// 07 - Usado
		SX3->X3_TIPO,;				// 08 - Tipo
		SX3->X3_F3,;				// 09 - F3
		SX3->X3_CONTEXT,;	   		// 10 - Contexto
		X3CBox(),;					// 11 - ComboBox
		SX3->X3_RELACAO,;			// 12 - Relacao
		SX3->X3_WHEN,;         		// 13 - When
		SX3->X3_VISUAL,;			// 14 - Visual
		SX3->X3_VLDUSER,;			// 15 - ValidUser
		SX3->X3_PICTVAR,;			// 16 - PictVar	
		X3Obrigat(SX3->X3_CAMPO)})	// 17 - Obrigat
EndIf
RestArea(aArea) 
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845HAltบAutor  ณJair Ribeiro        บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera aHeader                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderAlt: aHeader preenchido                             บฑฑ 
ฑฑบ          ณ cCampo: Campo a ser alterado no aHeader                    บฑฑ
ฑฑบ          ณ nAlt: Numerico indica que conteudo do aHeader deve ser	  บฑฑ
ฑฑบ          ณ alterado: 	01 - Titulo									  บฑฑ
ฑฑบ          ณ				02 - Campo									  บฑฑ
ฑฑบ          ณ				03 - Picture								  บฑฑ
ฑฑบ          ณ				04 - Tamanho								  บฑฑ
ฑฑบ          ณ				05 - Decimal								  บฑฑ
ฑฑบ          ณ				06 - Valid									  บฑฑ
ฑฑบ          ณ				07 - Usado									  บฑฑ
ฑฑบ          ณ				08 - Tipo									  บฑฑ
ฑฑบ          ณ				09 - F3									  	  บฑฑ
ฑฑบ          ณ				10 - Contexto								  บฑฑ
ฑฑบ          ณ				11 - ComboBox								  บฑฑ
ฑฑบ          ณ				12 - Relacao								  บฑฑ
ฑฑบ          ณ				13 - When									  บฑฑ
ฑฑบ          ณ				14 - Visual									  บฑฑ
ฑฑบ          ณ				15 - ValidUser								  บฑฑ
ฑฑบ          ณ				16 - PictVar								  บฑฑ
ฑฑบ          ณ				17 - Obrigat								  บฑฑ 
ฑฑบ          ณ xConteudo: Novo valor para conteudo do aHeader 			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845HAlt(aHeaderAlt,cCampo,nAlt,xConteudo)
Local nPos	:= aSCan(aHeaderAlt,{|aX| AllTrim(aX[2]) == AllTrim(cCampo)})
If nPos > 0  .and. (nAlt >= 1 .and. nAlt <= 17) 
	aHeaderAlt[nPos,nAlt]:= xConteudo
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845Pos บAutor  ณJair Ribeiro	     บ Data ณ  07/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna posicao X para objetos	                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nPerc: Numero percentual para posicionamento               บฑฑ
ฑฑบ          ณ oBj: Objeto pai                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845Pos(nPerc,oBj,lVert)
Local aDimensao	:= FWGetDialogSize(oBj)
Local nSIze		:= 0
Default lVert	:= .T.
If lVert 
	nSize := (aDimensao[3]/2 * nPerc)/100
Else
	nSize := (aDimensao[4]/2 * nPerc)/100
EndIf
Return INT(nSize)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFin845DCt		ณAutor ณSabrina Passini SoaresณDataณ 18.06.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao que mostra os panel para digitacao dos rateios das  ณฑฑ
ฑฑณ          ณ retencoes recebidos pelos titulos selecionados             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fin845DCt(cRetText,nRetVal,cRetNum,aItRet,cRet)
Local oDlg			:= Nil
Local oPanelM		:= Nil
Local oPanelT		:= Nil
Local oPanelC		:= Nil
Local oGCertif		:= Nil
Local oGCenter		:= Nil 
Local oGet1			:= Nil
Local oGet2			:= Nil
Local oGet3			:= Nil
Local oSay1			:= Nil
Local oSay2			:= Nil
Local oSay3			:= Nil 
Local oGetDd		:= Nil		

Local nI			:= 0
Local nJ			:= 0		
Local nUsado		:= 0
Local nOpc 			:= 0

Local lRet			:= .F.
                                         
Local aCamposGet	:= {}
Local aHeaderX		:= {}
Local aColsX		:= {}
Local aAlter		:= {}

Local bFieldOk		:= {|| IiF(lRatImp,.F.,.T.).or. Fin845FlC(oGetDd)}
Local bRetencao		:= {|| IiF(Fin845VRt(aItRet,nRetVal,oGetDd), Eval({|| lRet := .T.,oDlg:End()}) ,.F.)}
Local bEndWin		:= {|| oDlg:End()}

Local cTitulo		:= STR0027 //"Distribuicao da Retencao"
Local lRatImp		:= GetMv("MV_RATIMP",.F.,"0") == "0"

//SaveInter()
If !(cPaisLoc $ "ANG|ARG|AUS|BOL|BRA|CHI|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|SAL|URU|VEN")
	Return .T.
Endif

oDlg:= MSDialog():New(65,0,500,700,cTitulo,,,,,,,,oMainWnd,.T.)
	oPanelM:=TPanel():New(001,001,,oDlg,,,,,,30,30,.F.,.F.)
	oPanelM:align:= CONTROL_ALIGN_ALLCLIENT

	oPanelT:=TPanel():New(001,001,,oPanelM,,,,,,200,040,.F.,.F.)
	oPanelT:align:= CONTROL_ALIGN_TOP
	
	oPanelC:=TPanel():New(001,001,,oPanelM,,,,,,200,050,.F.,.F.)
	oPanelC:align:= CONTROL_ALIGN_ALLCLIENT
	     
    oGCertif:= tGroup():New(0,5	,40,344		,STR0028 	,oPanelT,,,.T.)	 //"Dados do Recibo"
    oGCertif:align:= CONTROL_ALIGN_ALLCLIENT
    oSay1	:= TSay():New(10,010	,{|| STR0029 }			,oPanelT,,,,,,.T.)  //"Tipo"
   	oSay3	:= TSay():New(10,100	,{|| STR0020 }			,oPanelT,,,,,,.T.)  //"Numero"
   	oSay2	:= TSay():New(10,190	,{|| STR0030 }			,oPanelT,,,,,,.T.)  //"Valor"

   	oGet1	:= TGet():New(20,010	,{|u| if(PCount()>0,cRetText:=u,cRetText)}		,oPanelT,80,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cRetText")
 	oGet2	:= TGet():New(20,100	,{|u| if(PCount()>0,cRetNum:=u,cRetNum)}		,oPanelT,80,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cRetNum")
	oGet3	:= TGet():New(20,190	,{|u| if(PCount()>0,nRetVal:=u,nRetVal)}		,oPanelT,80,10,PesqPict("SE1","E1_VALOR"),,,,,,,.T.,,,,,,,.T.,,,"nRetVal")
    
 	If lRatImp
		If cRet $ "RB|RI"
			aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
		ElseIf	cRet $ "RG|RS"                                                                                               
			aCamposGet	:=	{"FE_SERIE","FE_NFISCAL","FE_PARCELA","E1_TIPO","FE_EST","FE_CFO",Iif(cRet $ "RG","A2_AGREGAN","A2_CONCSUS"),"FE_VALBASE","FE_ALIQ","FE_RETENC"}
		EndIf	
	Else
		If cRet $ "RB|RI"
			aCamposGet	:=	{"FE_EST","FE_CFO","FE_VALBASE","FE_ALIQ","FE_RETENC"}
		ElseIf cRet $ "RS|RG" 
			aCamposGet	:=	{"FE_EST","FE_CFO",Iif(cRet $ "RG","A2_AGREGAN","A2_CONCSUS"),"FE_VALBASE","FE_ALIQ","FE_RETENC"}		
		EndIf
	Endif
	
	For nI := 1 To Len(aCamposGet)
		Fin845Hdr(aHeaderX,aCamposGet[nI])
	Next nI
		
	aAlter 	:= {"FE_VALBASE","FE_ALIQ","FE_CFO","FE_EST","FE_RETENC","A2_AGREGAN","A2_CONCSUS"}
	nUsado		:=	Len(aCamposGet)
	aColsX		:={}
	
	If lRatImp
		For nI:= 1 To Len(aItRet)
			aAdd(aColsX,Array(nUsado+1))
			aColsX[nI,nUsado+1]:=.F.
			aColsX[nI,1]	:=	aItRet[nI,1]
			aColsX[nI,2]	:=	aItRet[nI,2]
			aColsX[nI,3]	:=	aItRet[nI,3]
			aColsX[nI,4]	:=	aItRet[nI,4]
			
			For nJ := 5 To Len(aHeaderX)
				aColsX[Len(aColsX)][nJ] := Criavar(aHeaderX[nJ][2])
			Next nJ
		Next nI
	Else
		aAdd(aColsX,Array(nUsado+1))
		aColsX[1,nUsado+1]:=.F.
		For nI	:=	1 To Len(aHeaderX)
			aColsX[1,nI]	:=	Criavar(aHeaderX[nI][2])
		Next nI      
	EndIf 
  	oGetDd:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlter,,,"AllwaysTrue",,,oPanelC,aHeaderX,aColsX)
   	oGetDd:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	 
    oGetDd:bFieldOk := bFieldOk
ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bRetencao,bEndWin)

If(cRet $ "RB|RI|RS|RG") .and. lRet
	aItRet := aClone(oGetDd:aCols)
EndIf
//RestInter()
Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845VRt บAutor  ณMicrosiga           บ Data ณ  08/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845VRt(aItems,nRetVal,oGetDd)
Local lRet 		:= .T.
Local nI   		:= 0
Local nTotal 	:= 0
Local nPosRet	:=	GdFieldPos("FE_RETENC"	,oGetDd:aHeader)
Local nPosTipo	:=	GdFieldPos("E1_TIPO"	,oGetDd:aHeader)
Local nPosCFO	:=	GdFieldPos("FE_CFO"		,oGetDd:aHeader)
Local nPosEst	:=	GdFieldPos("FE_EST"		,oGetDd:aHeader)
Local nPosAlq	:=	GdFieldPos("FE_ALIQ" 	,oGetDd:aHeader)
Local nPosBas	:=	GdFieldPos("FE_VALBASE"	,oGetDd:aHeader)
              

For nI := 1 To Len(oGetDd:aCols)
	If !oGetDd:aCols[nI,Len(oGetDd:aCols[nI])]
 	nTotal := nTotal + oGetDd:aCols[nI,nPosRet] * IIf(nPosTipo> 0 .And. oGetDd:aCols[nI,nPosTipo] $ MV_CRNEG+"|"+MVRECANT,-1,1)
		If oGetDd:aCols[nI,nPosRet] <> 0 .and.;
			 (Empty(oGetDd:aCols[nI,nPosCFO]) .or.;
			  Empty(oGetDd:aCols[nI,nPosEST]) .or.;
			  Empty(oGetDd:aCols[nI,nPosBas]) .or.;
			  Empty(oGetDd:aCols[nI,nPosAlq]))
		
			Help("",1,"OBRIGAT")
			lRet	:=	.F.
			Exit
		EndIf		
	EndIf		
Next nI   
If lRet
	If (Round(nTotal,MsDecimais(1)) > nRetVal )
		Help(" ",1,"FINVALOR",,'O valor digitado e maior que o valor da retencao',1,0)
		lRet	:=	.F.
	ElseIf ( Round(nTotal,MsDecimais(1)) < nRetVal )
		Help(" ",1,"FINVALOR",,'O valor digitado e maior que o valor da retencao',1,0)
		lRet	:=	.F.
	EndIf
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845FlC บAutor  ณBruno           	 บ Data ณ  08/24/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para recplicar os dados que devem ser iguais acols  บฑฑ
ฑฑบ          ณ do detalhe das retencoes. (Argentina)                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fin845FlC(oGetDados)
Local xCont	:=	Nil            
Local nI	:= 0

IF "FE_CFO"$ ReadVar() 
	 xCont	:=	  &(ReadVar())
	 For nI:= 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nI,6]	:=	xCont
    Next nI
ElseIf "FE_EST"$ ReadVar() 
	 xCont	:=	  &(ReadVar())
	 For nI:= 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nI,5]	:=	xCont
    Next nI
ElseIf "FE_ALIQ"$ ReadVar() 
	 xCont	:=	  &(ReadVar())
	 For nI:= 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nI,Len(aCols[nI])-2]	:=	xCont
		oGetDados:aCols[nI,Len(aCols[nI])-1]	:=	oGetDados:aCols[nI,Len(aCols[nI])-3] * oGetDados:aCols[nI,Len(aCols[nI])-2] /100
    Next nI
ElseIf "A2_AGREGAN"$ ReadVar() 
	 xCont	:=	  &(ReadVar())
	 For nI:= 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nI,7]	:=	xCont
    Next nI
ElseIf "A2_CONCSUS"$ ReadVar() 
	 xCont	:=	  &(ReadVar())
	 For nI:= 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nI,7]	:=	xCont
    Next nI
Endif                          
oGetDados:oBrowse:Refresh()
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFin845SFE บAutor  ณMicrosiga           บ Data ณ  08/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fin845SFE(aRateio,cTipoDoc,cNumero,cRecibo,dDataRef,nValor,cCliente,cLoja,lRatImp)
Local nI	:= 0

For nI := 1 To Len(aRateio)
	If cTipoDoc == "RB"
		If !aRateio[nI][Len(aRateio[nI])] .and. (aRateio[nI][Len(aRateio[nI])-1] > 0) .and.;
			(!lRatImp .or. SE1->(DbSeek(xFilial("SE1")+aRateio[nI][1]+aRateio[nI][2]+aRateio[nI][3]+aRateio[nI][4])))
		
			SFE->(RecLock("SFE",.T.))    
			SFE->FE_FILIAL	:= xFilial('SFE')   
			SFE->FE_EMISSAO	:= dDataRef
			SFE->FE_CLIENTE	:= cCliente
			SFE->FE_LOJCLI	:= cLoja       
			
			If lRatImp
				SFE->FE_NFISCAL	:= SE1->E1_NUM
				SFE->FE_SERIE	:= SE1->E1_SERIE
				SFE->FE_EST		:= aRateio[nI][5]   
				SFE->FE_CFO		:= aRateio[nI][6]   
				SFE->FE_VALBASE	:= aRateio[nI][7]   
				SFE->FE_ALIQ	:= aRateio[nI][8]   
				SFE->FE_RETENC 	:= aRateio[nI][9]   
			Else
				SFE->FE_EST		:= aRateio[nI][1]   
				SFE->FE_CFO		:= aRateio[nI][2]   
				SFE->FE_VALBASE	:= aRateio[nI][3]   
				SFE->FE_ALIQ	:= aRateio[nI][4]   
				SFE->FE_RETENC	:= aRateio[nI][5]   
			EndIf
			SFE->FE_RECIBO	:= cRecibo       
			SFE->FE_NROCERT	:= cNumero
			SFE->FE_TIPO	:= "B"
			SFE->(MsUnlock())
		EndIf 
	ElseIf cTipoDoc == "RI"
		If !aRateio[nI][Len(aRateio[nI])] .and. (aRateio[nI][Len(aRateio[nI])-1] > 0) .and.;
			(!lRatImp .or. SE1->(DbSeek(xFilial("SE1")+aRateio[nI][1]+aRateio[nI][2]+aRateio[nI][3]+aRateio[nI][4]))) 
		
		SFE->(RecLock("SFE",.T.))    
		SFE->FE_FILIAL	:= xFilial('SFE')   
		SFE->FE_EMISSAO	:= dDataRef
		SFE->FE_CLIENTE	:= cCliente
		SFE->FE_LOJCLI	:= cLoja       
		If lRatImp
			SFE->FE_NFISCAL	:= SE1->E1_NUM
			SFE->FE_SERIE	:= SE1->E1_SERIE
			SFE->FE_EST		:= aRateio[nI][5]   
			SFE->FE_CFO		:= aRateio[nI][6]   
			SFE->FE_VALBASE	:= aRateio[nI][7]   
			SFE->FE_ALIQ	:= aRateio[nI][8]   
			SFE->FE_RETENC	:= aRateio[nI][9]   
		Else
			SFE->FE_EST		:= aRateio[nI][1]   
			SFE->FE_CFO		:= aRateio[nI][2]   
			SFE->FE_VALBASE	:= aRateio[nI][3]   
			SFE->FE_ALIQ	:= aRateio[nI][4]   
			SFE->FE_RETENC	:= aRateio[nI][5]   
		EndIf
		SFE->FE_RECIBO	:= cRecibo       
		SFE->FE_NROCERT	:= cNumero 
		SFE->FE_TIPO	:= "I"
		SFE->(MsUnlock())
	EndIf	
	ElseIf cTipoDoc == "RG"
		If !aRateio[nI][Len(aRateio[nI])] .and. (aRateio[nI][Len(aRateio[nI])-1] > 0) .and.;
			(!lRatImp .or. SE1->(DbSeek(xFilial("SE1")+aRateio[nI][1]+aRateio[nI][2]+aRateio[nI][3]+aRateio[nI][4]))) 	 		
			
			SFE->(RecLock("SFE",.T.))    
			SFE->FE_FILIAL	:= xFilial('SFE')   
			SFE->FE_EMISSAO	:= dDataRef
			SFE->FE_CLIENTE	:= cCliente
			SFE->FE_LOJCLI	:= cLoja       
			If lRatImp
				SFE->FE_NFISCAL	:= SE1->E1_NUM
				SFE->FE_SERIE	:= SE1->E1_SERIE
				SFE->FE_EST		:= aRateio[nI][5]   
				SFE->FE_CFO		:= aRateio[nI][6]   
				SFE->FE_CONCEPT	:= aRateio[nI][7]   
				SFE->FE_VALBASE	:= aRateio[nI][8]   
				SFE->FE_ALIQ	:= aRateio[nI][9]   
				SFE->FE_RETENC	:= aRateio[nI][10]   
			Else
				SFE->FE_EST		:= aRateio[nI][1]   
				SFE->FE_CFO		:= aRateio[nI][2]   
				SFE->FE_CONCEPT	:= aRateio[nI][3] 
				SFE->FE_VALBASE	:= aRateio[nI][4]   
				SFE->FE_ALIQ	:= aRateio[nI][5]   
				SFE->FE_RETENC	:= aRateio[nI][6]   
			EndIf
			SFE->FE_RECIBO	:= cRecibo       
			SFE->FE_NROCERT	:= cNumero 
			SFE->FE_TIPO	:= "G"
			SFE->(MsUnlock())
		EndIf	
	ElseIf cTipoDoc == "RS"
		If !aRateio[nI][Len(aRateio[nI])] .and. (aRateio[nI][Len(aRateio[nI])-1] > 0) .and.;
			(!lRatImp .or. SE1->(DbSeek(xFilial("SE1")+aRateio[nI][1]+aRateio[nI][2]+aRateio[nI][3]+aRateio[nI][4]))) 
	 		
			SFE->(RecLock("SFE",.T.))
			SFE->FE_FILIAL	:= xFilial('SFE')   
			SFE->FE_EMISSAO	:= dDataRef
			SFE->FE_CLIENTE	:= cCliente
			SFE->FE_LOJCLI	:= cLoja       
			If lRatImp
				SFE->FE_NFISCAL	:= SE1->E1_NUM
				SFE->FE_SERIE	:= SE1->E1_SERIE
				SFE->FE_EST		:= aRateio[nI][5]   
				SFE->FE_CFO		:= aRateio[nI][6]   
				SFE->FE_CONCEPT	:= aRateio[nI][7] 
				SFE->FE_VALBASE	:= aRateio[nI][8]   
				SFE->FE_ALIQ	:= aRateio[nI][9]   
				SFE->FE_RETENC	:= aRateio[nI][10]   
			Else
				SFE->FE_EST		:= aRateio[nI][1]   
				SFE->FE_CFO		:= aRateio[nI][2]   
				SFE->FE_CONCEPT	:= aRateio[nI][3] 
				SFE->FE_VALBASE	:= aRateio[nI][4]   
				SFE->FE_ALIQ	:= aRateio[nI][5]   
				SFE->FE_RETENC	:= aRateio[nI][6]    
			Endif
				SFE->FE_RECIBO	:= cRecibo       
				SFE->FE_NROCERT	:= cNumero 
				SFE->FE_TIPO	:= "S"
				SFE->(MsUnlock())
		EndIf	
	Else
		If aRateio[nI][7] == cTipoDoc     
			If (aRateio[nI][5] > 0) .and. SE1->(DbSeek(xFilial("SE1")+aRateio[nI][1]+aRateio[nI][2]+aRateio[nI][3]+aRateio[nI][4])) 
			
				SFE->(RecLock("SFE",.T.))
				SFE->FE_FILIAL	:= xFilial('SFE')   
				SFE->FE_EMISSAO	:= dDataRef
				SFE->FE_CLIENTE	:= cCliente
				SFE->FE_LOJCLI	:= cLoja    
				SFE->FE_NFISCAL	:= SE1->E1_NUM
				SFE->FE_SERIE	:= SE1->E1_SERIE
				SFE->FE_RECIBO	:= cRecibo       
				SFE->FE_NROCERT	:= aRateio[nI][6]  
				SFE->FE_TIPO	:= Subs(aRateio[nI][7],2,1)
				SFE->FE_RETENC	:= aRateio[nI][5]   
				SFE->(MsUnlock())
			EndIf
		EndIf
	EndIf
Next nI
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa845Cont บAutor  ณMicrosiga           บ Data ณ  03/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa845Cont(cPerg)
Local nHdlPrv	:= 0
Local cKeyImp 	:= ""
Local cAlias	:= ""
Local aFlagCTB 	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local cPadrao 	:= ""
Local nTotalLanc:= 0
Local cArquivo	:= ""
Local nLinha 	:= 1
Local lLancPad	:= .F.

Local lDigita  	:= .F.
Local lAglutina	:= .F.
Local lGeraLanc	:= .F.
Local cDiario	:= SEl->EL_DIACTB 
Local aDiario	:= {}

Pergunte(cPerg,.F.)

lDigita  	:= If( MV_PAR01==1,.T.,.F.)  // Mostra Lanctos.
lAglutina	:= If( MV_PAR02==1,.T.,.F.)  // Aglutina Lanctos.
lGeraLanc	:= If( MV_PAR03==1,.T.,.F.)  // Lanctos. On-Line

If lGeraLanc
	lLancPad := VerPadrao('5A1')
	cPadrao := '5A1'	
Else
	Return
EndIf
   
If lLancPad
	cLoteCom:= LoteCont("FIN")
	
	nHdlPrv := HeadProva( cLoteCom,;
	                      "FINA845",;
	                      Substr(cUsuario,7,6),;
	                      @cArquivo)
	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")
	EndIf
EndIf

If nHdlPrv > 0 .and. lLancPad
	SA6->(DbsetOrder(1))
	SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
			
	SE1->(DbsetOrder(2))
	SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))
			
	Do Case
		Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
			cAlias := "SF1"
		Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
			cAlias := "SF1"         
		Otherwise
			cAlias := "SF2"    
	EndCase
		
	cKeyImp := 	xFilial(cAlias)	+;
				SE1->E1_NUM		+;
				SE1->E1_PREFIXO	+;
				SE1->E1_CLIENTE	+;
				SE1->E1_LOJA			
	
	If (cAlias == "SF1")
		cKeyImp += SE1->E1_TIPO
	Endif
	
	Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Prepara Lancamento Contabil                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
		aAdd(aFlagCTB,{"EL_LA","S","SEL",SEL->(Recno()),0,0,0})
	EndIf
				
	nTotalLanc := nTotalLanc + DetProva(nHdlPrv,;
											"5A1",;
											"FINA840" /*cPrograma*/,;
											cLoteCom,;
											@nLinha,;
											/*lExecuta*/,;
											/*cCriterio*/,;
											/*lRateio*/,;
											/*cChaveBusca*/,;
											/*aCT5*/,;
											/*lPosiciona*/,;
											@aFlagCTB,;
											/*aTabRecOri*/,;
											/*aDadosProva*/)

	If UsaSeqCor()
		AAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
	EndIf			

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetiva Lanamento Contabil                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RodaProva(nHdlPrv,nTotalLanc)
	
	lLanctOk := cA100Incl(cArquivo,;
							nHdlPrv,;
							3 /*nOpcx*/,;
							cLoteCom,;
							lDigita,;
							lAglutina,;
							/*cOnLine*/,;
							/*dData*/,;
							/*dReproc*/,;
							@aFlagCTB,;
							/*aDadosProva*/,;
							aDiario)
	aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

	If lLanctOk
		RecLock("SEL",.F.)
		Replace EL_LA With "S"
		MsUnLock()
		SEL->(DbSkip())
	EndIf
EndIf
Return
