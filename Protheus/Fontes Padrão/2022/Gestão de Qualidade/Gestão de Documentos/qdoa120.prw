#INCLUDE "TOTVS.CH"
#INCLUDE "QDOA120.CH"                                                                                                          

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOA120  ³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de distribuicoes de Documentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOA120 ()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³27/03/02³ META ³ Alterado para utilizar o novo conceito de  ³±±
±±³            ³        ³      ³ arquivos de Usuarios do Quality.           ³±±
±±³Eduardo S.  ³21/05/02³015888³ Acerto para enviar corretamente email para ³±±
±±³            ³        ³      ³ o usuario responsavel pela pendencia gerada³±±
±±³Eduardo S.  ³13/08/02³016141³ Alteracao na interface, inclusao de pesqui-³±±
±±³            ³        ³      ³ sas de Usuarios/Departamentos/Documentos e ³±±
±±³            ³        ³      ³ incluido a opcao de filtro por Tipo Recbto.³±±
±±³Eduardo S.  ³22/08/02³ ---- ³ Acerto para apresentar somente os usuarios/³±±
±±³            ³        ³      ³ deptos da filial selecionada na pesquisa.  ³±±
±±³Eduardo S.  ³27/11/02³------³ Acerto para gravar corretamente a filial do³±±
±±³            ³        ³      ³ depto/usuario qdo utiliz. filial exclusiva.³±±
±±³Eduardo S.  ³08/01/03³ ---- ³ Alterado para permitir pesquisar usuarios  ³±±
±±³            ³        ³      ³ de outras filiais.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA120()

Local oDlg
Local oBtn01
Local oBtn02
Local oBtn04
Local oBtn05
Local oBtn07
Local oBtn08
Local oBtn10
Local oBtn11

Private aUsrMat  := QA_USUARIO()
Private lApelido := aUsrMat[1]
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cTipDest := " "
Private nTP      := 0
Private nItdp    := 1
Private cDocto   := Space(16)
private cRev     := Space(3)
Private cMat     := Space(6)
Private cNome    := Space(30)
Private cDepto   := Space(30)
Private cDepto1  := Space(9)
Private cFil     := FWSizeFilial() //Space(2)
Private cCargo   := Space(4)
Private cTpDist  := Space(1)
Private nQtdCop  := 1
Private lChk01   := .T.
Private lChk02   := .T.
Private lChk03   := .T.
Private lChk04   := .T.
Private cFilMat  := xFilial("QAA")
Private cFilDep  := xFilial("QAD")
Private nQaConpad:= 4
Private clibvias := GetMv("MV_QDOLNV",.T.,"1")
Private cFilPst  := cFilAnt

If !lApelido
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
	Return .f.
Endif

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 260,460 OF oMainWnd PIXEL // "Manuten‡„o de Distribui‡„o"


@ 035,005 TO 130,227 OF oDlg PIXEL

@ 045,025 BUTTON oBtn01 PROMPT OemToAnsi(STR0002) SIZE 075,015 OF oDlg PIXEL; //"Distribuir por Destin tario"
				ACTION(EscUsrPst(),cTipDest:= "I",If(nItdp == 1,nTP:= 1,nTP:= nItdp+1),If(nTP <= 3,QDODIST0(nTP),.F.))

@ 045,130 BUTTON oBtn02 PROMPT OemToAnsi(STR0003) SIZE 075,015 OF oDlg PIXEL; //"Distribuir por Documento"
				ACTION(nTP:= 2,cTipDest:= "I",QDODIST0(nTP))

@ 065,025 BUTTON oBtn04 PROMPT OemToAnsi(STR0004) SIZE 075,015 OF oDlg PIXEL; //"Inativar por Destin tario"
				ACTION(EscUsrPst(),cTipDest:= "E",If(nItdp == 1,nTP:= 1,nTP:= nItdp+1),If(nTP <= 3,QDODIST0(nTP),.F.))

@ 065,130 BUTTON oBtn05 PROMPT OemToAnsi(STR0005) SIZE 075,015 OF oDlg PIXEL; //"Inativar por Documento"
				ACTION(nTP:= 2,cTipDest:= "E",QDODIST0(nTP))

@ 085,025 BUTTON oBtn07 PROMPT OemToAnsi(STR0006) SIZE 075,015 OF oDlg PIXEL; //"Ativar por Destinat rio"
				ACTION(EscUsrPst(),cTipDest:= "R",If(nItdp == 1,nTP:= 1,nTP:= nItdp+1),If(nTP <= 3,QDODIST0(nTP),.F.))

@ 085,130 BUTTON oBtn08 PROMPT OemToAnsi(STR0007) SIZE 075,015 OF oDlg PIXEL; //"Ativar por Documento"
				ACTION(nTP:= 2,cTipDest:= "R",QDODIST0(nTP))

@ 105,025 BUTTON oBtn10 PROMPT OemToAnsi(STR0011) SIZE 075,015 OF oDlg PIXEL; //"Documentos Cancelados"
				ACTION(QDOA121())

@ 105,130 BUTTON oBtn011 PROMPT OemToAnsi(STR0081) SIZE 075,015 OF oDlg PIXEL;  //"Localizadores"
				ACTION(nTP:= 4,QDODIST0(nTP))

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) CENTERED

DbSelectArea("QAA")
Set Filter To

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ESCUSRPST³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 02/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona Destinatario                       		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ESCUSRPST()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EscUsrPst()

Local oDlg
Local oItdp

nItdp:= 1
nTP  := 0

DEFINE MSDIALOG oDlg FROM 000,000 TO 100,295 TITLE OemToAnsi(STR0013) OF oMainWnd PIXEL//"Destinat rio"

@ 003,005 TO 045,100 LABEL OemToAnsi(STR0071) OF oDlg PIXEL // "Tipo Destino"
@ 010,013 RADIO oItdp VAR nItdp ITEMS;
					OemToAnsi(STR0014),; //"Usu rios"
					OemToAnsi(STR0015) ; //"Pastas"
			  3D SIZE 040,015 OF oDlg PIXEL

DEFINE SBUTTON FROM 015,112 TYPE 1 ENABLE OF oDlg;
			ACTION oDlg:end()

DEFINE SBUTTON FROM 030,112 TYPE 2 ENABLE OF oDlg;
			ACTION (nItDp:= 3,oDlg:end())

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDODIST0 ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de Distribuicoes Extra 							        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDODIST0( nTP )                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDODIST0( nTP )

Private oQDC
Private oQDG
Private oQDH
Private oQAD
Private bQDCLine
Private bQDGLine
Private bQDHLine
Private bQADLine
Private aQDC     := {}
Private aQDCRegs := {}
Private aQDG     := {}
Private aQDH     := {}
Private aQAD     := {}
Private hOK      := LoadBitmap(GetResources(),"LBTIK")
Private hNo      := LoadBitmap(GetResources(),"LBNO")
Private cFilApSol:= Space(FWSizeFilial()) //Space(02)
Private cCodApSol:= Space(06)
Private cFilApDes:= Space(FWSizeFilial()) //Space(02)
Private cCodApDes:= Space(06)
Private cDtEmiss := dDatabase
Private Inclui   := .F.

Public cCodMat  := SPACE(LEN(QAA->QAA_MAT))
Public cFilCod  := Space(FWSizeFilial())//SPACE(LEN(QAA->QAA_FILIAL))
Public cDeptoMat:= SPACE(LEN(QAA->QAA_CC))

If nTP == 2 .Or. nTP == 3
	cCodMat  := QAA->QAA_MAT
	cFilCod  := QAA->QAA_FILIAL
	cDeptoMat:= QAA->QAA_CC
EndIf

If !VerSenha(92)
	MsgAlert(OemToAnsi(STR0017),OemToAnsi(STR0010)) //"N¡vel de acesso restrito" ### "Aten‡„o"
	Return .F.
EndIf

If nTP == 1
	MsgRun(OemToAnsi(STR0021),OemToAnsi(STR0022),{ || SeleQAA() } ) //"Selecionando Usu rios" ### "Aguarde..."
	SeleUsr()

Elseif nTP == 2
	MsgRun(OemToAnsi(STR0023),OemToAnsi(STR0022),{ || SeleQDH() } ) //"Selecionando Documentos" ### "Aguarde..."
	SeleDoc()

Elseif nTP == 3
	MsgRun( OemToAnsi(STR0024),OemToAnsi(STR0022),{ || SeleQAD() } ) //"Selecionando Departamentos" ### "Aguarde..."
	MsgRun( OemToAnsi(STR0025),OemToAnsi(STR0022),{ || SeleQDC() } ) //"Selecionando Pastas" ### "Aguarde..."
	SeleCC()
	
Elseif nTP == 4
	MsgRun(OemToAnsi(STR0023),OemToAnsi(STR0022),{ || SeleQDH() } ) //"Selecionando Documentos" ### "Aguarde..."
	SeleDoc()				
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleUsr  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona usuarios para distribuicao de Documentos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleUsr()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleUsr()

Local oDlg
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local cQDG:= " "

If nTP == 2 .Or. nTP == 3
	If Empty(cDocto)
		MsgAlert(OemToAnsi(STR0026),OemToAnsi(STR0010)) // "Documento n„o selecionado" ### "Aten‡„o"
		Return .f.
	Endif
	MsgRun(OemToAnsi(STR0021),OemToAnsi(STR0022),{ || SeleQAA() } ) //"Selecionando Usu rios" ### "Aguarde..."
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0027) FROM 000,000 TO 245,625 OF oMainWnd PIXEL //"Sele‡„o de Usu rio"

If nTP == 1
	@ 005,004 TO 120,310 LABEL OemToAnsi(STR0029) OF oDlg PIXEL //"Usu rios"
	@ 015,007 LISTBOX oQDG;
					VAR cQDG FIELDS;
						HEADER AllTrim(TitSx3("QAA_FILIAL")[1] ),;
								 AllTrim(TitSx3("QAA_MAT")[1] ),;
 								 AllTrim(TitSX3("QAA_NOME")[1] ),;
								 AllTrim(TitSX3("QAA_CC")[1] );
					SIZE 270,100 OF oDlg PIXEL WHEN Len(aQDG) > 0;
					ON CHANGE (HabUsr(oQDG:nAt),oQDG:Refresh())

	DEFINE SBUTTON	oBtn1 FROM 015,279 TYPE 1 ENABLE OF oDlg;
				ACTION SeleDoc()
	oBtn1:cToolTip:= OemToAnsi(STR0038) //"Sele‡„o de Documentos por Usu rio"

	DEFINE SBUTTON oBtn2 FROM 029,279 TYPE 2 ENABLE OF oDlg;
				ACTION oDlg:End()
	oBtn2:cToolTip:= OemToAnsi(STR0039) //"Cancelar"	

	DEFINE SBUTTON oBtn3 FROM 043,279 TYPE 11 ENABLE OF oDlg;
				ACTION EditUsr()
	oBtn3:cToolTip:= OemToAnsi(STR0063) //"Editar Usuario"
	                   
	@ 057,279 BUTTON oBtn4 PROMPT OemToAnsi(STR0072) ;
		  ACTION (QD120PesqU(),(HabUsr(oQDG:nAt),oQDG:Refresh())) ;
		  SIZE 026,012 OF oDlg PIXEL 
			oBtN4:cToolTip := OemToAnsi(STR0072) 
	
	DEFINE SBUTTON oBtn5 FROM 071,279 TYPE 17 ENABLE OF oDlg;
				ACTION QD120Filt()

ElseIf nTP == 2 .Or. nTP == 3
	@ 042,002 TO 121,280 LABEL(If(cTipDest == "I",OemToAnsi(STR0029),If(cTipDest == "E",OemToAnsi(STR0036),If(cTipDest == "R",OemToAnsi(STR0037)," ")))) OF oDlg PIXEL //"Usu rios" ### "Usu rios com possibilidade de inativa‡„o do Documento" ### "Usu rios com possibilidade de ativa‡„o do Documento"
	@ 049,006 LISTBOX oQDG;
					VAR cQDG	FIELDS ;
						HEADER " ",;
							AllTrim(TitSx3("QAA_FILIAL")[1] ),;
							AllTrim(TitSx3("QAA_MAT")[1] ),;
							AllTrim(TitSX3("QAA_NOME")[1] ),;
							AllTrim(TitSX3("QAA_CC")[1] );
					SIZE 270,068 OF oDlg PIXEL;
					ON DBLCLICK(HabUsr(oQDG:nAt),oQDG:Refresh())

	@ 003,002 TO 040,280 LABEL OemToAnsi( STR0032 ) OF oDlg PIXEL //"Documentos"
	@ 011,007 SAY OemToAnsi(STR0033) SIZE 070,010 OF oDlg PIXEL //"Documento"
	@ 011,055 GET oDocto VAR cDocto SIZE 070,010 OF oDlg PIXEL
	oDocto:lReadOnly:= .T.

	@ 011,140 SAY OemToAnsi( STR0034 ) SIZE 035,010 OF oDlg PIXEL //"Revis„o"
	@ 011,165 GET oRev VAR	cRev SIZE 040,010 OF oDlg PIXEL
	oRev:lReadOnly:= .T.

	@ 023,007 SAY OemToAnsi(STR0035) SIZE 070,010 OF oDlg PIXEL //"T¡tulo"
	@ 023,055 GET oTitulo VAR cTitulo SIZE 150,010 OF oDlg PIXEL
	oTitulo:lReadOnly:= .T.

	DEFINE SBUTTON	oBtn1 FROM 002,282 TYPE 1 ENABLE OF oDlg;
				ACTION ( Continua(nTP) )
	oBtn1:cToolTip:= OemToAnsi(STR0040) //"Continua"
	oBtn1:cCaption:= OemToAnsi(STR0040) //"Continua"
	DEFINE SBUTTON oBtn2 FROM 016,282 TYPE 2 ENABLE OF oDlg;
				ACTION oDlg:End()
	oBtn2:cToolTip:= OemToAnsi(STR0039) //"Cancelar"

	DEFINE SBUTTON oBtn3 FROM 030,282 TYPE 11 ENABLE OF oDlg;
				ACTION EditUsr()
	oBtn3:cToolTip:= OemToAnsi(STR0063) //"Editar Usuario"

	@ 044,282 BUTTON oBtn4 PROMPT OemToAnsi(STR0094) ;
	  ACTION MarQDG();
	  SIZE 026,012 OF oDlg PIXEL 
		oBtn4:cToolTip := OemToAnsi(STR0094)
	
    @ 058,282 BUTTON oBtn5 PROMPT OemToAnsi(STR0072) ;
	  ACTION QD120PesqU();
	  SIZE 026,012 OF oDlg PIXEL 
		oBtn5:cToolTip := OemToAnsi(STR0072)

EndIf

oQDG:SetArray( aQDG )
oQDG:bLine:= bQDGLine

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleDoc  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona Documentos para distribuicao de usuarios         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleDoc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleDoc()

Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oDlgDoc
Local cQDH:= " "
Local lQDHFil	 := FwModeAccess("QDH") == "C" //Empty(xFilial("QDH"))

Private cTitulo:= Space(100)
Private cChTxt := Space(8)

If nTP == 1
	If Empty(cNome)
		MsgAlert(OemToAnsi(STR0042),OemToAnsi(STR0010)) //"Usu rio n„o selecionado" ### "Aten‡„o"
		Return .f.
	Endif
EndIf

If nTP == 1 .Or. nTP == 3
	If nTP == 3
		If aScan(aQAD,{|X| X[1] == .T.}) == 0
			Return .f.
		EndIf
	Endif
	MsgRun(OemToAnsi(STR0043),OemToAnsi(STR0010),{ || SeleQDH() } )  // "Selecionando Documentos" ### "Aten‡„o"
EndIf

DEFINE MSDIALOG oDlgDoc TITLE OemToAnsi(STR0028) FROM 000,000 TO 245,625 OF oMainWnd PIXEL // "Sele‡„o de Documentos"

If nTP == 1
	@ 042,002 TO 121,280 LABEL (If(cTipDest == "I",OemToAnsi(STR0032),If(cTipDest == "E",OemToAnsi(STR0044),If(cTipDest == "R",OemToAnsi(STR0045)," "))) ) OF oDlgDoc PIXEL // "Documentos" ### "Documentos com possibilidade de inativa‡„o pelo usu rio" ### "Documentos com possibilidade de ativa‡„o pelo usu rio"
	@ 049,006 LISTBOX oQDH	VAR cQDH FIELDS;
					HEADER " ",;
						AllTrim(TitSX3("QDH_CODTP")[1] ),;						
						AllTrim(TitSX3("QDH_DOCTO")[1] ),;
						AllTrim(TitSX3("QDH_RV")[1] ),;
						AllTrim(TitSX3("QDH_TITULO")[1] );
				SIZE 270,068 OF oDlgDoc PIXEL;
				ON DBLCLICK(HabQDH(oQDH:nAt),oQDH:Refresh())

	@ 003,002 TO 040,280 LABEL OemToAnsi(STR0029) OF oDlgDoc PIXEL //"Usu rios"
	@ 011,007 SAY OemToAnsi(STR0030) SIZE 070,010 OF oDlgDoc PIXEL //"Nome do Usu rio"
	@ 011,055 GET oNome VAR cNome SIZE 150,010 OF oDlgDoc PIXEL
	oNome:lReadOnly:= .T.

	@ 023,007 SAY OemToAnsi(STR0031) SIZE 070,010 OF oDlgDoc PIXEL //"Departamento"
	@ 023,055 GET oDepto VAR cDepto1 SIZE 150,010 OF oDlgDoc PIXEL
	oDepto:lReadOnly:= .T.
	
	DEFINE SBUTTON oBtn1 FROM 002,282 TYPE 1 ENABLE OF oDlgDoc;
				ACTION Continua(nTP) WHEN Len( aQDH ) > 0
	oBtn1:cToolTip:= OemToAnsi(STR0040) //"Continua"
	oBtn1:cCaption:= OemToAnsi(STR0040) //"Continua"
				
	DEFINE SBUTTON oBtn2 FROM 016,282 TYPE 2 ENABLE OF oDlgDoc;
			ACTION oDlgDoc:End()
	oBtn2:cToolTip:= OemToAnsi(STR0039) //"Cancelar"
    
	@ 030,282 BUTTON oBtn3 PROMPT OemToAnsi(STR0094) ;
	  ACTION MarQDH();
	  SIZE 026,012 OF oDlgDoc PIXEL 
		oBtn3:cToolTip := OemToAnsi(STR0094)

    @ 044,282 BUTTON oBtn4 PROMPT OemToAnsi(STR0072) ;
	  ACTION QD120PesqD() ;
	  SIZE 026,012 OF oDlgDoc PIXEL 
		oBtn4:cToolTip := OemToAnsi(STR0072)	

