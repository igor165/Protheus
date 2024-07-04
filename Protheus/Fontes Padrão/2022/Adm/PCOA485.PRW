#Include 'Protheus.CH'
#Include "ApWizard.ch"
#Include "PCOA485.ch"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE NOPC DA ROTINAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR			3
#DEFINE ALTERAR			4
#DEFINE EXCLUIR			5

Static nQtdEntid := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA485   บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de regra de distribui็ใo de or็amento              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA485()

Private cCadastro:= STR0001 //"Regras de distribui็ใo Or็amentแrias"
Private aRotina  := MenuDef()

dbSelectArea("AMW")
dbSelectArea("AMZ")

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	MBrowse(6,1,22,75,"AMW")
EndIf

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA485   บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard para manuten็ใo do cadastro de regra                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCO485Wiz(cAlias, nReg, nOpc)
Local oWizard 		:= Nil
Local lConfirma		:= .F.
Local aPBox1	 	:= {} 
Local lRet 			:= .T.
Local cLinOk  		:= "PCO485LIN()"
Local nOpcX 		:= 0
Local aHeader		:= {}
Local aCols			:= {}
Local aRecNo		:= {}
Local aAlter		:= {} 
Local aRetPer		:= Array(2) 

Private lTemOrc := .F.

Private oGetAMZ

If nOpc <> INCLUIR
	If xFilial("AMW") # AMW->AMW_FILIAL .OR. ( AMW->( Eof() ) .AND. AMW->( Bof() ) )
		Help( " ", 1, "ARQVAZIO" )
		Return
	EndIf
EndIf

If nOpc==INCLUIR .or. nOpc==ALTERAR
	EDITWIZAR := .T.
Else
	EDITWIZAR := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIncializa็ใo dos array de resposta do paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc==INCLUIR
	aRetPer[01] 	:= Space( TamSx3('AMW_CODIGO')[1] )
	aRetPer[02] 	:= Space( TamSx3('AMW_DESCR')[1] )
Else
	aRetPer[01] 	:= AMW->AMW_CODIGO
	aRetPer[02] 	:= AMW->AMW_DESCR
EndIf

//Primeira pagina do Wizard
aAdd(aPBox1,{ 1, "* "+STR0003,	Space(TamSx3('AMW_CODIGO')[1]),       "@!"    	 ,""                 ,""  ,"INCLUI",                          0,  .T.}) //"C๓digo" 
aAdd(aPBox1,{ 1, "* "+STR0004, Space(TamSx3('AMW_DESCR')[1]),       "@!"    ,""              ,""  ,"EDITWIZAR",                          150,  .T.})//"Descri็ใo"           


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do acols da get de modificadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCpos := {"AMZ_ITEM","AMZ_CLASSE","AMZ_OPER","AMZ_CC","AMZ_ITCTB","AMZ_CLVLR","AMZ_IDENT","AMZ_CHAVE","AMZ_UM","AMZ_PERC"}
aAlter:= {"AMZ_CLASSE","AMZ_OPER","AMZ_CC","AMZ_ITCTB","AMZ_CLVLR","AMZ_IDENT","AMZ_PERC"} 
 
PCOAPrepList (@aCpos,@aAlter)
PCOAVrfUNIORC(@aCpos,@aAlter)

aHeader := GetaHeader("AMZ",aCpos)
aCols	:= CriaAcols(aHeader,"AMZ",1,xFilial("AMZ")+AMW->AMW_CODIGO,nOpc,,'AMZ_ITEM','AMZ_FILIAL+AMZ_CODIGO' ) 

DEFINE WIZARD oWizard TITLE STR0005 ;//"Este assistente lhe ajudarแ a cadastrar ou dar manuten็ใo nas regras para distribui็ใo "
       HEADER STR0006  ; //"Regras de distribui็ใo Or็amentแrias"	
       MESSAGE "";
       TEXT STR0007 ;//"Voc๊ deverแ escolher os tipos de entidade utilizados na regra, na sequencia cadastrar as entidades os seus percentuais "
       NEXT {||.T.} ;
       FINISH {|| .T. } ;
       PANEL

	//Segunda Pagina 
   CREATE PANEL oWizard ;
          HEADER STR0008  ; //"Dados da regra de distribui็ใo or็amentแria"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| Iif(nOpc <> VISUALIZAR, PCO485Next(aRetPer), .T.) } ;
          FINISH {|| .T. } ;
          PANEL

	ParamBox(aPBox1,STR0009, @aRetPer,,,,,,oWizard:GetPanel(2)) //"Parโmetros..."

	//Terceira Pagina
   CREATE PANEL oWizard ;
          HEADER STR0010 ; //"Regras de Distribui็ใo" 
          MESSAGE STR0011 ;//"Informe a regra de distribui็ใo" 
          BACK {|| .T. } ;
          NEXT {|| .T. };
          FINISH {|| Iif(nOpc <> VISUALIZAR,PCO485TOK(@lConfirma),.T.) } ;
          PANEL
          
   If nOpc == INCLUIR .Or. nOpc == ALTERAR
   		nOpcX := GD_INSERT+GD_DELETE+GD_UPDATE 
   EndIf
     
	oGetAMZ	:= MsNewGetDados():New(0,0,90,305,nOpcX,cLinOk, ,"+AMZ_ITEM", aAlter,,,,,,oWizard:GetPanel(3),aHeader,aCols) 
	oGetAMZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetAMZ:AddAction("AMZ_IDENT",{||PcoIdentF3("AMZ")})

