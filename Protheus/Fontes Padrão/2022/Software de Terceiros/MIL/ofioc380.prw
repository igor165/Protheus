// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOC380.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC380 ³ Autor ³  Rafael Goncalves     ³ Data ³ 15 01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta diaria por Tarefa / Hora / Box / Produtivo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC380()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local lBXT := .f.
Local cCbStat := STR0001 //1=Todos
Local cAgeCon := "3"
Local aCbStat :={"1="+STR0001,"2="+STR0002,"3="+STR0003,"4="+STR0004,"5="+STR0005,"6="+STR0006,"7="+STR0007}//1=Todos ### 2=Agendado ### 3=Em Andamento Total ### 4=Em Aberto Orcamento ### 5=Em Aberto O.S. ### 6=Em Aberto Finalizado ### 7=Cancelado
Local aAgeCon :={"1="+STR0037,"2="+STR0038,"3="+STR0039}//1=Confirmado ### 2=Nao Confimado ### 3=Ambos
Local dDatIni := ctod("   /   /   ")//ctod("01/"+strzero(month(dDataBase),2)+"/"+right(strzero(year(dDataBase),4),2))
Local dDatFim := ctod("   /   /   ")//ddatabase
Local cHorIni := space(5)
Local cHorFim := space(5)
Local cCodCli := space(Len(SA1->A1_COD))
Local cLojCli := space(Len(SA1->A1_LOJA))
Local cNomCli := space(21)
Local cBoxFtr := "   "
Local aFilAtu   := FWArrFilAtu()
Local aFilFtr   := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cFilFtr   := "  "
Private aLevPesq := {}
Private aInconvAg := {}
Private cChassi := space(Len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )    	// 1 = Agendad
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO")		// 4 = Cancelado
Private oazul := LoadBitmap( GetResources(), "BR_azul")			// 2 = OS Aberta
Private olara := LoadBitmap( GetResources(), "BR_laranja")  	// 5 = Orcamento Aberto
Private opret := LoadBitmap( GetResources(), "BR_preto") 		// 3 = Finalizado
Private obran := LoadBitmap( GetResources(), "BR_branco")      //qdo em chanco
aAdd(aFilFtr,"")
aSort(aFilFtr)
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 44 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

FS_LEVANTA(0)
DEFINE MSDIALOG oPesqAge TITLE STR0008 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL  //Pesquisa Avancada
//Objeto 01 cabecalho
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0009 OF oPesqAge PIXEL  //Filtro

@ aPosObj[1,1]+9,aPosObj[1,2]+4 SAY oDat VAR STR0010 SIZE 150,08 OF oPesqAge PIXEL COLOR CLR_BLUE     //Status
@ aPosObj[1,1]+7,aPosObj[1,2]+25 MSCOMBOBOX oCbStat VAR cCbStat ITEMS aCbStat  SIZE 95,08 OF oPesqAge PIXEL //COLOR CLR_HBLUE //WHEN ( lOk ) ON CHANGE(lOkM:=.t.)//VALID lSair .or. FS_VALID("MDE")
@ aPosObj[1,1]+9,aPosObj[1,2]+127 SAY oFil VAR STR0011 SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLUE 	//Filial
@ aPosObj[1,1]+7,aPosObj[1,2]+145 MSCOMBOBOX oCbStat VAR cFilFtr ITEMS aFilFtr  SIZE 75,08 OF oPesqAge PIXEL 

@ aPosObj[1,1]+9,aPosObj[1,2]+230 SAY oAge VAR STR0040 SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLUE  	//Agendamento
@ aPosObj[1,1]+7,aPosObj[1,2]+266 MSCOMBOBOX oAgeCon VAR cAgeCon ITEMS aAgeCon  SIZE 55,08 OF oPesqAge PIXEL //COLOR CLR_HBLUE //WHEN ( lOk ) ON CHANGE(lOkM:=.t.)//VALID lSair .or. FS_VALID("MDE")

