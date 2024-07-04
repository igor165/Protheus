// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 11     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "OFIOC450.ch"

Static cPARGVei := left(GetNewPar("MV_GRUVEI","VEI ")+space(4),4) // Grupo do Produto Veiculo
Static cPARGSrv := left(GetNewPar("MV_GRUSRV","SRVC")+space(4),4) // Grupo do Produto Servico
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC450 ³ Autor ³  Thiago               ³ Data ³ 28/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Avancada Ordem de Servico				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC450()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}//
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0 //
Local nTam :=0 //controla posicao da legenda na tela
Local cCbStat := space(10)
Local cFilFtr := space(len(SA1->A1_FILIAL))
Local aCbStat :={STR0001,STR0002,STR0003,STR0004,STR0005}
Local dDatIni := ctod("01/"+StrZero(Month(dDataBase),2)+"/"+Substr(StrZero(Year(dDataBase),4),3,2))//ctod("")
Local dDatFim := dDataBase//ctod("")
Local cCodCli := space(Len(SA1->A1_COD))
Local cLojCli := space(Len(SA1->A1_LOJA))
Local cNomCli := space(21)
Local cCodVend:= space(Len(SA3->A3_COD))
Local aVetEmp	:= {}
Private cCodPec := space(Len(SB1->B1_COD))		//codigo da peca ou servico
Private cCodSrv := space(50)		//codigo da peca ou servico
Private cRegSel := 0
Private cChassi := space(Len(VV1->VV1_CHASSI))
Private lNomCli := .f.
Private aListOS := {}
Private cNomVen := space(21)
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )		// "Aberta"
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO")		// "Fechada"
Private oazul := LoadBitmap( GetResources(), "BR_azul")			// "Libarada"
Private opret := LoadBitmap( GetResources(), "BR_preto")		// "Cancelada"
Private cGruPec := space(Len(SB1->B1_GRUPO))	//codigo da peca ou servico

