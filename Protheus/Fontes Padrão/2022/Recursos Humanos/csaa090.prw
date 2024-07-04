#INCLUDE "Protheus.ch"
#INCLUDE "CSAA090.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAA090  ³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Quadro de Funcionarios                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSAA090()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³07/07/14³TPZVTW³Incluido o fonte da 11 para a 12 e        ³±±
±±³            ³        ³      ³efetuada a limpeza.                       ³±±
±±³Esther V.   ³07/10/16³TVOH80³Ajustada geracao do quadro de funcionarios³±±
±±³            ³        ³      ³para respeitar os parametros informados , ³±±
±±³            ³        ³      ³o compartilhamento da tabela e o acesso   ³±±
±±³            ³        ³      ³do usuario.                               ³±±
±±³Oswaldo L   ³22/08/17³DRHPON³Habilitar edição campos novos inseridos na³±±
±±³            ³        ³TP1436³tabela RB8 + preservar regras da tela     ³±±
±±³Oswaldo L   ³14/09/17³DRHPON³evitar duplicate key pois o sistema nao   ³±±
±±³            ³        ³TP1663³utilizava a variavel correta de filial    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAA090
Local cFiltraCTT			//Variavel para filtro
Local aIndexCTT	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

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
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemToAnsi(STR0004) //"Quadro de Funcionario por Centro de Custo"
Private cFilRB8	:= xFilial("RB8")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH("CSAA090","CTT","1")
bFiltraBrw 	:= {|| FilBrowse("CTT",@aIndexCTT,@cFiltraRH) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("CTT")
DbGoTop()

mBrowse(06,01,22,75,"CTT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("CTT",aIndexCTT)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs090Gera³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de chamada da Geracao dos dados do Quadro de Vagas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs090Gera()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSAA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs090Gera(cAlias,nReg,nOpc)
Local oDlg
Local nOpca		:= 0
Local aRegs		:= {}
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia

Private cCadastro := OemtoAnsi(STR0005)//"Atualizacao salarios dos funcionarios"

Pergunte("CSA090",.F.)

AADD(aSays,OemToAnsi(STR0006) ) //"Este rotina gera as informacoes de numero de funcionario e valores salariais"
AADD(aSays,OemToAnsi(STR0007) ) //"que possui o Centro de Custo num determinado periodo"
AADD(aButtons, { 5,.T.,{|| Pergunte("CSA090",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(Cs090Conf(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| Cs090Processa()})	// Chamada do Processamento
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs090Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 27.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs090Processa()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Processa()
Local aGrava	:= {}
Local cFilDe	:= ""
Local cFilAte	:= ""
Local cCCDe		:= ""
Local cCCAte	:= ""
Local cAnoMesDe	:= ""
Local cAnoMesAte:= ""
Local nx		:= 0
Local cAnoMesAtu:= ""

// mv_par01		- Filial De
// mv_par02		- Filial Ate
// mv_par03		- Centro Custo De
// mv_par04		- Centro Custo Ate
// mv_par05		- Ano/Mes De
// mv_par06		- Ano/Mes Ate

Pergunte("CSA090",.F.)

// Variaveis da pergunte
cFilDe		:= mv_par01
cFilAte		:= mv_par02
cCCDe		:= mv_par03
cCCAte		:= mv_par04
cAnoMesDe	:= mv_par05
cAnoMesAte	:= mv_par06

// Validando os dados da pergunte
If 	Empty(cAnoMesDe) .Or. Empty(cAnoMesAte)
	Help("",1,"CS090DATA")		//Ano/Mes em branco
	Return Nil
EndIf

If 	Val(Substr(cAnoMesDe,1,4)) < 1900 	.Or.;
	Val(Substr(cAnoMesAte,1,4)) < 1900
	Help("",1,"CS090ANO")		//Verifique o ano da pergunte
	Return Nil
EndIf

If 	Val(Substr(cAnoMesDe,5,6)) < 1 	.Or.;
 	Val(Substr(cAnoMesDe,5,6)) > 12   .Or.;
	Val(Substr(cAnoMesAte,5,6)) < 1 	.Or.;
 	Val(Substr(cAnoMesAte,5,6)) > 12
	Help("",1,"CS090MES")		//Verifique o mes da pergunte
	Return Nil
EndIf

If 	cAnoMesAte < cAnoMesDe
	Help("",1,"CS090MAIOR")	//Ano/Mes de esta maior que Ano/Mes Ate
	Return Nil
EndIf

cAnoMesAtu := Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)

If cAnoMesDe < cAnoMesAtu
	Aviso( 	OemToAnsi(STR0015),;	//"Atencao"
			OemToAnsi(STR0030)+;	//"Esta opcao tem o objetivo de Planejar e projetar o Quadro de funcionários e nao a obtenção "
			OemToAnsi(STR0031),;	//"de informações passadas, portanto informe nos Parametros, um período a partir do mes atual. "
			{"Ok"})
	Return Nil
EndIf

Cs090Calc(@aGrava,cFilDe,cFilAte,cCCDe,cCCAte,cAnoMesDe,cAnoMesAte,.T.)

For nx:=1 To Len(aGrava)
	dbSelectArea("RB8")
	dbSetOrder(1)
	If DbSeek(aGrava[nx][6]+aGrava[nx][2]+aGrava[nx][1])
		RecLock("RB8",.F.)
	Else
		RecLock("RB8",.T.)
		Replace RB8->RB8_FILIAL		With aGrava[nx][6] //xFilial("RB8")
		Replace RB8->RB8_CC			With aGrava[nx][2]
		Replace RB8->RB8_ANOMES		With aGrava[nx][1]
	EndIf

	Replace RB8->RB8_NRATUA		With aGrava[nx][3]
	Replace RB8->RB8_VLATUA		With aGrava[nx][4]
	MsUnlock()

	cFilRB8 := RB8->RB8_FILIAL
	// Gera Quadro por funcao - RBD
	Cs090PrcFun(aGrava[nx],cFilDe,cFilAte)

	//Ponto de Entrada executado apos a gravacao do registro para permitir a
	//manipulacao das informacoes que foram adicionadas na tabela RB8.
	If ExistBlock("CSA90B03")
		Execblock("CSA90B03",.F.,.F.,{RB8->RB8_FILIAL,RB8->RB8_ANOMES,RB8->RB8_CC})
	Endif

Next nx

dbSelectArea("SRA")
dbSetOrder(1)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs090Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao principal do Quadro de vagas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs090Rot()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSAA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs090Rot(cAlias,nReg,nOpc)

Local oGet, oLbx, oGroup, oDlg , oFont
Local cChave		:= ""
Local cDescr		:= CTT->CTT_DESC01
Local lCsDel		:= If(nOpc == 2 .Or. nOpc == 5,.F.,.T.)
Local nGrava		:= 0

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local aBtn90		:= {}					//Array para retorno do PE CSA90B01
Local aCposHead     := {}
Local aCposNoHd     := {}

// Definicao dos arrays da getdados
Private aCols 	:= {}
Private aHeader	:= {}
Private aGrvRBD := {}
Private aAltera := {}

// Variavel da mbrowse
Private cCC		:= CTT->CTT_CUSTO

If Empty( xFilial("RB8") )
	aCposHead := {"RB8_CC","RB8_FILIAL"}
Else
	aCposHead := {"RB8_CC"}
	aCposNoHd := {"RB8_FILIAL"}
EndIf

// Monta aHeader da GetDados
TrmHeader(@aHeader,aCposHead,"RB8",aCposNoHd)

// Monta o aCols da GetDados
cChave := xFilial("RB8")+cCC
Cs090aCols(@aCols,nOpc,"RB8","RB8->RB8_FILIAL+RB8->RB8_CC",cChave,aHeader,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as Dimensoes dos Objetos         					         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

SETAPILHA()
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL


	@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO aObjSize[1,3],aObjSize[1,4]*0.35 LABEL OemToAnsi(STR0024) OF oDlg PIXEL	// "Codigo do Centro de Custo"
	oGroup:oFont:= oFont
	@ aObjSize[1,1], aObjSize[1,4]*0.355 GROUP oGroup TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0025) OF oDlg PIXEL	// "Descricao do Centro de Custo"
	oGroup:oFont:= oFont

	@ aObjSize[1,1]+10, aObjSize[1,2]*2.5	MSGET cCC		WHEN .F. SIZE 120,10 PIXEL
	@ aObjSize[1,1]+10, aObjSize[1,4]*0.37 	MSGET cDescr	WHEN .F. SIZE 120,10 PIXEL

	oGet		:= MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3]-15,aObjSize[2,4],nOpc,"Cs090Ok","AlwaysTrue","",lCsDel,aAltera,,,300,,,,,oDlg)

	bSet15		:= {|| If(oGet:TudoOk(),(nGrava:= 1,oDlg:End()),.F.) }
	bSet24		:=    	   			{||nGrava:=0,oDlg:End()}
	aButtons	:= {;
						{"COLINC",{||Cs090List()},OeMToAnsi(STR0009),OemToAnsi(STR0028)},; //"Distribuicao por Funcao"#"Distribuir"
						{"BMPCPO",{||Cs090Lanc(nOpc,oGet)},OeMToAnsi(STR0016),OemToAnsi(STR0029)};//"Lancamento por Funcao"#"Lançar"
					}
	//Ponto de entrada para inclusao de botoes na TOOBAR.
	If ExistBlock("CSA90B01")
		aBtn90:=ExecBlock("CSA90B01",.F.,.F.)
		If Valtype(aBtn90)="A".AND.Len(aBtn90)>=2 //Garante que tenha o icone do botao e a função a ser executada
			aadd(aButtons,aBtn90 )
		EndIf
	EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ) CENTERED

If 	nGrava == 1
	PcoIniLan("000083")

	Begin Transaction
		Cs090Grava()
		EvalTrigger()
	End Transaction

	PcoFinLan("000083")

EndIf

PcoFreeBlq("000083")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090aCols³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o acols da getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090aCols(aAuxCols,nOpcx,cAlias,cCond,cChave,aAuxHeader,nOrdem)
Local cFilialDe := ""
Local cFilialAte:= ""
Local cValidFil	:= fValidFil()
Local cGrpEmp 	:= FwGrpCompany()
Local ny 		:= 0
Local nAcols	:= 0
Local nCntFor 	:= 0
Local nUsado  	:= Len(aAuxHeader)
Local lTemGC	:= fIsCorpManage( cGrpEmp ) // verifica se a empresa tem gestao corporativa
Local aSaveArea := GetArea()
Local aEmpCor 	:= {}
Local cFilSelec 

If cAlias == "RB8"
	aEmpCor := FwLoadSM0()
	If	Empty(xFilial("CTT")) // se C.Custo Compartilhado CCC, filtro fica sendo branco a ZZZ
		For ny := 1 to Len(aEmpCor)
			If aEmpCor[ny][1] == cGrpEmp //verifico GrpEmpresa corrente
				cFilialDe := xFilial("RB8",aEmpCor[ny][2])
				Exit
			EndIf
		Next ny
		cFilialAte := Replicate('Z',FwGetTamFilial)
	Else
		For ny := 1 to Len(aEmpCor)
			If aEmpCor[ny][1] == cGrpEmp //verifico GrpEmpresa corrente
				If (CTT->CTT_FILIAL == aEmpCor[ny][3])  .OR. (CTT->CTT_FILIAL == aEmpCor[ny][3]+aEmpCor[ny][4]) ;
					.OR. (CTT->CTT_FILIAL == aEmpCor[ny][2])

					cFilialDe := xFilial("RB8",aEmpCor[ny][2])
					Exit
				EndIf
			EndIf
		Next ny
		cFilialAte := Substr(RTrim(CTT->CTT_FILIAL)+'ZZZZZZZZZZZZ',1,FwGetTamFilial)
	EndIf

	ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp})

	For nCntFor := 1 To Len(aAuxHeader)//neste ponto tratamos inclusive o caso do browse vazio ainda sem registros
		If ( aAuxHeader[nCntFor][10] != "V")
			If  !(AllTrim(aAuxHeader[nCntFor][2]) $ "RB8_NRATUA|RB8_VLATUAL")//janela original não permitia editar estas 2 colunas
				Aadd ( aAltera, aAuxHeader[nCntFor][2] )
			EndIf
		EndIf
	Next nCntFor

	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)	
	cFilSelec := FWCodFil() // Retorna o código da Filial posicionada
	
	While ny <= Len(aEmpCor) .AND. (aEmpCor[ny][1] == cGrpEmp) .AND. (aEmpCor[ny][2] <= cFilialAte)
		//verifico se a filial do registro atual da RB8 eh diferente da filial do registro anterior
		If (aEmpCor[ny,2] $ cValidFil) .AND. ((ny == 1) .OR. ((ny - 1 != 0) .AND. (xFilial("RB8",aEmpCor[ny,2]) != xFilial("RB8",aEmpCor[ny-1,2]))))
			cChave := (xFilial("RB8",aEmpCor[ny][2]) + cCC)
			If dbSeek(cChave)
				While !Eof() .And. &cCond <= cFilialAte  .And. cFilSelec == RB8->RB8_FILIAL
					Aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
					nAcols := Len(aAuxCols)
					For nCntFor := 1 To Len(aAuxHeader)

						If ( aAuxHeader[nCntFor][10] != "V")
							aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aAuxHeader[nCntFor][2]))
						Else
							aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
						EndIf
					Next nCntFor

					If nOpcx # 2 .And. nOpcx # 5
						aAuxCols[nAcols][nUsado+1] := .F.
					EndIf

					dbSelectArea(cAlias)
					dbSkip()
					//somente circula o while da tabela se manter no mesmo CC e tiver acesso a filial.
					If lTemGC .AND. ( !(RTrim(RB8->RB8_Filial) $ cValidFil) .OR. (RB8->RB8_CC != cCC) )
						Exit
					ElseIf !lTemGC .AND. ( !( (RB8->RB8_Filial) $ cValidFil) .OR. (RB8->RB8_CC != cCC) )
						Exit
					EndIf
				EndDo
			EndIf
			If Empty(RB8->RB8_FILIAL) .OR. (xFilial("RB8",aEmpCor[ny][2]) == RB8->RB8_Filial)
				ny++
			Else
				ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp .AND. RTrim(RB8->RB8_Filial) $ x[2]})
			EndIf
		Else
			ny++
		EndIf
	EndDo

