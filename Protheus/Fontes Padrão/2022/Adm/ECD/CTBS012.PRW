#INCLUDE "CTBS012.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"

//Compatibiliza็ใo de fontes 30/05/2018

Static __aPosField := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS012   บAutor  ณEquipe CTB          บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo do c๓digo de HASH                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBS012( cCodRev, cEmp )
Local oWizard 		:= Nil
Local aPWiz1 		:= {}           
Local aRetWiz1		:= {}
Local nOpcRot		:= 0
Local nX			:= 0 
Local lRet			:= .F.
Local aArea			:= GetArea()
Local aAreaCS0		:= CS0->(GetArea())
Local cLivro		:= ""

Private oGetHash := Nil

Default cCodRev := ""            
Default cEmp 	:= ""

If !Empty(cCodRev)
	DbSelectArea("CS0")
	CS0->(dbSetOrder(1))
	CS0->(dbSeek(xFilial("CS0") + cCodRev))
EndIf

cLivro := CS0->CS0_TIPLIV 

If !(CS0->CS0_TIPLIV $ "R/B/A/Z")
	Help("ECDRB",1,"HELP","ECDRB",STR0001,2,0) //" Essa op็ใo ้ somente para os livros R-Diแrio Resumido e B-Balancete Diแrio "
	Return 
EndIf 

//Wizard 1: Confirma็ใo das informa็๕es da escritura็ใo
//Wizard 2: Tabela de HASH

