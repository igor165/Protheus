#include "PROTHEUS.CH"       
#include "FINA085R.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ FINA085R ³ AUTOR ³ Percy Arias Horna     ³ DATA ³ 21.06.01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Efetivar a Ordem de Pago                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano  ³05/12/16³SERINN001-116³creación de tabla temporal con     ³±±
±±³              ³        ³      ³FWTemporaryTable en func Fina085R()       ³±±
±±³Alf. Medrano  ³05/12/16³SERINN001-116³se elimina la creacion del indice  ³±±
±±³              ³        ³      ³temporal cIndOrdPag                       ³±±
±±³Alf. Medrano  ³30/12/16³SERINN001-116³Merge 12.1.15 vs Main              ³±±
±±³José Glez     ³05/03/20³DMINA-7769   ³Actualización de Fuente y habilitar³±±
±±³              ³        ³      ³boton de filtro.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina085R()
Local nLastKey
Local aCampos := {}
Local aCpos   := {}
Local cFiltro	:=	''
Local nX 		:= 1
Local nI := 0,  nJ:= 0
Local aStruTRB  := {}

Private cMarcaEK := ""
Private lCheckMarca := .F.
Private cLibOrd := GetMV("MV_LIBORD")
Private blSeek := {|cAlias, nOrden, xKey, lSoft| (cAlias)->(dbSetOrder(nOrden)), (calias)->(Msseek(xkey, lSoft)) }
Private lLancPad70 := .F.
Private lLancPad71 := .F.
Private lDigita  
Private lAglutina
Private lGeraLanc
Private nHdlPrv    := 1
Private nTotalLanc := 0
Private cLoteCom   := ""
Private cArquivo   := ""
Private nLinha     := 2
Private lLanctOk
Private aRecnoSEK	:=	{}
Private oTmpTable 
Private aOrdem1 := {} 

nLastKey := 0

IF !Pergunte("FIN85R",.T.)
	Return
Endif

If nLastKey == 27
	Return
Endif

Private nDecs := MsDecimais(VAL(SEK->EK_MOEDA))
lDigita   	:= If(mv_par02==1,.T.,.F.)
lAglutina 	:= If(mv_par03==1,.T.,.F.)
lGeraLanc 	:= If(mv_par01==1,.T.,.F.)

aOrdem1 := {"EK_ORDPAGO"} 

If Select("TRB") <> 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf
dbSelectArea("SEK")
aStruTRB := dbStruct()

If Valtype(aCampos) == "A" .And. Len(aCampos) == 0
		AADD(aCampos,{ "MARKA"     , "C", 2, 0 })
	For nj := 1 To Len(aStruTRB)
		if aStruTRB[nj,1] $ "|EK_ORDPAGO|EK_FORNECE|EK_LOJA|EK_VALOR|EK_DOCREC|EK_DTDIGIT|EK_DTREC|EK_MOEDA"
			aAdd(aCampos , {aStruTRB[nj,1], aStruTRB[nj,2], aStruTRB[nj,3], aStruTRB[nj,4]})
		EndIf
	Next
EndIf

oTmpTable := FWTemporaryTable():New("TRB") 
oTmpTable:SetFields( aCampos )
oTmpTable:AddIndex('I1', aOrdem1)
oTmpTable:Create()

If ExistBlock('F085RFLT')
	cFiltro	:=	ExecBlock('F085RFLT',.F.,.F.)
Endif

DbSelectArea("SEK")

cQuery:= "SELECT * "
cQuery+= " FROM " + RetSqlName("SEK")
cQuery+= " WHERE EK_FILIAL = '" + xFilial("SEK") + "'"   
cQuery+= " AND EK_ORDPAGO >= '" + mv_par04 + "' AND EK_ORDPAGO <= '"+ mv_par05 + "'"
cQuery+= " AND D_E_L_E_T_ <> '*' "
if !Empty(cFiltro)
	cQuery+= " AND (" + cFiltro + ")"