ElseIf nTP == 2 .Or. nTP == 3
	@ 005,004 TO 120,310 LABEL OemToAnsi(STR0032) OF oDlgDoc PIXEL //"Documentos"
	If nTP == 2
		@ 015, 007 LISTBOX oQDH	VAR cQDH	FIELDS;
						HEADER;
							AllTrim(TitSX3("QDH_CODTP")[1] ),;						
							AllTrim(TitSX3("QDH_DOCTO")[1] ),;
							AllTrim(TitSX3("QDH_RV")[1] ),;
							AllTrim(TitSX3("QDH_TITULO")[1] );
						SIZE 270,100 OF oDlgDoc PIXEL ;
						WHEN Len(aQDH) > 0;
						ON CHANGE (HabQDH(oQDH:nAt),oQDH:Refresh())
	Else
		If lQDHFil

			@ 015,007 LISTBOX oQDH	VAR cQDH FIELDS ;
							HEADER " ",;
								AllTrim(TitSX3("QDH_CODTP")[1] ),;						
								AllTrim(TitSX3("QDH_DOCTO")[1] ),;
								AllTrim(TitSX3("QDH_RV")[1] ),;
								AllTrim(TitSX3("QDH_TITULO")[1] );
							SIZE 270,100 OF oDlgDoc PIXEL ;
							WHEN Len(aQDH) > 0;
							ON DBLCLICK(HabQDH(oQDH:nAt),oQDH:Refresh())
		
		Else   
		
			@ 015, 007 LISTBOX oQDH	VAR cQDH	FIELDS;
					HEADER " ",; 
						AllTrim(TitSX3("QDH_FILIAL")[1]),;						
						AllTrim(TitSX3("QDH_CODTP")[1] ),;						
						AllTrim(TitSX3("QDH_DOCTO")[1] ),;
						AllTrim(TitSX3("QDH_RV")[1] ),;
						AllTrim(TitSX3("QDH_TITULO")[1] );
					SIZE 270,100 OF oDlgDoc PIXEL ;
					WHEN Len(aQDH) > 0;
					ON DBLCLICK(HabQDH(oQDH:nAt),oQDH:Refresh())				
		
		Endif			                                        
	
	EndIf

	If nItdp == 2 .And. nTP == 3
		DEFINE SBUTTON oBtn1 FROM 015,279 TYPE 1 ENABLE OF	oDlgDoc;
					ACTION FQD120Past()
		oBtn1:cToolTip:=OemToAnsi(STR0040) //"Continua"
		oBtn1:cCaption:= OemToAnsi(STR0040) //"Continua"

	Else
		DEFINE SBUTTON oBtn1 FROM 015,279 TYPE 1 ENABLE OF	oDlgDoc;
					ACTION SeleUsr()
		oBtn1:cToolTip:=OemToAnsi( STR0046 ) //"Sele‡„o de Usu rios por Documento"

	EndIf

	DEFINE SBUTTON oBtn2 FROM 029,279 TYPE	2 ENABLE OF	oDlgDoc;
			ACTION oDlgDoc:End()			
	oBtn2:cToolTip:=OemToAnsi( STR0039 ) //"Cancelar"	

	@ 043,279 BUTTON oBtn3 PROMPT OemToAnsi(STR0072) ;
	  ACTION (QD120PesqD(), (HabQDH(oQDH:nAt),oQDH:Refresh()) ) ;
	  SIZE 026,012 OF oDlgDoc PIXEL 
		oBtn3:cToolTip := OemToAnsi(STR0072) 
	
ElseIf nTP == 4
	@ 005,004 TO 120,310 LABEL OemToAnsi(STR0032) OF oDlgDoc PIXEL //"Documentos"
	IF lQDHFil
		@ 015, 007 LISTBOX oQDH	VAR cQDH	FIELDS;
				HEADER " ",; 
					AllTrim(TitSX3("QDH_CODTP")[1] ),;						
					AllTrim(TitSX3("QDH_DOCTO")[1] ),;
					AllTrim(TitSX3("QDH_RV")[1] ),;
					AllTrim(TitSX3("QDH_TITULO")[1] );
				SIZE 270,100 OF oDlgDoc PIXEL ;
				WHEN Len(aQDH) > 0;
				ON DBLCLICK(HabQDH(oQDH:nAt),oQDH:Refresh())					
	Else   
		@ 015, 007 LISTBOX oQDH	VAR cQDH	FIELDS;
				HEADER " ",; 
					AllTrim(TitSX3("QDH_FILIAL")[1]),;						
					AllTrim(TitSX3("QDH_CODTP")[1] ),;						
					AllTrim(TitSX3("QDH_DOCTO")[1] ),;
					AllTrim(TitSX3("QDH_RV")[1] ),;
					AllTrim(TitSX3("QDH_TITULO")[1] );
				SIZE 270,100 OF oDlgDoc PIXEL ;
				WHEN Len(aQDH) > 0;
				ON DBLCLICK(HabQDH(oQDH:nAt),oQDH:Refresh())				
	Endif			                                        
	
	DEFINE SBUTTON oBtn1 FROM 016,279 TYPE 1 ENABLE OF	oDlgDoc;
				ACTION SeleLoc()   				
	oBtn1:cToolTip:=OemToAnsi(STR0082)  //"Sele‡ão de Localizador"

	DEFINE SBUTTON oBtn2 FROM 030,279 TYPE	2 ENABLE OF	oDlgDoc;
			ACTION oDlgDoc:End()			
	oBtn2:cToolTip:=OemToAnsi(STR0039) //"Cancelar"	
  
	@ 044,279 BUTTON oBtn3 PROMPT OemToAnsi(STR0094) ;
	  ACTION MarQDH();
	  SIZE 026,012 OF oDlgDoc PIXEL 
		oBtn3:cToolTip := OemToAnsi(STR0094)  

	@ 058,279 BUTTON oBtn3 PROMPT OemToAnsi(STR0072) ;
		  ACTION (QD120PesqD(), (oQDH:Refresh()) ) ;
		  SIZE 026,012 OF oDlgDoc PIXEL 
			oBtn3:cToolTip := OemToAnsi(STR0072) 
EndIf

oQDH:SetArray(aQDH)
oQDH:bLine:= bQDHLine

ACTIVATE MSDIALOG oDlgDoc CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQD120Past ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a distribuicao e baixa por PASTA dos documentos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Continua( nTP )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FQD120Past

Local lOk     := .T.
Local cStatus := ""
Local nCt     := 0 
Local lFound  := .F.
Local aRevis  := {}  // Array das revisoes Existentes do Documento
Local lRev    := .f. // Controla de deve ou nao processar as revisoes
Local cBuscaD := ""
Local nI      := 0
Local nOrdQAA := 0
Local nRegQAA := 0
Local aUsrMail:= {}
Local aUsrMat := QA_USUARIO()
Local nCZ	  := 1
Local nQAD 	  := 1
Local nDoc    := 1
Local lAchou  := .F.
Local lQDOAP23 := ExistBlock("QDOAP23")
Local lQDOAP21 := ExistBlock("QDOAP21")

If Len(aQDH) == 0
	Return .F.
EndIf

If !MsgYesNo(OemToAnsi(STR0052),OemToAnsi(STR0010)) //"Confirma a opera‡„o ?" ### "Aten‡„o"
	Return .F.
EndIf

For nCt:= 1 To 2
	If nCt == 1
		cStatus:= "I  "
	ElseIf nCt == 2
		cStatus:= "L  "
	Endif
	
	For nDoc:= 1 to Len(aQDH)
		If aQDH[nDoc,1] == .T.
			For nQAD := 1 to Len(aQAD)
				If aQAD[nQAD,1] == .T.
					lRev:=.F.
					If cTipDest== "I"
						aRevis:={}
						lRev := f_ProcRv(aQDH[ nDoc, 5],aQDH[ nDoc, 2],@aRevis)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ No caso da Existencia de Revisoes    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI:= 1 To If(lRev,Len(aRevis),1)
							If !lRev .Or. (lRev .And. aRevis[nI,2] == "L  ")
								QD1->(dbSetOrder(7))

								If cStatus == "I  "
									lFound := .F.
									If QD1->(Dbseek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
										While 	QD1->QD1_FILIAL = aQDH[ nDoc, 5] .And.;
												QD1->QD1_DOCTO = aQDH[ nDoc, 2] .And.;
												QD1->QD1_RV = iif(!lRev,aQDH[ nDoc, 3],aRevis[nI,1]) .And.;
												QD1->QD1_DEPTO = cMatDep .And. QD1->QD1_FILMAT = cMatFil .And.;
												QD1->QD1_MAT = cMatCod .And. QD1->QD1_TPPEND = cStatus

											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Ponto de Entrada Para tratamento com outras tipos de Copias³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                            IF lQDOAP23
                                            	IF Execblock("QDOAP23",.F.,.F.,{QD1->QD1_FILMAT,QD1->QD1_MAT,QD1->QD1_TPDIST}) .AND. ;
													QD1->QD1_DTGERA == dDataBase .And. 	QD1->QD1_HRGERA == SubStr(Time(),1,5)
													lFound := .T.
													Exit                                            	 	
                                            	Endif
											Endif   
											
											If QD1->QD1_TPDIST == "2" .And. ;
												QD1->QD1_DTGERA == dDataBase .And. 	QD1->QD1_HRGERA == SubStr(Time(),1,5)
												lFound := .T.
												Exit
											Endif

											QD1->(DbSkip())
										EndDo
									Endif
								Else	
									lFound := .F.
								   	If QD1->(dbseek(aQDH[ nDoc, 5]+aQDH[ nDoc, 2]+iif(!lRev,aQDH[ nDoc, 3],aRevis[nI,1])+aQAD[nQAD,3]+aQAD[nQAD,5]+aQAD[nQAD,6]+cStatus))
										While 	QD1->QD1_FILIAL = aQDH[ nDoc, 5] .And.;
												QD1->QD1_DOCTO = aQDH[ nDoc, 2] .And.;
												QD1->QD1_RV = iif(!lRev,aQDH[ nDoc, 3],aRevis[nI,1]) .And.;
												QD1->QD1_DEPTO = aQAD[nQAD,3] .And. QD1->QD1_FILMAT = aQAD[nQAD,5] .And.;
												QD1->QD1_MAT = aQAD[nQAD,6] .And. QD1->QD1_TPPEND = cStatus

											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Ponto de Entrada Para tratamento com outras tipos de Copias³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
                                            IF lQDOAP23
                                            	IF Execblock("QDOAP23",.F.,.F.,{QD1->QD1_FILMAT,QD1->QD1_MAT,QD1->QD1_TPDIST})
	                                            	lFound := .T.
													Exit 
												Endif
											Endif	

											If QD1->QD1_TPDIST == "2"
												lFound := .T.
												Exit
											Endif
											
											QD1->(DbSkip())
										EndDo
									Endif
								EndIf	
								
								If lFound
									If cStatus <> "I  "
										RecLock("QD1",.F.)
										QD1->QD1_SIT   := "A"
										QD1->QD1_DTGERA:= dDataBase
										QD1->QD1_HRGERA:= If(cStatus <> "I  ",QSomaH(SubStr(Time(),1,5)),SubStr(Time(),1,5))
										QD1->QD1_DTBAIX:= If(cStatus <> "I  ",If(lOk,dDataBase,CtoD(" ")),dDataBase)
										QD1->QD1_HRBAIX:= If(cStatus <> "I  ",If(lOk,QSomaH(SubStr(Time(),1,5))," "),SubStr(Time(),1,5))
										QD1->(MsUnlock())
									Endif
								Else
									RecLock("QD1",.T.)
									QD1->QD1_FILIAL:= aQDH[nDoc,5]
									QD1->QD1_DOCTO := aQDH[nDoc,2]
									QD1->QD1_RV    := If(!lRev,aQDH[nDoc,3],aRevis[nI,1])
									If cStatus == "I  "
										QD1->QD1_FILMAT:= cMatFil
										QD1->QD1_MAT   := cMatCod
										QD1->QD1_DEPTO := cMatDep
									Else
										QD1->QD1_FILMAT:= aQAD[nQAD,5]
										QD1->QD1_MAT   := aQAD[nQAD,6]
										QD1->QD1_DEPTO := aQAD[nQAD,3]
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Ponto de Entrada Para tratamento com outras tipos de Copias³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
                                    IF lQDOAP21
	                                  	QD1->QD1_TPDIST:= aQAD[nQAD,Len(aQAD[nQAD])]	
	                                ELSE
		                                QD1->QD1_TPDIST:= "2"  	
                                    EndiF									
									QD1->QD1_CARGO := aQAD[nQAD,8]
									QD1->QD1_CHAVE := aQDH[nDoc,6]									
									QD1->QD1_DTGERA:= dDataBase
									QD1->QD1_HRGERA:= SubStr(Time(),1,5)
									QD1->QD1_DTBAIX:= If(cStatus <> "I  ",If(lOk,dDataBase,CtoD(" ")),dDataBase)
									QD1->QD1_HRBAIX:= If(cStatus <> "I  ",If(lOk,SubStr(Time(),1,5)," "),SubStr(Time(),1,5))
									QD1->QD1_TPPEND:= cStatus
									QD1->QD1_PENDEN:= "B"
									QD1->QD1_LEUDOC:= "S"
									QD1->QD1_APROVA:= "N"
									QD1->QD1_FMATBX:= cMatFil
									QD1->QD1_MATBX := cMatCod
									QD1->QD1_DEPBX := cMatDep
									QD1->QD1_DISTNE:= "E"
									QD1->QD1_SIT   := "A"
									QD1->(MsUnlock() )
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Envia email para o usuario da Pendencia Gerada      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								nOrdQAA:= QAA->(IndexOrd())
								nRegQAA:= QAA->(Recno())
								QAA->(DbSetOrder(1))
								If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT))
									If (QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND <> "D") .And. ;
										(!Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1") .and. cTpDist <> "4"
										If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
					                     	fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,QDH->QDH_TITULO,QAA->QAA_EMAIL,cStatus,cFilCod,QAA->QAA_APELID,"","","",,QDH->QDH_CODTP,QDH->QDH_DTVIG)
					    		   		EndIf								
									EndIf
								EndIf
								QAA->(dbSetOrder(nOrdQAA))
								QAA->(dbGoTo(nRegQAA))					
								
								QDG->(dbSetOrder(2))
								If cStatus == "L  "
									If !QDG->(Dbseek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC))
										RecLock("QDG",.T.)
										QDG->QDG_FILIAL := aQDH[nDoc,5]
										QDG->QDG_DOCTO  := aQDH[nDoc,2]
										QDG->QDG_RV     := If(!lRev,aQDH[nDoc,3],aRevis[nI,1])
										QDG->QDG_MAT    := aQAD[nQAD,6]
										QDG->QDG_FILMAT := aQAD[nQAD,5]
										QDG->QDG_DEPTO  := aQAD[nQAD,3]

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Ponto de Entrada Para tratamento com outras tipos de Copias³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
										IF lQDOAP21													
	                                  		QDG->QDG_TPRCBT := aQAD[nQAD,Len(aQAD[nQAD])]	
	                                	ELSE
		                                	QDG->QDG_TPRCBT := "2"											
                                    	EndiF
                                    	
	                                    nQtdCop	:=aQAD[nQAD,9] //nrCopias
										QDG->QDG_NCOP   := nQtdCop
										QDG->QDG_RECEB  := "S"
										QDG->QDG_TIPO   := "P"
										QDG->QDG_CODMAN := cQDC
										QDG->QDG_SIT    := "A"
										QDG->(MsUnlock() )
										If cLibVias == "2"
											GrvLog(.T.,OemToAnsi(STR0056),"U",1,cMatFil,cMatCod,aQAD[nQAD,5],aQAD[nQAD,6],"1",nDoc) //"Distribui‡„o Extra por Pasta"
										Else
										GrvLog(.T.,OemToAnsi(STR0056),"U",1,aQAD[nQAD,5],aQAD[nQAD,6],aQDH[nDoc,5],aQDH[nDoc,2],"1",nDoc) //"Distribui‡„o Extra por Pasta"
										Endif
									Else
										RecLock("QDG",.F.)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Ponto de Entrada Para tratamento com outras tipos de Copias³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
										IF lQDOAP21													
	                                  		QDG->QDG_TPRCBT := aQAD[nQAD,Len(aQAD[nQAD])]	
	                                	ELSE
		                                	QDG->QDG_TPRCBT := "2"											
                                    	EndiF
                                    	
	                                    nQtdCop			:=aQAD[nQAD,9] //nrCopias
										IF clibvias == "2"
											If QDG->QDG_SIT <> "I" 
										   		QDG->QDG_NCOP	+= nQtdCop
											Else
												QDG->QDG_NCOP	= nQtdCop
											Endif
										Else
											QDG->QDG_NCOP	:= nQtdCop
										Endif
										QDG->QDG_SIT	:= "A"
										QDG->QDG_RECEB	:= "S"
										QDG->(MsUnlock())
										IF clibvias  == "2"
											DbSelectArea("QDE")
											DbSetOrder(1) 
											IF QDE->(DbSeek(XFilial("QDE")+QDG->QDG_DOCTO+QDG->QDG_RV) )
												While QDE->(!EOF()) .and. QDE->QDE_FILIAL+QDE->QDE_DOCTO+QDE->QDE_RV == XFilial("QDE")+QDG->QDG_DOCTO+QDG->QDG_RV
													If QDE->QDE_FILDES+Alltrim(QDE->QDE_MATDES) == aQAD[nQAD,5]+Alltrim(aQAD[nQAD,6]) .and. ALLTRIM(QDE->QDE_MOTIVO) == STR0056 
														lAchou:=.T. 
														Exit
													Endif   
													QDE->(DBSKIP())
												Enddo 
											Endif     
											If lAchou
                                            	Reclock("QDE",.F.)
                                            	QDE->QDE_NCOP += nQtdCop
                                                MsUnlock()
           									Else 
           										GrvLog(.T.,OemToAnsi(STR0056),"U",1,cMatFil,cMatCod,aQAD[nQAD,5],aQAD[nQAD,6],"1",nDoc) //"Distribui‡„o Extra por Pasta"
           									Endif
										Endif 
									EndIf							
									QD1->(dbSetOrder(1))

									If QDJ->(!DbSeek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]))
										Reclock("QDJ",.T.)
										QDJ->QDJ_FILIAL := aQDH[nDoc,5]
										QDJ->QDJ_DOCTO  := aQDH[nDoc,2]
										QDJ->QDJ_RV     := If(!lRev,aQDH[nDoc,3],aRevis[nI,1])
										QDJ->QDJ_FILMAT := aQAD[nQAD,5]
										QDJ->QDJ_DEPTO  := aQAD[nQAD,3]
										QDJ->QDJ_TIPO   := "P"
										QDJ->( MsUnlock() )
									EndIf									
									QDG->(dbSetOrder(1))
								EndIf
							EndIf
						Next nI						

					ElseIf cTipDest == "E"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ No caso da Existencia de Revisoes    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//Para Carregar as revisoes (Ultima e Penultima)
						aRevis:={}
						lRev := .F.
						lRev := f_ProcRv(aQDH[nDoc,5],aQDH[nDoc,2],@aRevis)						
						For nCZ := 1 To If(Len(aRevis) == 0,1,Len(aRevis))
							If cStatus == "I  "
								cBuscaD:= cMatDep+cMatFil+cMatCod
							Else
								cBuscaD:= aQAD[nQAD,3]+aQAD[nQAD,5]+aQAD[nQAD,6]
							Endif
							
							If Len(aRevis) > 0
								cChave := aQDH[nDoc,5]+aQDH[nDoc,2]+aRevis[nCZ,1]+cBuscaD+cStatus
							Else
								cChave := aQDH[nDoc,5]+aQDH[nDoc,2]+aQDH[nDoc,3]+cBuscaD+cStatus
							EndIf
							
							QD1->(DbSetOrder(7))
							If QD1->(DbSeek(cChave))
								RecLock("QD1",.F.)
								If QD1->QD1_PENDEN == "B"
									QD1->QD1_SIT := "I"
									QD1->(MsUnlock() )									

									DbSelectArea("QDG")
									QDG->(DbSetOrder(2))
									If QDG->(DbSeek(aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nCZ,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC ))
										While QDG->(!EOf()) .AND. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_TIPO+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_CODMAN == aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nCZ,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC
											Reclock("QDG",.F.)
											QDG->QDG_SIT   := "I"
											QDG->QDG_RECEB := "N"
											QDG->( MsUnLock() )
											GrvLog(.T.,OemToAnsi(STR0059),"U",1,aQAD[nQAD,5],aQAD[nQAD,5],aQDH[nDoc,5],aQDH[nDoc,2],"1",nDoc ) //"Inativa‡„o de Distribui‡„o por Pasta"
											QDG->( DbSkip() )
										EndDo
									EndIf
								Else
									QD1->(dbDelete() )
									QD1->(MsUnlock() )
									QDG->( DbSetOrder( 2 ) )
									If QDG->(Dbseek(aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nCZ,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC ))
										Reclock("QDG",.F.)
										QDG->( dbDelete() )
										QDG->( MsUnLock() )
									EndIf
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Caso nao exista mais nenhum destinatario no Depto, exclui ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If !QDG->(Dbseek(aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nCZ,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]))
										If QDJ->(DbSeek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nCZ,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]))
											Reclock("QDJ", .F. )
											QDJ->( dbDelete() )
											QDJ->( MsUnLock() )
										EndIf
									EndIf									
								EndIf
							Endif
						Next
						
					Elseif cTipDest == "R"
						aRevis:={}						
						lRev := f_ProcRv(aQDH[ nDoc, 5],aQDH[ nDoc, 2],@aRevis)						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ No caso da Existencia de Revisoes    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI:= 1 TO If(lRev,Len(aRevis),1)							
							If !lRev .Or. (lRev .And. aRevis[nI,2] == "L  ")								
								QD1->(dbSetOrder(7))
								If cStatus == "I  "
									lFound:= QD1->(Dbseek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
								Else
									lFound:= QD1->(Dbseek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+aQAD[nQAD,3]+aQAD[nQAD,5]+aQAD[nQAD,6]+cStatus))
								EndIf
								
								If lFound
									RecLock("QD1",.F.)
									QD1->QD1_SIT    := "A"
									QD1->QD1_DTGERA := dDataBase
									QD1->QD1_HRGERA := If(cStatus <> "I  ",QSomaH(SubStr(Time(),1,5)),SubStr(Time(),1,5))
									QD1->QD1_DTBAIX := If(cStatus <> "I  ",If(lOk,dDataBase,CtoD(" ")),dDataBase)
									QD1->QD1_HRBAIX := If(cStatus <> "I  ",If(lOk,QSomaH(SubStr(Time(),1,5))," "),SubStr(Time(),1,5))
									QD1->(MsUnlock() )
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Envia email para o usuario da Pendencia Gerada      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									nOrdQAA:= QAA->(IndexOrd())
									nRegQAA:= QAA->(Recno())
									QAA->(DbSetOrder(1))
									If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT)) 
										cNomRece:= QAA->QAA_NOME
										cDepRece:= QAA->QAA_CC
										If (QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND <> "D") .And. ;
											(!Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1") .And. cTpDist <> "4"
											If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
					                     		fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,QDH->QDH_TITULO,QAA->QAA_EMAIL,cStatus,cFilCod,QAA->QAA_APELID,"","","",,QDH->QDH_CODTP,QDH->QDH_DTVIG)
					    		   			EndIf										
										EndIf
									EndIf
									QAA->(dbSetOrder(nOrdQAA))
									QAA->(dbGoTo(nRegQAA))
									
									QDG->(dbSetOrder(2))
									If cStatus == "L  "										
										If QDG->(dbseek(aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC))											
											While !EOf() .AND. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_TIPO+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_CODMAN == aQdh[nDoc,5]+aQdh[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3]+cQDC
												RecLock( "QDG", .F. )
												QDG->QDG_SIT   := "A"
												QDG->QDG_RECEB := "S"
												IF QDG->QDG_TPRCBT == "2" //Pasta										
													nQtdCop		:=aQAD[nQAD,9]
												ENDIF
												QDG->QDG_NCOP   := nQtdCop
												QDG->(MsUnlock() )											
												GrvLog(.T.,OemToAnsi(STR0056),"U",1,aQAD[nQAD,5],aQAD[nQAD,6],aQDH[nDoc,5],aQDH[nDoc,2],"1",nDoc) //"Distribui‡„o Extra por Pasta"
												QDG->( DbSkip() )
											EndDo
										EndIf										
										QD1->(dbSetOrder(1))

										DbSelectArea("QDJ")										
										If !dbSeek(aQDH[nDoc,5]+aQDH[nDoc,2]+If(!lRev,aQDH[nDoc,3],aRevis[nI,1])+"P"+aQAD[nQAD,5]+aQAD[nQAD,3])
											Reclock("QDJ", .T. )
											QDJ->QDJ_FILIAL := aQDH[nDoc,5]
											QDJ->QDJ_DOCTO  := aQDH[nDoc,2]
											QDJ->QDJ_RV     := If(!lRev,aQDH[nDoc,3],aRevis[nI,1])
											QDJ->QDJ_FILMAT := aQAD[nQAD,5]
											QDJ->QDJ_DEPTO  := aQAD[nQAD,3]
											QDJ->QDJ_TIPO   := "P"
											QDJ->( MsUnlock() )
										EndIf										
									EndIf
									QDG->(dbSetOrder(1))
								EndIf
							EndIf
						Next nI
					Endif
				Endif
			Next nQAD
		Endif
	Next nDoc
