#Include "PROTHEUS.CH"
#Include "OFIXC006.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIXC006 º Autor ³ Andre Luis Almeida º Data ³  13/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Agendamento Oficina - Confirmar presenca do Cliente        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXC006()
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cPesqCli   := space(30)
Local cPesqVei   := space(VSO->(TamSX3("VSO_PLAVEI")[1]))
Private cVeicul  := space(25)
Private aAgeVSO  := {}
Private cDtHrLev := ""
Private oCor11   := LoadBitmap( GetResources() , "BR_VERDE" )		// Agendamento confirmado
Private oCor12   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Agendamento nao confirmado
Private oCor21   := LoadBitmap( GetResources() , "BR_BRANCO" )		// Aguardando chegada do Cliente
Private oCor22   := LoadBitmap( GetResources() , "BR_LARANJA" )		// Cliente esta atrasado
Private nTpoTela := ( ( 5 * 1000 ) * 60 ) // 5 minutos
Private aNewBot  := { { "PARAMETROS" , { || FS_PARAM(1) } , STR0002+" "+"<F12>" }  , { "PMSCOLOR" , { || FS_LEGEND() } , STR0003 } } // Parametros / Legenda

SetKey(VK_F12,{|| FS_PARAM(1) })

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 20 , .T. , .F. } ) // Pesquisar
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox

aPos := MsObjSize( aInfo, aObjects )

FS_PARAM(0)

dbSelectArea("VSO")

DEFINE MSDIALOG oOFXC006 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Agendamento Oficina - Confirmar presenca do Cliente

oTimerTela := TTimer():New(nTpoTela, {|| FS_FILTRAR(1) }, oOFXC006 )
oTimerTela:Activate()

@ aPos[1,1]+000,aPos[1,4]-072 TO aPos[1,3],aPos[1,4]-2 LABEL STR0009 OF oOFXC006 PIXEL // Levantamento a partir de:
@ aPos[1,1]+009,aPos[1,4]-066 SAY oDtHrLev VAR cDtHrLev SIZE 50,10 OF oOFXC006 PIXEL COLOR CLR_HRED

@ aPos[1,1]+000,aPos[1,2] TO aPos[1,3],aPos[1,4]-075 LABEL STR0010 OF oOFXC006 PIXEL // Pesquisar
@ aPos[2,1]+001,aPos[2,2]+000 LISTBOX oLbAgeVSO FIELDS HEADER "","",STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017 ; // Dt.Agend / Hr.Agend / Cliente / Placa / Veiculo / Chassi / Produtivo/Box
																COLSIZES 10,10,27,27,140,30,90,70,140 SIZE aPos[2,4]-5,aPos[2,3]-(aPos[2,1]+5) OF oOFXC006 PIXEL ON DBLCLICK FS_CONFPRE(oLbAgeVSO:nAt)
oLbAgeVSO:SetArray(aAgeVSO)
oLbAgeVSO:bLine := { || { 	IIf(aAgeVSO[oLbAgeVSO:nAt,01]=="1",oCor11,oCor12) ,;
							IIf(aAgeVSO[oLbAgeVSO:nAt,02]=="1",oCor21,oCor22) ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,03],"@D") ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,04],"@R 99:99")+"h" ,;
							aAgeVSO[oLbAgeVSO:nAt,11]+"-"+aAgeVSO[oLbAgeVSO:nAt,12]+" "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,13]) ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,07],x3Picture("VSO_PLAVEI")),;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,08])+" "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,09]),;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,10]) ,;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,05])+" ( "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,06])+" )"  }}

@ aPos[1,1]+009,aPos[1,2]+005 SAY (STR0021+":") SIZE 50,10 OF oOFXC006 PIXEL COLOR CLR_BLACK // Nome do Cliente
@ aPos[1,1]+008,aPos[1,2]+050 MSGET oPesqCli VAR cPesqCli PICTURE "@!" SIZE 100,08 VALID FS_PESQVET(13,cPesqCli) OF oOFXC006 PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[1,1]+009,aPos[1,2]+205 SAY (STR0022+":") SIZE 50,10 OF oOFXC006 PIXEL COLOR CLR_BLACK // Placa do Veiculo
@ aPos[1,1]+008,aPos[1,2]+252 MSGET oPesqVei VAR cPesqVei PICTURE VSO->(x3Picture("VSO_PLAVEI")) SIZE 40,08 VALID FS_PESQVET(07,cPesqVei) OF oOFXC006 PIXEL COLOR CLR_BLUE HASBUTTON

