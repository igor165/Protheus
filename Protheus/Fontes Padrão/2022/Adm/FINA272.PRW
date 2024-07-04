#include "Fina272.Ch"
#Include "Protheus.Ch"

#Define LINEBREAK Chr(10)+Chr(13)

STATIC oFIN272TMP := NIL    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA272   บAutor  ณTOTVS		         บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de importacao do fluxo orcamentario por natureza do  บฑฑ
ฑฑบ          ณPCO - Planejamento e Controle Orcamentario para o Financeiroบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA272()

Private cTitulo := STR0001 //"Natureza X Contas Or็amentแrias" 
Private cAlias	:= "SED"
PRIVATE aRotina		:= MenuDef() 
Private bCampo 	:= {|nField| FieldName(nField) } 
                                                                          

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA O TAMANHO DA TELAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aSize    := {}
Private aObjects := {}
Private aInfo    := {}
Private aPosObj  := {}
Private aPosGet  := {}

If !( TableIndic("F73") )
	HELP(" ",1,STR0001 ,, STR0076 ,2,0,,,,,,{ STR0077 }) // "FINA272-Natureza X Contas Or็amentแrias" # "Dicionแrio Desatualizado" # "Migrar para Protheus 12.1.27 - Abril 2021"
	Return .F.
Else
	aSize := MsAdvSize()
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	aAdd(aObjects,{80,40,.T.,.F.})
	aAdd(aObjects,{100,120,.T.,.T.})

	aPosObj := MsObjSize(aInfo,aObjects)
	aPosGet := MsObjGetPos((aSize[3]-aSize[1]),315,{{004,024,240,270}} )

	dbSelectArea("F73")
	dbSelectArea(cAlias)//SED
	dbSetOrder(1)//ED_FILIAL+ED_CODIGO  

	MBrowse(,,,,cAlias,,,,,,) 

	If !EMPTY(oFIN272TMP)
		oFIN272TMP:Delete()
		oFIN272TMP := NIL
	EndIf
Endif	

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272INC บAutor  ณTOTVS			     บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Natureza X Contas Orcamentarias                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272INC( cAlias, nReg, nOpc )

Local oDlg                                                 

Local oGet 
Local nX 		:= 0 
Local nOpcA 	:= 0    

Private aHeader := {} 
Private aCols 	:= {} 
Private aGets 	:= {} 
Private aTela 	:= {}                  
Private aCampos	:= {"NOUSER","ED_CODIGO","ED_DESCRIC"} 	//VETOR COM OS CAMPOS QUE APARECEM NO CABECALHO 
          
F73->(dbSetOrder(1))//F73_FILIAL+F73_NATUR+F73_ITEM
F73->(dbSeek(xFilial()+SED->ED_CODIGO))   

If nOpc == 3 .And.(F73->(!EOF()))
  
	Aviso("SIGAFIN",STR0003 + LINEBREAK + STR0004,{"Ok"}) //"Jแ existe amarra็ใo para esta Natureza."###"Disponํvel apenas Alterar."
	Return
	
EndIf  

dbSelectArea( cAlias )//SED
dbSetOrder(1)//ED_FILIAL+ED_CODIGO
         
For nX := 1 To FCount() 
	M->&( Eval( bCampo, nX ) ) := FieldGet( nX ) 
Next nX 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem dos Vetores de aHeader e aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FIN272HEAD() 
FIN272COLS( nOpc ) 

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL 

EnChoice( cAlias, nReg, nOpc, , , ,aCampos , aPosObj[1],{}) 
// Atualiza็ใo do nome do cliente  
  
oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"FIN272LOK","FIN272TOK","+F73_ITEM",.T.) 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
{|| IIF( FIN272TOK() .And. Obrigatorio( aGets, aTela ), ( nOpcA := 1, INCLUI := .F. , oDlg:End() ), NIL) },{|| oDlg:End() }) 

If nOpcA == 1 .And. nOpc == 3 

   	FIN272GRV( nOpc ) 

Endif 

Return           
   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272MNT บAutor  ณTOTVS		         บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao da tela amarracao Natureza X Conta Orcamentaria  บฑฑ
ฑฑบ          ณVisualizacao, Alteracao e Exclusao                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272MNT(cAlias, nReg, nOpc)

Local oDlg 
Local oGet 
Local nX := 0 
Local nOpcA := 0     

Private aHeader := {} 
Private aCOLS := {} 
Private aGets := {} 
Private aTela := {} 
Private aREG := {}      
Private aCampos	:= {"NOUSER","ED_CODIGO","ED_DESCRIC"} 	//VETOR COM OS CAMPOS QUE APARECEM NO CABECALHO 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA SE EXISTE RELACIONAMENTOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
F73->(dbSetOrder(1))//F73_FILIAL+F73_NATUR+F73_ITEM
F73->(dbSeek(xFilial()+SED->ED_CODIGO))   

If (nOpc == 4 .Or. nOpc == 5) .And.(F73->(EOF()))
   
	Aviso("SIGAFIN",STR0052 + LINEBREAK + STR0005,{"Ok"}) //"Nใo existe amarra็ใo para esta Natureza."###"Disponํvel apenas Incluir."
	Return  
	
EndIf  

dbSelectArea( cAlias )//SED
dbSetOrder(1)//ED_FILIAL+ED_CODIGO

For nX := 1 To FCount() 
	M->&( Eval( bCampo, nX ) ) := FieldGet( nX ) 
Next nX 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem dos Vetores de aHeader e aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FIN272HEAD() 
FIN272COLS( nOpc ) 

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL 

EnChoice( cAlias, nReg, nOpc, , , ,aCampos, aPosObj[1],{}) 
// Atualiza็ใo do nome do cliente 

oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"FIN272LOK","FIN272TOK","+F73_ITEM",.T.)
 
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,; 
{|| IIF( FIN272TOK() .And. Obrigatorio( aGets, aTela ), ( nOpcA := 1, oDlg:End() ), NIL ) },; 
{|| oDlg:End() }) 

If nOpcA == 1 .And. ( nOpc == 4 .Or. nOpc == 5 ) 
	FIN272GRV( nOpc ) 
Endif 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272HEADบAutor  ณTOTVS		         บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetor do aHeader.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272HEAD() 

Local aArea := GetArea() 

dbSelectArea("SX3") 
dbSetOrder(1) 

dbSeek("F73") 
While !EOF() .And. X3_ARQUIVO == "F73" 

	If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL .And.;
	   !(Alltrim(X3_CAMPO) $ "F73_NATUR/F73_DESNAT")    
 
		AADD( aHeader, { Trim( X3Titulo() ),; 
		X3_CAMPO,; 
		X3_PICTURE,; 
		X3_TAMANHO,; 
		X3_DECIMAL,; 
		X3_VALID,; 
		X3_USADO,; 
		X3_TIPO,; 
		X3_ARQUIVO,; 
		X3_CONTEXT}) 
	
	Endif 

	dbSkip() 

End 

RestArea(aArea) 

Return          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272COLSบAutor  ณTOTVS		         บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o vetor aCols.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272COLS( nOpc )    

Local aArea := GetArea() 
Local cChave := "" 
Local cAlias := "F73" 
Local nI := 0 

If nOpc <> 3 

	cChave := SED->ED_CODIGO

	dbSelectArea( cAlias ) 
	dbSetOrder(1) 
	dbSeek( xFilial( cAlias ) + cChave )

	While !EOF() .And. F73->( F73_FILIAL + F73_NATUR ) == xFilial( cAlias ) + cChave 
		AADD( aREG, F73->( RecNo() ) ) 
		AADD( aCOLS, Array( Len( aHeader ) + 1 ) ) 

		For nI := 1 To Len( aHeader ) 

			If aHeader[nI,10] == "V" 
				aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.) 
			Else 
				aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2])) 
			Endif

		Next nI

		aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.
		dbSkip() 

	End                                                          

Else 

	AADD( aCOLS, Array( Len( aHeader ) + 1 ) ) 

	For nI := 1 To Len( aHeader ) 
		aCOLS[1, nI] := CriaVar( aHeader[nI, 2], .T. ) 
	Next nI 

	aCOLS[1, GdFieldPos("F73_ITEM")] := "0001" 
	aCOLS[1, Len( aHeader )+1 ] := .F.   

Endif 

Restarea( aArea ) 

Return        
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272GRV บAutor  ณTOTVS		         บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o relacionamento entre Natureza X Conta Orcamentaria. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272GRV( nOpc ) 

