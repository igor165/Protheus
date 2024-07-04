#INCLUDE "ATFA480.ch"
#Include 'Protheus.CH'
#Include "ApWizard.ch"
#INCLUDE "FWBROWSE.CH"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE NOPC DA ROTINAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE VISUALIZAR 2
#DEFINE INCLUIR    	3
#DEFINE ESTORNAR   4

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA480   บAutor  ณ Alexandre Circenis บ Data ณ  11/09/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Capitaliza็ใo de Custo de Empr้stimo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ATFA480()
Local lDefTop 	:= IfDefTopCTB()// verificar se pode executar query (TOPCONN)

Private  cPerg := "ATFA480"
Private cCadastro 	:= STR0001 //"Capitaliza็ใo de Custo de Empr้stimo"
Private aRotina 	:= MenuDef()
Private aPanels		:= {}
Private oGetD 		:= Nil
Private EditWizar	:= .F.
Private oBrowse

If !lDefTop
	Help("  ",1,"ADMFILTOP",,STR0002,1,0)  //"Fun็ใo disponํvel apenas para ambientes TopConnect"
	Return
EndIf

SetKey (VK_F12, {|| Pergunte (cPerg,.T.)})

Pergunte(cPerg,.F.)

DbSelectArea( "FN1" )
FN1->( DbSetOrder( 1 ) )

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FN1' )
oBrowse:SetDescription( STR0001 ) //"Capitaliza็ใo de Custo de Empr้stimo"
oBrowse:AddLegend( "FN1_STATUS == '1'", "GREEN"  , STR0051  ) //"Efetivado"
oBrowse:AddLegend( "FN1_STATUS == '2'", "RED"    , STR0052  ) //"Estornado"

oBrowse:Activate()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Acacio Egas           ณ Data ณ29/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Private aRotina :=  {}

aAdd(aRotina , { STR0005 , "AxPesqui"  , 	1, 1} )  //"Pesquisar"###"AxPesqui"
aAdd(aRotina , { STR0006 , "Af480Wizar", 	2, 2} )  //"Visualizar"
aAdd(aRotina , { STR0007 , "Af480Wizar", 	3, 3} )  //"Incluir"
aAdd(aRotina , { STR0008 , "Af480Wizar", 	4, 4} )  //"Estornar"
aAdd(aRotina , { STR0009 , "MsDocument", 	5, 4} )  //"Conhecimento"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf480WizarบAutor  ณAlexandre Circenis  บ Data ณ  09/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard para a gera็ใo dos Ativos para a Capitalizao dos     บฑฑ
ฑฑบ          ณCustos de Emprestimo                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Af480Wizar(cAlias, nReg, nOpc)
Local oWizard 		:= Nil
Local oWPanel		:= Nil
Local nOpcRot		:= 0
Local nSaveSx8Len 	:= GetSx8Len()
Local lRet 			:= .T.
Local nX, nY
Local nEditGD := 0
Local lCTranManu := (MV_PAR01 == 2) // Custo de Transa็ใo manual (T/F)
// Variaveis do Painel 02
Local aCposP02		:= {}
Local aEnchP02      := {"FN1_PROC","FN1_DATA","FN1_DESC"}
// Variaveis do Painel 03
Local aHeaderP03 :={}
Local aColsP03   :={}
Local cExcessP03 := 'FN2_PROC' // Campos nใo acessados no Painel 03
Local oGetDP03
Local nColsP03 := 0
// Variaveis do Painel 04
Local aPBox04	 	:= {}
Local aRetPer04     := Array(7) // Respotas do Painel 04
//Variaveis do Painel 05
Local oBrowse05
Local aDados05 :={}
Local oGetDP05
Local aHeaderP05 :={}
Local aColsP05   :={}
Local cExcessP05 := 'FN3_PROC#FN3_CBASE#FN3_ITEM#FN3_TIPO#FN3_TPSALD' // Campos nใo acessados no Painel 03
Local nColsP05 := 0

// Variaveis do Painel 06
Local aHeaderP06 :={}
Local aColsP06   :={}
Local cExcessP06 := 'FN3_PROC' // Campos nใo acessados no Painel 03
Local nColsP06 := 0
Local oGetDP06
// Variaveis do Painel 07
Local aPBox07	 	:= {}
Local aRetPer07     := Array(8) // Respotas do Painel 04
//Variaveis do Painel 08
Local oBrowse08
Local aDados08 :={}
// Variaveis do Painel 09
Local aHeaderP09 :={}
Local aColsP09   :={}
Local nColsP09 := 0
Local cExcessP09 := 'FN5_PROC, FN5_CBACEM, FN5_ITECEM, FN5_TIPEMP, FN5_SLDEMP, FN5_GRPCEM' // Campos nใo acessados no Painel 05
Local oGetDP09
// Variaveis para Gravacao
Local aCols
Local lGrvOk := .T.



If nOPC <> VISUALIZAR .and. !CtbInTran( 1, .F. )
	Return
EndIf

if nOpc == ESTORNAR .and. FN1->FN1_STATUS = '2'
	Help( " ", 1, "AF480ESTPR",,  STR0004,1,0) //"Este processo jแ estแ estornado escolha outro processo para essa opera็ใo"
	Return
endif

If nOpc != INCLUIR
	If xFilial( "FN1") # FN1->FN1_FILIAL .OR. ( FN1->( Eof() ) .AND. FN1->( Bof() ) )
		Help( " ", 1, "ARQVAZIO" )
		Return
	EndIf
		//Validacao para o bloqueio do processo
	If !CtbValiDt(,dDataBase  ,,,,{"ATF001"},)
		Return 
	EndIf
else
	If lCTranManu
		If dDatabase < SuperGetMv("MV_ULTDEPR") .Or. dDatabase > ( LastDay(SuperGetMv("MV_ULTDEPR") + 1 ) )
			Help( " ", 1, "AF480INCDP2",, STR0060 ,1,0) //"Data de Opera็ใo Invแlida. Essa opera็ใo deve ser feita entre o ultimo calculo de deprecia็ใo e o m๊s posterior."
			return
		endif
	Else
		If dDatabase != SuperGetMv("MV_ULTDEPR")
			Help( " ", 1, "AF480INCDP",,  STR0010+Dtoc(SuperGetMv("MV_ULTDEPR")),1,0) //"S๓ se pode incluir um processo de Capitaliza็ใo no mesmo dia da ultima deprecia็ใo. Altere a data para "
			return
		endif
	EndIf
	//Validacao para o bloqueio do processo
	If !CtbValiDt(,dDataBase  ,,,,{"ATF001"},)
		Return 
	EndIf
EndIf

SetKey (VK_F12, NIL)

If nOpc==INCLUIR
	EDITWIZAR := .T.
	nEditGD := (GD_INSERT+GD_UPDATE+GD_DELETE)
Else
	EDITWIZAR := .F.
	nEditGD := 0
	lManual := FN1->FN1_TIPO = '2' // Para visualizar ou estornar respeitar como o calculo foi realizado
EndIf

