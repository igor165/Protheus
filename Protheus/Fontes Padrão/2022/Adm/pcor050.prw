#INCLUDE "PCOR050.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE CELLTAMDATA ((_cAliTotal)->TOT_TAMCOL*7)

Static aPosCol := {}, aCabConteudo := {}, nUltCol := 0
Static _oPCOR0501 := NIL
Static _cAliConta := NIL
Static _oPCOR0502 := NIL
Static _cAliTotal := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR050  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 07-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao da planilha orcamentaria.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR050                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao da planilha orcamentaria.              ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR050(aPerg)

Local aArea		:= GetArea()
Local cRevisa	:= ""
Local lOk		:= .F.
Local oOk		:= LoadBitMap(GetResources(), "LBTIK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")
Local oDlg, oListBox

Local oReport

Private nLin		:= 200
Private aTotList 	:= {}
Private aTotBlock 	:= {}

//OBSERVACAO NAO TIRAR A LINHA ABAIXO POIS SERA UTILIZADA NA CONSULTA PADRAO AKE1
Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME))

Default aPerg := {}


	dbSelectArea("AKK")
	dbSetOrder(1)
	dbSeek(xFilial("AKK"))
	
	While ! Eof() .And. AKK_FILIAL == xFilial("AKK")
		aAdd(aTotList,{.F.,AKK->AKK_COD,AKK->AKK_DESCRI})
		aAdd(aTotBlock, { AKK->(Recno()), AKK->AKK_BLOCK } ) 
	    dbSkip()
	End
	
	If Len(aTotList) > 0
		DEFINE MSDIALOG oDlg FROM 40,168 TO 380,730 TITLE STR0001 Of oMainWnd PIXEL  //"Escolha os Totais da Planilha"
		
			@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
			oListBox := TWBrowse():New( 10,10,206,152,,{" OK ",STR0002,STR0003},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Codigo"###"Descricao"
			oListBox:SetArray(aTotList)
			oListBox:bLine := { || {If(aTotList[oListBox:nAt,1],oOk,oNo),aTotList[oListBox:nAT][2],aTotList[oListBox:nAT][3]}}
			oListBox:bLDblClick := { ||InverteSel(oListBox, oListBox:nAt, .T.)}
		
		   @ 10,230 BUTTON STR0004 		SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,oDlg:End())  OF oDlg PIXEL   //'Confirma >>'
		   @ 25,230 BUTTON STR0005  		SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL   //'<< Cancela'
		   @ 40,230 BUTTON STR0006  		SIZE 45 ,10   FONT oDlg:oFont ACTION (MarcaTodos(oListBox, .F., .T.))  OF oDlg PIXEL   //'Marcar Todos'
		   @ 55,230 BUTTON STR0007 	SIZE 45 ,10   FONT oDlg:oFont ACTION (MarcaTodos(oListBox, .F., .F.))  OF oDlg PIXEL   //'Desmarcar Todos'
		   @ 70,230 BUTTON STR0008	SIZE 45 ,10   FONT oDlg:oFont ACTION (MarcaTodos(oListBox, .T.))  OF oDlg PIXEL   //'Inverter Selecao'
		   @ 85,230 BUTTON STR0009		SIZE 45 ,10   FONT oDlg:oFont ACTION (InverteSel(oListBox, oListBox:nAt, .T.))  OF oDlg PIXEL   //'Marca/Desmarca'
		
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		HELP("  ",1,"PCOR0201") //Cadastro de totais da planilha esta vazio. Verifique!
		lOk := .F.
	EndIf	
		
	If lOk .And. (lOk := Elem_Selec(aTotList))
		If Len(aPerg) # 0
			aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			oReport := ReportDef( ,@cRevisa )
		Else
			oReport := ReportDef("PCR010",@cRevisa)
		EndIf
	EndIf
	
	If lOk
		oReport:PrintDialog()
	EndIf