Next nCt

IF Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
Endif	

For nDoc := 1 to Len(aQDH)
	If nDoc <= Len(aQDH)
		If aQDH[nDoc,1] == .T.
			aDel(aQDH,nDoc)
			aSize(aQDH,Len(aQDH)-1)
			nDoc --
		EndIf
	EndIf
Next nDoc

oQDH:SetArray( aQDH )
oQDH:nAt:=1
oQDH:bLine:=bQDHLine
oQDH:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleCC   ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona Pastas e Departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleCC()	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleCC()

Local bLiLocal := Nil
Local cDescQDC := " "
Local cModoQDC := ""
Local cQAD     := " "
Local oBtn1    := Nil
Local oBtn2    := Nil
Local oBtn3    := Nil
Local oBtn4    := Nil
Local oBtn5    := Nil
Local oDescQDC := Nil
Local oDlg     := Nil
Local oQDC     := Nil

Private cQDC:= Space(TamSx3("QDC_CODMAN")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acresenta o Nr Copias no bLine de Controle do Listbox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bLiLocal:= {|| aIn:=Eval(bQADLine),iif(oQad:nat>0 .and. len(aQad) > 0,Aadd(ain,aQAD[oQAD:nAt,9] ), ),aIn } 
                                    
cFilPst := cFilAnt

IF ExistBlock("QDOAP21")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acresenta o Tipo de Copias no Array ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEval(aQAD,{|X| AADD(X,"2") }) //Copia tipo Papel
Endif


If Len(aQad) > 0 

	ChecaModos(@cModoQDC)
	If !("E" $ cModoQDC) //QDC Compartilhada
		aQAD:={}	   
		aAdd(aQAD,{ .F.,,,,,,,,})
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0047) FROM 000,000 TO 245,625 OF oMainWnd PIXEL //"Sele‡„o de Pastas e Departamentos"
		
		@ 006,003 SAY OemToAnsi(STR0048) SIZE 040,010 OF oDlg PIXEL //"Pastas"
		IF cTipDest=="E"
			@ 005,025 MSGET oQDC VAR cQDC F3 "QDC" SIZE 080,010 OF oDlg PIXEL valid recriaAQAD(cQDC) .and. ;
						      If(Empty(cDescQDC:= QDXFNANMAN(cQDC,.T.)),(Help(" ",1,"QD050PNE"),oDescQDC:Refresh(),.F.),.t.) 	// Pasta nao Existe
		Else
			@ 005,025 MSGET oQDC VAR cQDC F3 "QDC" SIZE 080,010 OF oDlg PIXEL valid recriaAQAD(cQDC) .and. ;
						      If(QA_CHKMAN(xFilial("QDC"),cQDC),(cDescQDC:= QDXFNANMAN(cQDC,.T.),oDescQDC:Refresh()),.F.)
		Endif
	    
		@ 005,110 MSGET oDescQDC VAR cDescQDC SIZE 165,010 OF oDlg PIXEL

	Else //QDC Exclusiva
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0047) FROM 000,000 TO 245,625 OF oMainWnd PIXEL //"Sele‡„o de Pastas e Departamentos"
		
		@ 002,003 SAY OemToAnsi(STR0096+":") SIZE 040,010 OF oDlg PIXEL //"Filial"
		@ 009,003 MSGET oSM0 VAR cFilPst F3 "SM0_01" SIZE 025,010 OF oDlg PIXEL;
		
		oSM0:bLostFocus := {|| Iif(FwModeAccess("QDC") == "E",(QDA120Fil(oSM0),oSM0:lActive:=.F.,oDescQDC:Refresh()),.T.)}
		
		@ 002,054 SAY OemToAnsi(STR0048+":") SIZE 040,010 OF oDlg PIXEL //"Pastas"
		IF cTipDest=="E"
			@ 009,053 MSGET oQDC VAR cQDC F3 "QDC" SIZE 080,010 OF oDlg PIXEL valid recriaAQAD(cQDC) .and. ;
						     If(Empty(cDescQDC:= QDXFNANMAN(cQDC,.T.,If(FwModeAccess("QDC") == "E",cFilPst,))),(Help(" ",1,"QD050PNE"),oDescQDC:Refresh(),.F.),.t.)	// Pasta nao Existe
		Else
			@ 009,053 MSGET oQDC VAR cQDC F3 "QDC" SIZE 080,010 OF oDlg PIXEL valid recriaAQAD(cQDC) .and. ;
						     If(QA_CHKMAN(If(FwModeAccess("QDC")== "E",cFilPst,xFilial("QDC")),cQDC),(cDescQDC:= QDXFNANMAN(cQDC,.T.,If(FwModeAccess("QDC") == "E",cFilPst,)),oDescQDC:Refresh()),.F.)	
		Endif
	
		@ 009,135 MSGET oDescQDC VAR cDescQDC SIZE 145,010 OF oDlg PIXEL
		
	EndIf
		
	oDescQDC:lReadOnly:= .T. 
	
	@ 022,003 TO 120,281 LABEL OemToansi(STR0049) OF oDlg PIXEL //"Departamentos" 
	@ 030,008 LISTBOX oQAD VAR cQAD FIELDS; 
						HEADER " ",;
							TitSX3("QAD_FILIAL")[1],;
							TitSX3("QAD_CUSTO" )[1],;
							TitSX3("QAD_DESC"  )[1],;
							OemToAnsi( STR0065 ) ;   //"Nr Copias"
					COLSIZES 10,20,50,150,10 ;
					SIZE 268,085 OF oDlg PIXEL ;
					ON DBLCLICK( VldClickCC(@aQAD, oQAD, cFilPst) )
	oQAD:SetArray(aQAD)
	oQAD:bLine:= bLiLocal
	
	DEFINE SBUTTON oBtn1 FROM 005,283 TYPE 1 ENABLE OF oDlg;
				ACTION SeleDoc()
	oBtn1:cToolTip:= OemToAnsi(STR0040) //"Continua"
	oBtn1:cCaption:= OemToAnsi(STR0040) //"Continua"
	
	DEFINE SBUTTON oBtn2 FROM 019,283 TYPE 2 ENABLE OF oDlg;
			ACTION oDlg:End()
	oBtn2:cToolTip:= OemToAnsi(STR0039) //"Cancelar"
	
	@ 033,283 BUTTON oBtn3 PROMPT OemToAnsi(STR0094) ;
	  ACTION MarQAD();
	  SIZE 026,012 OF oDlg PIXEL 
		oBtn3:cToolTip := OemToAnsi(STR0094)
	
	@ 047,283 BUTTON oBtn4 PROMPT OemToAnsi(STR0072) ;
		  ACTION QD120PesqCC() ;
		  SIZE 026,012 OF oDlg PIXEL 
			oBtN4:cToolTip := OemToAnsi(STR0072) 
	
	DEFINE SBUTTON oBtn5 FROM 061,283 TYPE 16 ENABLE OF oDlg;
			ACTION {|| QD120AlCop(@aQAD,oQAD:nAt),oQAD:Refresh()}
	oBtn5:cToolTip:= OemToAnsi(STR0065) //"Nr Copias"
	oBtn5:cCaption:= OemToAnsi(STR0065) //"Nr Copias"
	IF cTipDest == "E" .OR. cTipDest == "R"
		oBtn5:Disable()
	Endif
	
	ACTIVATE MSDIALOG oDlg CENTERED 

EndIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Continua ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a distribuicao e baixa ( se for o caso ) dos docu- ³±±
±±³          ³ mentos selecionados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Continua( nTP )                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Continua(nTP)

Local lOk      := .T.
Local cStatus  := ""
Local nTamanho := 0
Local nCt      :=0
Local lFound   := .f.
Local aRevis   := {}  // Array das revisoes Existentes do Documento
Local lRev     := .f. // Controla se deve ou nao processar as revisoes
Local nI       := 0
Local nOrdQAA  := 0
Local nRegQAA  := 0
Local aUsrMail := {}
Local lApagaQD1:= .F.
Local aUsrMat  := QA_USUARIO()
Local nCV	   := 1
Local nDoc	   := 1
Local lGrvQD1 := .F.

Private lChCopia := .t.                   
Private cNomRece:= ""
Private oWord
If nTP == 1
	If Len(aQDH) == 0
		Return .f.
	EndIf

ElseIf nTP == 2 .Or. nTP == 3
	If Len(aQDG) == 0
		Return .f.
	EndIf
Endif

If !MsgYesNo(OemToAnsi(STR0052),OemToAnsi(STR0010)) //"Confirma a opera‡„o ?" ### "Aten‡„o"
	Return .F.
EndIf

If cTipDest == "I" .And. nTP <> 3
	lOk :=MsgYesNo(OemToAnsi(STR0053),OemToAnsi(STR0010)) //"Executa baixa de leitura dos documentos ?" ### "Aten‡„o"
EndIf