DEFINE WIZARD oWizard TITLE STR0011; //"Assistente de Capitaliza็ใo de custo de empr้stimo"
       HEADER "" ;
       MESSAGE "";
       TEXT STR0012 + CRLF + ; //"Esse assistente tem o objetivo de realizar o calculo do custo de empreดstimo e a sua"
       		STR0013 + CRLF +;	 //"capitaliza็ใo nos ativos dem andamento cadastrados no ambiente Ativo Fixo. Informe "
       		STR0014 ; //"todos os parโmetros corretamente para a conclusใo do processo."
       NEXT {||.T.} ;
       FINISH {|| .T. } ;
       PANEL

	//Segunda Pagina
   CREATE PANEL oWizard ;
          HEADER STR0015 ; 	 //"Informa็๕es do Processamento"
          MESSAGE STR0016; //"Informa็oes sobre o calculo."
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .T. } ;
          PANEL

	RegToMemory("FN1", If(nOpc==INCLUIR,.T.,.F.),,, )
	If nOpc==INCLUIR
		M->FN1_PROC := GetSx8Num("FN1","FN1_PROC")
		M->FN1_DATA := dDatabase
		aCposP02    := {"FN1_DESC"}
	EndIf

	oMsmSNI	:= MsMGet():New("FN1",FN1->(RECNO()),nOpc,,,,aEnchP02,,aCposP02,,,,,oWizard:GetPanel(2),,,.T.)
	oMsmSNI:oBox:Align := CONTROL_ALIGN_ALLCLIENT


	//Terceira Pagina
   CREATE PANEL oWizard ;
          HEADER STR0017 ; 	//"Informe Parโmetros Iniciais" ; //"Informa็๕e de Contrato e Juros"
          MESSAGE STR0018+CRLF+STR0019; 	//"Determine o filtro para sele็ใo."  //"Informa็๕es sobre os contratos e juros da competencia que serใo usados "###"para compor o custo dos emprestimos"
          BACK {|| .T. } ;
	          NEXT {|| if (lCTranManu , oWizard:nPanel := 4,), .T. } ;
          FINISH {|| .T. } ;
          PANEL

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("FN2"))
	While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == "FN2"
		If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessP03)) .And. (X3USO(SX3->X3_USADO))
			aAdd( aHeaderP03, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO	,;			// 02 - Campo
			SX3->X3_Picture	,;			// 03 - Picture
			SX3->X3_TAMANHO	,;			// 04 - Tamanho
			SX3->X3_DECIMAL	,;			// 05 - Decimal
			SX3->X3_Valid  	,;			// 06 - Valid
			SX3->X3_USADO  	,;			// 07 - Usado
			SX3->X3_TIPO   	,;			// 08 - Tipo
			SX3->X3_F3		,;			// 09 - F3
			SX3->X3_CONTEXT ,;       	// 10 - Contexto
			SX3->X3_CBOX	,; 	  		// 11 - ComboBox
			SX3->X3_RELACAO , } )  		// 12 - Relacao
		Endif
		SX3->(dbSkip())
	End

	dbSelectArea("FN2")

	IF nOpc == INCLUIR
		aAdd(aColsP03,Array(Len(aHeaderP03)+1))
		For nX := 1 To Len(aHeaderP03)
			if aHeaderP03[nX][2] = "FN2_LINHA"
				aColsP03[1][nX] := StrZero(1,aHeaderP03[nX][4],0)
			else
				aColsP03[1][nX] := CriaVar(aHeaderP03[nX][2])
			endif
		Next nX
		aColsP03[1][Len(aHeaderP03)+1] := .F.
	Else
		FN2->(dbSetOrder(1))
		FN2->(dbSeek(xFilial("FN2")+M->FN1_PROC))
		While FN2->(!Eof()) .And. ALLTRIM(FN2->(FN2_FILIAL+FN2_PROC)) = ALLTRIM(xFilial("FN2")+M->FN1_PROC)
			aAdd(aColsP03,Array(Len(aHeaderP03)+1))
			nColsP03++
			For nX := 1 To Len(aHeaderP03)
				If ( aHeaderP03[nX][10] != "V")
					aColsP03[nColsP03][nX] := FN2->(FieldGet(FieldPos(aHeaderP03[nX][2])))
				Else
				aColsP03[nColsP03][nX] := CriaVar(aHeaderP03[nX][2],.T.)
				Endif
			Next nX
			aColsP03[nColsP03][Len(aHeaderP03)+1] := .F.
			FN2->(dbSkip())
		End
	EndIf

	oGetDP03 := MsNewGetDados():New(005,005,090,300,nEditGD,,,"+FN2_LINHA",,,999,,,,oWizard:GetPanel(3),aHeaderP03,aColsP03)
 	oGetDP03:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	if lCTranManu  // Custo da Transa็ใo Serแ informado manualmente

		//Quarta Pagina
		CREATE PANEL oWizard ;
				HEADER STR0020; 	//"Processamento" ; //"Filtro de Custo de Transa็ใo"
		        MESSAGE STR0021; 	//"Informe o que deseja fazer..." //"Dados usados para filtrar os Bens de custeio dos Emprestimos."
		        BACK {|| .T. } ;
		        NEXT {|| .T.} ;
		        FINISH {|| , .T.} ;
		        PANEL

		//Quinta Pagina
		CREATE PANEL oWizard ;
				HEADER STR0030; 	//"Processamento" ; //"Custo de Transa็ใo"
		        MESSAGE STR0031; 	//"Informe o que deseja fazer..." //"Bens de Custeio de emprestimo usados para calculo do Custeio"
		        BACK {||  oWizard:nPanel := 4, .T. } ;
		        NEXT {|| .T. } ;
		        FINISH {|| .T.} ;
		        PANEL

		SX3->(dbSetOrder(1))
		SX3->(dbSeek("FN3"))
		While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == "FN3"
			If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessP05)) .And. (X3USO(SX3->X3_USADO))
				aAdd( aHeaderP05, { AlLTrim( X3Titulo() ),; // 01 - Titulo
				SX3->X3_CAMPO	,;			// 02 - Campo
				SX3->X3_Picture	,;			// 03 - Picture
				SX3->X3_TAMANHO	,;			// 04 - Tamanho
				SX3->X3_DECIMAL	,;			// 05 - Decimal
				SX3->X3_Valid  	,;			// 06 - Valid
				SX3->X3_USADO  	,;			// 07 - Usado
				SX3->X3_TIPO   	,;			// 08 - Tipo
				SX3->X3_F3		,;			// 09 - F3
				SX3->X3_CONTEXT ,;       	// 10 - Contexto
				SX3->X3_CBOX	,; 	  		// 11 - ComboBox
				SX3->X3_RELACAO , } )  		// 12 - Relacao
			Endif
			SX3->(dbSkip())
		End

		dbSelectArea("FN3")

		IF nOpc == INCLUIR
			aAdd(aColsP05,Array(Len(aHeaderP05)+1))
			For nX := 1 To Len(aHeaderP05)
				if aHeaderP05[nX][2] = "FN3_LINHA"
					aColsP05[1][nX] := StrZero(1,aHeaderP05[nX][4],0)
				else
					aColsP05[1][nX] := CriaVar(aHeaderP05[nX][2])
				endif
			Next nX
			aColsP05[1][Len(aHeaderP05)+1] := .F.
		Else
			FN3->(dbSetOrder(1))
			FN3->(dbSeek(xFilial("FN3")+M->FN1_PROC))
			While FN3->(!Eof()) .And. ALLTRIM(FN3->(FN3_FILIAL+FN3_PROC)) = ALLTRIM(xFilial("FN3")+M->FN1_PROC)
				aAdd(aColsP05,Array(Len(aHeaderP05)+1))
				nColsP05++
				For nX := 1 To Len(aHeaderP05)
					If ( aHeaderP05[nX][10] != "V")
						aColsP05[nColsP05][nX] := FN3->(FieldGet(FieldPos(aHeaderP05[nX][2])))
					Else
					aColsP05[nColsP05][nX] := CriaVar(aHeaderP05[nX][2],.T.)
					Endif
				Next nX
				aColsP05[nColsP05][Len(aHeaderP05)+1] := .F.
				FN3->(dbSkip())
			End
		EndIf

 	 	oGetDP05 := MsNewGetDados():New(005,005,090,300,nEditGD,,,"+FN3_LINHA",,,999,,,,oWizard:GetPanel(5),aHeaderP05,aColsP05)
 		oGetDP05:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	else // Custo da Transa็ใo serแ automatico
		//Quarta Pagina
		CREATE PANEL oWizard ;
				HEADER STR0020; 	//"Processamento" ; //"Filtro de Custo de Transa็ใo"
		        MESSAGE STR0021; 	//"Informe o que deseja fazer..." //"Dados usados para filtrar os Bens de custeio dos Emprestimos."
		        BACK {|| .T. } ;
		        NEXT {|| If(nOpc=INCLUIR,aCstTrans(aRetPer04,oBrowse05, aDados05),.T.)} ;
		        FINISH {|| , .T.} ;
		        PANEL
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncializa็ใo dos array de resposta do paramboxณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aRetPer04[01] 	:= Space( TamSx3('N1_CBASE')[1] )
		aRetPer04[02] 	:= Space( TamSx3('N1_CBASE')[1] )
		aRetPer04[03] 	:= Space( TamSx3('N1_ITEM')[1] )
		aRetPer04[04] 	:= Space( TamSx3('N1_ITEM')[1] )
		aRetPer04[05] 	:= Space( TamSx3('N1_GRUPO')[1] )
		aRetPer04[06] 	:= Space( TamSx3('N1_GRUPO')[1] )
		aRetPer04[07] 	:= Space( TamSx3('N3_TPSALDO')[1] )


		aAdd(aPBox04,{ 1, STR0022, Space(TamSx3('N1_CBASE')[1])  , X3Picture('N1_CBASE')   ,""   ,"SN1","EDITWIZAR",  50,  .F.})  //"C๓digo base de"
		aAdd(aPBox04,{ 1, STR0023, Space(TamSx3('N1_CBASE')[1])  , X3Picture('N1_CBASE')   ,""   ,"SN1","EDITWIZAR",  50,  .F.})  //"C๓digo base at้"
		aAdd(aPBox04,{ 1, STR0024, Space(TamSx3('N1_ITEM')[1])   , X3Picture('N1_ITEM')    ,""   ,""   ,"EDITWIZAR",  50,  .F.}) 	 //"Item de"
		aAdd(aPBox04,{ 1, STR0025, Space(TamSx3('N1_ITEM')[1])   , X3Picture('N1_ITEM')    ,""   ,""   ,"EDITWIZAR",  50,  .F.})  //"Item at้"
		aAdd(aPBox04,{ 1, STR0026, Space(TamSx3('N1_GRUPO')[1])  , "@S50"                  ,""   ,"SNG","EDITWIZAR",  50,  .F.})  //"Grupo de"
		aAdd(aPBox04,{ 1, STR0027, Space(TamSx3('N1_GRUPO')[1])  , "@S50"                  ,""   ,"SNG","EDITWIZAR",  50,  .F.})  //"Grupo at้"
		aAdd(aPBox04,{ 1, STR0028, Space(TamSx3('N3_TPSALDO')[1]), X3Picture('N3_TPSALDO') ,"VldTpSald( M->MV_PAR07 )"   ,"SL" ,"EDITWIZAR",  50,  .F.})  //"Tipo de saldo"

		ParamBox(aPBox04,STR0029 , @aRetPer04 ,,,,,,oWizard:GetPanel(4)) //"Filtro Custo Transa็ใo"


		//Quinta Pagina
		CREATE PANEL oWizard ;
				HEADER STR0030; 	//"Processamento" ; //"Custo de Transa็ใo"
		        MESSAGE STR0031; 	//"Informe o que deseja fazer..." //"Bens de Custeio de emprestimo usados para calculo do Custeio"
		        BACK {|| .T. } ;
		        NEXT {|| .T. } ;
		        FINISH {|| .T.} ;
		        PANEL

	   	dbSelectArea("FN3")
		if !nOpc = INCLUIR
			FN3->(dbSetOrder(1))
			FN3->(dbSeek(xFilial("FN3")+M->FN1_PROC))
			While FN3->(!Eof()) .And. ALLTRIM(FN3->(FN3_FILIAL+FN3_PROC)) = ALLTRIM(xFilial("FN3")+M->FN1_PROC)
				Aadd( aDados05 ,FN3->({.t., FN3_LINHA, FN3_CBASE, FN3_ITEM, FN3_TIPO, FN3_TPSALD,Posicione("SN1",1,xFilial("SN1")+FN3_CBASE+FN3_ITEM,"N1_DESCRIC"), FN3_AMORT}))
				FN3->(dbSkip())
			End
		endif
		//-------------------------------------------------------------------
		// Define o Browse
		//---------------------------------------------------------------------------
		DEFINE FWBROWSE oBrowse05 DATA ARRAY ARRAY aDados05 NO CONFIG  NO REPORT  OF oWizard:GetPanel(5)

		//-------------------------------------------------------------------
		// Adiciona as colunas do Browse
		//-------------------------------------------------------------------
		ADD MARKCOLUMN oColumn DATA {|| Iif(aDados05[oBrowse05:nAt,1], 'LBOK', 'LBNO')};
			DOUBLECLICK {|| If(nOPC == INCLUIR,( aDados05[oBrowse05:nAt,1] := !aDados05[oBrowse05:nAt,1], oBrowse05:Refresh()),NIL)};
			HEADERCLICK {|| If(nOpc == INCLUIR,(AEval(aDados05,{|x| x[1] := !x[1]}),oBrowse05:Refresh(.T.)),Nil)}	OF oBrowse05
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),2] } TITLE STR0034 SIZE 10 HEADERCLICK {||.F.} OF oBrowse05 //"Linha"
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),3] } TITLE STR0035 SIZE 10 HEADERCLICK {||.F.} OF oBrowse05 //"C๓digo"
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),4] } TITLE STR0036 SIZE 04 HEADERCLICK {||.F.} OF oBrowse05 //"Item"
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),5] } TITLE STR0037 SIZE 04 HEADERCLICK {||.F.} OF oBrowse05 //"Tipo"
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),6] } TITLE STR0038 SIZE 04 HEADERCLICK {||.F.} OF oBrowse05 //"Tipo Saldo"
		ADD COLUMN oColumn DATA { || aDados05[oBrowse05:At(),7] } TITLE STR0046 SIZE 20 HEADERCLICK {||.F.} OF oBrowse05 //"Descri็ใo"
		ADD COLUMN oColumn DATA { || Transform( aDados05[oBrowse05:At(),8], "@E 999,999,999,999.99") } TITLE STR0039 SIZE 10 HEADERCLICK {||.F.} OF oBrowse05 //"Valor Amortiza็ใo"
		oBrowse05:ACOLUMNS[7]:NALIGN := 2

		//-------------------------------------------------------------------
		// Ativa็ใo do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWBROWSE oBrowse05

	 endif
	//Sexta Pagina
	CREATE PANEL oWizard ;
			HEADER STR0040;  //"Informa็๕es de Rendimento"
	        MESSAGE STR0041; 	//"Informe o que deseja fazer..." //"Valores dos Rendimentos dos Saldo dos emprestiamso ainda nใo utilizados."
	        BACK {|| .T. } ;
	        NEXT {|| .T. } ;
	        FINISH {|| .T.} ;
	        PANEL

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("FN4"))
	While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == "FN4"
		If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessP03)) .And. (X3USO(SX3->X3_USADO))
			aAdd( aHeaderP06, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO	,;			// 02 - Campo
			SX3->X3_Picture	,;			// 03 - Picture
			SX3->X3_TAMANHO	,;			// 04 - Tamanho
			SX3->X3_DECIMAL	,;			// 05 - Decimal
			SX3->X3_Valid  	,;			// 06 - Valid
			SX3->X3_USADO  	,;			// 07 - Usado
			SX3->X3_TIPO   	,;			// 08 - Tipo
			SX3->X3_F3		,;			// 09 - F3
			SX3->X3_CONTEXT ,;       	// 10 - Contexto
			SX3->X3_CBOX	,; 	  		// 11 - ComboBox
			SX3->X3_RELACAO , } )  		// 12 - Relacao
		Endif
		SX3->(dbSkip())
	End

	dbSelectArea("FN4")

	IF nOpc == INCLUIR
		aAdd(aColsP06,Array(Len(aHeaderP06)+1))
		For nX := 1 To Len(aHeaderP06)
			if aHeaderP06[nX][2] = "FN4_LINHA"
				aColsP06[1][nX] := StrZero(1,aHeaderP06[nX][4],0)
			else
				aColsP06[1][nX] := CriaVar(aHeaderP06[nX][2])
			endif
		Next nX
		aColsP06[1][Len(aHeaderP06)+1] := .F.
	Else
		FN4->(dbSetOrder(1))
		FN4->(dbSeek(xFilial("FN4")+M->FN1_PROC))
		While FN4->(!Eof()) .And. ALLTRIM(FN4->(FN4_FILIAL+FN4_PROC)) = ALLTRIM(xFilial("FN4")+M->FN1_PROC)
			aAdd(aColsP06,Array(Len(aHeaderP06)+1))
			nColsP06 ++
			For nX := 1 To Len(aHeaderP06)
				If ( aHeaderP06[nX][10] != "V")
					aColsP06[nColsP06][nX] := FN4->(FieldGet(FieldPos(aHeaderP06[nX][2])))
				Else
					aColsP06[nColsP06][nX] := CriaVar(aHeaderP06[nX][2],.T.)
				Endif
			Next nX
			aColsP06[nColsP06][Len(aHeaderP06)+1] := .F.
			FN4->(dbSkip())
		End
	EndIf

	oGetDP06 := MsNewGetDados():New(005,005,090,300,nEditGD,,,"+FN4_LINHA",,,999,,,,oWizard:GetPanel(6),aHeaderP06,aColsP06)
 	oGetDP06:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//Setima Pagina
	CREATE PANEL oWizard ;
			HEADER STR0042; //"Filtro de Ativos em Andamento"
	        MESSAGE STR0042; 	//"Informe o que deseja fazer..." //"Filtro de Ativos em Andamento"
	        BACK {|| .T. } ;
	        NEXT {||  if(nOpc=INCLUIR,aAtvAnda(aRetPer07, oBrowse08, aDados08),.T.) } ;
	        FINISH {|| .T.} ;
	        PANEL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIncializa็ใo dos array de resposta do paramboxณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aRetPer07[01] 	:= Space( TamSx3('N1_CBASE')[1] )
	aRetPer07[02] 	:= Space( TamSx3('N1_CBASE')[1] )
	aRetPer07[03] 	:= Space( TamSx3('N1_ITEM')[1] )
	aRetPer07[04] 	:= Space( TamSx3('N1_ITEM')[1] )
	aRetPer07[05] 	:= Space( TamSx3('N1_GRUPO')[1] )
	aRetPer07[06] 	:= Space( TamSx3('N1_GRUPO')[1] )
	aRetPer07[07] 	:= Space( TamSx3('N3_TPSALDO')[1] )
	aRetPer07[08] 	:= Space( TamSx3('N1_GRUPO')[1] )


	aAdd(aPBox07,{ 1, STR0022, Space(TamSx3('N1_CBASE')[1])  , X3Picture('N1_CBASE')  ,""   ,"SN1","EDITWIZAR",  50,  .F.})  //"C๓digo base de"
	aAdd(aPBox07,{ 1, STR0023, Space(TamSx3('N1_CBASE')[1])  , X3Picture('N1_CBASE')  ,""   ,"SN1","EDITWIZAR",  50,  .F.})  //"C๓digo base at้"
	aAdd(aPBox07,{ 1, STR0024, Space(TamSx3('N1_ITEM')[1])   , X3Picture('N1_ITEM')   ,""   ,""   ,"EDITWIZAR",  50,  .F.}) 	 //"Item de"
	aAdd(aPBox07,{ 1, STR0025, Space(TamSx3('N1_ITEM')[1])   , X3Picture('N1_ITEM')   ,""   ,""   ,"EDITWIZAR",  50,  .F.})  //"Item at้"
	aAdd(aPBox07,{ 1, STR0026, Space(TamSx3('N1_GRUPO')[1])  , "@S50"                 ,""   ,"SNG","EDITWIZAR",  50,  .F.})  //"Grupo de"
	aAdd(aPBox07,{ 1, STR0027, Space(TamSx3('N1_GRUPO')[1])  , "@S50"                 ,""   ,"SNG","EDITWIZAR",  50,  .F.})  //"Grupo at้"
	aAdd(aPBox07,{ 1, STR0028, Space(TamSx3('N3_TPSALDO')[1]), X3Picture('N3_TPSALDO'),"VldTpSald( M->MV_PAR07 )"   ,"SL" ,"EDITWIZAR",  50,  .F.})  //"Tipo de saldo"
	aAdd(aPBox07,{ 1, STR0043, Space(TamSx3('N1_GRUPO')[1])  , "@S50"                 ,"AF480VLGRP()"   ,"SNG","EDITWIZAR",  50,  .F.})  //"Grupo de Custo Emprestimo"

	ParamBox(aPBox07, STR0043 , @aRetPer07 ,,,,,,oWizard:GetPanel(7))

	//Oitava Pagina
	CREATE PANEL oWizard ;
			HEADER STR0044;  //"Ativos em Andamento"
	        MESSAGE STR0045; 	//"Informe o que deseja fazer..." //"Bens em andamento e aptos a receberem os custos de emprestimos."
	        BACK {|| .T. } ;
	        NEXT {||If(nOpc=INCLUIR, (GeraCapi(oGetDP03, If(lCTranManu,oGetDP05,aDados05),oGetDP06,aDados08, oGetDP09:aHeader, oGetDP09:Acols, lCTranManu),oGetDP09:Refresh()),),.T. } ;
	        FINISH {|| .T.} ;
	        PANEL

  	dbSelectArea("FN5")
	if !nOpc = INCLUIR
		FN5->(dbSetOrder(1))
		FN5->(dbSeek(xFilial("FN5")+M->FN1_PROC))
		While FN5->(!Eof()) .And. ALLTRIM(FN5->(FN5_FILIAL+FN5_PROC)) = ALLTRIM(xFilial("FN5")+M->FN1_PROC)
			Aadd( aDados08 ,FN5->({.t., FN5_CBAORI,FN5_ITEORI, FN5_TIPORI, FN5_SLDORI,Posicione("SN1",1,xFilial("SN1")+FN5_CBAORI+FN5_ITEORI,"N1_DESCRIC"), FN5_VLRORI}))
			FN5->(dbSkip())
		End
	endif

	//---------------------------------------------------------------------------
	// Define o Browse
	//---------------------------------------------------------------------------
	DEFINE FWBROWSE oBrowse08 DATA ARRAY ARRAY aDados08 NO CONFIG  NO REPORT  OF oWizard:GetPanel(8)

		//-------------------------------------------------------------------
		// Adiciona as colunas do Browse
		//-------------------------------------------------------------------
		ADD MARKCOLUMN oColumn DATA {|| If(aDados08[oBrowse08:nAt,1], 'LBOK', 'LBNO')};
			DOUBLECLICK {|| If(nOpc == INCLUIR,(aDados08[oBrowse08:nAt,1] := !aDados08[oBrowse08:nAt,1]),Nil)};
			HEADERCLICK {|| If(nOpc == INCLUIR,(AEval(aDados08,{|x| x[1] := !x[1]}),oBrowse08:Refresh(.T.)),Nil)}	OF oBrowse08
		ADD COLUMN oColumn DATA { || aDados08[oBrowse08:At(),2] } TITLE STR0035 SIZE 10 HEADERCLICK {||.F.} OF oBrowse08 //"C๓digo"
		ADD COLUMN oColumn DATA { || aDados08[oBrowse08:At(),3] } TITLE STR0036 SIZE 04 HEADERCLICK {||.F.} OF oBrowse08 //"Item"
		ADD COLUMN oColumn DATA { || aDados08[oBrowse08:At(),4] } TITLE STR0037 SIZE 04 HEADERCLICK {||.F.} OF oBrowse08 //"Tipo"
		ADD COLUMN oColumn DATA { || aDados08[oBrowse08:At(),5] } TITLE STR0038 SIZE 04 HEADERCLICK {||.F.} OF oBrowse08 //"Tipo Saldo"
		ADD COLUMN oColumn DATA { || aDados08[oBrowse08:At(),6] } TITLE STR0046 SIZE 20 HEADERCLICK {||.F.} OF oBrowse08 //"Descri็ใo"
		ADD COLUMN oColumn DATA { || Transform( aDados08[oBrowse08:At(),7], "@E 999,999,999,999.99") } TITLE STR0047 SIZE 10 HEADERCLICK {||.F.} OF oBrowse08 //"Valor Aquisi็ใo"
		oBrowse08:ACOLUMNS[7]:NALIGN := 2

	//----------------------------------------------------------------
	// Ativa็ใo do Browse
	//-------------------------------------------------------------------
	ACTIVATE FWBROWSE oBrowse08
	//--

	//Nona Pagina
	CREATE PANEL oWizard ;
			HEADER STR0048;  //"Resumo do Processamento"
	        MESSAGE STR0048; 	//"Informe o que deseja fazer..." //"Resumo do Processamento"
	        BACK {|| .T. } ;
	        NEXT {||nOpcRot :=1, .T. } ;
	        FINISH {||nOpcRot :=1, .T.} ;
	        PANEL


	SX3->(dbSetOrder(1))
	SX3->(dbSeek("FN5"))
	While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == "FN5"
		If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessP09)) .And. (X3USO(SX3->X3_USADO))
			aAdd( aHeaderP09, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO	,;			// 02 - Campo
			SX3->X3_Picture	,;			// 03 - Picture
			SX3->X3_TAMANHO	,;			// 04 - Tamanho
			SX3->X3_DECIMAL	,;			// 05 - Decimal
			SX3->X3_Valid  	,;			// 06 - Valid
			SX3->X3_USADO  	,;			// 07 - Usado
			SX3->X3_TIPO   	,;			// 08 - Tipo
			SX3->X3_F3		,;			// 09 - F3
			SX3->X3_CONTEXT ,;       	// 10 - Contexto
			SX3->X3_CBOX	,; 	  		// 11 - ComboBox
			SX3->X3_RELACAO , } )  		// 12 - Relacao
		Endif
		SX3->(dbSkip())
	End
	dbSelectArea("FN5")
	IF nOpc == INCLUIR
		aAdd(aColsP09,Array(Len(aHeaderP09)+1))
		For nX := 1 To Len(aHeaderP09)
			if aHeaderP09[nX][2] = "FN5_LINHA"
				aColsP09[1][nX] := StrZero(1,aHeaderP09[nX][4],0)
			else
				aColsP09[1][nX] := CriaVar(aHeaderP09[nX][2])
			endif
		Next nX
		aColsP09[1][Len(aHeaderP09)+1] := .F.
	Else
		FN5->(dbSetOrder(1))
		FN5->(dbSeek(xFilial("FN5")+M->FN1_PROC))
		While FN5->(!Eof()) .And. ALLTRIM(FN5->(FN5_FILIAL+FN5_PROC)) = ALLTRIM(xFilial("FN5")+M->FN1_PROC)
			aAdd(aColsP09,Array(Len(aHeaderP09)+1))
			nColsP09 ++
			For nX := 1 To Len(aHeaderP09)
				If ( aHeaderP09[nX][10] != "V")
					aColsP09[nColsP09][nX] := FN5->(FieldGet(FieldPos(aHeaderP09[nX][2])))
				Else
					aColsP09[nColsP09][nX] := CriaVar(aHeaderP09[nX][2],.T.)
				Endif
			Next nX
			aColsP09[nColsP09][Len(aHeaderP09)+1] := .F.
			FN5->(dbSkip())
		End
	EndIf

	oGetDP09 := MsNewGetDados():New(005,005,090,300,nEditGD,,,"",,,999,,,,oWizard:GetPanel(9),aHeaderP09,aColsP09)
 	oGetDP09:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oWizard:RefreshButtons()