ACTIVATE MSDIALOG oOFXC006 ON INIT EnchoiceBar(oOFXC006,{ || oOFXC006:End() }, { || oOFXC006:End() },,aNewBot)

SetKey(VK_F12,Nil)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_PARAM º Autor ³ Andre Luis Almeida º Data ³  14/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Parametros da rotina                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PARAM(nTp)

If nTp == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunte para Parametros da Rotina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//AADD(aRegs,{STR0023 , "", "", "mv_ch1", "N", 1 , 0, 1, "C", ''                , "mv_par01", STR0024,STR0024,STR0024, "" , "" , STR0025,STR0025,STR0025, "" , "" , STR0026,STR0026,STR0026, "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {},{},{}})
	//AADD(aRegs,{STR0027 , "", "", "mv_ch2", "N", 3 , 0, 0, "G", '(MV_PAR02 >= 0)' , "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})
	//AADD(aRegs,{STR0028 , "", "", "mv_ch3", "N", 2 , 0, 0, "G", '(MV_PAR03 >= 1)' , "mv_par03", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{},{},{}})

	Pergunte("OXC006",.f.)
	If MV_PAR03 > 0
		nTpoTela := ( ( MV_PAR03 * 1000 ) * 60 )
	EndIf
Else
	Pergunte("OXC006",.t.)
	If MV_PAR03 > 0
		nTpoTela := ( ( MV_PAR03 * 1000 ) * 60 )
		oTimerTela:DeActivate()
		oTimerTela:nInterval := nTpoTela
		oTimerTela:Activate()
	EndIf
EndIf
Processa( {|| FS_FILTRAR(nTp) } )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FILTRARº Autor ³ Andre Luis Almeida º Data ³  14/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtra/Levanta Agendamento EM ABERTO                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp)
Local cQuery  := ""
Local cQAlSQL := "SQLVSO"
Local dAux    := dDataBase // Dia atual
Local cTime   := left(Time(),5) // Hora/Minuto atual
Local cAux1   := "00:00"
Local cAux2   := ""
Local nAux1   := 0
Local nAux2   := 0
Local cCor1   := ""
Local cCor2   := ""
Pergunte("OXC006",.f.)
If MV_PAR01 == 1 // Dias
	//////////////////////
	// Calcular Dias    //
	//////////////////////
	dAux := ( dDataBase - MV_PAR02 )
ElseIf MV_PAR01 == 2 // Horas
	//////////////////////
	// Calcular Horas   //
	//////////////////////
	cAux1 := cTime // Hora/Minuto atual
	nAux1 := int( ( MV_PAR02 / 24 ) ) // Horas em Dias
	nAux2 := ( ( ( MV_PAR02 / 24 ) - nAux1 ) * 24 ) // sobra de Horas
	cAux2 := strzero( int( val(left(cAux1,2)) ) -  int(nAux2) , 2 ) + substr(cAux1,3)
	If val(left(cAux1,2)) < nAux2 // Se Horas negativas
		nAux1++
		nAux2 := ( 24 - ( nAux2 - val(left(cAux1,2)) ) ) // retirar Dias
		cAux2 := strzero( nAux2 , 2 ) + substr(cAux1,3)
	EndIf
	cAux1 := cAux2
	If nAux1 >= 1
		dAux := dDataBase - nAux1
	EndIf
ElseIf MV_PAR01 == 3 // Minutos
	//////////////////////
	// Calcular Minutos //
	//////////////////////
	cAux1 := cTime // Hora/Minuto atual
	nAux1 := int( ( MV_PAR02 / 60 ) ) // Minutos em Horas
	nAux2 := ( ( ( MV_PAR02 / 60 ) - nAux1 ) * 60 ) // sobra de Minutos
	cAux2 := left(cAux1,3) + strzero( int( val(right(cAux1,2)) ) -  int(nAux2) , 2 )
	If val(right(cAux1,2)) < nAux2 // Se Minutos negativos
		nAux1++
		nAux2 := ( 60 - ( nAux2 - val(right(cAux1,2)) ) ) // retirar Horas
		cAux2 := left(cAux1,3) + strzero( nAux2 , 2 ) 
	EndIf
	cAux1 := cAux2
	//////////////////////
	// Calcular Horas   //
	//////////////////////
	nHora := nAux1
	nAux1 := int( ( nHora / 24 ) ) // Horas em Dias
	nAux2 := ( ( ( nHora / 24 ) - nAux1 ) * 24 ) // sobra de Horas
	cAux2 := strzero( int( val(left(cAux1,2)) ) -  int(nAux2) , 2 ) + substr(cAux1,3)
	If val(left(cAux1,2)) < nAux2 // Se Horas negativas
		nAux1++
		nAux2 := ( 24 - ( nAux2 - val(left(cAux1,2)) ) ) // retirar Dias
		cAux2 := strzero( nAux2 , 2 ) + substr(cAux1,3)
	EndIf
	cAux1 := cAux2
	If nAux1 >= 1
		dAux := dDataBase - nAux1
	EndIf