For nCt:= 1 To 1
	cStatus:= "L  "
	If nTP == 1
		nTamanho:= Len(aQDH)
	Elseif nTP == 2 .Or. nTP == 3
		nTamanho:= Len(aQDG)
	EndIf
	
	For nCV:= 1 To nTamanho
		If nTP == 1
			If aQDH[nCV,1] == .F.
				Loop
			EndIf
		ElseIf nTP == 2 .Or. nTP == 3
			If aQDG[nCV,1] == .F.
				Loop
			EndIf
		Endif
		lGrvQD1:= .F.
		If cTipDest == "I"
			aRevis:={}
			lRev:=.F.
			If nTp==1
				lRev := f_ProcRv(aQDH[ nCV, 5],aQDH[ nCV, 2],@aRevis)
			Else
				lRev := f_ProcRv(cFil,cDocto,@aRevis)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ No caso da Existencia de Revisoes    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI:= 1 TO If(lRev,Len(aRevis),1)				
				If !lRev .Or. (lRev .And. aRevis[nI,2] == "L  ")					
					QD1->(dbSetOrder(7))
					If cStatus == "I  "
						If nTp == 1
							lFound := .F.
							If  QD1->(Dbseek(aQDH[nCV,5]+aQDH[nCV,2]+If(!lRev,aQDH[nCV,3],aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
								While 	QD1->QD1_FILIAL = aQDH[nCV,5]  .And.;
									QD1->QD1_DOCTO = aQDH[nCV,2]  .And.;
									QD1->QD1_RV = If(!lRev,aQDH[nCV,3],aRevis[nI,1]) .And.;
									QD1->QD1_DEPTO = cMatDep .And. QD1->QD1_FILMAT = cMatFil  .And.;
									QD1->QD1_MAT = cMatCod .And. QD1->QD1_TPPEND =  cStatus
									
									If QD1->QD1_TPDIST == "1" .And. ;
										QD1->QD1_DTGERA == dDataBase .And. 	QD1->QD1_HRGERA == SubStr(Time(),1,5)
										lFound := .T.
										Exit
									Endif
									
									QD1->(DbSkip())
								EndDo
							Endif

						Else
							lFound := .F.
							lGrvQD1:= .F.
							QD1->(DbSetOrder(7))//QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1_DEPTO+QD1_FILMAT+QD1_MAT+QD1_TPPEND+QD1_PENDEN  
							If  QD1->(Dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
								While !QD1->(Eof()).And.QD1->QD1_FILIAL == cFil .And.	QD1->QD1_DOCTO == cDocto .And.QD1->QD1_RV == If(!lRev,cRev,aRevis[nI,1]) .And.;
								QD1->QD1_DEPTO == cMatDep .And. QD1->QD1_FILMAT == cMatFil  .And.QD1->QD1_MAT == cMatCod .And. QD1->QD1_TPPEND == cStatus
									
									If QD1->QD1_TPDIST == "1" .And. QD1->QD1_DTGERA == dDataBase .And. QD1->QD1_HRGERA == SubStr(Time(),1,5)
										lFound := .T.
										Exit
									Endif
									If QD1->QD1_MAT == cMatCod .And. QD1->QD1_TPDIST == "2"
											lGrvQD1:= .T.
									Endif
									QD1->(DbSkip())
								EndDo
							Endif


						Endif
					Else
						If nTp == 1
							lFound:= QD1->(Dbseek(aQDH[nCV,5]+aQDH[nCV,2]+If(!lRev,aQDH[nCV,3],aRevis[nI,1])+cDepto+cFil+cMat+cStatus))
						Else
							lFound:= QD1->(Dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,8]+aQDG[nCV,5]+aQDG[nCV,2]+cStatus))
						Endif
					EndIf
					
					If (!lFound .Or. ( lFound .And. cStatus <> "I  ")) .And. !lGrvQD1
						If lFound
							RecLock( "QD1", .F. )
						Else
							RecLock( "QD1", .T. )
						EndIf
						
						If nTP==1
							QD1->QD1_FILIAL:= aQDH[nCV,5]
							QD1->QD1_DOCTO := aQDH[nCV,2]
							QD1->QD1_RV    := If(!lRev,aQDH[nCV,3],aRevis[nI,1])
							If cStatus == "I  "
								QD1->QD1_FILMAT := cMatFil
								QD1->QD1_MAT    := cMatCod
								QD1->QD1_DEPTO  := cMatDep
							Else
								QD1->QD1_FILMAT:= cFil
								QD1->QD1_MAT   := cMat
								QD1->QD1_DEPTO := cDepto
							Endif
							QD1->QD1_TPDIST:= cTpDist
							QD1->QD1_CARGO := cCargo
							QD1->QD1_CHAVE := aQDH[nCV,6]
	
						ElseIf nTP == 2 .Or. nTP == 3  
							QD1->QD1_FILIAL:= cFil
							QD1->QD1_DOCTO := cDocto
							QD1->QD1_RV    := If(!lRev,cRev,aRevis[nI,1])
//							If cStatus == "I  "
//								QD1->QD1_FILMAT := cMatFil
//								QD1->QD1_MAT    := cMatCod
//								QD1->QD1_DEPTO  := cMatDep
//							Else
								QD1->QD1_FILMAT := aQDG[ nCV, 5]
								QD1->QD1_MAT    := aQDG[ nCV, 2]
								QD1->QD1_DEPTO  := aQDG[ nCV, 8]
//							Endif
							QD1->QD1_TPDIST    := aQDG[ nCV, 7]
							QD1->QD1_CARGO     := aQDG[ nCV, 6]
							QD1->QD1_CHAVE     := cChTxt
						Endif
						
						QD1->QD1_DTGERA := dDataBase
						QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
						QD1->QD1_DTBAIX := If( cStatus!="I  ", If( lOk, dDataBase, ctod(" ") ), dDataBase )
						QD1->QD1_HRBAIX := If( cStatus!="I  ", If( lOk, SubStr( Time(), 1, 5 ), " " ), SubStr( Time(),1, 5 ) )
						QD1->QD1_TPPEND := cStatus
						QD1->QD1_PENDEN := If( cStatus!="I  ", If( lOk,"B","P"),"B")
						QD1->QD1_LEUDOC := If( cStatus!="I  ", If( lOk,"S","N"),"N")
						QD1->QD1_APROVA := "N"
						QD1->QD1_FMATBX := cMatFil
						QD1->QD1_MATBX  := cMatCod
						QD1->QD1_DEPBX  := cMatDep
						QD1->QD1_DISTNE := "E"
						QD1->QD1_SIT    := "A"
						QD1->(MsUnlock() )
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Envia email para o usuario da Pendencia Gerada      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nOrdQAA:= QAA->(IndexOrd())
						nRegQAA:= QAA->(Recno())
						QAA->(DbSetOrder(1))
						If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT))
							If ( QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND != "D" ) .and. ;
								( !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1" ) .and. cTpDist <> "4"
								If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
					          		fQdoTpMail(@aUsrMail,	QD1->QD1_DOCTO,QD1->QD1_RV,QDH->QDH_TITULO,QAA->QAA_EMAIL,cStatus,cFilCod,QAA->QAA_APELID,"","","",,QDH->QDH_CODTP,QDH->QDH_DTVIG)
					  			EndIf							
							EndIf
						EndIf
						QAA->(dbSetOrder(nOrdQAA))
						QAA->(dbGoTo(nRegQAA))
					Endif				
					QDG->(dbSetOrder(3))
					
					If cStatus == "L  "					
						If nTP==1
							If !QDG->(dbseek(aQdh[nCV,5]+aQdh[nCV,2]+If(!lRev,aQDH[nCV,3],aRevis[nI,1])+cFil+cDepto+cMat))
								RecLock( "QDG", .T. )
							Else
								RecLock( "QDG", .F. )
							EndIf
							QDG->QDG_FILIAL := aQDH[ nCV, 5 ]
							QDG->QDG_DOCTO  := aQDH[ nCV, 2 ]
							QDG->QDG_RV     := If(!lRev,aQDH[ nCV, 3 ],aRevis[nI,1])
							QDG->QDG_MAT    := cMat
							QDG->QDG_FILMAT := cFil
							QDG->QDG_DEPTO  := cDepto
							QDG->QDG_TPRCBT := cTpDist
							If cLibVias == "2" .and. QDG->QDG_SIT <> "I"
								QDG->QDG_NCOP   += nQtdCop	
							Else
								QDG->QDG_NCOP   := nQtdCop
							Endif
							
						Elseif nTP == 2 .Or. nTP == 3
							If !QDG->(dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,5]+aQDG[nCV,8]+aQDG[nCV,2]))
								RecLock( "QDG", .T. )
							Else
								RecLock( "QDG", .F. )
							EndIf
							
							QDG->QDG_FILIAL := cFil
							QDG->QDG_DOCTO  := cDocto
							QDG->QDG_RV     := If(!lRev,cRev,aRevis[nI,1])
							QDG->QDG_MAT    := aQDG[ nCV, 2]
							QDG->QDG_FILMAT := aQDG[ nCV, 5]
							QDG->QDG_DEPTO  := aQDG[ nCV, 8]
							QDG->QDG_TPRCBT := aQDG[ nCV, 7]
							If cLibVias == "2" .and. QDG->QDG_SIT <> "I"
								QDG->QDG_NCOP   += aQDG[ nCv, 9]
							Else
								QDG->QDG_NCOP   = aQDG[ nCv, 9]
							Endif
						Endif
						
						QDG->QDG_RECEB:= "S"
						If nTP == 1 .or. nTP == 2
							QDG->QDG_TIPO:= "D"
						Elseif nTP == 3
							QDG->QDG_TIPO  := "P"
							QDG->QDG_CODMAN:= cQDC
						EndIf
						QDG->QDG_SIT:= "A"
						QDG->(MsUnlock() )
						
						If nTP == 1
							GrvLog(.T.,OemToAnsi( STR0054 ),"U",IF(cLibvias == "2",nQtdCop,1),cFilCod,cCodMat,cFil,cMat,cTpDist,nCV ) //"Distribui‡„o Extra por Usu rio"
						Elseif nTP == 2
							GrvLog(.T.,OemToAnsi( STR0055 ),"U",IF(cLibvias == "2",aQDG[nCv,9],1),cFilCod,cCodMat,aQDG[nCV,5],aQDG[nCV,2],aQDG[nCV,7],nCV ) //"Distribui‡„o Extra por Documento"
						Elseif nTP == 3                               
							GrvLog(.T.,OemToAnsi( STR0056 ),"U",IF(cLibvias == "2",aQDG[nCv,9],1),cFilCod,cCodMat,aQDG[nCV,5],aQDG[nCV,2],aQDG[nCV,7],nCV ) //"Distribui‡„o Extra por Pasta"
						Endif
						
						QDG->(dbSetOrder(1))
						QD1->(dbSetOrder(1))
						DbSelectArea("QDJ")
						
						If nTP == 1
							lFound := dbSeek(aQDH[nCV,5] + aQDH[nCV,2] + ;
							If(!lRev,aQDH[ nCV, 3 ],aRevis[nI,1]) + ;
							If((nTP == 1 .or. nTP == 2),"D","P") + ;
							cFil + cDepto)
							
						ElseIf nTP == 2 .or. nTP == 3
							lFound := DbSeek(cFil+cDocto+ If(!lRev,cRev,aRevis[nI,1]) + ;
							If((nTP == 1 .or. nTP == 2),"D","P") + ;
							aQDG[nCV,5] + ;
							aQDG[nCV,8])
						EndIf
						If !lFound
							Reclock("QDJ",.T.)
							If nTP == 1
								QDJ->QDJ_FILIAL := aQDH[ nCV, 5 ]
								QDJ->QDJ_DOCTO  := aQDH[ nCV, 2 ]
								QDJ->QDJ_RV     := If(!lRev,aQDH[ nCV, 3 ],aRevis[nI,1])
								QDJ->QDJ_FILMAT := cFil
								QDJ->QDJ_DEPTO  := cDepto
								QDJ->QDJ_TIPO   := If( (nTp == 1 .or. nTp == 2), "D", "P" )
								QDJ->( MsUnlock() )
							ElseIf nTP == 2 .or. nTP == 3
								QDJ->QDJ_FILIAL := cFil
								QDJ->QDJ_DOCTO  := cDocto
								QDJ->QDJ_RV     := If(!lRev,cRev,aRevis[nI,1])
								QDJ->QDJ_FILMAT := aQDG[nCV,5]
								QDJ->QDJ_DEPTO  := aQDG[nCV,8]
								QDJ->QDJ_TIPO   := If(nTp == 1 .or. nTp == 2, "D", "P" )
								QDJ->( MsUnlock() )
							EndIf
						EndIf
					EndIf
				Endif
			Next nI
			If cLibVias == "2" 
				If nTP==1 .and. cTpDist == "2"
			        dbselectarea("QDH")
			        DbSetOrder(1)
			        If QDH->(Dbseek(xfilial("QDH")+aQDH[ nCV, 2 ] +aQDH[ nCV, 3 ] ))
						RegToMemory("QDH",.F.,,.F.)
						QdoDocRUsr(.T.,.F.,cNomRece,,,nQtdCop,.F.,.F.) 
						QdoDocRUsr(.F.,.T.,cNomRece,,,nQtdCop,.F.,.F.)
					Endif
				Elseif (nTP==2 .or. nTP == 3) .and. aQdg[nCv,7] == "2"
					dbselectarea("QDH")
					DbSetOrder(1)
			        If QDH->(Dbseek(xfilial("QDH")+cDocto +cRev ))
						RegToMemory("QDH",.F.,,.F.)
						QdoDocRUsr(.T.,.F.,cNomRece,,,aQDG[nCv,9],.F.,.F.)
						QdoDocRUsr(.F.,.T.,cNomRece,,,aQDG[nCv,9],.F.,.F.)
					Endif
				Endif
				
			Endif
		Elseif cTipDest == "E" .Or. cTipDest == "R"
			
			aRevis:={}
			lRev:=.F.
			If nTp==1
				lRev := f_ProcRv(aQDH[ nCV, 5],aQDH[ nCV, 2],@aRevis)
			Else
				lRev := f_ProcRv(cFil,cDocto,@aRevis)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ No caso da Existencia de Revisoes    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI:=1 TO If(lRev,Len(aRevis),1)
				
				If !lRev .Or. (lRev .And. aRevis[nI,2] == "L  ")
					
					QD1->(dbSetOrder(7))
					If cStatus == "I  "
						If nTp==1
							lFound := QD1->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+If(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
						Else
							lFound := QD1->(dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+cMatDep+cMatFil+cMatCod+cStatus))
						Endif
					Else
						If nTp==1
							lFound := QD1->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+If(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+cDepto+cFil+cMat+cStatus))
						Else
							lFound := QD1->(dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,8]+aQDG[nCV,5]+aQDG[nCV,2]+cStatus))
						Endif
					EndIf
					
					If lFound
						RecLock( "QD1", .F. )
						If cTipDest == "E"
							If QD1->QD1_PENDEN = "P"
								QD1->QD1_SIT := "I"
								QD1->QD1_PENDEN := "B"//Baixa pendência para que a mesma não fique mais visível para o usuário
							Else
								QD1->QD1_SIT := "I"
							Endif
						Else
							QD1->QD1_SIT := "A"
							QD1->QD1_DTGERA := dDataBase
							QD1->QD1_HRGERA := If( cStatus!="I  ", QSomaH(SubStr(Time(),1,5)), SubStr(Time(),1,5) )
							QD1->QD1_DTBAIX := If( cStatus!="I  ", If( lOk, dDataBase, CtoD(" ") ), dDataBase )
							QD1->QD1_HRBAIX := If( cStatus!="I  ", If( lOk, QSomaH(SubStr(Time(),1,5)), " " ), SubStr( Time(),1, 5 ) )
							QD1->QD1_PENDEN := "P"
						Endif
						QD1->(MsUnlock() )
					Else						
						If cTipDest == "R"
							RecLock("QD1",.T.)
							QD1->QD1_FILIAL := cFil
							QD1->QD1_DOCTO  := cDocto
							QD1->QD1_RV     := cRev
							QD1->QD1_TPPEND := "L  "
							QD1->QD1_FILMAT := aQDG[nCV,5]
							QD1->QD1_MAT    := aQDG[nCV,2]
							QD1->QD1_DEPTO  := aQDG[nCV,8]
							QD1->QD1_DISTNE := "N"
							QD1->QD1_PENDEN := "P"
							QD1->QD1_DTGERA := dDataBase
							QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
							QD1->QD1_SIT    := "A"
							QD1->QD1_LEUDOC := "N"
							QD1->QD1_TPDIST := "1"
							QD1->(MsUnlock() )
						Endif
												
					EndIf
				
					QDG->(dbSetOrder(3))
					If cStatus == "L  "
						If nTp==1
							lFound := QDG->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+If(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+cFil+cDepto+cMat))
						Else
							lFound := QDG->(dbseek(cFil+cDocto+If(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,5]+aQDG[nCV,8]+aQDG[nCV,2]))
						Endif
						
						If lFound
							RecLock( "QDG", .F. )
							If cTipDest == "E"
								If lApagaQD1
									dbDelete()
								Else
									QDG->QDG_SIT   := "I"
									QDG->QDG_RECEB := "N"
								Endif
							Else
								QDG->QDG_SIT   := "A"
								QDG->QDG_RECEB := "S"
							Endif
							QDG->(MsUnlock() )
							
							If lApagaQD1
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Caso nao exista mais nenhum destinatario no Depto, exclui ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If nTp==1
									lFound := QDG->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+If(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+cFil+cDepto))
								Else
									lFound := QDG->(dbseek(cFil+cDocto+iif(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,5]+aQDG[nCV,8]))
								Endif
								
								If !lFound	// Caso nao existe mais Depto no QDG apaga do QDJ
									If nTp==1
										lFound := QDJ->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+iif(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+"D"+cFil+cDepto))
									Else
										lFound := QDJ->(dbseek(cFil+cDocto+iif(!lRev,cRev,aRevis[nI,1])+"D"+aQDG[nCV,5]+aQDG[nCV,8]))
									Endif
									
									If lFound
										Reclock("QDJ", .F. )
										QDJ->( dbDelete() )
										QDJ->( MsUnLock() )
									Endif
								Endif
							Endif
						Else						
							If cTipDest == "R"
								RecLock( "QDG", .T. )
								QDG->QDG_SIT    := "A"
								QDG->QDG_RECEB  := "S"
								QDG->QDG_FILIAL := cFil
								QDG->QDG_DOCTO  := cDocto
								QDG->QDG_RV     := cRev
								QDG->QDG_FILMAT := aQDG[nCV,5]
								QDG->QDG_DEPTO  := aQDG[nCV,8]
								QDG->QDG_MAT    := aQDG[nCV,2]
								QDG->QDG_NCOP   := 1
								QDG->QDG_TPRCBT := aQDG[nCV,7]
								QDG->QDG_TIPO   := "D"
								QDG->(MsUnlock() )							
							Endif
							
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso nao exista o Depto cadastrado, inclui 					  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nTp==1
								lFound := QDG->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+If(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+cFil+cDepto))
							Else
								lFound := QDG->(dbseek(cFil+cDocto+iif(!lRev,cRev,aRevis[nI,1])+aQDG[nCV,5]+aQDG[nCV,8]))
							Endif
								
							If lFound	// Caso nao existe mais Depto no QDG apaga do QDJ
								If nTp==1
									lFound := QDJ->(dbseek(aQDH[ nCV, 5]+aQDH[ nCV, 2]+iif(!lRev,aQDH[ nCV, 3],aRevis[nI,1])+"D"+cFil+cDepto))
								Else
									lFound := QDJ->(dbseek(cFil+cDocto+iif(!lRev,cRev,aRevis[nI,1])+"D"+aQDG[nCV,5]+aQDG[nCV,8]))
								Endif
									
								If !lFound
									Reclock("QDJ", .T. )
									QDJ->QDJ_FILIAL := cFil
									QDJ->QDJ_DOCTO  := cDocto
									QDJ->QDJ_RV     := cRev
									QDJ->QDJ_FILMAT := aQDG[nCV,5]
									QDJ->QDJ_DEPTO  := aQDG[nCV,8]
									QDJ->QDJ_TIPO   := "D"	
									QDJ->( MsUnLock() )								
								Endif
							Endif
							
						EndIf
						
						If nTP==1
							GrvLog(.T., If(cTipDest == "E",OemToAnsi( STR0057 ) , OemToAnsi( STR0060 )),"U",1,cFilCod,cCodMat,cFil,cMat,cTpDist,nCV ) //"Inativa‡„o de Distribui‡„o por Usu rio"
						Elseif nTP==2
							GrvLog(.T., If(cTipDest == "E",OemToAnsi( STR0058 ) , OemToAnsi( STR0061 )),"U",1,cFilCod,cCodMat,aQDG[nCV,5],aQDG[nCV,2],aQDG[nCV,7],nCV )  //"Inativa‡„o de Distribui‡„o por Documento"
						Elseif nTP==3
							GrvLog(.T., If(cTipDest == "E",OemToAnsi( STR0059 ) , OemToAnsi( STR0062 )),"U",1,cFilCod,cCodMat,aQDG[nCV,5],aQDG[nCV,2],aQDG[nCV,7],nCV ) //"Inativa‡„o de Distribui‡„o por Pasta"
						Endif
						
						QDG->(dbSetOrder(1))
						QD1->(dbSetOrder(1))
					Endif  
				Endif					
			Next
			
		Endif
		cAliasx := Alias()
	Next
Next
IF Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
Endif	

If nTP==1
	For nDoc := 1 to Len(aQDH)
		If nDoc <= Len(aQDH)
			If aQDH[nDoc,1] == .T.
				aDel(aQDH,nDoc)
				aSize(aQDH,Len(aQDH)-1)
				nDoc --
			Endif
		Endif
	Next
	
	oQDH:SetArray( aQDH )
	oQDH:nAt:=1
	oQDH:bLine:=bQDHLine
	oQDH:Refresh()
Elseif nTP==2 .or. nTP == 3
	For nDoc := 1 to Len(aQDG)
		If nDoc <= Len(aQDG)
			If aQDG[nDoc,1] == .T.
				aDel(aQDG,nDoc)
				aSize(aQDG,Len(aQDG)-1)
				nDoc --
			Endif
		Endif
	Next
	
	oQDG:SetArray( aQDG )
	oQDG:nAt:=1
	oQDG:bLine:=bQDGLine
	oQDG:Refresh()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleQAA  ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona todos os usuarios do cadastrado QAA              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleQAA()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleQAA()

Local cFil     := ""
Local cMat     := ""
Local nQAARecno:= 0
Local cCusto   := ""
Local sStatus
Local cQuery := ""

Private	aReg:= {}

If nTP==1
	cCodMat  := QAA->QAA_MAT
	cFilCod  := QAA->QAA_FILIAL
	cDeptoMat:= QAA->QAA_CC
Endif

If nTP==2 .or. nTP==3
	sStatus  := "L  "
	nQAARecno:= 0
EndIf

aQDG:={}
QAA->( DbSetOrder( 1 ) )
QD1->( DbSetOrder( 7 ) )