ACTIVATE WIZARD oWizard CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณRetorna a numera็ใo caso o usuแrio nใo confirmeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If (nOpcRot == 0 .or. !lRet ).or. Len(oGetDP09:aCols) = 0
	While GetSx8Len() > nSaveSx8Len
		RollBackSx8()
	End
ElseIf nOpc == INCLUIR
	MsgRun( STR0058,, {||	lGrvOk := AF480CATF(oGetDP09,ARETPER07[8],if (lCTranManu,oGetDP05, aDados05),oGetDP06,oGetDP03,nSaveSx8Len,lCTranManu) } ) //"Processando custo de Empr้stimo"
ElseIf nOpc == ESTORNAR
	MsgRun( STR0059,, {||	lGrvOk := AF480EST(nReg) } ) // "Processando Estorno"
EndIf

if !lGrvOk // Ocorreu erro na grava็ใo visar ao usuario
		Help( " ", 1, "AF480ERGR",, STR0057,1,0) //"Ocorreu um erro na Grava็ใo dos Ativos. Analise o cadastro de Ativos"
endif

SetKey (VK_F12, {|| Pergunte (cPerg,.T.)})
Pergunte(cPerg,.F.)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA480   บAutor  ณAlexandre Circenis  บ Data ณ  09/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna um array com os bens que tenham custos de Transacao บฑฑ
ฑฑบ          ณno Periodo                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aCstTrans(aParam, oBrowse05, aDados05)
Local cCodDe	:= aParam[1]
Local cCodAte	:= aParam[2]
Local cItemDe	:= aParam[3]
Local cItemAte	:= aParam[4]
Local cGrupoDe	:= aParam[5]
Local cGrupoAte	:= aParam[6]
Local cTpSaldo	:= aParam[7]
Local aRet		:= {}
Local aAux		:= {}
Local nX		:= 0
Local lRet		:= .T.
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local aTamSN4	:= TamSx3('N4_VLROC1')
Local aCampos	:={}
Local aCposSel	:= {"N1_CBASE", "N1_ITEM", "N1_DESCRIC", "N3_TPSALDO", "N4_TIPO" , "N4_VLROC1"}
Local cLinha	:= StrZero(1,TamSx3('FN3_LINHA')[1] ,0)