//Wizard 1
aAdd(aPWiz1,{ 1,	STR0002 ,Space(TamSx3('CS0_CODEMP')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Empresa"
aAdd(aPWiz1,{ 1,	STR0003 ,Space(TamSx3('CS0_CODFIL')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Filial"
aAdd(aPWiz1,{ 1,	STR0004 ,Space(TamSx3('CS0_CODREV')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Revisao"
aAdd(aPWiz1,{ 1,	STR0005	,Space(TamSx3('CS0_TPESC')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Tipo Escrituracao"

aAdd(aRetWiz1,CS0->CS0_CODEMP)
aAdd(aRetWiz1,CS0->CS0_CODFIL)
aAdd(aRetWiz1,CS0->CS0_CODREV)
aAdd(aRetWiz1,CS0->CS0_TPESC)

DEFINE WIZARD oWizard TITLE STR0006; //"Escritura็ใo"
       HEADER STR0007 ;  //"Gera็ใo de Arquivo Texto"
       MESSAGE STR0008 	 ; //"Parโmetros Iniciais..."
       TEXT STR0009; //"Essa rotina tem o objetivo de gerar o arquivo texto da escritura็ใo"
       NEXT {||.T.} ;
       FINISH {|| .F. } ;
       PANEL

	//Wizard 1
   CREATE PANEL oWizard ;
          HEADER STR0010;  //"Dados da Escritura็ใo"
          MESSAGE ""; 
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .F. } ;
          PANEL
	
	//Wizard 2
   CREATE PANEL oWizard ;
          HEADER STR0011; //"Dados do Arquivo"
          MESSAGE ""; 
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| ECDHashVal(@nOpcRot) } ;
          PANEL
	

ParamBox(aPWiz1,STR0012,@aRetWiz1,,,,,,oWizard:GetPanel(2)) //"Parโmetros..."
ECDHashBrowse(cCodRev, oWizard:GetPanel(3), cEmp, cLivro) 

ACTIVATE WIZARD oWizard CENTERED

If nOpcRot == 1
	lRet := ECDHashGrv(cCodRev)
EndIf
      
RestArea(aAreaCS0)
RestArea(aArea)

//atribui NIL para variavel static que contem posicao dos campos - FIELDPOS
__aPosField := NIL

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDHashBrowseบAutorณEquipe CTB         บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a grid para preencher com os c๓digos de hash          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ECDHashBrowse(cCodRev, oDlg, cEmp, cLivro )
Local aHeader 		:= CriaAHeader()
Local aCols	  		:= CriaACols(aHeader,cCodRev)
Local nOpcX			:= GD_INSERT+GD_UPDATE+GD_DELETE       	// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "ECDHashLOK()"					    // Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"					 	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local nFreeze      	:= 000              					// Campos estaticos na GetDados.
Local nMax         	:= 9999             					// Numero maximo de linhas permitidas.
Local aAlter     	:= {}	                            	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						// Funcao executada na validacao do campo
Local cSuperDel    	:= "AllwaysTrue"          			   	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= "AllwaysTrue"    					// Funcao executada para validar a exclusao de uma linha do aCols
Local nX		  	:= 0 
Local aHeaderAux   	:= {} 
Local nPos			:= 1 

Default cLivro := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona os campos a serem atualizados pelo usuario na MsNewGetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aHeader)
	If (aHeader[nX,2] != "CS1_NUMLIN")
		aAdd(aAlter,aHeader[nX,2])
	EndIf
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMsNewGetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetHash	:= MsNewGetDados():New(0,0,125,288,nOpcX,cLinhaOk,cTudoOk,"+CS1_NUMLIN",aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols) 
aHeaderAux 	:= oGetHash:aHeader //aHeader com o nome da coluna
nPos 		:= aScan(aHeaderAux, {|x| Alltrim(x[2]) == "CS1_NUMLIN" })// informa a coluna a ser informada

If AliasInDic("CSJ") .And. CS0->CS0_TIPLIV != "Z"
	@ 126,002 BUTTON "Sel.Conta" SIZE 040,012 ACTION {||CTBS060BR( cEmp, cCodRev, oGetHash:aCols[oGetHash:nAt][nPos], cLivro )} PIXEL OF oDlg
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAHeaderบAutor ณAlvaro Camillo Neto บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aHeader para a Getdados de livros auxiliares         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SpedGetLAux                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAHeader()
Local aHeader 	:= {}
Local aArea		:= GetArea() 
Local aAreaSX3	:= SX3->(GetArea())
Local cAlias   	:= "CS1"

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If ( X3USO(SX3->X3_USADO) ) .AND. ALLTRIM(SX3->X3_CAMPO) != "CS1_CODREV" 
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;		// 02 - Campo
		SX3->X3_Picture	, ;		// 03 - Picture
		SX3->X3_TAMANHO	, ;		// 04 - Tamanho
		SX3->X3_DECIMAL	, ;		// 05 - Decimal
		SX3->X3_Valid  	, ;		// 06 - Valid
		SX3->X3_USADO  	, ;		// 07 - Usado
		SX3->X3_TIPO   	, ;		// 08 - Tipo
		SX3->X3_F3		, ;	    // 09 - F3
		SX3->X3_CONTEXT , ;    	// 10 - Contexto
		SX3->X3_CBOX	, ; 	// 11 - ComboBox
		SX3->X3_RELACAO , } ) 	// 12 - Relacao	
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)


RestArea(aAreaSX3)
RestArea(aArea)
Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaACols  บAutor ณAlvaro Camillo Neto บ Data ณ  08/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aCols   para a Getdados de livros auxiliares         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SpedGetLAux                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaACols(aHeader,cCodRev)
Local 	nX			:= 0
Local 	nCols   	:= 0
Local 	aCols		:= {}
Local 	aArea		:= GetArea()
Local 	aAreaCS0	:= CS0->(GetArea())
Local   cFIlCS1  	:= xFilial("CS1")
Local  nPosCpo 	:= 0

//array static para colocar a posicao do campo - FIELDPOS
//sera utilizado no proximo laco da CS1
//tratado como excessao
If __aPosField == NIL

	__aPosField := Array( Len(aHeader) )

	For nX := 1 To Len(__aPosField)
		nPosCpo := CS1->(FieldPos( aHeader[nX][2] )) 	
		__aPosField[nX] := nPosCpo 	
	Next nX

EndIf

CS1->(dbSetOrder(2))
IF CS1->(dbSeek( cFIlCS1 + cCodRev ) )
	While CS1->(!Eof()) .And. ALLTRIM(CS1->( CS1_FILIAL + CS1_CODREV )) == ALLTRIM( cFIlCS1 + cCodRev )
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		If __aPosField != NIL
			For nX := 1 To Len(aHeader)
				If __aPosField[nX] > 0
					aCols[nCols][nX] := CS1->(FieldGet( __aPosField[nX] ))
				EndIf	
			Next nX
		EndIf
		aCols[nCols][Len(aHeader)+1] := .F.
		CS1->(dbSkip())
	End
Else
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		If Alltrim(aHeader[nX][2]) == "CS1_NUMLIN"
			aCols[1][nX] := "0001"
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIF
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
EndIf

RestArea(aAreaCS0)
RestArea(aArea)
Return aCols 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDHashLOKบAutor  ณAlvaro Camillo Neto บ Data ณ  08/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a linha da getdados de livros auxiliares            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ECDHashLOK(nAt)
Local aCols	  		:= oGetHash:aCols 
Local aHeader  		:= oGetHash:aHeader	
Local nPosNatureza 	:= Ascan(aHeader, {|x| x[2] == "CS1_NATLIV" })		
Local nPosTipo 		:= Ascan(aHeader, {|x| x[2] == "CS1_TIPAUX" })		
Local nPosHash 		:= Ascan(aHeader, {|x| x[2] == "CS1_CODHAS" })
Local nPosOrdem		:= Ascan(aHeader, {|x| x[2] == "CS1_NUMLIV" })
Local lRet 			:= .T.
Local nPosLiv		:= 0
Local cOrdem		:= ""
Local nX			:= 0 
Local cNatureza		:= ""

Default nAt := oGetHash:nAt
	
If lRet .And. Empty(aCols[nAT][nPosTipo])
	lRet := .F.
	Help("ECDLivAux",1,"HELP","ECDLivAux",STR0018 + cvalTochar(nAT)+STR0013,2,0)  //" o campo Tipo ้ obrigat๓rio "
EndIf

If lRet .And. Empty(aCols[nAT][nPosNatureza])
	lRet := .F.
	Help("ECDLivAux",1,"HELP","ECDLivAux",STR0018 + cvalTochar(nAT)+STR0014,2,0) //" o campo Natureza ้ obrigat๓rio "
EndIf

If CS0->CS0_TIPLIV != "Z"
	If lRet .And. aCols[nAT][nPosTipo] == "0" .And. Empty(aCols[nAT][nPosHash])
		lRet := .F.
		Help("ECDLivAux",1,"HELP","ECDLivAux",STR0018 + cvalTochar(nAT)+STR0015+CRLF+STR0016,2,0)   	 //" o campo Hash ้ obrigat๓rio "###" pois o tipo do livro ้ 0-Digital"
	EndIf
Else
	//Livro Z nao deve ser informado o codigo hash
	If lRet .And. aCols[nAT][nPosTipo] == "0" .And. !Empty(aCols[nAT][nPosHash])
		lRet := .F.
		Help("ECDLivAux",1,"HELP","ECDLivAux","Para Livro Z nใo deve ser informado o Campo Hash.",2,0)   	 //"Para Livro Z nใo deve ser informado o Campo Hash."
	EndIf
EndIf

If lRet
	cOrdem 		:= aCols[nAt][nPosOrdem]
	cNatureza   := aCols[nAt][nPosNatureza]
	For nX := 1 to Len(aCols)
		If Alltrim(aCols[nX][nPosOrdem]) == Alltrim(cOrdem) .And. Alltrim(aCols[nX][nPosNatureza]) == Alltrim(cNatureza);
		 .And. nX != nAt .And. !(aCols[nX][Len(aHeader) + 1]) .And. !(aCols[nAt][Len(aHeader) + 1])
		 
			lRet := .F.
  			Help("ECDLivAux",1,"HELP","ECDLivAux",STR0018 + cvalTochar(nX)+STR0017,2,0) //" hแ um livro com a mesma ordem "
  			Exit  	
		EndIf 
	Next nX
EndIf   

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDHashValบAutor  ณEquipe CTB          บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida toda a tabela de HASH para permitir ou nao a grava็ใoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ECDHashVal(nOpcRot)
Local lRet 		:= .T.
Local nX	  		:= 0
Local aCols	  	:= oGetHash:aCols 

For nX := 1 to Len(aCols)
	If !ECDHashLOK(nX)	
		lRet := .F.
		Exit
	EndIf
Next nX

If lRet
	nOpcRot := 1
EndIf

Return lRet  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECDHashGrvบAutor  ณEquipe CTB          บ Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a grava็ใo dos Hash da escritura็ใo                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ECDHashGrv(cCodRev)
Local aCols	  		:= oGetHash:aCols 
Local aHeader  		:= oGetHash:aHeader	
Local lGrava 		:= .T. 
Local nX		  	:= 0

CS1->(dbSetOrder(2)) //CS1_FILIAL+CS1_CODREV+CS1_NUMLIV+CS1_NATLIV 
For nX:= 1 to Len(aCols)
	lGrava := (CS1->(dbSeek(xFilial("CS1") + cCodRev +Acols[nX,1]+Acols[nX,2]) ) )

	If Acols[nX,Len(aHeader)+1] .And. lGrava
			RecLock("CS1",!lGrava)
			CS1->( dbDelete() )
			MsUnlock()
	ElseIf !Acols[nX,Len(aHeader)+1] 
		RecLock("CS1",!lGrava)
		CS1->CS1_NUMLIN := Acols[nX,1]
		CS1->CS1_NUMLIV := Acols[nX,2]
		CS1->CS1_TIPAUX := Acols[nX,3]
		CS1->CS1_NATLIV := Acols[nX,4]
		CS1->CS1_CODHAS := Acols[nX,5]
		CS1->CS1_FILIAL := xFilial("CS1")
		CS1->CS1_CODREV := cCodRev
		MsUnLock()
	EndIf
Next nX

Return
 