_oPCOR0502 := NIL
_cAliConta := NIL
_oPCOR0502 := NIL
_cAliTotal := NIL

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR050Proc ³ Autor ³ Gustavo Henrique    ³ Data ³ 19/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento da planilha orcamentaria.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR050Proc(lEnd)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR050Proc( cArqConta, cArqTotal, cRevisa )

Local aArea			:= GetArea()
Local aEstrutAK3	:= {}
Local aEstrutTOT	:= {}

Local aChave1			:= {}
Local aChave2			:= {}

Private Acols, aRet := {}, nCols
Private cOrcame     := AK1->AK1_CODIGO
Private cDesAK1     := AK1->AK1_DESCRI
Private dIniPer     := AK1->AK1_INIPER
Private dFimPer     := AK1->AK1_FIMPER
Private nTpPeri     := AK1->AK1_TPPERI

AADD(aEstrutAK3,{'XK3_RECNO'	,'C',10,0})
AADD(aEstrutAK3,{'XK3_LDESC'	,'C',1,0})
AADD(aEstrutAK3,{'XK3_ORCAME'	,'C',Len(AK3->AK3_ORCAME),0})
AADD(aEstrutAK3,{'XK3_CO'		,'C',Len(AK3->AK3_CO),0})
AADD(aEstrutAK3,{'XK3_NIVEL'	,'C',Len(AK3->AK3_NIVEL),0})
AADD(aEstrutAK3,{'XK3_DESCRI'	,'C',Len(AK3->AK3_DESCRI),0})
AADD(aEstrutAK3,{'XK3_TIPO'	,'C',Len(AK3->AK3_TIPO),0})

If _oPCOR0501 <> Nil
	_oPCOR0501:Delete()
	_oPCOR0501:= Nil
Endif

_cAliConta := If( _cAliConta == NIL, GetNextAlias(), _cAliConta)

aChave1	:= {"XK3_RECNO"}

_oPCOR0501 := FWTemporaryTable():New(_cAliConta)
_oPCOR0501:SetFields( aEstrutAK3 )

_oPCOR0501:AddIndex("1", aChave1)	
_oPCOR0501:Create()

cArqConta		:= _oPCOR0501:GetRealName()

AADD(aEstrutTOT,{'TOT_RECNO'	,'C',10,0})
AADD(aEstrutTOT,{'TOT_SEQUEN'	,'C',3,0})
AADD(aEstrutTOT,{'TOT_LDESC'	,'C',1,0})
AADD(aEstrutTOT,{'TOT_LINHA'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_COLUNA'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_CONTEU'	,'C',100,0})
AADD(aEstrutTOT,{'TOT_NROCOL'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_TAMCOL'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_LINIMP'	,'N',10,0})

If _oPCOR0502 <> Nil
	_oPCOR0502:Delete()
	_oPCOR0502:= Nil
Endif

_cAliTotal := If( _cAliTotal == NIL, GetNextAlias(), _cAliTotal)

aChave2	:= {"TOT_RECNO","TOT_SEQUEN"}

_oPCOR0502 := FWTemporaryTable():New(_cAliTotal)
_oPCOR0502:SetFields( aEstrutTOT )

_oPCOR0502:AddIndex("1", aChave2)	
_oPCOR0502:Create()

cArqTotal 		:= _oPCOR0502:GetRealName()

AK3->( dbSetOrder(3) )

If AK3->( MsSeek(xFilial()+cOrcame+cRevisa+"001") )
	While AK3->( !Eof() .And. AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL ==;
						xFilial()+cOrcame+cRevisa+"001" )
		PCOR050_It(AK3->AK3_ORCAME,AK3->AK3_VERSAO,AK3->AK3_CO)
		AK3->(dbSkip())
	EndDo
EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Gustavo Henrique   º Data ³  05/06/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef( cPerg, cRevisa )

