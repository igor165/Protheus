#INCLUDE "QMTA210.CH"
#INCLUDE "PROTHEUS.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QMTA210    ³ Autor ³ Denis Martins      ³ Data ³24.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Ordem de Servico                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QMTA210()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQMT                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³ Alteracao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³        ³      ³           ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui", 0,1,,.F.},; //"Pesquisar"
					{STR0002, "QM210Telas",0,2},; //"Visualizar"
					{STR0003, "QM210Telas",0,3},; //"Incluir"
					{STR0004, "QM210Telas",0,4},; //"Alterar"
					{STR0005, "QM210Telas",0,5}}  //"Excluir"

Return aRotina

Function QMTA210()

Private cCadastro:= STR0012 //Cadastro
Private aRotina  := MenuDef()

DbSelectArea("QMZ")
DbSetOrder(1)
DbGoTop()

mBrowse(006,001,022,075,"QMZ")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QM210Telas  ³ Autor ³ Denis Martins      ³ Data ³24.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QM210Telas(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                  ³±±
±±³           ³ ExpN1 - Registro Atual ( Recno() )                        ³±±
±±³           ³ ExpN2 - Opcao de selecao do aRotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QMTA210                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QM210Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI    := 0
Local nCnt
Local nSavRec
Local lOpc := .F.
Local aUsrMat:= QA_USUARIO()
Local oSize
Local oEnch
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local aStruQMB := FWFormStruct(3, "QMB")[3]
Local nX

Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]
Private aHeader:= {}
Private aCols  := {}
Private nUsado := 0
Private oGetD
Private aButtons := {}
Private oArialGr	:= TFont():New("Arial",11,14,,.F.) 
Private oArial2		:= TFont():New("Arial",9,14,,.F.) 
Private aQNQMZ		:= {}
Private __lQNSX8 := .F.
Private aAliasQN := {}
Private cMatFil  := aUsrMat[2]

dbSelectArea("QMZ")
dbSetOrder(1)
If nOpc == 3
	For nI := 1 To FCount()
		cCampo := Eval( bCampo, nI )
		lInit  := .f.
		If ExistIni( cCampo )
			lInit := .t.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,'X3_RELACAO') )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,'X3_TAMANHO') )
			EndIf
			If M->&( cCampo ) == Nil
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&( cCampo ) := FieldGet( nI )
			If ValType( M->&( cCampo ) ) = "C"
				M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
			ElseIf ValType( M->&( cCampo ) ) = "N"
				M->&( cCampo ) := 0
			ElseIf ValType( M->&( cCampo ) ) = "D"
				M->&( cCampo ) := CtoD( "  /  /  " )
			ElseIf ValType( M->&( cCampo ) ) = "L"
				M->&( cCampo ) := .f.
			EndIf
		EndIf
	Next nI
	M->QMZ_FILIAL:= xFilial("QMZ")

	M->QMZ_COD := GETQNCNUM("QMZ" ,"QMZ_COD",,1,StrZero(Year(dDataBase),4),@aQNQMZ)

Else 
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI
EndIf


aHeader:= {}
nUsado := 0
aCpos := {}

For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		Aadd(aCpos,aStruAlias[nX,1])
	EndIf
Next nX

For nX := 1 To Len(aStruQMB)
	If cNivel >= GetSx3Cache(aStruQMB[nX,1], "X3_NIVEL") 
		nUsado++
		Aadd(aHeader, Q210GetSX3(aStruQMB[nX,1], "", "") )
	EndIf
Next nX                  

aCols := array(1,nUsado+1)
nUsado := 0