Local nX := 0 
Local nI := 0 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณnOpc == 3 Se for INCLUSAOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 3 
	
	dbSelectArea("F73") 
	dbSetOrder(1)//F73_FILIAL+F73_NATUR+F73_ITEM 
	
	For nX := 1 To Len( aCOLS ) 
	
		RecLock( "F73", .T. ) 
	
		For nI := 1 To Len( aHeader ) 
			FieldPut( FieldPos( Trim( aHeader[nI, 2] ) ), aCOLS[nX,nI] ) 
		Next nI 
		F73->F73_FILIAL := xFilial("F73")
		F73->F73_NATUR := M->ED_CODIGO
	
		MsUnLock()
	
	Next nX 
	
EndIf          

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณnOpc == 4 Se for ALTERACAOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 4 

	dbSelectArea("F73") 
	dbSetOrder(1)//F73_FILIAL+F73_NATUR+F73_ITEM  
	
	For nX := 1 To Len( aCOLS ) 

		If nX <= Len( aREG ) 
			dbGoto( aREG[nX] ) 
			RecLock("F73",.F.) 
			If aCOLS[ nX, Len( aHeader ) + 1 ] 
				dbDelete() 
			Endif 
		Else
			If !aCOLS[ nX, Len( aHeader ) + 1 ] 
				RecLock( "F73", .T. ) 
			Endif 
		Endif               
		
		If !aCOLS[ nX, Len(aHeader)+1 ] 
			For nI := 1 To Len( aHeader ) 
				FieldPut( FieldPos( Trim( aHeader[ nI, 2] ) ),; 
				aCOLS[ nX, nI ] ) 
			Next nI 
			F73->F73_FILIAL	:= xFilial("F73")
			F73->F73_NATUR 	:= M->ED_CODIGO   

		Endif 

		MsUnLock() 

	Next nX
Endif                 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณnOpc == 5 Se for EXCLUSAOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 5 

	dbSelectArea("F73") 
	dbSetOrder(1)//F73_FILIAL+F73_NATUR+F73_ITEM
	dbSeek(xFilial("F73") + M->ED_CODIGO) 
	
	While !EOF() .And. F73->(F73_FILIAL + F73_NATUR) == xFilial("F73") + M->ED_CODIGO
		RecLock("F73") 
		
		dbDelete() 
		
		MsUnLock() 
		dbSkip() 
	End 

Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272VLD บAutor  ณTOTVS			     บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao com as validacoes dos campos da tabela F73.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272VLD(cCampo)

Local lRet	:= .T.
            
If !aCols[n][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVALIDA CONTA ORCAMENTARIA INICIAL E FINALณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cCampo == "F73_COINI") .And. !Empty(aCols[n][GdFieldPos("F73_COFIM")]) .And. (aCols[n][GdFieldPos("F73_COFIM")] < M->F73_COINI )
	
		Help( ,, 'HELP',, STR0006 , 1, 0) //'A Conta Or็amentแria inicial deve ser menor ou igual a Conta Or็amentแira final. '
		lRet := .F.
	
	EndIf
	
	If (cCampo == "F73_COFIM") .And. (	aCols[n][GdFieldPos("F73_COINI")] > M->F73_COFIM )
	
		Help( ,, 'HELP',, STR0007 , 1, 0) //'A Conta Or็amentแria final deve ser maior ou igual a Conta Or็amentแria inicial. '
		lRet := .F.
	
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVALIDA CENTRO DE CUSTO INICIAL E FINALณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cCampo == "F73_CCINI") .And. !Empty(aCols[n][GdFieldPos("F73_CCFIM")]) .And. (aCols[n][GdFieldPos("F73_CCFIM")] < M->F73_CCINI )
	
		Help( ,, 'HELP',, STR0008 , 1, 0) //'O Centro de Custo inicial deve ser menor ou igual ao Centro de Custo final. '
		lRet := .F.
	
	EndIf
	
	If (cCampo == "F73_CCFIM") .And. (	aCols[n][GdFieldPos("F73_CCINI")] > M->F73_CCFIM )
	
		Help( ,, 'HELP',, STR0009, 1, 0) //'O Centro de Custo final deve ser maior ou igual ao Centro de Custo inicial. '
		lRet := .F.
	
	EndIf    
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVALIDA ITEM CONTABIL INICIAL E FINALณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cCampo == "F73_ITCTBI") .And. !Empty(aCols[n][GdFieldPos("F73_ITCTBF")]) .And. (aCols[n][GdFieldPos("F73_ITCTBF")] < M->F73_ITCTBI )
	
		Help( ,, 'HELP',, STR0010, 1, 0) //'O Item Contแbil inicial deve ser menor ou igual ao Item Contแbil final. '
		lRet := .F.
	
	EndIf
	
	If (cCampo == "F73_ITCTBF") .And. (	aCols[n][GdFieldPos("F73_ITCTBI")] > M->F73_ITCTBF )
	
		Help( ,, 'HELP',, STR0011, 1, 0) //'O Item Contแbil final deve ser maior ou igual ao Item Contแbil inicial. '
		lRet := .F.
	
	EndIf    
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVALIDA CLASSE DE VALOR INICIAL E FINALณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cCampo == "F73_CLVRLI") .And. !Empty(aCols[n][GdFieldPos("F73_CLVRLF")]) .And. (aCols[n][GdFieldPos("F73_CLVRLF")] < M->F73_CLVRLI )
	
		Help( ,, 'HELP',, STR0012, 1, 0) //'A Classe de Valor inicial deve ser menor ou igual a Classe de Valor final. '
		lRet := .F.
	
	EndIf
	
	If (cCampo == "F73_CLVRLF") .And. (	aCols[n][GdFieldPos("F73_CLVRLI")] > M->F73_CLVRLF )
	
		Help( ,, 'HELP',, STR0013, 1, 0) //'A Classe de Valor final deve ser maior ou igual a Classe de Valor inicial. '
		lRet := .F.
	
	EndIf   

EndIf 
	
Return lRet      
                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272LOK บAutor  ณTOTVS		         บ Data ณ  10/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a linha do aCols.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272LOK()

Local lRet	:= .T.                
Local ni,nx

If Empty(aCols[n][GdFieldPos("F73_COINI")]) .Or. Empty(aCols[n][GdFieldPos("F73_COFIM")])

	Help( ,, 'HELP',, STR0014 , 1, 0) //'As Contas Or็amentแrias inicial e final devem estar preenchidas. '
	lRet := .F.     

EndIf      

