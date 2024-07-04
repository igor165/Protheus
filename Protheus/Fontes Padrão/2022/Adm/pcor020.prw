#INCLUDE "pcor020.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE CELLTAMDATA (TOTAL->TOT_TAMCOL*8)
#DEFINE TAMCELLDATA (TOTFOL->TOT_TAMCOL*8)

Static aPosCol := {}, aCabConteudo := {}, nUltCol := 0

Static _oPCOR0201
Static _oPCOR0202
Static _oPCOR0203


/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR020  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 07-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao da planilha orcamentaria.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR020                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao da planilha orcamentaria.              ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR020(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local nRecAK1
Local oOk			:= LoadBitMap(GetResources(), "LBTIK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local oDlg, oListBox

Private nLin	:= 200
Private cRevisa
Private aTotList := {}
Private aTotBlock := {}

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
	If Len(aPerg) == 0
		oPrint := PcoPrtIni(STR0010,.T.,2,,@lOk,"PCR010") //"Planilha Orcamentaria"
	Else
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
		oPrint := PcoPrtIni(STR0010,.T.,2,,@lOk,"") //"Planilha Orcamentaria"
	EndIf
EndIf

If lOk
	dbSelectArea("AK1")
	dbSetOrder(1)
	If MSSeek(xFilial()+MV_PAR01)
	   	If !Empty(MV_PAR02)
	   		dbSelectArea("AKE")
	   		dbSetOrder(1)
	   		If ! MSSeek(xFilial()+MV_PAR01+MV_PAR02)
	   			MsgStop(STR0019)	// Revisao nao encontrada. Verifique!
	   			lOk := .F.
	   		Else
	   			cRevisa := MV_PAR02
	   		EndIf
	   		dbSelectArea("AK1")
	   	Else			
	      While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial("AK1")+MV_PAR01)
			cRevisa	:= AK1->AK1_VERSAO
			nRecAK1 := AK1->(Recno())
	        AK1->(dbSkip())
	      End
	      AK1->(dbGoto(nRecAK1))
	   	EndIf      
	   
	   	If lOk
			RptStatus( {|lEnd| PCOR020Imp(@lEnd,oPrint)})
		EndIf
	   
    EndIf                                                          
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR020Imp³ Autor ³ Edson Maricate        ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao da planilha orcamentaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR020Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR020Imp(lEnd,oPrint)
Local cAlias           := Alias()
Local aEstrutAK3       := {}, cArqConta
Local aEstrutTOT       := {}, cArqTotal
Local aEstrutTFL       := {}, cArqTFl
Local aChave1			:= {}
Local aChave2			:= {}
Local aChave3			:= {}

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

If _oPCOR0201 <> Nil
	_oPCOR0201:Delete()
	_oPCOR0201:= Nil
Endif

aChave1	:= {"XK3_RECNO"}

_oPCOR0201 := FWTemporaryTable():New("CONTA")
_oPCOR0201:SetFields( aEstrutAK3 )

_oPCOR0201:AddIndex("1", aChave1)	
_oPCOR0201:Create()

cArqConta		:= _oPCOR0201:GetRealName()


AADD(aEstrutTFL,{'TOT_RECNO'	,'C',10,0})
AADD(aEstrutTFL,{'TOT_SEQUEN'	,'C',3,0})
AADD(aEstrutTFL,{'TOT_LDESC'	,'C',1,0})
AADD(aEstrutTFL,{'TOT_LINHA'	,'N',10,0})
AADD(aEstrutTFL,{'TOT_COLUNA'	,'N',10,0})
AADD(aEstrutTFL,{'TOT_CONTEU'	,'C',100,0})
AADD(aEstrutTFL,{'TOT_NROCOL'	,'N',10,0})
AADD(aEstrutTFL,{'TOT_TAMCOL'	,'N',10,0})
AADD(aEstrutTFL,{'TOT_LINIMP'	,'N',10,0})
AADD(aEstrutTFL,{'TOT_COLIMP'	,'N',10,0})

If _oPCOR0202 <> Nil
	_oPCOR0202:Delete()
	_oPCOR0202:= Nil
Endif

aChave2	:= {"TOT_RECNO","TOT_SEQUEN","TOT_LINHA","TOT_COLUNA"}

_oPCOR0202 := FWTemporaryTable():New("TOTFOL")
_oPCOR0202:SetFields( aEstrutTFL )

_oPCOR0202:AddIndex("1", aChave2)	
_oPCOR0202:Create()

cArqTFL 		:= _oPCOR0202:GetRealName()


dbSelectArea("TOTFOL")
dbSetOrder(1)

AADD(aEstrutTOT,{'TOT_RECNO'	,'C',10,0})
AADD(aEstrutTOT,{'TOT_SEQUEN'	,'C',3,0})
AADD(aEstrutTOT,{'TOT_LDESC'	,'C',1,0})
AADD(aEstrutTOT,{'TOT_LINHA'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_COLUNA'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_CONTEU'	,'C',100,0})
AADD(aEstrutTOT,{'TOT_NROCOL'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_TAMCOL'	,'N',10,0})
AADD(aEstrutTOT,{'TOT_LINIMP'	,'N',10,0})

If _oPCOR0203 <> Nil
	_oPCOR0203:Delete()
	_oPCOR0203:= Nil
Endif

aChave3	:= {"TOT_RECNO","TOT_SEQUEN"}

_oPCOR0203 := FWTemporaryTable():New("TOTAL")
_oPCOR0203:SetFields( aEstrutTOT )

_oPCOR0203:AddIndex("1", aChave3)	
_oPCOR0203:Create()

cArqTotal 		:= _oPCOR0203:GetRealName()

dbSelectArea("TOTAL")
dbSetOrder(1)

dbSelectArea("AK3")
dbSetOrder(3)

If MsSeek(xFilial()+cOrcame+cRevisa+"001")
	While !Eof() .And. 	AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL==;
						xFilial("AK3")+cOrcame+cRevisa+"001"
		PCOR020It(AK3_ORCAME,AK3_VERSAO,AK3_CO)
		dbSelectArea("AK3")
		dbSkip()
	End
EndIf

//Impressao do relatorio
dbSelectArea("CONTA")
dbGoTop()
If !Eof()
	R020Cabec()
EndIf

While ! Eof()
	
	If PcoPrtLim(nLin+150)
		nLin := 200
		R020Cabec()
		R020QuebraPag()
	EndIf

	R020DetConta()

	dbSelectArea("CONTA")
	CONTA->(dbSkip())
	
End

If TOTFOL->(!Eof())
	nLin := 200
	R020Cabec()
	R020QuebraPag()
EndIf

dbSelectArea("CONTA")
dbCloseArea()
If _oPCOR0201 <> Nil
	_oPCOR0201:Delete()
	_oPCOR0201:= Nil
Endif

dbSelectArea("TOTFOL")
dbCloseArea()
If _oPCOR0202 <> Nil
	_oPCOR0202:Delete()
	_oPCOR0202:= Nil
Endif

dbSelectArea("TOTAL")
dbCloseArea()
If _oPCOR0203 <> Nil
	_oPCOR0203:Delete()
	_oPCOR0203:= Nil
Endif

dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOR020It ³ Autor ³ Edson Maricate        ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao da planilha orcamentaria.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR020Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOR020It(cOrcame,cVersao,cCO)
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
                  
// Se o centro Orcamentario pertence ao filtro que foi selecionado
IF (AK3->AK3_CO >= MV_PAR03 .AND. AK3->AK3_CO <= MV_PAR04 )
	// Se o Nivel pertence ao filtro que foi selecionado
	IF (AK3->AK3_NIVEL >= MV_PAR05 .AND. AK3->AK3_NIVEL <= MV_PAR06 )
		// se usuario tem acesso a conta orcamentaria
		If PcoChkUser(cOrcame, cCO, AK3->AK3_PAI, 1, "ESTRUT", cVersao)
			If R020Totais(aTotList, aTotBlock)
				R020ContaOrc()	//somente grava a conta se registros totais for maior que zero
			EndIf
		EndIf	
	EndIf
EndIf

dbSelectArea("AK3")
dbSetOrder(2)

If MsSeek(xFilial()+cOrcame+cVersao+cCO)
   	While !Eof() .And. AK3->AK3_FILIAL+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_PAI==xFilial("AK3")+cOrcame+cVersao+cCO
		PCOR020It(AK3_ORCAME,AK3_VERSAO,AK3_CO)
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
±±ºPrograma  ³R020TotaisºAutor  ³Paulo Carnelossi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa os blocos de codigos contidos no array atotBlock    º±±
±±º          ³do list box selecionado (aTotBlock - array recno TABELA AKK)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020Totais(aTotList, aTotBlock)
Local nX, aResult := {}, aRetorno := {}, lRetorno := .F., lRet := .F.
For nX := 1 TO Len(aTotList)
	If aTotList[nX][1]
		AKK->(dbGoto(aTotBlock[nX][1]))
		If !Empty(AKK->AKK_BLOCK)
			aResult := PCOExecForm(AKK->AKK_BLOCK)
			If Len(aResult) > 1  // primeira elemento e o cabecalho
				lRet := R020TotOrc(aResult[1], aResult[2], aResult[3], nX)
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
±±ºPrograma  ³R020ContaOrcºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as contas orcamentarias em arquivo temporario para    º±±
±±º          ³posterior impressao                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020ContaOrc()				

CONTA->(dbAppend())
CONTA->XK3_RECNO	:= StrZero(AK3->(Recno()),10)
CONTA->XK3_LDESC	:= "1"
CONTA->XK3_ORCAME	:= AK3->AK3_ORCAME
CONTA->XK3_CO		:= AK3->AK3_CO
CONTA->XK3_NIVEL	:= AK3->AK3_NIVEL
CONTA->XK3_DESCRI	:= AK3->AK3_DESCRI
CONTA->XK3_TIPO		:= AK3->AK3_TIPO

Return						

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020TotOrc  ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava totais das contas orcamentarias em arquivo temporario º±±
±±º          ³posterior impressao                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020TotOrc(aRet, aCols, nCols, nTotBlock)
Local nX, nY, lRet := .F.
Local nVal := 0

For nX := 2 TO Len(aRet)
	For nY := 1 TO Len(aCols)   
	    If Type(aRet[nX][nY]) == "N"
			nVal += Val(aRet[nX][nY])
		EndIf	
    Next
Next

lRet := (nVal > 0)

If lRet
	For nX := 1 TO Len(aRet)
		For nY := 1 TO Len(aCols)
			TOTAL->(dbAppend())
			TOTAL->TOT_RECNO	:= StrZero(AK3->(Recno()),10)
	        TOTAL->TOT_SEQUEN   := StrZero(nTotBlock, 3)
			TOTAL->TOT_LDESC	:= "1"
			TOTAL->TOT_LINHA	:= nX
			TOTAL->TOT_COLUNA	:= nY
			TOTAL->TOT_CONTEU	:= aRet[nX][nY]
			TOTAL->TOT_NROCOL	:= nCols
			TOTAL->TOT_TAMCOL   := aCols[nY]
			TOTAL->TOT_LINIMP	:= 0
	    Next
	Next
EndIf
    
Return(lRet)						

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020TotFolhaºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava totais das contas orcamentarias em arquivo temporario º±±
±±º          ³que nao foram impressos na pagina principal - continuacao   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020TotFolha()
TOTFOL->(dbSetOrder(1))
If TOTFOL->(!dbSeek(TOTAL->TOT_RECNO+TOTAL->TOT_SEQUEN+STRZERO(TOTAL->TOT_LINHA,3)+STRZERO(TOTAL->TOT_COLUNA,3)))
	TOTFOL->(dbAppend())
	TOTFOL->TOT_RECNO	:= TOTAL->TOT_RECNO
	TOTFOL->TOT_SEQUEN  := TOTAL->TOT_SEQUEN
	TOTFOL->TOT_LDESC	:= TOTAL->TOT_LDESC
	TOTFOL->TOT_LINHA	:= TOTAL->TOT_LINHA
	TOTFOL->TOT_COLUNA	:= TOTAL->TOT_COLUNA
	TOTFOL->TOT_CONTEU	:= TOTAL->TOT_CONTEU
	TOTFOL->TOT_NROCOL	:= TOTAL->TOT_NROCOL
	TOTFOL->TOT_TAMCOL  := TOTAL->TOT_TAMCOL
	TOTFOL->TOT_LINIMP	:= TOTAL->TOT_LINIMP
	TOTFOL->TOT_COLIMP	:= 0
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020Cabec   ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho principal do relatorio                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020Cabec()

PcoPrtCab(oPrint)
PcoPrtCol({20,370,470,2075,2250})
PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,cOrcame,oPrint,4,2,/*RgbColor*/,STR0002) //"Codigo"
PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,cRevisa,oPrint,4,2,/*RgbColor*/,STR0011) //"Versao"
PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,cDesAK1,oPrint,4,2,/*RgbColor*/,STR0003) //"Descricao"
PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,DTOC(dIniPer),oPrint,4,2,/*RgbColor*/,STR0012) //"Dt.Inicio"
PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,DTOC(dFimPer),oPrint,4,2,/*RgbColor*/,STR0013) //"Dt.Fim"
nLin+=70

