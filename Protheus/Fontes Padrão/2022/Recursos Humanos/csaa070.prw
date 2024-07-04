#include "fwadaptereai.ch"
#include "dbtree.ch"
#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#INCLUDE "CSAA070.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ CSAA070     ³ Autor ³ Cristina Ogura           ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o   ³ Cadastro das Tabelas Salariais                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ CSAA070                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros  ³ xAutoCab   - Array ExecAuto com RBR                              ³±±
±±³            ³ xAutoItens - Array ExecAuto com RB6                              ³±±
±±³            ³ nOpcAuto   - Opção 3 inc 4 Alt 5 Del                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³07/07/2014³TPZVTW      ³Incluido o fonte da 11 para a 12 e        ³±±
±±³            ³          ³            ³efetuada a limpeza.                       ³±±
±±³Gabriel A.  ³08/07/2015³PCDEF-      ³Retirada a verificação de release da      ³±±
±±³            ³          ³45828       ³chamada da mensagem única.                ³±±
±±³Marcos Perei³03/09/2015³PCREQ-      ³Produtizacao projeto MP na 12.            ³±±
±±³            ³          ³5342        ³                                          ³±±
±±³Raquel Hager³20/09/2016³TVVUNW      ³Ajuste na função fValidVlr para impedir   ³±±
±±³            ³          ³            ³que o campo Coeficiente estoure picture e ³±±
±±³            ³          ³            ³gere erro ao gravar a tabela.             ³±±
±±³Eduardo K.  ³28/10/2016³TWJOMP      ³Ajuste na função fProcReaj para calculo   ³±±
±±³            ³          ³            ³correto das faixas ao executar a função   ³±±
±±³            ³          ³            ³de reajuste da tabela.	                  ³±±
±±³Gabriel A.  ³08/03/2017³MRH-        ³Ajuste na validação de linhas do "grid".  ³±±
±±³M. Silveira ³07/04/2017³DRHPONTP-57 ³Ajuste no preenchimento automatico p/ nao ³±±
±±³            ³          ³            ³deixar lacunas entre as faixas.           ³±±
±±³M. Silveira ³09/05/2017³DRHPONTP-444³Ajuste no preenchimento automatico para   ³±±
±±³            ³          ³            ³validar o tamanho do coeficiente calculado³±±
±±³M. Silveira ³10/05/2017³DRHPONTP-474³Ajuste no preenc. automatico p/ tratar da ³±±
±±³            ³          ³            ³forma correta valor exato ou p/ intervalo.³±±
±±³Esther V.   ³22/05/2017³DRHPONTP-652³Ajuste na validacao do campo RB6_COEFIC,  ³±±
±±³            ³          ³            ³na gravacao do campo RB6_COEFIC no aCols. ³±±
±±³E.Moskovkina³20/09/2017³HR-PY-45-5  ³Option "Automatically Fill In" is removed ³±±
±±³            ³          ³            ³for Russia localization. Calculation of   ³±±
±±³            ³          ³            ³"Levels and Ranges editing" is fixed.     ³±±
±±³            ³          ³            ³Check of coefficients is deleted for      ³±±
±±³            ³          ³            ³"Delete" and "View" actions		     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CSAA070(xAutoCab,xAutoItens,nOpcAuto,lEAutMU)
Private aIndexRBR	:= {}
Private bFiltraBrw 	:= {|| Nil}	   			// Variavel para Filtro
Private	aAC 		:= {STR0001,STR0002}	//"Abandona"###"Confirma"

//variavel que define se mantem historico das alteracoes na tabela salarial
Private lHistorico	:= Iif( Getmv("MV_HISTSAL",,"2") = "1", .T., .F.)
Private cCpoFaixa	:= Getmv("MV_CPOFAI",,"")
Private lGestPubl 	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)  //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Private aRotina     := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro 	:= If(lGestPubl,OemtoAnsi(STR0106),OemtoAnsi(STR0008))	//"Tabela de Subsídios"/"Cadastro das Tabelas Salariais"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Variaveis para rotina automatica    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private lExecAuto  	:= ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
Private aAutoCab  	:= {}
Private aAutoItens 	:= {}

