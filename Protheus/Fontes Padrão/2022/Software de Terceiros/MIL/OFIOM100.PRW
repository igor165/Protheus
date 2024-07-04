#INCLUDE "OFIOM100.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OFIOM100   ³ Autor ³ Valdir F. Silva      ³ Data ³ 07/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fechamento de Orcamento                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Concessionarias (SIGAOFI)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM100(cNumOrc,nOpcExec)
Local aCores := {{"!Empty(VS1->VS1_NUMOSV) .and. VS1->VS1_VPERDI # '1'","DISABLE"},; //Orcamento Fechado
						{"Empty(VS1->VS1_NUMOSV) .and. VS1->VS1_VPERDI # '1'","ENABLE"},;  // Orcamento Aberto
						{"VS1->VS1_VPERDI == '1'","BR_PRETO"}}   									  // Venda Perdida
Local aArea := {}
Local lRetOM100 := .t.

Private cCadastro := STR0001 //Fechamento de Orcamentos
Private aRotina := MenuDef()

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO1")
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")
aArea := sGetArea(aArea , "VV1")
aArea := sGetArea(aArea , "VO5")
aArea := sGetArea(aArea , "VV2")
aArea := sGetArea(aArea , "VVC")
aArea := sGetArea(aArea , "SA1")
aArea := sGetArea(aArea , "VE1")
                         
If cNumOrc # NIL                         

	If nOpcExec == NIL
		nOpcExec := 3             
   EndIf

	DbSelectArea("VS1")
	DbSetOrder(1)
   If DbSeek( xFilial("VS1") + cNumOrc )

		If nOpcExec == 3
			lRetOM100 := OM100FEC("VS1",VS1->(Recno()),4)
      ElseIf nOpcExec == 4
			lRetOM100 := OM100PER("VS1",VS1->(Recno()),4)
		EndIf

	Else
		Help(" ",1,"RECNO")
	EndIf
	                
Else
	
	dbSelectArea("VS1")
	dbSetOrder(5)    
	mBrowse( 6, 1,22,75,"VS1",,,,,,aCores,'OM100Top()','OM100Bot()')
	
EndIf

sRestArea(aArea)

Return(lRetOM100)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM100FEC   ³ Autor ³ Valdir F. Silva      ³ Data ³ 07/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Afetua a gravacao da aprovacao do orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM100FEC(cAlias,nReg,nOpc)
Private cNumOrd := ""
If VS1->VS1_VPERDI == "1"
	Help(" ",1,"OFIOM100NI")
	Return .F.
EndIf

If !Empty(VS1->VS1_NUMOSV)
	Help(" ",1,"OFIOM100FE",,STR0011+Chr(13)+Chr(13)+STR0012+VS1->VS1_NUMOSV,4,1)
	Return .F.
EndIf                 

If !FS_ULTKIL(VS1->VS1_CHAINT)
	Return .F.
EndIf        

	If ( Empty(VS1->VS1_APOLIC) .Or. Empty(VS1->VS1_SINIST) .Or. Empty(VS1->VS1_NROAPR) )
		
		DbSelectArea("VOI")
		DbSetOrder(1)
	   DbSeek( xFilial("VOI") + VS1->VS1_TIPTEM )

		If VOI->VOI_SEGURO == "1"	
			MsgStop(STR0022,STR0014) //Orcamento de seguro e obrigatorio informar o numero da apolice, sinistro e aprovacao! Impossivel importar para a OS. # Atencao!
			Return(.F.)
		EndIf
		
	EndIf

If MsgYesno(STR0007,STR0008) //Deseja abrir uma nova O.S###Atencao
	cNumOrd := OM100NOS(cAlias,nReg,2)