If nOpc == 3
	For nX := 1 To Len(aStruQMB)
		If cNivel >= GetSx3Cache(aStruQMB[nX,1], "X3_NIVEL")
			//			If Alltrim(SX3->X3_CAMPO) $ "QMB_ITEM|QMB_MATERI|QMB_CONTRA|QMB_FAIXA|QMB_PRECO|QMB_APROVS|QMB_TEXTO" 
			nUsado++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o array de 1 elemento vazio,no caso de Inclusao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If GetSx3Cache(aStruQMB[nX,1],"X3_TIPO") == "C"
				If Trim(aHeader[nUsado][2]) == "QMB_ITEM"
					aCols[1][nUsado] := StrZero(1,GetSx3Cache(aStruQMB[nX,1],"X3_TAMANHO"))
				Else
					aCols[1][nUsado] := SPACE(GetSx3Cache(aStruQMB[nX,1],"X3_TAMANHO"))
				EndIf
			ElseIf GetSx3Cache(aStruQMB[nX,1],"X3_TIPO") == "N"
				aCols[1][nUsado] := 0
			ElseIf GetSx3Cache(aStruQMB[nX,1],"X3_TIPO") == "D"
				If GetSx3Cache(aStruQMB[nX,1],"X3_PROPRI") != "U"
					aCols[1][nUsado] := dDataBase
				Else
					aCols[1][nUsado] := CTOD(SPACE(08))
				EndIf
			Elseif GetSx3Cache(aStruQMB[nX,1],"X3_TIPO") == "M"
				aCols[1][nUsado] := ""
			Else
				aCols[1][nUsado] := .F.
			Endif
			If GetSx3Cache(aStruQMB[nX,1],"X3_CONTEXT") == "V"
				aCols[1][nUsado] := CriaVar(AllTrim(aStruQMB[nX,1]))
			Endif
			//			Endif
		EndIf
	Next nX   
	
	aCols[1][nUsado+1] := .F.
Else
	aHeader := {}
	For nX := 1 To Len(aStruQMB)
		If cNivel >= GetSx3Cache(aStruQMB[nX,1], "X3_NIVEL") 
			nUsado++
			Aadd(aHeader, Q210GetSX3(aStruQMB[nX,1], "", "") )
		EndIf
	Next nX        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a ordem de calibracao posicionada                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMB")
dbSetOrder(1)
dbSeek(xFilial("QMB")+QMZ->QMZ_COD)
cCods := QMB->QMB_COD
nCnt := 0
nSavRec := RecNo()

dbSeek(xFilial("QMB")+cCods)

While !EOF() .And. QMB_FILIAL+QMB_COD == xFilial("QMB")+cCods
	nCnt++
	dbSkip()
EndDo

If nCnt == 0
	dbGoto(nSavRec)
	Return .T.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMB")
dbSeek(xFilial("QMB")+cCods)

aCOLS := array(nCnt,nUsado+1)

nCnt   :=0
nUsado :=0
While !EOF() .And. 	QMB_FILIAL+QMB_COD == xFilial("QMB")+cCods       
	nCnt++
	nUsado:=0
	For nX := 1 To Len(aStruQMB)
		If cNivel >= GetSx3Cache(aStruQMB[nX,1], "X3_NIVEL") 
			//			If Alltrim(SX3->X3_CAMPO) $ "QMB_ITEM|QMB_MATERI|QMB_CONTRA|QMB_FAIXA|QMB_PRECO|QMB_APROVS|QMB_TEXTO"
			nUsado++
			If GetSx3Cache(aStruQMB[nX,1], "X3_CONTEXT") # "V"
				cCampAux := "QMB->"+ aStruQMB[nX,1]
				aCols[nCnt][nUsado] := &cCampAux
			ElseIf GetSx3Cache(aStruQMB[nX,1], "X3_CONTEXT") == "V"
				aCols[nCnt][nUsado] := 	MSMM(QMB->QMB_CHAVE,80)//MSMM(QMB->QMB_CHAVE,,,,3,,,"QMB","QMB_CHAVE")
			Endif
			//			EndIf
		EndIf
	Next nX                  
	aCOLS[nCnt][nUsado+1] := .F.
	dbSelectArea("QMB")
	dbSkip( )
End

Endif