R020CabConta()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020Cabec   ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho secundario (contas orcamentarias)do relatorio     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020CabConta()

PcoPrtCol({20,370,470,2150})
PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0014,oPrint,2,1,RGB(230,230,230)) //"C.O."
PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0015,oPrint,2,1,RGB(230,230,230)) //"Nivel"
PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0003,oPrint,2,1,RGB(230,230,230)) //"Descricao"
PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0016,oPrint,2,1,RGB(230,230,230)) //"Tipo"
nLin+=75

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020DetContaºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Detalhe do relatorio - contas orcamentarias                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020DetConta()
Local lDescricao := (CONTA->XK3_LDESC=="1")
Local nX

If lDescricao
	PcoPrtCol({20,370,470,2150})
	PcoPrtCell(PcoPrtPos(1),nLin,,60,PcoRetCo(CONTA->XK3_CO),oPrint,1,3)
	PcoPrtCell(PcoPrtPos(2),nLin,,60,CONTA->XK3_NIVEL,oPrint,1,3)
	PcoPrtCell(PcoPrtPos(3),nLin,,60,SPACE((VAL(CONTA->XK3_NIVEL)-1)*3)+CONTA->XK3_DESCRI,oPrint,1,3)
	If Empty(CONTA->XK3_TIPO).Or.CONTA->XK3_TIPO == "1"
		PcoPrtCell(PcoPrtPos(4),nLin,,60,STR0017,oPrint,1,3) //"Sintetica"
	Else
		PcoPrtCell(PcoPrtPos(4),nLin,,60,STR0018,oPrint,1,3) //"Analitica"
	EndIf
	CONTA->XK3_LDESC := "0"  //