ACTIVATE WIZARD oWizard CENTERED

If lConfirma
	lRet := PCO485Grv(nOpc,aRetPer[1],aRetPer[2])	
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOACompChvRegistro บAutor  ณ          บ Data ณ  19/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da Linha                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOACompChvRegistro(aCols, cChave, nX, nPosClass, nPosOper, nPosCCusto, nPosItCtb, nPosClVlr, nPosUniOrc,nPosEnt05,nPosEnt06,nPosEnt07,nPosEnt08,nPosEnt09)
Local cChav2	:= "" 								    
Local nCont
Local lRet := .F.

cChav2	:= aCols[nX][nPosClass] + aCols[nX][nPosOper] + aCols[nX][nPosCCusto] + aCols[nX][nPosItCtb] + aCols[nX][nPosClVlr] 

if lTemOrc           
	cChav2	+= aCols[nX][nPosUniOrc]
EndIf

If nQtdEntid == Nil
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	EndIf
EndIf

If cPaisLoc != "RUS"
	For nCont := 5 To nQtdEntid
		cChav2	+= aCols[nX][&("nPosEnt"+StrZero(nCont,2))]
	Next nCont
EndIf

	 
if AllTrim (cChave)	== AllTrim (cChav2)					    
	lRet := .T.
EndIf			

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO485Grv บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Grava็ใo de regra de Distribui็ใo                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCO485Grv(nOpc,cCodigo,cDescricao)
Local nX			:= 0
Local nI 			:= 0
Local aCols 	   		:= oGetAMZ:aCols 
Local aHeader  		:= oGetAMZ:aHeader  
Local nPosItem		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMZ_ITEM")})
Local lGrava		:= .F.
Local nItem			:= 1

AMW->(dbSetOrder(1)) //AMW_FILIAL+AMW_CODIGO 
AMZ->(dbSetOrder(1)) //AMZ_FILIAL+AMZ_CODIGO+AMZ_ITEM 

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava o cabe็alho da tabelaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lGrava := ( AMW->(dbSeek(xFilial("AMZ")+cCodigo)) )
	RecLock("AMW",!lGrava)
	AMW->AMW_FILIAL := xFilial("AMZ")
	AMW->AMW_CODIGO := cCodigo
	AMW->AMW_DESCR	:= cDescricao
	MsUnLock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava os Itens da Tabelaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX:= 1 to Len(aCols)
		lGrava := ( AMZ->(dbSeek(xFilial("AMZ")+cCodigo+Acols[nX,nPosItem])) )
		If Acols[nX,Len(aHeader)+1] .And. lGrava 
			RecLock("AMZ",!lGrava)
			AMZ->( dbDelete() )
			MsUnlock()
		ElseIf !Acols[nX,Len(aHeader)+1]
			RecLock("AMZ",!lGrava)
			AMZ->AMZ_FILIAL := xFilial("AMZ")
			AMZ->AMZ_CODIGO := cCodigo
			For nI:= 1 to Len(aHeader)
				If Upper(AllTrim(aHeader[nI,2])) == "AMZ_ITEM"
					AMZ->(FieldPut(FieldPos(Trim(aHeader[nI,2])),StrZero(nItem,aHeader[nI,4])))
				Else 
					AMZ->(FieldPut(FieldPos(Trim(aHeader[nI,2])),aCols[nX,nI]))
				EndIf
			Next nI
			nItem++
			MsUnLock()
		EndIf
	Next nX
	
ElseIf nOpc == EXCLUIR
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeleta os Itensณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AMW->(dbSeek(xFilial("AMZ")+cCodigo))
		RecLock("AMW",.F.)
		AMW->( dbDelete() )
		MsUnlock()
	EndIf
	
	AMZ->(dbSeek(xFilial("AMZ")+cCodigo))
	While AMZ->(!EOF()) .And. AMZ->(AMZ_FILIAL + AMZ_CODIGO ) == xFilial("AMZ")+cCodigo
		RecLock("AMZ",.F.)
		AMZ->( dbDelete() )
		MsUnlock()
		AMZ->(dbSkip())
	EndDo
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO485NextบAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os campos do cabe็alho da regra                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCO485Next(aRetPer)
Local lRet := .T.

