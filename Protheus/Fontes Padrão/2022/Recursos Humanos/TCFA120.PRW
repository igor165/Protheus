#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA120.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o      ³ TCFA120  ³ Autor ³ Cristina Ogura      ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o   ³ Cadastro dos Menus de Terminal Funcionarios              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ TCFA120                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³24/07/14³TQEA22³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TCFA120()                                                          

Local aArea			:= GetArea()
Local aAreaRBC		:= RBC->( GetArea() )
Local aIndFil		:= {}
Local cFiltra		:= ""
Local cFiltraRBC	:= ""

Private aAC			:= { STR0001 , STR0002 }	//"Abandona"###"Confirma"
Private bFiltraBrw 	:= { || ( aIndFil := {} , FilBrowse( "RBC" , @aIndFil , @cFiltraRBC ) ) }
Private bResetFilt	:= { || EndFilBrw("RBC",aIndFil) }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Array contendo as Rotinas a executar do programa      ³
³ ----------- Elementos contidos por dimensao ------------     ³
³ 1. Nome a aparecer no cabecalho                              ³
³ 2. Nome da Rotina associada                                  ³
³ 3. Usado pela rotina                                         ³
³ 4. Tipo de Transa‡„o a ser efetuada                          ³
³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
³    2 - Simplesmente Mostra os Campos                         ³
³    3 - Inclui registros no Bancos de Dados                   ³
³    4 - Altera o registro corrente                            ³
³    5 - Remove o registro corrente do Banco de Dados          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o cabecalho da tela de atualizacoes                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro dos Menus do Terminal de Consulta"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cFiltra 	:= ChkRh(FunName(),"RBC","1")
cFiltraRBC 	:= "RBC_SEQ == '" + Space( TamSx3("RBC_SEQ   ")[1]) + "'"
IF !Empty(cFiltra)
	cFiltraRBC := ( cFiltraRBC + ".and." + cFiltra )
EndIF
Tcfa120Filter( bFiltraBrw )
dbSelectArea("RBC")
dbGotop()

mBrowse(6, 1, 22, 75, "RBC")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Deleta o filtro utilizando a funcao FilBrowse e Restaura Dados de Entra³
³ da																	 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Tcfa120Filter( bResetFilt )
RestArea( aAreaRBC )
RestArea( aArea )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tc120Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que trata as funcoes de Cadastro Menus              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tc120Rot(cExpC1,nExpN1,nExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Rot(cAlias,nReg,nOpc)

Local aArea		:= GetArea()
Local aAreaRBC	:= RBC->( GetArea() )
Local aAlter	:= {}
Local aList		:= {}
Local aPos		:= {15,1,65,312 }
Local aItens	:={STR0020,STR0021} //"VARIOS"###"UNICO"
Local cStatus	:=""
Local cGet		:=""                                 
Local cChave	:=""
Local lCsDel	:= IF( nOpc == 2 .or. nOpc == 5 , .F. , .T. )
Local lRet		:= .F.
Local lMarca	:= .F.
Local lDesmarca	:= .F.
Local nOpca		:= 0.00
Local nGrava	:= 0.00             
Local oDlgMain
Local oGroup
Local oCbx
Local oMarca
Local oDesMarca
Local o1Grp
Local o2Grp
Local oSay
Local oCodMnu120
Local oDescMnu
Local oVarios
Local oUnico
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}

// Private do programa
Private aCols		:= {}
Private aHeader		:= {}    
Private aAuxCols	:= {}
Private aAuxHeader  := {}
Private cCodMnu120	:= ""
Private cDescMnu	:= ""
Private cSvDescMnu	:= ""
Private cItens120	:= ""
Private lCompArray	:= .F.
Private nOpcx		:= nOpc
Private oLbx
Private oNo
Private oOk
Private oGet

//Limpa os Filtros
Tcfa120Filter( bResetFilt )

//Reposiciona Ponteiro do Banco de Dados
//Que foi disposicionado na Limpeza dos Filtros
( cAlias )->( dbGoto( nReg ) )

// Seta Bitmap nas variaveis              
oNo 	:= LoadBitmap( GetResources(), "LBNO" )
oOk 	:= LoadBitmap( GetResources(), "LBOK" )