@ aPosObj[1,1]+21,aPosObj[1,2]+4 SAY oData VAR STR0013 SIZE 150,08 OF oPesqAge PIXEL COLOR CLR_BLUE 	//Data
@ aPosObj[1,1]+19,aPosObj[1,2]+25 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+78 SAY oDatate VAR STR0014 SIZE 150,08 OF oPesqAge PIXEL COLOR CLR_BLUE //ate
@ aPosObj[1,1]+19,aPosObj[1,2]+95 MSGET odatFim VAR dDatFim PICTURE "@D" SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+147 SAY oHora VAR STR0015 SIZE 150,08 OF oPesqAge PIXEL COLOR CLR_BLUE //Hora
@ aPosObj[1,1]+19,aPosObj[1,2]+165 MSGET oHorIni VAR cHorIni VALID FS_VARHORA(cHorIni) PICTURE "@R 99:99" SIZE 20,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+197 SAY oHorate VAR STR0014 SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLUE //ate
@ aPosObj[1,1]+19,aPosObj[1,2]+210 MSGET oHorFim VAR cHorFim VALID FS_VARHORA(cHorFim,cHorIni,cHorFim) PICTURE "@R 99:99" SIZE 20,08 OF oPesqAge PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+21,aPosObj[1,2]+250 SAY oBox VAR STR0012 SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLUE  	//Box
@ aPosObj[1,1]+19,aPosObj[1,2]+263 MSGET oBoxFtr VAR cBoxFtr F3 "BOX" SIZE 10,08 OF oPesqAge PIXEL COLOR CLR_BLACK


@ aPosObj[1,1]+33,aPosObj[1,2]+4 SAY oChass VAR STR0016 SIZE 50,08 OF oPesqAge PIXEL COLOR CLR_BLUE //Veiculo
@ aPosObj[1,1]+31,aPosObj[1,2]+25 MSGET oChassi VAR cChassi PICTURE "@!" VALID (FG_POSVEI("cChassi",),oChassi:Refresh()) SIZE 95,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+33,aPosObj[1,2]+127 SAY oClient VAR STR0017 SIZE 20,08 OF oPesqAge PIXEL COLOR CLR_BLUE //Cliente
@ aPosObj[1,1]+31,aPosObj[1,2]+145 MSGET oCodCli VAR cCodCli F3 "VSA" SIZE 18,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+31,aPosObj[1,2]+181 MSGET oLojCli VAR cLojCli SIZE 10,08 OF oPesqAge PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+32,aPosObj[1,2]+198 SAY oSep VAR "-" SIZE 5,08 OF oPesqAge PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+31,aPosObj[1,2]+204 MSGET oNomCli VAR cNomCli PICTURE "@!" SIZE 100,08 OF oPesqAge PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+7,aPosObj[1,4]-52 BUTTON oFintra PROMPT OemToAnsi(STR0018) OF oPesqAge SIZE 45,10 PIXEL ACTION FS_LEVANTA(1,cCbStat,cFilFtr,cBoxFtr,dDatIni,dDatFim,cHorIni,cHorFim,cChassi,cCodCli,cLojCli,cNomCli,cAgeCon) //FILTRAR
@ aPosObj[1,1]+31,aPosObj[1,4]-52 BUTTON oSair PROMPT OemToAnsi(STR0019) OF oPesqAge SIZE 45,10 PIXEL ACTION oPesqAge:End() // SAIR
//Parametros da funcao Filtrar
//1o Elemento - se 1-filtra ou 0-nao.
//2o Elemento - Status
//3o Elemento - Filial
//4o Elemento - BOX
//5o Elemento - Data Inicial
//6o Elemento - Data Final
//7o Elemento - Hora Inicial
//8o Elemento - Hora Final
//9o Elemento - Chassi
//10 Elemento - Codigo do Cliente
//11 Elemento - Loja do Cliente
//12 Elemento - Nome do Cliente
@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLstAgen FIELDS HEADER "",STR0011,STR0037,STR0015,STR0012,STR0040,STR0024,STR0025,STR0016,STR0026,STR0017,STR0027,STR0028; // Filial ### Data ### Hora ### Box ### Produtivo ### Placa ### Veiculo ### Chassi ### Cliente ### Fone ### E-mail
COLSIZES 10,80,35,20,40,40,100,35,100,100,130,80,120 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oPesqAge PIXEL ON DBLCLICK (FS_POSREG(oLstAgen:nAt),oPesqAge:End()) ON CHANGE ( FS_LEVINC(@aLevPesq[oLstAgen:nAt,15],1))
oLstAgen:SetArray(aLevPesq)
oLstAgen:bLine := { || {IIF(aLevPesq[oLstAgen:nAt,1]=="1",oVerd,IIF(aLevPesq[oLstAgen:nAt,1]=="2",oazul,IIF(aLevPesq[oLstAgen:nAt,1]=="3",opret,IIF(aLevPesq[oLstAgen:nAt,1]=="4",oVerm,IIF(aLevPesq[oLstAgen:nAt,1]=="5",olara,obran))))),;
aLevPesq[oLstAgen:nAt,13],;
aLevPesq[oLstAgen:nAt,2],;
aLevPesq[oLstAgen:nAt,3],;
aLevPesq[oLstAgen:nAt,4],;
aLevPesq[oLstAgen:nAt,16],;
aLevPesq[oLstAgen:nAt,5],;
aLevPesq[oLstAgen:nAt,6],;
aLevPesq[oLstAgen:nAt,7],;
aLevPesq[oLstAgen:nAt,8],;
aLevPesq[oLstAgen:nAt,9],;
aLevPesq[oLstAgen:nAt,10],;
aLevPesq[oLstAgen:nAt,11]}}
// 2 LIST BOX INFERIOR INCONVENIENTES NO BOX
@ aPosObj[3,1],aPosObj[3,2] LISTBOX oInconvAg FIELDS HEADER STR0034 ,; // Grupo
STR0035 ,; // Codigo
STR0036  ; // Descricao
COLSIZES 50,70,250 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-2 OF oPesqAge PIXEL
oInconvAg:SetArray(aInconvAg)
oInconvAg:bLine := { || {  aInconvAg[oInconvAg:nAt,1] ,;
aInconvAg[oInconvAg:nAt,2] ,;
aInconvAg[oInconvAg:nAt,3]}}


