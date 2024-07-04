#INCLUDE "CTBC661A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"

// ESTRUTURA DE DADOS DA ARRAY aFiltro
#DEFINE FILTRO_DTINI	1
#DEFINE FILTRO_DTFIM	2
#DEFINE FILTRO_MOEDA	3
#DEFINE FILTRO_LCONF	4
#DEFINE FILTRO_DIVER	5
#DEFINE FILTRO_FILALL	6
#DEFINE FILTRO_LSEQUEM	7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define das posiçoes do array de empresas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE NUM_COL_EMP		6
#DEFINE EMP_SELECAO		1 
#DEFINE EMP_CODIGO		2
#DEFINE EMP_FILIAL		3
#DEFINE EMP_DESCRIC		4
#DEFINE EMP_CGC			5
#DEFINE EMP_MODO_CT2	6

Static lFWCodFil	:= FindFunction( "FWCodFil" )
Static lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Static lMarcaTudo	:= .F.

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : Ctbc661A
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Efetua a montagem do wizard de perguntas
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function Ctbc661A( cEmp, aFiltro, aFiliais )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas utilizadas no Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeader  		:= {}
Local aTexto   		:= {}
Local aPergs   		:= {}
Local aParams  		:= {}

Local lFim     		:= .F.
Local lAdmin  		:= .F. 

Local cMatriz		:= Space(CtbTamFil("033",2))

Local oOk
Local oNo
Local oBold			:= Nil
Local oFil 			:= Nil
Local oMarcaTudo	:= Nil
Local oQtdDoc		:= Nil	
Local oQtdMrk		:= Nil

Private nQtdMrk		:= 0
Private oWizard		:= Nil
Private aFils		:= {}

Default cEmp		:= cEmpAnt

IF Len( aFiltro ) == 0
	Aadd( aFiltro , CTOD("") )
	Aadd( aFiltro , CTOD("") )
	Aadd( aFiltro , Space(CTO->(TamSx3("CTO_MOEDA")[1])) )
	Aadd( aFiltro , 1 )
	Aadd( aFiltro , 1 )
	Aadd( aFiltro , .F. )
	Aadd( aFiltro , 1 )
EndIf

aParams1 	:= CTC661AParam('1', aFiltro )
aParams2 	:= CTC661AParam('2', aFiltro )
oOk 		:= LoadBitmap( GetResources(), "LBOK")
oNo			:= LoadBitmap( GetResources(), "LBNO")
	
aPergs1	 	:= aParams1[1]
aResps1		:= aParams1[2]
	
aPergs2	 	:= aParams2[1]
aResps2		:= aParams2[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aheader do ListBox das Filiais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := ARRAY(5)

aHeader[1]	:= ""  		
aHeader[2] 	:= IIF(lGestao,STR0001,STR0002) //### //"Filial"###"Empresa/Unidade/Filial"
aHeader[3] 	:= STR0003 // //"Razão Social"
aHeader[4]	:= STR0004 // //"CNPJ"
aHeader[5]	:= ""

aFils := GetFiliais( cEmp )

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard ;
	TITLE STR0005 + cEmp; // //"Assistente de configuração do Rastreamento Contábil - Empresa: "
	HEADER STR0006; // //"Atenção"
	MESSAGE "" ;
	TEXT STR0007 + CRLF + STR0008; //### //"Essa rotina tem como objetivo ajudá-lo a configurar o rastreamento Contábil"###"Siga atentamente os passos, pois iremos efetuar a parametrização dos seus dados contábeis."
	NEXT {|| .T.} ;
	FINISH {||.T.}
       
CREATE PANEL oWizard  ;
	HEADER STR0009; // //"Informe os parametros de filragem do dados contabeis para o Rastreamento."
	MESSAGE "";
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergs1,aResps1)} ;
	PANEL
	
	ParamBox(aPergs1,"", @aResps1,,,,,,oWizard:GetPanel(2)) 

CREATE PANEL oWizard  ;
	HEADER STR0009; // //"Informe os parametros de filragem do dados contabeis para o Rastreamento."
	MESSAGE "";
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergs2,aResps2)} ;
	PANEL
	
	ParamBox(aPergs2,"", @aResps2,,,,,,oWizard:GetPanel(3)) 