If Empty(aRetPer[1]) .Or. Empty(aRetPer[2])
	HELP("  ",1,"OBRIGAT")
	lRet := .F.
EndIf

If lRet
	lRet := ExistChav("AMW", aRetPer[1], 1) 
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO485LIN บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da Linha                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCO485TOK(lConfirma) 
Local lRet		:= .T.
Local aCols		:= oGetAMZ:aCols 
Local aHeader 	:= oGetAMZ:aHeader                      
Local nPosPerc	:= aScan(aHeader , {|x| Alltrim(x[2]) == "AMZ_PERC" })
Local nX		:= 0
Local nSomaPerc := 0

Default lConfirma	:= .F.

For nX := 1 to Len(aCols)
	If aCols[nX,Len(aHeader)+1] == .F. // Nao soma os deletados
		If !PCO485LIN(nX)
			lRet := .F.
			Exit
		EndIf
		nSomaPerc += aCols[nX][nPosPerc]
	EndIf
Next nX

If lRet 
	If nSomaPerc != 100
		HELP("   ",1,"PC485PERC",,STR0014  ,1,0) //" Percentual Invแlido "
		lRet := .F.		
	EndIf	
EndIf

lConfirma := lRet 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO485LIN บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da Linha                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCO485LIN(nAt)
Local lRet 		:= .T.         
Local aCols 		:= oGetAMZ:aCols 
Local aHeader 	:= oGetAMZ:aHeader
Local nPosClass	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLASSE" })
Local nPosOper	:= aScan(aHeader , {|x| AllTrim(x[2]) == 'AMZ_OPER' })
Local nPosCCusto:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CC" })
Local nPosItCtb	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ITCTB" })
Local nPosClVlr	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLVLR" })
Local nPosPerc	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_PERC" })
Local nPosItem	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ITEM" })
Local nPosIdent	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_IDENT" })
Local nPosUM	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UM" })
Local nPosUniOrc:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UNIORC" })
Local nPos		:= 0
Local nX		:= 0
Local nSomaPerc := 0
Local aArea		:= GetArea()
Local cChave	:= ""   
Local nCont     := 0
Local bFunfun := {||}

Private nPosEnt05	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT05" })
Private nPosEnt06	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT06" })
Private nPosEnt07	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT07" })
Private nPosEnt08	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT08" })
Private nPosEnt09	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT09" })

Default nAt := oGetAMZ:nAt  

cChave	:= aCols[nAt][nPosClass] + aCols[nAt][nPosOper] + aCols[nAt][nPosCCusto] + aCols[nAt][nPosItCtb] + aCols[nAt][nPosClVlr]     

if lTemOrc           
	cChave	+= aCols[nAt][nPosUniOrc]
EndIf
	
If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

If cPaisLoc != "RUS"
	For nCont := 5 To nQtdEntid
		cChave	+= aCols[nAt][&("nPosEnt"+StrZero(nCont,2))]
	Next nCont
EndIf

If lRet
	lRet := MaCheckCols(aHeader,aCols,nAt) 
EndIf

AK6->(dbSetOrder(1))
AK6->(MsSeek(xFilial("AK6")+aCols[nAt][nPosClass]))

aCols[nAt][nPosUM] := &(AK6->AK6_UM)
oGetAMZ:Refresh()

If AK6->AK6_OBRIGA=="1" .And. Empty(aCols[nAt][nPosIdent])
	HELP("  ",1,"PCONOCHAVE")
	lRet	:= .F.
EndIf

If lRet .And. AK6->AK6_OPER=="1" .And. Empty(aCols[nAt][nPosOper])
	HELP("  ",1,"PCONOOPER")
	lRet	:= .F.
EndIf

If lRet
	For nX := 1 to Len(aCols)
		If aCols[nX,Len(aHeader)+1] == .F. // Nao soma os deletados
			If nX != nAt .And. ;
			    PCOACompChvRegistro(aCols, cChave, nX, nPosClass, nPosOper, nPosCCusto, nPosItCtb, nPosClVlr, ;
								    nPosUniOrc,nPosEnt05,nPosEnt06,nPosEnt07,nPosEnt08,nPosEnt09)
				HELP("   ",1,"PC485LINDUP",,STR0013+ aCols[nX][nPosItem]  ,1,0)// "Linha Duplicada no Item " 
				lRet := .F.
				Exit 
			EndIf
			nSomaPerc += aCols[nX][nPosPerc]
		EndIf
	Next nX