Endif
If cpaisLoc <> "BRA"
		cQuery+= " ORDER BY EK_FILIAL,EK_FORNEPG,EK_LOJAPG,EK_ORDPAGO DESC"
Else
	cQuery+= " ORDER BY EK_FILIAL,EK_FORNECE,EK_LOJA,EK_ORDPAGO DESC"
Endif
cQuery:= ChangeQuery(cQuery)

MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEKTMP', .T., .T.) },"Por favor aguarde","Seleccionando registros en el Servidor...")

For nI := 1 to Len(aStruTRB)
	If aStruTRB[ni,2] != 'C'
		TCSetField('SEKTMP', aStruTRB[ni,1], aStruTRB[ni,2],aStruTRB[ni,3],aStruTRB[ni,4])
	Endif
Next

DbSelectArea("SEKTMP")
Processa({|| GeraTRB("SEKTMP") })
DbSelectArea("SEKTMP")
DbCloseArea()

DbSelectArea("TRB")
dbGoTop()
nSaveOrder:=Indexord()
If BOF() .and. EOF()
	Help(" ",1,"RECNO")
Else
	AADD(aCpos,{ "MARKA"    , "","" })
	AADD(aCpos,{ "EK_ORDPAGO"   , "", OemToAnsi(STR0014) }) //"Ord. de Pago"
	AADD(aCpos,{ "EK_FORNECE", "", OemToAnsi(STR0015) }) //"Proveedor"
	AADD(aCpos,{ "EK_LOJA" , "", OemToAnsi(STR0016) }) //"Suc."
	AADD(aCpos,{ "EK_VALOR", "", OemToAnsi(STR0017),PesqPict("SEK","EK_VALOR",17,nDecs) }) //"Total Bruto"
	AADD(aCpos,{ "EK_DTDIGIT"  , "", OemToAnsi(STR0022) }) //"Emitida"
	AADD(aCpos,{ "EK_DOCREC"	 , "", OemToAnsi(STR0023) }) //"Doc. Recebimento"
	AADD(aCpos,{ "EK_DTREC", "", OemToAnsi(STR0024) }) //"Data Recebimento"
	
	cCadastro := OemToAnsi(STR0001)                               //"Efetivar Ordem de Pago"
	aPos:= {  8,  4, 11, 74 }
	
	Private aRotina := MenuDef()
	
	cMarcaEK := GetMark()
	MarkBrow("TRB","MARKA","EK_DTREC",aCpos,,cMarcaEK,"A085rMarkAll()",,,,"a085rMark()")

	//Deslockear os registros lockeados
	DbSelectArea("SEK")
	For nX:= 1 To Len(aRecnoSEK)
		MsGoto(aRecnoSEK[nX])
		MsRUnlock(aRecnoSEK[nX])
	Next	

EndIf
TRB->(DbCloseArea())
	
If oTmpTable <> Nil  
	oTmpTable:Delete() 	
	oTmpTable := Nil 
Endif 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085RPesq ºAutor  ³Percy Arias Horna    ºData ³  21/06/01   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a085rPesq()
Local cCampo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CCAMPO,CORD,AORD,")

