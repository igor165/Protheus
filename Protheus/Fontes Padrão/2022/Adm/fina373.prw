#INCLUDE "FINA373.ch"
#INCLUDE "PROTHEUS.CH"

Static lFWCodFil := .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FINA373   ³ Autor ³ Adrianne Furtado      ³ Data ³01.07.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Emissão de DARF                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FINA373()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := MenuDef()
Private nValTot  := 0

If GetHlpLGPD({"A6_COD", "A6_AGENCIA", "A6_NUMCON"})
	Return .F.
Endif

mBrowse( 6, 1,22,75,"FI9",,,,,, FA373Legen())

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Adrianne Furtado       ³ Data ³06/07/09 ³±±
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
Local aRotina

aRotina := {{ OemToAnsi(STR0021),"AxPesqui"  , 0 , 1, ,.F.},; //"Pesquisar"
			{ OemToAnsi(STR0001),"FINRSRF"  , 0 , 3},; //"Emitir Darf"
   			{ OemToAnsi(STR0002),"FA373Reem", 0 , 2},; //"Reemitir Darf"
			{ OemToAnsi(STR0003),"FA373Cons", 0 , 1},; //"Consulta Darf"
			{ OemToAnsi(STR0004),"FA373Canc", 0 , 5},; //"Cancelar Darf"
			{ OemToAnsi(STR0035),"FA373Legen('x')", 0 , 4, ,.F.} }  //"Legenda"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FA373Reem ³ Autor ³ Adrianne Furtado      ³ Data ³06.07.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reemissao de Darf.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Reem()

Local aDarf     	:= {}
Local aInfo     	:= {}
Local lQuery    	:= .F.
Local cAliasFI9 	:= "FI9"
Local dDataIni
Local dDataFim
Local cGuiaIni
Local cGuiaFim
Local cForIni
Local cForFim
Local nX        	:= 0
Local nY			 	:= 0
Local nValorImp 	:= 0
Local aAreaSm0  	:= SM0->(GetArea())
Local cFilCtr 	 	:= ""  //filial de controle
Local lAchouPai

Static aPergRet 	:= Array(13)