IF nTP==2 .or. nTP==3
	nQAARecno := QAA->( Recno())
Endif

QAA->( dbGoTop() )

If nTP==1
	
cQuery := " SELECT QAA.QAA_FILIAL,QAA.QAA_MAT,QAA.QAA_NOME,QAA.QAA_CC,QAA.QAA_CODFUN,QAA.QAA_TPRCBT,QAD.QAD_CUSTO,QAD.QAD_DESC "
cQuery += " FROM " + RetSqlName("QAA")+" QAA ,"+ RetSqlName("QAD")+" QAD "
cQuery += " WHERE "
cQuery += QA_FILSITF(.T.,.T.)
cQuery += " AND QAA.D_E_L_E_T_ <> '*' AND QAD.D_E_L_E_T_ <> '*'"

//If Empty(xFilial("QAD"))
If FwModeAccess("QAD") == "C"
//  cQuery += " AND QAD.QAD_FILIAL = '  ' AND QAD.QAD_CUSTO = QAA.QAA_CC "
	cQuery += " AND QAD.QAD_FILIAL = '"+xFilial("QAD")+" ' AND QAD.QAD_CUSTO = QAA.QAA_CC "
Else
	cQuery += " AND QAD.QAD_FILIAL = QAA.QAA_FILIAL AND QAD.QAD_CUSTO = QAA.QAA_CC "
Endif

cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL+QAA_MAT")

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
TMPQAA->(dbGoTop())

While !TMPQAA->( Eof() )
	aAdd(aQDG,{.F.,;
				TMPQAA->QAA_MAT,;
				TMPQAA->QAA_NOME,;
				TMPQAA->QAD_DESC,;
				TMPQAA->QAA_FILIAL,;
				TMPQAA->QAA_CODFUN,;
				If(Empty(TMPQAA->QAA_TPRCBT),"1",TMPQAA->QAA_TPRCBT),;
				TMPQAA->QAA_CC,1})
	TMPQAA->(DbSkip())
EndDo

dBSelectArea("TMPQAA")
DbCloseArea()
dbSelectArea("QAA")
	
ElseIf nTP==2 .or. nTP==3

cQuery := "SELECT QAA.QAA_FILIAL,QAA.QAA_MAT,QAA.QAA_NOME,QAA.QAA_CC,QAA.QAA_CODFUN,QAA.QAA_TPRCBT,QAD.QAD_CUSTO,QAD.QAD_DESC,QAA.D_E_L_E_T_ ,QAD.D_E_L_E_T_ "
cQuery += "FROM " + RetSqlName("QAA")+" QAA ,"+RetSqlName("QAD")+" QAD"
cQuery += " WHERE "
cQuery += QA_FILSITF(.T.,.T.)
cQuery += " AND QAA.D_E_L_E_T_ <> '*' AND QAD.D_E_L_E_T_ <> '*'"
//If Empty(xFilial("QAD"))
If FwModeAccess("QAD") == "C"
//				cQuery += " AND QAD.QAD_FILIAL = '  ' AND QAD.QAD_CUSTO = QAA.QAA_CC "
	cQuery += " AND QAD.QAD_FILIAL = '"+xFilial("QAD")+"' AND QAD.QAD_CUSTO = QAA.QAA_CC "
Else
	cQuery += " AND QAD.QAD_FILIAL = QAA.QAA_FILIAL AND QAD.QAD_CUSTO = QAA.QAA_CC "
Endif

If cTipDest == "I" // Incluir
	cQuery += " AND (NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QD1.QD1_FILIAL = '"+aQDH[oQDH:nAt,5]+"' AND QD1.QD1_DOCTO = '"+aQDH[oQDH:nAt,2]+"' AND QD1.QD1_RV = '"+aQDH[oQDH:nAt,3]+"'"
	cQuery +=                            " AND QD1.QD1_DEPTO = QAA.QAA_CC AND QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT AND QD1.QD1_TPPEND = 'L  ' AND QD1.D_E_L_E_T_ <> '*') OR "
	cQuery += "     EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	If clibvias == "2"
		cQuery +=                     "WHERE QD1.QD1_FILIAL = '"+aQDH[oQDH:nAt,5]+"' AND QD1.QD1_DOCTO = '"+aQDH[oQDH:nAt,2]+"' AND QD1.QD1_RV = '"+aQDH[oQDH:nAt,3]+"'"			
	Else
	cQuery +=                     "WHERE QD1.QD1_SIT = 'I' AND QD1.QD1_FILIAL = '"+aQDH[oQDH:nAt,5]+"' AND QD1.QD1_DOCTO = '"+aQDH[oQDH:nAt,2]+"' AND QD1.QD1_RV = '"+aQDH[oQDH:nAt,3]+"'"
	Endif
	cQuery +=                            " AND QD1.QD1_DEPTO = QAA.QAA_CC AND QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT AND QD1.QD1_TPPEND = 'L  ' AND QD1.D_E_L_E_T_ <> '*')) "
ElseIf cTipDest == "E" // Desativar
	cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QD1.QD1_SIT <> 'I' AND QD1.QD1_FILIAL = '"+aQDH[oQDH:nAt,5]+"' AND QD1.QD1_DOCTO = '"+aQDH[oQDH:nAt,2]+"' AND QD1.QD1_RV = '"+aQDH[oQDH:nAt,3]+"'"
	cQuery +=                            " AND QD1.QD1_DEPTO = QAA.QAA_CC AND QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT AND QD1.QD1_TPPEND = 'L  ' AND QD1.D_E_L_E_T_ <> '*') "
ElseIf cTipDest == "R" // Reativar
	cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QD1.QD1_SIT <> 'I' AND QD1.QD1_FILIAL = '"+aQDH[oQDH:nAt,5]+"' AND QD1.QD1_DOCTO = '"+aQDH[oQDH:nAt,2]+"' AND QD1.QD1_RV = '"+aQDH[oQDH:nAt,3]+"'"
	cQuery +=                            " AND QD1.QD1_DEPTO = QAA.QAA_CC AND QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT AND QD1.QD1_TPPEND = 'L  ' AND QD1.D_E_L_E_T_ <> '*') "
Endif

cQuery += " ORDER BY "+SqlOrder("QAA_FILIAL+QAA_MAT") // Ordem coluna5+coluna2 do array

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
TMPQAA->(dbGoTop())

While !TMPQAA->( Eof() )
	aAdd(aQDG,{.F.,;
				TMPQAA->QAA_MAT,;
				TMPQAA->QAA_NOME,;
				TMPQAA->QAD_DESC,;
				TMPQAA->QAA_FILIAL,;
				TMPQAA->QAA_CODFUN,;
				If(Empty(TMPQAA->QAA_TPRCBT),"1",TMPQAA->QAA_TPRCBT),;
				TMPQAA->QAA_CC,1})
	TMPQAA->(DbSkip())
EndDo

dbSelectArea("TMPQAA")		
dbCloseArea()
dbSelectArea("QAA")

EndIf

If nTP == 1
	bQDGLine:={ || {;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 5 ], CriaVar( "QAA_FILIAL" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 2 ], CriaVar( "QAA_MAT" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 3 ], CriaVar( "QAA_NOME" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 4 ], CriaVar( "QAA_CC" ) ) } }
Else
	bQDGLine:={ || {;
	If( Len( aQDG ) > 0, If( aQDG[ oQDG:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 5 ], CriaVar( "QAA_FILIAL" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 2 ], CriaVar( "QAA_MAT" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 3 ], CriaVar( "QAA_NOME" ) ),;
	If( Len( aQDG ) > 0, aQDG[ oQDG:nAt, 4 ], CriaVar( "QAA_CC" ) ) } }
Endif

If nTP==2 .or. nTP==3
	QDH->( DbSetOrder( 1 ) )
	QAA->( DbGoto( nQAARecno ) )
EndIf

QD1->( DbSetOrder(1) )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleQDH  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le todos os documentos do cadastro QDH                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleQDH()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleQDH()

Local cChave  := ""
Local nQAD 	  := 1
Local cQuery  := ""
Local cQueryQ := ""
Local cIndex       
Local lQDHFil  := FwModeAccess("QDH") == "C" //Empty(xFilial("QDH"))     
Local lAddDoc  := .F.
Local cWhere    := ""
Local lQD120FIL	:= ExistBlock("QD120FIL")

aQDH:={}

QD1->( DbSetOrder( 7 ) )
QDG->( DbSetOrder( 2 ) )
QDH->( DbSetOrder( 3 ) )

If nTP == 1

cQuery := "SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_OBSOL,QDH_STATUS,QDH_TITULO,QDH_CHAVE,QDH_CODTP,D_E_L_E_T_ FROM " + RetSqlName("QDH")
cQuery += " WHERE QDH_STATUS = 'L  ' AND QDH_OBSOL = 'N' AND QDH_CANCEL <> 'S' AND D_E_L_E_T_ <> '*'"

If cTipDest == "I" // Incluir
	cQuery += " AND (NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QDH_FILIAL = QD1.QD1_FILIAL AND QDH_DOCTO = QD1.QD1_DOCTO AND QDH_RV = QD1.QD1_RV AND "
	cQuery +=                            "QD1.QD1_DEPTO ='"+cDepto+"' AND QD1.QD1_FILMAT ='"+cFil+"' AND QD1.QD1_MAT ='"+cMat+"' AND QD1.QD1_TPPEND ='L  ' AND QD1.D_E_L_E_T_ <> '*') OR "
	cQuery += "     EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	If clibvias == "2"
		cQuery += "WHERE QDH_FILIAL = QD1.QD1_FILIAL AND QDH_DOCTO = QD1.QD1_DOCTO AND QDH_RV = QD1.QD1_RV AND "									
	Else
		cQuery += "WHERE QD1.QD1_SIT = 'I' AND  QDH_FILIAL = QD1.QD1_FILIAL AND QDH_DOCTO = QD1.QD1_DOCTO AND QDH_RV = QD1.QD1_RV AND "
	Endif
	cQuery +=                            "QD1.QD1_DEPTO ='"+cDepto+"' AND QD1.QD1_FILMAT ='"+cFil+"' AND QD1.QD1_MAT ='"+cMat+"' AND QD1.QD1_TPPEND ='L  ' AND QD1.D_E_L_E_T_ <> '*')) "
ElseIf cTipDest == "E" // Desativar
	cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QD1.QD1_SIT <> 'I' AND  QDH_FILIAL = QD1.QD1_FILIAL AND QDH_DOCTO = QD1.QD1_DOCTO AND QDH_RV = QD1.QD1_RV AND "
	cQuery +=                            "QD1.QD1_DEPTO ='"+cDepto+"' AND QD1.QD1_FILMAT ='"+cFil+"' AND QD1.QD1_MAT ='"+cMat+"' AND QD1.QD1_TPPEND ='L  ' AND QD1.D_E_L_E_T_ <> '*') "
ElseIf cTipDest == "R" // Reativar
	cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 "
	cQuery +=                     "WHERE QD1.QD1_SIT = 'I' AND  QDH_FILIAL = QD1.QD1_FILIAL AND QDH_DOCTO = QD1.QD1_DOCTO AND QDH_RV = QD1.QD1_RV AND "
	cQuery +=                            "QD1.QD1_DEPTO ='"+cDepto+"' AND QD1.QD1_FILMAT ='"+cFil+"' AND QD1.QD1_MAT ='"+cMat+"' AND QD1.QD1_TPPEND ='L  ' AND QD1.D_E_L_E_T_ <> '*') "
Endif

cQuery += " ORDER BY " + SqlOrder(QDH->(IndexKey()))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDH",.T.,.T.)
TMPQDH->(dbGoTop())

While !TMPQDH->( Eof() )
	AAdd( aQDH, { .F., TMPQDH->QDH_DOCTO, TMPQDH->QDH_RV, OemToAnsi( TMPQDH->QDH_TITULO ), TMPQDH->QDH_FILIAL, TMPQDH->QDH_CHAVE, TMPQDH->QDH_CODTP } )
	TMPQDH->(DbSkip())
EndDo

dbSelectArea("TMPQDH")		
dbCloseArea()

dbSelectArea("QDH")

Elseif nTP == 2

cQuery := "SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_OBSOL,QDH_STATUS,QDH_TITULO,QDH_CHAVE,QDH_CODTP,D_E_L_E_T_ FROM " + RetSqlName("QDH")
cQuery += " WHERE QDH_FILIAL = '" + xFilial("QDH") + "' AND QDH_STATUS = 'L  ' AND QDH_OBSOL = 'N'" 
cQuery += " AND QDH_CANCEL <> 'S' AND D_E_L_E_T_ <> '*'"  	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QD120FIL - Ponto de Entrada para filtro no QDH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQD120FIL
	cWhere := ExecBlock("QD120FIL",.F.,.F.)
	If ValType(cWhere) == "C" .And. Len(cWhere) > 1
		cQuery += ' AND '+cWhere + ' '
	EndIf
EndIf

cQuery += " ORDER BY " + SqlOrder(QDH->(IndexKey()))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDH",.T.,.T.)
TMPQDH->(dbGoTop())

While !TMPQDH->( Eof() )
	AAdd( aQDH, { .F., TMPQDH->QDH_DOCTO, TMPQDH->QDH_RV, OemToAnsi( TMPQDH->QDH_TITULO ), TMPQDH->QDH_FILIAL, TMPQDH->QDH_CHAVE, TMPQDH->QDH_CODTP } )
	TMPQDH->(DbSkip())
EndDo

dbSelectArea("TMPQDH")
dbCloseArea()

dbSelectArea("QDH")
	
ElseIf nTP == 3

For nQAD := 1 to Len(aQAD)
	If aQAD[nQAD,1] == .T.
		If !Empty(cQueryQ)
			cQueryQ += ' OR '
		Endif
		cQueryQ += "(QDG.QDG_FILMAT ='"+aQAD[nQAD,5]+"' AND QDG.QDG_DEPTO ='"+aQAD[nQAD,3]+"')"
	Endif
Next
If !Empty(cQueryQ)
	cQueryQ := '('+cQueryQ+')'
Endif

cQuery := "SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_OBSOL,QDH_STATUS,QDH_TITULO,QDH_CHAVE,QDH_CODTP,D_E_L_E_T_ FROM " + RetSqlName("QDH")
cQuery += " WHERE QDH_STATUS = 'L  ' AND QDH_OBSOL = 'N' AND QDH_CANCEL <> 'S' AND D_E_L_E_T_ <> '*'"

If cTipDest == "I" // Incluir
	cQuery += " AND (NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDG") + " QDG "
	cQuery +=                     "WHERE QDH_FILIAL = QDG.QDG_FILIAL AND QDH_DOCTO = QDG.QDG_DOCTO AND QDH_RV = QDG.QDG_RV AND "
	cQuery +=                            cQueryQ+" AND QDG_TIPO = 'P' AND QDG.QDG_CODMAN='"+cQDC+"' AND QDG.D_E_L_E_T_ <> '*') OR "
	cQuery += "     EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDG") + " QDG "
	If clibvias == "2"
		cQuery +=                     "WHERE QDH_FILIAL = QDG.QDG_FILIAL AND QDH_DOCTO = QDG.QDG_DOCTO AND QDH_RV = QDG.QDG_RV AND "				
	Else
	cQuery +=                     "WHERE (QDG.QDG_SIT = 'I' OR QDG.QDG_RECEB ='N' )AND  QDH_FILIAL = QDG.QDG_FILIAL AND QDH_DOCTO = QDG.QDG_DOCTO AND QDH_RV = QDG.QDG_RV AND "
	Endif
	cQuery +=                            cQueryQ+" AND QDG_TIPO = 'P' AND QDG.QDG_CODMAN='"+cQDC+"' AND QDG.D_E_L_E_T_ <> '*')) "
ElseIf cTipDest == "E" // Desativar
	cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDG") + " QDG "
	cQuery +=                     "WHERE (QDG.QDG_SIT <> 'I' AND QDG.QDG_RECEB='S' )AND  QDH_FILIAL = QDG.QDG_FILIAL AND QDH_DOCTO = QDG.QDG_DOCTO AND QDH_RV = QDG.QDG_RV AND "
	cQuery +=                            cQueryQ+" AND QDG_TIPO = 'P' AND QDG.QDG_CODMAN='"+cQDC+"' AND QDG.D_E_L_E_T_ <> '*') "
ElseIf cTipDest == "R" // Reativar
	cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDG") + " QDG "
	cQuery +=                     "WHERE QDG.QDG_SIT = 'I' AND  QDH_FILIAL = QDG.QDG_FILIAL AND QDH_DOCTO = QDG.QDG_DOCTO AND QDH_RV = QDG.QDG_RV AND "
	cQuery +=                            cQueryQ+" AND QDG_TIPO = 'P' AND QDG.QDG_CODMAN='"+cQDC+"' AND QDG.D_E_L_E_T_ <> '*') "
Endif

cQuery += " ORDER BY " + SqlOrder(QDH->(IndexKey()))

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDH",.T.,.T.)
TMPQDH->(dbGoTop())

While !TMPQDH->( Eof() )
	AAdd( aQDH, { .F., TMPQDH->QDH_DOCTO, TMPQDH->QDH_RV, OemToAnsi( TMPQDH->QDH_TITULO ), TMPQDH->QDH_FILIAL, TMPQDH->QDH_CHAVE, TMPQDH->QDH_CODTP } )
	TMPQDH->(DbSkip())
EndDo

dbSelectArea("TMPQDH")
dbCloseArea()         

dbSelectArea("QDH")


Elseif nTP == 4 

cQuery := "SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_OBSOL,QDH_STATUS,QDH_TITULO,QDH_CHAVE,QDH_CODTP,D_E_L_E_T_ FROM " + RetSqlName("QDH")
cQuery += " WHERE QDH_STATUS = 'L  ' AND QDH_OBSOL = 'N' AND QDH_CANCEL <> 'S' AND D_E_L_E_T_ <> '*' "
cQuery += " AND EXISTS(SELECT QD0.R_E_C_N_O_ FROM " + RetSqlName("QD0") + " QD0 ,"+ RetSqlName("QD5") + " QD5 "
cQuery +=                     "WHERE QDH_FILIAL = QD0.QD0_FILIAL AND QDH_DOCTO = QD0.QD0_DOCTO AND QDH_RV = QD0.QD0_RV AND "
cQuery +=                            " QD0.QD0_FILMAT = '"+cMatFil+"' AND QD0.QD0_MAT = '"+cMatCod+"' AND QD0.D_E_L_E_T_ <> '*' AND "			
cQuery +=                            " QD0.QD0_FLAG <> 'I' AND QD0.D_E_L_E_T_ <> '*' AND  "
cQuery +=					   "QD5.QD5_FILIAL = QD0.QD0_FILIAL AND QD5.QD5_CODTP = QDH_CODTP AND QD5.QD5_AUT = QD0.QD0_AUT AND "
cQuery +=					   "QD5.QD5_ALT = 'S' AND QD5.D_E_L_E_T_ <> '*') "					
cQuery += " ORDER BY " + SqlOrder(QDH->(IndexKey()))
 
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDH",.T.,.T.)
            TMPQDH->(dbGoTop())