cCampo := Space(TamSX3("EK_ORDPAGO")[1])
cOrd   := OemToAnsi(STR0005)    //"Orden de Pago"
aOrd   :={}
Aadd(aOrd,OemToAnsi(STR0005))  //"Orden de Pago"
DEFINE MSDIALOG oDlg FROM 5, 5 TO  14, 50 TITLE OemToAnsi(STR0006) //"Orden de Pago"
@ 0.6,1.3 COMBOBOX  cOrd ITEMS aOrd  SIZE 165,44 OF oDlg
@ 2.1,1.3	MSGET cCampo SIZE 165,10
DEFINE SBUTTON FROM 055,122	TYPE 1 ACTION (Buscar(cCampo),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
ACTIVATE DIALOG oDlg CENTERED
Return

Static Function Buscar(pCampo)
	DbSelectArea("TRB")
	TRB->(Msseek(pCampo))
	oDlg:End()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085rMarkAll ºAutor  ³Percy Arias Horna    ºData ³  22/06/01   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a085rMarkAll()
Local nRecno	:=	0
DbSelectArea("TRB")
nRecno	:=	REcno()
DbGoTop()
While !EOF()
	//Pois o click na bMarkAll, chama tanto a markall como a makr
	If nRecno <> Recno()
		a085rMark(.T.)
	Endif
	DbSkip()
Enddo
DbGoTo(nRecno)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085rMark ºAutor  ³Percy Arias Horna   ºFecha ³  22/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de marca da MarkBrowse, definida aqui para tratar os º±±
±±º          ³ locks do SEK a efeitos ad concorrencia de processos.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a085rMark(lAll)
Local lRet	 :=	.F.
Local nX	 :=	0 
Local lAchou := .F.

lAll	:=	Iif(lAll==Nil,.F.,lAll)
            
If ( Eval ( blSeek, 'SEK', 1, xFilial('SEK')+TRB->EK_ORDPAGO,.T. ) )
	lAchou := .T.
EndIf

DbSelectArea("TRB")
//Nao usamos o lInvete pois tem problemas...

If Empty(TRB->EK_DTREC)
	If IsMark("MARKA",cMarcaEK)
		Replace MARKA With "  "
		MsRUnLock(TRB->(RECNO()))
		If lAchou
			dbSelectArea("SEK")
			While EK_ORDPAGO == TRB->EK_ORDPAGO .AND. !EOF()
				Replace EK_OK With "  "
				MsRUnLock(SEK->(RECNO()))
				nX := aScan(aRecNoSEK, RecNo() )
				aDel(aRecNoSEK, nX)
				aSize(aRecNoSEK, Len(aRecNoSEK)-1)
				DbSkip()
			Enddo
			dbSelectArea("TRB")
		EndIf
		lCheckMarca := .F.
	Else
		For nX	:=	0	To 1 STEP 0.2
			If MsRLock()
				Replace MARKA With cMarcaEK
				nX	:=	1
				lRet:=	.T.
				lCheckMarca := .T.
				If lAchou
					dbSelectArea("SEK")
					While EK_ORDPAGO == TRB->EK_ORDPAGO .AND. !EOF()
						If MsRLock()
							Replace EK_OK With cMarcaEK
							AAdd(aRecNoSEK,Recno())
						EndIf
						DbSkip()
					Enddo
					dbSelectArea("TRB")
				EndIf
			Else
				Inkey(0.2)
			Endif
		Next
		If !lRet .And. !lAll
			MsgAlert(OemToAnsi(STR0007)) //"A Ordem de Pagamento est  em uso e nao pode ser marcado no momento"
		Endif
	Endif
Else
	lCheckMarca := .F.
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085rEfetiva  ºAutor  ³Percy Arias Horna   ºFecha ³  22/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de Efetivacao das Ordens de Pagamento.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a085rEfetiva()
Local cDocumento
Local dData      
Private aOrdPago := {}

If !lCheckMarca
	MsgAlert(OemToAnsi(STR0010)) //"Nao foi selecionado nenhuma Ordem de Pagamento!"
	Return
Endif

dbSelectArea("TRB")
DbGoTop()
Do while !TRB->(EOF())
	If IsMark("MARKA",cMarcaEK)
		AADD(aOrdPago,{TRB->EK_ORDPAGO,TRB->MARKA})
	EndIf
	Skip
Enddo

cDocumento  := Space(TamSX3("EK_DOCREC")[1])
dData       := Date()   //CToD(Space(TamSX3("EK_DTREC")[1]))

DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE OemToAnsi(STR0003) //""Efetivar"
@0.6,1.3 SAY OemtoAnsi(STR0008) SIZE 30,7		//	Documento
@ 2.1,1.3 MSGET cDocumento         SIZE 100,10 Of oDlg 
@ 5.6,1.3 SAY OemtoAnsi(STR0009) SIZE 30,7		//	Data
@ 4.1,1.3 MSGET dData              SIZE 40 ,10 Of oDlg
DEFINE SBUTTON FROM 055,122		TYPE 1 ACTION (a085rEfetA(cDocumento,dData)) ENABLE OF oDlg
DEFINE SBUTTON FROM  055,149.1  TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085rEfetA    ºAutor  ³Percy Arias Horna   ºFecha ³  22/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de confirmacao da efetivacao das Ordens de Pagamento.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a085rEfetA(pDocumento,pData)
Local i
Local cAlias	:= ""
Local cKeyImp	:= "" 

SEK->(Msseek(xFilial("SEK")+aOrdPago[1][1]))

	cLibOrd := If(cLibOrd=Nil,"N",cLibOrd)

	If  cLibOrd = "N"
		MsgAlert(OemToAnsi(STR0011)) //"Verificar parametro MV_LIBORD, operacao cancelada!"
		Return	
	Endif
	
	If Len(LTrim(pDocumento)) <= 0
		MsgAlert(OemToAnsi(STR0012)) //"Dados em branco!"
		Return
	Endif
	
	If pData < SEK->EK_DTDIGIT
		MsgAlert(OemToAnsi(STR0028)) //Verificar a data que foi gerada a OP
		Return
	Endif	

	If lGeraLanc
		//+--------------------------------------------------------------+
		//¦ Nao Gerar os lancamento Contabeis On-Line                    ¦
		//+--------------------------------------------------------------+
		lLancPad70 := VerPadrao("570")
	EndIf

	For i = 1 To Len(aOrdPago)
		If (aOrdPago[i][2] == cMarcaEK)
			If ( Eval ( blSeek, 'SEK', 1, xFilial('SEK')+aOrdPago[i][1],.T. ) )
				If lLancPad70
						//+--------------------------------------------------------------+
						//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
						//+--------------------------------------------------------------+
						dbSelectArea("SX5")
						Msseek(xFilial()+"09FIN")
						cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
						nHdlPrv:=HeadProva(cLoteCom,"FINA85R",Subs(cUsuario,7,6),@cArquivo)
						If nHdlPrv <= 0
							Help(" ",1,"A100NOPROV")
						EndIf
				EndIf

				Do While SEK->EK_ORDPAGO = aOrdPago[i][1] .And. SEK->(!EOF())
					RecLock("SEK",.F.)
					Replace EK_DOCREC With pDocumento ,;
					        EK_DTREC  With pData
		            MsUnlock()

					If nHdlPrv > 0 .and. lLancPad70
						//+--------------------------------------------------+
						//¦ Gera Lancamento Contab. para Orden de Pago.      ¦
						//+--------------------------------------------------+
						If lLancPad70
							//SEK->(DbSetOrder(1))
							//SEK->(Msseek(xFilial("SEK")+cOrdPago,.F.))
							SA2->(DbsetOrder(1))
							SA2->(Msseek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA) )
							SA6->(DbsetOrder(1))
							SA6->(Msseek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))

							Do Case
								Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
									cAlias := "SF2"
								Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
									cAlias := "SF2"         
								Otherwise
									cAlias := "SF1"    
							EndCase
							cKeyImp := 	xFilial(cAlias)	+;
										SEK->EK_NUM		+;
										SEK->EK_PREFIXO	+;
										SEK->EK_FORNECE	+;
										SEK->EK_LOJA
							If ( cAlias == "SF1" )
								cKeyImp += SE1->E1_TIPO
							Endif
							Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
							
							nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"570","FINA085",cLoteCom,@nLinha)
                        EndIf
       		   
       				EndIf
					SEK->(DbSkip())
				EndDo

				//-------------------------------------------
				// Atualizao cabecalho da Ordem de Pagamento
				//-------------------------------------------
				DbSelectArea("FJR")
				DbSetOrder(1) //FJR_FILIAL+FJR_ORDPAG
				If Msseek(XFilial("FJR")+aOrdPago[i][1])
					RecLock("FJR",.F.)
					FJR->FJR_DOCREC := pDocumento
					FJR->(MsUnlock())
				EndIf

				//+-----------------------------------------------------+
				//¦ Atualiza TRB para efeito no MarkBrowse              ¦
				//+-----------------------------------------------------+
				dbSelectArea("TRB")
				If ( Eval ( blSeek, 'TRB', 1, aOrdPago[i][1],.F. ) )	
					Replace EK_DTREC With pData,;
							MARKA With "  ",;
				   		 	EK_DOCREC With pDocumento
				EndIf               

				If nHdlPrv > 0 .and. lLancPad70 

					//+-----------------------------------------------------+
					//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
					//+-----------------------------------------------------+
					RodaProva(nHdlPrv,nTotalLanc)

					//+-----------------------------------------------------+
					//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
					//+-----------------------------------------------------+
					lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina)

					If lLanctOk
						SEK->(Msseek(xFilial("SEK")+aOrdPago[i][1]))
						Do while aOrdPago[i][1]==SEK->EK_ORDPAGO.AND.SEK->(!EOF())
							RecLock("SEK",.F.)
							Replace SEK->EK_LA With "S"
							MsUnLock()
							SEK->(DbSkip())
						Enddo
					EndIf
				EndIf
			EndIf   
		Endif
	Next
		
	oDlg:End()
	lCheckMarca := .F.
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a085rCancela  ºAutor  ³Percy Arias Horna   ºFecha ³  26/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de cancelamento da efetivacao das Ordens de Pagamento.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a085rCancela()
Local nRegs

	cLibOrd := If(cLibOrd=Nil,"N",cLibOrd)

	If  cLibOrd = "N"
		MsgAlert(OemToAnsi(STR0011)) //"Verificar parametro MV_LIBORD, operacao cancelada!"
		Return	
	Endif

	If Empty(TRB->EK_DTREC)
		MsgAlert(OemToAnsi(STR0027)) //"Item NAO pode ser apagado!, ainda NAO foi efetivado"	
		Return
	EndIf

	nTotalLanc := 0

	If lGeraLanc
		//+--------------------------------------------------------------+
		//¦ Nao Gerar os lancamento Contabeis On-Line                    ¦
		//+--------------------------------------------------------------+
		lLancPad71 := VerPadrao("571")
	EndIf

	nRegs := TRB->EK_ORDPAGO
	If ( Eval ( blSeek, 'SEK', 1, xFilial('SEK')+nRegs,.F. ) ) 
		If lLancPad71
				//+--------------------------------------------------------------+
				//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
				//+--------------------------------------------------------------+
				dbSelectArea("SX5")
				Msseek(xFilial()+"09FIN")
				cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
				nHdlPrv:=HeadProva(cLoteCom,"FINA85R",Subs(cUsuario,7,6),@cArquivo)
				If nHdlPrv <= 0
					Help(" ",1,"A100NOPROV")
				EndIf
		EndIf
		//"¿Deseja apagar este item?","ATENCAO!"
		If MsgYesNo(OemToAnsi(STR0026)+ OemToAnsi(STR0025))
			Begin Transaction
			Do While SEK->EK_ORDPAGO = nRegs .And. SEK->(!EOF())
				RecLock("SEK",.F.)
				Replace EK_DOCREC With Space(TamSX3("EK_DOCREC")[1]),;
					EK_DTREC  With CtoD(Space(8))
				MsUnlock()  
				If nHdlPrv > 0 .and. lLancPad71
					//+--------------------------------------------------+
					//¦ Gera Lancamento Contab. para Orden de Pago.      ¦
					//+--------------------------------------------------+
					If lLancPad71

						SA2->(DbsetOrder(1))
						SA2->(Msseek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA) )
						SA6->(DbsetOrder(1))
						SA6->(Msseek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))

						Do Case
							Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
								cAlias := "SF2"
							Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
								cAlias := "SF2"         
							Otherwise
								cAlias := "SF1"    
						EndCase
						cKeyImp := 	xFilial(cAlias)	+;
									SEK->EK_NUM		+;
									SEK->EK_PREFIXO	+;
									SEK->EK_FORNECE	+;
									SEK->EK_LOJA
						If ( cAlias == "SF1" )
							cKeyImp += SE1->E1_TIPO
						Endif
						Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
						
						nTotalLanc := nTotalLanc + DetProva(nHdlPrv,"571","FINA085",cLoteCom,@nLinha)
            	EndIf
       		   
       		EndIf		        
				SEK->(DbSkip())
			EndDo

			//-------------------------------------------
			// Atualizao cabecalho da Ordem de Pagamento
			//-------------------------------------------
			DbSelectArea("FJR")
			DbSetOrder(1) //FJR_FILIAL+FJR_ORDPAG
			If Msseek(XFilial("FJR")+nRegs)
				RecLock("FJR",.F.)
				FJR->FJR_DOCREC := CriaVar("FJR_DOCREC",.F.)
				FJR->(MsUnlock())
			EndIf

			RecLock("TRB",.F.)	
			Replace EK_DOCREC    With Space(TamSX3("EK_DOCREC")[1]),;
					EK_DTREC With Ctod(Space(8))
		        MsUnlock() 
					If nHdlPrv > 0 .and. lLancPad71 
	
						//+-----------------------------------------------------+
						//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
						//+-----------------------------------------------------+
						RodaProva(nHdlPrv,nTotalLanc)   
						
						//+-----------------------------------------------------+
						//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
						//+-----------------------------------------------------+
						lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina)						
					EndIf		        
			End Transaction
		EndIf
	Endif		

		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GeraTRB  ³ Autor ³ Percy Arias Horna     ³ Data ³ 22/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera el archivo de trabajo.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA085R                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTRB(cAlias)