aadd(aListOS,{"","","","","","","","" ,"",ctod(""),0,"",""})

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 44 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 80 , .T. , .T. } )  //list box superior
AAdd( aObjects, { 01,120 , .T. , .F. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oPesqOS TITLE STR0006 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME PIXEL  //Pesquisa Avancada
oPesqOS:lEscClose := .F.
//Objeto 01 cabecalho
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0007 OF oPesqOS PIXEL  //Filtro

@ aPosObj[1,1]+9,aPosObj[1,2]+4 SAY oDat VAR STR0008 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE     //Status
@ aPosObj[1,1]+7,aPosObj[1,2]+25 MSCOMBOBOX oCbStat VAR cCbStat ITEMS aCbStat  SIZE 95,08 OF oPesqOS PIXEL //COLOR CLR_HBLUE //WHEN ( lOk ) ON CHANGE(lOkM:=.t.)//VALID lSair .or. FS_VALID("MDE")
@ aPosObj[1,1]+9,aPosObj[1,2]+127 SAY oFil VAR STR0009 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE 	//Filial
@ aPosObj[1,1]+7,aPosObj[1,2]+145 MSGET oFilFtr VAR cFilFtr  F3 "SM0" SIZE 10,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+9,aPosObj[1,2]+220 SAY oChass VAR STR0010 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Veiculo
@ aPosObj[1,1]+7,aPosObj[1,2]+240 MSGET oChassi VAR cChassi PICTURE "@!" F3 "VV1" VALID (FG_POSVEI("cChassi",),oChassi:Refresh()) SIZE 95,08 OF oPesqOS PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+21,aPosObj[1,2]+4 SAY oData VAR STR0011 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE 	//Data
@ aPosObj[1,1]+19,aPosObj[1,2]+25 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+73 SAY oDatate VAR STR0012 SIZE 150,08 OF oPesqOS PIXEL COLOR CLR_BLUE //ate
@ aPosObj[1,1]+19,aPosObj[1,2]+83 MSGET odatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 45,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+132 SAY oPecItem VAR STR0013 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE 	//Peca
@ aPosObj[1,1]+19,aPosObj[1,2]+152 MSGET oCodPec VAR cCodPec  SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+236 SAY oPecItem VAR STR0014 SIZE 50,08 OF oPesqOS PIXEL COLOR CLR_BLUE 	//Peca
@ aPosObj[1,1]+19,aPosObj[1,2]+258 MSGET oCodSrv VAR cCodSrv  SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+21,aPosObj[1,2]+335 SAY oRegSel VAR str(cRegSel)+" "+STR0015 SIZE 100,08 OF oPesqOS PIXEL COLOR CLR_BLUE  //registro(s) filtrado(s)

@ aPosObj[1,1]+33,aPosObj[1,2]+004 SAY oClient VAR STR0016 SIZE 20,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Cliente
@ aPosObj[1,1]+31,aPosObj[1,2]+025 MSGET oCodCli VAR cCodCli F3 "VSA" SIZE 32,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+31,aPosObj[1,2]+065 MSGET oLojCli VAR cLojCli SIZE 10,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+32,aPosObj[1,2]+081 SAY oSep VAR "-" SIZE 5,08 OF oPesqOS PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+31,aPosObj[1,2]+088 MSGET oNomCli VAR cNomCli PICTURE "@!" SIZE 100,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+31,aPosObj[1,2]+190 CHECKBOX oNoCli VAR lNomCli PROMPT "" OF oPesqOS SIZE 40,10 PIXEL
@ aPosObj[1,1]+33,aPosObj[1,2]+199 SAY opNome VAR ("-"+STR0017) SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Parte Nome
@ aPosObj[1,1]+33,aPosObj[1,2]+238 SAY oVend VAR STR0018 SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLUE //Vendedor
@ aPosObj[1,1]+31,aPosObj[1,2]+265 MSGET oCodVend VAR cCodVend  F3 "VAI" VALID FS_CONSULT(cCodVend) SIZE 30,08 OF oPesqOS PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+32,aPosObj[1,2]+303 SAY oSepVend VAR "-" SIZE 5,08 OF oPesqOS PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+31,aPosObj[1,2]+309 MSGET oNomVen VAR cNomVen PICTURE "@!" SIZE 100,08 OF oPesqOS PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+07,aPosObj[1,4]-50 BUTTON oFintra PROMPT STR0019 OF oPesqOS SIZE 50,10 PIXEL ACTION (FS_OC450(cCbStat,cFilFtr,cChassi,dDatIni,dDatFim,cCodCli,cLojCli,cNomCli,lNomCli,cCodVend,cNomVen)) //FILTRAR
@ aPosObj[1,1]+19,aPosObj[1,4]-50 BUTTON oLimFil PROMPT OemToAnsi(STR0020) OF oPesqOS SIZE 50,10 PIXEL ACTION (FS_LIMFIL(@cCbStat,@aCbStat,@dDatIni,@dDatFim,@cFilFtr,@cCodCli,@cLojCli,@cNomCli,@cCodVend,@cNomVen,@aListOS,@cCodSrv))//oPesqOS:End()
@ aPosObj[1,1]+31,aPosObj[1,4]-50 BUTTON oSair PROMPT STR0021 OF oPesqOS SIZE 50,10 PIXEL ACTION oPesqOS:End() // SAIR

@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLstAgen FIELDS HEADER "",STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0030,STR0031,STR0032;
COLSIZES 10,80,35,43,40,15,100,35,25,50,50,30 SIZE aPosObj[2,4]-2,aPosObj[2,3]+40 OF oPesqOS PIXEL ON DBLCLICK (FS_POSVO1(aListOS[oLstAgen:nAt,3],aListOS[oLstAgen:nAt,2]))
oLstAgen:SetArray(aListOS)

oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="A",oVerd,IIF(aListOS[oLstAgen:nAt,1]=="F",oVerm,IIF(aListOS[oLstAgen:nAt,1]=="D",oazul,opret))),;
aListOS[oLstAgen:nAt,2],;  //Filial
aListOS[oLstAgen:nAt,3],;  //Nro O.S.
aListOS[oLstAgen:nAt,4],;  //Proprietario
aListOS[oLstAgen:nAt,5],;  //Loja
aListOS[oLstAgen:nAt,6],;  //Nome Cliente
aListOS[oLstAgen:nAt,7],;  //Chassi
aListOS[oLstAgen:nAt,8],;  //Placa
transform(aListOS[oLstAgen:nAt,9],"@D"),; //Data Abertura
transform(aListOS[oLstAgen:nAt,10],"@E 99:99"),; //Hora Abertura
aListOS[oLstAgen:nAt,11],; //Consultor
aListOS[oLstAgen:nAt,12]}} //Nome Consultor
nTam := ( aPosObj[3,4] / 4 ) //varaivel que armazena o resutlado da divisao da tela.
@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*0)+((((nTam*1)-(nTam*0))-90)/2) BITMAP OXverde RESOURCE "BR_verde" OF oPesqOS PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*0)+((((nTam*1)-(nTam*0))-80)/2)+10 SAY STR0002 SIZE 40,08 OF oPesqOS PIXEL COLOR CLR_BLACK	//Aberto