Else //RBD
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	If dbSeek(cCHAVE)
		While !Eof() .And. &cCond == cChave
			Aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
			nAcols := Len(aAuxCols)
			For nCntFor := 1 To Len(aAuxHeader)
				If ( aAuxHeader[nCntFor][10] != "V")
					aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aAuxHeader[nCntFor][2]))
				Else
					aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
				EndIf
			Next nCntFor

			If nOpcx # 2 .And. nOpcx # 5
				aAuxCols[nAcols][nUsado+1] := .F.
			EndIf
			dbSelectArea(cAlias)
			dbSkip()
		EndDo
	EndIf
EndIf

If Empty(aAuxCols)
	dbSelectArea("SX3")
	dbSeek(cAlias)
	aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
	nAcols := Len(aAuxCols)
	For nCntFor := 1 To Len(aAuxHeader)
		If aAuxHeader[nCntFor][2] == "RBD_FILIAL"
			aAuxCols[nAcols][nCntFor] := xFilial("RBD",cChave) //carrego o valor do campo Filial pois nao eh permitida alteracao
		Else
			aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
		EndIf
	Next nCntFor
	If nOpcx # 2 .And. nOpcx # 5
		aAuxCols[1][nUsado+1] := .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090Ok   ³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de linha ok da getdados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Ok()
