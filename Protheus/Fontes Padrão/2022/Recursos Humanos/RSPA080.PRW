#Include "Protheus.ch"
#Include "font.ch"
#Include "colors.ch"
#INCLUDE "RSPA080.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RSPA080  ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definir Pesquisa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA080

LOCAL cFiltraSQU	:= ""			//Variavel para filtro
Private aIndexSQU	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro :=OemtoAnsi(STR0006) //"Definir Pesquisa"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh 	:= "QU_SEQ == '01'"
bFiltraBrw 	:= {|| FilBrowse("SQU",@aIndexSQU,@cFiltraRH) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SQU")
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQU",aIndexSQU)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Rot  ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que atende todas as opcoes da aRotina               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Rot(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1- Alias do arquivo                                        ³±±
±±³          ³ 2- Numero do registro selecionado                          ³±±
±±³          ³ 3- Opcao Selecionada                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Rot(cAlias,nReg,nOpcx)
Local oDlg, oFont
Local oArquivo
Local cArquivo	:= ""
Local aArquivo	:= {}
Local oFiltro
Local aFiltro	:= {}
Local oResult
Local aResult	:= {}
Local oOk 		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oCodigo, oDescric, oTipo, oOrdem
Local cRspOrd	:= ""
Local cRspTipo	:= ""
Local lOk
Local cAnt		:= ""
Local cAnt1    	:= ""
Local nOrder 	:= IndexOrd()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}		
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}	
Local aObj1Coords 	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}

Private cRspCod	:= ""
Private cRspDesc:= ""
Private aPode	:= {"SQG","SQM","SQL","SQR","SQ3","RS6"}
Private cString	:= "QM_CURRIC/QL_CURRIC/QR_CURRIC"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQU",aIndexSQU)
aIndexSQU := {}
dbGoto(nReg)

If nOpcx == 3 									// Inclusao
	aAdd(aResult,{"01","","","","S",""})
	aFiltro  := A080Filtro(1,aResult)
	cRspCod  := CriaVar("QU_CODIGO")
	cRspDesc := CriaVar("QU_DESCRIC")
Else
	cRspCod := SQU->QU_CODIGO	
	cRspDesc:= SQU->QU_DESCRIC
	aResult := A080MontResult(SQU->QU_CODIGO)
	aFiltro := A080Filtro(1,aResult)
EndIf	

cRspOrd	 := CriaVar("QU_SEQ")
cRspTipo := CriaVar("QU_TIPO")
aArquivo := A080SX2()

SETAPILHA()              

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size    := aClone(aObjSize[2])
aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 050 , 000 , .T. , .T. } )
aAdd( aObj1Coords , { 005 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 050 , 000 , .T. , .T. } )
aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

aAdv2Size    := aClone(aObj1Size[1])
aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 10 , 10 }
aAdd( aObj2Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj2Coords , { 000 , 000 , .T. , .T., .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )


aAdv3Size    := aClone(aObj1Size[3])
aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 10 , 10 }
aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords )

DEFINE FONT oFont NAME "Arial Negrito" SIZE 0, -11

DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro PIXEL
	
	
    
	@ aObjSize[1,1]+5, aObjSize[1,2]+5		SAY OemtoAnsi(STR0007) SIZE 24, 7 OF oDlg PIXEL; //"Codigo:"
											FONT oFont COLOR CLR_BLUE 
	
	@ aObjSize[1,1]+5, aObjSize[1,2]+35 	MSGET oCodigo VAR cRspCod OF oDlg PIXEL;
									 		PICTURE "999";
									 		VALID A080Cod() .And. A080Valid("C");
									 		SIZE 17, 7; 
										 	WHEN nOpcx == 3			// Inclusao
												
	@ aObjSize[1,1]+5, aObjSize[1,2]+58 	MSGET oDescric VAR cRspDesc OF oDlg PIXEL;
									  		PICTURE "@!" ;
									  		VALID A080Valid("D");
									  		SIZE 140, 7; 
									  		WHEN nOpcx == 3 .Or. nOpcx == 4				// Inclusao/Alteracao
	
	@ aObj1Size[1,1], aObj1Size[1,2] TO aObj1Size[1,3], aObj1Size[1,4] OF oDlg  LABEL OemtoAnsi(STR0008) PIXEL //Primeira Moldura: Arquivo
    
	@ aObj2Size[1,1], aObj2Size[1,2] COMBOBOX oArquivo VAR cArquivo ITEMS aArquivo SIZE aObj2Size[1,4]-20,10 OF oDlg PIXEL;	
	ON CHANGE (aFiltro:=A080Filtro(oArquivo:nAt,aResult),A080bLine(oFiltro,aFiltro),oFiltro:Refresh(.t.))
	
	@ aObj2Size[2,1], aObj2Size[2,2] LISTBOX oFiltro FIELDS HEADER "","" SIZE aObj2Size[2,3],aObj2Size[2,4]  OF oDlg PIXEL;
	ON DBLCLICK (aFiltro[oFiltro:nAt,1] := !aFiltro[oFiltro:nAt,1],;
					 A080Result(@aResult,aFiltro,oFiltro,nOpcx,aArquivo[oArquivo:nAt]),;
					 oFiltro:Refresh(.T.),;
					 oResult:Refresh(.T.));
	WHEN nOpcx==3 .Or. nOpcx==4				 
	oFiltro:SetArray(aFiltro)
	oFiltro:bLine := { || {if(aFiltro[oFiltro:nAt,1],oOk,oNo),aFiltro[oFiltro:nAt,2] }}
	oFiltro:nFreeze := 1
	
	
	
    @ aObj1Size[3,1], aObj1Size[3,2] TO aObj1Size[3,3], aObj1Size[3,4] OF oDlg LABEL OemtoAnsi(STR0009) PIXEL 	//Segunda Moldura: Filtro
   												 	
	@ aObj3Size[1,1],aObj3Size[1,2] LISTBOX oResult FIELDS HEADER STR0010,STR0012,STR0008,STR0013 SIZE aObj3Size[1,3],aObj3Size[1,4] OF oDlg PIXEL; //"Ordem"###"Campos    "###"Arquivo"###"Tipo"
	ON CHANGE (oOrdem:SetText(aResult[oResult:nAt,1]),cRspOrd:=aResult[oResult:nAt,1],oOrdem:Refresh(.T.),;
				  oTipo:SetText(aResult[oResult:nAt,5]),cRspTipo:=aResult[oResult:nAt,5],oTipo:Refresh(.T.))
	oResult:SetArray(aResult)
	oResult:bLine := { || {aResult[oResult:nAt,1],aResult[oResult:nAt,2],aResult[oResult:nAt,3],aResult[oResult:nAt,5],aResult[oResult:nAt,6]}}												 
	
	@ aObj3Size[2,1], aObj3Size[2,2] SAY OemtoAnsi(STR0010) SIZE 20, 7 OF oDlg PIXEL; //"Ordem"										  
												 FONT oFont COLOR CLR_BLUE												 
									 
	@ aObj3Size[2,1], aObj3Size[2,2]+25 MSGET oOrdem VAR cRspOrd OF oDlg PIXEL;
								   PICTURE "99";
								   VALID (lOk:= A080Ordem(cRspOrd),;
									      If(lOk,aResult:=A080Sort(aResult,cAnt,cRspOrd),.F.),;
										  If(lOk,oResult:Refresh(),.F.));		
								   SIZE 16, 7;
								   WHEN nOpcx ==3 .Or. nOpcx==4				// Inclusao ou Alteracao
	oOrdem:bGotFocus := { || cAnt := aResult[oResult:nAt,1]}							  
	
	@ aObj3Size[2,1], aObj3Size[2,2]+65 SAY OemtoAnsi(STR0011) SIZE 20, 7 OF oDlg PIXEL; //"Tipo "
												 FONT oFont COLOR CLR_BLUE		
												 
	@ aObj3Size[2,1], aObj3Size[2,2]+85 MSGET oTipo VAR cRspTipo OF oDlg PIXEL;
								   PICTURE "@!";
								   VALID (lOk:= A080TpRsp(cRspTipo,aResult[oResult:nAt,4],aResult[oResult:nAt,5]),;
									      If(lOk,aResult:=A080AtuTipo(aResult,cAnt1,cRspTipo,oResult),.F.),;
										  If(lOk,oResult:Refresh(),.F.));		
								   SIZE 16, 7;
								   WHEN (nOpcx ==3 .Or. nOpcx==4) 		// Inclusao ou Alteracao
	oTipo:bGotFocus := { || cAnt1 := aResult[oResult:nAt,5]}							  
     
    
     
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| IF( A080Valid("C") .And. A080Valid("D") .And. A080Grava(nOpcx,aResult),( IIf( __lSX8,ConfirmSX8(),.T.), oDlg:End() ), )  }, {|| nOk:= 0,( IIf(__lSX8,RollBackSX8(),.T.),oDlg:End() )} ))
SETAPILHA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
dbGoto(nReg)