@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*1)+((((nTam*2)-(nTam*1))-90)/2) BITMAP oXVerm RESOURCE "BR_VERMELHO" OF oPesqOS PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*1)+((((nTam*2)-(nTam*1))-80)/2)+10 SAY STR0003 SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK	//Fechado

@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*2)+((((nTam*3)-(nTam*2))-90)/2) BITMAP oXazul RESOURCE "BR_azul" OF oPesqOS PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*2)+((((nTam*3)-(nTam*2))-80)/2)+10 SAY STR0004 SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK	//Liberada

@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*3)+((((nTam*4)-(nTam*3))-90)/2) BITMAP oXpret RESOURCE "BR_preto" OF oPesqOS PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+100,aPosObj[3,2]+003+(nTam*3)+((((nTam*4)-(nTam*3))-80)/2)+10 SAY STR0033 SIZE 80,08 OF oPesqOS PIXEL COLOR CLR_BLACK //Cancalado

ACTIVATE MSDIALOG oPesqOS

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OC450 | Autor ³ Thiago                ³Data  ³ 28/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza o levantamento das informacoes                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1-Opcao do combo - "" = todas                              ³±±
±±³          ³ 2-Filial                                                   ³±±
±±³          ³ 3-Data Inicial                                             ³±±
±±³          ³ 4-Data Final                                               ³±±
±±³          ³ 5-Codigo do cliente                                        ³±±
±±³          ³ 6-Loja do Cliente                                          ³±±
±±³          ³ 7-Nome do cliente                                          ³±±
±±³          ³ 8-Codigo do Vendedo                                        ³±±
±±³          ³ 8-Nome do vendedor                                         ³±±
±±³          ³ 9-Chassi do veiculo                                        ³±±
±±³          ³10-Se mostra orcamento reservados ou nao / "" indiferente   ³±±
±±³          ³11-Tipo de orcamento a ser filtrado                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OC450(cCbStat,cFilFtr,cChassi,dDatIni,dDatFim,cCodCli,cLojCli,cNomCli,lNomCli,cCodVend,cNomVen)
Local cQAlVO1 	:= "SQLVO1"
Local cQuery	:= ""
Local cResSql 	:= "="
Local aVetEmp	:= {}
Local ni		:= 0 //resultado ascan
Local aFilAtu    := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local cBkpFilAnt:= cFilAnt
Local nCont := 0 
Local cPesqFil  := ""
Default cCbStat := "" 	//Status da ordem de servico
Default cFilFtr	:= "" 	// Filial da orde de servico
Default dDatIni	:= ctod("")//data Inicial
Default dDatFim := ctod("")//Ddata Final
Default cCodCli	:="" 	//Codigo Cliente
Default cLojCli	:="" 	//loja cliente
Default cCodVend:=""	//codigo vendedor
Default cNomCli :=""	//nome cliente
Default cNomVen :="" 	//nome vendedor
Default cChassi :=""	//Chassi do veiculo
if !Empty(cCodPec)
	FS_PECA()
Endif

if !Empty(cCodSrv)
	FS_SRV()
Endif

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd( aVetEmp, { cFilAnt, FWFilialName() })
Next
cFilAnt := cBkpFilAnt

cRegSel := 0
aListOrc:={}

if cCbStat == STR0002
	cStaOS := "A"
Elseif  cCbStat == STR0003
	cStaOS := "F"
Elseif cCbStat == STR0004
	cStaOS := "D"
Elseif cCbStat == STR0005
	cStaOS := "C"
Else
	cStaOS := "T"