Local aStru  	:= {}
Local cQuery 	:= ""
Local cPerg   := "FINSRF2"  // Pergunta do Relatorio
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cSeekFil		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas        ³
//³---------------------------------        ³
//³ mv_par01 - Emissao De ?  				³
//³ mv_par02 - Emissao Ate?					³
//³ mv_par03 - Guia De?						³
//³ mv_par04 - Guia Ate?					³
//³ mv_par05 - Fornecedor De?				³
//³ mv_par06 - Fornecedor Ate?				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Pergunte(cPerg,.T.)
	dDataIni  := MV_PAR01
	dDataFim  := MV_PAR02
	cGuiaIni  := MV_PAR03
	cGuiaFim  := MV_PAR04
	cForIni   := MV_PAR05
	cForFim   := MV_PAR06

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre o SE2 com outro alias para ser localizado o titulo 	 ³
	//³ principal do imposto                   							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( ChkFile("SE2",.F.,"NEWSE2") )
		Return(Nil)
	EndIf

	dbSelectArea("FI9")
	dbSetOrder(1)

	lQuery := .T.
	aStru  := FI9->(dbStruct())
	cAliasFI9 := "REIMP"

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("FI9")+" FI9 "
	cQuery += "WHERE FI9.FI9_FILIAL='"+xFilial("FI9")+"' AND "
	cQuery += "FI9.FI9_EMISS >='" +DToS(dDataIni)+"' AND "
	cQuery += "FI9.FI9_EMISS <='" +DToS(dDataFim)+"' AND "
	cQuery += "FI9.FI9_IDDARF >='"+cGuiaIni+"' AND "
	cQuery += "FI9.FI9_IDDARF <='"+cGuiaFim+"' AND "
	cQuery += "FI9.FI9_FORNEC >='"+cForIni +"' AND "
	cQuery += "FI9.FI9_FORNEC <='"+cForFim +"' AND "
	cQuery += "FI9.FI9_STATUS ='A' AND "
	cQuery += "FI9.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(FI9->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFI9)
	For nX := 1 To Len(aStru)
		If aStru[nX][2]<>"C"
			TcSetField(cAliasFI9,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX

	SE2->(DbSetOrder(1))

	While (!Eof() .And. xFilial("FI9")==(cAliasFI9)->FI9_FILIAL .And.;
			(cAliasFI9)->FI9_IDDARF <= cGuiaFim )

		If (cAliasFI9)->FI9_STATUS == 'A' .And.;
			(cAliasFI9)->FI9_EMISS  >= dDataIni .And.;
			(cAliasFI9)->FI9_EMISS  <= dDataFim .And.;
			(cAliasFI9)->FI9_FORNEC >= cForIni .And.;
			(cAliasFI9)->FI9_FORNEC <= cForFim
			
			If lFI9_FILORI .And. !Empty((cAliasFI9)->FI9_FILORI)
				cSeekFil	:= xFilial("SE2",(cAliasFI9)->FI9_FILORI)
			Else
			 	cSeekFil	:= xFilial("SE2")
			EndIf

			If SE2->(DBSeek(cSeekFil+(cAliasFI9)->(FI9_PREFIXO+FI9_NUM+FI9_PARCEL+FI9_TIPO)))

				cFilCtr := FI9->FI9_FILCTR

				dbSelectArea("SA2")
				MsSeek(xFilial("SA2")+(cAliasFI9)->(FI9_FORNECE+FI9_LOJA))

				nX := aScan(aDarf,{|x|	x[1] == SE2->E2_CODRET .And.;
												x[2] == SE2->E2_VENCREA .And.;
												x[4] == SA2->A2_COD .And.;
												x[8] == (cAliasFI9)->FI9_IDDARF })

				//Verificação necessária, pois a DARF pode ter sido emitida aglutinando somente por COD. RETENÇÃO e nao FORNECEDOR
				If nX == 0
					nY := aScan(aDarf,{|x|	x[1] == SE2->E2_CODRET .And. x[2] == SE2->E2_VENCREA .And. x[8] == (cAliasFI9)->FI9_IDDARF })
				Endif

				// Obtem o valor do imposto
				nValorImp := (cAliasFI9)->FI9_VALOR

				If nX == 0  .and. nY==0
	        	    If Alltrim((cAliasFI9)->(FI9_FORNECE+FI9_LOJA)) == ''
						lAchouPai := .F.
					Else
						lAchouPai := .T.
					EndIf
					aadd(aDarf,{SE2->E2_CODRET,;
									SE2->E2_VENCREA,;
									xMoeda(nValorImp,SE2->E2_MOEDA,1),;
									SA2->A2_COD,;
									SA2->A2_NOME,;
									lAchouPai,;
									SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA),(cAliasFI9)->FI9_IDDARF,,;
									(cAliasFI9)->FI9_APURA, (cAliasFI9)->FI9_REFER})
				Else
					If nX>0
						aDarf[nX][3] += xMoeda(nValorImp,SE2->E2_MOEDA,1)
					Else
						aDarf[nY][3] += xMoeda(nValorImp,SE2->E2_MOEDA,1)
					Endif
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasFI9)
		dbSkip()

	EndDo
	NEWSE2->(dbCloseArea())
	If lQuery
		dbSelectArea(cAliasFI9)
		dbCloseArea()
		dbSelectArea("SE2")
	EndIf

	// Se for informada a filial centralizadora, posiciona nela para impressao dos dados como CGC, Nome, Etc.
	If !Empty(cFilCtr)
		SM0->(MsSeek(cEmpAnt+cFilCtr))
		cFilCtr := ""
	Endif
	For nX := 1 To Len(aDarf)
		aadd(aInfo,{{SM0->M0_NOMECOM,SM0->M0_TEL},;
			aDarf[nX][10],;
			TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99"),;
			aDarf[nX][1],;
			aDarf[nX][11],;
			aDarf[nX][2],;
			aDarf[nX][3],;
			0,;
			0,;
			aDarf[nX][3],;
			aDarf[nX][5],;
			aDarf[nX][6],;
			aDarf[nX][7]})
	Next nX

	aInfoAux := AClone(aInfo)
	If ExistBlock("FA373SCL")
		aInfo := ExecBlock("FA373SCL", .F., .F.,{aInfo})
		If ValType(aInfo) <> "A"
			aInfo := AClone(aInfoAux)
		Endif
	Endif

	If Len(aInfo) > 0
		aPergRet[9] := "1."
		aPergRet[5] := "1."
		PrtDarf(aInfo, aPergRet)
	Else
		Aviso(STR0005,STR0006,{STR0007}) //"Mensagem"###"Nao há dados no intervalo informado"###"Ok"
	EndIf
	SM0->(RestArea(aAreaSm0))
EndIf

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FA373Cons ³ Autor ³ Adrianne Furtado      ³ Data ³06.07.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Darf.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Cons()
Local aSize := {}
Local oDlg
Local cIdDarf := Space(20)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de baixas								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTitulo := OemToAnsi(STR0031) //"DARF - Consulta"
Local aButtons := {}
local l373Cons:= existblock("F373CONS")