aSort(aCols,,,{|x,y| x[1] < y[1]}) //Sorte do menor item

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE" ,  100, 40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FOLDER"   ,  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE "Cadastro Ordem de Serviços" ;  //"Cadastro Ordem de Serviços"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .or. nOpc == 4
	oEnch:=MsMGet():New( "QMZ", nReg, nOpc,,,,aCpos,;
		 {oSize:GetDimension("ENCHOICE","LININI"),;
		 oSize:GetDimension("ENCHOICE","COLINI"),;
		 oSize:GetDimension("ENCHOICE","LINEND"),;
		 oSize:GetDimension("ENCHOICE","COLEND")};
		,,,,,,oDlg)	
Else	
	oEnch:=MsMGet():New( "QMZ", nReg, nOpc,,,,,;
		 {oSize:GetDimension("ENCHOICE","LININI"),;
		 oSize:GetDimension("ENCHOICE","COLINI"),;
		 oSize:GetDimension("ENCHOICE","LINEND"),;
		 oSize:GetDimension("ENCHOICE","COLEND")};
		,,3,,,,oDlg,,.T.)
Endif	

oFolder := TFolder():New(oSize:GetDimension("FOLDER","LININI"),oSize:GetDimension("FOLDER","COLINI"),;
	   					{STR0007},,oDlg,,,,.T.,,;
    					 oSize:GetDimension("FOLDER","XSIZE") ,oSize:GetDimension("FOLDER","YSIZE")+3 )	

If Altera //Forca nOpc 3 para correta manutencao do MSMM
	lOpc := .T.
	nOpc := 3
Else
	lOpc := .F.
Endif	

oGetD:=MsGetDados():New(4.2,.2,84,310,nOpc,,,"+QMB_ITEM",.T.,,,,,,,,,oFolder:aDialogs[1]) 
oGetD:oBrowse:bDrawSelect := {||QM210VlLin(oGetD,oFolder:aDialogs[1])}
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aButtons,{"NOTE"  ,{|| QM210Resumo(oDlg)}, STR0008}) //"Resumo"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .and. QM210TstLj(nOpc) .and. QM210Acols(nOpc,lOpc),oDlg:End(),.f.)},;
											    {|| RollBackQE(aQNQMZ),oDlg:End()},,aButtons)  CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM210SomItºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela somatoria de itens                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA210	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM210SomIt()

If n <> 1
	cSoma := SomaIt(aCols[n-1][1])
Else
	cSoma := "01"	
Endif	
aCols[n][1] := cSoma
oGetD:ForceRefresh()
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM210AcolsºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela gravacao dos dados                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA210                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Gravacao dos dados
Function QM210Acols(nOpc,lOpc)
Local lRet	:= .T.
Local i		:= 1
Local cItem	:= ""
Local nItem := 0
Local nCpos := 1
Local nx	:= 1
If lOpc //Volto o nopc para gravar alteracao
	nOpc := 4
Endif

//Verifica se existe algum campo no aCols vazio, exceto o campo Observacoes (QMB_TEXTO)
If nOpc == 3 .Or. nOpc == 4
	For nCpos := 1 To Len(aHeader)
		If !aCols[I,nUsado+1] .And. Alltrim(aHeader[nCpos,2])<> "QMB_TEXTO"
			If Empty(aCols[I,nCPOS])
				MsgAlert(OemToAnsi(STR0021) + CHR(13) + CHR(10) + Upper(Alltrim(aHeader[nCpos,1])) ,OemToAnsi(STR0018))					
				lRet := .F.
				Exit
			Else
				lRet := .T.
			EndIf      
		Endif
	Next nCpos                 