@ aPosObj[4,1]+2,aPosObj[4,2]+4 BITMAP OXverde RESOURCE "BR_verde"  OF oPesqAge PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[4,1]+2,aPosObj[4,2]+14 SAY STR0029 SIZE 80,08 OF oPesqAge PIXEL COLOR CLR_BLACK//CLR_GREEN			//Agendado

@ aPosObj[4,1]+2,aPosObj[4,2]+84 BITMAP OXlara RESOURCE "BR_laranja"  OF oPesqAge PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[4,1]+2,aPosObj[4,2]+94 SAY STR0033 SIZE 80,08 OF oPesqAge PIXEL COLOR CLR_BLACK//RGB(255,120,20)	//Orcamento Aberto

@ aPosObj[4,1]+2,aPosObj[4,2]+164 BITMAP OXazul RESOURCE "BR_azul"  OF oPesqAge PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[4,1]+2,aPosObj[4,2]+174 SAY STR0032 SIZE 80,08 OF oPesqAge PIXEL COLOR CLR_BLACK//CLR_BLUE			//OS Aberta

@ aPosObj[4,1]+2,aPosObj[4,2]+244 BITMAP OXverm RESOURCE "BR_VERMELHO"  OF oPesqAge PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[4,1]+2,aPosObj[4,2]+254 SAY STR0031 SIZE 80,08 OF oPesqAge PIXEL COLOR CLR_BLACK//CLR_RED			//cancelado

@ aPosObj[4,1]+2,aPosObj[4,2]+324 BITMAP OXpreto RESOURCE "BR_preto"  OF oPesqAge PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[4,1]+2,aPosObj[4,2]+334 SAY STR0030 SIZE 80,08 OF oPesqAge PIXEL COLOR CLR_BLACK			//Finalizado



ACTIVATE MSDIALOG oPesqAge

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VARHORA³ Autor ³  Rafael Goncalves     ³ Data ³ 15 01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ valida hora digitada                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cHorVal - Hora a ser validada                              ³±±
±±³          ³ cHorIn  - Hora Inicial                                     ³±±
±±³          ³ cHorFm  - Hora Final                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VARHORA(cHorVal,cHorIn,cHorFm)
Local nHora := 0
Local nMinut := 0
Local nHorIn := 0
Local nHorFm := 0
Default cHorIn := ""
Default cHorFm := ""