Else
	If !Pergunte("OFM100",.T.)
		Return .F.
	EndIf
	cNumOrd := MV_PAR01	
	If !FS_VLABERT(cNumOrd,VS1->VS1_TIPTEM)
		Return( .F. )
	EndIf
	VO1->(dbSetOrder(1))
	VO1->(dbSeek(xFilial("VO1")+cNumOrd))
	If Type("GrvNoOS_") # "U"
		GrvNoOS_ := cNumOrd
	EndIf
	cNumOrd := OM100NOS(cAlias,nReg,3)
EndIf

If Empty(cNumOrd)
	Return .F.
End
VO1->(dbSetOrder(1))
VO1->(dbSeek(xFilial("VO1")+cNumOrd))

If OM100GRV(cAlias,nReg)
	MsgInfo(STR0013,STR0014)
Else
	MsgAlert(STR0023 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0024 +" "+VO1->VO1_NUMOSV+" "+STR0025 ,STR0014) //Foi impossivel importar os itens para a OS. #Favor importar novamente para a OS # ja existente # Atencao
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM100PER   ³ Autor ³ Valdir F. Silva      ³ Data ³ 07/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o registro de venda perdida p/ os itens do orcamento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM100PER(cAlias,nReg,nOpc)
Local oDlg,nX
Local nOpca:=2
Local lGrava := .F.
Private aCols:={}
Private aHeader:={}
Private nUsado:=0

If VS1->VS1_VPERDI == "1"
	Help(" ",1,"OFIOM100NI")
	Return .F.
EndIf

If VS1->VS1_TIPORC # "2"
	Help(" ",1,"OFIOM100NI")
	Return .F.
EndIf

If !Empty(VS1->VS1_NUMOSV)
	Help(" ",1,"OFIOM100FE",,STR0011+Chr(13)+Chr(13)+STR0012+VS1->VS1_NUMOSV,4,1)
	Return .F.
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 to 35,80  of oMainWnd

RegToMemory("VS1",.F.)
EnChoice("VS1",nReg,2,,,,{"VS1_NUMORC","VS1_CLIFAT","VS1_LOJA","VS1_NCLIFT"},{015,001,050,317},,3,,,,oDlg,,.F.)

RegToMemory("VE6",.t.)
MontaHead()
MontaCols()

If Len(aCols) == 0
	Help(" ",1,"OFIOM100SP")
	Return .F.
Endif

oGetDados := MsGetDados():New(52,1,196,317,4,"AllwaysTrue()","AllwaysTrue()","",.F.,{"VE6_CODMOT"},,,Len(aCols),,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT(EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{|| nOpca:=2,oDlg:End()})) CENTERED
If nOpca == 1
	dbSelectArea("VS3")
	dbSetOrder(2)
	For nX := 1 to Len(aCols)
		If !Empty(aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_CODMOT"})])
			VS3->(dbSeek(xFilial("VS3")+VS1->VS1_NUMORC+aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_GRUITE"})]+aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_CODITE"})]))
			lGrava := .T.
			VE6->(RecLock("VE6",.T.))
			VE6->VE6_FILIAL := xFilial("VE6")
			VE6->VE6_INDREG := "1"
			VE6->VE6_DATREG := dDataBase
			VE6->VE6_HORREG := Substr(Time(),1,2)+Substr(Time(),4,2)
			VE6->VE6_CODUSU := __cUserId
			VE6->VE6_CODMAR := VS1->VS1_CODMAR
			VE6->VE6_GRUITE := aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_GRUITE"})]
			VE6->VE6_CODITE := aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_CODITE"})]
			VE6->VE6_QTDITE := aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_QTDITE"})]
			VE6->VE6_CODMOT := aCols[nX,aScan(aHeader,{|x|Trim(x[2])=="VE6_CODMOT"})]
			VE6->VE6_LOTECT := VS3->VS3_LOTECT
			VE6->VE6_NUMLOT := VS3->VS3_NUMLOT
			VE6->VE6_NUMSER := VS3->VS3_NUMSER
			VE6->VE6_NUMORC := VS1->VS1_NUMORC
			VE6->(MsUnlock())
			VS3->(RecLock("VS3",.F.))
			VS3->(DbDelete())
			VS3->(MsUnlock())
		EndIf
	Next
	If lGrava
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_VPERDI := "1"
		VS1->(MsUnlock())
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM100LEG   ³ Autor ³ Valdir F. Silva      ³ Data ³ 07/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM100LEG()
Local aLegenda := 	{{"DISABLE",STR0009},; 	//Orcamento Fechado
{"ENABLE",STR0010},; 								//Orcamento Aberto
{"BR_PRETO",STR0005}} 								//Venda Perdida
BrwLegenda(cCadastro,STR0006 ,aLegenda) 		//Legenda
Return .T.