Endif
If lRet 
	If nOpc == 3
		Begin Transaction 
		dbSelectArea("QMZ")
		
		RecLock("QMZ",.T.)
   
		For i := 1 TO FCount()
			If "FILIAL" $ Field(i)
				FieldPut(i,xFilial("QMZ"))
			Else
				FieldPut(i,M->&(EVAL(bCampo,i)))
			EndIf
		Next i      

		Replace QMZ->QMZ_NTFISC With M->QMZ_NTFISC
		Replace QMZ->QMZ_DTPREV With M->QMZ_DTPREV
		Replace QMZ->QMZ_DTSAID With M->QMZ_DTSAID
		Replace QMZ->QMZ_TPSERV With M->QMZ_TPSERV
		Replace QMZ->QMZ_VENDED With M->QMZ_VENDED
		Replace QMZ->QMZ_APROVS With M->QMZ_APROVS                                                  
		Replace QMZ->QMZ_FREQUE With M->QMZ_FREQUE
		Replace QMZ->QMZ_RESP With M->QMZ_RESP
		Replace QMZ->QMZ_FILRES With M->QMZ_FILRES
		Replace QMZ->QMZ_TIPO With M->QMZ_TIPO
		Replace QMZ->QMZ_LOCAL With M->QMZ_LOCAL
		Replace QMZ->QMZ_LABORA With M->QMZ_LABORA
		Replace QMZ->QMZ_FILVEN With M->QMZ_FILVEN	

		MSMM(QMZ_CTEXTO,,,M->QMZ_TEXTO,1,,,"QMZ","QMZ_CTEXTO")

		MsUnLock()
		FKCOMMIT()
		
		dbSelectArea("QMB")
		For i := 1 to Len(aCols)
			If !aCols[i][Len(aCols[i])] //Se naum estiver deletado
				nItem++
				RecLock("QMB",.T.)
				For nCpos := 1 To Len(aHeader)
					If aHeader[nCpos, 10] <> "V"
						If Alltrim(aHeader[nCpos,2]) == "QMB_ITEM"
							If nItem <= 9
								cItem := "0"+Alltrim(Str(nItem))
							Else
							    cItem := Alltrim(Str(nItem))
							Endif	
							Replace QMB_ITEM   With cItem
						Else 
							QMB->(FieldPut(FieldPos(Trim(aHeader[nCpos,2])),aCols[i,nCpos]))
						Endif
					EndIf
				Next nCpos

				Replace QMB_FILIAL With xFilial("QMB")
				Replace QMB_COD	   With QMZ->QMZ_COD	

				If !Empty(aCols[i][7]) .Or. nOpc == 3
					MSMM(QMB_CHAVE,,,aCols[i][8],1,,,"QMB","QMB_CHAVE")
				Endif
												
				MsUnLock()
				FKCOMMIT()
			Endif
		Next i
	    End Transaction

		If __lQNSX8
			ConfirmeQE(aQNQMZ)
		EndIf

	ElseIf nOpc == 4
		Begin Transaction 
		RecLock("QMZ",.F.)
   
		For i := 1 TO FCount()
			If "FILIAL" $ Field(i)
				FieldPut(i,xFilial("QMZ"))
			Else
				FieldPut(i,M->&(EVAL(bCampo,i)))
			EndIf
		Next i      

		MSMM(QMZ_CTEXTO,,,M->QMZ_TEXTO,1,,,"QMZ","QMZ_CTEXTO")

		MsUnLock()
		FKCOMMIT()
		
		For i := 1 to Len(aCols)
			If !aCols[i][Len(aCols[i])] //Se naum estiver deletado
				nItem++
				dbSelectArea("QMB")
				dbSetOrder(1)
				If dbSeek(xFilial("QMB")+QMZ->QMZ_COD+aCols[i][1])
					RecLock("QMB",.F.)
				Else
					RecLock("QMB",.T.)				
				Endif

				For nCpos := 1 To Len(aHeader)
					If aHeader[nCpos, 10] <> "V"
						If Alltrim(aHeader[nCpos,2]) == "QMB_ITEM"
							If nItem <= 9
								cItem := "0"+Alltrim(Str(nItem))
							Else
							    cItem := Alltrim(Str(nItem))
							Endif	
							Replace QMB_ITEM   With cItem
						Else 
							QMB->(FieldPut(FieldPos(Trim(aHeader[nCpos,2])),aCols[i,nCpos]))
						Endif
					EndIf
				Next nCpos

				Replace QMB_FILIAL With xFilial("QMB")
				Replace QMB_COD	   With QMZ->QMZ_COD	
				
				If !Empty(aCols[i][8]) .Or. nOpc == 3
					MSMM(QMB_CHAVE,,,aCols[i][8],1,,,"QMB","QMB_CHAVE")
				Endif
												
				MsUnLock()
				FKCOMMIT()
			Else
				dbSelectArea("QMB")
				dbSetOrder(1)
				If dbSeek(xFilial("QMB")+QMZ->QMZ_COD+aCols[i][1])

					RecLock("QMB",.F.)

					MSMM(QMB_CHAVE,,,,2)
					dbDelete()	
					MsUnLock()
					FKCOMMIT()
				Endif	
			Endif
		Next i
	    End Transaction
	ElseIf nOpc == 5 //Delecao
		Begin Transaction 
		dbSelectArea("QMZ")
		dbSetOrder(1)
		If dbSeek(xFilial()+M->QMZ_COD)
			dbSelectArea("QMB")
			dbSetOrder(1)
			If dbSeek(xFilial("QMB")+QMZ->QMZ_COD)
				While QMB->(!Eof()) .and. QMB->QMB_FILIAL+QMB->QMB_COD == xFilial("QMB")+QMZ->QMZ_COD
    				RecLock("QMB",.F.)
					MSMM(QMB_CHAVE,,,,2)
                    dbDelete()
    				MsUnLock()
					FKCOMMIT()
					dbSkip()
				Enddo
			Endif

			//Delata numero de ordem de servico com possibilidade de recuperacao do mesmo...
			GETQNCSEQ("QMZ","QMZ_COD",QMZ->QMZ_COD,.T.,nOpc)

			dbSelectArea("QMZ")
			MSMM(QMZ_CTEXTO,,,,2)

			RecLock("QMZ",.f.)
			dbDelete()
			MsUnLock()
			FKCOMMIT()
		Endif
	    End Transaction
	Endif	     
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QM210VlLin³ Autor ³ Denis Martins  		³ Data ³ 25/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se incluiu mais de uma vez linha em branco no acols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Handle do Objeto getdados 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA210   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM210VlLin(oGetDad,oFldFix)