EndIf
//
cDtHrLev := Transform(dAux,"@D")+" "+cAux1+"h"
//
aAgeVSO := {}
//
cQuery  := "SELECT VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_NUMBOX , VSO.VSO_AGCONF , VSO.VSO_PLAVEI , VSO.VSO_CODMAR , VSO.VSO_PROVEI , VSO.VSO_LOJPRO , VSO.VSO_GETKEY , "
cQuery  += "VON.VON_CODPRO , VOD.VOD_DESSEC , VAI.VAI_NOMTEC , VV2.VV2_DESMOD , SA1.A1_NOME , VSO.R_E_C_N_O_ AS RECVSO "
cQuery  += "FROM "+RetSqlName("VSO")+" VSO "
cQuery  += "LEFT JOIN "+RetSqlName("VON")+" VON ON ( VON.VON_FILIAL='"+xFilial("VON")+"' AND VON.VON_NUMBOX=VSO.VSO_NUMBOX AND VON.D_E_L_E_T_=' ' ) "
cQuery  += "LEFT JOIN "+RetSqlName("VOD")+" VOD ON ( VOD.VOD_FILIAL='"+xFilial("VOD")+"' AND VOD.VOD_CODSEC=VON.VON_CODSEC AND VOD.D_E_L_E_T_=' ' ) "
cQuery  += "LEFT JOIN "+RetSqlName("VAI")+" VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VON.VON_CODPRO AND VAI.D_E_L_E_T_=' ' ) "
cQuery  += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VSO.VSO_CODMAR AND VV2.VV2_MODVEI=VSO.VSO_MODVEI AND VV2.VV2_SEGMOD=VSO.VSO_SEGMOD AND VV2.D_E_L_E_T_=' ' ) "
cQuery  += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VSO.VSO_PROVEI AND SA1.A1_LOJA=VSO.VSO_LOJPRO AND SA1.D_E_L_E_T_=' ' ) "
cQuery  += "WHERE VSO.VSO_FILIAL='"+xFilial("VSO")+"' AND VSO.VSO_STATUS='1' AND "
cQuery  += "VSO.VSO_DATAGE>='"+dtos(dAux)+"' AND VSO.VSO_DATAGE<='"+dtos(dDataBase)+"' AND "
cQuery  += "VSO.VSO_AGCONF<>'2' AND VSO.D_E_L_E_T_=' ' "
cQuery  += "ORDER BY VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_PLAVEI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	cCor1 := IIf(( cQAlSQL )->( VSO_AGCONF )=="1","1","0") // 1=Agendamento confirmado / 0=Atendimento nao confirmado 
	cCor2 := "0" // 0=Cliente esta atrasado
	If stod(( cQAlSQL )->( VSO_DATAGE )) == dAux
		If left(( cQAlSQL )->( VSO_HORAGE ),2) < left(cAux1,2)
			( cQAlSQL )->( DbSkip() )
			Loop
		ElseIf left(( cQAlSQL )->( VSO_HORAGE ),2) == left(cAux1,2)
			If right(( cQAlSQL )->( VSO_HORAGE ),2) < right(cAux1,2)
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
		EndIf
	EndIf
	If stod(( cQAlSQL )->( VSO_DATAGE )) == dDataBase
		cCor2 := "1" // Aguardando chegada do Cliente
		If left(( cQAlSQL )->( VSO_HORAGE ),2) < left(cTime,2)
			cCor2 := "0" // 0=Cliente esta atrasado
		ElseIf left(( cQAlSQL )->( VSO_HORAGE ),2) == left(cTime,2)
			If right(( cQAlSQL )->( VSO_HORAGE ),2) < right(cTime,2)
				cCor2 := "0" // 0=Cliente esta atrasado
			EndIf
		EndIf
	EndIf
	aAdd(aAgeVSO,{cCor1,cCor2,;
					stod(( cQAlSQL )->( VSO_DATAGE )),( cQAlSQL )->( VSO_HORAGE ),;
					( cQAlSQL )->( VON_CODPRO )+"-"+( cQAlSQL )->( VAI_NOMTEC ),;
					( cQAlSQL )->( VSO_NUMBOX )+"-"+( cQAlSQL )->( VOD_DESSEC ),;
					( cQAlSQL )->( VSO_PLAVEI ),( cQAlSQL )->( VSO_CODMAR ),( cQAlSQL )->( VV2_DESMOD ),( cQAlSQL )->( VSO_GETKEY ),;
					( cQAlSQL )->( VSO_PROVEI ),( cQAlSQL )->( VSO_LOJPRO ),( cQAlSQL )->( A1_NOME ),;
					( cQAlSQL )->( RECVSO )})
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VSO")
If len(aAgeVSO) <= 0
	aAdd(aAgeVSO,{"0","0",ctod(""),"","","","","","","","","","",0})