IF nOpc == 3	//Inclusao                                
	cChave 		:= CriaVar("RBC_FILIAL")+CriaVar("RBC_CODMNU")
	cCodMnu120 	:= GetSx8Num("RBC","RBC_CODMNU")	
	cDescMnu    := Space( Len( RBC->RBC_DESCRI ) )
Else                       
	cChave 	:= RBC->RBC_FILIAL+RBC->RBC_CODMNU
	cCodMnu120 := RBC->RBC_CODMNU	                
	cDescMnu:= RBC->RBC_DESCRI
	cItens120:= Tc120VerItens(cCodMnu120)
EndIF

cSvDescMnu	:= cDescMnu
	
IF nOpcx # 2 .And. nOpcx # 5 // Visual/Excluir
	lGetD	:= .T.
Else
	lGetD	:= .F.
EndIF
                                                            
// Campos que nao podem aparecer na getdados
aAdd(aAlter,"RBC_FILIAL")
aAdd(aAlter,"RBC_CODMNU")
aAdd(aAlter,"RBC_DESCRI")
aAdd(aAlter,"RBC_SEQ")
aAdd(aAlter,"RBC_NIVEL")

// Verifica campos de usuario que devem aparecer na GetDados
Tc120Usuario(@aAlter)

aAdd(aAuxHeader,{OemtoAnsi(STR0009),"XX_SEQ",PesqPict("RBC","RBC_SEQ"),(TamSx3( "RBC_SEQ   " )[1]),0,"","û","C"," ","" } )			//"Seq"
aAdd(aAuxHeader,{OemtoAnsi(STR0010),"XX_DESCRI",PesqPict("RBC","RBC_DESCRI"),(TamSx3( "RBC_DESCRI" )[1]),0,"","û","C"," ","" } )	//"Descricao"
                         
// Monta aHeader da GetDados
TrmHeader(@aAuxHeader,aAlter,"RBC")

// Monta o aCols da GetDados
Tc120aCols(@aAuxCols,nOpcx,"RBC","RBC->RBC_FILIAL+RBC->RBC_CODMNU",cChave,aAuxHeader,1)

aCols 	:= aClone( aAuxCols )
aHeader	:= aClone( aAuxHeader )

// Monta os dados do Listbox          
//Tc120Listbox(@aList)

SetaPilha()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 80	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 80	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*70), (((aObjSize[1,4])/100)*78) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlgMain FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]	 PIXEL TITLE cCadastro OF oMainWnd

	@ aGdCoord[1], aGdCoord[2] GROUP o1Grp	TO aGdCoord[3], aGdCoord[4] LABEL "" PIXEL OF oDlgMain 
	@ aGdCoord[1]+6, aGdCoord[2]+5 SAY	STR0011 PIXEL SIZE 40,7		//"Titulo Menu: "
	@ aGdCoord[1]+5 , aGdCoord[2]+42 MSGET oCodMnu120 VAR cCodMnu120 PICTURE "999" VALID NaoVazio() .and. Existchav("RBC",( cCodMnu120 + Space( TamSx3("RBC_SEQ   ")[1]) ),1) PIXEL SIZE 15,7 WHEN lGetD
	@ aGdCoord[1]+5 , aGdCoord[2]+65 MSGET oDescMnu	VAR cDescMnu PICTURE "@!S30" VALID !Empty(cDescMnu) PIXEL SIZE 150,7 WHEN lGetD
    
	@ aGdCoord[1]+20, aGdCoord[2]+5 SAY STR0012 PIXEL SIZE 40,7		//"Itens Menu"
	@ aGdCoord[1]+19, aGdCoord[2]+42 MSCOMBOBOX oCbx VAR cItens120 ITEMS aItens SIZE 061, 65 OF oDlgMain PIXEL;
			  ON CHANGE Tc120Combo(@nOpcx,cDescMnu)
	     
	oGet := MSGetDados():New(aGdCoord[1]+34, aGdCoord[2]+5, aGdCoord[3]-5, aGdCoord[4]-5,nOpcx,"Tc120LOk","AlwaysTrue","+XX_SEQ",lGetD,,1,,300,,,,,oDlgMain)
	oGet:oBrowse:Default()
				
ACTIVATE DIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,	{||nGrava:=1,If(Tc120Ok(cDescMnu),oDlgMain:End(),)},{||nGrava:=2,oDlgMain:End()}) CENTERED
SetaPilha()

