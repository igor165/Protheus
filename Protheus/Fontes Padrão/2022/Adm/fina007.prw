#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA007.CH"


// Define dos modos das rotinas
#DEFINE VISUALIZAR	2
#DEFINE INCLUIR		3
#DEFINE ALTERAR		4
#DEFINE EXCLUIR		5
#DEFINE OK			1
#DEFINE CANCELA		2
#DEFINE ENTER		Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA007   บAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Dados Auxiliares FIN                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA007()
Private cCadastro	:= STR0002 //"Dados Auxiliares FIN"
Private cAlias		:= "FR0"
Private aRotina		:= MenuDef()

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1)) // FR0_FILIAL+FR0_TABELA+FR0_CHAVE
(cAlias)->(dbGotop())
mBrowse(,,,,cAlias,,,,,,,,,,,,,, "FR0_TABELA<>'000'" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA007MAN บAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo de manutn็ใo Dados Auxiliares FIN                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA007MAN(cAlias,nRecNo,nOpc)

Local aHeader 		:= {}
Local aCols   		:= {}
Local cCPOs			:= ""		// Campos que aparecerใo na getdados
Local cChav			:= ""
Private oEnch		:= Nil
Private oDlg		:= Nil
Private oGet		:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis internas para a MsMGet()ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aTELA[0][0]
Private aGETS[0]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnchBar   		:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Private lPadrao    		:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Private nMinY	      	:= 400 // Altura mํnima da janela

Private aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Private aInfo	 	   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Private aObjects	   	:= {}
Private aPosObj	   	:= {}

aAdd(aObjects,{50,50,.T.,.F.})// Definicoes para a Enchoice
aAdd(aObjects,{150,150,.T.,.F.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal


// Valida็ใo da inclusใo
If (cAlias)->(RecCount()) == 0 .And. !(nOpc==INCLUIR)
	Return .T.
Endif

cCPOs := "FR0_FILIAL/FR0_TABELA"
cChav := IIF( (cAlias)->FR0_TABELA == "000", (cAlias)->FR0_CHAVE, (cAlias)->FR0_TABELA)
cChav	:= Alltrim(cChav)

aHeader	:= CriaHeader(NIL,cCPOs,aHeader)
aCols		:= CriaAcols(aHeader,cAlias,1,xFilial("FR0")+cChav,nOpc,aCols)
MontaTela(aHeader,aCols,nRecNo,nOpc)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaHeaderบAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader)
Local   aArea		:= (cAlias)->(GetArea())
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que nใo conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao)) .And. (X3USO(SX3->X3_USADO))
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;				// 02 - Campo
		SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		   , ;			// 09 - F3
		SX3->X3_CONTEXT   , ;       	// 10 - Contexto
		SX3->X3_CBOX	  , ; 	  		// 11 - ComboBox
		SX3->X3_RELACAO   , } )   		// 12 - Relacao
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcAlias  : Alias da tabela                                   บฑฑ
ฑฑบ          ณnIndice : Indice da tabela que sera usado para              บฑฑ
ฑฑบ          ณcComp   : Informacao dos Campos para ser comparado no While บฑฑ
ฑฑบ          ณnOpc    : Op็ใo do Cadastro                                 บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols)
Local 	nX			:= 0
Local 	nCols     	:= 0
Local   aArea		:= (cAlias)->(GetArea())
DEFAULT aCols 		:= {}

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		aCols[1][nX] := CriaVar(aHeader[nX][2])
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(FR0_FILIAL+FR0_TABELA)) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc็ใo responsแvel por montar a tela                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaTela(aHeader,aCols,nReg,nOpc)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpcX			:= 0                                   // Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "FA007LOK()" 							  	// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue()" 							// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""                       				// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              							// Campos estaticos na GetDados.
Local nMax         	:= 999              					  		// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                                 	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"								// Funcao executada na validacao do campo
Local cSuperDel    	:= "AllwaysTrue"          				   // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= "AllwaysTrue"    					  		// Funcao executada para validar a exclusao de uma linha do aCols
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsMGet()             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aAlterEnch	:= {}				 	// Campos que podem ser editados na Enchoice
Local aPos		  	:= {000,000,080,400}// Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
Local nModelo		:= 3     			 // Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
Local lF3 		  	:= .F.				 // Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
Local lMemoria		:= .T.	   	 	 // Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
Local lColumn		:= .F.				 // Indica se a apresentacao dos campos sera em forma de coluna
Local caTela 		:= "" 				 // Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
Local lNoFolder		:= .F.				 // Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
Local lProperty		:= .F.				 // Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da EnchoiceBar()        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpcA			:= 0										// Botใo Ok ou Cancela
Local nCont			:= 0
Local aArea			:= GetArea()
Local lExistGet