Private lExAutMU	:= If(lEAutMU <> Nil, lEAutMU, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("RBR")
dbSetOrder(1)
dbGotop()

If lExecAuto
	aAutoCab 	:= xAutoCab
	aAutoItens 	:= xAutoItens

	MBrowseAuto(nOpcAuto,aAutoCab,"RBR")
Else
	mBrowse(6, 1, 22, 75, "RBR",, , , , , fUsaCor() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RBR",aIndexRBR)

dbSelectArea("RBR")
dbSetOrder(1)

dbSelectArea("RB6")
dbSetOrder(1)

dbSelectArea("SX3")
dbSetOrder(1)

dbSelectArea("SQ3")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que trata as funcoes para a Tabela Salarial         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Rot(cExpC1,nExpN1,nExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Rot(cAlias,nReg,nOpc)

// Variaveis Locais do programa
Local aKeys			:= GetKeys()
Local nX
Local cCampo		:= ""
Local cAplicada	:= ""

// Variaveis Locais para MSDialogs
Local oDlgMain
Local o1Group
Local oFont
Local nOpca 		:= 0
Local nPos			:= 0
Local lRet			:= .F.
Local bSet15		:= {||}
Local bSet24		:= {||}
Local aButtons  	:= {}
Local lCsDel		:= If( nOpc = 2 .Or. nOpc = 5 , .F. , .T. )

// Variaveis para Dimensionar Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}


Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local aAdv31Size	:= {}
Local aInfo31AdvSize:= {}
Local aObj31Size	:= {}
Local aObj31Coords	:= {}

Local aAdv32Size	:= {}
Local aInfo32AdvSize:= {}
Local aObj32Size	:= {}
Local aObj32Coords	:= {}

Local aAdv33Size	:= {}
Local aInfo33AdvSize:= {}
Local aObj33Size	:= {}
Local aObj33Coords	:= {}

Local nSize:=0
Local cTexto, oTexto

//variaveis par o ExecAuto
Local nI			:= 0
Local nPosNivel		:= 0
Local cContrNivel	:= ""
Local nQtdeFaixa	:= 0

// Variaveis Privadas do programa
Private nOpcx			:= nOpc
Private aCols			:= {}
Private aHeader			:= {}
Private aAlter			:= {}
Private aRBRCols		:= {}
Private aRBRHeader		:= {}
Private aRBRFields		:= {}
Private aRBRVisual		:= {}
Private aRBRVirtual		:= {}
Private aRBRAltera		:= {}
Private aRBRNotAlt		:= {}
Private aRB6Novos		:= {}
Private aCpoNivel		:= {}
Private aCpoFaixa		:= {}
Private aNaoUtil 		:= {	"RB6_FILIAL" 	, ;
								"RB6_TABELA" 	, ;
    	               			"RB6_DESCTA" 	, ;
	        	           		"RB6_TIPOVL" 	, ;
    	        	       		"RB6_FAIXA"  	, ;
        	        	   		"RB6_DTREF"    	}

Private cGrupoDe   		:= ""
Private cGrupoAt		:= ""
Private nNrNivel		:= 0
Private nTpVl   		:= 0
Private nNrFaixa		:= 0
Private nQual			:= 0
Private nPtos			:= 0
Private nUsaPto			:= 0

Private cTabela			:= ""
Private cDescTab		:= ""
Private cTipo			:= ""
Private nValRef 		:= 0
Private cNivel1			:= ""
Private dDataRef		:= Date()

Private aNiveis := {}
// Variaveis Privadas para MSDialogs
Private oDlg
Private oEnchoice
Private oGet



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RBR",aIndexRBR)
aIndexRBR := {}
dbGoto(nReg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta tela inicial de criacao de tabela                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3  	// Inclusao
	If !lExecAuto  // Inclusão manual
		If cPaisLoc $ "RUS"
			nQual:=1
			Cs070Perg()
			M->RBR_TIPOVL := nTpVl
		Else
		    /*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Monta as Dimensoes dos Objetos         					   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			aAdv3Size		:= MsAdvSize(.F.,.T.,300)
			aAdv3Size[4]	:=aAdv3Size[4]*0.6							//Linha final da Area de Trabalho
			aAdv3Size[6]    :=aAdv3Size[6]*0.7							//Linha final Area Dialogo
			aInfo3AdvSize	:= { aAdv3Size[1] , aAdv3Size[2] , aAdv3Size[3] , aAdv3Size[4] , 5 , 5 }
			aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )			//1-Texto
			aAdd( aObj3Coords , { 080 , 000 , .F. , .T. } )			//2-Botoes
			aObj3Size	:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )

			aAdv31Size		:= aClone(aObj3Size[1])
			aInfo31AdvSize	:= { aAdv31Size[2] , aAdv31Size[1] , aAdv31Size[4] , aAdv31Size[3] , 2 , 5 }
			aAdd( aObj31Coords , { 000 , 000 , .T. , .T. } )
			aAdd( aObj31Coords , { 000 , 045 , .T. , .F. , .T. } )		//2-Tmultiget
			aAdd( aObj31Coords , { 000 , 000 , .T. , .T. } )
			aObj31Size	:= MsObjSize( aInfo31AdvSize , aObj31Coords )

			aAdv33Size		:= aClone(aObj3Size[2])
			aInfo33AdvSize	:= { aAdv33Size[2] , aAdv33Size[1] , aAdv33Size[4] , aAdv33Size[3] , 5 , 5 }
			aAdd( aObj33Coords , { 000 , 000 , .T. , .T. } )
			aAdd( aObj33Coords , { 000 , 011 , .T. , .F. } )
			aAdd( aObj33Coords , { 000 , 011 , .T. , .F. } )
			aAdd( aObj33Coords , { 000 , 011 , .T. , .F. } )
			aAdd( aObj33Coords , { 000 , 000 , .T. , .T. } )
			aObj33Size	:= MsObjSize( aInfo33AdvSize , aObj33Coords )


			aAdv32Size		:= aClone(aObj33Size[2])
			aInfo32AdvSize	:= { aAdv32Size[2] , aAdv32Size[1] , aAdv32Size[4] , aAdv32Size[3] , 5 , 5 }
			aAdd( aObj32Coords , { 000 , 000 , .T. , .T. } )
			aAdd( aObj32Coords , { 075 , 000 , .F. , .T. } )
			aAdd( aObj32Coords , { 000 , 000 , .T. , .T. } )
			aObj32Size	:= MsObjSize( aInfo32AdvSize , aObj32Coords,,.T. )


			DEFINE MSDIALOG oDlgMain FROM aAdv3Size[7],0 TO aAdv3Size[6],aAdv3Size[5] TITLE cCadastro OF oMainWnd PIXEL

				cTexto := Iif(lGestPubl,OemtoAnsi(STR0107),OemtoAnsi(STR0009))+' '+ OemtoAnsi(STR0010)+' '+OemtoAnsi(STR0011)+ OemtoAnsi(STR0012)
				cTexto := cTexto + OemtoAnsi(STR0013)+ OemtoAnsi(STR0014)

		    	oTexto := TMultiget():New(aObj31Size[2,1],aObj31Size[2,2],{|u|if(Pcount()>0,cTexto:=u,cTexto)},;
		                          oDlgMain,aObj31Size[2,3],aObj31Size[2,4],,,,,,.T.,,,,,,.T.,,,,.T.)
				oTexto:lWordWrap:=.T.

				@ aObj33Size[2,1],aObj32Size[2,2] BUTTON STR0015	SIZE 75,11 OF oDlgMain PIXEL ACTION (nQual:=1,If(Cs070Perg(),(lRet:=.T.,oDlgMain:End()),))	//"INFORMADA"
				@ aObj33Size[3,1],aObj32Size[2,2] BUTTON STR0016	SIZE 75,11 OF oDlgMain PIXEL ACTION (nQual:=2,If(Cs070Perg(),(lRet:=.T.,oDlgMain:End()),))	//"CALCULADA POR PONTOS"
				@ aObj33Size[4,1],aObj32Size[2,2] BUTTON STR0017	SIZE 75,11 OF oDlgMain PIXEL ACTION (nOpca:=1,lRet:=.T.,oDlgMain:End()) 					//"SAIR"

			ACTIVATE MSDIALOG oDlgMain CENTERED VALID lRet

			If nOpca == 1
				Eval(bFiltraBrw)
				dbGotop()
				Return Nil
			EndIf
		Endif
	Else //Inclusão via ExecAuto
		If cPaisLoc $ "RUS"
			nQual:=1
			nUsaPto:=0
		Else
			nPos 		:= aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_USAPTO"} )
			If nPos > 0
				nQual		:= aAutoCab[nPos][ 2 ]
        		nUsaPto		:= aAutoCab[nPos][ 2 ]			
				// Remove campo para não gerar conflito com a função MsGetDAuto
				aDel( aAutoCab, nPos ) 					//Deleta registro do array
				aSize( aAutoCab, Len( aAutoCab ) - 1 ) //Diminui a posição excluída do array
			EndIf
		Endif

        lRet		:= .T.
        nPosNivel 	:= Ascan(aAutoItens[1],{|aValorItem | Alltrim(aValorItem[1]) == AllTrim("RB6_NIVEL")})

		Do Case
			Case aAutoCab[ aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_TIPOVL"} ) ][ 2 ] == 1	//Exatos / Nivel
				nTpVl	:= 1
				nPtos	:= 1
				M->RBR_TIPOVL	:= 1
			Case aAutoCab[ aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_TIPOVL"} ) ][ 2 ] == 2	//Intervalo / Nivel
				nTpVl	:= 2
				nPtos	:= 1
				M->RBR_TIPOVL	:= 2
			Case aAutoCab[ aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_TIPOVL"} ) ][ 2 ] == 3	//Exatos / Faixa
				nTpVl	:= 1
				nPtos	:= 2
				M->RBR_TIPOVL	:= 3
			Case aAutoCab[ aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_TIPOVL"} ) ][ 2 ] == 4	//Intervalo / Faixa
				nTpVl	:= 2
				nPtos	:= 2
				M->RBR_TIPOVL	:= 4
		EndCase
		nNrNivel	:= len(aAutoItens)
		nNrFaixa	:= 1
	EndIf
Else
	If lExecAuto  .AND. nOpc == 4 // ExecAuto e Alteração
		M->RBR_TIPOVL	:= aAutoCab[ aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_TIPOVL"} ) ][ 2 ]
		If M->RBR_TIPOVL == 1 .OR. M->RBR_TIPOVL == 3
			nTpVl	:= 1
		Else
			nTpVl	:= 2
		EndIf
		nNrNivel		:= len(aAutoItens)
		nNrFaixa		:= 1
	EndIf
	nPos 			:= aScan(aAutoCab, {|x| AllTrim(x[1]) == "RBR_USAPTO"} )
	If nPos > 0 
		// Remove campo para não gerar conflito com a função MsGetDAuto
		nUsaPto	:= aAutoCab[nPos][ 2 ]	
		aDel( aAutoCab, nPos ) 					//Deleta registro do array
		aSize( aAutoCab, Len( aAutoCab ) - 1 ) //Diminui a posição excluída do array
	EndIf
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Dados para Enchoice - RBR                   				³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aRBRHeader := RBR->( GdMontaHeader( NIL , @aRBRVirtual , @aRBRVisual , NIL , {"RBR_FILIAL"}, , .T. ) )

aRBRNotAlt := { "RBR_FILIAL" , "RBR_TABELA" , "RBR_DTREF" , "RBR_VLREF" }

For nX := 1 To Len( aRBRHeader )
	aAdd( aRBRFields , aRBRHeader[ nX , 02 ] )
	If ( nOpcx == 3 ) .or. ( nOpcx == 4 .and. aScan(aRBRNotAlt, {|x| x == aRBRHeader[ nX , 02 ] }) == 0 )
		aAdd( aRBRAltera , aRBRFields[ nX ] )
	EndIf
	IF (nOpcx == 3) .OR. !Empty(aScan(aRBRVirtual, {|x| x == aRBRHeader[ nX , 02 ] } )) // inclusao
		&( "M->"+aRBRHeader[ nX , 02 ] ) := CriaVar( aRBRHeader[ nX , 02 ] )
	Else
		&( "M->"+aRBRHeader[ nX , 02 ] ) := RBR->( &( aRBRHeader[ nX , 02 ] ) )
	EndIf
Next nX

If !lExecAuto
	If nOpcx == 3		// Inclusao
		M->RBR_TABELA	:= GetSx8Num("RB6","RB6_TABELA")
		M->RBR_DESCTA	:= CriaVar("RBR_DESCTA")
		M->RBR_DTREF	:= Date()	//Sugere a Dt.Atual como Dt.Referencia
		M->RBR_APLIC	:= "2"
		cAplicada		:= oEmToAnsi(STR0081)
		Do Case
			Case nTpVl == 1 .AND. nPtos	== 1
				M->RBR_TIPOVL := 1	//Exatos / Nivel

			Case nTpVl == 2 .AND. nPtos	== 1
				M->RBR_TIPOVL := 2	//Intervalo / Nivel

			Case nTpVl == 1 .AND. nPtos	== 2
				M->RBR_TIPOVL := 3	//Exatos / Faixa

			Case nTpVl == 2 .AND. nPtos	== 2
				M->RBR_TIPOVL := 4	//Intervalo / Faixa
		EndCase
	Else
		M->RBR_FILIAL	:= RBR->RBR_FILIAL
		M->RBR_TABELA	:= RBR->RBR_TABELA
		M->RBR_DESCTA	:= RBR->RBR_DESCTA
		M->RBR_APLIC	:= RBR->RBR_APLIC
		M->RBR_TIPOVL	:= RBR->RBR_TIPOVL
		cAplicada		:= If ( M->RBR_APLIC == "1" , oEmToAnsi(STR0080) , oEmToAnsi(STR0081) )
		nValRef			:= RBR->RBR_VLREF
		nUsaPto			:= RBR->RBR_USAPTO
		Do Case
			Case RBR->RBR_TIPOVL == 1	//Exatos / Nivel
				nTpVl	:= 1
				nPtos	:= 1
			Case RBR->RBR_TIPOVL == 2	//Intervalo / Nivel
				nTpVl	:= 2
				nPtos	:= 1
			Case RBR->RBR_TIPOVL == 3	//Exatos / Faixa
				nTpVl	:= 1
				nPtos	:= 2
			Case RBR->RBR_TIPOVL == 4	//Intervalo / Faixa
				nTpVl	:= 2
				nPtos	:= 2
		EndCase
		nNrFaixa:= Cs070Faixa(RBR->RBR_TABELA,RBR->RBR_DTREF)
	EndIf
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Dados para GetDados - RB6                   				³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

// Monta aHeader
Cs070Header()

// Monta aCols
Cs070aCols()

//Campos que podem ser alterados
Cs070Alter(@aAlter,.T.)

If !lExecAuto
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdv1Size		:= MsAdvSize()
	aInfo1AdvSize	:= { aAdv1Size[1] , aAdv1Size[2] , aAdv1Size[3] , aAdv1Size[4] , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 060 , .T. , .F. } )  		//1-Enchoice
	aAdd( aObj1Coords , { 000 , 018 , .T. , .F. } ) 		//2-Cabecalho MsGetDados
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )		//3-MsGetDados
	aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )


	nSize			:=len(cAplicada)*3		//Calculo do Tamanho da String - para centralização na Tela
	aAdv2Size		:= aClone(aObj1Size[2])
	aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 0 , 6 }
	aAdd( aObj2Coords , { 000 	, 000 , .T. , .T. } )		//1-Espaco
	aAdd( aObj2Coords , { nSize	, 000 , .F. , .T. } )		//2-Say Cabecalho
	aAdd( aObj2Coords , { 000	, 000 , .T. , .T. } )		//3-Espacao
	aObj2Size	:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )


	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdv1Size[7],0 TO aAdv1Size[6],aAdv1Size[5] OF oMainWnd PIXEL

	   	oEnchoice	:= MsmGet():New( 	"RBR"		,;   	// 01 -> tabela a consultar
									 	nReg		,;		// 02 -> Nro do Recno do Registro
									  	nOpc		,;		// 03 -> Tipo de operacao
									  	NIL			,;		// 04 ->
									  	NIL			,;		// 05 ->
									  	NIL			,; 		// 06 ->
									  	aRBRFields	,;		// 07 -> campos editaveis
									  	aObj1Size[1]	,;      // 08 -> posicao da Enchoice na tela
									  	aRBRAltera	,;		// 09 -> campos que permitem alteracao
									  	NIL			,;		// 10 ->
									  	NIL			,;		// 11 ->
									  	NIL			,;		// 12 -> funcao para validacao da Enchoice
									  	oDlg		,;		// 13 -> objeto
									  	NIL			,;		// 14 ->
									  	.T.			 ;		// 15 ->
									) 						// funcao da biblioteca LIB

		// APLICADA / NAO APLICADA
		oGroup:= TGroup():New(aObj1Size[2,1],aObj1Size[2,2],aObj1Size[2,3],aObj1Size[1,4],'',oDlg,,,.T.)
		@ aObj2Size[2,1] ,  aObj2Size[2,2]	 SAY cAplicada		SIZE nSize,10			OF oDlg PIXEL FONT oFont

		oGet := MsNewGetDados():New(	aObj1Size[3,1]							,;
					 					aObj1Size[3,2]	 						,;
										aObj1Size[3,3]			    	   		,;
										aObj1Size[3,4]			  			    ,;
										If(nOpc != 2 .and. nOpc != 5, ;
											GD_INSERT+GD_UPDATE+GD_DELETE,0)	,; // controle do que podera ser realizado na GetDado - nstyle
										"Cs070Ok"								,;
										"Cs070TOk"								,;
										"+RB6_NIVEL"							,;
										aAlter									,;
										0										,;
										99999 									,;
										Nil										,;
										Nil										,;
										lCsDel									,;
										oDlg									,;
									    aHeader									,;
									    aCols				 					)
		oGet:oBrowse:bGotFocus := { || CabecOK() }

		bSet15		:= {|| nOpca := 1,RestKeys(aKeys,.T.),If(Cs070TOk(nOpcx),oDlg:End(),Nil)}
		bSet24		:= {|| nOpca := 2,RestKeys(aKeys,.T.), oDlg:End()}

		If nOpc != 2 .And. nOpc != 5
			If cPaisLoc $ "RUS"
				aButtons	:=	{;
									{"RECALC" ,{||Cs070Reaj(nOpc)}  ,OeMToAnsi(STR0066),OemToAnsi(STR0066)} ;	//"Reajustar Tabela"#"Reajuste"
								}

				SetKey( VK_F7, 	 {||Cs070Reaj(nOpc)})
			Else
				aButtons	:=	{;
								{"AUTOM"  ,{||Cs070Autom(nOpc)} ,OeMToAnsi(STR0026),OemToAnsi(STR0026)},;	//"Preenchimento Automatico"#"Preencher"
								{"RECALC" ,{||Cs070Reaj(nOpc)}  ,OeMToAnsi(STR0066),OemToAnsi(STR0066)} ;	//"Reajustar Tabela"#"Reajuste"
							}

				SetKey( VK_F6, 	 {||Cs070Autom(nOpc)})
				SetKey( VK_F7, 	 {||Cs070Reaj(nOpc)})
			EndIf
		EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ) CENTERED
Else	//Com ExecAuto

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Montagem do aCols                                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	n	 := 1
	If EnchAuto("RBR",aAutoCab)
		nOpca := 2
		If MsGetDAuto(aAutoItens,NIl,{|| .T. },aAutoCab,nOpcx)
			nOpca := 1
		EndIf
	EndIf
EndIf
If 	nOpca == 1 	// Confirma

	If nOpcx = 3 .Or. nOpcx = 4		// inclusao ou alteracao
		Begin Transaction
			If nOpcx == 3				// Inclusao
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
			Cs070Grava()
			EvalTrigger()
		End Transaction

	ElseIf nOpcx = 5 	 			// exclusao
		Begin Transaction
			Cs070Delete()
		End Transaction
	EndIf

Else

	If nOpcx == 3		//Inclusao
		If ( __lSx8 )
			RollBackSx8()
		EndIf
	EndIf

EndIf

Eval(bFiltraBrw)
dbGoto(nReg)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Grava  ³ Autor ³ Kelly Soares       ³ Data ³ 28.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados na tabela RBR								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Grava()

Local cChave			:= ""
Local lInclusao			:= ( nOpcx == 3 )
Local lNovaChave
Local naRBRHeader		:= 0
Local nForaRBRHeader	:= 0
Local lValReg  			:= .T.

If lHistorico    // Se Mantem Historico Salarial
	cChave := xFilial("RBR")+M->RBR_TABELA+DTOS(M->RBR_DTREF)
Else
	cChave := xFilial("RBR")+M->RBR_TABELA
Endif

DbSelectArea("RBR")
DbSetOrder(1)

lNovaChave := ( nOpcx == 4 .and. !DbSeek(cChave) )

//Testes realizados apenas em rotinas automáticas
If lExecAuto .AND. lInclusao
	//Na rotina automática com a opção incluir, ao inserir uma chave já existente a operação não é realizada.
	lValReg := !DbSeek(xFilial("RBR")+M->RBR_TABELA)
EndIf

If lValReg
	If 	lInclusao .or. lNovaChave
		RecLock("RBR",.T.)
		RBR->RBR_FILIAL := xFilial("RBR")
		RBR->RBR_TABELA := M->RBR_TABELA
		If ( lNovaChave , M->RBR_APLIC := "2" , NIL )
	Else
		RecLock("RBR",.F.)
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Grava dados principais da tabela - RBR                   	³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	RBR->RBR_DESCTA := M->RBR_DESCTA
	RBR->RBR_DTREF  := M->RBR_DTREF
	RBR->RBR_VLREF	:= M->RBR_VLREF
	RBR->RBR_USAPTO := nUsaPto
	RBR->RBR_APLIC  := M->RBR_APLIC
	RBR->RBR_TIPOVL := M->RBR_TIPOVL

	nForaRBRHeader	:= Len(aRBRHeader)
	For naRBRHeader := 1 To nForaRBRHeader
		cCampo:= Alltrim(aRBRHeader[ naRBRHeader , 2 ])
		IF RBR->( FieldPos ( cCampo ) > 0 ) .AND. !(cCampo$"RBR_DESCTA.RBR_DTREF.RBR_VLREF.RBR_USAPTO.RBR_APLIC.RBR_TIPOVL")
			RBR->( FieldPut( FieldPos ( cCampo ) , &('M->'+cCampo  ) ) )
		EndIF
	Next naRBRHeader

	FKCOMMIT()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Grava niveis e faixas da tabela - RB6                   	³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fRB6Grava()

	RBR->( MsUnlock() )
EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Delete ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que apaga todos os dados da Tabela                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs070Delete()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Delete()

Local aTabSal	:= {}
Local cTabela	:= M->RBR_TABELA
Local lChkDelOk := .T.
Local lAtuRB6 	:= .F.
Local nPos		:= 0
Local nX		:= 0
//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA070",.T.,,.T.)
Local aLog		:= {}
Local aLogTitle := {}

Begin Transaction
	dbSelectArea("RBR")
	dbSetOrder(1)
	If dbSeek(xFilial("RBR")+M->RBR_TABELA+DTOS(M->RBR_DTREF))

		lChkDelOk  := ChkDelRegs("RBR"	,;	//01 -> Alias do Arquivo Principal
								Nil		,;	//02 -> Registro do Arquivo Principal
								Nil		,;	//03 -> Opcao para a AxDeleta
								Nil		,;	//04 -> Filial do Arquivo principal para Delecao
								Nil		,;	//05 -> Chave do Arquivo Principal para Delecao
								Nil		,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								Nil		,;	//07 -> Mensagem para MsgYesNo
								Nil		,;	//08 -> Titulo do Log de Delecao
								Nil 	,;	//09 -> Mensagem para o corpo do Log
								Nil	 	,;	//10 -> Se executa AxDeleta
								Nil		,;	//11 -> Se deve Mostrar o Log
								Nil		,;	//12 -> Array com o Log de Exclusao
								Nil		,;	//13 -> Array com o Titulo do Log
								Nil		,;	//14 -> Bloco para Posicionamento no Arquivo
								Nil		,;	//15 -> Bloco para a Condicao While
								Nil		,;	//16 -> Bloco para Skip/Loop no While
								.T.		,;	//17 -> Verifica os Relacionamentos no SX9
								Nil  	,;	//18 -> Alias que nao deverao ser Verificados no SX9
								Nil		,;	//19 -> Se faz uma checagem soft
								lExecAuto)  //20 -> Se esta executando rotina automatica



		If !lChkDelOk
			DISARMTRANSATCION()
			Return Nil
		Endif

	    //nTpVl == 1 Seleciona valores exatos os demais sistemas não estão preparados para atender valores por intervalo
	    //!lExAutMU A mensagem unica utiliza ExecAuto para excluir um registro, porem se ele esta excluindo nao a
		//necessidade de enviar o mesmo registro para ser excluido no sistema externo.
		If lIntegDef  .AND. nTpVl == 1 .AND. !lExAutMU
			// chamada da função integdef
			FwIntegDef('CSAA070')
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Primeiro deleta os itens(RB6), depois deleta a tabela(RBR)	³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		dbSelectArea("RB6")
		dbSetOrder(3)
		If RB6->( dbSeek(xFilial("RB6")+M->RBR_TABELA+DTOS(M->RBR_DTREF)) )

		While RB6->( !Eof() ) .And. RB6->RB6_FILIAL+RB6->RB6_TABELA+DTOS(RB6->RB6_DTREF) == ;
										xFilial("RB6")+M->RBR_TABELA+DTOS(M->RBR_DTREF)

				If RB6->RB6_ATUAL == "1"
					lAtuRB6 := .T.
				EndIf

				RecLock("RB6",.F.)
					RB6->( dbDelete() )
				RB6->( MsUnlock() )
				RB6->( dbSkip()   )
			EndDo

		EndIf

		RecLock("RBR",.F.)
			RBR->( dbDelete() )
		RBR->( MsUnlock() )

	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Tratamento para que ao excluir uma tabela	que seja a ultima    ³
	³ versao, ou seja, RB6_ATUAL == "1", verifique qual e a nova     ³
	³ ultima versao, ou seja, aquela com Data de Ref maior e atualize³
	³ o campo RB6_ATUAL com "1". 									 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lAtuRB6 .And. lHistorico

		If RBR->( dbSeek( xFilial("RBR")+cTabela ) )
			While RBR->( !EoF() ) .And. RBR->RBR_FILIAL+RBR->RBR_TABELA == xFilial("RBR")+cTabela
				If ( nPos := Ascan( aTabSal,{|x| x[1]+x[2] == RBR->RBR_FILIAL+RBR->RBR_TABELA} ) ) == 0
				    aAdd( aTabSal, { RBR->RBR_FILIAL, RBR->RBR_TABELA, RBR->RBR_DTREF } )
				Else
					If RBR->RBR_DTREF > aTabSal[nPos,3]
						aTabSal[nPos,3] := RBR->RBR_DTREF
					EndIf
				EndIf
				RBR->( dbSkip() )
			EndDo
		EndIf

		RB6->( dbSetOrder(3) )
		For nX := 1 To Len(aTabSal)
			If RB6->( dbSeek( aTabSal[nX, 1]+aTabSal[nX, 2]+dToS(aTabSal[nX, 3]) ) )
				While RB6->( !EoF() ) .And. RB6->RB6_FILIAL+RB6->RB6_TABELA+dToS(RB6->RB6_DTREF) == ;
							aTabSal[nX, 1]+aTabSal[nX, 2]+dToS(aTabSal[nX, 3])
					RB6->( RecLock("RB6", .F.) )
					RB6->RB6_ATUAL	:= "1"
					RB6->( MsUnlock() )
					RB6->( dbSkip() )
				EndDo
			EndIf
		Next nX

	EndIf

End Transaction

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Perg   ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica as perguntas direcionado pelos BUTTONS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cs070Perg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Perg()

Local lRet:= .F.

If nQual == 1			// Botao de Informado
	If Pergunte("CSA071")
		nTpVl		:= mv_par01
		nNrFaixa	:= mv_par02
		If !(cPaisLoc $ "RUS")
			nPtos		:= mv_par03
			nUsaPto		:= mv_par04
		Else
			nPtos		:= 0
			nUsaPto		:= 0
		Endif
		lRet 		:= .T.
	EndIf
ElseIf nQual == 2		// Botao de Calculado por pontos
	If Pergunte("CSA070")
		lRet 		:= .T.
		cGrupoDe	:= mv_par01
		cGrupoAt	:= mv_par02
		nNrNivel	:= mv_par03
		nTpVl		:= mv_par04
		nNrFaixa	:= mv_par05
		nPtos		:= mv_par06
		nUsaPto		:= mv_par07
		If nNrNivel == 0
			Aviso(STR0022,STR0023,{STR0017})	//"Aviso"###"O Nivel da Tabela Salarial nao pode ser Zero."###"Sair"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Header  ³ Autor ³ Kelly Soares       ³ Data ³ 10.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o aHeader de acordo com campos do SX3                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs070Header()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Header()

Local nX
Local nY
Local nCont		:= 0
Local nFaixas	:= 0
Local cValid	:= ""
Local cVDFFXSL  := Getmv("MV_VDFFXSL",,"01")
Local cFaixa    := "00"

// Carrega campos do SX3 e separa em AGRUPADOS e NAO AGRUPADOS
// Agrupados:     COEFICIENTE, VALOR, PONTO MIN E MAX (POR FAIXA) E INDICADOS NO PARAMETRO MV_CPOFAI
// Nao Agrupados: DEMAIS CAMPOS

Cs070Campos(@aCpoNivel,@aCpoFaixa)

// Adiciona campos NAO AGRUPADOS no aHeader

For nX := 1 to len(aCpoNivel)

	Aadd(aHeader,{aCpoNivel[nX,2],aCpoNivel[nX,3],aCpoNivel[nX,4],aCpoNivel[nX,5],aCpoNivel[nX,6],;
				  aCpoNivel[nX,7],aCpoNivel[nX,8],aCpoNivel[nX,9],aCpoNivel[nX,10],aCpoNivel[nX,11]} )

Next nX

// Adiciona campos AGRUPADOS no aHeader

If ( nOpcx != 3 ) .and. ( nTpVl == 2 )  // nTpVl: 1=Exatos, 2=Intervalo
	nFaixas := nNrFaixa / 2
Else
	nFaixas := nNrFaixa
EndIf

For nX := 1 To nFaixas

	If lGestPubl .and. nTpVl <> 2 		//Gestao Publica e nao for por intervalo
       cFaixa	:= padr(cVDFFXSL,2) 	//Troca numerico por alfanumerico
       cVDFFXSL:= Soma1(cVDFFXSL,2)
    Else
       cFaixa	:= soma1(cFaixa)
    Endif

	For nY := 1 to len(aCpoFaixa)

		If "RB6_COEFIC" $ aCpoFaixa[nY][3]

			If Empty(aCpoFaixa[nY][7])
				cValid := "fValidCoef()"
			Else
				cValid := AllTrim(aCpoFaixa[nY,7]) + " .and. fValidCoef()"
			Endif

			Aadd( aHeader , {AllTrim(aCpoFaixa[nY,2])+" "+cFaixa,aCpoFaixa[nY,3],aCpoFaixa[nY,4],aCpoFaixa[nY,5],;
			 				 aCpoFaixa[nY,6],cValid,aCpoFaixa[nY,8],aCpoFaixa[nY,9],aCpoFaixa[nY,10],aCpoFaixa[nY,11]} )

		ElseIf "RB6_VALOR" $ aCpoFaixa[nY][3]

			If Empty(aCpoFaixa[nY][7])
				cValid := "fValidVlr()"
			Else
				cValid := AllTrim(aCpoFaixa[nY,7]) + " .and. fValidVlr()"
			Endif

			If nTpVl == 1 // Valores Exatos
				Aadd( aHeader , {oEmToAnsi(STR0065)+" "+cFaixa,aCpoFaixa[nY,3],aCpoFaixa[nY,4],aCpoFaixa[nY,5],;
				 				 aCpoFaixa[nY,6],cValid,aCpoFaixa[nY,8],aCpoFaixa[nY,9],aCpoFaixa[nY,10],aCpoFaixa[nY,11]} )
			Else // Valores Por Intervalo
				nCont++
				Aadd( aHeader , {oEmToAnsi(STR0019)+' ('+cValToChar(nCont)+')',aCpoFaixa[nY,3],aCpoFaixa[nY,4],aCpoFaixa[nY,5],; // Faixa De
				 				 aCpoFaixa[nY,6],cValid,aCpoFaixa[nY,8],aCpoFaixa[nY,9],aCpoFaixa[nY,10],aCpoFaixa[nY,11]} )

				nCont++
				Aadd( aHeader , {oEmToAnsi(STR0020)+' ('+cValToChar(nCont)+')',aCpoFaixa[nY,3],aCpoFaixa[nY,4],aCpoFaixa[nY,5],;	// Faixa Ate
				 				 aCpoFaixa[nY,6],aCpoFaixa[nY,7],aCpoFaixa[nY,8],aCpoFaixa[nY,9],aCpoFaixa[nY,10],aCpoFaixa[nY,11]} )
			Endif

		Else

			Aadd( aHeader , {AllTrim(aCpoFaixa[nY,2])+" "+cFaixa,aCpoFaixa[nY,3],aCpoFaixa[nY,4],aCpoFaixa[nY,5],;
			 				 aCpoFaixa[nY,6],aCpoFaixa[nY,7],aCpoFaixa[nY,8],aCpoFaixa[nY,9],aCpoFaixa[nY,10],aCpoFaixa[nY,11]} )

		Endif

	Next nY

Next nx


Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Acols   ³ Autor ³ Kelly Soares       ³ Data ³ 10.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o aCols de acordo com os dados da tabela RB6          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs070Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Acols()

Local nI
Local nX
Local nY
Local nCont		:= 0
Local nNiveis	:= 0
Local nAcols	:= 0
Local nFaixas	:= 0
Local nMin		:= 1
Local nMax		:= 1
Local nUsado	:= len(aHeader)
Local cNivel	:= ""
Local aPontos	:= {}
Local cSeqNiv	:= ""

If ( nOpcx != 3 ) .and. ( nTpVl == 2 ) // Por Intervalo
	nFaixas := nNrFaixa / 2
Else
	nFaixas := nNrFaixa
Endif

dbSelectArea("RB6")
dbSetOrder(3)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Visualizacao, Alteracao e Exclusao							³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lExecAuto
	If dbSeek(xFilial("RB6")+M->RBR_TABELA+DTOS(M->RBR_DTREF))

	    While !Eof() .And. RB6->RB6_FILIAL + RB6->RB6_TABELA + DTOS(RB6_DTREF) == ;
	    					xFilial("RB6") + M->RBR_TABELA   + DTOS(M->RBR_DTREF)

			cNivel := RB6->RB6_NIVEL

			While !Eof() .and. RB6->RB6_FILIAL + RB6->RB6_TABELA + DTOS(RB6_DTREF)    + RB6->RB6_NIVEL == ;
	      					   xFilial("RB6")  +   M->RBR_TABELA + DTOS(M->RBR_DTREF) + cNivel

				Aadd(aCols,Array(nUsado+1))
				nAcols := Len(aCols)
				nCont  := 0

				// Campos NAO AGRUPADOS
				For nX := 1 to len(aCpoNivel)

					nCont++

					If aCpoNivel[nX][11] == "V"
						aCols[nAcols][nCont] := CriaVar(aHeader[nX][2],.T.)
					Else
						aCols[nAcols][nCont] := &("RB6->" + aCpoNivel[nX][3])
					Endif

				Next nX

				// Campos AGRUPADOS
				For nX := 1 to nFaixas

					For nY := 1 to len(aCpoFaixa)

						If nTpVl == 1   // Valores Exatos

							nCont++

							aCols[nAcols][nCont] := &("RB6->" + aCpoFaixa[nY][3])

						Else   // Por Intervalo

							If "RB6_VALOR" $ aCpoFaixa[nY][3]

								nCont++		// Faixa De

								aCols[nAcols][nCont] := &("RB6->" + aCpoFaixa[nY][3])

								DbSkip()

								nCont++		// Faixa Ate

								aCols[nAcols][nCont] := &("RB6->" + aCpoFaixa[nY][3])

							Else

								nCont++

								aCols[nAcols][nCont] := &("RB6->" + aCpoFaixa[nY][3])

							Endif

						Endif

					Next nY

					DbSkip()

				Next nX

				aCols[nAcols][nUsado+1] := .F.

				cNivel := RB6->RB6_NIVEL

			Enddo

		Enddo

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Inclusao														³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Else

		Do Case
			Case nQual == 1	// Informada
				nNiveis := 1
			Case nQual == 2	// Calculada
				aPontos := Cs070Ptos()
				nNiveis := len(aPontos)
		EndCase

		cSeqNiv := StrZero(0,Len(RB6->RB6_NIVEL))	//Pre-requisito para Soma1: definicao do tamanho do campo
		For nI := 1 to nNiveis

				Aadd(aCols,Array(nUsado+1))
				nAcols := Len(aCols)
				nCont  := 0

				// Campos NAO AGRUPADOS
				For nX := 1 to len(aCpoNivel)

					nCont++

				    If ( "RB6_NIVEL" $ aCpoNivel[nX][3] )

						cSeqNiv := Soma1(cSeqNiv)	//Cria niveis superior a 99
						aCols[nAcols][nCont] := cSeqNiv
						aAdd( aNiveis , { nI , aCols[nAcols][nCont]} )	//1-Sequencia original,Sequencia do Soma1

				    ElseIf ( "RB6_PTOMIN" $ aCpoNivel[nX][3] ) .and. ( nQual == 2 )

						If 	nPtos == 2 .And. nTpVl == 1		// Ptos por faixa e tipo exato
							aCols[nAcols][nCont] := aPontos[nMin][2]
							nMin ++
		    			Else
							aCols[nAcols][nCont] := aPontos[nI][2]
						EndIf

				    ElseIf ( "RB6_PTOMAX" $ aCpoNivel[nX][3] ) .and. ( nQual == 2 )

						If 	nPtos == 2 .And. nTpVl == 1		// Ptos por faixa e tipo exato
							aCols[nAcols][nCont] := aPontos[nMax][3]
							nMax++
						Else
							aCols[nAcols][nCont] := aPontos[nI][3]
						EndIf

					Else

						If nCont <= Len(aHeader)
							aCols[nAcols][nCont] := CriaVar(aHeader[nCont][2],.T.)
						EndIf

					Endif

				Next nX

				// Campos AGRUPADOS
				For nX := 1 to nFaixas

					For nY := 1 to len(aCpoFaixa)

						If nTpVl == 1   // Valores Exatos

							nCont++

							If nCont <= Len(aHeader)
								aCols[nAcols][nCont] := CriaVar(aHeader[nCont][2],.T.)
							EndIf

						Else   // Por Intervalo

							nCont++

							If nCont <= Len(aHeader)
								aCols[nAcols][nCont] := CriaVar(aHeader[nCont][2],.T.)
							EndIf

							If "RB6_VALOR" $ aCpoFaixa[nY][3]

								nCont++

								If nCont <= Len(aHeader)
									aCols[nAcols][nCont] := CriaVar(aHeader[nCont][2],.T.)
								EndIf

							Endif

						Endif

					Next nY

				Next nX

				aCols[nAcols][nUsado+1] := .F.

		Next nI

	EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Rotina Automática														³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Else
	For nX := 1 To Len(aAutoItens)
   		Aadd(aCols,Array(nUsado+1))

   		For nY := 1 To nUsado
   			nPos	:= Ascan(aAutoItens[1],{|aValorItem | Alltrim(aValorItem[1]) == AllTrim(aHeader[nY,2])})
   			If nPos > 0
   				aCols[nX,nY]	:= aAutoItens[nX,nPos,2]
   			EndIf
   		Next nY
   		aCols[nX, nUsado+1] := .F.
	Next nX
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Campos ³ Autor ³ Kelly Soares        ³ Data ³ 07.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna array com os campos do RB6 contidos no SX3          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Campos(aCpoNivel,aCpoFaixa)

Local nX
Local nRegs	    := 0
Local nCont		:= 0
Local cOrdem	:= ""
Local cTab      := "RB6"
Local lGrupo	:= .F.
Local nInt		:= 0
Local aCampos   := {}

Local aGrupo    := { "RB6_COEFIC" , "RB6_VALOR" }

Local aGrupoAux := {}

// Carrega campos que deverao ser agrupados junto com Coeficiente e Valor ( parametro MV_CPOFAI )
If ( !Empty(cCpoFaixa) , aGrupoAux := StrTokArr(cCpoFaixa,",") , NIL )

// Junta campos do parametro com COEFICENTE e VALOR
nRegs := len(aGrupoAux)
If nRegs > 0
	For nX := 1 to nRegs
		aAdd( aGrupo , aGrupoAux[nX] )
	Next nX
Endif

If nUsaPto != 1 // inibe pontos se optou por nao utilizar
	aAdd( aNaoUtil , "RB6_PTOMIN" )
	aAdd( aNaoUtil , "RB6_PTOMAX" )
ElseIf nPtos == 2  // Pontos por Faixa
	aAdd( aGrupo , "RB6_PTOMIN" )
	aAdd( aGrupo , "RB6_PTOMAX" )
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cTab)
While !Eof() .and. SX3->X3_ARQUIVO == cTab

	If !lExecAuto
		lGrupo := Ascan( aGrupo , { |x| x == AllTrim(SX3->X3_campo) } ) > 0

		// Array de campos agrupados deve comecar pelos campos inclusos pelo usuario,
		// e na sequencia os campos COEFICIENTE, VALOR, PONTO MIN E MAX

		If ( "RB6_COEFIC" $ SX3->X3_campo )
			cOrdem := "96"
		Elseif ( "RB6_VALOR" $ SX3->X3_campo )
			cOrdem := "97"
		Elseif ( "RB6_PTOMIN" $ SX3->X3_campo ) .and. ( nPtos == 2 )
			cOrdem := "98"
		Elseif ( "RB6_PTOMAX" $ SX3->X3_campo ) .and. ( nPtos == 2 )
			cOrdem := "99"
		Elseif lGrupo
			nCont++
			cOrdem := StrZero(nCont,2)
		Endif

		// Com excecao dos NAO UTILIZADOS, adiciona os campos do SX3 nas arrays aCpoFaixa - "agrupados" e aCpoNivel - "nao agrupados"

		If Ascan( aNaoUtil , { |x| x == AllTrim(SX3->X3_campo) } ) == 0 ;
		.And. x3uso(x3_usado) .AND. cNivel >= x3_nivel

			aAdd( If ( lGrupo , aCpoFaixa , aCpoNivel ) 		, ;
					 { If ( lGrupo , cOrdem , SX3->X3_ordem )	, ; //[1]
	 			       TRIM(X3Titulo())							, ; //[2]
				       SX3->X3_campo							, ; //[3]
				       SX3->X3_picture							, ; //[4]
				       SX3->X3_tamanho							, ; //[5]
				       SX3->X3_decimal							, ; //[6]
				       SX3->X3_valid							, ; //[7]
				       SX3->X3_usado							, ; //[8]
				       SX3->X3_tipo								, ; //[9]
				       SX3->X3_f3								, ; //[10]
				       SX3->X3_context 							} ) //[11]

		Endif
	Else
		For nInt := 1 To Len(aAutoItens[1])

			If  Alltrim(aAutoItens[1,nInt,1]) == AllTrim(SX3->X3_campo) .And.;
				x3uso(x3_usado) .AND. cNivel >= x3_nivel

				If ( "RB6_COEFIC" $ AllTrim(aAutoItens[1,nInt,1]) )
					cOrdem := "96"
					lGrupo	:= .T.
				Elseif ( "RB6_VALOR" $ AllTrim(aAutoItens[1,nInt,1]) )
					cOrdem := "97"
					lGrupo	:= .T.
				Elseif ( "RB6_PTOMIN" $ AllTrim(aAutoItens[1,nInt,1]) )
					cOrdem := "98"
					lGrupo	:= .T.
				Elseif ( "RB6_PTOMAX" $ AllTrim(aAutoItens[1,nInt,1]) )
					cOrdem := "99"
					lGrupo	:= .T.
				Else
					lGrupo	:= .F.
				EndIf                                          (

				aAdd( If ( lGrupo , aCpoFaixa , aCpoNivel ) 		, ;
						 { If ( lGrupo , cOrdem , SX3->X3_ordem )	, ; //[1]
		 			       TRIM(X3Titulo())							, ; //[2]
					       Alltrim(SX3->X3_campo)					, ; //[3]
					       SX3->X3_picture							, ; //[4]
					       SX3->X3_tamanho							, ; //[5]
					       SX3->X3_decimal							, ; //[6]
					       SX3->X3_valid							, ; //[7]
					       SX3->X3_usado							, ; //[8]
					       SX3->X3_tipo								, ; //[9]
					       SX3->X3_f3								, ; //[10]
					       SX3->X3_context 							} ) //[11]

				Exit
			Endif
		Next nInt
	EndIf

	DbSkip()

Enddo

// Ordena cada array pelo campo ORDEM
aSort( aCpoNivel ,,, {|x,y| x[1] < y[1] } )
aSort( aCpoFaixa ,,, {|x,y| x[1] < y[1] } )

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs070Soma   ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que soma os acols da Getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs070Soma (nExp1,aExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nUsado : Tamanho do aheader                                 ³±±
±±³          ³aFaixa : Array com as faixas da tabela salarial             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Soma(nUsado,cNivel1,aFaixa,aDados,nTipo,cClasse,cDesClas)

Local nAcols 	:= 0
Local nFaixa 	:= 0
Local nCoefic	:= 0
Local nPos		:= 0
Local nCntFor	:= 0
Local nPosNiv 	:= GdFieldPos("RB6_NIVEL")
Local nPosClas	:= GdFieldPos("RB6_CLASSE")
Local nPosDClas	:= GdFieldPos("RB6_DESCLA")
Local nPosCoef 	:= GdFieldPos("RB6_COEFIC")

Aadd(aCols,Array(nUsado+1))
nAcols := Len(aCols)

For nCntFor := 1 To Len(aHeader)

	If "FAIXA" $ UPPER(aHeader[nCntFor][1]	)
		nFaixa ++
		nPos := Ascan(aFaixa,{|x| x[1] == StrZero(nFaixa,2)})
		If 	nPos > 0
			aCols[nAcols][nCntFor]:= aFaixa[nPos][2]
		EndIf
	ElseIf ( Alltrim(aHeader[nCntFor][2]) == "RB6_PTOMIN" ) .and. ( nUsaPto == 1 )
		If 	nTipo == 1
			aCols[nAcols][nCntFor] := aDados[1][2]
		Else
			nPos := Ascan(aDados,{|x| x[4] == StrZero(nFaixa,2)})
			If 	nPos > 0
				aCols[nAcols][nCntFor]:= aDados[nPos][2]
			EndIf
		EndIf
	ElseIf ( Alltrim(aHeader[nCntFor][2]) == "RB6_PTOMAX" ) .and. ( nUsaPto == 1 )
		If 	nTipo == 1
			aCols[nAcols][nCntFor] := aDados[1][3]
		Else
			nPos := Ascan(aDados,{|x| x[4] == StrZero(nFaixa,2)})
			If 	nPos > 0
				aCols[nAcols][nCntFor]:= aDados[nPos][3]
			EndIf
		EndIf
	ElseIf ( Alltrim(aHeader[nCntFor][2]) == "RB6_COEFIC" )
		nCoefic ++
		nPos := Ascan(aFaixa,{|x| x[1] == StrZero(nCoefic,2)})
		If 	nPos > 0
			aCols[nAcols][nCntFor]:= aFaixa[nPos][3]
		EndIf
	EndIf

Next nCntFor

aCols[nAcols][nPosNiv] 		:= cNivel1
aCols[nAcols][nPosClas]		:= cClasse
aCols[nAcols][nPosDClas]	:= cDesClas

aCols[nAcols][nUsado+1] 	:= nOpcx == 5

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRb6Grava   ³ Autor ³ Cristina Ogura      ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os dados da Tabela Salarial                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³fRB6Grava(nOpc)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRB6Grava(lRecalc)

Local aArea		:= GetArea()

Local nX
Local nY
Local nZ
Local nAux		:= 0
Local nCont		:= 0
Local nPos		:= 0
Local nPosNiv 	:= GdFieldPos("RB6_NIVEL")
Local nPosFxa 	:= GdFieldPos("RB6_FAIXA")
Local nVezes	:= 0
Local cNivel	:= ""
Local cFaixa    := ""
Local cNivNovo	:= ""
Local cNivAnt	:= ""
Local cTitulo	:= ""
Local cCampo	:= ""
Local aCampos	:= {}
Local lAntiga	:= .F.
Local lFound	:= .F.
Local lVirtual	:= .F.
Local nNiv		:= 0
Local aColsAux	:= {}
Local lGrava	:=	.F.
Local cVDFFXSL	:= ""
Local cFaixa	:= ""

//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA070",.T.,,.T.)

If nTpVl == 2 .And. nOpcx == 3
	nVezes := nNrFaixa * 2
Else
	nVezes := nNrFaixa
EndIf

DbSelectArea("RB6")
DbSetOrder(1)

Begin Transaction
//-- Tratamento quando usar historico de tabela salarial para apagar o conteudo do campo RB6_ATUAL
//-- das versoes anteriores da tabela p/ indicar que os valores dessa tabela nao serao mais usados
If lHistorico .And. nOpcx == 4
	If dbSeek(xFilial("RB6")+RBR->RBR_TABELA)
		While !EoF() .And. RB6->RB6_FILIAL+RB6->RB6_TABELA == xFilial("RB6")+RBR->RBR_TABELA
			If RB6->RB6_DTREF <= RBR->RBR_DTREF
				RecLock("RB6", .F.)
				RB6->RB6_ATUAL := " "
				RB6->( MsUnlock() )
			Else
				lAntiga := .T.
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf


If !lExecAuto
	For nX := 1 To Len(oGet:aCols)

		aCampos := {}
		cVDFFXSL:= Getmv("MV_VDFFXSL",,"01")
		cFaixa  := "00"

		//--Verifica se nao esta deletado no aCols
		If !oGet:aCols[nX][Len(oGet:aCols[nX])]

			// Guarda o nivel para posteriormente utiliza-lo na chave
			cNivel := oGet:aCols[nX][nPosNiv]

			aAdd( aNiveis , { nX , cNivel} )	//1-Sequencia original,Sequencia do Soma1

			// Para cada faixa ...
	        For nY := 1 to nVezes

				If cNivel <> cNivAnt
					nCont := 0
					nAux  := 0
				Endif

		       	If lGestPubl .and. nTpVl <> 2			//Gestao Publica e nao for por intervalo
	    	        cFaixa 			:= padr(cVDFFXSL,2)	//Troca numerico por alfanumerico
	        	    cVDFFXSL		:= Soma1(cVDFFXSL,2)
	        	Else
	          		cFaixa			:= soma1(cFaixa)
	          	Endif

				If nOpcx == 3
					lFound := .T.
				Else

				// Nao sendo inclusao, verifica se mantem historico para gerar
				// novos registros ao enves de alterar os originais

					If lHistorico
						dbSelectArea("RB6")
						dbSetOrder(3)
						If dbSeek(xFilial("RB6")		+ ; // Filial
						          RBR->RBR_TABELA		+ ; // Tabela
						          DTOS(RBR->RBR_DTREF)	+ ; // Data Referencia
						          cNivel				+ ;	// Nivel
						          cFaixa)					// Faixa
							lFound := .F.
						Else
							lFound := .T.
						EndIf
		            Else
						dbSelectArea("RB6")
						dbSetOrder(1)
						If dbSeek(xFilial("RB6")		+;	// Filial
						          RBR->RBR_TABELA		+;	// Tabela
						          cNivel				+;	// Nivel
						          cFaixa)					// Faixa
							lFound := .F.
						Else
							lFound := .T.
						EndIf
		            Endif

		    	Endif

				RecLock("RB6",lFound)

				If ( Mod(nY,2) > 0	, nCont ++ , NIL )

				// Grava campos AGRUPADOS
				For nZ := 1 to len(aCpoFaixa)

					cCampo   := aCpoFaixa[nZ][3]

					If nTpVl == 1  // Valores Exatos

						If "RB6_VALOR" $ cCampo
							cTitulo := oEmToAnsi(STR0065) + " " + cFaixa
						Else
							cTitulo := aCpoFaixa[nZ][2] + " " + cFaixa
						Endif
						cVirtual := aHeader[GdFieldPos(cCampo)][10]
						If cVirtual != "V"
							nPos := Ascan( aHeader , { |x| x[1] = cTitulo } )
							If nPos > 0
								lGrava	:=	fVerDec(@oGet:aCols[nX , nPos] , aCpoFaixa[nZ , 4] , aCpoFaixa[nZ , 5])
								If ( lGrava )
									&("RB6->"+cCampo) := oGet:aCols[nX][nPos]
								Else
						   	  		Help("",1,"TAMANVALOR")
									DisarmTransaction()
									Return .F.
								Endif
							Endif
						Endif

					Else  // Por Intervalo

						If Mod(nY,2) > 0	// Faixa De

							If "RB6_VALOR" $ cCampo
								nAux++
								cTitulo := oEmToAnsi(STR0019) + ' ('+cValToChar(nAux)+')'
							Else
								cTitulo := aCpoFaixa[nZ][2]+ " " + Strzero(nCont,2)
							Endif

						Else				// Faixa Ate

							If "RB6_VALOR" $ cCampo
								nAux++
								cTitulo := oEmToAnsi(STR0020) + ' ('+cValToChar(nAux)+')'
							Else
								cTitulo := aCpoFaixa[nZ][2]+ " " + Strzero(nCont,2)
							Endif

						Endif

						cVirtual := aHeader[GdFieldPos(cCampo)][10]
						If cVirtual != "V"
							nPos := Ascan( aHeader , { |x| Upper(x[1]) == Upper(cTitulo) } )
							If nPos > 0
								If ( lGrava	:=	fVerDec(@oGet:aCols[nX , nPos] , aCpoFaixa[nZ , 4] , aCpoFaixa[nZ , 5]) )
									&("RB6->"+cCampo) := oGet:aCols[nX][nPos]
								Else
						   	  		Help("",1,"TAMANVALOR")
									DisarmTransaction()
									Return .F.
								Endif
							Endif
						Endif

	                Endif

				Next nZ

				// Grava campos NAO AGRUPADOS
				For nZ := 1 to len(aCpoNivel)

					cCampo   := aCpoNivel[nZ][3]
					cVirtual := aHeader[GdFieldPos(cCampo)][10]
					If ( (cVirtual != "V") .AND. (lGrava :=	fVerDec(@oGet:aCols[nX][GdFieldPos(cCampo)] , aCpoNivel[nZ , 4] , aCpoNivel[nZ , 5])) )
						&("RB6->"+cCampo) := oGet:aCols[nX][GdFieldPos(cCampo)]
					Endif

				Next nZ

				// Grava campos da array aNaoUtil
				RB6->RB6_FILIAL		:= xFilial("RB6")
				RB6->RB6_TABELA 	:= RBR->RBR_TABELA
	   	        RB6->RB6_DESCTA 	:= RBR->RBR_DESCTA
	       	    RB6->RB6_TIPOVL 	:= RBR->RBR_TIPOVL
	       		RB6->RB6_FAIXA		:= cFaixa
	            RB6->RB6_DTREF    	:= RBR->RBR_DTREF
				RB6->RB6_NIVEL		:= cNivel

				If !lAntiga
		            RB6->RB6_ATUAL 		:= "1"
		  		EndIf

	            cNivAnt := oGet:aCols[nX][nPosNiv]

				RB6-> ( MsUnlock() )

			Next nY

		ElseIf nOpcx == 4	// Alteracao

			cNivel := oGet:aCols[nX][nPosNiv]

			dbSelectArea("RB6")
			dbSetOrder(1)

			lChkDelOk  := ChkDelRegs("RB6"	,;	//01 -> Alias do Arquivo Principal
								Nil		,;	//02 -> Registro do Arquivo Principal
								Nil		,;	//03 -> Opcao para a AxDeleta
								Nil		,;	//04 -> Filial do Arquivo principal para Delecao
								Nil		,;	//05 -> Chave do Arquivo Principal para Delecao
								Nil		,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								Nil		,;	//07 -> Mensagem para MsgYesNo
								Nil		,;	//08 -> Titulo do Log de Delecao
								Nil 	,;	//09 -> Mensagem para o corpo do Log
								Nil	 	,;	//10 -> Se executa AxDeleta
								Nil		,;	//11 -> Se deve Mostrar o Log
								Nil		,;	//12 -> Array com o Log de Exclusao
								Nil		,;	//13 -> Array com o Titulo do Log
								Nil		,;	//14 -> Bloco para Posicionamento no Arquivo
								Nil		,;	//15 -> Bloco para a Condicao While
								Nil		,;	//16 -> Bloco para Skip/Loop no While
								.T.		,;	//17 -> Verifica os Relacionamentos no SX9
								Nil  	;	//18 -> Alias que nao deverao ser Verificados no SX9
						    )

			If !lChkDelOk
				DisarmTransaction()
				Return Nil
			Endif

			If lHistorico
				dbSetOrder(3)
				cChave	:= xFilial("RB6")+RBR->RBR_TABELA+DTOS(RBR->RBR_DTREF)+cNivel
				cCampos	:= "RB6->RB6_FILIAL+RB6->RB6_TABELA+DTOS(RB6->RB6_DTREF)+RB6->RB6_NIVEL"
			Else
				cChave := xFilial("RB6")+RBR->RBR_TABELA+cNivel
				cCampos	:= "RB6->RB6_FILIAL+RB6->RB6_TABELA+RB6->RB6_NIVEL"
			Endif

			If dbSeek(cChave)
				While !Eof() .And. cChave == &cCampos
					If RecLock("RB6",.F.)
						dbDelete()
						MsUnlock()
					EndIf
					dbSkip()
				EndDo
			EndIf
		EndIf

	Next nX

	// Renumera os niveis
	cNivel := ""
	For nX := 1 To Len(oGet:aCols)
		If !oGet:aCols[nX][Len(oGet:aCols[nX])]

			If cNivel != oGet:aCols[nX][nPosNiv]
				cNivel := oGet:aCols[nX][nPosNiv]

				If ( nNiv := aScan(aNiveis, {|x| x[1] == nX }) ) <> 0
					cNivNovo:= aNiveis[nNiv][2]
				EndIf

			EndIf

			If  cNivNovo != cNivel

				dbSelectArea("RB6")
				If lHistorico
					dbSetOrder(3)
					cChave	:= xFilial("RB6")+RBR->RBR_TABELA+DTOS(RBR->RBR_DTREF)+cNivel
				Else
					dbSetOrder(1)
					cChave := xFilial("RB6")+RBR->RBR_TABELA+cNivel
				Endif

				While .T.
					If dbSeek(cChave)
						RecLock("RB6",.F.)
					       	Replace RB6->RB6_NIVEL 	WITH  cNivNovo
						MsUnlock()
					Else
						Exit
		    	    EndIf
				EndDo
			EndIf
		EndIf
	Next nX

	//nTpVl == 1 Seleciona valores exatos os demais sistemas não estão preparados para atender valores por intervalo
	If lIntegDef  .AND. nTpVl == 1
		// chamada da função integdef
		FwIntegDef('CSAA070')
	EndIf
Else
	For nX := 1 To Len(aCols)
		If nOpcx == 3
			lFound := .T.
		Else
			cNivel 	:= aCols[nX,nPosNiv]
			cFaixa	:= aCols[nX,nPosFxa]
			// Nao sendo inclusao, verifica se mantem historico para gerar
			// novos registros ao enves de alterar os originais
			If lHistorico
				dbSelectArea("RB6")
				dbSetOrder(3)
				If dbSeek(xFilial("RB6")		+ ; // Filial
				          RBR->RBR_TABELA		+ ; // Tabela
				          DTOS(RBR->RBR_DTREF)	+ ; // Data Referencia
				          cNivel				+ ;	// Nivel
				          cFaixa)	   				// Faixa
					lFound := .F.
				Else
					lFound := .T.
				EndIf
	        Else
				dbSelectArea("RB6")
				dbSetOrder(1)
				If dbSeek(xFilial("RB6")		+;	// Filial
				          RBR->RBR_TABELA		+;	// Tabela
				          cNivel				+;	// Nivel
				          cFaixa)					// Faixa
					lFound := .F.
				Else
					lFound := .T.
				EndIf
	   		Endif
	    Endif

	    RecLock("RB6",lFound)

	    	// Grava campos NAO AGRUPADOS
			For nZ := 1 to len(aCpoFaixa)
				cCampo   := aCpoFaixa[nZ][3]
				cVirtual := aHeader[GdFieldPos(cCampo)][10]
				If cVirtual != "V"
					&("RB6->"+cCampo) := aCols[nX][GdFieldPos(cCampo)]
				Endif
			Next nZ

		    // Grava campos NAO AGRUPADOS
			For nZ := 1 to len(aCpoNivel)
				cCampo   := aCpoNivel[nZ][3]
				cVirtual := aHeader[GdFieldPos(cCampo)][10]
				If cVirtual != "V"
					&("RB6->"+cCampo) := aCols[nX][GdFieldPos(cCampo)]
				Endif
			Next nZ

			// Grava campos da array aNaoUtil
			RB6->RB6_FILIAL		:= xFilial("RB6")

			If !lAntiga
		 		RB6->RB6_ATUAL 		:= "1"
		  	EndIf

		RB6-> ( MsUnlock() )
	Next nX

	//nTpVl == 1 Seleciona valores exatos os demais sistemas não estão preparados para atender valores por intervalo
	//!lExAutMU A mensagem unica utiliza ExecAuto para inserir um registro, porem se ele esta inserindo não a
	//necessidade de enviar o mesmo cadastro para ser inserido no sistema externo.
	If lIntegDef  .AND. nTpVl == 1 .AND. !lExAutMU
    	// chamada da função integdef
		FwIntegDef('CSAA070')
	EndIf
EndIf
RestArea(aArea)

END TRANSACTION
MsUnlockAll()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Ok  ³ Autor ³ Kelly Soares          ³ Data ³ 30.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a linha Ok na getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Ok( oBrowse )

Local aCoefic := {}
Local aFaixas := {}
Local nX      := 0
Local nY   	  := 0
Local nLin 	  := If( Type("oGet:oBrowse") == "U", n, oGet:oBrowse:nAt)
Local nTam 	  := Len(oGet:aHeader)
Local nNiv	  := aScan( oGet:aHeader, { |x| x[2] == "RB6_NIVEL " } )

//--Verifica se foram informados os valores de todas as faixas do nivel
For nX := 1 to nTam
	If ( ALLTRIM(oGet:aHeader[nX][2]) == "RB6_VALOR" )
		nY++
		If Empty(oGet:aCols[nLin][nX])
			Alert(oEmToAnsi(STR0061)+AllTrim(Str(nY))+".")
			Return .F.
		Endif
	EndIf
Next nX

//--Se for tabela por intervalos, guarda a posicao no aCols de todos os coeficientes
If nTpVl == 2
	For nX := 1 to nTam
		If ( ALLTRIM(oGet:aHeader[nX][2]) == "RB6_VALOR" )
			aAdd( aFaixas, nX )
		EndIf
	Next nX

	//--Valida as faixas
	For nX := Len(aFaixas) To 1 Step - 2
		If nX > 1 .And. oGet:aCols[nLin][aFaixas[nX]] <= oGet:aCols[nLin][aFaixas[nX-1]]
		    Alert(OemToAnsi(STR0094) + AllTrim(Str(nX)) + OemToAnsi(STR0095) + AllTrim(Str(nX-1)) + "." )//"O valor da Faixa "##" deve ser maior do que a Faixa "
		    Return .F.
		EndIf
	Next nX
EndIf

//--Guarda a posicao no aCols de todos os coeficientes
For nX := 1 to nTam
	If ( ALLTRIM(oGet:aHeader[nX][2]) == "RB6_COEFIC" )
		aAdd( aCoefic, nX )
	EndIf
Next nX

//--Valida os coeficientes
For nX := Len(aCoefic) To 1 Step - 1
	If nX > 1 .And. oGet:aCols[nLin][aCoefic[nX]] <= oGet:aCols[nLin][aCoefic[nX-1]]
	    Alert(OemToAnsi(STR0096) + AllTrim(Str(nX)) + OemToAnsi(STR0097) + AllTrim(Str(nX-1)) + "." )//"O valor do Coeficiente "##" deve ser maior do que o Coeficiente "
	    Return .F.
	EndIf
Next nX

If Len(oGet:aCols[nLin,1]) > oGet:aHeader[nNiv,4]
    Alert(OemToAnsi(STR0100) )//"O número de faixas cadastradas excedeu o limite de cadastro. Peça ao administrador do sistema para efetuar aumento do tamanho do campo RB6_NIVEL."
    Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Tab ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a tabela a ser incluida ja existe e nao esta   ³±±
±±³          ³ vazio.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Tab(cVar)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Tab(cVar)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If 	Empty(cVar)
	Help("",1,"CS070TABVAZ")
	lRet := .F.
EndIf

dbSelectArea("RBR")
dbSetOrder(1)
If 	lRet .And. dbSeek(xFilial("RBR")+cVar)
	Help("",1,"CS070JAEXI")			// Tabela ja existe
	lRet := .F.
EndIf

If lRet .And. !FreeForUse("RBR",cVar)
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070PtoMax ³ Autor ³ Cristina Ogura     ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os pontos maximo e' maior que os minimos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Tab(cVar)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070PtoMax()

Local cVar := &(ReadVar())

If M->RB6_PTOMIN > cVar
	Help("",1,"Cs070PONTOS")		// Pontos maximo esta menor que os minimos
	Return .F.
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Ptos   ³ Autor ³ Cristina Ogura     ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcular o maior e menor pontos do grupo selecionado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Tab(cVar)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Ptos()

Local aSaveArea	:= GetArea()

Local aAux		:= {}
Local nAux		:= 0
Local nMenor	:= 0
Local nMaior	:= 0
Local nCoefic	:= 0
Local cFilSQ3   := ""
Local nAuxNivel	:= 0
Local nx		:= 0

dbSelectArea("SQ3")
cFilSQ3 := If (cFilial = space(FWGETTAMFILIAL), space(FWGETTAMFILIAL), cFilial)
dbSetOrder(2)
dbSeek(cFilSQ3+mv_par01,.T.)
While !Eof() .And. cFilSQ3 == SQ3->Q3_FILIAL .And. SQ3->Q3_GRUPO <= mv_par02

	Aadd(aAux,SQ3->Q3_PONTOSI)

	dbSkip()
EndDo

aSort(aAux,,,{ |x,y| x < y })

If 	Len(aAux) <= 0
	nMenor := 0
	nMaior := 0
Else
	nMenor := aAux[1]
	nMaior := aAux[Len(aAux)]
EndIf

If nPtos == 2 .And. nTpVl == 1 	// Pontos por Faixa	e for exatos
	nAuxNivel := INT(nNrNivel * nNrFaixa)
Else
	nAuxNivel := nNrNivel
EndIf

If nMenor != 0 .And. nNrNivel != 0
	nCoefic := Round((nMaior/nMenor) ^ (1/nAuxNivel),2)
Else
	nCoefic := 1
EndIf

aAux :={}
For nx := 1 To nAuxNivel -1
	nPtoMin := nMenor
	nPtoMax := INT(nMenor * nCoefic)
	Aadd(aAux,{nx,nPtoMin,nPtoMax})
	nMenor  := nPtoMax
Next nx

Aadd(aAux,{nAuxNivel,nMenor,nMaior})

RestArea(aSaveArea)

Return aAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Alter  ³ Autor ³ Emerson G. Rocha   ³ Data ³ 19/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array com campos que podem ser alterados.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Alter()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Alter(aAlter,lTravaVlr)

Local aSaveArea	:= GetArea()
Local cCampos	:= ""

cCampos := "RB6_NIVEL"
If nOpcx == 4 .and. lTravaVlr
	cCampos += "/RB6_COEFIC/RB6_VALOR"
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RB6")
While !Eof() .And. (X3_ARQUIVO == "RB6")
	If  !( ALLTRIM(X3_CAMPO) $ cCampos )
		Aadd(aAlter,X3_CAMPO)
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Autom  ³ Autor ³ Emerson G. Rocha   ³ Data ³ 29/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche automaticamento os valores na Tabela.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Autom()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs070Autom(nOpc)

Local aSaveArea	:= GetArea()
Local aKeys		:= GetKeys()
Local nOpcao	:= 0
Local oDlg
Local oFont

//Variaveis Amplitude
Local oGroupA
Local nValorA	:= 0
Local oRadioA
Local nRadioA 	:= 1
Local bBlockA 	:= {|| Nil }
Local bClickA 	:= {|| Nil }

//Variaveis Progressao
Local oGroupP
Local nValorP	:= 0
Local oRadioP
Local nRadioP 	:= 1
Local bBlockP 	:= {|| Nil }
Local bClickP 	:= {|| Nil }

// Variaveis de Calculo
Local nPriVal	:= 0
Local nNiv		:= 0
Local nFai		:= 0
Local nFx		:= 0
Local nValor	:= 0
Local nPriAnt	:= 0
Local nTamCpo 	:= TAMSX3("RB6_COEFIC")[1]
Local nTamDec 	:= TAMSX3("RB6_COEFIC")[2]
Local nTamInt	:= nTamCpo - ( nTamDec + 1 )
Local aSvCols 	:= {}
Local oGrouPri
Local oGetVal
Local oGrouTip

Local oRadioTip
Local nRadioTip := 1
Local bBlockTip := {|| Nil }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv21Size		:= {}
Local aInfo21AdvSize	:= {}
Local aObj21Size		:= {}
Local aObj21Coords	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local aAdv31Size		:= {}
Local aInfo31AdvSize	:= {}
Local aObj31Size		:= {}
Local aObj31Coords	:= {}

// Objetos de Valores
Private oGetA
Private oGetP

// Visualizacao / Exclusao
If nOpc == 2 .Or. nOpc == 5
	Return Nil
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//Divisao Tela em 2 linhas
aAdvSize		:= MsAdvSize(,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

//Divisao da Linha 1 em duas colunas
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

//Para centralizacao na vertical dos objetos da Linha 2
aAdv2Size		:= aClone(aObjSize[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords )

//Para centralizacao na vertical dos objetos da Linha 1
aAdv21Size		:= aClone(aObjSize[1])
aInfo21AdvSize	:= { aAdv21Size[2] , aAdv21Size[1] , aAdv21Size[4] , aAdv21Size[3] , 5 , 5 }
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj21Coords , { 000 , 046 , .T. , .F. } )
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )
aObj21Size		:= MsObjSize( aInfo21AdvSize , aObj21Coords )


//Para centralizacao dos objetos da Coluna 1
aAdv3Size		:= aClone(aObj1Size[1])
aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 5 }
aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj3Coords , { 060 , 000 , .F. , .T. } )
aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )
aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. )

//Para centralizacao dos objetos da Coluna 2
aAdv31Size		:= aClone(aObj1Size[2])
aInfo31AdvSize	:= { aAdv31Size[2] , aAdv31Size[1] , aAdv31Size[4] , aAdv31Size[3] , 5 , 5 }
aAdd( aObj31Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj31Coords , { 060 , 000 , .F. , .T. } )
aAdd( aObj31Coords , { 000 , 000 , .T. , .T. } )
aObj31Size		:= MsObjSize( aInfo31AdvSize , aObj31Coords,,.T. )


DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

// Amplitude
	@ aObjSize[1,1], aObj1Size[1,2] GROUP oGroupA TO aObjSize[1,3], aObj1Size[1,4] LABEL OemToAnsi(STR0029) OF oDlg PIXEL	// "Amplitude"
	oGroupA:oFont:= oFont
	bBlockA	:= { |x| If(ValType(x)=='U', nRadioA , nRadioA := x ) }
	bClickA := { || oGetA:Picture := Cs070Pict(nRadioA), oGetA:Refresh() }
	oRadioA	:= TRadMenu():New( aObj21Size[2,1], aObj3Size[2,2], {STR0027, STR0028},bBlockA, oDlg,,bClickA,,,,,,80,10 )	//"Valor"###"Percentual"
	nRadioA	:= oRadioA:nOption
	@ aObj21Size[2,1]+25, aObj3Size[2,2] MSGET oGetA Var nValorA PICTURE Cs070Pict(nRadioA) SIZE 60,10 PIXEL HASBUTTON

 // Primeiro Valor
 	@ aObjSize[2,1], aObj1Size[1,2] GROUP oGrouPri TO aObjSize[2,3], aObj1Size[1,4] LABEL OemToAnsi(STR0031) OF oDlg PIXEL	// "Primeiro Valor"
	oGrouPri:oFont:= oFont
	@ aObj2Size[2,1] , aObj3Size[2,2] MSGET oGetVal Var nPriVal PICTURE PesqPict("RB6","RB6_VALOR") SIZE 60,10 PIXEL HASBUTTON

// Progressao
	@ aObjSize[1,1], aObj1Size[2,2] GROUP oGroupP TO aObjSize[1,3], aObj1Size[2,4] LABEL OemToAnsi(STR0030) OF oDlg PIXEL	// "Progressao"
	oGroupP:oFont:= oFont
	bBlockP	:= { |x| If(ValType(x)=='U', nRadioP , nRadioP := x ) }
	bClickP := { || oGetP:Picture := Cs070Pict(nRadioP), oGetP:Refresh() }
	oRadioP	:= TRadMenu():New( aObj21Size[2,1], aObj31Size[2,2], {STR0027, STR0028},bBlockP, oDlg,,bClickP,,,,,,80,10 )	//"Valor"###"Percentual"
	nRadioP	:= oRadioP:nOption
	@ aObj21Size[2,1]+25 , aObj31Size[2,2] MSGET oGetP Var nValorP PICTURE Cs070Pict(nRadioP) SIZE 60,10 PIXEL HASBUTTON

// Ordem Calculo Progressao
   	@ aObjSize[2,1], aObj1Size[2,2] GROUP oGrouTip TO aObjSize[2,3], aObj1Size[2,4] LABEL OemToAnsi(STR0032) OF oDlg PIXEL	// "Na Progressao considerar: "
	oGrouTip:oFont:= oFont
	bBlockTip	:= { |x| If(ValType(x)=='U', nRadioTip , nRadioTip := x ) }
	oRadioTip	:= TRadMenu():New( aObj2Size[2,1], aObj31Size[2,2], {STR0033, STR0034},bBlockTip, oDlg,,,,,,,,80,10 )	//"Primeiro Valor"###"Ultimo Valor"
	nRadioTip	:= oRadioTip:nOption

// EnchoiceBar
	bSet15	:= {|| nOpcao := 1, RestKeys(aKeys,.T.),oDlg:End()}
	bSet24	:= {|| nOpcao := 0, RestKeys(aKeys,.T.),oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

If nOpcao == 1

	Begin Sequence

		M->RBR_VLREF := nPriVal
		nValor		 := nPriVal
		nPriAnt		 := nPriVal
		aSvCols	:= aClone( oGet:aCols )

		For nNiv := 1 To Len(oGet:aCols)

			//Valida o coeficiente e impede a gravacao se ele ultrapassar o limite do campo, e sugere a alteracao do tamanho do campo
			If !fChkCoef(nValor,nPriVal,nTamInt,nNiv)
				oGet:aCols := Array(0)
				oGet:aCols := aClone( aSvCols )
				break
						EndIf

			nFx	:= 0
			For nFai := 1 To Len(aHeader)

				// Amplitude
				If "FAIXA" $ UPPER(aHeader[nFai][1])

					nFx ++
					If nFx > 1
						//Incrementa o valor somente na coluna "DE"
						If nFx % 2 == 0 .Or. ( nTpVl == 1 .Or. nTpVl == 3 )
							If nRadioA == 1 // Valor
								nValor += (nValorA)
							Else  			// Percentual
								nValor += Round( (nValor * nValorA / 100), MsDecimais(1))
					EndIf
						EndIf
					EndIF

					If !fChkCoef(nValor,nPriVal,nTamInt,nNiv)
						oGet:aCols := Array(0)
						oGet:aCols := aClone( aSvCols )
						break
					EndIf

					If nTpVl == 1 .Or. nTpVl == 3 //Exatos
						oGet:aCols[nNiv][nFai]   := nValor
						oGet:aCols[nNiv][nFai-1] := Round(nValor / nPriVal,nTamDec) //grava no aCols com o nr. correto de decimais do campo
					Else
						If nFx % 2 == 1
						oGet:aCols[nNiv][nFai]   := nValor
							oGet:aCols[nNiv][nFai-1] := Round(nValor / nPriVal,nTamDec) //grava no aCols com o nr. correto de decimais do campo
					Else
							//O valor da Faixa "ATE" a partir do elemento 2 deve retirar 0,01 centavo para nao ficar igual ao valor da faixa "DE" subsequente
							//Exemplo: considerando 1000,00 como referencia e uma amplitude de 10% para 3 faixas do mesmo nivel
							//De 1    - Ate 1   - De 2    - Ate 2   - De 3    - Ate 3
							//1000,00 - 1099,99 - 1100,00 - 1209,99 - 1210,00 - 1331,00
							oGet:aCols[nNiv][nFai]   := nValor - If( nFx > 1 .And. nFai <> Len(aHeader), 0.01, 0 )
					EndIf
				EndIf
				EndIf
			Next nFai

			// Progressao
			If nRadioTip == 1 	// Primeiro Valor
	        	nValor := nPriAnt
	  		EndIf
			If nRadioP == 1 // Valor
				nValor += (nValorP)
			Else  			// Percentual
				nValor += Round( (nValor * nValorP / 100), MsDecimais(1))
			EndIf
			nPriAnt := nValor	// Primeiro Valor do Novo Nivel

		Next nNiv
	End Sequence
EndIf

RestArea(aSaveArea)
RestKeys(aKeys,.T.)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Pict   ³ Autor ³ Emerson G. Rocha   ³ Data ³ 29/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Picture a ser utilizada no Campo Valor.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Pict()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs070Pict(nRadio)
Local cPict	:= ""

If nRadio == 2
	cPict := "9999.999"
Else
	cPict := PesqPict("RB6","RB6_VALOR")
EndIf

Return cPict


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CabecOK  ³ Autor ³ Kelly Soares          ³ Data ³ 24.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos da enchoice antes de iniciar o preenchimento ³±±
±±³          ³ da getdados.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CabecOk()

Local cAviso := ""

If Empty(M->RBR_TABELA)
	cAviso	:= oEmToAnsi(STR0052)		// "Campo CODIGO deve ser preenchido."
Endif

If Empty(M->RBR_DESCTA) .and. Empty(cAviso)
	cAviso	:= oEmToAnsi(STR0054)		// "Campo DESCRICAO deve ser preenchido."
Endif

If Empty(M->RBR_DTREF) .and. Empty(cAviso)
	cAviso	:= oEmToAnsi(STR0055)		//"Campo DATA DE REFERENCIA deve ser preenchido."
Endif

If !Empty(cAviso)
	oEnchoice:Setfocus()
	Aviso(oEmToAnsi(STR0024),cAviso,{STR0047})
Endif

Return (Empty(cAviso))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070TOk ³ Autor ³ Kelly Soares          ³ Data ³ 24.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos da tabela RBR                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs070TOk(nOpc)

Local aArea		:= GetArea()
Local nPosNivel	:= GdFieldPos("RB6_NIVEL")
Local nPosValor := GdFieldPos("RB6_VALOR")

//Checking if action is Delete or View, then return True
//Nao processa linha ok quando visualiza ou deleta o registro
If (nOpc == 5 .Or. nOpc == 2)
	Return .T.
Endif

// Verifica se os dados principais da tabela foram informados
If !CabecOk()
	Return .F.
Endif

// Verifica se a tabela ja existe (de mesmo codigo e mesma data)
If nOpc == 3 .and. !Empty(M->RBR_TABELA+DTOC(M->RBR_DTREF))
	DbSelectArea("RBR")
	DbSetOrder(1)
	If DbSeek(xFilial("RBR")+M->RBR_TABELA+DTOS(M->RBR_DTREF))
		Aviso(oEmToAnsi(STR0024),oEmToAnsi(STR0053),{STR0047})	//"Atencao"###"Já existe tabela salarial com o código informado."###"Ok"
		Return .F.
	Endif
Endif

// Verifica se algum nivel foi preenchido
If nPosNivel > 0
	If len(oGet:aCols) == 1 .and. Val(oGet:aCols[1][nPosNivel]) == 0
		Aviso(oEmToAnsi(STR0024),oEmToAnsi(STR0078),{STR0047})	//"Atencao"###"Preencha a tabela antes de salvar."###"Ok"
		Return .F.
	Endif
EndIf

// Preenche o valor de referencia com o valor da 1a faixa caso esteja zerado
If M->RBR_VLREF = 0
	M->RBR_VLREF := Iif(nPosValor > 0,oGet:aCols[1][nPosValor],0)
Endif

If !Cs070Ok()
	Return .F.
EndIf

RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Faixa  ³ Autor ³ Cristina Ogura     ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica quantas faixas existem na tabela                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Faixa(cTabela,dData)

Local aSaveArea	:= GetArea()
Local nQuantos	:= 0
Local cNiv		:= ""

dbSelectArea("RB6")
dbSetOrder(3)
If dbSeek(xFilial("RB6")+cTabela+DTOS(dData))
	cNiv := RB6->RB6_NIVEL
	While !Eof() .And. xFilial("RB6")+cTabela+DTOS(dData)+cNiv ==;
					RB6->RB6_FILIAL+RB6->RB6_TABELA+DTOS(RB6->RB6_DTREF)+RB6->RB6_NIVEL

		nQuantos ++

		dbSkip()
	EndDo
EndIf

RestArea(aSaveArea)

Return nQuantos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Reaj   ³ Autor ³ Kelly Soares       ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para escolha do tipo de reajuste na tabela salarial.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Reaj(nOpc)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs070Reaj(nOpc)

Local aSaveArea	:= GetArea()
Local aKeys		:= GetKeys()

Local oDlg
Local oGroup1, oGroup2, oGroup3
Local oFont1, oFont2
Local oData
Local nOpca		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Private nMarcado	:= 0

Private oDTab
Private cDTabReaj 	:= M->RBR_DESCTA
Private dDataReaj 	:= date()
Private nValReaj	:= M->RBR_VLREF

Private oValRef
Private nValor1		:= 0
Private oRadio1
Private nRadio1		:= 1
Private bBlock1		:= {|| Nil }
Private bClick1		:= {|| Nil }
Private nValor2		:= 0
Private oRadio2
Private nRadio2 	:= 1
Private bBlock2 	:= {|| Nil }
Private bClick2 	:= {|| Nil }
Private oGet2

// Visualizacao / Exclusao
If nOpc == 2 .Or. nOpc == 5
	Return Nil
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize(,.T.,380)
aAdvSize[4]		:=aAdvSize[4]*0.80					//Linha final da Area de Trabalho
aAdvSize[6]		:=aAdvSize[6]*0.85					//Linha final Area Dialogo

aAdvSize[3]		:= aAdvSize[3]*0.8		//Coluna Final Area Trabalho
aAdvSize[5]		:= aAdvSize[5]*0.8		//Coluna Final Dialogo

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 045 , .T. , .F. } )		//1-Cabecalho
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } ) 	//2-Reajuste
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )


//Divisao da linha 2-Reajuste em 2 Linhas
aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )	//1-Reajuste
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } ) 	//2-Itens Niveis e Faixas
aObj1Size	:= MsObjSize( aInfo1AdvSize , aObj1Coords )

DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE oEmToAnsi(STR0070) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

 	// "Tabela Salarial"
 	@ aObjSize[1,1],aObjSize[1,2] GROUP oGroup1	TO aObjSize[1,3],aObjSize[1,4] 		OF oDlg PIXEL
	@ aObjSize[1,1]+10 , aObjSize[1,2]+5 SAY OemtoAnsi(STR0018)		SIZE 045,010 	OF oDlg 	PIXEL 	FONT oFont1
	@ aObjSize[1,1]+8  , aObjSize[1,2]+55 MSGET oDTab Var cDTabReaj	SIZE 115,010 	PIXEL HASBUTTON

	// "Data Referencia"
	@ aObjSize[1,1]+27,aObjSize[1,2]+5 SAY OemtoAnsi(STR0036)	SIZE 045,010 OF oDlg 	PIXEL	FONT oFont1
	@ aObjSize[1,1]+25,aObjSize[1,2]+55 MSGET oData Var dDataReaj	SIZE 050,010 		PIXEL  HASBUTTON

	// "Reajustar"
	// 1 = Alteracao Manual
	// 2 = Valor de Referencia
	// 3 = Niveis e Faixas
	@ aObjSize[2,1],aObjSize[2,2] GROUP oGroup2 TO aObjSize[2,3]+5,aObjSize[2,4] LABEL oEmToAnsi(STR0072) OF oDlg PIXEL
	oGroup2:oFont := oFont2
	bBlock1	:= { |x| If(ValType(x)=='U', nRadio1 , nRadio1 := x ) }
	bClick1	:= { || Habilita(nRadio1) }
	oRadio1	:= TRadMenu():New( aObjSize[2,1]+10,aObjSize[2,2]+5, {STR0091, STR0073, STR0075},bBlock1,oDlg,,bClick1,,,,,,80,15 )	//"Valor de Referencia"###"Faixas"
	nRadio1	:= oRadio1:nOption

	// Valor de Referencia
	@ aObjSize[2,1]+18,aObjSize[2,2]+95 MSGET oValRef Var nValReaj		PICTURE Cs070Pict(1) SIZE 060,010 PIXEL WHEN nRadio1 == 2  HASBUTTON

	// Niveis e Faixas
	@ aObj1Size[2,1]+5,aObj1Size[2,2] GROUP oGroup3 TO aObj1Size[2,3]+5,aObj1Size[2,4] LABEL "" OF oDlg PIXEL
	oGroup3:oFont:= oFont2
	bBlock2	:= { |x| If(ValType(x)=='U', nRadio2 , nRadio2 := x ) }
	bClick2	:= { || Habilita(nRadio1) }
	oRadio2	:= TRadMenu():New( aObj1Size[2,1]+8,aObj1Size[2,2]+15, {STR0027, STR0028},bBlock2,oDlg,,bClick2,,,,,,60,10 )	//"Valor"###"Percentual"
	nRadio2	:= oRadio2:nOption
	@ aObj1Size[2,1]+11,aObjSize[2,2]+95 MSGET oGet2 Var nValor2 PICTURE Cs070Pict(nRadio2) SIZE 060,10 PIXEL WHEN nRadio1 == 3 HASBUTTON

	Habilita(nRadio1)

 	bSet15	:= {|| RestKeys(aKeys,.T.), If ( fReajOk(), oDlg:End(), NIL ) }
	bSet24	:= {|| RestKeys(aKeys,.T.), oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

RestArea(aSaveArea)
RestKeys(aKeys,.T.)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fReajOk     ³ Autor ³ Kelly Soares       ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica valores informados para o reajuste				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fReajOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fReajOk()

Local lRet		:= .T.
Local cAviso	:= ""

If dDataReaj < M->RBR_DTREF
	cAviso := oEmToAnsi(STR0076) //"Data do reajuste deve ser maior que a atual."
Endif

If nRadio1 == 1 // Alteracao Manual
	Cs070Alter(@aAlter,.F.)
	oGet:aAlter := aClone(aAlter)
	oGet:oBrowse:Refresh()
Elseif nRadio1 == 2 // Valor de Referencia
	If nTpVl == 2
		cAviso := oEmToAnsi(STR0083) //"Opção inválida para tabela com valores por intervalo."
	Else
	    If nValReaj <= M->RBR_VLREF
			cAviso := oEmToAnsi(STR0082) //"Novo Valor de Referência não pode ser menor ou igual ao atual."
	    Endif
	Endif
Else // Niveis e Faixas
	If ( nValor1 + nValor2 ) == 0	 //"Informe valor ou percentual para reajuste."
		cAviso := oEmToAnsi(STR0077)
	Endif
Endif

If Empty(cAviso)
	fProcReaj(nRadio1,nRadio2,nValReaj,dDataReaj)
Else
	lRet := .F.
	Aviso(STR0022,cAviso,{STR0047})	//"Aviso"###"XXXXXXXXXXXXXXXXXXXXX"###"Sair"
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fProcReaj   ³ Autor ³ Kelly Soares       ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os valores da tabela salarial, de acordo com o 	  ³±±
±±³          ³ tipo escolhido.                                         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fProcReaj(nRadio1,nRadio2,nValReaj,dDataReaj)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fProcReaj(nRadio1,nRadio2,nValReaj,dDataReaj)

Local nNiv		:= 0
Local nFai		:= 0
Local nValor 	:= 0
Local nCont		:= 0
Local lFirst	:= .T.

M->RBR_DESCTA := cDTabReaj

If nRadio1 == 1	// Alteracao Manual

	M->RBR_DTREF := dDataReaj

ElseIf nRadio1 == 2	// Valor de Referencia

	M->RBR_VLREF := nValReaj
	M->RBR_DTREF := dDataReaj
	For nNiv := 1 to Len(oGet:aCols)
		For nFai := 1 To Len(aHeader)
			If "RB6_COEFIC" $ AllTrim(UPPER(aHeader[nFai][2]))
				nCoefic := oGet:aCols[nNiv][nFai]
			Endif
			If "RB6_VALOR" $ AllTrim(UPPER(aHeader[nFai][2]))
				oGet:aCols[nNiv][nFai] := Round( nValReaj * nCoefic, MsDecimais(1))
			EndIf
		Next nFai
	Next nNiv

ElseIf nRadio1 == 3 // Niveis e Faixas

	For nNiv := 1 To Len(oGet:aCols)
		nCont := 0
		For nFai := 1 To Len(aHeader)
			If "RB6_VALOR" $ AllTrim(UPPER(aHeader[nFai][2]))
				nCont ++
				If nRadio2 == 1 // Valor
					nValor := (nValor2)
				Else  			// Percentual
					nValor := Round( (nValReaj * nValor2 / 100), MsDecimais(1))
				EndIf
				If lFirst
				    nValReaj += nValor
					lFirst   := .F.
				Endif
				if nRadio2 == 1 // Valor
					oGet:aCols[nNiv][nFai] := Round((oGet:aCols[nNiv][nFai] + nValor2), MsDecimais(1))
				Else
					oGet:aCols[nNiv][nFai] += Round((oGet:aCols[nNiv][nFai] * nValor2 / 100), MsDecimais(1))
				Endif
				// Atualiza o coeficiente
				If nCont == 1
					oGet:aCols[nNiv][nFai-1] := oGet:aCols[nNiv][nFai] / nValReaj
				Endif
			Else
				nCont := 0
			EndIf
		Next nFai
	Next nNiv

	M->RBR_DTREF := dDataReaj
	M->RBR_VLREF := nValReaj

Endif

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Habilita    ³ Autor ³ Kelly Soares       ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita/Desabilita objetos de acordo com o tipo de   	  ³±±
±±³          ³ reajuste informado.                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Habilita()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Habilita(nRadio)

oValRef:Setfocus()
oGet2:Setfocus()
If ( nRadio == 3 , oRadio2:Enable() , oRadio2:Disable() )

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fValidCoef  ³ Autor ³ Kelly Soares       ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o valor da faixa de acordo com o coeficiente.   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fValidCoef()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValidCoef()

If M->RBR_VLREF = 0
	M->RB6_COEFIC := 0
	Aviso(oEmToAnsi(STR0022),oEmToAnsi(STR0079),{STR0047}) // "Informe o valor de referencia."
Else
	oGet:aCols[n][oGet:oBrowse:nColPos+1] := Round( M->RBR_VLREF * M->RB6_COEFIC, MsDecimais(1))
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fValidVlr   ³ Autor ³ Kelly Soares       ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o coeficiente de acordo com o valor informado.  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fValidVlr()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fValidVlr()
Local lRet		:= .T.
Local nVlrCoef	:= 0
//monta valor máximo do coeficiente (não pode usar picture pois pode usar mais caracteres que o tamanho do campo)
Local nTamDec	:= TAMSX3("RB6_COEFIC")[2]
Local nTamInt	:= TAMSX3("RB6_COEFIC")[1] - ( nTamDec + 1 )
Local nCoefMax	:= Val(Replicate("9",nTamInt) +"."+ Replicate("9",nTamDec))

If M->RBR_VLREF = 0
	M->RBR_VLREF := M->RB6_VALOR
Endif

nVlrCoef := M->RB6_VALOR / M->RBR_VLREF

// Verifica se não estoura pictura e conceito de Coeficiente do cadastro
If nVlrCoef > nCoefMax
	Help(,,OemToAnsi(STR0024),, OemToAnsi(STR0098)+OemToAnsi(STR0099) ,1,0) // "Geração de Coeficiente Inválido - Verificar o conteúdo do campo Valor de Referência para geração de um Coeficiente válido."
	lRet	:= .F.
Else																					// "O valor do Coeficiente deverá corresponder à divisão entre o valor da Faixa e o valor Referência."
	oGet:aCols[n][oGet:oBrowse:nColPos-1] := nVlrCoef
	oEnchoice:Refresh()
	lRet	:= .T.
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fUsaCor     ³ Autor ³ Kelly Soares       ³ Data ³ 05/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina a cor da tabela de acordo com seu campo APLICADA.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fUsaCor()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fUsaCor()

Local aCores := {}

aCores	:=	{	                                    	 	 ;
				{ "RBR->RBR_APLIC=='1'" , "BR_VERDE"	}	,;
				{ "RBR->RBR_APLIC=='2'" , "BR_AZUL"		}	 ;
			 }

Return( aClone( aCores ) )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Simula ³ Autor ³ Kelly Soares       ³ Data ³ 06/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Simula o reajuste dos funcionarios vinculados a tabela     ³±±
±±³          ³ corrente.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Simula()	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Simula()

Local aSaveArea	:= GetArea()

Private cFilDe
Private cFilAte
Private cMatDe
Private cMatAte
Private cSituacao
Private cCategoria

If Pergunte("CSA072")

	cFilDe		:= mv_par01
	cFilAte		:= mv_par02
	cMatDe		:= mv_par03
	cMatAte		:= mv_par04
	cSituacao	:= mv_par05
	cCategoria	:= mv_par06

	If RBR->RBR_TIPOVL != 1	 .and. RBR->RBR_TIPOVL != 3 // Nao for Valores Exatos
		Aviso(OemToAnsi(STR0006),OemToAnsi(STR0083),{"Ok"})	//"Atencao"#"O reajuste salarial atraves de Tabela so' pode ser utilizado em tabela com valores Exatos."
		Return Nil
	EndIf

	Processa({|lEnd| ProcSimula()})	// Chamada do Processamento

EndIf

RestArea(aSaveArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ProcSimula  ³ Autor ³ Kelly Soares       ³ Data ³ 06/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a simulacao de reajuste.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcSimula()	                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcSimula()

Local nX
Local nSalario		:= 0
Local nAux			:= 0
Local cAcessaSRA	:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local cAplicada		:= If ( RBR->RBR_APLIC == "1" , oEmToAnsi(STR0088) , oEmToAnsi(STR0089) )
Local cChave		:= ""
Local cTabela		:= RBR->RBR_TABELA
Local dDataTab		:= RBR->RBR_DTREF
Local cNivel		:= ""
Local cFaixa		:= ""
Local cInicio		:= ""
Local cFim			:= ""
Local cLog			:= ""
Local aLog			:= {}
Local aTitle		:= {}
Local aComReaj		:= {}
Local aSemReaj		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_SALARIO"}
Local lOfuscaNom	:= .F.
Local lFirst

//Tratamento de acesso a Dados Sensíveis
aFldRel := Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ), {} )
If aOfusca[2] .And. (aScan( aFldRel, {|x| x:cfield == "RA_SALARIO"}) > 0)//FwProtectedDataUtil():IsFieldInList( "RA_SALARIO" )
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

If aOfusca[2] .And. Len(aFldRel) > 0
	lOfuscaNom :=  aScan( aFldRel, {|x| x:cfield == "RA_NOME"}) > 0
EndIf

cInicio	:="SRA->RA_FILIAL"
cFim	:= cFilAte

dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(cFilDe,.T.)

ProcRegua(SRA->(RecCount()))

While !Eof() .And. &cInicio <= cFim

	If !Eval(cAcessaSRA)
		dbSkip()
		Loop
	EndIf

	If 	(SRA->RA_MAT < cMatDe .or. SRA->RA_MAT > cMatAte)
		dbSkip()
		Loop
	EndIf

	If 	!(SRA->RA_SITFOLH $ cSituacao)
		dbSkip()
		Loop
	EndIf

	If 	!(SRA->RA_CATFUNC $ cCategoria)
		dbSkip()
		Loop
	EndIf

	IncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+ If(lOfuscaNom, "", " - "+SRA->RA_NOME) )

	cNivel		:= SRA->RA_TABNIVE
	cFaixa		:= SRA->RA_TABFAIX

	If 	!(cTabela == SRA->RA_TABELA)
		dbSkip()
		Loop
	EndIf

	If lHistorico
		cChave := xFilial("RB6") + cTabela + DTOS(dDataTab) + cNivel + cFaixa
		DbSelectArea("RB6")
		DbSetOrder(3)
		If DbSeek( cChave )
			nSalario := RB6->RB6_VALOR
		Endif
	Else
		cChave := xFilial("RB6") + cTabela + cNivel + cFaixa
		DbSelectArea("RB6")
		DbSetOrder(1)
		If DbSeek( cChave )
			nSalario := RB6->RB6_VALOR
		Endif
	Endif

	DbSelectArea("SRA")
	dbSetOrder(1)

	aAdd( If ( SRA->RA_SALARIO > nSalario , aSemReaj , aComReaj ) ,;
			 { SRA->RA_FILIAL,	;// [01] Filial
			   SRA->RA_MAT,		;// [02] Matricula
			   If(lOfuscaNom, Replicate('*',15),SRA->RA_NOME),	;// [03] Nome
			   SRA->RA_CATFUNC,	;// [04] Categoria
			   SRA->RA_SITFOLH,	;// [05] Situacao
			   SRA->RA_SALARIO,	;// [06] Salario Atual
			   nSalario,		;// [07] Novo Salario
			 } )

	DbSkip()

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta LOG com resultado da simulacao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd( aTitle , oEmToAnsi(STR0087) )
nAux ++
aAdd( aLog , {} )
aAdd( aLog[nAux] , Upper(cAplicada) )

If Empty(Len(aSemReaj) + Len(aComReaj))
	nAux ++
	Aadd(aLog,{})
	Aadd(aLog[nAux],oEmToAnsi(STR0090))
Endif

If Len(aSemReaj) > 0
	lFirst := .T.
	Aadd(aTitle,oEmToAnsi(STR0084))
	nAux ++
	Aadd(aLog,{})
	For nX := 1 to len(aSemReaj)
		If lFirst
			cLog := oEmToAnsi(STR0086)
			Aadd(aLog[nAux],cLog)
			Aadd(aLog[nAux],"")
			lFirst := .F.
		Endif
    	cLog := aSemReaj[nX][1] + " - " + aSemReaj[nX][2] + " - " + aSemReaj[nX][3] + Space(45-len(aSemReaj[nX][3])) + ;
			   	aSemReaj[nX][4] + Space(10) + aSemReaj[nX][5] + Space(10) +  ;
			   	Str(aSemReaj[nX][6],12,2) + Space(10) + Str(aSemReaj[nX][7],12,2)
		Aadd(aLog[nAux],cLog)
	Next nX
Endif

If Len(aComReaj) > 0
	lFirst := .T.
	Aadd(aTitle,oEmToAnsi(STR0085))
	nAux ++
	Aadd(aLog,{})
	For nX := 1 to len(aComReaj)
		If lFirst
			cLog := oEmToAnsi(STR0086)
			Aadd(aLog[nAux],cLog)
			Aadd(aLog[nAux],"")
			lFirst := .F.
		Endif
    	cLog := aComReaj[nX][1] + " - " + aComReaj[nX][2] + " - " + aComReaj[nX][3] + Space(45-len(aComReaj[nX][3])) + ;
			   	aComReaj[nX][4] + Space(10) + aComReaj[nX][5] + Space(10)  + ;
			   	Str(aComReaj[nX][6],12,2) + Space(10) + Str(aComReaj[nX][7],12,2)
		Aadd(aLog[nAux],cLog)
	Next nX
Endif

fMakeLog(aLog,aTitle,"CSAA070")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs070Leg    ³ Autor ³ Eduardo Ju         ³ Data ³ 12/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda de Status da Tabela Salarial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs070Leg()	                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs070Leg()

Local aSaveArea := GetArea()

BrwLegenda(cCadastro,STR0093, {	{"BR_VERDE"	, OemToAnsi(STR0040)},; //"Aplicada"
								{"BR_AZUL"	, OemToAnsi(STR0092)}}) //"Não Aplicada"

RestArea(aSaveArea)

Return Nil

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA070                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=		{ 	{ STR0003, 'PesqBrw'	, 0, 1,,.F. } , ; 	//"Pesquisar"
							{ STR0004, 'Cs070Rot'	, 0, 2 } , ; 	    //"Visualizar"
							{ STR0005, 'Cs070Rot'	, 0, 3 } , ; 	    //"Incluir"
							{ STR0006, 'Cs070Rot'	, 0, 4 } , ; 	    //"Alterar"
							{ STR0007, 'Cs070Rot'	, 0, 5 } , ; 	    //"Excluir"
							{ STR0068, 'Cs070Simula', 0, 6 } , ; 	    //"Simular Reajuste"
  						    { STR0093, 'Cs070Leg'   , 0, 7,,.F.}	}	//"Legenda"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Emerson Campos       º Data ³ 13/02/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem unica											    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem unica                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}
	aRet:= CSAI070 ( cXml, nTypeTrans, cTypeMessage )
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fVerDec   ºAutor  ³Luis Artuso         º Data ³  06/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta o valor a ser gravado, de acordo com a quantidade de º±±
±±º          ³casas decimais.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fVerDec(xDado , cPict , nTam)

Local lRet	:=	.F.

If ( ValType(xDado) == 'N' )
	If ( !(xDado > 0) .AND. (Empty(cPict)) )
		lRet	:=	Val ( Transform(xDado , cPict) ) > 0
	Else
		lRet	:=	.T.
	EndIf
Else
	If ( (ValType(xDado) == 'C') .AND. (nTam >= LEN(ALLTRIM(xDado))) )
		lRet	:=	.T.
	EndIf
EndIf

Return lRet


/*{Protheus.doc} csa70FilTp
	(long_description)
	@type  Function
	@author Din Whitechurch
	@since 2018-08-23
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
 */
 Function csa70FilTp()
	Local cRet as Char
	Local cFiltro as Char
	Local cFunName	:= FunName()
	Local oModelF5D As Object
	Local oModel	:= Nil
	Local oModelTMP	:= Nil

	cRet := ''

	If cFunName == "CSAA070"
		cRet := "@#F5C->F5C_CDTYP == '" + ALLTRIM(GetMemVar( "RBR_CDTYP" )) + "'@#"
	ElseIf cFunName $ "RU07T05"
		oModel := FwModelActive()
		oModelTMP := oModel:GetModel("F5DCHILD")
		cFiltro := oModelTMP:GetValue("F5D_TPCD")
		cRet := "@#F5C->F5C_CDTYP == '" + ALLTRIM(cFiltro) + "'@#"
	ElseIf cFunName $ "RU07T03"
		oModel := FwModelActive()
		oModelF5D := oModel:GetModel("RU07T03_MF5D")
		cFiltro := oModelF5D:GetValue("F5D_TPCD")
		cRet := "@#F5C->F5C_CDTYP == '" + ALLTRIM(cFiltro) + "'@#"
	EndIf

Return cRet


/*/{Protheus.doc} fChkCoef
//TODO Valida coeficiente entre faixas e niveis após a geração automatica
@author paulo.inzonha
@since 26/10/2018
@version 1.0
@return ${Logico}, ${Retorna .T. se o coeficiente tiver um tamanho valido e .F. se for Invalido}
@param nValor, numeric, Valor calculado
@param nPriVal, numeric, Valor Inicial
@param nTamInt, numeric, Numero maximo do valor inteiro
@param nNiv, numeric, numero do nivel que esta sendo avaliado
@type function
/*/
Static Function fChkCoef(nValor , nPriVal , nTamInt,nNiv)
Local lRet	:=	.T.

If Len( cValToChar( INT(nValor/nPriVal) ) ) > nTamInt
	cMsg := OemtoAnsi(STR0102) + cValToChar(nNiv) + CRLF + CRLF //"O valor do coeficiente ultrapassou o tamanho máximo permitido a partir do nível: "
	cMsg += OemtoAnsi(STR0103) + cValTochar( Int(nValor/nPriVal) ) + OemtoAnsi(STR0104) + cValToChar((10 ^ nTamInt)- 1) + CRLF + CRLF //"O valor calculado de: "#" é superior o valor máximo permitido de: "
	cMsg += OemtoAnsi(STR0105) //"Solução: Ajuste o tamanho do campo RB6_COEFIC na tabela RB6."
	MsgAlert( cMsg, OemtoAnsi(STR0101) ) //"Atenção"
	lRet :=	.F.
EndIf

Return lRet