CREATE PANEL oWizard  ;
	HEADER STR0010; // //"Informe quais são as filiais para o Rastreamento."
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaEmp(aFils)} ;
	PANEL

	@ 005,005 CHECKBOX oMarcaTudo VAR lMarcaTudo PROMPT 'Marca/Desmarca Todos' SIZE 168, 08	ON CLICK(MarcaTudo(aFils, oFil, oQtdMrk )) OF oWizard:GetPanel(4) PIXEL

	oFil := TWBrowse():New( 1.1, 0.5 , 295, 110,Nil,aHeader, Nil, oWizard:GetPanel(4), Nil, Nil, Nil,Nil,;
					      {|| aFils := EmpTroc( oFil:nAt, aFils, .T. ), oFil:Refresh() })      

	oFil:SetArray( aFils )
	oFil:bLDblClick := {|| Marca(aFils, oFil, oQtdMrk) }  

	oFil:bLine 		:= {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4],;
						aFils[oFil:nAt,5];
					}}

	@ 130,005 SAY "Total de Filiais: " OF  oWizard:GetPanel(4) PIXEL 
 	@ 128,055 MSGET oQtdDoc VAR Len(aFils) WHEN .F. OF  oWizard:GetPanel(4) PIXEL PICTURE '@E 999,999'

	@ 130,090 SAY "Filiais Marcadas: " OF  oWizard:GetPanel(4) PIXEL
	@ 128,140 MSGET oQtdMrk VAR nQtdMrk WHEN .F. OF  oWizard:GetPanel(4) PIXEL PICTURE '@E 999,999'

CREATE PANEL oWizard  ;
	HEADER STR0011 ;  // //"Etapa de Configuração Finalizada!"
	MESSAGE ""	;
	BACK {|| .T.} ;
	NEXT {|| .F.};
	FINISH {|| RetParam(@aFiltro, aResps1, aResps2, @aFiliais, @lFim) };
	PANEL

	@ 050,010 SAY STR0012 SIZE 270,020 FONT oBold PIXEL OF oWizard:GetPanel(5)  // //"Clique no botão finalizar para fechar o wizard e iniciarmos a montagem da tela de rastreamento."

ACTIVATE WIZARD oWizard CENTERED

Return lFim 


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTC661AParam
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Efetua a montagem do wizard de perguntas
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CTC661AParam(cPainel , aParamOld )
Local aPerguntas := {}
Local aRespostas := {}
Local aRetorno	 := {}

IF cPainel == '1' .OR. Empty( cPainel )
	aAdd(aPerguntas,{1,STR0013	,aParamOld[1],"","","",,60,.T.}) 						//"Periodo Inicial Lcto"
	aAdd(aPerguntas,{1,STR0014	,aParamOld[2],"","","",,60,.T.}) 						//"Periodo Final Lcto"
	aAdd(aPerguntas,{1,STR0015	,aParamOld[3],"@!","ExistCpo('CTO')","CTO",,05,.T.}) 	//"Moeda"

	Aadd( aRespostas , aParamOld[1])
	Aadd( aRespostas , aParamOld[2])
	Aadd( aRespostas , aParamOld[3])
Endif

If cPainel == '2' .OR. Empty( cPainel )
	aAdd(aPerguntas,{3,STR0016	,aParamOld[4],{STR0017,STR0018,STR0019},120,"",.T.}) 	//"Documento já conferido?"###"Não Conferidos"###"Conferidos"###"Todos"
	aAdd(aPerguntas,{3,STR0020	,aParamOld[5],{STR0021,STR0022},120,"",.T.}) 			//"Seleciona não divergentes?"###"Sim"###"Não"
	aAdd(aPerguntas,{3,'Exibir Lctos. Por:',aParamOld[7],{'Registro Gerado','Sequencia de Lcto.'},120,"",.T.})
	
	Aadd( aRespostas , aParamOld[4] )
	Aadd( aRespostas , aParamOld[5] )
	Aadd( aRespostas , aParamOld[7] )