nHorIn := Iif(cHorIn<>"",val(cHorIn),0)
nHorFm := Iif(cHorIn<>"",val(cHorFm),0)

nHora := val(substr(cHorVal,1,2))
nMinut:= val(substr(cHorVal,3,2))

If nHora < 0 .or. nHora > 23 .or. nMinut < 0 .or. nMinut > 59
	MsgInfo(STR0022,STR0021)//Hora invalida ### atencao
	Return .f.
EndIf

If nHorFm > 0 .and. nHorFm < nHorIn
	MsgInfo(STR0023,STR0021)//Hora Final prescisa ser maior que a hora inicial ### Atencao
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANTA³ Autor ³  Rafael Goncalves     ³ Data ³ 15 01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento das Tarefas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTP      - se filtra ou nao                                ³±±
±±³          ³ cStatus  - Status                                          ³±±
±±³          ³ cFilLev  - Filial                                          ³±±
±±³          ³ cBoxLev  - BOX                                             ³±±
±±³          ³ cDtInLv  - Data Inicial                                    ³±±
±±³          ³ cDtFmLv  - Data Final                                      ³±±
±±³          ³ cHrInLV  - Hora Inicial                                    ³±±
±±³          ³ cHrFmLv  - Hora Final                                      ³±±
±±³          ³ cChassLv - Chassi                                          ³±±
±±³          ³ cCodClLv - Codigo do Cliente                               ³±±
±±³          ³ cLojClLv - Loja do Cliente                                 ³±±
±±³          ³ cNomClLv - Nome do Cliente                                 ³±±
±±³          ³ cAgeCon  - Agendamento Confirmado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(nTP,cStatus,cFilLev,cBoxLev,cDtInLv,cDtFmLv,cHrInLV,cHrFmLv,cChassLv,cCodClLv,cLojClLv,cNomClLv,cAgeCon)
Local cQuery  := ""
Local cQAlias := "SQLVSOP"
Local cFilSlv := cFilAnt
Local cConf   := ""

Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0

Default cStatus := ""
Default cFilLev := ""
Default cBoxLev := ""
Default cDtInLv := ""
Default cDtFmLv := ""
Default cHrInLV := ""
Default cHrFmLv := ""
Default cChassLv:= ""
Default cCodClLv:= ""
default cLojClLv:= ""
Default cNomClLv:= ""

IF cStatus == "1" //Todos
	cStatus := ""
ElseIf cStatus == "2" //Agendado
	cStatus:="1"
ElseIf cStatus == "3" //Em Andamento Total
	cStatus:="2/5"
ElseIf cStatus == "4" //Andamento Aberto orcamento
	cStatus:="5"
ElseIf cStatus == "5" //Andamento Aberto OS
	cStatus:="2"
ElseIf cStatus == "6" //Finalizado
	cStatus:="3"
ElseIf cStatus == "7" //Cancelado
	cStatus:="4"
EndIf