// Funcao para o top do filtro da mbrowse
Function OM100Top()
Return (xFilial("VS1")+"2")

// Funcao para o bottom do filtro da mbrowse
Function OM100Bot()
Return (xFilial("VS1")+"2")

Function OM100PESQ()
AxPesqui()
dbSelectArea("VS1")
dbSetOrder(5)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaHead³ Autor ³ Valdir F. Silva       ³ Data ³ 12/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Head                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaHead()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaHead()
Local cCampos := "VE6_GRUITE/VE6_CODITE/VE6_QTDITE/VE6_CODMOT/VE6_VALPEC/"
//Local npos:= 0

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VE6")

While !Eof() .And. (X3_ARQUIVO == "VE6")
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. X3_CAMPO $ cCampos
		nUsado:=nUsado+1
		AADD(aHeader,{ Trim(X3Titulo()), ;
		X3_CAMPO,;
		X3_PICTURE, ;
		X3_TAMANHO, ;
		X3_DECIMAL, ;
		"AllwaysTrue()" , ;
		X3_USADO,;
		X3_TIPO, ;
		X3_ARQUIVO,;
		X3_CONTEXT } )
	EndIF
	dbSkip()
Enddo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaCols³ Autor ³ Valdir F. Silva       ³ Data ³ 12/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Cols                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaCols()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOM100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols()
Local nX
Local cCodMot := CriaVar("VE6_CODMOT")
M->VE6_INDREG := "1"

dbSelectArea("VS3")
dbSetOrder(3)
dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
While !Eof() .and. xFilial("VS3")+VS3->VS3_NUMORC == VS3->VS3_FILIAL+VS1->VS1_NUMORC
	aadd(aCols,Array(nUsado+1))
	aCols[Len(aCols),aScan(aHeader,{|x|Trim(x[2])=="VE6_GRUITE"})] := VS3->VS3_GRUITE
	aCols[Len(aCols),aScan(aHeader,{|x|Trim(x[2])=="VE6_CODITE"})] := VS3->VS3_CODITE
	aCols[Len(aCols),aScan(aHeader,{|x|Trim(x[2])=="VE6_QTDITE"})] := VS3->VS3_QTDITE
	aCols[Len(aCols),aScan(aHeader,{|x|Trim(x[2])=="VE6_CODMOT"})] := cCodMot
	aCols[Len(aCols),aScan(aHeader,{|x|Trim(x[2])=="VE6_VALPEC"})] := VS3->VS3_VALPEC
	aCols[Len(aCols),nUsado+1]:=.F.
	VS3->(dbSkip())
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OM100NOS  ³Autor  ³Valdir F. Silva        ³Data  ³  13/03/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Incluir ordem de servico                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OM100NOS(cAlias,nReg,nOpc)

Private aCrrgVar := {}

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
DbSelectArea("VO5")
DbSetOrder(1)
DbSeek(xFilial("VO5")+VV1->VV1_CHAINT)
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
DbSelectArea("VVC")
DbSetOrder(1)
DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1")+VV1->VV1_CODMAR)