Local nPosFilial:= GdFieldPos("RB8_FILIAL")
Local nPosData	:= GdFieldPos("RB8_ANOMES")
Local nx		:= 0

// Verifica se a linha esta deletado
If 	aCols[n][Len(aCols[n])]
	Return .T.
EndIf

If	(nPosData >0 .And. Empty(aCols[n][nPosData]))
	Help("",1,"Cs090DADOS")	// Verifique os campos de MES/ANO nao podem esta vazios
	Return .F.
EndIf

If 	nPosData > 0 .AND. nPosFilial > 0
	For nx:=1 To Len(aCols)
		If 	aCols[n][nPosFilial] == aCols[nx][nPosFilial] .AND. aCols[n][nPosData]== aCols[nx][nPosData]	.And.;
			n # nx .And.!aCols[nx][Len(aCols[nx])] .And.;
			!aCols[n][Len(aCols[n])]
			Help("",1,"CS090IGUAL")		// Filial + MES/ANO iguais.
			Return .F.
		EndIf
	Next nx
EndIf

If !PcoVldLan('000083','02','CSAA090')
	Return .F.
EndIf

dbSelectArea("RB8")
dbGoBottom()
dbSkip()

Return.T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090MesAno  ³ Autor ³ Cristina Ogura     ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de linha ok da getdados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090aCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090MesAno()
Local cVar		:= &(ReadVar())
Local cFilialDe := ""
Local cFilialAte:= ""
Local cGrpEmp	:= FwGrpCompany()
Local nPosFilial:= GdFieldPos("RB8_FILIAL")
Local nPosAnoMes:= GdFieldPos("RB8_ANOMES")
Local nPosVl	:= GdFieldPos("RB8_VLATUA")
Local nPosNr	:= GdFieldPos("RB8_NRATUA")
Local nx     	:= 0
Local aGrava	:= {}
Local aEmpCor 	:= FwLoadSM0()

//Verifica se filial foi preenchida
If !Empty(xFilial("RB8")) .AND. Empty(aCols[n][nPosFilial])
	Help(,,,OemToAnsi( STR0015 ),OemToAnsi( STR0047 ),1,0) //"Atenção" ### "Filial não preenchida. Preencha o campo filial com um código válido."
	Return .F.
EndIf

// Verificar o mes da data
If 	Val(Substr(cVar,5,2)) < 1 .Or. ;
	Val(Substr(cVar,5,2)) > 12
	Help("",1,"CS090MES")		// Mes invalido
	Return .F.
EndIf

// Verificar o ano da data
If 	Val(Substr(cVar,1,4)) == 0 	.Or.;
	Val(Substr(cVar,1,4)) < 1900
	Help("",1,"Cs090ANO")		// Ano Invalido
	Return .F.
EndIf

For nx:=1 To Len(aCols)
	If 	!aCols[n][Len(aCols[n])] .And. ( nPosFilial == 0 .Or. aCols[n][nPosFilial] == aCols[nx][nPosFilial] ) .And. nx # n .And. cVar == aCols[nx][nPosAnoMes]
		Help("",1,"Cs090IGUAL") //FILIAL + MES/ANO iguais
		Return .F.
	EndIf
Next nx

If	Empty(xFilial("RB8")) // se RB8 Compartilhado CCC, filtro fica sendo branco a ZZZ
	ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp})
	cFilialDe := aEmpCor[ny][2]
Else
	ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp})
	While ny <= Len(aEmpCor) .AND. aEmpCor[ny][1] == cGrpEmp
		If ( RTrim(aCols[n][nPosFilial]) == RTrim(aEmpCor[ny][3]) ) .Or. ( RTrim(aCols[n][nPosFilial]) == RTrim(aEmpCor[ny][3]+aEmpCor[ny][4]) ) .Or. ( aCols[n][nPosFilial] == aEmpCor[ny][2] )

			cFilialDe := aEmpCor[ny][2]
			Exit
		EndIf
		ny++
	EndDo
EndIf
cFilialAte := Substr( RTrim( IIf( nPosFilial > 0,aCols[n][nPosFilial],xFilial("RB8") ) ) + 'ZZZZZZZZZZZZ',1,FwGetTamFilial )

Cs090Calc(@aGrava,cFilialDe,cFilialAte,cCC,cCC,cVar,cVar,.F.)

If 	Len(aGrava) == 1
	aCols[n][nPosNr] := aGrava[1][3]
	aCols[n][nPosVl] := aGrava[1][4]
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090Calc ³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz calculo do nr de funcionarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090Calc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Calc(aGrava,cFilDe,cFilAte,cCCDe,cCCAte,cAnoMesDe,cAnoMesAte,lProc)
Local cAux		:= cAnoMesDe
Local cFim		:= ""
Local cInicio	:= ""
Local nAno		:= 0
Local nMes		:= 0
Local nSal		:= 0
Local aMeses	:= {}
Local nx		:= 0
Local cExpFilDe := ''
Local cExpFilAte:= ''
Local cExpCCDe	:= ''
Local cExpCCAte	:= ''
Local cExpAMDe	:= ''
Local cExpAMAte	:= ''
Local cExpOrder := ''
Local cAliasQry := ''
Local lCompart  := xFilial("RB8") <> cFilAnt
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca	:= Len(aFldRel) > 0

While Val( cAux ) <= Val( cAnoMesAte)
	Aadd(aMeses,{ cAux , 0 , 0 , 0 , 0 } )	// AnoMes, Nr atual, Nr Previsto, Vl Atual, Vl Previsto
	nMes := Val(Substr(cAux,5,2)) + 1
	nAno := Val(Substr(cAux,1,4))
	If nMes > 12
		cAux := StrZero(nAno + 1,4) + "01"
	Else
		cAux := StrZero(nAno,4) + StrZero(nMes,2)
	Endif
EndDo

// Grava no array os funcionarios que serao contados para geracao
cInicio	:= "SRA->RA_FILIAL+SRA->RA_CC"
cFim	:= cFilAte+cCCAte

dbSelectArea("SRA")
dbSetOrder(2)
dbSeek(cFilDe+cCCDe,.T.)

If 	lProc
	ProcRegua(SRA->(RecCount()))
EndIf

//Carrega os mnemônicos
SetMnemonicos(NIL,NIL,.T.)

While SRA->(!Eof()) .And. &cInicio <= cFim

	If !( SRA->RA_FILIAL $ fValidFil() ) //valida acesso
		SRA->(dbSkip())
		Loop
	EndIf

	If SRA->RA_CC < cCCDe .Or. SRA->RA_CC > cCCAte
		SRA->(dbSkip())
		Loop
	EndIf

	If 	MesAno(SRA->RA_ADMISSA) > cAnoMesAte
		SRA->(dbSkip())
		Loop
	EndIf

	If 	!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) < cAnoMesDe
		SRA->(dbSkip())
		Loop
	EndIf

	If 	lProc
		IncProc(STR0052 + SRA->RA_MAT + If(lOfusca, "", " " + SRA->RA_NOME) )
	EndIf

	FSalario(@nSal,,,,"A",AnoMes(SRA->RA_ADMISSA))

	// Quando nao tenho SRA->RA_TIPOPGT e SRA->RA_CATFUN definidos no SRA
	// a variavel nSal volta sem valor
	If 	nSal == Nil
		nSal := 0
	EndIf


	For nx:= 1 To Len(aMeses)

		// Verifica os admitido
		If 	MesAno(SRA->RA_ADMISSA) > aMeses[nx][1]
			Loop
		EndIf

		// Verifica os demitidos
		If 	!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) <= aMeses[nx][1]
			Loop
		EndIf

		nPos := 0
		nPos :=	Ascan(aGrava,{|x| x[1]== aMeses[nx][1] .And. x[2]+x[6] == SRA->RA_CC + xFilial("RB8",SRA->RA_FILIAL)})

		If 	nPos == 0
			Aadd(aGrava,{aMeses[nx][1], SRA->RA_CC, 1, nSal, .F., xFilial("RB8",SRA->RA_FILIAL)})	// AnoMes, Centro de Custo, Qtde, Salario
		Else
			aGrava[nPos][3] := aGrava[nPos][3] + 1
			aGrava[nPos][4] := aGrava[nPos][4] + nSal
		EndIf
	Next nx

	dbSelectArea("SRA")
	dbSetOrder(2)
	SRA->(dbSkip())