IF nGrava == 1 					// Confirma
	IF nOpcx # 5 .and. nOpcx # 2	// Se nao for Exclusao e visual
		Begin Transaction
			IF nOpcx == 3			// Inclusao
				IF __lSX8
					ConfirmSX8()
				EndIF
			EndIF
			IF !( lCompArray := fCompArray( aAuxCols , aCols ) ) .or. !( cSvDescMnu == cDescMnu )
				Tc120Grava(nOpcx,cDescMnu)
				EvalTrigger()
			EndIF	
		End Transaction
	ElseIF nOpcx == 5
		Begin Transaction
			Tc120Delete()
		End Transaction
	EndIF
Else 
	IF nOpcx == 3		//Inclusao
		IF ( __lSx8 )
			RollBackSx8()
		EndIF
	EndIF
EndIF

//Retorna o Filtro do Browse
Tcfa120Filter( bFiltraBrw )

//Retorna os Dados de Entrada
RestArea( aAreaRBC , RestArea( aArea ) )

Return( NIL )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc120Delete ³ Autor ³ Cristina Ogura      ³ Data ³ 13.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que apaga todos os dados dos Mnu                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tc120Delete()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TCFA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Delete()

Local cFilRBC := xFilial("RBC")

// Excluir os menus 
dbSelectArea("RBC")
RBC->( dbSetOrder(1) )
RBC->( dbSeek(cFilRBC+cCodMnu120) )
While RBC->( !Eof() .and. RBC_FILIAL+RBC_CODMNU == cFilRBC+cCodMnu120 )
	RecLock("RBC",.F.,.T.)
	RBC->( dbDelete()  )
	RBC->( MsUnlock() )
	RBC->( dbSkip() )
EndDo

