#INCLUDE "TMSA145.ch"
#INCLUDE "TOTVS.ch"

// -- Exibição Veículos
#DEFINE PV_STAVGE  1
#DEFINE PV_CODVEI  2
#DEFINE PV_PLACA   3
#DEFINE PV_TIPVEI  4
#DEFINE PV_FROTA   5
#DEFINE PV_NOMMOT  6
#DEFINE PV_FILBAS  7
#DEFINE PV_FILORI  8
#DEFINE PV_VIAGEM  9
#DEFINE PV_DESROT 10
#DEFINE PV_DESSVT 11
#DEFINE PV_DESTPT 12
#DEFINE PV_DATGER 13
#DEFINE PV_PRVTER 14
#DEFINE PV_CODRB1 15
#DEFINE PV_PLARB1 16
#DEFINE PV_CODRB2 17
#DEFINE PV_PLARB2 18
#DEFINE PV_SERTMS 19
#DEFINE PV_TIPTRA 20
#DEFINE PV_POSICI 21
#DEFINE PV_DATPOS 22
#DEFINE PV_HORPOS 23
#DEFINE PV_CODRB3 24
#DEFINE PV_PLARB3 25

//-- Exibição Documentos
#DEFINE PD_STADOC  1
#DEFINE PD_FILDOC  2
#DEFINE PD_DOC     3
#DEFINE PD_SERIE   4
#DEFINE PD_DATEMI  5
#DEFINE PD_CLIREM  6
#DEFINE PD_LOJREM  7
#DEFINE PD_NOMREM  8
#DEFINE PD_REGORI  9
#DEFINE PD_CLIDES 10
#DEFINE PD_LOJDES 11
#DEFINE PD_NOMDES 12
#DEFINE PD_REGDES 13
#DEFINE PD_VIAGEM 14
#DEFINE PD_DESROT 15
#DEFINE PD_DESSVT 16
#DEFINE PD_DESTPT 17
#DEFINE PD_DATGER 18
#DEFINE PD_PRVTER 19
#DEFINE PD_CODVEI 20
#DEFINE PD_PLACA  21
#DEFINE PD_TIPVEI 22
#DEFINE PD_FROTA  23
#DEFINE PD_NOMMOT 24
#DEFINE PD_FILBAS 25
#DEFINE PD_SERTMS 26
#DEFINE PD_TIPTRA 27
#DEFINE PD_DATPOS 28
#DEFINE PD_HORPOS 29
#DEFINE PD_POSICI 30

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA145  ³ Autor ³ Gustavo Almeida       ³ Data ³ 22/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestão de Viagens                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsA145()

Local   cPerg   := "TMSA145"
Local   lRastre := AliasInDic("DAV") .And. DAV->( FieldPos("DAV_HORPOS") ) > 0

Private oAmarelo  := LoadBitmap( GetResources() ,"BR_AMARELO"	)
Private oAzul     := LoadBitmap( GetResources() ,"BR_AZUL"		)
Private oBranco   := LoadBitmap( GetResources() ,"BR_BRANCO"	)
Private oCinza    := LoadBitmap( GetResources() ,"BR_CINZA"		)
Private oLaranja  := LoadBitmap( GetResources() ,"BR_LARANJA"	)
Private oPreto    := LoadBitmap( GetResources() ,"BR_PRETO"		)
Private oVerde    := LoadBitmap( GetResources() ,"BR_VERDE"		)
Private oVermelho := LoadBitmap( GetResources() ,"BR_VERMELHO"	)
Private oPink     := LoadBitmap( GetResources() ,"BR_PINK"		)
Private aSize     := MsAdvSize(.T.)
Private aObjects  := {}
Private aHeaderVei:= {}
Private aHeaderDoc:= {}
Private aSetKey   := {}
Private oDlgPnl, nI, oTimer
Private oToolBar, oRodape, oExibVei, oBar, oBVei, oLbVei, oExibDoc, oBDoc, oLbDoc

//-- Array Dados
Private aDadosVei := {}
Private aDadosDoc := {}
Private aDadosRod := Array(5)

//-- Tamanho do Array de Veículos
Private nTamAVei  := 25 

//-- Tamanho do Array de Documento
Private nTamADoc  := 27

//-- Rodapé
Private nQtdVge
Private nQtdVol
Private nPesTot
Private nValMer
Private nQtdDoc

//-- Visul. Dctos
Private aRotina   := {}

If lRastre
	nTamAVei := 25 
	nTamADoc := 30
EndIf

//-- Verificação de Release .5 do Protheus 11
If FindFunction('TMSChkVer') .And. !TMSChkVer('11','R5')
	Aviso(STR0078, STR0079 + Chr(10)+Chr(13) + STR0080, {STR0041}, 1) //--"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
	Return Nil
EndIf

If Pergunte(cPerg,.T.)

	TmsA145Pnl(mv_par01)

EndIf

Return Nil

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} TmsA145Pnl
Rotina de exibição por veiculo do Painel de Gestão de Viagens

@sample
TmsA145Pnl(ExpN1)

@param ExpN1 Identifica o tipo de painel que será exibido
				1: Painel de veículos
				2: Painel de Documentos