Local cTypes10	:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 29/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10	:= {}
Local nTypes10	:= 0
DbSelectArea("SN1")
DbSelectArea("SN4")

cQuery := "SELECT N1_CBASE, N1_ITEM, N4_TIPO, N3_TPSALDO, N1_DESCRIC, Sum(N4_VLROC1) VALOR FROM "+RetSqlName("SN1")+ " SN1"
cQuery += " INNER JOIN "+RetSqlName("SN3")+" SN3 ON N3_FILIAL = '"+xFilial("SN3")+"' AND N1_CBASE = N3_CBASE and N1_ITEM = N3_ITEM"
cQuery += " INNER JOIN "+RetSqlName("SN4")+" SN4 ON N4_FILIAL = '"+xFilial("SN4")+"' AND N4_CBASE = N1_CBASE AND N4_ITEM = N1_ITEM AND N4_SEQREAV = N3_SEQREAV AND N4_TPSALDO = N3_TPSALDO"
cQuery += " WHERE N1_FILIAL = '"+xFilial("SN1")+"'"
cQuery += " AND N1_CBASE BETWEEN '"+cCodDe+"' AND '"+cCodAte+"'"
cQuery += " AND N1_ITEM BETWEEN '"+cItemDe+"' AND '"+cItemAte+"'"
cQuery += " AND N1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"'"
cQuery += " AND N1_STATUS ='1'"