Endif
cQuery := "SELECT VO1.VO1_FILIAL,VO1.VO1_STATUS,VO1.VO1_NUMOSV,VO1.VO1_PROVEI,VO1.VO1_LOJPRO,VO1.VO1_CHASSI,VO1.VO1_PLAVEI,VO1.VO1_DATABE,VO1.VO1_HORABE,VO1.VO1_FUNABE "
cQuery += "FROM "+RetSqlName("VO1")+" VO1 "
cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON (SA1.A1_FILIAL='"+xFilial("SA1")+"' AND VO1.VO1_PROVEI=SA1.A1_COD AND VO1.VO1_LOJPRO=SA1.A1_LOJA AND SA1.D_E_L_E_T_=' ') "
cQuery += "JOIN "+RetSqlName("VAI")+" VAI ON (VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VO1.VO1_FUNABE AND VAI.D_E_L_E_T_=' ') "
If cGruPec == cPARGSrv
	If !Empty(cCodPec) //Servico
		cQuery += "JOIN "+RetSqlName("VO4")+" VO4 ON (VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NUMOSV=VO1.VO1_NUMOSV AND VO4.VO4_CODSER='"+cCodPec+"' AND VO4.D_E_L_E_T_=' ') "
	EndIF
ElseIf (!cGruPec==cPARGSrv .and. !cGruPec==cPARGVei)//se o grupo for diferente de servico e diferente de veiculo eh peca.
	If !Empty(cCodPec) //Peca
		DBSelectArea("SB1")
		DbSetOrder(1)
		DBSeek(xFilial("SB1")+cCodPec)
		cQuery += "JOIN "+RetSqlName("VO3")+" VO3 ON (VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND VO3.VO3_NUMOSV=VO1.VO1_NUMOSV AND VO3.VO3_CODITE='"+SB1->B1_CODITE+"' AND VO3.VO3_GRUITE='"+SB1->B1_GRUPO+"'  AND VO3.D_E_L_E_T_=' ') "
	EndIF
EndIf
If !Empty(cCodSrv) //Servico
	DBSelectArea("VO6")
	dbSetOrder(4)
	DBSeek(xFilial("VO6")+Alltrim(cCodSrv))
	cQuery += "JOIN "+RetSqlName("VO4")+" VO4 ON (VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NUMOSV=VO1.VO1_NUMOSV AND VO4.VO4_CODSER='"+VO6->VO6_CODSER+"' AND VO4.D_E_L_E_T_=' ') "
EndIf
cQuery += "WHERE "
if cStaOS <> "T"
	cQuery += "VO1.VO1_STATUS='"+cStaOS+"' AND "
Endif
If !Empty(cFilFtr)
	cQuery += "VO1.VO1_FILIAL='"+cFilFtr+"' AND "
Endif
If !Empty(cChassi)
	cQuery += "VO1.VO1_CHASSI='"+cChassi+"' AND "
EndIF
If !Empty(dDatIni+dDatFim)
	cQuery += "VO1.VO1_DATABE>='"+dtos(dDatIni)+"' AND VO1.VO1_DATABE<='"+dtos(dDatFim)+"' AND "
EndIF
If !Empty(cCodCli+cLojCli)
	cQuery += "VO1.VO1_PROVEI='"+cCodCli+"' AND VO1.VO1_LOJPRO='"+cLojCli+"' AND "
elseif !Empty(cNomCli)
	If lNomCli//filtra contido nome do cliente
		cQuery += "SA1.A1_NOME LIKE '%"+ AllTrim(cNomCli)+"%' AND "
	Else//filtra pelo inicio do nome do cliente
		cQuery += "SA1.A1_NOME LIKE '"+ AllTrim(cNomCli)+"%' AND "
	EndIF
EndIf
If !Empty(cCodVend)
	cQuery += "VO1.VO1_FUNABE='"+cCodVend+"' AND "
Else
	If !Empty(cNomVen)
		cQuery += "VAI.VAI_NOMTEC LIKE '%"+Alltrim(cNomVen)+"%' AND "
	EndIF
Endif
cQuery += "VO1.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO1, .F., .T. )