If (Empty(aCols[n][GdFieldPos("F73_CCINI")]) .And. !Empty(aCols[n][GdFieldPos("F73_CCFIM")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_CCINI")]) .And. Empty(aCols[n][GdFieldPos("F73_CCFIM")]))

	Help( ,, 'HELP',, STR0015, 1, 0) //'O Centro de Custo inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf      

If (Empty(aCols[n][GdFieldPos("F73_ITCTBI")]) .And. !Empty(aCols[n][GdFieldPos("F73_ITCTBF")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_ITCTBI")]) .And. Empty(aCols[n][GdFieldPos("F73_ITCTBF")]))

	Help( ,, 'HELP',, STR0016, 1, 0) //'O Item Contแbil inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf   

If (Empty(aCols[n][GdFieldPos("F73_CLVRLI")]) .And. !Empty(aCols[n][GdFieldPos("F73_CLVRLF")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_CLVRLI")]) .And. Empty(aCols[n][GdFieldPos("F73_CLVRLF")]))

	Help( ,, 'HELP',, STR0017, 1, 0) //'A Classe de Valor inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf                        
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA OS CAMPOS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 To Len(aCols)-1     

	If !aCols[nI][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
         
		For nX := nI+1 To Len(aCols)
		       
			If !aCols[nX][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVERIFICA CONJUNTO DE CONTA ORCAMENTARIAณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If FIN272VLG(aCols[nI][GdFieldPos("F73_COINI")], aCols[nI][GdFieldPos("F73_COFIM")],;
					         aCols[nX][GdFieldPos("F73_COINI")], aCols[nX][GdFieldPos("F73_COFIM")])
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVERIFICA CONJUNTO DE CLASSEณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If	(aCols[nX][GdFieldPos("F73_CLASSE")] == aCols[nI][GdFieldPos("F73_CLASSE")]) .Or.;
						(Empty(aCols[nX][GdFieldPos("F73_CLASSE")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLASSE")]))
					
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	                    //ณVERIFICA CONJUNTO DE CENTRO DE CUSTOณ
     					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If 	FIN272VLG(aCols[nI][GdFieldPos("F73_CCINI")], aCols[nI][GdFieldPos("F73_CCFIM")],;
							         aCols[nX][GdFieldPos("F73_CCINI")], aCols[nX][GdFieldPos("F73_CCFIM")]).Or.;
					  		(Empty(aCols[nX][GdFieldPos("F73_CCINI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CCINI")])) .Or.;
					  		(Empty(aCols[nX][GdFieldPos("F73_CCFIM")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CCFIM")]))

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณVERIFICA CONJUNTO DE ITEM CONTABILณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If 	FIN272VLG(aCols[nI][GdFieldPos("F73_ITCTBI")], aCols[nI][GdFieldPos("F73_ITCTBF")],;
							     		  aCols[nX][GdFieldPos("F73_ITCTBI")], aCols[nX][GdFieldPos("F73_ITCTBF")]).Or.;
						  		(Empty(aCols[nX][GdFieldPos("F73_ITCTBI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_ITCTBI")])) .Or.;
						  		(Empty(aCols[nX][GdFieldPos("F73_ITCTBF")]) .Or. Empty(aCols[nI][GdFieldPos("F73_ITCTBF")]))

								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณVERIFICA CONJUNTO DE CLASSE DE VALORณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If 	FIN272VLG(aCols[nI][GdFieldPos("F73_CLVRLI")], aCols[nI][GdFieldPos("F73_CLVRLF")],;
								     		  aCols[nX][GdFieldPos("F73_CLVRLI")], aCols[nX][GdFieldPos("F73_CLVRLF")]).Or.;
							  		(Empty(aCols[nX][GdFieldPos("F73_CLVRLI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLVRLI")])) .Or.;
							  		(Empty(aCols[nX][GdFieldPos("F73_CLVRLF")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLVRLF")]))

								   	Help( ,, 'HELP',, STR0018 + LINEBREAK + LINEBREAK +; //'Amarra็ใo invแlida para os Itens: '
								   		 aCols[nI][GdFieldPos("F73_ITEM")]+LINEBREAK+aCols[nX][GdFieldPos("F73_ITEM")] , 1, 0)
									
									lRet := .F.
									Exit    
								
							    EndIf
																														
							EndIf    
						
						EndIf					
						
					EndIf
			
				EndIf
  				 
			EndIf
		
		Next nX

	EndIf      
	
	If !lRet//SE FALSO, TERMINA A VERIFICACAO
	     
		Exit
	
	EndIf   
	
Next nI
               
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVALIDA OS CAMPOS DA TABELA F73 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet//SE FALSO, TERMINA A VERIFICACAO
	F73->(dbGoTop())//POSICIONA NO PRIMEIRO REGISTRO DA F73
	
	While F73->(!EOF())
	
		If !(M->ED_CODIGO == F73->F73_NATUR)
		
			For nI := 1 To Len(aCols)   
			
				If !aCols[nI][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVERIFICA CONJUNTO DE CONTA ORCAMENTARIAณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If 	FIN272VLG(F73->F73_COINI, F73->F73_COFIM, aCols[nI][GdFieldPos("F73_COINI")], aCols[nI][GdFieldPos("F73_COFIM")])

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVERIFICA CONJUNTO DE CLASSEณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
						If	(aCols[nI][GdFieldPos("F73_CLASSE")] == F73->F73_CLASSE) .Or.;
							(Empty(aCols[nI][GdFieldPos("F73_CLASSE")]) .Or. Empty(F73->F73_CLASSE))
						     
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณVERIFICA CONJUNTO DE CENTRO DE CUSTOณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If 	FIN272VLG(F73->F73_CCINI, F73->F73_CCFIM, aCols[nI][GdFieldPos("F73_CCINI")], aCols[nI][GdFieldPos("F73_CCFIM")]) .Or.;
						  		(Empty(aCols[nI][GdFieldPos("F73_CCINI")]) .Or. Empty(F73->F73_CCINI)) .Or.;
						  		(Empty(aCols[nI][GdFieldPos("F73_CCFIM")]) .Or. Empty(F73->F73_CCFIM))

								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณVERIFICA CONJUNTO DE ITEM CONTABILณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If 	FIN272VLG(F73->F73_ITCTBI, F73->F73_ITCTBF, aCols[nI][GdFieldPos("F73_ITCTBI")], aCols[nI][GdFieldPos("F73_ITCTBF")]) .Or.;
							  		(Empty(aCols[nI][GdFieldPos("F73_ITCTBI")]) .Or. Empty(F73->F73_ITCTBI)) .Or.;
							  		(Empty(aCols[nI][GdFieldPos("F73_ITCTBF")]) .Or. Empty(F73->F73_ITCTBF))

									//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
									//ณVERIFICA CONJUNTO DE CLASSE DE VALORณ
									//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
									If 	FIN272VLG(F73->F73_CLVRLI, F73->F73_CLVRLF, aCols[nI][GdFieldPos("F73_CLVRLI")], aCols[nI][GdFieldPos("F73_CLVRLF")]) .Or.;
								  		(Empty(aCols[nI][GdFieldPos("F73_CLVRLI")]) .Or. Empty(F73->F73_CLVRLI)) .Or.;
								  		(Empty(aCols[nI][GdFieldPos("F73_CLVRLF")]) .Or. Empty(F73->F73_CLVRLF))

									   	Help( ,, 'HELP',, STR0018 + LINEBREAK + LINEBREAK +; //'Amarra็ใo invแlida para os Itens: '
									   		 aCols[nI][GdFieldPos("F73_ITEM")]+LINEBREAK+F73->F73_ITEM+ STR0053 +F73->F73_NATUR , 1, 0) //" \ Natureza: "
										lRet := .F.									     
										Exit    
									
								    EndIf
						     	
						     	EndIf
						
							EndIf        
						
						EndIf				
					
					EndIf						
				
				EndIf	
			
			Next nI
			
		EndIf
		
		If !lRet//SE FALSO, TERMINA A VERIFICACAO
		     
			Exit
		
		EndIf            
		F73->(dbSkip())
	
	End

EndIf

Return lRet
               

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272TOK บAutor  ณTotvs		         บ Data ณ  10/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida todas as linhas da getDados.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272TOK()

Local lRet	:= .T.
Local nI    
Local nX
         
If Empty(aCols[n][GdFieldPos("F73_COINI")]) .Or. Empty(aCols[n][GdFieldPos("F73_COFIM")])

	Help( ,, 'HELP',, STR0019, 1, 0) //'As Contas Or็amentแrias inicial e final devem estar preenchidas. '
	lRet := .F.     

EndIf      

If (Empty(aCols[n][GdFieldPos("F73_CCINI")]) .And. !Empty(aCols[n][GdFieldPos("F73_CCFIM")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_CCINI")]) .And. Empty(aCols[n][GdFieldPos("F73_CCFIM")]))

	Help( ,, 'HELP',, STR0020, 1, 0) //'O Centro de Custo inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf      

If (Empty(aCols[n][GdFieldPos("F73_ITCTBI")]) .And. !Empty(aCols[n][GdFieldPos("F73_ITCTBF")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_ITCTBI")]) .And. Empty(aCols[n][GdFieldPos("F73_ITCTBF")]))

	Help( ,, 'HELP',, STR0021, 1, 0) //'O Item Contแbil inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf   

If (Empty(aCols[n][GdFieldPos("F73_CLVRLI")]) .And. !Empty(aCols[n][GdFieldPos("F73_CLVRLF")])) .Or. (!Empty(aCols[n][GdFieldPos("F73_CLVRLI")]) .And. Empty(aCols[n][GdFieldPos("F73_CLVRLF")]))

	Help( ,, 'HELP',, STR0022, 1, 0) //'A Classe de Valor inicial e final devem estar preenchidos ou vazios. '
	lRet := .F.     

EndIf                        


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVALIDA OS CAMPOS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 To Len(aCols)-1     

	If !aCols[nI][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
         
		For nX := nI+1 To Len(aCols)
		       
			If !aCols[nX][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVERIFICA CONJUNTO DE CONTA ORCAMENTARIAณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If FIN272VLG(aCols[nI][GdFieldPos("F73_COINI")], aCols[nI][GdFieldPos("F73_COFIM")],;
					         aCols[nX][GdFieldPos("F73_COINI")], aCols[nX][GdFieldPos("F73_COFIM")])
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVERIFICA CONJUNTO DE CLASSEณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If	(aCols[nX][GdFieldPos("F73_CLASSE")] == aCols[nI][GdFieldPos("F73_CLASSE")]) .Or.;
						(Empty(aCols[nX][GdFieldPos("F73_CLASSE")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLASSE")]))
					
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVERIFICA CONJUNTO DE CENTRO DE CUSTOณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If 	FIN272VLG(aCols[nI][GdFieldPos("F73_CCINI")], aCols[nI][GdFieldPos("F73_CCFIM")],;
							         aCols[nX][GdFieldPos("F73_CCINI")], aCols[nX][GdFieldPos("F73_CCFIM")]).Or.;
					  		(Empty(aCols[nX][GdFieldPos("F73_CCINI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CCINI")])) .Or.;
					  		(Empty(aCols[nX][GdFieldPos("F73_CCFIM")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CCFIM")]))

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณVERIFICA CONJUNTO DE ITEM CONTABILณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If 	FIN272VLG(aCols[nI][GdFieldPos("F73_ITCTBI")], aCols[nI][GdFieldPos("F73_ITCTBF")],;
							     		  aCols[nX][GdFieldPos("F73_ITCTBI")], aCols[nX][GdFieldPos("F73_ITCTBF")]).Or.;
						  		(Empty(aCols[nX][GdFieldPos("F73_ITCTBI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_ITCTBI")])) .Or.;
						  		(Empty(aCols[nX][GdFieldPos("F73_ITCTBF")]) .Or. Empty(aCols[nI][GdFieldPos("F73_ITCTBF")]))

								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณVERIFICA CONJUNTO DE CLASSE DE VALORณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If 	FIN272VLG(aCols[nI][GdFieldPos("F73_CLVRLI")], aCols[nI][GdFieldPos("F73_CLVRLF")],;
								     		  aCols[nX][GdFieldPos("F73_CLVRLI")], aCols[nX][GdFieldPos("F73_CLVRLF")]).Or.;
							  		(Empty(aCols[nX][GdFieldPos("F73_CLVRLI")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLVRLI")])) .Or.;
							  		(Empty(aCols[nX][GdFieldPos("F73_CLVRLF")]) .Or. Empty(aCols[nI][GdFieldPos("F73_CLVRLF")]))
																	
								   	Help( ,, 'HELP',, STR0018 + LINEBREAK + LINEBREAK +; //'Amarra็ใo invแlida para os Itens: '
								   		 aCols[nI][GdFieldPos("F73_ITEM")]+LINEBREAK+aCols[nX][GdFieldPos("F73_ITEM")] , 1, 0)									
									lRet := .F.									     
									Exit     
								
							    EndIf
																														
							EndIf    
						
						EndIf					
					
					EndIf
			
				EndIf
  				 
			EndIf
		
		Next nX

	EndIf  

	If !lRet//SE FALSO, TERMINA A VERIFICACAO
	     
		Exit
	
	EndIf  	
	
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVALIDA OS CAMPOS DA TABELA F73 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
F73->(dbGoTop())//POSICIONA NO PRIMEIRO REGISTRO DA F73

While F73->(!EOF())

	If !(M->ED_CODIGO == F73->F73_NATUR)
	
		For nI := 1 To Len(aCols)   
		
			If !aCols[nI][Len(aHeader)+1]//VERIFICA SE A LINHA NAO ESTA DELETADA
			
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVERIFICA CONJUNTO DE CONTA ORCAMENTARIAณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If 	FIN272VLG(F73->F73_COINI, F73->F73_COFIM, aCols[nI][GdFieldPos("F73_COINI")], aCols[nI][GdFieldPos("F73_COFIM")])

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVERIFICA CONJUNTO DE CLASSEณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
						If	(aCols[nI][GdFieldPos("F73_CLASSE")] == F73->F73_CLASSE) .Or.;
							(Empty(aCols[nI][GdFieldPos("F73_CLASSE")]) .Or. Empty(F73->F73_CLASSE))
						     
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณVERIFICA CONJUNTO DE CENTRO DE CUSTOณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If 	FIN272VLG(F73->F73_CCINI, F73->F73_CCFIM, aCols[nI][GdFieldPos("F73_CCINI")], aCols[nI][GdFieldPos("F73_CCFIM")]) .Or.;
						  		(Empty(aCols[nI][GdFieldPos("F73_CCINI")]) .Or. Empty(F73->F73_CCINI)) .Or.;
						  		(Empty(aCols[nI][GdFieldPos("F73_CCFIM")]) .Or. Empty(F73->F73_CCFIM))

								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณVERIFICA CONJUNTO DE ITEM CONTABILณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If 	FIN272VLG(F73->F73_ITCTBI, F73->F73_ITCTBF, aCols[nI][GdFieldPos("F73_ITCTBI")], aCols[nI][GdFieldPos("F73_ITCTBF")]) .Or.;
							  		(Empty(aCols[nI][GdFieldPos("F73_ITCTBI")]) .Or. Empty(F73->F73_ITCTBI)) .Or.;
							  		(Empty(aCols[nI][GdFieldPos("F73_ITCTBF")]) .Or. Empty(F73->F73_ITCTBF))

									//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
									//ณVERIFICA CONJUNTO DE CLASSE DE VALORณ
									//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
									If 	FIN272VLG(F73->F73_CLVRLI, F73->F73_CLVRLF, aCols[nI][GdFieldPos("F73_CLVRLI")], aCols[nI][GdFieldPos("F73_CLVRLF")]) .Or.;
								  		(Empty(aCols[nI][GdFieldPos("F73_CLVRLI")]) .Or. Empty(F73->F73_CLVRLI)) .Or.;
								  		(Empty(aCols[nI][GdFieldPos("F73_CLVRLF")]) .Or. Empty(F73->F73_CLVRLF))
																	
							   		   	Help( ,, 'HELP',, STR0018 + LINEBREAK + LINEBREAK +; //'Amarra็ใo invแlida para os Itens: '
								   	 	aCols[nI][GdFieldPos("F73_ITEM")]+LINEBREAK+F73->F73_ITEM+ STR0053 +F73->F73_NATUR , 1, 0) //" \ Natureza: "
									
									lRet := .F.									     
									Exit    
								
							    EndIf
					     	
					     	EndIf
					
						EndIf        
					
					EndIf				
				
				EndIf						
			
			EndIf	
		
		Next nI
		
	EndIf
	          
	If !lRet//SE FALSO, TERMINA A VERIFICACAO
	     
		Exit
	
	EndIf  	            
	F73->(dbSkip())

End
                                     
Return lRet
        
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272VLG บAutor  ณTOTVS			     บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida as informacoes do aCols.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272VLG(cValA1, cValA2, cValB1, cValB2)

Local lRet	:= .F.

If !((cValB1 < cValA1 .And. cValB2 < cValA1) .Or. (cValB1 > cValA2 .And. cValB2 > cValA2))

	lRet := .T.     

EndIf

Return lRet
               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272IMP บAutor  ณTOTVS		         บ Data ณ  11/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta o fluxo orcamentario por natureza do PCO.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272IMP()

Local cPerg 		:= "FINA272" 
Local lInverte		:= .F.  
Local aProcessa		:= {}//RETORNO DA FUNCAO PCORUNCUBE
Local aArea			:= getArea()   
Local cSED			:= getNextAlias()   
Local aChave		:= {}     
Local nX	
Local nY           
Local nXProc
Local aSoma			:= {0,0,0,0,0,0,0,0,0,0,0,0}
Local cMarca 		:= GetMark()      
Local nOpcao        := 0

Private aPeriodo	:= {}//PERIODO A SER CALCULADO OS SALDOS                           
Private cTMP 		:= GetNextAlias()    
Private COD_CUBO
				
If Pergunte( cPerg, .T. ) .And. FIN272PERG()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBUSCA AS NATUREZAS CONFORME SELECIONADO PELO USUARIOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BeginSQL Alias cSED
	
		SELECT SED.ED_CODIGO
		FROM	%Table:SED%	SED
		WHERE	SED.ED_CODIGO >= %Exp:MV_PAR05%		AND
				SED.ED_CODIGO <= %Exp:MV_PAR06% 	AND
				SED.%NotDel%
		ORDER BY SED.ED_CODIGO			      
	
	EndSQL

	FIN272TMP(cTmp)//CRIA TABELA TEMPORARIA  
	If (cSED)->(!EOF())//EXISTE NATUREZAS
	
		aPeriodo := FIN272DAT(MV_PAR01,MV_PAR02)//FIN272DAT(Dt.Inicial,Dt.Final) PERIODO A SER CALCULADO OS SALDOS			
		
		If Len(aPeriodo) > 0//EXISTE UM PERIODO PARA CALCULAR O SALDO
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMONTAR UM ARRAY CONTENDO OS SALDOSณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		   	aProcessa :=  PcoRunCube(       MV_PAR09,Len(aPeriodo)/*+1*/     , "FIN272SLD",       MV_PAR10,              0,          .F.,               ,           ,           ,           ,             ,   ,.T.,                ,/*aItCfgBlq*/,/*aFiltCfg*/,, .F./*llimpArqAKT*/)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMONTA AS CHAVES CONFORME F73ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			(cSED)->(dbGoTop())
    		While (cSED)->(!EOF())
	
				Processa( {|| aChave := FIN272CHAV((cSED)->(ED_CODIGO))}  )//CODIGO DA NATUREZA

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณFAZ A SOMA E ALIMENTA TABELA TEMPORARIAณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nXProc := 1 To Len(aProcessa)                        
				
					For nX := 1 To Len(aChave)
					                                                                       
    					if AllTrim( aProcessa[nXProc][1] ) == AllTrim( aChave[nX] )
					
						    For nY := Month(MV_PAR01) To Month(MV_PAR01)+Len(aProcessa[nXProc][2]) - 1
						         
						         aSoma[nY] +=   aProcessa[nXProc][2][nY - Month(MV_PAR01) + 1]                               
						     
						    Next                             
					   							
						EndIf
					
					Next               				  
				Next
				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCRIA ARQUIVO DE TRABALHOณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				FIN272GTMP(aSoma,(cSED)->(ED_CODIGO), cMarca)
				aSoma := {0,0,0,0,0,0,0,0,0,0,0,0} 
				
				(cSED)->(dbSkip())	
			End 

        EndIf
	
	EndIf                     
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMONTA DIALOG COM A TABELA TEMPORARIAณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cTMP)->(!EOF())                          
	
		aCamp    := FIN272CAMP()//CAMPOS QUE IRAO APARECER NA MSSELECT
	   	          
		Define MsDialog _oDlg Title OemtoAnsi(STR0023) From aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Importa็ใo de Saldos Or็amentแrios para o Financeiro"
	
	   	oMark := MsSelect():New(cTMP ,"TMP_OK","",aCamp, @lInverte,@cMarca,{15,05,aPosObj[2,3],aPosObj[2,4]})

		oMark:bAval := {|| FIN272MARK(cMarca,@lInverte,_oDlg) }

		oMark:oBrowse:lCanAllmark := .T. 
		oMark:oBrowse:bAllMark := {|| FIN272TDMK(cMarca,@lInverte,_oDlg) }
		
		Eval(oMark:oBrowse:bGoTop) 
		oMark:oBrowse:Refresh() 
	    	
    	Activate MsDialog _oDlg Centered On Init EnchoiceBar( _oDlg , { || nOpcao := 1, _oDlg:End() }, {|| _oDlg:End() } ,, )
	    	 
	EndIf                     

	If nOpcao == 1
	
		Processa( {|| FIN272SE7() } )
	
	EndIf
	
	(cTMP)->(dbCloseArea())  	             
	
EndIf	
    
restArea(aArea)

Return
         
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272MARKบAutor  ณTOTVS		         บ Data ณ  31/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o tratamento da MsSelect quando o campo e marcado ou    บฑฑ
ฑฑบ          ณdesmarcado.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272MARK(cMarca,lInverte,_oDlg)

If AllTrim((cTMP)->(TMP_OK)) == cMarca

	RecLock(cTMP,.F.)
	
	(cTMP)->(TMP_OK) := ''
	
	MsUnlock()

Else

	RecLock(cTMP,.F.)
	
	(cTMP)->(TMP_OK) := cMarca
	
	MsUnlock()


EndIf

Return
                                    
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272TDMKบAutor  ณTOTVS		         บ Data ณ  21/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca ou desmarca todos os registros da MsSelect.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272TDMK(cMarca,lInverte,_oDlg)
Local nReg := (cTMP)->(Recno())

(cTMP)->(dbGoTop())

While (cTMP)->(!Eof()) 

	If AllTrim((cTMP)->(TMP_OK)) == cMarca
	
		RecLock(cTMP,.F.)
		
		(cTMP)->(TMP_OK) := ''
		
		MsUnlock()
	
	Else
	
		RecLock(cTMP,.F.)
		
		(cTMP)->(TMP_OK) := cMarca
		
		MsUnlock()
	
	EndIf

	(cTMP)->(dbSkip())
	
Enddo

(cTMP)->(dbGoto(nReg))

Return
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272SE7 บAutor  ณTOTVS		         บ Data ณ  29/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a gravacao da tabela temporaria para a SE7, caso        บฑฑ
ฑฑบ          ณclique em confirmar.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272SE7()        

Local aArea	:= getArea() 
Local nX

dbSelectArea("SE7")//ORCAMENTO FINANCEIRO
SE7->(dbSetOrder(1))//E7_FILIAL+E7_NATUREZ+E7_ANO+E7_CMOEDA

(cTMP)->(dbGoTop())//POSICIONA NO PRIMEIRO REGISTRO

While (cTMP)->(!EOF()) 

	procRegua(0)                     		
    IncProc(STR0024) //"Finalizando importa็ใo de dados para SE7."

	If !Empty((cTMP)->(TMP_OK))//SE ESTA MARCADO 
	                                              
		If SE7->(dbSeek(xFilial("SE7") + (cTMP)->(TMP_NATUR) + (cTMP)->(TMP_ANO) + Str((cTMP)->(TMP_MOEDA)) ))//JA EXISTE O REGISTRO - ALTERAR
		
			RecLock("SE7",.F.)
			
			For nX := 1 To Len(aPeriodo)
			
				Do Case
				
					Case Month(aPeriodo[nX][1]) == 1
			
						SE7->E7_VALJAN1	:= (cTMP)->(TMP_VALJAN)					
			
					Case Month(aPeriodo[nX][1]) == 2
			
						SE7->E7_VALFEV1	:= (cTMP)->(TMP_VALFEV)
					
					Case Month(aPeriodo[nX][1]) == 3
			
						SE7->E7_VALMAR1	:= (cTMP)->(TMP_VALMAR)
					
					Case Month(aPeriodo[nX][1]) == 4
			
						SE7->E7_VALABR1	:= (cTMP)->(TMP_VALABR)			
					
					Case Month(aPeriodo[nX][1]) == 5
			
						SE7->E7_VALMAI1	:= (cTMP)->(TMP_VALMAI)			
					
					Case Month(aPeriodo[nX][1]) == 6
			
						SE7->E7_VALJUN1	:= (cTMP)->(TMP_VALJUN)
					
					Case Month(aPeriodo[nX][1]) == 7
			
						SE7->E7_VALJUL1	:= (cTMP)->(TMP_VALJUL)
					
					Case Month(aPeriodo[nX][1]) == 8
			
						SE7->E7_VALAGO1	:= (cTMP)->(TMP_VALAGO)			
					
					Case Month(aPeriodo[nX][1]) == 9
			
						SE7->E7_VALSET1	:= (cTMP)->(TMP_VALSET)			
					
					Case Month(aPeriodo[nX][1]) == 10
			
						SE7->E7_VALOUT1	:= (cTMP)->(TMP_VALOUT)			
					
					Case Month(aPeriodo[nX][1]) == 11
			
						SE7->E7_VALNOV1	:= (cTMP)->(TMP_VALNOV)			
					
					Case Month(aPeriodo[nX][1]) == 12
			
						SE7->E7_VALDEZ1	:= (cTMP)->(TMP_VALDEZ)			
				
				EndCase
			
			Next
					
			SE7->(MsUnlock())
		
		Else // NAO EXISTE O REGISTRO - INCLUIR
    		
			RecLock("SE7",.T.)
            
			SE7->E7_FILIAL	:= xFilial("SE7")
			SE7->E7_ANO 	:= (cTMP)->(TMP_ANO)
			SE7->E7_NATUREZ	:= (cTMP)->(TMP_NATUR)
			SE7->E7_VALJAN1	:= (cTMP)->(TMP_VALJAN)
			SE7->E7_VALFEV1	:= (cTMP)->(TMP_VALFEV)
			SE7->E7_VALMAR1	:= (cTMP)->(TMP_VALMAR)
			SE7->E7_VALABR1	:= (cTMP)->(TMP_VALABR)
			SE7->E7_VALMAI1	:= (cTMP)->(TMP_VALMAI)
			SE7->E7_VALJUN1	:= (cTMP)->(TMP_VALJUN)
			SE7->E7_VALJUL1	:= (cTMP)->(TMP_VALJUL)
			SE7->E7_VALAGO1	:= (cTMP)->(TMP_VALAGO)
			SE7->E7_VALSET1	:= (cTMP)->(TMP_VALSET)
			SE7->E7_VALOUT1	:= (cTMP)->(TMP_VALOUT)
			SE7->E7_VALNOV1	:= (cTMP)->(TMP_VALNOV)
			SE7->E7_VALDEZ1	:= (cTMP)->(TMP_VALDEZ)
			SE7->E7_MOEDA	:= (cTMP)->(TMP_MOEDA)		
		
			SE7->(MsUnlock())

		EndIf   
		
	EndIf
	
	(cTMP)->(dbSkip())
	
End

restArea(aArea)

Return
  
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272PERGบAutor  ณTOTVS		         บ Data ณ  29/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a escolha das Perguntas.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272PERG()

Local lRet 	:= .T.       
Local aArea	:= getArea()           

dbSelectArea("AL3")//CONFIGURACAO DO CUBO
dbSetOrder(3)//AL3_FILIAL+AL3_CONFIG+AL3_CODIGO      

If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR09) .Or. Empty(MV_PAR10)
     
	Help( ,, 'HELP',, STR0025, 1, 0) //"Importa็ใo nใo efetuada: Existem campos obrigat๓rios em branco.  "
	lRet := .F.

ElseIf Year(MV_PAR01) != Year(MV_PAR02)

	Help( ,, 'HELP',, STR0026, 1, 0) //"Importa็ใo nใo efetuada: O perํodo 'De/At้' deve estar no mesmo ano.  "
	lRet := .F.

ElseIf !dbSeek(xFilial("AL3") + MV_PAR09 + MV_PAR10)	


	Help( ,, 'HELP',, STR0027, 1, 0) //"Importa็ใo nใo efetuada: A Configura็ใo do Cubo nใo pertence ao cubo selecionado.  "	
 	lRet := .F.
              
ElseIf !FIN272ORD() //VERIFICA A ORDEM DO CUBO SELECIONADO
          

    Help( ,, 'HELP',, STR0028, 1, 0) //"Importa็ใo nใo efetuada: A ordem do Cubo selecionado ้ invแlida.  "
  	lRet := .F.
            
EndIf          

restArea(aArea)
      
Return lRet
 
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272ORD บAutor  ณTOTVS		         บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a ordem AL1_CHAVER do cubo selecionado.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272ORD()

Local lRet		:= .T.
Local aArea		:= getArea()
Local cAL1Chave 
Local nPos
Local cTemp
Local aOrdem	:= {}

dbSelectArea("AL1")
dbSetOrder(1)//AL1_FILIAL+AL1_CONFIG

If dbSeek(xFilial("AL1") + MV_PAR09)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSEPARA A ORDEM DA CHAVEณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAL1Chave 	:= AllTrim(AL1->AL1_CHAVER)
	While cAL1Chave <> ''
				
		nPos	:= At('+',cAL1Chave)

		If nPos >0
			
			cTemp		:= SubStr(cAL1Chave,1,nPos-1)
			cAL1Chave	:= SubStr(cAL1Chave,nPos+1)
			
		Else     
		     
			cTemp	:= SubStr(cAL1Chave,1)
			cAL1Chave:= ''    
		
		EndIf                           
		
		aAdd(aOrdem,cTemp)
		
	End	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVERIFICA SE A ORDEM E VALIDAณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aOrdem) < 6
	
		lRet := .F.     
	
	Else
	   
		If 	!('AKD_CO'	$ aOrdem[1] .And. 'AKD_CLASSE'	$ aOrdem[2] .And. 'AKD_CC' 		$ aOrdem[3] .And. ;
			 'AKD_ITCTB'$ aOrdem[4] .And. 'AKD_CLVLR'	$ aOrdem[5] .And. 'AKD_TPSALD'	$ aOrdem[6])

			lRet := .F.
			
		EndIf
	
	EndIf	

EndIf

restArea(aArea)

Return lRet
                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272GTM บAutor  ณTOTVS		         บ Data ณ  26/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava dados na tabela temporaria TMP.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272GTMP(aValor, cNatur, cMarca)

RecLock(cTMP,.T.)
                           
(cTMP)->(TMP_OK)		:= cMarca
(cTMP)->(TMP_ANO)		:= CVALTOCHAR(Year(Date()))
(cTMP)->(TMP_NATUR)		:= cNatur
(cTMP)->(TMP_VALJAN)	:= aValor[1]
(cTMP)->(TMP_VALFEV)	:= aValor[2]
(cTMP)->(TMP_VALMAR)	:= aValor[3]
(cTMP)->(TMP_VALABR)	:= aValor[4]
(cTMP)->(TMP_VALMAI)	:= aValor[5]
(cTMP)->(TMP_VALJUN)	:= aValor[6]
(cTMP)->(TMP_VALJUL)	:= aValor[7]
(cTMP)->(TMP_VALAGO)	:= aValor[8]
(cTMP)->(TMP_VALSET)	:= aValor[9]
(cTMP)->(TMP_VALOUT)	:= aValor[10]
(cTMP)->(TMP_VALNOV)	:= aValor[11]
(cTMP)->(TMP_VALDEZ)	:= aValor[12]
(cTMP)->(TMP_MOEDA)		:= MV_PAR04

(cTMP)->(MsUnlock())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272CHAVบAutor  ณTOTVS		         บ Data ณ  23/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula as chaves da F73 para buscar o saldo no aProcessa.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272CHAV(cNatur)

Local cQuery
Local aArea		:= getArea()
Local cAL1Chave	:= ""          
Local cTemp		:= "" //AJUDA NA CRIACAO DA ORDEM
Local aOrdem	:= {}, aParam	:= {'','','','','',''}
Local aChave	:= {}    
Local cCCINI
Local cCCFIM               
Local cEmpresa := 0                   
Local cAliasNw := "NEWALIAS"
Local nCont := 0  

dbSelectArea('SM0')                          
cEmpresa := SM0->M0_CODIGO

dbSelectArea("AL1")//CUBOS 
AL1->(dbSetOrder(1))//AL1_FILIAL+AL1_CONFIG    

If AL1->(dbSeek(xFilial("AL1")+MV_PAR09))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSEPARA A ORDEM DA CHAVEณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAL1Chave 	:= AllTrim(AL1->AL1_CHAVER)
	While cAL1Chave <> ''
		nPos	:= At('+',cAL1Chave)
	
		If nPos >0
			cTemp		:= SubStr(cAL1Chave,1,nPos-1)
			cAL1Chave	:= SubStr(cAL1Chave,nPos+1)
		Else     
			cTemp	:= SubStr(cAL1Chave,1)
			cAL1Chave:= ''    
		EndIf                           
			
		aADD(aOrdem,cTemp)
		nCont := nCont + 1
		
		if nCont <= 6 //por defini็ใo do projeto, fixado 6 parโmetros no sistema



			aParam[nCont] := aOrdem[nCont]
		EndIf
	End		          
EndIf
                                                     

		    If AllTrim(TCGetDB()) == "ORACLE"			 //Devido a sintaxe os nome do Oracle diferem do nome do SQL


				if TcSqlExec("Execute PRWCNIAC270") <> 0
					conout( TcSqlError() ) //Retornando erro durante a cria็ใo (no caso de haver um)
				endif                                   
			Else           


		
				if TcSqlExec("Execute _Pr_wCNIAC270") <> 0
					conout( TcSqlError() ) //Retornando erro durante a cria็ใo (no caso de haver um)
				endif      
			EndIf
		


dbSelectArea("F73")//CUBOS 
F73->(dbSetOrder(1))//F73_FILIAL+F73_NATUR+F73_ITEM
     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSEPARA AS INFORMACOES QUE IRAO MONTAR A CHAVEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If F73->(dbSeek(xFilial("F73")+cNatur))
	                                                                           
	procRegua(0)                     	

	While F73->(!EOF()) .And. F73->F73_NATUR == cNatur//POR ITEM



	    
	   	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMONTA A QUERY DE CLASSEณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    if Empty(F73->F73_CLASSE)
			cCLASI := ''                    
			cCLASF := 'ZZZZZZ'
	    Else
			cCLASI := F73->F73_CLASSE
			cCLASF := F73->F73_CLASSE
	    EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMONTA A QUERY DE CENTRO DE CUSTOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Empty(F73->F73_CCINI) .And. Empty(F73->F73_CCFIM)
			cCCINI := ''
  			cCCFIM := 'ZZZZZZZZZ'    
		Else		
			cCCINI := F73->F73_CCINI	
			cCCFIM := F73->F73_CCFIM
	    EndIF 	    
	                
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMONTA A QUERY DE ITEM CONTABILณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Empty(F73->F73_ITCTBI) .And. Empty(F73->F73_ITCTBF)
			cITINI := ''
			cITFIM := 'ZZZZZZZZZ'
		Else
			cITINI := F73->F73_ITCTBI	
			cITFIM := F73->F73_ITCTBF
		EndIF           
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMONTA A QUERY DE CLASSE DE VALORณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if Empty(F73->F73_CLVRLI) .And. Empty(F73->F73_CLVRLF)
			cCLINI := ''
			cCLFIM := 'ZZZZZZZZZ'
		Else
			cCLINI := F73->F73_CLVRLI
			cCLFIM := F73->F73_CLVRLF
	    EndIF                                                  
		
		CursorWait()
		LjMsgRun(STR0054 ,,,) //"Calculando configura็๕es ...,"
	                                         
	                                                
	    If AllTrim(TCGetDB()) == "ORACLE"   //Devido a sintaxe os nome do Oracle diferem do nome do SQL
	   		cQuery := "Execute PRWFINA272 '" + cEmpresa + "','"+ aParam[1] + "','" + aParam[2] + "','" + aParam[3] + "','" + aParam[4] + "','" + aParam[5] + "','" + aParam[6] + "','" + cNatur + "','" + xFilial("F73") + "','" + MV_PAR07 + "','" + MV_PAR08 + "','" +  cCLASI + "','" + cCLASF + "','" + cCCINI + "','" + cCCFIM + "','" + cITINI + "','" + cITFIM + "','" + cCLINI + "','" + cCLFIM + "','" + F73->F73_COINI   + "','" + F73->F73_COFIM  + "','" + F73->F73_CLASSE  + "','" + F73->F73_CCINI  + "','"  + F73->F73_CCFIM   + "','" + F73->F73_ITCTBI + "','" + F73->F73_ITCTBF  + "','" + F73->F73_CLVRLI + "','"  + F73->F73_CLVRLF + "','" + MV_PAR03 + "'"     
        Else                      
	   		cQuery := "Execute _Pr_wFINA272 '" + cEmpresa + "','"+ aParam[1] + "','" + aParam[2] + "','" + aParam[3] + "','" + aParam[4] + "','" + aParam[5] + "','" + aParam[6] + "','" + cNatur + "','" + xFilial("F73") + "','" + MV_PAR07 + "','" + MV_PAR08 + "','" +  cCLASI + "','" + cCLASF + "','" + cCCINI + "','" + cCCFIM + "','" + cITINI + "','" + cITFIM + "','" + cCLINI + "','" + cCLFIM + "','" + F73->F73_COINI   + "','" + F73->F73_COFIM  + "','" + F73->F73_CLASSE  + "','" + F73->F73_CCINI  + "','"  + F73->F73_CCFIM   + "','" + F73->F73_ITCTBI + "','" + F73->F73_ITCTBF  + "','" + F73->F73_CLVRLI + "','"  + F73->F73_CLVRLF + "','" + MV_PAR03 + "'"     
   		EndIf
   		
		if TcSqlExec(cQuery) <> 0
			conout( TcSqlError() ) 
		endif      
        
		F73->(dbSkip())
    End   
    
EndIf                          
                                                              
If AllTrim(TCGetDB()) == "ORACLE"			 //Devido a sintaxe os nome do Oracle diferem do nome do SQL
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,"Select chave from FINA272"),cAliasNw,.F.,.T.)                  
Else
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,"Select chave from _FINA272"),cAliasNw,.F.,.T.) 
EndIf

(cAliasNw)->( dbgotop() ) 
while (cAliasNw)->( !eof() )

	aAdd(aChave,AllTrim((cAliasNw)->chave) )

	(cAliasNw)->(dbSkip())
End              

(cAliasNw)->( dbCloseArea() )

restArea(aArea)   

Return aChave



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272SLD บAutor  ณTOTVS		         บ Data ณ  17/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao PcoRetSld tem como finalidade retornar o saldo do    บฑฑ
ฑฑบ          ณcubo para a chave informada, em uma determinada data        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272SLD(cConfig,cChave)

Local aRetorno := {}
Local aRetIni,aRetFim

Local nCrdIni
Local nDebIni

Local nCrdFim
Local nDebFim
Local nMovPer
Local nX
Local nTotAno := 0

For nX := 1 TO Len(aPeriodo)

	//SALDO DO MES
	dIni := aPeriodo[nX,1]
	dFim := aPeriodo[nX,2]

	aRetIni := PcoRetSld(cConfig,cChave,dIni - 1)
	nCrdIni := aRetIni[1, MV_PAR04]
	nDebIni := aRetIni[2, MV_PAR04]

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, MV_PAR04]
	nDebFim := aRetFim[2, MV_PAR04]

	nMovCrd := nCrdFim - nCrdIni	
	nMovDeb := nDebFim - nDebIni
	nMovPer := nMovCrd - nMovDeb

	aAdd(aRetorno,nMovPer)
	nTotAno += nMovPer

Next

aAdd(aRetorno, nTotAno)	

Return aRetorno

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272DAT บAutor  ณTOTVS		         บ Data ณ  16/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a quantidade de meses entre as datas informadas nos บฑฑ
ฑฑบ          ณparametros para calculo dos saldos.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272DAT(dDtIni,dDtFim)

Local aRetorno	:= {}
Local nMesIni 	:= Val(Subs(DToC(dDtIni),4,2))//MES INICIAL
Local nMesFim	:= Val(Subs(DToC(dDtFim),4,2))//MES FINAL
Local cAnoIni  	:= Right(DToC(dDtIni),4)//ANO INICIAL
Local cAnoFim  	:= Right(DToC(dDtFim),4)//ANO FINAL
Local nX            
Local nAno

Local dIni
Local dFim

If cAnoIni == cAnoFim//MESMO ANO

	For nX := nMesIni To nMesFim
		
		dIni := CTOD("01/"+StrZero(nX,2)+"/"+Right(cAnoIni,2))
		dFim := LastDay(dIni)
		aAdd(aRetorno, { dIni, dFim } )
		
	Next

Else //ANOS DIFERENTES
    
	For nX := nMesIni To 12
	
		dIni := CTOD("01/"+StrZero(nX,2)+"/"+Right(cAnoIni,4))
		dFim := LastDay(dIni)
		aAdd(aRetorno, { dIni, dFim } )		    
	
	Next
       
    nAno := Val(cAnoIni)+1
    While nAno < Val(cAnoFim)
    
		For nX := 1 To 12
		
			dIni := CTOD("01/"+StrZero(nX,2)+"/"+Right(Str(nAno),4))
			dFim := LastDay(dIni)
			aAdd(aRetorno, { dIni, dFim } )		    
		
		Next		
		 	
 		nAno += 1
    End
    
	For nX := 1 To nMesFim
	
		dIni := CTOD("01/"+StrZero(nX,2)+"/"+Right(cAnoFim,4))
		dFim := LastDay(dIni)
		aAdd(aRetorno, { dIni, dFim } )		    
	
	Next

EndIf

Return aRetorno
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272TMP บAutor  ณTOTVS		         บ Data ณ  15/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo temporario.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272TMP(cAlias)
	Local aStru    := NIL
	
	//Cria arquivo de trabalho
	aStru := {}    
	AADD(aStru,{"TMP_OK"		, "C", 02	, 0})
	AADD(aStru,{"TMP_ANO"		, "C", 04	, 0})
	AADD(aStru,{"TMP_NATUR"		, "C", 10	, 0})
	AADD(aStru,{"TMP_VALJAN"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALFEV"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALMAR"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALABR"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALMAI"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALJUN"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALJUL"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALAGO"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALSET"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALOUT"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALNOV"	, "N", 14	, 2})
	AADD(aStru,{"TMP_VALDEZ"	, "N", 14	, 2})
	AADD(aStru,{"TMP_MOEDA"		, "N", 02	, 0})
	
	If !EMPTY(oFIN272TMP)
		oFIN272TMP:Delete()
		oFIN272TMP := NIL
	EndIf
	
	oFIN272TMP := FWTemporaryTable():New( cAlias, aStru )
	oFIN272TMP:Create()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272CAMPบAutor  ณTOTVS			     บ Data ณ  16/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta array com os campos do arquivo temporario para mostrarบฑฑ
ฑฑบ          ณno MsSelect.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FIN272CAMP()

Local aCamp	:= {}

AADD(aCamp,{"TMP_OK"		,,""			, "@!"					})
AADD(aCamp,{"TMP_ANO"		,,STR0055		,"@E 9999"				}) //"Ano"
AADD(aCamp,{"TMP_NATUR"		,,STR0069		,"@!" 					}) //"Natureza"
AADD(aCamp,{"TMP_VALJAN"	,,STR0056	 	,"@E 999,999,999.99" 	}) //"Janeiro"
AADD(aCamp,{"TMP_VALFEV"	,,STR0057	 	,"@E 999,999,999.99" 	}) //"Fevereiro"
AADD(aCamp,{"TMP_VALMAR"	,,STR0058 		,"@E 999,999,999.99" 	}) //"Mar็o"
AADD(aCamp,{"TMP_VALABR"	,,STR0059 		,"@E 999,999,999.99" 	}) //"Abril"
AADD(aCamp,{"TMP_VALMAI"	,,STR0060 		,"@E 999,999,999.99" 	}) //"Maio"
AADD(aCamp,{"TMP_VALJUN"	,,STR0061 		,"@E 999,999,999.99" 	}) //"Junho"
AADD(aCamp,{"TMP_VALJUL"	,,STR0062 		,"@E 999,999,999.99" 	}) //"Julho"
AADD(aCamp,{"TMP_VALAGO"	,,STR0063 		,"@E 999,999,999.99" 	}) //"Agosto"
AADD(aCamp,{"TMP_VALSET"	,,STR0064	 	,"@E 999,999,999.99" 	}) //"Setembro"
AADD(aCamp,{"TMP_VALOUT"	,,STR0065	 	,"@E 999,999,999.99" 	}) //"Outubro"
AADD(aCamp,{"TMP_VALNOV"	,,STR0066	 	,"@E 999,999,999.99" 	}) //"Novembro"
AADD(aCamp,{"TMP_VALDEZ"	,,STR0067	 	,"@E 999,999,999.99" 	}) //"Dezembro"
AADD(aCamp,{"TMP_MOEDA"		,,STR0068		,"9" 					}) //"Moeda"
/*AADD(aCamp,{"TMP_DEBITO"	,,"Cta D้bito" 	,"@!" 					})
AADD(aCamp,{"TMP_CCD"		,,"C Custo Deb"	,"@!" 					})
AADD(aCamp,{"TMP_ITEMD"		,,"Item D้bito"	,"@!" 					})
AADD(aCamp,{"TMP_CLVLDB"	,,"Cl Vlr Deb" 	,"@!"	 				})
AADD(aCamp,{"TMP_CREDIT"	,,"Cta Cr้dito"	,"@!" 					})
AADD(aCamp,{"TMP_CCC"		,,"C Custo Crd"	,"@!"					})
AADD(aCamp,{"TMP_ITEMC"		,,"Item Cr้dito","@!"					})
AADD(aCamp,{"TMP_CLVLCR"	,,"Cl Vlr Cred"	,"@!" 					})
AADD(aCamp,{"TMP_CMOEDA"	,,"Moeda"		,"@!" 					})
*/
      
Return aCamp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMENUDEF   บAutor  ณTOTVS		         บ Data ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMenuDef                                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Private aRotina	:= {}    

AADD( aRotina, { STR0070	,"AxPesqui"	,0,1}) //"Pesquisar" 
AADD( aRotina, { STR0071	,'FIN272MNT',0,2}) //"Visualizar"
AADD( aRotina, { STR0072	,'FIN272INC',0,3}) //"Incluir"
AADD( aRotina, { STR0073	,'FIN272MNT',0,4}) //"Alterar"
AADD( aRotina, { STR0074	,'FIN272MNT',0,5}) //"Excluir"
AADD( aRotina, { STR0075	,'FIN272IMP',0,6}) //"Importa็ใo"

Return aRotina   
                                                                                  
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN272MOEDบAutor  ณTOTVS		         บ Data ณ  11/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida perguntas da importacao.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN272MOED(nTipo)

Local lRet	:= .T.  
Local aArea := getArea()

While .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFILTRO PARA CONSULTA PADRAO DE CONFIGURACAO DE CUBOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(MV_PAR09)
		
		COD_CUBO := MV_PAR09		
	
	EndIf    
    
	Do Case

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA O PERIODO DE ATE DA IMPORTACAOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 1
			If (Empty(MV_PAR01))
			
				Help( ,, 'HELP',, STR0030, 1, 0) //"Preencha o 'Perํodo De' a ser utilizado pela importa็ใo.  "
				lRet := .F.
			    Exit				     
			
			ElseIf !Empty(MV_PAR02) .And. (MV_PAR01 > MV_PAR02)
			     
				Help( ,, 'HELP',, STR0031, 1, 0) //"O 'Perํodo De' deve ser menor ou igual ao 'Perํodo At้'. "
				lRet := .F.
			    Exit				     
			
			EndIf

		Case nTipo == 2
			If (Empty(MV_PAR02))
			
				Help( ,, 'HELP',, STR0032, 1, 0) //"Preencha o 'Perํodo At้' a ser utilizado pela importa็ใo.  "
				lRet := .F.
			    Exit				     
			
			ElseIf !Empty(MV_PAR01) .And. (MV_PAR01 > MV_PAR02)
		
				Help( ,, 'HELP',, STR0033, 1, 0) //"O 'Perํodo At้' deve ser maior ou igual ao 'Perํodo De'.  "
				lRet := .F.
			    Exit				     
				
			EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA A MOEDA DESTINO DA IMPORTACAOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 4		
			If (MV_PAR04 < 1) .Or. (MV_PAR04 > 99 )
			
				Help( ,, 'HELP',, STR0034, 1, 0) //'A moeda destino deve estar entre 1 e 5. '
				lRet := .F.
			    Exit
			    
			EndIf    

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA A NATUREZA DE ATE DA IMPORTACAOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 5
			
  			If !Empty(MV_PAR06) .And. (MV_PAR05 > MV_PAR06)
  			     
				Help( ,, 'HELP',, STR0035, 1, 0) //"A 'Natureza De' deve ser menor ou igual a 'Natureza At้'. "
				lRet := .F.
			    Exit				     
			
			EndIf
			
		Case nTipo == 6
			
  			If !Empty(MV_PAR05) .And. (MV_PAR05 > MV_PAR06)
			     
				Help( ,, 'HELP',, STR0036, 1, 0) //"A 'Natureza At้' deve ser maior ou igual a 'Natureza De'. "
				lRet := .F.
			    Exit				     
			
			EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA A CONTA ORCAMENTARIA DE ATE DA IMPORTACAOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 7
			
 			If !Empty(MV_PAR08) .And. (MV_PAR07 > MV_PAR08)
			     
				Help( ,, 'HELP',, STR0037, 1, 0) //"A 'Conta Or็amentแria De' deve ser menor ou igual a 'Conta Or็amentแria At้'. "
				lRet := .F.
			    Exit				     
			
			EndIf
		
		Case nTipo == 8
	
  			If !Empty(MV_PAR07) .And. (MV_PAR07 > MV_PAR08)
			     
				Help( ,, 'HELP',, STR0038, 1, 0) //"A 'Conta Or็amentแria At้' deve ser maior ou igual a 'Conta Or็amentแria De'. "
				lRet := .F.
			    Exit  
			    
			EndIf	

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA O CODIGO DO CUBOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 9
			
			If Empty(MV_PAR09)
			
				Help( ,, 'HELP',, STR0039, 1, 0) //"Preencha o 'C๓digo do Cubo' a ser utilizado pela importa็ใo.  "
				lRet := .F.
			    Exit
			    
			EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVALIDA A CONFIGURACAO DO CUBOณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case nTipo == 10
			
			If Empty(MV_PAR10)
			
				Help( ,, 'HELP',, STR0040, 1, 0) //"Preencha a 'Configura็ใo do Cubo' a ser utilizada pela importa็ใo.  "
				lRet := .F.
			    Exit
			    
			Else
			
				dbSelectArea("AL3")//CONFIGURACAO DO CUBO
				dbSetOrder(3)//AL3_FILIAL+AL3_CONFIG+AL3_CODIGO      
				
				If !dbSeek(xFilial("AL3") + MV_PAR09 + MV_PAR10)	
				
					Help( ,, 'HELP',, STR0041, 1, 0) //"A 'Configura็ใo do Cubo' nใo pertence ao cubo selecionado.  "
					lRet := .F.
				    Exit
				
				EndIf			
			
			EndIf
		
	EndCase
					
	Exit	
End
	 
restArea(aArea)	
	
Return lRet
