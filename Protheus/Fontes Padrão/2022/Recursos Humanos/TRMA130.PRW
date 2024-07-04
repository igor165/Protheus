#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMA130.CH" 

Static lTR130MNU := ExistBlock("TR130MNU")

/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TRMA130  ³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro dos Planejamentos dos Treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA130                                                      ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³21.07.14³TPZSOX³Incluido o fonte da 11 para a 12 e efetua-  ³±±
±±³            ³        ³        ³da a limpeza.                             ³±±
±±³Renan Borges³06.10.14³TQMZWL  ³Ajuste na contagem de funcionários que pos³±±
±±³            ³        ³        ³suem treinamentos, na geração do planeja- ³±±
±±³            ³        ³        ³mento.                                    ³±±   
±±³Renan Borges³04/11/15³TTOOF4  ³Ajuste na validação do campo valor do pla-³±±
±±³            ³        ³        ³nejamento, para que realize a validação   ³±±
±±³            ³        ³        ³igual ao campo valor do curso.            ³±±
±±³Matheus M.  ³16/11/15³TTQIG4  ³Ajuste para verificar se o campo RA8_HORAS³±±
±±³            ³        ³        ³não foi atualizado para o tamanho 15      ³±±
±±³            ³        ³        ³e se o valor de Horas de Treinamento é    ³±±   
±±³            ³        ³        ³superior ao percentual 9999.99            ³±±
±±³Paulo O     ³16/11/15³MRH-6837³Ajuste para limpar o Campo RA8_NOME       ³±±
±±³Inzonha     ³22/02/17³        ³quando o valor do campo RA8_MAT for limpo ³±±
±±³            ³        ³        ³porém esta preenchido para este registro  ³±±
±±³Oswaldo L   ³13-09-17³DRHPONTP³Gerar solicitante na SC1 caso todos itens ³±±
±±³            ³        ³-1280   ³do browse tenham mesma matricula          ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Function TRMA130()

LOCAL cFiltra		:= ""			//Variavel para filtro
LOCAL cFiltraRA8	:= ""			//Variavel para filtro

Private aIndexRA8	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemtoAnsi(STR0006)	//"Cadastro de Planejamento dos Treinamentos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltra 	:= CHKRH(FunName(),"RA8","1")
cFiltraRA8	:= "Val(RA8_SEQ) == 1"

If !Empty(cFiltra)
	cFiltraRA8 += ".And." + cFiltra
EndIf
bFiltraBrw 	:= {|| FilBrowse("RA8",@aIndexRA8,@cFiltraRA8) }
Eval(bFiltraBrw)

dbSelectArea("RA8")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA8")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA8",aIndexRA8,.T.)
  
dbSelectArea("RA8") 
dbSetOrder(1)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr130Rot  ³ Autor ³ Cristina Ogura       ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os planejamentos dos treinamentos			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA130     ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Rot(cAlias,nReg,nOpcx)
Local aSaveArea := GetArea()
Local oDlgMain
Local nOpca		:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local aColsRec	:= {}
Local aCursos	:= {}
Local nOrder 	:= IndexOrd()
Local nPosSeq	:= 0
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

// Private da Getdados
Private oGet
Private aCols   := {}
Private aHeader := {}
Private Continua:= .F.
Private cCod	:= CriaVar("RA8_PLANEJ")
Private cDesc	:= CriaVar("RA8_DESC  ")
Private cGrupo	:= ""
Private nOpcao  := nOpcx
Private cArqNtx := ""
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA8",aIndexRA8,.T.)
aIndexRA8 := {}
dbGoto(nReg)

If nOpcx # 3			// Diferente de Inclusao
	cCod	:= RA8->RA8_PLANEJ
	cDesc	:= RA8->RA8_DESC
Else
	cCod	:= GetSx8Num("RA8","RA8_PLANEJ")	
EndIf	

// Monta as getdados dos arquivos
aCursos:= Tr130Monta(cAlias,nReg,nOpcx)

aColsRec	:= aClone(aCursos[1])
aHeader		:= aClone(aCursos[2])
aCols	 	:= aClone(aCursos[3])

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize	:= MsAdvSize()

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 1 , 1 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 100 , .T. , .T. } )

aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

If (nPosSeq := aScan(aHeader,{|x| AllTrim(x[2])=="RA8_SEQ"}) ) > 0
// somente quando for inclusao, sequencia do dependente.
	If nOpcx == 3 
	    aCols[1][nPosSeq] := StrZero(1,TamSX3("RA8_SEQ")[1],0)
	EndIf
Endif

If GetRpoRelease() >= "R7"
	PcoIniLan("000377")
Endif

DEFINE MSDIALOG oDlgMain TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1,1],aObjSize[1,4]*0.02 SAY OemToAnsi(STR0007) of oDlgMain PIXEL	//"Cod. Planejamento: "
	@ aObjSize[1,1],aObjSize[1,4]*0.02+50 GET cCod		VALID Tr130Plan(cCod) WHEN (nOpcx==3) of oDlgMain PIXEL
	@ aObjSize[1,1],aObjSize[1,4]*0.02+75 GET cDesc	VALID !Empty(cDesc)	WHEN lTrDel  PICTURE "@!" of oDlgMain PIXEL	//-SIZE 150,7 
	
	oGet := MSGetDados():New(aObjSize[2][1], aObjSize[2][2], aObjSize[2][3], aObjSize[2][4],nOpcx,"Tr130Ok","AlwaysTrue","+RA8_SEQ",lTrDel,,1,,999,,,,"Tr130LinDel",oDlgMain)
		
ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,If(Tr130TudOk(nOpcx,.T.),oDlgMain:End(),.F.)},;
				{|| nOpca := 2,oDlgMain:End()},,;
				Iif(nOpcx == 3 .Or. nOpcx == 4,;
	   			( {{"sduprop",{||Tr130Par()},OeMToAnsi(STR0008),OemToAnsi(STR0020)},;		//"sduprop"###"Parametro"
				{"AUTOM",{||Tr130Ger(nOpcx)},OeMToAnsi(STR0009),OemToAnsi(STR0021)} }),)))	//"Gerar Autom."###"Gerar"