aListOS := {}
Do While !( cQAlVO1 )->( Eof() )
	ni := aScan(aVetEmp,{|x| Alltrim(x[1]) == Alltrim(( cQAlVO1 )->( VO1_FILIAL )) })//pega a posicao da filial no array
	If ni > 0
		cPesqFil := aVetEmp[ni,2]
	Else
		cPesqFil := ""
	EndIf
	if Len(aListOS) == 1 .and. Empty(aListOS[1,3])
		aListOS := {}
	Endif
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+( cQAlVO1 )->( VO1_PROVEI ) + ( cQAlVO1 )->( VO1_LOJPRO ))
	dbSelectArea("VAI")
	dbSetOrder(1)
	dbSeek(xFilial("VAI")+( cQAlVO1 )->( VO1_FUNABE ))
	Aadd(aListOS,{( cQAlVO1 )->( VO1_STATUS ),( cQAlVO1 )->( VO1_FILIAL )+" - " + cPesqFil,( cQAlVO1 )->( VO1_NUMOSV ) , ( cQAlVO1 )->( VO1_PROVEI ) , ( cQAlVO1 )->( VO1_LOJPRO ) , SA1->A1_NOME, ( cQAlVO1 )->( VO1_CHASSI ) , ( cQAlVO1 )->( VO1_PLAVEI ) , Transform(stod(( cQAlVO1 )->( VO1_DATABE )),"@D") ,Transform(( cQAlVO1 )->( VO1_HORABE ),"@R 99:99"), ( cQAlVO1 )->( VO1_FUNABE),VAI->VAI_NOMTEC } )
	cRegSel += 1
	( cQAlVO1 )->( DbSkip() )
EndDo
( cQAlVO1 )->( dbCloseArea() )

If Len(aListOS) <= 0
	aadd(aListOS,{"","","","","","","","" ,"",ctod(""),0,"",""})
EndIF
oLstAgen:SetArray(aListOS)
oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="A",oVerd,IIF(aListOS[oLstAgen:nAt,1]=="F",oVerm,IIF(aListOS[oLstAgen:nAt,1]=="D",oazul,opret))),;
aListOS[oLstAgen:nAt,2],;  //Filial
aListOS[oLstAgen:nAt,3],;  //Nro O.S.
aListOS[oLstAgen:nAt,4],;  //Proprietario
aListOS[oLstAgen:nAt,5],;  //Loja
aListOS[oLstAgen:nAt,6],;  //Nome Cliente
aListOS[oLstAgen:nAt,7],;  //Chassi
aListOS[oLstAgen:nAt,8],;  //Placa
transform(aListOS[oLstAgen:nAt,9],"@D"),; //Data Abertura
transform(aListOS[oLstAgen:nAt,10],"@E 99:99"),; //Hora Abertura
aListOS[oLstAgen:nAt,11],; //Consultor
aListOS[oLstAgen:nAt,12]}} //Nome Consultor
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONSULT³ Autor ³  Thiago               ³ Data ³ 28/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Vendedor                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONSULT(cCodVend)
if !Empty(cCodVend)
	dbSelectArea("VAI")
	dbSetOrder(1)
	if !dbSeek(xFilial("VAI")+cCodVend)
		Return(.f.)
	Else
		cNomVen := VAI->VAI_NOMTEC
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONSULT³ Autor ³  Thiago               ³ Data ³ 28/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ LIMPA O FILTRO SELECIONADO                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMFIL(cCbStat,aCbStat,dDatIni,dDatFim,cFilFtr,cCodCli,cLojCli,cNomCli,cCodVend,cNomVen,aListOS,cCodSrv)

cCbStat := "Todos"
dDatIni := ctod("01/"+StrZero(Month(dDataBase),2)+"/"+Substr(StrZero(Year(dDataBase),4),3,2))//ctod("")
dDatFim := dDataBase//ctod("")
cFilFtr := space(len(SA1->A1_FILIAL))
cCodCli := space(Len(SA1->A1_COD))
cLojCli := space(Len(SA1->A1_LOJA))
cNomCli := space(21)
cCodPec := space(Len(SB1->B1_COD))		//codigo da peca ou servico
cGruPec := space(Len(SB1->B1_GRUPO))	//codigo da peca ou servico
cChassi := space(Len(VV1->VV1_CHASSI))
cRegSel := 0
cCodVend:= space(Len(VAI->VAI_CODTEC))
cNomVen := space(Len(VAI->VAI_NOMTEC))
cCodSrv := space(40)