EndDo

//Ponto de entrada para inclusão de registros no aGrava
If ExistBlock("CSA90CCUS")
	aGrava := ExecBlock("CSA90CCUS",.F.,.F.,{aGrava})
EndIf

cExpFilDe	:= "%'" + cFilDe + "'%"
cExpFilAte	:= "%'" + cFilAte + "'%"

cExpCCDe	:= "%'" + cCCDe + "'%"
cExpCCAte	:= "%'" + cCCAte + "'%"

cExpAMDe	:= "%'" + cAnoMesDe + "'%"
cExpAMAte	:= "%'" + cAnoMesAte + "'%"

cFilialIn 	:= "%('"+(StrTran(fvalidfil(),"/","','"))+"')%"
cExpOrder 	:= "%RB8_FILIAL,RB8_CC,RB8_ANOMES%"

cAliasQry 	:= GetNextAlias()

BeginSql Alias cAliasQry
	SELECT RB8_FILIAL,RB8_CC,RB8_ANOMES,RB8_VLATUA,RB8_VLPREV,RB8_NRATUA,RB8_NRPREV
	FROM 	%table:RB8% RB8
	WHERE
		RB8_FILIAL BETWEEN  %Exp:cExpFilDe% AND %Exp:cExpFilAte% AND
		RB8_CC BETWEEN  %Exp:cExpCCDe% AND %Exp:cExpCCAte% AND
		RB8_ANOMES BETWEEN 	%Exp:cExpAMDe%	AND %Exp:cExpAMAte% AND
		RB8_FILIAL IN %Exp:cFilialIn% AND
		RB8.%NotDel%
	ORDER BY %Exp:cExpOrder%
EndSql

While (cAliasQry)->(!Eof() .and. (RB8_CC <= cCCAte))

	IF (cAliasQry)->(Empty(Ascan(aGrava,{|x| x[1]== RB8_ANOMES .And. x[2] + x[6] == RB8_CC + RB8_FILIAL}) ))
		(cAliasQry)->( Aadd( aGrava,{RB8_ANOMES, RB8_CC, 0, 0, .T., RB8_FILIAL } )	) // AnoMes, Centro de Custo, Qtde, Salario
	Endif

	(cAliasQry)->(DbSkip())
End While

If ( Select( cAliasQry ) > 0 )
	( cAliasQry )->( dbCloseArea() )
EndIf

dbSelectArea("SRA")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090Grava ³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os arquivos de RB8.                				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090Grava()     				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Grava()
Local nx		:= 0
Local nt		:= 0
Local aAnterior := {}
Local cCampo	:= ""
Local xConteudo := ""
Local nTam 		:= Len(aCols)
Local nPosFilial:= GdFieldPos("RB8_FILIAL")
Local nPosData	:= GdFieldPos("RB8_ANOMES")
Local cChvRBD	:= ""

DbSelectArea("RB8")
DbSetOrder(1)
For nx := 1 to nTam
	If DbSeek( xFilial( "RB8",IIf( nPosFilial > 0,aCols[nx][nPosFilial],Nil ) ) + cCC + aCols[nx][nPosData] )
		Aadd(aAnterior, RecNo())
	EndIf
Next nx

For nx:=1 to nTam
	If nx <= Len(aAnterior)
		dbGoto(aAnterior[nx])
		//--Verifica se esta deletado
		If  aCols[nx][Len(aCols[nx])]
			RecLock("RB8",.F.)
				PcoDetLan("000083","02","CSAA090", .T.)
				dbDelete()
			MsUnlock()

			dbSelectArea("RBD")
			dbSetOrder(1)
			dbSeek(xFilial("RBD",aCols[nx][nPosFilial]) + cCC + aCols[nx][nPosData])
			cChvRBD := RBD->RBD_FILIAL + cCC + aCols[nx][nPosData]
			While !Eof() .And. xFilial("RBD",aCols[nx][nPosFilial])+RBD->RBD_CC+RBD->RBD_ANOMES == cChvRBD

				RecLock("RBD",.F.)
					PcoDetLan("000083","01","CSAA090", .T.)
					dbDelete()
				MsUnlock()
				dbSkip()
			Enddo

			dbSelectArea("RB8")
			Loop
		Else
			RecLock("RB8",.F.)
		EndIf

	Else
		If aCols[nx][Len(aCols[nx])]
			Loop
		EndIf
		RecLock("RB8",.T.)
		Replace RB8->RB8_CC			With cCC
	EndIf

	For nt := 1 To Len(aHeader)
		If aHeader[nt][10] # "V"
			cCampo		:= Trim(aHeader[nt][2])
			xConteudo 	:= aCols[nx][nt]
			Replace &cCampo With xConteudo
		EndIf
	Next nt
	MsUnlock()
	PcoDetLan("000083","02","CSAA090")
Next nx
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs090List³ Autor ³ Cristina Ogura        ³ Data ³ 11.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que monta o listbox com a distribuicao das funcoes  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs090List()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSAA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs090List()
Local cFil 		:= xFilial("SRA")
Local cValidFil	:= fValidFil()
Local aList 	:= {}
Local nPos		:= 0
Local nPosAnoMes:= GdFieldPos("RB8_ANOMES")
Local cAnoMes	:= ""
Local oDlg
Local oFont

Local cInicio	:= ""
Local cFim		:= ""

Local cFilDe	:= ""
Local cFilAte	:= ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Declaração de arrays para dimensionar tela	               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local lCompart		:= Empty( xFilial("RB8") )
Local bSet15
Local bSet24
Pergunte("CSA090",.F.)

// Variaveis da pergunte
cFilDe		:= mv_par01
cFilAte		:= mv_par02

If nPosAnoMes > 0
	cAnoMes	:= aCols[Len(aCols)][nPosAnoMes]
	cAnoMes := Stuff(cAnoMes,5,0,"/")
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

cInicio	:= "SRA->RA_FILIAL+SRA->RA_CC"
cFim := Substr(RTrim(CTT->CTT_FILIAL)+'ZZZZZZZZZZZZ',1,FwGetTamFilial)+cCC

dbSelectArea("SRA")
dbSetOrder(2)
dbSeek(cFilDe+cCC,.T.)