EndIf	
nLin+= 70

For nX := 1 TO Len(aTotList)
	If aTotList[nX][1]
		R020Total(CONTA->XK3_RECNO+StrZero(nX,3),lDescricao)
	EndIf
	nLin += 40
Next
nLin+= 70

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020Total   ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos totalizadores para conta orcamentaria impressaº±±
±±º          ³no detalhe do relatorio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020Total(cChave, lDescricao)
Local nTam
//Impressao do relatorio
dbSelectArea("TOTAL")
dbSeek(cChave)

nTam := 300

If dbSeek(cChave)
	While TOTAL->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave)
		R020TotImpr(cChave, lDescricao, nTam)
	End
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020TotImpr ºAutor  ³Paulo Carnelossi  º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos totalizadores para conta orcamentaria impressaº±±
±±º          ³no detalhe do relatorio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020TotImpr(cChave, lDescricao, nTamOrig)
Local nX, nTam := 0, nLinImpr 

nTam += nTamOrig

If PcoPrtLim(nLin)
	nLin := 200
	R020Cabec()
	R020QuebraPag()
EndIf

If TOTAL->TOT_LINHA == 1  //monta cabecalho dos totais
	//primeiro monta cabecalho
	aPosCol := {}
	aCabConteudo := {}

	While TOTAL->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. ;
		TOT_LINHA == 1 .And.  (nTam+CELLTAMDATA) <= 3100 )
		aAdd(aPosCol, nTam)
		nTam += CELLTAMDATA
		aAdd(aCabConteudo, TOTAL->TOT_CONTEU)
		nUltCol := TOTAL->TOT_COLUNA
		
		TOTAL->(dbDelete())
		TOTAL->(dbSkip())
	End
	//desprezaos registros que nao sao necessarios
	While TOTAL->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. ;
			TOTAL->TOT_LINHA == 1 .And. TOT_COLUNA > nUltCol) 
		TOTAL->TOT_LINIMP := nLin
		R020TotFolha()
		TOTAL->(dbDelete())
		TOTAL->(dbSkip())
	End

	PcoPrtCol(aPosCol)

	//agora imprime o cabecalho
   	For nX := 1 TO Len(aCabConteudo)
		PcoPrtCell(PcoPrtPos(nX),nLin,PcoPrtTam(nX),30,aCabConteudo[nX],oPrint,2,1,RGB(230,230,230))
   	Next
	nLin+=30