aListOS:={}
aadd(aListOS,{"","","","","","","","" ,"",ctod(""),"",ctod(""),"","","","",""})

oLstAgen:SetArray(aListOS)
oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="A",oVerd,IIF(aListOS[oLstAgen:nAt,1]=="F",oVerm,IIF(aListOS[oLstAgen:nAt,1]=="D",oazul,opret))),;
aListOS[oLstAgen:nAt,2],;  //Filial
aListOS[oLstAgen:nAt,3],;  //Nro O.S.
aListOS[oLstAgen:nAt,4],;  //Proprietario
aListOS[oLstAgen:nAt,5],;  //Loja
aListOS[oLstAgen:nAt,6],;  //Nome Cliente
aListOS[oLstAgen:nAt,7],;  //Chassi
aListOS[oLstAgen:nAt,8],;  //Placa
transform(aListOS[oLstAgen:nAt,9],"@D"),; //Data Abertura
transform(aListOS[oLstAgen:nAt,10],"@E 99:99"),; //Hora Abertura
aListOS[oLstAgen:nAt,11],; //Consultor
aListOS[oLstAgen:nAt,12]}} //Nome Consultor
oLstAgen:Refresh()
oCbStat:Refresh()
oPesqOS:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PECA  | Autor ³ Rafael Goncalves      ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ pesquisa iten no SB1 e depois no VB1                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PECA()
Local cQuery   := ""
Local cQAlSB1  := "SQLSB1"
Local aPecSel  := {}
Local nPos	   := 0

dbSelectArea("VAI")
If Vazio(cCodPec)
	Return(.t.)
EndIf

ProcRegua( RecCount() )

If !Empty(cCodPec)
	IncProc(OemtoAnsi(STR0034)) //Levantando informacoes
	cQuery := "SELECT SB1.B1_COD , SB1.B1_DESC , SB1.B1_CODITE , VB1.VB1_KEYALT , SB1.B1_GRUPO FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "LEFT JOIN "+RetSqlName("VB1")+" VB1 ON (VB1.VB1_FILIAL='"+xFilial("VB1")+"' AND VB1.VB1_COD = SB1.B1_COD AND VB1.D_E_L_E_T_=' ') "
	cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND ("
	cQuery += "SB1.B1_COD LIKE '%"+ AllTrim(UPPER(cCodPec))+"%' OR "		//codigo
	cQuery += "SB1.B1_CODITE LIKE '%"+ AllTrim(UPPER(cCodPec))+"%' OR "	//codite
	cQuery += "VB1.VB1_KEYALT LIKE '%" + AllTrim(UPPER(cCodPec)) + "%' OR "	//alternativo
	cQuery += "SB1.B1_DESC LIKE '%"+ AllTrim(UPPER(cCodPec))+"%') AND "		//descricao
	cQuery += "SB1.B1_GRUPO<>'"+cPARGVei+"' AND SB1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
	If !( cQAlSB1 )->( Eof() )
		( cQAlSB1 )->( DbGotop() )
		While !( cQAlSB1 )->( Eof() )
			nPos := 0
			nPos := aScan(aPecSel,{|x| x[1] == ( cQAlSB1 )->( B1_COD ) })
			if nPos <= 0
				AADD(aPecSel,{( cQAlSB1 )->( B1_COD ) , ( cQAlSB1 )->( B1_GRUPO ) , ( cQAlSB1 )->( B1_DESC ) , ( cQAlSB1 )->( B1_CODITE )	 , ( cQAlSB1 )->( VB1_KEYALT ) })
			EndIf
			IncProc(OemtoAnsi(STR0035)) //Carregando informacoes
			( cQAlSB1 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlSB1 )->( dbCloseArea() )
	
	If Len(aPecSel) > 1
		
		DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE OemToAnsi(STR0036) OF oMainWnd // Cadastros Encontrados
		@ 001,001 LISTBOX olBox2 FIELDS HEADER OemToAnsi(STR0037),; // Codigo Alternativo
		OemToAnsi(STR0038),; // Grupo
		OemToAnsi(STR0039),; // Cod. Item
		OemToAnsi(STR0040),; // Descricao
		OemToAnsi(STR0041);  // Alternativo
		COLSIZES 50,20,60,20,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox2:nAt, oDesVB1:END())
		olBox2:SetArray(aPecSel)
		olBox2:bLine := { || {  	aPecSel[olBox2:nAt,1] ,;
		aPecSel[olBox2:nAt,2] ,;
		aPecSel[olBox2:nAt,4] ,;
		aPecSel[olBox2:nAt,3] ,;
		aPecSel[olBox2:nAt,5] }}
		ACTIVATE MSDIALOG oDesVB1 CENTER
		
		If nPos != 0
			cCodPec:=aPecSel[nPos,1]
			cGruPec:=aPecSel[nPos,2]
		EndIf
	Elseif Len(aPecSel) = 1 // se encontrar somente 1 registro não exibe tela p
		cCodPec:=aPecSel[1,1]
		cGruPec:=aPecSel[1,2]
	EndIf