Private oGet
Private oSayFor
Private oValTot	:= 0
Private aHeader	:= {}
Private aCols		:= {}

Aadd(aButtons,{"S4WB010N",{|| Fr373Rel(cIdDarf)},STR0022})
AADD(aButtons,{"PMSCOLOR", {|| Fa373Legen(FI9->(RECNO()))}, STR0035 ,STR0035 }) //"Legenda"###"Legenda"
aSize := MsAdvSize(,.F.,400)
DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDLg:lMaximized := .T.

	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont,.T.,,,,,45,.T.,.T. )  // altura 45

	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	@	003,010 TO 040,145 OF oPanel1 Pixel
	@	003,147 TO 040,500 OF oPanel1 Pixel

	@	015,015 Say STR0008 Of oPanel1 Pixel   //"DARF"
	If l373Cons
		@   015,038	MSGET oGet1 VAR cIdDarf := (Execblock("F373CONS",.f.,.f.)) SIZE 68,10 Picture "@!" OF oPanel1 PIXEL
	EndIf
	@   015,038	MSGET oGet1 VAR cIdDarf SIZE 68,10 Picture "@!" OF oPanel1 PIXEL

DEFINE SBUTTON FROM 015,110	TYPE 1 ACTION (If(!Empty(cIdDarf), nOpca:=F73SlDarf(@oDlg,1,@cIdDarf,@oPanel1,@oPanel2),;
															 nOpca:=0)) ENABLE OF oPanel1

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg:End(),nOpca := 0), nOpca := 0)},{||oDlg:End()},,aButtons)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F73SlDarf  ³ Autor ³ Adrianne Furtado     ³ Data ³ 08.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GetDados   da Consulta de DARF					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto onde se encaixara a GetDados  			  ³±±
±±³			 ³ ExpN1 = Opcao selecionada na tela                  		  ³±±
±±³			 ³ ExpC1 = Código de identificação da DARF					  ³±±
±±³			 ³ ExpO2 = Panel 1                             				  ³±±
±±³			 ³ ExpO1 = Panel 2             				 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA290                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F73SlDarf(oDlg,nOpca,cIdDarf,oPanel1,oPanel2)

cIdDarf := If(nOpca=0,"   ",cIdDarf)

aCols := F73RtDarf(cIdDArf)

If !Empty(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela com os diversos titulos						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nOpca := 0

	If ValType(oGet) <> "O"
		@ 014,160	SAY STR0009 OF oPanel1 SIZE 80,14 Pixel//"Fornecedor : "
		oSayFor := TSay():New( 014, 200, {|| SubStr(FI9->FI9_FORNEC+' - '+FI9->FI9_LOJA+' - '+SA2->A2_NREDUZ,1,200) }, oPanel1,,,,,,.T.,,,200,14,,,,,,)
		@ 014,415	Say STR0011 OF oPanel1 SIZE 80,14 Pixel //"Cod. Retencao: "
		@ 014,465	Say FI9->FI9_CODRET OF oPanel1 SIZE 80,14  Pixel
		@ 027,160	Say STR0010 OF oPanel1 Pixel SIZE 80,14 //"Emissao: "
		@ 027,200	Say FI9->FI9_EMISS OF oPanel1 SIZE 100,14  Pixel			
		@ 027,416	Say STR0012 OF oPanel1 Pixel SIZE 80,14 //"Valor Total: "
		@ 027,453	Say nValTot Picture "@E 9,999,999,999.99" OF oPanel1 PIXEL SIZE 80,14 //FONT oFnt COLOR CLR_HBLUE //FONT oDlg2:oFont					
		oGet:= MSGetDados():New(90,1,172,312,4,,,,,.F.,,.T.,900,,,,)
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet:oBrowse:bChange := {|| F373FORN(@oSayFor) }
	Else
		oGet:ForceRefresh()
	EndIf
Else
	Aviso(STR0019,STR0020,{STR0007}) //"Atencao""Não há dados para o código informado."
Endif

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ F73RtDarf ³ Autor ³ Adrianne Furtado	  ³ Data ³ 08/07/09   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Formata Array com os titulos da DARF						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina373													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F73RtDarf(cIdDArf)
Local Ni

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

PRIVATE aCOLS
aCols := {}
nValTot := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da matriz aHeader											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeader) == 0
	AADD(aHeader,{" ","TMP_LEGE","@BMP",5,0," ",	"","C","","" })
	If !Empty( cFilFwFI9 )
		AADD(aHeader,{ OemToAnsi(STR0013),"FI9_FILIAL"	,"@!"             ,TamSx3("FI9_FILIAL")[1] ,0,"","û","C","SE2" } )          //"Filial"
	EndIf
	AADD(aHeader,{ OemToAnsi(STR0014),"FI9_PREFIX"	,"@!"                 ,TamSx3("FI9_PREFIX")[1] ,0,"","û","C","SE2" } )          //"Prefixo"
	AADD(aHeader,{ OemToAnsi(STR0015),"FI9_NUM"		,"@!"                 ,TamSx3("FI9_NUM")[1],0,"","û","C","SE2" } )     			//"N£mero"
	AADD(aHeader,{ OemToAnsi(STR0016),"FI9_PARCEL"	,PesqPict("FI9","FI9_PARCEL"),TamSx3("FI9_PARCEL")[1],0,"","û","C","FI9" } ) 	//"PArcela"
	AADD(aHeader,{ OemToAnsi(STR0017),"FI9_TIPO"	,"@!"                 ,TamSx3("FI9_TIPO")[1],0,"","û","C","SE2" } )          //"Tipo"
	AADD(aHeader,{ OemToAnsi(STR0042),"FI9_FORNEC"	,"@!"                 ,TamSx3("FI9_FORNEC")[1] ,0,"","û","C","SE2" } )          //"Fornecedor"
	AADD(aHeader,{ OemToAnsi(STR0043),"FI9_LOJA"		,"@!"                 ,TamSx3("FI9_LOJA")[1],0,"","û","C","SE2" } )     			//"Loja"
	AADD(aHeader,{ OemToAnsi(STR0018),"FI9_VALOR"	,"@E 9,999,999,999.99",TamSx3("FI9_VALOR")[1],TamSx3("E2_VALOR")[2],"Fa290AtuVl()","û","N","SE2"})//"Valor"
