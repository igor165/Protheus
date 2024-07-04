#INCLUDE "TMSA900.ch"
#include "PROTHEUS.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

#DEFINE FILDOCCTRC	1
#DEFINE DOCCTRC		2
#DEFINE SERIECTRC		3

#DEFINE RECNODOC		4

Static __nExeDel  := 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa900   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transferencia de documentos por lote							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa900()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Tmsa900

PRIVATE aRotina	:=	MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0004 //"Transferência de Documentos"

//Ajuste de Novos Helps
PutHelp("PTMSA90001",{"Ctrc não encontrado!"},{"CTRC not found!"},{"¡CTRC no encontrado!"},.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"DT6")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa900Vis³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza Docto, com opcao de vizualizar fatura				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa900Vis(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa900Vis(cAlias,nReg,nOpc)
Local aBut := {}
Local cAliasOld := Alias()

Aadd(aBut, {"PRECO", {|| Tmsa900Fat(nOpc)}, STR0008, STR0027}) //"Visualiza Fatura###Vis.Fat."

AxVisual(cAlias,nReg,nOpc,,,,, aBut)
DbSelectArea(cAliasOld)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa900Trf³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transferencia de documentos TMS                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa880Trf(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa900Trf(cAlias,nReg,nOpc)

Local cFilDest	 := Space(TamSx3("DT6_FILDEB")[1])
Local oDlg
Local nOpcA
Local aColsBx
Local aHeadBx	:= {}
Local oBold
Local aFldDT6 	:= {}
Local aFlds		:= {}
Local nX		:= 0
Local nPos		:= 0

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

PRIVATE oTotTrf
PRIVATE nTotTrf  := 0
PRIVATE nTotCred := 0
PRIVATE aRecnos  := {}

aFldDT6 := ApBuildHeader("DT6")

Aadd( aFlds, { , "DT6_FILDOC", , , , "", USADO, "", "" , "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_DOC", , , , "", USADO, "", "", "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_SERIE", , , , "T900ValSer(__oGetDad)", USADO, ,"", "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_FILDEB", , , , "", USADO, "", "", "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_CLIDEV", , , , "", USADO, "", "", "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_LOJDEV", , , , "", USADO, "", "", "V", "", "" , "" } )
Aadd( aFlds, { STR0009, "_SI_NOMCLI"  			, "@!", 30, 0, "", USADO, "C", "", "V", "", "", "" } ) //"Nome"
Aadd( aFlds, { STR0010, "_SI_VALFAT"  	, "@E 999,999,999.99", 15, 2, "", USADO, "N","", "V", "", "", ""  } ) //"Valor do Docto"
Aadd( aFlds, { , "DT6_ACRESC", , , , "", USADO, "", "", "V", "", "" , "" } )
Aadd( aFlds, { , "DT6_DECRES", , , , "", USADO, "", "", "V", "", "" , "" } )

For nX := 1 To Len(aFlds)
	If (nPos := aScan(aFldDT6, {|x| AllTrim(x[2]) == aFlds[nX][2]})) > 0
		aAdd(aHeadBx, {FWX3Titulo(aFldDT6[nPos][2]), aFldDT6[nPos][2], aFldDT6[nPos][3], aFldDT6[nPos][4], aFldDT6[nPos][5], aFlds[nX][6], aFldDT6[nPos][7], aFldDT6[nPos][8], aFlds[nX][9], "V", aFlds[nX][11], aFlds[nX][12], aFlds[nX][13]})
	Else
		aAdd(aHeadBx, aFlds[nX])
	EndIf
Next

aSize(aFlds, 0)
aFlds := Nil

aSize(aFldDT6, 0)
aFldDT6 := Nil

aColsBx := {} 

// Campos a serem editados na GetDados
aCposEdit := {	"DT6_FILDOC", "DT6_DOC", "DT6_SERIE" }
					
DEFINE MSDIALOG oDlg TITLE STR0011 From 0,0 To 35,124 OF oMainWnd //"Transferência de Doctos"

@ 35, 7   SAY STR0012 PIXEL OF oDlg  //"Filial de débito destino"
@ 35,65 MSGET cFilDest  SIZE 20, 9 PIXEL OF oDlg F3 "SM0" //VALID CheckSx3("DVX_FILDEB",cFilDest)

oGet := MsNewGetDados():New(50,2,250,490,GD_INSERT+GD_UPDATE+GD_DELETE,{ || T900LinOk(cFilDest) }, { || T900TudOk(cFilDest, .F.) },/*inicpos*/,aCposEdit,/*freeze*/,99999,/*fieldok*/,/*superdel*/,/*delok*/ { || Tms900Del() } ,oDlg,aHeadBx,aColsBx)
@ 253, 05 SAY STR0014 OF ODlg PIXEL FONT oBold //"Qtde. Transferida"
@ 253, 90 MSGET oTotTrf VAR nTotTrf SIZE 60, 9 OF oDlg PIXEL PICTURE "@E 999,999"	 WHEN .F. FONT oBold

__oGetDad := oGet // Private utilizada nas rotinas de validacao

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
														 {|| aColsBx := aClone(oGet:aCols), If(oGet:TudoOk(), (nOpca:=1,oDlg:End()), Nil ) },;
														 {|| aColsBx := aClone(oGet:aCols), nOpca:=0,If(MsgYesNo(STR0015), oDlg:End(),If(Empty(aColsBx[1][1]),oDlg:End(),Nil))}) CENTER //"Deseja realmente desistir da Transferência?"

If nOpca == 1
	Processa( { || Tm900GrTrf(aHeadBx, aColsBx, cFilDest), STR0016 } ) //"Aguarde! Efeturando transferências..."
Endif

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tm900GrTrf	³ Autor ³ Claudio D. de Souza   ³ Data ³ 14/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as transferencias                                     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide abaixo                							   				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tm900GrTrf()            			    				   				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900		    										   					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tm900GrTrf(aHeadBx, aColsBx, cFilDest)

Local nPosFilDoc 
Local nPosDoc	
Local nPosSerie
Local nX
Local nAscan
Local lApvSolTrf := SuperGetMv("MV_APSOLTR",.T.,.F.)
Local cHistDeb
Local cCodUsr:= RetCodUsr()

	nPosFilDoc 	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
	nPosDoc		:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_DOC" } )
	nPosSerie	:= aScan(aHeadBx, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
	
	nLen := Len(aColsBx)
	Begin Transaction
		// Processa todas os doctos. a serem transferidos
		ProcRegua(nLen)
		For nX := 1 To nLen
			// Se a linha nao estiver deletada	
			If ValType(aColsBx[nX][Len(aHeadBx)+1]) != "L" .Or. !aColsBx[nX][Len(aHeadBx)+1]
				IncProc(STR0017 + aColsBx[nX][nPosFildoc]+"/"+aColsBx[nX][nPosDoc]+"/"+aColsBx[nX][nPosSerie] ) //"Transferindo Docto "
				nAscan := aScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aColsBx[nX][nPosFildoc]+aColsBx[nX][nPosDoc]+aColsBx[nX][nPosSerie] } )
				// Localiza o Ctrc na matriz de recnos para efetuar a baixa no arquivo original
				If nAscan > 0
					// Posiciona no registro do ctrc pois sera utilizado na gravacao do DVX
					DT6->(MsGoto(aRecnos[nAscan][RECNODOC]))
					If RecLock("DT6",.F.)
						If RecLock("DVX",.T.)
							lRet := .T.
							DVX->DVX_FILIAL	:= xFilial("DVX")
							DVX->DVX_FILORIG	:= cFilAnt
							DVX->DVX_NUMSOL	:= GetSxENum("DVX", "DVX_NUMSOL","DVX_NUMSOL"+cEmpAnt)
							DVX->DVX_DATSOL	:= dDataBase
							DVX->DVX_HORSOL	:= StrTran(Left(Time(),5),":","")
							DVX->DVX_FILDOC	:= DT6->DT6_FILDOC
							DVX->DVX_DOC		:= DT6->DT6_DOC
							DVX->DVX_SERIE	   := DT6->DT6_SERIE
							DVX->DVX_SITSOL   := "1"
							DVX->DVX_USRSOL   := cCodUsr
							DVX->DVX_FILDEB	:= cFilDest
							DVX->DVX_CLIDEV	:= DT6->DT6_CLIDEV
							DVX->DVX_LOJDEV	:= DT6->DT6_LOJDEV
							// Grava historico
							cHistDeb := STR0018 + DT6->DT6_FILDEB + STR0019 + cFilDest + STR0020 + DT6->DT6_CLIDEV + "-" + DT6->DT6_LOJDEV //"Transferência por lote da filial "###" para filial "###" do cliente "###" para cliente "
							MSMM(DVX->DVX_CDHSOL,,,cHistDeb,1,,,"DVX","DVX_CDHSOL")
							DT6->DT6_NUMSOL		:= DVX->DVX_NUMSOL
							MsUnlock()
							ConfirmSx8()
							// Se o usuario tem que aprovar a solicitacao, incluir como Em aberto, senao aprova automaticamente
							If lApvSolTrf
								If ! Tm870GrvApv()
									DisarmTransaction()
								Endif
							Endif
						Else	
							DisarmTransaction()
						Endif
						MsUnlock()
					Else
						DisarmTransaction()
					Endif
				Else
			 		DisarmTransaction()			
				Endif	
			Endif	
		Next
	End Transaction	
   DbCommitall()