dbSelectArea("SQU") 
dbGoto(nReg)
dbSetOrder(nOrder)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080SX2  ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le o SX2 para preencher o ComboxBox com os arquivos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080SX2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080SX2()
Local aSX2	:= {}
Local i		:= 0

For i := 1 To Len(aPode)
	dbSelectArea("SX2")
	dbSetOrder(1)
	dbSeek(aPode[i])
	Aadd(aSX2,X2Nome())
Next i

Return aSX2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080MontResult  ³ Autor ³ Cristina Ogura ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Array de resultados com os dados do SQU              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080MontResult(ExpC1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Codigo da Pesquisa                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080MontResult(cRspCod)
Local aArray	:= {}
Local cAlias	:= ""
Local aSQX 		:= Rs080aSQX()
Local nx		:= 0            
Local nPos		:= 0
Local cDescSqx	:= ""

dbSelectArea("SQU")
dbSetOrder(1)
If dbSeek(cFilial+cRspCod)
	While !Eof() .And. cFilial+cRspCod == QU_FILIAL+QU_CODIGO
		If !(SubStr(SQU->QU_CAMPO,1,4) == "RS6_")
			dbSelectArea("SX3")
			dbSetOrder(2)
			If	dbSeek(SQU->QU_CAMPO)
				cAlias := "S"+Substr(Alltrim(X3_CAMPO),1,2)
				dbSelectArea("SX2")
				dbSetOrder(1)
				If dbSeek(cAlias)
					If cAlias == "SQM" .And. Len(aSqx) > 0 
						nPos		:= Ascan(aSqx,{|x| x[1] == AllTrim(SQU->QU_FILTRO)})
						cDescSqx	:= If(nPos > 0, aSqx[nPos][2], "")
	
						Aadd(aArray,{SQU->QU_SEQ,AllTrim(X3Titulo())+" ("+cDescSqx+") ",X2Nome(),SQU->QU_CAMPO,SQU->QU_TIPO,AllTrim(SQU->QU_FILTRO)})
						
					Else 
						Aadd(aArray,{SQU->QU_SEQ,X3Titulo(),X2Nome(),SQU->QU_CAMPO,SQU->QU_TIPO,""})				
					EndIf
				EndIf	
			EndIf
		Else
			DbSelectArea("SX2")
			DbSeek("RS6")
			DbSelectArea("RS6")
			cCodAux := SubStr(SQU->QU_CAMPO,5)
			DbSeek(xFilial("RS6")+cCodAux)
			aAdd(aArray,{SQU->QU_SEQ,AllTrim(RS6->RS6_DESC),X2Nome(),SQU->QU_CAMPO,SQU->QU_TIPO,""})
		EndIf	
		dbSelectArea("SQU")
		dbSetOrder(1)
		dbSkip()
	EndDo						 
EndIf

aArray := aSort(aArray,,,{|x,y| x[1] < y[1] })

dbSelectArea("SX3")
dbSetOrder(1)

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Filtro ³ Autor ³ Cristina Ogura      ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o array com os dados do SX3                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Filtro(ExpN1,ExpA1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Elemento escolhido                                      ³±±
±±³          ³ 2- Array com os dados a escolher                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Filtro(nEscol,aResult)
Local aArea		:= GetArea()
Local aArray	:= {}
Local cAlias	:= aPode[nEscol]
Local nPos		:= 0
Local lFlag		:= .F. 
Local lFiltro	:= .F.
Local aSQX 		:= Rs080aSQX() 
Local nx		:= 0

If cAlias <> "RS6"
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While X3_ARQUIVO == cAlias
		lFiltro 	:= .F.
		If X3USO(x3_usado) .And. cNivel >= x3_nivel  
		
		    //Permite apenas selecao de campo Virtual que for Memo
			If x3_context == "V" .And. !("MEMO" $ SX3->X3_CAMPO)
	           dbSkip()
	           Loop
			EndIf		
			
			If cAlias # "SQ3" .And. !(Trim(SX3->X3_CAMPO) $ cString)
				lFiltro := .T.
			ElseIf cAlias == "SQ3" .And. ((Trim(SX3->X3_CAMPO) $ "Q3_CARGO") .Or. SX3->X3_PROPRI == "U")
				lFiltro := .T.        
			EndIf
			
			If lFiltro
				If cAlias == "SQM" .And. Len(aSqx) > 0
				
					// Duplica o mesmo campo conforme Tipos cadastrados
				    For nx := 1 To Len(aSqx)
						lFlag 	:= .F. 
						nPos:= Ascan(aResult,{|x| Alltrim(x[4])+Alltrim(x[6]) == Alltrim(X3_CAMPO)+Alltrim(aSqx[nx][1])})
						If nPos > 0
							lFlag:= .T.		
						EndIf
						AADD(aArray,{lFlag,OemtoAnsi(AllTrim(X3Titulo())+"("+aSqx[nx][2]+")"),X3_CAMPO,X3_TIPO,X3_F3,aSqx[nx][1]})
					Next nx
				
				Else 
				
				  	lFlag 	:= .F.
					nPos	:= Ascan(aResult,{|x| Alltrim(x[4]) == Alltrim(X3_CAMPO)})
			
					If nPos > 0
						lFlag:= .T.		
					EndIf
					AADD(aArray,{lFlag,OemtoAnsi(X3Titulo()),X3_CAMPO,X3_TIPO,X3_F3,""})				
				
				EndIf
			EndIf	
		EndIf	
		dbSkip()
	EndDo
Else
	DbSelectArea("RS6")
	DbGoTop()
	While RS6->(!Eof())
		lFlag 	:= .F. 
		nPos:= Ascan(aResult,{|x| AllTrim(x[4]) == "RS6_" + AllTrim(RS6->RS6_CODIGO)})
		If nPos > 0
			lFlag:= .T.		
		EndIf
		aAdd(aArray,{lFlag,AllTrim(RS6->RS6_DESC),"RS6_" + AllTrim(RS6->RS6_CODIGO),If(RS6->RS6_RESP == "3","M","C"),"",""})
		RS6->(DbSkip())
	EndDo
EndIf
aArray := aSort(aArray,,,{|x,y| x[2] < y[2] })
RestArea(aArea)
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Result ³ Autor ³ Cristina Ogura      ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona no Array de filtros os dados do arquivo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Result(ExpA1,ExpA2,ExpO1,ExpN1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Array de Resultados                                     ³±±
±±³          ³ 2- Array de Filtros                                        ³±±
±±³          ³ 3- Objeto do Filtro                                        ³±±
±±³          ³ 4- Opcao do aRotina                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Result(aArray,aFiltro,oFiltro,nOpcx,cNomeArq)
Local nPos		:= 0
Local lPode		:= aFiltro[oFiltro:nAt,1]
Local cNomeCpo	:= aFiltro[oFiltro:nAt,2]
Local cCampoArq	:= aFiltro[oFiltro:nAt,3]
Local cCodSqx	:= aFiltro[oFiltro:nAt,6]
Local cTipoCpo 	:= ""
Local nTipo		:= 0

If aFiltro[oFiltro:nAt,4] == "M"
	cTipoCpo := "P"					// Procurar por Palavras
ElseIf "RS6_" $ cCampoArq
	cTipoCpo := "S"
ElseIf !Empty(aFiltro[oFiltro:nAt,5])
	nTipo := 	A080VerTipo(Alltrim(aFiltro[oFiltro:nAt,5]))
	If nTipo == 2
		cTipoCpo := "S"	 		// Seleciona
	Else
		cTipoCpo := "F"			// Filtro
	EndIf	
Else					
	cTipoCpo := "F"						// Seleciona
EndIf

If Len(aArray) ==1 .And.	;		// Inclusao
	Empty(aArray[1][3]) .And. Empty(aArray[1][2])
	aDel(aArray,1)
	aSize(aArray,0)
EndIf

nPos:= Ascan(aArray,{|x| Alltrim(x[4])+AllTrim(x[6]) == Alltrim(cCampoArq)+AllTrim(cCodSqx)})
If lPode
	If nPos == 0
		Aadd(aArray,{StrZero(Len(aArray)+1,2),cNomeCpo,cNomeArq,cCampoArq,cTipoCpo,cCodSqx})
	EndIf	
Else
	If nPos > 0
		aDel(aArray,nPos)
		aSize(aArray,Len(aArray)-1)
		A080Reseq(@aArray)
	EndIf	
EndIf                    

If Len(aArray) == 0
	aAdd(aArray,{"01","","","","S",""})
EndIf		

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Reseq³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resequencia o array de resultados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Reseq(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Array de resultados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Reseq(aArray)
Local i
For i := 1 To Len(aArray)	
	aArray[i][1] := StrZero(i,2)
Next i
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Sort ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena os campos do Filtro quando mudar de ordem           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Sort(ExpA1,ExpC1,ExpC2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Array de Filtros                                        ³±±
±±³          ³ 2- Ordem antiga                                            ³±±
±±³          ³ 3- Ordem nova                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Sort(aCampo,cOld,cNew,nTipo)
Local cTmp	:= ""
Local i		:= 0

If cOld == cNew
	Return aCampo
EndIf

If Val(cNew) > Len(aCampo)
	cTmp := aCampo[Len(aCampo),1]
	cNew := StrZero(Len(aCampo),2)+"A"
	aCampo[Len(aCampo),1] := cNew
Else
	cTmp := aCampo[Val(cNew),1]
	If Val(cNew) > Val(cOld)
		aCampo[Val(cNew),1] := cNew
		aCampo[Val(cOld),1] := cNew+"A"
	Else
		aCampo[Val(cNew),1] := cNew+"A"
		aCampo[Val(cOld),1] := cNew
	EndIf
EndIf

aCampo := aSort(aCampo,,,{|x,y| x[1] < y[1] })

For i:= 1 to Len(aCampo)
	aCampo[i,1] := StrZero(i,2)
Next

Return aCampo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080AtuTipo³ Autor ³ Cristina Ogura      ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o tipo de selecao da pesquisa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080AtuTipo(ExpA1,ExpC1,ExpC2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Array de Filtros                                        ³±±
±±³          ³ 2- Tipo antigo                                             ³±±
±±³          ³ 3- Tipo novo                                               ³±±
±±³          ³ 4- Objeto do filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080AtuTipo(aCampo,cOld,cNew,oObj)  

If cOld == cNew
	Return aCampo
EndIf

aCampo[oObj:nAt,5] := cNew

Return aCampo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080bLine³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os dados do Array apos sua alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080bLine(ExpO1,ExpA1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Objeto do Filtro                                        ³±±
±±³          ³ 2- Array dos Filtros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080bLine(oFiltro,aFiltro)
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )

oFiltro:SetArray(aFiltro)
oFiltro:bLine := { || {if(aFiltro[oFiltro:nAt,1],oOk,oNo),aFiltro[oFiltro:nAt,2] }}

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Grava³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os campos do arquivo -SQU                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Grava(ExpN1,ExpA1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Opcao selecionada no aRotina                            ³±±
±±³          ³ 2- Array dos Resultados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080grava(nOpcao,aResult)
Local n	:= 0

dbSelectArea("SQU")
dbSetOrder(1)

If nOpcao == 2 				 			// Visualizacao
	Return .T.
	
ElseIf nOpcao == 3 						// Inclusao
	If nOpcao == 3 .And. Len(aResult) ==1 .And.	;		// Tratamento de Listbox vazio
		Empty(aResult[1][3]) .And. Empty(aResult[1][2])
		Help("",1,"A080AVISO")			// Esta pesquisa nao sera gravado pois nao existe
		Return .F.							// campos selecionados
	EndIf
	For n:=1 To Len(aResult)
		RecLock("SQU",.T.)
			Replace QU_FILIAL 	With cFilial
			Replace QU_CODIGO 	With cRspCod
			Replace QU_DESCRIC	With cRspDesc
			Replace QU_CAMPO	With aResult[n][4]
			Replace QU_SEQ		With StrZero(n,2)
			Replace QU_TIPO		With aResult[n][5]
			Replace QU_FILTRO With aResult[n][6]			
		MsUnlock()	
	Next n
	
ElseIf nOpcao == 4						// Alteracao	
	//Deleta todos os itens 
	If	dbSeek(cFilial+cRspCod)
		While !Eof() .And. cFilial+cRspCod == QU_FILIAL+QU_CODIGO
			RecLock("SQU",.F.,.T.)
				dbDelete()
			MsUnlock()	
			dbSkip()
		EndDo
	EndIf 
	
	//Inclusao da pesquisa
	For n:=1 To Len(aResult)
		If !Empty(aResult[n][4])
			RecLock("SQU",.T.)
				Replace QU_FILIAL 	With cFilial
				Replace QU_CODIGO 	With cRspCod
				Replace QU_DESCRIC	With cRspDesc
				Replace QU_CAMPO	With aResult[n][4]
				Replace QU_SEQ		With StrZero(n,2)
				Replace QU_TIPO		With aResult[n][5]
				Replace QU_FILTRO With aResult[n][6]			
			MsUnlock()	
		EndIf
	Next n

ElseIf nOpcao == 5						// Exclusao
	If	dbSeek(cFilial+cRspCod)
		While !Eof() .And. cFilial+cRspCod == QU_FILIAL+QU_CODIGO
			RecLock("SQU",.F.,.T.)
				dbDelete()
			MsUnlock()	
			dbSkip()
		EndDo
	EndIf
EndIf	

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Valid³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os campos de codigo e descricao se foram preenchidos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Valid(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1- Tipo de Validacao                                       ³±±
±±³          ³     "C" - Codigo                                           ³±±
±±³          ³     "D" - Descricao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Valid(cTipo)

If cTipo == "C" .And. Empty(cRspCod)
	Help("",1,"A080Codigo")			// Codigo da Pesquisa deve ser preenchido antes
	Return .F.							// de comecar a montagem da pesquisa
ElseIf cTipo == "D" .And. Empty(cRspDesc)
	Help("",1,"A080Descri")			// Descricao da Pesquisa deve ser preenchido antes	
	Return .F.							// de comecar a montagem da pesquisa
EndIf		

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Cod  ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o codigo ja existe                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Cod()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Cod()   
Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If Val(cRspCod) <= 0
	Help("",1,"A080CODMAI")	// Codigo de pesquisa deve ser maior que zero
	lRet := .F.
EndIf

dbSelectArea("SQU")
dbSetOrder(1)
If lRet .And. dbSeek(cFilial+cRspCod)
	Help("",1,"A080VERIF")			// Codigo de Pesquisa ja existente
	lRet := .F.
EndIf              

If lRet .And. !FreeForUse("SQU",cRspCod)
	lRet := .F.
EndIf
          
RestArea(aSaveArea) 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Ordem³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a ordem deve ser maior que zero e menor que 99    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Ordem                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080Ordem(cOrdem)
If Val(cOrdem) <=0 .Or. Val(cOrdem) > 99
	Help("",1,"A080ORDEM")		// Ordem deve ser maior que zero e menor que 99
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A080TpRsp ³ Autor ³ Cristina Ogura        ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o tipo de selecao para a pesquisa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080TpRsp                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080TpRsp(cTipo,cCampo,cTipoOri)
If Empty(cTipo) .Or. (!cTipo $ "F/S/P")
	Help("",1,"A080TIPO")		// Verifique o tipo selecionado
	Return .F.
EndIf

If "RS6_" $ cCampo
	If cTipo <> cTipoOri
		MsgInfo( STR0015 , STR0014 ) //ATENÇÃO###"A alteração do tipo deste campo não é permitida"
		Return .F.
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A080VerTipo³ Autor ³ Cristina Ogura       ³ Data ³ 24.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifico se o X3_F3 foi preenchido com tabela ou arquivo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080VerTipo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080VerTipo(cAuxF3)
Local aSaveArea	:= GetArea()
Local nTipo		:= 0

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cAuxF3)
	nTipo := 1
EndIf

If nTipo == 0
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(cFilial+cAuxF3)
		nTipo := 2
	EndIf
EndIf	

RestArea(aSaveArea)

Return nTipo
       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs080aSQX ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 17/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Array com conteudo da Tabela SQX (Tipos de Cursos).³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs080aSQX                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs080aSQX()

Local aSqx 		:= {}
Local aSaveArea := GetArea()
Local aSaveSx2	:= {}

dbSelectArea("SX2")
aSaveSx2 := GetArea()
dbSetOrder(1)
If dbSeek("SQX")	

	dbSelectArea("SQX")
	dbSetOrder(1)
	dbGoTop()
	While ! Eof()
		Aadd(aSQX, {AllTrim(QX_CODIGO), AllTrim(QX_DESC)})
		dbSkip()
	EndDo 
EndIf	
RestArea(aSaveSx2)	             

RestArea(aSaveArea)
Return( aSqx )

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA080                                                     ³
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
Local aRotina 	:=    { 	{ STR0001,"PesqBrw",0,1,,.F.},;	//"Pesquisar"		
							{ STR0002,"A080Rot",0,2},;//"Visualizar"
							{ STR0003,"A080Rot",0,3},;//"Incluir"
							{ STR0004,"A080Rot",0,4},;//"Alterar"
							{ STR0005,"A080Rot",0,5} }//"Excluir"

Return aRotina