aLevPesq := {}
If nTp>0
	
	For nCont := 1 to Len(aSM0)
	
		If !Empty(cFilLev) //Filtra Filial
			If cFilLev <> aSM0[nCont]
				Loop
			EndIf
		EndIf
		cFilAnt := aSM0[nCont]

		cQuery := "SELECT VSO.VSO_FONPRO , VSO.VSO_NUMIDE , VSO.VSO_FILIAL , VSO.VSO_EMAIL , VSO.VSO_CODMAR , VSO.VSO_MODVEI , VSO.VSO_NOMPRO , VSO.VSO_GETKEY , VSO.VSO_LOJPRO , VSO.VSO_PROVEI , VSO.VSO_STATUS , VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_NUMBOX , VSO.VSO_PLAVEI , VSO.VSO_PLAVEI , VSO.VSO_AGCONF FROM "+RetSqlName("VSO")+" VSO  WHERE "
		cQuery += "VSO.VSO_FILIAL='"+xFilial("VSO")+"' AND "
		If !Empty(cStatus)
			If (cStatus=="2/5")//se for vazio todos os status
				cQuery += "VSO.VSO_STATUS IN ('2','5') AND "
			Else
				cQuery += "VSO.VSO_STATUS='"+cStatus+"' AND "
			EndIf
		EndIf
		if !Empty(cBoxLev) //filtro do box
			cQuery    += "VSO.VSO_NUMBOX='"+cBoxLev+"' AND "
		EndIf
		If !Empty(cDtInLv)//Filtro data
			cQuery    += "VSO.VSO_DATAGE>='"+dtos(cDtInLv)+"' AND "
		EndIf
		If !Empty(cDtFmLv)
			cQuery    += "VSO.VSO_DATAGE<='"+dtos(cDtFmLv)+"' AND "
		EndIf
		If !Empty(cHrInLV)//filtro Hora
			cQuery    += "VSO.VSO_HORAGE>='"+cHrInLV+"' AND "
		EndIf
		If !Empty(cHrFmLv)
			cQuery    += "VSO.VSO_HORAGE<='"+cHrFmLv+"' AND "
		EndIf
		If !Empty(cChassLv)//Filtra o Chassi
			cQuery    += "VSO.VSO_GETKEY='"+cChassLv+"' AND "
		EndIf
		If !Empty(cCodClLv)//Filtra o Codigo do Cliente
			cQuery    += "VSO.VSO_PROVEI='"+cCodClLv+"' AND "
		EndIf
		If !Empty(cCodClLv)//Filtra a Loja do Cliente
			cQuery    += "VSO.VSO_LOJPRO='"+cLojClLv+"' AND "
		EndIf
		If !Empty(cNomClLv)//Filtra o Nome do Cliente
			cQuery    += "VSO.VSO_NOMPRO LIKE '" +Alltrim(cNomClLv)+ "%' AND "
		EndIf
		if cAgeCon == "1" // Agendamento Confirmado
			cQuery    += "VSO.VSO_AGCONF IN ('1','2') AND "
		Elseif cAgeCon == "2"
			cQuery    += "VSO.VSO_AGCONF NOT IN ('1','2') AND "
		Endif
		cQuery += "VSO.D_E_L_E_T_=' ' ORDER BY VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_NUMBOX"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		Do While !( cQAlias )->( Eof() )
			DbSelectArea("VON")
			DbSetOrder(1)
			DbSeek( xFilial("VON") + ( cQAlias )->( VSO_NUMBOX ) )
			DbSelectArea("VAI")
			DbSetOrder(1)
			DbSeek( xFilial("VAI") + VON->VON_CODPRO )
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek( xFilial("VV2") + ( cQAlias )->( VSO_CODMAR ) + ( cQAlias )->( VSO_MODVEI ) )
			if ( cQAlias )->( VSO_AGCONF ) $ ("1/2")
				cConf := STR0037 // Confirmado
			Else
				cConf := STR0038 // Nao Confirmado
			Endif
			aadd(aLevPesq,{	( cQAlias )->( VSO_STATUS ) , ;
							Transform(stod(( cQAlias )->( VSO_DATAGE )),"@D"),;
							Transform(( cQAlias )->( VSO_HORAGE ),"@R 99:99"),;
							( cQAlias )->( VSO_NUMBOX ),;
							VON->VON_CODPRO+" - "+VAI->VAI_NOMTEC,;
							Transform(( cQAlias )->( VSO_PLAVEI ),VV1->(X3PICTURE("VV1_PLAVEI"))),;
							( cQAlias )->( VSO_CODMAR )+" "+Alltrim(( cQAlias )->( VSO_MODVEI ))+" - "+VV2->VV2_DESMOD,;
							( cQAlias )->( VSO_GETKEY ),;
							( cQAlias )->( VSO_PROVEI )+" "+( cQAlias )->( VSO_LOJPRO )+" -  "+( cQAlias )->( VSO_NOMPRO ),;
							( cQAlias )->( VSO_FONPRO ),;
							( cQAlias )->( VSO_EMAIL ),;
							( cQAlias )->( VSO_NUMIDE ),;
							( cQAlias )->( VSO_FILIAL ) , "",;
							( cQAlias )->( VSO_NUMIDE ),;	//posicao 15
							cConf})	//posicao 16
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
		
	Next
	cFilAnt := cBkpFilAnt