EndIf
If nTp > 0
	oDtHrLev:Refresh()
	oLbAgeVSO:nAt := 1
	oLbAgeVSO:SetArray(aAgeVSO)
	oLbAgeVSO:bLine := { || { 	IIf(aAgeVSO[oLbAgeVSO:nAt,01]=="1",oCor11,oCor12) ,;
							IIf(aAgeVSO[oLbAgeVSO:nAt,02]=="1",oCor21,oCor22) ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,03],"@D") ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,04],"@R 99:99")+"h" ,;
							aAgeVSO[oLbAgeVSO:nAt,11]+"-"+aAgeVSO[oLbAgeVSO:nAt,12]+" "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,13]) ,;
							Transform(aAgeVSO[oLbAgeVSO:nAt,07],x3Picture("VSO_PLAVEI")),;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,08])+" "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,09]),;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,10]) ,;
							Alltrim(aAgeVSO[oLbAgeVSO:nAt,05])+" ( "+Alltrim(aAgeVSO[oLbAgeVSO:nAt,06])+" )"  }}
	oLbAgeVSO:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEGEND ³ Autor ³ Andre Luis Almeida  ³ Data ³ 17/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Agendamento - Confirma presenca do Cliente     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEGEND()
Local aLegenda := {	{'BR_VERDE'   , STR0005 },;	// Agendamento confirmado
					{'BR_VERMELHO', STR0006 },;	// Agendamento nao confirmado
					{'BR_BRANCO'  , STR0007 },;	// Aguardando chegada do Cliente
					{'BR_LARANJA' , STR0008 }}	// Cliente esta atrasado
BrwLegenda(STR0004,STR0003,aLegenda) // Agendamento Oficina / Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONFPRE³ Autor ³ Andre Luis Almeida  ³ Data ³ 17/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma presenca do Cliente                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONFPRE(nLinha)
Local cMsg := ""
If aAgeVSO[nLinha,14] > 0
	cMsg := STR0018+": "+Transform(aAgeVSO[nLinha,03],"@D")+" "+Transform(aAgeVSO[nLinha,04],"@R 99:99")+"h"+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Agendado
	cMsg +=	STR0013+": "+aAgeVSO[nLinha,11]+"-"+aAgeVSO[nLinha,12]+" "+Alltrim(aAgeVSO[nLinha,13])+CHR(13)+CHR(10) // Cliente
	cMsg += STR0015+": "+aAgeVSO[nLinha,07]+" "+Alltrim(aAgeVSO[nLinha,08])+" "+Alltrim(aAgeVSO[nLinha,09])+" ( "+Alltrim(aAgeVSO[nLinha,10])+" )"+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Veiculo
	cMsg += STR0017+": "+Alltrim(aAgeVSO[nLinha,05])+" ( "+Alltrim(aAgeVSO[nLinha,06])+" )" // Produtivo/Box
	If MsgYesNo(STR0019+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0020) // Confirma presenca do Cliente? / Atencao
		DbSelectArea("VSO")
		DbGoTo(aAgeVSO[nLinha,14])
		RecLock("VSO",.f.)
			VSO->VSO_AGCONF := "2" // Cliente presente
		MsUnLock()
		if MsgYesNo(STR0029,STR0020)
	   	    OFIOA280()
		Endif
		Processa( {|| FS_FILTRAR(1) } )
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQVET³ Autor ³ Andre Luis Almeida  ³ Data ³ 17/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no vetor: Nome do Cliente / Placa do Veiculo    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQVET(nColuna,cPesqAux)
Local ni  := 1
oLbAgeVSO:nAt := 1
For ni := 1 to len(aAgeVSO)
	If UPPER(Alltrim(cPesqAux)) $ UPPER(aAgeVSO[ni,nColuna])
		oLbAgeVSO:nAt := ni
		Exit
	EndIf
Next
oLbAgeVSO:SetFocus()
oLbAgeVSO:Refresh()
Return(.t.)