Local oTabela		:= Nil
Local oDescric		:= Nil

Private cTabela 	:= ""
Private cDescric	:= ""

If nOpc != INCLUIR
	cTabela := IIF( (cAlias)->FR0_TABELA == "000", (cAlias)->FR0_CHAVE, (cAlias)->FR0_TABELA)
	cTabela	:= Alltrim(cTabela)
	cDescric	:= GetAdvFVal("FR0","FR0_DESC01",xFilial("FR0") +"000"+cTabela )
Else
	cTabela 	:= CriaVar("FR0_TABELA")
	cDescric	:= CriaVar("FR0_DESC01")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona os campos a serem atualizados pelo usuario na MsNewGetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCont := 1 to Len(aHeader)
	If ( aHeader[nCont][10] != "V") .And. X3USO(aHeader[nCont,7])
		aAdd(aAlter,aHeader[nCont,2])
	EndIf
Next nCont

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใod dos Objetosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nOpcX	:= 0
EndIf

oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
oTPane1:Align := CONTROL_ALIGN_TOP

@ 4, 006 SAY STR0003 + ":"  	SIZE 70,7 PIXEL OF oTPane1 //"Tabela"
@ 4, 062 SAY STR0004 + ":"  SIZE 70,7 PIXEL OF oTPane1 //"Descricao"

@ 3, 026 MSGET oTabela 	 VAR cTabela 	 Picture "@!" When INCLUI Valid NaoVazio(cTabela) .And. FA007Tab(cTabela,nOpc)  SIZE 30,7 PIXEL OF oTPane1
@ 3, 090 MSGET oDescric  VAR cDescric   Picture "@!" When (INCLUI .OR. ALTERA) Valid NaoVazio(cDescric) SIZE 150,7 PIXEL OF oTPane1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMsNewGetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGet			:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpcX,;
cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDLG,aHeader,aCols)
oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg:bInit 		:= EnchoiceBar(oDlg,{||IIF( IIF(nOpc == INCLUIR .Or. nOpc == ALTERAR, FA007TOK(nOpc) , .T.) ,(nOpcA:=1,oDlg:End()), )},{|| oDlg:End()})
oDlg:lCentered	:= .T.
oDlg:Activate()

If nOpcA == OK .AND. !(nOpc == VISUALIZAR)
	Begin Transaction
	FA007Grava(nOpc)
	End Transaction
Endif

RestArea(aArea)
Return(nOpcA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA007Grava บAutor  ณAlvaro Camillo Neto บ Data ณ  19/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para efetuar a grava็ใo nas tabelas                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA007Grava(nOpc)
Local nX				:= 0
Local nI 			:= 0
Local nPosChav		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FR0_CHAVE")})
Local nPosChvAux	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FR0_CHVAUX")})
Local lGrava		:= .F.
Local cArquivo		:= ""
Local cChave		:= ""
//Local cFiltro		:= ""
Local nIndex		:= 0
Local aArea			:= GetArea()
Local aAreaFR0		:= FR0->(GetArea())
Local nTamChave		:= TamSX3('FR0_CHAVE')[01]
Local nTamTabela	:= TamSX3('FR0_TABELA')[01]

If nOpc == INCLUIR .Or. nOpc == ALTERAR

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava o cabe็alho da tabelaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+"000"+PadR(cTabela, nTamChave ))) )
	RecLock(cAlias,!lGrava)
	(cAlias)->FR0_FILIAL := xFilial(cAlias)
	(cAlias)->FR0_TABELA := "000"
	(cAlias)->FR0_CHAVE	:= cTabela
	(cAlias)->FR0_DESC01	:= cDescric

	MsUnLock()

	cArquivo := CriaTrab(Nil,.F.)
	cChave := "FR0_FILIAL+FR0_TABELA+FR0_CHAVE+FR0_CHVAUX"

	IndRegua("FR0",cArquivo,cChave,,,)

	nIndex := RetIndex("FR0")

	DbSelectArea("FR0")
	#IFNDEF TOP
		dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
	DbGoTop()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava os Itens da Tabelaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX:= 1 to Len(oGet:aCols)
		lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+PadR(cTabela, nTamTabela)+oGet:Acols[nX,nPosChav]+oGet:Acols[nX,nPosChvAux])) )
		If oGet:Acols[nX,Len(oGet:aHeader)+1] .And. lGrava .And. FA007LOK(nX,.F.)
			RecLock(cAlias,!lGrava)
			( cAlias )->( dbDelete() )
			MsUnlock()
		ElseIf !oGet:Acols[nX,Len(oGet:aHeader)+1] .And. (!Empty(oGet:Acols[nX,nPosChav]) .Or. !Empty(oGet:Acols[nX,nPosChav]))
			RecLock(cAlias,!lGrava)
			(cAlias)->FR0_FILIAL := xFilial(cAlias)
			(cAlias)->FR0_TABELA := cTabela
			For nI:= 1 to Len(oGet:aHeader)
				(cAlias)->(FieldPut(FieldPos(Trim(oGet:aHeader[nI,2])),oGet:aCols[nX,nI]))
			Next nI
			MsUnLock()
		EndIf
	Next nX