EndIf

DbSelectArea("FI9")
DbSetOrder(1)
DbSeek(xFilial("FI9")+cIdDArf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava aCols com os titulos componentes da DARF		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nUsado := Len(aHeader)

//While !(cAliasTrb)->(EOF())
While FI9->(!Eof()) .And.  FI9->(FI9_FILIAL + FI9_IDDARF)  == xFilial("FI9")+cIdDArf
	AADD(aCols,Array(nUsado+1))
	For nI := 1 To nUsado
		If nI == 1
			aCols[Len(aCols)][nI] := If(FI9->FI9_STATUS == "A","ENABLE","DISABLE")
		Else
			aCols[Len(aCols)][nI] := FI9->(FieldGet(FieldPos(aHeader[nI][2])))
		EndIf
		If nI == nUsado
			nValTot += aCols[Len(aCols)][nI]
		EndIf
	Next nI
	aCols[Len(aCols)][nUsado+1] := .F.
	FI9->(dbSkip())
Enddo

FI9->(DbSeek(xFilial("FI9")+cIdDarf))
SA2->(DBSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+FI9->(FI9_FORNEC+FI9_LOJA )))

Return(aCols)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fr373Rel  ³ Autor ³ Adrianne Furtado      ³ Data ³ 13.07.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio com a DARF selecionada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fr373Rel(cidDarf)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fr373Rel(cIdDarf)

Local oReport
Private cChaveInterFun := ""

If TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef(cIdDArf)
	oReport:PrintDialog()
Else
	Fr373RlR3(cIdDarf)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ Adrianne Furtado      ³ Data ³ 13.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ "Conferencia DARF 			                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(cIdDarf)

Local oReport
Local oSection

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

oReport := TReport():New("FINR373",STR0025+ cIdDarf,,; //"RELACAO DAS NATUREZAS"
                         {|oReport| ReportPrint(oReport,cIdDarf)},STR0023+STR0024)

nTamCod := 0

oSection := TRSection():New(oReport,"Conferência DARF - Nr. " + cIdDarf,{"FI9","SA2"})

//oParent / cName / cAlias / cTitle / cPicture / nSize / lPixel / bBlock codeblock
If !Empty( cFilFwFI9 )
	TRCell():New(oSection,"FI9_FILIAL" 	,"FI9")
EndIf
TRCell():New(oSection,"FI9_PREFIX" 	,"FI9")
TRCell():New(oSection,"FI9_NUM"  	,"FI9")
TRCell():New(oSection,"FI9_PARCEL" 	,"FI9")
TRCell():New(oSection,"FI9_TIPO"    ,"FI9")
TRCell():New(oSection,"FI9_FORNEC"  ,"FI9","Fornecedor",/*cpicture*/,TamSX3("A2_COD")[1]+TamSX3("A2_LOJA")[1]+TamSX3("A2_NOME")[1]+4,/*lPixel*/,{|| SA2->A2_COD+"-"+ SA2->A2_LOJA+" - "+SA2->A2_NOME})
TRCell():New(oSection,"FI9_VALOR"   ,"FI9")