Local lRet		:= .T.
Local nI 		:= 1
Local nVezes	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aCols)
	If Empty(aCols[nI,2])
		nVezes++
	EndIf
Next nI
If nVezes > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGetDad:oBrowse:Refresh()
EndIf
If n <> Len(aCols) .And. Empty(aCols[Len(aCols),1])
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	oGetDad:oBrowse:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA210   ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela montagem dos resumos                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA210                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Resumo de tudo
Function QM210Resumo(oDlg)
Local oDlgRes
Local nTotItem  := 0
Local nPrecoTot :=0
Local nx := 1
Local oGrpS
Local cCodServ := ""

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->QMZ_CLIENT+M->QMZ_LOJA)
cCodServ := M->QMZ_CLIENT+" - "+SA1->A1_NREDUZ

DEFINE MSDIALOG oDlgRes TITLE STR0008 FROM 000,000 TO 300,450 OF oMainWnd PIXEL // Resumo
@ 4,44 SAY STR0009	SIZE 155,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_HRED //"Resumo dos Servicos"
@ 13,2	Group oGrpS TO 135,225 LABEL STR0006 OF oDlgRes PIXEL  //"Ordem de Servico"
@ 25,15 SAY STR0013	SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_BLUE	//"OS...........: "
@ 43,15 SAY STR0014 SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_BLUE	//"Cliente......: "
@ 61,15 SAY STR0010	SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_BLUE
@ 79,15 SAY STR0011	SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_BLUE
@ 97,15 SAY STR0015 SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr COLOR CLR_BLUE	//"Servico......: "

For nx := 1 to Len(aCols)
	If !aCols[nx][Len(aCols[nx])]
		nTotItem++
		nPrecoTot+=aCols[nx][6]
	Endif
Next nx
nPrecoTot := Round(nPrecoTot,2)