Return( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc120Grava  ³ Autor ³ Cristina Ogura      ³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os dados dos Mnus                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Tc120Grava()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TCFA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Grava(nOpcx,cDescMnu)

Local aRecnos		:= {}                                    
Local cSeq			:= ""
Local cFilRBC		:= xFilial("RBC")
Local cOldItens		:= Tc120VerItens(cCodMnu120)
Local lTodos		:= .T.
Local lMnuPrinc		:= .F.
Local nX			:= 0.00
Local nY			:= 0.00
Local nT			:= 0.00
Local nSeq			:= 0.00
Local nacols 		:= Len( aCols )
Local naHeader		:= Len( aHeader )
Local nAnterior 	:= 0.00
Local nPosStat  	:= GdFieldPos( "RBC_STATUS" )
Local nStatus		:= 0.00
Local nRecSeqEmpty	:= 0.00

IF nOpcx == 2 .Or. nOpcx == 5    // Visualizar ou Exclusao
	Return( .T. )
EndIF

// Verificar se todos os niveis foram marcados
//For nX:=1 To Len(aList)
//	If 	aList[nX][1] = 0
//		lTodos := .F.
//		Exit
//	EndIf
//Next nX 

// Sempre grava o RBC_SEQ em branco para o codigo e titulo do Menu.
IF !lCompArray
	IF nOpcx == 3		// Inclusao
		//Grava os Itens de Opcoes do Menu
		For nX := 1 To naCols
			IF !aCols[nX,Len(aCols[nX])]	// Deletado
				RecLock("RBC",.T.)
				RBC->RBC_FILIAL := cFilRBC
				RBC->RBC_CODMNU	:= cCodMnu120
				RBC->RBC_SEQ	:= IF( cItens120 != STR0021 , StrZero(++nSeq,2) , Space( Len( RBC->RBC_SEQ ) ) )
				RBC->RBC_NIVEL	:= Space(Len(RBC->RBC_NIVEL))
				For nY := 1 To naHeader
					IF aHeader[nY,10] # "V" 
						IF aHeader[nY,2] == "XX_DESCRI" 			 
							RBC->RBC_DESCRI := aCols[nX,nY]
						Else	
							IF RBC->( FieldPos( AllTrim(aHeader[nY,2]) ) ) > 0.00
								RBC->( FieldPut( FieldPos( AllTrim(aHeader[nY,2]) ) , aCols[nX,nY] ) )
							EndIF	
						EndIF
						IF nY == nPosStat .and. aCols[nX,nY] == "A"
							nStatus++
						EndIF
					EndIF
				Next nY
				RBC->( MsUnlock() )
			EndIF
		Next nX
		//Grava o Item que sera o Titulo do Menu do TCF
		IF cItens120 != STR0021 //"UNICO"
			RecLock("RBC",.T.)
			RBC->RBC_FILIAL := cFilRBC
			RBC->RBC_CODMNU := cCodMnu120
			RBC->RBC_DESCRI := cDescMnu
			RBC->RBC_SEQ	:= Space( Len( RBC->RBC_SEQ ) )
			RBC->RBC_STATUS	:= IF( nStatus == 0.00 , "" , "A" )
			RBC->( MsUnlock() )
		EndIF
	ElseIF nOpcx == 4 //Alteracao
		dbSelectArea("RBC")
		dbSetOrder(1)
		IF RBC->( dbSeek(cFilRBC+cCodMnu120) )
			While RBC->( !Eof() .and. RBC_FILIAL+RBC_CODMNU == cFilRBC+cCodMnu120 )
				IF Empty( RBC->RBC_SEQ )
					nRecSeqEmpty := RBC->( Recno() )
					IF !( cOldItens == STR0021 ) //"UNICO"
						RBC->( dbSkip() )
						Loop
					EndIF
				EndIF
				RBC->( aAdd(aRecnos,Recno()) )
				RBC->( dbSkip() )
			End While
		EndIF
		nAnterior := Len( aRecnos )
		For nX := 1 To naCols
			IF nX <= nAnterior
				RBC->( dbGoto( aRecnos[ nX ] ) )
				RecLock("RBC",.F.)
				//--Verifica se esta deletado
				IF aCols[nX,Len(aCols[nX])]
					RBC->( dbDelete() )
					aRecnos[ nX ]  := 0.00
					Loop
				Else
					RecLock("RBC",.F.)
				EndIF
			Else
				//--Verifica se esta deletado			
				IF aCols[nX,Len(aCols[nX])]
					Loop
				EndIF
				RecLock("RBC",.T.)
				RBC->RBC_FILIAL := cFilRBC
				RBC->RBC_NIVEL  := Space(Len(RBC->RBC_NIVEL))
				RBC->RBC_CODMNU := cCodMnu120
			EndIF
			RBC->RBC_SEQ := StrZero(++nSeq,2)
			For nT := 1 To naHeader
				IF aHeader[nT,10] # "V"
					IF aHeader[nT,2] == "XX_DESCRI"
						RBC->RBC_DESCRI := aCols[nX,nT]
					Else	
						IF RBC->( FieldPos( AllTrim(aHeader[nT,2]) ) ) > 0.00
							RBC->( FieldPut( FieldPos( AllTrim(aHeader[nT,2]) ) , aCols[nX,nT] ) )
						EndIF	
						IF nT == nPosStat .and. aCols[nX,nT] == "A"
							nStatus++
						EndIF
					EndIF
				EndIF
			Next nT
			RBC->(  MsUnlock()  )
	    Next nX	              
		IF !( cOldItens == STR0021 ) //"UNICO"
			RBC->( dbGoto( nRecSeqEmpty ) )
			RecLock("RBC",.F.,.F.)
			RBC->RBC_DESCRI := cDescMnu
			RBC->RBC_STATUS	:= IF( nStatus == 0.00 , "" , "A" )
			RBC->( MsUnLock() )
		ElseIF !( lMnuPrinc := ( Tc120VerItens(cCodMnu120) == STR0021 ) ) //"Pesquisa os Itens Ja Gravados 
			RecLock("RBC",.T.,.F.)
			RBC->RBC_FILIAL := cFilRBC
			RBC->RBC_CODMNU := cCodMnu120
			RBC->RBC_DESCRI := cDescMnu
			RBC->RBC_SEQ	:= Space( Len( RBC->RBC_SEQ ) )
			RBC->RBC_ROTINA := Space( Len( RBC->RBC_ROTINA ) )
			RBC->RBC_STATUS	:= IF( nStatus == 0.00 , "" , "A" )
			RBC->( MsUnlock() )
		ElseIF lMnuPrinc
			RecLock("RBC",.F.,.F.)
			RBC->RBC_SEQ	:= Space( Len( RBC->RBC_SEQ ) )
			RBC->( MsUnlock() )
		EndIF
		nX := nY := nT := 0.00
		aEval( aRecnos , { |x,y| IF( !Empty(x) , ( nX++ , nY := aRecnos[ y ] ) , NIL ) } )
		IF nX == 1 .and. !( cOldItens == STR0021 ) .and. cItens120 == STR0021 //"UNICO"
			dbSelectArea("RBC")
			dbSetOrder(1)
			IF RBC->( dbSeek(cFilRBC+cCodMnu120) )
				While RBC->( !Eof() .and. RBC_FILIAL+RBC_CODMNU == cFilRBC+cCodMnu120 )
					IF Empty( RBC->RBC_SEQ )
						nRecSeqEmpty := RBC->( Recno() )
					Else
						nT++
					EndIF
					RBC->( dbSkip() )
				End While
			EndIF
			IF nT == 1
				RBC->( dbGoto( nRecSeqEmpty ) )
				RecLock("RBC",.F.,.F.)
				RBC->( dbDelete() )
				RBC->( MsUnLock() )
				RBC->( dbGoto( nY ) )
				RecLock("RBC",.F.,.F.)
				RBC->RBC_SEQ := Space( Len( RBC->RBC_SEQ ) )
				RBC->( MsUnLock() )
			EndIF	
		EndIF
	EndIF
Else
	//Apenas Altera a Descricao do Menu Principal
	dbSelectArea("RBC")
	dbSetOrder(1)
	IF RBC->( dbSeek(cFilRBC+cCodMnu120) )
		While RBC->( !Eof() .and. RBC_FILIAL+RBC_CODMNU == cFilRBC+cCodMnu120 )
			IF Empty( RBC->RBC_SEQ )
				RecLock("RBC",.F.,.F.)
				RBC->RBC_DESCRI := cDescMnu
				IF !( cOldItens == STR0021 ) //"UNICO"
					RBC->RBC_ROTINA := Space( Len( RBC->RBC_ROTINA ) )
				EndIF
				RBC->( MsUnLock() )
				Exit
			EndIF	
			RBC->( dbSkip() )
		End While
	EndIF
EndIF
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tc120Usuar ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no SX3 se o usuario criou algum campo		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³Tc120Usuar(aAlter)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 := Array com os campos       			 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TCFA120   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tc120Usuario(aAlter)

Local aArea:= GetArea()

dbSelectArea("SX3")
dbSetOrder(1)
SX3->( dbSeek("RBC") )
While SX3->( !Eof() .and. (X3_ARQUIVO == "RBC") )
	IF SX3->X3_PROPRI == "U"
		aAdd(aAlter,X3_CAMPO)
	EndIF
	SX3->( dbSkip() )
End While

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tc120Listb ³ Autor ³ Cristina Ogura       ³ Data ³ 13.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³MonTa o listbox dos nivel para ser selecionado  		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³Tc120Listbox()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TCFA120   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Listbox()

Local aArea		:= GetArea()
Local aAreaRBC  := RBC->( GetArea() )
Local aAreaRB9	:= RB9->( GetArea() )
Local cFilRBC	:= xFilial("RBC")
Local lMarca	:= .F.
Local lTodos	:= .F.

dbSelectArea("RBC")
RBC->( dbSetOrder(1) )
IF RBC->( dbSeek(cFilRBC+cCodMnu120) )
	While RBC->( !Eof() .and. RBC_FILIAL+RBC_CODMNU == cFilRBC+cCodMnu120 )
		IF Empty(RBC->RBC_SEQ)
			RBC->( dbSkip() )
			Loop
		EndIF
		IF Empty(RBC->RBC_NIVEL)
			lTodos:= .T.
			Exit
		EndIF
		RBC->( dbSkip() )
	End While
EndIF

aList := {}

dbSelectArea("RB9")
RB9->( dbSetOrder(1) )
RB9->( dbGotop() )
While RB9->( !Eof() )
	lMarca := .F.
	IF !lTodos
		dbSelectArea("RBC")
		RBC->( dbSetOrder(3) )
		IF RBC->( dbSeek(cFilRBC+RB9->RB9_NIVEL+cCodMnu120) )
			While RBC->( !Eof() .and. RBC_FILIAL+RBC_NIVEL+RBC_CODMNU == cFilRBC+RB9->RB9_NIVEL+cCodMnu120 )
				IF Empty(RBC->RBC_SEQ)
					RBC->( dbSkip() )
					Loop
				EndIF
				IF RBC->RBC_NIVEL == RB9->RB9_NIVEL
					lMarca := .T.		
					Exit
				EndIf   
				RBC->( dbSkip() )
			End While
		EndIF
	Else
		lMarca := .T.
	EndIF
	
	aAdd( aList ,{ IF( lMarca , 1 , 0 ) , RB9->RB9_NIVEL , RB9-> RB9_DESCRI } )
     
	dbSelectArea("RB9")
	RB9->( dbSkip() )

End While
                                     
RestArea(aAreaRB9)
RestArea(aAreaRBC)
RestArea(aArea)

Return( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc120Marca³ Autor ³ Cristina Ogura        ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada para marcar/desmarcar os niveis no lbx     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³Tc120Marca(cExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc  = Opcao do arotina                                    ³±±
±±³			 ³nMarca= 1-marca todos 0-desmarca                            ³±±
±±³			 ³aList = array com os niveis hierarquicos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TCFA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Marca(nOpc,nMarca,aList)
Local nX

If nOpc == 2 .Or. nOpc== 5
	Return .T.
EndIf

For nX:= 1 TO Len(aList)
	aList[nX][1] := nMarca
Next nX                    

oLbx:SetArray(aList)
oLbx:bLine:= {||{If(aList[oLbx:nAt,1]=1,oOk,oNo),aList[oLbx:nAt,2],aList[oLbx:nAt,3]}}

oLbx:Refresh(.T.)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc120Pesq ³ Autor ³ Cristina Ogura        ³ Data ³ 15.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de pesquisa da Descricao do Nivel hierarquico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³Tc120Pesq()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TCFA120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Pesq(cProcura,aList)
Local nPos:= 0

nPos:= Ascan(aList,{|x| x[3] == cProcura})
If 	nPos > 0
	oLbx:nAt := nPos
	oLbx:Refresh()
EndIf	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC120aCols³ Autor ³ Cristina Ogura        ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³MonTa o acols da getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³TC110aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TCFA110   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120aCols(aAuxCols,nOpcx,cAlias,cCond,cChave,aAuxHeader,nOrdem)

Local aAreaRBC	:= RBC->( GetArea() )
Local cSeq		:="!!"
Local naCols 	:= 0.00
Local nCnTFor	:= 0
Local nUsado	:= Len(aAuxHeader)
Local nAuxOrdem := 0.00
Local nAuxReg	:= 0.00
Local nConT		:= 0.00

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
IF (cAlias)->( dbSeek(cCHAVE) ) .or. cItens120 == STR0021 //"UNICO"
    While (cAlias)->(  !Eof() .And. &cCond == cChave )
    	IF Empty(RBC->RBC_SEQ) .and. cItens120 != STR0021 //UNICO
    		(cAlias)->( dbSkip() )
    		Loop
    	EndIF
    	IF 	cSeq # RBC->RBC_SEQ
			cSeq:= RBC->RBC_SEQ
			Aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
			naCols  := Len(aAuxCols)
			For nCnTFor := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCnTFor][10] != "V")
					If 	( Alltrim(aAuxHeader[nCnTFor][2]) == "XX_SEQ")
						If 	cItens120 == STR0021 //"UNICO"
							aAuxCols[naCols][nCnTFor]:= "01"
						Else	
							aAuxCols[naCols,nCnTFor]:= RBC->RBC_SEQ					
						EndIf	
					ElseIf ( Alltrim(aAuxHeader[nCnTFor][2]) == "XX_DESCRI")
						aAuxCols[naCols,nCnTFor]:= RBC->RBC_DESCRI
					Else
						aAuxCols[naCols,nCnTFor] := FieldGet(FieldPos(aAuxHeader[nCnTFor][2]))
					EndIf	
				Else
					aAuxCols[naCols,nCnTFor] := CriaVar(aAuxHeader[nCnTFor][2],.T.)
				EndIf
			Next nCnTFor
			IF nOpcx # 2 .And. nOpcx # 5
				aAuxCols[naCols,nUsado+1] := .F.
			EndIF
		EndIf	
		dbSelectArea(cAlias)
		(cAlias)->( dbSkip() )
	End While
Else
	dbSelectArea("SX3")
	dbSeek(cAlias)
	aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
	naCols := Len(aAuxCols)
	For nCnTFor := 1 To Len(aAuxHeader)
		If 	X3_TIPO == "C" .And. Trim(aAuxHeader[nCnTFor][2]) $ "XX_SEQ"
			aAuxCols[1][nCnTFor] := Repl("0",aAuxHeader[nCnTFor][4]-1)+"1"
		ElseIf 	Trim(aAuxHeader[nCnTFor][2]) == "XX_DESCRI"
			aAuxCols[naCols,nCnTFor] := Space(Len(RBC->RBC_DESCRI))
		Else
			aAuxCols[naCols,nCnTFor] := CriaVar(aAuxHeader[nCnTFor][2],.T.)
		EndIf	
	Next nCnTFor
	If nOpcx # 2 .And. nOpcx # 5
		aAuxCols[1][nUsado+1] := .F.
	EndIf	
EndIf                     
                  
// Volto a posicao do RBC
RestArea( aAreaRBC )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tc120Ok  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que trata os campos de codigo e titulo do Menu      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³ Tc120Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Ok(cDescMnu)

Local nPosRotina	:=	GdFieldPos( "RBC_ROTINA" )
Local nPosDescr		:=	GdFieldPos( "XX_DESCRI"  )
Local naCols 		:= Len( aCols )
Local nX
                           
IF nOpcx == 2 .Or. nOpcx == 5		// Visual/Excluir
	Return( .T. )
EndIf
 
For nX := 1 To naCols
	IF !aCols[nX , Len( aCols[ nX ] ) ]
		IF nPosDescr > 0 .And. Empty(aCols[nX][nPosDescr])
			//Help("",1,"Tc120Descri")
			AVISO(STR0013,STR0015,{STR0014})	//"Aviso"###"Descricao do Menu deve ser preenchida"###"Sair"
		    Return( .F. )
		ElseIF nPosRotina > 0 .and. Empty(aCols[nX , nPosRotina] )
			//Help("",1,"Tc120Rotina")
			AVISO(STR0013,STR0016,{STR0014})	//"Aviso"###"Nome da rotina deve ser preenchida."###"Sair"
		    Return( .F. )
		EndIF
	EndIF
Next nX	

IF Empty(cCodMnu120) .or. Empty(cDescMnu)
//	Help("",1,"Tc120Mnu")
	AVISO(STR0013,STR0017,{STR0014})	//"Aviso"###"Verifique o codigo ou titulo do menu devem estar preenchidos."###"Sair"
	Return( .F. )
EndIF

//For nX:=1 To Len(aList)
//	If 	aList[nX,1]==1     
//		lRet:= .T.
//		Exit
//	EndIf	
//Next nX            

//If !lRet
//	Help("",1,"Tc120Sele")
//	Return .F.
//EndIf

IF cItens120 == STR0021 .And. cDescMnu # aCols[n][nPosDescr] //"UNICO"
//	Help("",1,"Tc120Unico")			// Item unico deve ter descricao igual a item do menu	
	AVISO(STR0013,STR0018,{STR0014})	//"Aviso"###"Item unico deve ter descricao igual ao titulo do menu"###"Sair"
	Return( .F. )
EndIF

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tc120LOk ³ Autor ³ Cristina Ogura        ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que trata a linha Ok da Getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³ Tc120LOk(cExpC1,nExpN1,nExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120LOk()

Local nPosRotina	:= GdFieldPos( "RBC_ROTINA" )
Local nPosDescr		:= GdFieldPos( "XX_DESCRI"  )
Local nTam		 	:= 0.00
Local nX			:= 0.00
Local naCols  		:= Len( aCols )
       
// Verificando qual o tamanho do acol sem os deletados            
For nX := 1 To naCols 
	IF !aCols[ nX , Len( aCols[ nX ] ) ]
		nTam := nTam + 1
	EndIF
Next nX

IF nTam == 1 .and. cItens120 == STR0021 //"UNICO"
//	Help("",1,"Tc120Unico")
	AVISO(STR0013,STR0022,{STR0014})	//"Aviso"###"Item unico deve ter descricao igual ao titulo do menu"###"Sair"
	Return( .F. )
EndIF

IF !aCols[n , Len( aCols[ n ] ) ]
	IF nPosDescr > 0 .and. Empty(aCols[ n , nPosDescr ] )
  		//Help("",1,"Tc120Descri")			// Descricao deve ser preenchida
		AVISO(STR0013,STR0015,{STR0014})	//"Aviso"###"Descricao do Menu deve ser preenchida"###"Sair"		
	    Return( .F.	 )
	ElseIF nPosRotina > 0 .and. Empty(aCols[ n , nPosRotina ] )
		//Help("",1,"Tc120Rotina")			// Rotina deve ser preenchida
		AVISO(STR0013,STR0016,{STR0014})	//"Aviso"###"Nome da rotina deve ser preenchida."###"Sair"
	    Return( .F. )
	EndIF
	For nX := 1 To naCols 
		IF nX # n .And. aCols[ n , nPosRotina ] == aCols[ nX , nPosRotina ]
			//Help("",1,"Tc120Igual")			// Existem rotinas iguais
			AVISO(STR0013,STR0019,{STR0014})	//"Aviso"###"Verifique pois existem rotinas com nomes iguais."###"Sair"
			Return( .F. )
		EndIF
	Next nX
EndIF

IF cItens120 == STR0021 .And. cDescMnu # aCols[n][nPosDescr] //"UNICO"
//	Help("",1,"Tc120Unico")				// Item unico deve ter descricao igual a item do menu	
	AVISO(STR0013,STR0018,{STR0014})	//"Aviso"###"Item unico deve ter descricao igual ao titulo do menu"###"Sair"
	Return( .F. )
EndIF

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tc120Combo ³ Autor ³ Cristina Ogura      ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina do combo dos itens do menu: Unico ou Varios         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³ Tc120Combo()					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120Combo(nOpcao,cDescMnu)

Local nPosDescri	:= GdFieldPos( "XX_DESCRI" ) 
Local naCols 		:= Len( aCols )
Local nX			:= 0.00

// inclui
IF cItens120 == STR0021 //"UNICO"
	IF nPosDescri > 0
 		aCols[ n , nPosDescri ] := cDescMnu
 	EndIF
EndIF 

IF nOpcao == 4 .and. cItens120 == STR0021 //"UNICO"
	For nX := 1 To naCols
		IF nX > 1
			aCols[ nX , Len( aCols[ nX ] ) ] := .T.
		EndIF
	Next nX
EndIF

oGet:oBrowse:Refresh()

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tc120VerItens³ Autor ³ Cristina Ogura    ³ Data ³ 13.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que verifica a qtde de itens do Menu                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SinTaxe   ³ Tc120VerItens()				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TCFA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc120VerItens()

Local aArea 	:= GetArea()
Local aAreaRBC	:= RBC->(GetArea())
Local cNome		:= ""
Local cFilRBC 	:= xFilial("RBC")
Local nConT		:= 0.00

dbSelectArea("RBC")
RBC->( dbSetOrder(1) )
IF RBC->( dbSeek(cFilRBC+cCodMnu120) )
	While RBC->( !Eof() .and. RBC_FILIAL+RBC->RBC_CODMNU == cFilRBC+cCodMnu120 )
		nConT++
		RBC->( dbSkip() )
	End While
EndIF 

IF nConT ==1
	cNome := STR0021 //"UNICO"
Else 
	cNome := STR0020 //"VARIOS"
EndIF

RestArea(aAreaRBC)
RestArea(aArea)

Return( cNome )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Tcfa120Filter ³ Autor ³Marinaldo de Jesus ³ Data ³06/08/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Trata o Filtro de Browse									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TCFA120                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Tcfa120Filter( bEval )

DEFAULT bEval := { || NIL }

Eval( bEval )

Return( NIL )

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³29/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TCFA120                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina :=  {	{ STR0003, 'PesqBrw'	, 0	, 1		} ,;	//"Pesquisar"
						{ STR0004, 'Tc120Rot'	, 0	, 2		} ,;	//"Visualizar"
						{ STR0005, 'Tc120Rot'	, 0	, 3		} ,;	//"Incluir"
						{ STR0006, 'Tc120Rot'	, 0	, 4		} ,;	//"Alterar"
						{ STR0007, 'Tc120Rot'	, 0	, 5	, 3	}  ;	//"Excluir"
					}	

Return aRotina