oBreak1 := TRBreak():New( oSection,oSection:Cell("FI9_FORNEC") ,STR0029)

TRFunction():New(oSection:Cell("FI9_VALOR")	, , "SUM"  , oBreak1, , , , .F. ,.F.,.F.  )

oBrkGeral := TRBreak():New(oSection, { || FI9->(!Eof()) },,,,.F.)	//	" T O T A I S "

TRFunction():New(oSection:Cell("FI9_VALOR")	, , "SUM"  , oBrkGeral, , , , .F. ,.F.,.F.  )

Return oReport
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Adrianne Furtado       ³ Data ³13.07.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport, cIdDarf)

Local oSection  := oReport:Section(1)
Local cAliasFI9 := "FI9"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FI9")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()

cAliasFI9 := GetNextAlias()

BeginSql Alias cAliasFI9
SELECT *

FROM %table:FI9% FI9

WHERE FI9_FILIAL = %xFilial:FI9% AND
	FI9_IDDARF   = %Exp:cIdDarf% AND
	FI9_STATUS   = "A" AND
	FI9.%notDel%

ORDER BY %Order:FI9%

EndSql
oReport:Section(1):EndQuery()

TRPosition():New(oSection,"SA2",1,{|| xFilial("SA2") + (cAliasFI9)->FI9_FORNECE+(cAliasFI9)->FI9_LOJA})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:SetMeter(FI9->(LastRec()))

dbSelectArea(cAliasFI9)
While !oReport:Cancel() .And. !(cAliasFI9)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	lFirst := .T.

	While !oReport:Cancel() .And. !(cAliasFI9)->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oSection:Init()

		oSection:PrintLine()

		dbSkip()
	EndDo
	oSection:Finish()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:IncMeter()
EndDo

(cAliasFI9)->(DbCloseArea())

Return NIL



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fr373RlR3         ³ Adrianne Furtado      ³ Data ³ 13.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do relatorio com a DARF selecionada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fr373Rel(ExpC1) 										  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String contendo o código da DARF                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA373				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fr373RlR3(cIdDarf)

Local cDesc1	:= STR0023 //"Este relatorio ir demonstrar os titulos de impostos "
Local cDesc2	:= STR0024 //"contidos na DARF selecionada."
Local cDesc3	:= ""
Local wNrel
Local Tamanho	:= "G"
Local CbCont	:= 0
Local CbTxt		:= Space(10)
Local cString	:= "FI9"
Local nColPrefixo
Local nColNumero
Local nColParcela
Local nColTipo
Local nColFornece
Local nColValor
Local nSubTot	:= 0
Local aRelat := aClone(aCols)

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial("FI9") )