While !Eof() .And. &cInicio <= cFim
	If !(SRA->RA_FILIAL $ cValidFil)
		SRA->(dbSkip())
		Loop
	EndIf

	If cCC != SRA->RA_CC
		SRA->(dbSkip())
		Loop
	EndIf

	If SRA->RA_FILIAL > cFilAte
		Exit
	EndIf

	// Verifica os demitidos
	If 	!Empty(SRA->RA_DEMISSA)
		SRA->(dbSkip())
		Loop
	EndIf

	nPos := 0
	nPos :=	Ascan(aList,{|x| x[2]+x[3]== xFilial("RB8", SRA->RA_FILIAL)+SRA->RA_CODFUNC})
	If 	nPos == 0
		Aadd(aList,{1,xFilial("RB8", SRA->RA_FILIAL),SRA->RA_CODFUNC,DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)})
	Else
		aList[nPos][1] := aList[nPos][1] + 1
	EndIf

	dbSelectArea("SRA")
	dbSkip()
EndDo

If 	Len(aList) == 0
    Help("",1,"CS090NODIS")		// Nao ha dados das funcoes
    Return .F.
EndIf

//ordena lista em ordem FILIAL + Funcao
aSort(aList,,,{|x,y|x[2]+x[3] < y[2]+y[3]})

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize(  , .T., 500)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0010 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	//"Distribuicao das Funcoes"

   	bSet15	:= {|| oDlg:End()}
	bSet24	:= {|| oDlg:End()}

	@ aObjSize[1][1]+5,aObjSize[1][2] SAY OemToAnsi(STR0026+cAnoMes+"  "+STR0043+cFilDe+STR0044+cFilAte) FONT oFont COLOR CLR_BLUE PIXEL //"Referente Ano/Mes: "###"Filial: "###" ate "

	@ aObjSize[2][1],aObjSize[2][2] LISTBOX oLbx FIELDS HEADER	;
										"Filial",;					//Filial
										"Quantidade"/*STR0011*/,;					//"Qtde"
										STR0012,;					//"Funcao"
										STR0013 SIZE aObjSize[2][3],aObjSize[2][4]-15 PIXEL	//"Descricao da funcao"

	oLbx:SetArray(aList)
	oLbx:bLine:= {||{aList[oLbx:nAt,2],aList[oLbx:nAt,1],aList[oLbx:nAt,3],aList[oLbx:nAt,4]}}

ACTIVATE MSDIALOG oDlg On Init Enchoicebar( oDlg, bSet15, bSet24 ) CENTERED

Return .T.

Static Function Cs090Conf()
Return (MsgYesNo(OemToAnsi(STR0014),OemToAnsi(STR0015))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs090Lanc³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lancamento de Necessidade de Aumento de Quadro por Funcao. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs090Lanc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSAA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC  ³  Motivo da Alteracao  	 	 	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³      								  ³±±
±±³            ³          ³      ³ 						                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Cs090Lanc(nOpc,oGet)

Local oGet2
Local oDlg
Local oGroup
Local oFont
Local aAuxCols	:= Aclone(aCols)
Local aAuxHeader:= Aclone(aHeader)
Local aButtons	:= {}					//Array de definição dos botoes da TooBar
Local bSet15	:= { || NIL }
Local bSet24	:= { || NIL }
Local nAuxN		:= n
Local lCsDel	:= If(nOpc == 2 .Or. nOpc == 5,.F.,.T.)
Local cFil 		:= xFilial("SRA")
Local cDescr	:= CTT->CTT_DESC01
Local cChave  	:= ""
Local nGrava	:= 0
Local nPosFilial:= GdFieldPos("RB8_FILIAL")
Local nPosAMes	:= GdFieldPos("RB8_ANOMES")
Local nPosQPrev	:= 0
Local nPosVPrev	:= 0
Local nQtPrev	:= 0
Local nVlPrev	:= 0
Local cCadastro := OemToAnsi(STR0019) 	//"Quadro por Centro de Custo / Funcao"
Local nx		:= 0
Local nItem		:= 0
Local nSal		:= 0
Local aFunc		:= {}
Local cAnoMes2	:= ""
Local aBtn90	:= {}					// Array de retorno do Ponto de entrada CSA90B02
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private cAnoMes	:= Iif(nPosAMes > 0, aCols[n][nPosAMes],"")

cAnoMes2	:= Stuff(cAnoMes,5,0,"/")
cFil := If(nPosFilial != 0, aAuxCols[nAuxN][nPosFilial],cFil) //carrego a filial da linha em foco na RB8.
cFilRB8 := cFil

If Empty(cAnomes) .Or. ( !Empty(xFilial("RB8")) .And. Empty(cFil) )
	Aviso(OemToAnsi(STR0015), OemToAnsi(STR0049), {"OK"}) //"Atencao"#"Filial e Mês/Ano devem ser preenchidos antes de fazer um lançamento."
	Return .T.
EndIf

aHeader := {}
aCols 	:= {}

// Monta aHeader da GetDados
TrmHeader(@aHeader,{"RBD_CC","RBD_ANOMES"},"RBD")

// Monta o aCols da GetDados
cChave := xFilial("RBD",cFil)+cCC+cAnoMes
Cs090aCols(@aCols,nOpc,"RBD","RBD->RBD_FILIAL+RBD->RBD_CC+RBD->RBD_ANOMES",cChave,aHeader,1)

nPosQPrev := GdFieldPos("RBD_QTPREV")
nPosVPrev := GdFieldPos("RBD_VLPREV")

SETAPILHA()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1][1],aObjSize[1][2] GROUP oGroup TO aObjSize[1][3],aObjSize[1][4]*0.15 LABEL OemToAnsi(STR0027) OF oDlg PIXEL	// "Ano / Mes"
	oGroup:oFont:= oFont

	@ aObjSize[1][1],aObjSize[1][4]*0.16 GROUP oGroup TO aObjSize[1][3],aObjSize[1][4]*0.50 LABEL OemToAnsi(STR0024) OF oDlg PIXEL	// "Codigo do Centro de Custo"
	oGroup:oFont:= oFont

	@ aObjSize[1][1],aObjSize[1][4]*0.51 GROUP oGroup TO aObjSize[1][3],aObjSize[1][4] LABEL OemToAnsi(STR0025) OF oDlg PIXEL	// "Descricao do Centro de Custo"
	oGroup:oFont:= oFont

	@ aObjSize[1][1]+10,aObjSize[1][2]+10 MSGET cAnoMes2	WHEN .F. SIZE 042,10 PIXEL
	@ aObjSize[1][1]+10,aObjSize[1][4]*0.16+10 MSGET cCC 		WHEN .F. SIZE 080,10 PIXEL
	@ aObjSize[1][1]+10,aObjSize[1][4]*0.51+10 MSGET cDescr	WHEN .F. SIZE 165,10 PIXEL

	oGet2 := MSGetDados():New(aObjSize[2][1],aObjSize[2][2],aObjSize[2][3]-15,aObjSize[2][4],nOpc,"Cs090Ok2","AlwaysTrue","RBD_FILIAL",lCsDel,,,,300,,,,,oDlg)
	bSet15	:= {|| If(oGet2:TudoOk(),(nGrava:= 1,oDlg:End()),.F.) }
	bSet24	:= {|| nGrava:=0,oDlg:End()}

	If ExistBlock("CSA90B02")
		aBtn90:=ExecBlock("CSA90B02",.F.,.F.)
		If Valtype(aBtn90)="A".AND.Len(aBtn90)>=2 //Garante que tenha o icone do botao e a função a ser executada
			aadd(aButtons,aBtn90 )
		EndIf
	EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ) CENTERED

If 	nGrava == 1

	nItem := Ascan(aGrvRBD,{|x| x[1]+x[2] == cAnoMes+cCC})
	aGrvRBD := { {cAnoMes,cCC,aCols,aHeader} }

	For nx := 1 to Len(aCols)
		nQtPrev += Iif(nPosQPrev > 0 .And. !(aCols[nx][len(aCols[nx])]), aCols[nx][nPosQPrev], 0)
		nVlPrev += Iif(nPosVPrev > 0 .And. !(aCols[nx][len(aCols[nx])]), aCols[nx][nPosVPrev], 0)
	Next nx

	PcoIniLan("000083")

	Begin Transaction
		Cs090GrRBD()
		EvalTrigger()
	End Transaction

	PcoFinLan("000083")