Local cReport	:= "PCOR050" // Nome do relatorio
Local cTitulo	:= STR0010	 // Titulo do relatorio

Local oPlanilha
Local oContaOG
Local oTotVis
 
Local oReport

If _cAliConta == NIL
	_cAliConta := GetNextAlias()
EndIf

If _cAliTotal == NIL
	_cAliTotal := GetNextAlias()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New( cReport, cTitulo, cPerg, { |oReport| If( R050Avalia( @cRevisa, cPerg ), PCOR050Prt( oReport, cRevisa ), NIL ) }, STR0020 ) // "Este relatorio ira imprimir a Planilha Orçamentária de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 1a. secao do relatorio - Totalizadores da Planilha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPlanilha := TRSection():New( oReport, STR0010, {"TMPAK1", "AK1"} )	
oPlanilha:SetNoFilter({"AK1"})

TRCell():New( oPlanilha, "AK1_CODIGO", "AK1", STR0002,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || AK1->AK1_CODIGO } )	// Codigo
TRCell():New( oPlanilha, "AK1_DESCRI", "AK1", STR0003,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || AK1->AK1_DESCRI } )	// Descricao
TRCell():New( oPlanilha, "AK1_INIPER", "AK1", STR0012,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || AK1->AK1_INIPER } )	// Dt.Inicio
TRCell():New( oPlanilha, "AK1_FIMPER", "AK1", STR0013,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || AK1->AK1_FIMPER } )	// Dt.Fim

oPlanilha:SetHeaderPage() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 2a. secao do relatorio - Conta Orcamentaria           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oContaOG := TRSection():New( oPlanilha,STR0014, {_cAliConta} )	//"C.O."