Private Li			:= 80
Private M_pag		:= 1
Private Titulo		:= STR0025+ cIdDarf //"Conferencia DARF - Nr. "
Private cabec1		:= ""
Private cabec2		:= ""
Private aReturn	:= {STR0026, 1, STR0027, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nomeprog	:= "FINA373"
Private nLastKey	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "FR373Rel"
wnrel := SetPrint(cString,wNrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",.F.)
If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return(Nil)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Considerar filiais                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nColPrefixo	:= 9
nColNumero	:= 18
nColParcela	:= 33
nColTipo	:= 40
nColFornece := 46
nColValor	:= 123

Cabec1 := STR0028 	//"Filial  Prefixo  Numero         Parc   Tipo  Fornecedor+Loja+Nome              										  Valor do Titulo"
//"Filial  Prefixo  Numero         Parc   Tipo  Fornecedor+Loja+Nome              										   Valor do Titulo"
//12      123      1234567890123  123    123   12345678901234567890" - "1234" - "1234567890123456789012345678901234567890    99,999,999.99  
//1       9        18             33     40    46                      					  								   123

Cabec2 := ""
If Len(aRelat) > 0
	//Imprime titulos baixados
	DbSelectArea("SA2")
	SA2->(DBSetOrder(1))
	DbSelectArea("FI9")
	FI9->(DBSetOrder(1))

	FI9->(DbSeek(xFilial("FI9") + cIdDarf + "A"))
	While FI9->(!Eof()) .And. FI9->(FI9_FILIAL+FI9_IDDARF +FI9_STATUS ) == xFilial("FI9") + cIdDarf + "A"
		If Li >= 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
			Li := Prow()+1
		EndIf
		
		SA2->(DBSeek(xFilial("SA2") + FI9->FI9_FORNEC+FI9->FI9_LOJA))
		If !Empty( cFilFwFI9 )
			@Li,001 		PSAY FI9->FI9_FILIAL //aRelat[nA][2]
		EndIf	
		@Li,nColPrefixo	PSAY FI9->FI9_PREFIX //aRelat[nA][3]
		@Li,nColNumero	PSAY FI9->FI9_NUM //aRelat[nA][4]
		@Li,nColParcela	PSAY FI9->FI9_PARCEL //aRelat[nA][5]
		@Li,nColTipo	PSAY FI9->FI9_TIPO //aRelat[nA][6]
		@Li,nColFornece	PSAY FI9->FI9_FORNEC +" - "+FI9->FI9_LOJA +" - " + SA2->A2_NOME
		@Li,nColValor	PSAY FI9->FI9_VALOR Picture "@e 99,999,999.99" //aRelat[nA][7]
		nSubTot += FI9->FI9_VALOR //aRelat[nA][7]
		Li++
		FI9->(DBSkip())
	EndDo
	If Li >= 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
		Li := Prow()+1
	EndIf
	Li ++
	@Li,001					PSAY STR0029 +" -->> " //"Valor Total "
	@Li,nColValor			PSAY nSubTot		Picture "@e 99,999,999.99"

	Li +=2
 	@ Li,000 PSAY __PrtThinLine()
	Li += 2

	Roda(CbCont,CbTxt,Tamanho)
Endif

If aReturn[5] = 1
	Set Printer To
	DbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FA373Canc ³ Autor ³ Adrianne Furtado     ³ Data ³14.07.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cancelamento de Darf.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Canc()
Local aSize := {}
Local oDlg
Local cIdDarf := Space(20)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de baixas								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTitulo := OemToAnsi(STR0030) //"DARF - Cancelamento"
Local aButtons := {}
Local lF373CAN := ExistBlock("F373CAN")

Private oGet
Private oSayFor
Private oValTot	:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private nValTot  := 0

AADD(aButtons,{"PMSCOLOR", {|| Fa373Legen(FI9->(RECNO()))}, STR0035 ,STR0035 }) //"Legenda"###"Legenda"
aSize := MsAdvSize(,.F.,400)
DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDLg:lMaximized := .T.

	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont,.T.,,,,,45,.T.,.T. )  // altura 45

	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	@	003,010 TO 040,145 OF oPanel1 Pixel
	@	003,147 TO 040,500 OF oPanel1 Pixel

	@	015,015 Say STR0008 Of oPanel1 Pixel   //"DARF"
	If lF373CAN
		@   015,038	MSGET oGet1 VAR cIdDarf :=(Execblock("F373CAN",.f.,.f.))SIZE 68,10 Picture "@!" OF oPanel1 PIXEL
	EndIf
	@   015,038	MSGET oGet1 VAR cIdDarf SIZE 68,10 Picture "@!" OF oPanel1 PIXEL

DEFINE SBUTTON FROM 015,110	TYPE 1 ACTION (If(!Empty(cIdDarf), nOpca:=F73SlDarf(oDlg,1,@cIdDarf,oPanel1,oPanel2),;
																nOpca:=0)) ENABLE OF oPanel1

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,If(FA373Del(cIdDarf),oDlg:End(),nOpca := 0),nOpca := 0), nOpca := 0)},{||oDlg:End()},,aButtons)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA373Legen ³ Autor ³ Adrianne Furtado     ³ Data ³ 14.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA373                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Legen(nReg)
Local uRetorno := .T.
Local aLegenda := {}

aLegenda := {	{"BR_VERDE", 	STR0033	},; //"Ativo"
		   		{"BR_VERMELHO", 	STR0034	}} //"Baixado"

If nReg = Nil	// Chamada direta da funcao
	dbSelectArea("FI9")
	uRetorno := {}
	Aadd(uRetorno,{ 'FI9_STATUS == "A"' , "BR_VERDE" }) // "Ativo"
	Aadd(uRetorno,{ 'FI9_STATUS == "B"' , "BR_VERMELHO"})	// "Baixado"
Else
	BrwLegenda(OemToAnsi(STR0031),STR0035,aLegenda) //"Legenda"
Endif

Return uRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA373Del ³ Autor ³ Adrianne Furtado      ³ Data ³ 14.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FA373Del                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Del(cidDarf)
Local cRet
Local lTemBx := .F.
Local nI
Local aRecno  := {}
Local nIniFLj
Local nTamFLj
Local cAliasSE2 := ""
Local cQuery	:= ""
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cSeekFil		:= ""