If SN1->(FieldPos("N1_MSBLQL")) > 0
	cQuery += " AND N1_MSBLQL <> '1' "
EndIf

cQuery += " AND N3_BAIXA = '0' "
If !lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cQuery += " AND N3_TIPO = '10' "
Else
	aTypes10 := Separa(cTypes10, '|', .f.)
	
	If len(aTypes10) = 0
		cQuery += " AND N3_TIPO = '10' "
	Else
		cQuery += "	AND N3_TIPO IN ('10'"
		
		For nTypes10 := 1 to len(aTypes10)
			cQuery += ",'" + aTypes10[nTypes10] + "' "
		Next nTypes10
		
		cQuery += ") "
	Endif
Endif
cQuery += " AND N1_PATRIM = 'T' "
cQuery += " AND N4_DATA >= '"+Dtos(FirstDay(dDataBase))+"'"
cQuery += " AND N4_DATA <= '"+Dtos(LastDay(dDataBase)) +"'"
If cPaisLoc=="RUS"
	cQuery += " AND N4_OCORR = '06' "
Else
	cQuery += " AND N4_OCORR = '20' "
EndIf
cQuery += " AND N4_TIPOCNT = CASE WHEN ("
cQuery += " Exists (select N4_TIPOCNT from "+RetSqlName("SN4")+ " SN4AUX"
cQuery += " WHERE SN4AUX.N4_FILIAL = '"+xFilial("SN4")+"'"
cQuery += " AND SN4AUX.N4_CBASE = SN1.N1_CBASE"
cQuery += " AND SN4AUX.N4_ITEM = N1_ITEM"
cQuery += " AND SN4AUX.N4_SEQREAV = SN3.N3_SEQREAV"
cQuery += " AND SN4AUX.N4_TPSALDO = SN3.N3_TPSALDO"
cQuery += " AND SN4AUX.N4_TIPOCNT = '3'"
cQuery += " AND N4_DATA >= '"+Dtos(FirstDay(dDataBase))+"'"
cQuery += " AND N4_DATA <= '"+Dtos(LastDay(dDataBase)) +"'"
If cPaisLoc=='RUS'
	cQuery += " AND N4_OCORR = '06') ) THEN '3'"