Else
	//primeiro monta linha com as colunas
	nLinImpr := TOTAL->TOT_LINHA
	aPosCol := {}
	aCabConteudo := {}
	
	While TOTAL->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. ;
		TOT_LINHA == nLinImpr .And.  (nTam+CELLTAMDATA) <= 3100 )
		aAdd(aPosCol, nTam)
		nTam += CELLTAMDATA
		aAdd(aCabConteudo, TOTAL->TOT_CONTEU)
		TOTAL->(dbDelete())
		TOTAL->(dbSkip())
	End 
	
	//ja avanca os registros que nao sao necessarios
	While TOTAL->(! Eof() .And. TOT_RECNO+TOT_SEQUEN == cChave .And. ;
			TOTAL->TOT_LINHA == nLinImpr .And. TOT_COLUNA > nUltCol)
		TOTAL->TOT_LINIMP := nLin
		R020TotFolha()
		TOTAL->(dbDelete())
		TOTAL->(dbSkip())
	End

	//agora imprime a linha
	PcoPrtCol(aPosCol)
	
   	For nX := 1 TO Len(aCabConteudo)
		PcoPrtCell(PcoPrtPos(nX),nLin,,40,aCabConteudo[nX],oPrint,1,3,,,nX!=1)
   	Next
	nLin+=40