ElseIf nOpc == EXCLUIR
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeleta os Itensณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(dbSetOrder(1)) // FR0_FILIAL + FR0_TABELA + FR0_CHAVE
	If (cAlias)->(dbSeek(xFilial(cAlias)+ "000" + PadR(cTabela, nTamChave )))
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
	EndIf

	(cAlias)->(dbSeek(xFilial(cAlias)+PadR(cTabela, nTamTabela)))
	While (cAlias)->(!EOF()) .And. (cAlias)->(FR0_FILIAL + FR0_TABELA ) == xFilial(cAlias)+PadR(cTabela, nTamTabela)
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
		(cAlias)->(dbSkip())
	EndDo

EndIf

//Restaura os indices
dbSelectArea("FR0")
RetIndex("FR0")
#IFNDEF TOP
	IF cIndex != ""
		FErase (cIndex+OrdBagExt())
	EndIF
#ENDIF

dbSetOrder(1)

RestArea(aAreaFR0)
RestArea(aArea)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA007TOK บAutor  ณAlvaro Camillo Neto บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo TudoOK da rotina                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA007TOK(nOpc)
Local lRet 			:= .T.
Local nX	  			:= 0
Local aCols 		:= oGet:aCols
Local aHeader		:= oGet:aHeader
Local nPosChav		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FR0_CHAVE")})
Local nItens		:= 0
Local nPos			:= 0

lRet := NaoVazio(cTabela) .And. NaoVazio(cDescric) .And. FA007Tab(cTabela,nOpc)

If lRet
	For nX:= 1 to Len(aCols)
		If !aCols[nX][Len(aHeader)+1]
			If !FA007LOK(nX)
				lRet := .F.
				Exit
			ElseIF !Empty(aCols[nX][nPosChav])
				nItens++
			EndIf
		EndIf
	Next nX
EndIf

If lRet .And. nItens == 0
	Help(" ",1,"FR0NOLIN" , , STR0005 ,3,0 ) //"Por favor, crie pelo menos um item"
	lRet := .F.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA007LOK บAutor  ณAlvaro Camillo Neto บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo LinOK da rotina                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA007LOK(nLinha,lHelp)
Local lRet := .T.
Local nX	  := 0
Local aCols 		:= oGet:aCols
Local aHeader		:= oGet:aHeader
Local nPosChav		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FR0_CHAVE")})
Local nPosChAux		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FR0_CHVAUX")})

Default nLinha := oGet:nAt
Default lHelp := .T.

For nX:= 1 to Len(aCols)
	If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And.;
		ALLTRIM(aCols[nX][nPosChav]+aCols[nX][nPosChAux]) == ALLTRIM(aCols[nLinha][nPosChav]+aCols[nLinha][nPosChAux])
		If lHelp
			Help(" ",1,"FR0LINDUP" , , STR0006 ,3,0 ) //"Linha Duplicada"
		EndIf
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA007Tab  บAutor  ณAlvaro Camillo Neto บ Data ณ  20/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao para o campo FR0_TABELA                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FIN                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA007Tab(cTabela,nOpc)
Local lRet	:= .T.

If lRet .And. cTabela == "000"
	Help(" ",1,"FR0TAB00" , , STR0007 ,3,0 ) //"Tabela 000 exclusiva para o sistema"
	lRet := .F.
EndIf