Else
	cQuery += " AND N4_OCORR = '20') ) THEN '3'"
EndIf
cQuery += "ELSE '4' END"
cQuery += " AND N3_TPSALDO = '"+cTpSaldo+"'"
cquery += " AND SN1.D_E_L_E_T_ = ' ' "
cquery += " AND SN3.D_E_L_E_T_ = ' ' "
cquery += " AND SN4.D_E_L_E_T_ = ' ' "
cquery += " GROUP BY N1_CBASE, N1_ITEM, N4_TIPO, N3_TPSALDO, N1_DESCRIC "
cquery += " ORDER BY N1_CBASE, N1_ITEM, N4_TIPO, N3_TPSALDO, N1_DESCRIC "


cQuery := ChangeQuery(cQuery)

If Select(cAliasQry) > 0
	dbSelectArea(cAliasQry)
	dbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TcSetField(cAliasQry,"VALOR","N",aTamSN4[1],aTamSN4[2])

dbSelectArea(cAliasQry)
dbGotop()

dbEval( {|| aAdd(aRet, (cAliasQry)->({ .T.,cLinha, N1_CBASE, N1_ITEM, N4_TIPO, N3_TPSALDO, N1_DESCRIC, VALOR})), cLinha:=Soma1(cLinha)})


aDados05:= {}
aDados05 := AClone(aRet)
oBrowse05:SetArray(aDados05)
oBrowse05:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaAtvAnda  บAutor  ณAlexandre Circenis  บ Data ณ  09/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Getdados preechida com os dados dos ativos aptos  บฑฑ
ฑฑบ          ณa receberem os de custeio                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aAtvAnda(aParam, oBrowse08, aDados08)
Local cCodDe    := aParam[1]
Local cCodAte   := aParam[2]
Local cItemDe   := aParam[3]
Local cItemAte  := aParam[4]
Local cGrupoDe  := aParam[5]
Local cGrupoAte := aParam[6]
Local cTpSaldo  := aParam[7]
Local aRet := {}
Local aAux := {}
Local nX
Local lRet := .T.
Local cQuery
Local cAliasQry
Local aTamSN1 := TamSx3('N3_VORIG1')

cAliasQry 	:= GetNextAlias()

cQuery := "SELECT N1_CBASE, N1_ITEM, N3_TIPO, N3_TPSALDO, N1_DESCRIC, N3_VORIG1 FROM "+RetSqlName("SN1")+ "  SN1" + CRLF
cQuery += " INNER JOIN "+RetSqlName("SN3")+"  SN3  ON N3_FILIAL = '"+xFilial("SN3")+"' AND N1_CBASE = N3_CBASE and N1_ITEM = N3_ITEM"+ CRLF
cQuery += " WHERE N1_FILIAL = '"+xFilial("SN1")+"'"+ CRLF
cQuery += " AND N1_CBASE BETWEEN '"+cCodDe+"' AND '"+cCodAte+"'" + CRLF
cQuery += " AND N1_ITEM BETWEEN '"+cItemDe+"' AND '"+cItemAte+"'" + CRLF
cQuery += " AND N1_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"'"+ CRLF
cQuery += " AND N1_PATRIM <> 'E' "+ CRLF
cQuery += " AND N1_STATUS ='1'"+ CRLF

If SN1->(FieldPos("N1_MSBLQL")) > 0
	cQuery += " AND N1_MSBLQL <> '1' "+ CRLF
End If

cQuery += " AND N3_BAIXA = '0' "+ CRLF
cQuery += " AND N3_TIPO = '13' "+ CRLF
cQuery += " AND N3_TPSALDO = '"+cTpSaldo+"'"+ CRLF
cquery += " AND SN1.D_E_L_E_T_ = ' ' "+ CRLF
cquery += " AND SN3.D_E_L_E_T_ = ' ' "    + CRLF

cQuery += " AND NOT EXISTS ( SELECT FN5_CBAORI FROM "+RetSqlName("FN5")+"  FN5, " +RetSqlName("FN1")+ "  FN1"+ CRLF
cQuery += " WHERE FN5.FN5_FILIAL = '"+xFilial("FN5")+"'"+ CRLF
cQuery += " AND FN5.FN5_CBAORI = N1_CBASE" + CRLF
cQuery += " AND FN5.FN5_ITEORI = N1_ITEM "+ CRLF
cQuery += " AND FN1.FN1_FILIAL = '"+xFilial("FN5")+"'"+ CRLF
cQuery += " AND FN1.FN1_PROC = FN5_PROC"+ CRLF
cQuery += " AND FN1.FN1_DATA = '"+Dtos(dDatabase)+ "'" + CRLF
cQuery += " AND FN1.FN1_STATUS <> '2' " + CRLF
cQuery += " AND FN1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " AND FN5.D_E_L_E_T_ = ' ')"+ CRLF


cQuery := ChangeQuery(cQuery)

If Select(cAliasQry) > 0
	dbSelectArea(cAliasQry)
	dbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TcSetField(cAliasQry,"N3_VORIG1","N",aTamSN1[1],aTamSN1[2])

dbSelectArea(cAliasQry)
dbGotop()

dbEval( {|| aAdd(aRet, (cAliasQry)->({ .T., N1_CBASE, N1_ITEM, N3_TIPO, N3_TPSALDO, N1_DESCRIC, N3_VORIG1}))})

if Len(aRet) = 0
endif

aDados08:= {}
aDados08 := AClone(aRet)
oBrowse08:SetArray(aDados08)
oBrowse08:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraCapi  บAutor  ณAlexandre Circenis  บ Data ณ  09/17/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o acols do resumo de calculo da capitalizacao dos      บฑฑ
ฑฑบ          ณcusto de emprestimos para os bens selecionados.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function GeraCapi(oGetDP03, xCustTran ,oGetDP06,aDados08, aHeader09, Acols09, lManual)
Local nX, nY
Local nSldContr := 0 // Saldo dos Contratos de Financiamento
Local nJurContr := 0 // Valor dos Juros de Competencia de Contratos.
Local nVlrAmort := 0 // Valor da Total da Amortiza็ใo
Local nVlrRend  := 0 // Valor dos Rendimentos
Local nTaxaCap  := 0 // Valor da Taxa de Capitalica็ใo
Local nPosSaldo := Ascan(oGetDP03:aHeader,{|x|Alltrim(x[2]) = "FN2_VLRSAL"})
Local nPosJuros := Ascan(oGetDP03:aHeader,{|x|Alltrim(x[2]) = "FN2_JURCOM"})
Local nPosAmort := 8
Local nPosRend  := Ascan(oGetDP06:aHeader,{|x|Alltrim(x[2]) = "FN4_VALOR"})
LOcal nPosCust
Local aLinhaAux  // Linha auxiliar para preenhimento do Acols
Local nCont := 0
Local lRet := .T.