Return Nil   
   
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T900Valser	³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a serie para pesquisa do ctrc a ser Baixado           	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide abaixo                							   				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ T900ValSer(Params)	     			    				   				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900		    										   					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T900ValSer(oGet)

Local nAscan
Local nDif
Local nPosFilDoc 	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )
Local nPosCliDev	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_CLIDEV" } )
Local nPosLojDev	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_LOJDEV" } )
Local nPosFilDeb	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
Local nPosNomCli	:= aScan(aHeader, {|e| AllTrim(e[2]) == "_SI_NOMCLI" } )
Local lRet := .F.
Local cVar := ReadVar()
Local cAliasOld := Alias()
Local cTmsERP := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP

If cVar != Nil
	If !GdDeleted()
		// Pesquisa CTRC para baixa-lo
		dbSelectArea("DT6")
		DbSetOrder(1)
		If DT6->(MsSeek(xFilial("DT6")+aCols[n][nPosFilDoc]+aCols[n][nPosDoc]+&cVar))
			// Se o docto. ja foi faturado, avisa e nao permite a inclusao
			If !Empty(DT6->DT6_PREFIX+DT6->DT6_NUM+DT6->DT6_TIPO)	.Or.;
				!Empty(DT6->DT6_NUMSOL)
				If cTmsERP == '1' //-- ERP Datasul
					Help(" ",1,"TMSA90002") //"Transferencia somente podera ser realizada se o documento (conhecimento) nao estiver vinculado em uma fatura de transporte a receber e nao tenha solicitacao de transferencia em aberto."
				Else
					Help(" ",1,"FIN62001") //"A transferencia somente podera ser solicitada se o titulo estiver em carteira, não tenha baixas parciais e não tenha solicitaoes em aberto"
				EndIf
			Else
				dbSelectArea("DVX")
				DbSetOrder(4)
				If !Empty(DT6->DT6_NUMSOL) .And.;
					MsSeek(xFilial("DVX")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE+DT6_FILORI))
					Help( " ", 1, "FIN62004",,STR0022+CHR(13)+STR0023 + DVX->DVX_FILDEB, 4, 0) //"já existe solicitação de transferência do docto"###"para filial "
				Else
					SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIDEV+DT6_LOJDEV)))
					lRet := .T.
					aCols[n][nPosNomCli]	:= SA1->A1_NREDUZ
					aCols[n][nPosCliDev]	:= DT6->DT6_CLIDEV
					aCols[n][nPosLojDev]	:= DT6->DT6_LOJDEV
					aCols[n][nPosFilDeb]	:= DT6->DT6_FILDEB
					nTotTrf ++ 
					oTotTrf:Refresh()
					If ValType(oGet) == "O"
						oGet:Refresh()
					Endif
					// Localiza o Ctrc na matriz de Recnos
					nAscan := aScan(aRecnos, {|e| e[FILDOCCTRC]+e[DOCCTRC]+e[SERIECTRC] == aCols[n][nPosFildoc]+aCols[n][nPosDoc]+&cVar } )
					If nAScan = 0
						Aadd(aRecnos, { aCols[n][nPosFilDoc],aCols[n][nPosDoc],&cVar,DT6->(Recno())} )
					Endif	
				Endif	
			Endif	
		Else
			Help(" ",1,"TMSA90001") //"Ctrc não encontrado!"
		Endif
	Endif