Endif

Aadd( aRetorno, aPerguntas )
Aadd( aRetorno, aRespostas )

Return aRetorno

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : ValidaParam
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Efetua a validação das perguntas
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function ValidaParam(aPergGener,aResGener,lPos,bValid)
Local aMsgAlert := {}
Local cMsgAlert := ""
Local nX 		:= 0
Local lRet		:= .T.

Default lPos	:= .F.
Default bValid := {||.T.}

For nX := 1 To Len(aResGener)
	If Empty( aResGener[nX] ) .And. Iif( aPergGener[nX][1] == 1, aPergGener[nX][9], aPergGener[nX][7])
		Aadd( aMsgAlert, aPergGener[nX][2] )
		lRet := .F.
	EndIf
Next

If !Empty( aMsgAlert )
	cMsgAlert := STR0023+CRLF+CRLF // //"Campos obrigatórios não preenchidos: "
	For nX := 1 To Len( aMsgAlert )
		cMsgAlert += aMsgAlert[nX] + CRLF
	Next
	lRet:= .F.
EndIf

If lRet
	lRet := Eval( bValid )
	If !lRet
		cMsgAlert := If( Empty(cMsgAlert), StrTran('STR0061',":","."), cMsgAlert)
	EndIf
EndIf

If !lRet
	MsgAlert( cMsgAlert )
Elseif lRet .And. lPos
	Return lRet
Else
	lRet := .T.
EndIf