EndIf

If lRet 
	If nSomaPerc > 100
		HELP("   ",1,"PC485MAX",,STR0014 ,1,0)//" Percentual Invแlido "
		lRet := .F.		
	EndIf	
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณAlvaro Camillo Neto บ Data ณ  19/10/10   บฑฑ
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
ฑฑบ          ณcCPO_ITEM: Opcional Campo de item a ser inicializado com '001'ฑฑ
ฑฑบ          ณcINDICE : Chave de compara็ใo da tabela de item             บฑฑ
ฑฑบ          ณcCPOMemo: Opcional Nome do campo de c๓digo do MEMO          บฑฑ
ฑฑบ          ณcMemo   : Nome do campo memo virtual                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE,cCPOMemo,cMemo)
Local nX			:= 0
Local nCols		      := 0
Local aArea			:= GetArea()   
Local nPosChave		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CHAVE" })
Local nPosClass		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLASSE" }) 
Local nPosIdent		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_IDENT" }) 
Local nPosUM		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UM" }) 

DEFAULT aCols		:= {} 
DEFAULT cCPO_ITEM		:= ""
DEFAULT cCPOMemo		:= ""
DEFAULT cMemo		:= ""

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		If Alltrim(aHeader[nX][2]) == cCPO_ITEM
			aCols[1][nX] := STRZERO(1,TamSX3(cCPO_ITEM)[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIF
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(&(cINDICE))) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			ElseIf (aHeader[nX][8] == "M") // Campo Memo
				aCols[nCols][nX] := MSMM((cAlias)->(&(cCPOMemo)), TamSX3(cMemo)[1] )
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		
		If !Empty( aCols[nCols][nPosClass] ) .And. !Empty(aCols[nCols][nPosChave])
		
			AK6->(DbSetOrder(1))
			If AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] ))
				dbSelectArea(Substr(aCols[nCols][nPosChave],1,3))
				dbSetOrder(If(!Empty(Substr(aCols[nCols][nPosChave] ,4,2)), Val(Substr(	aCols[nCols][nPosChave],4,2)), 1))
				dbSeek(Substr(	aCols[nCols][nPosChave],6,Len(	aCols[nCols][nPosChave] )))
				
				If !Empty(AK6->AK6_VISUAL)
					aCols[nCols][nPosIdent] := &(AK6->AK6_VISUAL)
				EndIf
			EndIF
	
		EndIf		
		aCols[nCols][Len(aHeader)+1] := .F.

		AK6->(DbSetOrder(1))
		If AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] )) 
			If !Empty(AllTrim(AK6->AK6_UM))
				aCols[nCols][nPosUM] :=  &(AK6->AK6_UM)
			EndIf
		EndIf

		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ19/10/2010ณฑฑ
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

aAdd(aRotina , { STR0015	,"AxPesqui", 	1, 1} ) //'Pesquisar'
aAdd(aRotina , { STR0016 	,"PCO485Wiz", 	2, 2} ) //'Visualizar'
aAdd(aRotina , { STR0017		,"PCO485Wiz", 	3, 3} ) //'Incluir'
aAdd(aRotina , { STR0018 		,"PCO485Wiz", 	4, 4} ) //'Alterar'
aAdd(aRotina , { STR0019 		,"PCO485Wiz", 	5, 5} ) //'Excluir'


Return(aRotina)                       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  PCOAPrepList       |                       ณ Data ณ11/11/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMonta Lista de nomes de campos das entidades novas          ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function PCOAPrepList(aArray1, aArray2)                                                        
Local nCont                                                                                     
Local cCampo
Local aAreaAK2		:= GetArea()

If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf           

for nCont := 5 to  nQtdEntid
	if nCont < 10
		cCampo := "AMZ_ENT0" + AllTrim(STR(nCont))
	else
		cCampo := "AMZ_ENT"  + AllTrim(STR(nCont))
	EndIf
                    
	aadd (aArray1, cCampo)     
	aadd (aArray2, cCampo)   
next                 

return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOAVrfUNIORC ณ                                ณ Data ณ02/11/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณVerifica habilita็ใo de acesso do usuแrio a UNIDADE ORวAMENTมRIA ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                                 ณฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PCOAVrfUNIORC(aArray1, aArray2)
Local aAreaAMZ		:= GetArea()
Local cUnidOrc := ''
                
dbSelectArea("AMZ")
dbSetOrder(1)                        

lTemOrc   :=  .F.      

if FieldPos("AMZ_UNIORC") > 0
	lTemOrc := .T.
	aadd (aArray1, "AMZ_UNIORC")     
	aadd (aArray2, "AMZ_UNIORC")     
EndIf 

AMZ->(dbCloseArea())

RestArea(aAreaAMZ)
Return 