End 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020QuebraPag ºAutor ³Paulo Carnelossi  º Data ³ 04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da continuacao dos totalizadores para contas orc. º±±
±±º          ³impressas na pagina principal                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020QuebraPag()
Local cAlias := Alias()

dbSelectArea("TOTFOL")
dbSetOrder(0)
dbGoTop()

While ! Eof()
	R020DetQbPag()
End

dbSelectArea("TOTFOL")
dbGoTop()
If !Eof()
	nLin := 200
	R020Cabec()
	R020QuebraPag()
Else 
	dbSelectArea("TOTFOL")
    ZAP
	If CONTA->(!Eof())
		nLin := 200
		R020Cabec()
	EndIf	
EndIf

dbSelectArea(cAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R020DetQbPag  ºAutor ³Paulo Carnelossi  º Data ³ 04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da continuacao dos totalizadores para contas orc. º±±
±±º          ³impressas na pagina principal                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R020DetQbPag()
Local nX, nTam := 20, nLinImpr, cChave

cChave := TOTFOL->TOT_RECNO+TOTFOL->TOT_SEQUEN

If TOTFOL->TOT_LINHA == 1  //monta cabecalho dos totais
	//primeiro monta cabecalho
	aPosCol := {}
	aCabConteudo := {}
	nLin := TOTFOL->TOT_LINIMP
	While TOTFOL->(! Eof() .And. TOTFOL->TOT_RECNO+TOTFOL->TOT_SEQUEN==cChave .And. ;
		TOT_LINHA == 1 .And.  (nTam+TAMCELLDATA) <= 3100 )
		aAdd(aPosCol, nTam)
		nTam += TAMCELLDATA
		aAdd(aCabConteudo, TOTFOL->TOT_CONTEU)
		nUltCol := TOTAL->TOT_COLUNA
		TOTFOL->(dbDelete())
		TOTFOL->(dbSkip())
	End
	//desprezaos registros que nao sao necessarios
	While TOTFOL->(! Eof() .And. TOTFOL->TOT_LINHA == 1 .And. ;
		 TOTFOL->TOT_RECNO+TOTFOL->TOT_SEQUEN==cChave .And. TOT_COLUNA > nUltCol) 
		TOTFOL->(dbSkip())
	End

	PcoPrtCol(aPosCol)

	//agora imprime o cabecalho
   	For nX := 1 TO Len(aCabConteudo)
		PcoPrtCell(PcoPrtPos(nX),nLin,PcoPrtTam(nX),30,aCabConteudo[nX],oPrint,2,1,RGB(230,230,230))
   	Next
	nLin+=30
Else
	//primeiro monta linha com as colunas
	nLinImpr := TOTFOL->TOT_LINHA
	aPosCol := {}
	aCabConteudo := {}
	nLin := TOTFOL->TOT_LINIMP
	
	While TOTFOL->(! Eof() .And. TOT_LINHA == nLinImpr .And.  ;
			 TOTFOL->TOT_RECNO+TOTFOL->TOT_SEQUEN==cChave .And.(nTam+TAMCELLDATA) <= 3100 )
		aAdd(aPosCol, nTam)
		nTam += TAMCELLDATA
		aAdd(aCabConteudo, TOTFOL->TOT_CONTEU)
		nUltCol := TOTAL->TOT_COLUNA
		TOTFOL->(dbDelete())
		TOTFOL->(dbSkip())
	End 
	
	//ja avanca os registros que nao sao necessarios
	While TOTFOL->(! Eof() .And. TOTFOL->TOT_LINHA == nLinImpr .And. ;
			 TOTFOL->TOT_RECNO+TOTFOL->TOT_SEQUEN==cChave .And. TOT_COLUNA > nUltCol)
		TOTFOL->(dbSkip())
	End

	//agora imprime a linha
	PcoPrtCol(aPosCol)

   	For nX := 1 TO Len(aCabConteudo)
		PcoPrtCell(PcoPrtPos(nX),nLin,,40,aCabConteudo[nX],oPrint,1,3,,, .T.)
   	Next
	nLin+=40
End 

Return