Return lRet

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CtbTamFil
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Retorna o tamanho da filial
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbTamFil(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : EmpTroc
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Efetua a troca dos itens marcados no wizard
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function EmpTroc(nIt,aArray,lEmp)
Local nCont	  		:= 1
Local cEmpAtu 		:= ""
Local cFilAtu 		:= ""
Local cModo			:= ""
Local cMensagem		:= STR0024 // //"A tabela de lançamentos está compartilhada, nesse caso marque somente uma filial"
Local aFilEmp		:= {}
Local nPosFil		:= 0

Default lEmp := .F.

If lEmp
	cEmpAtu	:= aArray[nIt][2]
	cFilAtu	:= aArray[nIt][3]
	
	cModo	:= aArray[nIt][6]
	
	// Se o CT2 for compartilhado, verificar se esta marcando mais de uma filial
	If cModo == "C"
		For nCont := 1 to Len(aArray)
			If nCont <> nIt //Nao verificar o que esta sendo marcado/desmarcado
				If aArray[nCont][1] .And. cEmpAtu == aArray[nCont][2] .And. cFilAtu <> aArray[nCont][3]
					If !IsBlind()
						MsgAlert( cMensagem )
					EndIf
					
					Return(aArray)
				EndIf
			EndIf
		Next
	ElseIf lGestao // Validação para Gestao Corporativa
		For nCont := 1 to Len(aArray)
			If (aArray[nCont][1] .Or. nCont == nIt ).And. cEmpAtu == aArray[nCont][2] 
				nPosFil := aScan(aFilEmp,{ |x| Alltrim(x) ==  Alltrim(xFilial("CT2",aArray[nCont][3])) })
				
				If nPosFil > 0
					If !IsBlind()
						MsgAlert( cMensagem )
					EndIf
					Return(aArray)
				Else
					aAdd(aFilEmp,Alltrim(xFilial("CT2",aArray[nCont][3])))
				EndIF
			EndIf
		Next
	EndIf
EndIf

aArray[nIt,1] := !aArray[nIt,1]

Return aArray


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : ValidaEmp
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : valida os itens marcados no wizard
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function ValidaEmp( aEmp )
Local lEmpresa	:= .F.
Local lRet 		:= .T.

lEmpresa := ( nQtdMrk > 0 )

// Nao selecionou nenhuma empresa
If !lEmpresa
	HELP ("Nenhuma filial selecionada!",1,"C210S/EMP")
	lRet 	 := .F.
Endif

If lRet
	lMarcaTudo := ( Len(aEmp) == nQtdMrk )
Endif

Return lRet


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : RetParam
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : valida os itens marcados no wizard
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function RetParam(aFiltro, aResp1, aResp2, aFiliais, lFim )
Local nIx	:= 1

// Atualiza os parametros de filtro
aFiltro := {aResp1[1],aResp1[2],aResp1[3],aResp2[1],aResp2[2],lMarcaTudo,aResp2[3]}

// atualiza as filiais a serem filtradas
aFiliais := {}
For nIx := 1 TO Len( aFils )
	If aFils[nIx,1] // Marcado
		Aadd( aFiliais , aFils[nIx,3] )
	Endif
Next

lFim := ( Len( aFiltro ) > 0 .And. Len( aFiliais ) > 0 )

Return lFim


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTBC661AP
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : valida os itens marcados no wizard
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Function CTBC661AP( aFiltro )

Local aParam	:= CTC661AParam('',aFiltro)
Local aPergs1 	:= aParam[1]
Local aResps1 	:= aParam[2]
Local lOk		:= .T.

lOk := ParamBox(aPergs1  ,STR0025, @aResps1) //,,         ,.T.       ,350,10) // //"Rastreamento Contábil"

If lOk
	aFiltro := {aResps1[1],aResps1[2],aResps1[3],aResps1[4],aResps1[5],lMarcaTudo,aResps1[6]}
Endif

Return lOk


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : GetFiliais
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Retorna as filiais para o wizard
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function GetFiliais(cEmp)
Local aArea 	:= GetArea() 					 // Salva Alias Anterior 
Local aFilAtu	:= {}
Local aGrupo    := ""
Local aRetorno	:= {}
Local aSM0		:= FWLoadSM0() //AdmAbreSM0()
Local aUsrFil	:= {}

Local cModo		:= 'E'

Local nInc		:= 0    
Local nX		:= 0   
Local nXFil		:= 0

If lGestao     
	cModo	:= FWModeAccess("CT2",1,cEmpAnt) + FWModeAccess("CT2",2,cEmpAnt) + FWModeAccess("CT2",3,cEmpAnt)
	cModo   := IIF(  "E" $cModo , "E" , "C" )   
Else
	cModo	:= FWModeAccess("CT2",3,cEmpAnt)
EndIf

// Adiciona as filiais que o usuario tem permissão
For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt	
		aAdd(aRetorno ,Array(NUM_COL_EMP) )    
		aRetorno[Len(aRetorno)][EMP_SELECAO] 	:= .F.
		aRetorno[Len(aRetorno)][EMP_CODIGO] 	:= aSM0[nInc][1]
		aRetorno[Len(aRetorno)][EMP_FILIAL] 	:= aSM0[nInc][2]
		aRetorno[Len(aRetorno)][EMP_DESCRIC] 	:= aSM0[nInc][17]
		aRetorno[Len(aRetorno)][EMP_CGC]     	:= aSM0[nInc][18]
		aRetorno[Len(aRetorno)][EMP_MODO_CT2] 	:= cModo   
	Endif
Next

RestArea( aArea )

Return aRetorno

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : Marca
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Marca um item no listbox
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function Marca(aListBox, oListBox, oQtdMrk, nItem, lMarca, lRefresh )

Default nItem   	:= oListBox:nAt
Default lMarca		:= Nil
Default lRefresh	:= .T.

aListBox[nItem,1] := Iif( lMarca == Nil, !aListBox[nItem,1] , lMarca )

If aListBox[nItem,1]
	nQtdMrk += 1 
Else
	nQtdMrk := iif( lMarca <> Nil .And. !lMarca, 0 , nQtdMrk-1 )
EndIf	

If lRefresh
	oQtdMrk:Refresh()
	oListBox:Refresh()
Endif

Return( Nil )


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : MarcaTudo
//± Autor        : Renato Campos
//± Data         : 11/08/2012
//± Uso          : Marca todos os itens no listbox
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarcaTudo(aListBox, oListBox, oQtdMrk )
Local nI := 0

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	Marca(aListBox, oListBox, oQtdMrk, nI, lMarcaTudo, .F. )
Next nI	

CursorArrow()

oQtdMrk:Refresh()
oListBox:Refresh()

Return