TRCell():New( oContaOG, "XK3_CO"    , _cAliConta, STR0014,/*Picture*/,30/*Tamanho*/,/*lPixel*/,{|| PcoRetCo((_cAliConta)->XK3_CO) })	// C.O.
TRCell():New( oContaOG, "XK3_NIVEL" , _cAliConta, STR0015,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Nivel
TRCell():New( oContaOG, "XK3_DESCRI", _cAliConta, STR0003,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// Descricao
TRCell():New( oContaOG, "XK3_TIPO"  , _cAliConta, STR0016,/*Picture*/,15,/*lPixel*/,{ || If( (_cAliConta)->XK3_TIPO == "2", STR0018, STR0017 ) }/*{|| code-block de impressao }*/)	// Analitica ### Sintetica

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a 3a. secao do relatorio - Classe Orcamentaria referente a conta orcamentaria da planilha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTotVis := TRSection():New( oContaOG,STR0023, {_cAliTotal} )	//"Colunas do Totalizador"

TRCell():New( oTotVis, "CELL1",,STR0024+"-1",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"
TRCell():New( oTotVis, "CELL2",,STR0024+"-2",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"
TRCell():New( oTotVis, "CELL3",,STR0024+"-3",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"
TRCell():New( oTotVis, "CELL4",,STR0024+"-4",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"
TRCell():New( oTotVis, "CELL5",,STR0024+"-5",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"
TRCell():New( oTotVis, "CELL6",,STR0024+"-6",/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Coluna"

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PcoR010Avalia³ Autor ³Paulo Carnelossi    ³ Data ³31/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do botao OK da print Dialog obj tReport ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Retorna se deve executar o relatorio                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R050Avalia( cRevisa, cPerg )

Local lOk 		:= .T.
Local nRecAK1	:= 0

Pergunte( cPerg, .F. )

AK1->( dbSetOrder(1) )

If AK1->( MSSeek(xFilial()+MV_PAR01) )
   	If !Empty(MV_PAR02)
   		AKE->( dbSetOrder(1) )
   		If ! AKE->( MSSeek(xFilial()+MV_PAR01+MV_PAR02) )
   			MsgStop(STR0015) // Revisao nao encontrada. Verifique!
   			lOk := .F.
   		Else
   			cRevisa := MV_PAR02
   		EndIf
   	Else			
		While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial()+MV_PAR01)
			cRevisa	:= AK1->AK1_VERSAO
			nRecAK1 := AK1->(Recno())
			AK1->(dbSkip())
		End
		AK1->(dbGoto(nRecAK1))
	EndIf
   	If lOk
		lOk := (PcoVerAcessoPlan(2) > 0 )
   	EndIf	
EndIf                                                          

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR050Prt  ³ Autor ³ Gustavo Henrique    ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao da planilha orcamentaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR00Prt()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR050Prt( oReport, cRevisa )

Local aArea		:= GetArea()
Local oPlanilha	:= oReport:Section(1)
Local oContaOG	:= oReport:Section(1):Section(1)
Local cArqConta	:= ""
Local cArqTotal	:= ""

Processa( { || PCOR050Proc( @cArqConta, @cArqTotal, cRevisa ) },, STR0021 )	//"Processando totalizadores da planilha..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia impressao da 1a. e 2a. secao do relatório                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:OnPageBreak( { || oPlanilha:PrintLine(), oReport:SkipLine() } )

oReport:SetMeter( (_cAliConta)->( RecCount() ) )

(_cAliConta)->( dbGoTop() )

oPlanilha:Init()

Do While ! oReport:Cancel() .And. (_cAliConta)->( ! EoF() )
                         
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf

	oContaOG:Init()
	oContaOG:PrintLine()

	R050_DetConta( oReport )

	oContaOG:Finish()
	
	(_cAliConta)->( dbSkip() )
	
EndDo

oPlanilha:Finish()

(_cAliConta)->(dbCloseArea())
If _oPCOR0501 <> Nil
	_oPCOR0501:Delete()
	_oPCOR0501:= Nil
Endif

(_cAliTotal)->(dbCloseArea())
If _oPCOR0502 <> Nil
	_oPCOR0502:Delete()
	_oPCOR0502:= Nil
Endif

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR050_It ³ Autor ³ Gustavo Henrique     ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento da planilha orcamentaria.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR050Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR050_It(cOrcame,cVersao,cCO)
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
                  
// Se o centro Orcamentario pertence ao filtro que foi selecionado  
// Se o Nivel pertence ao filtro que foi selecionado
IF	(AK3->AK3_CO    >= MV_PAR03 .AND. AK3->AK3_CO    <= MV_PAR04 ) .And.;	
	(AK3->AK3_NIVEL >= MV_PAR05 .AND. AK3->AK3_NIVEL <= MV_PAR06 )	
		// se usuario tem acesso a conta orcamentaria
	If PcoChkUser(cOrcame, cCO, AK3->AK3_PAI, 1, "ESTRUT", cVersao)
		If R050Totais(aTotList, aTotBlock)
			R050ContaOrc()	//somente grava a conta se registros totais for maior que zero
		EndIf
	EndIf	
EndIf

AK3->( dbSetOrder(2) )

If AK3->( MsSeek(xFilial()+cOrcame+cVersao+cCO) )
   	While AK3->( !Eof() .And. AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI == xFilial()+cOrcame+cVersao+cCO )
		PCOR050_It(AK3->AK3_ORCAME,AK3->AK3_VERSAO,AK3->AK3_CO)
		AK3->(dbSkip())
	EndDo
EndIf

RestArea(aAreaAK3)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R050_DetContaºAutor ³Gustavo Henrique  º Data ³  20/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Detalhe do relatorio - contas orcamentarias                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050_DetConta( oReport )

Local nTam	:= 300
Local nX	:= 0

For nX := 1 To Len(aTotList)
	If oReport:Cancel()
		Exit
	EndIf
	If aTotList[nX][1]
		If (_cAliTotal)->( dbSeek( (_cAliConta)->XK3_RECNO + StrZero(nX,3) ) )
			Do While (_cAliTotal)->( ! Eof() .And. TOT_RECNO + TOT_SEQUEN == (_cAliConta)->XK3_RECNO + StrZero(nX,3) )
				R050_TotImp( (_cAliConta)->XK3_RECNO + StrZero(nX,3), oReport, nTam )
				(_cAliTotal)->(dbSkip())
			EndDo          
		EndIf
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R050_TotImp ºAutor  ³ Gustavo Henrique º Data ³  20/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao dos totalizadores para conta orcamentaria impressaº±±
±±º          ³no detalhe do relatorio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050_TotImp( cChave, oReport, nTamOrig )

Local nX			:= 0
Local nY			:= 0
Local nTam 			:= 0
Local nLinImpr		:= 0
Local nPosCol		:= 0
Local nCtd			:= 0
Local aDadosImpr	:= {}
Local aCabDes  		:= {}
Local aTotCol		:= {}
Local oTotVis		:= oReport:Section(1):Section(1):Section(1)
Local cCell			:= ""
                          
nTam += nTamOrig

If (_cAliTotal)->TOT_LINHA == 1  //monta cabecalho dos totais

	// Monta cabecalho
	aPosCol := {}
	aCabConteudo := {}
	nCtd := 1

	Do While (_cAliTotal)->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. TOT_LINHA == 1 )//cabecalho das totalizacoes

		aAdd(aPosCol, nTam)
		aAdd(aCabConteudo, (_cAliTotal)->TOT_CONTEU)
        aAdd(aTotCol, {StrZero((_cAliTotal)->TOT_COLUNA,3), nCtd, Len(aPosCol)} )
        
		nTam += CELLTAMDATA

		If nTam > 2800
			aAdd(aCabDes, aClone(aCabConteudo))
			nTam := nTamOrig
        	aPosCol := {}
        	aCabConteudo := {}
        	nCtd++
      	EndIf   
		(_cAliTotal)->(dbSkip())
		
	EndDo

	If !Empty(aCabConteudo)
		aAdd(aCabDes, aClone(aCabConteudo))
	EndIf
    
	aDadosImpr := Array( Len(aCabDes), 0 )

	(_cAliTotal)->( dbSeek( cChave ) )  

	Do While (_cAliTotal)->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave)

		nLinImpr := (_cAliTotal)->TOT_LINHA

		Do While (_cAliTotal)->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. TOT_LINHA==nLinImpr)
			nPosCol := ASCAN( aTotCol, {|x| x[1] == StrZero((_cAliTotal)->TOT_COLUNA,3)} )
			If nPosCol > 0
				aAdd(aDadosImpr[aTotCol[nPosCol][2]],{nLinImpr,(_cAliTotal)->TOT_CONTEU, aTotCol[nPosCol][3]})
			EndIf
			(_cAliTotal)->(dbSkip())
		EndDo

	EndDo

	For nX := 1 To Len(aCabDes)

		If oReport:Cancel()
			Exit
		EndIf
                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia a impressao da secao de valores                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTotVis:Init()	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime conteudo das celulas da secao de totalizadores           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTotVis:Cell("CELL1"):Hide()
		oTotVis:Cell("CELL2"):Hide()
		oTotVis:Cell("CELL3"):Hide()
		oTotVis:Cell("CELL4"):Hide()
		oTotVis:Cell("CELL5"):Hide()
		oTotVis:Cell("CELL6"):Hide()

		oTotVis:Cell("CELL1"):HideHeader()
		oTotVis:Cell("CELL2"):HideHeader()
		oTotVis:Cell("CELL3"):HideHeader()
		oTotVis:Cell("CELL4"):HideHeader()
		oTotVis:Cell("CELL5"):HideHeader()
		oTotVis:Cell("CELL6"):HideHeader()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atribui o titulo de cada celula de secao de totalizadores        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 To Len(aCabDes[nX])
			cCell := "CELL" + AllTrim(Str(nY))
			oTotVis:Cell(cCell):cTitle := AllTrim(aCabDes[nX,nY])
		Next

		nLinImpr := aDadosImpr[nX][1][1]
		nColImpr := 1

		For nY := 2 TO Len(aDadosImpr[nX])
			If oReport:Cancel()
				Exit
			EndIf	
			If nLinImpr != aDadosImpr[nX][nY][1]

				nLinImpr := aDadosImpr[nX][nY][1]
				nColImpr := 1

				If nLinImpr > 2        

					oTotVis:PrintLine()
					
					oTotVis:Cell("CELL1"):Hide()
					oTotVis:Cell("CELL2"):Hide()
					oTotVis:Cell("CELL3"):Hide()
					oTotVis:Cell("CELL4"):Hide()
					oTotVis:Cell("CELL5"):Hide()
					oTotVis:Cell("CELL6"):Hide()

					oTotVis:Cell("CELL1"):HideHeader()
					oTotVis:Cell("CELL2"):HideHeader()
					oTotVis:Cell("CELL3"):HideHeader()
					oTotVis:Cell("CELL4"):HideHeader()
					oTotVis:Cell("CELL5"):HideHeader()
					oTotVis:Cell("CELL6"):HideHeader()
					
				EndIf	

			EndIf	                 
			
			cCell := "CELL" + AllTrim(Str(nColImpr))
			oTotVis:Cell(cCell):SetValue( AllTrim(aDadosImpr[nX][nY][2]) )
			oTotVis:Cell(cCell):Show()
			oTotVis:Cell(cCell):ShowHeader()			
       
			nColImpr++

	   	Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza impressao da secao de valores                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTotVis:PrintLine()
	    oTotVis:Finish()           
		
   	Next

EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR050It ³ Autor ³ Edson Maricate        ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao da planilha orcamentaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR050Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR050It(cOrcame,cVersao,cCO)
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
                  
// Se o centro Orcamentario pertence ao filtro que foi selecionado
IF (AK3->AK3_CO >= MV_PAR03 .AND. AK3->AK3_CO <= MV_PAR04 )
	// Se o Nivel pertence ao filtro que foi selecionado
	IF (AK3->AK3_NIVEL >= MV_PAR05 .AND. AK3->AK3_NIVEL <= MV_PAR06 )
		// se usuario tem acesso a conta orcamentaria
		If PcoChkUser(cOrcame, cCO, AK3->AK3_PAI, 1, "ESTRUT", cVersao)
			If R050Totais(aTotList, aTotBlock)
				R050ContaOrc()	//somente grava a conta se registros totais for maior que zero
			EndIf
		EndIf	
	EndIf
EndIf

dbSelectArea("AK3")
dbSetOrder(2)

If MsSeek(xFilial()+cOrcame+cVersao+cCO)
   	While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_PAI==xFilial("AK3")+cOrcame+cVersao+cCO
		PCOR050It(AK3_ORCAME,AK3_VERSAO,AK3_CO)
		dbSelectArea("AK3")
		dbSkip()
	End
EndIf

RestArea(aAreaAK3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InverteSelºAutor  ³Paulo Carnelossi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inverte Selecao do list box - totalizadores                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InverteSel(oListBox,nLin, lInverte, lMarca) 
DEFAULT nLin := oListBox:nAt

If lInverte
	oListbox:aArray[nLin,1] := ! oListbox:aArray[nLin,1]

Else
   If lMarca
	   oListbox:aArray[nLin,1] := .T.
   Else
	   oListbox:aArray[nLin,1] := .F.
   EndIf
EndIf   

aTotList[nLin,1] := oListbox:aArray[nLin,1]

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcaTodosºAutor  ³Paulo Carnelossi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca todos as opcoes do list box - totalizadores           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos(oListBox, lInverte, lMarca)
Local nX
DEFAULT lMarca := .T.

For nX := 1 TO Len(oListbox:aArray)
	InverteSel(oListBox,nX, lInverte, lMarca)
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Elem_SelecºAutor  ³Paulo Carnelossi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se ha pelo menos uma opcao do list box selecionada º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Elem_Selec(aTotList)
Local nX, lRet := .F.
For nX := 1 TO Len(aTotList)
  If aTotList[nX][1]
     lRet := .T.
     Exit
  EndIf   
Next 

If !lRet
	HELP("  ",1,"PCOR0202") //Nao selecionado nenhuma totalizacao. Verifique!
EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R050TotaisºAutor  ³Paulo Carnelossi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa os blocos de codigos contidos no array atotBlock    º±±
±±º          ³do list box selecionado (aTotBlock - array recno TABELA AKK)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050Totais(aTotList, aTotBlock)
Local nX, aResult := {}, aRetorno := {}, lRetorno := .F., lRet := .F.
For nX := 1 TO Len(aTotList)
	If aTotList[nX][1]
		AKK->(dbGoto(aTotBlock[nX][1]))
		If !Empty(AKK->AKK_BLOCK)
			aResult := PCOExecForm(AKK->AKK_BLOCK)
			If Len(aResult) > 1  // primeira elemento e o cabecalho
				lRet := R050TotOrc(aResult[1], aResult[2], aResult[3], nX)
				aAdd(aRetorno, lRet)
			EndIf
			aResult := {}
		EndIf
	EndIf
Next

For nX := 1 To Len(aRetorno)
	If aRetorno[nX]
		lRetorno := .T.
		Exit
	EndIf
Next	

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R050ContaOrcºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as contas orcamentarias em arquivo temporario para    º±±
±±º          ³posterior impressao                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050ContaOrc()				

(_cAliConta)->(dbAppend())
(_cAliConta)->XK3_RECNO	:= StrZero(AK3->(Recno()),10)
(_cAliConta)->XK3_LDESC	:= "1"
(_cAliConta)->XK3_ORCAME	:= AK3->AK3_ORCAME
(_cAliConta)->XK3_CO		:= AK3->AK3_CO
(_cAliConta)->XK3_NIVEL	:= AK3->AK3_NIVEL
(_cAliConta)->XK3_DESCRI	:= AK3->AK3_DESCRI
(_cAliConta)->XK3_TIPO		:= AK3->AK3_TIPO

Return						

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R050TotOrc  ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava totais das contas orcamentarias em arquivo temporario º±±
±±º          ³posterior impressao                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R050TotOrc(aRet, aCols, nCols, nTotBlock)
Local nX, nY, lRet := .F.
Local nVal := 0

For nX := 2 TO Len(aRet)
	For nY := 1 TO Len(aCols)   
	    If Type(aRet[nX][nY]) == "N"
			nVal += Val(aRet[nX][nY])
       ElseIf Type(SubStr(aRet[nX][nY],4)) == "N"
			nVal += Val(SubStr(aRet[nX][nY],4))			
		 EndIf	
    Next
Next

lRet := (nVal > 0)

If lRet
	For nX := 1 TO Len(aRet)
		For nY := 1 TO Len(aCols)
			(_cAliTotal)->(dbAppend())
			(_cAliTotal)->TOT_RECNO	:= StrZero(AK3->(Recno()),10)
	        (_cAliTotal)->TOT_SEQUEN   := StrZero(nTotBlock, 3)
			(_cAliTotal)->TOT_LDESC	:= "1"
			(_cAliTotal)->TOT_LINHA	:= nX
			(_cAliTotal)->TOT_COLUNA	:= nY
			(_cAliTotal)->TOT_CONTEU	:= aRet[nX][nY]
			(_cAliTotal)->TOT_NROCOL	:= nCols
			(_cAliTotal)->TOT_TAMCOL   := aCols[nY]
			(_cAliTotal)->TOT_LINIMP	:= 0
	    Next
	Next
EndIf
    
Return(lRet)						