EndIf

PcoFreeBlq("000083")

aCols 	:= Aclone(aAuxCols)
aHeader	:= Aclone(aAuxHeader)
n		:= nAuxN

nPosQPrev := GdFieldPos("RB8_NRPREV")
nPosVPrev := GdFieldPos("RB8_VLPREV")

If nGrava == 1
	Iif(nPosQPrev > 0, aCols[n][nPosQPrev] := nQtPrev, nil)
	Iif(nPosVPrev > 0, aCols[n][nPosVPrev] := nVlPrev, nil)
EndIf

oGet:Refresh(.T.)
oGet:oBrowse:SetFocus()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090Ok2  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de linha ok da getdados2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090Ok2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Ok2()
Local nPosFunc	:= GdFieldPos("RBD_FUNCAO")
Local nPosQAtu	:= GdFieldPos("RBD_QTATUA")
Local lRet		:= .T.
Local cFunc 	:= ""
Local nx		:= 0

// Verifica se a linha esta deletado
If 	aCols[n][Len(aCols[n])]
	If nPosFunc > 0
		cFunc 	:= aCols[n][nPosFunc]

		dbSelectArea("RBE")
		dbSetOrder(1)
		If dbSeek(xFilial("RBE") + cCC + cAnoMes + cFunc)
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0020), {"OK"}) //"Atencao"#"Item nao pode ser Excluido, pois existe Aprovacao de Vagas."
			lRet := .F.
		EndIf
	EndIf

	If nPosQAtu > 0 .And. lRet
		If aCols[n][nPosQAtu] > 0
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0022), {"OK"}) //"Atencao"#"Item nao pode ser Excluido, pois existe Qtde. atual."
			lRet := .F.
		EndIf
	EndIf

	dbSelectArea("RBD")
	dbGoBottom()
	dbSkip()
	Return lRet
EndIf

If	(nPosFunc > 0 .And. Empty(aCols[n][nPosFunc]))
	Aviso(OemToAnsi(STR0015), OemToAnsi(STR0017), {"OK"}) //"Atencao"#"Nao deixe a Funcao em Branco!"
	Return .F.
EndIf

If 	nPosFunc > 0
	For nx:=1 To Len(aCols)
		If 	aCols[n][nPosFunc]== aCols[nx][nPosFunc]	.And.;
			n # nx .And.!aCols[nx][Len(aCols[nx])] .And.;
			!aCols[n][Len(aCols[n])]
			Aviso(OemToAnsi(STR0015), OemToAnsi(STR0018), {"OK"}) //"Atencao"#"Esta Funcao ja foi incluida"
			Return .F.
		EndIf
	Next nx
EndIf

If !PcoVldLan('000083','01','CSAA090')
	Return .F.
EndIf

dbSelectArea("RBD")
dbGoBottom()
dbSkip()

Return.T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090GrRBD ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 16/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os arquivos de RBD.                				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090GrRBD()    				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090GrRBD(n)
Local nx 		:= 0
Local ny 		:= 0
Local nt 		:= 0
Local aAnterior := {}
Local cCampo	:= ""
Local xConteudo := ""
Local cAuxAMes	:= ""
Local cAuxCC	:= ""
Local aAuxCols 	:= ""
Local cAuxFil	:= ""
Local aAuxHeader:= {}

Default n := 0

For ny := 1 to Len(aGrvRBD)
	cAuxAMes	:= aGrvRBD[ny][1]
	cAuxCC      := aGrvRBD[ny][2]
	aAuxCols 	:= aGrvRBD[ny][3]
	aAuxHeader	:= aGrvRBD[ny][4]
	aAnterior	:= {}

	cAuxFil := If(n > 0 .AND. n <= Len(aAuxCols),aAuxCols[n][1],cFilRB8)
	dbSelectArea("RBD")
	dbSetOrder(1)
	dbSeek(xFilial("RBD",cAuxFil)+cAuxCC+cAuxAMes)
	While !Eof() .And. xFilial("RBD",cAuxFil)+ cAuxCC+ cAuxAMes ==;
							RBD->RBD_FILIAL+ RBD->RBD_CC+ RBD->RBD_ANOMES
		Aadd(aAnterior, RecNo())
		dbSkip()
	EndDo

	For nx:=1 to Len(aAuxCols)
		If nx <= Len(aAnterior)

			dbGoto(aAnterior[nx])
			//--Verifica se esta deletado
			If  aAuxCols[nx][Len(aAuxCols[nx])]
				RecLock("RBD",.F.)
				PcoDetLan("000083","01","CSAA090", .T.)
				dbDelete()
				MsUnlock()
				Loop
			Else
				RecLock("RBD",.F.)
			EndIf

		Else
			If aAuxCols[nx][Len(aAuxCols[nx])]
				Loop
			EndIf

			RecLock("RBD",.T.)
			Replace RBD->RBD_CC			With cCC
			Replace RBD->RBD_ANOMES		With cAuxAMes
			cAuxFil := If(n > 0 .AND. n <= Len(aAuxCols),aAuxCols[n][1],cFilRB8)
			RBD->RBD_FILIAL := xFilial("RBD",cAuxFil)
		EndIf

		For nt := 1 To Len(aAuxHeader)
			If aAuxHeader[nt][10] # "V"
				cCampo	 := Trim(aAuxHeader[nt][2])
				xConteudo:= aAuxCols[nx][nt]
				Replace &cCampo With xConteudo
			EndIf
		Next nt

		MsUnlock()
		PcoDetLan("000083","01","CSAA090")

		If ExistBlock("CSA90RBD")
			Execblock("CSA90RBD",.F.,.F.,{RBD->RBD_FILIAL,RBD->RBD_ANOMES,RBD->RBD_CC})
	 	Endif

	Next nx
Next ny

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090Func  ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 16/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna dados da Funcao.	                				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090Func()    				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs090Func()
Local nPosDFunc	:= GdFieldPos("RBD_DFUNCA")
Local cCodFunc  := &(ReadVar())
Local nPos		:= 0

cDescFunc := FDesc("SRJ",cCodFunc,"SRJ->RJ_DESC",30,xFilial("SRJ",aCols[n][1])) //pego a descricao de acordo com a filial da linha do aCols.

Iif(nPosDFunc > 0, aCols[n][nPosDFunc] := cDescFunc,"")	//Descricao Funcao

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090AdFunc³ Autor ³ Emerson Grassi Rocha ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adiciona Funcoes do C.Custo no aCols.        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090AdFunc()    				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs090AdFunc(nOpc,aFunc,cAnoMes)
Local nAcols	:= 0
Local nCntFor 	:= 0
Local nUsado  	:= Len(aHeader)
Local nx		:= 0
Local nPosFilial:= GdFieldPos("RBD_FILIAL")
Local nPosFunc	:= GdFieldPos("RBD_FUNCAO")
Local nPosDFun	:= GdFieldPos("RBD_DFUNCA")
Local nPosQAtu	:= GdFieldPos("RBD_QTATUA")
Local nPosVAtu	:= GdFieldPos("RBD_VLATUA")
Local nPosQPre	:= GdFieldPos("RBD_QTPREV")
Local nPosVPre	:= GdFieldPos("RBD_VLPREV")

Local nQtdAnt	:= 0
Local nQtPrevAnt:= 0

//Variaveis do Log de ocorrencias
Local aLog		:= {{},{}}
Local aTitle	:= {"",""}
Local cLog		:= ""
Local lFirst	:= .T.