nIniFLj := TamSx3("E2_PREFIXO")[1] + TamSx3("E2_NUM")[1] + TamSx3("E2_PARCELA")[1] + TamSx3("E2_TIPO")[1] + 1
nTamFLj := TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]

DbSelectArea("FI9")
DbSetOrder(1)
DbSeek(xFilial("FI9")+cIdDArf)
While !Eof() .and. FI9->(FI9_FILIAL + FI9_IDDARF) == xFilial("FI9")+cIdDarf .and. !lTemBx
	If FI9->FI9_STATUS = "B"
		lTemBx := .T.
	End
	DbSkip()
EndDo

If lTemBx
	//"A DARF Nr. " ### " possui títulos que já foram baixados. Nao será possível apagar."
	Aviso (STR0019,STR0036 + cIdDarf+ STR0037,{STR0007}) //"Ok"
EndIf

//"A DARF Nr. " ### " será completamente apagada. deseja continuar?" "Sim" "Não"
If !lTemBx .and. Aviso (STR0019,STR0036 + cIdDarf+STR0038,{STR0039,STR0040}) == 1
	FI9->(DbSeek(xFilial("FI9")+cIdDArf))
    SE2->(DbSetOrder(1))
	
	// Tratamento para cancelamento de DARF que possuem titulos de filiais distintas
	cAliasSE2 := GetNextAlias()
			
	cQuery := "SELECT E2_FILIAL "
	cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += "WHERE "
	cQuery += "SE2.E2_IDDARF = '"+FI9->FI9_IDDARF+"' AND "				
	cQuery += "SE2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SE2->(IndexKey()))
			
	cQuery := ChangeQuery(cQuery)
			
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE2,.F.,.T.)

	//Posiciono nos registros do SE2 e apago o IDDarf
	While !Eof() .and. FI9->(FI9_FILIAL +FI9_IDDARF) == xFilial("FI9")+cIdDarf
	
		If lFI9_FILORI .And. !Empty(FI9->FI9_FILORI)
		 	cSeekFil := xFilial("SE2",FI9->FI9_FILORI)
		Else
		 	cSeekFil :=  xFilial("SE2")
		EndIf
			
		If !SE2->(DbSeek(cSeekFil+FI9->(FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO)))
		
			// Se nao encontrou registro pela xFilial, procura em outras filiais
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbGoTop())
			While (cAliasSE2)->( ! Eof() )
				If SE2->(DbSeek((cAliasSE2)->E2_FILIAL+FI9->(FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO)))
					Exit
				Else
					(cAliasSE2)->(dbSkip())
				EndIf
			EndDo
		EndIf
		If !Empty(SE2->E2_TITPAI)
			While FI9->(FI9_FORNECE+FI9_LOJA) <> SubStr(SE2->E2_TITPAI,nIniFLj,nTamFLj)
				SE2->(DbSkip())
			EndDo
		EndIf
		RecLock( "SE2", .F. )
		SE2->E2_IDDARF	:= ""
		MsUnlock()
		Aadd(aRecno, FI9->(Recno()))
		FI9->(DbSkip())
	EndDo
	//Posiciono nos registros do FI9 e apago-os
	For nI := 1 To Len(aRecno)
		FI9->(DbGoTo(aRecno[nI]))
		RecLock( "FI9", .F. )
		DbDelete()
		DbCommit()
		MsUnlock()
	Next nI
	cRet := .T.
	Aviso (STR0019,STR0041,{STR0007}) //"Registros apagados com sucesso."		"Ok"
	(cAliasSE2)->(DbCloseArea())
	MsErase(cAliasSE2)
Else
	cRet := .F.
EndIf

Return cRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA373Del ³ Autor ³ Adrianne Furtado      ³ Data ³ 15.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava status de baixado "B" no registro FI9                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FA373Del                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA373Bx(lBaixa)
// lBaixa = .T. -> está baixando o título
// lBaixa = .F. -> está cancelando a baixa do título

// SE2 está posicionado

Local cChave  		:= ""
Local cParcela		:= ""
Local cSeek         := ""
Local cCPOPARC 		:= ""
Local cOrigens 		:= ""
Local cFilterSE2 	:= SE2->(DbFilter())
Local nIniFLj		:= 0
Local nTamFLj		:= 0
Local aArea			:= {}
Local lAglut 		:= (Alltrim(SE2->E2_ORIGEM)=="FINA376")  //CASO SEJA TITULO AGLUTINADO
Local lFINTPDARF	:= ExistBlock("FINTPDARF")
Local lFI9_FILORI	:= FI9->(FieldPos("FI9_FILORI")) > 0
Local cFilSeek		:= If(lFI9_FILORI, SE2->E2_FILORIG, xFilial("FI9") )
Local nOrder		:= 3 
Local lAchou		:= .F.