If lRet .and. nOpc==3
	lRet := ExistChav("FR0","000" + PadR(cTabela, TamSX3('FR0_CHAVE')[01]) )
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Alvaro Camillo Neto    ณ Data ณ19/11/09 ณฑฑ
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
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
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
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina ,{STR0008  		, "AxPesqui"		,0,1 }) //"Pesquisar"
aAdd( aRotina ,{STR0009 		, "FA007MAN"		,0,2 }) //"Visualizar"
aAdd( aRotina ,{STR0010    		, "FA007MAN"		,0,3 }) //"Incluir"
aAdd( aRotina ,{STR0011    		, "FA007MAN"		,0,4 }) //"Alterar"
aAdd( aRotina ,{STR0012    		, "FA007MAN"		,0,5 }) //"Excluir"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR0CONS   บAutor  ณMicrosiga           บFecha ณ  02/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR0CONS(cTabela,cMoeda)
	Local cQuery	:= ""
	Local cAliasFR0	:= ""
	Local cDescFR0	:= ""
	Local cFilFR0	:= ""
	Local cCpoFR0	:= ""
	Local cDesc		:= ""
	Local nItem		:= 0
	Local xRet		:= .F.
	Local aArea		:= {}
	Local aAreaFR0	:= {}
	Local aItens	:= {}
	Local aScrRes	:= {}
	Local oDlgFR0
	Local oBrwFR0
	//Paineis
	Local oPnlTopo
	Local oPnlEsq
	Local oPnlDir
	Local oPnlBase
	Local oPnlCons
	Local oPnlCons1
	Local oPnlBot
	Local oSep0
	Local oSep1
	Local oSep2
	Local oSep3
	Local oSep4
	Local oSep5
	//Botoes
	Local oBtnSair
	Local oBtnOk
	Local oBtnPesq
	//variaveis
	Local oDesc
	Local oSayDesc
	Local nTamChave		:= TamSX3('FR0_CHAVE')[01]
	Local nTamTabela	:= TamSX3('FR0_TABELA')[01]

	Default cMoeda	:= "01"

	aArea := GetArea()
	cFilFR0 := xFilial("FR0")
	If FR0->(DbSeek(cFilFR0 + PadR("0",nTamTabela,"0") + PadR(cTabela,nTamChave)))
		cCpoFR0 := "FR0_DESC" + cMoeda
		cDescFR0 := FR0->(&cCPOFR0)

		#IFDEF TOP

			cQuery := "select R_E_C_N_O_,FR0_CHAVE," + cCpoFR0 + " F0DESC from " + RetSqlName("FR0")
			cQuery += " where FR0_FILIAL = '" + xFilial("FR0") + "'"
			cQuery += " and FR0_TABELA = '" + PadR(cTabela,nTamTabela) + "'"
			cQuery += " and D_E_L_E_T_=''"
			cAliasFR0 := GetNextAlias()
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFR0,.T.,.T.)
			dbSelectArea(cAliasFR0)
			(cAliasFR0)->(DbGoTop())
			While !((cAliasFR0)->(Eof()))
				Aadd(aItens,{(cAliasFR0)->FR0_CHAVE,(cAliasFR0)->F0DESC,(cAliasFR0)->R_E_C_N_O_})
				(cAliasFR0)->(DbSkip())
			Enddo
			dbSelectArea(cAliasFR0)
			DbCloseArea()

		#ELSE

			DbSelectArea("FR0")
			DbSetOrder(1)
			While FR0->(!EOF())
				If FR0->FR0_TABELA == PadR(cTabela,nTamTabela)
					Aadd(aItens,{ FR0->FR0_CHAVE, FR0->(&cCPOFR0) ,FR0->(Recno()) })
				Endif
				DbSkip()
			Enddo

		#ENDIF

		If !Empty(aItens)
			cDesc := Space(FR0->(TamSX3(cCpoFR0)[1]))
			aScrRes := MsAdvSize(.F.,.F.,300)
			oDlgFR0 := TDialog():New(aScrRes[7],0,aScrRes[6]-250,aScrRes[5]-450,AllTrim(cDescFR0),,,,,,,,,.T.,,,,,)
				oPnlEsq := TPanel():New(01,01,,oDlgFR0,,,,,,5,5,.F.,.F.)
					oPnlEsq:Align := CONTROL_ALIGN_LEFT
					oPnlEsq:nWidth := 10
				oPnlDir := TPanel():New(01,01,,oDlgFR0,,,,,,5,5,.F.,.F.)
					oPnlDir:Align := CONTROL_ALIGN_RIGHT
					oPnlDir:nWidth := 10
				oPnlBase := TPanel():New(01,01,,oDlgFR0,,,,,,5,30,.F.,.F.)
					oPnlBase:Align := CONTROL_ALIGN_BOTTOM
					oPnlBase:nHeight := 10
				oPnlTopo := TPanel():New(01,01,,oDlgFR0,,,,,,5,30,.F.,.F.)
					oPnlTopo:Align := CONTROL_ALIGN_TOP
					oPnlTopo:nHeight := 10
				oPnlCons := TPanel():New(01,01,,oDlgFR0,,,,,,5,30,.F.,.F.)
					oPnlCons:Align := CONTROL_ALIGN_TOP
					oPnlCons:nHeight := 40
					oPnlCons1 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlCons1:Align := CONTROL_ALIGN_ALLCLIENT
						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(0,0,{|| FR0->(RetTitle(cCpoFR0))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20
					oSep4 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep4:Align := CONTROL_ALIGN_RIGHT
						oSep4:nWidth := 10
					oSep5 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep5:Align := CONTROL_ALIGN_LEFT
						oSep5:nWidth := 10
					oPnlBot := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,STR0008,oPnlBot1,{|| },30,10,,,,.T.,,"",,,,)		//"Pesquisar"
							oBtnPesq:Align := CONTROL_ALIGN_RIGHT
							oBtnPesq:nWidth := 80
				oSep3 := TPanel():New(01,01,,oDlgFR0,,,,,,5,30,.F.,.F.)
					oSep3:Align := CONTROL_ALIGN_TOP
					oSep3:nHeight := 10
				oPnlBotoes := TPanel():New(01,01,,oDlgFR0,,,,,,5,30,.F.,.F.)
					oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
					oPnlBotoes:nHeight := 20
					oSep0 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep0:Align := CONTROL_ALIGN_TOP
						oSep0:nHeight := 5
					oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep1:Align := CONTROL_ALIGN_RIGHT
					oBtnSair := TButton():New(0,0,STR0016,oPnlBotoes,{|| nItem := 0,oDlgFR0:End()},30,10,,,,.T.,,"",,,,)	//"Cancelar"
						oBtnSair:Align := CONTROL_ALIGN_RIGHT
					oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep2:Align := CONTROL_ALIGN_RIGHT
					oBtnOk := TButton():New(0,0,STR0013,oPnlBotoes,{|| nItem := oBrwFR0:nAt,oDlgFR0:End()},30,10,,,,.T.,,"",,,,) //"Selecionar"
						oBtnOk:Align := CONTROL_ALIGN_RIGHT
				oBrwFR0 := TCBrowse():New(0,0,100,100,,,,oBrwFR0,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)
				oBrwFR0:AddColumn(TCColumn():New(FR0->(RetTitle("FR0_CHAVE")),{|| aItens[oBrwFR0:nAt,1]},,,,"LEFT",15,.F.,.F.,,,,,))
				oBrwFR0:AddColumn(TCColumn():New(FR0->(RetTitle(cCpoFR0)),{|| aItens[oBrwFR0:nAt,2]},,,,"LEFT",150,.F.,.F.,,,,,))
				oBrwFR0:Align     := CONTROL_ALIGN_ALLCLIENT
				oBrwFR0:lAutoEdit := .F.
				oBrwFR0:lReadOnly := .F.
				oBrwFR0:SetArray(aItens)
				oDlgFR0:lCentered := .T.
			oDlgFR0:Activate(,,,,)
		Else
			MsgAlert(STR0014 + cTabela) //"Nใo foram encontrados itens para a tabela "
		Endif
	Else
		MsgAlert(cTabela + ":" + STR0015) //"Tabela nใo encontrada na lista de tabelas auxiliares"
	Endif
	RestArea(aArea)
	If nItem > 0
		FR0->(DbGoTo(aItens[nItem,3]))
		xRet := .T.
	Endif
Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR0CHAVE  บAutor  ณMicrosiga           บFecha ณ 13/03/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR0Chave(cTabela,cChave,cChvAux,cMoeda)
Local cRet		:= ""
Local cCpo		:= ""

Default cTabela	:= ""
Default cMoeda	:= "01"
Default cChvAux	:= ""
Default cChave	:= ""

If !Empty(cTabela)
	cCpo := "FR0_DESC" + cMoeda
	cChave  := PadR(cChave,TamSX3("FR0_CHAVE")[1])
	cChvAux := PadR(cChvAux,TamSX3("FR0_CHVAUX")[1])
	If FR0->(DbSeek(xFilial("FR0") + cTabela + cChave + cChvAux))
		cRet := Alltrim(FR0->(&cCpo))
	Endif
Endif
Return(cRet)