@author Equipe TMS
@since 22/10/10
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function TmsA145Pnl(nPnl)
	Local lNewDlg := .F.
	Local nTimeGV := SuperGetMV('MV_TMSGVT',,60)
	Local lRastre := AliasInDic("DAV") .And. DAV->( FieldPos("DAV_HORPOS") ) > 0 
	Local lTercRbq	:= DTR->(ColumnPos("DTR_CODRB3")) > 0
	Local oSize
	
	nTimeGV := (nTimeGV * 1000)
	
	MsgRun(STR0001,,{|| TmsA145Qry(nPnl) }) //"Aguarde, verificando registros..."
	
	//-- Tela Principal
	If Type("oDlgPnl") != "O"
		oSize := FwDefSize():New(.F.)
		oSize:lLateral     := .F.
		oSize:AddObject("TOOLBAR", 100, 16, .T., .F. )
		oSize:AddObject("LISTBOX", 100, 64, .T., .T. )
		oSize:AddObject("RODAPE",  100, 20, .T., .F. )
		oSize:aMargins	:= {0, 0, 0, 0}
		oSize:Process()
		
		DEFINE MSDIALOG oDlgPnl FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
		lNewDlg := .T.
	
		//-- Montagem da Tela Principal e Rodapé 
		oToolBar := TPanel():New(oSize:GetDimension("TOOLBAR","LININI"), oSize:GetDimension("TOOLBAR","COLINI"), "", oDlgPnl,,,,,CLR_WHITE, oSize:GetDimension("TOOLBAR","XSIZE") -1, oSize:GetDimension("TOOLBAR","YSIZE") -1, .F., .T.)
		oExibVei := TPanel():New(oSize:GetDimension("LISTBOX","LININI"), oSize:GetDimension("LISTBOX","COLINI"), "", oDlgPnl,,,,,CLR_WHITE, oSize:GetDimension("LISTBOX","XSIZE") -1, oSize:GetDimension("LISTBOX","YSIZE") -1, .F., .T.)
		oExibDoc := TPanel():New(oSize:GetDimension("LISTBOX","LININI"), oSize:GetDimension("LISTBOX","COLINI"), "", oDlgPnl,,,,,CLR_WHITE, oSize:GetDimension("LISTBOX","XSIZE") -1, oSize:GetDimension("LISTBOX","YSIZE") -1, .F., .T.)
		oRodape  := TPanel():New(oSize:GetDimension("RODAPE","LININI") + 1,  oSize:GetDimension("RODAPE","COLINI"),  "", oDlgPnl,,,,,CLR_WHITE, oSize:GetDimension("RODAPE","XSIZE")  -1, oSize:GetDimension("RODAPE","YSIZE"), .F., .F.)
		
		oBar   	 := TBar():New(oToolBar, oSize:GetDimension("TOOLBAR","LININI"),oSize:GetDimension("TOOLBAR","COLINI"),.T.,,,,.F.)
		oBar:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oRodape :FreeChildren()
	EndIf
	
	If nPnl == 1 //-- Por Veículo
		aDadosDoc := {}
		Aadd(aDadosDoc,Array(nTamADoc))
		Afill(aDadosDoc[Len(aDadosDoc)],"")
		If Len(aDadosVei) == 0
			aDadosVei := {}
			Aadd(aDadosVei,Array(nTamAVei))
			Afill(aDadosVei[Len(aDadosVei)],"")
		EndIf
	Else
		aDadosVei := {}
		Aadd(aDadosVei,Array(nTamAVei))
		Afill(aDadosVei[Len(aDadosVei)],"")
		If Len(aDadosDoc) == 0
			aDadosDoc := {}
			Aadd(aDadosDoc,Array(nTamADoc))
			Afill(aDadosDoc[Len(aDadosDoc)],"")
		EndIf
	EndIf
	
	If Len(aHeaderVei) == 0
		AAdd( aHeaderVei,' ' )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTR_CODVEI' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DA3_PLACA'  , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DA3_TIPVEI' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DA3_FROVEI' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DA4_NOME'   , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DA3_FILBAS' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_FILORI' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_VIAGEM' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_ROTA  ' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_SERTMS' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_TIPTRA' , 'X3Titulo()') )
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTQ_DATGER' , 'X3Titulo()') )
		AAdd( aHeaderVei,STR0002) //"Prev. Termino"
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTR_CODRB1' , 'X3Titulo()') )
		AAdd( aHeaderVei,STR0003) //"Placa.1o.Reboq"
		AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTR_CODRB2' , 'X3Titulo()') )
		AAdd( aHeaderVei,STR0004) //"Placa.2o.Reboq" 
		If lTercRbq
			AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DTR_CODRB3' , 'X3Titulo()') )
			AAdd( aHeaderVei,STR0087) //"Placa.3o.Reboq" 
		EndIf 
		If lRastre
			AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DAV_DATPOS' , 'X3Titulo()') )
			AAdd( aHeaderVei,Posicione('SX3' ,2 ,'DAV_HORPOS' , 'X3Titulo()') )
			AAdd( aHeaderVei,Posicione('SX3', 2 ,'DAV_POSICI' , 'X3Titulo()') )
		EndIf
	
		If	lTercRbq
			@ 0, 0 LISTBOX oLbVei VAR cLbVei FIELDS HEADER aHeaderVei[01],aHeaderVei[02],aHeaderVei[03],aHeaderVei[04],;
			aHeaderVei[05],aHeaderVei[06],aHeaderVei[07],aHeaderVei[08],aHeaderVei[09],aHeaderVei[10],aHeaderVei[11],aHeaderVei[12],;
			aHeaderVei[13],aHeaderVei[14],aHeaderVei[15],aHeaderVei[16],aHeaderVei[17],aHeaderVei[18],aHeaderVei[19],aHeaderVei[20],aHeaderVei[21],aHeaderVei[22],aHeaderVei[23];
			SIZE oSize:GetDimension("LISTBOX","COLEND"), 200 OF oExibVei PIXEL
		ElseIf lRastre
		 	@ 0, 0 LISTBOX oLbVei VAR cLbVei FIELDS HEADER aHeaderVei[01],aHeaderVei[02],aHeaderVei[03],aHeaderVei[04],;
			aHeaderVei[05],aHeaderVei[06],aHeaderVei[07],aHeaderVei[08],aHeaderVei[09],aHeaderVei[10],aHeaderVei[11],aHeaderVei[12],;
			aHeaderVei[13],aHeaderVei[14],aHeaderVei[15],aHeaderVei[16],aHeaderVei[17],aHeaderVei[18],aHeaderVei[19],aHeaderVei[20],aHeaderVei[21];
			SIZE oSize:GetDimension("LISTBOX","COLEND"), 200 OF oExibVei PIXEL
		Else
			@ 0, 0 LISTBOX oLbVei VAR cLbVei FIELDS HEADER aHeaderVei[01],aHeaderVei[02],aHeaderVei[03],aHeaderVei[04],;
			aHeaderVei[05],aHeaderVei[06],aHeaderVei[07],aHeaderVei[08],aHeaderVei[09],aHeaderVei[10],aHeaderVei[11],aHeaderVei[12],;
			aHeaderVei[13],aHeaderVei[14],aHeaderVei[15],aHeaderVei[16],aHeaderVei[17],aHeaderVei[18] ;
			SIZE oSize:GetDimension("LISTBOX","COLEND"), 325 OF oExibVei PIXEL
		EndIf
		
		oLbVei:Align := CONTROL_ALIGN_ALLCLIENT
		
		//-- Ações Por Veículo
		
		If nPnl	== 1
			TBtnBmp2():New( 00, 05, 35, 25,'PESQUISA' ,,,,{|| TmsA145Psq(1,aDadosVei)},oBar,STR0005+" - <F4>"      ,,.F.,.F. ) //"Pesquisa - <F4>"
			TBtnBmp2():New( 00, 05, 35, 25,'PMSRRFSH' ,,,,{|| TmsA145Rfs()}			,oBar,STR0010+" - <F5>"      ,,.F.,.F. ) //"Refresh - <F5>"
			TBtnBmp2():New( 00, 05, 35, 25,'SVM'      ,,,,{|| TmsA145Leg(1)}			,oBar,STR0006+" - <F6>"      ,,.F.,.F. ) //"Legenda - <F6>"
			TBtnBmp2():New( 00, 05, 35, 25,'CARGA'    ,,,,{|| TmsA145Nvg()}			,oBar,STR0007+" - <F7>"      ,,.F.,.F. ) //"Nova Viagem - <F7>"
			TBtnBmp2():New( 00, 05, 35, 25,'INSTRUME' ,,,,{|| TmsA145Mnt()}			,oBar,STR0008+" - <F8>"      ,,.F.,.F. ) //"Manutenção - <F8>"
			TBtnBmp2():New( 00, 05, 35, 25,'S4WB013N' ,,,,{|| TmsA145Grf()}			,oBar,STR0009+" - <F9>"      ,,.F.,.F. ) //"Gráfico - <F9>"	
			TBtnBmp2():New( 00, 05, 35, 25,'IMPRESSAO',,,,{|| TmsA145Prt()}			,oBar,STR0076+" - <Ctrl + P>",,.F.,.F. ) //"Imprimir - <Ctrl + P>" 
			If lRastre
				TBtnBmp2():New( 00, 05, 35, 25,'PIN'  ,,,,{|| TmsA145Pos(				aDadosVei[oLbVei:nAt,PV_CODVEI],;
																						aDadosVei[oLbVei:nAt,PV_FILORI],;
																						aDadosVei[oLbVei:nAt,PV_VIAGEM])};
																						,oBar,STR0085 ,,.F.,.F. ) //"Posicionamento " 
			EndIf
			TBtnBmp2():New( 00, 05, 35, 25,'CANCEL'   ,,,,{|| oDlgPnl:End()}			,oBar,STR0011+" - <Ctrl + X>",,.F.,.F. ) //"Fechar - <Ctrl + X>"
		EndIf
	
	EndIf
	
	oLbVei:SetArray(aDadosVei)
	
	If lTercRbq
		oLbVei:bLine := {|| {	Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='1',oVerde,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='2',oAmarelo,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='3',oAzul,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='4',oLaranja,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='5',oVermelho,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='9',oPreto,oBranco)))))),;
									aDadosVei[oLbVei:nAt,PV_CODVEI],;
									aDadosVei[oLbVei:nAt,PV_PLACA ],;
									aDadosVei[oLbVei:nAt,PV_TIPVEI],;
									aDadosVei[oLbVei:nAt,PV_FROTA ],;
									aDadosVei[oLbVei:nAt,PV_NOMMOT],;
									aDadosVei[oLbVei:nAt,PV_FILBAS],;
									aDadosVei[oLbVei:nAt,PV_FILORI],;
									aDadosVei[oLbVei:nAt,PV_VIAGEM],;
									aDadosVei[oLbVei:nAt,PV_DESROT],;
									aDadosVei[oLbVei:nAt,PV_DESSVT],;
									aDadosVei[oLbVei:nAt,PV_DESTPT],;
									aDadosVei[oLbVei:nAt,PV_DATGER],;
									aDadosVei[oLbVei:nAt,PV_PRVTER],;
									aDadosVei[oLbVei:nAt,PV_CODRB1],;
									aDadosVei[oLbVei:nAt,PV_PLARB1],;
									aDadosVei[oLbVei:nAt,PV_CODRB2],;
									aDadosVei[oLbVei:nAt,PV_PLARB2],;
									aDadosVei[oLbVei:nAt,PV_CODRB3],;
									aDadosVei[oLbVei:nAt,PV_PLARB3],;
									aDadosVei[oLbVei:nAt,PV_DATPOS],;
									aDadosVei[oLbVei:nAt,PV_HORPOS],;
									aDadosVei[oLbVei:nAt,PV_POSICI]}}
	
	ElseIf lRastre
		oLbVei:bLine := {|| {	Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='1',oVerde,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='2',oAmarelo,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='3',oAzul,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='4',oLaranja,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='5',oVermelho,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='9',oPreto,oBranco)))))),;
									aDadosVei[oLbVei:nAt,PV_CODVEI],;
									aDadosVei[oLbVei:nAt,PV_PLACA ],;
									aDadosVei[oLbVei:nAt,PV_TIPVEI],;
									aDadosVei[oLbVei:nAt,PV_FROTA ],;
									aDadosVei[oLbVei:nAt,PV_NOMMOT],;
									aDadosVei[oLbVei:nAt,PV_FILBAS],;
									aDadosVei[oLbVei:nAt,PV_FILORI],;
									aDadosVei[oLbVei:nAt,PV_VIAGEM],;
									aDadosVei[oLbVei:nAt,PV_DESROT],;
									aDadosVei[oLbVei:nAt,PV_DESSVT],;
									aDadosVei[oLbVei:nAt,PV_DESTPT],;
									aDadosVei[oLbVei:nAt,PV_DATGER],;
									aDadosVei[oLbVei:nAt,PV_PRVTER],;
									aDadosVei[oLbVei:nAt,PV_CODRB1],;
									aDadosVei[oLbVei:nAt,PV_PLARB1],;
									aDadosVei[oLbVei:nAt,PV_CODRB2],;
									aDadosVei[oLbVei:nAt,PV_PLARB2],;
									aDadosVei[oLbVei:nAt,PV_DATPOS],;
									aDadosVei[oLbVei:nAt,PV_HORPOS],;
									aDadosVei[oLbVei:nAt,PV_POSICI]}}
	Else
		oLbVei:bLine := {|| {	Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='1',oVerde,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='2',oAmarelo,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='3',oAzul,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='4',oLaranja,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='5',oVermelho,;
								Iif(aDadosVei[oLbVei:nAt,PV_STAVGE]=='9',oPreto,oBranco)))))),;
									aDadosVei[oLbVei:nAt,PV_CODVEI],;
									aDadosVei[oLbVei:nAt,PV_PLACA ],;
									aDadosVei[oLbVei:nAt,PV_TIPVEI],;
									aDadosVei[oLbVei:nAt,PV_FROTA ],;
									aDadosVei[oLbVei:nAt,PV_NOMMOT],;
									aDadosVei[oLbVei:nAt,PV_FILBAS],;
									aDadosVei[oLbVei:nAt,PV_FILORI],;
									aDadosVei[oLbVei:nAt,PV_VIAGEM],;
									aDadosVei[oLbVei:nAt,PV_DESROT],;
									aDadosVei[oLbVei:nAt,PV_DESSVT],;
									aDadosVei[oLbVei:nAt,PV_DESTPT],;
									aDadosVei[oLbVei:nAt,PV_DATGER],;
									aDadosVei[oLbVei:nAt,PV_PRVTER],;
									aDadosVei[oLbVei:nAt,PV_CODRB1],;
									aDadosVei[oLbVei:nAt,PV_PLARB1],;
									aDadosVei[oLbVei:nAt,PV_CODRB2],;
									aDadosVei[oLbVei:nAt,PV_PLARB2]}}
									
	EndIf
	
	
	If Len(aHeaderDoc) == 0
		AAdd( aHeaderDoc,' ' )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_FILDOC' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_DOC'    , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_SERIE'  , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_DATEMI' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_CLIREM' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_LOJREM' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_NOMREM' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DVA_REGORI' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_CLIDES' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_LOJDES' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DT6_NOMDES' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DVA_REGDES' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTQ_VIAGEM' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTQ_ROTA  ' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTQ_SERTMS' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTQ_TIPTRA' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTQ_DATGER' , 'X3Titulo()') )
		AAdd( aHeaderDoc,STR0002 ) //"Prev. Termino"
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DTR_CODVEI' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DA3_PLACA'  , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DA3_TIPVEI' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DA3_FROVEI' , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DA4_NOME'   , 'X3Titulo()') )
		AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DA3_FILBAS' , 'X3Titulo()') )
		If lRastre
			AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DAV_DATPOS' , 'X3Titulo()') )
			AAdd( aHeaderDoc,Posicione('SX3' ,2 ,'DAV_HORPOS' , 'X3Titulo()') )
			AAdd( aHeaderDoc,Posicione('SX3', 2 ,'DAV_POSICI' , 'X3Titulo()') )
		EndIf
	
		If lRastre
			@ 0, 0 LISTBOX oLbDoc VAR cLbox FIELDS HEADER aHeaderDoc[01],aHeaderDoc[02],aHeaderDoc[03],aHeaderDoc[04],;
			aHeaderDoc[05],aHeaderDoc[06],aHeaderDoc[07],aHeaderDoc[08],aHeaderDoc[09],aHeaderDoc[10],aHeaderDoc[11],aHeaderDoc[12],;
			aHeaderDoc[13],aHeaderDoc[14],aHeaderDoc[15],aHeaderDoc[16],aHeaderDoc[17],aHeaderDoc[18],aHeaderDoc[19],aHeaderDoc[20],;
			aHeaderDoc[21],aHeaderDoc[22],aHeaderDoc[23],aHeaderDoc[24],aHeaderDoc[25],aHeaderDoc[26],aHeaderDoc[27],aHeaderDoc[28] ;
			SIZE oSize:GetDimension("LISTBOX","COLEND")-1, 370 OF oExibDoc PIXEL
	
		Else
			@ 0, 0 LISTBOX oLbDoc VAR cLbox FIELDS HEADER aHeaderDoc[01],aHeaderDoc[02],aHeaderDoc[03],aHeaderDoc[04],;
			aHeaderDoc[05],aHeaderDoc[06],aHeaderDoc[07],aHeaderDoc[08],aHeaderDoc[09],aHeaderDoc[10],aHeaderDoc[11],aHeaderDoc[12],;
			aHeaderDoc[13],aHeaderDoc[14],aHeaderDoc[15],aHeaderDoc[16],aHeaderDoc[17],aHeaderDoc[18],aHeaderDoc[19],aHeaderDoc[20],;
			aHeaderDoc[21],aHeaderDoc[22],aHeaderDoc[23],aHeaderDoc[24],aHeaderDoc[25];
			SIZE oSize:GetDimension("LISTBOX","COLEND")-1, 370 OF oExibDoc PIXEL
		Endif
	
		oLbDoc:Align := CONTROL_ALIGN_ALLCLIENT
	
		//-- Acoes Por Documento
		If nPnl	== 2
			TBtnBmp2():New( 00, 05, 35, 25,'PESQUISA' ,,,,{|| TmsA145Psq(2,aDadosDoc)},oBar,STR0005+" - <F4>"      ,,.F.,.F. ) //"Pesquisa - <F4>"
			TBtnBmp2():New( 00, 05, 35, 25,'PMSRRFSH' ,,,,{|| TmsA145Rfs()}			,oBar,STR0010+" - <F5>"      ,,.F.,.F. ) //"Refresh - <F5>"
			TBtnBmp2():New( 00, 05, 35, 25,'SVM'      ,,,,{|| TmsA145Leg(2)}			,oBar,STR0006+" - <F6>"      ,,.F.,.F. ) //"Legenda - <F6>"
			TBtnBmp2():New( 00, 05, 35, 25,'PEDIDO'   ,,,,{|| TmsA145CEn()}			,oBar,STR0012+" - <F7>"      ,,.F.,.F. ) //"Comprovante de Entrega - <F7>"
			TBtnBmp2():New( 00, 05, 35, 25,'VERNOTA'  ,,,,{|| TmsA145VDc(				aDadosDoc[oLbDoc:nAt,PD_FILDOC],;
																						aDadosDoc[oLbDoc:nAt,PD_DOC   ],;
																						aDadosDoc[oLbDoc:nAt,PD_SERIE ],;
																						aDadosDoc[oLbDoc:nAt,PD_SERTMS])};
																						,oBar,STR0013+" - <F8>"      ,,.F.,.F. ) //"Visualizar Documento - <F8>"
			TBtnBmp2():New( 00, 05, 35, 25,'IMPRESSAO',,,,{|| TmsA145Prt()}			,oBar,STR0076+" - <Ctrl + P>",,.F.,.F. ) //"Imprimir - <Ctrl + P>"
			If lRastre
				TBtnBmp2():New( 00, 05, 35, 25,'PIN'  ,,,,{|| TmsA145Pos(				aDadosDoc[oLbDoc:nAt,PD_CODVEI],,;
																						aDadosDoc[oLbDoc:nAt,PD_VIAGEM])};
																						,oBar,STR0085,,.F.,.F. ) //"Posicionamento dos veículos " 
			EndIf
			TBtnBmp2():New( 00, 05, 35, 25,'CANCEL'   ,,,,{|| oDlgPnl:End()}			,oBar,STR0011+" - <Ctrl + X>",,.F.,.F. ) //"Fechar - <Ctrl + X>" 
		EndIf
	
	EndIf
	
	oLbDoc:SetArray(aDadosDoc)
	
	If lRastre
		oLbDoc:bLine := {|| {	Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='1',oVerde,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='2',oVermelho,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='3',oAmarelo,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='4',oLaranja,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='5',oAzul,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='6',oCinza,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='7',oPreto,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='8',oPink,oBranco)))))))),;
									aDadosDoc[oLbDoc:nAt,PD_FILDOC],;
									aDadosDoc[oLbDoc:nAt,PD_DOC   ],;
									aDadosDoc[oLbDoc:nAt,PD_SERIE ],;
									aDadosDoc[oLbDoc:nAt,PD_DATEMI],;
									aDadosDoc[oLbDoc:nAt,PD_CLIREM],;
									aDadosDoc[oLbDoc:nAt,PD_LOJREM],;
									aDadosDoc[oLbDoc:nAt,PD_NOMREM],;
									aDadosDoc[oLbDoc:nAt,PD_REGORI],;
									aDadosDoc[oLbDoc:nAt,PD_CLIDES],;
									aDadosDoc[oLbDoc:nAt,PD_LOJDES],;
									aDadosDoc[oLbDoc:nAt,PD_NOMDES],;
									aDadosDoc[oLbDoc:nAt,PD_REGDES],;
									aDadosDoc[oLbDoc:nAt,PD_VIAGEM],;
									aDadosDoc[oLbDoc:nAt,PD_DESROT],;
									aDadosDoc[oLbDoc:nAt,PD_DESSVT],;
									aDadosDoc[oLbDoc:nAt,PD_DESTPT],;
									aDadosDoc[oLbDoc:nAt,PD_DATGER],;
									aDadosDoc[oLbDoc:nAt,PD_PRVTER],;
									aDadosDoc[oLbDoc:nAt,PD_CODVEI],;
									aDadosDoc[oLbDoc:nAt,PD_PLACA ],;
									aDadosDoc[oLbDoc:nAt,PD_TIPVEI],;
									aDadosDoc[oLbDoc:nAt,PD_FROTA ],;
									aDadosDoc[oLbDoc:nAt,PD_NOMMOT],;
									aDadosDoc[oLbDoc:nAt,PD_FILBAS],;
									aDadosDoc[oLbDoc:nAt,PD_DATPOS],;
									aDadosDoc[oLbDoc:nAt,PD_HORPOS],;
									aDadosDoc[oLbDoc:nAt,PD_POSICI]}}
	Else
	
		oLbDoc:bLine := {|| {	Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='1',oVerde,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='2',oVermelho,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='3',oAmarelo,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='4',oLaranja,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='5',oAzul,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='6',oCinza,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='7',oPreto,;
								Iif(aDadosDoc[oLbDoc:nAt,PD_STADOC]=='8',oPink,oBranco)))))))),;
									aDadosDoc[oLbDoc:nAt,PD_FILDOC],;
									aDadosDoc[oLbDoc:nAt,PD_DOC   ],;
									aDadosDoc[oLbDoc:nAt,PD_SERIE ],;
									aDadosDoc[oLbDoc:nAt,PD_DATEMI],;
									aDadosDoc[oLbDoc:nAt,PD_CLIREM],;
									aDadosDoc[oLbDoc:nAt,PD_LOJREM],;
									aDadosDoc[oLbDoc:nAt,PD_NOMREM],;
									aDadosDoc[oLbDoc:nAt,PD_REGORI],;
									aDadosDoc[oLbDoc:nAt,PD_CLIDES],;
									aDadosDoc[oLbDoc:nAt,PD_LOJDES],;
									aDadosDoc[oLbDoc:nAt,PD_NOMDES],;
									aDadosDoc[oLbDoc:nAt,PD_REGDES],;
									aDadosDoc[oLbDoc:nAt,PD_VIAGEM],;
									aDadosDoc[oLbDoc:nAt,PD_DESROT],;
									aDadosDoc[oLbDoc:nAt,PD_DESSVT],;
									aDadosDoc[oLbDoc:nAt,PD_DESTPT],;
									aDadosDoc[oLbDoc:nAt,PD_DATGER],;
									aDadosDoc[oLbDoc:nAt,PD_PRVTER],;
									aDadosDoc[oLbDoc:nAt,PD_CODVEI],;
									aDadosDoc[oLbDoc:nAt,PD_PLACA ],;
									aDadosDoc[oLbDoc:nAt,PD_TIPVEI],;
									aDadosDoc[oLbDoc:nAt,PD_FROTA ],;
									aDadosDoc[oLbDoc:nAt,PD_NOMMOT],;
									aDadosDoc[oLbDoc:nAt,PD_FILBAS]}}
	
	EndIf
	
	If nPnl == 1   //-- Por Veículo
		oDlgPnl:cCaption := STR0014 //"Painel de Gestão de Viagens - Por Veículos"
		If Type("oLbVei") == "O"
			oLbVei:Refresh()
			oExibDoc:Hide()
	
			TmsKeyOff(aSetKey)
			aSetKey := {}
	
			AAdd( aSetKey ,{ VK_F4, {|| TmsA145Psq(1,aDadosVei)} } )
			AAdd( aSetKey ,{ VK_F5, {|| TmsA145Rfs()           } } )
			AAdd( aSetKey ,{ VK_F6, {|| TmsA145Leg(1)          } } )
			AAdd( aSetKey ,{ VK_F7, {|| TmsA145Nvg()           } } )
			AAdd( aSetKey ,{ VK_F8, {|| TmsA145Mnt()           } } )
			AAdd( aSetKey ,{ VK_F9, {|| TmsA145Grf()           } } )
			AAdd( aSetKey ,{  16  , {|| TmsA145Prt()           } } )
			AAdd( aSetKey ,{  24  , {|| oDlgPnl:End()          } } )
	
			TmsKeyOn(aSetKey)
	
			oExibVei:Show()
	
		EndIf
	ElseIf nPnl == 2 //-- Por Documento
		oDlgPnl:cCaption := STR0015 //"Painel de Gestão de Viagens - Por Documentos"
		If Type("oLbDoc") == "O"
			oLbDoc:Refresh()
			oExibVei:Hide()
	
			TmsKeyOff(aSetKey)
			aSetKey := {}
	
			AAdd( aSetKey ,{ VK_F4, {|| TmsA145Psq(2,aDadosDoc)} } )
			AAdd( aSetKey ,{ VK_F5, {|| TmsA145Rfs()           } } )
			AAdd( aSetKey ,{ VK_F6, {|| TmsA145Leg(2)          } } )
			AAdd( aSetKey ,{ VK_F7, {|| TmsA145CEn()           } } )
			AAdd( aSetKey ,{ VK_F8, {|| TmsA145VDc(aDadosDoc[oLbDoc:nAt,PD_FILDOC],;
																aDadosDoc[oLbDoc:nAt,PD_DOC],;
																aDadosDoc[oLbDoc:nAt,PD_SERIE],;
																aDadosDoc[oLbDoc:nAt,PD_SERTMS] ) } } )
			AAdd( aSetKey ,{  16  , {|| TmsA145Prt()           } } )
			AAdd( aSetKey ,{  24  , {|| oDlgPnl:End()          } } )
	
			TmsKeyOn(aSetKey)
	
			oExibDoc:Show()
	
		EndIf
	EndIf
	
	//-- Refresh
	If Type("oTimer") != "O"
		oTimer:= TTimer():New(nTimeGV, { || TmsA145Rfs(.F.) }, oDlgPnl )
		If mv_par03 == 1 //-- Automatico
			oTimer:Activate()
		EndIf
	Else
		If mv_par03 == 1 //-- Automatico
			oTimer:Activate()
		Else
			oTimer:DeActivate()
		EndIf
	EndIf
	
	//-- Montagem do Rodapé
	
	TmsKeyOn(aSetKey)
	
	nQtdVge:= aDadosRod[1]
	nQtdVol:= aDadosRod[2]
	nPesTot:= aDadosRod[3]
	nValMer:= aDadosRod[4]
	
	tSay():New(005,005,{||STR0016},oRodape,,,,,,.T.,,,40,9) //"Qtde. Viagens:"
	tGet():New(003,043,{|u| Iif(PCount()>0,nQtdVge:=u,nQtdVge)},oRodape,25,9,,,,,,,,.T.,,,,,,,.T.,,,'nQtdVge')
	
	tSay():New(005,075,{||STR0017},oRodape,,,,,,.T.,,,40,9) //"Qtde. Volume:"
	tGet():New(003,110,{|u| Iif(PCount()>0,nQtdVol:=u,nQtdVol)},oRodape,45,9,PesqPict("DT6","DT6_PESO"),,,,,,,.T.,,,,,,,.T.,,,'nQtdVol')
	
	tSay():New(005,160,{||STR0018},oRodape,,,,,,.T.,,,40,9) //"Peso Total:"
	tGet():New(003,188,{|u| Iif(PCount()>0,nPesTot:=u,nPesTot)},oRodape,45,9,PesqPict("DT6","DT6_PESO"),,,,,,,.T.,,,,,,,.T.,,,'nPesTot')
	
	tSay():New(005,238,{||STR0019},oRodape,,,,,,.T.,,,40,9) //"Valor Merc:"
	tGet():New(003,267,{|u| Iif(PCount()>0,nValMer:=u,nValMer)},oRodape,45,9,PesqPict("DT6","DT6_VALMER"),,,,,,,.T.,,,,,,,.T.,,,'nValMer')
	
	If nPnl == 2
		nQtdDoc:= aDadosRod[5]
		tSay():New(005,317,{||STR0020},oRodape,,,,,,.T.,,,40,9) //"Doctos:"
		tGet():New(003,337,{|u| Iif(PCount()>0,nQtdDoc:=u,nQtdDoc)},oRodape,25,9,,,,,,,,.T.,,,,,,,.T.,,,'nQtdDoc')
	EndIf
	
	If lNewDlg
	
		ACTIVATE MSDIALOG oDlgPnl
	
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Qry³ Autor ³ Gustavo Almeida       ³ Data ³ 22/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de query SQL do Painel de Gestão de Viagens         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Qry(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpN1: Identifica o tipo de query a utilizar se igual a 1  ³±±
±±³          ³        utiliza de query de veículos ou se 2 utiliza de     ³±±
±±³          ³        query de documentos.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei e TmsA145Doc                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TmsA145Qry(nPnl)

Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aCbxFro   := RetSx3Box(Posicione('SX3',2,'DA3_FROVEI','X3CBox()'),,,1)
Local cHorFim   := ""
Local cCodMot   := ""
Local aViagens  := {}
Local aVgexDoc  := {}
Local aRegOriInf:= {}
Local cRegOriInf:= ""
Local aRegDesInf:= {}
Local cRegDesInf:= ""
Local nPosVge   := 0
Local nPosVei   := 0
Local nPosDoc   := 0
Local nCnt      := 0
Local lContVei  := GetMV('MV_CONTVEI',,.T.)
Local lRetPE    := .F.
Local aPosici   := {}
Local lRastre   := AliasInDic("DAV") .And. DAV->( FieldPos("DAV_HORPOS") ) > 0
Local cAtivRTP  := GetMv('MV_ATIVRTP',,'') //-- Atividade de Retorno do Porto
Local cAtivRDP  := GetMv('MV_ATIVRDP',,'') //-- Atividade de Saida para retirada do Reboque
Local lTM145FIL := ExistBlock("TM145FIL")
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

Private cSerTms := ""
Private cTipTra := ""

//-- Inicializa valores do rodape e Limpa valores já efetuados
aDadosVei := {}
aDadosDoc := {}
aDadosRod := Array(5)
Afill(aDadosRod,0)

If nPnl == 1 //-- Por Veículo

	//-- Considerar parametros e Considera veiculos sem alocacao .Ou. Nao considera parametros
	If ( mv_par04 == 1 .And. mv_par16 == 1 ) .Or. mv_par04 == 2

		//-- Veículos sem alocacoes
		cQuery := "SELECT DA3_COD, DA3_PLACA, DA3_TIPVEI, DA3_FROVEI, DA3_FILBAS, DA3_FILATU "
		cQuery += " FROM "+RetSqlName('DA3')+" DA3, "+RetSqlName('DUT')+" DUT "
		cQuery += " WHERE DA3_FILIAL = '"+xFilial('DA3')+"'"
		If !Empty(mv_par02) 
			cQuery += " AND DA3.DA3_COD = '"+mv_par02+"'" //-- Veículo Específico
		EndIf

		If mv_par04 == 1
			//-- Filial Base
			cQuery += " AND DA3.DA3_FILBAS BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
			If mv_par05 == 1 //-- Frota Própria
				cQuery += "AND DA3.DA3_FROVEI = '1' "
			ElseIf mv_par05 == 2 //-- Frota Terceiro
				cQuery += "AND DA3.DA3_FROVEI = '2' "
			ElseIf mv_par05 == 3  //-- Frota Agregado
				cQuery += "AND DA3.DA3_FROVEI = '3' "
			EndIf
		EndIf

		cQuery += " AND DA3_ATIVO = '1' "
		cQuery += " AND DA3.D_E_L_E_T_ = ' ' "
		cQuery += " AND DUT_FILIAL = '"+xFilial('DUT')+"' "
		cQuery += " AND DUT_TIPVEI = DA3_TIPVEI "
		cQuery += " AND DUT_CATVEI IN ( '1', '2', '5' ) " //-- 1=Comun;2=Cavalo;5=Utilitario
		cQuery += " AND DUT.D_E_L_E_T_ = ' ' "

		If lContVei
			cQuery += "AND EXISTS ( SELECT 1 FROM "+RetSqlName('DTU')+" DTU "
			cQuery += "             WHERE DTU.DTU_FILIAL  = '"+xFilial('DTU')+"'"
			cQuery += "               AND DTU.DTU_CODVEI  = DA3_COD"
			cQuery += "               AND DTU.DTU_STATUS IN ( '1', '2' )"
			cQuery += "               AND DTU.D_E_L_E_T_  = ' ' )"
		Else
			cQuery += "AND (NOT EXISTS ( SELECT 1 FROM "+RetSqlName('DTR')+" DTR, "+RetSqlName('DTQ')+" DTQ "
			cQuery += "             WHERE DTR_FILIAL = '"+xFilial('DTR')+"' "
			cQuery += "               AND DTR_CODVEI = DA3_COD "
			cQuery += "               AND DTR.D_E_L_E_T_ = ' ' "
			cQuery += "               AND DTQ_FILIAL = '"+xFilial('DTQ')+"' "
			cQuery += "               AND DTQ_FILORI = DTR_FILORI "
			cQuery += "               AND DTQ_VIAGEM = DTR_VIAGEM "
			cQuery += "               AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- 3=Encerrada;9=Cancelada
			cQuery += "               AND DTQ.D_E_L_E_T_ = ' ' ) "
			//-- Verificar se existe apontamento da operacao de retorno do porto - Viagem Fluvial.
			cQuery += "OR EXISTS ( SELECT 1 FROM "+RetSqlName('DTR')+" DTR, "+RetSqlName('DTQ')+" DTQ, "+RetSqlName('DTW')+" DTW "
			cQuery += "             WHERE DTR_FILIAL = '"+xFilial('DTR')+"' "
			cQuery += "               AND DTR_CODVEI = DA3_COD AND DA3_STATUS <> '3'"
			cQuery += "               AND DTR.D_E_L_E_T_ = ' ' "
			cQuery += "               AND DTQ_FILIAL = '"+xFilial('DTQ')+"' "
			cQuery += "               AND DTQ_FILORI = DTR_FILORI "
			cQuery += "               AND DTQ_VIAGEM = DTR_VIAGEM "
			cQuery += "               AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- 3=Encerrada;9=Cancelada
			cQuery += "               AND DTQ.D_E_L_E_T_ = ' ' "
			cQuery += "               AND DTW_FILIAL = '"+xFilial('DTW')+"' "
			cQuery += "               AND DTR_FILORI = DTW_FILORI "
			cQuery += "               AND DTR_VIAGEM = DTW_VIAGEM "
			cQuery += "               AND DTR_ITEM   = '01' " //-- 1o cavalo
			cQuery += "               AND DTW_ATIVID IN ('"+cAtivRTP+"','"+cAtivRDP+"') "
			cQuery += "               AND DTW_STATUS = '2' "
			cQuery += "               AND DTW.D_E_L_E_T_ = ' ' ) )"

			cQuery += " UNION "

			//-- Reboque 1 e 2
			cQuery += "SELECT DA3_COD, DA3_PLACA, DA3_TIPVEI, DA3_FROVEI, DA3_FILBAS, DA3_FILATU "
			cQuery += "  FROM "+RetSqlName('DA3')+" DA3, "+RetSqlName('DUT')+" DUT "
			cQuery += " WHERE DA3_FILIAL = '"+xFilial('DA3')+"' "
			If !Empty(mv_par02)
				cQuery += " AND DA3.DA3_COD = '"+mv_par02+"'"//-- Veículo Específico
			EndIf

			If mv_par04 == 1
				//-- Filial Base
				cQuery += " AND DA3.DA3_FILBAS BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
				If mv_par05 == 1 //--  Frota: Própria
					cQuery += "AND DA3.DA3_FROVEI = '1' "
				ElseIf mv_par05 == 2 //-- Frota Terceiro
					cQuery += "AND DA3.DA3_FROVEI = '2' "
				ElseIf mv_par05 == 3 //-- Frota Agregado
					cQuery += "AND DA3.DA3_FROVEI = '3' "
				EndIf
			EndIf
			cQuery += " AND DA3_ATIVO = '1' "
			cQuery += " AND DA3.D_E_L_E_T_ = ' ' "
			cQuery += " AND DUT_FILIAL = '"+xFilial('DUT')+"' "
			cQuery += " AND DUT_TIPVEI = DA3_TIPVEI "
			cQuery += " AND DUT_CATVEI IN ( '3', '4' ) " //-- 3=Carreta;4=Especial
			cQuery += " AND DUT.D_E_L_E_T_ = ' ' "
			cQuery += " AND NOT EXISTS ( SELECT 1 FROM "+RetSqlName('DTR')+" DTR, "+RetSqlName('DTQ')+" DTQ "
			cQuery += "                   WHERE DTR_FILIAL = '"+xFilial('DTR')+"' "
			cQuery += "                     AND DTR_CODRB2 = DA3_COD "
			cQuery += "                     AND DTR.D_E_L_E_T_ = ' ' "
			cQuery += "                     AND DTQ_FILIAL = '"+xFilial('DTQ')+"' "
			cQuery += "                     AND DTQ_FILORI = DTR_FILORI "
			cQuery += "                     AND DTQ_VIAGEM = DTR_VIAGEM "
			cQuery += "                     AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- 3=Encerrada;9=Cancelada
			cQuery += "                     AND DTQ.D_E_L_E_T_ = ' ' ) "
			cQuery += " AND NOT EXISTS ( SELECT 1 FROM "+RetSqlName('DTR')+" DTR, "+RetSqlName('DTQ')+" DTQ "
			cQuery += "                   WHERE DTR_FILIAL = '"+xFilial('DTR')+"' "
			cQuery += "                     AND DTR_CODRB1 = DA3_COD "
			cQuery += "                     AND DTR.D_E_L_E_T_ = ' ' "
			cQuery += "                     AND DTQ_FILIAL = '"+xFilial('DTQ')+"' "
			cQuery += "                     AND DTQ_FILORI = DTR_FILORI "
			cQuery += "                     AND DTQ_VIAGEM = DTR_VIAGEM "
			cQuery += "                     AND DTQ_STATUS NOT IN ( '3', '9' ) "
			cQuery += "                     AND DTQ.D_E_L_E_T_ = ' ' ) "
			If lTercRbq
				cQuery += " AND NOT EXISTS ( SELECT 1 FROM "+RetSqlName('DTR')+" DTR, "+RetSqlName('DTQ')+" DTQ "
				cQuery += "                   WHERE DTR_FILIAL = '"+xFilial('DTR')+"' "
				cQuery += "                     AND DTR_CODRB3 = DA3_COD "
				cQuery += "                     AND DTR.D_E_L_E_T_ = ' ' "
				cQuery += "                     AND DTQ_FILIAL = '"+xFilial('DTQ')+"' "
				cQuery += "                     AND DTQ_FILORI = DTR_FILORI "
				cQuery += "                     AND DTQ_VIAGEM = DTR_VIAGEM "
				cQuery += "                     AND DTQ_STATUS NOT IN ( '3', '9' ) "
				cQuery += "                     AND DTQ.D_E_L_E_T_ = ' ' ) "
			EndIf
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		While(cAliasQry)->(!Eof())
			If lTM145FIL
				lRetPE := ExecBlock("TM145FIL",.F.,.F.,{"1",cAliasQry})
				If ValType(lRetPE) == "L" .And. lReTpe == .F.
					(cAliasQry)->(dbSkip())
					Loop
				EndIf
			EndIf
			Aadd(aDadosVei,Array(nTamAVei))
			nPosVei := Len(aDadosVei)
			aDadosVei[nPosVei,PV_STAVGE] := ""
			aDadosVei[nPosVei,PV_CODVEI] := (cAliasQry)->DA3_COD
			aDadosVei[nPosVei,PV_PLACA ] := (cAliasQry)->DA3_PLACA
			aDadosVei[nPosVei,PV_TIPVEI] := Posicione('DUT',1,xFilial('DUT')+(cAliasQry)->DA3_TIPVEI,'DUT_DESCRI')
			aDadosVei[nPosVei,PV_FROTA ] := AllTrim( aCbxFro[ Ascan( aCbxFro, { |x| x[ 2 ] == (cAliasQry)->DA3_FROVEI } ), 3 ])
			aDadosVei[nPosVei,PV_NOMMOT] := ""
			aDadosVei[nPosVei,PV_FILBAS] := (cAliasQry)->DA3_FILBAS
			aDadosVei[nPosVei,PV_FILORI] := ""
			aDadosVei[nPosVei,PV_VIAGEM] := ""
			aDadosVei[nPosVei,PV_DESROT] := ""
			aDadosVei[nPosVei,PV_DESSVT] := ""
			aDadosVei[nPosVei,PV_DESTPT] := ""
			aDadosVei[nPosVei,PV_DATGER] := Ctod("")
			aDadosVei[nPosVei,PV_PRVTER] := ""
			aDadosVei[nPosVei,PV_CODRB1] := ""
			aDadosVei[nPosVei,PV_PLARB1] := ""
			aDadosVei[nPosVei,PV_CODRB2] := ""
			aDadosVei[nPosVei,PV_PLARB2] := ""
			aDadosVei[nPosVei,PV_SERTMS] := ""
			aDadosVei[nPosVei,PV_TIPTRA] := ""
			If lTercRbq
				aDadosVei[nPosVei,PV_CODRB3] := ""
				aDadosVei[nPosVei,PV_PLARB3] := ""
			EndIf
			If lRastre
				aDadosVei[nPosVei,PV_DATPOS] := ""
				aDadosVei[nPosVei,PV_HORPOS] := ""
				aDadosVei[nPosVei,PV_POSICI] := Space( TamSX3('DAV_POSICI')[1] )
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

EndIf

If mv_par04 == 1 //-- Considerar parâmetros
	If !Empty(mv_par11)
		//-- Região de Origem
		Aadd(aRegOriInf , { mv_par11 , 0 })
		TmsNivInf( mv_par11, @aRegOriInf )
		For nCnt:= 1 to Len(aRegOriInf)
			If nCnt == Len(aRegOriInf)
				cRegOriInf+= "'"+aRegOriInf[nCnt,1]+"'"
			Else
				cRegOriInf+= "'"+aRegOriInf[nCnt,1]+"', "
			EndIf
		Next nCnt
	EndIf
	//-- Região de Destino
	If !Empty(mv_par12)
		Aadd(aRegDesInf , { mv_par12 , 0 })
		TmsNivInf( mv_par12, @aRegDesInf )
		For nCnt:= 1 to Len(aRegDesInf)
			If nCnt == Len(aRegDesInf)
				cRegDesInf+= "'"+aRegDesInf[nCnt,1]+"'"
			Else
				cRegDesInf+= "'"+aRegDesInf[nCnt,1]+"', "
			EndIf
		Next nCnt
	EndIf
EndIf

If nPnl == 1   //-- Por Veiculo
	cQuery := " SELECT DA3_COD   , DA3_PLACA , DA3_FROVEI, DA3_STATUS, "
	cQuery += "        DA3_FILBAS, DA3_FILATU, DA3_TIPVEI, "
	cQuery += "        DTQ_STATUS, DTQ_FILORI, DTQ_VIAGEM, "
	cQuery += "        DTQ_ROTA  , DTQ_SERTMS, DTQ_TIPTRA, "
	cQuery += "        DTQ_DATGER, DTR_CODRB1, DTR_CODRB2, "
	If lTercRbq
		cQuery += "		DTR_CODRB3, "
	EndIf
	cQuery += "        DTR_DATFIM, DTR_HORFIM, DTR_VIAGEM, DTR_ITEM "
	//cQuery += " 		 DT6_QTDVOL, DT6_PESO  , DT6_VALMER  "
ElseIf nPnl == 2  //-- Por Documento
	cQuery := " SELECT DT6_STATUS, DT6_FILDOC, DT6_DOC   , DT6_SERIE , DT6_DATEMI,"
	cQuery += "        DT6_CLIREM, DT6_LOJREM, DT6_CDRORI, DT6_CLIDES, DT6_LOJDES,"
	cQuery += "        DT6_CDRDES, DT6_QTDVOL, DT6_PESO  , DT6_VALMER, DTQ_FILORI,"
	cQuery += "        DTQ_VIAGEM, DTQ_ROTA  , DTQ_SERTMS, DTQ_TIPTRA, DTQ_DATGER,"
	cQuery += "        DTR_DATFIM, DTR_HORFIM, DTR_ITEM,   DTQ_STATUS, DA3_COD   , "
	cQuery += "        DA3_PLACA , DA3_FROVEI, DA3_FILBAS, DA3_FILATU, DA3_TIPVEI, DA3_STATUS "
EndIf

cQuery += " FROM "+RetSqlName('DA3')+" DA3, "
cQuery += "      "+RetSqlName('DTR')+" DTR, "
cQuery += "      "+RetSqlName('DTQ')+" DTQ  "

If nPnl == 2  //-- Por Documento
	cQuery += "     ,"+RetSqlName('DUD')+" DUD, "
	cQuery += "      "+RetSqlName('DT6')+" DT6  "
EndIf

cQuery += "  WHERE DA3_FILIAL  = '"+xFilial('DA3')+"' "

If !Empty(mv_par02) //-- Específico Veículo
	cQuery += " AND DA3_COD = '" + mv_par02 + "' "
EndIf

If mv_par04 == 1 //-- Considera parâmetros
	//-- Filial Base
	cQuery += " AND DA3_FILBAS BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	If mv_par05 == 1     //-- Frota Própria
		cQuery += " AND DA3_FROVEI = '1' "
	ElseIf mv_par05 == 2 //-- Frota Terceiro
		cQuery += " AND DA3_FROVEI = '2' "
	ElseIf mv_par05 == 3 //-- Frota Agregados
		cQuery += " AND DA3_FROVEI = '3' "
	EndIf
	If mv_par06 == 2 //-- Em Filial
		cQuery += " AND DA3_STATUS IN ( '1', '2') "
	ElseIf mv_par06 == 3 //-- Em Viagem 
		cQuery += " AND DA3_STATUS = '3' "
	EndIf
EndIf

cQuery += " AND DA3.D_E_L_E_T_ = ' '"
cQuery += " AND DTR_FILIAL     = '"+xFilial('DTR')+"' "
cQuery += " AND DTR_CODVEI     = DA3_COD "
cQuery += " AND DTR.D_E_L_E_T_ = ' '"
cQuery += " AND DTQ_FILIAL     = '"+xFilial('DTQ')+"' "
cQuery += " AND DTQ_FILORI     = DTR_FILORI "
cQuery += " AND DTQ_VIAGEM     = DTR_VIAGEM "

If mv_par04 == 1 //-- Considera parâmetros
	If mv_par13 == 1 //-- Status da Viagem
		cQuery += " AND DTQ_STATUS = '1' " //-- Em Aberto
	ElseIf mv_par13 == 2
		cQuery += " AND DTQ_STATUS = '5' " //-- Fechada
	ElseIf mv_par13 == 3
		cQuery += " AND DTQ_STATUS = '2' " //-- Em Trânsito
	ElseIf mv_par13 == 4
		cQuery += " AND DTQ_STATUS = '4' " //-- Chegada em Filial
	Else
		cQuery += " AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- Não considerar Viagens Encerradas ou Canceladas
	EndIf

	If mv_par09 == "1" //-- Serviço de Transporte
		cQuery += " AND DTQ_SERTMS = '1' " //-- Coleta
	ElseIf mv_par09 == "2"
		cQuery += " AND DTQ_SERTMS = '2' " //-- Transporte
	ElseIf mv_par09 == "3"
		cQuery += " AND DTQ_SERTMS = '3' " //-- Entrega
	EndIf

	If mv_par10 == "1" //-- Tipo de Transporte
		cQuery += " AND DTQ_TIPTRA = '1' " //-- Rodoviario
	ElseIf mv_par10 == "2"
		cQuery += " AND DTQ_TIPTRA = '2' " //-- Aereo
	ElseIf mv_par10 == "3"
		cQuery += " AND DTQ_TIPTRA = '3' " //-- Fluvial
	ElseIf mv_par10 == "4"
		cQuery += " AND DTQ_TIPTRA = '4' " //-- Rodoviario Internacional
	EndIf

	//-- Data de Geração de Viagem
	cQuery += " AND DTQ_DATGER BETWEEN '" + Dtos(mv_par14) + "' AND '" + Dtos(mv_par15) + "' "

Else
	cQuery += "	AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- Não considerar Viagens Encerradas ou Canceladas

EndIf
cQuery += " AND DTQ.D_E_L_E_T_ = ' ' "

If nPnl == 2  //-- Por Documento
	cQuery += " AND DUD_FILIAL      = '"+xFilial('DUD')+"' "
	cQuery += " AND DUD_FILORI      = DTQ_FILORI"
	cQuery += " AND DUD_VIAGEM      = DTQ_VIAGEM"
	cQuery += " AND DUD.D_E_L_E_T_  = ' '"
	cQuery += " AND DT6_FILIAL      = '"+xFilial('DT6')+"' "
	cQuery += " AND DT6_FILDOC      = DUD_FILDOC"
	cQuery += " AND DT6_DOC         = DUD_DOC   "
	cQuery += " AND DT6_SERIE       = DUD_SERIE "

	// Tratamento de Região Origem e Destino
	If mv_par04 == 1 .And. !Empty(cRegOriInf) .And. At(Upper(cRegDesInf), 'ZZ') > 0
		If !Empty(cRegOriInf)
			cQuery += " AND DT6_CDRORI IN ( "+cRegOriInf+" )"
		EndIf
		If !Empty(cRegDesInf)
			cQuery += " AND DT6_CDRDES IN ( "+cRegDesInf+" )"
		EndIf
	EndIf
	cQuery += " AND DT6.D_E_L_E_T_  = ' ' "
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

TCSetField(cAliasQry,"DTQ_DATGER","D",TamSx3("DTQ_DATGER")[1],TamSx3("DTQ_DATGER")[2])
TCSetField(cAliasQry,"DTR_DATFIM","D",TamSx3("DTR_DATFIM")[1],TamSx3("DTR_DATFIM")[2])

If nPnl == 2
	TCSetField(cAliasQry,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
	TCSetField(cAliasQry,"DT6_DATEMI","D",TamSx3("DT6_DATEMI")[1],TamSx3("DT6_DATEMI")[2])
EndIf

While (cAliasQry)->(!Eof())

	cSerTms := (cAliasQry)->DTQ_SERTMS
	cTipTra := (cAliasQry)->DTQ_TIPTRA
	cCodMot := Posicione('DUP',1,xFilial('DUP')+(cAliasQry)->(DTQ_FILORI+DTQ_VIAGEM),'DUP_CODMOT')
	cHorFim := Transform((cAliasQry)->DTR_HORFIM,"@R 99:99")

	If lTM145FIL
		lRetPE := ExecBlock("TM145FIL",.F.,.F.,{"2",cAliasQry}) // Retorna veiculos em viagem	 																																																																	//JFSB
		If ValType(lRetPE) == "L" .And. lReTpe == .F.
			(cAliasQry)->(dbSkip())
			Loop
		EndIf
	EndIf

	If nPnl == 1 //-- Por Veiculo

		If (nPosVge:=Ascan(aVgexDoc,{ | e | e[1]+e[2] == (cAliasQry)->(DTQ_FILORI+DTQ_VIAGEM) })) == 0
			Aadd(aDadosVei,Array(nTamAVei))
			nPosVei := Len(aDadosVei)
			Aadd(aVgexDoc,{ (cAliasQry)->DTQ_FILORI, (cAliasQry)->DTQ_VIAGEM, nPosVei })
		Else
			nPosVei := aVgexDoc[nPosVge,3]
		EndIf
		aDadosVei[nPosVei,PV_STAVGE] := (cAliasQry)->DTQ_STATUS
		aDadosVei[nPosVei,PV_CODVEI] := (cAliasQry)->DA3_COD
		aDadosVei[nPosVei,PV_PLACA ] := (cAliasQry)->DA3_PLACA
		aDadosVei[nPosVei,PV_TIPVEI] := Posicione('DUT',1,xFilial('DUT')+(cAliasQry)->DA3_TIPVEI,'DUT_DESCRI')
		aDadosVei[nPosVei,PV_FROTA ] := AllTrim( aCbxFro[ Ascan( aCbxFro, { |x| x[ 2 ] == (cAliasQry)->DA3_FROVEI } ), 3 ])
		aDadosVei[nPosVei,PV_NOMMOT] := Posicione('DA4',1,xFilial('DA4')+cCodMot,'DA4_NOME')
		aDadosVei[nPosVei,PV_FILBAS] := (cAliasQry)->DA3_FILBAS
		aDadosVei[nPosVei,PV_FILORI] := (cAliasQry)->DTQ_FILORI
		aDadosVei[nPosVei,PV_VIAGEM] := (cAliasQry)->DTQ_VIAGEM
		aDadosVei[nPosVei,PV_DESROT] := Posicione('DA8',1,xFilial('DA8')+(cAliasQry)->DTQ_ROTA,'DA8_DESC')
		aDadosVei[nPosVei,PV_DESSVT] := TMSValField('cSerTms',.F.)
		aDadosVei[nPosVei,PV_DESTPT] := TMSValField('cTipTra',.F.)
		aDadosVei[nPosVei,PV_DATGER] := (cAliasQry)->DTQ_DATGER
		aDadosVei[nPosVei,PV_PRVTER] := Dtoc((cAliasQry)->DTR_DATFIM)+" "+cHorFim
		aDadosVei[nPosVei,PV_CODRB1] := (cAliasQry)->DTR_CODRB1
		aDadosVei[nPosVei,PV_PLARB1] := Iif(!Empty((cAliasQry)->DTR_CODRB1),Posicione('DA3',1,xFilial('DA3')+(cAliasQry)->DTR_CODRB1,'DA3_PLACA'),'')
		aDadosVei[nPosVei,PV_CODRB2] := (cAliasQry)->DTR_CODRB2
		aDadosVei[nPosVei,PV_PLARB2] := Iif(!Empty((cAliasQry)->DTR_CODRB2),Posicione('DA3',1,xFilial('DA3')+(cAliasQry)->DTR_CODRB2,'DA3_PLACA'),'')
		aDadosVei[nPosVei,PV_SERTMS] := cSerTms
		aDadosVei[nPosVei,PV_TIPTRA] := cTipTra
		If lTercRbq
			aDadosVei[nPosVei,PV_CODRB3] := (cAliasQry)->DTR_CODRB3
			aDadosVei[nPosVei,PV_PLARB3] := Iif(!Empty((cAliasQry)->DTR_CODRB3),Posicione('DA3',1,xFilial('DA3')+(cAliasQry)->DTR_CODRB3,'DA3_PLACA'),'')
		EndIf 
		If !Empty(cAtivRTP) 
			//-- Se veiculo diferente de 3-Em Filial e Viagem 2-Em Transito e 1o cavalo.
			If (cAliasQry)->DA3_STATUS<>"3".And.(cAliasQry)->DTQ_STATUS=="2".And.(cAliasQry)->DTR_ITEM=="01"
				aDadosVei[nPosVei,PV_CODVEI] := ""
				aDadosVei[nPosVei,PV_PLACA ] := ""
				aDadosVei[nPosVei,PV_TIPVEI] := ""
				aDadosVei[nPosVei,PV_FROTA ] := ""
				aDadosVei[nPosVei,PV_NOMMOT] := ""
				aDadosVei[nPosVei,PV_FILBAS] := ""
			EndIf 
		EndIf
		If FindFunction('TmsPosAtu') .And. lRastre
			//-- Retorna um array contendo a data, hora e ultimo posicionamento
			aPosici := TmsPosAtu((cAliasQry)->DA3_COD,(cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM)
			aDadosVei[nPosVei, PV_DATPOS ] := aPosici[1]
			aDadosVei[nPosVei, PV_HORPOS ] := Transform(aPosici[2],PesqPict("DAV","DAV_HORPOS"))
			aDadosVei[nPosVei, PV_POSICI ] := Padr(aPosici[3],TamSX3('DAV_POSICI')[1])
		EndIf

		aDadosRod[1] += 1

	ElseIf nPnl == 2 // Por Documento

		Aadd(aDadosDoc,Array(nTamADoc))
		nPosDoc := Len(aDadosDoc)
		aDadosDoc[nPosDoc,PD_STADOC] := (cAliasQry)->DT6_STATUS
		aDadosDoc[nPosDoc,PD_FILDOC] := (cAliasQry)->DT6_FILDOC
		aDadosDoc[nPosDoc,PD_DOC   ] := (cAliasQry)->DT6_DOC
		aDadosDoc[nPosDoc,PD_SERIE ] := (cAliasQry)->DT6_SERIE
		aDadosDoc[nPosDoc,PD_DATEMI] := (cAliasQry)->DT6_DATEMI
		aDadosDoc[nPosDoc,PD_CLIREM] := (cAliasQry)->DT6_CLIREM
		aDadosDoc[nPosDoc,PD_LOJREM] := (cAliasQry)->DT6_LOJREM
		aDadosDoc[nPosDoc,PD_NOMREM] := Posicione('SA1',1,xFilial('SA1')+(cAliasQry)->(DT6_CLIREM+DT6_LOJREM),'A1_NOME')
		aDadosDoc[nPosDoc,PD_REGORI] := Posicione('DUY',1,xFilial('DUY')+(cAliasQry)->DT6_CDRORI,'DUY_DESCRI')
		aDadosDoc[nPosDoc,PD_CLIDES] := (cAliasQry)->DT6_CLIDES
		aDadosDoc[nPosDoc,PD_LOJDES] := (cAliasQry)->DT6_LOJDES
		aDadosDoc[nPosDoc,PD_NOMDES] := Posicione('SA1',1,xFilial('SA1')+(cAliasQry)->(DT6_CLIDES+DT6_LOJDES),'A1_NOME')
		aDadosDoc[nPosDoc,PD_REGDES] := Posicione('DUY',1,xFilial('DUY')+(cAliasQry)->DT6_CDRDES,'DUY_DESCRI')
		aDadosDoc[nPosDoc,PD_VIAGEM] := (cAliasQry)->DTQ_VIAGEM
		aDadosDoc[nPosDoc,PD_DESROT] := Posicione('DA8',1,xFilial('DA8')+(cAliasQry)->DTQ_ROTA,'DA8_DESC')
		aDadosDoc[nPosDoc,PD_DESSVT] := TMSValField('cSerTms',.F.)
		aDadosDoc[nPosDoc,PD_DESTPT] := TMSValField('cTipTra',.F.)
		aDadosDoc[nPosDoc,PD_DATGER] := (cAliasQry)->DTQ_DATGER
		aDadosDoc[nPosDoc,PD_PRVTER] := Dtoc((cAliasQry)->DTR_DATFIM)+" "+cHorFim
		aDadosDoc[nPosDoc,PD_CODVEI] := (cAliasQry)->DA3_COD
		aDadosDoc[nPosDoc,PD_PLACA ] := (cAliasQry)->DA3_PLACA
		aDadosDoc[nPosDoc,PD_TIPVEI] := Posicione('DUT',1,xFilial('DUT')+(cAliasQry)->DA3_TIPVEI,'DUT_DESCRI')
		aDadosDoc[nPosDoc,PD_FROTA ] := AllTrim( aCbxFro[ Ascan( aCbxFro, { |x| x[ 2 ] == (cAliasQry)->DA3_FROVEI } ), 3 ])
		aDadosDoc[nPosDoc,PD_NOMMOT] := Posicione('DA4',1,xFilial('DA4')+cCodMot,'DA4_NOME')
		aDadosDoc[nPosDoc,PD_FILBAS] := (cAliasQry)->DA3_FILBAS
		aDadosDoc[nPosDoc,PD_SERTMS] := cSerTms
		aDadosDoc[nPosDoc,PD_TIPTRA] := cTipTra
		//-- Se veiculo 3-Em Filial e Viagem 2-Em Transito e 1o cavalo.
		If (cAliasQry)->DA3_STATUS<>"3".And.(cAliasQry)->DTQ_STATUS=="2".And.(cAliasQry)->DTR_ITEM=="01"
			aDadosDoc[nPosDoc,PD_CODVEI] := ""
			aDadosDoc[nPosDoc,PD_PLACA ] := ""
			aDadosDoc[nPosDoc,PD_TIPVEI] := ""
			aDadosDoc[nPosDoc,PD_FROTA ] := ""
			aDadosDoc[nPosDoc,PD_NOMMOT] := ""
			aDadosDoc[nPosDoc,PD_FILBAS] := ""
		EndIf
		If FindFunction('TmsPosAtu') .And. lRastre
			//-- Retorna um array contendo a data, hora e ultimo posicionamento
			aPosici := TmsPosAtu(	(cAliasQry)->DA3_COD,    (cAliasQry)->DTQ_FILORI, (cAliasQry)->DTQ_VIAGEM,;
									(cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC,    (cAliasQry)->DT6_SERIE  )
			aDadosDoc[nPosDoc,PD_DATPOS ] := aPosici[1]
			aDadosDoc[nPosDoc,PD_HORPOS ] := Transform(aPosici[2],PesqPict("DAV","DAV_HORPOS"))
			aDadosDoc[nPosDoc,PD_POSICI ] := Padr(aPosici[3],TamSX3('DAV_POSICI')[1])
		EndIf

		//-- Rodapé
		If Ascan(aViagens,{ | e | e[1]+e[2] == (cAliasQry)->(DTQ_FILORI+DTQ_VIAGEM) }) == 0
			Aadd(aViagens,{ (cAliasQry)->DTQ_FILORI, (cAliasQry)->DTQ_VIAGEM })
			aDadosRod[1] += 1 //-- Qtd Viagens
		EndIf

		aDadosRod[2] += (cAliasQry)->DT6_QTDVOL
		aDadosRod[3] += (cAliasQry)->DT6_PESO
		aDadosRod[4] += (cAliasQry)->DT6_VALMER
		aDadosRod[5] += 1 //-- Qtd Docs.

	EndIf

	(cAliasQry)->(DbSkip())

EndDo

(cAliasQry)->(DbCloseArea())

//Impressao Rodape -- Por Veiculo
If nPnl == 1
	cQuery := " SELECT DT6_QTDVOL, DT6_PESO  , DT6_VALMER  "
	cQuery += "   FROM "+RetSqlName('DA3')+" DA3, "
	cQuery += "        "+RetSqlName('DTR')+" DTR, "
	cQuery += "        "+RetSqlName('DTQ')+" DTQ, "
	cQuery += "        "+RetSqlName('DUD')+" DUD, "
	cQuery += "        "+RetSqlName('DT6')+" DT6  "
	cQuery += "   WHERE DA3_FILIAL  = '"+xFilial('DA3')+"' "

	If !Empty(mv_par02) //-- Específico Veículo
		cQuery += " AND DA3_COD = '" + mv_par02 + "' "
	EndIf

	If mv_par04 == 1 //-- Considera parâmetros
		//-- Filial Base
		cQuery += " AND DA3_FILBAS BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
		If mv_par05 == 1     //-- Frota Própria
			cQuery += " AND DA3_FROVEI = '1' "
		ElseIf mv_par05 == 2 //-- Frota Terceiro
			cQuery += " AND DA3_FROVEI = '2' "
		ElseIf mv_par05 == 3 //-- Frota Agregados
			cQuery += " AND DA3_FROVEI = '3' "
		EndIf
		If mv_par06 == 2 //-- Em Filial
			cQuery += " AND DA3_STATUS IN ( '1', '2') "
		ElseIf mv_par06 == 3 //-- Em Viagem 
			cQuery += " AND DA3_STATUS = '3' "
		EndIf
	EndIf

	cQuery += " AND DA3.D_E_L_E_T_ = ' '"
	cQuery += " AND DTR_FILIAL     = '"+xFilial('DTR')+"' "
	cQuery += " AND DTR_CODVEI     = DA3_COD "
	cQuery += " AND DTR.D_E_L_E_T_ = ' '"
	cQuery += " AND DTQ_FILIAL     = '"+xFilial('DTQ')+"' "
	cQuery += " AND DTQ_FILORI     = DTR_FILORI "
	cQuery += " AND DTQ_VIAGEM     = DTR_VIAGEM "

	If mv_par04 == 1 //-- Considera parâmetros
		If mv_par13 == 1 //-- Status da Viagem
			cQuery += " AND DTQ_STATUS = '1' " //-- Em Aberto
		ElseIf mv_par13 == 2
			cQuery += " AND DTQ_STATUS = '5' " //-- Fechada
		ElseIf mv_par13 == 3
			cQuery += " AND DTQ_STATUS = '2' " //-- Em Trânsito
		ElseIf mv_par13 == 4
			cQuery += " AND DTQ_STATUS = '4' " //-- Chegada em Filial
		Else
			cQuery += " AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- Não considerar Viagens Encerradas ou Canceladas
		EndIf

		If mv_par09 == "1" //-- Serviço de Transporte
			cQuery += " AND DTQ_SERTMS = '1' " //-- Coleta
		ElseIf mv_par09 == "2"
			cQuery += " AND DTQ_SERTMS = '2' " //-- Transporte
		ElseIf mv_par09 == "3"
			cQuery += " AND DTQ_SERTMS = '3' " //-- Entrega
		EndIf

		If mv_par10 == "1" //-- Tipo de Transporte
			cQuery += " AND DTQ_TIPTRA = '1' " //-- Rodoviario
		ElseIf mv_par10 == "2"
			cQuery += " AND DTQ_TIPTRA = '2' " //-- Aereo
		ElseIf mv_par10 == "3"
			cQuery += " AND DTQ_TIPTRA = '3' " //-- Fluvial
		ElseIf mv_par10 == "4"
			cQuery += " AND DTQ_TIPTRA = '4' " //-- Rodoviario Internacional
		EndIf

		//-- Data de Geração de Viagem
		cQuery += " AND DTQ_DATGER BETWEEN '" + Dtos(mv_par14) + "' AND '" + Dtos(mv_par15) + "' "
	Else
		cQuery += " AND DTQ_STATUS NOT IN ( '3', '9' ) " //-- Não considerar Viagens Encerradas ou Canceladas

	EndIf
	cQuery += " AND DTQ.D_E_L_E_T_ = ' ' "
	cQuery += " AND DUD_FILIAL      = '"+xFilial('DUD')+"' "
	cQuery += " AND DUD_FILORI      = DTQ_FILORI"
	cQuery += " AND DUD_VIAGEM      = DTQ_VIAGEM"
	cQuery += " AND DUD.D_E_L_E_T_  = ' '"
	cQuery += " AND DT6_FILIAL      = '"+xFilial('DT6')+"' "
	cQuery += " AND DT6_FILDOC      = DUD_FILDOC"
	cQuery += " AND DT6_DOC         = DUD_DOC   "
	cQuery += " AND DT6_SERIE       = DUD_SERIE "
	cQuery += " AND DT6.D_E_L_E_T_  = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	TCSetField(cAliasQry,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])

	While (cAliasQry)->(!Eof())
		//aDadosRod[1] += 1	
		aDadosRod[2] += (cAliasQry)->DT6_QTDVOL
		aDadosRod[3] += (cAliasQry)->DT6_PESO
		aDadosRod[4] += (cAliasQry)->DT6_VALMER
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Leg³ Autor ³ Gustavo Almeida       ³ Data ³ 22/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de geração de legenda para a Painel de Gestão       ³±±
±±³          ³ de Viagens                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Leg(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpN1: Identifica o tipo de legenda a utilizar se igual a 1³±±
±±³          ³        utiliza legenda de veículos ou se 2 utiliza legenda ³±±
±±³          ³        de documentos.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei e TmsA145Doc                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Leg(cTipoLeg)

Local aLegVei, aLegDoc

aLegVei:={	{ "BR_VERDE"   ,STR0021 },; //"Em Aberto"
			{ "BR_VERMELHO",STR0022 },; //"Fechada"
			{ "BR_AMARELO" ,STR0023 },; //"Em Trânsito"
			{ "BR_LARANJA" ,STR0088 },; //"Chegada em Filial / Cliente"
			{ "BR_BRANCO"  ,STR0025 } } //"Veículo sem Viagem"

aLegDoc:={	{ "BR_VERDE"   ,STR0021 },; //"Em Aberto"
			{ "BR_VERMELHO",STR0026 },; //"Carregado / Indicado para Coleta"
			{ "BR_AMARELO" ,STR0023 },; //"Em Transito"
			{ "BR_LARANJA" ,STR0027 },; //"Chegada Parcial / Documento Informado"
			{ "BR_CINZA"   ,STR0028 },; //"Indicado p/ Entrega"
			{ "BR_PINK"    ,STR0029 } } //"Entrega Parcial"

If cTipoLeg == 1
	BrwLegenda(STR0030,STR0031, aLegVei ) //"Viagem" ### "Status"
ElseIf cTipoLeg == 2
	BrwLegenda(STR0032,STR0031, aLegDoc ) //"Documentos" ### "Status"
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Grf³ Autor ³ Gustavo Almeida       ³ Data ³ 22/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de geração de gráfico para a Painel de Gestão       ³±±
±±³          ³ de Viagens                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Grf(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpN1: Identifica o tipo de grafico a utilizar se igual a 1³±±
±±³          ³        utiliza "Tipo de Alocação" ou se 2 utiliza grafico  ³±±
±±³          ³        de "Tipo de veículos sem alocação".                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function TmsA145Grf(nTipGrf)

Local oGrafAlcVei := Nil
Local oGrafTip01  := Nil
Local lEnchBar    := .F.
Local lPadrao     := .F.
Local nMinY       := 400
Local aSize       := MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aItenSlc    := {}
Local aTipVeiGrf  := {}
Local nCnt        := 0
Local nCtrl       := 0
Local nS1         := 0
Local nS2         := 0
Local nS3         := 0
Local nS4         := 0
Local nSTot       := 0
Local cTitulod, oSlc, oBut, oCbox, cCbox

If nTipGrf == "1" //-- Tipo de Alocação 
	//-- Dados para o gráfico

	//-- Total de Veículos Alocados
	nSTot := Len(aDadosVei)
	
	For nCnt := 1 To nStot
		//-- Total em Coleta
		If aDadosVei[nCnt, PV_SERTMS] == "1"
			nS1 += 1
		//-- Total em Transportes
		ElseIf aDadosVei[nCnt, PV_SERTMS] == "2"
			nS2 += 1
		//-- Total em Entrega
		ElseIf aDadosVei[nCnt, PV_SERTMS] == "3"
			nS3 += 1
		//-- Total sem Alocação
		ElseIf aDadosVei[nCnt, PV_SERTMS] == ""
			nS4 += 1
		EndIf
	Next nCnt
	
	cTitulod := STR0033 //"Alocação de Veículos"
		
	If mv_par04 == 1
		cTitulod += STR0034 //" - [Conforme os parâmetros informados]"
	EndIf

	If (nStot-nS4) > 0
		DEFINE DIALOG oDlg TITLE cTitulod FROM aSize[7],aSize[2] TO aSize[4],aSize[3] PIXEL
	
		oGrafAlcVei:= FWLayer():New()
		oGrafAlcVei:init( oDlg, .F. )
	
		oGrafAlcVei:addCollumn( "AlcVei", 100, .F. )
		oGrafAlcVei:addWindow( "AlcVei","WinAlcVei",, 100, .F., .F., {|| oGrafTip01:Refresh() } )
	
		oGrafTip01:= FWChartFactory():New()
		oGrafTip01:= oGrafTip01:getInstance( PIECHART )
	
		oGrafTip01:init( oGrafAlcVei:getWinPanel( "AlcVei", "WinAlcVei" ) )
		oGrafTip01:setTitle( STR0035+CVALTOCHAR(nSTot-nS4), CONTROL_ALIGN_LEFT ) //"Total de Veículo(s):"
		oGrafTip01:setLegend( CONTROL_ALIGN_RIGHT )
		oGrafTip01:setMask( "*@* "+STR0081 ) //"Veículo(s)"  
		oGrafTip01:addSerie( STR0036 ,nS1  ) //"Alocados em Coleta"
		oGrafTip01:addSerie( STR0037 ,nS2  ) //"Alocados em Transporte"
		oGrafTip01:addSerie( STR0038 ,nS3  ) //"Alocados em Entrega"
		
		oGrafTip01:build()
	
		ACTIVATE DIALOG oDlg CENTERED
	Else
		MsgAlert(STR0082,STR0043) //"Não há veículos alocados" ### "ATENÇÃO"	
	EndIf
ElseIf nTipGrf == "2" // Tipo de veículos sem alocação

	For nCnt := 1 To Len(aDadosVei)
		If nCnt == 1 .And. aDadosVei[nCnt, PV_STAVGE] == "" .And. !Empty(aDadosVei[nCnt, PV_CODVEI])
			Aadd(aTipVeiGrf,{aDadosVei[nCnt, PV_TIPVEI], 1})
			nSTot += 1
			nCtrl += 1
		ElseIf aDadosVei[nCnt, PV_STAVGE] == "" .And. !Empty(aDadosVei[nCnt, PV_CODVEI])
			If aDadosVei[nCnt, PV_TIPVEI] == aDadosVei[nCnt-1, PV_TIPVEI]
				aTipVeiGrf[nCtrl, 2] += 1
				nSTot += 1
			Else
				Aadd(aTipVeiGrf,{aDadosVei[nCnt, PV_TIPVEI], 1})
				nSTot += 1
				nCtrl += 1
			EndIf
		EndIf
	Next nCnt

	cTitulod := STR0039 //"Veículos sem Alocação"
		
	If mv_par04 == 1
		cTitulod += STR0034 //" - [Conforme os parâmetros informados]"
	EndIf

	If nSTot > 0
		DEFINE DIALOG oDlg TITLE cTitulod FROM aSize[7],aSize[2] TO aSize[4],aSize[3] PIXEL
	
		oGrafAlcVei:= FWLayer():New()
		oGrafAlcVei:init( oDlg, .F. )
	
		oGrafAlcVei:addCollumn( "AlcVei", 100, .F. )
		oGrafAlcVei:addWindow( "AlcVei","WinAlcVei",, 100, .F., .F., {|| oGrafTip01:Refresh() } )
	
		oGrafTip01:= FWChartFactory():New()
		oGrafTip01:= oGrafTip01:getInstance( PIECHART )
	
		oGrafTip01:init( oGrafAlcVei:getWinPanel( "AlcVei", "WinAlcVei" ) )
		oGrafTip01:setTitle( STR0035+CVALTOCHAR(nSTot), CONTROL_ALIGN_LEFT ) //"Total de Veículo(s):"
		oGrafTip01:setLegend( CONTROL_ALIGN_RIGHT )
		oGrafTip01:setMask( "*@* "+STR0081 ) //"Veículo(s)" 
	
		For nCnt := 1 To Len(aTipVeiGrf)
		                    //--    Tipo Vei.           Qtds                       
			oGrafTip01:addSerie( aTipVeiGrf[nCnt, 1], aTipVeiGrf[nCnt, 2] )
		
		Next nCnt
	
		oGrafTip01:build()

		ACTIVATE DIALOG oDlg CENTERED
	Else
		MsgAlert(STR0083,STR0043) //"Não há veículos sem alocação" ### "ATENÇÃO"		
	EndIf

Else // Seleção de Gráfico
	If Empty(mv_par02)
		aItenSlc := {"1="+STR0033,"2="+STR0039} //"Alocação de Veículos" ### "Veículos sem Alocação"
		cCbox    := aItenSlc[1]

		DEFINE MSDIALOG oSlc FROM 0,0 TO 100,250 PIXEL TITLE STR0040 //"Tipo de Gráfico"

		oCbox:= tComboBox():New(10,15,{|u|if(PCount()>0,cCbox:=u,cCbox)},aItenSlc,100,20,oSlc,,{ || },,,,.T.,,,,,,,,,'cCbox')
		oBut := tButton():New(35,80,STR0041,oSlc,{ || TmsA145Grf( cCbox ), oSlc:End() },30,10,,,,.T.) //"Ok"

		ACTIVATE MSDIALOG oSlc CENTERED
	Else
		MsgAlert(STR0042,STR0043) //"Opção não disponível para parâmetros informados" ### "ATENÇÃO"
	EndIf

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145VDc³ Autor ³ Gustavo Almeida       ³ Data ³ 11/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualização do Documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145VDc(ExpC1,ExpC2,ExpC3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpC1: Filial do Documento                                 ³±±
±±³          ³ ExpC2: Documento                                           ³±±
±±³          ³ ExpC3: Serie                                               ³±±
±±³          ³ ExpC4: Serviço TMS                                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Doc                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145VDc()

Local aAreaAnt := GetArea()
Local aAreaDT6 := DT6->(GetArea())
Local aKeyAnt  := AClone(aSetKey)

Private cCadastro := STR0044 //"Manutencao de Documentos"
Private aRotina   := {	{'','', 0, 1,0,.F. },;	//'Pesquisar'
						{'','', 0, 2,0,NIL } }	//'Visualizar'
INCLUI := .F.
ALTERA := .F.

TmsKeyOff(aSetKey)

dbSelectArea('DT6')
dbSetOrder(1)
If aDadosDoc[oLbDoc:nAt,PD_SERTMS] <> '1' //-- Coleta
	If	DT6->(MsSeek(xFilial('DT6') + aDadosDoc[oLbDoc:nAt,PD_FILDOC] + aDadosDoc[oLbDoc:nAt,PD_DOC] + aDadosDoc[oLbDoc:nAt,PD_SERIE]))
		TmsA500Mnt('DT6',Recno(),2)
	EndIf
Else
	//-- Posiciona na solicitacao de coleta.
	dbSelectArea('DT5')
	dbSetOrder(4)
	If	DT5->(MsSeek(xFilial('DT5') + aDadosDoc[oLbDoc:nAt,PD_FILDOC] + aDadosDoc[oLbDoc:nAt,PD_DOC] + aDadosDoc[oLbDoc:nAt,PD_SERIE], .F. ) )
		TmsA460Mnt('DT5',DT5->(Recno()),2)
	EndIf
EndIf

aSetKey := aKeyAnt
TmsKeyOn(aSetKey)

RestArea( aAreaDT6 )
RestArea( aAreaAnt )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145CEn³ Autor ³ Gustavo Almeida       ³ Data ³ 13/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Comprovante de Entrega                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145CEn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Doc                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145CEn()

Local   aKeyAnt   := AClone(aSetKey)

TmsKeyOff(aSetKey)

TmsA570()

aSetKey := aKeyAnt
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Mnt³ Autor ³ Gustavo Almeida       ³ Data ³ 12/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutenção de Viagens                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Mnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Mnt()

Local aKeyAnt    := AClone(aSetKey)

TmsKeyOff(aSetKey)

If !Empty(aDadosVei[oLbVei:nAt,PV_VIAGEM])
	TmsA140(aDadosVei[oLbVei:nAt,PV_SERTMS],aDadosVei[oLbVei:nAt,PV_TIPTRA],,,;
			aDadosVei[oLbVei:nAt,PV_FILORI],aDadosVei[oLbVei:nAt,PV_VIAGEM])
Else
	Help('',1,'REGNOIS')
EndIf

aSetKey := aKeyAnt
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Rfs³ Autor ³ Gustavo Almeida       ³ Data ³ 18/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de refresh manual ou automático                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Rfs(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpL1: Informa se será exibido a tela de paramentos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei e TmsA145Doc                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Rfs(lParam)

Local cPerg := "TMSA145"

Default lParam := .T.

If lParam
	If Pergunte(cPerg,.T.)
		TmsA145Pnl(mv_par01)
	EndIf
Else
	Pergunte(cPerg,.F.)
	TmsA145Pnl(mv_par01)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Psq³ Autor ³ Gustavo Almeida       ³ Data ³ 03/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Psq(ExpN1,ExpA1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpN1: Identifica o tipo de pesquisa a utilizar se igual a ³±±
±±³          ³        1 utiliza pesquisa de veículos ou se 2 utiliza a    ³±±
±±³          ³        pesquisa de documentos.                             ³±±
±±³          ³ ExpA1: Identifica o Array de dados para pesquisa.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei e TmsA145Doc                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Psq(nTipoPesq,aDadosGen)

Local aCbx	 := {}
Local cCampo := ''
Local cData  := ''
Local cOrd
Local lSeek	:= .F.
Local nOrdem 	:= 1
Local nSeek	:= 0
Local oCbx, oDlg, oPsqGet
Local lTercRbq	:= DTR->(ColumnPos("DTR_CODRB3")) > 0

//-- Pesq. [Veículos]
If nTipoPesq == 1
	cCampo := AllTrim(Posicione('SX3', 2, 'DTR_CODVEI'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DA3_PLACA'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := STR0031 //"Status"
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTQ_FILORI'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DTQ_VIAGEM', 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTQ_DATGER'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTQ_ROTA  '	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTR_CODRB1'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := STR0003 //"Placa.1o.Reboq"
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTR_CODRB2'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := STR0004 //"Placa.2o.Reboq"
	Aadd( aCbx, cCampo )
	If lTercRbq
		cCampo := AllTrim(Posicione('SX3', 2, 'DTR_CODRB3'	, 'X3Titulo()'))
		Aadd( aCbx, cCampo )
		cCampo := STR0087 //"Placa.3o.Reboq"
	EndIf
	
	//-- Pesq. [Documentos]
ElseIf nTipoPesq == 2
	cCampo := AllTrim(Posicione('SX3', 2, 'DT6_FILDOC'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT6_DOC'   , 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT6_SERIE', 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DTQ_ROTA  '	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DT6_CLIREM'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT6_LOJREM', 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := STR0045 //"Nome Remetente"
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DVA_REGORI'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DT6_CLIDES'	, 'X3Titulo()')) + ' + ' + AllTrim(Posicione('SX3', 2, 'DT6_LOJDES', 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	cCampo := STR0046 //"Nome Destinatario"
	Aadd( aCbx, cCampo )
	cCampo := AllTrim(Posicione('SX3', 2, 'DVA_REGDES'	, 'X3Titulo()'))
	Aadd( aCbx, cCampo )
	
EndIf

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0005 //"Pesquisa"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	
	cCampo := AllTrim( cCampo )
	If nTipoPesq == 1
		If nOrdem == 1
			//-- Veiculo
			ASort( aDadosGen,,,{|x,y| x[ PV_CODVEI ] < y[ PV_CODVEI] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PV_CODVEI ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 2
			//-- Placa do Veículo
			ASort( aDadosGen,,,{|x,y| x[ PV_PLACA  ] < y[ PV_PLACA  ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PV_PLACA ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 3
			//-- Status
			ASort( aDadosGen,,,{|x,y| x[ PV_STAVGE ] < y[ PV_STAVGE ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PV_STAVGE ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 4
			//-- Fil. Origem + Viagem
			ASort( aDadosGen,,,{|x,y| x[ PV_FILORI ] + x[ PV_VIAGEM ] < y[ PV_FILORI ] + y[ PV_VIAGEM ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PV_FILORI ] + x[ PV_VIAGEM ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 5
			//-- Data de Geração
			ASort( aDadosGen,,,{|x,y| DtoS(x[ PV_DATGER ]) < DtoS(y[ PV_DATGER ]) } )
	
			cData := Left( cCampo, 6 )
			cData := DtoS( CtoD(Left(cData,2)+'/'+Subs(cData,3,2)+'/'+Right(cData,2)) )
			
			If Len( cCampo ) > 6
				cCampo := cData + Subs( cCampo, 7, Len( cCampo ) )
			Else
				cCampo := cData
			EndIf
			
			nSeek := Ascan( aDadosGen,{ | x | PadR( DtoS( x[ PV_DATGER ] ), Len( cCampo ) ) == cCampo  } )
			
		ElseIf nOrdem == 6
			//-- Rota
			ASort( aDadosGen,,,{|x,y| x[ PV_DESROT ] < y[ PV_DESROT ]  } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PV_DESROT ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 7
			//-- Cod.1o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_CODRB1  ] < y[ PV_CODRB1  ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_CODRB1 ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 8
			//-- Placa.1o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_PLARB1 ] < y[ PV_PLARB1 ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_PLARB1 ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 9
			//-- Cod.2o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_CODRB2  ] < y[ PV_CODRB2  ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_CODRB2 ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 10
			//-- Placa.2o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_PLARB2 ] < y[ PV_PLARB2 ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_PLARB2 ], Len( cCampo ) ) == cCampo } )
			
		ElseIf nOrdem == 11 .And. lTercRbq
			//-- Cod.3o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_CODRB3  ] < y[ PV_CODRB3  ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_CODRB3 ], Len( cCampo ) ) == cCampo } )
				
		ElseIf nOrdem == 12 .And. lTercRbq
			//-- Placa.3o.Reboq
			ASort( aDadosGen,,,{|x,y| x[ PV_PLARB3 ] < y[ PV_PLARB3 ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( x[ PV_PLARB3 ], Len( cCampo ) ) == cCampo } ) 
		EndIf
		
	ElseIf nTipoPesq == 2
		
		If nOrdem == 1
			//-- Fil.Doct + No. Docto. + Serie Docto. 
			ASort( aDadosGen,,,{|x,y| x[ PD_FILDOC ] + x[ PD_DOC ] + x[ PD_SERIE ] < y[ PD_FILDOC ] + y[ PD_DOC ] + y[ PD_SERIE ] } )
			nSeek := Ascan( aDadosGen,{ | x | PadR( (x[ PD_FILDOC ] + x[ PD_DOC ] + x[ PD_SERIE ]), Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 2
			//-- Rota
			ASort( aDadosGen,,,{|x,y| x[ PD_DESROT ] < y[ PD_DESROT ]  } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_DESROT ], Len( cCampo ) ) == cCampo } )
				
		ElseIf nOrdem == 3
			//-- Remetente + Loja Remet.
			ASort( aDadosGen,,,{|x,y| x[ PD_CLIREM ] + x[ PD_LOJREM ] < y[ PD_CLIREM ] + y[ PD_LOJREM ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_CLIREM ] + x[ PD_LOJREM ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 4
			//-- Nome Remetente
			ASort( aDadosGen,,,{|x,y| x[ PD_NOMREM ] < y[ PD_NOMREM ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_NOMREM ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 5
			//-- Reg. Origem
			ASort( aDadosGen,,,{|x,y| x[ PD_REGORI ] < y[ PD_REGORI ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_REGORI ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 6
			//-- Destinatário + Loja Dest.
			ASort( aDadosGen,,,{|x,y| x[ PD_CLIDES ] + x[ PD_LOJDES ] < y[ PD_CLIDES ] + y[ PD_LOJDES ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_CLIDES ] + x[ PD_LOJDES ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 7
			//-- Nome Destinatário
			ASort( aDadosGen,,,{|x,y| x[ PD_NOMDES ] < y[ PD_NOMDES ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_NOMDES ],Len(cCampo) ) == cCampo } )
			
		ElseIf nOrdem == 8
			//-- Reg. Destino
			ASort( aDadosGen,,,{|x,y| x[ PD_REGDES ] < y[ PD_REGDES ] } )
			nSeek := Ascan(aDadosGen,{ |x| PadR(x[ PD_REGDES ],Len(cCampo) ) == cCampo } )
			
		EndIf
		
	EndIf
	
EndIf

If mv_par01 == 1 .And. nSeek <> 0
	oLbVei:nAT := Ascan(aDadosGen,{ |x| PadR(x[ PD_FILDOC ] + x[ PD_DOC ] + x[ PD_SERIE ],Len(cCampo) ) == cCampo } ) //nSeek
	oLbVei:Refresh()
	oLbVei:SetFocus()
ElseIf mv_par01 == 2 .And. nSeek <> 0
	oLbDoc:nAT := nSeek
	oLbDoc:Refresh()
	oLbDoc:SetFocus()
ElseIf nSeek == 0 .And. lSeek == .T.
	Help('',1,'REGNOIS')
EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Nvg³ Autor ³ Gustavo Almeida       ³ Data ³ 04/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusão de nova viagem via painel de gestão de vaigens    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Nvg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Nvg()

Local cTitulo    := STR0007  //"Nova Viagem"
Local lValid     := .F.
Local cCpoDes    := ""
Local lConsF3    := .F.
Local lArray     := .T.
Local aItensSer  := TMSValField("SERTMS",lValid,cCpoDes,lConsF3,lArray)
Local aItensTra  := TMSValField("TIPTRA",lValid,cCpoDes,lConsF3,lArray)
Local cSerTms    := ""
Local cTipTra    := ""
Local cTipVgm    := ""
Local nOpcA      := 0
Local nCnt       := 0
Local aCbIteSer  := {}
Local aCbIteTra  := {}
Local aCbIteVgm  := { "1=Modelo 1", "2=Modelo 2" }
Local aKeyAnt    := AClone(aSetKey)
Local oDlgNvg, oButton, oCbNvgSer, oCbNvgTra, oCbNvgTip

TmsKeyOff(aSetKey)

For nCnt := 1 To Len(aItensSer)
	Aadd(aCbIteSer,aItensSer[nCnt,1]+"="+aItensSer[nCnt,2])
Next nCnt

For nCnt := 1 To Len(aItensTra)
	Aadd(aCbIteTra,aItensTra[nCnt,1]+"="+aItensTra[nCnt,2])
Next nCnt

DEFINE MSDIALOG oDlgNvg FROM 0,0 TO 200, 235 PIXEL TITLE cTitulo

tSay():New(04,10,{||STR0047},oDlgNvg,,,,,,.T.,,,80,10) //"Serviço de Transporte"
oCbNvgSer := tComboBox():New(13,10,{|u| Iif(PCount() > 0,cSerTms := u,cSerTms)},aCbIteSer,100,20,oDlgNvg,,,,,,.T.)

tSay():New(32,10,{||STR0048},oDlgNvg,,,,,,.T.,,,80,10) //"Tipo de Transporte"
oCbNvgTra := tComboBox():New(41,10,{|u| Iif(PCount() > 0,cTipTra := u,cTipTra)},aCbIteTra,100,20,oDlgNvg,,,,,,.T.)

tSay():New(59,10,{||STR0086},oDlgNvg,,,,,,.T.,,,80,10) //"Modelo Viagem"
oCbNvgTip := tComboBox():New(67,10,{|u| Iif(PCount() > 0,cTipVgm := u,cTipVgm)},aCbIteVgm,100,20,oDlgNvg,,,,,,.T.)

oButton:=tButton():New(87,90,STR0041,oDlgNvg,{||(nOpcA := 1,oDlgNvg:End())},20,10,,,,.T.) //"Ok"

ACTIVATE MSDIALOG oDlgNvg CENTERED

If nOpcA == 1
	If cSerTms == '1' //-- Coleta
		If cTipTra == '1' //-- Rodoviario
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA141A",,3)
					TMSA141A()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144A",,3)
					TMSA144A()
				EndIf
			EndIf
		ElseIf cTipTra == '2' //-- Aereo
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA141B",,3)
					TMSA141B()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144E",,3)
					TMSA144E()
				EndIf
			EndIf
		Else
			MsgAlert(STR0049+AllTrim(aItensSer[VAL(cSerTms),2]),STR0043) //"Opção não disponível para " ### "ATENÇÃO"
		EndIf
	ElseIf cSerTms == '2' //-- Transporte
		If cTipTra == '1' //-- Rodoviario
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA140A",,3)
					TMSA140A()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144B",,3)
					TMSA144B()
				EndIf
			EndIf
		ElseIf cTipTra == '2' //-- Aereo
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA140B",,3)
					TMSA140B()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144C",,3)
					TMSA144C()
				EndIf
			EndIf
		ElseIf cTipTra == '3' //-- Fluvial
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA140C",,3)
					TMSA140C()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144G",,3)
					TMSA144G()
				EndIf
			EndIf
		ElseIf cTipTra == '4' //-- Rodoviario Internacional
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA140D",,3)
					TMSA140D()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144I",,3)
					TMSA144I()
				EndIf
			EndIf
		Else
			MsgAlert(STR0049+AllTrim(aItensSer[VAL(cSerTms),2]),STR0043) //"Opção não disponível para " ### "ATENÇÃO"
		EndIf
	ElseIf cSerTms == '3' //-- Entrega
		If cTipTra == '1' //-- Rodoviário
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA141C",,3)
					TMSA141C()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144D",,3)
					TMSA144D()
				EndIf
			EndIf
		ElseIf cTipTra == '2' //-- Aereo
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA141D",,3)
					TMSA141D()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144F",,3)
					TMSA144F()
				EndIf
			EndIf
		ElseIf cTipTra == '3' //-- Fluvial
			If cTipVgm == '1' //-- Modelo 1
				If TmsAcesso(,"TMSA141E",,3)
					TMSA141E()
				EndIf
			ElseIf cTipVgm == '2' //-- Modelo 2
				If TmsAcesso(,"TMSA144H",,3)
					TMSA144H()
				EndIf
			EndIf
		Else
			MsgAlert(STR0049+AllTrim(aItensSer[VAL(cSerTms),2]),STR0043) //"Opção não disponível para " ### "ATENÇÃO"
		EndIf
	EndIf
EndIf

aSetKey := AClone(aKeyAnt)
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Prt³ Autor ³ Gustavo Almeida       ³ Data ³ 02/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprisão do painel de gestão de viagens                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Vei e TmsA145Doc                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function TmsA145Prt()
						
Local oRprt145

oRprt145:= Def145()
oRprt145:PrintDialog()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Def145   ³ Autor ³ Gustavo Almeida       ³ Data ³ 02/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definições do cabeçario para o TReport                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Def145()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Prt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Def145()

Local cTitulo := Iif(mv_par01 == 1,STR0014,STR0015) //"Painel de Gestão de Viagens - Por Veículos" ### "Painel de Gestão de Viagens - Por Documento"
Local oSecVeiCab,oSecVeiCabT,oSecDocCab,oSecDocCabT
Local oSecVeiItn,oSecVeiItnT,oSecDocItn,oSecDocItnT
Local oRprt145
Local aCampTam:= {}
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0
oRprt145 := TReport():New("TReport",cTitulo,/*cPerg*/,{|oRprt145| PrintReport(oRprt145,cTitulo) },STR0077) //"Este relatório irá imprimir o painel de acordo com os parâmetros informados pelo usuário."

If mv_par01 == 1 //-- Por Veiculos

	AAdd( aCampTam ,TAMSX3("DTQ_STATUS")                                        )//-- 1
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTR_CODVEI', 'X3Titulo()')),0,"C"})//-- 2  //-- Cód. Veículo
	AAdd( aCampTam ,TAMSX3("DA3_PLACA") 										          )//-- 3
	AAdd( aCampTam ,TAMSX3("DUT_DESCRI") 										          )//-- 4
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA3_FROVEI', 'X3Titulo()')),0,"C"})//-- 5  //-- Frota
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA4_NOME'  , 'X3Titulo()')),0,"C"})//-- 6  //-- Mototirsta
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA3_FILBAS', 'X3Titulo()')),0,"C"})//-- 7  //-- Fil. Base
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA3_FILORI', 'X3Titulo()')),0,"C"})//-- 8  //-- Fil. Origem
	AAdd( aCampTam ,TAMSX3("DTQ_VIAGEM") 										          )//-- 9
	AAdd( aCampTam ,TAMSX3("DA8_DESC")   										          )//-- 10
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_SERTMS', 'X3Titulo()')),0,"C"})//-- 11 //-- SERTMS
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_TIPTRA', 'X3Titulo()')),0,"C"})//-- 12 //-- TIPTMS
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_DATGER', 'X3Titulo()')),0,"C"})//-- 13 
	AAdd( aCampTam ,{19,0,"C"}           										          )//-- 14 //"Prev. Termino"
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTR_CODRB1', 'X3Titulo()')),0,"C"})//-- 15 Cod.1o Reboq
	AAdd( aCampTam ,TAMSX3("DA3_PLACA") 										          )//-- 16 //"Placa.1o.Reboq"
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTR_CODRB2', 'X3Titulo()')),0,"C"})//-- 17 Cod.2o Reboq
	AAdd( aCampTam ,TAMSX3("DA3_PLACA")	 										          )//-- 18 //"Placa.2o.Reboq"
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTR_CODRB3', 'X3Titulo()')),0,"C"})//-- 19 Cod.3o Reboq
	AAdd( aCampTam ,TAMSX3("DA3_PLACA")	 										          )//-- 20 //"Placa.3o.Reboq"

	oRprt145:SetTitle(STR0014)

	//Cabeçalho
	oSecVeiCab := TRSection():New(oRprt145,cTitulo,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) 
	TRCell():New(oSecVeiCab,"CAB_CODVEI","","",/*Picture*/,aCampTam[2,1] ,/*lPixel*/,{|| aHeaderVei[2]  })
	TRCell():New(oSecVeiCab,"CAB_PLACA" ,"","",/*Picture*/,aCampTam[3,1] ,/*lPixel*/,{|| aHeaderVei[3]  })
	TRCell():New(oSecVeiCab,"CAB_TIPVEI","","",/*Picture*/,aCampTam[4,1] ,/*lPixel*/,{|| aHeaderVei[4]  })
	TRCell():New(oSecVeiCab,"CAB_FROTA" ,"","",/*Picture*/,aCampTam[5,1] ,/*lPixel*/,{|| aHeaderVei[5]  })
	TRCell():New(oSecVeiCab,"CAB_NOMMOT","","",/*Picture*/,aCampTam[6,1] ,/*lPixel*/,{|| aHeaderVei[6]  })
	TRCell():New(oSecVeiCab,"CAB_FILBAS","","",/*Picture*/,aCampTam[7,1] ,/*lPixel*/,{|| aHeaderVei[7]  })
	TRCell():New(oSecVeiCab,"CAB_FILORI","","",/*Picture*/,aCampTam[8,1] ,/*lPixel*/,{|| aHeaderVei[8]  })
	TRCell():New(oSecVeiCab,"CAB_VIAGEM","","",/*Picture*/,aCampTam[9,1] ,/*lPixel*/,{|| aHeaderVei[9]  })
	TRCell():New(oSecVeiCab,"CAB_DESROT","","",/*Picture*/,aCampTam[10,1],/*lPixel*/,{|| aHeaderVei[10] })
	TRCell():New(oSecVeiCab,"CAB_DESSVT","","",/*Picture*/,aCampTam[11,1],/*lPixel*/,{|| aHeaderVei[11] })
	TRCell():New(oSecVeiCab,"CAB_DESTPT","","",/*Picture*/,aCampTam[12,1],/*lPixel*/,{|| aHeaderVei[12] })
	TRCell():New(oSecVeiCab,"CAB_DATGER","","",/*Picture*/,aCampTam[13,1],/*lPixel*/,{|| aHeaderVei[13] })
	TRCell():New(oSecVeiCab,"CAB_PRVTER","","",/*Picture*/,aCampTam[14,1],/*lPixel*/,{|| aHeaderVei[14] })
	TRCell():New(oSecVeiCab,"CAB_CODRB1","","",/*Picture*/,aCampTam[15,1],/*lPixel*/,{|| aHeaderVei[15] })
	TRCell():New(oSecVeiCab,"CAB_PLARB1","","",/*Picture*/,aCampTam[16,1],/*lPixel*/,{|| aHeaderVei[16] })
	TRCell():New(oSecVeiCab,"CAB_CODRB2","","",/*Picture*/,aCampTam[17,1],/*lPixel*/,{|| aHeaderVei[17] })
	TRCell():New(oSecVeiCab,"CAB_PLARB2","","",/*Picture*/,aCampTam[18,1],/*lPixel*/,{|| aHeaderVei[18] })
	If lTercRbq
		TRCell():New(oSecVeiCab,"CAB_CODRB3","","",/*Picture*/,aCampTam[19,1],/*lPixel*/,{|| aHeaderVei[19] })
		TRCell():New(oSecVeiCab,"CAB_PLARB3","","",/*Picture*/,aCampTam[20,1],/*lPixel*/,{|| aHeaderVei[20] })
	EndIf 

	//Itens
	oSecVeiItn:= TRSection():New(oSecVeiCab,STR0081,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)//"Veículos"
	TRCell():New(oSecVeiItn,"ITEM_CODVEI","","",/*Picture*/,aCampTam[2,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_CODVEI] })
	TRCell():New(oSecVeiItn,"ITEM_PLACA" ,"","",/*Picture*/,aCampTam[3,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_PLACA]  })
	TRCell():New(oSecVeiItn,"ITEM_TIPVEI","","",/*Picture*/,aCampTam[4,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_TIPVEI] })
	TRCell():New(oSecVeiItn,"ITEM_FROTA" ,"","",/*Picture*/,aCampTam[5,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_FROTA]  })
	TRCell():New(oSecVeiItn,"ITEM_NOMMOT","","",/*Picture*/,aCampTam[6,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_NOMMOT] })
	TRCell():New(oSecVeiItn,"ITEM_FILBAS","","",/*Picture*/,aCampTam[7,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_FILBAS] })
	TRCell():New(oSecVeiItn,"ITEM_FILORI","","",/*Picture*/,aCampTam[8,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_FILORI] })
	TRCell():New(oSecVeiItn,"ITEM_VIAGEM","","",/*Picture*/,aCampTam[9,1] ,/*lPixel*/,{|| aDadosVei[nI,PV_VIAGEM] })
	TRCell():New(oSecVeiItn,"ITEM_DESROT","","",/*Picture*/,aCampTam[10,1],/*lPixel*/,{|| aDadosVei[nI,PV_DESROT] })
	TRCell():New(oSecVeiItn,"ITEM_DESSVT","","",/*Picture*/,aCampTam[11,1],/*lPixel*/,{|| aDadosVei[nI,PV_DESSVT] })
	TRCell():New(oSecVeiItn,"ITEM_DESTPT","","",/*Picture*/,aCampTam[12,1],/*lPixel*/,{|| aDadosVei[nI,PV_DESTPT] })
	TRCell():New(oSecVeiItn,"ITEM_DATGER","","",/*Picture*/,aCampTam[13,1],/*lPixel*/,{|| aDadosVei[nI,PV_DATGER] })
	TRCell():New(oSecVeiItn,"ITEM_PRVTER","","",/*Picture*/,aCampTam[14,1],/*lPixel*/,{|| aDadosVei[nI,PV_PRVTER] })
	TRCell():New(oSecVeiItn,"ITEM_CODRB1","","",/*Picture*/,aCampTam[15,1],/*lPixel*/,{|| aDadosVei[nI,PV_CODRB1] })
	TRCell():New(oSecVeiItn,"ITEM_PLARB1","","",/*Picture*/,aCampTam[16,1],/*lPixel*/,{|| aDadosVei[nI,PV_PLARB1] })
	TRCell():New(oSecVeiItn,"ITEM_CODRB2","","",/*Picture*/,aCampTam[17,1],/*lPixel*/,{|| aDadosVei[nI,PV_CODRB2] })
	TRCell():New(oSecVeiItn,"ITEM_PLARB2","","",/*Picture*/,aCampTam[18,1],/*lPixel*/,{|| aDadosVei[nI,PV_PLARB2] })
	If lTercRbq
		TRCell():New(oSecVeiItn,"ITEM_CODRB3","","",/*Picture*/,aCampTam[19,1],/*lPixel*/,{|| aDadosVei[nI,PV_CODRB3] })
		TRCell():New(oSecVeiItn,"ITEM_PLARB3","","",/*Picture*/,aCampTam[20,1],/*lPixel*/,{|| aDadosVei[nI,PV_PLARB3] })
	EndIf

	//Total - Cabeçalho
	oSecVeiCabT:= TRSection():New(oRprt145,"",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) 
	TRCell():New(oSecVeiCabT,"CAB_TQtdVge","","",/*Picture*/,14,/*lPixel*/,{|| STR0016  }) //"Qtde. Viagens:"
	TRCell():New(oSecVeiCabT,"CAB_TQtdVol","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_QTDVOL', 'X3Titulo()'))+4,/*lPixel*/,{|| STR0017  }) //"Qtde. Volume:"
	TRCell():New(oSecVeiCabT,"CAB_TPesTot","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_PESO', 'X3Titulo()'  ))+4,/*lPixel*/,{|| STR0018  }) //"Peso Total:"
	TRCell():New(oSecVeiCabT,"CAB_TValMer","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_VALMER', 'X3Titulo()')),/*lPixel*/,{|| STR0019  }) //"Valor Merc:"

	//Total - Dados
	oSecVeiItnT:= TRSection():New(oSecVeiCabT,STR0084,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)//"Totais"
	TRCell():New(oSecVeiItn,"ITEM_TQtdVge","","",/*Picture*/,13,/*lPixel*/,{|| aDadosRod[1] })
	TRCell():New(oSecVeiItn,"ITEM_TQtdVol","","",PesqPict("DT6","DT6_QTDVOL"),Len(Posicione('SX3' ,2 ,'DT6_QTDVOL', 'X3Titulo()'))+1,/*lPixel*/,{|| aDadosRod[2] })
	TRCell():New(oSecVeiItn,"ITEM_TPesTot","","",PesqPict("DT6","DT6_PESO")  ,Len(Posicione('SX3' ,2 ,'DT6_PESO', 'X3Titulo()'  ))+3,/*lPixel*/,{|| aDadosRod[3] })
	TRCell():New(oSecVeiItn,"ITEM_TValMer","","",PesqPict("DT6","DT6_VALMER"),Len(Posicione('SX3' ,2 ,'DT6_VALMER', 'X3Titulo()'))+4,/*lPixel*/,{|| aDadosRod[4] })

	
ElseIf mv_par01 == 2 // -- Por Documento
	
	AAdd( aCampTam ,TAMSX3("DTQ_STATUS")                                        )//-- 1
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_FILDOC', 'X3Titulo()')),0,"C"})//-- 2  //-- Filial Doc.
	AAdd( aCampTam ,TAMSX3("DT6_DOC") 		   								          )//-- 3
	AAdd( aCampTam ,TAMSX3("DT6_SERIE") 										          )//-- 4
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_DATEMI', 'X3Titulo()')),0,"C"})//-- 5  //-- Data Emissão
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_CLIREM', 'X3Titulo()')),0,"C"})//-- 6  //-- Cód. Cliente Remetente
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_LOJREM', 'X3Titulo()')),0,"C"})//-- 7  //-- Loja Cliente Remet.
	AAdd( aCampTam ,TAMSX3("DT6_NOMREM")                                        )//-- 8  //-- Nome Remetente
	AAdd( aCampTam ,TAMSX3("DVA_REGORI")                                        )//-- 9  //-- Região Origem
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_CLIDES', 'X3Titulo()')),0,"C"})//-- 10 //-- Cód. Cliente Destinatário
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DT6_LOJDES', 'X3Titulo()')),0,"C"})//-- 11 //-- Loja Cliente Destin.
	AAdd( aCampTam ,TAMSX3("DT6_NOMDES")                                        )//-- 12 //-- Nome Destinatário
	AAdd( aCampTam ,TAMSX3("DVA_REGDES")                                        )//-- 13 //-- Região Destinatário
	AAdd( aCampTam ,TAMSX3("DTQ_VIAGEM") 										          )//-- 14
	AAdd( aCampTam ,TAMSX3("DA8_DESC")   										          )//-- 15 //-- Rota
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_SERTMS', 'X3Titulo()')),0,"C"})//-- 16 //-- SERTMS
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_TIPTRA', 'X3Titulo()')),0,"C"})//-- 17 //-- TIPTMS
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DTQ_DATGER', 'X3Titulo()')),0,"C"})//-- 18 
	AAdd( aCampTam ,{19,0,"C"}           										          )//-- 19 //"Prev. Termino"
	AAdd( aCampTam ,TAMSX3("DTR_CODVEI")                                        )//-- 20 //-- Cod. Veículo
	AAdd( aCampTam ,TAMSX3("DA3_PLACA") 										          )//-- 21
	AAdd( aCampTam ,TAMSX3("DUT_DESCRI") 										          )//-- 22
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA3_FROVEI', 'X3Titulo()')),0,"C"})//-- 23 //-- Frota
	AAdd( aCampTam ,{Len(Posicione('SX3' ,2 ,'DA4_NOME'  , 'X3Titulo()')),0,"C"})//-- 24 //-- Motorista
	AAdd( aCampTam ,TAMSX3("DA3_FILBAS")                                        )//-- 25 //-- Fil. Base

	oRprt145:SetTitle(STR0015)

	//Cabeçalho
	oSecDocCab := TRSection():New(oRprt145,cTitulo,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) 
	TRCell():New(oSecDocCab,"CAB_DOC"   ,"",aHeaderDoc[2],/*Picture*/,aCampTam[2,1]+aCampTam[3,1]+aCampTam[4,1]+3,/*lPixel*/,{|| ALLTRIM(aHeaderDoc[3])+"/"+ ALLTRIM(aHeaderDoc[4]) })
	TRCell():New(oSecDocCab,"CAB_DATEMI","","",/*Picture*/,aCampTam[5,1] ,/*lPixel*/,{|| aHeaderDoc[5]  })
	TRCell():New(oSecDocCab,"CAB_NOMREM","","",/*Picture*/,aCampTam[8,1] ,/*lPixel*/,{|| aHeaderDoc[8]  })
	TRCell():New(oSecDocCab,"CAB_REGORI","","",/*Picture*/,aCampTam[9,1] ,/*lPixel*/,{|| aHeaderDoc[9]  })
	TRCell():New(oSecDocCab,"CAB_NOMDES","","",/*Picture*/,aCampTam[12,1],/*lPixel*/,{|| aHeaderDoc[12] })
	TRCell():New(oSecDocCab,"CAB_REGDES","","",/*Picture*/,aCampTam[13,1],/*lPixel*/,{|| aHeaderDoc[13] })
	TRCell():New(oSecDocCab,"CAB_VIAGEM","",aHeaderDoc[25],/*Picture*/,aCampTam[25,1]+aCampTam[14,1]+1,/*lPixel*/,{|| aHeaderDoc[14] })
	TRCell():New(oSecDocCab,"CAB_SERTMS","","",/*Picture*/,aCampTam[16,1],/*lPixel*/,{|| aHeaderDoc[16] })
	TRCell():New(oSecDocCab,"CAB_TIPTRA","","",/*Picture*/,aCampTam[17,1],/*lPixel*/,{|| aHeaderDoc[17] })
	TRCell():New(oSecDocCab,"CAB_PRVTER","","",/*Picture*/,aCampTam[19,1],/*lPixel*/,{|| aHeaderDoc[19] })
	TRCell():New(oSecDocCab,"CAB_CODVEI","","",/*Picture*/,aCampTam[20,1],/*lPixel*/,{|| aHeaderDoc[20] })

	//Itens
	oSecDocItn:= TRSection():New(oSecDocCab,STR0032,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)//"Documentos"
	TRCell():New(oSecDocItn,"ITEM_DOC"   ,"","",/*Picture*/,aCampTam[2,1]+aCampTam[3,1]+aCampTam[4,1]+3 ,/*lPixel*/,{|| aDadosDoc[nI,PD_FILDOC]+" "+aDadosDoc[nI,PD_DOC]+"/"+ aDadosDoc[nI,PD_SERIE]   })
	TRCell():New(oSecDocItn,"ITEM_DATEMI","","",/*Picture*/,aCampTam[5,1] ,/*lPixel*/,{|| aDadosDoc[nI,PD_DATEMI] })
	TRCell():New(oSecDocItn,"ITEM_NOMREM","","",/*Picture*/,aCampTam[8,1] ,/*lPixel*/,{|| aDadosDoc[nI,PD_NOMREM] })
	TRCell():New(oSecDocItn,"ITEM_REGORI","","",/*Picture*/,aCampTam[9,1] ,/*lPixel*/,{|| aDadosDoc[nI,PD_REGORI] })
	TRCell():New(oSecDocItn,"ITEM_NOMDES","","",/*Picture*/,aCampTam[12,1],/*lPixel*/,{|| aDadosDoc[nI,PD_NOMDES] })
	TRCell():New(oSecDocItn,"ITEM_REGDES","","",/*Picture*/,aCampTam[13,1],/*lPixel*/,{|| aDadosDoc[nI,PD_REGDES] })
	TRCell():New(oSecDocItn,"ITEM_VIAGEM","","",/*Picture*/,aCampTam[25,1]+aCampTam[14,1]+1,/*lPixel*/,{|| aDadosDoc[nI,PD_FILBAS]+" "+aDadosDoc[nI,PD_VIAGEM] })
	TRCell():New(oSecDocItn,"ITEM_SERTMS","","",/*Picture*/,aCampTam[16,1],/*lPixel*/,{|| aDadosDoc[nI,PD_DESSVT] })
	TRCell():New(oSecDocItn,"ITEM_TIPTRA","","",/*Picture*/,aCampTam[17,1],/*lPixel*/,{|| aDadosDoc[nI,PD_DESTPT] })
	TRCell():New(oSecDocItn,"ITEM_PRVTER","","",/*Picture*/,aCampTam[19,1],/*lPixel*/,{|| aDadosDoc[nI,PD_PRVTER] })
	TRCell():New(oSecDocItn,"ITEM_CODVEI","","",/*Picture*/,aCampTam[20,1],/*lPixel*/,{|| aDadosDoc[nI,PD_CODVEI] })

	//Total - Cabeçalho
	oSecDocCabT:= TRSection():New(oRprt145,"",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) 
	TRCell():New(oSecDocCabT,"CAB_TQtdVge","","",/*Picture*/,14,/*lPixel*/,{|| STR0016  }) //"Qtde. Viagens:"
	TRCell():New(oSecDocCabT,"CAB_TQtdVol","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_QTDVOL', 'X3Titulo()'))+4,/*lPixel*/,{|| STR0017  }) //"Qtde. Volume:"
	TRCell():New(oSecDocCabT,"CAB_TPesTot","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_PESO', 'X3Titulo()'  ))+4,/*lPixel*/,{|| STR0018  }) //"Peso Total:"
	TRCell():New(oSecDocCabT,"CAB_TValMer","","",/*Picture*/,Len(Posicione('SX3' ,2 ,'DT6_VALMER', 'X3Titulo()'))  ,/*lPixel*/,{|| STR0019  }) //"Valor Merc:"
	TRCell():New(oSecDocCabT,"CAB_TDoctos","","",/*Picture*/,18,/*lPixel*/,{|| STR0020  }) //"Doctos:"

	//Total - Dados
	oSecDocItnT:= TRSection():New(oSecDocCabT,STR0084,{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)//"Totais"
	TRCell():New(oSecDocItn,"ITEM_TQtdVge","","",/*Picture*/,13,/*lPixel*/,{|| aDadosRod[1] })
	TRCell():New(oSecDocItn,"ITEM_TQtdVol","","",PesqPict("DT6","DT6_QTDVOL"),Len(Posicione('SX3' ,2 ,'DT6_QTDVOL', 'X3Titulo()'))+1,/*lPixel*/,{|| aDadosRod[2] })
	TRCell():New(oSecDocItn,"ITEM_TPesTot","","",PesqPict("DT6","DT6_PESO")  ,Len(Posicione('SX3' ,2 ,'DT6_PESO', 'X3Titulo()'  ))+3,/*lPixel*/,{|| aDadosRod[3] })
	TRCell():New(oSecDocItn,"ITEM_TValMer","","",PesqPict("DT6","DT6_VALMER"),Len(Posicione('SX3' ,2 ,'DT6_VALMER', 'X3Titulo()'))+4,/*lPixel*/,{|| aDadosRod[4] })
	TRCell():New(oSecDocItn,"ITEM_TDoctos","","",/*Picture*/,10,/*lPixel*/,{|| aDadosRod[5] })

EndIf

oRprt145:SetLandScape(.T.) //-- Impressão em formato Paisagem

Return(oRprt145)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport³ Autor ³ Gustavo Almeida      ³ Data ³ 02/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressão final do TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1,ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parmametro³ ExpO1: Objeto de TReport                                   ³±±
±±³          ³ ExpC1: Titulo do TReport                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145Prt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oRprt145,cTitulo)

Local oCabSec  := oRprt145:Section(1)
Local oItnSec  := oRprt145:Section(1):Section(1)
Local oCabTSec := oRprt145:Section(2)
Local oItnTSec := oRprt145:Section(2):Section(1)
Local nI_Aux  := 0

//-- Inicializa a Régua para cada período

If mv_par01 == 1 //-- Por Veiculo
	oRprt145:SetMeter(Len(aDadosVei))
ElseIf mv_par01 == 2 //-- Por Documento
	oRprt145:SetMeter(Len(aDadosDoc))
EndIf

oCabSec:Init()
oCabSec:PrintLine() //-- Cabeçalho
oCabSec:Finish()

oItnSec:Init()

If mv_par01 == 1 //-- Por Veiculo

	For nI_Aux := 1 To Len(aDadosVei) //-- Itens
		nI := nI_Aux
		oItnSec:PrintLine()
		oRprt145:IncMeter()
	Next nI_Aux

ElseIf mv_par01 == 2 //-- Por Documento

	For nI_Aux := 1 To Len(aDadosDoc) //-- Itens
		nI := nI_Aux
		oItnSec:PrintLine()
		oRprt145:IncMeter()
	Next nI_Aux

EndIf

oItnSec:Finish()

oCabTSec:Init()
oCabTSec:PrintLine() //-- Cabeçalho Total
oCabTSec:Finish()

oItnTSec:Init()
oItnTSec:PrintLine() //-- Itens Rodapé
oItnTSec:Finish()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA145Pos³ Autor ³ Caio Murakami      ³ Data ³ 08/08/12    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posicionamento de veículos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA145Pos()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TmsA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function TmsA145Pos(cCodVei,cFilOri,cViagem)

Local aKeyAnt   := AClone(aSetKey)
Local cFiltro   := ""

Default cCodVei := ""
Default cFilOri := ""
Default cViagem := ""

TmsKeyOff(aSetKey)

If !Empty(cCodVei)
	cFiltro := " DAV_CODVEI == '" + cCodVei  + "' "
	If !Empty(cFilOri)
		cFiltro += " .And. DAV_FILORI == '" + cFilOri + "' "
	EndIf
	If !Empty(cViagem)
		cFiltro += " .And. DAV_VIAGEM == '" + cViagem + "' "
	EndIf
EndIf

//--DAV_FILIAL+DAV_FILORI+DAV_VIAGEM+DAV_CODVEI
DAV->( dbSetOrder(2) )
If DAV->( dbSeek(xFilial("DAV") + cCodvei ) )
	TmsAO10(,,cFiltro)
Else
	Help('',1,'REGNOIS')
EndIf

aSetKey := aKeyAnt
TmsKeyOn(aSetKey)

Return Nil