If AllTrim(SE2->E2_IDDARF) <> ""
	aArea := SE2->(GetArea())
	cChave += SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
	cSeek := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM)
	
	nIniFLj := TamSx3("E2_PREFIXO")[1] + TamSx3("E2_NUM")[1] + TamSx3("E2_PARCELA")[1] + TamSx3("E2_TIPO")[1] + 1
	nTamFLj := TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]

	If !Empty(SE2->E2_TITPAI)
		cChave := SubStr(SE2->E2_TITPAI,nIniFLj, nTamFLj) + cChave
	Else
		//PIS. COFINS. CSLL. IR.
		If AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_PISNAT" )
			cCpoParc := "E2_PARCPIS"
		ElseIf AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_COFINS" )
			cCpoParc := "E2_PARCCOF"
		ElseIf AllTrim(SE2->E2_NATUREZ) = SuperGetMV( "MV_CSLL" )
		    cCpoParc := "E2_PARCSLL"
		ElseIf AllTrim(SE2->E2_NATUREZ) = &( SuperGetMV( "MV_IRF" ) )
			cCpoParc := "E2_PARCIR"
		EndIf
		cParcela := SE2->E2_PARCELA

		SE2->(DbClearFilter())

		If lFINTPDARF
			cOrigens := Execblock("FINTPDARF",.f.,.f.)
		Endif

		SE2->(DBSetOrder(1))
		SE2->(DBSeek(cSeek))
		cChave := SE2->(E2_FORNECE+E2_LOJA) + cChave

		If !( Empty( SE2->E2_TITPAI ) .and. ( ("GPE" $ SE2->E2_ORIGEM ) .OR. (lFINTPDARF .and. SE2->E2_ORIGEM $ cOrigens)) ) .OR. Alltrim(SE2->E2_ORIGEM)=="FINA376"

			While !SE2->(Eof()) .and. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cSeek .and. SE2->(&cCpoParc) <> cParcela .AND. !lAglut
				lAglut := (Alltrim(SE2->E2_ORIGEM)=="FINA376")  //CASO SEJA TITULO AGLUTINADO
				SE2->(DbSkip())
			EndDo
		Endif

		DbSelectArea("SE2")
		If !Empty(cFilterSE2)
			Set Filter To &cFilterSE2
		Endif

	EndIf
	DbSelectArea("FI9")
	
	If lFI9_FILORI
		nOrder	:= 4 //FI9_FILORI+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
	Else
		nOrder	:= 3 //FI9_FILIAL+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
	EndIf
	
	FI9->(DbSetOrder(nOrder)) 
	If FI9->(DBSeek(cFilSeek+cChave))
		lAchou 	:= .T.
	Else
		FI9->(DbSetOrder(3)) //FI9_FILIAL+FI9_FORNEC+FI9_LOJA+FI9_PREFIX+FI9_NUM+FI9_PARCEL+FI9_TIPO
		If FI9->(DBSeek(xFilial("FI9")+cChave))
			lAchou	:= .T.
		EndIf
	EndIf
	
	If lAchou
		RecLock( "FI9", .F. )
		If lBaixa
			FI9->FI9_STATUS := "B"
		Else
			FI9->FI9_STATUS := "A"
		EndIf
		MsUnlock()
	Endif

	RestArea(aArea)
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F373FORN ³ Autor ³ Leonardo Castro       ³ Data ³ 14.10.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona FI9 no registro selecionado no aCols             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ F373FORN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
Function F373FORN(oSayFor)
Local nAT       := oGet:oBrowse:nAT
Local lGestao   := FWSizeFilial() > 2 // Indica se usa Gestao Corporativa
Local cFilFwFI9 := IIF( lGestao , FwFilial("FI9") , xFilial( "FI9" ) )
Local cChave    := ""

If Empty( cFilFwFI9 )
	cChave := aCols[nAT,6] + (aCols[nAT,7]) + aCols[nAT,2] + aCols[nAT,3] + aCols[nAT,4] + aCols[nAT,5] 
Else
	cChave := aCols[nAT,7] + (aCols[nAT,8]) + aCols[nAT,3] + aCols[nAT,4] + aCols[nAT,5] + aCols[nAT,6]
EndIf

//Posiciona no FI9 o registro selecionado na GetDados
FI9->(DbSetOrder(3))
FI9->(DbSeek(xFilial("FI9")+ cChave )) 
SA2->(DBSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+FI9->(FI9_FORNEC+FI9_LOJA )))

oSayFor:Refresh()
oSayFor:CtrlRefresh()

Return Nil