&& monta vetor para assumir na abertura de OS
If nOpc == 2
	Aadd( aCrrgVar, { "M->VO1_DESMAR", VE1->VE1_DESMAR } )
	Aadd( aCrrgVar, { "M->VO1_DESMOD", VV2->VV2_DESMOD } )
	Aadd( aCrrgVar, { "M->VO1_CHASSI", VV1->VV1_CHASSI } )
	Aadd( aCrrgVar, { "M->VO1_CODFRO", VV1->VV1_CODFRO } )
	Aadd( aCrrgVar, { "M->VO1_PLAVEI", VV1->VV1_PLAVEI } )
	Aadd( aCrrgVar, { "M->VO1_FABMOD", VV1->VV1_FABMOD } )
	Aadd( aCrrgVar, { "M->VO1_DESCOR", VVC->VVC_DESCRI } )
	Aadd( aCrrgVar, { "M->VO1_PROVEI", SA1->A1_COD 		 } )
	Aadd( aCrrgVar, { "M->VO1_LOJPRO", SA1->A1_LOJA 	 } )
	Aadd( aCrrgVar, { "M->VO1_NOMPRO", SA1->A1_NOME		 } )
	//Aadd( aCrrgVar, { "M->VO1_NOMFAT", SA1->A1_NOME		 } )
	Aadd( aCrrgVar, { "M->VO1_ENDPRO", SA1->A1_END		 } )
	Aadd( aCrrgVar, { "M->VO1_CIDPRO", SA1->A1_MUN		 } )
	Aadd( aCrrgVar, { "M->VO1_ESTPRO", SA1->A1_EST		 } )
	Aadd( aCrrgVar, { "M->VO1_FONPRO", SA1->A1_TEL		 } )
	Aadd( aCrrgVar, { "M->VO1_CODMAR", VE1->VE1_CODMAR } )
	//Aadd( aCrrgVar, { "M->VO1_GETKEY", VS1->VS1_CHAINT } )
	Aadd( aCrrgVar, { "M->VO1_GETKEY", VV1->VV1_CHASSI } )
	Aadd( aCrrgVar, { "M->VO1_CHASSI", VV1->VV1_CHASSI } )
	Aadd( aCrrgVar, { "M->VO1_CHAINT", VV1->VV1_CHAINT } )
	Aadd( aCrrgVar, { "M->VO1_PLAVEI", VV1->VV1_PLAVEI } )
	Aadd( aCrrgVar, { "M->VO1_CODFRO", VV1->VV1_CODFRO } )
	Aadd( aCrrgVar, { "M->VO1_KILOME", VS1->VS1_KILOME } )
	Aadd( aCrrgVar, { "M->VO1_OBSERV", If(Type("M->VS1_OBSERV")#"U",M->VS1_OBSERV,CriaVar("VS1_OBSERV")) } )
	
		Aadd( aCrrgVar, { "M->VO1_APOLIC", VS1->VS1_APOLIC } )
		Aadd( aCrrgVar, { "M->VO1_SINIST", VS1->VS1_SINIST } )
		Aadd( aCrrgVar, { "M->VO1_NROAPR", VS1->VS1_NROAPR } )
		Aadd( aCrrgVar, { "M->VO1_FRANQU", VS1->VS1_FRANQU } )
EndIf

If !OFIOM010(,nOpc,VS1->VS1_NUMORC,.F.)
	Return("")
EndIf

cNumOrd := VO1->VO1_NUMOSV

Return( cNumOrd )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OM100GRV  ³Autor  ³Valdir F. Silva        ³Data  ³  15/03/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Grava a importacao													     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OM100GRV(cAlias,nReg)

Local nImp := 0

Private aOsAbert := {} , aSrv := {} , aPeca := {} , lMovto := ( GetNewPar("MV_RITEORC","N") == "S" )
Private lMsErroAuto := .F.,  aImpFatPar := {}
Private aSeguros := {}

DbSelectArea("VOI")
DbSetOrder(1)
DbSeek( xFilial("VOI") + VS1->VS1_TIPTEM )

//Servicos
DbSelectArea("VS4")
DbSetOrder(1)
DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
Do While !Eof() .And. VS4->VS4_FILIAL == xFilial("VS4") .And. VS4->VS4_NUMORC == VS1->VS1_NUMORC
   
   DbSelectArea("VO6")
   DbSetOrder(2)
   DbSeek( xFilial("VO6") + FG_MARSRV(VS1->VS1_CODMAR, VS4->VS4_CODSER ) + VS4->VS4_CODSER )
   
   DbSelectArea("VO2")
   DbSetOrder(1)
   DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "S" )
   
   DbSelectArea("VO4")
//   DbSetOrder(1)
//   If !DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM + VS1->VS1_TIPTEM + VS4->VS4_CODSER )
   DbSetOrder(4)
   If !DbSeek( xFilial("VO4") + VS4->VS4_CODSER + VO2->VO2_NOSNUM )

		If FS_CHKVSM( VS1->VS1_NUMORC,,, VS4->VS4_CODSER)

		   Aadd( aSrv , { .T. , VS1->VS1_TIPTEM , VS1->VS1_CLIFAT , VS1->VS1_LOJA , SA1->A1_NOME , VS4->VS4_GRUSER , VS4->VS4_CODSER , VO6->VO6_DESSER , VS4->VS4_TIPSER , VS4->VS4_TEMPAD , VS4->VS4_KILROD , VS4->VS4_VALTOT } )

	   EndIf

   EndIf

	&& Tipo de tempo de seguro
	If VOI->VOI_SEGURO == "1"

	   DbSelectArea("VO4")
//	   DbSetOrder(1)
//	   If !DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM + VOI->VOI_TIPFRA + VS4->VS4_CODSER )
	   DbSetOrder(4)
	   If !DbSeek( xFilial("VO4") + VS4->VS4_CODSER + VO2->VO2_NOSNUM )
	
			If Len(aSeguros) == 0 .Or. Ascan( aSeguros , { |x| x[1] == VOI->VOI_TIPTEM } ) == 0
			
				Aadd( aSeguros , { VOI->VOI_TIPTEM , VOI->VOI_TIPFRA , .t. } )

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + VOI->VOI_TIPFRA )
            
				If FS_CHKVSM( VS1->VS1_NUMORC,,, VOI->VOI_CODSER)
	
				   Aadd( aSrv , { .T. , VOI->VOI_TIPTEM , VS1->VS1_CLIFAT , VS1->VS1_LOJA , SA1->A1_NOME , VOI->VOI_GRUSER , VOI->VOI_CODSER , VO6->VO6_DESSER , VOI->VOI_TIPSER , 0 , 0 , 0 } )
	
					aImpFatPar := {"","",""}
					If !FG_TIPTPFAT(VOI->VOI_TIPTEM,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",VS1->VS1_CODMAR,,,,.t.)
						Return(.f.)    
					EndIf
					aSrv[Len(aSrv),3] := aImpFatPar[1]
					aSrv[Len(aSrv),4] := aImpFatPar[2]
					aSrv[Len(aSrv),5] := aImpFatPar[3]   
	
						aSrv[Len(aSrv),12] := VS1->VS1_FRANQU

			   EndIf

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + VS1->VS1_TIPTEM )
			   
		   EndIf
		   
	   EndIf
   EndIf
   
   DbSelectArea("VS4")
   DbSkip()                                     
   
EndDo

// Pecas
DbSelectArea("VS3")
DbSetOrder(1)
DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
Do While !Eof() .And. VS3->VS3_FILIAL == xFilial("VS3") .And. VS3->VS3_NUMORC == VS1->VS1_NUMORC
   DbSelectArea("SB1")
   DbSetOrder(7)
   DbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE )

   DbSelectArea("VSJ")
   DbSetOrder(1)
   If ( !DbSeek( xFilial("VSJ") + VO1->VO1_NUMOSV + VS3->VS3_GRUITE + VS3->VS3_CODITE ) .Or. VS1->VS1_NUMORC # VSJ->VSJ_NUMORC )

		If FS_CHKVSM( VS1->VS1_NUMORC, VS3->VS3_GRUITE, VS3->VS3_CODITE )

		   Aadd( aPeca , { .T. , VS1->VS1_TIPTEM , VS1->VS1_CLIFAT , VS1->VS1_LOJA , SA1->A1_NOME , VS3->VS3_GRUITE , VS3->VS3_CODITE , SB1->B1_DESC , VS3->VS3_QTDITE , VS3->VS3_FORMUL , FG_VALPEC(VS1->VS1_TIPTEM,"VS3->VS3_FORMUL",VS3->VS3_GRUITE,VS3->VS3_CODITE,,.f.,.t. ) , .t. } )

		EndIf
		
	EndIf

   DbSelectArea("VS3")
   DbSkip()   
EndDo                
         
If ( Len(aSrv) == 0 .And. Len(aPeca) == 0 )
//	MsgStop("As pecas e servicos ja foram importados ou sao inexistentes!","Atencao!!!")
	Return(.f.)
EndIf

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )

DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") +  VV1->VV1_PROATU + VV1->VV1_LJPATU )

aImpFatPar := {"","",""}
If !FG_TIPTPFAT(VS1->VS1_TIPTEM,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",VS1->VS1_CODMAR,,,,.t.)
	Return(.f.)    
EndIf

If !Empty(aImpFatPar[1])

	For nImp := 1 To Len(aSrv)
		aSrv[nImp,3] := aImpFatPar[1]
		aSrv[nImp,4] := aImpFatPar[2]
		aSrv[nImp,5] := aImpFatPar[3]
	Next	        

	For nImp := 1 To Len(aPeca)
		aPeca[nImp,3] := aImpFatPar[1]
		aPeca[nImp,4] := aImpFatPar[2]
		aPeca[nImp,5] := aImpFatPar[3]
	Next	        

EndIf

Aadd( aOsAbert , { .T. , VO1->VO1_NUMOSV , VV1->VV1_CHASSI , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_DESMOD , VV1->VV1_PROATU , VV1->VV1_LJPATU , SA1->A1_NOME , aClone(aSrv) , aClone(aPeca)})

If OM210IMP(cAlias,nReg,2) .and. !lMsErroAuto
	If FunName() == "OFIOM350"
		If VO1->(FieldPos("VO1_NUMORC")) > 0
			DbSelectArea("VO1")
			DbSelectArea(1)
			If DbSeek(xFilial("VO1")+cNumOrd) .and. Empty(VO1->VO1_NUMORC)
				RecLock("VO1",.F.)
					VO1->VO1_NUMORC := VS1->VS1_NUMORC
				MsUnLock()
			EndIf
		EndIf
		DbSelectArea("VS1")
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_VPERDI := "0"
		VS1->VS1_NUMOSV := cNumOrd
		VS1->(MsUnlock())
   EndIf
EndIf         

Return(!lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOM100  ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLABERT(cNumOrd,cTipTem)

Local aArea := {}

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")

&& Verifica se o tipo de tempo foi disponibilizado             
DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+cNumOrd )
Do While !Eof() .And. xFilial("VO2")==VO2->VO2_FILIAL .And. VO2->VO2_NUMOSV == cNumOrd 

	If VO2->VO2_TIPREQ == "P"
	
	   DbSelectArea("VO3")
	   DbSetOrder(1)
	   DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem)
	   If ( !Empty(VO3->VO3_DATDIS) .Or. !Empty(VO3->VO3_DATFEC) .Or. !Empty(VO3->VO3_DATCAN) )
	      
			If !Empty(VO3->VO3_DATCAN)      
				MsgStop(STR0015+Chr(13)+STR0016+cTipTem)
			EndIf
	
			If !Empty(VO3->VO3_DATDIS)      
				MsgStop(STR0017+Chr(13)+STR0016+cTipTem)		
			EndIf
			
			If !Empty(VO3->VO3_DATFEC)      
				MsgStop(STR0018+Chr(13)+STR0016+cTipTem)		
			EndIf
	
			sRestArea(aArea)
			
	      Return(.f.)      
	      
	   EndIf                           
	   
	Else 
	
	   DbSelectArea("VO4")
	   DbSetOrder(1)
	   DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem)
	   If ( !Empty(VO4->VO4_DATDIS) .Or. !Empty(VO4->VO4_DATFEC) .Or. !Empty(VO4->VO4_DATCAN) )
	      
			If !Empty(VO3->VO3_DATCAN)      
				MsgStop(STR0015+Chr(13)+STR0016+cTipTem)		
			EndIf
	
			If !Empty(VO3->VO3_DATDIS)      
				MsgStop(STR0017+Chr(13)+STR0016+cTipTem)		
			EndIf
			
			If !Empty(VO3->VO3_DATFEC)      
				MsgStop(STR0018+Chr(13)+STR0016+cTipTem)		
			EndIf

			sRestArea(aArea)
			
	      Return(.f.)      
	      
	   EndIf

	EndIf   

   DbSelectArea("VO2")
   DbSkip()
   