Local cAuxCC		:= ""
Local cAuxAnoMes 	:= ""
Local cAuxFuncao	:= ""
Local cAuxAnt		:= ""
Local cAuxPrevAnt	:= ""
Local cAuxAtu		:= ""
Local cAuxPrevAtu 	:= ""

If nPosFunc > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considerada funcao nao amarrada ao funcionario p/ gerar quadro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to Len(aCols)
		nPos:= Ascan(aFunc, {|x| x[2] == aCols[nx][nPosFunc] })
		If nPos == 0 .And. aCols[nx][nPosQPre] > 0
			Aadd(aFunc,{0,aCols[nx][nPosFunc],aCols[nx][nPosDFun],0, If(nPosFilial > 0,aCols[nx][nPosFilial],xFilial("RBD"))}) //{QtdeFunc,funcao,desc.funcao,qtde sal.previsto}
		EndIf
	Next nx

    nPos := 0

	For nx := 1 to Len(aFunc)
		nPos:= Ascan(aCols, {|x| x[nPosFunc] == aFunc[nx][2]})
		If nPos == 0  //Se nao encontrar

			dbSelectArea("SX3")
			dbSeek("RBD")
			If Len(aCols) != 1 .Or. (Len(aCols) == 1 .And. !Empty(aCols[1][nPosFunc]))

				aadd(aCols,Array(nUsado+If(nOpc#2.And.nOpc#5,1,0)))

				nAcols := Len(aCols)
				For nCntFor := 1 To Len(aHeader)
					aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
				Next nCntFor
				If nOpc # 2 .And. nOpc # 5
					aCols[Len(aCols)][nUsado+1] := .F.
				EndIf
			EndIf
			Iif(nPosFilial > 0, aCols[Len(aCols)][nPosFilial] := aFunc[nx][5], ) //Filial
			Iif(nPosFunc > 0, aCols[Len(aCols)][nPosFunc] := aFunc[nx][2], ) //Cod. Funcao
			Iif(nPosDfun > 0, aCols[Len(aCols)][nPosDFun] := aFunc[nx][3], ) //Desc. Funcao
			Iif(nPosQAtu > 0, aCols[Len(aCols)][nPosQAtu] := aFunc[nx][1], ) //Qt. Atu.Funcion.
			Iif(nPosVAtu > 0, aCols[Len(aCols)][nPosVAtu] := aFunc[nx][4], ) //Vl. Atu.Funcion.
			Iif(nPosQPre > 0, aCols[Len(aCols)][nPosQPre] := aFunc[nx][1], ) //Qt. Prev.Funcion.
			Iif(nPosVPre > 0, aCols[Len(aCols)][nPosVPre] := aFunc[nx][4], ) //Vl. Prev.Funcion.

		Else

			nQtdAnt		:= aCols[nPos][nPosQAtu]
			nQtPrevAnt  := aCols[nPos][nPosQPre]

			//Sempre atualiza quantidade atual devido usuario nao ter como apagar aprovacoes
			aCols[nPos][nPosQAtu] := aFunc[nx][1] //Qt. Atu.Funcion.
			aCols[nPos][nPosVAtu] := aFunc[nx][4] //Vl. Atu.Funcion.

			//Gerar Arquivo Log de ocorrencia quando tiver aprovacao
			If RBE->( dbSeek(xFilial("RBE")+cCC+cAnoMes+aFunc[nx][2]) ) .And. aFunc[nx][1] != nQtdAnt

		    	If lFirst
					aTitle[1] += OemToAnsi(STR0032) + Chr(13) + Chr(10)	//"A quantidade destas funções foram atualizadas no Quadro de Funcionários, porém já existem Aprovações de Vagas e também Vagas"									//
					aTitle[1] += OemToAnsi(STR0033) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)	//"geradas no Módulo Recrutamento e Seleção (SIGARSP). Favor verificar vagas já abertas a fim de evitar duplicidade das informações."

		        	aTitle[1] += STR0034 + Space(31-Len(STR0034))	//"Centro de Custo "
		        	aTitle[1] += STR0027 + Space(11-Len(STR0027))	//"Ano / Mes"
					aTitle[1] += STR0012 + Space(31-Len(STR0012))	//"Funcao"
					aTitle[1] += STR0035 + Space(15-Len(STR0035))	//"Qtde.Ant. "
					aTitle[1] += STR0036 + Space(15-Len(STR0036)+3)	//"Qtde.Prev.Ant."
					aTitle[1] += STR0037 + Space(15-Len(STR0037)-3)	//"Qtde.Atual"
					aTitle[1] += STR0038 + Space(15-Len(STR0038))	//"Qtde.Prev.Atu."

					lFirst := .F.
				Endif

	         	cAuxCC		:= Left(cCC+" - "+RhDescCC(cCC)	, 30)
			    cAuxAnoMes 	:= Left(cAnoMes,4)+" / "+Subst(cAnoMes,5,2)
			    cAuxFuncao	:= Left(aFunc[nx][2]+" - "+aFunc[nx][3], 30)
			    cAuxAnt		:= Str(nQtdAnt,14,2)
			    cAuxPrevAnt	:= Str(nQtPrevAnt,14,2)
			    cAuxAtu		:= Str(aFunc[nx][1],14,2)
			    cAuxPrevAtu := Str(nQtPrevAnt,14,2)

		    	cLog := cAuxCC 		+ Space(1)
    			cLog += cAuxAnoMes	+ Space(2)
    			cLog += cAuxFuncao	+ Space(1)
    			cLog += cAuxAnt		+ Space(1)
    			cLog += cAuxPrevAnt	+ Space(1)
    			cLog += cAuxAtu 	+ Space(1)
    			cLog += cAuxPrevAtu

				Aadd(aLog[1],cLog)

			EndIf
		EndIf
	Next nx

	lFirst  := .T.

	For nx := 1 to Len(aCols)
		nPos:= Ascan(aFunc, {|x| x[2] == aCols[nx][nPosFunc]})
		If nPos == 0  //Se nao encontrar

			nQtdAnt		:= aCols[nx][nPosQAtu]
			nQtPrevAnt  := aCols[nx][nPosQPre]

			//Apagar a linha do Acols mesmo qdo. tiver aprovacao, pois usuario nao tem como apagar aprovacoes
			aCols[nx][len(aCols[nx])] := .T.	//Linha deletada

			//checa no RBE
			If RBE->( dbSeek(xFilial("RBE")+cCC+cAnoMes+aCols[nx][nPosFunc]) )

				//Gerar Arquivo Log de ocorrencia quando tiver aprovacao
				If lFirst
					aTitle[2] += STR0039 + Chr(13) + Chr(10) 	//"Estas funcoes foram eliminadas do Quadro de funcionarios por nao ter funcionarios"
					aTitle[2] += STR0040 + Chr(13) + Chr(10)	//" na funcao atualmente, porem existem aprovacoes de vagas e Vagas geradas no modulo"
					aTitle[2] += STR0041 + Chr(13) + Chr(10) + Chr(13) + Chr(10)	//" Recrutamento e Selecao (SIGARSP) para estas funcoes atraves das aprovacoes de vagas."

					aTitle[2] += STR0034 + Space(31-Len(STR0034)) 	//"Centro de Custo: "
					aTitle[2] += STR0027 + Space(11-Len(STR0027))	//"Ano / Mes"
					aTitle[2] += STR0012 + Space(31-Len(STR0012)) 	//"Funcao"
					aTitle[2] += STR0035 + Space(15-Len(STR0035))	//"Qtde.Ant."
					aTitle[2] += STR0036 + Space(15-Len(STR0036))	//"Qtde.Prev.Ant."

					lFirst := .F.
				Endif

			    cAuxCC		:= Left(cCC+" - "+RhDescCC(cCC)	, 30)
			    cAuxAnoMes 	:= Left(cAnoMes,4)+" / "+Subst(cAnoMes,5,2)
			    cAuxFuncao	:= Left(aFunc[nx][2]+" - "+aFunc[nx][3], 30)
			    cAuxAnt		:= Str(nQtdAnt,14,2)
			    cAuxPrevAnt	:= Str(nQtPrevAnt,14,2)

		    	cLog := cAuxCC 		+ Space(1)
    			cLog += cAuxAnoMes	+ Space(2)
    			cLog += cAuxFuncao	+ Space(1)
    			cLog += PadR(cAuxAnt,14) + Space(1)
    			cLog += PadR(cAuxPrevAnt,14)

				Aadd(aLog[2],cLog)

			EndIf
		EndIf
	Next nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama rotina de Log de Ocorrencias. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fMakeLog(aLog,aTitle,"CSAA090",.T.,,STR0042,"M","P")  //"Ocorrencias na Geracao de Quadro de funcionarios"

EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Cs090PrcFun³ Autor ³ Emerson Grassi Rocha ³ Data ³ 22/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa Quadro de Funcionarios por funcao.  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs090PrcFun()    				                       	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CSAA090   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs090PrcFun(aAuxGrava,cFilDe,cFilAte)

Local cChave  	:= ""
Local nItem		:= 0
Local nSal		:= 0
Local aFunc		:= {}
Local cAnoMes	:= aAuxGrava[1]
Local cInicio	:= ""
Local cFim		:= ""

Private cCC		:= aAuxGrava[2]
Private aGrvRBD := {}

cInicio	:= "SRA->RA_FILIAL+SRA->RA_CC"
cFilAte	:= substr(Rtrim(aAuxGrava[6])+'ZZZZZZZZZZZZ',1,FwGetTamFilial)
cFim	:= cFilAte+cCC

//Carrega os mnemônicos
SetMnemonicos(NIL,NIL,.T.)

dbSelectArea("SRA")
dbSetOrder(2)
dbSeek(cFilDe+cCC,.T.)

While SRA->(!Eof()) .And. &cInicio <= cFim

	If (cCC != SRA->RA_CC) .OR. (xFilial("RBD",SRA->RA_FILIAL) != aAuxGrava[6])
		SRA->(dbSkip())
		Loop
	EndIf

	FSalario(@nSal,,,,"A",AnoMes(SRA->RA_ADMISSA))

	// Quando nao tenho SRA->RA_TIPOPGT e SRA->RA_CATFUN definidos no SRA
	// a variavel nSal volta sem valor
	If 	nSal == Nil
		nSal := 0
	EndIf

	// Verifica os admitido
	If 	MesAno(SRA->RA_ADMISSA) > cAnoMes
		SRA->(dbSkip())
		Loop
	EndIf

	// Verifica os demitidos
	If 	!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) <= cAnoMes
		SRA->(dbSkip())
		Loop
	EndIf

	nPos :=	Ascan(aFunc,{|x| x[2]+x[5]== SRA->RA_CODFUNC + xFilial("RBD",SRA->RA_FILIAL)})
	If 	nPos == 0
		Aadd(aFunc,{1,SRA->RA_CODFUNC,DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),nSal,xFilial("RBD",SRA->RA_FILIAL)})
	Else
		aFunc[nPos][1] += 1
		aFunc[nPos][4] += nSal
	EndIf

	dbSelectArea("SRA")
	SRA->(dbSkip())