If nOpca == 1
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
		Begin Transaction
			If nOpcx == 3			// Inclusao
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf	
			Tr130Grava(cAlias,nReg,nOpcx,aCursos)
			EvalTrigger()
		End Transaction
	ElseIf nOpcx = 5
		Begin Transaction
			Tr130Dele(cAlias,nReg,nOpcx)
		End Transaction
	EndIf
Else
	If __lSX8
		RollBackSX8()
	EndIf		
EndIf

If GetRpoRelease() >= "R7"
	PcoFinLan("000377") 
	PcoFreeBlq("000377",,,,,.T./*lCancela*/)
Endif
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
dbGoTo(nReg)

RestArea(aSaveArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr130Monta³ Autor ³ Cristina Ogura       ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta as getdados dos arquivos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA130       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Monta(cAlias, nReg, nOpcx)
Local aFields 	:= {"RA8_FILIAL","RA8_PLANEJ","RA8_DESC  "}
Local aAuxCols	:= {}
Local aAuxHeader:= {}
Local aColsRec	:= {}   //--Array que contem o Recno() dos registros da aCols
Local cCond		:= ""
Local cChave	:= ""

cCond := "RA8_FILIAL + RA8_PLANEJ"

// Monta o Header		                                         
TrmHeader(@aAuxHeader,aFields,cAlias)
	
// Monta o aCols									                       
cChave := xFilial(cAlias)+cCod
TrmCols(@aAuxCols,aFields,nOpcx,@aColsRec,cAlias,cCond,cChave,aAuxHeader)

Return {aColsRec,aAuxHeader,aAuxCols}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Ok   ³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Ok()
Local nPosCurso	:= GdFieldPos("RA8_CURSO")
Local nPosNrFun	:= GdFieldPos("RA8_NFUNC")
Local nPosValor	:= GdFieldPos("RA8_VALOR") 
Local nPosData 	:= GdFieldPos("RA8_DATA") 
Local nPosNome 	:= GdFieldPos("RA8_NOME") 
Local nPosDe   	:= GdFieldPos("RA8_DATADE") 
Local nPosAte  	:= GdFieldPos("RA8_DATAAT") 
Local nPosGrupo	:= GdFieldPos("RA8_GRUPO") 
Local nPosDepto	:= GdFieldPos("RA8_DEPTO") 
Local nPosCC   	:= GdFieldPos("RA8_CC") 
Local nPosHoras	:= GdFieldPos("RA8_HORAS") 
Local nx		:= 0
Local cInte 	:= SuperGetMV("MV_PCOINTE",.T.,"2")

If nOpcao # 5 .And. nOpcao # 2

	If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
		If nPosCurso > 0 .And. Empty(aCols[n][nPosCurso])
			Help("",1,"TR130CAMPO")	  // Verifique os campos de curso
			Return .F.
		ElseIf nPosNrFun > 0 .And. Empty(aCols[n][nPosNrFun])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosData > 0 .And. Empty(aCols[n][nPosData])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosNome > 0 .And. Empty(aCols[n][nPosNome])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosDe > 0 .And. Empty(aCols[n][nPosDe])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosAte > 0 .And. Empty(aCols[n][nPosAte])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosHoras > 0 .And. Empty(aCols[n][nPosHoras])
			Help("",1,"TR130CAMPO")
			Return .F.
		ElseIf nPosCC > 0 .And. cInte == '1' .And. GetRpoRelease() >= "R7" .And. Empty(aCols[n][nPosCC])
			Help("",1,"TR130CAMPO")
			Return .F.
		EndIf

		If Len(AllTrim(Str(Len(aCols)))) > TamSx3("RA8_SEQ")[1] 
			Aviso(STR0006, STR0022, {"Ok"})	//"Atencao"###"Excedeu o numero máximo de linhas, elimine linhas ou peça para o Administrador do Sistema aumentar o tamanho do campo RA8_SEQ."
			Return .F.
		EndIf
			
		For nx:=1 To Len(aCols)
			If aCols[n][nPosCurso] == aCols[nx][nPosCurso] .And.;
			   aCols[n][nPosDe] == aCols[nx][nPosDe] .And.;
			   aCols[n][nPosAte] == aCols[nx][nPosAte] .And.;    
			   aCols[n][nPosGrupo] == aCols[nx][nPosGrupo] .And.;
			   aCols[n][nPosDepto] == aCols[nx][nPosDepto] .And.;
			   aCols[n][nPosCC] == aCols[nx][nPosCC] .And.;
				!aCols[nx][Len(aCols[nx])] .And.;
				n # nx 
				Help(" ",1,"TR130EXIST")		// Planejamento para este curso já existe
				Return .F.
				Exit
			EndIf	
		Next nx		

	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos lancamentos no SIGAPCO		     			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcao # 5 .And. cInte == '1' .And. GetRpoRelease() >= "R7" .And. !PcoBlqFim({{"000377","01"}})
		PcoVldLan("000377", "02", "TRMA130",,, .T. )
	Endif

EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Grava³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr130Grava(cAlias,nReg,nOpcx,aCursos)

Local nx		:= 0
Local ny		:= 0 
Local nItem		:= 0

dbSelectArea(cAlias)
dbSetOrder(1)

// apaga todos os registros para regravar com numeracao correta.
dbSeek(xFilial(cAlias)+cCod)
While !Eof() .And. xFilial(cAlias)+cCod == RA8->RA8_FILIAL+RA8->RA8_PLANEJ 
	RecLock(cAlias,.F.)
		dbDelete()		
	MsUnlock()
	dbSkip()	
End	
                
nItem := 0
For nx := 1 to Len(aCols)

	//--Verifica se Nao esta Deletado no aCols
	If !aCols[nx][Len(aCols[nx])]
		nItem++ 
		RecLock(cAlias,.T.)
			Replace RA8->RA8_FILIAL 	WITH xFilial(cAlias)
			Replace RA8->RA8_PLANEJ	 	WITH cCod
			Replace RA8->RA8_DESC		WITH cDesc
			Replace RA8_SEQ				WITH Strzero(nItem,TamSx3("RA8_SEQ")[1])

			For ny := 1 To Len(aHeader)
				If aHeader[ny][10] # "V"
					cCampo    := Trim(aHeader[ny][2])
					xConteudo := aCols[nx][ny] 
					If cCampo != "RA8_SEQ"
						Replace &cCampo With xConteudo
					EndIf	
				EndIf	
			Next ny
	
		MsUnlock()
	EndIf
Next nx

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Dele ³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes aos treinamentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRM130                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr130Dele(cAlias,nReg,nOpcx,lLinDel)
Local lChkDelOk := .F.

DEFAULT lLinDel := .F.
DEFAULT cAlias  := "RA8"

If (ChkDelRegs(cAlias         ,;	//Alias do Arquivo Principal
				 nReg           ,;	//Registro do Arquivo Principal
				 nOpcx          ,;	//Opcao para a AxDeleta
				 xFilial(cAlias),;	//Filial do Arquivo principal para Delecao
				 cCod           ,;	//Chave do Arquivo Principal para Delecao
				 NIL            ,;	//Array contendo informacoes dos arquivos a serem pesquisados
				 NIL            ,;	//Mensagem para MsgYesNo
				 NIL            ,;	//Titulo do Log de Delecao
				 NIL            ,;	//Mensagem para o corpo do Log
				 .F.            ,;	//Se executa AxDeleta
				 !lLinDel       ,;	//Se deve Mostrar o Log
				 NIL            ,;	//Array com o Log de Exclusao
				 NIL            ,;	//Array com o Titulo do Log
				 NIL            ,;	//Bloco para Posicionamento no Arquivo
				 NIL            ,;	//Bloco para a Condicao While
				 NIL            ,;	//Bloco para Skip/Loop no While
				 .T.            ,;	//Verifica os Relacionamentos no SX9
				 {'SQB'}        ,;	//Alias que nao deverao ser Verificados no SX9
				 NIL            ,;	//Se faz uma checagem soft
				 .F.             ;  //Se esta executando rotina automatica
	)			)
	If !lLinDel
		// Planejamento
		dbSelectArea(cAlias)
		dbSetOrder(1)
		If dbSeek(xFilial(cAlias)+cCod)
			While !Eof() .And. RA8->RA8_FILIAL + RA8->RA8_PLANEJ == xFilial(cAlias)+cCod						 
				RecLock(cAlias,.F.)
					dbDelete()			
				MsUnlock()
				dbSkip()
			EndDo
			lChkDelOk := .T.
		EndIf
	Else
		lChkDelOk := .T.
	EndIf		
EndIf

Return (lChkDelOk)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no Ok da enchoicebar                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr130TudOk(nExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130TudOk(nOpcx,lOk)
Local lRet 		:= .T.
Local nX		:= 1
Local nRA8_CC	:= aScan(aHeader,{|x| AllTrim(x[2])=="RA8_CC"})
Local nRA8_DATA := aScan(aHeader,{|x| AllTrim(x[2])=="RA8_DATA"})
Local cInte 	:= SuperGetMV("MV_PCOINTE",.T.,"2")
Local n_SaveLin := 0

If nOpcx == 2
	lRet := .T.
ElseIf Empty(cDesc)
	Help(" ",1,"TR130DESC")	
	lRet := .F.
EndIf	               
If lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos lancamentos no SIGAPCO		     			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. nOpcx != 2 .And. nOpcx != 5 .And. GetRpoRelease() >= "R7"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se validacao do bloqueio do pco e no final, ³
		//³em caso positivo valida todas as linhas              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. PcoBlqFim({{"000377","01"}}) 			
			n_SaveLin := n
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					If  ( Empty(aCols[nX,nRA8_CC]) .Or. Empty(aCols[nX,nRA8_DATA]) )
						Aviso(OemToAnsi(STR0023), OemToAnsi(STR0016), {"OK"},,OemToAnsi(STR0024)) //"Quando a Integração com o Módulo SIGAPCO está ativada, os Centros de Custo e Data Planejamento são obrigatorios!"#"Atencao"#"Descricao"
						lRet := .F.
					Endif
					If lRet
						n := nX
						PcoVldLan('000377','02','TRMA130',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					Endif
					If !lRet
						Exit
					EndIf
				EndIf
			Next
			n := n_SaveLin
		EndIf

	Endif

	If lRet
		Return Tr130Ok()
	Endif
	
EndIf
Return lRet
            
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Plan ³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica na inclusao se o planejamento exist                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr130Plan                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Plan(cCod)
Local aSaveArea := GetArea()
Local lRet		:= .T.

dbSelectArea("RA8")
dbSetOrder(1)
If dbSeek(xFilial("RA8")+cCod)
	Help(" ",1,"Tr130EXIST")
	lRet := .F.
EndIf

If lRet .And. !FreeForUse("RA8",cCod) 
	lRet := .F.
ElseIf Val(cCod) <= 0	
	AVISO(STR0016,STR0019,{"OK"})	//"Atencao","Codigo do Planejamento deve ser preeenchido corretamente ou Codigo do Planejamento nao pode estar em branco."
	lRet := .F.
EndIf
                   
RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Desc ³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que traz  a descricao dos campos conforme parametro  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr130Desc(nExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nQual == 1 - Curso                                          ³±±
±±³          ³nQual == 2 - Matricula                                      ³±±
±±³          ³nQual == 3 - Grupo                                          ³±±
±±³          ³nQual == 4 - Centro de Custo                                ³±±
±±³          ³nQual == 5 - Cargo				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TR130Desc(nQual, lSX3)
Local aSaveArea := GetArea()
Local cVar		:= ""         
Local cDesc		:= ""              
Local cRetorno	:= ""
Local lRet		:= .F.              
Local nPos 		:= 0
Local nPosGrupo	:= 0

Default lSX3	:= .F.
Default nQual	:= 1

If ( Type("oGet") == "U" )
	n := 1
EndIf

If nQual == 1			// Curso
	cRetorno := CriaVar("RA8_DESCCU", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_CURSO")
		nPosDesc := GdFieldPos("RA8_DESCCU") 
	EndIf
	cVar := If(lSX3, RA8->RA8_CURSO, &(ReadVar()))
	dbSelectArea("RA1")
	dbSetOrder(1)
	If dbSeek(xFilial("RA1")+cVar)
		cRetorno := RA1->RA1_DESC	
		lRet := .T.	
	EndIf

ElseIf nQual == 2		// Matricula
	cRetorno := CriaVar("RA8_NOME", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_MAT")
		nPosDesc := GdFieldPos("RA8_NOME") 
	EndIf
	cVar := If(lSX3, RA8->RA8_MAT, &(ReadVar()))
	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(xFilial("SRA")+cVar)
		cRetorno := SRA->RA_NOME	
		lRet := .T.	
	EndIf
	
ElseIf nQual == 3		// Grupo
	cRetorno := CriaVar("RA8_DESCGR", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_GRUPO")
		nPosDesc := GdFieldPos("RA8_DESCGR") 
	EndIf
	cVar := If(lSX3, RA8->RA8_GRUPO, &(ReadVar()))
	dbSelectArea("SQ0")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ0")+cVar)
		cRetorno := SQ0->Q0_DESCRIC	
		lRet := .T.	
	EndIf

	
ElseIf nQual == 4		// Centro de Custo
	cRetorno := CriaVar("RA8_DESCGR", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_CC")
		nPosDesc := GdFieldPos("RA8_DESCCC") 
	EndIf
	cVar := If(lSX3, RA8->RA8_CC, &(ReadVar()))
	dbSelectArea("CTT")
	dbSetOrder(1)
	If dbSeek(xFilial("CTT")+cVar)
		cRetorno := CTT->CTT_DESC01	
		lRet := .T.	
	EndIf
	
ElseIf nQual == 5		// Cargo
	cRetorno := CriaVar("RA8_DESCGR", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_CARGO")
		nPosDesc := GdFieldPos("RA8_DESCCA") 
	EndIf
	cVar := IF(lSX3, RA8->RA8_CARGO, &(ReadVar()))
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cVar)
		cRetorno := SQ3->Q3_DESCSUM	
		lRet := .T.	
	EndIf

ElseIf nQual == 6		// Departamento
	cRetorno := CriaVar("RA8_DESCDP", .F.)
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_DEPTO")
		nPosDesc := GdFieldPos("RA8_DESCDP") 
	EndIf
	cVar := IF(lSX3, RA8->RA8_DEPTO, &(ReadVar()))
	dbSelectArea("SQB")
	dbSetOrder(1)
	If dbSeek(xFilial("SQB")+cVar)
		cRetorno := SQB->QB_DESCRIC	
		lRet := .T.	
	EndIf
	
ElseIf nQual == 7		// Matricula Vazia
	If Type("aHeader") != "U"   //Consulta Padrao
		nPos	 := GdFieldPos("RA8_MAT")
		nPosDesc := GdFieldPos("RA8_NOME") 
	EndIf
	if !Empty(aCols[n,10])//verifica o valor atual do campo
		cRetorno := CriaVar("RA8_NOME", .F.)
		cRetorno := space(tamSX3("RA8_NOME")[1])//Limpa variavel com seu respectivo tamanho	
		lRet := .T.
	endIf

EndIf

//Reinicializa as variavais na inclusão de linhas
If Type("aHeader") != "U" .And. Len(aCols) > 0 .And. nPos > 0 .And. nPosDesc > 0 //Consulta Padrao
	If lSX3
		If Len(aCols) == 0 .Or. Empty(aCols[Len(aCols)][nPos])
		    If nQual == 1
				cRetorno := CriaVar("RA8_DESCCU", .F.)
			ElseIf nQual == 2
				cRetorno := CriaVar("RA8_NOME", .F.)			
			ElseIf nQual == 3
				cRetorno := CriaVar("RA8_DESCGR", .F.)		
			ElseIf nQual == 4
				cRetorno := CriaVar("RA8_DESCCC", .F.)
			ElseIf nQual == 5
				cRetorno := CriaVar("RA8_DESCCA", .F.)
			ElseIf nQual == 6
				cRetorno := CriaVar("RA8_DESCDP", .F.)
			EndIf
		EndIf
	Else
		aCols[n][nPosDesc] := cRetorno
	EndIf
EndIf		

RestArea(aSaveArea)

Return(IIf(lSX3, cRetorno, lRet))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130DEPTO³ Autor ³ Cristina Ogura        ³ Data ³ 18.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que traz  a descricao do departamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr130Depto(nExpl1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lSX3 = .T. - Se for X3_RELACAO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Depto(lSX3)                                  
Local aSaveArea := GetArea()
Local nPosDesc 	:= GdFieldPos("RA8_DESCDP")
Local cVar		:= ""
Local cAux		:= ""            
Local cRetorno	:= ""

If lSX3                    
	cVar   	:= RA8->RA8_DEPTO
Else
	cVar 	:= &(ReadVar())
EndIf

dbSelectArea("SQB")
dbSetOrder(1)
If dbSeek(xFilial("SQB")+cVar)
	If lSX3
		cRetorno := SQB->QB_DESCRIC
	Else
		cRetorno := .T.	
		aCols[n][nPosDesc] :=SQB->QB_DESCRIC	
	EndIf
Else
	If lSX3
		cRetorno := Space(20)
	Else
		Help("",1,"TR130Depto")			// Departamento nao existe.
		cRetorno := .F.	
	EndIf
EndIf	

RestArea(aSaveArea)

Return cRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr130Par  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 19/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros para Geracao do Planejamento.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA130     ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Par() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera as perguntas 				                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TRM130" ,.T.)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tr130Ger  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 19/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera planejamento Automatico dos treinamentos	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA130     ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130Ger(nOpcx)

Local aSaveArea := GetArea()
Local cFilDe
Local cFilAte
Local cMatDe
Local cMatAte
Local cCCDe
Local cCCAte
Local cSinDe
Local cSinAte
Local cCurDe
Local cCurAte
Local cGruDe
Local cGruAte
Local cDepDe
Local cDepAte
Local cCarDe
Local cCarAte 

Local dTr130de	:= CriaVar("RA8_DATADE")     
Local dTr130at	:= CriaVar("RA8_DATAAT")     
Local cMatResp	:= CriaVar("RA8_MAT")
Local cNomResp	:= CriaVar("RA8_NOME")

Local dDataRA4 	:= CtoD("")
Local nRecRA4 	:= 0

Local cAuxFil	:= ""
Local aPlanej	:= {}
Local nOpca		:= 0
Local nPos		:= 0 
Local cCargo	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TRM130" ,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ MV_PAR01				// Filial De                             ³
//³ MV_PAR02				// Filial Ate                            ³
//³ MV_PAR03				// Matr¡cula De                    		 ³
//³ MV_PAR04				// Matr¡cula At‚                   		 ³
//³ MV_PAR05				// Centro de Custo De                    ³
//³ MV_PAR06				// Centro de Custo Ate                   ³
//³ MV_PAR07				// Sindicato De                   		 ³
//³ MV_PAR08				// Sindicato Ate                     	 ³
//³ MV_PAR09				// Curso De             				 ³
//³ MV_PAR10				// Curso At‚                        	 ³
//³ MV_PAR11				// Grupo De          					 ³
//³ MV_PAR12				// Grupo At‚                        	 ³
//³ MV_PAR13				// Departamento De            			 ³
//³ MV_PAR14				// Departamento At‚                      ³
//³ MV_PAR15				// Cargo De         					 ³
//³ MV_PAR16				// Cargo At‚                           	 ³
//³ MV_PAR17				// Periodo De       					 ³
//³ MV_PAR18				// Periodo At‚                           ³
//³ MV_PAR19				// Matricula Respons.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilDe	:= MV_PAR01
cFilAte	:= MV_PAR02
cMatDe	:= MV_PAR03
cMatAte	:= MV_PAR04
cCCDe	:= MV_PAR05
cCCAte	:= MV_PAR06
cSinDe	:= MV_PAR07
cSinAte	:= MV_PAR08
cCurDe	:= MV_PAR09
cCurAte	:= MV_PAR10
cGruDe	:= MV_PAR11
cGruAte	:= MV_PAR12
cDepDe	:= MV_PAR13
cDepAte	:= MV_PAR14
cCarDe	:= MV_PAR15
cCarAte	:= MV_PAR16

DEFINE MSDIALOG oDlgMain FROM	8.5,0 TO 17.5,80 TITLE cCadastro OF oMainWnd

	@ 2.5,02 SAY OemToAnsi(STR0011)	//"Data inicial: "
	@ 2.5,08 MSGET dTr130de	VALID !Empty(dTr130de)
	
	@ 2.5,22 SAY OemToAnsi(STR0012)	//"Data final: "
	@ 2.5,26 MSGET dTr130at VALID !Empty(dTr130at) 
	
	@ 3.5,02 SAY OemToAnsi(STR0013)	//"Responsavel: "
	@ 3.5,08 MSGET cMatResp F3 "SRA" Valid (!Empty(cMatResp) .And. Tr130Resp(cMatResp,@cNomResp))  
	@ 3.5,13 MSGET cNomResp WHEN .F. SIZE 135,7
		
ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,If(Tr130TudOk(nOpcx,.F.),oDlgMain:End(),)},{|| nOpca := 2,oDlgMain:End()}))

If nOpca == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivo de Funcionarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRA")
	dbSetOrder(1)
	cAuxFil := xFilial("SRA",If(!Empty(cFilDe),cFilDe,SRA->RA_FILIAL))
	dbSeek(cAuxFil+cMatDe,.T.)
	While !Eof() .And. SRA->RA_MAT >= cMatDe .And. SRA->RA_MAT <= cMatAte .And.;	
					   (SRA->RA_FILIAL >= cFilDe .And. SRA->RA_FILIAL <= cFilAte)
		
		If 	SRA->RA_CC 		< cCCDe .Or. SRA->RA_CC 		 > cCCAte 	.Or.;
			SRA->RA_SINDICA	< cSinDe.Or. SRA->RA_SINDICA > cSinAte	.Or.;
		 	SRA->RA_SITFOLH != " "	
			dbSkip()
			Loop
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Solicitacoes de Treinamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		dbSelectArea("RA3")                                        
		dbSetOrder(1)

		dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cCurDe,.T.)
		While !Eof()                                 .And.;
           (RA3->RA3_FILIAL == SRA->RA_FILIAL      ) .And.;
           (RA3->RA3_MAT    == SRA->RA_MAT         ) .And.;
		   (RA3->RA3_CURSO  >= cCurDe .And. RA3->RA3_CURSO  <= cCurAte)
			
			//Pesquisa Cargo	                         		    
		    cCargo := fGetCargo(SRA->RA_MAT)
		    
		    //Consiste Cargo
			If ( cCargo < MV_PAR15 ) .Or.;
			   ( cCargo > MV_PAR16 ) .Or.;
			   ( RA3->RA3_RESERV = "R" )
				dbSelectArea("RA3")
				dbSkip()
				Loop
			EndIf
			
			//Consiste Grupo e Departamento do Cargo do Func. 					
			dbSelectArea( "SQ3" )
			dbSetOrder(1)
			cAuxFil := xFilial("SQ3",SRA->RA_FILIAL)
			If dbSeek( cAuxFil + cCargo + SRA->RA_CC ) .Or. dbSeek( cAuxFil + cCargo )
				If SQ3->Q3_GRUPO < MV_PAR11 .Or. SQ3->Q3_GRUPO > MV_PAR12 .Or.;
					SQ3->Q3_DEPTO < MV_PAR13 .Or. SQ3->Q3_DEPTO > MV_PAR14
				
					dbSelectArea("RA3")
					dbSkip()
					Loop
				EndIf
			EndIf
            
			// Pesquisa Curso
			dbSelectArea("RA1")
			dbSetOrder(1)                   
			cAuxFil := xFilial("RA1",RA3->RA3_FILIAL)
			dbSeek(cAuxFil+RA3->RA3_CURSO)
						
			// Alimenta variaveis
			dbSelectArea("RA3")
			nPos := Ascan(aPlanej,{|x| x[1] == RA3->RA3_CURSO})
			If nPos == 0
		        Aadd(aPlanej, {RA3->RA3_CURSO,;	// Curso
   								1,;               	// Qtde. Func.
   								RA1->RA1_VALOR,;	// Valor do Treinamento
									RA1->RA1_HORAS,; // Horas do Treinamento
									RA3->RA3_MAT })	  //Matricula do Funcionario
		 	Else 
				aPlanej[nPos][2] += 1			 		// Qtde. Func.
				aPlanej[nPos][3] += RA1->RA1_VALOR	// Valor do Treinamento
				aPlanej[nPos][4] += RA1->RA1_HORAS	// Horas do Treinamento
				aPlanej[nPos][5] := RA3->RA3_MAT   //Matricula do Funcionario
		 	EndIf
				
	    	dbSkip()                    
	    EndDo
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Data de Validade dos Treinamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		dbSelectArea("RA4")
		dbSetOrder(1)                                             
		dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cCurDe,.T.)
		
		dDataRA4 := CtoD("")
		nRecRA4	 := 0		
		
		While !Eof() .And. (RA4->RA4_FILIAL == RA4->RA4_FILIAL) .And.;
                          (RA4->RA4_MAT    == SRA->RA_MAT)                             .And.;
				            (RA4->RA4_CURSO  >= cCurDe .And. RA4->RA4_CURSO  <= cCurAte)
				            
			If Empty(RA4->RA4_VALIDA)
				Exit
			EndIf				             
			
			//Verifica se Necessidade para o curso do Func. ja foi gerada				  
			nPos := Ascan(aPlanej,{|x| x[1]+x[5] == RA4->RA4_CURSO + RA4->RA4_MAT})
			If nPos == 0
				
				//Pesquisa Cargo
				cCargo := fGetCargo(SRA->RA_MAT)
				
				//Consiste Cargo					    
				If cCargo < MV_PAR15 .Or. cCargo > MV_PAR16
					dbSelectArea("RA4")
					dbSkip()
					Loop
				EndIf
				
				//Consiste Grupo e Departamento do Cargo do Func.	
				dbSelectArea( "SQ3" )
				dbSetOrder(1)
				cFil := xFilial("SQ3",SRA->RA_FILIAL) 
				If dbSeek( cFil + cCargo + SRA->RA_CC ) .Or. dbSeek( cFil + cCargo )
					If 	SQ3->Q3_GRUPO < MV_PAR11 .Or. SQ3->Q3_GRUPO > MV_PAR12 .Or.;
						SQ3->Q3_DEPTO < MV_PAR13 .Or. SQ3->Q3_DEPTO > MV_PAR14
						
						dbSelectArea("RA4")
						dbSkip()
						Loop
					EndIf
				EndIf
				
				If RA4->RA4_VALIDA > dDataRA4
					dDataRA4 := RA4->RA4_VALIDA
					nRecRA4 := RA4->(Recno())
				EndIf
	    	EndIf
	    	RA4->(dbSkip())                    
	    EndDo
	    
	    If nRecRA4 > 0					
      		dbSelectArea("RA4")
      		DbGoto(nRecRA4)
			If dDataRA4 <= dTr130at 								
				If !Empty(RA4->RA4_VALIDA) .And. RA4->RA4_VALIDA <= dTr130at 

					// Pesquisa Curso
					dbSelectArea("RA1")
					dbSetOrder(1)                   
					cAuxFil := xFilial("RA1",RA4->RA4_FILIAL)
					dbSeek(cAuxFil+RA4->RA4_CURSO)
	
					// Alimenta variaveis 
					dbSelectArea("RA4")
					nPos := Ascan(aPlanej,{|x| x[1] == RA4->RA4_CURSO})
					If nPos == 0
	    		    	Aadd(aPlanej, {RA4->RA4_CURSO,;	// Curso
		        						1,;               	// Qtde. Func.
		        						RA1->RA1_VALOR,;  	// Valor do Treinamento
										RA1->RA1_HORAS,; 		// Horas do Treinamento 
										""})
		        	Else 
						aPlanej[nPos][2] += 1			 		// Qtde. Func.
						aPlanej[nPos][3] += RA1->RA1_VALOR	// Valor do Treinamento
						aPlanej[nPos][4] += RA1->RA1_HORAS	// Horas do Treinamento
		 			EndIf						
	
	            EndIf
	    	EndIf
	    EndIf

		dbSelectArea("SRA")		
		dbSkip()
	EndDo                     
	      
	//Alimenta aCols automaticamente
	Tr130NewCols(aPlanej, cCod, cDesc, dTr130de, dTr130at, cMatResp, cNomResp)

EndIf

RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130NewCols³ Autor ³Emerson Grassi Rocha ³ Data ³ 19/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tr130NewCols(aPlanej,cCod,cDesc,dDataDe,dDataAte,cMatResp,cNomResp)

Local aSaveArea	:= GetArea()
Local nx		:= 0 
Local nPos		:= 0
Local nUsado  	:= Len(aHeader)
Local nCntFor	:= 0

Local nPosCurso := GdFieldPos("RA8_CURSO")
Local nPosDCur  := GdFieldPos("RA8_DESCCU")
Local nPosNFunc := GdFieldPos("RA8_NFUNC")
Local nPosValor := GdFieldPos("RA8_VALOR")
Local nPosHoras := GdFieldPos("RA8_HORAS")
Local nPosData	:= GdFieldPos("RA8_DATA")
Local nPosDataDe:= GdFieldPos("RA8_DATADE")
Local nPosDataAt:= GdFieldPos("RA8_DATAAT")
Local nPosMat	:= GdFieldPos("RA8_MAT")
Local nPosNome	:= GdFieldPos("RA8_NOME")

Asort(aPlanej,,,{|x,y| x[1] < y[1]})

dbSelectArea("RA8")
dbGoBottom()
For nx:=1 to Len(aPlanej)
	nPos := Ascan(aCols,{|x| x[nPosCurso] == aPlanej[nx][1]})
	If nPos == 0 .Or. aCols[nPos][Len(aCols[nPos])] // Nao encontrar ou Deletado
		If nPosCurso > 0 .And. Empty(aCols[1][nPosCurso])
		 	nPos := 1
		Else
			dbSelectArea("SX3")
			dbSeek("RA8")
			aadd(aCols,Array(nUsado+1))
			nPos := Len(aCols)
			For nCntFor := 1 To Len(aHeader)
				aCols[nPos][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			Next nCntFor
			aCols[nPos][nUsado+1] := .F.
		EndIf
	EndIf
	
	Iif(nPosCurso 	> 0, aCols[nPos][nPosCurso]		:= aPlanej[nx][1],)
	Iif(nPosDCur 	> 0, aCols[nPos][nPosDCur]		:= Fdesc("RA1",aPlanej[nx][1],"RA1_DESC"),)	
	Iif(nPosNFunc 	> 0, aCols[nPos][nPosNFunc] 	:= aPlanej[nx][2],)
	Iif(nPosValor 	> 0, aCols[nPos][nPosValor] 	:= aPlanej[nx][3],)
	Iif(nPosHoras 	> 0, aCols[nPos][nPosHoras] 	:= aPlanej[nx][4],)
	Iif(nPosData 	> 0, aCols[nPos][nPosData]		:= dDataBase,)
	Iif(nPosDataDe	> 0, aCols[nPos][nPosDataDe]	:= dDataDe,)
	Iif(nPosDataAt	> 0, aCols[nPos][nPosDataAt]	:= dDataAte,)
	Iif(nPosMat		> 0, aCols[nPos][nPosMat]		:= cMatResp,)
	Iif(nPosNome	> 0, aCols[nPos][nPosNome]		:= cNomResp,)     
	     
Next nx

oGet:Refresh(.T.)

RestArea(aSaveArea)

Return .t.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tr130Resp ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 25/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna Nome do Responsavel.			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tr130Resp(cMatResp,cNomResp)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tr130Resp(cMatResp,cNomResp)
Local aSaveArea := GetArea()

dbSelectArea("SRA")
dbSetOrder(1)
If dbSeek(xFilial("SRA")+cMatResp)
	cNomResp := Substr(SRA->RA_NOME,1,30)	
EndIf
	                         
RestArea(aSaveArea)	
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tr130Solic³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 23/10/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera Solicitacao de Compras automatica					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Trma130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tr130Solic(cAlias,nReg)

Local aSaveArea	:= GetArea()
Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local cCod		:= ""
Local nItem 	:= 0 
Local lGrava	:= .F.
Local cProd		:= ""
Local cDProd	:= ""
Local aFornec	:= {}
Local cFornec 	:= ""
Local cNomeFor	:= ""
Local nx		:= 0
Local aLstMat   := {}
Local lTR130Sol := ExistBlock("TR130SOL")

PRIVATE lMsErroAuto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RA8",aIndexRA8,.T.)
aIndexRA8 := {}

dbSelectArea("RA8")
dbSetOrder(1)
dbGoto(nReg)
cCod := RA8->RA8_PLANEJ

If Empty(RA8->RA8_NUMSC)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao de Arrays para Rotina Automatica de Solicitacao Compras.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	// Cabecalho
	aadd(aCabec,{"C1_EMISSAO" ,dDataBase	,Nil})
	
	// Itens   
	While !Eof() .And. RA8->RA8_PLANEJ == cCod
		aLinha 	:= {}    
		cProd	:= posicione("RA1", 1, xFilial("RA1")+RA8->RA8_CURSO	, "RA1_PROD")
		cDProd	:= Fdesc("RA1",RA8->RA8_CURSO,"RA1_DESC")
			
	    If !Empty(cProd)
		     
			dbSelectArea("RA6")
			dbSetOrder(2)
			dbSeek(xFilial("RA6")+RA8->RA8_CURSO)
			aFornec	:= {}
			While !Eof() .And. RA8->RA8_CURSO == RA6->RA6_CURSO

				cFornec := posicione("RA0", 1, xFilial("RA0")+RA6->RA6_ENTIDA	, "RA0_FORNEC")
				cNomeFor:= posicione("RA0", 1, xFilial("RA0")+RA6->RA6_ENTIDA	, "RA0_DESC")
				
				If !Empty(cFornec)
					Aadd(aFornec, {cFornec,cNomeFor})				
				EndIf
				
				dbSelectArea("RA6")
				dbSkip()
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica / Cria amarração Curso (Produto) x Entidade (Fornecedor). ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA5")
			dbSetOrder(2)
			For nx := 1 To Len(aFornec)               
				cFornec := aFornec[nx][1]   
				cNomeFor:= aFornec[nx][2]
				If !dbSeek(xFilial("SA5")+cProd+cFornec)
					RecLock("SA5",.T.)
						SA5->A5_FILIAL	:= xFilial("SA5")
						SA5->A5_FORNECE	:= cFornec
						SA5->A5_LOJA	:= "01" 
						SA5->A5_NOMEFOR	:= cNomeFor
						SA5->A5_PRODUTO	:= cProd
						SA5->A5_NOMPROD	:= cDProd
					MsUnlock()
				EndIf
			Next nx

			nItem++
			cItem 	:= Strzero(nItem,Len(SC1->C1_ITEM))
			
			If aScan( aLstMat , { |x| x[1] == RA8->RA8_MAT } ) == 0
				AAdd( aLstMat, {RA8->RA8_MAT, RA8->RA8_NOME} )
			EndIf
			
			aadd(aLinha,{"C1_ITEM"  	,cItem			,Nil})
			aadd(aLinha,{"C1_PRODUTO"  	,cProd			,Nil})
			aadd(aLinha,{"C1_QUANT"		,RA8->RA8_NFUNC	,Nil})
			aadd(aLinha,{"C1_DESCRI"	,cDProd			,Nil})
			aadd(aLinha,{"C1_ORIGEM"	,"TRM"			,Nil})
		
			aadd(aItens,aLinha)
		EndIf

		dbSelectArea("RA8")
		dbSkip()
	EndDo
	
	If nItem > 0
	
		If Len(aLstMat) > 1
			aadd(aCabec,{"C1_SOLICIT" ,""			            ,Nil})
			Aviso(STR0016,STR0029,{"Ok"})	
		Else
			aadd(aCabec,{"C1_SOLICIT" ,aLstMat[Len(aLstMat)][2]	,Nil})
		EndIf
		
		// Ponto de entrada p/ inclusao de campos nos itens do pedido
		If lTR130Sol
			ExecBlock( "TR130SOL" , .F., .F., {cCod, aCabec, aItens} )
		Else
			MATA110(aCabec,aItens,3)
	    EndIf

		If !lMsErroAuto
			Aviso("",STR0015+SC1->C1_NUM, {"Ok"})	//"Solicitacao gravada com sucesso - "
			lGrava := .T.
		Else
			Aviso(STR0016,STR0017,{"Ok"})	//"Atencao"###"Erro na inclusao automatica!"
		EndIf
	EndIf
Else
	Aviso(STR0016,STR0018+RA8->RA8_NUMSC ,{"Ok"})	//"Atencao"###"Ja foi gerada Solicitacao para este Planejamento - "
EndIf

If lGrava
	
	// Gravar Solicitacao no RA8
	dbSelectArea("RA8") 
	dbGoTo(nReg) 
	While !Eof() .And. RA8->RA8_PLANEJ == cCod

		RecLock("RA8",.F.)
			RA8->RA8_NUMSC := SC1->C1_NUM
		MsUnlock()
		
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA8")
Eval(bFiltraBrw)
dbGoTo(nReg)
			
RestArea(aSaveArea)
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR130ValCur³ Autor ³ Eduardo Ju           ³ Data ³ 25.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Valor do Curso de acordo c/ o No de Funcionarios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130  (Gatilho)                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function TR130ValCur()

Local nValAtu	:= 0    
Local nValUni   := 0
Local nQtdeFun  := GdFieldGet("RA8_NFUNC")  
Local cCurso    := GdFieldGet("RA8_CURSO")  

If !Empty(nQtdeFun)
	nValUni 	:= fDesc("RA1",cCurso,"RA1_VALOR")
	nValAtu 	:= nQtdeFun*nValUni
EndIf

Return(nValAtu)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR130Horas ³ Autor ³ Eduardo Ju           ³ Data ³ 25.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Valor das Horas acordo c/ o Curso (Gatilho)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function TR130Horas()

Local nValHoras	:= 0    
Local cCurso    := GdFieldGet("RA8_CURSO")

nValHoras := Fdesc("RA1",cCurso,"RA1_HORAS")  	

Return(nValHoras)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR130HTot  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 25.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Valor das Horas acordo c/ Qtde. funcion. (Valid) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±     
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function TR130HTot()

Local aArea := GetArea() 
Local lRet 		:= .T.
Local lRetAux 	:= .F.
Local nTam 		:= 7
Local nValHoras	:= 0    
Local cCurso    	:= GdFieldGet("RA8_CURSO")
Local nQtdeFun  	:= M->RA8_NFUNC
Local nPosHoras 	:= GdFieldPos("RA8_HORAS")

nValHoras 	:= Fdesc("RA1",cCurso,"RA1_HORAS")
nValHoras 	:= nQtdeFun*nValHoras

If TAMSX3('RA8_HORAS')[1] == nTam
		 lRetAux := .T.
EndIF

If(nValHoras > 9999.99) .And. (lRetAux)
	lRet := .F.
	MsgInfo(STR0028,STR0016)
EndIF		
aCols[n][nPosHoras] := nValHoras  	

RestArea(aArea)

Return ( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR130LINDEL ³ Autor ³ Henrique V.         ³ Data ³ 02.09.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a delecao da linha da getdados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TRMA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tr130LinDel()
Local aAreaRA8 := RA8->( GetArea() )
Local lSelfDel := IsInCallStack("{|| SELF:DELOK()}")	
Local nPosSeq  := GdFieldPos("RA8_SEQ")
Local cAliasRA8:= "RA8"
Local lRet     := .T.
Local nReg     := 0
Local nOpcx    := 5
		
dbSelectArea(cAliasRA8)
dbSetOrder(1)
If dbSeek(xFilial(cAliasRA8) + cCod + aCols[n,nPosSeq])
	nReg := RA8->(RECNO())
	//-- Verifica se pode eliminar a linha da getdados  
	//-- Artificio para nao verificar duas vezes a mesma situacao (processo automatico da MSGETDADOS).
	IF !lSelfDel
		If !Tr130Dele(cAliasRA8,nReg,nOpcx,.T.)
			Aviso(STR0016, STR0025,{"OK"})                
			lRet:= .F.          
		EndIf
	EndIf	
EndIf

RestArea(aAreaRA8)

Return lRet

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³21/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TRMA030                                                     ³
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

Local aRotina :=      { 	{ STR0001, "PesqBrw"	, 0, 1,,.F.}, ;	//"Pesquisar"
							{ STR0002, "Tr130Rot"	, 0, 2}, ;	//"Visualizar"
					  		{ STR0003, "Tr130Rot"	, 0, 3}, ;	//"Incluir"
					  		{ STR0004, "Tr130Rot"	, 0, 4}, ;	//"Alterar"
					  		{ STR0005, "Tr130Rot"	, 0, 5,3},;	//"Excluir"
							{ STR0014, "Tr130Solic"	, 0, 2} }	//"Sol.Compra"					  		

// Ponto de entrada p/ inclusao de novas opcoes em aRotina
If lTR130MNU
	aRotina := ExecBlock( "TR130MNU" , .F., .F., {aRotina} )
Endif

Return aRotina