While !TMPQDH->( Eof() )
	AAdd( aQDH, { .F., TMPQDH->QDH_DOCTO, TMPQDH->QDH_RV, OemToAnsi( TMPQDH->QDH_TITULO ), TMPQDH->QDH_FILIAL, TMPQDH->QDH_CHAVE, TMPQDH->QDH_CODTP } )
	TMPQDH->(DbSkip())
EndDo		

dbSelectArea("TMPQDH")
dbCloseArea()

dbSelectArea("QDH")

EndIf

IF ExistBlock( "QDOAP29" )
    IF Len(aQDH) > 0
		aQDH:= aClone( ExecBlock( "QDOAP29", .f., .f. ,{ aClone(aQDH) })	)
	Endif	
Endif

If nTP == 1 .Or. nTP == 3 
	If !lQDHFil .AND. nTP == 3
		bQDHLine:= { || { ;
		If( Len( aQDH ) > 0, If( aQDH[ oQDH:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
		If( Len( aQDH ) > 0, QD120NFIL(aQDH[ oQDH:nAt, 5 ]), Space( 2 ) ),; 	
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 7 ], OemToAnsi( STR0084)),;  //"Tipo Doc"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], OemToAnsi( STR0033 ) ),; //"Documento"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], OemToAnsi( STR0034 ) ),; //"Revis„o"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], OemToAnsi( STR0035 ) ) } } //"T¡tulo"
	Else
		bQDHLine:= { || { ;
		If( Len( aQDH ) > 0, If( aQDH[ oQDH:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 7 ], OemToAnsi( STR0084)),;  //"Tipo Doc"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], OemToAnsi( STR0033 ) ),; //"Documento"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], OemToAnsi( STR0034 ) ),; //"Revis„o"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], OemToAnsi( STR0035 ) ) } } //"T¡tulo"		
	Endif
Elseif nTP == 4
	
	If lQDHFil
		bQDHLine:= { || { ;
		If( Len( aQDH ) > 0, If( aQDH[ oQDH:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 7 ], OemToAnsi( STR0084)),;  //"Tipo Doc"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], OemToAnsi( STR0033 ) ),; //"Documento"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], OemToAnsi( STR0034 ) ),; //"Revis„o"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], OemToAnsi( STR0035 ) ) } } //"T¡tulo"		
	Else
		bQDHLine:= { || { ;
		If( Len( aQDH ) > 0, If( aQDH[ oQDH:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
		If( Len( aQDH ) > 0, QD120NFIL(aQDH[ oQDH:nAt, 5 ]), Space( 2 ) ),; 	
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 7 ], OemToAnsi( STR0084)),;  //"Tipo Doc"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], OemToAnsi( STR0033 ) ),; //"Documento"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], OemToAnsi( STR0034 ) ),; //"Revis„o"
		If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], OemToAnsi( STR0035 ) ) } } //"T¡tulo"
	Endif
			
Else
	bQDHLine:= { || { ;	
	If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 7 ], OemToAnsi( STR0084 ) ),;  //"Tipo Doc"
	If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], OemToAnsi( STR0033 ) ),; //"Documento"
	If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], OemToAnsi( STR0034 ) ),; //"Revis„o"
	If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], OemToAnsi( STR0035 ) ) } } //"T¡tulo"
Endif

QDH->( DbSetOrder( 1 ) )
QD1->( DbSetOrder( 1 ) )
QDG->( DbSetOrder( 1 ) )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleQAD  ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona todos os Departamentos do cadastrado QAA         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleQAD()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleQAD()

aQAD:={}


QAD->(DbSetOrder(1))
QAD->(DbGotop())
While !QAD->(Eof())
	If Empty(QAD->QAD_FILMAT) .Or. Empty(QAD->QAD_MAT) .Or.  QAD->QAD_STATUS == "2"
		QAD->(DbSkip())
		Loop
	Endif
	
	If !QAA->(dbSeek( QAD->QAD_FILMAT + QAD->QAD_MAT ))
		QAD->(DbSkip())
		Loop
	Endif
	
	aAdd(aQAD,{ .F., QAD->QAD_FILIAL,;
	QAD->QAD_CUSTO,;
	OemToAnsi( QAD->QAD_DESC ),;
	QAD->QAD_FILMAT,;
	QAD->QAD_MAT,;
	QAA->QAA_CC,;
	QAA->QAA_CODFUN,;//Cargo
	1,;              //nCopias
	QAA->(Recno())})
	
	QAD->(DbSkip())
EndDo 

If Len(aQad)==0
		   MsgAlert(STR0097,STR0098)
EndIF

bQADLine:= { || {	If( Len( aQAD ) > 0, If( aQAD[ oQAD:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 2 ], CriaVar( "QAD_FILIAL") ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 3 ], CriaVar( "QAD_CUSTO" ) ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 4 ], CriaVar( "QAD_DESC"  ) ) } }

Return
		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SeleQDC  ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona todos as Pastas cadastrado QDC				 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleQDC()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120 		                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleQDC()

aQDC     := {}
aQDCRegs := {}
QDC->( DbSeek( xFilial( "QDC" ) ) )
While !QDC->( Eof() ) .And. xFilial("QDC") == QDC->QDC_FILIAL
	aAdd( aQDC, { .F. , QDC->QDC_FILIAL , QDC->QDC_CODMAN , OemToAnsi( QDC->QDC_DESC ) } )
	aAdd( aQDCRegs, QDC->QDC_CODMAN )
	QDC->(DbSkip())
Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HabUsr   ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita o usuario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HabUsr( <nParam1>,<nParam2> )                              ³±±
±±³          ³ nParam1: Numero do item do browse.(Vetor dos Usuarios)     ³±±
±±³          ³ lParam2: Valor logico indicando Selecionado/Nao Selecionado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SeleUsr	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HabUsr( nQDG,lHab )

nQDG := If( nQDG == NIL, oQDG:nAt, nQDG )

If Len(aQDG) == 0
	Return NIL
EndIF

If nTP == 2 .Or. nTP == 3
	aQDG[nQDG,1] := !(aQDG[nQDG,1])
	oQDG:SetArray( aQDG )
	oQDG:bLine := bQDGLine
	oQDG:Refresh()
Endif

If nTP == 1
	cMat    := aQDG[oQDG:nAt,2]
	cNome   := aQDG[oQDG:nAt,3]
	cDepto1 := aQDG[oQDG:nAt,4]
	cDepto  := aQDG[oQDG:nAt,8]
	cFil    := aQDG[oQDG:nAt,5]
	cCargo  := aQDG[oQDG:nAt,6]
	cTpDist := aQDG[oQDG:nAt,7]
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HabQDH   ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita o documento 							        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HabQDH( nParam1 ,lParam2  )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nParam1: Numero do item do browse. (Vetor dos Documentos)  ³±±
±±³          ³ lParam2: Valor logico indicando se for pastas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SeleDoc                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HabQDH( nQDH )

nQDH := If( nQDH == NIL, oQDH:nAt, nQDH )

If Len( aQDH ) == 0
	Return NIL
Endif

If nTP == 1 .Or. nTP == 3 .Or. nTP == 4  
	aQDH[nQDH,1]:= !(aQDH[nQDH,1])
	oQDH:SetArray( aQDH )
	oQDH:bLine := bQDHLine
	oQDH:Refresh()
Endif

If nTP == 2 .Or. nTP == 3 
	cDocto  := aQDH[oQDH:nAt,2]
	cRev    := aQDH[oQDH:nAt,3]
	cTitulo := aQDH[oQDH:nAt,4]
	cFil    := aQDH[oQDH:nAt,5]
	cChTxt  := aQDH[oQDH:nAt,6]
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MarQDH   ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca Documentos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarQDH( )                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SeleDoc	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarQDH()

Local nCQDH:=0, nCF:=0

If Len( aQDH ) == 0
	Return NIL
End

For nCQDH := 1 to Len( aQDH )
	If aQDH[ nCQDH, 1 ] != .T.
		nCF ++
	EndIf
Next
For nCQDH:= 1 to Len( aQDH )
	If nCF == 0
		aQDH[ nCQDH, 1 ]:= .F.
	Else
		aQDH[ nCQDH, 1 ]:= .T.
	EndIf
Next

oQDH:SetArray( aQDH )
oQDH:bLine	:= bQDHLine
oQDH:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MarQDG   ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 27/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³	Marca Distribuicao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarQDG( )                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SeleUsr	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarQDG()

Local nCQDG:=0, nCF:=0

If Len( aQDG ) == 0
	Return NIL
End

For nCQDG := 1 to Len( aQDG )
	If aQDG[ nCQDG, 1 ] != .T.
		nCF ++
	EndIf
Next
For nCQDG:= 1 to Len( aQDG )
	If nCF == 0
		aQDG[ nCQDG, 1 ]:= .F.
	Else
		aQDG[ nCQDG, 1 ]:= .T.
	EndIf
Next

oQDG:SetArray( aQDG )
oQDG:bLine 	:= bQDGLine
oQDG:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MarQAD   ³ Autor ³Newton R. Ghiraldelli  ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³	Marca Departamentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarQAD( )                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SeleCC	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarQAD()

Local ncQAD  := 0
Local lAchou := .F.

If Len( aQAD ) == 0
	Return NIL
Endif

If aScan(aQAD,{|X| X[1] == .T.}) > 0
	lAchou := .T.
Endif

For ncQAD:= 1 to Len( aQAD )
	If lAchou
		aQAD[ ncQAD, 1 ]:= .F.
	Else
		aQAD[ ncQAD, 1 ]:= .T.
	EndIf
Next

oQAD:SetArray( aQAD )
oQAD:bLine	:= bQADLine
oQAD:Refresh()

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GrvLog     ³ Autor ³Newton R. Ghiraldelli³ Data ³ 27.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Log de Copias Emitidas                       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GrvLog(lDistr,cMotLog,cTpDist,nCopias,cFilSol,cMatSol,     ³±±
±±³          ³          cFilDes,cMatDes)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lDistr  = Se a origem do Log for da Distribuicao           ³±±
±±³          ³ cMotLog = Descricao do Motivo da Copia                     ³±±
±±³          ³ cTpDist = Tipo de Distribuicao (Usuario ou Pasta)          ³±±
±±³          ³ nCopias = Numero de Copias                                 ³±±
±±³          ³ cFilSol = Filial do Usuario Solicitante       	           ³±±
±±³          ³ cMatSol = Codigo do Usuario Solicitante                    ³±±
±±³          ³ cFilDes = Filial do Usuario Destino                        ³±±
±±³          ³ cMatDes = Codigo do Usuario Destino                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrvLog(lDistr,cMotLog,cTpDist,nCopias,cFilSol,cMatSol,cFilDes,cMatDes,cTpRcbt,nCV)

Local cChave, cCodSeq
Local lAchou:=.F.

If nTP==1
	cCodSeq:=STRZERO( VAL( QA_SEQU( aQDH[ nCV, 2 ] + aQDH[ nCV, 3 ] + "LOG",6,"N")),6)
	cChave:=aQDH[ nCV, 5 ] + aQDH[ nCV, 2 ] + aQDH[ nCV, 3 ] + cCodSeq
	cChave2:= aQDH[ nCV, 5 ] + aQDH[ nCV, 2 ] + aQDH[ nCV, 3 ] 
Elseif nTP==2 .or. nTP == 3
	cCodSeq:=STRZERO( VAL( QA_SEQU( cDocto + cRev + "LOG",6,"N")),6)
	cChave:=cFil + cDocto + cRev + cCodSeq
	cChave2:= cFil + cDocto + cRev 
EndIf

DbSelectArea("QDE")
DbSetOrder(1)

If clibvias == "2"
	If cTipDest == "I"
		If DbSeek(cChave2)
			While QDE->(!EOF()) .and. QDE->QDE_FILIAL+QDE->QDE_DOCTO+QDE->QDE_RV == cChave2
				If QDE->QDE_FILDES+QDE->QDE_MATDES == cFilDes+cMatDes .and. ALLTRIM(QDE->QDE_MOTIVO) == cMotLog .AND. QDE->QDE_TPRCBT == cTpRcbt
					lAchou:=.T. 
					Exit
				Endif   
				QDE->(DBSKIP())
			Enddo                                         
			If !DbSeek(cChave)
   		   		RecLock("QDE",.T.)
		   		If nTP==1
			   		QDE->QDE_FILIAL := aQDH[ nCV, 5 ]
	   		  		QDE->QDE_DOCTO  := aQDH[ nCV, 2 ]
	   	   	 		QDE->QDE_RV     := aQDH[ nCV, 3 ]
		   	   		QDE->QDE_TPDIST := cTpDist
   		  		Elseif nTP==2 .or. nTP == 3
					QDE->QDE_FILIAL := cFil
	   				QDE->QDE_DOCTO  := cDocto
	   				QDE->QDE_RV     := cRev
					If nTP == 2
				   		QDE->QDE_TPDIST := aQDG[ nCV, 7 ]
					Else
			   			QDE->QDE_TPDIST := cTpDist
					Endif
				Endif
				QDE->QDE_SEQ    := cCodSeq
				QDE->QDE_CONTR  := If( lDistr, "S", "N" )
   				QDE->QDE_DATA   := dDataBase
   				QDE->QDE_MOTIVO := cMotLog
	   	   		QDE->QDE_NCOP   := nCopias
   		   		QDE->QDE_OBSOL  := "N"
   	  			QDE->QDE_FILSOL := cFilSol
	   	   		QDE->QDE_MATSOL := cMatSol
   		  		QDE->QDE_FILDES := cFilDes
 	  			QDE->QDE_MATDES := cMatDes
	   	  		QDE->QDE_TPRCBT := cTpRcbt
  		  		QDE->( MsUnlock())
   			Else
   				If lAchou
					RecLock("QDE",.F.)
					QDE->QDE_SEQ    := cCodSeq
					QDE->QDE_CONTR  := If( lDistr, "S", "N" )
	   				QDE->QDE_DATA   := dDataBase
	   				QDE->QDE_MOTIVO := cMotLog
		   	   		QDE->QDE_NCOP   := nCopias
	   		   		QDE->QDE_OBSOL  := "N"
	   	  			QDE->QDE_FILSOL := cFilSol
		   	   		QDE->QDE_MATSOL := cMatSol
	   		  		QDE->QDE_FILDES := cFilDes
	 	  			QDE->QDE_MATDES := cMatDes
		   	  		QDE->QDE_TPRCBT := cTpRcbt
	  		  		QDE->( MsUnlock())
   				Endif	
   			Endif
		Endif
	Else 
		If !DbSeek(cChave)
			RecLock("QDE",.T.)
			If nTP==1
				QDE->QDE_FILIAL := aQDH[ nCV, 5 ]
				QDE->QDE_DOCTO  := aQDH[ nCV, 2 ]
				QDE->QDE_RV     := aQDH[ nCV, 3 ]
				QDE->QDE_TPDIST := cTpDist
			Elseif nTP==2 .or. nTP == 3
				QDE->QDE_FILIAL := cFil
				QDE->QDE_DOCTO  := cDocto
				QDE->QDE_RV     := cRev
				If nTP == 2
					QDE->QDE_TPDIST := aQDG[ nCV, 7 ]
				Else
					QDE->QDE_TPDIST := cTpDist
				Endif
			Endif
			QDE->QDE_SEQ    := cCodSeq
			QDE->QDE_CONTR  := If( lDistr, "S", "N" )
			QDE->QDE_DATA   := dDataBase
			QDE->QDE_MOTIVO := cMotLog
			QDE->QDE_NCOP   := nCopias
			QDE->QDE_OBSOL  := "N"
			QDE->QDE_FILSOL := cFilSol
			QDE->QDE_MATSOL := cMatSol
			QDE->QDE_FILDES := cFilDes
			QDE->QDE_MATDES := cMatDes
			QDE->QDE_TPRCBT := cTpRcbt
			QDE->( MsUnlock())
		Else 
			If lAchou
				RecLock("QDE",.F.)
				QDE->QDE_SEQ    := cCodSeq
				QDE->QDE_CONTR  := If( lDistr, "S", "N" )
				QDE->QDE_DATA   := dDataBase
				QDE->QDE_MOTIVO := cMotLog
				QDE->QDE_NCOP   := nCopias
				QDE->QDE_OBSOL  := "N"
				QDE->QDE_FILSOL := cFilSol
				QDE->QDE_MATSOL := cMatSol
				QDE->QDE_FILDES := cFilDes
				QDE->QDE_MATDES := cMatDes
				QDE->QDE_TPRCBT := cTpRcbt
				QDE->( MsUnlock())
			EndIf
		EndIf
	Endif
Else
	If !DbSeek(cChave)
		RecLock("QDE",.T.)
		If nTP==1
			QDE->QDE_FILIAL := aQDH[ nCV, 5 ]
			QDE->QDE_DOCTO  := aQDH[ nCV, 2 ]
			QDE->QDE_RV     := aQDH[ nCV, 3 ]
			QDE->QDE_TPDIST := cTpDist
		Elseif nTP==2 .or. nTP == 3
			QDE->QDE_FILIAL := cFil
			QDE->QDE_DOCTO  := cDocto
			QDE->QDE_RV     := cRev
			If nTP == 2
				QDE->QDE_TPDIST := aQDG[ nCV, 7 ]
			Else
				QDE->QDE_TPDIST := cTpDist
			Endif
		Endif
		QDE->QDE_SEQ    := cCodSeq
		QDE->QDE_CONTR  := If( lDistr, "S", "N" )
		QDE->QDE_DATA   := dDataBase
		QDE->QDE_MOTIVO := cMotLog
		QDE->QDE_NCOP   := nCopias
		QDE->QDE_OBSOL  := "N"
		QDE->QDE_FILSOL := cFilSol
		QDE->QDE_MATSOL := cMatSol
		QDE->QDE_FILDES := cFilDes
		QDE->QDE_MATDES := cMatDes
		QDE->QDE_TPRCBT := cTpRcbt
		QDE->( MsUnlock())
	EndIf  
Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EditUsr  ³ Autor ³ Evaldo V. Batista     ³ Data ³ 04/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita a Quantidade de C¢pias do Destinat rio e Define o    ³±±
±±³          ³ tipo da c¢pia, Papel ou Eletr“nica ou Ambas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EditUsr()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDODISTJ                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EditUsr()

Local oDlg
Local oItCp
Local nOpc1    := 0
Local cDescTit := OemToAnsi(STR0013)+" - "+OemToAnsi(STR0073) // "Destinat rio - Altera‡„o"
Local nItCp    := 0
Local cUsuario := ""
Local nCopias  := 0
Local I		   := 0	

If Len(aQDG) == 0
	Return .F.
EndIf

cUsuario := aQDG[ oQDG:nAt,3 ]
nCopias  := aQDG[ oQDG:nAt,9 ]
nItCp    := Val( aQDG[ oQDG:nAt,7 ] )

DEFINE MSDIALOG oDlg FROM 221,101 TO 405,480 TITLE cDescTit PIXEL

@ 003,003 TO 077,186 OF oDlg PIXEL