EndIf
If len(aLevPesq) <= 0
	aadd(aLevPesq,{"","","","","","","","","","","","","","","",""})
	aAdd(aInconvAg,{ "" , "" , "" , "" })
EndIf
If nTp > 0
	oLstAgen:nAt := 1
	oLstAgen:SetArray(aLevPesq)
	oLstAgen:bLine := { || {IIF(aLevPesq[oLstAgen:nAt,1]=="1",oVerd,IIF(aLevPesq[oLstAgen:nAt,1]=="2",oazul,IIF(aLevPesq[oLstAgen:nAt,1]=="3",opret,IIF(aLevPesq[oLstAgen:nAt,1]=="4",oVerm,IIF(aLevPesq[oLstAgen:nAt,1]=="5",olara,obran))))),;
	aLevPesq[oLstAgen:nAt,13],;
	aLevPesq[oLstAgen:nAt,2],;
	aLevPesq[oLstAgen:nAt,3],;
	aLevPesq[oLstAgen:nAt,4],;
	aLevPesq[oLstAgen:nAt,16],;
	aLevPesq[oLstAgen:nAt,5],;
	aLevPesq[oLstAgen:nAt,6],;
	aLevPesq[oLstAgen:nAt,7],;
	aLevPesq[oLstAgen:nAt,8],;
	aLevPesq[oLstAgen:nAt,9],;
	aLevPesq[oLstAgen:nAt,10],;
	aLevPesq[oLstAgen:nAt,11]}}
	oLstAgen:SetFocus()
	oLstAgen:Refresh()
	FS_LEVINC(aLevPesq[oLstAgen:nAt,15],1)
EndIf

cFilAnt := cFilSlv
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSREG³ Autor ³  Rafael Goncalves     ³ Data ³ 15 01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posiciona no registro na janela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSREG(nPos)
Default nPos := 0
if nPos > 0 .and. Len(aLevPesq) >= nPos
	//posiciona no registro
	DbSelectArea("VSO")      //pos 13
	DbSetOrder(1)//NUM.ATENDIMENTO
	DbSeek(aLevPesq[nPos,13]+ aLevPesq[nPos,12])//filial + numero atendimento
endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVINC³ Autor ³  Rafael Goncalves     ³ Data ³ 15 01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Inconvenientes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVINC(cNumVSO,nTipo)
Local cQuery2 := ""
Local cAliasVST := "SQLVST"
Default nTipo := 0
aInconvAg := {}
//LEVANTAMENTO DAS INFORMACOES
cQuery2 := "SELECT VST.VST_GRUINC , VST.VST_CODINC , VST.VST_DESINC FROM "+RetSqlName("VST")+" VST WHERE "
cQuery2 += "VST.VST_FILIAL='"+xFilial("VST")+"' AND VST.VST_TIPO='3' AND VST.VST_CODIGO='"+cNumVSO+"' AND VST.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAliasVST, .F., .T. )
// 1o Elemento - Grupo Inconveniente
// 2o Elemento - Codigo Inconveniente
// 3o Elemento - Descricao  Inconveniente
While ( cAliasVST )->(!Eof())
	aadd(aInconvAg,{ ( cAliasVST )->(VST_GRUINC) , ( cAliasVST )->(VST_CODINC) , ( cAliasVST )->(VST_DESINC) })
	( cAliasVST )->(DbSkip())
Enddo
( cAliasVST )->(dbCloseArea())
If Len(aInconvAg)<=0
	aAdd(aInconvAg,{ "" , "" , "" , "" })
EndIf
If nTipo <> 0
	oInconvAg:nAt := 1
	oInconvAg:SetArray(aInconvAg)
	oInconvAg:bLine := { || {  aInconvAg[oInconvAg:nAt,1] ,;
	aInconvAg[oInconvAg:nAt,2] ,;
	aInconvAg[oInconvAg:nAt,3]}}
	oInconvAg:Refresh()
EndIf
Return