Endif	
	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T900LinOk    	³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a linha da GetDados                                    	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide abaixo                							   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ T900LinOk(Params)	     			    				   						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900 		    										   						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T900LinOk(cFilDest)

Return T900TudOk(cFilDest, .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T900TudOk    	³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todos os campos da tela de transferencia							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide abaixo                							   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ T900TudOk(Params)	     			    				   						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900 		    										   						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T900TudOk(cFilDest, lChLinOk)

Local lRet := .T.
Local nPosFilDeb	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDEB" } )
Local nPosFilDoc 	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_FILDOC" } )
Local nPosDoc		:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_DOC" } )
Local nPosSerie	:= aScan(aHeader, {|e| AllTrim(e[2]) == "DT6_SERIE" } )

// Valida os campos que nao podem ficar em branco
lRet := lRet .And. T900NaoVazio(cFilDest, STR0012) //"Filial de débito destino"

// Se a linha nao estiver excluida, valida os campos
If !GdDeleted()
	
	If lRet 
		// Valida os campos que nao podem ficar em branco para o conhecimento
		lRet := lRet .And. T900NaoVazio(aCols[n][nPosFilDoc], aHeader[nPosFilDoc][1])
		lRet := lRet .And. T900NaoVazio(aCols[n][nPosDoc], aHeader[nPosDoc][1])
		lRet := lRet .And. T900NaoVazio(aCols[n][nPosSerie], aHeader[nPosSerie][1])
	Endif	
	
Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³T900NaoVazio 	³ Autor ³ Claudio D. de Souza   ³ Data ³ 10/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida um campo da tela de baixa e exibe Help informando qual campo³±±
±±³          ³esta em branco                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide abaixo                							   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ T900NaoVazio(xVar, cText)			    				   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900 		    										   						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function T900NaoVazio(xVar, cText)

Local lRet := .T.

If Empty(xVar)
	lRet := .F.
	Help(1," ","NVAZIO",,cText,4,0) //"Este campo deve ser informado"
Endif	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TMS900Del ³ Autor ³ Claudio D. de Souza	  | Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificacao apos a exclusao de uma linha						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tms900Del()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum																	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA900																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms900Del

__nExeDel++
// Como esta rotina eh chamada duas vezes pela exclusao na GetDados, controlar
// as chamadas para nao ocorrer erro nos calculos dos dados do rodape  do lancamento
// contabil.
If (__nExeDel%2)==0
	Return .T.
Endif

// A linha nao estava deletata e esta deletando
If ! GdDeleted()
	nTotTrf --
Else
	// A linha Estava deletada e esta desmarcando
	nTotTrf ++
Endif

oTotTrf:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
     
PRIVATE aRotina	:=	{{STR0001	, "AxPesqui"	, 0, 1,0,.F.},; //"Pesquisar"
                    	 {STR0002	, "Tmsa900Vis"	, 0, 2,0,NIL},; //"Visualizar"
                    	 {STR0003	, "Tmsa900Trf"	, 0, 4,0,NIL}} //"Transferir"


If ExistBlock("TM900MNU")
	ExecBlock("TM900MNU",.F.,.F.)
EndIf

Return(aRotina)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa900Fat
Chama a função para visualização da fatura de transporte a receber conforme integração com o
contas a receber (Protheus ou Datasul)
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 03/11/2016
@param [nOpc], Numérico, Opção
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tmsa900Fat(nOpc)

	Local aArea   := GetArea()
	Local cTmsERP := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP
	Local cAliFat := ''
	Local cChvFat := ''
	Local cChvCli := ''

	If cTmsERP == '1' //-- ERP Datasul
		cChvFat := DT6->DT6_NUM
		cAliFat := 'DRT'
	Else
		cChvFat := DT6->(DT6_PREFIX+DT6_NUM+Space(Len(SE1->E1_PARCELA))+DT6_TIPO)
		cAliFat := 'SE1'
	EndIf

	If ! Empty(cChvFat)

		(cAliFat)->(DbSetOrder(1))
		If (cAliFat)->(MsSeek(xFilial(cAliFat) + cChvFat))
		
			cChvCli := Iif(cTmsERP == '1', DRT->(DRT_CLIFAT + DRT_LOJFAT), SE1->(E1_CLIENTE + E1_LOJA))

			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1") + cChvCli))
			TmsA850Vis(cAliFat, "", nOpc)
		Else
			Aviso(STR0005,;  //"Atencao"
			      STR0006,;  //"Fatura nao encontrada"
			      {STR0026}) //"Ok"
		EndIf
	Else
		Aviso(STR0005,;  //"Atencao"
		      STR0007,;  //"Docto. nao faturado!"
		      {STR0026}) //"Ok"
	EndIf
	
	RestArea(aArea)
Return Nil