@ 012,006 SAY OemToAnsi( STR0064 ) SIZE 135,007 OF oDlg PIXEL	// "Usuario"
@ 024,006 SAY OemToAnsi( STR0065 ) SIZE 035, 007 OF oDlg PIXEL	// "Nr Copias"

@ 011,040 MSGET cUsuario PICTURE "@!"   WHEN .f.          SIZE 144, 010 OF oDlg PIXEL
@ 023,040 MSGET nCopias  PICTURE "9999" VALID nCopias > 0 SIZE 024, 010 OF oDlg PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que Monta Array com outras tipos de Copias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("QDOAP21")   
	aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0067)},{2,OemToAnsi(STR0068)},{3,OemToAnsi(STR0069)},{4,OemToAnsi(STR0070)}})	
	aCobItens:={}
	FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
	NEXT
	cItCp:= aNovItens[nItCp,2]
	
	@ 032,095 SAY OemToAnsi(STR0066) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
	@ 032,125 	COMBOBOX oItCp VAR cItCp ;
				ITEMS aCobItens ;
				SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlg PIXEL
Else	
	@ 025,105 TO 073,181 LABEL OemToAnsi(STR0066) OF oDlg PIXEL // "Tipo Copias"
	@ 032,115 RADIO oItCp VAR nItCp;
				ITEMS OemToAnsi( STR0067 ),;		// "&Eletr“nica"
						OemToAnsi( STR0068 ),;		// "&Papel"
						OemToAnsi( STR0069 ),;		// "&Ambos"
						OemToAnsi( STR0070 );			// "Nao &Recebe"
				3D SIZE 050, 007 OF oDlg PIXEL
Endif

DEFINE SBUTTON FROM 079, 130 TYPE 1 ENABLE OF oDlg ACTION ( nOpc1 := 1, oDlg:End() )
DEFINE SBUTTON FROM 079, 160 TYPE 2 ENABLE OF oDlg ACTION ( nOpc1 := 0, oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc1 == 1
	aQDG[ oQDG:nAt, 7 ] := Str( nItCp, 1 )
	aQDG[ oQDG:nAt, 9 ] := nCopias
	cTpDist             := Str( nItCp, 1 )
	nQtdCop             := nCopias
EndIf

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ f_ProcRv ³ Autor ³ Alexandre Mauricio    ³ Data ³ 30/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a Existencia de revisao de um Documento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ f_ProcRv(cFilial,cDocto,aRevis)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Continua()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilial = Codigo da Filial                                 ³±±
±±³          ³ cDocto  = Codigo do DOcumento                  	           ³±±
±±³          ³ aRevis  = Array com as Revisoes existentes - Var por @     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION f_ProcRv ( cFilialp, cDoctop, aRevis )

QDH->( DbSetOrder( 1 ) )

If QDH->(dbSeek(cFilialp+cDoctop))
	While cFilialp+cDoctop == QDH->QDH_FILIAL+QDH->QDH_DOCTO
		If Len(aRevis) == 0
			Aadd(aRevis,{ QDH->QDH_RV , QDH->QDH_STATUS } )
		Else
			If QDH->QDH_STATUS == "L  " .And. Val(aRevis[1,1]) < Val(QDH->QDH_RV)
				aRevis := { {QDH->QDH_RV, QDH->QDH_STATUS} }
			Else
				Aadd(aRevis,{ QDH->QDH_RV , QDH->QDH_STATUS } )
			Endif
		Endif
		QDH->(dbSkip())
	Enddo
EndIf

RETURN iif(Len(aRevis)>0,.T.,.F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QSomaH   ³ Autor ³ Aldo Marini Junior    ³ Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona 1(um) minuto nas Horas informadas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QSomaH(cHrIni)

Local nHoras :=0
Local nInt := 0
Local nDec := 0

nHoras := (Val(Subs(AllTrim(cHrIni),1,2)) * 60) + Val(Right(AllTrim(cHrIni),2)) + 1

nInt := Int(nHoras / 60)
nDec := Mod(nHoras , 60)

Return(StrZero(nInt,2)+":"+StrZero(nDec,2))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD120PesqU³ Autor ³ Eduardo de Souza     ³ Data ³ 06/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Usuarios                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD120PesqU()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD120PesqU()

Local oDlgPesq
Local oFilUsr
Local oCodUsr
Local oDesUsr
Local cFilUsr:= xFilial("QAA")
Local cCodUsr:= Space(TamSx3("QAA_MAT" )[1])
Local cDesUsr:= Space(TamSx3("QAA_NOME")[1])
Local nOpcao1:= 0
Local nPos   := 0

Local oFilDep
Local oCodDep
Local oDesDep
Local cFilCC := xFilial("QAD")
Local cCodDep:= Space(TamSx3("QAD_CUSTO")[1])
Local cDesDep:= Space(TamSx3("QAD_DESC" )[1])
Local oRadPes
Local nRadPes:=1


DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(STR0072) FROM 000,000 TO 280,310 OF oMainWnd PIXEL //"Pesquisa"

@ 003,003 TO 040,153 OF oDlgPesq PIXEL 

@ 010,013 RADIO oRadPes VAR nRadPes ITEMS;
					OemToAnsi(STR0064),; //"Usuario"
					OemToAnsi(STR0031) ; //"Departamento"
			  3D SIZE 043,012 OF oDlgPesq PIXEL ;
			  ON CHANGE If(nRadPes == 1,(oFilUsr:Enable(),oCodUsr:Enable(),oFilDep:Disable(),oCodDep:Disable()),;
			  				(oFilDep:Enable(),oCodDep:Enable(),oFilUsr:Disable(),oCodUsr:Disable())) 

@ 042,003 TO 080,153 LABEL OemToAnsi(STR0064) OF oDlgPesq PIXEL //"Usuario"
@ 050,006 MSGET oFilUsr VAR cFilUsr PICTURE "@!" F3 "SM0_01" SIZE 025,008 OF oDlgPesq PIXEL;
          VALID QA_CHKFIL(cFilUsr,@cFilMat)

@ 050,055 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oDlgPesq PIXEL;
				VALID If(Empty(cDesUsr:= QA_NUSR(cFilUsr,cCodUsr,.T.)),;
						(Help(" ",1,"QD050FNE"),oDesUsr:Refresh(),.F.),; // "Usuario nao existe"
						(oDesUsr:Refresh(),.T.))

@ 065,006 MSGET oDesUsr VAR cDesUsr SIZE 100,008 OF oDlgPesq PIXEL
oDesUsr:lReadOnly:= .T.


@ 082,003 TO 118,153 LABEL OemToAnsi(STR0031) OF oDlgPesq PIXEL  //"Departamento"
@ 088,006 MSGET oFilDep VAR cFilCC PICTURE "@!" F3 "SM0_01" SIZE 025,008 OF oDlgPesq PIXEL;
          VALID QA_CHKFIL(cFilCC,@cFilMat)

@ 088,055 MSGET oCodDep VAR cCodDep PICTURE '@!' F3 "QDD" SIZE 054,008 OF oDlgPesq PIXEL;
				VALID If(Empty(cDesDep:= QA_NDEPT(cCodDep,.T.,cFilCC)),;
						(Help(" ",1,"QD050CCNE"),oDesDep:Refresh(),.F.),; // "Depto nao existe"
						(oDesDep:Refresh(),.T.))

@ 102,006 MSGET oDesDep VAR cDesDep SIZE 100,008 OF oDlgPesq PIXEL
oDesDep:lReadOnly:= .T.
oFilDep:Disable()
oCodDep:Disable()


DEFINE SBUTTON FROM 125,095 TYPE 1 ENABLE OF oDlgPesq;
			ACTION (nOpcao1:= 1,oDlgPesq:End())

DEFINE SBUTTON FROM 125,125 TYPE 2 ENABLE OF oDlgPesq;
			ACTION oDlgPesq:End()


ACTIVATE MSDIALOG oDlgPesq CENTERED	

If nOpcao1 == 1
	If nRadPes == 1
		aQDG := aSort( aQDG,,, { |x, y| x[5] + x[2] < y[5] + y[2] } )							
		oQDG:SetArray( aQDG )
		oQDG:bLine:= bQDGLine
		If (nPos:= aScan(aQDG,{|x| x[5]+x[2] == cFilUsr+cCodUsr} )) > 0
			oQDG:nAt:= nPos
			oQDG:Refresh()
		EndIf	
	Else
		aQDG := aSort( aQDG,,, { |x, y| x[5] + x[8] < y[5] + y[8] } )							
		oQDG:SetArray( aQDG )
		oQDG:bLine:= bQDGLine
		If (nPos:= aScan(aQDG,{|x| x[5]+x[8] == cFilCC+cCodDep} )) > 0
			oQDG:nAt:= nPos
			oQDG:Refresh()
		EndIf		
	Endif	
	If nPos == 0
		Help(" ",1,"QD120USRNE") //"Usuario nao encontrado."
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD120Filt ³ Autor ³ Eduardo de Souza     ³ Data ³ 06/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra Usuarios                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD120Filt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD120Filt()

Local oDlg
Local oChk01
Local oChk02
Local oChk03
Local oChk04
Local lChk01Aux	:= lChk01
Local lChk02Aux	:= lChk02
Local lChk03Aux	:= lChk03
Local lChk04Aux	:= lChk04
Local cFiltro	:= ""
Local nOpc1  	:= 0
Local lFecha 	:= .F.

DEFINE MSDIALOG oDlg FROM 201,101 TO 350,360 TITLE OemToAnsi(STR0074) PIXEL // "Filtra Usuarios"

@ 003,003 TO 057,126 LABEL OemToAnsi(STR0066) OF oDlg PIXEL // "Tipo Copias"

@ 011,008 CHECKBOX oChk01 VAR lChk01 PROMPT OemToAnsi(STR0067) SIZE 040,010 OF oDlg PIXEL // "&Eletr“nica"
@ 021,008 CHECKBOX oChk02 VAR lChk02 PROMPT OemToAnsi(STR0068) SIZE 040,010 OF oDlg PIXEL // "&Papel"
@ 031,008 CHECKBOX oChk03 VAR lChk03 PROMPT OemToAnsi(STR0069) SIZE 040,010 OF oDlg PIXEL // "&Ambos"
@ 041,008 CHECKBOX oChk04 VAR lChk04 PROMPT OemToAnsi(STR0070) SIZE 040,010 OF oDlg PIXEL // "Nao &Recebe"

DEFINE SBUTTON FROM 059,070 TYPE 1 ENABLE OF oDlg ;
			ACTION (nOpc1 := 1,lFecha:= .T.,oDlg:End())

DEFINE SBUTTON FROM 059,100 TYPE 2 ENABLE OF oDlg ;
			ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED VALID lFecha

If nOpc1 == 1

	If lChk01
		cFiltro+= "1,"
	EndIf	

	If lChk02
		cFiltro += "2,"
	EndIf
	
	If lChk03
		cFiltro+= "3,"
	EndIf
	
	If lChk04
		cFiltro+= "4,"
	EndIf

	If Right(cFiltro, 1) = ","
		cFiltro := Left(cFiltro, Len(cFiltro) - 1)
	Endif

	DbSelectArea("QAA")
	If ! Empty(cFiltro)
			cFiltro:= "QAA_TPRCBTP $ '" + cFiltro + "'"
		Set Filter To &(cFiltro)
	Else
		Set Filter To 
		lChk01 := .T.
		lChk02 := .T.
		lChk03 := .T.
		lChk04 := .T.
	Endif
	
	MsgRun(OemToAnsi(STR0021),OemToAnsi(STR0022),{ || SeleQAA() } ) //"Selecionando Usu rios" ### "Aguarde..."
	
	oQDG:SetArray( aQDG )
	oQDG:bLine:= bQDGLine
	oQDG:Refresh()
	If Len(aQDG) > 0
		oQDG:nAt:= 1
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna a marcacao anterior no cancelamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lChk01:= lChk01Aux
	lChk02:= lChk02Aux
	lChk03:= lChk03Aux
	lChk04:= lChk04Aux
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD120PesqD³ Autor ³ Eduardo de Souza     ³ Data ³ 09/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Documentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD120PesqD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD120PesqD()

Local oDlgPesq
Local oCodDoc
Local cCodDoc:= Space(TamSx3("QDH_DOCTO" )[1])
Local nOpcao1:= 0
Local nPos   := 0

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(STR0072) FROM 000,000 TO 090,300 OF oMainWnd PIXEL //"Pesquisa"

@ 003,003 TO 030,143 LABEL OemToAnsi(STR0033) OF oDlgPesq PIXEL //"Documento"

@ 011,006 MSGET oCodDoc VAR cCodDoc F3 "QDT" SIZE 080,010 OF oDlgPesq PIXEL

DEFINE SBUTTON FROM 031,085 TYPE 1 ENABLE OF oDlgPesq;
			ACTION (nOpcao1:= 1,oDlgPesq:End())

DEFINE SBUTTON FROM 031,115 TYPE 2 ENABLE OF oDlgPesq;
			ACTION oDlgPesq:End()

ACTIVATE MSDIALOG oDlgPesq CENTERED	

If nOpcao1 == 1
	If (nPos:= aScan(aQDH,{|x| x[2] == cCodDoc} )) > 0
		oQDH:nAt:= nPos
		oQDH:Refresh()
	EndIf	
	If nPos == 0
		Help(" ",1,"QD120DNE") //"Documento nao encontrado."
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD120PesqCC ³ Autor ³ Eduardo de Souza   ³ Data ³ 12/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Departamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD120PesqCC()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA120                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD120PesqCC()

Local oDlg2
Local oFilDep
Local oCodDep
Local oDesDep
Local cFilCC := xFilial("QAD")
Local cCodDep:= Space(TamSx3("QAD_CUSTO")[1])
Local cDesDep:= Space(TamSx3("QAD_DESC" )[1])
Local nOpcao1:= 0
Local nPos   := 0

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0072) FROM 000,000 TO 110,310 OF oMainWnd PIXEL //"Pesquisa"

@ 003,003 TO 040,153 LABEL OemToAnsi(STR0031) OF oDlg2 PIXEL //"Departamento"

@ 010,006 MSGET oFilDep VAR cFilCC PICTURE "@!" F3 "SM0_01" SIZE 025,008 OF oDlg2 PIXEL;
          VALID QA_CHKFIL(cFilCC,@cFilDep) When Empty(cFilCC)

@ 010,060 MSGET oCodDep VAR cCodDep PICTURE '@!' F3 "QDD" SIZE 044,008 OF oDlg2 PIXEL;
				VALID If(Empty(cDesDep:= QA_NDEPT(cCodDep,.T.,cFilCC)),;
						(Help(" ",1,"QD050CCNE"),oDesDep:Refresh(),.F.),; // "Depto nao existe"
						(oDesDep:Refresh(),.T.))

@ 025,006 MSGET oDesDep VAR cDesDep SIZE 100,008 OF oDlg2 PIXEL
oDesDep:lReadOnly:= .T.

DEFINE SBUTTON FROM 041,095 TYPE 1 ENABLE OF oDlg2;
			ACTION (nOpcao1:= 1,oDlg2:End())

DEFINE SBUTTON FROM 041,125 TYPE 2 ENABLE OF oDlg2;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

If nOpcao1 == 1
	If (nPos:= aScan(aQAD,{|x| x[2]+x[3] == cFilCC+cCodDep} )) > 0
		oQAD:nAt:= nPos
		oQAD:Refresh()
	EndIf
	If nPos == 0
		Help(" ",1,"QD050CCNE") //"Departamento nao existe"
	EndIf
EndIf
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD120AlCop  ³ Autor ³ Telso Carneiro				³ Data ³08/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de alteracao de destinatarios                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD120AlQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA120                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD120AlCop(aQAD,nPos)

Local oDlgC
Local oDepto
Local oNDepto
Local oCopias
Local cDepto := ""
Local cNDepto:= ""
Local nOpc1  := 0
Local nCopias:= 1
Local I		 := 0

DEFINE MSDIALOG oDlgC FROM 000,000 TO 134,377 TITLE OemToAnsi(STR0065) PIXEL //"Nr Copias"

cDepto	:= aQAD[nPos,3]
cNDepto := aQAD[nPos,4]
nCopias := aQAD[nPos,9]

@ 003,003 TO 52,186 OF oDlgC PIXEL

@ 007,006 SAY OemToAnsi(TitSX3("QAD_CUSTO" )[1]) SIZE 035,007 OF oDlgC PIXEL 
@ 007,040 MSGET oDepto VAR cDepto SIZE 070,008 OF oDlgC PIXEL
oDepto:lReadOnly:= .T.

@ 022,006 SAY OemToAnsi(TitSX3("QAD_DESC"  )[1]) SIZE 035,007 OF oDlgC PIXEL 
@ 022,040 MSGET oNDepto VAR cNDepto SIZE 144,008 OF oDlgC PIXEL
oNDepto:lReadOnly:= .T.

@ 037,006 SAY OemToAnsi( STR0065 ) SIZE 035,007 OF oDlgC PIXEL //"Nr Copias"	
@ 037,040 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oDlgC PIXEL;
				VALID nCopias > 0

IF ExistBlock("QDOAP21")   
	nItCp 	:= Val(aQAD[nPos,Len(aQAD[nPos])])
	nItCp   := IF(nItCp<=2,nItCp / 2,nItCp-2)		
	aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{2,OemToAnsi(STR0068)},{4,OemToAnsi(STR0070)}})			
	aCobItens:={}
	FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
	NEXT
	cItCp:= aNovItens[nItCp,2]
	
	@ 037,095 SAY OemToAnsi(STR0066) SIZE 035,007 OF oDlgC PIXEL // "Tipo Copias"
	@ 037,125 	COMBOBOX oItCp VAR cItCp ;
				ITEMS aCobItens ;
				SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlgC PIXEL
Endif


DEFINE SBUTTON FROM 54,130 TYPE 1 ENABLE OF oDlgC ACTION	(nOpc1:=1,oDlgC:End())
DEFINE SBUTTON FROM 54,160 TYPE 2 ENABLE OF oDlgC ACTION	oDlgC:End()

ACTIVATE	MSDIALOG oDlgC CENTERED

If nOpc1 = 1
	aQAD[nPos,9]:=nCopias 
	IF ExistBlock("QDOAP21")                 
		nItCp   := IF(nItCp<=2,nItCp * 2,nItCp+2)
		aQAD[nPos,Len(aQAD[nPos])]:=Str( nItCp ,1)
	Endif	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD120NFIL ºAutor  ³Telso Carneiro      º Data ³  09/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localiza o Nome da Filial para os ListBox                  º±±
±±º			 ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QD120NFIL(Filial )                          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  bLine  													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD120NFIL(cCodFil)
local aArea   := GetArea()
Local nPosSM0 := 1
Local cFilAtu :=""  

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpAnt+cCodFil))
	cFilAtu := cCodFil+"-"+SM0->M0_FILIAL
Endif
SM0->(DbGoto(nPosSM0))

RestArea(aArea)