For nX := 1 To len(oGetDP03:aCols)
	if !Atail(oGetDP03:aCols[nX])
		nSldContr += oGetDP03:aCols[nX, nPosSaldo]
		nJurContr += oGetDP03:aCols[nX, nPosJuros]
	endif
next nX

if !lManual

	For nX := 1 To len(xCustTran)
		if xCustTran[nX, 1] // Esta marcado somar
			nVlrAmort += xCustTran[nX, nPosAmort]
		endif
	next nX

else

	nPosCust := Ascan(xCustTran:aHeader,{|x|Alltrim(x[2]) = "FN3_AMORT"})
	for nX := 1 to Len(xCustTran:aCols)
			nVlrAmort += xCustTran:aCols[nX, nPosCust]
	next

endif

For nX := 1 To len(oGetDP06:aCols)
	if !Atail(oGetDP06:aCols[nX])
		nVlrRend += oGetDP06:aCols[nX, nPosRend]
	endif
next nX

nTaxaCap := (nJurContr + nVlrAmort - nVlrRend) / nSldContr
aCols09 := {}

if nTaxaCap < 0
	Help( " ", 1, "AF480TXCAP",, STR0056,1,0) //Taxa de Capitaliza็ใo Negativa. Rever os valores dos empr้stimos e rendimentos.
	lRet := .F.
elseif At("*",Transform(nTaxaCap*100, PesqPict("FN5","FN5_TXCAP")) ) > 0
	Help(" ",1,"AF480TXCPB",,"Taxa de Capitaliza็ใo com o valor de"+Str(nTaxaCap)+" estแ acima do mแximo permitido para o campo.",1,0)
	lRet := .F.
else
	for nX := 1 to Len(aDados08)
		if aDados08[ nX, 1] // Ativo marcado para Capitalizacao
			nCont++
			aLinhaAux := {}
			for nY := 1 to Len(aHeader09)
				cCampo := Alltrim(aHeader09[nY,2])
				if cCampo =="FN5_CBAORI"
					Aadd(aLinhaAux, aDados08[nX, 02])
				elseif cCampo =="FN5_LINHA"
					Aadd(aLinhaAux, StrZero(nCont,Len(FN5->FN5_LINHA)))
					elseif cCampo =="FN5_ITEORI"
					Aadd(aLinhaAux, aDados08[nX, 03])
				elseif cCampo =="FN5_TIPORI"
					Aadd(aLinhaAux, aDados08[nX, 04])
				elseif cCampo =="FN5_SLDORI"
					Aadd(aLinhaAux, aDados08[nX, 05])
				elseif cCampo =="FN5_VLRORI"
					Aadd(aLinhaAux, aDados08[nX, 07])
				elseif cCampo =="FN5_TXCAP"
					Aadd(aLinhaAux, nTaxaCap*100)
				elseif cCampo =="FN5_VLRAPR"
					Aadd(aLinhaAux, nTaxaCap *  aDados08[nX, 07])
				else
					Aadd(aLinhaAux, Criavar(cCampo))
				endif
			next nY
			Aadd(aLinhaAux, .f.)
			Aadd(aCols09, Aclone(aLinhaAux))

		endif
	next nX
endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF480CATF บAutor  ณAlvaro Camillo Neto บ Data ณ  09/17/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a cria็ใo dos ativos utilizando a rotina automaticaบฑฑ
ฑฑบ          ณcusto de emprestimos para os bens selecionados.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function AF480CATF(oGetDP09,cGrupo,xDados05,oGetDP06,oGetDP03,nSaveSx8Len,lManual)


Local aCols     := oGetDP09:aCols
Local aHeader   := oGetDP09:aHeader
Local nPosCBOri := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_CBAORI"}) // Codigo Base Original
Local nPosItOri := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_ITEORI"}) // Item Original
Local nPosSlOri := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_SLDORI"}) // Tipo de Saldo Original
Local nPosTpOri := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_TIPORI"}) // Tipo Original
Local nPosVlOri := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_VLRORI"}) // Valor original
Local nPosTxCap := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_TXCAP"})  // Taxa Capitaliza็ใo
Local nPosVlApr := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_VLRAPR"}) // Valor Apropriacao
Local nPosLinha := Ascan(aHeader,{|x|Alltrim(x[2]) = "FN5_LINHA"})  // Linha do Acols
Local nX        := 0
Local nY        := 0
Local aCab		  := {}
Local aSldVal   := {}
Local aArea     := GetArea()
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSN3  := SN3->(GetArea())
// Variaveis do ExecAuto dos Bens
Local aParam :={{"MV_PAR01",2},{"MV_PAR02",1},{"MV_PAR03",2}}
Local cFileLog := NomeAutoLog()
Local cPath := ""
Local lGrvOk := .t.
Local cFilSN3	:= FWFilial("SN3")
Private	lMsErroAuto := .f.

BEGIN TRANSACTION