EndIf
oCodPec:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSVO1| Autor ³ Thiago                ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicionamento no VO1                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSVO1(cNumOS,cFilFtr) 
cFilFtr := substr(cFilFtr,1,FWSizeFilial())
DbSelectArea("VO1")
DbSetOrder(1)
DbSeek( cFilFtr + cNumOS )
oPesqOS:End()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SRV   | Autor ³ Thiago                ³Data  ³ 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Servico                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SRV()
Local cQuery   := ""
Local cQAlVO6 := "SQLVO6"
Local aPecSel  := {}
Local nPos	   := 0

dbSelectArea("VAI")
if Empty(cCodSrv)
	Return(.t.)
Endif

ProcRegua( RecCount() )

If !Empty(cCodSrv)
	IncProc(OemtoAnsi(STR0034)) //Levantando informacoes
	cQuery := "SELECT VO6.VO6_CODSER,VO6.VO6_GRUSER,VO6.VO6_DESSER  FROM "+RetSqlName("VO6")+" VO6 "
	cQuery += "WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND ("
	cQuery += "VO6.VO6_CODSER LIKE '%"+ AllTrim(UPPER(cCodSrv))+"%' OR "		//codigo
	cQuery += "VO6.VO6_DESSER LIKE '%"+ AllTrim(UPPER(cCodSrv))+"%') AND "		//descricao
	cQuery += "VO6.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO6, .F., .T. )
	If !( cQAlVO6 )->( Eof() )
		( cQAlVO6 )->( DbGotop() )
		While !( cQAlVO6 )->( Eof() )
			nPos := 0
			nPos := aScan(aPecSel,{|x| x[1] == ( cQAlVO6 )->( VO6_CODSER ) })
			if nPos <= 0
				AADD(aPecSel,{( cQAlVO6 )->( VO6_CODSER ) , ( cQAlVO6 )->( VO6_GRUSER ) , ( cQAlVO6 )->( VO6_DESSER ) })
			EndIf
			IncProc(OemtoAnsi(STR0035)) //Carregando informacoes
			( cQAlVO6 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlVO6 )->( dbCloseArea() )
	
	If Len(aPecSel) > 1
		
		DEFINE MSDIALOG oDesVB1 FROM 000,000 TO 015,080 TITLE OemToAnsi(STR0042) OF oMainWnd // Cadastros Encontrados
		@ 001,001 LISTBOX olBox2 FIELDS HEADER 	OemToAnsi(STR0038),; // Grupo
		OemToAnsi(STR0043),; // Cod. Item
		OemToAnsi(STR0040); // Descricao
		COLSIZES 50,20,60,20,65 SIZE 315,111 OF oDesVB1 PIXEL ON DBLCLICK (nPos := olBox2:nAt, oDesVB1:END())
		olBox2:SetArray(aPecSel)
		olBox2:bLine := { || {  	aPecSel[olBox2:nAt,2] ,;
		aPecSel[olBox2:nAt,1] ,;
		aPecSel[olBox2:nAt,3] }}
		ACTIVATE MSDIALOG oDesVB1 CENTER
		
		If nPos != 0
			cCodSrv:=aPecSel[nPos,1]
		EndIf
	Elseif Len(aPecSel) = 1 // se encontrar somente 1 registro não exibe tela p
		cCodSrv:=aPecSel[1,1]
	EndIf
EndIf

oCodPec:Refresh()

Return(.t.)