EndDo  

sRestArea(aArea)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_UltKil³ Autor ³  Emilton              ³ Data ³ 20/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Pesquisa Ultima Kilometragem e Ve Plano de Revisao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OFIM010.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ULTKIL(cChaInt)
                   
Local nUltKil := 0

nUltKil := FG_ULTKIL(cChaInt)

If !Empty(VS1->VS1_KILOME) .And. VS1->VS1_KILOME < nUltKil
   MSGSTOP(STR0019;
   		  +Chr(13)+Chr(13)+STR0020+Transform(VS1->VS1_KILOME,"@E 9,999,999,999");
   		  			 +Chr(13)+STR0021+Transform(nUltKil,"@E 9,999,999,999"))   && Kilometragem informada e MENOR que kilometragem ja existente !)
   Return .f.
   
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CHKVSM ºAutor  ³Fabio               º Data ³  08/29/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se exista peca ou servico no inconveniente         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CHKVSM(cNumOrc, cGruIte, cCodIte, cCodSer)
                                                            
Default cNumOrc := ""
Default cGruIte := "" 
Default cCodIte := ""
Default cCodSer := ""
           
If GetNewPar("MV_IPECSRV","N") == "S" .And. !Empty(cNumOrc)
           
	DbSelectArea("VSM")
	DbSetOrder(6)
	DbSeek( xFilial("VSM") + cNumOrc )
	Do While !Eof() .And. VSM->VSM_FILIAL+VSM->VSM_NUMORC == xFilial("VSM") + cNumOrc

		If !Empty(cGruIte) .And. !Empty(cCodIte)
			If VSM->VSM_GRUITE == cGruIte .And. VSM->VSM_CODITE == cCodIte
				Return(.F.)			
         EndIf
		ElseIf !Empty(cCodSer)
			If VSM->VSM_CODSER == cCodSer
				Return(.F.)			
         EndIf
      EndIf
	     
		DbSelectArea("VSM")
		DbSkip()
	
	EndDo

EndIf

Return(.T.)

Static Function MenuDef()
Local aRotina := {{		STR0002 ,"OM100PESQ", 0, 1},; 		//Pesquisar
							{	STR0003 ,"AxVisual" , 0, 2},; 		//Visualizar
							{	STR0004 ,"OM100FEC" , 0, 4},; 		//Aprovar
							{	STR0005 ,"OM100PER" , 0, 4},; 		//Venda Perdida
							{	STR0006 ,"OM100LEG" , 0, 2,0,.f.}} 	//Legenda
Return aRotina