Return(cFilAtu)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SeleLoc   ºAutor  ³Telso Carneiro      º Data ³  09/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona as Palavras-Chaves (Localizadores)                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QDOA120                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SeleLoc()

Local cQuery  := ""
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local oDlgLoc
Local cQDK	 := " "
Local lExDoc := .T.
Local lQDKFil  := FwModeAccess("QDK") == "C" //Empty(xFilial("QDK"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se um Pelos um Documento Selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aQDH,{|x| IF(x[1],lExDoc:=.F.,"")})
IF lExDoc 
	Help(" ",1,"QDA050BRA") // "Campo Obrigatorio nao preenchido."				
	Return
Endif                        

aQDK:={}

QDK->( DbSetOrder( 1 ) )

cQuery := "SELECT QDK_FILIAL,QDK_CHAVE FROM " + RetSqlName("QDK")
cQuery += " WHERE D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY " + SqlOrder(QDK->(IndexKey()))
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDK",.T.,.T.)
  		
TMPQDK->(dbGoTop())
While !TMPQDK->( Eof() )
	AAdd( aQDK, { .F., TMPQDK->QDK_FILIAL, TMPQDK->QDK_CHAVE } )
	TMPQDK->(DbSkip())
EndDo	

dbSelectArea("TMPQDK")
dbCloseArea()

dbSelectArea("QDK")

QDK->( DbSetOrder( 1 ) )

DEFINE MSDIALOG oDlgLoc TITLE OemToAnsi(STR0085) FROM 000,000 TO 245,625 OF oMainWnd PIXEL   //"Sele‡ão de Localizadores"
	
@ 005,004 TO 120,310 LABEL OemToAnsi(STR0086) OF oDlgLoc PIXEL //"Localizador"

If lQDKFil
	@ 015, 007 LISTBOX oQDK	VAR cQDK	FIELDS;
			HEADER " ",;
				AllTrim(TitSX3("QDK_CHAVE")[1] );						
			SIZE 270,100 OF oDlgLoc PIXEL ;
			WHEN Len(aQDK) > 0;
			ON DBLCLICK(aQDK[oQDK:nAt,1]:= !(aQDK[oQDK:nAt,1]),oQDK:Refresh())

	bQDKLine:= { || { ;
	If( Len( aQDK ) > 0, If( aQDK[ oQDK:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
	If( Len( aQDK ) > 0, aQDK[ oQDK:nAt, 3 ], Space(TamSx3("QDK_CHAVE")[1]) ) } } 			

Else
	@ 015, 007 LISTBOX oQDK	VAR cQDK	FIELDS;
			HEADER " ",; 
				AllTrim(TitSX3("QDK_FILIAL")[1]),;						
				AllTrim(TitSX3("QDK_CHAVE")[1] );						
			SIZE 270,100 OF oDlgLoc PIXEL ;
			WHEN Len(aQDK) > 0;
			ON DBLCLICK(aQDK[oQDK:nAt,1]:= !(aQDK[oQDK:nAt,1]),oQDK:Refresh())

	bQDKLine:= { || { ;
	If( Len( aQDK ) > 0, If( aQDK[ oQDK:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;	
	If( Len( aQDK ) > 0, QD120NFIL(aQDK[ oQDK:nAt, 2 ]), Space( 2 ) ),; 	
	If( Len( aQDK ) > 0, aQDK[ oQDK:nAt, 3 ],Space(TamSx3("QDK_CHAVE")[1]))  } } 
Endif			     

oQDK:SetArray(aQDK)
oQDK:bLine:= bQDKLine

DEFINE SBUTTON oBtn1 FROM 016,279 TYPE 4 ENABLE OF	oDlgLoc;
			ACTION (IF(QD120AlcL(3),oDlgLoc:End(),""))			
oBtn1:cToolTip:=OemToAnsi(STR0087)  //"Inclusão de Localizador(es) no(s) Documento(s)"

DEFINE SBUTTON oBtn2 FROM 030,279 TYPE 3 ENABLE OF	oDlgLoc;
			ACTION (IF(QD120AlcL(5),oDlgLoc:End(),""))			
oBtn2:cToolTip:=OemToAnsi(STR0089)  //"Exclusão de Localizador(es) no(s) Documento(s)"

DEFINE SBUTTON oBtn3 FROM 044,279 TYPE 2 ENABLE OF	oDlgLoc;
			ACTION oDlgLoc:End()			
oBtn3:cToolTip:=OemToAnsi( STR0039 ) //"Cancelar"	

@ 058,279 BUTTON oBtn4 PROMPT OemToAnsi(STR0094) ;
  ACTION  aEval(aQDK,{|x| x[1]:=!x[1]});
 SIZE 026,012 OF oDlgLoc PIXEL 
	oBtn4:cToolTip := OemToAnsi(STR0094)

@ 072,279 BUTTON oBtn5 PROMPT OemToAnsi(STR0072) ;
  ACTION  (QD120PesLc(), oQDK:Refresh() );
  SIZE 026,012 OF oDlgLoc PIXEL 
	oBtn5:cToolTip := OemToAnsi(STR0072)

ACTIVATE MSDIALOG oDlgLoc CENTERED

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD120PesLc³ Autor ³ Telso Carneiro       ³ Data ³ 09/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Localizadores                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD120PesLc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD120PesLc()

Local oDlgPesq
Local oCodLoc
Local cCodLoc:= Space(TamSx3("QDK_CHAVE" )[1])
Local nOpcao1:= 0
Local nPos   := 0

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(STR0072) FROM 000,000 TO 090,300 OF oMainWnd PIXEL //"Pesquisa"

@ 003,003 TO 030,143 LABEL OemToAnsi(STR0086) OF oDlgPesq PIXEL  //"Localizador"

@ 011,006 MSGET oCodLoc VAR cCodLoc F3 "QDK" SIZE 080,010 OF oDlgPesq PIXEL

DEFINE SBUTTON FROM 031,085 TYPE 1 ENABLE OF oDlgPesq;
ACTION (nOpcao1:= 1,oDlgPesq:End())

DEFINE SBUTTON FROM 031,115 TYPE 2 ENABLE OF oDlgPesq;
ACTION oDlgPesq:End()

ACTIVATE MSDIALOG oDlgPesq CENTERED

If nOpcao1 == 1
	If (nPos:= aScan(aQDK,{|x| x[3] == cCodLoc} )) > 0
		oQDK:nAt:= nPos
	Else
		Help(" ",1,'REGNOIS')
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD120AlcL ºAutor  ³Telso Carneiro      º Data ³  09/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir ou Exclui os Localizadores no Documento selecionadoº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SeleLoc()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD120AlcL(nOpcao)
Local lExDoc := .T.
Local nD	 := 0
Local nL	 := 0
Local lRet	 := .T.
Local lQDHFil:= FwModeAccess("QDH") == "C" //Empty(xFilial("QDH"))
Local lQDKFil:= FwModeAccess("QDK") == "C" //Empty(xFilial("QDK"))

DbSelectArea("QD6")
QD6->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se um Pelos um Documento Selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aQDK,{|x| IF(x[1],lExDoc:=.F.,"")})
IF lExDoc
	Help(" ",1,"QDA050BRA") // "Campo Obrigatorio nao preenchido."
	lRet:= .F.
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando QDH Exclusivo verifica se os Localizadores respeitan as filiais.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !lQDKFil .AND. !lQDHFil
	cQDHFi:=""
	For nD:= 1 TO Len(aQDH)
		IF aQDH[nD,1] .AND. cQDHFi<>aQDH[nD,5]
			lExDoc:=.T.
			cQDHFi:=aQDH[nD,5]
			aEval(aQDK,{|y|,IF(y[1] .AND. y[2]==cQDHFi,lExDoc:=.F.,"")})
			IF lExDoc
				Help("",1,"REGNOIS",,OemToAnsi(STR0091),3,0) //"Entre as Filiais do(s) Documento(s) e Localizador(es)"
				lRet:= .F.
				Return(lRet)
			Endif
		Endif
	Next
Endif

If !MsgYesNo(OemToAnsi(STR0052),OemToAnsi(STR0010)) //"Confirma a opera‡„o ?" ### "Aten‡„o"
	lRet:= .F.
	Return(lRet)
EndIf

CursorWait()
Begin Transaction
IF nOpcao== 3 //Inclusao
	For nD:=1 To Len(aQDH)
		IF aQDH[nD,1]
			For nL:=1 To Len(aQDK)
				IF aQDK[nL,1]
					IF !QD6->(DbSeek(aQDH[nD,5]+aQDH[nD,2]+aQDH[nD,3]+aQDK[nL,3]))
						RecLock("QD6",.T.)
						QD6->QD6_FILIAL	:=aQDH[nD,5]
						QD6->QD6_DOCTO	:=aQDH[nD,2]
						QD6->QD6_RV		:=aQDH[nD,3]
						QD6->QD6_CHAVE	:=aQDK[nL,3] //Localizador
						MsUnlock()
						FkCommit()
					Endif
				Endif
			Next
		Endif
	Next
ElseIF nOpcao== 5 //Exclusao
	For nD:=1 To Len(aQDH)
		IF aQDH[nD,1]
			For nL:=1 To Len(aQDK)
				IF aQDK[nL,1]
					IF QD6->(DbSeek(aQDH[nD,5]+aQDH[nD,2]+aQDH[nD,3]+aQDK[nL,3]))
						RecLock("QD6",.F.)
						QD6->(DbDelete())
						MsUnlock()
						FkCommit()
					Endif
				Endif
			Next
		Endif
	Next
Endif
End TransAction
CursorArrow()

MsgAlert(OemToAnsi(STR0092)+IF(nOpcao==3,OemToAnsi(STR0087),OemToAnsi(STR0089)),OemToAnsi(STR0093)) //"Realizada com sucesso a "###"Inclusão de Localizador(es) no(s) Documento(s)"###"Exclusão de Localizador(es) no(s) Documento(s)"###"Informe"

Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QDA120Fil ³ Autor ³Totvs                 | Data ³22/04/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function QDA120Fil(obj) 

If obj:lActive
	cDescQDC := " "
	cQDC:= Space(TamSx3("QDC_CODMAN")[1])
EndIf               

Return .T.  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ recriaAQAD  ³ Autor ³Nilton MK          ³ Data ³ 07/12/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os Departamentos do cadastrado QAA que tiverem   ³±±
±±             relacionamento em QDT (pasta Departamento)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ recriaAQAD(Exp)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function recriaAQAD(cQDC)
lRet:= .F.
aQAD:={}
bLiLocal:= {|| aIn:=Eval(bQADLine),Aadd(ain,aQAD[oQAD:nAt,9] ),aIn }


If cQDC = " "
	lret:=.T.
	Return lRet
Endif

dbselectarea("QDT")
QDT->(Dbsetorder(2))
QDT->(Dbgotop())

QDT->(DbSeek(xFilial("QDC") + cQDC ) )
While !QDT->( Eof() ) .And. QDT->QDT_FILIAL == xFilial("QDT") .And. QDT->QDT_CODMAN = cQDC
	QAD->(DbSetOrder(1))
	QAD->(DbGotop())
	QAD->(Dbseek(xFilial("QAD") + QDT->QDT_DEPTO ) )
	While	!QAD->(Eof()) .And. QAD->QAD_FILIAL == xFilial("QAD") .And. QAD->QAD_CUSTO = QDT->QDT_DEPTO
		If Empty(QAD->QAD_FILMAT) .Or. Empty(QAD->QAD_MAT) .Or.  QAD->QAD_STATUS == "2"
			QAD->(DbSkip())
			Loop
		Endif
	
		If !QAA->(dbSeek( QAD->QAD_FILMAT + QAD->QAD_MAT ))
			QAD->(DbSkip())
			Loop
		Endif

		aAdd(aQAD,{ .F., QAD->QAD_FILIAL,;
		QAD->QAD_CUSTO,;
		OemToAnsi( QAD->QAD_DESC ),;
		QAD->QAD_FILMAT,;
		QAD->QAD_MAT,;
		QAA->QAA_CC,;
		QAA->QAA_CODFUN,;//Cargo
		1,;              //nCopias
		QAA->(Recno())})
	
		QAD->(DbSkip())
	EndDo
	QDT->(DbSkip())
EndDo 

If Len(aQad)==0
   MsgAlert(STR0097,STR0098)
Else
   lRet:=.T.
Endif

bQADLine:= { || {	If( Len( aQAD ) > 0, If( aQAD[ oQAD:nAt, 1 ], hOk, hNo ), Space( 1 ) ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 2 ], CriaVar( "QAD_FILIAL") ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 3 ], CriaVar( "QAD_CUSTO" ) ),;
If( Len( aQAD ) > 0, aQAD[ oQAD:nAt, 4 ], CriaVar( "QAD_DESC"  ) ) } }   

oQAD:SetArray(aQAD)
oQAD:bLine:= bLiLocal
oQAD:Refresh()

Return lRet

/*/{Protheus.doc} VldClickCC
Valida Seleção de Departamento
@since 08/07/2022
@version P12.1.37
@param 01 - aQAD   , array   , registros da grid de departamentos
@param 02 - oQAD   , objeto  , objeto da grid de departamentos
@param 03 - cFilPst, caracter, filial selecionada em tela para pastas
/*/
Static Function VldClickCC(aQAD, oQAD, cFilPst)

	Local cModoQAD  := ""
	Local cModoQDC  := ""
	Local lInvalido := .F.
	Local lModoInv  := ChecaModos(@cModoQDC, @cModoQAD)
	
	lInvalido := (cModoQAD > cModoQDC;
		        .AND. xFilial("QDC", aQAD[oQAD:nAt,2]) != xFilial("QDC", cFilPst);  //QAD mais exclusiva que a QDC
		         ) .OR.              (aQAD[oQAD:nAt,2] != xFilial("QAD", cFilPst) ) //QDC mais exclusiva que a QAD OU Mesmo Compartilhamento

	//STR0099 - Atenção
	//STR0095 - Não é possível selecionar um departamento de filial diferente da filial da pasta.
	//STR0100 - Selecione um departamento válido.
	Iif(lInvalido, Help(NIL, NIL, STR0099, NIL, STR0095, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0100}), "")

	If !lInvalido .AND. !lModoInv
		aQAD[oQAD:nAt,1] := !aQAD[oQAD:nAt,1]
	EndIf

	oQAD:Refresh()
Return

/*/{Protheus.doc} ChecaModos
Checa Modos de Compartilhamento das Tabelas QDC, QAD, QAC e QDT
@since 08/07/2022
@version P12.1.37
@param 01 - cModoQDC , caracter, retorna por referência o modo de compartilhamento da tabela QDC
@param 02 - cModoQAD , caracter, retorna por referência o modo de compartilhamento da tabela QAD
@param 03 - cModoQAC , caracter, retorna por referência o modo de compartilhamento da tabela QAC
@param 04 - cModoQDT , caracter, retorna por referência o modo de compartilhamento da tabela QDT
@return lInvalido, lógico, indica se o modo de compartilhamento é inválido
/*/
Static Function ChecaModos(cModoQDC, cModoQAD, cModoQAC, cModoQDT)

	Local cAtualQAC := ""
	Local cAtualQAD := ""
	Local cAtualQDC := ""
	Local cAtualQDT := ""
	Local lInvalido := .F.
	Local nTamEmp   := 0
	Local nTamFil   := 0
	Local nTamUnid  := 0

	Default cModoQAC := ""
	Default cModoQAD := ""
	Default cModoQDC := ""
	Default cModoQDT := ""

	TamLayout(@nTamEmp, @nTamUnid, @nTamFil)

	If nTamFil > 0
		cAtualQAD := FWModeAccess("QAD", 3)
		cAtualQAC := FWModeAccess("QAC", 3)
		cAtualQDC := FWModeAccess("QDC", 3)
		cAtualQDT := FWModeAccess("QDT", 3)
		If cAtualQAD == "C" .AND. (cAtualQAC == "E" .OR. cAtualQDC == "E" .OR. cAtualQDT == "E")
			lInvalido := .T.
		EndIf
		cModoQAD += cAtualQAD
		cModoQAC += cAtualQAC
		cModoQDC += cAtualQDC
		cModoQDT += cAtualQDT
	EndIf

	If nTamUnid > 0
		cAtualQAD := FWModeAccess("QAD", 2)
		cAtualQAC := FWModeAccess("QAC", 2)
		cAtualQDC := FWModeAccess("QDC", 2)
		cAtualQDT := FWModeAccess("QDT", 2)
		If cAtualQAD == "C" .AND. (cAtualQAC == "E" .OR. cAtualQDC == "E" .OR. cAtualQDT == "E")
			lInvalido := .T.
		EndIf
		cModoQAD += cAtualQAD
		cModoQAC += cAtualQAC
		cModoQDC += cAtualQDC
		cModoQDT += cAtualQDT
	EndIf

	If nTamEmp > 0
		cAtualQAD := FWModeAccess("QAD", 1)
		cAtualQAC := FWModeAccess("QAC", 1)
		cAtualQDC := FWModeAccess("QDC", 1)
		cAtualQDT := FWModeAccess("QDT", 1)
		If cAtualQAD == "C" .AND. (cAtualQAC == "E" .OR. cAtualQDC == "E" .OR. cAtualQDT == "E")
			lInvalido := .T.
		EndIf
		cModoQAD += cAtualQAD
		cModoQAC += cAtualQAC
		cModoQDC += cAtualQDC
		cModoQDT += cAtualQDT
	EndIf

	If lInvalido
		//STR0099 - Atenção
		//STR0101 - Quando a situação da tabela 'QAD - Departamentos/Setor - 
		//STR0102 - ' estiver Compartilhada as tabelas 'QDC - Cadastros de Pastas - 
		//STR0103 - ', 'QDT - Relacionamento de Pastas x Departamento - 
		//STR0104 - ' e 'QAC - Cargos e Funções - 
		//STR0105 - ' não podem estar em modo exclusivo.
		//STR0106 - Solicite apoio do departamento de TI e ajuste a configuração de compartilhamento das tabelas.
		Help(NIL, NIL, STR0099, NIL, STR0101 + cModoQAD + STR0102 + cModoQDC + STR0103 + cModoQDT + STR0104 + cModoQAC + STR0105, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0106})
	EndIf

Return lInvalido

/*/{Protheus.doc} TamLayout
Retorna por referência os tamanhos da filial no layout do sigamat
@since 08/07/2022
@version P12.1.37
@param 01 - nTamEmp , número, tamanho da empresa no layout de filial
@param 02 - nTamUnid, número, tamanho da unidade de negócio no layout de filial
@param 03 - nTamFil , número, tamanho da filial no layout de filial
/*/
Static Function TamLayout(nTamEmp, nTamUnid, nTamFil)
Local cLayout := FWSM0Layout()
Local nCont   := 0
Local nTotal  := Len(cLayout)
For nCont := 1 To nTotal
	If     SubStr(cLayout, nCont, 1) == "E"
		nTamEmp++
	ElseIf SubStr(cLayout, nCont, 1) == "U"
		nTamUnid++
	ElseIf SubStr(cLayout, nCont, 1) == "F"
		nTamFil++
	EndIf
Next nCont
Return