EndDo

// Despreza, caso nao exista nenhum funcionario nesta funcao (Demitidos / Admitidos apos a data)
//If Len(aFunc) == 0
//	Return Nil
//EndIf

aHeader := {}
aCols 	:= {}

// Monta aHeader da GetDados
TrmHeader(@aHeader,{"RBD_CC","RBD_ANOMES"},"RBD")

// Monta o aCols da GetDados
cChave := RB8->RB8_FILIAL+cCC+cAnoMes
Cs090aCols(@aCols,4,"RBD","RBD->RBD_FILIAL+RBD->RBD_CC+RBD->RBD_ANOMES",cChave,aHeader,1)

// Verifica/adiciona Todas funcoes do C.Custo no aCols
Cs090AdFunc(4,@aFunc,cAnoMes)

nItem := Ascan(aGrvRBD,{|x| x[1]+x[2] == cAnoMes+cCC})
If nItem == 0
	Aadd(aGrvRBD, {cAnoMes,cCC,aCols,aHeader})
Else
    aGrvRBD[nItem][3] := Aclone(aCols)
EndIf
// Grava dados no RBD
Cs090GrRBD()

Return Nil


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA090                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina :=          {	{ STR0001 	, "PesqBrw"		, 0 , 1,,.F.},; //"Pesquisar"
								{ STR0002 	, "Cs090Gera"	, 0 , 1},;  	//"Gerar Dados"
								{ STR0003	, "Cs090Rot"	, 0 , 4},;	 	//"Quadro Funcion."
								{ STR0023	, "CSAR060"	    , 0 , 6}}	 	//"Imprimir"

Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RB8AnoMWhen³ Autor ³ Eduardo Ju           ³ Data ³ 21.12.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When do campo RB8_ANOMES.			        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RB8AnoMWhen()    		                     		   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                               	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN do Campo RB8_ANOMES  							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RB8AnoMWhen()

Local aSaveArea	 := GetArea()
Local lRet	   	 := .F.
Local nPosNrAtua := GdFieldPos("RB8_NRATUA")

If aCols[n][nPosNrAtua] == 0
	lRet := .T.
EndIf

RestArea(aSaveArea)
Return lRet

//---------------------------------------------
/*/{Protheus.doc} fCs090Fil
Função para validação de acesso à filial escolhida no momento do preenchimento do campo RB8_FILIAL.
@type function
@author esther.viveiro
@since 07/10/2016
@version 1.0
@return lReturn, lógico, indica se a informação está válida (.T.) ou não (.F.)
/*/
Function fCs090Fil()
	Local cCodFil    := &(ReadVar())
	Local nPosFilial := GdFieldPos("RB8_FILIAL")
	Local lRet       := .T.

	If !( RTrim(cCodFil) $ fValidFil() )
		Help(,,OemToAnsi( STR0015 ),,OemToAnsi(STR0048),1,0,,,,,,{ OemToAnsi(STR0050) }) //Usuario sem acesso a filial escolhida. Favor selecionar outra filial.
		lRet := .F.
	Else
		If xFilial("RB8",cCodFil) <> xFilial("RB8")
			Help(,,OemToAnsi( STR0015 ),,OemToAnsi(STR0051),1,0,,,,,,{ OemToAnsi(STR0050) }) //Filial diferente da filial do Centro de Custo. Favor escolher outra filial.
			lRet := .F.
		Else
			IIf(nPosFilial > 0, aCols[n][nPosFilial] := xFilial("RB8",cCodFil),"")	//Cod.Filial
		EndIf
	EndIf
Return lRet
//---------------------------------------------

//---------------------------------------------
/*/{Protheus.doc} RB8FilWhen
Valida se linha de registro da RB8 pode ser alterada. A linha somente poderá ser alterada se o campo RB8_NRATUA estiver vazio.
@type function
@author esther.viveiro
@since 07/10/2016
@version 1.0
@return lReturn, lógico, indica se pode alterar registro (.T.) ou não (.F.)
/*/
Function RB8FilWhen()
Local aSaveArea	 := GetArea()
Local lRet	   	 := .F.
Local nPosNrAtua := GdFieldPos("RB8_NRATUA")

If aCols[n][nPosNrAtua] == 0
	lRet := .T.
EndIf

RestArea(aSaveArea)
Return lRet
//---------------------------------------------