Local nTB

DbGoTop()
ProcRegua(Reccount())
DO WHILE !EOF()
	nTB:=0
	IF !EK_CANCEL
		cOrdAnt   := EK_ORDPAGO
		cForAnt   := EK_FORNECE
		cLojaAnt  := EK_LOJA
		Cfilant   := EK_FILIAL
		TRB->(DbAppend())
		TRB->EK_FORNECE := EK_FORNECE
		TRB->EK_LOJA  := EK_LOJA
		TRB->EK_DTDIGIT   := EK_DTDIGIT
		TRB->EK_ORDPAGO    := EK_ORDPAGO
		TRB->EK_DOCREC    := EK_DOCREC
		TRB->EK_DTREC := EK_DTREC
		Do While EK_ORDPAGO == cOrdAnt .And. Cfilant== EK_FILIAL .And. !(cAlias)->(EOF())  //filial
			IncProc()
			If EK_TIPODOC<>"TB" .And. !(EK_TIPO $ MVPAGANT)
				nTB	+= xMoeda(EK_VALOR,Max(Val(EK_MOEDA),1),VAL(EK_MOEDA),EK_DTDIGIT,2)
			Endif
			DbSelectArea(cAlias)
			DbSkip()
		Enddo
		TRB->EK_VALOR	:=	nTB
	Else
		IncProc()
		(cAlias)->(DbSkip())
	Endif
Enddo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³21/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotina := { { OemToAnsi(STR0002),'a085rPesq()'   ,0 ,1},;    //"Buscar"
	              { OemToAnsi(STR0003),'a085rEfetiva()' ,0 ,4},;   //"Efetivar"
	              { OemToAnsi(STR0004),'a085rCancela()' ,0 ,4}} 	//"Cancelar"
	             
Return(aRotina)