For nX := 1 to Len(aCols)
	aCab	   := {}
	aSldVal   := {}
	dbSelectArea("SN1")
	SN1->(dbSetOrder(1))
	If SN1->(dbSeek(xFilial("SN1")+ aCols[nX, nPosCbOri] + aCols[nX, nPOsItOri]))
		// Criacao da ficha do Ativo de Custo de emprestimo para os itens selecionados
		
		aAdd(aCab,{"N1_CBASE" , aCols[nX, nPosCbOri]})
		aAdd(aCab,{"N1_AQUISIC" , dDatabase})
		aAdd(aCab,{"N1_STATUS" , "1"})
		aAdd(aCab,{"N1_PATRIM" , "E"}) // Custo de Emprestimo
		aAdd(aCab,{"N1_ITEM"   , ATFXProxIt(cFilAnt,SN1->N1_CBASE)})
		aAdd(aCab,{"N1_QUANTD" , 1})
		aAdd(aCab,{"N1_DESCRIC", STR0054+ Alltrim(SN1->N1_CBASE) + "-"+ Alltrim(aCols[nX, nPOsItOri])}) // "CUSTO DE EMPRESTIMO  "
		aAdd(aCab,{"N1_BASESUP", SN1->N1_CBASE})
		aAdd(aCab,{"N1_ITEMSUP", aCols[nX, nPOsItOri]})
		aAdd(aCab,{"N1_GRUPO"  , cGrupo})
		aAdd(aCab,{"N1_INIAVP" , dDataBase})
		
		Aadd( aCab,{"N1_ORIGEM", "ATFA480", NIL})
		
		dbSelectArea("SN3")
		dbSetOrder(11)
		
		aItem := {}
		If dbSeek(xFilial("SN3")+ aCols[nX, nPosCbOri] + aCols[nX, nPOsItOri] + aCols[nX, nPosTpOri] + '0' + aCols[nX, nPOsSlOri])
		
			aAdd(aItem,{"N3_FILIAL", xFilial("SN3"), NIL})
			aAdd(aItem,{"N3_TIPO", "13", NIL})
			aAdd(aItem,{"N3_HISTOR", SN1->N1_DESCRIC , NIL})
			aAdd(aItem,{"N3_TPSALDO", aCols[nX, nPosSlOri], NIL})
			aAdd(aItem,{"N3_TPDEPR", "1", NIL})
			aAdd(aItem,{"N3_VORIG1", aCols[nX, nPosVlApr], NIL})
			aAdd(aItem,{"N3_TXDEPR1", 0.00 , NIL})
			aAdd(aItem,{"N3_DINDEPR", dDataBase+1, NIL})
			If Empty(cGrupo)
				aAdd(aItem,{"N3_CCONTAB"		, SN3->N3_CCONTAB, NIL})
				aAdd(aItem,{"N3_CUSTBEM"		, SN3->N3_CUSTBEM, NIL})
				aAdd(aItem,{"N3_CDEPREC"		, SN3->N3_CDEPREC, NIL})
				aAdd(aItem,{"N3_CCUSTO"		, SN3->N3_CCUSTO, NIL})
				aAdd(aItem,{"N3_CCDEPR"		, SN3->N3_CCDEPR, NIL})
				aAdd(aItem,{"N3_CDESP"		, SN3->N3_CDESP, NIL})
				aAdd(aItem,{"N3_CCORREC"		, SN3->N3_CCORREC, NIL})
			EndIf
		endif
		Aadd(aSldVal,aItem)
		
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)}, aCab,aSldVal,3,aParam)
		If lMsErroAuto
			cFileLog := NomeAutoLog()
			cPath := ""
			If !Empty(cFileLog)
				MostraErro(cPath,cFileLog)
			Endif
			lMsErroAuto := .F.
			
			While GetSx8Len() > nSaveSx8Len
				RollBackSx8()
			End
			
			
			lGrvOk := .f. // Erro na Grava็ใo
			DisarmTransaction()
			exit // Sair do Laco // Caso nใo esteja numa transa็ใo
			
			
		else  // Gravar FN5 com os dados de Grav็ใo.
			
			RecLock("FN5" ,.T.)
			FN5->FN5_FILIAL := xFilial("FN5")
			FN5->FN5_PROC   := M->FN1_PROC
			FN5->FN5_LINHA  := aCols[nX,nPosLinha]
			FN5->FN5_CBAORI := aCols[nX,nPosCBOri] // Codigo Base Original
			FN5->FN5_ITEORI := aCols[nX,nPosItOri] // Item Original
			FN5->FN5_SLDORI := aCols[nX,nPosSlOri] // Tipo de Saldo Original
			FN5->FN5_TIPORI := aCols[nX,nPosTpOri] // Tipo Original
			FN5->FN5_VLRORI := aCols[nX,nPosVlOri] // Valor original
			FN5->FN5_TXCAP  := aCols[nX,nPosTxCap] // Taxa Capitaliza็ใo
			FN5->FN5_VLRAPR := aCols[nX,nPosVlApr] // Valor Apropriacao
			FN5->FN5_CBACEM := SN1->N1_CBASE
			FN5->FN5_ITECEM := SN1->N1_ITEM
			FN5->FN5_TIPEMP := '13'
			FN5->FN5_SLDEMP := aCols[nX, nPosSlOri]
			FN5->FN5_GRPCEM := SN1->N1_GRUPO
			MsUnlock()
			
		endif
	endif
next


if lGrvOk
// Grava็ใo FN1
	dbSelectArea("FN1")
	RecLock("FN1",.T.)
	FN1->FN1_FILIAL := xFilial("FN1")
	FN1->FN1_PROC	:= M->FN1_PROC
	FN1->FN1_DATA	:= M->FN1_DATA
	FN1->FN1_DESC   := M->FN1_DESC
	FN1->FN1_STATUS := '1'
	FN1->FN1_TIPO   := if(lManual,'2','1')
	MsUnlock()

// Grava็ใo FN2
	for nX := 1 to Len(oGetDP03:aCols)
		if !Atail(oGetDP03:aCols[nX]) // Ultimo elemento do Array
			RecLock("FN2",.T.)
			FN2->FN2_FILIAL := xFilial()
			FN2->FN2_PROC   := M->FN1_PROC
			for nY := 1 to Len(oGetDP03:aHeader)
				FN2->&(oGetDP03:aHeader[nY,2]) := oGetDP03:aCols[nX,nY]
			next nY
			MsUnlock()
		endif

	next nX
// Grava็ใo FN3
	if lManual
		for nX := 1 to Len(xDados05:aCols)
			if !Atail(xDados05:aCols[nX]) // Ultimo elemento do Array
				RecLock("FN3",.T.)
				FN3->FN3_FILIAL := xFilial()
				FN3->FN3_PROC   := M->FN1_PROC
				for nY := 1 to Len(xDados05:aHeader)
					FN3->&(xDados05:aHeader[nY,2]) := xDados05:aCols[nX,nY]
				next nY
				MsUnlock()
			endif
		next nX
	else
		for nX := 1 to Len(xDados05)
			if xDados05[nX, 1] // marcado
				RecLock("FN3",.T.)
				FN3->FN3_FILIAL := xFilial()
				FN3->FN3_PROC   := M->FN1_PROC
				FN3->FN3_LINHA  := xDados05[nX ,2]
				FN3->FN3_CBASE  := xDados05[nX ,3]
				FN3->FN3_ITEM   := xDados05[nX ,4]
				FN3->FN3_TIPO   := xDados05[nX, 5]
				FN3->FN3_TPSALD := xDados05[nX, 6]
				FN3->FN3_AMORT  := xDados05[nX, 8]
				msUnlock()
			endif
		next nX
	endif
// Grava็ใo FN4
	for nX := 1 to Len(oGetDP06:aCols)
		if !Atail(oGetDP06:aCols[nX]) // Ultimo elemento do Array
			RecLock("FN4",.T.)
			FN4->FN4_FILIAL := xFilial()
			FN4->FN4_PROC   := M->FN1_PROC
			for nY := 1 to Len(oGetDP06:aHeader)
				FN4->&(oGetDP06:aHeader[nY,2]) := oGetDP06:aCols[nX,nY]
			next nY
			MsUnlock()
		endif

	next nX

	ConfirmSx8()

Endif

END TRANSACTION

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lGrvOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF480EST บAutor  ณAlvaro Camillo Neto บ Data ณ  09/17/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o estorno da opera็ใo excluindo as fichas           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function AF480EST(nReg)
Local aArea     := GetArea()
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSN3  := SN3->(GetArea())
// Variaveis do ExecAuto dos Bens
Local aParam :={{"MV_PAR01",2},{"MV_PAR02",1},{"MV_PAR03",2}}
Local cFileLog := NomeAutoLog()
Local cPath := ""
Local lRet  := .T.
Local aCab  := {}

Private	lMsErroAuto := .f.

BEGIN TRANSACTION

// Grava็ใo FN1
dbSelectArea("FN1")
dbGoto(nReg)
RecLock("FN1",.F.)
FN1->FN1_STATUS := '2'
MsUnlock()

aSldVal := {}
dbSelectArea("FN5")
dbSetOrder(1)
dbSeek(xFilial("FN5")+FN1->FN1_PROC)
while FN5->(!Eof()) .and. FN5->(FN5_FILIAL+FN5_PROC) = xFilial("FN5")+FN1->FN1_PROC

	lMsErroAuto := .f.
	
	SN1->(dbSetOrder(1))

	AAdd(aCab,{"N1_CBASE"  	, FN5->FN5_CBACEM	,NIL})
	AAdd(aCab,{"N1_ITEM"   	, FN5->FN5_ITECEM  ,NIL})
	
	MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCab,aSldVal,5,aParam)

	If lMsErroAuto
		lMsErroAuto := .F.
		lRet := .F.

		cFileLog := NomeAutoLog()
		cPath := ""
		If !Empty(cFileLog) .And. !lRet
			MostraErro(cPath,cFileLog)
		Endif

		DisarmTransaction()

	endif
	
	aCab := {}
	
	FN5->(dbSkip())
enddo


END TRANSACTION

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF480VLGRP  บAutor  ณAlexandre Circenis  บ Data ณ  20/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo de pergunte                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function AF480VLGRP()
Local lRet := .T.
Local cConteudo := &(ReadVar())

If !Empty(cConteudo)
	lRet := ExistCpo("SNG", cConteudo, 1 )
EndIf

Return lRet
