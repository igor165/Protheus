// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "fileio.ch"
#Include "protheus.ch"
#Include "VEICC530.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICC530 ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Contatos por Vendedor                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC530()

Local lVC1ESTVEI := ( VC1->(FieldPos("VC1_ESTVEI")) > 0 )
Local cQAlias := "SQLVC1"
Local cQuery  := ""
Local oxVerm
Local oxVerd
Local oxAzul
Local ocert,oerr,onfeit
Local nErr   := 0
Local nCert  := 0
Local nnfeit := 0
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lVerOutros := .t.
Local cVendedor  := ""
Private overde   := LoadBitmap( GetResources(), "BR_verde" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oazul:= LoadBitmap( GetResources(), "BR_azul")
Private oDlg,oLbInicial,oLbFinal,cObserv,cSitVei,cMarca,cModelo,nQtd,dData,cPrePag
Private oDlgPend,oLbTexto,aVetor:={}

If PERGUNTE("VCC530",.t.)

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox
	aAdd( aObjects, { 0 , 100 , .T. , .F. } ) // Rodape
	aPos := MsObjSize( aInfo, aObjects )

	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	cVendedor := VAI->VAI_CODVEN
	If ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )
		If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	   		lVerOutros := .f.
		EndIf
	EndIf

	cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_DATVIS , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_OCOMEM , VC1.VC1_CODMAR , VC1.VC1_QTDINT , VC1.VC1_DATINT , "
	If lVC1ESTVEI
		cQuery += "VC1.VC1_ESTVEI , "
	EndIf
	cQuery += "SA1.A1_NOME , VCA.VCA_DESABO , VC0.VC0_DESCON , VV2.VV2_DESMOD , VC7.VC7_DESPAG FROM "+RetSqlName("VC1")+" VC1 "
	cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC1.VC1_CODCLI AND SA1.A1_LOJA=VC1.VC1_LOJA AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VCA")+" VCA ON ( VCA.VCA_FILIAL='"+xFilial("VCA")+"' AND VCA.VCA_CODABO=VC1.VC1_CODABO AND VCA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VC0")+" VC0 ON ( VC0.VC0_FILIAL='"+xFilial("VC0")+"' AND VC0.VC0_TIPCON=VC1.VC1_TIPCON AND VC0.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VC1.VC1_CODMAR AND VV2.VV2_MODVEI=VC1.VC1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VC7")+" VC7 ON ( VC7.VC7_FILIAL='"+xFilial("VC7")+"' AND VC7.VC7_PREPAG=VC1.VC1_PREPAG AND VC7.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODVEN='"+MV_PAR01+"' AND VC1.D_E_L_E_T_=' ' "
	If !lVerOutros .and. !Empty(cVendedor)
		cQuery += "AND VC1.VC1_CODVEN='"+cVendedor+"' "
	EndIf
	cQuery += "ORDER BY VC1.VC1_DATVIS DESC , VC1.VC1_DATAGE DESC , VC1.VC1_CODCLI , VC1.VC1_LOJA "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		Aadd(aVetor,{( cQAlias )->( VC1_TIPAGE ),;
						stod(( cQAlias )->( VC1_DATAGE )),;
						stod(( cQAlias )->( VC1_DATVIS )),;
						( cQAlias )->( VC1_CODCLI )+"-"+( cQAlias )->( VC1_LOJA ),;
						left(( cQAlias )->( A1_NOME ),25),;
						( cQAlias )->( VCA_DESABO ),;
						( cQAlias )->( VC0_DESCON ),;
						( cQAlias )->( VC1_OCOMEM ),;
						( cQAlias )->( VC1_CODMAR ),;
						( cQAlias )->( VV2_DESMOD ),;
						( cQAlias )->( VC1_QTDINT ),;
						stod(( cQAlias )->( VC1_DATINT )),;
						( cQAlias )->( VC7_DESPAG ),;
						IIf(lVC1ESTVEI.and.!Empty(( cQAlias )->( VC1_CODMAR )),X3CBOXDESC("VC1_ESTVEI",IIf(!Empty(( cQAlias )->( VC1_ESTVEI )),( cQAlias )->( VC1_ESTVEI ),"2")),"")})
		If ( cQAlias )->( VC1_DATVIS ) == ( cQAlias )->( VC1_DATAGE )
			nCert++
		EndIf
		If ( cQAlias )->( VC1_DATVIS ) # ( cQAlias )->( VC1_DATAGE ) .and. !Empty(( cQAlias )->( VC1_DATVIS ))
			nErr++
		EndIf
		If Empty(( cQAlias )->( VC1_DATVIS ))
			nnfeit++
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	DbSelectArea("VC1")

	If Len(aVetor) <= 0
		Help(" ",1,"NAOEXISTIT")
		Return
	EndIf
	
	cTitulo := STR0002+": "+MV_PAR01+" - "+MV_PAR02 //"Contatos p/ Vendedor "
	
	DEFINE MSDIALOG oDlgPend TITLE cTitulo From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STATUS

	@ aPos[1,1],aPos[1,2] LISTBOX oLbTexto FIELDS HEADER "",;
													STR0003,; //"Tp Agenda"
													STR0004,; //"Dt Agenda"
													STR0005,; //"Dt Visita"
													STR0006,; //"Cod Cliente"
													STR0007,; //"Nome"
													STR0008,; //"Tipo Abordagem"
													STR0001; //"Tipo de Contato"
													COLSIZES 10,40,40,40,40,100,60,60 SIZE aPos[1,4]-3,aPos[1,3] OF oDlgPend PIXEL ON CHANGE FS_OBSVC530()
	
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || {IIf(!Empty(aVetor[oLbTexto:nAt,3]),IIf(Dtoc(aVetor[oLbTexto:nAt,2]) == Dtoc(aVetor[oLbTexto:nAt,3]),overde,overmelho),oazul ),;
							aVetor[oLbTexto:nAt,1] ,;
							Dtoc(aVetor[oLbTexto:nAt,2]) ,;
							Dtoc(aVetor[oLbTexto:nAt,3]) ,;
							aVetor[oLbTexto:nAt,4] ,;
							aVetor[oLbTexto:nAt,5] ,;
							aVetor[oLbTexto:nAt,6] ,;
							aVetor[oLbTexto:nAt,7] }}
	
	@ aPos[2,1]+012,aPos[2,2] GET oObserv VAR cObserv OF oDlgPend MEMO SIZE aPos[2,4]-3,025 PIXEL READONLY MEMO
	
	@ aPos[2,1]+040,aPos[2,2] TO aPos[2,1]+070,aPos[2,4] LABEL STR0009 OF oDlgPend PIXEL //"Interesse"
	
	@ aPos[2,1]+055,aPos[2,2]+003 MSGET oSitVei VAR cSitVei PICTURE "@!" SIZE 080,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+088 SAY STR0010 OF oDlgPend PIXEL COLOR CLR_BLUE //"Marca"
	@ aPos[2,1]+055,aPos[2,2]+088 MSGET oMarca VAR cMarca PICTURE "@!" SIZE 075,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+168 SAY STR0011 OF oDlgPend PIXEL COLOR CLR_BLUE //"Modelo"
	@ aPos[2,1]+055,aPos[2,2]+168 MSGET oModelo VAR cModelo PICTURE "@!" SIZE 100,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+273 SAY STR0012 OF oDlgPend PIXEL COLOR CLR_BLUE //"Qtd"
	@ aPos[2,1]+055,aPos[2,2]+273 MSGET oQtd VAR nQtd PICTURE "999" SIZE 20,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+299 SAY STR0013 OF oDlgPend PIXEL COLOR CLR_BLUE //"Data"
	@ aPos[2,1]+055,aPos[2,2]+299 MSGET oData VAR dData PICTURE "@D" SIZE 43,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+347 SAY STR0014 OF oDlgPend PIXEL COLOR CLR_BLUE //"Pref Pagto"
	@ aPos[2,1]+055,aPos[2,2]+347 MSGET oPrePag VAR cPrePag PICTURE "@!" SIZE 80,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	
	@ aPos[2,1]+080,001 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1]+079,010 MSGET oErr VAR nErr PICTURE "@!" SIZE 20,3 OF oDlg PIXEL COLOR CLR_BLUE when .f.
	@ aPos[2,1]+080,032 SAY STR0015 SIZE 130,40 OF oDlg  PIXEL COLOR CLR_BLUE //"Contatos realizados fora da data agendada "
	
	@ aPos[2,1]+080,151 BITMAP oxVerd RESOURCE "BR_verde" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1]+079,160 MSGET oCert VAR nCert PICTURE "@!" SIZE 20,3 OF oDlg PIXEL COLOR CLR_BLUE when .f.
	@ aPos[2,1]+080,182 SAY STR0016 OF oDlg PIXEL COLOR CLR_BLUE //"contatos realizados na data agendada"
	
	@ aPos[2,1]+080,301 BITMAP oxAzul RESOURCE "BR_azul" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1]+079,310 MSGET oNfeit VAR nnFeit PICTURE "@!" SIZE 20,3 OF oDlg PIXEL COLOR CLR_BLUE when .f.
	@ aPos[2,1]+080,332 SAY STR0017 OF oDlg  PIXEL COLOR CLR_BLUE //"Contatos ainda nao realizados"
	
	ACTIVATE MSDIALOG oDlgPend ON INIT EnchoiceBar(oDlgPend,{|| nOpca := 1,(oDlgPend:End())},{|| nOpca := 0,(oDlgPend:End())})
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBSVC530³ Autor ³  Fabio               ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Observacoes MEMO / variaveis tela                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSVC530()
cObserv := MSMM(aVetor[oLbTexto:nAt,8],47)
cSitVei := aVetor[oLbTexto:nAt,14]
cMarca  := aVetor[oLbTexto:nAt,09]
cModelo := aVetor[oLbTexto:nAt,10]
nQtd    := aVetor[oLbTexto:nAt,11]
dData   := aVetor[oLbTexto:nAt,12]
cPrePag := aVetor[oLbTexto:nAt,13]
oObserv:Refresh()
oSitVei:Refresh()
oMarca:Refresh()
oModelo:Refresh()
oQtd:Refresh()
oData:Refresh()
oPrePag:Refresh()
Return