@ 25,81 SAY M->QMZ_COD SIZE 78,8 OF oDlgRes PIXEL FONT oArial2		//Ordem de Servico
@ 43,81 SAY cCodServ SIZE 170,8 OF oDlgRes PIXEL FONT oArial2		//Cliente + Nome
@ 61,81 SAY nTotItem	 SIZE 78,8 OF oDlgRes PIXEL FONT oArial2	//Total de Itens
@ 79,81 SAY nPrecoTot	 SIZE 78,8 OF oDlgRes PIXEL FONT oArial2 PICTURE "@E 999,999,999.99" //Preco Total

If M->QMZ_TIPO == "1" //Tipo de servico interno
	@ 97,81 SAY STR0016 SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr  //Interno
Else
	@ 97,81 SAY STR0017 SIZE 80,8 OF oDlgRes PIXEL FONT oArialGr  //Externo
Endif

DEFINE SBUTTON FROM 137,183 TYPE 1 ENABLE OF oDlgRes Action (oDlgRes:End()) PIXEL

ACTIVATE MSDIALOG oDlgRes Centered
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QM210TstLj³ Autor ³ Adalberto Mendes Neto ³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a loja digitada existe para o cliente digitado. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Tipo de Operacao          						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA210   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM210TstLj(nOpc)
Local cLjClie := M->QMZ_LOJA
Local lRet := .T.

If nOpc == 3 .or. nOpc == 4
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	If !Empty(M->QMZ_LOJA) 
		If dbSeek(xFilial("SA1")+M->QMZ_CLIENT+M->QMZ_LOJA)
			cLjClie := SA1->A1_LOJA 
			M->QMZ_LOJA := cLjClie     
		Else
			lRet := .F.
				MsgAlert(OemToAnsi(STR0020),OemToAnsi(STR0018))
		Endif	                
	Else   
		lRet := .F.
		MsgAlert(OemToAnsi(STR0019),OemToAnsi(STR0018))
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QM210VldLj³ Autor ³ Adalberto Mendes Neto ³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida loja digitada ou busca primeira loja cadastrada.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 - cLjClie    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA210   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM210VldLj()
Local cLjClie := CriaVar("A1_LOJA",.F.)
lRet := .T.
dbSelectArea("SA1")
dbSetOrder(1)

If !Empty(M->QMZ_CLIENT)
	If !Empty(M->QMZ_LOJA) 
		If dbSeek(xFilial("SA1")+M->QMZ_CLIENT+M->QMZ_LOJA)
			cLjClie := SA1->A1_LOJA 
			M->QMZ_LOJA := cLjClie     
		Else
			lRet := .F.
			MsgAlert(OemToAnsi(STR0020),OemToAnsi(STR0018))
		Endif	                
	Else   
		lRet := .F.
		MsgAlert(OemToAnsi(STR0019),OemToAnsi(STR0018))
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QM210VldTp³ Autor ³ Alexandre Gimenez ³  Data ³ 24/05/13 ³    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³Limpa campo Laboratório ou Departamento dependendo do Tipo OS³±±
±±³			  ³chamada via X3_VALID.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cTipo = QMZ_TIPO                     						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ TRUE                     										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA210   									           			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QM210VldTp(cTipo) // Tipo 1 Destino Interno
If cTipo == "1"
   M-> QMZ_LABORA := CriaVar("QMZ_LABORA",.F.)
Else
   M-> QMZ_LOCAL := CriaVar("QMZ_LOCAL",.F.)
Endif
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} Q210GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 16/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q210GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
				GetSx3Cache(cCampo,'X3_CAMPO'),;
				GetSx3Cache(cCampo,'X3_PICTURE'),;
				GetSx3Cache(cCampo,'X3_TAMANHO'),;
				GetSx3Cache(cCampo,'X3_DECIMAL'),;
				GetSx3Cache(cCampo,'X3_VALID'),;
				GetSx3Cache(cCampo,'X3_USADO'),;
				GetSx3Cache(cCampo,'X3_TIPO'),;
				GetSx3Cache(cCampo,'X3_F3'),;
				GetSx3Cache(cCampo,'X3_CONTEXT') } 
Return aHeaderTmp